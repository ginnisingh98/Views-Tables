--------------------------------------------------------
--  DDL for Package OE_LINE_CL_DEP_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_CL_DEP_ATTR" AUTHID CURRENT_USER AS
/* $Header: OEXNLINS.pls 115.18 2003/11/07 18:23:58 kmuruges ship $ */


PROCEDURE ACCOUNTING_RULE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE ACCOUNTING_RULE_DURATION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE AGREEMENT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE CUST_PO_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE DELIVER_TO_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE DELIVER_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE DEMAND_CLASS
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE DEP_PLAN_REQUIRED
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE EARLIEST_ACCEPTABLE_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE FOB_POINT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE FREIGHT_CARRIER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE FREIGHT_TERMS
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE INTERMED_SHIP_TO_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE INTERMED_SHIP_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE INVOICE_TO_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE INVOICE_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE INVOICING_RULE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE ITEM_IDENTIFIER_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE ITEM_REVISION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE LATEST_ACCEPTABLE_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE LINE_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE ORDERED_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE ORDER_QUANTITY_UOM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE PAYMENT_TERM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE PRICE_LIST
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE PRICING_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE PROMISE_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE REQUEST_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE RETURN_REASON
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SALESREP
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SCHEDULE_ARRIVAL_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SCHEDULE_SHIP_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SHIPMENT_PRIORITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SHIPPING_METHOD
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SHIP_FROM_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SHIP_TOLERANCE_ABOVE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SHIP_TOLERANCE_BELOW
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SHIP_TO_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SHIP_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SOLD_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SOURCE_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SPLIT_FROM_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE TAX
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE TAX_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);


PROCEDURE TAX_EXEMPT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);


PROCEDURE TAX_EXEMPT_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE TAX_EXEMPT_REASON
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE TAX_POINT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SERVICE_DURATION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SERVICE_PERIOD
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SERVICE_START_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SERVICE_END_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SERVICE_COTERMINATE_FLAG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SERVICE_TXN_COMMENTS
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE SERVICE_REFERENCE_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE BLANKET_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE END_CUSTOMER_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);


PROCEDURE END_CUSTOMER_SITE_USE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE END_CUSTOMER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE IB_OWNER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE IB_INSTALLED_AT_LOCATION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

PROCEDURE IB_CURRENT_LOCATION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
);

END OE_Line_Cl_Dep_Attr;

 

/
