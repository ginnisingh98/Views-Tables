--------------------------------------------------------
--  DDL for Package Body JAI_CMN_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_HOOK_PKG" AS
/* $Header: jai_cmn_hook.plb 120.1 2005/07/20 12:57:07 avallabh ship $ */

/*------------------------------------------------------------------------------------------
 CHANGE HISTORY for FILENAME: jai_cmn_hook_pkg.sql
S.No    Date        Author and Details
------------------------------------------------------------------------------------------

1    20/02/2004     Nagaraj.s for bug 3438863 Version : 618.1

            This Package is basically meant for any client customizations
            for defaultation of Localization Taxes when Purchase Orders
            are not created from PO-Localized screens.
            Both the Functions
            Ja_In_po_line_locations_all
            Ja_In_po_lines_all
            would return value as True.

            In scenarios where the PO has not been entered from PO-Localized
            screen, the customer would have an option of avoiding
            tax defaultation by coding these functions to return
            'FALSE'.

            In any case, if the Purchase Orders are created from PO Localized
            screen then Tax defaultation would not be affected.

2    14/04/2004     Vijay Shankar for bug# 3570189, Version : 619.1 (115.0)
                     PO Hook Functionality is made compatible with 11.5.3 Base Applications by removing last 11 from Ja_In_po_lines_all
                     procedure and 12 from Ja_In_po_line_locations_all procedure

3    07/02/2005    Vijay Shankar for bug# 4159557, Version : 115.1
                    Function allow_tax_change_on_receipt is added to give flexibility for client in deciding whether taxes can
                    be changed on receipt lines or not for Receipts that are created through Open Interface

4    22/02/2005    Vijay Shankar for bug# 4199929, Version : 115.2
                    Changes made in the previous version of this package are revoked with this version

5. 08-Jun-2005  Version 116.1 jai_cmn_hook -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                as required for CASE COMPLAINCE.

6  06-Jul-2005    rallamse for bug# PADDR Elimination
                   1. Added FUNCTION Po_Requisition_Lines_All in both spec and body

---------------------------------------------------------------------------------------------*/

