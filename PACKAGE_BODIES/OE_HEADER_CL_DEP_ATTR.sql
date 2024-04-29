--------------------------------------------------------
--  DDL for Package Body OE_HEADER_CL_DEP_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_CL_DEP_ATTR" AS
/* $Header: OEXNHDRB.pls 115.17 2003/11/07 18:04:20 kmuruges ship $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Header_Cl_Dep_Attr';

PROCEDURE ACCOUNTING_RULE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_ACCOUNTING_RULE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END ACCOUNTING_RULE;

PROCEDURE ACCOUNTING_RULE_DURATION
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_ACCOUNTING_RULE_DURATION
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END ACCOUNTING_RULE_DURATION;

PROCEDURE AGREEMENT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_AGREEMENT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END AGREEMENT;

PROCEDURE CHECK_NUMBER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CHECK_NUMBER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CHECK_NUMBER;

PROCEDURE CONVERSION_RATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CONVERSION_RATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CONVERSION_RATE;

PROCEDURE CONVERSION_RATE_DATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CONVERSION_RATE_DATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CONVERSION_RATE_DATE;

PROCEDURE CUSTOMER_PREFERENCE_SET
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CUSTOMER_PREFERENCE_SET
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CUSTOMER_PREFERENCE_SET;

PROCEDURE CONVERSION_TYPE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CONVERSION_TYPE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CONVERSION_TYPE;

PROCEDURE CREDIT_CARD_APPROVAL
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CREDIT_CARD_APPROVAL
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CREDIT_CARD_APPROVAL;

PROCEDURE CREDIT_CARD
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CREDIT_CARD
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CREDIT_CARD;

PROCEDURE CREDIT_CARD_EXPIRATION_DATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CREDIT_CARD_EXPIRATION_DATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CREDIT_CARD_EXPIRATION_DATE;

PROCEDURE CREDIT_CARD_APPROVAL_DATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CREDIT_CARD_APPROVAL_DATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CREDIT_CARD_APPROVAL_DATE;

PROCEDURE CREDIT_CARD_HOLDER_NAME
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CREDIT_CARD_HOLDER_NAME
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CREDIT_CARD_HOLDER_NAME;

PROCEDURE CREDIT_CARD_NUMBER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CREDIT_CARD_NUMBER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CREDIT_CARD_NUMBER;

PROCEDURE CUST_PO_NUMBER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_CUST_PO_NUMBER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END CUST_PO_NUMBER;

PROCEDURE DELIVER_TO_CONTACT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_DELIVER_TO_CONTACT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END DELIVER_TO_CONTACT;

PROCEDURE DELIVER_TO_ORG
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_DELIVER_TO_ORG
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END DELIVER_TO_ORG;

PROCEDURE DEMAND_CLASS
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_DEMAND_CLASS
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END DEMAND_CLASS;

PROCEDURE DEFAULT_FULFILLMENT_SET
( p_initial_header_rec         IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec             IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec               IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id => OE_Header_Util.G_DEFAULT_FULFILLMENT_SET
    , p_initial_header_rec      => p_initial_header_rec
    , p_old_header_rec          => p_old_header_rec
    , p_x_header_rec            => p_x_header_rec
    );
END DEFAULT_FULFILLMENT_SET;

PROCEDURE EARLIEST_SCHEDULE_LIMIT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_EARLIEST_SCHEDULE_LIMIT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END EARLIEST_SCHEDULE_LIMIT;

PROCEDURE EXPIRATION_DATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_EXPIRATION_DATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END EXPIRATION_DATE;

PROCEDURE FIRST_ACK
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_FIRST_ACK
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END FIRST_ACK;

PROCEDURE FIRST_ACK_DATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_FIRST_ACK_DATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END FIRST_ACK_DATE;

PROCEDURE FOB_POINT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_FOB_POINT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END FOB_POINT;

PROCEDURE FREIGHT_CARRIER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_FREIGHT_CARRIER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END FREIGHT_CARRIER;

PROCEDURE FREIGHT_TERMS
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_FREIGHT_TERMS
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END FREIGHT_TERMS;

PROCEDURE INVOICE_TO_CONTACT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_INVOICE_TO_CONTACT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END INVOICE_TO_CONTACT;

PROCEDURE INVOICE_TO_ORG
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_INVOICE_TO_ORG
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END INVOICE_TO_ORG;

PROCEDURE INVOICING_RULE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_INVOICING_RULE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END INVOICING_RULE;

PROCEDURE LAST_ACK
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_LAST_ACK
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END LAST_ACK;

PROCEDURE LAST_ACK_DATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_LAST_ACK_DATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END LAST_ACK_DATE;

PROCEDURE LATEST_SCHEDULE_LIMIT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_LATEST_SCHEDULE_LIMIT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END LATEST_SCHEDULE_LIMIT;

PROCEDURE ORDERED_DATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_ORDERED_DATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END ORDERED_DATE;

PROCEDURE ORDER_DATE_TYPE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_ORDER_DATE_TYPE_CODE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END ORDER_DATE_TYPE;

PROCEDURE ORDER_NUMBER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_ORDER_NUMBER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END ORDER_NUMBER;

PROCEDURE ORDER_SOURCE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_ORDER_SOURCE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END ORDER_SOURCE;

PROCEDURE ORDER_TYPE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_ORDER_TYPE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END ORDER_TYPE;

PROCEDURE PACKING_INSTRUCTIONS
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_PACKING_INSTRUCTIONS
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END PACKING_INSTRUCTIONS;

PROCEDURE PARTIAL_SHIPMENTS_ALLOWED
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_PARTIAL_SHIPMENTS_ALLOWED
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END PARTIAL_SHIPMENTS_ALLOWED;

PROCEDURE PAYMENT_AMOUNT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_PAYMENT_AMOUNT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END PAYMENT_AMOUNT;

PROCEDURE PAYMENT_TERM
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_PAYMENT_TERM
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END PAYMENT_TERM;

PROCEDURE PAYMENT_TYPE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_PAYMENT_TYPE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END PAYMENT_TYPE;

PROCEDURE PRICE_LIST
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_PRICE_LIST
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END PRICE_LIST;

PROCEDURE PRICING_DATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_PRICING_DATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END PRICING_DATE;

PROCEDURE REQUEST_DATE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_REQUEST_DATE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END REQUEST_DATE;

PROCEDURE REQUEST
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_REQUEST
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END REQUEST;

PROCEDURE RETURN_REASON
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_RETURN_REASON
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END RETURN_REASON;

PROCEDURE SALESREP
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SALESREP
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SALESREP;

PROCEDURE SHIPMENT_PRIORITY
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SHIPMENT_PRIORITY
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SHIPMENT_PRIORITY;

PROCEDURE SHIPPING_INSTRUCTIONS
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SHIPPING_INSTRUCTIONS
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SHIPPING_INSTRUCTIONS;

PROCEDURE SHIPPING_METHOD
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SHIPPING_METHOD
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SHIPPING_METHOD;

PROCEDURE SHIP_FROM_ORG
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SHIP_FROM_ORG
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SHIP_FROM_ORG;

PROCEDURE SHIP_TOLERANCE_ABOVE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SHIP_TOLERANCE_ABOVE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SHIP_TOLERANCE_ABOVE;

PROCEDURE SHIP_TOLERANCE_BELOW
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SHIP_TOLERANCE_BELOW
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SHIP_TOLERANCE_BELOW;

PROCEDURE SHIP_TO_CONTACT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SHIP_TO_CONTACT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SHIP_TO_CONTACT;

PROCEDURE SHIP_TO_ORG
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SHIP_TO_ORG
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SHIP_TO_ORG;

PROCEDURE SOLD_TO_CONTACT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SOLD_TO_CONTACT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SOLD_TO_CONTACT;

PROCEDURE SOLD_TO_ORG
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SOLD_TO_ORG
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SOLD_TO_ORG;

PROCEDURE SOURCE_DOCUMENT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SOURCE_DOCUMENT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SOURCE_DOCUMENT;

PROCEDURE SOURCE_DOCUMENT_TYPE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_SOURCE_DOCUMENT_TYPE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END SOURCE_DOCUMENT_TYPE;

PROCEDURE TAX_EXEMPT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_TAX_EXEMPT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END TAX_EXEMPT;

PROCEDURE TAX_EXEMPT_NUMBER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_TAX_EXEMPT_NUMBER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END TAX_EXEMPT_NUMBER;

PROCEDURE TAX_EXEMPT_REASON
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_TAX_EXEMPT_REASON
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END TAX_EXEMPT_REASON;

PROCEDURE TAX_POINT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_TAX_POINT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END TAX_POINT;

PROCEDURE TRANSACTIONAL_CURR
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_TRANSACTIONAL_CURR
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END TRANSACTIONAL_CURR;

PROCEDURE VERSION_NUMBER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_VERSION_NUMBER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END VERSION_NUMBER;

PROCEDURE BLANKET_NUMBER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_BLANKET_NUMBER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END BLANKET_NUMBER;

PROCEDURE TRANSACTION_PHASE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_TRANSACTION_PHASE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );

END TRANSACTION_PHASE;

PROCEDURE END_CUSTOMER_CONTACT
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
)IS
BEGIN
OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_END_CUSTOMER_CONTACT
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );
END END_CUSTOMER_CONTACT;

PROCEDURE END_CUSTOMER_SITE_USE
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
)IS
BEGIN
OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_END_CUSTOMER_SITE_USE
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );
END END_CUSTOMER_SITE_USE;

PROCEDURE END_CUSTOMER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
)IS
BEGIN
OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_END_CUSTOMER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );
END END_CUSTOMER;


PROCEDURE IB_OWNER
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
)IS
BEGIN
OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_IB_OWNER
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );
END IB_OWNER;

PROCEDURE IB_INSTALLED_AT_LOCATION
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
)IS
BEGIN
OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_IB_INSTALLED_AT_LOCATION
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );
END IB_INSTALLED_AT_LOCATION;

PROCEDURE IB_CURRENT_LOCATION
( p_initial_header_rec	IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_old_header_rec 		IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, p_x_header_rec		IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
)IS
BEGIN
OE_Header_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Util.G_IB_CURRENT_LOCATION
    , p_initial_header_rec	=> p_initial_header_rec
    , p_old_header_rec		=> p_old_header_rec
    , p_x_header_rec		=> p_x_header_rec
    );
END IB_CURRENT_LOCATION;

END OE_Header_Cl_Dep_Attr;

/
