--------------------------------------------------------
--  DDL for Package Body FA_INVOICE_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INVOICE_TRANSACTIONS_PKG" as
/* $Header: faxitsb.pls 120.3.12010000.2 2009/07/19 10:21:09 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Invoice_Transaction_Id         IN OUT NOCOPY NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Transaction_Type               VARCHAR2,
                       X_Date_Effective                 DATE,
			X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS SELECT rowid FROM fa_invoice_transactions
                 WHERE invoice_transaction_id = X_Invoice_Transaction_Id;
      CURSOR C2 IS SELECT fa_invoice_transactions_s.nextval FROM sys.dual;
   BEGIN
      if (X_Invoice_Transaction_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Invoice_Transaction_Id;
        CLOSE C2;
      end if;

       INSERT INTO fa_invoice_transactions(

              invoice_transaction_id,
              book_type_code,
              transaction_type,
              date_effective
             ) VALUES (

              X_Invoice_Transaction_Id,
              X_Book_Type_Code,
              X_Transaction_Type,
              X_Date_Effective

             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  EXCEPTION
	WHEN Others THEN
/*		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_INVOICE_TRANSACTIONS_PKG.Insert_Row',
			Calling_Fn => X_Calling_Fn, p_log_level_rec => p_log_level_rec); */
		FA_SRVR_MSG.Add_SQL_Error(
			Calling_Fn => 'FA_INVOICE_TRANSACTIONS_PKG.Insert_Row',  p_log_level_rec => p_log_level_rec);
		raise;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Invoice_Transaction_Id           NUMBER,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Transaction_Type                 VARCHAR2,
                     X_Date_Effective                   DATE,
			X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT *
        FROM   fa_invoice_transactions
        WHERE  rowid = X_Rowid
        FOR UPDATE of Invoice_Transaction_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.invoice_transaction_id =  X_Invoice_Transaction_Id)
           AND (Recinfo.book_type_code =  X_Book_Type_Code)
           AND (Recinfo.transaction_type =  X_Transaction_Type)
           AND (Recinfo.date_effective =  X_Date_Effective)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Invoice_Transaction_Id         NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Transaction_Type               VARCHAR2,
                       X_Date_Effective                 DATE,
			X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    UPDATE fa_invoice_transactions
    SET
       invoice_transaction_id          =     X_Invoice_Transaction_Id,
       book_type_code                  =     X_Book_Type_Code,
       transaction_type                =     X_Transaction_Type,
       date_effective                  =     X_Date_Effective
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
	WHEN Others THEN
		fa_srvr_msg.add_sql_error
			(Calling_Fn => 'FA_INVOICE_TRANSACTIONS_PKG.Update_Row',  p_log_level_rec => p_log_level_rec);
		raise;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
			X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    DELETE FROM fa_invoice_transactions
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
	WHEN Others THEN
		fa_srvr_msg.add_sql_error
			(Calling_Fn => 'FA_INVOICE_TRANSACTIONS_PKG.Delete_Row',  p_log_level_rec => p_log_level_rec);
		raise;
  END Delete_Row;


END FA_INVOICE_TRANSACTIONS_PKG;

/
