--------------------------------------------------------
--  DDL for Package Body IGI_IAC_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_WEBADI_PKG" AS
-- $Header: igiiasab.pls 120.10.12010000.2 2009/09/03 11:09:13 dramired ship $
   l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;

   Cursor C_File_Transferred(
             cp_file_name IN igi_iac_upload_headers.file_name%type) Is
   Select 'X'
   From igi_iac_upload_headers
   Where file_name = cp_file_name
   and status_flag = 'T';

   Cursor C_Asset_Exists(cp_file_name IN igi_iac_upload_headers.file_name%type,
                         cp_asset_number IN fa_additions.asset_number%type) Is
   Select hd.Book_Type_Code,
      hd.Period_Counter,
      hd.Currency_Code,
      hd.Status_Flag Hdr_Status_Flag,
      hd.Tolerance_Flag,
      hd.Tolerance_Amount,
      hd.Tolerance_Percent,
      hd.Revaluation_Id,
      ln.Asset_Id,
      ln.Line_Num,
      ln.Category_Id,
      ln.Original_Cost,
      ln.New_Cost,
      ln.status_flag Line_Status_Flag,
      ln.Gross_Flag,
      ln.Percentage_Diff,
      ln.Amount_Diff,
      ln.Exception_Message,
      ln.Comments
   From igi_iac_upload_headers hd,
        igi_iac_upload_lines ln,
        fa_additions fa
   Where fa.asset_number = cp_asset_number
   and hd.file_name = cp_file_name
   and ln.file_name = hd.file_name
   and ln.asset_id = fa.asset_id;

   Cursor C_Excpt_Asset(cp_file_name IN igi_iac_upload_headers.file_name%type,
                        cp_asset_number IN fa_additions.asset_number%type,
                        cp_line_num IN igi_iac_upload_lines.line_num%type) Is
   Select hd.Book_Type_Code,
      hd.Period_Counter,
      hd.Currency_Code,
      hd.Status_Flag Hdr_Status_Flag,
      hd.Tolerance_Flag,
      hd.Tolerance_Amount,
      hd.Tolerance_Percent,
      hd.Revaluation_Id,
      ln.Asset_Id,
      ln.Line_Num,
      ln.Category_Id,
      ln.Original_Cost,
      ln.New_Cost,
      ln.status_flag Line_Status_Flag,
      ln.Gross_Flag,
      ln.Percentage_Diff,
      ln.Amount_Diff,
      ln.Exception_Message,
      ln.Comments
   From igi_iac_upload_headers hd,
        igi_iac_upload_lines ln,
        fa_additions fa
   Where fa.asset_number = cp_asset_number
   and hd.file_name = cp_file_name
   and ln.file_name = hd.file_name
   and ln.asset_id = fa.asset_id
   and ln.line_num = cp_line_num;

   -- Bug 3413035 Start
   Cursor C_Full_Ret_Counter(
             cp_book_type_code in igi_iac_upload_headers.book_type_code%type,
             cp_asset_id in fa_books.asset_id%type) Is
   Select bk.period_counter_fully_retired
   From fa_books bk
   Where bk.book_type_code = cp_book_type_code
   and bk.asset_id = cp_asset_id
   and bk.transaction_header_id_out is null;
   -- Bug 3413035 End

   l_global_date date := sysdate;
   l_global_user_id number := fnd_global.user_id;
   l_global_login_id number := fnd_global.login_id;

   E_Iac_Not_Enabled  exception;
   E_File_Trans exception;
   E_Invalid_Asset exception;
