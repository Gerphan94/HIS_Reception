#NoEnv
#NoTrayIcon
#SingleInstance, ignore
FileEncoding, utf-8

Global g_arr := {} , g_arrHEX := {} , g_arrAddr := {}
Global path := A_ScriptDir . "\data\qrcode"

Global N := 0
Gui, Font, s14 Bold cNavy
Gui, Add, Text, x20 y20, % "QR Code"
Gui, Font
Gui, Font, s11
Gui, Add, DropDownList, x250 y20 w200 choose1, % "QĐ 1313/QĐ-BHXH-2014"
;Gui, Add, DropDownList, x250 y20 w200, % "QĐ 1313/QĐ-BHXH-2014||QĐ 1666/QĐ-BHXH-2020"
Gui, Add, Groupbox, x20 y50 w430 h50
Gui, Add, Text, x30 y65 h24 +0x200 , % "Đầu thẻ:"
Gui, ADd, DropDownList, x90 y65 w50 vddlDT, % "|1|2|3|4|5"
Gui, Add, Text, x170 y65 h24 +0x200 , % "Khu vực:"
Gui, ADd, DropDownList, x230 y65 w70 vddlKV, % "|KV 1|KV 2|KV 3"
Gui, Add, Button, x360 y65 w70 h28 gbtnCreate, % "Tạo"
Gui, Font
Gui, Font, s9
Gui, Add, ListView, x20 y110 w430 h150 +Grid -Multi -hdr vmyLV gmyLV +AltSubmit, % "Name|QRCode"
	LV_ModifyCol(1, "120 Left")
	LV_ModifyCol(2, "280 Left")

Gui, Add, Edit, x20 y270 w430 h50 vedt +ReadOnly cMaroon
Gui, Add, Button, x380 y330 w70 h28 gbtnCopy, % "Copy"
Gui, Add, StatusBar
initAddrArr()
initArray()
initHexArr()
writeLV(N)
Gui, Show,, % "QRCode Creater"
Return

GuiClose:
GuiEscape:
    ExitApp

initArray()
{
    g_arr := {}
    Loop, 
    {
        tmpAR := []
        FileReadLine, OutputVar, % path, % A_index
        If ErrorLevel
            Break
        Loop, Parse, OutputVar, CSV
        {
            If (A_index = 1)
                Str1 := A_LoopField
            Else
                Str2 := A_LoopField
        }
        g_arr.push({1:Str1, 2:Str2})
    }
    N := g_arr.Length()
    Return
}

myLV:
    ;Gui, Submit, NoHide
    Gui, Listview, myLV
    If (A_GuiEvent = "Normal")
    {
        iRow := A_EventInfo
        LV_GetText(OutputVar, iRow, 2)
        GuiControl, , edt, % OutputVar
    }
    Return

writeLV(k)
{
    i := k
    If ( k > 8)
        m := k - 8
    Else
        m := k

    LV_Delete()
    While (i > m)
    {
        LV_Add("", g_arr[i][1], g_arr[i][2])      
        i := i - 1
    }
    SB_SetText("  " . k)
    Return
}
btnCreate:
    Gui, Submit, Nohide
    Gui, Listview, 6_lv
    LV_Delete()
    random, r, 1,2
    iname := fn_CreatePersonName(r).hovaten
    bday := RandomDate(GETyearNyearAGO(90) ,GETyearNyearAGO(6),"dd/MM/yyyy")
    iadd := fn_randChoice(g_arrAddr)
    If (ddlDT = "")
        DT := 0
    Else
        DT := ddlDT
    BHYT := fn_CreateBHYTCode(DT)
    bhyt_code := BHYT.bhytcode
    MH := SubStr(bhyt_code, 3, 1)
    Switch % ddlKV
    {
        Case "":
            KV := 4
        Case "KV 1":
            KV := 5
        Case "KV 2":
            KV := 6
        Case "KV 3":
            KV := 7
    }
    HEXString := bhyt_code . "|" . fn_text2Hex(iname) . "|" . bday . "|" . r . "|" . fn_text2Hex(iadd) . "|" . BHYT.hoscode . "|01/01/2022|31/12/2022|01/01/2020||-|" . KV . "| 01/01/2025||$"
    tmpStr := iname . "," . HEXString
    FileAppend, % tmpStr . "`n", % path
    Guicontrol,, edt, % HEXString
    g_arr.Push({1:iname, 2:HEXString})
    N := N + 1
    writeLV(N)
    SB_SetText("  " . N + 1)
    Return

btnCopy:
    Gui, Submit, NoHide
    If ( edt != "") {
        Clipboard := edt
        SB_SetText("Copy thành công")
    }
    Return

