--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_AGREEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_AGREEMENT" AS
/* $Header: OEXFAGRB.pls 120.2 2005/12/14 16:13:41 shulin noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Agreement';

--  Global variables holding cached record.

g_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
g_db_Agreement_rec            OE_Pricing_Cont_PUB.Agreement_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_Agreement
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_Agreement
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_agreement_id                  IN  NUMBER
)
RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type;

PROCEDURE Clear_Agreement;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Pricing_Cont_PUB.Agreement_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accounting_rule_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_contact_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_num                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_org_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_contact_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_invoice_to_org_id        	    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_invoicing_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_arule_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_irule_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_purchase_order_num            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_salesrep_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_signature_date                OUT NOCOPY /* file.sql.39 change */ DATE
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_term_id                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_accounting_rule               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_contact             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_contact               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_site_use           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoicing_rule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_arule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_irule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_salesrep                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_term                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_source_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2 --added by rchellam for OKC
,   x_orig_system_agr_id            OUT NOCOPY /* file.sql.39 change */ NUMBER --added by rchellam for OKC
,   x_agreement_source              OUT NOCOPY /* file.sql.39 change */ VARCHAR2 --added by rchellam for OKC
,   x_invoice_to_customer_id        OUT NOCOPY NUMBER -- Added for bug#4029589
)
IS
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_Agreement_val_rec           OE_Pricing_Cont_PUB.Agreement_Val_Rec_Type;
l_control_rec                 oe_globals.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    oe_debug_pub.add('Entering OE_OE_Form_Agreement.Default_Attributes');

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.default_attributes   := TRUE;

    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.
/*
    l_Agreement_rec.attribute1                    := 'NULL';
    l_Agreement_rec.attribute10                   := 'NULL';
    l_Agreement_rec.attribute11                   := 'NULL';
    l_Agreement_rec.attribute12                   := 'NULL';
    l_Agreement_rec.attribute13                   := 'NULL';
    l_Agreement_rec.attribute14                   := 'NULL';
    l_Agreement_rec.attribute15                   := 'NULL';
    l_Agreement_rec.attribute2                    := 'NULL';
    l_Agreement_rec.attribute3                    := 'NULL';
    l_Agreement_rec.attribute4                    := 'NULL';
    l_Agreement_rec.attribute5                    := 'NULL';
    l_Agreement_rec.attribute6                    := 'NULL';
    l_Agreement_rec.attribute7                    := 'NULL';
    l_Agreement_rec.attribute8                    := 'NULL';
    l_Agreement_rec.attribute9                    := 'NULL';
    l_Agreement_rec.context                       := 'NULL';
*/
    --  Set Operation to Create

    l_Agreement_rec.operation := oe_globals.G_OPR_CREATE;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Agreement_rec               => l_Agreement_rec
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    x_accounting_rule_id           := l_x_Agreement_rec.accounting_rule_id;
    x_agreement_contact_id         := l_x_Agreement_rec.agreement_contact_id;
    x_agreement_id                 := l_x_Agreement_rec.agreement_id;
    x_agreement_num                := l_x_Agreement_rec.agreement_num;
    x_agreement_type_code          := l_x_Agreement_rec.agreement_type_code;
    x_attribute1                   := l_x_Agreement_rec.attribute1;
    x_attribute10                  := l_x_Agreement_rec.attribute10;
    x_attribute11                  := l_x_Agreement_rec.attribute11;
    x_attribute12                  := l_x_Agreement_rec.attribute12;
    x_attribute13                  := l_x_Agreement_rec.attribute13;
    x_attribute14                  := l_x_Agreement_rec.attribute14;
    x_attribute15                  := l_x_Agreement_rec.attribute15;
    x_attribute2                   := l_x_Agreement_rec.attribute2;
    x_attribute3                   := l_x_Agreement_rec.attribute3;
    x_attribute4                   := l_x_Agreement_rec.attribute4;
    x_attribute5                   := l_x_Agreement_rec.attribute5;
    x_attribute6                   := l_x_Agreement_rec.attribute6;
    x_attribute7                   := l_x_Agreement_rec.attribute7;
    x_attribute8                   := l_x_Agreement_rec.attribute8;
    x_attribute9                   := l_x_Agreement_rec.attribute9;
    x_context                      := l_x_Agreement_rec.context;
    x_sold_to_org_id               := l_x_Agreement_rec.sold_to_org_id;
    x_end_date_active              := l_x_Agreement_rec.end_date_active;
    x_freight_terms_code           := l_x_Agreement_rec.freight_terms_code;
    x_invoice_contact_id           := l_x_Agreement_rec.invoice_contact_id;
    x_invoice_to_org_id       	   := l_x_Agreement_rec.invoice_to_org_id;
    x_invoicing_rule_id            := l_x_Agreement_rec.invoicing_rule_id;
    x_name                         := l_x_Agreement_rec.name;
    x_override_arule_flag          := l_x_Agreement_rec.override_arule_flag;
    x_override_irule_flag          := l_x_Agreement_rec.override_irule_flag;
    x_price_list_id                := l_x_Agreement_rec.price_list_id;
    x_purchase_order_num           := l_x_Agreement_rec.purchase_order_num;
    x_revision                     := l_x_Agreement_rec.revision;
    x_revision_date                := l_x_Agreement_rec.revision_date;
    x_revision_reason_code         := l_x_Agreement_rec.revision_reason_code;
    x_salesrep_id                  := l_x_Agreement_rec.salesrep_id;
    x_ship_method_code             := l_x_Agreement_rec.ship_method_code;
    x_signature_date               := l_x_Agreement_rec.signature_date;
    x_start_date_active            := l_x_Agreement_rec.start_date_active;
    x_term_id                      := l_x_Agreement_rec.term_id;
    x_agreement_source_code        := l_x_Agreement_rec.agreement_source_code;
                                       --added by rchellam for OKC
    x_orig_system_agr_id           := l_x_Agreement_rec.orig_system_agr_id;
                                       --added by rchellam for OKC
    x_invoice_to_customer_id       := l_x_Agreement_rec.invoice_to_customer_id;
                                       -- Added for bug#4029589

    --  Load display out parameters if any

    l_Agreement_val_rec := OE_Agreement_Util.Get_Values
    (   p_Agreement_rec               => l_x_Agreement_rec
    );
    x_accounting_rule              := l_Agreement_val_rec.accounting_rule;
    x_agreement_contact            := l_Agreement_val_rec.agreement_contact;
    x_agreement                    := l_Agreement_val_rec.agreement;
    x_agreement_type               := l_Agreement_val_rec.agreement_type;
    x_customer                     := l_Agreement_val_rec.customer;
    x_freight_terms                := l_Agreement_val_rec.freight_terms;
    x_invoice_contact              := l_Agreement_val_rec.invoice_contact;
    x_invoice_to_site_use          := l_Agreement_val_rec.invoice_to_site_use;
