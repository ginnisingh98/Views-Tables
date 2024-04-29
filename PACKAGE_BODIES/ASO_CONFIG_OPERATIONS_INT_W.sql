--------------------------------------------------------
--  DDL for Package Body ASO_CONFIG_OPERATIONS_INT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CONFIG_OPERATIONS_INT_W" as
/* $Header: asovqwcb.pls 120.2 2005/10/03 15:39:00 skulkarn ship $ */
-- Start of Comments
-- Package name     : ASO_CONFIG_OPERATIONS_INT_W
-- Purpose          : Rosetta wrappers for ASO Config Operations Public API
-- History          : Created on 09/12/02
-- NOTE             :
-- END of Comments
ROSETTA_G_MISTAKE_DATE DATE   := TO_DATE('01/01/+4713', 'MM/DD/SYYYY');
ROSETTA_G_MISS_NUM     NUMBER := 0-1962.0724;

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'ASO_CONFIG_OPERATIONS_INT_W';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ASOVQWCB.PLS';

FUNCTION rosetta_g_miss_num_map(n number) RETURN number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
BEGIN
    IF n=a THEN RETURN b; END IF;
    IF n=b THEN RETURN a; END IF;
    RETURN n;
END;

PROCEDURE Is_Container
  (p_api_version                      IN  NUMBER    := 1                   ,
   p_inventory_item_id                IN  NUMBER    := FND_API.G_MISS_NUM  ,
   p_organization_id                  IN  NUMBER    := FND_API.G_MISS_NUM  ,
   p_ap_config_creation_date          IN  DATE      := FND_API.G_MISS_DATE ,
   p_ap_config_model_lookup_date      IN  DATE      := FND_API.G_MISS_DATE ,
   p_ap_config_effective_date         IN  DATE      := FND_API.G_MISS_DATE ,
   p_ap_calling_application_id        IN  NUMBER    := FND_API.G_MISS_NUM  ,
   p_ap_usage_name                    IN  VARCHAR2  := FND_API.G_MISS_CHAR ,
   p_ap_publication_mode              IN  VARCHAR2  := FND_API.G_MISS_CHAR ,
   p_ap_language                      IN  VARCHAR2  := FND_API.G_MISS_CHAR ,
   x_return_value                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2                         ,
   x_return_status                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2                         ,
   x_msg_count                        OUT NOCOPY /* file.sql.39 change */ NUMBER                           ,
   x_msg_data                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) AS
   l_appl_param_rec  CZ_API_PUB.appl_param_rec_type;
   l_api_name         CONSTANT VARCHAR2(30)   := 'is_container';

BEGIN
    Aso_Quote_Util_Pvt.Enable_Debug_Pvt;
    Aso_Quote_Util_Pvt.debug('Aso_Config_Operations_Int_W.Is_Container BEGIN');

    Aso_Quote_Util_Pvt.debug('Construct appl param record');
    Aso_Quote_Util_Pvt.debug('calling appln id '||p_ap_calling_application_id);
   l_appl_param_rec := Construct_Appl_Param_Rec(
                       p_ap_config_creation_date       => p_ap_config_creation_date,
                       p_ap_config_model_lookup_date   => p_ap_config_model_lookup_date,
                       p_ap_config_effective_date      => p_ap_config_effective_date,
                       p_ap_calling_application_id     => p_ap_calling_application_id,
                       p_ap_usage_name                 => p_ap_usage_name,
                       p_ap_publication_mode           => p_ap_publication_mode,
                       p_ap_language                   => p_ap_language
                     );

    Aso_Quote_Util_Pvt.debug('Call TO CZ_NETWORK_API_PUB.Is_Container ');
  CZ_NETWORK_API_PUB.Is_Container(p_api_version       => 1.0,
                                  p_inventory_item_id => p_inventory_item_id,
				  p_organization_id   => p_organization_id,
				  p_appl_param_rec    => l_appl_param_rec,
				  x_return_value      => x_return_value,
				  x_return_status     => x_return_status,
				  x_msg_count         => x_msg_count,
				  x_msg_data          => x_msg_data
				 );

   Aso_Quote_Util_Pvt.debug('X_Return_value from ASO '||x_return_value);
   Aso_Quote_Util_Pvt.debug('X_Return_Status from Is_Container '||X_Return_Status);
   Aso_Quote_Util_Pvt.debug('Aso_Config_Operations_Int_W.Is_Container END');
   Aso_Quote_Util_Pvt.Disable_Debug_Pvt;

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR
   THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
	Aso_Quote_Util_Pvt.Disable_Debug_Pvt;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
     Aso_Quote_Util_Pvt.Disable_Debug_Pvt;
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
    ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
END Is_Container;

