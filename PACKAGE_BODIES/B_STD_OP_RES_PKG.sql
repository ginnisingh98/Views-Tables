--------------------------------------------------------
--  DDL for Package Body B_STD_OP_RES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."B_STD_OP_RES_PKG" as
/* $Header: BOMPISRB.pls 115.7 2003/12/24 08:59:05 dpsingh ship $ */


PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Standard_Operation_Id               NUMBER,
                     X_Resource_Id                         NUMBER,
                     X_Activity_Id                         NUMBER DEFAULT NULL,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Resource_Seq_Num                    NUMBER,
                     X_Usage_Rate_Or_Amount                NUMBER,
                     X_Usage_Rate_Or_Amount_Inverse        NUMBER,
                     X_Basis_Type                          NUMBER,
                     X_Autocharge_Type                     NUMBER,
                     X_Standard_Rate_Flag                  NUMBER,
                     X_Assigned_Units                      NUMBER DEFAULT NULL,
                     X_Schedule_Flag                       NUMBER,
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
          Insert_Row(X_Rowid                             => X_Rowid,
                     X_Standard_Operation_Id             => X_Standard_Operation_Id,
                     X_Resource_Id                       => X_Resource_Id,
		     X_Substitute_Group_Num              => NULL,
                     X_Activity_Id                       => X_Activity_Id,
                     X_Last_Update_Date                  => X_Last_Update_Date,
                     X_Last_Updated_By                   => X_Last_Updated_By,
                     X_Creation_Date                     => X_Creation_Date,
                     X_Created_By                        => X_Created_By,
                     X_Last_Update_Login                 => X_Last_Update_Login,
                     X_Resource_Seq_Num                  => X_Resource_Seq_Num,
                     X_Usage_Rate_Or_Amount              => X_Usage_Rate_Or_Amount,
                     X_Usage_Rate_Or_Amount_Inverse      => X_Usage_Rate_Or_Amount_Inverse,
                     X_Basis_Type                        => X_Basis_Type,
                     X_Autocharge_Type                   => X_Autocharge_Type,
                     X_Standard_Rate_Flag                => X_Standard_Rate_Flag,
                     X_Assigned_Units                    => X_Assigned_Units,
                     X_Schedule_Flag                     => X_Schedule_Flag,
                     X_Attribute_Category                => X_Attribute_Category,
                     X_Attribute1                        => X_Attribute1,
                     X_Attribute2                        => X_Attribute2,
                     X_Attribute3                        => X_Attribute3,
                     X_Attribute4                        => X_Attribute4,
                     X_Attribute5                        => X_Attribute5,
                     X_Attribute6                        => X_Attribute6,
                     X_Attribute7                        => X_Attribute7,
                     X_Attribute8                        => X_Attribute8,
                     X_Attribute9                        => X_Attribute9,
                     X_Attribute10                       => X_Attribute10,
                     X_Attribute11                       => X_Attribute11,
                     X_Attribute12                       => X_Attribute12,
                     X_Attribute13                       => X_Attribute13,
                     X_Attribute14                       => X_Attribute14,
                     X_Attribute15                       => X_Attribute15

  );

END Insert_Row;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Standard_Operation_Id               NUMBER,
                     X_Resource_Id                         NUMBER,
		     X_Substitute_Group_Num                NUMBER,
                     X_Activity_Id                         NUMBER DEFAULT NULL,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Resource_Seq_Num                    NUMBER,
                     X_Usage_Rate_Or_Amount                NUMBER,
                     X_Usage_Rate_Or_Amount_Inverse        NUMBER,
                     X_Basis_Type                          NUMBER,
                     X_Autocharge_Type                     NUMBER,
                     X_Standard_Rate_Flag                  NUMBER,
                     X_Assigned_Units                      NUMBER DEFAULT NULL,
                     X_Schedule_Flag                       NUMBER,
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
   CURSOR C IS SELECT rowid FROM BOM_STD_OP_RESOURCES
             WHERE standard_operation_id = X_Standard_Operation_Id
             AND   resource_seq_num = X_Resource_Seq_Num;