fn_text2Hex(string)
{
    Loop, parse, string,
    {
        tmp := A_LoopField
        If ( tmp = " ")
            result .= 20
        Else
        {
            Loop, % g_arrHEX.Length()
            {
                If ( Asc(g_arrHEX[A_Index][1]) = Asc(tmp)) 
                    result .= g_arrHEX[A_Index][2]
            }
        }
    }
    Return, result
}
initAddrArr()
{
    addString := "Alexandre de Rhodes,Bà Lê Chân,Bùi Thị Xuân,Bùi Viện,Cách Mạng Tháng Tám,Calmette,Cao Bá Nhạ,Cao Bá Quát,Cô Bắc,Cô Giang,Cống Quỳnh,Chu Mạnh Trinh,Chương Dương,Đặng Dung,Đặng Tất,Đặng Thị Nhu,Đặng Trần Côn,Đề Thám,Đinh Công Tráng,Đông Du,Đồng Khởi,Hai Bà Trưng,Hải Triều,Hàm Nghi,Hàn Thuyên,Hòa Mỹ,Hồ Hảo Hớn,Hồ Huấn Nghiệp,Hồ Tùng Mậu,Hoàng Sa,Huyền Quang,Huyền Trân Công Chúa,Huỳnh Khương Ninh,Huỳnh Thúc Kháng,Ký Con,Lê Anh Xuân,Lê Công Kiều,Lê Duẩn,Lê Lai,Lê Lợi,Lê Thánh Tôn,Lê Thị Hồng Gấm,Lê Thị Riêng,Lê Văn Hưu,Lương Hữu Khánh,Lưu Văn Lang,Lý Tự Trọng,Lý Văn Phức,Mã Lộ,Mạc Đĩnh Chi,Mạc Thị Bưởi,Mai Thị Lựu,Nam Kỳ Khởi Nghĩa,Nam Quốc Cang,Ngô Đức Kế,Ngô Văn Năm,Nguyễn Bỉnh Khiêm,Nguyễn Cảnh Chân,Nguyễn Công Trứ,Nguyễn Cư Trinh,Nguyễn Du,Nguyễn Đình Chiểu,Nguyễn Huệ,Nguyễn Hữu Cảnh,Nguyễn Hữu Cầu,Nguyễn Huy Tự,Nguyễn Khắc Nhu,Nguyễn Phi Khanh,Nguyễn Thái Bình,Bà Huyện Thanh Quan,Bàn Cờ,Cách Mạng Tháng Tám,Cao Thắng,Điện Biên Phủ,Đoàn Công Bửu,Hai Bà Trưng,Hồ Xuân Hương,Huỳnh Tịnh Của,Kỳ Đồng,Lê Ngô Cát,Lê Quý Đôn,Nguyễn Văn Trỗi,Lê Văn Sỹ,Lý Chính Thắng,Lý Thái Tổ,Cao Thắng,Cầm Bá Thước,Cô Bắc,Cô Giang,Chiến Thắng,Duy Tân,Đào Duy Anh,Đào Duy Từ,Đặng Thai Mai,Đặng Văn Ngữ,Đoàn Thị Điểm,Đỗ Tấn Phong,Hải Nam,Hoàng Diệu,Hoàng Minh Giám,Hoàng Văn Thụ,Hồ Biểu Chánh,Hồ Văn Huê,Huỳnh Văn Bánh,Lam Sơn,Lê Quý Đôn,Nguyễn Văn Trỗi,Lê Văn Sỹ,Mai Văn Ngọc,Ngô Thời Nhiệm,Nguyễn Đình Chiểu,Nguyễn Đình Chính,Nguyễn Kiệm,Nguyễn Thị Huỳnh,Nguyễn Trọng Tuyển,Nguyễn Trường Tộ,Nguyễn Văn Đậu,Nam Kỳ Khởi Nghĩa,Nguyễn Văn Trỗi,Nhiêu Tứ,Phan Đăng Lưu,Phan Đình Phùng,Phan Tây Hồ,Phan Xích Long,Phổ Quang,Thích Quảng Đức,Trần Cao Vân,Trần Huy Liệu,Trần Hữu Trang,Trần Kế Xương,Trần Khắc Chân,Trần Văn Đang,Trương Quốc Dung,"
    Loop, Parse, addString, CSV
    {
        g_arrAddr.Push(A_LoopField)
    }
    Return
}