PROCEDURE Get_Contained_Models
  (x_model_tbl                        OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE                  ,
   p_api_version                      IN  NUMBER     := 1                   ,
   p_inventory_item_id                IN  NUMBER     := FND_API.G_MISS_NUM  ,
   p_organization_id                  IN  NUMBER     := FND_API.G_MISS_NUM  ,
   p_ap_config_creation_date          IN  DATE       := FND_API.G_MISS_DATE ,
   p_ap_config_model_lookup_date      IN  DATE       := FND_API.G_MISS_DATE ,
   p_ap_config_effective_date         IN  DATE       := FND_API.G_MISS_DATE ,
   p_ap_calling_application_id        IN  NUMBER     := FND_API.G_MISS_NUM  ,
   p_ap_usage_name                    IN  VARCHAR2   := FND_API.G_MISS_CHAR ,
   p_ap_publication_mode              IN  VARCHAR2   := FND_API.G_MISS_CHAR ,
   p_ap_language                      IN  VARCHAR2   := FND_API.G_MISS_CHAR ,
   x_return_status                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2                          ,
   x_msg_count                        OUT NOCOPY /* file.sql.39 change */ NUMBER                            ,
   x_msg_data                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  )
AS
  l_api_name         CONSTANT VARCHAR2(30)   := 'get_contained_models';
  l_appl_param_rec  CZ_API_PUB.appl_param_rec_type;
  lx_model_tbl      CZ_API_PUB.number_tbl_type;
  	indx1 BINARY_INTEGER; indx2 BINARY_INTEGER;
 BEGIN
   Aso_Quote_Util_Pvt.Enable_Debug_Pvt;
   Aso_Quote_Util_Pvt.debug('Aso_Config_Operations_Int_W.Get_Contained_Models BEGIN');
   x_model_tbl := jtf_number_table();

   Aso_Quote_Util_Pvt.debug('Construct appl param record');
   Aso_Quote_Util_Pvt.debug('calling appln id '||p_ap_calling_application_id);
  l_appl_param_rec := Construct_Appl_Param_Rec(
                       p_ap_config_creation_date       => p_ap_config_creation_date,
                       p_ap_config_model_lookup_date   => p_ap_config_model_lookup_date,
                       p_ap_config_effective_date      => p_ap_config_effective_date,
                       p_ap_calling_application_id     => p_ap_calling_application_id,
                       p_ap_usage_name                 => p_ap_usage_name,
                       p_ap_publication_mode           => p_ap_publication_mode,
                       p_ap_language                   => p_ap_language
                     );

     Aso_Quote_Util_Pvt.debug('Call to CZ_NETWORK_API_PUB.Get_Contained_Models ');
    CZ_NETWORK_API_PUB.Get_Contained_Models(
	                                p_api_version => 1.0,
					p_inventory_item_id => p_inventory_item_id,
					p_organization_id   => p_organization_id,
					p_appl_param_rec    => l_appl_param_rec,
					x_model_tbl         => lx_model_tbl,
					x_return_status     => x_return_status,
					x_msg_count         => x_msg_count,
					x_msg_data          => x_msg_data
					);
   Aso_Quote_Util_Pvt.debug('return CZ_NETWORK_API_PUB.Get_Contained_Models '||X_Return_Status);
   IF lx_model_tbl.COUNT > 0 THEN
      x_model_tbl.extend(lx_model_tbl.COUNT);

    indx1 := lx_model_tbl.first;
    indx2 := 1;
    WHILE TRUE LOOP
       x_model_tbl(indx2) := rosetta_g_miss_num_map(lx_model_tbl(indx1));
       indx2 := indx2 + 1;
       IF lx_model_tbl.last = indx1
          THEN EXIT;
       END IF;
        indx1 := lx_model_tbl.NEXT(indx1);
    END LOOP;
   END IF;

   Aso_Quote_Util_Pvt.debug('Aso_Config_Operations_Int_W.Get_Contained_Models END');
   Aso_Quote_Util_Pvt.Disable_Debug_Pvt;
   EXCEPTION
   WHEN FND_API.G_EXC_ERROR
   THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
    Aso_Quote_Util_Pvt.Disable_Debug_Pvt;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
    Aso_Quote_Util_Pvt.Disable_Debug_Pvt;
   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
    ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
END Get_Contained_Models;

