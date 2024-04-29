--------------------------------------------------------
--  DDL for Package Body FA_INVENTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INVENTORY_PKG" as
/* $Header: faxpidmb.pls 120.3.12010000.2 2009/07/19 09:58:38 glchen ship $ */

PROCEDURE Lock_Row(X_Rowid			IN OUT NOCOPY  VARCHAR2,
		   X_inventory_id			NUMBER,
	           X_Calling_Fn			        VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
 cursor c_inv is
 SELECT *
 FROM FA_INV_INTERFACE
 WHERE ROWID = X_ROWID
 FOR UPDATE OF STATUS NOWAIT;
 Recinfo c_inv%rowtype;

Begin
 Open c_inv;
 Fetch c_inv into recinfo;
 IF (c_inv%notfound) then
   close c_inv;
   fnd_message.set_name('FND','FORM_RECORD_DELETED');
   app_exception.raise_exception;

 End if;
 Close c_inv;
--
    if (
       (recinfo.inventory_id = X_inventory_id)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
		       X_inventory_id			number,
		       X_unit_rec_mth_lookup_code	VARCHAR2,
		       X_loc_rec_mth_lookup_code	VARCHAR2,
		       X_status_lookup_code		VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
		       X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    if X_Rowid is not null then
     UPDATE fa_inv_interface
     SET
	unit_reconcile_mth    = X_unit_rec_mth_lookup_code,
	loc_reconcile_mth     = X_loc_rec_mth_lookup_code,
	status		      = X_status_lookup_code,
	Last_Update_Date      = X_Last_Update_Date ,
        Last_Updated_By	      = X_Last_Updated_By,
	Last_Update_Login     = X_Last_Update_Login
     WHERE rowid = X_Rowid;
    else
     UPDATE fa_inv_interface
     SET
	unit_reconcile_mth    = X_unit_rec_mth_lookup_code,
	loc_reconcile_mth     = X_loc_rec_mth_lookup_code,
	status		      = X_status_lookup_code,
	Last_Update_Date      = X_Last_Update_Date ,
        Last_Updated_By	      = X_Last_Updated_By,
	Last_Update_Login     = X_Last_Update_Login
       where inventory_id = x_inventory_id;
    end if;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn	=> 'FA_INVENTORY_PKG.Update_Row',
			Calling_Fn	=> X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Update_Row;
  --

END FA_INVENTORY_PKG;

/
