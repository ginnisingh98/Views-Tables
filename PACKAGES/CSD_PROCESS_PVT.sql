--------------------------------------------------------
--  DDL for Package CSD_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_PROCESS_PVT" AUTHID CURRENT_USER as
/* $Header: csdvints.pls 120.18.12010000.2 2009/03/31 23:41:12 takwong ship $ */

/*--------------------------------------------------*/
/* Record name: TASK_ACTIVITY_REC                    */
/* description : Record used for logging the         */
/*               task update activity                */
/*                                                  */
/*--------------------------------------------------*/

TYPE TASK_ACTIVITY_REC  IS RECORD
(
    TASK_ID                         NUMBER,
    REPAIR_LINE_ID                  NUMBER ,
    NEW_RESOURCE_ID                 NUMBER        ,
    NEW_RESOURCE_TYPE_CODE              VARCHAR2(30)        ,
    NEW_RESOURCE_NAME               VARCHAR2(250)  ,
    OLD_RESOURCE_ID                 NUMBER ,
    OLD_RESOURCE_TYPE_CODE              VARCHAR2(30) ,
    OLD_RESOURCE_NAME               VARCHAR2 (250) ,
    NEW_OWNER_ID                 NUMBER   ,
    NEW_OWNER_TYPE_CODE              VARCHAR2 (30) ,
    NEW_OWNER_NAME               VARCHAR2 (250),
    OLD_OWNER_ID                 NUMBER ,
    OLD_OWNER_TYPE_CODE              VARCHAR2 (30) ,
    OLD_OWNER_NAME               VARCHAR2 (250),
    NEW_STATUS_ID                 NUMBER ,
    NEW_STATUS              VARCHAR2 (30),
    OLD_STATUS_ID                 NUMBER ,
    OLD_STATUS              VARCHAR2 (30)

);

/*--------------------------------------------------*/
/* Record name: OM_INTERFACE_REC                    */
/* description : Record used for interfacing the    */
/*               product transaction lines          */
/*                                                  */
/*--------------------------------------------------*/

TYPE OM_INTERFACE_REC  IS RECORD
(
    INCIDENT_ID                 NUMBER          := FND_API.G_MISS_NUM,
    PARTY_ID                    NUMBER          := FND_API.G_MISS_NUM,
    ACCOUNT_ID                  NUMBER          := FND_API.G_MISS_NUM,
    ORG_ID                      NUMBER          := FND_API.G_MISS_NUM,
    ORDER_HEADER_ID             NUMBER          := FND_API.G_MISS_NUM,
    ORDER_LINE_ID               NUMBER          := FND_API.G_MISS_NUM,
    PICKING_RULE_ID             NUMBER          := FND_API.G_MISS_NUM,
    PICK_FROM_SUBINVENTORY      VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    DEF_STAGING_SUBINVENTORY    VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    SERIAL_NUMBER               VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    SHIPPED_QUANTITY            NUMBER          := FND_API.G_MISS_NUM,
    LOCATOR_ID                  NUMBER          := FND_API.G_MISS_NUM
);


/*--------------------------------------------------*/
/* Record name: SERVICE_REQUEST_REC                 */
/* description : Record used for service record     */
/*                                                  */
/*--------------------------------------------------*/

