--------------------------------------------------------
--  DDL for Package CSE_DATASTRUCTURES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_DATASTRUCTURES_PUB" AUTHID CURRENT_USER as
-- $Header: CSEDATAS.pls 120.4.12010000.2 2009/07/09 08:25:31 aradhakr ship $

G_IN_PROCESS         CONSTANT VARCHAR2(30) := 'IN_PROCESS';
G_IN_INVENTORY       CONSTANT VARCHAR2(30) := 'IN_INVENTORY';
G_IN_SERVICE         CONSTANT VARCHAR2(30) := 'IN_SERVICE';
G_OUT_OF_SERVICE     CONSTANT VARCHAR2(30) := 'OUT_OF_SERVICE';
G_IN_TRANSIT         CONSTANT VARCHAR2(30) := 'IN_TRANSIT';
G_INSTALLED          CONSTANT VARCHAR2(30) := 'INSTALLED';
G_COMPLETE           CONSTANT VARCHAR2(30) := 'COMPLETE';
G_PENDING            CONSTANT VARCHAR2(30) := 'PENDING';
G_INTERFACED_TO_PA   CONSTANT VARCHAR2(30) := 'INTERFACED_TO_PA';
G_RETIRED            CONSTANT VARCHAR2(30) := 'RETIRED';
G_TXN_ERROR          CONSTANT VARCHAR2(1)  := 'E';
G_BYPASS_FLAG        CONSTANT VARCHAR2(1)  := 'B';
G_SUCCESS_FLAG       CONSTANT VARCHAR2(1)  := 'S';
G_IB_UPDATE          CONSTANT VARCHAR2(30)  := 'IB_UPDATE';
G_PA_INTERFACE       CONSTANT VARCHAR2(30)  := 'PA_INTERFACE';
G_OUTBOUND           CONSTANT VARCHAR2(30)  := 'OUTBOUND';
G_BYPASS             CONSTANT VARCHAR2(30)  := 'BYPASS';
G_NOTIFY             CONSTANT VARCHAR2(1)   := 'N';
G_FA_UPDATE          CONSTANT VARCHAR2(30)  := 'FA_UPDATE';
G_COMP_ADJ_PENDING   CONSTANT VARCHAR2(30)  := 'COMP_ADJ_PENDING';

TYPE ASSET_ATTRIBUTES_REC_TYPE IS RECORD
(      ASSET_ID         NUMBER,
       BOOK_TYPE_CODE   VARCHAR2(15),
       UNITS            NUMBER,
       TRANSACTED_BY    NUMBER,
       TRANSACTION_DATE DATE,
       Message_Id       NUMBER
);
TYPE RCV_ATTRIBUTES_REC_TYPE IS RECORD
(      RCV_TRANSACTION_ID   NUMBER,
       Message_Id           NUMBER
);

