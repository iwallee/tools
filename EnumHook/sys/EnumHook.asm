;==============================================================================
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
;==============================================================================

.386
.model flat, stdcall
option casemap:none

include c:\masm32\include\w2k\ntstatus.inc
include c:\masm32\include\w2k\ntoskrnl.inc
include c:\masm32\include\wxp\wxpundoc.inc
include c:\masm32\Macros\Strings.mac
includelib c:\masm32\lib\w2k\ntoskrnl.lib

include ..\common.inc

_DriverUnload proto :PDRIVER_OBJECT
_DispatchCreateClose proto :PDEVICE_OBJECT,:PIRP
_DispatchControl proto :PDEVICE_OBJECT,:PIRP
_PhkFirstValid proto :DWORD,:DWORD
_PhkNextValid proto :DWORD

.const
	CCOUNTED_UNICODE_STRING	"\\Device\\devEnumHook", g_usDeviceName, 4
	CCOUNTED_UNICODE_STRING	"\\??\\slEnumHook", g_usSymbolicLinkName, 4
	
.data
;	lpPhkFirstValid		pFuncProto2  0BF81BB63h
;	lpPhkNextValid		pFuncProto1  0BF8DBC6Dh
	
	_gptiCurrent	dd  0

.code
DriverEntry proc uses ebx, pDriverObject:PDRIVER_OBJECT, pusRegistryPath:PUNICODE_STRING
	LOCAL	status : NTSTATUS
	LOCAL	pDeviceObject : PDEVICE_OBJECT
	
;	int	3
	invoke	DbgPrint, $CTA0("EnumHook v0.0.1 by 一块三毛钱 2005.6.18\n")
	
	mov	status, STATUS_DEVICE_CONFIGURATION_ERROR

	invoke	IoCreateDevice, pDriverObject, 0, addr g_usDeviceName, FILE_DEVICE_UNKNOWN, 0, FALSE, addr pDeviceObject
	.if eax==STATUS_SUCCESS
		invoke	IoCreateSymbolicLink, addr g_usSymbolicLinkName, addr g_usDeviceName
		.if eax==STATUS_SUCCESS
			mov	eax, pDriverObject
			assume	eax:ptr DRIVER_OBJECT
			mov	[eax].DriverUnload,						offset _DriverUnload
			mov	[eax].MajorFunction[IRP_MJ_CREATE*(sizeof PVOID)],		offset _DispatchCreateClose
			mov	[eax].MajorFunction[IRP_MJ_CLOSE*(sizeof PVOID)],		offset _DispatchCreateClose
			mov	[eax].MajorFunction[IRP_MJ_DEVICE_CONTROL*(sizeof PVOID)],	offset _DispatchControl
			assume	eax:nothing
			
			mov	status, STATUS_SUCCESS
		.else
			invoke	IoDeleteDevice, pDeviceObject
		.endif
	.endif

	mov eax, status
	ret
DriverEntry endp

_DispatchControl proc uses esi edi ebx,pDeviceObject:PDEVICE_OBJECT, pIrp:PIRP
	LOCAL	status : NTSTATUS
	LOCAL	dwBytesReturned
	