FUNCTION Ja_In_po_lines_all (
  P_PO_LINE_ID                         NUMBER,
  P_PO_HEADER_ID                       NUMBER,
  P_LINE_TYPE_ID                       NUMBER,
  P_LINE_NUM                           NUMBER,
  P_ITEM_ID                            NUMBER,
  P_ITEM_REVISION                      VARCHAR2,
  P_CATEGORY_ID                        NUMBER,
  P_ITEM_DESCRIPTION                   VARCHAR2,
  P_UNIT_MEAS_LOOKUP_CODE              VARCHAR2,
  P_QUANTITY_COMMITTED                 NUMBER,
  P_COMMITTED_AMOUNT                   NUMBER,
  P_ALLOW_PRICE_OVERRIDE_FLAG          VARCHAR2,
  P_NOT_TO_EXCEED_PRICE                NUMBER,
  P_LIST_PRICE_PER_UNIT                NUMBER,
  P_UNIT_PRICE                         NUMBER,
  P_QUANTITY                           NUMBER,
  P_UN_NUMBER_ID                       NUMBER,
  P_HAZARD_CLASS_ID                    NUMBER,
  P_NOTE_TO_VENDOR                     VARCHAR2,
  P_FROM_HEADER_ID                     NUMBER,
  P_FROM_LINE_ID                       NUMBER,
  P_MIN_ORDER_QUANTITY                 NUMBER,
  P_MAX_ORDER_QUANTITY                 NUMBER,
  P_QTY_RCV_TOLERANCE                  NUMBER,
  P_OVER_TOLERANCE_ERROR_FLAG          VARCHAR2,
  P_MARKET_PRICE                       NUMBER,
  P_UNORDERED_FLAG                     VARCHAR2,
  P_CLOSED_FLAG                        VARCHAR2,
  P_USER_HOLD_FLAG                     VARCHAR2,
  P_CANCEL_FLAG                        VARCHAR2,
  P_CANCELLED_BY                       NUMBER,
  P_CANCEL_DATE                        DATE,
  P_CANCEL_REASON                      VARCHAR2,
  P_FIRM_STATUS_LOOKUP_CODE            VARCHAR2,
  P_FIRM_DATE                          DATE,
  P_VENDOR_PRODUCT_NUM                 VARCHAR2,
  P_CONTRACT_NUM                       VARCHAR2,
  P_TAXABLE_FLAG                       VARCHAR2,
  P_TAX_NAME                           VARCHAR2,
  P_TYPE_1099                          VARCHAR2,
  P_CAPITAL_EXPENSE_FLAG               VARCHAR2,
  P_NEGOTIATED_BY_PREPARER_FLAG        VARCHAR2,
  P_ATTRIBUTE_CATEGORY                 VARCHAR2,
  P_ATTRIBUTE1                         VARCHAR2,
  P_ATTRIBUTE2                         VARCHAR2,
  P_ATTRIBUTE3                         VARCHAR2,
  P_ATTRIBUTE4                         VARCHAR2,
  P_ATTRIBUTE5                         VARCHAR2,
  P_ATTRIBUTE6                         VARCHAR2,
  P_ATTRIBUTE7                         VARCHAR2,
  P_ATTRIBUTE8                         VARCHAR2,
  P_ATTRIBUTE9                         VARCHAR2,
  P_ATTRIBUTE10                        VARCHAR2,
  P_REFERENCE_NUM                      VARCHAR2,
  P_ATTRIBUTE11                        VARCHAR2,
  P_ATTRIBUTE12                        VARCHAR2,
  P_ATTRIBUTE13                        VARCHAR2,
  P_ATTRIBUTE14                        VARCHAR2,
  P_ATTRIBUTE15                        VARCHAR2,
  P_MIN_RELEASE_AMOUNT                 NUMBER,
  P_PRICE_TYPE_LOOKUP_CODE             VARCHAR2,
  P_CLOSED_CODE                        VARCHAR2,
  P_PRICE_BREAK_LOOKUP_CODE            VARCHAR2,
  P_USSGL_TRANSACTION_CODE             VARCHAR2,
  P_GOVERNMENT_CONTEXT                 VARCHAR2,
  P_REQUEST_ID                         NUMBER,
  P_PROGRAM_APPLICATION_ID             NUMBER,
  P_PROGRAM_ID                         NUMBER,
  P_PROGRAM_UPDATE_DATE                DATE,
  P_CLOSED_DATE                        DATE,
  P_CLOSED_REASON                      VARCHAR2,
  P_CLOSED_BY                          NUMBER,
  P_TRANSACTION_REASON_CODE            VARCHAR2,
  P_ORG_ID                             NUMBER,
  P_QC_GRADE                           VARCHAR2,
  P_BASE_UOM                           VARCHAR2,
  P_BASE_QTY                           NUMBER,
  P_SECONDARY_UOM                      VARCHAR2,
  P_SECONDARY_QTY                      NUMBER,
  P_LINE_REFERENCE_NUM                 VARCHAR2,
  P_PROJECT_ID                         NUMBER,
  P_TASK_ID                            NUMBER,
  P_EXPIRATION_DATE                    DATE,
  P_TAX_CODE_ID                        NUMBER
) RETURN VARCHAR2
IS
BEGIN

  /* This function has be customized not to default location taxes*/
  NULL;

  -- RETURN ('FALSE');
  RETURN ('TRUE');

END Ja_In_po_lines_all;

