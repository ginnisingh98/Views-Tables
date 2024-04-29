--------------------------------------------------------
--  DDL for Package Body RG_DSS_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_DSS_HIERARCHIES_PKG" as
/* $Header: rgidhrcb.pls 120.2 2002/11/14 02:58:24 djogg ship $ */



/*** PUBLIC FUNCTIONS ***/

FUNCTION get_new_id RETURN NUMBER IS
  next_hierarchy_id NUMBER;
BEGIN
  SELECT    rg_dss_hierarchies_s.nextval
  INTO      next_hierarchy_id
  FROM      dual;

  RETURN (next_hierarchy_id);
END get_new_id;


FUNCTION used_in_frozen_system(X_Hierarchy_Id NUMBER) RETURN BOOLEAN IS
  dummy   NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_hierarchies
              WHERE     hierarchy_id = X_Hierarchy_Id
              AND       RG_DSS_DIMENSIONS_PKG.used_in_frozen_system(dimension_id) = 1);
  RETURN(FALSE);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(TRUE);
END used_in_frozen_system;


PROCEDURE check_unique_name(X_Rowid VARCHAR2, X_Name VARCHAR2) IS
  dummy   NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      rg_dss_hierarchies
  WHERE     name = X_Name
  AND       ((X_Rowid IS NULL) OR (rowid <> X_Rowid));

  -- name already exists for a different hierarchy: ERROR
  FND_MESSAGE.set_name('RG', 'RG_FORMS_OBJECT_EXISTS');
  FND_MESSAGE.set_token('OBJECT', 'RG_DSS_HIERARCHY', TRUE);
  APP_EXCEPTION.raise_exception;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- name doesn't exist, so do nothing
    NULL;
END check_unique_name;


FUNCTION details_exists(X_Hierarchy_Id NUMBER) RETURN BOOLEAN IS
  dummy   NUMBER;
BEGIN
  SELECT   1
  INTO     dummy
  FROM     dual
  WHERE    NOT EXISTS
            (SELECT   1
             FROM     rg_dss_hierarchy_details
             WHERE    hierarchy_id = X_Hierarchy_Id);
  RETURN(FALSE);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(TRUE);
END details_exists;


FUNCTION num_details(X_Hierarchy_Id NUMBER) RETURN NUMBER IS
  NumRecords NUMBER;
BEGIN
  NumRecords := 0;

  SELECT COUNT(hierarchy_id)
  INTO   NumRecords
  FROM   rg_dss_hierarchy_details
  WHERE  hierarchy_id = X_Hierarchy_Id;

  RETURN(NumRecords);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
	RAISE;
    WHEN OTHERS THEN
	 fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	 RAISE;

END num_details;


FUNCTION num_segments_for_dim(X_Dimension_Id NUMBER) RETURN NUMBER IS
  NumSegments NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO NumSegments
  FROM rg_dss_dim_segments
  WHERE dimension_id = X_Dimension_Id;

  RETURN(NumSegments);

  EXCEPTION
    WHEN OTHERS THEN
	 fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	 RAISE;

END num_segments_for_dim;


PROCEDURE check_references(X_Hierarchy_Id NUMBER) IS
  dummy NUMBER;
BEGIN
  IF (used_in_frozen_system(X_Hierarchy_Id)) THEN
    FND_MESSAGE.set_name('RG','RG_DSS_REF_HIERARCHY');
    APP_EXCEPTION.raise_exception;
  END IF;
END check_references;


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Hierarchy_Id                  IN OUT NOCOPY NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Dimension_Id                         NUMBER,
                     X_Description                          VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
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
  num_segments NUMBER;
  num_detail_rows  NUMBER;

  CURSOR C IS
    SELECT    rowid
    FROM      rg_dss_hierarchies
    WHERE     hierarchy_id = X_Hierarchy_Id;
