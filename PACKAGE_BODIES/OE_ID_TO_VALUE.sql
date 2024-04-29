--------------------------------------------------------
--  DDL for Package Body OE_ID_TO_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ID_TO_VALUE" AS
/* $Header: OEXSIDVB.pls 120.8.12010000.2 2008/08/04 15:01:34 amallik ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Id_To_Value';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  Id_To_Value functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'conversion_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'deliver_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'deliver_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fob_point';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'freight_carrier';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'intermed_ship_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'intermed_ship_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_source';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_document_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'payment_term';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipment_priority';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_from_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sold_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sold_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_exempt';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_exempt_reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_point';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transactional_curr';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'automatic';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_adjustment';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'dw_update_advice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quota';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sales_credit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'top_model_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_dock';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_trx_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_bucket_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'dep_plan_required';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_complete';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_category';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'link_to_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'option';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rla_schedule_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'task';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'visible_demand';

/*Pricing Contract */

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'agreement';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_list';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accounting_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'agreement_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'agreement_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'calculate_price_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'freight_terms';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_to_site_use';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoicing_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'override_arule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'override_irule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revision_reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'salesrep';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sales_credit_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'term';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'secondary_price_list';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'terms';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'automatic_discount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount_lines';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'manual_discount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'override_allowed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'prorate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'inventory_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_list_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reprice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'unit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount_customer';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'site_use';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'entity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'method_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lot_serial';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'appear_on_ack';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'appear_on_invoice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'charge';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'charge_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cost_or_charge';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'delivery';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'departure';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'estimated';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoiced';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'parent_charge';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'returnable';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_group';
--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for Id_To_Value functions.

--  START GEN Id_To_Value

--  Generator will append new prototypes before end generate comment.


