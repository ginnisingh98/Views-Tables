--------------------------------------------------------
--  DDL for Package OE_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: OEXSGLBS.pls 120.15.12010000.11 2011/02/24 02:30:17 snimmaga ship $ */

G_LANG     VARCHAR2(4)   := USERENV('LANG');
G_LANGUAGE VARCHAR2(255) := USERENV('LANGUAGE');
G_SYSDATE  DATE          := SYSDATE;

--  Procedure Get_Entities_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  entity constants.
--
--  DO NOT MODIFY

PROCEDURE Get_Entities_Tbl;

--  Product entity constants.
-- Partial Validation Level. This might go away when moved to FND_API
G_VALID_LEVEL_PARTIAL  CONSTANT    NUMBER := 50;
-- Partial Validation Level with def.
G_VALID_PARTIAL_WITH_DEF  CONSTANT NUMBER := 75;
-- Global Variable to hold ORG
G_ORG_ID		       NUMBER;

--  START GEN entities
-- bug 6817566
G_MANUAL_ADV_MODIFIER         VARCHAR2(1) := NULL;


G_ENTITY_ALL                   CONSTANT VARCHAR2(30) := 'ALL';
G_ENTITY_COMMIT		       CONSTANT VARCHAR2(30) := 'COMMIT';

/* Order Object Entities: Begin */
G_ENTITY_HEADER                CONSTANT VARCHAR2(30) := 'HEADER';
G_ENTITY_HEADER_ADJ            CONSTANT VARCHAR2(30) := 'HEADER_ADJ';
G_ENTITY_HEADER_PRICE_ATT      CONSTANT VARCHAR2(30) := 'HEADER_PATT';
G_ENTITY_HEADER_ADJ_ATT        CONSTANT VARCHAR2(30) := 'HEADER_AATT';
G_ENTITY_HEADER_ADJ_ASSOC      CONSTANT VARCHAR2(30) := 'HEADER_ASSOC';
G_ENTITY_HEADER_SCREDIT        CONSTANT VARCHAR2(30) := 'HEADER_SCREDIT';
G_ENTITY_LINE                  CONSTANT VARCHAR2(30) := 'LINE';
G_ENTITY_LINE_ADJ              CONSTANT VARCHAR2(30) := 'LINE_ADJ';
G_ENTITY_LINE_PRICE_ATT        CONSTANT VARCHAR2(30) := 'LINE_PATT';
G_ENTITY_LINE_ADJ_ATT          CONSTANT VARCHAR2(30) := 'LINE_AATT';
G_ENTITY_LINE_ADJ_ASSOC        CONSTANT VARCHAR2(30) := 'LINE_ASSOC';
G_ENTITY_LINE_SCREDIT          CONSTANT VARCHAR2(30) := 'LINE_SCREDIT';
G_ENTITY_LOT_SERIAL            CONSTANT VARCHAR2(30) := 'LOT_SERIAL';
G_ENTITY_RESERVATION           CONSTANT VARCHAR2(30) := 'RESERVATION';
G_ENTITY_HEADER_PAYMENT        CONSTANT VARCHAR2(30) := 'HEADER_PAYMENT';
G_ENTITY_LINE_PAYMENT          CONSTANT VARCHAR2(30) := 'LINE_PAYMENT';
/* Order Object Entities: End */

/* Pricing Contract Object Entities: Begin */
G_ENTITY_CONTRACT              CONSTANT VARCHAR2(30) := 'CONTRACT';
G_ENTITY_AGREEMENT             CONSTANT VARCHAR2(30) := 'AGREEMENT';
G_ENTITY_PRICE_LHEADER         CONSTANT VARCHAR2(30) := 'PRICE_LHEADER';
G_ENTITY_DISCOUNT_HEADER       CONSTANT VARCHAR2(30) := 'DISCOUNT_HEADER';
G_ENTITY_PRICE_LLINE           CONSTANT VARCHAR2(30) := 'PRICE_LLINE';
G_ENTITY_DISCOUNT_CUST         CONSTANT VARCHAR2(30) := 'DISCOUNT_CUST';
G_ENTITY_DISCOUNT_LINE         CONSTANT VARCHAR2(30) := 'DISCOUNT_LINE';
G_ENTITY_PRICE_BREAK           CONSTANT VARCHAR2(30) := 'PRICE_BREAK';
/* Pricing Contract Object Entities: End */

/* Charge Object Entities: Begin */
G_ENTITY_CHARGE_LINE	       CONSTANT VARCHAR2(30) := 'CHARGE_LINE';
/* Charge Object Entities: End   */

/* Customer and Item Settings object: Begin */
G_ENTITY_CUST_ITEM_SET		CONSTANT VARCHAR2(30) := 'CUST_ITEM_SET';
/* Customer and Item Settings object: End */
--  END GEN entities

-- following constants are used to debug lock_order,
-- please do not use them for any other purpose.

G_LOCK_TEST                     VARCHAR2(1):= 'N';
G_LOCK_CONST                    NUMBER := 0;

