.386
.model flat,stdcall
option casemap:none

; Include 文件定义
include windows.inc
include gdi32.inc
includelib gdi32.lib
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib

; Equ 等值定义
IDI_ICON equ 1000h;图标
IDR_MENU equ 2000h;菜单
IDR_ACCELERATOR equ 2000h;加速键


; 数据段
.data?
hInstance dd ?
hWinMain dd ?
hMenu dd ?

; 常量
.const
szClassName db 'Win32Clock',0
szCaptionMain db 'Music Clock',0

; 代码段
.code


_ProcWinMain proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
 
    mov eax,uMsg

    .if eax == WM_CLOSE
        invoke DestroyWindow,hWinMain
        invoke PostQuitMessage,NULL

    .else
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .endif

    xor eax,eax
    ret
_ProcWinMain endp

_WinMain proc
    local @stWndClass:WNDCLASSEX
    local @stMsg:MSG
    local @hAccelerator

    invoke GetModuleHandle,NULL
    mov hInstance,eax

    ;载入菜单
    invoke	LoadMenu,hInstance,IDR_MENU
	mov	hMenu,eax
    ;载入加速键
    invoke	LoadAccelerators,hInstance,IDR_ACCELERATOR
	mov	@hAccelerator,eax

    ;-------注册窗口类---------
    ;局部变量全0
    invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
    
    ;鼠标
    invoke LoadCursor,0,IDC_ARROW
    mov @stWndClass.hCursor,eax
    ;加载图标
    invoke	LoadIcon,hInstance,IDI_ICON
    mov	@stWndClass.hIcon,eax
    push hInstance
    pop @stWndClass.hInstance
    mov @stWndClass.cbSize,sizeof WNDCLASSEX
    mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW
    mov @stWndClass.lpfnWndProc,offset _ProcWinMain
    mov @stWndClass.hbrBackground,COLOR_WINDOW + 1
    mov @stWndClass.lpszClassName,offset szClassName
    invoke RegisterClassEx,addr @stWndClass
    ;-------加载显示窗口---------
    invoke CreateWindowEx,WS_EX_CLIENTEDGE, \
        offset szClassName,offset szCaptionMain, \
        WS_OVERLAPPEDWINDOW, \
        800,500,600,400, \
        NULL,hMenu,hInstance,NULL
    mov hWinMain,eax
    invoke ShowWindow,hWinMain,SW_SHOWNORMAL
    invoke UpdateWindow,hWinMain
    ;-------消息循环---------
    .while TRUE
        invoke GetMessage,addr @stMsg,NULL,0,0
        .break .if eax == 0
        invoke	TranslateAccelerator,hWinMain,@hAccelerator,addr @stMsg
        .if eax == 0
        invoke TranslateMessage,addr @stMsg
        invoke DispatchMessage,addr @stMsg
        .endif
    .endw
    ret
_WinMain endp

start:
    call _WinMain
    invoke ExitProcess,NULL
    end start