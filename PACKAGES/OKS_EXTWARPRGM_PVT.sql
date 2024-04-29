--------------------------------------------------------
--  DDL for Package OKS_EXTWARPRGM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_EXTWARPRGM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSREWRS.pls 120.25 2007/09/07 10:17:09 vmutyala ship $ */

   ---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
   g_required_value        CONSTANT VARCHAR2 (200)
                                                  := okc_api.g_required_value;
   g_invalid_value         CONSTANT VARCHAR2 (200) := okc_api.g_invalid_value;
   g_col_name_token        CONSTANT VARCHAR2 (200)
                                                  := okc_api.g_col_name_token;
   g_parent_table_token    CONSTANT VARCHAR2 (200)
                                              := okc_api.g_parent_table_token;
   g_child_table_token     CONSTANT VARCHAR2 (200)
                                               := okc_api.g_child_table_token;
   g_unexpected_error      CONSTANT VARCHAR2 (200)
                                               := 'OKC_CONTRACTS_UNEXP_ERROR';
   g_sqlerrm_token         CONSTANT VARCHAR2 (200) := 'SQLerrm';
   g_sqlcode_token         CONSTANT VARCHAR2 (200) := 'SQLcode';
   g_uppercase_required    CONSTANT VARCHAR2 (200)
                                        := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
   g_app_id                CONSTANT NUMBER           := 515;
------------------------------------------------------------------------------------
    -- Constants used for Message Logging
   g_level_unexpected      CONSTANT NUMBER        := fnd_log.level_unexpected;
   g_level_error           CONSTANT NUMBER         := fnd_log.level_error;
   g_level_exception       CONSTANT NUMBER         := fnd_log.level_exception;
   g_level_event           CONSTANT NUMBER         := fnd_log.level_event;
   g_level_procedure       CONSTANT NUMBER         := fnd_log.level_procedure;
   g_level_statement       CONSTANT NUMBER         := fnd_log.level_statement;
   g_level_current         CONSTANT NUMBER := fnd_log.g_current_runtime_level;
   g_module_current        CONSTANT VARCHAR2 (255)
                                            := 'oks.plsql.oks_int_extwar_pvt';
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
---------------------------------------------------------------------------
   g_exception_halt_validation      EXCEPTION;
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
   g_pkg_name              CONSTANT VARCHAR2 (200) := 'OKSOMINT';
   g_app_name              CONSTANT VARCHAR2 (3)   := 'OKS';
   g_jtf_order_hdr         CONSTANT VARCHAR2 (200) := 'OKX_ORDERHEAD';
   g_jtf_order_ln          CONSTANT VARCHAR2 (200) := 'OKX_ORDERLINE';
   g_invoice_contact       CONSTANT VARCHAR2 (200) := 'BILLING';
   g_rule_group_code       CONSTANT VARCHAR2 (200) := 'SVC_K';
   g_jtf_extwarr           CONSTANT VARCHAR2 (200) := 'OKX_SERVICE';
   g_jtf_warr              CONSTANT VARCHAR2 (200) := 'OKX_WARRANTY';
   g_jtf_party             CONSTANT VARCHAR2 (200) := 'OKX_PARTY';
   g_jtf_party_vendor      CONSTANT VARCHAR2 (200) := 'OKX_OPERUNIT';
   g_jtf_invoice_contact   CONSTANT VARCHAR2 (200) := 'OKX_PCONTACT';
   g_jtf_billto            CONSTANT VARCHAR2 (200) := 'OKX_BILLTO';
   g_jtf_shipto            CONSTANT VARCHAR2 (200) := 'OKX_SHIPTO';
   g_jtf_arl               CONSTANT VARCHAR2 (200) := 'OKX_ACCTRULE';
   g_jtf_ire               CONSTANT VARCHAR2 (200) := 'OKX_INVRULE';
   g_jtf_custprod          CONSTANT VARCHAR2 (200) := 'OKX_CUSTPROD';
   g_jtf_custacct          CONSTANT VARCHAR2 (200) := 'OKX_CUSTACCT';
   g_jtf_price             CONSTANT VARCHAR2 (200) := 'OKX_PRICE';
   g_jtf_payment_term      CONSTANT VARCHAR2 (200) := 'OKX_RPAYTERM';
   g_jtf_conv_type         CONSTANT VARCHAR2 (200) := 'OKX_CONVTYPE';
   g_jtf_taxexemp          CONSTANT VARCHAR2 (200) := 'OKX_TAXEXEMP';
   g_jtf_taxctrl           CONSTANT VARCHAR2 (200) := 'OKX_TAXCTRL';
   g_ptr                            NUMBER         := 1;
   g_fnd_log_option        CONSTANT VARCHAR2 (30)
                                := NVL (fnd_profile.VALUE ('OKS_DEBUG'), 'N');
  G_CONTEXT_ORDER_HEADER CONSTANT VARCHAR2(30) := 'ORDER_HEADER';
  G_CONTEXT_ORDER_LINE CONSTANT VARCHAR2(30) := 'ORDER_LINE';
  G_PAYMENT_CREDIT_CARD CONSTANT VARCHAR2(30) := 'CREDIT_CARD';