--  Operations.
G_OPR_INSERT        CONSTANT    VARCHAR2(30) := 'INSERT';
G_OPR_CREATE	    CONSTANT	VARCHAR2(30) := 'CREATE';
G_OPR_UPDATE	    CONSTANT	VARCHAR2(30) := 'UPDATE';
G_OPR_DELETE	    CONSTANT	VARCHAR2(30) := 'DELETE';
G_OPR_LOCK	        CONSTANT	VARCHAR2(30) := 'LOCK';
G_OPR_NONE	        CONSTANT	VARCHAR2(30) := FND_API.G_MISS_CHAR;
G_OPR_DISCONTINUE  CONSTANT     VARCHAR2(30) := 'DISCONTINUE';

-- for 5331980 start
G_CALCULATE_LINE_TOTAL BOOLEAN := TRUE;
-- for 5331980 end

--  OE Item Types.
G_ITEM_MODEL        CONSTANT    VARCHAR2(30) := 'MODEL';
G_ITEM_STANDARD     CONSTANT    VARCHAR2(30) := 'STANDARD';
G_ITEM_INCLUDED     CONSTANT    VARCHAR2(30) := 'INCLUDED';
G_ITEM_CONFIG       CONSTANT    VARCHAR2(30) := 'CONFIG';
G_ITEM_CLASS        CONSTANT    VARCHAR2(30) := 'CLASS';
G_ITEM_OPTION       CONSTANT    VARCHAR2(30) := 'OPTION';
G_ITEM_KIT          CONSTANT    VARCHAR2(30) := 'KIT';
G_ITEM_SERVICE      CONSTANT    VARCHAR2(30) := 'SERVICE';

--  Included Item Freeze Methods
G_IIFM_ENTRY         CONSTANT    VARCHAR2(30)  := 'ENTRY';
G_IIFM_BOOKING       CONSTANT    VARCHAR2(30)  := 'BOOKING';
G_IIFM_PICK_RELEASE  CONSTANT    VARCHAR2(30)  := 'PICK RELEASE';

-- OE Source Types
G_SOURCE_EXTERNAL    CONSTANT    VARCHAR2(30) := 'EXTERNAL';
G_SOURCE_INTERNAL    CONSTANT    VARCHAR2(30) := 'INTERNAL';

-- OE Order Sources
G_ORDER_SOURCE_COPY     CONSTANT    NUMBER       := 2;
G_ORDER_SOURCE_EDI      CONSTANT    NUMBER       := 6;
G_ORDER_SOURCE_INTERNAL CONSTANT    NUMBER       := 10;

--  OE Set Types.
G_SET_SHIP	     CONSTANT    VARCHAR2(30) := 'SHIP';
G_SET_DELIVERY	     CONSTANT    VARCHAR2(30) := 'DELIVERY';
G_SET_INVOICE	     CONSTANT    VARCHAR2(30) := 'INVOICE';
G_SET_FULFILL	     CONSTANT    VARCHAR2(30) := 'FULFILL';

-- Changes for Line Set Enhancements
G_ADD_FULFILLMENT_SET      CONSTANT VARCHAR2(30) :=  'ADD_FULFILLMENT_SET';
G_REMOVE_FULFILLMENT_SET   CONSTANT VARCHAR2(30) :=  'REMOVE_FULFILLMENT_SET';

-- Values for API Service Level argument in the group API (OEXGORDS/B.pls)
G_ALL_SERVICE	    		CONSTANT	VARCHAR2(30) 	:= 'ALL';
G_CHECK_SECURITY_ONLY	CONSTANT	VARCHAR2(30)	:= 'CHECK_SECURITY_ONLY';
G_VALIDATION_ONLY		CONSTANT	VARCHAR2(30)	:= 'VALIDATION_ONLY';

-- Delayed Requests for Enhanced Drop Shipments
G_DROPSHIP_CMS            CONSTANT  Varchar2(30) := 'DROPSHIP_CMS';


-- added for bug 3636884, for group API calls, default the reason code,
-- unless called by order import (also added control_rec.require_reason)
G_DEFAULT_REASON BOOLEAN := FALSE;

-- added to determine when to use created_by context when retrieving profiles
G_FLOW_RESTARTED BOOLEAN := FALSE;
G_USE_CREATED_BY_CONTEXT BOOLEAN := FALSE;


/* Start Audit Trail */
-- Flag to determine if the change in the entity requires reason
-- for auditing purposes.
G_AUDIT_REASON_RQD_FLAG  VARCHAR2(1)    := 'N';
G_AUDIT_HISTORY_RQD_FLAG  VARCHAR2(1)    := 'N';
/* End Audit Trail */

/* Start Versioning */
G_ROLL_VERSION VARCHAR2(2) := 'N';
G_CAPTURED_REASON VARCHAR2(1) := 'N';
G_REASON_TYPE VARCHAR2(30) := NULL; --added for bug 3625599
G_REASON_CODE VARCHAR2(30) := NULL;
G_REASON_COMMENTS VARCHAR2(2000) := NULL;
G_VERSION_AUDIT VARCHAR2(30) := 'VERSION_AUDIT';
/* End Versioning */

-- Flag to de-activate recursion in process order: used by sets,
-- Configurations, Splits etc.
G_RECURSION_MODE		VARCHAR2(1) 	:= 'N';

-- Flag set by the sales order form to indicate to process order API that
-- the caller is UI
G_UI_FLAG				BOOLEAN	:= FALSE;