initHexArr()
{
    istring := "a,61|b,62|c,63|d,64|e,65|f,66|g,67|h,68|i,69|j,6a|k,6b|l,6c|m,6d|n,6e|o,6f|p,70|q,71|r,72|s,73|t,74|u,75|v,76|w,77|x,78|y,79|z,7a|A,41|B,42|C,43|D,44|E,45|F,46|G,47|H,48|I,49|J,4a|K,4b|L,4c|M,4d|N,4e|O,4f|P,50|Q,51|R,52|S,53|T,54|U,55|V,56|W,57|X,58|Y,59|Z,5a|Đ,c490|đ,c491|É,c389|È,c388|Ẻ,e1baba|Ẹ,e1bab8|é,c3a9|è,c3a8|ẻ,c3a8|ẹ,e1bab9|Ê,c38a|Ế,e1babe|Ề,e1bb80|Ể,e1bb82|Ễ,e1bb84|Ệ,e1bb86|ê,c3aa|ế,e1babf|ề,e1bb81|ể,e1bb83|ễ,e1bb85|ệ,e1bb87|Í,c38d|Ì,c38c|Ị,e1bb8a|í,c3ad|ì,c3ac|ị,e1bb8b|Ó,c393|Ò,c392|Ỏ,e1bb8e|Õ,c395|Ọ,e1bb8c|ó,c3b3|ò,c3b2|ỏ,e1bb8f|õ,c3b5|ọ,e1bb8d|Ô,c394|Ố,e1bb90|Ồ,e1bb92|Ổ,e1bb94|Ỗ,e1bb96|Ộ,e1bb98|ô,c3b4|ố,e1bb91|ồ,e1bb93|ổ,e1bb95|ỗ,e1bb97|ộ,e1bb99|Ơ,c6a0|Ớ,e1bb9a|Ờ,e1bb9c|Ở,e1bb9e|Ỡ,e1bba0|Ợ,e1bba2|ơ,c6a1|ớ,e1bb9b|ờ,e1bb9d|ở,e1bb9f|ỡ,e1bba1|ợ,e1bba3|Ú,c39a|Ù,c399|Ủ,e1bba6|Ũ,c5a8|Ụ,e1bba4|ú,c3ba|ù,c3b9|ủ,e1bba7|ũ,c5a9|ụ,e1bba5|Ư,c6af|Ứ,e1bba8|Ừ,e1bbaa|Ử,e1bbac|Ữ,e1bbae|Ự,e1bbb0|ư,c6b0|ứ,e1bba9|ừ,e1bbab|ử,e1bbad|ữ,e1bbaf|ự,e1bbb1|Ý,c39d|Ỳ,e1bbb2|Ỷ,e1bbb6|Ỹ,e1bbb8|ý,c3bd|ỳ,e1bbb3|ỷ,e1bbb7|ỹ,e1bbb9|/,2f|,,2c|0,30|1,31|2,32|3,33|4,34|5,35|6,36|7,37|8,38|9,39|:,3a|;,3b|<,3c|=,3d|>,3e|?,3f|@,40|Á,c381|À,c380|Ả,e1baa2|Ã,c383|Ạ,e1baa0|á,c3a1|à,c3a0|ả,e1baa3|ã,c3a3|ạ,e1baa1|Ă,c482|Ắ,e1baae|Ằ,e1bab0|Ẳ,e1bab2|Ẵ,e1bab4|Ặ,e1bab6|ă,c483|ắ,e1baaf|ằ,e1bab1|ẳ,e1bab3|ẵ,e1bab5|ặ,e1bab7|Â,c382|Ấ,e1baa4|Ầ,e1baa6|Ẩ,e1baa8|Ẫ,e1baaa|Ậ,e1baac|â,c3a2|ấ,e1baa5|ầ,e1baa7|ẩ,e1baa9|ẫ,e1baab|ậ,e1baad"
    Loop, Parse, istring, `|
    {
        tmpString := A_LoopField
        Loop, Parse, tmpString, `,
        {
            if (A_Index = 1)
                Str1 := A_LoopField
            Else
                Str2 := A_LoopField
        }
        g_arrHEX.Push({1:str1, 2:str2})
    }
    Return
}

