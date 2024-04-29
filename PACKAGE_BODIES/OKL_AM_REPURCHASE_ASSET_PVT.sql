--------------------------------------------------------
--  DDL for Package Body OKL_AM_REPURCHASE_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_REPURCHASE_ASSET_PVT" AS
/* $Header: OKLRRQUB.pls 120.6 2007/12/18 09:32:20 akrangan noship $ */

   ---------------------------------------------------------------------------
-- GLOBAL DATASTRUCTURES
---------------------------------------------------------------------------
   SUBTYPE rulv_rec_type IS okl_rule_pub.rulv_rec_type;

   SUBTYPE asset_tbl_type IS okl_am_calculate_quote_pvt.asset_tbl_type;

   SUBTYPE taiv_rec_type IS okl_trx_ar_invoices_pub.taiv_rec_type;

   SUBTYPE qpyv_tbl_type IS okl_quote_parties_pub.qpyv_tbl_type;

   --akrangan added for debug logging begin
   g_module_name                VARCHAR2 (255)
                                := 'okl.am.plsql.okl_am_repurchase_asset_pvt';
   g_level_procedure   CONSTANT NUMBER         := fnd_log.level_procedure;
   g_level_exception   CONSTANT NUMBER         := fnd_log.level_exception;
   g_level_statement   CONSTANT NUMBER         := fnd_log.level_statement;

   --akrangan added for debug logging end

   -- Start of comments
   --
   -- Procedure Name  : get_db_values
   -- Description     : get the stored database fields for the quote
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   PROCEDURE get_db_values (
      p_qte_id                IN              NUMBER,
      x_accepted_yn           OUT NOCOPY      VARCHAR2,
      x_quote_number          OUT NOCOPY      NUMBER,
      x_date_effective_from   OUT NOCOPY      DATE,
      x_date_effective_to     OUT NOCOPY      DATE,
      x_khr_id                OUT NOCOPY      NUMBER,
      x_qtp_code              OUT NOCOPY      VARCHAR2,
      x_return_status         OUT NOCOPY      VARCHAR2
   ) AS
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                          := g_module_name || 'get_db_values';
      is_debug_exception_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);

      -- akrangan added for debug feature end
        -- Select existing db values.
      CURSOR l_qtev_csr (p_id IN NUMBER) IS
         SELECT accepted_yn,
                quote_number,
                date_effective_from,
                date_effective_to,
                khr_id,
                qtp_code
           FROM okl_trx_quotes_v qtev
          WHERE qtev.ID = p_id;
   BEGIN
      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_qte_id =' || p_qte_id
                                 );
      END IF;

      x_return_status := okc_api.g_ret_sts_success;

      -- Select existing db values.
      OPEN l_qtev_csr (p_qte_id);

      FETCH l_qtev_csr
       INTO x_accepted_yn,
            x_quote_number,
            x_date_effective_from,
            x_date_effective_to,
            x_khr_id,
            x_qtp_code;

      -- Invalid Value for the column COL_NAME
      IF (l_qtev_csr%NOTFOUND) THEN
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_invalid_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'qte_id'
                             );
         x_return_status := okc_api.g_ret_sts_error;
      END IF;

      CLOSE l_qtev_csr;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'x_return_status =' || x_return_status
                                 );
      END IF;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_qtev_csr%ISOPEN) THEN
            CLOSE l_qtev_csr;
         END IF;

         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         x_return_status := okc_api.g_ret_sts_unexp_error;
   END get_db_values;

   -- Start of comments
   --
   -- Procedure Name  : get_sysdate
   -- Description     : get the sysdate
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   PROCEDURE get_sysdate (x_sysdate OUT NOCOPY DATE) AS
      -- get the sysdate
      CURSOR l_db_date_csr IS
         SELECT SYSDATE
           FROM DUAL;
   BEGIN
      -- get the sysdate
      OPEN l_db_date_csr;

      FETCH l_db_date_csr
       INTO x_sysdate;

      CLOSE l_db_date_csr;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_db_date_csr%ISOPEN) THEN
            CLOSE l_db_date_csr;
         END IF;

         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END get_sysdate;

   -- Start of comments
   --
   -- Procedure Name  : quote_effectivity
   -- Description     : gets the rule to determine the quote effective dates
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   PROCEDURE quote_effectivity (
      p_contract_id          IN              NUMBER,
      x_quote_eff_days       OUT NOCOPY      NUMBER,
      x_quote_eff_max_days   OUT NOCOPY      NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2
   ) IS
      l_return_status              VARCHAR2 (1)   := okc_api.g_ret_sts_error;
      l_rule_found                 BOOLEAN        := FALSE;
      l_rulv_rec                   rulv_rec_type;
      l_rule_code         CONSTANT VARCHAR2 (30)  := 'AMQTEF';
      l_rule_group_code   CONSTANT VARCHAR2 (30)  := 'AMTQPR';
      -- akrangan added for debug feature start
      l_module_name                VARCHAR2 (500)
                                      := g_module_name || 'quote_effectivity';
      is_debug_exception_on        BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on        BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on        BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_contract_id       =' || p_contract_id
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'before okl_am_util_pvt.get_rule_record'
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_rgd_code   =' || l_rule_group_code
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_rdf_code   =' || l_rule_code
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_chr_id     =' || p_contract_id
                                 );
      END IF;

      okl_am_util_pvt.get_rule_record (p_rgd_code           => l_rule_group_code,
                                       p_rdf_code           => l_rule_code,
                                       p_chr_id             => p_contract_id,
                                       p_cle_id             => NULL,
                                       x_rulv_rec           => l_rulv_rec,
                                       x_return_status      => l_return_status,
                                       p_message_yn         => TRUE
                                      );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'after okl_am_util_pvt.get_rule_record'
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status   =' || l_return_status
                                 );
      END IF;

      IF (l_return_status = okc_api.g_ret_sts_success) THEN
         x_quote_eff_days := l_rulv_rec.rule_information1;
         x_quote_eff_max_days := l_rulv_rec.rule_information2;
         l_return_status := okc_api.g_ret_sts_success;
      END IF;

      x_return_status := l_return_status;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         x_return_status := okc_api.g_ret_sts_unexp_error;
   END quote_effectivity;

   -- Start of comments
   --
   -- Procedure Name  : quote_type_check
   -- Description     : checks the quote type
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   PROCEDURE quote_type_check (
      p_qtp_code        IN              VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_return_status         VARCHAR2 (1)   := okc_api.g_ret_sts_error;
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                       := g_module_name || 'quote_type_check';
      is_debug_exception_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF ((p_qtp_code IS NOT NULL) AND (p_qtp_code = 'REP_STANDARD')) THEN
         l_return_status := okc_api.g_ret_sts_success;
      END IF;

      x_return_status := l_return_status;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         x_return_status := okc_api.g_ret_sts_unexp_error;
   END quote_type_check;

   -- Start of comments
   --
   -- Procedure Name  : set_quote_defaults
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   PROCEDURE set_quote_defaults (
      px_qtev_rec       IN OUT NOCOPY   qtev_rec_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_quote_eff_days        NUMBER;
      l_quote_eff_max_days    NUMBER;
      l_db_date               DATE;
      l_quote_status          VARCHAR2 (200) := 'DRAFTED';
      l_quote_reason          VARCHAR2 (200) := 'EOT';
      l_return_status         VARCHAR2 (1)   := okc_api.g_ret_sts_success;
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                     := g_module_name || 'set_quote_defaults';
      is_debug_exception_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'px_qtev_rec.id : ' || px_qtev_rec.ID
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.qrs_code : '
                                  || px_qtev_rec.qrs_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.qst_code : '
                                  || px_qtev_rec.qst_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.consolidated_qte_id : '
                                  || px_qtev_rec.consolidated_qte_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'px_qtev_rec.khr_id : '
                                  || px_qtev_rec.khr_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'px_qtev_rec.art_id : '
                                  || px_qtev_rec.art_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.qtp_code : '
                                  || px_qtev_rec.qtp_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.trn_code : '
                                  || px_qtev_rec.trn_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'px_qtev_rec.pdt_id : '
                                  || px_qtev_rec.pdt_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.date_effective_from : '
                                  || px_qtev_rec.date_effective_from
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.quote_number : '
                                  || px_qtev_rec.quote_number
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.early_termination_yn : '
                                  || px_qtev_rec.early_termination_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.partial_yn : '
                                  || px_qtev_rec.partial_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.preproceeds_yn : '
                                  || px_qtev_rec.preproceeds_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.summary_format_yn : '
                                  || px_qtev_rec.summary_format_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.consolidated_yn : '
                                  || px_qtev_rec.consolidated_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.date_requested : '
                                  || px_qtev_rec.date_requested
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.date_proposal : '
                                  || px_qtev_rec.date_proposal
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.date_effective_to : '
                                  || px_qtev_rec.date_effective_to
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.date_accepted : '
                                  || px_qtev_rec.date_accepted
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.payment_received_yn : '
                                  || px_qtev_rec.payment_received_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.requested_by : '
                                  || px_qtev_rec.requested_by
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.approved_yn : '
                                  || px_qtev_rec.approved_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.accepted_yn : '
                                  || px_qtev_rec.accepted_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'px_qtev_rec.org_id : '
                                  || px_qtev_rec.org_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.purchase_amount : '
                                  || px_qtev_rec.purchase_amount
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.purchase_formula : '
                                  || px_qtev_rec.purchase_formula
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.asset_value : '
                                  || px_qtev_rec.asset_value
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.residual_value : '
                                  || px_qtev_rec.residual_value
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.unbilled_receivables : '
                                  || px_qtev_rec.unbilled_receivables
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.gain_loss : '
                                  || px_qtev_rec.gain_loss
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.PERDIEM_AMOUNT : '
                                  || px_qtev_rec.perdiem_amount
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.currency_code : '
                                  || px_qtev_rec.currency_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.currency_conversion_code : '
                                  || px_qtev_rec.currency_conversion_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.legal_entity_id : '
                                  || px_qtev_rec.legal_entity_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'px_qtev_rec.repo_quote_indicator_yn : '
                                  || px_qtev_rec.repo_quote_indicator_yn
                                 );
      END IF;

      IF (   (px_qtev_rec.date_effective_from IS NULL)
          OR (px_qtev_rec.date_effective_from = okc_api.g_miss_date)
         ) THEN
         -- get the sysdate
         get_sysdate (l_db_date);
         px_qtev_rec.date_effective_from := l_db_date;
      END IF;

      IF (   (px_qtev_rec.date_effective_to IS NULL)
          OR (px_qtev_rec.date_effective_to = okc_api.g_miss_date)
         ) THEN
         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'Before quote_effectivity'
                                    );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                        'In param, p_contract_id: '
                                     || px_qtev_rec.khr_id
                                    );
         END IF;

         -- set the date eff to using rules
         quote_effectivity (p_contract_id             => px_qtev_rec.khr_id,
                            x_quote_eff_days          => l_quote_eff_days,
                            x_quote_eff_max_days      => l_quote_eff_max_days,
                            x_return_status           => l_return_status
                           );

         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'After quote_effectivity '
                                    );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'l_return_status: ' || l_return_status
                                    );
         END IF;

         IF (l_return_status = okc_api.g_ret_sts_success) THEN
            px_qtev_rec.date_effective_to :=
                           px_qtev_rec.date_effective_from + l_quote_eff_days;
         ELSE
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      IF (   (px_qtev_rec.qst_code IS NULL)
          OR (px_qtev_rec.qst_code = okc_api.g_miss_char)
         ) THEN
         px_qtev_rec.qst_code := l_quote_status;
      END IF;

      IF (   (px_qtev_rec.qrs_code IS NULL)
          OR (px_qtev_rec.qrs_code = okc_api.g_miss_char)
         ) THEN
         px_qtev_rec.qrs_code := l_quote_reason;
      END IF;

      -- Always NO during quote creation
      px_qtev_rec.accepted_yn := g_no;
      px_qtev_rec.approved_yn := g_no;
      x_return_status := l_return_status;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation THEN
         x_return_status := l_return_status;
      WHEN OTHERS THEN
         x_return_status := l_return_status;
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END set_quote_defaults;

   -- Start of comments
   --
   -- Procedure Name  : validate_quote
   -- Description     : checks the validity of the quote
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- History         : SECHAWLA 22-JAN-03 Bug # 2762419 : Modified the logic to check for the terminated/expired
   --                   asset line instead of a terminated/expired contract
   -- End of comments
   PROCEDURE validate_quote (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okl_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_qtev_rec        IN OUT NOCOPY   qtev_rec_type,
      p_tqlv_tbl        IN              tqlv_tbl_type,
      p_call_flag       IN              VARCHAR2
   ) IS
      -- select the contract id for the contract line id
      CURSOR l_clev_csr (p_kle_id NUMBER) IS
         SELECT chr_id
           FROM okc_k_lines_b
          WHERE ID = p_kle_id;

      -- see if any quotes already exist for this asset return id
      CURSOR l_qtev_csr (p_art_id NUMBER) IS
         SELECT quote_number
           FROM okl_trx_quotes_b
          WHERE art_id = p_art_id;

      -- select the asset return id to see if valid

      -- SECHAWLA 22-JAN-03 Bug # 2762419 : Added asset_number in the SELECT clause. Modified the FROM clause to use
    -- okl_am_asset_returns_uv instead of OKL_ASSET_RETURNS_B