-- This flag would be used by callers of the process order API to
-- find out whether the process order call resulted in cascading the
-- changes to other records/entities that were not directly operated on.
-- For e.g. cascading quantity changes on model lines to option classes
-- /option lines
-- This is set to TRUE when a cascading delayed request is LOGGED.
-- It is upto the caller to reset the flag back to FALSE after checking the
-- value. For e.g. the sales order form would check this value after
-- a call to process order and if TRUE,a message is displayed asking the user
-- if he/she wants to re-query so that changes to all the cascaded records are
-- displayed. If the changes are queried, the flag needs to be reset to FALSE
G_CASCADING_REQUEST_LOGGED    BOOLEAN   := FALSE;


-- this flag will be used to requery the lines/headers block
-- if any of lines/header change occurs through the call of process_objects
-- i.e. after validate and write. We need to refresh the block with
-- the changes happend in delayed req. execution.
-- is set to true in process_objects in oOEXFHDRB.pls and based
-- on it being true, we set the G_CASCADING_REQUEST_LOGGED  to true
-- in OEXVREQB.pls in process_request_pvt.

G_PROCESS_OBJECTS_FLAG    BOOLEAN   := FALSE;

-- Delayed Request Entity Types
G_DREQ_HEADER      CONSTANT Varchar2(30) := 'HEADER';
G_DREQ_LINE        CONSTANT Varchar2(30) := 'LINE';

-- DELAYED REQUEST TYPES
G_FTE_REINVOKE             VARCHAR2(1) := 'N';
G_DELETE_CHARGES           CONSTANT        VARCHAR2(30):= 'DELETE_CHARGES';
G_PRICE_LINE		CONSTANT	VARCHAR2(30) := 'PRICE_LINE';
G_PRICE_ORDER       CONSTANT  VARCHAR2(30) := 'PRICE_ORDER';
G_PRICE_ADJ		CONSTANT	VARCHAR2(30) := 'PRICE_ADJ';
G_COPY_ADJUSTMENTS  CONSTANT  VARCHAR2(30) := 'COPY_ADJUSTMENTS';
G_COPY_FREIGHT_CHARGES      CONSTANT  VARCHAR2(30) := 'COPY_FREIGHT_CHARGES';
/* Added the following line to fix the bug 2170086 */
G_COPY_HEADER_ADJUSTMENTS CONSTANT  VARCHAR2(30) := 'COPY_HEADER_ADJUSTMENTS';
G_TAX_LINE		CONSTANT	VARCHAR2(30) := 'TAX_LINE';
G_PRICE_FLAG	               VARCHAR2(30);
G_PRICING_RECURSION		     VARCHAR2(1) := 'N';
G_TAX_FLAG                    VARCHAR2(30);
G_CHANGE_CFG_FLAG             VARCHAR2(1) := 'Y';
G_COPY_PRICING_ATTRIBUTES  CONSTANT  VARCHAR2(30) := 'COPY_PRICING_ATTRIBUTES';
G_COPY_MODEL_PATTR  CONSTANT  VARCHAR2(30) := 'COPY_MODEL_PATTR';
G_DEL_CHG_LINES     VARCHAR2(30) := 'DEL_CHG_LINES';
G_REVERSE_LIMITS    CONSTANT  VARCHAR2(30) := 'REVERSE_LIMITS';  -- BUG 2013611
G_FREIGHT_FOR_INCLUDED CONSTANT  VARCHAR2(30) := 'FREIGHT_FOR_INCLUDED';
G_MARGIN_HOLD    CONSTANT VARCHAR2(12):='MARGIN_HOLD';
G_GET_COST CONSTANT VARCHAR2(8) := 'GET_COST';
G_FREIGHT_RATING CONSTANT  VARCHAR2(30) := 'FREIGHT_RATING';
G_GET_FREIGHT_RATES CONSTANT  VARCHAR2(30) := 'GET_FREIGHT_RATES';
G_GET_SHIP_METHOD_AND_RATES CONSTANT  VARCHAR2(30) := 'GET_SHIP_METHOD_AND_RATES';

G_DR_COPY_OTM_RECORDS  CONSTANT  VARCHAR2(30) := 'DR_COPY_OTM_RECORDS'; --BUG#10052614

-- Delayed requests for Payments
G_CALCULATE_COMMITMENT  CONSTANT  VARCHAR2(30) := 'CALCULATE_COMMITMENT';
G_UPDATE_COMMITMENT  CONSTANT  VARCHAR2(30) := 'UPDATE_COMMITMENT';
G_UPDATE_COMMITMENT_APPLIED  CONSTANT  VARCHAR2(30) := 'UPDATE_COMMITMENT_APPLIED';
G_COMMITMENT_BALANCE	NUMBER;
G_ORIGINAL_COMMITMENT_APPLIED	NUMBER;
G_SPLIT_PAYMENT CONSTANT        VARCHAR2(30)    := 'SPLIT_PAYMENT';
G_UPDATE_HDR_PAYMENT CONSTANT   VARCHAR2(30)    := 'UPD_HDR_PAYMENT';
G_APPLY_PPP_HOLD CONSTANT VARCHAR2(30) := 'APPLY_PPP_HOLD';
G_PROCESS_PAYMENT CONSTANT VARCHAR2(30) := 'PROCESS_PAYMENT';
G_DELETE_PAYMENT_HOLD CONSTANT VARCHAR2(30) := 'DELETE_PAYMENT_HOLD';
G_DELETE_PAYMENTS CONSTANT VARCHAR2(30) := 'DELETE_PAYMENTS'; --R12 CC Encryption
G_CALLING_SOURCE VARCHAR2(5) := 'WSH';  --8478151