PROCEDURE Config_Operations
  (x_q_quote_header_id                OUT NOCOPY NUMBER,
   x_q_last_update_date               OUT NOCOPY DATE,
   x_q_object_version_number          OUT NOCOPY NUMBER,
   p_c_last_update_date               IN  DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag                   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_functionality_code             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_copy_task_flag                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_copy_notes_flag                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_copy_att_flag                  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_deactivate_all                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_price_mode                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_dependency_flag                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_defaulting_flag                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_defaulting_fwk_flag            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_application_type_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_header_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_creation_date                  IN  DATE     := FND_API.G_MISS_DATE,
   p_q_created_by                     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_last_updated_by                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_last_update_date               IN  DATE     := FND_API.G_MISS_DATE,
   p_q_last_update_login              IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_request_id                     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_program_application_id         IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_program_id                     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_program_update_date            IN  DATE     := FND_API.G_MISS_DATE,
   p_q_org_id                         IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_quote_name                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_number                   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_quote_version                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_quote_status_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_quote_source_code              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_expiration_date          IN  DATE     := FND_API.G_MISS_DATE,
   p_q_price_frozen_date              IN  DATE     := FND_API.G_MISS_DATE,
   p_q_quote_password                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_original_system_reference      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_party_id                       IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_cust_account_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_invoice_to_cust_acct_id        IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_org_contact_id                 IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_party_name                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_party_type                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_person_first_name              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_person_last_name               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_person_middle_name             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_phone_id                       IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_price_list_id                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_price_list_name                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_currency_code                  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_total_list_price               IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_adjusted_amount          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_adjusted_percent         IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_tax                      IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_shipping_charge          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_surcharge                      IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_quote_price              IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_payment_amount                 IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_accounting_rule_id             IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_exchange_rate                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_exchange_type_code             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_exchange_rate_date             IN  DATE     := FND_API.G_MISS_DATE,
   p_q_quote_category_code            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_status_code              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_status                   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_employee_person_id             IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_sales_channel_code             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_salesrep_first_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_salesrep_last_name             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute_category             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute1                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute10                    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute11                    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute12                    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute13                    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute14                    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute15                    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute2                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute3                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute4                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute5                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute6                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute7                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute8                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute9                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_contract_id                    IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_qte_contract_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_ffm_request_id                 IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_invoice_to_address1            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_address2            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_address3            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_address4            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_city                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_cont_first_name     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_cont_last_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_cont_mid_name       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_country_code        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_country             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_county              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_party_id            IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_invoice_to_party_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_party_site_id       IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_invoice_to_postal_code         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_province            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_state               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoicing_rule_id              IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_marketing_source_code_id       IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_marketing_source_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_marketing_source_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_orig_mktg_source_code_id       IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_order_type_id                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_order_id                       IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_order_number                   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_order_type_name                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_ordered_date                   IN  DATE     := FND_API.G_MISS_DATE,
   p_q_resource_id                    IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_contract_template_id           IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_contract_template_maj_ver      IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_contract_requester_id          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_contract_approval_level        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_publish_flag                   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_resource_grp_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_sold_to_party_site_id          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_display_arithmetic_op          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_description              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_type                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_minisite_id                    IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_cust_party_id                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_invoice_to_cust_party_id       IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_pricing_status_indicator       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_tax_status_indicator           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_price_updated_date             IN  DATE     := FND_API.G_MISS_DATE,
   p_q_tax_updated_date               IN  DATE     := FND_API.G_MISS_DATE,
   p_q_recalculate_flag               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_price_request_id               IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_credit_update_date             IN  DATE     := FND_API.G_MISS_DATE,
   p_q_customer_name_and_title    	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_customer_signature_date    	  IN DATE     := FND_API.G_MISS_DATE,
   p_q_supplier_name_and_title    	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_supplier_signature_date   	  IN DATE     := FND_API.G_MISS_DATE,
   p_q_object_version_number          IN  NUMBER  := FND_API.G_MISS_NUM,
   p_ql_creation_date                 IN  jtf_date_table         := NULL,
   p_ql_created_by                    IN  jtf_number_table       := NULL,
   p_ql_last_updated_by               IN  jtf_number_table       := NULL,
   p_ql_last_update_date              IN  jtf_date_table         := NULL,
   p_ql_last_update_login             IN  jtf_number_table       := NULL,
   p_ql_request_id                    IN  jtf_number_table       := NULL,
   p_ql_program_application_id        IN  jtf_number_table       := NULL,
   p_ql_program_id                    IN  jtf_number_table       := NULL,
   p_ql_program_update_date           IN  jtf_date_table         := NULL,
   p_ql_quote_line_id                 IN  jtf_number_table       := NULL,
   p_ql_quote_header_id               IN  jtf_number_table       := NULL,
   p_ql_org_id                        IN  jtf_number_table       := NULL,
   p_ql_line_number                   IN  jtf_number_table       := NULL,
   p_ql_line_category_code            IN  jtf_varchar2_table_100 := NULL,
   p_ql_item_type_code                IN  jtf_varchar2_table_100 := NULL,
   p_ql_inventory_item_id             IN  jtf_number_table       := NULL,
   p_ql_organization_id               IN  jtf_number_table       := NULL,
   p_ql_quantity                      IN  jtf_number_table       := NULL,
   p_ql_uom_code                      IN  jtf_varchar2_table_100 := NULL,
   p_ql_start_date_active             IN  jtf_date_table         := NULL,
   p_ql_end_date_active               IN  jtf_date_table         := NULL,
   p_ql_order_line_type_id            IN  jtf_number_table       := NULL,
   p_ql_price_list_id                 IN  jtf_number_table       := NULL,
   p_ql_price_list_line_id            IN  jtf_number_table       := NULL,
   p_ql_currency_code                 IN  jtf_varchar2_table_100 := NULL,
   p_ql_line_list_price               IN  jtf_number_table       := NULL,
   p_ql_line_adjusted_amount          IN  jtf_number_table       := NULL,
   p_ql_line_adjusted_percent         IN  jtf_number_table       := NULL,
   p_ql_line_quote_price              IN  jtf_number_table       := NULL,
   p_ql_related_item_id               IN  jtf_number_table       := NULL,
   p_ql_item_relationship_type        IN  jtf_varchar2_table_100 := NULL,
   p_ql_split_shipment_flag           IN  jtf_varchar2_table_100 := NULL,
   p_ql_backorder_flag                IN  jtf_varchar2_table_100 := NULL,
   p_ql_selling_price_change          IN  jtf_varchar2_table_100 := NULL,
   p_ql_recalculate_flag              IN  jtf_varchar2_table_100 := NULL,
   p_ql_attribute_category            IN  jtf_varchar2_table_100 := NULL,
   p_ql_attribute1                    IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute2                    IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute3                    IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute4                    IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute5                    IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute6                    IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute7                    IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute8                    IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute9                    IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute10                   IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute11                   IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute12                   IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute13                   IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute14                   IN  jtf_varchar2_table_300 := NULL,
   p_ql_attribute15                   IN  jtf_varchar2_table_300 := NULL,
   p_ql_accounting_rule_id            IN  jtf_number_table       := NULL,
   p_ql_ffm_content_name              IN  jtf_varchar2_table_300 := NULL,
   p_ql_ffm_content_type              IN  jtf_varchar2_table_300 := NULL,
   p_ql_ffm_document_type             IN  jtf_varchar2_table_300 := NULL,
   p_ql_ffm_media_id                  IN  jtf_varchar2_table_300 := NULL,
   p_ql_ffm_media_type                IN  jtf_varchar2_table_300 := NULL,
   p_ql_ffm_user_note                 IN  jtf_varchar2_table_300 := NULL,
   p_ql_invoice_to_party_id           IN  jtf_number_table       := NULL,
   p_ql_invoice_to_party_site_id      IN  jtf_number_table       := NULL,
   p_ql_invoicing_rule_id             IN  jtf_number_table       := NULL,
   p_ql_marketing_source_code_id      IN  jtf_number_table       := NULL,
   p_ql_operation_code                IN  jtf_varchar2_table_100 := NULL,
   p_ql_invoice_to_cust_acct_id       IN  jtf_number_table       := NULL,
   p_ql_pricing_quantity_uom          IN  jtf_varchar2_table_100 := NULL,
   p_ql_minisite_id                   IN  jtf_number_table       := NULL,
   p_ql_section_id                    IN  jtf_number_table       := NULL,
   p_ql_priced_price_list_id          IN  jtf_number_table       := NULL,
   p_ql_agreement_id                  IN  jtf_number_table       := NULL,
   p_ql_commitment_id                 IN  jtf_number_table       := NULL,
   p_ql_display_arithmetic_op         IN  jtf_varchar2_table_100 := NULL,
   p_ql_invoice_to_cust_party_id      IN  jtf_number_table       := NULL,
   p_i_instance_id                    IN  JTF_NUMBER_TABLE := NULL     ,
   p_i_price_list_id                  IN  JTF_NUMBER_TABLE := NULL     ,
   p_operation_code                   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_api_version_number               IN  NUMBER  := 1                 ,
   p_init_msg_list                    IN  VARCHAR2:= FND_API.G_TRUE    ,
   p_commit                           IN  VARCHAR2:= FND_API.G_FALSE   ,
   p_validation_level                 IN  NUMBER  := FND_API.G_MISS_NUM,
   x_return_status                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2                     ,
   x_msg_count                        OUT NOCOPY /* file.sql.39 change */ NUMBER                       ,
   x_msg_data                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 )
