--------------------------------------------------------
--  DDL for Package MTL_CCEOI_VAR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CCEOI_VAR_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVCCVS.pls 120.1 2005/06/22 05:28:06 appldev ship $ */
-- ################# New Datatypes #################################
-- New record Type for Item informations
TYPE INV_ITEM_REC_TYPE IS RECORD(
  INVENTORY_ITEM_ID	NUMBER DEFAULT NULL
, ITEM_SEGMENT1		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT2		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT3		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT4		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT5		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT6		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT7		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT8		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT9		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT10		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT11		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT12		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT13		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT14		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT15		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT16		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT17		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT18		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT19		VARCHAR2(40) DEFAULT NULL
, ITEM_SEGMENT20		VARCHAR2(40) DEFAULT NULL
);
--
-- New record type for Locator information
TYPE INV_LOCATOR_REC_TYPE IS RECORD(
  LOCATOR_ID		NUMBER  DEFAULT NULL
, LOCATOR_SEGMENT1	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT2	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT3	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT4	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT5	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT6	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT7	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT8	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT9	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT10	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT11	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT12	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT13	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT14	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT15	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT16	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT17	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT18	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT19	VARCHAR2(40) DEFAULT NULL
, LOCATOR_SEGMENT20	VARCHAR2(40) DEFAULT NULL
);
--
-- New record type for adjustment account
TYPE ADJUSTACCOUNT_REC_TYPE IS RECORD(
  ADJUSTMENT_ACCOUNT_ID		NUMBER DEFAULT NULL
, ACCOUNT_SEGMENT1	 VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT2	 VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT3	 VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT4	 VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT5	 VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT6	 VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT7	 VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT8	 VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT9	 VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT10 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT11 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT12 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT13 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT14 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT15 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT16 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT17 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT18 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT19 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT20 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT21 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT22 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT23 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT24 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT25 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT26 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT27 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT28 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT29 	VARCHAR2(25) DEFAULT NULL
, ACCOUNT_SEGMENT30 	VARCHAR2(25) DEFAULT NULL
);
--
-- New record data type for attribute category
TYPE INV_ATTRIB_CATEGORY_REC_TYPE IS RECORD(
  INVENTORY_ITEM_ID	NUMBER  DEFAULT NULL
, ATTRIBUTE1		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE2		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE3		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE4		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE5		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE6		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE7		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE8		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE9		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE10		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE11		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE12		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE13		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE14		VARCHAR2(150) DEFAULT NULL
, ATTRIBUTE15		VARCHAR2(150) DEFAULT NULL
);
--
-- New record data type for SKU information
TYPE INV_SKU_REC_TYPE IS RECORD (
  INVENTORY_ITEM_FLAG		VARCHAR2(1)  DEFAULT NULL
, REVISION_QTY_CONTROL_CODE	NUMBER DEFAULT NULL
, REVISION			VARCHAR2(3) DEFAULT NULL
, LOT_CONTROL_CODE 		NUMBER DEFAULT NULL
, LOT_NUMBER			VARCHAR2(80) DEFAULT NULL -- INVCONV
, EXPIRATION_DATE		DATE DEFAULT NULL  --LOT
, SERIAL_NUMBER_CONTROL_CODE	NUMBER DEFAULT NULL
, SERIAL_NUMBER			VARCHAR2(30) DEFAULT NULL
, ALLOWED_UNITS_LOOKUP_CODE	NUMBER DEFAULT NULL
, LOCATION_CONTROL_CODE		NUMBER DEFAULT NULL
, RESTRICT_LOCATORS_CODE	NUMBER DEFAULT NULL
);
--
--################# VARIABLES ###########################
--
-- Cycle Count header record
G_CYCLE_COUNT_HEADER_REC	MTL_CYCLE_COUNT_HEADERS%ROWTYPE;
--
-- Cycle Count Entries record
G_CYCLE_COUNT_ENTRY_REC	MTL_CYCLE_COUNT_ENTRIES%ROWTYPE;
--
-- Open request exist
G_OPEN_REQUEST BOOLEAN default FALSE;
--
-- SKU record for the current entrie
G_SKU_REC		MTL_CCEOI_VAR_PVT.INV_SKU_REC_TYPE;
--
-- Adjustment amount
G_ADJUSTMENT_AMOUNT		NUMBER DEFAULT NULL;
--
-- Adjustment Variance percentage
G_ADJ_VARIANCE_PERCENTAGE	NUMBER DEFAULT NULL;
--
-- Adjustment quantity
G_ADJUSTMENT_QUANTITY	NUMBER DEFAULT NULL;
-- item costs
G_ITEM_COST	NUMBER DEFAULT NULL;
--
-- Stock locator control code for the given organization
G_STOCK_LOCATOR_CONTROL_CODE	NUMBER DEFAULT NULL;
--
-- Action Codes
G_EXPORT CONSTANT integer   := 10 ;
G_VALIDATE CONSTANT integer := 11;
G_CREATE CONSTANT integer   := 12;
G_VALSIM CONSTANT integer   := 13;
G_PROCESS CONSTANT integer  := 14;
G_CREPRO CONSTANT integer   := 15;
--
-- Get who and concurrent program information.
G_LoginID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_UserID NUMBER:= FND_GLOBAL.USER_ID;
G_ProgramAppID NUMBER:= FND_GLOBAL.PROG_APPL_ID;
G_ProgramID NUMBER:= FND_GLOBAL.CONC_PROGRAM_ID;
G_RequestID NUMBER:= FND_GLOBAL.CONC_REQUEST_ID;
--
-- Temporary Se No - for Unschedule Entry
G_Seq_No NUMBER;
-- Current interface record ID
G_cc_entry_interface_id
   MTL_CC_ENTRIES_INTERFACE.cc_entry_interface_id%type  DEFAULT NULL;
