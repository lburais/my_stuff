'
' Actions
'

Const lbUnlockSheets As Long = 1
Const lbLockSheets As Long = 2
Const lbCopyData As Long = 4
Const lbMergeData As Long = 8
Const lbExtractToFiles As Long = 16
Const lbCleanNames As Long = 32
Const lbExportHTML As Long = 64
Const lbNormalizeGraphs As Long = 128
Const lbSetRanges As Long = 256
Const lbSort As Long = 512
Const lbCalculate As Long = 1024
Const lbMessage As Long = 2048

Const lbNone = 0

Function GetSeparator() As String
    GetSeparator = Application.PathSeparator
End Function

'
' MACROS
'

Sub test()
    ret = Action(Range("lbWhat").Value)
End Sub

Sub Calculate_Macro()
    ret = Action(lbCalculate)
End Sub

Sub Set_Ranges_Macro()
    Dim StartTime As Double
    StartTime = Timer
    ret = fSetRanges()
    MsgBox "This code ran successfully in " & Round(Timer - StartTime, 2) & " seconds", vbInformation
End Sub

Sub To_HTML_Macro()
    Dim StartTime As Double
    StartTime = Timer
    ret = fExportHTML()
    MsgBox "This code ran successfully in " & Round(Timer - StartTime, 2) & " seconds", vbInformation
End Sub

Sub Extract_To_Files_Macro()
    Dim StartTime As Double
    StartTime = Timer
    Calculate
    ret = fUnlockSheets()
    ret = fSort()
    ret = fExtractToFiles()
    ret = fLockSheets()
    MsgBox "This code ran successfully in " & Round(Timer - StartTime, 2) & " seconds", vbInformation
End Sub

Sub Sheets_MergeData_Macro()
    Dim StartTime As Double
    StartTime = Timer
    ret = fMergeData()
    MsgBox "This code ran successfully in " & Round(Timer - StartTime, 2) & " seconds", vbInformation
End Sub

Sub Sheets_Lock_Macro()
    ret = fLockSheets()
End Sub

Sub Sheets_Unlock_Macro()
    ret = fUnlockSheets()
End Sub

Sub Sheets_CleanNames()
    ret = fCleanNames()
End Sub

Sub Sheets_Sachin_Macro()
    Dim StartTime As Double
    StartTime = Timer
    ret = fMergeData()
    MsgBox "This code ran successfully in " & Round(Timer - StartTime, 2) & " seconds", vbInformation
End Sub

' -----------------------------------------------
' HTML functions and procedures
' -----------------------------------------------

Function HTMLColor2RGB(c) As String
    S = Right$("000000" & Hex(c), 6)
    HTMLColor2RGB = Right(S, 2) & Mid(S, 3, 2) & Left(S, 2)
End Function

Function HTMLBorders(c As Range) As String
Dim shtml As String

shtml = ""
If (c.DisplayFormat.Borders(Excel.XlBordersIndex.xlEdgeRight).LineStyle <> xlNone) Or _
    (c.DisplayFormat.Borders(Excel.XlBordersIndex.xlEdgeLeft).LineStyle <> xlNone) Or _
        (c.DisplayFormat.Borders(Excel.XlBordersIndex.xlEdgeTop).LineStyle <> xlNone) Or _
            (c.DisplayFormat.Borders(Excel.XlBordersIndex.xlEdgeBottom).LineStyle <> xlNone) Then shtml = "border: 1px;"

HTMLBorders = shtml

End Function

Function HTMLMerge(c As Range) As String
Dim shtml As String

If (c.MergeCells) Then
    If (c.Address = c.MergeArea(1, 1).Address) Then
        shtml = "colspan='" & c.MergeArea.Columns.Count & "'"
    Else
        shtml = ""
    End If
Else
    shtml = " "
End If

HTMLMerge = shtml

End Function

Function HTMLFromTable(sTable As String) As String

Dim shtml, sstyle As String
Dim smerge As String
Dim rng As Range

