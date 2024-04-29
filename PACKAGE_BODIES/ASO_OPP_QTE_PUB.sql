--------------------------------------------------------
--  DDL for Package Body ASO_OPP_QTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_OPP_QTE_PUB" AS
/* $Header: asopopqb.pls 120.18.12010000.2 2014/11/06 19:25:20 vidsrini ship $ */

-- Start of Comments
-- Package name : ASO_OPP_QTE_PUB
-- Purpose      : API to create quote from opportunity
-- End of Comments


G_PKG_NAME           CONSTANT    VARCHAR2(30) := 'ASO_OPP_QTE_PUB';
G_FILE_NAME          CONSTANT    VARCHAR2(12) := 'asopopqb.pls';


PROCEDURE Create_Qte_Opportunity(
P_API_VERSION_NUMBER     IN  NUMBER,
P_INIT_MSG_LIST          IN  VARCHAR2 := FND_API.G_FALSE,
P_COMMIT                 IN  VARCHAR2 := FND_API.G_FALSE,
P_VALIDATION_LEVEL       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
P_SOURCE_CODE            IN  VARCHAR2,
P_QUOTE_HEADER_REC       IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec,
P_HEADER_PAYMENT_REC     IN  ASO_QUOTE_PUB.Payment_Rec_Type    := ASO_QUOTE_PUB.G_MISS_Payment_REC,
P_HEADER_SHIPMENT_REC    IN  ASO_QUOTE_PUB.Shipment_Rec_Type   := ASO_QUOTE_PUB.G_MISS_Shipment_REC,
P_HEADER_TAX_DETAIL_REC  IN  ASO_QUOTE_PUB.Tax_Detail_Rec_Type := ASO_QUOTE_PUB.G_MISS_Tax_Detail_Rec,
P_TEMPLATE_TBL           IN  ASO_QUOTE_PUB.TEMPLATE_TBL_TYPE   := ASO_QUOTE_PUB.G_MISS_TEMPLATE_TBL,
P_OPP_QTE_IN_REC         IN  OPP_QTE_IN_REC_TYPE,
P_CONTROL_REC            IN  ASO_QUOTE_PUB.Control_Rec_Type    := ASO_QUOTE_PUB.G_MISS_Control_Rec,
X_OPP_QTE_OUT_REC        OUT NOCOPY /* file.sql.39 change */ OPP_QTE_OUT_REC_TYPE,
X_RETURN_STATUS          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
X_MSG_COUNT              OUT NOCOPY /* file.sql.39 change */ NUMBER,
X_MSG_DATA               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

G_USER_ID                    NUMBER  := FND_GLOBAL.USER_ID;
G_LOGIN_ID                   NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;

L_API_NAME                   VARCHAR2(50) := 'Create_Qte_Opportunity';
L_API_VERSION    CONSTANT    NUMBER := 1.0;

l_line_count                 NUMBER;
l_ln_shipment_count          NUMBER;
l_ln_sales_credit_count      NUMBER;
l_ln_price_attr_count        NUMBER;

l_serv_item_flag             VARCHAR2(1);
l_dtl_line_count             NUMBER;
l_serv_duraion               Number;
l_serv_period                VARCHAR2(3);

l_cust_account_id            NUMBER := P_OPP_QTE_IN_REC.cust_account_id;
l_conc_segments              VARCHAR2(40);

l_copy_notes_flag            VARCHAR2(1);
l_copy_task_flag             VARCHAR2(1);
l_copy_att_flag              VARCHAR2(1);

-- Variables to hold values to be passed to ASO_VALIDATE_PRICING_PVT.Validate_Pricing_Order()
l_pricing_control_rec        ASO_PRICING_INT.Pricing_Control_Rec_Type ;
lp_ln_price_attributes_tbl   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                             := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;
lp_ln_shipment_tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Shipment_Tbl;
lp_ln_sales_credit_tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_type := ASO_QUOTE_PUB.G_Miss_Sales_Credit_Tbl;
lpx_Qte_Header_Rec           ASO_QUOTE_PUB.Qte_Header_Rec_Type;
lpx_Qte_Line_Tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
lpx_Qte_Line_Dtl_Tbl         ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
lpx_Price_Adjustment_Tbl     ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
lpx_Price_Adj_Attr_Tbl       ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
lpx_Price_Adj_Rltship_Tbl    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

-- Variables to hold values to be passed to ASO_QUOTE_PUB.Create_Quote()
l_control_rec                ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec;
l_qte_header_rec             ASO_QUOTE_PUB.Qte_Header_Rec_type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
l_hd_price_attributes_tbl    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;
l_hd_Payment_Tbl             ASO_QUOTE_PUB.Payment_Tbl_Type := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
l_hd_Shipment_Rec            ASO_QUOTE_PUB.Shipment_Rec_Type := ASO_QUOTE_PUB.G_Miss_Shipment_rec;
l_qte_line_tbl               ASO_QUOTE_PUB.Qte_Line_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Qte_Line_Tbl;
l_qte_line_dtl_tbl           ASO_QUOTE_PUB.Qte_Line_dtl_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Qte_Line_dtl_Tbl;
l_ln_price_attributes_tbl    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                             := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;
l_ln_shipment_tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Shipment_Tbl;
l_ln_sales_credit_tbl        ASO_QUOTE_PUB.Sales_Credit_Tbl_type := ASO_QUOTE_PUB.G_Miss_Sales_Credit_Tbl;
lx_Qte_Header_Rec            ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
lx_out_Qte_Header_Rec        ASO_QUOTE_PUB.Qte_Header_Rec_Type;
lx_Qte_Line_Tbl              ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
lx_Qte_Line_Dtl_Tbl          ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
lx_Hd_Price_Attributes_Tbl   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_Hd_Payment_Tbl            ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_Hd_Shipment_Tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_Hd_Shipment_Rec           ASO_QUOTE_PUB.Shipment_Rec_Type;
lx_Hd_Freight_Charge_Tbl     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_Hd_Tax_Detail_Tbl         ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
lx_Hd_Attr_Ext_tbl           ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_Hd_Sales_Credit_Tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lx_Hd_Quote_Party_tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lx_Line_Attr_Ext_Tbl         ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_Line_Rltship_tbl          ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
lx_Price_Adjustment_Tbl      ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
lx_Price_Adj_Attr_Tbl        ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
lx_Price_Adj_Rltship_Tbl     ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
lx_Ln_Price_Attributes_Tbl   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_Ln_Payment_Tbl            ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_Ln_Shipment_Tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_Ln_Freight_Charge_Tbl     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_Ln_Tax_Detail_Tbl         ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
lx_Ln_Sales_Credit_Tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lx_Ln_Quote_Party_tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lx_Qte_Template_Tbl          ASO_QUOTE_PUB.Template_Tbl_Type;
l_last_update_date           Date;
l_Related_Obj_Tbl            ASO_QUOTE_PUB.Related_Obj_Tbl_Type;
lx_Related_Obj_Tbl           ASO_QUOTE_PUB.Related_Obj_Tbl_Type;

-- Variables for creating object relationship between opportunity and quote
l_related_obj_rec            ASO_QUOTE_PUB.Related_Obj_Rec_Type := ASO_QUOTE_PUB.G_MISS_RELATED_OBJ_REC;
lx_related_object_id         NUMBER;
l_payment_term_id            NUMBER;

-- Variables for Sales Team (Security)
l_qte_access_rec             ASO_QUOTE_PUB.Qte_Access_Rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_ACCESS_REC;
l_qte_access_tbl             ASO_QUOTE_PUB.Qte_Access_Tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_ACCESS_TBL;
lx_qte_access_tbl            ASO_QUOTE_PUB.Qte_Access_Tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_ACCESS_TBL;
l_primary_uom_code           VARCHAR2(3);

-- Dummy Variable
l_dummy                      VARCHAR(1) := NULL;
l_party_type                 VARCHAR2(30);
l_party_site_id              Number;
x_valid                      VARCHAR(1);

-- Recurring charges Change
l_charge_periodicity_code    VARCHAR(3);


l_def_control_rec            ASO_DEFAULTING_INT.Control_Rec_Type := ASO_DEFAULTING_INT.G_MISS_CONTROL_REC;
l_db_object_name             VARCHAR2(30);
l_hd_payment_rec             ASO_QUOTE_PUB.Payment_Rec_Type := ASO_QUOTE_PUB.G_MISS_Payment_REC;
l_hd_tax_detail_rec          ASO_QUOTE_PUB.Tax_Detail_Rec_Type := ASO_QUOTE_PUB.G_MISS_Tax_Detail_REC;
l_hd_misc_rec                ASO_DEFAULTING_INT.Header_Misc_Rec_Type
                             := ASO_DEFAULTING_INT.G_MISS_HEADER_MISC_REC;
lx_hd_payment_rec            ASO_QUOTE_PUB.Payment_Rec_Type;
lx_hd_tax_detail_rec         ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
lx_hd_misc_rec               ASO_DEFAULTING_INT.Header_Misc_Rec_Type;
lx_quote_line_rec            ASO_QUOTE_PUB.Qte_Line_Rec_Type;
lx_ln_misc_rec               ASO_DEFAULTING_INT.Line_Misc_Rec_Type;
lx_ln_shipment_rec           ASO_QUOTE_PUB.Shipment_Rec_Type;
lx_ln_payment_rec            ASO_QUOTE_PUB.Payment_Rec_Type;
lx_ln_tax_detail_rec         ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
lx_changed_flag              VARCHAR2(1);
l_hd_tax_detail_tbl	         ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

l_header_Shipment_Rec        ASO_QUOTE_PUB.Shipment_Rec_Type := ASO_QUOTE_PUB.G_Miss_Shipment_rec;
l_header_Payment_Tbl         ASO_QUOTE_PUB.Payment_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
l_header_Tax_Detail_Tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Tax_Detail_Tbl;


-- Cursors to fetch data from OSO Tables

-- AS_LEADS_ALL
CURSOR C_lead (p_lead_id NUMBER) IS
SELECT offer_id
FROM as_leads_all
WHERE lead_id = p_lead_id;

l_lead_rec                    c_lead%ROWTYPE;

-- AS_LEAD_LINES_ALL
CURSOR C_lead_line (p_lead_id NUMBER) IS
SELECT lead_line_id,
       inventory_item_id,
       organization_id,
       uom_code,
       NVL(quantity, 1) quantity,
       offer_id,
       forecast_date
FROM as_lead_lines_all
WHERE lead_id = p_lead_id
AND inventory_item_id IS NOT NULL
AND organization_id IS NOT NULL;

-- AS_SALES_CREDITS
CURSOR C_sales_credits (p_lead_id NUMBER, p_lead_line_id NUMBER) IS
SELECT salesforce_id,
       salesgroup_id,
       credit_type_id,
       credit_percent
FROM as_sales_credits
WHERE lead_id = p_lead_id
AND lead_line_id = p_lead_line_id;

CURSOR C_phone (p_party_id number) is
SELECT contact_point_id
FROM hz_contact_points
WHERE owner_table_id = p_party_id
AND owner_table_name = 'HZ_PARTIES'
AND contact_point_type = 'PHONE'
AND status = 'A'
AND primary_flag = 'Y';

CURSOR C_campaign_id (l_sc_id NUMBER) IS
SELECT source_code_for_id
FROM ams_source_codes
WHERE source_code_id = l_sc_id;

CURSOR c_conc_segments (l_inventory_item_id NUMBER) IS
SELECT concatenated_segments
FROM MTL_SYSTEM_ITEMS_VL
WHERE inventory_item_id = l_inventory_item_id;

CURSOR C_sales_team (l_lead_id NUMBER) IS
SELECT salesforce_id,
       sales_group_id,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       freeze_flag,
       team_leader_flag,
       created_by_tap_flag,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15
FROM AS_ACCESSES_ALL
WHERE lead_id = l_lead_id;

-- bug 5534788, fixed cursor so that freeze flag
-- is carried over from opp to qte correctly
Cursor C_opp_owner(p_lead_id NUMBER,p_qte_number Number) IS
SELECT a.freeze_flag,c.access_id
FROM AS_ACCESSES_ALL a, ASO_QUOTE_HEADERS_ALL B,aso_quote_accesses c
WHERE a.lead_id = p_lead_id
AND b.quote_number = p_qte_number
AND a.salesforce_id = c.resource_id
AND b.quote_number =c.quote_number;

CURSOR c_base_valid(p_item_id IN Number,p_organization_id IN Number) IS
SELECT primary_uom_code
FROM MTL_SYSTEM_ITEMS_B
WHERE inventory_item_id = p_item_id
AND organization_id = p_organization_id;

CURSOR c_pay_term_aggrement(p_agreement_id IN Number) IS
SELECT term_id
FROM   oe_agreements
WHERE  agreement_id = p_agreement_id;

CURSOR c_pay_term_acct(p_cust_account_id IN Number) IS
SELECT hcp.standard_terms
FROM hz_cust_accounts hca,hz_customer_profiles hcp
WHERE  hca.cust_account_id = p_cust_account_id
AND hcp.cust_account_id = hca.cust_account_id
AND    nvl(hcp.status,'A') = 'A';

CURSOR c_primary_address(p_party_id IN Number,p_site_use_type VARCHAR2) IS
SELECT   hps.party_site_id
FROM     hz_party_sites hps, hz_party_site_uses hpsu
WHERE    hps.party_id= p_party_id
AND      hps.status='A'
AND      hps.party_site_id= hpsu.party_site_id
AND      hpsu.site_use_type= p_site_use_type
AND      hpsu.primary_per_type='Y'
AND      hpsu.status='A';

CURSOR c_identifying_address(p_party_id IN Number) IS
SELECT party_site_id
FROM   hz_party_sites
WHERE  party_id= p_party_id
AND    status='A'
AND    identifying_address_flag='Y';

-- Recurring charges Change

CURSOR c_periodicity(p_inventory_item_id IN Number, p_organization_id IN Number) IS
SELECT charge_periodicity_code
FROM   mtl_system_items_b
WHERE  inventory_item_id = p_inventory_item_id
AND    organization_id = p_organization_id;

CURSOR c_serv_item (l_inventory_item_id NUMBER, l_organization_id NUMBER) IS
SELECT service_item_flag,service_duration,service_duration_period_code
FROM MTL_SYSTEM_ITEMS_VL
WHERE inventory_item_id = l_inventory_item_id
AND organization_id = l_organization_id
AND customer_order_enabled_flag = 'Y'
AND bom_item_type <> 2
AND NVL(start_date_active, SYSDATE) <= SYSDATE
AND NVL(end_date_active, SYSDATE) >= SYSDATE;

l_master_organization_id NUMBER;
l_profile_val varchar2(30) := null;
l_add_service varchar2(1);
l_add_line    varchar2(1);
def_context1 varchar2(30);

-- start Bug 19944384
Cursor def_context is
select DEFAULT_CONTEXT_VALUE
from FND_DESCRIPTIVE_FLEXS
where APPLICATION_ID=697
and DESCRIPTIVE_FLEXFIELD_NAME LIKE 'ASO_LINE_ATTRIBUTES';
-- End Bug 19944384

BEGIN

-- Standard Start of API savepoint
SAVEPOINT Create_Qte_Opportunity_pub;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('****** Start of Create_Qte_Opportunity API ******', 1, 'Y');
END IF;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call(
   L_API_VERSION,
   P_API_VERSION_NUMBER,
   L_API_NAME,
   G_PKG_NAME
) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.To_Boolean(p_init_msg_list) THEN
   FND_Msg_Pub.initialize;
END IF;

--Procedure added by Anoop Rajan on 30/09/2005 to print login details
IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Before call to printing login info details', 1, 'Y');
	ASO_UTILITY_PVT.print_login_info;
	aso_debug_pub.add('After call to printing login info details', 1, 'Y');
END IF;

-- Change Done By Girish
-- Procedure added to validate the operating unit
ASO_VALIDATE_PVT.VALIDATE_OU(P_Quote_Header_Rec);


-- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

--defaulting framework begin

l_qte_header_rec := P_Quote_Header_Rec;
l_control_rec    := p_control_rec;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Create_Qte_Opportunity - before defaulting framework', 1, 'Y');
   aso_debug_pub.add('Create_Qte_Opportunity - populate defaulting control record from header control record',
                      1, 'Y');
END IF ;

--Yogeshwar(MOAC)
if (l_qte_header_rec.CUST_PARTY_ID IS NULL OR l_qte_header_rec.CUST_PARTY_ID = FND_API.G_MISS_NUM ) THEN
    l_qte_header_rec.ORG_ID := P_OPP_QTE_IN_REC.ORG_ID;
 End if;
--Yogeshwar(MOAC)


l_def_control_rec.Dependency_Flag := FND_API.G_FALSE;
l_def_control_rec.Defaulting_Flag := l_control_rec.Defaulting_Flag;
l_def_control_rec.Application_Type_Code := l_control_rec.Application_Type_Code;
l_def_control_rec.Defaulting_Flow_Code := 'CREATE';

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Defaulting_Fwk_Flag - '||l_control_rec.Defaulting_Fwk_Flag, 1, 'Y');
   aso_debug_pub.add('Dependency_Flag - '||l_def_control_rec.Dependency_Flag, 1, 'Y');
   aso_debug_pub.add('Defaulting_Flag - '||l_def_control_rec.Defaulting_Flag, 1, 'Y');
   aso_debug_pub.add('Application_Type_Code - '||l_def_control_rec.Application_Type_Code, 1, 'Y');
   aso_debug_pub.add('Defaulting_Flow_Code - '||l_def_control_rec.Defaulting_Flow_Code, 1, 'Y');
END IF ;

IF l_def_control_rec.application_type_code = 'QUOTING HTML'
   OR  l_def_control_rec.application_type_code = 'QUOTING FORM' THEN
       l_db_object_name := ASO_QUOTE_HEADERS_PVT.G_QUOTE_HEADER_DB_NAME;
ELSE
       l_control_rec.Defaulting_Fwk_Flag := 'N';
END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Create_Qte_Opportunity - Pick '||l_db_object_name
                      ||' based on calling application '||l_def_control_rec.application_type_code, 1, 'Y');
