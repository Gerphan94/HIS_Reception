#NoEnv
#NoTrayIcon
FileEncoding, utf-8

AHK_Title := "Danh mục"

Global gpConfig := A_ScriptDir . "\config.ini"
Global gnSelectedRow
Global gpDepartment, gaHISDepart

IniRead, nHISEnvID, % gpConfig, Section1, HISEnvID
 
Global gpEnv := A_ScriptDir . "\Env\"

global gaEnv := fn_GetlistFolder(gpEnv)
HISEnvName := gaEnv[nHISEnvID]

Gui, Font, BOLD s16 cMaroon
Gui, Add, Text,, % "Danh mục"
Gui, Font
Gui, Add, DropDownList, w120 choose%nHISEnvID% vddlEnv gddlEnv, % ConvertARRtoString(gaEnv)
Gui, Add, Tab3, section w400, % "Chung|Phòng khám"
Gui, Tab, 1
Gui, Add, Text, section, % "File chạy:"
Gui, Add, Edit, vedt1 ys w250 cMaroon disabled
Gui, Add, Button, x+10 w30
Gui, Add, Groupbox, xs w360 r4 cNavy, % "Tiêu đề HIS"
Gui, Add, Text, section xp+10 yp+25, % "TN thường:"
Gui, Add, Text,, % "TN Cấp cứu:"
Gui, Add, Text,, % "TN VP:"
Gui, Add, Edit, vedt2 ys w250 cMaroon
Gui, Add, Edit, vedt3 w250 cMaroon
Gui, Add, Edit, vedt4 w250 cMaroon
Gui, Add, Groupbox, xs-10 y+20 w360 r4 cNavy, % "User/Pass"
Gui, Add, Text, section xp+10 yp+25, % "TN Thường:"
Gui, Add, Text,, % "TN Cấp cứu:"
Gui, Add, Text,, % "TN Sản:"
Gui, Add, Edit, disabled section ys w70
Gui, Add, Edit, disabled x+10 w70
Gui, Add, Edit, disabled xs w70
Gui, Add, Edit, disabled x+10 w70
Gui, Add, Edit, disabled xs w70
Gui, Add, Edit, disabled x+10 w70
Gui, Add, Button, y+20 w50 h32 hidden, % "Hidden Button"
Gui, Add, Button, x+30 w50 h32, % "Lưu"
Gui, Add, Button, x+10 w50 h32, % "Đóng"

Gui, Tab
Gui, Tab, 2
Gui, Add, Listview, w360 r15 -Hdr -Multi cNavy vmyLISTVIEW gmyLISTVIEW +AltSubmit, % "STT|Tên"
    LV_ModifyCol(1, " 40 Center")
    LV_ModifyCol(2, " 250 Left")
Gui, Add, Text, section, % "Tên phòng: "
Gui, Add, Edit, ys w280 Disabled vedt5
Gui, Add, Button, section w70 h32 Disabled vbtnDel gbtnDel, % "Xóa"
Gui, Add, Button, section x+50 ys w70 h32 vbtnNew gbtnNew, % "Thêm mới"
Gui, Add, Button, ys w70 h32 Disabled vbtnSave gbtnSave, % "Lưu"
Gui, Tab

Gui, Add, StatusBar
Gui, Show,, % AHK_Title
SendMessage 0x1501, 1, "Search",, ahk_id %hEdt% ; EM_SETCUEBANNER
IfNotExist, % gpConfig
    SB_SetText(" File config không tồn tại")
initGUI(HISEnvName)
Return

GuiClose:
GuiEscape:
    ExitApp,

ddlenv:
    Gui, Submit, Nohide
    initGUI(ddlEnv)
    Return


initGUI(env) {
    runpath := A_ScriptDir . "\Env\" . env . "\HISRun"
    titlepath := A_ScriptDir . "\Env\" . env . "\HISTitle"
    gpDepartment := A_ScriptDir . "\Env\" . env . "\HISDepartment"
    aHISrun := fn_readFileOne(runpath)
    aHIStitle := fn_readFileOne(titlepath)
    Guicontrol,, edt1, % aHISrun[1]
    Guicontrol,, edt2, % aHIStitle[1]
    Guicontrol,, edt3, % aHIStitle[2]
    Guicontrol,, edt4, % aHIStitle[3]
	initLV()
	
    Return
}

initLV() {
	LV_Delete()
	gaHISDepart := fn_readFileOne(gpDepartment)
	For index, element in gaHISDepart
	{
		LV_Add("", index, element)
	}
}


myLISTVIEW:
	GuiControlGet, btn_name,, % "Button8"
	If ( btn_name = "Hủy")
		Return
	Gui, ListView, myLISTVIEW
    If (A_GuiEvent = "Normal") {
        gnSelectedRow := A_EventInfo
		GuiControl, enable, btnDel
    }
	Return

btnDel:
	If ( gnSelectedRow = 0)
	{
		Return
	}
	Else
	{
		LV_GetText(iVar, gnSelectedRow, 2)
		Msgbox, 36, % "Thông báo", % "Xóa`n" . iVar . "?"
		IfMsgBox, No
			Return
		DelFromFile(gnSelectedRow, gpDepartment)
		initLV()
		SB_SetText("Xóa thành công")
	}
	Return

btnNew:
	Gui, Submit, NoHide
	GuiControlGet, btn_name,, % A_GuiControl
	If ( btn_name = "Thêm mới")
	{
		GuiControl, Enable, edt5
		GuiControl, Focus, edt5
		GuiControl, Enable, btnSave
		GuiControl, Disable, btnDel
		GuiControl, , btnNew, % "Hủy"
	}
	Else
	{
		GuiControl, , edt5, % ""
		GuiControl, Disable, edt5
		GuiControl, Disable, btnSave
		GuiControl, , btnNew, % "Thêm mới"
	}
	Return

btnSave:
	Gui, Submit, NoHide
	If ( edt5 = "") {
		SB_SetText("Tên phòng không được để trống")
		Return
	}
	if (fn_isStringInArray(edt5, gaHISDepart)) {
		SB_SetText("Tên phòng đã tồn tại")
		Return
	}
	FileAppend, % edt5 . "`n", % gpDepartment
	initLV()
	GuiControl, , edt5, % ""
	GuiControl, Disable, edt5
	GuiControl, Disable, btnSave
	GuiControl, , btnNew, % "Thêm mới"
	SB_SetText("Thêm mới thành công")
	Return
; xóa dữ liệu trong file
DelFromFile(x, xpath) {
    Temppath = %A_ScriptDir%\tmp.Txt
    Loop, read, %xpath%, %Temppath%
    {
        If (A_Index = x)
            var := ""
        Else
            var := A_LoopReadLine
        If (var <> "")
            FileAppend, %var%`n
    }
    FileDelete, %xpath%
    FileMove, %Temppath%, %xpath%
    Return
}
;Lấy DS folder
fn_GetlistFolder(path)
{
	tmpAR := []
	path := path . "\*.*"
	tmpString := ""
	Loop, % path, 2
	{
		tmpAR.push(A_LoopFileName)
	}
	Return, tmpAR
}
;ConvertARRtoString
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
;Hàm đọc file và thêm vào mảng 1 giá trị
fn_readFileOne(path)
{
	tmpAR := []
	Loop,
	{
		i := A_Index
		FileReadLine, OutputVar, % path, % i
		If ErrorLevel
			Break
		tmpAR.Push(OutputVar)
	}
	Return, tmpAR
}
;Kiểm tra dữ liệu tồn tại trong mảng
fn_isStringInArray(string, array) {
	For index, element in array
	{
		If (element = string)
			Return, True
	}
	Return, False
}