Const FontSize = 10
shtml = "&nbsp;"

    On Error GoTo HTMLFromTableError

    Set rng = Range(sTable)

    shtml = "<table style='border: 1px solid #c6c6c6; margin-left: auto; margin-right: auto; border-width: 1; border-color: #c6c6c6; background-color: #ffffff; font-size: " & FontSize & "px; color: #000000;' width='100%'>"

    For i = 1 To rng.Rows.Count
        '---Rows---
        shtml = shtml & "<tr valign='top' nowrap>"
        For j = 1 To rng.Columns.Count
            '---Columns---
            smerge = HTMLMerge(rng(i, j))
            If (smerge <> "") Then
                shtml = shtml & "<td "
                If (smerge <> " ") Then shtml = shtml & smerge & " "

                sstyle = ""
                If (rng.Cells(i, j).DisplayFormat.Interior.color <> RGB(255, 255, 255)) Then sstyle = sstyle & "background-color: #" & HTMLColor2RGB(rng.Cells(i, j).DisplayFormat.Interior.color) & "; "
                If (rng.Cells(i, j).HorizontalAlignment = xlCenter) Then sstyle = sstyle & "text-align: center; "
                sstyle = sstyle & HTMLBorders(rng.Cells(i, j))
                If (sstyle <> "") Then shtml = shtml & "style='" & sstyle & "' "

                shtml = shtml & ">"
                sstyle = ""
                'If (rng.Cells(i, j).Font.size > FontSize) Then sstyle = sstyle & "font-size: " & rng.Cells(i, j).Font.size & "px; "
                If (rng.Cells(i, j).DisplayFormat.Font.color <> RGB(0, 0, 0)) Then sstyle = sstyle & "color: #" & HTMLColor2RGB(rng.Cells(i, j).DisplayFormat.Font.color) & "; "
                If (sstyle <> "") Then shtml = shtml & "<span style='" & sstyle & "'>"
                If (rng.Cells(i, j).DisplayFormat.Font.Bold) Then shtml = shtml & "<strong>"
                shtml = shtml & Replace(rng.Cells(i, j).Value, Chr(10), "<br>")
                If (rng.Cells(i, j).Font.Bold) Then shtml = shtml & "</strong>"
                If (sstyle <> "") Then shtml = shtml & "</span>"
               shtml = shtml & "</td>"
            End If
        Next j
        shtml = shtml & "</tr>"
    Next i
    shtml = shtml & "</table><p></p>"

HTMLFromTableError:
    On Error GoTo 0
    HTMLFromTable = shtml

End Function

Function HTMLExport()

Dim shtml As String
Dim v As Boolean

    v = Sheets("PUBLISH").Visible
    Sheets("PUBLISH").Visible = True
    Sheets("PUBLISH").Select

    filename = Range("FOLDER").Value & "Templates" & Application.PathSeparator & "CX Requisitions - Base.html"
    Open filename For Input As #1
    found = False
    Do Until (EOF(1) Or found)
        Line Input #1, textline
        shtml = shtml & textline
    Loop
    Close #1

    Range(Range("S_REQS").Cells(1, 1), Range("S_REQS").Cells(Range("nb_reqs").Value + 3 + 2, Range("S_REQS").Columns.Count)).Select
    Selection.Name = "S_REQS"
    shtml = ""
    shtml = shtml & "<p style='color: grey; font-size: 10px;'>" & Range("S_DATE").Value & "</p>"
    shtml = shtml & "<table style='border-width: 0px; background-color: white; width: 100%;'><tr style='background-color: #33BCEB;'>"
    shtml = shtml & "<td style='vertical-align: middle; text-align: center; color: white; font-size: 24px;'>"
    shtml = shtml & "<p><a name='reqs'></a>Requisitions status</p>"
    shtml = shtml & "</td></tr></table><p></p>"
    shtml = shtml & HTMLFromTable("S_REQS")

    ' Write files

    filename = Range("FOLDER").Value & "HTML" & Application.PathSeparator & "CX Requisitions Details.html"
    Open filename For Output As #1
    Print #1, shtml
    Close #1

    Sheets("PUBLISH").Visible = v

End Function

'
' ACTIONS
'

Function fUnlockSheets() As Boolean
    For Each sh In ActiveWorkbook.Worksheets
        sh.Visible = True
        sh.Unprotect
    Next sh
End Function

