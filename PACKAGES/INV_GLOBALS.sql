--------------------------------------------------------
--  DDL for Package INV_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_GLOBALS" AUTHID CURRENT_USER AS
  /* $Header: INVSGLBS.pls 120.1 2005/07/15 05:05:15 ramarava noship $ */

  --  Procedure GET_ENTITIES_TBL;
  --
  --  Used by generator to avoid overriding or duplicating existing
  --  entity constants.
  --
  PROCEDURE GET_ENTITIES_TBL;

  --  Product entity constants.
  G_ORG_ID                               NUMBER           := NULL;
  G_MAX_LINE_NUM                         NUMBER           := NULL;
  G_CALL_MODE                            VARCHAR2(10)     := NULL;

  -- Transaction Types
  G_TYPE_CYCLE_COUNT_ADJ           CONSTANT NUMBER           := 4;
  G_TYPE_CYCLE_COUNT_SUBXFR        CONSTANT NUMBER           := 5;
  G_TYPE_PHYSICAL_COUNT_ADJ        CONSTANT NUMBER           := 8;
  G_TYPE_PHYSICAL_COUNT_SUBXFR     CONSTANT NUMBER           := 9;
  G_TYPE_LOGL_IC_SHIP_RECEIPT      CONSTANT NUMBER           := 10;
  G_TYPE_LOGL_IC_SALES_ISSUE       CONSTANT NUMBER           := 11;
  G_TYPE_LOGL_IC_RECEIPT_RETURN    CONSTANT NUMBER           := 13;
  G_TYPE_LOGL_IC_SALES_RETURN      CONSTANT NUMBER           := 14;
  G_TYPE_LOGL_RMA_RECEIPT          CONSTANT NUMBER           := 16;
  G_TYPE_PO_RECEIPT                CONSTANT NUMBER           := 18;
  G_TYPE_LOGL_PO_RECEIPT           CONSTANT NUMBER           := 19;
  G_TYPE_RETRO_PRICE_UPDATE        CONSTANT NUMBER           := 20;
  G_TYPE_LOGL_IC_PROC_RECEIPT      CONSTANT NUMBER           := 22;
  G_TYPE_LOGL_IC_PROC_RETURN       CONSTANT NUMBER           := 23;
  G_TYPE_LOGL_EXP_REQ_RECEIPT      CONSTANT NUMBER           := 27;
  G_TYPE_LOGL_SALES_ORDER_ISSUE    CONSTANT NUMBER           := 30;
  G_TYPE_XFER_ORDER_WIP_ISSUE      CONSTANT NUMBER           := 35;
  G_TYPE_LOGL_RETURN_TO_VENDOR     CONSTANT NUMBER           := 39;
  G_TYPE_XFER_ORDER_REPL_SUBXFR    CONSTANT NUMBER           := 51;
  G_TYPE_TRANSFER_ORDER_STGXFR     CONSTANT NUMBER           := 52;
  G_TYPE_INTERNAL_ORDER_STGXFR     CONSTANT NUMBER           := 53;
  G_TYPE_TRANSFER_ORDER_ISSUE      CONSTANT NUMBER           := 63;
  G_TYPE_TRANSFER_ORDER_SUBXFR     CONSTANT NUMBER           := 64;
  G_TYPE_LOGL_PO_RECEIPT_ADJ       CONSTANT NUMBER           := 69;
  G_TYPE_INV_LOT_SPLIT             CONSTANT NUMBER           := 82;
  G_TYPE_INV_LOT_MERGE             CONSTANT NUMBER           := 83;
  G_TYPE_INV_LOT_TRANSLATE         CONSTANT NUMBER           := 84;
  G_TYPE_CONTAINER_PACK            CONSTANT NUMBER           := 87;
  G_TYPE_CONTAINER_UNPACK          CONSTANT NUMBER           := 88;
  G_TYPE_CONTAINER_SPLIT           CONSTANT NUMBER           := 89;
  G_TYPE_PO_RCPT_ADJ               CONSTANT NUMBER           := 71;
  G_TYPE_RETURN_TO_VENDOR          CONSTANT NUMBER           := 36;

  -- Transaction Source Types
  G_SOURCETYPE_PURCHASEORDER    CONSTANT NUMBER           := 1;
  G_SOURCETYPE_SALESORDER       CONSTANT NUMBER           := 2;
  G_SOURCETYPE_ACCOUNT          CONSTANT NUMBER           := 3;
  G_SOURCETYPE_MOVEORDER        CONSTANT NUMBER           := 4;
  G_SOURCETYPE_WIP              CONSTANT NUMBER           := 5;
  G_SOURCETYPE_ACCOUNTALIAS     CONSTANT NUMBER           := 6;
  G_SOURCETYPE_INTREQ           CONSTANT NUMBER           := 7;
  G_SOURCETYPE_INTORDER         CONSTANT NUMBER           := 8;
  G_SOURCETYPE_CYCLECOUNT       CONSTANT NUMBER           := 9;
  G_SOURCETYPE_PHYSICALCOUNT    CONSTANT NUMBER           := 10;
  G_SOURCETYPE_STDCOSTUPDATE    CONSTANT NUMBER           := 11;
  G_SOURCETYPE_RMA              CONSTANT NUMBER           := 12;
  G_SOURCETYPE_INVENTORY        CONSTANT NUMBER           := 13;
  G_SOURCETYPE_PERCOSTUPDATE    CONSTANT NUMBER           := 14;
  G_SOURCETYPE_LAYERCOSTUPDATE  CONSTANT NUMBER           := 15;
  G_SOURCETYPE_PRJCONTRACTS     CONSTANT NUMBER           := 16;
  G_SOURCETYPE_EXTREQ           CONSTANT NUMBER           := 17;

  -- Transaction Actions
  G_ACTION_ISSUE                CONSTANT NUMBER           := 1;
  G_ACTION_SUBXFR               CONSTANT NUMBER           := 2;
  G_ACTION_ORGXFR               CONSTANT NUMBER           := 3;
  G_ACTION_CYCLECOUNTADJ        CONSTANT NUMBER           := 4;
  G_ACTION_PLANXFR              CONSTANT NUMBER           := 5;
  G_ACTION_OWNXFR               CONSTANT NUMBER           := 6;
  G_ACTION_LOGICALISSUE         CONSTANT NUMBER           := 7;
  G_ACTION_PHYSICALCOUNTADJ     CONSTANT NUMBER           := 8;
  G_ACTION_LOGICALICSALES       CONSTANT NUMBER           := 9;
  G_ACTION_LOGICALICRECEIPT     CONSTANT NUMBER           := 10;
  G_ACTION_LOGICALDELADJ        CONSTANT NUMBER           := 11;
  G_ACTION_INTRANSITRECEIPT     CONSTANT NUMBER           := 12;
  G_ACTION_LOGICALICRCPTRETURN  CONSTANT NUMBER           := 13;
  G_ACTION_LOGICALICSALESRETURN CONSTANT NUMBER           := 14;
  G_ACTION_LOGICALEXPREQRECEIPT CONSTANT NUMBER           := 17;
  G_ACTION_INTRANSITSHIPMENT    CONSTANT NUMBER           := 21;
  G_ACTION_COSTUPDATE           CONSTANT NUMBER           := 24;
  G_ACTION_RETROPRICEUPDATE     CONSTANT NUMBER           := 25;
  G_ACTION_LOGICALRECEIPT       CONSTANT NUMBER           := 26;
  G_ACTION_RECEIPT              CONSTANT NUMBER           := 27;
  G_ACTION_STGXFR               CONSTANT NUMBER           := 28;
  G_ACTION_DELIVERYADJ          CONSTANT NUMBER           := 29;
  G_ACTION_WIPSCRAP             CONSTANT NUMBER           := 30;
  G_ACTION_ASSYCOMPLETE         CONSTANT NUMBER           := 31;
  G_ACTION_ASSYRETURN           CONSTANT NUMBER           := 32;
  G_ACTION_NEGCOMPISSUE         CONSTANT NUMBER           := 33;
  G_ACTION_NEGCOMPRETURN        CONSTANT NUMBER           := 34;
  G_ACTION_INV_LOT_SPLIT        CONSTANT NUMBER           := 40;
  G_ACTION_INV_LOT_MERGE        CONSTANT NUMBER           := 41;
  G_ACTION_INV_LOT_TRANSLATE    CONSTANT NUMBER           := 42;
  G_ACTION_CONTAINERPACK        CONSTANT NUMBER           := 50;
  G_ACTION_CONTAINERUNPACK      CONSTANT NUMBER           := 51;
  G_ACTION_CONTAINERSPLIT       CONSTANT NUMBER           := 52;
  G_ACTION_COSTGROUPXFR         CONSTANT NUMBER           := 55;

  --  GEN entities
  G_ENTITY_ALL                  CONSTANT VARCHAR2(30)     := 'ALL';
  G_ENTITY_TROHDR               CONSTANT VARCHAR2(30)     := 'TROHDR';
  G_ENTITY_TROLIN               CONSTANT VARCHAR2(30)     := 'TROLIN';

  G_MATERIAL_STATUS_ACTIVE      CONSTANT NUMBER           := 1;

  -- Move order types
  G_MOVE_ORDER_REQUISITION      CONSTANT NUMBER           := 1;
  G_MOVE_ORDER_REPLENISHMENT    CONSTANT NUMBER           := 2;
  G_MOVE_ORDER_PICK_WAVE        CONSTANT NUMBER           := 3;
  G_MOVE_ORDER_RECEIPT          CONSTANT NUMBER           := 4;
  G_MOVE_ORDER_MFG_PICK         CONSTANT NUMBER           := 5;
  G_MOVE_ORDER_WIP_ISSUE        CONSTANT NUMBER           := 5;
  G_MOVE_ORDER_PUT_AWAY         CONSTANT NUMBER           := 6;
  G_MOVE_ORDER_BACKFLUSH        CONSTANT NUMBER           := 7;
  G_MOVE_ORDER_SYSTEM           CONSTANT NUMBER           := 8;

  -- Move Order Status
  G_TO_STATUS_INCOMPLETE        CONSTANT NUMBER           := 1;
  G_TO_STATUS_PENDING_APPROVAL  CONSTANT NUMBER           := 2;
  G_TO_STATUS_APPROVED          CONSTANT NUMBER           := 3;
  G_TO_STATUS_REJECTED          CONSTANT NUMBER           := 4;
  G_TO_STATUS_CLOSED            CONSTANT NUMBER           := 5;
  G_TO_STATUS_CANCELLED         CONSTANT NUMBER           := 6;
  G_TO_STATUS_PREAPPROVED       CONSTANT NUMBER           := 7;
  G_TO_STATUS_PART_APPROVED     CONSTANT NUMBER           := 8;
  G_TO_STATUS_CANCEL_BY_SOURCE  CONSTANT NUMBER           := 9;

  -- SubInventory Flags
  G_SUBINVENTORY_RESERVABLE     CONSTANT NUMBER           := 1;
  G_SUBINVENTORY_NON_RESERVABLE CONSTANT NUMBER           := 2;
  G_SUBINVENTORY_LPN_CONTROLLED CONSTANT NUMBER           := 1;

  --  Operations.
  G_OPR_CREATE                  CONSTANT VARCHAR2(30)     := 'CREATE';
  G_OPR_UPDATE                  CONSTANT VARCHAR2(30)     := 'UPDATE';
  G_OPR_DELETE                  CONSTANT VARCHAR2(30)     := 'DELETE';
  G_OPR_LOCK                    CONSTANT VARCHAR2(30)     := 'LOCK';
  G_OPR_NONE                    CONSTANT VARCHAR2(30)     := chr(0);

  -- Locator Types
  G_LOC_TYPE_DOCK_DOOR          CONSTANT NUMBER           := 1;
  G_LOC_TYPE_STAGING_LANE       CONSTANT NUMBER           := 2;
  G_LOC_TYPE_STORAGE_LOC        CONSTANT NUMBER           := 3;
  G_LOC_TYPE_CONSOLIDATION      CONSTANT NUMBER           := 4;
  G_LOC_TYPE_PACKING_STATION    CONSTANT NUMBER           := 5;

  --  Max number of defaulting tterations.
  G_MAX_DEF_ITERATIONS          CONSTANT NUMBER           := 5;

  -- DONT USE THIS CONTANT. Its already defined in Source Types section.
  G_SOURCE_TYPE_TRANSFER_ORDERS CONSTANT NUMBER           := 4;

  --  Index table type used by JVC controllers.
  TYPE INDEX_TBL_TYPE IS TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;

  --  API Operation control flags.
  TYPE CONTROL_REC_TYPE IS RECORD(
    CONTROLLED_OPERATION          BOOLEAN  := FALSE
  , DEFAULT_ATTRIBUTES            BOOLEAN  := TRUE
  , CHANGE_ATTRIBUTES             BOOLEAN  := TRUE
  , VALIDATE_ENTITY               BOOLEAN  := TRUE
  , WRITE_TO_DB                   BOOLEAN  := TRUE
  , PROCESS                       BOOLEAN  := TRUE
  , PROCESS_ENTITY                VARCHAR2(30)  := G_ENTITY_ALL
  , CLEAR_API_CACHE               BOOLEAN  := TRUE
  , CLEAR_API_REQUESTS            BOOLEAN  := TRUE
  , REQUEST_CATEGORY              VARCHAR2(30)  := NULL
  , REQUEST_NAME                  VARCHAR2(30)  := NULL);

  --  Variable representing missing control record.
  G_MISS_CONTROL_REC                     CONTROL_REC_TYPE;

  --  API request record type.
  TYPE REQUEST_REC_TYPE IS RECORD(
    ENTITY                        VARCHAR2(30)  := NULL
  , STEP                          VARCHAR2(30)  := NULL
  , NAME                          VARCHAR2(30)  := NULL
  , CATEGORY                      VARCHAR2(30)  := NULL
  , PROCESSED                     BOOLEAN  := FALSE
  , ATTRIBUTE1                    VARCHAR2(240)  := NULL
  , ATTRIBUTE2                    VARCHAR2(240)  := NULL
  , ATTRIBUTE3                    VARCHAR2(240)  := NULL
  , ATTRIBUTE4                    VARCHAR2(240)  := NULL
  , ATTRIBUTE5                    VARCHAR2(240)  := NULL);

  --  API Request table type.
  TYPE REQUEST_TBL_TYPE IS TABLE OF REQUEST_REC_TYPE
    INDEX BY BINARY_INTEGER;

  --  Generic table types
  TYPE BOOLEAN_TBL_TYPE IS TABLE OF BOOLEAN
    INDEX BY BINARY_INTEGER;

  TYPE NUMBER_TBL_TYPE IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(30)
     INDEX BY BINARY_INTEGER;

  --  Variable representing a missing table.
  G_MISS_BOOLEAN_TBL BOOLEAN_TBL_TYPE;
  G_MISS_NUMBER_TBL  NUMBER_TBL_TYPE;
  G_MISS_VARCHAR_TBL VARCHAR_TBL_TYPE;

  FUNCTION IS_ISSUE_XFR_TRANSACTION(P_TRANSACTION_ACTION_ID IN NUMBER)
    RETURN BOOLEAN;

  --  Initialize control record.

  FUNCTION INIT_CONTROL_REC(P_OPERATION IN VARCHAR2, P_CONTROL_REC IN CONTROL_REC_TYPE)
    RETURN CONTROL_REC_TYPE;

  --  Function Equal
  --  Number comparison.

  FUNCTION EQUAL(P_ATTRIBUTE1 IN NUMBER, P_ATTRIBUTE2 IN NUMBER)
    RETURN BOOLEAN;

  --  Varchar2 comparison.

  FUNCTION EQUAL(P_ATTRIBUTE1 IN VARCHAR2, P_ATTRIBUTE2 IN VARCHAR2)
    RETURN BOOLEAN;

  --  Date comparison.

  FUNCTION EQUAL(P_ATTRIBUTE1 IN DATE, P_ATTRIBUTE2 IN DATE)
    RETURN BOOLEAN;

  PROCEDURE SET_ORG_ID(P_ORG_ID IN NUMBER);

  -- It sets the organization id in the server profile to this
  -- new value so that PJM can use it appropriately to get the
  -- projects segments of the locator.
  PROCEDURE SET_PJM_ORG_ID(ORGANIZATION_ID IN NUMBER);

  FUNCTION NO_NEG_ALLOWED(P_RESTRICT_FLAG IN NUMBER, P_NEG_FLAG IN NUMBER, P_ACTION IN NUMBER)
    RETURN BOOLEAN;

  FUNCTION LOCATOR_CONTROL(
    X_RETURN_STATUS     OUT    NOCOPY VARCHAR2
  , X_MSG_COUNT         OUT    NOCOPY NUMBER
  , X_MSG_DATA          OUT    NOCOPY VARCHAR2
  , P_ORG_CONTROL       IN     NUMBER
  , P_SUB_CONTROL       IN     NUMBER
  , P_ITEM_CONTROL      IN     NUMBER
  , P_ITEM_LOC_RESTRICT IN     NUMBER
  , P_ORG_NEG_ALLOWED   IN     NUMBER
  , P_ACTION            IN     NUMBER
  )
    RETURN NUMBER;

  --
  -- PURPOSE
  --    In R12 the LE - OU link will be broken
  --    There are some places where the SOB is derived using this link. In all these places the SOB needs
  --    to be derived using the direct linkage of Inventory Org and Ledger if Inventory Organization ID is
  --    known, otherwise if Operating Unit is knowng the linkage of Operating Unit and Leger is to be used.
  --    For this purpose following two procedures are added to this package
  --      1. GET_COA_LEDGER_ID
  --      2. GET_LEDGER_INFO
  --
  --    These program is a New Supporting routine that returns the Chart of Accounts or Set of Books for a
  --    given Legal Entity or or Operating Unit or an Inventory Org.
  --
  --
  -- PRIVATE PROCEDURE
  --
  -- ARGUMENTS
  --
  --   X_return_Status                 Returns 1 if the procedure is successful otherwise returns 0
  --
  --   X_msg_data                      Returns the error message if the "X_return_Status" is 0
  --
  --   P_Account_Info_Context          This parameter indicates if for a given context Chart of
  --                                   Accounts is required or Set of books is required or both
  --                                   of them is required. Valid values for this parameter are:
  --                                   SOB  -> To get the Set of Books ID/Ledger ID
  --                                   COA  -> To get the Chart of Accounts ID
  --                                   BOTH -> To get both SOB and COA ids
  --
  --   P_ENTITY_CONTEXT                This parameter determines the Accounting Context stored
  --                                   for Legal Entities, Operating Units and Inventory
  --                                   Organizations.Valid Values are:
  --                                   Legal Entity Accounting    -> For LE
  --                                   Operating Unit Information -> For OU
  --                                   Accounting Information     -> For Inv Org
  --
  --   P_Org_Id                        This parameter will be the organization id of legal entity
  --                                   or operating unit or inventory org depending on the value
  --                                   passed in P_Context_Type parameter
  --
  --   X_ACCOUNT_INFO1                 This parameter returns the Org_Information1 of
  --                                   Hr_Organizaiton_Informaiton for the
  --                                   Organizaiton ID passed.
  --
  --   X_ACCOUNT_INFO3                 This parameter returns the Org_Information3 of
  --                                   Hr_Organizaiton_Informaiton for the
  --                                   Organizaiton ID passed.
  --
  --   X_COA_ID                        This Parameter will contain the Chart of Accounts for an
  --                                   operating unit or Legal Entity or Inventory Org depding
  --                                   on the value passed in P_Context_Type parameter
  --
  -- HISTORY
  --
  --   Created by: Karthik Sambasivam          Date : 22-Apr-2005
  --
  --   CHANGES
  --   WHO                     WHEN            WHAT
  --
  /*PROCEDURE GET_COA_LEDGER_ID
    (X_return_status         OUT   NOCOPY VARCHAR2,
     X_msg_data              OUT   NOCOPY VARCHAR2,
     P_Account_Info_Context  IN    VARCHAR2,
     P_ENTITY_CONTEXT        IN    VARCHAR2,
     P_Org_Id                IN    NUMBER,
     X_ACCOUNT_INFO1         OUT   NOCOPY NUMBER,
     X_ACCOUNT_INFO3         OUT   NOCOPY NUMBER,
     X_COA_ID                OUT   NOCOPY NUMBER
    );*/
  --
  -- PUBLIC PROCEDURE
  --
  -- ARGUMENTS
  --
  --   X_return_Status                 Returns 1 if the procedure is successful otherwise returns 0
  --
  --   X_msg_data                      Returns the error message if the "X_return_Status" is 0
  --
  --   P_Context_Type                  This parameter specifies the type of Org_Id passed. The valid
  --                                   values for this parameter are:
  --                                   LE  -> Legal Entity
  --                                   OU  -> Operating Unit
  --                                   IO  -> Inventory Organization
  --
  --   P_Org_Id                        This Parameter will contain the Ledger ID for an operating
  --                                   unit or Legal Entity or Inventory Org depding on the value
  --                                   passed in P_Context_Type parameter
  --
  --   X_SOB_ID                        This Parameter will contain the Ledger ID for an operating
  --                                   unit or Legal Entity or Inventory Org depding on the value
  --                                   passed in P_Context_Type parameter
  --
  --   X_COA_ID                        This Parameter will contain the Chart of Accounts for an
  --                                   operating unit or Legal Entity or Inventory Org depding on
  --                                   the value passed in P_Context_Type parameter
  --
  --   P_Account_Info_Context          This parameter indicates if for a given context Chart of
  --                                   Accounts is required or Set of books is required or both
  --                                   of them is required. Valid values for this parameter are:
  --                                   SOB  -> To get the Set of Books ID/Ledger ID
  --                                   COA  -> To get the Chart of Accounts ID
  --                                   BOTH -> To get both SOB and COA ids.
  --
  -- HISTORY
  --
  --   Created by: Karthik Sambasivam          Date : 22-Apr-2005
  --
  --   CHANGES
  --   WHO                     WHEN            WHAT
  --
  PROCEDURE GET_LEDGER_INFO
    (X_return_status         OUT   NOCOPY VARCHAR2,
     X_msg_data              OUT   NOCOPY VARCHAR2,
     P_Context_Type          IN    VARCHAR2,
     P_Org_Id                IN    NUMBER,
     X_SOB_ID                OUT   NOCOPY NUMBER,
     X_COA_ID                OUT   NOCOPY NUMBER,
     P_Account_Info_Context  IN    VARCHAR2 DEFAULT 'SOB'
    );

END INV_GLOBALS;

 

/
