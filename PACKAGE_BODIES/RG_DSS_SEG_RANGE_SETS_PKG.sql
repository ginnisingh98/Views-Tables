--------------------------------------------------------
--  DDL for Package Body RG_DSS_SEG_RANGE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_DSS_SEG_RANGE_SETS_PKG" as
/* $Header: rgidrgsb.pls 120.2 2002/11/14 02:58:50 djogg ship $ */



/*** PUBLIC FUNCTIONS ***/

PROCEDURE check_unique(X_Rowid VARCHAR2, X_Name VARCHAR2) IS
  dummy   NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      rg_dss_seg_range_sets
  WHERE     name = X_Name
  AND       ((X_Rowid IS NULL) OR (rowid <> X_Rowid));

  -- name already exists for a different range set: ERROR
  FND_MESSAGE.set_name('RG', 'RG_FORMS_OBJECT_EXISTS');
  FND_MESSAGE.set_token('OBJECT', 'RG_DSS_SEG_RANGE_SET', TRUE);
  APP_EXCEPTION.raise_exception;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- name doesn't exist, so do nothing
    NULL;
END check_unique;


FUNCTION details_exist(X_Range_Set_Id NUMBER) RETURN BOOLEAN IS
  dummy   NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
            (SELECT    1
             FROM      rg_dss_seg_ranges
             WHERE     range_set_id = X_Range_Set_Id);
  RETURN(FALSE);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(TRUE);

END details_exist;


PROCEDURE check_references(X_Range_Set_Id NUMBER) IS
  dummy NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_dim_segments
              WHERE     range_set_id = X_Range_Set_Id
             );

  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_var_selections
              WHERE     range_set_id = X_Range_Set_Id
             );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG','RG_DSS_REF_SEG_RANGE_SET');
      APP_EXCEPTION.raise_exception;
END check_references;


FUNCTION used_in_frozen_system(X_Range_Set_Id NUMBER) return NUMBER IS
  dummy NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM 	rg_dss_systems sys,
			rg_dss_system_variables svar,
			rg_dss_var_dimensions vdim,
			rg_dss_dimensions dim,
			rg_dss_dim_segments dseg,
			rg_dss_var_selections vsel
	      WHERE 	dseg.range_set_id = X_Range_Set_Id
	      AND	dim.dimension_id  = dseg.dimension_id
	      AND	vdim.dimension_id = dim.dimension_id
	      AND	svar.variable_id  = vdim.variable_id
	      AND	sys.system_id     = svar.system_id
	      AND 	sys.freeze_flag   = 'Y'
             );
  return (0);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return(1);
END used_in_frozen_system;


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Range_Set_Id                  IN OUT NOCOPY NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Application_Column_Name              VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Description                          VARCHAR2,
                     X_Context                              VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2) IS
  CURSOR C IS
    SELECT    rowid
    FROM      rg_dss_seg_range_sets
    WHERE     range_set_id = X_Range_Set_Id;

  CURSOR C2 IS
    SELECT    rg_dss_seg_range_sets_s.nextval
    FROM      dual;

BEGIN

  check_unique(X_Rowid, X_Name);

  IF (X_Range_Set_Id IS NULL) THEN
    OPEN C2;
    FETCH C2 INTO X_Range_Set_Id;
    CLOSE C2;
  END IF;

  INSERT INTO rg_dss_seg_range_sets(
          range_set_id,
          name,
          application_column_name,
          id_flex_code,
          id_flex_num,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by,
          description,
          context,
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
          attribute15
         ) VALUES (
          X_Range_Set_Id,
          X_Name,
          X_Application_Column_Name,
          X_Id_Flex_Code,
          X_Id_Flex_Num,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Creation_Date,
          X_Created_By,
          X_Description,
          X_Context,
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
          X_Attribute15
  );


  OPEN C;
  FETCH C INTO X_Rowid;

  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE C;

END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                                VARCHAR2,
                   X_Range_Set_Id                         NUMBER,
                   X_Name                                 VARCHAR2,
                   X_Application_Column_Name              VARCHAR2,
                   X_Id_Flex_Code                         VARCHAR2,
                   X_Id_Flex_Num                          NUMBER,
                   X_Description                          VARCHAR2,
                   X_Context                              VARCHAR2,
                   X_Attribute1                           VARCHAR2,
                   X_Attribute2                           VARCHAR2,
                   X_Attribute3                           VARCHAR2,
                   X_Attribute4                           VARCHAR2,
                   X_Attribute5                           VARCHAR2,
                   X_Attribute6                           VARCHAR2,
                   X_Attribute7                           VARCHAR2,
                   X_Attribute8                           VARCHAR2,
                   X_Attribute9                           VARCHAR2,
                   X_Attribute10                          VARCHAR2,
                   X_Attribute11                          VARCHAR2,
                   X_Attribute12                          VARCHAR2,
                   X_Attribute13                          VARCHAR2,
                   X_Attribute14                          VARCHAR2,
                   X_Attribute15                          VARCHAR2
  ) IS
  CURSOR C IS
      SELECT *
      FROM   rg_dss_seg_range_sets
      WHERE  rowid = X_Rowid
      FOR UPDATE of range_set_id  NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;

  IF (
          (   (Recinfo.range_set_id = X_Range_Set_Id)
           OR (    (Recinfo.range_set_id IS NULL)
               AND (X_Range_Set_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.application_column_name = X_Application_Column_Name)
           OR (    (Recinfo.application_column_name IS NULL)
               AND (X_Application_Column_Name IS NULL)))
      AND (   (Recinfo.id_flex_code = X_Id_Flex_Code)
           OR (    (Recinfo.id_flex_code IS NULL)
               AND (X_Id_Flex_Code IS NULL)))
      AND (   (Recinfo.id_flex_num = X_Id_Flex_Num)
           OR (    (Recinfo.id_flex_num IS NULL)
               AND (X_Id_Flex_Num IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
          ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END Lock_Row;


PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Range_Set_Id                         NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Application_Column_Name              VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Description                          VARCHAR2,
                     X_Context                              VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2) IS
BEGIN

  UPDATE rg_dss_seg_range_sets
  SET
    range_set_id                              =    X_Range_Set_Id,
    name                                      =    X_Name,
    application_column_name                   =    X_Application_Column_Name,
    id_flex_code                              =    X_Id_Flex_Code,
    id_flex_num                               =    X_Id_Flex_Num,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    description                               =    X_Description,
    context                                   =    X_Context,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15
    WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN

  DELETE FROM rg_dss_seg_range_sets
  WHERE  rowid = X_Rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;


END RG_DSS_SEG_RANGE_SETS_PKG;

/
