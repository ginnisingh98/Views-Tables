--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_AGREEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_AGREEMENT" AS
/* $Header: OEXLAGRB.pls 120.2 2005/12/14 16:00:12 shulin noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Agreement';

FUNCTION Handle_Revision (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
		)
		RETURN BOOLEAN ;

FUNCTION Allow_Revision (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
		)
		RETURN BOOLEAN ;

FUNCTION Check_EndDates (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
		)
		RETURN BOOLEAN ;

--Begin code added by rchellam for OKC
FUNCTION Valid_Agreement_Source (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
		)
		RETURN BOOLEAN;
--Begin code added by rchellam for OKC

FUNCTION Check_Dates (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
		)
		RETURN BOOLEAN ;

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_Agreement_rec.agreement_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --Begin code added by rchellam for OKC
    IF  p_Agreement_rec.agreement_source_code = 'PAGR' AND
        p_Agreement_rec.price_list_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Price List Id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

      RAISE FND_API.G_EXC_ERROR;

    END IF;

--Commented by sssriniv for making terms field optional
/*    IF  p_Agreement_rec.agreement_source_code = 'PAGR' AND
        p_Agreement_rec.term_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Term Id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;
*/

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

      RAISE FND_API.G_EXC_ERROR;

    END IF;
    --End code added by rchellam for OKC

    --
    --  Check rest of required attributes here.
    --
/* Revision Handling */
	 /* Check for Agreement Name exists */
    IF  p_Agreement_rec.name is not NULL THEN

--            OE_MSG_PUB.Add_Exc_Msg
--            (   G_PKG_NAME
--            ,   'Checking Revsion '
--            );

		if NOT ( Allow_Revision( p_Agreement_rec => p_Agreement_rec))
		THEN
        		l_return_status := FND_API.G_RET_STS_ERROR;
        		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
				FND_MESSAGE.SET_NAME('QP','QP_NO_REVISION');
				OE_MSG_PUB.Add;
			end if;

		END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

	     IF NOT ( Handle_Revision (p_Agreement_rec => p_Agreement_rec ))
		THEN

        		l_return_status := FND_API.G_RET_STS_ERROR;

        		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
				FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_REVISION');
--            		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision');
				OE_MSG_PUB.Add;
--            OE_MSG_PUB.Add_Exc_Msg
--           (   G_PKG_NAME
--          ,   'Revsion Cannot be the Same'
--            );

        		END IF;

		ELSE
		   /* revision is OK, check for dates overlapping */
		   if NOT ( Check_Dates(p_Agreement_rec => p_Agreement_rec ))
		   then

        		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
        		     l_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('QP','QP_OVERLAPPING_START_DATE');
--            		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision');
				OE_MSG_PUB.Add;
/*
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Start Dates Cannot Overlap During Agreement Revisions'
            );
*/
        		END IF;

		   end if;


    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;


		   IF NOT ( Check_EndDates(p_Agreement_rec => p_Agreement_rec ))
		   THEN

        		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        		THEN
        		     l_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('QP','QP_OVERLAPPING_END_DATE');
--            		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision');
				OE_MSG_PUB.Add;
