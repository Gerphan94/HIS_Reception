#NoEnv
#NoTrayIcon
FileEncoding, utf-8

AHK_Title := "Cấu hình"

Global gnPKNhi, gnPKmacdinh
Global gaDepart
Global gpEnvironmentFolder := A_ScriptDir . "\Env"
Global gArrayEnv := fn_GetlistFolder(gpEnvironmentFolder)
Global gpConfig := A_ScriptDir . "\Config.ini"
IfNotExist, % gpConfig
{
	Msgbox, 16, % "Lỗi", % gpConfig . "`nkhông tồn tại"
	ExitApp,
}
Gui, Font, s14 cNavy BOLD, % AHK_font
Gui, Add, Text, , % "CẤU HÌNH"
Gui, Font
Gui, Add, Groupbox, r10 w280
Gui, Add, Text, section xp+10 yp+20, % "Môi trường: "
Gui, Add, Text,, % "Số BN/Gọi:"
Gui, Add, Text,, % "PK cho TE:"
Gui, Add, Text,, % "PK cho mặc định:"
Gui, Add, Text,, % "Đuôi Email:"
Gui, Add, Text,, % "Đầu thẻ:"
Gui, Add, Text,, % "Version HIS:"
Gui, Add, DropDownList, ys vddlEnv gddlENV w150, % ConvertARRtoString(gArrayEnv)
Gui, Add, DropDownList, w70 vddlSoBN, % "1|2|3|4|5|6|7"
Gui, Add, DropDownList, w150 vddlPKNhi,
Gui, Add, DropDownList, w150 vddlPKmacdinh,
Gui, Add, Edit, w150 vedtEmail,
Gui, Add, DropDownList, w70 vddlDauthe, % "1|2|3|4|5|1-5"
Gui, Add, Edit, w150 vedtVersion disabled,
Gui, Add, Button, section xp+90 y+35 w60 h32 gbtnSave, % "Lưu"
;Gui, Add, Button, ys w60 h32 gbtnSave, % "Lưu"
Gui, Add, StatusBar,,
Gui, Show,, % AHK_Title
INIT()
Return

btnClose:
GuiClose:
GuiEscape:
	ExitApp,

INIT() {
	IniRead, HISEnvID, % gpConfig, section1, HISEnvID
	IniRead, SoBN, % gpConfig, section1, SoBN
	IniRead, Email, % gpConfig, section1, Email
    IniRead, gnPKNHi, % gpConfig, section1, ChildrenDepartment
    IniRead, gnPKMacdinh, % gpConfig, section1, DefaultDepartment
    IniRead, Dauthe, % gpConfig, section1, Dauthe
    IniRead, Version, % gpConfig, section1, Version
	HISEnvName := gArrayEnv[HISEnvID]
    initLISTPhong(HISEnvName)
	GuiControl, choose,ddlEnv, % HISEnvID
	GuiControl, choose,ddlSoBN, % SoBN
    Guicontrol, , edtEmail, % Email
    Guicontrol, choose, ddlDauthe, % Dauthe
    Guicontrol,, edtVersion, % Version
	Return
}
ddlEnv:
    Gui, Submit, NoHide
    initLISTPhong(ddlEnv)
    Return

