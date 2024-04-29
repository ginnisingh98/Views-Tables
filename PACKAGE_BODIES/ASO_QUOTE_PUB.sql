--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_PUB" as
/* $Header: asopqteb.pls 120.3.12010000.13 2016/05/03 22:13:50 vidsrini ship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_PUB
-- Purpose          :
-- History          :
--                     12-16-04  skulkarn: fixed bug 4046692
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_QUOTE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asopqteb.pls';


x_msg_count number;
x_msg_data varchar2(1000);

PROCEDURE Convert_Party_To_Id (
	p_column_name	IN	VARCHAR2,
	p_party_type	IN	VARCHAR2,
	p_party_id	IN	NUMBER,
	p_party_name	IN	VARCHAR2,
	p_person_first_name	IN	VARCHAR2,
	p_person_middle_name	IN	VARCHAR2,
	p_person_last_name	IN	VARCHAR2,
	x_party_id OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
    l_party_rec		ASO_PARTY_INT.Party_Rec_Type;
BEGIN

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    x_party_id := p_party_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_party_id IS NOT NULL
	AND p_party_id <> FND_API.G_MISS_NUM) THEN
	ASO_UTILITY_PVT.Set_Message(
		p_msg_level     => FND_MSG_PUB.G_MSG_LVL_SUCCESS,
		p_msg_name      => 'ASO_API_ATTRIBUTE_IGNORED',
		p_token1        => 'COLUMN',
		p_token1_value  => p_column_name);
/* commented below code as part of bug 22264384 */
 /*   ELSIF (p_person_first_name <> FND_API.G_MISS_CHAR
		AND p_person_first_name IS NOT NULL)
	OR (p_party_name <> FND_API.G_MISS_CHAR
		AND p_party_name IS NOT NULL) THEN
	l_party_rec.party_id := p_party_id;
	l_party_rec.party_type := p_party_type;
	l_party_rec.party_name := p_party_name;
	l_party_rec.person_first_name := p_person_first_name;
	l_party_rec.person_middle_name := p_person_middle_name;
	l_party_rec.person_last_name := p_person_last_name;
	ASO_PARTY_INT.Create_Party(
		p_party_rec	=> l_party_rec,
		x_party_id	=> x_party_id,
		x_return_status => x_return_status,
        x_msg_count  => x_msg_count,
        x_msg_data => x_msg_data  );*/
    END IF;
END;

PROCEDURE Convert_Site_To_Id (
	p_column_name	IN	VARCHAR2,
	p_party_id	IN	NUMBER,
	p_party_site_id	IN	NUMBER,
	p_site_use_type IN	VARCHAR2,
	p_address1	IN	VARCHAR2,
	p_address2	IN	VARCHAR2,
	p_address3	IN	VARCHAR2,
	p_address4	IN	VARCHAR2,
	p_country_code	IN	VARCHAR2,
	p_country	IN	VARCHAR2,
	p_city		IN	VARCHAR2,
	p_postal_code	IN	VARCHAR2,
	p_province	IN	VARCHAR2,
	p_county	IN	VARCHAR2,
	x_party_site_id OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
    l_party_site_rec	ASO_PARTY_INT.Party_Site_Rec_Type;
    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;

BEGIN

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    x_party_site_id := p_party_site_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_party_site_id IS NOT NULL
	AND p_party_site_id <> FND_API.G_MISS_NUM) THEN
	ASO_UTILITY_PVT.Set_Message(
		p_msg_level     => FND_MSG_PUB.G_MSG_LVL_SUCCESS,
		p_msg_name      => 'ASO_API_ATTRIBUTE_IGNORED',
		p_token1        => 'COLUMN',
		p_token1_value  => p_column_name);
    ELSIF (p_address1 <> FND_API.G_MISS_CHAR AND
		p_address1 IS NOT NULL AND
		p_country <> FND_API.G_MISS_CHAR AND
		p_country IS NOT NULL AND
		p_party_id <> FND_API.G_MISS_NUM  AND  -- bug 4046692 changed from G_MISS_CHAR to G_MISS_NUM
		p_party_id IS NULL) THEN
	l_party_site_rec.party_id := p_party_id;
	l_party_site_rec.party_site_use_type := p_site_use_type;
    	l_party_site_rec.location.address1 := p_address1;
    	l_party_site_rec.location.address2 := p_address2;
    	l_party_site_rec.location.address3 := p_address3;
    	l_party_site_rec.location.address4 := p_address4;
    	l_party_site_rec.location.city := p_city;
    	l_party_site_rec.location.postal_code := p_postal_code;
    	l_party_site_rec.location.province := p_province;
    	l_party_site_rec.location.county := p_county;
    	l_party_site_rec.location.country := p_country;
	ASO_PARTY_INT.Create_Party_Site(
		p_party_site_rec => l_party_site_rec,
		x_party_site_id	 => x_party_site_id,
		x_return_status	 => x_return_status,
		x_msg_data => l_msg_data,
		x_msg_count => l_msg_count);
    END IF;
END;


PROCEDURE Convert_Header_Values_To_Ids(
         P_Qte_Header_rec        IN    Qte_Header_Rec_Type,
         x_qte_header_rec	  OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type
)
IS
    l_any_errors  BOOLEAN := FALSE;
    l_return_status     VARCHAR2(1);