BEGIN

  check_unique_name(X_Rowid, X_Name);

  IF (X_Hierarchy_Id IS NULL) THEN
    X_Hierarchy_Id := get_new_id;
  END IF;

  /* Ensure that there are as many detail records
     as there are segments for the dimension */

  num_segments := num_segments_for_dim(X_dimension_id);
  num_detail_rows := num_details(X_Hierarchy_Id);

  IF (num_detail_rows <> num_segments) THEN
    /* Every segment must have a detail hierarchy row */
    FND_MESSAGE.set_name('RG','RG_DSS_HIR_ROOT_NODE');
    APP_EXCEPTION.raise_exception;
  END IF;

  INSERT INTO rg_dss_hierarchies(
          hierarchy_id,
          name,
          id_flex_code,
          id_flex_num,
          dimension_id,
          description,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by,
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
          X_Hierarchy_Id,
          X_Name,
          X_Id_Flex_Code,
          X_Id_Flex_Num,
          X_Dimension_Id,
          X_Description,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Creation_Date,
          X_Created_By,
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
                   X_Hierarchy_Id                         NUMBER,
                   X_Name                                 VARCHAR2,
                   X_Id_Flex_Code                         VARCHAR2,
                   X_Id_Flex_Num                          NUMBER,
                   X_Dimension_Id                         NUMBER,
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
      FROM   rg_dss_hierarchies
      WHERE  rowid = X_Rowid
      FOR UPDATE of hierarchy_id NOWAIT;
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
          (   (Recinfo.hierarchy_id = X_Hierarchy_Id)
           OR (    (Recinfo.hierarchy_id IS NULL)
               AND (X_Hierarchy_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.id_flex_code = X_Id_Flex_Code)
           OR (    (Recinfo.id_flex_code IS NULL)
               AND (X_Id_Flex_Code IS NULL)))
      AND (   (Recinfo.id_flex_num = X_Id_Flex_Num)
           OR (    (Recinfo.id_flex_num IS NULL)
               AND (X_Id_Flex_Num IS NULL)))
      AND (   (Recinfo.dimension_id = X_Dimension_Id)
           OR (    (Recinfo.dimension_id IS NULL)
               AND (X_Dimension_Id IS NULL)))
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


PROCEDURE Update_Row(X_Rowid                              VARCHAR2,
                     X_Hierarchy_Id                         NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Dimension_Id                         NUMBER,
                     X_Description                          VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
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
  num_segments 	NUMBER;
  num_detail_rows	NUMBER;
BEGIN

  IF (used_in_frozen_system(X_Hierarchy_Id)) THEN
    -- Can't update the record if the hierarchy is used in a frozen system
    FND_MESSAGE.set_name('RG', 'RG_DSS_FROZEN_SYSTEM');
    FND_MESSAGE.set_token('OBJECT', 'RG_DSS_HIERARCHY', TRUE);
    APP_EXCEPTION.raise_exception;
  END IF;

  /* Ensure that there are as many detail records
     as there are segments for the dimension */

  num_segments := num_segments_for_dim(X_dimension_id);
  num_detail_rows := num_details(X_Hierarchy_Id);

  IF (num_detail_rows <> num_segments) THEN
    /* Every segment must have a detail hierarchy row */
    FND_MESSAGE.set_name('RG','RG_DSS_HIR_ROOT_NODE');
    APP_EXCEPTION.raise_exception;
  END IF;

  UPDATE rg_dss_hierarchies
  SET
    hierarchy_id                              =    X_Hierarchy_Id,
    name                                      =    X_Name,
    id_flex_code                              =    X_Id_Flex_Code,
    id_flex_num                               =    X_Id_Flex_Num,
    dimension_id                              =    X_Dimension_Id,
    description                               =    X_Description,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
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

PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Hierarchy_Id NUMBER) IS
BEGIN

  IF (used_in_frozen_system(X_Hierarchy_Id)) THEN
    -- Can't delete the record if the hierarchy is used in a frozen system
    FND_MESSAGE.set_name('RG', 'RG_DSS_FROZEN_SYSTEM');
    FND_MESSAGE.set_token('OBJECT', 'RG_DSS_HIERARCHY', TRUE);
    APP_EXCEPTION.raise_exception;
  END IF;

  DELETE FROM rg_dss_hierarchies
  WHERE  rowid = X_Rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;


END RG_DSS_HIERARCHIES_PKG;

/