Function fLockSheets() As Boolean
        Sheets(Range("THIS").Value).Visible = True
        Sheets(Range("THIS").Value).Unprotect
        Sheets(Range("THIS").Value).Activate

        For Each sh In ActiveWorkbook.Worksheets

            If (sh.Name <> Range("THIS").Value) Then
                bVisible = False
                bProtect = True

                For i = 2 To Range("R_lock").Rows.Count
                    If (Range("R_lock").Cells(i, 1).Value = sh.Name) Then
                        bVisible = Range("R_lock").Cells(i, 2).Value
                        bProtect = Range("R_lock").Cells(i, 3).Value
                        Exit For
                    End If
                Next i

                If (bProtect) Then
                    sh.Protect DrawingObjects:=True, Contents:=True, Scenarios:=True
                    sh.EnableSelection = xlUnlockedCells
                Else
                    sh.Unprotect
                End If

                sh.Visible = bVisible
            End If

        Next sh

        Sheets(Range("THIS").Value).Protect DrawingObjects:=True, Contents:=True, Scenarios:=True
        Sheets(Range("THIS").Value).EnableSelection = xlUnlockedCells
        ' Sheets(Range("THIS").Value).Visible = False
        Sheets("ACTIVE").Activate
End Function

Function fSetRanges() As Boolean
ret = fUnlockSheets()
  If Sheets(Range("Sgrr_name").Value).FilterMode Then
      Sheets(Range("Sgrr_name").Value).ShowAllData
  End If
  Sheets(Range("Sgrr_name").Value).Activate
  Range("A1").Select
  Range(Selection, Selection.End(xlToRight)).Select
  Selection.Name = "Sgrr_header"
  Range(Selection, Selection.End(xlDown)).Select
  Selection.Name = "Sgrr_data"

  If Sheets(Range("Sneeds_name").Value).FilterMode Then
      Sheets(Range("Sneeds_name").Value).ShowAllData
  End If
  Sheets(Range("Sneeds_name").Value).Activate
  Range("A1").Select
  Range(Selection, Selection.End(xlToRight)).Select
  Selection.Name = "Sneeds_header"
  Cells(1, Range("Sneeds_header").Columns.Count).Select
  Range(Selection, Selection.End(xlDown)).Select
  Range(Selection, Selection.End(xlToLeft)).Select
  Selection.Name = "Sneeds_data"

  If Sheets(Range("Sfilled_name").Value).FilterMode Then
      Sheets(Range("Sfilled_name").Value).ShowAllData
  End If
  Sheets(Range("Sfilled_name").Value).Activate
  Range("A1").Select
  Range(Selection, Selection.End(xlToRight)).Select
  Selection.Name = "Sfilled_header"
  Range(Selection, Selection.End(xlDown)).Select
  Selection.Name = "Sfilled_data"

  If Sheets(Range("Sactive_name").Value).FilterMode Then
      Sheets(Range("Sactive_name").Value).ShowAllData
  End If
  Sheets(Range("Sactive_name").Value).Activate
  Range("C1").Select
  Selection.End(xlDown).Select
  active_last = Selection.Row()
  Range(Range("Sactive_data").Cells(1, 1), Range("Sactive_data").Cells(active_last, Range("Sactive_data").Columns.Count)).Select
  Selection.Name = "Sactive_data"

  Dim ListOf As Variant
  Sheets(Range("Sactive_name").Value).Activate
  ListOf = Array("D_grr", "D_needs", "D_filled", "D_cancelled", "D_rows", "D_finances", "D_reqs", "D_smartsheet", "S_REQS", _
                         "R_analysis", "R_approver", "R_criteria", "R_cx_l1", "R_dept", "R_descr", "R_needs", "R_notes", "R_order", "R_reco", "R_reqnum", "R_review")
  For i = LBound(ListOf) To UBound(ListOf)
      Range(Range(ListOf(i)).Cells(1, 1), Range(ListOf(i)).Cells(Range("Sactive_data").Rows.Count, Range(ListOf(i)).Columns.Count)).Select
      Selection.Name = ListOf(i)
  Next i

  Sheets(Range("Sneeds_name").Value).Activate
  ListOf = Array("R_ASid", "R_ASid_row", "R_jobid", "R_jobid_row", "R_needs_action")
  For i = LBound(ListOf) To UBound(ListOf)
      Range(Range(ListOf(i)).Cells(1, 1), Range(ListOf(i)).Cells(Range("Sneeds_data").Rows.Count, Range(ListOf(i)).Columns.Count)).Select
      Selection.Name = ListOf(i)
  Next i

  Sheets(Range("Sgrr_name").Value).Activate
  ListOf = Array("R_addgrr", "R_grrjobid")
  For i = LBound(ListOf) To UBound(ListOf)
      Range(Range(ListOf(i)).Cells(1, 1), Range(ListOf(i)).Cells(Range("Sgrr_data").Rows.Count, Range(ListOf(i)).Columns.Count)).Select
      Selection.Name = ListOf(i)
  Next i
