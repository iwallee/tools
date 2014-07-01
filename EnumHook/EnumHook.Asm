;===================================================================================
;
;  作者：一块三毛钱
;  邮箱：zhongts@163.com
;  日期：2005.6.18
;
;  遍历全局钩子
;
;  v0.0.1 (2005.6.18)
;
;      [+] 遍历全局钩子，显示哪些动态库添加了钩子
;
;          * 刷新前需要先动一动鼠标，摁几下键盘什么的才能显示某些模块的名字。
;
;===================================================================================

.386
.model flat, stdcall
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include comctl32.inc
include advapi32.inc
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib advapi32.lib

include c:\masm32\macros\strings.mac
include common.inc

DlgProc proto :DWORD,:DWORD,:DWORD,:DWORD
_OpenDevice proto
_CloseDevice proto
_Init proto :DWORD
_Refresh proto
_InsertHookInfo proto :DWORD,:DWORD,:DWORD
_GetHookModuleName proto :DWORD,:DWORD

.const
	DLG_MAIN	equ	1000
	IDC_LIST	equ	1001
	IDC_REFRESH	equ	1002
	
	szHandle	db  "钩子句柄",0
	szFunc		db  "钩子函数地址",0
	szType		db  "钩子类型",0
	szModule	db  "钩子所在模块",0
	
	szFlags	db "WH_MSGFILTER      ",0
		db "WH_JOURNALRECORD  ",0
		db "WH_JOURNALPLAYBACK",0
		db "WH_KEYBOARD       ",0
		db "WH_GETMESSAGE     ",0
		db "WH_CALLWNDPROC    ",0
		db "WH_CBT            ",0
		db "WH_SYSMSGFILTER   ",0
		db "WH_MOUSE          ",0
		db "WH_HARDWARE       ",0
		db "WH_DEBUG          ",0
		db "WH_SHELL          ",0
		db "WH_FOREGROUNDIDLE ",0

.data?
	hInst		dd  ?
	hList		dd  ?
	hDevice		dd  ?

.code
start:
	invoke	GetModuleHandle,NULL
	mov	hInst,eax
	invoke	_OpenDevice
	.if eax
		invoke	DialogBoxParam, hInst, DLG_MAIN, NULL, addr DlgProc, NULL
		invoke	InitCommonControls
		invoke	_CloseDevice
	.endif
	invoke	ExitProcess, 0

DlgProc proc uses ebx, hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL	rect : RECT

	mov	eax,uMsg
	.if eax==WM_INITDIALOG
		invoke	_Init, hWnd
		
	.elseif eax==WM_COMMAND
		mov	eax, wParam
		and	eax, 0ffffh
		.if eax==IDC_REFRESH
			invoke	SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
			invoke	_Refresh
		.endif
		
	.elseif eax==WM_CLOSE
		invoke	EndDialog, hWnd, 0
	.else
		mov	eax, FALSE
		ret
	.endif
	mov	eax, TRUE
	ret
DlgProc endp

_OpenDevice proc
	LOCAL	_hSCManager
	LOCAL	_hService
	LOCAL	_szDriverPath[MAX_PATH] : BYTE
	
	;打开驱动链接
	invoke	CreateFile, $CTA0("\\\\.\\slEnumHook"), GENERIC_READ+GENERIC_WRITE, \
			FILE_SHARE_READ+FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov	hDevice, eax
		ret
	.endif
	
	;如果上面的打开失败，则说明驱动没有安装或者没有启动
	invoke	OpenSCManager, NULL, NULL, SC_MANAGER_CREATE_SERVICE
	.if eax!=0
		mov	_hSCManager, eax
		
		;如果驱动已经安装了，则启动驱动程序
		invoke	OpenService, _hSCManager, $CTA0("EnumHook"), SERVICE_START+DELETE
		.if eax!=0
			mov	_hService, eax
			invoke	StartService, _hService, 0, NULL
			invoke	CloseServiceHandle, _hService
			
		;如果驱动程序没有安装，则先安装，再启动
		.else
			push	eax
			invoke GetFullPathName, $CTA0("EnumHook.sys"), sizeof _szDriverPath, addr _szDriverPath, esp
			pop	eax
			invoke	CreateService, _hSCManager, $CTA0("EnumHook"), $CTA0("ZTS's Enumerate Global Windows Service"), \
					SERVICE_START+DELETE, SERVICE_KERNEL_DRIVER, SERVICE_DEMAND_START, \
					SERVICE_ERROR_IGNORE, addr _szDriverPath, NULL, NULL, NULL, NULL, NULL
			.if eax!=0
				mov	_hService, eax
				invoke	StartService, _hService, 0, NULL
				invoke	CloseServiceHandle, _hService
			.endif
		.endif
		invoke	CloseServiceHandle, _hSCManager
	.endif
	
	;启动驱动程序后，再一次打开驱动链接，如果不出意外，这一次应该可以成功
	invoke	CreateFile, $CTA0("\\\\.\\slEnumHook"), GENERIC_READ+GENERIC_WRITE, \
			FILE_SHARE_READ+FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov	hDevice, eax
	.else
		xor	eax, eax
	.endif

	ret
_OpenDevice endp

_CloseDevice proc
	LOCAL	_hSCManager
	LOCAL	_hService
	LOCAL	_sest : SERVICE_STATUS
		
	.if hDevice
		invoke	CloseHandle, hDevice
	.endif
	
	invoke	OpenSCManager, NULL, NULL, SC_MANAGER_CONNECT
	.if eax!=0
		mov	_hSCManager, eax
		
		invoke	OpenService, _hSCManager, $CTA0("EnumHook"), SERVICE_STOP+DELETE
		.if eax!=0
			mov	_hService, eax
			invoke	ControlService, _hService, SERVICE_CONTROL_STOP, addr _sest
			invoke	DeleteService, _hService
			invoke	CloseServiceHandle, _hService
		.endif
		invoke	CloseServiceHandle, _hSCManager
	.endif
	
	ret