TYPE service_request_rec IS RECORD
(
      request_date             DATE         := FND_API.G_MISS_DATE,
      type_id                  NUMBER       := FND_API.G_MISS_NUM,
      type_name                VARCHAR2(30) := FND_API.G_MISS_CHAR,
      status_id                NUMBER       := FND_API.G_MISS_NUM,
      status_name              VARCHAR2(30) := FND_API.G_MISS_CHAR,
      severity_id              NUMBER       := FND_API.G_MISS_NUM,
      severity_name            VARCHAR2(30) := FND_API.G_MISS_CHAR,
      urgency_id               NUMBER       := FND_API.G_MISS_NUM,
      urgency_name             VARCHAR2(30) := FND_API.G_MISS_CHAR,
      closed_date              DATE         := FND_API.G_MISS_DATE,
      owner_id                 NUMBER       := FND_API.G_MISS_NUM,
      owner_group_id           NUMBER       := FND_API.G_MISS_NUM,
      publish_flag             VARCHAR2(1)  := FND_API.G_MISS_CHAR,
      summary                  VARCHAR2(240):= FND_API.G_MISS_CHAR,
      caller_type              VARCHAR2(30) := FND_API.G_MISS_CHAR,
      customer_id              NUMBER       := FND_API.G_MISS_NUM,
      customer_number          VARCHAR2(30) := FND_API.G_MISS_CHAR,
      employee_id              NUMBER       := FND_API.G_MISS_NUM,
      employee_number          VARCHAR2(30) := FND_API.G_MISS_CHAR,
      verify_cp_flag           VARCHAR2(1)  := FND_API.G_MISS_CHAR,
      customer_product_id      NUMBER       := FND_API.G_MISS_NUM,
      cp_ref_number            NUMBER       := FND_API.G_MISS_NUM,
      inventory_item_id        NUMBER       := FND_API.G_MISS_NUM,
      inventory_org_id         NUMBER       := FND_API.G_MISS_NUM,
      current_serial_number    VARCHAR2(30) := FND_API.G_MISS_CHAR,
      original_order_number    NUMBER       := FND_API.G_MISS_NUM,
      purchase_order_num       VARCHAR2(50) := FND_API.G_MISS_CHAR,
      problem_code             VARCHAR2(50) := FND_API.G_MISS_CHAR,
      exp_resolution_date      DATE         := FND_API.G_MISS_DATE,
      bill_to_site_use_id      NUMBER       := FND_API.G_MISS_NUM,
      ship_to_site_use_id      NUMBER       := FND_API.G_MISS_NUM,
      contract_id              NUMBER       := FND_API.G_MISS_NUM,
      account_id               NUMBER       := FND_API.G_MISS_NUM,
      resource_type            VARCHAR2(30) := FND_API.G_MISS_CHAR,
      cust_po_number           VARCHAR2(50) := FND_API.G_MISS_CHAR,
      cp_revision_id           NUMBER       := FND_API.G_MISS_NUM,
      inv_item_revision        VARCHAR2(3)  := FND_API.G_MISS_CHAR,
      sr_contact_point_id      NUMBER       := FND_API.G_MISS_NUM,
      party_id                 NUMBER       := FND_API.G_MISS_NUM,
      contact_point_id         NUMBER       := FND_API.G_MISS_NUM,
      contact_point_type       VARCHAR2(30) := FND_API.G_MISS_CHAR,
      primary_flag             VARCHAR2(1)  := FND_API.G_MISS_CHAR,
      contact_type             VARCHAR2(30) := FND_API.G_MISS_CHAR,
      sr_creation_channel      VARCHAR2(50) := FND_API.G_MISS_CHAR,
	 incident_number          VARCHAR2(64) := NULL, -- swai: FP 5157216
	 /*Fixed for bug#5589395 below column added for DFF on SR*/
       external_context           VARCHAR2(30):=NULL,
       external_attribute_1       VARCHAR2(150):=NULL,
       external_attribute_2       VARCHAR2(150):=NULL,
       external_attribute_3       VARCHAR2(150):=NULL,
       external_attribute_4       VARCHAR2(150):=NULL,
       external_attribute_5       VARCHAR2(150):=NULL,
       external_attribute_6       VARCHAR2(150):=NULL,
       external_attribute_7       VARCHAR2(150):=NULL,
       external_attribute_8       VARCHAR2(150):=NULL,
       external_attribute_9       VARCHAR2(150):=NULL,
       external_attribute_10      VARCHAR2(150):=NULL,
       external_attribute_11      VARCHAR2(150):=NULL,
       external_attribute_12      VARCHAR2(150):=NULL,
       external_attribute_13      VARCHAR2(150):=NULL,
       external_attribute_14      VARCHAR2(150):=NULL,
       external_attribute_15      VARCHAR2(150):=NULL
);



/*--------------------------------------------------*/
/* Record name: PRODUCT_TXN_REC                     */
/* description : Record used for product txn        */
/*                                                  */
/*--------------------------------------------------*/

/** ------------------------------------------------------------------------------------**/
/** In release 11.5.10, 13 new columns were added to table csd_product_transactions     **/
/** They are source_serial_number, source_Instance_number and these columns are  added  **/
/** to the product_txn_rec and existing columns(serial_number and instance_number       **/
/** are commented.                                                                      **/
/** Columns Order_Header_Id and Order_Line_Id were added to table csd_product_transactions **/
/** table but they are not included in product_txn_rec definition as there are          **/
/** existing columns in record definition with same name.                               **/
/** 9 Columns are added to the definition of product_Txn_rec record and they are as     **/
/** follows (non_source_serial_number, non_source_ib_Ref_number, req_header_id,         **/
/** req_line_id , locator_id, sub_inventory_rcvd, lot_number_rcvd                       **/
/** prd_txn_Qty_received and prd_txn_qty_shipped                                        **/
/** ------------------------------------------------------------------------------------**/


