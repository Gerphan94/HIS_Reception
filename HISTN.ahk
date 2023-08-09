#NoEnv
#NoTrayIcon
#SingleInstance Ignore
FileEncoding, UTF-8

global release_note := "
(
	
2.8.0:
- Refactor	
2.7.5:
- Fix lỗi nhập giấy chuyển tuyến (icd phụ)
2.7.4:
- Bổ sung tiếp nhận trả sau
2.7.3:
- Fix lỗi tiếp nhận có giấy chuyển tuyến
- Fix lỗi thẻ 5 năm
2.7.2:
- Fix bug không đóng được phiếu thu
)"
;AHK SETUP
GuiWidth := "w330"
Tabwidth := "w320"
AHK_tittle := "Tiếp nhận 2.8.0"
AHK_font := "Tahoma"
Global g_Resolution := A_ScreenWidth . "x" . A_ScreenHeight
If ( g_Resolution != "1366x768") AND ( g_Resolution != "1920x1080" )
{
	MsgBox, 48, % "Oop!",% "Lỗi độ phần giải màn hình`n1366x768 hoặc 1920x1080`nHiện tại: " . g_Resolution
	ExitApp
}

;FIle
exe := A_ScriptDir + "/Reception.exe"
;Tạo các biến đường dẫn mặc định
Global gpEnvironmentFolder := A_ScriptDir . "\Env"
; global path_DepartFolder := A_ScriptDir . "\data\Depart"
Global path_Config := A_ScriptDir . "\config.ini"
global path_PosConfig := A_ScriptDir . "\CONFIG\POS.ini"
Global path_Company := A_ScriptDir . "\data\Company"
Global path_addressName := A_ScriptDir . "\data\Address"
Global path_dichvu := A_ScriptDir . "\Env\"
Global gpPOSFile := A_ScriptDir . "\POS"

IfNotExist, % gpEnvironmentFolder
{
	MsgBox, 48, % "Oop!",% "File " . gpEnvironmentFolder . " không tồn tại"
	ExitApp
}
IfNotExist, % path_Config
{
	MsgBox, 48, % "Oop!",% "File " . path_Config . " không tồn tại"
	ExitApp
}
;Khởi tạo biến array
Global garr_PersonType := ["Child", "Pupil", "Student", "Old", "Other"]
Global gArrayDT1 := ["Thu phí", "BHYT","BHYT-GCT"]
Global gArrayDT2 := ["Thu phí", "BHYT (TE1)", "BHYT(GCT)", "BHYT(Thẻ tạm)"]

global arr_addcode := ["HCTDTB","DIBHTD","DILKXU","DILKPB","DILKBV","DILKXL","DILKBS","DILKBV"]

global arr_Person := ["Bình thường","","2","3","4","5"]
global garr_GenderSuggest := ["Thị", "Văn"]

Global gArrayDepart, gaPOS, gUX
Global gArrayLoginRoomNormal, gArrayLoginRoomEmergency, gArrayLoginRoomReproduction
Global gArrayEnv := fn_GetlistFolder(gpEnvironmentFolder)
Global gArrayAddressName := fn_readFileOne(path_addressName)
Global gArrayCompany := fn_GetArrayOfCompany()
;KHỞI TẠO BIẾN 
;Các biến file config
Global gnPKNhi, gnPKmacdinh, SoBNcallQMS, g_DepartGID, gsEmail, g_PKNhi, gisCheckLGR, gnBHYTHead, gnisSDT, gnHanThe
Global EXEFILE
Global g_MaBV := "75009", gsHISver , g_HISEnvID , g_HISEnv
Global gArrayHISexe
global g_nWait := 8
global g_Now
FormatTime, g_Now,, % "dd/MM/yyyy"
global g_SuggessGender_arr := ["Thị", "Văn"]

Global gTITLE_TN, gTITLE_CC, gTITLE_TNVP ;các biến tiêu đề HIS

Global g_fDSBN_Title := "[PM001] DANH SÁCH BỆNH NHÂN"
Global g_fBHYT_Title := "THÔNG TIN THẺ BHYT"

gisCheckLGR := False
;Khởi tạo data
INIT()
;GUI
if FileExist(A_ScriptDir + "\Reception.exe")
	Menu, Tray, icon, % A_ScriptDir . "\Reception.exe"
Menu, FileMenu, Add,
Menu, FileMenu, Add, % "Mở TN Thường", OpenTNThuong
Menu, FileMenu, Add, % "Reload (F12)", Reload
Menu, FileMenu, Add,

Menu, FileMenu, Add,
Menu, FileMenu, Add, % "Exit", MenuExit
Menu, OptionMenu, Add, % "Xem Log", Log
Menu, OptionMenu, Add, % "Danh mục" , Catelogy
Menu, OptionMenu, Add, % "POS", POSManager
Menu, OptionMenu, Add,

	global arr_Dauthe_Menu := ["All","1","2","3","4","5"]
	global arr_GCT_Menu := ["All", "Nội tỉnh", "Ngoại tỉnh"]
	global arr_Hanthe_Menu := ["Từ ngày < " . g_Now . " < Đến ngày", "Từ ngày = " . g_Now, "Đến ngày = " . g_Now]

	Menu, Dauthe_Menu, Add, % arr_Dauthe_Menu[1], CardHead
	Menu, Dauthe_Menu, Add, % arr_Dauthe_Menu[2], CardHead
	Menu, Dauthe_Menu, Add, % arr_Dauthe_Menu[3], CardHead
	Menu, Dauthe_Menu, Add, % arr_Dauthe_Menu[4], CardHead
	Menu, Dauthe_Menu, Add, % arr_Dauthe_Menu[5], CardHead
	Menu, Dauthe_Menu, Add, % arr_Dauthe_Menu[6], CardHead

	Menu, GCT_Menu, Add, % arr_GCT_Menu[1], GCT
	Menu, GCT_Menu, Add, % arr_GCT_Menu[2], GCT
	Menu, GCT_Menu, Add, % arr_GCT_Menu[3], GCT

	Menu, Hanthe_Menu, Add,% arr_Hanthe_Menu[1], Hanthe
	Menu, Hanthe_Menu, Add,% arr_Hanthe_Menu[2], Hanthe
	Menu, Hanthe_Menu, Add,% arr_Hanthe_Menu[3], Hanthe

	Menu, BHYT_Menu, Add, % "Đầu thẻ", :Dauthe_Menu
	Menu, BHYT_Menu, Add, % "GCT", :GCT_Menu
	Menu, BHYT_Menu, Add, % "Hạn thẻ", :Hanthe_Menu

Menu, OptionMenu, Add, % "BHYT", :BHYT_Menu
	;PERSON MENU
	Menu, NhomTuoi_Menu, Add, % "All", Nhomtuoi
	Menu, NhomTuoi_Menu, Add, % "Trẻ em", Nhomtuoi
	Menu, NhomTuoi_Menu, Add, % "Học sinh", Nhomtuoi
	Menu, NhomTuoi_Menu, Add, % "Sinh viên", Nhomtuoi
	Menu, NhomTuoi_Menu, Add, % "Trung niên", Nhomtuoi
	Menu, NhomTuoi_Menu, Add, % "Lão", Nhomtuoi

	
	Menu, Person_Menu, Add, % "Nhóm tuổi", :NhomTuoi_Menu
Menu, OptionMenu, Add, % "Bệnh nhân", :Person_Menu
	

; Menu, OptionMenu, Add, % "Config", Config
Menu, Tool, Add, % "QRCode", QRCode

Menu, Info, Add, % "Gõ tắt", Acronym
Menu, Info, Add, % "Release Note", VerRelease
Menu, Info, Add, % "Đầu thẻ", InfoDauthe
Menu, Config, Add, % "Config", Config

Menu, Env, Add, % ""

Menu, MyMenuBar, Add, &File, :FileMenu

Menu, MyMenuBar, Add, &Option, :OptionMenu
Menu, MyMenuBar, Add, &Tools, :Tool
; Menu, MyMenuBar, Add, &Env, :Env
Menu, MyMenuBar, Add, % "Config", Config
Menu, MyMenuBar, Add, &Info, :Info

Gui, 1: Menu, MyMenuBar