initLISTPhong(env) {
    GuiControl, , ddlPKnhi, % "|"
    GuiControl, , ddlPKmacdinh, % "|"
    path := A_ScriptDir . "\Env\" . env . "\HISDepartment"
    IfNotExist, % path
    {
        Msgbox, 16, % "Lỗi", % path . "`nkhông tồn tại"
        Return
    }
    gaDepart := fn_readFileOne(path)
    GuiControl, , ddlPKnhi, % "|" . ConvertARRtoString(gaDepart)
    GuiControl, , ddlPKmacdinh, % "|" . ConvertARRtoString(gaDepart)
    GuiControl, choose, ddlPKnhi, % gnPKNhi
    GuiControl, choose, ddlPKmacdinh, % gnPKMacdinh
    Return
}
btnSave:
	Gui, Submit, NoHide
    If ( ddlPKNhi = "" ) OR ( ddlPKmacdinh = "") OR (edtEmail = "") {
        SB_SetText("Dữ liệu không thể trống")
        Return
    }
    new_HISEnvID := fn_findStringInArray(ddlEnv,gArrayEnv)
    new_SoBN := ddlSoBN
    new_Email := Bodau(trim(edtEmail))
    new_PKNhi := fn_findStringInArray(ddlPKNhi, gaDepart)
    new_PKmacdinh := fn_findStringInArray(ddlPKmacdinh, gaDepart)
    If (ddldauthe = "1-5")
        new_dauthe := 0
    Else
        new_dauthe := ddldauthe
    IniWrite, % new_HISEnvID, % gpConfig, section1, HISEnvID
	IniWrite, % new_SoBN, % gpConfig, section1, SoBN
	IniWrite, % new_Email, % gpConfig, section1, Email
    IniWrite, % new_PKNhi, % gpConfig, section1, ChildrenDepartment
    IniWrite, % new_PKmacdinh, % gpConfig, section1, DefaultDepartment
    IniWrite, % new_dauthe, % gpConfig, section1, Dauthe
	SB_SetText("Lưu thành công")
	Return

;ConvertARRtoString
ConvertARRtoString(arr) {
	i := arr.Length()
	Loop, % i
	{
		_str .= arr[A_Index]
		If (A_Index <> i)
			_str .= "|"
	}
	Return, _str
}
fn_GetlistFolder(path) {
	tmpAR := []
	path := path . "\*.*"
	tmpString := ""
	Loop, % path, 2
	{
		tmpAR.push(A_LoopFileName)
	}
	Return, tmpAR
}
;Hàm đọc file và thêm vào mảng 1 giá trị
fn_readFileOne(path) {
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
fn_findStringInArray(string, array) {
    For index, element in array
    {
        If (string = element)
            Return, % index
    }
    return, 0
}
;Hàm bỏ dấu
Bodau(myString) {    
    N_String := ""    
    Loop, % StrLen(myString)    
    {        
        temp := SubStr(myString, A_Index, 1)        
        Switch Asc(temp)       
        {            
            Case 272:                
                N_String .= "d"            
            Case 272:                
                N_String .= "D"            
            Case 224, 225, 226, 227, 259, 7841, 7843, 7845, 7847, 7849, 7851, 7853, 7855, 7857, 7859, 7861, 7862:                
                N_String .= "a"            
            Case 192, 193, 194, 195, 258, 7840, 7842, 7844, 7846, 7848, 7850, 7852, 7854, 7856, 7858, 7860, 7862:                
                N_String .= "A"            
            Case 232, 233, 234, 7865, 7867, 7869, 7871, 7873, 7875, 7877, 7879:                
                N_String .= "e"            
            Case 200, 201, 202, 7864, 7866, 7868, 7870, 7872, 7874, 7876, 7878:                
                N_String .= "E"            
            Case 236, 237, 297, 7881, 7882:                
                N_String .= "i"            
            Case 204, 205, 296, 7880, 7882:                
                N_String .= "I"            
            Case 242, 243, 244, 245, 417, 7885, 7887, 7889, 7891, 7893, 7895, 7897, 7899, 7901, 7903, 7905, 7907:                
                N_String .= "o"            
            Case 210, 211, 212, 213, 416, 7884, 7886, 7888, 7890, 7892, 7894, 7896, 7898, 7900, 7902, 7904, 7906:                
                N_String .= "O"            
            Case 249, 250, 361, 432, 7909, 7911, 7913, 7915, 7917, 7919, 7921:                
                N_String .= "u"            
            Case 217, 218, 360, 431, 7908, 7910, 7912, 7914, 7916, 7918, 7920:                
                N_String .= "U"            
            Case 253, 7923, 7925, 7927, 7929:                
                N_String .= "y"            
            Case 221, 7922, 7924, 7926, 7928:                
                N_String .= "Y"
            Case 32:
                N_String .= " "         
            Default:                
                N_String .= temp        
        }    
    }    
    Return, N_String
}