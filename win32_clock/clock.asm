.386
.model flat,stdcall
option casemap:none

; Include �ļ�����
include windows.inc
include gdi32.inc
includelib gdi32.lib
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include		winmm.inc
includelib	winmm.lib
include  shell32.inc
includelib  shell32.lib

; Equ ��ֵ����
IDI_ICON equ 1000h;ͼ��
IDR_MENU equ 2000h;�˵�
IDR_ACCELERATOR equ 2000h;���ټ�
New_Clock    equ 4001h
Delet_Clock  equ 4002h
Exit         equ 4003h
Change_Clock equ 4004h
Style1       equ 4101h
Style2       equ 4102h
Music1_Set   equ 4201h
Music2_Set   equ 4202h
Music3_Set   equ 4203h
Music4_Set   equ 4204h
Help         equ 4301h
MUSIC_1 equ 5001h
MUSIC_2 equ 5002h
MUSIC_3 equ 5003h
MUSIC_4 equ 5004h
DLG_ClockSet     equ 6001h
SC_Confirm       equ 6002h
SC_Cancel        equ 6003h
SC_DTP           equ 6004h
DLG_ClockDelet   equ 6005h
DC_Confirm       equ 6006h
DC_Cancel        equ 6007h
Clock_List       equ 6008h
DLG_ClockChange  equ 6009h
CC_Confirm       equ 6010h
CC_Cancel        equ 6011h
Clock_List2      equ 6012h
CC_DTP           equ 6013h
CCSet_Confirm    equ 6014h
CCSet_Cancel     equ 6015h
IDD_CCSet        equ 6016h
; ���ݶ�
.data?
hInstance dd ?
hWinMain dd ?
hMenu dd ?
hour dd ?
minute dd ?
second dd ?
time dd ?
timearray  dd 10 dup(?)
clocks dd ?
MUSIC dd ?
temp dd ?
styleFlag dd ?
; ����
.const
szClassName db 'Win32Clock',0
szCaptionMain db 'Music Clock',0
dwCenterX	dd		80h	;Բ��X
dwCenterY	dd		80h	;Բ��Y
dwRadius	dd		70h	;�뾶
rome_3		db	'��',0
rome_6		db	'��',0
rome_9		db	'��',0
rome_12		db	'��',0
showTime    db  '%02d:%02d:%02d',0
showClock   db  '����������',0
mptionMain db 'clock',0
clockMessage db 'ling~ling~ling',0
musicChange db '��ȷ��Ҫ�޸�����������',0
clocksNumAlert1 db '������������Ϊ10��',0
clocksNumAlert2 db '��ǰû�����ӿ���ɾ����',0
clocksNumAlert3 db '��ǰû�����ӣ�',0
clocksNumAlert4 db '��û��ѡ��Ҫɾ�����',0
Button1txt db '����',0
Button2txt db 'ɾ��',0
button db 'button',0
open db 'open',0
domain db 'https://github.com/williamslay',0
; �����
.code

; ����ʱ��Բ����ָ���ǶȰ뾶��Ӧ�� X ����
_dwPara180	dw	180
_CalcX		proc	_dwDegree,_dwRadius;_dwDegree���Ƕȣ�_dwRadius���뾶
		local	@dwReturn

		fild	dwCenterX
		fild	_dwDegree
		fldpi
		fmul			;�Ƕ�*Pi
		fild	_dwPara180
		fdivp	st(1),st	;�Ƕ�*Pi/180
		fsin			;Sin(�Ƕ�*Pi/180)
		fild	_dwRadius
		fmul			;�뾶*Sin(�Ƕ�*Pi/180)
		fadd			;X+�뾶*Sin(�Ƕ�*Pi/180)
		fistp	@dwReturn
		mov	eax,@dwReturn
		ret

_CalcX		endp

; ����ʱ��Բ����ָ���ǶȰ뾶��Ӧ�� Y ����
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

; ���� _dwDegreeInc �Ĳ����Ƕȣ��� _dwRadius Ϊ�뾶��СԲ��
_DrawDot	proc	_hDC,_dwDegreeInc,_dwRadius
		local	@dwNowDegree,@dwR
		local	@dwX,@dwY

		mov	@dwNowDegree,0
		mov	eax,dwRadius
		mov	@dwR,eax
		.while	@dwNowDegree <360
			finit
; --------------����СԲ���Բ������--------------
            invoke	_CalcX,@dwNowDegree,@dwR
			mov	@dwX,eax
			invoke	_CalcY,@dwNowDegree,@dwR
			mov	@dwY,eax