TYPE PRODUCT_TXN_REC  IS RECORD
(
  product_transaction_id     NUMBER          := FND_API.G_MISS_NUM,
  repair_line_id             NUMBER          := FND_API.G_MISS_NUM,
  estimate_detail_id         NUMBER          := FND_API.G_MISS_NUM,
  action_type                VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  action_code                VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  incident_id                NUMBER          := FND_API.G_MISS_NUM,
  transaction_type_id        NUMBER          := FND_API.G_MISS_NUM,
  business_process_id        NUMBER          := FND_API.G_MISS_NUM,
  txn_billing_type_id        NUMBER          := FND_API.G_MISS_NUM,
  original_source_id         NUMBER          := FND_API.G_MISS_NUM,
  source_id                  NUMBER          := FND_API.G_MISS_NUM,
  line_type_id               NUMBER          := FND_API.G_MISS_NUM,
  order_number               VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  status                     VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  currency_code              VARCHAR2(15)    := FND_API.G_MISS_CHAR,
  line_category_code         VARCHAR2(6)     := FND_API.G_MISS_CHAR,
  unit_of_measure_code       VARCHAR2(3)     := FND_API.G_MISS_CHAR,
  inventory_item_id          NUMBER          := FND_API.G_MISS_NUM,
  revision                   VARCHAR2(10)    := FND_API.G_MISS_CHAR,
  quantity                   NUMBER          := FND_API.G_MISS_NUM,
  -- ( comented serial_number as it is replaced by Source_Serial_Number 11.5.10
  -- serial_number              VARCHAR2(50)    := FND_API.G_MISS_CHAR,
  -- (commented shipped_serial_number it is no more used from 11.5.10
  -- shipped_serial_number      VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  lot_number                 VARCHAR2(80)    := FND_API.G_MISS_CHAR,  -- fix for bug#4625226
  -- (Commented instance_id as it is replaced by Source_instance_id 11.5.10
  -- instance_id                NUMBER          := FND_API.G_MISS_NUM,
  -- (commented instance number) as it is replaced by Source_instance_number 11.5.10
  -- instance_number            NUMBER          := FND_API.G_MISS_NUM,
  price_list_id              NUMBER          := FND_API.G_MISS_NUM,
  contract_id                NUMBER          := FND_API.G_MISS_NUM,
  coverage_id                NUMBER          := FND_API.G_MISS_NUM,
  coverage_txn_group_id      NUMBER          := FND_API.G_MISS_NUM,
  coverage_bill_rate_id      NUMBER          := FND_API.G_MISS_NUM,
  order_header_id            NUMBER          := FND_API.G_MISS_NUM,
  order_line_id              NUMBER          := FND_API.G_MISS_NUM,
  sub_inventory              VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  organization_id            NUMBER          := FND_API.G_MISS_NUM,
  invoice_to_org_id          NUMBER          := FND_API.G_MISS_NUM,
  ship_to_org_id             NUMBER          := FND_API.G_MISS_NUM,
  no_charge_flag             VARCHAR2(1)     := FND_API.G_MISS_CHAR,
  after_warranty_cost	     NUMBER	         := FND_API.G_MISS_NUM,
  add_to_order_flag          VARCHAR2(1)     := 'F',
  new_order_flag             VARCHAR2(1)     := FND_API.G_MISS_CHAR,
  interface_to_om_flag       VARCHAR2(1)     := FND_API.G_MISS_CHAR,
  book_sales_order_flag      VARCHAR2(1)     := FND_API.G_MISS_CHAR,
  release_sales_order_flag   VARCHAR2(1)     := FND_API.G_MISS_CHAR,
  ship_sales_order_flag      VARCHAR2(1)     := FND_API.G_MISS_CHAR,
  prod_txn_status            VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  prod_txn_code              VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  process_txn_flag           VARCHAR2(1)     := FND_API.G_MISS_CHAR,
  return_reason              VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  return_by_date             DATE            := FND_API.G_MISS_DATE,
  last_update_date           DATE            := FND_API.G_MISS_DATE,
  creation_date              DATE            := FND_API.G_MISS_DATE,
  last_updated_by            NUMBER          := FND_API.G_MISS_NUM,
  created_by                 NUMBER          := FND_API.G_MISS_NUM,
  last_update_login          NUMBER          := FND_API.G_MISS_NUM,
  attribute1                 VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute2                 VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute3                 VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute4                 VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute5                 VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute6                 VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute7                 VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute8                 VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute9                 VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute10                VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute11                VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute12                VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute13                VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute14                VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  attribute15                VARCHAR2(150)   := FND_API.G_MISS_CHAR,
  context                    VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  object_version_number      NUMBER          := FND_API.G_MISS_NUM,
  security_group_id          NUMBER          := FND_API.G_MISS_NUM,
  po_number                  VARCHAR2(50)    := FND_API.G_MISS_CHAR,
  -- Following columns are added as part of 11.5.10 release enhancments
  -- Non source columns will be used only when repair type in
  --(Replacement, Exchange and Advance Exchange)
  non_source_serial_number   VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  non_source_instance_Number VARCHAR2(30)    := NULL ,
  non_source_instance_id     NUMBER          := FND_API.G_MISS_NUM,
  source_serial_number       VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  -- Since instance_number is defined as Number in Charges Record assigning NULL  -- value instead of G_MISS_CHAR when initialized. saupadhy Sep-12-2003
  source_instance_number     VARCHAR2(30)    := NULL,
  source_instance_id         NUMBER          := FND_API.G_MISS_NUM,
  -- Requisition columns are used only for internal RO
  req_header_id              NUMBER          := FND_API.G_MISS_NUM,
  req_line_id                NUMBER          := FND_API.G_MISS_NUM,
  -- Quantity received against RMA or internal so.
  prd_txn_qty_received       NUMBER          := FND_API.G_MISS_NUM,
  -- Quantity shipped against SHIP line or internal so.
  prd_txn_qty_shipped        NUMBER          := FND_API.G_MISS_NUM,
  -- sub_inventory_rcvd column used by Internal repair order
  sub_inventory_rcvd         VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  -- Lot_number_Rcvd column used by Internal repair order
  lot_number_rcvd            VARCHAR2(80)    := FND_API.G_MISS_CHAR,  -- fix for bug#4625226
  -- This column is used only by both regular and internal ROs, if item is locator controlled
  locator_id                 NUMBER          := FND_API.G_MISS_NUM,
  charge_line_type           VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  -- Add_to_Order_Id column is used by regular RO only
  add_to_order_id            NUMBER          := FND_API.G_MISS_NUM,
  --Add below col for r12
  picking_rule_id            NUMBER,
  --R12 changes for contracts re arch
  contract_line_id           NUMBER,
  rate_type_code             VARCHAR2(40), -- This is added because charges
  -- table has this column, this may not be used.
  -- inventory_org changes , vijay Jan 28, 2006
  inventory_org_id           NUMBER,
  --taklam add column for project integration
  project_id                 NUMBER          := FND_API.G_MISS_NUM,
  task_id                    NUMBER          := FND_API.G_MISS_NUM,
  unit_number                VARCHAR2(30)    := FND_API.G_MISS_CHAR,
  -- swai: bug 5931926 - 3rd party logistics for 12.0.2
  bill_to_party_id           NUMBER          := FND_API.G_MISS_NUM,
  bill_to_account_id         NUMBER          := FND_API.G_MISS_NUM,
  ship_to_party_id           NUMBER          := FND_API.G_MISS_NUM,
  ship_to_account_id         NUMBER          := FND_API.G_MISS_NUM,
  -- swai: bug 6148019 internal PO Number
  internal_po_header_id      NUMBER          := FND_API.G_MISS_NUM
);

TYPE PRODUCT_TXN_TBL IS TABLE OF PRODUCT_TXN_REC INDEX BY BINARY_INTEGER;

-- HZ Wrappers: swai - updated to use TCA v2 records

   FUNCTION GET_ORG_REC_TYPE RETURN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
   FUNCTION GET_GROUP_REC_TYPE RETURN HZ_PARTY_V2PUB.GROUP_REC_TYPE;
   FUNCTION GET_PARTY_REC_TYPE RETURN HZ_PARTY_V2PUB.PARTY_REC_TYPE;
   FUNCTION GET_PERSON_REC_TYPE RETURN HZ_PARTY_V2PUB.PERSON_REC_TYPE;
   FUNCTION GET_CONTACT_POINTS_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
   FUNCTION GET_EDI_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
   FUNCTION GET_PHONE_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
   FUNCTION GET_EMAIL_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
   FUNCTION GET_TELEX_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
   FUNCTION GET_WEB_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
   FUNCTION GET_ACCOUNT_REC_TYPE RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
   FUNCTION GET_PARTY_REL_REC_TYPE RETURN HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
   FUNCTION GET_ORG_CONTACT_REC_TYPE RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
   FUNCTION GET_PARTY_SITE_REC_TYPE RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
   FUNCTION GET_PARTY_SITE_USE_REC_TYPE RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
   FUNCTION GET_CUST_PROFILE_REC_TYPE RETURN HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;


-- travi changes
/*-------------------------------------------------------*/
/* Record name: CREATE_TASK_REC_TYPE                     */
/* description : Record used for Task Creation or Update */
/* the Task called from Depot Repair Repair Forms        */
/*-------------------------------------------------------*/
TYPE CREATE_TASK_REC_TYPE IS RECORD
(
       TASK_ID                NUMBER         := FND_API.G_MISS_NUM,
       TASK_NAME              VARCHAR2(80)   := FND_API.G_MISS_CHAR,
       TASK_TYPE_ID           NUMBER         := FND_API.G_MISS_NUM,
       DESCRIPTION            VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       TASK_STATUS_ID         NUMBER         := FND_API.G_MISS_NUM,
       TASK_PRIORITY_NAME     VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       TASK_PRIORITY_ID       NUMBER         := FND_API.G_MISS_NUM,
       OWNER_TYPE_CODE        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       OWNER_ID               NUMBER         := FND_API.G_MISS_NUM,
       OWNER_TERRITORY_ID     NUMBER         := FND_API.G_MISS_NUM,
       ASSIGNED_BY_ID         NUMBER         := FND_API.G_MISS_NUM,
       CUSTOMER_ID            NUMBER         := FND_API.G_MISS_NUM,
       CUST_ACCOUNT_ID        NUMBER         := FND_API.G_MISS_NUM,
       ADDRESS_ID             NUMBER         := FND_API.G_MISS_NUM,
       PLANNED_START_DATE     DATE           := FND_API.G_MISS_DATE,
       PLANNED_END_DATE       DATE           := FND_API.G_MISS_DATE,
       SCHEDULED_START_DATE   DATE           := FND_API.G_MISS_DATE,
       SCHEDULED_END_DATE     DATE           := FND_API.G_MISS_DATE,
       ACTUAL_START_DATE      DATE           := FND_API.G_MISS_DATE,
       ACTUAL_END_DATE        DATE           := FND_API.G_MISS_DATE,
       TIMEZONE_ID            NUMBER         := FND_API.G_MISS_NUM,
       SOURCE_OBJECT_TYPE_CODE VARCHAR2(60)  := FND_API.G_MISS_CHAR,
       SOURCE_OBJECT_ID       NUMBER         := FND_API.G_MISS_NUM,
       SOURCE_OBJECT_NAME     VARCHAR2(80)   := FND_API.G_MISS_CHAR,
       DURATION               NUMBER         := FND_API.G_MISS_NUM,
       DURATION_UOM           VARCHAR2(3)    := FND_API.G_MISS_CHAR,
       PLANNED_EFFORT         NUMBER         := FND_API.G_MISS_NUM,
       PLANNED_EFFORT_UOM     VARCHAR2(3)    := FND_API.G_MISS_CHAR,
       ACTUAL_EFFORT          NUMBER         := FND_API.G_MISS_NUM,
       ACTUAL_EFFORT_UOM      VARCHAR2(3)    := FND_API.G_MISS_CHAR,
       PRIVATE_FLAG           VARCHAR2(1)    := FND_API.G_MISS_CHAR,
       PUBLISH_FLAG           VARCHAR2(1)    := FND_API.G_MISS_CHAR,
       RESTRICT_CLOSURE_FLAG  VARCHAR2(1)    := FND_API.G_MISS_CHAR,
       ATTRIBUTE1             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE2             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE3             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE4             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE5             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE6             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE7             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE8             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE9             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE10            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE11            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE12            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE13            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE14            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE15            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE_CATEGORY     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       BOUND_MODE_CODE        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       SOFT_BOUND_FLAG        VARCHAR2(1)    := FND_API.G_MISS_CHAR,
       PARENT_TASK_ID         NUMBER         := FND_API.G_MISS_NUM,
       ESCALATION_LEVEL       VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER  NUMBER         := FND_API.G_MISS_NUM
);

/*---------------------------------------------------*/
/* Function to Return the Record Type for Creating / */
/* Updating the Task called from Depot Repair Forms  */
/*---------------------------------------------------*/
FUNCTION GET_CREATE_TASK_REC_TYPE RETURN CSD_PROCESS_PVT.CREATE_TASK_REC_TYPE;


/*---------------------------------------------------*/
/* Record name: address_rec_type                     */
/* description : Record used for address creation    */
/* Record Type for Creating / Updating the Customer  */
/* Address called from Depot Repair Repair Forms     */
/*---------------------------------------------------*/
   TYPE address_rec_type IS RECORD
   (
  	    location_id                   NUMBER         := FND_API.G_MISS_NUM,
        address1                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address2                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address3                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address4                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        city                          VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        state                         VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        postal_code                   VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        province                      VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        county                        VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        country                       VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        language                      VARCHAR2(4)    := FND_API.G_MISS_CHAR,
        position                      VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        address_key                   VARCHAR2(500)  := FND_API.G_MISS_CHAR,
        postal_plus4_code             VARCHAR2(10)   := FND_API.G_MISS_CHAR,
        delivery_point_code           VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        location_directions           VARCHAR2(640)  := FND_API.G_MISS_CHAR,
        -- address_error_code            VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        clli_code                     VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        short_description             VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR,
        sales_tax_geocode             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        sales_tax_inside_city_limits  VARCHAR2(30)   := FND_API.G_MISS_CHAR,
     	address_effective_date        DATE           := FND_API.G_MISS_DATE,
	    address_expiration_date       DATE           := FND_API.G_MISS_DATE,
	    address_style                 VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        /* swai: unused TCA fields per bug #2863096, but still avail in TCA */
        po_box_number                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        house_number                  VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        street_suffix                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        street                        VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        street_number                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        floor                         VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        suite                         VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        /* swai: obsoleted TCA v1 fields
        apartment_number              VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        apartment_flag                VARCHAR2(1)    := FND_API.G_MISS_CHAR,
        secondary_suffix_element      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        rural_route_type              VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        rural_route_number            VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        building                      VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        room                          VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        time_zone                     VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        post_office                   VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        dodaac                        VARCHAR2(6)    := FND_API.G_MISS_CHAR,
        trailing_directory_code       VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        life_cycle_status             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        wh_update_date                DATE           := FND_API.G_MISS_DATE
        */
        /* swai: new TCA v2 fields */
        timezone_id                   NUMBER         := FND_API.G_MISS_NUM,
        created_by_module             VARCHAR2(150)  := 'CSDSR',
        application_id                NUMBER         := 516,
        actual_content_source         VARCHAR2(30)   := FND_API.G_MISS_CHAR
        );


/*---------------------------------------------------*/
/* R12 Quality Integration                            */
/* Record name: repair_task_type                     */
/* description : Record used for updating Depot task table */
/* Record Type for Creating / Updating the Quality  */
/* specifc data called from Depot Repair Repair Forms */
/*---------------------------------------------------*/
TYPE REPAIR_TASK_REC  IS RECORD
(
    REPAIR_TASK_ID                  NUMBER,
    TASK_ID                         NUMBER,
    REPAIR_LINE_ID                  NUMBER ,
    CONTEXT_VALUES                  VARCHAR2(10000),
    ORG_ID			    NUMBER,
    OBJECT_VERSION_NUMBER           NUMBER

);

/*--------------------------------------------------*/
/* Function to Return the Record Type for Creating  */
/* / Updating the Customer Address called from Depot*/
/* Repair Repair Forms                              */
/*--------------------------------------------------*/
 FUNCTION GET_ADDRESS_REC_TYPE RETURN CSD_PROCESS_PVT.ADDRESS_REC_TYPE;

-- travi changes


/*--------------------------------------------------*/
/* procedure name: process_service_request          */
/* description   : procedure used to create/update  */
/*                 service requests                 */
/*                                                  */
/*--------------------------------------------------*/

procedure PROCESS_SERVICE_REQUEST
( p_api_version          IN   NUMBER,
  p_commit               IN   VARCHAR2  := fnd_api.g_false,
  p_init_msg_list        IN   VARCHAR2  := fnd_api.g_false,
  p_validation_level     IN   NUMBER    := fnd_api.g_valid_level_full,
  p_action               IN   VARCHAR2,
  p_incident_id          IN   NUMBER    := NULL,
  p_service_request_rec  IN   CSD_PROCESS_PVT.SERVICE_REQUEST_REC,
  p_notes_tbl            IN   CS_SERVICEREQUEST_PUB.NOTES_TABLE ,
  x_incident_id		 OUT  NOCOPY  NUMBER,
  x_incident_number      OUT  NOCOPY  VARCHAR2,
  x_return_status	      OUT NOCOPY  VARCHAR2,
  x_msg_count		      OUT NOCOPY  NUMBER,
  x_msg_data		      OUT NOCOPY  VARCHAR2 );

/*--------------------------------------------------*/
/* procedure name: process_service_request          */
/* description   : procedure used to create/update  */
/*                 service requests                 */
/*                                                  */
/*--------------------------------------------------*/

procedure PROCESS_SERVICE_REQUEST
( p_api_version          IN   NUMBER,
  p_commit               IN   VARCHAR2  := fnd_api.g_false,
  p_init_msg_list        IN   VARCHAR2  := fnd_api.g_false,
  p_validation_level     IN   NUMBER    := fnd_api.g_valid_level_full,
  p_action               IN   VARCHAR2,
  p_incident_id          IN   NUMBER    := NULL,
  p_service_request_rec  IN   CSD_PROCESS_PVT.SERVICE_REQUEST_REC,
  x_incident_id		 OUT  NOCOPY  NUMBER,
  x_incident_number      OUT  NOCOPY  VARCHAR2,
  x_return_status	 OUT  NOCOPY  VARCHAR2,
  x_msg_count		 OUT  NOCOPY  NUMBER,
  x_msg_data		 OUT  NOCOPY  VARCHAR2 );


/*--------------------------------------------------*/
/* procedure name: process_charge_lines             */
/* description   : procedure used to create/update  */
/*                 delete charge lines              */
/*                                                  */
/*--------------------------------------------------*/

procedure PROCESS_CHARGE_LINES
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_action                IN     VARCHAR2,
  p_Charges_Rec           IN     Cs_Charge_Details_Pub.Charges_Rec_Type,
  x_estimate_detail_id    OUT NOCOPY    NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2  );


/*--------------------------------------------------*/
/* procedure name: apply_contract                   */
/* description   : procedure used to apply contract */
/*                                                  */
/*--------------------------------------------------*/

procedure APPLY_CONTRACT
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN     NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2);

/*--------------------------------------------------*/
/* procedure name: ship_sales_order                 */
/* description   : procedure used to ship           */
/*                 sales Order                      */
/*                                                  */
/*--------------------------------------------------*/

procedure SHIP_SALES_ORDER
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_delivery_id           IN OUT NOCOPY  NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2  );


