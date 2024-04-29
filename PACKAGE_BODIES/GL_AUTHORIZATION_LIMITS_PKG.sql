--------------------------------------------------------
--  DDL for Package Body GL_AUTHORIZATION_LIMITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTHORIZATION_LIMITS_PKG" as
/* $Header: gliemalb.pls 120.5 2005/05/05 01:07:12 kvora ship $ */
--
-- Package
--   GL_AUTHORIZATION_LIMITS_PKG
-- Purpose
--   To contain validation and insertion routines for GL_AUTHORIZATION_LIMITS
-- History
--   08-07-97      R Goyal 	   Created.
  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Inserts a row into GL_AUTHORIZATION_LIMITS
  -- History
  --   08-07-97      R Goyal 	   Created.
  -- Arguments
  --   all the columns of the table GL_AUTHORIZATION_LIMITS
  -- Example
  --   GL_AUTHORIZATION_LIMITS_PKG.Insert_Row(....;
  -- Notes
  --
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Employee_Id                         NUMBER,
                     X_Authorization_Limit                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_AUTHORIZATION_LIMITS
             WHERE ledger_id = X_Ledger_Id
             AND   employee_id = X_Employee_Id;
BEGIN
  INSERT INTO GL_AUTHORIZATION_LIMITS(
          ledger_id,
          employee_id,
          authorization_limit,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
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
          context
         ) VALUES (
          X_Ledger_Id,
          X_Employee_Id,
          X_Authorization_Limit,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
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
          X_Context
	);
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

END Insert_Row;

  --
  -- Procedure
  --  Lock_Row
  -- Purpose
  --   Locks a row into GL_AUTHORIZATION_LIMITS
  -- History
  --   08-07-97      R Goyal 	   Created.
  -- Arguments
  --   all the columns of the table GL_AUTHORIZATION_LIMITS
  -- Example
  --   GL_AUTHORIZATION_LIMITS_PKG.Lock_Row(....;
  -- Notes
  --
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Ledger_Id                             NUMBER,
                   X_Employee_Id                           NUMBER,
                   X_Authorization_Limit                   NUMBER,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Context                               VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_AUTHORIZATION_LIMITS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Ledger_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.employee_id = X_Employee_Id)
           OR (    (Recinfo.employee_id IS NULL)
               AND (X_Employee_Id IS NULL)))
      AND (   (Recinfo.authorization_limit = X_Authorization_Limit)
           OR (    (Recinfo.authorization_limit IS NULL)
               AND (X_Authorization_Limit IS NULL)))
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
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;


  --
  -- Procedure
  --  Update_Row
  -- Purpose
  --   Updates a row into GL_AUTHORIZATION_LIMITS
  -- History
  --   08-07-97    R Goyal     Created.
  -- Arguments
  -- all the columns of the table GL_AUTHORIZATION_LIMITS
  -- Example
  --   GL_AUTHORIZATION_LIMITS_PKG.Update_Row(....;
  -- Notes
  --
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Employee_Id                         NUMBER,
                     X_Authorization_Limit                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2
) IS
BEGIN
  UPDATE GL_AUTHORIZATION_LIMITS
  SET
    ledger_id                                 =    X_Ledger_Id,
    employee_id                               =    X_Employee_Id,
    authorization_limit                       =    X_Authorization_Limit,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
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
    attribute15                               =    X_Attribute15,
    context                                   =    X_Context
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

  --
  -- Procedure
  --  Delete_Row
  -- Purpose
  --   Deletes a row from GL_AUTHORIZATION_LIMITS
  -- History
  --   08-07-97     R Goyal      Created.
  -- Arguments
  --    x_rowid         Rowid of a row
  -- Example
  --   GL_AUTHORIZATION_LIMITS_PKG.delete_row('ajfdshj');
  -- Notes
  --
PROCEDURE Delete_Row(X_Rowid  VARCHAR2) IS
BEGIN
     DELETE FROM GL_AUTHORIZATION_LIMITS
     WHERE  rowid = X_Rowid;

     IF (SQL%NOTFOUND) THEN
       RAISE NO_DATA_FOUND;
     END IF;

END Delete_Row;

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the employee_name is unique
  -- History
  --   08-08-97     R Goyal      Created.
  -- Arguments
  --   row_id                   	The row ID
  --   X_Ledger_Id 			Ledger Id
  --   x_employee_id		        Employee ID
  -- Example
  --   GL_AUTHORIZATION_LIMITS_PKG.check_unique(...
  -- Notes
  --
FUNCTION Check_Unique(X_Rowid                  VARCHAR2,
                      X_Ledger_Id              NUMBER,
                      X_employee_id            NUMBER,
                      X_employee_name          VARCHAR2) RETURN BOOLEAN IS
dummy NUMBER := 0;
BEGIN
  IF (    x_employee_id IS NOT NULL
      AND X_Ledger_Id IS NOT NULL ) THEN
        SELECT 1
        INTO dummy
        FROM dual
        WHERE EXISTS
                 (SELECT 1
                  FROM   GL_AUTHORIZATION_LIMITS A
                  WHERE  A.ledger_id = X_Ledger_Id
                    AND  A.employee_id = X_Employee_Id
                    AND  ( A.rowid <> X_Rowid  or X_Rowid is null));
  ELSIF (x_employee_name IS NOT NULL) THEN
        SELECT 1
        INTO dummy
        FROM dual
        WHERE EXISTS
                 (SELECT 1
                  FROM   GL_AUTHORIZATION_LIMITS_V A
                  WHERE  A.ledger_id = X_Ledger_Id
                    AND  A.employee_name = X_employee_name
                    AND  ( A.rowid <> X_Rowid  or X_Rowid is null));

  END IF;

  IF (dummy = 1) THEN
    return (FALSE);
  ELSE
    return (TRUE);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  return(TRUE);

END Check_Unique;

END GL_AUTHORIZATION_LIMITS_PKG;

/