END IF ;

/*
-- In create quote, it never deaults any line level records.
IF l_control_rec.defaulting_fwk_flag = 'Y' THEN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Create_Qte_Opportunity - Calling default_entity', 1, 'Y');
    END IF ;

    ASO_DEFAULTING_INT.Default_Entity (
      p_api_version           =>  1.0
    , p_control_rec           =>  l_def_control_rec
    , p_database_object_name  =>  l_db_object_name
    , p_quote_header_rec      =>  P_Quote_Header_Rec
    , p_header_misc_rec       =>  l_hd_misc_rec
    , p_header_shipment_rec   =>  P_header_shipment_rec
    , p_header_payment_rec    =>  P_header_payment_rec
    , p_header_tax_detail_rec =>  P_header_tax_detail_rec
    , x_quote_header_rec      =>  lx_qte_header_rec
    , x_header_misc_rec       =>  lx_hd_misc_rec
    , x_header_shipment_rec   =>  lx_hd_shipment_rec
    , x_header_payment_rec    =>  lx_hd_payment_rec
    , x_header_tax_detail_rec =>  lx_hd_tax_detail_rec
    , x_quote_line_rec        =>  lx_quote_line_rec
    , x_line_misc_rec         =>  lx_ln_misc_rec
    , x_line_shipment_rec     =>  lx_ln_shipment_rec
    , x_line_payment_rec      =>  lx_ln_payment_rec
    , x_line_tax_detail_rec   =>  lx_ln_tax_detail_rec
    , x_changed_flag          =>  lx_changed_flag
    , x_return_status	      =>  x_return_status
    , x_msg_count		      =>  x_msg_count
    , x_msg_data		      =>  x_msg_data
    );

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_DEFAULTING');
          FND_MSG_PUB.ADD;
       END IF;

       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    l_qte_header_rec := lx_qte_header_rec;

    IF ASO_QUOTE_HEADERS_PVT.Shipment_Null_Rec_Exists(lx_hd_shipment_rec, l_db_object_name) THEN
      l_hd_shipment_rec := lx_hd_shipment_rec;
      l_hd_shipment_rec.operation_code := 'CREATE';
    END IF;

    IF ASO_QUOTE_HEADERS_PVT.Payment_Null_Rec_Exists(lx_hd_payment_rec, l_db_object_name) THEN
       l_hd_Payment_Tbl(1) := lx_hd_payment_rec;
       l_hd_Payment_Tbl(1).operation_code := 'CREATE';
    END IF;

    IF ASO_QUOTE_HEADERS_PVT.Tax_Detail_Null_Rec_Exists(lx_hd_tax_detail_rec, l_db_object_name) THEN
       l_hd_tax_detail_tbl(1) := lx_hd_tax_detail_rec;
       l_hd_tax_detail_tbl(1).operation_code := 'CREATE';
    END IF;

END IF;
*/
-- defaulting framework end

   l_hd_shipment_rec := P_header_shipment_rec;
   l_hd_Payment_Tbl(1) := P_header_payment_rec;

   IF aso_utility_pvt.tax_rec_exists(P_header_tax_detail_rec) then
      l_hd_tax_detail_tbl(1) := P_header_tax_detail_rec;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_OPP_QTE_PUB: Assigning the header tax record',1,'N');
         aso_debug_pub.add('ASO_OPP_QTE_PUB: Header tax_exempt_flag: '||P_header_tax_detail_rec.tax_exempt_flag,1,'N');
      END IF ;
   end if;