/*--------------------------------------------------*/
/* procedure name: process_sales_order              */
/* description   : procedure used to create/book    */
/*                 release and ship sales Order     */
/*                                                  */
/*--------------------------------------------------*/

procedure PROCESS_SALES_ORDER
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_action                IN     VARCHAR2,
/*Fixed for bug#4433942 added product
  txn record as in parameter
*/
  p_product_txn_rec       IN  PRODUCT_TXN_REC default null,
  p_order_rec             IN OUT NOCOPY OM_INTERFACE_REC,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2  );

/*--------------------------------------------------*/
/* procedure name: create_product_txn               */
/* description   : procedure used to create         */
/*                 product transaction lines        */
/*                                                  */
/*--------------------------------------------------*/

procedure CREATE_PRODUCT_TXN
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  x_product_txn_rec       IN OUT NOCOPY PRODUCT_TXN_REC,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2  );

/*---------------------------------------------------*/
/* Procedure Name: Create_ext_prod_txn               */
/* description : This procedure will take additional */
/*               parameter and skip creating charge  */
/*               line based on the param
/*---------------------------------------------------*/
procedure CREATE_EXT_PROD_TXN
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  ,
  p_init_msg_list         IN     VARCHAR2  ,
  p_validation_level      IN     NUMBER    ,
  p_create_charge_lines   IN     VARCHAR2,
  x_product_txn_rec       IN OUT NOCOPY PRODUCT_TXN_REC,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2  );