FUNCTION Ja_In_po_line_locations_all (
  P_LINE_LOCATION_ID                   NUMBER,
  P_PO_HEADER_ID                       NUMBER,
  P_PO_LINE_ID                         NUMBER,
  P_QUANTITY                           NUMBER,
  P_QUANTITY_RECEIVED                  NUMBER,
  P_QUANTITY_ACCEPTED                  NUMBER,
  P_QUANTITY_REJECTED                  NUMBER,
  P_QUANTITY_BILLED                    NUMBER,
  P_QUANTITY_CANCELLED                 NUMBER,
  P_UNIT_MEAS_LOOKUP_CODE              VARCHAR2,
  P_PO_RELEASE_ID                      NUMBER,
  P_SHIP_TO_LOCATION_ID                NUMBER,
  P_SHIP_VIA_LOOKUP_CODE               VARCHAR2,
  P_NEED_BY_DATE                       DATE,
  P_PROMISED_DATE                      DATE,
  P_LAST_ACCEPT_DATE                   DATE,
  P_PRICE_OVERRIDE                     NUMBER,
  P_ENCUMBERED_FLAG                    VARCHAR2,
  P_ENCUMBERED_DATE                    DATE,
  P_UNENCUMBERED_QUANTITY              NUMBER,
  P_FOB_LOOKUP_CODE                    VARCHAR2,
  P_FREIGHT_TERMS_LOOKUP_CODE          VARCHAR2,
  P_TAXABLE_FLAG                       VARCHAR2,
  P_TAX_NAME                           VARCHAR2,
  P_ESTIMATED_TAX_AMOUNT               NUMBER,
  P_FROM_HEADER_ID                     NUMBER,
  P_FROM_LINE_ID                       NUMBER,
  P_FROM_LINE_LOCATION_ID              NUMBER,
  P_START_DATE                         DATE,
  P_END_DATE                           DATE,
  P_LEAD_TIME                          NUMBER,
  P_LEAD_TIME_UNIT                     VARCHAR2,
  P_PRICE_DISCOUNT                     NUMBER,
  P_TERMS_ID                           NUMBER,
  P_APPROVED_FLAG                      VARCHAR2,
  P_APPROVED_DATE                      DATE,
  P_CLOSED_FLAG                        VARCHAR2,
  P_CANCEL_FLAG                        VARCHAR2,
  P_CANCELLED_BY                       NUMBER,
  P_CANCEL_DATE                        DATE,
  P_CANCEL_REASON                      VARCHAR2,
  P_FIRM_STATUS_LOOKUP_CODE            VARCHAR2,
  P_FIRM_DATE                          DATE,
  P_ATTRIBUTE_CATEGORY                 VARCHAR2,
  P_ATTRIBUTE1                         VARCHAR2,
  P_ATTRIBUTE2                         VARCHAR2,
  P_ATTRIBUTE3                         VARCHAR2,
  P_ATTRIBUTE4                         VARCHAR2,
  P_ATTRIBUTE5                         VARCHAR2,
  P_ATTRIBUTE6                         VARCHAR2,
  P_ATTRIBUTE7                         VARCHAR2,
  P_ATTRIBUTE8                         VARCHAR2,
  P_ATTRIBUTE9                         VARCHAR2,
  P_ATTRIBUTE10                        VARCHAR2,
  P_UNIT_OF_MEASURE_CLASS              VARCHAR2,
  P_ENCUMBER_NOW                       VARCHAR2,
  P_ATTRIBUTE11                        VARCHAR2,
  P_ATTRIBUTE12                        VARCHAR2,
  P_ATTRIBUTE13                        VARCHAR2,
  P_ATTRIBUTE14                        VARCHAR2,
  P_ATTRIBUTE15                        VARCHAR2,
  P_INSPECTION_REQUIRED_FLAG           VARCHAR2,
  P_RECEIPT_REQUIRED_FLAG              VARCHAR2,
  P_QTY_RCV_TOLERANCE                  NUMBER,
  P_QTY_RCV_EXCEPTION_CODE             VARCHAR2,
  P_ENF_SHIP_TO_LOCATION_CODE          VARCHAR2,
  P_ALLOW_SUBST_RECEIPTS_FLAG          VARCHAR2,
  P_DAYS_EARLY_RECEIPT_ALLOWED         NUMBER,
  P_DAYS_LATE_RECEIPT_ALLOWED          NUMBER,
  P_RECEIPT_DAYS_EXCEPTION_CODE        VARCHAR2,
  P_INVOICE_CLOSE_TOLERANCE            NUMBER,
  P_RECEIVE_CLOSE_TOLERANCE            NUMBER,
  P_SHIP_TO_ORGANIZATION_ID            NUMBER,
  P_SHIPMENT_NUM                       NUMBER,
  P_SOURCE_SHIPMENT_ID                 NUMBER,
  P_SHIPMENT_TYPE                      VARCHAR2,
  P_CLOSED_CODE                        VARCHAR2,
  P_REQUEST_ID                         NUMBER,
  P_PROGRAM_APPLICATION_ID             NUMBER,
  P_PROGRAM_ID                         NUMBER,
  P_PROGRAM_UPDATE_DATE                DATE,
  P_USSGL_TRANSACTION_CODE             VARCHAR2,
  P_GOVERNMENT_CONTEXT                 VARCHAR2,
  P_RECEIVING_ROUTING_ID               NUMBER,
  P_ACCRUE_ON_RECEIPT_FLAG             VARCHAR2,
  P_CLOSED_REASON                      VARCHAR2,
  P_CLOSED_DATE                        DATE,
  P_CLOSED_BY                          NUMBER,
  P_ORG_ID                             NUMBER ,
  P_QUANTITY_SHIPPED                   NUMBER,
  P_COUNTRY_OF_ORIGIN_CODE             VARCHAR2,
  P_TAX_USER_OVERRIDE_FLAG             VARCHAR2,
  P_MATCH_OPTION                       VARCHAR2,
  P_TAX_CODE_ID                        NUMBER,
  P_CALCULATE_TAX_FLAG                 VARCHAR2,
  P_CHANGE_PROMISED_DATE_REASON        VARCHAR2
) RETURN VARCHAR2
IS
BEGIN

  /* This function has be customized not to default location taxes*/
  NULL;
  -- RETURN ('FALSE');
  RETURN ('TRUE');

