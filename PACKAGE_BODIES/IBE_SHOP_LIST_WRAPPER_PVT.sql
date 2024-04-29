--------------------------------------------------------
--  DDL for Package Body IBE_SHOP_LIST_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_SHOP_LIST_WRAPPER_PVT" AS
/* $Header: IBEVQLWB.pls 120.1.12010000.2 2010/11/30 10:06:00 scnagara ship $ */

ROSETTA_G_MISTAKE_DATE DATE   := TO_DATE('01/01/+4713', 'MM/DD/SYYYY');
ROSETTA_G_MISS_NUM     NUMBER := 0-1962.0724;


FUNCTION Construct_Control_Rec(
   p_c_last_update_date        IN  DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_price_mode	       IN  VARCHAR2 := 'ENTIRE_QUOTE'	-- change line logic pricing
) RETURN ASO_QUOTE_PUB.Control_Rec_Type
IS
   control_rec ASO_QUOTE_PUB.Control_Rec_Type;
BEGIN
   IF p_c_last_update_date = ROSETTA_G_MISTAKE_DATE THEN
      control_rec.last_update_date := FND_API.G_MISS_DATE;
   ELSE
      control_rec.last_update_date := p_c_last_update_date;
   END IF;
   control_rec.auto_version_flag := p_c_auto_version_flag;
   control_rec.pricing_request_type := p_c_pricing_request_type;
   control_rec.header_pricing_event := p_c_header_pricing_event;
   control_rec.line_pricing_event := p_c_line_pricing_event;
   control_rec.calculate_tax_flag := p_c_cal_tax_flag;
   control_rec.calculate_freight_charge_flag := p_c_cal_freight_charge_flag;
   control_rec.price_mode := p_c_price_mode;	-- change line logic pricing
   RETURN control_rec;
END Construct_Control_Rec;


FUNCTION Construct_Quote_Header_Rec(
   p_h_quote_header_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_creation_date              IN  DATE     := FND_API.G_MISS_DATE,
   p_h_created_by                 IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_last_updated_by            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_last_update_date           IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_update_login          IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_request_id                 IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_application_id     IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_id                 IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_update_date        IN  DATE     := FND_API.G_MISS_DATE,
   p_h_org_id                     IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_quote_name                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_quote_number               IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_quote_version              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_quote_status_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_quote_source_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_quote_expiration_date      IN  DATE     := FND_API.G_MISS_DATE,
   p_h_price_frozen_date          IN  DATE     := FND_API.G_MISS_DATE,
   p_h_quote_password             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_original_system_reference  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_party_id                   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_cust_account_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_org_contact_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_party_name                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_party_type                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_person_first_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_person_last_name           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_person_middle_name         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_phone_id                   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_price_list_id              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_pricing_status_indicator   IN  VARCHAR2 := FND_API.G_MISS_CHAR,	-- change line logic pricing
   p_h_tax_status_indicator   	  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_price_list_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_currency_code              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_total_list_price           IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_adjusted_amount      IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_adjusted_percent     IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_tax                  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_shipping_charge      IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_surcharge                  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_quote_price          IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_payment_amount             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_accounting_rule_id         IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_exchange_rate              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_exchange_type_code         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_exchange_rate_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_h_quote_category_code        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_quote_status_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_quote_status               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_employee_person_id         IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_sales_channel_code         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
--   p_h_salesrep_full_name         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute_category         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute1                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute10                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute11                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute12                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute13                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute14                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute15                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute2                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute3                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute4                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute5                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute6                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute7                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute8                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute9                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_contract_id                IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_qte_contract_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_ffm_request_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_invoice_to_address1        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_address2        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_address3        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_address4        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_city            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_cont_first_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_cont_last_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_cont_mid_name   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_country_code    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_country         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_county          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_party_id        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_invoice_to_party_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_party_site_id   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_invoice_to_postal_code     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_province        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_state           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoicing_rule_id          IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_marketing_source_code_id   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_marketing_source_code      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_marketing_source_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_orig_mktg_source_code_id   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_order_type_id              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_order_id                   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_order_number               IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_order_type_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_ordered_date               IN  DATE     := FND_API.G_MISS_DATE,
   p_h_resource_id                IN  NUMBER   := FND_API.G_MISS_NUM
) RETURN ASO_QUOTE_PUB.Qte_Header_Rec_Type
IS
   q_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type;
