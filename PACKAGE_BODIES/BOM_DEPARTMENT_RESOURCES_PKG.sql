--------------------------------------------------------
--  DDL for Package Body BOM_DEPARTMENT_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEPARTMENT_RESOURCES_PKG" as
/* $Header: bompbdrb.pls 120.1.12010000.2 2009/12/10 11:33:06 ybabulal ship $ */

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Share_Capacity_Flag            NUMBER,
                     X_Share_From_Dept_Id             NUMBER DEFAULT NULL,
                     X_Capacity_Units                 NUMBER DEFAULT NULL,
                     X_Resource_Group_Name            VARCHAR2 DEFAULT NULL,
                     X_Available_24_Hours_Flag        NUMBER,
		     X_Ctp_Flag			      NUMBER,
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
                     X_Exception_Set_Name	      VARCHAR2 DEFAULT NULL,
                     X_ATP_Rule_Id                    NUMBER DEFAULT NULL,
                     X_Utilization                    NUMBER DEFAULT NULL,
                     X_Efficiency                     NUMBER DEFAULT NULL,
                     X_Schedule_To_Instance           NUMBER,
                     X_Sequencing_Window	      NUMBER DEFAULT NULL,       --APS Enhancement for Routings
	             X_Idle_Time_Tolerance	      NUMBER DEFAULT NULL        --APS Enhancement for Routings
 ) IS
   CURSOR C IS SELECT rowid FROM BOM_DEPARTMENT_RESOURCES
               WHERE department_id = X_Department_Id
               AND   resource_id = X_Resource_Id;
  BEGIN
    INSERT INTO BOM_DEPARTMENT_RESOURCES(
               department_id,
               resource_id,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               share_capacity_flag,
               share_from_dept_id,
               capacity_units,
               resource_group_name,
               available_24_hours_flag,
			   ctp_flag,
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
               exception_set_name,
	       atp_rule_id,
	       utilization,
	       efficiency,
	       schedule_to_instance,
	       sequencing_window,               --APS Enhancement for Routings
	       idle_time_tolerance              --APS Enhancement for Routings
             ) VALUES (
               X_Department_Id,
               X_Resource_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Share_Capacity_Flag,
               X_Share_From_Dept_Id,
               X_Capacity_Units,
               X_Resource_Group_Name,
               X_Available_24_Hours_Flag,
			   X_Ctp_Flag,
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
               X_Exception_Set_Name,
	       x_Atp_Rule_Id,
	       X_Utilization,
	       X_Efficiency,
 	       X_Schedule_To_Instance,
	       X_Sequencing_Window,            --APS Enhancement for Routings
	       X_Idle_Time_Tolerance           --APS Enhancement for Routings
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
                   X_Share_Capacity_Flag              NUMBER,
                   X_Share_From_Dept_Id               NUMBER DEFAULT NULL,
                   X_Capacity_Units                   NUMBER DEFAULT NULL,
                   X_Resource_Group_Name              VARCHAR2 DEFAULT NULL,
                   X_Available_24_Hours_Flag          NUMBER,
		   X_Ctp_Flag			      NUMBER,
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
                   X_Exception_Set_Name		      VARCHAR2 DEFAULT NULL,
                   X_ATP_Rule_Id                      NUMBER DEFAULT NULL,
                   X_Utilization                      NUMBER DEFAULT NULL,
                   X_Efficiency                       NUMBER DEFAULT NULL,
                   X_Schedule_To_Instance             NUMBER,
		   X_Sequencing_Window	              NUMBER DEFAULT NULL,          --APS Enhancement for Routings
	           X_Idle_Time_Tolerance	      NUMBER DEFAULT NULL           --APS Enhancement for Routings

) IS
  CURSOR C IS
    SELECT *
      FROM BOM_DEPARTMENT_RESOURCES
      WHERE rowid = X_Rowid
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
           AND (Recinfo.share_capacity_flag = X_Share_Capacity_Flag)
           AND (   (Recinfo.share_from_dept_id = X_Share_From_Dept_Id)
                OR (    (Recinfo.share_from_dept_id IS NULL)
                    AND (X_Share_From_Dept_Id IS NULL)))
           AND (   (Recinfo.capacity_units = X_Capacity_Units)
                OR (    (Recinfo.capacity_units IS NULL)
                    AND (X_Capacity_Units IS NULL)))
           AND (   (Recinfo.resource_group_name = X_Resource_Group_Name)
                OR (    (Recinfo.resource_group_name IS NULL)
                    AND (X_Resource_Group_Name IS NULL)))
           AND (Recinfo.available_24_hours_flag = X_Available_24_Hours_Flag)
           AND (   (Recinfo.ctp_flag = X_Ctp_Flag)
                OR (    (Recinfo.ctp_flag IS NULL)
                    AND (X_Ctp_Flag IS NULL)))
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
	   AND (   (Recinfo.exception_set_name = X_Exception_Set_Name)
		OR (    (Recinfo.exception_set_name IS NULL)
		    AND (X_Exception_Set_Name IS NULL)))
           AND (   (Recinfo.atp_rule_id= x_atp_rule_id)
                OR (    (Recinfo.atp_rule_id IS NULL)
                    AND (X_atp_rule_id IS NULL)))
           AND (   (Recinfo.utilization= x_utilization)
                OR (    (Recinfo.utilization IS NULL)
                    AND (x_utilization IS NULL)))
	   AND (   (Recinfo.efficiency= x_efficiency)
                OR (    (Recinfo.efficiency IS NULL)
                    AND (x_efficiency IS NULL)))
           AND (   (Recinfo.schedule_to_instance = X_Schedule_To_Instance)
                OR (    (Recinfo.schedule_to_instance IS NULL)
                    AND (X_Schedule_To_Instance IS NULL)))
           AND(   (Recinfo.sequencing_window = X_Sequencing_Window)              --APS Enhancement for Routings
	        OR(    (Recinfo.sequencing_window IS NULL)
		    AND (X_Sequencing_Window IS NULL)))
           AND(   (Recinfo.idle_time_tolerance = X_Idle_Time_Tolerance)          --APS Enhancement for Routings
	        OR(   (Recinfo.idle_time_tolerance IS NULL)
		    AND (X_Idle_Time_Tolerance IS NULL)))
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
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Share_Capacity_Flag            NUMBER,
                     X_Share_From_Dept_Id             NUMBER DEFAULT NULL,
                     X_Capacity_Units                 NUMBER DEFAULT NULL,
                     X_Resource_Group_Name            VARCHAR2 DEFAULT NULL,
                     X_Available_24_Hours_Flag        NUMBER,
		     X_Ctp_Flag			      NUMBER,
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
		     X_Exception_Set_Name	      VARCHAR2 DEFAULT NULL,
                     X_ATP_Rule_Id	 	      NUMBER DEFAULT NULL,
                     X_Utilization                    NUMBER DEFAULT NULL,
                     X_Efficiency                     NUMBER DEFAULT NULL,
                     X_Schedule_To_Instance           NUMBER,
		     X_Sequencing_Window	      NUMBER DEFAULT NULL,         --APS Enhancement for Routings
	             X_Idle_Time_Tolerance	      NUMBER DEFAULT NULL          --APS Enhancement for Routings
 ) IS

    Cursor C is SELECT rowid FROM BOM_DEPARTMENT_RESOURCES
		WHERE share_from_dept_id = X_Department_Id
		  AND resource_id = X_Resource_Id ;