--
-- LOCATOR_CONTROL of Subinventory on ORGANIZATION LEVEL
G_ITEM_LOCATOR_TYPE MTL_SYSTEM_ITEMS.LOCATION_CONTROL_CODE%TYPE :=
    G_SKU_REC.LOCATION_CONTROL_CODE;
--
-- LOCATOR_CONTROL of Item level
G_SUB_LOCATOR_TYPE
    MTL_SECONDARY_INVENTORIES.LOCATOR_TYPE%TYPE DEFAULT NULL;
--
-- Current Inventory Item ID
G_INVENTORY_ITEM_ID MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%type  DEFAULT NULL;
--
-- Cycle Count Orientation Code
G_ORIENTATION_CODE number := G_CYCLE_COUNT_HEADER_REC.ORIENTATION_CODE;
--
-- Cycle Count Header ID
G_CC_HEADER_ID number := G_CYCLE_COUNT_HEADER_REC.CYCLE_COUNT_HEADER_ID;
--
-- Current Locator ID
G_LOCATOR_ID MTL_ITEM_LOCATIONS.INVENTORY_LOCATION_ID%TYPE DEFAULT NULL;
--
-- Primary unit of measure code of the current item
G_PRIMARY_UOM_CODE  MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE%TYPE default null;
--
-- Unit of measure code
G_UOM_CODE MTL_CYCLE_COUNT_ENTRIES.COUNT_UOM_CURRENT%TYPE default null;
--
-- Count Quantity
G_COUNT_QUANTITY MTL_CC_ENTRIES_INTERFACE.COUNT_QUANTITY%TYPE default null;
--
-- System quantity
G_SYSTEM_QUANTITY MTL_ONHAND_QUANTITIES.TRANSACTION_QUANTITY%TYPE default null;
--
-- Employee-ID of the counter
G_EMPLOYEE_ID MTL_EMPLOYEES_CURRENT_VIEW.Employee_ID%type default null;
--
-- Count Date
G_COUNT_DATE date default null;
--
-- SUBINVENTORY
G_SUBINVENTORY MTL_CC_ENTRIES_INTERFACE.SUBINVENTORY%TYPE default null ;
-- Adjustment Account ID
G_ADJUST_ACCOUNT_ID MTL_CC_ENTRIES_INTERFACE.ADJUSTMENT_ACCOUNT_ID%type
default null;

-- flag to determine whether the record that is being processed
-- is stored in the interface
G_REC_IN_SYSTEM BOOLEAN DEFAULT TRUE;

-- LPN ID
G_LPN_ID MTL_CC_ENTRIES_INTERFACE.PARENT_LPN_ID%TYPE default null ;
-- System Quantity
G_LPN_ITEM_SYSTEM_QTY NUMBER DEFAULT 0;