/*--------------------------------------------------*/
/* procedure name: update_product_txn               */
/* description   : procedure used to update         */
/*                 product transaction lines        */
/*                                                  */
/*--------------------------------------------------*/

procedure UPDATE_PRODUCT_TXN
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  x_product_txn_rec       IN OUT NOCOPY PRODUCT_TXN_REC,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2  );


/*--------------------------------------------------*/
/* procedure name: delete_product_txn               */
/* description   : procedure used to delete         */
/*                 product transaction lines        */
/*                                                  */
/*--------------------------------------------------*/

Procedure DELETE_PRODUCT_TXN
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_product_txn_id        IN     NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2  );

/*--------------------------------------------------*/
/* procedure name: create_default_prod_txn          */
/* description   : procedure used to create         */
/*         default product transaction lines        */
/*                                                  */
/*--------------------------------------------------*/

procedure CREATE_DEFAULT_PROD_TXN
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_repair_line_id        IN     NUMBER,
  p_create_thirdpty_line  IN	 VARCHAR2  := fnd_api.g_false,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2  );


-- travi changes

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: create_task                                                                               */
/* description   : procedure used to create task                                                            */
/* Called from   : Depot Repair Form to Create Task                                                          */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 CREATE_TASK_REC_TYPE  RECORD      Required Columns are in the Record CREATE_TASK_REC_TYPE */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*                 x_task_id             NUMBER               Task Id of the created Task                    */
/*-----------------------------------------------------------------------------------------------------------*/
procedure CREATE_TASK
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2             := fnd_api.g_false,
  p_commit                IN     VARCHAR2             := fnd_api.g_false,
  p_validation_level      IN     NUMBER               := fnd_api.g_valid_level_full,
  p_create_task_rec       IN     CREATE_TASK_REC_TYPE,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  x_task_id               OUT NOCOPY    NUMBER
 );

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: update_task                                                                               */
/* description   : procedure used to update task                                                             */
/* Called from   : Depot Repair Form to Create Task                                                          */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 CREATE_TASK_REC_TYPE  RECORD      Required Columns are in the Record CREATE_TASK_REC_TYPE */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/

