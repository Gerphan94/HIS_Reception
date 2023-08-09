#NoEnv
#Include %A_ScriptDir%\Data

;BASIC FUNC
;ConvertARRtoString
ConvertARRtoString(arr)
{
	i := arr.Length()
	Loop, %i%
	{
		_str .= arr[A_Index]
		If (A_Index <> i)
			_str .= "|"
	}
	Return, _str
}

;TÌM XEM GIÁ TRỊ NẰM Ở STT BAO NHIÊU TRONG ARRAY
FindInArray(arr, string)
{
	Kq := 0
	i := arr.Length()
	Loop, %i%
	{
		If ( string = arr[A_Index])
			return, A_Index
	}
	Return, 0
}

;Check Resolution
CheckResolution()
{
	wid := A_ScreenWidth
	hei := A_ScreenHeight
	Screen = %wid%:%hei%
	If (Screen="1366:768")
		Return True
	Else
		Return False
}
;Random String
RandomStr(len, i = 48, x = 122) { ; length, lowest and highest Asc value
	Loop, %len% {
		Random, r, i, x
		s .= Chr(r)
	    }
	Return, s
    }
;Random dãy số
RandomNumRange(len, i = 48, x = 57) { ; length, lowest and highest Asc value
	Loop, %len% {
		Random, r, i, x
		s .= Chr(r)
	    }
	Return, s
    }

