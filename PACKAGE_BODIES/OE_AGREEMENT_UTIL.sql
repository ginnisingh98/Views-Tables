--------------------------------------------------------
--  DDL for Package Body OE_AGREEMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_AGREEMENT_UTIL" AS
/* $Header: OEXUAGRB.pls 120.2 2005/12/14 16:17:38 shulin noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Agreement_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN            NUMBER := FND_API.G_MISS_NUM
,   p_Agreement_rec                 IN            OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN            OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                                  OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
)
IS
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Clear_Dependent_Attr');

    --  Load out record

    x_Agreement_rec := p_Agreement_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.accounting_rule_id,p_old_Agreement_rec.accounting_rule_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_contact_id,p_old_Agreement_rec.agreement_contact_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_id,p_old_Agreement_rec.agreement_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_num,p_old_Agreement_rec.agreement_num)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_type_code,p_old_Agreement_rec.agreement_type_code)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute1,p_old_Agreement_rec.attribute1)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute10,p_old_Agreement_rec.attribute10)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute11,p_old_Agreement_rec.attribute11)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute12,p_old_Agreement_rec.attribute12)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute13,p_old_Agreement_rec.attribute13)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute14,p_old_Agreement_rec.attribute14)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute15,p_old_Agreement_rec.attribute15)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute2,p_old_Agreement_rec.attribute2)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute3,p_old_Agreement_rec.attribute3)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute4,p_old_Agreement_rec.attribute4)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute5,p_old_Agreement_rec.attribute5)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute6,p_old_Agreement_rec.attribute6)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute7,p_old_Agreement_rec.attribute7)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute8,p_old_Agreement_rec.attribute8)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute9,p_old_Agreement_rec.attribute9)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.context,p_old_Agreement_rec.context)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.created_by,p_old_Agreement_rec.created_by)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.creation_date,p_old_Agreement_rec.creation_date)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.sold_to_org_id,p_old_Agreement_rec.sold_to_org_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.end_date_active,p_old_Agreement_rec.end_date_active)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.freight_terms_code,p_old_Agreement_rec.freight_terms_code)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.invoice_contact_id,p_old_Agreement_rec.invoice_contact_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.invoice_to_org_id,p_old_Agreement_rec.invoice_to_org_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.invoicing_rule_id,p_old_Agreement_rec.invoicing_rule_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.last_updated_by,p_old_Agreement_rec.last_updated_by)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.last_update_date,p_old_Agreement_rec.last_update_date)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.last_update_login,p_old_Agreement_rec.last_update_login)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.name,p_old_Agreement_rec.name)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.override_arule_flag,p_old_Agreement_rec.override_arule_flag)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.override_irule_flag,p_old_Agreement_rec.override_irule_flag)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.price_list_id,p_old_Agreement_rec.price_list_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.purchase_order_num,p_old_Agreement_rec.purchase_order_num)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.revision,p_old_Agreement_rec.revision)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.revision_date,p_old_Agreement_rec.revision_date)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.revision_reason_code,p_old_Agreement_rec.revision_reason_code)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.salesrep_id,p_old_Agreement_rec.salesrep_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.ship_method_code,p_old_Agreement_rec.ship_method_code)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.signature_date,p_old_Agreement_rec.signature_date)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.start_date_active,p_old_Agreement_rec.start_date_active)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.term_id,p_old_Agreement_rec.term_id)
        THEN
            NULL;
        END IF;

        --Begin code added by rchellam for OKC
        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_source_code,p_old_Agreement_rec.agreement_source_code)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.orig_system_agr_id,p_old_Agreement_rec.orig_system_agr_id)
        THEN
            NULL;
        END IF;
        --End code added by rchellam for OKC

        -- Added for bug#4029589
        IF NOT OE_GLOBALS.Equal(p_Agreement_rec.invoice_to_customer_id,p_old_Agreement_rec.invoice_to_customer_id)
        THEN
            NULL;
        END IF;

    ELSIF p_attr_id = G_ACCOUNTING_RULE THEN
        NULL;
    ELSIF p_attr_id = G_AGREEMENT_CONTACT THEN
        NULL;
    ELSIF p_attr_id = G_AGREEMENT THEN
        NULL;
    ELSIF p_attr_id = G_AGREEMENT_NUM THEN
        NULL;
    ELSIF p_attr_id = G_AGREEMENT_TYPE THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        NULL;
    ELSIF p_attr_id = G_CONTEXT THEN
        NULL;
    ELSIF p_attr_id = G_CREATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        NULL;
    ELSIF p_attr_id = G_CUSTOMER THEN
        NULL;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        NULL;
    ELSIF p_attr_id = G_FREIGHT_TERMS THEN
        NULL;
    ELSIF p_attr_id = G_INVOICE_CONTACT THEN
        NULL;
    ELSIF p_attr_id = G_INVOICE_TO_SITE_USE THEN
        NULL;
    ELSIF p_attr_id = G_INVOICING_RULE THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        NULL;
    ELSIF p_attr_id = G_NAME THEN
        NULL;
    ELSIF p_attr_id = G_OVERRIDE_ARULE THEN
        NULL;
    ELSIF p_attr_id = G_OVERRIDE_IRULE THEN
        NULL;
    ELSIF p_attr_id = G_PRICE_LIST THEN
        NULL;
    ELSIF p_attr_id = G_PURCHASE_ORDER_NUM THEN
        NULL;
    ELSIF p_attr_id = G_REVISION THEN
        NULL;
    ELSIF p_attr_id = G_REVISION_DATE THEN
        NULL;
    ELSIF p_attr_id = G_REVISION_REASON THEN
        NULL;
    ELSIF p_attr_id = G_SALESREP THEN
        NULL;
    ELSIF p_attr_id = G_SHIP_METHOD THEN
        NULL;
    ELSIF p_attr_id = G_SIGNATURE_DATE THEN
        NULL;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        NULL;
    ELSIF p_attr_id = G_TERM THEN
        NULL;
    --Begin code added by rchellam for OKC
    ELSIF p_attr_id = G_AGREEMENT_SOURCE THEN
        NULL;
    ELSIF p_attr_id = G_ORIG_SYSTEM_AGR THEN
        NULL;
    --End code added by rchellam for OKC
    ELSIF p_attr_id = G_INVOICE_TO_CUSTOMER_ID THEN -- Added for bug#4029589
        NULL;
    END IF;

    oe_debug_pub.add('Exiting OE_Agreement_Util.Clear_Dependent_Attr');

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Agreement_rec                 IN            OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN            OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                                  OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
)
IS
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Apply_Attribute_Changes');

    --  Load out record

    x_Agreement_rec := p_Agreement_rec;

    -- Performance-related change
    IF p_Agreement_rec.sold_to_org_id IS NULL OR
	  p_Agreement_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
	 x_Agreement_rec.sold_to_org_id := -1;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.accounting_rule_id,p_old_Agreement_rec.accounting_rule_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_contact_id,p_old_Agreement_rec.agreement_contact_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_id,p_old_Agreement_rec.agreement_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_num,p_old_Agreement_rec.agreement_num)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_type_code,p_old_Agreement_rec.agreement_type_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute1,p_old_Agreement_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute10,p_old_Agreement_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute11,p_old_Agreement_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute12,p_old_Agreement_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute13,p_old_Agreement_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute14,p_old_Agreement_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute15,p_old_Agreement_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute2,p_old_Agreement_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute3,p_old_Agreement_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute4,p_old_Agreement_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute5,p_old_Agreement_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute6,p_old_Agreement_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute7,p_old_Agreement_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute8,p_old_Agreement_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.attribute9,p_old_Agreement_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.context,p_old_Agreement_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.created_by,p_old_Agreement_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.creation_date,p_old_Agreement_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.sold_to_org_id,p_old_Agreement_rec.sold_to_org_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.end_date_active,p_old_Agreement_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.freight_terms_code,p_old_Agreement_rec.freight_terms_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.invoice_contact_id,p_old_Agreement_rec.invoice_contact_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.invoice_to_org_id,p_old_Agreement_rec.invoice_to_org_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.invoicing_rule_id,p_old_Agreement_rec.invoicing_rule_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.last_updated_by,p_old_Agreement_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.last_update_date,p_old_Agreement_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.last_update_login,p_old_Agreement_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.name,p_old_Agreement_rec.name)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.override_arule_flag,p_old_Agreement_rec.override_arule_flag)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.override_irule_flag,p_old_Agreement_rec.override_irule_flag)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.price_list_id,p_old_Agreement_rec.price_list_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.purchase_order_num,p_old_Agreement_rec.purchase_order_num)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.revision,p_old_Agreement_rec.revision)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.revision_date,p_old_Agreement_rec.revision_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.revision_reason_code,p_old_Agreement_rec.revision_reason_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.salesrep_id,p_old_Agreement_rec.salesrep_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.ship_method_code,p_old_Agreement_rec.ship_method_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.signature_date,p_old_Agreement_rec.signature_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.start_date_active,p_old_Agreement_rec.start_date_active)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.term_id,p_old_Agreement_rec.term_id)
    THEN
        NULL;
    END IF;

    --Begin code added by rchellam for OKC
    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_source_code,p_old_Agreement_rec.agreement_source_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.orig_system_agr_id,p_old_Agreement_rec.orig_system_agr_id)
    THEN
        NULL;
    END IF;
    --End code added by rchellam for OKC

    -- Added for bug#4029589
    IF NOT OE_GLOBALS.Equal(p_Agreement_rec.invoice_to_customer_id,p_old_Agreement_rec.invoice_to_customer_id)
    THEN
        NULL;
    END IF;
    oe_debug_pub.add('Exiting OE_Agreement_Util.Apply_Attribute_Changes');

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type
IS
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type := p_Agreement_rec;
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Complete_Record');

    IF l_Agreement_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.accounting_rule_id := p_old_Agreement_rec.accounting_rule_id;
    END IF;

    IF l_Agreement_rec.agreement_contact_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.agreement_contact_id := p_old_Agreement_rec.agreement_contact_id;
    END IF;

    IF l_Agreement_rec.agreement_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.agreement_id := p_old_Agreement_rec.agreement_id;
    END IF;

    IF l_Agreement_rec.agreement_num = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.agreement_num := p_old_Agreement_rec.agreement_num;
    END IF;

    IF l_Agreement_rec.agreement_type_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.agreement_type_code := p_old_Agreement_rec.agreement_type_code;
    END IF;

    IF l_Agreement_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute1 := p_old_Agreement_rec.attribute1;
    END IF;

    IF l_Agreement_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute10 := p_old_Agreement_rec.attribute10;
    END IF;

    IF l_Agreement_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute11 := p_old_Agreement_rec.attribute11;
    END IF;

    IF l_Agreement_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute12 := p_old_Agreement_rec.attribute12;
    END IF;

    IF l_Agreement_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute13 := p_old_Agreement_rec.attribute13;
    END IF;

    IF l_Agreement_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute14 := p_old_Agreement_rec.attribute14;
    END IF;

    IF l_Agreement_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute15 := p_old_Agreement_rec.attribute15;
    END IF;

    IF l_Agreement_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute2 := p_old_Agreement_rec.attribute2;
    END IF;

    IF l_Agreement_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute3 := p_old_Agreement_rec.attribute3;
    END IF;

    IF l_Agreement_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute4 := p_old_Agreement_rec.attribute4;
    END IF;

    IF l_Agreement_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute5 := p_old_Agreement_rec.attribute5;
    END IF;

    IF l_Agreement_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute6 := p_old_Agreement_rec.attribute6;
    END IF;

    IF l_Agreement_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute7 := p_old_Agreement_rec.attribute7;
    END IF;

    IF l_Agreement_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute8 := p_old_Agreement_rec.attribute8;
    END IF;

    IF l_Agreement_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute9 := p_old_Agreement_rec.attribute9;
    END IF;

    IF l_Agreement_rec.context = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.context := p_old_Agreement_rec.context;
    END IF;

    IF l_Agreement_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.created_by := p_old_Agreement_rec.created_by;
    END IF;

    IF l_Agreement_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.creation_date := p_old_Agreement_rec.creation_date;
    END IF;

    IF l_Agreement_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.sold_to_org_id := p_old_Agreement_rec.sold_to_org_id;
    END IF;

    IF l_Agreement_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.end_date_active := p_old_Agreement_rec.end_date_active;
    END IF;

    IF l_Agreement_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.freight_terms_code := p_old_Agreement_rec.freight_terms_code;
    END IF;

    IF l_Agreement_rec.invoice_contact_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.invoice_contact_id := p_old_Agreement_rec.invoice_contact_id;
    END IF;

    IF l_Agreement_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.invoice_to_org_id := p_old_Agreement_rec.invoice_to_org_id;
    END IF;

    IF l_Agreement_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.invoicing_rule_id := p_old_Agreement_rec.invoicing_rule_id;
    END IF;

    IF l_Agreement_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.last_updated_by := p_old_Agreement_rec.last_updated_by;
    END IF;

    IF l_Agreement_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.last_update_date := p_old_Agreement_rec.last_update_date;
    END IF;

    IF l_Agreement_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.last_update_login := p_old_Agreement_rec.last_update_login;
    END IF;

    IF l_Agreement_rec.name = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.name := p_old_Agreement_rec.name;
    END IF;

    IF l_Agreement_rec.override_arule_flag = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.override_arule_flag := p_old_Agreement_rec.override_arule_flag;
    END IF;

    IF l_Agreement_rec.override_irule_flag = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.override_irule_flag := p_old_Agreement_rec.override_irule_flag;
    END IF;

    IF l_Agreement_rec.price_list_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.price_list_id := p_old_Agreement_rec.price_list_id;
    END IF;

    IF l_Agreement_rec.purchase_order_num = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.purchase_order_num := p_old_Agreement_rec.purchase_order_num;
    END IF;

    IF l_Agreement_rec.revision = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.revision := p_old_Agreement_rec.revision;
    END IF;

    IF l_Agreement_rec.revision_date = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.revision_date := p_old_Agreement_rec.revision_date;
    END IF;

    IF l_Agreement_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.revision_reason_code := p_old_Agreement_rec.revision_reason_code;
    END IF;

    IF l_Agreement_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.salesrep_id := p_old_Agreement_rec.salesrep_id;
    END IF;

    IF l_Agreement_rec.ship_method_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.ship_method_code := p_old_Agreement_rec.ship_method_code;
    END IF;

    IF l_Agreement_rec.signature_date = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.signature_date := p_old_Agreement_rec.signature_date;
    END IF;

    IF l_Agreement_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.start_date_active := p_old_Agreement_rec.start_date_active;
    END IF;

    IF l_Agreement_rec.term_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.term_id := p_old_Agreement_rec.term_id;
    END IF;

    --Begin code added by rchellam for OKC
    IF l_Agreement_rec.agreement_source_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.agreement_source_code := p_old_Agreement_rec.agreement_source_code;
    END IF;

    IF l_Agreement_rec.orig_system_agr_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.orig_system_agr_id := p_old_Agreement_rec.orig_system_agr_id;
    END IF;
    --End code added by rchellam for OKC

    -- Added for bug#4029589
    IF l_Agreement_rec.invoice_to_customer_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.invoice_to_customer_id := p_old_Agreement_rec.invoice_to_customer_id;
    END IF;

    oe_debug_pub.add('Exiting OE_Agreement_Util.Complete_Record');

    RETURN l_Agreement_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type
IS
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type := p_Agreement_rec;
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Convert_Miss_To_Null');

    IF l_Agreement_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.accounting_rule_id := NULL;
    END IF;

    IF l_Agreement_rec.agreement_contact_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.agreement_contact_id := NULL;
    END IF;

    IF l_Agreement_rec.agreement_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.agreement_id := NULL;
    END IF;

    IF l_Agreement_rec.agreement_num = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.agreement_num := NULL;
    END IF;

    IF l_Agreement_rec.agreement_type_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.agreement_type_code := NULL;
    END IF;

    IF l_Agreement_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute1 := NULL;
    END IF;

    IF l_Agreement_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute10 := NULL;
    END IF;

    IF l_Agreement_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute11 := NULL;
    END IF;

    IF l_Agreement_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute12 := NULL;
    END IF;

    IF l_Agreement_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute13 := NULL;
    END IF;

    IF l_Agreement_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute14 := NULL;
    END IF;

    IF l_Agreement_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute15 := NULL;
    END IF;

    IF l_Agreement_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute2 := NULL;
    END IF;

    IF l_Agreement_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute3 := NULL;
    END IF;

    IF l_Agreement_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute4 := NULL;
    END IF;

    IF l_Agreement_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute5 := NULL;
    END IF;

    IF l_Agreement_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute6 := NULL;
    END IF;

    IF l_Agreement_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute7 := NULL;
    END IF;

    IF l_Agreement_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute8 := NULL;
    END IF;

    IF l_Agreement_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.attribute9 := NULL;
    END IF;

    IF l_Agreement_rec.context = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.context := NULL;
    END IF;

    IF l_Agreement_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.created_by := NULL;
    END IF;

    IF l_Agreement_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.creation_date := NULL;
    END IF;

    IF l_Agreement_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.sold_to_org_id := NULL;
    END IF;

    IF l_Agreement_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.end_date_active := NULL;
    END IF;

    IF l_Agreement_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.freight_terms_code := NULL;
    END IF;

    IF l_Agreement_rec.invoice_contact_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.invoice_contact_id := NULL;
    END IF;

    IF l_Agreement_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.invoice_to_org_id := NULL;
    END IF;

    IF l_Agreement_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.invoicing_rule_id := NULL;
    END IF;

    IF l_Agreement_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.last_updated_by := NULL;
    END IF;

    IF l_Agreement_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.last_update_date := NULL;
    END IF;

    IF l_Agreement_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.last_update_login := NULL;
    END IF;

    IF l_Agreement_rec.name = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.name := NULL;
    END IF;

    IF l_Agreement_rec.override_arule_flag = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.override_arule_flag := NULL;
    END IF;

    IF l_Agreement_rec.override_irule_flag = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.override_irule_flag := NULL;
    END IF;

    IF l_Agreement_rec.price_list_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.price_list_id := NULL;
    END IF;

    IF l_Agreement_rec.purchase_order_num = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.purchase_order_num := NULL;
    END IF;

    IF l_Agreement_rec.revision = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.revision := NULL;
    END IF;

    IF l_Agreement_rec.revision_date = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.revision_date := NULL;
    END IF;

    IF l_Agreement_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.revision_reason_code := NULL;
    END IF;

    IF l_Agreement_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.salesrep_id := NULL;
    END IF;

    IF l_Agreement_rec.ship_method_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.ship_method_code := NULL;
    END IF;

    IF l_Agreement_rec.signature_date = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.signature_date := NULL;
    END IF;

    IF l_Agreement_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_Agreement_rec.start_date_active := NULL;
    END IF;

    IF l_Agreement_rec.term_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.term_id := NULL;
    END IF;

    --Begin code added by rchellam for OKC
    IF l_Agreement_rec.agreement_source_code = FND_API.G_MISS_CHAR THEN
        l_Agreement_rec.agreement_source_code := NULL;
    END IF;

    IF l_Agreement_rec.orig_system_agr_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.orig_system_agr_id := NULL;
    END IF;
    --End code added by rchellam for OKC

    -- Added for bug#4029589
    IF l_Agreement_rec.invoice_to_customer_id = FND_API.G_MISS_NUM THEN
        l_Agreement_rec.invoice_to_customer_id := NULL;
    END IF;

    RETURN l_Agreement_rec;

    oe_debug_pub.add('Exiting OE_Agreement_Util.Convert_Miss_To_Null');

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
)
IS
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Update_Row');

  IF QP_security.check_function( p_function_name => QP_Security.G_FUNCTION_UPDATE,
                                 p_instance_type => QP_Security.G_AGREEMENT_OBJECT,
                                 p_instance_pk1  => p_Agreement_rec.price_list_id) <> 'F' THEN

    OE_AGREEMENTS_PKG.UPDATE_ROW (
           	p_Agreement_rec.agreement_id
		 ,	p_Agreement_rec.tp_attribute2
		 ,	p_Agreement_rec.tp_attribute3
		 ,	p_Agreement_rec.tp_attribute4
		 ,	p_Agreement_rec.tp_attribute5
		 ,	p_Agreement_rec.tp_attribute6
		 ,	p_Agreement_rec.tp_attribute7
		 ,	p_Agreement_rec.tp_attribute8
		 ,	p_Agreement_rec.tp_attribute9
		 ,	p_Agreement_rec.tp_attribute10
		 ,	p_Agreement_rec.tp_attribute11
		 ,	p_Agreement_rec.tp_attribute12
		 ,	p_Agreement_rec.tp_attribute13
		 ,	p_Agreement_rec.tp_attribute14
		 ,	p_Agreement_rec.tp_attribute15
		 ,	p_Agreement_rec.tp_attribute_category
		 ,	p_Agreement_rec.agreement_type_code
		 ,	p_Agreement_rec.price_list_id
		 ,	p_Agreement_rec.term_id
		 ,	p_agreement_rec.override_irule_flag
		 ,	p_Agreement_rec.override_arule_flag
		 ,	p_Agreement_rec.signature_date
		 ,	p_Agreement_rec.agreement_num
		 ,	p_Agreement_rec.tp_attribute1
		 ,	p_Agreement_rec.attribute12
		 ,	p_Agreement_rec.attribute13
		 ,	p_Agreement_rec.attribute14
		 ,	p_Agreement_rec.attribute15
		 ,	p_Agreement_rec.attribute11
		 ,	p_Agreement_rec.attribute9
		 ,	p_Agreement_rec.attribute10
		 ,	p_Agreement_rec.revision
		 ,	p_Agreement_rec.revision_date
		 ,	p_Agreement_rec.revision_reason_code
		 ,	p_Agreement_rec.freight_terms_code
		 ,	p_Agreement_rec.ship_method_code
		 ,	p_Agreement_rec.invoicing_rule_id
		 ,	p_Agreement_rec.accounting_rule_id
		 ,	p_Agreement_rec.sold_to_org_id
		 ,	p_Agreement_rec.purchase_order_num
		 ,	p_Agreement_rec.invoice_contact_id
		 ,	p_Agreement_rec.agreement_contact_id
		 ,	p_Agreement_rec.invoice_to_org_id
		 ,	p_Agreement_rec.salesrep_id
		 ,	p_Agreement_rec.start_date_active
		 ,	p_Agreement_rec.end_date_active
		 ,	p_Agreement_rec.comments
		 ,	p_Agreement_rec.context
		 ,	p_Agreement_rec.attribute1
		 ,	p_Agreement_rec.attribute2
		 ,	p_Agreement_rec.attribute3
		 ,	p_Agreement_rec.attribute4
		 ,	p_Agreement_rec.attribute5
		 ,	p_Agreement_rec.attribute6
		 ,	p_Agreement_rec.attribute7
		 ,	p_Agreement_rec.attribute8
		 ,	p_Agreement_rec.name
		 ,	p_Agreement_rec.last_update_date
		 ,	p_Agreement_rec.last_updated_by
		 ,	p_Agreement_rec.last_update_login
		 ,	p_Agreement_rec.agreement_source_code --added by
		 ,	p_Agreement_rec.orig_system_agr_id --rchellam for OKC
     ,	p_Agreement_rec.invoice_to_customer_id -- Added for bug#4029589
    );

  ELSE

    fnd_message.set_name('QP', 'QP_NO_PRIVILEGE');
    fnd_message.set_token('PRICING_OBJECT', 'Agreement');
    oe_msg_pub.Add;

  END IF;


/*
    UPDATE  OE_AGREEMENTS
    SET     ACCOUNTING_RULE_ID             = p_Agreement_rec.accounting_rule_id
    ,       AGREEMENT_CONTACT_ID           = p_Agreement_rec.agreement_contact_id
    ,       AGREEMENT_ID                   = p_Agreement_rec.agreement_id
    ,       AGREEMENT_NUM                  = p_Agreement_rec.agreement_num
    ,       AGREEMENT_TYPE_CODE            = p_Agreement_rec.agreement_type_code
    ,       ATTRIBUTE1                     = p_Agreement_rec.attribute1
    ,       ATTRIBUTE10                    = p_Agreement_rec.attribute10
    ,       ATTRIBUTE11                    = p_Agreement_rec.attribute11
    ,       ATTRIBUTE12                    = p_Agreement_rec.attribute12
    ,       ATTRIBUTE13                    = p_Agreement_rec.attribute13
    ,       ATTRIBUTE14                    = p_Agreement_rec.attribute14
    ,       ATTRIBUTE15                    = p_Agreement_rec.attribute15
    ,       ATTRIBUTE2                     = p_Agreement_rec.attribute2
    ,       ATTRIBUTE3                     = p_Agreement_rec.attribute3
    ,       ATTRIBUTE4                     = p_Agreement_rec.attribute4
    ,       ATTRIBUTE5                     = p_Agreement_rec.attribute5
    ,       ATTRIBUTE6                     = p_Agreement_rec.attribute6
    ,       ATTRIBUTE7                     = p_Agreement_rec.attribute7
    ,       ATTRIBUTE8                     = p_Agreement_rec.attribute8
    ,       ATTRIBUTE9                     = p_Agreement_rec.attribute9
    ,       CONTEXT                        = p_Agreement_rec.context
    ,       CREATED_BY                     = p_Agreement_rec.created_by
    ,       CREATION_DATE                  = p_Agreement_rec.creation_date
    ,       SOLD_TO_ORG_ID                    = p_Agreement_rec.sold_to_org_id
    ,       END_DATE_ACTIVE                = p_Agreement_rec.end_date_active
    ,       FREIGHT_TERMS_CODE             = p_Agreement_rec.freight_terms_code
    ,       INVOICE_CONTACT_ID             = p_Agreement_rec.invoice_contact_id
    ,       invoice_to_org_id         = p_Agreement_rec.invoice_to_org_id
    ,       INVOICING_RULE_ID              = p_Agreement_rec.invoicing_rule_id
    ,       LAST_UPDATED_BY                = p_Agreement_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_Agreement_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_Agreement_rec.last_update_login
    ,       NAME                           = p_Agreement_rec.name
    ,       OVERRIDE_ARULE_FLAG            = p_Agreement_rec.override_arule_flag
    ,       OVERRIDE_IRULE_FLAG            = p_Agreement_rec.override_irule_flag
    ,       PRICE_LIST_ID                  = p_Agreement_rec.price_list_id
    ,       PURCHASE_ORDER_NUM             = p_Agreement_rec.purchase_order_num
    ,       REVISION                       = p_Agreement_rec.revision
    ,       REVISION_DATE                  = p_Agreement_rec.revision_date
    ,       REVISION_REASON_CODE           = p_Agreement_rec.revision_reason_code
    ,       SALESREP_ID                    = p_Agreement_rec.salesrep_id
    ,       SHIP_METHOD_CODE               = p_Agreement_rec.ship_method_code
    ,       SIGNATURE_DATE                 = p_Agreement_rec.signature_date
    ,       START_DATE_ACTIVE              = p_Agreement_rec.start_date_active
    ,       TERM_ID                        = p_Agreement_rec.term_id
    WHERE   AGREEMENT_ID = p_Agreement_rec.agreement_id
    ;
*/
    oe_debug_pub.add('Exiting OE_Agreement_Util.Update_Row');

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
)
IS
x_row_id VARCHAR2(240);
x_result VARCHAR2(1);
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Insert_Row');
--

   OE_AGREEMENTS_PKG.INSERT_ROW ( x_row_id
    ,       p_Agreement_rec.agreement_id
    ,       p_Agreement_rec.tp_attribute2
    ,       p_Agreement_rec.tp_attribute3
    ,       p_Agreement_rec.tp_attribute4
    ,       p_Agreement_rec.tp_attribute5
    ,       p_Agreement_rec.tp_attribute6
    ,       p_Agreement_rec.tp_attribute7
    ,       p_Agreement_rec.tp_attribute8
    ,       p_Agreement_rec.tp_attribute9
    ,       p_Agreement_rec.tp_attribute10
    ,       p_Agreement_rec.tp_attribute11
    ,       p_Agreement_rec.tp_attribute12
    ,       p_Agreement_rec.tp_attribute13
    ,       p_Agreement_rec.tp_attribute14
    ,       p_Agreement_rec.tp_attribute15
    ,       p_Agreement_rec.tp_attribute_category
    ,       p_Agreement_rec.agreement_type_code
    ,       p_Agreement_rec.price_list_id
    ,       p_Agreement_rec.term_id
    ,       p_Agreement_rec.override_irule_flag
    ,       p_Agreement_rec.override_arule_flag
    ,       p_Agreement_rec.signature_date
    ,       p_Agreement_rec.agreement_num
    ,       p_Agreement_rec.tp_attribute1
    ,       p_Agreement_rec.attribute12
    ,       p_Agreement_rec.attribute13
    ,       p_Agreement_rec.attribute14
    ,       p_Agreement_rec.attribute15
    ,       p_Agreement_rec.attribute11
    ,       p_Agreement_rec.attribute9
    ,       p_Agreement_rec.attribute10
    ,       p_Agreement_rec.revision
    ,       p_Agreement_rec.revision_date
    ,       p_Agreement_rec.revision_reason_code
    ,       p_Agreement_rec.freight_terms_code
    ,       p_Agreement_rec.ship_method_code
    ,       p_Agreement_rec.invoicing_rule_id
    ,	    p_Agreement_rec.accounting_rule_id
    ,       p_Agreement_rec.sold_to_org_id
    ,       p_Agreement_rec.purchase_order_num
    ,       p_Agreement_rec.invoice_contact_id
    ,       p_Agreement_rec.agreement_contact_id
    ,       p_Agreement_rec.invoice_to_org_id
    ,       p_Agreement_rec.salesrep_id
    ,       p_Agreement_rec.start_date_active
    ,       p_Agreement_rec.end_date_active
    ,       p_Agreement_rec.comments
    ,       p_Agreement_rec.context
    ,       p_Agreement_rec.attribute1
    ,       p_Agreement_rec.attribute2
    ,       p_Agreement_rec.attribute3
    ,       p_Agreement_rec.attribute4
    ,       p_Agreement_rec.attribute5
    ,       p_Agreement_rec.attribute6
    ,       p_Agreement_rec.attribute7
    ,       p_Agreement_rec.attribute8
    ,       p_Agreement_rec.name
    ,       p_Agreement_rec.creation_date
    ,       p_Agreement_rec.created_by
    ,       p_Agreement_rec.last_update_date
    ,       p_Agreement_rec.last_updated_by
    ,       p_Agreement_rec.last_update_login
    ,       p_Agreement_rec.agreement_source_code --added by rchellam for OKC
    ,       p_Agreement_rec.orig_system_agr_id --added by rchellam for OKC
    ,	    p_Agreement_rec.invoice_to_customer_id -- Added for bug#4029589
    );


