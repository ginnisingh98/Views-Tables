--------------------------------------------------------
--  DDL for Package JAI_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CONSTANTS" AUTHID CURRENT_USER AS
/* $Header: jai_constants.pls 120.15.12010000.2 2010/04/16 21:19:01 haoyang ship $ */

/*  */
/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_constants_s.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1    15/12/2004     Vijay Shankar for Bug#4068823, 3940588,   FileVersion:115.0
                    This Package is coded as a common reference to different Constants that are be used across the product

2    19/03/2005     Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.1
                    added required constants as part of VAT Implementation

3.  08-Jun-2005     Version 116.1 jai_constants -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                    as required for CASE COMPLAINCE.

4.  13-Jun-2005     In the prorcess of Removal of SQL LITERALs. File Version: 116.2
                    New constants added
                    1. item_class codes
                    2. closed_code codes

5.  06-Jul-2005     Ramananda for bug#4477004. File Version: 116.1
                    GL Sources and GL Categories got changed. Refer bug for the details

6.  29-08-2005      rallamse. File Verion 120.2
                    Added the trigger actions inserting, deleting and updating

7.  02-Sep-2005     Ramananda for bug#4584221. File Version 120.3
                    Two constants added
                    1. regn_type_tds_batch := 'TDS_INVOICE_BATCH'
                    2. tds_regime := 'TDS' ;

8.  01/11/2006     SACSETHI for bug 5228046, File version 120.4
                   Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                   This bug has datamodel and spec changes.

9.  02/02/2007     Bgowrava for BUG 5631784, File Version 120.5
                   Forward porting the change in 11i bug 4742259 (TCS enhancement)
10.  13/04/2007   bduvarag for the Bug#5989740, file version 120.6
                  Forward porting the changes done in 11i bug#5907436

11   24-APR-2007    CBABU FOR BUG 6012567, 6012570 FILE VERSION 120.7   (Projects Costing,Billing porting)
                        Project Costing + Billing Changes
12   01-Jun-2007   CSahoo for bug#6081806, File version 120.8
		   changed the service_tax_orgn_type from OU to IO.

13.  04-jun-2007   the table_name for ar trx lines was still the R11i name. It has been changed to reflect the R12 name.

 23.        14/06/2007   sacsethi for bug 6072461 for file version - 120.15

			FP of bug 5183031 ( vat reversal )
DEPENDANCY:
-----------
IN60106   + 4239736 + 4245089

15.  27/06/2007		csahoo for bug# 6155839, File Version 120.11
									added the following constants:
									service_tax_source     	CONSTANT VARCHAR2(30)	:= 'Service Tax India';
									vat_source							CONSTANT VARCHAR2(30)	:= 'VAT India';
									tcs_source							CONSTANT VARCHAR2(30) := 'India TCS Entry';

16.  28/06/2007 by sacsethi for bug 6157120 file version 120.12

		Two Variables added

		1. pan_no  - Organization pan no
		2. accounting_information  -- Organization Accoutning information

17.  04/09/2007   Bgowrava for Bug#6012570, File version 120.14
                  Added constant pa_je_source for the gl source 'Projects India'
18.  04/09/2007  Jeffsen for standalone invoice.
                 Added two constants and one function.
19.  02-Apr-2010 Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement).
                 Added six constants.

