--------------------------------------------------------
--  DDL for Package IBY_VALIDATIONSETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_VALIDATIONSETS_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyvalls.pls 120.18.12010000.9 2010/06/03 10:25:09 asarada ship $*/

 --
 -- Contains all document level fields which need to be validated
 --
 TYPE documentRecType IS RECORD (
     calling_app_id             IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     calling_app_doc_id1        IBY_DOCS_PAYABLE_ALL.
                                    calling_app_doc_unique_ref1%TYPE,
     calling_app_doc_id2        IBY_DOCS_PAYABLE_ALL.
                                    calling_app_doc_unique_ref2%TYPE,
     calling_app_doc_id3        IBY_DOCS_PAYABLE_ALL.
                                    calling_app_doc_unique_ref3%TYPE,
     calling_app_doc_id4        IBY_DOCS_PAYABLE_ALL.
                                    calling_app_doc_unique_ref4%TYPE,
     calling_app_doc_id5        IBY_DOCS_PAYABLE_ALL.
                                    calling_app_doc_unique_ref5%TYPE,
     pay_proc_trxn_type_cd      IBY_DOCS_PAYABLE_ALL.
                                    pay_proc_trxn_type_code%TYPE,
     document_id                IBY_DOCS_PAYABLE_ALL.
                                    document_payable_id%TYPE,
     document_amount            IBY_DOCS_PAYABLE_ALL.
                                    document_amount%TYPE,
     document_pay_currency      IBY_DOCS_PAYABLE_ALL.
                                    payment_currency_code%TYPE,
     exclusive_payment_flag     IBY_DOCS_PAYABLE_ALL.
                                    exclusive_payment_flag%TYPE := 'N',
     delivery_channel_code      IBY_DOCS_PAYABLE_ALL.delivery_channel_code%TYPE,
     delivery_chn_format_val    IBY_DELIVERY_CHANNELS_B.format_value%TYPE,
     unique_remit_id_code       IBY_DOCS_PAYABLE_ALL.
                                    unique_remittance_identifier%TYPE,
     PAYMENT_REASON_COMMENTS    IBY_DOCS_PAYABLE_ALL.PAYMENT_REASON_COMMENTS%TYPE,
     SETTLEMENT_PRIORITY        IBY_DOCS_PAYABLE_ALL.SETTLEMENT_PRIORITY%TYPE,
     REMITTANCE_MESSAGE1        IBY_DOCS_PAYABLE_ALL.REMITTANCE_MESSAGE1%TYPE,
     REMITTANCE_MESSAGE2        IBY_DOCS_PAYABLE_ALL.REMITTANCE_MESSAGE2%TYPE,
     REMITTANCE_MESSAGE3        IBY_DOCS_PAYABLE_ALL.REMITTANCE_MESSAGE3%TYPE,
     URI_CHECK_DIGIT            IBY_DOCS_PAYABLE_ALL.URI_CHECK_DIGIT%TYPE,
     EXTERNAL_BANK_ACCOUNT_ID   IBY_DOCS_PAYABLE_ALL.EXTERNAL_BANK_ACCOUNT_ID%TYPE,


     int_bank_num               CE_BANK_BRANCHES_V.bank_number%TYPE,
     int_bank_name              CE_BANK_BRANCHES_V.bank_name%TYPE,
     int_bank_name_alt          CE_BANK_BRANCHES_V.bank_name_alt%TYPE,
     int_bank_branch_num        CE_BANK_BRANCHES_V.branch_number%TYPE,
     int_bank_branch_name       CE_BANK_BRANCHES_V.bank_branch_name%TYPE,
     int_bank_branch_name_alt   CE_BANK_BRANCHES_V.bank_branch_name_alt%TYPE,

     int_bank_acc_num           CE_BANK_ACCOUNTS.bank_account_num%TYPE,
     int_bank_acc_name          CE_BANK_ACCOUNTS.bank_account_name%TYPE,
     int_bank_acc_name_alt      CE_BANK_ACCOUNTS.bank_account_name_alt%TYPE,
     int_bank_acc_type          CE_BANK_ACCOUNTS.bank_account_type%TYPE,
     int_bank_acc_iban          CE_BANK_ACCOUNTS.iban_number%TYPE,
     int_bank_assigned_id1      VARCHAR2(240),
     int_bank_assigned_id2      VARCHAR2(240),
     int_eft_user_number        CE_BANK_ACCOUNTS.eft_user_num%TYPE,
     int_bank_acc_chk_dgts      CE_BANK_ACCOUNTS.check_digits%TYPE,
     int_eft_req_identifier     CE_BANK_ACCOUNTS.
                                    eft_requester_identifier%TYPE,
     int_bank_acc_short_name    CE_BANK_ACCOUNTS.short_account_name%TYPE,
     int_bank_acc_holder_name   CE_BANK_ACCOUNTS.account_holder_name%TYPE,
     int_bank_acc_holder_name_alt
                                CE_BANK_ACCOUNTS.account_holder_name_alt%TYPE,

     payer_le_name              IBY_PP_FIRST_PARTY_V.party_legal_name%TYPE,
     payer_le_country           IBY_PP_FIRST_PARTY_V.party_address_country%TYPE,
     payer_phone                IBY_PP_FIRST_PARTY_V.party_phone%TYPE,
     payer_registration_number  IBY_PP_FIRST_PARTY_V.party_registration_number%TYPE, --added by asarada (SEPA Credit Transfer 3.3)
     payer_tax_registration_number IBY_PAYMENTS_ALL.payer_tax_registration_num%TYPE, --added by asarada (SEPA Credit Transfer 3.3)
     ext_bank_num               IBY_EXT_BANK_ACCOUNTS_V.bank_number%TYPE,
     ext_bank_name              IBY_EXT_BANK_ACCOUNTS_V.bank_name%TYPE,

     ext_bank_name_alt          CE_BANKS_V.bank_name_alt%TYPE,

     ext_bank_branch_num        IBY_EXT_BANK_ACCOUNTS_V.branch_number%TYPE,
     ext_bank_branch_name       IBY_EXT_BANK_ACCOUNTS_V.bank_branch_name%TYPE,

     ext_bank_branch_name_alt   CE_BANK_BRANCHES_V.bank_branch_name_alt%TYPE,

     ext_bank_country           IBY_EXT_BANK_ACCOUNTS_V.country_code%TYPE,

     ext_bank_branch_addr1      CE_BANK_BRANCHES_V.address_line1%TYPE,

     ext_bank_branch_country    CE_BANK_BRANCHES_V.country%TYPE,

     ext_bank_acc_num           IBY_EXT_BANK_ACCOUNTS_V.
                                    bank_account_number%TYPE,
     ext_bank_acc_name          IBY_EXT_BANK_ACCOUNTS_V.bank_account_name%TYPE,
     ext_bank_acc_name_alt      IBY_EXT_BANK_ACCOUNTS_V.
                                    alternate_account_name%TYPE,
     ext_bank_acc_type          IBY_EXT_BANK_ACCOUNTS_V.bank_account_type%TYPE,
     ext_bank_acc_iban          IBY_EXT_BANK_ACCOUNTS_V.iban_number%TYPE,        -- Payee IBAN
     ext_bank_acc_chk_dgts      IBY_EXT_BANK_ACCOUNTS_V.check_digits%TYPE,
     ext_bank_acc_short_name    IBY_EXT_BANK_ACCOUNTS_V.short_acct_name%TYPE,
     ext_bank_acc_holder_name   IBY_EXT_BANK_ACCOUNTS_V.
                                    primary_acct_owner_name%TYPE,

     ext_bank_acc_holder_name_alt
                                CE_BANK_ACCOUNTS_V.bank_account_name_alt%TYPE,
     ext_eft_swift_code IBY_EXT_BANK_ACCOUNTS_INT_V.eft_swift_code%TYPE,   -- Payee BIC (added by sodash)

     payee_party_name           HZ_PARTIES.party_name%TYPE,
     payee_party_addr1          HZ_LOCATIONS.address1%TYPE,
     payee_party_addr2          HZ_LOCATIONS.address2%TYPE,
     payee_party_addr3          HZ_LOCATIONS.address3%TYPE,
     payee_party_city           HZ_LOCATIONS.city%TYPE,

     /*
      * Fix for bug 6713003:
      *
      * The payee address fields are picked up from three
      * possible sources: HR_LOCATIONS, PER_ADDRESSES
      * and HZ_LOCATIONS. Therefore, the field sizes
      * should be the maximum of the corresponding column
      * sizes from these three tables.
      *
      * Usually, HZ_LOCATIONS field sizes are sufficient.
      * But for state, county and provice fields, HR_LOCATIONS /
      * PER_ADDRESSES has larger field sizes.
      *
      * Therefore, for these three fields, we use HR_LOCATIONS
      * for the field sizes.
      */
     payee_party_state          HR_LOCATIONS.region_2%TYPE,
     payee_party_province       HR_LOCATIONS.region_1%TYPE,
     payee_party_county         HR_LOCATIONS.region_1%TYPE,

     payee_party_postal         HZ_LOCATIONS.postal_code%TYPE,
     payee_party_country        HZ_LOCATIONS.country%TYPE,

     bank_charge_bearer         IBY_DOCS_PAYABLE_ALL.bank_charge_bearer%TYPE,
     payment_reason_code        IBY_DOCS_PAYABLE_ALL.payment_reason_code%TYPE,
     payment_method_cd          IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     payment_format_cd          IBY_DOCS_PAYABLE_ALL.payment_format_code%TYPE,

    /*Start of Bug 9704929*/
     payee_party_site_name      HZ_PARTY_SITES.PARTY_SITE_NAME%TYPE
     /*Start of Bug 9704929*/
     );

 /*
  * This record stores the minimum number of fields required
  * to uniquely identify a doc for the calling app.
  *
  * It will be used in exception situations to inform the calling
  * app that a particular doc is in error.
  */
 TYPE basicDocRecType IS RECORD (
     calling_app_id         IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     calling_app_doc_id1    IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref1%TYPE,
     calling_app_doc_id2    IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref2%TYPE,
     calling_app_doc_id3    IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref3%TYPE,
     calling_app_doc_id4    IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref4%TYPE,
     calling_app_doc_id5    IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref5%TYPE,
     pay_proc_trxn_type_cd  IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     document_id            IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE
     );

 TYPE paymentRecType IS RECORD (
     pmt_id	                IBY_PAYMENTS_ALL.payment_id%TYPE,
     pmt_amount                 IBY_PAYMENTS_ALL.payment_amount%TYPE,
     pmt_currency               IBY_PAYMENTS_ALL.payment_currency_code%TYPE,
     pmt_delivery_channel_code  IBY_PAYMENTS_ALL.delivery_channel_code%TYPE,
     pmt_payer_le_country       IBY_PP_FIRST_PARTY_V.party_address_country%TYPE,  -- Payer Country
     pmt_detail                 IBY_PAYMENTS_ALL.payment_details%TYPE,
     pmt_payment_reason_count   NUMBER,
     int_bank_account_iban  IBY_PAYMENTS_ALL.int_bank_account_iban%TYPE,   -- Payer IBAN (added by sodash)
     payer_tax_registration_num IBY_PAYMENTS_ALL.PAYER_TAX_REGISTRATION_NUM %TYPE, --(Added by asarada SEPA Credut Transfer 3.3)
     payer_le_registration_num  IBY_PAYMENTS_ALL.PAYER_LE_REGISTRATION_NUM %TYPE,  --(Added by asarada SEPA Credut Transfer 3.3)
     party_address_line1  IBY_PP_FIRST_PARTY_V.party_address_line1%TYPE,    -- Payer Address Line1 (added by sodash)
     party_address_city  IBY_PP_FIRST_PARTY_V.party_address_city%TYPE,       --  Payer City  (added by sodash)
     party_address_postal_code   IBY_PP_FIRST_PARTY_V.party_address_postal_code%TYPE,  -- Payer Postal Code (added by sodash)
     payer_bank_acc_cur_code     CE_BANK_ACCOUNTS.currency_code%TYPE         -- Internal Bank Account Currency Code
     );

 TYPE instructionRecType is RECORD (
     ins_id                     IBY_PAY_INSTRUCTIONS_ALL.
                                    payment_instruction_id%TYPE,
     ins_amount                 NUMBER,
     ins_document_count         NUMBER
     );

 --
 -- A record to store the details of the validation set
 --
 TYPE valSetRecType IS RECORD (
     doc_id                 IBY_DOCS_PAYABLE_ALL.
                                document_payable_id%TYPE,
     pmt_grp_num            IBY_DOCS_PAYABLE_ALL.
                                payment_grouping_number%TYPE,
     payee_id               IBY_DOCS_PAYABLE_ALL.
                                ext_payee_id%TYPE,
     val_set_code           IBY_VALIDATION_SETS_VL.
                                validation_set_code%TYPE,
     val_code_pkg           IBY_VALIDATION_SETS_VL.
                                validation_code_package%TYPE,
     val_code_entry_point   IBY_VALIDATION_SETS_VL.
                                validation_code_entry_point%TYPE,
     val_assign_id          IBY_VAL_ASSIGNMENTS.
                                validation_assignment_id%TYPE,
     val_assign_entity_type IBY_VAL_ASSIGNMENTS.
                                val_assignment_entity_type%TYPE,
     val_set_name           IBY_VALIDATION_SETS_VL.
                                validation_set_display_name%TYPE
     );

 --
 -- Table of validation set records
 --
 TYPE valSetTabType IS TABLE OF valSetRecType
     INDEX BY BINARY_INTEGER;

 TYPE valSetOuterRecType IS RECORD (
     val_set_count  NUMBER,
     val_set_tbl    valSetTabType
     );

 --
 -- Table of validation set records
 --
 TYPE valSetOuterTabType IS TABLE OF valSetOuterRecType
     INDEX BY VARCHAR2(2000);

 val_set_outer_tbl    valSetOuterTabType;

 --
 -- Document errors table
 --
 TYPE docErrorTabType IS TABLE OF IBY_TRANSACTION_ERRORS%ROWTYPE
     INDEX BY BINARY_INTEGER;

 --
 -- Transaction error tokens table
 --

 TYPE trxnErrTokenTabType IS TABLE OF IBY_TRXN_ERROR_TOKENS%ROWTYPE
     INDEX BY BINARY_INTEGER;

 --
 -- Record to hold document ids.
 --
 -- This record will hold a document payable id and it's
 -- corresponding original document id.
 --
 TYPE docPayRecType IS RECORD (
     doc_id                 IBY_DOCS_PAYABLE_ALL.
                                document_payable_id%TYPE,
     ca_doc_id1             IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref1%TYPE,
     ca_doc_id2             IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref2%TYPE,
     ca_doc_id3             IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref3%TYPE,
     ca_doc_id4             IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref4%TYPE,
     ca_doc_id5             IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_unique_ref5%TYPE,
     ca_doc_ref_num         IBY_DOCS_PAYABLE_ALL.
                                calling_app_doc_ref_number%TYPE,
     ca_id                  IBY_DOCS_PAYABLE_ALL.
                                calling_app_id%TYPE,
     pp_tt_cd               IBY_DOCS_PAYABLE_ALL.
                                pay_proc_trxn_type_code%TYPE,
     pmt_grp_num            IBY_DOCS_PAYABLE_ALL.
                                payment_grouping_number%TYPE,
     payee_id               IBY_DOCS_PAYABLE_ALL.
                                ext_payee_id%TYPE,
     profile_id             IBY_DOCS_PAYABLE_ALL.
                                payment_profile_id%TYPE,
     org_id                 IBY_DOCS_PAYABLE_ALL.
                                org_id%TYPE,
     org_type               IBY_DOCS_PAYABLE_ALL.
                                org_type%TYPE,
     pmt_method_cd          IBY_DOCS_PAYABLE_ALL.
                                payment_method_code%TYPE,
     pmt_format_cd          IBY_DOCS_PAYABLE_ALL.
                                payment_format_code%TYPE,
     pmt_curr_code          IBY_DOCS_PAYABLE_ALL.
                                payment_currency_code%TYPE,
     int_bank_acct_id       IBY_DOCS_PAYABLE_ALL.
                                internal_bank_account_id%TYPE,
     ext_bank_acct_id       IBY_DOCS_PAYABLE_ALL.
                                external_bank_account_id%TYPE,
     pmt_date               IBY_DOCS_PAYABLE_ALL.
                                payment_date%TYPE
     );

 --
 -- The document id table
 --
 TYPE docPayTabType IS TABLE OF docPayRecType
     INDEX BY BINARY_INTEGER;


 --
 -- Record to hold document status.
 --
 -- This record will hold a document payable id, its status
 -- and its corresponding original document id.
 --
 TYPE docStatusRecType IS RECORD (
     doc_id                 IBY_DOCS_PAYABLE_ALL.
                                document_payable_id%TYPE,
     pmt_grp_num            IBY_DOCS_PAYABLE_ALL.
                                payment_grouping_number%TYPE,
     payee_id               IBY_DOCS_PAYABLE_ALL.
                                ext_payee_id%TYPE,
     doc_status             IBY_DOCS_PAYABLE_ALL.
                                document_status%TYPE
     );

 --
 -- The document status table
 --
 TYPE docStatusTabType IS TABLE OF docStatusRecType
     INDEX BY BINARY_INTEGER;

 --
 -- System options record
 --
 TYPE sysOptionsRecType IS RECORD (
     rej_level              IBY_INTERNAL_PAYERS_ALL.
                                document_rejection_level_code%TYPE
     );

 --
 -- System options table
 --
 TYPE sysOptionsTabType IS TABLE OF sysOptionsRecType
     INDEX BY BINARY_INTEGER;

 /*
  * Rejected document id along with its status.
  */
 TYPE rejectedDocRecType IS RECORD (
     doc_id                 IBY_DOCS_PAYABLE_ALL.
                                document_payable_id%TYPE,
     doc_status             IBY_DOCS_PAYABLE_ALL.
                                document_status%TYPE
     );

 /*
  * Table of rejected documents.
  */
 TYPE rejectedDocTabType IS TABLE OF rejectedDocRecType
     INDEX BY BINARY_INTEGER;

 /*
  * Rejected payment id along with its status.
  */
 TYPE rejectedPmtRecType IS RECORD (
     pmt_id                 IBY_PAYMENTS_ALL.
                                payment_id%TYPE,
     pmt_status             IBY_PAYMENTS_ALL.
                                payment_status%TYPE
     );

 /*
  * Table of rejected payments.
  */
 TYPE rejectedPmtTabType IS TABLE OF rejectedPmtRecType
     INDEX BY BINARY_INTEGER;

 /*
  * The record structure below is meant to pull up data fields for
  * character validation. For character validation, all possible fields
  * that could potentially be sent to the bank need to be picked up;
  * this will include data related to the document, payer, payee,
  * payer bank and payee bank (payments have not be created at this
  * stage and so cannot be picked up).
  *
  * Notes:
  * 1. Fields that are not likely to cause character validation errors
  *    have not be included viz., dates, amounts, flags, lookup codes etc.
  * 2. If you feel some field is likely to cause char validation error,
  *    then include it to this list.
  * 3. Document lines are ignored as they are usually not sent to the bank
  */
 TYPE charValRecType IS RECORD (

     /* DOCUMENT */
     document_id
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     ca_id
         IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     calling_app_doc_id1
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref1%TYPE,
     calling_app_doc_id2
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref2%TYPE,
     calling_app_doc_id3
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref3%TYPE,
     calling_app_doc_id4
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref4%TYPE,
     calling_app_doc_id5
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref5%TYPE,
     pay_proc_trxn_type_cd
         IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     ca_doc_ref_num
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_ref_number%TYPE,
     uri
         IBY_DOCS_PAYABLE_ALL.unique_remittance_identifier%TYPE,
     uri_checkdigit
         IBY_DOCS_PAYABLE_ALL.uri_check_digit%TYPE,
     po_number
         IBY_DOCS_PAYABLE_ALL.po_number%TYPE,
     doc_desc
         IBY_DOCS_PAYABLE_ALL.document_description%TYPE,
     bank_ref
         IBY_DOCS_PAYABLE_ALL.bank_assigned_ref_code%TYPE,
     pmt_reason_comments
         IBY_DOCS_PAYABLE_ALL.payment_reason_comments%TYPE,
     remit_msg1
         IBY_DOCS_PAYABLE_ALL.remittance_message1%TYPE,
     remit_msg2
         IBY_DOCS_PAYABLE_ALL.remittance_message2%TYPE,
     remit_msg3
         IBY_DOCS_PAYABLE_ALL.remittance_message3%TYPE,
     delv_chnl_code
         IBY_DELIVERY_CHANNELS_VL.format_value%TYPE,
     pmt_reason
         IBY_PAYMENT_REASONS_VL.format_value%TYPE,
     ca_doc_line_cd
         IBY_DOCUMENT_LINES.calling_app_document_line_code%TYPE,
     line_type
         IBY_DOCUMENT_LINES.line_type%TYPE,
     line_name
         IBY_DOCUMENT_LINES.line_name%TYPE,
     line_desc
         IBY_DOCUMENT_LINES.description%TYPE,
     line_uom
         IBY_DOCUMENT_LINES.unit_of_measure%TYPE,
     line_po_num
         IBY_DOCUMENT_LINES.po_number%TYPE,

     /* PAYER */
     payer_number
         IBY_PP_FIRST_PARTY_V.party_number%TYPE,
     payer_name
         IBY_PP_FIRST_PARTY_V.party_name%TYPE,
     payer_legal_name
         IBY_PP_FIRST_PARTY_V.party_legal_name%TYPE,
     payer_tax_id
         IBY_PP_FIRST_PARTY_V.party_tax_id%TYPE,
     payer_add1
         IBY_PP_FIRST_PARTY_V.party_address_line1%TYPE,
     payer_add2
         IBY_PP_FIRST_PARTY_V.party_address_line2%TYPE,
     payer_add3
         IBY_PP_FIRST_PARTY_V.party_address_line3%TYPE,
     payer_city
         IBY_PP_FIRST_PARTY_V.party_address_city%TYPE,
     payer_county
         IBY_PP_FIRST_PARTY_V.party_address_county%TYPE,
     payer_state
         IBY_PP_FIRST_PARTY_V.party_address_state%TYPE,
     payer_country
         IBY_PP_FIRST_PARTY_V.party_address_country%TYPE,
     payer_postcode
         IBY_PP_FIRST_PARTY_V.party_address_postal_code%TYPE,

     /* PAYER BANK */
     payer_bank_name
         CE_BANK_BRANCHES_V.bank_name%TYPE,
     payer_bank_number
         CE_BANK_BRANCHES_V.bank_number%TYPE,
     payer_bank_branch_num
         CE_BANK_BRANCHES_V.branch_number%TYPE,
     payer_bank_branch_name
         CE_BANK_BRANCHES_V.bank_branch_name%TYPE,
     payer_bank_swift_code
         CE_BANK_BRANCHES_V.eft_swift_code%TYPE,
     payer_bank_add1
         CE_BANK_BRANCHES_V.address_line1%TYPE,
     payer_bank_add2
         CE_BANK_BRANCHES_V.address_line2%TYPE,
     payer_bank_add3
         CE_BANK_BRANCHES_V.address_line3%TYPE,
     payer_bank_city
         CE_BANK_BRANCHES_V.city%TYPE,
     payer_bank_county
         CE_BANK_BRANCHES_V.province%TYPE,
     payer_bank_state
         CE_BANK_BRANCHES_V.state%TYPE,
     payer_bank_country
         CE_BANK_BRANCHES_V.country%TYPE,
     payer_bank_postcode
         CE_BANK_BRANCHES_V.zip%TYPE,
     payer_bank_name_alt
         CE_BANK_BRANCHES_V.bank_name_alt%TYPE,
     payer_bank_branch_name_alt
         CE_BANK_BRANCHES_V.bank_branch_name_alt%TYPE,

     payer_bank_acct_name_alt
         CE_BANK_ACCOUNTS.bank_account_name_alt%TYPE,
     payer_bank_acct_type
         CE_BANK_ACCOUNTS.bank_account_type%TYPE,
     payer_bank_assigned_id1
         VARCHAR2(240),
     payer_bank_assigned_id2
         VARCHAR2(240),
     payer_eft_user_number
         CE_BANK_ACCOUNTS.eft_user_num%TYPE,
     payer_eft_req_identifier
         CE_BANK_ACCOUNTS.eft_requester_identifier%TYPE,
     payer_bank_acct_short_name
         CE_BANK_ACCOUNTS.short_account_name%TYPE,
     payer_bank_acct_hold_name_alt
         CE_BANK_ACCOUNTS.account_holder_name_alt%TYPE,
     payer_bank_acct_holder_name
         CE_BANK_ACCOUNTS.account_holder_name%TYPE,
     payer_bank_acct_num
         CE_BANK_ACCOUNTS.bank_account_num%TYPE,
     payer_bank_acct_name
         CE_BANK_ACCOUNTS.bank_account_name%TYPE,
     payer_bank_acct_iban_num
         CE_BANK_ACCOUNTS.iban_number%TYPE,
     payer_bank_acct_checkdigits
         CE_BANK_ACCOUNTS.check_digits%TYPE,

     /* PAYEE */
     payee_number
         HZ_PARTIES.party_number%TYPE,
     payee_name
         HZ_PARTIES.party_name%TYPE,
     payee_tax_id
         HZ_PARTIES.tax_reference%TYPE,
     payee_add1
         HZ_LOCATIONS.address1%TYPE,
     payee_add2
         HZ_LOCATIONS.address2%TYPE,
     payee_add3
         HZ_LOCATIONS.address3%TYPE,
     payee_city
         HZ_LOCATIONS.city%TYPE,
     payee_county
         HZ_LOCATIONS.county%TYPE,
     payee_province
         HZ_LOCATIONS.province%TYPE,
     payee_state
         HZ_LOCATIONS.state%TYPE,
     payee_country
         HZ_LOCATIONS.country%TYPE,
     payee_postcode
         HZ_LOCATIONS.postal_code%TYPE,

     /* PAYEE BANK */
     payee_bank_name
         IBY_EXT_BANK_ACCOUNTS_V.bank_name%TYPE,
     payee_bank_number
         IBY_EXT_BANK_ACCOUNTS_V.bank_number%TYPE,
     payee_bank_branch_num
         IBY_EXT_BANK_ACCOUNTS_V.branch_number%TYPE,
     payee_bank_branch_name
         IBY_EXT_BANK_ACCOUNTS_V.bank_branch_name%TYPE,
     payee_bank_acct_holder_name
         IBY_EXT_BANK_ACCOUNTS_V.primary_acct_owner_name%TYPE,
     payee_bank_acct_num
         IBY_EXT_BANK_ACCOUNTS_V.bank_account_number%TYPE,
     payee_bank_acct_name
         IBY_EXT_BANK_ACCOUNTS_V.bank_account_name%TYPE,
     payee_bank_acct_iban_num
         IBY_EXT_BANK_ACCOUNTS_V.iban_number%TYPE,
     payee_bank_swift_code
         IBY_EXT_BANK_ACCOUNTS_V.eft_swift_code%TYPE,
     payee_bank_acct_checkdigits
         IBY_EXT_BANK_ACCOUNTS_V.check_digits%TYPE,
     payee_bank_add1
         VARCHAR2(240),
     payee_bank_add2
         VARCHAR2(240),
     payee_bank_add3
         VARCHAR2(240),
     payee_bank_city
         VARCHAR2(240),
     payee_bank_county
         VARCHAR2(240),
     payee_bank_state
         VARCHAR2(240),
     payee_bank_country
         VARCHAR2(240),
     payee_bank_postcode
         VARCHAR2(240),
     payee_bank_name_alt
         VARCHAR2(240),
     payee_bank_branch_name_alt
         VARCHAR2(240),
     payee_bank_country_code
         IBY_EXT_BANK_ACCOUNTS_V.country_code%TYPE,
     payee_bank_account_name_alt
         IBY_EXT_BANK_ACCOUNTS_V.alternate_account_name%TYPE,
     payee_bank_account_type
         IBY_EXT_BANK_ACCOUNTS_V.bank_account_type%TYPE,
     payee_bank_account_short_name
         IBY_EXT_BANK_ACCOUNTS_V.short_acct_name%TYPE,
     payee_bank_acct_hold_name_alt
         VARCHAR2(240)
     );

 --
 -- Record to hold default payment format for each payee.
 --
 TYPE payeeFormatRecType IS RECORD (
     payee_id               IBY_EXTERNAL_PAYEES_ALL.
                                ext_payee_id%TYPE,
     payment_format_cd      IBY_EXTERNAL_PAYEES_ALL.
                                payment_format_code%TYPE
     );

 --
 -- The payee formats table
 --
 TYPE payeeFormatTabType IS TABLE OF payeeFormatRecType
     INDEX BY BINARY_INTEGER;

 --
 -- Record to format linked to each profile.
 --
 TYPE profileFormatRecType IS RECORD (
     profile_id             IBY_PAYMENT_PROFILES.
                                payment_profile_id%TYPE,
     payment_format_cd      IBY_PAYMENT_PROFILES.
                                payment_format_code%TYPE,
     bepid                  IBY_PAYMENT_PROFILES.
                                bepid%TYPE,
     transmit_protocol_cd   IBY_PAYMENT_PROFILES.
                                transmit_protocol_code%TYPE
     );

 --
 -- The profile formats table
 --
 TYPE profileFormatTabType IS TABLE OF profileFormatRecType
     INDEX BY BINARY_INTEGER;