End Function

Function fMergeData() As Boolean
nb = 1

Calculate
ret = fSetRanges()

Sheets(Range("Sactive_name").Value).Activate
last_active = Range("R_reqnum").Rows.Count

For rneeds = 2 To Range("R_needs_action").Rows.Count
    If (Range("R_needs_action").Cells(rneeds, 1).Value = "ADD") Then
        Sheets(Range("Sactive_name").Value).Activate
        Rows(last_active).Select
        Selection.Copy
        ractive = last_active + nb
        Sheets(Range("Sactive_name").Value).Activate
        Rows(ractive).Select
        ActiveSheet.Paste
        Cells(ractive, 1).Select
        Selection.Value = Range("R_jobid").Cells(rneeds, 1).Value
        Cells(ractive, 2).Select
        Selection.Value = Range("R_ASid").Cells(rneeds, 1).Value
        nb = nb + 1
    Else
        If (Range("R_needs_action").Cells(rneeds, 1).Value = "JOBID") Then
            ractive = Range("R_ASid_row").Cells(rneeds, 1).Value
            Sheets(Range("Sactive_name").Value).Activate
            Cells(ractive, 1).Select
            Selection.Value = Range("R_jobid").Cells(rneeds, 1).Value
        Else
            If (Range("R_needs_action").Cells(rneeds, 1).Value = "ASID") Then
                ractive = Range("R_jobid_row").Cells(rneeds, 1).Value
                Sheets(Range("Sactive_name").Value).Activate
                Cells(ractive, 2).Select
                Selection.Value = Range("R_ASid").Cells(rneeds, 1).Value
            Else
                If (Range("R_needs_action").Cells(rneeds, 1).Value = "ASID2") Then
                    ractive = Range("R_jobid_row2").Cells(rneeds, 1).Value
                    Sheets(Range("Sactive_name").Value).Activate
                    Cells(ractive, 2).Select
                    Selection.Value = Range("R_ASid").Cells(rneeds, 1).Value
                End If
           End If
        End If
    End If
 Next rneeds

 Calculate

 For rgrr = 2 To Range("R_addgrr").Rows.Count
    If (Range("R_addgrr").Cells(rgrr, 1).Value = True) Then
        Sheets(Range("Sactive_name").Value).Activate
        Rows(last_active).Select
        Selection.Copy
        ractive = last_active + nb
        Sheets(Range("Sactive_name").Value).Activate
        Rows(ractive).Select
        ActiveSheet.Paste
        Cells(ractive, 1).Select
        Selection.Value = Range("R_grrjobid").Cells(rgrr, 1).Value
        Cells(ractive, 2).Value = ""
        nb = nb + 1
    End If
Next rgrr

Calculate

ret = fSetRanges()

Calculate

End Function

Function fCleanNames() As Boolean
    Sheets(Range("THIS").Value).Activate
    cclean = Range("CLEAR_NAMES").Column + 1
    rclean = 1

    Range(Columns(cclean), Columns(cclean + 5)).Select
    Selection.ClearContents

    Cells(1, cclean + 0).Value = "Name"
    Cells(1, cclean + 1).Value = "Reference"
    Cells(1, cclean + 2).Value = "Parent Name"
    Cells(1, cclean + 3).Value = "First Value"
    Cells(1, cclean + 4).Value = "Action"
    Cells(1, cclean + 5).Value = "Status"

     On Error GoTo nm_delete
     For Each Nm In ActiveWorkbook.Names
        rclean = rclean + 1
        Cells(rclean, cclean + 0).Value = Nm.Name
        Cells(rclean, cclean + 1).Value = Nm
        Cells(rclean, cclean + 2).Value = Nm.RefersToRange.Parent.Name
        Cells(rclean, cclean + 3).Value = Nm.RefersToRange.Cells(1, 1).Value
        If (InStr(Nm.Name, "Print_Area") > 0) Then
            force_delete_through_error = 1 / 0
        End If
        If (InStr(Nm.Name, "_FilterDatabase") > 0) Then
            force_delete_through_error = 1 / 0
        End If
