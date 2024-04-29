--------------------------------------------------------
--  DDL for Package Body MRP_SCHEDULE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SCHEDULE_ITEMS_PKG" AS
/* $Header: MRSITEMB.pls 115.1 99/07/16 12:44:51 porting ship $ */

PROCEDURE Insert_Row(
                  X_Rowid                         IN OUT VARCHAR2,
                  X_Inventory_Item_Id                    NUMBER,
                  X_Organization_Id                      NUMBER,
                  X_Schedule_Designator                  VARCHAR2,
                  X_Last_Update_Date                     DATE,
                  X_Last_Updated_By                      NUMBER,
                  X_Creation_Date                        DATE,
                  X_Created_By                           NUMBER,
                  X_Last_Update_Login                    NUMBER DEFAULT NULL,
                  X_MPS_Explosion_Level                  NUMBER DEFAULT NULL,
                  X_Request_Id                  	 NUMBER DEFAULT NULL,
                  X_Program_Application_Id               NUMBER DEFAULT NULL,
                  X_Program_Id                           NUMBER DEFAULT NULL,
                  X_Program_Update_Date                  DATE DEFAULT NULL,
                  X_Attribute_Category                   VARCHAR2 DEFAULT NULL,
                  X_Attribute1                           VARCHAR2 DEFAULT NULL,
                  X_Attribute2                           VARCHAR2 DEFAULT NULL,
                  X_Attribute3                           VARCHAR2 DEFAULT NULL,
                  X_Attribute4                           VARCHAR2 DEFAULT NULL,
                  X_Attribute5                           VARCHAR2 DEFAULT NULL,
                  X_Attribute6                           VARCHAR2 DEFAULT NULL,
                  X_Attribute7                           VARCHAR2 DEFAULT NULL,
                  X_Attribute8                           VARCHAR2 DEFAULT NULL,
                  X_Attribute9                           VARCHAR2 DEFAULT NULL,
                  X_Attribute10                          VARCHAR2 DEFAULT NULL,
                  X_Attribute11                          VARCHAR2 DEFAULT NULL,
                  X_Attribute12                          VARCHAR2 DEFAULT NULL,
                  X_Attribute13                          VARCHAR2 DEFAULT NULL,
                  X_Attribute14                          VARCHAR2 DEFAULT NULL,
                  X_Attribute15                          VARCHAR2 DEFAULT NULL,
                  X_Capacity_Model_Id                    NUMBER DEFAULT NULL
) IS

   CURSOR C IS SELECT rowid
                FROM MRP_SCHEDULE_ITEMS
                WHERE inventory_item_id = X_Inventory_Item_Id
		  AND schedule_designator = X_Schedule_Designator
                  AND organization_id = X_Organization_Id;

