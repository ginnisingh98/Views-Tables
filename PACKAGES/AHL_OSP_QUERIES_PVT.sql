--------------------------------------------------------
--  DDL for Package AHL_OSP_QUERIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_QUERIES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVOSQS.pls 120.1 2006/08/23 11:27:26 mpothuku noship $ */

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE Search_Order_Rec_Type IS RECORD (
    Order_Number         VARCHAR2(40)  ,
    Description	         VARCHAR2(2000),
    Order_Type_Code	     VARCHAR2(30)  ,
    Order_Status_Code	 VARCHAR2(30)  ,
    Job_Number	         VARCHAR2(80)  ,
    Project_Name	     VARCHAR2(30)  ,
    Task_Name	         VARCHAR2(20)  ,
    Part_Number	         VARCHAR2(40)  ,
    Serial_Number	     VARCHAR2(30)  ,
    Has_New_PO_Line	     VARCHAR2(1)   ,
    vendor               VARCHAR2(240)  ,
    department_id        NUMBER        ,
    department           VARCHAR2(10)
);

Type Search_WO_Rec_Type IS RECORD (
    job_number	         VARCHAR2(80)   ,
    description	         VARCHAR2(2000) ,
    project_name	     VARCHAR2(30)   ,
    task_name	         VARCHAR2(20)   ,
    Part_number	         VARCHAR2(40)   ,
    Instance_number	     VARCHAR2(30)   ,
    Serial_number	     VARCHAR2(30)   ,
    Svc_item_number	     VARCHAR2(40)   ,
    department_id        NUMBER         ,
    Department           VARCHAR2(10)

);


Type Results_Order_Rec_Type IS RECORD (
    OSP_ID	              NUMBER           ,
    Object_version_number NUMBER           ,
    Order_Number	      NUMBER           ,
    Order_Date	          DATE             ,
    Description	          VARCHAR2(2000)   ,
    order_type_code       VARCHAR2(30)     ,
    Order_Type	          VARCHAR2(80)     ,
    status_code           VARCHAR2(30)     ,
    Order_Status	      VARCHAR2(80)     ,
    po_header_id          NUMBER           ,
    PO_Number	          VARCHAR2(20)     ,
    oe_header_id          NUMBER           ,
    Shipment_Number	      NUMBER           ,
    po_interface_header_id  NUMBER
 );

Type Results_WO_Rec_Type IS RECORD (
    Workorder_ID	   NUMBER         ,
    job_number	       VARCHAR2(80)   ,
    Part_number	       VARCHAR2(40)   ,
    Instance_number	   VARCHAR2(30)   ,
    Serial_number	   VARCHAR2(30)   ,
    Svc_item_number	   VARCHAR2(40)   ,
    Svc_Description	   VARCHAR2(240)  ,
    Suggested_Vendor   VARCHAR2(240)   ,
    Department         VARCHAR2(10)

);

Type order_header_rec_Type IS RECORD(
        OSP_ID	               NUMBER,
        OBJECT_VERSION_NUMBER  NUMBER,
        ORDER_NUMBER	       NUMBER,
        ORDER_DESCRIPTION	   VARCHAR2(1000),
        ORDER_TYPE_CODE        VARCHAR(30),
        ORDER_TYPE	           VARCHAR2(80),
        ORDER_STATUS_CODE      VARCHAR2(30),
        ORDER_STATUS	       VARCHAR2(80),
        ORDER_DATE	           DATE,
        VENDOR_ID              NUMBER,
        VENDOR_NAME	           VARCHAR2(240),
        VENDOR_SITE_ID         NUMBER,
        VENDOR_LOCATION	       VARCHAR2(15),
        CUSTOMER_ID            NUMBER,
        CUSTOMER               VARCHAR2(360),
        SINGLE_INSTANCE_FLAG   VARCHAR2(20),
        SINGLE_INSTANCE_MEANING   VARCHAR2(80),
        PO_AGENT_ID            NUMBER,
        BUYER_NAME	           VARCHAR2(240),
        PO_HEADER_ID           NUMBER,
        PO_NUMBER              VARCHAR2(80),
        PO_SYNCH_FLAG          VARCHAR2(20),
        OE_HEADER_ID           NUMBER,
        SHIPMENT_NUMBER        NUMBER,
        CONTRACT_ID            NUMBER,
        CONTRACT_NUMBER	       VARCHAR2(120)
      );

