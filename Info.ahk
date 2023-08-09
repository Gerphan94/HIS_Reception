#NoEnv
#NoTrayIcon
FileEncoding, utf-8

AHK_Title := "Thông tin mã tắt"

; Gui, Font, s13 cNavy BOLD
; Gui, Add, Text, , % "Thông tin mã tắt"
Gui, Font
Gui, Add, Text,,
;Gui, Add, Groupbox, r10 w280
Gui, Add, ListView, w400 h200 vMYLIST, % "Key|Module|Menu|Field"
    LV_ModifyCol(1, " 80 Left")
    LV_ModifyCol(2, " 100 Center")
    LV_ModifyCol(3, " 100 Center")
    LV_ModifyCol(4, " 100 Center")

init_list()
Gui, Show,, % AHK_Title
return

init_list()
{
    thau := ["=thau","Dược","Thêm thầu mới","Tên đợt thầu"]
    lo := ["=lo","Dược","Nhập NCC","Lô SX"]
    hd := ["=hd","Dược","Nhập NCC","Số hóa đơn"]
    kb := ["=kb","Khám bệnh","Khám bệnh","Triệu chứng"]
    LV_Delete()
    LV_Add("", thau[1] ,thau[2],thau[3], thau[4] )
    LV_Add("", lo[1] , lo[2], lo[3], lo[4] )
    LV_Add("", hd[1] , hd[2], hd[3], hd[4] )
    LV_Add("", kb[1] , kb[2], kb[3], kb[4] )
    return
    
}