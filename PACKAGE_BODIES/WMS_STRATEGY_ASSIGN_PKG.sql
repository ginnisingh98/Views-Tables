--------------------------------------------------------
--  DDL for Package Body WMS_STRATEGY_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_STRATEGY_ASSIGN_PKG" AS
/* $Header: WMSPPSAB.pls 120.1 2005/06/20 02:51:50 appldev ship $ */
--
 PROCEDURE insert_row
   (X_Rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Organization_Id		     NUMBER,
    X_Object_Type_Code               NUMBER,
    X_Object_Name                    VARCHAR2 DEFAULT NULL,
    X_Object_Id			     NUMBER,
    X_PK1_Value			     VARCHAR2,
    X_PK2_Value                      VARCHAR2 DEFAULT NULL,
    X_PK3_Value                      VARCHAR2 DEFAULT NULL,
    X_PK4_Value                      VARCHAR2 DEFAULT NULL,
    X_PK5_Value                      VARCHAR2 DEFAULT NULL,
    X_Strategy_Id		     NUMBER,
    X_Strategy_Type_Code             NUMBER,
    X_Effective_From		     DATE DEFAULT NULL,
    X_Effective_To                   DATE DEFAULT NULL,
    X_Created_By                     NUMBER,
    X_Creation_Date                  DATE,
    X_Last_Updated_By                NUMBER,
    X_Last_Update_Date               DATE,
    X_Last_Update_Login              NUMBER DEFAULT NULL,
    X_Attribute1                     VARCHAR2 DEFAULT NULL,
    X_Attribute2                     VARCHAR2 DEFAULT NULL,
    X_Attribute3                     VARCHAR2 DEFAULT NULL,
    X_Attribute4                     VARCHAR2 DEFAULT NULL,
    X_Attribute5                     VARCHAR2 DEFAULT NULL,
    X_Attribute6                     VARCHAR2 DEFAULT NULL,
    X_Attribute7                     VARCHAR2 DEFAULT NULL,
    X_Attribute8                     VARCHAR2 DEFAULT NULL,
    X_Attribute9                     VARCHAR2 DEFAULT NULL,
    X_Attribute10                    VARCHAR2 DEFAULT NULL,
    X_Attribute11                    VARCHAR2 DEFAULT NULL,
    X_Attribute12                    VARCHAR2 DEFAULT NULL,
    X_Attribute13                    VARCHAR2 DEFAULT NULL,
    X_Attribute14                    VARCHAR2 DEFAULT NULL,
    X_Attribute15                    VARCHAR2 DEFAULT NULL,
    X_Attribute_Category             VARCHAR2 DEFAULT NULL,
    X_Date_Type_Code                 VARCHAR2 DEFAULT NULL,
    X_Date_Type_Lookup_Type          VARCHAR2 DEFAULT NULL,
    X_Date_Type_From                 NUMBER DEFAULT NULL,
    X_Date_Type_To                   NUMBER DEFAULT NULL,
    X_Sequence_Number		     NUMBER DEFAULT NULL

  ) IS
     CURSOR C IS
	SELECT rowid FROM WMS_STRATEGY_ASSIGNMENTS
         WHERE organization_id		= X_Organization_Id
         AND   object_id                = X_Object_Id
	 AND   NVL(object_name,chr(0))	= NVL(X_Object_Name,chr(0))
	 AND   pk1_value		= X_PK1_Value
	 AND   NVL(pk2_value,chr(0))	= NVL(X_PK2_Value,chr(0))
	 AND   NVL(pk3_value,chr(0))    = NVL(X_PK3_Value,chr(0))
	 AND   NVL(pk4_value,chr(0))    = NVL(X_PK4_Value,chr(0))
	 AND   NVL(pk5_value,chr(0))    = NVL(X_PK5_Value,chr(0))
         AND   strategy_id              = X_Strategy_Id
         AND   strategy_type_code       = X_Strategy_Type_Code
	 AND   NVL(effective_from,TO_DATE('01011900','DDMMYYYY'))
			= NVL(X_Effective_From,TO_DATE('01011900','DDMMYYYY'))
	 AND   NVL(effective_to,TO_DATE('31124000','DDMMYYYY'))
                      = NVL(X_Effective_To,TO_DATE('31124000','DDMMYYYY'));

   BEGIN

       INSERT INTO WMS_STRATEGY_ASSIGNMENTS(
 	      Organization_Id,
              Object_Type_Code,
              Object_Name,
              Object_Id,
              PK1_Value,
	      PK2_Value,
	      PK3_Value,
   	      PK4_Value,
	      PK5_Value,
              Strategy_Id,
              Strategy_Type_Code,
              Effective_From,
	      Effective_To,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
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
              attribute_category,
	      date_type_code,
	      date_type_lookup_type,
              date_type_from,
              date_type_to,
 	      sequence_number
             ) VALUES (
	      X_Organization_Id,
              X_Object_Type_Code,
              X_Object_Name,
              X_Object_Id,
              X_PK1_Value,
	      X_PK2_Value,
	      X_PK3_Value,
   	      X_PK4_Value,
	      X_PK5_Value,
              X_Strategy_Id,
              X_Strategy_Type_Code,
              X_Effective_From,
	      X_Effective_To,
              X_Created_By,
              X_Creation_Date,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Last_Update_Login,
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
              X_Attribute_Category,
              X_Date_Type_Code,
	      X_Date_Type_Lookup_Type,
 	      X_Date_Type_From,
              X_Date_Type_To,
	      X_Sequence_Number
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

  PROCEDURE lock_row
    (X_Rowid                            VARCHAR2,
     X_Organization_Id			NUMBER,
     X_Object_Type_Code               	NUMBER,
     X_Object_Name                	VARCHAR2 DEFAULT NULL,
     X_Object_Id			NUMBER,
     X_PK1_Value			VARCHAR2,
     X_PK2_Value                      	VARCHAR2 DEFAULT NULL,
     X_PK3_Value                      	VARCHAR2 DEFAULT NULL,
     X_PK4_Value                      	VARCHAR2 DEFAULT NULL,
     X_PK5_Value                      	VARCHAR2 DEFAULT NULL,
     X_Strategy_Id			NUMBER,
     X_Strategy_Type_Code               NUMBER,
     X_Effective_From			DATE DEFAULT NULL,
     X_Effective_To                 	DATE DEFAULT NULL,
     X_Attribute1                       VARCHAR2 DEFAULT NULL,
     X_Attribute2                       VARCHAR2 DEFAULT NULL,
     X_Attribute3                       VARCHAR2 DEFAULT NULL,
     X_Attribute4                       VARCHAR2 DEFAULT NULL,
     X_Attribute5                       VARCHAR2 DEFAULT NULL,
     X_Attribute6                       VARCHAR2 DEFAULT NULL,
     X_Attribute7                       VARCHAR2 DEFAULT NULL,
     X_Attribute8                       VARCHAR2 DEFAULT NULL,
     X_Attribute9                       VARCHAR2 DEFAULT NULL,
     X_Attribute10                      VARCHAR2 DEFAULT NULL,
     X_Attribute11                      VARCHAR2 DEFAULT NULL,
     X_Attribute12                      VARCHAR2 DEFAULT NULL,
     X_Attribute13                      VARCHAR2 DEFAULT NULL,
     X_Attribute14                      VARCHAR2 DEFAULT NULL,
     X_Attribute15                      VARCHAR2 DEFAULT NULL,
     X_Attribute_Category               VARCHAR2 DEFAULT NULL,
     X_Date_Type_Code                   VARCHAR2 DEFAULT NULL,
     X_Date_Type_Lookup_Type            VARCHAR2 DEFAULT NULL,
     X_Date_Type_From                   NUMBER DEFAULT NULL,
     X_Date_Type_To                     NUMBER DEFAULT NULL,
     X_Sequence_Number			NUMBER DEFAULT NULL
  ) IS
    CURSOR C IS SELECT *
                FROM   WMS_STRATEGY_ASSIGNMENTS
                WHERE  rowid = X_Rowid
                FOR UPDATE of Strategy_Id NOWAIT;
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
    if (       (Recinfo.organization_id =  X_Organization_Id)
	   AND (Recinfo.object_type_code =  X_Object_Type_Code)
           AND (   (Recinfo.object_name =  X_Object_Name)
                OR (    (Recinfo.object_name IS NULL)
                    AND (X_Object_Name IS NULL)))
           AND (Recinfo.object_id =  X_Object_Id)
           AND (Recinfo.pk1_value =  X_PK1_Value)
           AND (   (Recinfo.pk2_value =  X_PK2_Value)
                OR (    (Recinfo.pk2_value IS NULL)
                    AND (X_PK2_Value IS NULL)))
           AND (   (Recinfo.pk3_value =  X_PK3_Value)
                OR (    (Recinfo.pk3_value IS NULL)
                    AND (X_PK3_Value IS NULL)))
	   AND (   (Recinfo.pk4_value =  X_PK4_Value)
                OR (    (Recinfo.pk4_value IS NULL)
                    AND (X_PK4_Value IS NULL)))
	   AND (   (Recinfo.pk5_value =  X_PK5_Value)
                OR (    (Recinfo.pk5_value IS NULL)
                    AND (X_PK5_Value IS NULL)))
	   AND (Recinfo.strategy_id =  X_Strategy_Id)
	   AND (Recinfo.strategy_type_code =  X_Strategy_Type_Code)
	   AND (   (Recinfo.effective_from =  X_Effective_From)
                OR (    (Recinfo.effective_from IS NULL)
                    AND (X_Effective_From IS NULL)))
	   AND (   (Recinfo.effective_to =  X_Effective_To)
                OR (    (Recinfo.effective_to IS NULL)
                    AND (X_Effective_To IS NULL)))
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
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.date_type_code =  X_Date_Type_Code)
                OR (    (Recinfo.date_type_code IS NULL)
                    AND (X_Date_Type_Code IS NULL)))
           AND (   (Recinfo.date_type_lookup_type =  X_Date_Type_Lookup_Type)
                OR (    (Recinfo.date_type_lookup_type IS NULL)
                    AND (X_Date_Type_Lookup_Type IS NULL)))
           AND (   (Recinfo.date_type_from =  X_Date_Type_From)
                OR (    (Recinfo.date_type_from IS NULL)
                    AND (X_Date_Type_From IS NULL)))
           AND (   (Recinfo.date_type_to =  X_Date_Type_To)
                OR (    (Recinfo.date_type_to IS NULL)
                    AND (X_Date_Type_To IS NULL)))
           AND (   (Recinfo.sequence_number =  X_Sequence_Number)
                OR (    (Recinfo.sequence_number IS NULL)
                    AND (X_Sequence_Number IS NULL)))


      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE update_row
    (X_Rowid                          VARCHAR2,
     X_Organization_Id		NUMBER,
     X_Object_Type_Code               NUMBER,
     X_Object_Name                	VARCHAR2 DEFAULT NULL,
     X_Object_Id			NUMBER,
     X_PK1_Value			VARCHAR2,
     X_PK2_Value                      VARCHAR2 DEFAULT NULL,
     X_PK3_Value                      VARCHAR2 DEFAULT NULL,
     X_PK4_Value                      VARCHAR2 DEFAULT NULL,
     X_PK5_Value                      VARCHAR2 DEFAULT NULL,
     X_Strategy_Id			NUMBER,
     X_Strategy_Type_Code             NUMBER,
     X_Effective_From			DATE DEFAULT NULL,
     X_Effective_To                 	DATE DEFAULT NULL,
     X_Last_Updated_By                NUMBER,
     X_Last_Update_Date               DATE,
     X_Last_Update_Login              NUMBER DEFAULT NULL,
     X_Attribute1                     VARCHAR2 DEFAULT NULL,
     X_Attribute2                     VARCHAR2 DEFAULT NULL,
     X_Attribute3                     VARCHAR2 DEFAULT NULL,
     X_Attribute4                     VARCHAR2 DEFAULT NULL,
     X_Attribute5                     VARCHAR2 DEFAULT NULL,
     X_Attribute6                     VARCHAR2 DEFAULT NULL,
     X_Attribute7                     VARCHAR2 DEFAULT NULL,
     X_Attribute8                     VARCHAR2 DEFAULT NULL,
     X_Attribute9                     VARCHAR2 DEFAULT NULL,
     X_Attribute10                    VARCHAR2 DEFAULT NULL,
     X_Attribute11                    VARCHAR2 DEFAULT NULL,
     X_Attribute12                    VARCHAR2 DEFAULT NULL,
     X_Attribute13                    VARCHAR2 DEFAULT NULL,
     X_Attribute14                    VARCHAR2 DEFAULT NULL,
     X_Attribute15                    VARCHAR2 DEFAULT NULL,
     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
     X_Date_Type_Code                 VARCHAR2 DEFAULT NULL,
     X_Date_Type_Lookup_Type          VARCHAR2 DEFAULT NULL,
     X_Date_Type_From                 NUMBER DEFAULT NULL,
     X_Date_Type_To                   NUMBER DEFAULT NULL,
     X_Sequence_Number		      NUMBER DEFAULT NULL
  ) IS
  BEGIN
    UPDATE WMS_STRATEGY_ASSIGNMENTS
    SET
       organization_id		       =     X_Organization_Id,
       object_type_code		       =     X_Object_Type_Code,
       object_name		       =     X_Object_Name,
       object_id		       =     X_Object_Id,
       pk1_value		       =     X_PK1_Value,
       pk2_value                       =     X_PK2_Value,
       pk3_value                       =     X_PK3_Value,
       pk4_value                       =     X_PK4_Value,
       pk5_value                       =     X_PK5_Value,
       strategy_id                     =     X_Strategy_Id,
       strategy_type_code              =     X_Strategy_Type_Code,
       effective_from		       =     X_Effective_From,
       effective_to                    =     X_Effective_To,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_date                =     X_Last_Update_Date,
       last_update_login               =     X_Last_Update_Login,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       attribute_category              =     X_Attribute_Category,
       date_type_code		       =     X_Date_Type_Code,
       date_type_lookup_type           =     X_Date_Type_Lookup_Type,
       date_type_from                  =     X_Date_Type_From,
       date_type_to                    =     X_Date_Type_To,
       sequence_number		       =     X_Sequence_Number

    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM WMS_STRATEGY_ASSIGNMENTS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;
END WMS_STRATEGY_ASSIGN_PKG;

/