/* x_invoice_to_org          	:= l_Agreement_val_rec.invoice_to_org; */
    x_invoicing_rule               := l_Agreement_val_rec.invoicing_rule;
    x_override_arule               := l_Agreement_val_rec.override_arule;
    x_override_irule               := l_Agreement_val_rec.override_irule;
    x_price_list                   := l_Agreement_val_rec.price_list;
    x_revision_reason              := l_Agreement_val_rec.revision_reason;
    x_salesrep                     := l_Agreement_val_rec.salesrep;
    x_ship_method                  := l_Agreement_val_rec.ship_method;
    x_term                         := l_Agreement_val_rec.term;
    x_agreement_source             := l_Agreement_val_rec.agreement_source;
                                       --added by rchellam for OKC

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_Agreement_rec.db_flag := FND_API.G_FALSE;

    Write_Agreement
    (   p_Agreement_rec               => l_x_Agreement_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_Form_Agreement.Default_Attributes');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id                  IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   x_accounting_rule_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_contact_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_agreement_num                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_org_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_contact_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_invoice_to_org_id        	    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_invoicing_rule_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_arule_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_irule_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_purchase_order_num            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_salesrep_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_signature_date                OUT NOCOPY /* file.sql.39 change */ DATE
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_term_id                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_accounting_rule               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_contact             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_contact               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_site_use           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoicing_rule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_arule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override_irule                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_salesrep                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_term                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_agreement_source_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2 --added by rchellam for OKC
,   x_orig_system_agr_id            OUT NOCOPY /* file.sql.39 change */ NUMBER --added by rchellam for OKC
,   x_agreement_source              OUT NOCOPY /* file.sql.39 change */ VARCHAR2 --added by rchellam for OKC
,   x_invoice_to_customer_id        OUT NOCOPY NUMBER -- Added for bug#4029589
)
IS
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_old_Agreement_rec           OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_Agreement_val_rec           OE_Pricing_Cont_PUB.Agreement_Val_Rec_Type;
l_control_rec                 oe_globals.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    oe_debug_pub.add('Entering OE_OE_Form_Agreement.Change_Attribute');

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read Agreement from cache

    l_Agreement_rec := Get_Agreement
    (   p_db_record                   => FALSE
    ,   p_agreement_id                => p_agreement_id
    );

    l_old_Agreement_rec            := l_Agreement_rec;

    IF p_attr_id = OE_Agreement_Util.G_ACCOUNTING_RULE THEN
        l_Agreement_rec.accounting_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_AGREEMENT_CONTACT THEN
        l_Agreement_rec.agreement_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_AGREEMENT THEN
        l_Agreement_rec.agreement_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_AGREEMENT_NUM THEN
        l_Agreement_rec.agreement_num := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_AGREEMENT_TYPE THEN
        l_Agreement_rec.agreement_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_CUSTOMER THEN
