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

;ID_TIMER	equ		1;刷新周期定时器标号

; 数据段
.data?
hInstance dd ?
hWinMain dd ?
hMenu dd ?
hour dd ?
minute dd ?
second dd ?
timearray  dd 10 dup(?)
clocks dd ?
; 常量
.const
szClassName db 'Win32Clock',0
szCaptionMain db 'Music Clock',0
dwCenterX	dd		80h	;圆心X
dwCenterY	dd		80h	;圆心Y
dwRadius	dd		70h	;半径
rome_3		db	'Ⅲ',0
rome_6		db	'Ⅵ',0
rome_9		db	'Ⅸ',0
rome_12		db	'Ⅻ',0
showTime    db  '%02d:%02d:%02d',0
showTPara   db  '%0d',0
temp db 'ling~ling~ling',0
showButton byte 'button',0
button db 'button',0
; 代码段
.code

; 计算时钟圆周上指定角度半径对应的 X 坐标
_dwPara180	dw	180
_CalcX		proc	_dwDegree,_dwRadius;_dwDegree：角度，_dwRadius：半径
		local	@dwReturn

		fild	dwCenterX
		fild	_dwDegree
		fldpi
		fmul			;角度*Pi
		fild	_dwPara180
		fdivp	st(1),st	;角度*Pi/180
		fsin			;Sin(角度*Pi/180)
		fild	_dwRadius
		fmul			;半径*Sin(角度*Pi/180)
		fadd			;X+半径*Sin(角度*Pi/180)
		fistp	@dwReturn
		mov	eax,@dwReturn
		ret

_CalcX		endp

; 计算时钟圆周上指定角度半径对应的 Y 坐标
_CalcY		proc	_dwDegree,_dwRadius
		local	@dwReturn

		fild	dwCenterY
		fild	_dwDegree
		fldpi
		fmul
		fild	_dwPara180
		fdivp	st(1),st
		fcos
		fild	_dwRadius
		fmul
		fsubp	st(1),st
		fistp	@dwReturn
		mov	eax,@dwReturn
		ret

_CalcY		endp

; 按照 _dwDegreeInc 的步进角度，画 _dwRadius 为半径的小圆点
_DrawDot	proc	_hDC,_dwDegreeInc,_dwRadius
		local	@dwNowDegree,@dwR
		local	@dwX,@dwY

		mov	@dwNowDegree,0
		mov	eax,dwRadius
		mov	@dwR,eax
		.while	@dwNowDegree <360
			finit
; --------------计算小圆点的圆心坐标--------------
            invoke	_CalcX,@dwNowDegree,@dwR
			mov	@dwX,eax
			invoke	_CalcY,@dwNowDegree,@dwR
			mov	@dwY,eax
; --------------画其它点--------------
            mov	eax,@dwX	
			mov	ebx,eax
			mov	ecx,@dwY
			mov	edx,ecx
			sub	eax,_dwRadius
			add	ebx,_dwRadius
			sub	ecx,_dwRadius
			add	edx,_dwRadius
			invoke	Ellipse,_hDC,eax,ecx,ebx,edx
; --------------画罗马数字--------------
			.if @dwNowDegree==0
			    mov eax,@dwX
			    sub eax,7
			    mov	@dwX,eax
				mov eax,@dwY
			    add eax,5
			    mov	@dwY,eax
			   invoke TextOut,_hDC,@dwX,@dwY,addr rome_12,2
			.elseif @dwNowDegree==90
			    mov eax,@dwX
			    sub eax,23
			    mov	@dwX,eax
				mov eax,@dwY
			    sub eax,5
			    mov	@dwY,eax
			   invoke TextOut,_hDC,@dwX,@dwY,addr rome_3,2
			.elseif @dwNowDegree==180
			    mov eax,@dwX
			    sub eax,7
			    mov	@dwX,eax
				mov eax,@dwY
			    sub eax,20
			    mov	@dwY,eax
			   invoke TextOut,_hDC,@dwX,@dwY,addr rome_6,2
			.elseif @dwNowDegree==270
			    mov eax,@dwX
			    add eax,10
			    mov	@dwX,eax
				mov eax,@dwY
			    sub eax,5
			    mov	@dwY,eax
			   invoke TextOut,_hDC,@dwX,@dwY,addr rome_9,2
			.endif
			mov	eax,_dwDegreeInc
			add	@dwNowDegree,eax
		.endw
		ret
_DrawDot	endp

; 画 _dwDegree 角度的线条，半径=时钟半径-参数_dwRadiusAdjust
_DrawLine	proc	_hDC,_dwDegree,_dwRadiusAdjust
		local	@dwR
		local	@dwX1,@dwY1,@dwX2,@dwY2

		mov	eax,dwRadius
		sub	eax,_dwRadiusAdjust
		mov	@dwR,eax