-- API body
FOR l_lead_rec IN c_lead(P_OPP_QTE_IN_REC.OPPORTUNITY_ID) LOOP

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.OPPORTUNITY_ID:'
	                     ||P_OPP_QTE_IN_REC.OPPORTUNITY_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.QUOTE_NUMBER:'
	                     ||P_OPP_QTE_IN_REC.QUOTE_NUMBER, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.QUOTE_NAME:'
	                     ||P_OPP_QTE_IN_REC.QUOTE_NAME, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.CUST_ACCOUNT_ID:'
	                     ||P_OPP_QTE_IN_REC.CUST_ACCOUNT_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.RESOURCE_ID:'
	                     ||P_OPP_QTE_IN_REC.RESOURCE_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.SOLD_TO_CONTACT_ID:'
	                     ||P_OPP_QTE_IN_REC.SOLD_TO_CONTACT_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.SOLD_TO_PARTY_SITE_ID:'
	                     ||P_OPP_QTE_IN_REC.SOLD_TO_PARTY_SITE_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.PRICE_LIST_ID:'
	                     ||P_OPP_QTE_IN_REC.PRICE_LIST_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.RESOURCE_GRP_ID:'
	                     ||P_OPP_QTE_IN_REC.RESOURCE_GRP_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.CHANNEL_CODE:'
	                     ||P_OPP_QTE_IN_REC.CHANNEL_CODE, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.ORDER_TYPE_ID:'
	                     ||P_OPP_QTE_IN_REC.ORDER_TYPE_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.AGREEMENT_ID:'
	                     ||P_OPP_QTE_IN_REC.AGREEMENT_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.CONTRACT_TEMPLATE_ID:'
	                     ||P_OPP_QTE_IN_REC.CONTRACT_TEMPLATE_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.CONTRACT_TEMPLATE_MAJOR_VER:'
	                     ||P_OPP_QTE_IN_REC.CONTRACT_TEMPLATE_MAJOR_VER, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.CURRENCY_CODE:'
	                     ||P_OPP_QTE_IN_REC.CURRENCY_CODE, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.MARKETING_SOURCE_CODE_ID:'
	                     ||P_OPP_QTE_IN_REC.MARKETING_SOURCE_CODE_ID, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: l_lead_rec.offer_id:'||l_lead_rec.offer_id, 1, 'N');
    END IF;


    -- Set Control Record
    l_control_rec.pricing_request_type           := 'ASO';

    if p_control_rec.header_pricing_event = 'PRICE' then
       l_control_rec.header_pricing_event    := 'ORDER';
    else
       l_control_rec.header_pricing_event    := 'BATCH';
    end if;

    l_control_rec.price_mode  := 'ENTIRE_QUOTE';
    l_control_rec.quote_source := 'OPP_QUOTE';
    l_qte_header_rec.quote_source_code := P_SOURCE_CODE;

    IF l_control_rec.defaulting_fwk_flag <> 'Y' THEN
       l_qte_header_rec.quote_number                 := P_OPP_QTE_IN_REC.quote_number;
       l_qte_header_rec.resource_id                  := P_OPP_QTE_IN_REC.resource_id;
       l_qte_header_rec.price_list_id                := P_OPP_QTE_IN_REC.price_list_id;
       l_qte_header_rec.resource_grp_id              := P_OPP_QTE_IN_REC.resource_grp_id;
       l_qte_header_rec.order_type_id                := P_OPP_QTE_IN_REC.order_type_id;
       l_qte_header_rec.contract_id                  := P_OPP_QTE_IN_REC.agreement_id;
       l_qte_header_rec.contract_template_id         := P_OPP_QTE_IN_REC.contract_template_id;
       l_qte_header_rec.contract_template_major_ver  := P_OPP_QTE_IN_REC.contract_template_major_ver;
	  l_qte_header_rec.QUOTE_EXPIRATION_DATE        := P_OPP_QTE_IN_REC.QUOTE_EXPIRATION_DATE;

       IF P_OPP_QTE_IN_REC.quote_name <> FND_API.G_MISS_CHAR THEN
          l_qte_header_rec.quote_name               := P_OPP_QTE_IN_REC.quote_name;
       END IF;

       IF P_OPP_QTE_IN_REC.sold_to_contact_id <> FND_API.G_MISS_NUM THEN
          l_qte_header_rec.party_id := P_OPP_QTE_IN_REC.sold_to_contact_id;
       Else
          l_qte_header_rec.party_id := P_OPP_QTE_IN_REC.cust_party_id;
       END IF;

    END IF;

    -- Phone # population
    IF l_control_rec.defaulting_fwk_flag <> 'Y' THEN
       IF l_qte_header_rec.party_id <> FND_API.G_MISS_NUM THEN
          FOR l_phone_rec IN C_phone(l_qte_header_rec.party_id) LOOP
              l_qte_header_rec.phone_id             := l_phone_rec.contact_point_id;
          END LOOP;
        END IF;

        IF P_OPP_QTE_IN_REC.sold_to_party_site_id <> FND_API.G_MISS_NUM THEN
           Address_Validation(
                    p_party_site_id     =>    P_OPP_QTE_IN_REC.sold_to_party_site_id ,
                    p_use_type          =>    'SOLD_TO',
                    x_valid             =>    x_valid,
                    X_RETURN_STATUS     =>    X_RETURN_STATUS,
                    X_MSG_COUNT         =>    X_MSG_COUNT,
                    X_MSG_DATA          =>    X_MSG_DATA) ;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
	         aso_debug_pub.add('ASO_OPP_QTE_PUB: sold_to_party_site_id:'
		                       ||P_OPP_QTE_IN_REC.sold_to_party_site_id, 1, 'N');
              aso_debug_pub.add('ASO_OPP_QTE_PUB: valid flag:Sold_To:'||x_valid, 1, 'N');
	      END IF;


           IF x_valid = 'Y' THEN
	         l_qte_header_rec.sold_to_party_site_id := P_OPP_QTE_IN_REC.sold_to_party_site_id;
           ELSE
              l_qte_header_rec.sold_to_party_site_id := FND_API.G_MISS_NUM;
           END IF;

	   END IF;

        IF P_OPP_QTE_IN_REC.channel_code <> FND_API.G_MISS_CHAR THEN
            l_qte_header_rec.sales_channel_code := P_OPP_QTE_IN_REC.channel_code;
        END IF;

        IF P_OPP_QTE_IN_REC.currency_code <> FND_API.G_MISS_CHAR THEN
            l_qte_header_rec.currency_code := P_OPP_QTE_IN_REC.currency_code;
        END IF;

        IF P_OPP_QTE_IN_REC.marketing_source_code_id <> FND_API.G_MISS_NUM THEN
            l_qte_header_rec.marketing_source_code_id := P_OPP_QTE_IN_REC.marketing_source_code_id;
        END IF;

        IF P_OPP_QTE_IN_REC.PRICING_STATUS_INDICATOR <> FND_API.G_MISS_CHAR THEN
            l_qte_header_rec.PRICING_STATUS_INDICATOR := P_OPP_QTE_IN_REC.PRICING_STATUS_INDICATOR;
        END IF;

        IF P_OPP_QTE_IN_REC.TAX_STATUS_INDICATOR <> FND_API.G_MISS_CHAR THEN
            l_qte_header_rec.TAX_STATUS_INDICATOR := P_OPP_QTE_IN_REC.TAX_STATUS_INDICATOR;
        END IF;

        IF P_OPP_QTE_IN_REC.PRICE_UPDATED_DATE <>  FND_API.G_MISS_DATE THEN
            l_qte_header_rec.PRICE_UPDATED_DATE := P_OPP_QTE_IN_REC.PRICE_UPDATED_DATE;
        END IF;

        IF P_OPP_QTE_IN_REC.TAX_UPDATED_DATE <>  FND_API.G_MISS_DATE THEN
            l_qte_header_rec.TAX_UPDATED_DATE := P_OPP_QTE_IN_REC.TAX_UPDATED_DATE;
        END IF;


        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.quote_header_id:'
		                    || l_qte_header_rec.quote_header_id, 1, 'N');
	      aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.quote_source_code:'
	                         || l_qte_header_rec.quote_source_code, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.quote_number:'
		                    || l_qte_header_rec.quote_number, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.resource_id:'
		                    || l_qte_header_rec.resource_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.price_list_id:'
		                    || l_qte_header_rec.price_list_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.resource_grp_id:'
		                    || l_qte_header_rec.resource_grp_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.order_type_id:'
		                    || l_qte_header_rec.order_type_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.contract_id:'
		                    || l_qte_header_rec.contract_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.contract_template_id:'
		                    || l_qte_header_rec.contract_template_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.contract_template_major_ver: '
		                    || l_qte_header_rec.contract_template_major_ver, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.quote_name:'
		                    || l_qte_header_rec.quote_name, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.party_id:'
		                    || l_qte_header_rec.party_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.phone_id:'
		                    || l_qte_header_rec.phone_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.cust_account_id:'
		                    || l_qte_header_rec.cust_account_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.sold_to_party_site_id:'
		                    || l_qte_header_rec.sold_to_party_site_id, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.sales_channel_code:'
		                    || l_qte_header_rec.sales_channel_code, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.currency_code:'
		                    || l_qte_header_rec.currency_code, 1, 'N');
           aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_header_rec.marketing_source_code_id:'
		                    || l_qte_header_rec.marketing_source_code_id, 1, 'N');
	   END IF;

        l_qte_header_rec.cust_party_id              := P_OPP_QTE_IN_REC.cust_party_id ;
        l_qte_header_rec.invoice_to_cust_party_id   := P_OPP_QTE_IN_REC.cust_party_id ;

        IF P_OPP_QTE_IN_REC.cust_party_id <> FND_API.G_MISS_NUM
	      AND P_OPP_QTE_IN_REC.cust_party_id IS NOT NULL THEN
           l_hd_Shipment_Rec.operation_code            := 'CREATE' ;
           l_hd_Shipment_Rec.ship_to_cust_party_id     := P_OPP_QTE_IN_REC.cust_party_id ;
        END IF;

        OPEN c_pay_term_aggrement(P_OPP_QTE_IN_REC.agreement_id);
        FETCH c_pay_term_aggrement INTO l_payment_term_id;

        IF  c_pay_term_aggrement%NOTFOUND THEN
            OPEN  c_pay_term_acct(P_OPP_QTE_IN_REC.CUST_ACCOUNT_ID);
            FETCH c_pay_term_acct INTO l_payment_term_id;
            IF  c_pay_term_acct%NOTFOUND THEN
                l_payment_term_id := null;
            end  if;
            close c_pay_term_acct;
        END IF;
        close c_pay_term_aggrement;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	      aso_debug_pub.add('ASO_OPP_QTE_PUB: payment_term_id:'||l_payment_term_id, 1, 'N');
	   END IF;

        IF l_payment_term_id <> FND_API.G_MISS_NUM and l_payment_term_id IS NOT NULL THEN
           l_hd_Payment_Tbl(1).operation_code              := 'CREATE';
           l_hd_Payment_Tbl(1).payment_term_id             := l_payment_term_id;
        END IF;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	      aso_debug_pub.add('ASO_OPP_QTE_PUB: P_OPP_QTE_IN_REC.cust_party_id:'
		                    ||P_OPP_QTE_IN_REC.cust_party_id, 1, 'N');
	   END IF;

        IF P_OPP_QTE_IN_REC.cust_party_id <> FND_API.G_MISS_NUM
	      AND P_OPP_QTE_IN_REC.cust_party_id IS NOT NULL THEN
           OPEN  c_primary_address(P_OPP_QTE_IN_REC.cust_party_id,'BILL_TO');
           FETCH c_primary_address INTO l_party_site_id;

          IF  c_primary_address%NOTFOUND THEN
              OPEN  c_identifying_address(P_OPP_QTE_IN_REC.cust_party_id);
              FETCH c_identifying_address INTO l_party_site_id;
              IF  c_identifying_address%NOTFOUND THEN
                  l_party_site_id := null;
              END  IF;
              close c_identifying_address;
          END IF;
          close c_primary_address;
        END IF;

        IF l_party_site_id <> FND_API.G_MISS_NUM and l_party_site_id IS NOT NULL THEN
           Address_Validation(
                      p_party_site_id     =>    l_party_site_id ,
                      p_use_type          =>    'BILL_TO',
                      x_valid             =>    x_valid,
                      X_RETURN_STATUS     =>    X_RETURN_STATUS,
                      X_MSG_COUNT         =>    X_MSG_COUNT,
                      X_MSG_DATA          =>    X_MSG_DATA) ;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
	         aso_debug_pub.add('ASO_OPP_QTE_PUB: invoice_to_party_site_id:'||l_party_site_id, 1, 'N');
              aso_debug_pub.add('ASO_OPP_QTE_PUB: valid flag:Invoice_To:'||x_valid, 1, 'N');
	      END IF;

           IF x_valid = 'Y' THEN
		    l_qte_header_rec.invoice_to_party_site_id := l_party_site_id;
           else
		    l_qte_header_rec.invoice_to_party_site_id := FND_API.G_MISS_NUM;
           end if;

        END IF;

        IF P_OPP_QTE_IN_REC.cust_party_id <> FND_API.G_MISS_NUM
	      AND P_OPP_QTE_IN_REC.cust_party_id IS NOT NULL THEN
               OPEN  c_primary_address(P_OPP_QTE_IN_REC.cust_party_id,'SHIP_TO');
               FETCH c_primary_address INTO l_party_site_id;

               IF  c_primary_address%NOTFOUND THEN
                   OPEN  c_identifying_address(P_OPP_QTE_IN_REC.cust_party_id);
                   FETCH c_identifying_address INTO l_party_site_id;
                   IF  c_identifying_address%NOTFOUND THEN
                       l_party_site_id := null;
                   end  if;
                   close c_identifying_address;
               end if;
               close c_primary_address;
        END IF;

        IF l_party_site_id <> FND_API.G_MISS_NUM and l_party_site_id IS NOT NULL THEN
           l_hd_Shipment_Rec.operation_code := 'CREATE';
           Address_Validation(
                   p_party_site_id     =>    l_party_site_id,
                   p_use_type          =>    'SHIP_TO',
                   x_valid             =>    x_valid,
                   X_RETURN_STATUS     =>    X_RETURN_STATUS,
                   X_MSG_COUNT         =>    X_MSG_COUNT,
                   X_MSG_DATA          =>    X_MSG_DATA);


            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	          aso_debug_pub.add('ASO_OPP_QTE_PUB: ship_to_party_site_id :'||l_party_site_id, 1, 'N');
               aso_debug_pub.add('ASO_OPP_QTE_PUB: valid flag:Ship_To:'||x_valid, 1, 'N');
	       END IF;

            IF x_valid = 'Y' THEN
	          l_hd_Shipment_Rec.ship_to_party_site_id := l_party_site_id;
            else
	          l_hd_Shipment_Rec.ship_to_party_site_id := FND_API.G_MISS_NUM;
            end if;
        END IF;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	      aso_debug_pub.add('ASO_OPP_QTE_PUB: ship_to_party_site_id:'||l_party_site_id, 1, 'N');
	   END IF;

        IF P_OPP_QTE_IN_REC.CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM THEN
            l_qte_header_rec.cust_account_id := P_OPP_QTE_IN_REC.CUST_ACCOUNT_ID;
            l_qte_header_rec.invoice_to_cust_account_id := P_OPP_QTE_IN_REC.CUST_ACCOUNT_ID;
            l_hd_Shipment_Rec.operation_code := 'CREATE' ;
            l_hd_Shipment_Rec.ship_to_cust_account_id := P_OPP_QTE_IN_REC.CUST_ACCOUNT_ID;
        END IF;

    END IF;


    IF l_lead_rec.offer_id IS NOT NULL AND l_lead_rec.offer_id <> FND_API.G_MISS_NUM THEN
       FOR l_campaign_rec IN C_campaign_id(l_lead_rec.offer_id) LOOP
           l_hd_price_attributes_tbl(1).operation_code     := 'CREATE';
           l_hd_price_attributes_tbl(1).pricing_context    := 'MODLIST';
           l_hd_price_attributes_tbl(1).flex_title         := 'QP_ATTR_DEFNS_QUALIFIER';
           l_hd_price_attributes_tbl(1).pricing_attribute1 := l_campaign_rec.source_code_for_id;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('ASO_OPP_QTE_PUB: l_hd_price_attributes_tbl(1).pricing_attribute1: '
		                       || l_hd_price_attributes_tbl(1).pricing_attribute1, 1, 'N');
		 END IF;
       END LOOP;
    END IF;

    If l_control_rec.defaulting_fwk_flag = 'Y' then
       IF l_qte_header_rec.sold_to_party_site_id <> FND_API.G_MISS_NUM THEN
          Address_Validation(
                  p_party_site_id     =>    l_qte_header_rec.sold_to_party_site_id ,
                  p_use_type          =>    'SOLD_TO',
                  x_valid             =>    x_valid,
                  X_RETURN_STATUS     =>    X_RETURN_STATUS,
                  X_MSG_COUNT         =>    X_MSG_COUNT,
                  X_MSG_DATA          =>    X_MSG_DATA);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        aso_debug_pub.add('ASO_OPP_QTE_PUB: sold_to_party_site_id:'
		                      ||l_qte_header_rec.sold_to_party_site_id, 1, 'N');
             aso_debug_pub.add('ASO_OPP_QTE_PUB: valid flag:Sold_To:'||x_valid, 1, 'N');
	     END IF;

          IF x_valid = 'Y' THEN
	        l_qte_header_rec.sold_to_party_site_id := l_qte_header_rec.sold_to_party_site_id;
          else
             l_qte_header_rec.sold_to_party_site_id := FND_API.G_MISS_NUM;
          END IF;

       end if;

       IF l_qte_header_rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM
          AND l_qte_header_rec.invoice_to_party_site_id IS NOT NULL THEN
              Address_Validation(
                   p_party_site_id     =>    l_qte_header_rec.invoice_to_party_site_id ,
                   p_use_type          =>    'BILL_TO',
                   x_valid             =>    x_valid,
                   X_RETURN_STATUS     =>    X_RETURN_STATUS,
                   X_MSG_COUNT         =>    X_MSG_COUNT,
                   X_MSG_DATA          =>    X_MSG_DATA);

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
	            aso_debug_pub.add('ASO_OPP_QTE_PUB: invoice_to_party_site_id:'
		                          ||l_qte_header_rec.invoice_to_party_site_id, 1, 'N');
                 aso_debug_pub.add('ASO_OPP_QTE_PUB: valid flag:Invoice_To:'||x_valid, 1, 'N');
	         END IF;

              IF x_valid = 'Y' THEN
		       l_qte_header_rec.invoice_to_party_site_id    := l_qte_header_rec.invoice_to_party_site_id;
              else
		       l_qte_header_rec.invoice_to_party_site_id    := FND_API.G_MISS_NUM;
              end if;

       END IF;

       IF l_hd_Shipment_Rec.ship_to_party_site_id <> FND_API.G_MISS_NUM
          AND l_hd_Shipment_Rec.ship_to_party_site_id IS NOT NULL THEN
              l_hd_Shipment_Rec.operation_code := 'CREATE' ;
              Address_Validation(
                   p_party_site_id     =>    l_hd_Shipment_Rec.ship_to_party_site_id,
                   p_use_type          =>    'SHIP_TO',
                   x_valid             =>    x_valid,
                   X_RETURN_STATUS     =>    X_RETURN_STATUS,
                   X_MSG_COUNT         =>    X_MSG_COUNT,
                   X_MSG_DATA          =>    X_MSG_DATA);


              IF aso_debug_pub.g_debug_flag = 'Y' THEN
	            aso_debug_pub.add('ASO_OPP_QTE_PUB: ship_to_party_site_id :'
		                          ||l_hd_Shipment_Rec.ship_to_party_site_id, 1, 'N');
                 aso_debug_pub.add('ASO_OPP_QTE_PUB: valid flag:Ship_To:'||x_valid, 1, 'N');
	         END IF;

              IF x_valid = 'Y' THEN
	            l_hd_Shipment_Rec.ship_to_party_site_id := l_hd_Shipment_Rec.ship_to_party_site_id;
              else
	            l_hd_Shipment_Rec.ship_to_party_site_id := FND_API.G_MISS_NUM;
              end if;

       END IF;

    END IF;

    l_related_obj_rec.OPERATION_CODE := 'CREATE';
    l_related_obj_rec.QUOTE_OBJECT_TYPE_CODE := 'HEADER';
    l_related_obj_rec.QUOTE_OBJECT_ID := lx_qte_header_rec.quote_header_id;
    l_related_obj_rec.OBJECT_TYPE_CODE := 'LDID';
    l_related_obj_rec.OBJECT_ID := P_OPP_QTE_IN_REC.OPPORTUNITY_ID;
    l_related_obj_rec.RELATIONSHIP_TYPE_CODE := 'OPP_QUOTE';


    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('ASO_OPP_QTE_PUB: before Create_Object_Relationship: quote_header_id:'
	                     || l_related_obj_rec.QUOTE_OBJECT_ID, 1, 'Y');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: before Create_Object_Relationship: opportunity_id:'
	                     || l_related_obj_rec.OBJECT_ID, 1, 'Y');
    END IF;

    l_Related_Obj_Tbl(l_Related_Obj_Tbl.count+1) := l_related_obj_rec;


    l_line_count            := 0;
    l_ln_shipment_count     := 0;
    l_ln_sales_credit_count := 0;
    l_ln_price_attr_count   := 0;