--RT{
G_COPY_RETROBILL_ADJ VARCHAR2(30):='COPY_RETROBILLING_ADJUSTMENTS';
--RT}

-- pricing header / line level adjustments
G_PROCESS_ADJUSTMENTS CONSTANT VARCHAR2(30) := 'PROCESS_ADJUSTMENTS';

-- check max percentage on price adjustments
G_CHECK_PERCENTAGE	CONSTANT	VARCHAR2(30) := 'CHECK_PERCENTAGE';

-- check the duplication of a discount
G_CHECK_DUPLICATE	CONSTANT	VARCHAR2(30) := 'CHECK_DUPLICATE';

-- check the application of a price discount
G_CHECK_FIXED_PRICE	CONSTANT	VARCHAR2(30) := 'CHECK_FIXED_PRICE';

-- Delayed Request for Holds
G_APPLY_HOLD		CONSTANT	VARCHAR2(30) := 'APPLY_HOLD';
G_RELEASE_HOLD		CONSTANT	VARCHAR2(30) := 'RELEASE_HOLD';

-- Delayed request for Holds when a line splits
G_SPLIT_HOLD             CONSTANT        VARCHAR2(30) := 'SPLIT_HOLD';

-- Delayed Request for Sales Credits
G_CHECK_HSC_QUOTA_TOTAL   CONSTANT  Varchar2(30) := 'CHECK_HSC_QUOTA_TOTAL';
G_CHECK_LSC_QUOTA_TOTAL   CONSTANT  Varchar2(30) := 'CHECK_LSC_QUOTA_TOTAL';
G_CASCADE_SERVICE_SCREDIT CONSTANT  Varchar2(30) := 'CASCADE_SERVICE_SCREDIT';
G_DFLT_HSCREDIT_FOR_SREP  CONSTANT  Varchar2(30) := 'DFLT_HSCREDIT_FOR_SREP';

G_CREATE_SETS             CONSTANT  Varchar2(30) := 'CREATE_SETS';
G_VALIDATE_LINE_SET       CONSTANT  Varchar2(30) := 'VALIDATE_SET';
G_SPLIT_SET_CHK           CONSTANT  Varchar2(30) := 'SPLIT_SET';
G_CREATE_RESERVATIONS     CONSTANT  Varchar2(30) := 'CREATE_RESERVATIONS';
G_INSERT_INTO_SETS        CONSTANT  Varchar2(30) := 'INSERT_INTO_SETS';
G_SCHEDULE_LINE           CONSTANT  Varchar2(30) := 'SCHEDULE_LINE';
G_RESCHEDULE_LINE         CONSTANT  Varchar2(30) := 'RESCHEDULE_LINE';
G_SCHEDULE_SMC            CONSTANT  Varchar2(30) := 'SCHEDULE_SMC';
G_SCHEDULE_ATO            CONSTANT  Varchar2(30) := 'SCHEDULE_ATO';
/* Added the following line to fix the bug 6663462 */
G_DELAYED_SCHEDULE        CONSTANT  Varchar2(30) := 'DELAYED_SCHEDULE';


G_SCHEDULE_NONSMC         CONSTANT  Varchar2(30) := 'SCHEDULE_NONSMC';
G_CASCADE_SHIP_SET_ATTR   CONSTANT  Varchar2(30) := 'CASCADE_SHIP_SET_ATTR';

-- Delayed Request/ Actions for ATO/PTO Models
G_INS_INCLUDED_ITEMS      CONSTANT  Varchar2(30) := 'INS_INCLUDED_ITEMS';
G_CREATE_CONFIG_ITEM      CONSTANT  Varchar2(30) := 'CREATE_CONFIG_ITEM';
G_CASCADE_CHANGES         CONSTANT  Varchar2(30) := 'CASCADE_CHANGES ';
G_CHANGE_CONFIGURATION    CONSTANT  Varchar2(30) := 'CHG_CONFIGURATION ';
G_CASCADE_QUANTITY        CONSTANT  Varchar2(30) := 'CASCADE_QUANTITY';
G_CASCADE_PROJECT         CONSTANT  Varchar2(30) := 'G_CASCADE_PROJECT';
G_CASCADE_TASK            CONSTANT  Varchar2(30) := 'G_CASCADE_TASK';
G_COPY_CONFIGURATION      CONSTANT  Varchar2(30) := 'COPY_CONFIGURATION';
G_COMPLETE_CONFIGURATION  CONSTANT  Varchar2(30) := 'COMPLETE_CONFIGURATION';
G_VALIDATE_CONFIGURATION  CONSTANT  Varchar2(30) := 'VALIDATE_CONFIGURATION';
G_MATCH_AND_RESERVE       CONSTANT  Varchar2(30) := 'MATCH_AND_RESERVE';
G_DELINK_CONFIG           CONSTANT  Varchar2(30) := 'DELINK_CONFIG';
G_LINK_CONFIG             CONSTANT  Varchar2(30) := 'LINK_CONFIG';
G_DELETE_OPTION           CONSTANT  Varchar2(30) := 'DELETE_OPTION';
G_UPDATE_OPTION           CONSTANT  Varchar2(30) := 'UPDATE_OPTION';
G_CTO_NOTIFICATION        CONSTANT  Varchar2(30) := 'CTO_NOTIFICATION';
G_CTO_CHANGE              CONSTANT  Varchar2(30) := 'CTO_CHANGE';
-- G_SYS_HOLD is used to distinguish if system hold is applied by USER or SYSTEM(TRUE) --8477694
G_SYS_HOLD                BOOLEAN := FALSE;  --8477694