procedure UPDATE_TASK
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2             := fnd_api.g_false,
  p_commit                IN     VARCHAR2             := fnd_api.g_false,
  p_validation_level      IN     NUMBER               := fnd_api.g_valid_level_full,
  p_create_task_rec       IN     CREATE_TASK_REC_TYPE,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
 );


/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: create_address                                                                            */
/* description   : procedure to create Address for the Contact                                               */
/* Called from   : Depot Repair Form to Create Address                                                       */
/* Input Parm    : p_address_rec         RECORD      Required Record ADDRESS_REC_TYPE                        */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*                 x_location_id         NUMBER               Location ID of the Contacts address created    */
/*-----------------------------------------------------------------------------------------------------------*/
procedure CREATE_ADDRESS
(
  p_address_rec		IN	ADDRESS_REC_TYPE,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data        OUT NOCOPY     VARCHAR2,
  x_return_status   OUT NOCOPY     VARCHAR2,
  x_location_id		OUT NOCOPY     NUMBER);


/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: Create_repair_task_hist                                                                   */
/* description   : procedure used to create Repair Order history                                             */
/*                 for task creation                                                                         */
/* Called from   : Depot Repair Form to Create Address                                                       */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_task_id             NUMBER      Required Task Id                                        */
/*                 p_repair_line_id      NUMBER      Required Repair_line_id                                 */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/