;RANDOM 1 SỐ
RandomNum(f_num, t_num)
{
	Random, a, %f_num%, %t_num%
	Return %a%
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
create_log(mytest,module)			
{
	
	FormatTime, foldername, , yyyy.MM
	path = %A_ScriptDir%\log\%foldername%
	FileCreateDir, %path%
	Path = %A_ScriptDir%\log\%foldername%\%module%
	FileCreateDir, %path%
	FormatTime, logdate,,yyyyMMdd
	FileAppend, %mytest% `n, %path%\log%logdate%.txt
	Return
}
create_logerror(mytest)			
{
	;MsgBox, %mytest%
	FormatTime, logdate,,yyyyMMdd
	FileAppend, %mytest% `n, %A_ScriptDir%\logerror\logerror%logdate%.txt
	Return
}

Waitform(form_name) {
	WinWaitActive, %form_name%,, 10
    If ErrorLevel
    {
        Msgbox, 16, Oop!, Không vào được form %form_name%
        exit
    }
}

;Tạo thông tin HỌ va TÊN
Create_PersonName(Gend)
{
    F_name := fn_returnArr(firstname_arr)
    If (Gend = 1) {
        M_name := fn_returnArr(midname_male_arr)
        L_Name := fn_returnArr(lastname_male_arr)
    }
    Else {
        M_name := fn_returnArr(midname_female_arr)
        L_Name := fn_returnArr(lastname_female_arr)
    }
    Full_name := F_name . " " . M_name . " " . L_Name
    Return, {HovaTen:Full_name, Lot:M_name}
}
; Trả về 1 giá trị ngẫu nhiên trong mảng
fn_returnArr(arr)
{
	arr_len := arr.Length()
	Random, r, 1, %arr_len%
	return, arr[r]
}


ddl_choose(mydata, ctime)      ;Sử dụng cho các TH chọn dữ liệu dạng DropDownList
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
edit_choose(mydata, ctime)				;Sử dụng cho các TH nhập sử liệu vào ô Edit
{
	If (mydata <> 0)
		Send {Text}%mydata%
	Sleep %ctime%
	Send {tab}
	Sleep %ctime%
}
Formatnumber(num,i)
{
	If (i = 1)
		n_num := Format("{:.1f}", num)
	Else
		n_num := Format("{:.2f}", num)
	return %n_num%
}
;HÀM TẠO BHYT CODE

Create_bhytcode(BH_header)
{
	;bhyt0 = %BH_header%
	bhytArr := ["CC1","CK2","CB2","KC2","HN2","DT2","DK2","XD2","BT2","TS2","HT3","TC3","CN3","DN4","HX4","CH4","NN4","TK4","HC4","XK4","TB4","NO4","CT2","XB4","TN4","CS4","XN4","MS4","HD4","TQ4","TA4","TY4","HG4","LS4","PV4","GB4","GD4","QN5","CA5","CY5"]
	code := ["79011","75011","79012","79013","75009"]
    Icode := code[randomNum(1,code.Length() )]
	If (BH_header = "")
		bhyt := bhytArr[randomNum(1,bhytArr.Length())] . SubStr(icode, 1, 2) . RandomNumRange(10)
	Else
		bhyt := BH_header . SubStr(icode, 1, 2) . RandomNumRange(10)
	FromDate := RandomDate(GETyearNyearAGO(1) ,GETyearNyearAGO(0) ,"ddMMyyyy")
	ToDate := SubStr(FromDate, 1, 4) . SubStr(FromDate, 5, 4)+1
    Return, {bhytcode:bhyt, hoscode:icode, fromdate:Fromdate, todate:todate}
}

randomICD()
{
	Filename = %A_ScriptDir%\data\icdlist.txt
	Loop, Read, %Filename%
	{
		Max = %A_Index%
	}
	Random,r,1,%Max%
	FileReadLine, OutputVar, %Filename%, %r%
	Return %OutputVar%
}

Readrandomlinefromfile(path)
{
	Loop, Read, %path%
	{
    	Maxline = %A_Index%
	}
	Random, r, 1, %Maxline%
	FileReadLine, line, %path%, %r%
   	; If ErrorLevel
    ; 	    MsgBox, 16, Lỗi Script, Không tìm được file. 
	Return %line%
}
ratoa_new()
{
	pharma_str = Losec|Onglyza|Tanatril|Duphaston|Victoza
	Random,r_phar,1,5
	Loop, Parse, pharma_str, `|
	{
		Phar_name = %A_LoopField%
		Max_pharname := StrLen(Phar_name)
	
		f_pharname := SubStr(Phar_name, 1, 1)
		l_pharname := SubStr(Phar_name, 2, StrLen(Phar_name))
		
		send % f_pharname
		Sleep 200
		ddl_choose(l_pharname, 300)
		If (r_phar = A_Index)
			Break
	}
}
ddl_array(path)
{
	Loop, read, %path%
	{
		FileReadLine, iline, %path%, %A_Index%
		{
			mystr .= iline
			mystr .= "|"
		}
	}
	Return %mystr%
}

create_add()
{
	xpath = %A_ScriptDir%\data\address.txt
    Loop, read, %xpath%
    {
    	max = %A_Index%
    }
    random, i, 1, %max% 
    FileReadLine, iline, %xpath%, %i%
    If ErrorLevel
    	MsgBox, 16, Lỗi Script, Không tìm được file
	Random, iNum, 10, 1500
	Random, r1, 1, 2
	If (r1 = 1)
	{
		Random, r2, 1, 20
		iNum := iNum . "/" . R2
	}
    address := "Số " . iNum ", " . iline
    return address
}

Create_Stringdata()
{
    Filename = %A_ScriptDir%\data\Vocabulary.txt
    random, inum, 1, 5
    Loop, Read, %Filename%
	{
		Max = %A_Index%
	}
    Loop, %inum%
    {
        Random,r,1,%Max%
	    FileReadLine, OutputVar, %Filename%, %r%
        mystring .= OutputVar
        If (A_Index=inum)
            Break
        mystring .= "`n"
    }
	Return %mystring%

}

