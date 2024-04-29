--------------------------------------------------------
--  DDL for Package MRP_SCHEDULE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SCHEDULE_ITEMS_PKG" AUTHID CURRENT_USER AS
/* $Header: MRSITEMS.pls 115.0 99/07/16 12:44:56 porting ship $ */

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
                  X_Capacity_Model_Id                    NUMBER DEFAULT NULL);

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
                  X_Capacity_Model_Id                    NUMBER DEFAULT NULL);

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
                  X_Capacity_Model_Id                    NUMBER DEFAULT NULL);

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE Get_Item_Info(X_organization_id 		   	NUMBER,
                  	X_schedule_type           		NUMBER,
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
                  	X_mrp_planning_code_text        IN OUT  VARCHAR2);

PROCEDURE Delete_Details(X_organization_id NUMBER,
                         X_schedule_designator VARCHAR2,
                         X_inventory_item_id NUMBER);

FUNCTION  Check_Unique(X_Rowid VARCHAR2,
                       X_organization_id NUMBER,
                       X_schedule_designator VARCHAR2,
                       X_inventory_item_id NUMBER) RETURN BOOLEAN;


END MRP_SCHEDULE_ITEMS_PKG;

 

/