-- delayed request for scheduleing
G_GROUP_SCHEDULE          CONSTANT  Varchar2(30) := 'GROUP_SCHEDULE';
G_GROUP_SET               CONSTANT  Varchar2(30) := 'GROUP_SET';
G_SPLIT_SCHEDULE          CONSTANT  Varchar2(30) := 'SPLIT_SCHEDULE';
-- 40256758 : delayed request to delete set
G_DELETE_SET              CONSTANT  Varchar2(30) := 'DELETE_SET';

G_FORCE_CLEAR_UI_BLOCK              VARCHAR2(1)            := 'N';

-- delayed request for Payment Verification
G_VERIFY_PAYMENT         CONSTANT       VARCHAR2(30) := 'VERIFY_PAYMENT';

-- delayed request for Updating Shipping from OE
G_UPDATE_SHIPPING        CONSTANT       VARCHAR2(30) := 'UPDATE_SHIPPING';

-- delayed request for Ship Confirmation
G_SHIP_CONFIRMATION      CONSTANT       VARCHAR2(30) := 'SHIP_CONFIRMATION';

-- delayed request for Work flow Activity completion
G_COMPLETE_ACTIVITY      CONSTANT       VARCHAR2(30) := 'COMPLETE_ACTIVITY';

--Bug 10032407
G_SKIP_ACTIVITY          CONSTANT       VARCHAR2(30) := 'SKIP_ACTIVITY';

--2391781
-- delayed request for scheduling attribute  changes in sets
G_CASCADE_SCH_ATTRBS    CONSTANT    VARCHAR2(30) := 'CASCADE_SCH_ATTRIBUTES';

-- Shipment Statuses for a line
G_FULLY_SHIPPED      	  CONSTANT       VARCHAR2(30) := 'Fully Shipped';
G_SHIPPED_WITHIN_TOL_BELOW CONSTANT       VARCHAR2(30) := 'Shipped within tolerance below';
G_SHIPPED_WITHIN_TOL_ABOVE CONSTANT       VARCHAR2(30) := 'Shipped within tolerance above';
G_SHIPPED_BEYOND_TOLERANCE CONSTANT       VARCHAR2(30) := 'Shipped beyond tolerance';
G_PARTIALLY_SHIPPED 	  CONSTANT       VARCHAR2(30) := 'Partially Shipped';

-- delayed request for RMA
G_INSERT_RMA           CONSTANT       VARCHAR2(30) := 'INSERT_RMA';
G_CHECK_OVER_RETURN    CONSTANT       VARCHAR2(30) := 'CHECK_OVER_RETURN';


-- Delayed request for Service
G_INSERT_SERVICE       CONSTANT      VARCHAR2(30) := 'INSERT_SERVICE';
/* added for bug #1533658 */
G_UPDATE_SERVICE       CONSTANT      VARCHAR2(30) := 'UPDATE_SERVICE';

/* lchen added for bug 1761154 */
G_CASCADE_OPTIONS_SERVICE  CONSTANT  VARCHAR2(30) := 'CASCADE_OPTIONS_SERVICE';


-- Delayed Request for Applying or Removing Holds when hold source entities
-- (customer/site/item) are entered or updated on the order or line.
G_EVAL_HOLD_SOURCE	CONSTANT	VARCHAR2(30) := 'EVAL_HOLD_SOURCE';

/* 7576948: IR ISO Change Management project Start */
-- delayed requet for updating Internal Requisition in Purchasing.
-- This is added for IR ISO Change Management project
G_UPDATE_REQUISITION   CONSTANT VARCHAR2(30) := 'UPDATE_INTERNAL_REQ';
/* IR ISO Change Management project End */

-- DOO Pre Exploded Kit
G_PRE_EXPLODED_KIT CONSTANT VARCHAR2(20) := 'PRE_EXPLODED_KIT';

-- Action Request to Book the Order
G_BOOK_ORDER		CONSTANT  VARCHAR2(30) := 'BOOK_ORDER';

-- Action Request to get the Ship Method for Order
G_GET_SHIP_METHOD       CONSTANT  VARCHAR2(30) := 'GET_SHIP_METHOD';
G_FTE_INSTALLED                   VARCHAR2(1)  := NULL;

-- Delayed Request/Action Request for Applying Automatic Attachments
G_APPLY_AUTOMATIC_ATCHMT		CONSTANT  VARCHAR2(30) := 'AUTOMATIC_ATCHMT';
-- Delayed Request for Copying Attachments
G_COPY_ATCHMT		CONSTANT  VARCHAR2(30) := 'COPY_ATCHMT';

--Delayed Request for the automatic internal req creation (ikon) Mshenoy
G_CREATE_INTERNAL_REQ	CONSTANT  VARCHAR2(30) := 'CREATE_INTERNAL_REQ';

