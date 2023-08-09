#NoEnv
#NoTrayIcon
#SingleInstance, ignore
FileEncoding, utf-8
global path_config := A_ScriptDir . "\CONFIG\POS.ini"

IfNotExist, % path_config
{
    Msgbox, 16, % "Lỗi", % path_config . "`nkhông tồn tại"
    ExitApp, 
}

Global gaResolution := ["1366x768","1920x1080"]
global g_arField := ["Phòng khám","BHYT 5 năm","Mua sổ KB","BN ưu tiên","Giấy CT","Email","CMND","Người thân"]

Gui, Font, s15 BOLD cNavy
Gui, Add, Text, , % "POSition"
Gui, Font,
Gui, Font, cNavy
Gui, Add, DropDownList, w130 choose1 vddlNhom gddlNhom, %  ConvertARRtoString(gaResolution)
Gui, Add, Checkbox, x+210 h21 vcbFind gcbFind, % "Find"
Gui, Add, DropDownList, x+10, % "||" . ConvertARRtoString(g_arField)
Gui, Add, Groupbox, x20 y80 w250 h180, % "Thông tin tiếp nhận"
Gui, Add, Groupbox, x280 y80 w250 h180,  % "Thông tin bệnh nhân"
Gui, Add, Groupbox, x20 y260 w510 h50
;Group 1
Gui, Add, Text, x30 y100 w80 h21 +0x200, % "Phòng khám:"
Gui, Add, Text, x110 y100 h21 +0x200, % "X:"
Gui, Add, edit, x130 y100 w40 vedtx1 cMaroon +Right
Gui, Add, Text, x190 y100 h21 +0x200, % "Y:"
Gui, Add, edit, x210 y100 w40 vedty1 cMaroon +Right

Gui, Add, Text, x30 y125 w80 h21 +0x200, % "BHYT 5 năm:"
Gui, Add, Text, x110 y125 h21 +0x200, % "X:"
Gui, Add, edit, x130 y125 w40 vedtx2 cMaroon +Right
Gui, Add, Text, x190 y125 h21 +0x200, % "Y:"
Gui, Add, edit, x210 y125 w40 vedty2 cMaroon +Right

Gui, Add, Text, x30 y150 w80 h21 +0x200, % "Thẻ tạm:"
Gui, Add, Text, x110 y150 h21 +0x200, % "X:"
Gui, Add, edit, x130 y150 w40 vedtx3 cMaroon +Right
Gui, Add, Text, x190 y150 h21 +0x200, % "Y:"
Gui, Add, edit, x210 y150 w40 vedty3 cMaroon +Right

Gui, Add, Text, x30 y175 w80 h21 +0x200, % "BN ưu tiên:"
Gui, Add, Text, x110 y175 h21 +0x200, % "X:"
Gui, Add, edit, x130 y175 w40 vedtx4 cMaroon +Right
Gui, Add, Text, x190 y175 h21 +0x200, % "Y:"
Gui, Add, edit, x210 y175 w40 vedty4 cMaroon +Right

Gui, Add, Text, x30 y200 w80 h21 +0x200, % "Giấy CT:"
Gui, Add, Text, x110 y200 h21 +0x200, % "X:"
Gui, Add, edit, x130 y200 w40 vedtx5 cMaroon +Right
Gui, Add, Text, x190 y200 h21 +0x200, % "Y:"
Gui, Add, edit, x210 y200 w40 vedty5 cMaroon +Right

Gui, Add, Text, x30 y225 w80 h21 +0x200, % "Hưởng Đ.T:"
Gui, Add, Text, x110 y225 h21 +0x200, % "X:"
Gui, Add, edit, x130 y225 w40 vedtx6 cMaroon +Right
Gui, Add, Text, x190 y225 h21 +0x200, % "Y:"
Gui, Add, edit, x210 y225 w40 vedty6  cMaroon +Right

;Group 2
Gui, Add, Text, x290 y100 w80 h21 +0x200, % "Email:"
Gui, Add, Text,  x370 y100 h21 +0x200, % "X:"
Gui, Add, edit, HwndctlEmailX x390 y100 w40 vedtx7 cMaroon +Right
Gui, Add, Text, x450 y100 h21 +0x200, % "Y:"
Gui, Add, edit, x470 y100 w40 vedty7 cMaroon +Right