-- Code commented :: using new package
/*
    INSERT  INTO OE_AGREEMENTS
    (       ACCOUNTING_RULE_ID
    ,       AGREEMENT_CONTACT_ID
    ,       AGREEMENT_ID
    ,       AGREEMENT_NUM
    ,       AGREEMENT_TYPE_CODE
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       SOLD_TO_ORG_ID
    ,       END_DATE_ACTIVE
    ,       FREIGHT_TERMS_CODE
    ,       INVOICE_CONTACT_ID
    ,       invoice_to_org_id
    ,       INVOICING_RULE_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NAME
    ,       OVERRIDE_ARULE_FLAG
    ,       OVERRIDE_IRULE_FLAG
    ,       PRICE_LIST_ID
    ,       PURCHASE_ORDER_NUM
    ,       REVISION
    ,       REVISION_DATE
    ,       REVISION_REASON_CODE
    ,       SALESREP_ID
    ,       SHIP_METHOD_CODE
    ,       SIGNATURE_DATE
    ,       START_DATE_ACTIVE
    ,       TERM_ID
    )
    VALUES
    (       p_Agreement_rec.accounting_rule_id
    ,       p_Agreement_rec.agreement_contact_id
    ,       p_Agreement_rec.agreement_id
    ,       p_Agreement_rec.agreement_num
    ,       p_Agreement_rec.agreement_type_code
    ,       p_Agreement_rec.attribute1
    ,       p_Agreement_rec.attribute10
    ,       p_Agreement_rec.attribute11
    ,       p_Agreement_rec.attribute12
    ,       p_Agreement_rec.attribute13
    ,       p_Agreement_rec.attribute14
    ,       p_Agreement_rec.attribute15
    ,       p_Agreement_rec.attribute2
    ,       p_Agreement_rec.attribute3
    ,       p_Agreement_rec.attribute4
    ,       p_Agreement_rec.attribute5
    ,       p_Agreement_rec.attribute6
    ,       p_Agreement_rec.attribute7
    ,       p_Agreement_rec.attribute8
    ,       p_Agreement_rec.attribute9
    ,       p_Agreement_rec.context
    ,       p_Agreement_rec.created_by
    ,       p_Agreement_rec.creation_date
    ,       p_Agreement_rec.sold_to_org_id
    ,       p_Agreement_rec.end_date_active
    ,       p_Agreement_rec.freight_terms_code
    ,       p_Agreement_rec.invoice_contact_id
    ,       p_Agreement_rec.invoice_to_org_id
    ,       p_Agreement_rec.invoicing_rule_id
    ,       p_Agreement_rec.last_updated_by
    ,       p_Agreement_rec.last_update_date
    ,       p_Agreement_rec.last_update_login
    ,       p_Agreement_rec.name
    ,       p_Agreement_rec.override_arule_flag
    ,       p_Agreement_rec.override_irule_flag
    ,       p_Agreement_rec.price_list_id
    ,       p_Agreement_rec.purchase_order_num
    ,       p_Agreement_rec.revision
    ,       p_Agreement_rec.revision_date
    ,       p_Agreement_rec.revision_reason_code
    ,       p_Agreement_rec.salesrep_id
    ,       p_Agreement_rec.ship_method_code
    ,       p_Agreement_rec.signature_date
    ,       p_Agreement_rec.start_date_active
    ,       p_Agreement_rec.term_id
    );
*/

    oe_debug_pub.add('Entering OE_Agreement_Util.Insert_Row');

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(
    x_return_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id                  IN  NUMBER
,   p_Price_List_Exists_Flag        IN  BOOLEAN
,   p_Agreement_Delete_Flag         IN BOOLEAN
,   p_Agreement_Lines_Delete_Flag         IN BOOLEAN
)
IS
  l_Price_List_id NUMBER;
  l_list_type_code varchar2(10);
  CURSOR get_line_id( p_Price_List_id NUMBER )  is
		SELECT list_line_id
		FROM QP_LIST_LINES
		WHERE LIST_HEADER_ID = p_Price_List_id;


BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Delete_Row');
/*    IF (p_Price_List_Exists_Flag) THEN
      oe_debug_pub.add('p_Price_List_Exists_Flag :');

    --oe_debug_pub.add('p_Price_List_Exists_Flag :'||to_char(p_Price_List_Exists_Flag));
    End If;
    If (p_Agreement_Delete_Flag) Then
    oe_debug_pub.add('p_Agreement_Delete_Flag :');

-- oe_debug_pub.add('p_Agreement_Delete_Flag :'|| to_char(p_Agreement_Delete_Flag));
   End If;

     If (p_Agreement_Lines_Delete_Flag) Then
     oe_debug_pub.add('p_Agreement_Lines_Delete_Flag :');
     End If;
*/
--     oe_debug_pub.add('p_Agreement_Lines_Delete_Flag :'||to_char(p_Agreement_Lines_Delete_Flag));
-- Added for 2321498
   SELECT price_list_id, q.list_type_code into
        l_Price_List_id, l_list_type_code
        from oe_agreements_b, qp_list_headers q
        where agreement_id = p_agreement_id And
              price_list_id = q.list_header_id;



-- Commented the following code as price List shouldn't be deleted as per Bug2321498

/*
    if ( p_Price_List_Exists_Flag ) then

 	 If this flag is TRUE then Delete Price List

     SELECT price_list_id into
	l_Price_List_id
	from oe_agreements_b
	where agreement_id = p_agreement_id;

     if l_Price_List_id is NOT NULL THEN

	 Deletes the Price List Header

		 oe_debug_pub.add(' OE_Agreement_Util: Deleting price list for the Agreement');
     	QP_Price_List_Util.Delete_Row( l_Price_List_id );
*/

	/* Delete from qp_qualifiers table */