BEGIN
  INSERT INTO BOM_STD_OP_RESOURCES(
          standard_operation_id,
          resource_id,
	  substitute_group_num,
          activity_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          resource_seq_num,
          usage_rate_or_amount,
          usage_rate_or_amount_inverse,
          basis_type,
          autocharge_type,
          standard_rate_flag,
          assigned_units,
          schedule_flag,
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
          X_Standard_Operation_Id,
          X_Resource_Id,
	  X_Substitute_Group_Num,
          X_Activity_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Resource_Seq_Num,
          X_Usage_Rate_Or_Amount,
          X_Usage_Rate_Or_Amount_Inverse,
          X_Basis_Type,
          X_Autocharge_Type,
          X_Standard_Rate_Flag,
          X_Assigned_Units,
          X_Schedule_Flag,
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
                   X_Standard_Operation_Id                 NUMBER,
                   X_Resource_Id                           NUMBER,
                   X_Activity_Id                           NUMBER DEFAULT NULL,
                   X_Resource_Seq_Num                      NUMBER,
                   X_Usage_Rate_Or_Amount                  NUMBER,
                   X_Usage_Rate_Or_Amount_Inverse          NUMBER,
                   X_Basis_Type                            NUMBER,
                   X_Autocharge_Type                       NUMBER,
                   X_Standard_Rate_Flag                    NUMBER,
                   X_Assigned_Units                        NUMBER DEFAULT NULL,
                   X_Schedule_Flag                         NUMBER,
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

BEGIN

          Lock_Row(X_Rowid                                 => X_Rowid,
                   X_Standard_Operation_Id                 => X_Standard_Operation_Id,
                   X_Resource_Id                           => X_Resource_Id,
		   X_Substitute_Group_Num                  => NULL,
                   X_Activity_Id                           => X_Activity_Id,
                   X_Resource_Seq_Num                      => X_Resource_Seq_Num,
                   X_Usage_Rate_Or_Amount                  => X_Usage_Rate_Or_Amount,
                   X_Usage_Rate_Or_Amount_Inverse          => X_Usage_Rate_Or_Amount_Inverse,
                   X_Basis_Type                            => X_Basis_Type,
                   X_Autocharge_Type                       => X_Autocharge_Type,
                   X_Standard_Rate_Flag                    => X_Standard_Rate_Flag,
                   X_Assigned_Units                        => X_Assigned_Units,
                   X_Schedule_Flag                         => X_Schedule_Flag,
                   X_Attribute_Category                    => X_Attribute_Category,
                   X_Attribute1                            => X_Attribute1,
                   X_Attribute2                            => X_Attribute2,
                   X_Attribute3                            => X_Attribute3,
                   X_Attribute4                            => X_Attribute4,
                   X_Attribute5                            => X_Attribute5,
                   X_Attribute6                            => X_Attribute6,
                   X_Attribute7                            => X_Attribute7,
                   X_Attribute8                            => X_Attribute8,
                   X_Attribute9                            => X_Attribute9,
                   X_Attribute10                           => X_Attribute10,
                   X_Attribute11                           => X_Attribute11,
                   X_Attribute12                           => X_Attribute12,
                   X_Attribute13                           => X_Attribute13,
                   X_Attribute14                           => X_Attribute14,
                   X_Attribute15                           => X_Attribute15);

END Lock_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Standard_Operation_Id                 NUMBER,
                   X_Resource_Id                           NUMBER,
		   X_Substitute_Group_Num                  NUMBER,
                   X_Activity_Id                           NUMBER DEFAULT NULL,
                   X_Resource_Seq_Num                      NUMBER,
                   X_Usage_Rate_Or_Amount                  NUMBER,
                   X_Usage_Rate_Or_Amount_Inverse          NUMBER,
                   X_Basis_Type                            NUMBER,
                   X_Autocharge_Type                       NUMBER,
                   X_Standard_Rate_Flag                    NUMBER,
                   X_Assigned_Units                        NUMBER DEFAULT NULL,
                   X_Schedule_Flag                         NUMBER,
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
      FROM   BOM_STD_OP_RESOURCES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Standard_Operation_Id, Substitute_Group_Num NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.standard_operation_id = X_Standard_Operation_Id)
           OR (    (Recinfo.standard_operation_id IS NULL)
               AND (X_Standard_Operation_Id IS NULL)))
      AND (   (Recinfo.resource_id = X_Resource_Id)
           OR (    (Recinfo.resource_id IS NULL)
               AND (X_Resource_Id IS NULL)))
      AND (   (Recinfo.substitute_group_num = X_Substitute_Group_Num)
           OR (    (Recinfo.Substitute_Group_Num IS NULL)
               AND (X_Substitute_Group_Num IS NULL)))
      AND (   (Recinfo.activity_id = X_Activity_Id)
           OR (    (Recinfo.activity_id IS NULL)
               AND (X_Activity_Id IS NULL)))
      AND (   (Recinfo.resource_seq_num = X_Resource_Seq_Num)
           OR (    (Recinfo.resource_seq_num IS NULL)
               AND (X_Resource_Seq_Num IS NULL)))
      AND (   (Recinfo.usage_rate_or_amount = X_Usage_Rate_Or_Amount)
           OR (    (Recinfo.usage_rate_or_amount IS NULL)
               AND (X_Usage_Rate_Or_Amount IS NULL)))
      AND (   (Recinfo.usage_rate_or_amount_inverse = X_Usage_Rate_Or_Amount_Inverse)
           OR (    (Recinfo.usage_rate_or_amount_inverse IS NULL)
               AND (X_Usage_Rate_Or_Amount_Inverse IS NULL)))
      AND (   (Recinfo.basis_type = X_Basis_Type)
           OR (    (Recinfo.basis_type IS NULL)
               AND (X_Basis_Type IS NULL)))
      AND (   (Recinfo.autocharge_type = X_Autocharge_Type)
           OR (    (Recinfo.autocharge_type IS NULL)
               AND (X_Autocharge_Type IS NULL)))
      AND (   (Recinfo.standard_rate_flag = X_Standard_Rate_Flag)
           OR (    (Recinfo.standard_rate_flag IS NULL)
               AND (X_Standard_Rate_Flag IS NULL)))
      AND (   (Recinfo.assigned_units = X_Assigned_Units)
           OR (    (Recinfo.assigned_units IS NULL)
               AND (X_Assigned_Units IS NULL)))
      AND (   (Recinfo.schedule_flag = X_Schedule_Flag)
           OR (    (Recinfo.schedule_flag IS NULL)
               AND (X_Schedule_Flag IS NULL)))
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
                     X_Standard_Operation_Id               NUMBER,
                     X_Resource_Id                         NUMBER,
                     X_Activity_Id                         NUMBER DEFAULT NULL,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Resource_Seq_Num                    NUMBER,
                     X_Usage_Rate_Or_Amount                NUMBER,
                     X_Usage_Rate_Or_Amount_Inverse        NUMBER,
                     X_Basis_Type                          NUMBER,
                     X_Autocharge_Type                     NUMBER,
                     X_Standard_Rate_Flag                  NUMBER,
                     X_Assigned_Units                      NUMBER DEFAULT NULL,
                     X_Schedule_Flag                       NUMBER,
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
          Update_Row(X_Rowid                               => X_Rowid,
                     X_Standard_Operation_Id               => X_Standard_Operation_Id,
                     X_Resource_Id                         => X_Resource_Id,
		     X_Substitute_Group_Num                => NULL,
                     X_Activity_Id                         => X_Activity_Id,
                     X_Last_Update_Date                    => X_Last_Update_Date,
                     X_Last_Updated_By                     => X_Last_Updated_By,
                     X_Last_Update_Login                   => X_Last_Update_Login,
                     X_Resource_Seq_Num                    => X_Resource_Seq_Num,
                     X_Usage_Rate_Or_Amount                => X_Usage_Rate_Or_Amount,
                     X_Usage_Rate_Or_Amount_Inverse        => X_Usage_Rate_Or_Amount_Inverse,
                     X_Basis_Type                          => X_Basis_Type,
                     X_Autocharge_Type                     => X_Autocharge_Type,
                     X_Standard_Rate_Flag                  => X_Standard_Rate_Flag,
                     X_Assigned_Units                      => X_Assigned_Units,
                     X_Schedule_Flag                       => X_Schedule_Flag,
                     X_Attribute_Category                  => X_Attribute_Category,
                     X_Attribute1                            => X_Attribute1,
                     X_Attribute2                            => X_Attribute2,
                     X_Attribute3                            => X_Attribute3,
                     X_Attribute4                            => X_Attribute4,
                     X_Attribute5                            => X_Attribute5,
                     X_Attribute6                            => X_Attribute6,
                     X_Attribute7                            => X_Attribute7,
                     X_Attribute8                            => X_Attribute8,
                     X_Attribute9                            => X_Attribute9,
                     X_Attribute10                           => X_Attribute10,
                     X_Attribute11                           => X_Attribute11,
                     X_Attribute12                           => X_Attribute12,
                     X_Attribute13                           => X_Attribute13,
                     X_Attribute14                           => X_Attribute14,
                     X_Attribute15                           => X_Attribute15);

