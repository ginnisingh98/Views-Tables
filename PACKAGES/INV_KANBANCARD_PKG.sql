--------------------------------------------------------
--  DDL for Package INV_KANBANCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_KANBANCARD_PKG" AUTHID CURRENT_USER as
/* $Header: INVKCRDS.pls 115.6 2003/08/20 18:09:55 cjandhya ship $ */


FUNCTION  Check_Unique(p_Kanban_Card_Id   IN OUT  NOCOPY NUMBER,
                       p_Organization_Id          NUMBER,
                       p_Kanban_Card_Number       VARCHAR2)
RETURN BOOLEAN;

FUNCTION Supply_Status_Change_OK
(   p_from_supply_status number,
    p_to_supply_status   number,
    p_card_status        number)
RETURN BOOLEAN;

FUNCTION Query_Row
(   p_kanban_card_id              IN  NUMBER )
RETURN INV_Kanban_PVT.Kanban_Card_Rec_Type;

Procedure commit_row;

Procedure rollback_row;

PROCEDURE Insert_Row(  x_return_status          OUT 	NOCOPY VARCHAR2,
                       p_Kanban_Card_Id         IN OUT NOCOPY NUMBER,
                       p_Kanban_Card_Number     IN OUT NOCOPY VARCHAR2,
                       p_Pull_Sequence_Id               NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Supply_Status        	IN OUT	NOCOPY NUMBER,
                       p_Card_Status        	IN OUT	NOCOPY NUMBER,
                       p_Kanban_Card_Type      		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Last_Updated_By                NUMBER,
                       p_Creation_Date                  DATE,
                       p_Created_By                     NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Last_Print_Date                DATE,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory	        VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_wip_line_id                    NUMBER,
                       p_Current_Replnsh_Cycle_Id IN OUT NOCOPY NUMBER,
                       p_Document_Type                  NUMBER,
                       p_Document_Header_Id             NUMBER,
                       p_Document_Detail_Id             NUMBER,
                       p_Error_code           		NUMBER,
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
                       p_release_kanban_flag            NUMBER :=1);

  PROCEDURE Lock_Row  (p_Kanban_Card_Id			NUMBER,
                       p_Kanban_Card_Number             VARCHAR2,
                       p_Pull_Sequence_Id               NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Supply_Status         		NUMBER,
                       p_Card_Status         		NUMBER,
                       p_Kanban_Card_Type      		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Last_Print_date                DATE,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory	        VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_wip_line_id                    NUMBER,
                       p_Current_Replnsh_Cycle_Id	NUMBER,
                       p_Error_code           		NUMBER,
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
                       p_Attribute15                    VARCHAR2);

  PROCEDURE Update_Row(x_return_status        Out       NOCOPY VARCHAR2,
		       p_Kanban_Card_Id                 NUMBER,
                       p_Kanban_Card_Number             VARCHAR2,
                       p_Pull_Sequence_Id               NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Supply_Status        In OUT 	NOCOPY NUMBER,
                       p_Card_Status          In Out 	NOCOPY NUMBER,
                       p_Kanban_Card_Type      		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Last_Updated_By                NUMBER,
                       p_Creation_Date                  DATE,
                       p_Created_By                     NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Last_Print_Date                Date,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory	        VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_wip_line_id                    NUMBER,
                       p_Current_Replnsh_Cycle_Id In Out NOCOPY NUMBER,
                       p_Document_Type                  NUMBER,
                       p_Document_Header_Id             NUMBER,
                       p_Document_Detail_Id             NUMBER,
                       p_Error_code           		NUMBER,
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
                       p_lot_item_id                    NUMBER    DEFAULT NULL,
                       p_lot_number                     VARCHAR2  DEFAULT NULL,
                       p_lot_item_revision              VARCHAR2  DEFAULT NULL,
                       p_lot_subinventory_code          VARCHAR2  DEFAULT NULL,
                       p_lot_location_id                NUMBER    DEFAULT NULL,
                       p_lot_quantity                   NUMBER    DEFAULT NULL,
                       p_replenish_quantity             NUMBER    DEFAULT NULL,
                       p_need_by_date                   DATE      DEFAULT NULL,
                       p_source_wip_entity_id           NUMBER    DEFAULT NULL);

  PROCEDURE  Update_Row(p_Kanban_Card_Rec
			INV_Kanban_PVT.Kanban_Card_rec_Type);

  PROCEDURE  Update_Card_Status(p_Kanban_Card_Rec
			      IN OUT NOCOPY INV_Kanban_PVT.kanban_card_rec_type,
			      p_card_status IN NUMBER);

PROCEDURE Delete_Row(x_return_status Out NOCOPY Varchar2,
                     p_Kanban_Card_Id    Number);

PROCEDURE Delete_Cards_For_Pull_Seq(p_Pull_Sequence_Id Number);

PROCEDURE Insert_Activity_For_Card
     (p_Kanban_Card_Rec INV_Kanban_PVT.Kanban_Card_Rec_Type);

PROCEDURE Delete_Activity_For_Card(p_Kanban_Card_Id NUMBER);

PROCEDURE Delete_Activity_For_Pull_Seq(p_Pull_Sequence_Id NUMBER);

END INV_KanbanCard_PKG;

 

/