PROCEDURE Create_repair_task_hist
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2             := fnd_api.g_false,
  p_commit                IN     VARCHAR2             := fnd_api.g_false,
  p_validation_level      IN     NUMBER               := fnd_api.g_valid_level_full,
  p_task_id               IN     NUMBER,
  p_repair_line_id        IN     NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
);

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: Create_repair_task_hist                                                                   */
/* description   : procedure used to create Repair Order history                                             */
/*                 for task creation                                                                         */
/* Called from   : Depot Repair Form to Create Address                                                       */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.
/*                 p_task_activity_rec   CSD_PROCESS_PVT.TASK_ACTIVITY_REC Used for logging task activity    */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/

PROCEDURE Create_repair_task_hist
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2             := fnd_api.g_true,
  p_commit                IN     VARCHAR2             := fnd_api.g_false,
  p_validation_level      IN     NUMBER               := fnd_api.g_valid_level_full,
  p_task_activity_rec     IN CSD_PROCESS_PVT.TASK_ACTIVITY_REC,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
);


/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: Update_repair_task_hist                                                                   */
/* description   : procedure used to Update Repair Order history                                             */
/*                 for task creation                                                                         */
/* Called from   : Depot Repair Form to update to Repair history                                             */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                p_task_acticity_rec    TASK_ACTIVITY_REC Required Used to log activity                     */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/

/*
PROCEDURE Update_repair_task_hist
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_true,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_task_id               IN     NUMBER,
  p_repair_line_id        IN     NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
);*/
--sangiguptask
/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: Update_repair_task_hist                                                                   */
/* description   : procedure used to Update Repair Order history                                             */
/*                 for task creation                                                                         */
/* Called from   : Depot Repair Form to update to Repair history                                             */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_activity_rec        TASK_ACTIVITY_REC Required Task activity record*/
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/

PROCEDURE Update_repair_task_hist
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2             := fnd_api.g_true,
  p_commit                IN     VARCHAR2             := fnd_api.g_false,
  p_validation_level      IN     NUMBER               := fnd_api.g_valid_level_full,
  p_task_activity_rec     IN CSD_PROCESS_PVT.TASK_ACTIVITY_REC,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
);
-- travi changes

/*----------------------------------------------------------------*/
/* procedure name: Close_Status                                   */
/* description   : procedure used to Close RO /Group RO  and SR   */
/*----------------------------------------------------------------*/

PROCEDURE Close_status
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN     NUMBER,
  p_repair_line_id        IN     NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
 );

/*---------------------------------------------------------------*/
 /* procedure name: Check_Service_Request                         */
 /* Description:  procedure used to find if there are unasigned   */
 /*               RMA/SO lines for the given service request      */
 /*---------------------------------------------------------------*/
 PROCEDURE Check_Service_Request
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN     NUMBER,
  x_link_mode			 OUT	NOCOPY  NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2
 );

 /*---------------------------------------------------------------*/
 /* procedure name: Update_Line_Txn_Source                        */
 /* Description:  procedure used to update the source_code and    */
 /*               source_id of the line transaction               */
 /*---------------------------------------------------------------*/
 PROCEDURE Update_Line_Txn_Source
