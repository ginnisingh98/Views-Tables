--------------------------------------------------------
--  DDL for Package Body FA_LEASES2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_LEASES2_PKG" as
/* $Header: faxils2b.pls 120.3.12010000.2 2009/07/19 10:37:52 glchen ship $ */

/* Bug 1782129 : Added a new column TERMS_ID in fa_leases
and fa_lease_payment_items tables. Terms_ID is a unique identifier
for AP Payment Term. - YYOON 5/21/01
*/
PROCEDURE INSERT_ROW( X_Rowid    IN OUT NOCOPY  VARCHAR2,
              X_Lease_id           NUMBER,
              X_lease_number       VARCHAR2,
              X_lessor_id          NUMBER,
              X_description         VARCHAR2,
              X_last_update_date    DATE,
              X_last_updated_by     NUMBER,
              X_created_by          NUMBER,
              X_creation_date       DATE,
              X_last_update_login   NUMBER,
              X_attribute1          VARCHAR2,
              X_attribute2          VARCHAR2,
              X_attribute3          VARCHAR2,
              X_attribute4          VARCHAR2,
              X_attribute5          VARCHAR2,
              X_attribute6          VARCHAR2,
              X_attribute7          VARCHAR2,
              X_attribute8          VARCHAR2,
              X_attribute9          VARCHAR2,
              X_attribute10         VARCHAR2,
              X_attribute11         VARCHAR2,
              X_attribute12         VARCHAR2,
              X_attribute13         VARCHAR2,
              X_attribute14         VARCHAR2,
              X_attribute15         VARCHAR2,
              X_attribute_category_code  VARCHAR2,
              X_FASB_LEASE_TYPE     VARCHAR2,
              X_COST_CAPITALIZED    NUMBER,
              X_TRANSFER_OWNERSHIP  VARCHAR2,
              X_BARGAIN_PURCHASE_OPTION  VARCHAR2,
              X_PAYMENT_SCHEDULE_ID  NUMBER,
              X_FAIR_VALUE           NUMBER,
              X_PRESENT_VALUE        NUMBER,
              X_LEASE_TYPE           VARCHAR2,
              X_LEASE_TERM           NUMBER,
              X_ASSET_LIFE           NUMBER,
              X_CURRENCY_CODE        VARCHAR2,
              X_LESSOR_SITE_ID	     NUMBER,
              X_DIST_CODE_COMBINATION_ID    NUMBER,
              X_TERMS_ID             NUMBER,
              X_Calling_Fn           VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS SELECT rowid FROM fa_leases
                 WHERE lease_id = X_Lease_Id;
BEGIN

    INSERT INTO fa_leases(
              lease_id,
              lease_number,
              lessor_id,
              description,
              last_update_date,
              last_updated_by,
              created_by,
              creation_date,
              last_update_login,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              attribute_category_code,
              FASB_LEASE_TYPE,
              COST_CAPITALIZED,
              TRANSFER_OWNERSHIP,
              BARGAIN_PURCHASE_OPTION,
              PAYMENT_SCHEDULE_ID,
              FAIR_VALUE,
              PRESENT_VALUE,
              LEASE_TYPE,
              LEASE_TERM,
              ASSET_LIFE,
              CURRENCY_CODE,
              LESSOR_SITE_ID,
              DIST_CODE_COMBINATION_ID,
              TERMS_ID)
     VALUES (
               X_lease_id,
               X_lease_number,
               X_lessor_id,
               X_description,
               X_last_update_date,
               X_last_updated_by,
               X_created_by,
               X_creation_date,
               X_last_update_login,
               X_attribute1,
               X_attribute2,
               X_attribute3,
               X_attribute4,
               X_attribute5,
               X_attribute6,
               X_attribute7,
               X_attribute8,
               X_attribute9,
               X_attribute10,
               X_attribute11,
               X_attribute12,
               X_attribute13,
               X_attribute14,
               X_attribute15,
               X_attribute_category_code,
               X_FASB_LEASE_TYPE,
               X_COST_CAPITALIZED,
               X_TRANSFER_OWNERSHIP,
               X_BARGAIN_PURCHASE_OPTION,
               X_PAYMENT_SCHEDULE_ID,
               X_FAIR_VALUE,
               X_PRESENT_VALUE,
               X_LEASE_TYPE,
               X_LEASE_TERM,
               X_ASSET_LIFE,
               X_CURRENCY_CODE,
               X_LESSOR_SITE_ID,
               X_DIST_CODE_COMBINATION_ID,
               X_TERMS_ID);

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  EXCEPTION
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn	=> 'FA_LEASES2_PKG.Insert_Row',
			Calling_Fn	=> X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Insert_Row;


PROCEDURE Lock_Row( X_Rowid    IN OUT NOCOPY  VARCHAR2,
              X_Lease_id           NUMBER,
              X_lease_number       VARCHAR2,
              X_lessor_id          NUMBER,
              X_description         VARCHAR2,
              X_last_update_date    DATE,
              X_last_updated_by     NUMBER,
              X_created_by          NUMBER,
              X_creation_date       DATE,
              X_last_update_login   NUMBER,
              X_attribute1          VARCHAR2,
              X_attribute2          VARCHAR2,
              X_attribute3          VARCHAR2,
              X_attribute4          VARCHAR2,
              X_attribute5          VARCHAR2,
              X_attribute6          VARCHAR2,
              X_attribute7          VARCHAR2,
              X_attribute8          VARCHAR2,
              X_attribute9          VARCHAR2,
              X_attribute10         VARCHAR2,
              X_attribute11         VARCHAR2,
              X_attribute12         VARCHAR2,
              X_attribute13         VARCHAR2,
              X_attribute14         VARCHAR2,
              X_attribute15         VARCHAR2,
              X_attribute_category_code  VARCHAR2,
              X_FASB_LEASE_TYPE     VARCHAR2,
              X_COST_CAPITALIZED    NUMBER,
              X_TRANSFER_OWNERSHIP  VARCHAR2,
              X_BARGAIN_PURCHASE_OPTION  VARCHAR2,
              X_PAYMENT_SCHEDULE_ID  NUMBER,
              X_FAIR_VALUE           NUMBER,
              X_PRESENT_VALUE        NUMBER,
              X_LEASE_TYPE           VARCHAR2,
              X_LEASE_TERM           NUMBER,
              X_ASSET_LIFE           NUMBER,
              X_CURRENCY_CODE        VARCHAR2,
              X_Calling_Fn           VARCHAR2


  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    CURSOR C IS
        SELECT *
        FROM   fa_leases
        WHERE  rowid = X_Rowid
        FOR UPDATE of Lease_Id NOWAIT;
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
               (Recinfo.lease_id =  X_Lease_Id)
           AND (Recinfo.lease_number =  X_Lease_Number)
           AND (Recinfo.lessor_id =  X_Lessor_Id)
           AND (Recinfo.description =  X_Description)
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND ((Recinfo.attribute_category_code =  X_Attribute_Category_Code)
                OR (    (Recinfo.attribute_category_code IS NULL)
                    AND (X_Attribute_Category_Code IS NULL)))

           AND (   (Recinfo.fasb_lease_type = X_Fasb_lease_type)
                OR (    (Recinfo.fasb_lease_type IS NULL)
                    AND (X_fasb_lease_type IS NULL)))
           AND (   (Recinfo.cost_capitalized = X_cost_capitalized)
                OR (    (Recinfo.cost_capitalized IS NULL)
                    AND (X_cost_capitalized IS NULL)))
           AND (   (Recinfo.transfer_ownership = X_Transfer_ownership)
                OR (    (Recinfo.transfer_ownership IS NULL)
                    AND (X_transfer_ownership IS NULL)))
           AND (   (Recinfo.bargain_purchase_option = X_bargain_purchase_option)
                OR (    (Recinfo.bargain_purchase_option IS NULL)
                    AND (X_bargain_purchase_option IS NULL)))
           AND (   (Recinfo.payment_schedule_id = X_payment_schedule_id)
                OR (    (Recinfo.payment_schedule_id IS NULL)
                    AND (X_payment_schedule_id IS NULL)))
           AND (   (Recinfo.fair_value = X_fair_value)
               OR (    (Recinfo.fair_value IS NULL)
                    AND (X_fair_value IS NULL)))
           AND (  (Recinfo.present_value = X_present_value)
               OR (    (Recinfo.present_value IS NULL)
                    AND (X_present_value IS NULL)))

           AND (Recinfo.lease_type = X_lease_type)

           AND (  (Recinfo.lease_term = X_lease_term)
               OR (    (Recinfo.lease_term IS NULL)
                    AND (X_lease_term IS NULL)))
           AND (  (Recinfo.asset_life = X_asset_life)
               OR (    (Recinfo.asset_life IS NULL)
                    AND (X_asset_life IS NULL)))
           AND (Recinfo.currency_code = X_currency_code)

      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    exception
       when others then
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
          APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

PROCEDURE Update_Row( X_Rowid    IN OUT NOCOPY  VARCHAR2,
              X_Lease_id           NUMBER,
              X_lease_number       VARCHAR2,
              X_lessor_id          NUMBER,
              X_description         VARCHAR2,
              X_last_update_date    DATE,
              X_last_updated_by     NUMBER,
              X_created_by          NUMBER,
              X_creation_date       DATE,
              X_last_update_login   NUMBER,
              X_attribute1          VARCHAR2,
              X_attribute2          VARCHAR2,
              X_attribute3          VARCHAR2,
              X_attribute4          VARCHAR2,
              X_attribute5          VARCHAR2,
              X_attribute6          VARCHAR2,
              X_attribute7          VARCHAR2,
              X_attribute8          VARCHAR2,
              X_attribute9          VARCHAR2,
              X_attribute10         VARCHAR2,
              X_attribute11         VARCHAR2,
              X_attribute12         VARCHAR2,
              X_attribute13         VARCHAR2,
              X_attribute14         VARCHAR2,
              X_attribute15         VARCHAR2,
              X_attribute_category_code  VARCHAR2,
              X_FASB_LEASE_TYPE     VARCHAR2,
              X_COST_CAPITALIZED    NUMBER,
              X_TRANSFER_OWNERSHIP  VARCHAR2,
              X_BARGAIN_PURCHASE_OPTION  VARCHAR2,
              X_PAYMENT_SCHEDULE_ID  NUMBER,
              X_FAIR_VALUE           NUMBER,
              X_PRESENT_VALUE        NUMBER,
              X_LEASE_TYPE           VARCHAR2,
              X_LEASE_TERM           NUMBER,
              X_ASSET_LIFE           NUMBER,
              X_CURRENCY_CODE        VARCHAR2,
              X_LESSOR_SITE_ID       NUMBER,
              X_DIST_CODE_COMBINATION_ID    NUMBER,
              X_TERMS_ID             NUMBER,
              X_Calling_Fn           VARCHAR2

  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    UPDATE fa_leases
    SET
              lease_id           = X_lease_id,
              lease_number       = X_lease_number,
              lessor_id          = X_lessor_id,
              description        = X_description,
              last_update_date   = X_last_update_date,
              last_updated_by    = X_last_updated_by,
              created_by         = X_created_by,
              creation_date      = X_creation_date,
              last_update_login  = X_last_update_login,
              attribute1         = X_attribute1,
              attribute2         = X_attribute2,
              attribute3         = X_attribute3,
              attribute4         = X_attribute4,
              attribute5         = X_attribute5,
              attribute6         = X_attribute6,
              attribute7         = X_attribute7,
              attribute8         = X_attribute8,
              attribute9         = X_attribute9,
              attribute10         = X_attribute10,
              attribute11         = X_attribute11,
              attribute12         = X_attribute12,
              attribute13         = X_attribute13,
              attribute14         = X_attribute14,
              attribute15         = X_attribute15,
              attribute_category_code = X_attribute_category_code,
              FASB_LEASE_TYPE     = X_fasb_lease_type,
              COST_CAPITALIZED    = X_cost_capitalized,
              TRANSFER_OWNERSHIP  = X_transfer_ownership,
              BARGAIN_PURCHASE_OPTION  = X_bargain_purchase_option,
              PAYMENT_SCHEDULE_ID      = X_payment_schedule_id,
              FAIR_VALUE          = X_fair_value,
              PRESENT_VALUE       = X_present_value,
              LEASE_TYPE          = X_lease_type,
              LEASE_TERM          = X_lease_term,
              ASSET_LIFE          = X_asset_life,
              CURRENCY_CODE       = X_CURRENCY_CODE,
              LESSOR_SITE_ID	  = X_LESSOR_SITE_ID,
              DIST_CODE_COMBINATION_ID  = X_DIST_CODE_COMBINATION_ID,
              TERMS_ID            = X_TERMS_ID
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn	=> 'FA_LEASES_PKG.Update_Row',
			Calling_Fn	=> X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Update_Row;
  --
  PROCEDURE Delete_Row(X_Rowid 		VARCHAR2 DEFAULT NULL,
			X_Lease_Id	NUMBER DEFAULT NULL,
			X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    if X_Rowid is not null then
    	DELETE FROM fa_leases
    	WHERE rowid = X_Rowid;
    elsif X_Lease_Id is not null then
	DELETE FROM fa_leases
	WHERE lease_id = X_Lease_Id;
    else
	-- error
	null;
    end if;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn	=> 'FA_LEASES_PKG.Delete_Row',
			Calling_Fn	=> X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Delete_Row;


END FA_LEASES2_PKG;

/