Type order_line_rec_type IS RECORD (
    OSP_ORDER_LINE_ID	      NUMBER,
	OBJECT_VERSION_NUMBER 	  NUMBER,
    OSP_ORDER_ID              NUMBER,
    OSP_LINE_NUMBER           NUMBER,
	STATUS_CODE			      VARCHAR2(30),
    STATUS                    VARCHAR2(80),
    PO_LINE_TYPE_ID    		  NUMBER,
    PO_LINE_TYPE    		  VARCHAR2(25),
    SERVICE_ITEM_ID    		  NUMBER,
    SERVICE_ITEM_NUMBER    	  VARCHAR2(40),
	SERVICE_ITEM_DESCRIPTION  VARCHAR2(2000),
	SERVICE_ITEM_UOM_CODE  	  VARCHAR2(3),
    NEED_BY_DATE           	  DATE,
    SHIP_BY_DATE              DATE,
    PO_LINE_ID             	  NUMBER,
    OE_SHIP_LINE_ID           NUMBER,
    OE_RETURN_LINE_ID         NUMBER,
    WORKORDER_ID              NUMBER,
    JOB_NUMBER                VARCHAR2(80),
	OPERATION_ID              NUMBER,
	ATTRIBUTE_CATEGORY		  VARCHAR2(30),
    WO_PART_NUMBER               VARCHAR2(40),
    QUANTITY                  NUMBER,
    ITEM_INSTANCE_ID          NUMBER,
    ITEM_INSTANCE_NUMBER      VARCHAR2(30),
    EXCHANGE_INSTANCE_NUMBER  VARCHAR2(30),
    EXCHANGE_INSTANCE_ID      NUMBER,
    PROJECT_ID                NUMBER,
    PROJECT_NAME              VARCHAR2(30),
    PRJ_TASK_ID               NUMBER,
    PRJ_TASK_NAME             VARCHAR2(20)



   );

Type Work_Id_Rec_Type IS RECORD (
  work_order_id    NUMBER
);
----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Results_Order_Tbl_Type IS TABLE OF Results_Order_Rec_Type INDEX BY BINARY_INTEGER;

Type Results_WO_Tbl_Type IS TABLE OF Results_WO_Rec_Type INDEX BY BINARY_INTEGER;

Type order_line_Tbl_type IS TABLE OF order_line_rec_type INDEX BY BINARY_INTEGER;

Type work_id_tbl_type IS TABLE OF Work_Id_Rec_Type INDEX BY BINARY_INTEGER;


----------------------------------------
-- Declare Procedures for Search OSP --
----------------------------------------
-- This procedure Search for osp order based on the search criteria specify in parameter P_search_order_rec
-- The search result will be populated into x_results_order_tbl.
-- Start of Comments --
--  Procedure name    : Search_OSP
--  Type        : Public
--  Function    : Search OSP Order
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN    VARCHAR2       Default  Null
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is null. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values;based
--      on which the Id's are populated.
--
--  Search_OSP Parameters :
--  p_start_row           IN    NUMBER  specify the start row to populate into search result table
--  p_rows_per_page       IN    NUMBER  specify the number of row to be populated in the search result table
--  P_search_order_rec    IN    Search_Order_rec_type, specify the search criteria
--  x_results_order_tbl   OUT   Results_Order_Tbl_Type, the search Result table
--  x_results_count       OUT   NUMBER,  row count from the query, this number can be more than the number of row in search result table
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

  PROCEDURE Search_OSP_Orders
      (
        p_api_version                   IN            NUMBER,
        p_init_msg_list                 IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit                        IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level              IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_default                       IN            VARCHAR2  := FND_API.G_TRUE,
        p_module_type                   IN            VARCHAR2 ,
        p_start_row                     IN            NUMBER,
        p_rows_per_page                 IN            NUMBER,
        P_search_order_rec              IN            AHL_OSP_QUERIES_PVT.Search_Order_rec_type,
        x_results_order_tbl             OUT NOCOPY           AHL_OSP_QUERIES_PVT.Results_Order_Tbl_Type,
        x_results_count                 OUT NOCOPY           NUMBER,
        x_return_status                 OUT NOCOPY           VARCHAR2,
        x_msg_count                     OUT NOCOPY           NUMBER,
        x_msg_data                      OUT NOCOPY           VARCHAR2
      );



----------------------------------------
-- Declare Procedures for Search Work Orders --
----------------------------------------
-- This procedure Search for Work orders based on the search criteria specify in parameter P_search_WO_rec
-- The search result will be populated into x_results_order_tbl.
-- Start of Comments --
--  Procedure name    : Search_OSP
--  Type        : Public
--  Function    : Search OSP Order
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN    VARCHAR2       Default  Null
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is null. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values;based
--      on which the Id's are populated.
--
--  Search_OSP Parameters :
--  p_start_row           IN    NUMBER  specify the start row to populate into search result table
--  p_rows_per_page       IN    NUMBER  specify the number of row to be populated in the search result table
--  P_search_order_rec    IN    Search_Order_rec_type, specify the search criteria
--  x_results_order_tbl   OUT   Results_Order_Tbl_Type, the search Result table
--  x_results_count       OUT   NUMBER,  row count from the query, this number can be more than the number of row in search result table
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
PROCEDURE Search_WO
(
        p_api_version	        IN	       NUMBER,
        p_init_msg_list	        IN	       VARCHAR2 := FND_API.G_FALSE,
        p_commit	            IN	       VARCHAR2 := FND_API.G_FALSE,
        p_validation_level	    IN	       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        p_module_type           IN         VARCHAR2 ,
        p_start_row             IN         NUMBER,
        p_rows_per_page         IN         NUMBER,
        p_search_WO_rec	        IN	       AHL_OSP_QUERIES_PVT.Search_WO_Rec_Type,
        x_result_WO_tbl	        OUT NOCOPY	       AHL_OSP_QUERIES_PVT.Results_WO_Tbl_Type,
        x_results_count         OUT NOCOPY        NUMBER,
        x_return_status	        OUT NOCOPY 	   VARCHAR2,
        x_msg_count	            OUT NOCOPY 	   NUMBER,
        x_msg_data	            OUT NOCOPY 	   VARCHAR2

);

