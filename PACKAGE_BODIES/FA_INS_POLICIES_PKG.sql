--------------------------------------------------------
--  DDL for Package Body FA_INS_POLICIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INS_POLICIES_PKG" AS
/* $Header: faxinspb.pls 120.3.12010000.2 2009/07/19 10:28:16 glchen ship $ */


PROCEDURE Get_Calculation_Method (X_Vendor_id   NUMBER,
						    X_Policy_number VARCHAR2,
						    X_Asset_policy_id IN OUT NOCOPY NUMBER,
						    X_Calculation_method IN OUT NOCOPY VARCHAR2,
					         X_Vendor_site_code IN OUT NOCOPY VARCHAR2,
						    X_Vendor_Site_id IN OUT NOCOPY NUMBER
						    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

 CURSOR C (X_vendor_id NUMBER, X_Policy_number VARCHAR2) IS
	SELECT pol.calculation_method,
		  pol.Vendor_Site_code,
		  pol.vendor_site_id,
		  nvl(pol.asset_policy_id,0)
    FROM    fa_ins_mst_pols_v pol
    WHERE   pol.vendor_id = X_Vendor_id
    AND     pol.policy_number = X_Policy_number
    ;


BEGIN

  OPEN C (X_Vendor_id, X_Policy_number);

  FETCH C into X_Calculation_method, X_Vendor_site_code, X_vendor_site_id,
			X_Asset_policy_id;

  IF SQL%NOTFOUND THEN
	X_Asset_policy_id := 0;
  END IF;

  CLOSE C;

END Get_Calculation_Method;

PROCEDURE Insert_Row(   X_Rowid 		  IN OUT NOCOPY VARCHAR2,
                        X_Asset_policy_id         IN OUT NOCOPY NUMBER,
                        X_Asset_id                VARCHAR2,
                        X_Book_type_code          VARCHAR2,
                        X_Policy_number           VARCHAR2,
                        X_Vendor_site_id          NUMBER,
                        X_Vendor_id               NUMBER,
                        X_Calculation_method      VARCHAR2,
				    X_Current_insurance_value NUMBER,
                        X_Base_insurance_value    NUMBER,
                        X_Base_index_date         DATE,
                        X_Current_price_index_id  NUMBER,
                        X_Last_indexation_id      NUMBER,
                        X_Insured_amount          NUMBER,
			X_Swiss_Building	  VARCHAR2,
			X_Last_update_date	  DATE,
			X_Last_updated_by	  VARCHAR2,
			X_Last_update_login	  VARCHAR2,
			X_Creation_date		  DATE,
			X_Created_by		  VARCHAR2,
			X_Attribute_category	  VARCHAR2,
			X_Attribute1 		  VARCHAR2,
			X_Attribute2 		  VARCHAR2,
			X_Attribute3		  VARCHAR2,
			X_Attribute4		  VARCHAR2,
			X_Attribute5		  VARCHAR2,
			X_Attribute6		  VARCHAR2,
			X_Attribute7		  VARCHAR2,
			X_Attribute8		  VARCHAR2,
			X_Attribute9		  VARCHAR2,
			X_Attribute10   	  VARCHAR2,
			X_Attribute11 		  VARCHAR2,
			X_Attribute12 		  VARCHAR2,
			X_Attribute13		  VARCHAR2,
			X_Attribute14 		  VARCHAR2,
			X_Attribute15 		  VARCHAR2,
			X_Attribute16 		  VARCHAR2,
			X_Attribute17 		  VARCHAR2,
			X_Attribute18 		  VARCHAR2,
			X_Attribute19 		  VARCHAR2,
			X_Attribute20 		  VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS


CURSOR C IS SELECT rowid FROM fa_ins_policies
    WHERE asset_policy_id = X_Asset_policy_id
    AND policy_number = X_Policy_number
    AND asset_id = X_Asset_id;

CURSOR C1 (X_Policy_Number Varchar2, X_vendor_id NUMBER) IS
		   SELECT asset_policy_id
		   FROM fa_ins_mst_pols
             WHERE policy_number = X_Policy_number
		   AND Vendor_id = X_Vendor_id;

l_asset_policy_id NUMBER;

BEGIN

  OPEN C1(X_Policy_number, X_Vendor_id);

  FETCH C1 INTO l_asset_policy_id;

  CLOSE C1;

  IF l_asset_policy_id is null THEN

	SELECT FA_INS_POLICY_S.nextval
        INTO     X_Asset_policy_id
	FROM     dual;

     l_asset_policy_id := X_Asset_policy_id;

	INSERT INTO fa_ins_mst_pols
	(asset_policy_id,
	 policy_number,
	 calculation_method,
	 vendor_id,
	 vendor_site_id
     )
     VALUES
	(
	 X_asset_policy_id,
	 X_Policy_number,
	 X_Calculation_method,
	 X_Vendor_id,
	 X_Vendor_site_id
	 );

  END IF;

  INSERT INTO fa_ins_policies
	(
	asset_policy_id,
	asset_id,
	book_type_code,
	policy_number,
	current_insurance_value,
	base_insurance_value,
	base_index_date,
	current_price_index_id,
	last_indexation_id,
	insured_amount,
	swiss_building,
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
	L_Asset_policy_id,
     X_Asset_id,
	X_Book_type_code,
	X_Policy_number,
	X_Current_insurance_value,
	X_Base_insurance_value,
	X_Base_index_date,
	X_Current_price_index_id,
	X_last_indexation_id,
	X_Insured_amount,
	X_Swiss_building,
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
   X_Asset_policy_id := NULL;
   RAISE NO_DATA_FOUND;
END IF;

CLOSE C;

END Insert_Row;


PROCEDURE Lock_Row(     X_Rowid                  VARCHAR2,
                        X_Asset_policy_id        NUMBER,
                        X_Asset_id               VARCHAR2,
                        X_Book_type_code         VARCHAR2,
                        X_Policy_number          VARCHAR2,
                        X_Vendor_site_id         NUMBER,
                        X_Vendor_id              NUMBER,
                        X_Calculation_method     VARCHAR2,
                        X_Current_insurance_value NUMBER,
                        X_Base_insurance_value   NUMBER,
                        X_Base_index_date        DATE,
                        X_Current_price_index_id NUMBER,
                        X_Last_indexation_id     NUMBER,
                        X_Insured_amount         NUMBER,
			X_Swiss_building	 VARCHAR2,
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
			FROM	fa_ins_policies
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
	AND  (	(recinfo.asset_id = X_Asset_id)
	     OR (   (recinfo.asset_id IS NULL)
		AND (X_asset_id IS NULL)))
	AND  (	(recinfo.book_type_code = X_Book_type_code)
	     OR (   (recinfo.book_type_code IS NULL)
		AND (X_Book_type_code IS NULL)))
	AND  (	(recinfo.policy_number = X_Policy_number)
	     OR (   (recinfo.policy_number IS NULL)
		AND (X_Policy_number IS NULL)))
        AND  (  (recinfo.current_insurance_value = X_current_insurance_value)
             OR (   (recinfo.current_insurance_value IS NULL)
                AND (X_current_insurance_value IS NULL)))
	AND  (  (recinfo.base_insurance_value = X_Base_insurance_value)
	     OR (   (recinfo.base_insurance_value IS NULL)
		AND (X_Base_insurance_value IS NULL)))
	AND  (  (recinfo.base_index_date = X_Base_index_date)
	     OR (   (recinfo.base_index_date IS NULL)
		AND (X_Base_index_date IS NULL)))
	AND  (  (recinfo.current_price_index_id = X_Current_price_index_id)
	     OR (   (recinfo.current_price_index_id IS NULL)
		AND (X_Current_price_index_id IS NULL)))
	AND  (  (recinfo.last_indexation_id = X_last_indexation_id)
	     OR (   (recinfo.last_indexation_id IS NULL)
		AND (X_Last_indexation_id IS NULL)))
	AND  (	(recinfo.insured_amount = X_Insured_amount)
	     OR (   (recinfo.insured_amount IS NULL)
		AND (X_Insured_amount IS NULL)))
        AND  (  (recinfo.swiss_building = X_Swiss_building)
             OR (   (recinfo.swiss_building IS NULL)
                AND (X_Swiss_building IS NULL)))
	AND  (	(recinfo.attribute_category = X_Attribute_category)
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
                        X_Asset_id               VARCHAR2,
                        X_Book_type_code         VARCHAR2,
                        X_Policy_number          VARCHAR2,
                        X_Vendor_site_id         NUMBER,
                        X_Vendor_id              NUMBER,
                        X_Calculation_method     VARCHAR2,
                        X_Base_insurance_value   NUMBER,
			X_Current_insurance_value NUMBER,
                        X_Base_index_date        DATE,
                        X_Current_price_index_id NUMBER,
                        X_Last_indexation_id     NUMBER,
                        X_Insured_amount         NUMBER,
			X_Swiss_building	 VARCHAR2,
                        X_Last_update_date       DATE,
                        X_Last_updated_by        VARCHAR2,
                        X_Last_update_login      VARCHAR2,
                        X_Creation_date          DATE,
                        X_Created_by             VARCHAR2,
                        X_Attribute_category     VARCHAR2,
                        X_Attribute1              VARCHAR2,
                        X_Attribute2              VARCHAR2,
                        X_Attribute3              VARCHAR2,
                        X_Attribute4              VARCHAR2,
                        X_Attribute5              VARCHAR2,
                        X_Attribute6              VARCHAR2,
                        X_Attribute7              VARCHAR2,
                        X_Attribute8              VARCHAR2,
                        X_Attribute9              VARCHAR2,
                        X_Attribute10             VARCHAR2,
                        X_Attribute11             VARCHAR2,
                        X_Attribute12             VARCHAR2,
                        X_Attribute13             VARCHAR2,
                        X_Attribute14             VARCHAR2,
                        X_Attribute15             VARCHAR2,
                        X_Attribute16             VARCHAR2,
                        X_Attribute17             VARCHAR2,
                        X_Attribute18             VARCHAR2,
                        X_Attribute19             VARCHAR2,
                        X_Attribute20             VARCHAR2

                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

  UPDATE fa_ins_policies
  SET
     asset_policy_id		= X_Asset_policy_id,
     asset_id			= X_Asset_id,
     book_type_code		= X_Book_type_code,
     policy_number		= X_Policy_number,
     current_insurance_value    = X_Current_insurance_value,
     base_insurance_value	= X_Base_insurance_value,
     base_index_date		= X_Base_index_date,
     current_price_index_id	= X_Current_price_index_id,
     last_indexation_id		= X_Last_indexation_id,
     insured_amount		= X_Insured_amount,
     swiss_building		= X_Swiss_building,
     last_update_date		= X_Last_update_date,
     last_updated_by		= X_Last_updated_by,
     last_update_login		= X_Last_update_login,
     creation_date		= X_Creation_date,
     created_by			= X_Created_by,
     attribute_category		= X_Attribute_category,
     attribute1			= X_Attribute1,
     attribute2			= X_Attribute2,
     attribute3			= X_Attribute3,
     attribute4			= X_Attribute4,
     attribute5			= X_Attribute5,
     attribute6			= X_Attribute6,
     attribute7			= X_Attribute7,
     attribute8			= X_Attribute8,
     attribute9			= X_Attribute9,
     attribute10		= X_Attribute10,
     attribute11		= X_Attribute11,
     attribute12		= X_Attribute12,
     attribute13		= X_Attribute13,
     attribute14		= X_Attribute14,
     attribute15		= X_Attribute15,
     attribute16		= X_Attribute16,
     attribute17		= X_Attribute17,
     attribute18		= X_Attribute18,
     attribute19		= X_Attribute19,
     attribute20		= X_Attribute20
  WHERE rowid = X_Rowid;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;


PROCEDURE Delete_Row(	X_Rowid		VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

	DELETE FROM fa_ins_policies
	WHERE rowid = X_Rowid;

	IF (SQL%NOTFOUND) THEN
	   RAISE NO_DATA_FOUND;
	END IF;

END Delete_Row;

END FA_INS_POLICIES_PKG;

/
