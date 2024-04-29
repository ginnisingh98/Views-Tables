--------------------------------------------------------
--  DDL for Package OKS_EXTWAR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_EXTWAR_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRUTLS.pls 120.10 2006/07/13 06:10:07 nechatur noship $ */

   ---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
   g_required_value       CONSTANT VARCHAR2 (200) := okc_api.g_required_value;
   g_invalid_value        CONSTANT VARCHAR2 (200)  := okc_api.g_invalid_value;
   g_col_name_token       CONSTANT VARCHAR2 (200) := okc_api.g_col_name_token;
   g_parent_table_token   CONSTANT VARCHAR2 (200)
                                              := okc_api.g_parent_table_token;
   g_child_table_token    CONSTANT VARCHAR2 (200)
                                               := okc_api.g_child_table_token;
   g_unexpected_error     CONSTANT VARCHAR2 (200)
                                               := 'OKC_CONTRACTS_UNEXP_ERROR';
   g_sqlerrm_token        CONSTANT VARCHAR2 (200)   := 'SQLerrm';
   g_sqlcode_token        CONSTANT VARCHAR2 (200)   := 'SQLcode';
   g_uppercase_required   CONSTANT VARCHAR2 (200)
                                        := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
---------------------------------------------------------------------------
   g_exception_halt_validation     EXCEPTION;
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
   g_pkg_name             CONSTANT VARCHAR2 (200)   := 'OKSOMINT';
   g_app_name             CONSTANT VARCHAR2 (3)     := 'OKS';
   g_fnd_log_option       CONSTANT VARCHAR2 (30)
                                := NVL (fnd_profile.VALUE ('OKS_DEBUG'), 'N');
   g_app_id               CONSTANT NUMBER           := 515;
---------------------------------------------------------------------------

   -- Constants used for Message Logging
   g_level_unexpected     CONSTANT NUMBER         := fnd_log.level_unexpected;
   g_level_error          CONSTANT NUMBER           := fnd_log.level_error;
   g_level_exception      CONSTANT NUMBER          := fnd_log.level_exception;
   g_level_event          CONSTANT NUMBER           := fnd_log.level_event;
   g_level_procedure      CONSTANT NUMBER          := fnd_log.level_procedure;
   g_level_statement      CONSTANT NUMBER          := fnd_log.level_statement;
   g_level_current        CONSTANT NUMBER  := fnd_log.g_current_runtime_level;
   g_module_current       CONSTANT VARCHAR2 (255)
                                               := 'oks.plsql.oks_int_utl_pvt';
------------------------------------------------------------------------------------------
   g_jtf_party            CONSTANT VARCHAR2 (30)    := 'OKX_PARTY';
   g_jtf_covlvl           CONSTANT VARCHAR2 (30)    := 'OKX_COVSYST';
   g_jtf_custacct         CONSTANT VARCHAR2 (30)    := 'OKX_CUSTACCT';
   g_jtf_cusprod          CONSTANT VARCHAR2 (40)    := 'OKX_CUSTPROD';
