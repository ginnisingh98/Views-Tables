--------------------------------------------------------
--  DDL for Package FTE_PO_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_PO_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: FTEGPOIS.pls 120.1 2005/07/21 15:02:19 schennal noship $ */
/*
-- Global constants
-- +======================================================================+
--   Procedure :
--          Estimated Rate for the given Shipment Header Id
--
--   Description:
--
--   Inputs: Shipment Header Id
--   Output: Table of Receipt Lines w/ Cost and Currency Code
--           See the Record structure for more info
-- +======================================================================+
*/
/*Receipt Record Type for the output table for the calling API*/

TYPE FTE_RECEIPT_LINE_REC IS RECORD
(VENDOR_ID NUMBER,
 VENDOR_SITE_ID NUMBER,
 RCV_SHIPMENT_LINE_ID NUMBER,
 CURRENCY_CODE VARCHAR2(15),
 TOTAL_COST NUMBER,
 RETURN_STATUS VARCHAR2(1),
 MESSAGE_TEXT VARCHAR2(1000));

/**Receipt_Table Type*/

TYPE FTE_RECEIPT_LINES_TAB IS TABLE OF FTE_RECEIPT_LINE_REC INDEX BY BINARY_INTEGER ;

/* Variable Tables for any number, currency ( 15 chars ), uom ( 3 chars )*/

 -- use from wsh_util_core.api
TYPE fte_number_table  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE fte_varchar15_table  IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;
TYPE fte_varchar3_table  IS TABLE OF VARCHAR2(3)  INDEX BY BINARY_INTEGER;
TYPE fte_varchar25_table  IS TABLE OF VARCHAR2(25)  INDEX BY BINARY_INTEGER;

/* This procedure will be used to get the estimated rate from pre-rated shipments */
/* This API will not rate or re-rate during this process. Extract only pre-rated info */
PROCEDURE GET_ESTIMATED_RATES(
      p_init_msg_list           IN  VARCHAR2,
      p_api_version_number      IN  NUMBER,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2,
      p_shipment_header_id      IN  NUMBER,
      x_receipt_lines_tab      OUT NOCOPY FTE_PO_INTEGRATION_GRP.FTE_RECEIPT_LINES_TAB);

END FTE_PO_INTEGRATION_GRP;

 

/