; --------------计算线条两端的坐标--------------
		invoke	_CalcX,_dwDegree,@dwR
		mov	@dwX1,eax
		invoke	_CalcY,_dwDegree,@dwR
		mov	@dwY1,eax
		add	_dwDegree,180
		invoke	_CalcX,_dwDegree,10
		mov	@dwX2,eax
		invoke	_CalcY,_dwDegree,10
		mov	@dwY2,eax
		invoke	MoveToEx,_hDC,@dwX1,@dwY1,NULL
		invoke	LineTo,_hDC,@dwX2,@dwY2
		ret
_DrawLine	endp

;显示时间
_ShowTime	proc	_hWnd,_hDC
		local	@stTime:SYSTEMTIME
		local	@szBuffer[256]:byte
		pushad
		invoke	GetLocalTime,addr @stTime
; --------------画时钟圆周上的点--------------
		invoke	GetStockObject,BLACK_BRUSH
		invoke	SelectObject,_hDC,eax
		invoke	_DrawDot,_hDC,360/12,3	;画12个大圆点
		invoke	_DrawDot,_hDC,360/60,1	;画60个小圆点
;---------------画秒针---------------------
		invoke	CreatePen,PS_SOLID,1,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		movzx	eax,@stTime.wSecond
		mov	ecx,360/60
		mul	ecx			;秒针度数 = 秒 * 360/60
		invoke	_DrawLine,_hDC,eax,40
;---------------画分针---------------------
		invoke	CreatePen,PS_SOLID,2,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		movzx	eax,@stTime.wMinute
		mov	ecx,360/60
		mul	ecx			;分针度数 = 分 * 360/60
		invoke	_DrawLine,_hDC,eax,55
;---------------画时针---------------------
		invoke	CreatePen,PS_SOLID,3,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		movzx	eax,@stTime.wHour
		.if	eax >=	12
			sub	eax,12
		.endif
		mov	ecx,360/12
		mul	ecx
		movzx	ecx,@stTime.wMinute
		shr	ecx,1
		add	eax,ecx
		invoke	_DrawLine,_hDC,eax,70
;---------------显示数字时间---------------------
		invoke	wsprintf,addr @szBuffer,addr showTime,@stTime.wHour,@stTime.wMinute,@stTime.wSecond
		invoke TextOut,_hDC,100,250,addr @szBuffer,8
		invoke	wsprintf,addr @szBuffer,addr showTPara,[timearray]
		invoke TextOut,_hDC,100,270,addr @szBuffer,8
		invoke	wsprintf,addr @szBuffer,addr showTPara,[timearray+4]
		invoke TextOut,_hDC,100,290,addr @szBuffer,8
		invoke	wsprintf,addr @szBuffer,addr showTPara,[timearray+8]
		invoke TextOut,_hDC,100,310,addr @szBuffer,8
;---------------删除画笔对象---------------------
		invoke	GetStockObject,NULL_PEN
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		popad
		ret

_ShowTime	endp

;初始化预存时间数组
_clockInit proc 
       local @temp
       pusha
	   mov clocks,0
	   mov ebx,offset timearray
	   mov @temp,10
	   .while	@temp >0
	       mov eax ,@temp
		   dec eax
		   shl eax,2
		   mov ecx,240001
		   mov [ebx+eax],ecx
		   dec @temp
	   .endw
	   popa
	   ret
_clockInit	endp

;设置预存时间
_clockSet proc _time,i
       pusha
	   mov ecx,i
	   shl ecx ,2;i*4
	   mov eax,_time
	   mov ebx,offset timearray
	   mov [ebx+ecx],eax
	   inc clocks
	   popa
	   ret
_clockSet	endp

;刷新预存时间数组
_clockFlush proc 
       local @temp,@i
	   mov @temp,10
       pusha
	   mov ebx,offset timearray
	   mov edx,240001
	   .while	@temp >0
	        mov eax ,@temp
		    dec eax
		    shl eax,2
			cmp [ebx+eax],edx
			jz @F
			push [ebx+eax];从后向前保存数据就
			mov ecx,240001;统一用240001标记无效数据
	        mov [ebx+eax],ecx
@@:         dec @temp
	   .endw
	   mov edx,clocks
	   mov @temp,edx
	   mov @i,0
	   .while	@temp >0
	        mov eax ,@i
		    shl eax,2
			pop [ebx+eax]
            dec @temp
			inc @i
	   .endw
	   popa
	   ret
_clockFlush	endp