Gui, 1:Font, s12 BOLD c000080 
Gui, 1:Add, Tab3, x10 %Tabwidth% vmyTAB ,% "Tiếp nhận|.|KB"
Gui, 1:Font
Gui, 1:Tab, 1
Gui, 1:Font, s10 normal, % AHK_font
Gui, 1:Add, Text, x20 y60 w120 h23 +0x200, % "Loại TN:"
Gui, 1:Add, Text, x200 y60 h23 +0x200, % "Số BN:"
Gui, 1:Add, Text, x20 y90 w120 h23 +0x200, % "Bệnh nhân:"
Gui, 1:Add, Text, x200 y90 h23 +0x200, % "Phái:"
Gui, 1:Add, Text, x20 y120 w120 h23 +0x200, % "Phòng khám:"
Gui, 1:Add, Text, x20 y150 w120 h23 +0x200, % "Đối tượng:"
Gui, 1:Add, DropDownList, x100 y60 w90 vddlLoaiTN gddlLoaiTN, % "Thường||Cấp cứu|Dịch vụ|Sản phụ"
Gui, 1:Add, DropDownList, x255 y60 w50 vddlSoBN choose4, % "1|2|3|4|5|10|20|30|40"
Gui, 1:Add, DropDownList, x100 y90 w90 vddlBenhnhan gddlBenhnhan choose1, % "||Trẻ em|Lão"
Gui, 1:Add, DropDownList, x255 y90 w50 vddlGT, % "||Nam|Nữ"
Gui, 1:Add, DropDownList, x100 y120 w205 vddlPhongkham, % ConvertARRtoString(fn_readFileOne(path_DEPART . "\Normal_area"))
Gui, 1:Add, DropDownList, x100 y150 w90 vddlDoituong gddlDoituong choose2, % ConvertARRtoString(gArrayDT1)
Gui, 1:Add, Text, x200 y150 w120 h23 +0x200 , % "Đầu thẻ:"
Gui, 1:Add, DropDownList, x255 y150 w50 choose4 vddlDauthe, % "1|2|3|4|5"

;Gui, 1:Add, DropDownList, x200 y150 w105 vddlTuyen, % "Đúng tuyến||Thông tuyến|Chuyển tuyến"
Gui, 1:Font, s10
Gui, 1:Add, Text, x100 y190 w195 h2 w190 +0x10
Gui, 1:Add, Checkbox, x100 y200 h23 vcbBHYT5nam, % "BHYT 5 năm"
Gui, 1:Add, CheckBox, x100 y225 h23 vcbMuaSKB Disabled, % "Mua sổ KB"
Gui, 1:Add, CheckBox, x220 y225 h23 vcbBNUuTien, % "Ưu tiên"
Gui, 1:Add, CheckBox, x100 y250 w70 h23 vcbDST, % "DST"
Gui, 1:Add, CheckBox, x220 y250 w150 h23 vTNcddv disabled, % "Chỉ định DV"
Gui, 1:Add, Checkbox, x100 y275 vcbThutien, % "Thu tiền"
Gui, 1:Add, Checkbox, x220 y275 vcbTrasau disabled, % "Trả sau"
Gui, 1:Tab
Gui, 1:Tab, 2
Gui, 1: Font, s9
Gui, 1:Add, Groupbox,w290 r4 cGray, % "Thông tin hành chính"
Gui, 1:Add, Checkbox, section xp+20 yp+30 vcbFull gcbFull, % "Full"
Gui, 1:Add, Checkbox, ys vcbESC, % "Email, SĐT, Công ty"
Gui, 1:Add, Checkbox, vcbCMND, % "CMND"
Gui, 1:Add, Checkbox, vcbNguoithan, % "Người thân"
Gui, 1:Add, Groupbox, xm+12 y+30 w290 r2 cGray, % "Đầu thẻ"
Gui, 1:Add, Radio,  section xp+10 yp+30 vradio0 , % "1-5"
Gui, 1:Add, Radio,  section ys vradio1 , % "1"
Gui, 1:Add, Radio,  section ys vradio2 , % "2"
Gui, 1:Add, Radio,  section ys vradio3 , % "3"
Gui, 1:Add, Radio,  section ys vradio4 , % "4"
Gui, 1:Add, Radio,  ys vradio5 , % "5"
Gui, 1:Font
Gui, 1:Tab

Gui, 1:Tab, 3
Gui, 1:Font, s10
Gui, 1:Add, Text, x20 y60 w120 h23 +0x200, % "Loại NV:"
Gui, 1:Add, DropDownList, x150 y60 w100, % "Nội trú||Ngoại trú"
Gui, 1:Add, Text, x20 y90 w120 h23 +0x200, % "Khoa nhập viện"
Gui, 1:Add, DropDownList, x150 y90 w150 vddlKhoaNV, % "Liên chuyên khoa||"
Gui, 1:Add, Checkbox, x20 y120 vcbCDDV, % "Chỉ định dịch vụ"

Gui, 1:Tab

Gui, 1:Add, Groupbox, x10 y308 h55 w320
Gui, 1:Add, Button, x250 y325 w60 h32 vbtnRunTN gbtnRunTN, % "Bắt đầu"
Gui, 1:Font, s8
Gui, 1:Add, StatusBar,,
SB_SetParts(160,60,60)
Gui, 1:Font
Gui, 1:Show, , %AHK_tittle%
Gui, 1:Submit, Nohide
;msgbox, % g_arrPK.Length()
initGUI()
;initSOBNTN(SoBNcallQMS)
SetTimer, RefreshTime, 1000
;Gán Control của GUI
ctrl_BHYT5Nam := "Button1"
ctrl_MuaSKB := "Button2"
ctrl_BNUT := "Button3"
ctrl_DST := "Button4"
ctrl_CDDV := "Button5"
ctrl_Thutien := "Button6"
ctrl_Trasau := "Button7"

ctrl_Full := "Button8"
ctrl_ESC := "Button9"
ctrl_CMND := "Button10"
ctrl_Nguoithan := "Button11"
Return
;Kết thúc GUI
MenuExit:
GuiEscape:
GuiClose:
    ExitApp

::=v::
	Return

::=hd::
	FormatTime, Out1,, yyyy.MM.dd-HH.mm
	hd_str := "HĐ-" . Out1
	Send {Text}%hd_str%
	Send, {Tab}
	FormatTime, Out2, , ddMMyyyy
	send % Out2
	Return

::=thau::
	year := A_Year
	month := A_Mon
	random, R1, 1, 1000
	thau_str := year . "." . month . "." . R1 . "/TB_BV"
	sqd_str := "SQD.2022."
	random, r_num,1, 1000
	sqd_str := sqd_str . r_num

	from := "01122022"
	to := "31122023"

	send % thau_str
	send {Tab}
	send % sqd_str
	send {Tab}
	send % from
	send {Tab}
	send % to
	send {tab}{tab}
	dien_giai := "Thầu số " . R1 " tháng " . month . " năm " . year
	send {Text}%dien_giai%

	return

::=lo::
	today := A_MM
	i_string := "LO.IDOEM." . today . "."
	random, r_num,1, 1000
	i_string := i_string . r_num
	send % i_string
	send {tab}
	hsd := RandomDate("2024/01/01","2030/12/31", "ddMMyyyy")
	send % hsd
	return

::=kb::
	kham_tt_kham()
	Return

::=dvnt::
	chidinh_dv()
	Return
	
F12::
	MsgBox, 48, Warning!, Dừng Script
Reload:
	Reload
	Return
; Khởi tạo Data từ file