Gui, Add, Text, x290 y125 w80 h21 +0x200, % "Cty:"
Gui, Add, Text, x370 y125 h21 +0x200, % "X:"
Gui, Add, edit, x390 y125 w40 vedtx8 cMaroon +Right
Gui, Add, Text, x450 y125 h21 +0x200, % "Y:"
Gui, Add, edit, x470 y125 w40 vedty8 cMaroon +Right

Gui, Add, Text, x290 y150 w80 h21 +0x200, % "CMND:"
Gui, Add, Text, x370 y150 h21 +0x200, % "X:"
Gui, Add, edit, x390 y150 w40 vedtx9 cMaroon +Right
Gui, Add, Text, x450 y150 h21 +0x200, % "Y:"
Gui, Add, edit, x470 y150 w40 vedty9 cMaroon +Right

Gui, Add, Text, x290 y175 w80 h21 +0x200, % "Người thân:"
Gui, Add, Text, x370 y175 h21 +0x200, % "X:"
Gui, Add, edit, x390 y175 w40 vedtx10 cMaroon +Right
Gui, Add, Text, x450 y175 h21 +0x200, % "Y:"
Gui, Add, edit, x470 y175 w40 vedty10 cMaroon +Right

;Group 3
Gui, Add, button, x400 y270 w50 h32 gbtnSave, % "Lưu" 
Gui, Add, button, x460 y270 w50 h32 gbtnCLose , % "Đóng" 
Gui, Add, StatusBar
SB_SetParts(310, 20, 200)
Gui, Show,, % "POSition"
ControlGetText, outVar, ComboBox1, % "POS"
init("1366x768")
; readfile(outVar)
SetTimer, Update, 250
SetTimer, Update, Off
Return

btnClose:
GuiClose:
GuiEscape:
    ExitApp,

init(resolution)
{
    IniRead, xyPhongKham, % path_Config, % resolution, xyPhongKham
    IniRead, xy5Nam, % path_Config, % resolution, xy5Nam
    IniRead, xyTheTam, % path_Config, % resolution, xyTheTam
    IniRead, xyBNUT, % path_Config, % resolution, xyBNUT
    IniRead, xyGCT, % path_Config, % resolution, xyGCT
    IniRead, xyHuongDTuyen, % path_Config, % resolution, xyHuongDTuyen
    IniRead, xyEmail, % path_Config, % resolution, xyEmail
    IniRead, xyCongTy, % path_Config, % resolution, xyCongTy
    IniRead, xyCNMD, % path_Config, % resolution, xyCNMD
    IniRead, xnNguoiThan, % path_Config, % resolution, xnNguoiThan

    GuiControl, , edtx1, % parse_POS(xyPhongKham).x
    GuiControl, , edty1, % parse_POS(xyPhongKham).y
    GuiControl, , edtx2, % parse_POS(xy5Nam).x
    GuiControl, , edty2, % parse_POS(xy5Nam).y
    GuiControl, , edtx3, % parse_POS(xyTheTam).x
    GuiControl, , edty3, % parse_POS(xyTheTam).y
    GuiControl, , edtx4, % parse_POS(xyBNUT).x
    GuiControl, , edty4, % parse_POS(xyBNUT).y
    GuiControl, , edtx5, % parse_POS(xyGCT).x
    GuiControl, , edty5, % parse_POS(xyGCT).y
    GuiControl, , edtx6, % parse_POS(xyHuongDTuyen).x
    GuiControl, , edty6, % parse_POS(xyHuongDTuyen).y
    GuiControl, , edtx7, % parse_POS(xyEmail).x
    GuiControl, , edty7, % parse_POS(xyEmail).y
    GuiControl, , edtx8, % parse_POS(xyCongTy).x
    GuiControl, , edty8, % parse_POS(xyCongTy).y
    GuiControl, , edtx9, % parse_POS(xyCNMD).x
    GuiControl, , edty9, % parse_POS(xyCNMD).y
    GuiControl, , edtx10, % parse_POS(xnNguoiThan).x
    GuiControl, , edty10, % parse_POS(xnNguoiThan).y
}

