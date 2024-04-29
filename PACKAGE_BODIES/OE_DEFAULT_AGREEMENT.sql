--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_AGREEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_AGREEMENT" AS
/* $Header: OEXDAGRB.pls 120.3 2005/12/14 15:57:40 shulin ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Agreement';

--  Package global used within the package.

g_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;

--  Get functions.

FUNCTION Get_Accounting_Rule
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Accounting_Rule;

FUNCTION Get_Agreement_Contact
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Agreement_Contact;

FUNCTION Get_Agreement
RETURN NUMBER
IS
	l_Agreement_Id	NUMBER := NULL;
BEGIN

    oe_debug_pub.add('Entering OE_Default_Agreement.Get_Agreement');

    select oe_agreements_s.nextval into l_Agreement_Id
    from dual;

    oe_debug_pub.add('Exiting OE_Default_Agreement.Get_Agreement, agreement_id: '||to_char(l_Agreement_Id));

    RETURN l_Agreement_Id;

EXCEPTION

   WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         OE_MSG_PUB.Add_Exc_Msg
           (    G_PKG_NAME          ,
                'Get_Agreement'
            );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Agreement;

FUNCTION Get_Agreement_Num
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Agreement_Num;

FUNCTION Get_Agreement_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Agreement_Type;

FUNCTION Get_Customer
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Customer;

FUNCTION Get_End_Date_Active
RETURN DATE
IS
BEGIN

    /* Changed the following for bug 1524336.
       End date should be defaulted as NULL
       RETURN add_months(SYSDATE, 24); */

   RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Freight_Terms
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Freight_Terms;

FUNCTION Get_Invoice_Contact
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Invoice_Contact;

FUNCTION Get_Invoice_To_Site_Use
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Invoice_To_Site_Use;

FUNCTION Get_Invoicing_Rule
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Invoicing_Rule;

FUNCTION Get_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Name;

FUNCTION Get_Override_Arule
RETURN VARCHAR2
IS
BEGIN

    RETURN 'Y';

END Get_Override_Arule;

FUNCTION Get_Override_Irule
RETURN VARCHAR2
IS
BEGIN

    RETURN 'Y';

END Get_Override_Irule;

FUNCTION Get_Price_List
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_List;

FUNCTION Get_Purchase_Order_Num
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Purchase_Order_Num;

FUNCTION Get_Revision
RETURN VARCHAR2
IS
BEGIN

    RETURN '1';

END Get_Revision;

FUNCTION Get_Revision_Date
RETURN DATE
IS
BEGIN

    RETURN SYSDATE;

END Get_Revision_Date;

FUNCTION Get_Revision_Reason
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Revision_Reason;

FUNCTION Get_Salesrep
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Salesrep;

FUNCTION Get_Ship_Method
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Ship_Method;

FUNCTION Get_Signature_Date
RETURN DATE
IS
BEGIN

    RETURN SYSDATE;

END Get_Signature_Date;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
BEGIN

    RETURN SYSDATE;

END Get_Start_Date_Active;

FUNCTION Get_Term
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Term;

--Begin code added by rchellam for OKC
FUNCTION Get_Agreement_Source
RETURN VARCHAR2
IS
BEGIN

  RETURN 'PAGR';

END Get_Agreement_Source;

FUNCTION Get_Orig_System_Agr
RETURN NUMBER
IS
BEGIN

 RETURN NULL;

END Get_Orig_System_Agr;
--End code added by rchellam for OKC

-- Added for bug#4029589
FUNCTION Get_Invoice_To_Customer_Id
RETURN NUMBER
IS
BEGIN

 RETURN NULL;

END Get_Invoice_To_Customer_Id;

PROCEDURE Get_Flex_Agreement
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_Agreement_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute1     := NULL;
    END IF;

    IF g_Agreement_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute10    := NULL;
    END IF;

    IF g_Agreement_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute11    := NULL;
    END IF;

    IF g_Agreement_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute12    := NULL;
    END IF;

    IF g_Agreement_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute13    := NULL;
    END IF;

    IF g_Agreement_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute14    := NULL;
    END IF;

    IF g_Agreement_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute15    := NULL;
    END IF;

    IF g_Agreement_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute2     := NULL;
    END IF;

    IF g_Agreement_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute3     := NULL;
    END IF;

    IF g_Agreement_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute4     := NULL;
    END IF;

    IF g_Agreement_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute5     := NULL;
    END IF;

    IF g_Agreement_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute6     := NULL;
    END IF;

    IF g_Agreement_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute7     := NULL;
    END IF;

    IF g_Agreement_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute8     := NULL;
    END IF;

    IF g_Agreement_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.attribute9     := NULL;
    END IF;

    IF g_Agreement_rec.context = FND_API.G_MISS_CHAR THEN
        g_Agreement_rec.context        := NULL;
    END IF;