BEGIN
   IF p_h_quote_header_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.quote_header_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.quote_header_id := p_h_quote_header_id;
   END IF;
   IF p_h_creation_date = ROSETTA_G_MISTAKE_DATE THEN
      q_header_rec.creation_date := FND_API.G_MISS_DATE;
   ELSE
      q_header_rec.creation_date := p_h_creation_date;
   END IF;
   IF p_h_created_by = ROSETTA_G_MISS_NUM THEN
      q_header_rec.created_by := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.created_by := p_h_created_by;
   END IF;
   IF p_h_last_updated_by = ROSETTA_G_MISS_NUM THEN
      q_header_rec.last_updated_by := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.last_updated_by := p_h_last_updated_by;
   END IF;
   IF p_h_last_update_date = ROSETTA_G_MISTAKE_DATE THEN
      q_header_rec.last_update_date := FND_API.G_MISS_DATE;
   ELSE
      q_header_rec.last_update_date := p_h_last_update_date;
   END IF;
   IF p_h_last_update_login = ROSETTA_G_MISS_NUM THEN
      q_header_rec.last_update_login := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.last_update_login := p_h_last_update_login;
   END IF;
   IF p_h_request_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.request_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.request_id := p_h_request_id;
   END IF;
   IF p_h_program_application_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.program_application_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.program_application_id := p_h_program_application_id;
   END IF;
   IF p_h_program_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.program_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.program_id := p_h_program_id;
   END IF;
   IF p_h_program_update_date = ROSETTA_G_MISTAKE_DATE THEN
      q_header_rec.program_update_date := FND_API.G_MISS_DATE;
   ELSE
      q_header_rec.program_update_date := p_h_program_update_date;
   END IF;
   IF p_h_org_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.org_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.org_id := p_h_org_id;
   END IF;
   q_header_rec.quote_name := p_h_quote_name;
   IF p_h_quote_number = ROSETTA_G_MISS_NUM THEN
      q_header_rec.quote_number := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.quote_number := p_h_quote_number;
   END IF;
   IF p_h_quote_version = ROSETTA_G_MISS_NUM THEN
      q_header_rec.quote_version := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.quote_version := p_h_quote_version;
   END IF;
   IF p_h_quote_status_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.quote_status_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.quote_status_id := p_h_quote_status_id;
   END IF;
   q_header_rec.quote_source_code := p_h_quote_source_code;
   IF p_h_quote_expiration_date = ROSETTA_G_MISTAKE_DATE THEN
      q_header_rec.quote_expiration_date := FND_API.G_MISS_DATE;
   ELSE
      q_header_rec.quote_expiration_date := p_h_quote_expiration_date;
   END IF;
   IF p_h_price_frozen_date = ROSETTA_G_MISTAKE_DATE THEN
      q_header_rec.price_frozen_date := FND_API.G_MISS_DATE;
   ELSE
      q_header_rec.price_frozen_date := p_h_price_frozen_date;
   END IF;
   q_header_rec.quote_password := p_h_quote_password;
   q_header_rec.original_system_reference := p_h_original_system_reference;
   IF p_h_party_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.party_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.party_id := p_h_party_id;
   END IF;
   IF p_h_cust_account_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.cust_account_id := p_h_cust_account_id;
   END IF;
   IF p_h_org_contact_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.org_contact_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.org_contact_id := p_h_org_contact_id;
   END IF;
   q_header_rec.party_name := p_h_party_name;
   q_header_rec.party_type := p_h_party_type;
   q_header_rec.person_first_name := p_h_person_first_name;
   q_header_rec.person_last_name := p_h_person_last_name;
   q_header_rec.person_middle_name := p_h_person_middle_name;
   IF p_h_phone_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.phone_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.phone_id := p_h_phone_id;
   END IF;
   IF p_h_price_list_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.price_list_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.price_list_id := p_h_price_list_id;
   END IF;

   q_header_rec.pricing_status_indicator := p_h_pricing_status_indicator;  -- change line logic pricing
   q_header_rec.tax_status_indicator := p_h_tax_status_indicator;

   q_header_rec.price_list_name := p_h_price_list_name;
   q_header_rec.currency_code := p_h_currency_code;
   IF p_h_total_list_price = ROSETTA_G_MISS_NUM THEN
      q_header_rec.total_list_price := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.total_list_price := p_h_total_list_price;
   END IF;
   IF p_h_total_adjusted_amount = ROSETTA_G_MISS_NUM THEN
      q_header_rec.total_adjusted_amount := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.total_adjusted_amount := p_h_total_adjusted_amount;
   END IF;
   IF p_h_total_adjusted_percent = ROSETTA_G_MISS_NUM THEN
      q_header_rec.total_adjusted_percent := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.total_adjusted_percent := p_h_total_adjusted_percent;
   END IF;
   IF p_h_total_tax = ROSETTA_G_MISS_NUM THEN
      q_header_rec.total_tax := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.total_tax := p_h_total_tax;
   END IF;
   IF p_h_total_shipping_charge = ROSETTA_G_MISS_NUM THEN
      q_header_rec.total_shipping_charge := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.total_shipping_charge := p_h_total_shipping_charge;
   END IF;
   IF p_h_surcharge = ROSETTA_G_MISS_NUM THEN
      q_header_rec.surcharge := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.surcharge := p_h_surcharge;
   END IF;
   IF p_h_total_quote_price = ROSETTA_G_MISS_NUM THEN
      q_header_rec.total_quote_price := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.total_quote_price := p_h_total_quote_price;
   END IF;
   IF p_h_payment_amount = ROSETTA_G_MISS_NUM THEN
      q_header_rec.payment_amount := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.payment_amount := p_h_payment_amount;
   END IF;
   IF p_h_accounting_rule_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.accounting_rule_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.accounting_rule_id := p_h_accounting_rule_id;
   END IF;
   IF p_h_exchange_rate = ROSETTA_G_MISS_NUM THEN
      q_header_rec.exchange_rate := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.exchange_rate := p_h_exchange_rate;
   END IF;
   q_header_rec.exchange_type_code := p_h_exchange_type_code;
   IF p_h_exchange_rate_date = ROSETTA_G_MISTAKE_DATE THEN
      q_header_rec.exchange_rate_date := FND_API.G_MISS_DATE;
   ELSE
      q_header_rec.exchange_rate_date := p_h_exchange_rate_date;
   END IF;
   q_header_rec.quote_category_code := p_h_quote_category_code;
   q_header_rec.quote_status_code := p_h_quote_status_code;
   q_header_rec.quote_status := p_h_quote_status;
   IF p_h_employee_person_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.employee_person_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.employee_person_id := p_h_employee_person_id;
   END IF;
   q_header_rec.sales_channel_code := p_h_sales_channel_code;
--   q_header_rec.salesrep_full_name := p_h_salesrep_full_name;
   q_header_rec.attribute_category := p_h_attribute_category;
   q_header_rec.attribute1 := p_h_attribute1;
   q_header_rec.attribute10 := p_h_attribute10;
   q_header_rec.attribute11 := p_h_attribute11;
   q_header_rec.attribute12 := p_h_attribute12;
   q_header_rec.attribute13 := p_h_attribute13;
   q_header_rec.attribute14 := p_h_attribute14;
   q_header_rec.attribute15 := p_h_attribute15;
   q_header_rec.attribute2 := p_h_attribute2;
   q_header_rec.attribute3 := p_h_attribute3;
   q_header_rec.attribute4 := p_h_attribute4;
   q_header_rec.attribute5 := p_h_attribute5;
   q_header_rec.attribute6 := p_h_attribute6;
   q_header_rec.attribute7 := p_h_attribute7;
   q_header_rec.attribute8 := p_h_attribute8;
   q_header_rec.attribute9 := p_h_attribute9;
   IF p_h_contract_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.contract_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.contract_id := p_h_contract_id;
   END IF;
   IF p_h_qte_contract_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.qte_contract_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.qte_contract_id := p_h_qte_contract_id;
   END IF;
   IF p_h_ffm_request_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.ffm_request_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.ffm_request_id := p_h_ffm_request_id;
   END IF;
   q_header_rec.invoice_to_address1 := p_h_invoice_to_address1;
   q_header_rec.invoice_to_address2 := p_h_invoice_to_address2;
   q_header_rec.invoice_to_address3 := p_h_invoice_to_address3;
   q_header_rec.invoice_to_address4 := p_h_invoice_to_address4;
   q_header_rec.invoice_to_city := p_h_invoice_to_city;
   q_header_rec.invoice_to_contact_first_name := p_h_invoice_to_cont_first_name;
   q_header_rec.invoice_to_contact_last_name := p_h_invoice_to_cont_last_name;
   q_header_rec.invoice_to_contact_middle_name := p_h_invoice_to_cont_mid_name;
   q_header_rec.invoice_to_country_code := p_h_invoice_to_country_code;
   q_header_rec.invoice_to_country := p_h_invoice_to_country;
   q_header_rec.invoice_to_county := p_h_invoice_to_county;
   IF p_h_invoice_to_party_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.invoice_to_party_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.invoice_to_party_id := p_h_invoice_to_party_id;
   END IF;
   q_header_rec.invoice_to_party_name := p_h_invoice_to_party_name;
   IF p_h_invoice_to_party_site_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.invoice_to_party_site_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.invoice_to_party_site_id := p_h_invoice_to_party_site_id;
   END IF;
   q_header_rec.invoice_to_postal_code := p_h_invoice_to_postal_code;
   q_header_rec.invoice_to_province := p_h_invoice_to_province;
   q_header_rec.invoice_to_state := p_h_invoice_to_state;
   IF p_h_invoicing_rule_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.invoicing_rule_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.invoicing_rule_id := p_h_invoicing_rule_id;
   END IF;
   IF p_h_marketing_source_code_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.marketing_source_code_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.marketing_source_code_id := p_h_marketing_source_code_id;
   END IF;
   q_header_rec.marketing_source_code := p_h_marketing_source_code;
   q_header_rec.marketing_source_name := p_h_marketing_source_name;
   IF p_h_orig_mktg_source_code_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.orig_mktg_source_code_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.orig_mktg_source_code_id := p_h_orig_mktg_source_code_id;
   END IF;
   IF p_h_order_type_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.order_type_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.order_type_id := p_h_order_type_id;
   END IF;
   IF p_h_order_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.order_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.order_id := p_h_order_id;
   END IF;
   IF p_h_order_number = ROSETTA_G_MISS_NUM THEN
      q_header_rec.order_number := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.order_number := p_h_order_number;
   END IF;
   q_header_rec.order_type_name := p_h_order_type_name;
   IF p_h_ordered_date = ROSETTA_G_MISTAKE_DATE THEN
      q_header_rec.ordered_date := FND_API.G_MISS_DATE;
   ELSE
      q_header_rec.ordered_date := p_h_ordered_date;
   END IF;
   IF p_h_resource_id = ROSETTA_G_MISS_NUM THEN
      q_header_rec.resource_id := FND_API.G_MISS_NUM;
   ELSE
      q_header_rec.resource_id := p_h_resource_id;
   END IF;

   RETURN q_header_rec;