open def_context;
fetch def_context into def_context1;
exit when def_context %NOTFOUND;

    ASO_QUOTE_PUB.Create_Quote(
            P_Api_Version_Number      => 1.0,
            P_Init_Msg_List           => FND_API.G_FALSE,
            P_Commit                  => FND_API.G_FALSE,
            p_control_rec             => l_control_rec,
            p_qte_header_rec          => l_qte_header_rec,
            P_hd_Price_Attributes_Tbl => l_hd_price_attributes_tbl,
            P_hd_Payment_Tbl          => l_hd_Payment_Tbl,
            P_hd_Shipment_Rec         => l_hd_Shipment_Rec,
            P_hd_tax_detail_Tbl       => l_hd_Tax_Detail_Tbl,
		  P_Related_Obj_Tbl         => l_Related_Obj_Tbl,
            X_Qte_Header_Rec          => lx_Qte_Header_Rec,
            X_Qte_Line_Tbl            => lx_Qte_Line_Tbl,
            X_Qte_Line_Dtl_Tbl        => lx_Qte_Line_Dtl_Tbl,
            X_Hd_Price_Attributes_Tbl => lx_Hd_Price_Attributes_Tbl,
            X_Hd_Payment_Tbl          => lx_Hd_Payment_Tbl,
            X_Hd_Shipment_Rec         => lx_Hd_Shipment_Rec,
            X_Hd_Freight_Charge_Tbl   => lx_Hd_Freight_Charge_Tbl,
            X_Hd_Tax_Detail_Tbl       => lx_Hd_Tax_Detail_Tbl,
            X_Hd_Attr_Ext_tbl         => lx_Hd_Attr_Ext_tbl,
            X_Hd_Sales_Credit_Tbl     => lx_Hd_Sales_Credit_Tbl,
            X_Hd_Quote_Party_Tbl      => lx_Hd_Quote_Party_tbl,
            X_Line_Attr_Ext_Tbl       => lx_Line_Attr_Ext_Tbl,
            X_Line_rltship_tbl        => lx_Line_Rltship_Tbl,
            X_Price_Adjustment_Tbl    => lx_Price_Adjustment_Tbl,
            X_Price_Adj_Attr_Tbl      => lx_Price_Adj_Attr_Tbl,
            X_Price_Adj_Rltship_Tbl   => lx_Price_Adj_Rltship_Tbl,
            X_Ln_Price_Attributes_Tbl => lx_Ln_Price_Attributes_Tbl,
            X_Ln_Payment_Tbl          => lx_Ln_Payment_Tbl,
            X_Ln_Shipment_Tbl         => lx_Ln_Shipment_Tbl,
            X_Ln_Freight_Charge_Tbl   => lx_Ln_Freight_Charge_Tbl,
            X_Ln_Tax_Detail_Tbl       => lx_Ln_Tax_Detail_Tbl,
            X_Ln_Sales_Credit_Tbl     => lx_Ln_Sales_Credit_Tbl,
            X_Ln_Quote_Party_Tbl      => lx_Ln_Quote_Party_tbl,
		  X_Qte_Access_Tbl          => lx_Qte_Access_Tbl,
		  x_Template_Tbl            => lx_Qte_Template_Tbl,
		  x_Related_Obj_Tbl         => lx_Related_Obj_Tbl,
            X_Return_Status           => x_return_status,
            X_Msg_Count               => x_msg_count,
            X_Msg_Data                => x_msg_data
    );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_OPP_QTE_PUB: after Create_Quote: x_return_status: '|| x_return_status, 1, 'Y');
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FOR l_lead_line_rec IN c_lead_line(P_OPP_QTE_IN_REC.OPPORTUNITY_ID) LOOP

        IF (l_lead_line_rec.uom_code IS NULL) OR (l_lead_line_rec.uom_code = FND_API.G_MISS_CHAR) THEN
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('ASO_OPP_QTE_PUB: NO UOM Passed from Opportunity', 1, 'N');
           END IF;

           OPEN c_base_valid(l_lead_line_rec.inventory_item_id,l_lead_line_rec.organization_id);
           FETCH c_base_valid INTO l_primary_uom_code;
           IF  c_base_valid%NOTFOUND THEN
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('ASO_OPP_QTE_PUB:IF c_base_valid%NOTFOUND invitem'
			                      ||l_lead_line_rec.inventory_item_id, 1, 'N');
                  aso_debug_pub.add('ASO_OPP_QTE_PUB: UOM from MTL_SYSTEMS passed to pricing', 1, 'N');
               END IF;

               FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
               FND_MESSAGE.Set_Token('COLUMN', 'UOM_CODE', FALSE);
               FND_MSG_PUB.ADD;
           END IF;
           l_lead_line_rec.uom_code       := l_primary_uom_code;
           close c_base_valid;
        END IF;

        IF Validate_Item(
           p_qte_header_rec    => l_qte_header_rec,
           p_inventory_item_id => l_lead_line_rec.inventory_item_id,
           p_organization_id   => l_lead_line_rec.organization_id,
           p_quantity          => l_lead_line_rec.quantity,
           p_uom_code          => l_lead_line_rec.uom_code) THEN

           l_line_count := l_line_count + 1;
           l_qte_line_tbl(l_line_count).operation_code := 'CREATE';
           l_qte_line_tbl(l_line_count).inventory_item_id := l_lead_line_rec.inventory_item_id;
           l_qte_line_tbl(l_line_count).organization_id := l_lead_line_rec.organization_id;
           l_qte_line_tbl(l_line_count).quantity := l_lead_line_rec.quantity;
           l_qte_line_tbl(l_line_count).uom_code := l_lead_line_rec.uom_code;
		    l_qte_line_tbl(l_line_count).attribute_category:= def_context1;

           -- Recurring charges Change
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('lx_qte_header_rec.org_id: ' || lx_qte_header_rec.org_id);
           END IF;

           l_master_organization_id := oe_sys_parameters.value(param_name => 'MASTER_ORGANIZATION_ID',
		                                                     p_org_id => lx_qte_header_rec.org_id);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('l_master_organization_id: ' || l_master_organization_id);
           END IF;

           OPEN c_periodicity(l_lead_line_rec.inventory_item_id, l_master_organization_id);
           FETCH c_periodicity INTO l_charge_periodicity_code;

           l_qte_line_tbl(l_line_count).charge_periodicity_code := l_charge_periodicity_code;

           IF c_periodicity%NOTFOUND THEN
              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('ASO_OPP_QTE_PUB:IF c_periodicity%NOTFOUND invitem'
			                     ||l_lead_line_rec.inventory_item_id, 1, 'N');
              END IF;
           END IF;
           close c_periodicity;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
		    aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_line_tbl('||l_line_count||').operation_code:'
		                       ||l_qte_line_tbl(l_line_count).operation_code, 1, 'N');
              aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_line_tbl('||l_line_count||').inventory_item_id:'
		                       ||l_qte_line_tbl(l_line_count).inventory_item_id, 1, 'N');
              aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_line_tbl('||l_line_count||').organization_id:'
		                       ||l_qte_line_tbl(l_line_count).organization_id, 1, 'N');
              aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_line_tbl('||l_line_count||').quantity:'
		                       ||l_qte_line_tbl(l_line_count).quantity, 1, 'N');
              aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_line_tbl('||l_line_count||').uom_code:'
		                       ||l_qte_line_tbl(l_line_count).uom_code, 1, 'N');
              aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_line_tbl('||l_line_count||').price_list_id:'
		                       ||l_qte_line_tbl(l_line_count).price_list_id, 1, 'N');
              aso_debug_pub.add('ASO_OPP_QTE_PUB: l_qte_line_tbl('||l_line_count||').charge_periodicity_code:'
		                       ||l_qte_line_tbl(l_line_count).charge_periodicity_code, 1, 'N');
           END IF;


           /* Line level forecast date should not  be mapped to the Request Date Bug (3115703*/
          /* IF l_lead_line_rec.forecast_date IS NOT NULL
		    AND l_lead_line_rec.forecast_date <> FND_API.G_MISS_DATE THEN
                  IF l_lead_line_rec.forecast_date >= SYSDATE THEN
                     l_ln_shipment_count := l_ln_shipment_count + 1;
                     lp_ln_shipment_tbl(l_ln_shipment_count).qte_line_index := l_line_count;
                     lp_ln_shipment_tbl(l_ln_shipment_count).operation_code := 'CREATE';
                     lp_ln_shipment_tbl(l_ln_shipment_count).request_date := l_lead_line_rec.forecast_date;
                  END IF;
           END IF;
         */
           -- Populate Sales Credits
           FOR l_sales_credit_rec IN c_sales_credits(P_OPP_QTE_IN_REC.OPPORTUNITY_ID,
		                                           l_lead_line_rec.lead_line_id) LOOP
               l_ln_sales_credit_count := l_ln_sales_credit_count + 1;
               lp_ln_sales_credit_tbl(l_ln_sales_credit_count).operation_code := 'CREATE';
               lp_ln_sales_credit_tbl(l_ln_sales_credit_count).qte_line_index := l_line_count;
               lp_ln_sales_credit_tbl(l_ln_sales_credit_count).resource_id
			                                           := l_sales_credit_rec.salesforce_id;
               lp_ln_sales_credit_tbl(l_ln_sales_credit_count).resource_group_id
			                                           := l_sales_credit_rec.salesgroup_id;
               lp_ln_sales_credit_tbl(l_ln_sales_credit_count).sales_credit_type_id
			                                           := l_sales_credit_rec.credit_type_id;
               lp_ln_sales_credit_tbl(l_ln_sales_credit_count).percent := l_sales_credit_rec.credit_percent;
           END LOOP;

           -- Populate Price Attributes with Offer ID
           FOR l_campaign_rec IN C_campaign_id(l_lead_line_rec.offer_id) LOOP
               l_ln_price_attr_count := l_ln_price_attr_count + 1;
               lp_ln_price_attributes_tbl(l_ln_price_attr_count).operation_code := 'CREATE';
               lp_ln_price_attributes_tbl(l_ln_price_attr_count).qte_line_index := l_line_count;
               lp_ln_price_attributes_tbl(l_ln_price_attr_count).pricing_context := 'MODLIST';
               lp_ln_price_attributes_tbl(l_ln_price_attr_count).flex_title := 'QP_ATTR_DEFNS_QUALIFIER';
               lp_ln_price_attributes_tbl(l_ln_price_attr_count).pricing_attribute1
			                                                     := l_campaign_rec.source_code_for_id;
           END LOOP;

        END IF; -- Validate Item

    END LOOP; -- Line Loop

    l_pricing_control_rec.request_type  := l_control_rec.pricing_request_type;
    l_pricing_control_rec.pricing_event := l_control_rec.header_pricing_event;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_OPP_QTE_PUB: before Validate_Pricing_Order', 1, 'Y');
    END IF;

    ASO_VALIDATE_PRICING_PVT.Validate_Pricing_Order(
            p_api_version_number       => 1.0,
            p_init_msg_list            => FND_API.G_FALSE,
            p_commit                   => FND_API.G_FALSE,
            p_control_rec              => l_pricing_control_rec,
            p_qte_header_rec           => lx_qte_header_rec,
            p_qte_line_tbl             => l_qte_line_tbl,
            p_ln_shipment_tbl          => lp_ln_shipment_tbl,
            p_ln_price_attr_tbl        => lp_ln_price_attributes_tbl,
            x_qte_header_rec           => lpx_qte_header_rec,
            x_qte_line_tbl             => lpx_qte_line_tbl,
            x_qte_line_dtl_tbl         => lpx_qte_line_dtl_tbl,
            x_price_adj_tbl            => lpx_price_adjustment_tbl,
            x_price_adj_attr_tbl       => lpx_price_adj_attr_tbl,
            x_price_adj_rltship_tbl    => lpx_price_adj_rltship_tbl,
            x_return_status            => x_return_status,
            x_msg_count                => x_msg_count,
            x_msg_data                 => x_msg_data
    );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_OPP_QTE_PUB:  after Validate_Pricing_Order', 1, 'Y');
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_dtl_line_count        := 0;
    l_line_count            := 0;
    l_ln_shipment_count     := 0;
    l_ln_sales_credit_count := 0;
    l_ln_price_attr_count   := 0;
    l_qte_line_tbl          := ASO_QUOTE_PUB.G_Miss_Qte_Line_Tbl;
    l_profile_val           := fnd_profile.value('ASO_REQUIRE_SERVICE_REFERENCE');

    FOR i IN 1..lpx_qte_line_tbl.count LOOP

        IF lpx_qte_line_tbl(i).pricing_status_code <> FND_API.G_RET_STS_SUCCESS THEN
           FOR conc_segments_rec IN c_conc_segments(lpx_qte_line_tbl(i).inventory_item_id) LOOP
               l_conc_segments := conc_segments_rec.concatenated_segments;
           END LOOP;
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('ASO_OPP_QTE_PUB: item has pricing error: '
		                       || lpx_qte_line_tbl(i).pricing_status_text, 1, 'N');
           END IF;

           FND_MESSAGE.Set_Name('ASO', 'ASO_OTQ_INVALID_PRICELIST');
           FND_MESSAGE.Set_Token('INVITEM', l_conc_segments, FALSE);
           FND_MSG_PUB.ADD;

        ELSE

	      l_serv_item_flag := null;
		 l_serv_duraion := null;
		 l_serv_period := null;
		 l_add_line := fnd_api.g_true;
		 l_add_service := fnd_api.g_false;

           open c_serv_item(lpx_qte_line_tbl(i).inventory_item_id,lpx_qte_line_tbl(i).organization_id);
           fetch c_serv_item INTO l_serv_item_flag,l_serv_duraion,l_serv_period;
		 close c_serv_item;

		 if (nvl(l_serv_item_flag, 'N') = 'Y') then

		     if (nvl(l_profile_val, 'Y') = 'N') then

                   l_line_count := l_line_count + 1;

                   l_qte_line_tbl(l_line_count) := lpx_qte_line_tbl(i);
                   l_qte_line_tbl(l_line_count).start_date_active := SYSDATE;
                   l_qte_line_tbl(l_line_count).item_type_code := 'SRV';

                   l_dtl_line_count := l_dtl_line_count + 1;

                   l_qte_line_dtl_tbl(l_dtl_line_count).qte_line_index := l_line_count;
                   l_qte_line_dtl_tbl(l_dtl_line_count).operation_code := 'CREATE';
                   l_qte_line_dtl_tbl(l_dtl_line_count).service_duration := l_serv_duraion;
                   l_qte_line_dtl_tbl(l_dtl_line_count).service_period := l_serv_period;

			    l_add_service := fnd_api.g_true;

               else
		         l_add_line := fnd_api.g_false;

               end if;

           end if;


           if l_add_line = fnd_api.g_true then

		     if l_add_service = fnd_api.g_false then

			    l_line_count := l_line_count + 1;
                   l_qte_line_tbl(l_line_count) := lpx_qte_line_tbl(i);

			end if;

               l_qte_line_tbl(l_line_count).quote_header_id := lx_qte_header_rec.quote_header_id;
               l_qte_line_tbl(l_line_count).operation_code := 'CREATE';

               FOR j IN 1..lp_ln_shipment_tbl.count LOOP

                  IF lp_ln_shipment_tbl(j).qte_line_index = i THEN
                     l_ln_shipment_count := l_ln_shipment_count + 1;
                     l_ln_shipment_tbl(l_ln_shipment_count) := lp_ln_shipment_tbl(j);
                     l_ln_shipment_tbl(l_ln_shipment_count).qte_line_index := l_line_count;
                  END IF;

               END LOOP;

               FOR k IN 1..lp_ln_sales_credit_tbl.count LOOP

                  IF lp_ln_sales_credit_tbl(k).qte_line_index = i THEN
                     l_ln_sales_credit_count := l_ln_sales_credit_count + 1;
                     l_ln_sales_credit_tbl(l_ln_sales_credit_count) := lp_ln_sales_credit_tbl(k);
                     l_ln_sales_credit_tbl(l_ln_sales_credit_count).qte_line_index := l_line_count;
                  END IF;

               END LOOP;

               FOR l IN 1..lp_ln_price_attributes_tbl.count LOOP

                  IF lp_ln_price_attributes_tbl(l).qte_line_index = i THEN
                     l_ln_price_attr_count := l_ln_price_attr_count + 1;
                     l_ln_price_attributes_tbl(l_ln_price_attr_count) := lp_ln_price_attributes_tbl(l);
                     l_ln_price_attributes_tbl(l_ln_price_attr_count).qte_line_index := l_line_count;
                  END IF;

               END LOOP;

           end if; --l_add_line = fnd_api.g_true then

        END IF;

    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_OPP_QTE_PUB: value of ASO_API_ENABLE_SECURITY:'
	                     || FND_PROFILE.value('ASO_API_ENABLE_SECURITY'), 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: before copy sales team loop: lx_qte_header_rec.resource_id:'
	                   || lx_qte_header_rec.resource_id, 1, 'Y');
    END IF;

    IF NVL(FND_PROFILE.value('ASO_API_ENABLE_SECURITY'),'N') = 'Y' THEN
       FOR l_sales_team_rec IN C_sales_team(P_OPP_QTE_IN_REC.OPPORTUNITY_ID) LOOP
           IF l_sales_team_rec.salesforce_id <> lx_qte_header_rec.resource_id THEN
              l_qte_access_rec := ASO_SECURITY_INT.G_MISS_QTE_ACCESS_REC;
		    l_qte_access_rec.OPERATION_CODE := 'CREATE';
              l_qte_access_rec.QUOTE_NUMBER := lx_qte_header_rec.quote_number;
              l_qte_access_rec.RESOURCE_ID := l_sales_team_rec.salesforce_id;
              l_qte_access_rec.RESOURCE_GRP_ID := l_sales_team_rec.sales_group_id;
              l_qte_access_rec.CREATED_BY := G_USER_ID;
              l_qte_access_rec.CREATION_DATE := SYSDATE;
              l_qte_access_rec.LAST_UPDATED_BY := G_USER_ID;
              l_qte_access_rec.LAST_UPDATE_LOGIN := G_LOGIN_ID;
              l_qte_access_rec.LAST_UPDATE_DATE := SYSDATE;
              l_qte_access_rec.REQUEST_ID := l_sales_team_rec.request_id;
              l_qte_access_rec.PROGRAM_APPLICATION_ID := l_sales_team_rec.program_application_id;
              l_qte_access_rec.PROGRAM_ID := l_sales_team_rec.program_id;
              l_qte_access_rec.PROGRAM_UPDATE_DATE := l_sales_team_rec.program_update_date;
              l_qte_access_rec.KEEP_FLAG := l_sales_team_rec.freeze_flag;
              l_qte_access_rec.UPDATE_ACCESS_FLAG := l_sales_team_rec.team_leader_flag;
              l_qte_access_rec.CREATED_BY_TAP_FLAG := l_sales_team_rec.created_by_tap_flag;
              l_qte_access_rec.ATTRIBUTE_CATEGORY := l_sales_team_rec.attribute_category;
              l_qte_access_rec.ATTRIBUTE1 := l_sales_team_rec.attribute1;
              l_qte_access_rec.ATTRIBUTE2 := l_sales_team_rec.attribute2;
              l_qte_access_rec.ATTRIBUTE3 := l_sales_team_rec.attribute3;
              l_qte_access_rec.ATTRIBUTE4 := l_sales_team_rec.attribute4;
              l_qte_access_rec.ATTRIBUTE5 := l_sales_team_rec.attribute5;
              l_qte_access_rec.ATTRIBUTE6 := l_sales_team_rec.attribute6;
              l_qte_access_rec.ATTRIBUTE7 := l_sales_team_rec.attribute7;
              l_qte_access_rec.ATTRIBUTE8 := l_sales_team_rec.attribute8;
              l_qte_access_rec.ATTRIBUTE9 := l_sales_team_rec.attribute9;
              l_qte_access_rec.ATTRIBUTE10 := l_sales_team_rec.attribute10;
              l_qte_access_rec.ATTRIBUTE11 := l_sales_team_rec.attribute11;
              l_qte_access_rec.ATTRIBUTE12 := l_sales_team_rec.attribute12;
              l_qte_access_rec.ATTRIBUTE13 := l_sales_team_rec.attribute13;
              l_qte_access_rec.ATTRIBUTE14 := l_sales_team_rec.attribute14;
              l_qte_access_rec.ATTRIBUTE15 := l_sales_team_rec.attribute15;
              l_qte_access_tbl(l_qte_access_tbl.count+1) := l_qte_access_rec;
            END IF;
       END LOOP;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('ASO_OPP_QTE_PUB:  after copy sales team loop: l_qte_access_tbl.count:'
		                   || l_qte_access_tbl.count, 1, 'N');
       END IF;

    END IF; --NVL(FND_PROFILE.value('ASO_API_ENABLE_SECURITY'),'N') = 'Y'





    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('ASO_OPP_QTE_PUB: before Update_Quote', 1, 'Y');
    END IF;


    BEGIN
        SELECT last_update_date into l_last_update_date
        FROM ASO_QUOTE_HEADERS_ALL
        WHERE quote_header_id = lx_qte_header_rec.quote_header_id;

        lx_QTE_HEADER_REC.last_update_date  := l_last_update_date;

        EXCEPTION WHEN NO_DATA_FOUND THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	               FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
	               FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
	               FND_MSG_PUB.ADD;
                  END IF;
	             RAISE FND_API.G_EXC_ERROR;
    END;


    ASO_QUOTE_PUB.Update_Quote(
          p_api_version_number      => 1.0,
          p_init_msg_list           => fnd_api.g_false,
          p_commit                  => fnd_api.g_false,
          p_control_rec             => p_control_rec,
          p_qte_header_rec          => lx_qte_header_rec,
          p_qte_line_tbl            => l_qte_line_tbl,
		p_qte_line_dtl_tbl        => l_qte_line_dtl_tbl,
          p_ln_Price_Attributes_Tbl => l_ln_price_attributes_tbl,
          p_ln_shipment_tbl         => l_ln_shipment_tbl,
          p_ln_sales_credit_Tbl     => l_ln_sales_credit_tbl,
		P_Qte_Access_Tbl          => l_qte_access_tbl,
		P_Template_Tbl            => P_Template_Tbl,
          X_Qte_Header_Rec          => lx_out_qte_header_rec,
          X_Qte_Line_Tbl            => lx_Qte_Line_Tbl,
          X_Qte_Line_Dtl_Tbl        => lx_Qte_Line_Dtl_Tbl,
          X_hd_Price_Attributes_Tbl => lx_hd_Price_Attributes_Tbl,
          X_hd_Payment_Tbl          => lx_hd_Payment_Tbl,
          X_hd_Shipment_Tbl         => lx_hd_Shipment_Tbl,
          X_hd_Freight_Charge_Tbl   => lx_hd_Freight_Charge_Tbl,
          X_hd_Tax_Detail_Tbl       => lx_hd_Tax_Detail_Tbl,
          X_hd_Attr_Ext_Tbl         => lX_hd_Attr_Ext_Tbl,
          X_hd_Sales_Credit_Tbl     => lx_hd_Sales_Credit_Tbl,
          X_hd_Quote_Party_Tbl      => lx_hd_Quote_Party_Tbl,
          X_Line_Attr_Ext_Tbl       => lx_Line_Attr_Ext_Tbl,
          X_line_rltship_tbl        => lx_line_rltship_tbl,
          X_Price_Adjustment_Tbl    => lx_Price_Adjustment_Tbl,
          X_Price_Adj_Attr_Tbl      => lx_Price_Adj_Attr_Tbl,
          X_Price_Adj_Rltship_Tbl   => lx_Price_Adj_Rltship_Tbl,
          X_ln_Price_Attributes_Tbl => lx_ln_Price_Attributes_Tbl,
          X_ln_Payment_Tbl          => lx_ln_Payment_Tbl,
          X_ln_Shipment_Tbl         => lx_ln_Shipment_Tbl,
          X_ln_Freight_Charge_Tbl   => lx_ln_Freight_Charge_Tbl,
          X_ln_Tax_Detail_Tbl       => lx_ln_Tax_Detail_Tbl,
          X_Ln_Sales_Credit_Tbl     => lX_Ln_Sales_Credit_Tbl,
          X_Ln_Quote_Party_Tbl      => lX_Ln_Quote_Party_Tbl,
		X_Qte_Access_Tbl          => lx_Qte_Access_Tbl,
		X_Template_Tbl            => lx_Qte_Template_Tbl,
		X_Related_Obj_Tbl         => lX_Related_Obj_Tbl,
          X_Return_Status           => x_Return_Status,
          X_Msg_Count               => x_Msg_Count,
          X_Msg_Data                => x_Msg_Data);

    lx_qte_header_rec := lx_out_qte_header_rec;
    --existing code -- Not sure if this is necessary
    l_qte_access_tbl := lx_qte_access_tbl;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('update_quote:X_Return_Status:'||X_Return_Status,1,'N');
       aso_debug_pub.add('update_quote:X_Msg_Count:'||X_Msg_Count,1,'N');
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR then
       raise FND_API.G_EXC_ERROR;
    elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- security changes
    -- copying the sales team from opportunity to quote


    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_OPP_QTE_PUB: value of ASO_API_ENABLE_SECURITY:'
	                     || FND_PROFILE.value('ASO_API_ENABLE_SECURITY'), 1, 'N');
    END IF;

    IF NVL(FND_PROFILE.value('ASO_API_ENABLE_SECURITY'),'N') = 'Y' THEN
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('ASO_OPP_QTE_PUB: before copy sales team loop: lx_qte_header_rec.resource_id:'
		                   || lx_qte_header_rec.resource_id, 1, 'Y');
       END IF;

       FOR l_opp_rec IN C_opp_owner(P_OPP_QTE_IN_REC.OPPORTUNITY_ID,lx_qte_header_rec.quote_number) LOOP
           ASO_QUOTE_ACCESSES_PKG.UPDATE_ROW(
               P_ACCESS_ID               =>      l_opp_rec.access_id,
               P_QUOTE_NUMBER            =>      FND_API.G_MISS_NUM,
               P_RESOURCE_ID             =>      FND_API.G_MISS_NUM,
               P_RESOURCE_GRP_ID         =>      FND_API.G_MISS_NUM,
               P_CREATED_BY              =>      FND_API.G_MISS_NUM,
               P_CREATION_DATE           =>      FND_API.G_MISS_DATE,
               P_LAST_UPDATED_BY         =>      G_USER_ID,
               P_LAST_UPDATE_LOGIN       =>      G_LOGIN_ID,
               P_LAST_UPDATE_DATE        =>      SYSDATE,
               P_REQUEST_ID              =>      FND_API.G_MISS_NUM,
               P_PROGRAM_APPLICATION_ID  =>      FND_API.G_MISS_NUM,
               P_PROGRAM_ID              =>      FND_API.G_MISS_NUM,
               P_PROGRAM_UPDATE_DATE     =>      FND_API.G_MISS_DATE,
               P_KEEP_FLAG               =>      l_opp_rec.freeze_flag,
               P_UPDATE_ACCESS_FLAG      =>      FND_API.G_MISS_CHAR,
               P_CREATED_BY_TAP_FLAG     =>      FND_API.G_MISS_CHAR,
               p_TERRITORY_ID            =>      FND_API.G_MISS_NUM,
               p_TERRITORY_SOURCE_FLAG   =>      FND_API.G_MISS_CHAR,
               p_ROLE_ID                 =>      FND_API.G_MISS_NUM,
               P_ATTRIBUTE_CATEGORY      =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE1              =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE2              =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE3              =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE4              =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE5              =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE6              =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE7              =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE8              =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE9              =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE10             =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE11             =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE12             =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE13             =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE14             =>      FND_API.G_MISS_CHAR,
               P_ATTRIBUTE15             =>      FND_API.G_MISS_CHAR,
               p_ATTRIBUTE16    		  =>      FND_API.G_MISS_CHAR,
               p_ATTRIBUTE17    		  =>      FND_API.G_MISS_CHAR,
               p_ATTRIBUTE18    		  =>      FND_API.G_MISS_CHAR,
               p_ATTRIBUTE19    		  =>      FND_API.G_MISS_CHAR,
               p_ATTRIBUTE20   		  =>      FND_API.G_MISS_CHAR,
		     P_OBJECT_VERSION_NUMBER   =>      FND_API.G_MISS_NUM
           );

	  END LOOP;

    END IF;

    -- end security changes

    -- sanity check
    -- call to check the validity of the passed flags
    Set_Copy_Flags(
           p_object_id            => p_opp_qte_in_rec.opportunity_id,
           x_copy_notes_flag      => l_copy_notes_flag,
           x_copy_task_flag       => l_copy_task_flag,
           x_copy_att_flag        => l_copy_att_flag
    );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_CONTROL_REC.COPY_NOTES_FLAG:'
	                     ||P_CONTROL_REC.COPY_NOTES_FLAG, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: l_copy_notes_flag:'||l_copy_notes_flag, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_CONTROL_REC.COPY_TASK_FLAG:'
	                     ||P_CONTROL_REC.COPY_TASK_FLAG, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: l_copy_task_flag:'||l_copy_task_flag, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: P_CONTROL_REC.COPY_ATT_FLAG:'
	                     ||P_CONTROL_REC.COPY_ATT_FLAG, 1, 'N');
       aso_debug_pub.add('ASO_OPP_QTE_PUB: l_copy_att_flag:'||l_copy_att_flag, 1, 'N');
    END IF;

    IF (p_control_rec.COPY_NOTES_FLAG = 'Y') AND (l_copy_notes_flag = 'Y') THEN
       ASO_NOTES_INT.Copy_Opp_Notes_To_Qte(
                p_api_version          => 1.0,
                p_init_msg_list        => FND_API.G_FALSE,
                p_commit               => FND_API.G_FALSE,
                p_old_object_id        => P_OPP_QTE_IN_REC.OPPORTUNITY_ID,
                p_new_object_id        => lx_qte_header_rec.quote_header_id,
                p_old_object_type_code => 'OPPORTUNITY',
                p_new_object_type_code => 'ASO_QUOTE',
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data
       );
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (p_control_rec.COPY_TASK_FLAG = 'Y') AND (l_copy_task_flag = 'Y') THEN
       ASO_TASK_INT.Copy_Opp_Tasks_To_Qte(
                p_api_version          => 1.0,
                p_init_msg_list        => FND_API.G_FALSE,
                p_commit               => FND_API.G_FALSE,
                p_old_object_id        => P_OPP_QTE_IN_REC.OPPORTUNITY_ID,
                p_new_object_id        => lx_qte_header_rec.quote_header_id,
                p_old_object_type_code => 'OPPORTUNITY',
                p_new_object_type_code => 'ASO_QUOTE',
                p_new_object_name      => lx_qte_header_rec.quote_number ||  FND_GLOBAL.local_chr(45) || lx_qte_header_rec.quote_version,
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data
       );
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (p_control_rec.COPY_ATT_FLAG = 'Y') AND (l_copy_att_flag = 'Y') THEN
       ASO_ATTACHMENT_INT.Copy_Attachments(
                p_api_version          => l_api_version,
                p_init_msg_list        => FND_API.G_FALSE,
                p_commit               => FND_API.G_FALSE,
                p_old_object_code      => 'AS_OPPORTUNITY_ATTCH',
                p_new_object_code      => 'ASO_QUOTE_HEADERS_ALL',
                p_old_object_id        => P_OPP_QTE_IN_REC.OPPORTUNITY_ID,
                p_new_object_id        => lx_qte_header_rec.quote_header_id,
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data
       );
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