; --------------��������--------------
            mov	eax,@dwX	
			mov	ebx,eax
			mov	ecx,@dwY
			mov	edx,ecx
			sub	eax,_dwRadius
			add	ebx,_dwRadius
			sub	ecx,_dwRadius
			add	edx,_dwRadius
			invoke	Ellipse,_hDC,eax,ecx,ebx,edx
; --------------����������--------------
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

; �� _dwDegree �Ƕȵ��������뾶=ʱ�Ӱ뾶-����_dwRadiusAdjust
_DrawLine	proc	_hDC,_dwDegree,_dwRadiusAdjust
		local	@dwR
		local	@dwX1,@dwY1,@dwX2,@dwY2

		mov	eax,dwRadius
		sub	eax,_dwRadiusAdjust
		mov	@dwR,eax
; --------------�����������˵�����--------------
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

;��ʾʱ�䣨ָ��ʽ��
_ShowTime1	proc	_hWnd,_hDC
		local	@stTime:SYSTEMTIME
		local	@szBuffer[256]:byte
		pushad
		invoke	GetLocalTime,addr @stTime
; --------------��ʱ��Բ���ϵĵ�--------------
		invoke	GetStockObject,BLACK_BRUSH
		invoke	SelectObject,_hDC,eax
		invoke	_DrawDot,_hDC,360/12,3	;��12����Բ��
		invoke	_DrawDot,_hDC,360/60,1	;��60��СԲ��
;---------------������---------------------
		invoke	CreatePen,PS_SOLID,1,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		movzx	eax,@stTime.wSecond
		mov	ecx,360/60
		mul	ecx			;������� = �� * 360/60
		invoke	_DrawLine,_hDC,eax,40
;---------------������---------------------
		invoke	CreatePen,PS_SOLID,2,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		movzx	eax,@stTime.wMinute
		mov	ecx,360/60
		mul	ecx			;������� = �� * 360/60
		invoke	_DrawLine,_hDC,eax,55
;---------------��ʱ��---------------------
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
;---------------��ʾ����ʱ��--------------------
		invoke	wsprintf,addr @szBuffer,addr showTime,@stTime.wHour,@stTime.wMinute,@stTime.wSecond
		invoke TextOut,_hDC,100,250,addr @szBuffer,8
;---------------ɾ�����ʶ���---------------------
		invoke	GetStockObject,NULL_PEN
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		popad
		ret

_ShowTime1	endp

;��ʾʱ�䣨ָ��ʽ��
_ShowTime2	proc	_hWnd,_hDC
		local	@stTime:SYSTEMTIME
		local	@szBuffer[256]:byte
		local   @Font:LOGFONT
		pushad
		invoke	GetLocalTime,addr @stTime
		mov  @Font.lfHeight, -30
		mov  @Font.lfCharSet, GB2312_CHARSET
		invoke  CreateFontIndirect,addr @Font
		invoke SelectObject,_hDC,eax
;---------------��ʾ����ʱ��--------------------
		invoke	wsprintf,addr @szBuffer,addr showTime,@stTime.wHour,@stTime.wMinute,@stTime.wSecond
		invoke TextOut,_hDC,70,100,addr @szBuffer,8
		popad
		ret
_ShowTime2	endp

;ͨ���Ĵ�������ȡ��ֱ��õ�Ԥ��ʱ���ʱ����
_getTime proc _time
       pusha
;--------�õ�����--------------
       mov bx,100
	   mov eax,_time
	   mov edx,_time
	   shr edx,16
	   div bx
	   movzx edx,dx
	   mov second,edx
;--------�õ�����--------------
       mov dx,0
	   movzx edx,dx
       movzx eax,ax
       div bx
	   mov minute,edx
;--------�õ�ʱ��--------------
       movzx edx,al
       mov hour,edx
	   popa
	ret
_getTime endp

;ͨ���Ĵ����˷���ʱ���뻯Ϊ��
_TimeChange proc _Hour,_Minute,_Second
       pusha
	   mov bl,100
	   mov eax,_Hour
	   mul bl
	   add eax,_Minute
	   mul bx
	   mov cx,ax
	   mov ax,dx
	   shl eax,16
	   mov ax,cx
	   add eax,_Second
	   mov time,eax
	   popa
	ret
_TimeChange endp