/*
   Procedure Debug(p_debug in varchar2, p_print in boolean := TRUE) Is
   Begin
      If p_print Then
         fnd_file.put_line(fnd_file.log, p_debug);
      End If;
   End;
*/
   Function Last_Period_Counter(
               p_asset_id IN fa_books.asset_id%type,
               p_book_type_code IN igi_iac_upload_headers.book_type_code%type,
               p_dpis_period_counter IN number,
               p_last_period_counter OUT NOCOPY number) Return Boolean Is
      l_calendar_type varchar2(40);
      l_number_per_fiscal_year number;
      l_life_in_months number;
   Begin
      Select ct.calendar_type, ct.number_per_fiscal_year, bk.life_in_months
      Into l_calendar_type, l_number_per_fiscal_year, l_life_in_months
      From fa_calendar_types ct, fa_book_controls bc, fa_books bk
      Where ct.calendar_type = bc.deprn_calendar
      and bk.book_type_code = p_book_type_code
      and bk.date_ineffective is null
      and bk.asset_id = p_asset_id
      and bc.date_ineffective is null
      and bc.book_type_code = p_book_type_code;

      p_last_period_counter := p_dpis_period_counter + ((l_life_in_months/12)
                               * l_number_per_fiscal_year) - 1 ;
      Return True ;
   Exception
      When Others Then
         Return False ;
   End;

   Procedure Assign_Values_To_Rec(
                p_upload_record IN out nocopy upload_record,
                p_file_name IN igi_iac_upload_headers.file_name%type,
                p_asset_number IN fa_additions.asset_number%type) Is
   Begin
      For C_Asset_Exists_Rec in C_Asset_Exists(p_file_Name, p_asset_number) Loop
         p_upload_record.File_Name := p_file_name;
         p_upload_record.Book_Type_Code := C_Asset_Exists_Rec.Book_Type_Code;
         p_upload_record.Period_Counter := C_Asset_Exists_Rec.Period_Counter;
         p_upload_record.Currency_Code := C_Asset_Exists_Rec.Currency_Code;
         p_upload_record.Hdr_Status_Flag := C_Asset_Exists_Rec.Hdr_Status_Flag;
         p_upload_record.Tolerance_Flag := C_Asset_Exists_Rec.Tolerance_Flag;
         p_upload_record.Tolerance_Amount := C_Asset_Exists_Rec.Tolerance_Amount;
         p_upload_record.Tolerance_Percent := C_Asset_Exists_Rec.Tolerance_Percent;
         p_upload_record.Revaluation_Id := C_Asset_Exists_Rec.Revaluation_Id;
         p_upload_record.Asset_Id := C_Asset_Exists_Rec.Asset_Id;
         p_upload_record.Line_Num := C_Asset_Exists_Rec.Line_Num;
         p_upload_record.Category_Id := C_Asset_Exists_Rec.Category_Id;
         p_upload_record.Original_Cost := C_Asset_Exists_Rec.Original_Cost;
         p_upload_record.New_Cost := C_Asset_Exists_Rec.New_Cost;
         p_upload_record.Line_Status_Flag := C_Asset_Exists_Rec.Line_Status_Flag;
         p_upload_record.Gross_Flag := C_Asset_Exists_Rec.Gross_Flag;
         p_upload_record.Percentage_Diff := C_Asset_Exists_Rec.Percentage_Diff;
         p_upload_record.Amount_Diff := C_Asset_Exists_Rec.Amount_Diff;
         p_upload_record.Exception_Message := C_Asset_Exists_Rec.Exception_Message;
         p_upload_record.Comments := C_Asset_Exists_Rec.Comments;
      End Loop;
   End;

   Procedure Delete_Line(p_file_name IN igi_iac_upload_headers.file_name%type,
                         p_asset_id IN igi_iac_upload_lines.asset_id%type,
                         p_line_num IN igi_iac_upload_lines.line_num%type) Is
   Begin
      Delete from igi_iac_upload_lines
      Where file_name = p_file_name
      and asset_id = p_asset_id
      and line_num = p_line_num;
   End;

   Procedure Insert_Header(p_upload_record IN upload_record) Is
   Begin
      Insert into igi_iac_upload_headers(
         File_Name,
         Book_Type_Code,
         Period_Counter,
         Currency_Code,
         Status_Flag,
         Tolerance_Flag,
         Tolerance_Amount,
         Tolerance_Percent,
         Revaluation_Id,
         Created_By,
         Creation_Date,
         Last_Update_Login,
         Last_Update_Date,
         Last_Updated_By)
      Values(
         p_upload_record.File_Name,
         p_upload_record.Book_Type_Code,
         p_upload_record.Period_Counter,
         p_upload_record.Currency_Code,
         p_upload_record.Hdr_Status_Flag,
         p_upload_record.Tolerance_Flag,
         p_upload_record.Tolerance_Amount,
         p_upload_record.Tolerance_Percent,
         p_upload_record.Revaluation_Id,
         l_global_user_id,
         l_global_date,
         l_global_login_id,
         l_global_date,
         l_global_user_id);
   End Insert_Header;

   Procedure Insert_Line(p_upload_record IN upload_record) Is
   Begin
      Insert into igi_iac_upload_lines(
         File_Name,
         Asset_Id,
         Line_Num,
         Category_Id,
         Original_Cost,
         New_Cost,
         Status_Flag,
         Gross_Flag,
         Percentage_Diff,
         Amount_Diff,
         Exception_Message,
         Comments,
         Created_By,
         Creation_Date,
         Last_Update_Login,
         Last_Update_Date,
         Last_Updated_By)
      Values (
         p_upload_record.file_name,
         p_upload_record.asset_id,
         p_upload_record.line_num,
         p_upload_record.category_id,
         p_upload_record.original_cost,
         p_upload_record.new_cost,
         p_upload_record.line_status_flag,
         p_upload_record.gross_flag,
         p_upload_record.percentage_diff,
         p_upload_record.amount_diff,
         p_upload_record.exception_message,
         p_upload_record.comments,
         l_global_user_id,
         l_global_date,
         l_global_login_id,
         l_global_date,
         l_global_user_id);
   End Insert_Line;

   Procedure Update_Header(p_upload_record IN upload_record) Is
   Begin
      Update igi_iac_upload_headers set
         Tolerance_Flag = p_upload_record.tolerance_flag,
         Tolerance_Amount = p_upload_record.tolerance_amount,
         Tolerance_Percent = p_upload_record.tolerance_percent,
         Revaluation_Id = p_upload_record.revaluation_id,
         Last_Update_Login = l_global_login_id,
         Last_Update_Date = l_global_date,
         Last_Updated_By = l_global_user_id
      Where file_name = p_upload_record.file_name;
   End Update_Header;

   Procedure Gross_Up(p_upload_record IN OUT nocopy upload_record) Is
      Cursor C_Dpis(
                cp_book_type_code IN igi_iac_upload_headers.book_type_code%type,
                cp_asset_id IN igi_iac_upload_lines.asset_id%type) Is
      Select date_placed_in_service, life_in_months
      From fa_books
      Where book_type_code = cp_book_type_code
      and asset_id = cp_asset_id
      and date_ineffective is null;

      l_date_placed_in_service fa_books.date_placed_in_service%type;
      l_life_in_months fa_books.life_in_months%type;
      l_dpis_period_counter fa_deprn_summary.period_counter%type;
      l_end_date fa_books.date_placed_in_service%type;
      l_end_period_counter  fa_deprn_summary.period_counter%type;
      l_total_periods  number;
      l_remaining_periods  number;
   Begin
      Open C_Dpis(p_upload_record.book_type_code, p_upload_record.asset_id);
      Fetch C_Dpis into l_date_placed_in_service, l_life_in_months;
      Close C_Dpis;
      If igi_iac_common_utils.get_dpis_period_counter(
            p_upload_record.book_type_code,
            p_upload_record.asset_id,
            l_dpis_period_counter) Then
         l_end_date := add_months(l_date_placed_in_service, l_life_in_months);
         If Last_Period_Counter(p_upload_record.asset_id,
                                p_upload_record.book_type_code,
                                l_dpis_period_counter,
                                l_end_period_counter) Then
            l_total_periods := (l_end_period_counter - l_dpis_period_counter) + 1;
            l_remaining_periods := l_end_period_counter - p_upload_record.period_counter;
            If l_remaining_periods = 0 then
               l_remaining_periods := 1;
            End If;
            p_upload_record.new_cost := ((p_upload_record.new_cost/l_remaining_periods)*l_total_periods) ;
            If igi_iac_common_utils.Iac_Round(p_upload_record.new_cost,
                                              p_upload_record.book_type_code) Then
               Null;
            End If;
         End If;
      End If;
   End Gross_Up;

   Procedure Update_Duplicate_Assets(
                p_file_name IN igi_iac_upload_lines.file_name%type,
                p_book_type_code IN igi_iac_upload_headers.book_type_code%type,
                p_period_counter IN igi_iac_upload_headers.period_counter%type,
                p_asset_id IN igi_iac_upload_lines.asset_id%type,
                p_line_num IN igi_iac_upload_lines.line_num%type,
                p_message IN igi_iac_upload_lines.exception_message%type) Is
      Cursor C_Dup_Asset_Info(
                cp_file_name IN igi_iac_upload_lines.file_name%type,
                cp_asset_id IN igi_iac_upload_lines.asset_id%type,
                cp_line_num IN igi_iac_upload_lines.line_num%type) IS
      Select Line_Num, New_Cost, Gross_Flag, Status_Flag
      From igi_iac_upload_lines
      Where file_name = cp_file_name
      and asset_id = cp_asset_id
      and line_num <> cp_line_num;

      Cursor C_Dpis(
                cp_book_type_code IN igi_iac_upload_headers.book_type_code%type,
                cp_asset_id IN igi_iac_upload_lines.asset_id%type) Is
      Select date_placed_in_service, life_in_months
      From fa_books
      Where book_type_code = cp_book_type_code
      and asset_id = cp_asset_id
      and date_ineffective is null;

      l_date_placed_in_service fa_books.date_placed_in_service%type;
      l_life_in_months fa_books.life_in_months%type;
      l_dpis_period_counter fa_deprn_summary.period_counter%type;
      l_end_date fa_books.date_placed_in_service%type;
      l_end_period_counter  fa_deprn_summary.period_counter%type;
      l_total_periods  number;
      l_remaining_periods  number;
   Begin
      Open C_Dpis(p_book_type_code, p_asset_id);
      Fetch C_Dpis into l_date_placed_in_service, l_life_in_months;
      Close C_Dpis;
      If igi_iac_common_utils.get_dpis_period_counter(p_book_type_code,
                                                      p_asset_id,
                                                      l_dpis_period_counter) Then
         l_end_date := add_months(l_date_placed_in_service, l_life_in_months);
         If Last_Period_Counter(p_asset_id,
                                p_book_type_code,
                                l_dpis_period_counter,
                                l_end_period_counter) Then
            l_total_periods := (l_end_period_counter - l_dpis_period_counter) + 1;
            l_remaining_periods := l_end_period_counter - p_period_counter;
            If l_remaining_periods = 0 then
               l_remaining_periods := 1;
            End If;
            For C_Dup_Asset_Info_Rec in C_Dup_Asset_Info(p_file_name,
                                                         p_asset_id,
                                                         p_line_num) Loop
                If C_Dup_Asset_Info_Rec.status_flag <> 'E' and
                      C_Dup_Asset_Info_Rec.gross_flag = 'Y' Then
                   C_Dup_Asset_Info_Rec.new_cost :=
                      ((C_Dup_Asset_Info_Rec.new_cost/l_total_periods) *
                       l_remaining_periods);
                   If igi_iac_common_utils.Iac_Round(
                         C_Dup_Asset_Info_Rec.new_cost,p_book_type_code) Then
                      null;
                   End If;
                End If;
                Update igi_iac_upload_lines
                Set New_Cost = C_Dup_Asset_Info_Rec.new_cost,
                    Status_Flag = 'E',
                    Amount_Diff = null,
                    Percentage_Diff = null,
                    Exception_Message = p_message
                Where file_name = p_file_name
                and asset_id = p_asset_id
                and line_num = C_Dup_Asset_Info_Rec.line_num;
            End Loop;
         End If;
      End If;
   End Update_Duplicate_Assets;

   Procedure Check_Tolerances(p_upload_record IN OUT nocopy upload_record) Is
   Begin
      p_upload_record.percentage_diff := abs((p_upload_record.new_cost/ (p_upload_record.original_cost) -1)*100);
      p_upload_record.amount_diff := abs(p_upload_record.new_cost - p_upload_record.original_cost);
      If igi_iac_common_utils.Iac_Round(p_upload_record.percentage_diff,
                                        p_upload_record.book_type_code) Then
         Null;
      End If;
      If igi_iac_common_utils.Iac_Round(p_upload_record.amount_diff,
                                        p_upload_record.book_type_code) Then
         Null;
      End If;
      p_upload_record.line_status_flag := 'A';
      If p_upload_record.tolerance_amount is null Then
         If p_upload_record.percentage_diff >
               abs(p_upload_record.tolerance_percent) Then
            p_upload_record.line_status_flag := 'L';
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_PER_ERROR');
            p_upload_record.exception_message := Fnd_Message.Get;
         End If;
      Elsif p_upload_record.tolerance_percent is null Then
         If p_upload_record.amount_diff >
               abs(p_upload_record.tolerance_amount) Then
            p_upload_record.line_status_flag := 'L';
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_AMT_ERROR');
            p_upload_record.exception_message := Fnd_Message.Get;
         End If;
      Else
         If ((p_upload_record.percentage_diff >
                 abs(p_upload_record.tolerance_percent)) OR
            (p_upload_record.amount_diff >
                abs(p_upload_record.tolerance_amount))) Then
	    p_upload_record.line_status_flag := 'L';
            If ((p_upload_record.percentage_diff >
                   abs(p_upload_record.tolerance_percent)) AND
               (p_upload_record.amount_diff >
                   abs(p_upload_record.tolerance_amount))) Then
               Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_AMT_PER_ERROR');
               p_upload_record.exception_message := Fnd_Message.Get;
            Elsif p_upload_record.percentage_diff >
                     abs(p_upload_record.tolerance_percent) Then
               Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_PER_ERROR');
               p_upload_record.exception_message := Fnd_Message.Get;
            Elsif p_upload_record.amount_diff >
                     abs(p_upload_record.tolerance_amount) Then
               Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_AMT_ERROR');
               p_upload_record.exception_message := Fnd_Message.Get;
            End If;
         End If;
      End If;
   End Check_Tolerances;

   Procedure Check_Exceptions(p_upload_record IN OUT nocopy upload_record)Is

      Cursor C_Dup_Assets(cp_file_name IN igi_iac_upload_headers.file_name%type,
                          cp_asset_id IN igi_iac_upload_lines.asset_id%type) Is
      Select count(*)
      From igi_iac_upload_lines
      Where file_name = cp_file_name
      and asset_id = cp_asset_id;

      Cursor C_Valid_Iac_Cat(
                cp_book_type_code in igi_iac_upload_headers.book_type_code%type,
                cp_category_id in igi_iac_upload_lines.category_id%type) Is
      Select allow_prof_reval_flag
      From igi_iac_category_books
      Where book_type_code = cp_book_type_code
      and category_id = cp_category_id;

      Cursor C_Max_Period_counter(
             cp_book_type_code in igi_iac_upload_headers.book_type_code%type) Is
      Select max(period_counter)
      From fa_deprn_summary
      Where book_type_code = cp_book_type_code;

      Cursor C_Last_Closed_Period(
             cp_book_type_code in igi_iac_upload_headers.book_type_code%type) Is
      Select last_period_counter
      From fa_book_controls
      Where book_type_code = cp_book_type_code;

      l_asset_cnt number;
      l_allow_prof_reval_flag igi_iac_category_books.allow_prof_reval_flag%type;
      l_max_period_counter number;
      l_last_closed_period number;
      l_get_period_rec igi_iac_types.prd_rec;
   Begin
      p_upload_record.line_status_flag := 'A';
      p_upload_record.exception_message := null;

      Open C_Valid_Iac_Cat(p_upload_record.book_type_code,
                           p_upload_record.category_id);
      Fetch C_Valid_Iac_Cat into l_allow_prof_reval_flag;
      If C_Valid_Iac_Cat%notfound Then
         p_upload_record.line_status_flag := 'E';
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_NON_IAC_CATEGORY');
         p_upload_record.exception_message := ltrim(
            p_upload_record.exception_message || ' ' || Fnd_Message.Get);
      Else
         If l_allow_prof_reval_flag = 'Y' Then
   	    Null;
	 Else
            p_upload_record.line_status_flag := 'E';
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_NON_PROF_CATEGORY');
            p_upload_record.exception_message := ltrim(
               p_upload_record.exception_message || ' ' || Fnd_Message.Get);
         End If;
      End If;
      Close C_Valid_Iac_Cat;

      -- Bug 3391784 Start
      If p_upload_record.original_cost < 0 Then
         p_upload_record.line_status_flag := 'E';
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_NEGATIVE_ASSETS');
         p_upload_record.exception_message := ltrim(
            p_upload_record.exception_message || ' ' || Fnd_Message.Get);
      End If;
      -- Bug 3391784 End

      If igi_iac_common_utils.get_open_Period_Info(
               p_upload_record.book_type_code, l_get_period_rec) Then
         If p_upload_record.period_counter <> (l_get_period_rec.period_counter
                                               - 1) Then
            p_upload_record.line_status_flag := 'E';
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_UNAVAILABLE_PERIOD');
            p_upload_record.exception_message := ltrim(
               p_upload_record.exception_message || ' ' || Fnd_Message.Get);
         End If;
      End If;
      Open C_max_period_counter(p_upload_record.book_type_code);
      Fetch C_max_period_counter into l_max_period_counter;
      Close C_max_period_counter;

      Open C_Last_Closed_Period(p_upload_record.book_type_code);
      Fetch C_Last_Closed_Period into l_last_closed_period;
      Close C_Last_Closed_Period;

      If l_max_period_counter > l_last_closed_period Then
         p_upload_record.line_status_flag := 'E';
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_DEP_NOT_CLOSED');
         p_upload_record.exception_message := ltrim(
            p_upload_record.exception_message || ' ' || Fnd_Message.Get);
      End If;

      If igi_iac_common_utils.Any_Txns_In_Open_Period(
               p_upload_record.book_type_code, p_upload_record.asset_id) Then
         p_upload_record.line_status_flag := 'E';
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_PENDING_TRX');
         p_upload_record.exception_message := ltrim(
            p_upload_record.exception_message || ' ' || Fnd_Message.Get);
      End If;
      If p_upload_record.period_counter_fully_retired is not null Then
         p_upload_record.line_status_flag := 'E';
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_FULLY_RET');
         p_upload_record.exception_message := ltrim(
            p_upload_record.exception_message || ' ' || Fnd_Message.Get);
      End If;
      Open C_Dup_Assets(p_upload_record.File_Name, p_upload_record.Asset_Id);
      Fetch C_Dup_Assets into l_asset_cnt;
      Close C_Dup_Assets;
      If l_asset_cnt > 1 Then
         p_upload_record.line_status_flag := 'E';
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_DUP_ASSET');
         p_upload_record.exception_message := ltrim(
         p_upload_record.exception_message || ' ' || Fnd_Message.Get);
         Update_Duplicate_Assets(p_upload_record.file_name,
                                 p_upload_record.book_type_code,
                                 p_upload_record.period_counter,
                                 p_upload_record.asset_id,
                                 p_upload_record.line_num,
                                 p_upload_record.exception_message);
      End If;
   Exception
      When Others Then
         If C_Dup_Assets%isopen Then
            Close C_Dup_Assets;
         End If;
         If C_Valid_Iac_Cat%isopen Then
            Close C_Valid_Iac_Cat;
         End If;
         If C_Max_Period_counter%isopen Then
            Close C_Max_Period_counter;
         End If;
         If C_Last_Closed_Period%isopen Then
            Close C_Last_Closed_Period;
         End If;
         Raise;
   End Check_Exceptions;

   Procedure Update_Line(p_upload_record IN upload_record) Is
   Begin
      Update igi_iac_upload_lines
      Set new_cost = p_upload_record.new_cost,
         original_cost = p_upload_record.original_cost,
         percentage_diff = p_upload_record.percentage_diff,
         amount_diff = p_upload_record.amount_diff,
         status_flag = p_upload_record.line_status_flag,
         gross_flag = p_upload_record.gross_flag,
         exception_message = p_upload_record.exception_message,
         comments = p_upload_record.comments
      Where file_name = p_upload_record.file_name
      and asset_id = p_upload_record.asset_id
      and line_num = p_upload_record.line_num;
   End Update_Line;

   Procedure Update_Header_Status(
                p_file_name IN igi_iac_upload_headers.file_name%type) Is
      Cursor C_Lines(cp_file_name IN igi_iac_upload_headers.file_name%type) Is
      Select count(*) line_cnt
      From igi_iac_upload_lines
      Where file_name = cp_file_name;

      Cursor C_Errors(cp_file_name IN igi_iac_upload_headers.file_name%type,
                      cp_status_flag IN varchar2) Is
      Select count(*) exp_cnt
      From igi_iac_upload_lines
      Where file_name = cp_file_name
      and status_flag = cp_status_flag;
      l_errors number;
      l_lines number;
   Begin
      Open C_Lines(p_file_name);
      Fetch C_Lines into l_lines;
      Close C_Lines;
      If l_lines = 0 Then
         Delete from igi_iac_upload_headers where file_name = p_file_name;
      Else
         Open C_Errors(p_file_name, 'E');
         Fetch C_Errors into l_errors;
         Close C_Errors;
         If l_errors > 0 Then
            Update igi_iac_upload_headers
            Set status_flag = 'E'
            Where file_name = p_file_name;
         Else
            l_errors := 0;
            Open C_Errors(p_file_name, 'L');
            Fetch C_Errors into l_errors;
            Close C_Errors;
            If l_errors > 0 Then
               Update igi_iac_upload_headers
               Set status_flag = 'L'
       	       Where file_name = p_file_name;
            Else
       	       Update igi_iac_upload_headers
       	       Set status_flag = 'A'
       	       Where file_name = p_file_name;
            End If;
         End If;
      End If;
   Exception
      When Others Then
         If C_Lines%isopen Then
            Close C_Lines;
         End If;
         If C_Errors%isopen Then
            Close C_Errors;
         End If;
         Raise;
   End Update_Header_Status;

   Procedure Final_Dup_Asset_Check(
                p_file_name IN igi_iac_upload_headers.file_name%type,
                p_asset_id IN igi_iac_upload_lines.asset_id%type,
                p_line_num IN igi_iac_upload_lines.line_num%type,
                p_asset_number IN fa_additions.asset_number%type) Is
      Cursor C_Dup_Count(cp_file_name IN igi_iac_upload_headers.file_name%type,
                         cp_asset_id IN igi_iac_upload_lines.asset_id%type,
                         cp_line_num IN igi_iac_upload_lines.line_num%type) Is
      Select count(*)
      From igi_iac_upload_lines
      Where file_name = cp_file_name
      and asset_id = cp_asset_id
      and line_num <> cp_line_num
      and status_flag = 'E';

      l_cnt number;
      l_dup_record upload_record;
   Begin
      Open C_Dup_Count(p_file_name, p_asset_id, p_line_num);
      Fetch C_Dup_Count into l_cnt;
      Close C_Dup_Count;
      If l_cnt = 1 Then
         Assign_Values_To_Rec(l_dup_record,p_file_name,p_asset_number);
         -- Bug 3413035 Start
         For C_Full_Ret_Counter_Rec in C_Full_Ret_Counter(
                l_dup_record.book_type_code, l_dup_record.asset_id)Loop
                l_dup_record.period_counter_fully_retired := C_Full_Ret_Counter_Rec.period_counter_fully_retired;
         End Loop;
         -- Bug 3413035 End
         Check_Exceptions(l_dup_record);
         If l_dup_record.line_status_flag = 'A' Then
            If l_dup_record.gross_flag = 'Y' Then
               Gross_Up(l_dup_record);
            End If;
            If l_dup_record.tolerance_flag = 'Y' Then
               Check_Tolerances(l_dup_record);
            End If;
         End If;
      End If;
      Update_Line(l_dup_record);
   Exception
      When Others Then
         If C_Dup_Count%isopen Then
            Close C_Dup_Count;
         End If;
         Raise;
   End Final_Dup_Asset_Check;

   Procedure New_File(
         P_File_Name  	      IN  igi_iac_upload_headers.file_name%type,
         P_Book_Type_Code     IN  igi_iac_upload_headers.book_type_code%type,
         P_Tolerance_Flag     IN  igi_iac_upload_headers.tolerance_flag%type,
         P_Tolerance_Amount   IN  igi_iac_upload_headers.tolerance_amount%type,
         P_Tolerance_Percent  IN  igi_iac_upload_headers.tolerance_percent%type,
         P_Asset_Number       IN  fa_additions.asset_number%type,
	 P_New_Cost           IN  igi_iac_upload_lines.new_cost%type,
	 P_Gross_Flag         IN  igi_iac_upload_lines.gross_flag%type) Is

      Cursor C_Book_Defaults(
             cp_book_type_code in igi_iac_upload_headers.book_type_code%type) Is
      Select fa.last_period_counter, gl.currency_code
      From fa_book_controls fa, gl_sets_of_books gl
      Where book_type_code = cp_book_type_code
      and gl.set_of_books_id = fa.set_of_books_id;

      Cursor C_Asset_Details(
             cp_book_type_code in igi_iac_upload_headers.book_type_code%type,
             cp_asset_number in fa_additions.asset_number%type) Is
      Select bk.cost,
             bk.period_counter_fully_retired,
             ad.asset_id,
             ad.asset_category_id
      From fa_books bk, fa_additions ad
      Where bk.book_type_code = cp_book_type_code
      and bk.transaction_header_id_out is null
      and ad.asset_id = bk.asset_id
      and ad.asset_number = cp_asset_number;

      Cursor C_Get_Adjustments(
             cp_book_type_code in igi_iac_upload_headers.book_type_code%type,
             cp_asset_id in igi_iac_upload_lines.asset_id%type,
             cp_period_counter in igi_iac_upload_headers.period_counter%type) Is
      Select nvl(adjusted_cost,0)adjusted_cost
      From igi_iac_asset_balances
      Where book_type_code = cp_book_type_code
      and asset_id = cp_asset_id
      and period_counter = (select max(period_counter)
                             from igi_iac_asset_balances
                             where book_type_code = cp_book_type_code
                             and asset_id = cp_asset_id);  -- Bug 8484461

      Cursor C_File_Status(
             cp_file_name in igi_iac_upload_headers.status_flag%type) Is
      Select status_flag, period_counter, currency_code
      From igi_iac_upload_headers
      Where file_name = cp_file_name;

      Cursor C_Line_Num(
             cp_file_name in igi_iac_upload_headers.file_name%type) Is
      Select nvl(max(line_num),0) + 1 Line_Num
      From igi_iac_upload_lines
      Where file_name =  cp_file_name;

      l_status_flag igi_iac_upload_headers.status_flag%type;
      l_period_counter igi_iac_upload_headers.period_counter%type;
      l_currency_code igi_iac_upload_headers.currency_code%type;
      l_upload_record Upload_Record;
      E_Non_Iac_Book exception;
      E_Igi_Tol_Yes exception;
      E_Igi_Tol_No exception;
   Begin
      l_upload_record.File_Name := p_file_name;
      l_upload_record.Book_Type_Code := p_book_type_code;
      l_upload_record.Hdr_Status_Flag := 'A';
      l_upload_record.Tolerance_Flag := p_tolerance_flag;
      l_upload_record.Tolerance_Amount := p_tolerance_amount;
      l_upload_record.Tolerance_Percent := p_tolerance_percent;
      l_upload_record.New_Cost := p_new_cost;
      l_upload_record.Line_Status_Flag := 'A';
      l_upload_record.Gross_Flag := p_gross_flag;
      If not igi_gen.is_req_installed('IAC') Then
         Raise E_Iac_Not_Enabled;
      End If;

      If not igi_iac_common_utils.Is_IAC_Book(
                                     l_upload_record.book_type_code) Then
         Raise E_Non_Iac_Book;
      End If;

      For C_Book_Defaults_Rec in C_Book_Defaults(
                                    l_upload_record.book_type_code) Loop
         l_upload_record.period_counter := C_Book_Defaults_Rec.last_period_counter;
         l_upload_record.currency_code := C_Book_Defaults_Rec.currency_code;
      End Loop;

      If l_upload_record.tolerance_flag = 'Y' Then
         If (l_upload_record.tolerance_amount is null
             and l_upload_record.tolerance_percent is null ) Then
            Raise E_Igi_Tol_Yes;
         End If;
      Else
         If (l_upload_record.tolerance_amount is not null
             or l_upload_record.tolerance_percent is not null ) Then
            Raise E_Igi_Tol_No;
         End If;
      End If;

      For C_Asset_Details_Rec in C_Asset_Details(l_upload_record.book_type_code,
                                                 p_asset_number) Loop
         l_upload_record.original_cost := C_Asset_Details_Rec.cost;
         l_upload_record.asset_id := C_Asset_Details_Rec.asset_id;
         l_upload_record.category_id := C_Asset_Details_Rec.asset_category_id;
         l_upload_record.period_counter_fully_retired := C_Asset_Details_Rec.period_counter_fully_retired;
      End Loop;

      If l_upload_record.asset_id is null Then
         Raise E_Invalid_Asset;
      End If;

      For C_Get_Adjustments_Rec in C_Get_Adjustments(
                                      l_upload_record.book_type_code,
                                      l_upload_record.asset_id,
                                      l_upload_record.period_counter) Loop
         l_upload_record.original_cost := l_upload_record.original_cost + C_Get_Adjustments_Rec.adjusted_cost;
      End Loop;

      Open C_File_Status (p_file_name);
      Fetch C_File_Status into l_status_flag, l_period_counter, l_currency_code;
      If C_File_Status%notfound Then
         Insert_Header(l_upload_record);
         l_upload_record.line_num := 1;
         Insert_Line(l_upload_record);
      Else
         If l_status_flag = 'T' Then
            Close C_File_Status;
            Raise E_File_Trans;
         Else
            l_upload_record.period_counter := l_period_Counter;
            l_upload_record.currency_code := l_currency_code;
            Update_Header(l_upload_record);
            For C_Line_Num_Rec in C_Line_Num(p_file_name) Loop
                l_upload_record.Line_Num := C_Line_Num_rec.line_num;
            End Loop;
            Insert_Line(l_upload_record);
         End If;
      End If;
      Close C_File_Status;
      Check_Exceptions (l_upload_record);
      If l_upload_record.line_status_flag = 'A' Then
         If l_upload_record.gross_flag = 'Y' Then
            Gross_Up(l_upload_record);
         End If;
         If l_upload_record.tolerance_flag = 'Y' Then
            Check_Tolerances(l_upload_record);
         End If;
      End If;
      Update_Line(l_upload_record);
      Update_Header_Status(l_upload_record.file_name);
      Commit;
   Exception
      When E_Iac_Not_Enabled Then
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_NOT_INSTALLED') ;
         Fnd_Message.Raise_Error;
      When E_Non_Iac_Book Then
         Fnd_Message.Set_Name('IGI','IGI_IAC_UPL_INVALID_BOOK');
         Fnd_Message.Raise_Error;
      When E_Igi_Tol_Yes Then
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_TOL_REQ');
         Fnd_Message.Raise_Error;
      When E_Igi_Tol_No Then
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_TOL_NOT_REQ');
         Fnd_Message.Raise_Error;
      When E_Invalid_Asset Then
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_INVALID_ASSET');
         Fnd_Message.Raise_Error;
      When E_File_Trans Then
         Fnd_Message.Set_Name('IGI','IGI_IAC_UPL_FILE_TRANS');
         Fnd_Message.Raise_Error;
   End New_File;

   Procedure Tol_Errors(
         P_File_Name  	   IN  igi_iac_upload_headers.file_name%type,
         P_Book_Type_Code  IN  igi_iac_upload_headers.book_type_code%type,
         P_Period	   IN  fa_deprn_periods.period_name%type,
         P_Currency    	   IN  igi_iac_upload_headers.currency_code%type,
         P_Status          IN  igi_iac_upload_headers.status_flag%type,
         P_Hdr_Action	   IN  fnd_lookup_values.lookup_code%type,
         P_Asset_Number    IN  fa_additions.asset_number%type,
         P_Asset_Desc      IN  fa_additions.description%type,
         P_Cat_Desc        IN  fa_categories.description%type,
         P_Original_Cost   IN  igi_iac_upload_lines.original_cost%type,
         P_New_Cost        IN  igi_iac_upload_lines.new_cost%type,
         P_Amt_Diff        IN  igi_iac_upload_lines.amount_diff%type,
         P_Per_Diff        IN  igi_iac_upload_lines.percentage_diff%type,
         P_Message         IN  igi_iac_upload_lines.exception_message%type,
         P_Line_Action     IN  fnd_lookup_values.lookup_code%type,
         P_Comments        IN  igi_iac_upload_lines.comments%type,
         -- Bug 3391921 Start
	 P_Gross_Flag      IN  igi_iac_upload_lines.gross_flag%type) Is
         -- Bug 3391921 End
      l_dummy varchar2(1);
      l_upload_record upload_record;
      l_upd_line_flag varchar2(1) := 'Y';
   Begin
      If not igi_gen.is_req_installed('IAC') Then
         Raise E_Iac_Not_Enabled;
      End If;

      Open C_File_Transferred(p_file_name);
      Fetch C_File_Transferred into l_dummy;
      If C_File_Transferred%found Then
         Close C_File_Transferred;
         Raise E_File_Trans;
      End If;
      Close C_File_Transferred;

      Assign_Values_To_Rec(l_upload_record,p_file_name, p_asset_number);
      l_upload_record.Comments := p_Comments;
      -- Bug 3391921 Start
      l_upload_record.Gross_Flag := p_gross_flag;
      -- Bug 3391921 End

      If l_upload_record.asset_id is null Then
         Raise E_Invalid_Asset;
      End If;

      If p_line_action = 'D' Then
         Delete_Line(p_file_name,
                     l_upload_record.asset_id,
                     l_upload_record.line_num);
         l_upd_line_flag := 'N';
      Elsif p_line_action = 'A' Then
         If p_hdr_action = 'A' Then
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_TOL_ACCEPT');
            l_upload_record.comments :=  Fnd_Message.Get;
         End If;
         l_upload_record.line_status_flag := 'A';
         l_upload_record.exception_message := null;
      Else -- N
         If p_hdr_action = 'D' Then
            Delete_Line(p_file_name,
                        l_upload_record.asset_Id,
                        l_upload_record.line_num);
            l_upd_line_flag := 'N';
         Elsif p_hdr_action = 'A' Then
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_TOL_ACCEPT');
            l_upload_record.comments :=  Fnd_Message.Get;
            l_upload_record.line_status_flag := 'A';
            l_upload_record.exception_message := null;
         Else -- N
            l_upd_line_flag := 'N';
         End If;
      End If;

      If l_upload_record.line_status_flag = 'A' Then
         -- Bug 3391921 Start
         If ((p_new_cost <> l_upload_record.new_cost) or p_gross_flag = 'Y') Then
         -- Bug 3391921 End
            l_upload_record.new_cost := p_new_cost;
            If l_upload_record.gross_flag = 'Y' Then
               Gross_Up(l_upload_record);
            End If;
            If l_upload_record.tolerance_flag = 'Y' Then
               Check_Tolerances(l_upload_record);
            End If;
         End If;
      End If;
      If l_upd_line_flag = 'Y' Then
         Update_Line(l_upload_record);
      End If;
      Update_Header_Status(l_upload_record.file_name);
      Commit;
   Exception
      When E_Iac_Not_Enabled Then
         FND_MESSAGE.Set_Name('IGI','IGI_IAC_NOT_INSTALLED');
         Fnd_Message.Raise_Error;
      When E_File_Trans Then
         FND_MESSAGE.Set_Name('IGI','IGI_IAC_UPL_FILE_TRANS');
         Fnd_Message.Raise_Error;
      When E_Invalid_Asset Then
         Fnd_Message.Set_Name('IGI','IGI_IAC_UPL_NO_ASSET_IN_FILE');
         Fnd_Message.Raise_Error;
   End Tol_Errors;

   Procedure Excpt_Errors(
         P_File_Name  	   IN  igi_iac_upload_headers.file_name%type,
  	 P_Book_Type_Code  IN  igi_iac_upload_headers.book_type_code%type,
  	 P_Period	   IN  fa_deprn_periods.period_name%type,
  	 P_Currency	   IN  igi_iac_upload_headers.currency_code%type,
  	 P_Status          IN  igi_iac_upload_headers.status_flag%type,
  	 P_Hdr_Action	   IN  fnd_lookup_values.lookup_code%type,
  	 P_Asset_Number    IN  fa_additions.asset_number%type,
         P_Line_Num        IN  igi_iac_upload_lines.line_num%type,
	 P_Asset_Desc      IN  fa_additions.description%type,
	 P_Cat_Desc        IN  fa_categories.description%type,
         P_New_Cost        IN  igi_iac_upload_lines.new_cost%type,
	 P_Message         IN  igi_iac_upload_lines.exception_message%type,
	 P_Line_Action     IN  fnd_lookup_values.lookup_code%type,
         -- Bug 3391921 Start
         P_Gross_Flag      IN  igi_iac_upload_lines.gross_flag%type) Is
         -- Bug 3391921 End

      l_dummy igi_iac_upload_headers.status_flag%type;
      l_upload_record upload_record;
      l_upd_line_flag varchar2(1) := 'Y';
   Begin
      If not igi_gen.is_req_installed('IAC') Then
         Raise E_Iac_Not_Enabled;
      End If;

      Open C_File_Transferred(p_file_name);
      Fetch C_File_Transferred into l_dummy;
      If C_File_Transferred%found Then
         Close C_File_Transferred;
         Raise E_File_Trans;
      End If;
      Close C_File_Transferred;

      For C_Excpt_Asset_Rec in C_Excpt_Asset(p_file_name,
                                             p_asset_number,
                                             p_line_num) Loop
         l_upload_record.File_Name := p_file_name;
         l_upload_record.Book_Type_Code := C_Excpt_Asset_Rec.Book_Type_Code;
         l_upload_record.Period_Counter := C_Excpt_Asset_Rec.Period_Counter;
         l_upload_record.Currency_Code := C_Excpt_Asset_Rec.Currency_Code;
         l_upload_record.Hdr_Status_Flag := C_Excpt_Asset_Rec.Hdr_Status_Flag;
         l_upload_record.Tolerance_Flag := C_Excpt_Asset_Rec.Tolerance_Flag;
         l_upload_record.Tolerance_Amount := C_Excpt_Asset_Rec.Tolerance_Amount;
         l_upload_record.Tolerance_Percent := C_Excpt_Asset_Rec.Tolerance_Percent;
         l_upload_record.Revaluation_Id := C_Excpt_Asset_Rec.Revaluation_Id;
         l_upload_record.Asset_Id := C_Excpt_Asset_Rec.Asset_Id;
         l_upload_record.Line_Num := C_Excpt_Asset_Rec.Line_Num;
         l_upload_record.Category_Id := C_Excpt_Asset_Rec.Category_Id;
         l_upload_record.Original_Cost := C_Excpt_Asset_Rec.Original_Cost;
         -- Bug 3391921 Start
         l_upload_record.New_Cost := p_new_cost;
         -- Bug 3391921 End
         l_upload_record.Line_Status_Flag := C_Excpt_Asset_Rec.Line_Status_Flag;
         -- Bug 3391921 Start
         l_upload_record.Gross_Flag := p_gross_flag;
         -- Bug 3391921 End
         l_upload_record.Percentage_Diff := C_Excpt_Asset_Rec.Percentage_Diff;
         l_upload_record.Amount_Diff := C_Excpt_Asset_Rec.Amount_Diff;
         l_upload_record.Exception_Message := C_Excpt_Asset_Rec.Exception_Message;
         l_upload_record.Comments := C_Excpt_Asset_Rec.Comments;
      End Loop;

      If l_upload_record.Asset_Id is null Then
         Raise E_Invalid_Asset;
      End If;

      For C_Full_Ret_Counter_Rec in C_Full_Ret_Counter(
             l_upload_record.book_type_code, l_upload_record.asset_id)Loop
         l_upload_record.period_counter_fully_retired := C_Full_Ret_Counter_Rec.period_counter_fully_retired;
      End Loop;

      If p_line_action = 'D' Then
         Delete_Line(p_file_name,
                     l_upload_record.asset_id,
                     l_upload_record.line_num);
         l_upd_line_flag := 'N';
      Elsif p_line_action = 'A' Then
         If p_hdr_action = 'A' Then
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_EXC_ACCEPT');
            l_upload_record.comments :=  Fnd_Message.Get;
         End If;
         Check_Exceptions(l_upload_record);
      Else -- N
         If p_hdr_action = 'D' Then
            Delete_Line(p_file_name,
                        l_upload_record.asset_id,
                        l_upload_record.line_num);
            l_upd_line_flag := 'N';
         Elsif p_hdr_action = 'A' Then
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_EXC_ACCEPT');
            l_upload_record.comments :=  Fnd_Message.Get;
            Check_Exceptions(l_upload_record);
         Else -- N
            l_upd_line_flag := 'N';
         End If;
      End if;

      If l_upload_record.line_status_flag = 'A' Then
         If l_upload_record.gross_flag = 'Y' Then
            Gross_Up(l_upload_record);
         End If;
         If l_upload_record.tolerance_flag = 'Y' Then
            Check_Tolerances(l_upload_record);
         End If;
      End If;
      If l_upd_line_flag = 'Y' Then
         Update_Line(l_upload_record);
      End If;
      Final_Dup_Asset_Check(
                p_file_name,
                l_upload_record.asset_id,
                l_upload_record.line_num,
                p_asset_number);
      Update_Header_Status(l_upload_record.file_name);
      Commit;
   Exception
      When E_Iac_Not_Enabled Then
         FND_MESSAGE.Set_Name('IGI','IGI_IAC_NOT_INSTALLED');
         Fnd_Message.Raise_Error;
      When E_File_Trans Then
         FND_MESSAGE.Set_Name('IGI','IGI_IAC_UPL_FILE_TRANS');
         Fnd_Message.Raise_Error;
      When E_Invalid_Asset Then
         Fnd_Message.Set_Name('IGI','IGI_IAC_UPL_NO_ASSET_IN_FILE');
         Fnd_Message.Raise_Error;
   End Excpt_Errors;

   Procedure Valid_Assets(
      P_File_Name  	IN  igi_iac_upload_headers.file_name%type,
      P_Book_Type_Code  IN  igi_iac_upload_headers.book_type_code%type,
      P_Period	        IN  fa_deprn_periods.period_name%type,
      P_Currency	IN  igi_iac_upload_headers.currency_code%type,
      P_Status          IN  igi_iac_upload_headers.status_flag%type,
      P_Hdr_Action	IN  fnd_lookup_values.lookup_code%type,
      P_Asset_Number    IN  fa_additions.asset_number%type,
      P_Asset_Desc      IN  fa_additions.description%type,
      P_Cat_Desc        IN  fa_categories.description%type,
      P_Original_Cost   IN  igi_iac_upload_lines.original_cost%type,
      P_New_Cost        IN  igi_iac_upload_lines.new_cost%type,
      P_Line_Action     IN  fnd_lookup_values.lookup_code%type,
      -- Bug 3391921 Start
      P_Gross_Flag      IN  igi_iac_upload_lines.gross_flag%type) Is
      -- Bug 3391921 End

      l_dummy varchar2(1);
      l_upload_record upload_record;
   Begin
      If not igi_gen.is_req_installed('IAC') Then
         Raise E_Iac_Not_Enabled;
      End If;

      Open C_File_Transferred(p_file_name);
      Fetch C_File_Transferred into l_dummy;
      If C_File_Transferred%found Then
         Close C_File_Transferred;
         Raise E_File_Trans;
      End If;
      Close C_File_Transferred;

      If p_hdr_action = 'Y' Then
         Delete from igi_iac_upload_headers where file_name = p_file_name;
         Delete from igi_iac_upload_lines where file_name = p_file_name;
      Else  -- N
         Assign_Values_To_Rec(l_upload_record, p_file_name, p_asset_number);
         -- Bug 3391921 Start
         l_upload_record.gross_flag := p_gross_flag;
         -- Bug 3391921 End
         If l_upload_record.asset_id is null Then
            Raise E_Invalid_Asset;
         End If;
         If p_line_action = 'D' Then
            Delete_Line(p_file_name,
                        l_upload_record.asset_id,
                        l_upload_record.line_num);
         Else -- N
            -- Bug 3391921 Start
            If ((p_new_cost <> l_upload_record.new_cost) or p_gross_flag = 'Y')  Then
            -- Bug 3391921 End
                l_upload_record.new_cost := p_new_cost;
                If l_upload_record.gross_flag = 'Y' Then
                   Gross_Up(l_upload_record);
                End If;
                If l_upload_record.tolerance_flag = 'Y' Then
                   Check_Tolerances(l_upload_record);
                End If;
                Update_Line(l_upload_record);
             End If;
         End If;
         Update_Header_Status(l_upload_record.file_name);
      End If;
      Commit;
   Exception
      When E_Iac_Not_Enabled Then
         FND_MESSAGE.Set_Name('IGI','IGI_IAC_NOT_INSTALLED');
         Fnd_Message.Raise_Error;
      When E_File_Trans Then
         FND_MESSAGE.Set_Name('IGI','IGI_IAC_UPL_FILE_TRANS');
         Fnd_Message.Raise_Error;
      When E_Invalid_Asset Then
         Fnd_Message.Set_Name('IGI','IGI_IAC_UPL_NO_ASSET_IN_FILE');
         Fnd_Message.Raise_Error;
   End Valid_Assets;

   Procedure Transfer_Data(
                errbuf         OUT NOCOPY varchar2,
	        retcode        OUT NOCOPY number,
	        p_file_name    IN  igi_iac_upload_headers.file_name%type,
	        p_preview_flag IN  varchar2) Is

      Cursor C_Upload_Hdr(
                cp_file_name in igi_iac_upload_headers.file_name%type) Is
      Select * from igi_iac_upload_headers
      Where file_name = cp_file_name;

      Cursor C_Upload_Lines(
                cp_file_name in igi_iac_upload_headers.file_name%type) Is
      Select * from igi_iac_upload_lines
      Where file_name = cp_file_name;

      Cursor C_Categories(
                cp_file_name in igi_iac_upload_headers.file_name%type) Is
      Select distinct category_id from igi_iac_upload_lines
      where file_name = cp_file_name;

      Cursor C_Max_Period_counter(
             cp_book_type_code in igi_iac_upload_headers.book_type_code%type) Is
      Select max(period_counter) max_period_counter
      From fa_deprn_summary
      Where book_type_code = cp_book_type_code;

      Cursor C_Last_Closed_Period(
             cp_book_type_code in igi_iac_upload_headers.book_type_code%type) Is
      Select last_period_counter
      From fa_book_controls
      Where book_type_code = cp_book_type_code;

      -- bug 3443410, start 1
      CURSOR c_preview_exists(cp_book_type_code  igi_iac_upload_headers.book_type_code%TYPE)
      IS
      SELECT irar.asset_id,
             fa.asset_number,
             irar.selected_for_reval_flag,
             iir.status
      FROM igi_iac_reval_asset_rules irar,
           igi_iac_revaluations iir,
           fa_additions fa
      WHERE irar.book_type_code = cp_book_type_code
      AND fa.asset_id = irar.asset_id
      AND irar.revaluation_id = iir.revaluation_id
      AND irar.revaluation_id = (SELECT max(revaluation_id)
                                 FROM igi_iac_revaluations
                                 WHERE book_type_code = cp_book_type_code
                                 AND   calling_program IN ('IGIIAIAR', 'SSUPLOAD') -- bug 3510376, add
                                 AND   status in ('PREVIEWED', 'NEW', 'FAILED_PRE',
                                                  'FAILED_RUN', 'PREVIEW', 'UPDATED'));

      l_preview_exists          c_preview_exists%ROWTYPE;
      -- l_book_type_code          igi_iac_revaluations.book_type_code%TYPE;
      -- bug 3443410, end 1

      -- bug 3536362, start 1
      -- cursor to retrieve the historic portion of the cost of an asset
      CURSOR C_FA_Asset_Cost(cp_book_type_code IN igi_iac_upload_headers.book_type_code%TYPE,
                             cp_asset_id IN fa_additions.asset_id%TYPE
                            )
      IS
      SELECT bk.cost
      FROM fa_books bk,
           fa_additions ad
      WHERE bk.book_type_code = cp_book_type_code
      AND bk.transaction_header_id_out IS NULL
      AND ad.asset_id = bk.asset_id
      AND ad.asset_id = cp_asset_id;

      -- cursor to retrieve the iac portion of the cost of an asset
      CURSOR C_IAC_Asset_Cost(cp_book_type_code IN igi_iac_upload_headers.book_type_code%TYPE,
                              cp_asset_id IN igi_iac_upload_lines.asset_id%TYPE,
                              cp_period_counter IN igi_iac_upload_headers.period_counter%TYPE
                             )
      IS
      SELECT nvl(adjusted_cost,0)  adjusted_cost
      FROM igi_iac_asset_balances
      WHERE book_type_code = cp_book_type_code
      AND asset_id = cp_asset_id
      AND period_counter = (SELECT MAX(period_counter)
                             FROM igi_iac_asset_balances
                             WHERE book_type_code = cp_book_type_code
                             AND asset_id = cp_asset_id);  -- Bug 8484461

      l_fa_asset_cost   fa_books.cost%TYPE;
      l_iac_asset_cost  igi_iac_asset_balances.adjusted_cost%TYPE;
      l_current_cost    igi_iac_reval_asset_rules.current_cost%TYPE;
      -- bug 3536362, end 1

      l_reval_id Number;
      l_reval_date Date;
      l_asset_count Number := 0;
      l_max_period_counter number;
      l_last_closed_period number;
      l_request_id Number;
      l_message varchar2(1000);
      l_get_period_rec igi_iac_types.prd_rec;
      l_create_req_id igi_iac_revaluations.create_request_id%type := null;

      -- bug 3412940, start 1
      l_reval_factor   igi_iac_reval_asset_rules.revaluation_factor%TYPE;
      -- bug 3412940, end 1

      E_Request_Submit_Error exception;
      E_Unavailable_Period exception;
      E_Period_Not_Closed exception;

      -- bug 3443410, start 2
      e_preview_exists   EXCEPTION;
      -- bug 3443410, end 2

   Begin

      /* bug 3443410, start 3
         comment this out - the nextval should be retrieved only if
         the upload process is allowed to create a NEW or PREVIEWED
         revaluation. Move it to after the Preview/New exists exception
         check
      Select igi_iac_revaluations_s.NEXTVAL
      Into l_reval_id
      From dual;

      bug 3443419, end 3  */

      For C_Upload_Hdr_Rec in C_Upload_Hdr(p_file_name) Loop

         -- mh start 4
         -- check if a previewed revaluation exists for the book
         -- if it does then error the transfer process out
         OPEN c_preview_exists(C_Upload_Hdr_Rec.book_type_code);
         FETCH c_preview_exists INTO l_preview_exists;
         IF c_preview_exists%FOUND THEN
           --    l_book_type_code := C_Upload_Hdr_Rec.book_type_code;
            CLOSE c_preview_exists;
            RAISE e_preview_exists;
         END IF;
         CLOSE c_preview_exists;

         Select igi_iac_revaluations_s.NEXTVAL
         Into l_reval_id
         From dual;
         -- mh end 4

         If igi_iac_common_utils.get_open_Period_Info(
            C_Upload_Hdr_Rec.book_type_code, l_get_period_rec) Then
            If C_Upload_Hdr_Rec.period_counter <>
                  (l_get_period_rec.period_counter - 1) Then
               Raise E_Unavailable_Period;
            End If;
         End If;
         For C_Max_Period_Counter_Rec in C_max_period_counter(
                                         C_Upload_Hdr_Rec.book_type_code) Loop
            l_max_period_counter :=  C_max_period_counter_rec.max_period_counter;
         End Loop;

         For C_Last_Closed_Period_Rec in C_Last_Closed_Period(
                                         C_Upload_Hdr_Rec.book_type_code) Loop
            l_last_closed_period := C_Last_Closed_Period_Rec.last_period_counter;
         End Loop;

         If l_max_period_counter > l_last_closed_period Then
            Raise E_Period_Not_Closed;
         End If;

         If igi_iac_common_utils.get_period_info_for_counter(
                                 C_Upload_Hdr_rec.book_type_code,
                                 C_Upload_Hdr_Rec.period_counter,
                                 l_get_period_rec) Then
           l_reval_date := l_get_period_rec.period_end_date;
         End If;
         Insert into igi_iac_revaluations(
            Revaluation_Id,
            Book_Type_Code,
            Revaluation_Date ,
            Revaluation_Period ,
            Status,
            Reval_Request_Id ,
            Create_Request_Id ,
            Calling_Program ,
            Last_Update_Date,
            Created_By ,
            Last_Update_Login  ,
            Last_Updated_By ,
            Creation_Date)
         Values(
            l_reval_id,
            C_Upload_Hdr_Rec.book_type_code,
            l_reval_date,
            C_Upload_Hdr_Rec.period_counter,
            'NEW',
            null,
            null,
            'SSUPLOAD',
            l_global_date,
            l_global_user_id,
            l_global_login_id,
            l_global_user_id,
            l_global_date);

         For C_Categories_Rec in C_Categories(p_file_name) Loop
            Insert into igi_iac_reval_categories(
               Revaluation_Id,
               Book_Type_Code,
               Category_Id,
               Select_Category,
               Last_Update_Date,
               Created_By ,
               Last_Update_Login  ,
               Last_Updated_By ,
               Creation_Date)
            Values(
               l_reval_id,
               C_Upload_Hdr_Rec.book_type_code,
               C_Categories_Rec.category_id,
               'Y',
               l_global_date,
               l_global_user_id,
               l_global_login_id,
               l_global_user_id,
               l_global_date);
         End Loop;

         For C_Upload_Lines_Rec in C_Upload_Lines(p_file_name) Loop

            -- bug 3536362, start 2
            OPEN C_FA_Asset_Cost(cp_book_type_code => C_Upload_Hdr_Rec.book_type_code,
                                        cp_asset_id       => C_Upload_Lines_Rec.asset_id
                                       );
            FETCH C_FA_Asset_Cost INTO l_fa_asset_cost;
            IF C_FA_Asset_Cost%NOTFOUND THEN
               RAISE NO_DATA_FOUND;
            END IF;
            CLOSE C_FA_Asset_Cost;

            OPEN C_IAC_Asset_Cost(cp_book_type_code => C_Upload_Hdr_Rec.book_type_code,
                                         cp_asset_id => C_Upload_Lines_Rec.asset_id,
                                         cp_period_counter => C_Upload_Hdr_Rec.period_counter
                                         );
            FETCH C_IAC_Asset_Cost INTO l_iac_asset_cost;
            IF C_IAC_Asset_Cost%NOTFOUND THEN
               l_iac_asset_cost := 0;    -- Bug 8484461
               --RAISE NO_DATA_FOUND;
            END IF;
            CLOSE C_IAC_Asset_Cost;

            l_current_cost := l_fa_asset_cost + l_iac_asset_cost;
            -- bug 3536362, end 2

            -- bug 3412940, start 2
            -- l_reval_factor   := C_Upload_lines_Rec.new_cost/C_Upload_Lines_Rec.original_cost;
            -- bug 3412940, end 2

            -- bug 3536362, start 3
            l_reval_factor   := C_Upload_lines_Rec.new_cost/l_current_cost;
            -- bug 3536362, end 3

            Insert into igi_iac_reval_asset_rules(
               Revaluation_Id,
               Book_Type_Code,
               Category_Id,
               Asset_Id,
               Revaluation_Factor,
               Revaluation_Type,
               New_Cost,
               Current_Cost,
               Selected_For_Reval_Flag,
               Selected_For_Calc_Flag,
               Allow_Prof_Update,
               Created_By,
               Creation_Date,
               Last_Update_Login,
               Last_Update_Date,
               Last_Updated_By)
            Values(
               l_reval_id,
               C_Upload_Hdr_Rec.book_type_code,
               C_Upload_Lines_Rec.category_id,
               C_Upload_Lines_Rec.asset_id,
               l_reval_factor, -- bug 3412940 1,
               'P',
               C_Upload_Lines_Rec.new_cost,
               l_current_cost, -- bug 3536362 C_Upload_Lines_Rec.original_cost,
               'Y',
               null,
               null,
               l_global_user_id,
               l_global_date,
               l_global_login_id,
               l_global_date,
               l_global_user_id);
            If sql%found Then
               l_asset_count := l_asset_count + 1;
            End If;
         End Loop ;

         Update igi_iac_upload_headers
         Set status_flag = 'T', revaluation_id = l_reval_id
         Where file_name = p_file_name;

         If sql%notfound then
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_TRANS_FAILURE');
            l_message := Fnd_Message.Get;