/*        l_Agreement_rec.customer_id := TO_NUMBER(p_attr_value); */
        l_Agreement_rec.sold_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_END_DATE_ACTIVE THEN
        l_Agreement_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Agreement_Util.G_FREIGHT_TERMS THEN
        l_Agreement_rec.freight_terms_code := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_INVOICE_CONTACT THEN
        l_Agreement_rec.invoice_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_INVOICE_TO_SITE_USE THEN
/*    ELSIF p_attr_id = OE_Agreement_Util.G_INVOICE_TO_ORG THEN */
/*        l_Agreement_rec.invoice_to_site_use_id := TO_NUMBER(p_attr_value); */
        l_Agreement_rec.invoice_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_INVOICING_RULE THEN
        l_Agreement_rec.invoicing_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_NAME THEN
        l_Agreement_rec.name := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_OVERRIDE_ARULE THEN
        l_Agreement_rec.override_arule_flag := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_OVERRIDE_IRULE THEN
        l_Agreement_rec.override_irule_flag := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_PRICE_LIST THEN
        l_Agreement_rec.price_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_PURCHASE_ORDER_NUM THEN
        l_Agreement_rec.purchase_order_num := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_REVISION THEN
        l_Agreement_rec.revision := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_REVISION_DATE THEN
        l_Agreement_rec.revision_date := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Agreement_Util.G_REVISION_REASON THEN
        l_Agreement_rec.revision_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_SALESREP THEN
        l_Agreement_rec.salesrep_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_SHIP_METHOD THEN
        l_Agreement_rec.ship_method_code := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_SIGNATURE_DATE THEN
        l_Agreement_rec.signature_date := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Agreement_Util.G_START_DATE_ACTIVE THEN
        l_Agreement_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Agreement_Util.G_TERM THEN
        l_Agreement_rec.term_id := TO_NUMBER(p_attr_value);
    --Begin code added by rchellam for OKC
    ELSIF p_attr_id = OE_Agreement_Util.G_AGREEMENT_SOURCE THEN
        l_Agreement_rec.agreement_source_code := p_attr_value;
    ELSIF p_attr_id = OE_Agreement_Util.G_ORIG_SYSTEM_AGR THEN
        l_Agreement_rec.orig_system_agr_id := TO_NUMBER(p_attr_value);
    --End code added by rchellam for OKC
    -- Added for bug#4029589
    ELSIF p_attr_id = OE_Agreement_Util.G_INVOICE_TO_CUSTOMER_ID THEN
        l_Agreement_rec.invoice_to_customer_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Agreement_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Agreement_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Agreement_Util.G_CONTEXT
    THEN

        l_Agreement_rec.attribute1     := p_attribute1;
        l_Agreement_rec.attribute10    := p_attribute10;
        l_Agreement_rec.attribute11    := p_attribute11;
        l_Agreement_rec.attribute12    := p_attribute12;
        l_Agreement_rec.attribute13    := p_attribute13;
        l_Agreement_rec.attribute14    := p_attribute14;
        l_Agreement_rec.attribute15    := p_attribute15;
        l_Agreement_rec.attribute2     := p_attribute2;
        l_Agreement_rec.attribute3     := p_attribute3;
        l_Agreement_rec.attribute4     := p_attribute4;
        l_Agreement_rec.attribute5     := p_attribute5;
        l_Agreement_rec.attribute6     := p_attribute6;
        l_Agreement_rec.attribute7     := p_attribute7;
        l_Agreement_rec.attribute8     := p_attribute8;
        l_Agreement_rec.attribute9     := p_attribute9;
        l_Agreement_rec.context        := p_context;

    ELSE

        --  Unexpected error, unrecognized attribute

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --  Set Operation.

    IF FND_API.To_Boolean(l_Agreement_rec.db_flag) THEN
        l_Agreement_rec.operation := oe_globals.G_OPR_UPDATE;
    ELSE
        l_Agreement_rec.operation := oe_globals.G_OPR_CREATE;
    END IF;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Agreement_rec               => l_Agreement_rec
    ,   p_old_Agreement_rec           => l_old_Agreement_rec
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Init OUT parameters to missing.

    x_accounting_rule_id           := FND_API.G_MISS_NUM;
    x_agreement_contact_id         := FND_API.G_MISS_NUM;
    x_agreement_id                 := FND_API.G_MISS_NUM;
    x_agreement_num                := FND_API.G_MISS_CHAR;
    x_agreement_type_code          := FND_API.G_MISS_CHAR;
    x_attribute1                   := FND_API.G_MISS_CHAR;
    x_attribute10                  := FND_API.G_MISS_CHAR;
    x_attribute11                  := FND_API.G_MISS_CHAR;
    x_attribute12                  := FND_API.G_MISS_CHAR;
    x_attribute13                  := FND_API.G_MISS_CHAR;
    x_attribute14                  := FND_API.G_MISS_CHAR;
    x_attribute15                  := FND_API.G_MISS_CHAR;
    x_attribute2                   := FND_API.G_MISS_CHAR;
    x_attribute3                   := FND_API.G_MISS_CHAR;
    x_attribute4                   := FND_API.G_MISS_CHAR;
    x_attribute5                   := FND_API.G_MISS_CHAR;
    x_attribute6                   := FND_API.G_MISS_CHAR;
    x_attribute7                   := FND_API.G_MISS_CHAR;
    x_attribute8                   := FND_API.G_MISS_CHAR;
    x_attribute9                   := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_sold_to_org_id                  := FND_API.G_MISS_NUM;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_freight_terms_code           := FND_API.G_MISS_CHAR;
    x_invoice_contact_id           := FND_API.G_MISS_NUM;
    x_invoice_to_org_id       		:= FND_API.G_MISS_NUM;
    x_invoicing_rule_id            := FND_API.G_MISS_NUM;
    x_name                         := FND_API.G_MISS_CHAR;
    x_override_arule_flag          := FND_API.G_MISS_CHAR;
    x_override_irule_flag          := FND_API.G_MISS_CHAR;
    x_price_list_id                := FND_API.G_MISS_NUM;
    x_purchase_order_num           := FND_API.G_MISS_CHAR;
    x_revision                     := FND_API.G_MISS_CHAR;
    x_revision_date                := FND_API.G_MISS_DATE;
    x_revision_reason_code         := FND_API.G_MISS_CHAR;
    x_salesrep_id                  := FND_API.G_MISS_NUM;
    x_ship_method_code             := FND_API.G_MISS_CHAR;
    x_signature_date               := FND_API.G_MISS_DATE;
    x_start_date_active            := FND_API.G_MISS_DATE;
    x_term_id                      := FND_API.G_MISS_NUM;
    x_accounting_rule              := FND_API.G_MISS_CHAR;
    x_agreement_contact            := FND_API.G_MISS_CHAR;
    x_agreement                    := FND_API.G_MISS_CHAR;
    x_agreement_type               := FND_API.G_MISS_CHAR;
    x_customer                     := FND_API.G_MISS_CHAR;
    x_freight_terms                := FND_API.G_MISS_CHAR;
    x_invoice_contact              := FND_API.G_MISS_CHAR;
    x_invoice_to_site_use          := FND_API.G_MISS_CHAR;