--G_JTF_Sysitem    CONSTANT  VARCHAR2(30)  := 'X_
   g_jtf_billto           CONSTANT VARCHAR2 (30)    := 'OKX_BILLTO';
   g_jtf_shipto           CONSTANT VARCHAR2 (30)    := 'OKX_SHIPTO';
   g_jtf_warr             CONSTANT VARCHAR2 (30)    := 'OKX_WARRANTY';
   g_jtf_extwar           CONSTANT VARCHAR2 (30)    := 'OKX_SERVICE';
   g_jtf_invrule          CONSTANT VARCHAR2 (30)    := 'OKX_INVRULE';
   g_jtf_acctrule         CONSTANT VARCHAR2 (30)    := 'OKX_ACCTRULE';
   g_jtf_payterm          CONSTANT VARCHAR2 (30)    := 'OKX_PPAYTERM';
   g_jtf_price            CONSTANT VARCHAR2 (30)    := 'OKX_PRICE';
   g_jtf_usage            CONSTANT VARCHAR2 (30)    := 'OKX_USAGE';

   TYPE war_rec_type IS RECORD (
      service_item_id        NUMBER,
      duration_quantity      NUMBER,
      duration_period        VARCHAR2 (20),
      coverage_schedule_id   NUMBER,
      warranty_start_date    DATE,
      warranty_end_date      DATE
   );

   TYPE header_rec_type IS RECORD (
      contract_number                VARCHAR2 (120),
      sts_code                       VARCHAR2 (30),
      class_code                     VARCHAR2 (30),
      authoring_org_id               NUMBER,
      party_id                       NUMBER,
      invoice_to_contact_id          NUMBER,
      bill_to_id                     NUMBER,
      ship_to_id                     NUMBER,
      cust_po_number                 VARCHAR2 (240),
      agreement_id                   NUMBER,
      currency                       VARCHAR2 (15),
      accounting_rule_id             NUMBER,
      invoice_rule_id                NUMBER,
      order_hdr_id                   NUMBER,
      price_list_id                  NUMBER,
      hdr_payment_term_id            NUMBER,
      hdr_cvn_type                   VARCHAR2 (25),
      hdr_cvn_rate                   NUMBER,
      hdr_cvn_date                   DATE,
      hdr_tax_exemption_id           NUMBER,
      hdr_tax_status_flag            VARCHAR2 (30),
      ship_to_contact_id             NUMBER,
      salesrep_id                    NUMBER,
      ccr_number                     VARCHAR2 (80),
      ccr_exp_date                   DATE
--Added for R12 eBTax Uptake by rsu
      ,
      exemption_certificate_number   VARCHAR2 (80),
      exemption_reason_code          VARCHAR2 (30),
      tax_classification_code        VARCHAR2 (50)  /* nechatur 12-07-06 bug#5380870 Increased the tax_classification_code length from 30 to 50 */
--End: Added for R12 eBTax Uptake by rsu
   );

   TYPE line_rec_type IS RECORD (
      k_line_number                  VARCHAR2 (150),
      org_id                         NUMBER,
      srv_id                         NUMBER,
      srv_segment1                   VARCHAR2 (240),
      srv_desc                       VARCHAR2 (240),
      srv_sdt                        DATE,
      srv_edt                        DATE,
      bill_to_id                     NUMBER,
      ship_to_id                     NUMBER,
      order_line_id                  NUMBER,
      coverage_schd_id               NUMBER,
      amount                         NUMBER,
      unit_selling_percent           NUMBER,
      unit_selling_price             NUMBER,
      customer_acct_id               NUMBER,
      invoice_to_contact_id          NUMBER,
      qty                            NUMBER,
      invoicing_rule_id              NUMBER,
      accounting_rule_id             NUMBER,
      commitment_id                  NUMBER,
      tax_amount                     NUMBER,
      ln_price_list_id               NUMBER
--22-NOV-2005 mchoudha added for PPC
      ,
      pricing_quantity               NUMBER,
      pricing_quantity_uom           VARCHAR2 (3),
      order_quantity_uom             VARCHAR2 (3)
--End PPC
--Added for R12 eBTax Uptake by rsu
      ,
      exemption_certificate_number   VARCHAR2 (80),
      exemption_reason_code          VARCHAR2 (30),
      tax_classification_code        VARCHAR2 (50),  /* nechatur 12-07-06 bug#5380870 Increased the tax_classification_code length from 30 to 50 */
      tax_status                     VARCHAR2 (30)
--End: Added for R12 eBTax Uptake by rsu
   );

   TYPE war_tbl IS TABLE OF war_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE l_line_tbl_type IS TABLE OF oks_extwarprgm_pvt.k_line_service_rec_type
      INDEX BY BINARY_INTEGER;

   SUBTYPE l_covlvl_rec IS oks_extwarprgm_pvt.k_line_covered_level_rec_type;

   TYPE service_rec IS RECORD (
      order_line_id     NUMBER,
      srv_ref_line_id   NUMBER,
      start_date        DATE,
      end_date          DATE,
      order_header_id   NUMBER,
      service_item_id   NUMBER
   );

   TYPE service_tbl IS TABLE OF service_rec
      INDEX BY BINARY_INTEGER;

   TYPE contract_rec IS RECORD (
      hdr_id                   NUMBER,
      hdr_org_id               NUMBER,
      hdr_sdt                  DATE,
      hdr_edt                  DATE,
      hdr_sts                  VARCHAR2 (30),
      contract_number          VARCHAR2 (40),
      service_line_id          NUMBER,
      service_line_number      VARCHAR2 (150),
      service_inventory_id     NUMBER,
      object_line_id           NUMBER,
      service_name             VARCHAR2 (240),
      service_description      VARCHAR2 (240),
      service_sdt              DATE,
      service_edt              DATE,
      service_bill_2_id        NUMBER,
      service_ship_2_id        NUMBER,
      service_order_line_id    NUMBER,
      service_amount           NUMBER,
      service_tax_amount       NUMBER,                          --bug 3736860
      tax_code                 NUMBER,
      service_unit_price       NUMBER,
      service_currency         VARCHAR2 (15),
      service_cov_id           NUMBER,
      k_item_id                NUMBER,
      cp_qty                   NUMBER,
      warranty_flag            VARCHAR2 (2),
      cust_account             NUMBER,
      invoice_rule_id          NUMBER,
      accounting_rule_id       NUMBER,
      price_list_id            NUMBER,
      payment_term_id          NUMBER,
      hdr_acct_rule_id         NUMBER,
      hdr_inv_rule_id          NUMBER,
      ar_interface_yn          VARCHAR2 (1),
      summary_trx_yn           VARCHAR2 (1),
      hold_billing             VARCHAR2 (1),
      inv_trx_type             VARCHAR2 (40),
      payment_type             VARCHAR2 (30),
      organization_id          NUMBER,
      cvn_type                 VARCHAR2 (30),
      cvn_rate                 NUMBER,
      cvn_date                 DATE,
      cvn_euro_rate            NUMBER,
      resource_id              NUMBER,
      GROUP_ID                 NUMBER,
      access_level             VARCHAR2 (3),
      cle_id_renewed           VARCHAR2 (240),
      sts_code                 VARCHAR2 (30),
      prod_sts_code            VARCHAR2 (30),
      prod_sdt                 DATE,
      prod_edt                 DATE,
      prod_term_date           DATE,
      prod_name                VARCHAR2 (240),
      prod_description         VARCHAR2 (240),
      prod_line_renewal_type   VARCHAR2 (30),
      start_delay              NUMBER,
      upg_orig_system_ref      VARCHAR2 (60),
      upg_orig_system_ref_id   NUMBER,
      cust_po_number           VARCHAR2 (150),                  --07-May-2003
      header_currency          VARCHAR2 (15),                   --07-May-2003
      ord_hdr_id               VARCHAR2 (40),                   --07-May-2003
      party_id                 NUMBER
   );

   TYPE contract_tbl_type IS TABLE OF contract_rec
      INDEX BY BINARY_INTEGER;

   TYPE contract_line_rec IS RECORD (
      hdr_id               NUMBER,
      start_date           DATE,
      end_date             DATE,
      status_code          VARCHAR2 (30),
      line_id              NUMBER,
      class_id             VARCHAR2 (30),
      subclass_id          NUMBER,
      party_id             NUMBER,
      agreement_id         NUMBER,
      price_list_id        VARCHAR2 (40),
      currency_code        VARCHAR2 (15),
      accounting_rule_id   VARCHAR2 (40),
      invoice_rule_id      VARCHAR2 (40),
      payment_terms_id     VARCHAR2 (40),
      customer_po_number   NUMBER,
      bill_profile         VARCHAR2 (40),
      bill_interval        VARCHAR2 (40),
      inventory_item_id    NUMBER,
      DURATION             NUMBER,
      period               VARCHAR2 (10),
      bill_to_id           VARCHAR2 (40),
      ship_to_id           VARCHAR2 (40),
      customer_acct_id     NUMBER,
      usage_item_flag      VARCHAR2 (10)
   );

   TYPE g_sline_rec_type IS RECORD (
      contract_sub_line_id   NUMBER,
      service_line_id        NUMBER,
      serviceable_item_id    NUMBER,
      item_qty               NUMBER,
      item_uom_code          VARCHAR2 (30),
      unit_price             NUMBER,
      unit_percent           NUMBER,
      extended_amount        NUMBER
   );

   TYPE g_sline_tbl_type IS TABLE OF g_sline_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE bill_rec_type IS RECORD (
      bill_from_date    DATE,
      bill_to_date      DATE,
      invoice_on_date   DATE,
      billed_flag       VARCHAR2 (1)
   );

   TYPE billing_schedule_tbl_type IS TABLE OF bill_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE salesrec_type IS RECORD (
      employee_number        VARCHAR2 (30),
      full_name              VARCHAR2 (240),
      phone                  VARCHAR2 (60),
      fax                    VARCHAR2 (60),
      email                  VARCHAR2 (240),
      job_title              VARCHAR2 (240),
      address1               VARCHAR2 (240),
      address2               VARCHAR2 (240),
      address3               VARCHAR2 (240),
      concatenated_address   VARCHAR2 (2000),
      city                   VARCHAR2 (240),
      postal_code            VARCHAR2 (240),
      state                  VARCHAR2 (240),
      province               VARCHAR2 (240),
      county                 VARCHAR2 (240),
      country                VARCHAR2 (240),
      mgr_id                 NUMBER,
      mgr_name               VARCHAR2 (240),
      org_id                 NUMBER,
      org_name               VARCHAR2 (240),
      first_name             VARCHAR2 (240),
      last_name              VARCHAR2 (240),
      middle_name            VARCHAR2 (240),
      new_email              VARCHAR2 (240)
   );