END Construct_Quote_Header_Rec;

FUNCTION Construct_SL_Header_Rec(
   p_h_shp_list_id               IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_request_id                IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_application_id    IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_id                IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_update_date       IN  DATE     := FND_API.G_MISS_DATE,
   p_h_object_version_number     IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_created_by                IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_creation_date             IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_updated_by           IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_last_update_date          IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_update_login         IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_party_id                  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_cust_account_id           IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_shopping_list_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_description               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute_category        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute1                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute2                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute3                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute4                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute5                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute6                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute7                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute8                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute9                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute10               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute11               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute12               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute13               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute14               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute15               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_org_id                    IN  NUMBER   := FND_API.G_MISS_NUM
) RETURN IBE_Shop_List_PVT.SL_Header_Rec_Type
IS
   sl_header_rec IBE_Shop_List_PVT.SL_Header_Rec_Type;
BEGIN
   IF p_h_shp_list_id = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.shp_list_id := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.shp_list_id := p_h_shp_list_id;
   END IF;
   IF p_h_request_id = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.request_id := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.request_id := p_h_request_id;
   END IF;
   IF p_h_program_application_id = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.program_application_id := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.program_application_id := p_h_program_application_id;
   END IF;
   IF p_h_program_id = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.program_id := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.program_id := p_h_program_id;
   END IF;
   IF p_h_program_update_date = ROSETTA_G_MISTAKE_DATE THEN
      sl_header_rec.program_update_date := FND_API.G_MISS_DATE;
   ELSE
      sl_header_rec.program_update_date := p_h_program_update_date;
   END IF;
   IF p_h_object_version_number = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.object_version_number := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.object_version_number := p_h_object_version_number;
   END IF;
   IF p_h_created_by = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.created_by := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.created_by := p_h_created_by;
   END IF;
   IF p_h_creation_date = ROSETTA_G_MISTAKE_DATE THEN
      sl_header_rec.creation_date := FND_API.G_MISS_DATE;
   ELSE
      sl_header_rec.creation_date := p_h_creation_date;
   END IF;
   IF p_h_last_updated_by = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.last_updated_by := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.last_updated_by := p_h_last_updated_by;
   END IF;
   IF p_h_last_update_date = ROSETTA_G_MISTAKE_DATE THEN
      sl_header_rec.last_update_date := FND_API.G_MISS_DATE;
   ELSE
      sl_header_rec.last_update_date := p_h_last_update_date;
   END IF;
   IF p_h_last_update_login = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.last_update_login := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.last_update_login := p_h_last_update_login;
   END IF;
   IF p_h_party_id = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.party_id := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.party_id := p_h_party_id;
   END IF;
   IF p_h_cust_account_id = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.cust_account_id := p_h_cust_account_id;
   END IF;
   sl_header_rec.shopping_list_name := p_h_shopping_list_name;
   sl_header_rec.description := p_h_description;
   sl_header_rec.attribute_category := p_h_attribute_category;
   sl_header_rec.attribute1 := p_h_attribute1;
   sl_header_rec.attribute2 := p_h_attribute2;
   sl_header_rec.attribute3 := p_h_attribute3;
   sl_header_rec.attribute4 := p_h_attribute4;
   sl_header_rec.attribute5 := p_h_attribute5;
   sl_header_rec.attribute6 := p_h_attribute6;
   sl_header_rec.attribute7 := p_h_attribute7;
   sl_header_rec.attribute8 := p_h_attribute8;
   sl_header_rec.attribute9 := p_h_attribute9;
   sl_header_rec.attribute10 := p_h_attribute10;
   sl_header_rec.attribute11 := p_h_attribute11;
   sl_header_rec.attribute12 := p_h_attribute12;
   sl_header_rec.attribute13 := p_h_attribute13;
   sl_header_rec.attribute14 := p_h_attribute14;
   sl_header_rec.attribute15 := p_h_attribute15;
   IF p_h_org_id = ROSETTA_G_MISS_NUM THEN
      sl_header_rec.org_id := FND_API.G_MISS_NUM;
   ELSE
      sl_header_rec.org_id := p_h_org_id;
   END IF;

   RETURN sl_header_rec;
END Construct_SL_Header_Rec;


FUNCTION Construct_SL_Line_Tbl(
   p_l_shp_list_item_id          IN  jtf_number_table       := NULL,
   p_l_object_version_number     IN  jtf_number_table       := NULL,
   p_l_creation_date             IN  jtf_date_table         := NULL,
   p_l_created_by                IN  jtf_number_table       := NULL,
   p_l_last_updated_by           IN  jtf_number_table       := NULL,
   p_l_last_update_date          IN  jtf_date_table         := NULL,
   p_l_last_update_login         IN  jtf_number_table       := NULL,
   p_l_request_id                IN  jtf_number_table       := NULL,
   p_l_program_id                IN  jtf_number_table       := NULL,
   p_l_program_application_id    IN  jtf_number_table       := NULL,
   p_l_program_update_date       IN  jtf_date_table         := NULL,
   p_l_shp_list_id               IN  jtf_number_table       := NULL,
   p_l_inventory_item_id         IN  jtf_number_table       := NULL,
   p_l_organization_id           IN  jtf_number_table       := NULL,
   p_l_uom_code                  IN  jtf_varchar2_table_100 := NULL,
   p_l_quantity                  IN  jtf_number_table       := NULL,
   p_l_config_header_id          IN  jtf_number_table       := NULL,
   p_l_config_revision_num       IN  jtf_number_table       := NULL,
   p_l_complete_config_flag      IN  jtf_varchar2_table_100 := NULL,
   p_l_valid_configuration_flag  IN  jtf_varchar2_table_100 := NULL,
   p_l_item_type_code            IN  jtf_varchar2_table_100 := NULL,
   p_l_attribute_category        IN  jtf_varchar2_table_100 := NULL,
   p_l_attribute1                IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute2                IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute3                IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute4                IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute5                IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute6                IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute7                IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute8                IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute9                IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute10               IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute11               IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute12               IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute13               IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute14               IN  jtf_varchar2_table_200 := NULL,
   p_l_attribute15               IN  jtf_varchar2_table_200 := NULL,
   p_l_org_id                    IN  jtf_number_table       := NULL
) RETURN IBE_Shop_List_PVT.SL_Line_Tbl_Type
IS
   sl_line_tbl  IBE_Shop_List_PVT.SL_Line_Tbl_Type
                   := IBE_Shop_List_PVT.G_MISS_SL_LINE_TBL;
   l_table_size PLS_INTEGER;
   i            PLS_INTEGER;
