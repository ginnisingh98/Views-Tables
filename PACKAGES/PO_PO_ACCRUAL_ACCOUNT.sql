--------------------------------------------------------
--  DDL for Package PO_PO_ACCRUAL_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PO_ACCRUAL_ACCOUNT" AUTHID CURRENT_USER AS
/* $Header: POXWFB3S.pls 115.4 2002/11/25 21:50:30 sbull ship $*/

    FUNCTION BUILD (
        FB_FLEX_NUM IN NUMBER DEFAULT 101,
        BOM_COST_ELEMENT_ID IN VARCHAR2 DEFAULT NULL,
        BOM_RESOURCE_ID IN VARCHAR2 DEFAULT NULL,
        BUDGET_ACCOUNT_ID IN VARCHAR2 DEFAULT NULL,
        CATEGORY_ID IN VARCHAR2 DEFAULT NULL,
        CODE_COMBINATION_ID IN VARCHAR2 DEFAULT NULL,
        DELIVER_TO_LOCATION_ID IN VARCHAR2 DEFAULT NULL,
        DESTINATION_ORGANIZATION_ID IN VARCHAR2 DEFAULT NULL,
        DESTINATION_SUBINVENTORY IN VARCHAR2 DEFAULT NULL,
        DESTINATION_TYPE_CODE IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT1 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT10 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT11 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT12 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT13 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT14 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT15 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT2 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT3 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT4 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT5 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT6 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT7 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT8 IN VARCHAR2 DEFAULT NULL,
        DISTRIBUTION_ATT9 IN VARCHAR2 DEFAULT NULL,
        EXPENDITURE_ITEM_DATE IN VARCHAR2 DEFAULT NULL,
        EXPENDITURE_ORGANIZATION_ID IN VARCHAR2 DEFAULT NULL,
        EXPENDITURE_TYPE IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT1 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT10 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT11 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT12 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT13 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT14 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT15 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT2 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT3 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT4 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT5 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT6 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT7 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT8 IN VARCHAR2 DEFAULT NULL,
        HEADER_ATT9 IN VARCHAR2 DEFAULT NULL,
        ITEM_ID IN VARCHAR2 DEFAULT NULL,
        LINE_ATT1 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT10 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT11 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT12 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT13 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT14 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT15 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT2 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT3 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT4 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT5 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT6 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT7 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT8 IN VARCHAR2 DEFAULT NULL,
        LINE_ATT9 IN VARCHAR2 DEFAULT NULL,
        LINE_TYPE_ID IN VARCHAR2 DEFAULT NULL,
        PA_BILLABLE_FLAG IN VARCHAR2 DEFAULT NULL,
        PREPARER_ID IN VARCHAR2 DEFAULT NULL,
        PROJECT_ID IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT1 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT10 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT11 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT12 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT13 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT14 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT15 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT2 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT3 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT4 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT5 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT6 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT7 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT8 IN VARCHAR2 DEFAULT NULL,
        SHIPMENT_ATT9 IN VARCHAR2 DEFAULT NULL,
        SOURCE_DOCUMENT_HEADER_ID IN VARCHAR2 DEFAULT NULL,
        SOURCE_DOCUMENT_LINE_ID IN VARCHAR2 DEFAULT NULL,
        SOURCE_DOCUMENT_TYPE_CODE IN VARCHAR2 DEFAULT NULL,
        TASK_ID IN VARCHAR2 DEFAULT NULL,
        TO_PERSON_ID IN VARCHAR2 DEFAULT NULL,
        TYPE_LOOKUP_CODE IN VARCHAR2 DEFAULT NULL,
        VENDOR_ID IN VARCHAR2 DEFAULT NULL,
        WIP_ENTITY_ID IN VARCHAR2 DEFAULT NULL,
        WIP_ENTITY_TYPE IN VARCHAR2 DEFAULT NULL,
        WIP_LINE_ID IN VARCHAR2 DEFAULT NULL,
        WIP_OPERATION_SEQ_NUM IN VARCHAR2 DEFAULT NULL,
        WIP_REPETITIVE_SCHEDULE_ID IN VARCHAR2 DEFAULT NULL,
        WIP_RESOURCE_SEQ_NUM IN VARCHAR2 DEFAULT NULL,
        FB_FLEX_SEG IN OUT NOCOPY VARCHAR2,
        FB_ERROR_MSG IN OUT NOCOPY VARCHAR2)
        RETURN BOOLEAN;

END PO_PO_ACCRUAL_ACCOUNT;

 

/
