--------------------------------------------------------
--  DDL for Package Body BOM_RES_INSTANCE_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RES_INSTANCE_CHANGES_PKG" as
/* $Header: bompricb.pls 115.5 2002/11/27 01:25:46 chrng ship $ */

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Shift_Num                      NUMBER,
                     X_Simulation_Set                 VARCHAR2,
                     X_From_Date                      DATE,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Date                        DATE   DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Instance_Id                    NUMBER,
                     X_Serial_Number                  VARCHAR2 DEFAULT NULL,
                     X_Action_Type                    NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER   DEFAULT NULL,
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
                     X_Capacity_Change                NUMBER   DEFAULT NULL,
                     X_Reason_Code                    VARCHAR2 DEFAULT NULL,
			-- chrng: added the Source fields
			X_Maintenance_Organization_Id	NUMBER	DEFAULT NULL,
			X_Wip_Entity_Id			NUMBER	DEFAULT NULL,
			X_Operation_Seq_Num		NUMBER	DEFAULT NULL
 ) IS

  v_to_date	DATE := to_date('31/12/1950', 'DD/MM/YYYY');

  CURSOR C IS SELECT rowid FROM BOM_RES_INSTANCE_CHANGES
   Where Department_Id 	      	= X_Department_Id
     And Resource_Id   		= X_Resource_Id
     And Shift_Num  		= X_Shift_Num
     And Simulation_Set 	= X_Simulation_Set
     And From_Date   		= X_From_Date
     And nvl(to_date,v_to_date) = nvl(X_To_Date,v_to_date)
     And nvl(from_time,'90000')	= nvl(X_From_Time,'90000')
     And nvl(to_time,'90000')  	= nvl(X_To_Time,'90000')
     And instance_id 		= X_Instance_Id
     And nvl(serial_number,'x') = nvl(X_Serial_Number,'x')
     And action_type 		= X_Action_Type;

BEGIN
  INSERT INTO BOM_RES_INSTANCE_CHANGES(
               department_id,
               resource_id,
               shift_num,
               simulation_set,
               from_date,
               from_time,
               to_date,
               to_time,
               instance_id,
               serial_number,
               action_type,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
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
               capacity_change,
	       reason_code,
		-- chrng: added the Source fields
		maintenance_organization_id,
		wip_entity_id,
		operation_seq_num

             ) VALUES (
               X_Department_Id,
               X_Resource_Id,
               X_Shift_Num,
               X_Simulation_Set,
               X_From_Date,
               X_From_Time,
               X_To_Date,
               X_To_Time,
               X_Instance_Id,
               X_Serial_Number,
               X_Action_Type,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
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
               X_Capacity_Change,
	       X_Reason_Code,
		-- chrng: added the Source fields
		X_Maintenance_Organization_Id,
		X_Wip_Entity_Id,
		X_Operation_Seq_Num
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
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Shift_Num                      NUMBER,
                     X_Simulation_Set                 VARCHAR2,
                     X_From_Date                      DATE,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Date                        DATE   DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Instance_Id                    NUMBER,
                     X_Serial_Number                  VARCHAR2 DEFAULT NULL,
                     X_Action_Type                    NUMBER,
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
                     X_Capacity_Change                NUMBER   DEFAULT NULL,
                     X_Reason_Code                    VARCHAR2 DEFAULT NULL,
			-- chrng: added the Source fields
			X_Maintenance_Organization_Id	NUMBER	DEFAULT NULL,
			X_Wip_Entity_Id			NUMBER	DEFAULT NULL,
			X_Operation_Seq_Num		NUMBER	DEFAULT NULL
  ) IS
  CURSOR C IS SELECT * FROM BOM_RES_INSTANCE_CHANGES
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
           AND (Recinfo.simulation_set = X_Simulation_Set)
           AND (Recinfo.from_date = X_From_Date)
           AND (   (Recinfo.from_time = X_From_Time)
                OR (    (Recinfo.from_time IS NULL)
                    AND (X_From_Time IS NULL)))
           AND (   (Recinfo.to_date = X_To_Date)
                OR (    (Recinfo.to_date IS NULL)
                    AND (X_To_Date IS NULL)))
           AND (   (Recinfo.to_time = X_To_Time)
                OR (    (Recinfo.to_time IS NULL)
                    AND (X_To_Time IS NULL)))
           AND (Recinfo.instance_id = X_Instance_Id)
           AND (   (Recinfo.serial_number = X_Serial_Number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_Serial_Number IS NULL)))
           AND (Recinfo.action_type = X_Action_Type)
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
           AND (   (Recinfo.capacity_change = X_Capacity_Change)
                OR (    (Recinfo.capacity_change IS NULL)
                    AND (X_Capacity_Change IS NULL)))
           AND (   (Recinfo.reason_code = X_Reason_Code)
                OR (    (Recinfo.reason_code IS NULL)
                    AND (X_Reason_Code IS NULL)))
           AND (   (Recinfo.maintenance_organization_id = X_Maintenance_Organization_Id)
                OR (    (Recinfo.maintenance_organization_id IS NULL)
                    AND (X_Maintenance_Organization_Id IS NULL)))
           AND (   (Recinfo.wip_entity_id = X_Wip_Entity_Id)
                OR (    (Recinfo.wip_entity_id IS NULL)
                    AND (X_Wip_Entity_Id IS NULL)))
           AND (   (Recinfo.operation_seq_num = X_Operation_Seq_Num)
                OR (    (Recinfo.operation_seq_num IS NULL)
                    AND (X_Operation_Seq_Num IS NULL)))
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
                     X_Simulation_Set                 VARCHAR2,
                     X_From_Date                      DATE,
                     X_From_Time                      NUMBER DEFAULT NULL,
                     X_To_Date                        DATE   DEFAULT NULL,
                     X_To_Time                        NUMBER DEFAULT NULL,
                     X_Instance_Id                    NUMBER,
                     X_Serial_Number                  VARCHAR2 DEFAULT NULL,
                     X_Action_Type                    NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER   DEFAULT NULL,
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
                     X_Capacity_Change                NUMBER   DEFAULT NULL,
                     X_Reason_Code                    VARCHAR2 DEFAULT NULL,
			-- chrng: added the Source fields
			X_Maintenance_Organization_Id	NUMBER	DEFAULT NULL,
			X_Wip_Entity_Id			NUMBER	DEFAULT NULL,
			X_Operation_Seq_Num		NUMBER	DEFAULT NULL
 ) IS
