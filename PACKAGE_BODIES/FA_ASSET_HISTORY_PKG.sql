--------------------------------------------------------
--  DDL for Package Body FA_ASSET_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_HISTORY_PKG" as
/* $Header: faxiahb.pls 120.5.12010000.2 2009/07/19 13:26:43 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Category_Id                    NUMBER,
                       X_Asset_Type                     VARCHAR2,
                       X_Units                          NUMBER,
                       X_Date_Effective                 DATE,
                       X_Date_Ineffective               DATE DEFAULT NULL,
                       X_Transaction_Header_Id_In       NUMBER,
                       X_Transaction_Header_Id_Out      NUMBER DEFAULT NULL,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Return_Status              OUT NOCOPY BOOLEAN,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS SELECT rowid FROM fa_asset_history
                 WHERE asset_id = X_asset_id
                   AND transaction_header_id_in = X_Transaction_Header_Id_In;

   BEGIN


       INSERT INTO fa_asset_history
             (asset_id,
              category_id,
              asset_type,
              units,
              date_effective,
              date_ineffective,
              transaction_header_id_in,
              transaction_header_id_out,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (
              X_Asset_Id,
              X_Category_Id,
              X_Asset_Type,
              X_Units,
              X_Date_Effective,
              X_Date_Ineffective,
              X_Transaction_Header_Id_In,
              X_Transaction_Header_Id_Out,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login
             );

/* Commenting out for Security by Book
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
*/

  exception
    when others then
        fa_srvr_msg.add_sql_error(
             calling_fn => 'fa_asset_history_pkg.insert_row', p_log_level_rec => p_log_level_rec);
        raise;

