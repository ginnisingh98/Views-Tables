--------------------------------------------------------
--  DDL for Package Body CN_CREDIT_CONV_FCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CREDIT_CONV_FCTS_PKG" as
/* $Header: cncrtcvb.pls 115.2 2001/10/29 17:06:15 pkm ship    $ */

  PROCEDURE Insert_Row
      ( x_credit_conv_fct_id  NUMBER			,
    	x_from_credit_type_id NUMBER			,
   	x_to_credit_type_id   NUMBER			,
        x_conversion_factor   NUMBER			,
    	x_start_date          DATE			,
    	x_end_date            DATE			,
    	x_attribute_category  VARCHAR2 := NULL		,
    	x_attribute1          VARCHAR2 := NULL		,
    	x_attribute2          VARCHAR2 := NULL		,
    	x_attribute3          VARCHAR2 := NULL		,
    	x_attribute4          VARCHAR2 := NULL		,
    	x_attribute5          VARCHAR2 := NULL		,
    	x_attribute6          VARCHAR2 := NULL		,
    	x_attribute7          VARCHAR2 := NULL		,
    	x_attribute8          VARCHAR2 := NULL		,
    	x_attribute9          VARCHAR2 := NULL		,
    	x_attribute10         VARCHAR2 := NULL		,
    	x_attribute11         VARCHAR2 := NULL		,
    	x_attribute12         VARCHAR2 := NULL		,
    	x_attribute13         VARCHAR2 := NULL		,
    	x_attribute14         VARCHAR2 := NULL		,
        x_attribute15         VARCHAR2 := NULL		,
        x_created_by	      NUMBER			,
        x_creation_date	      DATE			,
        x_last_update_login   NUMBER			,
        x_last_update_date    DATE			,
        x_last_updated_by     NUMBER
      ) IS
  BEGIN
    INSERT INTO cn_credit_conv_fcts
      ( object_version_number,
        credit_conv_fct_id,
        from_credit_type_id,
        to_credit_type_id,
        conversion_factor,
        start_date,
        end_date,
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
        created_by,
        creation_date,
        last_update_login,
        last_update_date,
        last_updated_by
      ) VALUES
      (   1.0,
          x_credit_conv_fct_id,
          x_from_credit_type_id,
          x_to_credit_type_id,
          x_conversion_factor,
          x_start_date,
          x_end_date,
          x_attribute_category,
    	  x_attribute1,
    	  x_attribute2,
    	  x_attribute3,
    	  x_attribute4,
    	  x_attribute5,
    	  x_attribute6,
    	  x_attribute7,
       	  x_attribute8,
    	  x_attribute9,
    	  x_attribute10,
    	  x_attribute11,
    	  x_attribute12,
    	  x_attribute13,
    	  x_attribute14,
          x_attribute15,
          x_created_by,
          x_creation_date,
          x_last_update_login,
          x_last_update_date,
          x_last_updated_by
        );
  END Insert_Row;


  PROCEDURE Update_Row
    ( x_credit_conv_fct_id  NUMBER			,
      x_object_version      number,
    	x_from_credit_type_id NUMBER			,
   	x_to_credit_type_id   NUMBER			,
        x_conversion_factor   NUMBER			,
    	x_start_date          DATE			,
    	x_end_date            DATE			,
    	x_attribute_category  VARCHAR2 := NULL		,
    	x_attribute1          VARCHAR2 := NULL		,
    	x_attribute2          VARCHAR2 := NULL		,
    	x_attribute3          VARCHAR2 := NULL		,
    	x_attribute4          VARCHAR2 := NULL		,
    	x_attribute5          VARCHAR2 := NULL		,
    	x_attribute6          VARCHAR2 := NULL		,
    	x_attribute7          VARCHAR2 := NULL		,
    	x_attribute8          VARCHAR2 := NULL		,
    	x_attribute9          VARCHAR2 := NULL		,
    	x_attribute10         VARCHAR2 := NULL		,
    	x_attribute11         VARCHAR2 := NULL		,
    	x_attribute12         VARCHAR2 := NULL		,
    	x_attribute13         VARCHAR2 := NULL		,
    	x_attribute14         VARCHAR2 := NULL		,
        x_attribute15         VARCHAR2 := NULL		,
        x_created_by	      NUMBER			,
        x_creation_date	      DATE			,
        x_last_update_login   NUMBER			,
        x_last_update_date    DATE			,
        x_last_updated_by     NUMBER
      ) IS
  BEGIN
    UPDATE cn_credit_conv_fcts
      SET
        object_version_number = x_object_version +1,
        from_credit_type_id = x_from_credit_type_id,
        to_credit_type_id   = x_to_credit_type_id,
        conversion_factor   = x_conversion_factor,
        start_date          = x_start_date,
        end_date            = x_end_date,
        attribute_category  = x_attribute_category,
    	attribute1          = x_attribute1,
    	attribute2          = x_attribute2,
    	attribute3          = x_attribute3,
    	attribute4          = x_attribute4,
    	attribute5          = x_attribute5,
    	attribute6          = x_attribute6,
    	attribute7          = x_attribute7,
       	attribute8          = x_attribute8,
    	attribute9          = x_attribute9,
    	attribute10         = x_attribute10,
    	attribute11         = x_attribute11,
    	attribute12         = x_attribute12,
    	attribute13         = x_attribute13,
    	attribute14         = x_attribute14,
        attribute15         = x_attribute15,
        created_by          = x_created_by,
        creation_date       = x_creation_date,
        last_update_login   = x_last_update_login,
        last_update_date    = x_last_update_date,
        last_updated_by     = x_last_updated_by
    WHERE credit_conv_fct_id = x_credit_conv_fct_id;
    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;
  END Update_Row;

  PROCEDURE Lock_Row
      ( x_credit_conv_fct_id  NUMBER			,
    	x_from_credit_type_id NUMBER			,
   	x_to_credit_type_id   NUMBER			,
        x_conversion_factor   NUMBER			,
    	x_start_date          DATE			,
    	x_end_date            DATE			,
    	x_attribute_category  VARCHAR2 := NULL		,
    	x_attribute1          VARCHAR2 := NULL		,
    	x_attribute2          VARCHAR2 := NULL		,
    	x_attribute3          VARCHAR2 := NULL		,
    	x_attribute4          VARCHAR2 := NULL		,
    	x_attribute5          VARCHAR2 := NULL		,
    	x_attribute6          VARCHAR2 := NULL		,
    	x_attribute7          VARCHAR2 := NULL		,
    	x_attribute8          VARCHAR2 := NULL		,
    	x_attribute9          VARCHAR2 := NULL		,
    	x_attribute10         VARCHAR2 := NULL		,
    	x_attribute11         VARCHAR2 := NULL		,
    	x_attribute12         VARCHAR2 := NULL		,
    	x_attribute13         VARCHAR2 := NULL		,
    	x_attribute14         VARCHAR2 := NULL		,
        x_attribute15         VARCHAR2 := NULL		,
        x_created_by	      NUMBER			,
        x_creation_date	      DATE			,
        x_last_update_login   NUMBER			,
        x_last_update_date    DATE			,
        x_last_updated_by     NUMBER
      ) IS
    CURSOR C IS
       SELECT *
       FROM cn_credit_conv_fcts
       WHERE credit_conv_fct_id = x_credit_conv_fct_id
       FOR UPDATE of credit_conv_fct_id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

    if (
    --  check that mandatory columns match values in form
        (Recinfo.credit_conv_fct_id = x_credit_conv_fct_id)
        AND (Recinfo.last_update_date = x_last_update_date)
        AND (Recinfo.last_updated_by = x_last_updated_by)
        AND (Recinfo.creation_date = x_creation_date)
        AND (Recinfo.created_by = x_created_by)
        AND (Recinfo.last_update_login = x_last_update_login)
        AND (Recinfo.from_credit_type_id = x_from_credit_type_id)
        AND (Recinfo.to_credit_type_id = x_to_credit_type_id)
        AND (Recinfo.conversion_factor = x_conversion_factor)
        AND (Recinfo.start_date = x_start_date)

    --  check that non-mandatory columns match values in form
        AND ((Recinfo.end_date = x_end_date)
             OR ((Recinfo.end_date is null)
                 AND (x_end_date is null)))

        AND ((Recinfo.attribute_category = x_attribute_category)
             OR ((Recinfo.attribute_category is null)
                 AND (x_attribute_category is null)))

        AND ((Recinfo.attribute1 = x_attribute1)
             OR ((Recinfo.attribute1 is null)
                 AND (x_attribute1 is null)))

        AND ((Recinfo.attribute2 = x_attribute2)
             OR ((Recinfo.attribute2 is null)
                 AND (x_attribute2 is null)))

        AND ((Recinfo.attribute3 = x_attribute3)
             OR ((Recinfo.attribute3 is null)
                 AND (x_attribute3 is null)))

        AND ((Recinfo.attribute4 = x_attribute4)
             OR ((Recinfo.attribute4 is null)
                 AND (x_attribute4 is null)))

        AND ((Recinfo.attribute5 = x_attribute5)
             OR ((Recinfo.attribute5 is null)
                 AND (x_attribute5 is null)))

        AND ((Recinfo.attribute6 = x_attribute6)
             OR ((Recinfo.attribute6 is null)
                 AND (x_attribute6 is null)))

        AND ((Recinfo.attribute7 = x_attribute7)
             OR ((Recinfo.attribute7 is null)
                 AND (x_attribute7 is null)))

        AND ((Recinfo.attribute8 = x_attribute8)
             OR ((Recinfo.attribute8 is null)
                 AND (x_attribute8 is null)))

        AND ((Recinfo.attribute9 = x_attribute9)
             OR ((Recinfo.attribute9 is null)
                 AND (x_attribute9 is null)))

        AND ((Recinfo.attribute10 = x_attribute10)
             OR ((Recinfo.attribute10 is null)
                 AND (x_attribute10 is null)))

        AND ((Recinfo.attribute11 = x_attribute11)
             OR ((Recinfo.attribute11 is null)
                 AND (x_attribute11 is null)))

        AND ((Recinfo.attribute12 = x_attribute12)
             OR ((Recinfo.attribute12 is null)
                 AND (x_attribute12 is null)))

        AND ((Recinfo.attribute13 = x_attribute13)
             OR ((Recinfo.attribute13 is null)
                 AND (x_attribute13 is null)))

        AND ((Recinfo.attribute14 = x_attribute14)
             OR ((Recinfo.attribute14 is null)
                 AND (x_attribute14 is null)))

        AND ((Recinfo.attribute15 = x_attribute15)
             OR ((Recinfo.attribute15 is null)
                 AND (x_attribute15 is null)))
    ) then
    return;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Delete_Row(x_credit_conv_fct_id  NUMBER) IS
  BEGIN
    DELETE FROM CN_CREDIT_CONV_FCTS
    WHERE credit_conv_fct_id = x_credit_conv_fct_id;
    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;

end CN_CREDIT_CONV_FCTS_PKG;

/
