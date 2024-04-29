--------------------------------------------------------
--  DDL for Package IGI_IAC_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_WEBADI_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiasas.pls 120.3.12000000.1 2007/08/01 16:18:59 npandya noship $
   Type Upload_Record is Record (
      File_Name igi_iac_upload_headers.file_name%type,
      Book_Type_Code igi_iac_upload_headers.book_type_code%type,
      Period_Counter igi_iac_upload_headers.period_counter%type,
      Currency_Code igi_iac_upload_headers.currency_code%type,
      Hdr_Status_Flag igi_iac_upload_headers.status_flag%type,
      Tolerance_Flag igi_iac_upload_headers.tolerance_flag%type,
      Tolerance_Amount igi_iac_upload_headers.tolerance_amount%type,
      Tolerance_Percent igi_iac_upload_headers.tolerance_percent%type,
      Revaluation_Id igi_iac_upload_headers.revaluation_id%type,
      Asset_Id igi_iac_upload_lines.asset_id%type,
      Line_Num igi_iac_upload_lines.line_num%type,
      Category_Id igi_iac_upload_lines.category_id%type,
      Original_Cost igi_iac_upload_lines.original_cost%type,
      New_Cost igi_iac_upload_lines.new_cost%type,
      Line_Status_Flag igi_iac_upload_lines.status_flag%type,
      Gross_Flag igi_iac_upload_lines.gross_flag%type,
      Percentage_Diff igi_iac_upload_lines.percentage_diff%type,
      Amount_Diff igi_iac_upload_lines.amount_diff%type,
      Comments igi_iac_upload_lines.comments%type,
      Exception_Message igi_iac_upload_lines.exception_message%type,
      Period_Counter_Fully_Retired fa_books.period_counter_fully_retired%type);

   Procedure New_File(
      P_File_Name  	   IN  igi_iac_upload_headers.file_name%type,
      P_Book_Type_Code     IN  igi_iac_upload_headers.book_type_code%type,
      P_Tolerance_Flag     IN  igi_iac_upload_headers.tolerance_flag%type,
      P_Tolerance_Amount   IN  igi_iac_upload_headers.tolerance_amount%type,
      P_Tolerance_Percent  IN  igi_iac_upload_headers.tolerance_percent%type,
      P_Asset_Number       IN  fa_additions.asset_number%type,
      P_New_Cost           IN  igi_iac_upload_lines.new_cost%type,
      P_Gross_Flag         IN  igi_iac_upload_lines.gross_flag%type );

   Procedure Tol_Errors(
      P_File_Name  	IN  igi_iac_upload_headers.file_name%type,
      P_Book_Type_Code  IN  igi_iac_upload_headers.book_type_code%type,
      P_Period	        IN  fa_deprn_periods.period_name%type,
      P_Currency    	IN  igi_iac_upload_headers.currency_code%type,
      P_Status          IN  igi_iac_upload_headers.status_flag%type,
      P_Hdr_Action	IN  fnd_lookup_values.lookup_code%type,
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
      P_Gross_Flag      IN  igi_iac_upload_lines.gross_flag%type);
      -- Bug 3391921 End

   Procedure Excpt_Errors(
      P_File_Name       IN  igi_iac_upload_headers.file_name%type,
      P_Book_Type_Code  IN  igi_iac_upload_headers.book_type_code%type,
      P_Period	        IN  fa_deprn_periods.period_name%type,
      P_Currency        IN  igi_iac_upload_headers.currency_code%type,
      P_Status          IN  igi_iac_upload_headers.status_flag%type,
      P_Hdr_Action      IN  fnd_lookup_values.lookup_code%type,
      P_Asset_Number    IN  fa_additions.asset_number%type,
      P_Line_Num        IN  igi_iac_upload_lines.line_num%type,
      P_Asset_Desc      IN  fa_additions.description%type,
      P_Cat_Desc        IN  fa_categories.description%type,
      P_New_Cost        IN  igi_iac_upload_lines.new_cost%type,
      P_Message         IN  igi_iac_upload_lines.exception_message%type,
      P_Line_Action     IN  fnd_lookup_values.lookup_code%type,
      -- Bug 3391921 Start
      P_Gross_Flag      IN  igi_iac_upload_lines.gross_flag%type);
      -- Bug 3391921 End

   Procedure Valid_Assets(
      P_File_Name  	IN  igi_iac_upload_headers.file_name%type,
      P_Book_Type_Code  IN  igi_iac_upload_headers.book_type_code%type,
      P_Period	        IN  fa_deprn_periods.period_name%type,
      P_Currency        IN  igi_iac_upload_headers.currency_code%type,
      P_Status          IN  igi_iac_upload_headers.status_flag%type,
      P_Hdr_Action	IN  fnd_lookup_values.lookup_code%type,
      P_Asset_Number    IN  fa_additions.asset_number%type,
      P_Asset_Desc      IN  fa_additions.description%type,
      P_Cat_Desc        IN  fa_categories.description%type,
      P_Original_Cost   IN  igi_iac_upload_lines.original_cost%type,
      P_New_Cost        IN  igi_iac_upload_lines.new_cost%type,
      P_Line_Action     IN  fnd_lookup_values.lookup_code%type,
      -- Bug 3391921 Start
      P_Gross_Flag      IN  igi_iac_upload_lines.gross_flag%type );
      -- Bug 3391921 End

   Procedure Transfer_Data(
      errbuf          OUT NOCOPY varchar2,
      retcode         OUT NOCOPY number,
      p_file_name     IN  igi_iac_upload_headers.file_name%type,
      p_preview_flag  IN  varchar2);
END IGI_IAC_WEBADI_PKG;

 

/
