    format PE GUI 5.0       ; Subsystem Version (min Windows 2000)

;   =========================================================
    section '.code' code import writeable readable executable
;   =========================================================

    include 'win32ax.inc'

;   =========================================================
    library user32, 'user32.dll',\
            kernel32, 'kernel32.dll',\
            ntdll, 'ntdll.dll'

    import  user32,\
            MessageBoxA, 'MessageBoxA',\
            wsprintfA, 'wsprintfA'

    import  kernel32,\
            ExitProcess, 'ExitProcess'

    import  ntdll,\
            RtlComputeCrc32, 'RtlComputeCrc32'
;   =========================================================


;   =========================================================
;           макрос вычисления CRC "на лету"
;   =========================================================
macro CalcCRC32 
{
    local _byte, _crc

    _crc = 0xFFFFFFFF
    _pol = 0xEDB88320

    repeat crc_end - crc_start
        load _byte byte from crc_start + % - 1
        _crc = _crc xor _byte

        repeat 8
            _crc = (_crc shr 1) xor (_pol * (_crc and 1))
        end repeat
    end repeat

    _crc = _crc xor 0xFFFFFFFF

    crc dd _crc
} 


;   =========================================================
;           ENTRY POINT
;   =========================================================
entry $

    ; недокументированный подход вместо своей реализации
    invoke RtlComputeCrc32, 0, crc_start, crc_end - crc_start
    cmp eax, [crc]
    je _ok

    invoke MessageBoxA, 0, error, tittle, MB_OK + MB_ICONERROR
    jmp _exit

_ok:
    cinvoke wsprintfA, buffer, ok, eax
    invoke MessageBoxA, 0, buffer, tittle, MB_OK + MB_ICONINFORMATION

_exit:
    invoke ExitProcess, 0


crc_start:
    tittle      db 'tittle', 0
    ok          db 'CRC32 от "crc_start" до "crc_end" составляет - %08Xh', 0
    error       db 'Нарушение целостности!', 0
crc_end:

    CalcCRC32       ; вычисляем и сохраняем в переменной с названием "crc"

    buffer      rb 100