FUNCTION Accounting_Rule
(   p_accounting_rule_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_accounting_rule             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_accounting_rule_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_accounting_rule
        FROM    OE_RA_RULES_V
        WHERE   RULE_ID = p_accounting_rule_id;

    END IF;

    RETURN l_accounting_rule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accounting_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accounting_Rule;


FUNCTION Calculate_Price_Flag
(   p_calculate_price_flag            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_calculate_price_flag         VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) :='CALCULATE_PRICE_FLAG';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN GET VALUES ' || P_CALCULATE_PRICE_FLAG ) ;
	END IF;
    IF p_calculate_price_flag IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_calculate_price_flag
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_calculate_price_flag
        AND     LOOKUP_TYPE = l_lookup_type;


    END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN GET VALUES ' || L_CALCULATE_PRICE_FLAG ) ;
	END IF;
    RETURN l_calculate_price_flag;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','calculate_price_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'calculate_price_flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Calculate_Price_Flag;





FUNCTION Agreement
(   p_agreement_id                  IN  NUMBER
) RETURN VARCHAR2
IS
l_agreement                   VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

-- Appended name with revision for Bug 2249065

    IF p_agreement_id IS NOT NULL THEN

        SELECT  NAME ||' : '||revision
        INTO    l_agreement
        FROM    OE_AGREEMENTS_VL
        WHERE   AGREEMENT_ID = p_agreement_id;

--	NULL;

    END IF;

    RETURN l_agreement;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement;

FUNCTION Conversion_Type
(   p_conversion_type_code          IN  VARCHAR2
) RETURN VARCHAR2
IS
l_conversion_type             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_conversion_type_code IS NOT NULL THEN

        SELECT  USER_CONVERSION_TYPE
        INTO    l_conversion_type
        FROM    OE_GL_DAILY_CONVERSION_TYPES_V
        WHERE   CONVERSION_TYPE = p_conversion_type_code;

    END IF;

    RETURN l_conversion_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','conversion_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Type;

FUNCTION Deliver_To_Contact
(   p_deliver_to_contact_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_deliver_to_contact          VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_deliver_to_contact_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_deliver_to_contact
        FROM    OE_CONTACTS_V
        WHERE   CONTACT_ID = p_deliver_to_contact_id;

    END IF;

    RETURN l_deliver_to_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Deliver_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Deliver_To_Contact;

FUNCTION Inventory_Org
(   p_inventory_org_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_inventory_org          VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_inventory_org_id IS NOT NULL THEN

        SELECT  ORGANIZATION_NAME
        INTO    l_inventory_org
        FROM    ORG_ORGANIZATION_DEFINITIONS
        WHERE   ORGANIZATION_ID = p_inventory_org_id;

    END IF;

    RETURN l_inventory_org;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_org');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'inventory_org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END inventory_org;

PROCEDURE Deliver_To_Org
(   p_deliver_to_org_id             IN  NUMBER
, x_deliver_to_address1 OUT NOCOPY VARCHAR2

, x_deliver_to_address2 OUT NOCOPY VARCHAR2

, x_deliver_to_address3 OUT NOCOPY VARCHAR2

, x_deliver_to_address4 OUT NOCOPY VARCHAR2

, x_deliver_to_location OUT NOCOPY VARCHAR2

, x_deliver_to_org OUT NOCOPY VARCHAR2

, x_deliver_to_city OUT NOCOPY VARCHAR2

, x_deliver_to_state OUT NOCOPY VARCHAR2

, x_deliver_to_postal_code OUT NOCOPY VARCHAR2

, x_deliver_to_country OUT NOCOPY VARCHAR2

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_deliver_to_org_id is NOT NULL THEN

        SELECT  L.NAME
        ,       L.LOCATION_CODE
        ,       L.ADDRESS_LINE_1
        ,       L.ADDRESS_LINE_2
        ,       L.ADDRESS_LINE_3
        ,       L.ADDRESS_LINE_4
        ,       L.TOWN_OR_CITY
        ,       L.STATE
        ,       L.POSTAL_CODE
        ,       L.COUNTRY
        INTO    x_deliver_to_org
        ,       x_deliver_to_location
        ,       x_deliver_to_address1
        ,       x_deliver_to_address2
        ,       x_deliver_to_address3
        ,       x_deliver_to_address4
        ,       x_deliver_to_city
        ,       x_deliver_to_state
        ,       x_deliver_to_postal_code
        ,       x_deliver_to_country
        FROM    OE_DELIVER_TO_ORGS_V    L
        WHERE   L.ORGANIZATION_ID   = p_deliver_to_org_id;

    ELSE

        x_deliver_to_org         :=  NULL    ;
        x_deliver_to_location    :=  NULL    ;
        x_deliver_to_address1    :=  NULL    ;
        x_deliver_to_address2    :=  NULL    ;
        x_deliver_to_address3    :=  NULL    ;
        x_deliver_to_address4    :=  NULL    ;
        x_deliver_to_city        :=  NULL    ;
        x_deliver_to_state       :=  NULL    ;
        x_deliver_to_postal_code :=  NULL    ;
        x_deliver_to_country     :=  NULL    ;

    END IF;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Deliver_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Deliver_To_Org;

FUNCTION Fob_Point
(   p_fob_point_code                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_fob_point                   VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) :='FOB';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_fob_point_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_fob_point
        FROM    OE_AR_LOOKUPS_V
        WHERE   LOOKUP_CODE = p_fob_point_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_fob_point;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fob_point');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fob_Point'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fob_Point;

FUNCTION Freight_Terms
(   p_freight_terms_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_freight_terms               VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) :='FREIGHT_TERMS';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_freight_terms_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_freight_terms
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_freight_terms_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_freight_terms;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Freight_Terms'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Freight_Terms;

-- Intermediate Ship To

FUNCTION Intermed_Ship_To_Contact
(   p_intermed_ship_to_contact_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_intermed_ship_to_contact             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_intermed_ship_to_contact_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_intermed_ship_to_contact
        FROM    OE_CONTACTS_V
        WHERE   CONTACT_ID = p_intermed_ship_to_contact_id;

    END IF;

    RETURN l_intermed_ship_to_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','intermed_ship_to_contact');
            OE_MSG_PUB.Add;

        END IF;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Intermed_Ship_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Intermed_Ship_To_Contact;

PROCEDURE Intermed_Ship_To_Org
(   p_intermed_ship_to_org_id                IN  NUMBER
, x_intermed_ship_to_address1 OUT NOCOPY VARCHAR2

, x_intermed_ship_to_address2 OUT NOCOPY VARCHAR2

, x_intermed_ship_to_address3 OUT NOCOPY VARCHAR2

, x_intermed_ship_to_address4 OUT NOCOPY VARCHAR2

, x_intermed_ship_to_location OUT NOCOPY VARCHAR2

, x_intermed_ship_to_org OUT NOCOPY VARCHAR2

, x_intermed_ship_to_city OUT NOCOPY VARCHAR2

, x_intermed_ship_to_state OUT NOCOPY VARCHAR2

, x_intermed_ship_to_postal_code OUT NOCOPY VARCHAR2

, x_intermed_ship_to_country OUT NOCOPY VARCHAR2

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_intermed_ship_to_org_id is NOT NULL THEN

        SELECT  L.NAME
        ,       L.LOCATION_CODE
        ,       L.ADDRESS_LINE_1
        ,       L.ADDRESS_LINE_2
        ,       L.ADDRESS_LINE_3
        ,       L.ADDRESS_LINE_4
        ,       L.TOWN_OR_CITY
        ,       L.STATE
        ,       L.POSTAL_CODE
        ,       L.COUNTRY
        INTO    x_intermed_ship_to_org
        ,       x_intermed_ship_to_location
        ,       x_intermed_ship_to_address1
        ,       x_intermed_ship_to_address2
        ,       x_intermed_ship_to_address3
        ,       x_intermed_ship_to_address4
        ,       x_intermed_ship_to_city
        ,       x_intermed_ship_to_state
        ,       x_intermed_ship_to_postal_code
        ,       x_intermed_ship_to_country
        FROM    OE_SHIP_TO_ORGS_V    L
        WHERE   L.ORGANIZATION_ID   = p_intermed_ship_to_org_id;

    ELSE

        x_intermed_ship_to_org         :=  NULL    ;
        x_intermed_ship_to_location    :=  NULL    ;
        x_intermed_ship_to_address1    :=  NULL    ;
        x_intermed_ship_to_address2    :=  NULL    ;
        x_intermed_ship_to_address3    :=  NULL    ;
        x_intermed_ship_to_address4    :=  NULL    ;
        x_intermed_ship_to_city        :=  NULL    ;
        x_intermed_ship_to_state       :=  NULL    ;
        x_intermed_ship_to_postal_code :=  NULL    ;
        x_intermed_ship_to_country     :=  NULL    ;

    END IF;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','intermed_ship_to_org');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Intermed_Ship_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Intermed_Ship_To_Org;

FUNCTION Invoice_To_Contact
(   p_invoice_to_contact_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_invoice_to_contact          VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_invoice_to_contact_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_invoice_to_contact
        FROM    OE_CONTACTS_V
        WHERE   CONTACT_ID = p_invoice_to_contact_id;

    END IF;

    RETURN l_invoice_to_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Contact;

PROCEDURE Invoice_To_Org
(   p_invoice_to_org_id             IN  NUMBER
, x_invoice_to_address1 OUT NOCOPY VARCHAR2

, x_invoice_to_address2 OUT NOCOPY VARCHAR2

, x_invoice_to_address3 OUT NOCOPY VARCHAR2

, x_invoice_to_address4 OUT NOCOPY VARCHAR2

, x_invoice_to_location OUT NOCOPY VARCHAR2

, x_invoice_to_org OUT NOCOPY VARCHAR2

, x_invoice_to_city OUT NOCOPY VARCHAR2

, x_invoice_to_state OUT NOCOPY VARCHAR2

, x_invoice_to_postal_code OUT NOCOPY VARCHAR2

, x_invoice_to_country OUT NOCOPY VARCHAR2

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_invoice_to_org_id is NOT NULL THEN

        SELECT  L.NAME
        ,       L.LOCATION_CODE
        ,       L.ADDRESS_LINE_1
        ,       L.ADDRESS_LINE_2
        ,       L.ADDRESS_LINE_3
        ,       L.ADDRESS_LINE_4
        ,       L.TOWN_OR_CITY
        ,       L.STATE
        ,       L.POSTAL_CODE
        ,       L.COUNTRY
        INTO    x_invoice_to_org
        ,       x_invoice_to_location
        ,       x_invoice_to_address1
        ,       x_invoice_to_address2
        ,       x_invoice_to_address3
        ,       x_invoice_to_address4
        ,       x_invoice_to_city
        ,       x_invoice_to_state
        ,       x_invoice_to_postal_code
        ,       x_invoice_to_country
        FROM    OE_INVOICE_TO_ORGS_V    L
        WHERE   L.ORGANIZATION_ID   = p_invoice_to_org_id;

    ELSE

        x_invoice_to_org         :=  NULL    ;
        x_invoice_to_location    :=  NULL    ;
        x_invoice_to_address1    :=  NULL    ;
        x_invoice_to_address2    :=  NULL    ;
        x_invoice_to_address3    :=  NULL    ;
        x_invoice_to_address4    :=  NULL    ;
        x_invoice_to_city        :=  NULL;
        x_invoice_to_state       :=  NULL;
        x_invoice_to_postal_code :=  NULL;
        x_invoice_to_country     :=  NULL;

    END IF;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_org');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Org;

FUNCTION Invoicing_Rule
(   p_invoicing_rule_id             IN  NUMBER
) RETURN VARCHAR2
IS
l_invoicing_rule              VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_invoicing_rule_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_invoicing_rule
        FROM    OE_RA_RULES_V
        WHERE   RULE_ID = p_invoicing_rule_id;

    END IF;

    RETURN l_invoicing_rule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoicing_rule');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoicing_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoicing_Rule;

FUNCTION Order_Source
(   p_order_source_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_order_source                VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_order_source_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_order_source
        FROM    OE_ORDER_SOURCES
        WHERE   ORDER_SOURCE_ID = p_order_source_id;

    END IF;

    RETURN l_order_source;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_source');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Source'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Source;

FUNCTION Order_Type
(   p_order_type_id                 IN  NUMBER
) RETURN VARCHAR2
IS
l_order_type                  VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_order_type_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_order_type
        FROM    OE_ORDER_TYPES_v
        WHERE   ORDER_TYPE_ID = p_order_type_id;

    END IF;

    RETURN l_order_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Type;

FUNCTION Payment_Term
(   p_payment_term_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_payment_term                VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_payment_term_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_payment_term
        FROM    OE_RA_TERMS_V
        WHERE   TERM_ID = p_payment_term_id;

    END IF;

    RETURN l_payment_term;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_term');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Term'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Term;

FUNCTION Price_List
(   p_price_list_id                 IN  NUMBER
) RETURN VARCHAR2
IS
l_price_list                  VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_price_list_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_price_list
        FROM    qp_list_headers_vl
        WHERE   list_header_id = p_price_list_id and
			list_type_code in ('PRL', 'AGR');

    END IF;

    RETURN l_price_list;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List;

FUNCTION New_Modifier_List
(   p_new_modifier_list_id                 IN  NUMBER
) RETURN VARCHAR2
IS
l_new_modifier_list                  VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_new_modifier_list_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_new_modifier_list
        FROM    qp_list_headers_vl
        WHERE   list_header_id = p_new_modifier_list_id ;

    END IF;

    RETURN l_new_modifier_list;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','New_Modifier_list');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'New_Modifier_List'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END New_Modifier_List;
FUNCTION Demand_Class
(   p_demand_class_code        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_demand_class           VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) :='DEMAND_CLASS';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_demand_class_code IS NOT NULL THEN

       SELECT  MEANING
        INTO    l_demand_class
        FROM    OE_FND_COMMON_LOOKUPS_V
        WHERE   LOOKUP_CODE = p_demand_class_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_demand_class;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand_class');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'demand_class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Class;

FUNCTION Shipment_Priority
(   p_shipment_priority_code        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_shipment_priority           VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) :='SHIPMENT_PRIORITY';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_shipment_priority_code IS NOT NULL THEN

       SELECT  MEANING
        INTO    l_shipment_priority
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_shipment_priority_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_shipment_priority;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipment_priority');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipment_Priority'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipment_Priority;

PROCEDURE Ship_From_Org
(   p_ship_from_org_id              IN  NUMBER
, x_ship_from_address1 OUT NOCOPY VARCHAR2

, x_ship_from_address2 OUT NOCOPY VARCHAR2

, x_ship_from_address3 OUT NOCOPY VARCHAR2

, x_ship_from_address4 OUT NOCOPY VARCHAR2

, x_ship_from_location OUT NOCOPY VARCHAR2

, x_ship_from_org OUT NOCOPY VARCHAR2

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_ship_from_org_id is NOT NULL THEN

        SELECT  L.Organization_code
        ,       L.LOCATION_CODE
        ,       L.ADDRESS_LINE_1
        ,       L.ADDRESS_LINE_2
        ,       L.ADDRESS_LINE_3
        ,       DECODE(L.TOWN_OR_CITY,NULL,NULL,L.TOWN_OR_CITY||', ')||
                DECODE(L.REGION_1, NULL, NULL, L.REGION_1 || ', ')||
                DECODE(L.REGION_2, NULL, NULL, L.REGION_2 || ', ')||
                DECODE(L.REGION_3, NULL, NULL, L.REGION_3 || ', ')||
                DECODE(L.POSTAL_CODE, NULL, NULL, L.POSTAL_CODE || ', ')||
                DECODE(L.COUNTRY, NULL, NULL, L.COUNTRY)
        INTO    x_ship_from_org
        ,       x_ship_from_location
        ,       x_ship_from_address1
        ,       x_ship_from_address2
        ,       x_ship_from_address3
        ,       x_ship_from_address4
        FROM    OE_SHIP_FROM_ORGS_V    L
        WHERE   L.ORGANIZATION_ID   = p_ship_from_org_id;

    ELSE

        x_ship_from_org         :=  NULL    ;
        x_ship_from_location    :=  NULL    ;
        x_ship_from_address1    :=  NULL    ;
        x_ship_from_address2    :=  NULL    ;
        x_ship_from_address3    :=  NULL    ;
        x_ship_from_address4    :=  NULL    ;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_from_org');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_From_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_From_Org;

FUNCTION Ship_To_Contact
(   p_ship_to_contact_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_ship_to_contact             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_ship_to_contact_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_ship_to_contact
        FROM    OE_CONTACTS_V
        WHERE   CONTACT_ID = p_ship_to_contact_id;

    END IF;

    RETURN l_ship_to_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_To_Contact;

PROCEDURE Ship_To_Org
(   p_ship_to_org_id                IN  NUMBER
, x_ship_to_address1 OUT NOCOPY VARCHAR2

, x_ship_to_address2 OUT NOCOPY VARCHAR2

, x_ship_to_address3 OUT NOCOPY VARCHAR2

, x_ship_to_address4 OUT NOCOPY VARCHAR2

, x_ship_to_location OUT NOCOPY VARCHAR2

, x_ship_to_org OUT NOCOPY VARCHAR2

, x_ship_to_city OUT NOCOPY VARCHAR2

, x_ship_to_state OUT NOCOPY VARCHAR2

, x_ship_to_postal_code OUT NOCOPY VARCHAR2

, x_ship_to_country OUT NOCOPY VARCHAR2

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_ship_to_org_id is NOT NULL THEN

        SELECT  L.NAME
        ,       L.LOCATION_CODE
        ,       L.ADDRESS_LINE_1
        ,       L.ADDRESS_LINE_2
        ,       L.ADDRESS_LINE_3
        ,       L.ADDRESS_LINE_4
        ,       L.TOWN_OR_CITY
        ,       L.STATE
        ,       L.POSTAL_CODE
        ,       L.COUNTRY
        INTO    x_ship_to_org
        ,       x_ship_to_location
        ,       x_ship_to_address1
        ,       x_ship_to_address2
        ,       x_ship_to_address3
        ,       x_ship_to_address4
        ,       x_ship_to_city
        ,       x_ship_to_state
        ,       x_ship_to_postal_code
        ,       x_ship_to_country
        FROM    OE_SHIP_TO_ORGS_V    L
        WHERE   L.ORGANIZATION_ID   = p_ship_to_org_id;

    ELSE

        x_ship_to_org         :=  NULL    ;
        x_ship_to_location    :=  NULL    ;
        x_ship_to_address1    :=  NULL    ;
        x_ship_to_address2    :=  NULL    ;
        x_ship_to_address3    :=  NULL    ;
        x_ship_to_address4    :=  NULL    ;
        x_ship_to_city        :=  NULL    ;
        x_ship_to_state       :=  NULL    ;
        x_ship_to_postal_code :=  NULL    ;
        x_ship_to_country     :=  NULL    ;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_To_Org;

FUNCTION Sold_To_Contact
(   p_sold_to_contact_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_sold_to_contact             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_sold_to_contact_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_sold_to_contact
        FROM    OE_CONTACTS_V
        WHERE   CONTACT_ID = p_sold_to_contact_id;

    END IF;

    RETURN l_sold_to_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Contact;

PROCEDURE    Sold_To_Org
(   p_sold_to_org_id	IN  NUMBER  	,
    x_org OUT NOCOPY VARCHAR2 ,
    x_customer_number OUT NOCOPY VARCHAR2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_sold_to_org_id is NOT NULL THEN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'DOING SELECT FOR CUSTOMER_NUMBER' ) ;
	END IF;
	SELECT  O.NAME
	,	O.CUSTOMER_NUMBER
	INTO    x_org
	,	x_customer_number
	FROM    OE_SOLD_TO_ORGS_V	O
	WHERE   O.ORGANIZATION_ID   = p_sold_to_org_id;

    ELSE

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE QUERY FOR CUSTOMER NUMBER - NO ORG_ID PASSED' ) ;
        END IF;
	x_org		    :=  NULL    ;
	x_customer_number   :=  NULL    ;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Org;

--Overloded procedure added for Ac. Desc, Registry ID Project

PROCEDURE Sold_To_Org
(
    p_sold_to_org_id	IN  NUMBER  	,
    x_org OUT NOCOPY VARCHAR2 ,
    x_customer_number OUT NOCOPY VARCHAR2 ,
    x_account_description OUT NOCOPY VARCHAR2,
    x_registry_id OUT NOCOPY VARCHAR2
)  IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_sold_to_org_id is NOT NULL THEN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'DOING SELECT FOR CUSTOMER_NUMBER' ) ;
	END IF;
	SELECT  P.PARTY_NAME
	,	C.ACCOUNT_NUMBER
	,	C.ACCOUNT_NAME
	,	P.PARTY_NUMBER
	INTO    x_org
	,	x_customer_number
	,	x_account_description
	,	x_registry_id
	FROM    HZ_CUST_ACCOUNTS	C
	,	HZ_PARTIES		P
	WHERE   C.CUST_ACCOUNT_ID   = p_sold_to_org_id
	AND	C.PARTY_ID	    =P.PARTY_ID;

    ELSE

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE QUERY FOR CUSTOMER NUMBER - NO ORG_ID PASSED' ) ;
        END IF;
	x_org		    :=  NULL    ;
	x_customer_number   :=  NULL    ;
	x_account_description:= NULL	;
	x_registry_id	    :=  NULL	;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Org;
	--added for Ac. Desc, Registry ID Project

FUNCTION Tax_Exempt
(   p_tax_exempt_flag               IN  VARCHAR2
) RETURN VARCHAR2
IS
l_tax_exempt                  VARCHAR2(240) := NULL;

-- eBTax Changes
l_lookup_type      	      VARCHAR2(80) :='ZX_EXEMPTION_CONTROL';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_tax_exempt_flag IS NOT NULL THEN
    -- eBTax changes
        SELECT  MEANING
        INTO    l_tax_exempt
        FROM    FND_LOOKUPS
        WHERE   LOOKUP_CODE = p_tax_exempt_flag
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_tax_exempt;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Exempt'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Exempt;

FUNCTION Tax_Exempt_Reason
(   p_tax_exempt_reason_code        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_tax_exempt_reason           VARCHAR2(240) := NULL;
-- eBTax changes
l_lookup_type      	      VARCHAR2(80) :='ZX_EXEMPTION_REASON_CODE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_tax_exempt_reason_code IS NOT NULL THEN
       -- eBTax changes
        SELECT  MEANING
        INTO    l_tax_exempt_reason
        FROM    FND_LOOKUPS
        WHERE   LOOKUP_CODE = p_tax_exempt_reason_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_tax_exempt_reason;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt_reason');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Exempt_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Exempt_Reason;

FUNCTION Tax_Point
(   p_tax_point_code                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_tax_point                   VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) :='TAX_POINT_TYPE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_tax_point_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_tax_point
        FROM    OE_AR_LOOKUPS_V
        WHERE   LOOKUP_CODE = p_tax_point_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_tax_point;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_point');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Point'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Point;

FUNCTION Discount
(   p_discount_id                   IN  NUMBER
) RETURN VARCHAR2
IS
l_discount                    VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_discount_id IS NOT NULL THEN

        --  SELECT  DISCOUNT
        --  INTO    l_discount
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_discount_id;

        NULL;

    END IF;

    RETURN l_discount;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount;

FUNCTION sales_credit_type
(   p_sales_credit_type_id        IN  NUMBER
) RETURN VARCHAR2
IS
l_sales_credit_type              VARCHAR2(240) := NULL;
cursor c_sales_credit_type(p_sales_credit_type_id number) is
       select name
       from oe_sales_credit_types
       where sales_credit_type_id = p_sales_credit_type_id;
       --
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
       --
BEGIN

    IF p_sales_credit_type_id IS NOT NULL THEN
        open c_sales_credit_type(p_sales_credit_type_id);
        fetch c_sales_credit_type into  l_sales_credit_type;
        close c_sales_credit_type;
    END IF;

    RETURN l_sales_credit_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_credit_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'sales_credit_type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END sales_credit_type;

FUNCTION Salesrep
(   p_salesrep_id                   IN  NUMBER
) RETURN VARCHAR2
IS
l_salesrep                    VARCHAR2(240) := NULL;
cursor c_salesrep(p_salesrep_id number) is
       select name
       from ra_salesreps
       where salesrep_id = p_salesrep_id;
       --
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
       --
BEGIN

    IF p_salesrep_id IS NOT NULL THEN
        open c_salesrep(p_salesrep_id);
        fetch c_salesrep into  l_salesrep;
        close c_salesrep;
    END IF;

    RETURN l_salesrep;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Salesrep'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Salesrep;

FUNCTION Customer_Item
(   p_customer_item_id              IN  NUMBER
) RETURN VARCHAR2
IS
l_customer_item               VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_customer_item_id IS NOT NULL THEN

        --  SELECT  CUSTOMER_ITEM
        --  INTO    l_customer_item
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_customer_item_id;

        NULL;

    END IF;

    RETURN l_customer_item;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','customer_item');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Item;

FUNCTION Demand_Bucket_Type
(   p_demand_bucket_type_code       IN  VARCHAR2
) RETURN VARCHAR2
IS
l_demand_bucket_type          VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_demand_bucket_type_code IS NOT NULL THEN

        --  SELECT  DEMAND_BUCKET_TYPE
        --  INTO    l_demand_bucket_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_demand_bucket_type_code;

        NULL;

    END IF;

    RETURN l_demand_bucket_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand_bucket_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Bucket_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Bucket_Type;

FUNCTION Inventory_Item
(   p_inventory_item_id             IN  NUMBER
) RETURN VARCHAR2
IS
l_inventory_item              VARCHAR2(240) := NULL;
l_validation_org_id           NUMBER        := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF p_inventory_item_id IS NOT NULL THEN

--Kris make a global variable for validation org so we don't have to get it all the time

	/*l_validation_org_id := fnd_profile.value('OE_ORGANIZATION_ID');*/
    -- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
    l_validation_org_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

        SELECT  DESCRIPTION
        INTO    l_inventory_item
        FROM    MTL_SYSTEM_ITEMS
        WHERE   INVENTORY_ITEM_ID = p_inventory_item_id
        AND     ORGANIZATION_ID = l_validation_org_id;


    END IF;
    RETURN l_inventory_item;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

FUNCTION Item_Type
(   p_item_type_code                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_item_type                   VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_item_type_code IS NOT NULL THEN

        --  SELECT  ITEM_TYPE
        --  INTO    l_item_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_item_type_code;

        NULL;

    END IF;

    RETURN l_item_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Type;

FUNCTION Line_Type
(   p_line_type_id                  IN  NUMBER
) RETURN VARCHAR2
IS
l_line_type                   VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_line_type_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_line_type
        FROM    OE_LINE_TYPES_V
        WHERE   LINE_TYPE_ID = p_line_type_id;

    END IF;

    RETURN l_line_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Type;

FUNCTION Project
(   p_project_id                    IN  NUMBER
) RETURN VARCHAR2
IS
l_project                     VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF p_project_id IS NOT NULL THEN


	   l_project := pjm_project.all_proj_idtonum(p_project_id);

    END IF;

    RETURN l_project;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Project'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Project;

FUNCTION Rla_Schedule_Type
(   p_rla_schedule_type_code        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_rla_schedule_type           VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_rla_schedule_type_code IS NOT NULL THEN

        --  SELECT  RLA_SCHEDULE_TYPE
        --  INTO    l_rla_schedule_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_rla_schedule_type_code;

        NULL;

    END IF;

    RETURN l_rla_schedule_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rla_schedule_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rla_Schedule_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rla_Schedule_Type;

FUNCTION Task
(   p_task_id                       IN  NUMBER
) RETURN VARCHAR2
IS
l_task                        VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_task_id IS NOT NULL THEN

	   l_task := PJM_PROJECT.ALL_TASK_IDTONUM(p_task_id);

    END IF;

    RETURN l_task;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Task;


FUNCTION Over_Ship_Reason
(   p_over_ship_reason_code        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_over_ship_reason           VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_over_ship_reason_code IS NOT NULL THEN

        --  SELECT  RLA_SCHEDULE_TYPE
        --  INTO    l_rla_schedule_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_rla_schedule_type_code;

        NULL;

    END IF;

    RETURN l_over_ship_reason;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','over_ship_reason');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Over_Ship_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_Ship_Reason;

FUNCTION Source_Type
(   p_source_type_code        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_source_type           VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) :='SOURCE_TYPE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_source_type_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_source_type
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_source_type_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_source_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','source_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Source_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Source_Type;

FUNCTION Order_Date_Type
(   p_order_date_type_code        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_order_date_type           VARCHAR2(80) := NULL;
l_lookup_type      	      VARCHAR2(80) := 'REQUEST_DATE_TYPE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_order_date_type_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_order_date_type
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_order_date_type_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_order_date_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_date_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'order_date_type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Date_Type;

FUNCTION Return_Reason
(   p_return_reason_code        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_return_reason           VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) :='CREDIT_MEMO_REASON';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_return_reason_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_return_reason
        FROM    OE_AR_LOOKUPS_V
        WHERE   LOOKUP_CODE = p_return_reason_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_return_reason;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','return_reason');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Return_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Return_Reason;

PROCEDURE Reference_Line
( p_reference_line_id  IN NUMBER
, x_ref_order_number OUT NOCOPY NUMBER
, x_ref_line_number OUT NOCOPY NUMBER
, x_ref_shipment_number OUT NOCOPY NUMBER
, x_ref_option_number OUT NOCOPY NUMBER
, x_ref_component_number OUT NOCOPY NUMBER

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_reference_line_id IS NOT NULL THEN

     SELECT /* MOAC_SQL_CHANGE */ H.order_number,
             l.line_number,
             l.shipment_number,
             l.option_number,
             l.component_number
      INTO x_ref_order_number,
           x_ref_line_number,
           x_ref_shipment_number,
           x_ref_option_number,
           x_ref_component_number
      FROM oe_order_headers_all h,
           oe_order_lines l
      WHERE l.line_id=p_reference_line_id
      and h.header_id=l.header_id;

    ELSE

      x_ref_order_number := NULL;
      x_ref_line_number := NULL;
      x_ref_shipment_number := NULL;
      x_ref_option_number := NULL;
      x_ref_component_number := NULL;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reference_line');
            OE_MSG_PUB.Add;

        END IF;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference_line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference_Line;

PROCEDURE Reference_Cust_Trx_Line
(   p_reference_cust_trx_line_id               IN NUMBER
, x_ref_invoice_number OUT NOCOPY VARCHAR2

, x_ref_invoice_line_number OUT NOCOPY NUMBER

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_reference_cust_trx_line_id IS NOT NULL THEN

       select /* MOAC_SQL_CHANGE */ rct.trx_number,
              rctl.line_number
       into x_ref_invoice_number,
            x_ref_invoice_line_number
       from ra_customer_trx rct,
            ra_customer_trx_lines_all rctl
       where rctl.customer_trx_line_id = p_reference_cust_trx_line_id
       and rctl.customer_trx_id = rct.customer_trx_id;

    ELSE

      x_ref_invoice_number := NULL;
      x_ref_invoice_line_number := NULL;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Reference_Customer_Trx_Line');
            OE_MSG_PUB.Add;

        END IF;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference_Customer_Trx_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference_Cust_Trx_Line;

FUNCTION Credit_Invoice_Line
(   p_credit_invoice_line_id        IN  NUMBER
) RETURN VARCHAR2
IS
l_credit_invoice_number           VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_credit_invoice_line_id IS NOT NULL THEN

       select /* MOAC_SQL_CHANGE */ rct.trx_number
       into l_credit_invoice_number
       from ra_customer_trx rct,
         ra_customer_trx_lines_all rctl
       where rctl.customer_trx_line_id = p_credit_invoice_line_id
       and rctl.customer_trx_id = rct.customer_trx_id;

    END IF;

    RETURN l_credit_invoice_number;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','credit_invoice_line');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'credit_invoice_line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Credit_Invoice_Line;

FUNCTION Veh_Cus_Item_cum_Key
(   p_veh_cus_item_cum_key_id                       IN  NUMBER
) RETURN VARCHAR2
IS
l_veh_cus_item_cum_key                        VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_veh_cus_item_cum_key_id IS NOT NULL THEN

        --  SELECT  TASK
        --  INTO    l_task
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_task_id;

        NULL;

    END IF;

    RETURN l_veh_cus_item_cum_key;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','veh_cus_item_cum_key');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Veh_Cus_Item_cum_key'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Veh_Cus_Item_cum_key;

FUNCTION Payment_Type
(   p_payment_type_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_payment_type               VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) := 'PAYMENT TYPE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_payment_type_code IS NOT NULL THEN
--serla begin
      IF OE_PrePayment_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN
        -- skubendr For commitments also the corresponding value has to be returned
        IF ( p_payment_type_code = 'COMMITMENT') THEN
	   l_lookup_type :='OE_PAYMENT_TYPE';
           SELECT MEANING
           INTO   l_payment_type
           FROM   oe_lookups
           WHERE  lookup_type=l_lookup_type and lookup_code=p_payment_type_code;
        ELSE
           SELECT  NAME
           INTO    l_payment_type
           FROM    oe_payment_types_vl
           WHERE   payment_type_code = p_payment_type_code;
        END IF;
      ELSE
        SELECT  MEANING
        INTO    l_payment_type
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_payment_type_code
        AND     LOOKUP_TYPE = l_lookup_type;
      END IF;
--serla end

    END IF;

    RETURN l_payment_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Type;

FUNCTION Credit_Card
(   p_credit_card_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_credit_card               VARCHAR2(240) := NULL;
l_lookup_type      	      VARCHAR2(80) :='CREDIT_CARD';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_credit_card_code IS NOT NULL THEN
	    --R12 CC Encryption
	    select description into l_credit_card
	    from iby_creditcard_issuers_v
	    where CARD_ISSUER_CODE = p_credit_card_code
	    and rownum = 1;
    END IF;

    RETURN l_credit_card;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','credit_card');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Card'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Credit_Card;


FUNCTION Commitment
(   p_commitment_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_commitment             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_commitment_id IS NOT NULL THEN

        SELECT  trx_number
        INTO    l_commitment
        FROM    RA_CUSTOMER_TRX
        WHERE   customer_trx_id = p_commitment_id;

    END IF;

    RETURN l_commitment;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','commitment');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Commitment'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Commitment;


/* Pricing Contract Functions : Begin */


FUNCTION Agreement_Contact
(   p_agreement_contact_id          IN  NUMBER
) RETURN VARCHAR2
IS
l_agreement_contact           VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_agreement_contact_id IS NOT NULL THEN

        --  SELECT  AGREEMENT_CONTACT
        --  INTO    l_agreement_contact
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_agreement_contact_id;

        NULL;

    END IF;

    RETURN l_agreement_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement_Contact;

FUNCTION Agreement_Type
(   p_agreement_type_code           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_agreement_type              VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_agreement_type_code IS NOT NULL THEN

        --  SELECT  AGREEMENT_TYPE
        --  INTO    l_agreement_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_agreement_type_code;

        NULL;

    END IF;

    RETURN l_agreement_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement_Type;

FUNCTION Customer
(   p_sold_to_org_id                   IN  NUMBER
) RETURN VARCHAR2
IS
l_customer                    VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_sold_to_org_id IS NOT NULL THEN

        --  SELECT  CUSTOMER
        --  INTO    l_customer
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_sold_to_org_id;

        NULL;

    END IF;

    RETURN l_customer;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','customer');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer;

FUNCTION Invoice_Contact
(   p_invoice_contact_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_invoice_contact             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_invoice_contact_id IS NOT NULL THEN

        --  SELECT  INVOICE_CONTACT
        --  INTO    l_invoice_contact
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_invoice_contact_id;

        NULL;

    END IF;

    RETURN l_invoice_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_Contact;

FUNCTION Invoice_To_Site_Use
(   p_invoice_to_org_id        IN  NUMBER
) RETURN VARCHAR2
IS
l_invoice_to_site_use         VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_invoice_to_org_id IS NOT NULL THEN

        --  SELECT  INVOICE_TO_SITE_USE
        --  INTO    l_invoice_to_site_use
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_invoice_to_org_id;

        NULL;

    END IF;

    RETURN l_invoice_to_site_use;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_site_use');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Site_Use'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Site_Use;

FUNCTION Override_Arule
(   p_override_arule_flag           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_override_arule              VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_override_arule_flag IS NOT NULL THEN

        --  SELECT  OVERRIDE_ARULE
        --  INTO    l_override_arule
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_override_arule_flag;

        NULL;

    END IF;

    RETURN l_override_arule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override_arule');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override_Arule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override_Arule;

FUNCTION Override_Irule
(   p_override_irule_flag           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_override_irule              VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_override_irule_flag IS NOT NULL THEN

        --  SELECT  OVERRIDE_IRULE
        --  INTO    l_override_irule
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_override_irule_flag;

        NULL;

    END IF;

    RETURN l_override_irule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override_irule');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override_Irule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override_Irule;

FUNCTION Revision_Reason
(   p_revision_reason_code          IN  VARCHAR2
) RETURN VARCHAR2
IS
l_revision_reason             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_revision_reason_code IS NOT NULL THEN

        --  SELECT  REVISION_REASON
        --  INTO    l_revision_reason
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_revision_reason_code;

        NULL;

    END IF;

    RETURN l_revision_reason;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_reason');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision_Reason;

FUNCTION Ship_Method
(   p_ship_method_code              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_ship_method                 VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_ship_method_code IS NOT NULL THEN

          SELECT  meaning
          INTO    l_ship_method
          FROM    oe_ship_methods_v
          WHERE   lookup_code = p_ship_method_code;

        NULL;

    END IF;

    RETURN l_ship_method;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_method');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_Method;

FUNCTION Term
(   p_term_id                       IN  NUMBER
) RETURN VARCHAR2
IS
l_term                        VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_term_id IS NOT NULL THEN

        --  SELECT  TERM
        --  INTO    l_term
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_term_id;

        NULL;

    END IF;

    RETURN l_term;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','term');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Term'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Term;

FUNCTION Currency
(   p_currency_code                 IN  VARCHAR2
) RETURN VARCHAR2
IS
l_currency                    VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_currency_code IS NOT NULL THEN

        --  SELECT  CURRENCY
        --  INTO    l_currency
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_currency_code;

        NULL;

    END IF;

    RETURN l_currency;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency;

FUNCTION Secondary_Price_List
(   p_secondary_price_list_id       IN  NUMBER
) RETURN VARCHAR2
IS
l_secondary_price_list        VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_secondary_price_list_id IS NOT NULL THEN

        --  SELECT  SECONDARY_PRICE_LIST
        --  INTO    l_secondary_price_list
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_secondary_price_list_id;

        NULL;

    END IF;

    RETURN l_secondary_price_list;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','secondary_price_list');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Secondary_Price_List'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Secondary_Price_List;

FUNCTION Terms
(   p_terms_id                      IN  NUMBER
) RETURN VARCHAR2
IS
l_terms                       VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_terms_id IS NOT NULL THEN

        --  SELECT  TERMS
        --  INTO    l_terms
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_terms_id;

        NULL;

    END IF;

    RETURN l_terms;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','terms');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Terms'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Terms;

FUNCTION Automatic_Discount
(   p_automatic_discount_flag       IN  VARCHAR2
) RETURN VARCHAR2
IS
l_automatic_discount          VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_automatic_discount_flag IS NOT NULL THEN

        --  SELECT  AUTOMATIC_DISCOUNT
        --  INTO    l_automatic_discount
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_automatic_discount_flag;

        NULL;

    END IF;

    RETURN l_automatic_discount;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic_discount');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Automatic_Discount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Automatic_Discount;

FUNCTION Discount_Lines
(   p_discount_lines_flag           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_discount_lines              VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_discount_lines_flag IS NOT NULL THEN

        --  SELECT  DISCOUNT_LINES
        --  INTO    l_discount_lines
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_discount_lines_flag;

        NULL;

    END IF;

    RETURN l_discount_lines;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_lines');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Lines;

FUNCTION Discount_Type
(   p_discount_type_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_discount_type               VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_discount_type_code IS NOT NULL THEN

        --  SELECT  DISCOUNT_TYPE
        --  INTO    l_discount_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_discount_type_code;

        NULL;

    END IF;

    RETURN l_discount_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Type;

FUNCTION Manual_Discount
(   p_manual_discount_flag          IN  VARCHAR2
) RETURN VARCHAR2
IS
l_manual_discount             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_manual_discount_flag IS NOT NULL THEN

        --  SELECT  MANUAL_DISCOUNT
        --  INTO    l_manual_discount
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_manual_discount_flag;

        NULL;

    END IF;

    RETURN l_manual_discount;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','manual_discount');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Manual_Discount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Manual_Discount;

FUNCTION Override_Allowed
(   p_override_allowed_flag         IN  VARCHAR2
) RETURN VARCHAR2
IS
l_override_allowed            VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_override_allowed_flag IS NOT NULL THEN

        --  SELECT  OVERRIDE_ALLOWED
        --  INTO    l_override_allowed
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_override_allowed_flag;

        NULL;

    END IF;

    RETURN l_override_allowed;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override_allowed');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override_Allowed'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override_Allowed;

FUNCTION Prorate
(   p_prorate_flag                  IN  VARCHAR2
) RETURN VARCHAR2
IS
l_prorate                     VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_prorate_flag IS NOT NULL THEN

        --  SELECT  PRORATE
        --  INTO    l_prorate
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_prorate_flag;

        NULL;

    END IF;

    RETURN l_prorate;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prorate');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Prorate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Prorate;

FUNCTION Method
(   p_method_code                   IN  VARCHAR2
) RETURN VARCHAR2
IS
l_method                      VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_method_code IS NOT NULL THEN

        --  SELECT  METHOD
        --  INTO    l_method
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_method_code;

        NULL;

    END IF;

    RETURN l_method;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','method');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Method;

FUNCTION Price_List_Line
(   p_price_list_line_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_price_list_line             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_price_list_line_id IS NOT NULL THEN

        --  SELECT  PRICE_LIST_LINE
        --  INTO    l_price_list_line
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_price_list_line_id;

        NULL;

    END IF;

    RETURN l_price_list_line;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_line');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List_Line;

FUNCTION Pricing_Rule
(   p_pricing_rule_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_pricing_rule                VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_pricing_rule_id IS NOT NULL THEN

        --  SELECT  PRICING_RULE
        --  INTO    l_pricing_rule
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_pricing_rule_id;

        NULL;

    END IF;

    RETURN l_pricing_rule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_rule');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Rule;

FUNCTION Reprice
(   p_reprice_flag                  IN  VARCHAR2
) RETURN VARCHAR2
IS
l_reprice                     VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_reprice_flag IS NOT NULL THEN

        --  SELECT  REPRICE
        --  INTO    l_reprice
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_reprice_flag;

        NULL;

    END IF;

    RETURN l_reprice;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reprice');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reprice'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reprice;

FUNCTION Unit
(   p_unit_code                     IN  VARCHAR2
) RETURN VARCHAR2
IS
l_unit                        VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_unit_code IS NOT NULL THEN

        --  SELECT  UNIT
        --  INTO    l_unit
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_unit_code;

        NULL;

    END IF;

    RETURN l_unit;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','unit');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Unit'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Unit;

FUNCTION Customer_Class
(   p_customer_class_code           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_customer_class              VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_customer_class_code IS NOT NULL THEN

        --  SELECT  CUSTOMER_CLASS
        --  INTO    l_customer_class
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_customer_class_code;

        NULL;

    END IF;

    RETURN l_customer_class;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','customer_class');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Class;

FUNCTION Discount_Customer
(   p_discount_customer_id          IN  NUMBER
) RETURN VARCHAR2
IS
l_discount_customer           VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_discount_customer_id IS NOT NULL THEN

        --  SELECT  DISCOUNT_CUSTOMER
        --  INTO    l_discount_customer
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_discount_customer_id;

        NULL;

    END IF;

    RETURN l_discount_customer;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_customer');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Customer'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Customer;

FUNCTION Site_Use
(   p_site_use_id                   IN  NUMBER
) RETURN VARCHAR2
IS
l_site_use                    VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_site_use_id IS NOT NULL THEN

        --  SELECT  SITE_USE
        --  INTO    l_site_use
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_site_use_id;

        NULL;

    END IF;

    RETURN l_site_use;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','site_use');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Site_Use'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Site_Use;

FUNCTION Entity
(   p_entity_id                     IN  NUMBER
) RETURN VARCHAR2
IS
l_entity                      VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_entity_id IS NOT NULL THEN

        --  SELECT  ENTITY
        --  INTO    l_entity
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_entity_id;

        NULL;

    END IF;

    RETURN l_entity;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','entity');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Entity;

FUNCTION Method_Type
(   p_method_type_code              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_method_type                 VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_method_type_code IS NOT NULL THEN

        --  SELECT  METHOD_TYPE
        --  INTO    l_method_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_method_type_code;

        NULL;

    END IF;

    RETURN l_method_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','method_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Method_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Method_Type;

FUNCTION Lot_Serial
(   p_lot_serial_id                 IN  NUMBER
) RETURN VARCHAR2
IS
l_lot_serial                  VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_lot_serial_id IS NOT NULL THEN

        --  SELECT  LOT_SERIAL
        --  INTO    l_lot_serial
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_lot_serial_id;

        NULL;

    END IF;

    RETURN l_lot_serial;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lot_serial');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lot_Serial'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lot_Serial;

FUNCTION Appear_On_Ack
(   p_appear_on_ack_flag            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_appear_on_ack               VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_appear_on_ack_flag IS NOT NULL THEN

        --  SELECT  APPEAR_ON_ACK
        --  INTO    l_appear_on_ack
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_appear_on_ack_flag;

        NULL;

    END IF;

    RETURN l_appear_on_ack;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','appear_on_ack');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Appear_On_Ack'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Appear_On_Ack;

FUNCTION Appear_On_Invoice
(   p_appear_on_invoice_flag        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_appear_on_invoice           VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_appear_on_invoice_flag IS NOT NULL THEN

        --  SELECT  APPEAR_ON_INVOICE
        --  INTO    l_appear_on_invoice
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_appear_on_invoice_flag;

        NULL;

    END IF;

    RETURN l_appear_on_invoice;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','appear_on_invoice');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Appear_On_Invoice'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Appear_On_Invoice;

FUNCTION Charge
(   p_charge_id                     IN  NUMBER
) RETURN VARCHAR2
IS
l_charge                      VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_charge_id IS NOT NULL THEN

        --  SELECT  CHARGE
        --  INTO    l_charge
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_charge_id;

        NULL;

    END IF;

    RETURN l_charge;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','charge');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge;

FUNCTION Charge_Type
(   p_charge_type_id                IN  NUMBER
) RETURN VARCHAR2
IS
l_charge_type                 VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_charge_type_id IS NOT NULL THEN

        --  SELECT  CHARGE_TYPE
        --  INTO    l_charge_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_charge_type_id;

        NULL;

    END IF;

    RETURN l_charge_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','charge_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge_Type;

FUNCTION Cost_Or_Charge
(   p_cost_or_charge_flag           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_cost_or_charge              VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_cost_or_charge_flag IS NOT NULL THEN

        --  SELECT  COST_OR_CHARGE
        --  INTO    l_cost_or_charge
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_cost_or_charge_flag;

        NULL;

    END IF;

    RETURN l_cost_or_charge;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','cost_or_charge');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cost_Or_Charge'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cost_Or_Charge;

FUNCTION Delivery
(   p_delivery_id                   IN  NUMBER
) RETURN VARCHAR2
IS
l_delivery                    VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_delivery_id IS NOT NULL THEN

        --  SELECT  DELIVERY
        --  INTO    l_delivery
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_delivery_id;

        NULL;

    END IF;

    RETURN l_delivery;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','delivery');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delivery'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delivery;

FUNCTION Departure
(   p_departure_id                  IN  NUMBER
) RETURN VARCHAR2
IS
l_departure                   VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_departure_id IS NOT NULL THEN

        --  SELECT  DEPARTURE
        --  INTO    l_departure
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_departure_id;

        NULL;

    END IF;

    RETURN l_departure;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','departure');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Departure'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Departure;

FUNCTION Estimated
(   p_estimated_flag                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_estimated                   VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_estimated_flag IS NOT NULL THEN

        --  SELECT  ESTIMATED
        --  INTO    l_estimated
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_estimated_flag;

        NULL;

    END IF;

    RETURN l_estimated;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','estimated');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Estimated'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Estimated;

FUNCTION Invoiced
(   p_invoiced_flag                 IN  VARCHAR2
) RETURN VARCHAR2
IS
l_invoiced                    VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_invoiced_flag IS NOT NULL THEN

        --  SELECT  INVOICED
        --  INTO    l_invoiced
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_invoiced_flag;

        NULL;

    END IF;

    RETURN l_invoiced;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoiced');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoiced'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoiced;

FUNCTION Parent_Charge
(   p_parent_charge_id              IN  NUMBER
) RETURN VARCHAR2
IS
l_parent_charge               VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_parent_charge_id IS NOT NULL THEN

        --  SELECT  PARENT_CHARGE
        --  INTO    l_parent_charge
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_parent_charge_id;

        NULL;

    END IF;

    RETURN l_parent_charge;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','parent_charge');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Parent_Charge'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Parent_Charge;

FUNCTION Returnable
(   p_returnable_flag               IN  VARCHAR2
) RETURN VARCHAR2
IS
l_returnable                  VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_returnable_flag IS NOT NULL THEN

        --  SELECT  RETURNABLE
        --  INTO    l_returnable
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_returnable_flag;

        NULL;

    END IF;

    RETURN l_returnable;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','returnable');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Returnable'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Returnable;
/* eBTax changes - the function Tax_Group would no longer be required.
FUNCTION Tax_Group
(   p_tax_code                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_tax_group                   VARCHAR2(1) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_tax_code IS NOT NULL THEN

        SELECT  DECODE(TAX_TYPE,'TAX_GROUP','Y',NULL)
        INTO    l_tax_group
        FROM    ar_vat_tax
        WHERE   tax_code = p_tax_code
	   AND     ROWNUM = 1;

    END IF;

    RETURN l_tax_group;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_group');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Group'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Group;
*/

FUNCTION Flow_Status
(   p_flow_status_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_flow_status               VARCHAR2(240) := NULL;
l_lookup_type1      	      VARCHAR2(80) :='FLOW_STATUS';
l_lookup_type2      	      VARCHAR2(80) :='LINE_FLOW_STATUS';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_flow_status_code IS NOT NULL THEN

        SELECT  distinct MEANING
        INTO    l_flow_status
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_flow_status_code
        AND     (LOOKUP_TYPE = l_lookup_type1
			  OR LOOKUP_TYPE = l_lookup_type2);

    END IF;

    RETURN l_flow_status;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','flow_status');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Flow_Status'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Flow_Status;

FUNCTION Freight_Carrier
(   p_freight_carrier_code            IN  VARCHAR2
,   p_ship_from_org_id			   IN  NUMBER
) RETURN VARCHAR2
IS
l_freight_carrier               VARCHAR2(240) := NULL;
l_ship_from_org_id			  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_ship_from_org_id = FND_API.G_MISS_NUM THEN
	  l_ship_from_org_id := NULL;
    ELSE
	  l_ship_from_org_id := p_ship_from_org_id;
    END IF;

    IF p_freight_carrier_code IS NOT NULL THEN

        SELECT  DESCRIPTION
        INTO    l_freight_carrier
        FROM    ORG_FREIGHT
        WHERE   FREIGHT_CODE = p_freight_carrier_code
        AND     ORGANIZATION_ID = nvl(l_ship_from_org_id,ORGANIZATION_ID);

    END IF;

    RETURN l_freight_carrier;

EXCEPTION

    WHEN TOO_MANY_ROWS THEN
	--    NULL;
        RETURN NULL;  --  Added for the bug 3554864

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_carrier');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Freight_Carrier'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Freight_Carrier;

FUNCTION Sales_Channel
(   p_sales_channel_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_sales_channel			VARCHAR2(80);
l_lookup_type      	      VARCHAR2(80) := 'SALES_CHANNEL';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_sales_channel_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_sales_channel
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_sales_channel_code
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_sales_channel;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_channel');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sales_Channel'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sales_Channel;

PROCEDURE Ship_To_Customer_Name
(   p_ship_to_org_id                IN  NUMBER
, x_ship_to_customer_name OUT NOCOPY VARCHAR2

)

IS
l_site_use_code VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_ship_to_org_id is NOT NULL THEN

        l_site_use_code := 'SHIP_TO';

        SELECT /* MOAC_SQL_CHANGE */ P.PARTY_NAME
        INTO    x_ship_to_customer_name
        FROM    HZ_CUST_SITE_USES_all site,
                HZ_CUST_ACCT_SITES cas,
                HZ_CUST_ACCOUNTS cust,
                HZ_PARTIES p
        WHERE   site.cust_acct_site_id=cas.cust_acct_site_id
	   AND     cust.cust_account_id=cas.cust_account_id
           AND     cust.party_id = p.party_id
	   AND     site.site_use_code=l_site_use_code
	   AND     site.site_use_id=p_ship_to_org_id;

    ELSE

        x_ship_to_customer_name    :=  NULL    ;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_customer_name');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_To_customer_name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_To_Customer_Name;

PROCEDURE Invoice_To_Customer_Name
(   p_invoice_to_org_id                IN  NUMBER
, x_invoice_to_customer_name OUT NOCOPY VARCHAR2

)

IS
l_site_use_code VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_invoice_to_org_id is NOT NULL THEN

        l_site_use_code := 'BILL_TO';

        SELECT /* MOAC_SQL_CHANGE */ P.PARTY_NAME
        INTO    x_invoice_to_customer_name
        FROM    HZ_CUST_SITE_USES_ALL site,
                HZ_CUST_ACCT_SITES cas,
                HZ_CUST_ACCOUNTS cust,
                HZ_PARTIES p
        WHERE   site.cust_acct_site_id=cas.cust_acct_site_id
	   AND     cust.cust_account_id=cas.cust_account_id
           AND     cust.party_id = p.party_id
	   AND     site.site_use_code=l_site_use_code
	   AND     site.site_use_id=p_invoice_to_org_id;

    ELSE

        x_invoice_to_customer_name    :=  NULL    ;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_customer_name');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_customer_name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Customer_Name;

PROCEDURE Ordered_Item
( p_item_identifier_type   IN  VARCHAR2
, p_inventory_item_id      IN  NUMBER
, p_organization_id        IN  NUMBER
, p_ordered_item_id        IN  NUMBER
, p_sold_to_org_id         IN  NUMBER
, p_ordered_item           IN  VARCHAR2
, x_ordered_item OUT NOCOPY VARCHAR2

, x_inventory_item OUT NOCOPY VARCHAR2)

IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING ORDERED_ITEM' , 1 ) ;
 END IF;
   IF NVL(p_item_identifier_type, 'INT') = 'INT' THEN
      BEGIN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXSIDVB ITEM IDENTIFIER IS INT' ) ;
         END IF;

         SELECT concatenated_segments
               ,concatenated_segments
         INTO   x_ordered_item
               ,x_inventory_item
         FROM  mtl_system_items_vl
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ORDERED_ITEM_DSP: '||X_ORDERED_ITEM ) ;
         END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Null;
        When too_many_rows then
          Null;
	   When others then
	      Null;
      END;
    ELSIF NVL(p_item_identifier_type, 'INT') = 'CUST' THEN
      BEGIN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXSIDVB ITEM IDENTIFIER IS CUST' ) ;
         END IF;
         SELECT citems.customer_item_number
               ,sitems.concatenated_segments
         INTO   x_ordered_item
               ,x_inventory_item
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = p_organization_id
           AND citems.customer_item_id = p_ordered_item_id
           AND citems.customer_id = p_sold_to_org_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Null;
        When too_many_rows then
	     Null;
	   When others then
	     Null;
      END;
    ELSE
      BEGIN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN OEXSIDVB ITEM IDENTIFIER IS GENE' ) ;
       END IF;
       IF p_ordered_item_id IS NULL THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ORDERED_ITEM_ID IS NULL ' ) ;
	         oe_debug_pub.add(  'ORDERED_ITEM: '||P_ORDERED_ITEM ) ;
	     END IF;
         SELECT items.cross_reference
                ,sitems.concatenated_segments
         INTO    x_ordered_item
                ,x_inventory_item
         FROM  mtl_cross_reference_types types
             , mtl_cross_references items
             , mtl_system_items_vl sitems
         WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.organization_id = p_organization_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item;
       END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         Null;
        When too_many_rows then
	     Null;
	   When others then
	     Null;
      END;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORDERED_ITEM_DSP: '||X_ORDERED_ITEM ) ;
    END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ordered_Item');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ordered_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ordered_Item;

PROCEDURE  Item_Identifier
(p_Item_Identifier_type IN  VARCHAR2
, x_Item_Identifier OUT NOCOPY VARCHAR2)

IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_lookup_type      	      VARCHAR2(80) :='ITEM_IDENTIFIER_TYPE';
--
BEGIN
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING ITEM_IDENTIFIER' , 1 ) ;
 END IF;
 IF p_Item_Identifier_type in ('INT','CUST') THEN
   Select  meaning
   Into    x_Item_Identifier
   From oe_lookups
   Where lookup_type = l_lookup_type
   And lookup_code   = p_Item_Identifier_type;
 ELSE
   x_Item_Identifier := p_Item_Identifier_type;

 END IF;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ITEM_IDENTIFIER' || X_ITEM_IDENTIFIER , 1 ) ;
 END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Item_Identifier');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Identifier'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Identifier;

PROCEDURE  Item_Relationship_Type
(p_Item_Relationship_Type           IN  NUMBER
, x_Item_Relationship_Type_Dsp      OUT nocopy VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_lookup_type      	      VARCHAR2(80) :='MTL_RELATIONSHIP_TYPES';
--
BEGIN
 IF l_debug_level  > 0 THEN
 oe_debug_pub.add('Entering Item_Relationship_Type',1);
 END IF;
 IF p_Item_Relationship_Type IS NOT NULL THEN
   Select  meaning
   Into    x_Item_Relationship_Type_dsp
   From mfg_lookups
   Where lookup_type = l_lookup_type
   And lookup_code   = p_Item_Relationship_Type;
 ELSE
   x_Item_Relationship_Type_Dsp := null;

 IF l_debug_level  > 0 THEN
 oe_debug_pub.add('in else Item_Relationship_Type' || x_Item_Relationship_Type_Dsp,1);
 END IF;
 END IF;

 IF l_debug_level  > 0 THEN
 oe_debug_pub.add('Item_Relationship_Type_dsp' || x_Item_Relationship_Type_Dsp,1);
 END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Item_Relationship_Type');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Relationship_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Relationship_Type;

FUNCTION User_Status
(   p_user_status_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_user_status         VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_lookup_type      	      VARCHAR2(80) := 'USER_STATUS';
--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN GET VALUES ' || p_user_status_code ) ;
	END IF;
    IF p_user_status_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_user_status
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_user_status_code
        AND     LOOKUP_TYPE = l_lookup_type;


    END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN GET VALUES ' || L_user_status ) ;
	END IF;
    RETURN l_user_status;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_status');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'user_status'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_status;


FUNCTION Transaction_Phase
(   p_Transaction_Phase_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_Transaction_Phase         VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_lookup_type      	      VARCHAR2(80) :='TRANSACTION_PHASE';
--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN GET VALUES ' || p_Transaction_Phase_code ) ;
	END IF;
    IF p_Transaction_Phase_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_Transaction_Phase
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_Transaction_Phase_code
        AND     LOOKUP_TYPE = l_lookup_type;


    END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN GET VALUES ' || L_Transaction_Phase ) ;
	END IF;
    RETURN l_Transaction_Phase;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_phase');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'transaction_phase'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Phase;
PROCEDURE Customer_Location
(
  p_sold_to_site_use_id       IN         NUMBER
, x_sold_to_location_address1 OUT NOCOPY VARCHAR2
, x_sold_to_location_address2 OUT NOCOPY VARCHAR2
, x_sold_to_location_address3 OUT NOCOPY VARCHAR2
, x_sold_to_location_address4 OUT NOCOPY VARCHAR2
, x_sold_to_location          OUT NOCOPY VARCHAR2
, x_sold_to_location_city     OUT NOCOPY VARCHAR2
, x_sold_to_location_state    OUT NOCOPY VARCHAR2
, x_sold_to_location_postal   OUT NOCOPY VARCHAR2
, x_sold_to_location_country  OUT NOCOPY VARCHAR2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_sold_to_site_use_id is NOT NULL THEN

        SELECT  /* MOAC_SQL_CHANGE */
                SITE.LOCATION
        ,       LOC.ADDRESS1
        ,       LOC.ADDRESS2
        ,       LOC.ADDRESS3
        ,       LOC.ADDRESS4
        ,       LOC.CITY
        ,       nvl(LOC.STATE,LOC.PROVINCE) -- 3603600
        ,       LOC.POSTAL_CODE
        ,       LOC.COUNTRY
        INTO
                x_sold_to_location
        ,       x_sold_to_location_address1
        ,       x_sold_to_location_address2
        ,       x_sold_to_location_address3
        ,       x_sold_to_location_address4
        ,       x_sold_to_location_city
        ,       x_sold_to_location_state
        ,       x_sold_to_location_postal
        ,       x_sold_to_location_country

        FROM
                HZ_CUST_SITE_USES_All   SITE,
                HZ_PARTY_SITES          PARTY_SITE,
                HZ_LOCATIONS	        LOC,
                HZ_CUST_ACCT_SITES      ACCT_SITE
       WHERE
             SITE.SITE_USE_CODE         = 'SOLD_TO'
       AND   SITE.SITE_USE_ID           = p_sold_to_site_use_id
       AND   SITE.CUST_ACCT_SITE_ID     = ACCT_SITE.CUST_ACCT_SITE_ID
       AND   ACCT_SITE.PARTY_SITE_ID    = PARTY_SITE.PARTY_SITE_ID
       AND   PARTY_SITE.LOCATION_ID     = LOC.LOCATION_ID;

    ELSE

        x_sold_to_location             :=  NULL    ;
        x_sold_to_location_address1    :=  NULL    ;
        x_sold_to_location_address2    :=  NULL    ;
        x_sold_to_location_address3    :=  NULL    ;
        x_sold_to_location_address4    :=  NULL    ;
        x_sold_to_location_city        :=  NULL    ;
        x_sold_to_location_state       :=  NULL    ;
        x_sold_to_location_postal      :=  NULL    ;
        x_sold_to_location_country     :=  NULL    ;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Customer_Location');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Location'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Location;

/*-----------------------------------------------------------------
PROCEDURE Get_Contact_Details

added for pack J enhanced dropship project.
------------------------------------------------------------------*/
PROCEDURE Get_Contact_Details
( p_contact_id  IN NUMBER
 ,x_contact_name        OUT NOCOPY VARCHAR2
 ,x_phone_line_type     OUT NOCOPY VARCHAR2
 ,x_phone_number        OUT NOCOPY VARCHAR2
 ,x_email_address       OUT NOCOPY VARCHAR2)
IS
BEGIN

  SELECT  SUBSTRB(CONTACT_PARTY.PARTY_NAME,1,70) CONTACT_NAME,
  DECODE(arl.meaning,NULL, NULL, ' '||arl.meaning) Phone_Type,
  DECODE(CONTACT.phone_country_code, NULL, NULL,
         CONTACT.phone_country_code || '- ') ||
  DECODE(CONTACT.phone_area_code, NULL, NULL, CONTACT.phone_area_code || '-')||
  DECODE(CONTACT.phone_number, NULL, NULL, CONTACT.phone_number ) phone,
  REL_PARTY.email_address
  INTO   x_contact_name,
         x_phone_line_type,
         x_phone_number,
         x_email_address
  FROM   HZ_CONTACT_POINTS CONTACT,
         HZ_PARTIES CONTACT_PARTY,
         HZ_CUST_ACCOUNT_ROLES ACCT_ROLES,
         HZ_CUST_ACCOUNTS CUST_ACCT,
         HZ_RELATIONSHIPS PARTY_REL,
         HZ_PARTIES  REL_PARTY,
         AR_LOOKUPS  ARL
  WHERE  CONTACT.owner_table_name(+)  = 'HZ_PARTIES'
  AND CONTACT.PRIMARY_FLAG (+)        = 'Y'
  AND CONTACT.contact_point_type (+)  = 'PHONE'
  AND ACCT_ROLES.PARTY_ID             =  CONTACT.owner_table_id(+)
  AND ACCT_ROLES.cust_account_role_id = p_contact_id
  AND PARTY_REL.PARTY_ID              = ACCT_ROLES.PARTY_ID
  AND PARTY_REL.PARTY_ID              = REL_PARTY.PARTY_ID
  AND PARTY_REL.SUBJECT_ID            = CONTACT_PARTY.PARTY_ID
  AND PARTY_REL.OBJECT_ID             = CUST_ACCT.PARTY_ID
  AND ACCT_ROLES.CUST_ACCOUNT_ID      = CUST_ACCT.CUST_ACCOUNT_ID
  AND CONTACT.status(+)               = 'A'
  AND ACCT_ROLES.STATUS               = 'A'
  AND ARL.lookup_type (+)             = 'PHONE_LINE_TYPE'
  AND ARL.lookup_code(+)              = CONTACT.phone_line_type;

EXCEPTION
  WHEN others THEN
    oe_debug_pub.add('Get_Contact_Details ' || sqlerrm, 1);
END Get_Contact_Details;

--serla begin
FUNCTION payment_collection_event_name
(   p_payment_collection_event            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_lookup_type      	      VARCHAR2(80) := 'OE_PAYMENT_COLLECTION_TYPE';
l_payment_collection_event                 VARCHAR2(80);
BEGIN

    IF p_payment_collection_event IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_payment_collection_event
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_payment_collection_event
        AND     LOOKUP_TYPE = l_lookup_type;

    END IF;

    RETURN l_payment_collection_event;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_collection_event_name');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'payment_collection_event_name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END payment_collection_event_name;

FUNCTION Receipt_Method
(   p_receipt_method            IN  NUMBER
) RETURN VARCHAR2
IS
l_receipt_method                 VARCHAR2(80);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_err_message VARCHAR2(2000);
BEGIN

    IF l_debug_level > 0 THEN
	oe_debug_pub.add('Receipt method id....ksurendr'||p_receipt_method);
    END IF;

    IF p_receipt_method IS NOT NULL AND p_receipt_method <> 0 AND
    NOT OE_GLOBALS.Equal(p_receipt_method,FND_API.G_MISS_NUM) THEN
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Inside if part....');
	END IF;
        SELECT  NAME
        INTO    l_receipt_method
        FROM    AR_RECEIPT_METHODS
        WHERE   receipt_method_id = p_receipt_method;
    --bug 5204358
    ELSIF p_receipt_method = 0 THEN
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Inside else part....');
	END IF;
	fnd_message.set_name('ONT','OE_VPM_NO_PAY_METHOD');
	OE_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    RETURN l_receipt_method;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Receipt_Method');
            OE_MSG_PUB.Add;

        END IF;

    WHEN FND_API.G_EXC_ERROR THEN
	l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Id to value error for receipt method....exc');
		oe_debug_pub.add('Error'||l_err_message);
	END IF;

	RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Receipt_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Receipt_Method;
--serla end

FUNCTION get_sales_group_name
(p_sales_group_id IN NUMBER
)RETURN VARCHAR2 IS

l_sales_group_name                VARCHAR2(80);
BEGIN

    IF p_sales_group_id IS NOT NULL THEN
      Select group_name into l_sales_group_name
      From   jtf_rs_groups_vl
      Where  Group_id=p_sales_group_id;
    ELSE
       Oe_Debug_Pub.add('Input sales group id is null');
    END IF;

    RETURN l_sales_group_name;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF p_sales_group_id <>  -1 THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
           THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_group_name');
            OE_MSG_PUB.Add;

          END IF;
        ELSE
          oe_debug_pub.add('Sales Group, -1 sales group id');
        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'sales_group_name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_sales_group_name;

FUNCTION end_customer_Contact
(   p_end_customer_contact_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_end_customer_contact             VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_end_customer_contact_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_end_customer_contact
        FROM    OE_CONTACTS_V
        WHERE   CONTACT_ID = p_end_customer_contact_id;

    END IF;

    RETURN l_end_customer_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End_Customer_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END End_Customer_Contact;

PROCEDURE  End_Customer
(   p_end_customer_id    	IN  NUMBER  	,
    x_end_customer_name         OUT NOCOPY VARCHAR2 ,
    x_end_customer_number       OUT NOCOPY VARCHAR2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_end_customer_id is NOT NULL THEN

       	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'DOING SELECT FOR END_CUSTOMER_NUMBER' ) ;
	END IF;
	SELECT  O.NAME
	,	O.CUSTOMER_NUMBER
	INTO    x_end_customer_name
	,	x_end_customer_number
	FROM    OE_SOLD_TO_ORGS_V	O
	WHERE   O.ORGANIZATION_ID   = p_end_customer_id;

    ELSE

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE QUERY FOR END CUSTOMER NUMBER - NO ORG_ID PASSED' ) ;
        END IF;
	x_end_customer_name     :=  NULL    ;
	x_end_customer_number   :=  NULL    ;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'end_customer'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END end_customer;

PROCEDURE end_customer_site_use
(   p_end_customer_site_use_id           IN  NUMBER
,   x_end_customer_address1              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_address2              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_address3              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_address4              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_location              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_city                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_state                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_postal_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_country               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_end_customer_site_use_id is NOT NULL THEN

       SELECT /* MOAC_SQL_CHANGE */
	   loc.address1
	  ,loc.address2
	  ,loc.address3
	  ,loc.address4
	  ,site_use.location
	  ,loc.city
	  ,nvl(loc.state,loc.province) -- 3603600
	  ,loc.postal_code
	  ,loc.country
      INTO
	   x_end_customer_address1
	  ,x_end_customer_address2
	  ,x_end_customer_address3
	  ,x_end_customer_address4
	  ,x_end_customer_location
	  ,x_end_customer_city
	  ,x_end_customer_state
	  ,x_end_customer_postal_code
	  ,x_end_customer_country
      FROM
	  hz_locations loc,
	  hz_party_sites site,
	  hz_cust_site_uses_all site_use,
	  hz_cust_acct_sites acct_site
     WHERE
	  site_use.site_use_id= p_end_customer_site_use_id
	  and site_use.cust_acct_site_id=acct_site.cust_acct_site_id
	  and acct_site.party_site_id=site.party_site_id
	  and site.location_id=loc.location_id;

    ELSE
       x_end_customer_address1     := NULL;
       x_end_customer_address2     := NULL;
       x_end_customer_address3     := NULL;
       x_end_customer_address4     := NULL;
       x_end_customer_location     := NULL;
       x_end_customer_city         := NULL;
       x_end_customer_state        := NULL;
       x_end_customer_postal_code  := NULL;
       x_end_customer_country      := NULL;
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_site');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'end_customer_site_use'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END end_customer_site_use;

--Macd

FUNCTION  IB_OWNER
(   p_ib_owner            IN    VARCHAR2
) RETURN VARCHAR2
IS
l_ib_owner_dsp             VARCHAR2(60) := NULL;
l_lookup_type1      	      VARCHAR2(80) :='ITEM_OWNER';
l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_ib_owner IS NOT NULL THEN

        SELECT  meaning
        INTO    l_ib_owner_dsp
        FROM    OE_LOOKUPS
        WHERE   lookup_code= p_ib_owner and
                (lookup_type=l_lookup_type1 or lookup_type=l_lookup_type2);

    END IF;

    RETURN l_ib_owner_dsp;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_OWNER');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'IB_OWNER'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IB_OWNER;

FUNCTION  IB_CURRENT_LOCATION
(   p_ib_current_location            IN    VARCHAR2
) RETURN VARCHAR2
IS
l_ib_current_location_dsp             VARCHAR2(60) := NULL;
l_lookup_type1      	      VARCHAR2(80) :='ITEM_CURRENT_LOCATION';
l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_ib_current_location IS NOT NULL THEN

        SELECT  meaning
        INTO    l_ib_current_location_dsp
        FROM    OE_LOOKUPS
        WHERE   lookup_code= p_ib_current_location and
                (lookup_type=l_lookup_type1 or lookup_type=l_lookup_type2);

    END IF;

    RETURN l_ib_current_location_dsp;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_CURRENT_LOCATION');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'IB_CURRENT_LOCATION'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IB_CURRENT_LOCATION;

FUNCTION  IB_INSTALLED_AT_LOCATION
(   p_ib_installed_at_location            IN    VARCHAR2
) RETURN VARCHAR2
IS
l_ib_installed_at_location_dsp             VARCHAR2(60) := NULL;
l_lookup_type1      	      VARCHAR2(80) :='ITEM_INSTALL_LOCATION';
l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_ib_installed_at_location IS NOT NULL THEN

        SELECT  meaning
        INTO    l_ib_installed_at_location_dsp
        FROM    OE_LOOKUPS
        WHERE   lookup_code= p_ib_installed_at_location and
                (lookup_type=l_lookup_type1 or lookup_type=l_lookup_type2);

    END IF;

    RETURN l_ib_installed_at_location_dsp;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_INSTALLED_AT_LOCATION');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'IB_INSTALLED_AT_LOCATION'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IB_INSTALLED_AT_LOCATION;
--Macd

--Recurring CHarges
FUNCTION  Charge_Periodicity
(   p_charge_periodicity_code            IN    VARCHAR2
) RETURN VARCHAR2
IS
l_charge_periodicity_dsp             VARCHAR2(60) := NULL;
--l_profile_value      	              VARCHAR2(80) :=Oe_Sys_Parameters.Value('UOM_CLASS_CHARGE_PERIODICITY');
l_profile_value      	              VARCHAR2(80) :=fnd_profile.Value('ONT_UOM_CLASS_CHARGE_PERIODICITY');
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_charge_periodicity_code IS NOT NULL THEN

        SELECT  unit_of_measure
        INTO    l_charge_periodicity_dsp
        FROM    mtl_units_of_measure_vl
        WHERE   uom_class=l_profile_value
                and uom_code=p_charge_periodicity_code;

    END IF;

    RETURN l_charge_periodicity_dsp;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CHARGE_PERIODICITY_CODE');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CHARGE_PERIODICITY'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge_Periodicity;
--Recurring Charges


/*3605052*/
FUNCTION  SERVICE_PERIOD
(   p_service_period            IN    VARCHAR2
    ,p_inventory_item_id         IN    NUMBER
) RETURN VARCHAR2
IS
l_service_period_dsp             VARCHAR2(60) := NULL;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_temp       VARCHAR2(60) := NULL;
BEGIN

    IF p_service_period IS NOT NULL THEN

     --webroot bug 6826344 start
        SELECT service_item_flag
        INTO l_temp
        FROM MTL_SYSTEM_ITEMS_B
        WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

    --OE_MSG_PUB.ADD_TEXT('l_temp' || l_temp);
    IF l_temp = 'Y' THEN
         --webroot bug 6826344 end

         Select description
         INTO l_service_period_dsp
         FROM mtl_item_uoms_view
         WHERE uom_code  =p_service_period
                and inventory_item_id = p_inventory_item_id
	        and organization_id = OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
     END IF;

    --OE_MSG_PUB.ADD_TEXT('l_service_period_dsp'|| l_service_period_dsp);
    END IF;

    RETURN l_service_period_dsp;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','SERVICE_PERIOD');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'SERVICE_PERIOD'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SERVICE_PERIOD;

-- Added for bug 5701246

FUNCTION  SERVICE_REFERENCE_TYPE
(   p_service_reference_type_code            IN    VARCHAR2
) RETURN VARCHAR2
IS
l_service_reference_type             VARCHAR2(240) := NULL;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   IF p_service_reference_type_code IS NOT NULL THEN

         Select meaning
         INTO l_service_reference_type
         FROM   oe_lookups
         WHERE  lookup_code=p_service_Reference_type_code
                and lookup_type = 'SERVICE_REFERENCE_TYPE_CODE';

   END IF;

   RETURN l_service_reference_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','SERVICE_REFERENCE_TYPE');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'SERVICE_REFERENCE_TYPE'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SERVICE_REFERENCE_TYPE;

-- end Added for bug 5701246

--  END GEN Id_To_Value

FUNCTION  CHANGE_REASON
(   p_change_reason_code            IN    VARCHAR2
) RETURN VARCHAR2
IS
l_change_reason             VARCHAR2(60) := NULL;
l_lookup_type1      	      VARCHAR2(80) :='CHANGE_CODE';
l_lookup_type2      	      VARCHAR2(80) :='CANCEL_CODE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_change_reason_code IS NOT NULL THEN

        SELECT  meaning
        INTO    l_change_reason
        FROM    OE_LOOKUPS
        WHERE   lookup_code= p_change_reason_code
         and       (lookup_type=l_lookup_type1 or lookup_type=l_lookup_type2);

    END IF;

    RETURN l_change_reason;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CHANGE_CODE');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CHANGE_CODE'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CHANGE_REASON;

--Customer Acceptance
Procedure Get_Contingency_Attributes
(   p_contingency_id               IN  NUMBER
   , x_contingency_name            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_contingency_description     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_expiration_event_attribute  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_expiration_event_code  VARCHAR2(30):=NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

        x_contingency_name := NULL;
        x_contingency_description := NULL;
        x_expiration_event_attribute := NULL;
    IF p_contingency_id IS NOT NULL THEN

        SELECT  contingency_name, description, expiration_event_code
        INTO    x_contingency_name, x_contingency_description, l_expiration_event_code
        FROM    AR_DEFERRAL_REASONS
        WHERE   contingency_id = p_contingency_id;


       IF l_expiration_event_code IS NOT NULL THEN
          SELECT MEANING
          INTO x_expiration_event_attribute
          FROM AR_LOOKUPS
          WHERE lookup_type='AR_EXPIRATION_EVENTS'
          AND lookup_code = l_expiration_event_code;
       END IF;

    ELSE
       x_contingency_name := NULL;
       x_contingency_description := NULL;
       x_expiration_event_attribute := NULL;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CONTINGENCY_ID');
            OE_MSG_PUB.Add;

        END IF;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Contingency_Attributes'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Contingency_Attributes;

FUNCTION Revrec_Event(p_revrec_event_code IN VARCHAR2) RETURN VARCHAR2
IS
l_revrec_event VARCHAR2(80);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_revrec_event_code IS NOT NULL THEN
           SELECT MEANING
          INTO l_revrec_event
          FROM AR_LOOKUPS
          WHERE lookup_type='AR_REVREC_EVENTS'
          AND lookup_code = p_revrec_event_code;
      ELSE
         l_revrec_event := NULL;
       END IF;

RETURN l_revrec_event;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','REVREC_EVENT_CODE');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revrec_Event'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revrec_Event;

FUNCTION Accepted_By(p_accepted_by IN NUMBER) RETURN VARCHAR2
IS
l_accepted_by_dsp VARCHAR2(100);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_accepted_by IS NOT NULL THEN
           SELECT user_name
          INTO l_accepted_by_dsp
          FROM FND_USER
          WHERE user_id=p_accepted_by;
     ELSE
          l_accepted_by_dsp:= NULL;
     END IF;

RETURN l_accepted_by_dsp;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ACCEPTED_BY');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accepted_By'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accepted_By;


END OE_Id_To_Value;

/