TYPE IPV_ATTRIBUTES_REC_TYPE IS RECORD
(      INVOICE_DISTRIBUTION_ID  NUMBER,
       Message_Id               NUMBER
);
TYPE MTL_ITEM_REC_TYPE IS RECORD
(     INVENTORY_ITEM_ID               NUMBER       := FND_API.G_MISS_NUM,
      ORGANIZATION_ID                 NUMBER       := FND_API.G_MISS_NUM,
      SUBINVENTORY_CODE               VARCHAR2(10) := FND_API.G_MISS_CHAR,
      REVISION                        VARCHAR2(3)  := FND_API.G_MISS_CHAR,
      TRANSACTION_QUANTITY            NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_UOM                 VARCHAR2(3)  := FND_API.G_MISS_CHAR,
      TRANSACTION_TYPE_ID             NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_ACTION_ID           NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_SOURCE_ID           NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_SOURCE_TYPE_ID      NUMBER       := FND_API.G_MISS_NUM,
      TRANSFER_LOCATOR_ID             NUMBER       := FND_API.G_MISS_NUM,
      TRANSFER_ORGANIZATION_ID        NUMBER       := FND_API.G_MISS_NUM,
      TRANSFER_SUBINVENTORY           VARCHAR2(10) := FND_API.G_MISS_CHAR,
      LOCATOR_ID                      NUMBER       := FND_API.G_MISS_NUM,
      SOURCE_PROJECT_ID               NUMBER       := FND_API.G_MISS_NUM,
      SOURCE_TASK_ID                  NUMBER       := FND_API.G_MISS_NUM,
      FROM_PROJECT_ID                 NUMBER       := FND_API.G_MISS_NUM,
      FROM_TASK_ID                    NUMBER       := FND_API.G_MISS_NUM,
      TO_PROJECT_ID                   NUMBER       := FND_API.G_MISS_NUM,
      TO_TASK_ID                      NUMBER       := FND_API.G_MISS_NUM,
      TRANSACTION_DATE                DATE         := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY                 NUMBER       := FND_API.G_MISS_NUM,
      SERIAL_NUMBER                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
      LOT_NUMBER                      VARCHAR2(30) := FND_API.G_MISS_CHAR,
      HR_LOCATION_ID                  NUMBER       := FND_API.G_MISS_NUM,
      PO_DISTRIBUTION_ID              NUMBER       := FND_API.G_MISS_NUM,
      SUBINV_LOCATION_ID              NUMBER       := FND_API.G_MISS_NUM,
      SHIPMENT_NUMBER                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
      TRX_SOURCE_LINE_ID              NUMBER       := FND_API.G_MISS_NUM,
      MOVE_ORDER_LINE_ID              NUMBER       := FND_API.G_MISS_NUM,
      SERIAL_NUMBER_CONTROL_CODE      NUMBER       := FND_API.G_MISS_NUM,
      SHIP_TO_LOCATION_ID             NUMBER       := FND_API.G_MISS_NUM
);
   TYPE MTL_ITEM_TBL_TYPE is TABLE OF MTL_ITEM_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE MTL_INSTANCE_REC_TYPE is RECORD
(     INSTANCE_ID                     NUMBER,
      INSTANCE_NUMBER                 VARCHAR2(30),
      INVENTORY_ITEM_ID               NUMBER,
      INVENTORY_REVISION              VARCHAR2(3),
      INV_MASTER_ORGANIZATION_ID      NUMBER,
      SERIAL_NUMBER                   VARCHAR2(30),
      MFG_SERIAL_NUMBER_FLAG          VARCHAR2(1),
      LOT_NUMBER                      VARCHAR2(30),
      QUANTITY                        NUMBER,
      UNIT_OF_MEASURE                 VARCHAR2(3),
      INSTANCE_STATUS_ID              NUMBER,
      CUSTOMER_VIEW_FLAG              VARCHAR2(1),
      MERCHANT_VIEW_FLAG              VARCHAR2(1),
      INSTANCE_TYPE_CODE              VARCHAR2(30),
      LOCATION_TYPE_CODE              VARCHAR2(30),
      LOCATION_ID                     NUMBER,
      INV_ORGANIZATION_ID             NUMBER,
      INV_SUBINVENTORY_NAME           VARCHAR2(10),
      INV_LOCATOR_ID                  NUMBER,
      PA_PROJECT_ID                   NUMBER,
      PA_PROJECT_TASK_ID              NUMBER
);
   TYPE MTL_INSTANCE_TBL_TYPE is TABLE OF MTL_INSTANCE_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE MTL_TRX_TYPE is RECORD
(     MTL_TRANSACTION_ID              NUMBER);

 TYPE PROJ_ITEM_UNINST_ATTR_REC_TYPE IS RECORD