/* This code has been moved so that qualifier should be deleted only
  if Agreement is deleted. Bug 2321498

		DELETE FROM QP_QUALIFIERS
		where list_header_id = l_Price_List_id
		and qualifier_attr_value = p_agreement_id;

	end if;

	end if;

*/
 -- Delete Agreement only when the agreement is not associated with
 -- an order or order line

	if  ( p_Agreement_Delete_Flag  ) and
	    ( p_Agreement_Lines_Delete_Flag) then

               -- Bug 2321498: delete qualifier
                     Begin
                           If l_list_type_code = 'AGR' Then
                              DELETE FROM QP_QUALIFIERS
                            where list_header_id = l_Price_List_id
                            and qualifier_attr_value = p_agreement_id;
                           End If;
                           Exception
                             When No_data_Found Then
                            oe_debug_pub.add('No Qualifiers found',4);
                      End;

		oe_dEbug_pub.add('Deleting Agreement because agreement is not associated with an order or order line');

   			OE_AGREEMENTS_PKG.DELETE_ROW( p_agreement_id );
                  x_return_status                := FND_API.G_RET_STS_SUCCESS;
	else
		oe_debug_pub.add('Did not delete agreement');
                 x_return_status                := FND_API.G_RET_STS_ERROR;
	 IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.SET_NAME('QP','QP_AGREEMENT_DELETE');
		oe_msg_pub.Add;
   --             x_return_status                := FND_API.G_RET_STS_ERROR;
              --  RAISE FND_API.G_EXC_ERROR;
                  /* Bug 2321498 */
	 END IF;

	end if;


    oe_debug_pub.add('Exiting OE_Agreement_Util.Delete_Row');

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
	WHEN no_data_found then
		NULL;
     WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_agreement_id                  IN  NUMBER
) RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type
IS
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Query_Row');

    RETURN Query_Rows
        (   p_agreement_id                => p_agreement_id
        )(1);

    oe_debug_pub.add('Exiting OE_Agreement_Util.Query_Row');

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_agreement_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_pricing_contract_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN OE_Pricing_Cont_PUB.Agreement_Tbl_Type
IS
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_Agreement_tbl               OE_Pricing_Cont_PUB.Agreement_Tbl_Type;