;����������ʾ
_ShowClock	proc	_hWnd,_hDC       
        local	@szBuffer[256]:byte
		local	@stRect:RECT
		pushad
		invoke  SetRect,addr @stRect,300,20,380,60
		invoke	DrawText,_hDC,addr showClock,-1,\
				addr @stRect,\
				DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_EDITCONTROL
		mov eax ,clocks
		cmp eax ,0
		jz @0
		cmp eax ,1
		jz @1
		cmp eax ,2
		jz @2
		cmp eax ,3
		jz @3
		cmp eax ,4
		jz @4
		cmp eax ,5
		jz @5
		cmp eax ,6
		jz @6
		cmp eax ,7
		jz @7
		cmp eax ,8
		jz @8
		cmp eax ,9
		jz @9
		cmp eax ,10
		jz @10
@0:         invoke TextOut,_hDC,300,60,offset clocksNumAlert3,14
            popad
		    ret
@10:		invoke  _getTime,[timearray+36]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,380,140,addr @szBuffer,8
@9:		    invoke  _getTime,[timearray+32]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,380,120,addr @szBuffer,8
@8:		    invoke  _getTime,[timearray+28]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,380,100,addr @szBuffer,8
@7:		    invoke  _getTime,[timearray+24]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,380,80,addr @szBuffer,8
@6:		    invoke  _getTime,[timearray+20]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,380,60,addr @szBuffer,8
@5:		    invoke  _getTime,[timearray+16]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,300,140,addr @szBuffer,8
@4:		    invoke  _getTime,[timearray+12]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,300,120,addr @szBuffer,8
@3:		    invoke  _getTime,[timearray+8]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,300,100,addr @szBuffer,8
@2:		    invoke  _getTime,[timearray+4]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,300,80,addr @szBuffer,8
@1:		    invoke  _getTime,[timearray]
            invoke	wsprintf,addr @szBuffer,addr showTime,hour,minute,second
		    invoke TextOut,_hDC,300,60,addr @szBuffer,8
		popad
		ret
_ShowClock   endp

;��ʼ��Ԥ��ʱ������
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

;����Ԥ��ʱ������
_clockArraySet proc _time,i
       pusha
	   mov ecx,i
	   shl ecx ,2;i*4
	   mov eax,_time
	   mov ebx,offset timearray
	   mov [ebx+ecx],eax
	   inc clocks
	   popa
	   ret
_clockArraySet	endp

;ˢ��Ԥ��ʱ������
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
			push [ebx+eax];�Ӻ���ǰ��������
			mov ecx,240001;ͳһ��240001�����Ч����
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

;ɾ��Ԥ��ʱ��
_clockArrayDelet proc i
       pusha
	   mov ecx,i
	   shl ecx ,2;i*4
	   mov ebx,offset timearray
	   mov eax,240001;ͳһ��240001�����Ч����
	   mov [ebx+ecx],eax
	   dec clocks
	   invoke _clockFlush
	   popa
	   ret
_clockArrayDelet	endp

;clockSet�Ի��������
_clockSet proc uses ebx edi esi hWnd,wMsg,wParam,lParam
       local @DTPhandle
       local @set_Time:SYSTEMTIME
       pusha
	   mov	eax,wMsg
		.if	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			 .if eax == SC_Cancel
			    invoke	EndDialog,hWnd,NULL
			 .elseif eax == SC_Confirm
			    invoke GetDlgItem,hWnd,SC_DTP
				mov  @DTPhandle,eax
			    invoke SendMessage,@DTPhandle,DTM_GETSYSTEMTIME,0,addr @set_Time
				invoke _TimeChange,@set_Time.wHour,@set_Time.wMinute,@set_Time.wSecond
				invoke _clockArraySet,time,clocks
				invoke	EndDialog,hWnd,NULL
			 .endif
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
	   popa
	   ret
_clockSet	endp