Checktenphong(ten, itype, winform) 
{
	TN_thuong := {"Phòng Hành chính - Quầy tiếp nhận 1":1}
	TN_san := {"Khoa Sản phụ - Tiếp nhận Sản":1}
	TN_dichvu := {"":1}
	TN_capcuu := {"":1}
	WinGet, ilist, controllist, %title_tnkhambenh%
	Loop, Parse, ilist, `n`r
	{
		ControlGetPos, X, Y, , , %A_LoopField%, %title_tnkhambenh%
		If (X=887 and Y=36) {
			Tenphong := A_LoopField
			Break
		}
	}
	ControlGetText, OutputVar, %Tenphong%, %title_tnkhambenh%
	If (TN_thuong[OutputVar]) {
		return True
	}
	Else
		return False
}

CreatEvenNumber(jump)
{
	random, x, 1, 9
	num := x*jump
	Return % num
}

GetUsername(n)
{
	Username_path = %A_ScriptDir%\data\username.txt
	If (n=0) {
		Loop, read, %Username_path%
		{
			FileReadLine, var, %Username_path%, A_Index
			MyString .= "|"
			MyString .= var
			max := A_index
		}
	}
	Else {
		Max := n
		Loop, read, %Username_path%
		{
			max := A_Index
		}
		Loop, %n%
		{
			Loop
			{
				Random, LineNum, 1, %max%
				FileReadLine, var, %Username_path%, %LineNum%
				IfNotInString, MyString, %var%
					Break
			}
			MyString .= var
			If (A_Index=n)
				Break
			Else
				MyString .= "|"
		}
	}
	Return, {name: MyString, num: Max}
}

;<<- RANDOMNUMBERLIST
;Tạo ngẫu nhiên dãy 4 số với dk là có ít nhất 1 số > 0
randomnumberlist()
{
	Loop, 4
	{
		If (A_Index=4) 
		{
			If (a1=a2=a3=0)
				Random, a%A_Index%, 1, 4
			Else
				Random, a%A_Index%, 0, 4
		}
		Else
		{
			Random, a%A_Index%, 0, 4
		}
			sl%A_Index% := a%A_Index%*0.5
			sl%A_Index% := Format("{:.1f}", sl%A_Index%)
	}
	Return, {sl1:sl1,sl2:sl2,sl3:sl3,sl4:sl4}
}
;RANDOMNUMBERLIST ->>
;
;
GETyearNmonthAGO(N) 
{
	n_day := A_DD
	n_month := A_Mon
	n_year := A_Year

	imod := mod(N, 12)
	iyear := Floor((N-imod)/12)
	i_day := n_day

	If (n_month-imod<0) {
		i_month := n_month+12-imod
		i_year := n_year-1-iyear
	}
	Else {
		i_month := n_month-imod
		i_year := n_year-iyear
	}
	idate = %i_day%/%i_month%/%i_year%
	Return % idate
}