CURSOR l_Agreement_csr IS
    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_CONTACT_ID
    ,       AGREEMENT_ID
    ,       AGREEMENT_NUM
    ,       AGREEMENT_TYPE_CODE
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       sold_to_org_id
    ,       END_DATE_ACTIVE
    ,       FREIGHT_TERMS_CODE
    ,       INVOICE_CONTACT_ID
    ,       invoice_to_org_id
    ,       INVOICING_RULE_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NAME
    ,       OVERRIDE_ARULE_FLAG
    ,       OVERRIDE_IRULE_FLAG
    ,       PRICE_LIST_ID
    ,       PURCHASE_ORDER_NUM
    ,       REVISION
    ,       REVISION_DATE
    ,       REVISION_REASON_CODE
    ,       SALESREP_ID
    ,       SHIP_METHOD_CODE
    ,       SIGNATURE_DATE
    ,       START_DATE_ACTIVE
    ,       TERM_ID
    ,       AGREEMENT_SOURCE_CODE
    ,       ORIG_SYSTEM_AGR_ID
    ,       INVOICE_TO_CUSTOMER_ID -- Added for bug#4029589
    FROM    OE_AGREEMENTS
    WHERE ( AGREEMENT_ID = p_agreement_id
    )
    ;

BEGIN

    IF
    (p_agreement_id IS NOT NULL
     AND
     p_agreement_id <> FND_API.G_MISS_NUM)
    AND
    (p_pricing_contract_id IS NOT NULL
     AND
     p_pricing_contract_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: agreement_id = '|| p_agreement_id || ', pricing_contract_id = '|| p_pricing_contract_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_Agreement_csr LOOP

        l_Agreement_rec.accounting_rule_id := l_implicit_rec.ACCOUNTING_RULE_ID;
        l_Agreement_rec.agreement_contact_id := l_implicit_rec.AGREEMENT_CONTACT_ID;
        l_Agreement_rec.agreement_id   := l_implicit_rec.AGREEMENT_ID;
        l_Agreement_rec.agreement_num  := l_implicit_rec.AGREEMENT_NUM;
        l_Agreement_rec.agreement_type_code := l_implicit_rec.AGREEMENT_TYPE_CODE;
        l_Agreement_rec.attribute1     := l_implicit_rec.ATTRIBUTE1;
        l_Agreement_rec.attribute10    := l_implicit_rec.ATTRIBUTE10;
        l_Agreement_rec.attribute11    := l_implicit_rec.ATTRIBUTE11;
        l_Agreement_rec.attribute12    := l_implicit_rec.ATTRIBUTE12;
        l_Agreement_rec.attribute13    := l_implicit_rec.ATTRIBUTE13;
        l_Agreement_rec.attribute14    := l_implicit_rec.ATTRIBUTE14;
        l_Agreement_rec.attribute15    := l_implicit_rec.ATTRIBUTE15;
        l_Agreement_rec.attribute2     := l_implicit_rec.ATTRIBUTE2;
        l_Agreement_rec.attribute3     := l_implicit_rec.ATTRIBUTE3;
        l_Agreement_rec.attribute4     := l_implicit_rec.ATTRIBUTE4;
        l_Agreement_rec.attribute5     := l_implicit_rec.ATTRIBUTE5;
        l_Agreement_rec.attribute6     := l_implicit_rec.ATTRIBUTE6;
        l_Agreement_rec.attribute7     := l_implicit_rec.ATTRIBUTE7;
        l_Agreement_rec.attribute8     := l_implicit_rec.ATTRIBUTE8;
        l_Agreement_rec.attribute9     := l_implicit_rec.ATTRIBUTE9;
        l_Agreement_rec.context        := l_implicit_rec.CONTEXT;
        l_Agreement_rec.created_by     := l_implicit_rec.CREATED_BY;
        l_Agreement_rec.creation_date  := l_implicit_rec.CREATION_DATE;
        l_Agreement_rec.sold_to_org_id    := l_implicit_rec.SOLD_TO_ORG_ID;
        l_Agreement_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_Agreement_rec.freight_terms_code := l_implicit_rec.FREIGHT_TERMS_CODE;
        l_Agreement_rec.invoice_contact_id := l_implicit_rec.INVOICE_CONTACT_ID;
        l_Agreement_rec.invoice_to_org_id := l_implicit_rec.invoice_to_org_id;
        l_Agreement_rec.invoicing_rule_id := l_implicit_rec.INVOICING_RULE_ID;
        l_Agreement_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_Agreement_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_Agreement_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_Agreement_rec.name           := l_implicit_rec.NAME;
        l_Agreement_rec.override_arule_flag := l_implicit_rec.OVERRIDE_ARULE_FLAG;
        l_Agreement_rec.override_irule_flag := l_implicit_rec.OVERRIDE_IRULE_FLAG;
        l_Agreement_rec.price_list_id  := l_implicit_rec.PRICE_LIST_ID;
        l_Agreement_rec.purchase_order_num := l_implicit_rec.PURCHASE_ORDER_NUM;
        l_Agreement_rec.revision       := l_implicit_rec.REVISION;
        l_Agreement_rec.revision_date  := l_implicit_rec.REVISION_DATE;
        l_Agreement_rec.revision_reason_code := l_implicit_rec.REVISION_REASON_CODE;
        l_Agreement_rec.salesrep_id    := l_implicit_rec.SALESREP_ID;
        l_Agreement_rec.ship_method_code := l_implicit_rec.SHIP_METHOD_CODE;
        l_Agreement_rec.signature_date := l_implicit_rec.SIGNATURE_DATE;
        l_Agreement_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_Agreement_rec.term_id        := l_implicit_rec.TERM_ID;
        --Begin code added by rchellam for OKC
        l_Agreement_rec.agreement_source_code := l_implicit_rec.AGREEMENT_SOURCE_CODE;
        l_Agreement_rec.orig_system_agr_id := l_implicit_rec.ORIG_SYSTEM_AGR_ID;
        --End code added by rchellam for OKC

	-- Added for bug#4029589
        l_Agreement_rec.invoice_to_customer_id := l_implicit_rec.INVOICE_TO_CUSTOMER_ID;

        l_Agreement_tbl(l_Agreement_tbl.COUNT + 1) := l_Agreement_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_agreement_id IS NOT NULL
     AND
     p_agreement_id <> FND_API.G_MISS_NUM)
    AND
    (l_Agreement_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_Agreement_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec              IN            OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_Agreement_rec              OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
)
IS
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Lock_Row');

    OE_AGREEMENTS_PKG.UPDATE_ROW (
           	p_Agreement_rec.agreement_id
		 ,	p_Agreement_rec.tp_attribute2
		 ,	p_Agreement_rec.tp_attribute3
		 ,	p_Agreement_rec.tp_attribute4
		 ,	p_Agreement_rec.tp_attribute5
		 ,	p_Agreement_rec.tp_attribute6
		 ,	p_Agreement_rec.tp_attribute7
		 ,	p_Agreement_rec.tp_attribute8
		 ,	p_Agreement_rec.tp_attribute9
		 ,	p_Agreement_rec.tp_attribute10
		 ,	p_Agreement_rec.tp_attribute11
		 ,	p_Agreement_rec.tp_attribute12
		 ,	p_Agreement_rec.tp_attribute13
		 ,	p_Agreement_rec.tp_attribute14
		 ,	p_Agreement_rec.tp_attribute15
		 ,	p_Agreement_rec.tp_attribute_category
		 ,	p_Agreement_rec.agreement_type_code
		 ,	p_Agreement_rec.price_list_id
		 ,	p_Agreement_rec.term_id
		 ,	p_agreement_rec.override_irule_flag
		 ,	p_Agreement_rec.override_arule_flag
		 ,	p_Agreement_rec.signature_date
		 ,	p_Agreement_rec.agreement_num
		 ,	p_Agreement_rec.tp_attribute1
		 ,	p_Agreement_rec.attribute12
		 ,	p_Agreement_rec.attribute13
		 ,	p_Agreement_rec.attribute14
		 ,	p_Agreement_rec.attribute15
		 ,	p_Agreement_rec.attribute11
		 ,	p_Agreement_rec.attribute9
		 ,	p_Agreement_rec.attribute10
		 ,	p_Agreement_rec.revision
		 ,	p_Agreement_rec.revision_date
		 ,	p_Agreement_rec.revision_reason_code
		 ,	p_Agreement_rec.freight_terms_code
		 ,	p_Agreement_rec.ship_method_code
		 ,	p_Agreement_rec.invoicing_rule_id
		 ,	p_Agreement_rec.accounting_rule_id
		 ,	p_Agreement_rec.sold_to_org_id
		 ,	p_Agreement_rec.purchase_order_num
		 ,	p_Agreement_rec.invoice_contact_id
		 ,	p_Agreement_rec.agreement_contact_id
		 ,	p_Agreement_rec.invoice_to_org_id
		 ,	p_Agreement_rec.salesrep_id
		 ,	p_Agreement_rec.start_date_active
		 ,	p_Agreement_rec.end_date_active
		 ,	p_Agreement_rec.comments
		 ,	p_Agreement_rec.context
		 ,	p_Agreement_rec.attribute1
		 ,	p_Agreement_rec.attribute2
		 ,	p_Agreement_rec.attribute3
		 ,	p_Agreement_rec.attribute4
		 ,	p_Agreement_rec.attribute5
		 ,	p_Agreement_rec.attribute6
		 ,	p_Agreement_rec.attribute7
		 ,	p_Agreement_rec.attribute8
		 ,	p_Agreement_rec.name
		 ,	p_Agreement_rec.last_update_date
		 ,	p_Agreement_rec.last_updated_by
		 ,	p_Agreement_rec.last_update_login
		 ,	p_Agreement_rec.agreement_source_code --added by
		 ,	p_Agreement_rec.orig_system_agr_id --rchellam for OKC
		 ,	p_Agreement_rec.invoice_to_customer_id -- Added for bug#4029589
    );