----------------------------------------------------------------------------------------------------------------------------*/
-- All global variables are declared as CONSTANT for File.Sql.35 by Brathod

  func_curr                 CONSTANT VARCHAR2(3)   := 'INR';

  accounting_method_cash    CONSTANT VARCHAR2(15)  := 'Cash';
  accounting_method_accrual CONSTANT VARCHAR2(15)  := 'Accrual';

  no_number_value           CONSTANT NUMBER        := -999999999999;

  party_type_orgn           CONSTANT VARCHAR2(1)   := 'O';
  party_type_vendor         CONSTANT VARCHAR2(1)   := 'V';
  party_type_customer       CONSTANT VARCHAR2(1)   := 'C';

  yes                       CONSTANT VARCHAR2(1)   := 'Y';
  no                        CONSTANT VARCHAR2(1)   := 'N';
  value_true                CONSTANT VARCHAR2(15)  := 'TRUE';
  value_false               CONSTANT VARCHAR2(15)  := 'FALSE';

  credit                    CONSTANT VARCHAR2(2)   := 'CR';
  debit                     CONSTANT VARCHAR2(2)   := 'DR';

  je_category_rg_entry      CONSTANT VARCHAR2(30)  := 'Register India';

  recovery                  CONSTANT VARCHAR2(20)  := 'RECOVERY';
  liability                 CONSTANT VARCHAR2(20)  := 'LIABILITY';
  recovery_interim          CONSTANT VARCHAR2(20)  := 'INTERIM_RECOVERY';
  liability_interim         CONSTANT VARCHAR2(20)  := 'INTERIM_LIABILITY';

  source_ap                 CONSTANT VARCHAR2(2)   := 'AP';
  source_ar                 CONSTANT VARCHAR2(2)   := 'AR';
  source_po                 CONSTANT VARCHAR2(2)   := 'PO';
  source_om                 CONSTANT VARCHAR2(2)   := 'OM';
  source_manual_entry       CONSTANT VARCHAR2(15)  := 'MANUAL';
  source_settle_in          CONSTANT VARCHAR2(15)  := 'SETTLE_IN';
  source_settle_out         CONSTANT VARCHAR2(15)  := 'SETTLE_OUT';
  source_receive            CONSTANT VARCHAR2(15)  := 'RECEIVE';
  source_rtv                CONSTANT VARCHAR2(20)  := 'RETURN TO VENDOR';

  source_wsh                CONSTANT VARCHAR2(5)   := 'WSH';
  source_rcv                CONSTANT VARCHAR2(5)   := 'RCV';
  source_ttype_delivery     CONSTANT VARCHAR2(15)  := 'DELIVERY';
  source_ttype_man_ar_inv   CONSTANT VARCHAR2(30)  := 'MANUAL AR INVOICE';
  /*
  || Added by bgowrava for the TCS enhancement Bug 5631784
  */

  service_src_distribute_in      CONSTANT VARCHAR2(30)  := 'SERVICE_DISTRIBUTE_IN';
  service_src_distribute_out     CONSTANT VARCHAR2(30)  := 'SERVICE_DISTRIBUTE_OUT';

  orgn_type_ou              CONSTANT VARCHAR2(2)   := 'OU';
  orgn_type_io              CONSTANT VARCHAR2(2)   := 'IO';
  excise_regime             CONSTANT VARCHAR2(15)  := 'EXCISE';

  service_tax_orgn_type     CONSTANT VARCHAR2(2)   := 'IO';   --added by csahoo for bug#6081806
  service_regime            CONSTANT VARCHAR2(15)  := 'SERVICE';
  vat_regime                CONSTANT VARCHAR2(15)  := 'VAT';
  tds_regime                CONSTANT VARCHAR2(3)   := 'TDS' ;

  /* this will be used for rounding the amounts that are hitting service tax repository */
  service_rgm_rnd_factor    CONSTANT NUMBER(1)     := 2;
  vat_rgm_rnd_factor        CONSTANT NUMBER(1)     := 2;

  tax_type_service          CONSTANT VARCHAR2(15)  := 'Service';
  tax_type_excise           CONSTANT VARCHAR2(15)  := 'Excise';
  tax_type_exc_additional   CONSTANT VARCHAR2(15)  := 'Addl. Excise';
  tax_type_exc_other        CONSTANT VARCHAR2(15)  := 'Other Excise';
  tax_type_cvd              CONSTANT VARCHAR2(15)  := 'CVD';
  tax_type_add_cvd          CONSTANT VARCHAR2(15)  := 'ADDITIONAL_CVD'; -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  tax_type_tds              CONSTANT VARCHAR2(15)  := 'TDS';
  tax_type_modvat_recovery  CONSTANT VARCHAR2(20)  := 'Modvat Recovery';
  tax_type_customs          CONSTANT VARCHAR2(15)  := 'Customs';
  tax_type_cst              CONSTANT VARCHAR2(15)  := 'CST';
  tax_type_sales            CONSTANT VARCHAR2(15)  := 'Sales Tax';
  tax_type_other            CONSTANT VARCHAR2(15)  := 'Other';
  tax_type_octroi           CONSTANT VARCHAR2(15)  := 'Octrai';
  tax_type_service_edu_cess CONSTANT VARCHAR2(30)  := 'SERVICE_EDUCATION_CESS';
  tax_type_exc_edu_cess     CONSTANT VARCHAR2(30)  := 'EXCISE_EDUCATION_CESS';
  tax_type_cvd_edu_cess     CONSTANT VARCHAR2(30)  := 'CVD_EDUCATION_CESS';
  tax_type_customs_edu_cess CONSTANT VARCHAR2(30)  := 'CUSTOMS_EDUCATION_CESS';
  tax_type_freight          CONSTANT VARCHAR2(30)  := 'Freight';
 /*Bug 5989740 bduvarag start*/
  tax_type_sh_exc_edu_cess                        VARCHAR2(30)  := 'EXCISE_SH_EDU_CESS';
  tax_type_sh_cvd_edu_cess                        VARCHAR2(30)  := 'CVD_SH_EDU_CESS';
  tax_type_sh_customs_edu_Cess                    VARCHAR2(30)  := 'CUSTOMS_SH_EDU_CESS';
  tax_type_sh_service_edu_cess                    VARCHAR2(30)  := 'SERVICE_SH_EDU_CESS';
  tax_type_sh_tcs_edu_cess                        VARCHAR2(30)  := 'TCS_SH_EDU_CESS';