/*    x_invoice_org          		:= FND_API.G_MISS_CHAR; */
    x_invoicing_rule               := FND_API.G_MISS_CHAR;
    x_override_arule               := FND_API.G_MISS_CHAR;
    x_override_irule               := FND_API.G_MISS_CHAR;
    x_price_list                   := FND_API.G_MISS_CHAR;
    x_revision_reason              := FND_API.G_MISS_CHAR;
    x_salesrep                     := FND_API.G_MISS_CHAR;
    x_ship_method                  := FND_API.G_MISS_CHAR;
    x_term                         := FND_API.G_MISS_CHAR;
    x_agreement_source_code        := FND_API.G_MISS_CHAR;
                                        --added by rchellam for OKC
    x_orig_system_agr_id           := FND_API.G_MISS_NUM;
                                        --added by rchellam for OKC
    x_agreement_source             := FND_API.G_MISS_CHAR;
                                        --added by rchellam for OKC
    x_invoice_to_customer_id       := FND_API.G_MISS_NUM;
                                        -- Added for bug#4029589

    --  Load display out parameters if any

    l_Agreement_val_rec := OE_Agreement_Util.Get_Values
    (   p_Agreement_rec               => l_x_Agreement_rec
    ,   p_old_Agreement_rec           => l_Agreement_rec
    );

    --  Return changed attributes.

    IF NOT oe_globals.Equal(l_x_Agreement_rec.accounting_rule_id,
                            l_Agreement_rec.accounting_rule_id)
    THEN
        x_accounting_rule_id := l_x_Agreement_rec.accounting_rule_id;
        x_accounting_rule := l_Agreement_val_rec.accounting_rule;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.agreement_contact_id,
                            l_Agreement_rec.agreement_contact_id)
    THEN
        x_agreement_contact_id := l_x_Agreement_rec.agreement_contact_id;
        x_agreement_contact := l_Agreement_val_rec.agreement_contact;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.agreement_id,
                            l_Agreement_rec.agreement_id)
    THEN
        x_agreement_id := l_x_Agreement_rec.agreement_id;
        x_agreement := l_Agreement_val_rec.agreement;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.agreement_num,
                            l_Agreement_rec.agreement_num)
    THEN
        x_agreement_num := l_x_Agreement_rec.agreement_num;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.agreement_type_code,
                            l_Agreement_rec.agreement_type_code)
    THEN
        x_agreement_type_code := l_x_Agreement_rec.agreement_type_code;
        x_agreement_type := l_Agreement_val_rec.agreement_type;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute1,
                            l_Agreement_rec.attribute1)
    THEN
        x_attribute1 := l_x_Agreement_rec.attribute1;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute10,
                            l_Agreement_rec.attribute10)
    THEN
        x_attribute10 := l_x_Agreement_rec.attribute10;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute11,
                            l_Agreement_rec.attribute11)
    THEN
        x_attribute11 := l_x_Agreement_rec.attribute11;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute12,
                            l_Agreement_rec.attribute12)
    THEN
        x_attribute12 := l_x_Agreement_rec.attribute12;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute13,
                            l_Agreement_rec.attribute13)
    THEN
        x_attribute13 := l_x_Agreement_rec.attribute13;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute14,
                            l_Agreement_rec.attribute14)
    THEN
        x_attribute14 := l_x_Agreement_rec.attribute14;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute15,
                            l_Agreement_rec.attribute15)
    THEN
        x_attribute15 := l_x_Agreement_rec.attribute15;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute2,
                            l_Agreement_rec.attribute2)
    THEN
        x_attribute2 := l_x_Agreement_rec.attribute2;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute3,
                            l_Agreement_rec.attribute3)
    THEN
        x_attribute3 := l_x_Agreement_rec.attribute3;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute4,
                            l_Agreement_rec.attribute4)
    THEN
        x_attribute4 := l_x_Agreement_rec.attribute4;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute5,
                            l_Agreement_rec.attribute5)
    THEN
        x_attribute5 := l_x_Agreement_rec.attribute5;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute6,
                            l_Agreement_rec.attribute6)
    THEN
        x_attribute6 := l_x_Agreement_rec.attribute6;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute7,
                            l_Agreement_rec.attribute7)
    THEN
        x_attribute7 := l_x_Agreement_rec.attribute7;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute8,
                            l_Agreement_rec.attribute8)
    THEN
        x_attribute8 := l_x_Agreement_rec.attribute8;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.attribute9,
                            l_Agreement_rec.attribute9)
    THEN
        x_attribute9 := l_x_Agreement_rec.attribute9;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.context,
                            l_Agreement_rec.context)
    THEN
        x_context := l_x_Agreement_rec.context;
    END IF;