--Delayed Request for XML Generation
G_GENERATE_XML_REQ_HDR   CONSTANT  VARCHAR2(30) := 'GENERATE_XML_REQ_HDR';
G_GENERATE_XML_REQ_LN   CONSTANT  VARCHAR2(30) := 'GENERATE_XML_REQ_LN';

--Delayed Request for 3A7 Hold
G_XML_APPLY_3A7_HOLD_REQ CONSTANT VARCHAR2(30) := 'XML_APPLY_3A7_HOLD';

-- Added 09-DEC-2002
-- DELAYED REQUESTS FOR BLANKETS/RELEASES
G_PROCESS_RELEASE              CONSTANT VARCHAR2(30) := 'PROCESS_RELEASE';
G_VALIDATE_RELEASE_SHIPMENTS   CONSTANT VARCHAR2(30) := 'VALIDATE_RELEASE_SHIPMENTS';

--Delayed Request for Clearing a Blanket Pricelist Line.Bug 3309427
G_CLEAR_BLKT_PRICE_LIST_LINE   CONSTANT VARCHAR2(30) := 'CLEAR_BLKT_PRICE_LIST_LINE';

-- delayed request for scheduleing
G_CANCEL_WF          CONSTANT  Varchar2(30) := 'CANCEL_WF';

-- Attribute groups for processing constraints
   G_ATTR_GRP_HSCREDIT CONSTANT Varchar2(30)    := 'HEADER_SCREDIT';
   G_ATTR_GRP_LSCREDIT CONSTANT Varchar2(30)    := 'LINE_SCREDIT';

-- Return Category Code
G_RETURN_CATEGORY_CODE  CONSTANT Varchar2(30) := 'RETURN';

-- Used when processing children of a return line
-- This is for internal returns processing use only
G_RETURN_CHILDREN_MODE  Varchar2(1) := 'N';

--  Max number of defaulting tterations.
G_MAX_DEF_ITERATIONS          CONSTANT NUMBER:= 5;

-- Please follow the naming convention for prefixing any of the
-- following Workflow attributes
-- G_WFI   -- item type
-- G_WFIA  -- item attribute
-- G_WFA   -- activity
-- G_WFR   -- results
-----------------------------------------------------------------
--  Workflow Item Types

G_WFI_HDR			   CONSTANT   VARCHAR2(8) := 'OEOH';
G_WFI_LIN  			   CONSTANT   VARCHAR2(8) := 'OEOL';

G_WFI_NGO                          CONSTANT   VARCHAR2(8) := 'OENH';
G_WFI_BKT                          CONSTANT   VARCHAR2(8) := 'OEBH';


--  Sales Document Type Code for Quote vs Blanket
G_SALES_DOCUMENT_TYPE_CODE   VARCHAR2(1) := NULL;

--  Common Workflow Results
G_WFR_COMPLETE		CONSTANT  VARCHAR2(30) := 'COMPLETE';
G_WFR_INCOMPLETE	CONSTANT  VARCHAR2(30) := 'INCOMPLETE';
G_WFR_ON_HOLD       CONSTANT  VARCHAR2(30) := 'ON_HOLD';
G_WFR_NOT_ELIGIBLE	CONSTANT  VARCHAR2(30) := 'NOT_ELIGIBLE';
G_WFR_PRTL_COMPLETE	CONSTANT  VARCHAR2(30) := 'PRTL_COMPLETE';
G_WFR_PRTL_INCOMPLETE	CONSTANT  VARCHAR2(30) := 'PRTL_INCOMPLETE';
G_WFR_PENDING_ACCEPTANCE  VARCHAR2(30) := 'PENDING_ACCEPTANCE';

-- Seeded Workflow Activities
G_WFA_PICK_ORDER        CONSTANT   VARCHAR2(30) := 'PICK_ORDER';
G_WFA_PICK_ORDER_LINE   CONSTANT   VARCHAR2(30) := 'PICK_ORDER_LINE';

-- Globals used for starting Order and Line flows

-- This indicates whether a Header flow needs to be started.
G_START_HEADER_FLOW           NUMBER  := NULL;

-- This indicates whether a Negotiation Header flow needs to be started.
G_START_NEGOTIATE_HEADER_FLOW           NUMBER  := NULL;

-- This indicates whether a Blanket Header (fulfillment) flow needs to be started.
G_START_BLANKET_HEADER_FLOW           NUMBER  := NULL;

-- This indicates whether we have started executing the code that starts on the pending
-- header and line flows.
G_FLOW_PROCESSING_STARTED     BOOLEAN := FALSE;
--This flag indicates if the flex fields has to be validated .By default it is set to Y
--However Public API and Group API can set these values to Y/N based on parameter p_validate_desc_flex
--R12 CVV2
G_PAYMENT_PROCESSED VARCHAR2(1);
--R12 CVV2

--This flag indicates if the flex fields has to be validated .By default it is set to Y
--However Public API and Group API can set these values to Y/N based on parameter p_validate_desc_flex
g_validate_desc_flex varchar2(1) :='Y'; -- 4343612

-- For bug 3000619
TYPE Line_ID_List_Rec IS Record
( line_id                 NUMBER
 ,post_write_ato_line_id  NUMBER);


