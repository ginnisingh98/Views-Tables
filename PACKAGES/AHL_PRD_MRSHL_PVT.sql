--------------------------------------------------------
--  DDL for Package AHL_PRD_MRSHL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_MRSHL_PVT" AUTHID CURRENT_USER AS
 /* $Header: AHLVPMLS.pls 120.2.12010000.1 2008/07/28 08:33:36 appldev ship $ */

 TYPE Mrshl_search_rec_type  IS RECORD
 (
    Visit_id	        NUMBER,
    item_instance_id	NUMBER,
    Workorder_id     	NUMBER,
    Workorder_name	    VARCHAR2(80),
    Item_name	        VARCHAR2(240),
    Item_Desc	        VARCHAR2(240),
    Search_mode	        VARCHAR2(30)
  );

  TYPE Unavailable_items_rec_type   IS RECORD
   (
    Scheduled_material_id NUMBER,
    Inventory_item_id	NUMBER,
    Item_name	        VARCHAR2(240),
    Item_Desc	        VARCHAR2(240),
    Workorder_id	    NUMBER,
    Workorder_name	    VARCHAR2(80),
    Wip_Entity_Id       NUMBER,
    Organization_id     NUMBER,
    Visit_id            NUMBER,
    wo_status_code      VARCHAR2(30),
    wo_status           VARCHAR2(80),
    Wo_operation_id	    NUMBER,
    Op_seq	            NUMBER,
    Quantity	        NUMBER,
    UOM	                VARCHAR2(3),
    UOM_DESC	        VARCHAR2(25),
    Required_date	    DATE,
    Required_quantity	NUMBER,
    Issued_Quantity	    NUMBER,
    Scheduled_date	    DATE,
    Scheduled_quantity	NUMBER,
    Exception_date	    DATE,
    Reserved_quantity	NUMBER,
    Onhand_quantity     NUMBER,
    Qty_per_assembly	NUMBER,
    Subinventory	    VARCHAR2(10),
    Locator_id	        NUMBER,
    Locator_segments	VARCHAR2(240),
    Serial_Number	    VARCHAR2(30),
    Lot	                VARCHAR2(30),
    Revision	        VARCHAR2(3),
    Is_serialized	    VARCHAR2(1),
    Is_Lot_Controlled   VARCHAR2(1),
    Is_Revision_Controlled VARCHAR2(1),
    diposition_id       NUMBER,
    diposition_name     VARCHAR2(80)

  );

TYPE Unavailable_items_tbl_type IS TABLE OF Unavailable_items_rec_type   INDEX BY BINARY_INTEGER;

TYPE Available_items_rec_type   IS RECORD
   (
    Scheduled_material_id NUMBER,
    Inventory_item_id	NUMBER,
    Item_name	        VARCHAR2(240),
    Item_Desc	        VARCHAR2(240),
    Workorder_id	    NUMBER,
    Workorder_name	    VARCHAR2(80),
    Wip_Entity_Id       NUMBER,
    Organization_id     NUMBER,
    Visit_id            NUMBER,
    wo_status_code      VARCHAR2(30),
    wo_status           VARCHAR2(80),
    Wo_operation_id	    NUMBER,
    Op_seq	            NUMBER,
    Quantity	        NUMBER,
    UOM	                VARCHAR2(3),
    UOM_DESC	        VARCHAR2(25),
    Required_date	    DATE,
    Required_quantity	NUMBER,
    Scheduled_date	    DATE,
    Scheduled_quantity	NUMBER,
    Issued_Quantity	    NUMBER,
    Exception_date	    DATE,
    Reserved_quantity	NUMBER,
    Onhand_quantity     NUMBER,
    Qty_per_assembly	NUMBER,
    Subinventory	    VARCHAR2(10),
    Locator_id	        NUMBER,
    Locator_segments	VARCHAR2(240),
    Serial_Number	    VARCHAR2(30),
    Lot	                VARCHAR2(30),
    Revision	        VARCHAR2(3),
    Item_source_wo_id	NUMBER,
    Item_source_wo_name	VARCHAR2(80),
    Item_source_wop_id	NUMBER,
    Item_source_wop_seq	NUMBER,
    Is_serialized	    VARCHAR2(1),
    Is_Lot_Controlled   VARCHAR2(1),
    Is_Revision_Controlled VARCHAR2(1),
    diposition_id       NUMBER,
    diposition_name     VARCHAR2(80)
  );

TYPE Available_items_tbl_type IS TABLE OF Available_items_rec_type   INDEX BY BINARY_INTEGER;


