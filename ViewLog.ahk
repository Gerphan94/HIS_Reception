#NoEnv
#NoTrayIcon
FileEncoding, utf-8

Gui, Font, S16 cNavy BOLD
GUi, Add, Text, x20 y20 w150 , % "LOG SỰ KIỆN"
Gui, Font
Gui, Add, Text, x20 y60 w30 h23 +0x200, % "Ngày:"
Gui, Add, DateTime, x60 y60 w100 vdtDateView, dd/MM/yyyy
Gui, Add, Button, x170 y60 w70 gbtnView, % "Xem"
Gui, Add, ListView, x20 y90 w660 h300 +Grid vMYLIST +AltSubmit, % "STT|Thời gian|Mã TN|Họ tên|Phòng khám|TG gọi số|TG lưu BN|TG lưu TN"
	LV_ModifyCol(1, "40 Center")
	LV_ModifyCol(2, "120 Center")
	LV_ModifyCol(3, "100 Center")
	LV_ModifyCol(4, "140 Right")
	LV_ModifyCol(5, "100 Right")
	LV_ModifyCol(6, "80 Right")
	LV_ModifyCol(7, "80 Right")
	LV_ModifyCol(8, "80 Right")
Gui, Add, StatusBar
Gui, Show,, % "LOG"
Gui, Submit, Nohide
Readlog(dtDateView)
Return

GuiCLose:
GuiEscape:
    ExitApp,

btnView:
    Gui, Submit, Nohide
    Readlog(dtDateView)
    Return

Readlog(idate)
{
    LV_Delete()
    FormatTime, D1, % idate, yyyyMM
    FormatTime, D2, % idate, dd
    path := A_ScriptDir . "\log\" . D1 . "\" . D2 . ".txt"
    IfNotExist, % path
        Return
    Loop
    {
        i := A_Index
        FileReadLine, OutputVar, % path, % i
        If ErrorLevel
            Break
        Loop, Parse, % OutputVar, CSV
        {
            Switch % A_Index
            {
                Case 1:
                    Col1 := A_LoopField
                Case 2:
                    Col2 := A_LoopField
                Case 3:
                    Col3 := A_LoopField
                Case 4:
                    Col4 := A_LoopField
                Case 5:
                    Col5 := fn_ThousandSeperate(A_LoopField)
                Case 6:
                    Col6 := fn_ThousandSeperate(A_LoopField)
                Case 7:
                    Col7 := fn_ThousandSeperate(A_LoopField)
            }
        }
        LV_Add("",i, Col1, Col2, Col3, Col4, Col5, Col6, Col7)
    }
    Return
}

fn_ThousandSeperate(k)
{
	If (k < 1000)
		Return k . " ms"
	Else
		Return, Format("{:d}", (k - mod(k,1000))/1000) . "," . (k - (k - mod(k,1000))/1000) . " ms"
}