END Update_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Standard_Operation_Id               NUMBER,
                     X_Resource_Id                         NUMBER,
		     X_Substitute_Group_Num                NUMBER,
                     X_Activity_Id                         NUMBER DEFAULT NULL,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Resource_Seq_Num                    NUMBER,
                     X_Usage_Rate_Or_Amount                NUMBER,
                     X_Usage_Rate_Or_Amount_Inverse        NUMBER,
                     X_Basis_Type                          NUMBER,
                     X_Autocharge_Type                     NUMBER,
                     X_Standard_Rate_Flag                  NUMBER,
                     X_Assigned_Units                      NUMBER DEFAULT NULL,
                     X_Schedule_Flag                       NUMBER,
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
  UPDATE BOM_STD_OP_RESOURCES
  SET
    standard_operation_id                     =    X_Standard_Operation_Id,
    resource_id                               =    X_Resource_Id,
    substitute_group_num                      =    X_Substitute_Group_Num,
    activity_id                               =    X_Activity_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    resource_seq_num                          =    X_Resource_Seq_Num,
    usage_rate_or_amount                      =    X_Usage_Rate_Or_Amount,
    usage_rate_or_amount_inverse              =    X_Usage_Rate_Or_Amount_Inverse,
    basis_type                                =    X_Basis_Type,
    autocharge_type                           =    X_Autocharge_Type,
    standard_rate_flag                        =    X_Standard_Rate_Flag,
    assigned_units                            =    X_Assigned_Units,
    schedule_flag                             =    X_Schedule_Flag,
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
  DELETE FROM BOM_STD_OP_RESOURCES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

PROCEDURE Check_Unique(X_Rowid VARCHAR2,
		       X_Standard_Operation_Id NUMBER,
		       X_Resource_Seq_Num NUMBER) IS
  dummy NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_STD_OP_RESOURCES
     WHERE Standard_Operation_Id = X_Standard_Operation_Id
       AND Resource_Seq_Num = X_Resource_Seq_Num
       AND ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
    );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('BOM', 'BOM_ALREADY_EXISTS');
    FND_MESSAGE.SET_TOKEN('ENTITY1', 'SEQUENCE NUMBER_CAP', TRUE);
    FND_MESSAGE.SET_TOKEN('ENTITY2', X_Resource_Seq_Num);
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique;


END B_STD_OP_RES_PKG;

/