TYPE mrshl_details_rec_type   IS RECORD
  (
    Unit_Header_id        NUMBER,
    Unit_Name             VARCHAR2(80),
    relationship_id       NUMBER,
    parent_rel_id         NUMBER,
    root_instance_id      NUMBER,
    POSITION              VARCHAR2(240),
    IS_POSITION_SER_CTRLD VARCHAR2(1),
    CURR_ITEM_ID          NUMBER,
    CURR_INSTANCE_ID      NUMBER,
    parent_instance_id    NUMBER,
    ALLOWED_QTY           NUMBER,
    CURR_ITEM_NUMBER      VARCHAR2(240),
    CURR_SERIAL_NUMBER    VARCHAR2(30),
    CURR_INSTLD_QTY       NUMBER,
    REQ_QTY               NUMBER,
    ISSUED_QTY            NUMBER,
    AVAILABLE_QTY         NUMBER,
    NOT_AVAILABLE_QTY     NUMBER,
    COMPL_WO_COUNT        NUMBER,
    TOTAL_WO_COUNT        NUMBER,
    CUMM_REQ_QTY          NUMBER,
    CUMM_ISSUED_QTY       NUMBER,
    CUMM_AVAILABLE_QTY    NUMBER,
    CUMM_NOT_AVAILABLE_QTY  NUMBER,
    CUMM_COMPL_WO_COUNT   NUMBER,
    CUMM_TOTAL_WO_COUNT   NUMBER
  );

TYPE mrshl_details_tbl_type IS TABLE OF mrshl_details_rec_type   INDEX BY BINARY_INTEGER;



 PROCEDURE Get_unavailable_items
 		(
   		p_api_version        IN    NUMBER     := 1.0,
   		p_init_msg_list      IN    VARCHAR2   := FND_API.G_FALSE,
   		p_commit             IN    VARCHAR2   := FND_API.G_FALSE,
   		p_validation_level   IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   		p_default            IN    VARCHAR2   := FND_API.G_FALSE,
   		p_module_type        IN    VARCHAR2   := NULL,
 		p_Mrshl_search_rec   IN	   Mrshl_search_rec_type,
   		x_Unavailable_items_tbl    OUT NOCOPY Unavailable_items_Tbl_Type,
   		x_return_status            OUT NOCOPY           VARCHAR2,
   		x_msg_count                OUT NOCOPY           NUMBER,
   		x_msg_data                 OUT NOCOPY           VARCHAR2
 );

 PROCEDURE Get_available_items
 		(
   		p_api_version        IN    NUMBER     := 1.0,
   		p_init_msg_list      IN    VARCHAR2   := FND_API.G_FALSE,
   		p_commit             IN    VARCHAR2   := FND_API.G_FALSE,
   		p_validation_level   IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   		p_default            IN    VARCHAR2   := FND_API.G_FALSE,
   		p_module_type        IN    VARCHAR2   := NULL,
 		p_Mrshl_search_rec  IN	   Mrshl_search_rec_type,
   		x_available_items_tbl      OUT NOCOPY Available_items_Tbl_Type,
   		x_return_status            OUT NOCOPY           VARCHAR2,
   		x_msg_count                OUT NOCOPY           NUMBER,
   		x_msg_data                 OUT NOCOPY           VARCHAR2
 );

 FUNCTION Get_workorder_count
 (
   		p_visit_id                 IN NUMBER,
   		p_item_instance_id         IN NUMBER,
   		p_mode                     IN VARCHAR2
 ) RETURN NUMBER;

 FUNCTION Get_item_count
 (
   		p_visit_id                 IN NUMBER,
   		p_item_instance_id         IN NUMBER :=NULL,
   		p_mode                     IN VARCHAR2
 ) RETURN NUMBER;

 FUNCTION Get_visit_completion_perc
 (
   		p_visit_id                 IN NUMBER
 ) RETURN NUMBER;

 PROCEDURE Get_mrshl_details
 (
   		p_api_version        IN    NUMBER     := 1.0,
   		p_init_msg_list      IN    VARCHAR2   := FND_API.G_FALSE,
   		p_commit             IN    VARCHAR2   := FND_API.G_FALSE,
   		p_validation_level   IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   		p_default            IN    VARCHAR2   := FND_API.G_FALSE,
   		p_module_type        IN    VARCHAR2   := NULL,
 		p_unit_header_id     IN	   NUMBER,
 		p_item_instance_id   IN	   NUMBER,
        p_visit_id           IN	   NUMBER,
   		x_mrshl_details_tbl     OUT NOCOPY mrshl_details_tbl_type,
   		x_return_status            OUT NOCOPY           VARCHAR2,
   		x_msg_count                OUT NOCOPY           NUMBER,
   		x_msg_data                 OUT NOCOPY           VARCHAR2
 );

FUNCTION GET_ONHAND_AVAILABLE(
P_ORG_ID IN NUMBER,
P_ITEM_ID IN NUMBER,
p_SUBINVENTORY VARCHAR2,
p_locator_id NUMBER) RETURN NUMBER;

FUNCTION GET_ONHAND_NOTAVAILABLE(
P_ORG_ID IN NUMBER,
P_ITEM_ID IN NUMBER,
p_SUBINVENTORY VARCHAR2,
p_locator_id NUMBER) RETURN NUMBER;

END AHL_PRD_MRSHL_PVT;

/