/*
    IF NOT oe_globals.Equal(l_x_Agreement_rec.customer_id,
                            l_Agreement_rec.customer_id)
    THEN
        x_customer_id := l_x_Agreement_rec.customer_id;
        x_customer := l_Agreement_val_rec.customer;
    END IF;
*/

    IF NOT oe_globals.Equal(l_x_Agreement_rec.sold_to_org_id,
                            l_Agreement_rec.sold_to_org_id)
    THEN
        x_sold_to_org_id := l_x_Agreement_rec.sold_to_org_id;
        x_customer := l_Agreement_val_rec.customer;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.end_date_active,
                            l_Agreement_rec.end_date_active)
    THEN
        x_end_date_active := l_x_Agreement_rec.end_date_active;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.freight_terms_code,
                            l_Agreement_rec.freight_terms_code)
    THEN
        x_freight_terms_code := l_x_Agreement_rec.freight_terms_code;
        x_freight_terms := l_Agreement_val_rec.freight_terms;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.invoice_contact_id,
                            l_Agreement_rec.invoice_contact_id)
    THEN
        x_invoice_contact_id := l_x_Agreement_rec.invoice_contact_id;
        x_invoice_contact := l_Agreement_val_rec.invoice_contact;
    END IF;

/*    IF NOT oe_globals.Equal(l_x_Agreement_rec.invoice_to_site_use_id,
                            l_Agreement_rec.invoice_to_site_use_id)
*/
    IF NOT oe_globals.Equal(l_x_Agreement_rec.invoice_to_org_id,
                            l_Agreement_rec.invoice_to_org_id)
    THEN