-- below code commented
/*
    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_CONTACT_ID
    ,       AGREEMENT_ID
    ,       AGREEMENT_NUM
    ,       AGREEMENT_TYPE_CODE
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       sold_to_org_id
    ,       END_DATE_ACTIVE
    ,       FREIGHT_TERMS_CODE
    ,       INVOICE_CONTACT_ID
    ,       invoice_to_org_id
    ,       INVOICING_RULE_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NAME
    ,       OVERRIDE_ARULE_FLAG
    ,       OVERRIDE_IRULE_FLAG
    ,       PRICE_LIST_ID
    ,       PURCHASE_ORDER_NUM
    ,       REVISION
    ,       REVISION_DATE
    ,       REVISION_REASON_CODE
    ,       SALESREP_ID
    ,       SHIP_METHOD_CODE
    ,       SIGNATURE_DATE
    ,       START_DATE_ACTIVE
    ,       TERM_ID
    INTO    l_Agreement_rec.accounting_rule_id
    ,       l_Agreement_rec.agreement_contact_id
    ,       l_Agreement_rec.agreement_id
    ,       l_Agreement_rec.agreement_num
    ,       l_Agreement_rec.agreement_type_code
    ,       l_Agreement_rec.attribute1
    ,       l_Agreement_rec.attribute10
    ,       l_Agreement_rec.attribute11
    ,       l_Agreement_rec.attribute12
    ,       l_Agreement_rec.attribute13
    ,       l_Agreement_rec.attribute14
    ,       l_Agreement_rec.attribute15
    ,       l_Agreement_rec.attribute2
    ,       l_Agreement_rec.attribute3
    ,       l_Agreement_rec.attribute4
    ,       l_Agreement_rec.attribute5
    ,       l_Agreement_rec.attribute6
    ,       l_Agreement_rec.attribute7
    ,       l_Agreement_rec.attribute8
    ,       l_Agreement_rec.attribute9
    ,       l_Agreement_rec.context
    ,       l_Agreement_rec.created_by
    ,       l_Agreement_rec.creation_date
    ,       l_Agreement_rec.sold_to_org_id
    ,       l_Agreement_rec.end_date_active
    ,       l_Agreement_rec.freight_terms_code
    ,       l_Agreement_rec.invoice_contact_id
    ,       l_Agreement_rec.invoice_to_org_id
    ,       l_Agreement_rec.invoicing_rule_id
    ,       l_Agreement_rec.last_updated_by
    ,       l_Agreement_rec.last_update_date
    ,       l_Agreement_rec.last_update_login
    ,       l_Agreement_rec.name
    ,       l_Agreement_rec.override_arule_flag
    ,       l_Agreement_rec.override_irule_flag
    ,       l_Agreement_rec.price_list_id
    ,       l_Agreement_rec.purchase_order_num
    ,       l_Agreement_rec.revision
    ,       l_Agreement_rec.revision_date
    ,       l_Agreement_rec.revision_reason_code
    ,       l_Agreement_rec.salesrep_id
    ,       l_Agreement_rec.ship_method_code
    ,       l_Agreement_rec.signature_date
    ,       l_Agreement_rec.start_date_active
    ,       l_Agreement_rec.term_id
    FROM    OE_AGREEMENTS
    WHERE   AGREEMENT_ID = p_Agreement_rec.agreement_id
        FOR UPDATE NOWAIT;
*/
    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_Agreement_rec.accounting_rule_id =
             p_Agreement_rec.accounting_rule_id) OR
            ((p_Agreement_rec.accounting_rule_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.accounting_rule_id IS NULL) AND
                (p_Agreement_rec.accounting_rule_id IS NULL))))
    AND (   (l_Agreement_rec.agreement_contact_id =
             p_Agreement_rec.agreement_contact_id) OR
            ((p_Agreement_rec.agreement_contact_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.agreement_contact_id IS NULL) AND
                (p_Agreement_rec.agreement_contact_id IS NULL))))
    AND (   (l_Agreement_rec.agreement_id =
             p_Agreement_rec.agreement_id) OR
            ((p_Agreement_rec.agreement_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.agreement_id IS NULL) AND
                (p_Agreement_rec.agreement_id IS NULL))))
    AND (   (l_Agreement_rec.agreement_num =
             p_Agreement_rec.agreement_num) OR
            ((p_Agreement_rec.agreement_num = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.agreement_num IS NULL) AND
                (p_Agreement_rec.agreement_num IS NULL))))
    AND (   (l_Agreement_rec.agreement_type_code =
             p_Agreement_rec.agreement_type_code) OR
            ((p_Agreement_rec.agreement_type_code = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.agreement_type_code IS NULL) AND
                (p_Agreement_rec.agreement_type_code IS NULL))))
    AND (   (l_Agreement_rec.attribute1 =
             p_Agreement_rec.attribute1) OR
            ((p_Agreement_rec.attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute1 IS NULL) AND
                (p_Agreement_rec.attribute1 IS NULL))))
    AND (   (l_Agreement_rec.attribute10 =
             p_Agreement_rec.attribute10) OR
            ((p_Agreement_rec.attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute10 IS NULL) AND
                (p_Agreement_rec.attribute10 IS NULL))))
    AND (   (l_Agreement_rec.attribute11 =
             p_Agreement_rec.attribute11) OR
            ((p_Agreement_rec.attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute11 IS NULL) AND
                (p_Agreement_rec.attribute11 IS NULL))))
    AND (   (l_Agreement_rec.attribute12 =
             p_Agreement_rec.attribute12) OR
            ((p_Agreement_rec.attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute12 IS NULL) AND
                (p_Agreement_rec.attribute12 IS NULL))))
    AND (   (l_Agreement_rec.attribute13 =
             p_Agreement_rec.attribute13) OR
            ((p_Agreement_rec.attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute13 IS NULL) AND
                (p_Agreement_rec.attribute13 IS NULL))))
    AND (   (l_Agreement_rec.attribute14 =
             p_Agreement_rec.attribute14) OR
            ((p_Agreement_rec.attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute14 IS NULL) AND
                (p_Agreement_rec.attribute14 IS NULL))))
    AND (   (l_Agreement_rec.attribute15 =
             p_Agreement_rec.attribute15) OR
            ((p_Agreement_rec.attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute15 IS NULL) AND
                (p_Agreement_rec.attribute15 IS NULL))))
    AND (   (l_Agreement_rec.attribute2 =
             p_Agreement_rec.attribute2) OR
            ((p_Agreement_rec.attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute2 IS NULL) AND
                (p_Agreement_rec.attribute2 IS NULL))))
    AND (   (l_Agreement_rec.attribute3 =
             p_Agreement_rec.attribute3) OR
            ((p_Agreement_rec.attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute3 IS NULL) AND
                (p_Agreement_rec.attribute3 IS NULL))))
    AND (   (l_Agreement_rec.attribute4 =
             p_Agreement_rec.attribute4) OR
            ((p_Agreement_rec.attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute4 IS NULL) AND
                (p_Agreement_rec.attribute4 IS NULL))))
    AND (   (l_Agreement_rec.attribute5 =
             p_Agreement_rec.attribute5) OR
            ((p_Agreement_rec.attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute5 IS NULL) AND
                (p_Agreement_rec.attribute5 IS NULL))))
    AND (   (l_Agreement_rec.attribute6 =
             p_Agreement_rec.attribute6) OR
            ((p_Agreement_rec.attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute6 IS NULL) AND
                (p_Agreement_rec.attribute6 IS NULL))))
    AND (   (l_Agreement_rec.attribute7 =
             p_Agreement_rec.attribute7) OR
            ((p_Agreement_rec.attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute7 IS NULL) AND
                (p_Agreement_rec.attribute7 IS NULL))))
    AND (   (l_Agreement_rec.attribute8 =
             p_Agreement_rec.attribute8) OR
            ((p_Agreement_rec.attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute8 IS NULL) AND
                (p_Agreement_rec.attribute8 IS NULL))))
    AND (   (l_Agreement_rec.attribute9 =
             p_Agreement_rec.attribute9) OR
            ((p_Agreement_rec.attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.attribute9 IS NULL) AND
                (p_Agreement_rec.attribute9 IS NULL))))
    AND (   (l_Agreement_rec.context =
             p_Agreement_rec.context) OR
            ((p_Agreement_rec.context = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.context IS NULL) AND
                (p_Agreement_rec.context IS NULL))))
    AND (   (l_Agreement_rec.created_by =
             p_Agreement_rec.created_by) OR
            ((p_Agreement_rec.created_by = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.created_by IS NULL) AND
                (p_Agreement_rec.created_by IS NULL))))
    AND (   (l_Agreement_rec.creation_date =
             p_Agreement_rec.creation_date) OR
            ((p_Agreement_rec.creation_date = FND_API.G_MISS_DATE) OR
            (   (l_Agreement_rec.creation_date IS NULL) AND
                (p_Agreement_rec.creation_date IS NULL))))
    AND (   (l_Agreement_rec.sold_to_org_id =
             p_Agreement_rec.sold_to_org_id) OR
            ((p_Agreement_rec.sold_to_org_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.sold_to_org_id IS NULL) AND
                (p_Agreement_rec.sold_to_org_id IS NULL))))
    AND (   (l_Agreement_rec.end_date_active =
             p_Agreement_rec.end_date_active) OR
            ((p_Agreement_rec.end_date_active = FND_API.G_MISS_DATE) OR
            (   (l_Agreement_rec.end_date_active IS NULL) AND
                (p_Agreement_rec.end_date_active IS NULL))))
    AND (   (l_Agreement_rec.freight_terms_code =
             p_Agreement_rec.freight_terms_code) OR
            ((p_Agreement_rec.freight_terms_code = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.freight_terms_code IS NULL) AND
                (p_Agreement_rec.freight_terms_code IS NULL))))
    AND (   (l_Agreement_rec.invoice_contact_id =
             p_Agreement_rec.invoice_contact_id) OR
            ((p_Agreement_rec.invoice_contact_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.invoice_contact_id IS NULL) AND
                (p_Agreement_rec.invoice_contact_id IS NULL))))
    AND (   (l_Agreement_rec.invoice_to_org_id =
             p_Agreement_rec.invoice_to_org_id) OR
            ((p_Agreement_rec.invoice_to_org_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.invoice_to_org_id IS NULL) AND
                (p_Agreement_rec.invoice_to_org_id IS NULL))))
    AND (   (l_Agreement_rec.invoicing_rule_id =
             p_Agreement_rec.invoicing_rule_id) OR
            ((p_Agreement_rec.invoicing_rule_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.invoicing_rule_id IS NULL) AND
                (p_Agreement_rec.invoicing_rule_id IS NULL))))
    AND (   (l_Agreement_rec.last_updated_by =
             p_Agreement_rec.last_updated_by) OR
            ((p_Agreement_rec.last_updated_by = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.last_updated_by IS NULL) AND
                (p_Agreement_rec.last_updated_by IS NULL))))
    AND (   (l_Agreement_rec.last_update_date =
             p_Agreement_rec.last_update_date) OR
            ((p_Agreement_rec.last_update_date = FND_API.G_MISS_DATE) OR
            (   (l_Agreement_rec.last_update_date IS NULL) AND
                (p_Agreement_rec.last_update_date IS NULL))))
    AND (   (l_Agreement_rec.last_update_login =
             p_Agreement_rec.last_update_login) OR
            ((p_Agreement_rec.last_update_login = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.last_update_login IS NULL) AND
                (p_Agreement_rec.last_update_login IS NULL))))
    AND (   (l_Agreement_rec.name =
             p_Agreement_rec.name) OR
            ((p_Agreement_rec.name = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.name IS NULL) AND
                (p_Agreement_rec.name IS NULL))))
    AND (   (l_Agreement_rec.override_arule_flag =
             p_Agreement_rec.override_arule_flag) OR
            ((p_Agreement_rec.override_arule_flag = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.override_arule_flag IS NULL) AND
                (p_Agreement_rec.override_arule_flag IS NULL))))
    AND (   (l_Agreement_rec.override_irule_flag =
             p_Agreement_rec.override_irule_flag) OR
            ((p_Agreement_rec.override_irule_flag = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.override_irule_flag IS NULL) AND
                (p_Agreement_rec.override_irule_flag IS NULL))))
    AND (   (l_Agreement_rec.price_list_id =
             p_Agreement_rec.price_list_id) OR
            ((p_Agreement_rec.price_list_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.price_list_id IS NULL) AND
                (p_Agreement_rec.price_list_id IS NULL))))
    AND (   (l_Agreement_rec.purchase_order_num =
             p_Agreement_rec.purchase_order_num) OR
            ((p_Agreement_rec.purchase_order_num = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.purchase_order_num IS NULL) AND
                (p_Agreement_rec.purchase_order_num IS NULL))))
    AND (   (l_Agreement_rec.revision =
             p_Agreement_rec.revision) OR
            ((p_Agreement_rec.revision = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.revision IS NULL) AND
                (p_Agreement_rec.revision IS NULL))))
    AND (   (l_Agreement_rec.revision_date =
             p_Agreement_rec.revision_date) OR
            ((p_Agreement_rec.revision_date = FND_API.G_MISS_DATE) OR
            (   (l_Agreement_rec.revision_date IS NULL) AND
                (p_Agreement_rec.revision_date IS NULL))))
    AND (   (l_Agreement_rec.revision_reason_code =
             p_Agreement_rec.revision_reason_code) OR
            ((p_Agreement_rec.revision_reason_code = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.revision_reason_code IS NULL) AND
                (p_Agreement_rec.revision_reason_code IS NULL))))
    AND (   (l_Agreement_rec.salesrep_id =
             p_Agreement_rec.salesrep_id) OR
            ((p_Agreement_rec.salesrep_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.salesrep_id IS NULL) AND
                (p_Agreement_rec.salesrep_id IS NULL))))
    AND (   (l_Agreement_rec.ship_method_code =
             p_Agreement_rec.ship_method_code) OR
            ((p_Agreement_rec.ship_method_code = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.ship_method_code IS NULL) AND
                (p_Agreement_rec.ship_method_code IS NULL))))
    AND (   (l_Agreement_rec.signature_date =
             p_Agreement_rec.signature_date) OR
            ((p_Agreement_rec.signature_date = FND_API.G_MISS_DATE) OR
            (   (l_Agreement_rec.signature_date IS NULL) AND
                (p_Agreement_rec.signature_date IS NULL))))
    AND (   (l_Agreement_rec.start_date_active =
             p_Agreement_rec.start_date_active) OR
            ((p_Agreement_rec.start_date_active = FND_API.G_MISS_DATE) OR
            (   (l_Agreement_rec.start_date_active IS NULL) AND
                (p_Agreement_rec.start_date_active IS NULL))))
    AND (   (l_Agreement_rec.term_id =
             p_Agreement_rec.term_id) OR
            ((p_Agreement_rec.term_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.term_id IS NULL) AND
                (p_Agreement_rec.term_id IS NULL))))
    --Begin code added by rchellam for OKC
    AND (   (l_Agreement_rec.agreement_source_code =
             p_Agreement_rec.agreement_source_code) OR
            ((p_Agreement_rec.agreement_source_code = FND_API.G_MISS_CHAR) OR
            (   (l_Agreement_rec.agreement_source_code IS NULL) AND
                (p_Agreement_rec.agreement_source_code IS NULL))))
    AND (   (l_Agreement_rec.orig_system_agr_id =
             p_Agreement_rec.orig_system_agr_id) OR
            ((p_Agreement_rec.orig_system_agr_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.orig_system_agr_id IS NULL) AND
                (p_Agreement_rec.orig_system_agr_id IS NULL))))
    --End code added by rchellam for OKC
        -- Added for bug#4029589
    AND (   (l_Agreement_rec.invoice_to_customer_id =
             p_Agreement_rec.invoice_to_customer_id) OR
            ((p_Agreement_rec.invoice_to_customer_id = FND_API.G_MISS_NUM) OR
            (   (l_Agreement_rec.invoice_to_customer_id IS NULL) AND
                (p_Agreement_rec.invoice_to_customer_id IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_Agreement_rec                := l_Agreement_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_Agreement_rec.return_status  := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Agreement_rec.return_status  := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    oe_debug_pub.add('Entering OE_Agreement_Util.Lock_Row');

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Agreement_rec.return_status  := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Agreement_rec.return_status  := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Agreement_rec.return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
) RETURN OE_Pricing_Cont_PUB.Agreement_Val_Rec_Type
IS
l_Agreement_val_rec           OE_Pricing_Cont_PUB.Agreement_Val_Rec_Type;
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Get_Values');

    IF p_Agreement_rec.accounting_rule_id IS NOT NULL AND
        p_Agreement_rec.accounting_rule_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.accounting_rule_id,
        p_old_Agreement_rec.accounting_rule_id)
    THEN
        l_Agreement_val_rec.accounting_rule := QP_Id_To_Value.Accounting_Rule
        (   p_accounting_rule_id          => p_Agreement_rec.accounting_rule_id
        );
    END IF;

    IF p_Agreement_rec.agreement_contact_id IS NOT NULL AND
        p_Agreement_rec.agreement_contact_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_contact_id,
        p_old_Agreement_rec.agreement_contact_id)
    THEN
        l_Agreement_val_rec.agreement_contact := QP_Id_To_Value.Agreement_Contact
        (   p_agreement_contact_id        => p_Agreement_rec.agreement_contact_id
        );
    END IF;

/*changes made by spgopal for 'AGR' fix 08/10/00*/
/*
    IF p_Agreement_rec.agreement_id IS NOT NULL AND
        p_Agreement_rec.agreement_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_id,
        p_old_Agreement_rec.agreement_id)
    THEN
        l_Agreement_val_rec.agreement := QP_Id_To_Value.Agreement
        (   p_agreement_id                => p_Agreement_rec.agreement_id
        );
    END IF;
    */

    IF p_Agreement_rec.agreement_type_code IS NOT NULL AND
        p_Agreement_rec.agreement_type_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_type_code,
        p_old_Agreement_rec.agreement_type_code)
    THEN
        l_Agreement_val_rec.agreement_type := QP_Id_To_Value.Agreement_Type
        (   p_agreement_type_code         => p_Agreement_rec.agreement_type_code
        );
    END IF;

    IF p_Agreement_rec.sold_to_org_id IS NOT NULL AND
        p_Agreement_rec.sold_to_org_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.sold_to_org_id,
        p_old_Agreement_rec.sold_to_org_id)
    THEN
        l_Agreement_val_rec.customer := QP_Id_To_Value.Customer
        (   p_sold_to_org_id                 => p_Agreement_rec.sold_to_org_id
        );
    END IF;

    IF p_Agreement_rec.freight_terms_code IS NOT NULL AND
        p_Agreement_rec.freight_terms_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.freight_terms_code,
        p_old_Agreement_rec.freight_terms_code)
    THEN
        l_Agreement_val_rec.freight_terms := QP_Id_To_Value.Freight_Terms
        (   p_freight_terms_code          => p_Agreement_rec.freight_terms_code
        );
    END IF;

    IF p_Agreement_rec.invoice_contact_id IS NOT NULL AND
        p_Agreement_rec.invoice_contact_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.invoice_contact_id,
        p_old_Agreement_rec.invoice_contact_id)
    THEN
        l_Agreement_val_rec.invoice_contact := QP_Id_To_Value.Invoice_Contact
        (   p_invoice_contact_id          => p_Agreement_rec.invoice_contact_id
        );
    END IF;

    IF p_Agreement_rec.invoice_to_org_id IS NOT NULL AND
        p_Agreement_rec.invoice_to_org_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.invoice_to_org_id,
        p_old_Agreement_rec.invoice_to_org_id)
    THEN
        l_Agreement_val_rec.invoice_to_site_use := QP_Id_To_Value.Invoice_To_Site_Use
        (   p_invoice_to_org_id      => p_Agreement_rec.invoice_to_org_id
        );
    END IF;

    IF p_Agreement_rec.invoicing_rule_id IS NOT NULL AND
        p_Agreement_rec.invoicing_rule_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.invoicing_rule_id,
        p_old_Agreement_rec.invoicing_rule_id)
    THEN
        l_Agreement_val_rec.invoicing_rule := QP_Id_To_Value.Invoicing_Rule
        (   p_invoicing_rule_id           => p_Agreement_rec.invoicing_rule_id
        );
    END IF;

    IF p_Agreement_rec.override_arule_flag IS NOT NULL AND
        p_Agreement_rec.override_arule_flag <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.override_arule_flag,
        p_old_Agreement_rec.override_arule_flag)
    THEN
        l_Agreement_val_rec.override_arule := QP_Id_To_Value.Override_Arule
        (   p_override_arule_flag         => p_Agreement_rec.override_arule_flag
        );
    END IF;

    IF p_Agreement_rec.override_irule_flag IS NOT NULL AND
        p_Agreement_rec.override_irule_flag <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.override_irule_flag,
        p_old_Agreement_rec.override_irule_flag)
    THEN
        l_Agreement_val_rec.override_irule := QP_Id_To_Value.Override_Irule
        (   p_override_irule_flag         => p_Agreement_rec.override_irule_flag
        );
    END IF;

    IF p_Agreement_rec.price_list_id IS NOT NULL AND
        p_Agreement_rec.price_list_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.price_list_id,
        p_old_Agreement_rec.price_list_id)
    THEN
        l_Agreement_val_rec.price_list := QP_Id_To_Value.Price_List
        (   p_price_list_id               => p_Agreement_rec.price_list_id
        );
    END IF;

    IF p_Agreement_rec.revision_reason_code IS NOT NULL AND
        p_Agreement_rec.revision_reason_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.revision_reason_code,
        p_old_Agreement_rec.revision_reason_code)
    THEN
        l_Agreement_val_rec.revision_reason := QP_Id_To_Value.Revision_Reason
        (   p_revision_reason_code        => p_Agreement_rec.revision_reason_code
        );
    END IF;

    IF p_Agreement_rec.salesrep_id IS NOT NULL AND
        p_Agreement_rec.salesrep_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.salesrep_id,
        p_old_Agreement_rec.salesrep_id)
    THEN
        l_Agreement_val_rec.salesrep := QP_Id_To_Value.Salesrep
        (   p_salesrep_id                 => p_Agreement_rec.salesrep_id
        );
    END IF;

    IF p_Agreement_rec.ship_method_code IS NOT NULL AND
        p_Agreement_rec.ship_method_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.ship_method_code,
        p_old_Agreement_rec.ship_method_code)
    THEN
        l_Agreement_val_rec.ship_method := QP_Id_To_Value.Ship_Method
        (   p_ship_method_code            => p_Agreement_rec.ship_method_code
        );
    END IF;

    IF p_Agreement_rec.term_id IS NOT NULL AND
        p_Agreement_rec.term_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.term_id,
        p_old_Agreement_rec.term_id)
    THEN
        l_Agreement_val_rec.term := QP_Id_To_Value.Term
        (   p_term_id                     => p_Agreement_rec.term_id
        );
    END IF;

    --Begin code added by rchellam for OKC
    IF p_Agreement_rec.agreement_source_code IS NOT NULL AND
        p_Agreement_rec.agreement_source_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_Agreement_rec.agreement_source_code,
        p_old_Agreement_rec.agreement_source_code)
    THEN
        l_Agreement_val_rec.agreement_source := QP_Id_To_Value.Agreement_Source
        (   p_agreement_source_code     => p_Agreement_rec.agreement_source_code
        );
    END IF;
    --End code added by rchellam for OKC

    RETURN l_Agreement_val_rec;

    oe_debug_pub.add('Exiting OE_Agreement_Util.Get_Values');

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_Agreement_val_rec             IN  OE_Pricing_Cont_PUB.Agreement_Val_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type
IS
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
BEGIN

    oe_debug_pub.add('Entering OE_Agreement_Util.Get_Ids');

    --  initialize  return_status.

    l_Agreement_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_Agreement_rec.

    l_Agreement_rec := p_Agreement_rec;

    IF  p_Agreement_val_rec.accounting_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.accounting_rule_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.accounting_rule_id := p_Agreement_rec.accounting_rule_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.accounting_rule_id := QP_Value_To_Id.accounting_rule
            (   p_accounting_rule             => p_Agreement_val_rec.accounting_rule
            );

            IF l_Agreement_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.agreement_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.agreement_contact_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.agreement_contact_id := p_Agreement_rec.agreement_contact_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.agreement_contact_id := QP_Value_To_Id.agreement_contact
            (   p_agreement_contact           => p_Agreement_val_rec.agreement_contact
            );

            IF l_Agreement_rec.agreement_contact_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.agreement <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.agreement_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.agreement_id := p_Agreement_rec.agreement_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.agreement_id := QP_Value_To_Id.agreement
            (   p_agreement                   => p_Agreement_val_rec.agreement
            );

            IF l_Agreement_rec.agreement_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.agreement_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.agreement_type_code <> FND_API.G_MISS_CHAR THEN

            l_Agreement_rec.agreement_type_code := p_Agreement_rec.agreement_type_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.agreement_type_code := QP_Value_To_Id.agreement_type
            (   p_agreement_type              => p_Agreement_val_rec.agreement_type
            );

            IF l_Agreement_rec.agreement_type_code = FND_API.G_MISS_CHAR THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.customer <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.sold_to_org_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.sold_to_org_id := p_Agreement_rec.sold_to_org_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','customer');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.sold_to_org_id := QP_Value_To_Id.customer
            (   p_customer                    => p_Agreement_val_rec.customer
            );

            IF l_Agreement_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.freight_terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.freight_terms_code <> FND_API.G_MISS_CHAR THEN

            l_Agreement_rec.freight_terms_code := p_Agreement_rec.freight_terms_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.freight_terms_code := QP_Value_To_Id.freight_terms
            (   p_freight_terms               => p_Agreement_val_rec.freight_terms
            );

            IF l_Agreement_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.invoice_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.invoice_contact_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.invoice_contact_id := p_Agreement_rec.invoice_contact_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.invoice_contact_id := QP_Value_To_Id.invoice_contact
            (   p_invoice_contact             => p_Agreement_val_rec.invoice_contact
            );

            IF l_Agreement_rec.invoice_contact_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.invoice_to_site_use <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.invoice_to_org_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.invoice_to_org_id := p_Agreement_rec.invoice_to_org_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_site_use');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.invoice_to_org_id := QP_Value_To_Id.invoice_to_site_use
            (   p_invoice_to_site_use         => p_Agreement_val_rec.invoice_to_site_use
            );

            IF l_Agreement_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.invoicing_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.invoicing_rule_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.invoicing_rule_id := p_Agreement_rec.invoicing_rule_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoicing_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.invoicing_rule_id := QP_Value_To_Id.invoicing_rule
            (   p_invoicing_rule              => p_Agreement_val_rec.invoicing_rule
            );

            IF l_Agreement_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.override_arule <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.override_arule_flag <> FND_API.G_MISS_CHAR THEN

            l_Agreement_rec.override_arule_flag := p_Agreement_rec.override_arule_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override_arule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.override_arule_flag := QP_Value_To_Id.override_arule
            (   p_override_arule              => p_Agreement_val_rec.override_arule
            );

            IF l_Agreement_rec.override_arule_flag = FND_API.G_MISS_CHAR THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.override_irule <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.override_irule_flag <> FND_API.G_MISS_CHAR THEN

            l_Agreement_rec.override_irule_flag := p_Agreement_rec.override_irule_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override_irule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.override_irule_flag := QP_Value_To_Id.override_irule
            (   p_override_irule              => p_Agreement_val_rec.override_irule
            );

            IF l_Agreement_rec.override_irule_flag = FND_API.G_MISS_CHAR THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.price_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.price_list_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.price_list_id := p_Agreement_rec.price_list_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.price_list_id := QP_Value_To_Id.price_list
            (   p_price_list                  => p_Agreement_val_rec.price_list
            );

            IF l_Agreement_rec.price_list_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.revision_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.revision_reason_code <> FND_API.G_MISS_CHAR THEN

            l_Agreement_rec.revision_reason_code := p_Agreement_rec.revision_reason_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.revision_reason_code := QP_Value_To_Id.revision_reason
            (   p_revision_reason             => p_Agreement_val_rec.revision_reason
            );

            IF l_Agreement_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.salesrep <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.salesrep_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.salesrep_id := p_Agreement_rec.salesrep_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.salesrep_id := QP_Value_To_Id.salesrep
            (   p_salesrep                    => p_Agreement_val_rec.salesrep
            );

            IF l_Agreement_rec.salesrep_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.ship_method <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.ship_method_code <> FND_API.G_MISS_CHAR THEN

            l_Agreement_rec.ship_method_code := p_Agreement_rec.ship_method_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_method');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.ship_method_code := QP_Value_To_Id.ship_method
            (   p_ship_method                 => p_Agreement_val_rec.ship_method
            );

            IF l_Agreement_rec.ship_method_code = FND_API.G_MISS_CHAR THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Agreement_val_rec.term <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.term_id <> FND_API.G_MISS_NUM THEN

            l_Agreement_rec.term_id := p_Agreement_rec.term_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','term');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.term_id := QP_Value_To_Id.term
            (   p_term                        => p_Agreement_val_rec.term
            );

            IF l_Agreement_rec.term_id = FND_API.G_MISS_NUM THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    --Begin code added by rchellam for OKC
    IF  p_Agreement_val_rec.agreement_source <> FND_API.G_MISS_CHAR
    THEN

        IF p_Agreement_rec.agreement_source_code <> FND_API.G_MISS_CHAR THEN

            l_Agreement_rec.agreement_source_code := p_Agreement_rec.agreement_source_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_source');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Agreement_rec.agreement_source_code := QP_Value_To_Id.agreement_source
            (   p_agreement_source  => p_Agreement_val_rec.agreement_source
            );

            IF l_Agreement_rec.agreement_source_code = FND_API.G_MISS_CHAR THEN
                l_Agreement_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
    --End code added by rchellam for OKC

    RETURN l_Agreement_rec;

    oe_debug_pub.add('Exiting OE_Agreement_Util.Get_Ids');

END Get_Ids;

END OE_Agreement_Util;

/