BEGIN

  INSERT INTO MRP_SCHEDULE_ITEMS(
	  inventory_item_id,
          organization_id,
          schedule_designator,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
	  mps_explosion_level,
	  request_id,
	  program_application_id,
	  program_id,
	  program_update_date,
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
	  capacity_model_id
         ) VALUES (
          X_Inventory_Item_Id,
          X_Organization_Id,
          X_Schedule_Designator,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_MPS_Explosion_Level,
          X_Request_Id,
          X_Program_Application_Id,
          X_Program_Id,
          X_Program_Update_Date,
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
          X_Capacity_Model_Id
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

END Insert_Row;


PROCEDURE Lock_Row(
                  X_Rowid                                VARCHAR2,
                  X_Inventory_Item_Id                    NUMBER,
                  X_Organization_Id                      NUMBER,
                  X_Schedule_Designator                  VARCHAR2,
                  X_Last_Update_Date                     DATE,
                  X_Last_Updated_By                      NUMBER,
                  X_Creation_Date                        DATE,
                  X_Created_By                           NUMBER,
                  X_Last_Update_Login                    NUMBER DEFAULT NULL,
                  X_MPS_Explosion_Level                  NUMBER DEFAULT NULL,
                  X_Request_Id                  	 NUMBER DEFAULT NULL,
                  X_Program_Application_Id               NUMBER DEFAULT NULL,
                  X_Program_Id                           NUMBER DEFAULT NULL,
                  X_Program_Update_Date                  DATE DEFAULT NULL,
                  X_Attribute_Category                   VARCHAR2 DEFAULT NULL,
                  X_Attribute1                           VARCHAR2 DEFAULT NULL,
                  X_Attribute2                           VARCHAR2 DEFAULT NULL,
                  X_Attribute3                           VARCHAR2 DEFAULT NULL,
                  X_Attribute4                           VARCHAR2 DEFAULT NULL,
                  X_Attribute5                           VARCHAR2 DEFAULT NULL,
                  X_Attribute6                           VARCHAR2 DEFAULT NULL,
                  X_Attribute7                           VARCHAR2 DEFAULT NULL,
                  X_Attribute8                           VARCHAR2 DEFAULT NULL,
                  X_Attribute9                           VARCHAR2 DEFAULT NULL,
                  X_Attribute10                          VARCHAR2 DEFAULT NULL,
                  X_Attribute11                          VARCHAR2 DEFAULT NULL,
                  X_Attribute12                          VARCHAR2 DEFAULT NULL,
                  X_Attribute13                          VARCHAR2 DEFAULT NULL,
                  X_Attribute14                          VARCHAR2 DEFAULT NULL,
                  X_Attribute15                          VARCHAR2 DEFAULT NULL,
                  X_Capacity_Model_Id                    NUMBER DEFAULT NULL
) IS

  CURSOR C IS
      SELECT *
      FROM   MRP_SCHEDULE_ITEMS
      WHERE  rowid = X_Rowid
      FOR UPDATE of inventory_item_id NOWAIT;

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
           (Recinfo.inventory_item_id = X_Inventory_Item_Id)
      AND  (Recinfo.organization_id = X_Organization_Id)
      AND  (Recinfo.schedule_designator = X_Schedule_Designator)
      AND (   (Recinfo.mps_explosion_level = X_MPS_Explosion_Level)
           OR (    (Recinfo.mps_explosion_level IS NULL)
               AND (X_MPS_Explosion_Level IS NULL)))
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
      AND (   (Recinfo.capacity_model_id = X_Capacity_Model_Id)
           OR (    (Recinfo.capacity_model_id IS NULL)
               AND (X_Capacity_Model_Id IS NULL)))
      ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;


PROCEDURE Update_Row(
                  X_Rowid                                VARCHAR2,
                  X_Inventory_Item_Id                    NUMBER,
                  X_Organization_Id                      NUMBER,
                  X_Schedule_Designator                  VARCHAR2,
                  X_Last_Update_Date                     DATE,
                  X_Last_Updated_By                      NUMBER,
                  X_Creation_Date                        DATE,
                  X_Created_By                           NUMBER,
                  X_Last_Update_Login                    NUMBER DEFAULT NULL,
                  X_MPS_Explosion_Level                  NUMBER DEFAULT NULL,
                  X_Request_Id                  	 NUMBER DEFAULT NULL,
                  X_Program_Application_Id               NUMBER DEFAULT NULL,
                  X_Program_Id                           NUMBER DEFAULT NULL,
                  X_Program_Update_Date                  DATE DEFAULT NULL,
                  X_Attribute_Category                   VARCHAR2 DEFAULT NULL,
                  X_Attribute1                           VARCHAR2 DEFAULT NULL,
                  X_Attribute2                           VARCHAR2 DEFAULT NULL,
                  X_Attribute3                           VARCHAR2 DEFAULT NULL,
                  X_Attribute4                           VARCHAR2 DEFAULT NULL,
                  X_Attribute5                           VARCHAR2 DEFAULT NULL,
                  X_Attribute6                           VARCHAR2 DEFAULT NULL,
                  X_Attribute7                           VARCHAR2 DEFAULT NULL,
                  X_Attribute8                           VARCHAR2 DEFAULT NULL,
                  X_Attribute9                           VARCHAR2 DEFAULT NULL,
                  X_Attribute10                          VARCHAR2 DEFAULT NULL,
                  X_Attribute11                          VARCHAR2 DEFAULT NULL,
                  X_Attribute12                          VARCHAR2 DEFAULT NULL,
                  X_Attribute13                          VARCHAR2 DEFAULT NULL,
                  X_Attribute14                          VARCHAR2 DEFAULT NULL,
                  X_Attribute15                          VARCHAR2 DEFAULT NULL,
                  X_Capacity_Model_Id                    NUMBER DEFAULT NULL
) IS

BEGIN

  UPDATE MRP_SCHEDULE_ITEMS
  SET
    inventory_item_id			      =    X_Inventory_Item_Id,
    organization_id                           =    X_Organization_Id,
    schedule_designator                       =    X_Schedule_Designator,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    creation_date 			      =    X_Creation_Date,
    created_by                                =    X_Created_By,
    last_update_login                         =    X_Last_Update_Login,
    mps_explosion_level			      =    X_MPS_Explosion_Level,
    request_id				      =    X_Request_Id,
    program_application_id		      =    X_Program_Application_Id,
    program_id				      =    X_Program_Id,
    program_update_date			      =    X_Program_Update_Date,
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
    attribute15                               =    X_Attribute15,
    capacity_model_id			      =    X_Capacity_Model_Id
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

BEGIN
  DELETE FROM MRP_SCHEDULE_ITEMS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Delete_Row;


PROCEDURE Get_Item_Info(X_organization_id 		   	NUMBER,
                  	X_schedule_type           	        NUMBER,
                        X_inventory_item_id 		 	NUMBER,
                  	X_item_description              IN OUT  VARCHAR2,
                  	X_primary_uom_code              IN OUT  VARCHAR2,
                  	X_demand_time_fence_days        IN OUT  NUMBER,
                  	X_planning_time_fence_days      IN OUT  NUMBER,
                  	X_demand_time_fence_date        IN OUT  DATE,
                  	X_planning_time_fence_date      IN OUT  DATE,
                  	X_repetitive_planning_flag      IN OUT  VARCHAR2,
                  	X_bom_item_type                 IN OUT  NUMBER,
                  	X_bom_item_type_text            IN OUT  VARCHAR2,
                  	X_mrp_planning_code             IN OUT  NUMBER,
                  	X_mrp_planning_code_text        IN OUT  VARCHAR2
) IS

   CURSOR C IS
	 SELECT	msi.description,
		msi.primary_uom_code,
		NVL(msi.demand_time_fence_days,0),
 		NVL(msi.planning_time_fence_days,0),
 		DECODE(X_schedule_type,
		       1, DECODE(msi.demand_time_fence_days,
                  		 NULL, NULL,
		  		 cal2.calendar_date),
      		       2, NULL),
 		DECODE(X_schedule_type,
		       1, NULL,
		       2, DECODE(msi.planning_time_fence_days,
        	  		 NULL, NULL,
		  		 cal2.calendar_date)),
 		NVL(msi.repetitive_planning_flag,'N'),
 		msi.bom_item_type,
 		l1.meaning,
 		msi.mrp_planning_code,
 		l2.meaning
	   FROM MTL_SYSTEM_ITEMS 		msi,
     		BOM_CALENDAR_DATES 		cal2,
     		MTL_PARAMETERS 			param,
     		BOM_CALENDAR_DATES 		cal1,
     		MFG_LOOKUPS 			l1,
     		MFG_LOOKUPS 			l2
	  WHERE msi.organization_id = X_organization_id
  	    AND msi.inventory_item_id = X_inventory_item_id
  	    AND l1.lookup_type = 'BOM_ITEM_TYPE'
  	    AND l1.lookup_code = msi.bom_item_type
  	    AND l2.lookup_type(+) = 'MRP_PLANNING_CODE'
  	    AND l2.lookup_code(+) = msi.mrp_planning_code
  	    AND param.organization_id = msi.organization_id
  	    AND cal2.exception_set_id = param.calendar_exception_set_id
  	    AND cal2.calendar_code = param.calendar_code
  	    AND cal2.seq_num = cal1.prior_seq_num +
         	     	       DECODE(X_schedule_type,
		       	    	      1, NVL(msi.demand_time_fence_days, 0),
                            	      2, NVL(msi.planning_time_fence_days,0))
  	    AND cal1.exception_set_id = param.calendar_exception_set_id
  	    AND cal1.calendar_code = param.calendar_code
  	    AND cal1.calendar_date = TRUNC(sysdate);

BEGIN

  OPEN C;

  FETCH C INTO X_item_description,
               X_primary_uom_code,
               X_demand_time_fence_days,
               X_planning_time_fence_days,
               X_demand_time_fence_date,
               X_planning_time_fence_date,
               X_repetitive_planning_flag,
               X_bom_item_type,
               X_bom_item_type_text,
               X_mrp_planning_code,
               X_mrp_planning_code_text;

  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;

  CLOSE C;

END Get_Item_Info;


PROCEDURE Delete_Details(X_organization_id NUMBER,
                         X_schedule_designator VARCHAR2,
                         X_inventory_item_id NUMBER
) IS

BEGIN
   DELETE
     FROM mrp_schedule_dates
    WHERE inventory_item_id = X_inventory_item_id
      AND schedule_designator = X_schedule_designator
      AND organization_id = X_organization_id;

   IF (SQL%NOTFOUND) THEN
      null;
   END IF;

END Delete_Details;


FUNCTION Check_Unique(X_Rowid VARCHAR2,
                      X_organization_id NUMBER,
                      X_schedule_designator VARCHAR2,
                      X_inventory_item_id NUMBER)
    	RETURN BOOLEAN IS

       dummy NUMBER;

BEGIN

  SELECT 1
    INTO dummy
    FROM dual
   WHERE NOT EXISTS (SELECT 1
                      FROM mrp_schedule_items
                     WHERE inventory_item_id = X_inventory_item_id
		       AND schedule_designator = X_schedule_designator
                       AND organization_id = X_organization_id
                       AND (   (X_rowid IS NULL)
                            OR (rowid <> X_rowid) )
                     );

  RETURN(TRUE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN(FALSE);

END Check_Unique;


END MRP_SCHEDULE_ITEMS_PKG;

/