----------------------------------------
-- Declare Procedures for GET_HEADER_AND_LINES --
----------------------------------------
-- This procedure Search for OSP Order Header and order lines based on the input parameter P_osp_id.
-- When the input parameter p_osp_id is null it will use input parameter P_work_order_ids to search for workorders
-- and populate into order line table.

-- Start of Comments --
--  Procedure name    : Search_OSP
--  Type        : Public
--  Function    : Search OSP Order
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN    VARCHAR2       Default  Null
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is null. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values;based
--      on which the Id's are populated.
--
--  Search_OSP Parameters :
--  P_osp_id              IN    NUMBER,                id that the search will be based on.
--  P_work_order_ids      IN    work_id_tbl_type,      List of workorder id that search will be based on if p_osp_id is null
--  x_order_header_rec    IN    order_header_rec_Type, store order header
--  x_order_lines_tbl     OUT   order_line_tbl_Type,   Store order order lines rows
--  x_msg_count           OUT   NUMBER,
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
PROCEDURE GET_HEADER_AND_LINES
(
        p_api_version	          IN	NUMBER,
        p_init_msg_list	          IN	VARCHAR2,
        p_commit	              IN	VARCHAR2,
        p_validation_level	      IN	NUMBER,
        p_module_type             IN    VARCHAR2,
        P_osp_id	              IN	NUMBER,
        P_work_order_ids          IN    AHL_OSP_QUERIES_PVT.work_id_tbl_type,
        x_order_header_rec	      OUT NOCOPY	AHL_OSP_QUERIES_PVT.order_header_rec_Type,
        x_order_lines_tbl	      OUT NOCOPY	AHL_OSP_QUERIES_PVT.order_line_tbl_Type,
        x_return_status	          OUT NOCOPY 	VARCHAR2,
        x_msg_count	              OUT NOCOPY 	NUMBER,
        x_msg_data	              OUT NOCOPY 	VARCHAR2

);



----------------------------------------
-- Declare Procedures for GET_HEADER_AND_LINES --
----------------------------------------
-- This procedure Search for OSP Order lines based on the input parameter P_osp_id.
-- When the input parameter p_osp_id is null it will use input parameter P_work_order_ids to search for workorders
-- and populate into order line table.

-- Start of Comments --
--  Procedure name    : Search_OSP
--  Type        : Public
--  Function    : Search OSP Order
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN    VARCHAR2       Default  Null
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--      This parameter indicates the front-end form interface. The default value is null. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values;based
--      on which the Id's are populated.
--
--  Search_OSP Parameters :
--  P_osp_id              IN    NUMBER,                id that the search will be based on.
--  P_work_order_ids      IN    work_id_tbl_type,      List of workorder id that search will be based on if p_osp_id is null
--  x_order_lines_tbl     OUT   order_line_tbl_Type,   Store order order lines rows
--  x_msg_count           OUT   NUMBER,
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
PROCEDURE GET_ORDER_LINES
(
        p_api_version	          IN	NUMBER,
        p_init_msg_list	          IN	VARCHAR2,
        p_commit	              IN	VARCHAR2,
        p_validation_level	      IN	NUMBER,
        p_module_type             IN    VARCHAR2,
        P_osp_id	              IN	NUMBER,
        P_work_order_ids          IN    AHL_OSP_QUERIES_PVT.work_id_tbl_type,
        x_order_lines_tbl	      OUT NOCOPY	AHL_OSP_QUERIES_PVT.order_line_tbl_Type,
        x_return_status	          OUT NOCOPY 	VARCHAR2,
        x_msg_count	              OUT NOCOPY 	NUMBER,
        x_msg_data	              OUT NOCOPY 	VARCHAR2

);

-------------------------------GET SUGGESTED VENDOR-------------------------
-- Return the suggested vendor for a work order
--   If there are no suggested vendors, returns null
--   If there are multiple suggested vendors, returns '*'
--   If there is only one vendor, returns the vendor name
----------------------------------------------------------------------------
FUNCTION Get_Suggested_Vendor(p_work_order_id  IN NUMBER)
RETURN VARCHAR2;

/* Added by mpothuku on 03-17-05 for calculating the onhand quantity for an inventory item */
-------------------------------GET ON HAND QUANTITY FOR AN ITEM-------------------------

FUNCTION Get_Onhand_Quantity(p_org_id  IN NUMBER, p_subinventory_code IN VARCHAR2, p_inventory_item_id IN NUMBER,
                            --Added by mpothuku on 23rd Aug, 06 to fix the Bug 5252627
                             p_lot_number IN VARCHAR2)
RETURN NUMBER;

END AHL_OSP_QUERIES_PVT;

 

/
