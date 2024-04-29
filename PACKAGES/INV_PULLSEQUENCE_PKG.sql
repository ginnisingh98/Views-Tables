--------------------------------------------------------
--  DDL for Package INV_PULLSEQUENCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PULLSEQUENCE_PKG" AUTHID CURRENT_USER as
/* $Header: INVKPSQS.pls 120.0 2005/05/24 18:01:53 appldev noship $ */

FUNCTION  Check_Unique( p_Pull_sequence_Id IN OUT NOCOPY  NUMBER,
                        p_Organization_Id          NUMBER,
                        p_Kanban_Plan_Id           NUMBER,
                        p_Inventory_Item_Id        NUMBER,
                        p_Subinventory_Name        VARCHAR2,
                        p_Locator_Id               NUMBER)
RETURN BOOLEAN ;

Procedure commit_row;

Procedure rollback_row;

FUNCTION Query_Row
(   p_pull_sequence_id              IN  NUMBER
) RETURN INV_Kanban_PVT.Pull_Sequence_Rec_Type;

FUNCTION Convert_Miss_To_Null
(   p_pull_sequence_rec             IN  INV_Kanban_PVT.Pull_Sequence_Rec_Type
) RETURN INV_Kanban_PVT.Pull_Sequence_Rec_Type;

FUNCTION Complete_Record
(   p_pull_sequence_rec             IN  INV_Kanban_PVT.Pull_Sequence_Rec_Type
,   p_old_pull_sequence_rec         IN  INV_Kanban_PVT.Pull_Sequence_Rec_Type
) RETURN INV_Kanban_PVT.Pull_Sequence_Rec_Type;

PROCEDURE Insert_Row(p_pull_sequence_rec INV_Kanban_PVT.Pull_Sequence_Rec_Type);

PROCEDURE Insert_Row(  x_return_status        	 OUT NOCOPY VARCHAR2,
                       p_pull_sequence_id        IN OUT NOCOPY NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Kanban_Plan_id        		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Last_Updated_By                NUMBER,
                       p_Creation_Date                  DATE,
                       p_Created_By                     NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory	        VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_Wip_Line_id		        NUMBER,
                       p_Release_kanban_flag            NUMBER,
                       p_Calculate_kanban_flag          NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Number_of_cards       		NUMBER,
                       p_Minimum_order_quantity		NUMBER,
                       p_Aggregation_type		NUMBER,
                       p_Allocation_Percent		NUMBER,
                       p_Replenishment_lead_time        NUMBER,
                       p_Fixed_Lot_multiplier           NUMBER,
                       p_Safety_Stock_Days              NUMBER,
                       p_Updated_Flag          		NUMBER,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
                       p_Request_Id        		NUMBER,
                       p_Program_application_Id		NUMBER,
                       p_Program_Id        		NUMBER,
                       p_Program_Update_date        	DATE,
		       p_point_of_use_x			NUMBER DEFAULT NULL,
	               p_point_of_use_y			NUMBER DEFAULT NULL,
		       p_point_of_supply_x		NUMBER DEFAULT NULL,
	               p_point_of_supply_y		NUMBER DEFAULT NULL,
		       p_planning_update_status		NUMBER DEFAULT NULL,
		       p_auto_request                   VARCHAR2 DEFAULT NULL,
		       p_Auto_Allocate_Flag             NUMBER DEFAULT NULL); --Added P_Auto_Allocate_Flag for 3905884

PROCEDURE Lock_Row  (p_Pull_sequence_Id               NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Kanban_Plan_id       		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory            VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_Wip_Line_id		        NUMBER,
                       p_Release_kanban_flag            NUMBER,
                       p_Calculate_kanban_flag          NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Number_of_cards       		NUMBER,
                       p_Minimum_order_quantity		NUMBER,
                       p_Aggregation_type		NUMBER,
                       p_Allocation_Percent		NUMBER,
                       p_Replenishment_lead_time        NUMBER,
                       p_Fixed_Lot_multiplier           NUMBER,
                       p_Safety_Stock_Days              NUMBER,
                       p_Updated_Flag          		NUMBER,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
       		       p_point_of_use_x			NUMBER DEFAULT NULL,
	               p_point_of_use_y			NUMBER DEFAULT NULL,
		       p_point_of_supply_x		NUMBER DEFAULT NULL,
	               p_point_of_supply_y		NUMBER DEFAULT NULL,
		       p_planning_update_status		NUMBER DEFAULT NULL,
		       p_auto_request                   VARCHAR2 DEFAULT NULL,
      		       p_Auto_Allocate_Flag             NUMBER DEFAULT NULL); --Added P_Auto_Allocate_Flag for 3905884.


  PROCEDURE Update_Row(p_pull_sequence_rec INV_Kanban_PVT.Pull_sequence_Rec_Type);

PROCEDURE Update_Row(  x_return_status        	 OUT NOCOPY VARCHAR2,
                       p_Pull_sequence_Id               NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Kanban_Plan_id        		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Last_Updated_By                NUMBER,
                       p_Creation_Date                  DATE,
                       p_Created_By                     NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory            VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_Wip_Line_id		        NUMBER,
                       p_Release_kanban_flag            NUMBER,
                       p_Calculate_kanban_flag          NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Number_of_cards       		NUMBER,
                       p_Minimum_order_quantity		NUMBER,
                       p_Aggregation_type		NUMBER,
                       p_Allocation_Percent		NUMBER,
                       p_Replenishment_lead_time        NUMBER,
                       p_Fixed_Lot_multiplier           NUMBER,
                       p_Safety_Stock_Days              NUMBER,
                       p_Updated_Flag          		NUMBER,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
       		       p_point_of_use_x			NUMBER DEFAULT NULL,
	               p_point_of_use_y			NUMBER DEFAULT NULL,
		       p_point_of_supply_x		NUMBER DEFAULT NULL,
	               p_point_of_supply_y		NUMBER DEFAULT NULL,
		       p_planning_update_status		NUMBER DEFAULT NULL,
		       p_auto_request                   VARCHAR2 DEFAULT NULL,
       		       p_Auto_Allocate_Flag             NUMBER DEFAULT NULL); --Added P_Auto_Allocate_Flag for 3905884



  PROCEDURE Delete_Row(x_return_status    OUT NOCOPY VARCHAR2,
                       p_Pull_sequence_Id     NUMBER);


END INV_PullSequence_PKG;

 

/