--            Debug(l_message);
-- bug 3299718, start block
            IF (l_state_level >= l_debug_level) THEN
               FND_LOG.STRING(l_state_level, 'igi.plsql.IGI_IAC_WEBADI_PKG.Transfer_Data.Msg1',
                                            l_message);
            END IF;
-- bug 3299718, end block


         Elsif sql%found then
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_TRANS_SUCCESS');
            l_message := Fnd_Message.Get;
--            Debug(l_message);
-- bug 3299718, start block
            IF (l_state_level >= l_debug_level) THEN
               FND_LOG.STRING(l_state_level, 'igi.plsql.IGI_IAC_WEBADI_PKG.Transfer_Data.Msg2',
                                            l_message);
            END IF;
-- bug 3299718, end block

            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_TRANS_COUNT');
            Fnd_Message.Set_Token('ASSET_COUNT',l_asset_count);
            l_message := Fnd_Message.Get;
--            Debug(l_message);
-- bug 3299718, start block
            IF (l_state_level >= l_debug_level) THEN
               FND_LOG.STRING(l_state_level, 'igi.plsql.IGI_IAC_WEBADI_PKG.Transfer_Data.Msg3',
                                            l_message);
            END IF;
-- bug 3299718, end block
            Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_REVAL_ID');
            Fnd_Message.Set_Token('REVAL_ID',l_reval_id);
            l_message := Fnd_Message.Get;
