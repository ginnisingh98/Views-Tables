--------------------------------------------------------
--  DDL for Package Body FA_INS_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INS_LINES_PKG" AS
/* $Header: faxinslb.pls 120.3.12010000.2 2009/07/19 10:26:25 glchen ship $ */

PROCEDURE Insert_Row(   X_Rowid                  IN OUT NOCOPY VARCHAR2,
			X_Asset_policy_id	 NUMBER,
			X_Vendor_id		 NUMBER,
			X_Policy_number		 VARCHAR2,
			X_Asset_id		 NUMBER,
                        X_policy_line            NUMBER,
                        X_insurance_category     VARCHAR2,
                        X_hazard_class           VARCHAR2,
                        X_comments               VARCHAR2,
                        X_Last_update_date       DATE,
                        X_Last_updated_by        VARCHAR2,
                        X_Last_update_login      VARCHAR2,
                        X_Creation_date          DATE,
                        X_Created_by             VARCHAR2,
                        X_Attribute_category     VARCHAR2,
                        X_Attribute1             VARCHAR2,
                        X_Attribute2             VARCHAR2,
                        X_Attribute3             VARCHAR2,
                        X_Attribute4             VARCHAR2,
                        X_Attribute5             VARCHAR2,
                        X_Attribute6             VARCHAR2,
                        X_Attribute7             VARCHAR2,
                        X_Attribute8             VARCHAR2,
                        X_Attribute9             VARCHAR2,
                        X_Attribute10            VARCHAR2,
                        X_Attribute11            VARCHAR2,
                        X_Attribute12            VARCHAR2,
                        X_Attribute13            VARCHAR2,
                        X_Attribute14            VARCHAR2,
                        X_Attribute15            VARCHAR2,
                        X_Attribute16            VARCHAR2,
                        X_Attribute17            VARCHAR2,
                        X_Attribute18            VARCHAR2,
                        X_Attribute19            VARCHAR2,
                        X_Attribute20            VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

CURSOR C IS SELECT rowid FROM fa_ins_lines
    WHERE asset_policy_id = X_Asset_policy_id;

BEGIN
   INSERT INTO fa_ins_lines
	(
	asset_policy_id,
        vendor_id,
	policy_number,
	asset_id,
	policy_line,
	insurance_category,
	hazard_class,
	comments,
	last_update_date,
	last_updated_by,
	last_update_login,
	creation_date,
	created_by,
        attribute_category,
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
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20
	)
	VALUES
	(
	X_Asset_policy_id,
	X_Vendor_id,
	X_Policy_number,
	X_Asset_id,
        X_Policy_line,
        X_Insurance_category,
        X_Hazard_class,
        X_Comments,
	X_Last_update_date,
	X_Last_updated_by,
	X_Last_update_login,
	X_Creation_date,
	X_Created_by,
        X_Attribute_category,
        X_Attribute1,
        X_Attribute2,
        X_Attribute3,
        X_Attribute4,
        X_Attribute5,
        X_Attribute6,
        X_Attribute7,
        X_Attribute8,
        X_Attribute9,
        X_Attribute10,
        X_Attribute11,
        X_Attribute12,
        X_Attribute13,
        X_Attribute14,
        X_Attribute15,
        X_Attribute16,
        X_Attribute17,
        X_Attribute18,
        X_Attribute19,
        X_Attribute20
	);

-- Check to see whether insert was successful

OPEN C;

FETCH C INTO X_Rowid;

IF C%NOTFOUND THEN
   CLOSE C;
   RAISE NO_DATA_FOUND;
END IF;

CLOSE C;

END Insert_Row;


PROCEDURE Lock_Row(     X_Rowid                  VARCHAR2,
                        X_Asset_policy_id        NUMBER,
                        X_Vendor_id              NUMBER,
                        X_Policy_number          VARCHAR2,
                        X_Asset_id               NUMBER,
                        X_policy_line            NUMBER,
                        X_insurance_category     VARCHAR2,
                        X_hazard_class           VARCHAR2,
                        X_comments               VARCHAR2,
                        X_Last_update_date       DATE,
                        X_Last_updated_by        VARCHAR2,
                        X_Last_update_login      VARCHAR2,
                        X_Creation_date          DATE,
                        X_Created_by             VARCHAR2,
                        X_Attribute_category     VARCHAR2,
                        X_Attribute1             VARCHAR2,
                        X_Attribute2             VARCHAR2,
                        X_Attribute3             VARCHAR2,
                        X_Attribute4             VARCHAR2,
                        X_Attribute5             VARCHAR2,
                        X_Attribute6             VARCHAR2,
                        X_Attribute7             VARCHAR2,
                        X_Attribute8             VARCHAR2,
                        X_Attribute9             VARCHAR2,
                        X_Attribute10            VARCHAR2,
                        X_Attribute11            VARCHAR2,
                        X_Attribute12            VARCHAR2,
                        X_Attribute13            VARCHAR2,
                        X_Attribute14            VARCHAR2,
                        X_Attribute15            VARCHAR2,
                        X_Attribute16            VARCHAR2,
                        X_Attribute17            VARCHAR2,
                        X_Attribute18            VARCHAR2,
                        X_Attribute19            VARCHAR2,
                        X_Attribute20            VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

		      CURSOR C IS
			SELECT 	*
			FROM	fa_ins_lines
			WHERE	rowid = X_Rowid
			FOR UPDATE OF vendor_id NOWAIT;

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
       	     (recinfo.vendor_id = X_vendor_id)
        AND  (  (recinfo.policy_number = X_policy_number)
             OR (   (recinfo.policy_number IS NULL)
                AND (X_policy_number IS NULL)))
        AND  (  (recinfo.asset_id = X_asset_id)
             OR (   (recinfo.asset_id IS NULL)
                AND (X_asset_id IS NULL)))
	AND  (	(recinfo.policy_line = X_policy_line)
	     OR (   (recinfo.policy_line IS NULL)
		AND (X_policy_line IS NULL)))
	AND  (	(recinfo.insurance_category = X_insurance_category)
	     OR (   (recinfo.insurance_category IS NULL)
		AND (X_insurance_category IS NULL)))
	AND  (	(recinfo.hazard_class = X_hazard_class)
	     OR (   (recinfo.hazard_class IS NULL)
		AND (X_hazard_class IS NULL)))
	AND  (	(recinfo.comments = X_comments)
	     OR (   (recinfo.comments IS NULL)
		AND (X_comments IS NULL)))
        AND  (  (recinfo.attribute_category = X_Attribute_category)
             OR (   (recinfo.attribute_category IS NULL)
                AND (X_Attribute_category IS NULL)))
        AND  (  (recinfo.attribute1 = X_attribute1)
             OR (   (recinfo.attribute1 IS NULL)
                AND (X_Attribute1 IS NULL)))
        AND  (  (recinfo.attribute2 = X_attribute2)
             OR (   (recinfo.attribute2 IS NULL)
                AND (X_Attribute2 IS NULL)))
        AND  (  (recinfo.attribute3 = X_attribute3)
             OR (   (recinfo.attribute3 IS NULL)
                AND (X_Attribute3 IS NULL)))
        AND  (  (recinfo.attribute4 = X_attribute4)
             OR (   (recinfo.attribute4 IS NULL)
                AND (X_Attribute4 IS NULL)))
        AND  (  (recinfo.attribute5 = X_attribute5)
             OR (   (recinfo.attribute5 IS NULL)
                AND (X_Attribute5 IS NULL)))
        AND  (  (recinfo.attribute6 = X_attribute6)
             OR (   (recinfo.attribute6 IS NULL)
                AND (X_Attribute6 IS NULL)))
        AND  (  (recinfo.attribute7 = X_attribute7)
             OR (   (recinfo.attribute7 IS NULL)
                AND (X_Attribute7 IS NULL)))
        AND  (  (recinfo.attribute8 = X_attribute8)
             OR (   (recinfo.attribute8 IS NULL)
                AND (X_Attribute8 IS NULL)))
        AND  (  (recinfo.attribute9 = X_attribute9)
             OR (   (recinfo.attribute9 IS NULL)
                AND (X_Attribute9 IS NULL)))
        AND  (  (recinfo.attribute10 = X_attribute10)
             OR (   (recinfo.attribute10 IS NULL)
                AND (X_Attribute10 IS NULL)))
        AND  (  (recinfo.attribute11 = X_attribute11)
             OR (   (recinfo.attribute11 IS NULL)
                AND (X_Attribute11 IS NULL)))
        AND  (  (recinfo.attribute12 = X_attribute12)
             OR (   (recinfo.attribute12 IS NULL)
                AND (X_Attribute12 IS NULL)))
        AND  (  (recinfo.attribute13 = X_attribute13)
             OR (   (recinfo.attribute13 IS NULL)
                AND (X_Attribute13 IS NULL)))
        AND  (  (recinfo.attribute14 = X_attribute14)
             OR (   (recinfo.attribute14 IS NULL)
                AND (X_Attribute14 IS NULL)))
        AND  (  (recinfo.attribute15 = X_attribute15)
             OR (   (recinfo.attribute15 IS NULL)
                AND (X_Attribute15 IS NULL)))
        AND  (  (recinfo.attribute16 = X_attribute16)
             OR (   (recinfo.attribute16 IS NULL)
                AND (X_Attribute16 IS NULL)))
        AND  (  (recinfo.attribute17 = X_attribute17)
             OR (   (recinfo.attribute17 IS NULL)
                AND (X_Attribute17 IS NULL)))
        AND  (  (recinfo.attribute18 = X_attribute18)
             OR (   (recinfo.attribute18 IS NULL)
                AND (X_Attribute18 IS NULL)))
        AND  (  (recinfo.attribute19 = X_attribute19)
             OR (   (recinfo.attribute19 IS NULL)
                AND (X_Attribute19 IS NULL)))
        AND  (  (recinfo.attribute20 = X_attribute20)
             OR (   (recinfo.attribute20 IS NULL)
                AND (X_Attribute20 IS NULL)))
      ) THEN
     RETURN;
  ELSE
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.Raise_Exception;
  END IF;
END Lock_Row;


PROCEDURE Update_Row(   X_Rowid                  VARCHAR2,
                        X_Asset_policy_id        NUMBER,
                        X_Vendor_id              NUMBER,
                        X_Policy_number          VARCHAR2,
                        X_Asset_id               NUMBER,
                        X_policy_line            NUMBER,
                        X_insurance_category     VARCHAR2,
                        X_hazard_class           VARCHAR2,
                        X_comments               VARCHAR2,
                        X_Last_update_date       DATE,
                        X_Last_updated_by        VARCHAR2,
                        X_Last_update_login      VARCHAR2,
                        X_Creation_date          DATE,
                        X_Created_by             VARCHAR2,
                        X_Attribute_category     VARCHAR2,
                        X_Attribute1             VARCHAR2,
                        X_Attribute2             VARCHAR2,
                        X_Attribute3             VARCHAR2,
                        X_Attribute4             VARCHAR2,
                        X_Attribute5             VARCHAR2,
                        X_Attribute6             VARCHAR2,
                        X_Attribute7             VARCHAR2,
                        X_Attribute8             VARCHAR2,
                        X_Attribute9             VARCHAR2,
                        X_Attribute10            VARCHAR2,
                        X_Attribute11            VARCHAR2,
                        X_Attribute12            VARCHAR2,
                        X_Attribute13            VARCHAR2,
                        X_Attribute14            VARCHAR2,
                        X_Attribute15            VARCHAR2,
                        X_Attribute16            VARCHAR2,
                        X_Attribute17            VARCHAR2,
                        X_Attribute18            VARCHAR2,
                        X_Attribute19            VARCHAR2,
                        X_Attribute20            VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

  UPDATE fa_ins_lines
  SET
     asset_policy_id 		= X_Asset_policy_id,
     vendor_id			= X_vendor_id,
     policy_number		= X_policy_number,
     asset_id			= X_asset_id,
     policy_line		= X_policy_line,
     insurance_category		= X_insurance_category,
     hazard_class		= X_hazard_class,
     comments			= X_comments,
     last_update_date		= X_Last_update_date,
     last_updated_by		= X_Last_updated_by,
     last_update_login		= X_Last_update_login,
     creation_date		= X_Creation_date,
     created_by			= X_Created_by,
     attribute_category         = X_Attribute_category,
     attribute1                 = X_Attribute1,
     attribute2                 = X_Attribute2,
     attribute3                 = X_Attribute3,
     attribute4                 = X_Attribute4,
     attribute5                 = X_Attribute5,
     attribute6                 = X_Attribute6,
     attribute7                 = X_Attribute7,
     attribute8                 = X_Attribute8,
     attribute9                 = X_Attribute9,
     attribute10                = X_Attribute10,
     attribute11                = X_Attribute11,
     attribute12                = X_Attribute12,
     attribute13                = X_Attribute13,
     attribute14                = X_Attribute14,
     attribute15                = X_Attribute15,
     attribute16                = X_Attribute16,
     attribute17                = X_Attribute17,
     attribute18                = X_Attribute18,
     attribute19                = X_Attribute19,
     attribute20                = X_Attribute20
  WHERE rowid = X_Rowid;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;


PROCEDURE Delete_Row(	X_Rowid		VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

	DELETE FROM fa_ins_lines
	WHERE rowid = X_Rowid;

	IF (SQL%NOTFOUND) THEN
	   RAISE NO_DATA_FOUND;
	END IF;

END Delete_Row;

END FA_INS_LINES_PKG;

/