;clockDelet�Ի��������
_clockDelet proc uses ebx edi esi hWnd,wMsg,wParam,lParam
       local @Listhandle
	   local @szBuffer[256]:byte
	   local @i
	   pusha
	   invoke GetDlgItem,hWnd,Clock_List
	   mov  @Listhandle,eax
	   mov	eax,wMsg
	    .if eax ==  WM_INITDIALOG
		    mov @i, 0
			mov ebx,offset timearray
			mov edx ,clocks
			.while	@i < edx
	           mov eax ,@i
		       shl eax,2
		       invoke  _getTime,[ebx+eax]
               invoke  wsprintf,addr @szBuffer,addr showTime,hour,minute,second
			   invoke  SendMessage,@Listhandle,LB_ADDSTRING,NULL, addr @szBuffer
			   mov edx ,clocks
		       inc  @i
	        .endw
		.elseif	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			 .if eax == DC_Cancel
			    invoke	EndDialog,hWnd,NULL
			 .elseif eax == DC_Confirm
			    invoke SendMessage,@Listhandle,LB_GETCURSEL,0,0
				.if eax == LB_ERR
				   invoke MessageBox,hWinMain,addr clocksNumAlert4,offset mptionMain,MB_OK
				.else
				    mov @i,eax
				    invoke SendMessage,@Listhandle,LB_DELETESTRING,@i,0
				    invoke _clockArrayDelet,@i
				.endif
			 .endif
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
	   popa
	   ret
_clockDelet	endp

;CCSet�Ի��������
_CCSet proc uses ebx edi esi hWnd,wMsg,wParam,lParam
       local @DTPhandle
       local @set_Time:SYSTEMTIME
       pusha
	   invoke GetDlgItem,hWnd,CC_DTP
	   mov  @DTPhandle,eax
	   mov  eax,lParam
	   mov	eax,wMsg
	    .if eax ==  WM_INITDIALOG
			    ;��ʾѡ�е�ʱ��
	            mov ebx,offset timearray
	            mov ecx,lParam
	            shl ecx,2
	            invoke  _getTime,[ebx+ecx]
				mov eax,hour
	            mov @set_Time.wHour   ,ax
				mov eax,minute
	            mov @set_Time.wMinute ,ax
				mov eax,second
	            mov @set_Time.wSecond ,ax
				;�����壬��㸳ֵ��ʹ�ṹ�������壬������������˼���
				mov eax,2020
				mov @set_Time.wYear ,ax
				mov eax,11
				mov @set_Time.wMonth ,ax
				mov eax,2
				mov @set_Time.wDayOfWeek ,ax
				mov eax,10
				mov @set_Time.wDay ,ax
				mov eax,0
				mov @set_Time.wMilliseconds ,ax
	            invoke SendMessage,@DTPhandle,DTM_SETSYSTEMTIME,GDT_VALID,addr @set_Time
		.elseif	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			 .if eax == CCSet_Cancel
			    invoke	EndDialog,hWnd,NULL
			 .elseif eax == CCSet_Confirm
			    invoke SendMessage,@DTPhandle,DTM_GETSYSTEMTIME,0,addr @set_Time
				invoke _TimeChange,@set_Time.wHour,@set_Time.wMinute,@set_Time.wSecond
				mov ebx,offset timearray
	            mov ecx, temp
				shl ecx,2
				mov edx ,time
	            mov [ebx+ecx],edx
				invoke	EndDialog,hWnd,NULL
			 .endif
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
	   popa
	   ret
_CCSet	endp

;clockChang�Ի��������
_clockChange proc uses ebx edi esi hWnd,wMsg,wParam,lParam
       local @Listhandle
	   local @szBuffer[256]:byte
	   local @i
	   pusha
	   invoke GetDlgItem,hWnd,Clock_List2
	   mov  @Listhandle,eax
	   mov	eax,wMsg
	    .if eax ==  WM_INITDIALOG
		    mov @i, 0
			mov ebx,offset timearray
			mov edx ,clocks
			.while	@i < edx
	           mov eax ,@i
		       shl eax,2
		       invoke  _getTime,[ebx+eax]
               invoke  wsprintf,addr @szBuffer,addr showTime,hour,minute,second
			   invoke  SendMessage,@Listhandle,LB_ADDSTRING,NULL, addr @szBuffer
			   mov edx ,clocks
		       inc  @i
	        .endw
		.elseif	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			 .if eax == CC_Cancel
			    invoke	EndDialog,hWnd,NULL
			 .elseif eax == CC_Confirm
			    invoke SendMessage,@Listhandle,LB_GETCURSEL,0,0
				.if eax == LB_ERR
				   invoke MessageBox,hWinMain,addr clocksNumAlert4,offset mptionMain,MB_OK
				.else
				    mov temp,eax
					invoke  SendMessage,@Listhandle,LB_DELETESTRING,temp,0
					invoke	DialogBoxParam,hInstance,IDD_CCSet,NULL,offset _CCSet,temp
					mov ebx,offset timearray
					mov eax ,temp
		            shl eax,2
		            invoke  _getTime,[ebx+eax]
                    invoke  wsprintf,addr @szBuffer,addr showTime,hour,minute,second
			        invoke  SendMessage,@Listhandle,LB_ADDSTRING,NULL, addr @szBuffer
				.endif
			 .endif
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
	   popa
	   ret
