
include winioctl.inc

HOOK struct
	hmodule		dd  ?
	_Z_		dd  4 dup (?)
	phkNext		dd  ?		;14h
	iHook		dd  ?		;18h
	offPfn		dd  ?		;1Ch
	flags		dd  ?		;20h
	ihmod		dd  ?		;24h
	ptiHooked	dd  ?
	rpdesk		dd  ?
HOOK ends

WH_MSGFILTER		equ  -1
WH_JOURNALRECORD	equ  0
WH_JOURNALPLAYBACK	equ  1
WH_KEYBOARD		equ  2
WH_GETMESSAGE		equ  3
WH_CALLWNDPROC		equ  4
WH_CBT			equ  5
WH_SYSMSGFILTER		equ  6
WH_MOUSE		equ  7
WH_HARDWARE		equ  8
WH_DEBUG		equ  9
WH_SHELL		equ  10
WH_FOREGROUNDIDLE	equ  11


IOCTL_GET_HOOKINFO	equ	CTL_CODE(FILE_DEVICE_UNKNOWN, 800h, METHOD_BUFFERED, FILE_READ_ACCESS+FILE_WRITE_ACCESS)

HOOK_INFO struct
	Handle		dd  ?
	FuncOffset	dd  ?
	FuncBaseAddr	dd  ?
	iHook		dd  ?
HOOK_INFO ends

MAX_HOOKS		equ	100

m2m MACRO M1, M2
	push M2
	pop  M1
ENDM