END Get_Flex_Agreement;

--  Procedure Attributes

PROCEDURE Attributes
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
)
IS
l_Agreement_rec		OE_Pricing_Cont_PUB.Agreement_Rec_Type; --[prarasto]
BEGIN

    oe_debug_pub.add('Entering OE_Default_Agreement.Attributes');

    --  Check number of iterations.

    IF p_iteration > OE_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_DEF_MAX_ITERATION');
            OE_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_Agreement_rec

    g_Agreement_rec := p_Agreement_rec;

    --  Default missing attributes.

    IF g_Agreement_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.accounting_rule_id := Get_Accounting_Rule;

        IF g_Agreement_rec.accounting_rule_id IS NOT NULL THEN

            IF OE_Validate_Attr.Accounting_Rule(g_Agreement_rec.accounting_rule_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_ACCOUNTING_RULE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.accounting_rule_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.agreement_contact_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.agreement_contact_id := Get_Agreement_Contact;

        IF g_Agreement_rec.agreement_contact_id IS NOT NULL THEN

            IF OE_Validate_Attr.Agreement_Contact(g_Agreement_rec.agreement_contact_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_AGREEMENT_CONTACT
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.agreement_contact_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.agreement_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.agreement_id := Get_Agreement;

        IF g_Agreement_rec.agreement_id IS NOT NULL THEN

            IF OE_Validate_Attr.Agreement(g_Agreement_rec.agreement_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_AGREEMENT
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.agreement_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.agreement_num = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.agreement_num := Get_Agreement_Num;

        IF g_Agreement_rec.agreement_num IS NOT NULL THEN

            IF OE_Validate_Attr.Agreement_Num(g_Agreement_rec.agreement_num)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_AGREEMENT_NUM
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.agreement_num := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.agreement_type_code = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.agreement_type_code := Get_Agreement_Type;

        IF g_Agreement_rec.agreement_type_code IS NOT NULL THEN

            IF OE_Validate_Attr.Agreement_Type(g_Agreement_rec.agreement_type_code)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_AGREEMENT_TYPE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.agreement_type_code := NULL;
            END IF;

        END IF;

    END IF;
--

    IF g_Agreement_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.sold_to_org_id := Get_Customer;

        IF g_Agreement_rec.sold_to_org_id IS NOT NULL THEN

            IF OE_Validate_Attr.Customer(g_Agreement_rec.sold_to_org_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_CUSTOMER
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.sold_to_org_id := NULL;
            END IF;

        END IF;

    END IF;

--
/*
    IF g_Agreement_rec.customer_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.customer_id := Get_Customer;

        IF g_Agreement_rec.customer_id IS NOT NULL THEN

            IF OE_Validate_Attr.Customer(g_Agreement_rec.customer_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_CUSTOMER
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.customer_id := NULL;
            END IF;

        END IF;

    END IF;
*/

    IF g_Agreement_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_Agreement_rec.end_date_active := Get_End_Date_Active;

        IF g_Agreement_rec.end_date_active IS NOT NULL THEN

            IF OE_Validate_Attr.End_Date_Active(g_Agreement_rec.end_date_active)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_END_DATE_ACTIVE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.freight_terms_code := Get_Freight_Terms;

        IF g_Agreement_rec.freight_terms_code IS NOT NULL THEN

            IF OE_Validate_Attr.Freight_Terms(g_Agreement_rec.freight_terms_code)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_FREIGHT_TERMS
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.freight_terms_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.invoice_contact_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.invoice_contact_id := Get_Invoice_Contact;

        IF g_Agreement_rec.invoice_contact_id IS NOT NULL THEN

            IF OE_Validate_Attr.Invoice_Contact(g_Agreement_rec.invoice_contact_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_INVOICE_CONTACT
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.invoice_contact_id := NULL;
            END IF;

        END IF;

    END IF;

/*    IF g_Agreement_rec.invoice_to_site_use_id = FND_API.G_MISS_NUM THEN */
    IF g_Agreement_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN

/*        g_Agreement_rec.invoice_to_site_use_id := Get_Invoice_To_Site_Use; */
        g_Agreement_rec.invoice_to_org_id := Get_Invoice_To_Site_Use;

/*        IF g_Agreement_rec.invoice_to_site_use_id IS NOT NULL THEN */
        IF g_Agreement_rec.invoice_to_org_id IS NOT NULL THEN

            IF OE_Validate_Attr.Invoice_To_Site_Use(g_Agreement_rec.invoice_to_org_id)

/*            IF OE_Validate_Attr.Invoice_To_Site_Use(g_Agreement_rec.invoice_to_site_use_id) */
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_INVOICE_TO_SITE_USE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
/*                g_Agreement_rec.invoice_to_site_use_id := NULL; */
                g_Agreement_rec.invoice_to_org_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.invoicing_rule_id := Get_Invoicing_Rule;

        IF g_Agreement_rec.invoicing_rule_id IS NOT NULL THEN

            IF OE_Validate_Attr.Invoicing_Rule(g_Agreement_rec.invoicing_rule_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_INVOICING_RULE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.invoicing_rule_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.name = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.name := Get_Name;

        IF g_Agreement_rec.name IS NOT NULL THEN

            IF OE_Validate_Attr.Name(g_Agreement_rec.name)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_NAME
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.override_arule_flag = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.override_arule_flag := Get_Override_Arule;

        IF g_Agreement_rec.override_arule_flag IS NOT NULL THEN

            IF OE_Validate_Attr.Override_Arule(g_Agreement_rec.override_arule_flag)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_OVERRIDE_ARULE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.override_arule_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.override_irule_flag = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.override_irule_flag := Get_Override_Irule;

        IF g_Agreement_rec.override_irule_flag IS NOT NULL THEN

            IF OE_Validate_Attr.Override_Irule(g_Agreement_rec.override_irule_flag)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_OVERRIDE_IRULE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.override_irule_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.price_list_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.price_list_id := Get_Price_List;

        IF g_Agreement_rec.price_list_id IS NOT NULL THEN

            IF OE_Validate_Attr.Price_List(g_Agreement_rec.price_list_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_PRICE_LIST
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.price_list_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.purchase_order_num = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.purchase_order_num := Get_Purchase_Order_Num;

        IF g_Agreement_rec.purchase_order_num IS NOT NULL THEN

            IF OE_Validate_Attr.Purchase_Order_Num(g_Agreement_rec.purchase_order_num)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_PURCHASE_ORDER_NUM
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.purchase_order_num := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.revision = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.revision := Get_Revision;

        IF g_Agreement_rec.revision IS NOT NULL THEN

            IF OE_Validate_Attr.Revision(g_Agreement_rec.revision)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_REVISION
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.revision := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.revision_date = FND_API.G_MISS_DATE THEN

        g_Agreement_rec.revision_date := Get_Revision_Date;

        IF g_Agreement_rec.revision_date IS NOT NULL THEN

            IF OE_Validate_Attr.Revision_Date(g_Agreement_rec.revision_date)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_REVISION_DATE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.revision_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.revision_reason_code := Get_Revision_Reason;

        IF g_Agreement_rec.revision_reason_code IS NOT NULL THEN

            IF OE_Validate_Attr.Revision_Reason(g_Agreement_rec.revision_reason_code)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_REVISION_REASON
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.revision_reason_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.salesrep_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.salesrep_id := Get_Salesrep;

        IF g_Agreement_rec.salesrep_id IS NOT NULL THEN

            IF OE_Validate_Attr.Salesrep(g_Agreement_rec.salesrep_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_SALESREP
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.salesrep_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.ship_method_code = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.ship_method_code := Get_Ship_Method;

        IF g_Agreement_rec.ship_method_code IS NOT NULL THEN

            IF OE_Validate_Attr.Ship_Method(g_Agreement_rec.ship_method_code)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_SHIP_METHOD
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.ship_method_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.signature_date = FND_API.G_MISS_DATE THEN

        g_Agreement_rec.signature_date := Get_Signature_Date;

        IF g_Agreement_rec.signature_date IS NOT NULL THEN

            IF OE_Validate_Attr.Signature_Date(g_Agreement_rec.signature_date)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_SIGNATURE_DATE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.signature_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_Agreement_rec.start_date_active := Get_Start_Date_Active;

        IF g_Agreement_rec.start_date_active IS NOT NULL THEN

            IF OE_Validate_Attr.Start_Date_Active(g_Agreement_rec.start_date_active)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_START_DATE_ACTIVE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.term_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.term_id := Get_Term;

        IF g_Agreement_rec.term_id IS NOT NULL THEN

            IF OE_Validate_Attr.Term(g_Agreement_rec.term_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_TERM
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.term_id := NULL;
            END IF;

        END IF;

    END IF;

    --Begin code added by rchellam for OKC
    IF g_Agreement_rec.agreement_source_code = FND_API.G_MISS_CHAR THEN

        g_Agreement_rec.agreement_source_code := Get_Agreement_Source;

        IF g_Agreement_rec.agreement_source_code IS NOT NULL THEN

            IF OE_Validate_Attr.Agreement_Source(g_Agreement_rec.agreement_source_code)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_AGREEMENT_SOURCE
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.agreement_source_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Agreement_rec.orig_system_agr_id = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.orig_system_agr_id := Get_Orig_System_Agr;

        IF g_Agreement_rec.orig_system_agr_id IS NOT NULL THEN

            IF OE_Validate_Attr.Orig_System_Agr(g_Agreement_rec.orig_system_agr_id)
            THEN

	        l_Agreement_rec := g_Agreement_rec; --[prarasto]

                OE_Agreement_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Agreement_Util.G_ORIG_SYSTEM_AGR
                ,   p_Agreement_rec               => l_Agreement_rec
                ,   x_Agreement_rec               => g_Agreement_rec
                );
            ELSE
                g_Agreement_rec.orig_system_agr_id := NULL;
            END IF;

        END IF;

    END IF;
    --End code added by rchellam for OKC

    IF g_Agreement_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Agreement;

    END IF;

    IF g_Agreement_rec.created_by = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.created_by := NULL;

    END IF;

    IF g_Agreement_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_Agreement_rec.creation_date := NULL;

    END IF;

    IF g_Agreement_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.last_updated_by := NULL;

    END IF;

    IF g_Agreement_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_Agreement_rec.last_update_date := NULL;

    END IF;

    IF g_Agreement_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_Agreement_rec.last_update_login := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_Agreement_rec.accounting_rule_id = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.agreement_contact_id = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.agreement_id = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.agreement_num = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.agreement_type_code = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.context = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.created_by = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.creation_date = FND_API.G_MISS_DATE
/*    OR  g_Agreement_rec.customer_id = FND_API.G_MISS_NUM */
    OR  g_Agreement_rec.sold_to_org_id = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_Agreement_rec.freight_terms_code = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.invoice_contact_id = FND_API.G_MISS_NUM
 /*   OR  g_Agreement_rec.invoice_to_site_use_id = FND_API.G_MISS_NUM */
    OR  g_Agreement_rec.invoice_to_org_id = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.invoicing_rule_id = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_Agreement_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.name = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.override_arule_flag = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.override_irule_flag = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.price_list_id = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.purchase_order_num = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.revision = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.revision_date = FND_API.G_MISS_DATE
    OR  g_Agreement_rec.revision_reason_code = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.salesrep_id = FND_API.G_MISS_NUM
    OR  g_Agreement_rec.ship_method_code = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.signature_date = FND_API.G_MISS_DATE
    OR  g_Agreement_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_Agreement_rec.term_id = FND_API.G_MISS_NUM
    --begin code  added by rchellam for OKC
    OR  g_Agreement_rec.agreement_source_code = FND_API.G_MISS_CHAR
    OR  g_Agreement_rec.orig_system_agr_id = FND_API.G_MISS_NUM
    --end code  added by rchellam for OKC
    THEN

        OE_Default_Agreement.Attributes
        (   p_Agreement_rec               => g_Agreement_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_Agreement_rec               => x_Agreement_rec
        );

    ELSE

        --  Done defaulting attributes

        x_Agreement_rec := g_Agreement_rec;

    END IF;

    oe_debug_pub.add('Exiting OE_Default_Agreement.Attributes');

END Attributes;

END OE_Default_Agreement;

/
