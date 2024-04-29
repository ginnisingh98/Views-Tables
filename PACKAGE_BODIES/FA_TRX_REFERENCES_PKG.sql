--------------------------------------------------------
--  DDL for Package Body FA_TRX_REFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRX_REFERENCES_PKG" as
/* $Header: faxitrb.pls 120.4.12010000.2 2009/07/19 10:19:53 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                    IN OUT NOCOPY VARCHAR2,
                       X_Trx_Reference_Id         IN OUT NOCOPY NUMBER,
                       X_Book_Type_Code                  VARCHAR2,
                       X_Src_Asset_Id                    NUMBER,
                       X_Src_Transaction_Header_Id       NUMBER,
                       X_Dest_Asset_Id                   NUMBER,
                       X_Dest_Transaction_Header_Id      NUMBER,
                       X_Member_Asset_Id                 NUMBER   DEFAULT NULL,
                       X_Member_Transaction_Header_Id    NUMBER   DEFAULT NULL,
                       X_Transaction_Type                VARCHAR2 DEFAULT NULL,
                       X_Src_Transaction_Subtype         VARCHAR2 DEFAULT NULL,
                       X_Dest_Transaction_Subtype        VARCHAR2 DEFAULT NULL,
                       X_Src_Amortization_Start_Date     DATE     DEFAULT NULL,
                       X_Dest_Amortization_Start_Date    DATE     DEFAULT NULL,
                       X_Reserve_Transfer_Amount         NUMBER   DEFAULT NULL,
                       X_Src_Expense_Amount              NUMBER   DEFAULT NULL,
                       X_Dest_Expense_Amount             NUMBER   DEFAULT NULL,
                       X_Src_Eofy_Reserve                NUMBER   DEFAULT NULL,
                       X_Dest_Eofy_Reserve               NUMBER   DEFAULT NULL,
                       X_Creation_Date                   DATE,
                       X_Created_By                      NUMBER,
                       X_Last_Update_Date                DATE,
                       X_Last_Updated_By                 NUMBER,
                       X_Last_Update_Login               NUMBER   DEFAULT NULL,
                       X_Invoice_Transaction_Id          NUMBER   DEFAULT NULL,
                       X_Event_Id                        NUMBER   DEFAULT NULL,
                       X_Return_Status               OUT NOCOPY BOOLEAN,
                       X_Calling_Fn                      VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    CURSOR C IS SELECT rowid FROM fa_trx_references
                 WHERE trx_reference_id = X_Trx_Reference_Id;

    CURSOR C2 IS SELECT fa_trx_references_s.nextval FROM dual;

  BEGIN
      if (X_Trx_Reference_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Trx_Reference_Id;
        CLOSE C2;
      end if;

      INSERT INTO fa_trx_references(
              trx_reference_id,
              book_type_code,
              src_asset_id,
              src_transaction_header_id,
              dest_asset_id,
              dest_transaction_header_id,
              member_asset_id,
              member_transaction_header_id,
              transaction_type,
              src_transaction_subtype,
              dest_transaction_subtype,
              src_amortization_start_date,
              dest_amortization_start_date,
              reserve_transfer_amount,
              src_expense_amount,
              dest_expense_amount,
              src_eofy_reserve,
              dest_eofy_reserve,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              event_id,
              invoice_transaction_id
      ) VALUES (
              X_Trx_Reference_Id,
              X_Book_Type_Code,
              X_Src_Asset_Id,
              X_Src_Transaction_Header_Id,
              X_Dest_Asset_Id,
              X_Dest_Transaction_Header_Id,
              X_Member_Asset_Id,
              X_Member_Transaction_Header_Id,
              X_Transaction_Type,
              X_Src_Transaction_Subtype,
              X_Dest_Transaction_Subtype,
              X_Src_Amortization_Start_Date,
              X_Dest_Amortization_Start_Date,
              X_Reserve_Transfer_Amount,
              X_Src_Expense_Amount,
              X_Dest_Expense_Amount,
              X_Src_Eofy_Reserve,
              X_Dest_Eofy_Reserve,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Event_Id,
              X_Invoice_Transaction_Id
      );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    X_Return_Status := TRUE;

  exception
    when others then
	FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_TRX_REFERENCES_PKG.Insert_Row', p_log_level_rec => p_log_level_rec);
	X_Return_Status := FALSE;
        raise;

  END Insert_Row;


/*

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

  PROCEDURE Update_Row(

  PROCEDURE Delete_Row(X_Rowid 			VARCHAR2 DEFAULT NULL,

*/


END FA_TRX_REFERENCES_PKG;

/