;删除预存时间
_clockDelet proc i
       pusha
	   mov ecx,i
	   shl ecx ,2;i*4
	   mov ebx,offset timearray
	   mov eax,240001;统一用240001标记无效数据
	   mov [ebx+ecx],eax
	   dec clocks
	   invoke _clockFlush
	   popa
	   ret
_clockDelet	endp

;通过寄存器除法取余分别拿到预设时间的时分秒
_getTime proc _time
;--------拿到秒数--------------
       mov bx,100
	   mov eax,_time
	   mov edx,_time
	   shr edx,16
	   div bx
	   movzx edx,dx
	   mov second,edx
;--------拿到分数--------------
       mov dx,0
	   movzx edx,dx
       movzx eax,ax
       div bx
	   mov minute,edx
;--------拿到时数--------------
       movzx edx,al
       mov hour,edx
	ret
_getTime endp

;闹钟响应程序
_clock proc	_hWnd
       local	@stTime:SYSTEMTIME
	   local	@time;计算循环判断次数
	   local	@i;计算循环判断次数
	   pushad
	   invoke	GetLocalTime,addr @stTime
	   mov ebx,clocks
	   mov @time,ebx
	   mov ecx,offset timearray
	   mov @i,0
	   .while	@time >0
		   mov ebx ,@i
		   shl ebx,2
	       invoke   _getTime,[ecx+ebx]
	       movzx	eax,@stTime.wSecond
	       cmp eax,second
	       jnz @F
	       movzx	eax,@stTime.wMinute
	       cmp eax,minute
	       jnz @F
		   cmp eax,0
		   jz @r
	       movzx	eax,@stTime.wHour
	       cmp eax,hour
	       jnz @F
	       jz @r
@r:     invoke  MessageBox,hWinMain,addr temp,offset szCaptionMain,MB_OK
@@:     dec	@time
        inc @i
	   .endw
	   popad
	   ret 
_clock	endp

;消息处理主函数
_ProcWinMain proc uses ebx edi esi, hWnd, uMsg, wParam, lParam

    local	@stPS:PAINTSTRUCT
    mov eax,uMsg
	.if	eax ==	WM_TIMER;刷新定时器消息
			invoke	InvalidateRect,hWnd,NULL,TRUE
		.elseif	eax ==	WM_PAINT
			invoke	BeginPaint,hWnd,addr @stPS
			invoke	_ShowTime,hWnd,eax
			invoke	_clock,hWnd
			invoke	EndPaint,hWnd,addr @stPS
		.elseif	eax ==	WM_CREATE
			;invoke	SetTimer,hWnd,ID_TIMER,1000,NULL;设置刷新周期1s定时器
			invoke	SetTimer,hWnd,1,1000,NULL;设置刷新周期1s定时器
			invoke CreateWindowEx,NULL,offset button,offset showButton,\
		      WS_CHILD or WS_VISIBLE,300,100,60,30,\  
		      hWnd,1,hInstance,NULL  ;1表示该按钮的句柄是1
        .elseif eax == WM_CLOSE
		    ;invoke	KillTimer,hWnd,ID_TIMER;撤销刷新周期定时器
			invoke	KillTimer,hWnd,1;撤销刷新周期定时器
            invoke DestroyWindow,hWinMain
            invoke PostQuitMessage,NULL
		.elseif eax==WM_COMMAND  ;点击时候产生的消息是WM_COMMAND
		      mov eax,wParam  ;其中参数wParam里存的是句柄，如果点击了一个按钮，则wParam是那个按钮的句柄
		       .if eax==1  
			     invoke _clockDelet,1
               .endif
        .else  
            invoke DefWindowProc,hWnd,uMsg,wParam,lParam
          ret
    .endif
    xor eax,eax
    ret
_ProcWinMain endp

;初始化函数
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
        WS_SYSMENU or WS_MINIMIZEBOX, \
        800,500,600,400, \
        NULL,hMenu,hInstance,NULL
    mov hWinMain,eax
    invoke ShowWindow,hWinMain,SW_SHOWNORMAL
    invoke UpdateWindow,hWinMain
    ;-------消息循环---------
	invoke _clockInit
	invoke _clockSet,190303,0
	invoke _clockSet,190304,1
	invoke _clockSet,190305,2
    .while TRUE
        invoke GetMessage,addr @stMsg,NULL,0,0
        .break .if eax == 0
        invoke	TranslateAccelerator,hWinMain,@hAccelerator,addr @stMsg
        invoke TranslateMessage,addr @stMsg
        invoke DispatchMessage,addr @stMsg
    .endw
    ret
_WinMain endp

start:
    call _WinMain
    invoke ExitProcess,NULL
    end start