AS
 l_api_name         CONSTANT VARCHAR2(30)   := 'config_operations';
 l_control_rec Aso_Quote_Pub.Control_Rec_Type
               := Aso_Quote_Pub.G_MISS_Control_Rec;
 l_qte_header_rec Aso_Quote_Pub.Qte_Header_Rec_Type
               := Aso_Quote_Pub.G_MISS_Qte_Header_Rec;
 l_instance_tbl Aso_Quote_Headers_Pvt.Instance_Tbl_Type
               := Aso_Quote_Headers_Pvt.G_MISS_Instance_Tbl;
 l_qte_line_tbl Aso_Quote_Pub.Qte_Line_Tbl_Type
               :=  Aso_Quote_Pub.G_MISS_Qte_Line_Tbl;

 x_Qte_Header_Rec Aso_Quote_Pub.Qte_Header_Rec_Type;

BEGIN
    Aso_Quote_Util_Pvt.Enable_Debug_Pvt;
    Aso_Quote_Util_Pvt.debug('Aso_Config_Operations_Int_W.Config_Operations BEGIN');

  Aso_Quote_Util_Pvt.Set_Control_Rec_W(
      p_last_update_date               => p_c_last_update_date,
      p_auto_version_flag              => p_c_auto_version_flag,
      p_pricing_request_type           => p_c_pricing_request_type,
      p_header_pricing_event           => p_c_header_pricing_event,
      p_line_pricing_event             => p_c_line_pricing_event,
      p_cal_tax_flag                   => p_c_cal_tax_flag,
      p_cal_freight_charge_flag        => p_c_cal_freight_charge_flag,
      p_functionality_code             => p_c_functionality_code,
      p_copy_task_flag                 => p_c_copy_task_flag,
      p_copy_notes_flag                => p_c_copy_notes_flag,
      p_copy_att_flag                  => p_c_copy_att_flag,
      p_deactivate_all                 => p_c_deactivate_all,
      p_price_mode                     => p_c_price_mode,
      p_dependency_flag                => p_c_dependency_flag,
      p_defaulting_flag                => p_c_defaulting_flag,
      p_defaulting_fwk_flag            => p_c_defaulting_fwk_flag,
      p_application_type_code          => p_c_application_type_code,
      x_control_rec                    => l_control_rec);

      l_qte_header_rec := Aso_Quote_Util_Pvt.Construct_Qte_Header_Rec(
      p_quote_header_id             => p_q_quote_header_id           ,
      p_creation_date               => p_q_creation_date             ,
      p_created_by                  => p_q_created_by                ,
      p_last_updated_by             => p_q_last_updated_by           ,
      p_last_update_date            => p_q_last_update_date          ,
      p_last_update_login           => p_q_last_update_login         ,
      p_request_id                  => p_q_request_id                ,
      p_program_application_id      => p_q_program_application_id    ,
      p_program_id                  => p_q_program_id                ,
      p_program_update_date         => p_q_program_update_date       ,
      p_org_id                      => p_q_org_id                    ,
      p_quote_name                  => p_q_quote_name                ,
      p_quote_number                => p_q_quote_number              ,
      p_quote_version               => p_q_quote_version             ,
      p_quote_status_id             => p_q_quote_status_id           ,
      p_quote_source_code           => p_q_quote_source_code         ,
      p_quote_expiration_date       => p_q_quote_expiration_date     ,
      p_price_frozen_date           => p_q_price_frozen_date         ,
      p_quote_password              => p_q_quote_password            ,
      p_original_system_reference   => p_q_original_system_reference ,
      p_party_id                    => p_q_party_id                  ,
      p_cust_account_id             => p_q_cust_account_id           ,
      p_invoice_to_cust_account_id  => p_q_invoice_to_cust_acct_id   ,
      p_org_contact_id              => p_q_org_contact_id            ,
      p_party_name                  => p_q_party_name                ,
      p_party_type                  => p_q_party_type                ,
      p_person_first_name           => p_q_person_first_name         ,
      p_person_last_name            => p_q_person_last_name          ,
      p_person_middle_name          => p_q_person_middle_name        ,
      p_phone_id                    => p_q_phone_id                  ,
      p_price_list_id               => p_q_price_list_id             ,
      p_price_list_name             => p_q_price_list_name           ,
      p_currency_code               => p_q_currency_code             ,
      p_total_list_price            => p_q_total_list_price          ,
      p_total_adjusted_amount       => p_q_total_adjusted_amount     ,
      p_total_adjusted_percent      => p_q_total_adjusted_percent    ,
      p_total_tax                   => p_q_total_tax                 ,
      p_total_shipping_charge       => p_q_total_shipping_charge     ,
      p_surcharge                   => p_q_surcharge                 ,
      p_total_quote_price           => p_q_total_quote_price         ,
      p_payment_amount              => p_q_payment_amount            ,
      p_accounting_rule_id          => p_q_accounting_rule_id        ,
      p_exchange_rate               => p_q_exchange_rate             ,
      p_exchange_type_code          => p_q_exchange_type_code        ,
      p_exchange_rate_date          => p_q_exchange_rate_date        ,
      p_quote_category_code         => p_q_quote_category_code       ,
      p_quote_status_code           => p_q_quote_status_code         ,
      p_quote_status                => p_q_quote_status              ,
      p_employee_person_id          => p_q_employee_person_id        ,
      p_sales_channel_code          => p_q_sales_channel_code        ,
      p_salesrep_first_name         => p_q_salesrep_first_name       ,
      p_salesrep_last_name          => p_q_salesrep_last_name        ,
      p_attribute_category          => p_q_attribute_category        ,
      p_attribute1                  => p_q_attribute1                ,
      p_attribute10                 => p_q_attribute10               ,
      p_attribute11                 => p_q_attribute11               ,
      p_attribute12                 => p_q_attribute12               ,
      p_attribute13                 => p_q_attribute13               ,
      p_attribute14                 => p_q_attribute14               ,
      p_attribute15                 => p_q_attribute15               ,
      p_attribute2                  => p_q_attribute2                ,
      p_attribute3                  => p_q_attribute3                ,
      p_attribute4                  => p_q_attribute4                ,
      p_attribute5                  => p_q_attribute5                ,
      p_attribute6                  => p_q_attribute6                ,
      p_attribute7                  => p_q_attribute7                ,
      p_attribute8                  => p_q_attribute8                ,
      p_attribute9                  => p_q_attribute9                ,
      p_contract_id                 => p_q_contract_id               ,
      p_qte_contract_id             => p_q_qte_contract_id           ,
      p_ffm_request_id              => p_q_ffm_request_id            ,
      p_invoice_to_address1         => p_q_invoice_to_address1       ,
      p_invoice_to_address2         => p_q_invoice_to_address2       ,
      p_invoice_to_address3         => p_q_invoice_to_address3       ,
      p_invoice_to_address4         => p_q_invoice_to_address4       ,
      p_invoice_to_city             => p_q_invoice_to_city           ,
      p_invoice_to_cont_first_name  => p_q_invoice_to_cont_first_name,
      p_invoice_to_cont_last_name   => p_q_invoice_to_cont_last_name ,
      p_invoice_to_cont_mid_name    => p_q_invoice_to_cont_mid_name  ,
      p_invoice_to_country_code     => p_q_invoice_to_country_code   ,
      p_invoice_to_country          => p_q_invoice_to_country        ,
      p_invoice_to_county           => p_q_invoice_to_county         ,
      p_invoice_to_party_id         => p_q_invoice_to_party_id       ,
      p_invoice_to_party_name       => p_q_invoice_to_party_name     ,
      p_invoice_to_party_site_id    => p_q_invoice_to_party_site_id  ,
      p_invoice_to_postal_code      => p_q_invoice_to_postal_code    ,
      p_invoice_to_province         => p_q_invoice_to_province       ,
      p_invoice_to_state            => p_q_invoice_to_state          ,
      p_invoicing_rule_id           => p_q_invoicing_rule_id         ,
      p_marketing_source_code_id    => p_q_marketing_source_code_id  ,
      p_marketing_source_code       => p_q_marketing_source_code     ,
      p_marketing_source_name       => p_q_marketing_source_name     ,
      p_orig_mktg_source_code_id    => p_q_orig_mktg_source_code_id  ,
      p_order_type_id               => p_q_order_type_id             ,
      p_order_id                    => p_q_order_id                  ,
      p_order_number                => p_q_order_number              ,
      p_order_type_name             => p_q_order_type_name           ,
      p_ordered_date                => p_q_ordered_date              ,
      p_resource_id                 => p_q_resource_id               ,
      p_contract_template_id        => p_q_contract_template_id      ,
      p_contract_template_maj_ver   => p_q_contract_template_maj_ver ,
      p_contract_requester_id       => p_q_contract_requester_id     ,
      p_contract_approval_level     => p_q_contract_approval_level   ,
      p_publish_flag                => p_q_publish_flag              ,
      p_resource_grp_id             => p_q_resource_grp_id           ,
      p_sold_to_party_site_id       => p_q_sold_to_party_site_id     ,
      p_display_arithmetic_operator => p_q_display_arithmetic_op     ,
      p_quote_description           => p_q_quote_description         ,
      p_quote_type                  => p_q_quote_type                ,
      p_minisite_id                 => p_q_minisite_id               ,
      p_cust_party_id               => p_q_cust_party_id             ,
      p_invoice_to_cust_party_id    => p_q_invoice_to_cust_party_id  ,
      p_pricing_status_indicator    => p_q_pricing_status_indicator  ,
      p_tax_status_indicator        => p_q_tax_status_indicator      ,
      p_price_updated_date          => p_q_price_updated_date        ,
      p_tax_updated_date            => p_q_tax_updated_date          ,
      p_recalculate_flag            => p_q_recalculate_flag          ,
      p_price_request_id            => p_q_price_request_id		    ,
      p_customer_name_and_title    	=> p_q_customer_name_and_title,
	  p_customer_signature_date    	=> p_q_customer_signature_date,
	  p_supplier_name_and_title    	=> p_q_supplier_name_and_title,
	  p_supplier_signature_date    	=> p_q_supplier_signature_date,
      p_credit_update_date          => p_q_credit_update_date,
      p_object_version_number        => p_q_object_version_number);

  l_instance_tbl := Aso_Quote_Util_Pvt.Construct_Instance_Tbl(
      p_instance_id            => p_i_instance_id,
      p_price_list_id          => p_i_price_list_id);

  l_qte_line_tbl := Aso_Quote_Util_Pvt.Construct_Qte_Line_Tbl(
      p_creation_date            => p_ql_creation_date           ,
      p_created_by               => p_ql_created_by              ,
      p_last_updated_by          => p_ql_last_updated_by         ,
      p_last_update_date         => p_ql_last_update_date        ,
      p_last_update_login        => p_ql_last_update_login       ,
      p_request_id               => p_ql_request_id              ,
      p_program_application_id   => p_ql_program_application_id  ,
      p_program_id               => p_ql_program_id              ,
      p_program_update_date      => p_ql_program_update_date     ,
      p_quote_line_id            => p_ql_quote_line_id           ,
      p_quote_header_id          => p_ql_quote_header_id         ,
      p_org_id                   => p_ql_org_id                  ,
      p_line_number              => p_ql_line_number             ,
      p_line_category_code       => p_ql_line_category_code      ,
      p_item_type_code           => p_ql_item_type_code          ,
      p_inventory_item_id        => p_ql_inventory_item_id       ,
      p_organization_id          => p_ql_organization_id         ,
      p_quantity                 => p_ql_quantity                ,
      p_uom_code                 => p_ql_uom_code                ,
      p_start_date_active        => p_ql_start_date_active       ,
      p_end_date_active          => p_ql_end_date_active         ,
      p_order_line_type_id       => p_ql_order_line_type_id      ,
      p_price_list_id            => p_ql_price_list_id           ,
      p_price_list_line_id       => p_ql_price_list_line_id      ,
      p_currency_code            => p_ql_currency_code           ,
      p_line_list_price          => p_ql_line_list_price         ,
      p_line_adjusted_amount     => p_ql_line_adjusted_amount    ,
      p_line_adjusted_percent    => p_ql_line_adjusted_percent   ,
      p_line_quote_price         => p_ql_line_quote_price        ,
      p_related_item_id          => p_ql_related_item_id         ,
      p_item_relationship_type   => p_ql_item_relationship_type  ,
      p_split_shipment_flag      => p_ql_split_shipment_flag     ,
      p_backorder_flag           => p_ql_backorder_flag          ,
      p_selling_price_change     => p_ql_selling_price_change    ,
      p_recalculate_flag         => p_ql_recalculate_flag        ,
      p_attribute_category       => p_ql_attribute_category      ,
      p_attribute1               => p_ql_attribute1              ,
      p_attribute2               => p_ql_attribute2              ,
      p_attribute3               => p_ql_attribute3              ,
      p_attribute4               => p_ql_attribute4              ,
      p_attribute5               => p_ql_attribute5              ,
      p_attribute6               => p_ql_attribute6              ,
      p_attribute7               => p_ql_attribute7              ,
      p_attribute8               => p_ql_attribute8              ,
      p_attribute9               => p_ql_attribute9              ,
      p_attribute10              => p_ql_attribute10             ,
      p_attribute11              => p_ql_attribute11             ,
      p_attribute12              => p_ql_attribute12             ,
      p_attribute13              => p_ql_attribute13             ,
      p_attribute14              => p_ql_attribute14             ,
      p_attribute15              => p_ql_attribute15             ,
      p_accounting_rule_id       => p_ql_accounting_rule_id      ,
      p_ffm_content_name         => p_ql_ffm_content_name        ,
      p_ffm_content_type         => p_ql_ffm_content_type        ,
      p_ffm_document_type        => p_ql_ffm_document_type       ,
      p_ffm_media_id             => p_ql_ffm_media_id            ,
      p_ffm_media_type           => p_ql_ffm_media_type          ,
      p_ffm_user_note            => p_ql_ffm_user_note           ,
      p_invoice_to_party_id      => p_ql_invoice_to_party_id     ,
      p_invoice_to_party_site_id => p_ql_invoice_to_party_site_id,
      p_invoicing_rule_id        => p_ql_invoicing_rule_id       ,
      p_marketing_source_code_id => p_ql_marketing_source_code_id,
      p_operation_code           => p_ql_operation_code          ,
      p_invoice_to_cust_account_id => p_ql_invoice_to_cust_acct_id,
      p_pricing_quantity_uom     => p_ql_pricing_quantity_uom    ,
      p_minisite_id              => p_ql_minisite_id             ,
      p_section_id               => p_ql_section_id              ,
      p_priced_price_list_id     => p_ql_priced_price_list_id    ,
      p_agreement_id             => p_ql_agreement_id            ,
      p_commitment_id            => p_ql_commitment_id           ,
      p_display_arithmetic_operator => p_ql_display_arithmetic_op,
	  p_invoice_to_cust_party_id    => p_ql_invoice_to_cust_party_id);


    Aso_Quote_Util_Pvt.debug('Call TO Aso_Config_Operations_Int.Config_Operations ');

    Aso_Config_Operations_Int.Config_Operations(
   	  p_api_version_number => p_api_version_number,
	  p_init_msg_list      => p_init_msg_list,
	  p_commit             => p_commit,
	  p_validation_level   => p_validation_level,
	  p_control_rec        => l_control_rec,
	  p_qte_header_rec     => l_qte_header_rec,
	  p_qte_line_tbl       => l_qte_line_tbl,
	  p_instance_tbl       => l_instance_tbl,
      p_operation_code     => p_operation_code,
	  x_Qte_Header_Rec     => x_Qte_Header_Rec,
	  x_return_status      => x_return_status,
	  x_msg_count          => x_msg_count,
	  x_msg_data           => x_msg_data);


   x_q_quote_header_id := rosetta_g_miss_num_map(x_Qte_Header_Rec.quote_header_id);
   x_q_last_update_date := x_Qte_Header_Rec.last_update_date;
   x_q_object_version_number := x_Qte_Header_Rec.object_version_number;


    ASO_QUOTE_UTIL_PVT.debug('Quote Hdr Id '|| x_q_quote_header_id);
    ASO_QUOTE_UTIL_PVT.debug('Quote last updt DATE '|| x_q_last_update_date);
    Aso_Quote_Util_Pvt.debug('return Aso_Config_Operations_Int.Config_Operations '||X_Return_Status);
    Aso_Quote_Util_Pvt.debug('Aso_Config_Operations_Int_W.Config_Operations END');
    Aso_Quote_Util_Pvt.Disable_Debug_Pvt;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

   Aso_Quote_Util_Pvt.Disable_Debug_Pvt;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
  );
   Aso_Quote_Util_Pvt.Disable_Debug_Pvt;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
  );
  END IF;
  FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
  );
   Aso_Quote_Util_Pvt.Disable_Debug_Pvt;
