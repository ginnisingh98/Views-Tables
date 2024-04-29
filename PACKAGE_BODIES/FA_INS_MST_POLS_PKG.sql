--------------------------------------------------------
--  DDL for Package Body FA_INS_MST_POLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INS_MST_POLS_PKG" AS
/* $Header: faxinsmb.pls 120.3.12010000.2 2009/07/19 10:27:20 glchen ship $ */


PROCEDURE Lock_Row(     X_Rowid                  VARCHAR2,
                        X_Asset_policy_id        NUMBER,
                        X_Policy_number          VARCHAR2,
                        X_Vendor_site_id         NUMBER,
                        X_Vendor_id              NUMBER,
                        X_Calculation_method     VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

		      CURSOR C IS
			SELECT 	*
			FROM	fa_ins_mst_pols
			WHERE	rowid = X_Rowid
			FOR UPDATE OF policy_number NOWAIT;

		      recinfo C%ROWTYPE;

BEGIN
  OPEN C;
  FETCH C INTO recinfo;
  IF C%NOTFOUND THEN
     CLOSE C;
     FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
     APP_EXCEPTION.Raise_Exception;
  END IF;
  CLOSE C;
  IF (
       	     (recinfo.asset_policy_id = X_Asset_policy_id)
	AND  (	(recinfo.policy_number = X_Policy_number)
	     OR (   (recinfo.policy_number IS NULL)
		AND (X_Policy_number IS NULL)))
	AND  (	(recinfo.vendor_site_id = X_Vendor_site_id)
	     OR (   (recinfo.vendor_site_id IS NULL)
		AND (X_Vendor_site_id IS NULL)))
	AND  (  (recinfo.vendor_id = X_Vendor_id)
	     OR (   (recinfo.vendor_site_id IS NULL)
		AND (X_Vendor_site_id IS NULL)))
	AND  (  (recinfo.calculation_method = X_Calculation_method)
	     OR (   (recinfo.calculation_method IS NULL)
		AND (X_Calculation_method IS NULL)))
      ) THEN
     RETURN;
  ELSE
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.Raise_Exception;
  END IF;
END Lock_Row;


PROCEDURE Update_Row(   X_Rowid                  VARCHAR2,
                        X_Asset_policy_id        NUMBER,
                        X_Policy_number          VARCHAR2,
                        X_Vendor_site_id         NUMBER,
                        X_Vendor_id              NUMBER,
                        X_Calculation_method     VARCHAR2,
                        X_Last_update_date       DATE,
                        X_Last_updated_by        VARCHAR2,
                        X_Last_update_login      VARCHAR2,
                        X_Creation_date          DATE,
                        X_Created_by             VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

  UPDATE fa_ins_mst_pols
  SET
     asset_policy_id		= X_Asset_policy_id,
     policy_number		= X_Policy_number,
     vendor_site_id		= X_Vendor_site_id,
     vendor_id			= X_Vendor_id,
     calculation_method		= X_Calculation_method,
     last_update_date		= X_Last_update_date,
     last_updated_by		= X_Last_updated_by,
     last_update_login		= X_Last_update_login,
     creation_date		= X_Creation_date,
     created_by			= X_Created_by
  WHERE rowid = X_Rowid;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;

  commit;

END Update_Row;


PROCEDURE Delete_Row(	X_asset_policy_id		NUMBER,
			X_Asset_id                      VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

 CURSOR C IS
       SELECT 1
       FROM   fa_ins_policies
       WHERE  asset_policy_id = X_asset_policy_id
       AND    asset_id <> X_Asset_id;

 dummy varchar2(1);

BEGIN

    OPEN C;
    FETCH C INTO dummy;
    IF C%NOTFOUND THEN
        DELETE FROM fa_ins_mst_pols
	WHERE asset_policy_id = X_asset_policy_id;

	IF (SQL%NOTFOUND) THEN
	   RAISE NO_DATA_FOUND;
	END IF;
    END IF;

    DELETE FROM fa_ins_lines
    WHERE asset_policy_id = X_asset_policy_id
    AND   asset_id = X_Asset_id;

--    commit;


    DELETE FROM fa_ins_policies
    WHERE asset_policy_id = X_asset_policy_id
    AND   asset_id = X_Asset_id;

    DELETE FROM fa_ins_values
    WHERE asset_policy_id = X_asset_policy_id
    AND   asset_id = X_Asset_id;


    commit;

END Delete_Row;

END FA_INS_MST_POLS_PKG;

/