;	int	3
	
	and	dwBytesReturned, 0
	mov	status, STATUS_UNSUCCESSFUL
	mov	esi, pIrp
	assume	esi : ptr _IRP
	
	IoGetCurrentIrpStackLocation esi
	mov	edi, eax
	assume	edi : ptr IO_STACK_LOCATION
	
	mov	eax, [edi].Parameters.DeviceIoControl.IoControlCode
	push	edi
	.if eax==IOCTL_GET_HOOKINFO
		assume	esi : ptr _IRP
		assume	edi : ptr IO_STACK_LOCATION
		mov	eax, sizeof HOOK_INFO
		imul	eax, MAX_HOOKS
		.if [edi].Parameters.DeviceIoControl.OutputBufferLength >= eax
			mov	edi, [esi].AssociatedIrp.SystemBuffer
			assume	edi : ptr HOOK_INFO
			
			invoke	PsGetCurrentThread
			mov	ebx, [eax+130h]
			mov	_gptiCurrent, ebx
			invoke	DbgPrint, $CTA0("ETHREAD:%08X, Win32Thread:%08X\n"), eax, _gptiCurrent
			
			assume	esi : nothing
			mov	ebx, -1
			.while ebx!=12
				invoke	_PhkFirstValid, _gptiCurrent, ebx
				assume	eax : ptr HOOK
				.while eax
					push	eax	;_PhkNextValid 的参数
					
					;根据 win32k.sys 中的 _xxxHkCallHook 得到下面的代码
					mov	edx, [eax].ihmod
					cmp	edx, -1
					jz	@F
					mov	esi, _gptiCurrent	;esi -> ThreadInfo
					mov	esi, [esi+2Ch]		;esi -> ProcessInfo
					mov	edx, [esi+edx*4+0A8h]	;edx = [esi].ahmodLibLoaded[ihmod]
					@@:
					
					;-------------------------------------
					m2m	[edi].Handle, [eax].hmodule
					m2m	[edi].FuncOffset, [eax].offPfn
					mov	[edi].FuncBaseAddr, edx
					m2m	[edi].iHook, [eax].iHook
					;-------------------------------------
					
					invoke	DbgPrint, $CTA0("Handle:%08X    FuncOffset:%08X    FuncBaseAddr:%08X    iHook:%d    ihmod:%d\n"), \
							[eax].hmodule, [eax].offPfn, edx, [eax].iHook, [eax].ihmod
					
					call	_PhkNextValid
					add	dwBytesReturned, sizeof HOOK_INFO
					add	edi, sizeof HOOK_INFO
				.endw
				inc	ebx
			.endw
			
			mov	status, STATUS_SUCCESS
		.else
			mov	status, STATUS_BUFFER_TOO_SMALL
		.endif
	.endif
	pop	edi
	assume	edi : ptr IO_STACK_LOCATION
	mov	esi, pIrp
	assume	esi : ptr _IRP
	
	m2m	[esi].IoStatus.Status, status
	m2m	[esi].IoStatus.Information, dwBytesReturned

	assume	esi : nothing
	assume	edi : nothing

	invoke	IoCompleteRequest, pIrp, IO_NO_INCREMENT

	mov eax, status
	ret

_DispatchControl endp

_DispatchCreateClose proc pDeviceObject:PDEVICE_OBJECT, pIrp:PIRP
	mov	eax, pIrp
	assume	eax:ptr _IRP
	mov	[eax].IoStatus.Status, STATUS_SUCCESS
	and	[eax].IoStatus.Information, 0
	assume	eax:nothing
	invoke	IoCompleteRequest, pIrp, IO_NO_INCREMENT

	mov	eax, STATUS_SUCCESS
	ret
_DispatchCreateClose endp

_DriverUnload proc pDriverObject:PDRIVER_OBJECT
	invoke	IoDeleteSymbolicLink, addr g_usSymbolicLinkName
	mov	eax, pDriverObject
	invoke	IoDeleteDevice, (DRIVER_OBJECT PTR [eax]).DeviceObject
	ret
_DriverUnload endp

; 直接取之 win32k.sys 的反汇编代码
_PhkFirstValid proc pThreadInfo:DWORD, nFlags:DWORD
                mov     ecx, pThreadInfo
                mov     edx, nFlags
                mov     eax, [ecx+edx*4+0F8h]
                test    eax, eax
                jnz     short loc_BF81BB88
                mov     eax, [ecx+40h]
                mov     eax, [eax+edx*4+14h]
                test    eax, eax
                jnz     short loc_BF81BB88

loc_BF81BB84:
                ret

loc_BF81BB88:
                test    byte ptr [eax+20h], 80h
                jz      short loc_BF81BB84
                push    eax
                call    _PhkNextValid
                jmp     short loc_BF81BB84
_PhkFirstValid endp

; 直接取之 win32k.sys 的反汇编代码
_PhkNextValid proc pHook:DWORD

                mov     eax, pHook

loc_BF8DBC75:
                mov     ecx, [eax+14h]
                test    ecx, ecx
                jnz     short loc_BF8DBC9A
                test    byte ptr [eax+20h], 1
                jnz     short loc_BF8DBC5C
                mov     ecx, _gptiCurrent
                mov     eax, [eax+18h]
                mov     ecx, [ecx+40h]
                mov     eax, [ecx+eax*4+14h]

loc_BF8DBC92:
                test    eax, eax
                jnz     short loc_BF8DBC60

loc_BF8DBC96:
                ret

loc_BF8DBC9A:
                mov     eax, ecx
                jmp     short loc_BF8DBC92

loc_BF8DBC5C:
                xor     eax, eax
                jmp     short loc_BF8DBC96
loc_BF8DBC60:
                test    byte ptr [eax+20h], 80h
                jnz     short loc_BF8DBC75
                jmp     short loc_BF8DBC96

_PhkNextValid endp

end DriverEntry