--            Debug(l_message);
-- bug 3299718, start block
            IF (l_state_level >= l_debug_level) THEN
               FND_LOG.STRING(l_state_level, 'igi.plsql.IGI_IAC_WEBADI_PKG.Transfer_Data.Msg4',
                                            l_message);
            END IF;
-- bug 3299718, end block
         End if;
         Commit;

         If p_preview_flag = 'Y' Then
            l_request_id := FND_REQUEST.SUBMIT_REQUEST(
               APPLICATION  => 'IGI',
               PROGRAM      => 'IGIIAIAR',
               DESCRIPTION  => '',
               START_TIME   => NULL,
               SUB_REQUEST  => FALSE,
               ARGUMENT1    => to_char(l_reval_id),
               ARGUMENT2    => C_Upload_Hdr_Rec.book_type_code,
               ARGUMENT3    => 'P',
               ARGUMENT4    => to_char(C_Upload_Hdr_Rec.period_counter),
               ARGUMENT5    => to_char(l_create_req_id),
               ARGUMENT6    => CHR(0), ARGUMENT7 => NULL, ARGUMENT8    => NULL,
               ARGUMENT9    => NULL, ARGUMENT10   => NULL, ARGUMENT11   => NULL,
               ARGUMENT12   => NULL, ARGUMENT13   => NULL, ARGUMENT14   => NULL,
               ARGUMENT15   => NULL, ARGUMENT16   => NULL, ARGUMENT17   => NULL,
               ARGUMENT18   => NULL, ARGUMENT19   => NULL, ARGUMENT20   => NULL,
               ARGUMENT21   => NULL, ARGUMENT22   => NULL, ARGUMENT23   => NULL,
               ARGUMENT24   => NULL, ARGUMENT25   => NULL, ARGUMENT26   => NULL,
               ARGUMENT27   => NULL, ARGUMENT28   => NULL, ARGUMENT29   => NULL,
               ARGUMENT30   => NULL, ARGUMENT31   => NULL, ARGUMENT32   => NULL,
               ARGUMENT33   => NULL, ARGUMENT34   => NULL, ARGUMENT35   => NULL,
               ARGUMENT36   => NULL, ARGUMENT37   => NULL, ARGUMENT38   => NULL,
               ARGUMENT39   => NULL, ARGUMENT40   => NULL, ARGUMENT41   => NULL,
               ARGUMENT42   => NULL, ARGUMENT43   => NULL, ARGUMENT44   => NULL,
               ARGUMENT45   => NULL, ARGUMENT46   => NULL, ARGUMENT47   => NULL,
               ARGUMENT48   => NULL, ARGUMENT49   => NULL, ARGUMENT50   => NULL,
               ARGUMENT51   => NULL, ARGUMENT52   => NULL, ARGUMENT53   => NULL,
               ARGUMENT54   => NULL, ARGUMENT55   => NULL, ARGUMENT56   => NULL,
               ARGUMENT57   => NULL, ARGUMENT58   => NULL, ARGUMENT59   => NULL,
               ARGUMENT60   => NULL, ARGUMENT61   => NULL, ARGUMENT62   => NULL,
               ARGUMENT63   => NULL, ARGUMENT64   => NULL, ARGUMENT65   => NULL,
               ARGUMENT66   => NULL, ARGUMENT67   => NULL, ARGUMENT68   => NULL,
               ARGUMENT69   => NULL, ARGUMENT70   => NULL, ARGUMENT71   => NULL,
               ARGUMENT72   => NULL, ARGUMENT73   => NULL, ARGUMENT74   => NULL,
               ARGUMENT75   => NULL, ARGUMENT76   => NULL, ARGUMENT77   => NULL,
               ARGUMENT78   => NULL, ARGUMENT79   => NULL, ARGUMENT80   => NULL,
               ARGUMENT81   => NULL, ARGUMENT82   => NULL, ARGUMENT83   => NULL,
               ARGUMENT84   => NULL, ARGUMENT85   => NULL, ARGUMENT86   => NULL,
               ARGUMENT87   => NULL, ARGUMENT88   => NULL, ARGUMENT89   => NULL,
               ARGUMENT90   => NULL, ARGUMENT91   => NULL, ARGUMENT92   => NULL,
               ARGUMENT93   => NULL, ARGUMENT94   => NULL, ARGUMENT95   => NULL,
               ARGUMENT96   => NULL, ARGUMENT97   => NULL, ARGUMENT98   => NULL,
               ARGUMENT99   => NULL, ARGUMENT100  => NULL);

            IF l_request_id = 0 THEN
               RAISE E_Request_Submit_Error;
            End If;
         End If;
      End Loop;
      retcode := 0;
   Exception
      When E_Unavailable_Period Then
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_UNAVAILABLE_PERIOD');
         l_message := Fnd_Message.Get;
