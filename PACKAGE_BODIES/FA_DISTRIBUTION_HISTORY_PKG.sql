--------------------------------------------------------
--  DDL for Package Body FA_DISTRIBUTION_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DISTRIBUTION_HISTORY_PKG" as
/* $Header: faxidhb.pls 120.3.12010000.2 2009/07/19 13:23:17 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,

                       X_Distribution_Id                IN OUT NOCOPY NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Units_Assigned                 NUMBER,
                       X_Date_Effective                 DATE,
                       X_Code_Combination_Id            NUMBER,
                       X_Location_Id                    NUMBER,
                       X_Transaction_Header_Id_In       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Date_Ineffective               DATE DEFAULT NULL,
                       X_Assigned_To                    NUMBER DEFAULT NULL,
                       X_Transaction_Header_Id_Out      NUMBER DEFAULT NULL,
                       X_Transaction_Units              NUMBER DEFAULT NULL,
                       X_Retirement_Id                  NUMBER DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
		         X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS SELECT rowid FROM fa_distribution_history
                 WHERE distribution_id = X_Distribution_Id;
      CURSOR C2 IS SELECT fa_distribution_history_s.nextval FROM sys.dual;
   BEGIN
      if (X_Distribution_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Distribution_Id;
        CLOSE C2;
      end if;

       INSERT INTO fa_distribution_history(

              distribution_id,
              book_type_code,
              asset_id,
              units_assigned,
              date_effective,
              code_combination_id,
              location_id,
              transaction_header_id_in,
              last_update_date,
              last_updated_by,
              date_ineffective,
              assigned_to,
              transaction_header_id_out,
              transaction_units,
              retirement_id,
              last_update_login
             ) VALUES (

              X_Distribution_Id,
              X_Book_Type_Code,
              X_Asset_Id,
              X_Units_Assigned,
              X_Date_Effective,
              X_Code_Combination_Id,
              X_Location_Id,
              X_Transaction_Header_Id_In,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Date_Ineffective,
              X_Assigned_To,
              X_Transaction_Header_Id_Out,
              X_Transaction_Units,
              X_Retirement_Id,
              X_Last_Update_Login

             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  exception
    when others then
	fa_srvr_msg.add_sql_error(calling_fn=>
			'fa_distribution_history_pkg.insert_row', p_log_level_rec => p_log_level_rec);
	raise;
/*      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_distribution_history_pkg.insert_row',
		CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec); */
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Distribution_Id                  NUMBER,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Units_Assigned                   NUMBER,
                     X_Date_Effective                   DATE,
                     X_Code_Combination_Id              NUMBER,
                     X_Location_Id                      NUMBER,
                     X_Transaction_Header_Id_In         NUMBER,
                     X_Date_Ineffective                 DATE DEFAULT NULL,
                     X_Assigned_To                      NUMBER DEFAULT NULL,
                     X_Transaction_Header_Id_Out        NUMBER DEFAULT NULL,
                     X_Transaction_Units                NUMBER DEFAULT NULL,
                     X_Retirement_Id                    NUMBER DEFAULT NULL,
		         X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT *
        FROM   fa_distribution_history
        WHERE  rowid = X_Rowid
        FOR UPDATE of Distribution_Id NOWAIT;
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

               (Recinfo.distribution_id =  X_Distribution_Id)
           AND (Recinfo.book_type_code =  X_Book_Type_Code)
           AND (Recinfo.asset_id =  X_Asset_Id)
           AND (Recinfo.units_assigned =  X_Units_Assigned)
           AND (Recinfo.date_effective =  X_Date_Effective)
           AND (Recinfo.code_combination_id =  X_Code_Combination_Id)
           AND (Recinfo.location_id =  X_Location_Id)
           AND (Recinfo.transaction_header_id_in =  X_Transaction_Header_Id_In)
           AND (   (Recinfo.date_ineffective =  X_Date_Ineffective)
                OR (    (Recinfo.date_ineffective IS NULL)
                    AND (X_Date_Ineffective IS NULL)))
           AND (   (Recinfo.assigned_to =  X_Assigned_To)
                OR (    (Recinfo.assigned_to IS NULL)
                    AND (X_Assigned_To IS NULL)))
           AND (   (Recinfo.transaction_header_id_out =
						X_Transaction_Header_Id_Out)
                OR (    (Recinfo.transaction_header_id_out IS NULL)
                    AND (X_Transaction_Header_Id_Out IS NULL)))
           AND (   (Recinfo.transaction_units =  X_Transaction_Units)
                OR (    (Recinfo.transaction_units IS NULL)
                    AND (X_Transaction_Units IS NULL)))
           AND (   (Recinfo.retirement_id =  X_Retirement_Id)
                OR (    (Recinfo.retirement_id IS NULL)
                    AND (X_Retirement_Id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid				VARCHAR2 DEFAULT NULL,
		       X_Distribution_Id                NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Units_Assigned                 NUMBER,
                       X_Date_Effective                 DATE,
                       X_Code_Combination_Id            NUMBER,
                       X_Location_Id                    NUMBER,
                       X_Transaction_Header_Id_In       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Date_Ineffective               DATE,
                       X_Assigned_To                    NUMBER,
                       X_Transaction_Header_Id_Out      NUMBER,
                       X_Transaction_Units              NUMBER,
                       X_Retirement_Id                  NUMBER,
                       X_Last_Update_Login              NUMBER,
		         X_Calling_Fn			VARCHAR2

  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    if X_Rowid is not null then
     UPDATE fa_distribution_history
     SET
	distribution_id                 =     X_Distribution_Id,
	book_type_code                  =     X_Book_Type_Code,
	asset_id                        =     X_Asset_Id,
	units_assigned                  =     X_Units_Assigned,
	code_combination_id             =     X_Code_Combination_Id,
	location_id                     =     X_Location_Id,
	transaction_header_id_in        =     X_Transaction_Header_Id_In,
	last_update_date                =     X_Last_Update_Date,
	last_updated_by                 =     X_Last_Updated_By,
	date_ineffective                =     X_Date_Ineffective,
	assigned_to                     =     X_Assigned_To,
	transaction_header_id_out       =     X_Transaction_Header_Id_Out,
	transaction_units               =     X_Transaction_Units,
	retirement_id                   =     X_Retirement_Id,
	last_update_login               =     X_Last_Update_Login
     WHERE rowid = X_Rowid;
    else
     UPDATE fa_distribution_history
     SET
	distribution_id                 =     X_Distribution_Id,
	book_type_code                  =     X_Book_Type_Code,
	asset_id                        =     X_Asset_Id,
	units_assigned                  =     X_Units_Assigned,
	date_effective                  =     X_Date_Effective,
	code_combination_id             =     X_Code_Combination_Id,
	location_id                     =     X_Location_Id,
	transaction_header_id_in        =     X_Transaction_Header_Id_In,
	last_update_date                =     X_Last_Update_Date,
	last_updated_by                 =     X_Last_Updated_By,
	date_ineffective                =     X_Date_Ineffective,
	assigned_to                     =     X_Assigned_To,
	transaction_header_id_out       =     X_Transaction_Header_Id_Out,
	transaction_units               =     X_Transaction_Units,
	retirement_id                   =     X_Retirement_Id,
	last_update_login               =     X_Last_Update_Login
     WHERE distribution_id = X_Distribution_id;
   end if;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
        fa_srvr_msg.add_sql_error(calling_fn=>
                  'fa_distribution_history_pkg.update_row', p_log_level_rec => p_log_level_rec);
        raise;
/*      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_distribution_history_pkg.update_row',
		CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec); */

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid 			VARCHAR2 DEFAULT NULL,
			X_Asset_Id		NUMBER DEFAULT NULL,
			X_Book_Type_Code	VARCHAR2 DEFAULT NULL,
			X_Transaction_Header_Id	NUMBER DEFAULT NULL,
		         X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    if X_Rowid is not null then
    	DELETE FROM fa_distribution_history
    	WHERE rowid = X_Rowid;
    elsif X_Transaction_Header_Id is not null then
	DELETE FROM fa_distribution_history
	WHERE transaction_header_id_in = X_Transaction_Header_Id
	AND asset_id = X_Asset_Id
	AND book_type_code = X_Book_Type_Code;
    elsif X_Asset_Id is not null then
	DELETE FROM fa_distribution_history
	WHERE asset_id = X_Asset_Id;
    else
	-- print some error message
	null;
    end if;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
	fa_srvr_msg.add_sql_error(calling_fn=>
                        'fa_distribution_history_pkg.delete_row', p_log_level_rec => p_log_level_rec);
        raise;
/*      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_distribution_history_pkg.delete_row',
		CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec); */
  END Delete_Row;

  PROCEDURE Reactivate_Row(X_Transaction_Header_Id_Out	NUMBER DEFAULT NULL,
			X_Asset_Id			NUMBER,
			X_Book_Type_Code		VARCHAR2,
		         X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
	X_Book_Class	Varchar2(20);
  BEGIN
    -- The update to the Distribution History needs to be done only
    -- when the  Book_Class is Corporate.

    Select Book_Class Into X_Book_Class
    From FA_BOOK_Controls
    Where Book_Type_Code = X_Book_Type_Code;

    If (X_Book_Class <> 'CORPORATE') then
	return;
    End If;


    if X_Transaction_Header_Id_Out is not null then
	UPDATE fa_distribution_history
	SET transaction_units = null,
	    transaction_header_id_out = null,
	    date_ineffective = null,
	    retirement_id = null
	WHERE transaction_header_id_out = X_Transaction_Header_Id_Out
	and asset_id = X_Asset_Id
	and book_type_code = X_Book_Type_Code;
    else
	UPDATE fa_distribution_history
	set transaction_units = null,
	    retirement_id = null
	WHERE asset_id = X_Asset_Id
	and book_type_code = X_Book_Type_Code
	and date_ineffective is null;
    end if;
    --
    if (SQL%NOTFOUND) then
      	Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_distribution_history_pkg.reactivate_row',
		CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Reactivate_Row;

END FA_DISTRIBUTION_HISTORY_PKG;

/