/*   x_invoice_to_site_use_id := l_x_Agreement_rec.invoice_to_site_use_id;*/
        x_invoice_to_org_id := l_x_Agreement_rec.invoice_to_org_id;

        x_invoice_to_site_use := l_Agreement_val_rec.invoice_to_site_use;
/*        x_invoice_to_org := l_Agreement_val_rec.invoice_to_org; */
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.invoicing_rule_id,
                            l_Agreement_rec.invoicing_rule_id)
    THEN
        x_invoicing_rule_id := l_x_Agreement_rec.invoicing_rule_id;
        x_invoicing_rule := l_Agreement_val_rec.invoicing_rule;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.name,
                            l_Agreement_rec.name)
    THEN
        x_name := l_x_Agreement_rec.name;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.override_arule_flag,
                            l_Agreement_rec.override_arule_flag)
    THEN
        x_override_arule_flag := l_x_Agreement_rec.override_arule_flag;
        x_override_arule := l_Agreement_val_rec.override_arule;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.override_irule_flag,
                            l_Agreement_rec.override_irule_flag)
    THEN
        x_override_irule_flag := l_x_Agreement_rec.override_irule_flag;
        x_override_irule := l_Agreement_val_rec.override_irule;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.price_list_id,
                            l_Agreement_rec.price_list_id)
    THEN
        x_price_list_id := l_x_Agreement_rec.price_list_id;
        x_price_list := l_Agreement_val_rec.price_list;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.purchase_order_num,
                            l_Agreement_rec.purchase_order_num)
    THEN
        x_purchase_order_num := l_x_Agreement_rec.purchase_order_num;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.revision,
                            l_Agreement_rec.revision)
    THEN
        x_revision := l_x_Agreement_rec.revision;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.revision_date,
                            l_Agreement_rec.revision_date)
    THEN
        x_revision_date := l_x_Agreement_rec.revision_date;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.revision_reason_code,
                            l_Agreement_rec.revision_reason_code)
    THEN
        x_revision_reason_code := l_x_Agreement_rec.revision_reason_code;
        x_revision_reason := l_Agreement_val_rec.revision_reason;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.salesrep_id,
                            l_Agreement_rec.salesrep_id)
    THEN
        x_salesrep_id := l_x_Agreement_rec.salesrep_id;
        x_salesrep := l_Agreement_val_rec.salesrep;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.ship_method_code,
                            l_Agreement_rec.ship_method_code)
    THEN
        x_ship_method_code := l_x_Agreement_rec.ship_method_code;
        x_ship_method := l_Agreement_val_rec.ship_method;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.signature_date,
                            l_Agreement_rec.signature_date)
    THEN
        x_signature_date := l_x_Agreement_rec.signature_date;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.start_date_active,
                            l_Agreement_rec.start_date_active)
    THEN
        x_start_date_active := l_x_Agreement_rec.start_date_active;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.term_id,
                            l_Agreement_rec.term_id)
    THEN
        x_term_id := l_x_Agreement_rec.term_id;
        x_term := l_Agreement_val_rec.term;
    END IF;

    --Begin code added by rchellam for OKC
    IF NOT oe_globals.Equal(l_x_Agreement_rec.agreement_source_code,
                            l_Agreement_rec.agreement_source_code)
    THEN
        x_agreement_source_code := l_x_Agreement_rec.agreement_source_code;
        x_agreement_source := l_Agreement_val_rec.agreement_source;
    END IF;

    IF NOT oe_globals.Equal(l_x_Agreement_rec.orig_system_agr_id,
                            l_Agreement_rec.orig_system_agr_id)
    THEN
        x_orig_system_agr_id := l_x_Agreement_rec.orig_system_agr_id;
    END IF;
    --End code added by rchellam for OKC

    -- Added for bug#4029589
    IF NOT oe_globals.Equal(l_x_Agreement_rec.invoice_to_customer_id,
                            l_Agreement_rec.invoice_to_customer_id)
    THEN
        x_invoice_to_customer_id := l_x_Agreement_rec.invoice_to_customer_id;
    END IF;
    --  Write to cache.

    Write_Agreement
    (   p_Agreement_rec               => l_x_Agreement_rec
    );


   /* Added following code to raise warning message for Bug-2106110 */

      If p_attr_id = OE_Agreement_Util.G_NAME
        AND  l_old_Agreement_rec.name is not NULL Then
        If l_old_Agreement_rec.name <> p_attr_value Then
          FND_MESSAGE.SET_NAME('QP','QP_AGR_NAME_CHG');
          OE_MSG_PUB.Add;
         END IF;
      End If;