END LOOP;

-- Setting OUT NOCOPY /* file.sql.39 change */ parameter values
X_OPP_QTE_OUT_REC.quote_header_id        := lx_qte_header_rec.quote_header_id;
X_OPP_QTE_OUT_REC.quote_number           := lx_qte_header_rec.quote_number;
X_OPP_QTE_OUT_REC.related_object_id      := lx_related_object_id;
X_OPP_QTE_OUT_REC.cust_account_id        := lx_qte_header_rec.cust_account_id;
X_OPP_QTE_OUT_REC.party_id               := lx_qte_header_rec.party_id;
X_OPP_QTE_OUT_REC.currency_code          := lx_qte_header_rec.currency_code;

-- End of API body.

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('****** End of Create_Qte_Opportunity API ******', 1, 'Y');
END IF;

-- Standard check of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PUB,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PUB,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PUB,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Create_Qte_Opportunity;


FUNCTION Validate_Item(
    p_qte_header_rec    IN       ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_inventory_item_id IN       NUMBER,
    p_organization_id   IN       NUMBER,
    p_quantity          IN       NUMBER,
    p_uom_code          IN       VARCHAR2
) RETURN BOOLEAN
IS

 CURSOR c_conc_segments (l_inventory_item_id NUMBER) IS
 SELECT concatenated_segments
 FROM MTL_SYSTEM_ITEMS_VL
 WHERE inventory_item_id = l_inventory_item_id;

 CURSOR c_orderable_items (l_inventory_item_id NUMBER, l_organization_id NUMBER) IS
 SELECT bom_item_type,
        primary_uom_code,
        service_item_flag
 FROM MTL_SYSTEM_ITEMS_VL
 WHERE inventory_item_id = l_inventory_item_id
 AND organization_id = l_organization_id
 AND customer_order_enabled_flag = 'Y'
 AND bom_item_type <> 2
 AND NVL(start_date_active, SYSDATE) <= SYSDATE
 AND NVL(end_date_active, SYSDATE) >= SYSDATE;

 cursor c_in_org_in_master_org(l_inventory_item_id NUMBER, l_organization_id NUMBER) IS
 select segment1
 from mtl_system_items_vl
 WHERE inventory_item_id = l_inventory_item_id
 AND organization_id = l_organization_id;

 l_conc_segments     VARCHAR2(40);
 l_orderable_flag    VARCHAR2(1) := 'N';
 l_uom_code          MTL_SYSTEM_ITEMS_B.primary_uom_code%TYPE;
 l_resp_id           NUMBER;
 l_resp_appl_id      NUMBER;
 l_ui_def_id         NUMBER;
 l_output_qty        NUMBER;
 l_primary_qty       NUMBER;
 l_return_status     VARCHAR2(30);

 lx_return_status    VARCHAR2(50);
 lx_msg_count        NUMBER;
 lx_msg_data         VARCHAR2(2000);
 l_master_organization_id NUMBER;
 l_segment1          VARCHAR2(240);