--start changed by abhsaxen for Bug#6174484
      CURSOR l_artv_csr (p_art_id NUMBER) IS
         SELECT oar.ID ID,
                kle.NAME asset_number,
                oar.repurchase_agmt_yn repurchase_agmt_yn,
                oar.legal_entity_id legal_entity_id
           FROM okl_asset_returns_all_b oar, okl_k_lines_full_v kle
          WHERE oar.ID = p_art_id AND oar.kle_id = kle.ID;

--end changed by abhsaxen for Bug#6174484

      -- Select contract number for contract id
      CURSOR l_chr_csr (p_khr_id IN NUMBER) IS
         SELECT k.contract_number
           FROM okl_k_headers_full_v k
          WHERE k.ID = p_khr_id;

      -- Select the accepted_yn flag
      CURSOR l_acpt_csr (p_qte_id IN NUMBER) IS
         SELECT accepted_yn
           FROM okl_trx_quotes_b
          WHERE ID = p_qte_id;

      -- SECHAWLA 22-JAN-03 Bug # 2762419 : Added this cursor to check the status of the asset line
      CURSOR l_okclines_csr (p_kle_id IN NUMBER) IS
         SELECT sts_code
           FROM okc_k_lines_b
          WHERE ID = p_kle_id;

      l_contract_number       VARCHAR2 (120);
      l_contract_mismatch     BOOLEAN                                 := FALSE;
      l_chr_id                NUMBER                                      := 1;
      l_art_id                NUMBER                                      := 1;
      i                       NUMBER                                      := 0;
      l_quote_number          NUMBER                                      := 1;
      l_repurchase_agmt_yn    VARCHAR2 (3)                              := 'N';
      l_missing_lines         BOOLEAN                                 := FALSE;
      lx_contract_status      VARCHAR2 (200);
      l_control_flag_create   VARCHAR2 (200)           := 'REPUR_QUOTE_CREATE';
      l_control_flag_update   VARCHAR2 (200)           := 'REPUR_QUOTE_UPDATE';
      l_taiv_rec              taiv_rec_type;
      db_accepted_yn          VARCHAR2 (1);
      -- SECHAWLA 22-JAN-03 Bug # 2762419 : New declarations
      l_sts_code              okc_k_lines_b.sts_code%TYPE;
      l_asset_number          okl_am_asset_returns_uv.asset_number%TYPE;
      -- RRAVIKIR Legal Entity Changes
      l_legal_entity_id       NUMBER;
       -- Legal Entity Changes End
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                          := g_module_name || 'validate_quote';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_api_version :' || p_api_version
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_init_msg_list :' || p_init_msg_list
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.id : ' || p_qtev_rec.ID
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.qrs_code : '
                                  || p_qtev_rec.qrs_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.qst_code : '
                                  || p_qtev_rec.qst_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.consolidated_qte_id : '
                                  || p_qtev_rec.consolidated_qte_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.khr_id : ' || p_qtev_rec.khr_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.art_id : ' || p_qtev_rec.art_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.qtp_code : '
                                  || p_qtev_rec.qtp_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.trn_code : '
                                  || p_qtev_rec.trn_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.pdt_id : ' || p_qtev_rec.pdt_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_effective_from : '
                                  || p_qtev_rec.date_effective_from
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.quote_number : '
                                  || p_qtev_rec.quote_number
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.early_termination_yn : '
                                  || p_qtev_rec.early_termination_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.partial_yn : '
                                  || p_qtev_rec.partial_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.preproceeds_yn : '
                                  || p_qtev_rec.preproceeds_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.summary_format_yn : '
                                  || p_qtev_rec.summary_format_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.consolidated_yn : '
                                  || p_qtev_rec.consolidated_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_requested : '
                                  || p_qtev_rec.date_requested
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_proposal : '
                                  || p_qtev_rec.date_proposal
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_effective_to : '
                                  || p_qtev_rec.date_effective_to
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_accepted : '
                                  || p_qtev_rec.date_accepted
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.payment_received_yn : '
                                  || p_qtev_rec.payment_received_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.requested_by : '
                                  || p_qtev_rec.requested_by
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.approved_yn : '
                                  || p_qtev_rec.approved_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.accepted_yn : '
                                  || p_qtev_rec.accepted_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.org_id : ' || p_qtev_rec.org_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.purchase_amount : '
                                  || p_qtev_rec.purchase_amount
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.purchase_formula : '
                                  || p_qtev_rec.purchase_formula
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.asset_value : '
                                  || p_qtev_rec.asset_value
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.residual_value : '
                                  || p_qtev_rec.residual_value
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.unbilled_receivables : '
                                  || p_qtev_rec.unbilled_receivables
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.gain_loss : '
                                  || p_qtev_rec.gain_loss
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.PERDIEM_AMOUNT : '
                                  || p_qtev_rec.perdiem_amount
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.currency_code : '
                                  || p_qtev_rec.currency_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.currency_conversion_code : '
                                  || p_qtev_rec.currency_conversion_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.legal_entity_id : '
                                  || p_qtev_rec.legal_entity_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.repo_quote_indicator_yn : '
                                  || p_qtev_rec.repo_quote_indicator_yn
                                 );
      END IF;

      x_return_status := okc_api.g_ret_sts_success;

      -- SECHAWLA 22-JAN-03 Bug # 2762419 :Moved the quote header level validations to the beginning
      IF p_call_flag = 'UPDATE' THEN
         OPEN l_acpt_csr (p_qtev_rec.ID);

         FETCH l_acpt_csr
          INTO db_accepted_yn;

         -- SECHAWLA 22-JAN-03 Bug # 2762419 : Added the following exception handling code
         IF l_acpt_csr%NOTFOUND THEN
            okc_api.set_message (p_app_name          => 'OKC',
                                 p_msg_name          => g_invalid_value,
                                 p_token1            => g_col_name_token,
                                 p_token1_value      => 'qte_id'
                                );
            RAISE g_exception_halt_validation;
         END IF;

         -- SECHAWLA 22-JAN-03 Bug # 2762419 : end new code
         CLOSE l_acpt_csr;
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'before quote_type_check '
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_qtp_code: ' || p_qtev_rec.qtp_code
                                 );
      END IF;

      -- check if quote type is valid
      quote_type_check (p_qtp_code           => p_qtev_rec.qtp_code,
                        x_return_status      => x_return_status
                       );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'After quote_type_check '
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'x_return_status: ' || x_return_status
                                 );
      END IF;

      IF x_return_status = okc_api.g_ret_sts_error THEN
         --Please select a valid Quote Type.
         okc_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_AM_QTP_CODE_INVALID'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      -- check asset return id is populated and valid
      IF (    (p_qtev_rec.art_id IS NOT NULL)
          AND (p_qtev_rec.art_id <> okc_api.g_miss_num)
         ) THEN
         -- select the asset return id to see if valid
         OPEN l_artv_csr (p_qtev_rec.art_id);

         FETCH l_artv_csr
          INTO l_art_id,
               l_asset_number,
               l_repurchase_agmt_yn,
               l_legal_entity_id;

         CLOSE l_artv_csr;
      END IF;

      IF (l_art_id = 1) THEN
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_invalid_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'art_id'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      -- RRAVIKIR Legal Entity Changes
      IF (l_legal_entity_id IS NULL OR l_legal_entity_id = okc_api.g_miss_num
         ) THEN
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_required_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'legal_entity_id'
                             );
         RAISE okc_api.g_exception_error;
      ELSE
         p_qtev_rec.legal_entity_id := l_legal_entity_id;
      END IF;

      -- Legal Entity Changes End

      -- see if there is a repurchase agreement
      IF (l_repurchase_agmt_yn IS NULL) OR (l_repurchase_agmt_yn = 'N') THEN
         -- Get the contract number
         OPEN l_chr_csr (p_qtev_rec.khr_id);

         FETCH l_chr_csr
          INTO l_contract_number;

         CLOSE l_chr_csr;

         -- No repurchase agreement exists for contract CONTRACT_NUMBER.
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_NO_REPURCHASE_AGMT',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => l_contract_number
                             );
         RAISE g_exception_halt_validation;
      END IF;

      -- SECHAWLA 22-JAN-03 Bug # 2762419 : end of moved validations

      -- Check that there are contract lines passed as parameters.
      IF (p_tqlv_tbl.COUNT > 0) THEN
         i := p_tqlv_tbl.FIRST;

         LOOP
            IF (   (p_tqlv_tbl (i).kle_id IS NULL)
                OR (p_tqlv_tbl (i).kle_id = okc_api.g_miss_num)
               ) THEN
               l_missing_lines := TRUE;
               --SECHAWLA 22-JAN-03 Bug # 2762419 : Added the EXIT statement
               EXIT;
            END IF;

            EXIT WHEN (i = p_tqlv_tbl.LAST);
            i := p_tqlv_tbl.NEXT (i);
         END LOOP;
      ELSE
         l_missing_lines := TRUE;
      END IF;

      IF (l_missing_lines) THEN
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_required_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'kle_id'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      -- validate that the contract line ids are valid and belong to the same contract
      IF (    (p_tqlv_tbl.COUNT > 0)
          AND (    (p_qtev_rec.khr_id IS NOT NULL)
               AND (p_qtev_rec.khr_id <> okc_api.g_miss_num)
              )
         ) THEN
         i := p_tqlv_tbl.FIRST;
         l_contract_mismatch := FALSE;

         LOOP
            l_chr_id := 1;

            -- select the contract id for the contract line id
            OPEN l_clev_csr (p_tqlv_tbl (i).kle_id);

            FETCH l_clev_csr
             INTO l_chr_id;

            CLOSE l_clev_csr;

            IF (l_chr_id <> p_qtev_rec.khr_id) OR (l_chr_id = 1) THEN
               l_contract_mismatch := TRUE;
            END IF;

            EXIT WHEN (i = p_tqlv_tbl.LAST);
            i := p_tqlv_tbl.NEXT (i);
         END LOOP;

         IF (l_contract_mismatch) THEN
            okc_api.set_message (p_app_name          => 'OKC',
                                 p_msg_name          => g_invalid_value,
                                 p_token1            => g_col_name_token,
                                 p_token1_value      => 'kle_id'
                                );
            RAISE g_exception_halt_validation;
         END IF;
      ELSE