BEGIN
  UPDATE BOM_RES_INSTANCE_CHANGES
  SET
     department_id                     =     X_Department_Id,
     resource_id                       =     X_Resource_Id,
     shift_num                         =     X_Shift_Num,
     simulation_set                    =     X_Simulation_Set,
     from_date                         =     X_From_Date,
     from_time                         =     X_From_Time,
     to_date                           =     X_To_Date,
     to_time                           =     X_To_Time,
     instance_id                       =     X_Instance_Id,
     serial_number                     =     X_Serial_Number,
     action_type                       =     X_Action_Type,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
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
     capacity_change                   =     X_Capacity_Change,
     reason_code		       =     X_Reason_Code,
	-- chrng: added the Source fields
	maintenance_organization_id 	= 	X_Maintenance_Organization_Id,
	wip_entity_id 			=	X_Wip_Entity_Id,
	operation_seq_num		=	X_Operation_Seq_Num
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM BOM_RES_INSTANCE_CHANGES
    WHERE  rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Delete_Row;

PROCEDURE Check_Unique(X_Rowid           VARCHAR2,
                       X_Department_Id   NUMBER,
                       X_Resource_Id     NUMBER,
                       X_Shift_Num       NUMBER,
                       X_Simulation_Set  VARCHAR2,
                       X_From_Date       DATE,
                       X_From_Time       NUMBER,
                       X_To_Date         DATE,
                       X_To_Time         NUMBER,
                       X_Instance_Id     NUMBER,
                       X_Serial_Number   VARCHAR2,
                       X_Action_Type     NUMBER
  ) IS

  v_to_date	DATE := to_date('31/12/1950', 'DD/MM/YYYY');
  DUMMY NUMBER;
BEGIN
  SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_RES_INSTANCE_CHANGES ric
     Where Department_Id       	 = X_Department_Id
       And Resource_Id   	 = X_Resource_Id
       And Shift_Num  		 = X_Shift_Num
       And Simulation_Set 	 = X_Simulation_Set
       And From_Date   		 = X_From_Date
       And nvl(ric.to_date,v_to_date)=nvl(X_To_Date,v_to_date)
       And nvl(from_time,'90000')= nvl(X_From_Time,'90000')
       And nvl(to_time,'90000')	 = nvl(X_To_Time,'90000')
       And instance_id 		 = X_Instance_Id
       And nvl(serial_number,'x')= nvl(X_Serial_Number,'x')
       And action_type 		 = X_Action_Type
       And (( X_Rowid IS NULL) OR (rowid <> X_Rowid))
     );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('BOM','BOM_CANNOT_ENTER_INS_CHANGES');
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique;


/* GRANT EXECUTE ON BOM_RES_INSTANCE_CHANGES_PKG TO MFG; */


END BOM_RES_INSTANCE_CHANGES_PKG;

/