---------------------------------------------------------------------------
   TYPE pricing_attributes_type IS RECORD (
      pricing_context        okc_price_att_values.pricing_context%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute1     okc_price_att_values.pricing_attribute1%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute2     okc_price_att_values.pricing_attribute2%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute3     okc_price_att_values.pricing_attribute3%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute4     okc_price_att_values.pricing_attribute4%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute5     okc_price_att_values.pricing_attribute5%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute6     okc_price_att_values.pricing_attribute6%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute7     okc_price_att_values.pricing_attribute7%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute8     okc_price_att_values.pricing_attribute8%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute9     okc_price_att_values.pricing_attribute9%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute10    okc_price_att_values.pricing_attribute10%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute11    okc_price_att_values.pricing_attribute11%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute12    okc_price_att_values.pricing_attribute12%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute13    okc_price_att_values.pricing_attribute13%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute14    okc_price_att_values.pricing_attribute14%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute15    okc_price_att_values.pricing_attribute15%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute16    okc_price_att_values.pricing_attribute16%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute17    okc_price_att_values.pricing_attribute17%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute18    okc_price_att_values.pricing_attribute18%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute19    okc_price_att_values.pricing_attribute19%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute20    okc_price_att_values.pricing_attribute20%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute21    okc_price_att_values.pricing_attribute21%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute22    okc_price_att_values.pricing_attribute22%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute23    okc_price_att_values.pricing_attribute23%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute24    okc_price_att_values.pricing_attribute24%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute25    okc_price_att_values.pricing_attribute25%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute26    okc_price_att_values.pricing_attribute26%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute27    okc_price_att_values.pricing_attribute27%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute28    okc_price_att_values.pricing_attribute28%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute29    okc_price_att_values.pricing_attribute29%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute30    okc_price_att_values.pricing_attribute30%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute31    okc_price_att_values.pricing_attribute31%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute32    okc_price_att_values.pricing_attribute32%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute33    okc_price_att_values.pricing_attribute33%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute34    okc_price_att_values.pricing_attribute34%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute35    okc_price_att_values.pricing_attribute35%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute36    okc_price_att_values.pricing_attribute36%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute37    okc_price_att_values.pricing_attribute37%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute38    okc_price_att_values.pricing_attribute38%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute39    okc_price_att_values.pricing_attribute39%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute40    okc_price_att_values.pricing_attribute40%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute41    okc_price_att_values.pricing_attribute41%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute42    okc_price_att_values.pricing_attribute42%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute43    okc_price_att_values.pricing_attribute43%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute44    okc_price_att_values.pricing_attribute44%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute45    okc_price_att_values.pricing_attribute45%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute46    okc_price_att_values.pricing_attribute46%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute47    okc_price_att_values.pricing_attribute47%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute48    okc_price_att_values.pricing_attribute48%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute49    okc_price_att_values.pricing_attribute49%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute50    okc_price_att_values.pricing_attribute50%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute51    okc_price_att_values.pricing_attribute51%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute52    okc_price_att_values.pricing_attribute52%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute53    okc_price_att_values.pricing_attribute53%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute54    okc_price_att_values.pricing_attribute54%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute55    okc_price_att_values.pricing_attribute55%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute56    okc_price_att_values.pricing_attribute56%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute57    okc_price_att_values.pricing_attribute57%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute58    okc_price_att_values.pricing_attribute58%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute59    okc_price_att_values.pricing_attribute59%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute60    okc_price_att_values.pricing_attribute60%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute61    okc_price_att_values.pricing_attribute61%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute62    okc_price_att_values.pricing_attribute62%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute63    okc_price_att_values.pricing_attribute63%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute64    okc_price_att_values.pricing_attribute64%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute65    okc_price_att_values.pricing_attribute65%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute66    okc_price_att_values.pricing_attribute66%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute67    okc_price_att_values.pricing_attribute67%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute68    okc_price_att_values.pricing_attribute68%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute69    okc_price_att_values.pricing_attribute69%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute70    okc_price_att_values.pricing_attribute70%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute71    okc_price_att_values.pricing_attribute71%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute72    okc_price_att_values.pricing_attribute72%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute73    okc_price_att_values.pricing_attribute73%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute74    okc_price_att_values.pricing_attribute74%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute75    okc_price_att_values.pricing_attribute75%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute76    okc_price_att_values.pricing_attribute76%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute77    okc_price_att_values.pricing_attribute77%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute78    okc_price_att_values.pricing_attribute78%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute79    okc_price_att_values.pricing_attribute79%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute80    okc_price_att_values.pricing_attribute80%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute81    okc_price_att_values.pricing_attribute81%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute82    okc_price_att_values.pricing_attribute82%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute83    okc_price_att_values.pricing_attribute83%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute84    okc_price_att_values.pricing_attribute84%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute85    okc_price_att_values.pricing_attribute85%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute86    okc_price_att_values.pricing_attribute86%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute87    okc_price_att_values.pricing_attribute87%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute88    okc_price_att_values.pricing_attribute88%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute89    okc_price_att_values.pricing_attribute89%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute90    okc_price_att_values.pricing_attribute90%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute91    okc_price_att_values.pricing_attribute91%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute92    okc_price_att_values.pricing_attribute92%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute93    okc_price_att_values.pricing_attribute93%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute94    okc_price_att_values.pricing_attribute94%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute95    okc_price_att_values.pricing_attribute95%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute96    okc_price_att_values.pricing_attribute96%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute97    okc_price_att_values.pricing_attribute97%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute98    okc_price_att_values.pricing_attribute98%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute99    okc_price_att_values.pricing_attribute99%TYPE
                                                       := okc_api.g_miss_char,
      pricing_attribute100   okc_price_att_values.pricing_attribute100%TYPE
                                                       := okc_api.g_miss_char
   );

   TYPE partyrole_type IS RECORD (
      party_role     VARCHAR2 (30),
      object1_id1    NUMBER,
      object1_code   VARCHAR2 (30)
   );

   TYPE partyrole_tbl IS TABLE OF partyrole_type
      INDEX BY BINARY_INTEGER;

   TYPE contact_type IS RECORD (
      party_role            VARCHAR2 (30),
      contact_role          VARCHAR2 (30),
      contact_object_code   VARCHAR2 (30),
      contact_id            NUMBER,
      flag                  VARCHAR2 (1)
   );

   TYPE contact_tbl IS TABLE OF contact_type
      INDEX BY BINARY_INTEGER;

   TYPE salescredit_type IS RECORD (
      ctc_id                 NUMBER,
      sales_credit_type_id   NUMBER,
      PERCENT                NUMBER,
      sales_group_id         NUMBER
   );

   TYPE salescredit_tbl IS TABLE OF salescredit_type
      INDEX BY BINARY_INTEGER;

   TYPE k_header_rec_type IS RECORD (
      contract_number                VARCHAR2 (120),
      rty_code                       VARCHAR2 (30),
      start_date                     DATE,
      end_date                       DATE,
      sts_code                       VARCHAR2 (30),
      scs_code                       VARCHAR2 (30),
      class_code                     VARCHAR2 (30),
      authoring_org_id               NUMBER,
      short_description              VARCHAR2 (1995),
      chr_group                      NUMBER,
      pdf_id                         NUMBER,
      party_id                       NUMBER,
      bill_to_id                     NUMBER,
      ship_to_id                     NUMBER,
      contact_id                     NUMBER,
      price_list_id                  NUMBER,
      cust_po_number                 VARCHAR2 (240),
      agreement_id                   NUMBER,
      currency                       VARCHAR2 (15),
      accounting_rule_id             NUMBER,
      invoice_rule_id                NUMBER,
      order_hdr_id                   NUMBER,
      payment_term_id                NUMBER,
      cvn_type                       VARCHAR2 (25),
      cvn_rate                       NUMBER,
      cvn_date                       DATE,
      cvn_euro_rate                  NUMBER,
      billed_at_source		     OKC_K_HEADERS_ALL_B.BILLED_AT_SOURCE%TYPE,
      tax_exemption_id               NUMBER,
      tax_status_flag                VARCHAR2 (30),
      third_party_role               VARCHAR2 (30),
      merge_type                     VARCHAR2 (10),
      merge_object_id                NUMBER,
      renewal_type                   VARCHAR2 (3)         --'NSR/SFA/DNR/EVN'
                                                 ,
      renewal_pricing_type           VARCHAR2 (3)             --'LST/PCT/MAN'
                                                 ,
      renewal_price_list_id          NUMBER,
      renewal_markup                 NUMBER,
      renewal_po                     VARCHAR2 (1)                     --'Y/N'
                                                 ,
      qto_contact_id                 NUMBER,
      qto_email_id                   NUMBER,
      qto_phone_id                   NUMBER,
      qto_fax_id                     NUMBER,
      qto_site_id                    NUMBER,
      order_line_id                  NUMBER,
      billing_profile_id             NUMBER,
      qcl_id                         NUMBER,
      grace_period                   VARCHAR2 (250),
      inv_organization_id            NUMBER,
      grace_duration                 NUMBER,
      salesrep_id                    NUMBER,
      ar_interface_yn                VARCHAR2 (1),
      summary_trx_yn                 VARCHAR2 (1),
      hold_billing                   VARCHAR2 (1),
      inv_trx_type                   VARCHAR2 (40),
      payment_type                   VARCHAR2 (30),
      ccr_number                     VARCHAR2 (80),
      ccr_exp_date                   DATE,
      period_start                   VARCHAR2 (30),
      period_type                    VARCHAR2 (10),
      price_uom                      VARCHAR2 (30),
      attribute1                     VARCHAR2 (450),
      attribute2                     VARCHAR2 (450),
      attribute3                     VARCHAR2 (450),
      attribute4                     VARCHAR2 (450),
      attribute5                     VARCHAR2 (450),
      attribute6                     VARCHAR2 (450),
      attribute7                     VARCHAR2 (450),
      attribute8                     VARCHAR2 (450),
      attribute9                     VARCHAR2 (450),
      attribute10                    VARCHAR2 (450),
      attribute11                    VARCHAR2 (450),
      attribute12                    VARCHAR2 (450),
      attribute13                    VARCHAR2 (450),
      attribute14                    VARCHAR2 (450),
      attribute15                    VARCHAR2 (450),
      renewal_status                 VARCHAR2 (30)
                                  -- Added by JVARGHES for 12.0 enhancements.
-- Added by rsu for R12
      ,
      tax_classification_code        VARCHAR2 (50),  /* nechatur 13-07-06 bug#5380870 Increased the tax_classification_code length from 30 to 50 */
      exemption_certificate_number   VARCHAR2 (80),
      exemption_reason_code          VARCHAR2 (30),
-- Added by rsu for R12
      RENEWAL_APPROVAL_FLAG          VARCHAR2(30) --Bug# 5173373
   );

   TYPE k_line_service_rec_type IS RECORD (
      k_id                           NUMBER,
      k_line_number                  VARCHAR2 (150),
      line_sts_code                  VARCHAR2 (30),
      cust_account                   NUMBER,
      org_id                         NUMBER,
      srv_id                         NUMBER,
      object_name                    VARCHAR2 (440),
      srv_segment1                   VARCHAR2 (440),
      srv_desc                       VARCHAR2 (440),
      srv_sdt                        DATE,
      srv_edt                        DATE,
      bill_to_id                     NUMBER,
      ship_to_id                     NUMBER,
      order_line_id                  NUMBER,
      accounting_rule_id             NUMBER,
      invoicing_rule_id              NUMBER,
      warranty_flag                  VARCHAR2 (2),
      coverage_template_id           NUMBER,
      currency                       VARCHAR2 (15),
      SOURCE                         VARCHAR2 (30),
      reason_code                    VARCHAR2 (30),
      reason_comments                VARCHAR2 (1995),
      line_renewal_type              VARCHAR2 (3)            -- 'FUL/KEP/DNR'
                                                 ,
      upg_orig_system_ref            VARCHAR2 (60),
      upg_orig_system_ref_id         NUMBER,
      commitment_id                  NUMBER,
      tax_code                       NUMBER,
      ln_price_list_id               NUMBER,
      coverage_id                    NUMBER,
      standard_cov_yn                VARCHAR2 (1),
      price_uom                      VARCHAR2 (30),
      attribute1                     VARCHAR2 (450),
      attribute2                     VARCHAR2 (450),
      attribute3                     VARCHAR2 (450),
      attribute4                     VARCHAR2 (450),
      attribute5                     VARCHAR2 (450),
      attribute6                     VARCHAR2 (450),
      attribute7                     VARCHAR2 (450),
      attribute8                     VARCHAR2 (450),
      attribute9                     VARCHAR2 (450),
      attribute10                    VARCHAR2 (450),
      attribute11                    VARCHAR2 (450),
      attribute12                    VARCHAR2 (450),
      attribute13                    VARCHAR2 (450),
      attribute14                    VARCHAR2 (450),
      attribute15                    VARCHAR2 (450)
--added by rsu for r12
      ,
      tax_classification_code        VARCHAR2 (50),  /* nechatur 13-07-06 bug#5380870 Increased the tax_classification_code length from 30 to 50 */
      exemption_certificate_number   VARCHAR2 (80),
      exemption_reason_code          VARCHAR2 (30),
      tax_status                     oks_k_lines_b.tax_status%TYPE
--added by rsu for r12
   );

   TYPE k_line_covered_level_rec_type IS RECORD (
      k_id                     NUMBER,
      rty_code                 VARCHAR2 (30),
      attach_2_line_id         NUMBER,
      attach_2_line_desc       VARCHAR2 (450),
      line_number              VARCHAR2 (150),
      product_sts_code         VARCHAR2 (30),
      customer_product_id      NUMBER,
      product_item_id          NUMBER,
      product_segment1         VARCHAR2 (440),
      product_desc             VARCHAR2 (440),
      product_start_date       DATE,
      product_end_date         DATE,
      quantity                 NUMBER,
      uom_code                 VARCHAR2 (3),
      list_price               NUMBER,
      negotiated_amount        NUMBER,
      currency_code            VARCHAR2 (15),
      warranty_flag            VARCHAR2 (2),
      reason_code              VARCHAR2 (30),
      reason_comments          VARCHAR2 (1995),
      line_renewal_type        VARCHAR2 (3)                  -- 'FUL/KEP/DNR'
                                           ,
      order_line_id            NUMBER,
      translated_text          VARCHAR2 (1995),
      upg_orig_system_ref      VARCHAR2 (60),
      upg_orig_system_ref_id   NUMBER,
      prod_item_id             NUMBER,
      tax_amount               NUMBER,
      standard_coverage        VARCHAR2 (1),
      price_uom                VARCHAR2 (30),
      toplvl_uom_code          VARCHAR2 (3),
      --mchoudha added for bug#5233956
      toplvl_price_qty         Number,
      attribute1               VARCHAR2 (450),
      attribute2               VARCHAR2 (450),
      attribute3               VARCHAR2 (450),
      attribute4               VARCHAR2 (450),
      attribute5               VARCHAR2 (450),
      attribute6               VARCHAR2 (450),
      attribute7               VARCHAR2 (450),
      attribute8               VARCHAR2 (450),
      attribute9               VARCHAR2 (450),
      attribute10              VARCHAR2 (450),
      attribute11              VARCHAR2 (450),
      attribute12              VARCHAR2 (450),
      attribute13              VARCHAR2 (450),
      attribute14              VARCHAR2 (450),
      attribute15              VARCHAR2 (450)
   );

   TYPE extwar_rec_type IS RECORD (
      warranty_flag                  VARCHAR2 (30),
      rty_code                       VARCHAR2 (30),
      merge_type                     VARCHAR2 (10),
      merge_object_id                NUMBER,
      hdr_sdt                        DATE,
      hdr_edt                        DATE,
      hdr_org_id                     NUMBER,
      hdr_party_id                   NUMBER,
      hdr_third_party_role           VARCHAR2 (30),
      hdr_bill_2_id                  NUMBER,
      hdr_ship_2_id                  NUMBER,
      hdr_price_list_id              NUMBER,
      hdr_cust_po_number             VARCHAR2 (240),
      hdr_agreement_id               NUMBER,
      hdr_currency                   VARCHAR2 (15),
      hdr_acct_rule_id               NUMBER,
      hdr_inv_rule_id                NUMBER,
      hdr_order_hdr_id               NUMBER,
      hdr_status                     VARCHAR2 (30),
      hdr_payment_term_id            NUMBER,
      hdr_cvn_type                   VARCHAR2 (25),
      hdr_cvn_rate                   NUMBER,
      hdr_cvn_date                   DATE,
      hdr_cvn_euro_rate              NUMBER,
      hdr_chr_group                  NUMBER,
      hdr_pdf_id                     NUMBER,
      hdr_tax_exemption_id           NUMBER,
      hdr_tax_status_flag            VARCHAR2 (30),
      hdr_renewal_type               VARCHAR2 (3),
      hdr_renewal_pricing_type       VARCHAR2 (3),
      hdr_renewal_price_list_id      NUMBER,
      hdr_renewal_markup             NUMBER,
      hdr_renewal_po                 VARCHAR2 (1),
      hdr_contact_id                 NUMBER,
      hdr_qcl_id                     NUMBER,
      cust_account                   NUMBER,
      srv_id                         NUMBER,
      srv_name                       VARCHAR2 (440),
      srv_desc                       VARCHAR2 (440),
      srv_sdt                        DATE,
      srv_edt                        DATE,
      srv_bill_2_id                  NUMBER,
      srv_ship_2_id                  NUMBER,
      srv_order_line_id              NUMBER,
      srv_amount                     NUMBER,
      srv_unit_price                 NUMBER,
      srv_price_percent              NUMBER,
      srv_currency                   VARCHAR2 (15),
      srv_cov_template_id            NUMBER,
      lvl_cp_id                      NUMBER,
      lvl_inventory_id               NUMBER,
      lvl_inventory_name             VARCHAR2 (440),
      lvl_inventory_desc             VARCHAR2 (440),
      lvl_quantity                   NUMBER,
      lvl_uom_code                   VARCHAR2 (3),
      lvl_order_line_id              NUMBER,
      lvl_sts_code                   VARCHAR2 (40),
      lvl_line_renewal_type          VARCHAR2 (3),
      line_invoicing_rule_id         NUMBER,
      line_accounting_rule_id        NUMBER,
      qto_contact_id                 NUMBER,
      qto_email_id                   NUMBER,
      qto_phone_id                   NUMBER,
      qto_fax_id                     NUMBER,
      qto_site_id                    NUMBER,
      billing_profile_id             NUMBER
--,     Translated_text         Varchar2(1995);
      ,
      line_renewal_type              VARCHAR2 (3),
      grace_period                   VARCHAR2 (250),
      grace_duration                 NUMBER,
      hdr_scs_code                   VARCHAR2 (30),
      salesrep_id                    NUMBER,
      commitment_id                  NUMBER,
      ccr_number                     VARCHAR2 (80),
      ccr_exp_date                   DATE,
      tax_amount                     NUMBER,
      ln_price_list_id               NUMBER
--added by rsu for r12
      ,
      tax_classification_code        VARCHAR2 (50),  /* nechatur 13-07-06 bug#5380870 Increased the tax_classification_code length from 30 to 50 */
      exemption_certificate_number   VARCHAR2 (80),
      exemption_reason_code          VARCHAR2 (30)
--added by rsu for r12
      ,
      renewal_status                 VARCHAR2 (30)

   -- added Vigandhi : for warranty contract negotiation status
   );

   TYPE contract_trf_rec IS RECORD (
      hdr_id                   NUMBER,
      hdr_org_id               NUMBER,
      hdr_sdt                  DATE,
      hdr_edt                  DATE,
      hdr_sts                  VARCHAR2 (30),
      contract_number          VARCHAR2 (40),
      scs_code                 VARCHAR2 (40),
      service_line_id          NUMBER,
      service_line_number      VARCHAR2 (150),
      service_inventory_id     VARCHAR2 (240),
      object_line_id           NUMBER,
      --Service_name         VARCHAR2(240),
      --Service_Description  VARCHAR2(240),
      service_sdt              DATE,
      service_edt              DATE,
      service_bill_2_id        NUMBER,
      service_ship_2_id        NUMBER,
      --Service_order_line_id NUMBER,
      service_amount           NUMBER,
      service_tax_amount       NUMBER,
      tax_code                 NUMBER,
      service_unit_price       NUMBER,
      service_currency         VARCHAR2 (15),
 --Service_Cov_id        NUMBER,
-- K_Item_Id             NUMBER,
      cp_qty                   NUMBER,
      --warranty_flag         VARCHAR2(2),
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
      billed_at_source	       OKC_K_HEADERS_ALL_B.BILLED_AT_SOURCE%TYPE,
 --resource_id           Number,
-- group_id              Number,
 --access_level          Varchar2(3),
      cle_id_renewed           NUMBER,
      sts_code                 VARCHAR2 (30),
      prod_sts_code            VARCHAR2 (30),
      prod_sdt                 DATE,
      prod_edt                 DATE,
      prod_term_date           DATE,
      lse_id                   NUMBER,
      prod_name                VARCHAR2 (240),
      prod_description         VARCHAR2 (240),
      prod_line_renewal_type   VARCHAR2 (30),
--start_delay            Number,
      upg_orig_system_ref      VARCHAR2 (60),
      upg_orig_system_ref_id   NUMBER,
      cust_po_number           VARCHAR2 (150),                  --07-May-2003
      header_currency          VARCHAR2 (15),                   --07-May-2003
--ord_hdr_id             Varchar2(40),     --07-May-2003
      party_id                 NUMBER,
      instance_id              NUMBER,
      prod_inventory_item      NUMBER,
      transfer_date            DATE,
      transaction_date         DATE,
      old_account_id           NUMBER,
      new_account_id           NUMBER,
      system_id                NUMBER,
      old_cp_id                NUMBER,
      coverage_id              NUMBER,
      standard_cov_yn          VARCHAR2 (1),
      period_start             VARCHAR2 (30),
      period_type              VARCHAR2 (10),
      uom_code                 VARCHAR2 (3),
      price_uom_sl             VARCHAR2 (30),      -- Added to cpoy price_uom
      price_uom_tl             VARCHAR2 (30),      -- Added to cpoy price_uom
      price_uom_hdr            VARCHAR2 (30),      -- Added to cpoy price_uom
      toplvl_uom_code          VARCHAR2 (3),
      --mchoudha added for bug#5233956
      toplvl_price_qty         Number
   );

   TYPE contract_rec IS RECORD (
      old_cp_id                 NUMBER,
      termination_date          DATE,
      installation_date         DATE,
      transaction_date          DATE,
      old_customer_acct_id      NUMBER,
      new_customer_acct_id      NUMBER,
      system_id                 NUMBER,
      current_cp_quantity       NUMBER,
      new_quantity              NUMBER,
      new_customer_product_id   NUMBER,
      object_line_id            NUMBER,
      hdr_id                    NUMBER,
      hdr_sdt                   DATE,
      hdr_edt                   DATE,
      hdr_sts                   VARCHAR2 (30),
      service_line_id           NUMBER,
      service_amount            NUMBER,
      prod_sdt                  DATE,
      prod_edt                  DATE,
      prod_sts_code             VARCHAR2 (30),
      cust_account              NUMBER,
      service_sdt               DATE,
      service_edt               DATE,
      sts_code                  VARCHAR2 (30),
      contract_number           VARCHAR2 (40),
      old_cp_quantity           NUMBER,
      price_negotiated          NUMBER,
      term_date                 DATE,
      prod_inventory_item       NUMBER,
      hdr_org_id                NUMBER,
      organization_id           NUMBER,
      lse_id                    NUMBER,
      scs_code                  VARCHAR2 (40),
      new_cp_id                 NUMBER,
      service_inventory_id      VARCHAR2 (240),
      service_currency          VARCHAR2 (15),
      uom_code                  VARCHAR2 (30),
      prod_line_renewal_type    VARCHAR2 (30),
      raise_credit              VARCHAR2 (50),
      party_id                  NUMBER,
      service_tax_amount        NUMBER,
      service_unit_price        NUMBER,
      prod_name                 VARCHAR2 (240),
      prod_description          VARCHAR2 (240),
--start_delay            Number,
      upg_orig_system_ref       VARCHAR2 (60),
      upg_orig_system_ref_id    NUMBER,
      new_inventory_item        NUMBER,
      return_reason_code        VARCHAR2 (30),
      order_line_id             NUMBER,
      price_uom_code            VARCHAR2 (30),     -- Added to cpoy price_uom
      toplvl_uom_code           VARCHAR2 (3),
      --mchoudha added for bug#5233956
      toplvl_price_qty          Number
   );

   TYPE contract_trf_tbl IS TABLE OF contract_trf_rec
      INDEX BY BINARY_INTEGER;

   TYPE contract_tbl IS TABLE OF contract_rec
      INDEX BY BINARY_INTEGER;

   PROCEDURE update_cov_level (
      p_covered_line_id      IN              NUMBER,
      p_new_end_date         IN              DATE,
      p_k_item_id            IN              NUMBER,
      p_new_negotiated_amt   IN              NUMBER,
      p_new_cp_qty           IN              NUMBER,
      p_list_price           IN              NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_k_hdr (
      p_k_header_rec         IN              k_header_rec_type,
      p_contact_tbl          IN              contact_tbl,
      p_salescredit_tbl_in   IN              salescredit_tbl
                                                            --mmadhavi  bug 4174921
   ,
      p_caller               IN              VARCHAR2,
      x_order_error          OUT NOCOPY      VARCHAR2,
      x_chr_id               OUT NOCOPY      NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_k_service_lines (
      p_k_line_rec           IN              k_line_service_rec_type,
      p_contact_tbl          IN              contact_tbl,
      p_salescredit_tbl_in   IN              salescredit_tbl,
      p_caller               IN              VARCHAR2,
      x_order_error          OUT NOCOPY      VARCHAR2,
      x_service_line_id      OUT NOCOPY      NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_k_covered_levels (
      p_k_covd_rec      IN              k_line_covered_level_rec_type,
      p_price_attribs   IN              pricing_attributes_type,
      p_caller          IN              VARCHAR2,
      x_order_error     OUT NOCOPY      VARCHAR2,
      x_covlvl_id       OUT NOCOPY      NUMBER,
      x_update_line     OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_contract_ibnew (
      p_extwar_rec                IN              extwar_rec_type,
      p_contact_tbl_in            IN              oks_extwarprgm_pvt.contact_tbl,
      p_salescredit_tbl_hdr_in    IN              oks_extwarprgm_pvt.salescredit_tbl
                                                                                    --mmadhavi bug 4174921
   ,
      p_salescredit_tbl_line_in   IN              oks_extwarprgm_pvt.salescredit_tbl,
      p_price_attribs_in          IN              oks_extwarprgm_pvt.pricing_attributes_type,
      x_inst_dtls_tbl             IN OUT NOCOPY   oks_ihd_pvt.ihdv_tbl_type,
      x_chrid                     OUT NOCOPY      NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_contract_ibsplit (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_contract_ibreplace (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_contract_ibreturn (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_k_system_transfer (
      p_kdtl_tbl        IN              contract_trf_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_contract_terminate (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_contract_idc (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_contract_ibupdate (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );

   PROCEDURE get_sts_code (
      p_ste_code   IN              VARCHAR2,
      p_sts_code   IN              VARCHAR2,
      x_ste_code   OUT NOCOPY      VARCHAR2,
      x_sts_code   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE send_notification (
      p_order_id      IN   NUMBER,
      p_contract_id        NUMBER,
      p_type          IN   VARCHAR2
   );

   PROCEDURE get_jtf_resource (
      p_authorg_id                   NUMBER,
      p_party_id                     NUMBER,
      x_winners_rec     OUT NOCOPY   jtf_terr_assign_pub.bulk_winners_rec_type,
      x_msg_count       OUT NOCOPY   NUMBER,
      x_msg_data        OUT NOCOPY   VARCHAR2,
      x_return_status   OUT NOCOPY   VARCHAR2
   );

  -----------------------------------------------------------------------
  --  Procedure: get_cc_trxn_extn
  --  Added 03/03/2006 by Vijay Ramalingam
  -----------------------------------------------------------------------
  -- The get_cc_trxn_extn procedure is used to get a transaction extension
  -- id from iPayments, based on an existing transaction extension id from
  -- a sales order header or an order line from OM.
  -- This API is called while creating an Extended warranty contract
  -- from OM. It is called at the header level for a sales order header
  -- or at line level for a sales order line.
  -- p_context_level identifies the level at which it is called and the
  -- applicable values are 'ORDER_HEADER' and 'ORDER_LINE'

   PROCEDURE get_cc_trxn_extn (
      p_order_header_id  IN              NUMBER,
      p_order_line_id    IN              NUMBER,
      p_context_level    IN              VARCHAR2,
      p_contract_hdr_id  IN              NUMBER,
      p_contract_line_id IN              NUMBER,
      x_entity_id        OUT NOCOPY      NUMBER,
      x_return_status    OUT NOCOPY      VARCHAR2
   ) ;

END oks_extwarprgm_pvt;

/