-- CONTIANER ENABLED FLAG
G_CONTAINER_ENABLED_FLAG NUMBER DEFAULT NULL;
-- CONTIANER_ADJUSTMENT_OPTION
G_CONTAINER_ADJUSTMENT_OPTION NUMBER DEFAULT NULL;
-- CONTAINER_DECREPANCY_OPTION
G_CONTAINER_DISCREPANCY_OPTION NUMBER DEFAULT NULL;

-- Cost Group
G_COST_GROUP_ID NUMBER DEFAULT NULL;

TYPE INV_CCEOI_ID_TABLE_TYPE is TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

--
-- temporary record variable to include all changes for an processing of the
-- interface records. IF the the processing is not simulated then
-- the values of that record will be inserted into the DB
G_CC_ENTRY_REC_TMP MTL_CYCLE_COUNT_ENTRIES%ROWTYPE;
    -- New record Type forentries interface
    TYPE INV_CCEOI_TYPE IS RECORD(
     cost_group_name		     VARCHAR2(40),
     cost_group_id		     NUMBER,
     parent_lpn			     VARCHAR2(40),
     parent_lpn_id		     NUMBER,
     outermost_lpn_id		     NUMBER,
     cc_entry_interface_id           NUMBER,
     organization_id                 NUMBER,
     last_update_date                DATE    ,
     last_updated_by                 NUMBER,
     creation_date                   DATE   ,
     created_by                      NUMBER,
     last_update_login               NUMBER,
     cc_entry_interface_group_id     NUMBER,
     cycle_count_entry_id            NUMBER,
     action_code                     NUMBER,
     cycle_count_header_id           NUMBER,
     cycle_count_header_name         VARCHAR2(30),
     count_list_sequence             NUMBER,
     inventory_item_id               NUMBER,
     item_segment1                   VARCHAR2(40),
     item_segment2                   VARCHAR2(40),
     item_segment3                   VARCHAR2(40),
     item_segment4                   VARCHAR2(40),
     item_segment5                   VARCHAR2(40),
     item_segment6                   VARCHAR2(40),
     item_segment7                   VARCHAR2(40),
     item_segment8                   VARCHAR2(40),
     item_segment9                   VARCHAR2(40),
     item_segment10                  VARCHAR2(40),
     item_segment11                  VARCHAR2(40),
     item_segment12                  VARCHAR2(40),
     item_segment13                  VARCHAR2(40),
     item_segment14                  VARCHAR2(40),
     item_segment15                  VARCHAR2(40),
     item_segment16                  VARCHAR2(40),
     item_segment17                  VARCHAR2(40),
     item_segment18                  VARCHAR2(40),
     item_segment19                  VARCHAR2(40),
     item_segment20                  VARCHAR2(40),
     revision                        VARCHAR2(3) ,
     subinventory                    VARCHAR2(10),
     locator_id                      NUMBER,
     locator_segment1                VARCHAR2(40),
     locator_segment2                VARCHAR2(40),
     locator_segment3                VARCHAR2(40),
     locator_segment4                VARCHAR2(40),
     locator_segment5                VARCHAR2(40),
     locator_segment6                VARCHAR2(40),
     locator_segment7                VARCHAR2(40),
     locator_segment8                VARCHAR2(40),
     locator_segment9                VARCHAR2(40),
     locator_segment10               VARCHAR2(40),
     locator_segment11               VARCHAR2(40),
     locator_segment12               VARCHAR2(40),
     locator_segment13               VARCHAR2(40),
     locator_segment14               VARCHAR2(40),
     locator_segment15               VARCHAR2(40),
     locator_segment16               VARCHAR2(40),
     locator_segment17               VARCHAR2(40),
     locator_segment18               VARCHAR2(40),
     locator_segment19               VARCHAR2(40),
     locator_segment20               VARCHAR2(40),
     lot_number                      VARCHAR2(80), -- INVCONV
     serial_number                   VARCHAR2(30),
     primary_uom_quantity            NUMBER,
     count_uom                       VARCHAR2(3) ,
     count_unit_of_measure           VARCHAR2(25),
     count_quantity                  NUMBER  ,
     system_quantity                 NUMBER      ,
     adjustment_account_id           NUMBER  ,
     account_segment1                VARCHAR2(25),
     account_segment2                VARCHAR2(25),
     account_segment3                VARCHAR2(25),
     account_segment4                VARCHAR2(25),
     account_segment5                VARCHAR2(25),
     account_segment6                VARCHAR2(25),
     account_segment7                VARCHAR2(25),
     account_segment8                VARCHAR2(25),
     account_segment9                VARCHAR2(25),
     account_segment10               VARCHAR2(25),
     account_segment11               VARCHAR2(25),
     account_segment12               VARCHAR2(25),
     account_segment13               VARCHAR2(25),
     account_segment14               VARCHAR2(25),
     account_segment15               VARCHAR2(25),
     account_segment16               VARCHAR2(25),
     account_segment17               VARCHAR2(25),
     account_segment18               VARCHAR2(25),
     account_segment19               VARCHAR2(25),
     account_segment20               VARCHAR2(25),
     account_segment21               VARCHAR2(25),
     account_segment22               VARCHAR2(25),
     account_segment23               VARCHAR2(25),
     account_segment24               VARCHAR2(25),
     account_segment25               VARCHAR2(25),
     account_segment26               VARCHAR2(25),
     account_segment27               VARCHAR2(25),
     account_segment28               VARCHAR2(25),
     account_segment29               VARCHAR2(25),
     account_segment30               VARCHAR2(25),
     count_date                      DATE        ,
     employee_id                     NUMBER  ,
     employee_full_name              VARCHAR2(240),
     reference                       VARCHAR2(240),
     transaction_reason_id           NUMBER  ,
     transaction_reason              VARCHAR2(30),
     request_id                      NUMBER  ,
     program_application_id          NUMBER  ,
     program_id                      NUMBER  ,
     program_update_date             DATE        ,
     lock_flag                       NUMBER(1)   ,
     process_flag                    NUMBER(1)   ,
     process_mode                    NUMBER(1)   ,
     valid_flag                      NUMBER(1)   ,
     delete_flag                     NUMBER(1)   ,
     status_flag                     NUMBER  ,
     error_flag                      NUMBER  ,
     attribute_category              VARCHAR2(30),
     attribute1                      VARCHAR2(150),
     attribute2                      VARCHAR2(150),
     attribute3                      VARCHAR2(150),
     attribute4                      VARCHAR2(150),
     attribute5                      VARCHAR2(150),
     attribute6                      VARCHAR2(150),
     attribute7                      VARCHAR2(150),
     attribute8                      VARCHAR2(150),
     attribute9                      VARCHAR2(150),
     attribute10                     VARCHAR2(150),
     attribute11                     VARCHAR2(150),
     attribute12                     VARCHAR2(150),
     attribute13                     VARCHAR2(150),
     attribute14                     VARCHAR2(150),
     attribute15                     VARCHAR2(150),
     project_id                      NUMBER  ,
     task_id                         NUMBER,
     -- BEGIN INVCONV
     secondary_uom                   VARCHAR2(3),
     secondary_unit_of_measure       VARCHAR2(25),
     secondary_count_quantity        NUMBER,
     secondary_system_quantity       NUMBER
     -- END INVCONV
     );