--Function get_repname (p_party_id number, p_org_id number) Return Varchar2;
   FUNCTION round_currency_amt (p_amount IN NUMBER, p_currency_code IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION active_salesrep (
      p_contract_id   IN   NUMBER,
      p_party_id      IN   NUMBER,
      p_org_id        IN   NUMBER
   )
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (active_salesrep, WNPS, WNDS);

   PROCEDURE strip_white_spaces (
      p_credit_card_num   IN              VARCHAR2,
      p_stripped_cc_num   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE check_immediate_service (
      p_order_line_id              IN              NUMBER,
      x_service_tbl                OUT NOCOPY      service_tbl,
      x_immediate_service_status   OUT NOCOPY      VARCHAR2,
      x_return_status              OUT NOCOPY      VARCHAR2
   );

   PROCEDURE check_delayed_service (
      p_customer_product_id      IN              NUMBER,
      p_order_line_id            IN              NUMBER,
      x_service_tbl              OUT NOCOPY      service_tbl,
      x_delayed_service_status   OUT NOCOPY      VARCHAR2,
      x_return_status            OUT NOCOPY      VARCHAR2
   );

   PROCEDURE check_service_duplicate (
      p_order_line_id         IN              NUMBER,
      p_serv_id               IN              NUMBER,
      p_customer_product_id   IN              NUMBER,
      p_serv_start_date       IN              DATE,
      p_serv_end_date         IN              DATE,
      x_return_status         OUT NOCOPY      VARCHAR2,
      x_service_status        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE get_contract_header_info (
      p_order_line_id   IN              NUMBER,
      p_cp_id           IN              NUMBER,
      p_caller          IN              VARCHAR2,
      x_order_error     OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_header_rec      OUT NOCOPY      header_rec_type
   );

   PROCEDURE get_contract_line_info (
      p_order_line_id   IN              NUMBER,
      p_cp_id           IN              NUMBER,
      p_product_item    IN              NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_line_rec        OUT NOCOPY      line_rec_type
   );

   PROCEDURE get_warranty_info (
      p_prod_item_id          IN              NUMBER,
      p_customer_product_id   IN              NUMBER,
      x_return_status         OUT NOCOPY      VARCHAR2,
      p_ship_date             IN              DATE,
      p_installation_date     IN              DATE,
      x_warranty_tbl          OUT NOCOPY      war_tbl
   );

   PROCEDURE get_k_service_line (
      p_order_line_id       IN              NUMBER,
      p_cp_id               IN              NUMBER,
      p_shipped_date        IN              DATE,
      p_installation_date   IN              DATE,
      p_caller              IN              VARCHAR2,
      x_order_error         OUT NOCOPY      VARCHAR2,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_line_rec            OUT NOCOPY      line_rec_type
   );

   PROCEDURE get_contract_details (
      p_id                      IN              VARCHAR2,
      p_type                    IN              VARCHAR2,
      p_date                    IN              DATE,
      p_trxn_type               IN              VARCHAR2,
      x_available_yn            OUT NOCOPY      VARCHAR2,
      x_contract_tbl            OUT NOCOPY      contract_tbl_type,
      x_sales_credit_tbl_hdr    OUT NOCOPY      oks_extwarprgm_pvt.salescredit_tbl,
      --mmadhavi 4174921
      x_sales_credit_tbl_line   OUT NOCOPY      oks_extwarprgm_pvt.salescredit_tbl,
      x_return_status           OUT NOCOPY      VARCHAR2
   );

   FUNCTION get_k_hdr_id (p_order_hdr_id IN NUMBER)
      RETURN NUMBER;

   PROCEDURE create_billing_schedule (
      p_bill_start_date        IN              DATE,
      p_bill_end_date          IN              DATE,
      p_billing_frequency      IN              VARCHAR2,
      p_billing_method         IN              VARCHAR2,
      p_regular_offset_days    IN              NUMBER,
      p_first_bill_to_date     IN              DATE,
      p_first_inv_date         IN              DATE,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_billing_schedule_tbl   OUT NOCOPY      billing_schedule_tbl_type,
      p_cle_id                 IN              NUMBER
   );

   PROCEDURE get_warranty_info (
      p_org_id          IN              NUMBER,
      p_prod_item_id    IN              NUMBER,
      p_date            IN              DATE DEFAULT SYSDATE,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_warranty_tbl    OUT NOCOPY      war_tbl
   );

   PROCEDURE get_transfer_detail (
      p_cpid            IN              NUMBER,
      x_hdr_rec         OUT NOCOPY      oks_extwarprgm_pvt.k_header_rec_type,
      x_line_rec        OUT NOCOPY      oks_extwarprgm_pvt.k_line_service_rec_type,
      x_covd_rec        OUT NOCOPY      oks_extwarprgm_pvt.k_line_covered_level_rec_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_timestamp (
      p_counter_group_id     IN              NUMBER,
      p_service_start_date   IN              DATE,
      p_service_line_id      IN              NUMBER,
      x_status               OUT NOCOPY      VARCHAR2
   );

   SUBTYPE salescredit_tbl IS oks_extwarprgm_pvt.salescredit_tbl;

   PROCEDURE salescredit (
      p_order_line_id     IN              NUMBER,
      x_salescredit_tbl   OUT NOCOPY      salescredit_tbl,
      x_return_status     OUT NOCOPY      VARCHAR2
   );

--mmadhavi added for bug 4174921
   PROCEDURE salescredit_header (
      p_order_hdr_id      IN              NUMBER,
      x_salescredit_tbl   OUT NOCOPY      salescredit_tbl,
      x_return_status     OUT NOCOPY      VARCHAR2
   );

   TYPE renewal_rec_type IS RECORD (
      chr_id                 NUMBER,
      renewal_type           VARCHAR2 (10),
      po_required_yn         VARCHAR2 (1),
      renewal_pricing_type   VARCHAR2 (3),
      markup_percent         NUMBER,
      price_list_id1         NUMBER,
      line_renewal_type      VARCHAR2 (3),
      link_chr_id            NUMBER,
      contact_id             NUMBER,
      site_id                NUMBER,
      email_id               NUMBER,
      phone_id               NUMBER,
      fax_id                 NUMBER,
      billing_profile_id     NUMBER,
      RENEWAL_APPROVAL_FLAG  VARCHAR2(30)  --Bug# 5173373
   );

   l_renewal_rec                   renewal_rec_type;

   PROCEDURE get_k_order_details (
      p_order_line_id   IN              NUMBER,
      l_renewal_rec     OUT NOCOPY      renewal_rec_type
   );

   PROCEDURE update_contract_details (
      p_hdr_id                       NUMBER,
      p_order_line_id                NUMBER,
      x_return_status   OUT NOCOPY   VARCHAR2
   );

   PROCEDURE get_pricing_attributes (
      p_order_line_id   IN              NUMBER,
      x_pricing_att     OUT NOCOPY      oks_extwarprgm_pvt.pricing_attributes_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE get_k_pricing_attributes (
      p_k_line_id       IN              NUMBER,
      x_pricing_att     OUT NOCOPY      oks_extwarprgm_pvt.pricing_attributes_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   );

   FUNCTION oks_get_party (p_chr_id NUMBER, p_rle_code VARCHAR2)
      RETURN NUMBER;

   FUNCTION oks_get_svc (p_cle_id NUMBER)
      RETURN NUMBER;

   PROCEDURE create_sales_credits (
      p_header_id                    NUMBER,
      p_line_id                      NUMBER,
      x_return_status   OUT NOCOPY   VARCHAR2
   );

   FUNCTION get_line_name_if_null (
      p_inventory_item_id   IN              NUMBER,
      p_organization_id     IN              NUMBER,
      p_code                IN              VARCHAR2,
      x_return_status       OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2;

   PROCEDURE get_line_name_if_null (
      p_inventory_item_id   IN              NUMBER,
      p_organization_id     IN              NUMBER,
      p_code                IN              VARCHAR2,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_name                OUT NOCOPY      VARCHAR2,
      x_description         OUT NOCOPY      VARCHAR2
   );

   PROCEDURE oks_get_salesrep (
      p_contact_id      IN              NUMBER DEFAULT NULL,
      p_contract_id                     NUMBER,
      x_salesdetails    OUT NOCOPY      salesrec_type,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE calculate_rev_rec (
      p_conc_request_id   IN   NUMBER,
      p_contract_group    IN   NUMBER,
      p_orgid             IN   NUMBER,
      p_forfdate          IN   DATE,
      p_fortdate          IN   DATE,
      p_min               IN   NUMBER,
      p_max               IN   NUMBER,
      p_regz_date         IN   DATE,
      p_curr              IN   VARCHAR2
   );

   FUNCTION check_already_billed (
      p_chr_id     IN   NUMBER,
      p_cle_id     IN   NUMBER,
      p_lse_id     IN   NUMBER,
      p_end_date   IN   DATE
   )
      RETURN BOOLEAN;
END oks_extwar_util_pvt;

 

/
