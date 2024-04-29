--------------------------------------------------------
--  DDL for Package Body BOM_RESOURCE_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RESOURCE_CHANGES_PKG" as
/* $Header: bompbrcb.pls 115.6 2002/11/19 03:06:01 lnarveka ship $ */

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Shift_Num                      NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_From_Date                      DATE,
                     X_To_Date                        DATE DEFAULT NULL,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Capacity_Change                NUMBER DEFAULT NULL,
                     X_Simulation_Set                 VARCHAR2,
                     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
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
                     X_Action_Type                    NUMBER,
                     X_Reason_Code                    VARCHAR2 DEFAULT NULL
 ) IS
  v_to_date	DATE := to_date('31/12/1950','DD/MM/YYYY');

  CURSOR C IS SELECT rowid FROM BOM_RESOURCE_CHANGES BRC
              WHERE department_id = X_Department_Id
                AND resource_id = X_Resource_Id
                AND shift_num = X_Shift_Num
     		AND Simulation_Set = X_Simulation_Set
     		AND From_Date   = X_From_Date
     		AND nvl(BRC.To_Date,v_to_date) = nvl(X_To_Date,v_to_date)
     		AND nvl(From_Time,'90000')= nvl(X_From_Time,'90000')
     		AND nvl(To_Time,'90000')  = nvl(X_To_Time,'90000')
     		AND Action_Type = X_Action_Type;

BEGIN
  INSERT INTO BOM_RESOURCE_CHANGES(
               department_id,
               resource_id,
               shift_num,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               from_date,
               to_date,
               from_time,
               to_time,
               capacity_change,
               simulation_set,
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
               action_type,
	       reason_code
             ) VALUES (
               X_Department_Id,
               X_Resource_Id,
               X_Shift_Num,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_From_Date,
               X_To_Date,
               X_From_Time,
               X_To_Time,
               X_Capacity_Change,
               X_Simulation_Set,
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
               X_Attribute15,
               X_Action_Type,
	       X_Reason_Code
             );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    Raise NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;




PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                   X_Department_Id                    NUMBER,
                   X_Resource_Id                      NUMBER,
                   X_Shift_Num                        NUMBER,
                   X_From_Date                        DATE,
                   X_To_Date                          DATE DEFAULT NULL,
                   X_From_Time                        NUMBER DEFAULT NULL,
                   X_To_Time                          NUMBER DEFAULT NULL,
                   X_Capacity_Change                  NUMBER DEFAULT NULL,
                   X_Simulation_Set                   VARCHAR2,
                   X_Attribute_Category               VARCHAR2 DEFAULT NULL,
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
                   X_Action_Type                      NUMBER,
                   X_Reason_Code                      VARCHAR2 DEFAULT NULL
  ) IS
  CURSOR C IS SELECT * FROM BOM_RESOURCE_CHANGES
              WHERE  rowid = X_Rowid
              FOR UPDATE of Department_Id NOWAIT;
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
  if (
               (Recinfo.department_id = X_Department_Id)
           AND (Recinfo.resource_id = X_Resource_Id)
           AND (Recinfo.shift_num = X_Shift_Num)
           AND (Recinfo.from_date = X_From_Date)
           AND (   (Recinfo.to_date = X_To_Date)
                OR (    (Recinfo.to_date IS NULL)
                    AND (X_To_Date IS NULL)))
           AND (   (Recinfo.from_time = X_From_Time)
                OR (    (Recinfo.from_time IS NULL)
                    AND (X_From_Time IS NULL)))
           AND (   (Recinfo.to_time = X_To_Time)
                OR (    (Recinfo.to_time IS NULL)
                    AND (X_To_Time IS NULL)))
           AND (   (Recinfo.capacity_change = X_Capacity_Change)
                OR (    (Recinfo.capacity_change IS NULL)
                    AND (X_Capacity_Change IS NULL)))
           AND (Recinfo.simulation_set = X_Simulation_Set)
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
           AND (Recinfo.action_type = X_Action_Type)
           AND (   (Recinfo.reason_code = X_Reason_Code)
                OR (    (Recinfo.reason_code IS NULL)
                    AND (X_Reason_Code IS NULL)))
            ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;



PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Shift_Num                      NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_From_Date                      DATE,
                     X_To_Date                        DATE DEFAULT NULL,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Capacity_Change                NUMBER DEFAULT NULL,
                     X_Simulation_Set                 VARCHAR2,
                     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
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
                     X_Action_Type                    NUMBER,
		     X_Reason_Code		      VARCHAR2 DEFAULT NULL
 ) IS
BEGIN
  UPDATE BOM_RESOURCE_CHANGES
  SET
     department_id                     =     X_Department_Id,
     resource_id                       =     X_Resource_Id,
     shift_num                         =     X_Shift_Num,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     from_date                         =     X_From_Date,
     to_date                           =     X_To_Date,
     from_time                         =     X_From_Time,
     to_time                           =     X_To_Time,
     capacity_change                   =     X_Capacity_Change,
     simulation_set                    =     X_Simulation_Set,
     attribute_category                =     X_Attribute_Category,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15,
     action_type                       =     X_Action_Type,
     reason_code		       =     X_Reason_Code
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM BOM_RESOURCE_CHANGES
    WHERE  rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Delete_Row;

PROCEDURE Check_Unique(X_Rowid VARCHAR2,
                       X_Action_Type NUMBER,
                       X_From_Date DATE,
                       X_To_Date DATE,
                       X_From_Time NUMBER,
                       X_To_Time NUMBER,
                       X_Department_Id NUMBER,
                       X_Resource_Id NUMBER,
                       X_Shift_Num NUMBER,
                       X_Simulation_Set VARCHAR2) IS

  v_to_date	Date := to_date('31/12/1950','DD/MM/YYYY');
  DUMMY NUMBER;
BEGIN
  SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_RESOURCE_CHANGES BRC
     WHERE ACTION_TYPE = X_ACTION_TYPE
     AND FROM_DATE   = X_FROM_DATE
     AND NVL(BRC.TO_DATE,v_to_date) = NVL(X_TO_DATE,v_to_date)
     AND NVL(FROM_TIME,'90000')=NVL(X_FROM_TIME,'90000')
     AND NVL(TO_TIME,'90000')  =NVL(X_TO_TIME,'90000')
     AND DEPARTMENT_ID = X_DEPARTMENT_ID
     AND RESOURCE_ID   = X_RESOURCE_ID
     AND SHIFT_NUM  = X_SHIFT_NUM
     AND SIMULATION_SET = X_SIMULATION_SET
     AND (( X_ROWID IS NULL) OR (ROWID <> X_ROWID))
     );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('BOM','BOM_CANNOT_ENTER_CAP_CHANGE');
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique;


/* GRANT EXECUTE ON BOM_RESOURCE_SHIFTS_PKG TO MFG; */



END BOM_RESOURCE_CHANGES_PKG;

/