/*  Commented out for better error handling after using trx engine
      FA_STANDARD_PKG.RAISE_ERROR(
          CALLED_FN => 'fa_distribution_history_pkg.insert_row',
          CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
*/

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Category_Id                      NUMBER,
                     X_Asset_Type                       VARCHAR2,
                     X_Units                            NUMBER,
                     X_Date_Effective                   DATE,
                     X_Date_Ineffective                 DATE DEFAULT NULL,
                     X_Transaction_Header_Id_In         NUMBER,
                     X_Transaction_Header_Id_Out        NUMBER DEFAULT NULL,
                     X_Calling_Fn                       VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT *
        FROM   fa_asset_history
        WHERE  rowid = X_Rowid
        FOR UPDATE of Transaction_Header_Id_In NOWAIT;
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

               (Recinfo.asset_id =  X_Asset_Id)
           AND (Recinfo.category_id =  X_Category_Id)
           AND (Recinfo.asset_type =  X_Asset_Type)
           AND (Recinfo.units =  X_Units)
           AND (Recinfo.date_effective =  X_Date_Effective)
           AND (   (Recinfo.date_ineffective =  X_Date_Ineffective)
                OR (    (Recinfo.date_ineffective IS NULL)
                    AND (X_Date_Ineffective IS NULL)))
           AND (Recinfo.transaction_header_id_in =  X_Transaction_Header_Id_In)
           AND (   (Recinfo.transaction_header_id_out =
                         X_Transaction_Header_Id_Out)
                OR (    (Recinfo.transaction_header_id_out IS NULL)
                    AND (X_Transaction_Header_Id_Out IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2 DEFAULT NULL,
                       X_Asset_Id                       NUMBER   DEFAULT NULL,
                       X_Category_Id                    NUMBER   DEFAULT NULL,
                       X_Asset_Type                     VARCHAR2 DEFAULT NULL,
                       X_Units                          NUMBER   DEFAULT NULL,
                       X_Date_Effective                 DATE     DEFAULT NULL,
                       X_Date_Ineffective               DATE     DEFAULT NULL,
                       X_Transaction_Header_Id_In       NUMBER   DEFAULT NULL,
                       X_Transaction_Header_Id_Out      NUMBER   DEFAULT NULL,
                       X_Last_Update_Date               DATE     DEFAULT NULL,
                       X_Last_Updated_By                NUMBER   DEFAULT NULL,
                       X_Last_Update_Login              NUMBER   DEFAULT NULL,
                       X_Return_Status              OUT NOCOPY BOOLEAN,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  BEGIN

    If x_rowid is null then
      UPDATE fa_asset_history
      SET asset_id                        =     decode(X_Asset_Id,
                                                     NULL, asset_id,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Asset_Id),
        category_id                     =     decode(X_Category_Id,
                                                     NULL, category_id,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Category_Id),
        asset_type                      =     decode(X_Asset_Type,
                                                     NULL, asset_type,
                                                     FND_API.G_MISS_CHAR, null,
                                                     X_Asset_Type),
        units                           =     decode(X_Units,
                                                     NULL, units,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Units),
        date_effective                  =     decode(X_Date_Effective,
                                                     NULL, date_effective,
                                                     X_Date_Effective),
        date_ineffective                =     decode(X_Date_Ineffective,
                                                     NULL, date_ineffective,
                                                     X_Date_Ineffective),
        transaction_header_id_in        =     decode(X_Transaction_Header_Id_In,
                                                     NULL, transaction_header_id_in,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Transaction_Header_Id_In),
        transaction_header_id_out       =     decode(X_Transaction_Header_Id_Out,
                                                     NULL, transaction_header_id_out,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Transaction_Header_Id_Out),
        last_update_date                =     decode(X_Last_Update_Date,
                                                     NULL, last_update_date,
                                                     X_Last_Update_Date),
        last_updated_by                 =     decode(X_Last_Updated_By,
                                                     NULL, last_updated_by,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Last_Updated_By),
        last_update_login               =     decode(X_Last_Update_Login,
                                                     NULL, last_update_login,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Last_Update_Login)
      WHERE asset_id = X_asset_id and
            date_ineffective is null;

     else
      UPDATE fa_asset_history
      SET asset_id                        =     decode(X_Asset_Id,
                                                     NULL, asset_id,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Asset_Id),
        category_id                     =     decode(X_Category_Id,
                                                     NULL, category_id,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Category_Id),
        asset_type                      =     decode(X_Asset_Type,
                                                     NULL, asset_type,
                                                     FND_API.G_MISS_CHAR, null,
                                                     X_Asset_Type),
        units                           =     decode(X_Units,
                                                     NULL, units,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Units),
        date_effective                  =     decode(X_Date_Effective,
                                                     NULL, date_effective,
                                                     X_Date_Effective),
        date_ineffective                =     decode(X_Date_Ineffective,
                                                     NULL, date_ineffective,
                                                     X_Date_Ineffective),
        transaction_header_id_in        =     decode(X_Transaction_Header_Id_In,
                                                     NULL, transaction_header_id_in,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Transaction_Header_Id_In),
        transaction_header_id_out       =     decode(X_Transaction_Header_Id_Out,
                                                     NULL, transaction_header_id_out,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Transaction_Header_Id_Out),
        last_update_date                =     decode(X_Last_Update_Date,
                                                     NULL, last_update_date,
                                                     X_Last_Update_Date),
        last_updated_by                 =     decode(X_Last_Updated_By,
                                                     NULL, last_updated_by,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Last_Updated_By),
        last_update_login               =     decode(X_Last_Update_Login,
                                                     NULL, last_update_login,
                                                     FND_API.G_MISS_NUM, null,
                                                     X_Last_Update_Login)
      WHERE rowid = X_Rowid;

     end if;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_asset_history_pkg.update_row', p_log_level_rec => p_log_level_rec);
        raise;

/*  Commented out for better error handling after using trx engine
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
          CALLED_FN => 'fa_distribution_history_pkg.update_row',
          CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
*/

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid                VARCHAR2 DEFAULT NULL,
               X_Asset_Id                     NUMBER DEFAULT NULL,
               X_Transaction_Header_Id_In     NUMBER DEFAULT NULL,
               X_Calling_Fn                   VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    if X_Rowid is not null then
       DELETE FROM fa_asset_history
       WHERE rowid = X_Rowid;
    elsif X_Transaction_Header_Id_In is not null then
       DELETE FROM fa_asset_history
       WHERE asset_id = X_asset_id
       AND transaction_header_id_in = X_Transaction_Header_Id_In;
    elsif X_Asset_Id is not null then
       DELETE FROM fa_asset_history
       WHERE asset_id = X_Asset_Id;
    else
       -- print error message
       null;
    end if;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_asset_history_pkg.delete_row', p_log_level_rec => p_log_level_rec);
        raise;

/*  Commented out for better error handling after using trx engine
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
          CALLED_FN => 'fa_distribution_history_pkg.delete_row',
          CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
*/
  END Delete_Row;

  PROCEDURE Reactivate_Row(X_Transaction_Header_Id_Out     NUMBER,
                           X_asset_id                      NUMBER,
                           X_Calling_Fn                    VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN

     UPDATE fa_asset_history
     set Transaction_Header_Id_Out = null,
         date_ineffective = null
     where asset_id = X_asset_id
       and Transaction_Header_Id_Out = X_Transaction_Header_Id_Out;

     if (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
     end if;

  exception
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
          CALLED_FN => 'fa_distribution_history_pkg.reactivate_row',
          CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Reactivate_Row;

END FA_ASSET_HISTORY_PKG;

/