BEGIN
  UPDATE BOM_DEPARTMENT_RESOURCES
  SET
     department_id                     =     X_Department_Id,
     resource_id                       =     X_Resource_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     share_capacity_flag               =     X_Share_Capacity_Flag,
     share_from_dept_id                =     X_Share_From_Dept_Id,
     capacity_units                    =     X_Capacity_Units,
     resource_group_name               =     X_Resource_Group_Name,
     available_24_hours_flag           =     X_Available_24_Hours_Flag,
     ctp_flag			       =     X_Ctp_Flag,
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
     exception_set_name		       =     X_Exception_Set_Name,
     atp_rule_id		       =     X_ATP_Rule_Id,
     utilization	 	       =    X_Utilization,
     efficiency			       =    X_Efficiency,
     schedule_to_instance	       =    X_Schedule_To_Instance,
     sequencing_window                 =    X_Sequencing_Window,                --APS Enhancement for Routings
     idle_time_tolerance               =    X_Idle_Time_Tolerance               --APS Enhancement for Routings
  WHERE rowid = X_rowid;

  FOR c_row_id in C LOOP
   UPDATE BOM_DEPARTMENT_RESOURCES
   SET
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     capacity_units                    =     X_Capacity_Units,
     available_24_hours_flag           =     X_Available_24_Hours_Flag,
     ctp_flag			       =     X_Ctp_Flag,
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
     exception_set_name		       =     X_Exception_Set_Name,
     /*atp_rule_id		       =     X_ATP_Rule_Id,		       -- BUG 3961376
     utilization	 	       =    X_Utilization,
     efficiency			       =    X_Efficiency,
     schedule_to_instance	       =    X_Schedule_To_Instance,
     sequencing_window                 =    X_Sequencing_Window,               --APS Enhancement for Routings
     idle_time_tolerance               =    X_Idle_Time_Tolerance*/            --APS Enhancement for Routings
     atp_rule_id		       =     X_ATP_Rule_Id,		       /* Added this to enable update of atp_rule_id, utilization & efficiency for bug 6321534*/
     utilization	 	       =    X_Utilization,
     efficiency			       =    X_Efficiency
  WHERE rowid = c_row_id.rowid;
  END LOOP ;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;

