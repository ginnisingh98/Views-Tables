--------------------------------------------------------
--  DDL for Package Body OE_LINE_CL_DEP_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_CL_DEP_ATTR" AS
/* $Header: OEXNLINB.pls 115.19 2003/11/07 18:27:40 kmuruges ship $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Line_Cl_Dep_Attr';

PROCEDURE ACCOUNTING_RULE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ACCOUNTING_RULE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END ACCOUNTING_RULE;

PROCEDURE ACCOUNTING_RULE_DURATION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ACCOUNTING_RULE_DURATION
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END ACCOUNTING_RULE_DURATION;

PROCEDURE ACTUAL_ARRIVAL_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ACTUAL_ARRIVAL_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END ACTUAL_ARRIVAL_DATE;

PROCEDURE ACTUAL_SHIPMENT_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ACTUAL_SHIPMENT_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END ACTUAL_SHIPMENT_DATE;

PROCEDURE AGREEMENT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_AGREEMENT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END AGREEMENT;

PROCEDURE ARRIVAL_SET
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ARRIVAL_SET
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END ARRIVAL_SET;

PROCEDURE ATO_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ATO_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END ATO_LINE;

PROCEDURE AUTHORIZED_TO_SHIP
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_AUTHORIZED_TO_SHIP
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END AUTHORIZED_TO_SHIP;

PROCEDURE AUTO_SELECTED_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_AUTO_SELECTED_QUANTITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END AUTO_SELECTED_QUANTITY;

PROCEDURE CANCELLED_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CANCELLED_QUANTITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CANCELLED_QUANTITY;

PROCEDURE COMPONENT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_COMPONENT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END COMPONENT;

PROCEDURE COMPONENT_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_COMPONENT_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END COMPONENT_NUMBER;

PROCEDURE COMPONENT_SEQUENCE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_COMPONENT_SEQUENCE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END COMPONENT_SEQUENCE;

PROCEDURE CONFIGURATION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS

BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CONFIGURATION
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CONFIGURATION;

PROCEDURE CONFIG_DISPLAY_SEQUENCE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CONFIG_DISPLAY_SEQUENCE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CONFIG_DISPLAY_SEQUENCE;

PROCEDURE CREDIT_INVOICE_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN


OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CREDIT_INVOICE_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CREDIT_INVOICE_LINE;

PROCEDURE CUSTOMER_DOCK
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CUSTOMER_DOCK
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CUSTOMER_DOCK;

PROCEDURE CUSTOMER_JOB
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CUSTOMER_JOB
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CUSTOMER_JOB;

PROCEDURE CUSTOMER_PRODUCTION_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CUSTOMER_PRODUCTION_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CUSTOMER_PRODUCTION_LINE;

PROCEDURE CUSTOMER_TRX_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CUSTOMER_TRX_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END CUSTOMER_TRX_LINE;

PROCEDURE CUST_MODEL_SERIAL_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CUST_MODEL_SERIAL_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CUST_MODEL_SERIAL_NUMBER;

PROCEDURE CUST_PO_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CUST_PO_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CUST_PO_NUMBER;

PROCEDURE CUST_PRODUCTION_SEQ_NUM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_CUST_PRODUCTION_SEQ_NUM
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END CUST_PRODUCTION_SEQ_NUM;

PROCEDURE DELIVERY_LEAD_TIME
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_DELIVERY_LEAD_TIME
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END DELIVERY_LEAD_TIME;

PROCEDURE DELIVER_TO_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_DELIVER_TO_CONTACT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END DELIVER_TO_CONTACT;

PROCEDURE DELIVER_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_DELIVER_TO_ORG
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END DELIVER_TO_ORG;

PROCEDURE DEMAND_BUCKET_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_DEMAND_BUCKET_TYPE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END DEMAND_BUCKET_TYPE;

PROCEDURE DEMAND_CLASS
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_DEMAND_CLASS
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END DEMAND_CLASS;

PROCEDURE DEP_PLAN_REQUIRED
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_DEP_PLAN_REQUIRED
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END DEP_PLAN_REQUIRED;

PROCEDURE EARLIEST_ACCEPTABLE_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_EARLIEST_ACCEPTABLE_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END EARLIEST_ACCEPTABLE_DATE;

PROCEDURE END_ITEM_UNIT_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_END_ITEM_UNIT_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END END_ITEM_UNIT_NUMBER;

PROCEDURE EXPLOSION_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_EXPLOSION_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END EXPLOSION_DATE;

PROCEDURE FOB_POINT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_FOB_POINT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END FOB_POINT;

PROCEDURE FREIGHT_CARRIER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_FREIGHT_CARRIER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END FREIGHT_CARRIER;

PROCEDURE FREIGHT_TERMS
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_FREIGHT_TERMS
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END FREIGHT_TERMS;

PROCEDURE FULFILLED_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_FULFILLED_QUANTITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END FULFILLED_QUANTITY;

PROCEDURE INTERMED_SHIP_TO_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_INTERMED_SHIP_TO_CONTACT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END INTERMED_SHIP_TO_CONTACT;

PROCEDURE INTERMED_SHIP_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_INTERMED_SHIP_TO_ORG
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END INTERMED_SHIP_TO_ORG;

PROCEDURE INVENTORY_ITEM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_INVENTORY_ITEM
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END INVENTORY_ITEM;

PROCEDURE INVOICE_INTERFACE_STATUS
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_INVOICE_INTERFACE_STATUS
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END INVOICE_INTERFACE_STATUS;

PROCEDURE INVOICE_TO_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_INVOICE_TO_CONTACT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END INVOICE_TO_CONTACT;

PROCEDURE INVOICE_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_INVOICE_TO_ORG
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END INVOICE_TO_ORG;

PROCEDURE INVOICED_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_INVOICED_QUANTITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END INVOICED_QUANTITY;

PROCEDURE INVOICING_RULE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_INVOICING_RULE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END INVOICING_RULE;

PROCEDURE ORDERED_ITEM_ID
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ORDERED_ITEM_ID
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END ORDERED_ITEM_ID;

PROCEDURE ITEM_IDENTIFIER_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ITEM_IDENTIFIER_TYPE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END ITEM_IDENTIFIER_TYPE;

PROCEDURE ORDERED_ITEM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ORDERED_ITEM
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END ORDERED_ITEM;

PROCEDURE ITEM_REVISION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ITEM_REVISION
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END ITEM_REVISION;

PROCEDURE ITEM_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ITEM_TYPE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END ITEM_TYPE;

PROCEDURE LATEST_ACCEPTABLE_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_LATEST_ACCEPTABLE_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END LATEST_ACCEPTABLE_DATE;

PROCEDURE LINE_CATEGORY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_LINE_CATEGORY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END LINE_CATEGORY;

PROCEDURE LINE_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_LINE_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END LINE_NUMBER;

PROCEDURE LINE_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_LINE_TYPE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END LINE_TYPE;

PROCEDURE LINK_TO_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_LINK_TO_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END LINK_TO_LINE;

PROCEDURE MODEL_GROUP_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_MODEL_GROUP_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END MODEL_GROUP_NUMBER;

PROCEDURE OPTION_FLAG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_OPTION_FLAG
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END OPTION_FLAG;

PROCEDURE OPTION_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_OPTION_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END OPTION_NUMBER;

PROCEDURE ORDERED_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ORDERED_QUANTITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END ORDERED_QUANTITY;

PROCEDURE ORDER_QUANTITY_UOM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_ORDER_QUANTITY_UOM
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END ORDER_QUANTITY_UOM;

PROCEDURE OVER_SHIP_REASON
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_OVER_SHIP_REASON
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END OVER_SHIP_REASON;

PROCEDURE OVER_SHIP_RESOLVED
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_OVER_SHIP_RESOLVED
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END OVER_SHIP_RESOLVED;

PROCEDURE PAYMENT_TERM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_PAYMENT_TERM
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END PAYMENT_TERM;

PROCEDURE PRICE_LIST
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_PRICE_LIST
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END PRICE_LIST;

PROCEDURE PRICING_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_PRICING_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END PRICING_DATE;

PROCEDURE PRICING_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_PRICING_QUANTITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END PRICING_QUANTITY;

PROCEDURE PRICING_QUANTITY_UOM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_PRICING_QUANTITY_UOM
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END PRICING_QUANTITY_UOM;

PROCEDURE PROJECT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_PROJECT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END PROJECT;

PROCEDURE PROMISE_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_PROMISE_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END PROMISE_DATE;

PROCEDURE REFERENCE_CUST_TRX_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN


OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_REFERENCE_CUSTOMER_TRX_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END REFERENCE_CUST_TRX_LINE;

PROCEDURE REFERENCE_HEADER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN


OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_REFERENCE_HEADER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END REFERENCE_HEADER;

PROCEDURE REFERENCE_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_REFERENCE_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END REFERENCE_LINE;

PROCEDURE REFERENCE_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_REFERENCE_TYPE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END REFERENCE_TYPE;

PROCEDURE REQUEST_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_REQUEST_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END REQUEST_DATE;

PROCEDURE REQUEST
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_REQUEST
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END REQUEST;

PROCEDURE RESERVED_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_RESERVED_QUANTITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END RESERVED_QUANTITY;

PROCEDURE RETURN_REASON
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_RETURN_REASON
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END RETURN_REASON;

PROCEDURE RLA_SCHEDULE_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_RLA_SCHEDULE_TYPE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END RLA_SCHEDULE_TYPE;

PROCEDURE SALESREP
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SALESREP
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SALESREP;

PROCEDURE SCHEDULE_ACTION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SCHEDULE_ACTION
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SCHEDULE_ACTION;

PROCEDURE SCHEDULE_ARRIVAL_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SCHEDULE_ARRIVAL_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SCHEDULE_ARRIVAL_DATE;

PROCEDURE SCHEDULE_SHIP_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SCHEDULE_SHIP_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SCHEDULE_SHIP_DATE;

PROCEDURE SCHEDULE_STATUS
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SCHEDULE_STATUS
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SCHEDULE_STATUS;

PROCEDURE SHIPMENT_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIPMENT_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIPMENT_NUMBER;

PROCEDURE SHIPMENT_PRIORITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIPMENT_PRIORITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIPMENT_PRIORITY;

PROCEDURE SHIPPED_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIPPED_QUANTITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIPPED_QUANTITY;

PROCEDURE SHIPPING_INTERFACED
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIPPING_INTERFACED
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIPPING_INTERFACED;

PROCEDURE SHIPPING_METHOD
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIPPING_METHOD
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIPPING_METHOD;

PROCEDURE SHIPPING_QUANTITY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIPPING_QUANTITY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIPPING_QUANTITY;

PROCEDURE SHIPPING_QUANTITY_UOM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIPPING_QUANTITY_UOM
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIPPING_QUANTITY_UOM;

PROCEDURE SHIP_FROM_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIP_FROM_ORG
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIP_FROM_ORG;

PROCEDURE SHIP_MODEL_COMPLETE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIP_MODEL_COMPLETE_FLAG
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIP_MODEL_COMPLETE;

PROCEDURE SHIP_SET
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIP_SET
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIP_SET;

PROCEDURE SHIP_TOLERANCE_ABOVE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIP_TOLERANCE_ABOVE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END SHIP_TOLERANCE_ABOVE;

PROCEDURE SHIP_TOLERANCE_BELOW
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIP_TOLERANCE_BELOW
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIP_TOLERANCE_BELOW;

PROCEDURE SHIP_TO_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIP_TO_CONTACT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIP_TO_CONTACT;

PROCEDURE SHIP_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SHIP_TO_ORG
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SHIP_TO_ORG;

PROCEDURE SOLD_TO_ORG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SOLD_TO_ORG
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SOLD_TO_ORG;

PROCEDURE SORT_ORDER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SORT_ORDER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SORT_ORDER;

PROCEDURE SOURCE_DOCUMENT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SOURCE_DOCUMENT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SOURCE_DOCUMENT;

PROCEDURE SOURCE_DOCUMENT_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SOURCE_DOCUMENT_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END SOURCE_DOCUMENT_LINE;

PROCEDURE SOURCE_DOCUMENT_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SOURCE_DOCUMENT_TYPE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END SOURCE_DOCUMENT_TYPE;

PROCEDURE SOURCE_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SOURCE_TYPE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END SOURCE_TYPE;

PROCEDURE SPLIT_FROM_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SPLIT_FROM_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END SPLIT_FROM_LINE;

PROCEDURE TASK
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TASK
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END TASK;

PROCEDURE TAX
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TAX
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END TAX;

PROCEDURE TAX_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TAX_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END TAX_DATE;

PROCEDURE TAX_EXEMPT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TAX_EXEMPT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END TAX_EXEMPT;

PROCEDURE TAX_EXEMPT_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TAX_EXEMPT_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END TAX_EXEMPT_NUMBER;

PROCEDURE TAX_EXEMPT_REASON
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TAX_EXEMPT_REASON
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END TAX_EXEMPT_REASON;

PROCEDURE TAX_POINT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TAX_POINT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END TAX_POINT;

PROCEDURE TAX_RATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TAX_RATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END TAX_RATE;

PROCEDURE TAX_VALUE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TAX_VALUE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END TAX_VALUE;

PROCEDURE TOP_MODEL_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_TOP_MODEL_LINE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END TOP_MODEL_LINE;

PROCEDURE UNIT_LIST_PRICE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_UNIT_LIST_PRICE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END UNIT_LIST_PRICE;

PROCEDURE UNIT_SELLING_PRICE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_UNIT_SELLING_PRICE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END UNIT_SELLING_PRICE;

PROCEDURE VEH_CUS_ITEM_CUM_KEY
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_VEH_CUS_ITEM_CUM_KEY
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END VEH_CUS_ITEM_CUM_KEY;

PROCEDURE VISIBLE_DEMAND
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_VISIBLE_DEMAND
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END VISIBLE_DEMAND;

PROCEDURE SERVICE_TXN_REASON
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_TXN_REASON
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_TXN_REASON;


PROCEDURE SERVICE_DURATION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_DURATION
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_DURATION;


PROCEDURE SERVICE_PERIOD
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_PERIOD
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_PERIOD;


PROCEDURE SERVICE_START_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_START_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_START_DATE;


PROCEDURE SERVICE_END_DATE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_END_DATE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_END_DATE;


PROCEDURE SERVICE_COTERMINATE_FLAG
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_COTERMINATE_FLAG
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END SERVICE_COTERMINATE_FLAG;


PROCEDURE SERVICE_TXN_COMMENTS
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_TXN_COMMENTS
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_TXN_COMMENTS;


PROCEDURE UNIT_LIST_PERCENT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_UNIT_LIST_PERCENT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END UNIT_LIST_PERCENT ;


PROCEDURE UNIT_SELLING_PERCENT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_UNIT_SELLING_PERCENT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END UNIT_SELLING_PERCENT ;


PROCEDURE UNIT_PERCENT_BASE_PRICE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_UNIT_PERCENT_BASE_PRICE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END UNIT_PERCENT_BASE_PRICE ;

PROCEDURE SERVICE_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_NUMBER ;

PROCEDURE SERVICE_REFERENCE_TYPE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_REFERENCE_TYPE_CODE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_REFERENCE_TYPE ;

PROCEDURE SERVICE_REFERENCE_LINE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_REFERENCE_LINE_ID
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_REFERENCE_LINE ;


PROCEDURE SERVICE_REFERENCE_SYSTEM
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_SERVICE_REFERENCE_SYSTEM_ID
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END SERVICE_REFERENCE_SYSTEM ;

PROCEDURE BLANKET_NUMBER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_BLANKET_NUMBER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END BLANKET_NUMBER ;

PROCEDURE END_CUSTOMER_CONTACT
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_END_CUSTOMER_CONTACT
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END END_CUSTOMER_CONTACT;


PROCEDURE END_CUSTOMER_SITE_USE
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_END_CUSTOMER_SITE_USE
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END END_CUSTOMER_SITE_USE ;

PROCEDURE END_CUSTOMER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_END_CUSTOMER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END END_CUSTOMER ;

PROCEDURE IB_OWNER
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_IB_OWNER
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END IB_OWNER;

PROCEDURE IB_INSTALLED_AT_LOCATION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_IB_INSTALLED_AT_LOCATION
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );

END IB_INSTALLED_AT_LOCATION;

PROCEDURE IB_CURRENT_LOCATION
( p_initial_line_rec       IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
, p_x_line_rec	          IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

OE_Line_Util_Ext.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Util.G_IB_CURRENT_LOCATION
    , p_initial_line_rec	=> p_initial_line_rec
    , p_old_line_rec	=> p_old_line_rec
    , p_x_line_rec 	=> p_x_line_rec
    );


END IB_CURRENT_LOCATION;

END OE_Line_Cl_Dep_Attr;

/