END Ja_In_po_line_locations_all;

FUNCTION oe_lines_insert
(p_line_id NUMBER,
 p_org_id NUMBER,
 p_line_type_id NUMBER,
 p_ship_from_org_id NUMBER,
 p_ship_to_org_id NUMBER,
 p_invoice_to_org_id NUMBER,
 p_sold_to_org_id NUMBER,
 p_sold_from_org_id NUMBER,
 p_inventory_item_id NUMBER,
 p_tax_code VARCHAR2,
 p_price_list_id NUMBER,
 p_source_document_type_id NUMBER,
 p_source_document_line_id NUMBER,
 p_reference_line_id NUMBER,
 p_reference_header_id NUMBER,
 p_salesrep_id NUMBER,
 p_order_source_id NUMBER,
 p_orig_sys_document_ref VARCHAR2,
 p_orig_sys_line_ref VARCHAR2) RETURN VARCHAR2 IS

 v_return   VARCHAR2(1996);

BEGIN


/*------------------------------------------------------------------------------------------
 FILENAME: jai_cmn_hook_pkg.oe_lines_insert.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1         2002/06/13    Asshukla Function created
--------------------------------------------------------------------------------------------*/

/* this portion of the function is to be used for the customised component,
based on the return value the trigger JA_IN_OE_ORDER_LINES_AIU_TRG will function
the function should return "FALSE" so as not to execute procedure and "TRUE" to run the procedure.
Check for the impact on the trigger JA_IN_OE_ORDER_LINES_AIU_TRG before changing return value.
the functional currency of the operating unit has to be INR*/
  NULL;
  RETURN('TRUE');
END oe_lines_insert;

