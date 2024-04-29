--------------------------------------------------------
--  DDL for Package Body OKS_EXTWARPRGM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_EXTWARPRGM_PVT" AS
/* $Header: OKSREWRB.pls 120.87.12010000.3 2009/03/04 10:45:50 spingali ship $ */

   TYPE p_srvline_rec IS RECORD (
      k_line_id   NUMBER
   );

   TYPE p_srvline_tbl IS TABLE OF p_srvline_rec
      INDEX BY BINARY_INTEGER;

/**************************************************************************
   Procedure Get_k_cle_id
   Returns Service lines originated from Order having the same service item
***************************************************************************/
   PROCEDURE get_k_cle_id (
      p_chrid          IN              NUMBER,
      p_invserviceid   IN              NUMBER,
      p_cle_tbl        OUT NOCOPY      p_srvline_tbl
   )
   IS
      -- extwarr cascading
      -- merging servcice lines
      -- Modified the cusror for the fix of bug# 5088409

      CURSOR l_service_csr
      IS
         SELECT /*+ leading (kl)  use_nl (kl ki) */ kl.ID cle_id
           FROM okc_k_lines_b kl, okc_k_items ki, okc_statuses_b ks
          WHERE kl.dnz_chr_id = p_chrid
            AND kl.lse_id IN (1, 14, 19)
            AND kl.ID = ki.cle_id
            AND ki.object1_id1 = TO_CHAR (p_invserviceid)
            AND kl.upg_orig_system_ref = 'ORDER'
            AND ks.code = kl.sts_code                              -- 04-jun-2002 merging service lines from OM
            AND ks.ste_code NOT IN ('TERMINATED', 'CANCELLED')     -- Removed EXPIRED
	      AND kl.date_terminated is NULL;                        -- Modified for fix of bug 4690982

      -- Modified the cusror for the fix of bug# 5088409

      l_ctr           NUMBER;
      l_service_rec   l_service_csr%ROWTYPE;

   BEGIN
      l_ctr := 1;

      FOR l_service_rec IN l_service_csr
      LOOP
         p_cle_tbl (l_ctr).k_line_id := l_service_rec.cle_id;
         l_ctr := l_ctr + 1;
      END LOOP;
   END get_k_cle_id;

/***************************************************************************
    Function check_merge_yn
    Checks if the service line can be merged into an existing contract line
*****************************************************************************/
   FUNCTION check_merge_yn (
      p_k_line_id        IN   NUMBER,
      p_source_line_id   IN   NUMBER,
      p_warranty_flag    IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      -- cursor to get the Order line attributes
      CURSOR source_line_attrbs_csr
      IS
         SELECT invoicing_rule_id, accounting_rule_id, price_list_id,
                commitment_id, invoice_to_org_id, ship_to_org_id
           FROM oe_order_lines_all
          WHERE line_id = p_source_line_id;

      -- Cursor to compare the source line attributes with
      -- target line attributes
      CURSOR target_line_attrbs_csr (
         l_inv_id       NUMBER,
         l_acct_id      NUMBER,
         l_prl_id       VARCHAR2,
         l_commit_id    NUMBER,
         l_invorg_id    NUMBER,
         l_shiporg_id   NUMBER
      )
      IS
         SELECT 'x'
           FROM okc_k_lines_b kl, oks_k_lines_b sl
          WHERE kl.ID = p_k_line_id
            AND kl.ID = sl.cle_id
            AND NVL (sl.acct_rule_id, -99) = NVL (l_acct_id, -99)
            AND NVL (kl.inv_rule_id, -99) = NVL (l_inv_id, -99)
            AND NVL (sl.commitment_id, -99) = NVL (l_commit_id, -99)
            AND NVL (kl.price_list_id, -99) = NVL (l_prl_id, -99)
            AND NVL (kl.bill_to_site_use_id, -99) = NVL (l_invorg_id, -99)
            AND NVL (kl.ship_to_site_use_id, -99) = NVL (l_shiporg_id, -99);

      l_source_rec   source_line_attrbs_csr%ROWTYPE;
      l_merge_yn     BOOLEAN                          := FALSE;
      l_temp         VARCHAR2 (3);
   BEGIN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Check_merge_yn',
                         'Warranty Flag ' || p_warranty_flag
                        );
      END IF;

      IF p_warranty_flag = 'W'
      THEN
         l_merge_yn := TRUE;
         RETURN (l_merge_yn);
      ELSE
         OPEN source_line_attrbs_csr;

         FETCH source_line_attrbs_csr
          INTO l_source_rec;

         IF source_line_attrbs_csr%NOTFOUND
         THEN
            CLOSE source_line_attrbs_csr;

            RAISE g_exception_halt_validation;
         END IF;

         CLOSE source_line_attrbs_csr;

         OPEN target_line_attrbs_csr (l_source_rec.invoicing_rule_id,
                                      l_source_rec.accounting_rule_id,
                                      l_source_rec.price_list_id,
                                      l_source_rec.commitment_id,
                                      l_source_rec.invoice_to_org_id,
                                      l_source_rec.ship_to_org_id
                                     );

         FETCH target_line_attrbs_csr
          INTO l_temp;

         IF target_line_attrbs_csr%FOUND
         THEN
            l_merge_yn := TRUE;
         ELSE
            l_merge_yn := FALSE;
         END IF;

         CLOSE target_line_attrbs_csr;

         RETURN (l_merge_yn);
      END IF;
   END;

--G_Debug_option := Fnd_profile.value('OKS_DEBUG_LOG');
   FUNCTION get_top_line_number (p_chr_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_sub_line_number (p_chr_id IN NUMBER, p_cle_id IN NUMBER)
      RETURN NUMBER;

   PROCEDURE get_sts_code (
      p_ste_code                VARCHAR2,
      p_sts_code                VARCHAR2,
      x_ste_code   OUT NOCOPY   VARCHAR2,
      x_sts_code   OUT NOCOPY   VARCHAR2
   )
   IS
      CURSOR l_ste_csr
      IS
         SELECT code
           FROM okc_statuses_b
          WHERE ste_code = p_ste_code AND default_yn = 'Y';

      CURSOR l_sts_csr
      IS
         SELECT a.code, a.ste_code
           FROM okc_statuses_b a, okc_statuses_b b
          WHERE b.code = p_sts_code
            AND b.ste_code = a.ste_code
            AND a.default_yn = 'Y';

      l_sts_code   VARCHAR2 (30);
   BEGIN
      IF p_sts_code IS NULL
      THEN
         OPEN l_ste_csr;

         FETCH l_ste_csr
          INTO x_sts_code;

         CLOSE l_ste_csr;

         x_ste_code := p_ste_code;
      ELSE
         OPEN l_sts_csr;

         FETCH l_sts_csr
          INTO x_sts_code, x_ste_code;

         CLOSE l_sts_csr;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

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
   ) IS

      l_payercontext_rec    iby_fndcpt_common_pub.payercontext_rec_type;
      l_trxnextension_rec   iby_fndcpt_trxn_pub.trxnextension_rec_type;
      l_response            iby_fndcpt_common_pub.result_rec_type;
      l_order_number        NUMBER;
      l_invoice_to_org_id   NUMBER;
      l_trxn_extension_id   NUMBER;
      l_entity_id           NUMBER;
      l_instr_id            NUMBER;
      l_iby_cust_id         NUMBER;
      l_iby_party           NUMBER;
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_return_status       VARCHAR2 (1) := FND_API.G_RET_STS_SUCCESS;

      -- Cursor to get the transaction extension info for a sales order
      CURSOR c_header_trxid (c_order_header_id IN NUMBER)
      IS
         SELECT ordhdr.order_number
               ,ordhdr.invoice_to_org_id
               ,pmt.trxn_extension_id
           FROM
                oe_order_headers_all ordhdr
                ,oe_payments pmt
          WHERE ordhdr.header_id = c_order_header_id
            AND ordhdr.header_id = pmt.header_id
            AND pmt.line_id IS NULL
            AND pmt.payment_type_code = G_PAYMENT_CREDIT_CARD;

      -- Cursor to get the transaction extension info for a sales order line
      CURSOR c_line_trxid (c_order_line_id IN NUMBER)
      IS
         SELECT ordline.invoice_to_org_id
               ,pmt.trxn_extension_id
           FROM
                oe_order_lines_all ordline
                ,oe_payments pmt
          WHERE ordline.line_id = c_order_line_id
            AND ordline.header_id = pmt.header_id
            AND ordline.line_id = pmt.line_id
            AND pmt.payment_type_code = G_PAYMENT_CREDIT_CARD;

      -- Cursor to get the instrument asignment id for a given transaction
      -- extension id for a sales order header/line
      CURSOR c_instrid (c_trxn_extension_id IN NUMBER)
      IS
         SELECT instr_assignment_id
           FROM iby_trxn_extensions_v
          WHERE trxn_extension_id = c_trxn_extension_id;

      -- Cursor to get the the Bill to customer account corresponding
      -- to a bill to site id
      CURSOR c_cust_csr (p_bill_to_site_use_id NUMBER)
      IS
         SELECT ca.cust_account_id
           FROM hz_cust_acct_sites_all ca, hz_cust_site_uses_all cs
          WHERE ca.cust_acct_site_id = cs.cust_acct_site_id
            AND cs.site_use_id = p_bill_to_site_use_id;

      CURSOR c_party (c_cust_acct_id IN NUMBER)
      IS
         SELECT ca.party_id party_id
           FROM hz_cust_accounts_all ca
          WHERE ca.cust_account_id = c_cust_acct_id;
BEGIN

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,g_module_current||'.get_cc_trxn_extn parameters',
                     'p_context_level = '||p_context_level);

      fnd_log.STRING (fnd_log.level_statement,g_module_current||'.get_cc_trxn_extn parameters',
                     'p_order_header_id = '||p_order_header_id);

      fnd_log.STRING (fnd_log.level_statement,g_module_current||'.get_cc_trxn_extn parameters',
                     'p_order_line_id = '||p_order_line_id);

      fnd_log.STRING (fnd_log.level_statement,g_module_current||'.get_cc_trxn_extn parameters',
                     'p_contract_hdr_id = '||p_contract_hdr_id);

      fnd_log.STRING (fnd_log.level_statement,g_module_current||'.get_cc_trxn_extn parameters',
                     'p_contract_line_id  = '||p_contract_line_id);
   END IF;

   IF p_context_level = G_CONTEXT_ORDER_HEADER THEN

      OPEN c_header_trxid(p_order_header_id);
      FETCH c_header_trxid INTO l_order_number,l_invoice_to_org_id,l_trxn_extension_id;
      CLOSE c_header_trxid;

   ELSIF p_context_level = G_CONTEXT_ORDER_LINE THEN
      OPEN c_line_trxid(p_order_line_id);
      FETCH c_line_trxid INTO l_invoice_to_org_id,l_trxn_extension_id;
      CLOSE c_line_trxid;

   END IF;

      -- Proceed Further only if a Credit Card info is to be processed
      IF l_trxn_extension_id IS NOT NULL THEN
         OPEN c_instrid (l_trxn_extension_id);
         FETCH c_instrid INTO l_instr_id;
         CLOSE c_instrid;

         -- For a transaction extension id, an instrument assignment id
         -- should always exist in iPayments.
         IF l_instr_id IS NULL THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
               IF p_context_level = G_CONTEXT_ORDER_HEADER THEN
                  fnd_log.STRING (fnd_log.level_error,
                                  g_module_current
                               || '.get_cc_trxn_extn-Header.ERROR',
                                  'After CURSOR - c_InstrId'
                               || '   ,Payment Txn ID = '
                               || l_trxn_extension_id
                               || '   ,p_order_header_id = '
                               || p_order_header_id
                              );
               ELSE
                  fnd_log.STRING (fnd_log.level_error,
                                  g_module_current
                               || '.get_cc_trxn_extn-Line.ERROR',
                                  'After CURSOR - c_InstrId'
                               || '  ,Payment Txn ID = '
                               || l_trxn_extension_id
                               || '  ,p_line_id = '
                               || p_order_line_id
                              );
               END IF;
            END IF;
            IF p_context_level = G_CONTEXT_ORDER_HEADER THEN
               okc_api.set_message(g_app_name,
                                   'OKS_CC_INS_ASSG_NOT_FOUND',
                                   'ORDER_NUMBER',
                                   l_order_number
                                   );
            ELSE
               okc_api.set_message(g_app_name,
                                   'OKS_LINE_CC_INS_ASSG_NOT_FOUND',
                                   'ORDER_LINE_ID',
                                   p_order_line_id
                                   );
            END IF;
            RAISE g_exception_halt_validation;
         END IF;

         OPEN c_cust_csr(l_invoice_to_org_id);
         FETCH c_cust_csr INTO l_iby_cust_id;
         CLOSE c_cust_csr;

         OPEN c_party (l_iby_cust_id);
         FETCH c_party INTO l_iby_party;
         CLOSE c_party;

         l_payercontext_rec.payment_function := IBY_FNDCPT_COMMON_PUB.G_PMT_FUNCTION_CUST_PMT;
         l_payercontext_rec.party_id := l_iby_party;
         l_payercontext_rec.cust_account_id := l_iby_cust_id;

         -- Based on the header or line level, the corresponding contract header
         -- or contract line id is passed as the order id
         IF p_context_level = G_CONTEXT_ORDER_HEADER THEN
            l_trxnextension_rec.order_id := p_contract_hdr_id;
         ELSE
            l_trxnextension_rec.order_id := p_contract_line_id;
         END IF;

         l_trxnextension_rec.originating_application_id := g_app_id;
         l_trxnextension_rec.trxn_ref_number1 := TO_CHAR (SYSDATE, 'ddmmyyyyhhmmssss');

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            IF p_context_level = G_CONTEXT_ORDER_HEADER THEN
               fnd_log.STRING(fnd_log.level_statement,g_module_current,' ');
               fnd_log.STRING(
               fnd_log.level_statement,
                g_module_current || '.get_cc_trxn_extn-Header',
                   'Before call to IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension for order header'
                || '  ,Party_Id = '
                || l_payercontext_rec.party_id
                || '  ,Cust_Account_Id = '
                || l_payercontext_rec.cust_account_id
                || '  ,order_id = '
                || l_trxnextension_rec.order_id
                || '  ,Trxn_Ref_Number1 = '
                || l_trxnextension_rec.trxn_ref_number1
                || '  ,instr_assignment = '
                || l_instr_id
                || '  ,application_id= '
                || l_trxnextension_rec.originating_application_id
               );
                 fnd_log.STRING(fnd_log.level_statement,g_module_current,' ');
            ELSE
               fnd_log.STRING(fnd_log.level_statement,g_module_current,' ');
               fnd_log.STRING
               (fnd_log.level_statement,
                g_module_current || '.get_cc_trxn_extn-Line',
                   'Before call to IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension for order line'
                || '  ,Party_Id = '
                || l_payercontext_rec.party_id
                || '  ,Cust_Account_Id = '
                || l_payercontext_rec.cust_account_id
                || '  ,order_id (i.e. order line id) = '
                || l_trxnextension_rec.order_id
                || '  ,Trxn_Ref_Number1 = '
                || l_trxnextension_rec.trxn_ref_number1
                || '  ,instr_assignment = '
                || l_instr_id
                || '  ,application_id= '
                || l_trxnextension_rec.originating_application_id
               );
                 fnd_log.STRING(fnd_log.level_statement,g_module_current,' ');
            END IF;
         END IF;

         -- A payer equivalency level of full is provided for iPayments to be
         -- able to traverse up and down for a given instrument id
         -- Note: The new transaction extension that is created at a customer
         -- account level.
         iby_fndcpt_trxn_pub.create_transaction_extension
                                  (p_api_version            => 1.0,
                                   p_init_msg_list          => 'T',
                                   p_commit                 => 'F',
                                   x_return_status          => l_return_status,
                                   x_msg_count              => l_msg_count,
                                   x_msg_data               => l_msg_data,
                                   p_payer                  => l_payercontext_rec,
                                   p_payer_equivalency      => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_FULL,
                                   p_pmt_channel            => G_PAYMENT_CREDIT_CARD,
                                   p_instr_assignment       => l_instr_id,
                                   p_trxn_attribs           => l_trxnextension_rec,
                                   x_entity_id              => l_entity_id,
                                   x_response               => l_response
                                  );

         IF l_return_status <> 'S' THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
               IF p_context_level = G_CONTEXT_ORDER_HEADER THEN
                  fnd_log.STRING
                  (fnd_log.level_error,
                   g_module_current || '.get_cc_trxn_extn-Header.ERROR',
                      'After call to IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension'
                   || '  ,x_return_status= '
                   || l_return_status
                   || '  ,Result Code = '
                   || l_response.result_code
                   || '  ,Result Category= '
                   || l_response.result_category
                   || '  ,Result Message= '
                   || l_response.result_message
                  );
               ELSE
                  fnd_log.STRING
                  (fnd_log.level_error,
                   g_module_current || '.get_cc_trxn_extn-Line.ERROR',
                      'After call to IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension'
                   || '  ,x_return_status= '
                   || l_return_status
                   || '  ,Result Code = '
                   || l_response.result_code
                   || '  ,Result Category= '
                   || l_response.result_category
                   || '  ,Result Message= '
                   || l_response.result_message
                  );
			   END IF;
            END IF;
            IF p_context_level = G_CONTEXT_ORDER_HEADER THEN
               okc_api.set_message(g_app_name,
                                   'OKS_CC_EXTN_CREATN_FAILED',
                                   'ORDER_NUMBER',
                                   l_order_number
                                   );
            ELSE
               okc_api.set_message(g_app_name,
                                   'OKS_LINE_CC_EXTN_CREATN_FAILED',
                                   'ORDER_LINE_ID',
                                   p_order_line_id
                                   );
            END IF;
            RAISE g_exception_halt_validation;
         END IF;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.STRING (fnd_log.level_statement,
                     g_module_current||'.get_cc_trxn_extn ',
                     'l_entity_id = '||l_entity_id);
         END IF;

         x_entity_id := l_entity_id;
      END IF;
      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
         IF c_header_trxid%ISOPEN THEN
            CLOSE c_header_trxid;
         END IF;

         IF c_line_trxid%ISOPEN THEN
            CLOSE c_line_trxid;
         END IF;

         IF c_instrid%ISOPEN THEN
            CLOSE c_instrid;
         END IF;

         IF c_cust_csr%ISOPEN THEN
            CLOSE c_cust_csr;
         END IF;

         IF c_party%ISOPEN THEN
            CLOSE c_party;
         END IF;

         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level THEN
            IF p_context_level = G_CONTEXT_ORDER_HEADER THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.get_cc_trxn_extn-Header.UNEXPECTED',
                            ' sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
            ELSE
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.get_cc_trxn_extn-Line.UNEXPECTED',
                            ' sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
            END IF;
         END IF;
END get_cc_trxn_extn;


   PROCEDURE party_role (
      p_chrid           IN              NUMBER,
      p_cleid           IN              NUMBER,
      p_rle_code        IN              VARCHAR2,
      p_partyid         IN              NUMBER,
      p_object_code     IN              VARCHAR2,
      x_roleid          OUT NOCOPY      NUMBER,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_version     CONSTANT NUMBER                               := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)                         := 'F';
      l_return_status            VARCHAR2 (1)    := okc_api.g_ret_sts_success;
      l_index                    VARCHAR2 (240);
      --Party Role
      l_cplv_tbl_in              okc_contract_party_pub.cplv_tbl_type;
      l_cplv_tbl_out             okc_contract_party_pub.cplv_tbl_type;

      CURSOR l_party_csr
      IS
         SELECT ID
           FROM okc_k_party_roles_b
          WHERE dnz_chr_id = p_chrid
            AND cle_id IS NULL
            AND chr_id = p_chrid
            AND rle_code = p_rle_code;

      CURSOR l_lparty_csr
      IS
         SELECT ID
           FROM okc_k_party_roles_b
          WHERE dnz_chr_id = p_chrid
            AND chr_id IS NULL
            AND cle_id = p_cleid
            AND rle_code = p_rle_code;

      l_roleid                   NUMBER;
   BEGIN
      l_return_status := okc_api.g_ret_sts_success;

      IF p_cleid IS NULL
      THEN
         l_roleid := NULL;

         OPEN l_party_csr;

         FETCH l_party_csr
          INTO l_roleid;

         CLOSE l_party_csr;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module_current || '.PARTY_ROLE',
                            'Party Role Id = ' || l_roleid
                           );
         END IF;

         IF l_roleid IS NOT NULL
         THEN
            x_roleid := l_roleid;
            RETURN;
         END IF;

         l_cplv_tbl_in (1).chr_id := p_chrid;
      ELSE
         l_roleid := NULL;

         OPEN l_lparty_csr;

         FETCH l_lparty_csr
          INTO l_roleid;

         CLOSE l_lparty_csr;

         IF l_roleid IS NOT NULL
         THEN
            x_roleid := l_roleid;
            RETURN;
         END IF;

         l_cplv_tbl_in (1).cle_id := p_cleid;
      END IF;

      l_cplv_tbl_in (1).sfwt_flag := 'N';
      l_cplv_tbl_in (1).rle_code := p_rle_code;
      l_cplv_tbl_in (1).object1_id1 := p_partyid;
      l_cplv_tbl_in (1).object1_id2 := '#';
      l_cplv_tbl_in (1).jtot_object1_code := p_object_code;
      l_cplv_tbl_in (1).dnz_chr_id := p_chrid;
      okc_contract_party_pub.create_k_party_role
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_cplv_tbl           => l_cplv_tbl_in,
                                           x_cplv_tbl           => l_cplv_tbl_out
                                          );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
             (fnd_log.level_event,
              g_module_current || '.PARTY_ROLE.external_call.after',
                 'okc_contract_party_pub.create_k_party_role(Return status ='
              || l_return_status
              || ')'
              || 'Party Role Id = '
              || l_cplv_tbl_out (1).ID
             );
      END IF;

      IF l_return_status = 'S'
      THEN
         x_roleid := l_cplv_tbl_out (1).ID;
      ELSE
         okc_api.set_message (g_app_name,
                              g_required_value,
                              g_col_name_token,
                              p_rle_code || ' Party Role (HEADER)'
                             );
         RAISE g_exception_halt_validation;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

-----------------------------------------------------------------------
--  GetFormattedInvoiceText
--  added 05/29/2002  --Vigandhi
--  For Bug#2396580
-----------------------------------------------------------------------
   FUNCTION getformattedinvoicetext (
      p_product_item   IN   NUMBER,
      p_start_date     IN   DATE,
      p_end_date       IN   DATE,
      p_item_desc      IN   VARCHAR2,
      p_qty            IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      /* CURSOR l_item_csr IS
            SELECT jtot_object1_code,
                   object1_id1,
                   object1_id2,
                   number_of_items
              FROM okc_k_items
             WHERE cle_id = p_cle_id;
             */
      CURSOR l_inv_csr (p_product_item NUMBER)
      IS
         SELECT t.description NAME, b.concatenated_segments description
           FROM mtl_system_items_b_kfv b, mtl_system_items_tl t
          WHERE b.inventory_item_id = t.inventory_item_id
            AND b.organization_id = t.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND b.inventory_item_id = p_product_item
            AND ROWNUM < 2;

      l_object_code              okc_k_items.jtot_object1_code%TYPE;
      l_object1_id1              okc_k_items.object1_id1%TYPE;
      l_object1_id2              okc_k_items.object1_id2%TYPE;
      l_no_of_items              okc_k_items.number_of_items%TYPE;
      l_name                     VARCHAR2 (2000);
      l_desc                     VARCHAR2 (2000);
      l_formatted_invoice_text   VARCHAR2 (2000);
   BEGIN
      OPEN l_inv_csr (p_product_item);

      FETCH l_inv_csr
       INTO l_name, l_desc;

      CLOSE l_inv_csr;

      IF fnd_profile.VALUE ('OKS_ITEM_DISPLAY_PREFERENCE') = 'DISPLAY_DESC'
      THEN
         l_desc := l_name;                                          --l_desc;
      ELSE
         l_desc := l_desc;                                          --l_name;
      END IF;

      l_formatted_invoice_text :=
         SUBSTR (   p_item_desc
                 || ':'
                 || p_qty
                 || ':'
                 || l_desc
                 || ':'
                 || to_char(p_start_date,'DD-MON-YYYY')
                 || ':'
                 || to_char(p_end_date,'DD-MON-YYYY'),
                 1,
                 450
                );
      RETURN (l_formatted_invoice_text);
   END getformattedinvoicetext;

-----------------------------------------------------------------------
-- Get Contract Hearder Id
-----------------------------------------------------------------------
   FUNCTION get_k_hdr_id (
      p_type             VARCHAR2,
      p_object_id   IN   NUMBER,
      p_enddate     IN   DATE
   )
      RETURN NUMBER
   IS
      CURSOR l_kexists_csr (p_jtf_id VARCHAR2)
      IS
         SELECT chr_id
           FROM okc_k_rel_objs
          WHERE object1_id1 = TO_CHAR (p_object_id)
            AND jtot_object1_code = p_jtf_id;

      CURSOR l_wexists_csr (p_jtf_id VARCHAR2)
      IS
         SELECT chr_id
           FROM okc_k_rel_objs
          WHERE object1_id1 = TO_CHAR (p_object_id)
            AND jtot_object1_code = p_jtf_id
            AND rty_code = 'CONTRACTWARRANTYORDER';

      l_wchrid   NUMBER;
      l_kchrid   NUMBER;
      l_jtf_id   VARCHAR2 (30);

      CURSOR l_hdr_csr
      IS
         SELECT ID chr_id
           FROM okc_k_headers_v
          WHERE attribute1 = p_object_id AND end_date = p_enddate;
   BEGIN
      IF p_type = 'ORDER'
      THEN
         l_jtf_id := g_jtf_order_hdr;

         OPEN l_kexists_csr (l_jtf_id);

         FETCH l_kexists_csr
          INTO l_kchrid;

         IF l_kexists_csr%NOTFOUND
         THEN
            CLOSE l_kexists_csr;

            RETURN (NULL);
         END IF;

         CLOSE l_kexists_csr;

         RETURN (l_kchrid);
      ELSIF p_type = 'RENEW'
      THEN
         OPEN l_hdr_csr;

         FETCH l_hdr_csr
          INTO l_kchrid;

         IF l_hdr_csr%NOTFOUND
         THEN
            CLOSE l_hdr_csr;

            RETURN (NULL);
         END IF;

         CLOSE l_hdr_csr;

         RETURN (l_kchrid);
      ELSIF p_type = 'WARR'
      THEN
         l_jtf_id := g_jtf_order_hdr;

         OPEN l_wexists_csr (l_jtf_id);

         FETCH l_wexists_csr
          INTO l_wchrid;

         IF l_wexists_csr%NOTFOUND
         THEN
            CLOSE l_wexists_csr;

            RETURN (NULL);
         END IF;

         CLOSE l_wexists_csr;

         RETURN (l_wchrid);
      END IF;
   END get_k_hdr_id;

   FUNCTION priced_yn (p_lse_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR c_priced_yn
      IS
         SELECT priced_yn
           FROM okc_line_styles_b
          WHERE ID = p_lse_id;

      v_priced   VARCHAR2 (50) := 'N';
   BEGIN
      FOR cur_c_priced_yn IN c_priced_yn
      LOOP
         v_priced := cur_c_priced_yn.priced_yn;
         EXIT;
      END LOOP;

      RETURN (v_priced);
   END priced_yn;

   FUNCTION check_strmlvl_exists (p_cle_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR l_billsch_csr (p_cle_id IN NUMBER)
      IS
         SELECT ID
           FROM oks_stream_levels_v
          WHERE cle_id = p_cle_id;

      l_strmlvl_id   NUMBER;
   BEGIN
      OPEN l_billsch_csr (p_cle_id);

      FETCH l_billsch_csr
       INTO l_strmlvl_id;

      IF (l_billsch_csr%FOUND)
      THEN
         RETURN (l_strmlvl_id);
      ELSE
         RETURN (NULL);
      END IF;

      CLOSE l_billsch_csr;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN (NULL);
   END;

   FUNCTION check_lvlelements_exists (p_cle_id IN NUMBER)
      RETURN BOOLEAN
   IS
      CURSOR l_billsll_csr (p_cle_id IN NUMBER)
      IS
         SELECT 'x'
           FROM oks_stream_levels_v sll, oks_level_elements lvl
          WHERE lvl.rul_id = sll.ID AND sll.cle_id = p_cle_id;

      v_flag   BOOLEAN      := FALSE;
      v_temp   VARCHAR2 (5);
   BEGIN
      OPEN l_billsll_csr (p_cle_id);

      FETCH l_billsll_csr
       INTO v_temp;

      IF (l_billsll_csr%FOUND)
      THEN
         v_flag := TRUE;
      ELSE
         v_flag := FALSE;
      END IF;

      CLOSE l_billsll_csr;

      RETURN (v_flag);
   END;

/*************************************************************
Creates a record in operation instances for Transfer, Split, Replace
 and Update transactions.
**************************************************************/
   PROCEDURE create_operation_instance (
      p_target_chr_id                   NUMBER,
      p_transaction                     VARCHAR2,
      x_oper_instance_id   OUT NOCOPY   NUMBER,
      x_return_status      OUT NOCOPY   VARCHAR2,
      x_msg_count          OUT NOCOPY   NUMBER,
      x_msg_data           OUT NOCOPY   VARCHAR2
   )
   IS
      CURSOR cop_csr (p_opn_code VARCHAR2)
      IS
         SELECT ID
           FROM okc_class_operations
          WHERE cls_code = (SELECT cls_code
                              FROM okc_subclasses_b
                             WHERE code = 'SERVICE')
                AND opn_code = p_opn_code;

      l_cop_id                   NUMBER;
      l_api_version     CONSTANT NUMBER                          := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)                    := 'F';
      l_return_status            VARCHAR2 (1)                    := 'S';
      l_oiev_tbl_in              okc_oper_inst_pvt.oiev_tbl_type;
      l_oiev_tbl_out             okc_oper_inst_pvt.oiev_tbl_type;
   BEGIN
      x_return_status := l_return_status;

      -- get class operation id
      OPEN cop_csr (p_transaction);

      FETCH cop_csr
       INTO l_cop_id;

      CLOSE cop_csr;

      l_oiev_tbl_in (1).status_code := 'PROCESSED';
      l_oiev_tbl_in (1).cop_id := l_cop_id;
      l_oiev_tbl_in (1).target_chr_id := p_target_chr_id;
      okc_oper_inst_pub.create_operation_instance
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => l_init_msg_list,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_oiev_tbl           => l_oiev_tbl_in,
                                          x_oiev_tbl           => l_oiev_tbl_out
                                         );
      x_oper_instance_id := l_oiev_tbl_out (1).ID;
      x_return_status := l_return_status;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

/***********************************************
Create operation lines , linking the old and new lines
for Split, replace, transfer and update transactions
***********************************************/
   PROCEDURE create_operation_lines (
      p_source_line_id                 NUMBER,
      p_target_line_id                 NUMBER,
      p_source_chr_id                  NUMBER,
      p_target_chr_id                  NUMBER,
      p_opr_instance_id                NUMBER,
      x_return_status     OUT NOCOPY   VARCHAR2,
      x_msg_count         OUT NOCOPY   NUMBER,
      x_msg_data          OUT NOCOPY   VARCHAR2
   )
   IS
      l_api_version     CONSTANT NUMBER                          := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)                    := 'F';
      l_return_status            VARCHAR2 (1)                    := 'S';
      l_olev_tbl_in              okc_oper_inst_pvt.olev_tbl_type;
      l_olev_tbl_out             okc_oper_inst_pvt.olev_tbl_type;
   BEGIN
      x_return_status := l_return_status;
      l_olev_tbl_in (1).oie_id := p_opr_instance_id;
      l_olev_tbl_in (1).process_flag := 'P';
      l_olev_tbl_in (1).subject_chr_id := p_target_chr_id;
      l_olev_tbl_in (1).object_chr_id := p_source_chr_id;
      l_olev_tbl_in (1).subject_cle_id := p_target_line_id;
      l_olev_tbl_in (1).object_cle_id := p_source_line_id;
      l_olev_tbl_in (1).active_yn := 'Y';
      okc_oper_inst_pub.create_operation_line
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => l_init_msg_list,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_olev_tbl           => l_olev_tbl_in,
                                          x_olev_tbl           => l_olev_tbl_out
                                         );
      x_return_status := l_return_status;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

/***********************************************

Check if two contract headers can be merged for
System Transfers
************************************************/
   PROCEDURE header_merge_yn (
      p_source_chr_id   IN              NUMBER,
      p_target_chr_id   IN              NUMBER,
      p_sts_code        IN              VARCHAR2,
      x_eligible_yn     OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      -- [Signed] [Active] (Profile)         <=> [Signed] [Active](Target)
      -- [Entered] (Profile)                  => [Entered, Active] (Target)
      CURSOR source_csr (l_chr_id NUMBER)
      IS
         SELECT a.payment_term_id, a.price_list_id, c.ste_code, --a.STS_CODE,
                a.authoring_org_id, a.currency_code, a.template_yn,
                a.conversion_type, a.conversion_rate, a.conversion_rate_date,
                a.conversion_euro_rate, b.inv_trx_type, b.ar_interface_yn,
                b.summary_trx_yn, b.hold_billing, a.inv_organization_id,
                a.scs_code, c.ste_code source_ste_code, b.period_start,
                b.period_type, b.price_uom, a.billed_at_source
           FROM okc_k_headers_all_b a, oks_k_headers_b b, okc_statuses_b c
          WHERE a.ID = l_chr_id AND a.ID = b.chr_id AND p_sts_code = c.code;

      -- and c.ste_code in ('ACTIVE','ENTERED','SIGNED');

      -- Comparing the profile value 'OKS_TRANSFER_STATUS' with target ste_code
      CURSOR target_csr (
         l_target_chr_id     NUMBER,
         l_pay_term          NUMBER,
         l_price_list        NUMBER,
         l_profile           VARCHAR2,
         l_source_ste_code   VARCHAR2,
         l_org_id            NUMBER,
         l_curr_code         VARCHAR2,
         l_temp_yn           VARCHAR2,
         l_conv_type         VARCHAR2,
         l_conv_rate         VARCHAR2,
         l_conv_rate_date    DATE,
         l_conv_euro         NUMBER,
         l_trx_type          VARCHAR2,
         l_ar_int            VARCHAR2,
         l_sum_trx           VARCHAR2,
         l_hold_bill         VARCHAR2,
         l_inv_org_id        NUMBER,
         l_scs_code          VARCHAR2,
         l_period_start      VARCHAR2,
         l_period_type       VARCHAR2,
         l_price_uom         VARCHAR2,
	 l_billed_at_source  VARCHAR2
      )
      IS
         SELECT a.ID
           FROM okc_k_headers_all_b a, oks_k_headers_b b, okc_statuses_b c
          WHERE a.ID = l_target_chr_id
            AND a.ID = b.chr_id
            AND a.sts_code= c.code --Bug fix 5614310
            AND c.ste_code IN ('ACTIVE', 'ENTERED', 'SIGNED')
            AND (   DECODE (DECODE (l_source_ste_code,
                                    'ACTIVE', 1,
                                    'SIGNED', 1,
                                    'HOLD', 1,
                                    0
                                   ),
                            DECODE (l_profile, 'ACTIVE', 1, 2), 1,
                            3
                           ) =
                              DECODE (c.ste_code,
                                      'ACTIVE', 1,
                                      'SIGNED', 1,
                                      4
                                     )
                 OR DECODE (DECODE (l_source_ste_code,
                                    'ACTIVE', 1,
                                    'SIGNED', 1,
                                    'HOLD', 1,
                                    0
                                   ),
                            DECODE (l_profile, 'ENTERED', 1, 2), 1,
                            3
                           ) = DECODE (c.ste_code, 'ENTERED', 1, 4)
                 OR DECODE (l_source_ste_code, 'ENTERED', 1, 2) =
                                          DECODE (c.ste_code,
                                                  'ENTERED', 1,
                                                  3
                                                 )
                )
            AND NVL (a.payment_term_id, -99) = NVL (l_pay_term, -99)
            AND NVL (a.price_list_id, -99) = NVL (l_price_list, -99)
            AND a.authoring_org_id = l_org_id
            AND a.currency_code = l_curr_code
            AND a.template_yn = l_temp_yn
            AND NVL (a.conversion_type, -99) = NVL (l_conv_type, -99)
            AND NVL (a.conversion_rate, -99) = NVL (l_conv_rate, -99)
            AND DECODE (a.conversion_rate_date,
                        NULL, -99,
                        SYSDATE - TRUNC (a.conversion_rate_date)
                       ) =
                   DECODE (l_conv_rate_date,
                           NULL, -99,
                           SYSDATE - TRUNC (l_conv_rate_date)
                          )
            AND NVL (a.conversion_euro_rate, -99) = NVL (l_conv_euro, -99)
            AND NVL (b.inv_trx_type, -99) = NVL (l_trx_type, -99)
            AND NVL (b.ar_interface_yn, -99) = NVL (l_ar_int, -99)
            AND NVL (b.summary_trx_yn, -99) = NVL (l_sum_trx, -99)
            AND NVL (b.hold_billing, -99) = NVL (l_hold_bill, -99)
            AND NVL (a.inv_organization_id, -99) = NVL (l_inv_org_id, -99)
            AND NVL (a.scs_code, -99) = NVL (l_scs_code, -99)
            AND NVL (b.period_start, -99) = NVL (l_period_start, -99)
            AND NVL (b.period_type, -99) = NVL (l_period_type, -99)
            AND NVL (b.price_uom, -99) = NVL (l_price_uom, -99)
	    AND NVL (a.billed_at_source, '-99') = NVL(l_billed_at_source, '-99');

      l_target_rec   target_csr%ROWTYPE;
      l_source_rec   source_csr%ROWTYPE;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      OPEN source_csr (p_source_chr_id);

      FETCH source_csr
       INTO l_source_rec;

      CLOSE source_csr;

      OPEN target_csr (p_target_chr_id,
                       l_source_rec.payment_term_id,
                       l_source_rec.price_list_id,
                       fnd_profile.VALUE ('OKS_TRANSFER_STATUS'),
                       l_source_rec.source_ste_code,
                       l_source_rec.authoring_org_id,
                       l_source_rec.currency_code,
                       l_source_rec.template_yn,
                       l_source_rec.conversion_type,
                       l_source_rec.conversion_rate,
                       l_source_rec.conversion_rate_date,
                       l_source_rec.conversion_euro_rate,
                       l_source_rec.inv_trx_type,
                       l_source_rec.ar_interface_yn,
                       l_source_rec.summary_trx_yn,
                       l_source_rec.hold_billing,
                       l_source_rec.inv_organization_id,
                       l_source_rec.scs_code,
                       l_source_rec.period_start,
                       l_source_rec.period_type,
                       l_source_rec.price_uom,
                       l_source_rec.billed_at_source
                      );

      FETCH target_csr
       INTO l_target_rec;

      IF target_csr%NOTFOUND
      THEN
         x_eligible_yn := 'N';
      ELSE
         x_eligible_yn := 'Y';
      END IF;

      CLOSE target_csr;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END header_merge_yn;

/***********************************************

Check if two contract lines can be merged for
System Transfers
************************************************/
   PROCEDURE line_merge_yn (
      p_source_line_id   IN              NUMBER,
      p_target_line_id   IN              NUMBER,
      p_source_flag      IN              VARCHAR2,
      x_eligible_yn      OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      x_return_status    OUT NOCOPY      VARCHAR2
   )
   IS
      -- [Signed]  [Active] (Profile)         <=> [Signed]  [Active] (Target)
      -- [Entered] (Profile)                  => [Entered, Active] (Target)
      CURSOR source_line (l_line_id NUMBER)
      IS
         SELECT b.acct_rule_id, a.price_list_id, c.ste_code, a.lse_id,
                a.bill_to_site_use_id, a.line_renewal_type_code,
                b.tax_code                              --Fix for bug 4121175
                          ,
                b.price_uom
           FROM okc_k_lines_b a, oks_k_lines_b b, okc_statuses_b c
          WHERE a.ID = l_line_id AND a.ID = b.cle_id AND a.sts_code = c.code;

      CURSOR service_item (l_line_id NUMBER)
      IS
         SELECT object1_id1
           FROM okc_k_items
          WHERE cle_id = l_line_id AND jtot_object1_code LIKE 'OKX_SYSITEM';

      -- if date_completed is not null then it's billed.
      CURSOR get_date_complete (l_line_id NUMBER)
      IS
         SELECT a.date_completed
           FROM oks_level_elements a, oks_stream_levels_b b
          WHERE b.cle_id = l_line_id AND a.rul_id = b.ID;

      CURSOR target_line (
         l_line_id                  NUMBER,
         l_acct_rule_id             NUMBER,
         l_price_list_id            NUMBER,
         l_ste_code                 VARCHAR2,
         l_lse_id                   NUMBER,
         l_flag                     VARCHAR2,
         l_bill_to_site_use_id      NUMBER,
         l_line_renewal_type_code   VARCHAR2,
         l_tax_code                 VARCHAR2,
         l_price_uom                VARCHAR2
      )
      IS
         SELECT a.ID
           FROM okc_k_lines_b a, oks_k_lines_b b, okc_statuses_b c
          WHERE a.ID = l_line_id
            AND a.ID = b.cle_id
            AND a.sts_code = c.code
            AND c.ste_code IN ('ACTIVE', 'ENTERED', 'SIGNED')
            AND NVL (b.acct_rule_id, -99) = NVL (l_acct_rule_id, -99)
            AND NVL (b.tax_code, -99) = NVL (l_tax_code, -99)
            --Fix for bug 4121175
            AND NVL (b.price_uom, -99) = NVL (l_price_uom, -99)
            AND NVL (a.price_list_id, -99) = NVL (l_price_list_id, -99)
            /*
            AND (  c.ste_code = l_ste_code
                OR decode (l_ste_code, 'SIGNED', 1, 'ACTIVE', 1,  4) =
                   decode(c.ste_code, 'SIGNED', 1, 'ACTIVE', 1, 3)
                 )
            */
            AND a.lse_id = l_lse_id
            AND (   DECODE (l_flag, 'N', 0, 1) = 0
                 OR (    DECODE (l_flag, 'Y', 1, 0) = 1
                     AND NVL (a.bill_to_site_use_id, -99) =
                                               NVL (l_bill_to_site_use_id,
                                                    -99)
                     AND NVL (a.line_renewal_type_code, -99) =
                                            NVL (l_line_renewal_type_code,
                                                 -99)
                    )
                );

      CURSOR sales_credit_csr (l_line_id NUMBER)
      IS
         SELECT PERCENT, sc.sales_credit_type_id1, sct.quota_flag,
                sc.ctc_id sales_person_id, sc.sales_group_id
           FROM oks_k_sales_credits sc, oe_sales_credit_types sct
          WHERE sc.sales_credit_type_id1 = sct.sales_credit_type_id
            AND sc.cle_id = l_line_id;

      CURSOR target_sales_credit_csr (
         l_line_id                 NUMBER,
         l_percent                 NUMBER,
         l_sales_credit_type_id1   NUMBER,
         l_quota_flag              VARCHAR2,
         l_sales_person_id         NUMBER,
         l_sales_group_id          NUMBER
      )
      IS
         SELECT PERCENT, sc.sales_credit_type_id1, sct.quota_flag,
                sc.ctc_id sales_person_id, sc.sales_group_id
           FROM oks_k_sales_credits sc, oe_sales_credit_types sct
          WHERE sc.sales_credit_type_id1 = sct.sales_credit_type_id
            AND sc.cle_id = l_line_id
            AND PERCENT = l_percent
            AND sc.sales_credit_type_id1 = l_sales_credit_type_id1
            AND sct.quota_flag = l_quota_flag
            AND sc.ctc_id = l_sales_person_id
            AND NVL (sc.sales_group_id, -99) = NVL (l_sales_group_id, -99);

      CURSOR sales_credit_count_csr (l_line_id NUMBER)
      IS
         SELECT COUNT (*)
           FROM oks_k_sales_credits
          WHERE cle_id = l_line_id;

      l_source_rec               source_line%ROWTYPE;
      l_target_rentype           target_line%ROWTYPE;
      l_target_sales_rec         target_sales_credit_csr%ROWTYPE;
      l_source_sales_count       NUMBER;
      l_target_sales_count       NUMBER;
      l_target_bill_completed    DATE;
      l_source_bill_completed    DATE;
      l_source_service_item_id   NUMBER;
      l_target_service_item_id   NUMBER;
      l_api_version     CONSTANT NUMBER                            := 1.0;
      l_init_msg_list            VARCHAR2 (2000)            := okc_api.g_false;
      l_return_status            VARCHAR2 (1);
   BEGIN
      l_return_status := okc_api.g_ret_sts_success;

      OPEN source_line (p_source_line_id);

      FETCH source_line
       INTO l_source_rec;

      CLOSE source_line;

      -- Check invoice rule, accounting rule, price list id , currency code,
      -- status, line style id, payment type, billing schedule type.
      OPEN target_line (p_target_line_id,
                        l_source_rec.acct_rule_id,
                        l_source_rec.price_list_id,
                        fnd_profile.VALUE ('OKS_TRANSFER_STATUS'),
                        l_source_rec.lse_id,
                        p_source_flag,
                        l_source_rec.bill_to_site_use_id,
                        l_source_rec.line_renewal_type_code,
                        l_source_rec.tax_code,
                        l_source_rec.price_uom
                       );

      FETCH target_line
       INTO l_target_rentype;

      IF target_line%NOTFOUND
      THEN
         x_eligible_yn := 'N';
      ELSE
         ------------------------- Check Service Item Id ------------------------
         OPEN service_item (p_source_line_id);

         FETCH service_item
          INTO l_source_service_item_id;

         CLOSE service_item;

         OPEN service_item (p_target_line_id);

         FETCH service_item
          INTO l_target_service_item_id;

         CLOSE service_item;

         IF NVL (l_target_service_item_id, -99) =
                                           NVL (l_source_service_item_id,
                                                -99)
         THEN
            x_eligible_yn := 'Y';
         END IF;

         -------------------------- Check  Coverage -----------------------------
         IF     x_eligible_yn = 'Y'
            AND fnd_profile.VALUE ('OKS_CHECK_COV_MATCH') = 'Y'
         THEN
            oks_coverages_pub.check_coverage_match
                              (p_api_version                  => l_api_version,
                               p_init_msg_list                => l_init_msg_list,
                               x_return_status                => l_return_status,
                               x_msg_count                    => x_msg_count,
                               x_msg_data                     => x_msg_data,
                               p_source_contract_line_id      => p_source_line_id,
                               p_target_contract_line_id      => p_target_line_id,
                               x_coverage_match               => x_eligible_yn
                              );

            IF l_return_status <> okc_api.g_ret_sts_success
            THEN
               CLOSE target_line;

               RAISE g_exception_halt_validation;
            END IF;
         END IF;

         -- Vigandhi 06/10/2004
         -- Remove the check for date completed for line merging.
         /*   --------------------- Check Date Completed -----------------------
            If x_eligible_yn = 'Y' Then
                -- The billing is one time so we'll only have one level element.
                Open get_date_complete(p_source_line_id);
                Fetch get_date_complete into l_source_bill_completed;
                Close get_date_complete;

                Open get_date_complete(p_target_line_id);
                Fetch get_date_complete into l_target_bill_completed;
                Close get_date_complete;

                If l_source_bill_completed is null and l_target_bill_completed is null then
                    x_eligible_yn := 'Y';
                Elsif l_source_bill_completed is not null and l_target_bill_completed is not null
                    and  trunc(l_source_bill_completed) = trunc(l_target_bill_completed) then
                    x_eligible_yn := 'Y';
                Else
                    x_eligible_yn := 'N';
                End If;

            End If;        */
            --------------------- Check Sales Credit -----------------------
         IF x_eligible_yn = 'Y'
         THEN
            OPEN sales_credit_count_csr (p_source_line_id);

            FETCH sales_credit_count_csr
             INTO l_source_sales_count;

            CLOSE sales_credit_count_csr;

            OPEN sales_credit_count_csr (p_target_line_id);

            FETCH sales_credit_count_csr
             INTO l_target_sales_count;

            CLOSE sales_credit_count_csr;

            IF l_source_sales_count <> l_target_sales_count
            THEN
               x_eligible_yn := 'N';
            ELSE
               FOR sales_credit_rec IN sales_credit_csr (p_source_line_id)
               LOOP
                  OPEN target_sales_credit_csr
                                     (p_target_line_id,
                                      sales_credit_rec.PERCENT,
                                      sales_credit_rec.sales_credit_type_id1,
                                      sales_credit_rec.quota_flag,
                                      sales_credit_rec.sales_person_id,
                                      sales_credit_rec.sales_group_id
                                     );

                  FETCH target_sales_credit_csr
                   INTO l_target_sales_rec;

                  IF target_sales_credit_csr%NOTFOUND
                  THEN
                     x_eligible_yn := 'N';

                     CLOSE target_sales_credit_csr;

                     EXIT;
                  END IF;

                  CLOSE target_sales_credit_csr;
               END LOOP;
            END IF;            -- l_source_sales_count <> l_target_sales_count
         END IF;                                       --  x_eligible_yn = 'Y'
      --------------------- Check Sales Credit Finished -----------------------
      END IF;                                          -- target_line%NOTFOUND

      CLOSE target_line;

      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END line_merge_yn;

   PROCEDURE check_line_effectivity (
      p_cle_id     IN              NUMBER,
      p_srv_sdt    IN              DATE,
      p_srv_edt    IN              DATE,
      x_line_sdt   OUT NOCOPY      DATE,
      x_line_edt   OUT NOCOPY      DATE,
      x_status     OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_line_csr
      IS
         SELECT start_date, end_date
           FROM okc_k_lines_b
          WHERE ID = p_cle_id;

      l_line_csr_rec   l_line_csr%ROWTYPE;
   BEGIN
      OPEN l_line_csr;

      FETCH l_line_csr
       INTO l_line_csr_rec;

      IF l_line_csr%FOUND
      THEN
         IF     p_srv_sdt >= l_line_csr_rec.start_date
            AND p_srv_edt <= l_line_csr_rec.end_date
         THEN
            x_status := 'N';
         ELSE
            IF p_srv_sdt >= l_line_csr_rec.start_date
            THEN
               x_line_sdt := l_line_csr_rec.start_date;
            ELSE
               x_line_sdt := p_srv_sdt;
            END IF;

            IF p_srv_edt >= l_line_csr_rec.end_date
            THEN
               x_line_edt := p_srv_edt;
            ELSE
               x_line_edt := l_line_csr_rec.end_date;
            END IF;

            x_status := 'Y';
         END IF;
      ELSE
         x_status := 'E';
      END IF;
   END;

   PROCEDURE update_line_dates (
      p_cle_id          IN              NUMBER,
      p_chr_id          IN              NUMBER,
      p_new_sdt         IN              DATE,
      p_new_edt         IN              DATE,
      p_sts_flag        IN              VARCHAR2,
      p_warranty_flag   IN              VARCHAR2,
      x_status          OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_rulegroup_csr
      IS
         SELECT inv_rule_id
           FROM okc_k_lines_b
          WHERE cle_id = p_cle_id AND dnz_chr_id = p_chr_id;

--General
      l_api_version     CONSTANT NUMBER                         := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)              := okc_api.g_false;
      l_return_status            VARCHAR2 (1)                   := 'S';
      l_index                    VARCHAR2 (2000);
--Contract Line
      l_clev_tbl_in              okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out             okc_contract_pub.clev_tbl_type;
      l_cleid                    NUMBER;
      l_rgp_id                   NUMBER;
      l_rule_id                  NUMBER;
      l_invoice_rule_id          NUMBER;
      l_ste_code                 VARCHAR2 (30);
      l_sts_code                 VARCHAR2 (30);
   BEGIN
      x_status := okc_api.g_ret_sts_success;

      IF p_sts_flag = 'Y'
      THEN
         IF p_new_sdt > SYSDATE
         THEN
            get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
            l_clev_tbl_in (1).sts_code := l_sts_code;
         ELSIF p_new_sdt <= SYSDATE AND p_new_edt >= SYSDATE
         THEN
            get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
            l_clev_tbl_in (1).sts_code := l_sts_code;
         ELSIF p_new_edt < SYSDATE
         THEN
            get_sts_code ('EXPIRED', NULL, l_ste_code, l_sts_code);
            l_clev_tbl_in (1).sts_code := l_sts_code;
         END IF;
      END IF;

      --Contract Header Date Update
      l_clev_tbl_in (1).ID := p_cle_id;
      l_clev_tbl_in (1).start_date := p_new_sdt;
      l_clev_tbl_in (1).end_date := p_new_edt;
      okc_contract_pub.update_contract_line
                                       (p_api_version            => l_api_version,
                                        p_init_msg_list          => l_init_msg_list,
                                        p_restricted_update      => okc_api.g_true,
                                        x_return_status          => l_return_status,
                                        x_msg_count              => x_msg_count,
                                        x_msg_data               => x_msg_data,
                                        p_clev_tbl               => l_clev_tbl_in,
                                        x_clev_tbl               => l_clev_tbl_out
                                       );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                 (fnd_log.level_event,
                  g_module_current || '.Update_Line_Dates.external_call.after',
                     'okc_contract_pub.update_contract_line(Return status = '
                  || l_return_status
                  || ')'
                 );
      END IF;

      IF l_return_status = 'S'
      THEN
         l_cleid := l_clev_tbl_out (1).ID;
      ELSE
         x_status := 'E';
         RAISE g_exception_halt_validation;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         NULL;
      WHEN OTHERS
      THEN
         x_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_exception >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            g_module_current
                            || '.Update_Line_Dates.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END;

/*-----------------------------------------------------------------
-- warranty/Extwarranty consolidation
-- P_rty_code new parameter
------------------------------------------------------------------*/
   PROCEDURE create_obj_rel (
      p_k_id            IN              NUMBER,
      p_line_id         IN              NUMBER,
      p_orderhdrid      IN              NUMBER,
      p_rty_code        IN              VARCHAR2,
      p_orderlineid     IN              NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_crjv_tbl_out    OUT NOCOPY      okc_k_rel_objs_pub.crjv_tbl_type
   )
   IS
      l_api_version     CONSTANT NUMBER                           := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)                     := 'F';
      l_return_status            VARCHAR2 (1)                     := 'S';
      l_crjv_tbl_in              okc_k_rel_objs_pub.crjv_tbl_type;
      l_crjv_tbl_out             okc_k_rel_objs_pub.crjv_tbl_type;
   BEGIN
      x_return_status := l_return_status;

      IF p_orderhdrid IS NOT NULL
      THEN
         l_crjv_tbl_in (1).chr_id := p_k_id;
         l_crjv_tbl_in (1).object1_id1 := p_orderhdrid;
         l_crjv_tbl_in (1).object1_id2 := '#';
         l_crjv_tbl_in (1).jtot_object1_code := 'OKX_ORDERHEAD';
         --l_crjv_tbl_in( 1 ).rty_code        := 'CONTRACTSERVICESORDER';
         l_crjv_tbl_in (1).rty_code := p_rty_code;
         okc_k_rel_objs_pub.create_row (p_api_version        => l_api_version,
                                        p_init_msg_list      => l_init_msg_list,
                                        x_return_status      => l_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data,
                                        p_crjv_tbl           => l_crjv_tbl_in,
                                        x_crjv_tbl           => l_crjv_tbl_out
                                       );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_event,
                             g_module_current
                          || '.Create_Obj_Rel.external_call_hdr.after',
                             'okc_k_rel_objs_pub.create_row(Return status = '
                          || l_return_status
                          || ')'
                         );
         END IF;

         IF l_return_status = 'S'
         THEN
            x_crjv_tbl_out := l_crjv_tbl_out;
         ELSE
            x_return_status := l_return_status;
         END IF;
      ELSIF p_orderlineid IS NOT NULL
      THEN
         l_crjv_tbl_in (1).cle_id := p_line_id;
         l_crjv_tbl_in (1).chr_id := p_k_id;           -- Fix for Bug 2844603
         l_crjv_tbl_in (1).object1_id1 := p_orderlineid;
         l_crjv_tbl_in (1).object1_id2 := '#';
         l_crjv_tbl_in (1).jtot_object1_code := 'OKX_ORDERLINE';
         --l_crjv_tbl_in(1).rty_code          := 'CONTRACTSERVICESORDER';
         l_crjv_tbl_in (1).rty_code := p_rty_code;
         okc_k_rel_objs_pub.create_row (p_api_version        => l_api_version,
                                        p_init_msg_list      => l_init_msg_list,
                                        x_return_status      => l_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data,
                                        p_crjv_tbl           => l_crjv_tbl_in,
                                        x_crjv_tbl           => l_crjv_tbl_out
                                       );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_event,
                             g_module_current
                          || '.Create_Obj_Rel.external_call_line.after',
                             'okc_k_rel_objs_pub.create_row(Return status = '
                          || l_return_status
                          || ')'
                         );
         END IF;

         IF l_return_status = 'S'
         THEN
            x_crjv_tbl_out := l_crjv_tbl_out;
         ELSE
            x_return_status := l_return_status;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE check_hdr_effectivity (
      p_chr_id    IN              NUMBER,
      p_srv_sdt   IN              DATE,
      p_srv_edt   IN              DATE,
      x_hdr_sdt   OUT NOCOPY      DATE,
      x_hdr_edt   OUT NOCOPY      DATE,
      x_status    OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_hdr_csr
      IS
         SELECT start_date, end_date
           FROM okc_k_headers_v
          WHERE ID = p_chr_id;

      l_hdr_csr_rec   l_hdr_csr%ROWTYPE;
   BEGIN
      OPEN l_hdr_csr;

      FETCH l_hdr_csr
       INTO l_hdr_csr_rec;

      IF l_hdr_csr%FOUND
      THEN
         IF     p_srv_sdt >= l_hdr_csr_rec.start_date
            AND p_srv_edt <= l_hdr_csr_rec.end_date
         THEN
            x_status := 'N';
         ELSE
            IF p_srv_sdt >= l_hdr_csr_rec.start_date
            THEN
               x_hdr_sdt := l_hdr_csr_rec.start_date;
            ELSE
               x_hdr_sdt := p_srv_sdt;
            END IF;

            IF p_srv_edt >= l_hdr_csr_rec.end_date
            THEN
               x_hdr_edt := p_srv_edt;
            ELSE
               x_hdr_edt := l_hdr_csr_rec.end_date;
            END IF;

            x_status := 'Y';
         END IF;
      ELSE
         x_status := 'E';
      END IF;
   END;

   PROCEDURE update_hdr_dates (
      p_chr_id      IN              NUMBER,
      p_new_sdt     IN              DATE,
      p_new_edt     IN              DATE,
      p_sts_flag    IN              VARCHAR2,
      x_status      OUT NOCOPY      VARCHAR2,
      x_msg_count   OUT NOCOPY      NUMBER,
      x_msg_data    OUT NOCOPY      VARCHAR2
   )
   IS
      --General
      l_api_version     CONSTANT NUMBER                         := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)              := okc_api.g_false;
      l_return_status            VARCHAR2 (1)                   := 'S';
      l_index                    VARCHAR2 (2000);
      --Contract Header
      l_chrv_tbl_in              okc_contract_pub.chrv_tbl_type;
      l_chrv_tbl_out             okc_contract_pub.chrv_tbl_type;
      --Rule Related
      --l_rulv_tbl_in                 okc_rule_pub.rulv_tbl_type;
      --l_rulv_tbl_out                okc_rule_pub.rulv_tbl_type;
      --Time Value Related
      l_isev_ext_tbl_in          okc_time_pub.isev_ext_tbl_type;
      l_isev_ext_tbl_out         okc_time_pub.isev_ext_tbl_type;
      l_chrid                    NUMBER;
      l_timevalue_id             NUMBER;
      l_rgp_id                   NUMBER;
      l_rule_id                  NUMBER;
      l_ste_code                 VARCHAR2 (30);
      l_sts_code                 VARCHAR2 (30);
   BEGIN
      x_status := okc_api.g_ret_sts_success;

      IF p_sts_flag = 'Y'
      THEN
         IF p_new_sdt > SYSDATE
         THEN
            get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
            l_chrv_tbl_in (1).sts_code := l_sts_code;
         ELSIF p_new_sdt <= SYSDATE AND p_new_edt >= SYSDATE
         THEN
            get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
            l_chrv_tbl_in (1).sts_code := l_sts_code;
         ELSIF p_new_edt < SYSDATE
         THEN
            get_sts_code ('EXPIRED', NULL, l_ste_code, l_sts_code);
            l_chrv_tbl_in (1).sts_code := l_sts_code;
         END IF;
      END IF;

      --Contract Header Date Update
      l_chrv_tbl_in (1).ID := p_chr_id;
      l_chrv_tbl_in (1).start_date := p_new_sdt;
      l_chrv_tbl_in (1).end_date := p_new_edt;
      okc_contract_pub.update_contract_header
                                       (p_api_version            => l_api_version,
                                        p_init_msg_list          => l_init_msg_list,
                                        p_restricted_update      => okc_api.g_true,
                                        x_return_status          => l_return_status,
                                        x_msg_count              => x_msg_count,
                                        x_msg_data               => x_msg_data,
                                        p_chrv_tbl               => l_chrv_tbl_in,
                                        x_chrv_tbl               => l_chrv_tbl_out
                                       );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
               (fnd_log.level_event,
                g_module_current || '.Update_Hdr_Dates.external_call.after',
                   'okc_contract_pub.update_contract_header(Return status = '
                || l_return_status
                || ')'
               );
      END IF;

      IF l_return_status = 'S'
      THEN
         l_chrid := l_chrv_tbl_out (1).ID;
      ELSE
         x_status := 'E';
         RAISE g_exception_halt_validation;
      --End If;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         NULL;
      WHEN OTHERS
      THEN
         x_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   FUNCTION get_contract_number (p_hdrid IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR l_hdr_csr
      IS
         SELECT contract_number
           FROM okc_k_headers_v
          WHERE ID = p_hdrid;

      l_contract_number   VARCHAR2 (120);
   BEGIN
      OPEN l_hdr_csr;

      FETCH l_hdr_csr
       INTO l_contract_number;

      CLOSE l_hdr_csr;

      RETURN l_contract_number;
   END;

   PROCEDURE launch_workflow (p_msg IN VARCHAR2)
   IS
--Workflow attributes
      l_itemtype      VARCHAR2 (40)  := 'OKSWARWF';
      l_itemkey       VARCHAR2 (240)
                           := 'OKS-' || TO_CHAR (SYSDATE, 'MMDDYYYYHH24MISS');
      l_process       VARCHAR2 (40)  := 'OKSWARPROC';
      l_notify        VARCHAR2 (10)  := 'Y';
      l_receiver      VARCHAR2 (30);
      l_itemkey_seq   INTEGER;
   BEGIN
      l_notify := NVL (fnd_profile.VALUE ('OKS_INTEGRATION_NOTIFY_YN'), 'NO');
      l_receiver :=
            NVL (fnd_profile.VALUE ('OKS_INTEGRATION_NOTIFY_TO'), 'SYSADMIN');

      IF UPPER (l_notify) = 'YES'
      THEN
         SELECT oks_wf_item_key_number_s1.NEXTVAL
           INTO l_itemkey_seq
           FROM DUAL;

         l_itemkey := 'OKS-' || l_itemkey_seq;
         wf_engine.createprocess (itemtype      => l_itemtype,
                                  itemkey       => l_itemkey,
                                  process       => l_process
                                 );
         wf_engine.setitemattrtext (itemtype      => l_itemtype,
                                    itemkey       => l_itemkey,
                                    aname         => 'MSG_TXT',
                                    avalue        => p_msg
                                   );
         wf_engine.setitemattrtext (itemtype      => l_itemtype,
                                    itemkey       => l_itemkey,
                                    aname         => 'MSG_RECV',
                                    avalue        => l_receiver
                                   );
         wf_engine.startprocess (itemtype      => l_itemtype,
                                 itemkey       => l_itemkey);
      END IF;
   END;

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
   )
   IS
      CURSOR l_parent_line_csr
      IS
         SELECT cle_id
           FROM okc_k_lines_b
          WHERE ID = p_covered_line_id;

      l_api_version     CONSTANT NUMBER                              := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)              := okc_api.g_false;
      l_return_status            VARCHAR2 (1)                        := 'S';
      l_index                    VARCHAR2 (2000);
      --Contract Line Table
      l_clev_tbl_in              okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out             okc_contract_pub.clev_tbl_type;
      --Contract Item
      l_cimv_tbl_in              okc_contract_item_pub.cimv_tbl_type;
      l_cimv_tbl_out             okc_contract_item_pub.cimv_tbl_type;
      l_parent_line_id           NUMBER;
      l_line_id                  NUMBER;
      l_line_item_id             NUMBER;
   BEGIN
      IF p_new_end_date IS NOT NULL
      THEN
         x_return_status := okc_api.g_ret_sts_success;
         l_clev_tbl_in (1).ID := p_covered_line_id;
         l_clev_tbl_in (1).end_date := p_new_end_date;
         okc_contract_pub.update_contract_line
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_clev_tbl               => l_clev_tbl_in,
                                       x_clev_tbl               => l_clev_tbl_out
                                      );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                 (fnd_log.level_event,
                     g_module_current
                  || '.update_contract_line.external_call.after',
                     'okc_contract_pub.update_contract_line(Return status = '
                  || l_return_status
                  || ')'
                 );
         END IF;

         IF l_return_status <> 'S'
         THEN
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'Contract Line Update(UPDATE SUB LINE)'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      IF p_new_negotiated_amt IS NOT NULL
      THEN
         x_return_status := okc_api.g_ret_sts_success;
         l_clev_tbl_in (1).ID := p_covered_line_id;
         l_clev_tbl_in (1).price_negotiated := p_new_negotiated_amt;
         l_clev_tbl_in (1).price_unit := p_list_price;
         okc_contract_pub.update_contract_line
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_clev_tbl               => l_clev_tbl_in,
                                       x_clev_tbl               => l_clev_tbl_out
                                      );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                 (fnd_log.level_event,
                  g_module_current || '.Update_Cov_level.external_call.after',
                     'okc_contract_pub.update_contract_line(Return status = '
                  || l_return_status
                  || ')'
                 );
         END IF;

         IF l_return_status = 'S'
         THEN
            l_line_id := l_clev_tbl_out (1).ID;
         ELSE
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      IF p_new_cp_qty IS NOT NULL
      THEN
         l_cimv_tbl_in (1).ID := p_k_item_id;
         l_cimv_tbl_in (1).number_of_items := p_new_cp_qty;
         okc_contract_item_pub.update_contract_item
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => l_init_msg_list,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_cimv_tbl           => l_cimv_tbl_in,
                                          x_cimv_tbl           => l_cimv_tbl_out
                                         );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_event,
                g_module_current || '.Update_Cov_level.external_call.after',
                   'okc_contract_item_pub.update_contract_item(Return status = '
                || l_return_status
                || ')'
               );
         END IF;

         IF l_return_status = 'S'
         THEN
            l_line_item_id := l_cimv_tbl_out (1).ID;
         ELSE
            RAISE g_exception_halt_validation;
         END IF;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

/***************************************************************************

            PROCEDURE CREATE_K_HDR
           Creates the Contract Header

***************************************************************************/
   PROCEDURE create_k_hdr (
      p_k_header_rec         IN              k_header_rec_type,
      p_contact_tbl          IN              contact_tbl,
      p_salescredit_tbl_in   IN              salescredit_tbl,
      --mmadhavi for bug 4174921
      p_caller               IN              VARCHAR2,
      x_order_error          OUT NOCOPY      VARCHAR2,
      x_chr_id               OUT NOCOPY      NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   IS
      --Third party id
      CURSOR l_thirdparty_csr (p_id NUMBER)
      IS
         SELECT ca.party_id
           FROM okx_customer_accounts_v ca, okx_cust_site_uses_v cs
          WHERE ca.id1 = cs.cust_account_id AND cs.id1 = p_id;

      --party id
      CURSOR l_cust_csr (p_contactid NUMBER)
      IS
         SELECT party_id
           FROM okx_cust_contacts_v
          WHERE id1 = p_contactid AND id2 = '#';

      CURSOR l_ra_hcontacts_cur (p_contact_id NUMBER)
      IS
         SELECT hzr.object_id                                  --, subject_id
                             ,
                hzr.party_id
           --NPALEPU
                     --18-JUN-2005,09-AUG-2005
                     --TCA Project
                     --Replaced hz_party_relationships table with hz_relationships table and ra_hcontacts view with OKS_RA_HCONTACTS_V.
                     --Replaced hzr.party_relationship_id column with hzr.relationship_id column and added new conditions
                    /* FROM ra_hcontacts rah, hz_party_relationships hzr
                       WHERE rah.contact_id = p_contact_id
                       AND rah.party_relationship_id = hzr.party_relationship_id;*/
         FROM   oks_ra_hcontacts_v rah, hz_relationships hzr
          WHERE rah.contact_id = p_contact_id
            AND rah.party_relationship_id = hzr.relationship_id
            AND hzr.subject_table_name = 'HZ_PARTIES'
            AND hzr.object_table_name = 'HZ_PARTIES'
            AND hzr.directional_flag = 'F';

      --END NPALEPU

      --status code
      CURSOR l_sts_csr (p_chr_id NUMBER)
      IS
         SELECT ste_code
           FROM okc_statuses_b, okc_k_headers_v kh
          WHERE code = kh.sts_code AND kh.ID = p_chr_id;

      --Check for vendor object_code
      CURSOR object_code_csr (p_code VARCHAR2)
      IS
         SELECT 'x'
           FROM okc_contact_sources_v
          WHERE cro_code = p_code
            AND buy_or_sell = 'S'
            AND rle_code = 'VENDOR'
            AND jtot_object_code = 'OKX_SALEPERS';

      -- Contact address
      CURSOR address_cur_new (p_contact_id NUMBER)
      IS
         SELECT a.id1
           FROM okx_cust_sites_v a, okx_cust_contacts_v b
          WHERE b.id1 = p_contact_id
            AND a.id1 = b.cust_acct_site_id
            AND a.org_id = okc_context.get_okc_org_id;

      -- party contact id
      CURSOR party_cont_cur (p_contact_id NUMBER)
      IS
         SELECT hzr.party_id
           --NPALEPU
                     --18-JUN-2005,09-AUG-2005
                     --TCA Project
                     --Replaced hz_party_relationships table with hz_relationships table and ra_hcontacts view with OKS_RA_HCONTACTS_V.
                     --Replaced hzr.party_relationship_id column with hzr.relationship_id column and added new conditions
                      /* FROM ra_hcontacts rah,
                            hz_party_relationships hzr
                         WHERE rah.contact_id  = p_contact_id
                         AND rah.party_relationship_id = hzr.party_relationship_id;*/
         FROM   oks_ra_hcontacts_v rah, hz_relationships hzr
          WHERE rah.contact_id = p_contact_id
            AND rah.party_relationship_id = hzr.relationship_id
            AND hzr.subject_table_name = 'HZ_PARTIES'
            AND hzr.object_table_name = 'HZ_PARTIES'
            AND hzr.directional_flag = 'F';

      --END NPALEPU

      -- Primary e-mail address
      CURSOR email_cur_new (p_party_id NUMBER)
      IS
         SELECT contact_point_id
           FROM okx_contact_points_v
          WHERE contact_point_type = 'EMAIL'
            AND primary_flag = 'Y'
            AND owner_table_id = p_party_id;

      -- Primary telephone number
      CURSOR phone_cur_new (p_party_id NUMBER)
      IS
         SELECT contact_point_id
           FROM hz_contact_points
          WHERE contact_point_type = 'PHONE'
            AND NVL (phone_line_type, 'GEN') = 'GEN'
            AND primary_flag = 'Y'
            AND owner_table_id = p_party_id;

      -- Any one fax number
      CURSOR fax_cur_new (p_party_id NUMBER)
      IS
         SELECT contact_point_id
           FROM hz_contact_points
          WHERE contact_point_type = 'PHONE'
            AND phone_line_type = 'FAX'
            AND owner_table_id = p_party_id;

      CURSOR l_salesgrp_csr (p_id NUMBER, p_start_date DATE, p_end_date DATE)
      IS
         SELECT GROUP_ID
           FROM jtf_rs_srp_groups
          WHERE salesrep_id = p_id
            AND org_id = okc_context.get_okc_org_id
            AND p_start_date BETWEEN start_date AND end_date
            AND p_end_date BETWEEN start_date AND end_date;

      CURSOR l_bookdt_csr (p_ord_hdrid NUMBER)
      IS
         SELECT booked_date, order_firmed_date
           FROM oe_order_headers_all
          WHERE header_id = p_ord_hdrid;

      --Territory changes
      CURSOR resource_details (p_resource_id NUMBER)
      IS
         SELECT fu.user_id
           FROM jtf_rs_defresources_vl jrd, fnd_user fu
          WHERE jrd.resource_id = p_resource_id AND fu.user_id = jrd.user_id;

      CURSOR l_salesrep_csr (p_res_id NUMBER, p_org_id NUMBER)
      IS
         SELECT salesrep_id
           FROM jtf_rs_salesreps
          WHERE resource_id = p_res_id AND org_id = p_org_id;

      l_salesgroup_id            NUMBER;
      l_rah_party_id             NUMBER;
      l_rah_hdr_object1_id1      NUMBER;
      l_thirdparty_id            NUMBER;
      l_thirdparty_role          VARCHAR2 (30);
      l_api_version     CONSTANT NUMBER                                 := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)               := okc_api.g_false;
      l_return_status            VARCHAR2 (1)                           := 'S';
      l_index                    VARCHAR2 (2000);
      i                          NUMBER;
      --Contract Header
      l_chrv_tbl_in              okc_contract_pub.chrv_tbl_type;
      l_chrv_tbl_out             okc_contract_pub.chrv_tbl_type;
      l_khrv_tbl_in              oks_khr_pvt.khrv_tbl_type;
      l_khrv_tbl_out             oks_khr_pvt.khrv_tbl_type;
      --SalesCredit
      l_scrv_tbl_in              oks_sales_credit_pub.scrv_tbl_type;
      l_scrv_tbl_out             oks_sales_credit_pub.scrv_tbl_type;
      --Contract Groupings
      l_cgcv_tbl_in              okc_contract_group_pub.cgcv_tbl_type;
      l_cgcv_tbl_out             okc_contract_group_pub.cgcv_tbl_type;
      --Contacts
      l_ctcv_tbl_in              okc_contract_party_pub.ctcv_tbl_type;
      l_ctcv_tbl_out             okc_contract_party_pub.ctcv_tbl_type;
      --Agreements/Governance
      l_gvev_tbl_in              okc_contract_pub.gvev_tbl_type;
      l_gvev_tbl_out             okc_contract_pub.gvev_tbl_type;
      --Time Value Related
      l_isev_ext_tbl_in          okc_time_pub.isev_ext_tbl_type;
      l_isev_ext_tbl_out         okc_time_pub.isev_ext_tbl_type;
      --Approval WorkFlow
      l_cpsv_tbl_in              okc_contract_pub.cpsv_tbl_type;
      l_cpsv_tbl_out             okc_contract_pub.cpsv_tbl_type;
      --REL OBJS
      l_crjv_tbl_out             okc_k_rel_objs_pub.crjv_tbl_type;
      --Return IDs
      l_chrid                    NUMBER;
      l_partyid                  NUMBER;
      l_partyid_v                NUMBER;
      l_partyid_t                NUMBER;
      l_add2partyid              NUMBER;
      l_rule_group_id            NUMBER;
      l_rule_id                  NUMBER;
      l_govern_id                NUMBER;
      l_time_value_id            NUMBER;
      l_contact_id               NUMBER;
      l_grpid                    NUMBER;
      l_pdfid                    NUMBER;
      l_ctrgrp                   NUMBER;
      l_cust_partyid             NUMBER;
      l_findparty_id             NUMBER;
      l_hdr_contactid            NUMBER;
      l_sts_code                 VARCHAR2 (30);
      l_ste_code                 VARCHAR2 (30);
      --l_object_code               VARCHAR2( 200 );
      l_temp                     VARCHAR2 (1);
      l_email_id                 NUMBER;
      l_phone_id                 NUMBER;
      l_fax_id                   NUMBER;
      l_site_id                  NUMBER;
      l_msg_data                 VARCHAR2 (2000);
      l_ind                      NUMBER;
      l_book_dt                  DATE;
      l_ord_firmed_date          DATE;
      l_party_contact            NUMBER;
      l_salescredit_id           NUMBER;
      j                          NUMBER;
      -- Territory changes
      l_counter                  NUMBER;
      l_user_id                  NUMBER;
      l_count                    NUMBER;
      l_party_name               VARCHAR2 (360);
      l_country_code             VARCHAR2 (60);
      l_state_code               VARCHAR2 (120);
      l_gen_bulk_rec             jtf_terr_assign_pub.bulk_trans_rec_type;
      l_gen_return_rec           jtf_terr_assign_pub.bulk_winners_rec_type;
      l_use_type                 VARCHAR2 (30);
      l_msg_count                NUMBER;
      l_derived_res_id           NUMBER;
      l_resource_id              NUMBER;
      l_salesrep_id              NUMBER;
      l_new_org_id               NUMBER;
      l_entity_id		 NUMBER;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module_current || '.Create_K_Hdr.begin',
                            'Merge Type = '
                         || p_k_header_rec.merge_type
                         || 'Merge Id'
                         || p_k_header_rec.merge_object_id
                        );
      END IF;

      IF p_k_header_rec.merge_type = 'NEW'
      THEN
         l_chrid := NULL;
      ELSIF p_k_header_rec.merge_type = 'LTC'
      THEN
         l_chrid := p_k_header_rec.merge_object_id;
      ELSIF p_k_header_rec.merge_type IS NOT NULL
      THEN
         l_chrid :=
            get_k_hdr_id (p_type           => p_k_header_rec.merge_type,
                          p_object_id      => p_k_header_rec.merge_object_id,
                          p_enddate        => p_k_header_rec.end_date
                         );
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Hdr',
                         'Chr id = ' || l_chrid
                        );
      END IF;

      IF l_chrid IS NOT NULL
      THEN
         OPEN l_sts_csr (l_chrid);

         FETCH l_sts_csr
          INTO l_sts_code;

         CLOSE l_sts_csr;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module_current || '.Create_K_Hdr',
                            'Status code = ' || l_sts_code
                           );
         END IF;

         IF l_sts_code NOT IN ('TERMINATED', 'CANCELLED')
         THEN                                               -- Removed EXPIRED
            IF l_sts_code = 'EXPIRED'
            THEN
               get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);

               UPDATE okc_k_headers_b
                  SET sts_code = l_sts_code
                WHERE ID = l_chrid;
                     /*bugfix for 6882512*/
 	                 /* Updating the status in okc_contacts table.*/
 	                  OKC_CTC_PVT.update_contact_stecode(p_chr_id => l_chrid,
 	                                               x_return_status=>l_return_status);

 	                  IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
 	                       RAISE g_exception_halt_validation;
 	                  END IF;
            END IF;
                   /*bugfix for 6882512*/
            x_chr_id := l_chrid;
            l_return_status := okc_api.g_ret_sts_success;
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      get_sts_code (NULL, p_k_header_rec.sts_code, l_ste_code, l_sts_code);

      -------Fix for Bug 2707303
      IF NVL (l_ste_code, 'ENTERED') IN ('ACTIVE', 'SIGNED')
      THEN
         l_book_dt := NULL;

         IF p_k_header_rec.order_hdr_id IS NOT NULL
         THEN
            OPEN l_bookdt_csr (p_k_header_rec.order_hdr_id);

            FETCH l_bookdt_csr
             INTO l_book_dt, l_ord_firmed_date;

            CLOSE l_bookdt_csr;
         END IF;

         l_chrv_tbl_in (1).date_signed :=
            NVL (NVL (l_ord_firmed_date, l_book_dt),
                 p_k_header_rec.start_date);
         l_chrv_tbl_in (1).date_approved :=
            NVL (NVL (l_ord_firmed_date, l_book_dt),
                 p_k_header_rec.start_date);
      ELSE
         l_chrv_tbl_in (1).date_signed := NULL;
         l_chrv_tbl_in (1).date_approved := NULL;
      END IF;

      IF p_k_header_rec.cust_po_number IS NOT NULL
      THEN
         l_chrv_tbl_in (1).cust_po_number_req_yn := 'Y';
      ELSE
         l_chrv_tbl_in (1).cust_po_number_req_yn := 'N';
      END IF;

      -- rules seeded by okc
      l_chrv_tbl_in (1).price_list_id := p_k_header_rec.price_list_id;   --PRE
      l_chrv_tbl_in (1).payment_term_id := p_k_header_rec.payment_term_id;
      --PTR
      l_chrv_tbl_in (1).conversion_type := p_k_header_rec.cvn_type;      --CVN
      l_chrv_tbl_in (1).conversion_rate := p_k_header_rec.cvn_rate;      --CVN
      l_chrv_tbl_in (1).conversion_rate_date := p_k_header_rec.cvn_date; --CVN
      l_chrv_tbl_in (1).conversion_euro_rate := p_k_header_rec.cvn_euro_rate;
      --CVN
      l_chrv_tbl_in (1).billed_at_source := p_k_header_rec.billed_at_source;
      --IMP

      l_chrv_tbl_in (1).bill_to_site_use_id := p_k_header_rec.bill_to_id;
      --BTO
      l_chrv_tbl_in (1).ship_to_site_use_id := p_k_header_rec.ship_to_id;
      --STO
      l_chrv_tbl_in (1).inv_rule_id := p_k_header_rec.invoice_rule_id;   --IRE

      IF p_k_header_rec.renewal_type IS NOT NULL
      THEN                                                               --REN
         l_chrv_tbl_in (1).renewal_type_code := p_k_header_rec.renewal_type;
         l_chrv_tbl_in (1).APPROVAL_TYPE := p_k_header_rec.RENEWAL_APPROVAL_FLAG;  --Bug# 5173373
      END IF;

      l_chrv_tbl_in (1).sfwt_flag := 'N';
      l_chrv_tbl_in (1).contract_number := p_k_header_rec.contract_number;
      l_chrv_tbl_in (1).sts_code := p_k_header_rec.sts_code;
      l_chrv_tbl_in (1).scs_code := NVL (p_k_header_rec.scs_code, 'WARRANTY');
      l_chrv_tbl_in (1).authoring_org_id := p_k_header_rec.authoring_org_id;
      l_chrv_tbl_in (1).inv_organization_id :=
         NVL (p_k_header_rec.inv_organization_id,
              okc_context.get_okc_organization_id
             );
      l_chrv_tbl_in (1).pre_pay_req_yn := 'N';
      l_chrv_tbl_in (1).cust_po_number := p_k_header_rec.cust_po_number;
      l_chrv_tbl_in (1).qcl_id := p_k_header_rec.qcl_id;
      l_chrv_tbl_in (1).short_description :=
          NVL (p_k_header_rec.short_description, 'Warranty/Extended Warranty');
      l_chrv_tbl_in (1).template_yn := 'N';
      l_chrv_tbl_in (1).start_date := p_k_header_rec.start_date;
      l_chrv_tbl_in (1).end_date := p_k_header_rec.end_date;
      l_chrv_tbl_in (1).chr_type := okc_api.g_miss_char;
      l_chrv_tbl_in (1).archived_yn := 'N';
      l_chrv_tbl_in (1).deleted_yn := 'N';
      l_chrv_tbl_in (1).created_by := okc_api.g_miss_num;
      l_chrv_tbl_in (1).creation_date := okc_api.g_miss_date;
      l_chrv_tbl_in (1).currency_code := p_k_header_rec.currency;
      l_chrv_tbl_in (1).buy_or_sell := 'S';
      l_chrv_tbl_in (1).issue_or_receive := 'I';
      l_chrv_tbl_in (1).attribute1 := p_k_header_rec.attribute1;
      l_chrv_tbl_in (1).attribute2 := p_k_header_rec.attribute2;
      l_chrv_tbl_in (1).attribute3 := p_k_header_rec.attribute3;
      l_chrv_tbl_in (1).attribute4 := p_k_header_rec.attribute4;
      l_chrv_tbl_in (1).attribute5 := p_k_header_rec.attribute5;
      l_chrv_tbl_in (1).attribute6 := p_k_header_rec.attribute6;
      l_chrv_tbl_in (1).attribute7 := p_k_header_rec.attribute7;
      l_chrv_tbl_in (1).attribute8 := p_k_header_rec.attribute8;
      l_chrv_tbl_in (1).attribute9 := p_k_header_rec.attribute9;
      l_chrv_tbl_in (1).attribute10 := p_k_header_rec.attribute10;
      l_chrv_tbl_in (1).attribute11 := p_k_header_rec.attribute11;
      l_chrv_tbl_in (1).attribute12 := p_k_header_rec.attribute12;
      l_chrv_tbl_in (1).attribute13 := p_k_header_rec.attribute13;
      l_chrv_tbl_in (1).attribute14 := p_k_header_rec.attribute14;
      l_chrv_tbl_in (1).attribute15 := p_k_header_rec.attribute15;

      IF p_k_header_rec.merge_type = 'RENEW'
      THEN
         l_chrv_tbl_in (1).attribute1 := p_k_header_rec.merge_object_id;
      END IF;

      okc_contract_pub.create_contract_header
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chrv_tbl           => l_chrv_tbl_in,
                                           x_chrv_tbl           => l_chrv_tbl_out
                                          );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
               (fnd_log.level_event,
                g_module_current || '.Create_K_Hdr.external_call.after',
                   'okc_contract_pub.create_contract_header(Return Status = '
                || l_return_status
                || ')'
               );
      END IF;

      IF l_return_status = 'S'
      THEN
         l_chrid := l_chrv_tbl_out (1).ID;
      ELSE
         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            x_order_error := '#';

            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_encoded            => 'T',
                                p_data               => l_msg_data,
                                p_msg_index_out      => l_ind
                               );
               x_order_error := x_order_error || l_msg_data || '#';

               IF (g_fnd_log_option = 'Y')
               THEN
                  fnd_message.set_encoded (l_msg_data);
                  l_msg_data := fnd_message.get;
                  fnd_file.put_line
                             (fnd_file.LOG,
                                 '(okc_contract_pub).create_contract_header '
                              || l_msg_data
                             );
               END IF;
            END LOOP;

            RAISE g_exception_halt_validation;
         ELSE
            --mmadhavi
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'HEADER (HEADER)'
                                );
         END IF;

         RAISE g_exception_halt_validation;
      END IF;


      -- Get the transaction extension id for the contract header
      IF p_k_header_rec.order_hdr_id IS NOT NULL THEN
         get_cc_trxn_extn (
            p_order_header_id  => p_k_header_rec.order_hdr_id,
            p_order_line_id    => NULL,
            p_context_level    => G_CONTEXT_ORDER_HEADER,
            p_contract_hdr_id  => l_chrid,
            p_contract_line_id => NULL,
            x_entity_id        => l_entity_id,
            x_return_status    => l_return_status );

         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            -- Populate the oks header record with the trxn_extension_id
            l_khrv_tbl_in (1).trxn_extension_id := l_entity_id;
            IF l_entity_id IS NOT NULL THEN
               l_khrv_tbl_in (1).payment_type := 'CCR';  -- Credit Card
            END IF;
         ELSE
            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_encoded            => 'T',
                                p_data               => l_msg_data,
                                p_msg_index_out      => l_ind
                               );

               IF (g_fnd_log_option = 'Y') THEN
                  fnd_message.set_encoded (l_msg_data);
                  l_msg_data := fnd_message.get;
                  fnd_file.put_line
                             (fnd_file.LOG,
                                 'get_cc_trxn for header'
                              || l_msg_data
                             );
               END IF;
            END LOOP;
            RAISE g_exception_halt_validation;
         END IF;
      END IF;


      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Hdr.oks_header_rules',
                            'Accounting id = '
                         || p_k_header_rec.accounting_rule_id
                         || ',renewal type = '
                         || p_k_header_rec.renewal_type
                         || ',billing id = '
                         || p_k_header_rec.billing_profile_id
                         || ',renewal po = '
                         || p_k_header_rec.renewal_po
                         || ',ren price list = '
                         || p_k_header_rec.renewal_price_list_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Hdr.oks_header_rules',
                            'ren markup = '
                         || p_k_header_rec.renewal_markup
                         || ',qto contact = '
                         || p_k_header_rec.qto_contact_id
                         || ',contact id = '
                         || p_k_header_rec.contact_id
                         || ',tax status = '
                         || p_k_header_rec.tax_status_flag
                        );
      END IF;

      -- Hdr rules inserted by oks
      l_khrv_tbl_in (1).chr_id := l_chrv_tbl_out (1).ID;
      l_khrv_tbl_in (1).acct_rule_id := p_k_header_rec.accounting_rule_id;
      --ARL
      l_khrv_tbl_in (1).billing_profile_id :=
                                             p_k_header_rec.billing_profile_id;
      -- Fix for bug 3396484
      l_khrv_tbl_in (1).renewal_po_required :=p_k_header_rec.renewal_po; /*Bug:7555733*/
      --RPO
      l_khrv_tbl_in (1).renewal_pricing_type :=
                                           p_k_header_rec.renewal_pricing_type;
      --RPT
      l_khrv_tbl_in (1).price_uom := p_k_header_rec.price_uom;

      --mmadhavi fix for bug 4004028
      IF (l_khrv_tbl_in (1).renewal_pricing_type = 'MAN')
      THEN
         l_khrv_tbl_in (1).renewal_price_list := NULL;
      ELSE
         l_khrv_tbl_in (1).renewal_price_list :=
                                         p_k_header_rec.renewal_price_list_id;
      END IF;

      --mmadhavi
      IF p_k_header_rec.renewal_pricing_type = 'PCT'
      THEN                                                               --RPT
         l_khrv_tbl_in (1).renewal_markup_percent :=
                                                p_k_header_rec.renewal_markup;
      ELSE
         l_khrv_tbl_in (1).renewal_markup_percent := NULL;
      END IF;

      IF p_k_header_rec.qto_contact_id IS NOT NULL
      THEN                                                               --QTO
         l_khrv_tbl_in (1).quote_to_contact_id :=
                                                p_k_header_rec.qto_contact_id;
         l_khrv_tbl_in (1).quote_to_site_id := p_k_header_rec.qto_site_id;
         l_khrv_tbl_in (1).quote_to_email_id := p_k_header_rec.qto_email_id;
         l_khrv_tbl_in (1).quote_to_phone_id := p_k_header_rec.qto_phone_id;
         l_khrv_tbl_in (1).quote_to_fax_id := p_k_header_rec.qto_fax_id;
      ELSIF p_k_header_rec.contact_id IS NOT NULL
      THEN
         OPEN party_cont_cur (p_k_header_rec.contact_id);

         FETCH party_cont_cur
          INTO l_party_contact;

         CLOSE party_cont_cur;

         OPEN address_cur_new (p_k_header_rec.contact_id);

         FETCH address_cur_new
          INTO l_site_id;

         CLOSE address_cur_new;

         OPEN email_cur_new (l_party_contact);

         FETCH email_cur_new
          INTO l_email_id;

         CLOSE email_cur_new;

         OPEN phone_cur_new (l_party_contact);

         FETCH phone_cur_new
          INTO l_phone_id;

         CLOSE phone_cur_new;

         OPEN fax_cur_new (l_party_contact);

         FETCH fax_cur_new
          INTO l_fax_id;

         CLOSE fax_cur_new;

         l_khrv_tbl_in (1).quote_to_contact_id := p_k_header_rec.contact_id;
         l_khrv_tbl_in (1).quote_to_site_id := l_site_id;
         l_khrv_tbl_in (1).quote_to_email_id := l_email_id;
         l_khrv_tbl_in (1).quote_to_phone_id := l_phone_id;
         l_khrv_tbl_in (1).quote_to_fax_id := l_fax_id;
      END IF;

      l_khrv_tbl_in (1).ar_interface_yn :=
                                      p_k_header_rec.ar_interface_yn;
      l_khrv_tbl_in (1).hold_billing := NVL (p_k_header_rec.hold_billing, 'N');
      l_khrv_tbl_in (1).summary_trx_yn :=
                                      NVL (p_k_header_rec.summary_trx_yn, 'N');
      l_khrv_tbl_in (1).inv_trx_type := p_k_header_rec.inv_trx_type;
      l_khrv_tbl_in (1).tax_status := p_k_header_rec.tax_status_flag;    --TAX
      l_khrv_tbl_in (1).tax_code := NULL;                                --TAX
      l_khrv_tbl_in (1).tax_exemption_id := p_k_header_rec.tax_exemption_id;
      --TAX
      l_khrv_tbl_in (1).created_by := okc_api.g_miss_num;
      l_khrv_tbl_in (1).creation_date := okc_api.g_miss_date;

      IF p_k_header_rec.ccr_number IS NOT NULL
      THEN
         l_khrv_tbl_in (1).payment_type := 'CCR';
         l_khrv_tbl_in (1).cc_no := p_k_header_rec.ccr_number;
         l_khrv_tbl_in (1).cc_expiry_date := p_k_header_rec.ccr_exp_date;
      END IF;

      l_khrv_tbl_in (1).period_start := p_k_header_rec.period_start;
      l_khrv_tbl_in (1).period_type := p_k_header_rec.period_type;
      l_khrv_tbl_in (1).grace_period := p_k_header_rec.grace_period;
      l_khrv_tbl_in (1).grace_duration := p_k_header_rec.grace_duration;
      l_khrv_tbl_in (1).renewal_status := p_k_header_rec.renewal_status;
                                   -- Added by JVARGHES for 12.0 enhancements.
      -- Added for 120 CC EXTN project
   --   l_khrv_tbl_in (1).trxn_extension_id := p_k_header_rec.trxn_extension_id;

      --

      --Added in R12 by rsu
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Hdr',
                         'Before calling oks_contract_hdr_pub.create_header'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Hdr',
                            'p_k_header_rec.tax_classification_code: '
                         || p_k_header_rec.tax_classification_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Hdr',
                            'p_k_header_rec.exemption_certificate_number: '
                         || p_k_header_rec.exemption_certificate_number
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Hdr',
                            'p_k_header_rec.exemption_reason_code: '
                         || p_k_header_rec.exemption_reason_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Hdr',
                            'p_k_header_rec.tax_status_flag: '
                         || p_k_header_rec.tax_status_flag
                        );
      END IF;

      l_khrv_tbl_in (1).tax_classification_code :=
                                        p_k_header_rec.tax_classification_code;
      l_khrv_tbl_in (1).exempt_certificate_number :=
                                   p_k_header_rec.exemption_certificate_number;
      l_khrv_tbl_in (1).exempt_reason_code :=
                                          p_k_header_rec.exemption_reason_code;
      --End: added in R12 by rsu
      oks_contract_hdr_pub.create_header (p_api_version        => l_api_version,
                                          p_init_msg_list      => l_init_msg_list,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_khrv_tbl           => l_khrv_tbl_in,
                                          x_khrv_tbl           => l_khrv_tbl_out,
                                          p_validate_yn        => 'N'
                                         );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                   (fnd_log.level_event,
                    g_module_current || '.Create_K_Hdr.external_call.after',
                       ' oks_contract_hdr_pub.create_header(Return Status = '
                    || l_return_status
                    || ')'
                   );
      END IF;

      IF NOT l_return_status = okc_api.g_ret_sts_success
      THEN
         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            x_order_error := '#';

            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_encoded            => 'T',
                                p_data               => l_msg_data,
                                p_msg_index_out      => l_ind
                               );
               x_order_error := x_order_error || l_msg_data || '#';

               IF (g_fnd_log_option = 'Y')
               THEN
                  fnd_message.set_encoded (l_msg_data);
                  l_msg_data := fnd_message.get;
                  fnd_file.put_line
                                  (fnd_file.LOG,
                                      '(oks_contract_hdr_pub).create_header '
                                   || l_msg_data
                                  );
               END IF;
            END LOOP;

            RAISE g_exception_halt_validation;
         ELSE
            --mmadhavi
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'OKS (HEADER)'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      IF p_k_header_rec.order_line_id IS NOT NULL
      THEN
         oks_extwar_util_pvt.update_contract_details
                                               (l_chrid,
                                                p_k_header_rec.order_line_id,
                                                l_return_status
                                               );

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      IF p_k_header_rec.scs_code IN ('WARRANTY', 'SERVICE')
      THEN
         --Party Role Routine ('VENDOR')
         party_role (p_chrid              => l_chrid,
                     p_cleid              => NULL,
                     p_rle_code           => 'VENDOR',
                     p_partyid            => p_k_header_rec.authoring_org_id,
                     p_object_code        => g_jtf_party_vendor,
                     x_roleid             => l_partyid_v,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     x_return_status      => l_return_status
                    );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                               g_module_current
                            || '.Create_K_Hdr.Internal_call.after',
                               ' Party_role for Vendor(Return Status = '
                            || l_return_status
                            || ')'
                            || l_partyid_v
                           );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
            RAISE g_exception_halt_validation;
         END IF;

         --Party Role Routine ('CUSTOMER')
         party_role (p_chrid              => l_chrid,
                     p_cleid              => NULL,
                     p_rle_code           => 'CUSTOMER',
                     p_partyid            => p_k_header_rec.party_id,
                     p_object_code        => g_jtf_party,
                     x_roleid             => l_partyid,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     x_return_status      => l_return_status
                    );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                               g_module_current
                            || '.Create_K_Hdr.Internal_call.after',
                               ' Party_role for Customer(Return Status = '
                            || l_return_status
                            || ')'
                            || l_partyid
                           );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
            RAISE g_exception_halt_validation;
         END IF;
      ELSE
         --Party Role Routine ('MERCHANT')
         party_role (p_chrid              => l_chrid,
                     p_cleid              => NULL,
                     p_rle_code           => 'MERCHANT',
                     p_partyid            => p_k_header_rec.authoring_org_id,
                     p_object_code        => g_jtf_party_vendor,
                     x_roleid             => l_partyid_v,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     x_return_status      => l_return_status
                    );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                               g_module_current
                            || '.Create_K_Hdr.Internal_call.after',
                               ' Party_role for Merchant(Return Status = '
                            || l_return_status
                            || ')'
                            || l_partyid_v
                           );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
            RAISE g_exception_halt_validation;
         END IF;

         --Party Role Routine ('SUBSCRIBER')
         party_role (p_chrid              => l_chrid,
                     p_cleid              => NULL,
                     p_rle_code           => 'SUBSCRIBER',
                     p_partyid            => p_k_header_rec.party_id,
                     p_object_code        => g_jtf_party,
                     x_roleid             => l_partyid,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     x_return_status      => l_return_status
                    );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                               g_module_current
                            || '.Create_K_Hdr.Internal_call.after',
                               ' Party_role for Subscriber(Return Status = '
                            || l_return_status
                            || ')'
                            || l_partyid
                           );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      /* Check if the bill to belong to the order customer, if not create a third party role*/
      l_thirdparty_id := NULL;

      OPEN l_thirdparty_csr (p_k_header_rec.bill_to_id);

      FETCH l_thirdparty_csr
       INTO l_thirdparty_id;

      CLOSE l_thirdparty_csr;

      IF l_thirdparty_id IS NOT NULL
      THEN
         IF NOT l_thirdparty_id = p_k_header_rec.party_id
         THEN
            --Party Role Routine ('THIRD_PARTY')
            l_thirdparty_role :=
                         NVL (p_k_header_rec.third_party_role, 'THIRD_PARTY');

            --mmadhavi
            IF (p_caller = 'OC')
            THEN
               IF (l_thirdparty_role IN ('VENDOR', 'CUSTOMER'))
               THEN
                  fnd_message.set_name (g_app_name,
                                        'OKS_INVD_THIRD_PARTY_ROLE'
                                       );
                  x_order_error := '#' || fnd_message.get_encoded || '#';
                  l_return_status := okc_api.g_ret_sts_error;
                  RAISE g_exception_halt_validation;
               END IF;
            END IF;

            --mmadhavi
            party_role (p_chrid              => l_chrid,
                        p_cleid              => NULL,
                        p_rle_code           => l_thirdparty_role,
                        p_partyid            => l_thirdparty_id,
                        p_object_code        => g_jtf_party,
                        x_roleid             => l_partyid_t,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        x_return_status      => l_return_status
                       );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                           (fnd_log.level_event,
                               g_module_current
                            || '.Create_K_Hdr.Internal_call.after',
                               ' Party_role for Third Party(Return Status = '
                            || l_return_status
                            || ')'
                            || l_partyid_t
                           );
            END IF;

            IF NOT l_return_status = okc_api.g_ret_sts_success
            THEN
               x_return_status := l_return_status;
               RAISE g_exception_halt_validation;
            END IF;
         END IF;
      END IF;

      ---Creating Vendor Contact

      -- Fix for the Bug3557612
      -- Create vendor contact role if the profile option is not null
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.Create_K_Hdr.before_vendor_contact',
                            ' Vendor contact profile option value = '
                         || fnd_profile.VALUE ('OKS_VENDOR_CONTACT_ROLE')
                         || ' Territory profile option value = '
                         || fnd_profile.VALUE ('OKS_TERR_SALES_REP')
                        );
      END IF;

      /************ Territory changes ****************************/
      IF    ( NVL (fnd_profile.VALUE ('OKS_TERR_SALES_REP'), 'RET') = 'DER'
         AND p_k_header_rec.order_hdr_id IS NOT NULL) or (p_caller = 'ST')
      THEN
         get_jtf_resource (p_authorg_id         => p_k_header_rec.authoring_org_id,
                           p_party_id           => p_k_header_rec.party_id,
                           x_winners_rec        => l_gen_return_rec,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_return_status      => l_return_status
                          );

         IF (l_return_status <> okc_api.g_ret_sts_success)
         THEN
            -- Setup error
            If p_caller = 'ST' Then
                  send_notification (null, l_chrid, 'SER');
            Else

                  send_notification (p_k_header_rec.order_hdr_id, NULL, 'SER');
            End If;

         ELSE
            l_counter := l_gen_return_rec.trans_object_id.FIRST;
            l_count := 0;

            WHILE (l_counter <= l_gen_return_rec.trans_object_id.LAST)
            LOOP
               IF (l_count = 0)
               THEN
                  OPEN resource_details
                         (p_resource_id      => l_gen_return_rec.resource_id
                                                                    (l_counter)
                         );

                  FETCH resource_details
                   INTO l_user_id;

                  CLOSE resource_details;

                  l_derived_res_id := l_gen_return_rec.resource_id (l_counter);
               END IF;

               l_counter := l_counter + 1;
               l_count := l_count + 1;
            END LOOP;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module_current,
                               'Resource ID is : ' || l_derived_res_id
                              );
            END IF;

            IF l_count = 0
            THEN
               -- No resource setup
               If p_caller = 'ST' Then
                   send_notification (Null, l_chrid, 'NRS');
               Else
                  send_notification (p_k_header_rec.order_hdr_id, NULL, 'NRS');
               End If;
            ELSIF l_count >= 1
            THEN
               l_new_org_id := okc_context.get_okc_org_id;

               OPEN l_salesrep_csr (l_derived_res_id, l_new_org_id);

               FETCH l_salesrep_csr
                INTO l_salesrep_id;

               CLOSE l_salesrep_csr;

               IF l_salesrep_id IS NULL
               THEN
                   If p_caller = 'ST' Then

                           send_notification (NULL, l_chrid,'ISP');
                   Else
                           send_notification (p_k_header_rec.order_hdr_id, NULL,'ISP');
                    End If;
               END IF;
            END IF;
         END IF;
      ELSE
         l_salesrep_id := p_k_header_rec.salesrep_id;
      END IF;

      /************ Territory changes end****************************/
      IF     l_salesrep_id IS NOT NULL
         AND fnd_profile.VALUE ('OKS_VENDOR_CONTACT_ROLE') IS NOT NULL
      THEN
         l_salesgroup_id :=
            jtf_rs_integration_pub.get_default_sales_group
                                     (p_salesrep_id      => l_salesrep_id,
                                      p_org_id           => okc_context.get_okc_org_id,
                                      p_date             => p_k_header_rec.start_date
                                     );
         l_ctcv_tbl_in (1).object1_id1 := l_salesrep_id;
         l_ctcv_tbl_in (1).cpl_id := l_partyid_v;
         l_ctcv_tbl_in (1).dnz_chr_id := l_chrid;
         l_ctcv_tbl_in (1).cro_code :=
                                 fnd_profile.VALUE ('OKS_VENDOR_CONTACT_ROLE');
         l_ctcv_tbl_in (1).object1_id2 := '#';
         l_ctcv_tbl_in (1).sales_group_id := l_salesgroup_id;

         OPEN object_code_csr (l_ctcv_tbl_in (1).cro_code);

         FETCH object_code_csr
          INTO l_temp;

         IF object_code_csr%NOTFOUND
         THEN
            CLOSE object_code_csr;

            okc_api.set_message (g_app_name,
                                 g_unexpected_error,
                                 g_sqlcode_token,
                                 SQLCODE,
                                 g_sqlerrm_token,
                                 'Wrong vendor contact role assigned'
                                );
            l_return_status := okc_api.g_ret_sts_error;
            RAISE g_exception_halt_validation;
         END IF;

         CLOSE object_code_csr;

         l_ctcv_tbl_in (1).jtot_object1_code := 'OKX_SALEPERS';
         --l_object_code;
         okc_contract_party_pub.create_contact
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_ctcv_tbl           => l_ctcv_tbl_in,
                                           x_ctcv_tbl           => l_ctcv_tbl_out
                                          );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                (fnd_log.level_event,
                 g_module_current || '.Create_K_Hdr.External_call.after',
                    ' okc_contract_party_pub.create_contact(Return Status = '
                 || l_return_status
                 || ')'
                );
         END IF;

         IF l_return_status = 'S'
         THEN
            l_contact_id := l_ctcv_tbl_out (1).ID;
         ELSE
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                    l_ctcv_tbl_in (1).cro_code
                                 || 'Vendor  Contact (HEADER) '
                                 || ' OKX_SALEPERS'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      --mmadhavi --Create SalesCredits bug 4174921
      IF p_salescredit_tbl_in.COUNT > 0
      THEN
         j := p_salescredit_tbl_in.FIRST;

         LOOP
            l_scrv_tbl_in (1).PERCENT := p_salescredit_tbl_in (j).PERCENT;
            l_scrv_tbl_in (1).chr_id := l_chrid;
            l_scrv_tbl_in (1).cle_id := NULL;
            l_scrv_tbl_in (1).ctc_id := p_salescredit_tbl_in (j).ctc_id;
            l_scrv_tbl_in (1).sales_credit_type_id1 :=
                                p_salescredit_tbl_in (j).sales_credit_type_id;
            l_scrv_tbl_in (1).sales_credit_type_id2 := '#';
            l_scrv_tbl_in (1).sales_group_id :=
                                      p_salescredit_tbl_in (j).sales_group_id;
            oks_sales_credit_pub.insert_sales_credit
                                         (p_api_version        => 1.0,
                                          p_init_msg_list      => okc_api.g_false,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_scrv_tbl           => l_scrv_tbl_in,
                                          x_scrv_tbl           => l_scrv_tbl_out
                                         );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_event,
                   g_module_current || '.Create_K_Hdr.external_call.after',
                      'oks_sales_credit_pub.insert_sales_credit(Return status = '
                   || l_return_status
                   || ')'
                  );
            END IF;

            IF l_return_status = 'S'
            THEN
               l_salescredit_id := l_scrv_tbl_out (1).ID;
            ELSE
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Sales Credit Failure'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            EXIT WHEN j = p_salescredit_tbl_in.LAST;
            j := p_salescredit_tbl_in.NEXT (j);
         END LOOP;
      END IF;

      --mmadhavi bug 4174921
      IF p_contact_tbl.COUNT > 0
      THEN
         i := p_contact_tbl.FIRST;

         LOOP
            l_ctcv_tbl_in.DELETE;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                                  g_module_current
                               || '.Create_K_Hdr.contact creation',
                                  ' Party Role = '
                               || p_contact_tbl (i).party_role
                               || ',Contact Id = '
                               || p_contact_tbl (i).contact_id
                              );
            END IF;

            IF     p_contact_tbl (i).party_role = 'VENDOR'
               AND l_partyid_v IS NOT NULL
            THEN
               l_add2partyid := l_partyid_v;
               l_hdr_contactid := p_contact_tbl (i).contact_id;
            ELSE
               l_rah_party_id := NULL;
               l_hdr_contactid := NULL;

               OPEN l_ra_hcontacts_cur (p_contact_tbl (i).contact_id);

               FETCH l_ra_hcontacts_cur
                INTO l_rah_party_id, l_hdr_contactid;

               CLOSE l_ra_hcontacts_cur;

               --if l_findparty_id = l_thirdparty_id Then
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current
                                  || '.Create_K_Hdr.contact creation',
                                     ' Third Party = '
                                  || l_thirdparty_id
                                  || ',Customer Id = '
                                  || p_k_header_rec.party_id
                                  || ',Org CTC Id = '
                                  || p_contact_tbl (i).contact_id
                                  || ',Rah PArty Id = '
                                  || l_rah_party_id
                                  || ',Rah CTC Id = '
                                  || l_hdr_contactid
                                 );
               END IF;

               IF l_rah_party_id = l_thirdparty_id AND l_partyid_t IS NOT NULL
               THEN
                  l_add2partyid := l_partyid_t;
               ELSE
                  l_add2partyid := l_partyid;
               END IF;
            END IF;

            IF l_add2partyid IS NULL
            THEN
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                       p_contact_tbl (i).contact_role
                                    || ' Contact (HEADER) Missing Role Id '
                                    || p_contact_tbl (i).contact_object_code
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                                  g_module_current
                               || '.Create_K_Hdr.contact creation',
                                  ' FLAG   = '
                               || p_contact_tbl (i).flag
                               || ' CONTACT ID = '
                               || p_contact_tbl (i).contact_id
                               || ' CPL ID = '
                               || l_add2partyid
                               || ',CRO CD = '
                               || p_contact_tbl (i).contact_role
                               || ',CTC CD = '
                               || l_hdr_contactid
                               || ',JTO CD = '
                               || p_contact_tbl (i).contact_object_code
                              );
            END IF;

            IF p_contact_tbl (i).flag = 'H'
            THEN
               l_ctcv_tbl_in (1).object1_id1 := l_hdr_contactid;
            ELSE
               l_ctcv_tbl_in (1).object1_id1 := p_contact_tbl (i).contact_id;
            END IF;

            l_ctcv_tbl_in (1).cpl_id := l_add2partyid;
            l_ctcv_tbl_in (1).dnz_chr_id := l_chrid;
            l_ctcv_tbl_in (1).cro_code := p_contact_tbl (i).contact_role;
            l_ctcv_tbl_in (1).object1_id2 := '#';
            l_ctcv_tbl_in (1).jtot_object1_code :=
                                         p_contact_tbl (i).contact_object_code;
            okc_contract_party_pub.create_contact
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_ctcv_tbl           => l_ctcv_tbl_in,
                                           x_ctcv_tbl           => l_ctcv_tbl_out
                                          );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_event,
                   g_module_current || '.Create_K_Hdr.external_call.after',
                      'okc_contract_party_pub.create_contact(Return status = '
                   || l_return_status
                   || ')'
                  );
            END IF;

            IF l_return_status = 'S'
            THEN
               l_contact_id := l_ctcv_tbl_out (1).ID;
            ELSE
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                       p_contact_tbl (i).contact_role
                                    || ' Contact (HEADER) '
                                    || p_contact_tbl (i).contact_object_code
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            EXIT WHEN i = p_contact_tbl.LAST;
            i := p_contact_tbl.NEXT (i);
         END LOOP;
      END IF;

      --Grouping Routine
      l_ctrgrp :=
         NVL (p_k_header_rec.chr_group,
              NVL (fnd_profile.VALUE ('OKS_WARR_CONTRACT_GROUP'), 2)
             );
      l_cgcv_tbl_in (1).cgp_parent_id := l_ctrgrp;
      l_cgcv_tbl_in (1).included_chr_id := l_chrid;
      l_cgcv_tbl_in (1).object_version_number := okc_api.g_miss_num;
      l_cgcv_tbl_in (1).created_by := okc_api.g_miss_num;
      l_cgcv_tbl_in (1).creation_date := okc_api.g_miss_date;
      l_cgcv_tbl_in (1).last_updated_by := okc_api.g_miss_num;
      l_cgcv_tbl_in (1).last_update_date := okc_api.g_miss_date;
      l_cgcv_tbl_in (1).last_update_login := okc_api.g_miss_num;
      l_cgcv_tbl_in (1).included_cgp_id := NULL;
      okc_contract_group_pub.create_contract_grpngs
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_cgcv_tbl           => l_cgcv_tbl_in,
                                           x_cgcv_tbl           => l_cgcv_tbl_out
                                          );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_event,
             g_module_current || '.Create_K_Hdr.external_call.after',
                'okc_contract_group_pub.create_contract_grpngs(Return status = '
             || l_return_status
             || ')'
            );
      END IF;

      IF l_return_status = 'S'
      THEN
         l_grpid := l_cgcv_tbl_out (1).ID;
      ELSE
         okc_api.set_message (g_app_name,
                              g_required_value,
                              g_col_name_token,
                              'Contract Group (HEADER)'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      IF p_k_header_rec.pdf_id IS NOT NULL
      THEN
         l_cpsv_tbl_in (1).pdf_id := p_k_header_rec.pdf_id;
         l_cpsv_tbl_in (1).chr_id := l_chrid;
         l_cpsv_tbl_in (1).user_id := fnd_global.user_id;
         l_cpsv_tbl_in (1).in_process_yn := okc_api.g_miss_char;
         l_cpsv_tbl_in (1).object_version_number := okc_api.g_miss_num;
         l_cpsv_tbl_in (1).created_by := okc_api.g_miss_num;
         l_cpsv_tbl_in (1).creation_date := okc_api.g_miss_date;
         l_cpsv_tbl_in (1).last_updated_by := okc_api.g_miss_num;
         l_cpsv_tbl_in (1).last_update_date := okc_api.g_miss_date;
         l_cpsv_tbl_in (1).last_update_login := okc_api.g_miss_num;
         okc_contract_pub.create_contract_process
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => l_init_msg_list,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_cpsv_tbl           => l_cpsv_tbl_in,
                                          x_cpsv_tbl           => l_cpsv_tbl_out
                                         );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_event,
                g_module_current || '.Create_K_Hdr.external_call.after',
                   'okc_contract_pub.create_contract_process(Return status = '
                || l_return_status
                || ')'
               );
         END IF;

         IF l_return_status = 'S'
         THEN
            l_pdfid := l_cpsv_tbl_out (1).ID;
         ELSE
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'Contract WorkFlow (HEADER)'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      --Agreement ID Routine
      IF p_k_header_rec.agreement_id IS NOT NULL
      THEN
         l_gvev_tbl_in (1).chr_id := l_chrid;
         l_gvev_tbl_in (1).isa_agreement_id := p_k_header_rec.agreement_id;
         l_gvev_tbl_in (1).copied_only_yn := 'Y';
         l_gvev_tbl_in (1).dnz_chr_id := l_chrid;
         okc_contract_pub.create_governance
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => l_init_msg_list,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_gvev_tbl           => l_gvev_tbl_in,
                                          x_gvev_tbl           => l_gvev_tbl_out
                                         );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                    (fnd_log.level_event,
                     g_module_current || '.Create_K_Hdr.external_call.after',
                        'okc_contract_pub.create_governance(Return status = '
                     || l_return_status
                     || ')'
                    );
         END IF;

         IF l_return_status = 'S'
         THEN
            l_govern_id := l_gvev_tbl_out (1).ID;
         ELSE
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'Agreement Id (HEADER)'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      create_obj_rel (p_k_id               => l_chrid,
                      p_line_id            => NULL,
                      p_orderhdrid         => p_k_header_rec.order_hdr_id,
                      p_rty_code           => p_k_header_rec.rty_code,
                      p_orderlineid        => NULL,
                      x_return_status      => l_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      x_crjv_tbl_out       => l_crjv_tbl_out
                     );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                            g_module_current
                         || '.Create_K_Hdr.internal_call.after',
                            'create_obj_rel(Return status = '
                         || l_return_status
                         || ')'
                        );
      END IF;

      IF NOT l_return_status = okc_api.g_ret_sts_success
      THEN
         okc_api.set_message (g_app_name,
                              g_required_value,
                              g_col_name_token,
                              'Order Header Id (HEADER)'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      x_chr_id := l_chrid;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END create_k_hdr;

   FUNCTION get_top_line_number (p_chr_id IN NUMBER)
      RETURN NUMBER
   IS
      max_line_number   NUMBER;

      CURSOR get_line_number
      IS
         SELECT NVL (MAX (TO_NUMBER (line_number)), 0) + 1
           FROM okc_k_lines_b
          WHERE dnz_chr_id = p_chr_id AND lse_id IN (1, 12, 14, 19);
   BEGIN
      OPEN get_line_number;

      FETCH get_line_number
       INTO max_line_number;

      CLOSE get_line_number;

      RETURN (max_line_number);
   END get_top_line_number;

   FUNCTION get_sub_line_number (p_chr_id IN NUMBER, p_cle_id IN NUMBER)
      RETURN NUMBER
   IS
      max_line_number   NUMBER;

      CURSOR get_line_number
      IS
         SELECT NVL (MAX (TO_NUMBER (line_number)), 0) + 1
           FROM okc_k_lines_b
          WHERE dnz_chr_id = p_chr_id
            AND cle_id = p_cle_id
            AND lse_id IN (35, 7, 8, 9, 10, 11, 13, 18, 25);
   BEGIN
      OPEN get_line_number;

      FETCH get_line_number
       INTO max_line_number;

      CLOSE get_line_number;

      RETURN (max_line_number);
   END get_sub_line_number;

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
   )
   IS
      l_api_version     CONSTANT NUMBER                               := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)              := okc_api.g_false;
      l_return_status            VARCHAR2 (1)                         := 'S';
      l_index                    VARCHAR2 (2000);
      l_ctcv_tbl_in              okc_contract_party_pub.ctcv_tbl_type;
      l_ctcv_tbl_out             okc_contract_party_pub.ctcv_tbl_type;

      CURSOR l_ctr_csr (p_id NUMBER)
      IS
         SELECT counter_group_id
           FROM okx_ctr_associations_v
          WHERE source_object_id = p_id;

      CURSOR l_billto_csr (p_billto NUMBER)
      IS
         SELECT cust_account_id
           FROM okx_cust_site_uses_v
          WHERE id1 = p_billto AND id2 = '#';

      CURSOR l_ra_hcontacts_cur (p_contact_id NUMBER)
      IS
         SELECT hzr.object_id, hzr.party_id
           --NPALEPU
                --18-JUN-2005,09-AUG-2005
                --TCA Project
                --Replaced hz_party_relationships table with hz_relationships table and ra_hcontacts view with OKS_RA_HCONTACTS_V.
                --Replaced hzr.party_relationship_id column with hzr.relationship_id column and added new conditions
                /* FROM ra_hcontacts rah, hz_party_relationships hzr
                WHERE rah.contact_id = p_contact_id
                AND rah.party_relationship_id = hzr.party_relationship_id; */
         FROM   oks_ra_hcontacts_v rah, hz_relationships hzr
          WHERE rah.contact_id = p_contact_id
            AND rah.party_relationship_id = hzr.relationship_id
            AND hzr.subject_table_name = 'HZ_PARTIES'
            AND hzr.object_table_name = 'HZ_PARTIES'
            AND hzr.directional_flag = 'F';

      --END NPALEPU

      --enhancement to be commented
      CURSOR l_ste_csr (l_line_id NUMBER)
      IS
         SELECT os.ste_code
           FROM okc_statuses_b os, okc_k_lines_b ol
          WHERE ol.ID = l_line_id AND ol.sts_code = os.code;

      CURSOR l_salesgrp_csr (p_id NUMBER, p_start_date DATE, p_end_date DATE)
      IS
         SELECT GROUP_ID
           FROM jtf_rs_srp_groups
          WHERE salesrep_id = p_id
            AND org_id = okc_context.get_okc_org_id
            AND p_start_date BETWEEN start_date AND end_date
            AND p_end_date BETWEEN start_date AND end_date;

      l_sales_group_id           NUMBER;
      l_ctr_grpid                VARCHAR2 (40);
      l_ste_code                 VARCHAR2 (30);
      --Contract Line Table
      l_clev_tbl_in              okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out             okc_contract_pub.clev_tbl_type;
      l_klnv_tbl_in              oks_kln_pvt.klnv_tbl_type;
      l_klnv_tbl_out             oks_kln_pvt.klnv_tbl_type;
      --Contract Item
      l_cimv_tbl_in              okc_contract_item_pub.cimv_tbl_type;
      l_cimv_tbl_out             okc_contract_item_pub.cimv_tbl_type;
      --Time Value Related
      l_isev_ext_tbl_in          okc_time_pub.isev_ext_tbl_type;
      l_isev_ext_tbl_out         okc_time_pub.isev_ext_tbl_type;
      --SalesCredit
      l_scrv_tbl_in              oks_sales_credit_pub.scrv_tbl_type;
      l_scrv_tbl_out             oks_sales_credit_pub.scrv_tbl_type;
      --Coverage
      l_cov_rec                  oks_coverages_pub.ac_rec_type;
      --Counters
      l_ctr_grp_id_template      NUMBER;
      l_ctr_grp_id_instance      NUMBER;
      --Return IDs
      l_line_id                  NUMBER;
      l_rule_group_id            NUMBER;
      l_rule_id                  NUMBER;
      l_line_item_id             NUMBER;
      l_time_value_id            NUMBER;
      l_cov_id                   NUMBER;
      l_salescredit_id           NUMBER;
      --TimeUnits
      l_duration                 NUMBER;
      l_timeunits                VARCHAR2 (240);
      --General
      l_hdrsdt                   DATE;
      l_hdredt                   DATE;
      l_hdrstatus                CHAR;
      l_lsl_id                   NUMBER;
      l_jtot_object              VARCHAR2 (30)                        := NULL;
      i                          NUMBER;
      l_can_object               NUMBER;
      l_line_party_role_id       NUMBER;
      l_lin_party_id             NUMBER;
      l_lin_contactid            NUMBER;
      l_line_contact_id          NUMBER;
      l_role                     VARCHAR2 (40);
      l_obj                      VARCHAR2 (40);
      l_rle_code                 VARCHAR2 (240);
      l_msg_data                 VARCHAR2 (2000);
      l_ind                      NUMBER;
      l_sts_code                 VARCHAR2 (30);
      l_sts_flag                 VARCHAR2 (1);
      p_cle_tbl                  p_srvline_tbl;
      l_ctr                      NUMBER;
      l_inp_rec                  okc_inst_cnd_pub.instcnd_inp_rec;
      l_entity_id                NUMBER;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      IF p_k_line_rec.SOURCE = 'NEW'
      THEN
         get_k_cle_id (p_chrid             => p_k_line_rec.k_id,
                       p_invserviceid      => p_k_line_rec.srv_id,
                       p_cle_tbl           => p_cle_tbl
                      );

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module_current || '.Create_K_Service_Lines',
                            ' Top Lines Count = ' || p_cle_tbl.COUNT
                           );
         END IF;

         IF p_cle_tbl.COUNT > 0
         THEN
            l_ctr := p_cle_tbl.FIRST;

            LOOP
               IF check_merge_yn (p_cle_tbl (l_ctr).k_line_id,
                                  p_k_line_rec.order_line_id,
                                  p_k_line_rec.warranty_flag
                                 )
               THEN
                  l_line_id := p_cle_tbl (l_ctr).k_line_id;
                  EXIT;
               END IF;

               EXIT WHEN l_ctr = p_cle_tbl.LAST;
               l_ctr := p_cle_tbl.NEXT (l_ctr);
            END LOOP;
         ELSE
            l_line_id := NULL;
         END IF;

         -- enhancement to be commented
         OPEN l_ste_csr (l_line_id);

         FETCH l_ste_csr
          INTO l_ste_code;

         CLOSE l_ste_csr;

         IF l_ste_code = 'EXPIRED'
         THEN
            get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);

            UPDATE okc_k_lines_b
               SET sts_code = l_sts_code
             WHERE ID = l_line_id;
         END IF;
      ELSE
         l_line_id := NULL;
      END IF;

      IF l_line_id IS NOT NULL
      THEN
         x_service_line_id := l_line_id;
         l_return_status := okc_api.g_ret_sts_success;
         RAISE g_exception_halt_validation;
      END IF;

      IF p_k_line_rec.warranty_flag = 'W'
      THEN
         l_lsl_id := 14;
         l_jtot_object := g_jtf_warr;
      ELSIF p_k_line_rec.warranty_flag = 'E'
      THEN
         l_lsl_id := 19;
         l_jtot_object := g_jtf_extwarr;
      ELSIF p_k_line_rec.warranty_flag IN ('S', 'SU')
      THEN
         l_lsl_id := 1;
         l_jtot_object := g_jtf_extwarr;
      END IF;

      check_hdr_effectivity (p_chr_id       => p_k_line_rec.k_id,
                             p_srv_sdt      => p_k_line_rec.srv_sdt,
                             p_srv_edt      => p_k_line_rec.srv_edt,
                             x_hdr_sdt      => l_hdrsdt,
                             x_hdr_edt      => l_hdredt,
                             x_status       => l_hdrstatus
                            );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                            g_module_current
                         || '.Create_K_Service_Lines.internal_call.after',
                            'check_hdr_effectivity(Return status = '
                         || l_hdrstatus
                        );
      END IF;

      IF l_hdrstatus = 'E'
      THEN
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              'line dates are not within header effectivity'
                             );

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current
                            || '.Create_K_Service_Lines.ERROR',
                            'Line dates are not withen header effectivity'
                           );
         END IF;

         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            fnd_message.set_name (g_app_name, 'OKS_INVD_CONTRACT_ID');
            fnd_message.set_token (token      => 'HDR_ID',
                                   VALUE      => p_k_line_rec.k_id
                                  );
            x_order_error := '#' || fnd_message.get_encoded || '#';
         END IF;

         --mmadhavi
         l_return_status := okc_api.g_ret_sts_error;
         RAISE g_exception_halt_validation;
      ELSIF l_hdrstatus = 'Y'
      THEN
         IF p_k_line_rec.line_sts_code = 'ENTERED'
         THEN
            l_sts_flag := 'N';
         ELSE
            l_sts_flag := 'Y';
         END IF;

         update_hdr_dates (p_chr_id         => p_k_line_rec.k_id,
                           p_new_sdt        => l_hdrsdt,
                           p_new_edt        => l_hdredt,
                           p_sts_flag       => l_sts_flag,
                           x_status         => l_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data
                          );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                               g_module_current
                            || '.Create_K_Service_Lines.internal_call.after',
                               'update_hdr_dates(Return status = '
                            || l_return_status
                           );
         END IF;

         IF NOT l_return_status = 'S'
         THEN
            l_return_status := okc_api.g_ret_sts_error;
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'Header Effectivity Update (LINE)'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      l_clev_tbl_in (1).chr_id := p_k_line_rec.k_id;
      l_clev_tbl_in (1).sfwt_flag := 'N';
      l_clev_tbl_in (1).lse_id := l_lsl_id;
      --l_clev_tbl_in(1).line_number            := p_k_line_rec.k_line_number;
      l_clev_tbl_in (1).line_number := get_top_line_number (p_k_line_rec.k_id);
      l_clev_tbl_in (1).sts_code := p_k_line_rec.line_sts_code;
      l_clev_tbl_in (1).display_sequence := 1;
      l_clev_tbl_in (1).dnz_chr_id := p_k_line_rec.k_id;
      --l_clev_tbl_in(1).name                   := Substr(p_k_line_rec.srv_segment1,1,50);
      l_clev_tbl_in (1).NAME := NULL;
      l_clev_tbl_in (1).item_description := p_k_line_rec.srv_desc;
      l_clev_tbl_in (1).start_date := p_k_line_rec.srv_sdt;
      l_clev_tbl_in (1).end_date := p_k_line_rec.srv_edt;
      l_clev_tbl_in (1).exception_yn := 'N';
      l_clev_tbl_in (1).currency_code := p_k_line_rec.currency;
      l_clev_tbl_in (1).price_level_ind := priced_yn (l_lsl_id);
      l_clev_tbl_in (1).trn_code := p_k_line_rec.reason_code;
      l_clev_tbl_in (1).upg_orig_system_ref :=
                                              p_k_line_rec.upg_orig_system_ref;
      -- 04-jun-2002 Vigandhi
      l_clev_tbl_in (1).upg_orig_system_ref_id :=
                                           p_k_line_rec.upg_orig_system_ref_id;

      -- 04-jun-2002 Vigandhi
      l_clev_tbl_in (1).comments := p_k_line_rec.reason_comments;
      l_clev_tbl_in (1).attribute1 := p_k_line_rec.attribute1;
      l_clev_tbl_in (1).attribute2 := p_k_line_rec.attribute2;
      l_clev_tbl_in (1).attribute3 := p_k_line_rec.attribute3;
      l_clev_tbl_in (1).attribute4 := p_k_line_rec.attribute4;
      l_clev_tbl_in (1).attribute5 := p_k_line_rec.attribute5;
      l_clev_tbl_in (1).attribute6 := p_k_line_rec.attribute6;
      l_clev_tbl_in (1).attribute7 := p_k_line_rec.attribute7;
      l_clev_tbl_in (1).attribute8 := p_k_line_rec.attribute8;
      l_clev_tbl_in (1).attribute9 := p_k_line_rec.attribute9;
      l_clev_tbl_in (1).attribute10 := p_k_line_rec.attribute10;
      l_clev_tbl_in (1).attribute11 := p_k_line_rec.attribute11;
      l_clev_tbl_in (1).attribute12 := p_k_line_rec.attribute12;
      l_clev_tbl_in (1).attribute13 := p_k_line_rec.attribute13;
      l_clev_tbl_in (1).attribute14 := p_k_line_rec.attribute14;
      l_clev_tbl_in (1).attribute15 := p_k_line_rec.attribute15;
------------------------------------------
-- Rules inserted by okc
------------------------------------------
      l_can_object := NULL;
      IF p_k_line_rec.warranty_flag <> 'W'
      THEN

         OPEN l_billto_csr (p_k_line_rec.bill_to_id);
         FETCH l_billto_csr INTO l_can_object;
         CLOSE l_billto_csr;

          --ramesh added on jan-26-01 for ib html interface
         IF l_can_object IS NULL
         THEN
             l_can_object := p_k_line_rec.cust_account;
         END IF;
      END IF;


      l_clev_tbl_in (1).cust_acct_id := l_can_object;                    --CAN
      l_clev_tbl_in (1).inv_rule_id := p_k_line_rec.invoicing_rule_id;   --IRE
      l_clev_tbl_in (1).line_renewal_type_code :=
                                   NVL (p_k_line_rec.line_renewal_type, 'FUL');
      --LRT
      l_clev_tbl_in (1).bill_to_site_use_id := p_k_line_rec.bill_to_id;  --BTO
      l_clev_tbl_in (1).ship_to_site_use_id := p_k_line_rec.ship_to_id;  --STO
      l_clev_tbl_in (1).price_list_id := p_k_line_rec.ln_price_list_id;
      -- price list
      okc_contract_pub.create_contract_line
                                       (p_api_version            => l_api_version,
                                        p_init_msg_list          => l_init_msg_list,
                                        p_restricted_update      => okc_api.g_true,
                                        x_return_status          => l_return_status,
                                        x_msg_count              => x_msg_count,
                                        x_msg_data               => x_msg_data,
                                        p_clev_tbl               => l_clev_tbl_in,
                                        x_clev_tbl               => l_clev_tbl_out
                                       );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                 (fnd_log.level_event,
                     g_module_current
                  || '.Create_K_Service_Lines.External_call.after',
                     'okc_contract_pub.create_contract_line(Return status = '
                  || l_return_status
                 );
      END IF;

      IF l_return_status = 'S'
      THEN
         l_line_id := l_clev_tbl_out (1).ID;
      ELSE
         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            x_order_error := '#';

            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_encoded            => 'T',
                                p_data               => l_msg_data,
                                p_msg_index_out      => l_ind
                               );
               x_order_error := x_order_error || l_msg_data || '#';

               IF (g_fnd_log_option = 'Y')
               THEN
                  fnd_message.set_encoded (l_msg_data);
                  l_msg_data := fnd_message.get;
                  fnd_file.put_line
                               (fnd_file.LOG,
                                   '(okc_contract_pub).create_contract_line '
                                || l_msg_data
                               );
               END IF;
            END LOOP;

            RAISE g_exception_halt_validation;
         ELSE
            --mmadhavi
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'Line (LINE)'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Service_Lines',
                         'Line Id= ' || l_line_id
                        );
      END IF;
     -------------------------------------
      -- Get and populate the CC Trxn extension id
      -- and populate the oks line structure
      -------------------------------------

      -- Get the transaction extension id for the contract line
      IF p_k_line_rec.order_line_id IS NOT NULL THEN
         get_cc_trxn_extn (
            p_order_header_id  => NULL,
            p_order_line_id    => p_k_line_rec.order_line_id,
            p_context_level    => G_CONTEXT_ORDER_LINE,
            p_contract_hdr_id  => NULL,
            p_contract_line_id => l_line_id,
            x_entity_id        => l_entity_id,
            x_return_status    => l_return_status );

         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            -- Populate the oks header record with the trxn_extension_id
            l_klnv_tbl_in(1).trxn_extension_id := l_entity_id;
            IF l_entity_id IS NOT NULL THEN
               l_klnv_tbl_in (1).payment_type := 'CCR';  -- Credit Card
            END IF;
         ELSE
            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_encoded            => 'T',
                                p_data               => l_msg_data,
                                p_msg_index_out      => l_ind
                               );

               IF (g_fnd_log_option = 'Y') THEN
                  fnd_message.set_encoded (l_msg_data);
                  l_msg_data := fnd_message.get;
                  fnd_file.put_line
                             (fnd_file.LOG,
                                 'get_cc_trxn for line'
                              || l_msg_data
                             );
               END IF;
            END LOOP;
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

-------------------------------------
-- rules inserted by oks --IRT
-------------------------------------
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Service_Lines',
                            'Accounting id = '
                         || p_k_line_rec.accounting_rule_id
                         || ',Commitment id = '
                         || p_k_line_rec.commitment_id
                        );
      END IF;

      l_klnv_tbl_in (1).cle_id := l_line_id;
      l_klnv_tbl_in (1).dnz_chr_id := p_k_line_rec.k_id;
      --mmadhavi removing trucation of invoice_text
      l_klnv_tbl_in (1).invoice_text :=
            p_k_line_rec.srv_desc
         || ':'
         || to_char(p_k_line_rec.srv_sdt,'DD-MON-YYYY')
         || ':'
         || to_char(p_k_line_rec.srv_edt,'DD-MON-YYYY');
      l_klnv_tbl_in (1).created_by := okc_api.g_miss_num;
      l_klnv_tbl_in (1).creation_date := okc_api.g_miss_date;
      l_klnv_tbl_in (1).acct_rule_id := p_k_line_rec.accounting_rule_id; --ARL

      IF p_k_line_rec.commitment_id IS NOT NULL
      THEN
         l_klnv_tbl_in (1).payment_type := 'COM';
         l_klnv_tbl_in (1).commitment_id := p_k_line_rec.commitment_id;
      --PAYMENT METHOD
      END IF;

      l_klnv_tbl_in (1).cust_po_number_req_yn := 'N';    -- po number required
      l_klnv_tbl_in (1).inv_print_flag := 'Y';
                                -- print flag'Changed to Y to fix bug 4188061'
      --Bug Fix 4121175
      l_klnv_tbl_in (1).tax_code := p_k_line_rec.tax_code;
      --End Bug Fix 4121175
      l_klnv_tbl_in (1).coverage_id := p_k_line_rec.coverage_template_id;
      l_klnv_tbl_in (1).standard_cov_yn := p_k_line_rec.standard_cov_yn;
      l_klnv_tbl_in (1).price_uom := p_k_line_rec.price_uom;

      --Added in R12 by rsu
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Service_Lines',
                         'Before calling oks_contract_line_pub.create_line'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Service_Lines',
                            'p_k_line_rec.tax_classification_code: '
                         || p_k_line_rec.tax_classification_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Service_Lines',
                            'p_k_line_rec.exempt_certificate_number: '
                         || p_k_line_rec.exemption_certificate_number
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Service_Lines',
                            'p_k_line_rec.exempt_reason_code: '
                         || p_k_line_rec.exemption_reason_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Service_Lines',
                         'p_k_line_rec.tax_status: '
                         || p_k_line_rec.tax_status
                        );
      END IF;

      l_klnv_tbl_in (1).tax_classification_code :=
                                          p_k_line_rec.tax_classification_code;
      l_klnv_tbl_in (1).exempt_certificate_number :=
                                     p_k_line_rec.exemption_certificate_number;
      l_klnv_tbl_in (1).exempt_reason_code :=
                                            p_k_line_rec.exemption_reason_code;
      l_klnv_tbl_in (1).tax_status := p_k_line_rec.tax_status;
      --End: Added in R12 by rsu

      -- Added for 120 CC EXTN(LINE) project by vjramali
--      l_klnv_tbl_in (1).trxn_extension_id := p_k_line_rec.trxn_extension_id;
      oks_contract_line_pub.create_line (p_api_version        => l_api_version,
                                         p_init_msg_list      => l_init_msg_list,
                                         x_return_status      => l_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         p_klnv_tbl           => l_klnv_tbl_in,
                                         x_klnv_tbl           => l_klnv_tbl_out,
                                         p_validate_yn        => 'N'
                                        );

      IF NOT l_return_status = 'S'
      THEN
         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            x_order_error := '#';

            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_encoded            => 'T',
                                p_data               => l_msg_data,
                                p_msg_index_out      => l_ind
                               );
               x_order_error := x_order_error || l_msg_data || '#';

               IF (g_fnd_log_option = 'Y')
               THEN
                  fnd_message.set_encoded (l_msg_data);
                  l_msg_data := fnd_message.get;
                  fnd_file.put_line
                                   (fnd_file.LOG,
                                       '(oks_contract_line_pub).create_line '
                                    || l_msg_data
                                   );
               END IF;
            END LOOP;

            RAISE g_exception_halt_validation;
         ELSE
            --mmadhavi
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'OKS Contract LINE'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                    (fnd_log.level_event,
                        g_module_current
                     || '.Create_K_Service_Lines.external_call.after',
                        'oks_contract_line_pub.create_line (Return status = '
                     || l_return_status
                     || ')'
                    );
      END IF;

      okc_time_util_pub.get_duration (p_start_date         => p_k_line_rec.srv_sdt,
                                      p_end_date           => p_k_line_rec.srv_edt,
                                      x_duration           => l_duration,
                                      x_timeunit           => l_timeunits,
                                      x_return_status      => l_return_status
                                     );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                            g_module_current
                         || '.Create_K_Service_Lines.external_call.after',
                            'okc_time_util_pub.get_duration(Return status = '
                         || l_return_status
                         || ')'
                        );
      END IF;

      IF NOT l_return_status = 'S'
      THEN
         RAISE g_exception_halt_validation;
      END IF;

      --Create Contract Item
      l_cimv_tbl_in (1).cle_id := l_line_id;
      l_cimv_tbl_in (1).dnz_chr_id := p_k_line_rec.k_id;
      l_cimv_tbl_in (1).object1_id1 := p_k_line_rec.srv_id;
      l_cimv_tbl_in (1).object1_id2 := okc_context.get_okc_organization_id;
      l_cimv_tbl_in (1).jtot_object1_code := l_jtot_object;
      l_cimv_tbl_in (1).exception_yn := 'N';
      l_cimv_tbl_in (1).number_of_items := l_duration;
      l_cimv_tbl_in (1).uom_code := l_timeunits;
      okc_contract_item_pub.create_contract_item
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_cimv_tbl           => l_cimv_tbl_in,
                                           x_cimv_tbl           => l_cimv_tbl_out
                                          );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_event,
             g_module_current || '.Create_K_Service_Lines.external_call.after',
                'okc_contract_item_pub.create_contract_item(Return status = '
             || l_return_status
             || ')'
            );
      END IF;

      IF l_return_status = 'S'
      THEN
         l_line_item_id := l_cimv_tbl_out (1).ID;
      ELSE
         okc_api.set_message (g_app_name,
                              g_required_value,
                              g_col_name_token,
                                 'Service Inventory Item ID '
                              || p_k_line_rec.srv_id
                              || ' ORG '
                              +  okc_context.get_okc_organization_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      --Create SalesCredits
      IF p_salescredit_tbl_in.COUNT > 0
      THEN
         i := p_salescredit_tbl_in.FIRST;

         LOOP
            l_scrv_tbl_in (1).PERCENT := p_salescredit_tbl_in (i).PERCENT;
            l_scrv_tbl_in (1).chr_id := p_k_line_rec.k_id;
            l_scrv_tbl_in (1).cle_id := l_line_id;
            l_scrv_tbl_in (1).ctc_id := p_salescredit_tbl_in (i).ctc_id;
            l_scrv_tbl_in (1).sales_credit_type_id1 :=
                                p_salescredit_tbl_in (i).sales_credit_type_id;
            l_scrv_tbl_in (1).sales_credit_type_id2 := '#';
            l_scrv_tbl_in (1).sales_group_id :=
                                      p_salescredit_tbl_in (i).sales_group_id;
            oks_sales_credit_pub.insert_sales_credit
                                         (p_api_version        => 1.0,
                                          p_init_msg_list      => okc_api.g_false,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_scrv_tbl           => l_scrv_tbl_in,
                                          x_scrv_tbl           => l_scrv_tbl_out
                                         );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_event,
                      g_module_current
                   || '.Create_K_Service_Lines.external_call.after',
                      'oks_sales_credit_pub.insert_sales_credit(Return status = '
                   || l_return_status
                   || ')'
                  );
            END IF;

            IF l_return_status = 'S'
            THEN
               l_salescredit_id := l_scrv_tbl_out (1).ID;
            ELSE
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Sales Credit Failure'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            EXIT WHEN i = p_salescredit_tbl_in.LAST;
            i := p_salescredit_tbl_in.NEXT (i);
         END LOOP;
      END IF;

      --CONTACT CREATION ROUT NOCOPY INE STARTS
      IF p_contact_tbl.COUNT > 0
      THEN
         i := p_contact_tbl.FIRST;

         LOOP
            IF p_contact_tbl (i).flag = 'H'
            THEN
               l_lin_party_id := NULL;
               l_lin_contactid := NULL;

               OPEN l_ra_hcontacts_cur (p_contact_tbl (i).contact_id);

               FETCH l_ra_hcontacts_cur
                INTO l_lin_party_id, l_lin_contactid;

               CLOSE l_ra_hcontacts_cur;

               IF i = p_contact_tbl.FIRST
               THEN
                  IF p_k_line_rec.warranty_flag = 'SU'
                  THEN
                     l_rle_code := 'SUBSCRIBER';
                  ELSE
                     l_rle_code := 'CUSTOMER';
                  END IF;

                  party_role (p_chrid              => p_k_line_rec.k_id,
                              p_cleid              => l_line_id,
                              p_rle_code           => l_rle_code,
                              p_partyid            => l_lin_party_id,
                              p_object_code        => g_jtf_party,
                              x_roleid             => l_line_party_role_id,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              x_return_status      => l_return_status
                             );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                                 (fnd_log.level_event,
                                     g_module_current
                                  || '.Create_K_Service_Lines.contact_creation',
                                     'party_role(Return status = '
                                  || l_return_status
                                  || ')'
                                  || 'CPL id = '
                                  || l_line_party_role_id
                                 );
                  END IF;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;

               IF p_contact_tbl (i).contact_role LIKE '%BILLING%'
               THEN
                  l_role := 'CUST_BILLING';
                  l_obj := 'OKX_CONTBILL';
               ELSIF p_contact_tbl (i).contact_role LIKE '%ADMIN%'
               THEN
                  l_role := 'CUST_ADMIN';
                  l_obj := 'OKX_CONTADMN';
               ELSIF p_contact_tbl (i).contact_role LIKE '%SHIP%'
               THEN
                  l_role := 'CUST_SHIPPING';
                  l_obj := 'OKX_CONTSHIP';
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current
                                  || '.Create_K_Service_Lines.before_contact',
                                     'Line Party Id = '
                                  || l_lin_party_id
                                  || ',ORG CTC Id = '
                                  || p_contact_tbl (i).contact_id
                                  || ',RAH CTC Id = '
                                  || l_lin_contactid
                                  || ',Cont rule = '
                                  || p_contact_tbl (i).contact_role
                                  || ',CON OBJ Rule = '
                                  || p_contact_tbl (i).contact_object_code
                                 );
               END IF;

               l_ctcv_tbl_in (1).cpl_id := l_line_party_role_id;
               l_ctcv_tbl_in (1).dnz_chr_id := p_k_line_rec.k_id;
               l_ctcv_tbl_in (1).cro_code := l_role;
               l_ctcv_tbl_in (1).object1_id1 := p_contact_tbl (i).contact_id;
               l_ctcv_tbl_in (1).object1_id2 := '#';
               l_ctcv_tbl_in (1).jtot_object1_code := l_obj;
               okc_contract_party_pub.create_contact
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_ctcv_tbl           => l_ctcv_tbl_in,
                                           x_ctcv_tbl           => l_ctcv_tbl_out
                                          );

               IF l_return_status = 'S'
               THEN
                  l_line_contact_id := l_ctcv_tbl_out (1).ID;
               ELSE
                  okc_api.set_message (g_app_name,
                                       g_required_value,
                                       g_col_name_token,
                                          p_contact_tbl (i).contact_role
                                       || ' Contact (LINE) '
                                       || p_contact_tbl (i).contact_object_code
                                      );
                  RAISE g_exception_halt_validation;
               END IF;
            END IF;

            EXIT WHEN i = p_contact_tbl.LAST;
            i := p_contact_tbl.NEXT (i);
         END LOOP;
      END IF;

      IF p_k_line_rec.coverage_template_id IS NOT NULL and p_caller <> 'ST'
      THEN
         fnd_msg_pub.initialize;
         oks_coverages_pvt.create_k_coverage_ext
                         (p_api_version        => 1,
                          p_init_msg_list      => 'T',
                          p_src_line_id        => p_k_line_rec.coverage_template_id,
                          p_tgt_line_id        => l_line_id,
                          x_return_status      => l_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data
                         );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_event,
                   g_module_current
                || '.Create_K_Service_Lines.after_coverage_ext',
                   'OKS_COVERAGES_PVT.Create_K_coverage_ext(Return status = '
                || l_return_status
                || ')'
               );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            IF (p_caller = 'OC')
            THEN
               fnd_message.set_name (g_app_name, 'OKS_INVD_COV_TEMP');
               fnd_message.set_token (token      => 'SERV_ID',
                                      VALUE      => p_k_line_rec.srv_id
                                     );
               x_order_error := '#' || fnd_message.get_encoded || '#';
            ELSE
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                       'Invalid Coverage Associated with  '
                                    || p_k_line_rec.srv_id
                                   );
            END IF;

            RAISE g_exception_halt_validation;
         END IF;
      ELSIF p_k_line_rec.coverage_template_id IS NULL AND p_caller <> 'ST'
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current
                            || '.Create_K_Service_Lines.ERROR',
                               'Coverage is not associated with '
                            || p_k_line_rec.srv_id
                           );
         END IF;

         l_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              g_required_value,
                              g_col_name_token,
                                 'Coverage Not Associated with  '
                              || p_k_line_rec.srv_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      l_ctr_grpid := NULL;

      OPEN l_ctr_csr (p_k_line_rec.srv_id);

      FETCH l_ctr_csr
       INTO l_ctr_grpid;

      CLOSE l_ctr_csr;

      IF l_ctr_grpid IS NOT NULL
      THEN
         cs_counters_pub.autoinstantiate_counters
                         (p_api_version                    => 1.0,
                          p_init_msg_list                  => okc_api.g_false,
                          p_commit                         => 'F',
                          x_return_status                  => l_return_status,
                          x_msg_count                      => x_msg_count,
                          x_msg_data                       => x_msg_data,
                          p_source_object_id_template      => p_k_line_rec.srv_id,
                          p_source_object_id_instance      => l_line_id,
                          x_ctr_grp_id_template            => l_ctr_grp_id_template,
                          x_ctr_grp_id_instance            => l_ctr_grp_id_instance
                         );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_event,
                   g_module_current
                || '.Create_K_Service_Lines.after_instantiate_counters',
                   'cs_counters_pub.autoinstantiate_counters(Return Status = '
                || l_return_status
                || ')'
               );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'Counter Instantiate (LINE)'
                                );
            RAISE g_exception_halt_validation;
         END IF;

         -- To instantiate the events
         l_inp_rec.ins_ctr_grp_id := l_ctr_grp_id_instance;
         l_inp_rec.tmp_ctr_grp_id := l_ctr_grp_id_template;
         l_inp_rec.chr_id := p_k_line_rec.k_id;
         l_inp_rec.cle_id := l_line_id;
         l_inp_rec.jtot_object_code := 'OKC_K_LINE';
         l_inp_rec.inv_item_id := p_k_line_rec.srv_id;
         okc_inst_cnd_pub.inst_condition (p_api_version          => 1.0,
                                          p_init_msg_list        => 'T',
                                          x_return_status        => x_return_status,
                                          x_msg_count            => x_msg_count,
                                          x_msg_data             => x_msg_data,
                                          p_instcnd_inp_rec      => l_inp_rec
                                         );
      END IF;

      x_service_line_id := l_line_id;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END create_k_service_lines;

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
   )
   IS
      l_api_version     CONSTANT NUMBER                                := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)              := okc_api.g_false;
      l_return_status            VARCHAR2 (1)                          := 'S';
      l_index                    VARCHAR2 (2000);
      --Contract Line Table
      l_clev_tbl_in              okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out             okc_contract_pub.clev_tbl_type;
      l_klnv_tbl_in              oks_kln_pvt.klnv_tbl_type;
      l_klnv_tbl_out             oks_kln_pvt.klnv_tbl_type;
      --Contract Item
      l_cimv_tbl                 okc_contract_item_pub.cimv_tbl_type;
      l_cimv_tbl_out             okc_contract_item_pub.cimv_tbl_type;
      --Pricing Attributes
      l_pavv_tbl_in              okc_price_adjustment_pvt.pavv_tbl_type;
      l_pavv_tbl_out             okc_price_adjustment_pvt.pavv_tbl_type;
      --Rule Related
      --l_rgpv_tbl_in                 okc_rule_pub.rgpv_tbl_type;
      --l_rgpv_tbl_out                okc_rule_pub.rgpv_tbl_type;
      --l_rulv_tbl_in                 okc_rule_pub.rulv_tbl_type;
      --l_rulv_tbl_out                okc_rule_pub.rulv_tbl_type;
      --Return IDs
      l_line_id                  NUMBER;
      l_rule_group_id            NUMBER;
      l_rule_id                  NUMBER;
      l_line_item_id             NUMBER;
      l_lsl_id                   NUMBER;
      l_hdrsdt                   DATE;
      l_hdredt                   DATE;
      l_line_sdt                 DATE;
      l_line_edt                 DATE;
      l_hdrstatus                VARCHAR2 (3);
      l_line_status              VARCHAR2 (3);
      l_priceattrib_id           NUMBER;
      l_invoice_text             VARCHAR2 (2000);
      --Obj Rel
      l_crjv_tbl_out             okc_k_rel_objs_pub.crjv_tbl_type;
      l_msg_data                 VARCHAR2 (2000);
      l_ind                      NUMBER;
      l_ste_code                 VARCHAR2 (240);
      l_sts_code                 VARCHAR2 (240);
      g_rail_rec                 oks_tax_util_pvt.ra_rec_type;

      CURSOR l_line_csr (p_line_id NUMBER)
      IS
         SELECT kl.start_date, kl.end_date, kl.inv_rule_id
           FROM okc_k_lines_b kl
          WHERE kl.ID = p_line_id;

      l_duration                 NUMBER;
      l_timeunits                VARCHAR2 (25);
      l_sll_tbl                  oks_bill_sch.streamlvl_tbl;
      l_bil_sch_out              oks_bill_sch.itembillsch_tbl;
      l_strmlvl_id               NUMBER                               := NULL;
      l_update_top_line          VARCHAR2 (1);
      l_start_date               DATE;
      l_end_date                 DATE;
      l_invoice_rule_id          VARCHAR2 (10);
      l_sts_flag                 VARCHAR2 (1);
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;
      x_update_line := 'N';
      check_line_effectivity (p_cle_id        => p_k_covd_rec.attach_2_line_id,
                              p_srv_sdt       => p_k_covd_rec.product_start_date,
                              p_srv_edt       => p_k_covd_rec.product_end_date,
                              x_line_sdt      => l_line_sdt,
                              x_line_edt      => l_line_edt,
                              x_status        => l_line_status
                             );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.Create_K_Covered_Levels',
                         'Check line effectivity status = ' || l_line_status
                        );
      END IF;

      IF l_line_status = 'E'
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING
                       (fnd_log.level_error,
                        g_module_current || '.Create_K_Covered_Levels.ERROR',
                        'Covered level Dates are not within Line effectivity'
                       );
         END IF;

         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              'Covlvl Dates not within Line effectivity'
                             );
         l_return_status := okc_api.g_ret_sts_error;
         RAISE g_exception_halt_validation;
      ELSIF l_line_status = 'Y'
      THEN
         check_hdr_effectivity (p_chr_id       => p_k_covd_rec.k_id,
                                p_srv_sdt      => l_line_sdt,
                                p_srv_edt      => l_line_edt,
                                x_hdr_sdt      => l_hdrsdt,
                                x_hdr_edt      => l_hdredt,
                                x_status       => l_hdrstatus
                               );

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module_current || '.Create_K_Covered_Levels',
                            'Check Header effectivity status = '
                            || l_hdrstatus
                           );
         END IF;

         IF l_hdrstatus = 'E'
         THEN
            IF fnd_log.level_error >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_error,
                               g_module_current || '.Create_K_Covered_Levels',
                               'Line Dates are not within Header effectivity'
                              );
            END IF;

            okc_api.set_message (g_app_name,
                                 g_unexpected_error,
                                 g_sqlcode_token,
                                 SQLCODE,
                                 g_sqlerrm_token,
                                 'line Dates not within Hdr effectivity'
                                );
            l_return_status := okc_api.g_ret_sts_error;
            RAISE g_exception_halt_validation;
         ELSIF l_hdrstatus = 'Y'
         THEN
            get_sts_code (NULL,
                          p_k_covd_rec.product_sts_code,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code = 'ENTERED'
            THEN
               l_sts_flag := 'N';
            ELSE
               l_sts_flag := 'Y';
            END IF;

            update_hdr_dates (p_chr_id         => p_k_covd_rec.k_id,
                              p_new_sdt        => l_hdrsdt,
                              p_new_edt        => l_hdredt,
                              p_sts_flag       => l_sts_flag,
                              x_status         => l_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data
                             );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                             (fnd_log.level_event,
                                 g_module_current
                              || '.Create_K_Covered_Levels.afterupdatehdrdtaes',
                                 'update_hdr_dates(Return status = '
                              || l_return_status
                              || ')'
                             );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               l_return_status := okc_api.g_ret_sts_error;
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Header Effectivity Update (SUB LINE)'
                                   );
               RAISE g_exception_halt_validation;
            END IF;
         END IF;

         IF p_k_covd_rec.product_sts_code = 'ENTERED'
         THEN
            l_sts_flag := 'N';
         ELSE
            l_sts_flag := 'Y';
         END IF;

         update_line_dates (p_cle_id             => p_k_covd_rec.attach_2_line_id,
                            p_chr_id             => p_k_covd_rec.k_id,
                            p_new_sdt            => l_line_sdt,
                            p_new_edt            => l_line_edt,
                            p_sts_flag           => l_sts_flag,
                            p_warranty_flag      => p_k_covd_rec.warranty_flag,
                            x_status             => l_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data
                           );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_event,
                             g_module_current
                          || '.Create_K_Covered_Levels.after_update.line_dtaes',
                             'update_hdr_dates(Return status = '
                          || l_return_status
                          || ')'
                         );
         END IF;

         IF NOT l_return_status = 'S'
         THEN
            l_return_status := okc_api.g_ret_sts_error;
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'LINE Effectivity Update (SUB LINE)'
                                );
            RAISE g_exception_halt_validation;
         ELSE
            x_update_line := 'Y';
         END IF;

         oks_pm_programs_pvt.adjust_pm_program_schedule
                         (p_api_version           => 1.0,
                          p_init_msg_list         => 'F',
                          p_contract_line_id      => p_k_covd_rec.attach_2_line_id,
                          p_new_start_date        => l_line_sdt,
                          p_new_end_date          => l_line_edt,
                          x_return_status         => l_return_status,
                          x_msg_count             => x_msg_count,
                          x_msg_data              => x_msg_data
                         );

         IF NOT l_return_status = 'S'
         THEN
            l_return_status := okc_api.g_ret_sts_error;
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'Adjust PM Program Schedule(SUB LINE)'
                                );
            RAISE g_exception_halt_validation;
         END IF;

         IF p_k_covd_rec.standard_coverage = 'N'
         THEN
            oks_coverages_pub.update_cov_eff
                         (p_api_version          => 1.0,
                          p_init_msg_list        => 'F',
                          x_return_status        => l_return_status,
                          x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                          p_service_line_id      => p_k_covd_rec.attach_2_line_id,
                          p_new_start_date       => l_line_sdt,
                          p_new_end_date         => l_line_edt
                         );

            IF NOT l_return_status = 'S'
            THEN
               l_return_status := okc_api.g_ret_sts_error;
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Coverage Effectivity Update (SUB LINE)'
                                   );
               RAISE g_exception_halt_validation;
            END IF;
         END IF;
      END IF;

      IF p_k_covd_rec.warranty_flag = 'W'
      THEN
         l_lsl_id := 18;
      ELSIF p_k_covd_rec.warranty_flag = 'E'
      THEN
         l_lsl_id := 25;
      ELSIF p_k_covd_rec.warranty_flag IN ('S', 'SU')
      THEN
         l_lsl_id := 9;
      END IF;

      l_clev_tbl_in (1).chr_id := NULL;
      l_clev_tbl_in (1).sfwt_flag := 'N';
      l_clev_tbl_in (1).lse_id := l_lsl_id;
      --l_clev_tbl_in(1).line_number            := p_k_covd_rec.line_number;
      l_clev_tbl_in (1).line_number :=
         get_sub_line_number (p_k_covd_rec.k_id,
                              p_k_covd_rec.attach_2_line_id);
      l_clev_tbl_in (1).sts_code := p_k_covd_rec.product_sts_code;
      l_clev_tbl_in (1).display_sequence := 2;
      l_clev_tbl_in (1).dnz_chr_id := p_k_covd_rec.k_id;
      --l_clev_tbl_in(1).name                   := Substr(p_k_covd_rec.Product_segment1,1,50);
      l_clev_tbl_in (1).NAME := NULL;
      l_clev_tbl_in (1).item_description := p_k_covd_rec.product_desc;
      l_clev_tbl_in (1).start_date := p_k_covd_rec.product_start_date;
      l_clev_tbl_in (1).end_date := p_k_covd_rec.product_end_date;
      l_clev_tbl_in (1).exception_yn := 'N';
      l_clev_tbl_in (1).price_negotiated := Nvl(p_k_covd_rec.negotiated_amount,0);
      l_clev_tbl_in (1).currency_code := p_k_covd_rec.currency_code;
      l_clev_tbl_in (1).price_unit := Nvl(p_k_covd_rec.list_price,0);
      l_clev_tbl_in (1).cle_id := p_k_covd_rec.attach_2_line_id;
      l_clev_tbl_in (1).price_level_ind := priced_yn (l_lsl_id);
      l_clev_tbl_in (1).trn_code := p_k_covd_rec.reason_code;
      l_clev_tbl_in (1).comments := p_k_covd_rec.reason_comments;
      --l_clev_tbl_in(1).translated_text        := p_k_covd_rec.translated_text;
      l_clev_tbl_in (1).upg_orig_system_ref :=
                                              p_k_covd_rec.upg_orig_system_ref;
      -- 04-jun-2002 Vigandhi
      l_clev_tbl_in (1).upg_orig_system_ref_id :=
                                           p_k_covd_rec.upg_orig_system_ref_id;
      -- 04-jun-2002 Vigandhi
      l_clev_tbl_in (1).attribute1 := p_k_covd_rec.attribute1;
      l_clev_tbl_in (1).attribute2 := p_k_covd_rec.attribute2;
      l_clev_tbl_in (1).attribute3 := p_k_covd_rec.attribute3;
      l_clev_tbl_in (1).attribute4 := p_k_covd_rec.attribute4;
      l_clev_tbl_in (1).attribute5 := p_k_covd_rec.attribute5;
      l_clev_tbl_in (1).attribute6 := p_k_covd_rec.attribute6;
      l_clev_tbl_in (1).attribute7 := p_k_covd_rec.attribute7;
      l_clev_tbl_in (1).attribute8 := p_k_covd_rec.attribute8;
      l_clev_tbl_in (1).attribute9 := p_k_covd_rec.attribute9;
      l_clev_tbl_in (1).attribute10 := p_k_covd_rec.attribute10;
      l_clev_tbl_in (1).attribute11 := p_k_covd_rec.attribute11;
      l_clev_tbl_in (1).attribute12 := p_k_covd_rec.attribute12;
      l_clev_tbl_in (1).attribute13 := p_k_covd_rec.attribute13;
      l_clev_tbl_in (1).attribute14 := p_k_covd_rec.attribute14;
      l_clev_tbl_in (1).attribute15 := p_k_covd_rec.attribute15;
      --  rules inserted by okc
      l_clev_tbl_in (1).line_renewal_type_code :=
                                   NVL (p_k_covd_rec.line_renewal_type, 'FUL');
      --LRT
      okc_contract_pub.create_contract_line
                                       (p_api_version            => l_api_version,
                                        p_init_msg_list          => l_init_msg_list,
                                        p_restricted_update      => okc_api.g_true,
                                        x_return_status          => l_return_status,
                                        x_msg_count              => x_msg_count,
                                        x_msg_data               => x_msg_data,
                                        p_clev_tbl               => l_clev_tbl_in,
                                        x_clev_tbl               => l_clev_tbl_out
                                       );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                 (fnd_log.level_event,
                     g_module_current
                  || '.Create_K_Covered_Levels.after_create.top_line',
                     'okc_contract_pub.create_contract_line(Return status = '
                  || l_return_status
                  || ')'
                 );
      END IF;

      IF l_return_status = 'S'
      THEN
         l_line_id := l_clev_tbl_out (1).ID;
      ELSE
         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            x_order_error := '#';

            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_encoded            => 'T',
                                p_data               => l_msg_data,
                                p_msg_index_out      => l_ind
                               );
               x_order_error := x_order_error || l_msg_data || '#';

               IF (g_fnd_log_option = 'Y')
               THEN
                  fnd_message.set_encoded (l_msg_data);
                  l_msg_data := fnd_message.get;
                  fnd_file.put_line
                               (fnd_file.LOG,
                                   '(OKC_CONTRACT_PUB).CREATE_CONTRACT_LINE '
                                || l_msg_data
                               );
               END IF;
            END LOOP;

            RAISE g_exception_halt_validation;
         ELSE
            --mmadhavi
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'K LINE (SUB LINE)'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      x_covlvl_id := l_line_id;
      -- cov rules inserted by oks
      l_klnv_tbl_in (1).tax_amount := nvl(p_k_covd_rec.tax_amount,0);

      -- Added tax calculation for the new contract created after transfer
      -- 30-jan-2004 Vigandhi
      IF p_caller = 'ST' AND p_k_covd_rec.warranty_flag <> 'W'
      THEN
         oks_tax_util_pvt.get_tax (p_api_version        => 1.0,
                                   p_init_msg_list      => okc_api.g_true,
                                   p_chr_id             => p_k_covd_rec.k_id,
                                   p_cle_id             => l_line_id,
                                   px_rail_rec          => g_rail_rec,
                                   x_msg_count          => x_msg_count,
                                   x_msg_data           => x_msg_data,
                                   x_return_status      => l_return_status
                                  );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                               g_module_current
                            || '.Create_K_Covered_Levels.after_tax',
                               'oks_tax_util_pvt.get_tax(Return status = '
                            || l_return_status
                            || ')'
                           );
         END IF;

         -- Fixed Bug 5035571
         /*
	 IF (l_return_status <> okc_api.g_ret_sts_success)
         THEN
            RAISE g_exception_halt_validation;
         END IF;
	 */

         l_klnv_tbl_in (1).tax_inclusive_yn := g_rail_rec.amount_includes_tax_flag;

         IF g_rail_rec.amount_includes_tax_flag = 'Y'
         THEN
            l_klnv_tbl_in (1).tax_amount := 0;
         ELSE
            l_klnv_tbl_in (1).tax_amount := g_rail_rec.tax_value;
         END IF;
      END IF;

      l_invoice_text :=
         getformattedinvoicetext (p_k_covd_rec.prod_item_id,
                                  p_k_covd_rec.product_start_date,
                                  p_k_covd_rec.product_end_date,
                                  p_k_covd_rec.attach_2_line_desc,
                                  p_k_covd_rec.quantity
                                 );
      l_klnv_tbl_in (1).cle_id := l_line_id;  --p_k_covd_rec.attach_2_line_id;
      l_klnv_tbl_in (1).dnz_chr_id := p_k_covd_rec.k_id;
      l_klnv_tbl_in (1).invoice_text := l_invoice_text;                  --IRT
      l_klnv_tbl_in (1).created_by := okc_api.g_miss_num;
      l_klnv_tbl_in (1).creation_date := okc_api.g_miss_date;
      l_klnv_tbl_in (1).status_text := 'Subline created from OM/IB';
      l_klnv_tbl_in (1).price_uom := p_k_covd_rec.price_uom;
      l_klnv_tbl_in (1).toplvl_uom_code := p_k_covd_rec.toplvl_uom_code;
      l_klnv_tbl_in (1).inv_print_flag := 'Y';  --Bug# 5655521

      --mchoudha added for bug#5233956
      l_klnv_tbl_in (1).toplvl_price_qty := p_k_covd_rec.toplvl_price_qty;
      oks_contract_line_pub.create_line (p_api_version        => l_api_version,
                                         p_init_msg_list      => l_init_msg_list,
                                         x_return_status      => l_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         p_klnv_tbl           => l_klnv_tbl_in,
                                         x_klnv_tbl           => l_klnv_tbl_out,
                                         p_validate_yn        => 'N'
                                        );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                     (fnd_log.level_event,
                         g_module_current
                      || '.Create_K_Covered_Levels.after_create.covered_line',
                         'oks_contract_line_pub.create_line(Return status = '
                      || l_return_status
                      || ')'
                     );
      END IF;

      IF NOT l_return_status = 'S'
      THEN
         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            x_order_error := '#';

            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_encoded            => 'T',
                                p_data               => l_msg_data,
                                p_msg_index_out      => l_ind
                               );
               x_order_error := x_order_error || l_msg_data || '#';

               IF (g_fnd_log_option = 'Y')
               THEN
                  fnd_message.set_encoded (l_msg_data);
                  l_msg_data := fnd_message.get;
                  fnd_file.put_line
                                   (fnd_file.LOG,
                                       '(OKS_CONTRACT_LINE_PUB).CREATE_LINE '
                                    || l_msg_data
                                   );
               END IF;
            END LOOP;

            RAISE g_exception_halt_validation;
         ELSE
            --mmadhavi
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'OKS Contract COV LINE'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      --Create Contract Item
      l_cimv_tbl (1).ID := okc_p_util.raw_to_number (SYS_GUID ());
      l_cimv_tbl (1).cle_id := l_line_id;
      l_cimv_tbl (1).chr_id := NULL;
      l_cimv_tbl (1).cle_id_for := NULL;
      l_cimv_tbl (1).dnz_chr_id := p_k_covd_rec.k_id;
      l_cimv_tbl (1).object1_id1 := p_k_covd_rec.customer_product_id;
      l_cimv_tbl (1).object1_id2 := '#';
      l_cimv_tbl (1).jtot_object1_code := 'OKX_CUSTPROD';
      l_cimv_tbl (1).uom_code := p_k_covd_rec.uom_code;
      l_cimv_tbl (1).exception_yn := 'N';
      l_cimv_tbl (1).number_of_items := p_k_covd_rec.quantity;
      l_cimv_tbl (1).priced_item_yn := '';
      l_cimv_tbl (1).upg_orig_system_ref := '';
      l_cimv_tbl (1).upg_orig_system_ref_id := NULL;
      l_cimv_tbl (1).object_version_number := 1;
      l_cimv_tbl (1).created_by := fnd_global.user_id;
      l_cimv_tbl (1).creation_date := SYSDATE;
      l_cimv_tbl (1).last_updated_by := fnd_global.user_id;
      l_cimv_tbl (1).last_update_date := SYSDATE;
      l_cimv_tbl (1).last_update_login := NULL;
      l_cimv_tbl (1).request_id := NULL;
      l_cimv_tbl (1).program_id := NULL;
      l_cimv_tbl (1).program_application_id := NULL;
      l_cimv_tbl (1).program_update_date := NULL;
      okc_cim_pvt.insert_row_upg (x_return_status      => l_return_status,
                                  p_cimv_tbl           => l_cimv_tbl
                                 );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_event,
                          g_module_current
                       || '.Create_K_Covered_Levels.after_create.contract_item',
                          'okc_cim_pvt.insert_row_upg(Return status = '
                       || l_return_status
                       || ')'
                      );
      END IF;

      IF l_return_status = 'S'
      THEN
         l_line_item_id := l_cimv_tbl (1).ID;
      ELSE
         okc_api.set_message (g_app_name,
                              g_required_value,
                              g_col_name_token,
                              'KItem (SUB LINE)'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      --Create Obj Rel
      IF p_k_covd_rec.warranty_flag IN ('E', 'S', 'SU')
      THEN
         create_obj_rel (p_k_id               => p_k_covd_rec.k_id,
                         p_line_id            => l_line_id,
                         p_orderhdrid         => NULL,
                         p_rty_code           => p_k_covd_rec.rty_code,
                         p_orderlineid        => p_k_covd_rec.order_line_id,
                         x_return_status      => l_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         x_crjv_tbl_out       => l_crjv_tbl_out
                        );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                          (fnd_log.level_event,
                              g_module_current
                           || '.Create_K_Covered_Levels.create.object_relation',
                              'create_obj_rel(Return status = '
                           || l_return_status
                           || ')'
                          );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'Order Line Id (SUB LINE)'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      --Create Pricing Attributes
      IF p_price_attribs.pricing_context IS NOT NULL
      THEN
         l_pavv_tbl_in (1).cle_id := l_line_id;
         l_pavv_tbl_in (1).flex_title := 'QP_ATTR_DEFNS_PRICING';
         l_pavv_tbl_in (1).pricing_context := p_price_attribs.pricing_context;
         l_pavv_tbl_in (1).pricing_attribute1 :=
                                           p_price_attribs.pricing_attribute1;
         l_pavv_tbl_in (1).pricing_attribute2 :=
                                           p_price_attribs.pricing_attribute2;
         l_pavv_tbl_in (1).pricing_attribute3 :=
                                           p_price_attribs.pricing_attribute3;
         l_pavv_tbl_in (1).pricing_attribute4 :=
                                           p_price_attribs.pricing_attribute4;
         l_pavv_tbl_in (1).pricing_attribute5 :=
                                           p_price_attribs.pricing_attribute5;
         l_pavv_tbl_in (1).pricing_attribute6 :=
                                           p_price_attribs.pricing_attribute6;
         l_pavv_tbl_in (1).pricing_attribute7 :=
                                           p_price_attribs.pricing_attribute7;
         l_pavv_tbl_in (1).pricing_attribute8 :=
                                           p_price_attribs.pricing_attribute8;
         l_pavv_tbl_in (1).pricing_attribute9 :=
                                           p_price_attribs.pricing_attribute9;
         l_pavv_tbl_in (1).pricing_attribute10 :=
                                          p_price_attribs.pricing_attribute10;
         l_pavv_tbl_in (1).pricing_attribute11 :=
                                          p_price_attribs.pricing_attribute11;
         l_pavv_tbl_in (1).pricing_attribute12 :=
                                          p_price_attribs.pricing_attribute12;
         l_pavv_tbl_in (1).pricing_attribute13 :=
                                          p_price_attribs.pricing_attribute13;
         l_pavv_tbl_in (1).pricing_attribute14 :=
                                          p_price_attribs.pricing_attribute14;
         l_pavv_tbl_in (1).pricing_attribute15 :=
                                          p_price_attribs.pricing_attribute15;
         l_pavv_tbl_in (1).pricing_attribute16 :=
                                          p_price_attribs.pricing_attribute16;
         l_pavv_tbl_in (1).pricing_attribute17 :=
                                          p_price_attribs.pricing_attribute17;
         l_pavv_tbl_in (1).pricing_attribute18 :=
                                          p_price_attribs.pricing_attribute18;
         l_pavv_tbl_in (1).pricing_attribute19 :=
                                          p_price_attribs.pricing_attribute19;
         l_pavv_tbl_in (1).pricing_attribute20 :=
                                          p_price_attribs.pricing_attribute20;
         l_pavv_tbl_in (1).pricing_attribute21 :=
                                          p_price_attribs.pricing_attribute21;
         l_pavv_tbl_in (1).pricing_attribute22 :=
                                          p_price_attribs.pricing_attribute22;
         l_pavv_tbl_in (1).pricing_attribute23 :=
                                          p_price_attribs.pricing_attribute23;
         l_pavv_tbl_in (1).pricing_attribute24 :=
                                          p_price_attribs.pricing_attribute24;
         l_pavv_tbl_in (1).pricing_attribute25 :=
                                          p_price_attribs.pricing_attribute25;
         l_pavv_tbl_in (1).pricing_attribute26 :=
                                          p_price_attribs.pricing_attribute26;
         l_pavv_tbl_in (1).pricing_attribute27 :=
                                          p_price_attribs.pricing_attribute27;
         l_pavv_tbl_in (1).pricing_attribute28 :=
                                          p_price_attribs.pricing_attribute28;
         l_pavv_tbl_in (1).pricing_attribute29 :=
                                          p_price_attribs.pricing_attribute29;
         l_pavv_tbl_in (1).pricing_attribute30 :=
                                          p_price_attribs.pricing_attribute30;
         l_pavv_tbl_in (1).pricing_attribute31 :=
                                          p_price_attribs.pricing_attribute31;
         l_pavv_tbl_in (1).pricing_attribute32 :=
                                          p_price_attribs.pricing_attribute32;
         l_pavv_tbl_in (1).pricing_attribute33 :=
                                          p_price_attribs.pricing_attribute33;
         l_pavv_tbl_in (1).pricing_attribute34 :=
                                          p_price_attribs.pricing_attribute34;
         l_pavv_tbl_in (1).pricing_attribute35 :=
                                          p_price_attribs.pricing_attribute35;
         l_pavv_tbl_in (1).pricing_attribute36 :=
                                          p_price_attribs.pricing_attribute36;
         l_pavv_tbl_in (1).pricing_attribute37 :=
                                          p_price_attribs.pricing_attribute37;
         l_pavv_tbl_in (1).pricing_attribute38 :=
                                          p_price_attribs.pricing_attribute38;
         l_pavv_tbl_in (1).pricing_attribute39 :=
                                          p_price_attribs.pricing_attribute39;
         l_pavv_tbl_in (1).pricing_attribute40 :=
                                          p_price_attribs.pricing_attribute40;
         l_pavv_tbl_in (1).pricing_attribute41 :=
                                          p_price_attribs.pricing_attribute41;
         l_pavv_tbl_in (1).pricing_attribute42 :=
                                          p_price_attribs.pricing_attribute42;
         l_pavv_tbl_in (1).pricing_attribute43 :=
                                          p_price_attribs.pricing_attribute43;
         l_pavv_tbl_in (1).pricing_attribute44 :=
                                          p_price_attribs.pricing_attribute44;
         l_pavv_tbl_in (1).pricing_attribute45 :=
                                          p_price_attribs.pricing_attribute45;
         l_pavv_tbl_in (1).pricing_attribute46 :=
                                          p_price_attribs.pricing_attribute46;
         l_pavv_tbl_in (1).pricing_attribute47 :=
                                          p_price_attribs.pricing_attribute47;
         l_pavv_tbl_in (1).pricing_attribute48 :=
                                          p_price_attribs.pricing_attribute48;
         l_pavv_tbl_in (1).pricing_attribute49 :=
                                          p_price_attribs.pricing_attribute49;
         l_pavv_tbl_in (1).pricing_attribute50 :=
                                          p_price_attribs.pricing_attribute50;
         l_pavv_tbl_in (1).pricing_attribute51 :=
                                          p_price_attribs.pricing_attribute51;
         l_pavv_tbl_in (1).pricing_attribute52 :=
                                          p_price_attribs.pricing_attribute52;
         l_pavv_tbl_in (1).pricing_attribute53 :=
                                          p_price_attribs.pricing_attribute53;
         l_pavv_tbl_in (1).pricing_attribute54 :=
                                          p_price_attribs.pricing_attribute54;
         l_pavv_tbl_in (1).pricing_attribute55 :=
                                          p_price_attribs.pricing_attribute55;
         l_pavv_tbl_in (1).pricing_attribute56 :=
                                          p_price_attribs.pricing_attribute56;
         l_pavv_tbl_in (1).pricing_attribute57 :=
                                          p_price_attribs.pricing_attribute57;
         l_pavv_tbl_in (1).pricing_attribute58 :=
                                          p_price_attribs.pricing_attribute58;
         l_pavv_tbl_in (1).pricing_attribute59 :=
                                          p_price_attribs.pricing_attribute59;
         l_pavv_tbl_in (1).pricing_attribute60 :=
                                          p_price_attribs.pricing_attribute60;
         l_pavv_tbl_in (1).pricing_attribute61 :=
                                          p_price_attribs.pricing_attribute61;
         l_pavv_tbl_in (1).pricing_attribute62 :=
                                          p_price_attribs.pricing_attribute62;
         l_pavv_tbl_in (1).pricing_attribute63 :=
                                          p_price_attribs.pricing_attribute63;
         l_pavv_tbl_in (1).pricing_attribute64 :=
                                          p_price_attribs.pricing_attribute64;
         l_pavv_tbl_in (1).pricing_attribute65 :=
                                          p_price_attribs.pricing_attribute65;
         l_pavv_tbl_in (1).pricing_attribute66 :=
                                          p_price_attribs.pricing_attribute66;
         l_pavv_tbl_in (1).pricing_attribute67 :=
                                          p_price_attribs.pricing_attribute67;
         l_pavv_tbl_in (1).pricing_attribute68 :=
                                          p_price_attribs.pricing_attribute68;
         l_pavv_tbl_in (1).pricing_attribute69 :=
                                          p_price_attribs.pricing_attribute69;
         l_pavv_tbl_in (1).pricing_attribute70 :=
                                          p_price_attribs.pricing_attribute70;
         l_pavv_tbl_in (1).pricing_attribute71 :=
                                          p_price_attribs.pricing_attribute71;
         l_pavv_tbl_in (1).pricing_attribute72 :=
                                          p_price_attribs.pricing_attribute72;
         l_pavv_tbl_in (1).pricing_attribute73 :=
                                          p_price_attribs.pricing_attribute73;
         l_pavv_tbl_in (1).pricing_attribute74 :=
                                          p_price_attribs.pricing_attribute74;
         l_pavv_tbl_in (1).pricing_attribute75 :=
                                          p_price_attribs.pricing_attribute75;
         l_pavv_tbl_in (1).pricing_attribute76 :=
                                          p_price_attribs.pricing_attribute76;
         l_pavv_tbl_in (1).pricing_attribute77 :=
                                          p_price_attribs.pricing_attribute77;
         l_pavv_tbl_in (1).pricing_attribute78 :=
                                          p_price_attribs.pricing_attribute78;
         l_pavv_tbl_in (1).pricing_attribute79 :=
                                          p_price_attribs.pricing_attribute79;
         l_pavv_tbl_in (1).pricing_attribute80 :=
                                          p_price_attribs.pricing_attribute80;
         l_pavv_tbl_in (1).pricing_attribute81 :=
                                          p_price_attribs.pricing_attribute81;
         l_pavv_tbl_in (1).pricing_attribute82 :=
                                          p_price_attribs.pricing_attribute82;
         l_pavv_tbl_in (1).pricing_attribute83 :=
                                          p_price_attribs.pricing_attribute83;
         l_pavv_tbl_in (1).pricing_attribute84 :=
                                          p_price_attribs.pricing_attribute84;
         l_pavv_tbl_in (1).pricing_attribute85 :=
                                          p_price_attribs.pricing_attribute85;
         l_pavv_tbl_in (1).pricing_attribute86 :=
                                          p_price_attribs.pricing_attribute86;
         l_pavv_tbl_in (1).pricing_attribute87 :=
                                          p_price_attribs.pricing_attribute87;
         l_pavv_tbl_in (1).pricing_attribute88 :=
                                          p_price_attribs.pricing_attribute88;
         l_pavv_tbl_in (1).pricing_attribute89 :=
                                          p_price_attribs.pricing_attribute89;
         l_pavv_tbl_in (1).pricing_attribute90 :=
                                          p_price_attribs.pricing_attribute90;
         l_pavv_tbl_in (1).pricing_attribute91 :=
                                          p_price_attribs.pricing_attribute91;
         l_pavv_tbl_in (1).pricing_attribute92 :=
                                          p_price_attribs.pricing_attribute92;
         l_pavv_tbl_in (1).pricing_attribute93 :=
                                          p_price_attribs.pricing_attribute93;
         l_pavv_tbl_in (1).pricing_attribute94 :=
                                          p_price_attribs.pricing_attribute94;
         l_pavv_tbl_in (1).pricing_attribute95 :=
                                          p_price_attribs.pricing_attribute95;
         l_pavv_tbl_in (1).pricing_attribute96 :=
                                          p_price_attribs.pricing_attribute96;
         l_pavv_tbl_in (1).pricing_attribute97 :=
                                          p_price_attribs.pricing_attribute97;
         l_pavv_tbl_in (1).pricing_attribute98 :=
                                          p_price_attribs.pricing_attribute98;
         l_pavv_tbl_in (1).pricing_attribute99 :=
                                          p_price_attribs.pricing_attribute99;
         l_pavv_tbl_in (1).pricing_attribute100 :=
                                         p_price_attribs.pricing_attribute100;
         okc_price_adjustment_pvt.create_price_att_value
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => l_init_msg_list,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_pavv_tbl           => l_pavv_tbl_in,
                                          x_pavv_tbl           => l_pavv_tbl_out
                                         );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_event,
                   g_module_current
                || '.Create_K_Covered_Levels.after_create.price_att',
                   'okc_price_adjustment_pvt.create_price_att_value(Return status = '
                || l_return_status
                || ')'
               );
         END IF;

         IF l_return_status = 'S'
         THEN
            l_priceattrib_id := l_pavv_tbl_out (1).ID;
         ELSE
            okc_api.set_message (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 'PRICE ATTRIBUTES (SUB LINE)'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END create_k_covered_levels;

   PROCEDURE create_contract_ibnew (
      p_extwar_rec                IN              extwar_rec_type,
      p_contact_tbl_in            IN              oks_extwarprgm_pvt.contact_tbl,
      p_salescredit_tbl_hdr_in    IN              oks_extwarprgm_pvt.salescredit_tbl,
      --mmadhavi bug 4174921
      p_salescredit_tbl_line_in   IN              oks_extwarprgm_pvt.salescredit_tbl,
      p_price_attribs_in          IN              oks_extwarprgm_pvt.pricing_attributes_type,
      x_inst_dtls_tbl             IN OUT NOCOPY   oks_ihd_pvt.ihdv_tbl_type,
      x_chrid                     OUT NOCOPY      NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_party_csr
      IS
         SELECT NAME
           FROM okx_parties_v
          WHERE id1 = p_extwar_rec.hdr_party_id;

      CURSOR l_lndates_csr (p_id NUMBER)
      IS
         SELECT start_date, end_date
           FROM okc_k_lines_b
          WHERE ID = p_id;

      CURSOR l_hdrdates_csr (p_id NUMBER)
      IS
         SELECT start_date, end_date, sts_code
           FROM okc_k_headers_b
          WHERE ID = p_id;

      l_hdr_rec                  k_header_rec_type;
      l_line_rec                 k_line_service_rec_type;
      l_covd_rec                 k_line_covered_level_rec_type;
      l_return_status            VARCHAR2 (5)    := okc_api.g_ret_sts_success;
      l_chrid                    NUMBER                             := NULL;
      l_lineid                   NUMBER                             := NULL;
      l_covlvl_id                NUMBER                             := NULL;
      l_party_name               okx_parties_v.NAME%TYPE;
      l_lndates_rec              l_lndates_csr%ROWTYPE;
      l_hdrdates_rec             l_hdrdates_csr%ROWTYPE;
      --l_ctr                       NUMBER := 0;

      --Contact
      l_contact_tbl_in           oks_extwarprgm_pvt.contact_tbl;
      --SalesCredit
      l_salescredit_tbl          oks_extwarprgm_pvt.salescredit_tbl;
      l_api_version     CONSTANT NUMBER                             := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)              := okc_api.g_false;
      l_index                    VARCHAR2 (2000);
      l_rule_group_id            NUMBER;
      l_rule_id                  NUMBER;
      l_sts_code                 VARCHAR2 (30);
      l_ste_code                 VARCHAR2 (30);
      l_duration                 NUMBER;
      l_timeunits                VARCHAR2 (25);
      l_sll_tbl                  oks_bill_sch.streamlvl_tbl;
      l_bil_sch_out              oks_bill_sch.itembillsch_tbl;
      l_strmlvl_id               NUMBER                             := NULL;
      l_update_line              VARCHAR2 (1);
      l_temp                     VARCHAR2 (2000);
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      OPEN l_party_csr;

      FETCH l_party_csr
       INTO l_party_name;

      CLOSE l_party_csr;

      IF p_extwar_rec.hdr_scs_code IN ('SERVICE', 'SUBSCRIPTION')
      THEN
         l_hdr_rec.short_description :=
                                'CUSTOMER : ' || l_party_name || '  Contract';
      ELSE
         l_hdr_rec.short_description :=
               'CUSTOMER : '
            || l_party_name
            || ' Warranty/Extended Warranty Contract';
      END IF;

      l_hdr_rec.contract_number := okc_api.g_miss_char;
      l_hdr_rec.rty_code := p_extwar_rec.rty_code;
      l_hdr_rec.start_date := p_extwar_rec.hdr_sdt;
      l_hdr_rec.end_date := p_extwar_rec.hdr_edt;
      --l_hdr_rec.sts_code            := 'ACTIVE';
      l_hdr_rec.class_code := 'SVC';
      l_hdr_rec.authoring_org_id := p_extwar_rec.hdr_org_id;
      l_hdr_rec.party_id := p_extwar_rec.hdr_party_id;
      l_hdr_rec.third_party_role := p_extwar_rec.hdr_third_party_role;
      l_hdr_rec.bill_to_id := p_extwar_rec.hdr_bill_2_id;
      l_hdr_rec.ship_to_id := p_extwar_rec.hdr_ship_2_id;
      l_hdr_rec.chr_group := p_extwar_rec.hdr_chr_group;
      --l_hdr_rec.short_description   := 'CUSTOMER : ' || l_party_name || ' Warranty/Extended Warranty Contract';
      l_hdr_rec.price_list_id := p_extwar_rec.hdr_price_list_id;
      l_hdr_rec.cust_po_number := p_extwar_rec.hdr_cust_po_number;
      l_hdr_rec.agreement_id := p_extwar_rec.hdr_agreement_id;
      l_hdr_rec.currency := p_extwar_rec.hdr_currency;
      l_hdr_rec.accounting_rule_id := p_extwar_rec.hdr_acct_rule_id;
      l_hdr_rec.invoice_rule_id := p_extwar_rec.hdr_inv_rule_id;
      l_hdr_rec.order_hdr_id := p_extwar_rec.hdr_order_hdr_id;
      l_hdr_rec.payment_term_id := p_extwar_rec.hdr_payment_term_id;
      l_hdr_rec.renewal_type := p_extwar_rec.hdr_renewal_type;
      l_hdr_rec.renewal_markup := p_extwar_rec.hdr_renewal_markup;
      l_hdr_rec.renewal_pricing_type := p_extwar_rec.hdr_renewal_pricing_type;
      l_hdr_rec.renewal_price_list_id :=
                                        p_extwar_rec.hdr_renewal_price_list_id;
      l_hdr_rec.renewal_po := p_extwar_rec.hdr_renewal_po;
      l_hdr_rec.cvn_type := p_extwar_rec.hdr_cvn_type;
      l_hdr_rec.cvn_rate := p_extwar_rec.hdr_cvn_rate;
      l_hdr_rec.cvn_date := p_extwar_rec.hdr_cvn_date;
      l_hdr_rec.cvn_euro_rate := p_extwar_rec.hdr_cvn_euro_rate;
      l_hdr_rec.tax_status_flag := p_extwar_rec.hdr_tax_status_flag;
      l_hdr_rec.tax_exemption_id := p_extwar_rec.hdr_tax_exemption_id;
      l_hdr_rec.contact_id := p_extwar_rec.hdr_contact_id;
      l_hdr_rec.scs_code := p_extwar_rec.hdr_scs_code;
      l_hdr_rec.merge_type := p_extwar_rec.merge_type;
      l_hdr_rec.merge_object_id := p_extwar_rec.merge_object_id;
      l_hdr_rec.qto_contact_id := p_extwar_rec.qto_contact_id;
      l_hdr_rec.qto_email_id := p_extwar_rec.qto_email_id;
      l_hdr_rec.qto_phone_id := p_extwar_rec.qto_phone_id;
      l_hdr_rec.qto_fax_id := p_extwar_rec.qto_fax_id;
      l_hdr_rec.qto_site_id := p_extwar_rec.qto_site_id;
      l_hdr_rec.order_line_id := p_extwar_rec.srv_order_line_id;
      l_hdr_rec.billing_profile_id := p_extwar_rec.billing_profile_id;
      l_hdr_rec.qcl_id := p_extwar_rec.hdr_qcl_id;
      l_hdr_rec.grace_period := p_extwar_rec.grace_period;
      l_hdr_rec.grace_duration := p_extwar_rec.grace_duration;
      l_hdr_rec.salesrep_id := p_extwar_rec.salesrep_id;
      l_hdr_rec.pdf_id := p_extwar_rec.hdr_pdf_id;
      l_hdr_rec.ccr_number := p_extwar_rec.ccr_number;
      l_hdr_rec.ccr_exp_date := p_extwar_rec.ccr_exp_date;
      l_hdr_rec.renewal_status := p_extwar_rec.renewal_status;

      IF p_extwar_rec.hdr_sdt > SYSDATE
      THEN
         get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
      ELSE
         get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
      END IF;

      l_hdr_rec.sts_code := l_sts_code;
      oks_extwarprgm_pvt.create_k_hdr
                            (p_k_header_rec            => l_hdr_rec,
                             p_contact_tbl             => p_contact_tbl_in,
                             p_salescredit_tbl_in      => p_salescredit_tbl_hdr_in,
                             --mmadhavi  bug 4174921
                             x_chr_id                  => l_chrid,
                             p_caller                  => 'IB',
                             x_order_error             => l_temp,
                             x_return_status           => l_return_status,
                             x_msg_count               => x_msg_count,
                             x_msg_data                => x_msg_data
                            );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                       (fnd_log.level_event,
                           g_module_current
                        || '.Create_contract_Ibnew.after_create.header',
                           'oks_extwarprgm_pvt.create_k_hdr(Return status = '
                        || l_return_status
                        || ')'
                       );
      END IF;

      IF NOT l_return_status = 'S'
      THEN
         RAISE g_exception_halt_validation;
      END IF;

      x_chrid := l_chrid;

      IF     p_extwar_rec.hdr_order_hdr_id IS NOT NULL
         AND p_extwar_rec.merge_type = 'NEW'
      THEN
         okc_oc_int_pub.create_k_relationships
                           (p_api_version              => l_api_version,
                            p_init_msg_list            => l_init_msg_list,
                            p_commit                   => okc_api.g_false,
                            p_sales_contract_id        => okc_api.g_miss_num,
                            p_service_contract_id      => x_chrid,
                            p_quote_id                 => okc_api.g_miss_num,
                            p_quote_line_tab           => okc_oc_int_pub.g_miss_ql_tab,
                            p_order_id                 => p_extwar_rec.hdr_order_hdr_id,
                            p_order_line_tab           => okc_oc_int_pub.g_miss_ol_tab,
                            p_trace_mode               => NULL,
                            x_return_status            => l_return_status,
                            x_msg_count                => x_msg_count,
                            x_msg_data                 => x_msg_data
                           );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                 (fnd_log.level_event,
                     g_module_current
                  || '.Create_contract_Ibnew.after_create.header',
                     'okc_oc_int_pub.create_k_relationships(Return status = '
                  || l_return_status
                  || ')'
                 );
         END IF;

         IF NOT l_return_status = 'S'
         THEN
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      l_line_rec.k_id := l_chrid;
      l_line_rec.k_line_number := okc_api.g_miss_char;
      l_line_rec.org_id := p_extwar_rec.hdr_org_id;
      l_line_rec.accounting_rule_id := p_extwar_rec.line_accounting_rule_id;
      l_line_rec.invoicing_rule_id := p_extwar_rec.line_invoicing_rule_id;
      l_line_rec.srv_id := p_extwar_rec.srv_id;
      l_line_rec.srv_segment1 := p_extwar_rec.srv_name;
      l_line_rec.srv_desc := p_extwar_rec.srv_desc;
      l_line_rec.srv_sdt := p_extwar_rec.srv_sdt;
      l_line_rec.srv_edt := p_extwar_rec.srv_edt;
      l_line_rec.bill_to_id := p_extwar_rec.srv_bill_2_id;
      l_line_rec.ship_to_id := p_extwar_rec.srv_ship_2_id;
      l_line_rec.order_line_id := p_extwar_rec.srv_order_line_id;
      l_line_rec.warranty_flag := p_extwar_rec.warranty_flag;
      l_line_rec.currency := p_extwar_rec.srv_currency;
      l_line_rec.coverage_template_id := p_extwar_rec.srv_cov_template_id;
      l_line_rec.standard_cov_yn := 'Y';
      l_line_rec.cust_account := p_extwar_rec.cust_account;
      l_line_rec.SOURCE := 'NEW';
      l_line_rec.upg_orig_system_ref := 'ORDER'; -- added 04-jun-2002 Vigandhi
      l_line_rec.upg_orig_system_ref_id := NULL; -- added 04-jun-2002 Vigandhi
      l_line_rec.commitment_id := p_extwar_rec.commitment_id;
      -- added 12-aug-2003 Vigandhi
      l_line_rec.line_renewal_type := p_extwar_rec.line_renewal_type;
      --l_line_rec.tax_amount             := p_extwar_rec.tax_amount;      -- added 22-oct-2003 Vigandhi
      l_line_rec.ln_price_list_id := p_extwar_rec.ln_price_list_id;

      -- added 07-nov-2003 Vigandhi
      IF p_extwar_rec.srv_sdt > SYSDATE
      THEN
         get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
      ELSE
         get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
      END IF;

      l_line_rec.line_sts_code := l_sts_code;
      oks_extwarprgm_pvt.create_k_service_lines
                           (p_k_line_rec              => l_line_rec,
                            p_contact_tbl             => p_contact_tbl_in,
                            p_salescredit_tbl_in      => p_salescredit_tbl_line_in,
                            p_caller                  => 'IB',
                            x_order_error             => l_temp,
                            x_service_line_id         => l_lineid,
                            x_return_status           => l_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data
                           );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
             (fnd_log.level_event,
                 g_module_current
              || '.Create_contract_Ibnew.after_create.service_line',
                 'oks_extwarprgm_pvt.create_k_service_lines(Return status = '
              || l_return_status
              || ')'
             );
      END IF;

      IF NOT l_return_status = 'S'
      THEN
         RAISE g_exception_halt_validation;
      END IF;

      l_covd_rec.k_id := l_chrid;
      l_covd_rec.rty_code := p_extwar_rec.rty_code;
      l_covd_rec.attach_2_line_id := l_lineid;
      l_covd_rec.line_number := okc_api.g_miss_char;
      l_covd_rec.customer_product_id := p_extwar_rec.lvl_cp_id;
      -- l_covd_rec.product_segment1        := p_extwar_rec.lvl_inventory_name;
      -- l_covd_rec.product_desc            := p_extwar_rec.lvl_inventory_desc;
      l_covd_rec.product_start_date := p_extwar_rec.srv_sdt;
      l_covd_rec.product_end_date := p_extwar_rec.srv_edt;
      l_covd_rec.quantity := p_extwar_rec.lvl_quantity;
      l_covd_rec.list_price := p_extwar_rec.srv_unit_price;
      l_covd_rec.uom_code := p_extwar_rec.lvl_uom_code;
      l_covd_rec.negotiated_amount := p_extwar_rec.srv_amount;
      l_covd_rec.warranty_flag := p_extwar_rec.warranty_flag;
      --l_covd_rec.product_sts_code      := p_extwar_rec.lvl_sts_code;
      l_covd_rec.line_renewal_type := p_extwar_rec.lvl_line_renewal_type;
      l_covd_rec.currency_code := p_extwar_rec.srv_currency;
      l_covd_rec.order_line_id := p_extwar_rec.srv_order_line_id;
      --l_covd_rec.upg_orig_system_ref   := Null;
      l_covd_rec.attach_2_line_desc := p_extwar_rec.srv_desc;
      -- bug#2396580 Vigandhi
      l_covd_rec.upg_orig_system_ref := 'ORDER_LINE';
      -- added 04-jun-2002 Vigandhi
      l_covd_rec.upg_orig_system_ref_id := p_extwar_rec.srv_order_line_id;
      -- added 04-jun-2002 Vigandhi
      l_covd_rec.prod_item_id := p_extwar_rec.lvl_inventory_id;
      l_covd_rec.tax_amount := p_extwar_rec.tax_amount;
      -- added tax calculation from OM. -- Vigandhi
      l_covd_rec.standard_coverage := 'Y';

      IF p_extwar_rec.srv_sdt > SYSDATE
      THEN
         get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
      ELSE
         get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
      END IF;

      l_covd_rec.product_sts_code := l_sts_code;
      oks_extwarprgm_pvt.create_k_covered_levels
                                       (p_k_covd_rec         => l_covd_rec,
                                        p_price_attribs      => p_price_attribs_in,
                                        p_caller             => 'IB',
                                        x_order_error        => l_temp,
                                        x_covlvl_id          => l_covlvl_id,
                                        x_update_line        => l_update_line,
                                        x_return_status      => l_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data
                                       );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_event,
                g_module_current
             || '.Create_contract_Ibnew.after_create.covered_line',
                'oks_extwarprgm_pvt.create_k_covered_levels(Return status = '
             || l_return_status
             || ')'
            );
      END IF;

      IF NOT l_return_status = 'S'
      THEN
         RAISE g_exception_halt_validation;
      END IF;

      OPEN l_lndates_csr (l_lineid);

      FETCH l_lndates_csr
       INTO l_lndates_rec;

      CLOSE l_lndates_csr;

      OPEN l_hdrdates_csr (l_chrid);

      FETCH l_hdrdates_csr
       INTO l_hdrdates_rec;

      CLOSE l_hdrdates_csr;

      g_ptr := x_inst_dtls_tbl.COUNT;
      x_inst_dtls_tbl (g_ptr).instance_amt_old := NULL;
      x_inst_dtls_tbl (g_ptr).instance_qty_old := NULL;
      x_inst_dtls_tbl (g_ptr).old_contract_id := NULL;
      x_inst_dtls_tbl (g_ptr).old_contact_start_date := NULL;
      x_inst_dtls_tbl (g_ptr).old_contract_end_date := NULL;
      x_inst_dtls_tbl (g_ptr).old_service_line_id := NULL;
      x_inst_dtls_tbl (g_ptr).old_service_start_date := NULL;
      x_inst_dtls_tbl (g_ptr).old_service_end_date := NULL;
      x_inst_dtls_tbl (g_ptr).old_subline_id := NULL;
      x_inst_dtls_tbl (g_ptr).old_subline_start_date := NULL;
      x_inst_dtls_tbl (g_ptr).old_subline_end_date := NULL;
      x_inst_dtls_tbl (g_ptr).old_customer := NULL;
      x_inst_dtls_tbl (g_ptr).old_k_status := NULL;
      get_sts_code (NULL, l_hdrdates_rec.sts_code, l_ste_code, l_sts_code);
      x_inst_dtls_tbl (g_ptr).instance_amt_new := p_extwar_rec.srv_amount;
      x_inst_dtls_tbl (g_ptr).new_contract_id := l_chrid;
      x_inst_dtls_tbl (g_ptr).new_contact_start_date :=
                                                     l_hdrdates_rec.start_date;
      x_inst_dtls_tbl (g_ptr).new_contract_end_date := l_hdrdates_rec.end_date;
      x_inst_dtls_tbl (g_ptr).new_service_line_id := l_lineid;
      x_inst_dtls_tbl (g_ptr).new_service_start_date :=
                                                      l_lndates_rec.start_date;
      x_inst_dtls_tbl (g_ptr).new_service_end_date := l_lndates_rec.end_date;
      x_inst_dtls_tbl (g_ptr).new_subline_id := l_covlvl_id;
      x_inst_dtls_tbl (g_ptr).new_subline_start_date := p_extwar_rec.srv_sdt;
      x_inst_dtls_tbl (g_ptr).new_subline_end_date := p_extwar_rec.srv_edt;
      x_inst_dtls_tbl (g_ptr).new_customer := p_extwar_rec.cust_account;
      x_inst_dtls_tbl (g_ptr).new_k_status := l_sts_code;
      x_inst_dtls_tbl (g_ptr).subline_date_terminated := NULL;

      IF p_extwar_rec.warranty_flag <> 'W'
      THEN
         l_strmlvl_id := check_strmlvl_exists (l_lineid);

         IF l_strmlvl_id IS NULL
         THEN
            okc_time_util_pub.get_duration
                                       (p_start_date         => p_extwar_rec.srv_sdt,
                                        p_end_date           => p_extwar_rec.srv_edt,
                                        x_duration           => l_duration,
                                        x_timeunit           => l_timeunits,
                                        x_return_status      => l_return_status
                                       );

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                                  g_module_current
                               || '.Create_contract_Ibnew.after.get_duration',
                                  'Get_Duration Status ='
                               || l_return_status
                               || ',Duration = '
                               || l_duration
                               || ',Time Unit = '
                               || l_timeunits
                              );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            l_sll_tbl (1).cle_id := l_lineid;
            --l_sll_tbl(1).billing_type                  := 'T';
            l_sll_tbl (1).uom_code := l_timeunits;
            l_sll_tbl (1).sequence_no := '1';
            l_sll_tbl (1).level_periods := '1';
            l_sll_tbl (1).start_date := p_extwar_rec.srv_sdt;
            l_sll_tbl (1).uom_per_period := l_duration;
            l_sll_tbl (1).advance_periods := NULL;
            l_sll_tbl (1).level_amount := NULL;
            l_sll_tbl (1).invoice_offset_days := NULL;
            l_sll_tbl (1).interface_offset_days := NULL;
            oks_bill_sch.create_bill_sch_rules
                    (p_billing_type         => 'T',
                     p_sll_tbl              => l_sll_tbl,
                     p_invoice_rule_id      => p_extwar_rec.line_invoicing_rule_id,
                     x_bil_sch_out_tbl      => l_bil_sch_out,
                     x_return_status        => l_return_status
                    );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                    (fnd_log.level_event,
                        g_module_current
                     || '.Create_contract_Ibnew.after.bill_sch',
                        'oks_bill_sch.create_bill_sch_rules(Return status = '
                     || l_return_status
                     || ')'
                    );
            END IF;

            IF l_return_status <> okc_api.g_ret_sts_success
            THEN
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Sched Billing Rule (LINE)'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            oks_bill_util_pub.create_bcl_for_om
                                           (p_line_id            => l_lineid,
                                            x_return_status      => l_return_status
                                           );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_event,
                   g_module_current || '.Create_contract_Ibnew.after.bcl_om',
                      ' oks_bill_util_pub.create_bcl_for_om(Return status = '
                   || l_return_status
                   || ')'
                  );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;
         ELSE
            IF check_lvlelements_exists (l_lineid)
            THEN
               IF l_update_line = 'Y'
               THEN
                  oks_bill_sch.update_om_sll_date
                                         (p_top_line_id        => l_lineid,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                            g_module_current
                         || '.Create_contract_Ibnew.after.om_sll',
                            'oks_bill_sch.update_om_sll_date(Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = 'S'
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               ELSE
                  oks_bill_sch.create_bill_sch_cp
                                         (p_top_line_id        => l_lineid,
                                          p_cp_line_id         => l_covlvl_id,
                                          p_cp_new             => 'Y',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                            g_module_current
                         || '.Create_contract_Ibnew.after.sch_cp',
                            'oks_bill_sch.create_bill_sch_cp(Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = 'S'
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;

               oks_bill_util_pub.create_bcl_for_om
                                           (p_line_id            => l_lineid,
                                            x_return_status      => l_return_status
                                           );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                      g_module_current
                      || '.Create_contract_Ibnew.after.bcl_om',
                         'oks_bill_util_pub.create_bcl_for_om(Return status = '
                      || l_return_status
                      || ')'
                     );
               END IF;

               IF NOT l_return_status = 'S'
               THEN
                  RAISE g_exception_halt_validation;
               END IF;
            ELSE
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'level elements NOT EXIST'
                                   );
               RAISE g_exception_halt_validation;
            END IF;
         END IF;                                                -- strmlvl end
      END IF;                                             -- warranty flag end

      UPDATE okc_k_lines_b
         SET price_negotiated =
                           (SELECT NVL (SUM (NVL (price_negotiated, 0)), 0)
                              FROM okc_k_lines_b
                             WHERE cle_id = l_lineid AND dnz_chr_id = l_chrid)
       WHERE ID = l_lineid;

      UPDATE okc_k_headers_b
         SET estimated_amount =
                           (SELECT NVL (SUM (NVL (price_negotiated, 0)), 0)
                              FROM okc_k_lines_b
                             WHERE dnz_chr_id = l_chrid AND lse_id IN (1, 19))
       WHERE ID = l_chrid;

      launch_workflow (   'INSTALL BASE ACTIVITY : NEW '
                       || fnd_global.local_chr (10)
                       || 'Contract Number       :     '
                       || get_contract_number (l_chrid)
                       || fnd_global.local_chr (10)
                       || 'Service Added         :     '
                       || p_extwar_rec.srv_name
                       || fnd_global.local_chr (10)
                       || 'Customer Product      :     '
                       || p_extwar_rec.lvl_cp_id
                      );
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE create_transaction_source (
      p_create_opr_inst                    VARCHAR2,
      p_source_code                        VARCHAR2,
      p_target_chr_id                      VARCHAR2,
      p_source_line_id                     NUMBER,
      p_source_chr_id                      NUMBER,
      p_target_line_id                     NUMBER,
      x_oper_instance_id   IN OUT NOCOPY   NUMBER,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR cop_csr (p_opn_code VARCHAR2)
      IS
         SELECT ID
           FROM okc_class_operations
          WHERE cls_code = (SELECT cls_code
                              FROM okc_subclasses_b
                             WHERE code = 'SERVICE')
                AND opn_code = p_opn_code;

      l_cop_id                   NUMBER;
      l_api_version     CONSTANT NUMBER                          := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)                    := 'F';
      l_return_status            VARCHAR2 (1)                    := 'S';
      l_oiev_tbl_in              okc_oper_inst_pvt.oiev_tbl_type;
      l_oiev_tbl_out             okc_oper_inst_pvt.oiev_tbl_type;
      l_olev_tbl_in              okc_oper_inst_pvt.olev_tbl_type;
      l_olev_tbl_out             okc_oper_inst_pvt.olev_tbl_type;
   BEGIN
      x_return_status := l_return_status;

      IF p_create_opr_inst = 'Y'
      THEN
         -- get class operation id
         OPEN cop_csr (p_source_code);

         FETCH cop_csr
          INTO l_cop_id;

         CLOSE cop_csr;

         --errorout_n('cop'||l_cop_id);
         l_oiev_tbl_in (1).status_code := 'PROCESSED';
         l_oiev_tbl_in (1).cop_id := l_cop_id;
         l_oiev_tbl_in (1).target_chr_id := p_target_chr_id;
         okc_oper_inst_pub.create_operation_instance
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => l_init_msg_list,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_oiev_tbl           => l_oiev_tbl_in,
                                          x_oiev_tbl           => l_oiev_tbl_out
                                         );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_event,
                g_module_current || '.CReate_transaction_source',
                   'OKC_OPER_INST_PUB.Create_Operation_Instance (Return status = '
                || l_return_status
                || ')'
               );
         END IF;

         IF NOT l_return_status = 'S'
         THEN
            RAISE g_exception_halt_validation;
         END IF;

         x_oper_instance_id := l_oiev_tbl_out (1).ID;
      END IF;

      l_olev_tbl_in (1).oie_id := x_oper_instance_id;
      l_olev_tbl_in (1).process_flag := 'P';
      l_olev_tbl_in (1).subject_chr_id := p_target_chr_id;
      l_olev_tbl_in (1).object_chr_id := p_source_chr_id;
      l_olev_tbl_in (1).subject_cle_id := p_target_line_id;
      l_olev_tbl_in (1).object_cle_id := p_source_line_id;
      l_olev_tbl_in (1).active_yn := 'Y';
      okc_oper_inst_pub.create_operation_line
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_olev_tbl           => l_olev_tbl_in,
                                           x_olev_tbl           => l_olev_tbl_out
                                          );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
              (fnd_log.level_event,
               g_module_current || '.CReate_transaction_source',
                  'OKC_OPER_INST_PUB.Create_Operation_Line (Return status = '
               || l_return_status
               || ')'
              );
      END IF;

      IF NOT l_return_status = 'S'
      THEN
         RAISE g_exception_halt_validation;
      END IF;

      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE create_source_links (
      p_line_id                            NUMBER,
      p_source_code                        VARCHAR2,
      p_create_opr_inst                    VARCHAR2,
      p_target_chr_id                      VARCHAR2,
      p_target_line_id                     NUMBER,
      p_txn_date                           DATE,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      x_oper_instance_id   IN OUT NOCOPY   NUMBER
   )
   IS
      CURSOR check_renewal_link
      IS
         SELECT object_cle_id, object_chr_id
           FROM okc_operation_instances op,
                okc_operation_lines ol,
                okc_class_operations classopr,
                okc_subclasses_b subclass
          WHERE ol.oie_id = op.ID
            AND subclass.code = 'SERVICE'
            AND classopr.cls_code = subclass.cls_code
            AND classopr.opn_code IN ('RENEWAL', 'REN_CON')
            AND op.cop_id = classopr.ID
            AND ol.subject_cle_id = p_line_id;

      CURSOR check_source_link (p_line_id NUMBER)
      IS
         SELECT subject_cle_id, subject_chr_id
           FROM okc_operation_instances op,
                okc_operation_lines ol,
                okc_class_operations cl,
                okc_subclasses_b sl
          WHERE ol.oie_id = op.ID
            AND op.cop_id = cl.ID
            AND cl.cls_code = sl.cls_code
            AND sl.code = 'SERVICE'
            AND cl.opn_code = p_source_code
            AND ol.object_cle_id = p_line_id;

      CURSOR check_split_source_link (p_line_id NUMBER)
      IS
         SELECT subject_cle_id, subject_chr_id
           FROM okc_operation_instances op,
                okc_operation_lines ol,
                okc_class_operations cl,
                okc_subclasses_b sl,
                okc_k_items a
          WHERE ol.oie_id = op.ID
            AND op.cop_id = cl.ID
            AND cl.cls_code = sl.cls_code
            AND sl.code = 'SERVICE'
            AND cl.opn_code = p_source_code
            AND ol.object_cle_id = p_line_id
            AND a.cle_id = ol.subject_cle_id
            AND a.object1_id1 = (Select  b.object1_id1
                                 from    okc_k_items b
                                 where   b.jtot_object1_code = 'OKX_CUSTPROD'
                                 and b.cle_id = p_target_line_id)
            AND a.jtot_object1_code = 'OKX_CUSTPROD';

      l_api_version     CONSTANT NUMBER       := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1) := 'F';
      l_return_status            VARCHAR2 (1) := 'S';
      l_renewal_id               NUMBER;
      l_source_id                NUMBER;
      l_renewal_chr_id           NUMBER;
      l_source_hdr_id            NUMBER;
      l_source_line_id           NUMBER;
      l_source_chr_id            NUMBER;
      l_line_date_renewed        DATE;
      l_hdr_date_renewed         DATE;

      FUNCTION hdr_renewal_link_exists (
         p_target_chr_id   NUMBER,
         p_source_chr_id   NUMBER
      )
         RETURN BOOLEAN
      IS
         CURSOR check_source_link
         IS
            SELECT 'Y'
              FROM okc_operation_instances op,
                   okc_operation_lines ol,
                   okc_class_operations classopr,
                   okc_subclasses_b subclass
             WHERE ol.oie_id = op.ID
               AND subclass.code = 'SERVICE'
               AND classopr.cls_code = subclass.cls_code
               AND classopr.opn_code IN ('RENEWAL', 'REN_CON')
               AND op.cop_id = classopr.ID
               AND ol.subject_chr_id = p_target_chr_id
               AND ol.object_chr_id = p_source_chr_id
               AND ol.subject_cle_id IS NULL
               AND ol.object_cle_id IS NULL;

         l_found   VARCHAR2 (1) := '?';
      BEGIN
         OPEN check_source_link;

         FETCH check_source_link
          INTO l_found;

         CLOSE check_source_link;

         IF l_found = 'Y'
         THEN
            RETURN (TRUE);
         ELSE
            RETURN (FALSE);
         END IF;
      END;
   BEGIN
      x_return_status := l_return_status;

      OPEN check_renewal_link;

      FETCH check_renewal_link
       INTO l_renewal_id, l_renewal_chr_id;

      CLOSE check_renewal_link;

      IF l_renewal_id IS NOT NULL
      THEN
         IF p_source_code = 'IBSPLIT'
         THEN
            OPEN check_split_source_link (l_renewal_id);

            FETCH check_split_source_link
             INTO l_source_id, l_source_chr_id;

            CLOSE check_split_source_link;
         ELSE
            OPEN check_source_link (l_renewal_id);

            FETCH check_source_link
             INTO l_source_id, l_source_chr_id;

            CLOSE check_source_link;
         END IF;

         IF l_source_id IS NOT NULL
         THEN
            l_source_line_id := l_source_id;
            l_source_hdr_id := l_source_chr_id;
         ELSE
            l_source_line_id := l_renewal_id;
            l_source_hdr_id := l_renewal_chr_id;
         END IF;

         create_transaction_source (p_create_opr_inst       => p_create_opr_inst,
                                    p_source_code           => 'RENEWAL',
                                    p_target_chr_id         => p_target_chr_id,
                                    p_source_line_id        => l_source_line_id,
                                    p_source_chr_id         => l_source_hdr_id,
                                    p_target_line_id        => p_target_line_id,
                                    x_oper_instance_id      => x_oper_instance_id,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data
                                   );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_event,
                g_module_current || '.CReate_transaction_source',
                   'OKC_OPER_INST_PUB.Create_transaction_source(Return status = '
                || l_return_status
                || ')'
               );
         END IF;

         IF x_return_status = 'S'
         THEN
            UPDATE okc_k_lines_b
               SET date_renewed = p_txn_date
             WHERE ID = l_source_line_id;

            l_line_date_renewed :=
                     oks_ib_util_pvt.check_renewed_sublines (l_source_line_id);

            UPDATE okc_k_lines_b
               SET date_renewed = l_line_date_renewed
             WHERE ID = (SELECT cle_id
                           FROM okc_k_lines_b
                          WHERE ID = l_source_line_id)
                   AND date_renewed IS NULL;

            l_hdr_date_renewed :=
                        oks_ib_util_pvt.check_renewed_lines (l_source_line_id);

            UPDATE okc_k_headers_all_b
               SET date_renewed = l_hdr_date_renewed
             WHERE ID = (SELECT dnz_chr_id
                           FROM okc_k_lines_b
                          WHERE ID = l_source_line_id)
                   AND date_renewed IS NULL;
         ELSE
            RAISE g_exception_halt_validation;
         END IF;

         -- Create an operation line for headers.
         IF p_source_code = 'TRANSFER'
         THEN
            IF NOT hdr_renewal_link_exists (p_target_chr_id, l_source_hdr_id)
            THEN
               create_transaction_source
                                   (p_create_opr_inst       => 'N',
                                    p_source_code           => 'RENEWAL',
                                    p_target_chr_id         => p_target_chr_id,
                                    p_source_line_id        => NULL,
                                    p_source_chr_id         => l_source_hdr_id,
                                    p_target_line_id        => NULL,
                                    x_oper_instance_id      => x_oper_instance_id,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data
                                   );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                      g_module_current || '.CReate_transaction_source',
                         'OKC_OPER_INST_PUB.Create_transaction_source(Return status = '
                      || l_return_status
                      || ')'
                     );
               END IF;
            END IF;
         END IF;
      END IF;

      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE create_contract_ibsplit (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_bill_csr (p_cle_id NUMBER)
      IS
         SELECT NVL (SUM (amount), 0)
           FROM oks_bill_sub_lines_v
          WHERE cle_id = p_cle_id;

      CURSOR l_rule_csr (p_cle_id NUMBER)
      IS
         SELECT elmnts.ID
           FROM oks_stream_levels_b strm, oks_level_elements elmnts
          WHERE strm.cle_id = p_cle_id AND elmnts.rul_id = strm.ID;

      CURSOR l_credit_csr (p_cle_id NUMBER)
      IS
         SELECT NVL (SUM (amount), 0)
           FROM oks_bill_sub_lines bsl
          WHERE bsl.cle_id = p_cle_id
            AND EXISTS (SELECT 1
                          FROM oks_bill_cont_lines bcl
                         WHERE bcl.ID = bsl.bcl_id AND bill_action = 'TR');

      --bug start 3736860
      CURSOR get_oks_line_dtls (p_id NUMBER)
      IS
         SELECT ID, object_version_number
           FROM oks_k_lines_b
          WHERE cle_id = p_id;

      CURSOR l_bill_tax_csr (p_cle_id NUMBER)
      IS
         SELECT NVL (SUM (trx_line_tax_amount), 0)
           FROM oks_bill_txn_lines
          WHERE bsl_id IN (SELECT ID
                             FROM oks_bill_sub_lines
                            WHERE cle_id = p_cle_id);

      --bug end 3736860
      CURSOR l_serv_csr (p_serv_id NUMBER)
      IS
         SELECT b.concatenated_segments description
           FROM mtl_system_items_b_kfv b
          WHERE b.inventory_item_id = p_serv_id AND ROWNUM < 2;

      CURSOR l_ordline_csr (p_line_id NUMBER)
      IS
         SELECT object1_id1
           FROM okc_k_rel_objs
          WHERE cle_id = p_line_id;

      CURSOR l_refnum_csr (p_cp_id NUMBER)
      IS
         SELECT instance_number
           FROM csi_item_instances
          WHERE instance_id = p_cp_id;

      l_ref_num                   VARCHAR2 (30);
      x_inst_dtls_tbl             oks_ihd_pvt.ihdv_tbl_type;
      l_inst_dtls_tbl             oks_ihd_pvt.ihdv_tbl_type;
      l_instparent_id             NUMBER;
      l_old_cp_id                 NUMBER;
      l_insthist_rec              oks_ins_pvt.insv_rec_type;
      x_insthist_rec              oks_ins_pvt.insv_rec_type;
      l_parameters                VARCHAR2 (2000);
      l_renewal_id                NUMBER;
      l_line_rec                  k_line_service_rec_type;
      l_covd_rec                  k_line_covered_level_rec_type;
      l_available_yn              VARCHAR2 (1);
      l_return_status             VARCHAR2 (5)    := okc_api.g_ret_sts_success;
      l_chrid                     NUMBER                               := NULL;
      l_lineid                    NUMBER                               := NULL;
      l_ctr                       NUMBER                                  := 0;
      l_ctr1                      NUMBER                                  := 0;
      l_api_version      CONSTANT NUMBER                                := 1.0;
      l_init_msg_list    CONSTANT VARCHAR2 (1)                          := 'F';
      l_terminate_rec             okc_terminate_pvt.terminate_in_cle_rec;
      l_srvc_stdt                 DATE;
      --Contract Line Table
      l_clev_tbl_in               okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out              okc_contract_pub.clev_tbl_type;
      --SalesCredit
      l_salescredit_tbl_line      oks_extwarprgm_pvt.salescredit_tbl;
      l_salescredit_tbl_hdr       oks_extwarprgm_pvt.salescredit_tbl;
      l_qty1price                 NUMBER                                  := 0;
      l_oldamt                    NUMBER (30, 2)                          := 0;
      l_no_of_days                NUMBER                                  := 0;
      l_new_value                 NUMBER                                  := 0;
      l_dayprice                  NUMBER                                  := 0;
      l_newactprice               NUMBER (30, 2)                          := 0;
      l_diff                      NUMBER                                  := 0;
      l_covlvl_id                 NUMBER;
      l_rule_group_id             NUMBER;
      l_rule_id                   NUMBER;
      l_price_attribs_in          oks_extwarprgm_pvt.pricing_attributes_type;
      l_bill_schd_yn              VARCHAR2 (1);
      l_list_price                NUMBER                                  := 0;
      l_spldt                     DATE;
      l_billed_amount             NUMBER                                  := 0;
      actual_amt                  NUMBER                                  := 0;
      l_total_days                NUMBER;
      l_credit_amt                NUMBER;
      l_duration                  NUMBER;
      l_timeunits                 VARCHAR2 (25);
      l_sll_tbl                   oks_bill_sch.streamlvl_tbl;
      l_bil_sch_out               oks_bill_sch.itembillsch_tbl;
      l_strmlvl_id                NUMBER                               := NULL;
      l_update_line               VARCHAR2 (1);
      l_temp                      VARCHAR2 (2000);
      l_ste_code                  VARCHAR2 (30);
      l_sts_code                  VARCHAR2 (30);
      l_old_qty                   NUMBER                                  := 0;
      actual_tax                  NUMBER                                  := 0;
      l_qtyltax                   NUMBER                                  := 0;
      l_oldtax                    NUMBER (30, 2)                          := 0;
      l_newacttax                 NUMBER (30, 2)                          := 0;
      l_daytax                    NUMBER                                  := 0;
      l_obj_version_num           NUMBER;
      l_id                        NUMBER;
      l_klnv_tbl_in               oks_kln_pvt.klnv_tbl_type;
      l_klnv_tbl_out              oks_kln_pvt.klnv_tbl_type;
      l_taxed_amount              NUMBER                                  := 0;
      l_new_cp_tbl                oks_bill_sch.subline_id_tbl;
      l_warranty_flag             VARCHAR2 (2);
      l_renewal_opr_instance_id   NUMBER;
      l_opr_instance_id           NUMBER;
      l_target_chr_id             NUMBER;
      l_source_line_id            NUMBER;
      l_create_oper_instance      VARCHAR2 (1);
      l_new_sdate                 DATE;
      l_order_line_id             Number;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;
      l_target_chr_id := 0;
      l_old_cp_id := 0;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.CREATE_CONTRACT_IBSPLIT.',
                         ', count = ' || p_kdtl_tbl.COUNT || ')'
                        );
      END IF;

      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP
            okc_context.set_okc_org_context
                                           (p_kdtl_tbl (l_ctr).hdr_org_id,
                                            p_kdtl_tbl (l_ctr).organization_id
                                           );
            l_inst_dtls_tbl.DELETE;
            l_ctr1 := 1;
            l_spldt := p_kdtl_tbl (l_ctr).transaction_date;

            IF (TRUNC (l_spldt) <= TRUNC (p_kdtl_tbl (l_ctr).prod_sdt))
            THEN
               l_spldt := p_kdtl_tbl (l_ctr).prod_sdt;
            END IF;

            l_covd_rec.list_price := p_kdtl_tbl (l_ctr).service_unit_price;

            IF p_kdtl_tbl (l_ctr).lse_id = 25
            THEN
               l_warranty_flag := 'E';
            ELSIF     p_kdtl_tbl (l_ctr).lse_id = 9
                  AND p_kdtl_tbl (l_ctr).scs_code = 'SERVICE'
            THEN
               l_warranty_flag := 'S';
            ELSIF p_kdtl_tbl (l_ctr).lse_id = 18
            THEN
               l_warranty_flag := 'W';
            ELSIF     p_kdtl_tbl (l_ctr).lse_id = 9
                  AND p_kdtl_tbl (l_ctr).scs_code = 'SUBSCRIPTION'
            THEN
               l_warranty_flag := 'SU';
            END IF;

            IF l_warranty_flag = 'W'
            THEN
               l_covd_rec.list_price := 0;
               l_covd_rec.negotiated_amount := 0;
               l_newactprice := 0;
               l_oldamt := 0;
               l_old_qty :=
                    p_kdtl_tbl (l_ctr).old_cp_quantity
                  - p_kdtl_tbl (l_ctr).new_quantity;
               --bug start 3736860
               l_oldtax := 0;
               l_covd_rec.tax_amount := 0;
               l_newacttax := 0;

               --bug end 3736860
               IF l_old_qty < 1
               THEN                                                 -- changed
                  l_old_qty := p_kdtl_tbl (l_ctr).old_cp_quantity; -- changed
               END IF;                                              -- changed

               l_new_sdate := TRUNC (p_kdtl_tbl (l_ctr).prod_sdt);
            ELSIF p_kdtl_tbl (l_ctr).service_amount IS NOT NULL
            THEN
               IF p_kdtl_tbl (l_ctr).lse_id <> 18
               THEN                   -- added subscription contract category
                  l_no_of_days :=
                     ABS (  TRUNC (  p_kdtl_tbl (l_ctr).prod_edt
                                   - TRUNC (p_kdtl_tbl (l_ctr).prod_sdt)
                                  )
                          + 1
                         );
                  actual_amt := p_kdtl_tbl (l_ctr).service_amount;
                  --bug start 3736860
                  actual_tax := p_kdtl_tbl (l_ctr).service_tax_amount;
                  --bug end 3736860
                  l_new_sdate := TRUNC (p_kdtl_tbl (l_ctr).prod_sdt);
               END IF;

               l_qty1price := actual_amt / p_kdtl_tbl (l_ctr).old_cp_quantity;
               l_old_qty :=
                    p_kdtl_tbl (l_ctr).old_cp_quantity
                  - p_kdtl_tbl (l_ctr).new_quantity;                -- changed
               --bug start 3736860
               l_qtyltax := actual_tax / p_kdtl_tbl (l_ctr).old_cp_quantity;

               --bug end 3736860
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBSPLIT',
                                     ' cp quantity = '
                                  || p_kdtl_tbl (l_ctr).old_cp_quantity
                                 );
               END IF;

               ---- changed
               IF l_old_qty < 1
               THEN
                  l_old_qty := p_kdtl_tbl (l_ctr).old_cp_quantity;
                  l_oldamt := p_kdtl_tbl (l_ctr).service_amount;
                  l_newactprice := 0;
                  --bug start 3736860
                  l_oldtax := p_kdtl_tbl (l_ctr).service_tax_amount;
                  l_newacttax := 0;
               --bug end 3736860
               ELSE
                  l_oldamt := l_old_qty * l_qty1price;
                  l_newactprice :=
                                 p_kdtl_tbl (l_ctr).service_amount - l_oldamt;
                                                               -- bug 4274725
                  --bug start 3736860
                  l_oldtax := l_old_qty * l_qtyltax;
                  l_newacttax :=
                             p_kdtl_tbl (l_ctr).service_tax_amount - l_oldtax;
                                                               -- bug 4274725
               --bug end 3736860
               END IF;

               -- end of change
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBSPLIT',
                                     ' l_old_qty = '
                                  || l_old_qty
                                  || ',l_oldamt = '
                                  || l_oldamt
                                  || ',l_newactprice = '
                                  || l_newactprice
                                 );
               END IF;

               l_oldamt :=
                  oks_extwar_util_pvt.round_currency_amt
                                           (l_oldamt,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
               l_covd_rec.negotiated_amount :=
                  oks_extwar_util_pvt.round_currency_amt
                                           (l_newactprice,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
               --bug start 3736860
               l_covd_rec.tax_amount :=
                  oks_extwar_util_pvt.round_currency_amt
                                           (l_newacttax,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
               --bug end 3736860
               l_list_price := p_kdtl_tbl (l_ctr).service_unit_price;
               l_covd_rec.list_price := p_kdtl_tbl (l_ctr).service_unit_price;
            END IF;                                     ---warranty flag = 'W'

            UPDATE okc_k_items
               SET number_of_items = l_old_qty
             WHERE cle_id = p_kdtl_tbl (l_ctr).object_line_id;

            UPDATE okc_k_lines_b
               SET price_negotiated = NVL (l_oldamt, 0),
                   price_unit = NVL (p_kdtl_tbl (l_ctr).service_unit_price, 0)
             WHERE ID = p_kdtl_tbl (l_ctr).object_line_id;

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                            (fnd_log.level_event,
                                g_module_current
                             || '.CREATE_CONTRACT_IBSPLIT.after_update.cov_lvl',
                                ' update_cov_level(Return status = '
                             || l_return_status
                             || ')'
                            );
            END IF;

            IF NOT l_return_status = okc_api.g_ret_sts_success
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            --bug start 3736860
            OPEN get_oks_line_dtls (p_kdtl_tbl (l_ctr).object_line_id);

            FETCH get_oks_line_dtls
             INTO l_id, l_obj_version_num;

            CLOSE get_oks_line_dtls;

            l_klnv_tbl_in (1).ID := l_id;
            l_klnv_tbl_in (1).tax_amount :=
               oks_extwar_util_pvt.round_currency_amt
                                           (l_oldtax,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
            l_klnv_tbl_in (1).object_version_number := l_obj_version_num;
            oks_contract_line_pub.update_line
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_klnv_tbl           => l_klnv_tbl_in,
                                           x_klnv_tbl           => l_klnv_tbl_out,
                                           p_validate_yn        => 'N'
                                          );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                     (fnd_log.level_event,
                         g_module_current
                      || '.CREATE_CONTRACT_IBSPLIT.after_cov_lvl_tax',
                         'oks_contract_line_pub.update_line(Return status = '
                      || l_return_status
                      || ')'
                     );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'OKS Contract COV LINE'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            --bug end 3736860
            get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).hdr_sts,
                          l_ste_code,
                          l_sts_code
                         );
            --x_inst_dtls_tbl(l_ctr1).INST_PARENT_ID            :=  p_split_rec.old_cp_id;
            l_inst_dtls_tbl (l_ctr1).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
            l_inst_dtls_tbl (l_ctr1).transaction_type := 'SPL';
            l_inst_dtls_tbl (l_ctr1).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (l_ctr1).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
            l_inst_dtls_tbl (l_ctr1).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ctr1).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ctr1).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ctr1).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ctr1).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ctr1).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (l_ctr1).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (l_ctr1).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (l_ctr1).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (l_ctr1).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ctr1).old_k_status := l_sts_code;
            l_inst_dtls_tbl (l_ctr1).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
            l_inst_dtls_tbl (l_ctr1).instance_amt_new := NVL (l_oldamt, 0);
            l_inst_dtls_tbl (l_ctr1).instance_qty_new := l_old_qty;
            l_inst_dtls_tbl (l_ctr1).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ctr1).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ctr1).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ctr1).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ctr1).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ctr1).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (l_ctr1).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (l_ctr1).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (l_ctr1).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (l_ctr1).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ctr1).new_k_status := l_sts_code;

            --x_inst_dtls_tbl(l_ctr1).SUBLINE_DATE_TERMINATED   :=

            -- Fixed Bug 2500056  06-Aug-2002
            IF p_kdtl_tbl (l_ctr).lse_id = 18
            THEN
               l_covd_rec.rty_code := 'CONTRACTWARRANTYORDER';
            ELSE
               l_covd_rec.rty_code := 'CONTRACTSERVICESORDER';
            END IF;

            l_covd_rec.k_id := p_kdtl_tbl (l_ctr).hdr_id;
            l_covd_rec.attach_2_line_id := p_kdtl_tbl (l_ctr).service_line_id;
            l_covd_rec.line_number := okc_api.g_miss_char;
            l_covd_rec.customer_product_id := p_kdtl_tbl (l_ctr).new_cp_id;
            l_covd_rec.product_segment1 := p_kdtl_tbl (l_ctr).prod_name;
            l_covd_rec.product_desc := p_kdtl_tbl (l_ctr).prod_description;
            l_covd_rec.product_start_date := l_new_sdate;
            --TRUNC( p_kdtl_tbl( l_ctr ).prod_sdt ); -- fixed bug2296369
            l_covd_rec.product_end_date := TRUNC (p_kdtl_tbl (l_ctr).prod_edt);
            l_covd_rec.quantity := p_kdtl_tbl (l_ctr).new_quantity;
            l_covd_rec.warranty_flag := l_warranty_flag;
            l_covd_rec.uom_code := p_kdtl_tbl (l_ctr).uom_code;
            l_order_line_id := Null;
            OPEN l_ordline_csr (p_kdtl_tbl (l_ctr).object_line_id);

            FETCH l_ordline_csr
             INTO l_order_line_id;

            CLOSE l_ordline_csr;

            l_covd_rec.order_line_id := l_order_line_id;
            l_covd_rec.currency_code := p_kdtl_tbl (l_ctr).service_currency;
            l_covd_rec.product_sts_code := p_kdtl_tbl (l_ctr).prod_sts_code;
            l_covd_rec.upg_orig_system_ref :=
                                        p_kdtl_tbl (l_ctr).upg_orig_system_ref;
            l_covd_rec.upg_orig_system_ref_id :=
                                     p_kdtl_tbl (l_ctr).upg_orig_system_ref_id;

            OPEN l_serv_csr (p_kdtl_tbl (l_ctr).service_inventory_id);

            FETCH l_serv_csr
             INTO l_covd_rec.attach_2_line_desc;

            CLOSE l_serv_csr;

            l_covd_rec.line_renewal_type :=
                                     p_kdtl_tbl (l_ctr).prod_line_renewal_type;
            l_covd_rec.prod_item_id := p_kdtl_tbl (l_ctr).new_inventory_item;
            l_covd_rec.price_uom := p_kdtl_tbl (l_ctr).price_uom_code;
            l_covd_rec.toplvl_uom_code := p_kdtl_tbl (l_ctr).toplvl_uom_code;
            --mchoudha added for bug#5233956
            l_covd_rec.toplvl_price_qty := p_kdtl_tbl (l_ctr).toplvl_price_qty;
            oks_extwar_util_pvt.get_k_pricing_attributes
                            (p_k_line_id          => p_kdtl_tbl (l_ctr).service_line_id,
                             x_pricing_att        => l_price_attribs_in,
                             x_return_status      => l_return_status
                            );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_event,
                      g_module_current
                   || '.CREATE_CONTRACT_IBSPLIT.after.price_att',
                      'oks_extwar_util_pvt.get_k_pricing_attributes(Return status = '
                   || l_return_status
                   || ')'
                  );
            END IF;

            IF NOT l_return_status = okc_api.g_ret_sts_success
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            oks_extwarprgm_pvt.create_k_covered_levels
                                       (p_k_covd_rec         => l_covd_rec,
                                        p_price_attribs      => l_price_attribs_in,
                                        p_caller             => 'IB',
                                        x_order_error        => l_temp,
                                        x_covlvl_id          => l_covlvl_id,
                                        x_update_line        => l_update_line,
                                        x_return_status      => l_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data
                                       );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_event,
                      g_module_current
                   || '.CREATE_CONTRACT_IBSPLIT.after_create.cov_lvl',
                      'oks_extwarprgm_pvt.create_k_covered_levels(Return status = '
                   || l_return_status
                   || ')'
                  );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            --x_inst_dtls_tbl(l_ctr1+1).INST_PARENT_ID            :=  p_split_rec.old_cp_id;
            l_inst_dtls_tbl (l_ctr1 + 1).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
            l_inst_dtls_tbl (l_ctr1 + 1).transaction_type := NULL;
            l_inst_dtls_tbl (l_ctr1 + 1).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (l_ctr1 + 1).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
            l_inst_dtls_tbl (l_ctr1 + 1).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ctr1 + 1).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ctr1 + 1).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (l_ctr1 + 1).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ctr1 + 1).old_k_status := l_sts_code;
            l_inst_dtls_tbl (l_ctr1 + 1).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).new_cp_id;
            l_inst_dtls_tbl (l_ctr1 + 1).instance_amt_new :=
               oks_extwar_util_pvt.round_currency_amt
                                           (l_newactprice,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
            l_inst_dtls_tbl (l_ctr1 + 1).instance_qty_new :=
                                               p_kdtl_tbl (l_ctr).new_quantity;
            l_inst_dtls_tbl (l_ctr1 + 1).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ctr1 + 1).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ctr1 + 1).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ctr1 + 1).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (l_ctr1 + 1).new_subline_id := l_covlvl_id;
            l_inst_dtls_tbl (l_ctr1 + 1).new_subline_start_date := l_new_sdate;
            l_inst_dtls_tbl (l_ctr1 + 1).new_subline_end_date :=
                                           TRUNC (p_kdtl_tbl (l_ctr).prod_edt);
            l_inst_dtls_tbl (l_ctr1 + 1).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ctr1 + 1).new_k_status := l_sts_code;
            l_inst_dtls_tbl (l_ctr1 + 1).subline_date_terminated := NULL;
            l_new_cp_tbl (1).ID := l_covlvl_id;
            oks_bill_sch.adjust_split_bill_sch
                             (p_old_cp_id          => p_kdtl_tbl (l_ctr).object_line_id,
                              p_new_cp_tbl         => l_new_cp_tbl,
                              x_return_status      => l_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data
                             );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                           (fnd_log.level_event,
                               g_module_current
                            || '.CREATE_CONTRACT_IBSPLIT.ADJUST_SPLIT_BILL_SCH',
                            'Return status = ' || l_return_status
                           );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            -- Fixed Bug 5039806
	    /*
            UPDATE okc_k_lines_b
               SET price_negotiated =
                      (SELECT NVL (SUM (NVL (price_negotiated, 0)), 0)
                         FROM okc_k_lines_b
                        WHERE cle_id = p_kdtl_tbl (l_ctr).service_line_id
                          AND dnz_chr_id = p_kdtl_tbl (l_ctr).hdr_id)
             WHERE ID = p_kdtl_tbl (l_ctr).service_line_id;

            UPDATE okc_k_headers_b
               SET estimated_amount =
                      (SELECT NVL (SUM (NVL (price_negotiated, 0)), 0)
                         FROM okc_k_lines_b
                        WHERE dnz_chr_id = p_kdtl_tbl (l_ctr).hdr_id
                          AND lse_id IN (1, 19))
             WHERE ID = p_kdtl_tbl (l_ctr).hdr_id;
	     */

            l_create_oper_instance := 'N';

            IF    l_opr_instance_id IS NULL
               OR l_target_chr_id <> p_kdtl_tbl (l_ctr).hdr_id
            THEN
               l_target_chr_id := p_kdtl_tbl (l_ctr).hdr_id;
               l_create_oper_instance := 'Y';
            END IF;

            create_transaction_source
                        (p_create_opr_inst       => l_create_oper_instance,
                         p_source_code           => 'IBSPLIT',
                         p_target_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                         p_source_line_id        => p_kdtl_tbl (l_ctr).object_line_id,
                         p_source_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                         p_target_line_id        => l_covlvl_id,
                         x_oper_instance_id      => l_opr_instance_id,
                         x_return_status         => l_return_status,
                         x_msg_count             => x_msg_count,
                         x_msg_data              => x_msg_data
                        );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                       (fnd_log.level_event,
                           g_module_current
                        || '.CREATE_CONTRACT_IBSPLIT.Create_transaction_source',
                        'Return status = ' || l_return_status
                       );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            create_source_links
                            (p_create_opr_inst       => l_create_oper_instance,
                             p_source_code           => 'IBSPLIT',
                             p_target_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                             p_line_id               => p_kdtl_tbl (l_ctr).object_line_id,
                             p_target_line_id        => l_covlvl_id,
                             p_txn_date              => p_kdtl_tbl (l_ctr).transaction_date,
                             x_oper_instance_id      => l_renewal_opr_instance_id,
                             x_return_status         => l_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data
                            );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                             (fnd_log.level_event,
                                 g_module_current
                              || '.CREATE_CONTRACT_IBSPLIT.Create_source_links',
                              'Return status = ' || l_return_status
                             );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            IF l_inst_dtls_tbl.COUNT <> 0
            THEN
               IF     l_instparent_id IS NULL
                  AND l_old_cp_id <> p_kdtl_tbl (l_ctr).old_cp_id
               THEN
                  OPEN l_refnum_csr (p_kdtl_tbl (l_ctr).old_cp_id);

                  FETCH l_refnum_csr
                   INTO l_ref_num;

                  CLOSE l_refnum_csr;

                  l_parameters :=
                        ' Old CP :'
                     || p_kdtl_tbl (l_ctr).old_cp_id
                     || ','
                     || 'Item Id:'
                     || p_kdtl_tbl (l_ctr).prod_inventory_item
                     || ','
                     || 'Old Quantity:'
                     || p_kdtl_tbl (l_ctr).old_cp_quantity
                     || ','
                     || 'Transaction type :'
                     || 'SPL'
                     || ','
                     || ' Transaction date :'
                     || TRUNC(p_kdtl_tbl (l_ctr).transaction_date)
                     || ','
                     || 'New quantity:'
                     || p_kdtl_tbl (l_ctr).new_quantity;
                  --oks_instance_history
                  l_old_cp_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.instance_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.transaction_type := 'SPL';
                  l_insthist_rec.transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                  l_insthist_rec.reference_number := l_ref_num;
                  l_insthist_rec.PARAMETERS := l_parameters;
                  oks_ins_pvt.insert_row (p_api_version        => 1.0,
                                          p_init_msg_list      => 'T',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_insv_rec           => l_insthist_rec,
                                          x_insv_rec           => x_insthist_rec
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_K_IBSPLIT',
                                    'oks_ins_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
                  END IF;

                  x_return_status := l_return_status;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;
                     RAISE g_exception_halt_validation;
                  END IF;

                  l_instparent_id := x_insthist_rec.ID;
               END IF;

               FOR i IN l_inst_dtls_tbl.FIRST .. l_inst_dtls_tbl.LAST
               LOOP
                  l_inst_dtls_tbl (i).ins_id := l_instparent_id;
               END LOOP;

               --oks_inst_history_details
               oks_ihd_pvt.insert_row (p_api_version        => 1.0,
                                       p_init_msg_list      => 'T',
                                       x_return_status      => l_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_ihdv_tbl           => l_inst_dtls_tbl,
                                       x_ihdv_tbl           => x_inst_dtls_tbl
                                      );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_K_IBSPLIT',
                                    'oks_ihd_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
               END IF;

               x_return_status := l_return_status;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  x_return_status := l_return_status;
                  RAISE g_exception_halt_validation;
               END IF;
            END IF;

            launch_workflow (   'INSTALL BASE ACTIVITY : SPLIT '
                             || fnd_global.local_chr (10)
                             || 'Contract Number       :       '
                             || get_contract_number (p_kdtl_tbl (l_ctr).hdr_id)
                             || fnd_global.local_chr (10)
                             || 'Splitted Cust Product :       '
                             || p_kdtl_tbl (l_ctr).old_cp_id
                             || fnd_global.local_chr (10)
                             || 'New Customer  Product :       '
                             || p_kdtl_tbl (l_ctr).new_cp_id
                            );
            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
            l_ctr1 := l_ctr1 + 2;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE update_contract_ibreplace (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      --billed upto date
      CURSOR l_billend_csr (p_cle_id NUMBER)
      IS
         SELECT MAX (date_billed_to) date_billed_to
           FROM oks_bill_sub_lines
          WHERE cle_id = p_cle_id;

      CURSOR l_cov_csr (p_cle_id NUMBER)
      IS
         SELECT ksl1.inheritance_type
           FROM oks_k_lines_b ksl, oks_k_lines_b ksl1
          WHERE ksl.cle_id = p_cle_id AND ksl1.cle_id = ksl.coverage_id;

      --level element id
      CURSOR l_rule_csr (p_cle_id NUMBER)
      IS
         SELECT elmnts.ID
           FROM oks_stream_levels_b strm, oks_level_elements elmnts
          WHERE strm.cle_id = p_cle_id AND elmnts.rul_id = strm.ID;

      --total billed amount
      CURSOR l_billed_amount_csr (p_cle_id NUMBER)
      IS
         SELECT NVL (SUM (amount), 0)
           FROM oks_bill_sub_lines_v
          WHERE cle_id = p_cle_id;

      --credit amount
      CURSOR l_credit_csr (p_cle_id NUMBER)
      IS
         SELECT NVL (SUM (amount), 0)
           FROM oks_bill_sub_lines bsl
          WHERE bsl.cle_id = p_cle_id
            AND EXISTS (SELECT 1
                          FROM oks_bill_cont_lines bcl
                         WHERE bcl.ID = bsl.bcl_id AND bill_action = 'TR');

      -- bug start 3736860
      CURSOR get_oks_line_dtls (p_id NUMBER)
      IS
         SELECT ID, object_version_number
           FROM oks_k_lines_b
          WHERE cle_id = p_id;

      CURSOR l_bill_tax_csr (p_cle_id NUMBER)
      IS
         SELECT NVL (SUM (trx_line_tax_amount), 0)
           FROM oks_bill_txn_lines
          WHERE bsl_id IN (SELECT ID
                             FROM oks_bill_sub_lines
                            WHERE cle_id = p_cle_id);

      --bug end 3736860
      CURSOR l_serv_csr (p_serv_id NUMBER)
      IS
         SELECT b.concatenated_segments description
           FROM mtl_system_items_b_kfv b
          WHERE b.inventory_item_id = p_serv_id AND ROWNUM < 2;

      CURSOR l_ordline_csr (p_line_id NUMBER)
      IS
         SELECT object1_id1
           FROM okc_k_rel_objs
          WHERE cle_id = p_line_id;

      CURSOR check_renewal_link (p_line_id NUMBER)
      IS
         SELECT object_cle_id
           FROM okc_operation_instances op, okc_operation_lines ol
          WHERE ol.oie_id = op.ID
            AND op.cop_id IN (41, 40)
            AND ol.subject_cle_id = p_line_id;

      CURSOR check_replace_link (p_line_id NUMBER)
      IS
         SELECT object_cle_id
           FROM okc_operation_instances op, okc_operation_lines ol
          WHERE ol.oie_id = op.ID
            AND op.cop_id = 11017
            AND ol.subject_cle_id = p_line_id;

      CURSOR l_refnum_csr (p_cp_id NUMBER)
      IS
         SELECT instance_number
           FROM csi_item_instances
          WHERE instance_id = p_cp_id;

      l_ref_num                   VARCHAR2 (30);
      x_inst_dtls_tbl             oks_ihd_pvt.ihdv_tbl_type;
      l_inst_dtls_tbl             oks_ihd_pvt.ihdv_tbl_type;
      l_instparent_id             NUMBER;
      l_old_cp_id                 NUMBER;
      l_insthist_rec              oks_ins_pvt.insv_rec_type;
      x_insthist_rec              oks_ins_pvt.insv_rec_type;
      l_parameters                VARCHAR2 (2000);
      l_renewal_id                NUMBER;
      -- l_contact_tbl_in              oks_extwarprgm_pvt.contact_tbl;
      -- l_salescredit_tbl_line        oks_extwarprgm_pvt.salescredit_tbl;
      -- l_salescredit_tbl_hdr         oks_extwarprgm_pvt.salescredit_tbl;
      l_line_rec                  k_line_service_rec_type;
      l_covd_rec                  k_line_covered_level_rec_type;
      l_available_yn              CHAR;
      l_return_status             VARCHAR2 (5)    := okc_api.g_ret_sts_success;
      l_chrid                     NUMBER                               := NULL;
      l_lineid                    NUMBER                               := NULL;
      l_days                      NUMBER                                  := 0;
      l_day1price                 NUMBER                                  := 0;
      l_oldamt                    NUMBER (30, 2)                          := 0;
      l_newamt                    NUMBER (30, 2)                          := 0;
      l_ctr                       NUMBER                                  := 0;
      l_ctr1                      NUMBER                                  := 0;
      l_newsdt                    DATE;
      l_newedt                    DATE;
      l_repldt                    DATE;
      l_repl_rule                 VARCHAR2 (2);
      l_duration                  NUMBER;
      l_timeunits                 VARCHAR2 (240);
      l_covlvl_id                 NUMBER;
      --Contract Line Table
      l_clev_tbl_in               okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out              okc_contract_pub.clev_tbl_type;
      l_price_attribs_in          oks_extwarprgm_pvt.pricing_attributes_type;
      l_cov_rec                   l_cov_csr%ROWTYPE;
      l_api_version      CONSTANT NUMBER                                := 1.0;
      l_init_msg_list    CONSTANT VARCHAR2 (1)              := okc_api.g_false;
      l_list_price                NUMBER;
      l_no_of_days                NUMBER;
      l_billed_amount             NUMBER;
      l_billed_upto_dt            DATE;
      l_ptr                       NUMBER                                  := 0;
      actual_amount               NUMBER                                  := 0;
      l_ste_code                  VARCHAR2 (30);
      l_sts_code                  VARCHAR2 (30);
      l_update_line               VARCHAR2 (1);
      l_temp                      VARCHAR2 (2000);
      l_obj_version_num           NUMBER;
      l_id                        NUMBER;
      l_klnv_tbl_in               oks_kln_pvt.klnv_tbl_type;
      l_klnv_tbl_out              oks_kln_pvt.klnv_tbl_type;
      actual_tax                  NUMBER                                  := 0;
      l_day1tax                   NUMBER                                  := 0;
      l_oldtax                    NUMBER (30, 2)                          := 0;
      l_newtax                    NUMBER (30, 2)                          := 0;
      l_taxed_amount              NUMBER                                  := 0;
      l_warranty_flag             VARCHAR2 (2);
      l_opr_instance_id           NUMBER;
      l_renewal_opr_instance_id   NUMBER;
      l_target_chr_id             NUMBER;
      l_replace_id                NUMBER;
      l_source_line_id            NUMBER;
      l_create_oper_instance      VARCHAR2 (1);
      l_termdt                    DATE;
      l_order_line_id             Number;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;
      l_old_cp_id := 0;
      l_target_chr_id := 0;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.CREATE_CONTRACT_IBREPLACE.',
                         'count = ' || p_kdtl_tbl.COUNT || ')'
                        );
      END IF;

      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP
            okc_context.set_okc_org_context
                                           (p_kdtl_tbl (l_ctr).hdr_org_id,
                                            p_kdtl_tbl (l_ctr).organization_id
                                           );
            l_inst_dtls_tbl.DELETE;
            l_ctr1 := 1;
            get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).prod_sts_code,
                          l_ste_code,
                          l_sts_code
                         );

            --IF l_ste_code <> 'ENTERED' THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING
                  (fnd_log.level_statement,
                   g_module_current || '.CREATE_CONTRACT_IBREPLACE',
                      'Service Start Date = '
                   || p_kdtl_tbl (l_ctr).service_sdt
                   || '
                                           ,Service End Date = '
                   || p_kdtl_tbl (l_ctr).service_edt
                   || ', lse_id= '
                   || p_kdtl_tbl (l_ctr).lse_id
                  );
            END IF;

            l_days :=
                 (  TRUNC (p_kdtl_tbl (l_ctr).prod_edt)
                  - TRUNC (p_kdtl_tbl (l_ctr).prod_sdt)
                 )
               + 1;
            l_repldt := trunc(p_kdtl_tbl (l_ctr).transaction_date);

            IF TRUNC (l_repldt) <= TRUNC (p_kdtl_tbl (l_ctr).prod_sdt)
            THEN
               l_repldt := TRUNC (p_kdtl_tbl (l_ctr).prod_sdt);
            END IF;

            l_covd_rec.list_price := p_kdtl_tbl (l_ctr).service_unit_price;

            IF p_kdtl_tbl (l_ctr).lse_id = 18
            THEN
               l_covd_rec.list_price := 0;
               l_covd_rec.negotiated_amount := 0;
               l_list_price := 0;
               l_oldamt := 0;
               l_repl_rule := NULL;
               l_newamt := 0;
               --bug start 3736860
               l_newtax := 0;
               l_oldtax := 0;
               l_covd_rec.tax_amount := 0;

               --bug end 3736860
               OPEN l_cov_csr (p_kdtl_tbl (l_ctr).service_line_id);

               FETCH l_cov_csr
                INTO l_cov_rec;

               l_repl_rule := l_cov_rec.inheritance_type;

               CLOSE l_cov_csr;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBREPLACE',
                                  'Replace Rule = ' || l_repl_rule
                                 );
               END IF;

               /* If product is terminated it can't be extended beyond Its terminated date
                  so Replace rule will be set only for the remaining period.
               */
               l_newsdt := l_repldt;
               l_termdt := l_repldt;

               IF NVL (l_repl_rule, 'R') = 'R'
               THEN
                  l_newedt := p_kdtl_tbl (l_ctr).prod_edt;
               ELSIF NVL (l_repl_rule, 'R') = 'F'
               THEN
                  okc_time_util_pub.get_duration
                                 (p_start_date         => p_kdtl_tbl (l_ctr).prod_sdt,
                                  p_end_date           => p_kdtl_tbl (l_ctr).prod_edt,
                                  x_duration           => l_duration,
                                  x_timeunit           => l_timeunits,
                                  x_return_status      => l_return_status
                                 );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                            (fnd_log.level_event,
                                g_module_current
                             || '.CREATE_CONTRACT_IBREPLACE.after.get_duration',
                             'Return Status = ' || l_return_status
                            );
                  END IF;

                  IF NOT l_return_status = 'S'
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;

                  l_newedt :=
                     okc_time_util_pub.get_enddate (p_start_date      => l_repldt,
                                                    p_duration        => l_duration,
                                                    p_timeunit        => l_timeunits
                                                   );
               END IF;
            END IF;

            IF p_kdtl_tbl (l_ctr).service_amount IS NOT NULL
            THEN
               IF p_kdtl_tbl (l_ctr).lse_id IN (25, 9)
               THEN
                  actual_amount := p_kdtl_tbl (l_ctr).service_amount;
                  actual_tax := p_kdtl_tbl (l_ctr).service_tax_amount;
                  l_newedt := TRUNC (p_kdtl_tbl (l_ctr).prod_edt);
                  l_newamt := p_kdtl_tbl (l_ctr).service_amount;
                  l_oldamt := 0;
                  l_newtax := p_kdtl_tbl (l_ctr).service_tax_amount;
                  l_oldtax := 0;
                  l_newsdt := TRUNC (p_kdtl_tbl (l_ctr).prod_sdt);
                  -- Fixed for bug 4539750
                  l_termdt := TRUNC (p_kdtl_tbl (l_ctr).prod_sdt);
               END IF;
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                               || '.CREATE_CONTRACT_IBREPLACE',
                                  'New amount = '
                               || l_newamt
                               || ',Old amount = '
                               || l_oldamt
                              );
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                               || '.CREATE_CONTRACT_IBREPLACE',
                                  'New tax = '
                               || l_newtax
                               || ',Old tax = '
                               || l_oldtax
                              );
            END IF;

            l_covd_rec.tax_amount :=
               oks_extwar_util_pvt.round_currency_amt
                                           (l_newtax,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
            l_covd_rec.negotiated_amount :=
               oks_extwar_util_pvt.round_currency_amt
                                           (l_newamt,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
            l_covd_rec.list_price :=
               oks_extwar_util_pvt.round_currency_amt
                                           (  l_newamt
                                            / p_kdtl_tbl (l_ctr).old_cp_quantity,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );

            IF l_ste_code <> 'ENTERED'
            THEN
               l_clev_tbl_in (1).ID := p_kdtl_tbl (l_ctr).object_line_id;
               l_clev_tbl_in (1).date_terminated := l_termdt;
               l_clev_tbl_in (1).price_negotiated :=
                  oks_extwar_util_pvt.round_currency_amt
                                          (l_oldamt,
                                           p_kdtl_tbl (l_ctr).service_currency
                                          );
               l_clev_tbl_in (1).price_unit :=
                  oks_extwar_util_pvt.round_currency_amt
                                          (  p_kdtl_tbl (l_ctr).service_amount
                                           / p_kdtl_tbl (l_ctr).old_cp_quantity,
                                           p_kdtl_tbl (l_ctr).service_currency
                                          );
               l_clev_tbl_in (1).trn_code := 'REP';
               l_clev_tbl_in (1).term_cancel_source := 'IBREPLACE';

               get_sts_code ('TERMINATED', NULL, l_ste_code, l_sts_code);
               l_clev_tbl_in (1).sts_code := l_sts_code;

               okc_contract_pub.update_contract_line
                                       (p_api_version            => l_api_version,
                                        p_init_msg_list          => l_init_msg_list,
                                        p_restricted_update      => okc_api.g_true,
                                        x_return_status          => l_return_status,
                                        x_msg_count              => x_msg_count,
                                        x_msg_data               => x_msg_data,
                                        p_clev_tbl               => l_clev_tbl_in,
                                        x_clev_tbl               => l_clev_tbl_out
                                       );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                         g_module_current
                      || '.CREATE_CONTRACT_IBREPLACE.update_cov_lvl',
                         'okc_contract_pub.update_contract_line(Return status = '
                      || l_return_status
                      || 'count = '
                      || p_kdtl_tbl.COUNT
                      || ')'
                     );
               END IF;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  RAISE g_exception_halt_validation;
               END IF;

               OPEN get_oks_line_dtls (p_kdtl_tbl (l_ctr).object_line_id);

               FETCH get_oks_line_dtls
                INTO l_id, l_obj_version_num;

               CLOSE get_oks_line_dtls;

               l_klnv_tbl_in (1).ID := l_id;
               l_klnv_tbl_in (1).tax_amount :=
                  oks_extwar_util_pvt.round_currency_amt
                                           (l_oldtax,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
               l_klnv_tbl_in (1).object_version_number := l_obj_version_num;
               oks_contract_line_pub.update_line
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_klnv_tbl           => l_klnv_tbl_in,
                                           x_klnv_tbl           => l_klnv_tbl_out,
                                           p_validate_yn        => 'N'
                                          );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                         g_module_current
                      || '.CREATE_CONTRACT_IBREPLACE.after_update.cov_lvl_tax',
                         'oks_contract_line_pub.update_line(Return status = '
                      || l_return_status
                      || ')'
                     );
               END IF;

               IF NOT l_return_status = 'S'
               THEN
                  okc_api.set_message (g_app_name,
                                       g_required_value,
                                       g_col_name_token,
                                       'OKS Contract COV LINE'
                                      );
                  RAISE g_exception_halt_validation;
               END IF;

               l_inst_dtls_tbl (l_ctr1).subline_date_terminated :=
                                           TRUNC (p_kdtl_tbl (l_ctr).prod_sdt);
            ELSE
               -- Cancel the line

	      -- added for the bug # 6000133
	      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

               oks_change_status_pvt.update_line_status
                          (x_return_status           => l_return_status,
                           x_msg_data                => x_msg_data,
                           x_msg_count               => x_msg_count,
                           p_init_msg_list           => 'F',
                           p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                           p_cle_id                  => p_kdtl_tbl (l_ctr).object_line_id,
                           p_new_sts_code            => l_sts_code,
                           p_canc_reason_code        => 'REPLACE',
                           p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                           p_old_ste_code            => 'ENTERED',
                           p_new_ste_code            => 'CANCELLED',
                           p_term_cancel_source      => 'IBREPLACE',
                           p_date_cancelled          => TRUNC (l_termdt),
                           p_comments                => NULL,
                           p_validate_status         => 'N'
                          );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                      g_module_current || '.CREATE_CONTRACT_IBTERMINATE',
                         'okc_contract_pub.update_contract_line(Return status ='
                      || l_return_status
                      || ')'
                     );
               END IF;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  RAISE g_exception_halt_validation;
               END IF;

               l_inst_dtls_tbl (l_ctr1).date_cancelled := TRUNC (l_termdt);
            END IF;

            get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).hdr_sts,
                          l_ste_code,
                          l_sts_code
                         );
            l_inst_dtls_tbl (l_ctr1).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
            l_inst_dtls_tbl (l_ctr1).transaction_type := 'RPL';
            l_inst_dtls_tbl (l_ctr1).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (l_ctr1).instance_qty_old :=
                                               p_kdtl_tbl (l_ctr).new_quantity;
            l_inst_dtls_tbl (l_ctr1).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ctr1).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ctr1).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ctr1).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ctr1).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ctr1).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (l_ctr1).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (l_ctr1).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (l_ctr1).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (l_ctr1).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ctr1).old_k_status := l_sts_code;
            --l_inst_dtls_tbl(l_ctr1).SUBLINE_DATE_TERMINATED   := TRUNC(p_kdtl_tbl( l_ctr ).prod_sdt);
            l_inst_dtls_tbl (l_ctr1).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).new_cp_id;
            l_inst_dtls_tbl (l_ctr1).instance_amt_new :=
               oks_extwar_util_pvt.round_currency_amt
                                           (l_oldamt,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
            l_inst_dtls_tbl (l_ctr1).instance_qty_new :=
                                               p_kdtl_tbl (l_ctr).new_quantity;
            l_inst_dtls_tbl (l_ctr1).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ctr1).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ctr1).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ctr1).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ctr1).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ctr1).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (l_ctr1).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (l_ctr1).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (l_ctr1).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (l_ctr1).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ctr1).new_k_status := l_sts_code;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                               || '.CREATE_CONTRACT_IBREPLACE',
                                  'New End date = '
                               || l_newedt
                               || ',New start Date = '
                               || TRUNC (p_kdtl_tbl (l_ctr).prod_sdt)
                               || ',Old Amount= '
                               || l_oldamt
                               || 'New Amount = '
                               || l_newamt
                              );
            END IF;

            l_lineid := p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ctr1 + 1).new_service_line_id := l_lineid;
            l_inst_dtls_tbl (l_ctr1 + 1).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;

            -- Fixed Bug 2500056  06-Aug-2002
            IF p_kdtl_tbl (l_ctr).lse_id = 18
            THEN
               l_covd_rec.rty_code := 'CONTRACTWARRANTYORDER';
            ELSE
               l_covd_rec.rty_code := 'CONTRACTSERVICESORDER';
            END IF;
            l_order_line_id := null;
            OPEN l_ordline_csr (p_kdtl_tbl (l_ctr).object_line_id);

            FETCH l_ordline_csr
             INTO l_order_line_id;

            CLOSE l_ordline_csr;

            l_covd_rec.order_line_id := l_order_line_id;
            OPEN l_serv_csr (p_kdtl_tbl (l_ctr).service_inventory_id);

            FETCH l_serv_csr
             INTO l_covd_rec.attach_2_line_desc;

            CLOSE l_serv_csr;

            IF p_kdtl_tbl (l_ctr).lse_id = 25
            THEN
               l_warranty_flag := 'E';
            ELSIF     p_kdtl_tbl (l_ctr).lse_id = 9
                  AND p_kdtl_tbl (l_ctr).scs_code = 'SERVICE'
            THEN
               l_warranty_flag := 'S';
            ELSIF p_kdtl_tbl (l_ctr).lse_id = 18
            THEN
               l_warranty_flag := 'W';
            ELSIF     p_kdtl_tbl (l_ctr).lse_id = 9
                  AND p_kdtl_tbl (l_ctr).scs_code = 'SUBSCRIPTION'
            THEN
               l_warranty_flag := 'SU';
            END IF;

            l_covd_rec.k_id := p_kdtl_tbl (l_ctr).hdr_id;
            l_covd_rec.attach_2_line_id := l_lineid;
            l_covd_rec.line_number := 1;
            l_covd_rec.customer_product_id := p_kdtl_tbl (l_ctr).new_cp_id;
            l_covd_rec.product_start_date := l_newsdt;
            l_covd_rec.product_end_date := TRUNC (l_newedt);
            l_covd_rec.quantity := p_kdtl_tbl (l_ctr).new_quantity;
            l_covd_rec.warranty_flag := l_warranty_flag;
            l_covd_rec.uom_code := p_kdtl_tbl (l_ctr).uom_code;
            l_covd_rec.currency_code := p_kdtl_tbl (l_ctr).service_currency;
            l_covd_rec.product_sts_code := p_kdtl_tbl (l_ctr).prod_sts_code;
            l_covd_rec.upg_orig_system_ref :=
                                        p_kdtl_tbl (l_ctr).upg_orig_system_ref;
            l_covd_rec.upg_orig_system_ref_id :=
                                     p_kdtl_tbl (l_ctr).upg_orig_system_ref_id;
            l_covd_rec.line_renewal_type :=
                                     p_kdtl_tbl (l_ctr).prod_line_renewal_type;
            l_covd_rec.prod_item_id := p_kdtl_tbl (l_ctr).new_inventory_item;
            l_covd_rec.price_uom := p_kdtl_tbl (l_ctr).price_uom_code;
            l_covd_rec.toplvl_uom_code := p_kdtl_tbl (l_ctr).toplvl_uom_code;
            --mchoudha added for bug#5233956
            l_covd_rec.toplvl_price_qty := p_kdtl_tbl (l_ctr).toplvl_price_qty;
            oks_extwarprgm_pvt.create_k_covered_levels
                                       (p_k_covd_rec         => l_covd_rec,
                                        p_price_attribs      => l_price_attribs_in,
                                        p_caller             => 'IB',
                                        x_order_error        => l_temp,
                                        x_covlvl_id          => l_covlvl_id,
                                        x_update_line        => l_update_line,
                                        x_return_status      => l_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data
                                       );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_event,
                      g_module_current
                   || '.CREATE_CONTRACT_IBREPLACE.create_cov_lvl',
                      'oks_extwarprgm_pvt.create_k_covered_levels(Return status = '
                   || l_return_status
                  );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            IF l_ste_code = 'ENTERED'
            THEN
               -- UPdate topline price negotiated.
               UPDATE okc_k_lines_b
                  SET price_negotiated = price_negotiated + l_newamt
                WHERE ID = l_lineid;

               -- Update header estimated amount
               UPDATE okc_k_headers_b
                  SET estimated_amount = estimated_amount + l_newamt
                WHERE ID = p_kdtl_tbl (l_ctr).hdr_id;

               -- Update topline tax amount
               UPDATE oks_k_lines_b
                  SET tax_amount = tax_amount + l_newtax
                WHERE cle_id = l_lineid;

               -- Update header tax amount
               UPDATE oks_k_headers_b
                  SET tax_amount = tax_amount + l_newtax
                WHERE chr_id = p_kdtl_tbl (l_ctr).hdr_id;
            END IF;

            l_inst_dtls_tbl (l_ctr1 + 1).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
            l_inst_dtls_tbl (l_ctr1 + 1).transaction_type := 'RPL';
            l_inst_dtls_tbl (l_ctr1 + 1).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (l_ctr1 + 1).instance_qty_old :=
                                               p_kdtl_tbl (l_ctr).new_quantity;
            l_inst_dtls_tbl (l_ctr1 + 1).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ctr1 + 1).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ctr1 + 1).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (l_ctr1 + 1).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (l_ctr1 + 1).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ctr1 + 1).old_k_status := l_sts_code;
            l_inst_dtls_tbl (l_ctr1 + 1).subline_date_terminated := NULL;
            l_inst_dtls_tbl (l_ctr1 + 1).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).new_cp_id;
            l_inst_dtls_tbl (l_ctr1 + 1).instance_amt_new :=
               oks_extwar_util_pvt.round_currency_amt
                                           (l_newamt,
                                            p_kdtl_tbl (l_ctr).service_currency
                                           );
            l_inst_dtls_tbl (l_ctr1 + 1).instance_qty_new :=
                                               p_kdtl_tbl (l_ctr).new_quantity;
            l_inst_dtls_tbl (l_ctr1 + 1).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ctr1 + 1).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ctr1 + 1).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ctr1 + 1).new_subline_id := l_covlvl_id;
            l_inst_dtls_tbl (l_ctr1 + 1).new_subline_start_date :=
                                           TRUNC (p_kdtl_tbl (l_ctr).prod_sdt);
            l_inst_dtls_tbl (l_ctr1 + 1).new_subline_end_date :=
                                                              TRUNC (l_newedt);
            l_inst_dtls_tbl (l_ctr1 + 1).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ctr1 + 1).new_k_status := l_sts_code;

            -------Billing Schedule
            IF p_kdtl_tbl (l_ctr).lse_id IN (9, 25)
            THEN                       -- added subscription contract category
               oks_bill_sch.adjust_replace_product_bs
                            (p_old_cp_id          => p_kdtl_tbl (l_ctr).object_line_id,
                             p_new_cp_id          => l_covlvl_id,
                             x_return_status      => l_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data
                            );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                         g_module_current
                      || '.CREATE_CONTRACT_IBREPLACE.OKS_BILL_SCH.ADJUST_REPLACE_PRODUCT_BS',
                         'ADJUST_REPLACE_PRODUCT_BS(Return status = '
                      || l_return_status
                     );
               END IF;

               IF NOT l_return_status = 'S'
               THEN
                  RAISE g_exception_halt_validation;
               END IF;
            END IF;

            l_create_oper_instance := 'N';

            IF    l_opr_instance_id IS NULL
               OR l_target_chr_id <> p_kdtl_tbl (l_ctr).hdr_id
            THEN
               l_target_chr_id := p_kdtl_tbl (l_ctr).hdr_id;
               l_create_oper_instance := 'Y';
            END IF;

            create_transaction_source
                        (p_create_opr_inst       => l_create_oper_instance,
                         p_source_code           => 'REPLACE',
                         p_target_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                         p_source_line_id        => p_kdtl_tbl (l_ctr).object_line_id,
                         p_source_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                         p_target_line_id        => l_covlvl_id,
                         x_oper_instance_id      => l_opr_instance_id,
                         x_return_status         => l_return_status,
                         x_msg_count             => x_msg_count,
                         x_msg_data              => x_msg_data
                        );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                     (fnd_log.level_event,
                         g_module_current
                      || '.CREATE_CONTRACT_IBREPLACE.Create_transaction_source',
                         'ADJUST_REPLACE_PRODUCT_BS(Return status = '
                      || l_return_status
                     );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            create_source_links
                            (p_create_opr_inst       => l_create_oper_instance,
                             p_source_code           => 'REPLACE',
                             p_target_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                             p_line_id               => p_kdtl_tbl (l_ctr).object_line_id,
                             p_target_line_id        => l_covlvl_id,
                             p_txn_date              => p_kdtl_tbl (l_ctr).transaction_date,
                             x_oper_instance_id      => l_renewal_opr_instance_id,
                             x_return_status         => l_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data
                            );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                           (fnd_log.level_event,
                               g_module_current
                            || '.CREATE_CONTRACT_IBREPLACE.Create_source_links',
                               'ADJUST_REPLACE_PRODUCT_BS(Return status = '
                            || l_return_status
                           );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            IF l_inst_dtls_tbl.COUNT <> 0
            THEN
               IF l_old_cp_id <> p_kdtl_tbl (l_ctr).old_cp_id
               THEN
                  OPEN l_refnum_csr (p_kdtl_tbl (l_ctr).old_cp_id);

                  FETCH l_refnum_csr
                   INTO l_ref_num;

                  CLOSE l_refnum_csr;

                  l_parameters :=
                        ' Old CP :'
                     || p_kdtl_tbl (l_ctr).old_cp_id
                     || ','
                     || 'Item Id:'
                     || p_kdtl_tbl (l_ctr).prod_inventory_item
                     || ','
                     || 'Old Quantity:'
                     || p_kdtl_tbl (l_ctr).current_cp_quantity
                     || ','
                     || 'Transaction type :'
                     || 'RPL'
                     || ','
                     || ' Transaction date :'
                     || TRUNC(p_kdtl_tbl (l_ctr).transaction_date)
                     || ','
                     || 'New CP:'
                     || p_kdtl_tbl (l_ctr).new_cp_id;
                  --oks_instance_history
                  l_old_cp_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.instance_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.transaction_type := 'RPL';
                  l_insthist_rec.transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                  l_insthist_rec.reference_number := l_ref_num;
                  l_insthist_rec.PARAMETERS := l_parameters;
                  oks_ins_pvt.insert_row (p_api_version        => 1.0,
                                          p_init_msg_list      => 'T',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_insv_rec           => l_insthist_rec,
                                          x_insv_rec           => x_insthist_rec
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_IBREPLACE',
                                    'oks_ins_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
                  END IF;

                  x_return_status := l_return_status;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;
                     RAISE g_exception_halt_validation;
                  END IF;

                  l_instparent_id := x_insthist_rec.ID;
               END IF;

               FOR i IN l_inst_dtls_tbl.FIRST .. l_inst_dtls_tbl.LAST
               LOOP
                  l_inst_dtls_tbl (i).ins_id := l_instparent_id;
               END LOOP;

               --oks_inst_history_details
               oks_ihd_pvt.insert_row (p_api_version        => 1.0,
                                       p_init_msg_list      => 'T',
                                       x_return_status      => l_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_ihdv_tbl           => l_inst_dtls_tbl,
                                       x_ihdv_tbl           => x_inst_dtls_tbl
                                      );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_K_IBREPLACE',
                                    'oks_ihd_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
               END IF;

               x_return_status := l_return_status;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  x_return_status := l_return_status;
                  RAISE g_exception_halt_validation;
               END IF;
            END IF;

            launch_workflow (   'INSTALL BASE ACTIVITY : REPLACE '
                             || fnd_global.local_chr (10)
                             || 'Contract Number       :         '
                             || get_contract_number (p_kdtl_tbl (l_ctr).hdr_id)
                             || fnd_global.local_chr (10)
                             || 'Old Cust Product      :         '
                             || p_kdtl_tbl (l_ctr).old_cp_id
                             || fnd_global.local_chr (10)
                             || 'Replaced Cust Product :         '
                             || p_kdtl_tbl (l_ctr).new_cp_id
                            );
            --END IF;
            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
            l_ctr1 := l_ctr1 + 2;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE create_contract_ibreturn (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_serv_csr (p_serv_id NUMBER)
      IS
         SELECT t.description NAME
           FROM mtl_system_items_tl t
          WHERE t.inventory_item_id = p_serv_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND ROWNUM < 2;

      CURSOR l_refnum_csr (p_cp_id NUMBER)
      IS
         SELECT instance_number
           FROM csi_item_instances
          WHERE instance_id = p_cp_id;

      Cursor l_hdr_sts_csr(p_hdr_id Number)
      Is
      Select sts_code
      From Okc_k_headers_all_b
      WHere id = p_hdr_id;

      l_hdr_status               Varchar2(240);

      l_ref_num                  VARCHAR2 (30);
      x_inst_dtls_tbl            oks_ihd_pvt.ihdv_tbl_type;
      l_inst_dtls_tbl            oks_ihd_pvt.ihdv_tbl_type;
      l_instparent_id            NUMBER;
      l_old_cp_id                NUMBER;
      l_insthist_rec             oks_ins_pvt.insv_rec_type;
      x_insthist_rec             oks_ins_pvt.insv_rec_type;
      l_parameters               VARCHAR2 (2000);
      l_price_attribs_in         oks_extwarprgm_pvt.pricing_attributes_type;
      --SalesCredit
      l_salescredit_tbl_line     oks_extwarprgm_pvt.salescredit_tbl;
      l_salescredit_tbl_hdr      oks_extwarprgm_pvt.salescredit_tbl;
      l_line_rec                 k_line_service_rec_type;
      l_covd_rec                 k_line_covered_level_rec_type;
      l_available_yn             CHAR;
      l_return_status            VARCHAR2 (5)     := okc_api.g_ret_sts_success;
      l_chrid                    NUMBER                                := NULL;
      l_lineid                   NUMBER                                := NULL;
      l_days                     NUMBER                                   := 0;
      l_day1price                NUMBER                                   := 0;
      l_oldamt                   NUMBER                                   := 0;
      l_ctr                      NUMBER                                   := 0;
      l_terminate_rec            okc_terminate_pvt.terminate_in_cle_rec;
      --Contract Line Table
      l_clev_tbl_in              okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out             okc_contract_pub.clev_tbl_type;
      l_api_version     CONSTANT NUMBER                                 := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)               := okc_api.g_false;
      l_retdt                    DATE;
      l_ste_code                 VARCHAR2 (30);
      l_sts_code                 VARCHAR2 (30);
      l_suppress_credit          VARCHAR2 (2)                           := 'N';
      l_chrv_tbl_in              okc_contract_pub.chrv_tbl_type;
      l_chrv_tbl_out             okc_contract_pub.chrv_tbl_type;
      l_full_credit              VARCHAR2 (2)                           := 'N';
      l_rnrl_rec_out             oks_renew_util_pvt.rnrl_rec_type;
      l_service_name             VARCHAR2 (2000);
      date_terminated            DATE;
      date_cancelled             DATE;
      l_alllines_terminated      VARCHAR2 (1);
      l_alllines_cancelled       VARCHAR2 (1);
      l_term_date_flag           VARCHAR2 (1);
      l_credit_amount            VARCHAR2 (30);
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;
      l_old_cp_id := 0;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.Create_Contract_IBRETURN.',
                         'count = ' || p_kdtl_tbl.COUNT || ')'
                        );
      END IF;

      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP

            get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).hdr_sts,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code = 'HOLD'
            THEN
               IF fnd_log.level_error >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_error,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBRETURN.ERROR',
                                     ' Contract '
                                  || p_kdtl_tbl (l_ctr).contract_number
                                  || ' in QA_HOLD status'
                                 );
               END IF;

               l_return_status := okc_api.g_ret_sts_error;
               okc_api.set_message (g_app_name,
                                    g_invalid_value,
                                    g_col_name_token,
                                       'Return not allowed. Contract '
                                    || p_kdtl_tbl (l_ctr).contract_number
                                    || 'is in QA_HOLD status'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
         END LOOP;
      END IF;

      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP
            --Fix for Bug 5406201
            l_clev_tbl_in.delete;
            l_chrv_tbl_in.delete;

            l_inst_dtls_tbl.DELETE;

            okc_context.set_okc_org_context
                                           (p_kdtl_tbl (l_ctr).hdr_org_id,
                                            p_kdtl_tbl (l_ctr).organization_id
                                           );
            get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).prod_sts_code,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code <> 'ENTERED'
            THEN
               l_retdt := p_kdtl_tbl (l_ctr).termination_date;

               IF (TRUNC (l_retdt) <= TRUNC (p_kdtl_tbl (l_ctr).prod_sdt))
               THEN
                  l_retdt := p_kdtl_tbl (l_ctr).prod_sdt;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBRETURN',
                                     'Credit option = '
                                  || p_kdtl_tbl (l_ctr).raise_credit
                                 );
               END IF;

               IF TRUNC (p_kdtl_tbl (l_ctr).prod_edt) < TRUNC (l_retdt)
               THEN
                  l_retdt := p_kdtl_tbl (l_ctr).prod_edt + 1;
                  l_suppress_credit := 'Y';
                  l_term_date_flag := 'Y';
               ELSE
                  IF UPPER (p_kdtl_tbl (l_ctr).raise_credit) = 'FULL'
                  THEN
                     l_full_credit := 'Y';
                     --l_retdt := p_kdtl_tbl( l_ctr ).prod_sdt;
                     l_suppress_credit := 'N';
                  ELSIF UPPER (p_kdtl_tbl (l_ctr).raise_credit) = 'NONE'
                  THEN
                     l_suppress_credit := 'Y';
                     l_full_credit := 'N';
                  ELSIF UPPER (p_kdtl_tbl (l_ctr).raise_credit) = 'CALCULATED'
                  THEN
                     l_suppress_credit := 'N';
                     l_full_credit := 'N';
                  ELSIF p_kdtl_tbl (l_ctr).raise_credit IS NULL
                  THEN
                     -- Get the credit option from gcd
                     l_credit_amount :=
                        oks_ib_util_pvt.get_credit_option
                                   (p_party_id              => p_kdtl_tbl
                                                                        (l_ctr).party_id,
                                    p_org_id                => p_kdtl_tbl
                                                                        (l_ctr).hdr_org_id,
                                    p_transaction_date      => TRUNC (l_retdt)
                                   );

                     IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.STRING (fnd_log.level_statement,
                                           g_module_current
                                        || '.CREATE_CONTRACT_IBRETURN',
                                           'Credit option from GCD = '
                                        || l_credit_amount
                                       );
                     END IF;

                     IF UPPER (l_credit_amount) = 'FULL'
                     THEN
                        l_full_credit := 'Y';
                        --l_retdt := p_kdtl_tbl( l_ctr ).prod_sdt;
                        l_suppress_credit := 'N';
                     ELSIF UPPER (l_credit_amount) = 'NONE'
                     THEN
                        l_suppress_credit := 'Y';
                        l_full_credit := 'N';
                     ELSIF l_credit_amount = 'CALCULATED'
                     THEN
                        l_suppress_credit := 'N';
                        l_full_credit := 'N';
                     END IF;
                  END IF;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBRETURN',
                                     'Suppress credit = '
                                  || l_suppress_credit
                                  || 'Full credit = '
                                  || l_full_credit
                                 );
               END IF;

               oks_bill_rec_pub.pre_terminate_cp
                                (p_calledfrom                => -1,
                                 p_cle_id                    => p_kdtl_tbl
                                                                        (l_ctr).object_line_id,
                                 p_termination_date          => TRUNC (l_retdt),
                                 p_terminate_reason          => 'RMA',
                                 p_override_amount           => NULL,
                                 p_con_terminate_amount      => NULL,
                                 p_termination_amount        => NULL,
                                 p_suppress_credit           => l_suppress_credit,
                                 --p_existing_credit               => 0,
                                 p_full_credit               => l_full_credit,
                                 p_term_date_flag            => l_term_date_flag,
                                 p_term_cancel_source        => 'IBRETURN',
                                 x_return_status             => l_return_status
                                );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                         g_module_current
                      || '.CREATE_CONTRACT_IBRETURN.terminate_cp',
                         'oks_bill_rec_pub.pre_terminate_cp(Return status = '
                      || l_return_status
                      || ')'
                     );
               END IF;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  RAISE g_exception_halt_validation;
               END IF;

               l_inst_dtls_tbl (1).subline_date_terminated := TRUNC (l_retdt);
               -- If all the sublines are terminated terminate the top line
               oks_ib_util_pvt.check_termcancel_lines
                                           (p_kdtl_tbl (l_ctr).service_line_id,
                                            'SL',
                                            'T',
                                            date_terminated
                                           );

               IF date_terminated IS NOT NULL
               THEN
                  get_sts_code ('TERMINATED', NULL, l_ste_code, l_sts_code);

                  l_clev_tbl_in (1).ID := p_kdtl_tbl (l_ctr).service_line_id;
                  l_clev_tbl_in (1).date_terminated := TRUNC (date_terminated);
                  l_clev_tbl_in (1).trn_code := 'RMA';
                  l_clev_tbl_in (1).term_cancel_source := 'IBRETURN';

                  If TRUNC (date_terminated)<= trunc(sysdate) Then
	                    l_clev_tbl_in (1).sts_code  := l_sts_code;
                  End If;

                  okc_contract_pub.update_contract_line
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_clev_tbl               => l_clev_tbl_in,
                                       x_clev_tbl               => l_clev_tbl_out
                                      );

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;

               date_terminated := NULL;
               -- If all the toplines are terminated, terminate the header
               oks_ib_util_pvt.check_termcancel_lines
                                                    (p_kdtl_tbl (l_ctr).hdr_id,
                                                     'TL',
                                                     'T',
                                                     date_terminated
                                                    );

               IF date_terminated IS NOT NULL
               THEN
                  get_sts_code ('TERMINATED', NULL, l_ste_code, l_sts_code);

                  l_chrv_tbl_in (1).ID := p_kdtl_tbl (l_ctr).hdr_id;
                  l_chrv_tbl_in (1).date_terminated := TRUNC (date_terminated);
                  l_chrv_tbl_in (1).trn_code := 'RMA';
                  l_chrv_tbl_in (1).term_cancel_source := 'IBRETURN';

                  If TRUNC (date_terminated)<= trunc(sysdate) Then
                        l_chrv_tbl_in (1).sts_code := l_sts_code;
                  End If;


                  okc_contract_pub.update_contract_header
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_chrv_tbl               => l_chrv_tbl_in,
                                       x_chrv_tbl               => l_chrv_tbl_out
                                      );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                            g_module_current
                         || '.CREATE_CONTRACT_IBRETURN.external_call.after',
                            'okc_contract_pub.update_contract_header(Return status =
                                                   '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;
            ELSIF l_ste_code = 'ENTERED'
            THEN
               l_retdt := p_kdtl_tbl (l_ctr).termination_date;

               IF TRUNC (p_kdtl_tbl (l_ctr).prod_edt) < TRUNC (l_retdt)
               THEN
                  l_retdt := p_kdtl_tbl (l_ctr).prod_edt + 1;
               END IF;

               --Cancel the the entered lines.

	      -- added for the bug # 6000133
	      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

               oks_change_status_pvt.update_line_status
                           (x_return_status           => l_return_status,
                            x_msg_data                => x_msg_data,
                            x_msg_count               => x_msg_count,
                            p_init_msg_list           => 'F',
                            p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                            p_cle_id                  => p_kdtl_tbl (l_ctr).object_line_id,
                            p_new_sts_code            => l_sts_code,
                            p_canc_reason_code        => 'RETURN',
                            p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                            p_old_ste_code            => 'ENTERED',
                            p_new_ste_code            => 'CANCELLED',
                            p_term_cancel_source      => 'IBRETURN',
                            p_date_cancelled          => TRUNC (l_retdt),
                            p_comments                => NULL,
                            p_validate_status         => 'N'
                           );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                      g_module_current || '.CREATE_CONTRACT_IBRETURN',
                         'oks_change_status_pvt.Update_line_status (Return status ='
                      || l_return_status
                      || ')'
                     );
               END IF;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  RAISE g_exception_halt_validation;
               END IF;

               l_inst_dtls_tbl (1).date_cancelled := TRUNC (l_retdt);
               date_cancelled := NULL;
               oks_ib_util_pvt.check_termcancel_lines
                                           (p_kdtl_tbl (l_ctr).service_line_id,
                                            'SL',
                                            'C',
                                            date_cancelled
                                           );

               IF date_cancelled IS NOT NULL
               THEN

	      -- added for the bug # 6000133
	      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

                  oks_change_status_pvt.update_line_status
                          (x_return_status           => l_return_status,
                           x_msg_data                => x_msg_data,
                           x_msg_count               => x_msg_count,
                           p_init_msg_list           => 'F',
                           p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                           p_cle_id                  => p_kdtl_tbl (l_ctr).service_line_id,
                           p_new_sts_code            => l_sts_code,
                           p_canc_reason_code        => 'RETURN',
                           p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                           p_old_ste_code            => 'ENTERED',
                           p_new_ste_code            => 'CANCELLED',
                           p_term_cancel_source      => 'IBRETURN',
                           p_date_cancelled          => TRUNC (date_cancelled),
                           p_comments                => NULL,
                           p_validate_status         => 'N'
                          );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                         g_module_current || '.CREATE_CONTRACT_IBRETURN',
                            'oks_change_status_pvt.Update_line_status (Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;

               date_cancelled := NULL;
               oks_ib_util_pvt.check_termcancel_lines
                                                    (p_kdtl_tbl (l_ctr).hdr_id,
                                                     'TL',
                                                     'C',
                                                     date_cancelled
                                                    );

               IF date_cancelled IS NOT NULL
               THEN

	      -- added for the bug # 6000133
	      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

                  oks_change_status_pvt.update_header_status
                          (x_return_status           => l_return_status,
                           x_msg_data                => x_msg_data,
                           x_msg_count               => x_msg_count,
                           p_init_msg_list           => 'F',
                           p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                           p_new_sts_code            => l_sts_code,
                           p_canc_reason_code        => 'RETURN',
                           p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                           p_comments                => NULL,
                           p_term_cancel_source      => 'IBRETURN',
                           p_date_cancelled          => TRUNC (date_cancelled),
                           p_validate_status         => 'N'
                          );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                         g_module_current || '.CREATE_CONTRACT_IBRETURN',
                            'OKS_WF_K_PROCESS_PVT.cancel_contract(Return status =
                                                    '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;
            END IF;

            get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).hdr_sts,
                          l_ste_code,
                          l_sts_code
                         );
            --x_inst_dtls_tbl(l_ctr).INST_PARENT_ID            := p_retn_rec.old_cp_id;
            l_inst_dtls_tbl (1).transaction_date := TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
            l_inst_dtls_tbl (1).transaction_type := 'RET';
            l_inst_dtls_tbl (1).system_id := NULL;
            l_inst_dtls_tbl (1).instance_id_new := NULL;
            l_inst_dtls_tbl (1).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
            l_inst_dtls_tbl (1).instance_qty_new :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
            l_inst_dtls_tbl (1).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (1).instance_amt_new :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (1).old_contract_id := p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (1).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (1).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (1).new_contract_id := p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (1).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (1).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (1).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (1).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (1).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (1).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (1).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (1).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (1).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (1).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (1).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (1).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (1).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (1).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (1).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (1).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (1).old_k_status := l_sts_code;
            l_inst_dtls_tbl (1).new_k_status := l_sts_code;

            IF l_inst_dtls_tbl.COUNT <> 0
            THEN
               IF     l_instparent_id IS NULL
                  AND l_old_cp_id <> p_kdtl_tbl (l_ctr).old_cp_id
               THEN
                  OPEN l_refnum_csr (p_kdtl_tbl (l_ctr).old_cp_id);

                  FETCH l_refnum_csr
                   INTO l_ref_num;

                  CLOSE l_refnum_csr;

                  l_parameters :=
                        ' Old CP :'
                     || p_kdtl_tbl (l_ctr).old_cp_id
                     || ','
                     || 'Item Id:'
                     || p_kdtl_tbl (l_ctr).prod_inventory_item
                     || ','
                     || 'Old Quantity:'
                     || p_kdtl_tbl (l_ctr).current_cp_quantity
                     || ','
                     || 'Transaction type :'
                     || 'RET'
                     || ','
                     || ' Transaction date :'
                     || TRUNC(p_kdtl_tbl (l_ctr).transaction_date)
                     || ','
                     || 'New quantity:'
                     || p_kdtl_tbl (l_ctr).new_quantity;
                  --oks_instance_history
                  l_old_cp_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.instance_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.transaction_type := 'RET';
                  l_insthist_rec.transaction_date := TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                  l_insthist_rec.reference_number := l_ref_num;
                  l_insthist_rec.PARAMETERS := l_parameters;
                  oks_ins_pvt.insert_row (p_api_version        => 1.0,
                                          p_init_msg_list      => 'T',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_insv_rec           => l_insthist_rec,
                                          x_insv_rec           => x_insthist_rec
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_K_IBRETURN',
                                    'oks_ins_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
                  END IF;

                  x_return_status := l_return_status;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;
                     RAISE g_exception_halt_validation;
                  END IF;

                  l_instparent_id := x_insthist_rec.ID;
               END IF;

               l_inst_dtls_tbl (1).ins_id := l_instparent_id;
               --oks_inst_history_details
               oks_ihd_pvt.insert_row (p_api_version        => 1.0,
                                       p_init_msg_list      => 'T',
                                       x_return_status      => l_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_ihdv_tbl           => l_inst_dtls_tbl,
                                       x_ihdv_tbl           => x_inst_dtls_tbl
                                      );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_IBRETURN',
                                    'oks_ihd_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
               END IF;

               x_return_status := l_return_status;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  x_return_status := l_return_status;
                  RAISE g_exception_halt_validation;
               END IF;

	       If date_terminated is not null or date_cancelled is not null Then
	    	    Open l_hdr_sts_csr(p_kdtl_tbl (l_ctr).hdr_id);
	            Fetch l_hdr_sts_csr into l_hdr_status;
	            Close l_hdr_sts_csr;

	            Update oks_inst_hist_details set new_k_status = l_hdr_status
		    Where ins_id = l_instparent_id and new_contract_id = p_kdtl_tbl (l_ctr).hdr_id;

               End If;
            END IF;

            OPEN l_serv_csr (p_kdtl_tbl (l_ctr).service_inventory_id);

            FETCH l_serv_csr
             INTO l_service_name;

            CLOSE l_serv_csr;

            launch_workflow (   'INSTALL BASE ACTIVITY : RETURN  '
                             || fnd_global.local_chr (10)
                             || 'Contract Number       :         '
                             || get_contract_number (p_kdtl_tbl (l_ctr).hdr_id)
                             || fnd_global.local_chr (10)
                             || 'Service Terminated    :         '
                             || l_service_name
                            );
            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
         END LOOP;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

---System Transfer
   PROCEDURE create_k_system_transfer (
      p_kdtl_tbl        IN              contract_trf_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_cov_csr (p_cle_id NUMBER)
      IS
         SELECT LN.transfer_option
           FROM oks_k_lines_b LN, okc_k_lines_b kl, oks_k_lines_b ks
          WHERE kl.ID = p_cle_id
            AND ks.cle_id = kl.ID
            AND LN.cle_id = ks.coverage_id;

      CURSOR l_contracts_csr (
         p_system_id   NUMBER,
         p_trxn_date   DATE,
         p_cust_id     NUMBER
      )
      IS
         SELECT DISTINCT new_contract_id
                    FROM oks_inst_hist_details
                   WHERE system_id = p_system_id
                     AND transaction_date = p_trxn_date
                     AND transaction_type = 'TRF'
                     AND old_customer = p_cust_id
                     AND new_contract_id <> old_contract_id;

      CURSOR l_qa_csr (p_id NUMBER)
      IS
         SELECT qcl_id
           FROM okc_k_headers_b
          WHERE ID = p_id;

      CURSOR l_hdrdt_csr (p_hdr_id NUMBER)
      IS
         SELECT start_date, end_date
           FROM okc_k_headers_b
          WHERE ID = p_hdr_id;

      CURSOR l_srvdt_csr (p_line_id NUMBER)
      IS
         SELECT start_date, end_date
           FROM okc_k_lines_b
          WHERE ID = p_line_id;

      CURSOR l_cust_rel_csr (
         p_old_customer    VARCHAR2,
         p_new_customer    VARCHAR2,
         p_relation        VARCHAR2,
         p_transfer_date   DATE
      )
      IS
         SELECT DISTINCT relationship_type
                    FROM hz_relationships
                   WHERE (   (    object_id = p_new_customer
                              AND subject_id = p_old_customer
                             )
                          OR (    object_id = p_old_customer
                              AND subject_id = p_new_customer
                             )
                         )
                     AND relationship_type = p_relation
                     AND status = 'A'
                     AND TRUNC (p_transfer_date) BETWEEN TRUNC (start_date)
                                                     AND TRUNC (end_date);

      CURSOR l_hdr_sts_csr (p_hdr_id NUMBER)
      IS
         SELECT sts_code
           FROM okc_k_headers_b
          WHERE ID = p_hdr_id;


      CURSOR l_Launch_WF_csr (p_hdr_id NUMBER)
      IS
         SELECT 'Y'
           FROM okc_k_headers_b Kh, oks_k_headers_b Ks
                , okc_statuses_b sts
          WHERE Kh.ID = p_hdr_id
          And   Ks.chr_id = Kh.id
          And kh.sts_code = sts.code
          And sts.ste_code = 'ENTERED'
          And ks.wf_item_key is null;
      l_launch_wf_yn Varchar2(1);

      CURSOR l_subline_csr (p_id NUMBER)
      IS
         SELECT date_terminated, price_negotiated
           FROM okc_k_lines_b
          WHERE ID = p_id;

      l_date_terminated           DATE;
      l_subline_price             NUMBER;
      l_hdr_sts                   VARCHAR2 (40);

      CURSOR l_toplines_csr (p_chr_id NUMBER, p_service_item_id NUMBER)
      IS
         SELECT kl.ID cle_id
           FROM okc_k_lines_b kl, okc_k_items ki, okc_statuses_b st
          WHERE kl.dnz_chr_id = p_chr_id
            AND kl.lse_id IN (1, 14, 19)
            AND kl.ID = ki.cle_id
            AND ki.object1_id1 = TO_CHAR (p_service_item_id)
            AND st.code = kl.sts_code
            AND st.ste_code NOT IN ('TERMINATED', 'CANCELLED');

      l_cov_rec                   l_cov_csr%ROWTYPE;

      CURSOR l_refnum_csr (p_cp_id NUMBER)
      IS
         SELECT instance_number
           FROM csi_item_instances
          WHERE instance_id = p_cp_id;

      CURSOR l_serv_csr (p_serv_id NUMBER)
      IS
         SELECT t.description NAME
           FROM mtl_system_items_tl t
          WHERE t.inventory_item_id = p_serv_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND ROWNUM < 2;

      l_start_date                DATE;
      l_end_date                  DATE;
      l_subline_id                NUMBER;
      l_renewal_id                NUMBER;
      l_source_line_id            NUMBER;
      l_transfer_id               NUMBER;
      l_srv_sdt                   DATE;
      l_srv_edt                   DATE;
      l_coverage_id               NUMBER;
      l_service_name              VARCHAR2 (240);
      l_ref_num                   VARCHAR2 (30);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2 (2000);
      l_trf_option                VARCHAR2 (40);
      l_contact_tbl_in            oks_extwarprgm_pvt.contact_tbl;
      l_salescredit_tbl_line      oks_extwarprgm_pvt.salescredit_tbl;
      l_salescredit_tbl_hdr       oks_extwarprgm_pvt.salescredit_tbl;
      l_line_rec                  oks_extwarprgm_pvt.k_line_service_rec_type;
      l_covd_rec                  oks_extwarprgm_pvt.k_line_covered_level_rec_type;
--l_kdtl_tbl                oks_extwar_util_pvt.contract_tbl_type;
      l_available_yn              CHAR;
      l_return_status             VARCHAR2 (5)    := okc_api.g_ret_sts_success;
      l_line_found                VARCHAR2 (1);
      l_ste_code                  VARCHAR2 (40);
      l_sts_code                  VARCHAR2 (40);
      l_ctr                       NUMBER;
      l_suppress_credit           VARCHAR2 (10)                         := 'N';
      l_trfdt                     DATE;
      l_clev_tbl_in               okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out              okc_contract_pub.clev_tbl_type;
      l_api_version      CONSTANT NUMBER                                := 1.0;
      l_init_msg_list    CONSTANT VARCHAR2 (1)                          := 'F';
      l_index                     NUMBER;
      l_relationship              VARCHAR2 (40);
      l_relationship_type         VARCHAR2 (40);
      l_chr_id                    NUMBER;
      l_contract_exist            VARCHAR2 (1);
      l_contract_merge            VARCHAR2 (1);
      l_ptr                       NUMBER                                  := 0;
      l_old_cp_id                 NUMBER;
      l_line_id                   NUMBER;
      l_header_merge              VARCHAR2 (1);
      l_line_merge                VARCHAR2 (1);
      l_merge_chr_id              NUMBER;
      l_merge_line_id             NUMBER;
      l_max_severity              VARCHAR2 (1);
      l_msg_tbl                   okc_qa_check_pub.msg_tbl_type;
      l_covlvl_id                 NUMBER;
      i                           NUMBER;
      l_qcl_id                    NUMBER;
      l_update_line               VARCHAR2 (1);
      l_inst_dtls_tbl             oks_ihd_pvt.ihdv_tbl_type;
      x_inst_dtls_tbl             oks_ihd_pvt.ihdv_tbl_type;
      l_insthist_rec              oks_ins_pvt.insv_rec_type;
      x_insthist_rec              oks_ins_pvt.insv_rec_type;
      l_instparent_id             NUMBER;
      l_parameters                VARCHAR2 (2000);
      l_temp                      VARCHAR2 (2000);
      l_old_party_id              NUMBER;
      l_new_party_id              NUMBER;
      l_new_party_name            VARCHAR2 (360);
      l_old_party_name            VARCHAR2 (360);
      date_terminated             DATE;
      date_cancelled              DATE;
      l_chrv_tbl_in               okc_contract_pub.chrv_tbl_type;
      l_chrv_tbl_out              okc_contract_pub.chrv_tbl_type;
      l_create_contract           VARCHAR2 (1);
      l_party_id                  NUMBER;
      l_party_name                VARCHAR2 (360);
      l_opr_instance_id           NUMBER;
      l_renewal_opr_instance_id   NUMBER;
      l_term_date_flag            VARCHAR2 (1);
      l_wf_attr_details           oks_wf_k_process_pvt.wf_attr_details;
      l_create_oper_instance      VARCHAR2 (1);
      l_credit_amount             VARCHAR2 (50);
      l_full_credit               VARCHAR2 (10)                         := 'N';

      FUNCTION get_operation_instance (
         p_target_chr_id      NUMBER,
         p_transaction_type   VARCHAR2
      )
         RETURN NUMBER
      IS
         CURSOR l_operation_csr
         IS
            SELECT op.ID
              FROM okc_operation_instances op,
                   okc_class_operations classopr,
                   okc_subclasses_b subclass
             WHERE target_chr_id = p_target_chr_id
               AND subclass.code = 'SERVICE'
               AND classopr.cls_code = subclass.cls_code
               AND classopr.opn_code IN ('TRANSFER')
               AND op.cop_id = classopr.ID;

         CURSOR l_renewal_csr
         IS
            SELECT op.ID
              FROM okc_operation_instances op,
                   okc_class_operations classopr,
                   okc_subclasses_b subclass
             WHERE target_chr_id = p_target_chr_id
               AND subclass.code = 'SERVICE'
               AND classopr.cls_code = subclass.cls_code
               AND classopr.opn_code IN ('RENEWAL', 'REN_CON')
               AND op.cop_id = classopr.ID;

/*
Select id
From   Okc_operation_instances
Where  target_chr_id = p_target_chr_id
And    cop_id in (40,41);
*/
         l_oper_inst_id   NUMBER;
      BEGIN
         IF p_transaction_type = 'TRF'
         THEN
            OPEN l_operation_csr;

            FETCH l_operation_csr
             INTO l_oper_inst_id;

            CLOSE l_operation_csr;
         ELSE
            OPEN l_renewal_csr;

            FETCH l_renewal_csr
             INTO l_oper_inst_id;

            CLOSE l_renewal_csr;
         END IF;

         RETURN (l_oper_inst_id);
      END;

      PROCEDURE get_party_id (
         p_cust_id      IN              NUMBER,
         x_party_id     OUT NOCOPY      NUMBER,
         x_party_name   OUT NOCOPY      VARCHAR2
      )
      IS
         CURSOR l_party_csr
         IS
            SELECT party_id, NAME
              FROM okx_customer_accounts_v
             WHERE id1 = p_cust_id;
      BEGIN
         OPEN l_party_csr;

         FETCH l_party_csr
          INTO x_party_id, x_party_name;

         CLOSE l_party_csr;
      EXCEPTION
         WHEN OTHERS
         THEN
            x_return_status := okc_api.g_ret_sts_unexp_error;
            okc_api.set_message (g_app_name,
                                 g_unexpected_error,
                                 g_sqlcode_token,
                                 SQLCODE,
                                 g_sqlerrm_token,
                                 SQLERRM
                                );
      END;

      FUNCTION site_address (
         p_customer_id   NUMBER,
         p_party_id      NUMBER,
         p_code          VARCHAR2,
         p_org_id        NUMBER
      )
         RETURN NUMBER
      IS
         CURSOR l_address_csr
         IS
            SELECT id1
              FROM okx_cust_site_uses_v
             WHERE cust_account_id = p_customer_id
               AND party_id = p_party_id
               AND site_use_code = p_code
               AND identifying_address_flag = 'Y'
               AND status = 'A'
               AND org_id = p_org_id;

         l_site_id   NUMBER;
      BEGIN
         OPEN l_address_csr;

         FETCH l_address_csr
          INTO l_site_id;

         IF l_address_csr%NOTFOUND
         THEN
            CLOSE l_address_csr;

            RETURN (NULL);
         END IF;

         CLOSE l_address_csr;

         RETURN (l_site_id);
      END;

      PROCEDURE create_contract_header (
         p_kdtl_rec        IN              contract_trf_rec,
         x_msg_data        OUT NOCOPY      VARCHAR2,
         x_chr_id          OUT NOCOPY      NUMBER,
         x_msg_count       OUT NOCOPY      NUMBER,
         x_return_status   OUT NOCOPY      VARCHAR2
      )
      IS
         l_agrment_id        NUMBER;
         l_ste_code          VARCHAR2 (40);
         l_sts_code          VARCHAR2 (40);

         CURSOR l_party_csr (p_id NUMBER)
         IS
            SELECT party_id, NAME
              FROM okx_customer_accounts_v
             WHERE id1 = p_id;

         CURSOR l_get_agrid_csr (p_chr_id NUMBER)
         IS
            SELECT isa_agreement_id
              FROM okc_governances
             WHERE chr_id = p_chr_id AND dnz_chr_id = p_chr_id;

-- Fix for bug 3588355
         CURSOR l_get_bill_ship_csr (p_cp_id NUMBER)
         IS
            SELECT bill_to_address, ship_to_address
              FROM csi_instance_party_v
             WHERE instance_id = p_cp_id;

-- Fix for bug 3588355
         CURSOR validate_bill_ship_ids (
            p_id              NUMBER,
            p_org_id          NUMBER,
            p_site_use_code   VARCHAR2
         )
         IS
            SELECT 'x'
              FROM okx_cust_site_uses_v
             WHERE id1 = p_id
               AND site_use_code = p_site_use_code
               AND org_id = p_org_id
               AND status = 'A';

         CURSOR l_access_csr (p_hdr_id NUMBER)
         IS
            SELECT resource_id, GROUP_ID, access_level
              FROM okc_k_accesses_v
             WHERE chr_id = p_hdr_id;

         l_hdr_rec           k_header_rec_type;
         l_party_id          NUMBER;
         l_party_name        VARCHAR2 (360);
         l_return_status     VARCHAR2 (1);
         l_rnrl_rec_out      oks_renew_util_pvt.rnrl_rec_type;
         p_contact_tbl_in    oks_extwarprgm_pvt.contact_tbl;
         l_chrid             NUMBER;
         l_cacv_tbl_in       okc_contract_pub.cacv_tbl_type;
         l_cacv_tbl_out      okc_contract_pub.cacv_tbl_type;
         l_status            VARCHAR2 (40);
         l_bill_to_id        NUMBER;
         l_ship_to_id        NUMBER;
         l_valid             VARCHAR2 (1);
         l_resource_id       NUMBER;
         l_group_id          NUMBER;
         l_access_level      VARCHAR2 (3);
         l_sc_hdr_ctr        NUMBER;
         l_salescredit_tbl   oks_extwarprgm_pvt.salescredit_tbl;
         l_org_id            NUMBER;

         CURSOR l_sales_credit_hdr_csr (p_chr_id NUMBER)
         IS
            SELECT ctc_id, sales_credit_type_id1, PERCENT, sales_group_id
              FROM oks_k_sales_credits_v
             WHERE chr_id = p_chr_id AND cle_id IS NULL;
      BEGIN
         x_return_status := okc_api.g_ret_sts_success;

         OPEN l_get_agrid_csr (p_kdtl_rec.hdr_id);              --07-May-2003

         FETCH l_get_agrid_csr
          INTO l_agrment_id;

         CLOSE l_get_agrid_csr;

         l_hdr_rec.billed_at_source := p_kdtl_rec.billed_at_source;

         get_party_id (p_kdtl_rec.new_account_id, l_party_id, l_party_name);
         l_hdr_rec.party_id := l_party_id;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                            || '.CREATE_K_SYSTEM_TRF.create_contract_header',
                            'Party id = ' || l_hdr_rec.party_id
                           );
         END IF;

         oks_renew_util_pub.get_renew_rules
                                          (p_api_version        => 1.0,
                                           p_init_msg_list      => 'T',
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => NULL,
                                           p_party_id           => l_hdr_rec.party_id,
                                           p_org_id             => p_kdtl_rec.hdr_org_id,
                                           p_date               => SYSDATE,
                                           p_rnrl_rec           => NULL,
                                           x_rnrl_rec           => l_rnrl_rec_out
                                          );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                    (fnd_log.level_event,
                        g_module_current
                     || '.CREATE_K_SYSTEM_TRF.create_contract_header',
                        'oks_renew_util_pub.get_renew_rules(Return status = '
                     || l_return_status
                    );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
            RAISE g_exception_halt_validation;
         END IF;

         l_hdr_rec.scs_code := p_kdtl_rec.scs_code;

         IF p_kdtl_rec.scs_code = 'WARRANTY'
         THEN
            l_hdr_rec.short_description :=
                  'CUSTOMER : '
               || l_party_name
               || ' Warranty/Extended Warranty Contract';
         ELSE
            l_hdr_rec.short_description :=
                                'CUSTOMER : ' || l_party_name || '  Contract';
         END IF;

         l_hdr_rec.start_date := TRUNC (l_trfdt);

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                            || '.CREATE_K_SYSTEM_TRF.create_contract_header',
                               'Transfer status Profile = '
                            || fnd_profile.VALUE ('OKS_TRANSFER_STATUS')
                           );
         END IF;

         IF (p_kdtl_rec.scs_code = 'WARRANTY' AND p_kdtl_rec.lse_id = 18)
         THEN
            IF l_hdr_rec.start_date > SYSDATE
            THEN
               get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
            ELSE
               get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
            END IF;

            l_hdr_rec.sts_code := l_sts_code;
            l_hdr_rec.renewal_status := 'COMPLETE';
            l_hdr_rec.accounting_rule_id := null;
            l_hdr_rec.invoice_rule_id := Null;
            l_hdr_rec.qcl_id := Null;
            l_hdr_rec.pdf_id := Null;
            l_hdr_rec.ar_interface_yn := 'N';

         ELSE
            l_hdr_rec.accounting_rule_id := p_kdtl_rec.hdr_acct_rule_id;
            l_hdr_rec.invoice_rule_id := -2;
            l_hdr_rec.qcl_id := l_rnrl_rec_out.qcl_id;
            l_hdr_rec.pdf_id := l_rnrl_rec_out.pdf_id;
            l_hdr_rec.ar_interface_yn := p_kdtl_rec.ar_interface_yn;


            get_sts_code (p_kdtl_rec.prod_sts_code,
                          NULL,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code = 'ENTERED'
            THEN
               l_hdr_rec.sts_code := l_sts_code;
            ELSE
               l_status := fnd_profile.VALUE ('OKS_TRANSFER_STATUS');

               IF l_status = 'ACTIVE'
               THEN
                  IF l_hdr_rec.start_date > SYSDATE
                  THEN
                     get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
                  ELSE
                     get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
                  END IF;

                  l_hdr_rec.renewal_status := 'COMPLETE';
               ELSE
                  get_sts_code (l_status, NULL, l_ste_code, l_sts_code);
               END IF;

               l_hdr_rec.sts_code := l_sts_code;
            END IF;
         END IF;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                            || '.CREATE_K_SYSTEM_TRF.create_contract_header',
                               'Header Status = '
                            || l_hdr_rec.sts_code
                            || 'End date = '
                            || l_hdr_rec.end_date
                            || 'Start Date = '
                            || l_hdr_rec.start_date
                           );
         END IF;

         -- Fix for bug 3588355 Begin
         OPEN l_get_bill_ship_csr (p_kdtl_rec.old_cp_id);

         FETCH l_get_bill_ship_csr
          INTO l_bill_to_id, l_ship_to_id;

         CLOSE l_get_bill_ship_csr;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                            || '.CREATE_K_SYSTEM_TRF.create_contract_header',
                               ' Bill to Id = '
                            || l_bill_to_id
                            || 'Ship to Id = '
                            || l_ship_to_id
                           );
         END IF;

         IF (l_bill_to_id IS NOT NULL)
         THEN
            OPEN validate_bill_ship_ids (l_bill_to_id,
                                         p_kdtl_tbl (l_ctr).hdr_org_id,
                                         'BILL_TO'
                                        );

            FETCH validate_bill_ship_ids
             INTO l_valid;

            IF validate_bill_ship_ids%NOTFOUND
            THEN
               CLOSE validate_bill_ship_ids;

               IF fnd_log.level_error >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_error,
                                     g_module_current
                                  || '.CREATE_K_SYSTEM_TRF.ERROR',
                                     ' Bill to Id ('
                                  || l_bill_to_id
                                  || ') is not valid'
                                 );
               END IF;

               l_return_status := okc_api.g_ret_sts_error;
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Bill to id is not Valid'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            CLOSE validate_bill_ship_ids;
         END IF;

         IF (l_ship_to_id IS NOT NULL)
         THEN
            OPEN validate_bill_ship_ids (l_ship_to_id,
                                         p_kdtl_rec.hdr_org_id,
                                         'SHIP_TO'
                                        );

            FETCH validate_bill_ship_ids
             INTO l_valid;

            IF validate_bill_ship_ids%NOTFOUND
            THEN
               CLOSE validate_bill_ship_ids;

               IF fnd_log.level_error >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_error,
                                     g_module_current
                                  || '.CREATE_K_SYSTEM_TRF.ERROR',
                                     ' Bill to Id ('
                                  || l_ship_to_id
                                  || ') is not valid'
                                 );
               END IF;

               l_return_status := okc_api.g_ret_sts_error;
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Ship to id is not Valid'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            CLOSE validate_bill_ship_ids;
         END IF;

         l_hdr_rec.bill_to_id :=
            NVL (l_bill_to_id,
                 site_address (p_kdtl_rec.new_account_id,
                               l_hdr_rec.party_id,
                               'BILL_TO',
                               p_kdtl_rec.hdr_org_id
                              )
                );
         l_hdr_rec.ship_to_id :=
            NVL (l_ship_to_id,
                 site_address (p_kdtl_rec.new_account_id,
                               l_hdr_rec.party_id,
                               'SHIP_TO',
                               p_kdtl_rec.hdr_org_id
                              )
                );
         -- Fix for bug 3588355 End
         l_hdr_rec.order_line_id := NULL;
         l_hdr_rec.contract_number := okc_api.g_miss_char;
         l_hdr_rec.rty_code := 'CONTRACTTRANSFERORDER';
         --l_hdr_rec.start_date                        := trunc(l_trfdt);
         l_hdr_rec.end_date := p_kdtl_rec.service_edt;
         l_hdr_rec.class_code := 'SVC';
         l_hdr_rec.authoring_org_id := p_kdtl_rec.hdr_org_id;
         l_hdr_rec.inv_organization_id := p_kdtl_rec.organization_id;
         l_hdr_rec.chr_group := l_rnrl_rec_out.cgp_new_id;
         l_hdr_rec.price_list_id := p_kdtl_rec.price_list_id;
         l_hdr_rec.agreement_id := l_agrment_id;
         l_hdr_rec.currency := p_kdtl_rec.header_currency;
         --p_kdtl_rec.hdr_inv_rule_id; --fix for bug 3451440
         l_hdr_rec.payment_type := p_kdtl_rec.payment_type;
         l_hdr_rec.inv_trx_type := p_kdtl_rec.inv_trx_type;
         l_hdr_rec.hold_billing := p_kdtl_rec.hold_billing;
         --mmadhavi for bug 3765672
         l_hdr_rec.summary_trx_yn := p_kdtl_rec.summary_trx_yn;
         --mmadhavi for bug 3765672
         l_hdr_rec.order_hdr_id := NULL;
         l_hdr_rec.payment_term_id := p_kdtl_rec.payment_term_id;
         l_hdr_rec.cvn_type := p_kdtl_rec.cvn_type;
         l_hdr_rec.cvn_rate := p_kdtl_rec.cvn_rate;
         l_hdr_rec.cvn_date := p_kdtl_rec.cvn_date;
         l_hdr_rec.cvn_euro_rate := p_kdtl_rec.cvn_euro_rate;
         l_hdr_rec.merge_type := 'NEW';
         l_hdr_rec.period_start := p_kdtl_rec.period_start;
         l_hdr_rec.period_type := p_kdtl_rec.period_type;
         l_hdr_rec.price_uom := p_kdtl_rec.price_uom_hdr;
         l_sc_hdr_ctr := 0;

         FOR l_sales_credit_hdr_rec IN
            l_sales_credit_hdr_csr (p_kdtl_rec.hdr_id)
         LOOP
            l_sc_hdr_ctr := l_sc_hdr_ctr + 1;
            l_salescredit_tbl (l_sc_hdr_ctr).ctc_id :=
                                                l_sales_credit_hdr_rec.ctc_id;
            l_salescredit_tbl (l_sc_hdr_ctr).sales_credit_type_id :=
                                 l_sales_credit_hdr_rec.sales_credit_type_id1;
            l_salescredit_tbl (l_sc_hdr_ctr).PERCENT :=
                                               l_sales_credit_hdr_rec.PERCENT;
            l_salescredit_tbl (l_sc_hdr_ctr).sales_group_id :=
                                        l_sales_credit_hdr_rec.sales_group_id;
         END LOOP;             -- For l_sales_credit_rec IN l_sales_credit_csr

         oks_extwarprgm_pvt.create_k_hdr
                                   (p_k_header_rec            => l_hdr_rec,
                                    p_contact_tbl             => p_contact_tbl_in,
                                    p_salescredit_tbl_in      => l_salescredit_tbl
                                                                                  -- mmadhavi bug 4174921
         ,
                                    p_caller                  => 'ST',
                                    x_order_error             => l_temp,
                                    x_chr_id                  => l_chrid,
                                    x_return_status           => l_return_status,
                                    x_msg_count               => x_msg_count,
                                    x_msg_data                => x_msg_data
                                   );

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING
                       (fnd_log.level_statement,
                           g_module_current
                        || '.CREATE_K_SYSTEM_TRF.create_contract_header',
                           'OKS_EXTWARPRGM_PVT.create_k_hdr(Return status = '
                        || l_return_status
                        || ')'
                       );
         END IF;

         IF NOT l_return_status = 'S'
         THEN
            RAISE g_exception_halt_validation;
         ELSE
            x_chr_id := l_chrid;
         END IF;

         SELECT authoring_org_id
           INTO l_org_id
           FROM okc_k_headers_b
          WHERE ID = l_chrid;

         OPEN l_access_csr (p_kdtl_rec.hdr_id);

         FETCH l_access_csr
          INTO l_resource_id, l_group_id, l_access_level;

         CLOSE l_access_csr;

         IF l_resource_id IS NOT NULL OR l_group_id IS NOT NULL
         THEN
            l_cacv_tbl_in (1).chr_id := l_chrid;
            l_cacv_tbl_in (1).resource_id := l_resource_id;
            l_cacv_tbl_in (1).GROUP_ID := l_group_id;
            l_cacv_tbl_in (1).access_level := l_access_level;
            okc_contract_pub.create_contract_access
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => l_init_msg_list,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_cacv_tbl           => l_cacv_tbl_in,
                                          x_cacv_tbl           => l_cacv_tbl_out
                                         );

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING
                  (fnd_log.level_statement,
                      g_module_current
                   || '.CREATE_K_SYSTEM_TRF.create_contract_header',
                      'okc_contract_pub.create_contract_access(Return status = '
                   || l_return_status
                   || ')'
                  );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;
         END IF;

         x_return_status := l_return_status;
      EXCEPTION
         WHEN g_exception_halt_validation
         THEN
            x_return_status := l_return_status;
            NULL;
         WHEN OTHERS
         THEN
            x_return_status := okc_api.g_ret_sts_unexp_error;
            okc_api.set_message (g_app_name,
                                 g_unexpected_error,
                                 g_sqlcode_token,
                                 SQLCODE,
                                 g_sqlerrm_token,
                                 SQLERRM
                                );
      END create_contract_header;

      PROCEDURE create_contract_line (
         p_kdtl_rec        IN              contract_trf_rec,
         p_hdr_id          IN              NUMBER,
         x_return_status   OUT NOCOPY      VARCHAR2,
         x_msg_data        OUT NOCOPY      VARCHAR2,
         x_line_id         OUT NOCOPY      NUMBER,
         x_msg_count       OUT NOCOPY      NUMBER
      )
      IS
         CURSOR l_line_rule_csr (p_line_id NUMBER)
         IS
            SELECT oks.acct_rule_id, okc.inv_rule_id, okc.price_list_id
              FROM okc_k_lines_b okc, oks_k_lines_b oks
             WHERE okc.ID = p_line_id AND oks.cle_id = okc.ID;

         CURSOR l_party_csr (p_id NUMBER)
         IS
            SELECT party_id, NAME
              FROM okx_customer_accounts_v
             WHERE id1 = p_id;

         CURSOR l_hdr_sts_csr (p_hdr_id NUMBER)
         IS
            SELECT st.ste_code, kh.sts_code
              FROM okc_k_headers_b kh, okc_statuses_b st
             WHERE kh.ID = p_hdr_id AND st.code = kh.sts_code;

-- Fix for bug 3588355
         CURSOR l_get_bill_ship_csr (p_cp_id NUMBER)
         IS
            SELECT bill_to_address, ship_to_address
              FROM csi_instance_party_v
             WHERE instance_id = p_cp_id;

         CURSOR l_serv_csr (p_serv_id NUMBER)
         IS
         SELECT  DECODE (fnd_profile.VALUE ('OKS_ITEM_DISPLAY_PREFERENCE'), 'DISPLAY_DESC', t.description , b.concatenated_segments )
           FROM mtl_system_items_b_kfv b, mtl_system_items_tl t
          WHERE b.inventory_item_id = t.inventory_item_id
            AND b.organization_id = t.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND b.inventory_item_id = p_serv_id
            AND ROWNUM < 2;

         l_line_rec          k_line_service_rec_type;
         l_acct_id           NUMBER;
         l_inv_id            NUMBER;
         l_party_id          NUMBER;
         l_party_name        VARCHAR2 (360);
         l_ste_code          VARCHAR2 (40);
         l_sts_code          VARCHAR2 (40);
         l_hdr_sts_code      VARCHAR2 (40);
         l_hdr_ste_code      VARCHAR2 (40);
         l_lineid            NUMBER;
         l_return_status     VARCHAR2 (10);
         l_price_list_id     NUMBER;
         p_contact_tbl_in    oks_extwarprgm_pvt.contact_tbl;
         l_status            VARCHAR2 (40);
         l_bill_to_id        NUMBER;
         l_ship_to_id        NUMBER;
         l_warranty_flag     VARCHAR2 (2);

         CURSOR l_sales_credit_csr (p_cle_id NUMBER)
         IS
            SELECT ctc_id, sales_credit_type_id1, PERCENT, sales_group_id
              FROM oks_k_sales_credits_v
             WHERE cle_id = p_cle_id;

         l_sc_ctr            NUMBER;
         l_salescredit_tbl   oks_extwarprgm_pvt.salescredit_tbl;
      BEGIN
         x_return_status := okc_api.g_ret_sts_success;

         OPEN l_line_rule_csr (p_kdtl_rec.service_line_id);

         FETCH l_line_rule_csr
          INTO l_acct_id, l_inv_id, l_price_list_id;

         CLOSE l_line_rule_csr;

         get_party_id (p_kdtl_rec.new_account_id, l_party_id, l_party_name);

         OPEN l_get_bill_ship_csr (p_kdtl_rec.old_cp_id);

         FETCH l_get_bill_ship_csr
          INTO l_bill_to_id, l_ship_to_id;

         CLOSE l_get_bill_ship_csr;

         l_line_rec.k_id := p_hdr_id;
         l_line_rec.k_line_number := okc_api.g_miss_char;
         l_line_rec.org_id := p_kdtl_rec.hdr_org_id;
         l_line_rec.accounting_rule_id := l_acct_id;
         l_line_rec.invoicing_rule_id := -2;
         --l_inv_id; -- fix for bug 3451440
         l_line_rec.srv_id := p_kdtl_rec.service_inventory_id;
         --  l_line_rec.srv_segment1           := p_kdtl_rec.service_name;
         --  l_line_rec.srv_desc               := p_kdtl_rec.service_description;

         OPEN l_serv_csr (p_kdtl_rec.service_inventory_id);
         FETCH l_serv_csr  INTO l_line_rec.srv_desc;
         CLOSE l_serv_csr;

         l_line_rec.srv_sdt := TRUNC (l_trfdt);
         l_line_rec.srv_edt := TRUNC (p_kdtl_rec.service_edt);

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                            || '.CREATE_K_SYSTEM_TRF.create_k_service_line',
                               'Start date = '
                            || l_line_rec.srv_sdt
                            || 'End date = '
                            || l_line_rec.srv_edt
                           );
         END IF;

         --to be derived
         l_line_rec.bill_to_id :=
            NVL (l_bill_to_id,
                 site_address (p_kdtl_rec.new_account_id,
                               l_party_id,
                               'BILL_TO',
                               p_kdtl_rec.hdr_org_id
                              )
                );
         l_line_rec.ship_to_id :=
            NVL (l_ship_to_id,
                 site_address (p_kdtl_rec.new_account_id,
                               l_party_id,
                               'SHIP_TO',
                               p_kdtl_rec.hdr_org_id
                              )
                );

         IF p_kdtl_rec.lse_id = 25
         THEN
            l_warranty_flag := 'E';
         ELSIF p_kdtl_rec.lse_id = 9 AND p_kdtl_rec.scs_code = 'SERVICE'
         THEN
            l_warranty_flag := 'S';
         ELSIF p_kdtl_rec.lse_id = 18
         THEN
            l_warranty_flag := 'W';
         ELSIF p_kdtl_rec.lse_id = 9 AND p_kdtl_rec.scs_code = 'SUBSCRIPTION'
         THEN
            l_warranty_flag := 'SU';
         END IF;

         l_line_rec.warranty_flag := l_warranty_flag;
         l_line_rec.currency := p_kdtl_rec.service_currency;
         --Fix for Bug4121175
         l_line_rec.tax_code := p_kdtl_rec.tax_code;
         --End Fix for Bug4121175
         l_line_rec.cust_account := p_kdtl_rec.new_account_id;
         l_line_rec.ln_price_list_id := l_price_list_id;
         l_line_rec.coverage_id := p_kdtl_rec.coverage_id;
         l_line_rec.coverage_template_id := p_kdtl_rec.coverage_id;
         l_line_rec.standard_cov_yn := p_kdtl_rec.standard_cov_yn;
         l_line_rec.price_uom := p_kdtl_rec.price_uom_tl;

         --l_line_rec.line_renewal_type      := p_extwar_rec.line_renewal_type;
         IF l_line_rec.warranty_flag = 'W'
         THEN
            IF l_line_rec.srv_sdt > SYSDATE
            THEN
               get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
            ELSE
               get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
            END IF;

            l_line_rec.line_sts_code := l_sts_code;
            l_line_rec.line_renewal_type := 'DNR'  ;

         ELSE
            get_sts_code (p_kdtl_rec.prod_sts_code,
                          NULL,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code = 'ENTERED'
            THEN
               l_line_rec.line_sts_code := l_sts_code;
            ELSE
               l_status := fnd_profile.VALUE ('OKS_TRANSFER_STATUS');

               IF l_status = 'ACTIVE'
               THEN
                  IF l_line_rec.srv_sdt > SYSDATE
                  THEN
                     get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
                  ELSE
                     get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
                  END IF;
               ELSE
                  get_sts_code (l_status, NULL, l_ste_code, l_sts_code);
               END IF;

               l_line_rec.line_sts_code := l_sts_code;
            END IF;
         END IF;

         l_line_rec.SOURCE := NULL;
         --errorout_n ('srv sdt'||p_extwar_rec.srv_sdt||'   '||p_extwar_rec.srv_edt);
         l_sc_ctr := 0;

         FOR l_sales_credit_rec IN
            l_sales_credit_csr (p_kdtl_rec.service_line_id)
         LOOP
            l_sc_ctr := l_sc_ctr + 1;
            l_salescredit_tbl (l_sc_ctr).ctc_id := l_sales_credit_rec.ctc_id;
            l_salescredit_tbl (l_sc_ctr).sales_credit_type_id :=
                                     l_sales_credit_rec.sales_credit_type_id1;
            l_salescredit_tbl (l_sc_ctr).PERCENT :=
                                                   l_sales_credit_rec.PERCENT;
            l_salescredit_tbl (l_sc_ctr).sales_group_id :=
                                            l_sales_credit_rec.sales_group_id;
         END LOOP;             -- For l_sales_credit_rec IN l_sales_credit_csr

         oks_extwarprgm_pvt.create_k_service_lines
                                   (p_k_line_rec              => l_line_rec,
                                    p_contact_tbl             => p_contact_tbl_in,
                                    p_salescredit_tbl_in      => l_salescredit_tbl,
                                    p_caller                  => 'ST',
                                    x_order_error             => l_temp,
                                    x_service_line_id         => l_lineid,
                                    x_return_status           => l_return_status,
                                    x_msg_count               => x_msg_count,
                                    x_msg_data                => x_msg_data
                                   );

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING
               (fnd_log.level_statement,
                   g_module_current
                || '.CREATE_K_SYSTEM_TRF.create_k_service_line',
                   'oks_extwarprgm_pvt.create_k_service_lines(Return status = '
                || l_return_status
                || ')'
               );
         END IF;

         IF NOT l_return_status = 'S'
         THEN
            RAISE g_exception_halt_validation;
         ELSE
            x_line_id := l_lineid;
         END IF;
      EXCEPTION
         WHEN g_exception_halt_validation
         THEN
            x_return_status := l_return_status;
            NULL;
         WHEN OTHERS
         THEN
            x_return_status := okc_api.g_ret_sts_unexp_error;
            okc_api.set_message (g_app_name,
                                 g_unexpected_error,
                                 g_sqlcode_token,
                                 SQLCODE,
                                 g_sqlerrm_token,
                                 SQLERRM
                                );
      END create_contract_line;

      PROCEDURE create_contract_subline (
         p_kdtl_rec          IN              contract_trf_rec,
         p_hdr_id            IN              NUMBER,
         p_line_id           IN              NUMBER,
         x_subline_id        OUT NOCOPY      NUMBER,
         x_update_top_line   OUT NOCOPY      VARCHAR2,
         x_return_status     OUT NOCOPY      VARCHAR2,
         x_msg_data          OUT NOCOPY      VARCHAR2,
         x_msg_count         OUT NOCOPY      NUMBER
      )
      IS
/*  Cursor l_Cust_csr IS                                                   --29-apr-03

      Select   csi.last_oe_order_line_id Original_order_line_id
              ,csi.inventory_item_id
              ,csi.quantity
              ,csi.unit_of_measure uom_code
       From   csi_item_instances csi
       Where  csi.instance_id = p_kdtl_rec.old_cp_id;
*/
         CURSOR l_line_sts_csr (p_line_id NUMBER)
         IS
            SELECT st.ste_code, kl.sts_code
              FROM okc_k_lines_b kl, okc_statuses_b st
             WHERE kl.ID = p_line_id AND st.code = kl.sts_code;

         CURSOR l_getprice_csr (p_line_id NUMBER)
         IS
            SELECT price_negotiated
              FROM okc_k_lines_b
             WHERE ID = p_line_id;


         CURSOR l_serv_csr (p_serv_id NUMBER)
         IS
         SELECT  DECODE (fnd_profile.VALUE ('OKS_ITEM_DISPLAY_PREFERENCE'), 'DISPLAY_DESC', t.description , b.concatenated_segments )
           FROM mtl_system_items_b_kfv b, mtl_system_items_tl t
          WHERE b.inventory_item_id = t.inventory_item_id
            AND b.organization_id = t.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND b.inventory_item_id = p_serv_id
            AND ROWNUM < 2;

/*         CURSOR l_serv_csr (p_serv_id NUMBER)
         IS
            SELECT b.concatenated_segments description
              FROM mtl_system_items_b_kfv b
             WHERE b.inventory_item_id = p_serv_id AND ROWNUM < 2;
*/

         l_line_ste_code      VARCHAR2 (40);
         l_line_sts_code      VARCHAR2 (40);
         l_covd_rec           k_line_covered_level_rec_type;
         l_ste_code           VARCHAR2 (40);
         l_sts_code           VARCHAR2 (40);
         l_return_status      VARCHAR2 (10);
         l_days               NUMBER;
         l_newamt             NUMBER;
         l_day1price          NUMBER;
         p_price_attribs_in   oks_extwarprgm_pvt.pricing_attributes_type;
         l_warranty_flag      VARCHAR2 (2);
         l_covlvl_id          NUMBER;
         l_update_top_line    VARCHAR2 (1);
         l_status             VARCHAR2 (40);
         l_new_price          NUMBER;
         l_xfer_days          NUMBER;
         l_duration           NUMBER;
         l_timeunits          VARCHAR2 (25);
--l_xfer_timeunits         VARCHAR2(25);
      BEGIN
         x_return_status := okc_api.g_ret_sts_success;

/*                             Open l_Cust_csr;
                             Fetch l_Cust_csr into l_Cust_rec;
                             If l_Cust_csr%notfound Then
                                     Close l_Cust_Csr;
                                     IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                       fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.CREATE_K_SYSTEM_TRF.ERROR',
                                       'l_Cust_csr Not Found ' );
                                     END IF;
                                l_return_status := OKC_API.G_RET_STS_ERROR;
                                     OKC_API.set_message(G_APP_NAME,'OKS_CUST_PROD_DTLS_NOT_FOUND','CUSTOMER_PRODUCT',p_kdtl_rec.old_cp_id);
                                     Raise G_EXCEPTION_HALT_VALIDATION;
                             End if;
                             Close l_Cust_csr;
*/                           -- Amount to be prorated
                             -- Fix for the bug 3405907 Vigandhi 10-feb-2004
         IF p_kdtl_rec.service_amount IS NOT NULL
         THEN
            get_sts_code (p_kdtl_rec.prod_sts_code,
                          NULL,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code = 'ENTERED'
            THEN
               --l_days           := (trunc(p_kdtl_rec.prod_edt) - trunc(p_kdtl_rec.prod_sdt)) + 1;
               --l_day1price      := p_kdtl_rec.service_amount / l_days;
               --l_newamt         := oks_extwar_util_pvt.round_currency_amt(l_day1price * (trunc(p_kdtl_rec.prod_edt) - trunc(l_trfdt) + 1),p_kdtl_rec.service_currency);

               -- Calculations based on partial period.
               IF p_kdtl_rec.price_uom_sl IS NULL
               THEN
                  okc_time_util_pub.get_duration
                                 (p_start_date         => TRUNC
                                                             (p_kdtl_rec.prod_sdt
                                                             ),
                                  p_end_date           => p_kdtl_rec.prod_edt,
                                  x_duration           => l_duration,
                                  x_timeunit           => l_timeunits,
                                  x_return_status      => l_return_status
                                 );
               /*
                 Okc_time_util_pub.get_duration
                                (
                                 p_start_date    => trunc(l_trfdt),
                                 p_end_date      => p_kdtl_rec.prod_edt,
                                 x_duration      => l_duration,
                                 x_timeunit      => l_xfer_timeunits,
                                 x_return_status => l_return_status
                               );*/
               END IF;

               l_days :=
                  oks_time_measures_pub.get_quantity
                                               (p_kdtl_rec.prod_sdt,
                                                p_kdtl_rec.prod_edt,
                                                NVL (p_kdtl_rec.price_uom_sl,
                                                     l_timeunits
                                                    ),
                                                p_kdtl_rec.period_type,
                                                p_kdtl_rec.period_start
                                               );
               l_xfer_days :=
                  oks_time_measures_pub.get_quantity
                                               (l_trfdt,
                                                p_kdtl_rec.prod_edt,
                                                NVL (p_kdtl_rec.price_uom_sl,
                                                     l_timeunits
                                                    ),
                                                p_kdtl_rec.period_type,
                                                p_kdtl_rec.period_start
                                               );
               l_newamt :=
                  oks_extwar_util_pvt.round_currency_amt
                                                 (  p_kdtl_rec.service_amount
                                                  * l_xfer_days
                                                  / l_days,
                                                  p_kdtl_rec.service_currency
                                                 );
            ELSE
               OPEN l_getprice_csr (p_kdtl_rec.object_line_id);

               FETCH l_getprice_csr
                INTO l_new_price;

               CLOSE l_getprice_csr;

               l_newamt := p_kdtl_rec.service_amount - l_new_price;
            END IF;
         ELSE
            l_newamt := 0;
         END IF;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                            || '.CREATE_K_SYSTEM_TRF.Create_Contract_subline',
                            'New amount = ' || l_newamt
                           );
         END IF;

         l_covd_rec.k_id := p_hdr_id;
         l_covd_rec.rty_code := 'CONTRACTTRANSFERORDER';
         l_covd_rec.attach_2_line_id := p_line_id;
         l_covd_rec.line_number := okc_api.g_miss_char;
         l_covd_rec.customer_product_id := p_kdtl_rec.old_cp_id;
         l_covd_rec.product_segment1 := p_kdtl_rec.prod_name;
         l_covd_rec.product_desc := p_kdtl_rec.prod_description;
         l_covd_rec.product_start_date := TRUNC (l_trfdt);
         l_covd_rec.product_end_date := TRUNC (p_kdtl_rec.prod_edt);
         l_covd_rec.quantity := p_kdtl_rec.cp_qty;
         l_covd_rec.list_price := p_kdtl_rec.service_unit_price;
         l_covd_rec.uom_code := p_kdtl_rec.uom_code;
         l_covd_rec.negotiated_amount := l_newamt;
         l_covd_rec.standard_coverage := p_kdtl_rec.standard_cov_yn;
         l_covd_rec.price_uom := p_kdtl_rec.price_uom_sl;
         l_covd_rec.toplvl_uom_code := p_kdtl_rec.toplvl_uom_code;
         --mchoudha added for bug#5233956
         l_covd_rec.toplvl_price_qty := p_kdtl_rec.toplvl_price_qty;

         IF p_kdtl_rec.lse_id = 25
         THEN
            l_warranty_flag := 'E';
         ELSIF p_kdtl_rec.lse_id = 9 AND p_kdtl_rec.scs_code = 'SERVICE'
         THEN
            l_warranty_flag := 'S';
         ELSIF p_kdtl_rec.lse_id = 18
         THEN
            l_warranty_flag := 'W';
            l_covd_rec.line_renewal_type := 'DNR'  ;
         ELSIF p_kdtl_rec.lse_id = 9 AND p_kdtl_rec.scs_code = 'SUBSCRIPTION'
         THEN
            l_warranty_flag := 'SU';


         END IF;

         l_covd_rec.warranty_flag := l_warranty_flag;
         -- l_covd_rec.line_renewal_type               := p_kdtl_rec.cp_line_renewal_type;
         l_covd_rec.currency_code := p_kdtl_rec.service_currency;

         OPEN l_serv_csr (p_kdtl_rec.service_inventory_id);

         FETCH l_serv_csr
          INTO l_covd_rec.attach_2_line_desc;

         CLOSE l_serv_csr;

         l_covd_rec.prod_item_id := p_kdtl_rec.prod_inventory_item;

         IF l_covd_rec.warranty_flag = 'W'
         THEN
            IF l_covd_rec.product_start_date > SYSDATE
            THEN
               get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
            ELSE
               get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
            END IF;

            l_covd_rec.product_sts_code := l_sts_code;
         ELSE
            get_sts_code (p_kdtl_rec.prod_sts_code,
                          NULL,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code = 'ENTERED'
            THEN
               l_covd_rec.product_sts_code := l_sts_code;
            ELSE
               l_status := fnd_profile.VALUE ('OKS_TRANSFER_STATUS');

               IF l_status = 'ACTIVE'
               THEN
                  IF l_covd_rec.product_start_date > SYSDATE
                  THEN
                     get_sts_code ('SIGNED', NULL, l_ste_code, l_sts_code);
                  ELSE
                     get_sts_code ('ACTIVE', NULL, l_ste_code, l_sts_code);
                  END IF;
               ELSE
                  get_sts_code (l_status, NULL, l_ste_code, l_sts_code);
               END IF;

               l_covd_rec.product_sts_code := l_sts_code;
            END IF;
         END IF;

         oks_extwarprgm_pvt.create_k_covered_levels
                                       (p_k_covd_rec         => l_covd_rec,
                                        p_price_attribs      => p_price_attribs_in,
                                        p_caller             => 'ST',
                                        x_order_error        => l_temp,
                                        x_covlvl_id          => l_covlvl_id,
                                        x_update_line        => l_update_top_line,
                                        x_return_status      => l_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data
                                       );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                               g_module_current
                            || '.CREATE_K_SYSTEM_TRF.Create_Contract_subline',
                            'New amount = ' || l_newamt
                           );
         END IF;

         IF NOT l_return_status = 'S'
         THEN
            RAISE g_exception_halt_validation;
         ELSE
            x_subline_id := l_covlvl_id;
            x_update_top_line := l_update_top_line;
         END IF;
      EXCEPTION
         WHEN g_exception_halt_validation
         THEN
            x_return_status := l_return_status;
            NULL;
         WHEN OTHERS
         THEN
            x_return_status := okc_api.g_ret_sts_unexp_error;
            okc_api.set_message (g_app_name,
                                 g_unexpected_error,
                                 g_sqlcode_token,
                                 SQLCODE,
                                 g_sqlerrm_token,
                                 SQLERRM
                                );
      END create_contract_subline;

      PROCEDURE create_billing_schedule (
         p_line_id         IN              NUMBER,
         p_covlvl_id       IN              NUMBER,
         P_period_start    IN              Varchar2,
         p_start_date      IN              DATE,
         p_end_date        IN              DATE,
         p_update_line     IN              VARCHAR2,
         x_return_status   OUT NOCOPY      VARCHAR2,
         x_msg_data        OUT NOCOPY      VARCHAR2,
         x_msg_count       OUT NOCOPY      NUMBER
      )
      IS
         l_strmlvl_id      NUMBER;
         l_sll_tbl         oks_bill_sch.streamlvl_tbl;
         l_return_status   VARCHAR2 (1);
         l_duration        NUMBER;
         l_timeunits       VARCHAR2 (25);
         l_bil_sch_out     oks_bill_sch.itembillsch_tbl;
         l_uom_code         Varchar2(240);
         Cursor get_day_uom_code IS
          select uom_code
           from okc_time_code_units_v
           where tce_code='DAY'
           and quantity=1;



      BEGIN
         l_strmlvl_id := check_strmlvl_exists (p_line_id);

         IF l_strmlvl_id IS NULL
         THEN

          If p_period_start = 'CALENDAR' Then
                       Open get_day_uom_code;
	                 Fetch get_day_uom_code into l_uom_code;
	                 Close get_day_uom_code;


                      l_sll_tbl (1).cle_id                := p_line_id;
                      l_sll_tbl (1).sequence_no           := 1;
                      l_sll_tbl (1).level_periods         := 1;
                      l_sll_tbl (1).uom_code              := l_uom_code;
                      l_sll_tbl (1).uom_per_period        := p_end_date - p_start_date + 1;
                      l_sll_tbl (1).invoice_offset_days   := 0;
                      l_sll_tbl (1).interface_offset_days := 0;
                      l_sll_tbl (1).level_amount          := null;





          Else
            okc_time_util_pub.get_duration
                                        (p_start_date         => TRUNC
                                                                    (p_start_date
                                                                    ),
                                         p_end_date           => p_end_date,
                                         x_duration           => l_duration,
                                         x_timeunit           => l_timeunits,
                                         x_return_status      => l_return_status
                                        );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                        (fnd_log.level_event,
                            g_module_current
                         || '.CREATE_K_SYSTEM_TRF.Create_billing_schedule',
                            'Okc_time_util_pub.get_duration(Return status = '
                         || l_return_status
                         || ',Duration = '
                         || l_duration
                         || ',Time Units = '
                         || l_timeunits
                         || ')'
                        );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            l_sll_tbl (1).cle_id := p_line_id;
            --l_sll_tbl(1).billing_type                := 'T';
            l_sll_tbl (1).uom_code := l_timeunits;
            l_sll_tbl (1).sequence_no := '1';
            l_sll_tbl (1).level_periods := '1';
            --l_sll_tbl (1).start_date := TRUNC (l_trfdt);
            l_sll_tbl (1).uom_per_period := l_duration;
            l_sll_tbl (1).advance_periods := NULL;
            l_sll_tbl (1).level_amount := NULL;
            l_sll_tbl (1).invoice_offset_days := NULL;
            l_sll_tbl (1).interface_offset_days := NULL;

          End If;
            oks_bill_sch.create_bill_sch_rules
                                          (p_billing_type         => 'T',
                                           p_sll_tbl              => l_sll_tbl,
                                           p_invoice_rule_id      => -2,
                                           x_bil_sch_out_tbl      => l_bil_sch_out,
                                           x_return_status        => l_return_status
                                          );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                    (fnd_log.level_event,
                        g_module_current
                     || '.CREATE_K_SYSTEM_TRF.Create_billing_schedule',
                        'oks_bill_sch.create_bill_sch_rules(Return status = '
                     || l_return_status
                     || ')'
                    );
            END IF;

            IF l_return_status <> okc_api.g_ret_sts_success
            THEN
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Sched Billing Rule (LINE)'
                                   );
               RAISE g_exception_halt_validation;
            END IF;
                  /* OKS_BILL_UTIL_PUB.CREATE_BCL_FOR_OM
                   (
                        P_LINE_ID  => p_line_id ,
                        X_RETURN_STATUS => l_return_status
                    );
          If(G_FND_LOG_OPTION = 'Y') Then
                   FND_FILE.PUT_LINE (FND_FILE.LOG,'IBNEW :- CREATE_BCL_FOR_OM ' || l_return_status );
         OKS_RENEW_PVT.DEBUG_LOG( 'OKS_EXTWARPRGM_PVT.CREATE_K_SYSTEM_TRF :: CREATE_BCL_FOR_OM '|| l_return_status);
         End if;

                   If Not l_return_status = 'S' then
                        Raise G_EXCEPTION_HALT_VALIDATION;
                   End if;
                   */
         ELSE
            IF check_lvlelements_exists (p_line_id)
            THEN
               IF p_update_line = 'Y'
               THEN
                  oks_bill_sch.update_om_sll_date
                                         (p_top_line_id        => p_line_id,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data
                                         );

                  -- FND_FILE.PUT_LINE( fnd_file.LOG, 'IBNEW :- Update_OM_SLL_Date ' || l_return_status );
                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                            g_module_current
                         || '.CREATE_K_SYSTEM_TRF.Create_billing_schedule',
                            'oks_bill_sch.update_om_sll_date(Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = 'S'
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               ELSE
                  oks_bill_sch.create_bill_sch_cp
                                         (p_top_line_id        => p_line_id,
                                          p_cp_line_id         => p_covlvl_id,
                                          p_cp_new             => 'Y',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                            g_module_current
                         || '.CREATE_K_SYSTEM_TRF.Create_billing_schedule',
                            'oks_bill_sch.create_bill_sch_cp(Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = 'S'
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;
                      /* OKS_BILL_UTIL_PUB.CREATE_BCL_FOR_OM
                       (
                       P_LINE_ID  => p_line_id ,
                       X_RETURN_STATUS => l_return_status
                       );
                      -- FND_FILE.PUT_LINE (FND_FILE.LOG,'IBNEW :- CREATE_BCL_FOR_OM ' || l_return_status );
            If(G_FND_LOG_OPTION = 'Y') Then
                       OKS_RENEW_PVT.DEBUG_LOG( 'OKS_EXTWARPRGM_PVT.CREATE_K_SYSTEM_TRF :: CREATE_BCL_FOR_OM '|| l_return_status);
            End if;
                       If Not l_return_status = 'S' then
                            Raise G_EXCEPTION_HALT_VALIDATION;
                       End if;
                       */
            ELSE
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'level elements NOT EXIST'
                                   );
               RAISE g_exception_halt_validation;
            END IF;
         END IF;                                                -- strmlvl end

         x_return_status := l_return_status;
      EXCEPTION
         WHEN g_exception_halt_validation
         THEN
            x_return_status := l_return_status;
            NULL;
         WHEN OTHERS
         THEN
            x_return_status := okc_api.g_ret_sts_unexp_error;
            okc_api.set_message (g_app_name,
                                 g_unexpected_error,
                                 g_sqlcode_token,
                                 SQLCODE,
                                 g_sqlerrm_token,
                                 SQLERRM
                                );
      END;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;
      l_old_cp_id := 0;

      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP


            get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).hdr_sts,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code = 'HOLD'
            THEN
               l_return_status := okc_api.g_ret_sts_error;

               IF fnd_log.level_error >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_error,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBTERMINATE.ERROR',
                                  'Contract in QA_HOLD status'
                                 );
               END IF;

               okc_api.set_message (g_app_name,
                                    g_invalid_value,
                                    g_col_name_token,
                                       'Termination not allowed .Contract '
                                    || p_kdtl_tbl (l_ctr).contract_number
                                    || 'is in QA_HOLD status'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
         END LOOP;
      END IF;


      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP
            --Fix for Bug 5406201
            l_clev_tbl_in.delete;
            l_chrv_tbl_in.delete;
            okc_context.set_okc_org_context
                                           (p_kdtl_tbl (l_ctr).hdr_org_id,
                                            p_kdtl_tbl (l_ctr).organization_id
                                           );
            get_party_id (p_kdtl_tbl (l_ctr).new_account_id,
                          l_party_id,
                          l_party_name
                         );

            OPEN l_serv_csr (p_kdtl_tbl (l_ctr).service_inventory_id);

            FETCH l_serv_csr
             INTO l_service_name;

            CLOSE l_serv_csr;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module_current || '.CREATE_K_SYSTEM_TRF',
                                  'new cust acct id = '
                               || p_kdtl_tbl (l_ctr).new_account_id
                               || ',party id = '
                               || l_party_id
                              );
            END IF;

            IF p_kdtl_tbl (l_ctr).party_id <> l_party_id
            THEN
               l_inst_dtls_tbl.DELETE;
               l_ptr := l_ptr + 1;
               l_trf_option := NULL;

               OPEN l_cov_csr (p_kdtl_tbl (l_ctr).service_line_id);

               FETCH l_cov_csr
                INTO l_cov_rec;

               IF l_cov_csr%FOUND
               THEN
                  l_trf_option := l_cov_rec.transfer_option;
               END IF;

               --errorout_n('l_trf_option'||l_trf_option);
               CLOSE l_cov_csr;

               l_trfdt := p_kdtl_tbl (l_ctr).transfer_date;

               IF (TRUNC (l_trfdt) <= TRUNC (p_kdtl_tbl (l_ctr).prod_sdt))
               THEN
                  l_trfdt := p_kdtl_tbl (l_ctr).prod_sdt;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'Transfer Option = '
                                  || l_trf_option
                                  || ',For service line = '
                                  || p_kdtl_tbl (l_ctr).service_line_id
                                 );
               END IF;

/*-------------------------------------------------*/
-- If Transfer Option Is "No Change to Contract"
/*-------------------------------------------------*/
               IF l_trf_option = 'NO_CHANGE'
               THEN
                  NULL;
               END IF;

 /*-------------------------------------------------*/
 --If Transfer Option Is "Terminate upon Transfer"
 /*-------------------------------------------------*/
 /*----------------------------------------------------------------------------------------*/
 --If Transfer option Is "No Change if Transfer within group otherwise Terminate Contract".
/*----------------------------------------------------------------------------------------*/
               IF l_trf_option IN ('TERM', 'TERM_NO_REL')
               THEN
                  l_ptr := 1;
                  --Check if the CUstomers are related by the value defined in profile
                  l_relationship := NULL;

                  IF l_trf_option = 'TERM_NO_REL'
                  THEN
                     l_relationship_type :=
                                      fnd_profile.VALUE ('OKS_TRF_PARTY_REL');
                     get_party_id (p_kdtl_tbl (l_ctr).new_account_id,
                                   l_new_party_id,
                                   l_new_party_name
                                  );
                     get_party_id (p_kdtl_tbl (l_ctr).old_account_id,
                                   l_old_party_id,
                                   l_old_party_name
                                  );

                     OPEN l_cust_rel_csr (l_old_party_id,
                                          l_new_party_id,
                                          l_relationship_type,
                                          p_kdtl_tbl (l_ctr).transfer_date
                                         );

                     FETCH l_cust_rel_csr
                      INTO l_relationship;

                     CLOSE l_cust_rel_csr;

                     IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.STRING
                                    (fnd_log.level_statement,
                                     g_module_current
                                     || '.CREATE_K_SYSTEM_TRF',
                                        'TERM_NO_REL profile relationship = '
                                     || l_relationship_type
                                     || ', Actual Relationship = '
                                     || l_relationship
                                    );
                     END IF;
                  END IF;

                  IF l_relationship IS NULL
                  THEN


			-- Check Product status
                        get_sts_code (NULL,
                                   p_kdtl_tbl (l_ctr).prod_sts_code,
                                   l_ste_code,
                                   l_sts_code
                                  );

                     IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.STRING (fnd_log.level_statement,
                                           g_module_current
                                        || '.CREATE_K_SYSTEM_TRF',
                                           'Product status Code = '
                                        || p_kdtl_tbl (l_ctr).prod_sts_code
                                        || ', Ste code = '
                                        || l_ste_code
                                       );
                     END IF;

                     IF l_ste_code <> 'ENTERED'
                     THEN
                        --Terminate the CUrrent Owners Contract subline with date terminated as Transfer date
                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.STRING
                              (fnd_log.level_statement,
                               g_module_current || '.CREATE_K_SYSTEM_TRF',
                                  'OKS Raise credit memo profile option value  ='
                               || fnd_profile.VALUE
                                           ('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT')
                              );
                        END IF;

                        /*IF    fnd_profile.VALUE('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT') = 'YES' OR fnd_profile.VALUE('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT') IS NULL THEN
                               l_suppress_credit := 'N';
                        ELSE
                               l_suppress_credit := 'Y';
                        END IF;*/
                        l_credit_amount :=
                           oks_ib_util_pvt.get_credit_option
                                              (p_kdtl_tbl (l_ctr).party_id,
                                               p_kdtl_tbl (l_ctr).hdr_org_id,
                                               p_kdtl_tbl (l_ctr).transfer_date
                                              );

                        IF UPPER (l_credit_amount) = 'FULL'
                        THEN
                           l_full_credit := 'Y';
                           l_suppress_credit := 'N';
                           --l_trfdt := p_kdtl_tbl( l_ctr ).prod_sdt;
                           l_term_date_flag := 'N';
                        ELSIF UPPER (l_credit_amount) = 'NONE'
                        THEN
                           l_suppress_credit := 'Y';
                           l_full_credit := 'N';
                           l_term_date_flag := 'N';
                        ELSIF UPPER (l_credit_amount) = 'CALCULATED'
                        THEN
                           l_suppress_credit := 'N';
                           l_full_credit := 'N';
                           l_term_date_flag := 'N';
                        END IF;

                        IF (TRUNC (p_kdtl_tbl (l_ctr).prod_edt) <
                                                               TRUNC (l_trfdt)
                           )
                        THEN
                           l_suppress_credit := 'Y';
                           l_full_credit := 'N';
                           l_trfdt := p_kdtl_tbl (l_ctr).prod_edt + 1;
                           l_term_date_flag := 'Y';
                        END IF;



                        oks_bill_rec_pub.pre_terminate_cp
                                (p_calledfrom                => -1,
                                 p_cle_id                    => p_kdtl_tbl
                                                                        (l_ctr).object_line_id,
                                 p_termination_date          => TRUNC (l_trfdt),
                                 p_terminate_reason          => 'TRF',
                                 p_override_amount           => NULL,
                                 p_con_terminate_amount      => NULL,
                                 p_termination_amount        => NULL,
                                 p_suppress_credit           => l_suppress_credit,
                                 --p_existing_credit             => 0,
                                 p_full_credit               => l_full_credit,
                                 --'N',
                                 p_term_date_flag            => l_term_date_flag,
                                 p_term_cancel_source        => 'IBTRANSFER',
                                 x_return_status             => l_return_status
                                );

                        IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                           )
                        THEN
                           fnd_log.STRING
                              (fnd_log.level_event,
                               g_module_current || '.CREATE_K_SYSTEM_TRF',
                                  'oks_bill_rec_pub.Pre_terminate_cp(Return status ='
                               || l_return_status
                               || ')'
                              );
                        END IF;

                        IF NOT l_return_status = okc_api.g_ret_sts_success
                        THEN
                           RAISE g_exception_halt_validation;
                        END IF;

                        l_inst_dtls_tbl (l_ptr).subline_date_terminated :=
                                                               TRUNC (l_trfdt);
                        date_terminated := NULL;
                        oks_ib_util_pvt.check_termcancel_lines
                                           (p_kdtl_tbl (l_ctr).service_line_id,
                                            'SL',
                                            'T',
                                            date_terminated
                                           );

                        IF date_terminated IS NOT NULL
                        THEN
                           get_sts_code ('TERMINATED', NULL, l_ste_code, l_sts_code);

                           l_clev_tbl_in (1).ID :=
                                           p_kdtl_tbl (l_ctr).service_line_id;
                           l_clev_tbl_in (1).date_terminated := TRUNC (date_terminated);
                           l_clev_tbl_in (1).trn_code := 'TRF';
                           l_clev_tbl_in (1).term_cancel_source := 'IBTRANSFER';
                           If TRUNC (date_terminated)<= trunc(sysdate) Then
                                 l_clev_tbl_in (1).sts_code := l_sts_code;
                           End If;

                           okc_contract_pub.update_contract_line
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_clev_tbl               => l_clev_tbl_in,
                                       x_clev_tbl               => l_clev_tbl_out
                                      );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'okc_contract_pub.update_contract_line(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;
                        END IF;

                        date_terminated := NULL;
                        oks_ib_util_pvt.check_termcancel_lines
                                                    (p_kdtl_tbl (l_ctr).hdr_id,
                                                     'TL',
                                                     'T',
                                                     date_terminated
                                                    );

                        IF date_terminated IS NOT NULL
                        THEN
                           get_sts_code ('TERMINATED', NULL, l_ste_code, l_sts_code);

                           l_chrv_tbl_in (1).ID := p_kdtl_tbl (l_ctr).hdr_id;
                           l_chrv_tbl_in (1).date_terminated := TRUNC (date_terminated);
                           l_chrv_tbl_in (1).trn_code := 'TRF';
                           l_chrv_tbl_in (1).term_cancel_source := 'IBTRANSFER';
                           If TRUNC (date_terminated)<= trunc(sysdate) Then
		                      l_chrv_tbl_in (1).sts_code  := l_sts_code;
                           End If;

                           okc_contract_pub.update_contract_header
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_chrv_tbl               => l_chrv_tbl_in,
                                       x_chrv_tbl               => l_chrv_tbl_out
                                      );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                     g_module_current
                                  || '.Update_Hdr_Dates.external_call.after',
                                     'okc_contract_pub.update_contract_header(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;
                        END IF;

                        launch_workflow
                           (   'INSTALL BASE ACTIVITY : TRANSFER TERMINATE SUBLINE '
                            || fnd_global.local_chr (10)
                            || 'Contract Number       :                     '
                            || get_contract_number (p_kdtl_tbl (l_ctr).hdr_id)
                            || fnd_global.local_chr (10)
                            || 'Service Terminated    :                     '
                            || l_service_name
                           );
                     ELSIF l_ste_code = 'ENTERED'
                     THEN
                        IF (TRUNC (p_kdtl_tbl (l_ctr).prod_edt) <
                                                               TRUNC (l_trfdt)
                           )
                        THEN
                           l_trfdt := p_kdtl_tbl (l_ctr).prod_edt + 1;
                        END IF;

		      -- added for the bug # 6000133
		      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

                        oks_change_status_pvt.update_line_status
                           (x_return_status           => l_return_status,
                            x_msg_data                => x_msg_data,
                            x_msg_count               => x_msg_count,
                            p_init_msg_list           => 'F',
                            p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                            p_cle_id                  => p_kdtl_tbl (l_ctr).object_line_id,
                            p_new_sts_code            => l_sts_code,
                            p_canc_reason_code        => 'TRANSFER',
                            p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                            p_old_ste_code            => 'ENTERED',
                            p_new_ste_code            => 'CANCELLED',
                            p_term_cancel_source      => 'IBTRANSFER',
                            p_date_cancelled          => TRUNC (l_trfdt),
                            p_comments                => NULL,
                            p_validate_status         => 'N'
                           );

                        IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                           )
                        THEN
                           fnd_log.STRING
                              (fnd_log.level_event,
                               g_module_current || '.CREATE_K_SYSTEM_TRF',
                                  'okc_contract_pub.update_contract_line(Return status ='
                               || l_return_status
                               || ')'
                              );
                        END IF;

                        IF NOT l_return_status = okc_api.g_ret_sts_success
                        THEN
                           RAISE g_exception_halt_validation;
                        END IF;

                        l_inst_dtls_tbl (l_ptr).date_cancelled :=
                                                               TRUNC (l_trfdt);
                        date_cancelled := NULL;
                        oks_ib_util_pvt.check_termcancel_lines
                                           (p_kdtl_tbl (l_ctr).service_line_id,
                                            'SL',
                                            'C',
                                            date_cancelled
                                           );

                        IF date_cancelled IS NOT NULL
                        THEN

		      -- added for the bug # 6000133
		      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

			   oks_change_status_pvt.update_line_status
                              (x_return_status           => l_return_status,
                               x_msg_data                => x_msg_data,
                               x_msg_count               => x_msg_count,
                               p_init_msg_list           => 'F',
                               p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                               p_cle_id                  => p_kdtl_tbl (l_ctr).service_line_id,
                               p_new_sts_code            => l_sts_code,
                               p_canc_reason_code        => 'TRANSFER',
                               p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                               p_old_ste_code            => 'ENTERED',
                               p_new_ste_code            => 'CANCELLED',
                               p_term_cancel_source      => 'IBTRANSFER',
                               p_date_cancelled          => TRUNC
                                                               (date_cancelled),
                               p_comments                => NULL,
                               p_validate_status         => 'N'
                              );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'okc_contract_pub.update_contract_line(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;
                        END IF;

                        date_cancelled := NULL;
                        oks_ib_util_pvt.check_termcancel_lines
                                                    (p_kdtl_tbl (l_ctr).hdr_id,
                                                     'TL',
                                                     'C',
                                                     date_cancelled
                                                    );

                        IF date_cancelled IS NOT NULL
                        THEN

		      -- added for the bug # 6000133
		      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

			   oks_change_status_pvt.update_header_status
                              (x_return_status           => l_return_status,
                               x_msg_data                => x_msg_data,
                               x_msg_count               => x_msg_count,
                               p_init_msg_list           => 'F',
                               p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                               p_new_sts_code            => l_sts_code,
                               p_canc_reason_code        => 'TRANSFER',
                               p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                               p_comments                => NULL,
                               p_term_cancel_source      => 'IBTRANSFER',
                               p_date_cancelled          => TRUNC
                                                               (date_cancelled),
                               p_validate_status         => 'N'
                              );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'oks_change_status_pvt.Update_header_status(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;
                        END IF;                   --Date_Cancelled Is Not Null
                     END IF;                          -- ste_code <> 'ENTERED'

                     l_date_terminated := NULL;
                     l_subline_price := NULL;

                     OPEN l_subline_csr (p_kdtl_tbl (l_ctr).object_line_id);

                     FETCH l_subline_csr
                      INTO l_date_terminated, l_subline_price;

                     CLOSE l_subline_csr;

                     l_inst_dtls_tbl (l_ptr).transaction_date :=
                                              (p_kdtl_tbl (l_ctr).transaction_date);
                     l_inst_dtls_tbl (l_ptr).transaction_type := 'TRF';
                     l_inst_dtls_tbl (l_ptr).system_id :=
                                                  p_kdtl_tbl (l_ctr).system_id;
                     l_inst_dtls_tbl (l_ptr).transfer_option := l_trf_option;
                     l_inst_dtls_tbl (l_ptr).instance_id_new :=
                                                p_kdtl_tbl (l_ctr).instance_id;
                     l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                                               l_subline_price;
                     --l_kdtl_tbl( l_ctr ).service_amount;
                     l_inst_dtls_tbl (l_ptr).instance_qty_new :=
                                                     p_kdtl_tbl (l_ctr).cp_qty;
                     l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                     l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                     l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                     l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                     l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                     l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                     l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                     l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                     l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                     l_inst_dtls_tbl (l_ptr).new_customer :=
                                             p_kdtl_tbl (l_ctr).old_account_id;
                     l_inst_dtls_tbl (l_ptr).new_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                     l_inst_dtls_tbl (l_ptr).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
                     l_inst_dtls_tbl (l_ptr).instance_qty_old :=
                                                     p_kdtl_tbl (l_ctr).cp_qty;
                     l_inst_dtls_tbl (l_ptr).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                     l_inst_dtls_tbl (l_ptr).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                     l_inst_dtls_tbl (l_ptr).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                     l_inst_dtls_tbl (l_ptr).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                     l_inst_dtls_tbl (l_ptr).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                     l_inst_dtls_tbl (l_ptr).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                     l_inst_dtls_tbl (l_ptr).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                     l_inst_dtls_tbl (l_ptr).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                     l_inst_dtls_tbl (l_ptr).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                     l_inst_dtls_tbl (l_ptr).old_customer :=
                                             p_kdtl_tbl (l_ctr).old_account_id;
                     l_inst_dtls_tbl (l_ptr).old_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                  END IF;                            -- l_relation_ship = null
               END IF;               --l_trf_option in ( 'TERM','TERM_NO_REL')

/*------------------------------------------------------------------------------*/
 -- If Transfer option is "Transfer service to new owner, terminate old service".
/*-------------------------------------------------------------------------------*/
               IF l_trf_option IN ('TRANS', 'TRANS_NO_REL')
               THEN
                  l_ptr := 1;

                   -- Check Subline status
                   get_sts_code (NULL,
                                p_kdtl_tbl (l_ctr).prod_sts_code,
                                l_ste_code,
                                l_sts_code
                               );
		   --Check if the Customers are related by the value defined in profile for  Transfer option 'TRANS_NO_REL'

                  /*1*/
                  IF l_trf_option = 'TRANS_NO_REL'
                  THEN
                     l_relationship := NULL;
                     l_relationship_type :=
                                      fnd_profile.VALUE ('OKS_TRF_PARTY_REL');
                     get_party_id (p_kdtl_tbl (l_ctr).new_account_id,
                                   l_new_party_id,
                                   l_new_party_name
                                  );
                     get_party_id (p_kdtl_tbl (l_ctr).old_account_id,
                                   l_old_party_id,
                                   l_old_party_name
                                  );

                     OPEN l_cust_rel_csr (l_old_party_id,
                                          l_new_party_id,
                                          l_relationship_type,
                                          p_kdtl_tbl (l_ctr).transfer_date
                                         );

                     FETCH l_cust_rel_csr
                      INTO l_relationship;

                     CLOSE l_cust_rel_csr;
                  /*E1*/
                  END IF;

                  IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING
                                   (fnd_log.level_statement,
                                    g_module_current || '.CREATE_K_SYSTEM_TRF',
                                       'TRANS_NO_REL profile relationship = '
                                    || l_relationship_type
                                    || ', Actual Relationship = '
                                    || l_relationship
                                   );
                  END IF;

                  /*2*/
                  IF l_relationship IS NULL OR l_trf_option = 'TRANS'
                  THEN
                     -- If Contract is in Entered Status then no updates on the original Contract
                     -- but Create a Contract for New Owner in Entered Status.
                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.STRING (fnd_log.level_statement,
                                           g_module_current
                                        || '.CREATE_K_SYSTEM_TRF',
                                           'Product Status code = '
                                        || p_kdtl_tbl (l_ctr).prod_sts_code
                                        || ',Ste code = '
                                        || l_ste_code
                                       );
                     END IF;

                     l_create_contract := 'Y';

                     /*4*/
                     IF l_ste_code <> 'ENTERED'
                     THEN
                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.STRING
                              (fnd_log.level_statement,
                               g_module_current || '.CREATE_K_SYSTEM_TRF',
                                  'OKS Raise credit memo profile option value  ='
                               || fnd_profile.VALUE
                                           ('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT')
                              );
                        END IF;

                        /*IF    fnd_profile.VALUE('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT') = 'YES' OR fnd_profile.VALUE('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT') IS NULL THEN
                              l_suppress_credit := 'N';
                        ELSE
                              l_suppress_credit := 'Y';
                        END IF;*/
                        l_credit_amount :=
                           oks_ib_util_pvt.get_credit_option
                                              (p_kdtl_tbl (l_ctr).party_id,
                                               p_kdtl_tbl (l_ctr).hdr_org_id,
                                               p_kdtl_tbl (l_ctr).transfer_date
                                              );

                        IF UPPER (l_credit_amount) = 'FULL'
                        THEN
                           l_full_credit := 'Y';
                           l_suppress_credit := 'N';
                           --l_trfdt := p_kdtl_tbl( l_ctr ).prod_sdt;
                           l_term_date_flag := 'N';
                        ELSIF UPPER (l_credit_amount) = 'NONE'
                        THEN
                           l_suppress_credit := 'Y';
                           l_full_credit := 'N';
                           l_term_date_flag := 'N';
                        ELSIF UPPER (l_credit_amount) = 'CALCULATED'
                        THEN
                           l_suppress_credit := 'N';
                           l_full_credit := 'N';
                           l_term_date_flag := 'N';
                        END IF;

                        IF TRUNC (p_kdtl_tbl (l_ctr).prod_edt) <
                                                               TRUNC (l_trfdt)
                        THEN
                           l_suppress_credit := 'Y';
                           l_full_credit := 'N';
                           l_trfdt := p_kdtl_tbl (l_ctr).prod_edt + 1;
                           l_term_date_flag := 'Y';
                           l_create_contract := 'N';
                        END IF;



                        oks_bill_rec_pub.pre_terminate_cp
                                (p_calledfrom                => -1,
                                 p_cle_id                    => p_kdtl_tbl
                                                                        (l_ctr).object_line_id,
                                 p_termination_date          => TRUNC (l_trfdt),
                                 p_terminate_reason          => 'TRF',
                                 p_override_amount           => NULL,
                                 p_con_terminate_amount      => NULL,
                                 p_termination_amount        => NULL,
                                 --p_existing_credit               => 0,
                                 p_suppress_credit           => l_suppress_credit,
                                 p_full_credit               => l_full_credit,
                                 --'N',
                                 p_term_date_flag            => l_term_date_flag,
                                 p_term_cancel_source        => 'IBTRANSFER',
                                 x_return_status             => l_return_status
                                );

                        IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                           )
                        THEN
                           fnd_log.STRING
                              (fnd_log.level_event,
                               g_module_current || '.CREATE_K_SYSTEM_TRF',
                                  'oks_bill_rec_pub.Pre_terminate_cp(Return status ='
                               || l_return_status
                               || ')'
                              );
                        END IF;

                        IF NOT l_return_status = okc_api.g_ret_sts_success
                        THEN
                           RAISE g_exception_halt_validation;
                        END IF;

                        l_inst_dtls_tbl (l_ptr).subline_date_terminated :=
                                                               TRUNC (l_trfdt);
                        date_terminated := NULL;
                        oks_ib_util_pvt.check_termcancel_lines
                                           (p_kdtl_tbl (l_ctr).service_line_id,
                                            'SL',
                                            'T',
                                            date_terminated
                                           );

                        IF date_terminated IS NOT NULL
                        THEN
                           get_sts_code ('TERMINATED', NULL, l_ste_code, l_sts_code);

                           l_clev_tbl_in (1).ID :=
                                           p_kdtl_tbl (l_ctr).service_line_id;
                           l_clev_tbl_in (1).date_terminated :=
                                                      TRUNC (date_terminated);
                           l_clev_tbl_in (1).trn_code := 'TRF';
                           ---check the actual code
                           l_clev_tbl_in (1).term_cancel_source := 'IBTRANSFER';
                           If TRUNC (date_terminated)<= trunc(sysdate) Then
                                l_clev_tbl_in (1).sts_code  := l_sts_code;
                           End If;

                           okc_contract_pub.update_contract_line
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_clev_tbl               => l_clev_tbl_in,
                                       x_clev_tbl               => l_clev_tbl_out
                                      );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'okc_contract_pub.update_contract_line(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;
                        END IF;

                        date_terminated := NULL;
                        oks_ib_util_pvt.check_termcancel_lines
                                                    (p_kdtl_tbl (l_ctr).hdr_id,
                                                     'TL',
                                                     'T',
                                                     date_terminated
                                                    );

                        IF date_terminated IS NOT NULL
                        THEN
                           get_sts_code ('TERMINATED', NULL, l_ste_code, l_sts_code);

                           l_chrv_tbl_in (1).ID := p_kdtl_tbl (l_ctr).hdr_id;
                           l_chrv_tbl_in (1).date_terminated := TRUNC (date_terminated);
                           l_chrv_tbl_in (1).trn_code := 'TRF';
                           l_chrv_tbl_in (1).term_cancel_source := 'IBTRANSFER';
                           If TRUNC (date_terminated)<= trunc(sysdate) Then
                                l_chrv_tbl_in (1).sts_code  := l_sts_code;
                           End If;

                           okc_contract_pub.update_contract_header
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_chrv_tbl               => l_chrv_tbl_in,
                                       x_chrv_tbl               => l_chrv_tbl_out
                                      );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                     g_module_current
                                  || '.Update_Hdr_Dates.external_call.after',
                                     'okc_contract_pub.update_contract_header(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;
                        END IF;
                     ELSIF l_ste_code = 'ENTERED'
                     THEN
                        IF TRUNC (p_kdtl_tbl (l_ctr).prod_edt) <
                                                              TRUNC (l_trfdt)
                        THEN
                           l_create_contract := 'N';
                           l_trfdt := p_kdtl_tbl (l_ctr).prod_edt + 1;
                        ELSE
                           l_create_contract := 'Y';
                        END IF;

		      -- added for the bug # 6000133
		      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

			oks_change_status_pvt.update_line_status
                           (x_return_status           => l_return_status,
                            x_msg_data                => x_msg_data,
                            x_msg_count               => x_msg_count,
                            p_init_msg_list           => 'F',
                            p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                            p_cle_id                  => p_kdtl_tbl (l_ctr).object_line_id,
                            p_new_sts_code            => l_sts_code,
                            p_canc_reason_code        => 'TRANSFER',
                            p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                            p_old_ste_code            => 'ENTERED',
                            p_new_ste_code            => 'CANCELLED',
                            p_term_cancel_source      => 'IBTRANSFER',
                            p_date_cancelled          => TRUNC (l_trfdt),
                            p_comments                => NULL,
                            p_validate_status         => 'N'
                           );

                        IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                           )
                        THEN
                           fnd_log.STRING
                              (fnd_log.level_event,
                               g_module_current || '.CREATE_K_SYSTEM_TRF',
                                  'oks_change_status_pvt.Update_line_status(Return status ='
                               || l_return_status
                               || ')'
                              );
                        END IF;

                        IF NOT l_return_status = okc_api.g_ret_sts_success
                        THEN
                           RAISE g_exception_halt_validation;
                        END IF;

                        l_inst_dtls_tbl (l_ptr).date_cancelled :=
                                                               TRUNC (l_trfdt);
                        date_cancelled := NULL;
                        oks_ib_util_pvt.check_termcancel_lines
                                           (p_kdtl_tbl (l_ctr).service_line_id,
                                            'SL',
                                            'C',
                                            date_cancelled
                                           );

                        IF date_cancelled IS NOT NULL
                        THEN

		      -- added for the bug # 6000133
		      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

			   oks_change_status_pvt.update_line_status
                              (x_return_status           => l_return_status,
                               x_msg_data                => x_msg_data,
                               x_msg_count               => x_msg_count,
                               p_init_msg_list           => 'F',
                               p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                               p_cle_id                  => p_kdtl_tbl (l_ctr).service_line_id,
                               p_new_sts_code            => l_sts_code,
                               p_canc_reason_code        => 'TRANSFER',
                               p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                               p_old_ste_code            => 'ENTERED',
                               p_new_ste_code            => 'CANCELLED',
                               p_term_cancel_source      => 'IBTRANSFER',
                               p_date_cancelled          => TRUNC
                                                               (date_cancelled),
                               p_comments                => NULL,
                               p_validate_status         => 'N'
                              );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'okc_contract_pub.update_contract_line(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;
                        END IF;

                        date_cancelled := NULL;
                        oks_ib_util_pvt.check_termcancel_lines
                                                    (p_kdtl_tbl (l_ctr).hdr_id,
                                                     'TL',
                                                     'C',
                                                     date_cancelled
                                                    );

                        IF date_cancelled IS NOT NULL
                        THEN

		      -- added for the bug # 6000133
		      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

                           oks_change_status_pvt.update_header_status
                              (x_return_status           => l_return_status,
                               x_msg_data                => x_msg_data,
                               x_msg_count               => x_msg_count,
                               p_init_msg_list           => 'F',
                               p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                               p_new_sts_code            => l_sts_code,
                               p_canc_reason_code        => 'TRANSFER',
                               p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                               p_comments                => NULL,
                               p_term_cancel_source      => 'IBTRANSFER',
                               p_date_cancelled          => TRUNC
                                                               (date_cancelled),
                               p_validate_status         => 'N'
                              );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'OKS_WF_K_PROCESS_PVT.cancel_contract(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;
                        END IF;
                     /*E4*/
                     END IF;                          -- ste_code <> 'ENTERED'

                     l_date_terminated := NULL;
                     l_subline_price := NULL;

                     OPEN l_subline_csr (p_kdtl_tbl (l_ctr).object_line_id);

                     FETCH l_subline_csr
                      INTO l_date_terminated, l_subline_price;

                     CLOSE l_subline_csr;

                     l_inst_dtls_tbl (l_ptr).transaction_date :=
                                              (p_kdtl_tbl (l_ctr).transaction_date);
                     l_inst_dtls_tbl (l_ptr).transaction_type := 'TRF';
                     l_inst_dtls_tbl (l_ptr).system_id :=
                                                  p_kdtl_tbl (l_ctr).system_id;
                     l_inst_dtls_tbl (l_ptr).transfer_option := l_trf_option;
                     l_inst_dtls_tbl (l_ptr).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
                     l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                                               l_subline_price;
                     --l_kdtl_tbl( l_ctr ).service_amount;
                     l_inst_dtls_tbl (l_ptr).instance_qty_new :=
                                                     p_kdtl_tbl (l_ctr).cp_qty;
                     l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                     l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                     l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                     l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                     l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                     l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                     l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                     l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                     l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                     l_inst_dtls_tbl (l_ptr).new_customer :=
                                             p_kdtl_tbl (l_ctr).old_account_id;
                     l_inst_dtls_tbl (l_ptr).new_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                     l_inst_dtls_tbl (l_ptr).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
                     l_inst_dtls_tbl (l_ptr).instance_qty_old :=
                                                     p_kdtl_tbl (l_ctr).cp_qty;
                     l_inst_dtls_tbl (l_ptr).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                     l_inst_dtls_tbl (l_ptr).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                     l_inst_dtls_tbl (l_ptr).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                     l_inst_dtls_tbl (l_ptr).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                     l_inst_dtls_tbl (l_ptr).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                     l_inst_dtls_tbl (l_ptr).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                     l_inst_dtls_tbl (l_ptr).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                     l_inst_dtls_tbl (l_ptr).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                     l_inst_dtls_tbl (l_ptr).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                     l_inst_dtls_tbl (l_ptr).old_customer :=
                                             p_kdtl_tbl (l_ctr).old_account_id;
                     l_inst_dtls_tbl (l_ptr).old_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                     l_ptr := l_ptr + 1;
                     launch_workflow
                        (   'INSTALL BASE ACTIVITY : TRANSFER TERMINATE  SUBLINE '
                         || fnd_global.local_chr (10)
                         || 'Contract Number       :                     '
                         || get_contract_number (p_kdtl_tbl (l_ctr).hdr_id)
                         || fnd_global.local_chr (10)
                         || 'Service Terminated    :                     '
                         || l_service_name
                        );

                     /*---------------------------------------------------------
                      Check if the Customer product transferred
                      is a part of System Transfer.
                      If SYstem id is Not null then SYsytem transfer
                      else Customer product Transfer.
                     -----------------------------------------------------------*/
                     IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.STRING (fnd_log.level_statement,
                                           g_module_current
                                        || '.CREATE_K_SYSTEM_TRF.system_trf',
                                           'System Id = '
                                        || p_kdtl_tbl (l_ctr).system_id
                                        || ',lse_id = '
                                        || p_kdtl_tbl (l_ctr).lse_id
                                        || ',Merge Profile = '
                                        || fnd_profile.VALUE
                                                           ('OKS_MERGE_SYSTRF')
                                       );
                     END IF;

                     --If Contract is expired as of the transfer date, do not create a new contract.
                     IF l_create_contract = 'Y'
                     THEN
                        /*Sys trf*/
                        IF    p_kdtl_tbl (l_ctr).system_id IS NULL
                           OR p_kdtl_tbl (l_ctr).lse_id = 18
                           OR fnd_profile.VALUE ('OKS_MERGE_SYSTRF') = 'N'
                        THEN
                           l_contract_exist := 'F';
                           l_contract_merge := 'F';
                        /*Sys trf*/
                        ELSE
                           --Check if there exists a Contract for the System
                           l_contract_exist := 'F';
                           l_contract_merge := 'F';

                           FOR l_contracts_rec IN
                              l_contracts_csr
                                            (p_kdtl_tbl (l_ctr).system_id,
                                             p_kdtl_tbl (l_ctr).transaction_date,
                                             p_kdtl_tbl (l_ctr).old_account_id
                                            )
                           /*5*/
                           LOOP
                              IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                              THEN
                                 fnd_log.STRING
                                          (fnd_log.level_statement,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF.system_trf',
                                           'In Contracts_rec Loop'
                                          );
                              END IF;

                              IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                              THEN
                                 fnd_log.STRING
                                          (fnd_log.level_statement,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF.system_trf',
                                              'Source chr_id = '
                                           || p_kdtl_tbl (l_ctr).hdr_id
                                          );
                              END IF;

                              IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                              THEN
                                 fnd_log.STRING
                                          (fnd_log.level_statement,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF.system_trf',
                                              'Target chr Id = '
                                           || l_contracts_rec.new_contract_id
                                          );
                              END IF;

                              l_contract_exist := 'T';

                              IF l_contract_merge = 'T'
                              THEN
                                 EXIT;
                              END IF;

                              -- Check Header merging rules
                              header_merge_yn
                                 (p_source_chr_id      => p_kdtl_tbl (l_ctr).hdr_id,
                                  p_target_chr_id      => l_contracts_rec.new_contract_id,
                                  p_sts_code           => p_kdtl_tbl (l_ctr).hdr_sts,
                                  x_eligible_yn        => l_header_merge,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  x_return_status      => l_return_status
                                 );

                              IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                 )
                              THEN
                                 fnd_log.STRING
                                        (fnd_log.level_event,
                                            g_module_current
                                         || '.CREATE_K_SYSTEM_TRF',
                                            'header_merge_yn(Return status ='
                                         || l_return_status
                                         || ',Merging Rule = '
                                         || l_header_merge
                                         || ')'
                                        );
                              END IF;

                              l_merge_chr_id :=
                                               l_contracts_rec.new_contract_id;
                              l_line_found := 'F';

                              /*6*/
                              IF l_header_merge = 'Y'
                              THEN
                                 -- Check line_merge rules
                                 FOR l_topline_rec IN
                                    l_toplines_csr
                                       (l_merge_chr_id,
                                        p_kdtl_tbl (l_ctr).service_inventory_id
                                       )
                                 LOOP
                                    l_line_found := 'T';

                                    IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_statement,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF.system_trf',
                                              'Source line_id = '
                                           || p_kdtl_tbl (l_ctr).service_line_id
                                          );
                                    END IF;

                                    IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_statement,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF.system_trf',
                                              'Target line_id = '
                                           || l_topline_rec.cle_id
                                          );
                                    END IF;

                                    line_merge_yn
                                       (p_source_line_id      => p_kdtl_tbl
                                                                        (l_ctr).service_line_id,
                                        p_target_line_id      => l_topline_rec.cle_id,
                                        p_source_flag         => 'N',
                                        x_eligible_yn         => l_line_merge,
                                        x_msg_count           => x_msg_count,
                                        x_msg_data            => x_msg_data,
                                        x_return_status       => l_return_status
                                       );

                                    IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                       )
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_event,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF',
                                              'line_merge_yn(Return status ='
                                           || l_return_status
                                           || ',Merging Rule = '
                                           || l_line_merge
                                           || ')'
                                          );
                                    END IF;

                                    l_merge_line_id := l_topline_rec.cle_id;

                                    /*7*/
                                    IF l_line_merge = 'Y'
                                    THEN
                                       --Create Contract Subline
                                       create_contract_subline
                                          (p_kdtl_rec             => p_kdtl_tbl
                                                                        (l_ctr),
                                           p_hdr_id               => l_merge_chr_id,
                                           p_line_id              => l_merge_line_id,
                                           x_subline_id           => l_subline_id,
                                           x_update_top_line      => l_update_line,
                                           x_return_status        => l_return_status,
                                           x_msg_data             => x_msg_data,
                                           x_msg_count            => x_msg_count
                                          );

                                       IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                          )
                                       THEN
                                          fnd_log.STRING
                                             (fnd_log.level_event,
                                                 g_module_current
                                              || '.CREATE_K_SYSTEM_TRF',
                                                 'Create_contract_subline(Return status ='
                                              || l_return_status
                                              || ')'
                                             );
                                       END IF;

                                       IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                                       THEN
                                          RAISE g_exception_halt_validation;
                                       END IF;

                                       l_opr_instance_id :=
                                          get_operation_instance
                                                              (l_merge_chr_id,
                                                               'TRF'
                                                              );
                                       create_transaction_source
                                          (p_create_opr_inst       => 'N',
                                           p_source_code           => 'TRANSFER',
                                           p_target_chr_id         => l_merge_chr_id,
                                           p_source_line_id        => p_kdtl_tbl
                                                                         (l_ctr
                                                                         ).object_line_id,
                                           p_source_chr_id         => p_kdtl_tbl
                                                                         (l_ctr
                                                                         ).hdr_id,
                                           p_target_line_id        => l_subline_id,
                                           x_oper_instance_id      => l_opr_instance_id,
                                           x_return_status         => l_return_status,
                                           x_msg_count             => x_msg_count,
                                           x_msg_data              => x_msg_data
                                          );

                                       IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                          )
                                       THEN
                                          fnd_log.STRING
                                             (fnd_log.level_event,
                                                 g_module_current
                                              || '.CREATE_K_SYSTEM_TRF',
                                                 'Create_transaction_source(Return status ='
                                              || l_return_status
                                              || ')'
                                             );
                                       END IF;

                                       IF NOT l_return_status = 'S'
                                       THEN
                                          RAISE g_exception_halt_validation;
                                       END IF;

                                       l_renewal_opr_instance_id :=
                                          get_operation_instance
                                                              (l_merge_chr_id,
                                                               'REN'
                                                              );

                                       IF l_renewal_opr_instance_id IS NULL
                                       THEN
                                          l_create_oper_instance := 'Y';
                                       ELSE
                                          l_create_oper_instance := 'N';
                                       END IF;

                                       create_source_links
                                          (p_create_opr_inst       => l_create_oper_instance,
                                           p_source_code           => 'TRANSFER',
                                           p_target_chr_id         => l_merge_chr_id,
                                           p_line_id               => p_kdtl_tbl
                                                                         (l_ctr
                                                                         ).object_line_id,
                                           p_target_line_id        => l_subline_id,
                                           p_txn_date              => p_kdtl_tbl
                                                                         (l_ctr
                                                                         ).transfer_date,
                                           x_oper_instance_id      => l_renewal_opr_instance_id,
                                           x_return_status         => l_return_status,
                                           x_msg_count             => x_msg_count,
                                           x_msg_data              => x_msg_data
                                          );

                                       IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                          )
                                       THEN
                                          fnd_log.STRING
                                             (fnd_log.level_event,
                                                 g_module_current
                                              || '.CREATE_K_SYSTEM_TRF',
                                                 'Create_source_links(Return status ='
                                              || l_return_status
                                              || ')'
                                             );
                                       END IF;

                                       IF NOT l_return_status = 'S'
                                       THEN
                                          RAISE g_exception_halt_validation;
                                       END IF;

                                       OPEN l_hdrdt_csr (l_merge_chr_id);

                                       FETCH l_hdrdt_csr
                                        INTO l_start_date, l_end_date;

                                       CLOSE l_hdrdt_csr;

                                       IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                                       THEN
                                          fnd_log.STRING
                                                   (fnd_log.level_statement,
                                                       g_module_current
                                                    || '.CREATE_K_SYSTEM_TRF',
                                                       'Header start date = '
                                                    || l_start_date
                                                    || ',Header End date = '
                                                    || l_end_date
                                                   );
                                       END IF;

                                       OPEN l_srvdt_csr (l_merge_line_id);

                                       FETCH l_srvdt_csr
                                        INTO l_srv_sdt, l_srv_edt;

                                       CLOSE l_srvdt_csr;

                                       IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                                       THEN
                                          fnd_log.STRING
                                                    (fnd_log.level_statement,
                                                        g_module_current
                                                     || '.CREATE_K_SYSTEM_TRF',
                                                        'Line start date = '
                                                     || l_srv_sdt
                                                     || ',Line End date = '
                                                     || l_srv_edt
                                                    );
                                       END IF;

                                       l_date_terminated := NULL;
                                       l_subline_price := NULL;

                                       OPEN l_subline_csr (l_subline_id);

                                       FETCH l_subline_csr
                                        INTO l_date_terminated,
                                             l_subline_price;

                                       CLOSE l_subline_csr;

                                       l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                                l_merge_chr_id;
                                       l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                                  l_start_date;
                                       l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                                    l_end_date;
                                       l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                                               l_merge_line_id;
                                       l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                                     l_srv_sdt;
                                       l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                                     l_srv_edt;
                                       l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                                                  l_subline_id;
                                       l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                               TRUNC (l_trfdt);
                                       --p_transfer_rec.transfer_date;
                                       l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                                       l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                                               l_subline_price;
                                       ---Update Billing Schedule
                                       create_billing_schedule
                                          (p_line_id            => l_merge_line_id,
                                           p_covlvl_id          => l_subline_id,
                                           p_period_start       => p_kdtl_tbl(l_ctr).period_start,
                                           p_start_date         => l_srv_sdt,
                                           p_end_date           => l_srv_edt,
                                           p_update_line        => l_update_line,
                                           x_return_status      => l_return_status,
                                           x_msg_data           => x_msg_data,
                                           x_msg_count          => x_msg_count
                                          );

                                       IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                          )
                                       THEN
                                          fnd_log.STRING
                                             (fnd_log.level_event,
                                                 g_module_current
                                              || '.CREATE_K_SYSTEM_TRF',
                                                 'Create_billing_schedule(Return status ='
                                              || l_return_status
                                              || ')'
                                             );
                                       END IF;

                                       IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                                       THEN
                                          RAISE g_exception_halt_validation;
                                       END IF;

                                       UPDATE okc_k_lines_b
                                          SET price_negotiated =
                                                 (SELECT NVL
                                                            (SUM
                                                                (NVL
                                                                    (price_negotiated,
                                                                     0
                                                                    )
                                                                ),
                                                             0
                                                            )
                                                    FROM okc_k_lines_b
                                                   WHERE cle_id =
                                                               l_merge_line_id
                                                     AND dnz_chr_id =
                                                                l_merge_chr_id)
                                        WHERE ID = l_merge_line_id;

                                       UPDATE oks_k_lines_b
                                          SET tax_amount =
                                                   NVL (tax_amount, 0)
                                                 + NVL ((SELECT tax_amount
                                                           FROM oks_k_lines_b
                                                          WHERE cle_id =
                                                                   l_subline_id),
                                                        0
                                                       )
                                        WHERE cle_id = l_merge_line_id;

                                       UPDATE okc_k_headers_b
                                          SET estimated_amount =
                                                 (SELECT NVL
                                                            (SUM
                                                                (NVL
                                                                    (price_negotiated,
                                                                     0
                                                                    )
                                                                ),
                                                             0
                                                            )
                                                    FROM okc_k_lines_b
                                                   WHERE dnz_chr_id =
                                                                l_merge_chr_id
                                                     AND lse_id IN (1, 19))
                                        WHERE ID = l_merge_chr_id;

                                       UPDATE oks_k_headers_b
                                          SET tax_amount =
                                                   NVL (tax_amount, 0)
                                                 + NVL ((SELECT tax_amount
                                                           FROM oks_k_lines_b
                                                          WHERE cle_id =
                                                                   l_subline_id),
                                                        0
                                                       )
                                        WHERE chr_id = l_merge_chr_id;

                                       -- Check Qa
                                       -- Get the qa check list id
                                       OPEN l_qa_csr (l_merge_chr_id);

                                       FETCH l_qa_csr
                                        INTO l_qcl_id;

                                       CLOSE l_qa_csr;

                                       okc_qa_check_pub.execute_qa_check_list
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => okc_api.g_false,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_qcl_id             => l_qcl_id,
                                           p_chr_id             => l_merge_chr_id,
                                           x_msg_tbl            => l_msg_tbl
                                          );

                                       IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                          )
                                       THEN
                                          fnd_log.STRING
                                             (fnd_log.level_event,
                                                 g_module_current
                                              || '.CREATE_K_SYSTEM_TRF',
                                                 'okc_qa_check_pub.execute_qa_check_list(Return status ='
                                              || x_return_status
                                              || ')'
                                             );
                                       END IF;

                                       IF x_return_status <>
                                                     okc_api.g_ret_sts_success
                                       THEN
                                          RAISE g_exception_halt_validation;
                                       END IF;

                                       l_max_severity := 'I';

                                       IF l_msg_tbl.COUNT > 0
                                       THEN
                                          i := l_msg_tbl.FIRST;

                                          LOOP
                                             IF l_msg_tbl (i).error_status =
                                                                          'E'
                                             THEN
                                                --'QA returned with errors. Post renewal stopped';
                                                EXIT;
                                             END IF;

                                             EXIT WHEN i = l_msg_tbl.LAST;
                                             i := l_msg_tbl.NEXT (i);
                                          END LOOP;
                                       END IF;                   --table count

                                       IF fnd_log.level_error >=
                                               fnd_log.g_current_runtime_level
                                       THEN
                                          fnd_log.STRING
                                                (fnd_log.level_error,
                                                    g_module_current
                                                 || '.CREATE_K_SYSTEM_TRF',
                                                    'qa Check list error'
                                                 || l_msg_tbl (i).error_status
                                                 || ','
                                                 || l_msg_tbl (i).DATA
                                                );
                                       END IF;

                                       IF l_msg_tbl (i).error_status = 'E'
                                       THEN
                                          -- Change the Contract status to QA_HOLD
                                          -- if the COntract is in either Signed or Active status
                                          OPEN l_hdr_sts_csr (l_merge_chr_id);

                                          FETCH l_hdr_sts_csr
                                           INTO l_hdr_sts;

                                          CLOSE l_hdr_sts_csr;

                                          get_sts_code (NULL,
                                                        l_hdr_sts,
                                                        l_ste_code,
                                                        l_sts_code
                                                       );

                                          IF l_ste_code IN
                                                         ('ACTIVE', 'SIGNED')
                                          THEN
                                             get_sts_code ('ENTERED',
                                                           NULL,
                                                           l_ste_code,
                                                           l_sts_code
                                                          );

                                             UPDATE okc_k_headers_b
                                                SET sts_code = l_sts_code,
                                                    date_approved = NULL,
                                                    date_signed = NULL
                                              WHERE ID = l_merge_chr_id;
                                                  /*bugfix for 6882512*/
 	                                              /*update status in okc_contacts table*/
 	                                              OKC_CTC_PVT.update_contact_stecode(p_chr_id => l_merge_chr_id,
 	                                                                             x_return_status=>l_return_status);

 	                                              IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
 	                                                 RAISE g_exception_halt_validation;
 	                                              END IF;
                                               /*bugfix for 6882512*/
                                             UPDATE okc_k_lines_b
                                                SET sts_code = l_sts_code
                                              WHERE dnz_chr_id =
                                                                l_merge_chr_id;

                                             l_wf_attr_details.contract_id :=
                                                                l_merge_chr_id;
                                             l_wf_attr_details.irr_flag := 'Y';
                                             l_wf_attr_details.process_type :=
                                                                      'MANUAL';
                                             l_wf_attr_details.negotiation_status :=
                                                                       'DRAFT';
                                             oks_wf_k_process_pvt.launch_k_process_wf
                                                (p_api_version        => 1,
                                                 p_init_msg_list      => 'T',
                                                 p_wf_attributes      => l_wf_attr_details,
                                                 x_return_status      => x_return_status,
                                                 x_msg_count          => x_msg_count,
                                                 x_msg_data           => x_msg_data
                                                );
                                          END IF;
                                       END IF;

                                       launch_workflow
                                          (   'INSTALL BASE ACTIVITY : Transfer '
                                           || fnd_global.local_chr (10)
                                           || 'Contract Number       :       '
                                           || get_contract_number
                                                               (l_merge_chr_id)
                                           || fnd_global.local_chr (10)
                                           || 'Covered Product line merged into Contract     :       '
                                           || p_kdtl_tbl (l_ctr).old_cp_id
                                          );
                                       l_contract_merge := 'T';
                                       EXIT;
                                    /*End If7*/
                                    END IF;
                                 END LOOP;

                                 --If line merge fails Or l_line_found = 'F'

                                 /*8*/
                                 IF l_line_merge = 'N' OR l_line_found = 'F'
                                 THEN
                                    -- Create Top line
                                    create_contract_line
                                         (p_kdtl_rec           => p_kdtl_tbl
                                                                        (l_ctr),
                                          p_hdr_id             => l_merge_chr_id,
                                          x_return_status      => l_return_status,
                                          x_msg_data           => x_msg_data,
                                          x_line_id            => l_line_id,
                                          x_msg_count          => x_msg_count
                                         );

                                    IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                       )
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_event,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF',
                                              'Create_Contract_line(Return status = '
                                           || l_return_status
                                          );
                                    END IF;

                                    IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                                    THEN
                                       RAISE g_exception_halt_validation;
                                    END IF;

                                    IF     p_kdtl_tbl (l_ctr).coverage_id IS NOT NULL
                                       AND p_kdtl_tbl (l_ctr).standard_cov_yn =
                                                                           'N'
                                    THEN
                                       oks_coverages_pub.create_adjusted_coverage
                                          (p_api_version                  => l_api_version,
                                           p_init_msg_list                => l_init_msg_list,
                                           x_return_status                => l_return_status,
                                           x_msg_count                    => x_msg_count,
                                           x_msg_data                     => x_msg_data,
                                           p_source_contract_line_id      => p_kdtl_tbl
                                                                                (l_ctr
                                                                                ).service_line_id,
                                           p_target_contract_line_id      => l_line_id,
                                           x_actual_coverage_id           => l_coverage_id
                                          );

                                       IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                          )
                                       THEN
                                          fnd_log.STRING
                                             (fnd_log.level_event,
                                                 g_module_current
                                              || '.CREATE_K_SYSTEM_TRF',
                                                 'Oks_coverages_pub.create_adjusted_coverage(Return status = '
                                              || l_return_status
                                              || ')'
                                             );
                                       END IF;

                                       IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                                       THEN
                                          RAISE g_exception_halt_validation;
                                       END IF;

                                       UPDATE oks_k_lines_b
                                          SET coverage_id = l_coverage_id,
                                              standard_cov_yn = 'N'
                                        WHERE cle_id = l_line_id;
                                    END IF;


                                   oks_coverages_pvt.create_k_coverage_ext
                                       (p_api_version        => 1,
                                        p_init_msg_list      => 'T',
                                        p_src_line_id        => p_kdtl_tbl
                                                                        (l_ctr).service_line_id,
                                        p_tgt_line_id        => l_line_id,
                                        x_return_status      => l_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data
                                       );

                                    IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                       )
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_event,
                                              g_module_current
                                           || '..after_coverage_ext',
                                              'OKS_COVERAGES_PVT.Create_K_coverage_ext(Return status = '
                                           || l_return_status
                                           || ')'
                                          );
                                    END IF;

                                    IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                                    THEN
                                       okc_api.set_message
                                             (g_app_name,
                                              g_required_value,
                                              g_col_name_token,
                                              'Coverage Extn creation error '
                                             );
                                       RAISE g_exception_halt_validation;
                                    END IF;

                                    create_contract_subline
                                          (p_kdtl_rec             => p_kdtl_tbl
                                                                        (l_ctr),
                                           p_hdr_id               => l_merge_chr_id,
                                           x_subline_id           => l_subline_id,
                                           x_update_top_line      => l_update_line,
                                           p_line_id              => l_line_id,
                                           x_return_status        => l_return_status,
                                           x_msg_data             => x_msg_data,
                                           x_msg_count            => x_msg_count
                                          );

                                    IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                       )
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_event,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF',
                                              'Create_contract_subline(Return status = '
                                           || l_return_status
                                           || ')'
                                          );
                                    END IF;

                                    IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                                    THEN
                                       RAISE g_exception_halt_validation;
                                    END IF;

                                    l_opr_instance_id :=
                                       get_operation_instance (l_merge_chr_id,
                                                               'TRF'
                                                              );
                                    create_transaction_source
                                       (p_create_opr_inst       => 'N',
                                        p_source_code           => 'TRANSFER',
                                        p_target_chr_id         => l_merge_chr_id,
                                        p_source_line_id        => p_kdtl_tbl
                                                                        (l_ctr).object_line_id,
                                        p_source_chr_id         => p_kdtl_tbl
                                                                        (l_ctr).hdr_id,
                                        p_target_line_id        => l_subline_id,
                                        x_oper_instance_id      => l_opr_instance_id,
                                        x_return_status         => l_return_status,
                                        x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data
                                       );

                                    IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                       )
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_event,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF',
                                              'Create_transaction_source(Return status ='
                                           || l_return_status
                                           || ')'
                                          );
                                    END IF;

                                    IF NOT l_return_status = 'S'
                                    THEN
                                       RAISE g_exception_halt_validation;
                                    END IF;

                                    l_renewal_opr_instance_id :=
                                       get_operation_instance (l_merge_chr_id,
                                                               'REN'
                                                              );

                                    IF l_renewal_opr_instance_id IS NULL
                                    THEN
                                       l_create_oper_instance := 'Y';
                                    ELSE
                                       l_create_oper_instance := 'N';
                                    END IF;

                                    create_source_links
                                       (p_create_opr_inst       => l_create_oper_instance,
                                        p_source_code           => 'TRANSFER',
                                        p_target_chr_id         => l_merge_chr_id,
                                        p_line_id               => p_kdtl_tbl
                                                                        (l_ctr).object_line_id,
                                        p_target_line_id        => l_subline_id,
                                        p_txn_date              => p_kdtl_tbl
                                                                        (l_ctr).transfer_date,
                                        x_oper_instance_id      => l_renewal_opr_instance_id,
                                        x_return_status         => l_return_status,
                                        x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data
                                       );

                                    IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                       )
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_event,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF',
                                              'Create_source_links(Return status ='
                                           || l_return_status
                                           || ')'
                                          );
                                    END IF;

                                    IF NOT l_return_status = 'S'
                                    THEN
                                       RAISE g_exception_halt_validation;
                                    END IF;

                                    OPEN l_hdrdt_csr (l_merge_chr_id);

                                    FETCH l_hdrdt_csr
                                     INTO l_start_date, l_end_date;

                                    CLOSE l_hdrdt_csr;

                                    IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                                    THEN
                                       fnd_log.STRING
                                                   (fnd_log.level_statement,
                                                       g_module_current
                                                    || '.CREATE_K_SYSTEM_TRF',
                                                       'Header start date = '
                                                    || l_start_date
                                                    || ',End date ='
                                                    || l_end_date
                                                   );
                                    END IF;

                                    OPEN l_srvdt_csr (l_line_id);

                                    FETCH l_srvdt_csr
                                     INTO l_srv_sdt, l_srv_edt;

                                    CLOSE l_srvdt_csr;

                                    IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                                    THEN
                                       fnd_log.STRING
                                                    (fnd_log.level_statement,
                                                        g_module_current
                                                     || '.CREATE_K_SYSTEM_TRF',
                                                        'Line start date = '
                                                     || l_srv_sdt
                                                     || ',End date ='
                                                     || l_srv_edt
                                                    );
                                    END IF;

                                    l_date_terminated := NULL;
                                    l_subline_price := NULL;

                                    OPEN l_subline_csr (l_subline_id);

                                    FETCH l_subline_csr
                                     INTO l_date_terminated, l_subline_price;

                                    CLOSE l_subline_csr;

                                    l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                                l_merge_chr_id;
                                    l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                                  l_start_date;
                                    l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                                    l_end_date;
                                    l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                                                     l_line_id;
                                    l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                                     l_srv_sdt;
                                    l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                                     l_srv_edt;
                                    --END IF;
                                    l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                                                  l_subline_id;
                                    l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                               TRUNC (l_trfdt);
                                    --p_transfer_rec.transfer_date;
                                    l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                                    l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                                               l_subline_price;
                                    --- Create Billing Schedule
                                    create_billing_schedule
                                          (p_line_id            => l_line_id,
                                           p_covlvl_id          => l_subline_id,
                                           p_period_start       => p_kdtl_tbl(l_ctr).period_start,
                                           p_start_date         => l_srv_sdt,
                                           p_end_date           => l_srv_edt,
                                           p_update_line        => l_update_line,
                                           x_return_status      => l_return_status,
                                           x_msg_data           => x_msg_data,
                                           x_msg_count          => x_msg_count
                                          );

                                    IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                       )
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_event,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF',
                                              'Create_billing_schedule(Return status = '
                                           || l_return_status
                                           || ')'
                                          );
                                    END IF;

                                    IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                                    THEN
                                       RAISE g_exception_halt_validation;
                                    END IF;

                                    UPDATE okc_k_lines_b
                                       SET price_negotiated =
                                              (SELECT NVL
                                                         (SUM
                                                             (NVL
                                                                 (price_negotiated,
                                                                  0
                                                                 )
                                                             ),
                                                          0
                                                         )
                                                 FROM okc_k_lines_b
                                                WHERE cle_id = l_line_id
                                                  AND dnz_chr_id =
                                                                l_merge_chr_id)
                                     WHERE ID = l_line_id;

                                    UPDATE oks_k_lines_b
                                       SET tax_amount =
                                                NVL (tax_amount, 0)
                                              + NVL ((SELECT tax_amount
                                                        FROM oks_k_lines_b
                                                       WHERE cle_id =
                                                                  l_subline_id),
                                                     0
                                                    )
                                     WHERE cle_id = l_line_id;

                                    UPDATE okc_k_headers_b
                                       SET estimated_amount =
                                              (SELECT NVL
                                                         (SUM
                                                             (NVL
                                                                 (price_negotiated,
                                                                  0
                                                                 )
                                                             ),
                                                          0
                                                         )
                                                 FROM okc_k_lines_b
                                                WHERE dnz_chr_id =
                                                                l_merge_chr_id
                                                  AND lse_id IN (1, 19))
                                     WHERE ID = l_merge_chr_id;

                                    UPDATE oks_k_headers_b
                                       SET tax_amount =
                                                NVL (tax_amount, 0)
                                              + NVL ((SELECT tax_amount
                                                        FROM oks_k_lines_b
                                                       WHERE cle_id =
                                                                  l_subline_id),
                                                     0
                                                    )
                                     WHERE chr_id = l_merge_chr_id;

                                    --  Check QA
                                    OPEN l_qa_csr (l_merge_chr_id);

                                    FETCH l_qa_csr
                                     INTO l_qcl_id;

                                    CLOSE l_qa_csr;

                                    okc_qa_check_pub.execute_qa_check_list
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => okc_api.g_false,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_qcl_id             => l_qcl_id,
                                           p_chr_id             => l_merge_chr_id,
                                           x_msg_tbl            => l_msg_tbl
                                          );

                                    IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                       )
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_event,
                                              g_module_current
                                           || '.CREATE_K_SYSTEM_TRF',
                                              'okc_qa_check_pub.execute_qa_check_list(Return status = '
                                           || x_return_status
                                           || ')'
                                          );
                                    END IF;

                                    IF x_return_status <>
                                                     okc_api.g_ret_sts_success
                                    THEN
                                       RAISE g_exception_halt_validation;
                                    END IF;

                                    l_max_severity := 'I';

                                    IF l_msg_tbl.COUNT > 0
                                    THEN
                                       i := l_msg_tbl.FIRST;

                                       LOOP
                                          IF l_msg_tbl (i).error_status = 'E'
                                          THEN
                                             --'QA returned with errors. ';
                                             EXIT;
                                          END IF;

                                          EXIT WHEN i = l_msg_tbl.LAST;
                                          i := l_msg_tbl.NEXT (i);
                                       END LOOP;
                                    END IF;                      --table count

                                    IF fnd_log.level_error >=
                                               fnd_log.g_current_runtime_level
                                    THEN
                                       fnd_log.STRING
                                                (fnd_log.level_error,
                                                    g_module_current
                                                 || '.CREATE_K_SYSTEM_TRF',
                                                    'qa Check list error'
                                                 || l_msg_tbl (i).error_status
                                                 || ','
                                                 || l_msg_tbl (i).DATA
                                                );
                                    END IF;

                                    IF l_msg_tbl (i).error_status = 'E'
                                    THEN
                                       -- Change the Contract status to Entered
                                       -- if the COntract is in either Signed or Active status
                                       OPEN l_hdr_sts_csr (l_merge_chr_id);

                                       FETCH l_hdr_sts_csr
                                        INTO l_hdr_sts;

                                       CLOSE l_hdr_sts_csr;

                                       get_sts_code (NULL,
                                                     l_hdr_sts,
                                                     l_ste_code,
                                                     l_sts_code
                                                    );

                                       IF l_ste_code IN ('ACTIVE', 'SIGNED')
                                       THEN
                                          get_sts_code ('ENTERED',
                                                        NULL,
                                                        l_ste_code,
                                                        l_sts_code
                                                       );

                                          UPDATE okc_k_headers_b
                                             SET sts_code = l_sts_code,
                                                 date_approved = NULL,
                                                 date_signed = NULL
                                           WHERE ID = l_merge_chr_id;
                              /*bugfix for 6882512*/
 	                                          /*update status in okc_contacts table*/
 	                                           OKC_CTC_PVT.update_contact_stecode(p_chr_id => l_merge_chr_id,
 	                                                                              x_return_status=>l_return_status);
 	                                           IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
 	                                              RAISE g_exception_halt_validation;
 	                                           END IF;
                            /*bugfix for 6882512*/
                                          UPDATE okc_k_lines_b
                                             SET sts_code = l_sts_code
                                           WHERE dnz_chr_id = l_merge_chr_id;

                                          l_wf_attr_details.contract_id :=
                                                                l_merge_chr_id;
                                          l_wf_attr_details.irr_flag := 'Y';
                                          l_wf_attr_details.process_type :=
                                                                      'MANUAL';
                                          l_wf_attr_details.negotiation_status :=
                                                                       'DRAFT';
                                          oks_wf_k_process_pvt.launch_k_process_wf
                                             (p_api_version        => 1,
                                              p_init_msg_list      => 'T',
                                              p_wf_attributes      => l_wf_attr_details,
                                              x_return_status      => x_return_status,
                                              x_msg_count          => x_msg_count,
                                              x_msg_data           => x_msg_data
                                             );
                                       END IF;
                                    END IF;

                                    launch_workflow
                                       (   'INSTALL BASE ACTIVITY : TRANSFER  '
                                        || fnd_global.local_chr (10)
                                        || 'Contract Number       :                     '
                                        || get_contract_number (l_merge_chr_id)
                                        || fnd_global.local_chr (10)
                                        || 'Service line merged in to COntract    :                     '
                                        || l_service_name
                                       );
                                    l_contract_merge := 'T';
                                 /*E7*/
                                 END IF;
                              /*E6*/
                              END IF;                  --If Header Merge fails
                           /*E5*/
                           END LOOP;
                        /*Sys trf*/
                        END IF;

                        ---If none of the existing SYstem COntracts Header merge satisfies  then

                        -- Create New Contract
                        /*8*/
                        IF l_contract_exist = 'F' OR l_contract_merge = 'F'
                        THEN
                           IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_statement,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                  'Header merge failed, Create a new contract.'
                                 );
                           END IF;

                           -- Create New Contract.
                           create_contract_header
                                           (p_kdtl_rec           => p_kdtl_tbl
                                                                        (l_ctr),
                                            x_msg_data           => x_msg_data,
                                            x_chr_id             => l_chr_id,
                                            x_msg_count          => x_msg_count,
                                            x_return_status      => l_return_status
                                           );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'Create_Contract_header(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           ---If new Contract is created in 'Entered' status launch workflow
                           l_launch_wf_yn := 'N';
                           OPEN l_Launch_WF_csr (l_chr_id);
                           FETCH l_Launch_WF_csr INTO l_launch_wf_yn;
                           CLOSE l_Launch_WF_csr ;



                           IF nvl(l_launch_wf_yn,'N') = 'Y'
                           THEN
                              l_wf_attr_details.contract_id := l_chr_id;
                              l_wf_attr_details.irr_flag := 'Y';
                              l_wf_attr_details.process_type := 'MANUAL';
                              l_wf_attr_details.negotiation_status := 'DRAFT';
                              oks_wf_k_process_pvt.launch_k_process_wf
                                       (p_api_version        => 1,
                                        p_init_msg_list      => 'T',
                                        p_wf_attributes      => l_wf_attr_details,
                                        x_return_status      => x_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data
                                       );
                           END IF;

                           create_contract_line
                                          (p_kdtl_rec           => p_kdtl_tbl
                                                                        (l_ctr),
                                           p_hdr_id             => l_chr_id,
                                           x_return_status      => l_return_status,
                                           x_msg_data           => x_msg_data,
                                           x_line_id            => l_line_id,
                                           x_msg_count          => x_msg_count
                                          );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                  (fnd_log.level_event,
                                   g_module_current || '.CREATE_K_SYSTEM_TRF',
                                      'Create_Contract_line(Return status = '
                                   || l_return_status
                                   || ')'
                                  );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           IF     p_kdtl_tbl (l_ctr).coverage_id IS NOT NULL
                              AND p_kdtl_tbl (l_ctr).standard_cov_yn = 'N'
                           THEN
                              oks_coverages_pub.create_adjusted_coverage
                                 (p_api_version                  => l_api_version,
                                  p_init_msg_list                => l_init_msg_list,
                                  x_return_status                => l_return_status,
                                  x_msg_count                    => x_msg_count,
                                  x_msg_data                     => x_msg_data,
                                  p_source_contract_line_id      => p_kdtl_tbl
                                                                        (l_ctr).service_line_id,
                                  p_target_contract_line_id      => l_line_id,
                                  x_actual_coverage_id           => l_coverage_id
                                 );

                              IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                 )
                              THEN
                                 fnd_log.STRING
                                    (fnd_log.level_event,
                                     g_module_current
                                     || '.CREATE_K_SYSTEM_TRF',
                                        'oks_coverages_pub.create_adjusted_coverage(Return status = '
                                     || l_return_status
                                     || ')'
                                    );
                              END IF;

                              IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                              THEN
                                 RAISE g_exception_halt_validation;
                              END IF;

                              UPDATE oks_k_lines_b
                                 SET coverage_id = l_coverage_id,
                                     standard_cov_yn = 'N'
                               WHERE cle_id = l_line_id;
                           END IF;

                                   oks_coverages_pvt.create_k_coverage_ext
                                       (p_api_version        => 1,
                                        p_init_msg_list      => 'T',
                                        p_src_line_id        => p_kdtl_tbl
                                                                        (l_ctr).service_line_id,
                                        p_tgt_line_id        => l_line_id,
                                        x_return_status      => l_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data
                                       );

                                    IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                       )
                                    THEN
                                       fnd_log.STRING
                                          (fnd_log.level_event,
                                              g_module_current
                                           || '..after_coverage_ext',
                                              'OKS_COVERAGES_PVT.Create_K_coverage_ext(Return status = '
                                           || l_return_status
                                           || ')'
                                          );
                                    END IF;

                                    IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                                    THEN
                                       okc_api.set_message
                                             (g_app_name,
                                              g_required_value,
                                              g_col_name_token,
                                              'Coverage Extn creation error '
                                             );
                                       RAISE g_exception_halt_validation;
                                    END IF;

                           create_contract_subline
                                          (p_kdtl_rec             => p_kdtl_tbl
                                                                        (l_ctr),
                                           p_hdr_id               => l_chr_id,
                                           x_subline_id           => l_subline_id,
                                           x_update_top_line      => l_update_line,
                                           p_line_id              => l_line_id,
                                           x_return_status        => l_return_status,
                                           x_msg_data             => x_msg_data,
                                           x_msg_count            => x_msg_count
                                          );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'create_contract_subline(Return status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           create_transaction_source
                              (p_create_opr_inst       => 'Y',
                               p_source_code           => 'TRANSFER',
                               p_target_chr_id         => l_chr_id,
                               p_source_line_id        => p_kdtl_tbl (l_ctr).object_line_id,
                               p_source_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                               p_target_line_id        => l_subline_id,
                               x_oper_instance_id      => l_opr_instance_id,
                               x_return_status         => l_return_status,
                               x_msg_count             => x_msg_count,
                               x_msg_data              => x_msg_data
                              );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'Create_transaction_source(Return status ='
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = 'S'
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           create_source_links
                              (p_create_opr_inst       => 'Y',
                               p_source_code           => 'TRANSFER',
                               p_target_chr_id         => l_chr_id,
                               p_line_id               => p_kdtl_tbl (l_ctr).object_line_id,
                               p_target_line_id        => l_subline_id,
                               p_txn_date              => p_kdtl_tbl (l_ctr).transfer_date,
                               x_oper_instance_id      => l_renewal_opr_instance_id,
                               x_return_status         => l_return_status,
                               x_msg_count             => x_msg_count,
                               x_msg_data              => x_msg_data
                              );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                  g_module_current || '.CREATE_K_SYSTEM_TRF',
                                     'Create_transaction_source(Return status ='
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = 'S'
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           l_date_terminated := NULL;
                           l_subline_price := NULL;

                           OPEN l_subline_csr (l_subline_id);

                           FETCH l_subline_csr
                            INTO l_date_terminated, l_subline_price;

                           CLOSE l_subline_csr;

                           l_inst_dtls_tbl (l_ptr).new_contract_id := l_chr_id;
                           l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                               TRUNC (l_trfdt);
                           --p_transfer_rec.transfer_date;
                           l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                                                     l_line_id;
                           l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                               TRUNC (l_trfdt);
                           --p_transfer_rec.transfer_date;
                           l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           -- END IF;
                           l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                                                  l_subline_id;
                           l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                               TRUNC (l_trfdt);
                           --p_transfer_rec.transfer_date;
                           l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                                               l_subline_price;

                           -- Fixed for bug 3751050
                           UPDATE okc_k_lines_b
                              SET price_negotiated =
                                     (SELECT NVL (SUM (NVL (price_negotiated,
                                                            0
                                                           )
                                                      ),
                                                  0
                                                 )
                                        FROM okc_k_lines_b
                                       WHERE cle_id = l_line_id
                                         AND dnz_chr_id = l_chr_id)
                            WHERE ID = l_line_id;

                           UPDATE oks_k_lines_b
                              SET tax_amount =
                                       NVL (tax_amount, 0)
                                     + NVL ((SELECT tax_amount
                                               FROM oks_k_lines_b
                                              WHERE cle_id = l_subline_id), 0)
                            WHERE cle_id = l_line_id;

                           UPDATE okc_k_headers_b
                              SET estimated_amount =
                                     (SELECT NVL (SUM (NVL (price_negotiated,
                                                            0
                                                           )
                                                      ),
                                                  0
                                                 )
                                        FROM okc_k_lines_b
                                       WHERE dnz_chr_id = l_chr_id
                                         AND lse_id IN (1, 19))
                            WHERE ID = l_chr_id;

                           UPDATE oks_k_headers_b
                              SET tax_amount =
                                       NVL (tax_amount, 0)
                                     + NVL ((SELECT tax_amount
                                               FROM oks_k_lines_b
                                              WHERE cle_id = l_subline_id), 0)
                            WHERE chr_id = l_chr_id;

                           IF p_kdtl_tbl (l_ctr).lse_id <> 18
                           THEN
                              -- Create Billing Schedule
                              OPEN l_srvdt_csr (l_line_id);

                              FETCH l_srvdt_csr
                               INTO l_srv_sdt, l_srv_edt;

                              CLOSE l_srvdt_csr;

                              create_billing_schedule
                                          (p_line_id            => l_line_id,
                                           p_covlvl_id          => l_subline_id,
                                           p_period_start       => p_kdtl_tbl(l_ctr).period_start,
                                           p_start_date         => l_srv_sdt,
                                           p_end_date           => l_srv_edt,
                                           p_update_line        => l_update_line,
                                           x_msg_data           => x_msg_data,
                                           x_msg_count          => x_msg_count,
                                           x_return_status      => l_return_status
                                          );

                              IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                 )
                              THEN
                                 fnd_log.STRING
                                    (fnd_log.level_event,
                                     g_module_current
                                     || '.CREATE_K_SYSTEM_TRF',
                                        'Create_billing_schedule(Return status = '
                                     || l_return_status
                                     || ')'
                                    );
                              END IF;

                              IF NOT l_return_status =
                                                     okc_api.g_ret_sts_success
                              THEN
                                 RAISE g_exception_halt_validation;
                              END IF;

                              /*UPDATE okc_k_lines_b
                              SET price_negotiated = ( SELECT NVL( SUM(NVL( price_negotiated, 0)),0 )
                                                       FROM okc_k_lines_b
                                                       WHERE cle_id = l_line_id
                                                       AND dnz_chr_id = l_chr_id)
                              WHERE id = l_line_id;

                              UPDATE okc_k_headers_b
                              SET estimated_amount = ( SELECT  NVL( SUM( NVL(price_negotiated,0) ), 0 )
                                                       FROM  okc_k_lines_b
                                                       WHERE  dnz_chr_id = l_chr_id
                                                       AND  lse_id in (1,19) )
                              WHERE id = l_chr_id;*/

                              -- Check Qa
                              OPEN l_qa_csr (l_chr_id);

                              FETCH l_qa_csr
                               INTO l_qcl_id;

                              CLOSE l_qa_csr;

                              okc_qa_check_pub.execute_qa_check_list
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => okc_api.g_false,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_qcl_id             => l_qcl_id,
                                           p_chr_id             => l_chr_id,
                                           x_msg_tbl            => l_msg_tbl
                                          );

                              IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                 )
                              THEN
                                 fnd_log.STRING
                                    (fnd_log.level_event,
                                     g_module_current
                                     || '.CREATE_K_SYSTEM_TRF',
                                        'okc_qa_check_pub.execute_qa_check_list(Return status = '
                                     || x_return_status
                                     || ')'
                                    );
                              END IF;

                              IF x_return_status <> okc_api.g_ret_sts_success
                              THEN
                                 RAISE g_exception_halt_validation;
                              END IF;

                              l_max_severity := 'I';

                              IF l_msg_tbl.COUNT > 0
                              THEN
                                 i := l_msg_tbl.FIRST;

                                 LOOP
                                    IF l_msg_tbl (i).error_status = 'E'
                                    THEN
                                       --'QA returned with errors. ';
                                       EXIT;
                                    END IF;

                                    EXIT WHEN i = l_msg_tbl.LAST;
                                    i := l_msg_tbl.NEXT (i);
                                 END LOOP;
                              END IF;                            --table count

                              IF fnd_log.level_error >=
                                               fnd_log.g_current_runtime_level
                              THEN
                                 fnd_log.STRING (fnd_log.level_error,
                                                    g_module_current
                                                 || '.CREATE_K_SYSTEM_TRF',
                                                    'qa Check list error'
                                                 || l_msg_tbl (i).error_status
                                                 || ','
                                                 || l_msg_tbl (i).DATA
                                                );
                              END IF;

                              IF l_msg_tbl (i).error_status = 'E'
                              THEN
                                 -- Change the Contract status to QA_HOLD
                                 -- if the COntract is in either Signed or Active status
                                 OPEN l_hdr_sts_csr (l_chr_id);

                                 FETCH l_hdr_sts_csr
                                  INTO l_hdr_sts;

                                 CLOSE l_hdr_sts_csr;

                                 get_sts_code (NULL,
                                               l_hdr_sts,
                                               l_ste_code,
                                               l_sts_code
                                              );

                                 IF l_ste_code IN ('ACTIVE', 'SIGNED')
                                 THEN
                                    get_sts_code ('ENTERED',
                                                  NULL,
                                                  l_ste_code,
                                                  l_sts_code
                                                 );

                                    UPDATE okc_k_headers_b
                                       SET sts_code = l_sts_code,
                                           date_approved = NULL,
                                           date_signed = NULL
                                     WHERE ID = l_chr_id;
                                     /* bugfix for 6882512*/
 	                                     /*update status in okc_contacts table*/
 	                                     OKC_CTC_PVT.update_contact_stecode(p_chr_id => l_chr_id,
 	                                                                        x_return_status=>l_return_status);

 	                                     IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
 	                                        RAISE g_exception_halt_validation;
 	          /*bugfix for 6882512*/                          END IF;

                                    UPDATE okc_k_lines_b
                                       SET sts_code = l_sts_code
                                     WHERE dnz_chr_id = l_chr_id;

                                    l_wf_attr_details.contract_id := l_chr_id;
                                    l_wf_attr_details.irr_flag := 'Y';
                                    l_wf_attr_details.process_type := 'MANUAL';
                                    l_wf_attr_details.negotiation_status :=
                                                                       'DRAFT';
                                    oks_wf_k_process_pvt.launch_k_process_wf
                                        (p_api_version        => 1,
                                         p_init_msg_list      => 'T',
                                         p_wf_attributes      => l_wf_attr_details,
                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data
                                        );
                                 END IF;
                              END IF;

                              launch_workflow
                                 (   'INSTALL BASE ACTIVITY : TRANSFER  '
                                  || fnd_global.local_chr (10)
                                  || 'Contract Number       :                     '
                                  || get_contract_number (l_chr_id)
                                  || fnd_global.local_chr (10)
                                  || 'New Contract Created   :                     '
                                  || l_service_name
                                 );
                           END IF;
                        /*E8*/
                        END IF;

                        --Open l_hdr_sts_csr(l_chr_id);
                        --Fetch l_hdr_Sts_csr into l_hdr_sts;
                        --Close l_hdr_sts_csr;
                        --Removed trunc for transatcion date as the cursor to retrieve contracts
                        --to merge for system transfers fails to return K. The cursor looks at the time value compnent.
                        l_inst_dtls_tbl (l_ptr).transaction_date :=
                                              (p_kdtl_tbl (l_ctr).transaction_date);
                        l_inst_dtls_tbl (l_ptr).transaction_type := 'TRF';
                        l_inst_dtls_tbl (l_ptr).system_id :=
                                                  p_kdtl_tbl (l_ctr).system_id;
                        l_inst_dtls_tbl (l_ptr).transfer_option :=
                                                                  l_trf_option;
                        l_inst_dtls_tbl (l_ptr).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
                        --l_inst_dtls_tbl(l_ptr).INSTANCE_AMT_NEW          := p_kdtl_tbl( l_ctr ).service_amount;
                        l_inst_dtls_tbl (l_ptr).instance_qty_new :=
                                                     p_kdtl_tbl (l_ctr).cp_qty;
                        l_inst_dtls_tbl (l_ptr).new_customer :=
                                             p_kdtl_tbl (l_ctr).new_account_id;
                        --l_inst_dtls_tbl(l_ptr).NEW_K_STATUS              := l_hdr_sts;
                        l_inst_dtls_tbl (l_ptr).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
                        l_inst_dtls_tbl (l_ptr).instance_qty_old :=
                                                     p_kdtl_tbl (l_ctr).cp_qty;
                        l_inst_dtls_tbl (l_ptr).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                        l_inst_dtls_tbl (l_ptr).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                        l_inst_dtls_tbl (l_ptr).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                        l_inst_dtls_tbl (l_ptr).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                        l_inst_dtls_tbl (l_ptr).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                        l_inst_dtls_tbl (l_ptr).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                        l_inst_dtls_tbl (l_ptr).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                        l_inst_dtls_tbl (l_ptr).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                        l_inst_dtls_tbl (l_ptr).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                        l_inst_dtls_tbl (l_ptr).old_customer :=
                                             p_kdtl_tbl (l_ctr).old_account_id;
                        l_inst_dtls_tbl (l_ptr).old_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                     END IF;
                  /*E2*/
                  END IF;
               END IF;

               --errorout_n('l_inst_dtls_tbl.count'||l_inst_dtls_tbl.count);
               IF l_inst_dtls_tbl.COUNT <> 0
               THEN
                  IF l_old_cp_id <> p_kdtl_tbl (l_ctr).old_cp_id
                  THEN
                     OPEN l_refnum_csr (p_kdtl_tbl (l_ctr).old_cp_id);

                     FETCH l_refnum_csr
                      INTO l_ref_num;

                     CLOSE l_refnum_csr;

                     l_parameters :=
                           ' Old CP :'
                        || p_kdtl_tbl (l_ctr).old_cp_id
                        || ','
                        || 'Item Id:'
                        || p_kdtl_tbl (l_ctr).prod_inventory_item
                        || ','
                        || 'Old Customer :'
                        || p_kdtl_tbl (l_ctr).old_account_id
                        || ','
                        || 'System Id:'
                        || p_kdtl_tbl (l_ctr).system_id
                        || ','
                        || 'Transaction type :'
                        || 'TRF'
                        || ','
                        || ' Transaction date :'
                        || TRUNC(p_kdtl_tbl (l_ctr).transaction_date)
                        || ','
                        || 'New Customer:'
                        || p_kdtl_tbl (l_ctr).new_account_id;
                     --oks_instance_history
                     l_old_cp_id := p_kdtl_tbl (l_ctr).old_cp_id;
                     l_insthist_rec.instance_id :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
                     l_insthist_rec.transaction_type := 'TRF';
                     l_insthist_rec.transaction_date :=
                                              (p_kdtl_tbl (l_ctr).transaction_date);
                     l_insthist_rec.reference_number := l_ref_num;
                     l_insthist_rec.PARAMETERS := l_parameters;
                     oks_ins_pvt.insert_row
                                          (p_api_version        => 1.0,
                                           p_init_msg_list      => 'T',
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_insv_rec           => l_insthist_rec,
                                           x_insv_rec           => x_insthist_rec
                                          );

                     IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                        )
                     THEN
                        fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_K_SYSTEM_TRF',
                                    'oks_ins_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
                     END IF;

                     x_return_status := l_return_status;

                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN
                        x_return_status := l_return_status;
                        RAISE g_exception_halt_validation;
                     END IF;

                     l_instparent_id := x_insthist_rec.ID;
                  END IF;

                  --errorout_n('in inst l_inst_dtls_tbl.count'||l_inst_dtls_tbl.count);
                  FOR l_ctr IN 1 .. l_inst_dtls_tbl.COUNT
                  LOOP
                     l_inst_dtls_tbl (l_ctr).ins_id := l_instparent_id;

                     OPEN l_hdr_sts_csr
                                      (l_inst_dtls_tbl (l_ctr).new_contract_id
                                      );

                     FETCH l_hdr_sts_csr
                      INTO l_hdr_sts;

                     CLOSE l_hdr_sts_csr;              -- Vigandhi 03-Feb-2004

                     l_inst_dtls_tbl (l_ctr).new_k_status := l_hdr_sts;
                  -- FIx for bug 2408704
                  END LOOP;

                  --oks_inst_history_details
                  oks_ihd_pvt.insert_row (p_api_version        => 1.0,
                                          p_init_msg_list      => 'T',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => l_msg_count,
                                          x_msg_data           => l_msg_data,
                                          p_ihdv_tbl           => l_inst_dtls_tbl,
                                          x_ihdv_tbl           => x_inst_dtls_tbl
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_K_SYSTEM_TRF',
                                    'oks_ihd_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
                  END IF;

                  x_return_status := l_return_status;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;
                     RAISE g_exception_halt_validation;
                  END IF;
		  If date_terminated is not null or date_cancelled is not null Then
	    	      Open l_hdr_sts_csr(p_kdtl_tbl (l_ctr).hdr_id);
	              Fetch l_hdr_sts_csr into l_hdr_sts;
	              Close l_hdr_sts_csr;

		        If p_kdtl_tbl (l_ctr).system_id Is Null Then
	                  Update oks_inst_hist_details set new_k_status = l_hdr_sts
		            Where ins_id = l_instparent_id and new_contract_id = p_kdtl_tbl (l_ctr).hdr_id;
	              Else
	                  Update oks_inst_hist_details set new_k_status = l_hdr_sts
		            Where system_id = p_kdtl_tbl (l_ctr).system_id  and new_contract_id = p_kdtl_tbl (l_ctr).hdr_id
                        and transaction_date = p_kdtl_tbl (l_ctr).transaction_date;
                    End If;

                  End If;




               END IF;
            END IF;

            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
         END LOOP;
      END IF;

      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END create_k_system_transfer;

-----Terminate of Customer product
   PROCEDURE create_contract_terminate (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_serv_csr (p_serv_id NUMBER)
      IS
         SELECT t.description NAME
           FROM mtl_system_items_tl t
          WHERE t.inventory_item_id = p_serv_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND ROWNUM < 2;

      CURSOR l_refnum_csr (p_cp_id NUMBER)
      IS
         SELECT instance_number
           FROM csi_item_instances
          WHERE instance_id = p_cp_id;


      Cursor l_hdr_sts_csr(p_hdr_id Number)
      Is
      Select sts_code
      From Okc_k_headers_all_b
      WHere id = p_hdr_id;

      l_hdr_status               Varchar2(240);

      l_ref_num                  VARCHAR2 (30);
      x_inst_dtls_tbl            oks_ihd_pvt.ihdv_tbl_type;
      l_inst_dtls_tbl            oks_ihd_pvt.ihdv_tbl_type;
      l_instparent_id            NUMBER;
      l_old_cp_id                NUMBER;
      l_insthist_rec             oks_ins_pvt.insv_rec_type;
      x_insthist_rec             oks_ins_pvt.insv_rec_type;
      l_parameters               VARCHAR2 (2000);
      l_service_name             VARCHAR2 (2000);
      --Contract Line Table
      l_clev_tbl_in              okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out             okc_contract_pub.clev_tbl_type;
      --SalesCredit
      l_salescredit_tbl_line     oks_extwarprgm_pvt.salescredit_tbl;
      l_salescredit_tbl_hdr      oks_extwarprgm_pvt.salescredit_tbl;
      l_line_rec                 k_line_service_rec_type;
      l_covd_rec                 k_line_covered_level_rec_type;
      l_available_yn             CHAR;
      l_return_status            VARCHAR2 (5)     := okc_api.g_ret_sts_success;
      l_chrid                    NUMBER                                := NULL;
      l_lineid                   NUMBER                                := NULL;
      l_days                     NUMBER                                 := 0;
      l_day1price                NUMBER                                 := 0;
      l_oldamt                   NUMBER                                 := 0;
      l_ctr                      NUMBER                                 := 0;
      l_terminate_rec            okc_terminate_pvt.terminate_in_cle_rec;
      l_api_version     CONSTANT NUMBER                                 := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)               := okc_api.g_false;
      l_index                    VARCHAR2 (2000);
      l_trmdt                    DATE;
      l_suppress_credit          VARCHAR2 (2)                           := 'N';
      l_full_credit              VARCHAR2 (2)                           := 'N';
      l_ste_code                 VARCHAR2 (30);
      l_sts_code                 VARCHAR2 (30);
      date_terminated            DATE;
      date_cancelled             DATE;
      l_alllines_terminated      VARCHAR2 (1);
      l_alllines_cancelled       VARCHAR2 (1);
      l_chrv_tbl_in              okc_contract_pub.chrv_tbl_type;
      l_chrv_tbl_out             okc_contract_pub.chrv_tbl_type;
      l_ptr                      NUMBER;
      l_term_date_flag           VARCHAR2 (1);
      l_credit_amount            VARCHAR2 (50);
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.CREATE_CONTRACT_IBTERMINATE.',
                         'count = ' || p_kdtl_tbl.COUNT || ')'
                        );
      END IF;

      l_old_cp_id := 0;

      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP

          get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).hdr_sts,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code = 'HOLD'
            THEN
               l_return_status := okc_api.g_ret_sts_error;

               IF fnd_log.level_error >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_error,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBTERMINATE.ERROR',
                                  'Contract in QA_HOLD status'
                                 );
               END IF;

               okc_api.set_message (g_app_name,
                                    g_invalid_value,
                                    g_col_name_token,
                                       'Termination not allowed .Contract '
                                    || p_kdtl_tbl (l_ctr).contract_number
                                    || 'is in QA_HOLD status'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
         END LOOP;
      END IF;

      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP
            l_ptr := 1;
            --Fix for Bug 5406201

            l_clev_tbl_in.delete;
            l_chrv_tbl_in.delete;
            l_inst_dtls_tbl.DELETE;


            okc_context.set_okc_org_context
                                           (p_kdtl_tbl (l_ctr).hdr_org_id,
                                            p_kdtl_tbl (l_ctr).organization_id
                                           );
            get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).prod_sts_code,
                          l_ste_code,
                          l_sts_code
                         );

            IF l_ste_code NOT IN ('ENTERED','EXPIRED') /*Bug:7555733*/
            THEN
               l_trmdt := p_kdtl_tbl (l_ctr).termination_date;

               IF (TRUNC (l_trmdt) <= TRUNC (p_kdtl_tbl (l_ctr).prod_sdt))
               THEN
                  l_trmdt := p_kdtl_tbl (l_ctr).prod_sdt;
               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING
                       (fnd_log.level_statement,
                        g_module_current || '.CREATE_CONTRACT_IBTERMINATE',
                           'OKS Raise credit memo profile option value ='
                        || fnd_profile.VALUE
                                           ('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT')
                       );
               END IF;

               /*IF    fnd_profile.VALUE('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT') = 'YES'
                  OR fnd_profile.VALUE('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT') IS NULL THEN
                    l_suppress_credit := 'N';
               ELSE
                    l_suppress_credit := 'Y';
               END IF;*/
               l_credit_amount :=
                  oks_ib_util_pvt.get_credit_option
                                           (p_kdtl_tbl (l_ctr).party_id,
                                            p_kdtl_tbl (l_ctr).hdr_org_id,
                                            p_kdtl_tbl (l_ctr).termination_date
                                           );

               IF UPPER (l_credit_amount) = 'FULL'
               THEN
                  l_full_credit := 'Y';
                  l_suppress_credit := 'N';
                  --l_trmdt := p_kdtl_tbl( l_ctr ).prod_sdt;
                  l_term_date_flag := 'N';
               ELSIF UPPER (l_credit_amount) = 'NONE'
               THEN
                  l_suppress_credit := 'Y';
                  l_full_credit := 'N';
                  l_term_date_flag := 'N';
               ELSIF UPPER (l_credit_amount) = 'CALCULATED'
               THEN
                  l_suppress_credit := 'N';
                  l_full_credit := 'N';
                  l_term_date_flag := 'N';
               END IF;

               IF TRUNC (p_kdtl_tbl (l_ctr).prod_edt) < TRUNC (l_trmdt)
               THEN
                  l_trmdt := p_kdtl_tbl (l_ctr).prod_edt + 1;
                  l_suppress_credit := 'Y';
                  l_full_credit := 'N';
                  l_term_date_flag := 'Y';
               END IF;

               oks_bill_rec_pub.pre_terminate_cp
                                (p_calledfrom                => -1,
                                 p_cle_id                    => p_kdtl_tbl
                                                                        (l_ctr).object_line_id,
                                 p_termination_date          => TRUNC (l_trmdt),
                                 p_terminate_reason          => 'EXP',
                                 p_override_amount           => NULL,
                                 p_con_terminate_amount      => NULL,
                                 p_termination_amount        => NULL,
                                 p_suppress_credit           => l_suppress_credit,
                                 p_full_credit               => l_full_credit,
                                 --'N',
                                 p_term_date_flag            => l_term_date_flag,
                                 p_term_cancel_source        => 'IBTERMINATE',
                                 x_return_status             => l_return_status
                                );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                      g_module_current || '.CREATE_CONTRACT_IBTERMINATE',
                         'oks_bill_rec_pub.Pre_terminate_cp(Return status = '
                      || l_return_status
                      || ')'
                     );
               END IF;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  RAISE g_exception_halt_validation;
               END IF;

               l_inst_dtls_tbl (l_ptr).subline_date_terminated :=
                                                               TRUNC (l_trmdt);
               ---Terminate top line if all the sublines are terminated due to Instance termination
               date_terminated := NULL;
               oks_ib_util_pvt.check_termcancel_lines
                                           (p_kdtl_tbl (l_ctr).service_line_id,
                                            'SL',
                                            'T',
                                            date_terminated
                                           );

               IF date_terminated IS NOT NULL
               THEN
                  get_sts_code ('TERMINATED', NULL, l_ste_code, l_sts_code);

                  l_clev_tbl_in (1).ID := p_kdtl_tbl (l_ctr).service_line_id;
                  l_clev_tbl_in (1).date_terminated := TRUNC (date_terminated);
                  l_clev_tbl_in (1).trn_code := 'EXP';
                  ---check the actual code
                  l_clev_tbl_in (1).term_cancel_source := 'IBTERMINATE';
                  If TRUNC (date_terminated)<= trunc(sysdate) Then
                        l_clev_tbl_in (1).sts_code := l_sts_code;
                  End If;

                  okc_contract_pub.update_contract_line
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_clev_tbl               => l_clev_tbl_in,
                                       x_clev_tbl               => l_clev_tbl_out
                                      );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                         g_module_current || '.CREATE_CONTRACT_IBTERMINATE',
                            'oks_bill_rec_pub.update_contract_line(Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;

               date_terminated := NULL;
               oks_ib_util_pvt.check_termcancel_lines
                                                    (p_kdtl_tbl (l_ctr).hdr_id,
                                                     'TL',
                                                     'T',
                                                     date_terminated
                                                    );

               IF date_terminated IS NOT NULL
               THEN
                  get_sts_code ('TERMINATED', NULL, l_ste_code, l_sts_code);

                  l_chrv_tbl_in (1).ID := p_kdtl_tbl (l_ctr).hdr_id;
                  l_chrv_tbl_in (1).date_terminated :=
                                                      TRUNC (date_terminated);
                  l_chrv_tbl_in (1).trn_code := 'EXP';
                  l_chrv_tbl_in (1).term_cancel_source := 'IBTERMINATE';
                  If TRUNC (date_terminated)<= trunc(sysdate) Then
                       l_chrv_tbl_in (1).sts_code := l_sts_code;
                  End If;

                  okc_contract_pub.update_contract_header
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_chrv_tbl               => l_chrv_tbl_in,
                                       x_chrv_tbl               => l_chrv_tbl_out
                                      );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                            g_module_current
                         || '.Update_Hdr_Dates.external_call.after',
                            'okc_contract_pub.update_contract_header(Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;
            ELSIF l_ste_code = 'ENTERED'
            THEN
               l_trmdt := p_kdtl_tbl (l_ctr).termination_date;

               IF TRUNC (p_kdtl_tbl (l_ctr).prod_edt) < TRUNC (l_trmdt)
               THEN
                  l_trmdt := p_kdtl_tbl (l_ctr).prod_edt + 1;
               END IF;

	      -- added for the bug # 6000133
	      get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

               oks_change_status_pvt.update_line_status
                           (x_return_status           => l_return_status,
                            x_msg_data                => x_msg_data,
                            x_msg_count               => x_msg_count,
                            p_init_msg_list           => 'F',
                            p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                            p_cle_id                  => p_kdtl_tbl (l_ctr).object_line_id,
                            p_new_sts_code            => l_sts_code,
                            p_canc_reason_code        => 'TERMINATED',
                            p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                            p_old_ste_code            => 'ENTERED',
                            p_new_ste_code            => 'CANCELLED',
                            p_term_cancel_source      => 'IBTERMINATE',
                            p_date_cancelled          => TRUNC (l_trmdt),
                            p_comments                => NULL,
                            p_validate_status         => 'N'
                           );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                     (fnd_log.level_event,
                      g_module_current || '.CREATE_CONTRACT_IBTERMINATE',
                         'okc_contract_pub.update_contract_line(Return status ='
                      || l_return_status
                      || ')'
                     );
               END IF;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  RAISE g_exception_halt_validation;
               END IF;

               l_inst_dtls_tbl (l_ptr).date_cancelled := TRUNC (l_trmdt);
               date_cancelled := NULL;
               oks_ib_util_pvt.check_termcancel_lines
                                           (p_kdtl_tbl (l_ctr).service_line_id,
                                            'SL',
                                            'C',
                                            date_cancelled
                                           );

               IF date_cancelled IS NOT NULL
               THEN

	          -- added for the bug # 6000133
		  get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

                  oks_change_status_pvt.update_line_status
                          (x_return_status           => l_return_status,
                           x_msg_data                => x_msg_data,
                           x_msg_count               => x_msg_count,
                           p_init_msg_list           => 'F',
                           p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                           p_cle_id                  => p_kdtl_tbl (l_ctr).service_line_id,
                           p_new_sts_code            => l_sts_code,
                           p_canc_reason_code        => 'TERMINATED',
                           p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                           p_old_ste_code            => 'ENTERED',
                           p_new_ste_code            => 'CANCELLED',
                           p_term_cancel_source      => 'IBTERMINATE',
                           p_date_cancelled          => TRUNC (date_cancelled),
                           p_comments                => NULL,
                           p_validate_status         => 'N'
                          );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                         g_module_current || '.CREATE_CONTRACT_IBTERMINATE',
                            'okc_contract_pub.update_contract_line(Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;

               date_cancelled := NULL;
               oks_ib_util_pvt.check_termcancel_lines
                                                    (p_kdtl_tbl (l_ctr).hdr_id,
                                                     'TL',
                                                     'C',
                                                     date_cancelled
                                                    );

               IF date_cancelled IS NOT NULL
               THEN
                  l_return_status := 'S';

		  -- added for the bug # 6000133
		  get_sts_code ('CANCELLED', NULL, l_ste_code, l_sts_code);

                  oks_change_status_pvt.update_header_status
                          (x_return_status           => l_return_status,
                           x_msg_data                => x_msg_data,
                           x_msg_count               => x_msg_count,
                           p_init_msg_list           => 'F',
                           p_id                      => p_kdtl_tbl (l_ctr).hdr_id,
                           p_new_sts_code            =>  l_sts_code,
                           p_canc_reason_code        => 'TERMINATED',
                           p_old_sts_code            => p_kdtl_tbl (l_ctr).prod_sts_code,
                           p_comments                => NULL,
                           p_term_cancel_source      => 'IBTERMINATE',
                           p_date_cancelled          => TRUNC (date_cancelled),
                           p_validate_status         => 'N'
                          );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                         g_module_current || '.CREATE_CONTRACT_IBTERMINATE',
                            'OKS_WF_K_PROCESS_PVT.cancel_contract(Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;
            END IF;

            OPEN l_serv_csr (p_kdtl_tbl (l_ctr).service_inventory_id);

            FETCH l_serv_csr
             INTO l_service_name;

            CLOSE l_serv_csr;

            launch_workflow (   'INSTALL BASE ACTIVITY : TERMINATE  '
                             || fnd_global.local_chr (10)
                             || 'Contract Number       :         '
                             || get_contract_number (p_kdtl_tbl (l_ctr).hdr_id)
                             || fnd_global.local_chr (10)
                             || 'Customer product end dated    :         '
                             || l_service_name
                            );
           /*  get_sts_code (NULL,
                          p_kdtl_tbl (l_ctr).hdr_sts,
                          l_ste_code,
                          l_sts_code
                         );

            */


            l_inst_dtls_tbl (l_ptr).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
            l_inst_dtls_tbl (l_ptr).transaction_type := 'TRM';
            l_inst_dtls_tbl (l_ptr).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
            l_inst_dtls_tbl (l_ptr).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
            l_inst_dtls_tbl (l_ptr).instance_qty_new :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
            l_inst_dtls_tbl (l_ptr).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (l_ptr).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ptr).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ptr).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (l_ptr).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ptr).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ptr).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (l_ptr).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (l_ptr).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (l_ptr).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (l_ptr).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ptr).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (l_ptr).old_k_status := p_kdtl_tbl (l_ctr).hdr_sts;

            l_inst_dtls_tbl (l_ptr).new_k_status := p_kdtl_tbl (l_ctr).hdr_sts;


            IF l_inst_dtls_tbl.COUNT <> 0
            THEN
               IF l_old_cp_id <> p_kdtl_tbl (l_ctr).old_cp_id
               THEN
                  OPEN l_refnum_csr (p_kdtl_tbl (l_ctr).old_cp_id);

                  FETCH l_refnum_csr
                   INTO l_ref_num;

                  CLOSE l_refnum_csr;

                  l_parameters :=
                        ' Old CP :'
                     || p_kdtl_tbl (l_ctr).old_cp_id
                     || ','
                     || 'Item Id:'
                     || p_kdtl_tbl (l_ctr).prod_inventory_item
                     || ','
                     || 'Old Quantity:'
                     || p_kdtl_tbl (l_ctr).current_cp_quantity
                     || ','
                     || 'Transaction type :'
                     || 'TRM'
                     || ','
                     || ' Transaction date :'
                     || TRUNC(p_kdtl_tbl (l_ctr).transaction_date)
                     || ','
                     || 'New quantity:'
                     || p_kdtl_tbl (l_ctr).new_quantity;
                  --oks_instance_history
                  l_old_cp_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.instance_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.transaction_type := 'TRM';
                  l_insthist_rec.transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                  l_insthist_rec.reference_number := l_ref_num;
                  l_insthist_rec.PARAMETERS := l_parameters;
                  oks_ins_pvt.insert_row (p_api_version        => 1.0,
                                          p_init_msg_list      => 'T',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_insv_rec           => l_insthist_rec,
                                          x_insv_rec           => x_insthist_rec
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_K_SYSTEM_TRF',
                                    'oks_ins_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
                  END IF;

                  x_return_status := l_return_status;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;
                     RAISE g_exception_halt_validation;
                  END IF;

                  l_instparent_id := x_insthist_rec.ID;
               END IF;

               l_inst_dtls_tbl (l_ptr).ins_id := l_instparent_id;
               --oks_inst_history_details
               oks_ihd_pvt.insert_row (p_api_version        => 1.0,
                                       p_init_msg_list      => 'T',
                                       x_return_status      => l_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_ihdv_tbl           => l_inst_dtls_tbl,
                                       x_ihdv_tbl           => x_inst_dtls_tbl
                                      );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.CREATE_IBTERMINATE',
                                    'oks_ihd_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
               END IF;

               x_return_status := l_return_status;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  x_return_status := l_return_status;
                  RAISE g_exception_halt_validation;
               END IF;

	       If date_terminated is not null or date_cancelled is not null Then
	    	    Open l_hdr_sts_csr(p_kdtl_tbl (l_ctr).hdr_id);
	            Fetch l_hdr_sts_csr into l_hdr_status;
	            Close l_hdr_sts_csr;

	            Update oks_inst_hist_details set new_k_status = l_hdr_status
		    Where ins_id = l_instparent_id and new_contract_id = p_kdtl_tbl (l_ctr).hdr_id;

               End If;
            END IF;

            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
         END LOOP;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE update_contract_idc (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      -- Cursor to check cov attribute set
      CURSOR l_cov_csr (p_cle_id NUMBER)
      IS
         SELECT KL.sync_date_install
           FROM oks_k_lines_b LN, oks_k_lines_b kl
          WHERE LN.cle_id = p_cle_id AND kl.cle_id = LN.coverage_id;

      -- Cursor to check SR logged
      CURSOR l_checksr_csr (
         p_line_id   NUMBER,
         p_sdt       DATE,
         p_edt       DATE,
         p_cp_id     NUMBER
      )
      IS
         SELECT 'X'
           FROM cs_incidents_all_b
          WHERE customer_product_id = p_cp_id
            AND contract_service_id = p_line_id
            AND (   TRUNC (creation_date) <= TRUNC (p_sdt)
                 OR TRUNC (creation_date) >= TRUNC (p_edt)
                );

      -- Cursor to get start and end date of sub lines
      CURSOR l_subline_dates (
         p_topline_id   NUMBER,
         p_hdr_id       NUMBER,
         p_subline_id   NUMBER
      )
      IS
         SELECT MIN (start_date) sdt, MAX (end_date) edt
           FROM okc_k_lines_b
          WHERE cle_id = p_topline_id
            AND dnz_chr_id = p_hdr_id
            AND lse_id = 18
            AND ID <> p_subline_id;

      -- Cursor to get start and end date of top lines
      CURSOR l_topline_dates (p_hdr_id NUMBER, p_topline_id NUMBER)
      IS
         SELECT MIN (start_date) sdt, MAX (end_date) edt
           FROM okc_k_lines_b
          WHERE dnz_chr_id = p_hdr_id AND cle_id IS NULL
                AND ID <> p_topline_id;

      -- Cursor to get the header dates and status
      CURSOR l_lndates_csr (p_id NUMBER)
      IS
         SELECT start_date, end_date
           FROM okc_k_lines_b
          WHERE ID = p_id;

      -- Cursor to get the line dates and status
      CURSOR l_hdrdates_csr (p_id NUMBER)
      IS
         SELECT start_date, end_date, sts_code
           FROM okc_k_headers_b
          WHERE ID = p_id;

--mmadhavi bug 3761489
      CURSOR get_oks_line_dtls (p_id NUMBER)
      IS
         SELECT ID, object_version_number
           FROM oks_k_lines_b
          WHERE cle_id = p_id;

--mmadhavi bug 3761489
      CURSOR l_serv_csr (p_serv_line_id NUMBER)
      IS
         SELECT t.description NAME, b.concatenated_segments description
           FROM mtl_system_items_b_kfv b,
                mtl_system_items_tl t,
                okc_k_items ki
          WHERE ki.cle_id = p_serv_line_id
            AND b.inventory_item_id = TO_CHAR (ki.object1_id1)
            AND t.inventory_item_id = b.inventory_item_id
            AND t.organization_id = b.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND ROWNUM < 2;

      CURSOR l_refnum_csr (p_cp_id NUMBER)
      IS
         SELECT instance_number
           FROM csi_item_instances
          WHERE instance_id = p_cp_id;

      l_ref_num                  VARCHAR2 (30);
      x_inst_dtls_tbl            oks_ihd_pvt.ihdv_tbl_type;
      l_inst_dtls_tbl            oks_ihd_pvt.ihdv_tbl_type;
      l_instparent_id            NUMBER;
      l_old_cp_id                NUMBER;
      l_insthist_rec             oks_ins_pvt.insv_rec_type;
      x_insthist_rec             oks_ins_pvt.insv_rec_type;
      l_parameters               VARCHAR2 (2000);
      l_lndates_rec              l_lndates_csr%ROWTYPE;
      l_hdrdates_rec             l_hdrdates_csr%ROWTYPE;
      l_subline_rec              l_subline_dates%ROWTYPE;
      l_topline_rec              l_topline_dates%ROWTYPE;
      l_duration                 NUMBER;
      l_timeunits                VARCHAR2 (25);
      l_api_version     CONSTANT NUMBER                             := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)               := okc_api.g_false;
      l_available_yn             VARCHAR2 (2);
      l_index                    VARCHAR2 (2000);
      l_return_status            VARCHAR2 (1)                       := 'S';
      --l_kdtl_tbl                          oks_extwar_util_pvt.contract_tbl_type;
      l_salescredit_tbl_line     oks_extwarprgm_pvt.salescredit_tbl;
      l_salescredit_tbl_hdr      oks_extwarprgm_pvt.salescredit_tbl;
      l_ctr                      NUMBER                             := 0;
      l_cov_att                  VARCHAR2 (1);
      v_temp                     VARCHAR2 (1);
      l_sub_sdt                  DATE                               := NULL;
      l_sub_edt                  DATE                               := NULL;
      l_top_sdt                  DATE                               := NULL;
      l_top_edt                  DATE                               := NULL;
      l_hdr_sdt                  DATE                               := NULL;
      l_hdr_edt                  DATE                               := NULL;
      l_status                   VARCHAR2 (30);
      l_top_flag                 VARCHAR2 (1);
      l_hdr_flag                 VARCHAR2 (1);
      l_update_line              VARCHAR2 (1);
      l_sts_flag                 VARCHAR2 (1);
      l_ste_code                 VARCHAR2 (240);
      l_sts_code                 VARCHAR2 (240);
      l_obj_version_num          NUMBER;
      l_id                       NUMBER;
      l_prod_item_id             NUMBER;
      line_desc                  VARCHAR2 (240);
      line_name                  VARCHAR2 (240);
      l_desc                     VARCHAR2 (240);
      l_quantity                 NUMBER;
      l_invoice_text             VARCHAR2 (2000);
      l_klnv_tbl_in              oks_kln_pvt.klnv_tbl_type;
      l_klnv_tbl_out             oks_kln_pvt.klnv_tbl_type;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.UPDATE_CONTRACT_IDC.after.',
                         'count = ' || p_kdtl_tbl.COUNT || ')'
                        );
      END IF;

      l_old_cp_id := 0;

      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP
            okc_context.set_okc_org_context
                                           (p_kdtl_tbl (l_ctr).hdr_org_id,
                                            p_kdtl_tbl (l_ctr).organization_id
                                           );

            IF p_kdtl_tbl (l_ctr).installation_date IS NULL
            THEN
               l_return_status := okc_api.g_ret_sts_warning;

               IF fnd_log.level_error >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_error,
                                  g_module_current || '.IB_INTERFACE',
                                  'Installation date changed to null '
                                 );
               END IF;

               okc_api.set_message (g_app_name, 'OKS_NULL_INSTALLATION_DATE');
               RAISE g_exception_halt_validation;
            END IF;

            l_inst_dtls_tbl.DELETE;
            get_sts_code (p_kdtl_tbl (l_ctr).hdr_sts,
                          NULL,
                          l_ste_code,
                          l_sts_code
                         );
            -- Instance history details
            --x_inst_dtls_tbl(l_ctr).INST_PARENT_ID            := p_idc_rec.old_cp_id;
            l_inst_dtls_tbl (1).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
            l_inst_dtls_tbl (1).transaction_type := 'IDC';
            l_inst_dtls_tbl (1).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
            l_inst_dtls_tbl (1).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
            l_inst_dtls_tbl (1).instance_qty_new :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
            l_inst_dtls_tbl (1).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (1).instance_amt_new :=
                                             p_kdtl_tbl (l_ctr).service_amount;
            l_inst_dtls_tbl (1).old_contract_id := p_kdtl_tbl (l_ctr).hdr_id;
            l_inst_dtls_tbl (1).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
            l_inst_dtls_tbl (1).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
            l_inst_dtls_tbl (1).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
            l_inst_dtls_tbl (1).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
            l_inst_dtls_tbl (1).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
            l_inst_dtls_tbl (1).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
            l_inst_dtls_tbl (1).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
            l_inst_dtls_tbl (1).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
            l_inst_dtls_tbl (1).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
            l_inst_dtls_tbl (1).old_k_status := l_sts_code;
            -- If installation date is null Contract starts with OM shipment date
            -- New start date for the covered line
            l_sub_sdt := trunc(p_kdtl_tbl (l_ctr).installation_date); --bug 5757116 added trunc.
            okc_time_util_pub.get_duration
                                  (p_start_date         => p_kdtl_tbl (l_ctr).prod_sdt,
                                   p_end_date           => p_kdtl_tbl (l_ctr).prod_edt,
                                   x_duration           => l_duration,
                                   x_timeunit           => l_timeunits,
                                   x_return_status      => l_return_status
                                  );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                        (fnd_log.level_event,
                            g_module_current
                         || '.UPDATE_CONTRACT_IDC.after.get_k_dtls',
                            'Okc_time_util_pub.get_duration(Return status = '
                         || l_return_status
                         || ',Duration = '
                         || l_duration
                         || ',Time units = '
                         || l_timeunits
                         || ')'
                        );
            END IF;

            IF NOT l_return_status = 'S'
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            -- New end date for the covered line
            l_sub_edt :=
               okc_time_util_pub.get_enddate
                         (p_start_date      => trunc(p_kdtl_tbl (l_ctr).installation_date),
                          p_duration        => l_duration,
                          p_timeunit        => l_timeunits
                         );

            -- Check for the coverage flag Synchronization install date
            -- Contract date can be updated if the flag is checked
            OPEN l_cov_csr (p_kdtl_tbl (l_ctr).service_line_id);

            FETCH l_cov_csr
             INTO l_cov_att;

            CLOSE l_cov_csr;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               g_module_current || '.UPDATE_CONTRACT_IDC',
                               'Coverage attribute = ' || l_cov_att
                              );
            END IF;


            IF NVL (l_cov_att, 'N') = 'Y'
            THEN
               -- Check for any open service request
               -- Contract date wouldn't be updated only if there is a service request outside new effectivity
               OPEN l_checksr_csr (p_kdtl_tbl (l_ctr).service_line_id,
                                   l_sub_sdt,
                                   l_sub_edt,
                                   p_kdtl_tbl (l_ctr).old_cp_id
                                  );

               FETCH l_checksr_csr
                INTO v_temp;

               IF l_checksr_csr%FOUND
               THEN
                  CLOSE l_checksr_csr;

                  l_return_status := okc_api.g_ret_sts_warning;

                  IF fnd_log.level_error >= fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_error,
                                        g_module_current
                                     || '.UPDATE_CONTRACT_IDC.ERROR',
                                        'SR is logged '
                                     || ',status = '
                                     || l_return_status
                                    );
                  END IF;

                  okc_api.set_message (g_app_name, 'OKS_SR_EXISTS');
                  RAISE g_exception_halt_validation;
               ELSE
                  CLOSE l_checksr_csr;

                  OPEN l_subline_dates (p_kdtl_tbl (l_ctr).service_line_id,
                                        p_kdtl_tbl (l_ctr).hdr_id,
                                        p_kdtl_tbl (l_ctr).object_line_id
                                       );

                  FETCH l_subline_dates
                   INTO l_subline_rec;

                  IF     l_subline_dates%FOUND
                     AND l_subline_rec.sdt IS NOT NULL
                     AND l_subline_rec.edt IS NOT NULL
                  THEN
                     IF     l_subline_rec.sdt < l_sub_sdt
                        AND l_subline_rec.edt > l_sub_edt
                     THEN
                        l_top_flag := 'F';
                     ELSE
                        IF l_subline_rec.sdt >= l_sub_sdt
                        THEN
                           l_top_sdt := l_sub_sdt;
                        ELSE
                           l_top_sdt := l_subline_rec.sdt;
                        END IF;

                        IF l_subline_rec.edt >= l_sub_edt
                        THEN
                           l_top_edt := l_subline_rec.edt;
                        ELSE
                           l_top_edt := l_sub_edt;
                        END IF;

                        l_top_flag := 'T';
                     END IF;
                  ELSE
                     l_top_flag := 'T';
                     l_top_sdt := l_sub_sdt;
                     l_top_edt := l_sub_edt;
                  --errorout(   l_top_sdt || ': '||  l_top_edt   );
                  END IF;

                  CLOSE l_subline_dates;

                  IF l_top_flag = 'T'
                  THEN
                     OPEN l_topline_dates (p_kdtl_tbl (l_ctr).hdr_id,
                                           p_kdtl_tbl (l_ctr).service_line_id
                                          );

                     FETCH l_topline_dates
                      INTO l_topline_rec;

                     IF     l_topline_dates%FOUND
                        AND l_topline_rec.sdt IS NOT NULL
                        AND l_topline_rec.edt IS NOT NULL
                     THEN
                        IF     l_topline_rec.sdt < l_top_sdt
                           AND l_topline_rec.edt > l_top_edt
                        THEN
                           l_hdr_flag := 'F';
                        ELSE
                           IF l_topline_rec.sdt >= l_top_sdt
                           THEN
                              l_hdr_sdt := l_top_sdt;
                           ELSE
                              l_hdr_sdt := l_topline_rec.sdt;
                           END IF;

                           IF l_topline_rec.edt >= l_top_edt
                           THEN
                              l_hdr_edt := l_topline_rec.edt;
                           ELSE
                              l_hdr_edt := l_top_edt;
                           END IF;

                           l_hdr_flag := 'T';
                        END IF;
                     ELSE
                        l_hdr_flag := 'T';
                        l_hdr_sdt := l_top_sdt;
                        l_hdr_edt := l_top_edt;
                     END IF;

                     CLOSE l_topline_dates;

                     IF l_hdr_flag = 'T'
                     THEN
                        l_sts_flag := 'Y';

                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.STRING (fnd_log.level_statement,
                                              g_module_current
                                           || '.UPDATE_CONTRACT_IDC',
                                              'Header start date = '
                                           || l_hdr_sdt
                                           || ',End date = '
                                           || l_hdr_edt
                                           || ',status = '
                                           || l_sts_flag
                                          );
                        END IF;

                        update_hdr_dates
                                        (p_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                                         p_new_sdt        => l_hdr_sdt,
                                         p_new_edt        => l_hdr_edt,
                                         p_sts_flag       => l_sts_flag,
                                         x_status         => l_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data
                                        );

                        IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                           )
                        THEN
                           fnd_log.STRING
                                      (fnd_log.level_event,
                                          g_module_current
                                       || '.UPDATE_CONTRACT_IDC',
                                          'Update_hdr_dates(Return status = '
                                       || l_return_status
                                       || ')'
                                      );
                        END IF;

                        IF NOT l_return_status = okc_api.g_ret_sts_success
                        THEN
                           RAISE g_exception_halt_validation;
                        END IF;
                     END IF;                                         --hdrflag

                     l_sts_flag := 'Y';

                     IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.STRING (fnd_log.level_statement,
                                           g_module_current
                                        || '.UPDATE_CONTRACT_IDC',
                                           'Top line start date = '
                                        || l_top_sdt
                                        || ',End date = '
                                        || l_top_edt
                                        || ',status = '
                                        || l_sts_flag
                                       );
                     END IF;

                     update_line_dates
                               (p_cle_id             => p_kdtl_tbl (l_ctr).service_line_id,
                                p_chr_id             => p_kdtl_tbl (l_ctr).hdr_id,
                                p_new_sdt            => l_top_sdt,
                                p_new_edt            => l_top_edt,
                                p_sts_flag           => l_sts_flag,
                                p_warranty_flag      => 'W',
                                x_status             => l_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data
                               );

                     IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                        )
                     THEN
                        fnd_log.STRING
                                     (fnd_log.level_event,
                                         g_module_current
                                      || '.UPDATE_CONTRACT_IDC',
                                         'Update_Line_dates(Return status = '
                                      || l_return_status
                                      || ')'
                                     );
                     END IF;

                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN
                        RAISE g_exception_halt_validation;
                     END IF;

                     OPEN l_serv_csr (p_kdtl_tbl (l_ctr).service_line_id);

                     FETCH l_serv_csr
                      INTO line_name, line_desc;

                     CLOSE l_serv_csr;

                     IF fnd_profile.VALUE ('OKS_ITEM_DISPLAY_PREFERENCE') =
                                                                'DISPLAY_NAME'
                     THEN
                        l_desc := line_name;
                     ELSE
                        l_desc := line_desc;
                     END IF;

                     l_invoice_text :=
                             l_desc || ':' || to_char(l_top_sdt,'DD-MON-YYYY')
			     || ':' || to_char(l_top_edt,'DD-MON-YYYY');

                     OPEN get_oks_line_dtls (p_kdtl_tbl (l_ctr).service_line_id
                                            );

                     FETCH get_oks_line_dtls
                      INTO l_id, l_obj_version_num;

                     CLOSE get_oks_line_dtls;

                     l_klnv_tbl_in (1).ID := l_id;
                     l_klnv_tbl_in (1).invoice_text := l_invoice_text;
                     l_klnv_tbl_in (1).object_version_number :=
                                                             l_obj_version_num;
                     oks_contract_line_pub.update_line
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_klnv_tbl           => l_klnv_tbl_in,
                                           x_klnv_tbl           => l_klnv_tbl_out,
                                           p_validate_yn        => 'N'
                                          );

                     IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                        )
                     THEN
                        fnd_log.STRING
                           (fnd_log.level_event,
                            g_module_current || '.UPDATE_CONTRACT_IDC',
                               'oks_contract_line_pub.update_line(Return status = '
                            || l_return_status
                            || ')'
                           );
                     END IF;

                     IF NOT l_return_status = 'S'
                     THEN
                        okc_api.set_message (g_app_name,
                                             g_required_value,
                                             g_col_name_token,
                                             'OKS Contract COV LINE'
                                            );
                        RAISE g_exception_halt_validation;
                     END IF;

                     --mmadhavi end bug 3761489
                     oks_coverages_pub.update_cov_eff
                        (p_api_version          => 1.0,
                         p_init_msg_list        => 'T',
                         x_return_status        => l_return_status,
                         x_msg_count            => x_msg_count,
                         x_msg_data             => x_msg_data,
                         p_service_line_id      => p_kdtl_tbl (l_ctr).service_line_id,
                         p_new_start_date       => l_top_sdt,
                         p_new_end_date         => l_top_edt
                        );

                     IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                        )
                     THEN
                        fnd_log.STRING
                           (fnd_log.level_event,
                            g_module_current || '.UPDATE_CONTRACT_IDC',
                               'oks_coverages_pub.update_cov_eff(Return status = '
                            || l_return_status
                            || ')'
                           );
                     END IF;

                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN
                        RAISE g_exception_halt_validation;
                     END IF;

                     oks_pm_programs_pvt.adjust_pm_program_schedule
                        (p_api_version           => 1.0,
                         p_init_msg_list         => 'F',
                         p_contract_line_id      => p_kdtl_tbl (l_ctr).service_line_id,
                         p_new_start_date        => l_top_sdt,
                         p_new_end_date          => l_top_edt,
                         x_return_status         => l_return_status,
                         x_msg_count             => x_msg_count,
                         x_msg_data              => x_msg_data
                        );

                     IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                        )
                     THEN
                        fnd_log.STRING
                           (fnd_log.level_event,
                            g_module_current || '.UPDATE_CONTRACT_IDC',
                               'oks_pm_programs_pvt.ADJUST_PM_PROGRAM_SCHEDULE(Return status = '
                            || l_return_status
                            || ')'
                           );
                     END IF;

                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN
                        RAISE g_exception_halt_validation;
                     END IF;
                  END IF;                                            --topflag

                  IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current
                                     || '.UPDATE_CONTRACT_IDC',
                                        'sub line start date = '
                                     || l_sub_sdt
                                     || ',End date'
                                     || l_sub_edt
                                    );
                  END IF;

                  update_line_dates
                                (p_cle_id             => p_kdtl_tbl (l_ctr).object_line_id,
                                 p_chr_id             => p_kdtl_tbl (l_ctr).hdr_id,
                                 p_new_sdt            => l_sub_sdt,
                                 p_new_edt            => l_sub_edt,
                                 p_sts_flag           => 'Y',
                                 p_warranty_flag      => 'W',
                                 x_status             => l_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data
                                );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING (fnd_log.level_event,
                                     g_module_current
                                     || '.UPDATE_CONTRACT_IDC',
                                        'Update_line_dates(Return status = '
                                     || l_return_status
                                     || ')'
                                    );
                  END IF;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     RAISE g_exception_halt_validation;
                  END IF;

                  --mmadhavi start bug 3761489
                  l_prod_item_id := p_kdtl_tbl (l_ctr).prod_inventory_item;

                  OPEN get_oks_line_dtls (p_kdtl_tbl (l_ctr).object_line_id);

                  FETCH get_oks_line_dtls
                   INTO l_id, l_obj_version_num;

                  CLOSE get_oks_line_dtls;

                  l_quantity := p_kdtl_tbl (l_ctr).old_cp_quantity;
                  l_invoice_text :=
                     getformattedinvoicetext (l_prod_item_id,
                                              l_sub_sdt,
                                              l_sub_edt,
                                              line_desc,
                                              l_quantity
                                             );
                  l_klnv_tbl_in (1).ID := l_id;
                  l_klnv_tbl_in (1).invoice_text := l_invoice_text;
                  l_klnv_tbl_in (1).object_version_number := l_obj_version_num;
                  oks_contract_line_pub.update_line
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_klnv_tbl           => l_klnv_tbl_in,
                                           x_klnv_tbl           => l_klnv_tbl_out,
                                           p_validate_yn        => 'N'
                                          );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_event,
                         g_module_current || '.UPDATE_CONTRACT_IDC',
                            'oks_contract_line_pub.update_line(Return status = '
                         || l_return_status
                         || ')'
                        );
                  END IF;

                  IF NOT l_return_status = 'S'
                  THEN
                     okc_api.set_message (g_app_name,
                                          g_required_value,
                                          g_col_name_token,
                                          'OKS Contract COV LINE'
                                         );
                     RAISE g_exception_halt_validation;
                  END IF;

                  -- mmadhavi end bug 3761489
                  OPEN l_lndates_csr (p_kdtl_tbl (l_ctr).service_line_id);

                  FETCH l_lndates_csr
                   INTO l_lndates_rec;

                  CLOSE l_lndates_csr;

                  OPEN l_hdrdates_csr (p_kdtl_tbl (l_ctr).hdr_id);

                  FETCH l_hdrdates_csr
                   INTO l_hdrdates_rec;

                  CLOSE l_hdrdates_csr;

                  l_sts_code := NULL;
                  get_sts_code (l_hdrdates_rec.sts_code,
                                NULL,
                                l_ste_code,
                                l_sts_code
                               );
                  l_inst_dtls_tbl (1).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                  l_inst_dtls_tbl (1).new_contact_start_date :=
                                                     l_hdrdates_rec.start_date;
                  l_inst_dtls_tbl (1).new_contract_end_date :=
                                                       l_hdrdates_rec.end_date;
                  l_inst_dtls_tbl (1).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                  l_inst_dtls_tbl (1).new_service_start_date :=
                                                      l_lndates_rec.start_date;
                  l_inst_dtls_tbl (1).new_service_end_date :=
                                                        l_lndates_rec.end_date;
                  l_inst_dtls_tbl (1).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                  l_inst_dtls_tbl (1).new_subline_start_date :=
                                  NVL (l_sub_sdt, p_kdtl_tbl (l_ctr).prod_sdt);
                  l_inst_dtls_tbl (1).new_subline_end_date :=
                                  NVL (l_sub_edt, p_kdtl_tbl (l_ctr).prod_edt);
                  l_inst_dtls_tbl (1).subline_date_terminated := NULL;
                  l_inst_dtls_tbl (1).new_k_status := l_sts_code;
                  l_inst_dtls_tbl (1).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
               END IF;                                             --SR logged
            ELSE
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module_current || '.UPDATE_CONTRACT_IDC',
                                  'coverage attribute not set'
                                 );
               END IF;
            END IF;                                       --coverage attribute

            IF l_inst_dtls_tbl.COUNT <> 0
            THEN
               IF l_old_cp_id <> p_kdtl_tbl (l_ctr).old_cp_id
               THEN
                  OPEN l_refnum_csr (p_kdtl_tbl (l_ctr).old_cp_id);

                  FETCH l_refnum_csr
                   INTO l_ref_num;

                  CLOSE l_refnum_csr;

                  l_parameters :=
                        ' Old CP :'
                     || p_kdtl_tbl (l_ctr).old_cp_id
                     || ','
                     || 'Item Id:'
                     || p_kdtl_tbl (l_ctr).prod_inventory_item
                     || ','
                     || 'Old Quantity:'
                     || p_kdtl_tbl (l_ctr).current_cp_quantity
                     || ','
                     || 'Transaction type :'
                     || 'IDC'
                     || ','
                     || ' Transaction date :'
                     || TRUNC(p_kdtl_tbl (l_ctr).transaction_date)
                     || ','
                     || 'Installation Date:'
                     || trunc(p_kdtl_tbl (l_ctr).installation_date);
                  --oks_instance_history
                  l_old_cp_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.instance_id := p_kdtl_tbl (l_ctr).old_cp_id;
                  l_insthist_rec.transaction_type := 'IDC';
                  l_insthist_rec.transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                  l_insthist_rec.reference_number := l_ref_num;
                  l_insthist_rec.PARAMETERS := l_parameters;
                  oks_ins_pvt.insert_row (p_api_version        => 1.0,
                                          p_init_msg_list      => 'T',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_insv_rec           => l_insthist_rec,
                                          x_insv_rec           => x_insthist_rec
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.UPDATE_CONTRACT_IDC',
                                    'oks_ins_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
                  END IF;

                  x_return_status := l_return_status;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;
                     RAISE g_exception_halt_validation;
                  END IF;

                  l_instparent_id := x_insthist_rec.ID;
               END IF;

               l_inst_dtls_tbl (1).ins_id := l_instparent_id;
               --oks_inst_history_details
               oks_ihd_pvt.insert_row (p_api_version        => 1.0,
                                       p_init_msg_list      => 'T',
                                       x_return_status      => l_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_ihdv_tbl           => l_inst_dtls_tbl,
                                       x_ihdv_tbl           => x_inst_dtls_tbl
                                      );

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING
                                (fnd_log.level_event,
                                 g_module_current || '.UPDATE_CONTRACT_IDC',
                                    'oks_ihd_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
               END IF;

               x_return_status := l_return_status;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  x_return_status := l_return_status;
                  RAISE g_exception_halt_validation;
               END IF;
            END IF;

            launch_workflow
                       (   'INSTALL BASE ACTIVITY : INSTALLTION DATE CHANGE  '
                        || fnd_global.local_chr (10)
                        || 'Contract Number       :         '
                        || get_contract_number (p_kdtl_tbl (l_ctr).hdr_id)
                        || fnd_global.local_chr (10)
                        || 'Inatallation date changed to    :         '
                        || trunc(p_kdtl_tbl (l_ctr).installation_date)
                       );
            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
            l_hdr_sdt := NULL;
            l_hdr_edt := NULL;
            l_top_sdt := NULL;
            l_top_edt := NULL;
            l_sub_sdt := NULL;
            l_sub_edt := NULL;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE create_contract_ibupdate (
      p_kdtl_tbl        IN              contract_tbl,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_cust_csr (p_inventory_item_id NUMBER)
      IS
         SELECT mtl.NAME, mtl.description
           FROM okx_system_items_v mtl
          WHERE mtl.inventory_item_id = p_inventory_item_id
            AND mtl.organization_id = okc_context.get_okc_organization_id;

      CURSOR l_bill_csr (p_cle_id NUMBER)
      IS
         SELECT SUM (amount)
           FROM oks_bill_sub_lines_v
          WHERE cle_id = p_cle_id;

      CURSOR l_serv_csr (p_serv_id NUMBER)
      IS
         SELECT b.concatenated_segments description
           FROM mtl_system_items_b_kfv b
          WHERE b.inventory_item_id = p_serv_id AND ROWNUM < 2;

      CURSOR l_refnum_csr (p_cp_id NUMBER)
      IS
         SELECT instance_number
           FROM csi_item_instances
          WHERE instance_id = p_cp_id;

      l_ref_num                   VARCHAR2 (30);
      l_parameters                VARCHAR2 (2000);
      l_renewal_id                NUMBER;
      --Contract Line Table
      l_clev_tbl_in               okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out              okc_contract_pub.clev_tbl_type;
      --SalesCredit
      l_salescredit_tbl_line      oks_extwarprgm_pvt.salescredit_tbl;
      l_salescredit_tbl_hdr       oks_extwarprgm_pvt.salescredit_tbl;
      l_line_rec                  k_line_service_rec_type;
      l_covd_rec                  k_line_covered_level_rec_type;
      -- l_kdtl_tbl                              OKS_EXTWAR_UTIL_PVT.Contract_tbl_type;
      l_available_yn              VARCHAR2 (1);
      l_return_status             VARCHAR2 (5)    := okc_api.g_ret_sts_success;
      l_chrid                     NUMBER                               := NULL;
      l_lineid                    NUMBER                               := NULL;
      l_cust_rec                  l_cust_csr%ROWTYPE;
      l_terminate_rec             okc_terminate_pvt.terminate_in_cle_rec;
      l_api_version      CONSTANT NUMBER                                := 1.0;
      l_init_msg_list    CONSTANT VARCHAR2 (1)              := okc_api.g_false;
      l_ste_code                  VARCHAR2 (40);
      l_sts_code                  VARCHAR2 (40);
      l_billed_amount             NUMBER;
      l_update_top_line           VARCHAR2 (1);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2 (2000);
      l_covlvl_id                 NUMBER;
      l_amount                    NUMBER;
      l_subline_amount            NUMBER;
      l_srvc_stdt                 DATE;
      l_bill_schd_yn              VARCHAR2 (1);
      l_dur                       NUMBER;
      l_time                      VARCHAR2 (25);
      l_sll_tbl                   oks_bill_sch.streamlvl_tbl;
      l_bil_sch_out               oks_bill_sch.itembillsch_tbl;
      l_strmlvl_id                NUMBER                               := NULL;
      l_contact_tbl_in            oks_extwarprgm_pvt.contact_tbl;
      l_price_attribs_in          oks_extwarprgm_pvt.pricing_attributes_type;
      l_ctr                       NUMBER;
      l_temp                      VARCHAR2 (2000);
      l_suppress_credit           VARCHAR2 (10);

      CURSOR l_amount_csr (p_cle_id NUMBER)
      IS
         SELECT price_negotiated
           FROM okc_k_lines_b
          WHERE ID = p_cle_id;

      l_cov_tbl                   oks_bill_rec_pub.covered_tbl;
      l_ptr                       NUMBER                                  := 0;
      l_input_details             oks_qp_pkg.input_details;
      l_output_details            oks_qp_pkg.price_details;
      l_modif_details             qp_preq_grp.line_detail_tbl_type;
      l_pb_details                oks_qp_pkg.g_price_break_tbl_type;
      l_warranty_flag             VARCHAR2 (2);
      l_inst_dtls_tbl             oks_ihd_pvt.ihdv_tbl_type;
      x_inst_dtls_tbl             oks_ihd_pvt.ihdv_tbl_type;
      l_instparent_id             NUMBER;
      l_old_cp_id                 NUMBER;
      l_insthist_rec              oks_ins_pvt.insv_rec_type;
      x_insthist_rec              oks_ins_pvt.insv_rec_type;
      l_target_chr_id             NUMBER;
      l_opr_instance_id           NUMBER;
      l_renewal_opr_instance_id   NUMBER;
      l_update_id                 NUMBER;
      l_source_line_id            NUMBER;
      l_create_oper_instance      VARCHAR2 (1);
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;
      l_old_cp_id := 0;
      l_target_chr_id := 0;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.CREATE_CONTRACT_IBUPDATE.',
                         'count = ' || p_kdtl_tbl.COUNT || ')'
                        );
      END IF;

      IF p_kdtl_tbl.COUNT > 0
      THEN
         l_ctr := p_kdtl_tbl.FIRST;

         LOOP
            l_ptr := 1;
            l_inst_dtls_tbl.DELETE;
            okc_context.set_okc_org_context
                                           (p_kdtl_tbl (l_ctr).hdr_org_id,
                                            p_kdtl_tbl (l_ctr).organization_id
                                           );

            --  If status = 'ENTERED' then just update the qty and reprice and update billing schedule.
            --  else check if line is already billed.
            -- If partially billed or unbilled update the qty and reprice and update billing schedule.
            -- If line fully billed Then
            -- update qty of subline.
            -- create new top line and subline with updated qty and create one time billing schedule.
            -- the amount will be the diff.

            --If the qty decrement is due to return for repair ignore, only manual increments to the qty from IB is honored.
            IF p_kdtl_tbl (l_ctr).return_reason_code = 'REGULAR'
            THEN
               IF p_kdtl_tbl (l_ctr).new_quantity >
                                           p_kdtl_tbl (l_ctr).old_cp_quantity
               THEN
                  get_sts_code (NULL,
                                p_kdtl_tbl (l_ctr).prod_sts_code,
                                l_ste_code,
                                l_sts_code
                               );

                  IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.STRING (fnd_log.level_statement,
                                        g_module_current
                                     || '.CREATE_CONTRACT_IBUPDATE',
                                     'lse_id= ' || p_kdtl_tbl (l_ctr).lse_id
                                    );
                  END IF;

                  --errorout_n('in update lse_id'||p_kdtl_tbl(l_ctr).lse_id);
                  -- For Warranty lines instance qty is updated, no repricing done.
                  IF p_kdtl_tbl (l_ctr).lse_id = 18
                  THEN                                              --Warranty
                     UPDATE okc_k_items
                        SET number_of_items = p_kdtl_tbl (l_ctr).new_quantity
                      WHERE cle_id = p_kdtl_tbl (l_ctr).object_line_id;

                     l_inst_dtls_tbl (l_ptr).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                     l_inst_dtls_tbl (l_ptr).transaction_type := 'UPD';
                     l_inst_dtls_tbl (l_ptr).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
                     l_inst_dtls_tbl (l_ptr).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
                     l_inst_dtls_tbl (l_ptr).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                     l_inst_dtls_tbl (l_ptr).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                     l_inst_dtls_tbl (l_ptr).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                     l_inst_dtls_tbl (l_ptr).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                     l_inst_dtls_tbl (l_ptr).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                     l_inst_dtls_tbl (l_ptr).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                     l_inst_dtls_tbl (l_ptr).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                     l_inst_dtls_tbl (l_ptr).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                     l_inst_dtls_tbl (l_ptr).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                     l_inst_dtls_tbl (l_ptr).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                     l_inst_dtls_tbl (l_ptr).old_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                     l_inst_dtls_tbl (l_ptr).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).new_cp_id;
                     l_inst_dtls_tbl (l_ptr).instance_amt_new := NULL;
                     l_inst_dtls_tbl (l_ptr).instance_qty_new :=
                                               p_kdtl_tbl (l_ctr).new_quantity;
                     l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                     l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                     l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                     l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                     l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                     l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                     l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                     l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                     l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                     l_inst_dtls_tbl (l_ptr).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                     l_inst_dtls_tbl (l_ptr).new_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                  ELSE                 --lse_id = 18
                                       -- For service/ Ext.Warranty line types
                     l_billed_amount := NULL;

                     OPEN l_bill_csr (p_kdtl_tbl (l_ctr).object_line_id);

                     FETCH l_bill_csr
                      INTO l_billed_amount;

                     CLOSE l_bill_csr;

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.STRING (fnd_log.level_statement,
                                           g_module_current
                                        || '.CREATE_CONTRACT_IBUPDATE',
                                           'Billed amount = '
                                        || l_billed_amount
                                        || ',Service amount = '
                                        || p_kdtl_tbl (l_ctr).service_amount
                                       );
                     END IF;

                     --If amount billed is null, update instance qty and reprice.
                     IF l_billed_amount IS NULL
                     THEN
                        UPDATE okc_k_items
                           SET number_of_items =
                                               p_kdtl_tbl (l_ctr).new_quantity
                         WHERE cle_id = p_kdtl_tbl (l_ctr).object_line_id;

                        --calling reprice
                        l_input_details.line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                        l_input_details.subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                        l_input_details.intent := 'SP';
                        oks_qp_int_pvt.compute_price
                                       (p_api_version              => 1.0,
                                        p_init_msg_list            => 'T',
                                        p_detail_rec               => l_input_details,
                                        x_price_details            => l_output_details,
                                        x_modifier_details         => l_modif_details,
                                        x_price_break_details      => l_pb_details,
                                        x_return_status            => l_return_status,
                                        x_msg_count                => x_msg_count,
                                        x_msg_data                 => x_msg_data
                                       );

                        IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                           )
                        THEN
                           fnd_log.STRING
                              (fnd_log.level_event,
                               g_module_current || '.CREATE_CONTRACT_IBUPDATE',
                                  'oks_qp_int_pvt.compute_price(Return status = '
                               || l_return_status
                               || ',Repriced amount = '
                               || l_amount
                               || ')'
                              );
                        END IF;

                        IF l_return_status <> okc_api.g_ret_sts_success
                        THEN
                           RAISE g_exception_halt_validation;
                        END IF;

                        ---update billing schedule
                        oks_bill_sch.create_bill_sch_cp
                           (p_top_line_id        => p_kdtl_tbl (l_ctr).service_line_id,
                            p_cp_line_id         => p_kdtl_tbl (l_ctr).object_line_id,
                            p_cp_new             => 'N',
                            x_return_status      => l_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data
                           );

                        IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                           )
                        THEN
                           fnd_log.STRING
                              (fnd_log.level_event,
                               g_module_current || '.CREATE_CONTRACT_IBUPDATE',
                                  'Oks_bill_sch.Create_Bill_Sch_CP(Return status = '
                               || l_return_status
                               || ')'
                              );
                        END IF;

                        IF l_return_status <> okc_api.g_ret_sts_success
                        THEN
                           okc_api.set_message (g_app_name,
                                                g_required_value,
                                                g_col_name_token,
                                                'Sched Billing Rule (LINE)'
                                               );
                           RAISE g_exception_halt_validation;
                        END IF;

                        l_subline_amount := NULL;

                        OPEN l_amount_csr (p_kdtl_tbl (l_ctr).object_line_id);

                        FETCH l_amount_csr
                         INTO l_subline_amount;

                        CLOSE l_amount_csr;

                        UPDATE okc_k_lines_b
                           SET price_negotiated =
                                  (SELECT NVL (SUM (NVL (price_negotiated, 0)),0)
                                     FROM okc_k_lines_b
                                    WHERE cle_id = p_kdtl_tbl (l_ctr).service_line_id
                                      AND dnz_chr_id = p_kdtl_tbl (l_ctr).hdr_id
				      and date_cancelled is null)
                         WHERE ID = p_kdtl_tbl (l_ctr).service_line_id;

                         UPDATE oks_k_lines_b
                            SET tax_amount =
                            (SELECT (NVL (SUM (NVL(tax_amount,0)),0))
                               FROM oks_k_lines_b
                              WHERE cle_id IN ( SELECT id
                                                  FROM okc_k_lines_b
                                                 WHERE cle_id =  p_kdtl_tbl (l_ctr).service_line_id
                                                   AND lse_id IN (9,25)
                                                   AND date_cancelled IS NULL ))
                        WHERE cle_id =p_kdtl_tbl (l_ctr).service_line_id;

                        UPDATE okc_k_headers_b
                           SET estimated_amount =
                                  (SELECT NVL (SUM (NVL (price_negotiated, 0)), 0 )
                                     FROM okc_k_lines_b
                                    WHERE dnz_chr_id = p_kdtl_tbl (l_ctr).hdr_id
                                      AND lse_id IN (1, 19)
				      AND date_cancelled IS NULL )
                         WHERE ID = p_kdtl_tbl (l_ctr).hdr_id;


                         UPDATE oks_k_headers_b
                            SET tax_amount = ( SELECT (NVL (SUM (NVL(tax_amount,0)),0))
                                                 FROM oks_k_lines_b
                                                WHERE cle_id IN (SELECT id
                                                                   FROM okc_k_lineS_b
                                                                  WHERE dnz_chr_id = p_kdtl_tbl (l_ctr).hdr_id
                                                                    AND date_cancelled IS NULL
                                                                    AND lse_id IN (1,19)))
                         WHERE chr_id = p_kdtl_tbl (l_ctr).hdr_id;

                        l_inst_dtls_tbl (l_ptr).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                        l_inst_dtls_tbl (l_ptr).transaction_type := 'UPD';
                        l_inst_dtls_tbl (l_ptr).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
                        l_inst_dtls_tbl (l_ptr).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
                        l_inst_dtls_tbl (l_ptr).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                        l_inst_dtls_tbl (l_ptr).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                        l_inst_dtls_tbl (l_ptr).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                        l_inst_dtls_tbl (l_ptr).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                        l_inst_dtls_tbl (l_ptr).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                        l_inst_dtls_tbl (l_ptr).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                        l_inst_dtls_tbl (l_ptr).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                        l_inst_dtls_tbl (l_ptr).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                        l_inst_dtls_tbl (l_ptr).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                        l_inst_dtls_tbl (l_ptr).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                        l_inst_dtls_tbl (l_ptr).old_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                        l_inst_dtls_tbl (l_ptr).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
                        l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                                              l_subline_amount;
                        l_inst_dtls_tbl (l_ptr).instance_qty_new :=
                                               p_kdtl_tbl (l_ctr).new_quantity;
                        l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                        l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                        l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                        l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                        l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                        l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                        l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                        l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                        l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                        l_inst_dtls_tbl (l_ptr).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                        l_inst_dtls_tbl (l_ptr).new_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                     ELSE                          --billed_amount is not null
                           --errorout_n('in update l_billed_amount2'||l_billed_amount);
                        -- If line is fully billed , terminate the subline, issue credit and create a new subline with the updated qty
                        IF l_billed_amount =
                                            p_kdtl_tbl (l_ctr).service_amount
                        THEN
                           -- Terminate the subline and create a New Subline with the update qty
                           IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                           THEN
                              fnd_log.STRING (fnd_log.level_statement,
                                                 g_module_current
                                              || '.CREATE_CONTRACT_IBUPDATE',
                                              'The Line is fully billed'
                                             );
                           END IF;

                           get_sts_code (NULL,
                                         p_kdtl_tbl (l_ctr).hdr_sts,
                                         l_ste_code,
                                         l_sts_code
                                        );

                           IF l_ste_code = 'HOLD'
                           THEN
                              l_return_status := okc_api.g_ret_sts_error;

                              IF fnd_log.level_error >=
                                              fnd_log.g_current_runtime_level
                              THEN
                                 fnd_log.STRING
                                          (fnd_log.level_error,
                                              g_module_current
                                           || '.CREATE_CONTRACT_IBUPDATE.ERROR',
                                           ' Contract in QA_HOLD status'
                                          );
                              END IF;

                              okc_api.set_message
                                  (g_app_name,
                                   g_invalid_value,
                                   g_col_name_token,
                                      'Quantity Update not allowed. Contract '
                                   || p_kdtl_tbl (l_ctr).contract_number
                                   || ' is in QA_HOLD status'
                                  );
                              RAISE g_exception_halt_validation;
                           END IF;

                           ---to pass the term_cancel source.....
                           oks_bill_rec_pub.pre_terminate_cp
                              (p_calledfrom                => -1,
                               p_cle_id                    => p_kdtl_tbl
                                                                        (l_ctr).object_line_id,
                               p_termination_date          => TRUNC
                                                                 (p_kdtl_tbl
                                                                        (l_ctr).prod_sdt
                                                                 ),
                               p_terminate_reason          => 'UPD',
                               p_override_amount           => NULL,
                               p_con_terminate_amount      => NULL,
                               p_termination_amount        => NULL,
                               p_suppress_credit           => 'N',
                               p_full_credit               => 'Y',
                               p_term_date_flag            => 'N',
                               p_term_cancel_source        => 'IBUPDATE',
                               x_return_status             => l_return_status
                              );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBUPDATE',
                                     ' oks_bill_rec_pub.Pre_terminate_cp(Retun status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           l_inst_dtls_tbl (l_ptr).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                           l_inst_dtls_tbl (l_ptr).transaction_type := 'UPD';
                           l_inst_dtls_tbl (l_ptr).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
                           l_inst_dtls_tbl (l_ptr).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
                           l_inst_dtls_tbl (l_ptr).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                           l_inst_dtls_tbl (l_ptr).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                           l_inst_dtls_tbl (l_ptr).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                           l_inst_dtls_tbl (l_ptr).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                           l_inst_dtls_tbl (l_ptr).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                           l_inst_dtls_tbl (l_ptr).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                           l_inst_dtls_tbl (l_ptr).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                           l_inst_dtls_tbl (l_ptr).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                           l_inst_dtls_tbl (l_ptr).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           l_inst_dtls_tbl (l_ptr).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                           l_inst_dtls_tbl (l_ptr).old_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                           l_inst_dtls_tbl (l_ptr).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
                           l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                             p_kdtl_tbl (l_ctr).service_amount;
                           l_inst_dtls_tbl (l_ptr).instance_qty_new :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
                           l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                           l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                           l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                           l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                           l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                           l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                           l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                           l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                           l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           l_inst_dtls_tbl (l_ptr).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                           l_inst_dtls_tbl (l_ptr).new_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                           l_inst_dtls_tbl (l_ptr).subline_date_terminated :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                           l_ptr := l_ptr + 1;
                           l_covd_rec.k_id := p_kdtl_tbl (l_ctr).hdr_id;
                           l_covd_rec.attach_2_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                           l_covd_rec.line_number := 1;
                           l_covd_rec.customer_product_id :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
                           l_covd_rec.product_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                           l_covd_rec.product_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           l_covd_rec.quantity :=
                                               p_kdtl_tbl (l_ctr).new_quantity;

                           IF p_kdtl_tbl (l_ctr).lse_id = 25
                           THEN
                              l_warranty_flag := 'E';
                           ELSIF     p_kdtl_tbl (l_ctr).lse_id = 9
                                 AND p_kdtl_tbl (l_ctr).scs_code = 'SERVICE'
                           THEN
                              l_warranty_flag := 'S';
                           ELSIF p_kdtl_tbl (l_ctr).lse_id = 18
                           THEN
                              l_warranty_flag := 'W';
                           ELSIF     p_kdtl_tbl (l_ctr).lse_id = 9
                                 AND p_kdtl_tbl (l_ctr).scs_code =
                                                                'SUBSCRIPTION'
                           THEN
                              l_warranty_flag := 'SU';
                           END IF;

                           l_covd_rec.warranty_flag := l_warranty_flag;
                           l_covd_rec.uom_code := p_kdtl_tbl (l_ctr).uom_code;
                           l_covd_rec.currency_code :=
                                           p_kdtl_tbl (l_ctr).service_currency;
                           l_covd_rec.product_sts_code :=
                                              p_kdtl_tbl (l_ctr).prod_sts_code;

                           OPEN l_serv_csr
                                       (p_kdtl_tbl (l_ctr).service_inventory_id
                                       );

                           FETCH l_serv_csr
                            INTO l_covd_rec.attach_2_line_desc;

                           CLOSE l_serv_csr;

                           l_covd_rec.line_renewal_type :=
                                     p_kdtl_tbl (l_ctr).prod_line_renewal_type;
                           l_covd_rec.list_price := 0;
                           l_covd_rec.negotiated_amount := 0;
                           l_covd_rec.prod_item_id :=
                                        p_kdtl_tbl (l_ctr).prod_inventory_item;
                           l_covd_rec.price_uom :=
                                             p_kdtl_tbl (l_ctr).price_uom_code;
                           l_covd_rec.toplvl_uom_code :=
                                            p_kdtl_tbl (l_ctr).toplvl_uom_code;
                           --mchoudha added for bug#5233956
                           l_covd_rec.toplvl_price_qty :=
                                            p_kdtl_tbl (l_ctr).toplvl_price_qty;
                           oks_extwarprgm_pvt.create_k_covered_levels
                                       (p_k_covd_rec         => l_covd_rec,
                                        p_price_attribs      => l_price_attribs_in,
                                        p_caller             => 'IB',
                                        x_order_error        => l_temp,
                                        x_covlvl_id          => l_covlvl_id,
                                        x_update_line        => l_update_top_line,
                                        x_return_status      => l_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data
                                       );

                           --errorout_n('in update Create_K_Covered_Levels l_return_status'||l_return_status);
                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBUPDATE',
                                     'oks_extwarprgm_pvt.create_k_covered_levels(Retun status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = 'S'
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           l_create_oper_instance := 'N';

                           IF    l_opr_instance_id IS NULL
                              OR l_target_chr_id <> p_kdtl_tbl (l_ctr).hdr_id
                           THEN
                              l_target_chr_id := p_kdtl_tbl (l_ctr).hdr_id;
                              l_create_oper_instance := 'Y';
                           END IF;

                           create_transaction_source
                              (p_create_opr_inst       => 'Y',
                               p_source_code           => 'IBUPDATE',
                               p_target_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                               p_source_line_id        => p_kdtl_tbl (l_ctr).object_line_id,
                               p_source_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                               p_target_line_id        => l_covlvl_id,
                               x_oper_instance_id      => l_opr_instance_id,
                               x_return_status         => l_return_status,
                               x_msg_count             => x_msg_count,
                               x_msg_data              => x_msg_data
                              );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBUPDATE',
                                     'Create_transaction_source(Retun status = '
                                  || l_return_status
                                  || ')'
                                 );
                           END IF;

                           IF NOT l_return_status = 'S'
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           IF    l_renewal_opr_instance_id IS NULL
                              OR l_target_chr_id <> p_kdtl_tbl (l_ctr).hdr_id
                           THEN
                              l_create_oper_instance := 'Y';
                           ELSE
                              l_create_oper_instance := 'N';
                           END IF;

                           create_source_links
                              (p_create_opr_inst       => l_create_oper_instance,
                               p_source_code           => 'IBUPDATE',
                               p_target_chr_id         => p_kdtl_tbl (l_ctr).hdr_id,
                               p_line_id               => p_kdtl_tbl (l_ctr).object_line_id,
                               p_target_line_id        => l_covlvl_id,
                               p_txn_date              => p_kdtl_tbl (l_ctr).transaction_date,
                               x_oper_instance_id      => l_renewal_opr_instance_id,
                               x_return_status         => l_return_status,
                               x_msg_count             => x_msg_count,
                               x_msg_data              => x_msg_data
                              );

                           IF NOT l_return_status = 'S'
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                    (fnd_log.level_event,
                                        g_module_current
                                     || '.CREATE_CONTRACT_IBUPDATE',
                                        'Create_source_links(Retun status = '
                                     || l_return_status
                                     || ')'
                                    );
                           END IF;

                           l_input_details.line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                           l_input_details.subline_id := l_covlvl_id;
                           l_input_details.intent := 'SP';
                           oks_qp_int_pvt.compute_price
                                       (p_api_version              => 1.0,
                                        p_init_msg_list            => 'T',
                                        p_detail_rec               => l_input_details,
                                        x_price_details            => l_output_details,
                                        x_modifier_details         => l_modif_details,
                                        x_price_break_details      => l_pb_details,
                                        x_return_status            => l_return_status,
                                        x_msg_count                => l_msg_count,
                                        x_msg_data                 => l_msg_data
                                       );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBUPDATE',
                                     'oks_qp_int_pvt.compute_price(Retun status = '
                                  || l_return_status
                                  || ',Repriced amount = '
                                  || l_output_details.serv_ext_amount
                                  || ')'
                                 );
                           END IF;

                           IF l_return_status <> okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           l_subline_amount := NULL;

                           OPEN l_amount_csr (l_covlvl_id);

                           FETCH l_amount_csr
                            INTO l_subline_amount;

                           CLOSE l_amount_csr;

                           IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                           THEN
                              fnd_log.STRING (fnd_log.level_statement,
                                                 g_module_current
                                              || '.CREATE_CONTRACT_IBUPDATE',
                                                 'Subline Amount = '
                                              || l_subline_amount
                                             );
                           END IF;

                           UPDATE okc_k_lines_b
                              SET price_negotiated =
                                     (SELECT NVL (SUM (NVL (price_negotiated,0 ) ), 0 )
                                        FROM okc_k_lines_b
                                       WHERE cle_id = p_kdtl_tbl (l_ctr).service_line_id
                                         AND dnz_chr_id = p_kdtl_tbl (l_ctr).hdr_id
					 AND date_cancelled is NULL)
                            WHERE ID = p_kdtl_tbl (l_ctr).service_line_id;

                            UPDATE oks_k_lines_b
                               SET tax_amount =
                               (SELECT (NVL (SUM (NVL(tax_amount,0)),0))
                        	  FROM oks_k_lines_b
                        	 WHERE cle_id IN ( SELECT id
                                                     FROM okc_k_lines_b
                                                    WHERE cle_id =  p_kdtl_tbl (l_ctr).service_line_id
                                                      AND lse_id IN (9,25)
                                                      AND date_cancelled IS NULL ))
                	    WHERE cle_id =p_kdtl_tbl (l_ctr).service_line_id;

                           UPDATE okc_k_headers_b
                              SET estimated_amount =
                                     (SELECT NVL (SUM (NVL (price_negotiated,
                                                            0
                                                           )
                                                      ),
                                                  0
                                                 )
                                        FROM okc_k_lines_b
                                       WHERE dnz_chr_id =
                                                     p_kdtl_tbl (l_ctr).hdr_id
                                         AND lse_id IN (1, 19)
					 AND date_cancelled IS NULL)
                            WHERE ID = p_kdtl_tbl (l_ctr).hdr_id;

                            UPDATE oks_k_headers_b
                               SET tax_amount = ( SELECT (NVL (SUM (NVL(tax_amount,0)),0))
                                                    FROM oks_k_lines_b
                                                   WHERE cle_id IN (SELECT id
                                                                      FROM okc_k_lineS_b
                                                                     WHERE dnz_chr_id = p_kdtl_tbl (l_ctr).hdr_id
                                                                       AND date_cancelled IS NULL
                                                                       AND lse_id IN (1,19)))
                            WHERE chr_id = p_kdtl_tbl (l_ctr).hdr_id;

			   l_inst_dtls_tbl (l_ptr).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                           l_inst_dtls_tbl (l_ptr).transaction_type := 'UPD';
                           l_inst_dtls_tbl (l_ptr).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
                           l_inst_dtls_tbl (l_ptr).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
                           l_inst_dtls_tbl (l_ptr).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                           l_inst_dtls_tbl (l_ptr).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                           l_inst_dtls_tbl (l_ptr).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                           l_inst_dtls_tbl (l_ptr).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                           l_inst_dtls_tbl (l_ptr).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                           l_inst_dtls_tbl (l_ptr).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                           l_inst_dtls_tbl (l_ptr).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                           l_inst_dtls_tbl (l_ptr).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                           l_inst_dtls_tbl (l_ptr).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           l_inst_dtls_tbl (l_ptr).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                           l_inst_dtls_tbl (l_ptr).old_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                           l_inst_dtls_tbl (l_ptr).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
                           l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                                              l_subline_amount;
                           l_inst_dtls_tbl (l_ptr).instance_qty_new :=
                                               p_kdtl_tbl (l_ctr).new_quantity;
                           l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                           l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                           l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                           l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                           l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                           l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                           l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                                                   l_covlvl_id;
                           l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                           l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           l_inst_dtls_tbl (l_ptr).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                           l_inst_dtls_tbl (l_ptr).new_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;

                           --x_inst_dtls_tbl(l_ptr).subline_date_terminated   := p_kdtl_tbl( l_ctr ).prod_sdt;
                           ---update billing schedule
                           IF check_lvlelements_exists
                                            (p_kdtl_tbl (l_ctr).service_line_id
                                            )
                           THEN
                              oks_bill_sch.create_bill_sch_cp
                                 (p_top_line_id        => p_kdtl_tbl (l_ctr).service_line_id,
                                  p_cp_line_id         => l_covlvl_id,
                                  p_cp_new             => 'Y',
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data
                                 );

                              IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                 )
                              THEN
                                 fnd_log.STRING
                                    (fnd_log.level_event,
                                        g_module_current
                                     || '.CREATE_CONTRACT_IBUPDATE',
                                        'oks_bill_sch.create_bill_sch_cp(Retun status = '
                                     || l_return_status
                                     || ')'
                                    );
                              END IF;

                              IF l_return_status <> okc_api.g_ret_sts_success
                              THEN
                                 okc_api.set_message
                                                 (g_app_name,
                                                  g_required_value,
                                                  g_col_name_token,
                                                  'Sched Billing Rule (LINE)'
                                                 );
                                 RAISE g_exception_halt_validation;
                              END IF;
                           END IF;
                        ELSE       --Billed amount is less than service amount
                           UPDATE okc_k_items
                              SET number_of_items =
                                               p_kdtl_tbl (l_ctr).new_quantity
                            WHERE cle_id = p_kdtl_tbl (l_ctr).object_line_id;

                           l_input_details.line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                           l_input_details.subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                           l_input_details.intent := 'SP';
                           oks_qp_int_pvt.compute_price
                                       (p_api_version              => 1.0,
                                        p_init_msg_list            => 'T',
                                        p_detail_rec               => l_input_details,
                                        x_price_details            => l_output_details,
                                        x_modifier_details         => l_modif_details,
                                        x_price_break_details      => l_pb_details,
                                        x_return_status            => l_return_status,
                                        x_msg_count                => l_msg_count,
                                        x_msg_data                 => l_msg_data
                                       );

                           IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                              )
                           THEN
                              fnd_log.STRING
                                 (fnd_log.level_event,
                                     g_module_current
                                  || '.CREATE_CONTRACT_IBUPDATE',
                                     'oks_qp_int_pvt.compute_price(Retun status = '
                                  || l_return_status
                                  || ',Repriced amount = '
                                  || l_output_details.serv_ext_amount
                                  || ')'
                                 );
                           END IF;

                           IF l_return_status <> okc_api.g_ret_sts_success
                           THEN
                              RAISE g_exception_halt_validation;
                           END IF;

                           l_amount := l_output_details.serv_ext_amount;

                           IF l_amount <= l_billed_amount
                           THEN
                              UPDATE okc_k_lines_b
                                 SET price_negotiated = l_billed_amount
                               WHERE ID = p_kdtl_tbl (l_ctr).object_line_id;
                           END IF;

                           l_subline_amount := NULL;

                           OPEN l_amount_csr (p_kdtl_tbl (l_ctr).object_line_id
                                             );

                           FETCH l_amount_csr
                            INTO l_subline_amount;

                           CLOSE l_amount_csr;

                           UPDATE okc_k_lines_b
                              SET price_negotiated =
                                     (SELECT NVL (SUM (NVL (price_negotiated,
                                                            0
                                                           )
                                                      ),
                                                  0
                                                 )
                                        FROM okc_k_lines_b
                                       WHERE cle_id =
                                                p_kdtl_tbl (l_ctr).service_line_id
                                         AND dnz_chr_id =
                                                     p_kdtl_tbl (l_ctr).hdr_id
					 AND date_cancelled IS NULL)
                            WHERE ID = p_kdtl_tbl (l_ctr).service_line_id;

                            UPDATE oks_k_lines_b
                               SET tax_amount =
                               (SELECT (NVL (SUM (NVL(tax_amount,0)),0))
                        	  FROM oks_k_lines_b
                        	 WHERE cle_id IN ( SELECT id
                                                     FROM okc_k_lines_b
                                                    WHERE cle_id =  p_kdtl_tbl (l_ctr).service_line_id
                                                      AND lse_id IN (9,25)
                                                      AND date_cancelled IS NULL ))
                            WHERE cle_id =p_kdtl_tbl (l_ctr).service_line_id;

                           UPDATE okc_k_headers_b
                              SET estimated_amount =
                                     (SELECT NVL (SUM (NVL (price_negotiated,
                                                            0
                                                           )
                                                      ),
                                                  0
                                                 )
                                        FROM okc_k_lines_b
                                       WHERE dnz_chr_id =
                                                     p_kdtl_tbl (l_ctr).hdr_id
                                         AND lse_id IN (1, 19)
					 AND date_cancelled IS NULL)
                            WHERE ID = p_kdtl_tbl (l_ctr).hdr_id;


                            UPDATE oks_k_headers_b
                               SET tax_amount = ( SELECT (NVL (SUM (NVL(tax_amount,0)),0))
                                                    FROM oks_k_lines_b
                                                   WHERE cle_id IN (SELECT id
                                                                      FROM okc_k_lineS_b
                                                                     WHERE dnz_chr_id = p_kdtl_tbl (l_ctr).hdr_id
                                                                       AND date_cancelled IS NULL
                                                                       AND lse_id IN (1,19)))
                            WHERE chr_id = p_kdtl_tbl (l_ctr).hdr_id;

                           ---update billing schedule
                           IF check_lvlelements_exists
                                            (p_kdtl_tbl (l_ctr).service_line_id
                                            )
                           THEN
                              oks_bill_sch.create_bill_sch_cp
                                 (p_top_line_id        => p_kdtl_tbl (l_ctr).service_line_id,
                                  p_cp_line_id         => p_kdtl_tbl (l_ctr).object_line_id,
                                  p_cp_new             => 'N',
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data
                                 );

                              IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                                 )
                              THEN
                                 fnd_log.STRING
                                    (fnd_log.level_event,
                                        g_module_current
                                     || '.CREATE_CONTRACT_IBUPDATE',
                                        'oks_bill_sch.create_bill_sch_cp(Retun status = '
                                     || l_return_status
                                     || ')'
                                    );
                              END IF;

                              IF l_return_status <> okc_api.g_ret_sts_success
                              THEN
                                 okc_api.set_message
                                                 (g_app_name,
                                                  g_required_value,
                                                  g_col_name_token,
                                                  'Sched Billing Rule (LINE)'
                                                 );
                                 RAISE g_exception_halt_validation;
                              END IF;
                           END IF;

                           l_inst_dtls_tbl (l_ptr).transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                           l_inst_dtls_tbl (l_ptr).transaction_type := 'UPD';
                           l_inst_dtls_tbl (l_ptr).instance_amt_old :=
                                             p_kdtl_tbl (l_ctr).service_amount;
                           l_inst_dtls_tbl (l_ptr).instance_qty_old :=
                                            p_kdtl_tbl (l_ctr).old_cp_quantity;
                           l_inst_dtls_tbl (l_ptr).old_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                           l_inst_dtls_tbl (l_ptr).old_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                           l_inst_dtls_tbl (l_ptr).old_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                           l_inst_dtls_tbl (l_ptr).old_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                           l_inst_dtls_tbl (l_ptr).old_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                           l_inst_dtls_tbl (l_ptr).old_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                           l_inst_dtls_tbl (l_ptr).old_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                           l_inst_dtls_tbl (l_ptr).old_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                           l_inst_dtls_tbl (l_ptr).old_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           l_inst_dtls_tbl (l_ptr).old_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                           l_inst_dtls_tbl (l_ptr).old_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                           l_inst_dtls_tbl (l_ptr).instance_id_new :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
                           l_inst_dtls_tbl (l_ptr).instance_amt_new :=
                                                              l_subline_amount;
                           l_inst_dtls_tbl (l_ptr).instance_qty_new :=
                                               p_kdtl_tbl (l_ctr).new_quantity;
                           l_inst_dtls_tbl (l_ptr).new_contract_id :=
                                                     p_kdtl_tbl (l_ctr).hdr_id;
                           l_inst_dtls_tbl (l_ptr).new_contact_start_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_sdt;
                           l_inst_dtls_tbl (l_ptr).new_contract_end_date :=
                                                    p_kdtl_tbl (l_ctr).hdr_edt;
                           l_inst_dtls_tbl (l_ptr).new_service_line_id :=
                                            p_kdtl_tbl (l_ctr).service_line_id;
                           l_inst_dtls_tbl (l_ptr).new_service_start_date :=
                                                p_kdtl_tbl (l_ctr).service_sdt;
                           l_inst_dtls_tbl (l_ptr).new_service_end_date :=
                                                p_kdtl_tbl (l_ctr).service_edt;
                           l_inst_dtls_tbl (l_ptr).new_subline_id :=
                                             p_kdtl_tbl (l_ctr).object_line_id;
                           l_inst_dtls_tbl (l_ptr).new_subline_start_date :=
                                                   p_kdtl_tbl (l_ctr).prod_sdt;
                           l_inst_dtls_tbl (l_ptr).new_subline_end_date :=
                                                   p_kdtl_tbl (l_ctr).prod_edt;
                           l_inst_dtls_tbl (l_ptr).new_customer :=
                                               p_kdtl_tbl (l_ctr).cust_account;
                           l_inst_dtls_tbl (l_ptr).new_k_status :=
                                                    p_kdtl_tbl (l_ctr).hdr_sts;
                        END IF;
                     END IF;                         -- Billed amt is not null
                  END IF;                                       -- if Warranty
               END IF;

               --errorout_n('l_inst_dtls_tbl.count'||l_inst_dtls_tbl.count);
               IF l_inst_dtls_tbl.COUNT <> 0
               THEN
                  IF l_old_cp_id <> p_kdtl_tbl (l_ctr).old_cp_id
                  THEN
                     OPEN l_refnum_csr (p_kdtl_tbl (l_ctr).old_cp_id);

                     FETCH l_refnum_csr
                      INTO l_ref_num;

                     CLOSE l_refnum_csr;

                     l_parameters :=
                           ' Old CP :'
                        || p_kdtl_tbl (l_ctr).old_cp_id
                        || ','
                        || 'Item Id:'
                        || p_kdtl_tbl (l_ctr).prod_inventory_item
                        || ','
                        || 'Old Quantity:'
                        || p_kdtl_tbl (l_ctr).old_cp_quantity
                        || ','
                        || 'Transaction type :'
                        || 'UPD'
                        || ','
                        || ' Transaction date :'
                        || TRUNC(p_kdtl_tbl (l_ctr).transaction_date)
                        || ','
                        || 'New quantity:'
                        || p_kdtl_tbl (l_ctr).new_quantity;
                     --oks_instance_history
                     l_old_cp_id := p_kdtl_tbl (l_ctr).old_cp_id;
                     l_insthist_rec.instance_id :=
                                                  p_kdtl_tbl (l_ctr).old_cp_id;
                     l_insthist_rec.transaction_type := 'UPD';
                     l_insthist_rec.transaction_date :=
                                           TRUNC(p_kdtl_tbl (l_ctr).transaction_date);
                     l_insthist_rec.reference_number := l_ref_num;
                     l_insthist_rec.PARAMETERS := l_parameters;
                     oks_ins_pvt.insert_row
                                          (p_api_version        => 1.0,
                                           p_init_msg_list      => 'T',
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_insv_rec           => l_insthist_rec,
                                           x_insv_rec           => x_insthist_rec
                                          );

                     IF (fnd_log.level_event >=
                                               fnd_log.g_current_runtime_level
                        )
                     THEN
                        fnd_log.STRING
                                (fnd_log.level_event,
                                    g_module_current
                                 || '.CREATE_CONTRACT_IBUPDATE',
                                    'oks_ins_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
                     END IF;

                     x_return_status := l_return_status;

                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN
                        x_return_status := l_return_status;
                        RAISE g_exception_halt_validation;
                     END IF;

                     l_instparent_id := x_insthist_rec.ID;
                  END IF;

                  FOR i IN l_inst_dtls_tbl.FIRST .. l_inst_dtls_tbl.LAST
                  LOOP
                     l_inst_dtls_tbl (i).ins_id := l_instparent_id;
                  END LOOP;

                  --oks_inst_history_details
                  oks_ihd_pvt.insert_row (p_api_version        => 1.0,
                                          p_init_msg_list      => 'T',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => l_msg_count,
                                          x_msg_data           => l_msg_data,
                                          p_ihdv_tbl           => l_inst_dtls_tbl,
                                          x_ihdv_tbl           => x_inst_dtls_tbl
                                         );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                                (fnd_log.level_event,
                                    g_module_current
                                 || '.CREATE_CONTRACT_IBUPDATE',
                                    'oks_ihd_pvt.insert_row(Return status = '
                                 || l_return_status
                                 || ')'
                                );
                  END IF;

                  x_return_status := l_return_status;

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;
                     RAISE g_exception_halt_validation;
                  END IF;
               END IF;
            END IF;

            EXIT WHEN l_ctr = p_kdtl_tbl.LAST;
            l_ctr := p_kdtl_tbl.NEXT (l_ctr);
         END LOOP;
      END IF;

      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE get_jtf_resource (
      p_authorg_id                   NUMBER,
      p_party_id                     NUMBER,
      x_winners_rec     OUT NOCOPY   jtf_terr_assign_pub.bulk_winners_rec_type,
      x_msg_count       OUT NOCOPY   NUMBER,
      x_msg_data        OUT NOCOPY   VARCHAR2,
      x_return_status   OUT NOCOPY   VARCHAR2
   )
   IS
-- Fix for bug 4142999
      CURSOR get_vendor_details
      IS
         SELECT a.party_name, b.country, b.region_2
           FROM hr_locations b, hr_all_organization_units c, hz_parties a
          WHERE b.location_id = c.location_id
            AND c.organization_id = p_authorg_id
            AND a.party_id = p_party_id;

      CURSOR get_party_details
      IS
         SELECT hz.party_name, hzl.country, hzl.state
           FROM hz_parties hz, hz_party_sites hzs, hz_locations hzl
          WHERE hz.party_id = p_party_id
            AND hzs.party_id = hz.party_id
            AND hzs.identifying_address_flag = 'Y'
            AND hzl.location_id = hzs.location_id;

      l_gen_bulk_rec     jtf_terr_assign_pub.bulk_trans_rec_type;
      l_gen_return_rec   jtf_terr_assign_pub.bulk_winners_rec_type;
      l_party_name       VARCHAR2 (360);
      l_country_code     VARCHAR2 (60);
      l_state_code       VARCHAR2 (120);
      l_use_type         VARCHAR2 (30);
      l_msg_count        NUMBER;
      l_msg_data         VARCHAR2 (200);
      l_return_status    VARCHAR2 (3);
   BEGIN
-- Fix for bug 4142999
      IF NVL (fnd_profile.VALUE ('OKS_SRC_TERR_QUALFIERS'), 'V') = 'V'
      THEN
         OPEN get_vendor_details;

         FETCH get_vendor_details
          INTO l_party_name, l_country_code, l_state_code;

         CLOSE get_vendor_details;
      ELSE
         OPEN get_party_details;

         FETCH get_party_details
          INTO l_party_name, l_country_code, l_state_code;

         CLOSE get_party_details;
      END IF;

      l_gen_bulk_rec.trans_object_id.EXTEND;
      l_gen_bulk_rec.trans_detail_object_id.EXTEND;
      l_gen_bulk_rec.squal_char01.EXTEND;
      l_gen_bulk_rec.squal_char04.EXTEND;
      l_gen_bulk_rec.squal_char07.EXTEND;
      l_gen_bulk_rec.squal_num01.EXTEND;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current,
                            'Values passed to JTF API : '
                         || ' Party ID '
                         || p_party_id
                         || ' Party Name'
                         || l_party_name
                         || ' State Code'
                         || l_state_code
                         || ' Country Code'
                         || l_country_code
                         || ' Territory Qualifier profile '
                         || fnd_profile.VALUE ('OKS_SRC_TERR_QUALFIERS')
                        );
      END IF;

      l_gen_bulk_rec.trans_object_id (1) := 100;
      l_gen_bulk_rec.trans_detail_object_id (1) := 1000;
      l_gen_bulk_rec.squal_char01 (1) := l_party_name;
      l_gen_bulk_rec.squal_char04 (1) := l_state_code;
      l_gen_bulk_rec.squal_char07 (1) := l_country_code;
      l_gen_bulk_rec.squal_num01 (1) := p_party_id;
      l_use_type := 'RESOURCE';

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current
                         || '.JTF_TERR_ASSIGN_PUB.get_winners',
                         'Before JTF API call '
                        );
      END IF;

      jtf_terr_assign_pub.get_winners
                                   (p_api_version_number      => 1.0,
                                    p_init_msg_list           => okc_api.g_false,
                                    p_use_type                => l_use_type,
                                    p_source_id               => -1500,
                                    p_trans_id                => -1501,
                                    p_trans_rec               => l_gen_bulk_rec,
                                    p_resource_type           => fnd_api.g_miss_char,
                                    p_role                    => fnd_api.g_miss_char,
                                    p_top_level_terr_id       => fnd_api.g_miss_num,
                                    p_num_winners             => fnd_api.g_miss_num,
                                    x_return_status           => l_return_status,
                                    x_msg_count               => l_msg_count,
                                    x_msg_data                => l_msg_data,
                                    x_winners_rec             => l_gen_return_rec
                                   );
      x_winners_rec := l_gen_return_rec;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current
                         || '.JTF_TERR_ASSIGN_PUB.get_winners',
                         'After JTF call '
                        );
      END IF;
   END get_jtf_resource;

   PROCEDURE send_notification (
      p_order_id      IN   NUMBER,
      p_contract_id        NUMBER,
      p_type          IN   VARCHAR2
   )
   IS
      CURSOR l_fnd_csr (p_user_id NUMBER)
      IS
         SELECT user_name
           FROM fnd_user
          WHERE user_id = p_user_id;

      CURSOR get_order_number
      IS
         SELECT order_number
           FROM oe_order_headers_all
          WHERE header_id = p_order_id;

      CURSOR get_contract_number
      IS
         SELECT contract_number || ' ' || contract_number_modifier
           FROM okc_k_headers_all_b
          WHERE ID = p_contract_id;

      l_return_status          VARCHAR2 (10);
      l_msg_data               VARCHAR2 (2000);
      l_msg_count              NUMBER;
      l_terr_admin_id          NUMBER;
      l_order_number           NUMBER          := 0;
      l_contract_number        VARCHAR2 (2000);
      l_contract_admin_id      NUMBER;
      l_contract_approver_id   NUMBER;
      l_subj                   VARCHAR2 (1000);
      l_msg                    VARCHAR2 (1000);
      l_user_name              VARCHAR2 (100);
      l_order_num_prompt       VARCHAR2 (100);
   BEGIN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current,
                         'Inside  SEND_NOTIFICATION : '
                        );
      END IF;

      l_subj := fnd_message.get_string ('OKS', 'OKS_TERR_SETUP_ERR_SUB');
      l_terr_admin_id := fnd_profile.VALUE ('OKS_TERR_ADMIN_ID');

      IF (l_terr_admin_id IS NULL)
      THEN
         l_contract_admin_id := fnd_profile.VALUE ('OKS_CONTRACT_ADMIN_ID');
      END IF;

      IF l_terr_admin_id IS NOT NULL
      THEN
         OPEN l_fnd_csr (l_terr_admin_id);

         FETCH l_fnd_csr
          INTO l_user_name;

         CLOSE l_fnd_csr;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module_current,
                            'Territory Admin is not null  - ' || l_user_name
                           );
         END IF;
      ELSIF l_contract_admin_id IS NOT NULL
      THEN
         OPEN l_fnd_csr (l_contract_admin_id);

         FETCH l_fnd_csr
          INTO l_user_name;

         CLOSE l_fnd_csr;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module_current,
                            'Contract Admin is not null  - ' || l_user_name
                           );
         END IF;
      ELSE
         l_user_name := fnd_profile.VALUE ('OKC_K_APPROVER');

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module_current,
                            'Contract Approver is not null  - ' || l_user_name
                           );
         END IF;
      END IF;

      IF p_order_id IS NOT NULL
      THEN
         OPEN get_order_number;

         FETCH get_order_number
          INTO l_order_number;

         CLOSE get_order_number;

         l_order_num_prompt :=
                           fnd_message.get_string ('OKS', 'OKS_ORDER_NUMBER');
         l_subj :=
               l_subj || ' ' || l_order_num_prompt || ' - ' || l_order_number;
      ELSE
         OPEN get_contract_number;

         FETCH get_contract_number
          INTO l_contract_number;

         CLOSE get_contract_number;

         l_subj :=
               l_subj
            || ' '
            || fnd_message.get_string ('OKS', 'OKS_CONTRACT_NUMBER')
            || ' - '
            || l_contract_number;
      END IF;

      IF (p_type = 'NRS')
      THEN
         l_msg := fnd_message.get_string ('OKS', 'OKS_NO_TERR_RESOURCES');
      ELSIF (p_type = 'ISP')
      THEN
         l_msg := fnd_message.get_string ('OKS', 'OKS_INVALID_SALES_PERSON');
      ELSE
         l_msg := fnd_message.get_string ('OKS', 'OKS_TERR_SETUP_ERR_SUB');
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current,
                            'p_recipient is '
                         || l_user_name
                         || ' Order no is  '
                         || l_order_number
                         || 'Contract Number Is  '
                         || l_contract_number
                        );
      END IF;

      okc_async_pub.msg_call (p_api_version        => 1,
                              x_return_status      => l_return_status,
                              x_msg_count          => l_msg_count,
                              x_msg_data           => l_msg_data,
                              p_recipient          => l_user_name,
                              p_msg_body           => l_msg,
                              p_msg_subj           => l_subj,
                              p_contract_id        => NVL (l_order_number,
                                                           p_contract_id
                                                          )
                             );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current,
                         'Exiting Send_notification ' || l_return_status
                        );
      END IF;
   END send_notification;
END oks_extwarprgm_pvt;

/