BEGIN
   IF p_l_shp_list_item_id IS NOT NULL AND p_l_shp_list_item_id.COUNT > 0 THEN
      l_table_size := p_l_shp_list_item_id.COUNT;

      FOR i IN 1..l_table_size LOOP
         IF p_l_shp_list_item_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).shp_list_item_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).shp_list_item_id := p_l_shp_list_item_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_object_version_number(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).object_version_number := p_l_object_version_number(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_creation_date(i) = ROSETTA_G_MISTAKE_DATE THEN
            sl_line_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            sl_line_tbl(i).creation_date := p_l_creation_date(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_created_by(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).created_by := p_l_created_by(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_last_updated_by(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).last_updated_by := p_l_last_updated_by(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_last_update_date(i) = ROSETTA_G_MISTAKE_DATE THEN
            sl_line_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            sl_line_tbl(i).last_update_date := p_l_last_update_date(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_last_update_login(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).last_update_login := p_l_last_update_login(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_request_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).request_id := p_l_request_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_program_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).program_id := p_l_program_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_program_application_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).program_application_id := p_l_program_application_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_program_update_date(i) = ROSETTA_G_MISTAKE_DATE THEN
            sl_line_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            sl_line_tbl(i).program_update_date := p_l_program_update_date(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_shp_list_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).shp_list_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).shp_list_id := p_l_shp_list_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_inventory_item_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).inventory_item_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).inventory_item_id := p_l_inventory_item_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_organization_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).organization_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).organization_id := p_l_organization_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).uom_code := p_l_uom_code(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_quantity(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).quantity := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).quantity := p_l_quantity(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_config_header_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).config_header_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).config_header_id := p_l_config_header_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_config_revision_num(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).config_revision_num := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).config_revision_num := p_l_config_revision_num(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).complete_configuration_flag := p_l_complete_config_flag(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).valid_configuration_flag := p_l_valid_configuration_flag(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).item_type_code := p_l_item_type_code(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute_category := p_l_attribute_category(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute1 := p_l_attribute1(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute2 := p_l_attribute2(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute3 := p_l_attribute3(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute4 := p_l_attribute4(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute5 := p_l_attribute5(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute6 := p_l_attribute6(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute7 := p_l_attribute7(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute8 := p_l_attribute8(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute9 := p_l_attribute9(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute10 := p_l_attribute10(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute11 := p_l_attribute11(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute12 := p_l_attribute12(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute13 := p_l_attribute13(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute14 := p_l_attribute14(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_tbl(i).attribute15 := p_l_attribute15(i);
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_l_org_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_tbl(i).org_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_tbl(i).org_id := p_l_org_id(i);
         END IF;
      END LOOP;
   END IF;

   RETURN sl_line_tbl;
END Construct_SL_Line_Tbl;


FUNCTION Construct_SL_Line_Rel_Tbl(
   p_lr_shlitem_rel_id           IN  jtf_number_table       := NULL,
   p_lr_request_id               IN  jtf_number_table       := NULL,
   p_lr_program_application_id   IN  jtf_number_table       := NULL,
   p_lr_program_id               IN  jtf_number_table       := NULL,
   p_lr_program_update_date      IN  jtf_date_table         := NULL,
   p_lr_object_version_number    IN  jtf_number_table       := NULL,
   p_lr_created_by               IN  jtf_number_table       := NULL,
   p_lr_creation_date            IN  jtf_date_table         := NULL,
   p_lr_last_updated_by          IN  jtf_number_table       := NULL,
   p_lr_last_update_date         IN  jtf_date_table         := NULL,
   p_lr_last_update_login        IN  jtf_number_table       := NULL,
   p_lr_shp_list_item_id         IN  jtf_number_table       := NULL,
   p_lr_line_index               IN  jtf_number_table       := NULL,
   p_lr_related_shp_list_item_id IN  jtf_number_table       := NULL,
   p_lr_related_line_index       IN  jtf_number_table       := NULL,
   p_lr_relationship_type_code   IN  jtf_varchar2_table_100 := NULL
) RETURN IBE_Shop_List_PVT.SL_Line_Rel_Tbl_Type
IS
   sl_line_rel_tbl IBE_Shop_List_PVT.SL_Line_Rel_Tbl_Type
                      := IBE_Shop_List_PVT.G_MISS_SL_LINE_REL_TBL;
   l_table_size    PLS_INTEGER;
   i               PLS_INTEGER;
BEGIN
   IF p_lr_shlitem_rel_id IS NOT NULL AND p_lr_shlitem_rel_id.COUNT > 0 THEN
      l_table_size := p_lr_shlitem_rel_id.COUNT;

      FOR i IN 1..l_table_size LOOP
         IF p_lr_shlitem_rel_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).shlitem_rel_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).shlitem_rel_id := p_lr_shlitem_rel_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_request_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).request_id := p_lr_request_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_program_application_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).program_application_id := p_lr_program_application_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_program_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).program_id := p_lr_program_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_program_update_date(i) = ROSETTA_G_MISTAKE_DATE THEN
            sl_line_rel_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            sl_line_rel_tbl(i).program_update_date := p_lr_program_update_date(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_object_version_number(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).object_version_number := p_lr_object_version_number(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_created_by(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).created_by := p_lr_created_by(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_creation_date(i) = ROSETTA_G_MISTAKE_DATE THEN
            sl_line_rel_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            sl_line_rel_tbl(i).creation_date := p_lr_creation_date(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_last_updated_by(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).last_updated_by := p_lr_last_updated_by(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_last_update_date(i) = ROSETTA_G_MISTAKE_DATE THEN
            sl_line_rel_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            sl_line_rel_tbl(i).last_update_date := p_lr_last_update_date(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_last_update_login(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).last_update_login := p_lr_last_update_login(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_shp_list_item_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).shp_list_item_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).shp_list_item_id := p_lr_shp_list_item_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_line_index(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).line_index := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).line_index := p_lr_line_index(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_related_shp_list_item_id(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).related_shp_list_item_id := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).related_shp_list_item_id := p_lr_related_shp_list_item_id(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         IF p_lr_related_line_index(i) = ROSETTA_G_MISS_NUM THEN
            sl_line_rel_tbl(i).related_line_index := FND_API.G_MISS_NUM;
         ELSE
            sl_line_rel_tbl(i).related_line_index := p_lr_related_line_index(i);
         END IF;
      END LOOP;
      FOR i IN 1..l_table_size LOOP
         sl_line_rel_tbl(i).relationship_type_code := p_lr_relationship_type_code(i);
      END LOOP;
   END IF;

   RETURN sl_line_rel_tbl;
END Construct_SL_Line_Rel_Tbl;


PROCEDURE Save(
   p_api_version                 IN  NUMBER   := 1                  ,
   p_init_msg_list               IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                      IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status               OUT NOCOPY VARCHAR2                       ,
   x_msg_count                   OUT NOCOPY NUMBER                         ,
   x_msg_data                    OUT NOCOPY VARCHAR2                       ,
   p_combine_same_item           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_shp_list_id               IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_request_id                IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_application_id    IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_id                IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_update_date       IN  DATE     := FND_API.G_MISS_DATE,
   p_h_object_version_number     IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_created_by                IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_creation_date             IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_updated_by           IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_last_update_date          IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_update_login         IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_party_id                  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_cust_account_id           IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_shopping_list_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_description               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute_category        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute1                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute2                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute3                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute4                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute5                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute6                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute7                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute8                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute9                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute10               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute11               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute12               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute13               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute14               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute15               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_org_id                    IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_l_shp_list_item_id          IN  jtf_number_table       := NULL ,
   p_l_object_version_number     IN  jtf_number_table       := NULL ,
   p_l_creation_date             IN  jtf_date_table         := NULL ,
   p_l_created_by                IN  jtf_number_table       := NULL ,
   p_l_last_updated_by           IN  jtf_number_table       := NULL ,
   p_l_last_update_date          IN  jtf_date_table         := NULL ,
   p_l_last_update_login         IN  jtf_number_table       := NULL ,
   p_l_request_id                IN  jtf_number_table       := NULL ,
   p_l_program_id                IN  jtf_number_table       := NULL ,
   p_l_program_application_id    IN  jtf_number_table       := NULL ,
   p_l_program_update_date       IN  jtf_date_table         := NULL ,
   p_l_shp_list_id               IN  jtf_number_table       := NULL ,
   p_l_inventory_item_id         IN  jtf_number_table       := NULL ,
   p_l_organization_id           IN  jtf_number_table       := NULL ,
   p_l_uom_code                  IN  jtf_varchar2_table_100 := NULL ,
   p_l_quantity                  IN  jtf_number_table       := NULL ,
   p_l_config_header_id          IN  jtf_number_table       := NULL ,
   p_l_config_revision_num       IN  jtf_number_table       := NULL ,
   p_l_complete_config_flag      IN  jtf_varchar2_table_100 := NULL ,
   p_l_valid_configuration_flag  IN  jtf_varchar2_table_100 := NULL ,
   p_l_item_type_code            IN  jtf_varchar2_table_100 := NULL ,
   p_l_attribute_category        IN  jtf_varchar2_table_100 := NULL ,
   p_l_attribute1                IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute2                IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute3                IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute4                IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute5                IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute6                IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute7                IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute8                IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute9                IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute10               IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute11               IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute12               IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute13               IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute14               IN  jtf_varchar2_table_200 := NULL ,
   p_l_attribute15               IN  jtf_varchar2_table_200 := NULL ,
   p_l_org_id                    IN  jtf_number_table       := NULL ,
   p_lr_shlitem_rel_id           IN  jtf_number_table       := NULL ,
   p_lr_request_id               IN  jtf_number_table       := NULL ,
   p_lr_program_application_id   IN  jtf_number_table       := NULL ,
   p_lr_program_id               IN  jtf_number_table       := NULL ,
   p_lr_program_update_date      IN  jtf_date_table         := NULL ,
   p_lr_object_version_number    IN  jtf_number_table       := NULL ,
   p_lr_created_by               IN  jtf_number_table       := NULL ,
   p_lr_creation_date            IN  jtf_date_table         := NULL ,
   p_lr_last_updated_by          IN  jtf_number_table       := NULL ,
   p_lr_last_update_date         IN  jtf_date_table         := NULL ,
   p_lr_last_update_login        IN  jtf_number_table       := NULL ,
   p_lr_shp_list_item_id         IN  jtf_number_table       := NULL ,
   p_lr_line_index               IN  jtf_number_table       := NULL ,
   p_lr_related_shp_list_item_id IN  jtf_number_table       := NULL ,
   p_lr_related_line_index       IN  jtf_number_table       := NULL ,
   p_lr_relationship_type_code   IN  jtf_varchar2_table_100 := NULL ,
   x_sl_header_id                OUT NOCOPY NUMBER
)
IS
   l_sl_header_rec   IBE_Shop_List_PVT.SL_Header_Rec_Type;
   l_sl_line_tbl     IBE_Shop_List_PVT.SL_Line_Tbl_Type;
   l_sl_line_rel_tbl IBE_Shop_List_PVT.SL_Line_Rel_Tbl_Type;
BEGIN

   l_sl_header_rec := Construct_SL_Header_Rec(
      p_h_shp_list_id            => p_h_shp_list_id,
      p_h_request_id             => p_h_request_id,
      p_h_program_application_id => p_h_program_application_id,
      p_h_program_id             => p_h_program_id,
      p_h_program_update_date    => p_h_program_update_date,
      p_h_object_version_number  => p_h_object_version_number,
      p_h_created_by             => p_h_created_by,
      p_h_creation_date          => p_h_creation_date,
      p_h_last_updated_by        => p_h_last_updated_by,
      p_h_last_update_date       => p_h_last_update_date,
      p_h_last_update_login      => p_h_last_update_login,
      p_h_party_id               => p_h_party_id,
      p_h_cust_account_id        => p_h_cust_account_id,
      p_h_shopping_list_name     => p_h_shopping_list_name,
      p_h_description            => p_h_description,
      p_h_attribute_category     => p_h_attribute_category,
      p_h_attribute1             => p_h_attribute1,
      p_h_attribute2             => p_h_attribute2,
      p_h_attribute3             => p_h_attribute3,
      p_h_attribute4             => p_h_attribute4,
      p_h_attribute5             => p_h_attribute5,
      p_h_attribute6             => p_h_attribute6,
      p_h_attribute7             => p_h_attribute7,
      p_h_attribute8             => p_h_attribute8,
      p_h_attribute9             => p_h_attribute9,
      p_h_attribute10            => p_h_attribute10,
      p_h_attribute11            => p_h_attribute11,
      p_h_attribute12            => p_h_attribute11,
      p_h_attribute13            => p_h_attribute13,
      p_h_attribute14            => p_h_attribute14,
      p_h_attribute15            => p_h_attribute15,
      p_h_org_id                 => p_h_org_id);

   l_sl_line_tbl := Construct_SL_Line_Tbl(
      p_l_shp_list_item_id         => p_l_shp_list_item_id        ,
      p_l_object_version_number    => p_l_object_version_number   ,
      p_l_creation_date            => p_l_creation_date           ,
      p_l_created_by               => p_l_created_by              ,
      p_l_last_updated_by          => p_l_last_updated_by         ,
      p_l_last_update_date         => p_l_last_update_date        ,
      p_l_last_update_login        => p_l_last_update_login       ,
      p_l_request_id               => p_l_request_id              ,
      p_l_program_id               => p_l_program_id              ,
      p_l_program_application_id   => p_l_program_application_id  ,
      p_l_program_update_date      => p_l_program_update_date     ,
      p_l_shp_list_id              => p_l_shp_list_id             ,
      p_l_inventory_item_id        => p_l_inventory_item_id       ,
      p_l_organization_id          => p_l_organization_id         ,
      p_l_uom_code                 => p_l_uom_code                ,
      p_l_quantity                 => p_l_quantity                ,
      p_l_config_header_id         => p_l_config_header_id        ,
      p_l_config_revision_num      => p_l_config_revision_num     ,
      p_l_complete_config_flag     => p_l_complete_config_flag    ,
      p_l_valid_configuration_flag => p_l_valid_configuration_flag,
      p_l_item_type_code           => p_l_item_type_code          ,
      p_l_attribute_category       => p_l_attribute_category      ,
      p_l_attribute1               => p_l_attribute1              ,
      p_l_attribute2               => p_l_attribute2              ,
      p_l_attribute3               => p_l_attribute3              ,
      p_l_attribute4               => p_l_attribute4              ,
      p_l_attribute5               => p_l_attribute5              ,
      p_l_attribute6               => p_l_attribute6              ,
      p_l_attribute7               => p_l_attribute7              ,
      p_l_attribute8               => p_l_attribute8              ,
      p_l_attribute9               => p_l_attribute9              ,
      p_l_attribute10              => p_l_attribute10             ,
      p_l_attribute11              => p_l_attribute11             ,
      p_l_attribute12              => p_l_attribute12             ,
      p_l_attribute13              => p_l_attribute13             ,
      p_l_attribute14              => p_l_attribute14             ,
      p_l_attribute15              => p_l_attribute15             ,
      p_l_org_id                   => p_l_org_id);

   l_sl_line_rel_tbl := Construct_SL_Line_Rel_Tbl(
      p_lr_shlitem_rel_id           => p_lr_shlitem_rel_id          ,
      p_lr_request_id               => p_lr_request_id              ,
      p_lr_program_application_id   => p_lr_program_application_id  ,
      p_lr_program_id               => p_lr_program_id              ,
      p_lr_program_update_date      => p_lr_program_update_date     ,
      p_lr_object_version_number    => p_lr_object_version_number   ,
      p_lr_created_by               => p_lr_created_by              ,
      p_lr_creation_date            => p_lr_creation_date           ,
      p_lr_last_updated_by          => p_lr_last_updated_by         ,
      p_lr_last_update_date         => p_lr_last_update_date        ,
      p_lr_last_update_login        => p_lr_last_update_login       ,
      p_lr_shp_list_item_id         => p_lr_shp_list_item_id        ,
      p_lr_line_index               => p_lr_line_index              ,
      p_lr_related_shp_list_item_id => p_lr_related_shp_list_item_id,
      p_lr_related_line_index       => p_lr_related_line_index      ,
      p_lr_relationship_type_code   => p_lr_relationship_type_code);

   IBE_Shop_List_PVT.Save(
      p_api_version       => p_api_version      ,
      p_init_msg_list     => p_init_msg_list    ,
      p_commit            => p_commit           ,
      x_return_status     => x_return_status    ,
      x_msg_count         => x_msg_count        ,
      x_msg_data          => x_msg_data         ,
      p_combine_same_item => p_combine_same_item,
      p_sl_header_rec     => l_sl_header_rec    ,
      p_sl_line_tbl       => l_sl_line_tbl      ,
      p_sl_line_rel_tbl   => l_sl_line_rel_tbl  ,
      x_sl_header_id      => x_sl_header_id);
END Save;


PROCEDURE Save_List_From_Items(
   p_api_version              IN  NUMBER   := 1                  ,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status            OUT NOCOPY VARCHAR2                       ,
   x_msg_count                OUT NOCOPY NUMBER                         ,
   x_msg_data                 OUT NOCOPY VARCHAR2                       ,
   p_sl_line_ids              IN  jtf_number_table               ,
   p_sl_line_ovns             IN  jtf_number_table := NULL       ,
   p_mode                     IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_shp_list_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_request_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_application_id IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_update_date    IN  DATE     := FND_API.G_MISS_DATE,
   p_h_object_version_number  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_created_by             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_creation_date          IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_updated_by        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_last_update_date       IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_update_login      IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_party_id               IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_cust_account_id        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_shopping_list_name     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_description            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute_category     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute1             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute2             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute3             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute4             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute5             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute6             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute7             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute8             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute9             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute10            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute11            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute12            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute13            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute14            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute15            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_org_id                 IN  NUMBER   := FND_API.G_MISS_NUM ,
   x_sl_header_id             OUT NOCOPY NUMBER
)
IS
   l_sl_header_rec   IBE_Shop_List_PVT.SL_Header_Rec_Type;
BEGIN
   l_sl_header_rec := Construct_SL_Header_Rec(
      p_h_shp_list_id            => p_h_shp_list_id,
      p_h_request_id             => p_h_request_id,
      p_h_program_application_id => p_h_program_application_id,
      p_h_program_id             => p_h_program_id,
      p_h_program_update_date    => p_h_program_update_date,
      p_h_object_version_number  => p_h_object_version_number,
      p_h_created_by             => p_h_created_by,
      p_h_creation_date          => p_h_creation_date,
      p_h_last_updated_by        => p_h_last_updated_by,
      p_h_last_update_date       => p_h_last_update_date,
      p_h_last_update_login      => p_h_last_update_login,
      p_h_party_id               => p_h_party_id,
      p_h_cust_account_id        => p_h_cust_account_id,
      p_h_shopping_list_name     => p_h_shopping_list_name,
      p_h_description            => p_h_description,
      p_h_attribute_category     => p_h_attribute_category,
      p_h_attribute1             => p_h_attribute1,
      p_h_attribute2             => p_h_attribute2,
      p_h_attribute3             => p_h_attribute3,
      p_h_attribute4             => p_h_attribute4,
      p_h_attribute5             => p_h_attribute5,
      p_h_attribute6             => p_h_attribute6,
      p_h_attribute7             => p_h_attribute7,
      p_h_attribute8             => p_h_attribute8,
      p_h_attribute9             => p_h_attribute9,
      p_h_attribute10            => p_h_attribute10,
      p_h_attribute11            => p_h_attribute11,
      p_h_attribute12            => p_h_attribute11,
      p_h_attribute13            => p_h_attribute13,
      p_h_attribute14            => p_h_attribute14,
      p_h_attribute15            => p_h_attribute15,
      p_h_org_id                 => p_h_org_id);

   IBE_Shop_List_PVT.Save_List_From_Items(
      p_api_version       => p_api_version      ,
      p_init_msg_list     => p_init_msg_list    ,
      p_commit            => p_commit           ,
      x_return_status     => x_return_status    ,
      x_msg_count         => x_msg_count        ,
      x_msg_data          => x_msg_data         ,
      p_sl_line_ids       => p_sl_line_ids      ,
      p_sl_line_ovns      => p_sl_line_ovns     ,
      p_mode              => p_mode             ,
      p_combine_same_item => p_combine_same_item,
      p_sl_header_rec     => l_sl_header_rec    ,
      x_sl_header_id      => x_sl_header_id);
END Save_List_From_Items;


PROCEDURE Save_List_From_Quote(
   p_api_version              IN  NUMBER   := 1                  ,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status            OUT NOCOPY VARCHAR2                       ,
   x_msg_count                OUT NOCOPY NUMBER                         ,
   x_msg_data                 OUT NOCOPY VARCHAR2                       ,
   p_quote_header_id          IN  NUMBER                         ,
   p_quote_retrieval_number   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_minisite_id              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_last_update_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_mode                     IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_shp_list_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_request_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_application_id IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_update_date    IN  DATE     := FND_API.G_MISS_DATE,
   p_h_object_version_number  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_created_by             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_creation_date          IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_updated_by        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_last_update_date       IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_update_login      IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_party_id               IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_cust_account_id        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_shopping_list_name     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_description            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute_category     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute1             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute2             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute3             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute4             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute5             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute6             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute7             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute8             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute9             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute10            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute11            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute12            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute13            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute14            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute15            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_org_id                 IN  NUMBER   := FND_API.G_MISS_NUM ,
   x_sl_header_id             OUT NOCOPY NUMBER
)
IS
   l_sl_header_rec   IBE_Shop_List_PVT.SL_Header_Rec_Type;
BEGIN
   l_sl_header_rec := Construct_SL_Header_Rec(
      p_h_shp_list_id            => p_h_shp_list_id,
      p_h_request_id             => p_h_request_id,
      p_h_program_application_id => p_h_program_application_id,
      p_h_program_id             => p_h_program_id,
      p_h_program_update_date    => p_h_program_update_date,
      p_h_object_version_number  => p_h_object_version_number,
      p_h_created_by             => p_h_created_by,
      p_h_creation_date          => p_h_creation_date,
      p_h_last_updated_by        => p_h_last_updated_by,
      p_h_last_update_date       => p_h_last_update_date,
      p_h_last_update_login      => p_h_last_update_login,
      p_h_party_id               => p_h_party_id,
      p_h_cust_account_id        => p_h_cust_account_id,
      p_h_shopping_list_name     => p_h_shopping_list_name,
      p_h_description            => p_h_description,
      p_h_attribute_category     => p_h_attribute_category,
      p_h_attribute1             => p_h_attribute1,
      p_h_attribute2             => p_h_attribute2,
      p_h_attribute3             => p_h_attribute3,
      p_h_attribute4             => p_h_attribute4,
      p_h_attribute5             => p_h_attribute5,
      p_h_attribute6             => p_h_attribute6,
      p_h_attribute7             => p_h_attribute7,
      p_h_attribute8             => p_h_attribute8,
      p_h_attribute9             => p_h_attribute9,
      p_h_attribute10            => p_h_attribute10,
      p_h_attribute11            => p_h_attribute11,
      p_h_attribute12            => p_h_attribute11,
      p_h_attribute13            => p_h_attribute13,
      p_h_attribute14            => p_h_attribute14,
      p_h_attribute15            => p_h_attribute15,
      p_h_org_id                 => p_h_org_id);

   IBE_Shop_List_PVT.Save_List_From_Quote(
      p_api_version            => p_api_version           ,
      p_init_msg_list          => p_init_msg_list         ,
      p_commit                 => p_commit                ,
      x_return_status          => x_return_status         ,
      x_msg_count              => x_msg_count             ,
      x_msg_data               => x_msg_data              ,
      p_quote_header_id        => p_quote_header_id       ,
      p_quote_retrieval_number => p_quote_retrieval_number,
      p_minisite_id            => p_minisite_id           ,
      p_last_update_date       => p_last_update_date      ,
      p_mode                   => p_mode                  ,
      p_sl_header_rec          => l_sl_header_rec         ,
      p_combine_same_item      => p_combine_same_item     ,
      x_sl_header_id           => x_sl_header_id);
END Save_List_From_Quote;


PROCEDURE Save_Quote_From_List_Items(
   p_api_version                  IN  NUMBER   := 1                  ,
   p_init_msg_list                IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                       IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status                OUT NOCOPY VARCHAR2                       ,
   x_msg_count                    OUT NOCOPY NUMBER                         ,
   x_msg_data                     OUT NOCOPY VARCHAR2                       ,
   p_sl_line_ids                  IN  jtf_number_table               ,
   p_sl_line_ovns                 IN  jtf_number_table := NULL       ,
   p_quote_retrieval_number       IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_recipient_party_id           IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_recipient_cust_account_id    IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_minisite_id                  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_mode                         IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_last_update_date           IN  DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_price_mode		  IN  VARCHAR2 := 'ENTIRE_QUOTE'     ,	-- change line logic pricing
   p_h_quote_header_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_creation_date              IN  DATE     := FND_API.G_MISS_DATE,
   p_h_created_by                 IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_last_updated_by            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_last_update_date           IN  DATE     := FND_API.G_MISS_DATE,
   p_h_last_update_login          IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_request_id                 IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_application_id     IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_id                 IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_program_update_date        IN  DATE     := FND_API.G_MISS_DATE,
   p_h_org_id                     IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_quote_name                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_quote_number               IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_quote_version              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_quote_status_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_quote_source_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_quote_expiration_date      IN  DATE     := FND_API.G_MISS_DATE,
   p_h_price_frozen_date          IN  DATE     := FND_API.G_MISS_DATE,
   p_h_quote_password             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_original_system_reference  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_party_id                   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_cust_account_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_org_contact_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_party_name                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_party_type                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_person_first_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_person_last_name           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_person_middle_name         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_phone_id                   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_price_list_id              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_pricing_status_indicator   IN  VARCHAR2 := FND_API.G_MISS_CHAR,	-- change line logic pricing
   p_h_tax_status_indicator   	  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_price_list_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_currency_code              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_total_list_price           IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_adjusted_amount      IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_adjusted_percent     IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_tax                  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_shipping_charge      IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_surcharge                  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_total_quote_price          IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_payment_amount             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_accounting_rule_id         IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_exchange_rate              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_exchange_type_code         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_exchange_rate_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_h_quote_category_code        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_quote_status_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_quote_status               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_employee_person_id         IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_sales_channel_code         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
--   p_h_salesrep_full_name         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute_category         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute1                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute10                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute11                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute12                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute13                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute14                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute15                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute2                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute3                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute4                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute5                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute6                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute7                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute8                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_attribute9                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_contract_id                IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_qte_contract_id            IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_ffm_request_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_invoice_to_address1        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_address2        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_address3        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_address4        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_city            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_cont_first_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_cont_last_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_cont_mid_name   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_country_code    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_country         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_county          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_party_id        IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_invoice_to_party_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_party_site_id   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_invoice_to_postal_code     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_province        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoice_to_state           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_invoicing_rule_id          IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_marketing_source_code_id   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_marketing_source_code      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_marketing_source_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_orig_mktg_source_code_id   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_order_type_id              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_order_id                   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_order_number               IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_h_order_type_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_h_ordered_date               IN  DATE     := FND_API.G_MISS_DATE,
   p_h_resource_id                IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_password                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_email_address                IN  jtf_varchar2_table_2000 := NULL,
   p_privilege_type               IN  jtf_varchar2_table_100  := NULL,
   p_url                          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_comments                     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_promocode                    IN  VARCHAR2 := FND_API.G_MISS_CHAR, --added for R12
   x_q_header_id                  OUT NOCOPY NUMBER
)
IS
   l_control_rec  ASO_QUOTE_PUB.Control_Rec_Type
                     := ASO_QUOTE_PUB.G_MISS_CONTROL_REC;
   l_q_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type
                     := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC;
BEGIN
   l_control_rec := Construct_Control_Rec(
      p_c_last_update_date        => p_c_last_update_date    ,
      p_c_auto_version_flag       => p_c_auto_version_flag   ,
      p_c_pricing_request_type    => p_c_pricing_request_type,
      p_c_header_pricing_event    => p_c_header_pricing_event,
      p_c_line_pricing_event      => p_c_line_pricing_event  ,
      p_c_cal_tax_flag            => p_c_cal_tax_flag        ,
      p_c_cal_freight_charge_flag => p_c_cal_freight_charge_flag,
      p_c_price_mode		  => p_c_price_mode);

   l_q_header_rec := Construct_Quote_Header_Rec(
      p_h_quote_header_id            => p_h_quote_header_id           ,
      p_h_creation_date              => p_h_creation_date             ,
      p_h_created_by                 => p_h_created_by                ,
      p_h_last_updated_by            => p_h_last_updated_by           ,
      p_h_last_update_date           => p_h_last_update_date          ,
      p_h_last_update_login          => p_h_last_update_login         ,
      p_h_request_id                 => p_h_request_id                ,
      p_h_program_application_id     => p_h_program_application_id    ,
      p_h_program_id                 => p_h_program_id                ,
      p_h_program_update_date        => p_h_program_update_date       ,
      p_h_org_id                     => p_h_org_id                    ,
      p_h_quote_name                 => p_h_quote_name                ,
      p_h_quote_number               => p_h_quote_number              ,
      p_h_quote_version              => p_h_quote_version             ,
      p_h_quote_status_id            => p_h_quote_status_id           ,
      p_h_quote_source_code          => p_h_quote_source_code         ,
      p_h_quote_expiration_date      => p_h_quote_expiration_date     ,
      p_h_price_frozen_date          => p_h_price_frozen_date         ,
      p_h_quote_password             => p_h_quote_password            ,
      p_h_original_system_reference  => p_h_original_system_reference ,
      p_h_party_id                   => p_h_party_id                  ,
      p_h_cust_account_id            => p_h_cust_account_id           ,
      p_h_org_contact_id             => p_h_org_contact_id            ,
      p_h_party_name                 => p_h_party_name                ,
      p_h_party_type                 => p_h_party_type                ,
      p_h_person_first_name          => p_h_person_first_name         ,
      p_h_person_last_name           => p_h_person_last_name          ,
      p_h_person_middle_name         => p_h_person_middle_name        ,
      p_h_phone_id                   => p_h_phone_id                  ,
      p_h_price_list_id              => p_h_price_list_id             ,
      p_h_pricing_status_indicator   => p_h_pricing_status_indicator  ,	-- change line logic pricing
      p_h_tax_status_indicator	     => p_h_tax_status_indicator      ,
      p_h_price_list_name            => p_h_price_list_name           ,
      p_h_currency_code              => p_h_currency_code             ,
      p_h_total_list_price           => p_h_total_list_price          ,
      p_h_total_adjusted_amount      => p_h_total_adjusted_amount     ,
      p_h_total_adjusted_percent     => p_h_total_adjusted_percent    ,
      p_h_total_tax                  => p_h_total_tax                 ,
      p_h_total_shipping_charge      => p_h_total_shipping_charge     ,
      p_h_surcharge                  => p_h_surcharge                 ,
      p_h_total_quote_price          => p_h_total_quote_price         ,
      p_h_payment_amount             => p_h_payment_amount            ,
      p_h_accounting_rule_id         => p_h_accounting_rule_id        ,
      p_h_exchange_rate              => p_h_exchange_rate             ,
      p_h_exchange_type_code         => p_h_exchange_type_code        ,
      p_h_exchange_rate_date         => p_h_exchange_rate_date        ,
      p_h_quote_category_code        => p_h_quote_category_code       ,
      p_h_quote_status_code          => p_h_quote_status_code         ,
      p_h_quote_status               => p_h_quote_status              ,
      p_h_employee_person_id         => p_h_employee_person_id        ,
      p_h_sales_channel_code         => p_h_sales_channel_code        ,
--      p_h_salesrep_full_name         => p_h_salesrep_full_name        ,
      p_h_attribute_category         => p_h_attribute_category        ,
      p_h_attribute1                 => p_h_attribute1                ,
      p_h_attribute10                => p_h_attribute10               ,
      p_h_attribute11                => p_h_attribute11               ,
      p_h_attribute12                => p_h_attribute12               ,
      p_h_attribute13                => p_h_attribute13               ,
      p_h_attribute14                => p_h_attribute14               ,
      p_h_attribute15                => p_h_attribute15               ,
      p_h_attribute2                 => p_h_attribute2                ,
      p_h_attribute3                 => p_h_attribute3                ,
      p_h_attribute4                 => p_h_attribute4                ,
      p_h_attribute5                 => p_h_attribute5                ,
      p_h_attribute6                 => p_h_attribute6                ,
      p_h_attribute7                 => p_h_attribute7                ,
      p_h_attribute8                 => p_h_attribute8                ,
      p_h_attribute9                 => p_h_attribute9                ,
      p_h_contract_id                => p_h_contract_id               ,
      p_h_qte_contract_id            => p_h_qte_contract_id           ,
      p_h_ffm_request_id             => p_h_ffm_request_id            ,
      p_h_invoice_to_address1        => p_h_invoice_to_address1       ,
      p_h_invoice_to_address2        => p_h_invoice_to_address2       ,
      p_h_invoice_to_address3        => p_h_invoice_to_address3       ,
      p_h_invoice_to_address4        => p_h_invoice_to_address4       ,
      p_h_invoice_to_city            => p_h_invoice_to_city           ,
      p_h_invoice_to_cont_first_name => p_h_invoice_to_cont_first_name,
      p_h_invoice_to_cont_last_name  => p_h_invoice_to_cont_last_name ,
      p_h_invoice_to_cont_mid_name   => p_h_invoice_to_cont_mid_name  ,
      p_h_invoice_to_country_code    => p_h_invoice_to_country_code   ,
      p_h_invoice_to_country         => p_h_invoice_to_country        ,
      p_h_invoice_to_county          => p_h_invoice_to_county         ,
      p_h_invoice_to_party_id        => p_h_invoice_to_party_id       ,
      p_h_invoice_to_party_name      => p_h_invoice_to_party_name     ,
      p_h_invoice_to_party_site_id   => p_h_invoice_to_party_site_id  ,
      p_h_invoice_to_postal_code     => p_h_invoice_to_postal_code    ,
      p_h_invoice_to_province        => p_h_invoice_to_province       ,
      p_h_invoice_to_state           => p_h_invoice_to_state          ,
      p_h_invoicing_rule_id          => p_h_invoicing_rule_id         ,
      p_h_marketing_source_code_id   => p_h_marketing_source_code_id  ,
      p_h_marketing_source_code      => p_h_marketing_source_code     ,
      p_h_marketing_source_name      => p_h_marketing_source_name     ,
      p_h_orig_mktg_source_code_id   => p_h_orig_mktg_source_code_id  ,
      p_h_order_type_id              => p_h_order_type_id             ,
      p_h_order_id                   => p_h_order_id                  ,
      p_h_order_number               => p_h_order_number              ,
      p_h_order_type_name            => p_h_order_type_name           ,
      p_h_ordered_date               => p_h_ordered_date              ,
      p_h_resource_id                => p_h_resource_id);

   IBE_Shop_List_PVT.Save_Quote_From_List_Items(
      p_api_version               => p_api_version           ,
      p_init_msg_list             => p_init_msg_list         ,
      p_commit                    => p_commit                ,
      x_return_status             => x_return_status         ,
      x_msg_count                 => x_msg_count             ,
      x_msg_data                  => x_msg_data              ,
      p_sl_line_ids               => p_sl_line_ids           ,
      p_sl_line_ovns              => p_sl_line_ovns          ,
      p_quote_retrieval_number    => p_quote_retrieval_number,
      p_recipient_party_id        => p_recipient_party_id    ,
      p_recipient_cust_account_id => p_recipient_cust_account_id,
      p_minisite_id               => p_minisite_id           ,
      p_mode                      => p_mode                  ,
      p_combine_same_item         => p_combine_same_item     ,
      p_control_rec               => l_control_rec           ,
      p_q_header_rec              => l_q_header_rec          ,
      p_password                  => p_password              ,
      p_email_address             => p_email_address         ,
      p_privilege_type            => p_privilege_type        ,
      p_url                       => p_url                   ,
      p_comments                  => p_comments              ,
      p_promocode                 => p_promocode             ,
      x_q_header_id               => x_q_header_id);
END Save_Quote_From_List_Items;

END IBE_Shop_List_Wrapper_PVT;


/