BEGIN

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    x_qte_header_rec := p_qte_header_rec;
    -- party_id
    Convert_Party_To_Id (
	p_column_name	=> 'PARTY_NAME',
	p_party_id	=> p_qte_header_rec.party_id,
	p_party_type	=> p_qte_header_rec.party_type,
	p_party_name	=> p_qte_header_rec.party_name,
	p_person_first_name	=> p_qte_header_rec.person_first_name,
	p_person_middle_name	=> p_qte_header_rec.person_middle_name,
	p_person_last_name	=> p_qte_header_rec.person_last_name,
	x_party_id	=> x_qte_header_rec.party_id,
	x_return_status => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_any_errors := TRUE;
    END IF;
    -- invoice_to_party_id
    Convert_Party_To_Id (
	p_column_name	=> 'INVOICE_TO_PARTY_NAME',
	p_party_id	=> p_qte_header_rec.invoice_to_party_id,
	p_party_name	=> p_qte_header_rec.invoice_to_party_name,
	p_party_type	=> 'PERSON',
	p_person_first_name	=> p_qte_header_rec.invoice_to_contact_first_name,
	p_person_middle_name	=> p_qte_header_rec.invoice_to_contact_middle_name,
	p_person_last_name	=> p_qte_header_rec.invoice_to_contact_last_name,
	x_party_id	=> x_qte_header_rec.invoice_to_party_id,
	x_return_status => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_any_errors := TRUE;
    END IF;
    -- invoice_to_site_id
    Convert_Site_To_Id (
	p_column_name	=> 'INVOICE_TO_SITE_LOCATION',
	p_party_id	=> p_qte_header_rec.invoice_to_party_id,
	p_party_site_id	=> p_qte_header_rec.invoice_to_party_site_id,
	p_site_use_type => 'INVOICE_TO',
	p_address1	=> p_qte_header_rec.invoice_to_address1,
	p_address2	=> p_qte_header_rec.invoice_to_address2,
	p_address3	=> p_qte_header_rec.invoice_to_address3,
	p_address4	=> p_qte_header_rec.invoice_to_address4,
	p_country_code	=> p_qte_header_rec.invoice_to_country_code,
	p_country	=> p_qte_header_rec.invoice_to_country,
	p_city		=> p_qte_header_rec.invoice_to_city,
	p_postal_code	=> p_qte_header_rec.invoice_to_postal_code,
	p_province	=> p_qte_header_rec.invoice_to_province,
	p_county	=> p_qte_header_rec.invoice_to_county,
	x_party_site_id	=> x_qte_header_rec.invoice_to_party_site_id,
	x_return_status => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_any_errors := TRUE;
    END IF;
    -- no value-to-id conversion for the following fields. If the user wants
    -- to input any related data, the ID must be passed in.
    -- status_id
    -- org_contact_id
    -- source_campaign_id
    -- compaign_id
    -- order_type_id
    -- employee_person_id
    -- price_list_id
    IF l_any_errors THEN
          raise FND_API.G_EXC_ERROR;
    END IF;
END;

PROCEDURE Convert_Shipment_Values_To_Ids(
         P_shipment_Rec   IN    shipment_Rec_Type,
         x_shipment_rec	  OUT NOCOPY /* file.sql.39 change */  shipment_Rec_Type
)
IS
    l_any_errors  BOOLEAN := FALSE;
    l_return_status     VARCHAR2(1);
BEGIN

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    x_shipment_rec := p_shipment_rec;
    -- ship_to_party_id
    Convert_Party_To_Id (
	p_column_name	=> 'SHIP_TO_PARTY_NAME',
	p_party_id	=> p_shipment_rec.ship_to_party_id,
	p_party_name	=> p_shipment_rec.ship_to_party_name,
	p_party_type	=> 'PERSON',
	p_person_first_name	=> p_shipment_rec.ship_to_contact_first_name,
	p_person_middle_name	=> p_shipment_rec.ship_to_contact_middle_name,
	p_person_last_name	=> p_shipment_rec.ship_to_contact_last_name,
	x_party_id	=> x_shipment_rec.ship_to_party_id,
	x_return_status => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_any_errors := TRUE;
    END IF;
    -- ship_to_site_id
    Convert_Site_To_Id (
	p_column_name	=> 'SHIP_TO_SITE_LOCATION',
	p_party_id	=> p_shipment_rec.ship_to_party_id,
	p_party_site_id	=> p_shipment_rec.ship_to_party_site_id,
	p_site_use_type => 'INVOICE_TO',
	p_address1	=> p_shipment_rec.ship_to_address1,
	p_address2	=> p_shipment_rec.ship_to_address2,
	p_address3	=> p_shipment_rec.ship_to_address3,
	p_address4	=> p_shipment_rec.ship_to_address4,
	p_country_code	=> p_shipment_rec.ship_to_country_code,
	p_country	=> p_shipment_rec.ship_to_country,
	p_city		=> p_shipment_rec.ship_to_city,
	p_postal_code	=> p_shipment_rec.ship_to_postal_code,
	p_province	=> p_shipment_rec.ship_to_province,
	p_county	=> p_shipment_rec.ship_to_county,
	x_party_site_id	=> x_shipment_rec.ship_to_party_site_id,
	x_return_status => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_any_errors := TRUE;
    END IF;
    -- no value-to-id conversion for the following fields. If the user wants
    -- to input any related data, the CODE must be passed in.
    -- SHIP_METHOD_CODE
    -- FREIGHT_TERMS_CODE
    -- FREIGHT_CARRIER_CODE
    -- FOB_CODE
    IF l_any_errors THEN
          raise FND_API.G_EXC_ERROR;
    END IF;
END;

PROCEDURE Convert_Line_Values_To_Ids(
         P_QTE_Line_Rec        IN    QTE_Line_Rec_Type,
         x_QTE_Line_rec	  OUT NOCOPY /* file.sql.39 change */  QTE_Line_Rec_Type
)
IS
BEGIN
aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
    x_qte_line_rec := p_qte_line_rec;
    null;
END;

PROCEDURE Create_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Control_Rec		        IN   Control_Rec_Type                        := G_Miss_Control_Rec,
    P_Qte_Header_Rec		   IN   Qte_Header_Rec_Type                     := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		   IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec		   IN   ASO_QUOTE_PUB.Shipment_Rec_Type         := G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl	   IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		   IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := G_Miss_Tax_Detail_Tbl,
    P_Qte_Line_Tbl		        IN   Qte_Line_Tbl_Type                       := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		   IN   Qte_Line_Dtl_Tbl_Type                   := G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		   IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		   IN   Line_Rltship_Tbl_Type                   := G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	   IN   Price_Adj_Tbl_Type                      := G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	        IN   Price_Adj_Attr_Tbl_Type                 := G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	   IN   Price_Adj_Rltship_Tbl_Type              := G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	   IN   Price_Attributes_Tbl_Type               := G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		   IN   Payment_Tbl_Type                        := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		   IN   Shipment_Tbl_Type                       := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	   IN   Freight_Charge_Tbl_Type                 := G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		   IN   Tax_Detail_Tbl_Type                     := G_Miss_Tax_Detail_Tbl,
    x_Qte_Header_Rec		   OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		        OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		   OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Rec		   OUT NOCOPY /* file.sql.39 change */  Shipment_Rec_Type,
    X_Hd_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		   OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    x_Line_Attr_Ext_Tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	        OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		   OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

 x_hd_Attr_Ext_Tbl		       Line_Attribs_Ext_Tbl_Type;
 x_hd_Sales_Credit_Tbl          Sales_Credit_Tbl_Type ;
 x_hd_Quote_Party_Tbl           Quote_Party_Tbl_Type;
 x_ln_Sales_Credit_Tbl          Sales_Credit_Tbl_Type ;
 x_ln_Quote_Party_Tbl           Quote_Party_Tbl_Type;

BEGIN
   aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

   Create_quote(
	    P_Api_Version_Number	      => 1.0,
	    P_Init_Msg_List		      => p_init_msg_list,
	    P_Commit			      => p_commit,
	    P_Control_Rec		      => p_control_rec,
	    P_qte_header_rec		 => p_qte_header_rec,
	    P_Hd_Price_Attributes_Tbl	 => p_Hd_Price_Attributes_Tbl,
	    P_Hd_Payment_Tbl		 => p_Hd_Payment_Tbl,
	    P_Hd_Shipment_Rec		 => p_Hd_Shipment_Rec,
	    P_Hd_Freight_Charge_Tbl	 => p_Hd_Freight_Charge_Tbl,
	    P_Hd_Tax_Detail_Tbl		 => p_Hd_Tax_Detail_Tbl,
	    P_Qte_Line_Tbl		      => p_Qte_Line_Tbl,
	    P_Qte_Line_Dtl_Tbl		 => p_Qte_Line_Dtl_Tbl,
	    P_Line_Attr_Ext_Tbl		 => P_Line_Attr_Ext_Tbl,
	    P_Line_rltship_tbl		 => p_Line_Rltship_Tbl,
	    P_Price_Adjustment_Tbl	 => p_Price_Adjustment_Tbl,
	    P_Price_Adj_Attr_Tbl	      => P_Price_Adj_Attr_Tbl,
	    P_Price_Adj_Rltship_Tbl	 => p_Price_Adj_Rltship_Tbl,
	    P_Ln_Price_Attributes_Tbl	 => p_Ln_Price_Attributes_Tbl,
	    P_Ln_Payment_Tbl		 => p_Ln_Payment_Tbl,
	    P_Ln_Shipment_Tbl		 => p_Ln_Shipment_Tbl,
	    P_Ln_Freight_Charge_Tbl	 => p_Ln_Freight_Charge_Tbl,
	    P_Ln_Tax_Detail_Tbl		 => p_Ln_Tax_Detail_Tbl,
	    x_qte_header_rec		 => x_qte_header_rec,
	    X_Hd_Price_Attributes_Tbl	 => x_Hd_Price_Attributes_Tbl,
	    X_Hd_Payment_Tbl		 => x_Hd_Payment_Tbl,
	    X_Hd_Shipment_Rec		 => x_Hd_Shipment_Rec,
	    X_Hd_Freight_Charge_Tbl	 => x_Hd_Freight_Charge_Tbl,
	    X_Hd_Tax_Detail_Tbl		 => x_Hd_Tax_Detail_Tbl,
         X_hd_Attr_Ext_Tbl		 => X_hd_Attr_Ext_Tbl,
         X_hd_Sales_Credit_Tbl      => X_hd_Sales_Credit_Tbl,
         X_hd_Quote_Party_Tbl       => X_hd_Quote_Party_Tbl,
	    X_Qte_Line_Tbl		      => x_Qte_Line_Tbl,
	    X_Qte_Line_Dtl_Tbl		 => x_Qte_Line_Dtl_Tbl,
	    x_Line_Attr_Ext_Tbl		 => x_Line_Attr_Ext_Tbl,
	    X_Line_rltship_tbl		 => x_Line_Rltship_Tbl,
	    X_Price_Adjustment_Tbl	 => x_Price_Adjustment_Tbl,
	    x_Price_Adj_Attr_Tbl	      => x_Price_Adj_Attr_Tbl,
	    X_Price_Adj_Rltship_Tbl	 => x_Price_Adj_Rltship_Tbl,
	    X_Ln_Price_Attributes_Tbl	 => x_Ln_Price_Attributes_Tbl,
	    X_Ln_Payment_Tbl		 => x_Ln_Payment_Tbl,
	    X_Ln_Shipment_Tbl		 => x_Ln_Shipment_Tbl,
	    X_Ln_Freight_Charge_Tbl	 => x_Ln_Freight_Charge_Tbl,
	    X_Ln_Tax_Detail_Tbl		 => x_Ln_Tax_Detail_Tbl,
         X_Ln_Sales_Credit_Tbl      => X_ln_Sales_Credit_Tbl,
         X_Ln_Quote_Party_Tbl       => X_ln_Quote_Party_Tbl,
	    X_Return_Status            => x_return_status,
	    X_Msg_Count                => x_msg_count,
	    X_Msg_Data                 => x_msg_data);

END Create_Quote;


PROCEDURE Update_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Control_Rec		        IN   Control_Rec_Type                        := G_Miss_Control_Rec,
    P_Qte_Header_Rec		   IN   Qte_Header_Rec_Type                     := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		   IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Tbl		   IN   ASO_QUOTE_PUB.Shipment_Tbl_Type         := G_MISS_SHIPMENT_TBL,
    P_hd_Freight_Charge_Tbl	   IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		   IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := G_Miss_Tax_Detail_Tbl,
    P_Qte_Line_Tbl		        IN   Qte_Line_Tbl_Type                       := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		   IN   Qte_Line_Dtl_Tbl_Type                   := G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		   IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		   IN   Line_Rltship_Tbl_Type                   := G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	   IN   Price_Adj_Tbl_Type                      := G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	        IN   Price_Adj_Attr_Tbl_Type                 := G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	   IN   Price_Adj_Rltship_Tbl_Type              := G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	   IN   Price_Attributes_Tbl_Type               := G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		   IN   Payment_Tbl_Type                        := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		   IN   Shipment_Tbl_Type                       := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	   IN   Freight_Charge_Tbl_Type                 := G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		   IN   Tax_Detail_Tbl_Type                     := G_Miss_Tax_Detail_Tbl,
    x_Qte_Header_Rec		   OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		        OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		   OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Hd_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		   OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    x_Line_Attr_Ext_Tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	        OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		   OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

 x_hd_Attr_Ext_Tbl		       Line_Attribs_Ext_Tbl_Type;
 x_hd_Sales_Credit_Tbl          Sales_Credit_Tbl_Type ;
 x_hd_Quote_Party_Tbl           Quote_Party_Tbl_Type;
 x_ln_Sales_Credit_Tbl          Sales_Credit_Tbl_Type ;
 x_ln_Quote_Party_Tbl           Quote_Party_Tbl_Type;

BEGIN
     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     Update_quote(
	    P_Api_Version_Number	      => 1.0,
	    P_Init_Msg_List		      => p_init_msg_list,
	    P_Commit			      => p_commit,
	    P_Control_Rec		      => p_control_rec,
	    P_qte_header_rec		 => p_qte_header_rec,
	    P_Hd_Price_Attributes_Tbl	 => p_Hd_Price_Attributes_Tbl,
	    P_Hd_Payment_Tbl		 => p_Hd_Payment_Tbl,
	    P_Hd_Shipment_Tbl		 => p_Hd_Shipment_Tbl,
	    P_Hd_Freight_Charge_Tbl	 => p_Hd_Freight_Charge_Tbl,
	    P_Hd_Tax_Detail_Tbl		 => p_Hd_Tax_Detail_Tbl,
	    P_Qte_Line_Tbl		      => p_Qte_Line_Tbl,
	    P_Qte_Line_Dtl_Tbl		 => p_Qte_Line_Dtl_Tbl,
	    P_Line_Attr_Ext_Tbl		 => P_Line_Attr_Ext_Tbl,
	    P_Line_rltship_tbl		 => p_Line_Rltship_Tbl,
	    P_Price_Adjustment_Tbl	 => p_Price_Adjustment_Tbl,
	    P_Price_Adj_Attr_Tbl	      => P_Price_Adj_Attr_Tbl,
	    P_Price_Adj_Rltship_Tbl	 => p_Price_Adj_Rltship_Tbl,
	    P_Ln_Price_Attributes_Tbl	 => p_Ln_Price_Attributes_Tbl,
	    P_Ln_Payment_Tbl		 => p_Ln_Payment_Tbl,
	    P_Ln_Shipment_Tbl		 => p_Ln_Shipment_Tbl,
	    P_Ln_Freight_Charge_Tbl	 => p_Ln_Freight_Charge_Tbl,
	    P_Ln_Tax_Detail_Tbl		 => p_Ln_Tax_Detail_Tbl,
	    x_qte_header_rec		 => x_qte_header_rec,
	    X_Hd_Price_Attributes_Tbl	 => x_Hd_Price_Attributes_Tbl,
	    X_Hd_Payment_Tbl		 => x_Hd_Payment_Tbl,
	    X_Hd_Shipment_tbl		 => x_Hd_Shipment_tbl,
	    X_Hd_Freight_Charge_Tbl	 => x_Hd_Freight_Charge_Tbl,
	    X_Hd_Tax_Detail_Tbl		 => x_Hd_Tax_Detail_Tbl,
         X_hd_Attr_Ext_Tbl		 => X_hd_Attr_Ext_Tbl,
         X_hd_Sales_Credit_Tbl      => X_hd_Sales_Credit_Tbl,
         X_hd_Quote_Party_Tbl       => X_hd_Quote_Party_Tbl,
	    X_Qte_Line_Tbl		      => x_Qte_Line_Tbl,
	    X_Qte_Line_Dtl_Tbl		 => x_Qte_Line_Dtl_Tbl,
	    x_Line_Attr_Ext_Tbl		 => x_Line_Attr_Ext_Tbl,
	    X_Line_rltship_tbl		 => x_Line_Rltship_Tbl,
	    X_Price_Adjustment_Tbl	 => x_Price_Adjustment_Tbl,
	    x_Price_Adj_Attr_Tbl	      => x_Price_Adj_Attr_Tbl,
	    X_Price_Adj_Rltship_Tbl	 => x_Price_Adj_Rltship_Tbl,
	    X_Ln_Price_Attributes_Tbl	 => x_Ln_Price_Attributes_Tbl,
	    X_Ln_Payment_Tbl		 => x_Ln_Payment_Tbl,
	    X_Ln_Shipment_Tbl		 => x_Ln_Shipment_Tbl,
	    X_Ln_Freight_Charge_Tbl	 => x_Ln_Freight_Charge_Tbl,
	    X_Ln_Tax_Detail_Tbl		 => x_Ln_Tax_Detail_Tbl,
         X_Ln_Sales_Credit_Tbl      => X_ln_Sales_Credit_Tbl,
         X_Ln_Quote_Party_Tbl       => X_ln_Quote_Party_Tbl,
	    X_Return_Status            => x_return_status,
	    X_Msg_Count                => x_msg_count,
	    X_Msg_Data                 => x_msg_data);

End Update_quote;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
-- The Master delete procedure may not be needed depends on different business requirements.

PROCEDURE Delete_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Id		        IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )

IS
    l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_QUOTE';
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_qte_header_id NUMBER;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_QUOTE_PUB;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_qte_header_id := P_qte_header_id;

      --
      -- API body
      --
      -- call user hooks
      -- customer pre processing

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN

          ASO_QUOTE_CUHK.Delete_quote_PRE( P_Qte_Header_Id   => l_qte_header_id,
                                           X_Return_Status   => x_return_status,
  	                                      X_Msg_Count       => x_msg_count ,
  	                                      X_Msg_Data        => x_msg_data );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		        FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		        FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Delete_Quote_PRE', FALSE);
		        FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      END IF; -- customer hook

      -- vertical hook
      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN

          ASO_QUOTE_VUHK.Delete_quote_PRE( P_Qte_Header_Id  => l_qte_header_id,
                                           X_Return_Status  => x_return_status,
  	                                      X_Msg_Count      => x_msg_count,
  	                                      x_Msg_Data       => x_msg_data );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		        FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		        FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Delete_Quote_PRE', FALSE);
		        FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      END IF; -- vertical hook

      ASO_QUOTE_HEADERS_PVT.Delete_quote( P_Api_Version_Number  => 1.0,
		                                P_Init_Msg_List       => FND_API.G_FALSE,
		                                P_Commit              => p_commit,
		                                P_Qte_Header_ID       => l_Qte_Header_Id,
		                                X_Return_Status       => x_return_status,
		                                X_Msg_Count           => x_msg_count,
		                                X_Msg_Data            => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN

          ASO_QUOTE_CUHK.Delete_quote_POST( P_Qte_Header_Id		=> l_qte_header_id,
   	                                       X_Return_Status         => x_return_status,
		                                  X_Msg_Count             => x_msg_count,
		                                  X_Msg_Data              => x_msg_data );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		        FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		        FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Delete_Quote_POST', FALSE);
		        FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      END IF; -- customer hook

      -- vertical hook
      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN

          ASO_QUOTE_VUHK.Delete_quote_POST( P_Qte_Header_Id  => l_qte_header_id,
   	                                       X_Return_Status  => x_return_status,
		                                  X_Msg_Count      => x_msg_count,
		                                  X_Msg_Data       => x_msg_data );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		        FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		        FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Delete_Quote_POST', FALSE);
		        FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      END IF; -- vertical hook

	 --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                 p_data  => x_msg_data );

      EXCEPTION

          WHEN FND_API.G_EXC_ERROR THEN

              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		         P_API_NAME        => L_API_NAME
                  ,P_PKG_NAME        => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT       => X_MSG_COUNT
                  ,X_MSG_DATA        => X_MSG_DATA
                  ,X_RETURN_STATUS   => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME        => L_API_NAME
                  ,P_PKG_NAME        => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT       => X_MSG_COUNT
                  ,X_MSG_DATA        => X_MSG_DATA
                  ,X_RETURN_STATUS   => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME        => L_API_NAME
                  ,P_PKG_NAME        => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT       => X_MSG_COUNT
                  ,X_MSG_DATA        => X_MSG_DATA
                  ,X_RETURN_STATUS   => X_RETURN_STATUS);

End Delete_quote;


PROCEDURE Get_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec		 IN   Qte_Header_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   QTE_sort_rec_type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_QTE_Header_Tbl		 OUT NOCOPY /* file.sql.39 change */  QTE_Header_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_next_rec_ptr               OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_tot_rec_count              OUT NOCOPY /* file.sql.39 change */  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY /* file.sql.39 change */  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'GET_QUOTE';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_QUOTE_PUB;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      ASO_QUOTE_HEADERS_PVT.Get_quote(
		P_Api_Version_Number         => 1.0,
		P_Init_Msg_List              => FND_API.G_FALSE,
		P_Qte_Header_Rec  =>  P_Qte_Header_Rec,
		p_rec_requested              => p_rec_requested,
		p_start_rec_prt              => p_start_rec_prt,
		p_return_tot_count           => p_return_tot_count,
		p_order_by_rec               => p_order_by_rec,
		X_Return_Status              => x_return_status,
		X_Msg_Count                  => x_msg_count,
		X_Msg_Data                   => x_msg_data,
		X_Qte_Header_Tbl  => X_Qte_Header_Tbl,
		x_returned_rec_count         => x_returned_rec_count,
		x_next_rec_ptr               => x_next_rec_ptr,
		x_tot_rec_count              => x_tot_rec_count
      );




      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Get_quote;

PROCEDURE Validate_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Id		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_QUOTE';
    l_api_version_number      CONSTANT NUMBER   := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_QUOTE_PUB;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --


      ASO_QUOTE_HEADERS_PVT.Validate_Quote(
		P_Api_Version_Number     => 1.0,
		P_Init_Msg_List          => FND_API.G_FALSE,
		P_Qte_Header_Id		 => p_qte_header_id,
		X_Return_Status          => x_return_status,
		X_Msg_Count              => x_msg_count,
		X_Msg_Data               => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Validate_Quote;

PROCEDURE Submit_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_control_rec		        IN   Submit_Control_Rec_Type
				                               := g_miss_Submit_Control_Rec,
    P_Qte_Header_Id		        IN   NUMBER,
    x_order_header_rec		   OUT NOCOPY /* file.sql.39 change */  Order_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'SUBMIT_QUOTE';
    l_api_version_number      CONSTANT NUMBER   := 1.0;
    l_control_rec             Submit_Control_Rec_Type := P_control_rec;
    l_Qte_Header_Id           NUMBER;
    l_qte_header_rec          ASO_QUOTE_PUB.qte_Header_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT SUBMIT_QUOTE_PUB;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_Qte_Header_Id := P_Qte_Header_Id;

      --
      -- API body
      --

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN
       ASO_QUOTE_CUHK.Submit_quote_PRE(
    p_control_rec		 => l_control_rec,
    P_Qte_Header_Id		 => l_Qte_Header_Id,
    X_Return_Status      => X_Return_Status,
    X_Msg_Count          => X_Msg_Count,
    X_Msg_Data            => X_Msg_Data    );
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Submit_Quote_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook
       -- vertical hook
       IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN
         ASO_QUOTE_VUHK.Submit_quote_PRE(
    p_control_rec		 => l_control_rec,
    P_Qte_Header_Id		 => l_Qte_Header_Id,
    X_Return_Status      => X_Return_Status,
    X_Msg_Count          => X_Msg_Count,
    X_Msg_Data            => X_Msg_Data    );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Submit_Quote_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
       END IF;
      END IF;

	 l_qte_header_rec.quote_header_id := l_Qte_Header_Id;
	 l_qte_header_rec.last_update_date := FND_API.G_MISS_DATE;

      ASO_SUBMIT_QUOTE_PVT.Submit_Quote(
		P_Api_Version_Number => 1.0,
		P_Init_Msg_List      => p_init_msg_list,
		P_Control_Rec		 => l_control_rec,
		P_Qte_Header_Rec	 => l_qte_header_rec,
		x_order_header_rec	 => x_Order_Header_Rec,
		X_Return_Status      => x_return_status,
		X_Msg_Count          => x_msg_count,
		X_Msg_Data           => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

         --  call user hooks
      -- customer post processing

    IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN
         ASO_QUOTE_CUHK.Submit_quote_POST(
    p_control_rec		 => l_control_rec,
    P_Qte_Header_Id		 => l_Qte_Header_Id,
    p_order_header_rec   => x_order_header_rec,
    X_Return_Status      => X_Return_Status,
    X_Msg_Count          => X_Msg_Count,
    X_Msg_Data            => X_Msg_Data    );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Submit_Quote_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN
      ASO_QUOTE_VUHK.Submit_quote_POST(
    p_control_rec		 => l_control_rec,
    P_Qte_Header_Id		 => l_Qte_Header_Id,
    p_order_header_rec   => x_order_header_rec,
    X_Return_Status      => X_Return_Status,
    X_Msg_Count          => X_Msg_Count,
    X_Msg_Data            => X_Msg_Data    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Submit_Quote_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook
      --
      -- End of API body
      --




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Submit_Quote;


PROCEDURE Copy_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Id		 IN   NUMBER,
    P_Last_Update_Date		 IN   DATE,
    P_Copy_Only_Header		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_New_Version		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Qte_Status_Id		 IN   NUMBER	   := NULL,
    P_Qte_Number		 IN   NUMBER	   := NULL,
    X_Qte_Header_Id		 OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'COPY_QUOTE';
    l_api_version_number      CONSTANT NUMBER   := 1.0;
    l_Qte_Header_Id  NUMBER;
    l_Last_Update_Date DATE;
    l_Copy_Only_Header VARCHAR2(30);
    l_New_Version VARCHAR2(30);
    l_Qte_Status_Id NUMBER;
    l_Qte_Number NUMBER;
    l_NEW_Qte_Header_Id NUMBER;
    l_control_rec ASO_QUOTE_PUB.control_rec_type := G_MISS_Control_Rec ;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT COPY_QUOTE_PUB;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

    -- mapping to local variables
    l_Qte_Header_Id    :=   P_Qte_Header_Id	;
    l_Last_Update_Date := P_Last_Update_Date;
    l_Copy_Only_Header :=  P_Copy_Only_Header;
    l_New_Version   := P_New_Version;
    l_Qte_Status_Id := P_Qte_Status_Id;
    l_Qte_Number := P_Qte_Number	;

     IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN
     ASO_QUOTE_CUHK.Copy_quote_PRE(
    P_Qte_Header_Id		 => l_Qte_Header_Id,
    P_Last_Update_Date	  => l_Last_Update_Date,
    P_Copy_Only_Header		 => l_Copy_Only_Header,
    P_New_Version		 => l_New_Version,
    P_Qte_Status_Id		=> l_Qte_Status_Id	,
    P_Qte_Number		 => l_Qte_Number	,
    X_Return_Status      => X_Return_Status ,
    X_Msg_Count           =>     X_Msg_Count,
    X_Msg_Data            =>        X_Msg_Data
    );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Copy_Quote_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook
       -- vertical hook
       IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN
       ASO_QUOTE_VUHK.Copy_quote_PRE(
    P_Qte_Header_Id		 => l_Qte_Header_Id,
    P_Last_Update_Date	  => l_Last_Update_Date,
    P_Copy_Only_Header		 => l_Copy_Only_Header,
    P_New_Version		 => l_New_Version,
    P_Qte_Status_Id		=> l_Qte_Status_Id	,
    P_Qte_Number		 => l_Qte_Number	,
    X_Return_Status      => X_Return_Status ,
    X_Msg_Count           =>     X_Msg_Count,
    X_Msg_Data            =>        X_Msg_Data
    );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Copy_Quote_PRE', FALSE);
		  FND_MSG_PUB.ADD;
     END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF;


      ASO_QUOTE_HEADERS_PVT.Copy_Quote(
		P_Api_Version_Number	=> 1.0,
		P_Init_Msg_List		=> FND_API.G_FALSE,
		P_Commit		=> p_commit,
		P_Qte_Header_Id		=> p_qte_header_id,
                P_control_rec           =>  l_control_rec,
		P_Last_Update_Date	=> p_last_update_date,
		P_Copy_Only_Header	=> p_copy_only_header,
		P_New_Version		=> p_new_version,
		P_Qte_Status_Id		=> p_qte_status_id,
		P_Qte_Number		=> p_qte_number,
		X_Qte_Header_Id		=> x_qte_header_id,
		X_Return_Status         => x_return_status,
		X_Msg_Count             => x_msg_count,
		X_Msg_Data              => x_msg_data);



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  l_NEW_Qte_Header_Id := x_qte_header_id;

  IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN
      ASO_QUOTE_CUHK.Copy_quote_POST(
    P_Qte_Header_Id		 => l_Qte_Header_Id,
    P_Last_Update_Date	  => l_Last_Update_Date,
    P_Copy_Only_Header		 => l_Copy_Only_Header,
    P_New_Version		 => l_New_Version,
    P_Qte_Status_Id		=> l_Qte_Status_Id	,
    P_Qte_Number		 => l_Qte_Number	,
    P_NEW_Qte_Header_Id  => l_NEW_Qte_Header_Id,
    X_Return_Status      => X_Return_Status ,
    X_Msg_Count           =>     X_Msg_Count,
    X_Msg_Data            =>        X_Msg_Data
    );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Copy_Quote_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook
      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN
      ASO_QUOTE_VUHK.Copy_quote_POST(
    P_Qte_Header_Id		 => l_Qte_Header_Id,
    P_Last_Update_Date	  => l_Last_Update_Date,
    P_Copy_Only_Header		 => l_Copy_Only_Header,
    P_New_Version		 => l_New_Version,
    P_Qte_Status_Id		=> l_Qte_Status_Id	,
    P_Qte_Number		 => l_Qte_Number	,
    P_NEW_Qte_Header_Id  => l_NEW_Qte_Header_Id,
    X_Return_Status      => X_Return_Status ,
    X_Msg_Count           =>     X_Msg_Count,
    X_Msg_Data            =>        X_Msg_Data
    );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Copy_Quote_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Copy_Quote;


-- Overloaded Copy_quote

PROCEDURE Copy_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_control_rec                IN  Control_Rec_Type,
    P_Qte_Header_Id       IN   NUMBER,
    P_Last_Update_Date         IN   DATE,
    P_Copy_Only_Header         IN   VARCHAR2    := FND_API.G_FALSE,
    P_New_Version         IN   VARCHAR2    := FND_API.G_FALSE,
    P_Qte_Status_Id       IN   NUMBER      := NULL,
    P_Qte_Number          IN   NUMBER      := NULL,
    X_Qte_Header_Id       OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

  l_api_name                CONSTANT VARCHAR2(30) := 'COPY_QUOTE';
    l_api_version_number      CONSTANT NUMBER   := 1.0;
    l_Qte_Header_Id  NUMBER;
    l_Last_Update_Date DATE;
    l_Copy_Only_Header VARCHAR2(30);
    l_New_Version VARCHAR2(30);
    l_Qte_Status_Id NUMBER;
    l_Qte_Number NUMBER;
    l_NEW_Qte_Header_Id NUMBER;
    BEGIN

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

  ASO_QUOTE_HEADERS_PVT.Copy_Quote(
		P_Api_Version_Number	=> 1.0,
		P_Init_Msg_List		=> FND_API.G_FALSE,
		P_Commit		=> p_commit,
		P_control_rec           =>  P_control_rec,
		P_Qte_Header_Id		=> p_qte_header_id,
		P_Last_Update_Date	=> p_last_update_date,
		P_Copy_Only_Header	=> p_copy_only_header,
		P_New_Version		=> p_new_version,
		P_Qte_Status_Id		=> p_qte_status_id,
		P_Qte_Number		=> p_qte_number,
		X_Qte_Header_Id		=> x_qte_header_id,
		X_Return_Status         => x_return_status,
		X_Msg_Count             => x_msg_count,
		X_Msg_Data              => x_msg_data);


END;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_qte_lines_Rec     IN    qte_line_Rec_Type         Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--       P_Payment_Tbl       IN    Payment_Tbl_Type
--       P_Price_Adj_Tbl     IN    Price_Adj_Tbl_Type
--       P_Qte_Line_Dtl_Rec  IN    Qte_Line_Dtl_Rec_Type
--       P_Shipment_Tbl      IN    Shipment_Tbl_Type
--       P_Tax_Detail_Tbl      IN    Tax_Detail_Tbl_Type
--       P_Freight_Charge_Tbl  IN    Freight_Charge_Tbl_Type
--       P_Line_Rltship_Tbl IN   Line_Rltship_Tbl_Type
--       P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type
--       P_Price_Adj_Rltship_Tbl IN Price_Adj_Rltship_Tbl_Type
--       P_Update_Header_Flag    IN   VARCHAR2     Optional  Default = FND_API.G_TRUE

--   OUT:
--       X_quote_line_id     OUT NOCOPY /* file.sql.39 change */  NUMBER,
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--


PROCEDURE Create_Quote_Line(
    P_Api_Version_Number   IN   NUMBER,
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit               IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Line_Rec         IN   Qte_Line_Rec_Type  := G_MISS_qte_line_REC,
    P_Control_Rec          IN   Control_rec_Type   := G_MISS_control_REC,
    P_Qte_Line_Dtl_TBL     IN   Qte_Line_Dtl_Tbl_Type  := G_MISS_qte_line_dtl_TBL,
    P_Line_Attribs_Ext_Tbl IN   Line_Attribs_Ext_Tbl_type
                                        := G_Miss_Line_Attribs_Ext_Tbl,
    P_Payment_Tbl          IN   Payment_Tbl_Type   := G_MISS_Payment_TBL,
    P_Price_Adj_Tbl        IN   Price_Adj_Tbl_Type := G_MISS_Price_Adj_TBL,
    P_Price_Attributes_Tbl IN   Price_Attributes_Tbl_Type := G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN  Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Shipment_Tbl          IN  Shipment_Tbl_Type   := G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN  Tax_Detail_Tbl_Type:= G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN  Freight_Charge_Tbl_Type   := G_MISS_freight_charge_TBL,
    P_Update_Header_Flag    IN  VARCHAR2   := FND_API.G_TRUE,
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  Qte_Line_Rec_Type,
    X_Qte_Line_Dtl_TBL      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_TBL_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type ,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
X_Sales_Credit_Tbl  Sales_Credit_Tbl_Type;
X_Quote_Party_Tbl   Quote_Party_Tbl_Type;
BEGIN

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

  Create_Quote_Line(
    P_Api_Version_Number  => p_api_version_number,
    P_Init_Msg_List       => p_init_msg_list,
    P_Commit              => p_commit,
    P_Qte_Line_Rec        => p_qte_line_rec,
    P_Control_REC         => p_control_rec   ,
    P_Payment_Tbl         => p_payment_tbl   ,
    P_Price_Adj_Tbl       => p_price_adj_tbl ,
    P_Qte_Line_Dtl_Tbl    => p_Qte_Line_Dtl_Tbl,
    P_Shipment_Tbl        => p_Shipment_Tbl ,
    P_Tax_Detail_Tbl      => p_Tax_Detail_Tbl ,
    P_Freight_Charge_Tbl  => p_Freight_Charge_Tbl,
    P_Price_Attributes_Tbl  => p_Price_Attributes_Tbl,
    P_Price_Adj_Attr_Tbl    =>p_Price_Adj_Attr_Tbl,
    P_Line_Attribs_Ext_Tbl  =>p_Line_Attribs_Ext_Tbl,
    P_Update_Header_Flag    =>p_Update_Header_Flag ,
    X_qte_line_rec         => X_qte_line_rec,
    X_payment_tbl	   => x_payment_tbl,
    X_Price_Adj_Tbl        => x_price_adj_tbl,
    X_Qte_Line_Dtl_Tbl     => x_qte_line_dtl_tbl,
    X_Shipment_Tbl         => x_shipment_tbl,
    X_Tax_Detail_Tbl       => x_tax_detail_tbl,
    X_Freight_Charge_Tbl   => x_freight_charge_tbl,
    X_Price_Attributes_Tbl => x_price_attributes_tbl,
    X_Price_Adj_Attr_Tbl    => x_Price_Adj_Attr_Tbl,
    X_Line_Attribs_Ext_Tbl  => x_Line_Attribs_Ext_Tbl,
    X_Sales_Credit_Tbl      => X_Sales_Credit_Tbl ,
    X_Quote_Party_Tbl       => X_Quote_Party_Tbl,
    X_Return_Status        => x_return_status,
    X_Msg_Count            => x_msg_count,
    X_Msg_Data             => x_msg_data
    );

END Create_Quote_Line;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_qte_lines_Rec     IN    qte_line_Rec_Type         Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--       P_Payment_Tbl       IN    Payment_Tbl_Type
--       P_Price_Adj_Tbl     IN    Price_Adj_Tbl_Type
--       P_Qte_Line_Dtl_Rec  IN    Qte_Line_Dtl_Rec_Type
--       P_Shipment_Tbl      IN    Shipment_Tbl_Type
--       P_Tax_Detail_Tbl      IN    Tax_Detail_Tbl_Type
--       P_Freight_Charge_Tbl  IN    Freight_Charge_Tbl_Type
--       P_Line_Rltship_Tbl IN   Line_Rltship_Tbl_Type
--       P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type
--       P_Price_Adj_Rltship_Tbl IN Price_Adj_Rltship_Tbl_Type
--       P_Update_Header_Flag    IN   VARCHAR2     Optional  Default = FND_API.G_TRUE
--   OUT:
--       X_quote_line_id     OUT NOCOPY /* file.sql.39 change */  NUMBER,
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.

PROCEDURE Update_Quote_Line(
    P_Api_Version_Number   IN   NUMBER,
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit               IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Line_Rec         IN   Qte_Line_Rec_Type  := G_MISS_qte_line_REC,
    P_Control_Rec          IN   Control_rec_Type   := G_MISS_control_REC,
    P_Qte_Line_Dtl_Tbl     IN   Qte_Line_Dtl_Tbl_Type  := G_MISS_qte_line_dtl_TBL,
    P_Line_Attribs_Ext_Tbl IN   Line_Attribs_Ext_Tbl_type
                                        := G_Miss_Line_Attribs_Ext_Tbl,
    P_Payment_Tbl          IN   Payment_Tbl_Type   := G_MISS_Payment_TBL,
    P_Price_Adj_Tbl        IN   Price_Adj_Tbl_Type := G_MISS_Price_Adj_TBL,
    P_Price_Attributes_Tbl IN   Price_Attributes_Tbl_Type := G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN  Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Shipment_Tbl          IN  Shipment_Tbl_Type   := G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN  Tax_Detail_Tbl_Type:= G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN  Freight_Charge_Tbl_Type   := G_MISS_freight_charge_TBL,
    P_Update_Header_Flag    IN  VARCHAR2   := FND_API.G_TRUE,
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  Qte_Line_Rec_Type,
    X_Qte_Line_Dtl_Tbl      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type ,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

X_Sales_Credit_Tbl  Sales_Credit_Tbl_Type;
X_Quote_Party_Tbl   Quote_Party_Tbl_Type;
BEGIN

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

Update_Quote_Line(
    P_Api_Version_Number  => 1.0,
    P_Init_Msg_List       => p_init_msg_list,
    P_Commit              => p_commit,
    P_Qte_Line_Rec        => p_qte_line_rec,
    P_Control_REC         => p_control_rec      ,
    P_Payment_Tbl         => p_payment_tbl      ,
    P_Price_Adj_Tbl       => p_price_adj_tbl ,
    P_Qte_Line_Dtl_TBL    => p_Qte_Line_Dtl_TBL ,
    P_Shipment_Tbl        => p_Shipment_Tbl ,
    P_Tax_Detail_Tbl      => p_Tax_Detail_Tbl ,
    P_Freight_Charge_Tbl  => p_Freight_Charge_Tbl,
    P_Price_Attributes_Tbl => p_Price_Attributes_Tbl,
    P_Price_Adj_Attr_Tbl    =>p_Price_Adj_Attr_Tbl,
    P_Line_Attribs_Ext_Tbl  =>p_Line_Attribs_Ext_Tbl,
    P_Update_Header_Flag    =>p_Update_Header_Flag ,
    X_qte_line_rec         => X_qte_line_rec,
    X_payment_tbl	   => x_payment_tbl,
    X_Price_Adj_Tbl        => x_price_adj_tbl,
    X_Qte_Line_Dtl_tbl     => x_qte_line_dtl_tbl,
    X_Shipment_Tbl         => x_shipment_tbl,
    X_Tax_Detail_Tbl       => x_tax_detail_tbl,
    X_Freight_Charge_Tbl   => x_freight_charge_tbl,
    X_Price_Attributes_Tbl => x_price_attributes_tbl,
    X_Price_Adj_Attr_Tbl    =>x_Price_Adj_Attr_Tbl,
    X_Line_Attribs_Ext_Tbl  =>x_Line_Attribs_Ext_Tbl,
    X_Sales_Credit_Tbl      => X_Sales_Credit_Tbl,
    X_Quote_Party_Tbl       => X_Quote_Party_Tbl,
    X_Return_Status        => x_return_status,
    X_Msg_Count            => x_msg_count,
    X_Msg_Data             => x_msg_data
    );

END Update_Quote_Line;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_qte_line_Rec      IN qte_line_Rec_Type  Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.

PROCEDURE Delete_Quote_Line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_qte_line_Rec     IN qte_line_Rec_Type,
    P_Control_Rec      IN    Control_rec_Type   := G_MISS_control_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

BEGIN
aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
   Delete_Quote_Line(
    P_Api_Version_Number  => 1.0,
    P_Init_Msg_List       => P_Init_Msg_List  ,
    P_Commit              => p_commit,
    P_qte_line_Rec        => P_qte_line_Rec,
    P_Control_Rec         => p_control_rec,
    P_Update_Header_Flag  => 'N',
    X_Return_Status       => X_Return_Status,
    X_Msg_Count           => x_msg_count,
    X_Msg_Data            => x_msg_data
    );
End Delete_quote_line;


-- added by kchervel 06/26/00


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--   Version : Current version 2.0
--   Note: This is an overloaded procedure. It takes additional attributes
--   which include the hd_attributes, sales credits and quote party record
--   types
--
--   End of Comments
--

PROCEDURE Create_quote(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Validation_Level 	      IN   NUMBER                                  := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		      IN   Control_Rec_Type                        := G_Miss_Control_Rec,
    P_Qte_Header_Rec		 IN   Qte_Header_Rec_Type                     := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec		 IN   ASO_QUOTE_PUB.Shipment_Rec_Type         := G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl      IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl       IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		      IN   Qte_Line_Tbl_Type                       := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   Qte_Line_Dtl_Tbl_Type                   := G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   Line_Rltship_Tbl_Type                   := G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   Price_Adj_Tbl_Type                      := G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	      IN   Price_Adj_Attr_Tbl_Type                 := G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   Price_Adj_Rltship_Tbl_Type              := G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	 IN   Price_Attributes_Tbl_Type               := G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		 IN   Payment_Tbl_Type                        := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		 IN   Shipment_Tbl_Type                       := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	 IN   Freight_Charge_Tbl_Type                 := G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		 IN   Tax_Detail_Tbl_Type                     := G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl      IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl       IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Rec		 OUT NOCOPY /* file.sql.39 change */  Shipment_Rec_Type,
    X_Hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	      OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Return_Status            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
 x_Qte_Access_Tbl            Qte_Access_Tbl_Type;
 x_Template_Tbl              Template_Tbl_Type;
 X_Related_Obj_Tbl           Related_Obj_Tbl_Type;
BEGIN
   aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

   if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('Before call to the second overloaded create_quote procedure.',1, 'Y');
   end if;

   Create_quote(
	    P_Api_Version_Number	      => 1.0,
	    P_Init_Msg_List		      => p_init_msg_list,
	    P_Commit			      => p_commit,
	    P_Control_Rec		      => p_control_rec,
	    P_qte_header_rec		 => p_qte_header_rec,
	    P_Hd_Price_Attributes_Tbl	 => p_Hd_Price_Attributes_Tbl,
	    P_Hd_Payment_Tbl		 => p_Hd_Payment_Tbl,
	    P_Hd_Shipment_Rec		 => p_Hd_Shipment_Rec,
	    P_Hd_Freight_Charge_Tbl	 => p_Hd_Freight_Charge_Tbl,
	    P_Hd_Tax_Detail_Tbl		 => p_Hd_Tax_Detail_Tbl,
	    P_Qte_Line_Tbl		      => p_Qte_Line_Tbl,
	    P_Qte_Line_Dtl_Tbl		 => p_Qte_Line_Dtl_Tbl,
	    P_Line_Attr_Ext_Tbl		 => P_Line_Attr_Ext_Tbl,
	    P_Line_rltship_tbl		 => p_Line_Rltship_Tbl,
	    P_Price_Adjustment_Tbl	 => p_Price_Adjustment_Tbl,
	    P_Price_Adj_Attr_Tbl	      => P_Price_Adj_Attr_Tbl,
	    P_Price_Adj_Rltship_Tbl	 => p_Price_Adj_Rltship_Tbl,
	    P_Ln_Price_Attributes_Tbl	 => p_Ln_Price_Attributes_Tbl,
	    P_Ln_Payment_Tbl		 => p_Ln_Payment_Tbl,
	    P_Ln_Shipment_Tbl		 => p_Ln_Shipment_Tbl,
	    P_Ln_Freight_Charge_Tbl	 => p_Ln_Freight_Charge_Tbl,
	    P_Ln_Tax_Detail_Tbl		 => p_Ln_Tax_Detail_Tbl,
	    x_qte_header_rec		 => x_qte_header_rec,
	    X_Hd_Price_Attributes_Tbl	 => x_Hd_Price_Attributes_Tbl,
	    X_Hd_Payment_Tbl		 => x_Hd_Payment_Tbl,
	    X_Hd_Shipment_Rec		 => x_Hd_Shipment_Rec,
	    X_Hd_Freight_Charge_Tbl	 => x_Hd_Freight_Charge_Tbl,
	    X_Hd_Tax_Detail_Tbl		 => x_Hd_Tax_Detail_Tbl,
         X_hd_Attr_Ext_Tbl		 => x_hd_Attr_Ext_Tbl,
         X_hd_Sales_Credit_Tbl      => x_hd_Sales_Credit_Tbl,
         X_hd_Quote_Party_Tbl       => x_hd_Quote_Party_Tbl,
	    X_Qte_Line_Tbl		      => x_Qte_Line_Tbl,
	    X_Qte_Line_Dtl_Tbl		 => x_Qte_Line_Dtl_Tbl,
	    x_Line_Attr_Ext_Tbl		 => x_Line_Attr_Ext_Tbl,
	    X_Line_rltship_tbl		 => x_Line_Rltship_Tbl,
	    X_Price_Adjustment_Tbl	 => x_Price_Adjustment_Tbl,
	    x_Price_Adj_Attr_Tbl	      => x_Price_Adj_Attr_Tbl,
	    X_Price_Adj_Rltship_Tbl	 => x_Price_Adj_Rltship_Tbl,
	    X_Ln_Price_Attributes_Tbl	 => x_Ln_Price_Attributes_Tbl,
	    X_Ln_Payment_Tbl		 => x_Ln_Payment_Tbl,
	    X_Ln_Shipment_Tbl		 => x_Ln_Shipment_Tbl,
	    X_Ln_Freight_Charge_Tbl	 => x_Ln_Freight_Charge_Tbl,
	    X_Ln_Tax_Detail_Tbl		 => x_Ln_Tax_Detail_Tbl,
         X_Ln_Sales_Credit_Tbl      => x_ln_Sales_Credit_Tbl,
         X_Ln_Quote_Party_Tbl       => x_ln_Quote_Party_Tbl,
         x_Qte_Access_Tbl           => x_Qte_Access_Tbl,
         x_Template_Tbl             => x_Template_Tbl,
	    X_Related_Obj_Tbl          => X_Related_Obj_Tbl,
	    X_Return_Status            => x_return_status,
	    X_Msg_Count                => x_msg_count,
	    X_Msg_Data                 => x_msg_data);

   if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('After call to the second overloaded create_quote procedure: x_return_status: '|| x_return_status, 1, 'Y');
   end if;

END Create_Quote;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--  This is an overloaded procedure. It takes additional attributes
--  which include the hd_attributes, sales credits and quote party record types


PROCEDURE Update_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Validation_Level 	        IN   NUMBER                                  := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		        IN   Control_Rec_Type                        := G_Miss_Control_Rec,
    P_Qte_Header_Rec		   IN   Qte_Header_Rec_Type                     := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		   IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Tbl		   IN   ASO_QUOTE_PUB.Shipment_Tbl_Type         := G_MISS_SHIPMENT_TBL,
    P_hd_Freight_Charge_Tbl	   IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		   IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		   IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		        IN   Qte_Line_Tbl_Type                       := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		   IN   Qte_Line_Dtl_Tbl_Type                   := G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		   IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		   IN   Line_Rltship_Tbl_Type                   := G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	   IN   Price_Adj_Tbl_Type                      := G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	        IN   Price_Adj_Attr_Tbl_Type                 := G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	   IN   Price_Adj_Rltship_Tbl_Type              := G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	   IN   Price_Attributes_Tbl_Type               := G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		   IN   Payment_Tbl_Type                        := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		   IN   Shipment_Tbl_Type                       := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	   IN   Freight_Charge_Tbl_Type                 := G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		   IN   Tax_Detail_Tbl_Type                     := G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    x_Qte_Header_Rec		   OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		        OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		   OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Hd_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		   OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	        OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		   OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    x_Qte_Access_Tbl           Qte_Access_Tbl_Type;
    x_Template_Tbl             Template_Tbl_Type;
    X_Related_Obj_Tbl          Related_Obj_Tbl_Type;
BEGIN
     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     if aso_debug_pub.g_debug_flag = 'Y' then
         aso_debug_pub.add('Before call to the second overloaded update_quote procedure.',1, 'Y');
     end if;

     Update_quote(
	    P_Api_Version_Number	      => 1.0,
	    P_Init_Msg_List		      => p_init_msg_list,
	    P_Commit			      => p_commit,
	    P_Control_Rec		      => p_control_rec,
	    P_qte_header_rec		 => p_qte_header_rec,
	    P_Hd_Price_Attributes_Tbl	 => p_Hd_Price_Attributes_Tbl,
	    P_Hd_Payment_Tbl		 => p_Hd_Payment_Tbl,
	    P_Hd_Shipment_Tbl		 => p_Hd_Shipment_Tbl,
	    P_hd_Sales_Credit_Tbl	 => P_hd_Sales_Credit_Tbl,   --Yogeshwar(# Added parameter to address sales credit allocation issue)
	    P_ln_Sales_Credit_Tbl	 => P_ln_Sales_Credit_Tbl,   --Yogeshwar(# Added parameter to address sales credit allocation issue)
	    P_Hd_Freight_Charge_Tbl	 => p_Hd_Freight_Charge_Tbl,
	    P_Hd_Tax_Detail_Tbl		 => p_Hd_Tax_Detail_Tbl,
	    P_Qte_Line_Tbl		      => p_Qte_Line_Tbl,
	    P_Qte_Line_Dtl_Tbl		 => p_Qte_Line_Dtl_Tbl,
	    P_Line_Attr_Ext_Tbl		 => P_Line_Attr_Ext_Tbl,
	    P_Line_rltship_tbl		 => p_Line_Rltship_Tbl,
	    P_Price_Adjustment_Tbl	 => p_Price_Adjustment_Tbl,
	    P_Price_Adj_Attr_Tbl	      => P_Price_Adj_Attr_Tbl,
	    P_Price_Adj_Rltship_Tbl	 => p_Price_Adj_Rltship_Tbl,
	    P_Ln_Price_Attributes_Tbl	 => p_Ln_Price_Attributes_Tbl,
	    P_Ln_Payment_Tbl		 => p_Ln_Payment_Tbl,
	    P_Ln_Shipment_Tbl		 => p_Ln_Shipment_Tbl,
	    P_Ln_Freight_Charge_Tbl	 => p_Ln_Freight_Charge_Tbl,
	    P_Ln_Tax_Detail_Tbl		 => p_Ln_Tax_Detail_Tbl,
	    x_qte_header_rec		 => x_qte_header_rec,
	    X_Hd_Price_Attributes_Tbl	 => x_Hd_Price_Attributes_Tbl,
	    X_Hd_Payment_Tbl		 => x_Hd_Payment_Tbl,
	    X_Hd_Shipment_tbl		 => x_Hd_Shipment_tbl,
	    X_Hd_Freight_Charge_Tbl	 => x_Hd_Freight_Charge_Tbl,
	    X_Hd_Tax_Detail_Tbl		 => x_Hd_Tax_Detail_Tbl,
         X_hd_Attr_Ext_Tbl		 => X_hd_Attr_Ext_Tbl,
         X_hd_Sales_Credit_Tbl      => X_hd_Sales_Credit_Tbl,
         X_hd_Quote_Party_Tbl       => X_hd_Quote_Party_Tbl,
	    X_Qte_Line_Tbl		      => x_Qte_Line_Tbl,
	    X_Qte_Line_Dtl_Tbl		 => x_Qte_Line_Dtl_Tbl,
	    x_Line_Attr_Ext_Tbl		 => x_Line_Attr_Ext_Tbl,
	    X_Line_rltship_tbl		 => x_Line_Rltship_Tbl,
	    X_Price_Adjustment_Tbl	 => x_Price_Adjustment_Tbl,
	    x_Price_Adj_Attr_Tbl	      => x_Price_Adj_Attr_Tbl,
	    X_Price_Adj_Rltship_Tbl	 => x_Price_Adj_Rltship_Tbl,
	    X_Ln_Price_Attributes_Tbl	 => x_Ln_Price_Attributes_Tbl,
	    X_Ln_Payment_Tbl		 => x_Ln_Payment_Tbl,
	    X_Ln_Shipment_Tbl		 => x_Ln_Shipment_Tbl,
	    X_Ln_Freight_Charge_Tbl	 => x_Ln_Freight_Charge_Tbl,
	    X_Ln_Tax_Detail_Tbl		 => x_Ln_Tax_Detail_Tbl,
         X_Ln_Sales_Credit_Tbl      => X_ln_Sales_Credit_Tbl,
         X_Ln_Quote_Party_Tbl       => X_ln_Quote_Party_Tbl,
         x_Qte_Access_Tbl           => x_Qte_Access_Tbl,
         x_Template_Tbl             => x_Template_Tbl,
	    X_Related_Obj_Tbl          => X_Related_Obj_Tbl,
	    X_Return_Status            => x_return_status,
	    X_Msg_Count                => x_msg_count,
	    X_Msg_Data                 => x_msg_data);

   if aso_debug_pub.g_debug_flag = 'Y' then
       aso_debug_pub.add('After call to the second overloaded update_quote procedure: x_return_status: '|| x_return_status, 1, 'Y');
   end if;

End Update_quote;





--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   overloaded function includes the p_commit flag
--
--   End of Comments
--
PROCEDURE Submit_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_commit                     IN   VARCHAR2 ,
    p_control_rec		        IN   Submit_Control_Rec_Type
					                          := G_MISS_Submit_Control_Rec,
    P_Qte_Header_Id		        IN   NUMBER,
    x_order_header_rec		   OUT NOCOPY /* file.sql.39 change */  Order_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
BEGIN
aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
Submit_quote(
    P_Api_Version_Number       => P_Api_Version_Number,
    P_Init_Msg_List            =>  P_Init_Msg_List  ,
    P_control_rec		=> P_control_rec,
    P_Qte_Header_Id	 => 	P_Qte_Header_Id,
    x_order_header_rec		 => x_order_header_rec,
    X_Return_Status              => X_Return_Status,
    X_Msg_Count                  => X_Msg_Count,
    X_Msg_Data                   => X_Msg_Data
    );
  IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
END;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:


--
--   End of Comments
--
PROCEDURE Create_Quote_Line(

    P_Api_Version_Number   IN   NUMBER,
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit               IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Rec           IN    Qte_Header_Rec_Type  := G_MISS_Qte_Header_Rec,
    P_Qte_Line_Rec         IN   Qte_Line_Rec_Type  := G_MISS_qte_line_REC,
    P_Control_Rec          IN   Control_rec_Type   := G_MISS_control_REC,
    P_Qte_Line_Dtl_Tbl    IN   Qte_Line_Dtl_Tbl_Type:= G_MISS_qte_line_dtl_TBL,
    P_Line_Attribs_Ext_Tbl IN   Line_Attribs_Ext_Tbl_type
                                        := G_Miss_Line_Attribs_Ext_Tbl,
    P_Payment_Tbl          IN   Payment_Tbl_Type   := G_MISS_Payment_TBL,
    P_Price_Adj_Tbl        IN   Price_Adj_Tbl_Type := G_MISS_Price_Adj_TBL,
    P_Price_Attributes_Tbl IN   Price_Attributes_Tbl_Type := G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN  Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Shipment_Tbl          IN  Shipment_Tbl_Type   := G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN  Tax_Detail_Tbl_Type:= G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN  Freight_Charge_Tbl_Type   := G_MISS_freight_charge_TBL,
    P_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    P_Update_Header_Flag    IN  VARCHAR2   := FND_API.G_TRUE,
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  Qte_Line_Rec_Type,
    X_Qte_Line_Dtl_TBL      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_TBL_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type ,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_QUOTE_LINE';
    l_api_version_number      CONSTANT NUMBER   := 1.0;


        l_Qte_Line_Rec          Qte_Line_Rec_Type  ;
        l_Qte_Line_Rec_out      Qte_Line_Rec_Type  ;
        l_Payment_Tbl           Payment_Tbl_Type ;
        l_Price_Adj_Tbl         Price_Adj_Tbl_Type;
	l_Qte_Line_Dtl_rec      Qte_Line_Dtl_rec_Type ;
	l_Shipment_Tbl          Shipment_Tbl_Type;
	l_Tax_Detail_Tbl        Tax_Detail_Tbl_Type;
	l_Freight_Charge_Tbl    Freight_Charge_Tbl_Type;
	l_Line_Rltship_Tbl      Line_Rltship_Tbl_Type;
	l_Price_Attributes_Tbl  Price_Attributes_Tbl_Type;
	l_Price_Adj_rltship_Tbl Price_Adj_Rltship_Tbl_Type;
	l_Price_Adj_Attr_Tbl    Price_Adj_Attr_Tbl_Type;
	l_Line_Attribs_Ext_Tbl  Line_Attribs_Ext_Tbl_type;
	l_Qte_Line_Dtl_tbl      Qte_Line_Dtl_tbl_Type;
        l_Sales_Credit_Tbl      Sales_Credit_Tbl_Type ;
        l_Quote_Party_Tbl       Quote_Party_Tbl_Type;
        l_Control_Rec           Control_rec_Type;
        l_update_header_flag    VARCHAR2(10);

    my_message   VARCHAR2(2000);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_QUOTE_LINE_PUB;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- mapping to local variables

        l_Qte_Line_Rec          := p_Qte_Line_Rec  ;
        l_Payment_Tbl           := p_Payment_Tbl   ;
        l_Price_Adj_Tbl         := p_Price_Adj_Tbl ;
	l_Shipment_Tbl          := p_Shipment_Tbl  ;
	l_Tax_Detail_Tbl        := p_Tax_Detail_Tbl;
	l_Freight_Charge_Tbl    := p_Freight_Charge_Tbl   ;
--	l_Line_Rltship_Tbl      := p_Line_Rltship_Tbl     ;
	l_Price_Attributes_Tbl  := p_Price_Attributes_Tbl ;
--	l_Price_Adj_rltship_Tbl := p_Price_Adj_Rltship_Tbl;
	l_Price_Adj_Attr_Tbl    := p_Price_Adj_Attr_Tbl   ;
	l_Line_Attribs_Ext_Tbl  := p_Line_Attribs_Ext_Tbl ;
	l_Qte_Line_Dtl_tbl      := p_Qte_Line_Dtl_tbl     ;
        l_control_rec           := p_control_rec          ;
        l_update_header_flag    := p_update_header_flag   ;
        l_Quote_Party_Tbl       := P_Quote_Party_Tbl      ;
        l_Sales_Credit_Tbl      := P_Sales_Credit_Tbl     ;


      --  call user hooks
      -- customer pre processing

        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN
          ASO_QUOTE_CUHK.Create_Quote_Line_PRE(
    	  P_Qte_Line_Rec        => l_qte_line_rec      ,
    	  P_Control_Rec         => l_control_rec       ,
    	  P_Qte_Line_Dtl_Tbl    => l_qte_line_dtl_tbl  ,
    	  P_Line_Attribs_Ext_Tbl =>l_line_attribs_ext_tbl,
          P_Payment_Tbl         => l_payment_tbl,
    	  P_Price_Adj_Tbl       => l_price_adj_tbl,
    	  P_Price_Attributes_Tbl =>l_price_attributes_tbl,
    	  P_Price_Adj_Attr_Tbl  => l_price_adj_attr_tbl,
          P_Shipment_Tbl        => l_shipment_tbl      ,
    	  P_Tax_Detail_Tbl      => l_tax_detail_tbl    ,
    	  P_Freight_Charge_Tbl  => l_freight_charge_tbl,
          P_Sales_Credit_Tbl    => l_Sales_Credit_Tbl  ,
          P_Quote_Party_Tbl     => l_Quote_Party_Tbl,
    	  P_Update_Header_Flag  => l_update_header_flag,
    	  X_Return_Status       => x_return_status ,
    	  X_Msg_Count           => x_msg_count     ,
          X_Msg_Data            => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Create_Quote_Line_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook


      -- vertical hook
        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN
          ASO_QUOTE_VUHK.Create_Quote_Line_PRE(
    	  P_Qte_Line_Rec        => l_qte_line_rec      ,
    	  P_Control_Rec         => l_control_rec       ,
    	  P_Qte_Line_Dtl_Tbl    => l_qte_line_dtl_tbl  ,
    	  P_Line_Attribs_Ext_Tbl =>l_line_attribs_ext_tbl,
          P_Payment_Tbl         => l_payment_tbl,
    	  P_Price_Adj_Tbl       => l_price_adj_tbl,
    	  P_Price_Attributes_Tbl =>l_price_attributes_tbl,
    	  P_Price_Adj_Attr_Tbl  => l_price_adj_attr_tbl,
          P_Shipment_Tbl        => l_shipment_tbl      ,
    	  P_Tax_Detail_Tbl      => l_tax_detail_tbl    ,
    	  P_Freight_Charge_Tbl  => l_freight_charge_tbl,
          P_Sales_Credit_Tbl    => l_Sales_Credit_Tbl  ,
          P_Quote_Party_Tbl     => l_Quote_Party_Tbl,
    	  P_Update_Header_Flag  => l_update_header_flag,
    	  X_Return_Status       => x_return_status ,
    	  X_Msg_Count           => x_msg_count     ,
          X_Msg_Data            => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Create_Quote_Line_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook




      -- Convert the values to ids
      Convert_Line_Values_To_Ids (
	    p_qte_line_rec	=> l_qte_line_rec,
	    x_qte_line_rec	=> l_qte_line_rec_out);

	    l_qte_line_rec := l_qte_line_rec_out;


/*      FOR i IN 1..p_shipment_tbl.count LOOP
        Convert_Shipment_Values_To_Ids (
	    p_shipment_rec	=> p_shipment_tbl(i),
	    x_shipment_rec	=> l_shipment_tbl(i));
      END LOOP;
*/

     -- Call Private API
  ASO_QUOTE_LINES_PVT.Create_Quote_Lines(
    P_Api_Version_Number  => 1.0,
    P_Init_Msg_List       => p_init_msg_list,
    P_Commit              => p_commit,
 --   P_Validation_Level    => ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM,
    P_Validation_Level    => FND_API.G_VALID_LEVEL_FULL,
    p_qte_header_rec      => p_qte_header_rec,
    P_Qte_Line_Rec        => l_qte_line_rec,
    P_Control_REC         => l_control_rec   ,
    P_Payment_Tbl         => l_payment_tbl   ,
    P_Price_Adj_Tbl       => l_price_adj_tbl ,
    P_Qte_Line_Dtl_Tbl    => l_Qte_Line_Dtl_Tbl,
    P_Shipment_Tbl        => l_Shipment_Tbl ,
    P_Tax_Detail_Tbl      => l_Tax_Detail_Tbl ,
    P_Freight_Charge_Tbl  => l_Freight_Charge_Tbl,
    P_Price_Attributes_Tbl => l_Price_Attributes_Tbl,
    P_Price_Adj_Attr_Tbl    =>l_Price_Adj_Attr_Tbl,
    P_Line_Attribs_Ext_Tbl  =>l_Line_Attribs_Ext_Tbl,
    P_Sales_Credit_Tbl    => l_Sales_Credit_Tbl  ,
    P_Quote_Party_Tbl     => l_Quote_Party_Tbl,
    P_Update_Header_Flag    =>l_Update_Header_Flag ,
    X_qte_line_rec         => X_qte_line_rec,
    X_payment_tbl	   => x_payment_tbl,
    X_Price_Adj_Tbl        => x_price_adj_tbl,
    X_Qte_Line_Dtl_Tbl     => x_qte_line_dtl_tbl,
    X_Shipment_Tbl         => x_shipment_tbl,
    X_Tax_Detail_Tbl       => x_tax_detail_tbl,
    X_Freight_Charge_Tbl   => x_freight_charge_tbl,
    X_Price_Attributes_Tbl => x_price_attributes_tbl,
    X_Price_Adj_Attr_Tbl    => x_Price_Adj_Attr_Tbl,
    X_Line_Attribs_Ext_Tbl  => x_Line_Attribs_Ext_Tbl,
    X_Sales_Credit_Tbl      => X_Sales_Credit_Tbl,
    X_Quote_Party_Tbl      => X_Quote_Party_Tbl,
    X_Return_Status        => x_return_status,
    X_Msg_Count            => x_msg_count,
    X_Msg_Data             => x_msg_data
    );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
 my_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);
        while (my_message is not null) loop
            my_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);
        end loop;

      --
      -- End of API body.
      --



       --  call user hooks
      -- customer post processing

        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN
          ASO_QUOTE_CUHK.Create_Quote_Line_POST(
    	  P_Qte_Line_Rec        => x_qte_line_rec      ,
    	  P_Control_Rec         => l_control_rec       ,
    	  P_Qte_Line_Dtl_Tbl    => x_qte_line_dtl_tbl  ,
    	  P_Line_Attribs_Ext_Tbl =>x_line_attribs_ext_tbl,
          P_Payment_Tbl         => x_payment_tbl,
    	  P_Price_Adj_Tbl       => x_price_adj_tbl,
    	  P_Price_Attributes_Tbl =>x_price_attributes_tbl,
    	  P_Price_Adj_Attr_Tbl  => x_price_adj_attr_tbl,
          P_Shipment_Tbl        => x_shipment_tbl      ,
    	  P_Tax_Detail_Tbl      => x_tax_detail_tbl    ,
    	  P_Freight_Charge_Tbl  => x_freight_charge_tbl,
           P_Sales_Credit_Tbl    => x_Sales_Credit_Tbl  ,
          P_Quote_Party_Tbl     => x_Quote_Party_Tbl,
    	  P_Update_Header_Flag  => l_update_header_flag,
    	  X_Return_Status       => x_return_status ,
    	  X_Msg_Count           => x_msg_count     ,
          X_Msg_Data            => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Create_Quote_Line_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('aso_quote_vuhk: before if create quote line post (1) '||x_return_status,1, 'N');
	 END IF;

      -- vertical hook
        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN
	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('aso_quote_vuhk: inside if create quote line post (1)'||x_return_status,1, 'N');
	    END IF;
          ASO_QUOTE_VUHK.Create_Quote_Line_POST(
    	  P_Qte_Line_Rec        => x_qte_line_rec      ,
    	  P_Control_Rec         => l_control_rec       ,
    	  P_Qte_Line_Dtl_Tbl    => x_qte_line_dtl_tbl  ,
    	  P_Line_Attribs_Ext_Tbl =>x_line_attribs_ext_tbl,
          P_Payment_Tbl         => x_payment_tbl,
    	  P_Price_Adj_Tbl       => x_price_adj_tbl,
    	  P_Price_Attributes_Tbl =>x_price_attributes_tbl,
    	  P_Price_Adj_Attr_Tbl  => x_price_adj_attr_tbl,
          P_Shipment_Tbl        => x_shipment_tbl      ,
    	  P_Tax_Detail_Tbl      => x_tax_detail_tbl    ,
    	  P_Freight_Charge_Tbl  => x_freight_charge_tbl,
           P_Sales_Credit_Tbl    => x_Sales_Credit_Tbl  ,
          P_Quote_Party_Tbl     => x_Quote_Party_Tbl,
    	  P_Update_Header_Flag  => l_update_header_flag,
    	  X_Return_Status       => x_return_status ,
    	  X_Msg_Count           => x_msg_count     ,
          X_Msg_Data            => x_msg_data
          );

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('aso_quote_vuhk: after if create quote line post (1)'||x_return_status,1, 'N');
	    END IF;


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Create_Quote_Line_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook




      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN

PROCEDURE Update_Quote_Line(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Rec           IN    Qte_Header_Rec_Type  := G_MISS_Qte_Header_Rec,
    P_Qte_Line_Rec        IN    Qte_Line_Rec_Type  := G_MISS_qte_line_REC,
    P_Control_Rec         IN    Control_rec_Type   := G_MISS_control_REC,
    P_Qte_Line_Dtl_TBL   IN    Qte_Line_Dtl_tbl_Type:= G_MISS_qte_line_dtl_TBL,
    P_Line_Attribs_Ext_Tbl  IN   Line_Attribs_Ext_Tbl_type
                                        := G_Miss_Line_Attribs_Ext_Tbl,
    P_Payment_Tbl           IN    Payment_Tbl_Type   := G_MISS_Payment_TBL,
    P_Price_Adj_Tbl         IN    Price_Adj_Tbl_Type := G_MISS_Price_Adj_TBL,
    P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type := G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN   Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Shipment_Tbl          IN    Shipment_Tbl_Type   := G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN    Tax_Detail_Tbl_Type:= G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN   Freight_Charge_Tbl_Type   := G_MISS_freight_charge_TBL,
    P_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    P_Update_Header_Flag    IN   VARCHAR2   := FND_API.G_TRUE,
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  Qte_Line_Rec_Type,
    X_Qte_Line_Dtl_TBL      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_TBL_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type ,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

     l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_QUOTE_LINE';
    l_api_version_number      CONSTANT NUMBER   := 1.0;


        l_Qte_Line_Rec          Qte_Line_Rec_Type  ;
        l_Qte_Line_Rec_out      Qte_Line_Rec_Type  ;
        l_Payment_Tbl           Payment_Tbl_Type ;
        l_Price_Adj_Tbl         Price_Adj_Tbl_Type;
	l_Qte_Line_Dtl_rec      Qte_Line_Dtl_rec_Type ;
	l_Shipment_Tbl          Shipment_Tbl_Type;
	l_Tax_Detail_Tbl        Tax_Detail_Tbl_Type;
	l_Freight_Charge_Tbl    Freight_Charge_Tbl_Type;
	l_Line_Rltship_Tbl      Line_Rltship_Tbl_Type;
	l_Price_Attributes_Tbl  Price_Attributes_Tbl_Type;
	l_Price_Adj_rltship_Tbl Price_Adj_Rltship_Tbl_Type;
	l_Price_Adj_Attr_Tbl    Price_Adj_Attr_Tbl_Type;
	l_Line_Attribs_Ext_Tbl  Line_Attribs_Ext_Tbl_type;
	l_Qte_Line_Dtl_tbl      Qte_Line_Dtl_tbl_Type;
        l_Control_Rec           Control_rec_Type;
        l_update_header_flag    VARCHAR2(10);
          l_Sales_Credit_Tbl      Sales_Credit_Tbl_Type ;
        l_Quote_Party_Tbl       Quote_Party_Tbl_Type;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_QUOTE_LINE_PUB;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

             -- mapping to local variables

        l_Qte_Line_Rec          := p_Qte_Line_Rec  ;
        l_Payment_Tbl           := p_Payment_Tbl   ;
        l_Price_Adj_Tbl         := p_Price_Adj_Tbl ;
	l_Shipment_Tbl          := p_Shipment_Tbl  ;
	l_Tax_Detail_Tbl        := p_Tax_Detail_Tbl;
	l_Freight_Charge_Tbl    := p_Freight_Charge_Tbl   ;
--	l_Line_Rltship_Tbl      := p_Line_Rltship_Tbl     ;
	l_Price_Attributes_Tbl  := p_Price_Attributes_Tbl ;
--	l_Price_Adj_rltship_Tbl := p_Price_Adj_Rltship_Tbl;
	l_Price_Adj_Attr_Tbl    := p_Price_Adj_Attr_Tbl   ;
	l_Line_Attribs_Ext_Tbl  := p_Line_Attribs_Ext_Tbl ;
	l_Qte_Line_Dtl_tbl      := p_Qte_Line_Dtl_tbl     ;
        l_control_rec           := p_control_rec          ;
        l_update_header_flag    := p_update_header_flag   ;
        l_Quote_Party_Tbl       := P_Quote_Party_Tbl      ;
        l_Sales_Credit_Tbl      := P_Sales_Credit_Tbl     ;





      --  call user hooks
      -- customer pre processing

        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN
          ASO_QUOTE_CUHK.Update_Quote_Line_PRE(
    	  P_Qte_Line_Rec        => l_qte_line_rec      ,
    	  P_Control_Rec         => l_control_rec       ,
    	  P_Qte_Line_Dtl_Tbl    => l_qte_line_dtl_tbl  ,
    	  P_Line_Attribs_Ext_Tbl =>l_line_attribs_ext_tbl,
          P_Payment_Tbl         => l_payment_tbl,
    	  P_Price_Adj_Tbl       => l_price_adj_tbl,
    	  P_Price_Attributes_Tbl =>l_price_attributes_tbl,
    	  P_Price_Adj_Attr_Tbl  => l_price_adj_attr_tbl,
          P_Shipment_Tbl        => l_shipment_tbl      ,
    	  P_Tax_Detail_Tbl      => l_tax_detail_tbl    ,
    	  P_Freight_Charge_Tbl  => l_freight_charge_tbl,
           P_Sales_Credit_Tbl    => l_Sales_Credit_Tbl  ,
          P_Quote_Party_Tbl     => l_Quote_Party_Tbl,
    	  P_Update_Header_Flag  => l_update_header_flag,
    	  X_Return_Status       => x_return_status ,
    	  X_Msg_Count           => x_msg_count     ,
          X_Msg_Data            => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Update_Quote_Line_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook


      -- vertical hook
        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN
          ASO_QUOTE_VUHK.Update_Quote_Line_PRE(
    	  P_Qte_Line_Rec        => l_qte_line_rec      ,
    	  P_Control_Rec         => l_control_rec       ,
    	  P_Qte_Line_Dtl_Tbl    => l_qte_line_dtl_tbl  ,
    	  P_Line_Attribs_Ext_Tbl =>l_line_attribs_ext_tbl,
          P_Payment_Tbl         => l_payment_tbl,
    	  P_Price_Adj_Tbl       => l_price_adj_tbl,
    	  P_Price_Attributes_Tbl =>l_price_attributes_tbl,
    	  P_Price_Adj_Attr_Tbl  => l_price_adj_attr_tbl,
          P_Shipment_Tbl        => l_shipment_tbl      ,
    	  P_Tax_Detail_Tbl      => l_tax_detail_tbl    ,
    	  P_Freight_Charge_Tbl  => l_freight_charge_tbl,
           P_Sales_Credit_Tbl    => l_Sales_Credit_Tbl  ,
          P_Quote_Party_Tbl     => l_Quote_Party_Tbl,
    	  P_Update_Header_Flag  => l_update_header_flag,
    	  X_Return_Status       => x_return_status ,
    	  X_Msg_Count           => x_msg_count     ,
          X_Msg_Data            => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Update_Quote_Line_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook








      -- Convert the values to ids
      Convert_Line_Values_To_Ids (
	    p_qte_line_rec	=> l_qte_line_rec,
	    x_qte_line_rec	=> l_qte_line_rec_out);

	    l_qte_line_rec := l_qte_line_rec_out;

/*      FOR i IN 1..p_shipment_tbl.count LOOP
        Convert_Shipment_Values_To_Ids (
	    p_shipment_rec	=> p_shipment_tbl(i),
	    x_shipment_rec	=> l_shipment_tbl(i));
      END LOOP;
*/

-- Call Private API
  ASO_QUOTE_LINES_PVT.Update_Quote_Line(
    P_Api_Version_Number  => 1.0,
    P_Init_Msg_List       => p_init_msg_list,
    P_Commit              => p_commit,
    P_Validation_Level    => p_validation_level,
    p_qte_header_rec      => p_qte_header_rec,
    P_Qte_Line_Rec        => l_qte_line_rec,
    P_Control_REC         => l_control_rec   ,
    P_Payment_Tbl         => l_payment_tbl   ,
    P_Price_Adj_Tbl       => l_price_adj_tbl ,
    P_Qte_Line_Dtl_TBL    => l_Qte_Line_Dtl_TBL ,
    P_Shipment_Tbl        => l_Shipment_Tbl ,
    P_Tax_Detail_Tbl      => l_Tax_Detail_Tbl ,
    P_Freight_Charge_Tbl  => l_Freight_Charge_Tbl,
    P_Price_Attributes_Tbl => l_Price_Attributes_Tbl,
    P_Price_Adj_Attr_Tbl    =>l_Price_Adj_Attr_Tbl,
    P_Line_Attribs_Ext_Tbl  =>l_Line_Attribs_Ext_Tbl,
    P_Sales_Credit_Tbl    => l_Sales_Credit_Tbl  ,
    P_Quote_Party_Tbl     => l_Quote_Party_Tbl,
    P_Update_Header_Flag    =>l_Update_Header_Flag ,
    X_qte_line_rec         => X_qte_line_rec,
    X_payment_tbl	   => x_payment_tbl,
    X_Price_Adj_Tbl        => x_price_adj_tbl,
    X_Qte_Line_Dtl_tbl     => x_qte_line_dtl_tbl,
    X_Shipment_Tbl         => x_shipment_tbl,
    X_Tax_Detail_Tbl       => x_tax_detail_tbl,
    X_Freight_Charge_Tbl   => x_freight_charge_tbl,
    X_Price_Attributes_Tbl => x_price_attributes_tbl,
    X_Price_Adj_Attr_Tbl    =>x_Price_Adj_Attr_Tbl,
    X_Line_Attribs_Ext_Tbl  =>x_Line_Attribs_Ext_Tbl,
    X_Sales_Credit_Tbl      => X_Sales_Credit_Tbl,
    X_Quote_Party_Tbl       => X_Quote_Party_Tbl,
    X_Return_Status        => x_return_status,
    X_Msg_Count            => x_msg_count,
    X_Msg_Data             => x_msg_data
    );



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --



       --  call user hooks
      -- customer post processing

        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN
          ASO_QUOTE_CUHK.Update_Quote_Line_POST(
    	  P_Qte_Line_Rec        => x_qte_line_rec      ,
    	  P_Control_Rec         => l_control_rec       ,
    	  P_Qte_Line_Dtl_Tbl    => x_qte_line_dtl_tbl  ,
    	  P_Line_Attribs_Ext_Tbl =>x_line_attribs_ext_tbl,
          P_Payment_Tbl         => x_payment_tbl,
    	  P_Price_Adj_Tbl       => x_price_adj_tbl,
    	  P_Price_Attributes_Tbl =>x_price_attributes_tbl,
    	  P_Price_Adj_Attr_Tbl  => x_price_adj_attr_tbl,
          P_Shipment_Tbl        => x_shipment_tbl      ,
    	  P_Tax_Detail_Tbl      => x_tax_detail_tbl    ,
    	  P_Freight_Charge_Tbl  => x_freight_charge_tbl,
           P_Sales_Credit_Tbl    => x_Sales_Credit_Tbl  ,
          P_Quote_Party_Tbl     => x_Quote_Party_Tbl,
    	  P_Update_Header_Flag  => l_update_header_flag,
    	  X_Return_Status       => x_return_status ,
    	  X_Msg_Count           => x_msg_count     ,
          X_Msg_Data            => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Update_Quote_Line_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('aso_quote_vuhk: before if update quote line post (1)'||x_return_status,1, 'N');
	    END IF;

      -- vertical hook
        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN
	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('aso_quote_vuhk: inside if update quote line post (1)'||x_return_status,1, 'N');
	    END IF;
          ASO_QUOTE_VUHK.Update_Quote_Line_POST(
    	  P_Qte_Line_Rec        => x_qte_line_rec      ,
    	  P_Control_Rec         => l_control_rec       ,
    	  P_Qte_Line_Dtl_Tbl    => x_qte_line_dtl_tbl  ,
    	  P_Line_Attribs_Ext_Tbl =>x_line_attribs_ext_tbl,
          P_Payment_Tbl         => x_payment_tbl,
    	  P_Price_Adj_Tbl       => x_price_adj_tbl,
    	  P_Price_Attributes_Tbl =>x_price_attributes_tbl,
    	  P_Price_Adj_Attr_Tbl  => x_price_adj_attr_tbl,
          P_Shipment_Tbl        => x_shipment_tbl      ,
    	  P_Tax_Detail_Tbl      => x_tax_detail_tbl    ,
    	  P_Freight_Charge_Tbl  => x_freight_charge_tbl,
           P_Sales_Credit_Tbl    => x_Sales_Credit_Tbl  ,
          P_Quote_Party_Tbl     => x_Quote_Party_Tbl,
    	  P_Update_Header_Flag  => l_update_header_flag,
    	  X_Return_Status       => x_return_status ,
    	  X_Msg_Count           => x_msg_count     ,
          X_Msg_Data            => x_msg_data
          );

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('aso_quote_vuhk: after if update quote line post (1)'||x_return_status,1, 'N');
	    END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Update_Quote_Line_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook





      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END;


PROCEDURE Delete_Quote_Line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_qte_line_Rec     IN    qte_line_Rec_Type,
    P_Control_REC      IN    Control_Rec_Type := G_MISS_Control_Rec,
    P_Update_Header_Flag         IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_QUOTE_LINE';
    l_api_version_number      CONSTANT NUMBER   := 1.0;

      l_Qte_Line_Rec          Qte_Line_Rec_Type  ;
      l_Control_Rec           Control_rec_Type;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_QUOTE_LINE_PUB;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_Qte_Line_Rec   := p_qte_line_rec;
        l_control_rec    := p_control_rec ;

      --
      -- API body
      --


      --  call user hooks
      -- customer pre processing

        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN
          ASO_QUOTE_CUHK.Delete_Quote_Line_PRE(
  	  P_qte_line_Rec     => l_qte_line_rec,
  	  P_Control_Rec      => l_control_rec,
  	  X_Return_Status    => x_return_status,
  	  X_Msg_Count        => x_msg_count ,
  	  X_Msg_Data         => x_msg_data
   	 );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Delete_Quote_Line_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook


      -- vertical hook
        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN
          ASO_QUOTE_VUHK.Delete_Quote_Line_PRE(
  	  P_qte_line_Rec     => l_qte_line_rec,
  	  P_Control_Rec      => l_control_rec,
  	  X_Return_Status    => x_return_status,
  	  X_Msg_Count        => x_msg_count ,
  	  X_Msg_Data         => x_msg_data
   	 );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Delete_Quote_Line_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook




     ASO_QUOTE_LINES_PVT.Delete_quote_line(
		P_Api_Version_Number	=> 1.0,
		P_Init_Msg_List		=> FND_API.G_FALSE,
		P_Commit		=> p_commit,
                P_qte_line_Rec          => l_qte_line_Rec,
    		P_Control_Rec           => l_Control_Rec  ,
                P_Update_Header_Flag    => P_Update_Header_Flag ,
		X_Return_Status         => x_return_status,
		X_Msg_Count             => x_msg_count,
		X_Msg_Data              => x_msg_data );



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --



      --  call user hooks
      -- customer pre processing

        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN
          ASO_QUOTE_CUHK.Delete_Quote_Line_POST(
  	  P_qte_line_Rec     => l_qte_line_rec,
  	  P_Control_Rec      => l_control_rec,
  	  X_Return_Status    => x_return_status,
  	  X_Msg_Count        => x_msg_count ,
  	  X_Msg_Data         => x_msg_data
   	 );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Delete_Quote_Line_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- customer hook

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('aso_quote_vuhk: before if delete quote line post (1)'||x_return_status,1, 'N');
	    END IF;

      -- vertical hook
        IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN
	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('aso_quote_vuhk: inside if delete quote line post (1)'||x_return_status,1, 'N');
	    END IF;
          ASO_QUOTE_VUHK.Delete_Quote_Line_POST(
  	  P_qte_line_Rec     => l_qte_line_rec,
  	  P_Control_Rec      => l_control_rec,
  	  X_Return_Status    => x_return_status,
  	  X_Msg_Count        => x_msg_count ,
  	  X_Msg_Data         => x_msg_data
   	 );
	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('aso_quote_vuhk: after if delete quote line post (1)'||x_return_status,1, 'N');
	    END IF;


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Delete_Quote_Line_POST', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
                 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
      END IF; -- vertical hook






      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Delete_quote_line;

PROCEDURE Quote_Security_Check(
    P_Api_Version_Number         IN      NUMBER,
    P_Init_Msg_List              IN      VARCHAR2     := FND_API.G_FALSE,
    P_User_Id                    IN      NUMBER,
    X_Resource_Id                OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Security_Flag              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

BEGIN

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
    ASO_QUOTE_HEADERS_PVT.Quote_Security_Check(
        P_Api_Version_Number         =>     P_Api_Version_Number,
        P_Init_Msg_List              =>     P_Init_Msg_List,
        P_User_Id                    =>     P_User_Id,
        X_Resource_Id                =>     X_Resource_Id,
        X_Security_Flag              =>     X_Security_Flag,
        X_Return_Status              =>     X_Return_Status,
        X_Msg_Count                  =>     X_Msg_Count,
        X_Msg_Data                   =>     X_Msg_Data
    );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_QUOTE_PUB: Quote_Security_Check(): End: Resource_Id:   '||X_Resource_Id, 1, 'Y');
    aso_debug_pub.add('ASO_QUOTE_PUB: Quote_Security_Check(): End: Security_Flag: '||X_Security_Flag, 1, 'Y');
    END IF;

End Quote_Security_Check;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   overloaded function includes Qte_Header_Rec to check for last_update_date
--
--   End of Comments
--
PROCEDURE Submit_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_control_rec                IN   ASO_QUOTE_PUB.Submit_Control_Rec_Type
                                                   := ASO_QUOTE_PUB.G_MISS_Submit_Control_Rec,
    P_Qte_Header_Rec             IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    x_order_header_rec           OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Order_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'SUBMIT_QUOTE';
    l_api_version_number      CONSTANT NUMBER   := 1.0;
    l_control_rec             Submit_Control_Rec_Type := P_control_rec;
    l_Qte_Header_Id           NUMBER;
BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT SUBMIT_QUOTE_PUB;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_Qte_Header_Id := P_Qte_Header_Rec.Quote_Header_Id;

      --
      -- API body
      --


      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN
       ASO_QUOTE_CUHK.Submit_quote_PRE(
          p_control_rec      => l_control_rec,
          P_Qte_Header_Id    => l_Qte_Header_Id,
          X_Return_Status    => X_Return_Status,
          X_Msg_Count        => X_Msg_Count,
          X_Msg_Data         => X_Msg_Data    );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Submit_Quote_PRE', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;

             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
        END IF;

      END IF; -- customer hook

      -- vertical hook
      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN
         ASO_QUOTE_VUHK.Submit_quote_PRE(
            p_control_rec        => l_control_rec,
            P_Qte_Header_Id      => l_Qte_Header_Id,
            X_Return_Status      => X_Return_Status,
            X_Msg_Count          => X_Msg_Count,
            X_Msg_Data           => X_Msg_Data    );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Submit_Quote_PRE', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;
             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
       END IF;

      END IF;

ASO_SUBMIT_QUOTE_PVT.Submit_quote(
    P_Api_Version_Number       => 1.0,
    P_Init_Msg_List            => P_Init_Msg_List,
    P_control_rec              => l_control_rec,
    P_Qte_Header_Rec           => P_Qte_Header_Rec,
    x_order_header_rec         => X_order_header_rec,
    X_Return_Status            => X_Return_Status,
    X_Msg_Count                => X_Msg_Count,
    X_Msg_Data                 => X_Msg_Data
    );

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

         --  call user hooks
      -- customer post processing

    IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN
       ASO_QUOTE_CUHK.Submit_quote_POST(
          p_control_rec        => l_control_rec,
          P_Qte_Header_Id      => l_Qte_Header_Id,
          p_order_header_rec   => x_order_header_rec,
          X_Return_Status      => X_Return_Status,
          X_Msg_Count          => X_Msg_Count,
          X_Msg_Data           => X_Msg_Data    );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Submit_Quote_POST', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;
             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF;

      END IF; -- customer hook

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN
         ASO_QUOTE_VUHK.Submit_quote_POST(
           p_control_rec        => l_control_rec,
           P_Qte_Header_Id      => l_Qte_Header_Id,
           p_order_header_rec   => x_order_header_rec,
           X_Return_Status      => X_Return_Status,
           X_Msg_Count          => X_Msg_Count,
           X_Msg_Data           => X_Msg_Data    );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   	       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Submit_Quote_POST', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;
             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;

      END IF; -- vertical hook
      --
      -- End of API body
      --



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Submit_Quote;


-- vtariker: Sales Credit Allocation Public API
PROCEDURE Allocate_Sales_Credits
(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    p_control_rec         IN   ASO_QUOTE_PUB.SALES_ALLOC_CONTROL_REC_TYPE
                                            :=  ASO_QUOTE_PUB.G_MISS_SALES_ALLOC_CONTROL_REC,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Header_Rec      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS

   l_api_name              CONSTANT VARCHAR2 ( 30 ) := 'Allocate_Sales_Credits';
   l_api_version_number    CONSTANT NUMBER := 1.0;

BEGIN

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard Start of API savepoint
      SAVEPOINT ALLOCATE_SALES_CREDITS_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           1.0,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

   -- New PRE-Customer and Verical Hooks

     IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN
       ASO_QUOTE_CUHK.Allocate_Sales_Credits_PRE(
          p_control_rec      => p_control_rec,
          P_Qte_Header_Id    => p_qte_header_rec.quote_header_id,
          X_Return_Status    => X_Return_Status,
          X_Msg_Count        => X_Msg_Count,
          X_Msg_Data         => X_Msg_Data    );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Allocate_Sales_Credits_PRE', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;

             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
        END IF;

      END IF; -- customer hook

      -- vertical hook
      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN
         ASO_QUOTE_VUHK.Allocate_Sales_Credits_PRE(
            p_control_rec        => p_control_rec,
            P_Qte_Header_Id      => p_qte_header_rec.quote_header_id,
            X_Return_Status      => X_Return_Status,
            X_Msg_Count          => X_Msg_Count,
            X_Msg_Data           => X_Msg_Data    );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Allocate_Sales_Credits_PRE', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;
             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
         END IF;

      END IF;


      -- Allocate Sales Credits
      ASO_SALES_CREDIT_PVT.Allocate_Sales_Credits (
        P_Api_Version_Number         =>     1.0,
        P_Init_Msg_List              =>     FND_API.G_FALSE,
        P_Commit                     =>     FND_API.G_FALSE,
        P_control_rec                =>     p_control_rec,
        P_Qte_Header_Rec             =>     p_qte_header_rec,
        X_Qte_Header_Rec             =>     x_qte_header_rec,
        X_Return_Status              =>     x_return_status,
        X_Msg_Count                  =>     x_msg_count,
        X_Msg_Data                   =>     x_msg_data
      );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After ASO_SALES_TEAM_PVT.Assign_Sales_Team: '||x_return_status,1,'Y');
END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     -- Added new post Customer and Verical POST hooks

      -- customer post processing

    IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN
       ASO_QUOTE_CUHK.Allocate_Sales_Credits_POST(
          p_control_rec        => p_control_rec,
          P_Qte_Header_Rec     => x_qte_header_rec,
          X_Return_Status      => X_Return_Status,
          X_Msg_Count          => X_Msg_Count,
          X_Msg_Data           => X_Msg_Data    );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Allocate_Sales_Credits_POST', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;
             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF;

      END IF; -- customer hook



      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN
         ASO_QUOTE_VUHK.Allocate_Sales_Credits_POST(
           p_control_rec        => p_control_rec,
           P_Qte_Header_Rec     => x_qte_header_rec,
           X_Return_Status      => X_Return_Status,
           X_Msg_Count          => X_Msg_Count,
           X_Msg_Data           => X_Msg_Data    );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   	       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Allocate_Sales_Credits_POST', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;
             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;

      END IF; -- vertical hook

        -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
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

END Allocate_Sales_Credits;


PROCEDURE Sales_Credit_Event_Pre (
                  P_Qte_Header_Id     IN  NUMBER,
                  X_Return_Status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS

   l_list              WF_PARAMETER_LIST_T := wf_parameter_list_t();
   l_event_name        VARCHAR2(255) := 'oracle.apps.aso.quote.allocatecredit.pre';
   l_event_key         VARCHAR2(255);

BEGIN

       X_Return_Status := FND_API.G_RET_STS_SUCCESS;

       l_event_key := to_char(sysdate,'MMDDYYYY HH24MISS');

       wf_event.AddParameterToList (
                        p_name  => 'USER_ID',
                        p_value => fnd_profile.value( 'USER_ID'),
                        p_parameterlist => l_list );

       wf_event.AddParameterToList (
                        p_name  => 'RESP_ID',
                        p_value => fnd_profile.value( 'RESP_ID'),
                        p_parameterlist => l_list );

       wf_event.AddParameterToList (
                        p_name  => 'RESP_APPL_ID',
                        p_value => fnd_profile.value( 'RESP_APPL_ID'),
                        p_parameterlist => l_list );

       wf_event.AddParameterToList (
                        p_name  => 'ORG_ID',
                        p_value => fnd_profile.value( 'ORG_ID'),
                        p_parameterlist => l_list );

       wf_event.AddParameterToList (
                        p_name  => 'DOCUMENT_ID',
                        p_value => P_Qte_Header_Id,
                        p_parameterlist => l_list );

       wf_event.raise (
                        p_event_name => l_event_name,
                        p_event_key  => l_event_key,
                        p_parameters => l_list );

       l_list.DELETE;

   EXCEPTION

     WHEN OTHERS THEN

          x_return_Status :=FND_API.G_RET_STS_ERROR;

END Sales_Credit_Event_Pre;


PROCEDURE Sales_Credit_Event_Post (
                  P_Qte_Header_Id     IN  NUMBER,
                  X_Return_Status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS

   l_list              WF_PARAMETER_LIST_T := wf_parameter_list_t();
   l_event_name        VARCHAR2(255) := 'oracle.apps.aso.quote.allocatecredit.post';
   l_event_key         VARCHAR2(255);

BEGIN

       X_Return_Status := FND_API.G_RET_STS_SUCCESS;

       l_event_key := to_char(sysdate,'MMDDYYYY HH24MISS');

       wf_event.AddParameterToList (
                        p_name  => 'USER_ID',
                        p_value => fnd_profile.value( 'USER_ID'),
                        p_parameterlist => l_list );

       wf_event.AddParameterToList (
                        p_name  => 'RESP_ID',
                        p_value => fnd_profile.value( 'RESP_ID'),
                        p_parameterlist => l_list );

       wf_event.AddParameterToList (
                        p_name  => 'RESP_APPL_ID',
                        p_value => fnd_profile.value( 'RESP_APPL_ID'),
                        p_parameterlist => l_list );

       wf_event.AddParameterToList (
                        p_name  => 'ORG_ID',
                        p_value => fnd_profile.value( 'ORG_ID'),
                        p_parameterlist => l_list );

       wf_event.AddParameterToList (
                        p_name  => 'DOCUMENT_ID',
                        p_value => P_Qte_Header_Id,
                        p_parameterlist => l_list );

       wf_event.raise (
                        p_event_name => l_event_name,
                        p_event_key  => l_event_key,
                        p_parameters => l_list );

       l_list.DELETE;


   EXCEPTION

       WHEN OTHERS THEN

          x_return_Status :=FND_API.G_RET_STS_ERROR;

END Sales_Credit_Event_Post;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--   Version : Current version 2.0
--   Note: This is an overloaded procedure. It takes additional attributes
--   which include the p_template_tbl, P_Qte_Access_Tbl and P_Related_Obj_Tbl record
--   types
--
--   End of Comments
--


PROCEDURE Create_quote(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Validation_Level 	      IN   NUMBER                                  := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		      IN   Control_Rec_Type                        := G_Miss_Control_Rec,
    P_Qte_Header_Rec		 IN   Qte_Header_Rec_Type                     := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec		 IN   ASO_QUOTE_PUB.Shipment_Rec_Type         := G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl      IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl       IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		      IN   Qte_Line_Tbl_Type                       := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   Qte_Line_Dtl_Tbl_Type                   := G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   Line_Rltship_Tbl_Type                   := G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   Price_Adj_Tbl_Type                      := G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	      IN   Price_Adj_Attr_Tbl_Type                 := G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   Price_Adj_Rltship_Tbl_Type              := G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	 IN   Price_Attributes_Tbl_Type               := G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		 IN   Payment_Tbl_Type                        := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		 IN   Shipment_Tbl_Type                       := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	 IN   Freight_Charge_Tbl_Type                 := G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		 IN   Tax_Detail_Tbl_Type                     := G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl      IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl       IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl           IN   Qte_Access_Tbl_Type                     := G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl             IN   Template_Tbl_Type                       := G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl          IN   Related_Obj_Tbl_Type                    := G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Rec		 OUT NOCOPY /* file.sql.39 change */  Shipment_Rec_Type,
    X_Hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	      OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl           OUT NOCOPY /* file.sql.39 change */  Qte_Access_Tbl_Type,
    X_Template_Tbl             OUT NOCOPY /* file.sql.39 change */  Template_Tbl_Type,
    X_Related_Obj_Tbl          OUT NOCOPY /* file.sql.39 change */  Related_Obj_Tbl_Type,
    X_Return_Status            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    l_api_name                 CONSTANT VARCHAR2(30) := 'CREATE_QUOTE';
    l_api_version_number       CONSTANT NUMBER       := 1.0;
    l_qte_header_rec	      Qte_Header_Rec_Type;
    l_qte_header_rec_out       Qte_Header_Rec_Type;
    l_Qte_Line_Tbl	           Qte_Line_Tbl_Type;
    l_Qte_Line_rec_out	      Qte_Line_Rec_Type;
    l_hd_shipment_rec	      Shipment_Rec_Type;
    l_hd_shipment_rec_out      Shipment_Rec_Type;
    l_ln_shipment_tbl	      Shipment_Tbl_Type;
    l_ln_shipment_rec_out      Shipment_Rec_Type;
    l_hd_Payment_Tbl           Payment_Tbl_Type;
    l_ln_Payment_Tbl           Payment_Tbl_Type;
    l_Price_Adj_Tbl            Price_Adj_Tbl_Type;
    l_Qte_Line_Dtl_rec         Qte_Line_Dtl_rec_Type;
    l_hd_Tax_Detail_Tbl        Tax_Detail_Tbl_Type;
    l_ln_Tax_Detail_Tbl        Tax_Detail_Tbl_Type;
    l_hd_Freight_Charge_Tbl    Freight_Charge_Tbl_Type;
    l_ln_Freight_Charge_Tbl    Freight_Charge_Tbl_Type;
    l_Line_Rltship_Tbl         Line_Rltship_Tbl_Type;
    l_hd_Price_Attributes_Tbl  Price_Attributes_Tbl_Type;
    l_ln_Price_Attributes_Tbl  Price_Attributes_Tbl_Type;
    l_Price_Adj_rltship_Tbl    Price_Adj_Rltship_Tbl_Type;
    l_Price_Adj_Attr_Tbl       Price_Adj_Attr_Tbl_Type;
    l_hd_Attribs_Ext_Tbl       Line_Attribs_Ext_Tbl_type;
    l_Line_Attribs_Ext_Tbl     Line_Attribs_Ext_Tbl_type;
    l_Qte_Line_Dtl_tbl         Qte_Line_Dtl_tbl_Type;
    l_hd_Sales_Credit_Tbl      Sales_Credit_Tbl_Type;
    l_ln_Sales_Credit_Tbl      Sales_Credit_Tbl_Type;
    l_hd_Quote_Party_Tbl       Quote_Party_Tbl_Type;
    l_ln_Quote_Party_Tbl       Quote_Party_Tbl_Type;
    l_Control_Rec              Control_rec_Type;
    l_validation_level         NUMBER;
    l_Qte_Access_Tbl           Qte_Access_Tbl_Type;
    l_Template_Tbl             Template_Tbl_Type;
    l_Related_Obj_Tbl          Related_Obj_Tbl_Type;
    --ER 7428770
     l_CONFIG_REC ASO_QUOTE_PUB.QTE_LINE_DTL_REC_TYPE;
   l_MODEL_LINE_REC ASO_QUOTE_PUB.QTE_LINE_REC_TYPE;
seg1 varchar2(250);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_QUOTE_PUB;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- mapping to local variables
      l_qte_header_rec          := P_Qte_Header_Rec;
      l_hd_Price_Attributes_Tbl := P_hd_Price_Attributes_Tbl;
      l_hd_Payment_Tbl          := P_hd_Payment_Tbl;
      l_hd_shipment_rec         := P_hd_Shipment_Rec;
      l_hd_Freight_Charge_Tbl   := P_hd_Freight_Charge_Tbl;
      l_hd_Tax_Detail_Tbl       := P_hd_Tax_Detail_Tbl;
      l_hd_Attribs_Ext_Tbl      := P_hd_Attr_Ext_Tbl;
      l_hd_Sales_Credit_Tbl     := P_hd_Sales_Credit_Tbl;
      l_hd_Quote_Party_Tbl      := P_hd_Quote_Party_Tbl;
      l_Qte_Line_tbl            := p_Qte_Line_tbl;
      l_hd_Payment_Tbl          := p_hd_Payment_Tbl;
      l_Price_Adj_Tbl           := P_Price_Adjustment_Tbl;
    	 l_Line_Rltship_Tbl        := p_Line_Rltship_Tbl;
      l_Price_Adj_rltship_Tbl   := p_Price_Adj_Rltship_Tbl;
      l_ln_Price_Attributes_Tbl := P_Ln_Price_Attributes_Tbl;
      l_Price_Adj_Attr_Tbl      := p_Price_Adj_Attr_Tbl;
      l_ln_Payment_Tbl          := P_Ln_Payment_Tbl;
      l_ln_shipment_tbl         := P_Ln_Shipment_Tbl;
      l_ln_Freight_Charge_Tbl   := P_Ln_Freight_Charge_Tbl;
      l_ln_Tax_Detail_Tbl       := P_Ln_Tax_Detail_Tbl;
      l_ln_Sales_Credit_Tbl     := P_ln_Sales_Credit_Tbl;
      l_ln_Quote_Party_Tbl      := P_ln_Quote_Party_Tbl;
    	 l_Line_Attribs_Ext_Tbl    := P_Line_Attr_Ext_Tbl;
	 l_Qte_Line_Dtl_tbl        := p_Qte_Line_Dtl_tbl;
      l_control_rec             := p_control_rec;
      l_validation_level        := P_Validation_Level;
      l_Qte_Access_Tbl          := P_Qte_Access_Tbl;
      l_Template_Tbl            := P_Template_Tbl;
      l_Related_Obj_Tbl         := P_Related_Obj_Tbl;

      -- call user hooks
      -- customer pre processing

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN

           ASO_QUOTE_CUHK.Create_quote_PRE(
                            P_Validation_Level 	     => l_validation_level ,
                            P_Control_Rec		     => l_control_rec ,
                            P_Qte_Header_Rec	          => l_qte_header_rec  ,
                            P_hd_Price_Attributes_Tbl	=> l_hd_Price_Attributes_Tbl  ,
                            P_hd_Payment_Tbl		     => l_hd_Payment_Tbl ,
                            P_hd_Shipment_Rec		=> l_hd_shipment_rec,
                            P_hd_Freight_Charge_Tbl	=> l_hd_Freight_Charge_Tbl,
                            P_hd_Tax_Detail_Tbl		=> l_hd_Tax_Detail_Tbl ,
                            P_hd_Attr_Ext_Tbl		=> l_hd_Attribs_Ext_Tbl,
                            P_hd_Sales_Credit_Tbl      => l_hd_Sales_Credit_Tbl ,
                            P_hd_Quote_Party_Tbl       => l_hd_Quote_Party_Tbl   ,
                            P_Qte_Line_Tbl		     => l_Qte_Line_Tbl,
                            P_Qte_Line_Dtl_Tbl		=> l_Qte_Line_Dtl_tbl,
                            P_Line_Attr_Ext_Tbl		=> l_Line_Attribs_Ext_Tbl,
                            P_line_rltship_tbl		=> l_Line_Rltship_Tbl,
                            P_Price_Adjustment_Tbl	=> l_Price_Adj_Tbl ,
                            P_Price_Adj_Attr_Tbl	     => l_Price_Adj_Attr_Tbl    ,
                            P_Price_Adj_Rltship_Tbl	=> l_Price_Adj_rltship_Tbl,
                            P_Ln_Price_Attributes_Tbl	=> l_ln_Price_Attributes_Tbl  ,
                            P_Ln_Payment_Tbl		     => l_ln_Payment_Tbl ,
                            P_Ln_Shipment_Tbl		=> l_ln_shipment_tbl ,
                            P_Ln_Freight_Charge_Tbl	=> l_ln_Freight_Charge_Tbl,
                            P_Ln_Tax_Detail_Tbl		=> l_ln_Tax_Detail_Tbl,
                            P_ln_Sales_Credit_Tbl      => l_ln_Sales_Credit_Tbl    ,
                            P_ln_Quote_Party_Tbl       => l_ln_Quote_Party_Tbl,

					   /*
                            P_Qte_Access_Tbl           => l_Qte_Access_Tbl,
                            P_Template_Tbl             => l_Template_Tbl,   */
                            P_Related_Obj_Tbl          => l_Related_Obj_Tbl,

                            X_Return_Status            => X_Return_Status,
                            X_Msg_Count                => X_Msg_Count,
                            X_Msg_Data                 => X_Msg_Data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		         FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		         FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Create_Quote_PRE', FALSE);
		         FND_MSG_PUB.ADD;
               END IF;

               IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

          END IF;

      END IF; -- customer hook

      -- vertical hook
      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN

           ASO_QUOTE_VUHK.Create_quote_PRE(
                           P_Validation_Level 	   => l_validation_level ,
                           P_Control_Rec		   => l_control_rec ,
                           P_Qte_Header_Rec	        => l_qte_header_rec  ,
                           P_hd_Price_Attributes_Tbl => l_hd_Price_Attributes_Tbl  ,
                           P_hd_Payment_Tbl		   => l_hd_Payment_Tbl ,
                           P_hd_Shipment_Rec		   => l_hd_shipment_rec,
                           P_hd_Freight_Charge_Tbl   => l_hd_Freight_Charge_Tbl,
                           P_hd_Tax_Detail_Tbl	   => l_hd_Tax_Detail_Tbl ,
                           P_hd_Attr_Ext_Tbl		   => l_hd_Attribs_Ext_Tbl,
                           P_hd_Sales_Credit_Tbl     => l_hd_Sales_Credit_Tbl ,
                           P_hd_Quote_Party_Tbl      => l_hd_Quote_Party_Tbl   ,
                           P_Qte_Line_Tbl		   => l_Qte_Line_Tbl,
                           P_Qte_Line_Dtl_Tbl        => l_Qte_Line_Dtl_tbl,
                           P_Line_Attr_Ext_Tbl       => l_Line_Attribs_Ext_Tbl,
                           P_line_rltship_tbl        => l_Line_Rltship_Tbl,
                           P_Price_Adjustment_Tbl	   => l_Price_Adj_Tbl ,
                           P_Price_Adj_Attr_Tbl	   => l_Price_Adj_Attr_Tbl    ,
                           P_Price_Adj_Rltship_Tbl   => l_Price_Adj_rltship_Tbl,
                           P_Ln_Price_Attributes_Tbl => l_ln_Price_Attributes_Tbl  ,
                           P_Ln_Payment_Tbl		   => l_ln_Payment_Tbl ,
                           P_Ln_Shipment_Tbl		   => l_ln_shipment_tbl ,
                           P_Ln_Freight_Charge_Tbl   => l_ln_Freight_Charge_Tbl,
                           P_Ln_Tax_Detail_Tbl       => l_ln_Tax_Detail_Tbl,
                           P_ln_Sales_Credit_Tbl     => l_ln_Sales_Credit_Tbl    ,
                           P_ln_Quote_Party_Tbl      => l_ln_Quote_Party_Tbl,
					  /*
                           P_Qte_Access_Tbl          => l_Qte_Access_Tbl,
                           P_Template_Tbl            => l_Template_Tbl,
					  P_Related_Obj_Tbl         => l_Related_Obj_Tbl,
					  */
                           X_Return_Status           => X_Return_Status,
                           X_Msg_Count               => X_Msg_Count,
                           X_Msg_Data                => X_Msg_Data );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		         FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		         FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Create_Quote_PRE', FALSE);
		         FND_MSG_PUB.ADD;
               END IF;

               IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

          END IF;

      END IF;

      -- Convert the values to ids
      --

      Convert_Header_Values_To_Ids ( p_qte_header_rec	=>  l_qte_header_rec,
                                     x_qte_header_rec	=>  l_qte_header_rec_out);

	 l_qte_header_rec := l_qte_header_rec_out;

      FOR i IN 1..p_qte_line_tbl.count LOOP

         Convert_Line_Values_To_Ids ( p_qte_line_rec	=> l_qte_line_tbl(i),
	                                x_qte_line_rec	=> l_qte_line_rec_out );

	    l_qte_line_tbl(i) := l_qte_line_rec_out;

      END LOOP;

      Convert_Shipment_Values_To_Ids ( p_shipment_rec	=> l_hd_shipment_rec,
	                                  x_shipment_rec	=> l_hd_shipment_rec_out);

	 l_hd_shipment_rec := l_hd_shipment_rec_out;

      FOR i IN 1..p_ln_shipment_tbl.count LOOP

          Convert_Shipment_Values_To_Ids ( p_shipment_rec	=> l_ln_shipment_tbl(i),
	                                      x_shipment_rec	=> l_ln_shipment_rec_out );

	     l_ln_shipment_tbl(i) := l_ln_shipment_rec_out;

      END LOOP;
      --Bug 23223080
      	If l_qte_header_rec.quote_source_code = 'ASO' Then
/*ER 7428770 Validation for the customer to pass only model line when customer is adding configuration to quote using script */
	   For i in 1 .. l_qte_line_tbl.count loop
               If (l_qte_line_tbl(i).item_type_code = 'CFG' ) and  l_qte_line_tbl(i).Config_Header_id is not null and l_qte_line_tbl(i).Config_revision_nbr is not null then
                     for j in 1..l_qte_line_tbl.count loop
                              if l_qte_line_tbl(j).item_type_code ='MDL' AND l_qte_line_tbl(i).Config_Header_id=l_qte_line_tbl(j).Config_Header_id and  l_qte_line_tbl(i).Config_revision_nbr=l_qte_line_tbl(j).Config_revision_nbr then
                              Select segment1 into seg1  from  mtl_system_items_B where  INVENTORY_ITEM_ID = l_qte_line_tbl(j).inventory_item_id and ORGANIZATION_ID = l_Qte_Line_Tbl(j).org_id  ;
                    end if;

                 fnd_message.set_name( 'ASO', 'ASO_API_MDL_CFG_PARAM_ERROR' ) ;
                 fnd_message.set_token( 'MODELITEM', seg1,TRUE) ;
                 FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
                 End loop;
            End if;
      End loop;
END IF;
      ASO_QUOTE_HEADERS_PVT.Create_quote(
	                          P_Api_Version_Number      => 1.0,
	                          P_Init_Msg_List           => FND_API.G_FALSE,
	                          P_Commit			       => FND_API.G_FALSE,
	                          p_validation_level		  => p_validation_level,
	                          P_Control_Rec		       => l_control_rec,
	                          P_qte_header_rec		  => l_qte_header_rec,
	                          P_Hd_Price_Attributes_Tbl => l_hd_Price_Attributes_Tbl,
	                          P_Hd_Payment_Tbl		  => l_hd_Payment_Tbl,
	                          P_Hd_Shipment_Rec		  => l_Hd_Shipment_Rec,
	                          P_Hd_Freight_Charge_Tbl	  => l_hd_Freight_Charge_Tbl,
	                          P_Hd_Tax_Detail_Tbl	  => l_hd_Tax_Detail_Tbl ,
                               P_hd_Attr_Ext_Tbl         => l_hd_Attribs_Ext_Tbl,
                               P_hd_Sales_Credit_Tbl     => l_hd_Sales_Credit_Tbl ,
                               P_hd_Quote_Party_Tbl      => l_hd_Quote_Party_Tbl,
	                          P_Qte_Line_Tbl		  => l_Qte_Line_Tbl,
	                          P_Qte_Line_Dtl_Tbl		  => l_Qte_Line_Dtl_tbl,
	                          P_Line_Attr_Ext_Tbl       => l_Line_Attribs_Ext_Tbl,
	                          P_Line_rltship_tbl		  => l_Line_Rltship_Tbl,
	                          P_Price_Adjustment_Tbl	  => l_Price_Adj_Tbl,
	                          P_Price_Adj_Attr_Tbl	  => l_Price_Adj_Attr_Tbl,
	                          P_Price_Adj_Rltship_Tbl	  => l_Price_Adj_rltship_Tbl ,
	                          P_Ln_Price_Attributes_Tbl => l_ln_Price_Attributes_Tbl ,
	                          P_Ln_Payment_Tbl          => l_Ln_Payment_Tbl,
	                          P_Ln_Shipment_Tbl         => l_Ln_Shipment_Tbl,
	                          P_Ln_Freight_Charge_Tbl	  => l_Ln_Freight_Charge_Tbl,
	                          P_Ln_Tax_Detail_Tbl       => l_Ln_Tax_Detail_Tbl,
                               P_ln_Sales_Credit_Tbl     => l_ln_Sales_Credit_Tbl ,
                               P_ln_Quote_Party_Tbl      => l_ln_Quote_Party_Tbl,
                               P_Qte_Access_Tbl          => l_Qte_Access_Tbl,
                               P_Template_Tbl            => l_Template_Tbl,
					      P_Related_Obj_Tbl         => l_Related_Obj_Tbl,
	                          x_qte_header_rec		  => x_qte_header_rec,
	                          X_Hd_Price_Attributes_Tbl => x_Hd_Price_Attributes_Tbl,
	                          X_Hd_Payment_Tbl		  => x_Hd_Payment_Tbl,
	                          X_Hd_Shipment_Rec		  => x_Hd_Shipment_Rec,
	                          X_Hd_Freight_Charge_Tbl	  => x_Hd_Freight_Charge_Tbl,
	                          X_Hd_Tax_Detail_Tbl       => x_Hd_Tax_Detail_Tbl,
                               X_hd_Attr_Ext_Tbl         => X_hd_Attr_Ext_Tbl,
                               X_hd_Sales_Credit_Tbl     => X_hd_Sales_Credit_Tbl,
                               X_hd_Quote_Party_Tbl      => X_hd_Quote_Party_Tbl,
	                          X_Qte_Line_Tbl            => x_Qte_Line_Tbl,
	                          X_Qte_Line_Dtl_Tbl		  => x_Qte_Line_Dtl_Tbl,
	                          x_Line_Attr_Ext_Tbl       => x_Line_Attr_Ext_Tbl,
	                          X_Line_rltship_tbl	       => x_Line_Rltship_Tbl,
	                          X_Price_Adjustment_Tbl    => x_Price_Adjustment_Tbl,
	                          x_Price_Adj_Attr_Tbl      => x_Price_Adj_Attr_Tbl,
	                          X_Price_Adj_Rltship_Tbl   => x_Price_Adj_Rltship_Tbl,
	                          X_Ln_Price_Attributes_Tbl => x_Ln_Price_Attributes_Tbl,
	                          X_Ln_Payment_Tbl          => x_Ln_Payment_Tbl,
	                          X_Ln_Shipment_Tbl         => x_Ln_Shipment_Tbl,
	                          X_Ln_Freight_Charge_Tbl   => x_Ln_Freight_Charge_Tbl,
	                          X_Ln_Tax_Detail_Tbl       => x_Ln_Tax_Detail_Tbl,
                               X_Ln_Sales_Credit_Tbl     => X_Ln_Sales_Credit_Tbl,
                               X_Ln_Quote_Party_Tbl      => X_Ln_Quote_Party_Tbl ,
                               X_Qte_Access_Tbl          => X_Qte_Access_Tbl,
                               X_Template_Tbl            => X_Template_Tbl,
                               X_Related_Obj_Tbl         => X_Related_Obj_Tbl,
	                          X_Return_Status           => x_return_status,
	                          X_Msg_Count               => x_msg_count,
	                          X_Msg_Data                => x_msg_data);

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('create_quote_pub: after create quote, starting user hooks (1)'||x_return_status,1, 'N');
	 END IF;
   If x_Return_Status = FND_API.G_RET_STS_SUCCESS  THEN
  -- Bug 23223080 added the quote_source_code = ASO
   If l_qte_header_rec.quote_source_code = 'ASO' Then
      For i in 1 ..  x_Qte_Line_Tbl.count
      Loop
        If (x_Qte_Line_Tbl(i).item_type_code = 'MDL' )then
          If (X_Qte_Line_Tbl(i).Config_Header_id IS NOT NULL ) and (X_Qte_Line_Tbl(i).Config_revision_nbr  IS NOT NULL )then

              l_config_rec.quote_line_id:= x_Qte_Line_Tbl(i).quote_line_id;
              l_QTE_HEADER_REC.quote_header_id := x_qte_header_rec.quote_header_id;
              l_config_rec.complete_configuration_flag := 'Y';
              l_config_rec.valid_configuration_flag := 'Y';

              aso_debug_pub.add('ER 7428770 Create_quote before calling ASO_CFG_PUB.GET_CONFIG_DETAILS x_Qte_Line_Tbl(i).quote_line_id '||x_Qte_Line_Tbl(i).quote_line_id,1, 'N');
              aso_debug_pub.add('ER 7428770 Create_quote before calling ASO_CFG_PUB.GET_CONFIG_DETAILS x_QTE_HEADER_REC.quote_header_id '||x_QTE_HEADER_REC.quote_header_id,1, 'N');
              aso_debug_pub.add('ER 7428770 Create_quote before calling ASO_CFG_PUB.GET_CONFIG_DETAILS x_qte_line_tbl(i).Config_Header_id '||x_qte_line_tbl(i).Config_Header_id,1, 'N');
              aso_debug_pub.add('ER 7428770 Create_quote before calling ASO_CFG_PUB.GET_CONFIG_DETAILS x_qte_line_tbl(i).Config_revision_nbr'||x_qte_line_tbl(i).Config_revision_nbr,1, 'N');

    ASO_CFG_PUB.GET_CONFIG_DETAILS(
    P_API_VERSION_NUMBER => 1.0,
    P_INIT_MSG_LIST => FND_API.G_TRUE,
    P_COMMIT => FND_API.G_TRUE,
    P_CONTROL_REC => l_CONTROL_REC,
    P_QTE_HEADER_REC => x_QTE_HEADER_REC,
    P_MODEL_LINE_REC => l_MODEL_LINE_REC,
    P_CONFIG_REC => l_CONFIG_REC,
    P_CONFIG_HDR_ID =>l_Qte_Line_Tbl(i).Config_Header_id,
    P_CONFIG_REV_NBR =>l_Qte_Line_Tbl(i).Config_revision_nbr,
    X_RETURN_STATUS => X_RETURN_STATUS,
    X_MSG_COUNT => X_MSG_COUNT,
    X_MSG_DATA => X_MSG_DATA);
      End If;
     End If;
    End LOOP;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('ER 7428770 Create_quote After call to ASO_CFG_PUB.GET_CONFIG_DETAILS : Return status:'||x_return_status,1,'N');
aso_debug_pub.add('ER 7428770 Create_quote After call to ASO_CFG_PUB.GET_CONFIG_DETAILS ::Msg count:'||x_msg_count,1,'N');
END IF;

End If;
End If;
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- call user hooks customer post processing

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN

          ASO_QUOTE_CUHK.Create_quote_POST(
                            P_Validation_Level 	    => l_validation_level ,
                            P_Control_Rec		    => l_control_rec ,
                            P_Qte_Header_Rec	         => x_qte_header_rec  ,
                            P_hd_Price_Attributes_Tbl => x_hd_Price_Attributes_Tbl  ,
                            P_hd_Payment_Tbl		    => x_hd_Payment_Tbl ,
                            P_hd_Shipment_Rec         => x_hd_shipment_rec,
                            P_hd_Freight_Charge_Tbl   => x_hd_Freight_Charge_Tbl,
                            P_hd_Tax_Detail_Tbl       => x_hd_Tax_Detail_Tbl ,
                            P_hd_Attr_Ext_Tbl         => X_hd_Attr_Ext_Tbl,
                            P_hd_Sales_Credit_Tbl     => x_hd_Sales_Credit_Tbl ,
                            P_hd_Quote_Party_Tbl      => x_hd_Quote_Party_Tbl   ,
                            P_Qte_Line_Tbl            => x_Qte_Line_Tbl,
                            P_Qte_Line_Dtl_Tbl        => x_Qte_Line_Dtl_tbl,
                            P_Line_Attr_Ext_Tbl       => x_Line_Attr_Ext_Tbl,
                            P_line_rltship_tbl        => x_Line_Rltship_Tbl,
                            P_Price_Adjustment_Tbl    => x_Price_Adjustment_Tbl ,
                            P_Price_Adj_Attr_Tbl      => x_Price_Adj_Attr_Tbl    ,
                            P_Price_Adj_Rltship_Tbl   => x_Price_Adj_rltship_Tbl,
                            P_Ln_Price_Attributes_Tbl => x_ln_Price_Attributes_Tbl  ,
                            P_Ln_Payment_Tbl	         => x_ln_Payment_Tbl ,
                            P_Ln_Shipment_Tbl         => x_ln_shipment_tbl ,
                            P_Ln_Freight_Charge_Tbl   => x_ln_Freight_Charge_Tbl,
                            P_Ln_Tax_Detail_Tbl       => x_ln_Tax_Detail_Tbl,
                            P_ln_Sales_Credit_Tbl     => x_ln_Sales_Credit_Tbl    ,
                            P_ln_Quote_Party_Tbl      => x_ln_Quote_Party_Tbl,
					   /*
                            P_Qte_Access_Tbl          => x_Qte_Access_Tbl,
                            P_Template_Tbl            => x_Template_Tbl, */
					   P_Related_Obj_Tbl         => l_Related_Obj_Tbl,

                            X_Return_Status           => X_Return_Status,
                            X_Msg_Count               => X_Msg_Count,
                            X_Msg_Data                => X_Msg_Data
                            );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Create_Quote_POST', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;

             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
             END IF;

          END IF;

      END IF; -- customer hook


	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('aso_quote_vuhk: before if create quote post (1)'||x_return_status,1, 'N');
	 END IF;

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('aso_quote_vuhk: inside if create quote post (1)'||x_return_status,1, 'N');
	     END IF;

          ASO_QUOTE_VUHK.Create_quote_POST(
                            P_Validation_Level 	    => l_validation_level ,
                            P_Control_Rec		    => l_control_rec ,
                            P_Qte_Header_Rec	         => x_qte_header_rec  ,
                            P_hd_Price_Attributes_Tbl => x_hd_Price_Attributes_Tbl  ,
                            P_hd_Payment_Tbl		    => x_hd_Payment_Tbl ,
                            P_hd_Shipment_Rec         => x_hd_shipment_rec,
                            P_hd_Freight_Charge_Tbl   => x_hd_Freight_Charge_Tbl,
                            P_hd_Tax_Detail_Tbl	    => x_hd_Tax_Detail_Tbl ,
                            P_hd_Attr_Ext_Tbl         => X_hd_Attr_Ext_Tbl,
                            P_hd_Sales_Credit_Tbl     => x_hd_Sales_Credit_Tbl ,
                            P_hd_Quote_Party_Tbl      => x_hd_Quote_Party_Tbl   ,
                            P_Qte_Line_Tbl		    => x_Qte_Line_Tbl,
                            P_Qte_Line_Dtl_Tbl        => x_Qte_Line_Dtl_tbl,
                            P_Line_Attr_Ext_Tbl       => x_Line_Attr_Ext_Tbl,
                            P_line_rltship_tbl        => x_Line_Rltship_Tbl,
                            P_Price_Adjustment_Tbl    => x_Price_Adjustment_Tbl ,
                            P_Price_Adj_Attr_Tbl      => x_Price_Adj_Attr_Tbl    ,
                            P_Price_Adj_Rltship_Tbl   => x_Price_Adj_rltship_Tbl,
                            P_Ln_Price_Attributes_Tbl => x_ln_Price_Attributes_Tbl  ,
                            P_Ln_Payment_Tbl          => x_ln_Payment_Tbl ,
                            P_Ln_Shipment_Tbl         => x_ln_shipment_tbl ,
                            P_Ln_Freight_Charge_Tbl   => x_ln_Freight_Charge_Tbl,
                            P_Ln_Tax_Detail_Tbl       => x_ln_Tax_Detail_Tbl,
                            P_ln_Sales_Credit_Tbl     => x_ln_Sales_Credit_Tbl    ,
                            P_ln_Quote_Party_Tbl      => x_ln_Quote_Party_Tbl,
					   /*
                            P_Qte_Access_Tbl          => x_Qte_Access_Tbl,
                            P_Template_Tbl            => x_Template_Tbl,
					   P_Related_Obj_Tbl         => x_Related_Obj_Tbl,
					   */
                            X_Return_Status           => X_Return_Status,
                            X_Msg_Count               => X_Msg_Count,
                            X_Msg_Data                => X_Msg_Data
                            );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('create_quote_pub: after hooks (2)'||x_return_status,1, 'N');
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		        FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		        FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Create_Quote_POST', FALSE);
		        FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      END IF; -- vertical hook

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION

	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
END;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_quote_Service
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--   Version : Current version 2.0
--   Note: This is an overloaded procedure. It takes additional attributes
--   which include the p_template_tbl, P_Qte_Access_Tbl and P_Related_Obj_Tbl record
--   types
--
--   End of Comments
--


PROCEDURE Create_Quote_Service(
    P_Api_Version_Number        IN   NUMBER,
    P_Init_Msg_List             IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                    IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Validation_Level 	        IN   NUMBER                                  := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec	        IN   Control_Rec_Type                        := G_Miss_Control_Rec,
    P_Qte_Header_Rec		IN   Qte_Header_Rec_Type                     := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec		IN   ASO_QUOTE_PUB.Shipment_Rec_Type         := G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl	IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl       IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl        IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		IN   Qte_Line_Tbl_Type                       := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		IN   Qte_Line_Dtl_Tbl_Type                   := G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		IN   Line_Rltship_Tbl_Type                   := G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	IN   Price_Adj_Tbl_Type                      := G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	IN   Price_Adj_Attr_Tbl_Type                 := G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	IN   Price_Adj_Rltship_Tbl_Type              := G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	IN   Price_Attributes_Tbl_Type               := G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		IN   Payment_Tbl_Type                        := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		IN   Shipment_Tbl_Type                       := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	IN   Freight_Charge_Tbl_Type                 := G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		IN   Tax_Detail_Tbl_Type                     := G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl       IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl        IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl            IN   Qte_Access_Tbl_Type                     := G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl              IN   Template_Tbl_Type                       := G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl           IN   Related_Obj_Tbl_Type                    := G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec		OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Rec		OUT NOCOPY /* file.sql.39 change */  Shipment_Rec_Type,
    X_Hd_Freight_Charge_Tbl	OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl       OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl        OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl       OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl        OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl            OUT NOCOPY /* file.sql.39 change */  Qte_Access_Tbl_Type,
    X_Template_Tbl              OUT NOCOPY /* file.sql.39 change */  Template_Tbl_Type,
    X_Related_Obj_Tbl           OUT NOCOPY /* file.sql.39 change */  Related_Obj_Tbl_Type,
    X_Return_Status             OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                 OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                  OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_QUOTE_SERVICE';
    l_api_version_number        CONSTANT NUMBER       := 1.0;
    l_validation_level          NUMBER;
    l_control_rec               Control_Rec_Type;
    l_qte_header_rec	        Qte_Header_Rec_Type;
    l_hd_shipment_rec	        Shipment_Rec_Type;
    l_hd_Payment_Tbl            Payment_Tbl_Type;
    l_hd_payment_rec            Payment_Rec_Type :=G_MISS_PAYMENT_REC;
    l_hd_Tax_Detail_Tbl         Tax_Detail_Tbl_Type;
    l_hd_tax_rec                Tax_Detail_Rec_Type :=G_MiSS_TAX_DETAIL_REC;
    lx_qte_header_rec		Qte_Header_Rec_Type := ASO_UTILITY_PVT.Get_Qte_Header_Rec;
    lx_hd_shipment_rec 	        Shipment_Rec_Type := ASO_UTILITY_PVT.Get_Shipment_Rec;
    lx_hd_payment_rec	        Payment_Rec_Type := ASO_UTILITY_PVT.Get_Payment_Rec;
    lx_hd_tax_rec		TAX_DETAIL_REC_TYPE:= aso_utility_pvt.get_Tax_detail_rec;

    l_Qte_Line_Tbl	        Qte_Line_Tbl_Type;
    l_Qte_Line_rec	        Qte_Line_Rec_Type := G_MISS_QTE_LINE_REC;
    l_ln_shipment_rec           Shipment_Rec_Type := G_MISS_SHIPMENT_REC;
    l_ln_shipment_tbl	        Shipment_Tbl_Type;
    l_ln_payment_rec            Payment_Rec_Type := G_MISS_PAYMENT_REC;
    l_ln_Payment_Tbl            Payment_Tbl_Type;
    l_ln_tax_rec                Tax_Detail_Rec_Type :=G_MISS_TAX_DETAIL_REC;
    l_ln_Tax_Detail_Tbl         Tax_Detail_Tbl_Type;

    lx_qte_line_rec		QTE_LINE_REC_TYPE   :=ASO_UTILITY_PVT.Get_Qte_Line_Rec;
    lx_ln_shipment_rec          Shipment_rec_type   := ASO_UTILITY_PVT.Get_Shipment_Rec;
    lx_ln_payment_rec		Payment_Rec_Type    := ASO_UTILITY_PVT.Get_Payment_Rec;
    lx_ln_tax_rec		TAX_DETAIL_REC_TYPE :=aso_utility_pvt.get_tax_detail_rec;

    l_ln_misc_rec		ASO_DEFAULTING_INT.LINE_MISC_REC_TYPE :=ASO_utility_pvt.get_line_misc_rec;
    l_hd_misc_rec		ASO_DEFAULTING_INT.HEADER_MISC_REC_TYPE:=ASO_utility_pvt.get_header_misc_rec;
    lx_ln_misc_rec		ASO_DEFAULTING_INT.LINE_MISC_REC_TYPE :=ASO_utility_pvt.get_line_misc_rec;
    lx_hd_misc_rec		ASO_DEFAULTING_INT.HEADER_MISC_REC_TYPE:=ASO_utility_pvt.get_header_misc_rec;

    l_opp_qte_in_rec            ASO_OPP_QTE_PUB.OPP_QTE_IN_REC_TYPE := ASO_OPP_QTE_PUB.G_MISS_OPP_QTE_IN_REC;
   -- defaulting related parameters
    l_trigger_attribute_tbl     ASO_Defaulting_Int.Attribute_codes_tbl_type := ASO_Defaulting_Int.G_MISS_ATTRIBUTE_CODES_TBL;
    l_def_control_rec           ASO_Defaulting_Int.Control_Rec_Type    := ASO_Defaulting_Int.G_Miss_Control_Rec;

    lx_changed_flag		VARCHAR2(1);
    lx_return_status		VARCHAR2(1);
    lx_msg_count		NUMBER;
    lx_msg_data			VARCHAR2(2000);

    l_db_object_name            VARCHAR2(65);

    x_changed_flag		VARCHAR2(1);

    i                           NUMBER;
    k                           NUMBER;
-- parameter for quote line
    l_inv_org_id                NUMBER;
    l_primary_uom_code          VARCHAR2(3);
    l_serviceable_product_flag  VARCHAR2(1);
    l_bom_item_type             NUMBER;

    -- validate quantity
    l_output_qty              NUMBER;
    l_primary_qty             NUMBER;
    x_valid_quantity          VARCHAR2(1);

    CURSOR C_Get_Master_Org_Id (p_org_id NUMBER) IS
        SELECT master_organization_id
        FROM oe_system_parameters_all
        WHERE org_id = p_org_id;

      -- Cursor to get inventory item info.
    CURSOR C_Get_Item_Info(p_inv_org_id NUMBER, p_inv_item_id NUMBER) IS
     SELECT primary_uom_code,
            serviceable_product_flag ,
            bom_item_type
      FROM  mtl_system_items_b_kfv
      WHERE organization_id = p_inv_org_id
        AND inventory_item_id = p_inv_item_id;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_QUOTE_SERVICE_PUB;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- mapping to local variables
      l_qte_header_rec          := P_Qte_Header_Rec;
      l_hd_Payment_Tbl          := P_hd_Payment_Tbl;
      l_hd_shipment_rec         := P_hd_Shipment_Rec;
      l_hd_Tax_Detail_Tbl       := P_hd_Tax_Detail_Tbl;
      l_Qte_Line_tbl            := p_Qte_Line_tbl;
      l_hd_Payment_Tbl          := p_hd_Payment_Tbl;
      l_ln_Payment_Tbl          := P_Ln_Payment_Tbl;
      l_ln_shipment_tbl         := P_Ln_Shipment_Tbl;
      l_ln_Tax_Detail_Tbl       := P_Ln_Tax_Detail_Tbl;
      l_control_rec             := p_control_rec;
      l_validation_level        := P_Validation_Level;

      -- Default Header Record
      --IF P_Qte_Header_Rec IS NOT NULL
      --AND P_Qte_Header_Rec <> G_MISS_Qte_Header_Rec THEN
       -- Prepare to call ASO_DEFAULTING_INT.default_entity to default the header record
       -- Prepare p_trigger_attribute_table
        i:=1;
        IF P_Qte_Header_Rec.org_id IS NULL OR P_Qte_Header_Rec.org_id=FND_API.G_MISS_NUM THEN
          l_Qte_Header_Rec.org_id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10));
        END IF;
        l_trigger_attribute_tbl(i):='Q_ORG_ID';
        i := i+1;

        IF P_Qte_Header_Rec.original_system_reference IS NOT NULL
          AND P_Qte_Header_Rec.original_system_reference <> FND_API.G_MISS_CHAR THEN
           l_Qte_Header_Rec.original_system_reference := 'AIA_'||P_Qte_Header_Rec.original_system_reference;
        ELSE
           l_Qte_Header_Rec.original_system_reference := 'AIA';
        END IF;

        IF P_Qte_Header_Rec.order_type_id IS NOT NULL AND P_Qte_Header_Rec.order_type_id<>FND_API.G_MISS_NUM  THEN
          l_trigger_attribute_tbl(i):='Q_ORDER_TYPE_ID';
          i := i+1;
        END IF;

        IF P_Qte_Header_Rec.contract_id IS NOT NULL AND P_Qte_Header_Rec.contract_id <>FND_API.G_MISS_NUM THEN
          l_trigger_attribute_tbl(i):='Q_CONTRACT_ID';
          i := i+1;
        END IF;

        IF P_Qte_Header_Rec.price_list_id IS NOT NULL AND P_Qte_Header_Rec.price_list_id<>FND_API.G_MISS_NUM  THEN
          l_trigger_attribute_tbl(i):='Q_PRICE_LIST_ID';
          i := i+1;
        END IF;

        IF P_Qte_Header_Rec.resource_id IS NOT NULL AND P_Qte_Header_Rec.resource_id<>FND_API.G_MISS_NUM THEN
          l_trigger_attribute_tbl(i):='Q_RESOURCE_ID';
          i := i+1;
        END IF;

        IF P_Qte_Header_Rec.CUST_PARTY_ID IS NOT NULL
          AND P_Qte_Header_Rec.CUST_PARTY_ID <>FND_API.G_MISS_NUM  THEN
          l_trigger_attribute_tbl(i):='Q_CUST_PARTY_ID';
          i := i+1;
        END IF;

        IF P_Qte_Header_Rec.CUST_ACCOUNT_ID IS NOT NULL
          AND P_Qte_Header_Rec.CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM  THEN
          l_trigger_attribute_tbl(i):='Q_CUST_ACCOUNT_ID';
          i := i+1;
        END IF;

        IF P_Qte_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID IS NOT NULL
          AND P_Qte_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID<>FND_API.G_MISS_NUM THEN
          l_trigger_attribute_tbl(i):='Q_INV_TO_CUST_ACCT_ID';
          i := i+1;
        END IF;

        IF P_Qte_Header_Rec.INVOICE_TO_PARTY_SITE_ID IS NOT NULL
          AND P_Qte_Header_Rec.INVOICE_TO_PARTY_SITE_ID <>FND_API.G_MISS_NUM THEN
          l_trigger_attribute_tbl(i):='Q_INV_TO_PTY_SITE_ID';
          i := i+1;
        END IF;
      --END IF; -- quote header record attributes
      --IF P_hd_Shipment_Rec IS NOT NULL
      --  AND P_hd_Shipment_Rec <> G_MISS_SHIPMENT_REC THEN
        IF P_hd_shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID IS NOT NULL
          AND P_hd_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID<>FND_API.G_MISS_NUM THEN
          l_trigger_attribute_tbl(i):='Q_SHIP_TO_CUST_ACCT_ID';
          i := i+1;
        END IF;
        IF P_hd_shipment_Rec.SHIP_TO_PARTY_SITE_ID IS NOT NULL
          AND P_hd_Shipment_Rec.SHIP_TO_PARTY_SITE_ID<>FND_API.G_MISS_NUM THEN
          l_trigger_attribute_tbl(i):='Q_SHIP_TO_PARTY_SITE_ID';
        END IF;
      --END IF;

      -- set header defaulting control record
      -- set control record
    l_def_control_rec.override_Trigger_Flag := FND_API.G_FALSE;
    l_def_control_rec.dependency_Flag := FND_API.G_FALSE;
    l_def_control_rec.defaulting_Flag := FND_API.G_TRUE;
    l_def_control_rec.application_type_code := 'QUOTING HTML';
    l_def_control_rec.defaulting_flow_code := 'CREATE';

    l_db_object_name := 'ASO_AK_QUOTE_HEADER_V';

    Aso_Defaulting_Int.Default_Entity (
      P_API_VERSION               =>      1.0,
      P_INIT_MSG_LIST             =>      FND_API.G_TRUE,
      P_COMMIT                    =>      FND_API.G_TRUE,
      P_CONTROL_REC               =>      l_def_control_rec,
      P_DATABASE_OBJECT_NAME      =>      l_db_object_name,
      P_TRIGGER_ATTRIBUTES_TBL    =>      l_trigger_attribute_tbl,
      P_QUOTE_HEADER_REC          =>      l_qte_header_rec,
      P_OPP_QTE_HEADER_REC        =>      l_opp_qte_in_rec,
      P_HEADER_MISC_REC           =>      l_hd_Misc_Rec,
      P_HEADER_SHIPMENT_REC       =>      l_hd_shipment_rec,
      P_HEADER_PAYMENT_REC        =>      l_hd_payment_rec,
      P_HEADER_TAX_DETAIL_REC     =>      l_hd_tax_rec,
      P_QUOTE_LINE_REC            =>      l_qte_line_rec,
      P_LINE_MISC_REC             =>      l_ln_Misc_Rec,
      P_LINE_SHIPMENT_REC         =>      l_ln_shipment_rec,
      P_LINE_PAYMENT_REC          =>      l_ln_payment_rec,
      P_LINE_TAX_DETAIL_REC       =>      l_ln_tax_rec,
      X_QUOTE_HEADER_REC          =>      lx_qte_header_rec,
      X_HEADER_MISC_REC           =>      lx_hd_Misc_Rec,
      X_HEADER_SHIPMENT_REC       =>      lx_hd_shipment_rec,
      X_HEADER_PAYMENT_REC        =>      lx_hd_payment_rec,
      X_HEADER_TAX_DETAIL_REC     =>      lx_hd_tax_rec,
      X_QUOTE_LINE_REC            =>      lx_qte_line_rec,
      X_LINE_MISC_REC             =>      lx_ln_Misc_Rec,
      X_LINE_SHIPMENT_REC         =>      lx_ln_shipment_rec,
      X_LINE_PAYMENT_REC          =>      lx_ln_payment_rec,
      X_LINE_TAX_DETAIL_REC       =>      lx_ln_tax_rec,
      X_CHANGED_FLAG              =>      lx_changed_flag,
      X_RETURN_STATUS             =>      x_return_status,
      X_MSG_COUNT                 =>      x_msg_count,
      X_MSG_DATA                  =>      x_msg_data
    );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('create_quote_service: after call default header entity '||lx_return_status,1, 'N');
    END IF;
    /*
    DBMS_OUTPUT.PUT_LINE('header default entity call return= ' || x_return_status);
    DBMS_OUTPUT.PUT_LINE('status id = ' || lx_qte_header_rec.quote_status_id);
    DBMS_OUTPUT.PUT_LINE('resource id= ' || lx_qte_header_rec.resource_id);
    DBMS_OUTPUT.PUT_LINE('header price list id = ' || lx_qte_header_rec.price_list_id);
    DBMS_OUTPUT.PUT_LINE('currenty code = ' || lx_qte_header_rec.currency_code);
    DBMS_OUTPUT.PUT_LINE('quote_expiration_date = ' || lx_qte_header_rec.quote_expiration_date);
    DBMS_OUTPUT.PUT_LINE('automatic price flag = ' || lx_qte_header_rec.automatic_price_flag);
    DBMS_OUTPUT.PUT_LINE('automatic tax flag = ' || lx_qte_header_rec.automatic_tax_flag);
    DBMS_OUTPUT.PUT_LINE('contract template id = ' || lx_qte_header_rec.contract_template_id);
    DBMS_OUTPUT.PUT_LINE('created by = ' || lx_qte_header_rec.created_by);
    DBMS_OUTPUT.PUT_LINE('org_id = ' || lx_qte_header_rec.org_id);
    DBMS_OUTPUT.PUT_LINE('order_type_id = ' || lx_qte_header_rec.order_type_id);
    DBMS_OUTPUT.PUT_LINE('ship_to_party_site_id = ' || lx_hd_shipment_rec.ship_to_party_site_id);
    DBMS_OUTPUT.PUT_LINE('ship_to_cust_accuont_id = ' || lx_hd_shipment_rec.ship_to_cust_account_id);
    */
    -- Check return status from the above procedure call
    IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
    elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- validate defaulting data
    /*
    ASO_VALIDATE_PVT.VALIDATE_DEFAULTING_DATA(
	P_quote_header_rec    =>lx_qte_header_rec,
	P_quote_line_rec      =>lx_qte_line_rec,
	P_Shipment_header_rec =>lx_hd_shipment_rec,
	P_shipment_line_rec   =>lx_ln_shipment_rec,
	P_Payment_header_rec  =>lx_hd_payment_rec,
	P_Payment_line_rec    =>lx_ln_payment_rec,
	P_tax_header_rec      =>lx_hd_tax_rec,
	P_tax_line_rec        =>lx_ln_tax_rec,
	p_def_object_name     =>l_db_object_name,
	X_quote_header_rec    =>lx_qte_header_rec,
	X_quote_line_rec      =>lx_qte_line_rec,
	X_Shipment_header_rec =>lx_hd_shipment_rec,
	X_Shipment_line_rec   =>lx_ln_shipment_rec,
	X_Payment_header_rec  =>lx_hd_payment_rec,
	X_Payment_line_rec    =>lx_ln_payment_rec,
	X_tax_header_rec      =>lx_hd_tax_Rec,
	X_tax_line_rec        =>lx_ln_tax_rec,
	X_RETURN_STATUS       => x_return_Status,
	X_MSG_DATA            => x_msg_data,
	X_MSG_COUNT           => x_msg_count);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('create_quote_service: after call default header entity validation)'||lx_return_status,1, 'N');
    END IF;
    DBMS_OUTPUT.PUT_LINE('header default validaton return=' || x_return_status);
    IF lx_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
    elsif lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    */
    l_qte_header_rec := lx_qte_header_rec;
    l_hd_shipment_rec := lx_hd_shipment_rec;
    l_hd_payment_rec := lx_hd_payment_rec;
    l_hd_payment_tbl(1) := l_hd_payment_rec;

    -- check additional columns
    IF(l_qte_header_rec.quote_source_code IS NULL
      OR l_qte_header_rec.quote_source_code <> FND_API.G_MISS_CHAR) THEN
        l_qte_header_rec.quote_source_code := 'Order Capture Quotes';
    END IF;

    -- Loop over lines and prepare lines Recored
    l_db_object_name := 'ASO_AK_QUOTE_LINE_V';
    -- control record for lines defaulting
    l_def_control_rec.override_Trigger_Flag := FND_API.G_FALSE;
    l_def_control_rec.dependency_Flag := FND_API.G_FALSE;
    l_def_control_rec.defaulting_Flag := FND_API.G_TRUE;
    l_def_control_rec.application_type_code := 'QUOTING HTML';
    l_def_control_rec.defaulting_flow_code := 'CREATE';

    OPEN C_Get_Master_Org_Id (l_qte_header_rec.org_id);
    FETCH C_Get_Master_Org_Id INTO l_inv_org_id;
    CLOSE C_Get_Master_Org_Id;

--    IF (p_qte_line_tbl IS NOT NULL AND p_qte_line_tbl <> G_MISS_QTE_LINE_TBL) THEN
      FOR i IN 1..p_qte_line_tbl.count LOOP

        l_qte_line_tbl(i).operation_code := 'CREATE';
        l_qte_line_tbl(i).organization_id := l_inv_org_id;

        OPEN C_Get_Item_Info (l_inv_org_id, l_qte_line_tbl(i).inventory_item_id);
          FETCH C_Get_Item_Info INTO l_primary_uom_code, l_serviceable_product_flag, l_bom_item_type;
        CLOSE C_Get_Item_Info;

        IF (l_qte_line_tbl(i).uom_code IS NULL
          OR l_qte_line_tbl(i).uom_code = FND_API.G_MISS_CHAR) THEN
          l_qte_line_tbl(i).uom_code := l_primary_uom_code;
        END IF;

        IF l_bom_item_type = 1 THEN -- model item
          l_qte_line_tbl(i).item_type_code := 'MDL';
        ELSE
          IF l_serviceable_product_flag = 'Y' THEN
            l_qte_line_tbl(i).item_type_code := 'SVA';
          ELSE
            l_qte_line_tbl(i).item_type_code := 'STD';
          END IF;
        END IF;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          ASO_QUOTE_UTIL_PVT.debug('Create_Quote_Service: line '|| i);
          ASO_QUOTE_UTIL_PVT.debug('inventory_item_id '|| l_qte_line_tbl(i).inventory_item_id);
          ASO_QUOTE_UTIL_PVT.debug('l_inv_org_id '|| l_inv_org_id);
          ASO_QUOTE_UTIL_PVT.debug('uom_code '|| l_qte_line_tbl(i).uom_code);
          ASO_QUOTE_UTIL_PVT.debug('item_type_code '||l_qte_line_tbl(i).item_type_code );
          ASO_QUOTE_UTIL_PVT.debug('quantity '||l_qte_line_tbl(i).quantity );
        END IF;

          -- validate quantity
        inv_decimals_pub.validate_quantity(
            l_qte_line_tbl(i).inventory_item_id,
            l_inv_org_id,
            l_qte_line_tbl(i).quantity,
            l_qte_line_tbl(i).uom_code,
            l_output_qty,
            l_primary_qty,
            x_valid_quantity);
        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          ASO_QUOTE_UTIL_PVT.debug('Returning from INV_DECIMALS_PUB.validate_quantity ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;

        -- Prepare l_trigger_attribute_tbl
        l_trigger_attribute_tbl := ASO_Defaulting_Int.G_MISS_ATTRIBUTE_CODES_TBL;

        k :=1;
	IF (p_qte_line_tbl(i).order_line_type_id IS NOT NULL
          AND p_qte_line_tbl(i).order_line_type_id <> FND_API.G_MISS_NUM) THEN
          l_trigger_attribute_tbl(k) :='L_ORDER_LINE_TYPE_ID';
          k := k+1;
        END IF;

	IF (p_qte_line_tbl(i).agreement_id IS NOT NULL
          AND p_qte_line_tbl(i).agreement_id <> FND_API.G_MISS_NUM) THEN
          l_trigger_attribute_tbl(k) :='L_AGREEMENT_ID';
          k := k+1;
        END IF;

        IF (p_qte_line_tbl(i).invoice_to_cust_account_id IS NOT NULL
          AND p_qte_line_tbl(i).invoice_to_cust_account_id <> FND_API.G_MISS_NUM) THEN
          l_trigger_attribute_tbl(k) :='L_INV_TO_CUST_ACCT_ID';
          k := k+1;
        END IF;

        IF (p_qte_line_tbl(i).invoice_to_party_site_id IS NOT NULL
          AND p_qte_line_tbl(i).invoice_to_party_site_id <> FND_API.G_MISS_NUM) THEN
          l_trigger_attribute_tbl(k) :='L_INV_TO_PTY_SITE_ID';
          k := k+1;
        END IF;
/*
	IF (p_qte_line_tbl(i).line_ship_to_cust_acct_number IS NOT NULL
          AND p_qte_line_tbl(i).line_ship_to_cust_acct_number <> FND_API.G_MISS_NUM) THEN
          l_trigger_attribute_tbl(k) := 'L_SHIP_TO_CUST_ACCT_ID';
          k := k+1;
        END IF;

	IF (p_qte_line_tbl(i).ship_to_address1 IS NOT NULL
          AND p_qte_line_tbl(i).ship_to_address1 <> FND_API.G_MISS_CHAR) THEN
          l_trigger_attribute_tbl(k) := 'L_SHIP_TO_PARTY_SITE_ID';
          k := k+1;
        END IF;
  */
	IF (p_qte_line_tbl(i).price_list_id IS NOT NULL
          AND p_qte_line_tbl(i).price_list_id <> FND_API.G_MISS_NUM) THEN
          l_trigger_attribute_tbl(k) := 'L_PRICE_LIST_ID';
        END IF;

        l_qte_line_rec := p_qte_line_tbl(i);

        Aso_Defaulting_Int.Default_Entity (
          P_API_VERSION               =>      1.0,
          P_INIT_MSG_LIST             =>      FND_API.G_TRUE,
          P_COMMIT                    =>      FND_API.G_TRUE,
          P_CONTROL_REC               =>      l_def_control_rec,
          P_DATABASE_OBJECT_NAME      =>      l_db_object_name,
          P_TRIGGER_ATTRIBUTES_TBL    =>      l_trigger_attribute_tbl,
          P_QUOTE_HEADER_REC          =>      l_qte_header_rec,
          P_OPP_QTE_HEADER_REC        =>      l_opp_qte_in_rec,
          P_HEADER_MISC_REC           =>      l_hd_Misc_Rec,
          P_HEADER_SHIPMENT_REC       =>      l_hd_shipment_rec,
          P_HEADER_PAYMENT_REC        =>      l_hd_payment_rec,
          P_HEADER_TAX_DETAIL_REC     =>      l_hd_tax_rec,
          P_QUOTE_LINE_REC            =>      l_qte_line_rec,
          P_LINE_MISC_REC             =>      l_ln_Misc_Rec,
          P_LINE_SHIPMENT_REC         =>      l_ln_shipment_rec,
          P_LINE_PAYMENT_REC          =>      l_ln_payment_rec,
          P_LINE_TAX_DETAIL_REC       =>      l_ln_tax_rec,
          X_QUOTE_HEADER_REC          =>      lx_qte_header_rec,
          X_HEADER_MISC_REC           =>      lx_hd_Misc_Rec,
          X_HEADER_SHIPMENT_REC       =>      lx_hd_shipment_rec,
          X_HEADER_PAYMENT_REC        =>      lx_hd_payment_rec,
          X_HEADER_TAX_DETAIL_REC     =>      lx_hd_tax_rec,
          X_QUOTE_LINE_REC            =>      lx_qte_line_rec,
          X_LINE_MISC_REC             =>      lx_ln_Misc_Rec,
          X_LINE_SHIPMENT_REC         =>      lx_ln_shipment_rec,
          X_LINE_PAYMENT_REC          =>      lx_ln_payment_rec,
          X_LINE_TAX_DETAIL_REC       =>      lx_ln_tax_rec,
          X_CHANGED_FLAG              =>      lx_changed_flag,
          X_RETURN_STATUS             =>      x_return_status,
          X_MSG_COUNT                 =>      x_msg_count,
          X_MSG_DATA                  =>      x_msg_data
        );

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('create_quote_service: after call default line entity '||k||lx_return_status,1, 'N');
        END IF;
        -- Check return status from the above procedure call
        IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_qte_line_tbl (i) :=  lx_qte_line_rec;

        -- additional check
        IF l_qte_line_tbl(i).line_category_code IS NULL
          OR l_qte_line_tbl(i).line_category_code <> FND_API.G_MISS_CHAR THEN
          l_qte_line_tbl(i).line_category_code := 'ORDER';
        END IF;

      END LOOP;
   -- END IF;

    -- Prepare control record to call create_quote
    -- call create_quote api

          -- Prepare Control Record
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('ASO_QUOTE_PUB.Create_Quote_Service: Start to prepare control record');
      aso_debug_pub.add('Profile Value ASO_CALCULATE_PRICE is ' ||fnd_profile.value('ASO_CALCULATE_PRICE'), 1, 'N');
      aso_debug_pub.add('Profile Value ASO_CALCULATE_TAX is ' ||fnd_profile.value('ASO_CALCULATE_TAX'), 1, 'N');
    END IF;

    IF NVL(FND_PROFILE.VALUE('ASO_CALCULATE_PRICE'), 'A')='M' THEN
      l_control_rec.pricing_request_type := 'ASO';
      l_control_rec.price_mode := NULL;
      l_control_rec.header_pricing_event := NULL;
      l_control_rec.calculate_freight_charge_flag := 'N';
      l_qte_header_rec.pricing_status_indicator := 'I';
    ELSE
      l_control_rec.pricing_request_type :='ASO';
      l_control_rec.price_mode := 'ENTIRE_QUOTE';
      l_control_rec.header_pricing_event := 'BATCH';
      l_control_rec.calculate_freight_charge_flag := 'Y';
      l_qte_header_rec.pricing_status_indicator := 'C';
    END IF;

    IF NVL(FND_PROFILE.VALUE('ASO_CALCULATE_TAX'), 'A')='M' THEN
      l_control_rec.calculate_tax_flag := 'N';
      l_qte_header_rec.tax_status_indicator := 'I';
    ELSE
      l_control_rec.calculate_tax_flag := 'Y';
      l_qte_header_rec.tax_status_indicator := 'C';
    END IF;

   Create_quote(
	    P_Api_Version_Number        => 1.0,
	    P_Init_Msg_List		=> p_init_msg_list,
	    P_Commit			=> p_commit,
	    P_Control_Rec		=> p_control_rec,
	    P_qte_header_rec		=> l_qte_header_rec,
	    P_Hd_Price_Attributes_Tbl	=> p_Hd_Price_Attributes_Tbl,
	    P_Hd_Payment_Tbl		=> l_Hd_Payment_Tbl,
	    P_Hd_Shipment_Rec		=> l_Hd_Shipment_Rec,
	    P_Hd_Freight_Charge_Tbl	=> p_Hd_Freight_Charge_Tbl,
	    P_Hd_Tax_Detail_Tbl		=> p_Hd_Tax_Detail_Tbl,
	    P_Qte_Line_Tbl		=> l_Qte_Line_Tbl,
	    P_Qte_Line_Dtl_Tbl		=> p_Qte_Line_Dtl_Tbl,
	    P_Line_Attr_Ext_Tbl		=> P_Line_Attr_Ext_Tbl,
	    P_Line_rltship_tbl		=> p_Line_Rltship_Tbl,
	    P_Price_Adjustment_Tbl	=> p_Price_Adjustment_Tbl,
	    P_Price_Adj_Attr_Tbl	=> P_Price_Adj_Attr_Tbl,
	    P_Price_Adj_Rltship_Tbl	=> p_Price_Adj_Rltship_Tbl,
	    P_Ln_Price_Attributes_Tbl	=> p_Ln_Price_Attributes_Tbl,
	    P_Ln_Payment_Tbl		=> p_Ln_Payment_Tbl,
	    P_Ln_Shipment_Tbl		=> p_Ln_Shipment_Tbl,
	    P_Ln_Freight_Charge_Tbl	=> p_Ln_Freight_Charge_Tbl,
	    P_Ln_Tax_Detail_Tbl		=> p_Ln_Tax_Detail_Tbl,
	    x_qte_header_rec		=> x_qte_header_rec,
	    X_Hd_Price_Attributes_Tbl	=> x_Hd_Price_Attributes_Tbl,
	    X_Hd_Payment_Tbl		=> x_Hd_Payment_Tbl,
	    X_Hd_Shipment_Rec		=> x_Hd_Shipment_Rec,
	    X_Hd_Freight_Charge_Tbl	=> x_Hd_Freight_Charge_Tbl,
	    X_Hd_Tax_Detail_Tbl		=> x_Hd_Tax_Detail_Tbl,
            X_hd_Attr_Ext_Tbl		=> x_hd_Attr_Ext_Tbl,
            X_hd_Sales_Credit_Tbl       => x_hd_Sales_Credit_Tbl,
            X_hd_Quote_Party_Tbl        => x_hd_Quote_Party_Tbl,
	    X_Qte_Line_Tbl		=> x_Qte_Line_Tbl,
	    X_Qte_Line_Dtl_Tbl		=> x_Qte_Line_Dtl_Tbl,
	    x_Line_Attr_Ext_Tbl		=> x_Line_Attr_Ext_Tbl,
	    X_Line_rltship_tbl		=> x_Line_Rltship_Tbl,
	    X_Price_Adjustment_Tbl	=> x_Price_Adjustment_Tbl,
	    x_Price_Adj_Attr_Tbl	=> x_Price_Adj_Attr_Tbl,
	    X_Price_Adj_Rltship_Tbl	=> x_Price_Adj_Rltship_Tbl,
	    X_Ln_Price_Attributes_Tbl	=> x_Ln_Price_Attributes_Tbl,
	    X_Ln_Payment_Tbl		=> x_Ln_Payment_Tbl,
	    X_Ln_Shipment_Tbl		=> x_Ln_Shipment_Tbl,
	    X_Ln_Freight_Charge_Tbl	=> x_Ln_Freight_Charge_Tbl,
	    X_Ln_Tax_Detail_Tbl		=> x_Ln_Tax_Detail_Tbl,
            X_Ln_Sales_Credit_Tbl       => x_ln_Sales_Credit_Tbl,
            X_Ln_Quote_Party_Tbl        => x_ln_Quote_Party_Tbl,
            x_Qte_Access_Tbl            => x_Qte_Access_Tbl,
            x_Template_Tbl              => x_Template_Tbl,
	    X_Related_Obj_Tbl           => X_Related_Obj_Tbl,
	    X_Return_Status             => x_return_status,
	    X_Msg_Count                 => x_msg_count,
	    X_Msg_Data                  => x_msg_data);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('create_quote_service_pub: after create_quote'||x_return_status,1, 'N');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		        FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		        FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_PUB.Create_Quote', FALSE);
		        FND_MSG_PUB.ADD;
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION

	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END; -- Create_Quote_Service


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--  This is an overloaded procedure. It takes additional attributes
--  which include the hd_attributes, sales credits and quote party record types


PROCEDURE Update_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Validation_Level 	        IN   NUMBER                                  := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		        IN   Control_Rec_Type                        := G_Miss_Control_Rec,
    P_Qte_Header_Rec		   IN   Qte_Header_Rec_Type                     := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		   IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Tbl		   IN   ASO_QUOTE_PUB.Shipment_Tbl_Type         := G_MISS_SHIPMENT_TBL,
    P_hd_Freight_Charge_Tbl	   IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		   IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		   IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		        IN   Qte_Line_Tbl_Type                       := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		   IN   Qte_Line_Dtl_Tbl_Type                   := G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		   IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		   IN   Line_Rltship_Tbl_Type                   := G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	   IN   Price_Adj_Tbl_Type                      := G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	        IN   Price_Adj_Attr_Tbl_Type                 := G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	   IN   Price_Adj_Rltship_Tbl_Type              := G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	   IN   Price_Attributes_Tbl_Type               := G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		   IN   Payment_Tbl_Type                        := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		   IN   Shipment_Tbl_Type                       := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	   IN   Freight_Charge_Tbl_Type                 := G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		   IN   Tax_Detail_Tbl_Type                     := G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl             IN   Qte_Access_Tbl_Type                     := G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl               IN   Template_Tbl_Type                       := G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl            IN   Related_Obj_Tbl_Type                    := G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec		   OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		        OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		   OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Hd_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		   OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		   OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	        OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	   OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		   OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		   OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl             OUT NOCOPY /* file.sql.39 change */  Qte_Access_Tbl_Type,
    X_Template_Tbl               OUT NOCOPY /* file.sql.39 change */  Template_Tbl_Type,
    X_Related_Obj_Tbl            OUT NOCOPY /* file.sql.39 change */  Related_Obj_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    l_api_name                 CONSTANT VARCHAR2(30) := 'UPDATE_QUOTE';
    l_api_version_number       CONSTANT NUMBER       := 1.0;
    l_Qte_Header_Rec	      Qte_Header_Rec_Type;
    l_Qte_Header_Rec_Out       Qte_Header_Rec_Type;
    l_Qte_Line_Tbl	           Qte_Line_Tbl_Type;
    l_Qte_Line_Rec_Out	      Qte_Line_Rec_Type;
    l_hd_shipment_tbl	      Shipment_Tbl_Type;
    l_hd_shipment_rec_out      Shipment_Rec_Type;
    l_ln_shipment_tbl	      Shipment_Tbl_Type;
    l_ln_shipment_rec_out      Shipment_Rec_Type;
    l_hd_Payment_Tbl           Payment_Tbl_Type ;
    l_ln_Payment_Tbl           Payment_Tbl_Type ;
    l_Price_Adj_Tbl            Price_Adj_Tbl_Type;
    l_Qte_Line_Dtl_rec         Qte_Line_Dtl_rec_Type ;
    l_hd_Tax_Detail_Tbl        Tax_Detail_Tbl_Type;
    l_ln_Tax_Detail_Tbl        Tax_Detail_Tbl_Type;
    l_hd_Freight_Charge_Tbl    Freight_Charge_Tbl_Type;
    l_ln_Freight_Charge_Tbl    Freight_Charge_Tbl_Type;
    l_Line_Rltship_Tbl         Line_Rltship_Tbl_Type;
    l_hd_Price_Attributes_Tbl  Price_Attributes_Tbl_Type;
    l_ln_Price_Attributes_Tbl  Price_Attributes_Tbl_Type;
    l_Price_Adj_rltship_Tbl    Price_Adj_Rltship_Tbl_Type;
    l_Price_Adj_Attr_Tbl       Price_Adj_Attr_Tbl_Type;
    l_hd_Attribs_Ext_Tbl       Line_Attribs_Ext_Tbl_type;
    l_Line_Attribs_Ext_Tbl     Line_Attribs_Ext_Tbl_type;
    l_Qte_Line_Dtl_tbl         Qte_Line_Dtl_tbl_Type;
    l_hd_Sales_Credit_Tbl      Sales_Credit_Tbl_Type ;
    l_ln_Sales_Credit_Tbl      Sales_Credit_Tbl_Type ;
    l_hd_Quote_Party_Tbl       Quote_Party_Tbl_Type;
    l_ln_Quote_Party_Tbl       Quote_Party_Tbl_Type;
    l_Control_Rec              Control_rec_Type;
    l_validation_level         NUMBER;
    l_Qte_Access_Tbl           Qte_Access_Tbl_Type;
    l_Template_Tbl             Template_Tbl_Type;
    l_Related_Obj_Tbl          Related_Obj_Tbl_Type;

     l_quote_type                     VARCHAR2(1); -- bug 13801993
  l_CONFIG_REC ASO_QUOTE_PUB.QTE_LINE_DTL_REC_TYPE;
   l_MODEL_LINE_REC ASO_QUOTE_PUB.QTE_LINE_REC_TYPE;
   line_det_ct number;
   seg1 varchar2(250);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_QUOTE_PUB;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- mapping to local variables
      l_qte_header_rec          := P_Qte_Header_Rec;
      l_hd_Price_Attributes_Tbl := P_hd_Price_Attributes_Tbl;
      l_hd_Payment_Tbl          := P_hd_Payment_Tbl;
      l_hd_shipment_tbl         := P_hd_Shipment_tbl;
      l_hd_Freight_Charge_Tbl   := P_hd_Freight_Charge_Tbl;
      l_hd_Tax_Detail_Tbl       := P_hd_Tax_Detail_Tbl;
      l_hd_Attribs_Ext_Tbl      := P_hd_Attr_Ext_Tbl;
      l_hd_Sales_Credit_Tbl     := P_hd_Sales_Credit_Tbl;
      l_hd_Quote_Party_Tbl      := P_hd_Quote_Party_Tbl;
      l_Qte_Line_tbl            := p_Qte_Line_tbl;
      l_hd_Payment_Tbl          := p_hd_Payment_Tbl;
      l_Price_Adj_Tbl           := P_Price_Adjustment_Tbl;
      l_Line_Rltship_Tbl        := p_Line_Rltship_Tbl;
   	 l_Price_Adj_rltship_Tbl   := p_Price_Adj_Rltship_Tbl;
      l_ln_Price_Attributes_Tbl := P_Ln_Price_Attributes_Tbl;
  	 l_Price_Adj_Attr_Tbl      := p_Price_Adj_Attr_Tbl;
      l_ln_Payment_Tbl          := P_Ln_Payment_Tbl;
      l_ln_shipment_tbl         := P_Ln_Shipment_Tbl;
      l_ln_Freight_Charge_Tbl   := P_Ln_Freight_Charge_Tbl;
      l_ln_Tax_Detail_Tbl       := P_Ln_Tax_Detail_Tbl;
      l_ln_Sales_Credit_Tbl     := P_ln_Sales_Credit_Tbl;
      l_ln_Quote_Party_Tbl      := P_ln_Quote_Party_Tbl;
    	 l_Line_Attribs_Ext_Tbl    := P_Line_Attr_Ext_Tbl ;
      l_Qte_Line_Dtl_tbl        := p_Qte_Line_Dtl_tbl;
      l_control_rec             := p_control_rec;
      l_validation_level        := P_Validation_Level;
	 l_Qte_Access_Tbl          := P_Qte_Access_Tbl;
	 l_Template_Tbl            := p_Template_Tbl;
	 l_Related_Obj_Tbl         := p_Related_Obj_Tbl;

	 /*** Start code fix for 12.1 bug 13801993 ***/
	   select quote_type into l_quote_type
           from aso_quote_headers_all
           where quote_header_id = l_qte_header_rec.quote_header_id;

           if l_quote_type='T' then
                  l_control_rec.calculate_tax_flag  := 'N';
           end if;

	 /*** End code fix for 12.1 bug 13801993 ***/

      --  call user hooks
      -- customer pre processing

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN

          ASO_QUOTE_CUHK.update_quote_PRE(
                            P_Validation_Level 	    => l_validation_level ,
                            P_Control_Rec		    => l_control_rec ,
                            P_Qte_Header_Rec	         => l_qte_header_rec  ,
                            P_hd_Price_Attributes_Tbl => l_hd_Price_Attributes_Tbl  ,
                            P_hd_Payment_Tbl		    => l_hd_Payment_Tbl ,
                            P_hd_Shipment_tbl         => l_hd_shipment_tbl,
                            P_hd_Freight_Charge_Tbl   => l_hd_Freight_Charge_Tbl,
                            P_hd_Tax_Detail_Tbl	    => l_hd_Tax_Detail_Tbl ,
                            P_hd_Attr_Ext_Tbl         => l_hd_Attribs_Ext_Tbl,
                            P_hd_Sales_Credit_Tbl     => l_hd_Sales_Credit_Tbl ,
                            P_hd_Quote_Party_Tbl      => l_hd_Quote_Party_Tbl   ,
                            P_Qte_Line_Tbl		    => l_Qte_Line_Tbl,
                            P_Qte_Line_Dtl_Tbl        => l_Qte_Line_Dtl_tbl,
                            P_Line_Attr_Ext_Tbl       => l_Line_Attribs_Ext_Tbl,
                            P_line_rltship_tbl        => l_Line_Rltship_Tbl,
                            P_Price_Adjustment_Tbl    => l_Price_Adj_Tbl ,
                            P_Price_Adj_Attr_Tbl      => l_Price_Adj_Attr_Tbl    ,
                            P_Price_Adj_Rltship_Tbl   => l_Price_Adj_rltship_Tbl,
                            P_Ln_Price_Attributes_Tbl => l_ln_Price_Attributes_Tbl  ,
                            P_Ln_Payment_Tbl          => l_ln_Payment_Tbl ,
                            P_Ln_Shipment_Tbl         => l_ln_shipment_tbl ,
                            P_Ln_Freight_Charge_Tbl   => l_ln_Freight_Charge_Tbl,
                            P_Ln_Tax_Detail_Tbl       => l_ln_Tax_Detail_Tbl,
                            P_ln_Sales_Credit_Tbl     => l_ln_Sales_Credit_Tbl    ,
                            P_ln_Quote_Party_Tbl      => l_ln_Quote_Party_Tbl,
					   /*
                            P_Qte_Access_Tbl          => l_Qte_Access_Tbl,
                            P_Template_Tbl            => l_Template_Tbl,
                            p_Related_Obj_Tbl         => l_Related_Obj_Tbl,
					   */
                            X_Return_Status           => X_Return_Status,
                            X_Msg_Count               => X_Msg_Count,
                            X_Msg_Data                => X_Msg_Data
                            );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		        FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		        FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.update_Quote_PRE', FALSE);
		        FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      END IF; -- customer hook

      -- vertical hook
      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN

           ASO_QUOTE_VUHK.update_quote_PRE(
                            P_Validation_Level 	    => l_validation_level ,
                            P_Control_Rec		    => l_control_rec ,
                            P_Qte_Header_Rec	         => l_qte_header_rec  ,
                            P_hd_Price_Attributes_Tbl => l_hd_Price_Attributes_Tbl  ,
                            P_hd_Payment_Tbl		    => l_hd_Payment_Tbl ,
                            P_hd_Shipment_tbl         => l_hd_shipment_tbl,
                            P_hd_Freight_Charge_Tbl   => l_hd_Freight_Charge_Tbl,
                            P_hd_Tax_Detail_Tbl       => l_hd_Tax_Detail_Tbl ,
                            P_hd_Attr_Ext_Tbl         => l_hd_Attribs_Ext_Tbl,
                            P_hd_Sales_Credit_Tbl     => l_hd_Sales_Credit_Tbl ,
                            P_hd_Quote_Party_Tbl      => l_hd_Quote_Party_Tbl   ,
                            P_Qte_Line_Tbl		    => l_Qte_Line_Tbl,
                            P_Qte_Line_Dtl_Tbl        => l_Qte_Line_Dtl_tbl,
                            P_Line_Attr_Ext_Tbl       => l_Line_Attribs_Ext_Tbl,
                            P_line_rltship_tbl        => l_Line_Rltship_Tbl,
                            P_Price_Adjustment_Tbl    => l_Price_Adj_Tbl ,
                            P_Price_Adj_Attr_Tbl	    => l_Price_Adj_Attr_Tbl    ,
                            P_Price_Adj_Rltship_Tbl   => l_Price_Adj_rltship_Tbl,
                            P_Ln_Price_Attributes_Tbl => l_ln_Price_Attributes_Tbl  ,
                            P_Ln_Payment_Tbl	         => l_ln_Payment_Tbl ,
                            P_Ln_Shipment_Tbl         => l_ln_shipment_tbl ,
                            P_Ln_Freight_Charge_Tbl   => l_ln_Freight_Charge_Tbl,
                            P_Ln_Tax_Detail_Tbl       => l_ln_Tax_Detail_Tbl,
                            P_ln_Sales_Credit_Tbl     => l_ln_Sales_Credit_Tbl    ,
                            P_ln_Quote_Party_Tbl      => l_ln_Quote_Party_Tbl,
					   /*
                            P_Qte_Access_Tbl          => l_Qte_Access_Tbl,
                            P_Template_Tbl            => l_Template_Tbl,
					   p_Related_Obj_Tbl         => l_Related_Obj_Tbl,
					   */
                            X_Return_Status           => X_Return_Status,
                            X_Msg_Count               => X_Msg_Count,
                            X_Msg_Data                => X_Msg_Data
                            );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		         FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		         FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Update_Quote_PRE', FALSE);
		         FND_MSG_PUB.ADD;
               END IF;

               IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

           END IF;

      END IF;

      -- Convert the values to ids

      Convert_Header_Values_To_Ids ( p_qte_header_rec   =>  l_qte_header_rec,
                                     x_qte_header_rec   =>  l_qte_header_rec_out );

	 l_qte_header_rec := l_qte_header_rec_out;

      FOR i IN 1..p_qte_line_tbl.count LOOP

          Convert_Line_Values_To_Ids ( p_qte_line_rec	=> l_qte_line_tbl(i),
	                                  x_qte_line_rec	=> l_qte_line_rec_out);

	     l_qte_line_tbl(i) := l_qte_line_rec_out;

      END LOOP;

      FOR i IN 1..p_hd_shipment_tbl.count LOOP

          Convert_Shipment_Values_To_Ids ( p_shipment_rec	=> l_hd_shipment_tbl(i),
	                                      x_shipment_rec	=> l_hd_shipment_rec_out);

	     l_hd_shipment_tbl(i) := l_hd_shipment_rec_out;

      END LOOP;

      FOR i IN 1..p_ln_shipment_tbl.count LOOP

         Convert_Shipment_Values_To_Ids ( p_shipment_rec	=> l_ln_shipment_tbl(i),
	                                    x_shipment_rec	=> l_ln_shipment_rec_out);

	    l_ln_shipment_tbl(i) := l_ln_shipment_rec_out;

      END LOOP;

	/*ER 7428770 Validation for the customer to pass only model line when customer is adding configuration to quote using script */
	If l_qte_header_rec.quote_source_code = 'ASO' Then
	   For i in 1 .. l_qte_line_tbl.count loop
               If (l_qte_line_tbl(i).item_type_code = 'CFG' ) and  l_qte_line_tbl(i).Config_Header_id is not null and l_qte_line_tbl(i).Config_revision_nbr is not null then
                     for j in 1..l_qte_line_tbl.count loop
                              if l_qte_line_tbl(j).item_type_code ='MDL' AND l_qte_line_tbl(i).Config_Header_id=l_qte_line_tbl(j).Config_Header_id and  l_qte_line_tbl(i).Config_revision_nbr=l_qte_line_tbl(j).Config_revision_nbr then
                              Select segment1 into seg1  from  mtl_system_items_B where  INVENTORY_ITEM_ID = l_qte_line_tbl(j).inventory_item_id and ORGANIZATION_ID = l_Qte_Line_Tbl(j).org_id  ;
                    end if;

                 fnd_message.set_name( 'ASO', 'ASO_API_MDL_CFG_PARAM_ERROR' ) ;
                 fnd_message.set_token( 'MODELITEM', seg1,TRUE) ;
                 FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
                 End loop;
            End if;
      End loop;
	  End If;
      ASO_QUOTE_HEADERS_PVT.update_quote(
	                         P_Api_Version_Number	 => 1.0,
	                         P_Init_Msg_List		 => FND_API.G_FALSE,
	                         P_Commit			      => FND_API.G_FALSE,
	                         p_validation_level		 => p_validation_level,
	                         P_Control_Rec		      => l_control_rec,
	                         P_qte_header_rec		 => l_qte_header_rec,
	                         P_Hd_Price_Attributes_Tbl => l_hd_Price_Attributes_Tbl,
	                         P_Hd_Payment_Tbl		 => l_hd_Payment_Tbl,
	                         P_Hd_Shipment_tbl		 => l_Hd_Shipment_tbl,
	                         P_Hd_Freight_Charge_Tbl	 => l_hd_Freight_Charge_Tbl,
	                         P_Hd_Tax_Detail_Tbl		 => l_hd_Tax_Detail_Tbl ,
                              P_hd_Attr_Ext_Tbl         => l_hd_Attribs_Ext_Tbl,
                              P_hd_Sales_Credit_Tbl     => l_hd_Sales_Credit_Tbl ,
                              P_hd_Quote_Party_Tbl      => l_hd_Quote_Party_Tbl,
	                         P_Qte_Line_Tbl		      => l_Qte_Line_Tbl,
	                         P_Qte_Line_Dtl_Tbl		 => l_Qte_Line_Dtl_tbl,
	                         P_Line_Attr_Ext_Tbl		 => l_Line_Attribs_Ext_Tbl,
	                         P_Line_rltship_tbl		 => l_Line_Rltship_Tbl,
	                         P_Price_Adjustment_Tbl	 => l_Price_Adj_Tbl,
	                         P_Price_Adj_Attr_Tbl	 => l_Price_Adj_Attr_Tbl,
	                         P_Price_Adj_Rltship_Tbl	 => l_Price_Adj_rltship_Tbl ,
	                         P_Ln_Price_Attributes_Tbl => l_ln_Price_Attributes_Tbl ,
	                         P_Ln_Payment_Tbl		 => l_Ln_Payment_Tbl,
	                         P_Ln_Shipment_Tbl		 => l_Ln_Shipment_Tbl,
	                         P_Ln_Freight_Charge_Tbl	 => l_Ln_Freight_Charge_Tbl,
	                         P_Ln_Tax_Detail_Tbl		 => l_Ln_Tax_Detail_Tbl,
                              P_ln_Sales_Credit_Tbl     => l_ln_Sales_Credit_Tbl ,
                              P_ln_Quote_Party_Tbl      => l_ln_Quote_Party_Tbl,
                              P_Qte_Access_Tbl          => l_Qte_Access_Tbl,
                              P_Template_Tbl            => l_Template_Tbl,
					     p_Related_Obj_Tbl         => l_Related_Obj_Tbl,
	                         x_qte_header_rec		 => x_qte_header_rec,
	                         X_Hd_Price_Attributes_Tbl => x_Hd_Price_Attributes_Tbl,
	                         X_Hd_Payment_Tbl		 => x_Hd_Payment_Tbl,
	                         X_hd_Shipment_Tbl		 => X_hd_Shipment_Tbl,
	                         X_Hd_Freight_Charge_Tbl	 => x_Hd_Freight_Charge_Tbl,
	                         X_Hd_Tax_Detail_Tbl		 => x_Hd_Tax_Detail_Tbl,
                              X_hd_Attr_Ext_Tbl         => X_hd_Attr_Ext_Tbl,
                              X_hd_Sales_Credit_Tbl     => X_hd_Sales_Credit_Tbl,
                              X_hd_Quote_Party_Tbl      => X_hd_Quote_Party_Tbl,
	                         X_Qte_Line_Tbl		      => x_Qte_Line_Tbl,
	                         X_Qte_Line_Dtl_Tbl		 => x_Qte_Line_Dtl_Tbl,
	                         x_Line_Attr_Ext_Tbl		 => x_Line_Attr_Ext_Tbl,
	                         X_Line_rltship_tbl		 => x_Line_Rltship_Tbl,
	                         X_Price_Adjustment_Tbl	 => x_Price_Adjustment_Tbl,
	                         x_Price_Adj_Attr_Tbl	 => x_Price_Adj_Attr_Tbl,
	                         X_Price_Adj_Rltship_Tbl	 => x_Price_Adj_Rltship_Tbl,
	                         X_Ln_Price_Attributes_Tbl => x_Ln_Price_Attributes_Tbl,
	                         X_Ln_Payment_Tbl		 => x_Ln_Payment_Tbl,
	                         X_Ln_Shipment_Tbl		 => x_Ln_Shipment_Tbl,
	                         X_Ln_Freight_Charge_Tbl	 => x_Ln_Freight_Charge_Tbl,
	                         X_Ln_Tax_Detail_Tbl		 => x_Ln_Tax_Detail_Tbl,
                              X_Ln_Sales_Credit_Tbl     => X_Ln_Sales_Credit_Tbl,
                              X_Ln_Quote_Party_Tbl      => X_Ln_Quote_Party_Tbl ,
                              X_Qte_Access_Tbl          => X_Qte_Access_Tbl,
                              X_Template_Tbl            => X_Template_Tbl,
					     X_Related_Obj_Tbl         => X_Related_Obj_Tbl,
	                         X_Return_Status           => x_return_status,
	                         X_Msg_Count               => x_msg_count,
	                         X_Msg_Data                => x_msg_data);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('update_quote_pub: after update quote, starting user hooks (1)'||x_return_status,1, 'N');
	 END IF;
 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('update_quote_pub: after update quote, starting user hooks (1)'||x_return_status,1, 'N');
	 END IF;
aso_debug_pub.add('After calling update_quote_pub: after update quote x_qte_line_tbl.count '|| x_qte_line_tbl.count);
 For i in 1 ..  x_qte_line_tbl.count loop
If (x_qte_line_tbl(i).item_type_code = 'MDL' ) then
  aso_debug_pub.add('ER 7428770 update_quote_pub quote_line_id value ' || i ||  x_qte_line_tbl(i).quote_line_id);
End If;
  end loop;



      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('update_quote_pub: after update quote, starting user hooks (1)'||x_return_status,1, 'N');
	 END IF;

If x_Return_Status = FND_API.G_RET_STS_SUCCESS  THEN
If l_qte_header_rec.quote_source_code = 'ASO' Then
For i in 1 ..  x_qte_line_tbl.count loop
If (x_qte_line_tbl(i).item_type_code = 'MDL' ) then
select count(quote_line_id) into line_det_ct  from aso_quote_line_details
where quote_line_id = x_qte_line_tbl(i).quote_line_id;
if  (line_det_ct = 0 ) and  (x_qte_line_tbl(i).Config_Header_id IS NOT NULL ) and (x_qte_line_tbl(i).Config_revision_nbr  IS NOT NULL )then
aso_debug_pub.add('ER 7428770 all the above conditions are  satisfied');
l_config_rec.quote_line_id:= x_Qte_Line_Tbl(i).quote_line_id;

l_config_rec.complete_configuration_flag := 'Y';
l_config_rec.valid_configuration_flag := 'Y';
aso_debug_pub.add('ER 7428770 before calling ASO_CFG_PUB.GET_CONFIG_DETAILS x_Qte_Line_Tbl(i).quote_line_id '||x_Qte_Line_Tbl(i).quote_line_id,1, 'N');
              aso_debug_pub.add('ER 7428770 update_quote_pub before calling ASO_CFG_PUB.GET_CONFIG_DETAILS x_QTE_HEADER_REC.quote_header_id '||x_QTE_HEADER_REC.quote_header_id,1, 'N');
              aso_debug_pub.add('ER 7428770 update_quote_pub before calling ASO_CFG_PUB.GET_CONFIG_DETAILS x_qte_line_tbl(i).Config_Header_id '||x_qte_line_tbl(i).Config_Header_id,1, 'N');
              aso_debug_pub.add('ER 7428770 update_quote_pub before calling ASO_CFG_PUB.GET_CONFIG_DETAILS x_qte_line_tbl(i).Config_revision_nbr'||x_qte_line_tbl(i).Config_revision_nbr,1, 'N');


ASO_CFG_PUB.GET_CONFIG_DETAILS(
    P_API_VERSION_NUMBER => 1.0,
    P_INIT_MSG_LIST => FND_API.G_TRUE,
    P_COMMIT => FND_API.G_TRUE,
    P_CONTROL_REC => l_CONTROL_REC,
    P_QTE_HEADER_REC => x_qte_header_rec,
    P_MODEL_LINE_REC => l_MODEL_LINE_REC,
    P_CONFIG_REC => l_CONFIG_REC,
    P_CONFIG_HDR_ID =>x_qte_line_tbl(i).Config_Header_id,
    P_CONFIG_REV_NBR => x_qte_line_tbl(i).Config_revision_nbr,
    X_RETURN_STATUS => X_RETURN_STATUS,
    X_MSG_COUNT => X_MSG_COUNT,
    X_MSG_DATA => X_MSG_DATA
  );
  			  IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('ER 7428770 update_quote_pub After call to ASO_CFG_PUB.GET_CONFIG_DETAILS : Return status:'||x_return_status,1,'N');
aso_debug_pub.add('ER 7428770 update_quote_pub After call to ASO_CFG_PUB.GET_CONFIG_DETAILS ::Msg count:'||x_msg_count,1,'N');
END IF;
End If;
end if;
--End If;
end LOOP;
End If;
End If;
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN

           ASO_QUOTE_CUHK.Update_quote_POST(
                            P_Validation_Level        => l_validation_level ,
                            P_Control_Rec             => l_control_rec ,
                            P_Qte_Header_Rec	         => x_qte_header_rec  ,
                            P_hd_Price_Attributes_Tbl => x_hd_Price_Attributes_Tbl  ,
                            P_hd_Payment_Tbl	         => x_hd_Payment_Tbl ,
                            P_hd_Shipment_tbl         => x_hd_shipment_tbl,
                            P_hd_Freight_Charge_Tbl   => x_hd_Freight_Charge_Tbl,
                            P_hd_Tax_Detail_Tbl	    => x_hd_Tax_Detail_Tbl ,
                            P_hd_Attr_Ext_Tbl	    => x_hd_Attr_Ext_Tbl,
                            P_hd_Sales_Credit_Tbl     => x_hd_Sales_Credit_Tbl ,
                            P_hd_Quote_Party_Tbl      => x_hd_Quote_Party_Tbl   ,
                            P_Qte_Line_Tbl		    => x_Qte_Line_Tbl,
                            P_Qte_Line_Dtl_Tbl	    => x_Qte_Line_Dtl_tbl,
                            P_Line_Attr_Ext_Tbl	    => x_Line_Attr_Ext_Tbl,
                            P_line_rltship_tbl	    => x_Line_Rltship_Tbl,
                            P_Price_Adjustment_Tbl    => x_Price_Adjustment_Tbl ,
                            P_Price_Adj_Attr_Tbl	    => x_Price_Adj_Attr_Tbl    ,
                            P_Price_Adj_Rltship_Tbl   => x_Price_Adj_rltship_Tbl,
                            P_Ln_Price_Attributes_Tbl => x_ln_Price_Attributes_Tbl  ,
                            P_Ln_Payment_Tbl	         => x_ln_Payment_Tbl ,
                            P_Ln_Shipment_Tbl         => x_ln_shipment_tbl ,
                            P_Ln_Freight_Charge_Tbl   => x_ln_Freight_Charge_Tbl,
                            P_Ln_Tax_Detail_Tbl       => x_ln_Tax_Detail_Tbl,
                            P_ln_Sales_Credit_Tbl     => x_ln_Sales_Credit_Tbl    ,
                            P_ln_Quote_Party_Tbl      => x_ln_Quote_Party_Tbl,
					   /*
                            P_Qte_Access_Tbl          => x_Qte_Access_Tbl,
                            P_Template_Tbl            => x_Template_Tbl,
					   P_Related_Obj_Tbl         => x_Related_Obj_Tbl,
					   */
                            X_Return_Status           => X_Return_Status,
                            X_Msg_Count               => X_Msg_Count,
                            X_Msg_Data                => X_Msg_Data
                            );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		         FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		         FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.Update_Quote_POST', FALSE);
		         FND_MSG_PUB.ADD;
               END IF;

               IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

           END IF;

      END IF; -- customer hook

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('aso_quote_vuhk: before if update quote post (1)'||x_return_status,1, 'N');
	 END IF;

      IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('aso_quote_vuhk: inside if update quote post (1)'||x_return_status,1, 'N');
	     END IF;

          ASO_QUOTE_VUHK.Update_quote_POST(
                           P_Validation_Level        => l_validation_level ,
                           P_Control_Rec             => l_control_rec ,
                           P_Qte_Header_Rec	        => x_qte_header_rec  ,
                           P_hd_Price_Attributes_Tbl => x_hd_Price_Attributes_Tbl  ,
                           P_hd_Payment_Tbl	        => x_hd_Payment_Tbl ,
                           P_hd_Shipment_tbl         => x_hd_shipment_tbl,
                           P_hd_Freight_Charge_Tbl   => x_hd_Freight_Charge_Tbl,
                           P_hd_Tax_Detail_Tbl       => x_hd_Tax_Detail_Tbl ,
                           P_hd_Attr_Ext_Tbl	        => x_hd_Attr_Ext_Tbl,
                           P_hd_Sales_Credit_Tbl     => x_hd_Sales_Credit_Tbl ,
                           P_hd_Quote_Party_Tbl      => x_hd_Quote_Party_Tbl   ,
                           P_Qte_Line_Tbl            => x_Qte_Line_Tbl,
                           P_Qte_Line_Dtl_Tbl        => x_Qte_Line_Dtl_tbl,
                           P_Line_Attr_Ext_Tbl       => x_Line_Attr_Ext_Tbl,
                           P_line_rltship_tbl        => x_Line_Rltship_Tbl,
                           P_Price_Adjustment_Tbl	   => x_Price_Adjustment_Tbl ,
                           P_Price_Adj_Attr_Tbl	   => x_Price_Adj_Attr_Tbl    ,
                           P_Price_Adj_Rltship_Tbl   => x_Price_Adj_rltship_Tbl,
                           P_Ln_Price_Attributes_Tbl => x_ln_Price_Attributes_Tbl  ,
                           P_Ln_Payment_Tbl		   => x_ln_Payment_Tbl ,
                           P_Ln_Shipment_Tbl		   => x_ln_shipment_tbl ,
                           P_Ln_Freight_Charge_Tbl   => x_ln_Freight_Charge_Tbl,
                           P_Ln_Tax_Detail_Tbl       => x_ln_Tax_Detail_Tbl,
                           P_ln_Sales_Credit_Tbl     => x_ln_Sales_Credit_Tbl    ,
                           P_ln_Quote_Party_Tbl      => x_ln_Quote_Party_Tbl,
					  /*
                           P_Qte_Access_Tbl          => x_Qte_Access_Tbl,
                           P_Template_Tbl            => x_Template_Tbl,
					  P_Related_Obj_Tbl         => x_Related_Obj_Tbl,
					  */
                           X_Return_Status           => X_Return_Status,
                           X_Msg_Count               => X_Msg_Count,
                           X_Msg_Data                => X_Msg_Data
                           );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('update_quote_pub: after vertical hooks'||x_return_status,1, 'N');
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		        FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		        FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_VUHK.Update_Quote_POST', FALSE);
		        FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      END IF; -- vertical hook

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (  p_count          =>   x_msg_count,
                                   p_data           =>   x_msg_data );


      EXCEPTION

          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END;

-- ER 3177722
Procedure validate_model_configuration
 (
    P_Api_Version_Number              IN             NUMBER,
    P_Init_Msg_List                   IN             VARCHAR2  := FND_API.G_TRUE,  -- rassharm
    P_Commit                          IN             VARCHAR2  := FND_API.G_FALSE,
    P_Quote_header_id                 IN   NUMBER,
    p_Quote_line_id                   IN   NUMBER := FND_API.G_MISS_NUM,
    P_UPDATE_QUOTE                    IN   VARCHAR2 := FND_API.G_FALSE,
    P_Config_EFFECTIVE_DATE		      IN   Date  := FND_API.G_MISS_DATE,
    P_Config_model_lookup_DATE               IN   Date  := FND_API.G_MISS_DATE,
    X_Config_tbl                      OUT NOCOPY /* file.sql.39 change */ Config_Vaild_Tbl_Type,
    X_Return_Status                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                       OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
 )
    as
     l_qte_line_rec                       aso_quote_pub.qte_line_rec_type;
     l_qte_line_tbl                        aso_quote_pub.qte_line_tbl_type;
     l_qte_line_dtl_tbl                 aso_quote_pub.qte_line_dtl_tbl_type;
     l_model_qte_line_tbl          aso_quote_pub.qte_line_tbl_type;
     l_model_qte_line_dtl_tbl    aso_quote_pub.qte_line_dtl_tbl_type;
     l_model_index                     number:=0;

     l_config_index                     number:=0;
     l_control_rec_bv            ASO_QUOTE_PUB.Control_Rec_Type;

     l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
     l_api_name                VARCHAR2(30) := 'VALIDATE_MODEL_CONFIGURATION'; -- removed CONSTANT as part of fix for Bug 12679929
     l_api_version_number      CONSTANT NUMBER   := 1.0;
     l_complete_configuration_flag  VARCHAR2(1);
     l_valid_configuration_flag     VARCHAR2(1);
     l_config_changed                    VARCHAR2(1);
     l_config_header_id number;
     l_config_revision_num number;
     l_new_config_hdr_id number;


    G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_QUOTE_PUB';

    CURSOR c_config_exist_in_cz (p_config_hdr_id number, p_config_rev_nbr number) IS
    select config_hdr_id
    from cz_config_details_v
    where config_hdr_id = p_config_hdr_id
    and config_rev_nbr = p_config_rev_nbr;

-- variables used for messages
   l_changed_model_line_num VARCHAR2(4000);
   l_invalid_model_line_num VARCHAR2(4000);
   l_line_number VARCHAR2(4000);

   EXCP_USER_DEFINED   EXCEPTION;

   L_Return_X_Msg_data VARCHAR2(4000);
   --l_Init_Msg_List varchar2(1);

    l_In_Line_Number_Tbl                  ASO_LINE_NUM_INT.In_Line_Number_Tbl_Type;
    lx_Out_Line_Number_Tbl                 ASO_LINE_NUM_INT.Out_Line_Number_Tbl_Type;
Begin

   SAVEPOINT validate_model_cfg_pub;

   aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    --dbms_output.put_line('Testing in Progress');
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_QUOTE_PUB: Validate_Model_Configuration Begins', 1, 'Y');
        aso_debug_pub.add('ASO_QUOTE_PUB: Validate_Model_Configuration Begins'||p_init_msg_list,1,'Y');
    END IF;

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
		 		                         p_api_version_number,
					                     l_api_name,
					                     G_PKG_NAME) THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_api_name := 'VALIDATE_MODEL_CFG'; -- Added for Bug 12679929

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       aso_debug_pub.add('ASO_QUOTE_PUB: p_init_msg_list true', 1, 'Y');
       FND_MSG_PUB.initialize;
    END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Begin Validate_model_configuration pvt', 1, 'Y');
   aso_debug_pub.add('Begin quote_header_id'||P_Quote_header_id, 1, 'Y');
   aso_debug_pub.add('Begin quote_line_id'||P_Quote_line_id, 1, 'Y');
   aso_debug_pub.add('Begin p_update_quote'||p_update_quote, 1, 'Y');
   aso_debug_pub.add('Begin p_commit'||p_commit, 1, 'Y');
end if;

-- dbms_output.put_line('Entered quote line id  in Progress'||p_Quote_line_id);

if (p_Quote_line_id <> FND_API.G_MISS_NUM)  then    -- Model line id is being sent
    -- dbms_output.put_line('Entered quote line id  in Progress');
     l_qte_line_rec:=ASO_UTILITY_PVT.Query_Qte_Line_Row(p_Quote_line_id);
      l_model_qte_line_tbl(1) :=l_qte_line_rec;
      l_qte_line_dtl_tbl:= ASO_UTILITY_PVT.Query_Line_Dtl_Rows(p_Quote_line_id);
      l_model_qte_line_dtl_tbl(1).config_header_id:= l_qte_line_dtl_tbl(1).config_header_id;
      l_model_qte_line_dtl_tbl(1).config_revision_num:= l_qte_line_dtl_tbl(1).config_revision_num;
else
--   dbms_output.put_line('Entered else  in Progress');
   l_qte_line_tbl:=ASO_UTILITY_PVT.Query_Qte_Line_Rows(P_Quote_header_id);
   for i in 1..l_qte_line_tbl.count loop
   -- query the quote for all the models and populate the model line id  and details table
       if l_qte_line_tbl(i).item_type_code='MDL' then
               l_qte_line_dtl_tbl:= ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_tbl(i).quote_line_id);
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Validate_model_configuration detail table count l_qte_line_dtl_tbl'||l_qte_line_dtl_tbl.count, 1, 'Y');
                End if;

	       If l_qte_line_dtl_tbl.count = 0 then
                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Set config header_id and config_rev_num to null if there is no model details ', 1, 'Y');
                End if;
                l_qte_line_dtl_tbl(1).config_header_id := Null;
                l_qte_line_dtl_tbl(1).config_revision_num := Null;
              End if;
	     --   dbms_output.put_line('After l_qte_line_dtl_tbl the mdl table'||l_qte_line_dtl_tbl.count);
              l_model_index := l_model_index + 1;
              l_model_qte_line_tbl(l_model_index):=l_qte_line_tbl(i);
	      l_model_qte_line_dtl_tbl(l_model_index).config_header_id:= l_qte_line_dtl_tbl(1).config_header_id;
              l_model_qte_line_dtl_tbl(l_model_index).config_revision_num:= l_qte_line_dtl_tbl(1).config_revision_num;

     end if; -- Item type code MDL
   end loop;
 End if;  --End quote line id null or FND_API.G_MISS_NUM

 -- dbms_output.put_line('After populating the mdl table'||l_model_qte_line_tbl.count);
/*
   Added by Arul to check no model lines in the Quote.
   Catherine will do this check in UI.

 IF nvl(l_model_qte_line_tbl.count,0) = 0 THEN
    FND_MESSAGE.Set_Name('ASO', 'ASO_NO_MODEL_LINE_QUOTE');
    FND_MSG_PUB.ADD;
    RAISE EXCP_USER_DEFINED;
 ELSE
*/

   FOR i IN 1..l_model_qte_line_tbl.count LOOP
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('Validate_model_configuration: l_model_qte_line_tbl('||i||').quote_line_id: '||l_model_qte_line_tbl(i).quote_line_id,1,'N');
          aso_debug_pub.add('Validate_model_configuration: l_model_qte_line_dtl_tbl('||i||').config_header_id: '||l_model_qte_line_dtl_tbl(i).config_header_id,1,'N');
          aso_debug_pub.add('Validate_model_configuration: l_model_qte_line_dtl_tbl('||i||').config_revision_num: '||l_model_qte_line_dtl_tbl(i).config_revision_num,1,'N');
       END IF;
     --dbms_output.put_line('Validate_model_configuration: l_model_qte_line_tbl('||i||').quote_line_id: '||l_model_qte_line_tbl(i).quote_line_id);
     --dbms_output.put_line('Validate_model_configuration: l_model_qte_line_dtl_tbl('||i||').config_header_id: '||l_model_qte_line_dtl_tbl(i).config_header_id);
     --dbms_output.put_line('Validate_model_configuration: l_model_qte_line_dtl_tbl('||i||').config_revision_num: '||l_model_qte_line_dtl_tbl(i).config_revision_num);

 /*
 -- Sending modfied model line id and its details
 -- Discussed with CZ we need not send the line and details tables

       l_send_qte_line_tbl     := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
       l_send_qte_line_dtl_tbl := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;
       l_send_qte_line_tbl(1):=ASO_UTILITY_PVT.Query_Qte_Line_Row(l_model_qte_line_tbl(i).quote_line_id);
       l_send_qte_line_tbl(1).operation_code:='UPDATE';
       l_send_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_model_qte_line_tbl(i).quote_line_id);
 */
       l_control_rec_bv.header_pricing_event  :=  null;
       l_control_rec_bv.calculate_tax_flag    :=  'N';
       l_control_rec_bv.defaulting_fwk_flag   :=  'N';


        -- Call Batch Validation procedure
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 aso_debug_pub.add('ASO_QUOTE_PUB : Before call to ASO_BATCH_VALIDATE_CFG_PVT.Validate_Configuration'|| l_model_qte_line_tbl(i).quote_line_id,1,'N');
		 END IF;

     /*FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      => x_msg_count,
        p_data       => x_msg_data
      );
      x_msg_data := fnd_msg_pub.get( p_msg_index => 1, p_encoded => 'F');
      */
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_QUOTE_PUB: Validate_Model_Configuration Begins', 1, 'Y');
       -- aso_debug_pub.add('rassharm Update_Quote: ASO_VALIDATE_CFG_PVT.Validate_Configuration Begins'||x_msg_count, 1, 'Y');
        --aso_debug_pub.add('rassharm Update_Quote: ASO_VALIDATE_CFG_PVT.Validate_Configuration Begins'||x_msg_data, 1, 'Y');
    END IF;

   -- Added  condition for unconfigured items
    if  (l_model_qte_line_dtl_tbl(i).config_header_id is not null) and ( l_model_qte_line_dtl_tbl(i).config_revision_num is not null) then

           ASO_VALIDATE_CFG_PVT.Validate_Configuration
               ( P_Api_Version_Number           =>  1.0,
                 P_Init_Msg_List                =>  FND_API.G_FALSE,
                 P_Commit                       =>  FND_API.G_FALSE,
                 p_control_rec                  =>  l_control_rec_bv,
                 P_model_line_id                =>  l_model_qte_line_tbl(i).quote_line_id,
                 P_Qte_Line_Tbl                 =>  ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
                 P_Qte_Line_Dtl_Tbl             => ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
		 p_update_quote                      => p_update_quote,
		 P_EFFECTIVE_DATE	 => P_Config_EFFECTIVE_DATE,
		 P_model_lookup_DATE => P_Config_model_lookup_DATE,
                 X_config_header_id             =>  l_config_header_id,
                 X_config_revision_num          =>  l_config_revision_num,
                 X_valid_configuration_flag     =>  l_valid_configuration_flag,
                 X_complete_configuration_flag  =>  l_complete_configuration_flag,
		 X_config_changed           =>   l_config_changed,
                 X_return_status                =>  l_return_status,
                 X_msg_count                    =>  x_msg_count,
                 X_msg_data                     =>  x_msg_data
                );
END IF;  -- end condition for unconfigured items

-- Initializing the output parameters for unconfigured item else it would be assigned to previous value for null case since the private API is not called
if  (l_model_qte_line_dtl_tbl(i).config_header_id is null) and ( l_model_qte_line_dtl_tbl(i).config_revision_num is  null) then
  l_config_header_id:=NULL;
  l_config_revision_num:=NULL;
 l_valid_configuration_flag:=NULL;
 l_complete_configuration_flag:='N';
 l_config_changed:=NULL;
 l_return_status := FND_API.G_RET_STS_SUCCESS;
end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
		     aso_debug_pub.add('ASO_QUOTE_PUB: After call to Batch Validate_Configuration: l_return_status: '||l_return_status,1,'Y');
		     aso_debug_pub.add('ASO_QUOTE_PUB: l_config_header_id:            '|| l_config_header_id,1,'N');
		     aso_debug_pub.add('ASO_QUOTE_PUB: l_config_revision_num:         '|| l_config_revision_num,1,'N');
		     aso_debug_pub.add('ASO_QUOTE_PUB: l_valid_configuration_flag:    '|| l_valid_configuration_flag,1,'N');
		     aso_debug_pub.add('ASO_QUOTE_PUB: l_complete_configuration_flag: '|| l_complete_configuration_flag,1,'N');
		     aso_debug_pub.add('ASO_QUOTE_PUB: l_config_changed:    '|| l_config_changed,1,'N');
END IF;
       --dbms_output.put_line('ASO_QUOTE_PUB: After call to Batch Validate_Configuration: l_return_status: '||l_return_status);
       --dbms_output.put_line('ASO_QUOTE_PUB: l_config_header_id:            '|| l_config_header_id);
       --dbms_output.put_line('ASO_QUOTE_PUB: l_config_revision_num:         '|| l_config_revision_num);
       --dbms_output.put_line('ASO_QUOTE_PUB:  l_valid_configuration_flag:    '|| l_valid_configuration_flag);
       --dbms_output.put_line('ASO_QUOTE_PUB:  l_complete_configuration_flag: '|| l_complete_configuration_flag);
       --dbms_output.put_line('ASO_QUOTE_PUB: l_config_changed:    '|| l_config_changed);

           IF (l_return_status = FND_API.G_RET_STS_SUCCESS)  THEN
                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('ASO Quote Pub : Batch Validate configuration success');
                   END IF;
                 -- code populate the cz rec type and set the changed flag
		 l_config_index:=l_config_index+1;
		 X_Config_tbl(l_config_index).quote_line_id:=  l_model_qte_line_tbl(i).quote_line_id;
                 X_Config_tbl(l_config_index).IS_CFG_CHANGED_FLAG:=l_config_changed;
		 X_Config_tbl(l_config_index).IS_CFG_VALID:=l_valid_configuration_flag;
                 X_Config_tbl(l_config_index).IS_CFG_COMPLETE:=l_complete_configuration_flag;
	   end if;

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN

               open c_config_exist_in_cz(l_config_header_id, l_config_revision_num);
               fetch c_config_exist_in_cz into l_new_config_hdr_id;

               if c_config_exist_in_cz%found then

                   close c_config_exist_in_cz;

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('Update Quote: A higher version exist for this configuration so deleting it from CZ');
                   END IF;

                   ASO_CFG_INT.DELETE_CONFIGURATION_AUTO( P_API_VERSION_NUMBER  => 1.0,
                                                          P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                                          P_CONFIG_HDR_ID       => l_config_header_id,
                                                          P_CONFIG_REV_NBR      => l_config_revision_num,
                                                          X_RETURN_STATUS       => x_return_status,
                                                          X_MSG_COUNT           => x_msg_count,
                                                          X_MSG_DATA            => x_msg_data);

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('After call to ASO_CFG_INT.DELETE_CONFIGURATION_AUTO: x_Return_Status: ' || x_Return_Status);
                   END IF;

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                          FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                          FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
                          FND_MSG_PUB.ADD;
                       END IF;

                       RAISE FND_API.G_EXC_ERROR;

                   END IF;

               else
                   close c_config_exist_in_cz;
               end if;

           END IF;

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
  --END IF;  -- end condition for unconfigured items

   END LOOP; --l_model_qte_line_tbl.count

 --End if;

   IF (l_return_status = FND_API.G_RET_STS_SUCCESS)  THEN
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO Quote Pub1 : Batch Validate configuration success'||X_Config_tbl.count);
         END IF;

          FOR i IN 1..X_Config_tbl.count LOOP
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO Quote Pub1 : Batch Validate configuration success X_Config_tbl('||i||').QUOTE_LINE_ID:'||X_Config_tbl(i).QUOTE_LINE_ID);
            aso_debug_pub.add('ASO Quote Pub1 : Batch Validate configuration success X_Config_tbl('||i||').IS_CFG_CHANGED_FLAG:'||X_Config_tbl(i).IS_CFG_CHANGED_FLAG);
            aso_debug_pub.add('ASO Quote Pub1 : Batch Validate configuration success X_Config_tbl('||i||').IS_CFG_VALID:'||X_Config_tbl(i).IS_CFG_VALID);
            aso_debug_pub.add('ASO Quote Pub1 : Batch Validate configuration success X_Config_tbl('||i||').IS_CFG_COMPLETE:'||X_Config_tbl(i).IS_CFG_COMPLETE);
          END IF;

              If  X_Config_tbl(i).IS_CFG_CHANGED_FLAG = 'Y' then
                /* L_In_Line_Number_Tbl(1).Quote_Line_Id := X_Config_tbl(i).QUOTE_LINE_ID;
                 ASO_LINE_NUM_INT.ASO_UI_LINE_NUMBER(
                   P_In_Line_Number_Tbl => L_In_Line_Number_Tbl,
                   X_Out_Line_Number_Tbl =>l_Out_Line_Number_Tbl);

                  l_line_number:=l_Out_Line_Number_Tbl(X_Config_tbl(i).QUOTE_LINE_ID);
                  --l_line_number := ASO_LINE_NUM_INT.Get_UI_Line_Number (X_Config_tbl(i).QUOTE_LINE_ID);
		  ASO_QUOTE_PUB_W.Get_UI_Line_Number(X_Config_tbl(i).QUOTE_LINE_ID,l_Line_Number);*/

                  ASO_LINE_NUM_INT.RESET_LINE_NUM;

                  l_In_Line_Number_Tbl(1).quote_line_id := X_Config_tbl(i).QUOTE_LINE_ID;

                  ASO_LINE_NUM_INT.ASO_UI_LINE_NUMBER (
                      P_In_Line_Number_Tbl   =>     l_In_Line_Number_Tbl,
                      X_Out_Line_Number_Tbl  =>     lx_Out_Line_Number_Tbl
                  );

                  L_Line_Number := ASO_LINE_NUM_INT.Get_UI_Line_Number(X_Config_tbl(i).QUOTE_LINE_ID);

		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('ASO Quote Pub1 : Batch Validate configuration succes l_line_number'||l_line_number);
		 end if;
                  If l_changed_model_line_num is Null then
                     l_changed_model_line_num := l_line_number;
                  Else
                     l_changed_model_line_num := l_changed_model_line_num ||', '|| l_line_number;
                  End if;
              End if;

              If X_Config_tbl(i).IS_CFG_VALID = 'N' or X_Config_tbl(i).IS_CFG_COMPLETE = 'N' then
	         --ASO_QUOTE_PUB_W.Get_UI_Line_Number(X_Config_tbl(i).QUOTE_LINE_ID,l_Line_Number);
                 --l_line_number := ASO_LINE_NUM_INT.Get_UI_Line_Number (X_Config_tbl(i).QUOTE_LINE_ID);
		 ASO_LINE_NUM_INT.RESET_LINE_NUM;

                  l_In_Line_Number_Tbl(1).quote_line_id := X_Config_tbl(i).QUOTE_LINE_ID;

                  ASO_LINE_NUM_INT.ASO_UI_LINE_NUMBER (
                      P_In_Line_Number_Tbl   =>     l_In_Line_Number_Tbl,
                      X_Out_Line_Number_Tbl  =>     lx_Out_Line_Number_Tbl
                  );

                  L_Line_Number := ASO_LINE_NUM_INT.Get_UI_Line_Number(X_Config_tbl(i).QUOTE_LINE_ID);

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('ASO Quote Pub1 : Batch Validate configuration succes l_line_number'||l_line_number);
		 end if;
                 If l_invalid_model_line_num is Null then
                    l_invalid_model_line_num := l_line_number;
                 Else
                    l_invalid_model_line_num := l_invalid_model_line_num ||', '||l_line_number;
                 End if;
              End if;

          END LOOP;
/*
              If l_changed_model_line_num is Null AND l_invalid_model_line_num is Null then
                 FND_MESSAGE.Set_Name('ASO', 'ASO_MODEL_LINES_VALID_NOCHANGE');
                 FND_MSG_PUB.ADD;
              End if;
*/

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO Quote Pub1 : Batch Validate configuration success after X_Config_tbl loop');
         END IF;

              If l_changed_model_line_num is Not Null OR l_invalid_model_line_num is Not Null then
                 FND_MESSAGE.Set_Name('ASO', 'ASO_MODEL_LINES_VALID_NOCHANGE');
                 FND_MSG_PUB.ADD;
              End if;

              If l_changed_model_line_num is Not Null and P_UPDATE_QUOTE = 'T' then
                  FND_MESSAGE.Set_Name('ASO', 'ASO_CHANGED_MODEL_LINES_QUOTE');
                  FND_MESSAGE.Set_Token('CHANGED_MODEL_LINE_NUM', l_changed_model_line_num, FALSE);
                  FND_MSG_PUB.ADD;
              Elsif l_changed_model_line_num is Not Null and P_UPDATE_QUOTE = 'F' then
                  FND_MESSAGE.Set_Name('ASO', 'ASO_UPDATE_MODEL_LINES_QUOTE');
                  FND_MESSAGE.Set_Token('CHANGED_MODEL_LINE_NUM', l_changed_model_line_num, FALSE);
                  FND_MSG_PUB.ADD;
              End if;

              If l_invalid_model_line_num is not null then
                  FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_MODEL_LINES_QUOTE');
                  FND_MESSAGE.Set_Token('INVALID_MODEL_LINE_NUM', l_invalid_model_line_num, FALSE);
                  FND_MSG_PUB.ADD;
              End if;

             /*This needs to be done where the BV api is called during Place_Order
              If X_Config_tbl.count > 0 and X_Config_tbl(i).IS_CFG_CHANGED_FLAG = 'Y' then
                  FND_MESSAGE.Set_Name('ASO', 'ASO_CHANGED_MODEL_LINES_REVIEW');
                  FND_MSG_PUB.ADD;
              End if;
              */
        End if;

      x_return_status := l_return_status;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO Quote Pub : End Batch Validate configuration  x_return_status '|| x_return_status);
         aso_debug_pub.add('ASO Quote Pub : End Batch Validate configuration  X_Config_tbl.count '|| X_Config_tbl.count);
      End if;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
          COMMIT WORK;
      END IF;

      /* Added this Function to return the x_msg_data */
      --L_Return_X_Msg_data := Return_X_Msg_data;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO Quote Pub : End Batch Validate configuration  L_Return_X_Msg_data '||L_Return_X_Msg_data, 1, 'Y');
      End if;

   -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
      ( p_count      => x_msg_count,
        p_data       => x_msg_data
      );

      /* Assign the L_Return_X_Msg_data to the x_msg_data that can be shown in UI directly */
    -- x_msg_data := L_Return_X_Msg_data;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO Quote Pub : End Batch Validate configuration  x_msg_count '||x_msg_count, 1, 'Y');
      End if;


      EXCEPTION
            WHEN EXCP_USER_DEFINED THEN
                x_return_status := FND_API.G_RET_STS_ERROR;

                fnd_msg_pub.count_and_get
                ( p_count => x_msg_count
                , p_data  => x_msg_data);

          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end validate_model_configuration;

End ASO_QUOTE_PUB;

/