BEGIN

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: *** Start of API body ***', 1, 'Y');
   aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: p_inventory_item_id: '|| p_inventory_item_id, 1, 'N');
   aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: p_organization_id:   '|| p_organization_id, 1, 'N');
   aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: p_quantity:          '|| p_quantity, 1, 'N');
   aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: p_uom_code:          '|| p_uom_code, 1, 'N');
END IF;


FOR conc_segments_rec IN c_conc_segments(p_inventory_item_id) LOOP
    l_conc_segments := conc_segments_rec.concatenated_segments;
END LOOP;

 -- bug 4932359
           l_master_organization_id := oe_sys_parameters.value(param_name => 'MASTER_ORGANIZATION_ID',
                                                               p_org_id => p_qte_header_rec.org_id);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('l_master_organization_id: ' || l_master_organization_id);
              aso_debug_pub.add(' p_qte_header_rec.org_id: ' ||  p_qte_header_rec.org_id);
           END IF;

 open c_in_org_in_master_org(p_inventory_item_id,l_master_organization_id);
 fetch c_in_org_in_master_org into l_segment1;
 if c_in_org_in_master_org%NOTFOUND THEN
             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('ASO_OPP_QTE_PUB: Item does not exist in the master org',1,'N');
             END IF;
             FND_MESSAGE.Set_Name('ASO', 'ASO_INV_NOT_IN_OP_UNIT');
             FND_MESSAGE.Set_Token('INVITEM', l_conc_segments, FALSE);
             FND_MESSAGE.Set_Token('OPUNIT', l_master_organization_id, FALSE);
             FND_MSG_PUB.ADD;
             RETURN FALSE;

 end if;
 close c_in_org_in_master_org;