GETyearNyearAGO(N) 
{
	n_day := A_DD
	n_month := A_Mon
	n_year := A_Year-N
	idate = %n_year%/%n_month%/%n_day%
	Return % idate
}
;Function random dãy số không trùng nay
RandomNumRangeNotRepetition(a, N)
{
    Stringcheck := ""
    StringResult := ""
    idem = 1
    While (idem <= a)
    {
        random, r, 1, %N%
        IfInString,Stringcheck, %r%
            A++
        Else
        {
            StringResult .= r
            If (idem <> a)
                StringResult .= ","
        }
        Stringcheck .= r
        If (idem <> a)
            numStr .= ","
        Idem++
    }
    Return % StringResult
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
;<<- OPENEDMODULE
;Kiểm tra module có được mở hay chưa
OpenedModule(form_name)			
{
	IfWinNotExist, %form_name%
	{
		
        iString := SubStr(form_name, 15, StrLen(form_name)-14)
		MsgBox, 52, Lỗi, Chưa mở màn hình`n[%iString%]`n Mở ngay?
		IfMsgBox, Yes
			Return True
		Else
			Return False
	}
}

runModule(modulename,username)
{
	AH_tittle := "Tiếp nhận - Khám bệnh"
	Switch modulename
	{
		Case "INFOMED.HIS - TIẾP NHẬN - TIẾP NHẬN KHÁM BỆNH":
			moduletype := "TN"
			x1 := 190, y1 := 40, x2 := 30, y2 := 30
			form := "INFOMED.HIS - TIẾP NHẬN"
		Case "INFOMED.HIS - CẤP CỨU - TIẾP NHẬN KHÁM BỆNH":
			moduletype := "TN"
			x1 := 190, y1 := 40, x2 := 30, y2 := 30
			form := "INFOMED.HIS - CẤP CỨU"
		Case "INFOMED.HIS - KHÁM BỆNH - KHÁM BỆNH":
			moduletype := "KB"
			x1 := 55, y1 := 55, x2 := 30, y2 := 30
			form := "INFOMED.HIS - KHÁM BỆNH"
		Case "INFOMED.HIS - VIỆN PHÍ - TÍNH TIỀN VIỆN PHÍ":
			moduletype := "VP"
			x1 := 55, y1 := 40, x2 := 30, y2 := 30 
			form := "INFOMED.HIS - VIỆN PHÍ"
		Case "INFOMED.HIS - VIỆN PHÍ - QUYẾT TOÁN BẢO HIỂM":
			moduletype := "VP"
			x1 := 55, y1 := 40, x2 := 75, y2 := 40 
			form := "INFOMED.HIS - VIỆN PHÍ"
	}
	WinMinimize, %AH_tittle%
	run, %A_Desktop%\InfomedHIS.appref-ms
	WinWaitActive, Danh sách chức năng
	WinGet, OutputVar, ControlList, Danh sách chức năng
	Loop, Parse, OutputVar, `r`n
	{
		ControlGetText, myText, %A_LoopField%, Danh sách chức năng
		If (myText="Đăng nhập")
			btnOK := A_LoopField
	}
	Sleep 500
	Send %username%
	Sleep 300
	Send {tab}
	Sleep 300
	Send 123
	Sleep 300
	Send {Enter}
	Sleep 300
	IfWinActive, Thông báo
		Return
	Loop
	{
		Controlget, var, Enabled,, %btnOK%, Danh sách chức năng
		If (var=1)
			Break
	}
	ControlClick, %btnOK%, Danh sách chức năng
	If (modulename = "INFOMED.HIS - CẤP CỨU - TIẾP NHẬN KHÁM BỆNH") {
		Sleep 500
		ControlClick, x305 y131, Danh sách chức năng
	}
	WinWaitActive, %form%
	btnLogOut := ""
	Loop,
	{
		WinGet, tnlist, ControlList, %form%
		Loop, Parse, tnlist, `r`n
		{
			ControlGetText, myText, %A_LoopField%, %form%
			If (myText="Đăng xuất") {
				btnLogOut := A_LoopField
				Break
			}
		}
		If (btnLogOut<>"")
			Break
	}
	Loop
	{
		Controlget, var, Enabled,, %btnLogOut%, %form%
		If (var=1)
			Break
	}
	WinActivate, %form%
	Sleep 300
	MouseClick, Left, %x1%, %y1%
	Sleep 1000
	MouseClick, Left, %x2%, %y2%
	
	;Code đợi đến khi hoàn thành việc load xong form
	;Tìm control "Lưu"
	btnLuu := ""
	Loop,
	{
		WinGet, iList, ControlList, %modulename%
		Loop, Parse, iList, `n
		{
			ControlGetText, var, %A_LoopField%, %modulename%
			If (var = "Lưu") {
				btnLuu := A_LoopField
				Break
			}	
		}
		If (btnLuu <> "")
			Break
	}
	;Kiểm tra control "Lưu" đã load xong hay chưa 
	Loop
	{
		ControlGet, var, Enabled,, %btnLuu%, %modulename%
		If (var=1)
			Break
	}
}