/* End of code for Bug-2106110 */

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_Form_Agreement.Change_Attribute');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Change_Attribute;

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id                  IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_old_Agreement_rec           OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_control_rec                 oe_globals.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    oe_debug_pub.add('Entering OE_OE_Form_Agreement.Validate_And_Write');

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read Agreement from cache

    l_old_Agreement_rec := Get_Agreement
    (   p_db_record                   => TRUE
    ,   p_agreement_id                => p_agreement_id
    );

    l_Agreement_rec := Get_Agreement
    (   p_db_record                   => FALSE
    ,   p_agreement_id                => p_agreement_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_Agreement_rec.db_flag) THEN
        l_Agreement_rec.operation := oe_globals.G_OPR_UPDATE;
    ELSE
        l_Agreement_rec.operation := oe_globals.G_OPR_CREATE;
    END IF;



    --Revision Control S
    IF ( l_old_agreement_rec.revision <>  l_agreement_rec.revision
    and l_Agreement_rec.operation = oe_globals.G_OPR_UPDATE ) THEN

   select oe_agreements_s.nextval into l_agreement_rec.agreement_id from dual;

        l_Agreement_rec.operation := oe_globals.G_OPR_CREATE;
        l_Agreement_rec.db_flag := FND_API.G_FALSE;
  --OE_OE_Form_Contract.Create_Revision(l_agreement_rec.agreement_id);
    END IF;
    --Revision Control E





    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont


    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Agreement_rec               => l_Agreement_rec
    ,   p_old_Agreement_rec           => l_old_Agreement_rec
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );


/*    commit; */


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Load OUT parameters.


    x_creation_date                := l_x_Agreement_rec.creation_date;
    x_created_by                   := l_x_Agreement_rec.created_by;
    x_last_update_date             := l_x_Agreement_rec.last_update_date;
    x_last_updated_by              := l_x_Agreement_rec.last_updated_by;
    x_last_update_login            := l_x_Agreement_rec.last_update_login;

    --  Clear Agreement record cache

    Clear_Agreement;

    --  Keep track of performed operations.

    l_old_Agreement_rec.operation := l_Agreement_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_Form_Agreement.Validate_And_Write');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   x_msg_count || '1 ' || x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   x_msg_count || '2 ' || x_msg_data
            );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   x_msg_count || '3 ' || x_msg_data
            );

END Validate_And_Write;

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id                  IN  NUMBER
)
IS
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_control_rec                 oe_globals.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

    l_Agreement_rec := Get_Agreement
    (   p_db_record                   => TRUE
    ,   p_agreement_id                => p_agreement_id
    );

    --  Set Operation.

    l_Agreement_rec.operation := oe_globals.G_OPR_DELETE;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Agreement_rec               => l_Agreement_rec
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear Agreement record cache

    Clear_Agreement;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Row;

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_control_rec                 oe_globals.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := oe_globals.G_ENTITY_AGREEMENT;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Entity;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_accounting_rule_id            IN  NUMBER
,   p_agreement_contact_id          IN  NUMBER
,   p_agreement_id                  IN  NUMBER
,   p_agreement_num                 IN  VARCHAR2
,   p_agreement_type_code           IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
/* ,   p_customer_id                   IN  NUMBER */
,   p_sold_to_org_id                   IN  NUMBER
,   p_end_date_active               IN  DATE
,   p_freight_terms_code            IN  VARCHAR2
,   p_invoice_contact_id            IN  NUMBER
/* ,   p_invoice_to_site_use_id        IN  NUMBER */
,   p_invoice_to_org_id        	 IN  NUMBER
,   p_invoicing_rule_id             IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_name                          IN  VARCHAR2
,   p_override_arule_flag           IN  VARCHAR2
,   p_override_irule_flag           IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
,   p_purchase_order_num            IN  VARCHAR2
,   p_revision                      IN  VARCHAR2
,   p_revision_date                 IN  DATE
,   p_revision_reason_code          IN  VARCHAR2
,   p_salesrep_id                   IN  NUMBER
,   p_ship_method_code              IN  VARCHAR2
,   p_signature_date                IN  DATE
,   p_start_date_active             IN  DATE
,   p_term_id                       IN  NUMBER
,   p_agreement_source_code         IN  VARCHAR2
                                         --added by rchellam for OKC