/*
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End Dates Cannot Overlap During Agreement Revisions'
            );
*/
        		END IF;

		   end if;


		END IF;
    END IF;

    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --Begin code added by rchellam for OKC
    IF NOT (Valid_Agreement_Source (p_Agreement_rec => p_Agreement_rec ))
    THEN

      l_return_status := FND_API.G_RET_STS_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('QP','QP_INVALID_AGR_SOURCE_CODE');
        OE_MSG_PUB.Add;
      END IF;

    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;
    --End code added by rchellam for OKC


    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --


    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Agreement attributes

    IF  p_Agreement_rec.accounting_rule_id IS NOT NULL AND
        (   p_Agreement_rec.accounting_rule_id <>
            p_old_Agreement_rec.accounting_rule_id OR
            p_old_Agreement_rec.accounting_rule_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Accounting_Rule(p_Agreement_rec.accounting_rule_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.agreement_contact_id IS NOT NULL AND
        (   p_Agreement_rec.agreement_contact_id <>
            p_old_Agreement_rec.agreement_contact_id OR
            p_old_Agreement_rec.agreement_contact_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Agreement_Contact(p_Agreement_rec.agreement_contact_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.agreement_id IS NOT NULL AND
        (   p_Agreement_rec.agreement_id <>
            p_old_Agreement_rec.agreement_id OR
            p_old_Agreement_rec.agreement_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Agreement(p_Agreement_rec.agreement_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.agreement_num IS NOT NULL AND
        (   p_Agreement_rec.agreement_num <>
            p_old_Agreement_rec.agreement_num OR
            p_old_Agreement_rec.agreement_num IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Agreement_Num(p_Agreement_rec.agreement_num) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.agreement_type_code IS NOT NULL AND
        (   p_Agreement_rec.agreement_type_code <>
            p_old_Agreement_rec.agreement_type_code OR
            p_old_Agreement_rec.agreement_type_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Agreement_Type(p_Agreement_rec.agreement_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.created_by IS NOT NULL AND
        (   p_Agreement_rec.created_by <>
            p_old_Agreement_rec.created_by OR
            p_old_Agreement_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Created_By(p_Agreement_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.creation_date IS NOT NULL AND
        (   p_Agreement_rec.creation_date <>
            p_old_Agreement_rec.creation_date OR
            p_old_Agreement_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Creation_Date(p_Agreement_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

--

    IF  p_Agreement_rec.sold_to_org_id IS NOT NULL AND
        (   p_Agreement_rec.sold_to_org_id <>
            p_old_Agreement_rec.sold_to_org_id OR
            p_old_Agreement_rec.sold_to_org_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Customer(p_Agreement_rec.sold_to_org_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


--
/*
    IF  p_Agreement_rec.customer_id IS NOT NULL AND
        (   p_Agreement_rec.customer_id <>
            p_old_Agreement_rec.customer_id OR
            p_old_Agreement_rec.customer_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Customer(p_Agreement_rec.customer_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/

    IF  p_Agreement_rec.end_date_active IS NOT NULL AND
        (   p_Agreement_rec.end_date_active <>
            p_old_Agreement_rec.end_date_active OR
            p_old_Agreement_rec.end_date_active IS NULL )
    THEN
        IF NOT OE_Validate_Attr.End_Date_Active(p_Agreement_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.freight_terms_code IS NOT NULL AND
        (   p_Agreement_rec.freight_terms_code <>
            p_old_Agreement_rec.freight_terms_code OR
            p_old_Agreement_rec.freight_terms_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Freight_Terms(p_Agreement_rec.freight_terms_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.invoice_contact_id IS NOT NULL AND
        (   p_Agreement_rec.invoice_contact_id <>
            p_old_Agreement_rec.invoice_contact_id OR
            p_old_Agreement_rec.invoice_contact_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Invoice_Contact(p_Agreement_rec.invoice_contact_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

-- Changes

    IF  p_Agreement_rec.invoice_to_org_id IS NOT NULL AND
        (   p_Agreement_rec.invoice_to_org_id <>
            p_old_Agreement_rec.invoice_to_org_id OR
            p_old_Agreement_rec.invoice_to_org_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Invoice_To_Site_Use(p_Agreement_rec.invoice_to_org_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

--
/*    IF  p_Agreement_rec.invoice_to_site_use_id IS NOT NULL AND
        (   p_Agreement_rec.invoice_to_site_use_id <>
            p_old_Agreement_rec.invoice_to_site_use_id OR
            p_old_Agreement_rec.invoice_to_site_use_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Invoice_To_Site_Use(p_Agreement_rec.invoice_to_site_use_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/

    IF  p_Agreement_rec.invoicing_rule_id IS NOT NULL AND
        (   p_Agreement_rec.invoicing_rule_id <>
            p_old_Agreement_rec.invoicing_rule_id OR
            p_old_Agreement_rec.invoicing_rule_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Invoicing_Rule(p_Agreement_rec.invoicing_rule_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.last_updated_by IS NOT NULL AND
        (   p_Agreement_rec.last_updated_by <>
            p_old_Agreement_rec.last_updated_by OR
            p_old_Agreement_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Last_Updated_By(p_Agreement_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.last_update_date IS NOT NULL AND
        (   p_Agreement_rec.last_update_date <>
            p_old_Agreement_rec.last_update_date OR
            p_old_Agreement_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Last_Update_Date(p_Agreement_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.last_update_login IS NOT NULL AND
        (   p_Agreement_rec.last_update_login <>
            p_old_Agreement_rec.last_update_login OR
            p_old_Agreement_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Last_Update_Login(p_Agreement_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.name IS NOT NULL AND
        (   p_Agreement_rec.name <>
            p_old_Agreement_rec.name OR
            p_old_Agreement_rec.name IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Name(p_Agreement_rec.name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

/* Check Revisions */





    END IF;

    IF  p_Agreement_rec.override_arule_flag IS NOT NULL AND
        (   p_Agreement_rec.override_arule_flag <>
            p_old_Agreement_rec.override_arule_flag OR
            p_old_Agreement_rec.override_arule_flag IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Override_Arule(p_Agreement_rec.override_arule_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.override_irule_flag IS NOT NULL AND
        (   p_Agreement_rec.override_irule_flag <>
            p_old_Agreement_rec.override_irule_flag OR
            p_old_Agreement_rec.override_irule_flag IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Override_Irule(p_Agreement_rec.override_irule_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.price_list_id IS NOT NULL AND
        (   p_Agreement_rec.price_list_id <>
            p_old_Agreement_rec.price_list_id OR
            p_old_Agreement_rec.price_list_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Price_List(p_Agreement_rec.price_list_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.purchase_order_num IS NOT NULL AND
        (   p_Agreement_rec.purchase_order_num <>
            p_old_Agreement_rec.purchase_order_num OR
            p_old_Agreement_rec.purchase_order_num IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Purchase_Order_Num(p_Agreement_rec.purchase_order_num) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.revision IS NOT NULL AND
        (   p_Agreement_rec.revision <>
            p_old_Agreement_rec.revision OR
            p_old_Agreement_rec.revision IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Revision(p_Agreement_rec.revision) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.revision_date IS NOT NULL AND
        (   p_Agreement_rec.revision_date <>
            p_old_Agreement_rec.revision_date OR
            p_old_Agreement_rec.revision_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Revision_Date(p_Agreement_rec.revision_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.revision_reason_code IS NOT NULL AND
        (   p_Agreement_rec.revision_reason_code <>
            p_old_Agreement_rec.revision_reason_code OR
            p_old_Agreement_rec.revision_reason_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Revision_Reason(p_Agreement_rec.revision_reason_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.salesrep_id IS NOT NULL AND
        (   p_Agreement_rec.salesrep_id <>
            p_old_Agreement_rec.salesrep_id OR
            p_old_Agreement_rec.salesrep_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Salesrep(p_Agreement_rec.salesrep_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.ship_method_code IS NOT NULL AND
        (   p_Agreement_rec.ship_method_code <>
            p_old_Agreement_rec.ship_method_code OR
            p_old_Agreement_rec.ship_method_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Ship_Method(p_Agreement_rec.ship_method_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.signature_date IS NOT NULL AND
        (   p_Agreement_rec.signature_date <>
            p_old_Agreement_rec.signature_date OR
            p_old_Agreement_rec.signature_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Signature_Date(p_Agreement_rec.signature_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.start_date_active IS NOT NULL AND
        (   p_Agreement_rec.start_date_active <>
            p_old_Agreement_rec.start_date_active OR
            p_old_Agreement_rec.start_date_active IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Start_Date_Active(p_Agreement_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Agreement_rec.term_id IS NOT NULL AND
        (   p_Agreement_rec.term_id <>
            p_old_Agreement_rec.term_id OR
            p_old_Agreement_rec.term_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Term(p_Agreement_rec.term_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    -- Added for bug#4029589
    IF  p_Agreement_rec.invoice_to_customer_id IS NOT NULL AND
        (   p_Agreement_rec.invoice_to_customer_id <>
            p_old_Agreement_rec.invoice_to_customer_id OR
            p_old_Agreement_rec.invoice_to_customer_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Invoice_To_Customer_Id(p_Agreement_rec.invoice_to_customer_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_Agreement_rec.attribute1 IS NOT NULL AND
        (   p_Agreement_rec.attribute1 <>
            p_old_Agreement_rec.attribute1 OR
            p_old_Agreement_rec.attribute1 IS NULL ))
    OR  (p_Agreement_rec.attribute10 IS NOT NULL AND
        (   p_Agreement_rec.attribute10 <>
            p_old_Agreement_rec.attribute10 OR
            p_old_Agreement_rec.attribute10 IS NULL ))
    OR  (p_Agreement_rec.attribute11 IS NOT NULL AND
        (   p_Agreement_rec.attribute11 <>
            p_old_Agreement_rec.attribute11 OR
            p_old_Agreement_rec.attribute11 IS NULL ))
    OR  (p_Agreement_rec.attribute12 IS NOT NULL AND
        (   p_Agreement_rec.attribute12 <>
            p_old_Agreement_rec.attribute12 OR
            p_old_Agreement_rec.attribute12 IS NULL ))
    OR  (p_Agreement_rec.attribute13 IS NOT NULL AND
        (   p_Agreement_rec.attribute13 <>
            p_old_Agreement_rec.attribute13 OR
            p_old_Agreement_rec.attribute13 IS NULL ))
    OR  (p_Agreement_rec.attribute14 IS NOT NULL AND
        (   p_Agreement_rec.attribute14 <>
            p_old_Agreement_rec.attribute14 OR
            p_old_Agreement_rec.attribute14 IS NULL ))
    OR  (p_Agreement_rec.attribute15 IS NOT NULL AND
        (   p_Agreement_rec.attribute15 <>
            p_old_Agreement_rec.attribute15 OR
            p_old_Agreement_rec.attribute15 IS NULL ))
    OR  (p_Agreement_rec.attribute2 IS NOT NULL AND
        (   p_Agreement_rec.attribute2 <>
            p_old_Agreement_rec.attribute2 OR
            p_old_Agreement_rec.attribute2 IS NULL ))
    OR  (p_Agreement_rec.attribute3 IS NOT NULL AND
        (   p_Agreement_rec.attribute3 <>
            p_old_Agreement_rec.attribute3 OR
            p_old_Agreement_rec.attribute3 IS NULL ))
    OR  (p_Agreement_rec.attribute4 IS NOT NULL AND
        (   p_Agreement_rec.attribute4 <>
            p_old_Agreement_rec.attribute4 OR
            p_old_Agreement_rec.attribute4 IS NULL ))
    OR  (p_Agreement_rec.attribute5 IS NOT NULL AND
        (   p_Agreement_rec.attribute5 <>
            p_old_Agreement_rec.attribute5 OR
            p_old_Agreement_rec.attribute5 IS NULL ))
    OR  (p_Agreement_rec.attribute6 IS NOT NULL AND
        (   p_Agreement_rec.attribute6 <>
            p_old_Agreement_rec.attribute6 OR
            p_old_Agreement_rec.attribute6 IS NULL ))
    OR  (p_Agreement_rec.attribute7 IS NOT NULL AND
        (   p_Agreement_rec.attribute7 <>
            p_old_Agreement_rec.attribute7 OR
            p_old_Agreement_rec.attribute7 IS NULL ))
    OR  (p_Agreement_rec.attribute8 IS NOT NULL AND
        (   p_Agreement_rec.attribute8 <>
            p_old_Agreement_rec.attribute8 OR
            p_old_Agreement_rec.attribute8 IS NULL ))
    OR  (p_Agreement_rec.attribute9 IS NOT NULL AND
        (   p_Agreement_rec.attribute9 <>
            p_old_Agreement_rec.attribute9 OR
            p_old_Agreement_rec.attribute9 IS NULL ))
    OR  (p_Agreement_rec.context IS NOT NULL AND
        (   p_Agreement_rec.context <>
            p_old_Agreement_rec.context OR
            p_old_Agreement_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out NOCOPY /* file.sql.39 change */

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_Agreement_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_Agreement_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_Agreement_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_Agreement_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_Agreement_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_Agreement_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_Agreement_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_Agreement_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_Agreement_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_Agreement_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_Agreement_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_Agreement_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_Agreement_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_Agreement_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_Agreement_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_Agreement_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT OE_Validate_Attr.Desc_Flex( 'AGREEMENT' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;



FUNCTION Check_EndDates (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
					)
RETURN BOOLEAN
IS
l_count NUMBER;
l_dummy VARCHAR2(10);
BEGIN

    /* Check Agreement Exists */
    	IF p_Agreement_rec.name is NOT NULL THEN
/* Check for end dates overlap */

	select 'VALID' into l_dummy
	from oe_agreements
	where name = p_Agreement_rec.name
	and (  nvl( trunc(start_date_active),sysdate) between
		  nvl(p_Agreement_rec.start_date_active, sysdate)
		     and
		  nvl(p_Agreement_rec.end_date_active, sysdate)
	OR     nvl(trunc(end_date_active), sysdate) between
		  nvl(p_Agreement_rec.start_date_active , sysdate)
		     and
		  nvl(p_Agreement_rec.end_date_active , sysdate)
		);

    if l_count = 0 THEN
	   RETURN TRUE;
    else
	   RETURN FALSE;
    end if;
 --           OE_MSG_PUB.Add_Exc_Msg
 --           (   G_PKG_NAME
 --           ,   'End Dates are Overlapping' || l_count
 --           );
	     /* Revison needs to be changed */
	END IF;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 RETURN TRUE;
   WHEN TOO_MANY_ROWS THEN
	 RETURN FALSE;

END Check_EndDates;


--

FUNCTION Check_Dates (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
					)
RETURN BOOLEAN
IS
l_count NUMBER;
l_dummy VARCHAR2(10);
BEGIN

    /* Check Agreement Exists */
    	IF p_Agreement_rec.name is NOT NULL THEN

/* Check for start dates */

	select count(*)
	into l_count
	from oe_agreements
	where name = p_Agreement_rec.name
	and nvl(p_Agreement_rec.start_date_active , sysdate)
		  BETWEEN  nvl(trunc(start_date_active), sysdate) and
				 nvl(trunc(end_date_active),sysdate)
		  and p_Agreement_rec.revision <> revision;

     if l_count = 0 THEN
         RETURN TRUE;
     else
	     /* Revison needs to be changed */
		RETURN FALSE;
     end if;
	END IF;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 RETURN TRUE;

   WHEN TOO_MANY_ROWS THEN
	 RETURN TRUE;

END Check_Dates;

--

FUNCTION Allow_Revision (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
					)
RETURN BOOLEAN
IS
l_count NUMBER;
BEGIN

	SELECT  count(*)
	into l_count
	from oe_agreements
    	where name = p_Agreement_rec.name
   -- 	and revision = '1'   /* User may enter revision 2 to start with */
	and ( start_date_active is null
		or
		end_date_active is null ) ;


	if l_count = 0 THEN
		RETURN TRUE;
	else
		RETURN FALSE;
	END IF;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  RETURN TRUE;
	WHEN TOO_MANY_ROWS THEN
		NULL;
END Allow_Revision;


--Begin code added by rchellam for OKC

FUNCTION Valid_Agreement_Source (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
					)
RETURN BOOLEAN
IS
 l_dummy	VARCHAR2(10);
BEGIN

  --Check if agreement_source_code is valid
  IF p_Agreement_rec.agreement_source_code is NOT NULL THEN

    SELECT 'VALID'
    INTO   l_dummy
    FROM   qp_lookups
    WHERE  lookup_type = 'AGREEMENT_SOURCE_CODE'
    AND    lookup_code = p_Agreement_rec.agreement_source_code;

    RETURN TRUE;

  END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;

END Valid_Agreement_Source;

--End code added by rchellam for OKC


FUNCTION Handle_Revision (
		p_Agreement_rec  IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
					)
RETURN BOOLEAN
IS
l_dummy	VARCHAR2(100);
BEGIN

    /* Check Agreement Exists */
    	IF p_Agreement_rec.name is NOT NULL THEN
	    	SELECT 'VALID'
    		into l_dummy
    		FROM OE_AGREEMENTS
    		where name = p_Agreement_rec.name
     	and revision = p_Agreement_rec.revision;


  --          OE_MSG_PUB.Add_Exc_Msg
   --         (   G_PKG_NAME
    --        ,   'Agreement Record Exists'
     --       );

	     /* Revison needs to be changed */
		RETURN FALSE;
	END IF;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
                RETURN TRUE;


END Handle_Revision;

END OE_Validate_Agreement;

/