-- BEGIN INVCONV
G_TRACKING_QUANTITY_IND        MTL_SYSTEM_ITEMS.tracking_quantity_ind%TYPE default null;
G_SECONDARY_DEFAULT_IND        MTL_SYSTEM_ITEMS.secondary_default_ind%TYPE default null;
G_PROCESS_COSTING_ENABLED_FLAG MTL_SYSTEM_ITEMS.process_costing_enabled_flag%TYPE default null;
G_PROCESS_ENABLED_FLAG         MTL_PARAMETERS.process_enabled_flag%TYPE default null;
G_SECONDARY_UOM_CODE           MTL_SYSTEM_ITEMS.secondary_uom_code%TYPE default null;

G_SECONDARY_COUNT_UOM        MTL_SYSTEM_ITEMS.secondary_uom_code%TYPE default null;
G_SECONDARY_COUNT_QUANTITY   MTL_CC_ENTRIES_INTERFACE.SECONDARY_COUNT_QUANTITY%TYPE default null;
G_SECONDARY_SYSTEM_QUANTITY  MTL_CC_ENTRIES_INTERFACE.SECONDARY_SYSTEM_QUANTITY%TYPE default null;
G_LPN_ITEM_SEC_SYSTEM_QTY    NUMBER default null;
G_SEC_ADJUSTMENT_QUANTITY    NUMBER default null;
-- END INVCONV

END MTL_CCEOI_VAR_PVT;

 

/
