--------------------------------------------------------
--  DDL for Package OKS_MASS_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_MASS_UPDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRMUPS.pls 120.14.12000000.1 2007/01/16 22:11:29 appldev ship $ */

---------------------------------------------------------------------------
 -- Constants used for Message Logging
---------------------------------------------------------------------------
   g_level_unexpected     CONSTANT NUMBER         := fnd_log.level_unexpected;
   g_level_error          CONSTANT NUMBER         := fnd_log.level_error;
   g_level_exception      CONSTANT NUMBER         := fnd_log.level_exception;
   g_level_event          CONSTANT NUMBER         := fnd_log.level_event;
   g_level_procedure      CONSTANT NUMBER         := fnd_log.level_procedure;
   g_level_statement      CONSTANT NUMBER         := fnd_log.level_statement;
   g_level_current        CONSTANT NUMBER   := fnd_log.g_current_runtime_level;
   g_module_current       CONSTANT VARCHAR2 (255) := 'oks.plsql.oks_int_mass_edit';
---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
   g_required_value       CONSTANT VARCHAR2 (200) := okc_api.g_required_value;
   g_invalid_value        CONSTANT VARCHAR2 (200) := okc_api.g_invalid_value;
   g_col_name_token       CONSTANT VARCHAR2 (200) := okc_api.g_col_name_token;
   g_parent_table_token   CONSTANT VARCHAR2 (200) := okc_api.g_parent_table_token;
   g_child_table_token    CONSTANT VARCHAR2 (200) := okc_api.g_child_table_token;
   g_unexpected_error     CONSTANT VARCHAR2 (200) := 'OKC_CONTRACTS_UNEXP_ERROR';
   g_sqlerrm_token        CONSTANT VARCHAR2 (200) := 'SQLerrm';
   g_sqlcode_token        CONSTANT VARCHAR2 (200) := 'SQLcode';
   g_uppercase_required   CONSTANT VARCHAR2 (200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
---------------------------------------------------------------------------
 -- GLOBAL EXCEPTION
---------------------------------------------------------------------------
   g_exception_halt_validation     EXCEPTION;
---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
   g_pkg_name             CONSTANT VARCHAR2 (200)    := 'OKSMUPDB';
   g_app_name             CONSTANT VARCHAR2 (3)      := 'OKS';
   g_num_one              CONSTANT NUMBER            := 1;
   l_api_version          CONSTANT NUMBER            := 1.0;
   l_init_msg_list        CONSTANT VARCHAR2 (1)      := okc_api.g_false;
---------------------------------------------------------------------------
-- Package and functions
---------------------------------------------------------------------------
   TYPE batch_rules_rec_type IS RECORD (
      billing_profile_id            oks_billing_profiles_b.ID%TYPE,
      invoicing_rule                oks_billing_profiles_b.invoice_object1_id1%TYPE,
      accounting_rule               oks_billing_profiles_b.account_object1_id1%TYPE,
      transfer_date                 DATE,
      credit_option                 oks_batch_rules.credit_option%TYPE,
      termination_reason_code       oks_batch_rules.termination_reason_code%TYPE,
      retain_contract_number_flag   oks_batch_rules.retain_contract_number_flag%TYPE,
      contract_modifier             oks_batch_rules.contract_modifier%TYPE,
      contract_status               oks_batch_rules.contract_status%TYPE,
      transfer_notes_flag           oks_batch_rules.transfer_notes_flag%TYPE,
      transfer_attachments_flag     oks_batch_rules.transfer_attachments_flag%TYPE,
      bill_lines_flag               oks_batch_rules.bill_lines_flag%TYPE,
      transfer_option               oks_batch_rules.transfer_option_code%TYPE,
      bill_account_id               oks_batch_rules.bill_account_id%TYPE,
      ship_account_id               oks_batch_rules.ship_account_id%TYPE,
      bill_address_id               oks_batch_rules.bill_address_id%TYPE,
      ship_address_id               oks_batch_rules.ship_address_id%TYPE,
      bill_contact_id               oks_batch_rules.bill_contact_id%TYPE,
--    ship_contact_id               oks_batch_rules.ship_contact_id%TYPE,
      new_customer_id               NUMBER, --oks_batch_rules.new_account_id%TYPE,
      new_party_id                  NUMBER,
      party_name                    hz_parties.party_name%TYPE,
      Batch_id                      NUMBER
   );


TYPE batch_rules_trm_type IS  RECORD
(
credit_option                 oks_batch_rules.credit_option%TYPE,
      termination_reason_code       oks_batch_rules.termination_reason_code%TYPE
);
   TYPE jtf_note_rec_type IS RECORD (
      jtf_note_id          NUMBER,
      source_object_code   VARCHAR2 (240),
      note_status          VARCHAR2 (240),
      note_type            VARCHAR2 (240),
      notes                VARCHAR2 (2000),
      notes_detail         VARCHAR2 (32767),
      created_by           NUMBER,
      last_updated_by      NUMBER,
      last_update_login    NUMBER
   );

   TYPE jtf_note_tbl_type IS TABLE OF jtf_note_rec_type
      INDEX BY BINARY_INTEGER;

   l_notes_tbl                     jtf_note_tbl_type;

   -- Billing rec
   TYPE billing_rec_type IS RECORD (
      start_date         DATE,
      end_date           DATE,
      inv_rule_id        NUMBER,
      schedule_type      VARCHAR2 (1),
      billing_type       VARCHAR2 (10),
      freq_period        VARCHAR2 (10),
      invoice_offset     NUMBER,
      interface_offset   NUMBER,
      amount             NUMBER,
      currency_code      VARCHAR2 (10)
   );

   TYPE setup_rec IS RECORD (
      pdf_id       NUMBER,
      qcl_id       NUMBER,
      cgp_new_id   NUMBER,
      rle_code     oks_k_defaults.rle_code%TYPE
   );
 FUNCTION validate_account_id (
      p_account_id  NUMBER,
      p_party_id    Number,
      p_org_id      NUMBER
      ) return number;
  Function Get_address
   (P_address_id  Number,
    p_Account_id  Number,
    p_party_id  Number,
    P_Site_use  Varchar2,
    P_org_id  Number
    )  Return Number;
   PROCEDURE update_contracts (
      p_api_version            IN           NUMBER,
      p_init_msg_list          IN           VARCHAR2,
      p_batch_type             IN           VARCHAR2,
      p_batch_id               IN           NUMBER,
      p_new_acct_id            IN           NUMBER,
      p_old_acct_id            IN           NUMBER,
      x_return_status          OUT NOCOPY   VARCHAR2,
      x_msg_count              OUT NOCOPY   NUMBER,
      x_msg_data               OUT NOCOPY   VARCHAR2
   );

   FUNCTION check_relation (
      p_old_customer             IN       VARCHAR2,
      p_new_customer             IN       VARCHAR2,
      p_transfer_date            IN       DATE
   )
      RETURN VARCHAR2;

   Function get_ste_code(p_sts_code Varchar2) return Varchar2;



   FUNCTION get_end_date (
      p_sdate                    IN       DATE,
      p_edate                    IN       DATE,
      p_ins_date                 IN       DATE
   )
      RETURN DATE;

   FUNCTION get_status (
      p_start_date               IN       VARCHAR2,
      p_end_date                 IN       VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION get_seq_no (
      p_type                     IN       VARCHAR2,
      p_var                      IN       VARCHAR2,
      p_end_date                 IN       DATE
   )
      RETURN NUMBER;

   FUNCTION get_line_number (
      p_type                  IN             VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION get_Topline_number (
      p_type                  IN             VARCHAR2
   )
      RETURN NUMBER;


   FUNCTION site_address (
      p_customer_id          IN              NUMBER,
      p_party_id             IN              NUMBER,
      p_code                 IN              VARCHAR2,
      p_org_id               IN              NUMBER
   )
      RETURN NUMBER;

Function get_modifier(Contract_id  Number) return varchar2 ;
Function Negotiated_amount
        (P_start_date IN Date
        ,P_end_date IN Date
        ,P_price_uom IN Varchar2
        ,P_period_type IN Varchar2
        ,P_period_start  IN Varchar2
        ,P_new_start_date  IN Date
        ,P_amount  IN  Number
        ,P_Currency  IN  Varchar2)  Return Number ;

  Procedure Create_transaction_source
                    (
                       P_Batch_id          Number,
                       p_source_line_id    Number,
                       P_target_line_id    Number,
                       p_source_chr_id     Number,
                       p_target_chr_id     Number,
                       p_transaction       Varchar2,
                       x_return_status    OUT NOCOPY Varchar2,
                       x_msg_count        OUT NOCOPY Number,
                       x_msg_data         OUT NOCOPY Varchar2
                    );
Function get_status_code(p_ste_code Varchar2) return Varchar2;
Function get_line_status(p_lse_id Number,P_start_date date, p_end_date Date, P_line_status varchar2,p_batch_status Varchar2) return Varchar2 ;


END;




 

/