END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM BOM_DEPARTMENT_RESOURCES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Delete_Row;



PROCEDURE Check_Unique(X_Rowid VARCHAR2,
		       X_Department_Id NUMBER,
		       X_Resource_Id NUMBER) IS
  dummy 	NUMBER;
  res_code	VARCHAR2(10);
BEGIN
  SELECT RESOURCE_CODE INTO res_code FROM BOM_RESOURCES
     WHERE RESOURCE_ID = X_Resource_Id;
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_DEPARTMENT_RESOURCES
     WHERE DEPARTMENT_ID = X_Department_Id
       AND RESOURCE_ID = X_Resource_Id
       AND ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
    );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('BOM', 'BOM_ALREADY_EXISTS');
    FND_MESSAGE.SET_TOKEN('ENTITY1', 'RESOURCE_CAP', TRUE);
    FND_MESSAGE.SET_TOKEN('ENTITY2', res_code);
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique;


PROCEDURE Check_References(X_Rowid VARCHAR2,
			   X_Resource_Id NUMBER,
			   X_Department_Id NUMBER) IS
  dummy			NUMBER;
  err_code		NUMBER;
  message_name		VARCHAR2(80);
  res_code		VARCHAR2(10);
BEGIN
  SELECT RESOURCE_CODE INTO res_code FROM BOM_RESOURCES
     WHERE RESOURCE_ID = X_Resource_Id;

  err_code := 1;
  message_name := 'BOM_CANNOT_DELETE_RESOURCE';
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_RESOURCE_SHIFTS
     WHERE DEPARTMENT_ID = X_Department_Id
       AND RESOURCE_ID = X_Resource_Id);

  err_code := 2;
  message_name := 'BOM_CANNOT_DELETE_SHARED_RES';
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_DEPARTMENT_RESOURCES
     WHERE SHARE_FROM_DEPT_ID = X_Department_Id
       AND RESOURCE_ID = X_Resource_Id);

  err_code := 3;
  message_name := 'BOM_CANNOT_DELETE_RES_STD_OP';
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_STD_OP_RESOURCES bsor,
		              BOM_STANDARD_OPERATIONS bso
     WHERE bso.STANDARD_OPERATION_ID = bsor.STANDARD_OPERATION_ID
       AND bso.DEPARTMENT_ID = X_Department_Id
       AND bsor.RESOURCE_ID = X_Resource_Id);

  message_name := 'BOM_CANNOT_DELETE_RES_ROUTING';
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_OPERATION_RESOURCES bor,
			      BOM_OPERATION_SEQUENCES bos
     WHERE bor.OPERATION_SEQUENCE_ID = bos.OPERATION_SEQUENCE_ID
       AND bor.RESOURCE_ID = X_Resource_Id
       AND bos.DEPARTMENT_ID = X_Department_Id);

  message_name := 'BOM_CANNOT_DELETE_RES_WIP_OP';
  /* bug 9186572 - added WIP_DISCRETE_JOBS to check for the status of job also */
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM WIP_OPERATIONS wo,
                   WIP_OPERATION_RESOURCES wor,
                   WIP_DISCRETE_JOBS wdj
     WHERE wo.WIP_ENTITY_ID = wor.WIP_ENTITY_ID
       AND wdj.WIP_ENTITY_ID = wo.WIP_ENTITY_ID
       AND wo.OPERATION_SEQ_NUM = wor.OPERATION_SEQ_NUM
       AND wo.ORGANIZATION_ID = wor.ORGANIZATION_ID
       AND nvl(wo.REPETITIVE_SCHEDULE_ID, -1) = nvl(wor.REPETITIVE_SCHEDULE_ID, -1)
       AND wor.RESOURCE_ID = X_Resource_Id
       AND wo.DEPARTMENT_ID = X_Department_Id
       AND wdj.STATUS_TYPE <> 12);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF err_code = 1 THEN
      FND_MESSAGE.SET_NAME('BOM',message_name);
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSIF err_code = 2 THEN
      FND_MESSAGE.SET_NAME('BOM',message_name);
      FND_MESSAGE.SET_TOKEN('ENTITY', res_code);
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSIF err_code = 3 THEN
      FND_MESSAGE.SET_NAME('BOM', message_name);
      FND_MESSAGE.SET_TOKEN('ENTITY', res_code);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Check_References;



END BOM_DEPARTMENT_RESOURCES_PKG;

/