-- Table type used for storing Line Ids that need their flows to be started
-- Bug 3000619, changed line_id_list to be a table of  Line_ID_List_Rec
TYPE Line_ID_List IS TABLE OF Line_ID_List_Rec INDEX BY BINARY_INTEGER;

-- Global table used for storing  Line Ids that need their flows to be started
G_START_LINE_FLOWS_TBL Line_ID_List;



-- Cancellation Specific declarations
-- Results of Cancelation Operation
G_CANCELED                      CONSTANT VARCHAR2(1) := 'Y';
G_CANNOT_CANCEL                 CONSTANT VARCHAR2(1) := 'N';
G_NOTIFIED                      CONSTANT VARCHAR2(1) := 'A';
G_FULL                          CONSTANT VARCHAR2(1) := 'F';
G_PARTIAL                       CONSTANT VARCHAR2(1) := 'P';
G_CANCELATION_HOLD_ID           CONSTANT NUMBER      := 4;
G_CAN_HIST_TYPE_CODE            CONSTANT VARCHAR2(30) := 'CANCELLATION';

-- Commit specific requests that need to executed

G_GAPLESS_ORDER_NUMBER     CONSTANT       VARCHAR2(30) := 'GEN_GAPLESS_ORDNUM';

-- To check if a specific product is installed
G_FND_INSTALLED		VARCHAR2(1) := NULL;
G_IPAYMENT_INSTALLED	VARCHAR2(1) := NULL;
G_OTA_INSTALLED		VARCHAR2(1) := NULL;
G_ASO_INSTALLED		VARCHAR2(1) := NULL;
G_OKS_INSTALLED		VARCHAR2(1) := NULL;
G_EC_INSTALLED			VARCHAR2(1) := NULL;
G_CONFIGURATOR_INSTALLED	VARCHAR2(1) := NULL;
G_RLM_INSTALLED		VARCHAR2(1) := NULL;
G_GMI_INSTALLED		VARCHAR2(1) := NULL; -- OPM 2547940

-- Global to check whether the header record is created in the same call.
G_HEADER_CREATED   BOOLEAN := FALSE;

-- Global flag to determine if this is from html om ui session
G_HTML_FLAG   BOOLEAN := FALSE;

-- global to indicate current XML transaction type
G_XML_TXN_CODE VARCHAR2(30) := NULL;

-- Global which would indicate whether defaulting updated any
-- attributes or not.
-- Callers that need to check this global value should always
-- initialize it to 'N' before making a call to any API (e.g. process
-- order, clear_dep_and_default) that could result in defaulting.
-- If it is set to 'Y'
-- after the call, it indicates that at least one attribute was
-- updated by defaulting.
G_ATTR_UPDATED_BY_DEF    VARCHAR2(1) := 'N';
G_FREIGHT_RECURSION		     VARCHAR2(1) := 'N';
-- Global Indicates whether pricing is deferred at line level
G_DEFER_PRICING         VARCHAR2(1) := 'N';

--Action Requests for Customer Acceptance
G_ACCEPT_FULFILLMENT               CONSTANT  VARCHAR2(30) := 'ACCEPT_FULFILLMENT';
G_REJECT_FULFILLMENT               CONSTANT  VARCHAR2(30) := 'REJECT_FULFILLMENT';
G_DFLT_CONTINGENCY_ATTRIBUTES      CONSTANT  VARCHAR2(30) := 'DEFAULT_CONTINGENCY_ATTRIBUTES';
G_UPDATE_GLOBAL_PICTURE VARCHAR2(30) := 'Y';

-- To allow order import to fail in cases where partial
-- processing should apply only to direct callers of process order
G_FAIL_ORDER_IMPORT BOOLEAN := FALSE; /* Bug # 4036765 */

-- Added for bug 7367433. This indicates if Process Order code is being executed as part of Order Import call or not.
G_ORDER_IMPORT_CALL BOOLEAN := FALSE;

-- Added global for bug 9354229
G_CALL_PROCESS_REQ BOOLEAN := TRUE;

--Added for ER7675548
-- Flag to determine what should happen if both ID and Value are sent for inline customer creation
G_UPDATE_ON_ID BOOLEAN := FALSE;

--  Index table type used by JVC controllers.
TYPE Index_Tbl_Type IS TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;

--  API Operation control flags.
TYPE Control_Rec_Type IS RECORD
(   controlled_operation          BOOLEAN := FALSE
,   Private_Call		  BOOLEAN := TRUE
,   check_security                BOOLEAN := TRUE
,   clear_dependents		    BOOLEAN := TRUE
,   default_attributes            BOOLEAN := TRUE
,   change_attributes             BOOLEAN := TRUE
,   validate_entity               BOOLEAN := TRUE
,   write_to_db                   BOOLEAN := TRUE
,   Process_Partial               BOOLEAN := FALSE
,   process                       BOOLEAN := TRUE
,   process_entity                VARCHAR2(30) := G_ENTITY_ALL
,   clear_api_cache               BOOLEAN := TRUE
,   clear_api_requests            BOOLEAN := TRUE
,   request_category              VARCHAR2(30):= NULL
,   request_name                  VARCHAR2(30):= NULL
,   org_id			         NUMBER := FND_API.G_MISS_NUM
,   require_reason                BOOLEAN := NULL
);


--  Variable representing missing control record.

G_MISS_CONTROL_REC            Control_Rec_Type;