/*--------------------------------------------------------------------
 | NAME:
 |     initDocumentData
 |
 | PURPOSE:
 |     Initializes the document record from Oracle Payment's tables.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE initDocumentData(
     p_document_id  IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     x_document_rec IN OUT NOCOPY documentRecType,
     p_isOnline     IN VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     initCharValData
 |
 | PURPOSE:
 |     Initializes the character validation record with data from
 |     Oracle Payment's tables.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE initCharValData(
     p_document_id  IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     x_charval_rec IN OUT NOCOPY charValRecType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     initPaymentData
 |
 | PURPOSE:
 |     Initializes the document record from Oracle Payment's tables.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE initPaymentData(
     p_payment_id  IN IBY_PAYMENTS_ALL.payment_id%type,
     x_payment_rec IN OUT NOCOPY paymentRecType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     initInstructionData
 |
 | PURPOSE:
 |     Initializes the instruction record from Oracle Payment's tables.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
PROCEDURE initInstructionData (
     p_instruction_id  IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%type,
     x_instruction_rec IN OUT NOCOPY instructionRecType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     applyDocumentValidationSets
 |
 | PURPOSE:
 |     Picks up Validation Sets which can be applied and validates
 |     the documents in the payment request accordingly.
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/

 PROCEDURE applyDocumentValidationSets(
     p_pay_service_request_id IN IBY_PAY_SERVICE_REQUESTS.
                                     payment_service_request_id%TYPE,
     p_doc_rejection_level    IN IBY_INTERNAL_PAYERS_ALL.
                                     document_rejection_level_code%TYPE,
     p_is_singpay_flag        IN BOOLEAN,
     x_return_status          IN OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performOnlineValidations
 |
 | PURPOSE:
 |     Picks up validation sets which can be applied and validates
 |     the given document accordingly.
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performOnlineValidations(
     p_document_id     IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     x_return_status   IN OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     insert_transaction_errors
 |
 | PURPOSE:
 |     Inserts the transaction errors into IBY_TRANSACTION_ERRORS
 |     or IBY_TRANSACTION_ERRORS_GT depending upon the online flag.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insert_transaction_errors(
     p_isOnlineVal     IN            VARCHAR2,
     x_docErrorTab     IN OUT NOCOPY docErrorTabType,
     x_trxnErrTokenTab IN OUT NOCOPY trxnErrTokenTabType
     );

 PROCEDURE insert_transaction_errors(
     p_isOnlineVal IN VARCHAR2,
     x_docErrorTab IN OUT NOCOPY docErrorTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     insertIntoErrorTable
 |
 | PURPOSE:
 |     Inserts the document validation error into PLSQL Table
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insertIntoErrorTable(
     x_docErrorRec IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
     x_docErrorTab IN OUT NOCOPY docErrorTabType,
     x_trxnErrTokenTab IN OUT NOCOPY trxnErrTokenTabType
     );

 PROCEDURE insertIntoErrorTable(
     x_docErrorRec IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
     x_docErrorTab IN OUT NOCOPY docErrorTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performDBUpdates
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performDBUpdates(
     p_pay_service_request_id
                           IN IBY_PAY_SERVICE_REQUESTS.
                               payment_service_request_id%type,
     p_allDocsTab          IN docPayTabType,
     x_errorDocsTab        IN OUT NOCOPY docStatusTabType,
     p_allDocsSuccessFlag  IN BOOLEAN,
     p_allDocsFailedFlag   IN BOOLEAN,
     p_rejectionLevel      IN VARCHAR2,
     x_txnErrorsTab        IN OUT NOCOPY docErrorTabType,
     x_errTokenTab         IN OUT NOCOPY trxnErrTokenTabType,
     x_return_status       IN OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     failRelatedDocs
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE failRelatedDocs(
     p_allDocsTab        IN            docPayTabType,
     x_failedDocsTab     IN OUT NOCOPY docStatusTabType,
     x_docErrorTab       IN OUT NOCOPY docErrorTabType,
     x_errTokenTab       IN OUT NOCOPY trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     failAllDocsForPayee
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE failAllDocsForPayee(
     p_allDocsTab        IN            docPayTabType,
     x_failedDocsTab     IN OUT NOCOPY docStatusTabType,
     x_docErrorTab       IN OUT NOCOPY docErrorTabType,
     x_errTokenTab       IN OUT NOCOPY trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     failAllDocsForRequest
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE failAllDocsForRequest(
     p_allDocsTab        IN            docPayTabType,
     x_failedDocsTab     IN OUT NOCOPY docStatusTabType,
     x_docErrorTab       IN OUT NOCOPY docErrorTabType,
     x_errTokenTab       IN OUT NOCOPY trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     evaluateCondition
 |
 | PURPOSE:
 |     Function to evaluate a specific condition for a
 |     particular field on the basis of a token. This will
 |     minimize code in the Validation entry point procedures.
 |
 |     The possible token values are:
 |     EQUALSTO, NOTEQUALSTO, NOTNULL, LENGTH, MAXLENGTH,
 |     MINLENGTH, MIN, MAX, MASK, LIKE, SET, CUSTOM, ASSIGN,
 |     TYPE.
 |
 |     For token 'CUSTOM', this makes a dynamic PLSQL call to
 |     a procedure specified in the parameter 'p_value'.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE evaluateCondition(
     p_fieldName   IN VARCHAR2,
     p_fieldValue  IN VARCHAR2,
     p_token       IN VARCHAR2,
     p_char_value  IN VARCHAR2,
     p_num_value   IN NUMBER,
     x_valResult   OUT NOCOPY BOOLEAN,
     x_docErrorRec IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE
     );

 PROCEDURE getParamValue (
      p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.
                                     validation_assignment_id%TYPE,
      p_validation_set_code   IN IBY_VALIDATION_SETS_VL.
                                     validation_set_code%TYPE,
      p_validation_param_code IN IBY_VALIDATION_PARAMS_B.
                                     validation_parameter_code%TYPE,
      p_value                 OUT NOCOPY VARCHAR2);

 PROCEDURE getDocumentFieldValue (
      p_field_name	IN VARCHAR2,
      p_document_rec	IN documentRecType,
      p_field_value	OUT NOCOPY VARCHAR2);

 PROCEDURE getPaymentFieldValue (
      p_field_name	IN VARCHAR2,
      p_payment_rec	IN paymentRecType,
      p_field_value	OUT NOCOPY VARCHAR2);

 PROCEDURE getInstructionFieldValue (
      p_field_name	IN VARCHAR2,
      p_instruction_rec	IN instructionRecType,
      p_field_value	OUT NOCOPY VARCHAR2);

/*--------------------------------------------------------------------
 | NAME:
 |     getRequestAttributes
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getRequestAttributes(
     p_payReqId   IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     x_caPayReqCd IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.call_app_pay_service_req_code%TYPE,
     x_caId       IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE
     );

/*--------------------------------------------------------------------
 | NAME:
 |     raiseBizEvents
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE raiseBizEvents(
     p_payreq_id          IN            VARCHAR2,
     p_cap_payreq_id      IN            VARCHAR2,
     p_cap_id             IN            NUMBER,
     x_allDocsSuccessFlag IN OUT NOCOPY BOOLEAN,
     p_rejectionLevel     IN            VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfDocFailed
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfDocFailed(
     p_doc_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_failedDocsTab IN docStatusTabType
     )
     RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfAllDocsFailed
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfAllDocsFailed(
     p_allDocsTab    IN docPayTabType,
     p_failedDocsTab IN docStatusTabType
     )
     RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     validateProfileFromProfDrivers
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 FUNCTION validateProfileFromProfDrivers(
     p_profile_id        IN IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     p_org_id            IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     p_org_type          IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     p_pmt_method_cd     IN IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     p_pmt_currency      IN IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     p_int_bank_acct_id  IN IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE
     )
     RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |     getXMLClob
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 FUNCTION getXMLClob(
     p_payreq_id     IN VARCHAR2
     )
     RETURN CLOB;

/*--------------------------------------------------------------------
 | NAME:
 |     retrieveErrorMSG
 |
 | PURPOSE:
 |     Function to retrieve an error message according to an object
 |     code and an error message number provided.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE retrieveErrorMSG (
            p_object_code   IN fnd_lookups.lookup_code%TYPE,
            p_msg_name      IN fnd_new_messages.message_name%TYPE,
            p_message       IN OUT NOCOPY fnd_new_messages.message_text%TYPE
            );

/*--------------------------------------------------------------------
 | NAME:
 |     getDocRejLevelSysOption
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getDocRejLevelSysOption
     RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     checkProfileFormatCompat
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkProfileFormatCompat(
     p_doc_id            IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_payee_id          IN IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE,
     p_profile_id        IN IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE
     ) RETURN BOOLEAN;



/*--------------------------------------------------------------------
 | NAME:
 |     getRejectedDocs
 |
 | PURPOSE:
 |     Performs a database query to get all failed documents for
 |     the given payment request. These failed documents are put
 |     into data structure and returned to the caller.
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getRejectedDocs(
     p_payreq_id    IN VARCHAR2,
     x_docIDTab     IN OUT NOCOPY IBY_DISBURSE_UI_API_PUB_PKG.docPayIDTab,
     x_docStatusTab IN OUT NOCOPY IBY_DISBURSE_UI_API_PUB_PKG.docPayStatusTab
     );

END IBY_VALIDATIONSETS_PUB;

/
