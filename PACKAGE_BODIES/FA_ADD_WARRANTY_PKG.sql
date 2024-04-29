--------------------------------------------------------
--  DDL for Package Body FA_ADD_WARRANTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ADD_WARRANTY_PKG" AS
/* $Header: FAADDWRB.pls 120.2.12010000.2 2009/07/19 12:35:24 glchen ship $ */

  PROCEDURE Update_Table(WR_warranty_id      NUMBER,
                     WR_old_warranty_id      NUMBER,
		     WR_asset_id         NUMBER,
		     WR_date_effective   DATE DEFAULT sysdate,
		     WR_date_ineffective  DATE,
		     WR_last_update_date DATE,
		     WR_last_updated_by  NUMBER,
		     WR_created_by       NUMBER DEFAULT -1,
		     WR_creation_date    DATE DEFAULT sysdate,
		     WR_last_update_login NUMBER DEFAULT -1,
		     WR_update_row       VARCHAR2,
		     WR_insert_row       VARCHAR2,
		     WR_calling_fn	 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)   IS

	h_date_effective 	DATE;
	h_last_update_date	DATE;
	h_last_updated_by	NUMBER;
  BEGIN

	--Assigning the values to the parameters explicitly because the 'DEFAULT'
	--clause in the formal parameters definition does not work.
	h_date_effective   := WR_date_effective;
	h_last_update_date := WR_last_update_date;
	h_last_updated_by  := WR_last_updated_by;

	IF (h_date_effective IS NULL) THEN
		h_date_effective := sysdate;
	END IF;

	IF (h_last_update_date IS NULL) THEN
		h_last_update_date := sysdate;
	END IF;

	IF (h_last_updated_by IS NULL) THEN
		h_last_updated_by := -1;
	END IF;


	IF (WR_update_row = 'YES') THEN
 	 	Update_Row(X_old_warranty_id    =>WR_old_warranty_id ,
		     X_asset_id         =>WR_asset_id,
		     X_date_ineffective =>WR_date_ineffective,
		     X_last_update_date =>h_last_update_date,
		     X_last_updated_by  =>h_last_updated_by ,
		     X_last_update_login=>WR_last_update_login ,
		     X_calling_fn	=>'FA_ADD_WARRANTY_PKG.Update_Table', p_log_level_rec => p_log_level_rec);
	END IF;

	IF (WR_insert_row = 'YES') THEN
	  	Insert_Row(X_warranty_id=>WR_warranty_id ,
		     X_asset_id         =>WR_asset_id,
		     X_date_effective   =>h_date_effective ,
		     X_last_update_date =>h_last_update_date,
		     X_last_updated_by  =>h_last_updated_by ,
		     X_created_by       =>WR_created_by,
		     X_creation_date    =>WR_creation_date,
		     X_last_update_login=>WR_last_update_login ,
		     X_calling_fn	=>'FA_ADD_WARRANTY_PKG.Update_Table', p_log_level_rec => p_log_level_rec);
	END IF;

  EXCEPTION
	WHEN OTHERS THEN
      	FA_STANDARD_PKG.RAISE_ERROR(
				CALLED_FN => 'FA_INS_WARRANTY_PKG.Update_Table',
				CALLING_FN => WR_calling_fn, p_log_level_rec => p_log_level_rec);
  END Update_Table;



--------------------------------------------------------------------------------------

  PROCEDURE Update_Row(X_old_warranty_id     NUMBER,
		     X_asset_id          NUMBER,
		     X_date_ineffective  DATE DEFAULT sysdate,
		     X_last_update_date  DATE DEFAULT sysdate,
		     X_last_updated_by   NUMBER DEFAULT -1,
		     X_last_update_login NUMBER DEFAULT -1,
		     X_calling_fn	 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
  	UPDATE fa_add_warranties
	SET date_ineffective = X_date_ineffective,
	    last_update_date = X_last_update_date,
	    last_updated_by  = X_last_updated_by,
	    last_update_login= X_last_update_login
	WHERE asset_id = X_asset_id
	AND   warranty_id =  X_old_warranty_id
	AND   date_ineffective IS NULL;

  EXCEPTION
	WHEN OTHERS THEN
	      	FA_STANDARD_PKG.RAISE_ERROR(
				CALLED_FN => 'FA_INS_WARRANTY_PKG.Update_Row',
				CALLING_FN => X_calling_fn, p_log_level_rec => p_log_level_rec);
  END Update_Row;


--------------------------------------------------------------------------------------

  PROCEDURE Insert_Row(X_warranty_id      NUMBER,
		     X_asset_id         NUMBER,
		     X_date_effective   DATE,
		     X_last_update_date DATE,
		     X_last_updated_by  NUMBER,
		     X_created_by       NUMBER DEFAULT -1,
		     X_creation_date    DATE DEFAULT sysdate,
		     X_last_update_login NUMBER DEFAULT -1,
		     X_calling_fn	 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)   IS
  BEGIN
	INSERT INTO fa_add_warranties(
	warranty_id,
	asset_id,
	date_effective,
	last_update_date,
	last_updated_by,
	created_by,
	creation_date,
	last_update_login)
	VALUES (X_warranty_id,
		X_asset_id,
		X_date_effective,
		X_last_update_date,
		X_last_updated_by,
		X_created_by,
		X_creation_date,
		X_last_update_login);
  EXCEPTION
	when others then
      	FA_STANDARD_PKG.RAISE_ERROR(
				CALLED_FN => 'FA_INS_WARRANTY_PKG.Insert_Row',
				CALLING_FN => X_calling_fn, p_log_level_rec => p_log_level_rec);
  END Insert_Row;


END FA_ADD_WARRANTY_PKG;

/