-- Either no lines selected (which is not needed here since done earlier) or khr_id is invalid
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_required_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'khr_id'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      -- SECHAWLA 22-JAN-03 Bug # 2762419 : Check if the asset line is terminated or expired
      IF    (p_call_flag = 'CREATE')
         OR (p_call_flag = 'UPDATE' AND db_accepted_yn <> 'Y') THEN
         i := p_tqlv_tbl.FIRST;

         LOOP
            --Check if asset line is terminated or expired
            OPEN l_okclines_csr (p_tqlv_tbl (i).kle_id);

            FETCH l_okclines_csr
             INTO l_sts_code;

            IF l_okclines_csr%NOTFOUND THEN
               x_return_status := okl_api.g_ret_sts_error;
               -- Kle ID is invalid
               okl_api.set_message (p_app_name          => 'OKC',
                                    p_msg_name          => g_invalid_value,
                                    p_token1            => g_col_name_token,
                                    p_token1_value      => 'KLE_ID'
                                   );
               RAISE g_exception_halt_validation;
            END IF;

            CLOSE l_okclines_csr;

            IF l_sts_code NOT IN ('TERMINATED', 'EXPIRED') THEN
               x_return_status := okl_api.g_ret_sts_error;
               -- Asset ASSET_NUMBER is still STATUS. Asset should be terminated or expired.
               okl_api.set_message
                                (p_app_name          => 'OKL',
                                 p_msg_name          => 'OKL_AM_ASSET_NOT_TERMINATED',
                                 p_token1            => 'ASSET_NUMBER',
                                 p_token1_value      => l_asset_number,
                                 p_token2            => 'STATUS',
                                 p_token2_value      => l_sts_code
                                );
               RAISE g_exception_halt_validation;
            END IF;

            EXIT WHEN (i = p_tqlv_tbl.LAST);
            i := p_tqlv_tbl.NEXT (i);
         END LOOP;
      END IF;

      -- SECHAWLA 22-JAN-03 Bug # 2762419 : end new code

      /*
    -- check if contract active
    IF check_contract_active_yn ( p_qtev_rec,l_contract_number) = TRUE THEN
      -- Contract CONTRACT_NUMBER is still Active. Unable to generate the quote
      -- until the contract has been terminated.
      OKC_API.SET_MESSAGE (
          p_app_name => G_APP_NAME
         ,p_msg_name => 'OKL_AM_CONTRACT_STILL_ACTIVE'
         ,p_token1   => 'CONTRACT_NUMBER'
         ,p_token1_value   => l_contract_number);

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/

      -- see if vendor billing information exists
      l_taiv_rec.khr_id := p_qtev_rec.khr_id;
      okl_am_invoices_pvt.get_vendor_billing_info
                                           (px_taiv_rec          => l_taiv_rec,
                                            x_return_status      => x_return_status
                                           );

      -- If error then above api will set the message, so exit now
      IF x_return_status <> okl_api.g_ret_sts_success THEN
         RAISE g_exception_halt_validation;
      END IF;

      -- see if any quotes already exist for this asset return id
      OPEN l_qtev_csr (p_qtev_rec.art_id);

      FETCH l_qtev_csr
       INTO l_quote_number;

      CLOSE l_qtev_csr;

      IF (l_quote_number <> 1) THEN
         -- Repurchase quote (QUOTE_NUMBER) already exists for this Asset.
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_REP_QUOTE_ALREADY_EXIST',
                              p_token1            => 'QUOTE_NUMBER',
                              p_token1_value      => TO_CHAR (l_quote_number)
                             );
         RAISE g_exception_halt_validation;
      END IF;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation THEN
         IF (l_clev_csr%ISOPEN) THEN
            CLOSE l_clev_csr;
         END IF;

         IF (l_artv_csr%ISOPEN) THEN
            CLOSE l_artv_csr;
         END IF;

         IF (l_qtev_csr%ISOPEN) THEN
            CLOSE l_qtev_csr;
         END IF;

         IF (l_chr_csr%ISOPEN) THEN
            CLOSE l_chr_csr;
         END IF;

         IF (l_acpt_csr%ISOPEN) THEN
            CLOSE l_acpt_csr;
         END IF;

         -- SECHAWLA 22-JAN-03 Bug # 2762419 : Close the new cursor
         IF l_okclines_csr%ISOPEN THEN
            CLOSE l_okclines_csr;
         END IF;

         x_return_status := okc_api.g_ret_sts_error;
      WHEN OTHERS THEN
         IF (l_clev_csr%ISOPEN) THEN
            CLOSE l_clev_csr;
         END IF;

         IF (l_artv_csr%ISOPEN) THEN
            CLOSE l_artv_csr;
         END IF;

         IF (l_qtev_csr%ISOPEN) THEN
            CLOSE l_qtev_csr;
         END IF;

         IF (l_chr_csr%ISOPEN) THEN
            CLOSE l_chr_csr;
         END IF;

         IF (l_acpt_csr%ISOPEN) THEN
            CLOSE l_acpt_csr;
         END IF;

         -- SECHAWLA 22-JAN-03 Bug # 2762419 : Close the new cursor
         IF l_okclines_csr%ISOPEN THEN
            CLOSE l_okclines_csr;
         END IF;

         okc_api.set_message (p_app_name          => okc_api.g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         x_return_status := okc_api.g_ret_sts_unexp_error;
   END validate_quote;

   -- Start of comments
   --
   -- Procedure Name  : create_repurchase_quote
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   PROCEDURE create_repurchase_quote (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_qtev_rec        IN              qtev_rec_type,
      p_tqlv_tbl        IN              tqlv_tbl_type,
      x_qtev_rec        OUT NOCOPY      qtev_rec_type,
      x_tqlv_tbl        OUT NOCOPY      tqlv_tbl_type
   ) AS
      i                        NUMBER         := 0;
      l_contract_active_yn     VARCHAR2 (200);
      l_contract_term_yn       VARCHAR2 (200);
      l_partial_allowed_yn     VARCHAR2 (200);
      lp_qtev_rec              qtev_rec_type  := p_qtev_rec;
      lx_qtev_rec              qtev_rec_type;
      lp_tqlv_tbl              tqlv_tbl_type  := p_tqlv_tbl;
      lx_tqlv_tbl              tqlv_tbl_type  := p_tqlv_tbl;
      l_asset_tbl              asset_tbl_type;
      lx_qpyv_tbl              qpyv_tbl_type;
      l_quote_number           NUMBER;
      l_api_version   CONSTANT NUMBER         := 1;
      l_api_name      CONSTANT VARCHAR2 (30)  := 'create_repurchase_quote';
      l_return_status          VARCHAR2 (1)   := okc_api.g_ret_sts_success;
      -- akrangan added for debug feature start
      l_module_name            VARCHAR2 (500)
                                := g_module_name || 'create_repurchase_quote';
      is_debug_exception_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_api_version :' || p_api_version
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_init_msg_list :' || p_init_msg_list
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.id : ' || p_qtev_rec.ID
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.qrs_code : '
                                  || p_qtev_rec.qrs_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.qst_code : '
                                  || p_qtev_rec.qst_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.consolidated_qte_id : '
                                  || p_qtev_rec.consolidated_qte_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.khr_id : ' || p_qtev_rec.khr_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.art_id : ' || p_qtev_rec.art_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.qtp_code : '
                                  || p_qtev_rec.qtp_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.trn_code : '
                                  || p_qtev_rec.trn_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.pdt_id : ' || p_qtev_rec.pdt_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_effective_from : '
                                  || p_qtev_rec.date_effective_from
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.quote_number : '
                                  || p_qtev_rec.quote_number
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.early_termination_yn : '
                                  || p_qtev_rec.early_termination_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.partial_yn : '
                                  || p_qtev_rec.partial_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.preproceeds_yn : '
                                  || p_qtev_rec.preproceeds_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.summary_format_yn : '
                                  || p_qtev_rec.summary_format_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.consolidated_yn : '
                                  || p_qtev_rec.consolidated_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_requested : '
                                  || p_qtev_rec.date_requested
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_proposal : '
                                  || p_qtev_rec.date_proposal
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_effective_to : '
                                  || p_qtev_rec.date_effective_to
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_accepted : '
                                  || p_qtev_rec.date_accepted
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.payment_received_yn : '
                                  || p_qtev_rec.payment_received_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.requested_by : '
                                  || p_qtev_rec.requested_by
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.approved_yn : '
                                  || p_qtev_rec.approved_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.accepted_yn : '
                                  || p_qtev_rec.accepted_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.org_id : ' || p_qtev_rec.org_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.purchase_amount : '
                                  || p_qtev_rec.purchase_amount
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.purchase_formula : '
                                  || p_qtev_rec.purchase_formula
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.asset_value : '
                                  || p_qtev_rec.asset_value
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.residual_value : '
                                  || p_qtev_rec.residual_value
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.unbilled_receivables : '
                                  || p_qtev_rec.unbilled_receivables
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.gain_loss : '
                                  || p_qtev_rec.gain_loss
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.PERDIEM_AMOUNT : '
                                  || p_qtev_rec.perdiem_amount
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.currency_code : '
                                  || p_qtev_rec.currency_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.currency_conversion_code : '
                                  || p_qtev_rec.currency_conversion_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.legal_entity_id : '
                                  || p_qtev_rec.legal_entity_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.repo_quote_indicator_yn : '
                                  || p_qtev_rec.repo_quote_indicator_yn
                                 );
      END IF;

      --Check API version, initialize message list and create savepoint.
      l_return_status :=
         okl_api.start_activity (l_api_name,
                                 g_pkg_name,
                                 p_init_msg_list,
                                 l_api_version,
                                 p_api_version,
                                 '_PVT',
                                 x_return_status
                                );

      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'before validate_quote '
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      -- check if quote valid
      validate_quote
            (p_api_version        => p_api_version,
             p_init_msg_list      => p_init_msg_list,
             x_return_status      => l_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data,
             p_qtev_rec           => lp_qtev_rec,
                                       --lx_qtev_rec, --code added by akrangan
             p_tqlv_tbl           => lp_tqlv_tbl,
             p_call_flag          => 'CREATE'
            );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'after validate_quote '
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      IF (l_return_status = okc_api.g_ret_sts_unexp_error) THEN
         RAISE okc_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okc_api.g_ret_sts_error) THEN
         RAISE okc_api.g_exception_error;
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'before set_quote_defaults '
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      -- set quote default values
      set_quote_defaults
           (px_qtev_rec          => lp_qtev_rec,
                                       --lx_qtev_rec, --code added by akrangan
            x_return_status      => l_return_status);

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'after set_quote_defaults '
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      IF (l_return_status = okc_api.g_ret_sts_unexp_error) THEN
         RAISE okc_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okc_api.g_ret_sts_error) THEN
         RAISE okc_api.g_exception_error;
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                               'before OKL_TRX_QUOTES_PUB.insert_trx_quotes '
                              );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      -- call the pub tapi insert
      okl_trx_quotes_pub.insert_trx_quotes
            (p_api_version        => p_api_version,
             p_init_msg_list      => p_init_msg_list,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data,
             p_qtev_rec           => lp_qtev_rec,
                                       --lx_qtev_rec, --code added by akrangan
             x_qtev_rec           => lx_qtev_rec,
             x_return_status      => l_return_status
            );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                'after OKL_TRX_QUOTES_PUB.insert_trx_quotes '
                               );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      IF (l_return_status = okc_api.g_ret_sts_unexp_error) THEN
         RAISE okc_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okc_api.g_ret_sts_error) THEN
         RAISE okc_api.g_exception_error;
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                    (g_level_statement,
                     l_module_name,
                     'before OKL_AM_PARTIES_PVT.create_partner_as_recipient '
                    );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      -- Create quote parties
      okl_am_parties_pvt.create_partner_as_recipient
                                           (p_qtev_rec           => lx_qtev_rec,
                                            x_qpyv_tbl           => lx_qpyv_tbl,
                                            x_return_status      => l_return_status
                                           );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'after OKL_AM_PARTIES_PVT.create_partner_as_recipient '
                     );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- set the asset table to be passed to the calculate quote api
      IF (lp_tqlv_tbl.COUNT > 0) THEN
         i := lp_tqlv_tbl.FIRST;

         LOOP
            l_asset_tbl (i).p_asset_id := lp_tqlv_tbl (i).kle_id;
            EXIT WHEN (i = lp_tqlv_tbl.LAST);
            i := lp_tqlv_tbl.NEXT (i);
         END LOOP;
      ELSE                                     -- No assets selected for quote
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_required_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'p_tqlv_tbl'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                               'before  OKL_AM_CALCULATE_QUOTE_PVT.generate '
                              );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      -- call quote calculation api (pass assets tbl)
      -- this will insert quote lines
      okl_am_calculate_quote_pvt.generate (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_qtev_rec           => lx_qtev_rec,
                                           p_asset_tbl          => l_asset_tbl,
                                           x_tqlv_tbl           => lx_tqlv_tbl,
                                           x_return_status      => l_return_status
                                          );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                'after  OKL_AM_CALCULATE_QUOTE_PVT.generate '
                               );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      IF (l_return_status = okc_api.g_ret_sts_unexp_error) THEN
         RAISE okc_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okc_api.g_ret_sts_error) THEN
         RAISE okc_api.g_exception_error;
      END IF;

      -- set the return status and out variables
      x_return_status := l_return_status;
      x_qtev_rec := lx_qtev_rec;
      x_tqlv_tbl := lx_tqlv_tbl;
      -- end the transaction
      okc_api.end_activity (x_msg_count, x_msg_data);

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN okc_api.g_exception_error THEN
         x_return_status :=
            okc_api.handle_exceptions (l_api_name,
                                       g_pkg_name,
                                       'OKC_API.G_RET_STS_ERROR',
                                       x_msg_count,
                                       x_msg_data,
                                       '_PVT'
                                      );
      WHEN okc_api.g_exception_unexpected_error THEN
         x_return_status :=
            okc_api.handle_exceptions (l_api_name,
                                       g_pkg_name,
                                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                                       x_msg_count,
                                       x_msg_data,
                                       '_PVT'
                                      );
      WHEN OTHERS THEN
         x_return_status :=
            okc_api.handle_exceptions (l_api_name,
                                       g_pkg_name,
                                       'OTHERS',
                                       x_msg_count,
                                       x_msg_data,
                                       '_PVT'
                                      );
   END create_repurchase_quote;

   -- Start of comments
   --
   -- Procedure Name  : update_repurchase_quote
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- History         : rmunjulu Sales_Tax_Enhancement Call the OKL Tax engine to calculate tax
   --                   Also modified to not pass tax line for updates
   -- End of comments
   PROCEDURE update_repurchase_quote (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_qtev_rec        IN              qtev_rec_type,
      p_tqlv_tbl        IN              tqlv_tbl_type,
      x_qtev_rec        OUT NOCOPY      qtev_rec_type,
      x_tqlv_tbl        OUT NOCOPY      tqlv_tbl_type
   ) AS
      l_db_date                  DATE;
      i                          NUMBER          := 0;
      l_db_khr_id                NUMBER;
      l_db_accepted_yn           VARCHAR2 (3);
      l_db_date_effective_from   DATE;
      l_db_date_effective_to     DATE;
      l_db_qtp_code              VARCHAR2 (200);
      lp_qtev_rec                qtev_rec_type   := p_qtev_rec;
      lx_qtev_rec                qtev_rec_type   := p_qtev_rec;
      lp_tqlv_tbl                tqlv_tbl_type   := p_tqlv_tbl;
      lx_tqlv_tbl                tqlv_tbl_type   := p_tqlv_tbl;
      l_quote_number             NUMBER;
      l_quote_eff_days           NUMBER;
      l_quote_eff_max_days       NUMBER;
      l_max_quote_eff_to_dt      DATE;
      l_api_version     CONSTANT NUMBER          := 1;
      l_api_name        CONSTANT VARCHAR2 (30)   := 'update_repurchase_quote';
      l_return_status            VARCHAR2 (1)    := okc_api.g_ret_sts_success;
      l_event_name               VARCHAR2 (200)
                                      := 'oracle.apps.okl.am.repurchasequote';
      l_event_desc               VARCHAR2 (2000);
      l_date_eff_from            DATE;
      -- rmunjulu Sales_Tax_Enhancement
      llp_tqlv_tbl               tqlv_tbl_type;
      j                          NUMBER;
      -- akrangan added for debug feature start
      l_module_name              VARCHAR2 (500)
                                := g_module_name || 'update_repurchase_quote';
      is_debug_exception_on      BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on      BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on      BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_api_version :' || p_api_version
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_init_msg_list :' || p_init_msg_list
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.id : ' || p_qtev_rec.ID
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.qrs_code : '
                                  || p_qtev_rec.qrs_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.qst_code : '
                                  || p_qtev_rec.qst_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.consolidated_qte_id : '
                                  || p_qtev_rec.consolidated_qte_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.khr_id : ' || p_qtev_rec.khr_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.art_id : ' || p_qtev_rec.art_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.qtp_code : '
                                  || p_qtev_rec.qtp_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.trn_code : '
                                  || p_qtev_rec.trn_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.pdt_id : ' || p_qtev_rec.pdt_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_effective_from : '
                                  || p_qtev_rec.date_effective_from
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.quote_number : '
                                  || p_qtev_rec.quote_number
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.early_termination_yn : '
                                  || p_qtev_rec.early_termination_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.partial_yn : '
                                  || p_qtev_rec.partial_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.preproceeds_yn : '
                                  || p_qtev_rec.preproceeds_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.summary_format_yn : '
                                  || p_qtev_rec.summary_format_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.consolidated_yn : '
                                  || p_qtev_rec.consolidated_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_requested : '
                                  || p_qtev_rec.date_requested
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_proposal : '
                                  || p_qtev_rec.date_proposal
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_effective_to : '
                                  || p_qtev_rec.date_effective_to
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.date_accepted : '
                                  || p_qtev_rec.date_accepted
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.payment_received_yn : '
                                  || p_qtev_rec.payment_received_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.requested_by : '
                                  || p_qtev_rec.requested_by
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.approved_yn : '
                                  || p_qtev_rec.approved_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.accepted_yn : '
                                  || p_qtev_rec.accepted_yn
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'p_qtev_rec.org_id : ' || p_qtev_rec.org_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.purchase_amount : '
                                  || p_qtev_rec.purchase_amount
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.purchase_formula : '
                                  || p_qtev_rec.purchase_formula
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.asset_value : '
                                  || p_qtev_rec.asset_value
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.residual_value : '
                                  || p_qtev_rec.residual_value
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.unbilled_receivables : '
                                  || p_qtev_rec.unbilled_receivables
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.gain_loss : '
                                  || p_qtev_rec.gain_loss
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.PERDIEM_AMOUNT : '
                                  || p_qtev_rec.perdiem_amount
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.currency_code : '
                                  || p_qtev_rec.currency_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.currency_conversion_code : '
                                  || p_qtev_rec.currency_conversion_code
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.legal_entity_id : '
                                  || p_qtev_rec.legal_entity_id
                                 );
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                     'p_qtev_rec.repo_quote_indicator_yn : '
                                  || p_qtev_rec.repo_quote_indicator_yn
                                 );
      END IF;

      --Check API version, initialize message list and create savepoint.
      l_return_status :=
         okl_api.start_activity (l_api_name,
                                 g_pkg_name,
                                 p_init_msg_list,
                                 l_api_version,
                                 p_api_version,
                                 '_PVT',
                                 x_return_status
                                );

      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- initialize return variables
      x_return_status := okc_api.g_ret_sts_success;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'before  get_db_values '
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      -- get the db values
      get_db_values (lp_qtev_rec.ID,
                     l_db_accepted_yn,
                     l_quote_number,
                     l_db_date_effective_from,
                     l_db_date_effective_to,
                     l_db_khr_id,
                     l_db_qtp_code,
                     l_return_status
                    );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'after  get_db_values '
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      IF (l_return_status = okc_api.g_ret_sts_unexp_error) THEN
         RAISE okc_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okc_api.g_ret_sts_error) THEN
         RAISE okc_api.g_exception_error;
      END IF;

      IF (    (lp_qtev_rec.khr_id IS NOT NULL)
          AND (p_qtev_rec.khr_id <> okc_api.g_miss_num)
          AND (l_db_khr_id <> p_qtev_rec.khr_id)
         ) THEN
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_invalid_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'kle_id'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      -- get the sysdate
      get_sysdate (l_db_date);

      -- IF qtp_code not null then check if valid
      IF     lp_qtev_rec.qtp_code IS NOT NULL
         AND lp_qtev_rec.qtp_code <> okl_api.g_miss_char
         AND lp_qtev_rec.qtp_code NOT LIKE 'REP_STANDARD' THEN
         -- Please select a valid Quote Type.
         okl_api.set_message (p_app_name      => okl_api.g_app_name,
                              p_msg_name      => 'OKL_AM_QTP_CODE_INVALID'
                             );
         RAISE g_exception_halt_validation;
      -- if qtp_code is null then get from db and check
      ELSIF     (   lp_qtev_rec.qtp_code IS NULL
                 OR lp_qtev_rec.qtp_code = okl_api.g_miss_char
                )
            AND l_db_qtp_code NOT LIKE 'REP_STANDARD' THEN
         -- Please select a valid Quote Type.
         okl_api.set_message (p_app_name      => okl_api.g_app_name,
                              p_msg_name      => 'OKL_AM_QTP_CODE_INVALID'
                             );
         RAISE g_exception_halt_validation;
      END IF;

      -- Check if date_effective_to is NULL
      IF    lp_qtev_rec.date_effective_to IS NULL
         OR lp_qtev_rec.date_effective_to = okl_api.g_miss_date THEN
         -- You must enter a value for PROMPT
         okl_api.set_message
            (p_app_name          => okl_api.g_app_name,
             p_msg_name          => 'OKL_AM_REQ_FIELD_ERR',
             p_token1            => 'PROMPT',
             p_token1_value      => okl_am_util_pvt.get_ak_attribute
                                                           ('OKL_EFFECTIVE_TO')
            );
         RAISE g_exception_halt_validation;
      END IF;

      -- Get the date_eff_from from database if not passed
      IF     (lp_qtev_rec.date_effective_from IS NOT NULL)
         AND (lp_qtev_rec.date_effective_from <> okl_api.g_miss_date) THEN
         l_date_eff_from := lp_qtev_rec.date_effective_from;
      ELSE
         l_date_eff_from := l_db_date_effective_from;
      END IF;

      -- Check date_eff_to > date_eff_from
      IF     (l_date_eff_from IS NOT NULL)
         AND (l_date_eff_from <> okl_api.g_miss_date)
         AND (lp_qtev_rec.date_effective_to IS NOT NULL)
         AND (lp_qtev_rec.date_effective_to <> okl_api.g_miss_date) THEN
         IF (TRUNC (lp_qtev_rec.date_effective_to) <= TRUNC (l_date_eff_from)
            ) THEN
            -- Message : Date Effective To DATE_EFFECTIVE_TO cannot be before
            -- Date Effective From DATE_EFFECTIVE_FROM.
            okl_api.set_message
                            (p_app_name          => 'OKL',
                             p_msg_name          => 'OKL_AM_DATE_EFF_FROM_LESS_TO',
                             p_token1            => 'DATE_EFFECTIVE_TO',
                             p_token1_value      => lp_qtev_rec.date_effective_to,
                             p_token2            => 'DATE_EFFECTIVE_FROM',
                             p_token2_value      => l_date_eff_from
                            );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      -- if date effective to changed then
      IF (    (lp_qtev_rec.date_effective_to IS NOT NULL)
          AND (lp_qtev_rec.date_effective_to <> okc_api.g_miss_date)
          AND (lp_qtev_rec.date_effective_to <> l_db_date_effective_to)
         ) THEN
         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'before  quote_effectivity '
                                    );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'l_return_status: ' || l_return_status
                                    );
         END IF;

         -- get the date eff to from rules
         quote_effectivity (p_contract_id             => l_db_khr_id,
                            x_quote_eff_days          => l_quote_eff_days,
                            x_quote_eff_max_days      => l_quote_eff_max_days,
                            x_return_status           => l_return_status
                           );

         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'after  quote_effectivity '
                                    );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'l_return_status: ' || l_return_status
                                    );
         END IF;

         IF (l_return_status = okc_api.g_ret_sts_unexp_error) THEN
            RAISE okc_api.g_exception_unexpected_error;
         ELSIF (l_return_status = okc_api.g_ret_sts_error) THEN
            RAISE okc_api.g_exception_error;
         END IF;

         l_max_quote_eff_to_dt :=
                               l_db_date_effective_from + l_quote_eff_max_days;

         -- if max quote eff to date is less than sysdate then error
         IF (TRUNC (l_max_quote_eff_to_dt) < TRUNC (l_db_date)) THEN
            --Quote QUOTE_NUMBER is already expired.
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_QUOTE_ALREADY_EXP',
                                 p_token1            => g_quote_number_token,
                                 p_token1_value      => l_quote_number
                                );
            RAISE g_exception_halt_validation;
         END IF;

         -- if date is less than sysdate then error
         IF (TRUNC (lp_qtev_rec.date_effective_to) < TRUNC (l_db_date)) THEN
            --Please enter an Effective To date that occurs after the current system date.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_DATE_EFF_TO_PAST'
                                );
            RAISE g_exception_halt_validation;
         END IF;

         -- if eff_to date > l_quote_eff_to_dt then err msg
         IF (TRUNC (lp_qtev_rec.date_effective_to) >
                                                 TRUNC (l_max_quote_eff_to_dt)
            ) THEN
            --Please enter Effective To date before DATE_EFF_TO_MAX.
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_DATE_EFF_TO_ERR',
                                 p_token1            => g_max_date_token,
                                 p_token1_value      => l_max_quote_eff_to_dt
                                );
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      -- Accepted YN Flag Validation
      IF (    (lp_qtev_rec.accepted_yn IS NOT NULL)
          AND (lp_qtev_rec.accepted_yn <> okc_api.g_miss_char)
         ) THEN
         -- if accepting now then check that quote is still effective
         IF (l_db_accepted_yn = g_no) AND (lp_qtev_rec.accepted_yn = g_yes) THEN
            -- If date_eff_to is not passed
            IF (   (lp_qtev_rec.date_effective_to IS NULL)
                OR (lp_qtev_rec.date_effective_to = okl_api.g_miss_date)
               ) THEN
               --Has quote expired
               IF TRUNC (l_db_date) > TRUNC (l_db_date_effective_to) THEN
                  --Quote QUOTE_NUMBER is already expired.
                  okl_api.set_message
                                   (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKL_AM_QUOTE_ALREADY_EXP',
                                    p_token1            => g_quote_number_token,
                                    p_token1_value      => l_quote_number
                                   );
                  RAISE g_exception_halt_validation;
               ELSE
                  -- Do Acceptance steps
                  NULL;
               END IF;
            END IF;
         -- if already accepted and trying to change then raise error
         ELSIF     (l_db_accepted_yn = g_yes)
               AND (lp_qtev_rec.accepted_yn = g_no) THEN
            --Quote QUOTE_NUMBER is already accepted.
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_QUOTE_ALREADY_ACCP',
                                 p_token1            => g_quote_number_token,
                                 p_token1_value      => l_quote_number
                                );
            RAISE g_exception_halt_validation;
         END IF;
      ELSIF (lp_qtev_rec.accepted_yn IS NULL) THEN
         lp_qtev_rec.accepted_yn := g_no;
      END IF;

      -- Set the qst_code to ACCEPTED if the quote is accepted now
      IF (lp_qtev_rec.accepted_yn = g_yes AND l_db_accepted_yn = g_no) THEN
         lp_qtev_rec.qst_code := 'ACCEPTED';
         lp_qtev_rec.date_accepted := l_db_date;
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                               'before  OKL_TRX_QUOTES_PUB.update_trx_quotes'
                              );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      -- update the quote
      okl_trx_quotes_pub.update_trx_quotes
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_qtev_rec           => lp_qtev_rec,
                                           x_qtev_rec           => lx_qtev_rec
                                          );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                'after  OKL_TRX_QUOTES_PUB.update_trx_quotes'
                               );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      IF (l_return_status = okc_api.g_ret_sts_unexp_error) THEN
         RAISE okc_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okc_api.g_ret_sts_error) THEN
         RAISE okc_api.g_exception_error;
      END IF;

      -- update lines if necessary
      IF (lp_tqlv_tbl.COUNT > 0) THEN
         -- rmunjulu Sales_Tax_Enhancement
         j := 1;

         -- rmunjulu Sales_Tax_Enhancement -- Do not take tax quote line for update as that does not have the ID
         FOR i IN lp_tqlv_tbl.FIRST .. lp_tqlv_tbl.LAST
         LOOP
            IF     (    lp_tqlv_tbl (i).ID IS NOT NULL
                    AND lp_tqlv_tbl (i).ID <> okl_api.g_miss_num
                   )
               AND lp_tqlv_tbl (i).qlt_code <> 'AMCTAX' THEN
               llp_tqlv_tbl (j) := lp_tqlv_tbl (i);
               j := j + 1;
            END IF;
         END LOOP;

         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'before OKL_TXL_QUOTE_LINES_PUB.update_txl_quote_lines'
                     );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'l_return_status: ' || l_return_status
                                    );
         END IF;

         -- update the quote lines
         okl_txl_quote_lines_pub.update_txl_quote_lines
                  (p_api_version        => p_api_version,
                   p_init_msg_list      => p_init_msg_list,
                   x_return_status      => l_return_status,
                   x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data,
                   p_tqlv_tbl           => llp_tqlv_tbl,
                                              --rmunjulu Sales_Tax_Enhancement
                   x_tqlv_tbl           => lx_tqlv_tbl
                  );

         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'after  OKL_TXL_QUOTE_LINES_PUB.update_txl_quote_lines'
                     );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'l_return_status: ' || l_return_status
                                    );
         END IF;

         IF (l_return_status = okc_api.g_ret_sts_unexp_error) THEN
            RAISE okc_api.g_exception_unexpected_error;
         ELSIF (l_return_status = okc_api.g_ret_sts_error) THEN
            RAISE okc_api.g_exception_error;
         END IF;
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                'after  OKL_TRX_QUOTES_PUB.update_trx_quotes'
                               );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      -- rmunjulu Sales_Tax_Enhancement
      -- Call the new OKL Tax engine to RECALCULATE tax for all quote lines
      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'before  OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax'
                     );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      okl_process_sales_tax_pub.calculate_sales_tax
                      (p_api_version          => l_api_version,
                       p_init_msg_list        => okl_api.g_false,
                       x_return_status        => l_return_status,
                       x_msg_count            => x_msg_count,
                       x_msg_data             => x_msg_data,
                       p_source_trx_id        => lp_qtev_rec.ID,
                                                         -- TRX_ID is QUOTE_ID
                       p_source_trx_name      => 'Estimated Billing',
                       p_source_table         => 'OKL_TRX_QUOTES_B'
                      );                   -- SOURCE_TABLE IS OKL_TRX_QUOTES_B

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
                      (g_level_statement,
                       l_module_name,
                       'after  OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax'
                      );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status: ' || l_return_status
                                 );
      END IF;

      IF (l_return_status <> okl_api.g_ret_sts_success) THEN
         -- Tax Processing failed.
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_AM_PROCESS_TAX_ERR'
                             );
      END IF;

      -- raise exception if error
      IF (l_return_status = okc_api.g_ret_sts_unexp_error) THEN
         RAISE okc_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okc_api.g_ret_sts_error) THEN
         RAISE okc_api.g_exception_error;
      END IF;

      -- raise repurchase quote workflow if the quote is accepted now
      IF (lp_qtev_rec.accepted_yn = g_yes AND l_db_accepted_yn = g_no) THEN
         -- Raise Repurchase Quote WorkFlow event
         okl_am_wf.raise_business_event (p_transaction_id      => lp_qtev_rec.ID,
                                         p_event_name          => l_event_name
                                        );
         -- Get the event name
         l_event_desc :=
            okl_am_util_pvt.get_wf_event_name
                                       (p_wf_process_type      => 'OKLAMRAC',
                                        p_wf_process_name      => 'REPUR_QTE_PROC',
                                        x_return_status        => l_return_status
                                       );

         -- raise exception if error
         IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okc_api.g_exception_unexpected_error;
         ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okc_api.g_exception_error;
         END IF;

         -- Set message on stack
         -- Workflow event EVENT_NAME has been requested.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_WF_EVENT_MSG',
                              p_token1            => 'EVENT_NAME',
                              p_token1_value      => l_event_desc
                             );
         -- Save message from stack into transaction message table
         okl_am_util_pvt.process_messages
                                    (p_trx_source_table      => 'OKL_TRX_QUOTES_V',
                                     p_trx_id                => lp_qtev_rec.ID,
                                     x_return_status         => l_return_status
                                    );

         -- raise exception if error
         IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okc_api.g_exception_unexpected_error;
         ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okc_api.g_exception_error;
         END IF;
      END IF;

      -- set the return status and out variables
      x_return_status := l_return_status;
      x_qtev_rec := lx_qtev_rec;
      x_tqlv_tbl := lx_tqlv_tbl;
      -- end the transaction
      okc_api.end_activity (x_msg_count, x_msg_data);

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation THEN
         x_return_status := okc_api.g_ret_sts_error;
      WHEN okc_api.g_exception_error THEN
         x_return_status :=
            okc_api.handle_exceptions (l_api_name,
                                       g_pkg_name,
                                       'OKC_API.G_RET_STS_ERROR',
                                       x_msg_count,
                                       x_msg_data,
                                       '_PVT'
                                      );
      WHEN okc_api.g_exception_unexpected_error THEN
         x_return_status :=
            okc_api.handle_exceptions (l_api_name,
                                       g_pkg_name,
                                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                                       x_msg_count,
                                       x_msg_data,
                                       '_PVT'
                                      );
      WHEN OTHERS THEN
         x_return_status :=
            okc_api.handle_exceptions (l_api_name,
                                       g_pkg_name,
                                       'OTHERS',
                                       x_msg_count,
                                       x_msg_data,
                                       '_PVT'
                                      );
   END update_repurchase_quote;
END okl_am_repurchase_asset_pvt;

/