END Config_Operations;


FUNCTION Construct_Appl_Param_Rec(
      p_ap_config_creation_date       IN DATE     := FND_API.G_MISS_DATE,
      p_ap_config_model_lookup_date   IN DATE     := FND_API.G_MISS_DATE,
      p_ap_config_effective_date      IN DATE     := FND_API.G_MISS_DATE,
      p_ap_calling_application_id     IN NUMBER   := FND_API.G_MISS_NUM,
      p_ap_usage_name                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ap_publication_mode           IN VARCHAR2 := FND_API.G_MISS_CHAR,
      p_ap_language                   IN VARCHAR2 := FND_API.G_MISS_CHAR
)
RETURN CZ_API_PUB.appl_param_rec_type
IS
   l_appl_param_rec  CZ_API_PUB.appl_param_rec_type;
BEGIN
   ASO_Quote_Util_Pvt.Enable_Debug_Pvt;
   Aso_Quote_Util_Pvt.debug('Aso_Config_Operations_int_w.Construct_Appl_Param_Rec BEGIN');
   IF p_ap_config_creation_date = ROSETTA_G_MISTAKE_DATE THEN
     l_appl_param_rec.config_creation_date := FND_API.G_MISS_DATE;
   ELSE
     l_appl_param_rec.config_creation_date := p_ap_config_creation_date;
   END IF;

   IF p_ap_config_model_lookup_date = ROSETTA_G_MISTAKE_DATE THEN
     l_appl_param_rec.config_model_lookup_date := FND_API.G_MISS_DATE;
   ELSE
     l_appl_param_rec.config_model_lookup_date := p_ap_config_model_lookup_date;
   END IF;

   IF p_ap_config_effective_date = ROSETTA_G_MISTAKE_DATE THEN
     l_appl_param_rec.config_effective_date := FND_API.G_MISS_DATE;
   ELSE
     l_appl_param_rec.config_effective_date := p_ap_config_effective_date;
   END IF;

   IF p_ap_calling_application_id = ROSETTA_G_MISS_NUM THEN
      l_appl_param_rec.calling_application_id := FND_API.G_MISS_NUM;
   ELSE
      l_appl_param_rec.calling_application_id := p_ap_calling_application_id;
   END IF;

   l_appl_param_rec.usage_name := p_ap_usage_name;
   l_appl_param_rec.publication_mode := p_ap_publication_mode;
   l_appl_param_rec.language := p_ap_language;
   Aso_Quote_Util_Pvt.debug('Aso_Config_Operations_int_w.Construct_Appl_Param_Rec END');
   ASO_Quote_Util_Pvt.Enable_Debug_Pvt;
   RETURN l_appl_param_rec;
END Construct_Appl_Param_Rec;

END ASO_Config_Operations_Int_W;

/
