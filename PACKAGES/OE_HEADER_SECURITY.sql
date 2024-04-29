--------------------------------------------------------
--  DDL for Package OE_HEADER_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HEADER_SECURITY" AUTHID CURRENT_USER AS
/* $Header: OEXXHDRS.pls 120.0.12010000.2 2009/02/11 08:50:40 haagarwa ship $ */


-- Package Globals
g_check_all_cols_constraint VARCHAR2(1) := 'Y';
g_is_caller_defaulting      VARCHAR2(1) := 'N';
-- Entity global record that is used in APIs for validation templates
-- and the generated validation packages to access attribute values
-- on the entity record
g_record				   OE_AK_ORDER_HEADERS_V%ROWTYPE;

FUNCTION ACCOUNTING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ACCOUNTING_RULE_DURATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION AGREEMENT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

-- Start of fix #1459428

FUNCTION ATTRIBUTE1
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE10
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE11
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE12
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE13
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE14
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE15
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

-- For bug 2184255

FUNCTION ATTRIBUTE16
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE17
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE18
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE19
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE20
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE3
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE4
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE5
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE6
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE7
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE8
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ATTRIBUTE9
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CONTEXT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CONVERSION_RATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CONVERSION_RATE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CONVERSION_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CUSTOMER_PREFERENCE_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREATED_BY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;


FUNCTION CUST_PO_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION DELIVER_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION DELIVER_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION DEMAND_CLASS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;


FUNCTION EARLIEST_SCHEDULE_LIMIT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION FOB_POINT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION FREIGHT_CARRIER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION FREIGHT_TERMS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION INVOICE_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION INVOICE_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION INVOICING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION LATEST_SCHEDULE_LIMIT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;


FUNCTION ORDERED_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ORDER_DATE_TYPE_CODE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ORDER_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ORDER_SOURCE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ORDER_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION ORIG_SYS_DOCUMENT_REF
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION PACKING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION PAYMENT_TERM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION PRICE_LIST
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION PRICING_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION REQUEST_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION RETURN_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SALESREP
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SHIPMENT_PRIORITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SHIPPING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SHIPPING_METHOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SHIP_FROM_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SHIP_TOLERANCE_ABOVE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SHIP_TOLERANCE_BELOW
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SHIP_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SHIP_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SOLD_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SOLD_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SOURCE_DOCUMENT_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION TAX_EXEMPT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION TAX_EXEMPT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION TAX_EXEMPT_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;


FUNCTION TRANSACTIONAL_CURR
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD_APPROVAL_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;


PROCEDURE Entity
(   p_HEADER_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Attributes
(   p_HEADER_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
,   p_old_HEADER_rec                IN  OE_Order_PUB.HEADER_Rec_Type := OE_Order_PUB.G_MISS_HEADER_REC
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

);

/* The following Function is added to fix the issue #1651331 to enable
	  the Sales Channel Field be allowed to set the security rules  */

FUNCTION SALES_CHANNEL_CODE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

/* START PREPAYMENT */
FUNCTION PAYMENT_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD_HOLDER_NAME
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CREDIT_CARD_EXPIRATION_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;
/* END PREPAYMENT */

/* For bug 2395032 */
FUNCTION PAYMENT_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION CHECK_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;
/* End bug 2395032 */

FUNCTION BLANKET_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

-- QUOTING changes

FUNCTION QUOTE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION QUOTE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SALES_DOCUMENT_NAME
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION TRANSACTION_PHASE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION USER_STATUS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION EXPIRATION_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION VERSION_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION SOLD_TO_SITE_USE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

-- QUOTING changes END

FUNCTION IB_OWNER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION IB_INSTALLED_AT_LOCATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION IB_CURRENT_LOCATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;


FUNCTION END_CUSTOMER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;


FUNCTION END_CUSTOMER_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;


FUNCTION END_CUSTOMER_SITE_USE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;

FUNCTION Is_Op_Constrained
( p_operation           IN VARCHAR2
 , p_column_name         IN VARCHAR2 DEFAULT NULL
 , p_record       IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER;


/*---------------------------------------------------------------
PROCEDURE Copied_From_Quote
-- Used to validate the API based template - Copied From Quote
----------------------------------------------------------------*/
PROCEDURE Copied_From_Quote
(p_application_id                 IN NUMBER
,p_entity_short_name              IN VARCHAR2
,p_validation_entity_short_name   IN VARCHAR2
,p_validation_tmplt_short_name    IN VARCHAR2
,p_record_set_short_name          IN VARCHAR2
,p_scope                          IN VARCHAR2
,x_result                         OUT NOCOPY NUMBER
);

-- Bug 8217769 New Function added for Default Fulfillment Set.
FUNCTION DEFAULT_FULFILLMENT_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   x_on_operation_action          OUT  NOCOPY NUMBER
) RETURN NUMBER;
-- Bug 8217769 Function ends.

END OE_Header_Security;

/
