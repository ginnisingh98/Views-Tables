--------------------------------------------------------
--  DDL for Package ICX_POR_EXT_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_EXT_ITEM" AUTHID CURRENT_USER AS
/* $Header: ICXEXTIS.pls 115.13 2004/05/04 14:53:28 srmani ship $*/
NULL_NUMBER		PLS_INTEGER := -2;
-- Price document type
TEMPLATE_TYPE		PLS_INTEGER := 1;
CONTRACT_TYPE		PLS_INTEGER := 2;
ASL_TYPE		PLS_INTEGER := 3;
PURCHASING_ITEM_TYPE	PLS_INTEGER := 4;
INTERNAL_TEMPLATE_TYPE	PLS_INTEGER := 5;
INTERNAL_ITEM_TYPE	PLS_INTEGER := 6;
BULKLOAD_TYPE		PLS_INTEGER := 7;
GLOBAL_AGREEMENT_TYPE	PLS_INTEGER := 8;

-- Bug#3352834 : Dummy request IDs
TEMPLATE_TEMP_REQUEST_ID    PLS_INTEGER := -10123;
CONTRACT_TEMP_REQUEST_ID    PLS_INTEGER := -10234;
GA_TEMP_REQUEST_ID          PLS_INTEGER := -10345;
ASL_TEMP_REQUEST_ID         PLS_INTEGER := -10456;
ITEM_TEMP_REQUEST_ID        PLS_INTEGER := -10567;
NEW_PRICE_TEMP_REQUEST_ID   PLS_INTEGER := -10789;
CURRENT_REQUEST_ID          PLS_INTEGER := 0;

-- Bug#3542291 : Dummy Request IDs to be used in setActiveFlags
AF_TEMPLATE_TEMP_REQUEST_ID    PLS_INTEGER := -20123;
AF_CONTRACT_TEMP_REQUEST_ID    PLS_INTEGER := -20234;
AF_GA_TEMP_REQUEST_ID          PLS_INTEGER := -20345;
AF_ASL_TEMP_REQUEST_ID         PLS_INTEGER := -20456;
AF_ITEM_TEMP_REQUEST_ID        PLS_INTEGER := -20567;
AF_CLEANUP_TEMP_REQUEST_ID     PLS_INTEGER := -20678;
AF_NEW_PRICE_TEMP_REQUEST_ID   PLS_INTEGER := -20789;
AF_CURRENT_REQUEST_ID          PLS_INTEGER := 0;

FUNCTION getDocumentType(pPriceType	IN VARCHAR2)
  RETURN VARCHAR2;
PROCEDURE cleanupPrices;
PROCEDURE extractItemData;

-- Create functions to get active flag, description, else

FUNCTION getActiveFlag(p_price_type		IN VARCHAR2,
                       p_price_row_id 		IN ROWID)
  RETURN VARCHAR2;

FUNCTION getItemActiveFlag(p_inventory_item_id	IN NUMBER,
                           p_org_id 		IN NUMBER)
  RETURN VARCHAR2;

FUNCTION getItemSourceType(p_price_type				IN VARCHAR2,
                           p_inventory_item_id			IN NUMBER,
                           p_purchasing_enabled_flag		IN VARCHAR2,
                           p_outside_operation_flag		IN VARCHAR2,
                           p_list_price_per_unit		IN NUMBER,
                           p_load_master_item			IN VARCHAR2,
                           p_internal_order_enabled_flag	IN VARCHAR2,
                           p_load_internal_item			IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION getSearchType(p_price_type			IN VARCHAR2,
                       p_inventory_item_id		IN NUMBER,
                       p_purchasing_enabled_flag	IN VARCHAR2,
                       p_outside_operation_flag		IN VARCHAR2,
                       p_list_price_per_unit		IN NUMBER,
                       p_load_master_item		IN VARCHAR2,
                       p_internal_order_enabled_flag	IN VARCHAR2,
                       p_load_internal_item		IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION getMatchTempalteFlag(p_price_type	IN VARCHAR2,
                              p_rt_item_id	IN NUMBER,
                              p_template_id	IN VARCHAR2)
  RETURN VARCHAR2;

-- This function is only used by bulk loader code
-- It returns 'Y' -- Active
--            'N' -- Inactive
--            'A' -- ASL price should be reset
FUNCTION getBulkLoadActiveFlag(p_action			IN VARCHAR2,
                               p_rt_item_id		IN NUMBER)
  RETURN VARCHAR2;

-- Bug : 3345608
--
-- Function
--   getRate
--
-- Purpose
--    Returns the rate between the from currency and the functional
--    currency of the set of books.
--
-- Arguments
--   x_set_of_books_id        Set of books id
--   x_from_currency          From currency
--   x_conversion_date        Conversion date
--   x_conversion_type        Conversion type
--   x_purchasing_org_id      Purchasing Operating Unit ID
--   x_owning_org_id          Owning org ID
--   x_segment1               Blanket Segment1
--
FUNCTION getRate (
              x_set_of_books_id       NUMBER,
              x_from_currency         VARCHAR2,
              x_conversion_date       DATE,
              x_conversion_type       VARCHAR2 DEFAULT NULL,
              x_purchasing_org_id     NUMBER,
              x_owning_org_id         NUMBER,
              x_segment1              VARCHAR2) RETURN NUMBER;

-- Update Request Ids.
PROCEDURE updatePriceRequestIds;

END ICX_POR_EXT_ITEM;

 

/
