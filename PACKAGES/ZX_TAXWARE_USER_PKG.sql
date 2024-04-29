--------------------------------------------------------
--  DDL for Package ZX_TAXWARE_USER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAXWARE_USER_PKG" AUTHID CURRENT_USER AS
/* $Header: zxtxwuserpkgs.pls 120.7 2006/09/21 09:51:58 vchallur ship $ */

   /*These are two global variables which are used to hold the transaction date and transaction type id
   Since these are derived at the header level and are reused at the header level they have been made
   global*/

	 g_trx_date		ZX_LINES_DET_FACTORS.TRX_DATE%TYPE;
         g_trx_type_id		ZX_LINES_DET_FACTORS.RECEIVABLES_TRX_TYPE_ID%TYPE;
	 g_line_negation	BOOLEAN;
	 g_trx_line_id		ZX_LINES_DET_FACTORS.TRX_ID%TYPE;
	 G_MESSAGES_TBL         ZX_TAX_PARTNER_PKG.messages_tbl_type;
	 err_count		number :=0;

   /*The following are the nested table declartions to collect all the records
   fetch from the main cursor defined in Derive_Line_Ext_Attr procedure .*/

	 TYPE org_id_table IS TABLE OF  ZX_LINES_DET_FACTORS.Internal_Organization_Id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE application_id_table IS TABLE OF ZX_LINES_DET_FACTORS.Application_Id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE entity_code_table IS TABLE OF  ZX_LINES_DET_FACTORS.entity_code%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE event_class_code_table IS TABLE OF  ZX_LINES_DET_FACTORS.event_class_code%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE trx_id_table IS TABLE OF  ZX_LINES_DET_FACTORS.trx_id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE trx_provider_id_table IS TABLE OF  ZX_USER_PROC_INPUT_V.Tax_Provider_Id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE tax_regime_code_table IS TABLE OF  ZX_USER_PROC_INPUT_V.Tax_Regime_Code%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE trx_line_type_table IS TABLE OF  ZX_LINES_DET_FACTORS.Trx_Line_Type%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE trx_line_id_table IS TABLE OF  ZX_LINES_DET_FACTORS.trx_line_id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE product_id_table IS TABLE OF  ZX_LINES_DET_FACTORS.product_id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE product_org_id_table IS TABLE OF ZX_LINES_DET_FACTORS.product_org_id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE ship_to_party_tx_prf_id_table IS TABLE OF ZX_LINES_DET_FACTORS.ship_to_party_tax_prof_id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE exempt_cert_number_table IS TABLE OF ZX_LINES_DET_FACTORS.exempt_certificate_number%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE exempt_control_flag_table IS TABLE OF ZX_LINES_DET_FACTORS.Exemption_Control_Flag%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE exempt_reason_code_table IS TABLE OF ZX_LINES_DET_FACTORS.exempt_reason_code%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE ship_to_site_tax_prof_table IS TABLE OF ZX_LINES_DET_FACTORS.ship_to_site_tax_prof_id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE ship_from_prty_tx_prf_id_table IS TABLE OF ZX_LINES_DET_FACTORS.Ship_from_Party_Tax_Prof_Id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE ship_to_location_id_table IS TABLE OF ZX_LINES_DET_FACTORS.ship_to_location_id%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE ship_to_address_id_table  IS TABLE OF ZX_PARTY_TAX_PROFILE.PARTY_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE ship_to_party_id_table    IS TABLE OF ZX_PARTY_TAX_PROFILE.PARTY_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_trx_line_type_table  IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE1%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_product_code_table   IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE2%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_exempt_cert_number_table IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE3%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE arp_state_exempt_reason_table IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE4%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE arp_county_exempt_reason_table IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE5%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE arp_city_exempt_reason_table IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE6%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE arp_district_exempt_rs_table IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE7%TYPE
		     INDEX BY BINARY_INTEGER;
	 TYPE arp_audit_flag_table     IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE8%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_ship_to_add_table    IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE9%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_ship_from_add_table    IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE10%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_poa_add_code_table     IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE11%TYPE
		INDEX BY BINARY_INTEGER;
         TYPE arp_poo_add_code_table     IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE20%TYPE
                INDEX BY BINARY_INTEGER;
	 TYPE arp_customer_code_table     IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE12%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_customer_name_table     IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE13%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_company_code_table     IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE14%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_division_code_table     IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE15%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_vnd_ctrl_exmpt_table    IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE16%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_use_nexpro_table       IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE17%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_tax_type_table         IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE18%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_service_ind_table       IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE19%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_transaction_date_table  IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_DATE_ATTRIBUTE1%TYPE
	       INDEX BY BINARY_INTEGER;
	 TYPE arp_state_exempt_percent_table IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE1%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_county_exempt_pct_table IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE2%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_city_exempt_pct_table IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE3%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_district_exempt_pct_table IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE4%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE ship_to_site_use_table        IS TABLE OF ZX_LINES_DET_FACTORS.SHIP_TO_CUST_ACCT_SITE_USE_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE arp_tax_sel_param_table       IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE5%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE bill_to_site_use_table        IS TABLE OF ZX_LINES_DET_FACTORS.BILL_TO_CUST_ACCT_SITE_USE_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE bill_to_site_tax_prof_table   IS TABLE OF ZX_LINES_DET_FACTORS.BILL_TO_PARTY_TAX_PROF_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE bill_to_location_id_table     IS TABLE OF ZX_LINES_DET_FACTORS.BILL_TO_LOCATION_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE bill_to_party_tax_id_table    IS TABLE OF ZX_LINES_DET_FACTORS.BILL_TO_PARTY_TAX_PROF_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE bill_third_pty_acct_id_table  IS TABLE OF ZX_LINES_DET_FACTORS.BILL_THIRD_PTY_ACCT_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE hq_site_tax_prof_id_tab       IS TABLE OF ZX_LINES_DET_FACTORS.TRADING_HQ_SITE_TAX_PROF_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE hq_party_tax_prof_id_tab IS TABLE OF ZX_LINES_DET_FACTORS.TRADING_HQ_PARTY_TAX_PROF_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE line_level_action_table          IS TABLE OF ZX_LINES_DET_FACTORS.LINE_LEVEL_ACTION%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE exemption_control_flag_table     IS TABLE OF ZX_LINES_DET_FACTORS.EXEMPTION_CONTROL_FLAG%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE adjusted_doc_trx_id_table        IS TABLE OF ZX_LINES_DET_FACTORS.ADJUSTED_DOC_TRX_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE line_amount_table                IS TABLE OF ZX_LINES_DET_FACTORS.LINE_AMT%TYPE
		INDEX BY BINARY_INTEGER;
         TYPE trx_type_id_table                IS TABLE OF ZX_LINES_DET_FACTORS.RECEIVABLES_TRX_TYPE_ID%TYPE
       		INDEX BY BINARY_INTEGER;
         TYPE state_cert_no_table              IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE20%TYPE
       		INDEX BY BINARY_INTEGER;
         TYPE county_cert_no_table             IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE21%TYPE
       		INDEX BY BINARY_INTEGER;
	 TYPE calculation_flag_table           IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE21%TYPE
       		INDEX BY BINARY_INTEGER;
	 TYPE city_cert_no_table               IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE22%TYPE
       		INDEX BY BINARY_INTEGER;
	 TYPE use_step_table                   IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE23%TYPE
       		INDEX BY BINARY_INTEGER;
	 TYPE step_proc_flag_table             IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE24%TYPE
       		INDEX BY BINARY_INTEGER;
         TYPE crit_flag_table             IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE25%TYPE
       		INDEX BY BINARY_INTEGER;
	 TYPE Sec_County_Exempt_Pct_table  IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE6%TYPE
       		INDEX BY BINARY_INTEGER;
         TYPE Sec_City_Exempt_Pct_table  IS TABLE OF ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE7%TYPE
       		INDEX BY BINARY_INTEGER;
	 TYPE adj_doc_appl_id_table            IS TABLE OF ZX_LINES_DET_FACTORS.ADJUSTED_DOC_APPLICATION_ID%TYPE
	        INDEX BY BINARY_INTEGER;
	 TYPE adj_doc_entity_code_table        IS TABLE OF ZX_LINES_DET_FACTORS.ADJUSTED_DOC_ENTITY_CODE%TYPE
	        INDEX BY BINARY_INTEGER;
	 TYPE adj_evnt_cls_code_table	       IS TABLE OF ZX_LINES_DET_FACTORS.ADJUSTED_DOC_EVENT_CLASS_CODE%TYPE
	        INDEX BY BINARY_INTEGER;
         TYPE adj_doc_line_id_table            IS TABLE OF ZX_LINES_DET_FACTORS.ADJUSTED_DOC_LINE_ID%TYPE
 	        INDEX BY BINARY_INTEGER;
	 TYPE adj_doc_trx_level_type_table     IS TABLE OF ZX_LINES_DET_FACTORS.ADJUSTED_DOC_TRX_LEVEL_TYPE%TYPE
                INDEX BY BINARY_INTEGER;
	 TYPE ship_third_pty_site_table        IS TABLE OF ZX_LINES_DET_FACTORS.SHIP_THIRD_PTY_ACCT_SITE_ID%TYPE
		INDEX BY BINARY_INTEGER;
	 TYPE bill_third_pty_site_table        IS TABLE OF ZX_LINES_DET_FACTORS.BILL_THIRD_PTY_ACCT_SITE_ID%TYPE
		INDEX BY BINARY_INTEGER;





         TYPE exemptions_info_rec IS RECORD (
         state_exempt_reason		ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE4%TYPE,
         county_exempt_reason		ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE5%TYPE,
         city_exempt_reason		ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE6%TYPE,
         state_exempt_pct		ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE1%TYPE,
         county_exempt_pct		ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE2%TYPE,
         city_exempt_pct		ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE3%TYPE,
	 default_exempt_pct		ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE4%TYPE,
 	 State_Cert_No			ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE20%TYPE,
 	 County_Cert_No			ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE21%TYPE,
	 City_Cert_No			ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE22%TYPE,
	 Sec_County_Exempt_Percent	ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE6%TYPE,
	 Sec_City_Exempt_Percent        ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE7%TYPE,
 	 Use_Step                       ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE23%TYPE,
	 Step_Proc_Flag                 ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE24%TYPE,
	 Crit_Flag			ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE25%TYPE
	 );

	 TYPE exemptions_info_table          IS TABLE OF exemptions_info_rec
	         INDEX BY BINARY_INTEGER;

         --The following are the variable declarations for all the nested tables above(one per nested table)

         internal_org_id_tab        org_id_table    ;
         application_id_tab         application_id_table;
         entity_code_tab            entity_code_table;
         event_class_code_tab       event_class_code_table;
         trx_id_tab                 trx_id_table;
         tax_provider_id_tab        trx_provider_id_table;
         tax_regime_code_tab        tax_regime_code_table;
         trx_line_type_tab          trx_line_type_table;
         trx_line_id_tab            trx_line_id_table;
         product_id_tab             product_id_table;
         Product_Org_Id_tab         product_org_id_table;
         ship_to_tx_id_tab          ship_to_party_tx_prf_id_table;
         ship_from_tx_id_tab        ship_from_prty_tx_prf_id_table;
         cert_num_tab               exempt_cert_number_table;
         exmpt_rsn_code_tab         exempt_reason_code_table;
         exemption_control_flag_tab exemption_control_flag_table;

         ship_to_site_tax_prof_tab  ship_to_site_tax_prof_table;
         ship_to_loc_id_tab         ship_to_location_id_table;
         exmpt_control_flg_tab      exempt_control_flag_table;
         arp_trx_line_type_tab      arp_trx_line_type_table ;
         arp_product_code_tab       arp_product_code_table;
         arp_audit_flag_tab         arp_audit_flag_table;
         arp_ship_to_add_tab        arp_ship_to_add_table;
         arp_ship_from_add_tab      arp_ship_from_add_table;
         arp_poa_add_code_tab       arp_poa_add_code_table;
	 arp_poo_add_code_tab       arp_poo_add_code_table;
         arp_customer_code_tab      arp_customer_code_table;
         arp_customer_name_tab     arp_customer_name_table;
         arp_company_code_tab       arp_company_code_table;
         arp_division_code_tab      arp_division_code_table;
         arp_transaction_date_tab   arp_transaction_date_table;
         ship_to_address_id_tab     ship_to_address_id_table;
         ship_to_party_id_tab       ship_to_party_id_table;

         arp_state_exempt_reason_tab     arp_state_exempt_reason_table ;
         arp_county_exempt_reason_tab    arp_county_exempt_reason_table;
         arp_city_exempt_reason_tab      arp_city_exempt_reason_table;
         arp_district_exempt_rs_tab      arp_district_exempt_rs_table;
         arp_state_exempt_percent_tab    arp_state_exempt_percent_table;
	 ship_to_site_use_tab            ship_to_site_use_table;
         arp_county_exempt_pct_tab       arp_county_exempt_pct_table;
         arp_city_exempt_pct_tab         arp_city_exempt_pct_table;
         arp_district_exempt_pct_tab     arp_district_exempt_pct_table;
         bill_to_site_use_tab            bill_to_site_use_table;
         bill_to_site_tax_prof_tab       bill_to_site_tax_prof_table;
         bill_to_party_tax_id_tab        bill_to_party_tax_id_table;
         bill_to_location_id_tab         bill_to_location_id_table;
         trad_hq_site_tax_prof_id_tab    hq_site_tax_prof_id_tab;
         trad_hq_party_tax_prof_id_tab   hq_party_tax_prof_id_tab;
	 bill_third_pty_acct_id_tab  	 bill_third_pty_acct_id_table;
         line_level_action_tab           line_level_action_table;
	 adjusted_doc_trx_id_tab         adjusted_doc_trx_id_table;
	 line_amount_tab                 line_amount_table;
       	 trx_type_id_tab            	 trx_type_id_table;
	 exemptions_info_tab    	 exemptions_info_table;
 	 arp_vnd_ctrl_exmpt_tab  	 arp_vnd_ctrl_exmpt_table;
	 arp_use_nexpro_tab  		 arp_use_nexpro_table;
	 arp_tax_type_tab		 arp_tax_type_table;
	 arp_service_ind_tab		 arp_service_ind_table;
	 arp_tax_sel_param_tab		 arp_tax_sel_param_table;
 	 state_cert_no_tab		 state_cert_no_table;
	 county_cert_no_tab           	 county_cert_no_table;
	 city_cert_no_tab           	 city_cert_no_table;
	 use_step_tab               	 use_step_table;
	 step_proc_flag_tab         	 step_proc_flag_table;
	 crit_flag_tab              	 crit_flag_table;
	 sec_county_exempt_pct_tab  	 sec_county_exempt_pct_table;
	 sec_city_exempt_pct_tab    	 sec_city_exempt_pct_table;
	 calculation_flag_tab            calculation_flag_table;
 	 adj_doc_appl_id_tab       	 adj_doc_appl_id_table;
	 adj_doc_entity_code_tab   	 adj_doc_entity_code_table;
	 adj_evnt_cls_code_tab	         adj_evnt_cls_code_table;
	 adj_doc_line_id_tab       	 adj_doc_line_id_table;
	 adj_doc_trx_level_type_tab      adj_doc_trx_level_type_table;
	 ship_third_pty_site_tab	 ship_third_pty_site_table;
	 bill_third_pty_site_tab	 bill_third_pty_site_table;


PROCEDURE Derive_Hdr_Ext_Attr(
	x_error_status           OUT NOCOPY VARCHAR2,
	x_messages_tbl           OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type);
PROCEDURE Derive_Line_Ext_Attr(
	x_error_status           OUT NOCOPY VARCHAR2,
	x_messages_tbl           OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type);

END ZX_TAXWARE_USER_PKG;

 

/