INIT()
{
	IniRead, g_HISEnvID, % path_Config, section1, HISEnvID
	
	g_HISEnv := gArrayEnv[g_HISEnvID]
	path_ENV := A_ScriptDir . "\env\" . g_HISEnv
	path_HISRUN :=  path_ENV . "\HISRun"
	path_HISTITLE := path_ENV . "\HISTitle"
	path_USER := path_ENV . "\HISUser"
	global path_DEPART := path_ENV . "\Department"
	global path_SERVICE := path_ENV . "\HISService"
	path_WorkTNT := path_ENV . "\HISWorkTNT"
	path_WorkTNCC := path_ENV . "\HISWorkTNCC"
	path_WorkTNSan := path_ENV . "\HISWorkTNSan"
	IfNotExist, % path_HISTITLE
	{
		Msgbox, 16, % "OOP!", % "Không thấy file`n" . path_HISTITLE
		ExitApp
	}
	IfNotExist, % path_USER
	{
		Msgbox, 16, % "OOP!", % "Không thấy file`n" . path_USER
		ExitApp
	}

	IniRead, gUX, % path_Config, section1, UX
	;Khởi tạo biến đuối mail
	IniRead, gsEmail, % path_Config, section1, Email
	;KHởi tạo biến EXE
	gArrayHISexe := fn_readFileOne(path_HISRUN)
	;KhởI tại biến tiêu đề his
	gTITLE_TN := fn_readFileOne(path_HISTITLE)[1]
	gTITLE_CC := fn_readFileOne(path_HISTITLE)[2]
	gTITLE_TNVP := fn_readFileOne(path_HISTITLE)[3]
	;Khởi tạo biến userpass
	Loop,
	{
		FileReadLine, OutputVar, % userpath, A_Index
		If ErrorLevel
			Break
		Loop, Parse, OutputVar, CSV
		{
			If (A_index = 1)
				str1 := A_LoopField
			Else
				str2 := A_LoopField
		}
		g_arUserPass.Push({1:str1,2:str2})
	}
	global g_userThuong := g_arUserPass[1][1]
	global g_passThuong := g_arUserPass[1][2]
	global g_userCC := g_arUserPass[2][1]
	global g_passCC := g_arUserPass[2][2]
	global g_userSan := g_arUserPass[3][1]
	global g_passSan := g_arUserPass[3][2]
	;khởi tạo mảng màn hình làm việc
	gArrayLoginRoomNormal := fn_readFileOne(gpEnvironmentFolder . "\" . g_HISEnv . "\" . HISLoginNormal)
	gArrayLoginRoomEmergency := fn_readFileOne(gpEnvironmentFolder . "\" . g_HISEnv . "\" . HISLoginEmergency)
	gArrayLoginRoomReproduction := fn_readFileOne(gpEnvironmentFolder . "\" . g_HISEnv . "\" . HISLoginReproduction)
	;Khởi tạo mảng DS phòng khám
	gArrayDepart := fn_readFileOne(path_DEPART)
	Return
}


check_Menu()
{
	; Check Đầu thẻ Menu
	Dauthe_l := arr_Dauthe_Menu.Length()
	IniRead, Dauthe, % path_Config, section1, Dauthe
	Loop, % Dauthe_l
		{
			Menu, Dauthe_Menu, UnCheck, % arr_Dauthe_Menu[A_Index]
		}
	Menu, Dauthe_Menu, Check, % arr_Dauthe_Menu[Dauthe + 1]
	;Check GCT
	Gct_l := arr_GCT_Menu.Length()
	IniRead, iGCT, % path_Config, section1, GCT
	Loop, % Gct_l
		{
			Menu, GCT_Menu, UnCheck, % arr_GCT_Menu[A_Index]
		}
	Menu, GCT_Menu, Check, % arr_GCT_Menu[iGCT + 1]
	
	; CHeck Hanthe
	Hanthe_l := arr_Hanthe_Menu.Length()
	IniRead, gnHanthe, % path_Config, section1, Hanthe
	Loop, % Hanthe_l
		{
			Menu, Hanthe_Menu, UnCheck, % arr_Hanthe_Menu[A_Index]
		}
	Menu, Hanthe_Menu, Check, % arr_Hanthe_Menu[gnHanthe]


	Return
}

initGUI()
{
	;Đầu thẻ mặc định
	IniRead, Dauthe, % path_Config, section1, Dauthe
	Guicontrol,, % "radio" . dauthe, 1
	check_Menu()
	;Số BN
	IniRead, SoBNcallQMS, % path_Config, section1, SoBN
	ds = 1
	Loop, 10 {
		ds .= "|"
		ds .= A_Index * SoBNcallQMS
	}
	; Guicontrol,, ddlSoBN, : "|" .ds
	; GuiControl, choose, ddlSoBN, 2
	; Phòng khám mặc định
	IniRead, gnPKmacdinh, % path_Config, section1, DefaultDepartment
	
	GuiControl, choose, ddlPhongkham, % gnPKmacdinh
	;Phòng khám nhi
	IniRead, gnPKNhi, % path_Config, section1, ChildrenDepartment
	;Khởi tạo Statusbar
	IniRead, gsHISver, % path_Config, section1, version
	SB_SetText(" " . gsHISver, 1)
	SB_SetText(gArrayEnv[g_HISEnvID], 2)
	SB_SetText(A_ScreenWidth . "x" . A_ScreenHeight, 3)
	SB_SetText(a_hour . ":" . a_min . ":" . a_sec, 4)
	Return
}

; INITPOS() {
; 	If (g_Resolution = "1366x768")
; 		path := A_ScriptDir . "\POS\1366x768"
; 	Else
; 		path := A_ScriptDir . "\POS\1920x1080"
; 	gaPOS := fn_readFileTwo(path) 
; 	Return
; }

;Mở tiếp nhận thường
OpenTNThuong:
	Msgbox,, % "Thông báo", % "Chức năng đang xây dựng"
	Return

;Mở chức năng QLDM
Catelogy:
	IfWinExist, % "Danh mục"
		WinActivate,
	Else
	{
		tmpPath := A_ScriptDir . "\Catelogy.exe"
		IfNotExist, % tmpPath
			Msgbox, 16, % "Lỗi", % tmpPath . "`nkhông tồn tại!"
		Else
			Run, % tmpPath
	}
	Return
;Mở chức năng quản lý POS
POSManager:
	IfWinExist, % "POSition"
		WinActivate
	Else
	{
		path_POS := A_ScriptDir . "\POS.exe"
		IfNotExist, % path_POS
			Msgbox, 16, % "Lỗi", % path_POS . "`nkhông  tồn tại"
		Else
			Run, % path_POS
	}
	Return

;Gui 4
Config:
	IfWinExist, % "Cấu hình"
		WinActivate
	Else
	{
		path := A_ScriptDir . "\Config.exe"
		IfNotExist, % path
			Msgbox, 16, % "Lỗi", % path . "`nkhông  tồn tại"
		Else
			Run, % path
	}
	Return

CardHead:
	If (A_ThisMenuItem = "All")
		inumber := 0
	Else
		inumber := A_ThisMenuItem
	if (inumber = "")
		IniWrite, 0, % path_Config, section1, Dauthe
	else
		IniWrite, % inumber, % path_Config, section1, Dauthe
	check_Menu()
	Return


GCT:
	If (A_ThisMenuItem = "All")
		inumber := 0

	Else if (A_ThisMenuItem = "Nội tỉnh")
		inumber := 1
	Else
		inumber := 2
	IniWrite, % inumber, % path_Config, section1, GCT
	check_Menu()
	Return

Hanthe:
	IniWrite, % A_ThisMenuItemPos, % path_Config, section1, hanthe
	check_Menu()
	Return

Nhomtuoi:
	Return
	
QRCode:
	file := A_ScriptDir . "\QRcode Creater.exe"
	IfNotExist, % file
	{
		Msgbox, % "Lỗi "
		Return
	}
	If WinExist("QRCode Creater")
		WinActivate,
	Else
		Run, % file
	Return

VerRelease:
	Msgbox,, % "Release Info", % release_note
	Return

InfoDauthe:

	path_dauthe := A_ScriptDir . "\data\dauthe"
	IfNotExist, % path_dauthe
		Return
	Loop, 
	{
		FileReadLine, OutputVar, % path_dauthe, % A_Index
		if ErrorLevel
			{
				Break
			}
		msgtext .=  OutputVar . "`n"
	}
	Msgbox,, % "Đầu thẻ", % msgtext 
	
	Return


Acronym:
	file := A_ScriptDir . "\Info.exe"
	IfNotExist, % file
	{
		Msgbox, % "Lỗi "
		Return
	}
	If WinExist("QRCode Creater")
		WinActivate,
	Else
		Run, % file
	Return
	
;Vào chức năng xem log
;/////////////////////////////////////////////////////////////////////////
LOG:
	file := A_ScriptDir . "\ViewLog.exe"
	IfNotExist, % file
	{
		Msgbox, 16, % "Lỗi", % file . "`nkhông tồn tại!"
		Return
	}
	If WinExist("LOG")
		WinActivate,
	Else
		Run, % file
	Return
;;
;KẾT THÚC XỬ LÝ GUI
;CLOCKTIME
RefreshTime:
	iTime := a_hour . ":" . a_min . ":" . a_sec
    SB_SetText(iTime, 4)
    Return

;Xử lý kho chọn Dropdownlist bệnh nhân
ddlBenhnhan:
	Gui, 1:Submit, NoHide
	If (ddlBenhnhan = "Trẻ em")
	{
		Control, Check,, % ctrl_Nguoithan
		Control, UnCheck,, % ctrl_Full
		Control, UnCheck,, % ctrl_CMND
		Control, UnCheck,, % ctrl_ESC
		GuiControl, Disable ,cbFull
		GuiControl, Disable ,% ctrl_CMND
		GuiControl, Disable ,% ctrl_ESC
		GuiControl, Disable ,% ctrl_Nguoithan
		GuiControl, , ddlDoituong, % "|" . ConvertARRtoString(gArrayDT2)
		GuiControl, Choose, ddlDoituong, 2
		Guicontrol, Choose, % ddlTuyen, 1
		Guicontrol, disable, ddlTuyen
		Guicontrol, choose, ddlPhongKham, % gnPKNhi
	}
	Else {
		Control, UnCheck,, % ctrl_Nguoithan
		GuiControl, Enable ,cbFull
		GuiControl, Enable ,% ctrl_CMND
		GuiControl, Enable ,% ctrl_ESC
		GuiControl, Enable ,% ctrl_Nguoithan
		GuiControl, Choose, ddlPhongKham, % gnPKmacdinh
		GuiControl, , ddlDoituong, % "|" . ConvertARRtoString(gArrayDT1)
		GuiControl, Choose, ddlDoituong, 2
		Guicontrol, Choose, % ddlTuyen, 1
		Guicontrol, Enable, ddlTuyen
	}
	Return
;Xử lý kho chọn Dropdownlist Đối tượng
ddlDoituong:
	Gui, 1:Submit, NoHide
	Switch % ddlDoituong
	{
		Case "Thu phí":
			Control, Uncheck,, % ctrl_BHYT5Nam
			GuiControl, disable, % ctrl_BHYT5Nam
			GuiControl, enable, % ctrl_Thutien
			Guicontrol, disable, ddlTuyen
			Guicontrol, enable, cbTrasau
			Control, check,, % ctrl_Thutien

		Case "Thẻ tạm":
			Control, Uncheck,, % cbBHYT5nam
			Guicontrol, Choose, % ddlTuyen, 1
			Guicontrol, disable, ddlTuyen
			Control, Uncheck,, % ctrl_Thutien
		Case "BHYT":
			Guicontrol, Enable, ddlTuyen
			Control, Uncheck, ,% ctrl_Thutien
			GuiControl, enable, % ctrl_BHYT5Nam
			Guicontrol, disable, cbTrasau
			Control, Uncheck,, % ctrl_Trasau
		
		Case "BHYT (TE1)":
			Guicontrol, Choose, % ddlTuyen, 1
			Guicontrol, disable, ddlTuyen
			Control, Uncheck, ,% ctrl_Thutien
			Guicontrol, disable, cbTrasau
			Control, Uncheck,, % ctrl_Trasau
	}
	return

ddlLoaiTN:
	Gui, 1:Submit, NoHide
	Switch ddlLoaiTN
	{
		Case "Thường":
			Guicontrol, Choose, ddlGT, 1
			Guicontrol, Enable, ddlGT
			GuiControl, Disable, cbMuaSKB
			GuiControl, , ddlDoituong, % "|" . ConvertARRtoString(gArrayDT1)
			global gArrayDepart := fn_readFileOne(path_DEPART . "\Normal_area")	

			
		Case "Cấp cứu":
			Guicontrol, Choose, ddlGT, 1
			Guicontrol, Enable, ddlGT
			GuiControl, Disable, cbMuaSKB
			global gArrayDepart := fn_readFileOne(path_DEPART . "\Emergency_area")
		
		Case "Dịch vụ":
			GuiControl, Enable, cbMuaSKB
			Guicontrol, Choose, ddlGT, 1
			Guicontrol, Enable, ddlGT
			global gArrayDepart := fn_readFileOne(path_DEPART . "\Service_area")
			
		Case "Sản phụ":
			Guicontrol, Choose, ddlGT, 3
			Guicontrol, disable, ddlGT
			GuiControl, Disable, cbMuaSKB
			global gArrayDepart := fn_readFileOne(path_DEPART . "\Obstetric_area")
			
	}
	GuiControl, , ddlPhongkham, % "|" . ConvertARRtoString(gArrayDepart)
	GuiControl, Choose, ddlPhongkham, 1
	GuiControl, choose, ddlDoituong, 2
	Return

cbFull:
	Gui, 1:Submit, NoHide
	If (cbFull) {
		Control, Check,, % ctrl_ESC
		Control, Check,, % ctrl_CMND
		Control, Check,, % ctrl_Nguoithan
	}
	Else {
		Control, UnCheck,, % ctrl_ESC
		Control, UnCheck,, % ctrl_CMND
		Control, UnCheck,, % ctrl_Nguoithan
	}
	Return

initSOBNTN(n) {
	ds = 1
	Loop, 10
	{
		ds .= "|"
		ds .= A_Index*n
	}
	Guicontrol,, ddlSoBN, |%ds%
	GuiControl, choose, ddlSoBN, 2
	Return
}
;RUN/////////////////////
btnRunTN:
	Gui, 1:Submit, NoHide
	TimeGetPatient=NONE
	;Kiểm tra Màn hình tiếp nhận đã mở hay chưa?
	If (ddlLoaiTN = "Cấp cứu") {
		IfWinNotExist,	% gTITLE_CC
		{
			MsgBox,48, % "Oop!",% "Chưa mở `n" . gTITLE_CC
			Return
		}
		TITLE_TIEPNHAN := gTITLE_CC
	}
	Else {
		IfWinNotExist, % gTITLE_TN
		{
			MsgBox, 48, % "Oop!",% "Chưa mở `n" . gTITLE_TN
			Return
		}
		TITLE_TIEPNHAN := gTITLE_TN
	}
	WinMinimize, % AHK_tittle
	Sleep 300
	;Kiểm tra quầy tiếp nhận
	WinActivate, % TITLE_TIEPNHAN
	Sleep 100
	;Khởi tạo các control trong form thông tin BN
	ClassNN_Email := ""
	HISctrl_CNMD := ""
	ClassNN_Nguoithan := ""
	;Lấy COntrol của Tên phòng và mã BN
	IniRead, xyPhongKham, % path_PosConfig, % g_Resolution, xyPhongKham
	IniRead, xy5Nam, % path_PosConfig, % g_Resolution, xy5Nam
	IniRead, xyTheTam, % path_PosConfig, % g_Resolution, xyTheTam
	IniRead, xyBNUT, % path_PosConfig, % g_Resolution, xyBNUT
	IniRead, xyGCT, % path_PosConfig, % g_Resolution, xyGCT
	IniRead, xyHuongDTuyen, % path_PosConfig, % g_Resolution, xyHuongDTuyen
	IniRead, xySoKhamBenh, % path_PosConfig, % g_Resolution, xySoKhamBenh

	WinGet, ilist, ControlList, % ITLE_TIEPNHAN
	HISctrl_Thutien := ""
		iCheck := 0
		Loop, Parse, ilist, `n`r
		{
			ControlGetText, OutputVar, %A_LoopField%, % TITLE_TIEPNHAN
			ControlGetPos, x, y, , , %A_LoopField%, % TITLE_TIEPNHAN
			xy := x . "," . y
			Switch % OutputVar
			{
				; GET BTN GỌI
				Case "Gọi":
					HISctrl_Goiso := A_LoopField
					If (HISctrl_Goiso = "")
						{
							Msgbox, 48, % "Lỗi", % "Can't Get btn [Gọi]"
							Return
						}
					Continue
				; GET BTN LƯU
				Case "Lưu":
					HISctrl_Luu := A_LoopField
					If (HISctrl_Luu = "")
						{
							Msgbox, 48, % "Lỗi", % "Can't Get btn [Lưu]"
							Return
						}
					Continue
				
				Case "Nhập mới":
					HISctrl_Nhapmoi := A_LoopField
					If (HISctrl_Nhapmoi = "")
						{
							Msgbox, 48, % "Lỗi", % "Can't Get btn [Lưu]"
							Return
						}
					Continue

				Case "Nhập sinh hiệu":
					HISctrl_Nhapsinhhieu := A_LoopField
					If (HISctrl_Nhapsinhhieu = "")
						{
							Msgbox, 48, % "Lỗi", % "Can't Get btn [Nhập sinh hiệu]"
							Return
						}
					Continue
				
				Case "Thu tiền (F4)":
					HISctrl_Thutien := A_LoopField
					If (HISctrl_Thutien = "")
						{
							Msgbox, 48, % "Lỗi", % "Can't Get btn [Thu tiền (F4)]"
							Return
						}
					Continue
				
				Case "Chuyển tuyến":
					ClassNN_GCT := A_LoopField
					If (ClassNN_GCT = "")
						{
							Msgbox, 48, % "Lỗi", % "Can't Get btn [Chuyển tuyến]"
							Return
						}
					Continue
			}
			Switch % xy
			{
				
				Case % xyPhongKham:
					ClassNN_PK := A_LoopField
					Continue
				Case xy5Nam:
					ClassNN_cb5nam := A_LoopField
					Continue
				Case xyTheTam:
					ClassNN_TheTam := A_LoopField
					Continue
				Case xyBNUT:
					ClassNN_BNUT := A_LoopField
					Continue
				Case xyHuongDTuyen:
					ClassNN_HuongDT := A_LoopField
					Continue
				Case xySoKhamBenh:
					ClassNN_SKB := A_LoopField
					Continue
			
			}
		}

	;Kiểm tả version HIS và ver trên TOOL
	;Nếu giống nhau thì bỏ qua
	;Nếu khác nhau thì lưu ver HIS hiện tại lại
	ControlGetText, version, % ClassNN_version, % TITLE_TIEPNHAN
	;Msgbox, % version . "-" . gsHisVer
	If (gsHisVer != version) {
		IniWrite, % version, %path_Config%, section1, version
		SB_SetText(version, 1)
	}
	If gisCheckLGR {		
		ControlGetText, tenphong, % ClassNN_tenphong, % TITLE_TIEPNHAN
		If (tenphong = "") {
			Msgbox, 16, % "Lỗi", % "Kiểm tra lại tên phòng làm việc.`nKhông lấy được tên phòng"
			Return
		}
		Switch ddlLoaiTN
		{
			Case "Thường":
				If (NOT TN_thuong[tenphong]) {
					Msgbox, 16, % "Oop!", % "Cần vào phòng tiếp nhận thường, thử lại!"
					WinActivate, % AHK_tittle
					Return
				}
			Case "Cấp cứu":
				If (NOT TN_capcuu[tenphong]) {
					Msgbox, 16, % "Oop!", % "Cần vào phòng tiếp nhận CC, thử lại!"
					WinActivate, % AHK_tittle
					Return
				}
			Case "Sản phụ":
				If (NOT TN_khoasan[tenphong]) {
					Msgbox, 16, % "Oop!", % "Cần vào phòng tiếp nhận khoa sản, thử lại!"
					WinActivate, % AHK_tittle
					Return
				}
		}
	}
	;Kiểm tra có button Thu tiền khi sử dụng chức năng thu tiền hay không
	If ( cbThutien ) AND ( HISctrl_Thutien = "" ) {
		Msgbox, 16, % "Lỗi", % "User không có quyền thu tiền, `nthử lại"
		WinActivate, % AHK_tittle
		Return
	}
	;Bắt đầu:
	;Thời gian bắt đầu chạy Script

	Script_start := A_TickCount
	;Chọn phòng khám, (tiếp nhận cấp cứu sẽ không chọn)
	;Get mã Phòng

	If (TITLE_TIEPNHAN = gTITLE_TN) {
		Sleep 300
		ControlClick, %ClassNN_PK%, %TITLE_TIEPNHAN%
		Sleep 200
		Send {text}%ddlPhongkham%
		Sleep 200
		Send {Enter}
		sleep 200
	}
	icount = 0
	SoBN := ddlSoBN
	Loop, %SoBN% {
		Clipboard := ""
		;Code gọi click gọi số
		;Kiểm tra Button Gọi số có Enable hay không
		;Nếu Enable -> Click, Disable thì không click
		;/////////////////////////////////////////////////////////////////
		; ControlGet, gbGoiso, Enabled,, % HISctrl_Goiso, % TITLE_TIEPNHAN
		; If ( gbGoiso = 1 ) {
		; 	If (ddlLoaiTN = "Thường") {
		; 		Starttime := A_TickCount
		; 		If (mod(icount, SoBNcallQMS)=0) {
		; 			WinActivate, %TITLE_TIEPNHAN%
		; 			ControlClick, %HISctrl_Goiso%, %TITLE_TIEPNHAN%
		; 			Sleep 200
		; 			Loop {
		; 				ControlGet, var, Enabled,, %HISctrl_Goiso%, %TITLE_TIEPNHAN%
		; 				If (var=1)
		; 					Break
		; 			}
		; 		Endtime := A_TickCount
		; 		time_goiso := (Endtime-Starttime-200)
		; 		}
		; 	}
		; }
		;//////////////////////////////////////////////////////////////
		Sleep 300
		ControlClick, % HISctrl_Nhapmoi , % TITLE_TIEPNHAN
		Sleep 300
		personType := ddlBenhnhan
		person_info := fn_CreatePersonInfo(personType, ddlDauthe)
		HoVaTen := person_info.name.ho . " " . person_info.name.lot . " " . person_info.name.ten
		BirthDay := person_info.birthday
		GenderID := person_info.GenderID
		Address := person_info.address
		AddrCode := person_info.addrCode
		Phone := person_info.phone_num
		personType := person_info.personType
		If (UX = 1) {

		}
		Else {
			Send % "HHH"
			;Sleep 500
			Send {Enter}
			waitform(g_fDSBN_Title)
			Sleep 500
			Send ^{n}
			Partient_Form := "THÔNG TIN BỆNH NHÂN"
			waitform(Partient_Form)
			Sleep 300
			send ^{a}
			Sleep 300
			
			edit_choose(HoVaTen, 300)
			bdayD := SubStr(BirthDay, 1, 2)
			bdayM := SubStr(BirthDay, 3, 2)
			bdayY := SubStr(BirthDay, 5, 4)
			send, % bdayD
			sleep, 200
			send % bdayM
			sleep, 200
			edit_choose(bdayY, 300)
			; CHỌN Giới tính
			; garr_GenderSuggest
			; Nếu LÓT = gợi ý giới tính thì k cần chọn
			If fn_isInArray(person_info.name.lot, garr_GenderSuggest)
				send {Tab}
			Else {
				loop, % GenderID
					{
						send {Down}
						Sleep, 300
					}
				Send {Tab}
			}
			sleep, 200
			Send {Tab}
			edit_choose(Address, 300)
			edit_choose(AddrCode, 300)
			IfWinActive, % "Thông báo"
				Send {Enter}
			loop, 4
				{
					Send {tab}
					Sleep, 300
				}
			; NHẬP SDT
			
			edit_choose(Phone, 300)
			; LƯU THÔNG TIN BỆNH NHÂN
			Send ^{s}
			Startime := A_TickCount
			WinWaitActive, % "Thông báo"
			Endtime := A_TickCount
			Time_saveInfoPatient := Endtime - Startime	;Tính thời gian lưu thông tin BN
			Sleep 200
			Send {Enter}
			Sleep 200
			WinWaitActive, % TITLE_TIEPNHAN


			If (ddlDoituong = "BHYT (Thẻ tạm)") {
				Return
			}
			Else If (ddlDoituong != "Thu phí") {
				Sleep, 300
				Send {F2}
				WinWaitActive, % g_fBHYT_Title ,, 2
				If ErrorLevel {
					Msgbox, 48, % "Oop!", % "Có lỗi khi vào màn hình THÔNG TIN THẺ BHYT"
					Return
				}
				; If ( ddlDoituong = "BHYT" ) {
				; 	Return
				; }
				; Else If ( ddlDoituong = "BHYT-GCT" ) {
				; 	Return
				; }
				
				BHYT := fn_CreateBHYTCode(personType, ddlDoituong, ddlDauthe, gnHanThe)
				bhyt_code := BHYT.bhytcode
				Bhyt_hoscode := BHYT.hoscode		
				Bhyt_from := BHYT.fromdate
				Bhyt_to := BHYT.todate
				edit_choose(bhyt_code, 300)
				if (ddlTuyen = "Đúng tuyến")
					Send {tab}
			
				else
					ddl_choose(bhyt_hoscode,300)
				edit_choose(bhyt_from,300)
				edit_choose(bhyt_to,300)
				Send ^{s}
				WinWaitActive, % "Thông báo",, 2
				If ErrorLevel
				{
					Send {Enter}
					Sleep 300
					Send ^{q}
				}
				Sleep 300
				Send {enter}
				Sleep 300
				Send {enter}
				WinWaitActive, % "KIỂM TRA THÔNG TUYẾN"
				Sleep 300
				Send ^{q}
				Waitform(TITLE_TIEPNHAN)
				sleep 300
			}

			
		}
		; Nhập thẻ BHYT
		
			
		
		;Nhập thông tin thẻ 5 năm 6 tháng
		If ( cbBHYT5Nam ) {
			Sleep, 200
			ControlClick, % ClassNN_cb5nam, % TITLE_TIEPNHAN
			sleep, 300
			Send {tab}
			Sleep, 300
			rd := RandomNum(1,24)
			date5nam := A_Now
			date5nam += -%rd%, Days
			FormatTime, date5nam, %date5nam%, ddMMyyyy
			edit_choose(date5nam, 200)
		}
		;Nhập giấy chuyển tuyến
		if ( ddlDoituong = "BHYT-GCT") {
			If ( ClassNN_GCT = "") {
				Msgbox, 16, % "Thông báo", % "Có lỗi, không nhậP được SCT,`n Thử lại"
				WinActive(AHK_tittle)
				Return
			}
			ControlClick, % ClassNN_GCT, % TITLE_TIEPNHAN
			
			Sleep, 500
			random, R, 1000, 9999
			sct := R . "/2023/GCT"
			ngay_chuyen := "20122022"
			hieu_luc := "31122022"
			icd_chinh := "I10"
			icd_kemtheo := "J35.1"
			; Bhyt_hoscode

			edit_choose(sct, 200)
			; edit_choose(ngay_chuyen, 200)
			send {tab}
			; edit_choose(hieu_luc, 300)
			ddl_choose(Bhyt_hoscode, 200)
			ddl_choose(icd_chinh, 300)
			ddl_choose(icd_kemtheo, 300)
			Send {tab}
			Sleep, 200
			edit_choose("+bonus ICD", 300)
			send {tab}
			Sleep, 200
			Send {tab}
			Sleep, 200
			
			loop, 3
			{
				sleep, 200
				send {down}
				sleep, 200
				send {tab}
			}
			Sleep, 300
			Send {Enter} ; Nhấn "Đồng Ý" Trên Form
		}
		;Tiếp nhận trả sau
		ClassNN_LoaiTiepnhan := 


		;MUA SỔ KHÁM BỆNH
		If ( cbMuaSKB ) {
			ControlClick, % ClassNN_SKB , % TITLE_TIEPNHAN
			Sleep, 200
		}
		;TÍCH BN ƯU TIÊN
		If ( cbBNUuTien ) {
			If (yearold < 80) { ; Do BN > 80 sẽ auto là BN ƯU tiên
				ControlClick, %ClassNN_BNUT%, % TITLE_TIEPNHAN
				Sleep, 200
			}
		}
		Sleep 500
		Send ^{s}
		Starttime := A_TickCount
		WinWaitActive, % "Thông báo"
		fYESctrl := ""
		;Kiểm tra xem có thông báo xác nhậnh Yes/No hay không
		WinGet, iList, ControlList, % "Thông báo"
		Loop, Parse, iList, `r`n
		{
			ControlGetText, OutputVar, %A_LoopField%, % "Thông báo"
			if ( OutputVar = "&Yes") {
				fYESctrl := A_LoopField
				Break
			}
		}
		If (fYESctrl != "") {
			Send {Y}
			fOKctrl := ""
			Loop
			{
				WinGet, iList, ControlList, % "Thông báo"
				Loop, Parse, iList, `r`n
				{
					ControlGetText, OutputVar, %A_LoopField%, % "Thông báo"
					if ( OutputVar = "&OK") {
						fOKctrl := A_LoopField
						Break
					}
				}
				If (fOKctrl != "") {
					Send {Enter}
					Break
				}
			}
		}
		Else {
			WinActivate, % "Thông báo"
			Sleep, 200
			Send {enter}
		}
		Sleep, 200
		Loop {
			Controlget, var, Enabled,, %HISctrl_Luu%, %TITLE_TIEPNHAN%
			If (var=1)
				Break
		}
		Endtime := A_TickCount
		TimeSaveReception := (Endtime-Starttime)
		iMATN := Clipboard
		WinActivate, %TITLE_TIEPNHAN%
		
		icount++
		FormatTime, iNow,, dd/MM/yyyy HH:mm:ss
		;Ghi log tiếp nhận
		tiepnhan_log := iNow
						. "," . iMATN
						. "," . full_name
						. "," . ddlPhongkham
						. "," . time_goiso
						. "," . Time_saveInfoPatient
						. "," . TimeSaveReception
		;tiepnhan_log := StrReplace(tiepnhan_log, "|",";")
		create_log(tiepnhan_log)
		;Thu tiền
		If ( cbThutien ) {
			ControlClick, % HISctrl_Thutien, % TITLE_TIEPNHAN
			WinWaitActive, % gTITLE_TNVP
			Loop,
			{
				WinGet, ilist, ControlList, % gTITLE_TNVP
				VPbtnThutien := ""
				Loop, Parse, ilist, `n`r
				{
					ControlGetText, OutputVar, %A_LoopField%, % gTITLE_TNVP
					If (OutputVar = "Thu tiền") {
						VPbtnThutien := A_LoopField
						Break
					}
				}
				If (VPbtnThutien != "")
					Break
			}
			Loop 
			{
				Controlget, var, Enabled,, %VPbtnThutien%, %gTITLE_TNVP%
				If (var=1)
					Break
			}
			Sleep 300
			ControlClick, % VPbtnThutien, % gTITLE_TNVP
			WinWaitActive, % "THU TIỀN"
			Send ^{s}
			WinWaitActive, % "XEM TRƯỚC KHI IN"
			Send {Esc}
			WinWaitActive, % "Thông báo"
			Send {Enter}
			Sleep 200
			Send ^{t}
			WinWaitActive, % TITLE_TIEPNHAN
		}

		;Nhập dấu sinh tồn
		If cbDST {
			ControlClick, % HISctrl_Nhapsinhhieu, % TITLE_TIEPNHAN
			WinWaitActive, % "SINH HIỆU"
			edit_choose(RandomNum(155,170), 200)
			edit_choose(RandomNum(50,70), 200)
			edit_choose(RandomNum(90,130), 200)
			edit_choose(RandomNum(60,90), 200)
			edit_choose(RandomNum(70,150), 200)
			edit_choose(RandomNum(35.0,37.0), 200)
			edit_choose(RandomNum(95,100), 200)
			edit_choose(RandomNum(15,30), 200)
			Send {Enter}
			WinWaitActive, % "Thông báo"
			Send {Enter}
		}
		;END LOOP
	}
	Script_end := A_TickCount
	TotalTime := ConvertMilisec(Script_end-Script_start)
	TotalTime_H := TotalTime.hour
	TotalTime_M := TotalTime.min
	TotalTime_S := TotalTime.sec
	MsgTime := ""
	If (TotalTime_H <> 0) {
		MsgTime .= TotalTime_H . " giờ "
	}	
	If (TotalTime_M <> 0)
		MsgTime .= TotalTime_M . " phút "
	MsgTime .= TotalTime_S . " giây "
	MsgBox, 64, % "WoW", % "Chạy Script thành công!`nSố BN: " . SoBN . "`nThời gian: " . MsgTime
	WinActivate, % AHK_tittle
	Return

;FUNCTION
;BASIC FUNCTION
;Random Số
RandomNum(f_num, t_num)
{
	Random, r, %f_num%, %t_num%
	Return % r
}
;Random dãy số
RandomNumRange(len, i = 48, x = 57)  ; length, lowest and highest Asc value
{
	Loop, % len
	{
		Random, r, i, x
		s .= Chr(r)
	}
	Return, s
}
;Phân tách số hàng ngàn
fn_ThousandSeperate(k)
{
	If (k < 1000)
		Return k . " ms"
	Else
		Return, Format("{:d}", (k - mod(k,1000))/1000) . "," . mod(k,1000) . " ms"
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
;Kiểm tra giá trị tồn tại trong mảng
fn_isInArray(string, array)
{
	L := array.Length()
	Loop, % L
	{
		i := A_index
		If (array[i] = string)
			Return, True
	}
	Return, False
}
;Trả về index của giá trị trong mảng
fn_indexInArray(string, array)
{
	L := array.Length()
	Loop, % L
	{
		i := A_index
		If (array[i] = string)
			Return, i
	}
	Return, 1
}
;Trả về index của giá trị trong string
fn_indexInString(needle, string, seperate)
{
	Loop, Parse, string, % "`" . seperate
	{
		If (needle = A_LoopField)
			Return, A_Index
	}
	Return, 0

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


;Hàm get tất cả file trong folder
fn_GetlistFile(path)
{
	tmpAR := []
	path := path . "\*.*"
	tmpString := ""
	Loop, % path
	{
		tmpAR.push(A_LoopFileName)
	}
	Return, tmpAR
}

;Specical Function
;Tách x,y từ dữ liệu (XY=123,36 =>x=123 y=36)
fn_getXY(XY)
{
	Loop, parse, XY, `,
	{
		If (A_index = 1)
			Str1 := A_LoopField
		Else if (A_index = 2)
			Str2 := A_LoopField
		Else
			Continue
	}
	Return {xPOS:Str1, yPOS:Str2}
}

;Sử dụng cho các TH chọn dữ liệu dạng DropDownList
ddl_choose(mydata, ctime)      
{
	Send {Text}%mydata%
    Sleep %ctime%
    Send {down}
    Sleep %ctime%
    Send {enter}
    Sleep %ctime%
    Send {tab}
    sleep %ctime%
}
;Sử dụng cho các TH nhập sử liệu vào ô Edit
edit_choose(mydata, ctime)				
{
	If (mydata <> 0)
		Send {Text}%mydata%
	Sleep %ctime%
	Send {tab}
	Sleep %ctime%
}
;Hàm wait form
Waitform(form_name) {
	WinWaitActive, % form_name,, % g_nWait
    If ErrorLevel
    {
        Msgbox, 16, % "Oop!", % "Không vào được form " . form_name
		Return
        exit
    }
}
;RANDOM DATE FROM-TO

RandomDate(startDate,endDate,Format) 
{
	startDate := RegExReplace(startDate,"/"), max := endDate :=	RegExReplace(endDate,"/")
	max -= startDate, days
	Random, days, 1, %max%
	startDate += days, days
	FormatTime, newDate, %startDate%, %Format%
	return	newDate
}
GETyearNyearAGO(N) 
{
	n_day := A_DD
	n_month := A_Mon
	n_year := A_Year-N
	idate := n_year . "/" . n_month . "/" . n_day
	Return % idate
}
ConvertMilisec(mil)
{
    If (mil<1000)
        sec = 0
    Else
        sec := SubStr(mil, 1, Strlen(mil)-3)
    min := Floor(sec/60)
    sec := sec-(min*60)
    hour := Floor(min/60)
    min := min-(hour*60)
	If (hour<10)
		hour := "0" . hour
	If (min<10)
		min := "0" . min
	If (sec<10)
		sec := "0" . sec
    Return, {hour:hour, min:min, sec:sec, Mil:mil}
}
;Tạo thông tin HỌ va TÊN
fn_CreatePersonName(Gend)
{
	;Data
	firstname_arr := ["Nguyễn","Bùi","Nguyễn","Châu","Đặng","Nguyễn","Đinh","Đỗ","Đoàn","Dương","Hà","Hồ","Hứa","Huỳnh","Lê","Lý","Mạc","Mai","Ngô","Nguyễn","Phạm","Phan","Quách","Tăng","Thạch","Thái","Tô","Tôn","Trần","Triệu","Trịnh","Trương","Võ","Vương"]
	midname_male_arr := ["Ngọc", "Minh", "Bảo","Văn","Gia","Hoàng","Thiên","Khánh","Thái","Tuấn"]
	midname_female_arr := ["Hồng","Thị","Thị","Thị","Thị","Thị","Thị"]
	lastname_male_arr := ["An","Anh","Bảo","Bình","Biên","Công","Chung","Cường","Danh","Du","Duy","Dũng","Dương","Đường","Đạt","Được","Đăng","Định","Đức","Hoài","Hoàng","Hải","Hùng","Huy","Hậu","Huấn","Hưng","Kiên","Linh","Lương","Lăng","Ly","Long","Mạnh","Minh","Mẫn","Nam","Năm","Nghị","Phúc","Phước","Phong","Phi","Quyền","Quãng","Tư","Tứ","Tuấn","Tùng","Tấn","Tiến","Toàn","Thịnh","Thông","Thương","Tài","Thắng","Thanh","Vũ","Vy","Văn"]
	lastname_female_arr := ["Ánh","Bống","Chi","Chung","Châu","Dung","Dương","Duyên","Hằng","Hoài","Hương","Hai","Hạnh","Hồng","Hoa","Kiều","Linh","Lan","Ly","Liễu","Mai","Mơ","Nhung","Nhi","Như","Nga","Ngân","Phượng","Phương","Quyên ","Tình","Tư","Thương","Thảo","Thơ","Thơm","Thi","Thúy","Thủy","Thanh","Uyên","Yến","Vân Anh","Bảo Anh","Kiều Anh","Ngọc Anh","Trâm Anh","Trà Long","Trà My","Gia Mỹ","Kiều Tiên","Thúy Kiều ","Thúy Vân","Vân Kiều"]
	;--------------------------------------
    F_name := fn_randInArray(firstname_arr)
    If (Gend = 1) {
        M_name := fn_randInArray(midname_male_arr)
        L_Name := fn_randInArray(lastname_male_arr)
    }
    Else {
        M_name := fn_randInArray(midname_female_arr)
        L_Name := fn_randInArray(lastname_female_arr)
    }
    Return, {Ho:F_name, Lot:M_name, Ten:L_Name}
}

;Hàm tạo ramdom địa chỉ
fn_CreateAddress()
{
	address := ""
	random, r, 1, 3
	If ( r = 1)
		address := RandomNum(10,1000) . ", " . fn_randInArray(gArrayAddressName)
	Else if ( r = 2)
		address := RandomNum(10,1000) . "/" . RandomNum(1,20) . ", " . fn_randInArray(gArrayAddressName)
	Else
		address := RandomNum(10,1000) . "/" . RandomNum(1,20) . "/" . RandomNum(1,5) . ", " . fn_randInArray(gArrayAddressName)
	return, address
}

fn_CreatePersonInfo(personType, dauthe)
{
	Random, rGender, 1, 2
	name := fn_CreatePersonName(rGender)
	If (personType = "Trẻ em")
		bday := RandomDate(GETyearNyearAGO(0) ,GETyearNyearAGO(6),"ddMMyyyy") ;Tạo ngày sinh từ 0T >> 6T
	else if (personType = "Lão")
		bday := RandomDate(GETyearNyearAGO(70) ,GETyearNyearAGO(100),"ddMMyyyy") ;Tạo ngày sinh từ 70T >> 100T
	else {
		If (dauthe = 4)
			Random, R1, 1, 3
		Else
			R1 = 3
		; R1 = 1 sẽ là học sinh
		If (R1 = 1) {
			bday := RandomDate(GETyearNyearAGO(6) ,GETyearNyearAGO(18),"ddMMyyyy")
			personType := "Học sinh"
		}
		; R2 sẽ là sinh viên
		Else if ( R1 = 2) {
			bday := RandomDate(GETyearNyearAGO(18) ,GETyearNyearAGO(25),"ddMMyyyy")
			personType := "Sinh viên"
		}
		Else {
			bday := RandomDate(GETyearNyearAGO(25) ,GETyearNyearAGO(70),"ddMMyyyy")
			personType := "Other"
		}
	}

	arr_addcode := ["HCTDTB","DIBHTD","DILKXU","DILKPB","DILKBV","DILKXL","DILKBS","DILKBV"]
	addrCode := fn_randInArray(arr_addcode)
	addr := fn_CreateAddress()
	phone_num := "09" . RandomNumRange(8)
	email := "abc@gmail.com"

	Return, {name: name, genderID: rGender, birthday: bday, addrCode: addrCode, address: addr, phone_num: phone_num, email: email, personType: personType}

}

; Trả về 1 giá trị ngẫu nhiên trong mảng
fn_randInArray(arr)
{
	arr_len := arr.Length()
	Random, r, 1, % arr_len
	return, arr[r]
}

fn_createBirthday(personType, DT = 0)
{
	Switch % personType
	{
		Case "Trẻ em":
			bday := RandomDate(GETyearNyearAGO(0) ,GETyearNyearAGO(6),"ddMMyyyy")
		Case "Lão":
			bday := RandomDate(GETyearNyearAGO(70) ,GETyearNyearAGO(100),"ddMMyyyy")
		Case "Học sinh":
			bday := RandomDate(GETyearNyearAGO(6) ,GETyearNyearAGO(18),"ddMMyyyy")
		Case "Sinh viên":
			bday := RandomDate(GETyearNyearAGO(18) ,GETyearNyearAGO(25),"ddMMyyyy")
		Case Default:
			bday := RandomDate(GETyearNyearAGO(25) ,GETyearNyearAGO(70),"ddMMyyyy")
	}
	return % bday
}

;Hàm tính tuổi theo ngày sinh
fn_tinhtuoi(birthday)
{
	byear := SubStr(birthday, 5, 4)
	year_now := A_Year
	yearold := year_now-byear
	Return yearold
}


;Hàm tạo thẻ BHYT
fn_CreateBHYTCode(personType, doituong, DT, hanthe)
{
	;ar_BHYT0 := ["DN4","HX4","CH4","NN4","TK4","HC4","XK4","TB4","NO4","XB4","TN4","CS4","XN4","MS4","HD4","TQ4","TA4","TY4","HG4","LS4","PV4","GB4","GD4","HT3","TC3","CN3","CC1","CT2","CK2","CB2","KC2","HN2","DT2","DK2","XD2","BT2","TS2","QN5","CA5","CY5"]
	ar_BHYT1 := ["CC1"]
	ar_BHYT2 := ["CK2","CB2","KC2","HN2","DT2","DK2","XD2","BT2","TS2", "CT2"]
	ar_BHYT3 := ["HT3","TC3","CN3"]
	ar_BHYT4 := ["DN4","HX4","CH4","NN4","TK4","HC4","XK4","TB4","NO4","XB4","TN4","CS4","XN4","MS4","HD4","TQ4","TA4","TY4","HG4","LS4","PV4","GB4","GD4"]
	ar_BHYT5 := ["QN5","CA5","CY5"]

	cskcb := "75009"
	ngoaitinh_kcb := ["79011","75011","79012","79013","79014","79015","79016"]
	noitinh_kcb := ["75010","75011","75012","75013"]
	noingoaitinh_kcb := ngoaitinh_kcb
	for i in noitinh_kcb {
		noingoaitinh_kcb.Push(noitinh_kcb[i])
	}
	Switch % personType
	{
		Case "Trẻ em":
			DAUTHE := "TE1"
		Case "Học sinh":
			DAUTHE := "HS4"
		Case "Sinh viên":
			DAUTHE := "SV4"
		Default:
			Switch % DT {
				Case 1:
					DAUTHE := fn_randInArray(ar_BHYT1)
				Case 2:
					DAUTHE := fn_randInArray(ar_BHYT2)
				Case 3:
					DAUTHE := fn_randInArray(ar_BHYT3)
				Case 4:
					DAUTHE := fn_randInArray(ar_BHYT4)
				Case 5:
					DAUTHE := fn_randInArray(ar_BHYT5)
			}
	}

	if (doituong = "BHYT-GCT") {
		IniRead, iGCT, % path_Config, section1, GCT
		;Nếu là Nội tỉnh
		if (iGCT = 1) {
			maBV := fn_randInArray(noitinh_kcb)
			maTinh := SubStr(maBV, 1, 2)
		}	
		else if (iGCT = 2) {
			maBV := fn_randInArray(ngoaitinh_kcb)
			maTinh := SubStr(maBV, 1, 2)
		}
		else {
			maBV := fn_randInArray(noingoaitinh_kcb)
			maTinh := SubStr(maBV, 1, 2)
		}
	}
	else {
		maBV = 75009
		maTinh = 75
	}
	
	bhyt := DAUTHE . maTinh . RandomNumRange(10)
	; hạn thẻ

	if (hanthe = 2) {
		FormatTime, FromDate, , ddMMyyyy
		ToDate := SubStr(FromDate, 1, 4) . SubStr(FromDate, 5, 4)+1
	}
	else if (hanthe = 3) {
		FormatTime, ToDate, , ddMMyyyy
		FromDate := SubStr(ToDate, 1, 4) . SubStr(ToDate, 5, 4)-1
	}
	else {
		FromDate := RandomDate(GETyearNyearAGO(1) ,GETyearNyearAGO(0) ,"ddMMyyyy")
		ToDate := SubStr(FromDate, 1, 4) . SubStr(FromDate, 5, 4)+1
	}
	
    Return, {bhytcode:bhyt, hoscode:maBV, fromdate:FromDate, todate:ToDate}

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
; ;Đọc file có ,
; fn_readFileTwo(path)
; {
; 	tmpAR := []
; 	Loop,
; 	{
; 		i := A_Index
; 		FileReadLine, outVar, % path, % i
; 		If ErrorLevel
; 			Break
; 		Loop, Parse, outVar, `,
; 		{
; 			If ( A_index=1 )
; 				str1 := A_LoopField
; 			else if ( A_index=2 )
; 				str2 := A_LoopField
; 		}
; 		tmpAR.Push({1:Str1,2:str2})
; 	}
; 	Return, tmpAR
; }

;Hàm tạo Email theo Họ và tên
fn_CreateEmail(name, bday)
{
    tmpAR := []
	name := Bodau(name)
	Loop, Parse, name, ` %A_Space%
    {
        If (A_LoopField != "")
            tmpAR.Push(A_LoopField)
    }
    iMax := tmpAR.Length()
    tiepdaungu := tmpAR[iMax]
    Loop, % iMax - 1
    {
        tiepvingu .= SubStr(tmpAR[A_Index], 1, 1)
    }

	StringLower, tiepvingu, tiepvingu
	email := tiepdaungu . tiepvingu . SubStr(bday, -1) . gsEmail
	Return, email
}
;Lấy thông tin Cty từ file chuyển thanh array
fn_GetArrayOfCompany()
{
	tmpARR := []
	Loop,
	{
		i := A_Index
		FileReadLine, OutputVar, % path_Company, % i
		If ErrorLevel
			Break
		Loop, Parse, OutputVar, CSV
		{
			If (A_Index = 1)
				name := A_LoopField
			If (A_Index = 2)
				MST := A_LoopField
			If (A_Index = 3)
				addr := A_LoopField
		}
		tmpARR.Push({1:name,2:MST,3:addr})
	}
	Return, tmpARR
}
;Hàm Lowercase
Lowercase(string)
{
	StringLower, OutputVar, string
	Return, % OutputVar
}
;Hàm bỏ dấu
Bodau(myString)
{    
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
;Tạo file log
create_log(string)
{
	string := string . "`n"
	FormatTime, folder,, yyyyMM
	FormatTime, filename, , dd
	Filepath := A_ScriptDir . "\log\" . folder 
	FileCreateDir, %Filepath%
	Filepath := A_ScriptDir . "\log\" . folder . "\" . filename . ".txt"
	FileAppend, %string%, %Filepath%
	Return
}



check_string_in_array(arr, string)
{
	Loop, % arr.Length()
	{
		If ( string = arr[A_Index])
			return, True
	}
	Return, False
}


;///////////////////////////////////////
; KHÁM BỆNH
;///////////////////////////////////////
::=nv::
	Gui, 1:Submit, Nohide
	kham_nhapvien()
	Return


kham_nhapvien()
{
	
	kham_tt_kham()
	global cbCDDV
	global ddlKhoaNV
	
	Sleep, 200
	send {F9}
	Sleep, 200
	Send {Tab}
	Sleep, 200
	t_lydovv := "BN cần điều trị, theo dõi thêm"
	t_quatrinhbenhly := "Không có"
	t_tiensubthan := "Không"
	t_tiensugd := "Bố/Mẹ cao huyếp áp"
	t_toanthan := "Bệnh tỉnh"
	t_bophan := "Mắt đỏ"
	t_cls := "Chưa thực hiện"
	t_ghichu := "Ghi chú nhập viện"
	edit_choose(t_lydovv, 300)
	ddl_choose(ddlKhoaNV, 300)
	edit_choose(t_quatrinhbenhly, 300)
	edit_choose(t_tiensubthan, 300)
	edit_choose(t_tiensugd, 300)
	edit_choose(t_toanthan, 300)
	edit_choose(t_bophan, 300)
	edit_choose(t_cls, 300)
	edit_choose(t_ghichu, 300)
	Send ^{s}
	Return
}

kham_tt_kham()
{
	trieu_chung_ar := ["Đau vai gáy dài ngày","Sưng U vòng họng", "Thở gấp, hồi hộp", "Lo lắng, mất ngủ nhiều đêm, kéo dàu"]
	icd_ar := ["M49.01*","J35.1","I10","N17"]
	max_l := trieu_chung_ar.Length()
	icd_max := icd_ar.Length()
	random, R1, 1, max_l

	trieu_chung := trieu_chung_ar[R1]
	send % trieu_chung
	send {tab}{tab}

	icd := icd_ar[R1]
	send % icd
	send {tab}
	return
}


chidinh_dv()
{
	global path_SERVICE
	loop,
		{
			FileReadLine, OutputVar, % path_SERVICE, A_Index
			If ErrorLevel
				Break
			Loop, Parse, % OutputVar,`;
				{
					If (A_Index = 1)
						{
							ddl_choose(A_LoopField, 300)
							Send {F2}
						}
				}
		}
	Return
}