/* Added function Po_Requisition_Lines_All by rallamse bug#4479131 PADDR Elimination */
FUNCTION Po_Requisition_Lines_All
 (
        REQUISITION_LINE_ID               NUMBER,
        REQUISITION_HEADER_ID             NUMBER,
        LINE_NUM                          NUMBER,
        LINE_TYPE_ID                      NUMBER,
        CATEGORY_ID                       NUMBER,
        ITEM_DESCRIPTION                  VARCHAR2,
        UNIT_MEAS_LOOKUP_CODE             VARCHAR2,
        UNIT_PRICE                        NUMBER,
        QUANTITY                          NUMBER,
        DELIVER_TO_LOCATION_ID            NUMBER,
        TO_PERSON_ID                      NUMBER,
        LAST_UPDATE_DATE                  DATE,
        LAST_UPDATED_BY                   NUMBER,
        SOURCE_TYPE_CODE                  VARCHAR2,
        LAST_UPDATE_LOGIN                 NUMBER,
        CREATION_DATE                     DATE,
        CREATED_BY                        NUMBER,
        ITEM_ID                           NUMBER,
        ITEM_REVISION                     VARCHAR2,
        QUANTITY_DELIVERED                NUMBER,
        SUGGESTED_BUYER_ID                NUMBER,
        ENCUMBERED_FLAG                   VARCHAR2,
        RFQ_REQUIRED_FLAG                 VARCHAR2,
        NEED_BY_DATE                      DATE,
        LINE_LOCATION_ID                  NUMBER,
        MODIFIED_BY_AGENT_FLAG            VARCHAR2,
        PARENT_REQ_LINE_ID                NUMBER,
        JUSTIFICATION                     VARCHAR2,
        NOTE_TO_AGENT                     VARCHAR2,
        NOTE_TO_RECEIVER                  VARCHAR2,
        PURCHASING_AGENT_ID               NUMBER,
        DOCUMENT_TYPE_CODE                VARCHAR2,
        BLANKET_PO_HEADER_ID              NUMBER,
        BLANKET_PO_LINE_NUM               NUMBER,
        CURRENCY_CODE                     VARCHAR2,
        RATE_TYPE                         VARCHAR2,
        RATE_DATE                         DATE,
        RATE                              NUMBER,
        CURRENCY_UNIT_PRICE               NUMBER,
        SUGGESTED_VENDOR_NAME             VARCHAR2,
        SUGGESTED_VENDOR_LOCATION         VARCHAR2,
        SUGGESTED_VENDOR_CONTACT          VARCHAR2,
        SUGGESTED_VENDOR_PHONE            VARCHAR2,
        SUGGESTED_VENDOR_PRODUCT_CODE     VARCHAR2,
        UN_NUMBER_ID                      NUMBER,
        HAZARD_CLASS_ID                   NUMBER,
        MUST_USE_SUGG_VENDOR_FLAG         VARCHAR2,
        REFERENCE_NUM                     VARCHAR2,
        ON_RFQ_FLAG                       VARCHAR2,
        URGENT_FLAG                       VARCHAR2,
        CANCEL_FLAG                       VARCHAR2,
        SOURCE_ORGANIZATION_ID            NUMBER,
        SOURCE_SUBINVENTORY               VARCHAR2,
        DESTINATION_TYPE_CODE             VARCHAR2,
        DESTINATION_ORGANIZATION_ID       NUMBER,
        DESTINATION_SUBINVENTORY          VARCHAR2,
        QUANTITY_CANCELLED                NUMBER,
        CANCEL_DATE                       DATE,
        CANCEL_REASON                     VARCHAR2,
        CLOSED_CODE                       VARCHAR2,
        AGENT_RETURN_NOTE                 VARCHAR2,
        CHANGED_AFTER_RESEARCH_FLAG       VARCHAR2,
        VENDOR_ID                         NUMBER,
        VENDOR_SITE_ID                    NUMBER,
        VENDOR_CONTACT_ID                 NUMBER,
        RESEARCH_AGENT_ID                 NUMBER,
        ON_LINE_FLAG                      VARCHAR2,
        WIP_ENTITY_ID                     NUMBER,
        WIP_LINE_ID                       NUMBER,
        WIP_REPETITIVE_SCHEDULE_ID        NUMBER,
        WIP_OPERATION_SEQ_NUM             NUMBER,
        WIP_RESOURCE_SEQ_NUM              NUMBER,
        ATTRIBUTE_CATEGORY                VARCHAR2,
        DESTINATION_CONTEXT               VARCHAR2,
        INVENTORY_SOURCE_CONTEXT          VARCHAR2,
        VENDOR_SOURCE_CONTEXT             VARCHAR2,
        ATTRIBUTE1                        VARCHAR2,
        ATTRIBUTE2                        VARCHAR2,
        ATTRIBUTE3                        VARCHAR2,
        ATTRIBUTE4                        VARCHAR2,
        ATTRIBUTE5                        VARCHAR2,
        ATTRIBUTE6                        VARCHAR2,
        ATTRIBUTE7                        VARCHAR2,
        ATTRIBUTE8                        VARCHAR2,
        ATTRIBUTE9                        VARCHAR2,
        ATTRIBUTE10                       VARCHAR2,
        ATTRIBUTE11                       VARCHAR2,
        ATTRIBUTE12                       VARCHAR2,
        ATTRIBUTE13                       VARCHAR2,
        ATTRIBUTE14                       VARCHAR2,
        ATTRIBUTE15                       VARCHAR2,
        BOM_RESOURCE_ID                   NUMBER,
        CLOSED_REASON                     VARCHAR2,
        CLOSED_DATE                       DATE,
        TRANSACTION_REASON_CODE           VARCHAR2,
        QUANTITY_RECEIVED                 NUMBER,
        SOURCE_REQ_LINE_ID                NUMBER,
        ORG_ID                            NUMBER,
        KANBAN_CARD_ID                    NUMBER,
        CATALOG_TYPE                      VARCHAR2,
        CATALOG_SOURCE                    VARCHAR2,
        MANUFACTURER_ID                   NUMBER,
        MANUFACTURER_NAME                 VARCHAR2,
        MANUFACTURER_PART_NUMBER          VARCHAR2,
        REQUESTER_EMAIL                   VARCHAR2,
        REQUESTER_FAX                     VARCHAR2,
        REQUESTER_PHONE                   VARCHAR2,
        UNSPSC_CODE                       VARCHAR2,
        OTHER_CATEGORY_CODE               VARCHAR2,
        SUPPLIER_DUNS                     VARCHAR2,
        TAX_STATUS_INDICATOR              VARCHAR2,
        PCARD_FLAG                        VARCHAR2,
        NEW_SUPPLIER_FLAG                 VARCHAR2,
        AUTO_RECEIVE_FLAG                 VARCHAR2,
        TAX_USER_OVERRIDE_FLAG            VARCHAR2,
        TAX_CODE_ID                       NUMBER,
        NOTE_TO_VENDOR                    VARCHAR2,
        OKE_CONTRACT_VERSION_ID           NUMBER,
        OKE_CONTRACT_HEADER_ID            NUMBER,
        ITEM_SOURCE_ID                    NUMBER,
        SUPPLIER_REF_NUMBER               VARCHAR2,
        SECONDARY_UNIT_OF_MEASURE         VARCHAR2,
        SECONDARY_QUANTITY                NUMBER,
        PREFERRED_GRADE                   VARCHAR2,
        SECONDARY_QUANTITY_RECEIVED       NUMBER,
        SECONDARY_QUANTITY_CANCELLED      NUMBER,
        VMI_FLAG                          VARCHAR2,
        AUCTION_HEADER_ID                 NUMBER,
        AUCTION_DISPLAY_NUMBER            VARCHAR2,
        AUCTION_LINE_NUMBER               NUMBER,
        REQS_IN_POOL_FLAG                 VARCHAR2,
        BID_NUMBER                        NUMBER,
        BID_LINE_NUMBER                   NUMBER,
        NONCAT_TEMPLATE_ID                NUMBER,
        SUGGESTED_VENDOR_CONTACT_FAX      VARCHAR2,
        SUGGESTED_VENDOR_CONTACT_EMAIL    VARCHAR2,
        AMOUNT                            NUMBER,
        CURRENCY_AMOUNT                   NUMBER,
        LABOR_REQ_LINE_ID                 NUMBER,
        JOB_ID                            NUMBER,
        JOB_LONG_DESCRIPTION              VARCHAR2,
        CONTRACTOR_STATUS                 VARCHAR2,
        CONTACT_INFORMATION               VARCHAR2,
        SUGGESTED_SUPPLIER_FLAG           VARCHAR2,
        CANDIDATE_SCREENING_REQD_FLAG     VARCHAR2,
        CANDIDATE_FIRST_NAME              VARCHAR2,
        CANDIDATE_LAST_NAME               VARCHAR2,
        ASSIGNMENT_END_DATE               DATE,
        OVERTIME_ALLOWED_FLAG             VARCHAR2,
        CONTRACTOR_REQUISITION_FLAG       VARCHAR2,
        DROP_SHIP_FLAG                    VARCHAR2,
        ASSIGNMENT_START_DATE             DATE,
        ORDER_TYPE_LOOKUP_CODE            VARCHAR2,
        PURCHASE_BASIS                    VARCHAR2,
        MATCHING_BASIS                    VARCHAR2,
        NEGOTIATED_BY_PREPARER_FLAG       VARCHAR2,
        SHIP_METHOD                       VARCHAR2,
        ESTIMATED_PICKUP_DATE             DATE,
        SUPPLIER_NOTIFIED_FOR_CANCEL      VARCHAR2,
        BASE_UNIT_PRICE                   NUMBER,
        AT_SOURCING_FLAG                  VARCHAR2,
        EVENT_ID                          NUMBER,
        LINE_NUMBER                       NUMBER
 ) RETURN VARCHAR2 IS
 BEGIN

   /* This function has be customized not to default location taxes*/
  NULL;
  -- RETURN ('FALSE');
  RETURN ('TRUE');

 END Po_Requisition_Lines_All ;

End jai_cmn_hook_pkg;

/