(      ITEM_ID                 NUMBER,
       REVISION                VARCHAR2(3),
       LOT_NUMBER              VARCHAR2(30),
       SERIAL_NUMBER           VARCHAR2(30),
       QUANTITY                NUMBER,
       NETWORK_LOCATION_ID     NUMBER,
       PARTY_SITE_ID           NUMBER,
       WORK_ORDER_NUMBER       VARCHAR2(30),
       PROJECT_ID              NUMBER,
       TASK_ID                 NUMBER,
       TRANSACTION_DATE        DATE,
       TRANSACTED_BY           NUMBER,
       MESSAGE_ID              NUMBER
);
   TYPE PROJ_ITEM_UNINST_ATTR_TBL_TYPE is TABLE OF PROJ_ITEM_UNINST_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE PROJ_ITEM_INST_ATTR_REC_TYPE IS RECORD
(      ITEM_ID                 NUMBER,
       REVISION                VARCHAR2(3),
       LOT_NUMBER              VARCHAR2(30),
       SERIAL_NUMBER           VARCHAR2(30),
       QUANTITY                NUMBER,
       NETWORK_LOCATION_ID     NUMBER,
       PARTY_SITE_ID           NUMBER,
       WORK_ORDER_NUMBER       VARCHAR2(30),
       PROJECT_ID              NUMBER,
       TASK_ID                 NUMBER,
       TRANSACTION_DATE        DATE,
       TRANSACTED_BY           NUMBER,
       MESSAGE_ID              NUMBER
);
   TYPE PROJ_ITEM_INST_ATTR_TBL_TYPE is TABLE OF PROJ_ITEM_INST_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE OUT_OF_SERVICE_ATTR_REC_TYPE IS RECORD
(      ITEM_ID                 NUMBER,
       REVISION                VARCHAR2(3),
       LOT_NUMBER              VARCHAR2(30),
       SERIAL_NUMBER           VARCHAR2(30),
       QUANTITY                NUMBER,
       NETWORK_LOCATION_ID     NUMBER,
       PARTY_SITE_ID           NUMBER,
       WORK_ORDER_NUMBER       VARCHAR2(30),
       TRANSACTION_DATE        DATE,
       TRANSACTED_BY           NUMBER,
       MESSAGE_ID              NUMBER
);
   TYPE OUT_OF_SERVICE_ATTR_TBL_TYPE is TABLE OF OUT_OF_SERVICE_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE IN_SERVICE_ATTR_REC_TYPE IS RECORD
(      ITEM_ID                 NUMBER,
       REVISION                VARCHAR2(3),
       LOT_NUMBER              VARCHAR2(30),
       SERIAL_NUMBER           VARCHAR2(30),
       QUANTITY                NUMBER,
       NETWORK_LOCATION_ID     NUMBER,
       PARTY_SITE_ID           NUMBER,
       WORK_ORDER_NUMBER       VARCHAR2(30),
       TRANSACTION_DATE        DATE,
       TRANSACTED_BY           NUMBER,
       MESSAGE_ID              NUMBER
);
   TYPE IN_SERVICE_ATTR_TBL_TYPE is TABLE OF IN_SERVICE_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE ITEM_MOVE_ATTR_REC_TYPE IS RECORD
(      ITEM_ID                     NUMBER,
       REVISION                    VARCHAR2(3),
       LOT_NUMBER                  VARCHAR2(30),
       SERIAL_NUMBER               VARCHAR2(30),
       QUANTITY                    NUMBER,
       FROM_NETWORK_LOCATION_ID    NUMBER,
       TO_NETWORK_LOCATION_ID      NUMBER,
       FROM_PARTY_SITE_ID          NUMBER,
       TO_PARTY_SITE_ID            NUMBER,
       WORK_ORDER_NUMBER           VARCHAR2(30),
       TRANSACTION_DATE            DATE,
       TRANSACTED_BY               NUMBER,
       MESSAGE_ID                  NUMBER
);
   TYPE ITEM_MOVE_ATTR_TBL_TYPE is TABLE OF ITEM_MOVE_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;

  TYPE PROJ_ITM_INSV_ATTR_REC_TYPE IS RECORD