,   p_orig_system_agr_id            IN  NUMBER --added by rchellam for OKC
,   p_invoice_to_customer_id        IN  NUMBER -- Added for bug#4029589
)
IS
l_return_status               VARCHAR2(1);
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Load Agreement record

    l_Agreement_rec.accounting_rule_id := p_accounting_rule_id;
    l_Agreement_rec.agreement_contact_id := p_agreement_contact_id;
    l_Agreement_rec.agreement_id   := p_agreement_id;
    l_Agreement_rec.agreement_num  := p_agreement_num;
    l_Agreement_rec.agreement_type_code := p_agreement_type_code;
    l_Agreement_rec.attribute1     := p_attribute1;
    l_Agreement_rec.attribute10    := p_attribute10;
    l_Agreement_rec.attribute11    := p_attribute11;
    l_Agreement_rec.attribute12    := p_attribute12;
    l_Agreement_rec.attribute13    := p_attribute13;
    l_Agreement_rec.attribute14    := p_attribute14;
    l_Agreement_rec.attribute15    := p_attribute15;
    l_Agreement_rec.attribute2     := p_attribute2;
    l_Agreement_rec.attribute3     := p_attribute3;
    l_Agreement_rec.attribute4     := p_attribute4;
    l_Agreement_rec.attribute5     := p_attribute5;
    l_Agreement_rec.attribute6     := p_attribute6;
    l_Agreement_rec.attribute7     := p_attribute7;
    l_Agreement_rec.attribute8     := p_attribute8;
    l_Agreement_rec.attribute9     := p_attribute9;
    l_Agreement_rec.context        := p_context;
    l_Agreement_rec.created_by     := p_created_by;
    l_Agreement_rec.creation_date  := p_creation_date;
/*    l_Agreement_rec.customer_id    := p_customer_id; */
    l_Agreement_rec.sold_to_org_id    := p_sold_to_org_id;
    l_Agreement_rec.end_date_active := p_end_date_active;
    l_Agreement_rec.freight_terms_code := p_freight_terms_code;
    l_Agreement_rec.invoice_contact_id := p_invoice_contact_id;
/*    l_Agreement_rec.invoice_to_site_use_id := p_invoice_to_site_use_id; */
    l_Agreement_rec.invoice_to_org_id := p_invoice_to_org_id;
    l_Agreement_rec.invoicing_rule_id := p_invoicing_rule_id;
    l_Agreement_rec.last_updated_by := p_last_updated_by;
    l_Agreement_rec.last_update_date := p_last_update_date;
    l_Agreement_rec.last_update_login := p_last_update_login;
    l_Agreement_rec.name           := p_name;
    l_Agreement_rec.override_arule_flag := p_override_arule_flag;
    l_Agreement_rec.override_irule_flag := p_override_irule_flag;
    l_Agreement_rec.price_list_id  := p_price_list_id;
    l_Agreement_rec.purchase_order_num := p_purchase_order_num;
    l_Agreement_rec.revision       := p_revision;
    l_Agreement_rec.revision_date  := p_revision_date;
    l_Agreement_rec.revision_reason_code := p_revision_reason_code;
    l_Agreement_rec.salesrep_id    := p_salesrep_id;
    l_Agreement_rec.ship_method_code := p_ship_method_code;
    l_Agreement_rec.signature_date := p_signature_date;
    l_Agreement_rec.start_date_active := p_start_date_active;
    l_Agreement_rec.term_id        := p_term_id;
    l_Agreement_rec.agreement_source_code := p_agreement_source_code;
    l_Agreement_rec.orig_system_agr_id := p_orig_system_agr_id;
    l_Agreement_rec.invoice_to_customer_id := p_invoice_to_customer_id; -- Added for bug#4029589


    --  Call OE_Pricing_Cont_PVT.Lock_Pricing_Cont

    OE_Pricing_Cont_PVT.Lock_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_Agreement_rec               => l_Agreement_rec
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_Agreement_rec.db_flag := FND_API.G_TRUE;

        Write_Agreement
        (   p_Agreement_rec               => l_x_Agreement_rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Lock_Row;

--  Procedures maintaining Agreement record cache.

PROCEDURE Write_Agreement
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_Agreement_rec := p_Agreement_rec;

    IF p_db_record THEN

        g_db_Agreement_rec := p_Agreement_rec;

    END IF;

END Write_Agreement;

FUNCTION Get_Agreement
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_agreement_id                  IN  NUMBER
)
RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type
IS
BEGIN

    IF  p_agreement_id <> g_Agreement_rec.agreement_id
    THEN

        --  Query row from DB

        g_Agreement_rec := OE_Agreement_Util.Query_Row
        (   p_agreement_id                => p_agreement_id
        );

        g_Agreement_rec.db_flag        := FND_API.G_TRUE;

        --  Load DB record

        g_db_Agreement_rec             := g_Agreement_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_Agreement_rec;

    ELSE

        RETURN g_Agreement_rec;

    END IF;

END Get_Agreement;

PROCEDURE Clear_Agreement
IS
BEGIN

    g_Agreement_rec                := OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC;
    g_db_Agreement_rec             := OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC;

END Clear_Agreement;

END OE_OE_Form_Agreement;

/