parse_POS(in_var)
{
    Loop, Parse, % in_var, `,
        {
            if ( A_index = 1 )
                x:= A_LoopField
            Else if ( A_index = 2)
                y := A_LoopField
        }
    return {x:x, y:y}
}

ddlNhom:
    ControlGetText, outVar, ComboBox1, % "POS"
    Return

cbFind:
    Gui, Submit, NoHide

    If (cbFind)
    {
        SetTimer, Update, On
        Winset, AlwaysOnTop, On, % "POSition"
    }
    Else
    {
        SetTimer, Update, Off
        Winset, AlwaysOnTop, Off, % "POSition"
    }
    Return

btnSave:
    Gui, Submit, NoHide
    resolution := ddlNhom

    IniWrite, % edtx1 . "," . edty1, % path_Config, % resolution, xyPhongKham
    IniWrite, % edtx2 . "," . edty2, % path_Config, % resolution, xy5Nam
    IniWrite, % edtx3 . "," . edty3, % path_Config, % resolution, xyTheTam
    IniWrite, % edtx4 . "," . edty4, % path_Config, % resolution, xyBNUT
    IniWrite, % edtx5 . "," . edty5, % path_Config, % resolution, xyGCT
    IniWrite, % edtx6 . "," . edty6, % path_Config, % resolution, xyHuongDTuyen
    IniWrite, % edtx7 . "," . edty7, % path_Config, % resolution, xyEmail
    IniWrite, % edtx8 . "," . edty8, % path_Config, % resolution, xyCongTy
    IniWrite, % edtx9 . "," . edty9, % path_Config, % resolution, xyCNMD
    IniWrite, % edtx10 . "," . edty10, % path_Config, % resolution, xnNguoiThan
    
    SB_SetText("Lưu thành công", 1)
    Return

Update:
    ;Gui, Default
    ControlGetText, var, ComboBox2, % "POSition"
    CoordMode, Mouse, Relative
    MouseGetPos, , , msWin, msCtrl
    WinGetTitle, WinTitle, ahk_id %msWin%
    If (WinTitle = "POSition") Or (WinTitle = "") OR (var = "")
    {
        SB_SetText("Hold Ctrl to pause update", 1)
        SB_SetText("", 3)
        Return
    }
    ControlGetText, ctrlName, %msCtrl%, % WinTitle
    SB_SetText(WinTitle, 1)
    SB_SetText(ctrlName, 3)
    ControlGetPos, ctrlX, ctrlY, , , %msCtrl%, % WinTitle
    Switch, var
    {
        Case "Phòng khám":
            GuiControl, , edtx1, % ctrlX
            GuiControl, , edty1, % ctrlY
        Case "BHYT 5 năm":
            GuiControl, , edtx2, % ctrlX
            GuiControl, , edty2, % ctrlY
        Case "Mua sổ KB":
            GuiControl, , edtx3, % ctrlX
            GuiControl, , edty3, % ctrlY
        Case "BN Ưu tiên":
            GuiControl, , edtx4, % ctrlX
            GuiControl, , edty4, % ctrlY
        Case "Số CT":
            GuiControl, , edtx5, % ctrlX
            GuiControl, , edty5, % ctrlY
        Case "Phòng làm việc":
            GuiControl, , edtx6, % ctrlX
            GuiControl, , edty6, % ctrlY
        Case "Version":
            GuiControl, , edtx7, % ctrlX
            GuiControl, , edty7, % ctrlY
        Case "Email":
            GuiControl, , edtx8, % ctrlX
            GuiControl, , edty8, % ctrlY
        Case "CMND":
            GuiControl, , edtx9, % ctrlX
            GuiControl, , edty9, % ctrlY
        Case "Người thân":
            GuiControl, , edtx10, % ctrlX
            GuiControl, , edty10, % ctrlY
    }
    Return

;Nhấn giữ ctrl
~*Ctrl::
    SetTimer, Update, Off
    Return

~*Ctrl up::
    SetTimer, Update, On
    Return

; fn_GetlistFile(path)
; {
; 	tmpAR := []
; 	path := path . "\*.*"
; 	tmpString := ""
; 	Loop, % path
; 	{
; 		tmpAR.push(A_LoopFileName)
; 	}
; 	Return, tmpAR
; }
ConvertARRtoString(arr)
{
	i := arr.Length()
	Loop, % i
	{
		_str .= arr[A_Index]
		If (A_Index <> i)
			_str .= "|"
	}
	Return, _str
}