/* Request rec and request table definition has been moved to OEXPORDS */
--  API request record type.
/*
TYPE Request_Rec_Type IS RECORD
(
--  entity                        VARCHAR2(30) := NULL
--,   step                          VARCHAR2(30) := NULL
--,   name                          VARCHAR2(30) := NULL
--,   category                      VARCHAR2(30) := NULL
--,   processed                     BOOLEAN := FALSE
--,   attribute1                    VARCHAR2(240) := NULL
--,   attribute2                    VARCHAR2(240) := NULL
--,   attribute3                    VARCHAR2(240) := NULL
--,   attribute4                    VARCHAR2(240) := NULL
--,   attribute5                    VARCHAR2(240) := NULL


-- merge from admin/sql
-- Object for which the delayed request has been logged
-- ie LINE, ORDER, PRICE_ADJUSTMENT
   Entity_code        Varchar2(30):= NULL,

   -- Primary key for the object as in entity_code
   Entity_id          Number := NULL,

   -- Function / Procedure indentifier ie 'PRICE_LINE'
   -- 'RECORD_HISTORY'
   request_type       Varchar2(30) := NULL,

   return_status      VARCHAR2(1)  := FND_API.G_MISS_CHAR,

   -- Parameters (param - param10) for the delayed request
   param1             Varchar2(2000) := NULL,
   param2             Varchar2(240) := NULL,
   param3             Varchar2(240) := NULL,
   param4             Varchar2(240) := NULL,
   param5             Varchar2(240) := NULL,
   param6             Varchar2(240) := NULL,
   param7             Varchar2(240) := NULL,
   param8             Varchar2(240) := NULL,
   param9             Varchar2(240) := NULL,
   param10            Varchar2(240) := NULL,
   long_param1        Varchar2(2000) := NULL,
   processed          BOOLEAN := FALSE

);

--  API Request table type.

TYPE Request_Tbl_Type IS TABLE OF Request_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Missing request record type
G_MISS_REQUEST_REC	Request_Rec_Type;
G_MISS_REQUEST_TBL	Request_Tbl_Type;
*/

/* History type 'R' -> requires reason and history
                'H' -> requires only history */

TYPE  OE_AUDIT_HISTORY_REC IS RECORD
     (HEADER_ID          NUMBER,
      LINE_ID            NUMBER,
      HISTORY_TYPE       VARCHAR2(1));

TYPE oe_audit_trail_history_tbl IS TABLE OF oe_audit_history_rec
INDEX BY BINARY_INTEGER;

OE_AUDIT_HISTORY_TBL           oe_audit_trail_history_tbl;

--  Generic table types
TYPE Boolean_Tbl_Type IS TABLE OF BOOLEAN
    INDEX BY BINARY_INTEGER;

TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

--  Variable representing a missing table.
G_MISS_BOOLEAN_TBL      Boolean_Tbl_Type;
G_MISS_NUMBER_TBL       Number_Tbl_Type;

TYPE ACCESS_LIST IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;
G_ACCESS_LIST     ACCESS_LIST;
--  Get Application ID #1942082

-- added for Electronic Messaging Exc Mgmt
G_EM_ACCESS_LIST     ACCESS_LIST;
-- end Electronic Messaging Exc Mgmt

FUNCTION GET_APPLICATION_ID
(   p_resp_id                       IN NUMBER
) RETURN NUMBER;

--  Initialize control record.
FUNCTION Init_Control_Rec
(   p_operation                     IN  VARCHAR2
,   p_control_rec                   IN  Control_Rec_Type
)RETURN Control_Rec_Type;

--  Function Equal
--  Number comparison.

FUNCTION Equal
(   p_attribute1                    IN  NUMBER
,   p_attribute2                    IN  NUMBER
)RETURN BOOLEAN;

--  Varchar2 comparison.

FUNCTION Equal
(   p_attribute1                    IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
)RETURN BOOLEAN;

--  Date comparison.

FUNCTION Equal
(   p_attribute1                    IN  DATE
,   p_attribute2                    IN  DATE
)RETURN BOOLEAN;


PROCEDURE Set_Context;

FUNCTION CHECK_PRODUCT_INSTALLED
(   p_application_id                IN  NUMBER
)RETURN VARCHAR2;

FUNCTION  GET_FORCE_CLEAR_UI_BLOCK RETURN VARCHAR2;
PROCEDURE SET_FORCE_CLEAR_UI_BLOCK (ui_block IN VARCHAR2);

FUNCTION Is_Same_Credit_Card
(   p_cc_num_old                    IN  VARCHAR2 DEFAULT NULL
,   p_cc_num_new                    IN  VARCHAR2 DEFAULT NULL
,   p_instrument_id_old		    IN  NUMBER DEFAULT NULL
,   p_instrument_id_new		    IN  NUMBER DEFAULT NULL
)RETURN BOOLEAN;

TYPE Selected_Record_Type IS RECORD
(
id1         NUMBER
,id2         NUMBER
,id3         NUMBER
,id4         NUMBER
,id5         NUMBER
,org_id    NUMBER
);

TYPE Selected_Record_Tbl IS TABLE OF Selected_Record_Type
    INDEX BY BINARY_INTEGER;

G_BINARY_LIMIT CONSTANT NUMBER:=2147483648;  -- 8617475

END Oe_Globals;

/