nm_next:
    Next Nm

    On Error GoTo 0
    GoTo nm_end

nm_delete:
    On Error Resume Next
    'If (Left(Nm.Name, 1) <> "_") Then Nm.Delete
    Cells(rclean, cclean + 4).Value = "delete"
    On Error GoTo nm_delete
Resume nm_next

nm_end:

End Function

Function fSort() As Boolean
        Sheets(Range("Sactive_name").Value).Activate
        Cells.Select
        Application.CutCopyMode = False
        ActiveWorkbook.Worksheets(Range("Sactive_name").Value).sort.SortFields.Clear
        ActiveWorkbook.Worksheets(Range("Sactive_name").Value).sort.SortFields.Add Key:=Range("R_Order"), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
        With ActiveWorkbook.Worksheets(Range("Sactive_name").Value).sort
            .SetRange Range("Sactive_data")
            .Header = xlYes
            .MatchCase = False
            .Orientation = xlTopToBottom
            .SortMethod = xlPinYin
            .Apply
        End With
End Function

Function fExport() As Boolean
    ret = fSort()
    ret = fExtractToFiles()
    ret = fExportHTML()
End Function

Function fExportHTML() As Boolean
    Dim shtml As String
    Dim v As Boolean

    ret = fSort()

    Range(Range("S_REQS").Cells(1, 1), Range("S_REQS").Cells(Range("nb_reqs").Value + 3 + 2, Range("S_REQS").Columns.Count)).Select
    Selection.Name = "S_REQS2"

    shtml = ""
    shtml = shtml & "<table style='border-width: 0px; background-color: white; width: 100%;'><tr style='background-color: #33BCEB;'>"
    shtml = shtml & "<td style='vertical-align: middle; text-align: center; color: white; font-size: 24px;'>"
    shtml = shtml & "<p>Requisitions status</p>"
    shtml = shtml & "</td></tr>"
    shtml = shtml & "<tr style='vertical-align: top; text-align: left; color: grey; font-size: 10px;'><td>"
    shtml = shtml & "<p>" & Replace(Range("S_SUMMARY").Value, Chr(10), "<br>") & "</p>"
    shtml = shtml & "</td></tr></table><p></p>"
    shtml = shtml & HTMLFromTable("S_REQS2")

    ' Write files

    filename = Range("FOLDER").Value & "HTML" & Application.PathSeparator & "CX Requisitions Details.html"
    Open filename For Output As #1
    Print #1, shtml
    Close #1

End Function

Function fExtractToFiles() As Boolean

    Dim wb As Workbook
    Dim wbc As Workbook
    Dim ws As Worksheet

    Sheets(Range("Sactive_name").Value).Activate
    Range("D_reqs").Select
    Selection.Copy

    Set wbc = ActiveWorkbook
    Set wb = Workbooks.Open(Range("REQS_TEMPLATE").Value)
    Set ws = wb.Sheets.Add

    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
    Selection.PasteSpecial Paste:=xlPasteFormats, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
    Selection.PasteSpecial Paste:=xlPasteColumnWidths, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
    Application.CutCopyMode = False

    Application.DisplayAlerts = False
    wb.Sheets("EXTRACT").Delete
    Application.DisplayAlerts = True

    ws.Name = "EXTRACT"

    If (wbc.Range("REQS_PUBLISH").Value = wbc.Range("REQS_TEMPLATE").Value) Then
        wb.Save
    Else
        wb.SaveAs filename:=wbc.Range("REQS_PUBLISH").Value
    End If
    wb.Close

End Function

Function Action(what As String) As Variant

    Dim StartTime As Double

    ThisWorkbook.Activate

    StartTime = Timer

Select Case what

    Case lbCalculate
        ' Calculate
        Calculate

        Case lbLockSheets
            ret = fLockSheets()

            Case lbUnlockSheets
                ret = fUnlockSheets()

    Case lbSetRanges
      ret = fSetRanges()

    Case lbMergeData
      ret = fMergeData()

    Case lbSort
      ret = fSort()

    Case lbCleanNames
      ret = fCleanNames()

   Case lbExportHTML
      ret = fExportHTML()

    Case lbExtractToFiles
      ret = fExtractToFiles()


    Case Else
        MsgBox "Unknown command " & what, vbInformation

    End Select

    Action = Array(StartTime, Timer)
End Function
