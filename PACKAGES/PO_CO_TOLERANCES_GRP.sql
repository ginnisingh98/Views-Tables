--------------------------------------------------------
--  DDL for Package PO_CO_TOLERANCES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CO_TOLERANCES_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_CO_TOLERANCES_GRP.pls 120.4.12010000.2 2008/11/03 10:14:59 rojain ship $ */

--<R12 REQUESTER DRIVEN PROCUREMENT START>
-------------------------------------------------------------------
--GLOBAL VARIABLES: Change Order Type
--
--DESCRIPTION   : These variables correspond to the Tolerances
--                Change order type lookup codes
--
--CHANGE History: Created    SVASAMSE
-------------------------------------------------------------------
-- For Supplier Change Order Tolerances
G_SUPP_CHG_APP CONSTANT VARCHAR2(20) := 'SCO';

-- For iP, Requisition Change Auto-Approval Tolerances
G_RCO_REQ_APP  CONSTANT VARCHAR2(20) := 'RCO_REQ_APP';

-- For iP, Buyer Auto-Approval Tolerances
-- This includes the Routing flag
G_RCO_BUY_APP  CONSTANT VARCHAR2(20) := 'RCO_BUYER_APP';

-- For iP, Internal Requisition Change Auto-Approval Tolerances
G_RCO_INT_REQ_APP  CONSTANT VARCHAR2(20) := 'RCO_INT_REQ_APP';

-- For PO
G_CHG_AGREEMENTS  CONSTANT VARCHAR2(20) := 'CO_AGREEMENTS';
G_CHG_RELEASES   CONSTANT VARCHAR2(20) := 'CO_RELEASES';
G_CHG_ORDERS   CONSTANT VARCHAR2(20) := 'CO_ORDERS';


-------------------------------------------------------------------
--GLOBAL VARIABLES: Tolerances
--
--DESCRIPTION   : These variables correspond to the Tolerance names
-- 		 		  lookup codes.
--
--CHANGE History: Created    SVASAMSE
-------------------------------------------------------------------
G_DOCUMENT_AMOUNT_VALUE   CONSTANT VARCHAR2(40) := 'DOCUMENT_AMOUNT_VALUE';
G_DOCUMENT_AMOUNT_PERCENT CONSTANT VARCHAR2(40) := 'DOCUMENT_AMOUNT_PERCENT';

G_REQUISITION_AMOUNT_VALUE CONSTANT VARCHAR2(40) := 'REQUISITION_AMOUNT_VALUE';
G_REQUISITION_AMOUNT_PERCENT  CONSTANT VARCHAR2(40) := 'REQUISITION_AMOUNT_PERCENT';

G_LINE_AMOUNT_VALUE    CONSTANT VARCHAR2(40) := 'LINE_AMOUNT_VALUE';
G_LINE_AMOUNT_PERCENT  CONSTANT VARCHAR2(40) := 'LINE_AMOUNT_PERCENT';

G_REQ_LINE_AMOUNT_VALUE   CONSTANT VARCHAR2(40) := 'REQ_LINE_AMOUNT_VALUE';
G_REQ_LINE_AMOUNT_PERCENT CONSTANT VARCHAR2(40) := 'REQ_LINE_AMOUNT_PERCENT';

G_SHIPMENT_AMOUNT_VALUE   CONSTANT VARCHAR2(40) := 'SHIPMENT_AMOUNT_VALUE';
G_SHIPMENT_AMOUNT_PERCENT CONSTANT VARCHAR2(40) := 'SHIPMENT_AMOUNT_PERCENT';
G_PAY_ITEM_AMOUNT_VALUE   CONSTANT VARCHAR2(40) := 'PAY_ITEM_AMOUNT_VALUE'; -- <Complex Work R12>
G_PAY_ITEM_AMOUNT_PERCENT CONSTANT VARCHAR2(40) := 'PAY_ITEM_AMOUNT_PERCENT'; -- <Complex Work R12>



G_DISTRIBUTION_AMOUNT_PERCENT CONSTANT VARCHAR2(40) := 'DISTRIBUTION_AMOUNT_PERCENT';