(      ITEM_ID                 NUMBER,
       REVISION                VARCHAR2(3),
       LOT_NUMBER              VARCHAR2(30),
       SERIAL_NUMBER           VARCHAR2(30),
       QUANTITY                NUMBER,
       NETWORK_LOCATION_ID     NUMBER,
       PARTY_SITE_ID           NUMBER,
       WORK_ORDER_NUMBER       VARCHAR2(30),
       PROJECT_ID              NUMBER,
       TASK_ID                 NUMBER,
       EFFECTIVE_DATE          DATE,
       TRANSACTION_DATE        DATE,
       TRANSACTED_BY           NUMBER,
       MESSAGE_ID              NUMBER
);
   TYPE PROJ_ITM_INSV_ATTR_TBL_TYPE is TABLE OF PROJ_ITM_INSV_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE PROJ_ITM_INSV_PA_ATTR_REC_TYPE IS RECORD
(      ITEM_ID                 NUMBER,
       INV_MASTER_ORG_ID       NUMBER,
       SERIAL_NUMBER           VARCHAR2(30),
       QUANTITY                NUMBER,
       LOCATION_ID             NUMBER,
       LOCATION_TYPE           VARCHAR2(30),
       PROJECT_ID              NUMBER,
       TASK_ID                 NUMBER,
       INSTANCE_ID             NUMBER,
       OBJECT_VERSION_NUMBER   NUMBER,
       TRANSACTION_ID          NUMBER,
       TRANSACTION_DATE        DATE,
       TRANSACTED_BY           NUMBER,
       MESSAGE_ID              NUMBER,
       org_id                  number,
       to_project_id	       NUMBER,	-- Added for bug 8670632
       to_task_id              NUMBER	-- Added for bug 8670632
);

  TYPE PROJ_ITM_INSV_PA_ATTR_TBL_TYPE is TABLE OF PROJ_ITM_INSV_PA_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;

  TYPE Rcv_Txn_Rec_Type IS RECORD (
    Rcv_Transaction_ID NUMBER,
    Temp_Txn_Id             NUMBER,
    Organization_ID         NUMBER,
    Txn_Organization_ID     NUMBER,
    PO_Header_Id            NUMBER,
    PO_Line_Id              NUMBER,
    PO_Distribution_Id      NUMBER,
    Project_ID              NUMBER,
    Task_ID                 NUMBER,
    Transacted_By           NUMBER,
    Transaction_Date        DATE,
    Inventory_Item_ID       NUMBER,
    Revision_Id             VARCHAR2(3),
    Lot_Number              VARCHAR2(30),
    Serial_Number           VARCHAR2(30),
    Quantity                NUMBER,
    UOM                     VARCHAR2(3),
    Amount                  NUMBER,
    CSI_Transaction_Id      NUMBER,
    PO_Number               VARCHAR2(50),
    PO_Line_Number          VARCHAR2(50),
    po_vendor_id            number,
    transaction_type        varchar2(30),
    destination_type_code   varchar2(30));

  TYPE Rcv_Txn_tbl_Type IS TABLE OF Rcv_Txn_Rec_Type INDEX BY BINARY_INTEGER;

  TYPE IPV_Txn_Rec_Type IS RECORD (
    Project_Id              NUMBER,
    Task_Id                 NUMBER,
    Inventory_Item_Id       NUMBER,
    Item_Name               VARCHAR2(30),
    Serial_Number           VARCHAR2(30),
    Invoice_Distribution_Id NUMBER,
    Accounting_Date         DATE,
    Invoice_Id              NUMBER,
    IPV                     NUMBER,
    Transacted_By           NUMBER,
    Transaction_Date        DATE,
    Organization_Id         NUMBER,
    Invoice_Quantity        NUMBER,
    Price_Var_CC_Id         NUMBER,
    PO_Header_Id            NUMBER,
    PO_line_id              NUMBER,
    PO_distribution_id      NUMBER,
    Cr_CC_Id             NUMBER,
    Vendor_Number           VARCHAR2(30),
    UOM                     VARCHAR2(15),
    CSI_Transaction_ID      NUMBER,
    INVOICE_NUMBER          VARCHAR2(50));
  TYPE IPV_Txn_tbl_Type IS TABLE OF IPV_Txn_Rec_Type
   INDEX BY BINARY_INTEGER;

