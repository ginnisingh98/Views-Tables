--------------------------------------------------------
--  DDL for Package Body CST_RESOURCE_OVERHEADS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_RESOURCE_OVERHEADS_PKG" as
/* $Header: cstrovhb.pls 115.3 2002/11/11 23:21:14 awwang ship $ */


PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Cost_Type_Id                        NUMBER,
                     X_Resource_Id                         NUMBER,
                     X_Overhead_Id                         NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL
 ) IS
   CURSOR C IS SELECT rowid FROM cst_resource_overheads
             WHERE cost_type_id = X_Cost_Type_Id
             AND   resource_id  = X_Resource_Id
             AND   overhead_id  = X_Overhead_Id;

BEGIN

  INSERT INTO cst_resource_overheads(
          cost_type_id,
          resource_id,
          overhead_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          organization_id,
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
          attribute15
         ) VALUES (
          X_Cost_Type_Id,
          X_Resource_Id,
          X_Overhead_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Organization_Id,
          X_Attribute_Category,
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
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Cost_Type_Id                          NUMBER,
                   X_Resource_Id                           NUMBER,
                   X_Overhead_Id                           NUMBER,
                   X_Organization_Id                       NUMBER,
                   X_Attribute_Category                    VARCHAR2 DEFAULT NULL,
                   X_Attribute1                            VARCHAR2 DEFAULT NULL,
                   X_Attribute2                            VARCHAR2 DEFAULT NULL,
                   X_Attribute3                            VARCHAR2 DEFAULT NULL,
                   X_Attribute4                            VARCHAR2 DEFAULT NULL,
                   X_Attribute5                            VARCHAR2 DEFAULT NULL,
                   X_Attribute6                            VARCHAR2 DEFAULT NULL,
                   X_Attribute7                            VARCHAR2 DEFAULT NULL,
                   X_Attribute8                            VARCHAR2 DEFAULT NULL,
                   X_Attribute9                            VARCHAR2 DEFAULT NULL,
                   X_Attribute10                           VARCHAR2 DEFAULT NULL,
                   X_Attribute11                           VARCHAR2 DEFAULT NULL,
                   X_Attribute12                           VARCHAR2 DEFAULT NULL,
                   X_Attribute13                           VARCHAR2 DEFAULT NULL,
                   X_Attribute14                           VARCHAR2 DEFAULT NULL,
                   X_Attribute15                           VARCHAR2 DEFAULT NULL
) IS
  CURSOR C IS
      SELECT *
      FROM   cst_resource_overheads
      WHERE  rowid = X_Rowid
      FOR UPDATE of Cost_Type_Id NOWAIT;
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
          (   (Recinfo.cost_type_id = X_Cost_Type_Id)
           OR (    (Recinfo.cost_type_id IS NULL)
               AND (X_Cost_Type_Id IS NULL)))
      AND (   (Recinfo.resource_id = X_Resource_Id)
           OR (    (Recinfo.resource_id IS NULL)
               AND (X_Resource_Id IS NULL)))
      AND (   (Recinfo.overhead_id = X_Overhead_Id)
           OR (    (Recinfo.overhead_id IS NULL)
               AND (X_Overhead_Id IS NULL)))
      AND (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
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
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Cost_Type_Id                        NUMBER,
                     X_Resource_Id                         NUMBER,
                     X_Overhead_Id                         NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL
) IS
BEGIN

  UPDATE cst_resource_overheads
  SET
    cost_type_id                              =    X_Cost_Type_Id,
    resource_id                               =    X_Resource_Id,
    overhead_id                               =    X_Overhead_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    organization_id                           =    X_Organization_Id,
    attribute_category                        =    X_Attribute_Category,
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

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM cst_resource_overheads
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END CST_RESOURCE_OVERHEADS_PKG;

/
