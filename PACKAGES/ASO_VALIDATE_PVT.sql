--------------------------------------------------------
--  DDL for Package ASO_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_VALIDATE_PVT" AUTHID CURRENT_USER as
/* $Header: asovvlds.pls 120.8 2006/05/11 11:56:15 skulkarn ship $ */
-- Start of Comments
-- Package name     : ASO_VALIDATE_PVT
-- Purpose          :
--
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Validate_NotNULL_Number (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_NotNULL_VARCHAR2 (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_NotNULL_DATE (
	p_init_msg_list		IN	VARCHAR2,
	p_column_name		IN	VARCHAR2,
	p_notnull_column	IN	DATE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_For_GreaterEndDate (
	p_init_msg_list		IN	VARCHAR2,
	p_start_date            IN      DATE,
        p_end_date              IN      DATE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_For_Positive(
	p_init_msg_list		IN	VARCHAR2,
        p_column_name           IN      VARCHAR2,
	p_value			IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Party(
	p_init_msg_list		IN	VARCHAR2,
	p_party_id		IN	NUMBER,
	p_party_usage		IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Contact(
	p_init_msg_list		IN	VARCHAR2,
	p_contact_id		IN	NUMBER,
	p_contact_usage		IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_PartySite(
	p_init_msg_list		IN	VARCHAR2,
	p_party_id		IN	NUMBER,
	p_party_site_id		IN	NUMBER,
	p_site_usage		IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_OrderType(
	p_init_msg_list		IN	VARCHAR2,
	p_order_type_id		IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_LineType(
	p_init_msg_list		IN	VARCHAR2,
	p_order_line_type_id		IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_PriceList(
	p_init_msg_list		IN	VARCHAR2,
	p_price_list_id		IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Quote_Status(
	p_init_msg_list		IN	VARCHAR2,
	p_quote_status_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Inventory_Item(
	p_init_msg_list		IN	VARCHAR2,
	p_inventory_item_id	IN	NUMBER,
	p_organization_id       IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Item_Type_Code(
	p_init_msg_list		IN	VARCHAR2,
	p_item_type_code	IN	VARCHAR2,
      --  p_organization_id       IN      NUMBER,
      --  p_inventory_item_id     IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Marketing_Source_Code(
	p_init_msg_list		IN	VARCHAR2,
	p_mkting_source_code_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Tax_Exemption(
	p_init_msg_list		IN	VARCHAR2,
	p_tax_exempt_flag	IN	VARCHAR2,
	p_tax_exempt_reason_code IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_UOM_code(
	p_init_msg_list		IN	VARCHAR2,
	p_uom_code      	IN	VARCHAR2,
        p_organization_id       IN      NUMBER,
        p_inventory_item_id     IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Configuration(
	p_init_msg_list		IN	VARCHAR2,
	p_config_header_id      IN	NUMBER,
        p_config_revision_num   IN      NUMBER,
        p_config_item_id        IN      NUMBER,
        --p_component_code        IN      VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Delayed_Service(
	p_init_msg_list		IN	VARCHAR2,
	p_service_ref_type_code IN      VARCHAR2,
        p_service_ref_line_id   IN      NUMBER,
        p_service_ref_system_id IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Service(
	   p_init_msg_list		      IN	 VARCHAR2,
	   p_inventory_item_id         IN   NUMBER,
        p_start_date_active         IN   DATE,
        p_end_date_active           IN   DATE,
        p_service_duration          IN   NUMBER,
        p_service_period            IN   VARCHAR2,
        p_service_coterminate_flag  IN   VARCHAR2,
	   p_organization_id           IN   NUMBER,
	   x_return_status		      OUT NOCOPY /* file.sql.39 change */  	 VARCHAR2,
        x_msg_count		           OUT NOCOPY /* file.sql.39 change */  	 NUMBER,
        x_msg_data		           OUT NOCOPY /* file.sql.39 change */  	 VARCHAR2);

PROCEDURE Validate_Service_Period(
	p_init_msg_list		IN	VARCHAR2,
        p_service_period        IN      VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Service_Duration(
	p_init_msg_list		IN	VARCHAR2,
        p_service_duration      IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Returns(
        p_init_msg_list		IN	VARCHAR2,
        p_return_ref_type_code  IN      VARCHAR2,
        p_return_ref_header_id  IN      NUMBER,
        p_return_ref_line_id    IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_EmployPerson(
        p_init_msg_list		IN	VARCHAR2,
        p_employee_id           IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_CategoryCode(
        p_init_msg_list		IN	VARCHAR2,
        p_category_code         IN      VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

-- 06/27/00

PROCEDURE Validate_Salescredit_Type(
	p_init_msg_list		IN	VARCHAR2,
	p_salescredit_type_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Party_Type(
	p_init_msg_list		IN	VARCHAR2,
	p_party_type     	IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Party_Object_Type(
	p_init_msg_list		IN	VARCHAR2,
	p_party_object_type     IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Party_Object_Id(
	p_init_msg_list		IN	VARCHAR2,
        p_party_id              IN      NUMBER,
	p_party_object_type     IN	VARCHAR2,
        p_party_object_id       IN      NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Resource_id(
	p_init_msg_list		IN	VARCHAR2,
	p_resource_id	        IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Resource_group_id(
	p_init_msg_list		IN	VARCHAR2,
	p_resource_group_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_Quote_Price_Exp(
	p_init_msg_list		IN	VARCHAR2,
	p_price_list_id		IN	NUMBER,
        p_quote_expiration_date   IN DATE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);
PROCEDURE Validate_Quote_Exp_date(
	p_init_msg_list		IN	VARCHAR2,
    p_quote_expiration_date   IN DATE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);


--07/06/00
-- this procedure calls fnd_flex_descval.validate_desccols('ASO', p_desc_flex_name). If you want to pass segment values instead of segment ids then the call
-- should be modified to fnd_flex_descval.validate_desccols('ASO', p_desc_flex_name, 'V')

PROCEDURE Validate_Desc_Flexfield(
         p_desc_flex_rec       IN OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.attribute_rec_type,
         p_desc_flex_name      IN VARCHAR2 ,
         p_value_or_id         IN VARCHAR2 := 'I',
         x_return_status       OUT NOCOPY /* file.sql.39 change */    varchar2);
PROCEDURE Validate_item_tca_bsc(
	p_init_msg_list		IN	VARCHAR2,
	p_qte_header_rec        IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
	p_shipment_rec        	IN	ASO_QUOTE_PUB.shipment_rec_type  := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
     p_operation_code         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
     p_application_type_code  IN     VARCHAR2  := FND_API.G_MISS_CHAR,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_record_tca_crs(
	p_init_msg_list		IN	VARCHAR2,
	p_qte_header_rec        IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
	p_shipment_rec        	IN	ASO_QUOTE_PUB.shipment_rec_type 		:= ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
     p_operation_code         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
     p_application_type_code  IN     VARCHAR2  := FND_API.G_MISS_CHAR,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

PROCEDURE Validate_QTE_OBJ_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_QUOTE_OBJECT_TYPE_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    );

 PROCEDURE Validate_RLTSHIP_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_RELATIONSHIP_TYPE_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    );
  PROCEDURE  Validate_OBJECT_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_OBJECT_TYPE_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    );
  PROCEDURE Validate_Emp_Res_id(
     p_init_msg_list          IN   VARCHAR2,
     p_resource_id          IN     NUMBER,
     p_employee_person_id    IN    NUMBER,
     x_return_status          OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
        x_msg_count      OUT NOCOPY /* file.sql.39 change */    NUMBER,
        x_msg_data       OUT NOCOPY /* file.sql.39 change */    VARCHAR2);

PROCEDURE Validate_Minisite(
        p_init_msg_list         IN      VARCHAR2,
        p_minisite_id           IN      NUMBER,
        x_return_status         OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */       NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */       VARCHAR2);

PROCEDURE Validate_Section(
        p_init_msg_list         IN      VARCHAR2,
        p_section_id            IN      NUMBER,
        x_return_status         OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */       NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */       VARCHAR2);

Procedure Validate_Quote_Percent(
    p_init_msg_list             IN      VARCHAR2,
    p_sales_credit_tbl          IN      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2);

Procedure Validate_Sales_Credit_Return(
    p_init_msg_list             IN      VARCHAR2,
    p_sales_credit_tbl          IN      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    p_qte_line_rec              IN      ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2);


PROCEDURE  validate_ship_from_org_ID (
    P_Qte_Line_rec	 IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Shipment_rec   IN   ASO_QUOTE_PUB.Shipment_Rec_Type,
    x_return_status  OUT NOCOPY /* file.sql.39 change */    VARCHAR2
   );


PROCEDURE Validate_Commitment(
     P_Init_Msg_List     IN   VARCHAR2,
     P_Qte_Header_Rec    IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     P_Qte_Line_Rec      IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
     X_Return_Status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     X_Msg_Count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     X_Msg_Data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2);


PROCEDURE Validate_Agreement(
     P_Init_Msg_List     IN   VARCHAR2,
     P_Agreement_Id      IN   NUMBER,
     X_Return_Status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     X_Msg_Count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     X_Msg_Data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2);

-- hyang quote_status
PROCEDURE Validate_Status_Transition(
	p_init_msg_list		  IN	VARCHAR2,
	p_source_status_id  IN	NUMBER,
	p_dest_status_id	  IN	NUMBER,
	x_return_status		  OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
  x_msg_count		      OUT NOCOPY /* file.sql.39 change */  	NUMBER,
  x_msg_data		      OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);
-- end of hyang quote_status

-- hyang okc
PROCEDURE Validate_Contract_Template(
	p_init_msg_list		          IN	VARCHAR2,
	p_template_id               IN	NUMBER,
	p_template_major_version	  IN	NUMBER,
	x_return_status		          OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
  x_msg_count		              OUT NOCOPY /* file.sql.39 change */  	NUMBER,
  x_msg_data		              OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);
-- end of hyang okc

PROCEDURE Validate_Promotion (
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     p_price_attr_tbl           IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
     x_price_attr_tbl           OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */    NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */    VARCHAR2);


PROCEDURE VALIDATE_DEFAULTING_DATA(
	P_quote_header_rec		IN		ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
	P_quote_line_rec		IN		ASO_QUOTE_PUB.QTE_LINE_Rec_Type,
	P_Shipment_header_rec		IN		ASO_QUOTE_PUB.shipment_rec_type,
	P_shipment_line_rec		IN		ASO_QUOTE_PUB.shipment_rec_type,
	P_Payment_header_rec		IN		ASO_QUOTE_PUB.Payment_Rec_Type,
	P_Payment_line_rec		IN		ASO_QUOTE_PUB.Payment_Rec_Type,
	P_tax_header_rec		IN		ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
	P_tax_line_rec			IN		ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
	p_def_object_name		IN		VARCHAR,
	X_quote_header_rec		OUT NOCOPY	ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
	X_quote_line_rec		OUT NOCOPY	ASO_QUOTE_PUB.QTE_LINE_Rec_Type,
	X_Shipment_header_rec		OUT NOCOPY	ASO_QUOTE_PUB.shipment_rec_type,
	X_Shipment_line_rec		OUT NOCOPY       ASO_QUOTE_PUB.shipment_rec_type,
	X_Payment_header_rec		OUT NOCOPY	ASO_QUOTE_PUB.Payment_Rec_Type,
	X_Payment_line_rec		OUT NOCOPY      ASO_QUOTE_PUB.Payment_Rec_Type,
	X_tax_header_rec		OUT NOCOPY	ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
	X_tax_line_rec			OUT NOCOPY	ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
	X_RETURN_STATUS			OUT NOCOPY	VARCHAR2,
	X_MSG_DATA			OUT NOCOPY	VARCHAR2,
	X_MSG_COUNT			OUT NOCOPY	VARCHAR2 );
Function Validate_PaymentTerms(
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_TRUE,
	p_payment_term_id	IN	NUMBER)
RETURN VARCHAR2;

FUNCTION Validate_FreightTerms(
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_TRUE,
	p_freight_terms_code	IN	VARCHAR2)
RETURN VARCHAR2;

FUNCTION Validate_ShipMethods(
	p_init_msg_list		IN	VARCHAR2  := FND_API.G_TRUE,
	p_ship_method_code	IN	VARCHAR2,
	p_ship_from_org_id      IN      NUMBER    := FND_API.G_MISS_NUM,
        p_qte_header_id         IN      NUMBER,
        p_qte_line_id           IN      NUMBER  := FND_API.G_MISS_NUM)
RETURN VARCHAR2;

PROCEDURE Validate_ln_type_for_ord_type
(
p_init_msg_list	IN	VARCHAR2,
p_qte_header_rec	IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type,
P_Qte_Line_rec	IN	ASO_QUOTE_PUB.Qte_Line_Rec_Type,
x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_msg_count OUT NOCOPY /* file.sql.39 change */ NUMBER,
x_msg_data OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Validate_ln_category_code
(
p_init_msg_list	IN	VARCHAR2,
p_qte_header_rec	IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type,
P_Qte_Line_rec	IN	ASO_QUOTE_PUB.Qte_Line_Rec_Type,
x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_msg_count OUT NOCOPY /* file.sql.39 change */ NUMBER,
x_msg_data OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Validate_po_line_number
(
  p_init_msg_list	  IN   VARCHAR2  := fnd_api.g_false,
  p_qte_header_rec    IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  P_Qte_Line_rec	  IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC,
  x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2);


PROCEDURE validate_service_ref_line_id
(
p_init_msg_list          IN    VARCHAR2  := fnd_api.g_false,
p_service_ref_type_code  IN    VARCHAR2,
p_service_ref_line_id    IN    NUMBER,
p_qte_header_id          IN    NUMBER    := fnd_api.g_miss_num,
x_return_status          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_msg_count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
x_msg_data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2);


Procedure Validate_cc_info
(
  p_init_msg_list     IN   VARCHAR2  := fnd_api.g_false,
  p_payment_rec       IN   aso_quote_pub.payment_rec_type,
  p_qte_header_rec    IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  P_Qte_Line_rec      IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC,
  x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

  PROCEDURE VALIDATE_OU(p_qte_header_rec    IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type) ;

PROCEDURE validate_ship_method_code
(
p_init_msg_list          IN    VARCHAR2  := fnd_api.g_false,
p_qte_header_id          IN    NUMBER    := fnd_api.g_miss_num,
p_qte_line_id            IN    NUMBER    := fnd_api.g_miss_num,
p_organization_id        IN    NUMBER    := fnd_api.g_miss_num,
p_ship_method_code       IN    VARCHAR2  := fnd_api.g_miss_char,
p_operation_code         IN    VARCHAR2  := fnd_api.g_miss_char,
x_return_status          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_msg_count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
x_msg_data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2);


END ASO_VALIDATE_PVT;


 

/
