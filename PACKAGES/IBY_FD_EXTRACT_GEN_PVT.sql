--------------------------------------------------------
--  DDL for Package IBY_FD_EXTRACT_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FD_EXTRACT_GEN_PVT" AUTHID CURRENT_USER AS
/* $Header: ibyfdxgs.pls 120.32.12010000.9 2010/02/18 10:56:18 asarada ship $ */


  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_FD_EXTRACT_GEN_PVT';

  -- Various parameters used by the extract-generating XML views
  --

  -- system security key- for registered instrument decryption
  --
  G_VP_SYS_KEY CONSTANT VARCHAR2(30) := 'SYS_KEY';

  -- payment instruction id; for fv instruction level APIs
  --
  G_VP_INSTR_ID CONSTANT VARCHAR2(30) := 'PMT_INSTR_ID';

  -- Federal Summary ECS dos Sequence number; for fv ECS summary
  --
  G_VP_FV_ECS_SEQ CONSTANT VARCHAR2(30) := 'FV_ECS_SEQ';

  -- Format type
  --
  G_VP_FMT_TYPE CONSTANT VARCHAR2(30) := 'FMT_TYPE';


  /*Adding types for caching :- Citi Perf*/

   TYPE p_party_contact_point IS RECORD (
     table_name     VARCHAR2(1000),
     l_payee_party_id NUMBER,
     l_email      VARCHAR2(2000),
     l_phone_cp_id NUMBER ,
     l_fax_cp_id   NUMBER ,
     l_url VARCHAR2(2000)
     );

  TYPE party_contact_Tab_Type IS TABLE OF p_party_contact_point
     INDEX BY VARCHAR2(2000);

 party_contact_tab party_contact_Tab_Type;

 TYPE p_site_contact_point IS RECORD (
     table_name     VARCHAR2(1000),
     l_party_site_id NUMBER,
     l_email      VARCHAR2(2000),
     l_phone_cp_id NUMBER ,
     l_fax_cp_id   NUMBER ,
     l_url VARCHAR2(2000)
     );

  TYPE site_contact_Tab_Type IS TABLE OF p_site_contact_point
     INDEX BY VARCHAR2(2000);

 site_contact_tab site_contact_Tab_Type;


  /*End of variables for Caching :- Citi Perf */

  -- for payment format
  PROCEDURE Create_Extract_1_0
  (
  p_payment_instruction_id   IN     NUMBER,
  p_save_extract_flag        IN     VARCHAR2,
  p_format_type              IN     VARCHAR2,
  p_is_reprint_flag          IN     VARCHAR2,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  );

  -- directly for aux formats
  -- indirectly for payment format
  PROCEDURE Create_Extract_1_0
  (
  p_payment_instruction_id   IN     NUMBER,
  p_save_extract_flag        IN     VARCHAR2,
  p_format_type              IN     VARCHAR2,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  );


  -- for separate remittance advice
  PROCEDURE Create_Extract_1_0
  (
  p_payment_instruction_id   IN     NUMBER,
  p_save_extract_flag        IN     VARCHAR2,
  p_format_type              IN     VARCHAR2,
  p_delivery_method          IN     VARCHAR2,
  p_payment_id               IN     NUMBER,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB,
  p_from_pmt_ref             IN     NUMBER,
  p_to_pmt_ref               IN     NUMBER
  );


  -- for positive pay - bug 5028143
  PROCEDURE Create_Pos_Pay_Extract_1_0
  (
  p_payment_instruction_id   IN     NUMBER,
  p_payment_profile_id       IN     NUMBER,
  p_from_date                IN     VARCHAR2,
  p_to_date                  IN     VARCHAR2,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  );

  -- for LKQ POS PAY issue
  PROCEDURE Create_Pos_Pay_Extract_2_0
  (
  p_payment_instruction_id   IN     NUMBER,

  p_format_name		     IN     VARCHAR2,
  p_internal_bank_account_name     IN     VARCHAR2,
  p_from_date                IN     VARCHAR2,
  p_to_date                  IN     VARCHAR2,
  p_payment_status	     IN     VARCHAR2,
  p_reselect		     IN     VARCHAR2,

  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  );

  PROCEDURE Create_PPR_Extract_1_0
  (
  p_payment_service_request_id   IN     NUMBER,
  p_sys_key                      IN     iby_security_pkg.des3_key_type,
  x_extract_doc                  OUT NOCOPY CLOB
  );



  FUNCTION Get_FP_TaxRegistration(p_legal_entity_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION Get_Payee_LegalRegistration(p_vendor_id IN NUMBER,
                                       p_vendor_site_id IN NUMBER,
                                       p_vendor_site_country IN VARCHAR2)
  RETURN VARCHAR2;


  FUNCTION Get_Payee_TaxRegistration(p_party_id IN NUMBER,
                                     p_supplier_site_id IN NUMBER) -- bug# 7412315
  RETURN VARCHAR2;


  FUNCTION Get_PayerContact(p_party_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_PayeeContact(p_payment_id IN NUMBER)
  RETURN XMLTYPE;
  /*Overloaded Function*/
  FUNCTION Get_PayeeContact(p_payment_id IN NUMBER
                            ,p_remit_to_location_id IN iby_payments_all.remit_to_location_id%TYPE
			    ,p_party_site_id IN iby_payments_all.party_site_id%TYPE
			    ,p_payee_party_id IN iby_payments_all.payee_party_id%TYPE)
  RETURN XMLTYPE;

  FUNCTION format_hr_address(p_hr_location_id IN NUMBER,
                             p_style_code			IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;


  FUNCTION format_hz_address(p_hz_location_id IN NUMBER,
                             p_style_code			IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;


  FUNCTION Get_Pmt_DocPayableCount(p_payment_id IN NUMBER)
  RETURN NUMBER;

  FUNCTION Get_Ins_PayerInstrAgg(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE;


  FUNCTION Get_Payer(p_legal_entity_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_PayerBankAccount(p_bank_account_id IN NUMBER)
  RETURN XMLTYPE;


  FUNCTION Get_Payer_Denorm(p_payment_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_PayerBankAccount_Denorm(p_payment_id IN NUMBER)
  RETURN XMLTYPE;


  FUNCTION Get_PayerIns_Denorm(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_PayerBankAccountIns_Denorm(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE;


  FUNCTION Get_Ins_FVFieldsAgg(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_Ins_AccountSettingsAgg(p_bep_account_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_Pmt_DocPayableAgg(p_payment_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_Payee(p_payment_id IN NUMBER)
  RETURN XMLTYPE;


  --Overloaded Function
  FUNCTION Get_Payee(p_payment_id IN NUMBER, p_pmt_func IN VARCHAR2)
  RETURN XMLTYPE;

  /* TPP - Start */
  FUNCTION Get_InvPayee(p_payment_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION get_rel_add_info(
   payee_party_id IN NUMBER,
   supplier_site_id IN NUMBER,
   inv_payee_party_id IN NUMBER,
   inv_supplier_site_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_relship_id(
   payee_party_id IN NUMBER,
   supplier_site_id IN NUMBER,
   inv_payee_party_id IN NUMBER,
   inv_supplier_site_id IN NUMBER)
  RETURN NUMBER;
  /* TPP - End */

  FUNCTION Get_PayeeBankAccount(p_payment_id IN NUMBER, p_external_bank_account_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_PayeeBankAccount_Denorm(p_payment_id IN NUMBER, p_external_bank_account_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_PayeeBankAccount_Denorm(p_payment_id IN NUMBER
                                       , p_external_bank_account_id IN NUMBER
				       ,p_pmt_func IN VARCHAR2)
  RETURN XMLTYPE;

  FUNCTION Get_Doc_DocLineAgg(p_document_payable_id IN NUMBER)
  RETURN XMLTYPE;
  -- Overloaded function Citi Perf issues.
  FUNCTION Get_Doc_DocLineAgg(p_document_payable_id IN NUMBER,
                                p_call_app_doc_unique_ref2 IN ap_invoices_all.invoice_id%TYPE,
				p_doc_currency_code  IN iby_docs_payable_all.document_currency_code%TYPE,
				p_calling_app_id  IN iby_docs_payable_all.calling_app_id%TYPE)
				RETURN XMLTYPE;
 --Overloaded function Citi perf

  FUNCTION Get_SRA_Attribute(p_payment_id IN NUMBER, p_attribute_type IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_FEIN(payment_instruction_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_Abbreviated_Agency_Code(payment_instruction_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_Allotment_Code(payment_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION TOP_Offset_Eligibility_Flag(payment_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_SPS_PMT_TS(payment_id IN NUMBER)
  RETURN VARCHAR2;


  FUNCTION Get_Bordero_Bank_Ref(p_doc_payable_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION Get_Bordero_Int_Amt(p_doc_payable_id IN NUMBER)
  RETURN Number;

  FUNCTION Get_Bordero_Abatement(p_doc_payable_id IN NUMBER)
  RETURN Number;


  FUNCTION Get_Payment_Amount_Text(payment_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION Get_Payment_Amount_Withheld(payment_id IN NUMBER)
  RETURN NUMBER;


  -- Payment process request extract functions
  FUNCTION Get_Ppr_PmtAgg(p_payment_service_request_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_Ppr_PmtCount(p_payment_service_request_id IN NUMBER)
  RETURN NUMBER;

  FUNCTION Get_Ppr_PreBuildDocAgg(p_payment_service_request_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_Ppr_PreBuildDocCount(p_payment_service_request_id IN NUMBER)
  RETURN NUMBER;

  FUNCTION Get_Pmt_PmtErrAgg(p_payment_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_Doc_DocErrAgg(p_document_payable_id IN NUMBER)
  RETURN XMLTYPE;

  PROCEDURE Update_Pmt_SRA_Attr_Prt
  (
  p_payment_instruction_id   IN     NUMBER
  );

  PROCEDURE Update_Pmt_SRA_Attr_Ele
  (
  p_payment_id                   IN     NUMBER,
  p_delivery_method              IN     VARCHAR2,
  p_recipient_email              IN     VARCHAR2,
  p_recipient_fax                IN     VARCHAR2
  );

  PROCEDURE initialize;
  FUNCTION Get_Hz_Address(p_location_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_Account_Address(p_location_id IN NUMBER, p_country IN VARCHAR2)
  RETURN XMLTYPE;

  FUNCTION Get_Hr_Address(p_location_id IN NUMBER)
  RETURN XMLTYPE;

  FUNCTION Get_Ins_TotalAmt(p_payment_instruction_id IN NUMBER)
  RETURN NUMBER;

  FUNCTION Get_Expense_Rpt_CC_Num(p_document_payable_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION Replace_Special_Characters(p_base_string IN varchar2)
  RETURN VARCHAR2;

 /* Bug 9266772*/
  FUNCTION Get_Intermediary_Bank_Accts(p_bank_acct_id IN NUMBER)
  RETURN XMLTYPE;
  /* Bug 9266772*/

END IBY_FD_EXTRACT_GEN_PVT;



/