G_UNIT_PRICE 	CONSTANT VARCHAR2(40) := 'UNIT_PRICE';
G_SHIPMENT_PRICE  CONSTANT VARCHAR2(40) := 'SHIPMENT_PRICE';
G_PAY_ITEM_PRICE CONSTANT VARCHAR2(40) := 'PAY_ITEM_PRICE'; -- <Complex Work R12>
G_PRC_BRK_PRICE  CONSTANT VARCHAR2(40) := 'PRC_BRK_PRICE';
G_PRC_BRK_QTY 	CONSTANT VARCHAR2(40) := 'PRC_BRK_QTY';
G_PRICE_LIMIT	CONSTANT VARCHAR2(40) := 'PRICE_LIMIT';
G_HEADER_AMOUNT_AGREED  CONSTANT VARCHAR2(40) := 'HEADER_AMOUNT_AGREED';
G_HEADER_AMOUNT_LIMIT	 CONSTANT VARCHAR2(40) := 'HEADER_AMOUNT_LIMIT';
G_PO_AMOUNT  CONSTANT VARCHAR2(40) := 'PO_AMOUNT';
G_LINE_QTY_AGREED  CONSTANT VARCHAR2(40) := 'LINE_QTY_AGREED';
G_LINE_AMOUNT_AGREED	CONSTANT VARCHAR2(40) := 'LINE_AMOUNT_AGREED';

G_SHIPMENT_QTY  CONSTANT VARCHAR2(40) := 'SHIPMENT_QTY';
G_PAY_ITEM_QTY CONSTANT VARCHAR2(40) := 'PAY_ITEM_QTY'; -- <Complex Work R12>
G_LINE_QTY     CONSTANT VARCHAR2(40) := 'LINE_QTY';
G_REQUISITION_LINE_QTY  CONSTANT VARCHAR2(40) := 'REQUISITION_LINE_QTY';
G_DISTRIBUTION_QTY  CONSTANT VARCHAR2(40) := 'DISTRIBUTION_QTY';

G_START_DATE CONSTANT VARCHAR2(40) := 'START_DATE';
G_END_DATE CONSTANT VARCHAR2(40) := 'END_DATE';
G_NEED_BY_DATE  CONSTANT VARCHAR2(40) := 'NEED_BY_DATE';
G_PROMISED_DATE  CONSTANT VARCHAR2(40) := 'PROMISED_DATE';

-- For iP, routing flag
G_RCO_BUYER_APPROVAL_FLAG  CONSTANT VARCHAR2(40) := 'RCO_ROUTING';

-- For SCO, routing flags
G_PROMISED_DATE_APPROVAL_FLAG CONSTANT VARCHAR2(40) := 'PROMISED_DATE_APPROVAL';
G_SHIPMENT_QTY_APPROVAL_FLAG  CONSTANT VARCHAR2(40) := 'SHIPMENT_QTY_APPROVAL';
G_PRICE_APPROVAL_FLAG  CONSTANT VARCHAR2(40) := 'PRICE_APPROVAL';

-------------------------------------------------------------------
--GLOBAL VARIABLES: PL/SQL Table
--
--DESCRIPTION   : Tolerances table used to store the data retrieved
--
--CHANGE History: Created    SVASAMSE
-------------------------------------------------------------------
-- Record used in retrieving the max increment and max decrecment values
TYPE tolerances_rec_type IS RECORD (
	TOLERANCE_NAME 	VARCHAR2(30),
	MAX_INCREMENT	NUMBER,
	MAX_DECREMENT	NUMBER,
	ENABLED_FLAG	VARCHAR2(1)
);

-- Table of the tolerances record
TYPE tolerances_tbl_type IS TABLE OF tolerances_rec_type INDEX BY BINARY_INTEGER;

------------------------------------------------------------------------------
--Start of Comments
--Name: GET_TOLERANCES
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--   1. This procedure will retrieve the tolerances of a
--      given change order type and operating unit.
--Parameters:
--IN:
--  p_api_version
--    Used to determine compatibility of API and calling program
--  p_init_msg_list
--    True/False parameter to initialize message list
--  p_organization_id
--    Operating Unit Id
--  p_change_order_type
--    Change Order Type for which the tolerances should be retrieved.
--OUT:
--  x_tolerances_tbl
--    Table containing the tolerances and their values
--  x_return_status
--    The standard OUT parameter giving return status of the API call.
--    FND_API.G_RET_STS_ERROR - for expected error
--        FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--        FND_API.G_RET_STS_SUCCESS - for success
--  x_msg_count
--        The count of number of messages added to the message list in this call
--  x_msg_data
--        If the count is 1 then x_msg_data contains the message returned
--End of Comment
-------------------------------------------------------------------------------
procedure GET_TOLERANCES(p_api_version IN NUMBER,
           		 p_init_msg_list IN VARCHAR2,
           		 p_organization_id IN NUMBER,
           		 p_change_order_type IN VARCHAR2,
           		 x_tolerances_tbl IN OUT NOCOPY tolerances_tbl_type,
			 x_return_status OUT NOCOPY VARCHAR2,
           		 x_msg_count OUT NOCOPY NUMBER,
           		 x_msg_data OUT NOCOPY VARCHAR2);

--<R12 REQUESTER DRIVEN PROCUREMENT END>

END;

/