--         Debug(l_message);
-- bug 3299718, start block
            IF (l_state_level >= l_debug_level) THEN
               FND_LOG.STRING(l_state_level, 'igi.plsql.IGI_IAC_WEBADI_PKG.Transfer_Data.Msg5',
                                            l_message);
            END IF;
-- bug 3299718, end block

         errbuf := l_message;
         retcode :=2;
      When E_Period_Not_Closed Then
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_DEP_NOT_CLOSED');
         l_message := Fnd_Message.Get;
--         Debug(l_message);
-- bug 3299718, start block
            IF (l_state_level >= l_debug_level) THEN
               FND_LOG.STRING(l_state_level, 'igi.plsql.IGI_IAC_WEBADI_PKG.Transfer_Data.Msg6',
                                            l_message);
            END IF;
-- bug 3299718, end block

         errbuf := l_message;
         retcode :=2;
      When E_Request_Submit_Error THEN
         Fnd_Message.Set_Name('IGI', 'IGI_IAC_UPL_PREVIEW_FAILED');
         l_message := Fnd_Message.Get;
--         Debug(l_message);

-- bug 3299718, start block
            IF (l_state_level >= l_debug_level) THEN
               FND_LOG.STRING(l_state_level, 'igi.plsql.IGI_IAC_WEBADI_PKG.Transfer_Data.Msg7',
                                            l_message);
            END IF;