FOR orderable_items_rec IN c_orderable_items(p_inventory_item_id, p_organization_id) LOOP
    l_orderable_flag := 'Y';
    IF p_uom_code IS NULL THEN
       l_uom_code := orderable_items_rec.primary_uom_code;

    ELSIF p_uom_code IS NOT NULL AND p_uom_code <> FND_API.G_MISS_CHAR  THEN
      l_uom_code  := p_uom_code;

    END IF;

    IF orderable_items_rec.service_item_flag = 'Y' THEN
       IF (fnd_profile.value('ASO_REQUIRE_SERVICE_REFERENCE') <> 'N')
	     OR (fnd_profile.value('ASO_REQUIRE_SERVICE_REFERENCE') is null) THEN
             IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: item is of type service:'
			                   || p_inventory_item_id, 1, 'N');
		   END IF;
             FND_MESSAGE.Set_Name('ASO', 'ASO_OTQ_SERVICE_ITEM');
             FND_MESSAGE.Set_Token('INVITEM', l_conc_segments, FALSE);
             FND_MSG_PUB.ADD;
             RETURN FALSE;

        end if;
    END IF;

    IF orderable_items_rec.bom_item_type = 1 THEN
       l_resp_id := FND_PROFILE.Value('RESP_ID');
       l_resp_appl_id := FND_PROFILE.Value('RESP_APPL_ID');
       l_ui_def_id := CZ_CF_API.UI_FOR_ITEM(
                               p_inventory_item_id,
                               p_organization_id,
                               SYSDATE,
                               'APPLET',
                               FND_API.G_MISS_NUM,
                               FND_PROFILE.Value('RESP_ID'),
                               FND_PROFILE.Value('RESP_APPL_ID')
                           );

       IF l_ui_def_id IS NULL THEN
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: item does not have a configurable ui:'
		                      || p_inventory_item_id, 1, 'N');
          END IF;

          FND_MESSAGE.Set_Name('ASO', 'ASO_OTQ_NO_CFG_UI_FOR_ITEM');
          FND_MESSAGE.Set_Token('INVITEM', l_conc_segments, FALSE);
          FND_MSG_PUB.ADD;
          RETURN FALSE;
       END IF;
    END IF;

    INV_DECIMALS_PUB.Validate_Quantity(
            p_inventory_item_id,
            p_organization_id,
            p_quantity,
            l_uom_code,
            l_output_qty,
            l_primary_qty,
            l_return_status
    );
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item:p_quantity'|| p_quantity, 1, 'N');
	     aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item:l_return_status'|| l_return_status, 1, 'N');
         aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item:l_uom_code'|| l_uom_code, 1, 'N');
         aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item:l_output_qty'|| l_output_qty, 1, 'N');
         aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item:l_primary_qty'|| l_primary_qty, 1, 'N');
       END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR p_quantity <= 0 THEN
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: item has invalid quantity:'
		                   || p_inventory_item_id, 1, 'N');
       END IF;

       FND_MESSAGE.Set_Name('ASO', 'ASO_OTQ_INVALID_QTY');
       FND_MESSAGE.Set_Token('INVITEM', l_conc_segments, FALSE);
       FND_MSG_PUB.ADD;
       RETURN FALSE;
    END IF;

