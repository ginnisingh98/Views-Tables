--------------------------------------------------------
--  DDL for Package AK$ICX_PO_REQUISITION_LINES_IN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK$ICX_PO_REQUISITION_LINES_IN" AUTHID CURRENT_USER AS
/* $Header: ICXAKPLS.pls 115.2 99/10/28 15:22:19 porting ship   $ */

  TYPE REC IS RECORD (
    "AGENT_ID$178" NUMBER,
    "ICX_AGENT_RETURN_NOTE$178" VARCHAR(240),
    "ICX_AUTOSOURCE_DOC_HEADER_$178" NUMBER,
    "ICX_AUTOSOURCE_DOC_LINE_NU$178" NUMBER,
    "ICX_BOM_RESOURCE_ID$178" NUMBER,
    "ICX_BUYER$178" VARCHAR(2000),
    "ICX_CANCEL_DATE$178" VARCHAR(20),
    "ICX_CANCEL_FLAG$178" VARCHAR(1),
    "ICX_CANCEL_REASON$178" VARCHAR(240),
    "ICX_CATEGORY_ID$178" NUMBER,
    "ICX_CATEGORY_V$178" VARCHAR(81),
    "ICX_CLOSED_CODE$178" VARCHAR(30),
    "ICX_CLOSED_DATE$178" VARCHAR(20),
    "ICX_CLOSED_REASON$178" VARCHAR(240),
    "ICX_CREATION_DATE_V$178" DATE,
    "ICX_CURRENCY$178" VARCHAR(15),
    "ICX_CURR_UNIT_PRICE$178" NUMBER,
    "ICX_DELIVER_TO_LOCATION$178" VARCHAR(20),
    "ICX_DELIVER_TO_LOCATION_ID$178" NUMBER,
    "ICX_DESC$178" VARCHAR(240),
    "ICX_DESTINATION_TYPE_CODE$178" VARCHAR(25),
    "ICX_DEST_CONTEXT$178" VARCHAR(30),
    "ICX_DEST_ORG_ID$178" NUMBER,
    "ICX_DEST_SUBINVENTORY$178" VARCHAR(10),
    "ICX_DOCUMENT_TYPE$178" VARCHAR(80),
    "ICX_ENCUMBERED_FLAG$178" VARCHAR(5),
    "ICX_GOV_CONTEXT$178" VARCHAR(30),
    "ICX_HAZARD_CLASS_ID$178" NUMBER,
    "ICX_INV_SOURCE_CONTEXT$178" VARCHAR(30),
    "ICX_ITEM$178" VARCHAR(40),
    "ICX_JUSTIFICATION$178" VARCHAR(240),
    "ICX_LINE_ATTRIBUTE_1$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_10$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_11$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_12$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_13$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_14$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_15$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_2$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_3$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_4$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_5$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_6$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_7$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_8$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_9$178" VARCHAR(150),
    "ICX_LINE_ATTRIBUTE_CATEGOR$178" VARCHAR(30),
    "ICX_LINE_TYPE_ID_V$178" NUMBER,
    "ICX_LINE_V$178" NUMBER,
    "ICX_MOD_BY_AGENT_FLAG$178" VARCHAR(1),
    "ICX_NOTE_TO_BUYER$178" VARCHAR(240),
    "ICX_NOTE_TO_RECEIVER$178" VARCHAR(240),
    "ICX_NUM_V$178" VARCHAR(30),
    "ICX_ON_LINE_FLAG$178" VARCHAR(1),
    "ICX_ON_RFQ_FLAG$178" VARCHAR(1),
    "ICX_ORDER_NUM$178" VARCHAR(30),
    "ICX_PARENT_REQ_LINE_ID$178" NUMBER,
    "ICX_PONUM_V$178" VARCHAR(30),
    "ICX_PREPARER_NAME$178" VARCHAR(2000),
    "ICX_PRICE_V$178" NUMBER,
    "ICX_QTY_CANCELLED$178" NUMBER,
    "ICX_QTY_DELIVERY$178" NUMBER,
    "ICX_QTY_RECEIVED$178" NUMBER,
    "ICX_QTY_V$178" NUMBER,
    "ICX_RATE$178" NUMBER,
    "ICX_RATE_DATE$178" VARCHAR(20),
    "ICX_RATE_TYPE$178" VARCHAR(30),
    "ICX_REF_NUM$178" VARCHAR(30),
    "ICX_REQUESTOR$178" VARCHAR(2000),
    "ICX_REQ_DATE$178" VARCHAR(20),
    "ICX_REQ_HEADER_ID$178" NUMBER,
    "ICX_REQ_LINE_ID$178" NUMBER,
    "ICX_REQ_NUM$178" VARCHAR(30),
    "ICX_RFQ_REQUIRED$178" VARCHAR(5),
    "ICX_SOURCE_ORGANIZATION_ID$178" NUMBER,
    "ICX_SOURCE_REQ_LINE_ID$178" NUMBER,
    "ICX_SOURCE_SUBINVENTORY$178" VARCHAR(10),
    "ICX_SOURCE_TYPE_CODE$178" VARCHAR(25),
    "ICX_STATUS$178" VARCHAR(25),
    "ICX_SUGGESTED_BUYER_ID$178" NUMBER,
    "ICX_SUGGESTED_VENDOR_CONTA$178" VARCHAR(37),
    "ICX_SUGGESTED_VENDOR_ITEM_$178" VARCHAR(25),
    "ICX_SUGGESTED_VENDOR_PHONE$178" VARCHAR(20),
    "ICX_SUPPLIER$178" VARCHAR(80),
    "ICX_SUPSITE$178" VARCHAR(240),
    "ICX_TRAN_REASON_CODE$178" VARCHAR(25),
    "ICX_UN_NUMBER_ID$178" NUMBER,
    "ICX_UOM$178" VARCHAR(25),
    "ICX_URGENT_FLAG$178" VARCHAR(1),
    "ICX_USSGL_TRAN_CODE$178" VARCHAR(30),
    "ICX_VENDOR_SOURCE_CONTEXT$178" VARCHAR(30),
    "LINE_LOCATION_ID$178" NUMBER,
    "TO_PERSON_ID$178" NUMBER,
    "VENDOR_ID$178" NUMBER);
  PROCEDURE DEFAULT_MISSING (P_REC IN OUT REC);
END "AK$ICX_PO_REQUISITION_LINES_IN";

 

/