/*Bug 5989740 bduvarag end*/

  tax_type_entry            CONSTANT VARCHAR2(15) := 'ENTRY TAX';
  tax_type_purchase         CONSTANT VARCHAR2(15) := 'PURCHASE TAX';
  tax_type_turnover         CONSTANT VARCHAR2(15) := 'TURNOVER TAX';
  tax_type_value_added      CONSTANT VARCHAR2(20) := 'VALUE ADDED TAX';

  rgm_attr_type_code_primary  CONSTANT VARCHAR2(15) := 'PRIMARY';
  regn_type_tax_types       CONSTANT VARCHAR2(15)  := 'TAX_TYPES';
  regn_type_accounts        CONSTANT VARCHAR2(15)  := 'ACCOUNTS';
  regn_type_others          CONSTANT VARCHAR2(15)  := 'OTHERS';
  regn_type_tds_batch       CONSTANT VARCHAR2(20)  := 'TDS_INVOICE_BATCH' ;

  attr_code_same_inv_no     CONSTANT VARCHAR2(30)  := 'SAME_INVOICE_NO';
  attr_code_regn_no         CONSTANT VARCHAR2(30)  := 'REGISTRATION_NO';

  register_type_a           CONSTANT VARCHAR2(10)  := 'A';
  register_type_c           CONSTANT VARCHAR2(10)  := 'C';
  register_type_pla         CONSTANT VARCHAR2(10)  := 'PLA';

  gl_je_source_name         CONSTANT VARCHAR2(30)  := 'India Localization Entry';

  repository_name           CONSTANT VARCHAR2(30)  := 'JAI_RGM_TRX_RECORDS';
  ap_payments               CONSTANT VARCHAR2(30)  := 'AP_INVOICE_PAYMENTS_ALL';
  ap_prepayments            CONSTANT VARCHAR2(30)  := 'AP_INVOICE_DISTRIBUTIONS_ALL';
  rgm_trx_refs              CONSTANT VARCHAR2(25)  := 'JAI_RGM_TRX_REFS';
  ar_inv_lines_table                              VARCHAR2(30)  := 'JAI_AR_TRX_LINES'; --added by bgowrava /* ssumaith - bug#6109941 */

  already_processed         CONSTANT VARCHAR2(1)   := 'A';
  not_accounted             CONSTANT VARCHAR2(2)   := 'N';
  expected_error            CONSTANT VARCHAR2(2)   := 'EE';
  unexpected_error          CONSTANT VARCHAR2(2)   := 'UE';
  successful                CONSTANT VARCHAR2(2)   := 'SS';
  not_applicable                                  VARCHAR2(2)   := 'NA'; /* Added by bgowrava */

  misc_line                 CONSTANT VARCHAR2(30)  := 'MISCELLANEOUS';
  prepay_line               CONSTANT VARCHAR2(15)  := 'PREPAY';
  future_payment            CONSTANT VARCHAR2(15)  := 'FUTURE_PAYMENT';
  payment                   CONSTANT VARCHAR2(15)  := 'PAYMENT';
  payment_voided            CONSTANT VARCHAR2(15)  := 'PAYMENT_VOID';
  payment_reversal          CONSTANT VARCHAR2(20)  := 'PAYMENT_REVERSAL';
  prepay_application        CONSTANT VARCHAR2(15)  := 'PREPAY_APPLY';
  prepay_unapplication      CONSTANT VARCHAR2(15)  := 'PREPAY_UNAPPLY';

  cenvat_noclaim            CONSTANT VARCHAR2(15)  := 'UNCLAIM';
  vat_noclaim               CONSTANT VARCHAR2(15)  := 'VAT_UNCLAIM';

  gl_application_id         CONSTANT NUMBER(4)     := 101;

  -- Lookups Defined in Database
  lk_type_tax_type          CONSTANT VARCHAR2(20)   := 'JAI_TAX_TYPE' ;
  lk_type_ind_tax_rgms      CONSTANT VARCHAR2(25)  := 'JAI_INDIA_TAX_REGIMES' ;

  /* AR Related Constants */
  trx_type_inv_comp                    CONSTANT   VARCHAR2(40)  := 'INVOICE_COMPLETION' ; /*Added by Bgowrava for forward porting Bug#5631784*/
  trx_type_inv_incomp                  CONSTANT   VARCHAR2(40)  := 'INVOICE_INCOMPLETION' ; /*Added by Bgowrava for forward porting Bug#5631784*/
  trx_event_app                        CONSTANT   VARCHAR2(40)  := 'APPLICATION'         ;        /*Added by Bgowrava for forward porting Bug#5631784*/
  trx_event_completion                 CONSTANT   VARCHAR2(40)  := 'COMPLETION'          ;        /*Added by Bgowrava for forward porting Bug#5631784*/
  trx_event_inv_save                   CONSTANT   VARCHAR2(40)  := 'INV_SAVE'            ;        /*Added by Bgowrava for forward porting Bug#5631784*/
  trx_type_rct_app                     CONSTANT VARCHAR2(20)  := 'RECEIPT_APPLICATION' ;
  trx_type_rct_unapp                   CONSTANT   VARCHAR2(40)  := 'RECEIPT_UNAPPLICATION' ; /*Added by Bgowrava for forward porting Bug#5631784*/
  trx_type_rct_rvs                     CONSTANT VARCHAR2(20)  := 'RECEIPT_REVERSAL' ;
  jai_cash_rcpts                       CONSTANT   VARCHAR2(40)  := 'JAI_AR_CASH_RECEIPTS_ALL' ;/*Added by Bgowrava for forward porting Bug#5631784*/
  trx_type_cm_app                      CONSTANT VARCHAR2(30)  := 'CREDIT_MEMO_APPLICATION' ;
  trx_type_cm_unapp                    CONSTANT   VARCHAR2(40)  := 'CREDIT_MEMO_UNAPPLICATION' ; /*Added by Bgowrava for forward porting Bug#5631784*/
  trx_type_cm_rvs                      CONSTANT VARCHAR2(30)  := 'CREDIT_MEMO_REVERSAL' ;
  ar_receipt_app                       CONSTANT VARCHAR2(30)  := 'AR_RECEIVABLE_APPLICATIONS_ALL';
  ar_cash                              CONSTANT VARCHAR2(4)   := 'CASH' ;
  ar_cash_tax_confirmed                CONSTANT   VARCHAR2(40)  := 'CASH_TAX_CONFIRMED' ;/*Added by Bgowrava for forward porting Bug#5631784*/
  ar_status_app                        CONSTANT VARCHAR2(3)   := 'APP' ;
  ar_status_activity                   CONSTANT   VARCHAR2(40)  := 'ACTIVITY' ;/*Added by Bgowrava for forward porting Bug#5631784*/
  ar_invoice_type_inv                  CONSTANT VARCHAR2(3)   := 'INV' ;
  ar_invoice_type_cm                   CONSTANT VARCHAR2(2)   := 'CM' ;
  ar_doc_type_dm                                  VARCHAR2(2)   := 'DM' ; /* Added by bgowrava /*

  /* OM Related Constants */
  om_action_gen_inv_n_accnt CONSTANT VARCHAR2(15)  := 'PROCESS ALL';
  om_action_gen_invoice     CONSTANT VARCHAR2(30)  := 'GENERATE INVOICE NO';
  om_action_gen_accounting  CONSTANT VARCHAR2(30)  := 'PROCESS ACCOUNTING';

  -- Concurrent Request processing Stage codes
  request_error             CONSTANT NUMBER(1)     := 2;
  request_warning           CONSTANT NUMBER(1)     := 1;

  -- For Cenvat Register Processing
  reg_rg23_2_code           CONSTANT NUMBER(1)     := 1;
  reg_pla_code              CONSTANT NUMBER(1)     := 2;
  reg_rg23d_code            CONSTANT NUMBER(1)     := 3;
  reg_receipt_cenvat_code   CONSTANT NUMBER(1)     := 4;

  reg_rg23a_2               CONSTANT VARCHAR2(15)  := 'RG23A_P2';
  reg_rg23c_2               CONSTANT VARCHAR2(15)  := 'RG23C_P2';
  reg_rg23d                 CONSTANT VARCHAR2(15)  := 'RG23D';
  reg_pla                   CONSTANT VARCHAR2(15)  := 'PLA';
  reg_rg23a                 CONSTANT VARCHAR2(15)  := 'RG23A';
  reg_rg23c                 CONSTANT VARCHAR2(15)  := 'RG23C';

  reg_receipt_cenvat        CONSTANT VARCHAR2(15)  := 'RECEIPT_CENVAT';


  tname_dlry_dtl            CONSTANT VARCHAR2(30) := 'WSH_DELIVERY_DETAILS';
  tname_cus_trx_lines       CONSTANT VARCHAR2(30) := 'CUSTOMER_TRX_LINE_ALL' ;

  contxt_delivery           CONSTANT VARCHAR2(15)  := 'DELIVERY';
  contxt_manual_ar          CONSTANT VARCHAR2(30) := 'MANUAL AR INVOICE';

  vat_repo_call_from_om_ar  CONSTANT VARCHAR2(61) := 'JAI_RGM_OM_AR_VAT_ACCOUNTING.PROCESS_ORDER_INVOICE' ;
  vat_repo_call_inv_comp    CONSTANT VARCHAR2(61) := 'JA_IN_LOC_AR_HDR_UPD_TRG';

  rgm_attr_item_class       CONSTANT VARCHAR2(15) := 'ITEM CLASS';
  rgm_attr_item_folio       CONSTANT VARCHAR2(15) := 'ITEM FOLIO';
  rgm_attr_item_applicable  CONSTANT VARCHAR2(15) := 'APPLICABLE';
  rgm_attr_item_recoverable CONSTANT VARCHAR2(15) := 'RECOVERABLE';


   /********************************************
    || Start of bug 5631784. Added by Bgowrava For TCS enhancement
    || TCS Regime related entries
    *********************************************/
    --rgm_attr_type_code_primary           CONSTANT   VARCHAR2(15)  := 'PRIMARY'                    ;
    rgm_attr_code_org_tan                CONSTANT   VARCHAR2(30)  := 'ORG_TAN_NUM'                ;
    rgm_attr_cd_itm_class                CONSTANT   VARCHAR2(30)  := 'ITEM_CLASSIFICATION'        ;

    tcs_regime                           CONSTANT   VARCHAR2(30)  := 'TCS'                        ;
    tcs_event_surcharge                  CONSTANT   VARCHAR2(30)  := 'TCS_THRESHOLD_PROCESSING'   ;
    tax_type_tcs                         CONSTANT   VARCHAR2(30)  := 'TCS'                        ;
    tax_type_tcs_cess                    CONSTANT   VARCHAR2(30)  := 'TCS_CESS'                   ;
    tax_type_tcs_surcharge               CONSTANT   VARCHAR2(30)  := 'TCS_SURCHARGE'              ;
    tax_type_tcs_surcharge_cess          CONSTANT   VARCHAR2(30)  := 'TCS_SURCHARGE_CESS'         ;
    tax_exmpt_flag_std_rate              CONSTANT   VARCHAR2(2)   := 'SR'                         ;
    tax_exmpt_flag_lower_rate            CONSTANT   VARCHAR2(2)   := 'LR'                         ;
    tax_exmpt_flag_zero_rate             CONSTANT   VARCHAR2(2)   := 'ZR'                         ;
    tax_modified_by_system               CONSTANT   VARCHAR2(10)  := 'SYSTEM'                     ;
    tax_modified_by_user                 CONSTANT   VARCHAR2(10)  := 'MANUAL'                     ;
    thhold_typ_cumulative                CONSTANT   VARCHAR2(30)  := 'CUMULATIVE'                 ;
    default_taxes                        CONSTANT   VARCHAR2(15)  := 'DEFAULT_TAXES'              ;
    recalculate_taxes                    CONSTANT   VARCHAR2(20)  := 'RECALCULATE_TAXES'          ;
    site_use_bill_to                     CONSTANT   VARCHAR2(20)  := 'BILL_TO'                    ;
    line_type_line                       CONSTANT   VARCHAR2(20)  := 'LINE'                       ;
    account_class_rec                    CONSTANT   VARCHAR2(10)  := 'REC'                        ;
    account_class_rev                    CONSTANT   VARCHAR2(10)  := 'REV'                        ;
    tcs_surcharge_id                     CONSTANT   NUMBER(5)     := -700                         ;
    jai_rgm_thresholds                   CONSTANT   VARCHAR2(30)  := 'JAI_RGM_THRESHOLDS'         ;
    created_fr_ar_invoice_api            CONSTANT   VARCHAR2(20)  := 'AR_INVOICE_API'             ;
    order_booked                         CONSTANT   VARCHAR2(20)  := 'BOOKED'                     ;
    conversion_type_user                 CONSTANT   VARCHAR2(20)  := 'User'                       ;
    tax_code_localization                CONSTANT   VARCHAR2(20)  := 'Localization'               ;
    tcs_dm_prefix                        CONSTANT   VARCHAR2(10)  := 'TCS-DM'                     ;
    tcs_cm_prefix                        CONSTANT   VARCHAR2(10)  := 'TCS-CM'                     ;
    batch_src_dm                         CONSTANT   VARCHAR2(20)  := 'BATCH_SRC_DM'               ;
    batch_src_cm                         CONSTANT   VARCHAR2(20)  := 'BATCH_SRC_CM'               ;
    creation_sign_positive               CONSTANT   VARCHAR2(30)  := 'P'                          ;
    creation_sign_negative               CONSTANT   VARCHAR2(30)  := 'N'                          ;
    creation_sign_any                    CONSTANT   VARCHAR2(30)  := 'A'                          ;
    wsh_ship_confirm                     CONSTANT   VARCHAR2(20)  := 'SHIP_CONFIRM'               ;
    bill_only_invoice                    CONSTANT   VARCHAR2(25)  := 'BILL_ONLY_INVOICE'          ;
  /* End  of bug 5631784 */


  item_class_rmin           CONSTANT VARCHAR2(5) :=  'RMIN' ;
  item_class_rmex           CONSTANT VARCHAR2(5) :=  'RMEX' ;
  item_class_cgex           CONSTANT VARCHAR2(5) :=  'CGEX' ;
  item_class_cgin           CONSTANT VARCHAR2(5) :=  'CGIN' ;
  item_class_ccex           CONSTANT VARCHAR2(5) :=  'CCEX' ;
  item_class_ccin           CONSTANT VARCHAR2(5) :=  'CCIN' ;
  item_class_fgin           CONSTANT VARCHAR2(5) :=  'FGIN' ;
  item_class_fgex           CONSTANT VARCHAR2(5) :=  'FGEX' ;

  closed_code_open         CONSTANT VARCHAR2(20) :=  'OPEN';
  closed_code_inporcess    CONSTANT VARCHAR2(20) :=  'IN PROCESS' ;
  closed_code_approved     CONSTANT VARCHAR2(20) :=  'APPROVED';
  closed_code_preapproved  CONSTANT VARCHAR2(20) :=  'PRE-APPROVED';
  closed_code_req_appr     CONSTANT VARCHAR2(25) :=  'REQUIRES REAPPROVAL' ;
  closed_code_incomplete   CONSTANT VARCHAR2(20) :=  'INCOMPLETE'  ;

  INSERTING                CONSTANT VARCHAR2(15) := 'INSERTING' ;
  UPDATING                 CONSTANT VARCHAR2(15) := 'UPDATING' ;
  DELETING                 CONSTANT VARCHAR2(15) := 'DELETING' ;

  -- Start,BUGs 6012567, 6012570

   SETUP_EVENT_TYPE                    CONSTANT VARCHAR2(20)                := 'Event Type';
   SETUP_EXPENDITURE_TYPE              CONSTANT VARCHAR2(20)                := 'Expenditure Type';
   SETUP_PROJECT                       CONSTANT VARCHAR2(20)                := 'Project';
   SETUP_CUSTOMER_SITE                 CONSTANT VARCHAR2(20)                := 'Customer/Site';
   PA_DRAFT_INVOICE                    CONSTANT VARCHAR2 (30)                := 'PROJECT_DRAFT_INVOICE';
   pa_ip_invoices       constant  varchar2  (30)  := 'PA_IP_INVOICES';
   import_taxes         constant  varchar2  (30)  := 'IMPORT_TAXES';
   projects_invoices     constant  varchar2 (30)   := 'PROJECTS INVOICES';
   pa_je_source             CONSTANT  VARCHAR2(30)    := 'Projects India';    --Added by Bgowrava for Bug#6012570
  -- end,BUGs 6012567, 6012570
 ------------------------------------------------------
    -- sacsethi , Added expense constant, w.r.t BUG#6072461 (for VAT Reversal)
  expense                                          VARCHAR2(20)  := 'EXPENSE';

  /*added by csahoo for bug#6155839, start*/
  service_tax_source     	CONSTANT VARCHAR2(30)	:= 'Service Tax India';
  vat_source							CONSTANT VARCHAR2(30)	:= 'VAT India';
  tcs_source							CONSTANT VARCHAR2(30) := 'India Tax Collected';

  /*bug#6155839, end*/

  -- Date 28/06/2007 by sacsethi for bug 6157120
  -- pan_no = for Organization pan no
  -- 'Accounting Information' - This Reference to Organization Additional Information

   pan_no      	CONSTANT VARCHAR2(10)	:= 'PAN NO';
   accounting_information CONSTANT VARCHAR2(30)	:=  'Accounting Information' ;

-- Added by Jeffsen for standalone invoice on 2007/09/04

---------------------------------------------------------------------------
G_AP_STANDALONE_INVOICE    CONSTANT VARCHAR2(30) := 'STANDALONE_INVOICE';
G_REDEFAULT_TAXES          CONSTANT VARCHAR2(15) := 'REDEFAULT_TAXES';
G_MODULE_PREFIX            VARCHAR2(40)          := 'jai.plsql.JAI_CONSTANTS';
--==========================================================================

  -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
  source_nsh                     CONSTANT VARCHAR2(30)   := 'NON-SHIPPABLE LINES';
  source_ttype_non_shippable     CONSTANT VARCHAR2(30)   := 'FULFILL';
  tname_order_lines_all          CONSTANT VARCHAR2(30)   := 'OE_ORDER_LINES_ALL';
  contxt_non_shippable           CONSTANT VARCHAR2(30)   := 'NON-SHIPPABLE LINES';
  -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end

END jai_constants;

/