( p_api_version           		 IN     NUMBER,
  p_commit                		 IN     VARCHAR2,
  p_init_msg_list         		 IN     VARCHAR2,
  p_validation_level      		 IN     NUMBER,
  p_incident_id      			 IN     NUMBER,
  p_estimate_detail_line_id         IN     NUMBER,
  p_repair_line_id      			 IN     NUMBER,
  x_return_status         		 OUT NOCOPY  VARCHAR2,
  x_msg_count             		 OUT NOCOPY  NUMBER,
  x_msg_data              		 OUT NOCOPY  VARCHAR2
 );


 /*---------------------------------------------------------------------------------*/
 /* procedure name: Update_iro_product_txn                                          */
 /* Description:  procedure used to update the product transaction                  */
 /*               table and process pick release and shipping                       */
 /*               transactions for internal ROs.                                    */
 /*   p_api_version         Standard in parameter                                   */
 /*   p_commit              Standard in parameter                                   */
 /*   p_init_msg_list       Standard in parameter                                   */
 /*   p_validation_level    Standard in parameter                                   */
 /*   x_return_status       Standard Out parameter                                  */
 /*   x_msg_count           Standard in parameter                                   */
 /*   x_msg_data            Standard in parameter ,                                 */
 /*   x_product_txn_rec     in out record variable of type                          */
 /*                         csd_process_pvt.product_txn_rec ) ;                     */
 /*---------------------------------------------------------------------------------*/
 Procedure update_iro_product_txn
    ( p_api_version           in     number,
      p_commit                in     varchar2  ,
      p_init_msg_list         in     varchar2 ,
      p_validation_level      in     number  ,
      x_product_txn_rec       in out nocopy csd_process_pvt.product_txn_rec ,
      x_return_status         out nocopy    varchar2,
      x_msg_count             out nocopy    number,
      x_msg_data              out nocopy    varchar2 );


/******************* ************* **********************/
/*------------------------------------------------------*/
/*         - Add Logistics_KeyAttr_Rec_Type             */
/*------------------------------------------------------*/
/* Record name: Logistics_KeyAttr_Rec_Type              */
/* description: Record used for returning entities      */
/*              for a given repair line id              */
/*                                                      */
/*------------------------------------------------------*/
Type Logistics_KeyAttr_Rec_Type IS Record
( Product_Transaction_Id        NUMBER,   -- Primary Key for table csd_product_Transactions table.
	Estimate_Detail_id            NUMBER,   -- Primary Key for table cs_estimate_Details
	Order_Header_Id               NUMBER,   -- Primar key for oe_order_headers_all
	Order_Line_Id                 NUMBER) ; -- Primary Key for oe_Order_Lines_all

TYPE Logistics_KeyAttr_Tbl_Type IS TABLE OF Logistics_KeyAttr_Rec_Type INDEX BY BINARY_INTEGER;
/***************** ************* ************************/



--  Bug# 3877328  forward porting bug
/*----------------------------------------------------------------------*/
/* procedure name: create_default_prod_txn_wrapr                        */
/* description   : Is a wrapper procedure which does validations before */
/*                 calling procedure create_default_prod_txn.           */
/*                 This API will have same parameters as procedure      */
/*                 create_default_prod_txn. After successful validation */
/*                 wrapper API will pass same input parameters.         */
/**************** ************* *****************************************/
/*         - Add Logistics_KeyAttr_Tbl_Type
/*----------------------------------------------------------------------*/
procedure CREATE_DEFAULT_PROD_TXN_wrapr
( p_api_version                IN  NUMBER,
  p_commit                     IN  VARCHAR2,
  p_init_msg_list              IN  VARCHAR2,
  p_validation_level           IN  NUMBER,
  p_repair_line_id             IN  NUMBER,
  x_return_status              OUT NOCOPY VARCHAR2,
  x_msg_count                  OUT NOCOPY NUMBER,
  x_msg_data                   OUT NOCOPY VARCHAR2,
  x_Logistics_KeyAttr_Tbl      OUT NOCOPY CSD_PROCESS_PVT.Logistics_KeyAttr_Tbl_Type );

/*-----------------------------------------------------------------------------------------------------------*/
/* R12 Quality Integration */
/* procedure name: create_repair_task                                                                               */
/* description   : procedure used to create DR specific tasks in Depot tables                                                            */
/* Called from   : Depot Repair Form to Create Task                                                          */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_CREATE_REPAIR_TASK_REC  RECORD      Required Columns are in the Record CREATE_REPAIR_TASK_REC_TYPE */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*                 x_repair_task_id             NUMBER               Task Id of the created Task                    */
/*-----------------------------------------------------------------------------------------------------------*/
procedure CREATE_REPAIR_TASK
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2             := fnd_api.g_false,
  p_commit                IN     VARCHAR2             := fnd_api.g_false,
  p_validation_level      IN     NUMBER               := fnd_api.g_valid_level_full,
  p_create_repair_task_rec       IN     REPAIR_TASK_REC,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  x_repair_task_id               OUT NOCOPY    NUMBER
 );

/*-----------------------------------------------------------------------------------------------------------*/
/* R12 Quality Integration */
/* procedure name: update_repair_task                                                                               */
/* description   : procedure used to update DR specifc task in Depot tables                                                             */
/* Called from   : Depot Repair Form to Update DR specifc Task                                                          */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 CREATE_REPAIR_TASK_REC RECORD      Required Columns are in the Record CREATE_REPAIR_TASK_REC_TYPE */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/

procedure UPDATE_REPAIR_TASK
( p_api_version           IN     NUMBER,
  p_init_msg_list         IN     VARCHAR2             := fnd_api.g_false,
  p_commit                IN     VARCHAR2             := fnd_api.g_false,
  p_validation_level      IN     NUMBER               := fnd_api.g_valid_level_full,
  p_update_repair_task_rec       IN     REPAIR_TASK_REC,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
 );
/*---------------------------------------------------*/
/* Function to Return the Record Type for Creating / */
/* Updating the Repair Task called from Depot Repair Forms  */
/*---------------------------------------------------*/
FUNCTION GET_REPAIR_TASK_REC RETURN CSD_PROCESS_PVT.REPAIR_TASK_REC;
G_DEPOT_REPAIR_TXN_NUMBER CONSTANT NUMBER := 2005;

END CSD_PROCESS_PVT;

/
