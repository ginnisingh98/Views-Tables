--------------------------------------------------------
--  DDL for Package Body FA_TRANSFER_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRANSFER_DETAILS_PKG" as
/* $Header: faxitdb.pls 120.3.12010000.2 2009/07/19 10:17:26 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Transfer_Header_Id             NUMBER,
                       X_Distribution_Id                NUMBER,
                       X_Book_Header_Id                 NUMBER,
			X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS SELECT rowid FROM fa_transfer_details
                 WHERE transfer_header_id = X_Transfer_Header_Id
                 AND   distribution_id = X_Distribution_Id;
   BEGIN
       INSERT INTO fa_transfer_details(
              transfer_header_id,
              distribution_id,
              book_header_id
             ) VALUES (
              X_Transfer_Header_Id,
              X_Distribution_Id,
              X_Book_Header_Id
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
                fa_srvr_msg.add_sql_error(
                        calling_fn => 'FA_TRANSFER_DETAILS_PKG.insert_row', p_log_level_rec => p_log_level_rec);
                raise;
/*		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_TRANSFER_DETAILS_PKG.Insert_Row',
			Calling_Fn => X_Calling_Fn, p_log_level_rec => p_log_level_rec); */
  END Insert_Row;

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Transfer_Header_Id               NUMBER,
                     X_Distribution_Id                  NUMBER,
                     X_Book_Header_Id                   NUMBER,
			X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT	transfer_header_id,
		distribution_id,
		book_header_id
        FROM   fa_transfer_details
        WHERE  rowid = X_Rowid
        FOR UPDATE of Transfer_Header_Id NOWAIT;
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
    if ((Recinfo.transfer_header_id =  X_Transfer_Header_Id)
           AND (Recinfo.distribution_id =  X_Distribution_Id)
           AND (Recinfo.book_header_id =  X_Book_Header_Id)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Transfer_Header_Id             NUMBER,
                       X_Distribution_Id                NUMBER,
                       X_Book_Header_Id                 NUMBER,
			X_Calling_Fn			VARCHAR2

  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    UPDATE fa_transfer_details
    SET
       transfer_header_id              =     X_Transfer_Header_Id,
       distribution_id                 =     X_Distribution_Id,
       book_header_id                  =     X_Book_Header_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
	WHEN Others THEN
                fa_srvr_msg.add_sql_error(
                        calling_fn => 'FA_TRANSFER_DETAILS_PKG.update_row', p_log_level_rec => p_log_level_rec);
                raise;
/*		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_TRANSFER_DETAILS_PKG.Update_Row',
			Calling_Fn => X_Calling_Fn, p_log_level_rec => p_log_level_rec); */
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid 			VARCHAR2 DEFAULT NULL,
			X_Transfer_Header_Id 	NUMBER DEFAULT NULL,
			X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    if X_Rowid is not null then
    	DELETE FROM fa_transfer_details
    	WHERE rowid = X_Rowid;
    elsif X_Transfer_Header_Id is not null then
	DELETE FROM fa_transfer_details
	WHERE transfer_header_id = X_Transfer_Header_Id;
    else
	-- print some error message
       	null;
    end if;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
	WHEN Others THEN
                fa_srvr_msg.add_sql_error(
                        calling_fn => 'FA_TRANSFER_DETAILS_PKG.delete_row', p_log_level_rec => p_log_level_rec);
                raise;
/*		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_TRANSFER_DETAILS_PKG.Delete_Row',
			Calling_Fn => X_Calling_Fn, p_log_level_rec => p_log_level_rec); */
  END Delete_Row;


END FA_TRANSFER_DETAILS_PKG;

/