END LOOP;

IF l_orderable_flag = 'N' THEN
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: item not orderable:'|| p_inventory_item_id, 1, 'N');
   END IF;

   FND_MESSAGE.Set_Name('ASO', 'ASO_OTQ_NOT_ORDERABLE');
   FND_MESSAGE.Set_Token('INVITEM', l_conc_segments, FALSE);
   FND_MSG_PUB.ADD;
   RETURN FALSE;
END IF;


IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('ASO_OPP_QTE_PUB: Validate_Item: *** End of API body ***', 1, 'Y');
END IF;


RETURN TRUE;

END;


PROCEDURE Set_Copy_Flags
(
    p_object_id              IN     NUMBER,
    x_copy_notes_flag        OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_copy_task_flag         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_copy_att_flag          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

    CURSOR l_notes_csr(object_id NUMBER) IS
    SELECT jtf_note_id
      FROM jtf_notes_b
     WHERE source_object_id = object_id
       AND source_object_code = 'OPPORTUNITY';

    CURSOR l_tasks_csr(object_id NUMBER) IS
    SELECT task_id
      FROM jtf_tasks_b
     WHERE source_object_id = object_id
       AND source_object_type_code = 'OPPORTUNITY';

    CURSOR l_attch_csr(object_id NUMBER) IS
    SELECT attached_document_id
      FROM fnd_attached_documents
     WHERE pk1_value = TO_CHAR(object_id)
       AND entity_name = 'AS_OPPORTUNITY_ATTCH';

BEGIN

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    x_copy_notes_flag  := 'N';
    x_copy_task_flag   := 'N';
    x_copy_att_flag    := 'N';

    FOR notes_rec IN l_notes_csr(p_object_id) LOOP
        x_copy_notes_flag := 'Y';
    END LOOP;

    FOR tasks_rec IN l_tasks_csr(p_object_id) LOOP
        x_copy_task_flag := 'Y';
    END LOOP;

    FOR attachments_rec IN l_attch_csr(p_object_id) LOOP
        x_copy_att_flag := 'Y';
    END LOOP;

END Set_Copy_Flags;

Procedure Address_Validation(
          p_party_site_id     IN     Number,
          p_use_type          IN     VARCHAR2,
          x_valid             OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
          X_RETURN_STATUS     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
          X_MSG_COUNT         OUT NOCOPY /* file.sql.39 change */    NUMBER,
          X_MSG_DATA          OUT NOCOPY /* file.sql.39 change */    VARCHAR2
          )
IS
  CURSOR c_location(p_party_site_id IN Number) IS
  SELECT location_id from hz_party_sites
  WHERE party_site_id = p_party_site_id ;

  CURSOR c_loc_assign(p_location_id IN Number) IS
  SELECT loc_id from hz_loc_assignments
  WHERE location_id = p_location_id ;
  --Commented Code Start Yogeshwar (MOAC)
  /*
  AND NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO' ),1,1) , ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
  */
 --Commented Code End Yogeshwar (MOAC)
  l_location_id                Number;
  l_loc_id                     Number;
  lx_loc_id                    Number;
  l_token                      VARCHAR2(10);

BEGIN
  x_valid := 'Y';

  OPEN c_location(p_party_site_id);
  FETCH c_location INTO l_location_id;
  close c_location;

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('ASO_OPP_QTE_PUB:Address_Validation:location_id'||l_location_id, 1, 'N');
  END IF;

  OPEN  c_loc_assign(l_location_id);
  FETCH c_loc_assign INTO l_loc_id;

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('ASO_OPP_QTE_PUB:Address_Validation:loc_assignment_id:'||l_loc_id, 1, 'N');
  END IF;

  IF  c_loc_assign%NOTFOUND THEN
      HZ_TAX_ASSIGNMENT_V2PUB.create_loc_assignment(
                                p_init_msg_list         => FND_API.G_FALSE,
                                p_location_id           => l_location_id,
                                p_lock_flag             => FND_API.G_FALSE,
                                p_created_by_module     => 'ASO_CUSTOMER_DATA',
                                p_application_id        => FND_API.G_MISS_NUM,
                                X_RETURN_STATUS         => X_RETURN_STATUS,
                                X_MSG_COUNT             => X_MSG_COUNT,
                                X_MSG_DATA              => X_MSG_DATA,
                                x_loc_id                => lx_loc_id
      );

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_OPP_QTE_PUB:Address_Validation:X_RETURN_STATUS:'||X_RETURN_STATUS, 1, 'N');
         aso_debug_pub.add('ASO_OPP_QTE_PUB:Address_Validation:lx_loc_id:'||lx_loc_id, 1, 'N');
	 END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_valid := 'N';
         FND_Msg_Pub.initialize;
	 END IF;
  END IF;

END;


END;

/
