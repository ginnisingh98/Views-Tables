--------------------------------------------------------
--  DDL for Package Body RG_DSS_SYSTEM_VARIABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_DSS_SYSTEM_VARIABLES_PKG" as
/* $Header: rgidsvrb.pls 120.2 2002/11/14 02:59:03 djogg ship $ */



/*** PUBLIC FUNCTIONS ***/

PROCEDURE check_unique(X_Rowid VARCHAR2,
                       X_System_Id NUMBER,
                       X_Variable_Id NUMBER) IS
  dummy   NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      rg_dss_system_variables
  WHERE     system_id = X_System_Id
  AND       variable_id = X_Variable_Id
  AND       ((X_Rowid IS NULL) OR (rowid <> X_Rowid));

  -- name already exists for a different system: ERROR
  FND_MESSAGE.set_name('RG', 'RG_FORMS_OBJECT_EXISTS_FOR');
  FND_MESSAGE.set_token('OBJECT1', 'RG_DSS_VARIABLE', TRUE);
  FND_MESSAGE.set_token('OBJECT2', 'RG_DSS_SYSTEM', TRUE);
  APP_EXCEPTION.raise_exception;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- name doesn't exist, so do nothing
    NULL;
END check_unique;


PROCEDURE insert_row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_System_Id                            NUMBER,
                     X_Variable_Id                          NUMBER,
                     X_System_Variable_Id            IN OUT NOCOPY NUMBER,
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
  CURSOR C IS
    SELECT    rowid
    FROM      rg_dss_system_variables
    WHERE     system_variable_id = X_System_Variable_Id;

  CURSOR C2 IS
    SELECT    rg_dss_system_variables_s.nextval
    FROM      dual;

BEGIN

  check_unique(X_Rowid, X_System_Id, X_Variable_Id);

  IF (X_System_Variable_Id IS NULL) THEN
    OPEN C2;
    FETCH C2 INTO X_System_Variable_Id;
    CLOSE C2;
  END IF;

  INSERT INTO rg_dss_system_variables(
          system_id,
          variable_id,
          system_variable_id,
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
          X_System_Id,
          X_Variable_Id,
          X_System_Variable_Id,
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

END insert_row;


PROCEDURE lock_row(X_Rowid                                VARCHAR2,
                   X_System_Id                            NUMBER,
                   X_Variable_Id                          NUMBER,
                   X_System_Variable_Id                   NUMBER,
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
      FROM   rg_dss_system_variables
      WHERE  rowid = X_Rowid
      FOR UPDATE of system_variable_id  NOWAIT;
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
          (   (Recinfo.system_id = X_System_Id)
           OR (    (Recinfo.system_id IS NULL)
               AND (X_System_Id IS NULL)))
      AND (   (Recinfo.variable_id = X_Variable_Id)
           OR (    (Recinfo.variable_id IS NULL)
               AND (X_Variable_Id IS NULL)))
      AND (   (Recinfo.system_variable_id = X_System_Variable_Id)
           OR (    (Recinfo.system_variable_id IS NULL)
               AND (X_System_Variable_Id IS NULL)))
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
END lock_row;


PROCEDURE update_row(X_Rowid                                VARCHAR2,
                     X_System_Id                            NUMBER,
                     X_Variable_Id                          NUMBER,
                     X_System_Variable_Id                   NUMBER,
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
BEGIN

  UPDATE rg_dss_system_variables
  SET
    system_id                                 =    X_System_Id,
    variable_id                               =    X_Variable_Id,
    system_variable_id                        =    X_System_Variable_Id,
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

END update_row;

PROCEDURE delete_row(X_Rowid VARCHAR2) IS
BEGIN

  DELETE FROM rg_dss_system_variables
  WHERE  rowid = X_Rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;


END RG_DSS_SYSTEM_VARIABLES_PKG;

/