_clockChange	endp

;������Ӧ����
_clock proc	_hWnd
       local	@stTime:SYSTEMTIME
	   local	@time;����ѭ���жϴ���
	   local	@i;����ѭ���жϴ���
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
@r:     invoke PlaySound,MUSIC,hInstance,SND_ASYNC or SND_RESOURCE or SND_NODEFAULT 
        invoke  MessageBox,hWinMain,addr clockMessage,offset mptionMain,MB_OK
		.if eax==1
	   invoke  PlaySound,NULL,NULL,SND_ASYNC 
		.endif
@@:     dec	@time
        inc @i
	   .endw
	   popad
	   ret 
_clock	endp


;��Ϣ����������
_ProcWinMain proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
    local	@stPS:PAINTSTRUCT
    mov eax,uMsg
	.if	eax ==	WM_TIMER;ˢ�¶�ʱ����Ϣ
			invoke	InvalidateRect,hWnd,NULL,TRUE
		.elseif	eax ==	WM_PAINT
		    .if styleFlag == 1
			  invoke	BeginPaint,hWnd,addr @stPS
			  invoke	_ShowTime1,hWnd,eax
			  invoke  _ShowClock,hWnd,eax
			.elseif styleFlag == 2
			  invoke	BeginPaint,hWnd,addr @stPS
			  invoke	_ShowTime2,hWnd,eax
			  invoke  _ShowClock,hWnd,eax
			.endif			
			invoke	_clock,hWnd
			invoke	EndPaint,hWnd,addr @stPS
		.elseif	eax ==	WM_CREATE
			invoke	SetTimer,hWnd,1,1000,NULL;����ˢ������1s��ʱ��
			invoke CreateWindowEx,NULL,offset button,offset Button1txt,\
		      WS_CHILD or WS_VISIBLE,300,200,60,30,\  
		      hWnd,New_Clock,hInstance,NULL  
			invoke CreateWindowEx,NULL,offset button,offset Button2txt,\
		      WS_CHILD or WS_VISIBLE,380,200,60,30,\  
		      hWnd,Delet_Clock,hInstance,NULL  
        .elseif eax == WM_CLOSE
			invoke	KillTimer,hWnd,1;����ˢ�����ڶ�ʱ��
            invoke DestroyWindow,hWinMain
            invoke PostQuitMessage,NULL
		.elseif eax == WM_COMMAND  ;���ʱ���������Ϣ��WM_COMMAND
		      mov eax,wParam  ;���в���wParam�����Ǿ������������һ����ť����wParam���Ǹ���ť�ľ��
			  movzx	eax,ax;���ټ��Ĵ���
			   ;�˳�
			   .if eax ==  Exit
			     invoke	KillTimer,hWnd,1;����ˢ�����ڶ�ʱ��
                 invoke DestroyWindow,hWinMain
                 invoke PostQuitMessage,NULL
			   .endif
			   ;����������
		       .if eax == New_Clock  
			       .if clocks == 10
				     invoke MessageBox,hWinMain,addr clocksNumAlert1,offset mptionMain,MB_OK
				   .elseif
				     invoke	DialogBoxParam,hInstance,DLG_ClockSet,NULL,offset _clockSet,NULL
				   .endif
               .endif
			   ;ɾ������
			   .if eax == Delet_Clock  
			       .if clocks == 0
				     invoke MessageBox,hWinMain,addr clocksNumAlert2,offset mptionMain,MB_OK
				   .elseif
				     invoke	DialogBoxParam,hInstance,DLG_ClockDelet,NULL,offset _clockDelet,NULL
				   .endif
               .endif
			   ;�޸�����
			   .if eax == Change_Clock
			         .if clocks == 0
				     invoke MessageBox,hWinMain,addr clocksNumAlert2,offset mptionMain,MB_OK
				   .elseif
				     invoke	DialogBoxParam,hInstance,DLG_ClockChange,NULL,offset _clockChange,NULL
				   .endif
			   .endif
			   ;�����ֵ�ѡ��
			   .if	eax >=	Music1_Set && eax <= Music4_Set
			    mov ebx,eax
				.if eax == Music1_Set 
				   invoke PlaySound,MUSIC_1,hInstance,SND_ASYNC or SND_RESOURCE or SND_NODEFAULT 
				   invoke MessageBox,hWinMain,addr musicChange,offset mptionMain,MB_YESNO
			       .if eax == IDYES
				    invoke  PlaySound,NULL,NULL,SND_ASYNC
					mov MUSIC , MUSIC_1
				   .elseif eax == IDNO
					invoke  PlaySound,NULL,NULL,SND_ASYNC
					jmp  @F
				   .endif
			    .endif
				.if eax == Music2_Set 
				   invoke PlaySound,MUSIC_2,hInstance,SND_ASYNC or SND_RESOURCE or SND_NODEFAULT 
				   invoke MessageBox,hWinMain,addr musicChange,offset mptionMain,MB_YESNO
			       .if eax == IDYES
				    invoke  PlaySound,NULL,NULL,SND_ASYNC
					mov MUSIC , MUSIC_2
				   .elseif eax == IDNO
					invoke  PlaySound,NULL,NULL,SND_ASYNC
					jmp  @F
				   .endif
			    .endif
				.if eax == Music3_Set
				   invoke PlaySound,MUSIC_3,hInstance,SND_ASYNC or SND_RESOURCE or SND_NODEFAULT 
				   invoke MessageBox,hWinMain,addr musicChange,offset mptionMain,MB_YESNO
			       .if eax == IDYES
				    invoke  PlaySound,NULL,NULL,SND_ASYNC
					mov MUSIC , MUSIC_3
				   .elseif eax == IDNO
					invoke  PlaySound,NULL,NULL,SND_ASYNC
					jmp  @F
				   .endif
			    .endif
				.if eax == Music4_Set 
				   invoke PlaySound,MUSIC_4,hInstance,SND_ASYNC or SND_RESOURCE or SND_NODEFAULT 
				   invoke MessageBox,hWinMain,addr musicChange,offset mptionMain,MB_YESNO
			       .if eax == IDYES
				    invoke  PlaySound,NULL,NULL,SND_ASYNC
					mov MUSIC , MUSIC_4
				   .elseif eax == IDNO
					invoke  PlaySound,NULL,NULL,SND_ASYNC
					jmp  @F
				   .endif
			    .endif
			   invoke	CheckMenuRadioItem,hMenu,Music1_Set,Music4_Set,ebx,MF_BYCOMMAND			  