TYPE asset_query_rec IS RECORD
     (
           parent_mass_addition_id      NUMBER          := FND_API.G_MISS_NUM
          ,mass_addition_id             NUMBER          := FND_API.G_MISS_NUM
          ,asset_id                     NUMBER          := FND_API.G_MISS_NUM
          ,search_method                VARCHAR2(4)     := FND_API.G_MISS_CHAR
          ,asset_number                 VARCHAR2(15)    := FND_API.G_MISS_CHAR
          ,category_id                  NUMBER          := FND_API.G_MISS_NUM
          ,book_type_code               VARCHAR2(15)    := FND_API.G_MISS_CHAR
          ,date_placed_in_service       DATE            := FND_API.G_MISS_DATE
          ,asset_key_ccid               NUMBER          := FND_API.G_MISS_NUM
          ,tag_number                   VARCHAR2(15)    := FND_API.G_MISS_CHAR
          ,description                  VARCHAR2(80)    := FND_API.G_MISS_CHAR
          ,manufacturer_name            VARCHAR2(30)    := FND_API.G_MISS_CHAR
          ,serial_number                VARCHAR2(35)    := FND_API.G_MISS_CHAR
          ,model_number                 VARCHAR2(40)    := FND_API.G_MISS_CHAR
          ,location_id                  NUMBER          := FND_API.G_MISS_NUM
          ,employee_id                  NUMBER          := FND_API.G_MISS_NUM
          ,deprn_employee_id            NUMBER          := FND_API.G_MISS_NUM
          ,deprn_expense_ccid           NUMBER          := FND_API.G_MISS_NUM
          ,inventory_item_id            NUMBER          := FND_API.G_MISS_NUM
          ,distribution_id              NUMBER          := FND_API.G_MISS_NUM
          ,current_mtl_cost             NUMBER          := FND_API.G_MISS_NUM
          ,current_non_mtl_cost         NUMBER          := FND_API.G_MISS_NUM
          ,current_units                NUMBER          := FND_API.G_MISS_NUM
          ,pending_adj_mtl_cost         NUMBER          := FND_API.G_MISS_NUM
          ,pending_adj_non_mtl_cost     NUMBER          := FND_API.G_MISS_NUM
          ,pending_ret_mtl_cost         NUMBER          := FND_API.G_MISS_NUM
          ,pending_ret_non_mtl_cost     NUMBER          := FND_API.G_MISS_NUM
          ,pending_ret_units            NUMBER          := FND_API.G_MISS_NUM
     );

TYPE asset_query_tbl IS TABLE OF asset_query_rec
INDEX BY BINARY_INTEGER;


