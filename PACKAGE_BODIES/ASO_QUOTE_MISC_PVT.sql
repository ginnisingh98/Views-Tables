--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_MISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_MISC_PVT" AS
/* $Header: asovqmib.pls 120.2 2005/07/20 03:16:20 appldev ship $ */


PROCEDURE Debug_Tax_Info_Notification (
    p_qte_header_rec      IN ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE
   ,p_Hd_Shipment_Rec     IN ASO_QUOTE_PUB.SHIPMENT_REC_TYPE
   ,p_reason              IN VARCHAR2
) IS
  l_output         VARCHAR2(32767);
  l_org_id         NUMBER;
  l_client_info    VARCHAR2(256);
  l_return_status  VARCHAR2(30);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(32767);
  l_email          VARCHAR2(256) := FND_PROFILE.value('ASO_DIAG_EMAIL_ADDRESS');
  l_enable_email   VARCHAR2(1) := FND_PROFILE.value('ASO_ENABLE_DEBUG_EMAIL');

  PROCEDURE Writeln(pText IN VARCHAR2) IS
  BEGIN
    l_output := l_output || pText || FND_GLOBAL.NewLine();
  END Writeln;

BEGIN
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_Quote_Misc_PVT: Profile(ASO_DIAG_EMAIL_ADDRESS): l_email: '||l_email, 1, 'N');
    aso_debug_pub.add('ASO_Quote_Misc_PVT: Profile(ASO_ENABLE_DEBUG_EMAIL): l_enable_email: '||l_enable_email, 1, 'N');
  END IF;

 IF (NVL(FND_PROFILE.Value('ASO_ENABLE_DEBUG_EMAIL'), 'N') = 'Y') THEN
  IF l_email IS NOT NULL THEN
    Writeln('[ Begin Debug Tax Info ]');

    /* Commented out for performance issue and replaced with new code
    BEGIN

      SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
                                  SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99),
             USERENV('CLIENT_INFO')
        INTO l_org_id, l_client_info
        FROM dual;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
    */

 --Commented Code start Yogeshwar (MOAC)
 /*
    IF SUBSTRB(USERENV('CLIENT_INFO'),1 ,1) = ' ' THEN
        l_org_id  :=  NULL;
    ELSE
        l_org_id  :=  TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1,10));
    END IF;

    l_client_info :=  USERENV('CLIENT_INFO');
*/
--End of Commented code (MOAC)
    L_org_id := p_qte_header_rec.org_id  ; --New Code Yogeshwar (MOAC)

   /*    --Commented Code Start Yogeshwar (MOAC)
    Writeln('');
    Writeln('  General Info');
    Writeln('  ============');
    WriteLn('  ORG_ID=' || l_org_id);
    WriteLn('  RESP_ID=' || FND_GLOBAL.resp_id());
    WriteLn('  RESP_APPL_ID=' || FND_GLOBAL.resp_appl_id());
    Writeln('  USER_ID=' || FND_GLOBAL.resp_appl_id());
    Writeln('  USERENV("CLIENT_INFO") 01-32=[' || SUBSTR(l_client_info, 1, 32) || ']');
    Writeln('  USERENV("CLIENT_INFO") 33-64=[' || SUBSTR(l_client_info, 33) || ']');
    Writeln('');
    Writeln('  Quote Info');
    Writeln('  ==========');
    Writeln('  QUOTE_HEADER_ID=' || p_qte_header_rec.quote_header_id);
    Writeln('  ORG_ID=' || TO_CHAR(p_qte_header_rec.org_id,'9999'));
    Writeln('  INVOICE_TO_PARTY_ID=' || TO_CHAR(p_qte_header_rec.invoice_to_party_id, '999999999'));
    Writeln('  INVOICE_TO_PARTY_SITE_ID=' || TO_CHAR(p_qte_header_rec.invoice_to_party_site_id, '999999999'));
    Writeln('  SHIP_TO_PARTY_ID=' || TO_CHAR(p_hd_shipment_rec.ship_to_party_id, '999999999'));
    Writeln('  SHIP_TO_PARTY_SITE_ID=' || TO_CHAR(p_hd_shipment_rec.ship_to_party_site_id, '999999999'));
    Writeln('');
    Writeln('  AR_SYSTEM_PARAMETERS (ARP_STANDARD.sysparm)');
    Writeln('  ===========================================');
    Writeln('  org_id='  || ARP_STANDARD.sysparm.org_id);
    Writeln('  set_of_books_id=' || ARP_STANDARD.sysparm.set_of_books_id);
    Writeln('  default_grouping_rule_id=' || ARP_STANDARD.sysparm.default_grouping_rule_id);
    Writeln('  salesrep_required_flag=' || ARP_STANDARD.sysparm.salesrep_required_flag);
    Writeln('  location_tax_account=' || ARP_STANDARD.sysparm.location_tax_account);
    Writeln('  tax_registration_number=' || ARP_STANDARD.sysparm.tax_registration_number);
    Writeln('  create_reciprocal_flag=' || ARP_STANDARD.sysparm.create_reciprocal_flag);
    Writeln('  default_country=' || ARP_STANDARD.sysparm.default_country);
    Writeln('  default_territory=' || ARP_STANDARD.sysparm.default_territory);
    Writeln('  generate_customer_number=' || ARP_STANDARD.sysparm.generate_customer_number);
    Writeln('  invoice_deletion_flag=' || ARP_STANDARD.sysparm.invoice_deletion_flag);
    Writeln('  location_structure_id=' || ARP_STANDARD.sysparm.location_structure_id);
    Writeln('  site_required_flag=' || ARP_STANDARD.sysparm.site_required_flag);
    Writeln('  tax_allow_compound_flag=' || ARP_STANDARD.sysparm.tax_allow_compound_flag);
    Writeln('  tax_invoice_print=' || ARP_STANDARD.sysparm.tax_invoice_print);
    Writeln('  tax_method=' || ARP_STANDARD.sysparm.tax_method);
    Writeln('  accounting_method=' || ARP_STANDARD.sysparm.accounting_method);
    Writeln('  accrue_interest=' || ARP_STANDARD.sysparm.accrue_interest);
    Writeln('  auto_site_numbering=' || ARP_STANDARD.sysparm.auto_site_numbering);
    Writeln('  cash_basis_set_of_books_id=' || ARP_STANDARD.sysparm.cash_basis_set_of_books_id);
    Writeln('  address_validation=' || ARP_STANDARD.sysparm.address_validation);
    Writeln('  tax_code=' || ARP_STANDARD.sysparm.tax_code);
    Writeln('  tax_currency_code=' || ARP_STANDARD.sysparm.tax_currency_code);
    Writeln('  tax_header_level_flag=' || ARP_STANDARD.sysparm.tax_header_level_flag);
    Writeln('  rule_set_id=' || ARP_STANDARD.sysparm.rule_set_id);
    Writeln('  inclusive_tax_used=' || ARP_STANDARD.sysparm.inclusive_tax_used);
    Writeln('  sales_tax_geocode=' || ARP_STANDARD.sysparm.sales_tax_geocode);
    Writeln('');
    Writeln('  TAX_INFO_REC (ARP_TAX)');
    Writeln('  ======================');
    Writeln('  bill_to_cust_id=' || ARP_TAX.tax_info_rec.bill_to_cust_id);
    Writeln('  ship_to_cust_id=' || ARP_TAX.tax_info_rec.ship_to_cust_id);
    Writeln('  bill_to_customer_name='  || ARP_TAX.tax_info_rec.bill_to_customer_name);
    Writeln('  ship_to_customer_name=' || ARP_TAX.tax_info_rec.ship_to_customer_name);
    Writeln('  bill_to_site_use_id=' || ARP_TAX.tax_info_rec.bill_to_site_use_id);
    Writeln('  ship_to_site_use_id=' || ARP_TAX.tax_info_rec.ship_to_site_use_id);
    Writeln('  bill_to_location_id=' || ARP_TAX.tax_info_rec.bill_to_location_id);
    Writeln('  ship_to_location_id=' || ARP_TAX.tax_info_rec.ship_to_location_id);
    Writeln('  tax_code=' || ARP_TAX.tax_info_rec.tax_code);
    Writeln('  vat_tax_id=' || ARP_TAX.tax_info_rec.vat_tax_id);
    Writeln('  tax_exemption_id=' || ARP_TAX.tax_info_rec.tax_exemption_id);
    Writeln('  tax_rate=' || ARP_TAX.tax_info_rec.tax_rate);
    Writeln('  calculate_tax=' || ARP_TAX.tax_info_rec.calculate_tax);
    Writeln('  customer_trx_line_id=' || ARP_TAX.tax_info_rec.customer_trx_line_id);
    Writeln('  customer_trx_id=' || ARP_TAX.tax_info_rec.customer_trx_id);
    Writeln('  trx_date=' || ARP_TAX.tax_info_rec.trx_date);
    Writeln('  ship_to_postal_code=' || ARP_TAX.tax_info_rec.ship_to_postal_code);
    Writeln('  bill_to_postal_code=' || ARP_TAX.tax_info_rec.bill_to_postal_code);
    Writeln('  inventory_item_id=' || ARP_TAX.tax_info_rec.inventory_item_id);
    Writeln('  Exemp Flag or tax_control=' || ARP_TAX.tax_info_rec.tax_control);
    Writeln('  xmpt_cert_no =' || ARP_TAX.tax_info_rec.xmpt_cert_no);
    Writeln('  xmpt_reason =' || ARP_TAX.tax_info_rec.xmpt_reason);
    Writeln('  invoicing_rule_id =' || ARP_TAX.tax_info_rec.invoicing_rule_id);
    Writeln('  extended_amount =' || ARP_TAX.tax_info_rec.extended_amount);
    Writeln('  trx_exchange_rate =' || ARP_TAX.tax_info_rec.trx_exchange_rate);
    Writeln('  trx_currency_code =' || ARP_TAX.tax_info_rec.trx_currency_code);
    Writeln('  minimum_accountable_unit =' || ARP_TAX.tax_info_rec.minimum_accountable_unit);
    Writeln('  precision =' || ARP_TAX.tax_info_rec.precision);
    Writeln('  fob_point =' || ARP_TAX.tax_info_rec.fob_point);
    Writeln('  taxed_quantity =' || ARP_TAX.tax_info_rec.taxed_quantity);
    Writeln('  qualifier =' || ARP_TAX.tax_info_rec.qualifier);
    Writeln('  calculate_tax =' || ARP_TAX.tax_info_rec.calculate_tax);
    Writeln('  ship_to_customer_number =' || ARP_TAX.tax_info_rec.ship_to_customer_number);
    Writeln('  bill_to_customer_number =' || ARP_TAX.tax_info_rec.bill_to_customer_number);
    Writeln('  audit_flag =' || ARP_TAX.tax_info_rec.audit_flag);
    Writeln('  tax_header_level_flag =' || ARP_TAX.tax_info_rec.tax_header_level_flag);
    Writeln('  tax_rounding_rule =' || ARP_TAX.tax_info_rec.tax_rounding_rule);
    Writeln('  trx_type_id  =' || ARP_TAX.tax_info_rec.trx_type_id );
    Writeln('  ship_from_warehouse_id  =' || ARP_TAX.tax_info_rec.ship_from_warehouse_id );
    Writeln('  poo_id  =' || ARP_TAX.tax_info_rec.poo_id );
    Writeln('  poa_id  =' || ARP_TAX.tax_info_rec.poa_id );
    Writeln('  payment_term_id  =' || ARP_TAX.tax_info_rec.payment_term_id );
    Writeln('');
    WriteLn('[ End Debug Tax Info ]');

    Writeln(' REASON FOR NOT CALCULATING TAX' );
    Writeln(' ======================');
    Writeln('  Reason=' || p_reason);
  */ --Commented Code End Yogeshwar (MOAC)

    ASO_WFNOTIFICATION_PVT.Send_Email(
       p_api_version      => 1
      ,p_commit           => FND_API.G_FALSE
      ,p_init_msg_list    => FND_API.G_FALSE
      ,p_email_list         => l_email
      ,p_subject            => 'ASO [Debug_Tax_Info Email Notification] @ ' ||
    					     TO_CHAR(SYSDATE,'YYY/MM/DD HH:MI:SS')
      ,p_body               => l_output
      ,x_return_status      => l_return_status
      ,x_msg_count        => l_msg_count
      ,x_msg_data         => l_msg_data
      );
  END IF; -- IF l_email IS NOT NULL
 END IF; -- IF l_enable_email IS YES

END Debug_Tax_Info_Notification;

END ASO_Quote_Misc_PVT;

/