@@:			  .endif
               ;��ϵ����
               .if eax == Help
			       invoke ShellExecute,0,offset open,offset domain,NULL,0,0
			   .endif
			   ;��ʽ�޸�
               .if eax >= Style1 && eax <= Style2
			       mov ebx,eax
				      .if eax == Style1
					    mov  styleFlag,1
					  .elseif eax == Style2
					    mov  styleFlag,2
					  .endif
			       invoke	CheckMenuRadioItem,hMenu,Style1,Style2,ebx,MF_BYCOMMAND	
			   .endif
        .else  
            invoke DefWindowProc,hWnd,uMsg,wParam,lParam
          ret
    .endif
    xor eax,eax
    ret
_ProcWinMain endp

;��ʼ������
_WinMain proc
    local @stWndClass:WNDCLASSEX
    local @stMsg:MSG
    local @hAccelerator

    invoke GetModuleHandle,NULL
    mov hInstance,eax
    ;����˵�
    invoke	LoadMenu,hInstance,IDR_MENU
	mov	hMenu,eax
    ;������ټ�
    invoke	LoadAccelerators,hInstance,IDR_ACCELERATOR
	mov	@hAccelerator,eax
    ;-------ע�ᴰ����---------
    invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
    ;���
    invoke LoadCursor,0,IDC_ARROW
    mov @stWndClass.hCursor,eax
    ;����ͼ��
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
    ;-------������ʾ����---------
    invoke CreateWindowEx,WS_EX_CLIENTEDGE, \
        offset szClassName,offset szCaptionMain, \
        WS_SYSMENU or WS_MINIMIZEBOX, \
        900,500,600,400, \
        NULL,hMenu,hInstance,NULL
    mov hWinMain,eax
    invoke ShowWindow,hWinMain,SW_SHOWNORMAL
    invoke UpdateWindow,hWinMain
    ;-------��Ϣѭ��---------
	invoke _clockInit
	invoke _clockArraySet,190303,0
	invoke _clockArraySet,190304,1
	invoke _clockArraySet,193400,2
	mov MUSIC,5004h
	mov styleFlag,1
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