--bnarayan added for R12
TYPE asset_attrib_rec IS RECORD
     (
           Instance_ID                  NUMBER          := FND_API.G_MISS_NUM
          ,Inventory_Item_ID            NUMBER          := FND_API.G_MISS_NUM
          ,Serial_Number                VARCHAR2(30)    := FND_API.G_MISS_CHAR
          ,Organization_ID              NUMBER          := FND_API.G_MISS_NUM
          ,INV_MASTER_Organization_ID   NUMBER          := FND_API.G_MISS_NUM
          ,Subinventory_Name            VARCHAR2(30)    := FND_API.G_MISS_CHAR
          ,Transaction_Quantity         NUMBER          := FND_API.G_MISS_NUM
          ,Transaction_ID               NUMBER          := FND_API.G_MISS_NUM
   ,Transaction_Date             DATE            := FND_API.G_MISS_DATE
          ,Source_Transaction_type      VARCHAR2(30)   := FND_API.G_MISS_CHAR
          ,Depreciable_Flag             VARCHAR2(1)    :=  FND_API.G_MISS_CHAR
          ,Location_Type_Code           VARCHAR2(40)    := FND_API.G_MISS_CHAR
          ,Transaction_Type_ID          NUMBER          := FND_API.G_MISS_NUM
          ,Source_Header_Ref_ID         NUMBER          := FND_API.G_MISS_NUM
          ,RCV_Transaction_ID           NUMBER          := FND_API.G_MISS_NUM
          ,PO_Distribution_Id           NUMBER          := FND_API.G_MISS_NUM
          ,Inv_Material_Transaction_ID  NUMBER          := FND_API.G_MISS_NUM
          ,Location_id                  NUMBER          := FND_API.G_MISS_NUM
          ,Asset_Category_ID            NUMBER          := FND_API.G_MISS_NUM
          ,book_type_code               VARCHAR2(15)    := FND_API.G_MISS_CHAR

     );


TYPE asset_attrib_tbl IS TABLE OF asset_attrib_rec
INDEX BY BINARY_INTEGER;




TYPE distribution_rec IS RECORD
(
       asset_id               NUMBER        := FND_API.G_MISS_NUM
      ,book_type_code         VARCHAR2(15)  := FND_API.G_MISS_CHAR
      ,distribution_id        NUMBER        := FND_API.G_MISS_NUM
      ,location_id            NUMBER        := FND_API.G_MISS_NUM
      ,employee_id            NUMBER        := FND_API.G_MISS_NUM
      ,deprn_expense_ccid     NUMBER        := FND_API.G_MISS_NUM
      ,current_units          NUMBER        := FND_API.G_MISS_NUM
      ,pending_ret_units      NUMBER        := FND_API.G_MISS_NUM
);

TYPE distribution_tbl IS TABLE OF distribution_rec
INDEX BY BINARY_INTEGER ;

G_LIFO_SEARCH           CONSTANT VARCHAR2(4)         := 'LIFO';
G_FIFO_SEARCH           CONSTANT VARCHAR2(4)         := 'FIFO';
G_APPLICATION_NAME      CONSTANT VARCHAR2(3)         := 'CSE';

TYPE WFM_TRX_VALUES_REC is RECORD
(      INVENTORY_ITEM_ID           NUMBER,
       INVENTORY_REVISION          VARCHAR2(3),
       LOT_NUMBER                  VARCHAR2(30),
       SERIAL_NUMBER               VARCHAR2(30),
       QUANTITY                    NUMBER,
       NETWORK_LOCATION_ID         NUMBER,
       PARTY_SITE_ID               NUMBER,
       FROM_NETWORK_LOCATION_ID    NUMBER,
       TO_NETWORK_LOCATION_ID      NUMBER,
       FROM_PARTY_SITE_ID          NUMBER,
       TO_PARTY_SITE_ID            NUMBER,
       WORK_ORDER_NUMBER           VARCHAR2(30),
       SOURCE_TRANSACTION_DATE     DATE,
       SOURCE_TRANSACTION_BY       NUMBER,
       TRANSACTION_DATE            DATE,
       TRANSACTED_BY               NUMBER,
       EFFECTIVE_DATE              DATE,
       PROJECT_ID                  NUMBER,
       TASK_ID                     NUMBER,
       RETURN_STATUS               VARCHAR2(1),
       ERROR_MESSAGE               VARCHAR2(2000)
);

TYPE WFM_TRX_VALUES_TBL IS TABLE OF WFM_TRX_VALUES_REC INDEX BY BINARY_INTEGER;

END CSE_DATASTRUCTURES_PUB;

/
