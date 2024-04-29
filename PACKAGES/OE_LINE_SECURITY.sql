--------------------------------------------------------
--  DDL for Package OE_LINE_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_SECURITY" AUTHID CURRENT_USER AS
/* $Header: OEXXLINS.pls 120.6.12010000.2 2008/12/02 08:09:46 vbkapoor ship $ */


-- Package Globals
g_check_all_cols_constraint VARCHAR2(1) := 'Y';
g_is_caller_defaulting      VARCHAR2(1) := 'N';
-- Entity global record that is used in APIs for validation templates
-- and the generated validation packages to access attribute values
-- on the entity record
g_record				   OE_AK_ORDER_LINES_V%ROWTYPE;
g_operation_action		   NUMBER;

FUNCTION ACCOUNTING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ACCOUNTING_RULE_DURATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION calculate_price_flag(p_operation IN        VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
                             ,p_record              IN oe_ak_order_lines_v%ROWTYPE
                             ,x_on_operation_action OUT NOCOPY NUMBER)
RETURN NUMBER;

FUNCTION COMMITMENT_ID
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION AGREEMENT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION AUTHORIZED_TO_SHIP
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

-- Start of fix #1459428

FUNCTION ATTRIBUTE1
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE10
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE11
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE12
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE13
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE14
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE15
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

-- For bug 2184255
FUNCTION ATTRIBUTE16
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE17
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE18
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE19
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE20
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE3
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE4
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE5
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE6
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE7
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE8
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ATTRIBUTE9
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION CONTEXT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

--  End of fix #1459428

FUNCTION CREATED_BY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION CREDIT_INVOICE_LINE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION CUSTOMER_LINE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION CUSTOMER_TRX_LINE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION CUST_PO_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

-- Added for bug #7608170
FUNCTION CUSTOMER_JOB
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION DELIVERY_LEAD_TIME
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION DELIVER_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION DELIVER_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION DEMAND_CLASS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION DEP_PLAN_REQUIRED
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION EARLIEST_ACCEPTABLE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION END_ITEM_UNIT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION FOB_POINT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION FREIGHT_CARRIER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION FREIGHT_TERMS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION FULFILLED_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION INVENTORY_ITEM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION INVOICE_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION INVOICE_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION INVOICING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ITEM_REVISION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ITEM_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION LATEST_ACCEPTABLE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION LINE_CATEGORY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION LINE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION LINE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION ORDERED_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

-- OPM 1857167 start

FUNCTION ORDERED_QUANTITY2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

-- OPM 1857167 end

FUNCTION ORDER_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ORIG_SYS_DOCUMENT_REF
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ORIG_SYS_LINE_REF
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION OVER_SHIP_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION OVER_SHIP_RESOLVED
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION PACKING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION PAYMENT_TERM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION PLANNING_PRIORITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION PRICE_LIST
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION PRICING_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION PRICING_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION PRICING_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION PROJECT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION PROMISE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION REFERENCE_CUST_TRX_LINE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION REFERENCE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION REQUEST_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION RETURN_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SALESREP
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIP_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION ARRIVAL_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION SCHEDULE_ARRIVAL_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SCHEDULE_SHIP_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION SHIPMENT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIPMENT_PRIORITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIPPED_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIPPING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIPPING_METHOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIPPING_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIPPING_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIPPING_QUANTITY_UOM2  -- INVCONV
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIP_FROM_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SUBINVENTORY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIP_MODEL_COMPLETE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIP_TOLERANCE_ABOVE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIP_TOLERANCE_BELOW
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIP_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SHIP_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SOLD_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SOURCE_DOCUMENT_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SOURCE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION TASK
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION TAX
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION TAX_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION TAX_EXEMPT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION TAX_EXEMPT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION TAX_EXEMPT_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION UNIT_LIST_PRICE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION UNIT_SELLING_PRICE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION SERVICE_REFERENCE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SERVICE_REFERENCE_LINE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SERVICE_REFERENCE_SYSTEM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

/* Fix to bug 2205900: Added constraints functions for
some missing SERVICE fields */
FUNCTION SERVICE_COTERMINATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SERVICE_DURATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SERVICE_END_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SERVICE_PERIOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SERVICE_START_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SERVICE_TXN_COMMENTS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION SERVICE_TXN_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

/*1449220*/
FUNCTION ITEM_IDENTIFIER_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;
/*1449220*/

FUNCTION USER_ITEM_DESCRIPTION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION BLANKET_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION BLANKET_LINE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION IB_OWNER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION IB_INSTALLED_AT_LOCATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;

FUNCTION IB_CURRENT_LOCATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER;


FUNCTION END_CUSTOMER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER  /* file.sql.39 change */

) RETURN NUMBER;


FUNCTION END_CUSTOMER_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER  /* file.sql.39 change */

) RETURN NUMBER;


FUNCTION END_CUSTOMER_SITE_USE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER  /* file.sql.39 change */

) RETURN NUMBER;

PROCEDURE ALLOW_TAX_CODE_OVERRIDE
( p_application_id                  IN NUMBER,
  p_entity_short_name               IN VARCHAR2,
  p_validation_entity_short_name    IN VARCHAR2,
  p_validation_tmplt_short_name     IN VARCHAR2,
  p_record_set_tmplt_short_name     IN VARCHAR2,
  p_scope                           IN VARCHAR2,
  p_result                          OUT NOCOPY NUMBER  /* file.sql.39 change */
);

PROCEDURE ALLOW_TRX_LINE_EXEMPTIONS
( p_application_id                  IN NUMBER,
  p_entity_short_name               IN VARCHAR2,
  p_validation_entity_short_name    IN VARCHAR2,
  p_validation_tmplt_short_name     IN VARCHAR2,
  p_record_set_tmplt_short_name     IN VARCHAR2,
  p_scope                           IN VARCHAR2,
  p_result                          OUT NOCOPY NUMBER  /* file.sql.39 change */
);

PROCEDURE Entity
(   p_LINE_rec                      IN  OE_Order_PUB.LINE_Rec_Type
,   x_result                        OUT NOCOPY NUMBER  /* file.sql.39 change */
,   x_return_status                 OUT NOCOPY VARCHAR2  /* file.sql.39 change */
);

PROCEDURE Attributes
(   p_LINE_rec                      IN  OE_Order_PUB.LINE_Rec_Type
,   p_old_LINE_rec                  IN  OE_Order_PUB.LINE_Rec_Type := OE_Order_PUB.G_MISS_LINE_REC
,   x_result                        OUT NOCOPY NUMBER  /* file.sql.39 change */
,   x_return_status                 OUT NOCOPY VARCHAR2  /* file.sql.39 change */
);

FUNCTION CONTINGENCY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION REVREC_EXPIRATION_DAYS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

END OE_Line_Security;

/
