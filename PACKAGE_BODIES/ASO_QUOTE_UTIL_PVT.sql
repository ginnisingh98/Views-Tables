--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_UTIL_PVT" as
/* $Header: asovqwub.pls 120.6.12010000.6 2011/11/23 22:36:06 cazhou ship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_UTIL_PVT
-- Purpose          : Utility functions for implementing rosetta wrappers
-- History          : Created on 12/02/01
-- NOTE             :
-- END of Comments
ROSETTA_G_MISTAKE_DATE DATE   := TO_DATE('01/01/+4713', 'MM/DD/SYYYY');
ROSETTA_G_MISS_NUM     NUMBER := 0-1962.0724;

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'ASO_QUOTE_UTIL_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ASOVQWUB.PLS';

Procedure debug(p_line in varchar2 ) IS

   x_rest varchar2(32767);
   debug_msg varchar2(32767);
   buffer_overflow exception;
   pragma exception_init(buffer_overflow, -20000);

begin

   If fnd_profile.value_specific('ASO_ENABLE_DEBUG',FND_GLOBAL.USER_ID,null,null) = 'Y' Then
      enable_debug_pvt();
   Else
      disable_debug_pvt();
   End If;

   x_rest := p_line;
   loop
      if (x_rest is null) then
         exit;
      else
         debug_msg := to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS')||' QOT '||substr(x_rest,1,255);
         utl_file.put_line(ASO_DEBUG_PUB.G_FILE_PTR, debug_msg);
	 utl_file.fflush(ASO_DEBUG_PUB.G_FILE_PTR);
	 x_rest := substr(x_rest,256);
      end if;
   end loop;

   exception
   when buffer_overflow then
      null;  -- buffer overflow, ignore
   when others then
     -- raise; -- Modified so that it will not raise any exceptions.
      null;
end debug;


Procedure enable_debug_pvt IS

   l_session_id NUMBER;
   l_file_name  VARCHAR2(255);

begin

   /* Modified the procedure so that we can enable debug at user level. If the
   profile ASO_ENABLE_DEBUG is Set to 'Yes' for a User, we will start writing
   the debug messages into a file. */
   IF fnd_profile.value_specific('ASO_ENABLE_DEBUG',FND_GLOBAL.USER_ID,null,null) = 'Y' Then

      l_session_id := icx_sec.g_session_id;
      l_file_name := 'QOT_'||FND_GLOBAL.USER_NAME||'_' || l_session_id || '.log';

      IF (ASO_DEBUG_PUB.G_FILE is NULL OR ASO_DEBUG_PUB.G_FILE <> l_file_name) Then
         ASO_DEBUG_PUB.G_DEBUG_MODE := 'FILE';
         ASO_DEBUG_PUB.G_FILE := l_file_name;
         ASO_DEBUG_PUB.G_FILE_PTR := utl_file.fopen(ASO_DEBUG_PUB.G_DIR,ASO_DEBUG_PUB.G_FILE,'a');
         ASO_DEBUG_PUB.debug_on;
         ASO_DEBUG_PUB.setdebuglevel(ASO_DEBUG_PUB.G_DEBUG_LEVEL);
         /* Setting OM Debug variables on */
         OE_DEBUG_PUB.G_DEBUG_MODE := 'FILE';
         OE_DEBUG_PUB.G_FILE := l_file_name;
         OE_DEBUG_PUB.G_FILE_PTR := ASO_DEBUG_PUB.G_FILE_PTR;
         OE_DEBUG_PUB.debug_on;
        OE_DEBUG_PUB.setdebuglevel(ASO_DEBUG_PUB.G_DEBUG_LEVEL);
      END IF;
   ELSE
      disable_debug_pvt;
   END IF;
   exception
     When Others Then
        null;
end enable_debug_pvt;

procedure disable_debug_pvt is
begin
   ASO_DEBUG_PUB.Debug_off;
   ASO_DEBUG_PUB.G_FILE := null;
   OE_DEBUG_PUB.Debug_off;
   OE_DEBUG_PUB.G_FILE := null;
   If utl_file.is_Open(ASO_DEBUG_PUB.G_FILE_PTR) Then
      utl_file.fclose(ASO_DEBUG_PUB.G_FILE_PTR);
   End If;
   exception
     When Others Then
        null;
end disable_debug_pvt;

FUNCTION is_debug_enabled RETURN VARCHAR2 AS
BEGIN
    RETURN NVL(fnd_profile.value('ASO_ENABLE_DEBUG'), 'N');
END is_debug_enabled;

FUNCTION rosetta_g_miss_num_map(n number) RETURN number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
BEGIN
    IF n=a THEN RETURN b; END IF;
    IF n=b THEN RETURN a; END IF;
    RETURN n;
END;


-- there IS total 108 fields here IN header
FUNCTION Construct_Qte_Header_Rec(
   p_quote_header_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_creation_date              IN DATE     := FND_API.G_MISS_DATE,
   p_created_by                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_last_updated_by            IN NUMBER   := FND_API.G_MISS_NUM,
   p_last_update_date           IN DATE     := FND_API.G_MISS_DATE,
   p_last_update_login          IN NUMBER   := FND_API.G_MISS_NUM,
   p_request_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_application_id     IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_update_date        IN DATE     := FND_API.G_MISS_DATE,
   p_org_id                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_name                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_number               IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_version              IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_status_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_source_code          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_expiration_date      IN DATE     := FND_API.G_MISS_DATE,
   p_price_frozen_date          IN DATE     := FND_API.G_MISS_DATE,
   p_quote_password             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_original_system_reference  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_party_id                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_cust_account_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_cust_account_id IN NUMBER   := FND_API.G_MISS_NUM,
   p_org_contact_id             IN NUMBER   := FND_API.G_MISS_NUM,
   p_party_name                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_party_type                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_person_first_name          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_person_last_name           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_person_middle_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_phone_id                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_price_list_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_price_list_name            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_currency_code              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_total_list_price           IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_adjusted_amount      IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_adjusted_percent     IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_tax                  IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_shipping_charge      IN NUMBER   := FND_API.G_MISS_NUM,
   p_surcharge                  IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_quote_price          IN NUMBER   := FND_API.G_MISS_NUM,
   p_payment_amount             IN NUMBER   := FND_API.G_MISS_NUM,
   p_accounting_rule_id         IN NUMBER   := FND_API.G_MISS_NUM,
   p_exchange_rate              IN NUMBER   := FND_API.G_MISS_NUM,
   p_exchange_type_code         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_exchange_rate_date         IN DATE     := FND_API.G_MISS_DATE,
   p_quote_category_code        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_status_code          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_status               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_employee_person_id         IN NUMBER   := FND_API.G_MISS_NUM,
   p_sales_channel_code         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_salesrep_first_name        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_salesrep_last_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute_category         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute1                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute10                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute11                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute12                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute13                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute14                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute15                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute2                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute3                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute4                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute5                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute6                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute7                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute8                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute9                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_contract_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_qte_contract_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_ffm_request_id             IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_address1        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_address2        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_address3        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_address4        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_city            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_cont_first_name IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_cont_last_name  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_cont_mid_name   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_country_code    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_country         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_county          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_party_id        IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_party_name      IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_party_site_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_postal_code     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_province        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_state           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoicing_rule_id          IN NUMBER   := FND_API.G_MISS_NUM,
   p_marketing_source_code_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_marketing_source_code      IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_marketing_source_name      IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_orig_mktg_source_code_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_order_type_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_order_id                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_order_number               IN NUMBER   := FND_API.G_MISS_NUM,
   p_order_type_name            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ordered_date               IN DATE     := FND_API.G_MISS_DATE,
   p_resource_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_contract_template_id       IN NUMBER   := FND_API.G_MISS_NUM,
   p_contract_template_maj_ver  IN NUMBER   := FND_API.G_MISS_NUM,
   p_contract_requester_id      IN NUMBER   := FND_API.G_MISS_NUM,
   p_contract_approval_level    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_publish_flag               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_resource_grp_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_sold_to_party_site_id      IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_arithmetic_operator IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_description          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_type                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_minisite_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_cust_party_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_cust_party_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_pricing_status_indicator   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_tax_status_indicator       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_updated_date         IN DATE     := FND_API.G_MISS_DATE,
   p_tax_updated_date           IN DATE     := FND_API.G_MISS_DATE,
   p_recalculate_flag           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_request_id           IN NUMBER   := FND_API.G_MISS_NUM,
   p_credit_update_date         IN DATE     := FND_API.G_MISS_DATE,
   p_customer_name_and_title    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_customer_signature_date    IN DATE     := FND_API.G_MISS_DATE,
   p_supplier_name_and_title    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_supplier_signature_date    IN DATE     := FND_API.G_MISS_DATE,
   p_attribute16                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute17                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute18                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute19                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute20                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_automatic_price_flag       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_automatic_tax_flag         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_assistance_requested       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_assistance_reason_code     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_end_customer_party_id      IN NUMBER   := FND_API.G_MISS_NUM,
   p_end_customer_party_site_id IN NUMBER   := FND_API.G_MISS_NUM,
   p_end_customer_cust_account_id IN NUMBER   := FND_API.G_MISS_NUM,
   p_end_customer_cust_party_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number      IN NUMBER   := FND_API.G_MISS_NUM,
   p_header_paynow_charges      IN NUMBER   := FND_API.G_MISS_NUM,
   p_product_FISC_classification IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_TRX_business_category       IN VARCHAR2 := FND_API.G_MISS_CHAR
 )
RETURN ASO_Quote_Pub.Qte_Header_Rec_Type
IS
   cursor l_last_update_date_csr(p_qte_header_id NUMBER) IS
 	 SELECT aqh.last_update_date
	 FROM aso_quote_headers_all aqh
	 WHERE aqh.quote_header_id = p_qte_header_id;
   l_last_update_date   DATE;

   l_qte_header ASO_Quote_Pub.Qte_Header_Rec_Type;



BEGIN
   IF p_quote_header_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.quote_header_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.quote_header_id := p_quote_header_id;
   END IF;

   IF p_creation_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.creation_date := FND_API.G_MISS_DATE;
   ELSE
     l_qte_header.creation_date := p_creation_date;
   END IF;
   IF p_created_by= ROSETTA_G_MISS_NUM THEN
      l_qte_header.created_by := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.created_by := p_created_by;
   END IF;
   IF p_last_updated_by= ROSETTA_G_MISS_NUM THEN
      l_qte_header.last_updated_by := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.last_updated_by := p_last_updated_by;
   END IF;
   IF p_last_update_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.last_update_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.last_update_date := p_last_update_date;
   END IF;

   -- if last_update_date = FND_API.G_MISS_DATE, query for
   -- last_updated_date
   IF p_last_update_date= FND_API.G_MISS_DATE THEN
      OPEN l_last_update_date_csr(p_quote_header_id);
      FETCH l_last_update_date_csr into l_last_update_date;
      IF l_last_update_date_csr%FOUND THEN
         l_qte_header.last_update_date := l_last_update_date;
      END IF;
      CLOSE l_last_update_date_csr;
   END IF;

   IF p_last_update_login= ROSETTA_G_MISS_NUM THEN
      l_qte_header.last_update_login := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.last_update_login := p_last_update_login;
   END IF;
   IF p_request_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.request_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.request_id := p_request_id;
   END IF;
   IF p_program_application_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.program_application_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.program_application_id := p_program_application_id;
   END IF;
   IF p_program_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.program_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.program_id := p_program_id;
   END IF;
   IF p_program_update_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.program_update_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.program_update_date := p_program_update_date;
   END IF;
   IF p_org_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.org_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.org_id := p_org_id;
   END IF;
   l_qte_header.quote_name := p_quote_name;
   IF p_quote_number= ROSETTA_G_MISS_NUM THEN
      l_qte_header.quote_number := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.quote_number := p_quote_number;
   END IF;
   IF p_quote_version= ROSETTA_G_MISS_NUM THEN
      l_qte_header.quote_version := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.quote_version := p_quote_version;
   END IF;
   IF p_quote_status_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.quote_status_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.quote_status_id := p_quote_status_id;
   END IF;
   l_qte_header.quote_source_code := p_quote_source_code;
   IF p_quote_expiration_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.quote_expiration_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.quote_expiration_date := p_quote_expiration_date;
   END IF;
   IF p_price_frozen_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.price_frozen_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.price_frozen_date := p_price_frozen_date;
   END IF;
   l_qte_header.quote_password := p_quote_password;
   l_qte_header.original_system_reference := p_original_system_reference;
   IF p_party_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.party_id := p_party_id;
   END IF;
   IF p_cust_account_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.cust_account_id := p_cust_account_id;
   END IF;
   IF p_invoice_to_cust_account_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.invoice_to_cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.invoice_to_cust_account_id := p_invoice_to_cust_account_id;
   END IF;
   IF p_org_contact_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.org_contact_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.org_contact_id := p_org_contact_id;
   END IF;
   l_qte_header.party_name := p_party_name;
   l_qte_header.party_type := p_party_type;
   l_qte_header.person_first_name := p_person_first_name;
   l_qte_header.person_last_name := p_person_last_name;
   l_qte_header.person_middle_name := p_person_middle_name;
   IF p_phone_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.phone_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.phone_id := p_phone_id;
   END IF;
   IF p_price_list_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.price_list_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.price_list_id := p_price_list_id;
   END IF;
   l_qte_header.price_list_name := p_price_list_name;
   l_qte_header.currency_code := p_currency_code;
   IF p_total_list_price= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_list_price := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_list_price := p_total_list_price;
   END IF;
   IF p_total_adjusted_amount= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_adjusted_amount := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_adjusted_amount := p_total_adjusted_amount;
   END IF;
   IF p_total_adjusted_percent= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_adjusted_percent := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_adjusted_percent := p_total_adjusted_percent;
   END IF;
   IF p_total_tax= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_tax := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_tax := p_total_tax;
   END IF;
   IF p_total_shipping_charge= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_shipping_charge := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_shipping_charge := p_total_shipping_charge;
   END IF;
   IF p_surcharge= ROSETTA_G_MISS_NUM THEN
      l_qte_header.surcharge := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.surcharge := p_surcharge;
   END IF;
   IF p_total_quote_price= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_quote_price := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_quote_price := p_total_quote_price;
   END IF;
   IF p_payment_amount= ROSETTA_G_MISS_NUM THEN
      l_qte_header.payment_amount := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.payment_amount := p_payment_amount;
   END IF;
   IF p_accounting_rule_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.accounting_rule_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.accounting_rule_id := p_accounting_rule_id;
   END IF;
   IF p_exchange_rate= ROSETTA_G_MISS_NUM THEN
      l_qte_header.exchange_rate := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.exchange_rate := p_exchange_rate;
   END IF;
   l_qte_header.exchange_type_code := p_exchange_type_code;
   IF p_exchange_rate_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.exchange_rate_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.exchange_rate_date := p_exchange_rate_date;
   END IF;
   l_qte_header.quote_category_code := p_quote_category_code;
   l_qte_header.quote_status_code := p_quote_status_code;
   l_qte_header.quote_status := p_quote_status;
   IF p_employee_person_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.employee_person_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.employee_person_id := p_employee_person_id;
   END IF;
   l_qte_header.sales_channel_code := p_sales_channel_code;
   l_qte_header.salesrep_first_name := p_salesrep_first_name;
   l_qte_header.salesrep_last_name := p_salesrep_last_name;
   l_qte_header.attribute_category := p_attribute_category;
   l_qte_header.attribute1 := p_attribute1;
   l_qte_header.attribute10 := p_attribute10;
   l_qte_header.attribute11 := p_attribute11;
   l_qte_header.attribute12 := p_attribute12;
   l_qte_header.attribute13 := p_attribute13;
   l_qte_header.attribute14 := p_attribute14;
   l_qte_header.attribute15 := p_attribute15;
   l_qte_header.attribute2 := p_attribute2;
   l_qte_header.attribute3 := p_attribute3;
   l_qte_header.attribute4 := p_attribute4;
   l_qte_header.attribute5 := p_attribute5;
   l_qte_header.attribute6 := p_attribute6;
   l_qte_header.attribute7 := p_attribute7;
   l_qte_header.attribute8 := p_attribute8;
   l_qte_header.attribute9 := p_attribute9;
   IF p_contract_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.contract_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.contract_id := p_contract_id;
   END IF;
   IF p_qte_contract_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.qte_contract_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.qte_contract_id := p_qte_contract_id;
   END IF;
   IF p_ffm_request_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.ffm_request_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.ffm_request_id := p_ffm_request_id;
   END IF;
   l_qte_header.invoice_to_address1 := p_invoice_to_address1;
   l_qte_header.invoice_to_address2 := p_invoice_to_address2;
   l_qte_header.invoice_to_address3 := p_invoice_to_address3;
   l_qte_header.invoice_to_address4 := p_invoice_to_address4;
   l_qte_header.invoice_to_city := p_invoice_to_city;
   l_qte_header.invoice_to_contact_first_name := p_invoice_to_cont_first_name;
   l_qte_header.invoice_to_contact_last_name := p_invoice_to_cont_last_name;
   l_qte_header.invoice_to_contact_middle_name := p_invoice_to_cont_mid_name;
   l_qte_header.invoice_to_country_code := p_invoice_to_country_code;
   l_qte_header.invoice_to_country := p_invoice_to_country;
   l_qte_header.invoice_to_county := p_invoice_to_county;
   IF p_invoice_to_party_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.invoice_to_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.invoice_to_party_id := p_invoice_to_party_id;
   END IF;
   l_qte_header.invoice_to_party_name := p_invoice_to_party_name;
   IF p_invoice_to_party_site_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.invoice_to_party_site_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.invoice_to_party_site_id := p_invoice_to_party_site_id;
   END IF;
   l_qte_header.invoice_to_postal_code := p_invoice_to_postal_code;
   l_qte_header.invoice_to_province := p_invoice_to_province;
   l_qte_header.invoice_to_state := p_invoice_to_state;
   IF p_invoicing_rule_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.invoicing_rule_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.invoicing_rule_id := p_invoicing_rule_id;
   END IF;
   IF p_marketing_source_code_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.marketing_source_code_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.marketing_source_code_id := p_marketing_source_code_id;
   END IF;
   l_qte_header.marketing_source_code := p_marketing_source_code;
   l_qte_header.marketing_source_name := p_marketing_source_name;
   IF p_orig_mktg_source_code_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.orig_mktg_source_code_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.orig_mktg_source_code_id := p_orig_mktg_source_code_id;
   END IF;
   IF p_order_type_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.order_type_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.order_type_id := p_order_type_id;
   END IF;
   IF p_order_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.order_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.order_id := p_order_id;
   END IF;
   IF p_order_number= ROSETTA_G_MISS_NUM THEN
      l_qte_header.order_number := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.order_number := p_order_number;
   END IF;
   l_qte_header.order_type_name := p_order_type_name;
   IF p_ordered_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.ordered_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.ordered_date := p_ordered_date;
   END IF;
   IF p_resource_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.resource_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.resource_id := p_resource_id;
   END IF;
   IF p_contract_template_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.contract_template_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.contract_template_id := p_contract_template_id;
   END IF;
   IF p_contract_template_maj_ver = ROSETTA_G_MISS_NUM THEN
      l_qte_header.contract_template_major_ver := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.contract_template_major_ver := p_contract_template_maj_ver;
   END IF;
   IF p_contract_requester_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.contract_requester_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.contract_requester_id := p_contract_requester_id;
   END IF;
   l_qte_header.contract_approval_level := p_contract_approval_level;
   l_qte_header.publish_flag := p_publish_flag;
   IF p_resource_grp_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.resource_grp_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.resource_grp_id := p_resource_grp_id;
   END IF;
   IF p_sold_to_party_site_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.sold_to_party_site_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.sold_to_party_site_id := p_sold_to_party_site_id;
   END IF;
   l_qte_header.display_arithmetic_operator := p_display_arithmetic_operator;
   l_qte_header.quote_description := p_quote_description;
   l_qte_header.quote_type := p_quote_type;
   IF p_minisite_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.minisite_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.minisite_id := p_minisite_id;
   END IF;
   IF p_cust_party_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.cust_party_id := p_cust_party_id;
   ELSE
      l_qte_header.cust_party_id := p_cust_party_id;
   END IF;
   IF p_invoice_to_cust_party_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.invoice_to_cust_party_id := p_invoice_to_cust_party_id;
   ELSE
      l_qte_header.invoice_to_cust_party_id := p_invoice_to_cust_party_id;
   END IF;
   l_qte_header.pricing_status_indicator := p_pricing_status_indicator;
   l_qte_header.tax_status_indicator := p_tax_status_indicator;
   IF p_price_updated_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.price_updated_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.price_updated_date := p_price_updated_date;
   END IF;
   IF p_tax_updated_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.tax_updated_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.tax_updated_date := p_tax_updated_date;
   END IF;
   l_qte_header.recalculate_flag := p_recalculate_flag;
   IF p_price_request_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.price_request_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.price_request_id := p_price_request_id;
   END IF;
   IF p_credit_update_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.credit_update_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.credit_update_date := p_credit_update_date;
   END IF;

   l_qte_header.customer_name_and_title := p_customer_name_and_title;
   IF p_customer_signature_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.customer_signature_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.customer_signature_date := p_customer_signature_date;
   END IF;
   l_qte_header.supplier_name_and_title := p_supplier_name_and_title;
   IF p_supplier_signature_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.supplier_signature_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.supplier_signature_date := p_supplier_signature_date;
   END IF;
   l_qte_header.attribute16 := p_attribute16;
   l_qte_header.attribute17 := p_attribute17;
   l_qte_header.attribute18 := p_attribute18;
   l_qte_header.attribute19 := p_attribute19;
   l_qte_header.attribute20 := p_attribute20;
   l_qte_header.automatic_price_flag := p_automatic_price_flag;
   l_qte_header.automatic_tax_flag := p_automatic_tax_flag;
   l_qte_header.assistance_requested := p_assistance_requested;
   l_qte_header.assistance_reason_code := p_assistance_reason_code;
   IF p_end_customer_party_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.end_customer_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.end_customer_party_id := p_end_customer_party_id;
   END IF;
   IF p_end_customer_party_site_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.end_customer_party_site_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.end_customer_party_site_id := p_end_customer_party_site_id;
   END IF;
   IF p_end_customer_cust_account_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.end_customer_cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.end_customer_cust_account_id := p_end_customer_cust_account_id;
   END IF;
   IF p_end_customer_cust_party_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.end_customer_cust_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.end_customer_cust_party_id := p_end_customer_cust_party_id;
   END IF;

   IF p_object_version_number = ROSETTA_G_MISS_NUM THEN
      l_qte_header.object_version_number := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.object_version_number := p_object_version_number;
   END IF;

   IF p_header_paynow_charges = ROSETTA_G_MISS_NUM THEN
      l_qte_header.header_paynow_charges := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.header_paynow_charges := p_header_paynow_charges;
   END IF;

   l_qte_header.product_FISC_classification := p_product_FISC_classification;

   l_qte_header.TRX_business_category := p_TRX_business_category;

   RETURN l_qte_header;
END Construct_Qte_Header_Rec;

-- there IS total 71 fields here IN line
FUNCTION Construct_Qte_Line_Rec(
   p_creation_date              IN DATE     := FND_API.G_MISS_DATE,
   p_created_by                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_last_updated_by            IN NUMBER   := FND_API.G_MISS_NUM,
   p_last_update_date           IN DATE     := FND_API.G_MISS_DATE,
   p_last_update_login          IN NUMBER   := FND_API.G_MISS_NUM,
   p_request_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_application_id     IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_update_date        IN DATE     := FND_API.G_MISS_DATE,
   p_quote_line_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_header_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_org_id                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_line_number                IN NUMBER   := FND_API.G_MISS_NUM,
   p_line_category_code         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_item_type_code             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_inventory_item_id          IN NUMBER   := FND_API.G_MISS_NUM,
   p_organization_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_quantity                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_uom_code                   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_start_date_active          IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active            IN DATE     := FND_API.G_MISS_DATE,
   p_order_line_type_id         IN NUMBER   := FND_API.G_MISS_NUM,
   p_price_list_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_price_list_line_id         IN NUMBER   := FND_API.G_MISS_NUM,
   p_currency_code              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_line_list_price            IN NUMBER   := FND_API.G_MISS_NUM,
   p_line_adjusted_amount       IN NUMBER   := FND_API.G_MISS_NUM,
   p_line_adjusted_percent      IN NUMBER   := FND_API.G_MISS_NUM,
   p_line_quote_price           IN NUMBER   := FND_API.G_MISS_NUM,
   p_related_item_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_item_relationship_type     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_split_shipment_flag        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_backorder_flag             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_selling_price_change       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_recalculate_flag           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute_category         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute1                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute2                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute3                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute4                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute5                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute6                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute7                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute8                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute9                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute10                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute11                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute12                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute13                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute14                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute15                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_accounting_rule_id         IN NUMBER   := FND_API.G_MISS_NUM,
   p_ffm_content_name           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ffm_content_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ffm_document_type          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ffm_media_id               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ffm_media_type             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ffm_user_note              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_party_id        IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_party_site_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoicing_rule_id          IN NUMBER   := FND_API.G_MISS_NUM,
   p_marketing_source_code_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_operation_code             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_cust_account_id IN NUMBER   := FND_API.G_MISS_NUM,
   p_pricing_quantity_uom       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_minisite_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_section_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_priced_price_list_id       IN NUMBER   := FND_API.G_MISS_NUM,
   p_agreement_id               IN NUMBER   := FND_API.G_MISS_NUM,
   p_commitment_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_arithmetic_operator IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_cust_party_id    IN NUMBER   := FND_API.G_MISS_NUM,
   p_attribute16                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute17                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute18                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute19                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute20                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ship_model_complete_flag   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_charge_periodicity_code    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_end_customer_party_id      IN NUMBER   := FND_API.G_MISS_NUM,
   p_end_customer_party_site_id IN NUMBER   := FND_API.G_MISS_NUM,
   p_end_customer_cust_account_id IN NUMBER   := FND_API.G_MISS_NUM,
   p_end_customer_cust_party_id IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number       IN NUMBER   := FND_API.G_MISS_NUM,
   p_line_paynow_charges        IN NUMBER   := FND_API.G_MISS_NUM,
   p_line_paynow_tax            IN NUMBER   := FND_API.G_MISS_NUM,
   p_line_paynow_subtotal       IN NUMBER   := FND_API.G_MISS_NUM,
   p_config_model_type          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_product_FISC_classification IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_TRX_business_category       IN VARCHAR2 := FND_API.G_MISS_CHAR
)
RETURN ASO_Quote_Pub.Qte_Line_Rec_Type
IS

   l_qte_line_rec   ASO_Quote_Pub.Qte_Line_Rec_Type;

BEGIN

   IF p_creation_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_line_rec.creation_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_line_rec.creation_date := p_creation_date;
   END IF;
   IF p_created_by= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.created_by := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.created_by := p_created_by;
   END IF;
   IF p_last_updated_by= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.last_updated_by := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.last_updated_by := p_last_updated_by;
   END IF;
   IF p_last_update_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_line_rec.last_update_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_line_rec.last_update_date := p_last_update_date;
   END IF;
   IF p_last_update_login= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.last_update_login := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.last_update_login := p_last_update_login;
   END IF;
   IF p_request_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.request_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.request_id := p_request_id;
   END IF;
   IF p_program_application_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.program_application_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.program_application_id := p_program_application_id;
   END IF;
   IF p_program_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.program_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.program_id := p_program_id;
   END IF;
   IF p_program_update_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_line_rec.program_update_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_line_rec.program_update_date := p_program_update_date;
   END IF;
   IF p_quote_line_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.quote_line_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.quote_line_id := p_quote_line_id;
   END IF;
   IF p_quote_header_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.quote_header_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.quote_header_id := p_quote_header_id;
   END IF;
   IF p_org_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.org_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.org_id := p_org_id;
   END IF;
   IF p_line_number= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.line_number := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.line_number := p_line_number;
   END IF;
   l_qte_line_rec.line_category_code := p_line_category_code;
   l_qte_line_rec.item_type_code := p_item_type_code;
   IF p_inventory_item_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.inventory_item_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.inventory_item_id := p_inventory_item_id;
   END IF;
   IF p_organization_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.organization_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.organization_id := p_organization_id;
   END IF;
   IF p_quantity= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.quantity := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.quantity := p_quantity;
   END IF;
   l_qte_line_rec.uom_code := p_uom_code;
   IF p_start_date_active= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_line_rec.start_date_active := FND_API.G_MISS_DATE;
   ELSE
      l_qte_line_rec.start_date_active := p_start_date_active;
   END IF;
   IF p_end_date_active= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_line_rec.end_date_active := FND_API.G_MISS_DATE;
   ELSE
      l_qte_line_rec.end_date_active := p_end_date_active;
   END IF;
   IF p_order_line_type_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.order_line_type_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.order_line_type_id := p_order_line_type_id;
   END IF;
   IF p_price_list_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.price_list_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.price_list_id := p_price_list_id;
   END IF;
   IF p_price_list_line_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.price_list_line_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.price_list_line_id := p_price_list_line_id;
   END IF;
   l_qte_line_rec.currency_code := p_currency_code;
   IF p_line_list_price= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.line_list_price := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.line_list_price := p_line_list_price;
   END IF;
   IF p_line_adjusted_amount= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.line_adjusted_amount := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.line_adjusted_amount := p_line_adjusted_amount;
   END IF;
   IF p_line_adjusted_percent= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.line_adjusted_percent := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.line_adjusted_percent := p_line_adjusted_percent;
   END IF;
   IF p_line_quote_price= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.line_quote_price := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.line_quote_price := p_line_quote_price;
   END IF;
   IF p_related_item_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.related_item_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.related_item_id := p_related_item_id;
   END IF;
   l_qte_line_rec.item_relationship_type := p_item_relationship_type;
   l_qte_line_rec.split_shipment_flag := p_split_shipment_flag;
   l_qte_line_rec.backorder_flag := p_backorder_flag;
   l_qte_line_rec.selling_price_change := p_selling_price_change;
   l_qte_line_rec.recalculate_flag := p_recalculate_flag;
   l_qte_line_rec.attribute_category := p_attribute_category;
   l_qte_line_rec.attribute1 := p_attribute1;
   l_qte_line_rec.attribute2 := p_attribute2;
   l_qte_line_rec.attribute3 := p_attribute3;
   l_qte_line_rec.attribute4 := p_attribute4;
   l_qte_line_rec.attribute5 := p_attribute5;
   l_qte_line_rec.attribute6 := p_attribute6;
   l_qte_line_rec.attribute7 := p_attribute7;
   l_qte_line_rec.attribute8 := p_attribute8;
   l_qte_line_rec.attribute9 := p_attribute9;
   l_qte_line_rec.attribute10 := p_attribute10;
   l_qte_line_rec.attribute11 := p_attribute11;
   l_qte_line_rec.attribute12 := p_attribute12;
   l_qte_line_rec.attribute13 := p_attribute13;
   l_qte_line_rec.attribute14 := p_attribute14;
   l_qte_line_rec.attribute15 := p_attribute15;
   IF p_accounting_rule_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.accounting_rule_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.accounting_rule_id := p_accounting_rule_id;
   END IF;
   l_qte_line_rec.ffm_content_name := p_ffm_content_name;
   l_qte_line_rec.ffm_content_type := p_ffm_content_type;
   l_qte_line_rec.ffm_document_type := p_ffm_document_type;
   l_qte_line_rec.ffm_media_id := p_ffm_media_id;
   l_qte_line_rec.ffm_media_type := p_ffm_media_type;
   l_qte_line_rec.ffm_user_note := p_ffm_user_note;
   IF p_invoice_to_party_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.invoice_to_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.invoice_to_party_id := p_invoice_to_party_id;
   END IF;
   IF p_invoice_to_party_site_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.invoice_to_party_site_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.invoice_to_party_site_id := p_invoice_to_party_site_id;
   END IF;
   IF p_invoicing_rule_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.invoicing_rule_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.invoicing_rule_id := p_invoicing_rule_id;
   END IF;
   IF p_marketing_source_code_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.marketing_source_code_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.marketing_source_code_id := p_marketing_source_code_id;
   END IF;
   IF p_invoice_to_cust_account_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.invoice_to_cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.invoice_to_cust_account_id := p_invoice_to_cust_account_id;
   END IF;
   l_qte_line_rec.pricing_quantity_uom := p_pricing_quantity_uom;
   IF p_minisite_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.minisite_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.minisite_id := p_minisite_id;
   END IF;
   IF p_section_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.section_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.section_id := p_section_id;
   END IF;
   IF p_priced_price_list_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.priced_price_list_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.priced_price_list_id := p_priced_price_list_id;
   END IF;
   IF p_agreement_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.agreement_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.agreement_id := p_agreement_id;
   END IF;
   IF p_commitment_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.commitment_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.commitment_id := p_commitment_id;
   END IF;
   l_qte_line_rec.display_arithmetic_operator := p_display_arithmetic_operator;
   IF p_invoice_to_cust_party_id= ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.invoice_to_cust_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.invoice_to_cust_party_id := p_invoice_to_cust_party_id;
   END IF;
   l_qte_line_rec.attribute16 := p_attribute16;
   l_qte_line_rec.attribute17 := p_attribute17;
   l_qte_line_rec.attribute18 := p_attribute18;
   l_qte_line_rec.attribute19 := p_attribute19;
   l_qte_line_rec.attribute20 := p_attribute20;
   l_qte_line_rec.ship_model_complete_flag := p_ship_model_complete_flag;
   IF p_object_version_number = ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.object_version_number := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.object_version_number := p_object_version_number;
   END IF;
   l_qte_line_rec.charge_periodicity_code   := p_charge_periodicity_code;

   IF p_end_customer_party_id = ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.end_customer_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.end_customer_party_id := p_end_customer_party_id;
   END IF;

   IF p_end_customer_party_site_id = ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.end_customer_party_site_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.end_customer_party_site_id := p_end_customer_party_site_id;
   END IF;

   IF p_end_customer_cust_account_id = ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.end_customer_cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.end_customer_cust_account_id := p_end_customer_cust_account_id;
   END IF;

   IF p_end_customer_cust_party_id = ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.end_customer_cust_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_line_rec.end_customer_cust_party_id := p_end_customer_cust_party_id;
   END IF;

   IF p_line_paynow_charges  = ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.line_paynow_charges := FND_API.G_MISS_NUM;
   ELSE
         l_qte_line_rec.line_paynow_charges := p_line_paynow_charges;
   END IF;

   IF p_line_paynow_tax  = ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.line_paynow_tax := FND_API.G_MISS_NUM;
   ELSE
         l_qte_line_rec.line_paynow_tax := p_line_paynow_tax;
   END IF;

   IF p_line_paynow_subtotal  = ROSETTA_G_MISS_NUM THEN
      l_qte_line_rec.line_paynow_subtotal := FND_API.G_MISS_NUM;
   ELSE
         l_qte_line_rec.line_paynow_subtotal := p_line_paynow_subtotal;
   END IF;

      l_qte_line_rec.config_model_type := p_config_model_type;

   l_qte_line_rec.operation_code := p_operation_code;


   l_qte_line_rec.product_FISC_classification := p_product_FISC_classification;

   l_qte_line_rec.TRX_business_category := p_TRX_business_category;

   return l_qte_line_rec;

END Construct_Qte_Line_Rec;

-- there IS total 71 fields here IN line
FUNCTION Construct_Qte_Line_Tbl(
   p_creation_date              IN jtf_date_table         := NULL,
   p_created_by                 IN jtf_number_table       := NULL,
   p_last_updated_by            IN jtf_number_table       := NULL,
   p_last_update_date           IN jtf_date_table         := NULL,
   p_last_update_login          IN jtf_number_table       := NULL,
   p_request_id                 IN jtf_number_table       := NULL,
   p_program_application_id     IN jtf_number_table       := NULL,
   p_program_id                 IN jtf_number_table       := NULL,
   p_program_update_date        IN jtf_date_table         := NULL,
   p_quote_line_id              IN jtf_number_table       := NULL,
   p_quote_header_id            IN jtf_number_table       := NULL,
   p_org_id                     IN jtf_number_table       := NULL,
   p_line_number                IN jtf_number_table       := NULL,
   p_line_category_code         IN jtf_varchar2_table_100 := NULL,
   p_item_type_code             IN jtf_varchar2_table_100 := NULL,
   p_inventory_item_id          IN jtf_number_table       := NULL,
   p_organization_id            IN jtf_number_table       := NULL,
   p_quantity                   IN jtf_number_table       := NULL,
   p_uom_code                   IN jtf_varchar2_table_100 := NULL,
   p_start_date_active          IN jtf_date_table         := NULL,
   p_end_date_active            IN jtf_date_table         := NULL,
   p_order_line_type_id         IN jtf_number_table       := NULL,
   p_price_list_id              IN jtf_number_table       := NULL,
   p_price_list_line_id         IN jtf_number_table       := NULL,
   p_currency_code              IN jtf_varchar2_table_100 := NULL,
   p_line_list_price            IN jtf_number_table       := NULL,
   p_line_adjusted_amount       IN jtf_number_table       := NULL,
   p_line_adjusted_percent      IN jtf_number_table       := NULL,
   p_line_quote_price           IN jtf_number_table       := NULL,
   p_related_item_id            IN jtf_number_table       := NULL,
   p_item_relationship_type     IN jtf_varchar2_table_100 := NULL,
   p_split_shipment_flag        IN jtf_varchar2_table_100 := NULL,
   p_backorder_flag             IN jtf_varchar2_table_100 := NULL,
   p_selling_price_change       IN jtf_varchar2_table_100 := NULL,
   p_recalculate_flag           IN jtf_varchar2_table_100 := NULL,
   p_attribute_category         IN jtf_varchar2_table_100 := NULL,
   p_attribute1                 IN jtf_varchar2_table_300 := NULL,
   p_attribute2                 IN jtf_varchar2_table_300 := NULL,
   p_attribute3                 IN jtf_varchar2_table_300 := NULL,
   p_attribute4                 IN jtf_varchar2_table_300 := NULL,
   p_attribute5                 IN jtf_varchar2_table_300 := NULL,
   p_attribute6                 IN jtf_varchar2_table_300 := NULL,
   p_attribute7                 IN jtf_varchar2_table_300 := NULL,
   p_attribute8                 IN jtf_varchar2_table_300 := NULL,
   p_attribute9                 IN jtf_varchar2_table_300 := NULL,
   p_attribute10                IN jtf_varchar2_table_300 := NULL,
   p_attribute11                IN jtf_varchar2_table_300 := NULL,
   p_attribute12                IN jtf_varchar2_table_300 := NULL,
   p_attribute13                IN jtf_varchar2_table_300 := NULL,
   p_attribute14                IN jtf_varchar2_table_300 := NULL,
   p_attribute15                IN jtf_varchar2_table_300 := NULL,
   p_accounting_rule_id         IN jtf_number_table       := NULL,
   p_ffm_content_name           IN jtf_varchar2_table_300 := NULL,
   p_ffm_content_type           IN jtf_varchar2_table_300 := NULL,
   p_ffm_document_type          IN jtf_varchar2_table_300 := NULL,
   p_ffm_media_id               IN jtf_varchar2_table_300 := NULL,
   p_ffm_media_type             IN jtf_varchar2_table_300 := NULL,
   p_ffm_user_note              IN jtf_varchar2_table_300 := NULL,
   p_invoice_to_party_id        IN jtf_number_table       := NULL,
   p_invoice_to_party_site_id   IN jtf_number_table       := NULL,
   p_invoicing_rule_id          IN jtf_number_table       := NULL,
   p_marketing_source_code_id   IN jtf_number_table       := NULL,
   p_operation_code             IN jtf_varchar2_table_100 := NULL,
   p_invoice_to_cust_account_id IN jtf_number_table       := NULL,
   p_pricing_quantity_uom       IN jtf_varchar2_table_100 := NULL,
   p_minisite_id                IN jtf_number_table       := NULL,
   p_section_id                 IN jtf_number_table       := NULL,
   p_priced_price_list_id       IN jtf_number_table       := NULL,
   p_agreement_id               IN jtf_number_table       := NULL,
   p_commitment_id              IN jtf_number_table       := NULL,
   p_display_arithmetic_operator IN jtf_varchar2_table_100 := NULL,
   p_invoice_to_cust_party_id    IN jtf_number_table       := NULL,
   p_attribute16                IN jtf_varchar2_table_300 := NULL,
   p_attribute17                IN jtf_varchar2_table_300 := NULL,
   p_attribute18                IN jtf_varchar2_table_300 := NULL,
   p_attribute19                IN jtf_varchar2_table_300 := NULL,
   p_attribute20                IN jtf_varchar2_table_300 := NULL,
   p_ship_model_complete_flag   IN jtf_varchar2_table_100 := NULL,
   p_charge_periodicity_code    IN jtf_varchar2_table_100 := NULL,
   p_end_customer_party_id      IN jtf_number_table       := NULL,
   p_end_customer_party_site_id IN jtf_number_table       := NULL,
   p_end_customer_cust_account_id IN jtf_number_table     := NULL,
   p_end_customer_cust_party_id IN jtf_number_table       := NULL,
   p_object_version_number      IN jtf_number_table       := NULL,
   p_line_paynow_charges        IN jtf_number_table       := NULL,
   p_line_paynow_tax            IN jtf_number_table       := NULL,
   p_line_paynow_subtotal       IN jtf_number_table       := NULL,
   p_config_model_type          IN jtf_varchar2_table_100 := NULL,
   p_product_FISC_classification IN jtf_varchar2_table_100 := NULL,
   p_TRX_business_category       IN jtf_varchar2_table_100 := NULL
  )
RETURN ASO_Quote_Pub.Qte_Line_Tbl_Type
IS
   l_qte_line_tbl ASO_Quote_Pub.Qte_Line_Tbl_Type;
   l_table_size   PLS_INTEGER := 0;
   i              PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN

   FOR i IN 1..l_table_size LOOP
     IF p_creation_date IS NOT NULL THEN
      IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
         l_qte_line_tbl(i).creation_date := FND_API.G_MISS_DATE;
      ELSE
         l_qte_line_tbl(i).creation_date := p_creation_date(i);
      END IF;
     END IF;
     IF p_created_by IS NOT NULL THEN
      IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).created_by := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).created_by := p_created_by(i);
      END IF;
     END IF;
     IF p_last_updated_by IS NOT NULL THEN
      IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).last_updated_by := p_last_updated_by(i);
      END IF;
     END IF;
     IF p_last_update_date IS NOT NULL THEN
      IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
         l_qte_line_tbl(i).last_update_date := FND_API.G_MISS_DATE;
      ELSE
         l_qte_line_tbl(i).last_update_date := p_last_update_date(i);
      END IF;
     END IF;
     IF p_last_update_login IS NOT NULL THEN
      IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).last_update_login := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).last_update_login := p_last_update_login(i);
      END IF;
     END IF;
     IF p_request_id IS NOT NULL THEN
      IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).request_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).request_id := p_request_id(i);
      END IF;
     END IF;
     IF p_program_application_id IS NOT NULL THEN
      IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).program_application_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).program_application_id := p_program_application_id(i);
      END IF;
     END IF;
     IF p_program_id IS NOT NULL THEN
      IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).program_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).program_id := p_program_id(i);
      END IF;
     END IF;
     IF p_program_update_date IS NOT NULL THEN
      IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
         l_qte_line_tbl(i).program_update_date := FND_API.G_MISS_DATE;
      ELSE
         l_qte_line_tbl(i).program_update_date := p_program_update_date(i);
      END IF;
     END IF;
     IF p_quote_line_id IS NOT NULL THEN
      IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).quote_line_id := p_quote_line_id(i);
      END IF;
     END IF;
     IF p_quote_header_id IS NOT NULL THEN
      IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).quote_header_id := p_quote_header_id(i);
      END IF;
     END IF;
     IF p_org_id IS NOT NULL THEN
      IF p_org_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).org_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).org_id := p_org_id(i);
      END IF;
     END IF;
     IF p_line_number IS NOT NULL THEN
      IF p_line_number(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).line_number := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).line_number := p_line_number(i);
      END IF;
     END IF;
     IF p_line_category_code IS NOT NULL THEN
      l_qte_line_tbl(i).line_category_code := p_line_category_code(i);
     END IF;
     IF p_item_type_code IS NOT NULL THEN
      l_qte_line_tbl(i).item_type_code := p_item_type_code(i);
     END IF;
     IF p_inventory_item_id IS NOT NULL THEN
      IF p_inventory_item_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).inventory_item_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).inventory_item_id := p_inventory_item_id(i);
      END IF;
     END IF;
     IF p_organization_id IS NOT NULL THEN
      IF p_organization_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).organization_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).organization_id := p_organization_id(i);
      END IF;
     END IF;
     IF p_quantity IS NOT NULL THEN
      IF p_quantity(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).quantity := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).quantity := p_quantity(i);
      END IF;
     END IF;
     IF p_uom_code IS NOT NULL THEN
      l_qte_line_tbl(i).uom_code := p_uom_code(i);
     END IF;
     IF p_start_date_active IS NOT NULL THEN
      IF p_start_date_active(i)= ROSETTA_G_MISTAKE_DATE THEN
         l_qte_line_tbl(i).start_date_active := FND_API.G_MISS_DATE;
      ELSE
         l_qte_line_tbl(i).start_date_active := p_start_date_active(i);
      END IF;
     END IF;
     IF p_end_date_active IS NOT NULL THEN
      IF p_end_date_active(i)= ROSETTA_G_MISTAKE_DATE THEN
         l_qte_line_tbl(i).end_date_active := FND_API.G_MISS_DATE;
      ELSE
         l_qte_line_tbl(i).end_date_active := p_end_date_active(i);
      END IF;
     END IF;
     IF p_order_line_type_id IS NOT NULL THEN
      IF p_order_line_type_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).order_line_type_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).order_line_type_id := p_order_line_type_id(i);
      END IF;
     END IF;
     IF p_price_list_id IS NOT NULL THEN
      IF p_price_list_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).price_list_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).price_list_id := p_price_list_id(i);
      END IF;
     END IF;
     IF p_price_list_line_id IS NOT NULL THEN
      IF p_price_list_line_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).price_list_line_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).price_list_line_id := p_price_list_line_id(i);
      END IF;
     END IF;
     IF p_currency_code IS NOT NULL THEN
      l_qte_line_tbl(i).currency_code := p_currency_code(i);
     END IF;
     IF p_line_list_price IS NOT NULL THEN
      IF p_line_list_price(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).line_list_price := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).line_list_price := p_line_list_price(i);
      END IF;
     END IF;
     IF p_line_adjusted_amount IS NOT NULL THEN
      IF p_line_adjusted_amount(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).line_adjusted_amount := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).line_adjusted_amount := p_line_adjusted_amount(i);
      END IF;
     END IF;
     IF p_line_adjusted_percent IS NOT NULL THEN
      IF p_line_adjusted_percent(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).line_adjusted_percent := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).line_adjusted_percent := p_line_adjusted_percent(i);
      END IF;
     END IF;
     IF p_line_quote_price IS NOT NULL THEN
      IF p_line_quote_price(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).line_quote_price := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).line_quote_price := p_line_quote_price(i);
      END IF;
     END IF;
     IF p_related_item_id IS NOT NULL THEN
      IF p_related_item_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).related_item_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).related_item_id := p_related_item_id(i);
      END IF;
     END IF;
     IF p_item_relationship_type IS NOT NULL THEN
      l_qte_line_tbl(i).item_relationship_type := p_item_relationship_type(i);
     END IF;
     IF p_split_shipment_flag IS NOT NULL THEN
      l_qte_line_tbl(i).split_shipment_flag := p_split_shipment_flag(i);
     END IF;
     IF p_backorder_flag IS NOT NULL THEN
      l_qte_line_tbl(i).backorder_flag := p_backorder_flag(i);
     END IF;
     IF p_selling_price_change IS NOT NULL THEN
      l_qte_line_tbl(i).selling_price_change := p_selling_price_change(i);
     END IF;
     IF p_recalculate_flag IS NOT NULL THEN
      l_qte_line_tbl(i).recalculate_flag := p_recalculate_flag(i);
     END IF;
     IF p_attribute_category IS NOT NULL THEN
      l_qte_line_tbl(i).attribute_category := p_attribute_category(i);
     END IF;
     IF p_attribute1 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute1 := p_attribute1(i);
     END IF;
     IF p_attribute2 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute2 := p_attribute2(i);
     END IF;
     IF p_attribute3 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute3 := p_attribute3(i);
     END IF;
     IF p_attribute4 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute4 := p_attribute4(i);
     END IF;
     IF p_attribute5 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute5 := p_attribute5(i);
     END IF;
     IF p_attribute6 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute6 := p_attribute6(i);
     END IF;
     IF p_attribute7 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute7 := p_attribute7(i);
     END IF;
     IF p_attribute8 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute8 := p_attribute8(i);
     END IF;
     IF p_attribute9 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute9 := p_attribute9(i);
     END IF;
     IF p_attribute10 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute10 := p_attribute10(i);
     END IF;
     IF p_attribute11 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute11 := p_attribute11(i);
     END IF;
     IF p_attribute12 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute12 := p_attribute12(i);
     END IF;
     IF p_attribute13 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute13 := p_attribute13(i);
     END IF;
     IF p_attribute14 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute14 := p_attribute14(i);
     END IF;
     IF p_attribute15 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute15 := p_attribute15(i);
     END IF;
     IF p_accounting_rule_id IS NOT NULL THEN
      IF p_accounting_rule_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).accounting_rule_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).accounting_rule_id := p_accounting_rule_id(i);
      END IF;
     END IF;
     IF p_ffm_content_name IS NOT NULL THEN
      l_qte_line_tbl(i).ffm_content_name := p_ffm_content_name(i);
     END IF;
     IF p_ffm_content_type IS NOT NULL THEN
      l_qte_line_tbl(i).ffm_content_type := p_ffm_content_type(i);
     END IF;
     IF p_ffm_document_type IS NOT NULL THEN
      l_qte_line_tbl(i).ffm_document_type := p_ffm_document_type(i);
     END IF;
     IF p_ffm_media_id IS NOT NULL THEN
      l_qte_line_tbl(i).ffm_media_id := p_ffm_media_id(i);
     END IF;
     IF p_ffm_media_type IS NOT NULL THEN
      l_qte_line_tbl(i).ffm_media_type := p_ffm_media_type(i);
     END IF;
     IF p_ffm_user_note IS NOT NULL THEN
      l_qte_line_tbl(i).ffm_user_note := p_ffm_user_note(i);
     END IF;
     IF p_invoice_to_party_id IS NOT NULL THEN
      IF p_invoice_to_party_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).invoice_to_party_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).invoice_to_party_id := p_invoice_to_party_id(i);
      END IF;
     END IF;
     IF p_invoice_to_party_site_id IS NOT NULL THEN
      IF p_invoice_to_party_site_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).invoice_to_party_site_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).invoice_to_party_site_id := p_invoice_to_party_site_id(i);
      END IF;
     END IF;
     IF p_invoicing_rule_id IS NOT NULL THEN
      IF p_invoicing_rule_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).invoicing_rule_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).invoicing_rule_id := p_invoicing_rule_id(i);
      END IF;
     END IF;
     IF p_marketing_source_code_id IS NOT NULL THEN
      IF p_marketing_source_code_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).marketing_source_code_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).marketing_source_code_id := p_marketing_source_code_id(i);
      END IF;
     END IF;
     IF p_invoice_to_cust_account_id IS NOT NULL THEN
      IF p_invoice_to_cust_account_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).invoice_to_cust_account_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).invoice_to_cust_account_id := p_invoice_to_cust_account_id(i);
      END IF;
     END IF;
     IF p_pricing_quantity_uom IS NOT NULL THEN
      l_qte_line_tbl(i).pricing_quantity_uom := p_pricing_quantity_uom(i);
     END IF;
     IF p_minisite_id IS NOT NULL THEN
      IF p_minisite_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).minisite_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).minisite_id := p_minisite_id(i);
      END IF;
     END IF;
     IF p_section_id IS NOT NULL THEN
      IF p_section_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).section_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).section_id := p_section_id(i);
      END IF;
     END IF;
     IF p_priced_price_list_id IS NOT NULL THEN
      IF p_priced_price_list_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).priced_price_list_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).priced_price_list_id := p_priced_price_list_id(i);
      END IF;
     END IF;
     IF p_agreement_id IS NOT NULL THEN
      IF p_agreement_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).agreement_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).agreement_id := p_agreement_id(i);
      END IF;
     END IF;
     IF p_commitment_id IS NOT NULL THEN
      IF p_commitment_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).commitment_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).commitment_id := p_commitment_id(i);
      END IF;
     END IF;
     IF p_display_arithmetic_operator IS NOT NULL THEN
      l_qte_line_tbl(i).display_arithmetic_operator := p_display_arithmetic_operator(i);
     END IF;
     IF p_invoice_to_cust_party_id IS NOT NULL THEN
      IF p_invoice_to_cust_party_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).invoice_to_cust_party_id := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).invoice_to_cust_party_id := p_invoice_to_cust_party_id(i);
      END IF;
     END IF;
     IF p_attribute16 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute16 := p_attribute16(i);
     END IF;
     IF p_attribute17 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute17 := p_attribute17(i);
     END IF;
     IF p_attribute18 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute18 := p_attribute18(i);
     END IF;
     IF p_attribute19 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute19 := p_attribute19(i);
     END IF;
     IF p_attribute20 IS NOT NULL THEN
      l_qte_line_tbl(i).attribute20 := p_attribute20(i);
     END IF;
     IF p_object_version_number IS NOT NULL THEN
      IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).object_version_number  := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).object_version_number  := p_object_version_number(i);
      END IF;
     END IF;

      l_qte_line_tbl(i).operation_code := p_operation_code(i);
     IF p_charge_periodicity_code IS NOT NULL THEN
      l_qte_line_tbl(i).charge_periodicity_code := p_charge_periodicity_code(i);
     END IF;

     IF p_end_customer_party_id IS NOT NULL THEN
      IF p_end_customer_party_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).end_customer_party_id  := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).end_customer_party_id  := p_end_customer_party_id(i);
      END IF;
     END IF;

     IF p_end_customer_party_site_id IS NOT NULL THEN
      IF p_end_customer_party_site_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).end_customer_party_site_id  := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).end_customer_party_site_id  := p_end_customer_party_site_id(i);
      END IF;
     END IF;

     IF p_end_customer_cust_account_id IS NOT NULL THEN
      IF p_end_customer_cust_account_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).end_customer_cust_account_id  := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).end_customer_cust_account_id  := p_end_customer_cust_account_id(i);
      END IF;
     END IF;

     IF p_end_customer_cust_party_id IS NOT NULL THEN
      IF p_end_customer_cust_party_id(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).end_customer_cust_party_id  := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).end_customer_cust_party_id  := p_end_customer_cust_party_id(i);
      END IF;
     END IF;


     IF p_line_paynow_charges IS NOT NULL THEN
      IF p_line_paynow_charges(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).line_paynow_charges  := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).line_paynow_charges  := p_line_paynow_charges(i);
      END IF;
     END IF;

     IF p_line_paynow_tax IS NOT NULL THEN
      IF p_line_paynow_tax(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).line_paynow_tax  := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).line_paynow_tax  := p_line_paynow_tax(i);
      END IF;
     END IF;

     IF p_line_paynow_subtotal IS NOT NULL THEN
      IF p_line_paynow_subtotal(i)= ROSETTA_G_MISS_NUM THEN
         l_qte_line_tbl(i).line_paynow_subtotal  := FND_API.G_MISS_NUM;
      ELSE
         l_qte_line_tbl(i).line_paynow_subtotal  := p_line_paynow_subtotal(i);
      END IF;
     END IF;

     IF p_config_model_type  IS NOT NULL THEN
         l_qte_line_tbl(i).config_model_type  := p_config_model_type(i);
     END IF;

     IF p_product_FISC_classification IS NOT NULL THEN
         l_qte_line_tbl(i).product_FISC_classification  := p_product_FISC_classification(i);
     END IF;

     IF p_TRX_business_category IS NOT NULL THEN
        l_qte_line_tbl(i).TRX_business_category  := p_TRX_business_category(i);
     END IF;

   END LOOP;

      RETURN l_qte_line_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_QTE_LINE_TBL;
   END IF;
END Construct_Qte_Line_Tbl;


-- there IS total 71 fields here IN line
FUNCTION Construct_Qte_Line_Dtl_Rec(
   p_quote_line_detail_id     IN NUMBER   := FND_API.G_MISS_NUM,
   p_creation_date            IN DATE     := FND_API.G_MISS_DATE,
   p_created_by               IN NUMBER   := FND_API.G_MISS_NUM,
   p_last_update_date         IN DATE     := FND_API.G_MISS_DATE,
   p_last_updated_by          IN NUMBER   := FND_API.G_MISS_NUM,
   p_last_update_login        IN NUMBER   := FND_API.G_MISS_NUM,
   p_request_id               IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_application_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_id               IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_update_date      IN DATE     := FND_API.G_MISS_DATE,
   p_quote_line_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_config_header_id         IN NUMBER   := FND_API.G_MISS_NUM,
   p_config_revision_num      IN NUMBER   := FND_API.G_MISS_NUM,
   p_config_item_id           IN NUMBER   := FND_API.G_MISS_NUM,
   p_complete_configuration   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_valid_configuration_flag IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_component_code           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_service_coterminate_flag IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_service_duration         IN NUMBER   := FND_API.G_MISS_NUM,
   p_service_period           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_service_unit_selling     IN NUMBER   := FND_API.G_MISS_NUM,
   p_service_unit_list        IN NUMBER   := FND_API.G_MISS_NUM,
   p_service_number           IN NUMBER   := FND_API.G_MISS_NUM,
   p_unit_percent_base_price  IN NUMBER   := FND_API.G_MISS_NUM,
   p_attribute_category       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute1               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute2               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute3               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute4               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute5               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute6               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute7               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute8               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute9               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute10              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute11              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute12              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute13              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute14              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute15              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_service_ref_type_code    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_service_ref_order_number IN NUMBER   := FND_API.G_MISS_NUM,
   p_service_ref_line_number  IN NUMBER   := FND_API.G_MISS_NUM,
   p_service_ref_qte_line_ind IN NUMBER   := FND_API.G_MISS_NUM,
   p_service_ref_line_id      IN NUMBER   := FND_API.G_MISS_NUM,
   p_service_ref_system_id    IN NUMBER   := FND_API.G_MISS_NUM,
   p_service_ref_option_numb  IN NUMBER   := FND_API.G_MISS_NUM,
   p_service_ref_shipment     IN NUMBER   := FND_API.G_MISS_NUM,
   p_return_ref_type          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_ref_header_id     IN NUMBER   := FND_API.G_MISS_NUM,
   p_return_ref_line_id       IN NUMBER   := FND_API.G_MISS_NUM,
   p_return_attribute1        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute2        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute3        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute4        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute5        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute6        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute7        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute8        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute9        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute10       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute11       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute12       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute13       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute14       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_attribute15       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_operation_code           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_qte_line_index           IN NUMBER   := FND_API.G_MISS_NUM,
   p_return_attr_category     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_return_reason_code       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_change_reason_code       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute16              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute17              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute18              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute19              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute20              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_top_model_line_id        IN NUMBER   := FND_API.G_MISS_NUM,
   p_top_model_line_index     IN NUMBER   := FND_API.G_MISS_NUM,
   p_ato_line_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_ato_line_index           IN NUMBER   := FND_API.G_MISS_NUM,
   p_component_sequence_id    IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number    IN NUMBER   := FND_API.G_MISS_NUM

)
RETURN ASO_Quote_Pub.Qte_Line_Dtl_Rec_Type
IS
   l_qte_line_dtl_rec ASO_Quote_Pub.Qte_Line_Dtl_Rec_Type;
BEGIN
         IF p_quote_line_detail_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.quote_line_detail_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.quote_line_detail_id := p_quote_line_detail_id;
         END IF;
         IF p_creation_date= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_line_dtl_rec.creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_line_dtl_rec.creation_date := p_creation_date;
         END IF;
         IF p_created_by= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.created_by := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.created_by := p_created_by;
         END IF;
         IF p_last_update_date= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_line_dtl_rec.last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_line_dtl_rec.last_update_date := p_last_update_date;
         END IF;
         IF p_last_updated_by= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.last_updated_by := p_last_updated_by;
         END IF;
         IF p_last_update_login= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.last_update_login := p_last_update_login;
         END IF;
         IF p_request_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.request_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.request_id := p_request_id;
         END IF;
         IF p_program_application_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.program_application_id := p_program_application_id;
         END IF;
         IF p_program_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.program_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.program_id := p_program_id;
         END IF;
         IF p_program_update_date= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_line_dtl_rec.program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_line_dtl_rec.program_update_date := p_program_update_date;
         END IF;
         IF p_quote_line_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.quote_line_id := p_quote_line_id;
         END IF;
         IF p_config_header_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.config_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.config_header_id := p_config_header_id;
         END IF;
         IF p_config_revision_num= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.config_revision_num := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.config_revision_num := p_config_revision_num;
         END IF;
         IF p_config_item_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.config_item_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.config_item_id := p_config_item_id;
         END IF;
         l_qte_line_dtl_rec.complete_configuration_flag := p_complete_configuration;
         l_qte_line_dtl_rec.valid_configuration_flag := p_valid_configuration_flag;
         l_qte_line_dtl_rec.component_code := p_component_code;
         l_qte_line_dtl_rec.service_coterminate_flag := p_service_coterminate_flag;
         IF p_service_duration= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_duration := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_duration := p_service_duration;
         END IF;
         l_qte_line_dtl_rec.service_period := p_service_period;
         IF p_service_unit_selling= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_unit_selling_percent := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_unit_selling_percent := p_service_unit_selling;
         END IF;
         IF p_service_unit_list= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_unit_list_percent := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_unit_list_percent := p_service_unit_list;
         END IF;
         IF p_service_number= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_number := p_service_number;
         END IF;
         IF p_unit_percent_base_price= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.unit_percent_base_price := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.unit_percent_base_price := p_unit_percent_base_price;
         END IF;
         l_qte_line_dtl_rec.attribute_category := p_attribute_category;
         l_qte_line_dtl_rec.attribute1 := p_attribute1;
         l_qte_line_dtl_rec.attribute2 := p_attribute2;
         l_qte_line_dtl_rec.attribute3 := p_attribute3;
         l_qte_line_dtl_rec.attribute4 := p_attribute4;
         l_qte_line_dtl_rec.attribute5 := p_attribute5;
         l_qte_line_dtl_rec.attribute6 := p_attribute6;
         l_qte_line_dtl_rec.attribute7 := p_attribute7;
         l_qte_line_dtl_rec.attribute8 := p_attribute8;
         l_qte_line_dtl_rec.attribute9 := p_attribute9;
         l_qte_line_dtl_rec.attribute10 := p_attribute10;
         l_qte_line_dtl_rec.attribute11 := p_attribute11;
         l_qte_line_dtl_rec.attribute12 := p_attribute12;
         l_qte_line_dtl_rec.attribute13 := p_attribute13;
         l_qte_line_dtl_rec.attribute14 := p_attribute14;
         l_qte_line_dtl_rec.attribute15 := p_attribute15;
         l_qte_line_dtl_rec.service_ref_type_code := p_service_ref_type_code;
         IF p_service_ref_order_number= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_ref_order_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_ref_order_number := p_service_ref_order_number;
         END IF;
         IF p_service_ref_line_number= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_ref_line_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_ref_line_number := p_service_ref_line_number;
         END IF;
         IF p_service_ref_qte_line_ind= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_ref_qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_ref_qte_line_index := p_service_ref_qte_line_ind;
         END IF;
         IF p_service_ref_line_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_ref_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_ref_line_id := p_service_ref_line_id;
         END IF;
         IF p_service_ref_system_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_ref_system_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_ref_system_id := p_service_ref_system_id;
         END IF;
         IF p_service_ref_option_numb= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_ref_option_numb := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_ref_option_numb := p_service_ref_option_numb;
         END IF;
         IF p_service_ref_shipment= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.service_ref_shipment_numb := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.service_ref_shipment_numb := p_service_ref_shipment;
         END IF;
         l_qte_line_dtl_rec.return_ref_type := p_return_ref_type;
         IF p_return_ref_header_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.return_ref_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.return_ref_header_id := p_return_ref_header_id;
         END IF;
         IF p_return_ref_line_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.return_ref_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.return_ref_line_id := p_return_ref_line_id;
         END IF;
         l_qte_line_dtl_rec.return_attribute1 := p_return_attribute1;
         l_qte_line_dtl_rec.return_attribute2 := p_return_attribute2;
         l_qte_line_dtl_rec.return_attribute3 := p_return_attribute3;
         l_qte_line_dtl_rec.return_attribute4 := p_return_attribute4;
         l_qte_line_dtl_rec.return_attribute5 := p_return_attribute5;
         l_qte_line_dtl_rec.return_attribute6 := p_return_attribute6;
         l_qte_line_dtl_rec.return_attribute7 := p_return_attribute7;
         l_qte_line_dtl_rec.return_attribute8 := p_return_attribute8;
         l_qte_line_dtl_rec.return_attribute9 := p_return_attribute9;
         l_qte_line_dtl_rec.return_attribute10 := p_return_attribute10;
         l_qte_line_dtl_rec.return_attribute11 := p_return_attribute11;
         l_qte_line_dtl_rec.return_attribute12 := p_return_attribute12;
         l_qte_line_dtl_rec.return_attribute13 := p_return_attribute13;
         l_qte_line_dtl_rec.return_attribute14 := p_return_attribute14;
         l_qte_line_dtl_rec.return_attribute15 := p_return_attribute15;
         l_qte_line_dtl_rec.operation_code := p_operation_code;
         IF p_qte_line_index= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.qte_line_index := p_qte_line_index;
         END IF;
         l_qte_line_dtl_rec.return_attribute_category := p_return_attr_category;
         l_qte_line_dtl_rec.return_reason_code := p_return_reason_code;
         l_qte_line_dtl_rec.change_reason_code := p_change_reason_code;
         l_qte_line_dtl_rec.attribute16 := p_attribute16;
         l_qte_line_dtl_rec.attribute17 := p_attribute17;
         l_qte_line_dtl_rec.attribute18 := p_attribute18;
         l_qte_line_dtl_rec.attribute19 := p_attribute19;
         l_qte_line_dtl_rec.attribute20 := p_attribute20;
         IF p_top_model_line_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.top_model_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.top_model_line_id := p_top_model_line_id;
         END IF;
         IF p_top_model_line_index= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.top_model_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.top_model_line_index := p_top_model_line_index;
         END IF;
         IF p_ato_line_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.ato_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.ato_line_id := p_ato_line_id;
         END IF;
         IF p_ato_line_index= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.ato_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.ato_line_index := p_ato_line_index;
         END IF;
         IF p_component_sequence_id= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.component_sequence_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.component_sequence_id := p_component_sequence_id;
         END IF;
         IF p_object_version_number = ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_rec.object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_rec.object_version_number := p_object_version_number;
         END IF;

      RETURN l_qte_line_dtl_rec;
END Construct_Qte_Line_Dtl_Rec;

-- there IS total 71 fields here IN line
FUNCTION Construct_Qte_Line_Dtl_Tbl(
   p_quote_line_detail_id     IN jtf_number_table        := NULL,
   p_creation_date            IN jtf_date_table          := NULL,
   p_created_by               IN jtf_number_table        := NULL,
   p_last_update_date         IN jtf_date_table          := NULL,
   p_last_updated_by          IN jtf_number_table        := NULL,
   p_last_update_login        IN jtf_number_table        := NULL,
   p_request_id               IN jtf_number_table        := NULL,
   p_program_application_id   IN jtf_number_table        := NULL,
   p_program_id               IN jtf_number_table        := NULL,
   p_program_update_date      IN jtf_date_table          := NULL,
   p_quote_line_id            IN jtf_number_table        := NULL,
   p_config_header_id         IN jtf_number_table        := NULL,
   p_config_revision_num      IN jtf_number_table        := NULL,
   p_config_item_id           IN jtf_number_table        := NULL,
   p_complete_configuration   IN jtf_varchar2_table_100  := NULL,
   p_valid_configuration_flag IN jtf_varchar2_table_100  := NULL,
   p_component_code           IN jtf_varchar2_table_1200 := NULL,
   p_service_coterminate_flag IN jtf_varchar2_table_100  := NULL,
   p_service_duration         IN jtf_number_table        := NULL,
   p_service_period           IN jtf_varchar2_table_100  := NULL,
   p_service_unit_selling     IN jtf_number_table        := NULL,
   p_service_unit_list        IN jtf_number_table        := NULL,
   p_service_number           IN jtf_number_table        := NULL,
   p_unit_percent_base_price  IN jtf_number_table        := NULL,
   p_attribute_category       IN jtf_varchar2_table_100  := NULL,
   p_attribute1               IN jtf_varchar2_table_300  := NULL,
   p_attribute2               IN jtf_varchar2_table_300  := NULL,
   p_attribute3               IN jtf_varchar2_table_300  := NULL,
   p_attribute4               IN jtf_varchar2_table_300  := NULL,
   p_attribute5               IN jtf_varchar2_table_300  := NULL,
   p_attribute6               IN jtf_varchar2_table_300  := NULL,
   p_attribute7               IN jtf_varchar2_table_300  := NULL,
   p_attribute8               IN jtf_varchar2_table_300  := NULL,
   p_attribute9               IN jtf_varchar2_table_300  := NULL,
   p_attribute10              IN jtf_varchar2_table_300  := NULL,
   p_attribute11              IN jtf_varchar2_table_300  := NULL,
   p_attribute12              IN jtf_varchar2_table_300  := NULL,
   p_attribute13              IN jtf_varchar2_table_300  := NULL,
   p_attribute14              IN jtf_varchar2_table_300  := NULL,
   p_attribute15              IN jtf_varchar2_table_300  := NULL,
   p_service_ref_type_code    IN jtf_varchar2_table_100  := NULL,
   p_service_ref_order_number IN jtf_number_table        := NULL,
   p_service_ref_line_number  IN jtf_number_table        := NULL,
   p_service_ref_qte_line_ind IN jtf_number_table        := NULL,
   p_service_ref_line_id      IN jtf_number_table        := NULL,
   p_service_ref_system_id    IN jtf_number_table        := NULL,
   p_service_ref_option_numb  IN jtf_number_table        := NULL,
   p_service_ref_shipment     IN jtf_number_table        := NULL,
   p_return_ref_type          IN jtf_varchar2_table_100  := NULL,
   p_return_ref_header_id     IN jtf_number_table        := NULL,
   p_return_ref_line_id       IN jtf_number_table        := NULL,
   p_return_attribute1        IN jtf_varchar2_table_300  := NULL,
   p_return_attribute2        IN jtf_varchar2_table_300  := NULL,
   p_return_attribute3        IN jtf_varchar2_table_300  := NULL,
   p_return_attribute4        IN jtf_varchar2_table_300  := NULL,
   p_return_attribute5        IN jtf_varchar2_table_300  := NULL,
   p_return_attribute6        IN jtf_varchar2_table_300  := NULL,
   p_return_attribute7        IN jtf_varchar2_table_300  := NULL,
   p_return_attribute8        IN jtf_varchar2_table_300  := NULL,
   p_return_attribute9        IN jtf_varchar2_table_300  := NULL,
   p_return_attribute10       IN jtf_varchar2_table_300  := NULL,
   p_return_attribute11       IN jtf_varchar2_table_300  := NULL,
   p_return_attribute12       IN jtf_varchar2_table_300  := NULL,
   p_return_attribute13       IN jtf_varchar2_table_300  := NULL,
   p_return_attribute14       IN jtf_varchar2_table_300  := NULL,
   p_return_attribute15       IN jtf_varchar2_table_300  := NULL,
   p_operation_code           IN jtf_varchar2_table_100  := NULL,
   p_qte_line_index           IN jtf_number_table        := NULL,
   p_return_attr_category     IN jtf_varchar2_table_100  := NULL,
   p_return_reason_code       IN jtf_varchar2_table_100  := NULL,
   p_change_reason_code       IN jtf_varchar2_table_100  := NULL,
   p_attribute16              IN jtf_varchar2_table_300  := NULL,
   p_attribute17              IN jtf_varchar2_table_300  := NULL,
   p_attribute18              IN jtf_varchar2_table_300  := NULL,
   p_attribute19              IN jtf_varchar2_table_300  := NULL,
   p_attribute20              IN jtf_varchar2_table_300  := NULL,
   p_top_model_line_id        IN jtf_number_table        := NULL,
   p_top_model_line_index     IN jtf_number_table        := NULL,
   p_ato_line_id              IN jtf_number_table        := NULL,
   p_ato_line_index           IN jtf_number_table        := NULL,
   p_component_sequence_id    IN jtf_number_table        := NULL,
   p_object_version_number    IN jtf_number_table        := NULL

)
RETURN ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
IS
   l_qte_line_dtl_tbl ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
   l_table_size       PLS_INTEGER := 0;
   i                  PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN

      FOR i IN 1..l_table_size LOOP
        IF p_quote_line_detail_id IS NOT NULL THEN
         IF p_quote_line_detail_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).quote_line_detail_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).quote_line_detail_id := p_quote_line_detail_id(i);
         END IF;
        END IF;
        IF p_creation_date IS NOT NULL THEN
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_line_dtl_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_line_dtl_tbl(i).creation_date := p_creation_date(i);
         END IF;
        END IF;
        IF p_created_by IS NOT NULL THEN
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).created_by := p_created_by(i);
         END IF;
        END IF;
        IF p_last_update_date IS NOT NULL THEN
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_line_dtl_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_line_dtl_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
        END IF;
        IF p_last_updated_by IS NOT NULL THEN
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
        END IF;
        IF p_last_update_login IS NOT NULL THEN
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
        END IF;
        IF p_request_id IS NOT NULL THEN
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).request_id := p_request_id(i);
         END IF;
        END IF;
        IF p_program_application_id IS NOT NULL THEN
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
        END IF;
        IF p_program_id IS NOT NULL THEN
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).program_id := p_program_id(i);
         END IF;
        END IF;
        IF p_program_update_date IS NOT NULL THEN
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_line_dtl_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_line_dtl_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
        END IF;
        IF p_quote_line_id IS NOT NULL THEN
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
        END IF;
        IF p_config_header_id IS NOT NULL THEN
         IF p_config_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).config_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).config_header_id := p_config_header_id(i);
         END IF;
        END IF;
        IF p_config_revision_num IS NOT NULL THEN
         IF p_config_revision_num(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).config_revision_num := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).config_revision_num := p_config_revision_num(i);
         END IF;
        END IF;
        IF p_config_item_id IS NOT NULL THEN
         IF p_config_item_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).config_item_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).config_item_id := p_config_item_id(i);
         END IF;
        END IF;
        IF p_complete_configuration IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).complete_configuration_flag := p_complete_configuration(i);
        END IF;
        IF p_valid_configuration_flag IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).valid_configuration_flag := p_valid_configuration_flag(i);
        END IF;
        IF p_component_code IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).component_code := p_component_code(i);
        END IF;
        IF p_service_coterminate_flag IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).service_coterminate_flag := p_service_coterminate_flag(i);
        END IF;
        IF p_service_duration IS NOT NULL THEN
         IF p_service_duration(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_duration := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_duration := p_service_duration(i);
         END IF;
        END IF;
        IF p_service_period IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).service_period := p_service_period(i);
        END IF;
        IF p_service_unit_selling IS NOT NULL THEN
         IF p_service_unit_selling(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_unit_selling_percent := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_unit_selling_percent := p_service_unit_selling(i);
         END IF;
        END IF;
        IF p_service_unit_list IS NOT NULL THEN
         IF p_service_unit_list(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_unit_list_percent := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_unit_list_percent := p_service_unit_list(i);
         END IF;
        END IF;
        IF p_service_number IS NOT NULL THEN
         IF p_service_number(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_number := p_service_number(i);
         END IF;
        END IF;
        IF p_unit_percent_base_price IS NOT NULL THEN
         IF p_unit_percent_base_price(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).unit_percent_base_price := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).unit_percent_base_price := p_unit_percent_base_price(i);
         END IF;
        END IF;
        IF p_attribute_category IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute_category := p_attribute_category(i);
        END IF;
        IF p_attribute1 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute1 := p_attribute1(i);
        END IF;
        IF p_attribute2 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute2 := p_attribute2(i);
        END IF;
        IF p_attribute3 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute3 := p_attribute3(i);
        END IF;
        IF p_attribute4 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute4 := p_attribute4(i);
        END IF;
        IF p_attribute5 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute5 := p_attribute5(i);
        END IF;
        IF p_attribute6 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute6 := p_attribute6(i);
        END IF;
        IF p_attribute7 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute7 := p_attribute7(i);
        END IF;
        IF p_attribute8 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute8 := p_attribute8(i);
        END IF;
        IF p_attribute9 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute9 := p_attribute9(i);
        END IF;
        IF p_attribute10 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute10 := p_attribute10(i);
        END IF;
        IF p_attribute11 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute11 := p_attribute11(i);
        END IF;
        IF p_attribute12 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute12 := p_attribute12(i);
        END IF;
        IF p_attribute13 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute13 := p_attribute13(i);
        END IF;
        IF p_attribute14 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute14 := p_attribute14(i);
        END IF;
        IF p_attribute15 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute15 := p_attribute15(i);
        END IF;
        IF p_service_ref_type_code IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).service_ref_type_code := p_service_ref_type_code(i);
        END IF;
        IF p_service_ref_order_number IS NOT NULL THEN
         IF p_service_ref_order_number(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_order_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_order_number := p_service_ref_order_number(i);
         END IF;
        END IF;
        IF p_service_ref_line_number IS NOT NULL THEN
         IF p_service_ref_line_number(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_line_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_line_number := p_service_ref_line_number(i);
         END IF;
        END IF;
        IF p_service_ref_qte_line_ind IS NOT NULL THEN
         IF p_service_ref_qte_line_ind(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_qte_line_index := p_service_ref_qte_line_ind(i);
         END IF;
        END IF;
        IF p_service_ref_line_id IS NOT NULL THEN
         IF p_service_ref_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_line_id := p_service_ref_line_id(i);
         END IF;
        END IF;
        IF p_service_ref_system_id IS NOT NULL THEN
         IF p_service_ref_system_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_system_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_system_id := p_service_ref_system_id(i);
         END IF;
        END IF;
        IF p_service_ref_option_numb IS NOT NULL THEN
         IF p_service_ref_option_numb(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_option_numb := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_option_numb := p_service_ref_option_numb(i);
         END IF;
        END IF;
        IF p_service_ref_shipment IS NOT NULL THEN
         IF p_service_ref_shipment(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_shipment_numb := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_shipment_numb := p_service_ref_shipment(i);
         END IF;
        END IF;
        IF p_return_ref_type IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_ref_type := p_return_ref_type(i);
        END IF;
        IF p_return_ref_header_id IS NOT NULL THEN
         IF p_return_ref_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).return_ref_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).return_ref_header_id := p_return_ref_header_id(i);
         END IF;
        END IF;
        IF p_return_ref_line_id IS NOT NULL THEN
         IF p_return_ref_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).return_ref_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).return_ref_line_id := p_return_ref_line_id(i);
         END IF;
        END IF;
        IF p_return_attribute1 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute1 := p_return_attribute1(i);
        END IF;
        IF p_return_attribute2 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute2 := p_return_attribute2(i);
        END IF;
        IF p_return_attribute3 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute3 := p_return_attribute3(i);
        END IF;
        IF p_return_attribute4 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute4 := p_return_attribute4(i);
        END IF;
        IF p_return_attribute5 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute5 := p_return_attribute5(i);
        END IF;
        IF p_return_attribute6 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute6 := p_return_attribute6(i);
        END IF;
        IF p_return_attribute7 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute7 := p_return_attribute7(i);
        END IF;
        IF p_return_attribute8 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute8 := p_return_attribute8(i);
        END IF;
        IF p_return_attribute9 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute9 := p_return_attribute9(i);
        END IF;
        IF p_return_attribute10 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute10 := p_return_attribute10(i);
        END IF;
        IF p_return_attribute11 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute11 := p_return_attribute11(i);
        END IF;
        IF p_return_attribute12 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute12 := p_return_attribute12(i);
        END IF;
        IF p_return_attribute13 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute13 := p_return_attribute13(i);
        END IF;
        IF p_return_attribute14 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute14 := p_return_attribute14(i);
        END IF;
        IF p_return_attribute15 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute15 := p_return_attribute15(i);
        END IF;
        -- IF p_operation_code IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).operation_code := p_operation_code(i);
        -- END IF;
        IF p_qte_line_index IS NOT NULL THEN
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
        END IF;
        IF p_return_attr_category IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_attribute_category := p_return_attr_category(i);
        END IF;
        IF p_return_reason_code IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).return_reason_code := p_return_reason_code(i);
        END IF;
        IF p_change_reason_code IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).change_reason_code := p_change_reason_code(i);
        END IF;
        IF p_attribute16 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute16 := p_attribute16(i);
        END IF;
        IF p_attribute17 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute17 := p_attribute17(i);
        END IF;
        IF p_attribute18 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute18 := p_attribute18(i);
        END IF;
        IF p_attribute19 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute19 := p_attribute19(i);
        END IF;
        IF p_attribute20 IS NOT NULL THEN
         l_qte_line_dtl_tbl(i).attribute20 := p_attribute20(i);
        END IF;
        IF p_top_model_line_id IS NOT NULL THEN
         IF p_top_model_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).top_model_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).top_model_line_id := p_top_model_line_id(i);
         END IF;
        END IF;
        IF p_top_model_line_index IS NOT NULL THEN
         IF p_top_model_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).top_model_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).top_model_line_index := p_top_model_line_index(i);
         END IF;
        END IF;

        IF p_ato_line_id IS NOT NULL THEN
         IF p_ato_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).ato_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).ato_line_id := p_ato_line_id(i);
         END IF;
        END IF;
        IF p_ato_line_index IS NOT NULL THEN
         IF p_ato_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).ato_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).ato_line_index := p_ato_line_index(i);
         END IF;
        END IF;

        IF p_component_sequence_id IS NOT NULL THEN
         IF p_component_sequence_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).component_sequence_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).component_sequence_id := p_component_sequence_id(i);
         END IF;
        END IF;

        IF p_object_version_number IS NOT NULL THEN
         IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).object_version_number := p_object_version_number(i);
         END IF;
        END IF;

      END LOOP;

      RETURN l_qte_line_dtl_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL;
   END IF;
END Construct_Qte_Line_Dtl_Tbl;


-- there IS total 17 fields here IN line
FUNCTION Construct_Line_Rltship_Tbl(
   p_line_relationship_id   IN jtf_number_table       := NULL,
   p_creation_date          IN jtf_date_table         := NULL,
   p_created_by             IN jtf_number_table       := NULL,
   p_last_updated_by        IN jtf_number_table       := NULL,
   p_last_update_date       IN jtf_date_table         := NULL,
   p_last_update_login      IN jtf_number_table       := NULL,
   p_request_id             IN jtf_number_table       := NULL,
   p_program_application_id IN jtf_number_table       := NULL,
   p_program_id             IN jtf_number_table       := NULL,
   p_program_update_date    IN jtf_date_table         := NULL,
   p_quote_line_id          IN jtf_number_table       := NULL,
   p_related_quote_line_id  IN jtf_number_table       := NULL,
   p_relationship_type_code IN jtf_varchar2_table_100 := NULL,
   p_reciprocal_flag        IN jtf_varchar2_table_100 := NULL,
   p_qte_line_index         IN jtf_number_table       := NULL,
   p_related_qte_line_index IN jtf_number_table       := NULL,
   p_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_object_version_number  IN jtf_number_table       := NULL
)
RETURN ASO_Quote_Pub.Line_Rltship_Tbl_Type
IS
   l_line_rltship_tbl ASO_Quote_Pub.Line_Rltship_Tbl_Type;
   l_table_size       PLS_INTEGER := 0;
   i                  PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
        IF p_line_relationship_id IS NOT NULL THEN
         IF p_line_relationship_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).line_relationship_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).line_relationship_id := p_line_relationship_id(i);
         END IF;
        END IF;
        IF p_creation_date IS NOT NULL THEN
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_rltship_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_line_rltship_tbl(i).creation_date := p_creation_date(i);
         END IF;
        END IF;
        IF p_created_by IS NOT NULL THEN
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).created_by := p_created_by(i);
         END IF;
        END IF;
        IF p_last_updated_by IS NOT NULL THEN
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
        END IF;
        IF p_last_update_date IS NOT NULL THEN
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_rltship_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_line_rltship_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
        END IF;
        IF p_last_update_login IS NOT NULL THEN
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
        END IF;
        IF p_request_id IS NOT NULL THEN
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).request_id := p_request_id(i);
         END IF;
        END IF;
        IF p_program_application_id IS NOT NULL THEN
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
        END IF;
        IF p_program_id IS NOT NULL THEN
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).program_id := p_program_id(i);
         END IF;
        END IF;
        IF p_program_update_date IS NOT NULL THEN
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_rltship_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_line_rltship_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
        END IF;
        IF p_quote_line_id IS NOT NULL THEN
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
        END IF;
        IF p_related_quote_line_id IS NOT NULL THEN
         IF p_related_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).related_quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).related_quote_line_id := p_related_quote_line_id(i);
         END IF;
        END IF;
        IF p_relationship_type_code IS NOT NULL THEN
         l_line_rltship_tbl(i).relationship_type_code := p_relationship_type_code(i);
        END IF;
        IF p_reciprocal_flag IS NOT NULL THEN
         l_line_rltship_tbl(i).reciprocal_flag := p_reciprocal_flag(i);
        END IF;
        IF p_qte_line_index IS NOT NULL THEN
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
        END IF;
        IF p_related_qte_line_index IS NOT NULL THEN
         IF p_related_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).related_qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).related_qte_line_index := p_related_qte_line_index(i);
         END IF;
        END IF;
        IF p_object_version_number IS NOT NULL THEN
         IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).object_version_number := p_object_version_number(i);
         END IF;
        END IF;
        -- IF p_operation_code IS NOT NULL THEN
         l_line_rltship_tbl(i).operation_code := p_operation_code(i);
        -- END IF;
      END LOOP;

      RETURN l_line_rltship_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_LINE_RLTSHIP_TBL;
   END IF;
END Construct_Line_Rltship_Tbl;


-- there IS total 43 fields here IN line
FUNCTION Construct_Payment_Tbl(
   p_operation_code            IN  jtf_varchar2_table_100 := NULL,
   p_qte_line_index            IN  jtf_number_table := NULL,
   p_payment_id                IN  jtf_number_table := NULL,
   p_creation_date             IN  jtf_date_table   := NULL,
   p_created_by                IN  jtf_number_table := NULL,
   p_last_update_date          IN  jtf_date_table   := NULL,
   p_last_updated_by           IN  jtf_number_table := NULL,
   p_last_update_login         IN  jtf_number_table := NULL,
   p_request_id                IN  jtf_number_table := NULL,
   p_program_application_id    IN  jtf_number_table := NULL,
   p_program_id                IN  jtf_number_table := NULL,
   p_program_update_date       IN  jtf_date_table   := NULL,
   p_quote_header_id           IN  jtf_number_table := NULL,
   p_quote_line_id             IN  jtf_number_table := NULL,
   p_payment_type_code         IN  jtf_varchar2_table_100 := NULL,
   p_payment_ref_number        IN  jtf_varchar2_table_300 := NULL,
   p_payment_option            IN  jtf_varchar2_table_300 := NULL,
   p_payment_term_id           IN  jtf_number_table := NULL,
   p_credit_card_code          IN  jtf_varchar2_table_100 := NULL,
   p_credit_card_holder_name   IN  jtf_varchar2_table_100 := NULL,
   p_credit_card_exp_date      IN  jtf_date_table   := NULL,
   p_credit_card_approval_code IN  jtf_varchar2_table_100 := NULL,
   p_credit_card_approval_date IN  jtf_date_table   := NULL,
   p_payment_amount            IN  jtf_number_table := NULL,
   p_attribute_category        IN  jtf_varchar2_table_100 := NULL,
   p_attribute1                IN  jtf_varchar2_table_300 := NULL,
   p_attribute2                IN  jtf_varchar2_table_300 := NULL,
   p_attribute3                IN  jtf_varchar2_table_300 := NULL,
   p_attribute4                IN  jtf_varchar2_table_300 := NULL,
   p_attribute5                IN  jtf_varchar2_table_300 := NULL,
   p_attribute6                IN  jtf_varchar2_table_300 := NULL,
   p_attribute7                IN  jtf_varchar2_table_300 := NULL,
   p_attribute8                IN  jtf_varchar2_table_300 := NULL,
   p_attribute9                IN  jtf_varchar2_table_300 := NULL,
   p_attribute10               IN  jtf_varchar2_table_300 := NULL,
   p_attribute11               IN  jtf_varchar2_table_300 := NULL,
   p_attribute12               IN  jtf_varchar2_table_300 := NULL,
   p_attribute13               IN  jtf_varchar2_table_300 := NULL,
   p_attribute14               IN  jtf_varchar2_table_300 := NULL,
   p_attribute15               IN  jtf_varchar2_table_300 := NULL,
   p_shipment_index            IN  jtf_number_table := NULL,
   p_quote_shipment_id         IN  jtf_number_table := NULL,
   p_cust_po_number            IN  jtf_varchar2_table_100 := NULL,
   p_cust_po_line_number       IN  jtf_varchar2_table_100 := NULL,
   p_attribute16               IN  jtf_varchar2_table_300 := NULL,
   p_attribute17               IN  jtf_varchar2_table_300 := NULL,
   p_attribute18               IN  jtf_varchar2_table_300 := NULL,
   p_attribute19               IN  jtf_varchar2_table_300 := NULL,
   p_attribute20               IN  jtf_varchar2_table_300 := NULL,
   p_trxn_extension_id         IN  jtf_number_table       := NULL,
   p_instrument_id             IN  jtf_number_table := NULL,
   p_instr_assignment_id       IN  jtf_number_table := NULL,
   p_cvv2                      IN  jtf_varchar2_table_100 := NULL,
   p_object_version_number     IN  jtf_number_table       := NULL

)
RETURN ASO_Quote_Pub.Payment_Tbl_Type
IS
   l_payment_tbl ASO_Quote_Pub.Payment_Tbl_Type;
   l_table_size  PLS_INTEGER := 0;
   i             PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
        -- IF p_operation_code IS NOT NULL THEN
         l_payment_tbl(i).operation_code := p_operation_code(i);
        -- END IF;
        IF p_qte_line_index IS NOT NULL THEN
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
        END IF;
        IF p_payment_id IS NOT NULL THEN
         IF p_payment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).payment_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).payment_id := p_payment_id(i);
         END IF;
        END IF;
        IF p_creation_date IS NOT NULL THEN
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_tbl(i).creation_date := p_creation_date(i);
         END IF;
        END IF;
        IF p_created_by IS NOT NULL THEN
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).created_by := p_created_by(i);
         END IF;
        END IF;
        IF p_last_update_date IS NOT NULL THEN
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
        END IF;
        IF p_last_updated_by IS NOT NULL THEN
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
        END IF;
        IF p_last_update_login IS NOT NULL THEN
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
        END IF;
        IF p_request_id IS NOT NULL THEN
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).request_id := p_request_id(i);
         END IF;
        END IF;
        IF p_program_application_id IS NOT NULL THEN
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
        END IF;
        IF p_program_id IS NOT NULL THEN
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).program_id := p_program_id(i);
         END IF;
        END IF;
        IF p_program_update_date IS NOT NULL THEN
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
        END IF;
        IF p_quote_header_id IS NOT NULL THEN
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
        END IF;
        IF p_quote_line_id IS NOT NULL THEN
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
        END IF;
        IF p_payment_type_code IS NOT NULL THEN
         l_payment_tbl(i).payment_type_code := p_payment_type_code(i);
        END IF;
        IF p_payment_ref_number IS NOT NULL THEN
         l_payment_tbl(i).payment_ref_number := p_payment_ref_number(i);
        END IF;
        IF p_payment_option IS NOT NULL THEN
         l_payment_tbl(i).payment_option := p_payment_option(i);
        END IF;
        IF p_payment_term_id IS NOT NULL THEN
         IF p_payment_term_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).payment_term_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).payment_term_id := p_payment_term_id(i);
         END IF;
        END IF;
        IF p_credit_card_code IS NOT NULL THEN
         l_payment_tbl(i).credit_card_code := p_credit_card_code(i);
        END IF;
        IF p_credit_card_holder_name IS NOT NULL THEN
         l_payment_tbl(i).credit_card_holder_name := p_credit_card_holder_name(i);
        END IF;
        IF p_credit_card_exp_date IS NOT NULL THEN
         IF p_credit_card_exp_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_tbl(i).credit_card_expiration_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_tbl(i).credit_card_expiration_date := p_credit_card_exp_date(i);
         END IF;
        END IF;
        IF p_credit_card_approval_code IS NOT NULL THEN
         l_payment_tbl(i).credit_card_approval_code := p_credit_card_approval_code(i);
        END IF;
        IF p_credit_card_approval_date IS NOT NULL THEN
         IF p_credit_card_approval_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_tbl(i).credit_card_approval_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_tbl(i).credit_card_approval_date := p_credit_card_approval_date(i);
         END IF;
        END IF;
        IF p_payment_amount IS NOT NULL THEN
         IF p_payment_amount(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).payment_amount := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).payment_amount := p_payment_amount(i);
         END IF;
        END IF;
        IF p_attribute_category IS NOT NULL THEN
         l_payment_tbl(i).attribute_category := p_attribute_category(i);
        END IF;
        IF p_attribute1 IS NOT NULL THEN
         l_payment_tbl(i).attribute1 := p_attribute1(i);
        END IF;
        IF p_attribute2 IS NOT NULL THEN
         l_payment_tbl(i).attribute2 := p_attribute2(i);
        END IF;
        IF p_attribute3 IS NOT NULL THEN
         l_payment_tbl(i).attribute3 := p_attribute3(i);
        END IF;
        IF p_attribute4 IS NOT NULL THEN
         l_payment_tbl(i).attribute4 := p_attribute4(i);
        END IF;
        IF p_attribute5 IS NOT NULL THEN
         l_payment_tbl(i).attribute5 := p_attribute5(i);
        END IF;
        IF p_attribute6 IS NOT NULL THEN
         l_payment_tbl(i).attribute6 := p_attribute6(i);
        END IF;
        IF p_attribute7 IS NOT NULL THEN
         l_payment_tbl(i).attribute7 := p_attribute7(i);
        END IF;
        IF p_attribute8 IS NOT NULL THEN
         l_payment_tbl(i).attribute8 := p_attribute8(i);
        END IF;
        IF p_attribute9 IS NOT NULL THEN
         l_payment_tbl(i).attribute9 := p_attribute9(i);
        END IF;
        IF p_attribute10 IS NOT NULL THEN
         l_payment_tbl(i).attribute10 := p_attribute10(i);
        END IF;
        IF p_attribute11 IS NOT NULL THEN
         l_payment_tbl(i).attribute11 := p_attribute11(i);
        END IF;
        IF p_attribute12 IS NOT NULL THEN
         l_payment_tbl(i).attribute12 := p_attribute12(i);
        END IF;
        IF p_attribute13 IS NOT NULL THEN
         l_payment_tbl(i).attribute13 := p_attribute13(i);
        END IF;
        IF p_attribute14 IS NOT NULL THEN
         l_payment_tbl(i).attribute14 := p_attribute14(i);
        END IF;
        IF p_attribute15 IS NOT NULL THEN
         l_payment_tbl(i).attribute15 := p_attribute15(i);
        END IF;
        IF p_shipment_index IS NOT NULL THEN
         IF p_shipment_index(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).shipment_index := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).shipment_index := p_shipment_index(i);
         END IF;
        END IF;
        IF p_quote_shipment_id IS NOT NULL THEN
         IF p_quote_shipment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).quote_shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).quote_shipment_id := p_quote_shipment_id(i);
         END IF;
        END IF;

        IF p_cust_po_number IS NOT NULL THEN
         l_payment_tbl(i).cust_po_number := p_cust_po_number(i);
        END IF;

        IF p_cust_po_line_number IS NOT NULL THEN
            l_payment_tbl(i).cust_po_line_number := p_cust_po_line_number(i);
        END IF;

        IF p_attribute16 IS NOT NULL THEN
         l_payment_tbl(i).attribute16 := p_attribute16(i);
        END IF;
        IF p_attribute17 IS NOT NULL THEN
         l_payment_tbl(i).attribute17 := p_attribute17(i);
        END IF;
        IF p_attribute18 IS NOT NULL THEN
         l_payment_tbl(i).attribute18 := p_attribute18(i);
        END IF;
        IF p_attribute19 IS NOT NULL THEN
         l_payment_tbl(i).attribute19 := p_attribute19(i);
        END IF;
        IF p_attribute20 IS NOT NULL THEN
         l_payment_tbl(i).attribute20 := p_attribute20(i);
        END IF;

        IF p_object_version_number IS NOT NULL THEN
         IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).object_version_number := p_object_version_number(i);
         END IF;
        END IF;

        IF p_trxn_extension_id IS NOT NULL THEN
         IF p_trxn_extension_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).trxn_extension_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).trxn_extension_id := p_trxn_extension_id(i);
         END IF;
        END IF;

        IF p_instrument_id IS NOT NULL THEN
         IF p_instrument_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).instrument_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).instrument_id := p_instrument_id(i);
         END IF;
        END IF;

        IF p_instr_assignment_id IS NOT NULL THEN
         IF p_instr_assignment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_payment_tbl(i).instr_assignment_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_tbl(i).instr_assignment_id := p_instr_assignment_id(i);
         END IF;
        END IF;

        IF p_cvv2 IS NOT NULL THEN
         l_payment_tbl(i).cvv2 := p_cvv2(i);
        END IF;


      END LOOP;

      RETURN l_payment_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_PAYMENT_TBL;
   END IF;
END Construct_Payment_Tbl;

FUNCTION Construct_Payment_Rec(
   p_operation_code            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_qte_line_index            IN NUMBER        := FND_API.G_MISS_NUM,
   p_payment_id                IN NUMBER        := FND_API.G_MISS_NUM,
   p_creation_date             IN DATE          := FND_API.G_MISS_DATE,
   p_created_by                IN NUMBER        := FND_API.G_MISS_NUM,
   p_last_update_date          IN DATE          := FND_API.G_MISS_DATE,
   p_last_updated_by           IN NUMBER        := FND_API.G_MISS_NUM,
   p_last_update_login         IN NUMBER        := FND_API.G_MISS_NUM,
   p_request_id                IN NUMBER        := FND_API.G_MISS_NUM,
   p_program_application_id    IN NUMBER        := FND_API.G_MISS_NUM,
   p_program_id                IN NUMBER        := FND_API.G_MISS_NUM,
   p_program_update_date       IN DATE          := FND_API.G_MISS_DATE,
   p_quote_header_id           IN NUMBER        := FND_API.G_MISS_NUM,
   p_quote_line_id             IN NUMBER        := FND_API.G_MISS_NUM,
   p_payment_type_code         IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_payment_ref_number        IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_payment_option            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_payment_term_id           IN NUMBER        := FND_API.G_MISS_NUM,
   p_credit_card_code          IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_credit_card_holder_name   IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_credit_card_exp_date      IN DATE          := FND_API.G_MISS_DATE,
   p_credit_card_approval_code IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_credit_card_approval_date IN DATE          := FND_API.G_MISS_DATE,
   p_payment_amount            IN NUMBER        := FND_API.G_MISS_NUM,
   p_attribute_category        IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute1                IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute2                IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute3                IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute4                IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute5                IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute6                IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute7                IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute8                IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute9                IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute10               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute11               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute12               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute13               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute14               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute15               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_shipment_index            IN NUMBER        := FND_API.G_MISS_NUM,
   p_quote_shipment_id         IN NUMBER        := FND_API.G_MISS_NUM,
   p_cust_po_number            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_cust_po_line_number       IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute16               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute17               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute18               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute19               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute20               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_object_version_number     IN NUMBER        := FND_API.G_MISS_NUM,
   p_trxn_extension_id         IN NUMBER        := FND_API.G_MISS_NUM,
   p_instrument_id             IN NUMBER        := FND_API.G_MISS_NUM,
   p_instr_assignment_id       IN NUMBER        := FND_API.G_MISS_NUM,
   p_cvv2                      IN VARCHAR2      := FND_API.G_MISS_CHAR
)
RETURN ASO_Quote_Pub.Payment_Rec_Type
is
l_payment_rec ASO_Quote_Pub.Payment_Rec_Type;
Begin

         l_payment_rec.operation_code := p_operation_code;

         IF p_qte_line_index = ROSETTA_G_MISS_NUM THEN
            l_payment_rec.qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.qte_line_index := p_qte_line_index;
         END IF;

         IF p_payment_id= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.payment_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.payment_id := p_payment_id;
         END IF;

         IF p_creation_date= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_rec.creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_rec.creation_date := p_creation_date;
         END IF;

         IF p_created_by= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.created_by := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.created_by := p_created_by;
         END IF;

         IF p_last_update_date= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_rec.last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_rec.last_update_date := p_last_update_date;
         END IF;

         IF p_last_updated_by= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.last_updated_by := p_last_updated_by;
         END IF;

         IF p_last_update_login= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.last_update_login := p_last_update_login;
         END IF;

         IF p_request_id= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.request_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.request_id := p_request_id;
         END IF;

         IF p_program_application_id= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.program_application_id := p_program_application_id;
         END IF;

         IF p_program_id= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.program_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.program_id := p_program_id;
         END IF;

         IF p_program_update_date= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_rec.program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_rec.program_update_date := p_program_update_date;
         END IF;

         IF p_quote_header_id= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.quote_header_id := p_quote_header_id;
         END IF;

         IF p_quote_line_id= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.quote_line_id := p_quote_line_id;
         END IF;

         l_payment_rec.payment_type_code := p_payment_type_code;

         l_payment_rec.payment_ref_number := p_payment_ref_number;

         l_payment_rec.payment_option := p_payment_option;

         IF p_payment_term_id= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.payment_term_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.payment_term_id := p_payment_term_id;
         END IF;

         l_payment_rec.credit_card_code := p_credit_card_code;

         l_payment_rec.credit_card_holder_name := p_credit_card_holder_name;


         IF p_credit_card_exp_date= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_rec.credit_card_expiration_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_rec.credit_card_expiration_date := p_credit_card_exp_date;
         END IF;

         l_payment_rec.credit_card_approval_code := p_credit_card_approval_code;

         IF p_credit_card_approval_date= ROSETTA_G_MISTAKE_DATE THEN
            l_payment_rec.credit_card_approval_date := FND_API.G_MISS_DATE;
         ELSE
            l_payment_rec.credit_card_approval_date := p_credit_card_approval_date;
         END IF;

         IF p_payment_amount= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.payment_amount := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.payment_amount := p_payment_amount;
         END IF;

         l_payment_rec.attribute_category := p_attribute_category;

         l_payment_rec.attribute1 := p_attribute1;

         l_payment_rec.attribute2 := p_attribute2;

         l_payment_rec.attribute3 := p_attribute3;

         l_payment_rec.attribute4 := p_attribute4;

         l_payment_rec.attribute5 := p_attribute5;

         l_payment_rec.attribute6 := p_attribute6;

         l_payment_rec.attribute7 := p_attribute7;

         l_payment_rec.attribute8 := p_attribute8;

         l_payment_rec.attribute9 := p_attribute9;

         l_payment_rec.attribute10 := p_attribute10;

         l_payment_rec.attribute11 := p_attribute11;

         l_payment_rec.attribute12 := p_attribute12;

         l_payment_rec.attribute13 := p_attribute13;

         l_payment_rec.attribute14 := p_attribute14;

         l_payment_rec.attribute15 := p_attribute15;


         IF p_shipment_index= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.shipment_index := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.shipment_index := p_shipment_index;
         END IF;


         IF p_quote_shipment_id= ROSETTA_G_MISS_NUM THEN
            l_payment_rec.quote_shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.quote_shipment_id := p_quote_shipment_id;
         END IF;

         l_payment_rec.cust_po_number := p_cust_po_number;

         l_payment_rec.cust_po_line_number := p_cust_po_line_number;

         l_payment_rec.attribute16 := p_attribute16;

         l_payment_rec.attribute17 := p_attribute17;

         l_payment_rec.attribute18 := p_attribute18;

         l_payment_rec.attribute19 := p_attribute19;

         l_payment_rec.attribute20 := p_attribute20;

         IF p_object_version_number = ROSETTA_G_MISS_NUM THEN
            l_payment_rec.object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.object_version_number := p_object_version_number;
         END IF;

         IF p_trxn_extension_id = ROSETTA_G_MISS_NUM THEN
            l_payment_rec.trxn_extension_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.trxn_extension_id := p_trxn_extension_id;
         END IF;

         IF p_instrument_id = ROSETTA_G_MISS_NUM THEN
            l_payment_rec.instrument_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.instrument_id := p_instrument_id;
         END IF;

         IF p_instr_assignment_id = ROSETTA_G_MISS_NUM THEN
            l_payment_rec.instr_assignment_id := FND_API.G_MISS_NUM;
         ELSE
            l_payment_rec.instr_assignment_id := p_instr_assignment_id;
         END IF;

         l_payment_rec.cvv2 := p_cvv2;





      RETURN l_payment_rec;

end;



-- there IS total 67 fields here IN line
FUNCTION Construct_Shipment_Rec(
   p_operation_code         IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_qte_line_index         IN NUMBER        := FND_API.G_MISS_NUM,
   p_shipment_id            IN NUMBER        := FND_API.G_MISS_NUM,
   p_creation_date          IN DATE          := FND_API.G_MISS_DATE,
   p_created_by             IN NUMBER        := FND_API.G_MISS_NUM,
   p_last_update_date       IN DATE          := FND_API.G_MISS_DATE,
   p_last_updated_by        IN NUMBER        := FND_API.G_MISS_NUM,
   p_last_update_login      IN NUMBER        := FND_API.G_MISS_NUM,
   p_request_id             IN NUMBER        := FND_API.G_MISS_NUM,
   p_program_application_id IN NUMBER        := FND_API.G_MISS_NUM,
   p_program_id             IN NUMBER        := FND_API.G_MISS_NUM,
   p_program_update_date    IN DATE          := FND_API.G_MISS_DATE,
   p_quote_header_id        IN NUMBER        := FND_API.G_MISS_NUM,
   p_quote_line_id          IN NUMBER        := FND_API.G_MISS_NUM,
   p_promise_date           IN DATE          := FND_API.G_MISS_DATE,
   p_request_date           IN DATE          := FND_API.G_MISS_DATE,
   p_schedule_ship_date     IN DATE          := FND_API.G_MISS_DATE,
   p_ship_to_party_site_id  IN NUMBER        := FND_API.G_MISS_NUM,
   p_ship_to_party_id       IN NUMBER        := FND_API.G_MISS_NUM,
   p_ship_to_cust_account_id   IN NUMBER        := FND_API.G_MISS_NUM,
   p_ship_partial_flag      IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_set_id            IN NUMBER        := FND_API.G_MISS_NUM,
   p_ship_method_code       IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_freight_terms_code     IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_freight_carrier_code   IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_fob_code               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_shipping_instructions  IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_packing_instructions   IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_quantity               IN NUMBER        := FND_API.G_MISS_NUM,
   p_reserved_quantity      IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_reservation_id         IN NUMBER        := FND_API.G_MISS_NUM,
   p_order_line_id          IN NUMBER        := FND_API.G_MISS_NUM,
   p_ship_to_party_name     IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_cont_first_name IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_cont_mid_name   IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_cont_last_name  IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_address1       IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_address2       IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_address3       IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_address4       IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_country_code   IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_country        IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_city           IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_postal_code    IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_state          IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_province       IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_to_county         IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute_category     IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute1             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute2             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute3             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute4             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute5             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute6             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute7             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute8             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute9             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute10            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute11            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute12            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute13            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute14            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute15            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_quote_price       IN NUMBER        := FND_API.G_MISS_NUM,
   p_pricing_quantity       IN NUMBER        := FND_API.G_MISS_NUM,
   p_shipment_priority_code IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_ship_from_org_id       IN NUMBER        := FND_API.G_MISS_NUM,
   p_ship_to_cust_party_id  IN NUMBER        := FND_API.G_MISS_NUM,
   p_attribute16            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute17            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute18            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute19            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute20            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_request_date_type      IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_demand_class_code      IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_object_version_number  IN NUMBER        := FND_API.G_MISS_NUM

)
RETURN ASO_Quote_Pub.Shipment_Rec_Type
IS
   l_shipment_Rec ASO_Quote_Pub.Shipment_Rec_Type;
BEGIN

         l_shipment_rec.operation_code := p_operation_code;
         IF p_qte_line_index = ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.qte_line_index := p_qte_line_index;
         END IF;
         IF p_shipment_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.shipment_id := p_shipment_id;
         END IF;
         IF p_creation_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.creation_date := p_creation_date;
         END IF;
         IF p_created_by= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.created_by := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.created_by := p_created_by;
         END IF;
         IF p_last_update_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.last_update_date := p_last_update_date;
         END IF;
         IF p_last_updated_by= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.last_updated_by := p_last_updated_by;
         END IF;
         IF p_last_update_login= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.last_update_login := p_last_update_login;
         END IF;
         IF p_request_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.request_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.request_id := p_request_id;
         END IF;
         IF p_program_application_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.program_application_id := p_program_application_id;
         END IF;
         IF p_program_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.program_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.program_id := p_program_id;
         END IF;
         IF p_program_update_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.program_update_date := p_program_update_date;
         END IF;
         IF p_quote_header_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.quote_header_id := p_quote_header_id;
         END IF;
         IF p_quote_line_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.quote_line_id := p_quote_line_id;
         END IF;
         IF p_promise_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.promise_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.promise_date := p_promise_date;
         END IF;
         IF p_request_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.request_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.request_date := p_request_date;
         END IF;
         IF p_schedule_ship_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.schedule_ship_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.schedule_ship_date := p_schedule_ship_date;
         END IF;
         IF p_ship_to_party_site_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_to_party_site_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_to_party_site_id := p_ship_to_party_site_id;
         END IF;
         IF p_ship_to_party_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_to_party_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_to_party_id := p_ship_to_party_id;
         END IF;
         IF p_ship_to_cust_account_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_to_cust_account_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_to_cust_account_id := p_ship_to_cust_account_id;
         END IF;
         l_shipment_rec.ship_partial_flag := p_ship_partial_flag;
         IF p_ship_set_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_set_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_set_id := p_ship_set_id;
         END IF;
         l_shipment_rec.ship_method_code := p_ship_method_code;
         l_shipment_rec.freight_terms_code := p_freight_terms_code;
         l_shipment_rec.freight_carrier_code := p_freight_carrier_code;
         l_shipment_rec.fob_code := p_fob_code;
         l_shipment_rec.shipping_instructions := p_shipping_instructions;
         l_shipment_rec.packing_instructions := p_packing_instructions;
         IF p_quantity= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.quantity := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.quantity := p_quantity;
         END IF;

         l_shipment_rec.reserved_quantity := p_reserved_quantity;

         IF p_reservation_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.reservation_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.reservation_id := p_reservation_id;
         END IF;
         IF p_order_line_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.order_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.order_line_id := p_order_line_id;
         END IF;
         l_shipment_rec.ship_to_party_name := p_ship_to_party_name;
         l_shipment_rec.ship_to_contact_first_name := p_ship_to_cont_first_name;
         l_shipment_rec.ship_to_contact_middle_name := p_ship_to_cont_mid_name;
         l_shipment_rec.ship_to_contact_last_name := p_ship_to_cont_last_name;
         l_shipment_rec.ship_to_address1 := p_ship_to_address1;
         l_shipment_rec.ship_to_address2 := p_ship_to_address2;
         l_shipment_rec.ship_to_address3 := p_ship_to_address3;
         l_shipment_rec.ship_to_address4 := p_ship_to_address4;
         l_shipment_rec.ship_to_country_code := p_ship_to_country_code;
         l_shipment_rec.ship_to_country := p_ship_to_country;
         l_shipment_rec.ship_to_city := p_ship_to_city;
         l_shipment_rec.ship_to_postal_code := p_ship_to_postal_code;
         l_shipment_rec.ship_to_state := p_ship_to_state;
         l_shipment_rec.ship_to_province := p_ship_to_province;
         l_shipment_rec.ship_to_county := p_ship_to_county;
         l_shipment_rec.attribute_category := p_attribute_category;
         l_shipment_rec.attribute1 := p_attribute1;
         l_shipment_rec.attribute2 := p_attribute2;
         l_shipment_rec.attribute3 := p_attribute3;
         l_shipment_rec.attribute4 := p_attribute4;
         l_shipment_rec.attribute5 := p_attribute5;
         l_shipment_rec.attribute6 := p_attribute6;
         l_shipment_rec.attribute7 := p_attribute7;
         l_shipment_rec.attribute8 := p_attribute8;
         l_shipment_rec.attribute9 := p_attribute9;
         l_shipment_rec.attribute10 := p_attribute10;
         l_shipment_rec.attribute11 := p_attribute11;
         l_shipment_rec.attribute12 := p_attribute12;
         l_shipment_rec.attribute13 := p_attribute13;
         l_shipment_rec.attribute14 := p_attribute14;
         l_shipment_rec.attribute15 := p_attribute15;
         IF p_ship_quote_price= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_quote_price := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_quote_price := p_ship_quote_price;
         END IF;
         IF p_pricing_quantity= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.pricing_quantity := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.pricing_quantity := p_pricing_quantity;
         END IF;
         l_shipment_rec.shipment_priority_code := p_shipment_priority_code;
         IF p_ship_from_org_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_from_org_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_from_org_id := p_ship_from_org_id;
         END IF;
         IF p_ship_to_cust_party_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_to_cust_party_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_to_cust_party_id := p_ship_to_cust_party_id;
         END IF;
         l_shipment_rec.attribute16 := p_attribute16;
         l_shipment_rec.attribute17 := p_attribute17;
         l_shipment_rec.attribute18 := p_attribute18;
         l_shipment_rec.attribute19 := p_attribute19;
         l_shipment_rec.attribute20 := p_attribute20;
         l_shipment_rec.request_date_type := p_request_date_type;
         l_shipment_rec.demand_class_code := p_demand_class_code;
         IF p_object_version_number = ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.object_version_number := p_object_version_number;
         END IF;

      RETURN l_shipment_rec;
END Construct_Shipment_Rec;


-- there IS total 67 fields here IN line
FUNCTION Construct_Shipment_Tbl(
   p_operation_code         IN jtf_varchar2_table_100  := NULL,
   p_qte_line_index         IN jtf_number_table        := NULL,
   p_shipment_id            IN jtf_number_table        := NULL,
   p_creation_date          IN jtf_date_table          := NULL,
   p_created_by             IN jtf_number_table        := NULL,
   p_last_update_date       IN jtf_date_table          := NULL,
   p_last_updated_by        IN jtf_number_table        := NULL,
   p_last_update_login      IN jtf_number_table        := NULL,
   p_request_id             IN jtf_number_table        := NULL,
   p_program_application_id IN jtf_number_table        := NULL,
   p_program_id             IN jtf_number_table        := NULL,
   p_program_update_date    IN jtf_date_table          := NULL,
   p_quote_header_id        IN jtf_number_table        := NULL,
   p_quote_line_id          IN jtf_number_table        := NULL,
   p_promise_date           IN jtf_date_table          := NULL,
   p_request_date           IN jtf_date_table          := NULL,
   p_schedule_ship_date     IN jtf_date_table          := NULL,
   p_ship_to_party_site_id  IN jtf_number_table        := NULL,
   p_ship_to_party_id       IN jtf_number_table        := NULL,
   p_ship_to_cust_account_id  IN jtf_number_table        := NULL,
   p_ship_partial_flag      IN jtf_varchar2_table_300  := NULL,
   p_ship_set_id            IN jtf_number_table        := NULL,
   p_ship_method_code       IN jtf_varchar2_table_100  := NULL,
   p_freight_terms_code     IN jtf_varchar2_table_100  := NULL,
   p_freight_carrier_code   IN jtf_varchar2_table_100  := NULL,
   p_fob_code               IN jtf_varchar2_table_100  := NULL,
   p_shipping_instructions  IN jtf_varchar2_table_2000 := NULL,
   p_packing_instructions   IN jtf_varchar2_table_2000 := NULL,
   p_quantity               IN jtf_number_table        := NULL,
   p_reserved_quantity      IN jtf_varchar2_table_300  := NULL,
   p_reservation_id         IN jtf_number_table        := NULL,
   p_order_line_id          IN jtf_number_table        := NULL,
   p_ship_to_party_name     IN jtf_varchar2_table_300  := NULL,
   p_ship_to_cont_first_name IN jtf_varchar2_table_100  := NULL,
   p_ship_to_cont_mid_name   IN jtf_varchar2_table_100  := NULL,
   p_ship_to_cont_last_name  IN jtf_varchar2_table_100  := NULL,
   p_ship_to_address1       IN jtf_varchar2_table_300  := NULL,
   p_ship_to_address2       IN jtf_varchar2_table_300  := NULL,
   p_ship_to_address3       IN jtf_varchar2_table_300  := NULL,
   p_ship_to_address4       IN jtf_varchar2_table_300  := NULL,
   p_ship_to_country_code   IN jtf_varchar2_table_100  := NULL,
   p_ship_to_country        IN jtf_varchar2_table_100  := NULL,
   p_ship_to_city           IN jtf_varchar2_table_100  := NULL,
   p_ship_to_postal_code    IN jtf_varchar2_table_100  := NULL,
   p_ship_to_state          IN jtf_varchar2_table_100  := NULL,
   p_ship_to_province       IN jtf_varchar2_table_100  := NULL,
   p_ship_to_county         IN jtf_varchar2_table_100  := NULL,
   p_attribute_category     IN jtf_varchar2_table_100  := NULL,
   p_attribute1             IN jtf_varchar2_table_300  := NULL,
   p_attribute2             IN jtf_varchar2_table_300  := NULL,
   p_attribute3             IN jtf_varchar2_table_300  := NULL,
   p_attribute4             IN jtf_varchar2_table_300  := NULL,
   p_attribute5             IN jtf_varchar2_table_300  := NULL,
   p_attribute6             IN jtf_varchar2_table_300  := NULL,
   p_attribute7             IN jtf_varchar2_table_300  := NULL,
   p_attribute8             IN jtf_varchar2_table_300  := NULL,
   p_attribute9             IN jtf_varchar2_table_300  := NULL,
   p_attribute10            IN jtf_varchar2_table_300  := NULL,
   p_attribute11            IN jtf_varchar2_table_300  := NULL,
   p_attribute12            IN jtf_varchar2_table_300  := NULL,
   p_attribute13            IN jtf_varchar2_table_300  := NULL,
   p_attribute14            IN jtf_varchar2_table_300  := NULL,
   p_attribute15            IN jtf_varchar2_table_300  := NULL,
   p_ship_quote_price       IN jtf_number_table        := NULL,
   p_pricing_quantity       IN jtf_number_table        := NULL,
   p_shipment_priority_code IN jtf_varchar2_table_100  := NULL,
   p_ship_from_org_id       IN jtf_number_table        := NULL,
   p_ship_to_cust_party_id  IN jtf_number_table        := NULL,
   p_attribute16            IN jtf_varchar2_table_300  := NULL,
   p_attribute17            IN jtf_varchar2_table_300  := NULL,
   p_attribute18            IN jtf_varchar2_table_300  := NULL,
   p_attribute19            IN jtf_varchar2_table_300  := NULL,
   p_attribute20            IN jtf_varchar2_table_300  := NULL,
   p_request_date_type      IN jtf_varchar2_table_100  := NULL,
   p_demand_class_code      IN jtf_varchar2_table_100  := NULL,
   p_object_version_number  IN  jtf_number_table       := NULL

)
RETURN ASO_Quote_Pub.Shipment_Tbl_Type
IS
   l_shipment_tbl ASO_Quote_Pub.Shipment_Tbl_Type;
   l_table_size   PLS_INTEGER := 0;
   i              PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
        -- IF p_operation_code IS NOT NULL THEN
         l_shipment_tbl(i).operation_code := p_operation_code(i);
        -- END IF;
        IF p_qte_line_index IS NOT NULL THEN
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
        END IF;
        IF p_shipment_id IS NOT NULL THEN
         IF p_shipment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).shipment_id := p_shipment_id(i);
         END IF;
        END IF;
        IF p_creation_date IS NOT NULL THEN
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_tbl(i).creation_date := p_creation_date(i);
         END IF;
        END IF;
        IF p_created_by IS NOT NULL THEN
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).created_by := p_created_by(i);
         END IF;
        END IF;
        IF p_last_update_date IS NOT NULL THEN
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
        END IF;
        IF p_last_updated_by IS NOT NULL THEN
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
        END IF;
        IF p_last_update_login IS NOT NULL THEN
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
        END IF;
        IF p_request_id IS NOT NULL THEN
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).request_id := p_request_id(i);
         END IF;
        END IF;
        IF p_program_application_id IS NOT NULL THEN
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
        END IF;
        IF p_program_id IS NOT NULL THEN
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).program_id := p_program_id(i);
         END IF;
        END IF;
        IF p_program_update_date IS NOT NULL THEN
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
        END IF;
        IF p_quote_header_id IS NOT NULL THEN
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
        END IF;
        IF p_quote_line_id IS NOT NULL THEN
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
        END IF;
        IF p_promise_date IS NOT NULL THEN
         IF p_promise_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_tbl(i).promise_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_tbl(i).promise_date := p_promise_date(i);
         END IF;
        END IF;
        IF p_request_date IS NOT NULL THEN
         IF p_request_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_tbl(i).request_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_tbl(i).request_date := p_request_date(i);
         END IF;
        END IF;
        IF p_schedule_ship_date IS NOT NULL THEN
         IF p_schedule_ship_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_tbl(i).schedule_ship_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_tbl(i).schedule_ship_date := p_schedule_ship_date(i);
         END IF;
        END IF;
        IF p_ship_to_party_site_id IS NOT NULL THEN
         IF p_ship_to_party_site_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).ship_to_party_site_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).ship_to_party_site_id := p_ship_to_party_site_id(i);
         END IF;
        END IF;
        IF p_ship_to_party_id IS NOT NULL THEN
         IF p_ship_to_party_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).ship_to_party_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).ship_to_party_id := p_ship_to_party_id(i);
         END IF;
        END IF;
        IF p_ship_to_cust_account_id IS NOT NULL THEN
         IF p_ship_to_cust_account_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).ship_to_cust_account_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).ship_to_cust_account_id := p_ship_to_cust_account_id(i);
         END IF;
        END IF;
        IF p_ship_partial_flag IS NOT NULL THEN
         l_shipment_tbl(i).ship_partial_flag := p_ship_partial_flag(i);
        END IF;
        IF p_ship_set_id IS NOT NULL THEN
         IF p_ship_set_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).ship_set_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).ship_set_id := p_ship_set_id(i);
         END IF;
        END IF;
        IF p_ship_method_code IS NOT NULL THEN
         l_shipment_tbl(i).ship_method_code := p_ship_method_code(i);
        END IF;
        IF p_freight_terms_code IS NOT NULL THEN
         l_shipment_tbl(i).freight_terms_code := p_freight_terms_code(i);
        END IF;
        IF p_freight_carrier_code IS NOT NULL THEN
         l_shipment_tbl(i).freight_carrier_code := p_freight_carrier_code(i);
        END IF;
        IF p_fob_code IS NOT NULL THEN
         l_shipment_tbl(i).fob_code := p_fob_code(i);
        END IF;
        IF p_shipping_instructions IS NOT NULL THEN
         l_shipment_tbl(i).shipping_instructions := p_shipping_instructions(i);
        END IF;
        IF p_packing_instructions IS NOT NULL THEN
         l_shipment_tbl(i).packing_instructions := p_packing_instructions(i);
        END IF;
        IF p_quantity IS NOT NULL THEN
         IF p_quantity(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).quantity := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).quantity := p_quantity(i);
         END IF;
        END IF;
        IF p_reserved_quantity IS NOT NULL THEN
            l_shipment_tbl(i).reserved_quantity := p_reserved_quantity(i);
        END IF;
        IF p_reservation_id IS NOT NULL THEN
         IF p_reservation_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).reservation_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).reservation_id := p_reservation_id(i);
         END IF;
        END IF;
        IF p_order_line_id IS NOT NULL THEN
         IF p_order_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).order_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).order_line_id := p_order_line_id(i);
         END IF;
        END IF;
        IF p_ship_to_party_name IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_party_name := p_ship_to_party_name(i);
        END IF;
        IF p_ship_to_cont_first_name IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_contact_first_name := p_ship_to_cont_first_name(i);
        END IF;
        IF p_ship_to_cont_mid_name IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_contact_middle_name := p_ship_to_cont_mid_name(i);
        END IF;
        IF p_ship_to_cont_last_name IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_contact_last_name := p_ship_to_cont_last_name(i);
        END IF;
        IF p_ship_to_address1 IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_address1 := p_ship_to_address1(i);
        END IF;
        IF p_ship_to_address2 IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_address2 := p_ship_to_address2(i);
        END IF;
        IF p_ship_to_address3 IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_address3 := p_ship_to_address3(i);
        END IF;
        IF p_ship_to_address4 IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_address4 := p_ship_to_address4(i);
        END IF;
        IF p_ship_to_country_code IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_country_code := p_ship_to_country_code(i);
        END IF;
        IF p_ship_to_country IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_country := p_ship_to_country(i);
        END IF;
        IF p_ship_to_city IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_city := p_ship_to_city(i);
        END IF;
        IF p_ship_to_postal_code IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_postal_code := p_ship_to_postal_code(i);
        END IF;
        IF p_ship_to_state IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_state := p_ship_to_state(i);
        END IF;
        IF p_ship_to_province IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_province := p_ship_to_province(i);
        END IF;
        IF p_ship_to_county IS NOT NULL THEN
         l_shipment_tbl(i).ship_to_county := p_ship_to_county(i);
        END IF;
        IF p_attribute_category IS NOT NULL THEN
         l_shipment_tbl(i).attribute_category := p_attribute_category(i);
        END IF;
        IF p_attribute1 IS NOT NULL THEN
         l_shipment_tbl(i).attribute1 := p_attribute1(i);
        END IF;
        IF p_attribute2 IS NOT NULL THEN
         l_shipment_tbl(i).attribute2 := p_attribute2(i);
        END IF;
        IF p_attribute3 IS NOT NULL THEN
         l_shipment_tbl(i).attribute3 := p_attribute3(i);
        END IF;
        IF p_attribute4 IS NOT NULL THEN
         l_shipment_tbl(i).attribute4 := p_attribute4(i);
        END IF;
        IF p_attribute5 IS NOT NULL THEN
         l_shipment_tbl(i).attribute5 := p_attribute5(i);
        END IF;
        IF p_attribute6 IS NOT NULL THEN
         l_shipment_tbl(i).attribute6 := p_attribute6(i);
        END IF;
        IF p_attribute7 IS NOT NULL THEN
         l_shipment_tbl(i).attribute7 := p_attribute7(i);
        END IF;
        IF p_attribute8 IS NOT NULL THEN
         l_shipment_tbl(i).attribute8 := p_attribute8(i);
        END IF;
        IF p_attribute9 IS NOT NULL THEN
         l_shipment_tbl(i).attribute9 := p_attribute9(i);
        END IF;
        IF p_attribute10 IS NOT NULL THEN
         l_shipment_tbl(i).attribute10 := p_attribute10(i);
        END IF;
        IF p_attribute11 IS NOT NULL THEN
         l_shipment_tbl(i).attribute11 := p_attribute11(i);
        END IF;
        IF p_attribute12 IS NOT NULL THEN
         l_shipment_tbl(i).attribute12 := p_attribute12(i);
        END IF;
        IF p_attribute13 IS NOT NULL THEN
         l_shipment_tbl(i).attribute13 := p_attribute13(i);
        END IF;
        IF p_attribute14 IS NOT NULL THEN
         l_shipment_tbl(i).attribute14 := p_attribute14(i);
        END IF;
        IF p_attribute15 IS NOT NULL THEN
         l_shipment_tbl(i).attribute15 := p_attribute15(i);
        END IF;
        IF p_ship_quote_price IS NOT NULL THEN
         IF p_ship_quote_price(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).ship_quote_price := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).ship_quote_price := p_ship_quote_price(i);
         END IF;
        END IF;
        IF p_pricing_quantity IS NOT NULL THEN
         IF p_pricing_quantity(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).pricing_quantity := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).pricing_quantity := p_pricing_quantity(i);
         END IF;
        END IF;
        IF p_shipment_priority_code IS NOT NULL THEN
         l_shipment_tbl(i).shipment_priority_code := p_shipment_priority_code(i);
        END IF;
        IF p_ship_from_org_id IS NOT NULL THEN
         IF p_ship_from_org_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).ship_from_org_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).ship_from_org_id := p_ship_from_org_id(i);
         END IF;
        END IF;
        IF p_ship_to_cust_party_id IS NOT NULL THEN
         IF p_ship_to_cust_party_id(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).ship_to_cust_party_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).ship_to_cust_party_id := p_ship_to_cust_party_id(i);
         END IF;
        END IF;

        IF p_attribute16 IS NOT NULL THEN
         l_shipment_tbl(i).attribute16 := p_attribute16(i);
        END IF;
        IF p_attribute17 IS NOT NULL THEN
         l_shipment_tbl(i).attribute17 := p_attribute17(i);
        END IF;
        IF p_attribute18 IS NOT NULL THEN
         l_shipment_tbl(i).attribute18 := p_attribute18(i);
        END IF;
        IF p_attribute19 IS NOT NULL THEN
         l_shipment_tbl(i).attribute19 := p_attribute19(i);
        END IF;
        IF p_attribute20 IS NOT NULL THEN
         l_shipment_tbl(i).attribute20 := p_attribute20(i);
        END IF;
        IF p_request_date_type IS NOT NULL THEN
         l_shipment_tbl(i).request_date_type := p_request_date_type(i);
        END IF;
        IF p_demand_class_code IS NOT NULL THEN
         l_shipment_tbl(i).demand_class_code := p_demand_class_code(i);
        END IF;
        IF p_object_version_number IS NOT NULL THEN
         IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
            l_shipment_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_tbl(i).object_version_number := p_object_version_number(i);
         END IF;
        END IF;


      END LOOP;

      RETURN l_shipment_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_SHIPMENT_TBL;
   END IF;
END Construct_Shipment_Tbl;


-- there IS total 40 fields here IN line
FUNCTION Construct_Tax_Detail_Tbl(
   p_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qte_line_index         IN jtf_number_table       := NULL,
   p_shipment_index         IN jtf_number_table       := NULL,
   p_tax_detail_id          IN jtf_number_table       := NULL,
   p_quote_header_id        IN jtf_number_table       := NULL,
   p_quote_line_id          IN jtf_number_table       := NULL,
   p_quote_shipment_id      IN jtf_number_table       := NULL,
   p_creation_date          IN jtf_date_table         := NULL,
   p_created_by             IN jtf_number_table       := NULL,
   p_last_update_date       IN jtf_date_table         := NULL,
   p_last_updated_by        IN jtf_number_table       := NULL,
   p_last_update_login      IN jtf_number_table       := NULL,
   p_request_id             IN jtf_number_table       := NULL,
   p_program_application_id IN jtf_number_table       := NULL,
   p_program_id             IN jtf_number_table       := NULL,
   p_program_update_date    IN jtf_date_table         := NULL,
   p_orig_tax_code          IN jtf_varchar2_table_300 := NULL,
   p_tax_code               IN jtf_varchar2_table_100 := NULL,
   p_tax_rate               IN jtf_number_table       := NULL,
   p_tax_date               IN jtf_date_table         := NULL,
   p_tax_amount             IN jtf_number_table       := NULL,
   p_tax_exempt_flag        IN jtf_varchar2_table_100 := NULL,
   p_tax_exempt_number      IN jtf_varchar2_table_100 := NULL,
   p_tax_exempt_reason_code IN jtf_varchar2_table_100 := NULL,
   p_attribute_category     IN jtf_varchar2_table_100 := NULL,
   p_attribute1             IN jtf_varchar2_table_300 := NULL,
   p_attribute2             IN jtf_varchar2_table_300 := NULL,
   p_attribute3             IN jtf_varchar2_table_300 := NULL,
   p_attribute4             IN jtf_varchar2_table_300 := NULL,
   p_attribute5             IN jtf_varchar2_table_300 := NULL,
   p_attribute6             IN jtf_varchar2_table_300 := NULL,
   p_attribute7             IN jtf_varchar2_table_300 := NULL,
   p_attribute8             IN jtf_varchar2_table_300 := NULL,
   p_attribute9             IN jtf_varchar2_table_300 := NULL,
   p_attribute10            IN jtf_varchar2_table_300 := NULL,
   p_attribute11            IN jtf_varchar2_table_300 := NULL,
   p_attribute12            IN jtf_varchar2_table_300 := NULL,
   p_attribute13            IN jtf_varchar2_table_300 := NULL,
   p_attribute14            IN jtf_varchar2_table_300 := NULL,
   p_attribute15            IN jtf_varchar2_table_300 := NULL,
   p_attribute16            IN jtf_varchar2_table_300 := NULL,
   p_attribute17            IN jtf_varchar2_table_300 := NULL,
   p_attribute18            IN jtf_varchar2_table_300 := NULL,
   p_attribute19            IN jtf_varchar2_table_300 := NULL,
   p_attribute20            IN jtf_varchar2_table_300 := NULL,
   p_object_version_number  IN  jtf_number_table   := NULL,
   p_tax_rate_id            IN  jtf_number_table   := NULL
)
RETURN ASO_Quote_Pub.Tax_Detail_Tbl_Type
IS
   l_tax_detail_tbl ASO_Quote_Pub.Tax_Detail_Tbl_Type;
   l_table_size     PLS_INTEGER := 0;
   i                PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
        -- IF p_operation_code IS NOT NULL THEN
         l_tax_detail_tbl(i).operation_code := p_operation_code(i);
        -- END IF;
        IF p_qte_line_index IS NOT NULL THEN
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
        END IF;
        IF p_shipment_index IS NOT NULL THEN
         IF p_shipment_index(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).shipment_index := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).shipment_index := p_shipment_index(i);
         END IF;
        END IF;
        IF p_tax_detail_id IS NOT NULL THEN
         IF p_tax_detail_id(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).tax_detail_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).tax_detail_id := p_tax_detail_id(i);
         END IF;
        END IF;
        IF p_quote_header_id IS NOT NULL THEN
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
        END IF;
        IF p_quote_line_id IS NOT NULL THEN
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
        END IF;
        IF p_quote_shipment_id IS NOT NULL THEN
         IF p_quote_shipment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).quote_shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).quote_shipment_id := p_quote_shipment_id(i);
         END IF;
        END IF;
        IF p_creation_date IS NOT NULL THEN
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_tax_detail_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_tax_detail_tbl(i).creation_date := p_creation_date(i);
         END IF;
        END IF;
        IF p_created_by IS NOT NULL THEN
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).created_by := p_created_by(i);
         END IF;
        END IF;
        IF p_last_update_date IS NOT NULL THEN
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_tax_detail_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_tax_detail_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
        END IF;
        IF p_last_updated_by IS NOT NULL THEN
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
        END IF;
        IF p_last_update_login IS NOT NULL THEN
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
        END IF;
        IF p_request_id IS NOT NULL THEN
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).request_id := p_request_id(i);
         END IF;
        END IF;
        IF p_program_application_id IS NOT NULL THEN
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
        END IF;
        IF p_program_id IS NOT NULL THEN
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).program_id := p_program_id(i);
         END IF;
        END IF;
        IF p_program_update_date IS NOT NULL THEN
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_tax_detail_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_tax_detail_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
        END IF;
        IF p_orig_tax_code IS NOT NULL THEN
         l_tax_detail_tbl(i).orig_tax_code := p_orig_tax_code(i);
        END IF;
        IF p_tax_code IS NOT NULL THEN
         l_tax_detail_tbl(i).tax_code := p_tax_code(i);
        END IF;
        IF p_tax_rate IS NOT NULL THEN
         IF p_tax_rate(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).tax_rate := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).tax_rate := p_tax_rate(i);
         END IF;
        END IF;
        IF p_tax_date IS NOT NULL THEN
         IF p_tax_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_tax_detail_tbl(i).tax_date := FND_API.G_MISS_DATE;
         ELSE
            l_tax_detail_tbl(i).tax_date := p_tax_date(i);
         END IF;
        END IF;
        IF p_tax_amount IS NOT NULL THEN
         IF p_tax_amount(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).tax_amount := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).tax_amount := p_tax_amount(i);
         END IF;
        END IF;
        IF p_tax_exempt_flag IS NOT NULL THEN
         l_tax_detail_tbl(i).tax_exempt_flag := p_tax_exempt_flag(i);
        END IF;
        IF p_tax_exempt_number IS NOT NULL THEN
         l_tax_detail_tbl(i).tax_exempt_number := p_tax_exempt_number(i);
        END IF;
        IF p_tax_exempt_reason_code IS NOT NULL THEN
         l_tax_detail_tbl(i).tax_exempt_reason_code := p_tax_exempt_reason_code(i);
        END IF;
        IF p_attribute_category IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute_category := p_attribute_category(i);
        END IF;
        IF p_attribute1 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute1 := p_attribute1(i);
        END IF;
        IF p_attribute2 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute2 := p_attribute2(i);
        END IF;
        IF p_attribute3 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute3 := p_attribute3(i);
        END IF;
        IF p_attribute4 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute4 := p_attribute4(i);
        END IF;
        IF p_attribute5 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute5 := p_attribute5(i);
        END IF;
        IF p_attribute6 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute6 := p_attribute6(i);
        END IF;
        IF p_attribute7 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute7 := p_attribute7(i);
        END IF;
        IF p_attribute8 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute8 := p_attribute8(i);
        END IF;
        IF p_attribute9 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute9 := p_attribute9(i);
        END IF;
        IF p_attribute10 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute10 := p_attribute10(i);
        END IF;
        IF p_attribute11 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute11 := p_attribute11(i);
        END IF;
        IF p_attribute12 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute12 := p_attribute12(i);
        END IF;
        IF p_attribute13 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute13 := p_attribute13(i);
        END IF;
        IF p_attribute14 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute14 := p_attribute14(i);
        END IF;
        IF p_attribute15 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute15 := p_attribute15(i);
        END IF;
        IF p_attribute16 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute16 := p_attribute16(i);
        END IF;
        IF p_attribute17 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute17 := p_attribute17(i);
        END IF;
        IF p_attribute18 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute18 := p_attribute18(i);
        END IF;
        IF p_attribute19 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute19 := p_attribute19(i);
        END IF;
        IF p_attribute20 IS NOT NULL THEN
         l_tax_detail_tbl(i).attribute20 := p_attribute20(i);
        END IF;
        IF p_object_version_number IS NOT NULL THEN
         IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).object_version_number := p_object_version_number(i);
         END IF;
        END IF;


        IF p_tax_rate_id IS NOT NULL THEN
         IF p_tax_rate_id(i)= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_tbl(i).tax_rate_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_tbl(i).tax_rate_id := p_tax_rate_id(i);
         END IF;
        END IF;


      END LOOP;

      RETURN l_tax_detail_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_TAX_DETAIL_TBL;
   END IF;
END Construct_Tax_Detail_Tbl;

FUNCTION Construct_Tax_Detail_Rec(
   p_operation_code         IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_qte_line_index         IN NUMBER        := FND_API.G_MISS_NUM,
   p_shipment_index         IN NUMBER        := FND_API.G_MISS_NUM,
   p_tax_detail_id          IN NUMBER        := FND_API.G_MISS_NUM,
   p_quote_header_id        IN NUMBER        := FND_API.G_MISS_NUM,
   p_quote_line_id          IN NUMBER        := FND_API.G_MISS_NUM,
   p_quote_shipment_id      IN NUMBER        := FND_API.G_MISS_NUM,
   p_creation_date          IN DATE          := FND_API.G_MISS_DATE,
   p_created_by             IN NUMBER        := FND_API.G_MISS_NUM,
   p_last_update_date       IN DATE          := FND_API.G_MISS_DATE,
   p_last_updated_by        IN NUMBER        := FND_API.G_MISS_NUM,
   p_last_update_login      IN NUMBER        := FND_API.G_MISS_NUM,
   p_request_id             IN NUMBER        := FND_API.G_MISS_NUM,
   p_program_application_id IN NUMBER        := FND_API.G_MISS_NUM,
   p_program_id             IN NUMBER        := FND_API.G_MISS_NUM,
   p_program_update_date    IN DATE          := FND_API.G_MISS_DATE,
   p_orig_tax_code          IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_tax_code               IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_tax_rate               IN NUMBER        := FND_API.G_MISS_NUM,
   p_tax_date               IN DATE          := FND_API.G_MISS_DATE,
   p_tax_amount             IN NUMBER        := FND_API.G_MISS_NUM,
   p_tax_exempt_flag        IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_tax_exempt_number      IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_tax_exempt_reason_code IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute_category     IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute1             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute2             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute3             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute4             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute5             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute6             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute7             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute8             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute9             IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute10            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute11            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute12            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute13            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute14            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute15            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute16            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute17            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute18            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute19            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_attribute20            IN VARCHAR2      := FND_API.G_MISS_CHAR,
   p_object_version_number  IN NUMBER        := FND_API.G_MISS_NUM,
   p_tax_rate_id            IN NUMBER        := FND_API.G_MISS_NUM
)
RETURN ASO_Quote_Pub.Tax_Detail_Rec_Type
is
  l_tax_detail_rec ASO_Quote_Pub.Tax_Detail_Rec_Type;
BEGIN
         l_tax_detail_rec.operation_code := p_operation_code;

         IF p_qte_line_index = ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.qte_line_index := p_qte_line_index;
         END IF;

         IF p_shipment_index = ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.shipment_index := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.shipment_index := p_shipment_index;
         END IF;

         IF p_tax_detail_id = ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.tax_detail_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.tax_detail_id := p_tax_detail_id;
         END IF;

         IF p_quote_header_id= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.quote_header_id := p_quote_header_id;
         END IF;

         IF p_quote_line_id = ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.quote_line_id := p_quote_line_id;
         END IF;

         IF p_quote_shipment_id = ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.quote_shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.quote_shipment_id := p_quote_shipment_id;
         END IF;

         IF p_creation_date= ROSETTA_G_MISTAKE_DATE THEN
            l_tax_detail_rec.creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_tax_detail_rec.creation_date := p_creation_date;
         END IF;

         IF p_created_by = ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.created_by := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.created_by := p_created_by;
         END IF;

         IF p_last_update_date = ROSETTA_G_MISTAKE_DATE THEN
            l_tax_detail_rec.last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_tax_detail_rec.last_update_date := p_last_update_date;
         END IF;

         IF p_last_updated_by= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.last_updated_by := p_last_updated_by;
         END IF;

         IF p_last_update_login= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.last_update_login := p_last_update_login;
         END IF;

         IF p_request_id= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.request_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.request_id := p_request_id;
         END IF;

         IF p_program_application_id= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.program_application_id := p_program_application_id;
         END IF;

         IF p_program_id= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.program_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.program_id := p_program_id;
         END IF;

         IF p_program_update_date= ROSETTA_G_MISTAKE_DATE THEN
            l_tax_detail_rec.program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_tax_detail_rec.program_update_date := p_program_update_date;
         END IF;


         l_tax_detail_rec.orig_tax_code := p_orig_tax_code;

         l_tax_detail_rec.tax_code := p_tax_code;


         IF p_tax_rate= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.tax_rate := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.tax_rate := p_tax_rate;
         END IF;


         IF p_tax_date= ROSETTA_G_MISTAKE_DATE THEN
            l_tax_detail_rec.tax_date := FND_API.G_MISS_DATE;
         ELSE
            l_tax_detail_rec.tax_date := p_tax_date;
         END IF;

         IF p_tax_amount = ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.tax_amount := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.tax_amount := p_tax_amount;
         END IF;


         l_tax_detail_rec.tax_exempt_flag := p_tax_exempt_flag;

         l_tax_detail_rec.tax_exempt_number := p_tax_exempt_number;

         l_tax_detail_rec.tax_exempt_reason_code := p_tax_exempt_reason_code;

         l_tax_detail_rec.attribute_category := p_attribute_category;

         l_tax_detail_rec.attribute1 := p_attribute1;

         l_tax_detail_rec.attribute2 := p_attribute2;

         l_tax_detail_rec.attribute3 := p_attribute3;

         l_tax_detail_rec.attribute4 := p_attribute4;

         l_tax_detail_rec.attribute5 := p_attribute5;

         l_tax_detail_rec.attribute6 := p_attribute6;

         l_tax_detail_rec.attribute7 := p_attribute7;

         l_tax_detail_rec.attribute8 := p_attribute8;

         l_tax_detail_rec.attribute9 := p_attribute9;

         l_tax_detail_rec.attribute10 := p_attribute10;

         l_tax_detail_rec.attribute11 := p_attribute11;

         l_tax_detail_rec.attribute12 := p_attribute12;

         l_tax_detail_rec.attribute13 := p_attribute13;

         l_tax_detail_rec.attribute14 := p_attribute14;

         l_tax_detail_rec.attribute15 := p_attribute15;

         l_tax_detail_rec.attribute16 := p_attribute16;

         l_tax_detail_rec.attribute17 := p_attribute17;

         l_tax_detail_rec.attribute18 := p_attribute18;

         l_tax_detail_rec.attribute19 := p_attribute19;

         l_tax_detail_rec.attribute20 := p_attribute20;

         IF p_object_version_number= ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.object_version_number := p_object_version_number;
         END IF;

         IF p_tax_rate_id = ROSETTA_G_MISS_NUM THEN
            l_tax_detail_rec.tax_rate_id := FND_API.G_MISS_NUM;
         ELSE
            l_tax_detail_rec.tax_rate_id := p_tax_rate_id;
         END IF;


      RETURN l_tax_detail_rec;

End;


-- there IS total 132 fields here IN line
FUNCTION Construct_Price_Attributes_Tbl(
   p_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qte_line_index         IN jtf_number_table       := NULL,
   p_price_attribute_id     IN jtf_number_table       := NULL,
   p_creation_date          IN jtf_date_table         := NULL,
   p_created_by             IN jtf_number_table       := NULL,
   p_last_update_date       IN jtf_date_table         := NULL,
   p_last_updated_by        IN jtf_number_table       := NULL,
   p_last_update_login      IN jtf_number_table       := NULL,
   p_request_id             IN jtf_number_table       := NULL,
   p_program_application_id IN jtf_number_table       := NULL,
   p_program_id             IN jtf_number_table       := NULL,
   p_program_update_date    IN jtf_date_table         := NULL,
   p_quote_header_id        IN jtf_number_table       := NULL,
   p_quote_line_id          IN jtf_number_table       := NULL,
   p_flex_title             IN jtf_varchar2_table_100 := NULL,
   p_pricing_context        IN jtf_varchar2_table_100 := NULL,
   p_pricing_attribute1     IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute2     IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute3     IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute4     IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute5     IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute6     IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute7     IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute8     IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute9     IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute10    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute11    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute12    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute13    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute14    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute15    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute16    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute17    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute18    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute19    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute20    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute21    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute22    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute23    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute24    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute25    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute26    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute27    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute28    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute29    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute30    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute31    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute32    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute33    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute34    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute35    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute36    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute37    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute38    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute39    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute40    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute41    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute42    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute43    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute44    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute45    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute46    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute47    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute48    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute49    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute50    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute51    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute52    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute53    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute54    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute55    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute56    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute57    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute58    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute59    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute60    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute61    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute62    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute63    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute64    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute65    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute66    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute67    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute68    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute69    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute70    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute71    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute72    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute73    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute74    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute75    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute76    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute77    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute78    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute79    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute80    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute81    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute82    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute83    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute84    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute85    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute86    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute87    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute88    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute89    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute90    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute91    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute92    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute93    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute94    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute95    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute96    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute97    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute98    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute99    IN jtf_varchar2_table_300 := NULL,
   p_pricing_attribute100   IN jtf_varchar2_table_300 := NULL,
   p_context                IN jtf_varchar2_table_100 := NULL,
   p_attribute1             IN jtf_varchar2_table_300 := NULL,
   p_attribute2             IN jtf_varchar2_table_300 := NULL,
   p_attribute3             IN jtf_varchar2_table_300 := NULL,
   p_attribute4             IN jtf_varchar2_table_300 := NULL,
   p_attribute5             IN jtf_varchar2_table_300 := NULL,
   p_attribute6             IN jtf_varchar2_table_300 := NULL,
   p_attribute7             IN jtf_varchar2_table_300 := NULL,
   p_attribute8             IN jtf_varchar2_table_300 := NULL,
   p_attribute9             IN jtf_varchar2_table_300 := NULL,
   p_attribute10            IN jtf_varchar2_table_300 := NULL,
   p_attribute11            IN jtf_varchar2_table_300 := NULL,
   p_attribute12            IN jtf_varchar2_table_300 := NULL,
   p_attribute13            IN jtf_varchar2_table_300 := NULL,
   p_attribute14            IN jtf_varchar2_table_300 := NULL,
   p_attribute15            IN jtf_varchar2_table_300 := NULL,
   p_attribute16            IN jtf_varchar2_table_300 := NULL,
   p_attribute17            IN jtf_varchar2_table_300 := NULL,
   p_attribute18            IN jtf_varchar2_table_300 := NULL,
   p_attribute19            IN jtf_varchar2_table_300 := NULL,
   p_attribute20            IN jtf_varchar2_table_300 := NULL,
   p_object_version_number  IN  jtf_number_table      := NULL

)
RETURN ASO_Quote_Pub.Price_Attributes_Tbl_Type
IS
   l_price_attributes_tbl ASO_Quote_Pub.Price_Attributes_Tbl_Type;
   l_table_size           PLS_INTEGER := 0;
   i                      PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
        -- IF p_operation_code IS NOT NULL THEN
         l_price_attributes_tbl(i).operation_code := p_operation_code(i);
        -- END IF;
        IF p_qte_line_index IS NOT NULL THEN
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
        END IF;
        IF p_price_attribute_id IS NOT NULL THEN
         IF p_price_attribute_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).price_attribute_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).price_attribute_id := p_price_attribute_id(i);
         END IF;
        END IF;
        IF p_creation_date IS NOT NULL THEN
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_attributes_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_attributes_tbl(i).creation_date := p_creation_date(i);
         END IF;
        END IF;
        IF p_created_by IS NOT NULL THEN
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).created_by := p_created_by(i);
         END IF;
        END IF;
        IF p_last_update_date IS NOT NULL THEN
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_attributes_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_attributes_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
        END IF;
        IF p_last_updated_by IS NOT NULL THEN
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
        END IF;
        IF p_last_update_login IS NOT NULL THEN
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
        END IF;
        IF p_request_id IS NOT NULL THEN
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).request_id := p_request_id(i);
         END IF;
        END IF;
        IF p_program_application_id IS NOT NULL THEN
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
        END IF;
        IF p_program_id IS NOT NULL THEN
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).program_id := p_program_id(i);
         END IF;
        END IF;
        IF p_program_update_date IS NOT NULL THEN
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_attributes_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_attributes_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
        END IF;
        IF p_quote_header_id IS NOT NULL THEN
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
        END IF;
        IF p_quote_line_id IS NOT NULL THEN
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
        END IF;
        IF p_flex_title IS NOT NULL THEN
         l_price_attributes_tbl(i).flex_title := p_flex_title(i);
        END IF;
        IF p_pricing_context IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_context := p_pricing_context(i);
        END IF;
        IF p_pricing_attribute1 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute1 := p_pricing_attribute1(i);
        END IF;
        IF p_pricing_attribute2 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute2 := p_pricing_attribute2(i);
        END IF;
        IF p_pricing_attribute3 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute3 := p_pricing_attribute3(i);
        END IF;
        IF p_pricing_attribute4 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute4 := p_pricing_attribute4(i);
        END IF;
        IF p_pricing_attribute5 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute5 := p_pricing_attribute5(i);
        END IF;
        IF p_pricing_attribute6 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute6 := p_pricing_attribute6(i);
        END IF;
        IF p_pricing_attribute7 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute7 := p_pricing_attribute7(i);
        END IF;
        IF p_pricing_attribute8 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute8 := p_pricing_attribute8(i);
        END IF;
        IF p_pricing_attribute9 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute9 := p_pricing_attribute9(i);
        END IF;
        IF p_pricing_attribute10 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute10 := p_pricing_attribute10(i);
        END IF;
        IF p_pricing_attribute11 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute11 := p_pricing_attribute11(i);
        END IF;
        IF p_pricing_attribute12 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute12 := p_pricing_attribute12(i);
        END IF;
        IF p_pricing_attribute13 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute13 := p_pricing_attribute13(i);
        END IF;
        IF p_pricing_attribute14 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute14 := p_pricing_attribute14(i);
        END IF;
        IF p_pricing_attribute15 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute15 := p_pricing_attribute15(i);
        END IF;
        IF p_pricing_attribute16 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute16 := p_pricing_attribute16(i);
        END IF;
        IF p_pricing_attribute17 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute17 := p_pricing_attribute17(i);
        END IF;
        IF p_pricing_attribute18 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute18 := p_pricing_attribute18(i);
        END IF;
        IF p_pricing_attribute19 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute19 := p_pricing_attribute19(i);
        END IF;
        IF p_pricing_attribute20 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute20 := p_pricing_attribute20(i);
        END IF;
        IF p_pricing_attribute21 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute21 := p_pricing_attribute21(i);
        END IF;
        IF p_pricing_attribute22 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute22 := p_pricing_attribute22(i);
        END IF;
        IF p_pricing_attribute23 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute23 := p_pricing_attribute23(i);
        END IF;
        IF p_pricing_attribute24 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute24 := p_pricing_attribute24(i);
        END IF;
        IF p_pricing_attribute25 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute25 := p_pricing_attribute25(i);
        END IF;
        IF p_pricing_attribute26 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute26 := p_pricing_attribute26(i);
        END IF;
        IF p_pricing_attribute27 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute27 := p_pricing_attribute27(i);
        END IF;
        IF p_pricing_attribute28 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute28 := p_pricing_attribute28(i);
        END IF;
        IF p_pricing_attribute29 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute29 := p_pricing_attribute29(i);
        END IF;
        IF p_pricing_attribute30 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute30 := p_pricing_attribute30(i);
        END IF;
        IF p_pricing_attribute31 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute31 := p_pricing_attribute31(i);
        END IF;
        IF p_pricing_attribute32 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute32 := p_pricing_attribute32(i);
        END IF;
        IF p_pricing_attribute33 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute33 := p_pricing_attribute33(i);
        END IF;
        IF p_pricing_attribute34 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute34 := p_pricing_attribute34(i);
        END IF;
        IF p_pricing_attribute35 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute35 := p_pricing_attribute35(i);
        END IF;
        IF p_pricing_attribute36 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute36 := p_pricing_attribute36(i);
        END IF;
        IF p_pricing_attribute37 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute37 := p_pricing_attribute37(i);
        END IF;
        IF p_pricing_attribute38 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute38 := p_pricing_attribute38(i);
        END IF;
        IF p_pricing_attribute39 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute39 := p_pricing_attribute39(i);
        END IF;
        IF p_pricing_attribute40 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute40 := p_pricing_attribute40(i);
        END IF;
        IF p_pricing_attribute41 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute41 := p_pricing_attribute41(i);
        END IF;
        IF p_pricing_attribute42 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute42 := p_pricing_attribute42(i);
        END IF;
        IF p_pricing_attribute43 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute43 := p_pricing_attribute43(i);
        END IF;
        IF p_pricing_attribute44 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute44 := p_pricing_attribute44(i);
        END IF;
        IF p_pricing_attribute45 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute45 := p_pricing_attribute45(i);
        END IF;
        IF p_pricing_attribute46 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute46 := p_pricing_attribute46(i);
        END IF;
        IF p_pricing_attribute47 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute47 := p_pricing_attribute47(i);
        END IF;
        IF p_pricing_attribute48 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute48 := p_pricing_attribute48(i);
        END IF;
        IF p_pricing_attribute49 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute49 := p_pricing_attribute49(i);
        END IF;
        IF p_pricing_attribute50 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute50 := p_pricing_attribute50(i);
        END IF;
        IF p_pricing_attribute51 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute51 := p_pricing_attribute51(i);
        END IF;
        IF p_pricing_attribute52 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute52 := p_pricing_attribute52(i);
        END IF;
        IF p_pricing_attribute53 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute53 := p_pricing_attribute53(i);
        END IF;
        IF p_pricing_attribute54 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute54 := p_pricing_attribute54(i);
        END IF;
        IF p_pricing_attribute55 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute55 := p_pricing_attribute55(i);
        END IF;
        IF p_pricing_attribute56 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute56 := p_pricing_attribute56(i);
        END IF;
        IF p_pricing_attribute57 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute57 := p_pricing_attribute57(i);
        END IF;
        IF p_pricing_attribute58 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute58 := p_pricing_attribute58(i);
        END IF;
        IF p_pricing_attribute59 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute59 := p_pricing_attribute59(i);
        END IF;
        IF p_pricing_attribute60 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute60 := p_pricing_attribute60(i);
        END IF;
        IF p_pricing_attribute61 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute61 := p_pricing_attribute61(i);
        END IF;
        IF p_pricing_attribute62 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute62 := p_pricing_attribute62(i);
        END IF;
        IF p_pricing_attribute63 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute63 := p_pricing_attribute63(i);
        END IF;
        IF p_pricing_attribute64 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute64 := p_pricing_attribute64(i);
        END IF;
        IF p_pricing_attribute65 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute65 := p_pricing_attribute65(i);
        END IF;
        IF p_pricing_attribute66 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute66 := p_pricing_attribute66(i);
        END IF;
        IF p_pricing_attribute67 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute67 := p_pricing_attribute67(i);
        END IF;
        IF p_pricing_attribute68 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute68 := p_pricing_attribute68(i);
        END IF;
        IF p_pricing_attribute69 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute69 := p_pricing_attribute69(i);
        END IF;
        IF p_pricing_attribute70 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute70 := p_pricing_attribute70(i);
        END IF;
        IF p_pricing_attribute71 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute71 := p_pricing_attribute71(i);
        END IF;
        IF p_pricing_attribute72 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute72 := p_pricing_attribute72(i);
        END IF;
        IF p_pricing_attribute73 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute73 := p_pricing_attribute73(i);
        END IF;
        IF p_pricing_attribute74 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute74 := p_pricing_attribute74(i);
        END IF;
        IF p_pricing_attribute75 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute75 := p_pricing_attribute75(i);
        END IF;
        IF p_pricing_attribute76 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute76 := p_pricing_attribute76(i);
        END IF;
        IF p_pricing_attribute77 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute77 := p_pricing_attribute77(i);
        END IF;
        IF p_pricing_attribute78 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute78 := p_pricing_attribute78(i);
        END IF;
        IF p_pricing_attribute79 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute79 := p_pricing_attribute79(i);
        END IF;
        IF p_pricing_attribute80 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute80 := p_pricing_attribute80(i);
        END IF;
        IF p_pricing_attribute81 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute81 := p_pricing_attribute81(i);
        END IF;
        IF p_pricing_attribute82 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute82 := p_pricing_attribute82(i);
        END IF;
        IF p_pricing_attribute83 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute83 := p_pricing_attribute83(i);
        END IF;
        IF p_pricing_attribute84 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute84 := p_pricing_attribute84(i);
        END IF;
        IF p_pricing_attribute85 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute85 := p_pricing_attribute85(i);
        END IF;
        IF p_pricing_attribute86 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute86 := p_pricing_attribute86(i);
        END IF;
        IF p_pricing_attribute87 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute87 := p_pricing_attribute87(i);
        END IF;
        IF p_pricing_attribute88 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute88 := p_pricing_attribute88(i);
        END IF;
        IF p_pricing_attribute89 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute89 := p_pricing_attribute89(i);
        END IF;
        IF p_pricing_attribute90 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute90 := p_pricing_attribute90(i);
        END IF;
        IF p_pricing_attribute91 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute91 := p_pricing_attribute91(i);
        END IF;
        IF p_pricing_attribute92 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute92 := p_pricing_attribute92(i);
        END IF;
        IF p_pricing_attribute93 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute93 := p_pricing_attribute93(i);
        END IF;
        IF p_pricing_attribute94 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute94 := p_pricing_attribute94(i);
        END IF;
        IF p_pricing_attribute95 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute95 := p_pricing_attribute95(i);
        END IF;
        IF p_pricing_attribute96 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute96 := p_pricing_attribute96(i);
        END IF;
        IF p_pricing_attribute97 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute97 := p_pricing_attribute97(i);
        END IF;
        IF p_pricing_attribute98 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute98 := p_pricing_attribute98(i);
        END IF;
        IF p_pricing_attribute99 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute99 := p_pricing_attribute99(i);
        END IF;
        IF p_pricing_attribute100 IS NOT NULL THEN
         l_price_attributes_tbl(i).pricing_attribute100 := p_pricing_attribute100(i);
        END IF;
        IF p_context IS NOT NULL THEN
         l_price_attributes_tbl(i).context := p_context(i);
        END IF;
        IF p_attribute1 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute1 := p_attribute1(i);
        END IF;
        IF p_attribute2 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute2 := p_attribute2(i);
        END IF;
        IF p_attribute3 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute3 := p_attribute3(i);
        END IF;
        IF p_attribute4 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute4 := p_attribute4(i);
        END IF;
        IF p_attribute5 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute5 := p_attribute5(i);
        END IF;
        IF p_attribute6 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute6 := p_attribute6(i);
        END IF;
        IF p_attribute7 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute7 := p_attribute7(i);
        END IF;
        IF p_attribute8 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute8 := p_attribute8(i);
        END IF;
        IF p_attribute9 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute9 := p_attribute9(i);
        END IF;
        IF p_attribute10 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute10 := p_attribute10(i);
        END IF;
        IF p_attribute11 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute11 := p_attribute11(i);
        END IF;
        IF p_attribute12 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute12 := p_attribute12(i);
        END IF;
        IF p_attribute13 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute13 := p_attribute13(i);
        END IF;
        IF p_attribute14 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute14 := p_attribute14(i);
        END IF;
        IF p_attribute15 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute15 := p_attribute15(i);
        END IF;
        IF p_attribute16 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute16 := p_attribute16(i);
        END IF;
        IF p_attribute17 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute17 := p_attribute17(i);
        END IF;
        IF p_attribute18 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute18 := p_attribute18(i);
        END IF;
        IF p_attribute19 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute19 := p_attribute19(i);
        END IF;
        IF p_attribute20 IS NOT NULL THEN
         l_price_attributes_tbl(i).attribute20 := p_attribute20(i);
        END IF;
        IF p_object_version_number IS NOT NULL THEN
         IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).object_version_number := p_object_version_number(i);
         END IF;
        END IF;
      END LOOP;

      RETURN l_price_attributes_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_PRICE_ATTRIBUTES_TBL;
   END IF;
END Construct_Price_Attributes_Tbl;


-- there IS total 85 fields here IN line
FUNCTION Construct_Price_Adj_Tbl(
   p_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qte_line_index         IN jtf_number_table       := NULL,
   p_price_adjustment_id    IN jtf_number_table       := NULL,
   p_creation_date          IN jtf_date_table         := NULL,
   p_created_by             IN jtf_number_table       := NULL,
   p_last_update_date       IN jtf_date_table         := NULL,
   p_last_updated_by        IN jtf_number_table       := NULL,
   p_last_update_login      IN jtf_number_table       := NULL,
   p_program_application_id IN jtf_number_table       := NULL,
   p_program_id             IN jtf_number_table       := NULL,
   p_program_update_date    IN jtf_date_table         := NULL,
   p_request_id             IN jtf_number_table       := NULL,
   p_quote_header_id        IN jtf_number_table       := NULL,
   p_quote_line_id          IN jtf_number_table       := NULL,
   p_modifier_header_id     IN jtf_number_table       := NULL,
   p_modifier_line_id       IN jtf_number_table       := NULL,
   p_mod_line_type_code     IN jtf_varchar2_table_100 := NULL,
   p_mod_mech_type_code     IN jtf_varchar2_table_100 := NULL,
   p_modified_from          IN jtf_number_table       := NULL,
   p_modified_to            IN jtf_number_table       := NULL,
   p_operand                IN jtf_number_table       := NULL,
   p_arithmetic_operator    IN jtf_varchar2_table_100 := NULL,
   p_automatic_flag         IN jtf_varchar2_table_100 := NULL,
   p_update_allowable_flag  IN jtf_varchar2_table_100 := NULL,
   p_updated_flag           IN jtf_varchar2_table_100 := NULL,
   p_applied_flag           IN jtf_varchar2_table_100 := NULL,
   p_on_invoice_flag        IN jtf_varchar2_table_100 := NULL,
   p_pricing_phase_id       IN jtf_number_table       := NULL,
   p_attribute_category     IN jtf_varchar2_table_100 := NULL,
   p_attribute1             IN jtf_varchar2_table_300 := NULL,
   p_attribute2             IN jtf_varchar2_table_300 := NULL,
   p_attribute3             IN jtf_varchar2_table_300 := NULL,
   p_attribute4             IN jtf_varchar2_table_300 := NULL,
   p_attribute5             IN jtf_varchar2_table_300 := NULL,
   p_attribute6             IN jtf_varchar2_table_300 := NULL,
   p_attribute7             IN jtf_varchar2_table_300 := NULL,
   p_attribute8             IN jtf_varchar2_table_300 := NULL,
   p_attribute9             IN jtf_varchar2_table_300 := NULL,
   p_attribute10            IN jtf_varchar2_table_300 := NULL,
   p_attribute11            IN jtf_varchar2_table_300 := NULL,
   p_attribute12            IN jtf_varchar2_table_300 := NULL,
   p_attribute13            IN jtf_varchar2_table_300 := NULL,
   p_attribute14            IN jtf_varchar2_table_300 := NULL,
   p_attribute15            IN jtf_varchar2_table_300 := NULL,
   p_orig_sys_discount_ref  IN jtf_varchar2_table_100 := NULL,
   p_change_sequence        IN jtf_varchar2_table_100 := NULL,
   p_update_allowed         IN jtf_varchar2_table_100 := NULL,
   p_change_reason_code     IN jtf_varchar2_table_100 := NULL,
   p_change_reason_text     IN jtf_varchar2_table_2000 := NULL,
   p_cost_id                IN jtf_number_table       := NULL,
   p_tax_code               IN jtf_varchar2_table_100 := NULL,
   p_tax_exempt_flag        IN jtf_varchar2_table_100 := NULL,
   p_tax_exempt_number      IN jtf_varchar2_table_100 := NULL,
   p_tax_exempt_reason_code IN jtf_varchar2_table_100 := NULL,
   p_parent_adjustment_id   IN jtf_number_table       := NULL,
   p_invoiced_flag          IN jtf_varchar2_table_100 := NULL,
   p_estimated_flag         IN jtf_varchar2_table_100 := NULL,
   p_inc_in_sales_perfce    IN jtf_varchar2_table_100 := NULL,
   p_split_action_code      IN jtf_varchar2_table_100 := NULL,
   p_adjusted_amount        IN jtf_number_table       := NULL,
   p_charge_type_code       IN jtf_varchar2_table_100 := NULL,
   p_charge_subtype_code    IN jtf_varchar2_table_100 := NULL,
   p_range_break_quantity   IN jtf_number_table       := NULL,
   p_accrual_conv_rate      IN jtf_number_table       := NULL,
   p_pricing_group_sequence IN jtf_number_table       := NULL,
   p_accrual_flag           IN jtf_varchar2_table_100 := NULL,
   p_list_line_no           IN jtf_varchar2_table_300 := NULL,
   p_source_system_code     IN jtf_varchar2_table_100 := NULL,
   p_benefit_qty            IN jtf_number_table       := NULL,
   p_benefit_uom_code       IN jtf_varchar2_table_100 := NULL,
   p_print_on_invoice_flag  IN jtf_varchar2_table_100 := NULL,
   p_expiration_date        IN jtf_date_table         := NULL,
   p_rebate_trans_type_code IN jtf_varchar2_table_100 := NULL,
   p_rebate_trans_reference IN jtf_varchar2_table_100 := NULL,
   p_rebate_pay_system_code IN jtf_varchar2_table_100 := NULL,
   p_redeemed_date          IN jtf_date_table         := NULL,
   p_redeemed_flag          IN jtf_varchar2_table_100 := NULL,
   p_modifier_level_code    IN jtf_varchar2_table_100 := NULL,
   p_price_break_type_code  IN jtf_varchar2_table_100 := NULL,
   p_substitution_attribute IN jtf_varchar2_table_100 := NULL,
   p_proration_type_code    IN jtf_varchar2_table_100 := NULL,
   p_include_on_ret_flag    IN jtf_varchar2_table_100 := NULL,
   p_credit_or_charge_flag  IN jtf_varchar2_table_100 := NULL,
   p_shipment_index         IN jtf_number_table := NULL,
   p_quote_shipment_id      IN jtf_number_table := NULL,
   p_attribute16            IN jtf_varchar2_table_300 := NULL,
   p_attribute17            IN jtf_varchar2_table_300 := NULL,
   p_attribute18            IN jtf_varchar2_table_300 := NULL,
   p_attribute19            IN jtf_varchar2_table_300 := NULL,
   p_attribute20            IN jtf_varchar2_table_300 := NULL,
   p_object_version_number  IN jtf_number_table       := NULL
)
RETURN ASO_Quote_Pub.Price_Adj_Tbl_Type
IS
   l_price_adj_tbl ASO_Quote_Pub.Price_Adj_Tbl_Type;
   l_table_size  PLS_INTEGER := 0;
   i             PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
        -- IF p_operation_code IS NOT NULL THEN
         l_price_adj_tbl(i).operation_code := p_operation_code(i);
        -- END IF;
        IF p_qte_line_index IS NOT NULL THEN
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
        END IF;
        IF p_price_adjustment_id IS NOT NULL THEN
         IF p_price_adjustment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).price_adjustment_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).price_adjustment_id := p_price_adjustment_id(i);
         END IF;
        END IF;
        IF p_creation_date IS NOT NULL THEN
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).creation_date := p_creation_date(i);
         END IF;
        END IF;
        IF p_created_by IS NOT NULL THEN
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).created_by := p_created_by(i);
         END IF;
        END IF;
        IF p_last_update_date IS NOT NULL THEN
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
        END IF;
        IF p_last_updated_by IS NOT NULL THEN
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
        END IF;
        IF p_last_update_login IS NOT NULL THEN
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
        END IF;
        IF p_program_application_id IS NOT NULL THEN
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
        END IF;
        IF p_program_id IS NOT NULL THEN
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).program_id := p_program_id(i);
         END IF;
        END IF;
        IF p_program_update_date IS NOT NULL THEN
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
        END IF;
        IF p_request_id IS NOT NULL THEN
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).request_id := p_request_id(i);
         END IF;
        END IF;
        IF p_quote_header_id IS NOT NULL THEN
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
        END IF;
        IF p_quote_line_id IS NOT NULL THEN
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
        END IF;
        IF p_modifier_header_id IS NOT NULL THEN
         IF p_modifier_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).modifier_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).modifier_header_id := p_modifier_header_id(i);
         END IF;
        END IF;
        IF p_modifier_line_id IS NOT NULL THEN
         IF p_modifier_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).modifier_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).modifier_line_id := p_modifier_line_id(i);
         END IF;
        END IF;
        IF p_mod_line_type_code IS NOT NULL THEN
         l_price_adj_tbl(i).modifier_line_type_code := p_mod_line_type_code(i);
        END IF;
        IF p_mod_mech_type_code IS NOT NULL THEN
         l_price_adj_tbl(i).modifier_mechanism_type_code := p_mod_mech_type_code(i);
        END IF;
        IF p_modified_from IS NOT NULL THEN
         IF p_modified_from(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).modified_from := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).modified_from := p_modified_from(i);
         END IF;
        END IF;
        IF p_modified_to IS NOT NULL THEN
         IF p_modified_to(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).modified_to := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).modified_to := p_modified_to(i);
         END IF;
        END IF;
        IF p_operand IS NOT NULL THEN
         IF p_operand(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).operand := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).operand := p_operand(i);
         END IF;
        END IF;
        IF p_arithmetic_operator IS NOT NULL THEN
         l_price_adj_tbl(i).arithmetic_operator := p_arithmetic_operator(i);
        END IF;
        IF p_automatic_flag IS NOT NULL THEN
         l_price_adj_tbl(i).automatic_flag := p_automatic_flag(i);
        END IF;
        IF p_update_allowable_flag IS NOT NULL THEN
         l_price_adj_tbl(i).update_allowable_flag := p_update_allowable_flag(i);
        END IF;
        IF p_updated_flag IS NOT NULL THEN
         l_price_adj_tbl(i).updated_flag := p_updated_flag(i);
        END IF;
        IF p_applied_flag IS NOT NULL THEN
         l_price_adj_tbl(i).applied_flag := p_applied_flag(i);
        END IF;
        IF p_on_invoice_flag IS NOT NULL THEN
         l_price_adj_tbl(i).on_invoice_flag := p_on_invoice_flag(i);
        END IF;
        IF p_pricing_phase_id IS NOT NULL THEN
         IF p_pricing_phase_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).pricing_phase_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).pricing_phase_id := p_pricing_phase_id(i);
         END IF;
        END IF;
        IF p_attribute_category IS NOT NULL THEN
         l_price_adj_tbl(i).attribute_category := p_attribute_category(i);
        END IF;
        IF p_attribute1 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute1 := p_attribute1(i);
        END IF;
        IF p_attribute2 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute2 := p_attribute2(i);
        END IF;
        IF p_attribute3 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute3 := p_attribute3(i);
        END IF;
        IF p_attribute4 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute4 := p_attribute4(i);
        END IF;
        IF p_attribute5 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute5 := p_attribute5(i);
        END IF;
        IF p_attribute6 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute6 := p_attribute6(i);
        END IF;
        IF p_attribute7 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute7 := p_attribute7(i);
        END IF;
        IF p_attribute8 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute8 := p_attribute8(i);
        END IF;
        IF p_attribute9 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute9 := p_attribute9(i);
        END IF;
        IF p_attribute10 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute10 := p_attribute10(i);
        END IF;
        IF p_attribute11 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute11 := p_attribute11(i);
        END IF;
        IF p_attribute12 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute12 := p_attribute12(i);
        END IF;
        IF p_attribute13 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute13 := p_attribute13(i);
        END IF;
        IF p_attribute14 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute14 := p_attribute14(i);
        END IF;
        IF p_attribute15 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute15 := p_attribute15(i);
        END IF;
        IF p_orig_sys_discount_ref IS NOT NULL THEN
         l_price_adj_tbl(i).orig_sys_discount_ref := p_orig_sys_discount_ref(i);
        END IF;
        IF p_change_sequence IS NOT NULL THEN
         l_price_adj_tbl(i).change_sequence := p_change_sequence(i);
        END IF;
        IF p_update_allowed IS NOT NULL THEN
         l_price_adj_tbl(i).update_allowed := p_update_allowed(i);
        END IF;
        IF p_change_reason_code IS NOT NULL THEN
         l_price_adj_tbl(i).change_reason_code := p_change_reason_code(i);
        END IF;
        IF p_change_reason_text IS NOT NULL THEN
         l_price_adj_tbl(i).change_reason_text := p_change_reason_text(i);
        END IF;
        IF p_cost_id IS NOT NULL THEN
         IF p_cost_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).cost_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).cost_id := p_cost_id(i);
         END IF;
        END IF;
        IF p_tax_code IS NOT NULL THEN
         l_price_adj_tbl(i).tax_code := p_tax_code(i);
        END IF;
        IF p_tax_exempt_flag IS NOT NULL THEN
         l_price_adj_tbl(i).tax_exempt_flag := p_tax_exempt_flag(i);
        END IF;
        IF p_tax_exempt_number IS NOT NULL THEN
         l_price_adj_tbl(i).tax_exempt_number := p_tax_exempt_number(i);
        END IF;
        IF p_tax_exempt_reason_code IS NOT NULL THEN
         l_price_adj_tbl(i).tax_exempt_reason_code := p_tax_exempt_reason_code(i);
        END IF;
        IF p_parent_adjustment_id IS NOT NULL THEN
         IF p_parent_adjustment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).parent_adjustment_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).parent_adjustment_id := p_parent_adjustment_id(i);
         END IF;
        END IF;
        IF p_invoiced_flag IS NOT NULL THEN
         l_price_adj_tbl(i).invoiced_flag := p_invoiced_flag(i);
        END IF;
        IF p_estimated_flag IS NOT NULL THEN
         l_price_adj_tbl(i).estimated_flag := p_estimated_flag(i);
        END IF;
        IF p_inc_in_sales_perfce IS NOT NULL THEN
         l_price_adj_tbl(i).inc_in_sales_performance := p_inc_in_sales_perfce(i);
        END IF;
        IF p_split_action_code IS NOT NULL THEN
         l_price_adj_tbl(i).split_action_code := p_split_action_code(i);
        END IF;
        IF p_adjusted_amount IS NOT NULL THEN
         IF p_adjusted_amount(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).adjusted_amount := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).adjusted_amount := p_adjusted_amount(i);
         END IF;
        END IF;
        IF p_charge_type_code IS NOT NULL THEN
         l_price_adj_tbl(i).charge_type_code := p_charge_type_code(i);
        END IF;
        IF p_charge_subtype_code IS NOT NULL THEN
         l_price_adj_tbl(i).charge_subtype_code := p_charge_subtype_code(i);
        END IF;
        IF p_range_break_quantity IS NOT NULL THEN
         IF p_range_break_quantity(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).range_break_quantity := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).range_break_quantity := p_range_break_quantity(i);
         END IF;
        END IF;
        IF p_accrual_conv_rate IS NOT NULL THEN
         IF p_accrual_conv_rate(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).accrual_conversion_rate := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).accrual_conversion_rate := p_accrual_conv_rate(i);
         END IF;
        END IF;
        IF p_pricing_group_sequence IS NOT NULL THEN
         IF p_pricing_group_sequence(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).pricing_group_sequence := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).pricing_group_sequence := p_pricing_group_sequence(i);
         END IF;
        END IF;
        IF p_accrual_flag IS NOT NULL THEN
         l_price_adj_tbl(i).accrual_flag := p_accrual_flag(i);
        END IF;
        IF p_list_line_no IS NOT NULL THEN
         l_price_adj_tbl(i).list_line_no := p_list_line_no(i);
        END IF;
        IF p_source_system_code IS NOT NULL THEN
         l_price_adj_tbl(i).source_system_code := p_source_system_code(i);
        END IF;
        IF p_benefit_qty IS NOT NULL THEN
         IF p_benefit_qty(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).benefit_qty := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).benefit_qty := p_benefit_qty(i);
         END IF;
        END IF;
        IF p_benefit_uom_code IS NOT NULL THEN
         l_price_adj_tbl(i).benefit_uom_code := p_benefit_uom_code(i);
         END IF;
        IF p_print_on_invoice_flag IS NOT NULL THEN
         l_price_adj_tbl(i).print_on_invoice_flag := p_print_on_invoice_flag(i);
        END IF;
        IF p_expiration_date IS NOT NULL THEN
         IF p_expiration_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).expiration_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).expiration_date := p_expiration_date(i);
         END IF;
        END IF;
        IF p_rebate_trans_type_code IS NOT NULL THEN
         l_price_adj_tbl(i).rebate_transaction_type_code := p_rebate_trans_type_code(i);
        END IF;
        IF p_rebate_trans_reference IS NOT NULL THEN
         l_price_adj_tbl(i).rebate_transaction_reference := p_rebate_trans_reference(i);
        END IF;
        IF p_rebate_pay_system_code IS NOT NULL THEN
         l_price_adj_tbl(i).rebate_payment_system_code := p_rebate_pay_system_code(i);
        END IF;
        IF p_redeemed_date IS NOT NULL THEN
         IF p_redeemed_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).redeemed_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).redeemed_date := p_redeemed_date(i);
         END IF;
        END IF;
        IF p_redeemed_flag IS NOT NULL THEN
         l_price_adj_tbl(i).redeemed_flag := p_redeemed_flag(i);
        END IF;
        IF p_modifier_level_code IS NOT NULL THEN
         l_price_adj_tbl(i).modifier_level_code := p_modifier_level_code(i);
        END IF;
        IF p_price_break_type_code IS NOT NULL THEN
         l_price_adj_tbl(i).price_break_type_code := p_price_break_type_code(i);
        END IF;
        IF p_substitution_attribute IS NOT NULL THEN
         l_price_adj_tbl(i).substitution_attribute := p_substitution_attribute(i);
        END IF;
        IF p_proration_type_code IS NOT NULL THEN
         l_price_adj_tbl(i).proration_type_code := p_proration_type_code(i);
        END IF;
        IF p_include_on_ret_flag IS NOT NULL THEN
         l_price_adj_tbl(i).include_on_returns_flag := p_include_on_ret_flag(i);
        END IF;
        IF p_credit_or_charge_flag IS NOT NULL THEN
         l_price_adj_tbl(i).credit_or_charge_flag := p_credit_or_charge_flag(i);
        END IF;
        IF p_shipment_index IS NOT NULL THEN
         IF p_shipment_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).shipment_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).shipment_index := p_shipment_index(i);
         END IF;
        END IF;
        IF p_quote_shipment_id IS NOT NULL THEN
         IF p_quote_shipment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).quote_shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).quote_shipment_id := p_quote_shipment_id(i);
         END IF;
        END IF;
        IF p_attribute16 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute16 := p_attribute16(i);
        END IF;
        IF p_attribute17 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute17 := p_attribute17(i);
        END IF;
        IF p_attribute18 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute18 := p_attribute18(i);
        END IF;
        IF p_attribute19 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute19 := p_attribute19(i);
        END IF;
        IF p_attribute20 IS NOT NULL THEN
         l_price_adj_tbl(i).attribute20 := p_attribute20(i);
        END IF;
        IF p_object_version_number IS NOT NULL THEN
         IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).object_version_number := p_object_version_number(i);
         END IF;
        END IF;


      END LOOP;

      RETURN l_price_adj_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_PRICE_ADJ_TBL;
   END IF;
END Construct_Price_Adj_Tbl;


-- there IS total 38 fields here IN line
FUNCTION Construct_Sales_Credit_Tbl(
   p_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qte_line_index         IN jtf_number_table       := NULL,
   p_sales_credit_id        IN jtf_number_table       := NULL,
   p_creation_date          IN jtf_date_table         := NULL,
   p_created_by             IN jtf_number_table       := NULL,
   p_last_updated_by        IN jtf_varchar2_table_300 := NULL,
   p_last_update_date       IN jtf_date_table         := NULL,
   p_last_update_login      IN jtf_number_table       := NULL,
   p_request_id             IN jtf_number_table       := NULL,
   p_program_application_id IN jtf_number_table       := NULL,
   p_program_id             IN jtf_number_table       := NULL,
   p_program_update_date    IN jtf_date_table         := NULL,
   p_quote_header_id        IN jtf_number_table       := NULL,
   p_quote_line_id          IN jtf_number_table       := NULL,
   p_percent                IN jtf_number_table       := NULL,
   p_resource_id            IN jtf_number_table       := NULL,
   p_first_name             IN jtf_varchar2_table_300 := NULL,
   p_last_name              IN jtf_varchar2_table_300 := NULL,
   p_sales_credit_type      IN jtf_varchar2_table_300 := NULL,
   p_resource_group_id      IN jtf_number_table       := NULL,
   p_employee_person_id     IN jtf_number_table       := NULL,
   p_sales_credit_type_id   IN jtf_number_table       := NULL,
   p_attribute_category     IN jtf_varchar2_table_100 := NULL,
   p_attribute1             IN jtf_varchar2_table_300 := NULL,
   p_attribute2             IN jtf_varchar2_table_300 := NULL,
   p_attribute3             IN jtf_varchar2_table_300 := NULL,
   p_attribute4             IN jtf_varchar2_table_300 := NULL,
   p_attribute5             IN jtf_varchar2_table_300 := NULL,
   p_attribute6             IN jtf_varchar2_table_300 := NULL,
   p_attribute7             IN jtf_varchar2_table_300 := NULL,
   p_attribute8             IN jtf_varchar2_table_300 := NULL,
   p_attribute9             IN jtf_varchar2_table_300 := NULL,
   p_attribute10            IN jtf_varchar2_table_300 := NULL,
   p_attribute11            IN jtf_varchar2_table_300 := NULL,
   p_attribute12            IN jtf_varchar2_table_300 := NULL,
   p_attribute13            IN jtf_varchar2_table_300 := NULL,
   p_attribute14            IN jtf_varchar2_table_300 := NULL,
   p_attribute15            IN jtf_varchar2_table_300 := NULL,
   p_system_assigned_flag     IN jtf_varchar2_table_100 := NULL,
   p_credit_rule_id         IN jtf_number_table       := NULL,
   p_attribute16            IN jtf_varchar2_table_300 := NULL,
   p_attribute17            IN jtf_varchar2_table_300 := NULL,
   p_attribute18            IN jtf_varchar2_table_300 := NULL,
   p_attribute19            IN jtf_varchar2_table_300 := NULL,
   p_attribute20            IN jtf_varchar2_table_300 := NULL,
   p_object_version_number  IN jtf_number_table       := NULL

)
RETURN ASO_Quote_Pub.Sales_Credit_Tbl_Type
IS
   l_sales_credit_tbl ASO_Quote_Pub.Sales_Credit_Tbl_Type;
   l_table_size     PLS_INTEGER := 0;
   i                PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
        -- IF p_operation_code IS NOT NULL THEN
         l_sales_credit_tbl(i).operation_code := p_operation_code(i);
        -- END IF;
        IF p_qte_line_index IS NOT NULL THEN
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
        END IF;
        IF p_sales_credit_id IS NOT NULL THEN
         IF p_sales_credit_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).sales_credit_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).sales_credit_id := p_sales_credit_id(i);
         END IF;
        END IF;
        IF p_creation_date IS NOT NULL THEN
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_sales_credit_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_sales_credit_tbl(i).creation_date := p_creation_date(i);
         END IF;
        END IF;
        IF p_created_by IS NOT NULL THEN
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).created_by := p_created_by(i);
         END IF;
        END IF;
        IF p_last_updated_by IS NOT NULL THEN
            l_sales_credit_tbl(i).last_updated_by := p_last_updated_by(i);
        END IF;
        IF p_last_update_date IS NOT NULL THEN
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_sales_credit_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_sales_credit_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
        END IF;
        IF p_last_update_login IS NOT NULL THEN
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
        END IF;
        IF p_request_id IS NOT NULL THEN
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).request_id := p_request_id(i);
         END IF;
        END IF;
        IF p_program_application_id IS NOT NULL THEN
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
        END IF;
        IF p_program_id IS NOT NULL THEN
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).program_id := p_program_id(i);
         END IF;
        END IF;
        IF p_program_update_date IS NOT NULL THEN
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_sales_credit_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_sales_credit_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
        END IF;
        IF p_quote_header_id IS NOT NULL THEN
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
        END IF;
        IF p_quote_line_id IS NOT NULL THEN
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
        END IF;
        IF p_percent IS NOT NULL THEN
         IF p_percent(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).percent := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).percent := p_percent(i);
         END IF;
        END IF;
        IF p_resource_id IS NOT NULL THEN
         IF p_resource_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).resource_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).resource_id := p_resource_id(i);
         END IF;
        END IF;
        IF p_first_name IS NOT NULL THEN
         l_sales_credit_tbl(i).first_name := p_first_name(i);
        END IF;
        IF p_last_name IS NOT NULL THEN
         l_sales_credit_tbl(i).last_name := p_last_name(i);
        END IF;
        IF p_sales_credit_type IS NOT NULL THEN
         l_sales_credit_tbl(i).sales_credit_type := p_sales_credit_type(i);
        END IF;
        IF p_resource_group_id IS NOT NULL THEN
         IF p_resource_group_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).resource_group_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).resource_group_id := p_resource_group_id(i);
         END IF;
        END IF;
        IF p_employee_person_id IS NOT NULL THEN
         IF p_employee_person_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).employee_person_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).employee_person_id := p_employee_person_id(i);
         END IF;
        END IF;
        IF p_sales_credit_type_id IS NOT NULL THEN
         IF p_sales_credit_type_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).sales_credit_type_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).sales_credit_type_id := p_sales_credit_type_id(i);
         END IF;
        END IF;
        IF p_attribute_category IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute_category_code := p_attribute_category(i);
        END IF;
        IF p_attribute1 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute1 := p_attribute1(i);
        END IF;
        IF p_attribute2 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute2 := p_attribute2(i);
        END IF;
        IF p_attribute3 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute3 := p_attribute3(i);
        END IF;
        IF p_attribute4 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute4 := p_attribute4(i);
        END IF;
        IF p_attribute5 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute5 := p_attribute5(i);
        END IF;
        IF p_attribute6 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute6 := p_attribute6(i);
        END IF;
        IF p_attribute7 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute7 := p_attribute7(i);
        END IF;
        IF p_attribute8 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute8 := p_attribute8(i);
        END IF;
        IF p_attribute9 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute9 := p_attribute9(i);
        END IF;
        IF p_attribute10 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute10 := p_attribute10(i);
        END IF;
        IF p_attribute11 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute11 := p_attribute11(i);
        END IF;
        IF p_attribute12 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute12 := p_attribute12(i);
        END IF;
        IF p_attribute13 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute13 := p_attribute13(i);
        END IF;
        IF p_attribute14 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute14 := p_attribute14(i);
        END IF;
        IF p_attribute15 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute15 := p_attribute15(i);
        END IF;
        IF p_attribute16 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute16 := p_attribute16(i);
        END IF;
        IF p_attribute17 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute17 := p_attribute17(i);
        END IF;
        IF p_attribute18 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute18 := p_attribute18(i);
        END IF;
        IF p_attribute19 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute19 := p_attribute19(i);
        END IF;
        IF p_attribute20 IS NOT NULL THEN
         l_sales_credit_tbl(i).attribute20 := p_attribute20(i);
        END IF;

      IF p_system_assigned_flag IS NOT NULL THEN
       l_sales_credit_tbl(i).system_assigned_flag := p_system_assigned_flag(i);
      END IF;
      IF p_credit_rule_id IS NOT NULL THEN
       IF p_credit_rule_id(i)= ROSETTA_G_MISS_NUM THEN
          l_sales_credit_tbl(i).credit_rule_id := FND_API.G_MISS_NUM;
       ELSE
          l_sales_credit_tbl(i).credit_rule_id := p_credit_rule_id(i);
       END IF;
      END IF;

      IF p_object_version_number IS NOT NULL THEN
       IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
          l_sales_credit_tbl(i).object_version_number := FND_API.G_MISS_NUM;
       ELSE
          l_sales_credit_tbl(i).object_version_number := p_object_version_number(i);
       END IF;
      END IF;

    END LOOP;
      RETURN l_sales_credit_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_SALES_CREDIT_TBL;
   END IF;
END Construct_Sales_Credit_Tbl;

-- there IS total 14 fields here IN line
FUNCTION Construct_Opp_Qte_In_Rec(
   p_opportunity_id             IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_number               IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_name                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_cust_account_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_resource_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_sold_to_contact_id         IN NUMBER   := FND_API.G_MISS_NUM,
   p_sold_to_party_site_id      IN NUMBER   := FND_API.G_MISS_NUM,
   p_price_list_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_resource_grp_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_channel_code               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_order_type_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_agreement_id               IN NUMBER   := FND_API.G_MISS_NUM,
   p_contract_template_id       IN NUMBER   := FND_API.G_MISS_NUM,
   p_contract_template_maj_ver  IN NUMBER   := FND_API.G_MISS_NUM,
   p_currency_code              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_marketing_source_code_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_expiration_date      IN DATE     := FND_API.G_MISS_DATE,
   p_cust_party_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_pricing_status_indicator   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_tax_status_indicator       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_updated_date         IN DATE     := FND_API.G_MISS_DATE,
   p_tax_updated_date           IN DATE     := FND_API.G_MISS_DATE,
   p_org_id                     IN NUMBER   := FND_API.G_MISS_NUM
)
RETURN ASO_Opp_Qte_Pub.Opp_Qte_In_Rec_Type
IS
   l_opp_qte_in  ASO_Opp_Qte_Pub.Opp_Qte_In_Rec_Type;
BEGIN
   IF p_opportunity_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.opportunity_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.opportunity_id := p_opportunity_id;
   END IF;
   IF p_quote_number= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.quote_number := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.quote_number := p_quote_number;
   END IF;
   l_opp_qte_in.quote_name := p_quote_name;
   IF p_cust_account_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.cust_account_id := p_cust_account_id;
   END IF;
   IF p_resource_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.resource_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.resource_id := p_resource_id;
   END IF;
   IF p_sold_to_contact_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.sold_to_contact_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.sold_to_contact_id := p_sold_to_contact_id;
   END IF;
   IF p_sold_to_party_site_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.sold_to_party_site_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.sold_to_party_site_id := p_sold_to_party_site_id;
   END IF;
   IF p_price_list_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.price_list_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.price_list_id := p_price_list_id;
   END IF;
   IF p_resource_grp_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.resource_grp_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.resource_grp_id := p_resource_grp_id;
   END IF;
   l_opp_qte_in.channel_code := p_channel_code;
   IF p_order_type_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.order_type_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.order_type_id := p_order_type_id;
   END IF;
   IF p_agreement_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.agreement_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.agreement_id := p_agreement_id;
   END IF;
   IF p_contract_template_id= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.contract_template_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.contract_template_id := p_contract_template_id;
   END IF;
   IF p_contract_template_maj_ver= ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.contract_template_major_ver := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.contract_template_major_ver := p_contract_template_maj_ver;
   END IF;
   l_opp_qte_in.currency_code := p_currency_code;
   IF p_marketing_source_code_id = ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.marketing_source_code_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.marketing_source_code_id := p_marketing_source_code_id;
   END IF;
   IF p_quote_expiration_date = ROSETTA_G_MISTAKE_DATE THEN
      l_opp_qte_in.quote_expiration_date := FND_API.G_MISS_DATE;
   ELSE
      l_opp_qte_in.quote_expiration_date := p_quote_expiration_date;
   END IF;
   IF p_cust_party_id = ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.cust_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.cust_party_id := p_cust_party_id;
   END IF;
   l_opp_qte_in.pricing_status_indicator := p_pricing_status_indicator;
   l_opp_qte_in.tax_status_indicator := p_tax_status_indicator;
   IF p_price_updated_date = ROSETTA_G_MISTAKE_DATE THEN
      l_opp_qte_in.price_updated_date := FND_API.G_MISS_DATE;
   ELSE
      l_opp_qte_in.price_updated_date := p_price_updated_date;
   END IF;
   IF p_tax_updated_date = ROSETTA_G_MISTAKE_DATE THEN
      l_opp_qte_in.tax_updated_date := FND_API.G_MISS_DATE;
   ELSE
      l_opp_qte_in.tax_updated_date := p_tax_updated_date;
   END IF;
   RETURN l_opp_qte_in;

   IF p_org_id = ROSETTA_G_MISS_NUM THEN
      l_opp_qte_in.org_id := FND_API.G_MISS_NUM;
   ELSE
      l_opp_qte_in.org_id := p_org_id;
   END IF;


END Construct_Opp_Qte_In_Rec;

-- there IS total 35 fields in Qte_Access_Tbl
FUNCTION Construct_Qte_Access_Tbl(
   p_access_id                  IN jtf_number_table       := NULL,
   p_quote_number               IN jtf_number_table       := NULL,
   p_resource_id                IN jtf_number_table       := NULL,
   p_resource_grp_id            IN jtf_number_table       := NULL,
   p_created_by                 IN jtf_number_table       := NULL,
   p_creation_date              IN jtf_date_table         := NULL,
   p_last_updated_by            IN jtf_number_table       := NULL,
   p_last_update_login          IN jtf_number_table       := NULL,
   p_last_update_date           IN jtf_date_table         := NULL,
   p_request_id                 IN jtf_number_table       := NULL,
   p_program_application_id     IN jtf_number_table       := NULL,
   p_program_id                 IN jtf_number_table       := NULL,
   p_program_update_date        IN jtf_date_table         := NULL,
   p_keep_flag                  IN jtf_varchar2_table_100 := NULL,
   p_update_access_flag         IN jtf_varchar2_table_100 := NULL,
   p_created_by_tap_flag        IN jtf_varchar2_table_100 := NULL,
   p_role_id                	  IN jtf_number_table       := NULL,
   p_territory_id           	  IN jtf_number_table       := NULL,
   p_territory_source_flag  	  IN jtf_varchar2_table_100 := NULL,
   p_attribute_category         IN jtf_varchar2_table_100 := NULL,
   p_attribute1                 IN jtf_varchar2_table_300 := NULL,
   p_attribute2                 IN jtf_varchar2_table_300 := NULL,
   p_attribute3                 IN jtf_varchar2_table_300 := NULL,
   p_attribute4                 IN jtf_varchar2_table_300 := NULL,
   p_attribute5                 IN jtf_varchar2_table_300 := NULL,
   p_attribute6                 IN jtf_varchar2_table_300 := NULL,
   p_attribute7                 IN jtf_varchar2_table_300 := NULL,
   p_attribute8                 IN jtf_varchar2_table_300 := NULL,
   p_attribute9                 IN jtf_varchar2_table_300 := NULL,
   p_attribute10                IN jtf_varchar2_table_300 := NULL,
   p_attribute11                IN jtf_varchar2_table_300 := NULL,
   p_attribute12                IN jtf_varchar2_table_300 := NULL,
   p_attribute13                IN jtf_varchar2_table_300 := NULL,
   p_attribute14                IN jtf_varchar2_table_300 := NULL,
   p_attribute15                IN jtf_varchar2_table_300 := NULL,
   p_attribute16                IN jtf_varchar2_table_300 := NULL,
   p_attribute17                IN jtf_varchar2_table_300 := NULL,
   p_attribute18                IN jtf_varchar2_table_300 := NULL,
   p_attribute19                IN jtf_varchar2_table_300 := NULL,
   p_attribute20                IN jtf_varchar2_table_300 := NULL,
   p_object_version_number      IN jtf_number_table       := NULL,
   p_batch_price_flag           IN jtf_varchar2_table_100 := NULL,
   p_operation_code             IN jtf_varchar2_table_100 := NULL
)
RETURN ASO_QUOTE_PUB.Qte_Access_Tbl_Type
IS
   l_qte_access_tbl ASO_QUOTE_PUB.Qte_Access_Tbl_Type;
   l_table_size       PLS_INTEGER := 0;
   i                  PLS_INTEGER;
BEGIN
   IF p_access_id IS NOT NULL THEN
      l_table_size := p_access_id.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
        -- IF p_access_id IS NOT NULL THEN
         IF p_access_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).access_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).access_id := p_access_id(i);
         END IF;
        -- END IF;
        IF p_quote_number IS NOT NULL THEN
         IF p_quote_number(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).quote_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).quote_number := p_quote_number(i);
         END IF;
        END IF;
        IF p_resource_id IS NOT NULL THEN
         IF p_resource_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).resource_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).resource_id := p_resource_id(i);
         END IF;
        END IF;
        IF p_resource_grp_id IS NOT NULL THEN
         IF p_resource_grp_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).resource_grp_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).resource_grp_id := p_resource_grp_id(i);
         END IF;
        END IF;
        IF p_creation_date IS NOT NULL THEN
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_access_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_access_tbl(i).creation_date := p_creation_date(i);
         END IF;
        END IF;
        IF p_created_by IS NOT NULL THEN
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).created_by := p_created_by(i);
         END IF;
        END IF;
        IF p_last_update_date IS NOT NULL THEN
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_access_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_access_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
        END IF;
        IF p_last_updated_by IS NOT NULL THEN
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
        END IF;
        IF p_last_update_login IS NOT NULL THEN
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
        END IF;
        IF p_request_id IS NOT NULL THEN
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).request_id := p_request_id(i);
         END IF;
        END IF;
        IF p_program_application_id IS NOT NULL THEN
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
        END IF;
        IF p_program_id IS NOT NULL THEN
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).program_id := p_program_id(i);
         END IF;
        END IF;
        IF p_program_update_date IS NOT NULL THEN
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_access_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_access_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
        END IF;
        IF p_keep_flag IS NOT NULL THEN
         l_qte_access_tbl(i).keep_flag := p_keep_flag(i);
        END IF;
        IF p_update_access_flag IS NOT NULL THEN
         l_qte_access_tbl(i).update_access_flag := p_update_access_flag(i);
        END IF;
        IF p_created_by_tap_flag IS NOT NULL THEN
         l_qte_access_tbl(i).created_by_tap_flag := p_created_by_tap_flag(i);
        END IF;
        IF p_role_id IS NOT NULL THEN
         IF p_role_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).role_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).role_id := p_role_id(i);
         END IF;
        END IF;
        IF p_territory_id IS NOT NULL THEN
         IF p_territory_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).territory_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).territory_id := p_territory_id(i);
         END IF;
        END IF;
        IF p_territory_source_flag IS NOT NULL THEN
         l_qte_access_tbl(i).territory_source_flag := p_territory_source_flag(i);
        END IF;
        IF p_attribute_category IS NOT NULL THEN
         l_qte_access_tbl(i).attribute_category := p_attribute_category(i);
        END IF;
        IF p_attribute1 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute1 := p_attribute1(i);
        END IF;
        IF p_attribute2 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute2 := p_attribute2(i);
        END IF;
        IF p_attribute3 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute3 := p_attribute3(i);
        END IF;
        IF p_attribute4 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute4 := p_attribute4(i);
        END IF;
        IF p_attribute5 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute5 := p_attribute5(i);
        END IF;
        IF p_attribute6 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute6 := p_attribute6(i);
        END IF;
        IF p_attribute7 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute7 := p_attribute7(i);
        END IF;
        IF p_attribute8 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute8 := p_attribute8(i);
        END IF;
        IF p_attribute9 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute9 := p_attribute9(i);
        END IF;
        IF p_attribute10 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute10 := p_attribute10(i);
        END IF;
        IF p_attribute11 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute11 := p_attribute11(i);
        END IF;
        IF p_attribute12 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute12 := p_attribute12(i);
        END IF;
        IF p_attribute13 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute13 := p_attribute13(i);
        END IF;
        IF p_attribute14 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute14 := p_attribute14(i);
        END IF;
        IF p_attribute15 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute15 := p_attribute15(i);
        END IF;
        IF p_attribute16 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute16 := p_attribute16(i);
        END IF;
        IF p_attribute17 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute17 := p_attribute17(i);
        END IF;
        IF p_attribute18 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute18 := p_attribute18(i);
        END IF;
        IF p_attribute19 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute19 := p_attribute19(i);
        END IF;
        IF p_attribute20 IS NOT NULL THEN
         l_qte_access_tbl(i).attribute20 := p_attribute20(i);
        END IF;
        IF p_object_version_number IS NOT NULL THEN
         IF p_object_version_number(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_access_tbl(i).object_version_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_access_tbl(i).object_version_number := p_object_version_number(i);
         END IF;
        END IF;

        IF p_operation_code IS NOT NULL THEN
         l_qte_access_tbl(i).operation_code := p_operation_code(i);
        END IF;

      END LOOP;

      RETURN l_qte_access_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_QTE_ACCESS_TBL;
   END IF;
END Construct_Qte_Access_Tbl;

-- there IS total 7 fields here IN line
FUNCTION Construct_Copy_Qte_Hdr_Rec(
   p_quote_header_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_name                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_number               IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_source_code          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_expiration_date      IN DATE     := FND_API.G_MISS_DATE,
   p_resource_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_resource_grp_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_pricing_status_indicator   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_tax_status_indicator       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_updated_date         IN DATE     := FND_API.G_MISS_DATE,
   p_tax_updated_date           IN DATE     := FND_API.G_MISS_DATE

)
RETURN ASO_Copy_Quote_Pub.Copy_Quote_Header_Rec_Type
IS
   l_copy_qte_hdr  ASO_Copy_Quote_Pub.Copy_Quote_Header_Rec_Type;
BEGIN
   IF p_quote_header_id= ROSETTA_G_MISS_NUM THEN
      l_copy_qte_hdr.quote_header_id := FND_API.G_MISS_NUM;
   ELSE
      l_copy_qte_hdr.quote_header_id := p_quote_header_id;
   END IF;
   l_copy_qte_hdr.quote_name := p_quote_name;
   IF p_quote_number= ROSETTA_G_MISS_NUM THEN
      l_copy_qte_hdr.quote_number := FND_API.G_MISS_NUM;
   ELSE
      l_copy_qte_hdr.quote_number := p_quote_number;
   END IF;
   l_copy_qte_hdr.quote_source_code := p_quote_source_code;
   IF p_quote_expiration_date= ROSETTA_G_MISTAKE_DATE THEN
     l_copy_qte_hdr.quote_expiration_date := FND_API.G_MISS_DATE;
   ELSE
     l_copy_qte_hdr.quote_expiration_date := p_quote_expiration_date;
   END IF;
   IF p_resource_id= ROSETTA_G_MISS_NUM THEN
      l_copy_qte_hdr.resource_id := FND_API.G_MISS_NUM;
   ELSE
      l_copy_qte_hdr.resource_id := p_resource_id;
   END IF;
   IF p_resource_grp_id= ROSETTA_G_MISS_NUM THEN
      l_copy_qte_hdr.resource_grp_id := FND_API.G_MISS_NUM;
   ELSE
      l_copy_qte_hdr.resource_grp_id := p_resource_grp_id;
   END IF;

   l_copy_qte_hdr.pricing_status_indicator := p_pricing_status_indicator;
   l_copy_qte_hdr.tax_status_indicator := p_tax_status_indicator;
   IF p_price_updated_date= ROSETTA_G_MISTAKE_DATE THEN
     l_copy_qte_hdr.price_updated_date := FND_API.G_MISS_DATE;
   ELSE
     l_copy_qte_hdr.price_updated_date := p_price_updated_date;
   END IF;
   IF p_tax_updated_date= ROSETTA_G_MISTAKE_DATE THEN
     l_copy_qte_hdr.tax_updated_date := FND_API.G_MISS_DATE;
   ELSE
     l_copy_qte_hdr.tax_updated_date := p_tax_updated_date;
   END IF;
   RETURN l_copy_qte_hdr;
END Construct_Copy_Qte_Hdr_Rec;

-- there is total 2 fields in Instance_Tbl
FUNCTION Construct_Instance_Tbl(
   p_instance_id                  IN jtf_number_table       := NULL,
   p_price_list_id                IN jtf_number_table       := NULL
)
RETURN ASO_Quote_Headers_PVT.Instance_Tbl_Type
IS
   l_instance_tbl ASO_Quote_Headers_Pvt.Instance_Tbl_Type;
   l_table_size       PLS_INTEGER := 0;
   i                  PLS_INTEGER;
BEGIN
   IF p_instance_id IS NOT NULL THEN
      l_table_size := p_instance_id.COUNT;
   END IF;
   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         IF p_instance_id(i)= ROSETTA_G_MISS_NUM THEN
            l_instance_tbl(i).instance_id := FND_API.G_MISS_NUM;
         ELSE
            l_instance_tbl(i).instance_id := p_instance_id(i);
         END IF;
         IF p_price_list_id(i)= ROSETTA_G_MISS_NUM THEN
            l_instance_tbl(i).price_list_id := FND_API.G_MISS_NUM;
         ELSE
            l_instance_tbl(i).price_list_id := p_price_list_id(i);
         END IF;
      END LOOP;
      RETURN l_instance_tbl;
   ELSE
      RETURN ASO_Quote_Headers_Pvt.G_MISS_Instance_Tbl;
   END IF;
END Construct_Instance_Tbl;


-- there IS total 11 fields here IN line
PROCEDURE Set_Control_Rec_W(
   p_last_update_date               DATE     := FND_API.G_MISS_DATE,
   p_auto_version_flag              VARCHAR2 := FND_API.G_MISS_CHAR,
   p_pricing_request_type           VARCHAR2 := FND_API.G_MISS_CHAR,
   p_header_pricing_event           VARCHAR2 := FND_API.G_MISS_CHAR,
   p_line_pricing_event             VARCHAR2 := FND_API.G_MISS_CHAR,
   p_cal_tax_flag                   VARCHAR2 := FND_API.G_MISS_CHAR,
   p_cal_freight_charge_flag        VARCHAR2 := FND_API.G_MISS_CHAR,
   p_functionality_code             VARCHAR2 := FND_API.G_MISS_CHAR,
   p_copy_task_flag                 VARCHAR2 := FND_API.G_MISS_CHAR,
   p_copy_notes_flag                VARCHAR2 := FND_API.G_MISS_CHAR,
   p_copy_att_flag                  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_deactivate_all                 VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_mode                     VARCHAR2 := FND_API.G_MISS_CHAR,
   p_dependency_flag                VARCHAR2 := FND_API.G_MISS_CHAR,
   p_defaulting_flag                VARCHAR2 := FND_API.G_MISS_CHAR,
   p_defaulting_fwk_flag            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_application_type_code          VARCHAR2 := FND_API.G_MISS_CHAR,
   x_control_rec                    OUT NOCOPY  ASO_Quote_Pub.Control_Rec_Type
)
IS
BEGIN
   IF p_last_update_date = ROSETTA_G_MISTAKE_DATE THEN
      x_control_rec.last_update_date := FND_API.G_MISS_DATE;
   ELSE
      x_control_rec.last_update_date := p_last_update_date;
   END IF;
   x_control_rec.auto_version_flag := p_auto_version_flag;
   x_control_rec.pricing_request_type := p_pricing_request_type;
   x_control_rec.header_pricing_event := p_header_pricing_event;
   x_control_rec.line_pricing_event := p_line_pricing_event;
   x_control_rec.calculate_tax_flag := p_cal_tax_flag;
   x_control_rec.calculate_freight_charge_flag := p_cal_freight_charge_flag;
   x_control_rec.functionality_code := p_functionality_code;
   x_control_rec.copy_task_flag := p_copy_task_flag;
   x_control_rec.copy_notes_flag := p_copy_notes_flag;
   x_control_rec.copy_att_flag := p_copy_att_flag;
   x_control_rec.deactivate_all := p_deactivate_all;
   x_control_rec.price_mode := p_price_mode;
   x_control_rec.dependency_flag := p_dependency_flag;
   x_control_rec.defaulting_flag := p_defaulting_flag;
   x_control_rec.defaulting_fwk_flag := p_defaulting_fwk_flag;
   x_control_rec.application_type_code := p_application_type_code;

END Set_Control_Rec_W;

PROCEDURE Set_Def_Control_Rec_W(
   p_dc_override_Trigger_Flag      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_dc_dependency_Flag            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_dc_defaulting_Flag            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_dc_application_type_code      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_dc_defaulting_flow_code       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_dc_last_update_date           IN  DATE     := FND_API.G_MISS_DATE,
   p_dc_object_version_number      IN  NUMBER   := FND_API.G_MISS_NUM,
   x_def_control_rec               OUT NOCOPY  ASO_Defaulting_Int.Control_Rec_Type
)
IS
BEGIN

   x_def_control_rec.override_Trigger_Flag := p_dc_override_Trigger_Flag;
   x_def_control_rec.dependency_Flag := p_dc_dependency_Flag;
   x_def_control_rec.defaulting_Flag := p_dc_defaulting_Flag;
   x_def_control_rec.application_type_code := p_dc_application_type_code;
   x_def_control_rec.defaulting_flow_code := p_dc_defaulting_flow_code;

   IF p_dc_last_update_date = ROSETTA_G_MISTAKE_DATE THEN
      x_def_control_rec.last_update_date := FND_API.G_MISS_DATE;
   ELSE
      x_def_control_rec.last_update_date := p_dc_last_update_date;
   END IF;
   x_def_control_rec.object_version_number := p_dc_object_version_number;

END Set_Def_Control_Rec_W;



-- there IS total 4 fields here IN line
PROCEDURE Set_Submit_Control_Rec_W(
   p_book_flag       IN  VARCHAR2 := FND_API.G_FALSE,
   p_reserve_flag    IN  VARCHAR2 := FND_API.G_FALSE,
   p_calculate_price IN  VARCHAR2 := FND_API.G_FALSE,
   p_server_id       IN  NUMBER   := FND_API.G_MISS_NUM,
   x_Submit_control_rec OUT NOCOPY  ASO_Quote_Pub.Submit_Control_Rec_Type
)
IS
BEGIN
   x_submit_control_rec.book_flag := p_book_flag;
   x_submit_control_rec.reserve_flag := p_reserve_flag;
   x_submit_control_rec.calculate_price := p_calculate_price;
   IF p_server_id = ROSETTA_G_MISS_NUM THEN
      x_submit_control_rec.server_id := FND_API.G_MISS_NUM;
   ELSE
      x_submit_control_rec.server_id := p_server_id;
   END IF;
END Set_Submit_Control_Rec_W;


-- there IS total 5 fields here IN line
PROCEDURE Set_Copy_Quote_Control_Rec_W(
   p_copy_header_only               VARCHAR2 := FND_API.G_MISS_CHAR,
   p_new_version                    VARCHAR2 := FND_API.G_MISS_CHAR,
   p_copy_note                      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_copy_task                      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_copy_attachment                VARCHAR2 := FND_API.G_MISS_CHAR,
   p_pricing_request_type           VARCHAR2 := FND_API.G_MISS_CHAR,
   p_header_pricing_event           VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_mode                     VARCHAR2 := FND_API.G_MISS_CHAR,
   p_calc_freight_charge_flag       VARCHAR2 := FND_API.G_MISS_CHAR,
   p_calculate_tax_flag             VARCHAR2 := FND_API.G_MISS_CHAR,
   p_Copy_Shipping                  VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Billing                   VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Payment                   VARCHAR2 := FND_API.G_TRUE,
   p_Copy_End_Customer              VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Sales_Supplement          VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Flexfield                 VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Sales_Credit              VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Contract_Terms            VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Sales_Team                VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Line_Shipping             VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Line_Billing              VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Line_Payment              VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Line_End_Customer         VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Line_Sales_Supplement     VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Line_Attachment           VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Line_Flexfield            VARCHAR2 := FND_API.G_TRUE,
   p_Copy_Line_Sales_Credit         VARCHAR2 := FND_API.G_TRUE,
   p_Copy_To_Same_Customer          VARCHAR2 := FND_API.G_TRUE,
   x_copy_quote_control_rec  OUT NOCOPY  ASO_Copy_Quote_Pub.Copy_Quote_Control_Rec_Type
)
IS
BEGIN
   x_copy_quote_control_rec.copy_header_only              := p_copy_header_only;
   x_copy_quote_control_rec.new_version                   := p_new_version;
   x_copy_quote_control_rec.copy_note                     := p_copy_note;
   x_copy_quote_control_rec.copy_task                     := p_copy_task;
   x_copy_quote_control_rec.copy_attachment               := p_copy_attachment;
   x_copy_quote_control_rec.pricing_request_type          := p_pricing_request_type;
   x_copy_quote_control_rec.header_pricing_event          := p_header_pricing_event;
   x_copy_quote_control_rec.price_mode                    := p_price_mode;
   x_copy_quote_control_rec.calculate_freight_charge_flag := p_calc_freight_charge_flag;
   x_copy_quote_control_rec.calculate_tax_flag            := p_calculate_tax_flag;
   x_copy_quote_control_rec.copy_shipping                 := p_Copy_Shipping;
   x_copy_quote_control_rec.copy_billing                  := p_Copy_Billing;
   x_copy_quote_control_rec.copy_payment                  := p_Copy_Payment;
   x_copy_quote_control_rec.copy_end_customer             := p_Copy_End_Customer;
   x_copy_quote_control_rec.copy_sales_supplement         := p_Copy_Sales_Supplement;
   x_copy_quote_control_rec.copy_flexfield                := p_Copy_Flexfield;
   x_copy_quote_control_rec.copy_sales_credit             := p_Copy_Sales_Credit;
   x_copy_quote_control_rec.copy_contract_terms           := p_Copy_Contract_Terms;
   x_copy_quote_control_rec.copy_sales_team               := p_Copy_Sales_Team;
   x_copy_quote_control_rec.copy_line_shipping            := p_Copy_Line_Shipping;
   x_copy_quote_control_rec.copy_line_billing             := p_Copy_Line_Billing;
   x_copy_quote_control_rec.copy_line_payment             := p_Copy_Line_Payment;
   x_copy_quote_control_rec.copy_line_end_customer        := p_Copy_Line_End_Customer;
   x_copy_quote_control_rec.copy_line_sales_supplement    := p_Copy_Line_Sales_Supplement;
   x_copy_quote_control_rec.copy_line_attachment          := p_Copy_Line_Attachment;
   x_copy_quote_control_rec.copy_line_flexfield           := p_Copy_Line_Flexfield;
   x_copy_quote_control_rec.copy_line_sales_credit        := p_Copy_Line_Sales_Credit ;
   x_copy_quote_control_rec.copy_to_same_customer         := p_Copy_To_Same_Customer;
END Set_Copy_Quote_Control_Rec_W;


-- there IS total 5 fields here OUT NOCOPY /* file.sql.39 change */ line
PROCEDURE Set_Order_Header_Rec_Out(
   p_order_header_rec IN  ASO_Quote_Pub.Order_Header_Rec_Type,
   x_order_number     OUT NOCOPY  NUMBER                             ,
   x_order_header_id  OUT NOCOPY  NUMBER                             ,
   x_order_request_id OUT NOCOPY  NUMBER                             ,
   x_contract_id      OUT NOCOPY  NUMBER                             ,
   x_status           OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_order_number     := rosetta_g_miss_num_map(p_order_header_rec.order_number);
   x_order_header_id  := rosetta_g_miss_num_map(p_order_header_rec.order_header_id);
   x_order_request_id := rosetta_g_miss_num_map(p_order_header_rec.order_request_id);
   x_contract_id      := rosetta_g_miss_num_map(p_order_header_rec.contract_id);
   x_status           := p_order_header_rec.status;
END Set_Order_Header_Rec_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso quote header table
PROCEDURE Set_Qte_Header_Tbl_Out(
   p_qte_header_tbl                 IN  ASO_Quote_Pub.Qte_Header_Tbl_Type,
   x_quote_header_id                OUT NOCOPY  jtf_number_table,
   x_last_update_date               OUT NOCOPY  jtf_date_table

   /*-- The following output parameters are ignored
   x_creation_date                  OUT NOCOPY  jtf_date_table,
   x_created_by                     OUT NOCOPY  jtf_number_table,
   x_last_updated_by                OUT NOCOPY  jtf_number_table,
   x_last_update_login              OUT NOCOPY  jtf_number_table,
   x_request_id                     OUT NOCOPY  jtf_number_table,
   x_program_application_id         OUT NOCOPY  jtf_number_table,
   x_program_id                     OUT NOCOPY  jtf_number_table,
   x_program_update_date            OUT NOCOPY  jtf_date_table,
   x_org_id                         OUT NOCOPY  jtf_number_table,
   x_quote_name                     OUT NOCOPY  jtf_varchar2_table_100,
   x_quote_number                   OUT NOCOPY  jtf_number_table,
   x_quote_version                  OUT NOCOPY  jtf_number_table,
   x_quote_status_id                OUT NOCOPY  jtf_number_table,
   x_quote_source_code              OUT NOCOPY  jtf_varchar2_table_300,
   x_quote_expiration_date          OUT NOCOPY  jtf_date_table,
   x_price_frozen_date              OUT NOCOPY  jtf_date_table,
   x_quote_password                 OUT NOCOPY  jtf_varchar2_table_300,
   x_original_system_reference      OUT NOCOPY  jtf_varchar2_table_300,
   x_party_id                       OUT NOCOPY  jtf_number_table,
   x_cust_account_id                OUT NOCOPY  jtf_number_table,
   x_invoice_to_cust_account_id     OUT NOCOPY  jtf_number_table,
   x_org_contact_id                 OUT NOCOPY  jtf_number_table,
   x_phone_id                       OUT NOCOPY  jtf_number_table,
   x_invoice_to_party_site_id       OUT NOCOPY  jtf_number_table,
   x_invoice_to_party_id            OUT NOCOPY  jtf_number_table,
   x_orig_mktg_source_code_id       OUT NOCOPY  jtf_number_table,
   x_marketing_source_code_id       OUT NOCOPY  jtf_number_table,
   x_order_type_id                  OUT NOCOPY  jtf_number_table,
   x_quote_category_code            OUT NOCOPY  jtf_varchar2_table_300,
   x_ordered_date                   OUT NOCOPY  jtf_date_table,
   x_accounting_rule_id             OUT NOCOPY  jtf_number_table,
   x_invoicing_rule_id              OUT NOCOPY  jtf_number_table,
   x_employee_person_id             OUT NOCOPY  jtf_number_table,
   x_price_list_id                  OUT NOCOPY  jtf_number_table,
   x_currency_code                  OUT NOCOPY  jtf_varchar2_table_100,
   x_total_list_price               OUT NOCOPY  jtf_number_table,
   x_total_adjusted_amount          OUT NOCOPY  jtf_number_table,
   x_total_adjusted_percent         OUT NOCOPY  jtf_number_table,
   x_total_tax                      OUT NOCOPY  jtf_number_table,
   x_total_shipping_charge          OUT NOCOPY  jtf_number_table,
   x_surcharge                      OUT NOCOPY  jtf_number_table,
   x_total_quote_price              OUT NOCOPY  jtf_number_table,
   x_payment_amount                 OUT NOCOPY  jtf_number_table,
   x_exchange_rate                  OUT NOCOPY  jtf_number_table,
   x_exchange_type_code             OUT NOCOPY  jtf_varchar2_table_100,
   x_exchange_rate_date             OUT NOCOPY  jtf_date_table,
   x_contract_id                    OUT NOCOPY  jtf_number_table,
   x_sales_channel_code             OUT NOCOPY  jtf_varchar2_table_100,
   x_order_id                       OUT NOCOPY  jtf_number_table,
   x_order_number                   OUT NOCOPY  jtf_number_table,
   x_ffm_request_id                 OUT NOCOPY  jtf_number_table,
   x_qte_contract_id                OUT NOCOPY  jtf_number_table,
   x_attribute_category             OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute1                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute2                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute3                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute4                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute5                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute6                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute7                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute8                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute9                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute10                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute11                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute12                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute13                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute14                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute15                    OUT NOCOPY  jtf_varchar2_table_200,
   x_salesrep_first_name            OUT NOCOPY  jtf_varchar2_table_300,
   x_salesrep_last_name             OUT NOCOPY  jtf_varchar2_table_300,
   x_price_list_name                OUT NOCOPY  jtf_varchar2_table_300,
   x_quote_status_code              OUT NOCOPY  jtf_varchar2_table_100,
   x_quote_status                   OUT NOCOPY  jtf_varchar2_table_300,
   x_party_name                     OUT NOCOPY  jtf_varchar2_table_300,
   x_party_type                     OUT NOCOPY  jtf_varchar2_table_100,
   x_person_first_name              OUT NOCOPY  jtf_varchar2_table_200,
   x_person_middle_name             OUT NOCOPY  jtf_varchar2_table_100,
   x_person_last_name               OUT NOCOPY  jtf_varchar2_table_200,
   x_marketing_source_name          OUT NOCOPY  jtf_varchar2_table_200,
   x_marketing_source_code          OUT NOCOPY  jtf_varchar2_table_200,
   x_order_type_name                OUT NOCOPY  jtf_varchar2_table_300,
   x_invoice_to_party_name          OUT NOCOPY  jtf_varchar2_table_300,
   x_invoice_to_cont_first_name     OUT NOCOPY  jtf_varchar2_table_200,
   x_invoice_to_cont_mid_name       OUT NOCOPY  jtf_varchar2_table_100,
   x_invoice_to_cont_last_name      OUT NOCOPY  jtf_varchar2_table_200,
   x_invoice_to_address1            OUT NOCOPY  jtf_varchar2_table_300,
   x_invoice_to_address2            OUT NOCOPY  jtf_varchar2_table_300,
   x_invoice_to_address3            OUT NOCOPY  jtf_varchar2_table_300,
   x_invoice_to_address4            OUT NOCOPY  jtf_varchar2_table_300,
   x_invoice_to_country_code        OUT NOCOPY  jtf_varchar2_table_100,
   x_invoice_to_country             OUT NOCOPY  jtf_varchar2_table_100,
   x_invoice_to_city                OUT NOCOPY  jtf_varchar2_table_100,
   x_invoice_to_postal_code         OUT NOCOPY  jtf_varchar2_table_100,
   x_invoice_to_state               OUT NOCOPY  jtf_varchar2_table_100,
   x_invoice_to_province            OUT NOCOPY  jtf_varchar2_table_100,
   x_invoice_to_county              OUT NOCOPY  jtf_varchar2_table_100,
   x_resource_id                    OUT NOCOPY  jtf_number_table
   --*/
)
AS
    ddindx binary_integer; indx binary_integer;
BEGIN
    x_quote_header_id := jtf_number_table();
    x_last_update_date := jtf_date_table();

    /*-- The following output parameters are ignored
    x_creation_date := jtf_date_table();
    x_created_by := jtf_number_table();
    x_last_updated_by := jtf_number_table();
    x_last_update_login := jtf_number_table();
    x_request_id := jtf_number_table();
    x_program_application_id := jtf_number_table();
    x_program_id := jtf_number_table();
    x_program_update_date := jtf_date_table();
    x_org_id := jtf_number_table();
    x_quote_name := jtf_varchar2_table_100();
    x_quote_number := jtf_number_table();
    x_quote_version := jtf_number_table();
    x_quote_status_id := jtf_number_table();
    x_quote_source_code := jtf_varchar2_table_300();
    x_quote_expiration_date := jtf_date_table();
    x_price_frozen_date := jtf_date_table();
    x_quote_password := jtf_varchar2_table_300();
    x_original_system_reference := jtf_varchar2_table_300();
    x_party_id := jtf_number_table();
    x_cust_account_id := jtf_number_table();
    x_invoice_to_cust_account_id := jtf_number_table();
    x_org_contact_id := jtf_number_table();
    x_phone_id := jtf_number_table();
    x_invoice_to_party_site_id := jtf_number_table();
    x_invoice_to_party_id := jtf_number_table();
    x_orig_mktg_source_code_id := jtf_number_table();
    x_marketing_source_code_id := jtf_number_table();
    x_order_type_id := jtf_number_table();
    x_quote_category_code := jtf_varchar2_table_300();
    x_ordered_date := jtf_date_table();
    x_accounting_rule_id := jtf_number_table();
    x_invoicing_rule_id := jtf_number_table();
    x_employee_person_id := jtf_number_table();
    x_price_list_id := jtf_number_table();
    x_currency_code := jtf_varchar2_table_100();
    x_total_list_price := jtf_number_table();
    x_total_adjusted_amount := jtf_number_table();
    x_total_adjusted_percent := jtf_number_table();
    x_total_tax := jtf_number_table();
    x_total_shipping_charge := jtf_number_table();
    x_surcharge := jtf_number_table();
    x_total_quote_price := jtf_number_table();
    x_payment_amount := jtf_number_table();
    x_exchange_rate := jtf_number_table();
    x_exchange_type_code := jtf_varchar2_table_100();
    x_exchange_rate_date := jtf_date_table();
    x_contract_id := jtf_number_table();
    x_sales_channel_code := jtf_varchar2_table_100();
    x_order_id := jtf_number_table();
    x_order_number := jtf_number_table();
    x_ffm_request_id := jtf_number_table();
    x_qte_contract_id := jtf_number_table();
    x_attribute_category := jtf_varchar2_table_100();
    x_attribute1 := jtf_varchar2_table_200();
    x_attribute2 := jtf_varchar2_table_200();
    x_attribute3 := jtf_varchar2_table_200();
    x_attribute4 := jtf_varchar2_table_200();
    x_attribute5 := jtf_varchar2_table_200();
    x_attribute6 := jtf_varchar2_table_200();
    x_attribute7 := jtf_varchar2_table_200();
    x_attribute8 := jtf_varchar2_table_200();
    x_attribute9 := jtf_varchar2_table_200();
    x_attribute10 := jtf_varchar2_table_200();
    x_attribute11 := jtf_varchar2_table_200();
    x_attribute12 := jtf_varchar2_table_200();
    x_attribute13 := jtf_varchar2_table_200();
    x_attribute14 := jtf_varchar2_table_200();
    x_attribute15 := jtf_varchar2_table_200();
    x_salesrep_first_name := jtf_varchar2_table_300();
    x_salesrep_last_name := jtf_varchar2_table_300();
    x_price_list_name := jtf_varchar2_table_300();
    x_quote_status_code := jtf_varchar2_table_100();
    x_quote_status := jtf_varchar2_table_300();
    x_party_name := jtf_varchar2_table_300();
    x_party_type := jtf_varchar2_table_100();
    x_person_first_name := jtf_varchar2_table_200();
    x_person_middle_name := jtf_varchar2_table_100();
    x_person_last_name := jtf_varchar2_table_200();
    x_marketing_source_name := jtf_varchar2_table_200();
    x_marketing_source_code := jtf_varchar2_table_200();
    x_order_type_name := jtf_varchar2_table_300();
    x_invoice_to_party_name := jtf_varchar2_table_300();
    x_invoice_to_cont_first_name := jtf_varchar2_table_200();
    x_invoice_to_cont_mid_name := jtf_varchar2_table_100();
    x_invoice_to_cont_last_name := jtf_varchar2_table_200();
    x_invoice_to_address1 := jtf_varchar2_table_300();
    x_invoice_to_address2 := jtf_varchar2_table_300();
    x_invoice_to_address3 := jtf_varchar2_table_300();
    x_invoice_to_address4 := jtf_varchar2_table_300();
    x_invoice_to_country_code := jtf_varchar2_table_100();
    x_invoice_to_country := jtf_varchar2_table_100();
    x_invoice_to_city := jtf_varchar2_table_100();
    x_invoice_to_postal_code := jtf_varchar2_table_100();
    x_invoice_to_state := jtf_varchar2_table_100();
    x_invoice_to_province := jtf_varchar2_table_100();
    x_invoice_to_county := jtf_varchar2_table_100();
    x_resource_id := jtf_number_table();
    --*/

    IF p_qte_header_tbl.count > 0 THEN
      x_quote_header_id.extend(p_qte_header_tbl.count);
      x_last_update_date.extend(p_qte_header_tbl.count);

      /*-- The following output parameters are ignored
      x_creation_date.extend(p_qte_header_tbl.count);
      x_created_by.extend(p_qte_header_tbl.count);
      x_last_updated_by.extend(p_qte_header_tbl.count);
      x_last_update_login.extend(p_qte_header_tbl.count);
      x_request_id.extend(p_qte_header_tbl.count);
      x_program_application_id.extend(p_qte_header_tbl.count);
      x_program_id.extend(p_qte_header_tbl.count);
      x_program_update_date.extend(p_qte_header_tbl.count);
      x_org_id.extend(p_qte_header_tbl.count);
      x_quote_name.extend(p_qte_header_tbl.count);
      x_quote_number.extend(p_qte_header_tbl.count);
      x_quote_version.extend(p_qte_header_tbl.count);
      x_quote_status_id.extend(p_qte_header_tbl.count);
      x_quote_source_code.extend(p_qte_header_tbl.count);
      x_quote_expiration_date.extend(p_qte_header_tbl.count);
      x_price_frozen_date.extend(p_qte_header_tbl.count);
      x_quote_password.extend(p_qte_header_tbl.count);
      x_original_system_reference.extend(p_qte_header_tbl.count);
      x_party_id.extend(p_qte_header_tbl.count);
      x_cust_account_id.extend(p_qte_header_tbl.count);
      x_invoice_to_cust_account_id.extend(p_qte_header_tbl.count);
      x_org_contact_id.extend(p_qte_header_tbl.count);
      x_phone_id.extend(p_qte_header_tbl.count);
      x_invoice_to_party_site_id.extend(p_qte_header_tbl.count);
      x_invoice_to_party_id.extend(p_qte_header_tbl.count);
      x_orig_mktg_source_code_id.extend(p_qte_header_tbl.count);
      x_marketing_source_code_id.extend(p_qte_header_tbl.count);
      x_order_type_id.extend(p_qte_header_tbl.count);
      x_quote_category_code.extend(p_qte_header_tbl.count);
      x_ordered_date.extend(p_qte_header_tbl.count);
      x_accounting_rule_id.extend(p_qte_header_tbl.count);
      x_invoicing_rule_id.extend(p_qte_header_tbl.count);
      x_employee_person_id.extend(p_qte_header_tbl.count);
      x_price_list_id.extend(p_qte_header_tbl.count);
      x_currency_code.extend(p_qte_header_tbl.count);
      x_total_list_price.extend(p_qte_header_tbl.count);
      x_total_adjusted_amount.extend(p_qte_header_tbl.count);
      x_total_adjusted_percent.extend(p_qte_header_tbl.count);
      x_total_tax.extend(p_qte_header_tbl.count);
      x_total_shipping_charge.extend(p_qte_header_tbl.count);
      x_surcharge.extend(p_qte_header_tbl.count);
      x_total_quote_price.extend(p_qte_header_tbl.count);
      x_payment_amount.extend(p_qte_header_tbl.count);
      x_exchange_rate.extend(p_qte_header_tbl.count);
      x_exchange_type_code.extend(p_qte_header_tbl.count);
      x_exchange_rate_date.extend(p_qte_header_tbl.count);
      x_contract_id.extend(p_qte_header_tbl.count);
      x_sales_channel_code.extend(p_qte_header_tbl.count);
      x_order_id.extend(p_qte_header_tbl.count);
      x_order_number.extend(p_qte_header_tbl.count);
      x_ffm_request_id.extend(p_qte_header_tbl.count);
      x_qte_contract_id.extend(p_qte_header_tbl.count);
      x_attribute_category.extend(p_qte_header_tbl.count);
      x_attribute1.extend(p_qte_header_tbl.count);
      x_attribute2.extend(p_qte_header_tbl.count);
      x_attribute3.extend(p_qte_header_tbl.count);
      x_attribute4.extend(p_qte_header_tbl.count);
      x_attribute5.extend(p_qte_header_tbl.count);
      x_attribute6.extend(p_qte_header_tbl.count);
      x_attribute7.extend(p_qte_header_tbl.count);
      x_attribute8.extend(p_qte_header_tbl.count);
      x_attribute9.extend(p_qte_header_tbl.count);
      x_attribute10.extend(p_qte_header_tbl.count);
      x_attribute11.extend(p_qte_header_tbl.count);
      x_attribute12.extend(p_qte_header_tbl.count);
      x_attribute13.extend(p_qte_header_tbl.count);
      x_attribute14.extend(p_qte_header_tbl.count);
      x_attribute15.extend(p_qte_header_tbl.count);
      x_salesrep_first_name.extend(p_qte_header_tbl.count);
      x_salesrep_last_name.extend(p_qte_header_tbl.count);
      x_price_list_name.extend(p_qte_header_tbl.count);
      x_quote_status_code.extend(p_qte_header_tbl.count);
      x_quote_status.extend(p_qte_header_tbl.count);
      x_party_name.extend(p_qte_header_tbl.count);
      x_party_type.extend(p_qte_header_tbl.count);
      x_person_first_name.extend(p_qte_header_tbl.count);
      x_person_middle_name.extend(p_qte_header_tbl.count);
      x_person_last_name.extend(p_qte_header_tbl.count);
      x_marketing_source_name.extend(p_qte_header_tbl.count);
      x_marketing_source_code.extend(p_qte_header_tbl.count);
      x_order_type_name.extend(p_qte_header_tbl.count);
      x_invoice_to_party_name.extend(p_qte_header_tbl.count);
      x_invoice_to_cont_first_name.extend(p_qte_header_tbl.count);
      x_invoice_to_cont_mid_name.extend(p_qte_header_tbl.count);
      x_invoice_to_cont_last_name.extend(p_qte_header_tbl.count);
      x_invoice_to_address1.extend(p_qte_header_tbl.count);
      x_invoice_to_address2.extend(p_qte_header_tbl.count);
      x_invoice_to_address3.extend(p_qte_header_tbl.count);
      x_invoice_to_address4.extend(p_qte_header_tbl.count);
      x_invoice_to_country_code.extend(p_qte_header_tbl.count);
      x_invoice_to_country.extend(p_qte_header_tbl.count);
      x_invoice_to_city.extend(p_qte_header_tbl.count);
      x_invoice_to_postal_code.extend(p_qte_header_tbl.count);
      x_invoice_to_state.extend(p_qte_header_tbl.count);
      x_invoice_to_province.extend(p_qte_header_tbl.count);
      x_invoice_to_county.extend(p_qte_header_tbl.count);
      x_resource_id.extend(p_qte_header_tbl.count);
      --*/

      ddindx := p_qte_header_tbl.first;
      indx := 1;
      WHILE true LOOP
        x_quote_header_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).quote_header_id);
        x_last_update_date(indx) := p_qte_header_tbl(ddindx).last_update_date;

        /*-- The following output parameters are ignored
        x_creation_date(indx) := p_qte_header_tbl(ddindx).creation_date;
        x_created_by(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).created_by);
        x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).last_updated_by);
        x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).last_update_login);
        x_request_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).request_id);
        x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).program_application_id);
        x_program_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).program_id);
        x_program_update_date(indx) := p_qte_header_tbl(ddindx).program_update_date;
        x_org_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).org_id);
        x_quote_name(indx) := p_qte_header_tbl(ddindx).quote_name;
        x_quote_number(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).quote_number);
        x_quote_version(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).quote_version);
        x_quote_status_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).quote_status_id);
        x_quote_source_code(indx) := p_qte_header_tbl(ddindx).quote_source_code;
        x_quote_expiration_date(indx) := p_qte_header_tbl(ddindx).quote_expiration_date;
        x_price_frozen_date(indx) := p_qte_header_tbl(ddindx).price_frozen_date;
        x_quote_password(indx) := p_qte_header_tbl(ddindx).quote_password;
        x_original_system_reference(indx) := p_qte_header_tbl(ddindx).original_system_reference;
        x_party_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).party_id);
        x_cust_account_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).cust_account_id);
        x_invoice_to_cust_account_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).invoice_to_cust_account_id);
        x_org_contact_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).org_contact_id);
        x_phone_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).phone_id);
        x_invoice_to_party_site_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).invoice_to_party_site_id);
        x_invoice_to_party_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).invoice_to_party_id);
        x_orig_mktg_source_code_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).orig_mktg_source_code_id);
        x_marketing_source_code_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).marketing_source_code_id);
        x_order_type_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).order_type_id);
        x_quote_category_code(indx) := p_qte_header_tbl(ddindx).quote_category_code;
        x_ordered_date(indx) := p_qte_header_tbl(ddindx).ordered_date;
        x_accounting_rule_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).accounting_rule_id);
        x_invoicing_rule_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).invoicing_rule_id);
        x_employee_person_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).employee_person_id);
        x_price_list_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).price_list_id);
        x_currency_code(indx) := p_qte_header_tbl(ddindx).currency_code;
        x_total_list_price(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).total_list_price);
        x_total_adjusted_amount(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).total_adjusted_amount);
        x_total_adjusted_percent(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).total_adjusted_percent);
        x_total_tax(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).total_tax);
        x_total_shipping_charge(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).total_shipping_charge);
        x_surcharge(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).surcharge);
        x_total_quote_price(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).total_quote_price);
        x_payment_amount(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).payment_amount);
        x_exchange_rate(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).exchange_rate);
        x_exchange_type_code(indx) := p_qte_header_tbl(ddindx).exchange_type_code;
        x_exchange_rate_date(indx) := p_qte_header_tbl(ddindx).exchange_rate_date;
        x_contract_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).contract_id);
        x_sales_channel_code(indx) := p_qte_header_tbl(ddindx).sales_channel_code;
        x_order_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).order_id);
        x_order_number(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).order_number);
        x_ffm_request_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).ffm_request_id);
        x_qte_contract_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).qte_contract_id);
        x_attribute_category(indx) := p_qte_header_tbl(ddindx).attribute_category;
        x_attribute1(indx) := p_qte_header_tbl(ddindx).attribute1;
        x_attribute2(indx) := p_qte_header_tbl(ddindx).attribute2;
        x_attribute3(indx) := p_qte_header_tbl(ddindx).attribute3;
        x_attribute4(indx) := p_qte_header_tbl(ddindx).attribute4;
        x_attribute5(indx) := p_qte_header_tbl(ddindx).attribute5;
        x_attribute6(indx) := p_qte_header_tbl(ddindx).attribute6;
        x_attribute7(indx) := p_qte_header_tbl(ddindx).attribute7;
        x_attribute8(indx) := p_qte_header_tbl(ddindx).attribute8;
        x_attribute9(indx) := p_qte_header_tbl(ddindx).attribute9;
        x_attribute10(indx) := p_qte_header_tbl(ddindx).attribute10;
        x_attribute11(indx) := p_qte_header_tbl(ddindx).attribute11;
        x_attribute12(indx) := p_qte_header_tbl(ddindx).attribute12;
        x_attribute13(indx) := p_qte_header_tbl(ddindx).attribute13;
        x_attribute14(indx) := p_qte_header_tbl(ddindx).attribute14;
        x_attribute15(indx) := p_qte_header_tbl(ddindx).attribute15;
        x_salesrep_first_name(indx) := p_qte_header_tbl(ddindx).salesrep_first_name;
        x_salesrep_last_name(indx) := p_qte_header_tbl(ddindx).salesrep_last_name;
        x_price_list_name(indx) := p_qte_header_tbl(ddindx).price_list_name;
        x_quote_status_code(indx) := p_qte_header_tbl(ddindx).quote_status_code;
        x_quote_status(indx) := p_qte_header_tbl(ddindx).quote_status;
        x_party_name(indx) := p_qte_header_tbl(ddindx).party_name;
        x_party_type(indx) := p_qte_header_tbl(ddindx).party_type;
        x_person_first_name(indx) := p_qte_header_tbl(ddindx).person_first_name;
        x_person_middle_name(indx) := p_qte_header_tbl(ddindx).person_middle_name;
        x_person_last_name(indx) := p_qte_header_tbl(ddindx).person_last_name;
        x_marketing_source_name(indx) := p_qte_header_tbl(ddindx).marketing_source_name;
        x_marketing_source_code(indx) := p_qte_header_tbl(ddindx).marketing_source_code;
        x_order_type_name(indx) := p_qte_header_tbl(ddindx).order_type_name;
        x_invoice_to_party_name(indx) := p_qte_header_tbl(ddindx).invoice_to_party_name;
        x_invoice_to_cont_first_name(indx) := p_qte_header_tbl(ddindx).invoice_to_contact_first_name;
        x_invoice_to_cont_mid_name(indx) := p_qte_header_tbl(ddindx).invoice_to_contact_middle_name;
        x_invoice_to_cont_last_name(indx) := p_qte_header_tbl(ddindx).invoice_to_contact_last_name;
        x_invoice_to_address1(indx) := p_qte_header_tbl(ddindx).invoice_to_address1;
        x_invoice_to_address2(indx) := p_qte_header_tbl(ddindx).invoice_to_address2;
        x_invoice_to_address3(indx) := p_qte_header_tbl(ddindx).invoice_to_address3;
        x_invoice_to_address4(indx) := p_qte_header_tbl(ddindx).invoice_to_address4;
        x_invoice_to_country_code(indx) := p_qte_header_tbl(ddindx).invoice_to_country_code;
        x_invoice_to_country(indx) := p_qte_header_tbl(ddindx).invoice_to_country;
        x_invoice_to_city(indx) := p_qte_header_tbl(ddindx).invoice_to_city;
        x_invoice_to_postal_code(indx) := p_qte_header_tbl(ddindx).invoice_to_postal_code;
        x_invoice_to_state(indx) := p_qte_header_tbl(ddindx).invoice_to_state;
        x_invoice_to_province(indx) := p_qte_header_tbl(ddindx).invoice_to_province;
        x_invoice_to_county(indx) := p_qte_header_tbl(ddindx).invoice_to_county;
        x_resource_id(indx) := rosetta_g_miss_num_map(p_qte_header_tbl(ddindx).resource_id);
        --*/

        indx := indx+1;
        IF p_qte_header_tbl.last =ddindx
          THEN EXIT;
        END IF;
        ddindx := p_qte_header_tbl.next(ddindx);
      END LOOP;
    END IF;
END Set_Qte_Header_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso quote line table
PROCEDURE Set_Qte_Line_Tbl_Out(
   p_qte_line_tbl                   IN  ASO_Quote_Pub.Qte_Line_Tbl_Type,
   x_quote_line_id                  OUT NOCOPY  jtf_number_table

   /*-- The following output parameters are ignored
   x_operation_code                 OUT NOCOPY  jtf_varchar2_table_100,
   x_creation_date                  OUT NOCOPY  jtf_date_table,
   x_created_by                     OUT NOCOPY  jtf_number_table,
   x_last_update_date               OUT NOCOPY  jtf_date_table,
   x_last_updated_by                OUT NOCOPY  jtf_number_table,
   x_last_update_login              OUT NOCOPY  jtf_number_table,
   x_request_id                     OUT NOCOPY  jtf_number_table,
   x_program_application_id         OUT NOCOPY  jtf_number_table,
   x_program_id                     OUT NOCOPY  jtf_number_table,
   x_program_update_date            OUT NOCOPY  jtf_date_table,
   x_quote_header_id                OUT NOCOPY  jtf_number_table,
   x_org_id                         OUT NOCOPY  jtf_number_table,
   x_line_category_code             OUT NOCOPY  jtf_varchar2_table_100,
   x_item_type_code                 OUT NOCOPY  jtf_varchar2_table_100,
   x_line_number                    OUT NOCOPY  jtf_number_table,
   x_start_date_active              OUT NOCOPY  jtf_date_table,
   x_end_date_active                OUT NOCOPY  jtf_date_table,
   x_order_line_type_id             OUT NOCOPY  jtf_number_table,
   x_invoice_to_party_site_id       OUT NOCOPY  jtf_number_table,
   x_invoice_to_party_id            OUT NOCOPY  jtf_number_table,
   x_invoice_to_cust_account_id     OUT NOCOPY  jtf_number_table,
   x_organization_id                OUT NOCOPY  jtf_number_table,
   x_inventory_item_id              OUT NOCOPY  jtf_number_table,
   x_quantity                       OUT NOCOPY  jtf_number_table,
   x_uom_code                       OUT NOCOPY  jtf_varchar2_table_100,
   x_pricing_quantity_uom           OUT NOCOPY  jtf_varchar2_table_100,
   x_marketing_source_code_id       OUT NOCOPY  jtf_number_table,
   x_price_list_id                  OUT NOCOPY  jtf_number_table,
   x_price_list_line_id             OUT NOCOPY  jtf_number_table,
   x_currency_code                  OUT NOCOPY  jtf_varchar2_table_100,
   x_line_list_price                OUT NOCOPY  jtf_number_table,
   x_line_adjusted_amount           OUT NOCOPY  jtf_number_table,
   x_line_adjusted_percent          OUT NOCOPY  jtf_number_table,
   x_line_quote_price               OUT NOCOPY  jtf_number_table,
   x_related_item_id                OUT NOCOPY  jtf_number_table,
   x_item_relationship_type         OUT NOCOPY  jtf_varchar2_table_100,
   x_accounting_rule_id             OUT NOCOPY  jtf_number_table,
   x_invoicing_rule_id              OUT NOCOPY  jtf_number_table,
   x_split_shipment_flag            OUT NOCOPY  jtf_varchar2_table_100,
   x_backorder_flag                 OUT NOCOPY  jtf_varchar2_table_100,
   x_minisite_id                    OUT NOCOPY  jtf_number_table,
   x_section_id                     OUT NOCOPY  jtf_number_table,
   x_selling_price_change           OUT NOCOPY  jtf_varchar2_table_100,
   x_recalculate_flag               OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute_category             OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute1                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute2                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute3                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute4                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute5                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute6                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute7                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute8                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute9                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute10                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute11                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute12                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute13                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute14                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute15                    OUT NOCOPY  jtf_varchar2_table_200,
   x_ffm_content_name               OUT NOCOPY  jtf_varchar2_table_300,
   x_ffm_document_type              OUT NOCOPY  jtf_varchar2_table_300,
   x_ffm_media_type                 OUT NOCOPY  jtf_varchar2_table_300,
   x_ffm_media_id                   OUT NOCOPY  jtf_varchar2_table_300,
   x_ffm_content_type               OUT NOCOPY  jtf_varchar2_table_300,
   x_ffm_user_note                  OUT NOCOPY  jtf_varchar2_table_300
   --*/
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_quote_line_id := jtf_number_table();

   /*-- The following output parameters are ignored
   x_operation_code := jtf_varchar2_table_100();
   x_creation_date := jtf_date_table();
   x_created_by := jtf_number_table();
   x_last_update_date := jtf_date_table();
   x_last_updated_by := jtf_number_table();
   x_last_update_login := jtf_number_table();
   x_request_id := jtf_number_table();
   x_program_application_id := jtf_number_table();
   x_program_id := jtf_number_table();
   x_program_update_date := jtf_date_table();
   x_quote_header_id := jtf_number_table();
   x_org_id := jtf_number_table();
   x_line_category_code := jtf_varchar2_table_100();
   x_item_type_code := jtf_varchar2_table_100();
   x_line_number := jtf_number_table();
   x_start_date_active := jtf_date_table();
   x_end_date_active := jtf_date_table();
   x_order_line_type_id := jtf_number_table();
   x_invoice_to_party_site_id := jtf_number_table();
   x_invoice_to_party_id := jtf_number_table();
   x_invoice_to_cust_account_id := jtf_number_table();
   x_organization_id := jtf_number_table();
   x_inventory_item_id := jtf_number_table();
   x_quantity := jtf_number_table();
   x_uom_code := jtf_varchar2_table_100();
   x_pricing_quantity_uom := jtf_varchar2_table_100();
   x_marketing_source_code_id := jtf_number_table();
   x_price_list_id := jtf_number_table();
   x_price_list_line_id := jtf_number_table();
   x_currency_code := jtf_varchar2_table_100();
   x_line_list_price := jtf_number_table();
   x_line_adjusted_amount := jtf_number_table();
   x_line_adjusted_percent := jtf_number_table();
   x_line_quote_price := jtf_number_table();
   x_related_item_id := jtf_number_table();
   x_item_relationship_type := jtf_varchar2_table_100();
   x_accounting_rule_id := jtf_number_table();
   x_invoicing_rule_id := jtf_number_table();
   x_split_shipment_flag := jtf_varchar2_table_100();
   x_backorder_flag := jtf_varchar2_table_100();
   x_minisite_id := jtf_number_table();
   x_section_id := jtf_number_table();
   x_selling_price_change := jtf_varchar2_table_100();
   x_recalculate_flag := jtf_varchar2_table_100();
   x_attribute_category := jtf_varchar2_table_100();
   x_attribute1 := jtf_varchar2_table_200();
   x_attribute2 := jtf_varchar2_table_200();
   x_attribute3 := jtf_varchar2_table_200();
   x_attribute4 := jtf_varchar2_table_200();
   x_attribute5 := jtf_varchar2_table_200();
   x_attribute6 := jtf_varchar2_table_200();
   x_attribute7 := jtf_varchar2_table_200();
   x_attribute8 := jtf_varchar2_table_200();
   x_attribute9 := jtf_varchar2_table_200();
   x_attribute10 := jtf_varchar2_table_200();
   x_attribute11 := jtf_varchar2_table_200();
   x_attribute12 := jtf_varchar2_table_200();
   x_attribute13 := jtf_varchar2_table_200();
   x_attribute14 := jtf_varchar2_table_200();
   x_attribute15 := jtf_varchar2_table_200();
   x_ffm_content_name := jtf_varchar2_table_300();
   x_ffm_document_type := jtf_varchar2_table_300();
   x_ffm_media_type := jtf_varchar2_table_300();
   x_ffm_media_id := jtf_varchar2_table_300();
   x_ffm_content_type := jtf_varchar2_table_300();
   x_ffm_user_note := jtf_varchar2_table_300();
   --*/

   IF p_qte_line_tbl.count > 0 THEN
     x_quote_line_id.extend(p_qte_line_tbl.count);

     /*-- The following output parameters are ignored
     x_operation_code.extend(p_qte_line_tbl.count);
     x_creation_date.extend(p_qte_line_tbl.count);
     x_created_by.extend(p_qte_line_tbl.count);
     x_last_update_date.extend(p_qte_line_tbl.count);
     x_last_updated_by.extend(p_qte_line_tbl.count);
     x_last_update_login.extend(p_qte_line_tbl.count);
     x_request_id.extend(p_qte_line_tbl.count);
     x_program_application_id.extend(p_qte_line_tbl.count);
     x_program_id.extend(p_qte_line_tbl.count);
     x_program_update_date.extend(p_qte_line_tbl.count);
     x_quote_header_id.extend(p_qte_line_tbl.count);
     x_org_id.extend(p_qte_line_tbl.count);
     x_line_category_code.extend(p_qte_line_tbl.count);
     x_item_type_code.extend(p_qte_line_tbl.count);
     x_line_number.extend(p_qte_line_tbl.count);
     x_start_date_active.extend(p_qte_line_tbl.count);
     x_end_date_active.extend(p_qte_line_tbl.count);
     x_order_line_type_id.extend(p_qte_line_tbl.count);
     x_invoice_to_party_site_id.extend(p_qte_line_tbl.count);
     x_invoice_to_party_id.extend(p_qte_line_tbl.count);
     x_invoice_to_cust_account_id.extend(p_qte_line_tbl.count);
     x_organization_id.extend(p_qte_line_tbl.count);
     x_inventory_item_id.extend(p_qte_line_tbl.count);
     x_quantity.extend(p_qte_line_tbl.count);
     x_uom_code.extend(p_qte_line_tbl.count);
     x_pricing_quantity_uom.extend(p_qte_line_tbl.count);
     x_marketing_source_code_id.extend(p_qte_line_tbl.count);
     x_price_list_id.extend(p_qte_line_tbl.count);
     x_price_list_line_id.extend(p_qte_line_tbl.count);
     x_currency_code.extend(p_qte_line_tbl.count);
     x_line_list_price.extend(p_qte_line_tbl.count);
     x_line_adjusted_amount.extend(p_qte_line_tbl.count);
     x_line_adjusted_percent.extend(p_qte_line_tbl.count);
     x_line_quote_price.extend(p_qte_line_tbl.count);
     x_related_item_id.extend(p_qte_line_tbl.count);
     x_item_relationship_type.extend(p_qte_line_tbl.count);
     x_accounting_rule_id.extend(p_qte_line_tbl.count);
     x_invoicing_rule_id.extend(p_qte_line_tbl.count);
     x_split_shipment_flag.extend(p_qte_line_tbl.count);
     x_backorder_flag.extend(p_qte_line_tbl.count);
     x_minisite_id.extend(p_qte_line_tbl.count);
     x_section_id.extend(p_qte_line_tbl.count);
     x_selling_price_change.extend(p_qte_line_tbl.count);
     x_recalculate_flag.extend(p_qte_line_tbl.count);
     x_attribute_category.extend(p_qte_line_tbl.count);
     x_attribute1.extend(p_qte_line_tbl.count);
     x_attribute2.extend(p_qte_line_tbl.count);
     x_attribute3.extend(p_qte_line_tbl.count);
     x_attribute4.extend(p_qte_line_tbl.count);
     x_attribute5.extend(p_qte_line_tbl.count);
     x_attribute6.extend(p_qte_line_tbl.count);
     x_attribute7.extend(p_qte_line_tbl.count);
     x_attribute8.extend(p_qte_line_tbl.count);
     x_attribute9.extend(p_qte_line_tbl.count);
     x_attribute10.extend(p_qte_line_tbl.count);
     x_attribute11.extend(p_qte_line_tbl.count);
     x_attribute12.extend(p_qte_line_tbl.count);
     x_attribute13.extend(p_qte_line_tbl.count);
     x_attribute14.extend(p_qte_line_tbl.count);
     x_attribute15.extend(p_qte_line_tbl.count);
     x_ffm_content_name.extend(p_qte_line_tbl.count);
     x_ffm_document_type.extend(p_qte_line_tbl.count);
     x_ffm_media_type.extend(p_qte_line_tbl.count);
     x_ffm_media_id.extend(p_qte_line_tbl.count);
     x_ffm_content_type.extend(p_qte_line_tbl.count);
     x_ffm_user_note.extend(p_qte_line_tbl.count);
     --*/

     ddindx := p_qte_line_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).quote_line_id);

       /*-- The following output parameters are ignored
       x_operation_code(indx) := p_qte_line_tbl(ddindx).operation_code;
       x_creation_date(indx) := p_qte_line_tbl(ddindx).creation_date;
       x_created_by(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).created_by);
       x_last_update_date(indx) := p_qte_line_tbl(ddindx).last_update_date;
       x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).last_updated_by);
       x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).last_update_login);
       x_request_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).request_id);
       x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).program_application_id);
       x_program_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).program_id);
       x_program_update_date(indx) := p_qte_line_tbl(ddindx).program_update_date;
       x_quote_header_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).quote_header_id);
       x_org_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).org_id);
       x_line_category_code(indx) := p_qte_line_tbl(ddindx).line_category_code;
       x_item_type_code(indx) := p_qte_line_tbl(ddindx).item_type_code;
       x_line_number(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).line_number);
       x_start_date_active(indx) := p_qte_line_tbl(ddindx).start_date_active;
       x_end_date_active(indx) := p_qte_line_tbl(ddindx).end_date_active;
       x_order_line_type_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).order_line_type_id);
       x_invoice_to_party_site_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).invoice_to_party_site_id);
       x_invoice_to_party_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).invoice_to_party_id);
       x_invoice_to_cust_account_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).invoice_to_cust_account_id);
       x_organization_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).organization_id);
       x_inventory_item_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).inventory_item_id);
       x_quantity(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).quantity);
       x_uom_code(indx) := p_qte_line_tbl(ddindx).uom_code;
       x_pricing_quantity_uom(indx) := p_qte_line_tbl(ddindx).pricing_quantity_uom;
       x_marketing_source_code_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).marketing_source_code_id);
       x_price_list_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).price_list_id);
       x_price_list_line_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).price_list_line_id);
       x_currency_code(indx) := p_qte_line_tbl(ddindx).currency_code;
       x_line_list_price(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).line_list_price);
       x_line_adjusted_amount(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).line_adjusted_amount);
       x_line_adjusted_percent(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).line_adjusted_percent);
       x_line_quote_price(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).line_quote_price);
       x_related_item_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).related_item_id);
       x_item_relationship_type(indx) := p_qte_line_tbl(ddindx).item_relationship_type;
       x_accounting_rule_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).accounting_rule_id);
       x_invoicing_rule_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).invoicing_rule_id);
       x_split_shipment_flag(indx) := p_qte_line_tbl(ddindx).split_shipment_flag;
       x_backorder_flag(indx) := p_qte_line_tbl(ddindx).backorder_flag;
       x_minisite_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).minisite_id);
       x_section_id(indx) := rosetta_g_miss_num_map(p_qte_line_tbl(ddindx).section_id);
       x_selling_price_change(indx) := p_qte_line_tbl(ddindx).selling_price_change;
       x_recalculate_flag(indx) := p_qte_line_tbl(ddindx).recalculate_flag;
       x_attribute_category(indx) := p_qte_line_tbl(ddindx).attribute_category;
       x_attribute1(indx) := p_qte_line_tbl(ddindx).attribute1;
       x_attribute2(indx) := p_qte_line_tbl(ddindx).attribute2;
       x_attribute3(indx) := p_qte_line_tbl(ddindx).attribute3;
       x_attribute4(indx) := p_qte_line_tbl(ddindx).attribute4;
       x_attribute5(indx) := p_qte_line_tbl(ddindx).attribute5;
       x_attribute6(indx) := p_qte_line_tbl(ddindx).attribute6;
       x_attribute7(indx) := p_qte_line_tbl(ddindx).attribute7;
       x_attribute8(indx) := p_qte_line_tbl(ddindx).attribute8;
       x_attribute9(indx) := p_qte_line_tbl(ddindx).attribute9;
       x_attribute10(indx) := p_qte_line_tbl(ddindx).attribute10;
       x_attribute11(indx) := p_qte_line_tbl(ddindx).attribute11;
       x_attribute12(indx) := p_qte_line_tbl(ddindx).attribute12;
       x_attribute13(indx) := p_qte_line_tbl(ddindx).attribute13;
       x_attribute14(indx) := p_qte_line_tbl(ddindx).attribute14;
       x_attribute15(indx) := p_qte_line_tbl(ddindx).attribute15;
       x_ffm_content_name(indx) := p_qte_line_tbl(ddindx).ffm_content_name;
       x_ffm_document_type(indx) := p_qte_line_tbl(ddindx).ffm_document_type;
       x_ffm_media_type(indx) := p_qte_line_tbl(ddindx).ffm_media_type;
       x_ffm_media_id(indx) := p_qte_line_tbl(ddindx).ffm_media_id;
       x_ffm_content_type(indx) := p_qte_line_tbl(ddindx).ffm_content_type;
       x_ffm_user_note(indx) := p_qte_line_tbl(ddindx).ffm_user_note;
       --*/

       indx := indx+1;
       IF p_qte_line_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_line_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Qte_Line_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso quote line detail table
PROCEDURE Set_Qte_Line_Dtl_Tbl_Out(
   p_qte_line_dtl_tbl               IN  ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type,
   x_quote_line_detail_id           OUT NOCOPY  jtf_number_table

   /*-- The following output parameters are ignored
   x_operation_code                 OUT NOCOPY  jtf_varchar2_table_100,
   x_qte_line_index                 OUT NOCOPY  jtf_number_table,
   x_creation_date                  OUT NOCOPY  jtf_date_table,
   x_created_by                     OUT NOCOPY  jtf_number_table,
   x_last_update_date               OUT NOCOPY  jtf_date_table,
   x_last_updated_by                OUT NOCOPY  jtf_number_table,
   x_last_update_login              OUT NOCOPY  jtf_number_table,
   x_request_id                     OUT NOCOPY  jtf_number_table,
   x_program_application_id         OUT NOCOPY  jtf_number_table,
   x_program_id                     OUT NOCOPY  jtf_number_table,
   x_program_update_date            OUT NOCOPY  jtf_date_table,
   x_quote_line_id                  OUT NOCOPY  jtf_number_table,
   x_config_header_id               OUT NOCOPY  jtf_number_table,
   x_config_revision_num            OUT NOCOPY  jtf_number_table,
   x_config_item_id                 OUT NOCOPY  jtf_number_table,
   x_complete_configuration         OUT NOCOPY  jtf_varchar2_table_100,
   x_valid_configuration_flag       OUT NOCOPY  jtf_varchar2_table_100,
   x_component_code                 OUT NOCOPY  jtf_varchar2_table_1200,
   x_service_coterminate_flag       OUT NOCOPY  jtf_varchar2_table_100,
   x_service_duration               OUT NOCOPY  jtf_number_table,
   x_service_period                 OUT NOCOPY  jtf_varchar2_table_100,
   x_service_unit_selling           OUT NOCOPY  jtf_number_table,
   x_service_unit_list              OUT NOCOPY  jtf_number_table,
   x_service_number                 OUT NOCOPY  jtf_number_table,
   x_unit_percent_base_price        OUT NOCOPY  jtf_number_table,
   x_attribute_category             OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute1                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute2                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute3                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute4                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute5                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute6                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute7                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute8                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute9                     OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute10                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute11                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute12                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute13                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute14                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute15                    OUT NOCOPY  jtf_varchar2_table_200,
   x_service_ref_type_code          OUT NOCOPY  jtf_varchar2_table_100,
   x_service_ref_order_number       OUT NOCOPY  jtf_number_table,
   x_service_ref_line_number        OUT NOCOPY  jtf_number_table,
   x_service_ref_qte_line_ind       OUT NOCOPY  jtf_number_table,
   x_service_ref_line_id            OUT NOCOPY  jtf_number_table,
   x_service_ref_system_id          OUT NOCOPY  jtf_number_table,
   x_service_ref_option_numb        OUT NOCOPY  jtf_number_table,
   x_service_ref_shipment           OUT NOCOPY  jtf_number_table,
   x_return_ref_type                OUT NOCOPY  jtf_varchar2_table_100,
   x_return_ref_header_id           OUT NOCOPY  jtf_number_table,
   x_return_ref_line_id             OUT NOCOPY  jtf_number_table,
   x_return_attribute1              OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute2              OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute3              OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute4              OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute5              OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute6              OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute7              OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute8              OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute9              OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute10             OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute11             OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute15             OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute12             OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute13             OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attribute14             OUT NOCOPY  jtf_varchar2_table_300,
   x_return_attr_category           OUT NOCOPY  jtf_varchar2_table_100,
   x_return_reason_code             OUT NOCOPY  jtf_varchar2_table_100,
   x_change_reason_code             OUT NOCOPY  jtf_varchar2_table_100
   --*/
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_quote_line_detail_id := jtf_number_table();

   /*-- The following output parameters are ignored
   x_operation_code := jtf_varchar2_table_100();
   x_qte_line_index := jtf_number_table();
   x_creation_date := jtf_date_table();
   x_created_by := jtf_number_table();
   x_last_update_date := jtf_date_table();
   x_last_updated_by := jtf_number_table();
   x_last_update_login := jtf_number_table();
   x_request_id := jtf_number_table();
   x_program_application_id := jtf_number_table();
   x_program_id := jtf_number_table();
   x_program_update_date := jtf_date_table();
   x_quote_line_id := jtf_number_table();
   x_config_header_id := jtf_number_table();
   x_config_revision_num := jtf_number_table();
   x_config_item_id := jtf_number_table();
   x_complete_configuration:= jtf_varchar2_table_100();
   x_valid_configuration_flag := jtf_varchar2_table_100();
   x_component_code := jtf_varchar2_table_1200();
   x_service_coterminate_flag := jtf_varchar2_table_100();
   x_service_duration := jtf_number_table();
   x_service_period := jtf_varchar2_table_100();
   x_service_unit_selling := jtf_number_table();
   x_service_unit_list:= jtf_number_table();
   x_service_number := jtf_number_table();
   x_unit_percent_base_price := jtf_number_table();
   x_attribute_category := jtf_varchar2_table_100();
   x_attribute1 := jtf_varchar2_table_200();
   x_attribute2 := jtf_varchar2_table_200();
   x_attribute3 := jtf_varchar2_table_200();
   x_attribute4 := jtf_varchar2_table_200();
   x_attribute5 := jtf_varchar2_table_200();
   x_attribute6 := jtf_varchar2_table_200();
   x_attribute7 := jtf_varchar2_table_200();
   x_attribute8 := jtf_varchar2_table_200();
   x_attribute9 := jtf_varchar2_table_200();
   x_attribute10 := jtf_varchar2_table_200();
   x_attribute11 := jtf_varchar2_table_200();
   x_attribute12 := jtf_varchar2_table_200();
   x_attribute13 := jtf_varchar2_table_200();
   x_attribute14 := jtf_varchar2_table_200();
   x_attribute15 := jtf_varchar2_table_200();
   x_service_ref_type_code := jtf_varchar2_table_100();
   x_service_ref_order_number := jtf_number_table();
   x_service_ref_line_number := jtf_number_table();
   x_service_ref_qte_line_ind := jtf_number_table();
   x_service_ref_line_id := jtf_number_table();
   x_service_ref_system_id := jtf_number_table();
   x_service_ref_option_numb := jtf_number_table();
   x_service_ref_shipment:= jtf_number_table();
   x_return_ref_type := jtf_varchar2_table_100();
   x_return_ref_header_id := jtf_number_table();
   x_return_ref_line_id := jtf_number_table();
   x_return_attribute1 := jtf_varchar2_table_300();
   x_return_attribute2 := jtf_varchar2_table_300();
   x_return_attribute3 := jtf_varchar2_table_300();
   x_return_attribute4 := jtf_varchar2_table_300();
   x_return_attribute5 := jtf_varchar2_table_300();
   x_return_attribute6 := jtf_varchar2_table_300();
   x_return_attribute7 := jtf_varchar2_table_300();
   x_return_attribute8 := jtf_varchar2_table_300();
   x_return_attribute9 := jtf_varchar2_table_300();
   x_return_attribute10 := jtf_varchar2_table_300();
   x_return_attribute11 := jtf_varchar2_table_300();
   x_return_attribute15 := jtf_varchar2_table_300();
   x_return_attribute12 := jtf_varchar2_table_300();
   x_return_attribute13 := jtf_varchar2_table_300();
   x_return_attribute14 := jtf_varchar2_table_300();
   x_return_attr_category := jtf_varchar2_table_100();
   x_return_reason_code := jtf_varchar2_table_100();
   x_change_reason_code := jtf_varchar2_table_100();
   --*/

   IF p_qte_line_dtl_tbl.count > 0 THEN
     x_quote_line_detail_id.extend(p_qte_line_dtl_tbl.count);

     /*-- The following output parameters are ignored
     x_operation_code.extend(p_qte_line_dtl_tbl.count);
     x_qte_line_index.extend(p_qte_line_dtl_tbl.count);
     x_creation_date.extend(p_qte_line_dtl_tbl.count);
     x_created_by.extend(p_qte_line_dtl_tbl.count);
     x_last_update_date.extend(p_qte_line_dtl_tbl.count);
     x_last_updated_by.extend(p_qte_line_dtl_tbl.count);
     x_last_update_login.extend(p_qte_line_dtl_tbl.count);
     x_request_id.extend(p_qte_line_dtl_tbl.count);
     x_program_application_id.extend(p_qte_line_dtl_tbl.count);
     x_program_id.extend(p_qte_line_dtl_tbl.count);
     x_program_update_date.extend(p_qte_line_dtl_tbl.count);
     x_quote_line_id.extend(p_qte_line_dtl_tbl.count);
     x_config_header_id.extend(p_qte_line_dtl_tbl.count);
     x_config_revision_num.extend(p_qte_line_dtl_tbl.count);
     x_config_item_id.extend(p_qte_line_dtl_tbl.count);
     x_complete_configuration.extend(p_qte_line_dtl_tbl.count);
     x_valid_configuration_flag.extend(p_qte_line_dtl_tbl.count);
     x_component_code.extend(p_qte_line_dtl_tbl.count);
     x_service_coterminate_flag.extend(p_qte_line_dtl_tbl.count);
     x_service_duration.extend(p_qte_line_dtl_tbl.count);
     x_service_period.extend(p_qte_line_dtl_tbl.count);
     x_service_unit_selling.extend(p_qte_line_dtl_tbl.count);
     x_service_unit_list.extend(p_qte_line_dtl_tbl.count);
     x_service_number.extend(p_qte_line_dtl_tbl.count);
     x_unit_percent_base_price.extend(p_qte_line_dtl_tbl.count);
     x_attribute_category.extend(p_qte_line_dtl_tbl.count);
     x_attribute1.extend(p_qte_line_dtl_tbl.count);
     x_attribute2.extend(p_qte_line_dtl_tbl.count);
     x_attribute3.extend(p_qte_line_dtl_tbl.count);
     x_attribute4.extend(p_qte_line_dtl_tbl.count);
     x_attribute5.extend(p_qte_line_dtl_tbl.count);
     x_attribute6.extend(p_qte_line_dtl_tbl.count);
     x_attribute7.extend(p_qte_line_dtl_tbl.count);
     x_attribute8.extend(p_qte_line_dtl_tbl.count);
     x_attribute9.extend(p_qte_line_dtl_tbl.count);
     x_attribute10.extend(p_qte_line_dtl_tbl.count);
     x_attribute11.extend(p_qte_line_dtl_tbl.count);
     x_attribute12.extend(p_qte_line_dtl_tbl.count);
     x_attribute13.extend(p_qte_line_dtl_tbl.count);
     x_attribute14.extend(p_qte_line_dtl_tbl.count);
     x_attribute15.extend(p_qte_line_dtl_tbl.count);
     x_service_ref_type_code.extend(p_qte_line_dtl_tbl.count);
     x_service_ref_order_number.extend(p_qte_line_dtl_tbl.count);
     x_service_ref_line_number.extend(p_qte_line_dtl_tbl.count);
     x_service_ref_qte_line_ind.extend(p_qte_line_dtl_tbl.count);
     x_service_ref_line_id.extend(p_qte_line_dtl_tbl.count);
     x_service_ref_system_id.extend(p_qte_line_dtl_tbl.count);
     x_service_ref_option_numb.extend(p_qte_line_dtl_tbl.count);
     x_service_ref_shipment.extend(p_qte_line_dtl_tbl.count);
     x_return_ref_type.extend(p_qte_line_dtl_tbl.count);
     x_return_ref_header_id.extend(p_qte_line_dtl_tbl.count);
     x_return_ref_line_id.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute1.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute2.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute3.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute4.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute5.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute6.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute7.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute8.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute9.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute10.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute11.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute15.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute12.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute13.extend(p_qte_line_dtl_tbl.count);
     x_return_attribute14.extend(p_qte_line_dtl_tbl.count);
     x_return_attr_category.extend(p_qte_line_dtl_tbl.count);
     x_return_reason_code.extend(p_qte_line_dtl_tbl.count);
     x_change_reason_code.extend(p_qte_line_dtl_tbl.count);
     --*/

     ddindx := p_qte_line_dtl_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_quote_line_detail_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).quote_line_detail_id);

       /*-- The following output parameters are ignored
       x_operation_code(indx) := p_qte_line_dtl_tbl(ddindx).operation_code;
       x_qte_line_index(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).qte_line_index);
       x_creation_date(indx) := p_qte_line_dtl_tbl(ddindx).creation_date;
       x_created_by(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).created_by);
       x_last_update_date(indx) := p_qte_line_dtl_tbl(ddindx).last_update_date;
       x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).last_updated_by);
       x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).last_update_login);
       x_request_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).request_id);
       x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).program_application_id);
       x_program_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).program_id);
       x_program_update_date(indx) := p_qte_line_dtl_tbl(ddindx).program_update_date;
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).quote_line_id);
       x_config_header_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).config_header_id);
       x_config_revision_num(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).config_revision_num);
       x_config_item_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).config_item_id);
       x_complete_configuration(indx) := p_qte_line_dtl_tbl(ddindx).complete_configuration_flag;
       x_valid_configuration_flag(indx) := p_qte_line_dtl_tbl(ddindx).valid_configuration_flag;
       x_component_code(indx) := p_qte_line_dtl_tbl(ddindx).component_code;
       x_service_coterminate_flag(indx) := p_qte_line_dtl_tbl(ddindx).service_coterminate_flag;
       x_service_duration(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_duration);
       x_service_period(indx) := p_qte_line_dtl_tbl(ddindx).service_period;
       x_service_unit_selling(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_unit_selling_percent);
       x_service_unit_list(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_unit_list_percent);
       x_service_number(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_number);
       x_unit_percent_base_price(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).unit_percent_base_price);
       x_attribute_category(indx) := p_qte_line_dtl_tbl(ddindx).attribute_category;
       x_attribute1(indx) := p_qte_line_dtl_tbl(ddindx).attribute1;
       x_attribute2(indx) := p_qte_line_dtl_tbl(ddindx).attribute2;
       x_attribute3(indx) := p_qte_line_dtl_tbl(ddindx).attribute3;
       x_attribute4(indx) := p_qte_line_dtl_tbl(ddindx).attribute4;
       x_attribute5(indx) := p_qte_line_dtl_tbl(ddindx).attribute5;
       x_attribute6(indx) := p_qte_line_dtl_tbl(ddindx).attribute6;
       x_attribute7(indx) := p_qte_line_dtl_tbl(ddindx).attribute7;
       x_attribute8(indx) := p_qte_line_dtl_tbl(ddindx).attribute8;
       x_attribute9(indx) := p_qte_line_dtl_tbl(ddindx).attribute9;
       x_attribute10(indx) := p_qte_line_dtl_tbl(ddindx).attribute10;
       x_attribute11(indx) := p_qte_line_dtl_tbl(ddindx).attribute11;
       x_attribute12(indx) := p_qte_line_dtl_tbl(ddindx).attribute12;
       x_attribute13(indx) := p_qte_line_dtl_tbl(ddindx).attribute13;
       x_attribute14(indx) := p_qte_line_dtl_tbl(ddindx).attribute14;
       x_attribute15(indx) := p_qte_line_dtl_tbl(ddindx).attribute15;
       x_service_ref_type_code(indx) := p_qte_line_dtl_tbl(ddindx).service_ref_type_code;
       x_service_ref_order_number(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_ref_order_number);
       x_service_ref_line_number(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_ref_line_number);
       x_service_ref_qte_line_ind(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_ref_qte_line_index);
       x_service_ref_line_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_ref_line_id);
       x_service_ref_system_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_ref_system_id);
       x_service_ref_option_numb(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_ref_option_numb);
       x_service_ref_shipment(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).service_ref_shipment_numb);
       x_return_ref_type(indx) := p_qte_line_dtl_tbl(ddindx).return_ref_type;
       x_return_ref_header_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).return_ref_header_id);
       x_return_ref_line_id(indx) := rosetta_g_miss_num_map(p_qte_line_dtl_tbl(ddindx).return_ref_line_id);
       x_return_attribute1(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute1;
       x_return_attribute2(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute2;
       x_return_attribute3(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute3;
       x_return_attribute4(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute4;
       x_return_attribute5(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute5;
       x_return_attribute6(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute6;
       x_return_attribute7(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute7;
       x_return_attribute8(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute8;
       x_return_attribute9(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute9;
       x_return_attribute10(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute10;
       x_return_attribute11(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute11;
       x_return_attribute15(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute15;
       x_return_attribute12(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute12;
       x_return_attribute13(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute13;
       x_return_attribute14(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute14;
       x_return_attr_category(indx) := p_qte_line_dtl_tbl(ddindx).return_attribute_category;
       x_return_reason_code(indx) := p_qte_line_dtl_tbl(ddindx).return_reason_code;
       x_change_reason_code(indx) := p_qte_line_dtl_tbl(ddindx).change_reason_code;
       --*/

       indx := indx+1;
       IF p_qte_line_dtl_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_line_dtl_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Qte_Line_Dtl_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso quote line relationship table
PROCEDURE Set_Line_Rltship_Tbl_Out(
   p_qte_line_rltship_tbl      IN  ASO_Quote_Pub.Line_Rltship_Tbl_Type,
   x_line_relationship_id      OUT NOCOPY  jtf_number_table

   /*-- The following output parameters are ignored
   x_operation_code            OUT NOCOPY  jtf_varchar2_table_100,
   x_creation_date             OUT NOCOPY  jtf_date_table,
   x_created_by                OUT NOCOPY  jtf_number_table,
   x_last_update_date          OUT NOCOPY  jtf_date_table,
   x_last_updated_by           OUT NOCOPY  jtf_number_table,
   x_last_update_login         OUT NOCOPY  jtf_number_table,
   x_request_id                OUT NOCOPY  jtf_number_table,
   x_program_application_id    OUT NOCOPY  jtf_number_table,
   x_program_id                OUT NOCOPY  jtf_number_table,
   x_program_update_date       OUT NOCOPY  jtf_date_table,
   x_quote_line_id             OUT NOCOPY  jtf_number_table,
   x_qte_line_index            OUT NOCOPY  jtf_number_table,
   x_related_quote_line_id     OUT NOCOPY  jtf_number_table,
   x_related_qte_line_index    OUT NOCOPY  jtf_number_table,
   x_relationship_type_code    OUT NOCOPY  jtf_varchar2_table_100,
   x_reciprocal_flag           OUT NOCOPY  jtf_varchar2_table_100
   --*/
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_line_relationship_id := jtf_number_table();

   /*-- The following output parameters are ignored
   x_operation_code := jtf_varchar2_table_100();
   x_creation_date := jtf_date_table();
   x_created_by := jtf_number_table();
   x_last_update_date := jtf_date_table();
   x_last_updated_by := jtf_number_table();
   x_last_update_login := jtf_number_table();
   x_request_id := jtf_number_table();
   x_program_application_id := jtf_number_table();
   x_program_id := jtf_number_table();
   x_program_update_date := jtf_date_table();
   x_quote_line_id := jtf_number_table();
   x_qte_line_index := jtf_number_table();
   x_related_quote_line_id := jtf_number_table();
   x_related_qte_line_index := jtf_number_table();
   x_relationship_type_code := jtf_varchar2_table_100();
   x_reciprocal_flag := jtf_varchar2_table_100();
   --*/

   IF p_qte_line_rltship_tbl.count > 0 THEN
     x_line_relationship_id.extend(p_qte_line_rltship_tbl.count);

     /*-- The following output parameters are ignored
     x_operation_code.extend(p_qte_line_rltship_tbl.count);
     x_creation_date.extend(p_qte_line_rltship_tbl.count);
     x_created_by.extend(p_qte_line_rltship_tbl.count);
     x_last_update_date.extend(p_qte_line_rltship_tbl.count);
     x_last_updated_by.extend(p_qte_line_rltship_tbl.count);
     x_last_update_login.extend(p_qte_line_rltship_tbl.count);
     x_request_id.extend(p_qte_line_rltship_tbl.count);
     x_program_application_id.extend(p_qte_line_rltship_tbl.count);
     x_program_id.extend(p_qte_line_rltship_tbl.count);
     x_program_update_date.extend(p_qte_line_rltship_tbl.count);
     x_quote_line_id.extend(p_qte_line_rltship_tbl.count);
     x_qte_line_index.extend(p_qte_line_rltship_tbl.count);
     x_related_quote_line_id.extend(p_qte_line_rltship_tbl.count);
     x_related_qte_line_index.extend(p_qte_line_rltship_tbl.count);
     x_relationship_type_code.extend(p_qte_line_rltship_tbl.count);
     x_reciprocal_flag.extend(p_qte_line_rltship_tbl.count);
     --*/

     ddindx := p_qte_line_rltship_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_line_relationship_id(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).line_relationship_id);

       /*-- The following output parameters are ignored
       x_operation_code(indx) := p_qte_line_rltship_tbl(ddindx).operation_code;
       x_creation_date(indx) := p_qte_line_rltship_tbl(ddindx).creation_date;
       x_created_by(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).created_by);
       x_last_update_date(indx) := p_qte_line_rltship_tbl(ddindx).last_update_date;
       x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).last_updated_by);
       x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).last_update_login);
       x_request_id(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).request_id);
       x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).program_application_id);
       x_program_id(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).program_id);
       x_program_update_date(indx) := p_qte_line_rltship_tbl(ddindx).program_update_date;
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).quote_line_id);
       x_qte_line_index(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).qte_line_index);
       x_related_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).related_quote_line_id);
       x_related_qte_line_index(indx) := rosetta_g_miss_num_map(p_qte_line_rltship_tbl(ddindx).related_qte_line_index);
       x_relationship_type_code(indx) := p_qte_line_rltship_tbl(ddindx).relationship_type_code;
       x_reciprocal_flag(indx) := p_qte_line_rltship_tbl(ddindx).reciprocal_flag;
       --*/

       indx := indx+1;
       IF p_qte_line_rltship_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_line_rltship_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Line_Rltship_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso payment table
PROCEDURE Set_Payment_Tbl_Out(
   p_qte_payment_tbl               IN  ASO_Quote_Pub.Payment_Tbl_Type,
   x_payment_id                    OUT NOCOPY  jtf_number_table

   /*-- The following output parameters are ignored
   x_operation_code                OUT NOCOPY  jtf_varchar2_table_100,
   x_qte_line_index                OUT NOCOPY  jtf_number_table,
   x_shipment_index                OUT NOCOPY  jtf_number_table,
   x_creation_date                 OUT NOCOPY  jtf_date_table,
   x_created_by                    OUT NOCOPY  jtf_number_table,
   x_last_update_date              OUT NOCOPY  jtf_date_table,
   x_last_updated_by               OUT NOCOPY  jtf_number_table,
   x_last_update_login             OUT NOCOPY  jtf_number_table,
   x_request_id                    OUT NOCOPY  jtf_number_table,
   x_program_application_id        OUT NOCOPY  jtf_number_table,
   x_program_id                    OUT NOCOPY  jtf_number_table,
   x_program_update_date           OUT NOCOPY  jtf_date_table,
   x_quote_header_id               OUT NOCOPY  jtf_number_table,
   x_quote_line_id                 OUT NOCOPY  jtf_number_table,
   x_quote_shipment_id             OUT NOCOPY  jtf_number_table,
   x_payment_type_code             OUT NOCOPY  jtf_varchar2_table_100,
   x_payment_ref_number            OUT NOCOPY  jtf_varchar2_table_300,
   x_payment_option                OUT NOCOPY  jtf_varchar2_table_300,
   x_payment_term_id               OUT NOCOPY  jtf_number_table,
   x_credit_card_code              OUT NOCOPY  jtf_varchar2_table_100,
   x_credit_card_holder_name       OUT NOCOPY  jtf_varchar2_table_100,
   x_credit_card_exp_date          OUT NOCOPY  jtf_date_table,
   x_credit_card_approval_code     OUT NOCOPY  jtf_varchar2_table_100,
   x_credit_card_approval_date     OUT NOCOPY  jtf_date_table,
   x_payment_amount                OUT NOCOPY  jtf_number_table,
   x_attribute_category            OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute1                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute2                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute3                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute4                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute5                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute6                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute7                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute8                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute9                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute10                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute11                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute12                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute13                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute14                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute15                   OUT NOCOPY  jtf_varchar2_table_200,
   x_cust_po_number                OUT NOCOPY  jtf_varchar2_table_100
   --*/
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_payment_id := jtf_number_table();

   /*-- The following output parameters are ignored
   x_operation_code := jtf_varchar2_table_100();
   x_qte_line_index := jtf_number_table();
   x_shipment_index := jtf_number_table();
   x_creation_date := jtf_date_table();
   x_created_by := jtf_number_table();
   x_last_update_date := jtf_date_table();
   x_last_updated_by := jtf_number_table();
   x_last_update_login := jtf_number_table();
   x_request_id := jtf_number_table();
   x_program_application_id := jtf_number_table();
   x_program_id := jtf_number_table();
   x_program_update_date := jtf_date_table();
   x_quote_header_id := jtf_number_table();
   x_quote_line_id := jtf_number_table();
   x_quote_shipment_id := jtf_number_table();
   x_payment_type_code := jtf_varchar2_table_100();
   x_payment_ref_number := jtf_varchar2_table_300();
   x_payment_option := jtf_varchar2_table_300();
   x_payment_term_id := jtf_number_table();
   x_credit_card_code := jtf_varchar2_table_100();
   x_credit_card_holder_name := jtf_varchar2_table_100();
   x_credit_card_exp_date := jtf_date_table();
   x_credit_card_approval_code := jtf_varchar2_table_100();
   x_credit_card_approval_date := jtf_date_table();
   x_payment_amount := jtf_number_table();
   x_attribute_category := jtf_varchar2_table_100();
   x_attribute1 := jtf_varchar2_table_200();
   x_attribute2 := jtf_varchar2_table_200();
   x_attribute3 := jtf_varchar2_table_200();
   x_attribute4 := jtf_varchar2_table_200();
   x_attribute5 := jtf_varchar2_table_200();
   x_attribute6 := jtf_varchar2_table_200();
   x_attribute7 := jtf_varchar2_table_200();
   x_attribute8 := jtf_varchar2_table_200();
   x_attribute9 := jtf_varchar2_table_200();
   x_attribute10 := jtf_varchar2_table_200();
   x_attribute11 := jtf_varchar2_table_200();
   x_attribute12 := jtf_varchar2_table_200();
   x_attribute13 := jtf_varchar2_table_200();
   x_attribute14 := jtf_varchar2_table_200();
   x_attribute15 := jtf_varchar2_table_200();
   x_cust_po_number := jtf_varchar2_table_100();
   --*/
   IF p_qte_payment_tbl.count > 0 THEN
     x_payment_id.extend(p_qte_payment_tbl.count);

     /*-- The following output parameters are ignored
     x_operation_code.extend(p_qte_payment_tbl.count);
     x_qte_line_index.extend(p_qte_payment_tbl.count);
     x_shipment_index.extend(p_qte_payment_tbl.count);
     x_creation_date.extend(p_qte_payment_tbl.count);
     x_created_by.extend(p_qte_payment_tbl.count);
     x_last_update_date.extend(p_qte_payment_tbl.count);
     x_last_updated_by.extend(p_qte_payment_tbl.count);
     x_last_update_login.extend(p_qte_payment_tbl.count);
     x_request_id.extend(p_qte_payment_tbl.count);
     x_program_application_id.extend(p_qte_payment_tbl.count);
     x_program_id.extend(p_qte_payment_tbl.count);
     x_program_update_date.extend(p_qte_payment_tbl.count);
     x_quote_header_id.extend(p_qte_payment_tbl.count);
     x_quote_line_id.extend(p_qte_payment_tbl.count);
     x_quote_shipment_id.extend(p_qte_payment_tbl.count);
     x_payment_type_code.extend(p_qte_payment_tbl.count);
     x_payment_ref_number.extend(p_qte_payment_tbl.count);
     x_payment_option.extend(p_qte_payment_tbl.count);
     x_payment_term_id.extend(p_qte_payment_tbl.count);
     x_credit_card_code.extend(p_qte_payment_tbl.count);
     x_credit_card_holder_name.extend(p_qte_payment_tbl.count);
     x_credit_card_exp_date.extend(p_qte_payment_tbl.count);
     x_credit_card_approval_code.extend(p_qte_payment_tbl.count);
     x_credit_card_approval_date.extend(p_qte_payment_tbl.count);
     x_payment_amount.extend(p_qte_payment_tbl.count);
     x_attribute_category.extend(p_qte_payment_tbl.count);
     x_attribute1.extend(p_qte_payment_tbl.count);
     x_attribute2.extend(p_qte_payment_tbl.count);
     x_attribute3.extend(p_qte_payment_tbl.count);
     x_attribute4.extend(p_qte_payment_tbl.count);
     x_attribute5.extend(p_qte_payment_tbl.count);
     x_attribute6.extend(p_qte_payment_tbl.count);
     x_attribute7.extend(p_qte_payment_tbl.count);
     x_attribute8.extend(p_qte_payment_tbl.count);
     x_attribute9.extend(p_qte_payment_tbl.count);
     x_attribute10.extend(p_qte_payment_tbl.count);
     x_attribute11.extend(p_qte_payment_tbl.count);
     x_attribute12.extend(p_qte_payment_tbl.count);
     x_attribute13.extend(p_qte_payment_tbl.count);
     x_attribute14.extend(p_qte_payment_tbl.count);
     x_attribute15.extend(p_qte_payment_tbl.count);
     x_cust_po_number.extend(p_qte_payment_tbl.count);
     --*/

     ddindx := p_qte_payment_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_payment_id(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).payment_id);

       /*-- The following output parameters are ignored
       x_operation_code(indx) := p_qte_payment_tbl(ddindx).operation_code;
       x_qte_line_index(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).qte_line_index);
       x_shipment_index(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).shipment_index);
       x_creation_date(indx) := p_qte_payment_tbl(ddindx).creation_date;
       x_created_by(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).created_by);
       x_last_update_date(indx) := p_qte_payment_tbl(ddindx).last_update_date;
       x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).last_updated_by);
       x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).last_update_login);
       x_request_id(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).request_id);
       x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).program_application_id);
       x_program_id(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).program_id);
       x_program_update_date(indx) := p_qte_payment_tbl(ddindx).program_update_date;
       x_quote_header_id(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).quote_header_id);
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).quote_line_id);
       x_quote_shipment_id(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).quote_shipment_id);
       x_payment_type_code(indx) := p_qte_payment_tbl(ddindx).payment_type_code;
       x_payment_ref_number(indx) := p_qte_payment_tbl(ddindx).payment_ref_number;
       x_payment_option(indx) := p_qte_payment_tbl(ddindx).payment_option;
       x_payment_term_id(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).payment_term_id);
       x_credit_card_code(indx) := p_qte_payment_tbl(ddindx).credit_card_code;
       x_credit_card_holder_name(indx) := p_qte_payment_tbl(ddindx).credit_card_holder_name;
       x_credit_card_exp_date(indx) := p_qte_payment_tbl(ddindx).credit_card_expiration_date;
       x_credit_card_approval_code(indx) := p_qte_payment_tbl(ddindx).credit_card_approval_code;
       x_credit_card_approval_date(indx) := p_qte_payment_tbl(ddindx).credit_card_approval_date;
       x_payment_amount(indx) := rosetta_g_miss_num_map(p_qte_payment_tbl(ddindx).payment_amount);
       x_attribute_category(indx) := p_qte_payment_tbl(ddindx).attribute_category;
       x_attribute1(indx) := p_qte_payment_tbl(ddindx).attribute1;
       x_attribute2(indx) := p_qte_payment_tbl(ddindx).attribute2;
       x_attribute3(indx) := p_qte_payment_tbl(ddindx).attribute3;
       x_attribute4(indx) := p_qte_payment_tbl(ddindx).attribute4;
       x_attribute5(indx) := p_qte_payment_tbl(ddindx).attribute5;
       x_attribute6(indx) := p_qte_payment_tbl(ddindx).attribute6;
       x_attribute7(indx) := p_qte_payment_tbl(ddindx).attribute7;
       x_attribute8(indx) := p_qte_payment_tbl(ddindx).attribute8;
       x_attribute9(indx) := p_qte_payment_tbl(ddindx).attribute9;
       x_attribute10(indx) := p_qte_payment_tbl(ddindx).attribute10;
       x_attribute11(indx) := p_qte_payment_tbl(ddindx).attribute11;
       x_attribute12(indx) := p_qte_payment_tbl(ddindx).attribute12;
       x_attribute13(indx) := p_qte_payment_tbl(ddindx).attribute13;
       x_attribute14(indx) := p_qte_payment_tbl(ddindx).attribute14;
       x_attribute15(indx) := p_qte_payment_tbl(ddindx).attribute15;
       x_cust_po_number(indx) := p_qte_payment_tbl(ddindx).cust_po_number;
       --*/

       indx := indx+1;
       IF p_qte_payment_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_payment_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Payment_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso shipment table
PROCEDURE Set_Shipment_Tbl_Out(
   p_qte_shipment_tbl            IN  ASO_Quote_Pub.Shipment_Tbl_Type,
   x_shipment_id                 OUT NOCOPY  jtf_number_table

   /*-- The following output parameters are ignored
   x_operation_code              OUT NOCOPY  jtf_varchar2_table_100,
   x_qte_line_index              OUT NOCOPY  jtf_number_table,
   x_creation_date               OUT NOCOPY  jtf_date_table,
   x_created_by                  OUT NOCOPY  jtf_number_table,
   x_last_update_date            OUT NOCOPY  jtf_date_table,
   x_last_updated_by             OUT NOCOPY  jtf_number_table,
   x_last_update_login           OUT NOCOPY  jtf_number_table,
   x_request_id                  OUT NOCOPY  jtf_number_table,
   x_program_application_id      OUT NOCOPY  jtf_number_table,
   x_program_id                  OUT NOCOPY  jtf_number_table,
   x_program_update_date         OUT NOCOPY  jtf_date_table,
   x_quote_header_id             OUT NOCOPY  jtf_number_table,
   x_quote_line_id               OUT NOCOPY  jtf_number_table,
   x_promise_date                OUT NOCOPY  jtf_date_table,
   x_request_date                OUT NOCOPY  jtf_date_table,
   x_schedule_ship_date          OUT NOCOPY  jtf_date_table,
   x_ship_to_party_site_id       OUT NOCOPY  jtf_number_table,
   x_ship_to_party_id            OUT NOCOPY  jtf_number_table,
   x_ship_to_cust_account_id     OUT NOCOPY  jtf_number_table,
   x_ship_partial_flag           OUT NOCOPY  jtf_varchar2_table_300,
   x_ship_set_id                 OUT NOCOPY  jtf_number_table,
   x_ship_method_code            OUT NOCOPY  jtf_varchar2_table_100,
   x_freight_terms_code          OUT NOCOPY  jtf_varchar2_table_100,
   x_freight_carrier_code        OUT NOCOPY  jtf_varchar2_table_100,
   x_fob_code                    OUT NOCOPY  jtf_varchar2_table_100,
   x_shipping_instructions       OUT NOCOPY  jtf_varchar2_table_2000,
   x_packing_instructions        OUT NOCOPY  jtf_varchar2_table_2000,
   x_ship_quote_price            OUT NOCOPY  jtf_number_table,
   x_quantity                    OUT NOCOPY  jtf_number_table,
   x_pricing_quantity            OUT NOCOPY  jtf_number_table,
   x_reserved_quantity           OUT NOCOPY  jtf_varchar2_table_300,
   x_reservation_id              OUT NOCOPY  jtf_number_table,
   x_order_line_id               OUT NOCOPY  jtf_number_table,
   x_ship_to_party_name          OUT NOCOPY  jtf_varchar2_table_300,
   x_ship_to_cont_first_name     OUT NOCOPY  jtf_varchar2_table_200,
   x_ship_to_cont_mid_name       OUT NOCOPY  jtf_varchar2_table_100,
   x_ship_to_cont_last_name      OUT NOCOPY  jtf_varchar2_table_200,
   x_ship_to_address1            OUT NOCOPY  jtf_varchar2_table_300,
   x_ship_to_address2            OUT NOCOPY  jtf_varchar2_table_300,
   x_ship_to_address3            OUT NOCOPY  jtf_varchar2_table_300,
   x_ship_to_address4            OUT NOCOPY  jtf_varchar2_table_300,
   x_ship_to_country_code        OUT NOCOPY  jtf_varchar2_table_100,
   x_ship_to_country             OUT NOCOPY  jtf_varchar2_table_100,
   x_ship_to_city                OUT NOCOPY  jtf_varchar2_table_100,
   x_ship_to_postal_code         OUT NOCOPY  jtf_varchar2_table_100,
   x_ship_to_state               OUT NOCOPY  jtf_varchar2_table_100,
   x_ship_to_province            OUT NOCOPY  jtf_varchar2_table_100,
   x_ship_to_county              OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute_category          OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute1                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute2                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute3                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute4                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute5                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute6                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute7                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute8                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute9                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute10                 OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute11                 OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute12                 OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute13                 OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute14                 OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute15                 OUT NOCOPY  jtf_varchar2_table_200,
   x_shipment_priority_code      OUT NOCOPY  jtf_varchar2_table_100,
   x_ship_from_org_id            OUT NOCOPY  jtf_number_table
   --*/
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_shipment_id := jtf_number_table();

   /*-- The following output parameters are ignored
   x_operation_code := jtf_varchar2_table_100();
   x_qte_line_index := jtf_number_table();
   x_creation_date := jtf_date_table();
   x_created_by := jtf_number_table();
   x_last_update_date := jtf_date_table();
   x_last_updated_by := jtf_number_table();
   x_last_update_login := jtf_number_table();
   x_request_id := jtf_number_table();
   x_program_application_id := jtf_number_table();
   x_program_id := jtf_number_table();
   x_program_update_date := jtf_date_table();
   x_quote_header_id := jtf_number_table();
   x_quote_line_id := jtf_number_table();
   x_promise_date := jtf_date_table();
   x_request_date := jtf_date_table();
   x_schedule_ship_date := jtf_date_table();
   x_ship_to_party_site_id := jtf_number_table();
   x_ship_to_party_id := jtf_number_table();
   x_ship_to_cust_account_id := jtf_number_table();
   x_ship_partial_flag := jtf_varchar2_table_300();
   x_ship_set_id := jtf_number_table();
   x_ship_method_code := jtf_varchar2_table_100();
   x_freight_terms_code := jtf_varchar2_table_100();
   x_freight_carrier_code := jtf_varchar2_table_100();
   x_fob_code := jtf_varchar2_table_100();
   x_shipping_instructions := jtf_varchar2_table_2000();
   x_packing_instructions := jtf_varchar2_table_2000();
   x_ship_quote_price := jtf_number_table();
   x_quantity := jtf_number_table();
   x_pricing_quantity := jtf_number_table();
   x_reserved_quantity := jtf_varchar2_table_300();
   x_reservation_id := jtf_number_table();
   x_order_line_id := jtf_number_table();
   x_ship_to_party_name := jtf_varchar2_table_300();
   x_ship_to_cont_first_name := jtf_varchar2_table_200();
   x_ship_to_cont_mid_name := jtf_varchar2_table_100();
   x_ship_to_cont_last_name := jtf_varchar2_table_200();
   x_ship_to_address1 := jtf_varchar2_table_300();
   x_ship_to_address2 := jtf_varchar2_table_300();
   x_ship_to_address3 := jtf_varchar2_table_300();
   x_ship_to_address4 := jtf_varchar2_table_300();
   x_ship_to_country_code := jtf_varchar2_table_100();
   x_ship_to_country := jtf_varchar2_table_100();
   x_ship_to_city := jtf_varchar2_table_100();
   x_ship_to_postal_code := jtf_varchar2_table_100();
   x_ship_to_state := jtf_varchar2_table_100();
   x_ship_to_province := jtf_varchar2_table_100();
   x_ship_to_county := jtf_varchar2_table_100();
   x_attribute_category := jtf_varchar2_table_100();
   x_attribute1 := jtf_varchar2_table_200();
   x_attribute2 := jtf_varchar2_table_200();
   x_attribute3 := jtf_varchar2_table_200();
   x_attribute4 := jtf_varchar2_table_200();
   x_attribute5 := jtf_varchar2_table_200();
   x_attribute6 := jtf_varchar2_table_200();
   x_attribute7 := jtf_varchar2_table_200();
   x_attribute8 := jtf_varchar2_table_200();
   x_attribute9 := jtf_varchar2_table_200();
   x_attribute10 := jtf_varchar2_table_200();
   x_attribute11 := jtf_varchar2_table_200();
   x_attribute12 := jtf_varchar2_table_200();
   x_attribute13 := jtf_varchar2_table_200();
   x_attribute14 := jtf_varchar2_table_200();
   x_attribute15 := jtf_varchar2_table_200();
   x_shipment_priority_code := jtf_varchar2_table_100();
   x_ship_from_org_id := jtf_number_table();
   --*/

   IF p_qte_shipment_tbl.count > 0 THEN
     x_shipment_id.extend(p_qte_shipment_tbl.count);

     /*-- The following output parameters are ignored
     x_operation_code.extend(p_qte_shipment_tbl.count);
     x_qte_line_index.extend(p_qte_shipment_tbl.count);
     x_creation_date.extend(p_qte_shipment_tbl.count);
     x_created_by.extend(p_qte_shipment_tbl.count);
     x_last_update_date.extend(p_qte_shipment_tbl.count);
     x_last_updated_by.extend(p_qte_shipment_tbl.count);
     x_last_update_login.extend(p_qte_shipment_tbl.count);
     x_request_id.extend(p_qte_shipment_tbl.count);
     x_program_application_id.extend(p_qte_shipment_tbl.count);
     x_program_id.extend(p_qte_shipment_tbl.count);
     x_program_update_date.extend(p_qte_shipment_tbl.count);
     x_quote_header_id.extend(p_qte_shipment_tbl.count);
     x_quote_line_id.extend(p_qte_shipment_tbl.count);
     x_promise_date.extend(p_qte_shipment_tbl.count);
     x_request_date.extend(p_qte_shipment_tbl.count);
     x_schedule_ship_date.extend(p_qte_shipment_tbl.count);
     x_ship_to_party_site_id.extend(p_qte_shipment_tbl.count);
     x_ship_to_party_id.extend(p_qte_shipment_tbl.count);
     x_ship_to_cust_account_id.extend(p_qte_shipment_tbl.count);
     x_ship_partial_flag.extend(p_qte_shipment_tbl.count);
     x_ship_set_id.extend(p_qte_shipment_tbl.count);
     x_ship_method_code.extend(p_qte_shipment_tbl.count);
     x_freight_terms_code.extend(p_qte_shipment_tbl.count);
     x_freight_carrier_code.extend(p_qte_shipment_tbl.count);
     x_fob_code.extend(p_qte_shipment_tbl.count);
     x_shipping_instructions.extend(p_qte_shipment_tbl.count);
     x_packing_instructions.extend(p_qte_shipment_tbl.count);
     x_ship_quote_price.extend(p_qte_shipment_tbl.count);
     x_quantity.extend(p_qte_shipment_tbl.count);
     x_pricing_quantity.extend(p_qte_shipment_tbl.count);
     x_reserved_quantity.extend(p_qte_shipment_tbl.count);
     x_reservation_id.extend(p_qte_shipment_tbl.count);
     x_order_line_id.extend(p_qte_shipment_tbl.count);
     x_ship_to_party_name.extend(p_qte_shipment_tbl.count);
     x_ship_to_cont_first_name.extend(p_qte_shipment_tbl.count);
     x_ship_to_cont_mid_name.extend(p_qte_shipment_tbl.count);
     x_ship_to_cont_last_name.extend(p_qte_shipment_tbl.count);
     x_ship_to_address1.extend(p_qte_shipment_tbl.count);
     x_ship_to_address2.extend(p_qte_shipment_tbl.count);
     x_ship_to_address3.extend(p_qte_shipment_tbl.count);
     x_ship_to_address4.extend(p_qte_shipment_tbl.count);
     x_ship_to_country_code.extend(p_qte_shipment_tbl.count);
     x_ship_to_country.extend(p_qte_shipment_tbl.count);
     x_ship_to_city.extend(p_qte_shipment_tbl.count);
     x_ship_to_postal_code.extend(p_qte_shipment_tbl.count);
     x_ship_to_state.extend(p_qte_shipment_tbl.count);
     x_ship_to_province.extend(p_qte_shipment_tbl.count);
     x_ship_to_county.extend(p_qte_shipment_tbl.count);
     x_attribute_category.extend(p_qte_shipment_tbl.count);
     x_attribute1.extend(p_qte_shipment_tbl.count);
     x_attribute2.extend(p_qte_shipment_tbl.count);
     x_attribute3.extend(p_qte_shipment_tbl.count);
     x_attribute4.extend(p_qte_shipment_tbl.count);
     x_attribute5.extend(p_qte_shipment_tbl.count);
     x_attribute6.extend(p_qte_shipment_tbl.count);
     x_attribute7.extend(p_qte_shipment_tbl.count);
     x_attribute8.extend(p_qte_shipment_tbl.count);
     x_attribute9.extend(p_qte_shipment_tbl.count);
     x_attribute10.extend(p_qte_shipment_tbl.count);
     x_attribute11.extend(p_qte_shipment_tbl.count);
     x_attribute12.extend(p_qte_shipment_tbl.count);
     x_attribute13.extend(p_qte_shipment_tbl.count);
     x_attribute14.extend(p_qte_shipment_tbl.count);
     x_attribute15.extend(p_qte_shipment_tbl.count);
     x_shipment_priority_code.extend(p_qte_shipment_tbl.count);
     x_ship_from_org_id.extend(p_qte_shipment_tbl.count);
     --*/

     ddindx := p_qte_shipment_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_shipment_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).shipment_id);

       /*-- The following output parameters are ignored
       x_operation_code(indx) := p_qte_shipment_tbl(ddindx).operation_code;
       x_qte_line_index(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).qte_line_index);
       x_creation_date(indx) := p_qte_shipment_tbl(ddindx).creation_date;
       x_created_by(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).created_by);
       x_last_update_date(indx) := p_qte_shipment_tbl(ddindx).last_update_date;
       x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).last_updated_by);
       x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).last_update_login);
       x_request_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).request_id);
       x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).program_application_id);
       x_program_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).program_id);
       x_program_update_date(indx) := p_qte_shipment_tbl(ddindx).program_update_date;
       x_quote_header_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).quote_header_id);
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).quote_line_id);
       x_promise_date(indx) := p_qte_shipment_tbl(ddindx).promise_date;
       x_request_date(indx) := p_qte_shipment_tbl(ddindx).request_date;
       x_schedule_ship_date(indx) := p_qte_shipment_tbl(ddindx).schedule_ship_date;
       x_ship_to_party_site_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).ship_to_party_site_id);
       x_ship_to_party_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).ship_to_party_id);
       x_ship_to_cust_account_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).ship_to_cust_account_id);
       x_ship_partial_flag(indx) := p_qte_shipment_tbl(ddindx).ship_partial_flag;
       x_ship_set_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).ship_set_id);
       x_ship_method_code(indx) := p_qte_shipment_tbl(ddindx).ship_method_code;
       x_freight_terms_code(indx) := p_qte_shipment_tbl(ddindx).freight_terms_code;
       x_freight_carrier_code(indx) := p_qte_shipment_tbl(ddindx).freight_carrier_code;
       x_fob_code(indx) := p_qte_shipment_tbl(ddindx).fob_code;
       x_shipping_instructions(indx) := p_qte_shipment_tbl(ddindx).shipping_instructions;
       x_packing_instructions(indx) := p_qte_shipment_tbl(ddindx).packing_instructions;
       x_ship_quote_price(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).ship_quote_price);
       x_quantity(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).quantity);
       x_pricing_quantity(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).pricing_quantity);
       x_reserved_quantity(indx) := p_qte_shipment_tbl(ddindx).reserved_quantity;
       x_reservation_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).reservation_id);
       x_order_line_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).order_line_id);
       x_ship_to_party_name(indx) := p_qte_shipment_tbl(ddindx).ship_to_party_name;
       x_ship_to_cont_first_name(indx) := p_qte_shipment_tbl(ddindx).ship_to_contact_first_name;
       x_ship_to_cont_mid_name(indx) := p_qte_shipment_tbl(ddindx).ship_to_contact_middle_name;
       x_ship_to_cont_last_name(indx) := p_qte_shipment_tbl(ddindx).ship_to_contact_last_name;
       x_ship_to_address1(indx) := p_qte_shipment_tbl(ddindx).ship_to_address1;
       x_ship_to_address2(indx) := p_qte_shipment_tbl(ddindx).ship_to_address2;
       x_ship_to_address3(indx) := p_qte_shipment_tbl(ddindx).ship_to_address3;
       x_ship_to_address4(indx) := p_qte_shipment_tbl(ddindx).ship_to_address4;
       x_ship_to_country_code(indx) := p_qte_shipment_tbl(ddindx).ship_to_country_code;
       x_ship_to_country(indx) := p_qte_shipment_tbl(ddindx).ship_to_country;
       x_ship_to_city(indx) := p_qte_shipment_tbl(ddindx).ship_to_city;
       x_ship_to_postal_code(indx) := p_qte_shipment_tbl(ddindx).ship_to_postal_code;
       x_ship_to_state(indx) := p_qte_shipment_tbl(ddindx).ship_to_state;
       x_ship_to_province(indx) := p_qte_shipment_tbl(ddindx).ship_to_province;
       x_ship_to_county(indx) := p_qte_shipment_tbl(ddindx).ship_to_county;
       x_attribute_category(indx) := p_qte_shipment_tbl(ddindx).attribute_category;
       x_attribute1(indx) := p_qte_shipment_tbl(ddindx).attribute1;
       x_attribute2(indx) := p_qte_shipment_tbl(ddindx).attribute2;
       x_attribute3(indx) := p_qte_shipment_tbl(ddindx).attribute3;
       x_attribute4(indx) := p_qte_shipment_tbl(ddindx).attribute4;
       x_attribute5(indx) := p_qte_shipment_tbl(ddindx).attribute5;
       x_attribute6(indx) := p_qte_shipment_tbl(ddindx).attribute6;
       x_attribute7(indx) := p_qte_shipment_tbl(ddindx).attribute7;
       x_attribute8(indx) := p_qte_shipment_tbl(ddindx).attribute8;
       x_attribute9(indx) := p_qte_shipment_tbl(ddindx).attribute9;
       x_attribute10(indx) := p_qte_shipment_tbl(ddindx).attribute10;
       x_attribute11(indx) := p_qte_shipment_tbl(ddindx).attribute11;
       x_attribute12(indx) := p_qte_shipment_tbl(ddindx).attribute12;
       x_attribute13(indx) := p_qte_shipment_tbl(ddindx).attribute13;
       x_attribute14(indx) := p_qte_shipment_tbl(ddindx).attribute14;
       x_attribute15(indx) := p_qte_shipment_tbl(ddindx).attribute15;
       x_shipment_priority_code(indx) := p_qte_shipment_tbl(ddindx).shipment_priority_code;
       x_ship_from_org_id(indx) := rosetta_g_miss_num_map(p_qte_shipment_tbl(ddindx).ship_from_org_id);
       --*/

       indx := indx+1;
       IF p_qte_shipment_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_shipment_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Shipment_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso tax detail table
PROCEDURE Set_Tax_Detail_Tbl_Out(
   p_qte_tax_detail_tbl        IN  ASO_Quote_Pub.Tax_Detail_Tbl_Type,
   x_tax_detail_id             OUT NOCOPY  jtf_number_table

   /*-- The following output parameters are ignored
   x_operation_code            OUT NOCOPY  jtf_varchar2_table_100,
   x_qte_line_index            OUT NOCOPY  jtf_number_table,
   x_shipment_index            OUT NOCOPY  jtf_number_table,
   x_quote_header_id           OUT NOCOPY  jtf_number_table,
   x_quote_line_id             OUT NOCOPY  jtf_number_table,
   x_quote_shipment_id         OUT NOCOPY  jtf_number_table,
   x_creation_date             OUT NOCOPY  jtf_date_table,
   x_created_by                OUT NOCOPY  jtf_number_table,
   x_last_update_date          OUT NOCOPY  jtf_date_table,
   x_last_updated_by           OUT NOCOPY  jtf_number_table,
   x_last_update_login         OUT NOCOPY  jtf_number_table,
   x_request_id                OUT NOCOPY  jtf_number_table,
   x_program_application_id    OUT NOCOPY  jtf_number_table,
   x_program_id                OUT NOCOPY  jtf_number_table,
   x_program_update_date       OUT NOCOPY  jtf_date_table,
   x_orig_tax_code             OUT NOCOPY  jtf_varchar2_table_300,
   x_tax_code                  OUT NOCOPY  jtf_varchar2_table_100,
   x_tax_rate                  OUT NOCOPY  jtf_number_table,
   x_tax_date                  OUT NOCOPY  jtf_date_table,
   x_tax_amount                OUT NOCOPY  jtf_number_table,
   x_tax_exempt_flag           OUT NOCOPY  jtf_varchar2_table_100,
   x_tax_exempt_number         OUT NOCOPY  jtf_varchar2_table_100,
   x_tax_exempt_reason_code    OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute_category        OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute1                OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute2                OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute3                OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute4                OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute5                OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute6                OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute7                OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute8                OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute9                OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute10               OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute11               OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute12               OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute13               OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute14               OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute15               OUT NOCOPY  jtf_varchar2_table_200
   --*/
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_tax_detail_id := jtf_number_table();

   /*-- The following output parameters are ignored
   x_operation_code := jtf_varchar2_table_100();
   x_qte_line_index := jtf_number_table();
   x_shipment_index := jtf_number_table();
   x_quote_header_id := jtf_number_table();
   x_quote_line_id := jtf_number_table();
   x_quote_shipment_id := jtf_number_table();
   x_creation_date := jtf_date_table();
   x_created_by := jtf_number_table();
   x_last_update_date := jtf_date_table();
   x_last_updated_by := jtf_number_table();
   x_last_update_login := jtf_number_table();
   x_request_id := jtf_number_table();
   x_program_application_id := jtf_number_table();
   x_program_id := jtf_number_table();
   x_program_update_date := jtf_date_table();
   x_orig_tax_code := jtf_varchar2_table_300();
   x_tax_code := jtf_varchar2_table_100();
   x_tax_rate := jtf_number_table();
   x_tax_date := jtf_date_table();
   x_tax_amount := jtf_number_table();
   x_tax_exempt_flag := jtf_varchar2_table_100();
   x_tax_exempt_number := jtf_varchar2_table_100();
   x_tax_exempt_reason_code := jtf_varchar2_table_100();
   x_attribute_category := jtf_varchar2_table_100();
   x_attribute1 := jtf_varchar2_table_200();
   x_attribute2 := jtf_varchar2_table_200();
   x_attribute3 := jtf_varchar2_table_200();
   x_attribute4 := jtf_varchar2_table_200();
   x_attribute5 := jtf_varchar2_table_200();
   x_attribute6 := jtf_varchar2_table_200();
   x_attribute7 := jtf_varchar2_table_200();
   x_attribute8 := jtf_varchar2_table_200();
   x_attribute9 := jtf_varchar2_table_200();
   x_attribute10 := jtf_varchar2_table_200();
   x_attribute11 := jtf_varchar2_table_200();
   x_attribute12 := jtf_varchar2_table_200();
   x_attribute13 := jtf_varchar2_table_200();
   x_attribute14 := jtf_varchar2_table_200();
   x_attribute15 := jtf_varchar2_table_200();
   --*/

   IF p_qte_tax_detail_tbl.count > 0 THEN
     x_tax_detail_id.extend(p_qte_tax_detail_tbl.count);

     /*-- The following output parameters are ignored
     x_operation_code.extend(p_qte_tax_detail_tbl.count);
     x_qte_line_index.extend(p_qte_tax_detail_tbl.count);
     x_shipment_index.extend(p_qte_tax_detail_tbl.count);
     x_quote_header_id.extend(p_qte_tax_detail_tbl.count);
     x_quote_line_id.extend(p_qte_tax_detail_tbl.count);
     x_quote_shipment_id.extend(p_qte_tax_detail_tbl.count);
     x_creation_date.extend(p_qte_tax_detail_tbl.count);
     x_created_by.extend(p_qte_tax_detail_tbl.count);
     x_last_update_date.extend(p_qte_tax_detail_tbl.count);
     x_last_updated_by.extend(p_qte_tax_detail_tbl.count);
     x_last_update_login.extend(p_qte_tax_detail_tbl.count);
     x_request_id.extend(p_qte_tax_detail_tbl.count);
     x_program_application_id.extend(p_qte_tax_detail_tbl.count);
     x_program_id.extend(p_qte_tax_detail_tbl.count);
     x_program_update_date.extend(p_qte_tax_detail_tbl.count);
     x_orig_tax_code.extend(p_qte_tax_detail_tbl.count);
     x_tax_code.extend(p_qte_tax_detail_tbl.count);
     x_tax_rate.extend(p_qte_tax_detail_tbl.count);
     x_tax_date.extend(p_qte_tax_detail_tbl.count);
     x_tax_amount.extend(p_qte_tax_detail_tbl.count);
     x_tax_exempt_flag.extend(p_qte_tax_detail_tbl.count);
     x_tax_exempt_number.extend(p_qte_tax_detail_tbl.count);
     x_tax_exempt_reason_code.extend(p_qte_tax_detail_tbl.count);
     x_attribute_category.extend(p_qte_tax_detail_tbl.count);
     x_attribute1.extend(p_qte_tax_detail_tbl.count);
     x_attribute2.extend(p_qte_tax_detail_tbl.count);
     x_attribute3.extend(p_qte_tax_detail_tbl.count);
     x_attribute4.extend(p_qte_tax_detail_tbl.count);
     x_attribute5.extend(p_qte_tax_detail_tbl.count);
     x_attribute6.extend(p_qte_tax_detail_tbl.count);
     x_attribute7.extend(p_qte_tax_detail_tbl.count);
     x_attribute8.extend(p_qte_tax_detail_tbl.count);
     x_attribute9.extend(p_qte_tax_detail_tbl.count);
     x_attribute10.extend(p_qte_tax_detail_tbl.count);
     x_attribute11.extend(p_qte_tax_detail_tbl.count);
     x_attribute12.extend(p_qte_tax_detail_tbl.count);
     x_attribute13.extend(p_qte_tax_detail_tbl.count);
     x_attribute14.extend(p_qte_tax_detail_tbl.count);
     x_attribute15.extend(p_qte_tax_detail_tbl.count);
     --*/

     ddindx := p_qte_tax_detail_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_tax_detail_id(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).tax_detail_id);

       /*-- The following output parameters are ignored
       x_operation_code(indx) := p_qte_tax_detail_tbl(ddindx).operation_code;
       x_qte_line_index(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).qte_line_index);
       x_shipment_index(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).shipment_index);
       x_quote_header_id(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).quote_header_id);
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).quote_line_id);
       x_quote_shipment_id(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).quote_shipment_id);
       x_creation_date(indx) := p_qte_tax_detail_tbl(ddindx).creation_date;
       x_created_by(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).created_by);
       x_last_update_date(indx) := p_qte_tax_detail_tbl(ddindx).last_update_date;
       x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).last_updated_by);
       x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).last_update_login);
       x_request_id(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).request_id);
       x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).program_application_id);
       x_program_id(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).program_id);
       x_program_update_date(indx) := p_qte_tax_detail_tbl(ddindx).program_update_date;
       x_orig_tax_code(indx) := p_qte_tax_detail_tbl(ddindx).orig_tax_code;
       x_tax_code(indx) := p_qte_tax_detail_tbl(ddindx).tax_code;
       x_tax_rate(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).tax_rate);
       x_tax_date(indx) := p_qte_tax_detail_tbl(ddindx).tax_date;
       x_tax_amount(indx) := rosetta_g_miss_num_map(p_qte_tax_detail_tbl(ddindx).tax_amount);
       x_tax_exempt_flag(indx) := p_qte_tax_detail_tbl(ddindx).tax_exempt_flag;
       x_tax_exempt_number(indx) := p_qte_tax_detail_tbl(ddindx).tax_exempt_number;
       x_tax_exempt_reason_code(indx) := p_qte_tax_detail_tbl(ddindx).tax_exempt_reason_code;
       x_attribute_category(indx) := p_qte_tax_detail_tbl(ddindx).attribute_category;
       x_attribute1(indx) := p_qte_tax_detail_tbl(ddindx).attribute1;
       x_attribute2(indx) := p_qte_tax_detail_tbl(ddindx).attribute2;
       x_attribute3(indx) := p_qte_tax_detail_tbl(ddindx).attribute3;
       x_attribute4(indx) := p_qte_tax_detail_tbl(ddindx).attribute4;
       x_attribute5(indx) := p_qte_tax_detail_tbl(ddindx).attribute5;
       x_attribute6(indx) := p_qte_tax_detail_tbl(ddindx).attribute6;
       x_attribute7(indx) := p_qte_tax_detail_tbl(ddindx).attribute7;
       x_attribute8(indx) := p_qte_tax_detail_tbl(ddindx).attribute8;
       x_attribute9(indx) := p_qte_tax_detail_tbl(ddindx).attribute9;
       x_attribute10(indx) := p_qte_tax_detail_tbl(ddindx).attribute10;
       x_attribute11(indx) := p_qte_tax_detail_tbl(ddindx).attribute11;
       x_attribute12(indx) := p_qte_tax_detail_tbl(ddindx).attribute12;
       x_attribute13(indx) := p_qte_tax_detail_tbl(ddindx).attribute13;
       x_attribute14(indx) := p_qte_tax_detail_tbl(ddindx).attribute14;
       x_attribute15(indx) := p_qte_tax_detail_tbl(ddindx).attribute15;
       --*/

       indx := indx+1;
       IF p_qte_tax_detail_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_tax_detail_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Tax_Detail_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso price adjustment table
PROCEDURE Set_Price_Adj_Tbl_Out(
   p_qte_price_adj_tbl            IN  ASO_Quote_Pub.Price_Adj_Tbl_Type,
   x_price_adjustment_id          OUT NOCOPY  jtf_number_table

   /*-- The following output parameters are ignored
   x_operation_code               OUT NOCOPY  jtf_varchar2_table_100,
   x_qte_line_index               OUT NOCOPY  jtf_number_table,
   x_shipment_index               OUT NOCOPY  jtf_number_table,
   x_creation_date                OUT NOCOPY  jtf_date_table,
   x_created_by                   OUT NOCOPY  jtf_number_table,
   x_last_update_date             OUT NOCOPY  jtf_date_table,
   x_last_updated_by              OUT NOCOPY  jtf_number_table,
   x_last_update_login            OUT NOCOPY  jtf_number_table,
   x_program_application_id       OUT NOCOPY  jtf_number_table,
   x_program_id                   OUT NOCOPY  jtf_number_table,
   x_program_update_date          OUT NOCOPY  jtf_date_table,
   x_request_id                   OUT NOCOPY  jtf_number_table,
   x_quote_header_id              OUT NOCOPY  jtf_number_table,
   x_quote_line_id                OUT NOCOPY  jtf_number_table,
   x_quote_shipment_id            OUT NOCOPY  jtf_number_table,
   x_modifier_header_id           OUT NOCOPY  jtf_number_table,
   x_modifier_line_id             OUT NOCOPY  jtf_number_table,
   x_modifier_line_type_code      OUT NOCOPY  jtf_varchar2_table_100,
   x_modifier_mechanism_type_code OUT NOCOPY  jtf_varchar2_table_100,
   x_modified_from                OUT NOCOPY  jtf_number_table,
   x_modified_to                  OUT NOCOPY  jtf_number_table,
   x_operand                      OUT NOCOPY  jtf_number_table,
   x_arithmetic_operator          OUT NOCOPY  jtf_varchar2_table_100,
   x_automatic_flag               OUT NOCOPY  jtf_varchar2_table_100,
   x_update_allowable_flag        OUT NOCOPY  jtf_varchar2_table_100,
   x_updated_flag                 OUT NOCOPY  jtf_varchar2_table_100,
   x_applied_flag                 OUT NOCOPY  jtf_varchar2_table_100,
   x_on_invoice_flag              OUT NOCOPY  jtf_varchar2_table_100,
   x_pricing_phase_id             OUT NOCOPY  jtf_number_table,
   x_attribute_category           OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute1                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute2                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute3                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute4                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute5                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute6                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute7                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute8                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute9                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute10                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute11                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute12                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute13                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute14                  OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute15                  OUT NOCOPY  jtf_varchar2_table_200,
   x_orig_sys_discount_ref        OUT NOCOPY  jtf_varchar2_table_100,
   x_change_sequence              OUT NOCOPY  jtf_varchar2_table_100,
   x_update_allowed               OUT NOCOPY  jtf_varchar2_table_100,
   x_change_reason_code           OUT NOCOPY  jtf_varchar2_table_100,
   x_change_reason_text           OUT NOCOPY  jtf_varchar2_table_2000,
   x_cost_id                      OUT NOCOPY  jtf_number_table,
   x_tax_code                     OUT NOCOPY  jtf_varchar2_table_100,
   x_tax_exempt_flag              OUT NOCOPY  jtf_varchar2_table_100,
   x_tax_exempt_number            OUT NOCOPY  jtf_varchar2_table_100,
   x_tax_exempt_reason_code       OUT NOCOPY  jtf_varchar2_table_100,
   x_parent_adjustment_id         OUT NOCOPY  jtf_number_table,
   x_invoiced_flag                OUT NOCOPY  jtf_varchar2_table_100,
   x_estimated_flag               OUT NOCOPY  jtf_varchar2_table_100,
   x_inc_in_sales_performance     OUT NOCOPY  jtf_varchar2_table_100,
   x_split_action_code            OUT NOCOPY  jtf_varchar2_table_100,
   x_adjusted_amount              OUT NOCOPY  jtf_number_table,
   x_charge_type_code             OUT NOCOPY  jtf_varchar2_table_100,
   x_charge_subtype_code          OUT NOCOPY  jtf_varchar2_table_100,
   x_range_break_quantity         OUT NOCOPY  jtf_number_table,
   x_accrual_conversion_rate      OUT NOCOPY  jtf_number_table,
   x_pricing_group_sequence       OUT NOCOPY  jtf_number_table,
   x_accrual_flag                 OUT NOCOPY  jtf_varchar2_table_100,
   x_list_line_no                 OUT NOCOPY  jtf_varchar2_table_300,
   x_source_system_code           OUT NOCOPY  jtf_varchar2_table_100,
   x_benefit_qty                  OUT NOCOPY  jtf_number_table,
   x_benefit_uom_code             OUT NOCOPY  jtf_varchar2_table_100,
   x_print_on_invoice_flag        OUT NOCOPY  jtf_varchar2_table_100,
   x_expiration_date              OUT NOCOPY  jtf_date_table,
   x_rebate_transaction_type_code OUT NOCOPY  jtf_varchar2_table_100,
   x_rebate_transaction_reference OUT NOCOPY  jtf_varchar2_table_100,
   x_rebate_payment_system_code   OUT NOCOPY  jtf_varchar2_table_100,
   x_redeemed_date                OUT NOCOPY  jtf_date_table,
   x_redeemed_flag                OUT NOCOPY  jtf_varchar2_table_100,
   x_modifier_level_code          OUT NOCOPY  jtf_varchar2_table_100,
   x_price_break_type_code        OUT NOCOPY  jtf_varchar2_table_100,
   x_substitution_attribute       OUT NOCOPY  jtf_varchar2_table_100,
   x_proration_type_code          OUT NOCOPY  jtf_varchar2_table_100,
   x_include_on_returns_flag      OUT NOCOPY  jtf_varchar2_table_100,
   x_credit_or_charge_flag        OUT NOCOPY  jtf_varchar2_table_100
   --*/
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_price_adjustment_id := jtf_number_table();

   /*-- The following output parameters are ignored
   x_operation_code := jtf_varchar2_table_100();
   x_qte_line_index := jtf_number_table();
   x_shipment_index := jtf_number_table();
   x_creation_date := jtf_date_table();
   x_created_by := jtf_number_table();
   x_last_update_date := jtf_date_table();
   x_last_updated_by := jtf_number_table();
   x_last_update_login := jtf_number_table();
   x_program_application_id := jtf_number_table();
   x_program_id := jtf_number_table();
   x_program_update_date := jtf_date_table();
   x_request_id := jtf_number_table();
   x_quote_header_id := jtf_number_table();
   x_quote_line_id := jtf_number_table();
   x_quote_shipment_id := jtf_number_table();
   x_modifier_header_id := jtf_number_table();
   x_modifier_line_id := jtf_number_table();
   x_modifier_line_type_code := jtf_varchar2_table_100();
   x_modifier_mechanism_type_code := jtf_varchar2_table_100();
   x_modified_from := jtf_number_table();
   x_modified_to := jtf_number_table();
   x_operand := jtf_number_table();
   x_arithmetic_operator := jtf_varchar2_table_100();
   x_automatic_flag := jtf_varchar2_table_100();
   x_update_allowable_flag := jtf_varchar2_table_100();
   x_updated_flag := jtf_varchar2_table_100();
   x_applied_flag := jtf_varchar2_table_100();
   x_on_invoice_flag := jtf_varchar2_table_100();
   x_pricing_phase_id := jtf_number_table();
   x_attribute_category := jtf_varchar2_table_100();
   x_attribute1 := jtf_varchar2_table_200();
   x_attribute2 := jtf_varchar2_table_200();
   x_attribute3 := jtf_varchar2_table_200();
   x_attribute4 := jtf_varchar2_table_200();
   x_attribute5 := jtf_varchar2_table_200();
   x_attribute6 := jtf_varchar2_table_200();
   x_attribute7 := jtf_varchar2_table_200();
   x_attribute8 := jtf_varchar2_table_200();
   x_attribute9 := jtf_varchar2_table_200();
   x_attribute10 := jtf_varchar2_table_200();
   x_attribute11 := jtf_varchar2_table_200();
   x_attribute12 := jtf_varchar2_table_200();
   x_attribute13 := jtf_varchar2_table_200();
   x_attribute14 := jtf_varchar2_table_200();
   x_attribute15 := jtf_varchar2_table_200();
   x_orig_sys_discount_ref := jtf_varchar2_table_100();
   x_change_sequence := jtf_varchar2_table_100();
   x_update_allowed := jtf_varchar2_table_100();
   x_change_reason_code := jtf_varchar2_table_100();
   x_change_reason_text := jtf_varchar2_table_2000();
   x_cost_id := jtf_number_table();
   x_tax_code := jtf_varchar2_table_100();
   x_tax_exempt_flag := jtf_varchar2_table_100();
   x_tax_exempt_number := jtf_varchar2_table_100();
   x_tax_exempt_reason_code := jtf_varchar2_table_100();
   x_parent_adjustment_id := jtf_number_table();
   x_invoiced_flag := jtf_varchar2_table_100();
   x_estimated_flag := jtf_varchar2_table_100();
   x_inc_in_sales_performance := jtf_varchar2_table_100();
   x_split_action_code := jtf_varchar2_table_100();
   x_adjusted_amount := jtf_number_table();
   x_charge_type_code := jtf_varchar2_table_100();
   x_charge_subtype_code := jtf_varchar2_table_100();
   x_range_break_quantity := jtf_number_table();
   x_accrual_conversion_rate := jtf_number_table();
   x_pricing_group_sequence := jtf_number_table();
   x_accrual_flag := jtf_varchar2_table_100();
   x_list_line_no := jtf_varchar2_table_300();
   x_source_system_code := jtf_varchar2_table_100();
   x_benefit_qty := jtf_number_table();
   x_benefit_uom_code := jtf_varchar2_table_100();
   x_print_on_invoice_flag := jtf_varchar2_table_100();
   x_expiration_date := jtf_date_table();
   x_rebate_transaction_type_code := jtf_varchar2_table_100();
   x_rebate_transaction_reference := jtf_varchar2_table_100();
   x_rebate_payment_system_code := jtf_varchar2_table_100();
   x_redeemed_date := jtf_date_table();
   x_redeemed_flag := jtf_varchar2_table_100();
   x_modifier_level_code := jtf_varchar2_table_100();
   x_price_break_type_code := jtf_varchar2_table_100();
   x_substitution_attribute := jtf_varchar2_table_100();
   x_proration_type_code := jtf_varchar2_table_100();
   x_include_on_returns_flag := jtf_varchar2_table_100();
   x_credit_or_charge_flag := jtf_varchar2_table_100();
   --*/

   IF p_qte_price_adj_tbl.count > 0 THEN
     x_price_adjustment_id.extend(p_qte_price_adj_tbl.count);

     /*-- The following output parameters are ignored
     x_operation_code.extend(p_qte_price_adj_tbl.count);
     x_qte_line_index.extend(p_qte_price_adj_tbl.count);
     x_shipment_index.extend(p_qte_price_adj_tbl.count);
     x_creation_date.extend(p_qte_price_adj_tbl.count);
     x_created_by.extend(p_qte_price_adj_tbl.count);
     x_last_update_date.extend(p_qte_price_adj_tbl.count);
     x_last_updated_by.extend(p_qte_price_adj_tbl.count);
     x_last_update_login.extend(p_qte_price_adj_tbl.count);
     x_program_application_id.extend(p_qte_price_adj_tbl.count);
     x_program_id.extend(p_qte_price_adj_tbl.count);
     x_program_update_date.extend(p_qte_price_adj_tbl.count);
     x_request_id.extend(p_qte_price_adj_tbl.count);
     x_quote_header_id.extend(p_qte_price_adj_tbl.count);
     x_quote_line_id.extend(p_qte_price_adj_tbl.count);
     x_quote_shipment_id.extend(p_qte_price_adj_tbl.count);
     x_modifier_header_id.extend(p_qte_price_adj_tbl.count);
     x_modifier_line_id.extend(p_qte_price_adj_tbl.count);
     x_modifier_line_type_code.extend(p_qte_price_adj_tbl.count);
     x_modifier_mechanism_type_code.extend(p_qte_price_adj_tbl.count);
     x_modified_from.extend(p_qte_price_adj_tbl.count);
     x_modified_to.extend(p_qte_price_adj_tbl.count);
     x_operand.extend(p_qte_price_adj_tbl.count);
     x_arithmetic_operator.extend(p_qte_price_adj_tbl.count);
     x_automatic_flag.extend(p_qte_price_adj_tbl.count);
     x_update_allowable_flag.extend(p_qte_price_adj_tbl.count);
     x_updated_flag.extend(p_qte_price_adj_tbl.count);
     x_applied_flag.extend(p_qte_price_adj_tbl.count);
     x_on_invoice_flag.extend(p_qte_price_adj_tbl.count);
     x_pricing_phase_id.extend(p_qte_price_adj_tbl.count);
     x_attribute_category.extend(p_qte_price_adj_tbl.count);
     x_attribute1.extend(p_qte_price_adj_tbl.count);
     x_attribute2.extend(p_qte_price_adj_tbl.count);
     x_attribute3.extend(p_qte_price_adj_tbl.count);
     x_attribute4.extend(p_qte_price_adj_tbl.count);
     x_attribute5.extend(p_qte_price_adj_tbl.count);
     x_attribute6.extend(p_qte_price_adj_tbl.count);
     x_attribute7.extend(p_qte_price_adj_tbl.count);
     x_attribute8.extend(p_qte_price_adj_tbl.count);
     x_attribute9.extend(p_qte_price_adj_tbl.count);
     x_attribute10.extend(p_qte_price_adj_tbl.count);
     x_attribute11.extend(p_qte_price_adj_tbl.count);
     x_attribute12.extend(p_qte_price_adj_tbl.count);
     x_attribute13.extend(p_qte_price_adj_tbl.count);
     x_attribute14.extend(p_qte_price_adj_tbl.count);
     x_attribute15.extend(p_qte_price_adj_tbl.count);
     x_orig_sys_discount_ref.extend(p_qte_price_adj_tbl.count);
     x_change_sequence.extend(p_qte_price_adj_tbl.count);
     x_update_allowed.extend(p_qte_price_adj_tbl.count);
     x_change_reason_code.extend(p_qte_price_adj_tbl.count);
     x_change_reason_text.extend(p_qte_price_adj_tbl.count);
     x_cost_id.extend(p_qte_price_adj_tbl.count);
     x_tax_code.extend(p_qte_price_adj_tbl.count);
     x_tax_exempt_flag.extend(p_qte_price_adj_tbl.count);
     x_tax_exempt_number.extend(p_qte_price_adj_tbl.count);
     x_tax_exempt_reason_code.extend(p_qte_price_adj_tbl.count);
     x_parent_adjustment_id.extend(p_qte_price_adj_tbl.count);
     x_invoiced_flag.extend(p_qte_price_adj_tbl.count);
     x_estimated_flag.extend(p_qte_price_adj_tbl.count);
     x_inc_in_sales_performance.extend(p_qte_price_adj_tbl.count);
     x_split_action_code.extend(p_qte_price_adj_tbl.count);
     x_adjusted_amount.extend(p_qte_price_adj_tbl.count);
     x_charge_type_code.extend(p_qte_price_adj_tbl.count);
     x_charge_subtype_code.extend(p_qte_price_adj_tbl.count);
     x_range_break_quantity.extend(p_qte_price_adj_tbl.count);
     x_accrual_conversion_rate.extend(p_qte_price_adj_tbl.count);
     x_pricing_group_sequence.extend(p_qte_price_adj_tbl.count);
     x_accrual_flag.extend(p_qte_price_adj_tbl.count);
     x_list_line_no.extend(p_qte_price_adj_tbl.count);
     x_source_system_code.extend(p_qte_price_adj_tbl.count);
     x_benefit_qty.extend(p_qte_price_adj_tbl.count);
     x_benefit_uom_code.extend(p_qte_price_adj_tbl.count);
     x_print_on_invoice_flag.extend(p_qte_price_adj_tbl.count);
     x_expiration_date.extend(p_qte_price_adj_tbl.count);
     x_rebate_transaction_type_code.extend(p_qte_price_adj_tbl.count);
     x_rebate_transaction_reference.extend(p_qte_price_adj_tbl.count);
     x_rebate_payment_system_code.extend(p_qte_price_adj_tbl.count);
     x_redeemed_date.extend(p_qte_price_adj_tbl.count);
     x_redeemed_flag.extend(p_qte_price_adj_tbl.count);
     x_modifier_level_code.extend(p_qte_price_adj_tbl.count);
     x_price_break_type_code.extend(p_qte_price_adj_tbl.count);
     x_substitution_attribute.extend(p_qte_price_adj_tbl.count);
     x_proration_type_code.extend(p_qte_price_adj_tbl.count);
     x_include_on_returns_flag.extend(p_qte_price_adj_tbl.count);
     x_credit_or_charge_flag.extend(p_qte_price_adj_tbl.count);
     --*/

     ddindx := p_qte_price_adj_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_price_adjustment_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).price_adjustment_id);

       /*-- The following output parameters are ignored
       x_operation_code(indx) := p_qte_price_adj_tbl(ddindx).operation_code;
       x_qte_line_index(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).qte_line_index);
       x_shipment_index(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).shipment_index);
       x_creation_date(indx) := p_qte_price_adj_tbl(ddindx).creation_date;
       x_created_by(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).created_by);
       x_last_update_date(indx) := p_qte_price_adj_tbl(ddindx).last_update_date;
       x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).last_updated_by);
       x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).last_update_login);
       x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).program_application_id);
       x_program_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).program_id);
       x_program_update_date(indx) := p_qte_price_adj_tbl(ddindx).program_update_date;
       x_request_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).request_id);
       x_quote_header_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).quote_header_id);
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).quote_line_id);
       x_quote_shipment_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).quote_shipment_id);
       x_modifier_header_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).modifier_header_id);
       x_modifier_line_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).modifier_line_id);
       x_modifier_line_type_code(indx) := p_qte_price_adj_tbl(ddindx).modifier_line_type_code;
       x_modifier_mechanism_type_code(indx) := p_qte_price_adj_tbl(ddindx).modifier_mechanism_type_code;
       x_modified_from(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).modified_from);
       x_modified_to(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).modified_to);
       x_operand(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).operand);
       x_arithmetic_operator(indx) := p_qte_price_adj_tbl(ddindx).arithmetic_operator;
       x_automatic_flag(indx) := p_qte_price_adj_tbl(ddindx).automatic_flag;
       x_update_allowable_flag(indx) := p_qte_price_adj_tbl(ddindx).update_allowable_flag;
       x_updated_flag(indx) := p_qte_price_adj_tbl(ddindx).updated_flag;
       x_applied_flag(indx) := p_qte_price_adj_tbl(ddindx).applied_flag;
       x_on_invoice_flag(indx) := p_qte_price_adj_tbl(ddindx).on_invoice_flag;
       x_pricing_phase_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).pricing_phase_id);
       x_attribute_category(indx) := p_qte_price_adj_tbl(ddindx).attribute_category;
       x_attribute1(indx) := p_qte_price_adj_tbl(ddindx).attribute1;
       x_attribute2(indx) := p_qte_price_adj_tbl(ddindx).attribute2;
       x_attribute3(indx) := p_qte_price_adj_tbl(ddindx).attribute3;
       x_attribute4(indx) := p_qte_price_adj_tbl(ddindx).attribute4;
       x_attribute5(indx) := p_qte_price_adj_tbl(ddindx).attribute5;
       x_attribute6(indx) := p_qte_price_adj_tbl(ddindx).attribute6;
       x_attribute7(indx) := p_qte_price_adj_tbl(ddindx).attribute7;
       x_attribute8(indx) := p_qte_price_adj_tbl(ddindx).attribute8;
       x_attribute9(indx) := p_qte_price_adj_tbl(ddindx).attribute9;
       x_attribute10(indx) := p_qte_price_adj_tbl(ddindx).attribute10;
       x_attribute11(indx) := p_qte_price_adj_tbl(ddindx).attribute11;
       x_attribute12(indx) := p_qte_price_adj_tbl(ddindx).attribute12;
       x_attribute13(indx) := p_qte_price_adj_tbl(ddindx).attribute13;
       x_attribute14(indx) := p_qte_price_adj_tbl(ddindx).attribute14;
       x_attribute15(indx) := p_qte_price_adj_tbl(ddindx).attribute15;
       x_orig_sys_discount_ref(indx) := p_qte_price_adj_tbl(ddindx).orig_sys_discount_ref;
       x_change_sequence(indx) := p_qte_price_adj_tbl(ddindx).change_sequence;
       x_update_allowed(indx) := p_qte_price_adj_tbl(ddindx).update_allowed;
       x_change_reason_code(indx) := p_qte_price_adj_tbl(ddindx).change_reason_code;
       x_change_reason_text(indx) := p_qte_price_adj_tbl(ddindx).change_reason_text;
       x_cost_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).cost_id);
       x_tax_code(indx) := p_qte_price_adj_tbl(ddindx).tax_code;
       x_tax_exempt_flag(indx) := p_qte_price_adj_tbl(ddindx).tax_exempt_flag;
       x_tax_exempt_number(indx) := p_qte_price_adj_tbl(ddindx).tax_exempt_number;
       x_tax_exempt_reason_code(indx) := p_qte_price_adj_tbl(ddindx).tax_exempt_reason_code;
       x_parent_adjustment_id(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).parent_adjustment_id);
       x_invoiced_flag(indx) := p_qte_price_adj_tbl(ddindx).invoiced_flag;
       x_estimated_flag(indx) := p_qte_price_adj_tbl(ddindx).estimated_flag;
       x_inc_in_sales_performance(indx) := p_qte_price_adj_tbl(ddindx).inc_in_sales_performance;
       x_split_action_code(indx) := p_qte_price_adj_tbl(ddindx).split_action_code;
       x_adjusted_amount(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).adjusted_amount);
       x_charge_type_code(indx) := p_qte_price_adj_tbl(ddindx).charge_type_code;
       x_charge_subtype_code(indx) := p_qte_price_adj_tbl(ddindx).charge_subtype_code;
       x_range_break_quantity(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).range_break_quantity);
       x_accrual_conversion_rate(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).accrual_conversion_rate);
       x_pricing_group_sequence(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).pricing_group_sequence);
       x_accrual_flag(indx) := p_qte_price_adj_tbl(ddindx).accrual_flag;
       x_list_line_no(indx) := p_qte_price_adj_tbl(ddindx).list_line_no;
       x_source_system_code(indx) := p_qte_price_adj_tbl(ddindx).source_system_code;
       x_benefit_qty(indx) := rosetta_g_miss_num_map(p_qte_price_adj_tbl(ddindx).benefit_qty);
       x_benefit_uom_code(indx) := p_qte_price_adj_tbl(ddindx).benefit_uom_code;
       x_print_on_invoice_flag(indx) := p_qte_price_adj_tbl(ddindx).print_on_invoice_flag;
       x_expiration_date(indx) := p_qte_price_adj_tbl(ddindx).expiration_date;
       x_rebate_transaction_type_code(indx) := p_qte_price_adj_tbl(ddindx).rebate_transaction_type_code;
       x_rebate_transaction_reference(indx) := p_qte_price_adj_tbl(ddindx).rebate_transaction_reference;
       x_rebate_payment_system_code(indx) := p_qte_price_adj_tbl(ddindx).rebate_payment_system_code;
       x_redeemed_date(indx) := p_qte_price_adj_tbl(ddindx).redeemed_date;
       x_redeemed_flag(indx) := p_qte_price_adj_tbl(ddindx).redeemed_flag;
       x_modifier_level_code(indx) := p_qte_price_adj_tbl(ddindx).modifier_level_code;
       x_price_break_type_code(indx) := p_qte_price_adj_tbl(ddindx).price_break_type_code;
       x_substitution_attribute(indx) := p_qte_price_adj_tbl(ddindx).substitution_attribute;
       x_proration_type_code(indx) := p_qte_price_adj_tbl(ddindx).proration_type_code;
       x_include_on_returns_flag(indx) := p_qte_price_adj_tbl(ddindx).include_on_returns_flag;
       x_credit_or_charge_flag(indx) := p_qte_price_adj_tbl(ddindx).credit_or_charge_flag;
       --*/

       indx := indx+1;
       IF p_qte_price_adj_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_price_adj_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Price_Adj_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso price attributes table
PROCEDURE Set_Price_Attributes_Tbl_Out(
   p_qte_price_attributes_tbl      IN  ASO_Quote_Pub.Price_Attributes_Tbl_Type,
   x_price_attribute_id            OUT NOCOPY  jtf_number_table

   /*-- The following output parameters are ignored
   x_operation_code                OUT NOCOPY  jtf_varchar2_table_100,
   x_qte_line_index                OUT NOCOPY  jtf_number_table,
   x_creation_date                 OUT NOCOPY  jtf_date_table,
   x_created_by                    OUT NOCOPY  jtf_number_table,
   x_last_update_date              OUT NOCOPY  jtf_date_table,
   x_last_updated_by               OUT NOCOPY  jtf_number_table,
   x_last_update_login             OUT NOCOPY  jtf_number_table,
   x_request_id                    OUT NOCOPY  jtf_number_table,
   x_program_application_id        OUT NOCOPY  jtf_number_table,
   x_program_id                    OUT NOCOPY  jtf_number_table,
   x_program_update_date           OUT NOCOPY  jtf_date_table,
   x_quote_header_id               OUT NOCOPY  jtf_number_table,
   x_quote_line_id                 OUT NOCOPY  jtf_number_table,
   x_flex_title                    OUT NOCOPY  jtf_varchar2_table_100,
   x_pricing_context               OUT NOCOPY  jtf_varchar2_table_100,
   x_pricing_attribute1            OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute2            OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute3            OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute4            OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute5            OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute6            OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute7            OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute8            OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute9            OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute10           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute11           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute12           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute13           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute14           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute15           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute16           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute17           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute18           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute19           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute20           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute21           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute22           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute23           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute24           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute25           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute26           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute27           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute28           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute29           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute30           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute31           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute32           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute33           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute34           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute35           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute36           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute37           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute38           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute39           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute40           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute41           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute42           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute43           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute44           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute45           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute46           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute47           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute48           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute49           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute50           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute51           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute52           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute53           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute54           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute55           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute56           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute57           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute58           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute59           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute60           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute61           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute62           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute63           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute64           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute65           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute66           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute67           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute68           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute69           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute70           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute71           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute72           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute73           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute74           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute75           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute76           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute77           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute78           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute79           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute80           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute81           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute82           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute83           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute84           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute85           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute86           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute87           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute88           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute89           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute90           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute91           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute92           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute93           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute94           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute95           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute96           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute97           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute98           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute99           OUT NOCOPY  jtf_varchar2_table_200,
   x_pricing_attribute100          OUT NOCOPY  jtf_varchar2_table_200,
   x_context                       OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute1                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute2                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute3                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute4                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute5                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute6                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute7                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute8                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute9                    OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute10                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute11                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute12                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute13                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute14                   OUT NOCOPY  jtf_varchar2_table_200,
   x_attribute15                   OUT NOCOPY  jtf_varchar2_table_200
   --*/
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_price_attribute_id := jtf_number_table();

   /*-- The following output parameters are ignored
   x_operation_code := jtf_varchar2_table_100();
   x_qte_line_index := jtf_number_table();
   x_creation_date := jtf_date_table();
   x_created_by := jtf_number_table();
   x_last_update_date := jtf_date_table();
   x_last_updated_by := jtf_number_table();
   x_last_update_login := jtf_number_table();
   x_request_id := jtf_number_table();
   x_program_application_id := jtf_number_table();
   x_program_id := jtf_number_table();
   x_program_update_date := jtf_date_table();
   x_quote_header_id := jtf_number_table();
   x_quote_line_id := jtf_number_table();
   x_flex_title := jtf_varchar2_table_100();
   x_pricing_context := jtf_varchar2_table_100();
   x_pricing_attribute1 := jtf_varchar2_table_200();
   x_pricing_attribute2 := jtf_varchar2_table_200();
   x_pricing_attribute3 := jtf_varchar2_table_200();
   x_pricing_attribute4 := jtf_varchar2_table_200();
   x_pricing_attribute5 := jtf_varchar2_table_200();
   x_pricing_attribute6 := jtf_varchar2_table_200();
   x_pricing_attribute7 := jtf_varchar2_table_200();
   x_pricing_attribute8 := jtf_varchar2_table_200();
   x_pricing_attribute9 := jtf_varchar2_table_200();
   x_pricing_attribute10 := jtf_varchar2_table_200();
   x_pricing_attribute11 := jtf_varchar2_table_200();
   x_pricing_attribute12 := jtf_varchar2_table_200();
   x_pricing_attribute13 := jtf_varchar2_table_200();
   x_pricing_attribute14 := jtf_varchar2_table_200();
   x_pricing_attribute15 := jtf_varchar2_table_200();
   x_pricing_attribute16 := jtf_varchar2_table_200();
   x_pricing_attribute17 := jtf_varchar2_table_200();
   x_pricing_attribute18 := jtf_varchar2_table_200();
   x_pricing_attribute19 := jtf_varchar2_table_200();
   x_pricing_attribute20 := jtf_varchar2_table_200();
   x_pricing_attribute21 := jtf_varchar2_table_200();
   x_pricing_attribute22 := jtf_varchar2_table_200();
   x_pricing_attribute23 := jtf_varchar2_table_200();
   x_pricing_attribute24 := jtf_varchar2_table_200();
   x_pricing_attribute25 := jtf_varchar2_table_200();
   x_pricing_attribute26 := jtf_varchar2_table_200();
   x_pricing_attribute27 := jtf_varchar2_table_200();
   x_pricing_attribute28 := jtf_varchar2_table_200();
   x_pricing_attribute29 := jtf_varchar2_table_200();
   x_pricing_attribute30 := jtf_varchar2_table_200();
   x_pricing_attribute31 := jtf_varchar2_table_200();
   x_pricing_attribute32 := jtf_varchar2_table_200();
   x_pricing_attribute33 := jtf_varchar2_table_200();
   x_pricing_attribute34 := jtf_varchar2_table_200();
   x_pricing_attribute35 := jtf_varchar2_table_200();
   x_pricing_attribute36 := jtf_varchar2_table_200();
   x_pricing_attribute37 := jtf_varchar2_table_200();
   x_pricing_attribute38 := jtf_varchar2_table_200();
   x_pricing_attribute39 := jtf_varchar2_table_200();
   x_pricing_attribute40 := jtf_varchar2_table_200();
   x_pricing_attribute41 := jtf_varchar2_table_200();
   x_pricing_attribute42 := jtf_varchar2_table_200();
   x_pricing_attribute43 := jtf_varchar2_table_200();
   x_pricing_attribute44 := jtf_varchar2_table_200();
   x_pricing_attribute45 := jtf_varchar2_table_200();
   x_pricing_attribute46 := jtf_varchar2_table_200();
   x_pricing_attribute47 := jtf_varchar2_table_200();
   x_pricing_attribute48 := jtf_varchar2_table_200();
   x_pricing_attribute49 := jtf_varchar2_table_200();
   x_pricing_attribute50 := jtf_varchar2_table_200();
   x_pricing_attribute51 := jtf_varchar2_table_200();
   x_pricing_attribute52 := jtf_varchar2_table_200();
   x_pricing_attribute53 := jtf_varchar2_table_200();
   x_pricing_attribute54 := jtf_varchar2_table_200();
   x_pricing_attribute55 := jtf_varchar2_table_200();
   x_pricing_attribute56 := jtf_varchar2_table_200();
   x_pricing_attribute57 := jtf_varchar2_table_200();
   x_pricing_attribute58 := jtf_varchar2_table_200();
   x_pricing_attribute59 := jtf_varchar2_table_200();
   x_pricing_attribute60 := jtf_varchar2_table_200();
   x_pricing_attribute61 := jtf_varchar2_table_200();
   x_pricing_attribute62 := jtf_varchar2_table_200();
   x_pricing_attribute63 := jtf_varchar2_table_200();
   x_pricing_attribute64 := jtf_varchar2_table_200();
   x_pricing_attribute65 := jtf_varchar2_table_200();
   x_pricing_attribute66 := jtf_varchar2_table_200();
   x_pricing_attribute67 := jtf_varchar2_table_200();
   x_pricing_attribute68 := jtf_varchar2_table_200();
   x_pricing_attribute69 := jtf_varchar2_table_200();
   x_pricing_attribute70 := jtf_varchar2_table_200();
   x_pricing_attribute71 := jtf_varchar2_table_200();
   x_pricing_attribute72 := jtf_varchar2_table_200();
   x_pricing_attribute73 := jtf_varchar2_table_200();
   x_pricing_attribute74 := jtf_varchar2_table_200();
   x_pricing_attribute75 := jtf_varchar2_table_200();
   x_pricing_attribute76 := jtf_varchar2_table_200();
   x_pricing_attribute77 := jtf_varchar2_table_200();
   x_pricing_attribute78 := jtf_varchar2_table_200();
   x_pricing_attribute79 := jtf_varchar2_table_200();
   x_pricing_attribute80 := jtf_varchar2_table_200();
   x_pricing_attribute81 := jtf_varchar2_table_200();
   x_pricing_attribute82 := jtf_varchar2_table_200();
   x_pricing_attribute83 := jtf_varchar2_table_200();
   x_pricing_attribute84 := jtf_varchar2_table_200();
   x_pricing_attribute85 := jtf_varchar2_table_200();
   x_pricing_attribute86 := jtf_varchar2_table_200();
   x_pricing_attribute87 := jtf_varchar2_table_200();
   x_pricing_attribute88 := jtf_varchar2_table_200();
   x_pricing_attribute89 := jtf_varchar2_table_200();
   x_pricing_attribute90 := jtf_varchar2_table_200();
   x_pricing_attribute91 := jtf_varchar2_table_200();
   x_pricing_attribute92 := jtf_varchar2_table_200();
   x_pricing_attribute93 := jtf_varchar2_table_200();
   x_pricing_attribute94 := jtf_varchar2_table_200();
   x_pricing_attribute95 := jtf_varchar2_table_200();
   x_pricing_attribute96 := jtf_varchar2_table_200();
   x_pricing_attribute97 := jtf_varchar2_table_200();
   x_pricing_attribute98 := jtf_varchar2_table_200();
   x_pricing_attribute99 := jtf_varchar2_table_200();
   x_pricing_attribute100 := jtf_varchar2_table_200();
   x_context := jtf_varchar2_table_100();
   x_attribute1 := jtf_varchar2_table_200();
   x_attribute2 := jtf_varchar2_table_200();
   x_attribute3 := jtf_varchar2_table_200();
   x_attribute4 := jtf_varchar2_table_200();
   x_attribute5 := jtf_varchar2_table_200();
   x_attribute6 := jtf_varchar2_table_200();
   x_attribute7 := jtf_varchar2_table_200();
   x_attribute8 := jtf_varchar2_table_200();
   x_attribute9 := jtf_varchar2_table_200();
   x_attribute10 := jtf_varchar2_table_200();
   x_attribute11 := jtf_varchar2_table_200();
   x_attribute12 := jtf_varchar2_table_200();
   x_attribute13 := jtf_varchar2_table_200();
   x_attribute14 := jtf_varchar2_table_200();
   x_attribute15 := jtf_varchar2_table_200();
   --*/

   IF p_qte_price_attributes_tbl.count > 0 THEN
     x_price_attribute_id.extend(p_qte_price_attributes_tbl.count);

     /*-- The following output parameters are ignored
     x_operation_code.extend(p_qte_price_attributes_tbl.count);
     x_qte_line_index.extend(p_qte_price_attributes_tbl.count);
     x_creation_date.extend(p_qte_price_attributes_tbl.count);
     x_created_by.extend(p_qte_price_attributes_tbl.count);
     x_last_update_date.extend(p_qte_price_attributes_tbl.count);
     x_last_updated_by.extend(p_qte_price_attributes_tbl.count);
     x_last_update_login.extend(p_qte_price_attributes_tbl.count);
     x_request_id.extend(p_qte_price_attributes_tbl.count);
     x_program_application_id.extend(p_qte_price_attributes_tbl.count);
     x_program_id.extend(p_qte_price_attributes_tbl.count);
     x_program_update_date.extend(p_qte_price_attributes_tbl.count);
     x_quote_header_id.extend(p_qte_price_attributes_tbl.count);
     x_quote_line_id.extend(p_qte_price_attributes_tbl.count);
     x_flex_title.extend(p_qte_price_attributes_tbl.count);
     x_pricing_context.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute1.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute2.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute3.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute4.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute5.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute6.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute7.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute8.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute9.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute10.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute11.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute12.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute13.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute14.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute15.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute16.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute17.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute18.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute19.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute20.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute21.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute22.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute23.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute24.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute25.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute26.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute27.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute28.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute29.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute30.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute31.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute32.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute33.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute34.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute35.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute36.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute37.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute38.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute39.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute40.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute41.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute42.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute43.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute44.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute45.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute46.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute47.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute48.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute49.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute50.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute51.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute52.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute53.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute54.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute55.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute56.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute57.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute58.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute59.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute60.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute61.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute62.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute63.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute64.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute65.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute66.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute67.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute68.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute69.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute70.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute71.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute72.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute73.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute74.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute75.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute76.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute77.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute78.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute79.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute80.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute81.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute82.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute83.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute84.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute85.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute86.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute87.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute88.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute89.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute90.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute91.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute92.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute93.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute94.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute95.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute96.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute97.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute98.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute99.extend(p_qte_price_attributes_tbl.count);
     x_pricing_attribute100.extend(p_qte_price_attributes_tbl.count);
     x_context.extend(p_qte_price_attributes_tbl.count);
     x_attribute1.extend(p_qte_price_attributes_tbl.count);
     x_attribute2.extend(p_qte_price_attributes_tbl.count);
     x_attribute3.extend(p_qte_price_attributes_tbl.count);
     x_attribute4.extend(p_qte_price_attributes_tbl.count);
     x_attribute5.extend(p_qte_price_attributes_tbl.count);
     x_attribute6.extend(p_qte_price_attributes_tbl.count);
     x_attribute7.extend(p_qte_price_attributes_tbl.count);
     x_attribute8.extend(p_qte_price_attributes_tbl.count);
     x_attribute9.extend(p_qte_price_attributes_tbl.count);
     x_attribute10.extend(p_qte_price_attributes_tbl.count);
     x_attribute11.extend(p_qte_price_attributes_tbl.count);
     x_attribute12.extend(p_qte_price_attributes_tbl.count);
     x_attribute13.extend(p_qte_price_attributes_tbl.count);
     x_attribute14.extend(p_qte_price_attributes_tbl.count);
     x_attribute15.extend(p_qte_price_attributes_tbl.count);
     --*/

     ddindx := p_qte_price_attributes_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_price_attribute_id(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).price_attribute_id);

       /*-- The following output parameters are ignored
       x_operation_code(indx) := p_qte_price_attributes_tbl(ddindx).operation_code;
       x_qte_line_index(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).qte_line_index);
       x_creation_date(indx) := p_qte_price_attributes_tbl(ddindx).creation_date;
       x_created_by(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).created_by);
       x_last_update_date(indx) := p_qte_price_attributes_tbl(ddindx).last_update_date;
       x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).last_updated_by);
       x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).last_update_login);
       x_request_id(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).request_id);
       x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).program_application_id);
       x_program_id(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).program_id);
       x_program_update_date(indx) := p_qte_price_attributes_tbl(ddindx).program_update_date;
       x_quote_header_id(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).quote_header_id);
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_price_attributes_tbl(ddindx).quote_line_id);
       x_flex_title(indx) := p_qte_price_attributes_tbl(ddindx).flex_title;
       x_pricing_context(indx) := p_qte_price_attributes_tbl(ddindx).pricing_context;
       x_pricing_attribute1(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute1;
       x_pricing_attribute2(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute2;
       x_pricing_attribute3(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute3;
       x_pricing_attribute4(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute4;
       x_pricing_attribute5(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute5;
       x_pricing_attribute6(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute6;
       x_pricing_attribute7(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute7;
       x_pricing_attribute8(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute8;
       x_pricing_attribute9(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute9;
       x_pricing_attribute10(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute10;
       x_pricing_attribute11(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute11;
       x_pricing_attribute12(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute12;
       x_pricing_attribute13(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute13;
       x_pricing_attribute14(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute14;
       x_pricing_attribute15(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute15;
       x_pricing_attribute16(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute16;
       x_pricing_attribute17(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute17;
       x_pricing_attribute18(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute18;
       x_pricing_attribute19(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute19;
       x_pricing_attribute20(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute20;
       x_pricing_attribute21(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute21;
       x_pricing_attribute22(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute22;
       x_pricing_attribute23(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute23;
       x_pricing_attribute24(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute24;
       x_pricing_attribute25(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute25;
       x_pricing_attribute26(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute26;
       x_pricing_attribute27(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute27;
       x_pricing_attribute28(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute28;
       x_pricing_attribute29(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute29;
       x_pricing_attribute30(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute30;
       x_pricing_attribute31(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute31;
       x_pricing_attribute32(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute32;
       x_pricing_attribute33(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute33;
       x_pricing_attribute34(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute34;
       x_pricing_attribute35(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute35;
       x_pricing_attribute36(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute36;
       x_pricing_attribute37(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute37;
       x_pricing_attribute38(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute38;
       x_pricing_attribute39(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute39;
       x_pricing_attribute40(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute40;
       x_pricing_attribute41(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute41;
       x_pricing_attribute42(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute42;
       x_pricing_attribute43(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute43;
       x_pricing_attribute44(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute44;
       x_pricing_attribute45(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute45;
       x_pricing_attribute46(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute46;
       x_pricing_attribute47(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute47;
       x_pricing_attribute48(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute48;
       x_pricing_attribute49(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute49;
       x_pricing_attribute50(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute50;
       x_pricing_attribute51(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute51;
       x_pricing_attribute52(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute52;
       x_pricing_attribute53(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute53;
       x_pricing_attribute54(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute54;
       x_pricing_attribute55(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute55;
       x_pricing_attribute56(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute56;
       x_pricing_attribute57(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute57;
       x_pricing_attribute58(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute58;
       x_pricing_attribute59(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute59;
       x_pricing_attribute60(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute60;
       x_pricing_attribute61(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute61;
       x_pricing_attribute62(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute62;
       x_pricing_attribute63(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute63;
       x_pricing_attribute64(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute64;
       x_pricing_attribute65(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute65;
       x_pricing_attribute66(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute66;
       x_pricing_attribute67(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute67;
       x_pricing_attribute68(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute68;
       x_pricing_attribute69(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute69;
       x_pricing_attribute70(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute70;
       x_pricing_attribute71(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute71;
       x_pricing_attribute72(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute72;
       x_pricing_attribute73(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute73;
       x_pricing_attribute74(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute74;
       x_pricing_attribute75(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute75;
       x_pricing_attribute76(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute76;
       x_pricing_attribute77(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute77;
       x_pricing_attribute78(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute78;
       x_pricing_attribute79(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute79;
       x_pricing_attribute80(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute80;
       x_pricing_attribute81(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute81;
       x_pricing_attribute82(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute82;
       x_pricing_attribute83(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute83;
       x_pricing_attribute84(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute84;
       x_pricing_attribute85(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute85;
       x_pricing_attribute86(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute86;
       x_pricing_attribute87(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute87;
       x_pricing_attribute88(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute88;
       x_pricing_attribute89(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute89;
       x_pricing_attribute90(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute90;
       x_pricing_attribute91(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute91;
       x_pricing_attribute92(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute92;
       x_pricing_attribute93(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute93;
       x_pricing_attribute94(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute94;
       x_pricing_attribute95(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute95;
       x_pricing_attribute96(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute96;
       x_pricing_attribute97(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute97;
       x_pricing_attribute98(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute98;
       x_pricing_attribute99(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute99;
       x_pricing_attribute100(indx) := p_qte_price_attributes_tbl(ddindx).pricing_attribute100;
       x_context(indx) := p_qte_price_attributes_tbl(ddindx).context;
       x_attribute1(indx) := p_qte_price_attributes_tbl(ddindx).attribute1;
       x_attribute2(indx) := p_qte_price_attributes_tbl(ddindx).attribute2;
       x_attribute3(indx) := p_qte_price_attributes_tbl(ddindx).attribute3;
       x_attribute4(indx) := p_qte_price_attributes_tbl(ddindx).attribute4;
       x_attribute5(indx) := p_qte_price_attributes_tbl(ddindx).attribute5;
       x_attribute6(indx) := p_qte_price_attributes_tbl(ddindx).attribute6;
       x_attribute7(indx) := p_qte_price_attributes_tbl(ddindx).attribute7;
       x_attribute8(indx) := p_qte_price_attributes_tbl(ddindx).attribute8;
       x_attribute9(indx) := p_qte_price_attributes_tbl(ddindx).attribute9;
       x_attribute10(indx) := p_qte_price_attributes_tbl(ddindx).attribute10;
       x_attribute11(indx) := p_qte_price_attributes_tbl(ddindx).attribute11;
       x_attribute12(indx) := p_qte_price_attributes_tbl(ddindx).attribute12;
       x_attribute13(indx) := p_qte_price_attributes_tbl(ddindx).attribute13;
       x_attribute14(indx) := p_qte_price_attributes_tbl(ddindx).attribute14;
       x_attribute15(indx) := p_qte_price_attributes_tbl(ddindx).attribute15;
       --*/

       indx := indx+1;
       IF p_qte_price_attributes_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_price_attributes_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Price_Attributes_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso sales credit table
PROCEDURE Set_Sales_Credit_Tbl_Out(
   p_qte_sales_credit_tbl        IN  ASO_Quote_Pub.Sales_Credit_Tbl_Type,
   x_sales_credit_id             OUT NOCOPY  jtf_number_table

   /*-- The following output parameters are ignored
   x_qte_line_index              OUT NOCOPY  jtf_number_table,
   x_operation_code              OUT NOCOPY  jtf_varchar2_table_100,
   x_creation_date               OUT NOCOPY  jtf_date_table,
   x_created_by                  OUT NOCOPY  jtf_number_table,
   x_last_updated_by             OUT NOCOPY  jtf_number_table,
   x_last_update_date            OUT NOCOPY  jtf_date_table,
   x_last_update_login           OUT NOCOPY  jtf_number_table,
   x_request_id                  OUT NOCOPY  jtf_number_table,
   x_program_application_id      OUT NOCOPY  jtf_number_table,
   x_program_id                  OUT NOCOPY  jtf_number_table,
   x_program_update_date         OUT NOCOPY  jtf_date_table,
   x_quote_header_id             OUT NOCOPY  jtf_number_table,
   x_quote_line_id               OUT NOCOPY  jtf_number_table,
   x_percent                     OUT NOCOPY  jtf_number_table,
   x_resource_id                 OUT NOCOPY  jtf_number_table,
   x_first_name                  OUT NOCOPY  jtf_varchar2_table_300,
   x_last_name                   OUT NOCOPY  jtf_varchar2_table_300,
   x_sales_credit_type           OUT NOCOPY  jtf_varchar2_table_300,
   x_resource_group_id           OUT NOCOPY  jtf_number_table,
   x_employee_person_id          OUT NOCOPY  jtf_number_table,
   x_sales_credit_type_id        OUT NOCOPY  jtf_number_table,
   x_attribute_category          OUT NOCOPY  jtf_varchar2_table_100,
   x_attribute1                  OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute2                  OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute3                  OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute4                  OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute5                  OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute6                  OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute7                  OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute8                  OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute9                  OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute10                 OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute11                 OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute12                 OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute13                 OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute14                 OUT NOCOPY  jtf_varchar2_table_300,
   x_attribute15                 OUT NOCOPY  jtf_varchar2_table_300
   --*/
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_sales_credit_id := jtf_number_table();

   /*-- The following output parameters are ignored
   x_qte_line_index := jtf_number_table();
   x_operation_code := jtf_varchar2_table_100();
   x_creation_date := jtf_date_table();
   x_created_by := jtf_number_table();
   x_last_updated_by := jtf_number_table();
   x_last_update_date := jtf_date_table();
   x_last_update_login := jtf_number_table();
   x_request_id := jtf_number_table();
   x_program_application_id := jtf_number_table();
   x_program_id := jtf_number_table();
   x_program_update_date := jtf_date_table();
   x_quote_header_id := jtf_number_table();
   x_quote_line_id := jtf_number_table();
   x_percent := jtf_number_table();
   x_resource_id := jtf_number_table();
   x_first_name := jtf_varchar2_table_300();
   x_last_name := jtf_varchar2_table_300();
   x_sales_credit_type := jtf_varchar2_table_300();
   x_resource_group_id := jtf_number_table();
   x_employee_person_id := jtf_number_table();
   x_sales_credit_type_id := jtf_number_table();
   x_attribute_category := jtf_varchar2_table_100();
   x_attribute1 := jtf_varchar2_table_300();
   x_attribute2 := jtf_varchar2_table_300();
   x_attribute3 := jtf_varchar2_table_300();
   x_attribute4 := jtf_varchar2_table_300();
   x_attribute5 := jtf_varchar2_table_300();
   x_attribute6 := jtf_varchar2_table_300();
   x_attribute7 := jtf_varchar2_table_300();
   x_attribute8 := jtf_varchar2_table_300();
   x_attribute9 := jtf_varchar2_table_300();
   x_attribute10 := jtf_varchar2_table_300();
   x_attribute11 := jtf_varchar2_table_300();
   x_attribute12 := jtf_varchar2_table_300();
   x_attribute13 := jtf_varchar2_table_300();
   x_attribute14 := jtf_varchar2_table_300();
   x_attribute15 := jtf_varchar2_table_300();
   --*/
   IF p_qte_sales_credit_tbl.count > 0 THEN
     x_sales_credit_id.extend(p_qte_sales_credit_tbl.count);

     /*-- The following output parameters are ignored
     x_qte_line_index.extend(p_qte_sales_credit_tbl.count);
     x_operation_code.extend(p_qte_sales_credit_tbl.count);
     x_creation_date.extend(p_qte_sales_credit_tbl.count);
     x_created_by.extend(p_qte_sales_credit_tbl.count);
     x_last_updated_by.extend(p_qte_sales_credit_tbl.count);
     x_last_update_date.extend(p_qte_sales_credit_tbl.count);
     x_last_update_login.extend(p_qte_sales_credit_tbl.count);
     x_request_id.extend(p_qte_sales_credit_tbl.count);
     x_program_application_id.extend(p_qte_sales_credit_tbl.count);
     x_program_id.extend(p_qte_sales_credit_tbl.count);
     x_program_update_date.extend(p_qte_sales_credit_tbl.count);
     x_quote_header_id.extend(p_qte_sales_credit_tbl.count);
     x_quote_line_id.extend(p_qte_sales_credit_tbl.count);
     x_percent.extend(p_qte_sales_credit_tbl.count);
     x_resource_id.extend(p_qte_sales_credit_tbl.count);
     x_first_name.extend(p_qte_sales_credit_tbl.count);
     x_last_name.extend(p_qte_sales_credit_tbl.count);
     x_sales_credit_type.extend(p_qte_sales_credit_tbl.count);
     x_resource_group_id.extend(p_qte_sales_credit_tbl.count);
     x_employee_person_id.extend(p_qte_sales_credit_tbl.count);
     x_sales_credit_type_id.extend(p_qte_sales_credit_tbl.count);
     x_attribute_category.extend(p_qte_sales_credit_tbl.count);
     x_attribute1.extend(p_qte_sales_credit_tbl.count);
     x_attribute2.extend(p_qte_sales_credit_tbl.count);
     x_attribute3.extend(p_qte_sales_credit_tbl.count);
     x_attribute4.extend(p_qte_sales_credit_tbl.count);
     x_attribute5.extend(p_qte_sales_credit_tbl.count);
     x_attribute6.extend(p_qte_sales_credit_tbl.count);
     x_attribute7.extend(p_qte_sales_credit_tbl.count);
     x_attribute8.extend(p_qte_sales_credit_tbl.count);
     x_attribute9.extend(p_qte_sales_credit_tbl.count);
     x_attribute10.extend(p_qte_sales_credit_tbl.count);
     x_attribute11.extend(p_qte_sales_credit_tbl.count);
     x_attribute12.extend(p_qte_sales_credit_tbl.count);
     x_attribute13.extend(p_qte_sales_credit_tbl.count);
     x_attribute14.extend(p_qte_sales_credit_tbl.count);
     x_attribute15.extend(p_qte_sales_credit_tbl.count);
     --*/

     ddindx := p_qte_sales_credit_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_sales_credit_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).sales_credit_id);

       /*-- The following output parameters are ignored
       x_qte_line_index(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).qte_line_index);
       x_operation_code(indx) := p_qte_sales_credit_tbl(ddindx).operation_code;
       x_creation_date(indx) := p_qte_sales_credit_tbl(ddindx).creation_date;
       x_created_by(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).created_by);
       x_last_updated_by(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).last_updated_by);
       x_last_update_date(indx) := p_qte_sales_credit_tbl(ddindx).last_update_date;
       x_last_update_login(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).last_update_login);
       x_request_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).request_id);
       x_program_application_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).program_application_id);
       x_program_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).program_id);
       x_program_update_date(indx) := p_qte_sales_credit_tbl(ddindx).program_update_date;
       x_quote_header_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).quote_header_id);
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).quote_line_id);
       x_percent(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).percent);
       x_resource_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).resource_id);
       x_first_name(indx) := p_qte_sales_credit_tbl(ddindx).first_name;
       x_last_name(indx) := p_qte_sales_credit_tbl(ddindx).last_name;
       x_sales_credit_type(indx) := p_qte_sales_credit_tbl(ddindx).sales_credit_type;
       x_resource_group_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).resource_group_id);
       x_employee_person_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).employee_person_id);
       x_sales_credit_type_id(indx) := rosetta_g_miss_num_map(p_qte_sales_credit_tbl(ddindx).sales_credit_type_id);
       x_attribute_category(indx) := p_qte_sales_credit_tbl(ddindx).attribute_category_code;
       x_attribute1(indx) := p_qte_sales_credit_tbl(ddindx).attribute1;
       x_attribute2(indx) := p_qte_sales_credit_tbl(ddindx).attribute2;
       x_attribute3(indx) := p_qte_sales_credit_tbl(ddindx).attribute3;
       x_attribute4(indx) := p_qte_sales_credit_tbl(ddindx).attribute4;
       x_attribute5(indx) := p_qte_sales_credit_tbl(ddindx).attribute5;
       x_attribute6(indx) := p_qte_sales_credit_tbl(ddindx).attribute6;
       x_attribute7(indx) := p_qte_sales_credit_tbl(ddindx).attribute7;
       x_attribute8(indx) := p_qte_sales_credit_tbl(ddindx).attribute8;
       x_attribute9(indx) := p_qte_sales_credit_tbl(ddindx).attribute9;
       x_attribute10(indx) := p_qte_sales_credit_tbl(ddindx).attribute10;
       x_attribute11(indx) := p_qte_sales_credit_tbl(ddindx).attribute11;
       x_attribute12(indx) := p_qte_sales_credit_tbl(ddindx).attribute12;
       x_attribute13(indx) := p_qte_sales_credit_tbl(ddindx).attribute13;
       x_attribute14(indx) := p_qte_sales_credit_tbl(ddindx).attribute14;
       x_attribute15(indx) := p_qte_sales_credit_tbl(ddindx).attribute15;
       --*/

       indx := indx+1;
       IF p_qte_sales_credit_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_sales_credit_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Sales_Credit_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso approvers list table
PROCEDURE Set_Approvers_List_Tbl_Out(
   p_qte_approvers_list_tbl  IN  ASO_Apr_Pub.Approvers_List_Tbl_Type,
   x_approval_det_id         OUT NOCOPY  jtf_number_table,
   x_object_approval_id      OUT NOCOPY  jtf_number_table,
   x_approver_person_id      OUT NOCOPY  jtf_number_table,
   x_approver_user_id        OUT NOCOPY  jtf_number_table,
   x_notification_id         OUT NOCOPY  jtf_number_table,
   x_approver_sequence       OUT NOCOPY  jtf_number_table,
   x_approver_status         OUT NOCOPY  jtf_varchar2_table_100,
   x_approver_name           OUT NOCOPY  jtf_varchar2_table_100,
   x_approval_comments       OUT NOCOPY  jtf_varchar2_table_300,
   x_date_sent               OUT NOCOPY  jtf_date_table,
   x_date_received           OUT NOCOPY  jtf_date_table
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_approval_det_id := jtf_number_table();
   x_object_approval_id := jtf_number_table();
   x_approver_person_id := jtf_number_table();
   x_approver_user_id := jtf_number_table();
   x_notification_id := jtf_number_table();
   x_approver_sequence := jtf_number_table();
   x_approver_status := jtf_varchar2_table_100();
   x_approver_name := jtf_varchar2_table_100();
   x_approval_comments := jtf_varchar2_table_300();
   x_date_sent := jtf_date_table();
   x_date_received := jtf_date_table();
   IF p_qte_approvers_list_tbl.count > 0 THEN
     x_approval_det_id.extend(p_qte_approvers_list_tbl.count);
     x_object_approval_id.extend(p_qte_approvers_list_tbl.count);
     x_approver_person_id.extend(p_qte_approvers_list_tbl.count);
     x_approver_user_id.extend(p_qte_approvers_list_tbl.count);
     x_notification_id.extend(p_qte_approvers_list_tbl.count);
     x_approver_sequence.extend(p_qte_approvers_list_tbl.count);
     x_approver_status.extend(p_qte_approvers_list_tbl.count);
     x_approver_name.extend(p_qte_approvers_list_tbl.count);
     x_approval_comments.extend(p_qte_approvers_list_tbl.count);
     x_date_sent.extend(p_qte_approvers_list_tbl.count);
     x_date_received.extend(p_qte_approvers_list_tbl.count);
     ddindx := p_qte_approvers_list_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_approval_det_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).approval_det_id);
       x_object_approval_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).object_approval_id);
       x_approver_person_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).approver_person_id);
       x_approver_user_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).approver_user_id);
       x_notification_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).notification_id);
       x_approver_sequence(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).approver_sequence);
       x_approver_status(indx) := p_qte_approvers_list_tbl(ddindx).approver_status;
       x_approver_name(indx) := p_qte_approvers_list_tbl(ddindx).approver_name;
       x_approval_comments(indx) := p_qte_approvers_list_tbl(ddindx).approval_comments;
       x_date_sent(indx) := p_qte_approvers_list_tbl(ddindx).date_sent;
       x_date_received(indx) := p_qte_approvers_list_tbl(ddindx).date_recieved;
       indx := indx+1;
       IF p_qte_approvers_list_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_approvers_list_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Approvers_List_Tbl_Out;


-- copy data OUT NOCOPY /* file.sql.39 change */ from aso rules list table
PROCEDURE Set_Rules_List_Tbl_Out(
   p_qte_rules_list_tbl    IN  ASO_Apr_Pub.Rules_List_Tbl_Type,
   x_rule_id               OUT NOCOPY  jtf_number_table,
   x_object_approval_id    OUT NOCOPY  jtf_number_table,
   x_rule_action_id        OUT NOCOPY  jtf_number_table,
   x_rule_description      OUT NOCOPY  jtf_varchar2_table_300,
   x_approval_level        OUT NOCOPY  jtf_varchar2_table_300
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_rule_id := jtf_number_table();
   x_object_approval_id := jtf_number_table();
   x_rule_action_id := jtf_number_table();
   x_rule_description := jtf_varchar2_table_300();
   x_approval_level := jtf_varchar2_table_300();
   IF p_qte_rules_list_tbl.count > 0 THEN
     x_rule_id.extend(p_qte_rules_list_tbl.count);
     x_object_approval_id.extend(p_qte_rules_list_tbl.count);
     x_rule_action_id.extend(p_qte_rules_list_tbl.count);
     x_rule_description.extend(p_qte_rules_list_tbl.count);
     x_approval_level.extend(p_qte_rules_list_tbl.count);
     ddindx := p_qte_rules_list_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_rule_id(indx) := rosetta_g_miss_num_map(p_qte_rules_list_tbl(ddindx).rule_id);
       x_object_approval_id(indx) := rosetta_g_miss_num_map(p_qte_rules_list_tbl(ddindx).object_approval_id);
       x_rule_action_id(indx) := rosetta_g_miss_num_map(p_qte_rules_list_tbl(ddindx).rule_action_id);
       x_rule_description(indx) := p_qte_rules_list_tbl(ddindx).rule_description;
       x_approval_level(indx) := p_qte_rules_list_tbl(ddindx).approval_level;
       indx := indx+1;
       IF p_qte_rules_list_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_rules_list_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Rules_List_Tbl_Out;

-- there IS total 6 fields here OUT NOCOPY /* file.sql.39 change */ line
PROCEDURE Set_Opp_Qte_Out_Rec_Out(
   p_opp_qte_out_rec   IN  ASO_Opp_Qte_Pub.Opp_Qte_Out_Rec_Type,
   x_quote_header_id   OUT NOCOPY  NUMBER                              ,
   x_quote_number      OUT NOCOPY  NUMBER                              ,
   x_related_object_id OUT NOCOPY  NUMBER                              ,
   x_cust_account_id   OUT NOCOPY  NUMBER                              ,
   x_party_id          OUT NOCOPY  NUMBER                              ,
   x_currency_code     OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_quote_header_id := rosetta_g_miss_num_map(p_opp_qte_out_rec.quote_header_id);
   x_quote_number := rosetta_g_miss_num_map(p_opp_qte_out_rec.quote_number);
   x_related_object_id := rosetta_g_miss_num_map(p_opp_qte_out_rec.related_object_id);
   x_cust_account_id := rosetta_g_miss_num_map(p_opp_qte_out_rec.cust_account_id);
   x_party_id        := rosetta_g_miss_num_map(p_opp_qte_out_rec.party_id);
   x_currency_code   := p_opp_qte_out_rec.currency_code;
END Set_Opp_Qte_Out_Rec_Out;

-- copy info OUT NOCOPY /* file.sql.39 change */ from aso quote accesses tbl
PROCEDURE Set_Qte_Access_Tbl_Out(
   p_qte_access_tbl IN  ASO_Quote_Pub.Qte_Access_Tbl_Type,
   x_access_id      OUT NOCOPY  jtf_number_table
)
IS
   ddindx binary_integer;
   indx binary_integer;
BEGIN
   x_access_id := jtf_number_table();
   IF p_qte_access_tbl.count > 0 THEN
     x_access_id.extend(p_qte_access_tbl.count);
     ddindx := p_qte_access_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_access_id(indx) := rosetta_g_miss_num_map(p_qte_access_tbl(ddindx).access_id);
       indx := indx+1;
       IF p_qte_access_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_access_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Qte_Access_Tbl_Out;

-- copy info OUT NOCOPY /* file.sql.39 change */ from aso template tbl
PROCEDURE Set_Template_Tbl_Out(
   p_template_tbl  IN  ASO_Quote_Pub.Template_Tbl_Type,
   x_template_id   OUT NOCOPY  jtf_number_table
)
IS
   ddindx binary_integer;
   indx binary_integer;
BEGIN
   x_template_id := jtf_number_table();
   IF p_template_tbl.count > 0 THEN
     x_template_id.extend(p_template_tbl.count);
     ddindx := p_template_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_template_id(indx) := rosetta_g_miss_num_map(p_template_tbl(ddindx).template_id);
       indx := indx+1;
       IF p_template_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_template_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Template_Tbl_Out;


PROCEDURE Set_Atp_Tbl_Out (
  p_atp_tbl                    IN  ASO_ATP_INT.Atp_Tbl_Typ,
  x_inventory_item_id          OUT NOCOPY  JTF_NUMBER_TABLE,
  x_inventory_item_name        OUT NOCOPY  JTF_VARCHAR2_TABLE_300,
  x_inventory_item_description OUT NOCOPY  JTF_VARCHAR2_TABLE_300,
  x_padded_concatenated_segments OUT NOCOPY JTF_VARCHAR2_TABLE_300,
  x_source_organization_id     OUT NOCOPY  JTF_NUMBER_TABLE,
  x_source_organization_code   OUT NOCOPY  JTF_VARCHAR2_TABLE_300,
  x_source_organization_name   OUT NOCOPY  JTF_VARCHAR2_TABLE_300,
  x_identifier                 OUT NOCOPY  JTF_NUMBER_TABLE,
  x_customer_id                OUT NOCOPY  JTF_NUMBER_TABLE,
  x_customer_site_id           OUT NOCOPY  JTF_NUMBER_TABLE,
  x_quantity_ordered           OUT NOCOPY  JTF_NUMBER_TABLE,
  x_quantity_uom               OUT NOCOPY  JTF_VARCHAR2_TABLE_100,
  x_uom_meaning                OUT NOCOPY  JTF_VARCHAR2_TABLE_100,
  x_requested_ship_date        OUT NOCOPY  JTF_DATE_TABLE,
  x_ship_date                  OUT NOCOPY  JTF_DATE_TABLE,
  x_available_quantity         OUT NOCOPY  JTF_NUMBER_TABLE,
  x_request_date_quantity      OUT NOCOPY  JTF_NUMBER_TABLE,
  x_error_code                 OUT NOCOPY  JTF_NUMBER_TABLE,
  x_message                    OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   x_request_date_type                OUT NOCOPY jtf_varchar2_table_300,
   x_request_date_type_meaning        OUT NOCOPY jtf_varchar2_table_300,
   x_demand_class_code                OUT NOCOPY jtf_varchar2_table_300,
   x_demand_class_meaning                OUT NOCOPY jtf_varchar2_table_300,
   x_ship_set_name                    OUT NOCOPY jtf_varchar2_table_300,
   x_arrival_set_name                 OUT NOCOPY jtf_varchar2_table_300,
   x_line_number                     OUT NOCOPY jtf_varchar2_table_800,
   x_group_ship_date                  OUT NOCOPY jtf_date_table,
   x_requested_arrival_date           OUT NOCOPY jtf_date_table,
   x_ship_method_code                 OUT NOCOPY jtf_varchar2_table_300,
   x_ship_method_meaning                 OUT NOCOPY jtf_varchar2_table_300,
   x_quantity_on_hand                 OUT NOCOPY jtf_number_table,
   x_quote_header_id                  OUT NOCOPY jtf_number_table,
   x_calling_module                   OUT NOCOPY jtf_number_table,
   x_quote_number                     OUT NOCOPY jtf_number_table,
   x_ato_line_id                      OUT NOCOPY jtf_number_table,
   x_ref_line_id                      OUT NOCOPY jtf_number_table,
   x_top_model_line_id                OUT NOCOPY jtf_number_table,
   x_action                           OUT NOCOPY jtf_number_table,
   x_arrival_date                     OUT NOCOPY jtf_date_table,
   x_organization_id                  OUT NOCOPY jtf_number_table,
   x_component_code                   OUT NOCOPY jtf_varchar2_table_1200,
   x_component_sequence_id            OUT NOCOPY jtf_number_table,
   x_included_item_flag               OUT NOCOPY jtf_number_table,
   x_cascade_model_info_to_comp       OUT NOCOPY jtf_number_table,
   x_ship_to_party_site_id            OUT NOCOPY jtf_number_table,
   x_country                          OUT NOCOPY jtf_varchar2_table_600,
   x_state                            OUT NOCOPY jtf_varchar2_table_600,
   x_city                             OUT NOCOPY jtf_varchar2_table_600,
   x_postal_code                      OUT NOCOPY jtf_varchar2_table_600,
   x_match_item_id                    OUT NOCOPY jtf_number_table
)
IS
  ddindx binary_integer;
  indx binary_integer;
BEGIN
  x_inventory_item_id           := JTF_NUMBER_TABLE();
  x_inventory_item_name         := JTF_VARCHAR2_TABLE_300();
  x_inventory_item_description         := JTF_VARCHAR2_TABLE_300();
  x_padded_concatenated_segments         := JTF_VARCHAR2_TABLE_300();
  x_source_organization_id      := JTF_NUMBER_TABLE();
  x_source_organization_code    := JTF_VARCHAR2_TABLE_300();
  x_source_organization_name    := JTF_VARCHAR2_TABLE_300();
  x_identifier                  := JTF_NUMBER_TABLE();
  x_customer_id                 := JTF_NUMBER_TABLE();
  x_customer_site_id            := JTF_NUMBER_TABLE();
  x_quantity_ordered            := JTF_NUMBER_TABLE();
  x_quantity_uom                := JTF_VARCHAR2_TABLE_100();
  x_uom_meaning                 := JTF_VARCHAR2_TABLE_100();
  x_requested_ship_date         := JTF_DATE_TABLE();
  x_ship_date                   := JTF_DATE_TABLE();
  x_available_quantity          := JTF_NUMBER_TABLE();
  x_request_date_quantity       := JTF_NUMBER_TABLE();
  x_error_code                  := JTF_NUMBER_TABLE();
  x_message                     := JTF_VARCHAR2_TABLE_2000();

   x_request_date_type                :=jtf_varchar2_table_300();
   x_request_date_type_meaning        :=jtf_varchar2_table_300();
   x_demand_class_code                :=jtf_varchar2_table_300();
   x_demand_class_meaning                :=jtf_varchar2_table_300();
   x_ship_set_name                    :=jtf_varchar2_table_300();
   x_arrival_set_name                 :=jtf_varchar2_table_300();
   x_line_number                     :=jtf_varchar2_table_800();
   x_group_ship_date                  :=jtf_date_table();
   x_requested_arrival_date           :=jtf_date_table();
   x_ship_method_code                 :=jtf_varchar2_table_300();
   x_ship_method_meaning              :=jtf_varchar2_table_300();
   x_quantity_on_hand                 :=jtf_number_table();
   x_quote_header_id                  :=jtf_number_table();
   x_calling_module                   :=jtf_number_table();
   x_quote_number                     :=jtf_number_table();
   x_ato_line_id                      :=jtf_number_table();
   x_ref_line_id                      :=jtf_number_table();
   x_top_model_line_id                :=jtf_number_table();
   x_action                           :=jtf_number_table();
   x_arrival_date                     :=jtf_date_table();
   x_organization_id                  :=jtf_number_table();
   x_component_code                   :=jtf_varchar2_table_1200();
   x_component_sequence_id            :=jtf_number_table();
   x_included_item_flag               :=jtf_number_table();
   x_cascade_model_info_to_comp       :=jtf_number_table();
   x_ship_to_party_site_id            :=jtf_number_table();
   x_country                          :=jtf_varchar2_table_600();
   x_state                            :=jtf_varchar2_table_600();
   x_city                             :=jtf_varchar2_table_600();
   x_postal_code                      :=jtf_varchar2_table_600();
   x_match_item_id                 :=jtf_number_table();


  IF   p_atp_tbl.COUNT > 0
  THEN
       x_inventory_item_id.extend(p_atp_tbl.COUNT);
       x_inventory_item_name.extend(p_atp_tbl.COUNT);
       x_inventory_item_description.extend(p_atp_tbl.COUNT);
       x_padded_concatenated_segments.extend(p_atp_tbl.COUNT);
	  x_source_organization_id.extend(p_atp_tbl.COUNT);
       x_source_organization_code.extend(p_atp_tbl.COUNT);
       x_source_organization_name.extend(p_atp_tbl.COUNT);
	  x_identifier.extend(p_atp_tbl.COUNT);
       x_customer_id.extend(p_atp_tbl.COUNT);
       x_customer_site_id.extend(p_atp_tbl.COUNT);
       x_quantity_ordered.extend(p_atp_tbl.COUNT);
       x_quantity_uom.extend(p_atp_tbl.COUNT);
       x_uom_meaning.extend(p_atp_tbl.COUNT);
       x_requested_ship_date.extend(p_atp_tbl.COUNT);
       x_ship_date.extend(p_atp_tbl.COUNT);
       x_available_quantity.extend(p_atp_tbl.COUNT);
       x_request_date_quantity.extend(p_atp_tbl.COUNT);
       x_error_code.extend(p_atp_tbl.COUNT);
       x_message.extend(p_atp_tbl.COUNT);


   x_request_date_type.extend(p_atp_tbl.COUNT);
   x_request_date_type_meaning.extend(p_atp_tbl.COUNT);
   x_demand_class_code.extend(p_atp_tbl.COUNT);
   x_demand_class_meaning.extend(p_atp_tbl.COUNT);
   x_ship_set_name.extend(p_atp_tbl.COUNT);
   x_arrival_set_name.extend(p_atp_tbl.COUNT);
   x_line_number.extend(p_atp_tbl.COUNT);
   x_group_ship_date.extend(p_atp_tbl.COUNT);
   x_requested_arrival_date.extend(p_atp_tbl.COUNT);
   x_ship_method_code.extend(p_atp_tbl.COUNT);
   x_ship_method_meaning.extend(p_atp_tbl.COUNT);
   x_quantity_on_hand.extend(p_atp_tbl.COUNT);
   x_quote_header_id .extend(p_atp_tbl.COUNT);
   x_calling_module.extend(p_atp_tbl.COUNT);
   x_quote_number.extend(p_atp_tbl.COUNT);
   x_ato_line_id.extend(p_atp_tbl.COUNT);
   x_ref_line_id.extend(p_atp_tbl.COUNT);
   x_top_model_line_id.extend(p_atp_tbl.COUNT);
   x_action.extend(p_atp_tbl.COUNT);
   x_arrival_date.extend(p_atp_tbl.COUNT);
   x_organization_id.extend(p_atp_tbl.COUNT);
   x_component_code.extend(p_atp_tbl.COUNT);
   x_component_sequence_id.extend(p_atp_tbl.COUNT);
   x_included_item_flag.extend(p_atp_tbl.COUNT);
   x_cascade_model_info_to_comp.extend(p_atp_tbl.COUNT);
   x_ship_to_party_site_id.extend(p_atp_tbl.COUNT);
   x_country.extend(p_atp_tbl.COUNT);
   x_state.extend(p_atp_tbl.COUNT);
   x_city.extend(p_atp_tbl.COUNT);
   x_postal_code.extend(p_atp_tbl.COUNT);
   x_match_item_id.extend(p_atp_tbl.COUNT);

       ddindx := p_atp_tbl.first;
       indx := 1;

       WHILE true LOOP
            x_inventory_item_id(indx)     := rosetta_g_miss_num_map(p_atp_tbl(ddindx).inventory_item_id);
            x_inventory_item_name(indx)   := p_atp_tbl(ddindx).inventory_item_name;
            x_inventory_item_description(indx)   := p_atp_tbl(ddindx).inventory_item_description;
            x_padded_concatenated_segments(indx)   := p_atp_tbl(ddindx).padded_concatenated_segments;

		  x_source_organization_id(indx):= rosetta_g_miss_num_map(p_atp_tbl(ddindx).source_organization_id);
            --x_inventory_item_name(indx)   := p_atp_tbl(ddindx).source_organization_code;
            x_source_organization_code(indx)   := p_atp_tbl(ddindx).source_organization_code;
		  x_source_organization_name(indx)   := p_atp_tbl(ddindx).source_organization_name;
		  x_identifier(indx)            := rosetta_g_miss_num_map(p_atp_tbl(ddindx).identifier);
            x_customer_id(indx)           := rosetta_g_miss_num_map(p_atp_tbl(ddindx).customer_id);
            x_customer_site_id(indx)      := rosetta_g_miss_num_map(p_atp_tbl(ddindx).customer_site_id);
            x_quantity_ordered(indx)      := rosetta_g_miss_num_map(p_atp_tbl(ddindx).quantity_ordered);
            x_quantity_uom(indx)          := p_atp_tbl(ddindx).quantity_uom;
            x_uom_meaning(indx)          := p_atp_tbl(ddindx).uom_meaning;
		  x_requested_ship_date(indx)   := p_atp_tbl(ddindx).requested_ship_date;
            x_ship_date(indx)             := p_atp_tbl(ddindx).ship_date;
            x_available_quantity(indx)    := rosetta_g_miss_num_map(p_atp_tbl(ddindx).available_quantity);
            x_request_date_quantity(indx) := rosetta_g_miss_num_map(p_atp_tbl(ddindx).request_date_quantity);
            x_error_code(indx)            := rosetta_g_miss_num_map(p_atp_tbl(ddindx).error_code);
            x_message(indx)               := p_atp_tbl(ddindx).message;

   x_request_date_type(indx)  := p_atp_tbl(ddindx).request_date_type;
   x_request_date_type_meaning(indx)  := p_atp_tbl(ddindx).request_date_type_meaning;
   x_demand_class_code(indx)   := p_atp_tbl(ddindx).demand_class_code   ;
   x_demand_class_meaning(indx)   := p_atp_tbl(ddindx).demand_class_meaning   ;
   x_ship_set_name(indx)     := p_atp_tbl(ddindx).ship_set_name     ;
   x_arrival_set_name(indx)   := p_atp_tbl(ddindx).arrival_set_name   ;
   x_line_number(indx)    := p_atp_tbl(ddindx).line_number    ;
   x_group_ship_date(indx)      := p_atp_tbl(ddindx).group_ship_date;
   x_requested_arrival_date(indx)      := p_atp_tbl(ddindx).requested_arrival_date      ;
   x_ship_method_code(indx)     := p_atp_tbl(ddindx).ship_method_code  ;
   x_ship_method_meaning(indx)     := p_atp_tbl(ddindx).ship_method_meaning  ;
   x_quantity_on_hand(indx)    := rosetta_g_miss_num_map(p_atp_tbl(ddindx).quantity_on_hand)    ;
   x_quote_header_id(indx)   :=  rosetta_g_miss_num_map(p_atp_tbl(ddindx).quote_header_id);
   x_calling_module(indx)    := rosetta_g_miss_num_map(p_atp_tbl(ddindx).calling_module)    ;
   x_quote_number(indx)    := rosetta_g_miss_num_map(p_atp_tbl(ddindx).quote_number)    ;
   x_ato_line_id(indx)    :=  rosetta_g_miss_num_map(p_atp_tbl(ddindx).ato_line_id)    ;
   x_ref_line_id(indx)      := rosetta_g_miss_num_map(p_atp_tbl(ddindx).ref_line_id)      ;
   x_top_model_line_id(indx)      := rosetta_g_miss_num_map(p_atp_tbl(ddindx).top_model_line_id)      ;
   x_action(indx)      := rosetta_g_miss_num_map(p_atp_tbl(ddindx).action);
   x_arrival_date(indx)       := p_atp_tbl(ddindx).arrival_date       ;
   x_organization_id(indx)     :=  rosetta_g_miss_num_map(p_atp_tbl(ddindx).organization_id)     ;
   x_component_code(indx)    :=  p_atp_tbl(ddindx).component_code    ;
   x_component_sequence_id(indx)   := rosetta_g_miss_num_map(p_atp_tbl(ddindx).component_sequence_id)   ;
   x_included_item_flag(indx)   := rosetta_g_miss_num_map(p_atp_tbl(ddindx).included_item_flag)   ;
   x_cascade_model_info_to_comp(indx)        := rosetta_g_miss_num_map(p_atp_tbl(ddindx).cascade_model_info_to_comp)        ;
   x_ship_to_party_site_id(indx)   := rosetta_g_miss_num_map(p_atp_tbl(ddindx).ship_to_party_site_id)   ;
   x_country(indx)    := p_atp_tbl(ddindx).country;
   x_state(indx)    := p_atp_tbl(ddindx).state    ;
   x_city(indx)   := p_atp_tbl(ddindx).city   ;
   x_postal_code(indx)     := p_atp_tbl(ddindx).postal_code     ;
   x_match_item_id(indx)   := rosetta_g_miss_num_map(p_atp_tbl(ddindx).match_item_id)   ;

            indx := indx+1;
            IF   p_atp_tbl.last = ddindx
            THEN EXIT;
            END  IF;
            ddindx := p_atp_tbl.next(ddindx);

        END LOOP;
   END IF;

END Set_Atp_Tbl_Out;


-- Set the org id for given user id and notification id, when logged in
-- user id is in match the user id corresponding to notification id
PROCEDURE setOrgIdForNotifUserId(
  p_apvl_orgid         IN     NUMBER,
  p_apvl_notifId       IN     NUMBER,
  p_login_userid       IN     NUMBER,
  x_status             OUT NOCOPY /* file.sql.39 change */    VARCHAR2
 )IS


 Cursor C_APV_UserId(c_notif_id number) IS
 Select decode(orig_system, 'FND_USR', orig_system_id, 'PER', a.user_id, NULL) user_id
 From wf_roles b, wf_notifications c, fnd_user a
 Where b.name = c.recipient_role
 And c.notification_id = c_notif_id
 And a.employee_id (+) = b.ORIG_SYSTEM_ID;

 l_user_id  NUMBER;

BEGIN
    x_status := 'Y';
    IF (p_login_userid = -1 ) THEN
    /* dbms_application_info.set_client_info(p_apvl_orgid); */ --Commented Code Yogeshwar (MOAC)
    MO_GLOBAL.SET_POLICY_CONTEXT('S',p_apvl_orgid);  --New Code Yogeshwar (MOAC)
    ELSE

       OPEN C_APV_UserId(p_apvl_notifId);
       FETCH C_APV_UserId INTO l_user_id;
       CLOSE C_APV_UserId;

       IF(p_login_userid = l_user_id)  THEN
        /*  dbms_application_info.set_client_info(p_apvl_orgid); */ --Commented Code Yogeshwar (MOAC)
	MO_GLOBAL.SET_POLICY_CONTEXT('S',p_apvl_orgid);    --New Code Yogeshwar (MOAC)
       ELSE
         x_status := 'N';
       END IF;

    END IF;

    EXCEPTION
      When others Then
        null;

END setOrgIdForNotifUserId;

FUNCTION Construct_Template_Rec(
   p_template_id              IN NUMBER   := FND_API.G_MISS_NUM
 )
RETURN ASO_Quote_Pub.Template_Rec_Type
IS

   l_template_rec   ASO_Quote_Pub.Template_Rec_Type;

BEGIN

   IF p_template_id = ROSETTA_G_MISS_NUM THEN
      l_template_rec.template_id := FND_API.G_MISS_NUM;
   ELSE
      l_template_rec.template_id := p_template_id;
   END IF;

   return l_template_rec;

END Construct_Template_Rec;


FUNCTION Construct_Template_Tbl(
    p_template_id              IN jtf_number_table       := NULL
   )
RETURN ASO_Quote_Pub.Template_Tbl_Type
IS
   l_template_tbl ASO_Quote_Pub.Template_Tbl_Type;
   l_table_size   PLS_INTEGER := 0;
   i              PLS_INTEGER;
BEGIN

   IF p_template_id IS NOT NULL THEN
      l_table_size := p_template_id.COUNT;
   END IF;

   IF l_table_size > 0 THEN

   FOR i IN 1..l_table_size LOOP

     IF p_template_id IS NOT NULL THEN
      IF p_template_id(i)= ROSETTA_G_MISS_NUM THEN
         l_template_tbl(i).template_id := FND_API.G_MISS_NUM;
      ELSE
         l_template_tbl(i).template_id := p_template_id(i);
      END IF;
     END IF;

   END LOOP;

   RETURN l_template_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_TEMPLATE_TBL;
   END IF;
END Construct_Template_Tbl;



FUNCTION Construct_Trigger_Attr_Tbl(
   p_trigger_attribute   IN jtf_varchar2_table_100  := NULL
)
RETURN ASO_Defaulting_Int.Attribute_Codes_Tbl_Type
IS
   l_trigger_attr_tbl ASO_Defaulting_Int.ATTRIBUTE_CODES_TBL_TYPE;
   l_table_size   PLS_INTEGER := 0;
   i              PLS_INTEGER;
BEGIN

   IF p_trigger_attribute IS NOT NULL THEN
      l_table_size := p_trigger_attribute.COUNT;
   END IF;

   IF l_table_size > 0 THEN

   FOR i IN 1..l_table_size LOOP

     IF p_trigger_attribute IS NOT NULL THEN
         l_trigger_attr_tbl(i) := p_trigger_attribute(i);
     END IF;

   END LOOP;

   RETURN l_trigger_attr_tbl;
   ELSE
      RETURN ASO_Defaulting_Int.G_MISS_ATTRIBUTE_CODES_TBL;
   END IF;
END Construct_Trigger_Attr_Tbl;


FUNCTION Construct_Hdr_Misc_Rec(
   p_attribute1              IN VARCHAR2 := FND_API.G_MISS_CHAR
 )
RETURN ASO_Defaulting_Int.Header_Misc_Rec_Type
IS

   l_hdr_misc_rec   ASO_Defaulting_Int.Header_Misc_Rec_Type;

BEGIN
      l_hdr_misc_rec.attribute1 := p_attribute1;

   return l_hdr_misc_rec;

END Construct_Hdr_Misc_Rec;


FUNCTION Construct_Ln_Misc_Rec(
   p_attribute1              IN VARCHAR2 := FND_API.G_MISS_CHAR
 )
RETURN ASO_Defaulting_Int.Line_Misc_Rec_Type
IS

   l_ln_misc_rec   ASO_Defaulting_Int.Line_Misc_Rec_Type;

BEGIN
      l_ln_misc_rec.attribute1 := p_attribute1;

return l_ln_misc_rec;

END Construct_Ln_Misc_Rec;


PROCEDURE Set_Qte_header_rec_Out(
   p_qte_header_rec                   IN  ASO_Quote_Pub.Qte_header_rec_Type,
   x_q_quote_header_id                OUT NOCOPY NUMBER,
   x_q_creation_date                  OUT NOCOPY DATE,
   x_q_created_by                     OUT NOCOPY NUMBER,
   x_q_last_updated_by                OUT NOCOPY NUMBER,
   x_q_last_update_date               OUT NOCOPY DATE,
   x_q_last_update_login              OUT NOCOPY NUMBER,
   x_q_request_id                     OUT NOCOPY NUMBER,
   x_q_program_application_id         OUT NOCOPY NUMBER,
   x_q_program_id                     OUT NOCOPY NUMBER,
   x_q_program_update_date            OUT NOCOPY DATE,
   x_q_org_id                         OUT NOCOPY NUMBER,
   x_q_quote_name                     OUT NOCOPY VARCHAR2,
   x_q_quote_number                   OUT NOCOPY NUMBER,
   x_q_quote_version                  OUT NOCOPY NUMBER,
   x_q_quote_status_id                OUT NOCOPY NUMBER,
   x_q_quote_source_code              OUT NOCOPY VARCHAR2,
   x_q_quote_expiration_date          OUT NOCOPY DATE,
   x_q_price_frozen_date              OUT NOCOPY DATE,
   x_q_quote_password                 OUT NOCOPY VARCHAR2,
   x_q_original_system_reference      OUT NOCOPY VARCHAR2,
   x_q_party_id                       OUT NOCOPY NUMBER,
   x_q_cust_account_id                OUT NOCOPY NUMBER,
   x_q_invoice_to_cust_acct_id        OUT NOCOPY NUMBER,
   x_q_org_contact_id                 OUT NOCOPY NUMBER,
   x_q_party_name                     OUT NOCOPY VARCHAR2,
   x_q_party_type                     OUT NOCOPY VARCHAR2,
   x_q_person_first_name              OUT NOCOPY VARCHAR2,
   x_q_person_last_name               OUT NOCOPY VARCHAR2,
   x_q_person_middle_name             OUT NOCOPY VARCHAR2,
   x_q_phone_id                       OUT NOCOPY NUMBER,
   x_q_price_list_id                  OUT NOCOPY NUMBER,
   x_q_price_list_name                OUT NOCOPY VARCHAR2,
   x_q_currency_code                  OUT NOCOPY VARCHAR2,
   x_q_total_list_price               OUT NOCOPY NUMBER,
   x_q_total_adjusted_amount          OUT NOCOPY NUMBER,
   x_q_total_adjusted_percent         OUT NOCOPY NUMBER,
   x_q_total_tax                      OUT NOCOPY NUMBER,
   x_q_total_shipping_charge          OUT NOCOPY NUMBER,
   x_q_surcharge                      OUT NOCOPY NUMBER,
   x_q_total_quote_price              OUT NOCOPY NUMBER,
   x_q_payment_amount                 OUT NOCOPY NUMBER,
   x_q_accounting_rule_id             OUT NOCOPY NUMBER,
   x_q_exchange_rate                  OUT NOCOPY NUMBER,
   x_q_exchange_type_code             OUT NOCOPY VARCHAR2,
   x_q_exchange_rate_date             OUT NOCOPY DATE,
   x_q_quote_category_code            OUT NOCOPY VARCHAR2,
   x_q_quote_status_code              OUT NOCOPY VARCHAR2,
   x_q_quote_status                   OUT NOCOPY VARCHAR2,
   x_q_employee_person_id             OUT NOCOPY NUMBER,
   x_q_sales_channel_code             OUT NOCOPY VARCHAR2,
   x_q_salesrep_first_name            OUT NOCOPY VARCHAR2,
   x_q_salesrep_last_name             OUT NOCOPY VARCHAR2,
   x_q_attribute_category             OUT NOCOPY VARCHAR2,
   x_q_attribute1                     OUT NOCOPY VARCHAR2,
   x_q_attribute10                    OUT NOCOPY VARCHAR2,
   x_q_attribute11                    OUT NOCOPY VARCHAR2,
   x_q_attribute12                    OUT NOCOPY VARCHAR2,
   x_q_attribute13                    OUT NOCOPY VARCHAR2,
   x_q_attribute14                    OUT NOCOPY VARCHAR2,
   x_q_attribute15                    OUT NOCOPY VARCHAR2,
   x_q_attribute16                    OUT NOCOPY VARCHAR2,
   x_q_attribute17                    OUT NOCOPY VARCHAR2,
   x_q_attribute18                    OUT NOCOPY VARCHAR2,
   x_q_attribute19                    OUT NOCOPY VARCHAR2,
   x_q_attribute20                    OUT NOCOPY VARCHAR2,
   x_q_attribute2                     OUT NOCOPY VARCHAR2,
   x_q_attribute3                     OUT NOCOPY VARCHAR2,
   x_q_attribute4                     OUT NOCOPY VARCHAR2,
   x_q_attribute5                     OUT NOCOPY VARCHAR2,
   x_q_attribute6                     OUT NOCOPY VARCHAR2,
   x_q_attribute7                     OUT NOCOPY VARCHAR2,
   x_q_attribute8                     OUT NOCOPY VARCHAR2,
   x_q_attribute9                     OUT NOCOPY VARCHAR2,
   x_q_contract_id                    OUT NOCOPY NUMBER,
   x_q_qte_contract_id                OUT NOCOPY NUMBER,
   x_q_ffm_request_id                 OUT NOCOPY NUMBER,
   x_q_invoice_to_address1            OUT NOCOPY VARCHAR2,
   x_q_invoice_to_address2            OUT NOCOPY VARCHAR2,
   x_q_invoice_to_address3            OUT NOCOPY VARCHAR2,
   x_q_invoice_to_address4            OUT NOCOPY VARCHAR2,
   x_q_invoice_to_city                OUT NOCOPY VARCHAR2,
   x_q_invoice_to_cont_first_name     OUT NOCOPY VARCHAR2,
   x_q_invoice_to_cont_last_name      OUT NOCOPY VARCHAR2,
   x_q_invoice_to_cont_mid_name       OUT NOCOPY VARCHAR2,
   x_q_invoice_to_country_code        OUT NOCOPY VARCHAR2,
   x_q_invoice_to_country             OUT NOCOPY VARCHAR2,
   x_q_invoice_to_county              OUT NOCOPY VARCHAR2,
   x_q_invoice_to_party_id            OUT NOCOPY NUMBER,
   x_q_invoice_to_party_name          OUT NOCOPY VARCHAR2,
   x_q_invoice_to_party_site_id       OUT NOCOPY NUMBER,
   x_q_invoice_to_postal_code         OUT NOCOPY VARCHAR2,
   x_q_invoice_to_province            OUT NOCOPY VARCHAR2,
   x_q_invoice_to_state               OUT NOCOPY VARCHAR2,
   x_q_invoicing_rule_id              OUT NOCOPY NUMBER,
   x_q_marketing_source_code_id       OUT NOCOPY NUMBER,
   x_q_marketing_source_code          OUT NOCOPY VARCHAR2,
   x_q_marketing_source_name          OUT NOCOPY VARCHAR2,
   x_q_orig_mktg_source_code_id       OUT NOCOPY NUMBER,
   x_q_order_type_id                  OUT NOCOPY NUMBER,
   x_q_order_id                       OUT NOCOPY NUMBER,
   x_q_order_number                   OUT NOCOPY NUMBER,
   x_q_order_type_name                OUT NOCOPY VARCHAR2,
   x_q_ordered_date                   OUT NOCOPY DATE,
   x_q_resource_id                    OUT NOCOPY NUMBER,
   x_q_contract_template_id           OUT NOCOPY NUMBER,
   x_q_contract_template_maj_ver      OUT NOCOPY NUMBER,
   x_q_contract_requester_id          OUT NOCOPY NUMBER,
   x_q_contract_approval_level        OUT NOCOPY VARCHAR2,
   x_q_publish_flag                   OUT NOCOPY VARCHAR2,
   x_q_resource_grp_id                OUT NOCOPY NUMBER,
   x_q_sold_to_party_site_id          OUT NOCOPY NUMBER,
   x_q_display_arithmetic_op          OUT NOCOPY VARCHAR2,
   x_q_quote_description              OUT NOCOPY VARCHAR2,
   x_q_quote_type                     OUT NOCOPY VARCHAR2,
   x_q_minisite_id                    OUT NOCOPY NUMBER,
   x_q_cust_party_id                  OUT NOCOPY NUMBER,
   x_q_invoice_to_cust_party_id       OUT NOCOPY NUMBER,
   x_q_pricing_status_indicator       OUT NOCOPY VARCHAR2,
   x_q_tax_status_indicator           OUT NOCOPY VARCHAR2,
   x_q_price_updated_date             OUT NOCOPY DATE,
   x_q_tax_updated_date               OUT NOCOPY DATE,
   x_q_recalculate_flag               OUT NOCOPY VARCHAR2,
   x_q_price_request_id               OUT NOCOPY NUMBER,
   x_q_credit_update_date             OUT NOCOPY DATE,
   x_q_customer_name_and_title    	  OUT NOCOPY VARCHAR2,
   x_q_customer_signature_date    	  OUT NOCOPY DATE,
   x_q_supplier_name_and_title    	  OUT NOCOPY VARCHAR2,
   x_q_supplier_signature_date    	  OUT NOCOPY DATE,
   x_q_end_cust_party_id              OUT NOCOPY NUMBER,
   x_q_end_cust_party_site_id         OUT NOCOPY NUMBER,
   x_q_end_cust_cust_account_id       OUT NOCOPY NUMBER,
   x_q_end_cust_cust_party_id         OUT NOCOPY NUMBER,
   x_q_automatic_price_flag           OUT NOCOPY VARCHAR2,
   x_q_automatic_tax_flag             OUT NOCOPY VARCHAR2,
   x_q_assistance_requested           OUT NOCOPY VARCHAR2,
   x_q_assistance_reason_code         OUT NOCOPY VARCHAR2,
   x_q_object_version_number          OUT NOCOPY NUMBER,
   x_q_header_paynow_charges          OUT NOCOPY NUMBER,
   x_q_prod_FISC_classification       OUT NOCOPY VARCHAR2,
   x_q_TRX_business_category          OUT NOCOPY VARCHAR2

   ) is
   Begin
   x_q_quote_header_id                :=  p_qte_header_rec.quote_header_id;
   x_q_creation_date                  :=  p_qte_header_rec.creation_date;
   x_q_created_by                     :=  p_qte_header_rec.created_by;
   x_q_last_updated_by                :=  p_qte_header_rec.last_updated_by;
   x_q_last_update_date               :=  p_qte_header_rec.last_update_date ;
   x_q_last_update_login              :=  p_qte_header_rec.last_update_login;
   x_q_request_id                     :=  p_qte_header_rec.request_id;
   x_q_program_application_id         :=  p_qte_header_rec.program_application_id;
   x_q_program_id                     :=  p_qte_header_rec.program_id;
   x_q_program_update_date            :=  p_qte_header_rec.program_update_date;
   x_q_org_id                         :=  p_qte_header_rec.org_id;
   x_q_quote_name                     :=  p_qte_header_rec.quote_name;
   x_q_quote_number                   :=  p_qte_header_rec.quote_number;
   x_q_quote_version                  :=  p_qte_header_rec.quote_version;
   x_q_quote_status_id                :=  p_qte_header_rec.quote_status_id;
   x_q_quote_source_code              :=  p_qte_header_rec.quote_source_code;
   x_q_quote_expiration_date          :=  p_qte_header_rec.quote_expiration_date;
   x_q_price_frozen_date              :=  p_qte_header_rec.price_frozen_date;
   x_q_quote_password                 :=  p_qte_header_rec.quote_password ;
   x_q_original_system_reference      :=  p_qte_header_rec.original_system_reference;
   x_q_party_id                       :=  p_qte_header_rec.party_id;
   x_q_cust_account_id                :=  p_qte_header_rec.cust_account_id;
   x_q_invoice_to_cust_acct_id        :=  p_qte_header_rec.invoice_to_cust_account_id;
   x_q_org_contact_id                 :=  p_qte_header_rec.org_contact_id;
   x_q_party_name                     :=  p_qte_header_rec.party_name;
   x_q_party_type                     :=  p_qte_header_rec.party_type;
   x_q_person_first_name              :=  p_qte_header_rec.person_first_name;
   x_q_person_last_name               :=  p_qte_header_rec.person_last_name;
   x_q_person_middle_name             :=  p_qte_header_rec.person_middle_name;
   x_q_phone_id                       :=  p_qte_header_rec.phone_id;
   x_q_price_list_id                  :=  p_qte_header_rec.price_list_id;
   x_q_price_list_name                :=  p_qte_header_rec.price_list_name;
   x_q_currency_code                  :=  p_qte_header_rec.currency_code ;
   x_q_total_list_price               :=  p_qte_header_rec.total_list_price;
   x_q_total_adjusted_amount          :=  p_qte_header_rec.total_adjusted_amount;
   x_q_total_adjusted_percent         :=  p_qte_header_rec.total_adjusted_percent ;
   x_q_total_tax                      :=  p_qte_header_rec.total_tax;
   x_q_total_shipping_charge          :=  p_qte_header_rec.total_shipping_charge;
   x_q_surcharge                      :=  p_qte_header_rec.surcharge;
   x_q_total_quote_price              :=  p_qte_header_rec.total_quote_price;
   x_q_payment_amount                 :=  p_qte_header_rec.payment_amount;
   x_q_accounting_rule_id             :=  p_qte_header_rec.accounting_rule_id ;
   x_q_exchange_rate                  :=  p_qte_header_rec.exchange_rate;
   x_q_exchange_type_code             :=  p_qte_header_rec.exchange_type_code ;
   x_q_exchange_rate_date             :=  p_qte_header_rec.exchange_rate_date;
   x_q_quote_category_code            :=  p_qte_header_rec.quote_category_code;
   x_q_quote_status_code              :=  p_qte_header_rec.quote_status_code;
   x_q_quote_status                   :=  p_qte_header_rec.quote_status;
   x_q_employee_person_id             :=  p_qte_header_rec.employee_person_id;
   x_q_sales_channel_code             :=  p_qte_header_rec.sales_channel_code;
   x_q_salesrep_first_name            :=  p_qte_header_rec.salesrep_first_name;
   x_q_salesrep_last_name             :=  p_qte_header_rec.salesrep_last_name;
   x_q_attribute_category             :=  p_qte_header_rec.attribute_category;
   x_q_attribute1                     :=  p_qte_header_rec.attribute1;
   x_q_attribute10                    :=  p_qte_header_rec.attribute10;
   x_q_attribute11                    :=  p_qte_header_rec.attribute11;
   x_q_attribute12                    :=  p_qte_header_rec.attribute12;
   x_q_attribute13                    :=  p_qte_header_rec.attribute13;
   x_q_attribute14                    :=  p_qte_header_rec.attribute14;
   x_q_attribute15                    :=  p_qte_header_rec.attribute15;
   x_q_attribute16                    :=  p_qte_header_rec.attribute16;
   x_q_attribute17                    :=  p_qte_header_rec.attribute17;
   x_q_attribute18                    :=  p_qte_header_rec.attribute18;
   x_q_attribute19                    :=  p_qte_header_rec.attribute19;
   x_q_attribute20                    :=  p_qte_header_rec.attribute20;
   x_q_attribute2                     :=  p_qte_header_rec.attribute2;
   x_q_attribute3                     :=  p_qte_header_rec.attribute3;
   x_q_attribute4                     :=  p_qte_header_rec.attribute4;
   x_q_attribute5                     :=  p_qte_header_rec.attribute5;
   x_q_attribute6                     :=  p_qte_header_rec.attribute6;
   x_q_attribute7                     :=  p_qte_header_rec.attribute7;
   x_q_attribute8                     :=  p_qte_header_rec.attribute8;
   x_q_attribute9                     :=  p_qte_header_rec.attribute9;
   x_q_contract_id                    :=  p_qte_header_rec.contract_id;
   x_q_qte_contract_id                :=  p_qte_header_rec.ffm_request_id;
   x_q_ffm_request_id                 :=  p_qte_header_rec.ffm_request_id;
   x_q_invoice_to_address1            :=  p_qte_header_rec.invoice_to_address1;
   x_q_invoice_to_address2            :=  p_qte_header_rec.invoice_to_address2;
   x_q_invoice_to_address3            :=  p_qte_header_rec.invoice_to_address3;
   x_q_invoice_to_address4            :=  p_qte_header_rec.invoice_to_address4;
   x_q_invoice_to_city                :=  p_qte_header_rec.invoice_to_city;
   x_q_invoice_to_cont_first_name     :=  p_qte_header_rec.invoice_to_contact_first_name;
   x_q_invoice_to_cont_last_name      :=  p_qte_header_rec.invoice_to_contact_last_name;
   x_q_invoice_to_cont_mid_name       :=  p_qte_header_rec.invoice_to_contact_middle_name;
   x_q_invoice_to_country_code        :=  p_qte_header_rec.invoice_to_country_code;
   x_q_invoice_to_country             :=  p_qte_header_rec.invoice_to_country ;
   x_q_invoice_to_county              :=  p_qte_header_rec.invoice_to_county;
   x_q_invoice_to_party_id            :=  p_qte_header_rec.invoice_to_party_id;
   x_q_invoice_to_party_name          :=  p_qte_header_rec.invoice_to_party_name;
   x_q_invoice_to_party_site_id       :=  p_qte_header_rec.invoice_to_party_site_id;
   x_q_invoice_to_postal_code         :=  p_qte_header_rec.invoice_to_postal_code;
   x_q_invoice_to_province            :=  p_qte_header_rec.invoice_to_province ;
   x_q_invoice_to_state               :=  p_qte_header_rec.invoice_to_state;
   x_q_invoicing_rule_id              :=  p_qte_header_rec.invoicing_rule_id;
   x_q_marketing_source_code_id       :=  p_qte_header_rec.marketing_source_code_id;
   x_q_marketing_source_code          :=  p_qte_header_rec.marketing_source_code;
   x_q_marketing_source_name          :=  p_qte_header_rec.marketing_source_name;
   x_q_orig_mktg_source_code_id       :=  p_qte_header_rec.orig_mktg_source_code_id ;
   x_q_order_type_id                  :=  p_qte_header_rec.order_type_id;
   x_q_order_id                       :=  p_qte_header_rec.order_id;
   x_q_order_number                   :=  p_qte_header_rec.order_number;
   x_q_order_type_name                :=  p_qte_header_rec.order_type_name;
   x_q_ordered_date                   :=  p_qte_header_rec.ordered_date;
   x_q_resource_id                    :=  p_qte_header_rec.resource_id;
   x_q_contract_template_id           :=  p_qte_header_rec.contract_template_id;
   x_q_contract_template_maj_ver      :=  p_qte_header_rec.contract_template_major_ver;
   x_q_contract_requester_id          :=  p_qte_header_rec.contract_requester_id;
   x_q_contract_approval_level        :=  p_qte_header_rec.contract_approval_level;
   x_q_publish_flag                   :=  p_qte_header_rec.publish_flag;
   x_q_resource_grp_id                :=  p_qte_header_rec.resource_grp_id;
   x_q_sold_to_party_site_id          :=  p_qte_header_rec.sold_to_party_site_id;
   x_q_display_arithmetic_op          :=  p_qte_header_rec.display_arithmetic_operator;
   x_q_quote_description              :=  p_qte_header_rec.quote_description;
   x_q_quote_type                     :=  p_qte_header_rec.quote_type;
   x_q_minisite_id                    :=  p_qte_header_rec.minisite_id;
   x_q_cust_party_id                  :=  p_qte_header_rec.cust_party_id ;
   x_q_invoice_to_cust_party_id       :=  p_qte_header_rec.invoice_to_cust_party_id;
   x_q_pricing_status_indicator       :=  p_qte_header_rec.pricing_status_indicator;
   x_q_tax_status_indicator           :=  p_qte_header_rec.tax_status_indicator;
   x_q_price_updated_date             :=  p_qte_header_rec.price_updated_date;
   x_q_tax_updated_date               :=  p_qte_header_rec.tax_updated_date;
   x_q_recalculate_flag               :=  p_qte_header_rec.recalculate_flag;
   x_q_price_request_id               :=  p_qte_header_rec.price_request_id;
   x_q_credit_update_date             :=  p_qte_header_rec.credit_update_date;
   x_q_customer_name_and_title    	  :=  p_qte_header_rec.customer_name_and_title;
   x_q_customer_signature_date    	  :=  p_qte_header_rec.customer_signature_date;
   x_q_supplier_name_and_title    	  :=  p_qte_header_rec.supplier_name_and_title;
   x_q_supplier_signature_date    	  :=  p_qte_header_rec.supplier_signature_date;
   x_q_end_cust_party_id              :=  p_qte_header_rec.end_customer_party_id;
   x_q_end_cust_party_site_id         :=  p_qte_header_rec.end_customer_party_site_id;
   x_q_end_cust_cust_account_id       :=  p_qte_header_rec.end_customer_cust_account_id;
   x_q_end_cust_cust_party_id         :=  p_qte_header_rec.end_customer_cust_party_id;
   x_q_automatic_price_flag           :=  p_qte_header_rec.automatic_price_flag;
   x_q_automatic_tax_flag             :=  p_qte_header_rec.automatic_tax_flag;
   x_q_assistance_requested           :=  p_qte_header_rec.assistance_requested;
   x_q_assistance_reason_code         :=  p_qte_header_rec.assistance_reason_code;
   x_q_object_version_number          :=  p_qte_header_rec.object_version_number;
   x_q_header_paynow_charges          :=  p_qte_header_rec.header_paynow_charges;
   x_q_prod_FISC_classification       :=  p_qte_header_rec.product_FISC_classification;
   x_q_TRX_business_category          :=  p_qte_header_rec.TRX_business_category;
   end;

   PROCEDURE Set_Shipment_rec_Out(
   p_shipment_rec                     IN  ASO_Quote_Pub.Shipment_rec_Type,
   x_qs_operation_code                OUT NOCOPY VARCHAR2,
   x_qs_qte_line_index                OUT NOCOPY NUMBER,
   x_qs_shipment_id                   OUT NOCOPY NUMBER,
   x_qs_creation_date                 OUT NOCOPY DATE,
   x_qs_created_by                    OUT NOCOPY NUMBER,
   x_qs_last_update_date              OUT NOCOPY DATE,
   x_qs_last_updated_by               OUT NOCOPY NUMBER,
   x_qs_last_update_login             OUT NOCOPY NUMBER,
   x_qs_request_id                    OUT NOCOPY NUMBER,
   x_qs_program_application_id        OUT NOCOPY NUMBER,
   x_qs_program_id                    OUT NOCOPY NUMBER,
   x_qs_program_update_date           OUT NOCOPY DATE,
   x_qs_quote_header_id               OUT NOCOPY NUMBER,
   x_qs_quote_line_id                 OUT NOCOPY NUMBER,
   x_qs_promise_date                  OUT NOCOPY DATE,
   x_qs_request_date                  OUT NOCOPY DATE,
   x_qs_schedule_ship_date            OUT NOCOPY DATE,
   x_qs_ship_to_party_site_id         OUT NOCOPY NUMBER,
   x_qs_ship_to_party_id              OUT NOCOPY NUMBER,
   x_qs_ship_to_cust_account_id       OUT NOCOPY NUMBER,
   x_qs_ship_partial_flag             OUT NOCOPY VARCHAR2,
   x_qs_ship_set_id                   OUT NOCOPY NUMBER,
   x_qs_ship_method_code              OUT NOCOPY VARCHAR2,
   x_qs_freight_terms_code            OUT NOCOPY VARCHAR2,
   x_qs_freight_carrier_code          OUT NOCOPY VARCHAR2,
   x_qs_fob_code                      OUT NOCOPY VARCHAR2,
   x_qs_shipping_instructions         OUT NOCOPY VARCHAR2,
   x_qs_packing_instructions          OUT NOCOPY VARCHAR2,
   x_qs_quantity                      OUT NOCOPY NUMBER,
   x_qs_reserved_quantity             OUT NOCOPY VARCHAR2,
   x_qs_reservation_id                OUT NOCOPY NUMBER,
   x_qs_order_line_id                 OUT NOCOPY NUMBER,
   x_qs_ship_to_party_name            OUT NOCOPY VARCHAR2,
   x_qs_ship_to_cont_first_name       OUT NOCOPY VARCHAR2,
   x_qs_ship_to_cont_mid_name         OUT NOCOPY VARCHAR2,
   x_qs_ship_to_cont_last_name        OUT NOCOPY VARCHAR2,
   x_qs_ship_to_address1              OUT NOCOPY VARCHAR2,
   x_qs_ship_to_address2              OUT NOCOPY VARCHAR2,
   x_qs_ship_to_address3              OUT NOCOPY VARCHAR2,
   x_qs_ship_to_address4              OUT NOCOPY VARCHAR2,
   x_qs_ship_to_country_code          OUT NOCOPY VARCHAR2,
   x_qs_ship_to_country               OUT NOCOPY VARCHAR2,
   x_qs_ship_to_city                  OUT NOCOPY VARCHAR2,
   x_qs_ship_to_postal_code           OUT NOCOPY VARCHAR2,
   x_qs_ship_to_state                 OUT NOCOPY VARCHAR2,
   x_qs_ship_to_province              OUT NOCOPY VARCHAR2,
   x_qs_ship_to_county                OUT NOCOPY VARCHAR2,
   x_qs_attribute_category            OUT NOCOPY VARCHAR2,
   x_qs_attribute1                    OUT NOCOPY VARCHAR2,
   x_qs_attribute2                    OUT NOCOPY VARCHAR2,
   x_qs_attribute3                    OUT NOCOPY VARCHAR2,
   x_qs_attribute4                    OUT NOCOPY VARCHAR2,
   x_qs_attribute5                    OUT NOCOPY VARCHAR2,
   x_qs_attribute6                    OUT NOCOPY VARCHAR2,
   x_qs_attribute7                    OUT NOCOPY VARCHAR2,
   x_qs_attribute8                    OUT NOCOPY VARCHAR2,
   x_qs_attribute9                    OUT NOCOPY VARCHAR2,
   x_qs_attribute10                   OUT NOCOPY VARCHAR2,
   x_qs_attribute11                   OUT NOCOPY VARCHAR2,
   x_qs_attribute12                   OUT NOCOPY VARCHAR2,
   x_qs_attribute13                   OUT NOCOPY VARCHAR2,
   x_qs_attribute14                   OUT NOCOPY VARCHAR2,
   x_qs_attribute15                   OUT NOCOPY VARCHAR2,
   x_qs_attribute16                   OUT NOCOPY VARCHAR2,
   x_qs_attribute17                   OUT NOCOPY VARCHAR2,
   x_qs_attribute18                   OUT NOCOPY VARCHAR2,
   x_qs_attribute19                   OUT NOCOPY VARCHAR2,
   x_qs_attribute20                   OUT NOCOPY VARCHAR2,
   x_qs_ship_quote_price              OUT NOCOPY NUMBER,
   x_qs_pricing_quantity              OUT NOCOPY NUMBER,
   x_qs_shipment_priority_code        OUT NOCOPY VARCHAR2,
   x_qs_ship_from_org_id              OUT NOCOPY NUMBER,
   x_qs_ship_to_cust_party_id         OUT NOCOPY NUMBER,
   x_qs_request_date_type             OUT NOCOPY VARCHAR2,
   x_qs_demand_class_code             OUT NOCOPY VARCHAR2,
   x_qs_object_version_number         OUT NOCOPY NUMBER
   )is
   Begin
   x_qs_operation_code                :=  p_shipment_rec.operation_code;
   x_qs_qte_line_index                :=  p_shipment_rec.qte_line_index ;
   x_qs_shipment_id                   :=  p_shipment_rec.shipment_id;
   x_qs_creation_date                 :=  p_shipment_rec.creation_date;
   x_qs_created_by                    :=  p_shipment_rec.created_by;
   x_qs_last_update_date              :=  p_shipment_rec.last_update_date;
   x_qs_last_updated_by               :=  p_shipment_rec.last_updated_by;
   x_qs_last_update_login             :=  p_shipment_rec.last_update_login;
   x_qs_request_id                    :=  p_shipment_rec.request_id;
   x_qs_program_application_id        :=  p_shipment_rec.program_application_id;
   x_qs_program_id                    :=  p_shipment_rec.program_id;
   x_qs_program_update_date           :=  p_shipment_rec.program_update_date;
   x_qs_quote_header_id               :=  p_shipment_rec.quote_header_id;
   x_qs_quote_line_id                 :=  p_shipment_rec.quote_line_id;
   x_qs_promise_date                  :=  p_shipment_rec.promise_date;
   x_qs_request_date                  :=  p_shipment_rec.request_date;
   x_qs_schedule_ship_date            :=  p_shipment_rec.schedule_ship_date;
   x_qs_ship_to_party_site_id         :=  p_shipment_rec.ship_to_party_site_id;
   x_qs_ship_to_party_id              :=  p_shipment_rec.ship_to_party_id;
   x_qs_ship_to_cust_account_id       :=  p_shipment_rec.ship_to_cust_account_id;
   x_qs_ship_partial_flag             :=  p_shipment_rec.ship_partial_flag;
   x_qs_ship_set_id                   :=  p_shipment_rec.ship_set_id;
   x_qs_ship_method_code              :=  p_shipment_rec.ship_method_code;
   x_qs_freight_terms_code            :=  p_shipment_rec.freight_terms_code;
   x_qs_freight_carrier_code          :=  p_shipment_rec.freight_carrier_code;
   x_qs_fob_code                      :=  p_shipment_rec.fob_code;
   x_qs_shipping_instructions         :=  p_shipment_rec.shipping_instructions;
   x_qs_packing_instructions          :=  p_shipment_rec.packing_instructions;
   x_qs_quantity                      :=  p_shipment_rec.quantity;
   x_qs_reserved_quantity             :=  p_shipment_rec.reserved_quantity;
   x_qs_reservation_id                :=  p_shipment_rec.reservation_id;
   x_qs_order_line_id                 :=  p_shipment_rec.order_line_id;
   x_qs_ship_to_party_name            :=  p_shipment_rec.ship_to_party_name;
   x_qs_ship_to_cont_first_name       :=  p_shipment_rec.ship_to_contact_first_name;
   x_qs_ship_to_cont_mid_name         :=  p_shipment_rec.ship_to_contact_middle_name;
   x_qs_ship_to_cont_last_name        :=  p_shipment_rec.ship_to_contact_last_name;
   x_qs_ship_to_address1              :=  p_shipment_rec.ship_to_address1;
   x_qs_ship_to_address2              :=  p_shipment_rec.ship_to_address2;
   x_qs_ship_to_address3              :=  p_shipment_rec.ship_to_address3;
   x_qs_ship_to_address4              :=  p_shipment_rec.ship_to_address4;
   x_qs_ship_to_country_code          :=  p_shipment_rec.ship_to_country_code;
   x_qs_ship_to_country               :=  p_shipment_rec.ship_to_country ;
   x_qs_ship_to_city                  :=  p_shipment_rec.ship_to_city;
   x_qs_ship_to_postal_code           :=  p_shipment_rec.ship_to_postal_code;
   x_qs_ship_to_state                 :=  p_shipment_rec.ship_to_state;
   x_qs_ship_to_province              :=  p_shipment_rec.ship_to_province;
   x_qs_ship_to_county                :=  p_shipment_rec.ship_to_county;
   x_qs_attribute_category            :=  p_shipment_rec.attribute_category;
   x_qs_attribute1                    :=  p_shipment_rec.attribute1;
   x_qs_attribute2                    :=  p_shipment_rec.attribute2;
   x_qs_attribute3                    :=  p_shipment_rec.attribute3;
   x_qs_attribute4                    :=  p_shipment_rec.attribute4;
   x_qs_attribute5                    :=  p_shipment_rec.attribute5;
   x_qs_attribute6                    :=  p_shipment_rec.attribute6;
   x_qs_attribute7                    :=  p_shipment_rec.attribute7;
   x_qs_attribute8                    :=  p_shipment_rec.attribute8;
   x_qs_attribute9                    :=  p_shipment_rec.attribute9;
   x_qs_attribute10                   :=  p_shipment_rec.attribute10;
   x_qs_attribute11                   :=  p_shipment_rec.attribute11;
   x_qs_attribute12                   :=  p_shipment_rec.attribute12;
   x_qs_attribute13                   :=  p_shipment_rec.attribute13;
   x_qs_attribute14                   :=  p_shipment_rec.attribute14;
   x_qs_attribute15                   :=  p_shipment_rec.attribute15;
   x_qs_attribute16                   :=  p_shipment_rec.attribute16;
   x_qs_attribute17                   :=  p_shipment_rec.attribute17;
   x_qs_attribute18                   :=  p_shipment_rec.attribute18;
   x_qs_attribute19                   :=  p_shipment_rec.attribute19;
   x_qs_attribute20                   :=  p_shipment_rec.attribute20;
   x_qs_ship_quote_price              :=  p_shipment_rec.ship_quote_price;
   x_qs_pricing_quantity              :=  p_shipment_rec.pricing_quantity;
   x_qs_shipment_priority_code        :=  p_shipment_rec.shipment_priority_code;
   x_qs_ship_from_org_id              :=  p_shipment_rec.ship_from_org_id;
   x_qs_ship_to_cust_party_id         :=  p_shipment_rec.ship_to_cust_party_id;
   x_qs_request_date_type             :=  p_shipment_rec.request_date_type;
   x_qs_demand_class_code             :=  p_shipment_rec.demand_class_code;
   x_qs_object_version_number         :=  p_shipment_rec.object_version_number;
   end;


   PROCEDURE Set_Payment_rec_Out(
   p_payment_rec                      IN  ASO_Quote_Pub.Payment_rec_Type,
   x_qp_operation_code                OUT NOCOPY VARCHAR2,
   x_qp_qte_line_index                OUT NOCOPY NUMBER,
   x_qp_payment_id                    OUT NOCOPY NUMBER,
   x_qp_creation_date                 OUT NOCOPY DATE,
   x_qp_created_by                    OUT NOCOPY NUMBER,
   x_qp_last_update_date              OUT NOCOPY DATE,
   x_qp_last_updated_by               OUT NOCOPY NUMBER,
   x_qp_last_update_login             OUT NOCOPY NUMBER,
   x_qp_request_id                    OUT NOCOPY NUMBER,
   x_qp_program_application_id        OUT NOCOPY NUMBER,
   x_qp_program_id                    OUT NOCOPY NUMBER,
   x_qp_program_update_date           OUT NOCOPY DATE,
   x_qp_quote_header_id               OUT NOCOPY NUMBER,
   x_qp_quote_line_id                 OUT NOCOPY NUMBER,
   x_qp_payment_type_code             OUT NOCOPY VARCHAR2,
   x_qp_payment_ref_number            OUT NOCOPY VARCHAR2,
   x_qp_payment_option                OUT NOCOPY VARCHAR2,
   x_qp_payment_term_id               OUT NOCOPY NUMBER,
   x_qp_credit_card_code              OUT NOCOPY VARCHAR2,
   x_qp_credit_card_holder_name       OUT NOCOPY VARCHAR2,
   x_qp_credit_card_exp_date          OUT NOCOPY DATE,
   x_qp_credit_card_aprv_code         OUT NOCOPY VARCHAR2,
   x_qp_credit_card_aprv_date         OUT NOCOPY DATE,
   x_qp_payment_amount                OUT NOCOPY NUMBER,
   x_qp_attribute_category            OUT NOCOPY VARCHAR2,
   x_qp_attribute1                    OUT NOCOPY VARCHAR2,
   x_qp_attribute2                    OUT NOCOPY VARCHAR2,
   x_qp_attribute3                    OUT NOCOPY VARCHAR2,
   x_qp_attribute4                    OUT NOCOPY VARCHAR2,
   x_qp_attribute5                    OUT NOCOPY VARCHAR2,
   x_qp_attribute6                    OUT NOCOPY VARCHAR2,
   x_qp_attribute7                    OUT NOCOPY VARCHAR2,
   x_qp_attribute8                    OUT NOCOPY VARCHAR2,
   x_qp_attribute9                    OUT NOCOPY VARCHAR2,
   x_qp_attribute10                   OUT NOCOPY VARCHAR2,
   x_qp_attribute11                   OUT NOCOPY VARCHAR2,
   x_qp_attribute12                   OUT NOCOPY VARCHAR2,
   x_qp_attribute13                   OUT NOCOPY VARCHAR2,
   x_qp_attribute14                   OUT NOCOPY VARCHAR2,
   x_qp_attribute15                   OUT NOCOPY VARCHAR2,
   x_qp_attribute16                   OUT NOCOPY VARCHAR2,
   x_qp_attribute17                   OUT NOCOPY VARCHAR2,
   x_qp_attribute18                   OUT NOCOPY VARCHAR2,
   x_qp_attribute19                   OUT NOCOPY VARCHAR2,
   x_qp_attribute20                   OUT NOCOPY VARCHAR2,
   x_qp_shipment_index                OUT NOCOPY NUMBER,
   x_qp_quote_shipment_id             OUT NOCOPY NUMBER,
   x_qp_cust_po_number                OUT NOCOPY VARCHAR2,
   x_qp_cust_po_line_number           OUT NOCOPY VARCHAR2,
   x_qp_object_version_number         OUT NOCOPY NUMBER,
   x_qp_trxn_extension_id             OUT NOCOPY NUMBER,
   x_qp_instrument_id                 OUT NOCOPY NUMBER,
   x_qp_instr_assignment_id           OUT NOCOPY NUMBER,
   x_qp_cvv2                          OUT NOCOPY VARCHAR2
   )is
   Begin
   x_qp_operation_code                :=  p_payment_rec.operation_code;
   x_qp_qte_line_index                :=  p_payment_rec.qte_line_index ;
   x_qp_payment_id                    :=  p_payment_rec.payment_id;
   x_qp_creation_date                 :=  p_payment_rec.creation_date;
   x_qp_created_by                    :=  p_payment_rec.created_by;
   x_qp_last_update_date              :=  p_payment_rec.last_update_date;
   x_qp_last_updated_by               :=  p_payment_rec.last_updated_by;
   x_qp_last_update_login             :=  p_payment_rec.last_update_login ;
   x_qp_request_id                    :=  p_payment_rec.request_id;
   x_qp_program_application_id        :=  p_payment_rec.program_application_id;
   x_qp_program_id                    :=  p_payment_rec.program_id;
   x_qp_program_update_date           :=  p_payment_rec.program_update_date;
   x_qp_quote_header_id               :=  p_payment_rec.quote_header_id;
   x_qp_quote_line_id                 :=  p_payment_rec.quote_line_id;
   x_qp_payment_type_code             :=  p_payment_rec.payment_type_code;
   x_qp_payment_ref_number            :=  p_payment_rec.payment_ref_number;
   x_qp_payment_option                :=  p_payment_rec.payment_option;
   x_qp_payment_term_id               :=  p_payment_rec.payment_term_id;
   x_qp_credit_card_code              :=  p_payment_rec.credit_card_code;
   x_qp_credit_card_holder_name       :=  p_payment_rec.credit_card_holder_name;
   x_qp_credit_card_exp_date          :=  p_payment_rec.credit_card_expiration_date;
   x_qp_credit_card_aprv_code         :=  p_payment_rec.credit_card_approval_code;
   x_qp_credit_card_aprv_date         :=  p_payment_rec.credit_card_approval_date;
   x_qp_payment_amount                :=  p_payment_rec.payment_amount;
   x_qp_attribute_category            :=  p_payment_rec.attribute_category;
   x_qp_attribute1                    :=  p_payment_rec.attribute1;
   x_qp_attribute2                    :=  p_payment_rec.attribute2;
   x_qp_attribute3                    :=  p_payment_rec.attribute3;
   x_qp_attribute4                    :=  p_payment_rec.attribute4;
   x_qp_attribute5                    :=  p_payment_rec.attribute5;
   x_qp_attribute6                    :=  p_payment_rec.attribute6;
   x_qp_attribute7                    :=  p_payment_rec.attribute7;
   x_qp_attribute8                    :=  p_payment_rec.attribute8;
   x_qp_attribute9                    :=  p_payment_rec.attribute9;
   x_qp_attribute10                   :=  p_payment_rec.attribute10;
   x_qp_attribute11                   :=  p_payment_rec.attribute11;
   x_qp_attribute12                   :=  p_payment_rec.attribute12;
   x_qp_attribute13                   :=  p_payment_rec.attribute13;
   x_qp_attribute14                   :=  p_payment_rec.attribute14;
   x_qp_attribute15                   :=  p_payment_rec.attribute15;
   x_qp_attribute16                   :=  p_payment_rec.attribute16;
   x_qp_attribute17                   :=  p_payment_rec.attribute17;
   x_qp_attribute18                   :=  p_payment_rec.attribute18;
   x_qp_attribute19                   :=  p_payment_rec.attribute19;
   x_qp_attribute20                   :=  p_payment_rec.attribute20;
   x_qp_shipment_index                :=  p_payment_rec.shipment_index;
   x_qp_quote_shipment_id             :=  p_payment_rec.quote_shipment_id;
   x_qp_cust_po_number                :=  p_payment_rec.cust_po_number;
   x_qp_cust_po_line_number           :=  p_payment_rec.cust_po_line_number;
   x_qp_object_version_number         :=  p_payment_rec.object_version_number;
   x_qp_trxn_extension_id             :=  p_payment_rec.trxn_extension_id;
   x_qp_instrument_id                 :=  p_payment_rec.instrument_id;
   x_qp_instr_assignment_id           :=  p_payment_rec.instr_assignment_id;
   x_qp_cvv2                          :=  p_payment_rec.cvv2;

   end;


   PROCEDURE Set_Tax_detail_rec_Out(
   p_tax_detail_rec                   IN  ASO_Quote_Pub.Tax_detail_rec_Type,
   x_qt_operation_code                OUT NOCOPY VARCHAR2,
   x_qt_qte_line_index                OUT NOCOPY NUMBER,
   x_qt_shipment_index                OUT NOCOPY NUMBER,
   x_qt_tax_detail_id                 OUT NOCOPY NUMBER,
   x_qt_quote_header_id               OUT NOCOPY NUMBER,
   x_qt_quote_line_id                 OUT NOCOPY NUMBER,
   x_qt_quote_shipment_id             OUT NOCOPY NUMBER,
   x_qt_creation_date                 OUT NOCOPY DATE,
   x_qt_created_by                    OUT NOCOPY NUMBER,
   x_qt_last_update_date              OUT NOCOPY DATE,
   x_qt_last_updated_by               OUT NOCOPY NUMBER,
   x_qt_last_update_login             OUT NOCOPY NUMBER,
   x_qt_request_id                    OUT NOCOPY NUMBER,
   x_qt_program_application_id        OUT NOCOPY NUMBER,
   x_qt_program_id                    OUT NOCOPY NUMBER,
   x_qt_program_update_date           OUT NOCOPY DATE,
   x_qt_orig_tax_code                 OUT NOCOPY VARCHAR2,
   x_qt_tax_code                      OUT NOCOPY VARCHAR2,
   x_qt_tax_rate                      OUT NOCOPY NUMBER,
   x_qt_tax_date                      OUT NOCOPY DATE,
   x_qt_tax_amount                    OUT NOCOPY NUMBER,
   x_qt_tax_exempt_flag               OUT NOCOPY VARCHAR2,
   x_qt_tax_exempt_number             OUT NOCOPY VARCHAR2,
   x_qt_tax_exempt_reason_code        OUT NOCOPY VARCHAR2,
   x_qt_attribute_category            OUT NOCOPY VARCHAR2,
   x_qt_attribute1                    OUT NOCOPY VARCHAR2,
   x_qt_attribute2                    OUT NOCOPY VARCHAR2,
   x_qt_attribute3                    OUT NOCOPY VARCHAR2,
   x_qt_attribute4                    OUT NOCOPY VARCHAR2,
   x_qt_attribute5                    OUT NOCOPY VARCHAR2,
   x_qt_attribute6                    OUT NOCOPY VARCHAR2,
   x_qt_attribute7                    OUT NOCOPY VARCHAR2,
   x_qt_attribute8                    OUT NOCOPY VARCHAR2,
   x_qt_attribute9                    OUT NOCOPY VARCHAR2,
   x_qt_attribute10                   OUT NOCOPY VARCHAR2,
   x_qt_attribute11                   OUT NOCOPY VARCHAR2,
   x_qt_attribute12                   OUT NOCOPY VARCHAR2,
   x_qt_attribute13                   OUT NOCOPY VARCHAR2,
   x_qt_attribute14                   OUT NOCOPY VARCHAR2,
   x_qt_attribute15                   OUT NOCOPY VARCHAR2,
   x_qt_attribute16                   OUT NOCOPY VARCHAR2,
   x_qt_attribute17                   OUT NOCOPY VARCHAR2,
   x_qt_attribute18                   OUT NOCOPY VARCHAR2,
   x_qt_attribute19                   OUT NOCOPY VARCHAR2,
   x_qt_attribute20                   OUT NOCOPY VARCHAR2,
   x_qt_object_version_number         OUT NOCOPY NUMBER,
   x_qt_tax_rate_id                   OUT NOCOPY NUMBER
   )is
   Begin
   x_qt_operation_code                :=  p_tax_detail_rec.operation_code;
   x_qt_qte_line_index                :=  p_tax_detail_rec.qte_line_index;
   x_qt_shipment_index                :=  p_tax_detail_rec.shipment_index;
   x_qt_tax_detail_id                 :=  p_tax_detail_rec.tax_detail_id;
   x_qt_quote_header_id               :=  p_tax_detail_rec.quote_header_id;
   x_qt_quote_line_id                 :=  p_tax_detail_rec.quote_line_id;
   x_qt_quote_shipment_id             :=  p_tax_detail_rec.quote_shipment_id;
   x_qt_creation_date                 :=  p_tax_detail_rec.creation_date;
   x_qt_created_by                    :=  p_tax_detail_rec.created_by;
   x_qt_last_update_date              :=  p_tax_detail_rec.last_update_date;
   x_qt_last_updated_by               :=  p_tax_detail_rec.last_updated_by ;
   x_qt_last_update_login             :=  p_tax_detail_rec.last_update_login;
   x_qt_request_id                    :=  p_tax_detail_rec.request_id;
   x_qt_program_application_id        :=  p_tax_detail_rec.program_application_id;
   x_qt_program_id                    :=  p_tax_detail_rec.program_id;
   x_qt_program_update_date           :=  p_tax_detail_rec.program_update_date;
   x_qt_orig_tax_code                 :=  p_tax_detail_rec.orig_tax_code;
   x_qt_tax_code                      :=  p_tax_detail_rec.tax_code;
   x_qt_tax_rate                      :=  p_tax_detail_rec.tax_rate;
   x_qt_tax_date                      :=  p_tax_detail_rec.tax_date;
   x_qt_tax_amount                    :=  p_tax_detail_rec.tax_amount;
   x_qt_tax_exempt_flag               :=  p_tax_detail_rec.tax_exempt_flag;
   x_qt_tax_exempt_number             :=  p_tax_detail_rec.tax_exempt_number;
   x_qt_tax_exempt_reason_code        :=  p_tax_detail_rec.tax_exempt_reason_code;
   x_qt_attribute_category            :=  p_tax_detail_rec.attribute_category;
   x_qt_attribute1                    :=  p_tax_detail_rec.attribute1;
   x_qt_attribute2                    :=  p_tax_detail_rec.attribute2;
   x_qt_attribute3                    :=  p_tax_detail_rec.attribute3;
   x_qt_attribute4                    :=  p_tax_detail_rec.attribute4;
   x_qt_attribute5                    :=  p_tax_detail_rec.attribute5;
   x_qt_attribute6                    :=  p_tax_detail_rec.attribute6;
   x_qt_attribute7                    :=  p_tax_detail_rec.attribute7;
   x_qt_attribute8                    :=  p_tax_detail_rec.attribute8;
   x_qt_attribute9                    :=  p_tax_detail_rec.attribute9;
   x_qt_attribute10                   :=  p_tax_detail_rec.attribute10;
   x_qt_attribute11                   :=  p_tax_detail_rec.attribute11;
   x_qt_attribute12                   :=  p_tax_detail_rec.attribute12;
   x_qt_attribute13                   :=  p_tax_detail_rec.attribute13;
   x_qt_attribute14                   :=  p_tax_detail_rec.attribute14;
   x_qt_attribute15                   :=  p_tax_detail_rec.attribute15;
   x_qt_attribute16                   :=  p_tax_detail_rec.attribute16;
   x_qt_attribute17                   :=  p_tax_detail_rec.attribute17;
   x_qt_attribute18                   :=  p_tax_detail_rec.attribute18;
   x_qt_attribute19                   :=  p_tax_detail_rec.attribute19;
   x_qt_attribute20                   :=  p_tax_detail_rec.attribute20;
   x_qt_object_version_number         :=  p_tax_detail_rec.object_version_number;
   x_qt_tax_rate_id                   :=  p_tax_detail_rec.tax_rate_id;
   end;


   PROCEDURE Set_Qte_line_rec_Out(
   p_qte_line_rec                     IN  ASO_Quote_Pub.Qte_line_rec_Type,
   x_ql_creation_date                 OUT NOCOPY DATE,
   x_ql_created_by                    OUT NOCOPY NUMBER,
   x_ql_last_updated_by               OUT NOCOPY NUMBER,
   x_ql_last_update_date              OUT NOCOPY DATE,
   x_ql_last_update_login             OUT NOCOPY NUMBER,
   x_ql_request_id                    OUT NOCOPY NUMBER,
   x_ql_program_application_id        OUT NOCOPY NUMBER,
   x_ql_program_id                    OUT NOCOPY NUMBER,
   x_ql_program_update_date           OUT NOCOPY DATE,
   x_ql_quote_line_id                 OUT NOCOPY NUMBER,
   x_ql_quote_header_id               OUT NOCOPY NUMBER,
   x_ql_org_id                        OUT NOCOPY NUMBER,
   x_ql_line_number                   OUT NOCOPY NUMBER,
   x_ql_line_category_code            OUT NOCOPY VARCHAR2,
   x_ql_item_type_code                OUT NOCOPY VARCHAR2,
   x_ql_inventory_item_id             OUT NOCOPY NUMBER,
   x_ql_organization_id               OUT NOCOPY NUMBER,
   x_ql_quantity                      OUT NOCOPY NUMBER,
   x_ql_uom_code                      OUT NOCOPY VARCHAR2,
   x_ql_start_date_active             OUT NOCOPY VARCHAR2,
   x_ql_end_date_active               OUT NOCOPY VARCHAR2,
   x_ql_order_line_type_id            OUT NOCOPY NUMBER,
   x_ql_price_list_id                 OUT NOCOPY NUMBER,
   x_ql_price_list_line_id            OUT NOCOPY NUMBER,
   x_ql_currency_code                 OUT NOCOPY VARCHAR2,
   x_ql_line_list_price               OUT NOCOPY NUMBER,
   x_ql_line_adjusted_amount          OUT NOCOPY NUMBER,
   x_ql_line_adjusted_percent         OUT NOCOPY NUMBER,
   x_ql_line_quote_price              OUT NOCOPY NUMBER,
   x_ql_related_item_id               OUT NOCOPY NUMBER,
   x_ql_item_relationship_type        OUT NOCOPY VARCHAR2,
   x_ql_split_shipment_flag           OUT NOCOPY VARCHAR2,
   x_ql_backorder_flag                OUT NOCOPY VARCHAR2,
   x_ql_selling_price_change          OUT NOCOPY VARCHAR2,
   x_ql_recalculate_flag              OUT NOCOPY VARCHAR2,
   x_ql_attribute_category            OUT NOCOPY VARCHAR2,
   x_ql_attribute1                    OUT NOCOPY VARCHAR2,
   x_ql_attribute2                    OUT NOCOPY VARCHAR2,
   x_ql_attribute3                    OUT NOCOPY VARCHAR2,
   x_ql_attribute4                    OUT NOCOPY VARCHAR2,
   x_ql_attribute5                    OUT NOCOPY VARCHAR2,
   x_ql_attribute6                    OUT NOCOPY VARCHAR2,
   x_ql_attribute7                    OUT NOCOPY VARCHAR2,
   x_ql_attribute8                    OUT NOCOPY VARCHAR2,
   x_ql_attribute9                    OUT NOCOPY VARCHAR2,
   x_ql_attribute10                   OUT NOCOPY VARCHAR2,
   x_ql_attribute11                   OUT NOCOPY VARCHAR2,
   x_ql_attribute12                   OUT NOCOPY VARCHAR2,
   x_ql_attribute13                   OUT NOCOPY VARCHAR2,
   x_ql_attribute14                   OUT NOCOPY VARCHAR2,
   x_ql_attribute15                   OUT NOCOPY VARCHAR2,
   x_ql_attribute16                   OUT NOCOPY VARCHAR2,
   x_ql_attribute17                   OUT NOCOPY VARCHAR2,
   x_ql_attribute18                   OUT NOCOPY VARCHAR2,
   x_ql_attribute19                   OUT NOCOPY VARCHAR2,
   x_ql_attribute20                   OUT NOCOPY VARCHAR2,
   x_ql_accounting_rule_id            OUT NOCOPY NUMBER,
   x_ql_ffm_content_name              OUT NOCOPY VARCHAR2,
   x_ql_ffm_content_type              OUT NOCOPY VARCHAR2,
   x_ql_ffm_document_type             OUT NOCOPY VARCHAR2,
   x_ql_ffm_media_id                  OUT NOCOPY VARCHAR2,
   x_ql_ffm_media_type                OUT NOCOPY VARCHAR2,
   x_ql_ffm_user_note                 OUT NOCOPY VARCHAR2,
   x_ql_invoice_to_party_id           OUT NOCOPY NUMBER,
   x_ql_invoice_to_party_site_id      OUT NOCOPY NUMBER,
   x_ql_invoicing_rule_id             OUT NOCOPY NUMBER,
   x_ql_marketing_source_code_id      OUT NOCOPY NUMBER,
   x_ql_operation_code                OUT NOCOPY VARCHAR2,
   x_ql_invoice_to_cust_acct_id       OUT NOCOPY NUMBER,
   x_ql_pricing_quantity_uom          OUT NOCOPY VARCHAR2,
   x_ql_minisite_id                   OUT NOCOPY NUMBER,
   x_ql_section_id                    OUT NOCOPY NUMBER,
   x_ql_priced_price_list_id          OUT NOCOPY NUMBER,
   x_ql_agreement_id                  OUT NOCOPY NUMBER,
   x_ql_commitment_id                 OUT NOCOPY NUMBER,
   x_ql_display_arithmetic_op         OUT NOCOPY VARCHAR2,
   x_ql_invoice_to_cust_party_id      OUT NOCOPY NUMBER,
   x_ql_ship_model_complete_flag      OUT NOCOPY VARCHAR2,
   x_ql_charge_periodicity_code       OUT NOCOPY VARCHAR2,
   x_ql_end_cust_party_id             OUT NOCOPY NUMBER,
   x_ql_end_cust_party_site_id        OUT NOCOPY NUMBER,
   x_ql_end_cust_cust_account_id      OUT NOCOPY NUMBER,
   x_ql_end_cust_cust_party_id        OUT NOCOPY NUMBER,
   x_ql_object_version_number         OUT NOCOPY NUMBER,
   x_ql_line_paynow_charges           OUT NOCOPY NUMBER,
   x_ql_line_paynow_tax               OUT NOCOPY NUMBER,
   x_ql_line_paynow_subtotal          OUT NOCOPY NUMBER,
   x_ql_config_model_type             OUT NOCOPY VARCHAR2,
   x_ql_prod_FISC_classification      OUT NOCOPY VARCHAR2,
   x_ql_TRX_business_category         OUT NOCOPY VARCHAR2
   )is
   Begin
        x_ql_creation_date          := p_qte_line_rec.creation_date;
        x_ql_created_by             := p_qte_line_rec.created_by;
        x_ql_last_updated_by        := p_qte_line_rec.last_updated_by;
        x_ql_last_update_date       := p_qte_line_rec.last_update_date;
        x_ql_last_update_login      := p_qte_line_rec.last_update_login;
        x_ql_request_id             := p_qte_line_rec.request_id;
        x_ql_program_application_id := p_qte_line_rec.program_application_id;
        x_ql_program_id             := p_qte_line_rec.program_id;
        x_ql_program_update_date    := p_qte_line_rec.program_update_date;
        x_ql_quote_line_id          := p_qte_line_rec.quote_line_id;
        x_ql_quote_header_id        := p_qte_line_rec.quote_header_id;
        x_ql_org_id                 := p_qte_line_rec.org_id;
        x_ql_line_number            := p_qte_line_rec.line_number;
        x_ql_line_category_code     := p_qte_line_rec.line_category_code;
        x_ql_item_type_code         := p_qte_line_rec.item_type_code;
        x_ql_inventory_item_id      := p_qte_line_rec.inventory_item_id;
        x_ql_organization_id        := p_qte_line_rec.organization_id;
        x_ql_quantity               := p_qte_line_rec.quantity;
        x_ql_uom_code               := p_qte_line_rec.uom_code;
        x_ql_start_date_active      := p_qte_line_rec.start_date_active;
        x_ql_end_date_active        := p_qte_line_rec.end_date_active;
        x_ql_order_line_type_id     := p_qte_line_rec.order_line_type_id;
        x_ql_price_list_id          := p_qte_line_rec.price_list_id;
        x_ql_price_list_line_id     := p_qte_line_rec.price_list_line_id;
        x_ql_currency_code          := p_qte_line_rec.currency_code;
        x_ql_line_list_price        := p_qte_line_rec.line_list_price;
        x_ql_line_adjusted_amount   := p_qte_line_rec.line_adjusted_amount;
        x_ql_line_adjusted_percent  := p_qte_line_rec.line_adjusted_percent;
        x_ql_line_quote_price       := p_qte_line_rec.line_quote_price;
        x_ql_related_item_id        := p_qte_line_rec.related_item_id;
        x_ql_item_relationship_type := p_qte_line_rec.item_relationship_type;
        x_ql_split_shipment_flag    := p_qte_line_rec.split_shipment_flag;
        x_ql_backorder_flag         := p_qte_line_rec.backorder_flag;
        x_ql_selling_price_change   := p_qte_line_rec.selling_price_change;
        x_ql_recalculate_flag       := p_qte_line_rec.recalculate_flag;
        x_ql_attribute_category     := p_qte_line_rec.attribute_category;
        x_ql_attribute1             := p_qte_line_rec.attribute1;
        x_ql_attribute2             := p_qte_line_rec.attribute2;
        x_ql_attribute3             := p_qte_line_rec.attribute3;
        x_ql_attribute4             := p_qte_line_rec.attribute4;
        x_ql_attribute5             := p_qte_line_rec.attribute5;
        x_ql_attribute6             := p_qte_line_rec.attribute6;
        x_ql_attribute7             := p_qte_line_rec.attribute7;
        x_ql_attribute8             := p_qte_line_rec.attribute8;
        x_ql_attribute9             := p_qte_line_rec.attribute9;
        x_ql_attribute10            := p_qte_line_rec.attribute10;
        x_ql_attribute11            := p_qte_line_rec.attribute11;
        x_ql_attribute12            := p_qte_line_rec.attribute12;
        x_ql_attribute13            := p_qte_line_rec.attribute13;
        x_ql_attribute14            := p_qte_line_rec.attribute14;
        x_ql_attribute15            := p_qte_line_rec.attribute15;
        x_ql_attribute16            := p_qte_line_rec.attribute16;
        x_ql_attribute17            := p_qte_line_rec.attribute17;
        x_ql_attribute18            := p_qte_line_rec.attribute18;
        x_ql_attribute19            := p_qte_line_rec.attribute19;
        x_ql_attribute20            := p_qte_line_rec.attribute20;
        x_ql_accounting_rule_id     := p_qte_line_rec.accounting_rule_id;
        x_ql_ffm_content_name       := p_qte_line_rec.ffm_content_name;
        x_ql_ffm_content_type       := p_qte_line_rec.ffm_content_type;
        x_ql_ffm_document_type      := p_qte_line_rec.ffm_document_type;
        x_ql_ffm_media_id           := p_qte_line_rec.ffm_media_id;
        x_ql_ffm_media_type         := p_qte_line_rec.ffm_media_type;
        x_ql_ffm_user_note          := p_qte_line_rec.ffm_user_note;
        x_ql_invoice_to_party_id    := p_qte_line_rec.invoice_to_party_id;
        x_ql_invoice_to_party_site_id      := p_qte_line_rec.invoice_to_party_site_id;
        x_ql_invoicing_rule_id             := p_qte_line_rec.invoicing_rule_id;
        x_ql_marketing_source_code_id      := p_qte_line_rec.marketing_source_code_id;
        x_ql_operation_code                := p_qte_line_rec.operation_code;
        x_ql_invoice_to_cust_acct_id       := p_qte_line_rec.invoice_to_cust_account_id;
        x_ql_pricing_quantity_uom          := p_qte_line_rec.pricing_quantity_uom;
        x_ql_minisite_id                   := p_qte_line_rec.minisite_id;
        x_ql_section_id                    := p_qte_line_rec.section_id;
        x_ql_priced_price_list_id          := p_qte_line_rec.priced_price_list_id;
        x_ql_agreement_id                  := p_qte_line_rec.agreement_id;
        x_ql_commitment_id                 := p_qte_line_rec.commitment_id;
        x_ql_display_arithmetic_op         := p_qte_line_rec.display_arithmetic_operator;
        x_ql_invoice_to_cust_party_id      := p_qte_line_rec.invoice_to_cust_party_id;
        x_ql_ship_model_complete_flag      := p_qte_line_rec.ship_model_complete_flag;
        x_ql_charge_periodicity_code       := p_qte_line_rec.charge_periodicity_code;
        x_ql_end_cust_party_id             := p_qte_line_rec.end_customer_party_id;
        x_ql_end_cust_party_site_id        := p_qte_line_rec.end_customer_party_site_id;
        x_ql_end_cust_cust_account_id      := p_qte_line_rec.end_customer_cust_account_id;
        x_ql_end_cust_cust_party_id        := p_qte_line_rec.end_customer_cust_party_id;
        x_ql_object_version_number         := p_qte_line_rec.object_version_number;
        x_ql_line_paynow_charges           := p_qte_line_rec.line_paynow_charges;
        x_ql_line_paynow_tax               := p_qte_line_rec.line_paynow_tax;
        x_ql_line_paynow_subtotal          := p_qte_line_rec.line_paynow_subtotal;
        x_ql_config_model_type             := p_qte_line_rec.config_model_type;
        x_ql_prod_FISC_classification      := p_qte_line_rec.product_FISC_classification;
        x_ql_TRX_business_category         := p_qte_line_rec.TRX_business_category;
   end;

  PROCEDURE Set_Config_Valid_Table_Out(
   p_config_table               IN ASO_QUOTE_PUB.Config_Vaild_Tbl_Type,
   x_quote_line_id              OUT NOCOPY JTF_NUMBER_TABLE,
   x_changed_flag               OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_valid_flag                 OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_complete_flag              OUT NOCOPY JTF_VARCHAR2_TABLE_100
  )
  IS
    ddindx binary_integer;
    indx binary_integer;
  BEGIN
     x_quote_line_id:= jtf_number_table();
     x_changed_flag := jtf_varchar2_table_100();
     x_valid_flag   := jtf_varchar2_table_100();
     x_complete_flag := jtf_varchar2_table_100();

   IF p_config_table.count > 0 THEN
     x_quote_line_id.extend(p_config_table.count);
     x_changed_flag.extend(p_config_table.count);
     x_valid_flag.extend(p_config_table.count);
     x_complete_flag.extend(p_config_table.count);

     ddindx := p_config_table.first;
     indx := 1;
     WHILE true LOOP
       x_quote_line_id(indx) := rosetta_g_miss_num_map(p_config_table(ddindx).quote_line_id);
       x_changed_flag(indx) := p_config_table(ddindx).is_cfg_changed_flag;
       x_valid_flag(indx) := p_config_table(ddindx).is_cfg_valid;
       x_complete_flag(indx) := p_config_table(ddindx).is_cfg_complete;
       indx := indx+1;
       IF p_config_table.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_config_table.next(ddindx);
     END LOOP;
   END IF;
  END Set_Config_Valid_Table_Out;

 PROCEDURE Set_num_Tbl_Out (
   p_num_tbl                    IN  ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE,
   x_num_id                     OUT NOCOPY  JTF_NUMBER_TABLE
   )
  IS
  ddindx binary_integer;
  indx binary_integer;
 BEGIN
  x_num_id           := JTF_NUMBER_TABLE();

  IF   p_num_tbl.COUNT > 0
  THEN
       x_num_id.extend(p_num_tbl.COUNT);

       ddindx := p_num_tbl.first;
       indx := 1;

       WHILE true LOOP
            x_num_id(indx)     := rosetta_g_miss_num_map(p_num_tbl(ddindx));

            indx := indx+1;
            IF   p_num_tbl.last = ddindx
            THEN EXIT;
            END  IF;
            ddindx := p_num_tbl.next(ddindx);

        END LOOP;
   END IF;

END Set_num_Tbl_Out;

FUNCTION Construct_Related_Obj_Tbl(
   p_operation_code             IN jtf_varchar2_table_100 := NULL,
   p_RELATED_OBJECT_ID          IN jtf_number_table       := NULL,
   p_CREATION_DATE              IN jtf_date_table         := null,
   p_CREATED_BY                 IN jtf_number_table       := NULL,
   p_LAST_UPDATE_DATE           IN jtf_date_table         := null,
   p_LAST_UPDATED_BY            IN jtf_number_table       := NULL,
   p_LAST_UPDATE_LOGIN          IN jtf_number_table       := NULL,
   p_REQUEST_ID                 IN jtf_number_table       := NULL,
   p_PROGRAM_APPLICATION_ID     IN jtf_number_table       := NULL,
   p_PROGRAM_ID                 IN jtf_number_table       := NULL,
   p_PROGRAM_UPDATE_DATE        IN jtf_date_table         := null,
   p_QUOTE_OBJECT_TYPE_CODE     IN jtf_varchar2_table_300 := NULL,
   p_QUOTE_OBJECT_ID            IN jtf_number_table       := NULL,
   p_OBJECT_TYPE_CODE           IN jtf_varchar2_table_300 := NULL,
   p_OBJECT_ID                  IN jtf_number_table       := NULL,
   p_RELATIONSHIP_TYPE_CODE     IN jtf_varchar2_table_300 := NULL,
   p_RECIPROCAL_FLAG            IN jtf_varchar2_table_100 := NULL,
   p_QUOTE_OBJECT_CODE          IN jtf_number_table       := NULL,
   p_OBJECT_VERSION_NUMBER      IN jtf_number_table       := NULL
   )
RETURN ASO_Quote_Pub.RELATED_OBJ_Tbl_Type
IS
   l_rel_obj_tbl ASO_QUOTE_PUB.RELATED_OBJ_Tbl_Type := ASO_Quote_Pub.G_MISS_RELATED_OBJ_TBL;
   l_table_size       PLS_INTEGER := 0;
   i                  PLS_INTEGER;
BEGIN


   IF p_OBJECT_ID IS NOT NULL THEN
      l_table_size := p_OBJECT_ID.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP

      IF P_CREATED_BY IS NOT NULL THEN
         IF P_CREATED_BY(i)= ROSETTA_G_MISS_NUM THEN
           l_rel_obj_tbl(i).CREATED_BY:= FND_API.G_MISS_NUM;
         ELSE
           l_rel_obj_tbl(i).CREATED_BY:= P_CREATED_BY(i);
         END IF;
	 END IF;

      IF P_CREATION_DATE IS NOT NULL THEN
         IF P_CREATION_DATE(i)= ROSETTA_G_MISTAKE_DATE THEN
           l_rel_obj_tbl(i).CREATION_DATE:= FND_API.G_MISS_DATE;
         ELSE
           l_rel_obj_tbl(i).CREATION_DATE:= P_CREATION_DATE(i);
         END IF;
      END IF;

      IF P_LAST_UPDATED_BY  IS NOT NULL THEN
         IF P_LAST_UPDATED_BY(i)= ROSETTA_G_MISS_NUM THEN
           l_rel_obj_tbl(i).LAST_UPDATED_BY:= FND_API.G_MISS_NUM;
         ELSE
           l_rel_obj_tbl(i).LAST_UPDATED_BY:= P_LAST_UPDATED_BY(i);
         END IF;
	 END IF;

      IF P_LAST_UPDATE_DATE  IS NOT NULL THEN
         IF P_LAST_UPDATE_DATE(i)= ROSETTA_G_MISTAKE_DATE  THEN
           l_rel_obj_tbl(i).LAST_UPDATE_DATE:= FND_API.G_MISS_DATE;
         ELSE
           l_rel_obj_tbl(i).LAST_UPDATE_DATE:= P_LAST_UPDATE_DATE(i);
         END IF;
	END IF;

      IF P_LAST_UPDATE_LOGIN  IS NOT NULL THEN
         IF P_LAST_UPDATE_LOGIN(i)= ROSETTA_G_MISS_NUM THEN
           l_rel_obj_tbl(i).LAST_UPDATE_LOGIN:= FND_API.G_MISS_NUM;
         ELSE
           l_rel_obj_tbl(i).LAST_UPDATE_LOGIN:= P_LAST_UPDATE_LOGIN(i);
         END IF;
	 END IF;

      IF P_OBJECT_ID  IS NOT NULL THEN
         IF P_OBJECT_ID(i)= ROSETTA_G_MISS_NUM THEN
           l_rel_obj_tbl(i).OBJECT_ID:= FND_API.G_MISS_NUM;
         ELSE
           l_rel_obj_tbl(i).OBJECT_ID:= P_OBJECT_ID(i);
         END IF;
	 END IF;

      IF  P_OBJECT_TYPE_CODE  IS NOT NULL THEN
         IF P_OBJECT_TYPE_CODE(i)IS NOT NULL  THEN
            l_rel_obj_tbl(i).OBJECT_TYPE_CODE:= P_OBJECT_TYPE_CODE(i);
         END IF;
      END IF;

      IF  P_OBJECT_VERSION_NUMBER  IS NOT NULL THEN
         IF P_OBJECT_VERSION_NUMBER(i)= ROSETTA_G_MISS_NUM THEN
            l_rel_obj_tbl(i).OBJECT_VERSION_NUMBER:= FND_API.G_MISS_NUM;
         ELSE
            l_rel_obj_tbl(i).OBJECT_VERSION_NUMBER:= P_OBJECT_VERSION_NUMBER(i);
         END IF;
	END IF;


      IF  P_PROGRAM_APPLICATION_ID  IS NOT NULL THEN
         IF P_PROGRAM_APPLICATION_ID(i)= ROSETTA_G_MISS_NUM THEN
            l_rel_obj_tbl(i).PROGRAM_APPLICATION_ID:= FND_API.G_MISS_NUM;
         ELSE
            l_rel_obj_tbl(i).PROGRAM_APPLICATION_ID:= P_PROGRAM_APPLICATION_ID(i);
         END IF;
	END IF;

      IF  P_PROGRAM_ID  IS NOT NULL THEN
         IF P_PROGRAM_ID(i)= ROSETTA_G_MISS_NUM THEN
               l_rel_obj_tbl(i).PROGRAM_ID:= FND_API.G_MISS_NUM;
         ELSE
             l_rel_obj_tbl(i).PROGRAM_ID:= P_PROGRAM_ID(i);
         END IF;
	END IF;


      IF  P_PROGRAM_UPDATE_DATE  IS NOT NULL THEN
         IF P_PROGRAM_UPDATE_DATE(i)= ROSETTA_G_MISTAKE_DATE  THEN
             l_rel_obj_tbl(i).PROGRAM_UPDATE_DATE:= FND_API.G_MISS_DATE;
         ELSE
             l_rel_obj_tbl(i).PROGRAM_UPDATE_DATE:= P_PROGRAM_UPDATE_DATE(i);
         END IF;
	END IF;

      IF  P_QUOTE_OBJECT_ID  IS NOT NULL THEN
         IF P_QUOTE_OBJECT_ID(i)= ROSETTA_G_MISS_NUM THEN
             l_rel_obj_tbl(i).QUOTE_OBJECT_ID:= FND_API.G_MISS_NUM;
         ELSE
             l_rel_obj_tbl(i).QUOTE_OBJECT_ID:= P_QUOTE_OBJECT_ID(i);
         END IF;
	END IF;

      IF  P_QUOTE_OBJECT_TYPE_CODE  IS NOT NULL THEN
         IF P_QUOTE_OBJECT_TYPE_CODE(i)IS NOT NULL  THEN
             l_rel_obj_tbl(i).QUOTE_OBJECT_TYPE_CODE:= P_QUOTE_OBJECT_TYPE_CODE(i);
         END IF;

      END IF;

      IF  P_RECIPROCAL_FLAG  IS NOT NULL THEN
         IF P_RECIPROCAL_FLAG(i) IS NOT NULL  THEN
             l_rel_obj_tbl(i).RECIPROCAL_FLAG:= P_RECIPROCAL_FLAG(i);
         END IF;
	END IF;

      IF  P_RELATED_OBJECT_ID  IS NOT NULL THEN
         IF P_RELATED_OBJECT_ID(i)= ROSETTA_G_MISS_NUM THEN
             l_rel_obj_tbl(i).RELATED_OBJECT_ID:= FND_API.G_MISS_NUM;
         ELSE
             l_rel_obj_tbl(i).RELATED_OBJECT_ID:= P_RELATED_OBJECT_ID(i);
         END IF;

      END IF;

      IF  P_RELATIONSHIP_TYPE_CODE  IS NOT NULL THEN
         IF P_RELATIONSHIP_TYPE_CODE(i) IS NOT NULL  THEN
            l_rel_obj_tbl(i).RELATIONSHIP_TYPE_CODE:= P_RELATIONSHIP_TYPE_CODE(i);
         END IF;
      END IF;

      IF  P_OPERATION_CODE  IS NOT NULL THEN
         IF P_OPERATION_CODE(i) IS NOT NULL  THEN
            l_rel_obj_tbl(i).OPERATION_CODE:= P_OPERATION_CODE(i);
         END IF;
      END IF;

	 IF  P_QUOTE_OBJECT_CODE  IS NOT NULL THEN
         IF P_QUOTE_OBJECT_CODE(i) IS NOT NULL  THEN
            l_rel_obj_tbl(i).QUOTE_OBJECT_CODE:= P_QUOTE_OBJECT_CODE(i);
         END IF;
      END IF;

      IF  P_REQUEST_ID  IS NOT NULL THEN
         IF P_REQUEST_ID(i) = ROSETTA_G_MISS_NUM  THEN
            l_rel_obj_tbl(i).REQUEST_ID:= FND_API.G_MISS_NUM;
         ELSE
            l_rel_obj_tbl(i).REQUEST_ID:= P_REQUEST_ID(i);
         END IF;
      END IF;

      END LOOP;

      RETURN l_rel_obj_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_RELATED_OBJ_TBL;
   END IF;

END Construct_Related_Obj_Tbl;

PROCEDURE Set_Related_Obj_Tbl_Out(
   p_rel_obj_tbl         IN  ASO_Quote_Pub.RELATED_OBJ_Tbl_Type,
   x_related_object_id   OUT NOCOPY  jtf_number_table
  )
  IS
   ddindx binary_integer;
   indx binary_integer;
BEGIN
   x_related_object_id := jtf_number_table();
   IF p_rel_obj_tbl.count > 0 THEN
     x_related_object_id.extend(p_rel_obj_tbl.count);
     ddindx := p_rel_obj_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_related_object_id(indx) := rosetta_g_miss_num_map(p_rel_obj_tbl(ddindx).related_object_id);
       indx := indx+1;
       IF p_rel_obj_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_rel_obj_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Related_Obj_Tbl_Out;

END ASO_QUOTE_UTIL_PVT;


/