_CloseDevice endp

_Init proc uses ebx, hWnd:DWORD
	LOCAL	lvc:LV_COLUMN
	
	invoke	GetDlgItem, hWnd, IDC_LIST
	mov	hList, eax
	
	mov	lvc.imask, LVCF_TEXT+LVCF_WIDTH
	mov	lvc.pszText, offset szHandle
	mov	lvc.lx, 100
	invoke	SendMessage, hList, LVM_INSERTCOLUMN, 0, addr lvc
	mov	lvc.pszText, offset szFunc
	mov	lvc.lx, 100
	invoke	SendMessage, hList, LVM_INSERTCOLUMN, 1, addr lvc
	mov	lvc.pszText, offset szType
	mov	lvc.lx, 120
	invoke	SendMessage, hList, LVM_INSERTCOLUMN, 2, addr lvc
	mov	lvc.pszText, offset szModule
	mov	lvc.lx, 400
	invoke	SendMessage, hList, LVM_INSERTCOLUMN, 3, addr lvc
	
	invoke	SendMessage, hList, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_FULLROWSELECT, LVS_EX_FULLROWSELECT
	
	ret
_Init endp

_Refresh proc
	LOCAL	lpHookInfo
	LOCAL	dwByteReturned
	LOCAL	dwHooks
	
	mov	eax, sizeof HOOK_INFO
	imul	eax, MAX_HOOKS
	invoke	GlobalAlloc, GMEM_FIXED + GMEM_ZEROINIT, eax
	mov	lpHookInfo, eax
	
	and	dwByteReturned, 0
	invoke	DeviceIoControl, hDevice, IOCTL_GET_HOOKINFO, 0, 0, \
			lpHookInfo, (sizeof HOOK_INFO)*MAX_HOOKS, addr dwByteReturned, NULL
	
	.if dwByteReturned!=0
		mov	eax, dwByteReturned
		cdq
		mov	ebx, sizeof HOOK_INFO
		div	ebx
		mov	dwHooks, eax
		
		sub	ebx, ebx
		mov	esi, lpHookInfo
		.while ebx<dwHooks
			invoke	_InsertHookInfo, hList, esi, ebx
			add	esi, sizeof HOOK_INFO
			inc	ebx
		.endw
		
	.endif
	
	ret
_Refresh endp

; 把每一个钩子的信息插入到列表控件中
_InsertHookInfo proc uses esi edi ebx, hWnd:DWORD, lpHookInfo:DWORD, dwNum:DWORD
	LOCAL	_lvi : LV_ITEM
	LOCAL	_buf[MAX_PATH] : byte
	
	mov	esi, lpHookInfo
	assume	esi : ptr HOOK_INFO
	
	;Handle
	mov	_lvi.imask, LVIF_TEXT
	m2m	_lvi.iItem, dwNum
	lea	edi, _buf
	invoke	wsprintf, edi, $CTA0("%08X"), [esi].Handle
	mov	_lvi.iSubItem, 0
	mov	_lvi.pszText, edi
	invoke	SendMessage, hWnd, LVM_INSERTITEM, 0, addr _lvi
	
	;Func
	mov	eax, [esi].FuncOffset
	add	eax, [esi].FuncBaseAddr
	lea	edi, _buf
	invoke	wsprintf, edi, $CTA0("%08X"), eax
	mov	_lvi.iSubItem, 1
	mov	_lvi.pszText, edi
	invoke	SendMessage, hWnd, LVM_SETITEM, 0, addr _lvi
	
	;Type
	mov	eax, [esi].iHook
	inc	eax
	imul	eax, 19
	mov	edi, offset szFlags
	add	edi, eax
	mov	_lvi.iSubItem, 2
	mov	_lvi.pszText, edi
	invoke	SendMessage, hWnd, LVM_SETITEM, 0, addr _lvi
	
	;Module Name
	mov	eax, [esi].FuncBaseAddr
	.if eax!=0
		lea	edi, _buf
		mov	dword ptr [edi], 0
		invoke	_GetHookModuleName, [esi].FuncBaseAddr, edi
		mov	_lvi.iSubItem, 3
		mov	_lvi.pszText, edi
		invoke	SendMessage, hWnd, LVM_SETITEM, 0, addr _lvi
	.endif
	
	ret
_InsertHookInfo endp

; 返回进程空间中所有被加载的模块的基地址为 dwBaseAddress 的模块的路径和文件名
_GetHookModuleName proc uses ebx, dwBaseAddress:DWORD, lpModuleName:DWORD
	LOCAL	_stModule : MODULEENTRY32
	LOCAL	_hSnapshot
	
	invoke	RtlZeroMemory, addr _stModule, sizeof _stModule
	mov	_stModule.dwSize, sizeof _stModule
	invoke	CreateToolhelp32Snapshot, TH32CS_SNAPMODULE, 0
	mov	_hSnapshot, eax
	invoke	Module32First, _hSnapshot, addr _stModule
	.while eax
		mov	eax, _stModule.modBaseAddr
		.if eax==dwBaseAddress
			invoke	lstrcpyn, lpModuleName, addr _stModule.szExePath, MAX_PATH
			.break
		.endif
		invoke	Module32Next, _hSnapshot, addr _stModule
	.endw
	invoke	CloseHandle, _hSnapshot
	
	ret
_GetHookModuleName endp
end start



