-- bug 3299718, end block

      -- bug 3443410, start 5
      WHEN e_preview_exists THEN
         /* bug 3495368, start 1
         -- commenting out as no longer required
         IF  (l_error_level >= l_debug_level) THEN
            fnd_message.set_name('IGI', 'IGI_IAC_UPL_PREVIEW_EXISTS');
            l_mesg1 := fnd_message.get;
            FND_LOG.MESSAGE(l_error_level,'igi.plsql.IGI_IAC_WEBADI_PKG.Transfer_Data.Preview Exists', TRUE);
            -- fnd_file.put_line required for display to user
            fnd_file.put_line(fnd_file.log, l_mesg1);

            -- list of assets
            l_preview_exists := NULL;
            FOR l_preview_exists IN c_preview_exists(l_book_type_code) LOOP
               fnd_message.set_name('IGI', 'IGI_IAC_UPL_PREVIEW_ASSETS');
               fnd_message.set_token('ASSET_NUM', l_preview_exists.asset_number, FALSE);
               l_mesg1 := fnd_message.get;
               FND_LOG.MESSAGE(l_error_level,'igi.plsql.IGI_IAC_WEBADI_PKG.Transfer_Data.Preview Exists', TRUE);
               -- fnd_file.put_line required for display to user
               fnd_file.put_line(fnd_file.log, l_mesg1);
            END LOOP;
         END IF;
         bug 3495368, end 1  */

         -- bug 3495368, start 2
            fnd_message.set_name('IGI', 'IGI_IAC_UPL_PREVIEW_EXISTS');
            l_message := fnd_message.get;
         -- bug 3495368, end 2

         errbuf := SQLERRM||': '||l_message;
         retcode :=2;
      -- bug 3443410, end 5

      When Others then
         errbuf := SQLERRM;
         retcode :=2;
   End Transfer_Data;
End IGI_IAC_WEBADI_PKG;

/