fn_CreatePersonName(Gend)
{
	;Data
	firstname_arr := ["Nguyễn","Bùi","Nguyễn","Châu","Đặng","Nguyễn","Đinh","Đỗ","Đoàn","Dương","Hà","Hồ","Hứa","Huỳnh","Lê","Lý","Mạc","Mai","Ngô","Nguyễn","Phạm","Phan","Quách","Tăng","Thạch","Thái","Tô","Tôn","Trần","Triệu","Trịnh","Trương","Võ","Vương", "Cồ","H'", "Đàm"]
	midname_male_arr := ["Ngọc", "Minh", "Bảo","Văn","Gia","Hoàng","Thiên","Khánh","Thái","Tuấn"]
	midname_female_arr := ["Hồng","Thị","Thị","Thị","Thị","Thị","Thị"]
	lastname_male_arr := ["An","Anh","Bảo","Bình","Biên","Công","Chung","Cường","Danh","Du","Duy","Dũng","Dương","Đường","Đạt","Được","Đăng","Định","Đức","Hoài","Hoàng","Hải","Hùng","Huy","Hậu","Huấn","Hưng","Kiên","Linh","Lương","Lăng","Ly","Long","Mạnh","Minh","Mẫn","Nam","Năm","Nghị","Phúc","Phước","Phong","Phi","Quyền","Quãng","Tư","Tứ","Tuấn","Tùng","Tấn","Tiến","Toàn","Thịnh","Thông","Thương","Tài","Thắng","Thanh","Vũ","Vy","Văn"]
	lastname_female_arr := ["Ánh","Bống","Chi","Chung","Châu","Dung","Dương","Duyên","Hằng","Hoài","Hương","Hai","Hạnh","Hồng","Hoa","Kiều","Linh","Lan","Ly","Liễu","Mai","Mơ","Nhung","Nhi","Như","Nga","Ngân","Phượng","Phương","Quyên ","Tình","Tư","Thương","Thảo","Thơ","Thơm","Thi","Thúy","Thủy","Thanh","Uyên","Yến","Vân Anh","Bảo Anh","Kiều Anh","Ngọc Anh","Trâm Anh","Trà Long","Trà My","Gia Mỹ","Kiều Tiên","Thúy Kiều ","Thúy Vân","Vân Kiều"]
	;--------------------------------------
    F_name := fn_randChoice(firstname_arr)
    If (Gend = 1) {
        M_name := fn_randChoice(midname_male_arr)
        L_Name := fn_randChoice(lastname_male_arr)
    }
    Else {
        M_name := fn_randChoice(midname_female_arr)
        L_Name := fn_randChoice(lastname_female_arr)
    }
    Full_name := F_name . " " . M_name . " " . L_Name
    Return, {HovaTen:Full_name, Ho:F_name, Lot:M_name, Ten:L_Name}
}
fn_CreateBHYTCode(DT)
{
	ar_BHYT0 := ["DN4","HX4","CH4","NN4","TK4","HC4","XK4","TB4","NO4","XB4","TN4","CS4","XN4","MS4","HD4","TQ4","TA4","TY4","HG4","LS4","PV4","GB4","GD4","HT3","TC3","CN3","CC1","CT2","CK2","CB2","KC2","HN2","DT2","DK2","XD2","BT2","TS2","QN5","CA5","CY5"]
    ar_BHYT1 := ["CC1", "TE1"]
    ar_BHYT2 := ["CK2","CB2","KC2","HN2","DT2","DK2","XD2","BT2","TS2","CT2"]
    ar_BHYT3 := ["HT3","TC3","CN3"]
    ar_BHYT4 := ["DN4","HX4","CH4","NN4","TK4","HC4","XK4","TB4","NO4","XB4","TN4","CS4","XN4","MS4","HD4","TQ4","TA4","TY4","HG4","LS4","PV4","GB4","GD4"]
    ar_BHYT5 := ["QN5","CA5","CY5"]
	code := ["79 - 011","75 - 011","79 - 012","79 - 013","79 - 014","79 - 015","79 - 016"]
    maBV := fn_randChoice(code)
    maTinh := SubStr(maBV, 1, 2)  
    Switch % DT
    {
        Case "0":
            bhyt := fn_randChoice(ar_BHYT0) . maTinh . RandomNumRange(10)
        Case "1":
            bhyt := fn_randChoice(ar_BHYT1) . maTinh . RandomNumRange(10)
        Case "2":
            bhyt := fn_randChoice(ar_BHYT2) . maTinh . RandomNumRange(10)
        Case "3":
            bhyt := fn_randChoice(ar_BHYT3) . maTinh . RandomNumRange(10)
        Case "4":
            bhyt := fn_randChoice(ar_BHYT4) . maTinh . RandomNumRange(10)
        Case "5":
            bhyt := fn_randChoice(ar_BHYT5) . maTinh . RandomNumRange(10)
    }
	FromDate := RandomDate(GETyearNyearAGO(1) ,GETyearNyearAGO(0) ,"ddMMyyyy")
	ToDate := SubStr(FromDate, 1, 4) . SubStr(FromDate, 5, 4)+1
    Return, {bhytcode:bhyt, hoscode:maBV, fromdate:FromDate, todate:ToDate}
}
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
fn_randChoice(arr)
{
	arr_len := arr.Length()
	Random, r, 1, % arr_len
	return, arr[r]
}
RandomNumRange(len, i = 48, x = 57)  ; length, lowest and highest Asc value
{
	Loop, % len
	{
		Random, r, i, x
		s .= Chr(r)
	}
	Return, s
}