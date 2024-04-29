--------------------------------------------------------
--  DDL for Package Body OKL_AM_CNTRCT_LN_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CNTRCT_LN_TRMNT_PVT" AS
   /* $Header: OKLRCLTB.pls 120.38.12010000.10 2009/06/02 10:37:43 racheruv ship $ */
   -- GLOBAL VARIABLES

   g_level_procedure   CONSTANT NUMBER         := fnd_log.level_procedure;
   g_level_exception   CONSTANT NUMBER         := fnd_log.level_exception;
   g_level_statement   CONSTANT NUMBER         := fnd_log.level_statement;
   g_module_name       CONSTANT VARCHAR2 (500)
                                := 'okl.am.plsql.okl_am_cntrct_ln_trmnt_pvt.';
   g_amort_complete_flag        VARCHAR2 (1)   := 'N';

--------------- TO DO -----------------------------------------------------

   --invalidating trns once the lines are updated. -- differed for now

   --There may be a change becos of the requirement that mass rebook wont work
   --synchronously with booking the contract and so there may be a delay in the
   --booking of the contract. Soln may be to spawn a WF which checks when
   --contract status changes and then calls the activate insur api.

   --------------------------------------------------------------------------

   -- Start of comments
   --
   -- Procedure Name : check_lease_or_loan
   -- Desciption     : Checks if lease or loan
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        : RMUNJULU 02-JAN-03 2724951 created
   --                : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
   --
   -- End of comments
   PROCEDURE check_lease_or_loan (
      p_khr_id            IN              NUMBER,
      x_lease_loan_type   OUT NOCOPY      VARCHAR2
   )
   IS
      -- Get the K scs_code and deal_type
      -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
      CURSOR k_deal_type_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT CHR.scs_code,
                khr.deal_type
           FROM okc_k_headers_v CHR,
                okl_k_headers_v khr
          WHERE CHR.ID = p_khr_id AND khr.ID = CHR.ID;

      l_lease_loan_type       VARCHAR2 (30)             := '$';
      k_deal_type_rec         k_deal_type_csr%ROWTYPE;
      l_module_name           VARCHAR2 (500)
                                     := g_module_name || 'check_lease_or_loan';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_khr_id: ' || p_khr_id
                                 );
      END IF;

      OPEN k_deal_type_csr (p_khr_id);

      FETCH k_deal_type_csr
       INTO k_deal_type_rec;

      IF k_deal_type_csr%FOUND
      THEN
         -- Set the lease or loan type
         -- (If scs_code = Lease and deal_type = Loan then Loan)
         IF     k_deal_type_rec.scs_code = 'LEASE'
            AND NVL (k_deal_type_rec.deal_type, '?') LIKE 'LOAN%'
         THEN
            l_lease_loan_type := 'LOAN';
         ELSIF     k_deal_type_rec.scs_code = 'LEASE'
               AND NVL (k_deal_type_rec.deal_type, '?') LIKE 'LEASE%'
         THEN
            l_lease_loan_type := 'LEASE';
         ELSIF k_deal_type_rec.scs_code = 'LOAN'
         THEN
            l_lease_loan_type := 'LOAN';
         END IF;
      END IF;

      CLOSE k_deal_type_csr;

      x_lease_loan_type := l_lease_loan_type;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF k_deal_type_csr%ISOPEN
         THEN
            CLOSE k_deal_type_csr;
         END IF;

         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END check_lease_or_loan;


 -- Start of comments
   --
   -- Procedure Name  : update_quote_status
   -- Desciption     : UPDATE TERMINATION QUOTES FROM STATUS ACCEPTED TO
   -- Business Rules  :
   -- Parameters       :
   -- Version      : 1.0
   -- History        : RBRUNO BUG 6801022
   -- 02-sep-2008 rbruno bug 7129269 fix  -
   -- End of comments

PROCEDURE update_quote_status(p_term_rec IN term_rec_type) IS

    lp_qtev_rec                 OKL_TRX_QUOTES_PUB.qtev_rec_type;
    lx_qtev_rec                 OKL_TRX_QUOTES_PUB.qtev_rec_type;

    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_quote_status              VARCHAR2(200) := 'COMPLETE';--'OKL_QUOTE_STATUS'

    lx_msg_count                NUMBER;
    lx_msg_data                 VARCHAR2(2000);

    l_qst_code                  varchar2(200);

    l_tmt_status_code           VARCHAR2(200);

    lx_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lx_quotes_found              VARCHAR2(1) := 'N';
    l_api_version               NUMBER := 1;
    l_module_name           VARCHAR2 (500)
                                     := g_module_name || 'update_quote_status';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
    --:= okl_debug_pub.check_log_on (l_module_name, g_level_exception);


    -- Fetch tmt_status_code

         CURSOR c_tmt_status_code_csr (p_qte_id IN NUMBER) IS
         SELECT tmt_status_code
          FROM okl_trx_contracts trx
          WHERE trx.qte_id = p_qte_id
   --rkuttiya added for 12.1.1 Multi GAAP Project
          AND  trx.representation_type = 'PRIMARY';
   --

    --- Fetch quote satus

         CURSOR k_quotes_csr (p_qte_id IN NUMBER) IS
         SELECT qst_code
          FROM okl_trx_quotes_v
          WHERE id = p_qte_id
          AND (qtp_code LIKE 'TER%' OR qtp_code LIKE 'RES%');

BEGIN
     IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

--Get termination quote status

OPEN k_quotes_csr(p_term_rec.p_quote_id);
FETCH k_quotes_csr into l_qst_code;
CLOSE k_quotes_csr;

IF (is_debug_statement_on)
      THEN
       okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'quote id value :p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
      END IF;
--check whether cutrrent  quote is in status accepted
IF p_term_rec.p_quote_id is not null and l_qst_code = 'ACCEPTED' THEN



      OPEN  c_tmt_status_code_csr(p_term_rec.p_quote_id);
      FETCH c_tmt_status_code_csr INTO l_tmt_status_code;
      CLOSE c_tmt_status_code_csr;

IF (is_debug_statement_on)
      THEN
       okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'quote exists and is in status accepted ');
      okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'Show value of  :l_tmt_status_code '
                                  || l_tmt_status_code
                                 );
              end if;
    --  02-sep-2008 rbruno bug 7129269 fix   commenting line as check is not needed
    --  IF l_tmt_status_code = 'PROCESSED' THEN
          lp_qtev_rec.id        :=     p_term_rec.p_quote_id;
          lp_qtev_rec.qst_code   :=    l_quote_status;


      -- Call the update of the quote header api
      OKL_TRX_QUOTES_PUB.update_trx_quotes (
           p_api_version                  => l_api_version,
           p_init_msg_list                => OKL_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => lx_msg_count,
           x_msg_data                     => lx_msg_data,
           p_qtev_rec                     => lp_qtev_rec,
           x_qtev_rec                     => lx_qtev_rec);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

       IF (is_debug_statement_on)
      THEN
       okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'failure while updating the quote status ');

       END IF;
      END IF;

    --END IF;

  END IF;

END update_quote_status;


   -- Start of comments
   --
   -- Procedure Name : log_messages
   -- Desciption     : Logs the messages in the output log
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        : RMUNJULU 04-DEC-02 Bug # 2484327. Added exception block
   --
   -- End of comments
   PROCEDURE log_messages
   IS
      lx_error_rec   okl_api.error_rec_type;
      l_msg_idx      INTEGER                := fnd_msg_pub.g_first;
   BEGIN
      -- Get the messages in the log
      LOOP
         fnd_msg_pub.get (p_msg_index          => l_msg_idx,
                          p_encoded            => fnd_api.g_false,
                          p_data               => lx_error_rec.msg_data,
                          p_msg_index_out      => lx_error_rec.msg_count
                         );

         IF (lx_error_rec.msg_count IS NOT NULL)
         THEN
            fnd_file.put_line (fnd_file.LOG, lx_error_rec.msg_data);
            fnd_file.put_line (fnd_file.output, lx_error_rec.msg_data);
         END IF;

         EXIT WHEN (   (lx_error_rec.msg_count = fnd_msg_pub.count_msg)
                    OR (lx_error_rec.msg_count IS NULL)
                   );
         l_msg_idx := fnd_msg_pub.g_next;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END log_messages;

   -- Start of comments
   --
   -- Procedure Name : set_database_values
   -- Desciption     : Set the parameters values from database
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        : RMUNJULU 04-DEC-02 Bug#2484327 Added comments to FOR LOOPs
   --                : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
   --
   -- End of comments
   PROCEDURE set_database_values (
      px_term_rec   IN OUT NOCOPY   term_rec_type
   )
   IS
      -- Cursor to get the quote details
      CURSOR get_quote_details_csr (
         p_quote_id   IN   NUMBER
      )
      IS
         SELECT qte.qtp_code qtp_code,
                qte.qrs_code qrs_code
           FROM okl_trx_quotes_v qte
          WHERE qte.ID = p_quote_id;

      -- Cursor to get the k details
      -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
      CURSOR get_k_details_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT khr.contract_number contract_number
           FROM okc_k_headers_v khr
          WHERE khr.ID = p_khr_id;

      l_module_name           VARCHAR2 (500)
                                     := g_module_name || 'set_database_values';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_term_rec.p_contract_id: '
                                  || px_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_term_rec.p_quote_id: '
                                  || px_term_rec.p_quote_id
                                 );
      END IF;

      -- RMUNJULU -- Bug # 2484327 Added comments to for loop
      -- Get the contract number for the contract id passed
      FOR get_k_details_rec IN get_k_details_csr (px_term_rec.p_contract_id)
      LOOP
         px_term_rec.p_contract_number := get_k_details_rec.contract_number;
      END LOOP;

      -- If the termination request is from quote,
      -- populate the rest of the quote attributes
      IF     px_term_rec.p_quote_id IS NOT NULL
         AND px_term_rec.p_quote_id <> g_miss_num
      THEN
         -- RMUNJULU -- Bug # 2484327 Added comments to for loop
         -- Get the quote_type and quote_reason for the quote id passed
         FOR get_quote_details_rec IN
            get_quote_details_csr (px_term_rec.p_quote_id)
         LOOP
            px_term_rec.p_quote_type := get_quote_details_rec.qtp_code;
            px_term_rec.p_quote_reason := get_quote_details_rec.qrs_code;
         END LOOP;
      END IF;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- RMUNJULU -- Bug # 2484327 Added code to close cursors if open
         IF get_k_details_csr%ISOPEN
         THEN
            CLOSE get_k_details_csr;
         END IF;

         IF get_quote_details_csr%ISOPEN
         THEN
            CLOSE get_quote_details_csr;
         END IF;

         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END set_database_values;

   -- Start of comments
   --
   -- Procedure Name : set_info_messages
   -- Desciption     : Set the messages before starting the termination process
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        :
   --
   -- End of comments
   PROCEDURE set_info_messages (
      p_term_rec   IN   term_rec_type
   )
   IS
      l_quote_type            VARCHAR2 (2000);
      l_module_name           VARCHAR2 (500)
                                      := g_module_name || 'set_info_messages';
      is_debug_exception_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_control_flag: '
                                  || p_term_rec.p_control_flag
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
      END IF;

      -- Check and Set the message saying where the termination request came from
      IF (p_term_rec.p_control_flag = 'CONTRACT_TERMINATE_SCRN')
      THEN
         -- Termination request from Request Contract Termination screen
         -- for contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_TERM_REQ_FRM_SCRN',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );

         -- Set the additional message to let the user know if there was a quote
         IF     p_term_rec.p_quote_id IS NOT NULL
            AND p_term_rec.p_quote_id <> g_miss_num
         THEN
            -- Get the lookup meaning for quote type
            l_quote_type :=
               okl_am_util_pvt.get_lookup_meaning
                                   (p_lookup_type      => 'OKL_QUOTE_TYPE',
                                    p_lookup_code      => p_term_rec.p_quote_type,
                                    p_validate_yn      => g_yes
                                   );
            -- Termination request from accepted QUOTE_TYPE
            -- for contract CONTRACT_NUMBER.
            okl_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKL_AM_TERM_REQ_FRM_QTE',
                                p_token1            => 'QUOTE_TYPE',
                                p_token1_value      => l_quote_type,
                                p_token2            => 'CONTRACT_NUMBER',
                                p_token2_value      => p_term_rec.p_contract_number
                               );
         END IF;
      ELSIF (p_term_rec.p_control_flag = 'TRMNT_QUOTE_UPDATE')
      THEN
         -- Get the lookup meaning for quote type
         l_quote_type :=
            okl_am_util_pvt.get_lookup_meaning
                                   (p_lookup_type      => 'OKL_QUOTE_TYPE',
                                    p_lookup_code      => p_term_rec.p_quote_type,
                                    p_validate_yn      => g_yes
                                   );
         -- Termination request from accepted QUOTE_TYPE
         -- for contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_TERM_REQ_FRM_QTE',
                              p_token1            => 'QUOTE_TYPE',
                              p_token1_value      => l_quote_type,
                              p_token2            => 'CONTRACT_NUMBER',
                              p_token2_value      => p_term_rec.p_contract_number
                             );
      ELSIF (p_term_rec.p_control_flag = 'BATCH_PROCESS')
      THEN
         -- Auto termination request for contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_AUTO_TERM_REQ',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
      END IF;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END set_info_messages;

   -- Start of comments
   --
   -- Procedure Name : set_overall_status
   -- Desciption     : Set the overall status for the Termination API
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        :
   --
   -- End of comments
   PROCEDURE set_overall_status (
      p_return_status     IN              VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2
   )
   IS
   BEGIN
      -- Store the highest degree of error
      -- Set p_overall_status only if p_overall_status was successful and
      -- p_return_status is not null
      IF     px_overall_status = g_ret_sts_success
         AND (   p_return_status IS NOT NULL
              OR p_return_status <> okl_api.g_miss_char
             )
      THEN
         px_overall_status := p_return_status;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END set_overall_status;

   -- Start of comments
   --
   -- Procedure Name : initialize_transaction
   -- Desciption     : Initialize the Transaction Record (okl_trx_contracts rec)
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        :
   --
   -- End of comments
   PROCEDURE initialize_transaction (
      p_term_rec        IN              term_rec_type,
      p_sys_date        IN              DATE,
      p_control_flag    IN              VARCHAR2,
      px_tcnv_rec       IN OUT NOCOPY   tcnv_rec_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_try_id                NUMBER;
      l_currency_code         VARCHAR2 (2000);
      l_trans_meaning         VARCHAR2 (200);
      l_return_status         VARCHAR2 (1)    := g_ret_sts_success;
      l_module_name           VARCHAR2 (500)
                                 := g_module_name || 'initialize_transaction';
      is_debug_exception_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_control_flag: '
                                  || p_control_flag
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                                 'In param, p_term_rec.p_termination_reason: '
                              || p_term_rec.p_termination_reason
                             );
      END IF;

      IF p_control_flag = 'CREATE'
      THEN
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                 'calling OKL_AM_UTIL_PVT.get_transaction_id'
                                );
         END IF;

         -- Get the Accounting Transaction Id
         okl_am_util_pvt.get_transaction_id
                                          (p_try_name           => 'Termination',
                                           x_return_status      => l_return_status,
                                           x_try_id             => l_try_id
                                          );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_AM_UTIL_PVT.get_transaction_id , l_return_status: '
                || l_return_status
               );
         END IF;

         -- Get the meaning of Accounting lookup
         l_trans_meaning :=
            okl_am_util_pvt.get_lookup_meaning
                                (p_lookup_type      => 'OKL_ACCOUNTING_EVENT_TYPE',
                                 p_lookup_code      => 'TERMINATION',
                                 p_validate_yn      => 'Y'
                                );

         IF l_return_status <> g_ret_sts_success
         THEN
            -- Unable to find a transaction type for the transaction TRY_NAME
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_NO_TRX_TYPE_FOUND',
                                 p_token1            => 'TRY_NAME',
                                 p_token1_value      => l_trans_meaning
                                );
            RAISE okl_api.g_exception_error;
         END IF;

         -- Get the contract currency code
         l_currency_code :=
                   okl_am_util_pvt.get_chr_currency (p_term_rec.p_contract_id);
         -- initialize the transaction rec
         px_tcnv_rec.khr_id := p_term_rec.p_contract_id;
         px_tcnv_rec.tcn_type := 'ALT';                                 -- TMT
         px_tcnv_rec.try_id := l_try_id;
         px_tcnv_rec.currency_code := l_currency_code;
      END IF;

      -- Set the rest of the transaction rec
      px_tcnv_rec.qte_id := p_term_rec.p_quote_id;
      px_tcnv_rec.tsu_code := 'ENTERED';
      px_tcnv_rec.tmt_status_code := 'ENTERED';
                                 --akrangan changes for sla tmt_status_code cr
      px_tcnv_rec.date_transaction_occurred := p_sys_date;
      --20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
      px_tcnv_rec.legal_entity_id :=
                okl_legal_entity_util.get_khr_le_id (p_term_rec.p_contract_id);

      -- set the termination reason (TRN_CODE)
      IF     (p_term_rec.p_termination_reason <> okl_api.g_miss_char)
         AND (p_term_rec.p_termination_reason IS NOT NULL)
      THEN
         px_tcnv_rec.trn_code := p_term_rec.p_termination_reason;
      ELSE
         px_tcnv_rec.trn_code := 'EXP';
      END IF;

      -- Set the return status
      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- Set the return status
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         -- Set the return status
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END initialize_transaction;

   -- Start of comments
   --
   -- Procedure Name : set_transaction_rec
   -- Desciption     : Set the Transaction Record (okl_trx_contracts rec)
   -- Business Rules :
   -- Parameters     :
   -- Version      : 1.0
   -- History        : RMUNJULU 2757312 Added code to set tmt_generic flags
   --
   -- End of comments
   PROCEDURE set_transaction_rec (
      p_return_status    IN              VARCHAR2,
      p_overall_status   IN              VARCHAR2,
      p_tmt_flag         IN              VARCHAR2,
      p_tsu_code         IN              VARCHAR2,
      p_ret_val          IN              VARCHAR2,
      px_tcnv_rec        IN OUT NOCOPY   tcnv_rec_type
   )
   IS
      l_module_name           VARCHAR2 (500)
                                    := g_module_name || 'set_transaction_rec';
      is_debug_exception_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_return_status: '
                                  || p_return_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_overall_status: '
                                  || p_overall_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_tmt_flag: ' || p_tmt_flag
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_tsu_code: ' || p_tsu_code
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_ret_val: ' || p_ret_val
                                 );
      END IF;

      -- set the transaction record
      IF (p_overall_status = g_ret_sts_success)
      THEN
         --px_tcnv_rec.tsu_code := p_tsu_code; --akrangan chaged
         px_tcnv_rec.tmt_status_code := p_tsu_code;
                                --akrangan changed for sla tmt_status_code cr
      ELSE
         px_tcnv_rec.tmt_status_code := 'ERROR';
                                --akrangan changes for sla tmt_status_code cr
      END IF;

      IF (p_ret_val = okl_api.g_miss_char)
      THEN
         -- No value for p_ret_val
         IF (p_return_status = g_ret_sts_success)
         THEN
            -- ret stat success
            IF (p_tmt_flag = 'TMT_EVERGREEN_YN')
            THEN
               px_tcnv_rec.tmt_evergreen_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_CLOSE_BALANCES_YN')
            THEN
               px_tcnv_rec.tmt_close_balances_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_ACCOUNTING_ENTRIES_YN')
            THEN
               px_tcnv_rec.tmt_accounting_entries_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_CANCEL_INSURANCE_YN')
            THEN
               px_tcnv_rec.tmt_cancel_insurance_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_ASSET_DISPOSITION_YN')
            THEN
               px_tcnv_rec.tmt_asset_disposition_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_AMORTIZATION_YN')
            THEN
               px_tcnv_rec.tmt_amortization_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_ASSET_RETURN_YN')
            THEN
               px_tcnv_rec.tmt_asset_return_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_CONTRACT_UPDATED_YN')
            THEN
               px_tcnv_rec.tmt_contract_updated_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_STREAMS_UPDATED_YN')
            THEN
               px_tcnv_rec.tmt_streams_updated_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_VALIDATED_YN')
            THEN
               px_tcnv_rec.tmt_validated_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_SPLIT_ASSET_YN')
            THEN
               px_tcnv_rec.tmt_split_asset_yn := g_yes;
            -- RMUNJULU 2757312 Added
            ELSIF (p_tmt_flag = 'TMT_GENERIC_FLAG1_YN')
            THEN
               px_tcnv_rec.tmt_generic_flag1_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_GENERIC_FLAG2_YN')
            THEN
               px_tcnv_rec.tmt_generic_flag2_yn := g_yes;
            ELSIF (p_tmt_flag = 'TMT_GENERIC_FLAG3_YN')
            THEN
               px_tcnv_rec.tmt_generic_flag3_yn := g_yes;
            END IF;
         ELSE
            -- return_status not success
            IF (p_tmt_flag = 'TMT_EVERGREEN_YN')
            THEN
               px_tcnv_rec.tmt_evergreen_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_CLOSE_BALANCES_YN')
            THEN
               px_tcnv_rec.tmt_close_balances_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_ACCOUNTING_ENTRIES_YN')
            THEN
               px_tcnv_rec.tmt_accounting_entries_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_CANCEL_INSURANCE_YN')
            THEN
               px_tcnv_rec.tmt_cancel_insurance_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_ASSET_DISPOSITION_YN')
            THEN
               px_tcnv_rec.tmt_asset_disposition_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_AMORTIZATION_YN')
            THEN
               px_tcnv_rec.tmt_amortization_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_ASSET_RETURN_YN')
            THEN
               px_tcnv_rec.tmt_asset_return_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_CONTRACT_UPDATED_YN')
            THEN
               px_tcnv_rec.tmt_contract_updated_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_STREAMS_UPDATED_YN')
            THEN
               px_tcnv_rec.tmt_streams_updated_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_VALIDATED_YN')
            THEN
               px_tcnv_rec.tmt_validated_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_SPLIT_ASSET_YN')
            THEN
               px_tcnv_rec.tmt_split_asset_yn := g_no;
            -- RMUNJULU 2757312 Added
            ELSIF (p_tmt_flag = 'TMT_GENERIC_FLAG1_YN')
            THEN
               px_tcnv_rec.tmt_generic_flag1_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_GENERIC_FLAG2_YN')
            THEN
               px_tcnv_rec.tmt_generic_flag2_yn := g_no;
            ELSIF (p_tmt_flag = 'TMT_GENERIC_FLAG3_YN')
            THEN
               px_tcnv_rec.tmt_generic_flag3_yn := g_no;
            END IF;
         END IF;
      ELSE
         -- value for p_ret_val passed ( will override return_status val)
         IF (p_tmt_flag = 'TMT_EVERGREEN_YN')
         THEN
            px_tcnv_rec.tmt_evergreen_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_CLOSE_BALANCES_YN')
         THEN
            px_tcnv_rec.tmt_close_balances_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_ACCOUNTING_ENTRIES_YN')
         THEN
            px_tcnv_rec.tmt_accounting_entries_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_CANCEL_INSURANCE_YN')
         THEN
            px_tcnv_rec.tmt_cancel_insurance_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_ASSET_DISPOSITION_YN')
         THEN
            px_tcnv_rec.tmt_asset_disposition_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_AMORTIZATION_YN')
         THEN
            px_tcnv_rec.tmt_amortization_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_ASSET_RETURN_YN')
         THEN
            px_tcnv_rec.tmt_asset_return_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_CONTRACT_UPDATED_YN')
         THEN
            px_tcnv_rec.tmt_contract_updated_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_STREAMS_UPDATED_YN')
         THEN
            px_tcnv_rec.tmt_streams_updated_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_VALIDATED_YN')
         THEN
            px_tcnv_rec.tmt_validated_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_SPLIT_ASSET_YN')
         THEN
            px_tcnv_rec.tmt_split_asset_yn := p_ret_val;
         -- RMUNJULU 2757312 Added
         ELSIF (p_tmt_flag = 'TMT_GENERIC_FLAG1_YN')
         THEN
            px_tcnv_rec.tmt_generic_flag1_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_GENERIC_FLAG2_YN')
         THEN
            px_tcnv_rec.tmt_generic_flag2_yn := p_ret_val;
         ELSIF (p_tmt_flag = 'TMT_GENERIC_FLAG3_YN')
         THEN
            px_tcnv_rec.tmt_generic_flag3_yn := p_ret_val;
         END IF;
      END IF;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END set_transaction_rec;

   -- Start of comments
   --
   -- Procedure Name : process_transaction
   -- Desciption     : Insert/Update the Transaction Record (okl_trx_contracts )
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History
   --
   -- End of comments
   PROCEDURE process_transaction (
      p_id              IN              NUMBER,
      p_term_rec        IN              term_rec_type,
      p_tcnv_rec        IN              tcnv_rec_type,
      p_trn_mode        IN              VARCHAR2,
      x_id              OUT NOCOPY      NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_return_status          VARCHAR2 (1)    := g_ret_sts_success;
      lp_tcnv_rec              tcnv_rec_type   := p_tcnv_rec;
      lx_tcnv_rec              tcnv_rec_type;
      l_api_version   CONSTANT NUMBER          := g_api_version;
      l_msg_count              NUMBER          := g_miss_num;
      l_msg_data               VARCHAR2 (2000);
      l_module_name            VARCHAR2 (500)
                                    := g_module_name || 'process_transaction';
      is_debug_exception_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_id: ' || p_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_trn_mode: ' || p_trn_mode
                                 );
      END IF;

      -- Set the savepoint for this api
      SAVEPOINT process_transaction;
      -- Clear the recycle flag after processing
      lp_tcnv_rec.tmt_recycle_yn := NULL;

      -- Based on mode Insert/Update the transaction rec
      IF p_trn_mode = 'INSERT'
      THEN
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling OKL_TRX_CONTRACTS_PUB.create_trx_contracts'
                        );
         END IF;

         -- insert transaction rec
         okl_trx_contracts_pub.create_trx_contracts
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_tcnv_rec           => lp_tcnv_rec,
                                           x_tcnv_rec           => lx_tcnv_rec
                                          );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_TRX_CONTRACTS_PUB.create_trx_contracts , return status: '
                || l_return_status
               );
         END IF;
      ELSIF p_trn_mode = 'UPDATE'
      THEN
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling OKL_TRX_CONTRACTS_PUB.update_trx_contracts'
                        );
         END IF;

         -- update transaction rec
         okl_trx_contracts_pub.update_trx_contracts
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_tcnv_rec           => lp_tcnv_rec,
                                           x_tcnv_rec           => lx_tcnv_rec
                                          );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_TRX_CONTRACTS_PUB.update_trx_contracts , return status: '
                || l_return_status
               );
         END IF;
      END IF;

      -- rollback if error
      IF (l_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- set the return values
      x_return_status := l_return_status;
      x_id := lx_tcnv_rec.ID;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         ROLLBACK TO process_transaction;
         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         ROLLBACK TO process_transaction;
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         ROLLBACK TO process_transaction;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END process_transaction;

   -- Start of comments
   --
   -- Procedure Name : get_lines
   -- Desciption     : For the Termination quote get the contract lines
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        : RMUNJULU -- Bug # 2484327 16-DEC-02 set additional values
   --                  for lines rec type
   --
   -- End of comments
   PROCEDURE get_lines (
      p_term_rec        IN              term_rec_type,
      x_klev_tbl        OUT NOCOPY      klev_tbl_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      -- Get the lines for the quote
      -- RMUNJULU -- Bug # 2484327 16-DEC-02 Added columns to query
      CURSOR get_qte_lines_csr (
         p_qte_id   IN   NUMBER
      )
      IS
         SELECT kle.ID kle_id,
                kle.NAME asset_name,
                tql.asset_quantity asset_quantity,
                tql.ID tql_id,
                tql.quote_quantity quote_quantity,
                tql.split_kle_name split_kle_name          -- RMUNJULU 2757312
           FROM okl_txl_quote_lines_v tql,
                okc_k_lines_v kle
          WHERE tql.qte_id = p_qte_id
            AND tql.qlt_code = 'AMCFIA'
            AND tql.kle_id = kle.ID;

      lx_klev_tbl             klev_tbl_type;
      i                       NUMBER         := 1;
      l_return_status         VARCHAR2 (1)   := g_ret_sts_success;
      l_module_name           VARCHAR2 (500) := g_module_name || 'get_lines';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
      END IF;

      i := 1;

      -- Set the klev_tbl
      FOR get_qte_lines_rec IN get_qte_lines_csr (p_term_rec.p_quote_id)
      LOOP
         lx_klev_tbl (i).p_kle_id := get_qte_lines_rec.kle_id;
         lx_klev_tbl (i).p_asset_name := get_qte_lines_rec.asset_name;
         -- RMUNJULU -- Bug # 2484327 16-DEC-02 -- START --
         -- set additional values for lines
         lx_klev_tbl (i).p_asset_quantity := get_qte_lines_rec.asset_quantity;
         lx_klev_tbl (i).p_tql_id := get_qte_lines_rec.tql_id;
         lx_klev_tbl (i).p_quote_quantity := get_qte_lines_rec.quote_quantity;
         -- RMUNJULU -- Bug # 2484327 16-DEC-02 -- END --

         -- RMUNJULU 2757312
         lx_klev_tbl (i).p_split_kle_name := get_qte_lines_rec.split_kle_name;
         i := i + 1;
      END LOOP;

      -- Set the return status
      x_return_status := l_return_status;
      x_klev_tbl := lx_klev_tbl;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- RMUNJULU -- Bug # 2484327 Added code to close cursor if open
         IF get_qte_lines_csr%ISOPEN
         THEN
            CLOSE get_qte_lines_csr;
         END IF;

         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         -- Set the return status
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END get_lines;

   -- Start of comments
   --
   -- Procedure Name : validate_contract_and_lines
   -- Desciption     : Validates the contract and lines to check they have right
   --                  statuses (ste_code and sts_code).
   -- Business Rules :
   -- Parameters   :
   -- Version    : 1.0
   -- History        : RMUNJULU 20-DEC-02 2484327 Added message when error
   --                : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
   --
   -- End of comments
   PROCEDURE validate_contract_and_lines (
      p_term_rec        IN              term_rec_type,
      p_sys_date        IN              DATE,
      p_klev_tbl        IN              klev_tbl_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      -- Get the status of the contract
      -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
      CURSOR chr_sts_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT khr.sts_code sts_code
           FROM okc_k_headers_v khr
          WHERE khr.ID = p_khr_id;

      -- Get the status of the line
      -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_LNS_FULL
      CURSOR cle_sts_csr (
         p_kle_id   IN   NUMBER
      )
      IS
         SELECT kle.sts_code sts_code
           FROM okc_k_lines_v kle
          WHERE kle.ID = p_kle_id;

      i                       NUMBER         := 1;
      l_k_sts                 VARCHAR2 (30);
      l_l_sts                 VARCHAR2 (30);
      l_sts_match             VARCHAR2 (1)   := g_yes;
      l_return_status         VARCHAR2 (1)   := g_ret_sts_success;
      l_module_name           VARCHAR2 (500)
                             := g_module_name || 'validate_contract_and_lines';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );

         IF (p_klev_tbl.COUNT > 0)
         THEN
            i := p_klev_tbl.FIRST;

            LOOP
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'In param, p_klev_tbl('
                                        || i
                                        || ').p_kle_id: '
                                        || p_klev_tbl (i).p_kle_id
                                       );
               EXIT WHEN (i = p_klev_tbl.LAST);
               i := p_klev_tbl.NEXT (i);
            END LOOP;
         END IF;
      END IF;

      -- Get the contract status
      OPEN chr_sts_csr (p_term_rec.p_contract_id);

      FETCH chr_sts_csr
       INTO l_k_sts;

      CLOSE chr_sts_csr;

      -- RMUNJULU 3018641 Step Message
      -- Step : Validate Contract
      okl_api.set_message (p_app_name      => g_app_name,
                           p_msg_name      => 'OKL_AM_STEP_VAL');

      -- While looping thru the lines get the line status and compare with
      -- contract status. If both the statuses doesnot match then error.
      IF (p_klev_tbl.COUNT > 0)
      THEN
         i := p_klev_tbl.FIRST;

         LOOP
            -- Get the line status
            OPEN cle_sts_csr (p_klev_tbl (i).p_kle_id);

            FETCH cle_sts_csr
             INTO l_l_sts;

            CLOSE cle_sts_csr;

            -- Check if both statuses match
            IF l_k_sts <> l_l_sts
            THEN
               l_sts_match := g_no;
               EXIT;
            END IF;

            EXIT WHEN (i = p_klev_tbl.LAST);
            i := p_klev_tbl.NEXT (i);
         END LOOP;
      END IF;

      -- If statuses do not match set return status
      IF l_sts_match <> g_yes
      THEN
         -- Validation of contract and/or lines failed for contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_VAL_K_LNS_FAILED',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
         l_return_status := g_ret_sts_error;
      END IF;

      -- Set the return status
      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Close any cursors which are open
         IF chr_sts_csr%ISOPEN
         THEN
            CLOSE chr_sts_csr;
         END IF;

         IF cle_sts_csr%ISOPEN
         THEN
            CLOSE cle_sts_csr;
         END IF;

         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         -- Set the return status
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END validate_contract_and_lines;

   -- Start of comments
   --
   -- Procedure Name  : do_split_asset_trn
   -- Description     : This procedure Creates the Split Trn and Updates the Split TRN if needed
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- History         : RMUNJULU 2757312 Added this proc
   --                   This proc will use tmt_generic_flag1_yn to maintain status of
   --                   whether the split trn was created and updated successfully or not
   --                 : rmunjulu EDAT Added code to get quote eff dates and call new overloaded split asset API
   -- End of comments
   PROCEDURE do_split_asset_trn (
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_trn_already_set   IN              VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2,
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type,
      px_klev_tbl         IN OUT NOCOPY   klev_tbl_type,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      -- SECHAWLA 23-DEC-02 2484327 Added cursors
      -- Get the count of IB lines for the quote_line_id (TQL_ID )
      CURSOR get_ib_lines_cnt_csr (
         p_tql_id   IN   NUMBER
      )
      IS
         SELECT COUNT (txd.ID) ib_lines_count
           FROM okl_txd_quote_line_dtls txd
          WHERE txd.tql_id = p_tql_id;

      -- Get the IB Lines for the quote_line_id (tql_id)
      CURSOR get_ib_lines_csr (
         p_tql_id   IN   NUMBER
      )
      IS
         SELECT txd.kle_id
           FROM okl_txd_quote_line_dtls txd
          WHERE txd.tql_id = p_tql_id;

      lx_txdv_tbl              okl_txd_assets_pub.adpv_tbl_type;
      lx_txlv_rec              okl_txl_assets_pub.tlpv_rec_type;
      lx_trxv_rec              okl_trx_assets_pub.thpv_rec_type;
      lx_cle_tbl               okl_split_asset_pvt.cle_tbl_type;
      lx_sno_yn                VARCHAR2 (3)                        := g_false;
      lx_clev_tbl              okl_okc_migration_pvt.clev_tbl_type;
      lp_ib_tbl                okl_split_asset_pvt.ib_tbl_type;
      lp_empty_ib_tbl          okl_split_asset_pvt.ib_tbl_type;
      l_api_name      CONSTANT VARCHAR2 (30)           := 'do_split_asset_trn';
      l_return_status          VARCHAR2 (1)               := g_ret_sts_success;
      cle_index                NUMBER                              := 0;
      i                        NUMBER                              := 0;
      ib_id                    NUMBER                              := 0;
      l_module_name            VARCHAR2 (500)
                                      := g_module_name || 'do_split_asset_trn';
      is_debug_exception_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      --SECHAWLA 14-JAN-03 2748110 : New Declarations
      ib_line_id               NUMBER                              := 0;
      id_exists                VARCHAR2 (1);
      -- SECHAWLA 23-DEC-02 2484327 Added variable
      l_ib_lines_count         NUMBER;
      l_api_version   CONSTANT NUMBER                         := g_api_version;
      l_msg_count              NUMBER                            := g_miss_num;
      l_msg_data               VARCHAR2 (2000);
      lxx_txdv_tbl             okl_txd_assets_pub.adpv_tbl_type;
      lx_txd_assets_rec        okl_txd_assets_pub.adpv_rec_type;
      lx_txdv_rec              okl_txd_assets_pub.adpv_rec_type;
      j                        NUMBER;
      -- rmunjulu EDAT
      l_quote_accpt_date       DATE;
      l_quote_eff_date         DATE;
   BEGIN
      SAVEPOINT do_split_asset_trn;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug
                            (g_level_statement,
                             l_module_name,
                                'In param, px_tcnv_rec.tmt_generic_flag1_yn: '
                             || px_tcnv_rec.tmt_generic_flag1_yn
                            );

         IF px_klev_tbl.COUNT > 0
         THEN
            FOR i IN px_klev_tbl.FIRST .. px_klev_tbl.LAST
            LOOP
               IF (px_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || px_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_asset_quantity: '
                                           || px_klev_tbl (i).p_asset_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || px_klev_tbl (i).p_asset_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_quote_quantity: '
                                           || px_klev_tbl (i).p_quote_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_tql_id: '
                                           || px_klev_tbl (i).p_tql_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_split_kle_name: '
                                           || px_klev_tbl (i).p_split_kle_name
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      x_return_status := okl_api.g_ret_sts_success;

      IF    (    p_trn_already_set = g_yes
             AND NVL (px_tcnv_rec.tmt_generic_flag1_yn, '?') <> g_yes
            )
         OR (p_trn_already_set = g_no)
      THEN
         -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

         -- rmunjulu EDAT
         -- If quote exists then accnting date is quote accept date else sysdate
         IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
         THEN
            l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
            l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
         ELSE
            l_quote_accpt_date := p_sys_date;
            l_quote_eff_date := p_sys_date;
         END IF;

         -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++
         IF px_klev_tbl.COUNT > 0
         THEN
            FOR i IN px_klev_tbl.FIRST .. px_klev_tbl.LAST
            LOOP
               IF    px_klev_tbl (i).p_kle_id IS NULL
                  OR px_klev_tbl (i).p_kle_id = g_miss_num
               THEN
                  -- kle id parameter is null
                  okl_api.set_message (p_app_name          => g_app_name_1,
                                       p_msg_name          => g_required_value,
                                       p_token1            => g_col_name_token,
                                       p_token1_value      => 'Kle Id'
                                      );
                  RAISE okl_api.g_exception_error;
               END IF;

               IF    px_klev_tbl (i).p_asset_quantity IS NULL
                  OR px_klev_tbl (i).p_asset_quantity = okl_api.g_miss_num
               THEN
                  -- Asset Quantity parameter is null
                  okl_api.set_message (p_app_name          => g_app_name_1,
                                       p_msg_name          => g_required_value,
                                       p_token1            => g_col_name_token,
                                       p_token1_value      => 'Asset Quantity'
                                      );
                  RAISE okl_api.g_exception_error;
               END IF;

               IF    px_klev_tbl (i).p_asset_name IS NULL
                  OR px_klev_tbl (i).p_asset_name = okl_api.g_miss_char
               THEN
                  -- Asset Name parameter is null
                  okl_api.set_message (p_app_name          => g_app_name_1,
                                       p_msg_name          => g_required_value,
                                       p_token1            => g_col_name_token,
                                       p_token1_value      => 'Asset Name'
                                      );
                  RAISE okl_api.g_exception_error;
               END IF;

               IF    px_klev_tbl (i).p_quote_quantity IS NULL
                  OR px_klev_tbl (i).p_quote_quantity = okl_api.g_miss_num
               THEN
                  -- Quote Quantity parameter is null
                  okl_api.set_message (p_app_name          => g_app_name_1,
                                       p_msg_name          => g_required_value,
                                       p_token1            => g_col_name_token,
                                       p_token1_value      => 'Quote Quantity'
                                      );
                  RAISE okl_api.g_exception_error;
               END IF;

               IF    px_klev_tbl (i).p_tql_id IS NULL
                  OR px_klev_tbl (i).p_tql_id = okl_api.g_miss_num
               THEN
                  -- quote line id parameter is null
                  okl_api.set_message (p_app_name          => g_app_name_1,
                                       p_msg_name          => g_required_value,
                                       p_token1            => g_col_name_token,
                                       p_token1_value      => 'Quote Line ID'
                                      );
                  RAISE okl_api.g_exception_error;
               END IF;

               -- Check if the IB instances for this asset are serialized
               -- also get the IB instances which are serialized
               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                            'calling OKL_AM_TERMNT_QUOTE_PVT.check_asset_sno'
                           );
               END IF;

               x_return_status :=
                  okl_am_termnt_quote_pvt.check_asset_sno
                                     (p_asset_line      => px_klev_tbl (i).p_kle_id,
                                      x_sno_yn          => lx_sno_yn,
                                      x_clev_tbl        => lx_clev_tbl
                                     );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                         'called OKL_AM_TERMNT_QUOTE_PVT.check_asset_sno , return status: '
                      || x_return_status
                     );
               END IF;

               IF (x_return_status = g_ret_sts_unexp_error)
               THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (x_return_status = g_ret_sts_error)
               THEN
                  RAISE okl_api.g_exception_error;
               END IF;

               -- If Asset serialized
               IF lx_sno_yn = g_true
               THEN
                  -- SECHAWLA 23-DEC-02 2484327 Changed processing to get the correct
                  -- IB lines for the quote

                  -- Get the IB line count
                  OPEN get_ib_lines_cnt_csr (px_klev_tbl (i).p_tql_id);

                  FETCH get_ib_lines_cnt_csr
                   INTO l_ib_lines_count;

                  CLOSE get_ib_lines_cnt_csr;

                  -- If IB line count does not match Quote Qty raise msg and exp
                  IF l_ib_lines_count <> px_klev_tbl (i).p_quote_quantity
                  THEN
                     -- Asset ASSET_NUMBER is serialized. Quote quantity
                     -- QUOTE_QUANTITY does not match the number of selected asset
                     -- units ASSET_UNITS.
                     okl_api.set_message
                          (p_app_name          => 'OKL',
                           p_msg_name          => 'OKL_AM_QTE_QTY_SRL_CNT_ERR',
                           p_token1            => 'ASSET_NUMBER',
                           p_token1_value      => px_klev_tbl (i).p_asset_name,
                           p_token2            => 'QUOTE_QUANTITY',
                           p_token2_value      => px_klev_tbl (i).p_quote_quantity,
                           p_token3            => 'ASSET_UNITS',
                           p_token3_value      => l_ib_lines_count
                          );
                     RAISE okl_api.g_exception_error;
                  END IF;

                  --SECHAWLA 14-JAN-03 2748110 : Modified the logic to send those ib
                  -- line ids that do not exist in
                  --OKL_TXD_QUOTE_LINE_DTLS_V, to create_split_transaction procedure.
                  -- This change follows the change
                  -- in p_split_into_units quantity, on 08-JAN-03, to send
                  -- asset quantity minus quote quantity as split
                  -- into units.
                  IF lx_clev_tbl.COUNT > 0
                  THEN
                     ib_line_id := lx_clev_tbl.FIRST;
                     ib_id := 1;

                     LOOP
                        id_exists := 'F';

                        -- Populate the input table of IB line IDs to create split transaction
                        -- procedure with rows from okl_txd_quote_line_dtls table
                        FOR get_ib_lines_rec IN
                           get_ib_lines_csr (px_klev_tbl (i).p_tql_id)
                        LOOP
                           IF lx_clev_tbl (ib_line_id).ID =
                                                      get_ib_lines_rec.kle_id
                           THEN
                              id_exists := 'T';
                              EXIT;
                           END IF;
                        END LOOP;

                        IF id_exists = 'F'
                        THEN
                           lp_ib_tbl (ib_id).ID :=
                                                  lx_clev_tbl (ib_line_id).ID;
                           ib_id := ib_id + 1;
                        END IF;

                        EXIT WHEN (ib_line_id = lx_clev_tbl.LAST);
                        ib_line_id := lx_clev_tbl.NEXT (ib_line_id);
                     END LOOP;
                  ELSE
                     -- IB line ids not found
                     okl_api.set_message (p_app_name          => g_app_name_1,
                                          p_msg_name          => g_required_value,
                                          p_token1            => g_col_name_token,
                                          p_token1_value      => 'IB Line IDs'
                                         );
                     RAISE okl_api.g_exception_error;
                  END IF;
               END IF;

               -- Create the split asset transactions
               -- rmunjulu EDAT Call the new signature of split asset which takes trx date
               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                      (g_level_statement,
                       l_module_name,
                       'calling OKL_SPLIT_ASSET_PUB.create_split_transaction'
                      );
               END IF;

               okl_split_asset_pub.create_split_transaction
                  (p_api_version                    => l_api_version,
                   p_init_msg_list                  => g_false,
                   x_return_status                  => x_return_status,
                   x_msg_count                      => l_msg_count,
                   x_msg_data                       => l_msg_data,
                   p_cle_id                         => px_klev_tbl (i).p_kle_id,
                   p_split_into_individuals_yn      => 'N',
                                          -- RMUNJULU Changed was NULL earlier
                   p_split_into_units               =>   px_klev_tbl (i).p_asset_quantity
                                                       - px_klev_tbl (i).p_quote_quantity,
                   p_ib_tbl                         => lp_ib_tbl,
                   p_trx_date                       => l_quote_eff_date,
                                                              -- rmunjulu EDAT
                   x_txdv_tbl                       => lx_txdv_tbl,
                                                                 --okl_asd_pvt
                   x_txlv_rec                       => lx_txlv_rec,
                   x_trxv_rec                       => lx_trxv_rec
                  );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                         'called OKL_SPLIT_ASSET_PUB.create_split_transaction , return status: '
                      || x_return_status
                     );
               END IF;

               IF (x_return_status = g_ret_sts_unexp_error)
               THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (x_return_status = g_ret_sts_error)
               THEN
                  RAISE okl_api.g_exception_error;
               END IF;

               -- get the transaction which needs to be updated
               IF     px_klev_tbl (i).p_split_kle_name IS NOT NULL
                  AND px_klev_tbl (i).p_split_kle_name <> g_miss_char
               THEN
                  IF lx_txdv_tbl.COUNT > 0
                  THEN
                     -- Update the TXDV rec which has no target_kle_id ie which is the
                     -- new asset created
                     FOR j IN lx_txdv_tbl.FIRST .. lx_txdv_tbl.LAST
                     LOOP
                        IF lx_txdv_tbl (j).target_kle_id IS NULL
                        THEN
                           lx_txd_assets_rec.asset_number :=
                                             px_klev_tbl (i).p_split_kle_name;
                           lx_txd_assets_rec.ID := lx_txdv_tbl (j).ID;

                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                  'calling OKL_TXD_ASSETS_PUB.update_txd_asset_def'
                                 );
                           END IF;

                           okl_txd_assets_pub.update_txd_asset_def
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_adpv_rec           => lx_txd_assets_rec,
                                           x_adpv_rec           => lx_txdv_rec
                                          );

                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called OKL_TXD_ASSETS_PUB.update_txd_asset_def , return status: '
                                  || x_return_status
                                 );
                           END IF;

                           IF (x_return_status = g_ret_sts_unexp_error)
                           THEN
                              RAISE okl_api.g_exception_unexpected_error;
                           ELSIF (x_return_status = g_ret_sts_error)
                           THEN
                              RAISE okl_api.g_exception_error;
                           END IF;
                        END IF;
                     END LOOP;
                  ELSE
                     -- Create Split Trn did not work properly
                     okl_api.set_message
                                       (p_app_name          => g_app_name_1,
                                        p_msg_name          => g_invalid_value,
                                        p_token1            => g_col_name_token,
                                        p_token1_value      => 'lx_txdv_tbl.COUNT'
                                       );
                     RAISE okl_api.g_exception_error;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                            (g_level_statement,
                             l_module_name,
                                'called set_overall_status , return status: '
                             || x_return_status
                            );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'px_overall_status: '
                                     || px_overall_status
                                    );
         END IF;

         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_GENERIC_FLAG1_YN',
                              p_tsu_code            => 'WORKING',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called set_transaction_rec , return status: '
                            || x_return_status
                           );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'px_overall_status: '
                                     || px_overall_status
                                    );
         END IF;
      END IF;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- SECHAWLA 23-DEC-02 2484327 Closed cursors if open
         IF get_ib_lines_cnt_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_cnt_csr;
         END IF;

         IF get_ib_lines_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_csr;
         END IF;

         ROLLBACK TO do_split_asset_trn;
         x_return_status := g_ret_sts_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_GENERIC_FLAG1_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- SECHAWLA 23-DEC-02 2484327 Closed cursors if open
         IF get_ib_lines_cnt_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_cnt_csr;
         END IF;

         IF get_ib_lines_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_csr;
         END IF;

         ROLLBACK TO do_split_asset_trn;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_GENERIC_FLAG1_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- SECHAWLA 23-DEC-02 2484327 Closed cursors if open
         IF get_ib_lines_cnt_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_cnt_csr;
         END IF;

         IF get_ib_lines_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_csr;
         END IF;

         ROLLBACK TO do_split_asset_trn;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_GENERIC_FLAG1_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END do_split_asset_trn;

   -- Start of comments
   --
   -- Procedure Name  : do_split_asset
   -- Description     : This procedure splits a financial asset into two
   -- Business Rules  :
   -- Parameters      :  Input/Output parameters : px_klev_tbl
   --                    px_klev_tbl is a table of records of the following structure :

   --                    p_kle_id            : Original kle ID
   --                    p_asset_quantity    : Asset Quantity
   --                    p_asset_name        : Asset Number
   --                    p_quote_quantity    : Quantity to Split
   --                    p_tql_id            : Quote Line ID
   --                    p_split_kle_id      : Split (new) Kle Id
   --
   -- Version         : 1.0
   -- History         : SECHAWLA 16-DEC-02 Bug# 2484327 Created
   --                   SECHAWLA 23-DEC-02 2484327 Changed the way IB line ids are identified
   --                   SECHAWLA 08-JAN-03 2736865 Changed the logic to send (asset qty - quote qty)
   --                       in p_split_into_units parameter, instead of sending the quote qty
   --                   SECHAWLA 14-JAN-03 2748110 : Modified the logic to send
   --                       those ib line ids that do not exist in
   --                       OKL_TXD_QUOTE_LINE_DTLS_V, to create_split_transaction procedure
   --                   RMUNJULU 2757312 MAJOR CHANGES TO this proc
   --                   Added parameters, removed create split trn to do_split_trn
   --                   coded for two flags to maintain split asset status
   --                   This proc will use tmt_split_asset_yn
   --                   RMUNJULU 2757312 Added code to check that split trn is not processed
   --                   RMUNJULU ASSETNUM INPUT 2757312 Added code to make sure error from split
   --                   asset is becos of uniqueness failure
   --                   RMUNJULU 3241502 Call asset_number_exists from OKL_AM_CREATE_QUOTE_PVT
   --                   SECHAWLA Split Asset Enhancements (FPs) Addes a parameter p_source_call in call to
   --                            OKL_SPLIT_ASSET_PUB.split_fixed_asset
   -- End of comments
   PROCEDURE do_split_asset (
      p_term_rec          IN              term_rec_type,
                                                      --RMUNJULU 2757312 Added
      p_sys_date          IN              DATE,       --RMUNJULU 2757312 Added
      p_trn_already_set   IN              VARCHAR2,   --RMUNJULU 2757312 Added
      px_overall_status   IN OUT NOCOPY   VARCHAR2,   --RMUNJULU 2757312 Added
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type,
                                                      --RMUNJULU 2757312 Added
      px_klev_tbl         IN OUT NOCOPY   klev_tbl_type,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      -- SECHAWLA 23-DEC-02 2484327 Added cursors
      -- Get the count of IB lines for the quote_line_id (TQL_ID )
      CURSOR get_ib_lines_cnt_csr (
         p_tql_id   IN   NUMBER
      )
      IS
         SELECT COUNT (txd.ID) ib_lines_count
           FROM okl_txd_quote_line_dtls txd
          WHERE txd.tql_id = p_tql_id;

      -- Get the IB Lines for the quote_line_id (tql_id)
      CURSOR get_ib_lines_csr (
         p_tql_id   IN   NUMBER
      )
      IS
         SELECT txd.kle_id
           FROM okl_txd_quote_line_dtls txd
          WHERE txd.tql_id = p_tql_id;

      lx_txdv_tbl                okl_txd_assets_pub.adpv_tbl_type;
      lx_txlv_rec                okl_txl_assets_pub.tlpv_rec_type;
      lx_trxv_rec                okl_trx_assets_pub.thpv_rec_type;
      lx_cle_tbl                 okl_split_asset_pvt.cle_tbl_type;
      lx_sno_yn                  VARCHAR2 (3)                       := g_false;
      lx_clev_tbl                okl_okc_migration_pvt.clev_tbl_type;
      lp_ib_tbl                  okl_split_asset_pvt.ib_tbl_type;
      lp_empty_ib_tbl            okl_split_asset_pvt.ib_tbl_type;
      l_api_name        CONSTANT VARCHAR2 (30)             := 'do_split_asset';
      l_return_status            VARCHAR2 (1)             := g_ret_sts_success;
      cle_index                  NUMBER                                := 0;
      i                          NUMBER                                := 0;
      ib_id                      NUMBER                                := 0;
      l_module_name              VARCHAR2 (500)
                                          := g_module_name || 'do_split_asset';
      is_debug_exception_on      BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on      BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on      BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      --SECHAWLA 14-JAN-03 2748110 : New Declarations
      ib_line_id                 NUMBER                                := 0;
      id_exists                  VARCHAR2 (1);
      -- SECHAWLA 23-DEC-02 2484327 Added variable
      l_ib_lines_count           NUMBER;
      l_api_version     CONSTANT NUMBER                       := g_api_version;
      l_msg_count                NUMBER                          := g_miss_num;
      l_msg_data                 VARCHAR2 (2000);
      -- RMUNJULU 2757312 added
      lp_tqlv_tbl                okl_txl_quote_lines_pub.tqlv_tbl_type;
      lx_tqlv_tbl                okl_txl_quote_lines_pub.tqlv_tbl_type;
      l_new_asset_name           VARCHAR2 (2000);
      l_new_asset_quantity       NUMBER;

      -- RMUNJULU 2757312 added
      -- Get the asset name
      CURSOR get_asset_name_csr (
         p_kle_id   IN   NUMBER
      )
      IS
         SELECT kle.NAME NAME
           FROM okc_k_lines_v kle
          WHERE kle.ID = p_kle_id;

      -- RMUNJULU 2757312 added
      -- Get the ENTERED split trn
      -- RMUNJULU ASSETNUM INPUT 2757312
      -- Added txl.id to select
      CURSOR get_split_trn_csr (
         p_kle_id   IN   NUMBER
      )
      IS
         SELECT 'N',
                txl.ID
           FROM okl_txl_assets_b txl,
                okl_trx_assets trx,
                okc_k_lines_v kle_fin,
                okc_k_lines_v kle_fix,
                okc_line_styles_b lty_fin,
                okc_line_styles_b lty_fix
          WHERE txl.tal_type = 'ALI'
            AND trx.tsu_code = 'ENTERED'
            AND txl.tas_id = trx.ID
            AND kle_fin.lse_id = lty_fin.ID
            AND lty_fin.lty_code = 'FREE_FORM1'
            AND kle_fin.ID = kle_fix.cle_id
            AND kle_fix.lse_id = lty_fix.ID
            AND lty_fix.lty_code = 'FIXED_ASSET'
            AND txl.kle_id = kle_fix.ID
            AND kle_fin.ID = p_kle_id;

      -- RMUNJULU ASSETNUM INPUT 2757312
      -- Get the split asset
      CURSOR get_split_asset_csr (
         p_tal_id   IN   NUMBER
      )
      IS
         SELECT asset_number
           FROM okl_txd_assets_b
          WHERE tal_id = p_tal_id AND target_kle_id IS NULL;

      l_split_trn_processed_yn   VARCHAR2 (1)                          := 'Y';
      -- RMUNJULU ASSETNUM INPUT 2757312
      l_split_trn_id             NUMBER;
      l_split_asset              VARCHAR2 (400);
      l_asset_exists             VARCHAR2 (3);

      -- RMUNJULU ASSETNUM INPUT 2757312 Added function
      -- Function to check asset number is not duplicated
      FUNCTION asset_number_exists (
         p_asset_number   IN   VARCHAR2
      )
         RETURN VARCHAR2
      IS
         l_asset_exists   VARCHAR2 (1)   DEFAULT 'N';
         l_module_name    VARCHAR2 (500)
                                    := g_module_name || 'asset_number_exists';

         --chk for asset in FA
         CURSOR asset_chk_curs1 (
            p_asset_number   IN   VARCHAR2
         )
         IS
            SELECT 'Y' a
              FROM okx_assets_v okx
             WHERE okx.asset_number = p_asset_number;

         --chk for asset on asset line
         CURSOR asset_chk_curs2 (
            p_asset_number   IN   VARCHAR2
         )
         IS
            SELECT 'Y' a
              FROM okl_k_lines_full_v kle,
                   okc_line_styles_b lse
             WHERE kle.NAME = p_asset_number
               AND kle.lse_id = lse.ID
               AND lse.lty_code = 'FIXED_ASSET';
      BEGIN
         IF (is_debug_procedure_on)
         THEN
            okl_debug_pub.log_debug (g_level_procedure,
                                     l_module_name,
                                     'Begin(+)'
                                    );
         END IF;

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                        'In param, p_asset_number: '
                                     || p_asset_number
                                    );
         END IF;

         FOR asset_chk_rec1 IN asset_chk_curs1 (p_asset_number)
         LOOP
            l_asset_exists := asset_chk_rec1.a;

            IF l_asset_exists <> 'Y'
            THEN
               FOR asset_chk_rec2 IN asset_chk_curs2 (p_asset_number)
               LOOP
                  l_asset_exists := asset_chk_rec2.a;
               END LOOP;
            END IF;
         END LOOP;

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                        'Returning l_asset_exists: '
                                     || l_asset_exists
                                    );
         END IF;

         IF (is_debug_procedure_on)
         THEN
            okl_debug_pub.log_debug (g_level_procedure,
                                     l_module_name,
                                     'End(-)'
                                    );
         END IF;

         RETURN (l_asset_exists);
      EXCEPTION
         WHEN OTHERS
         THEN
            -- store SQL error message on message stack for caller
            okl_api.set_message (g_app_name,
                                 g_unexpected_error,
                                 g_sqlcode_token,
                                 SQLCODE,
                                 g_sqlerrm_token,
                                 SQLERRM
                                );

            IF (is_debug_exception_on)
            THEN
               okl_debug_pub.log_debug (g_level_exception,
                                        l_module_name,
                                           'EXCEPTION :'
                                        || 'OTHERS, SQLCODE: '
                                        || SQLCODE
                                        || ' , SQLERRM : '
                                        || SQLERRM
                                       );
            END IF;

            RETURN ('N');
      END asset_number_exists;
   BEGIN
      SAVEPOINT do_split_asset;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                   'In param, p_term_rec.p_contract_number: '
                                || p_term_rec.p_contract_number
                               );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                                  'In param, px_tcnv_rec.tmt_split_asset_yn: '
                               || px_tcnv_rec.tmt_split_asset_yn
                              );

         IF px_klev_tbl.COUNT > 0
         THEN
            FOR i IN px_klev_tbl.FIRST .. px_klev_tbl.LAST
            LOOP
               IF (px_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || px_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_asset_quantity: '
                                           || px_klev_tbl (i).p_asset_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || px_klev_tbl (i).p_asset_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_quote_quantity: '
                                           || px_klev_tbl (i).p_quote_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_tql_id: '
                                           || px_klev_tbl (i).p_tql_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, px_klev_tbl('
                                           || i
                                           || ').p_split_kle_name: '
                                           || px_klev_tbl (i).p_split_kle_name
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      x_return_status := okl_api.g_ret_sts_success;

      IF    (    p_trn_already_set = g_yes
             AND NVL (px_tcnv_rec.tmt_split_asset_yn, '?') <> g_yes
            )
         OR (p_trn_already_set = g_no)
      THEN
         IF px_klev_tbl.COUNT > 0
         THEN
            -- Loop thru financial assets
            FOR i IN px_klev_tbl.FIRST .. px_klev_tbl.LAST
            LOOP
               -- Check the trn if processed if processed then set tmt_split_asset_yn = y and do
               -- not do split, but how to get split_kle_id and update the quote with split_kle_id
               -- AND split_kle_name
               -- For financial asset line - get fixed asset line
               -- query for all trns in txl_assets for fixed asset line of tal_type 'ALI'
               -- see if the trx_assets trn is not in status other than processed
               OPEN get_split_trn_csr (px_klev_tbl (i).p_kle_id);

               FETCH get_split_trn_csr
                INTO l_split_trn_processed_yn,
                     l_split_trn_id;
                       -- RMUNJULU ASSETNUM INPUT 2757312 Added l_split_trn_id

               CLOSE get_split_trn_csr;

               -- If Not Processed Split Trn exists then our split trn is pending
               IF l_split_trn_processed_yn = 'N'
               THEN
                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                              'calling OKL_SPLIT_ASSET_PUB.split_fixed_asset'
                             );
                  END IF;

                  -- Process split asset transactions
                  okl_split_asset_pub.split_fixed_asset
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => g_false,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => l_msg_count,
                                          x_msg_data           => l_msg_data,
                                          p_cle_id             => px_klev_tbl
                                                                           (i).p_kle_id,
                                          x_cle_tbl            => lx_cle_tbl,
                                          p_source_call        => 'PARTIAL_TERM'
                                         );
                              -- sechawla 18-dec-07 - Split Asset Enhancements

                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                            'called OKL_SPLIT_ASSET_PUB.split_fixed_asset , return status: '
                         || x_return_status
                        );
                  END IF;

                  -- Try doing split for all split assets and get all errors
                  IF x_return_status <> okl_api.g_ret_sts_success
                  THEN
                     -- RMUNJULU ASSETNUM INPUT 2757312
                     -- Get the split asset from the split transaction
                     FOR get_split_asset_rec IN
                        get_split_asset_csr (l_split_trn_id)
                     LOOP
                        l_split_asset := get_split_asset_rec.asset_number;

                        IF (is_debug_statement_on)
                        THEN
                           okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                               'calling OKL_AM_CREATE_QUOTE_PVT.asset_number_exists'
                              );
                        END IF;

                        -- RMUNJULU 3241502 Call asset_number_exists from OKL_AM_CREATE_QUOTE_PVT
                        l_return_status :=
                           okl_am_create_quote_pvt.asset_number_exists
                                             (p_asset_number      => l_split_asset,
                                              x_asset_exists      => l_asset_exists);

                        IF (is_debug_statement_on)
                        THEN
                           okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                                  'called OKL_AM_CREATE_QUOTE_PVT.asset_number_exists , return status: '
                               || l_return_status
                              );
                        END IF;

                        -- Make sure new asset is not unique before throwing message saying so
                        IF l_asset_exists = 'Y'
                        THEN
                           -- New Asset Number NEW_ASSET_NUMBER is not unique. Please update the
                           -- New Asset Number for the Contract CONTRACT_NUMBER and Original
                           -- Asset Number ORIG_ASSET_NUMBER from the Split Asset screen.
                           okl_api.set_message
                              (p_app_name          => g_app_name,
                               p_msg_name          => 'OKL_AM_SPLIT_ASSET_ERROR',
                               p_token1            => 'NEW_ASSET_NUMBER',
                               p_token1_value      => l_split_asset,
                                            -- RMUNJULU ASSETNUM INPUT 2757312
                               p_token2            => 'CONTRACT_NUMBER',
                               p_token2_value      => p_term_rec.p_contract_number,
                               p_token3            => 'ORIG_ASSET_NUMBER',
                               p_token3_value      => px_klev_tbl (i).p_asset_name
                              );
                        END IF;
                     END LOOP;

                     -- Set Return status
                     l_return_status := x_return_status;
                  END IF;

                  IF x_return_status = okl_api.g_ret_sts_success
                  THEN
                     -- RMUNJULU 2757312 Added this IF
                     IF lx_cle_tbl.COUNT = 2
                     THEN
                        -- lx_cle_tbl returns 2 rows. One for the original kle id and
                        -- the other one for the split (new) kle_id
                        cle_index := lx_cle_tbl.FIRST;

                        IF lx_cle_tbl (cle_index).cle_id <>
                                                     px_klev_tbl (i).p_kle_id
                        THEN
                           -- split kle id is the first one in the table
                           px_klev_tbl (i).p_split_kle_id :=
                                                lx_cle_tbl (cle_index).cle_id;
                        ELSE
                           -- split kle id is the second one in the table
                           px_klev_tbl (i).p_split_kle_id :=
                                            lx_cle_tbl (cle_index + 1).cle_id;
                        END IF;
                     ELSE
                        -- Invalid value for x_cle_tbl.
                        okl_api.set_message (p_app_name          => g_app_name_1,
                                             p_msg_name          => g_invalid_value,
                                             p_token1            => g_col_name_token,
                                             p_token1_value      => 'x_cle_tbl'
                                            );
                        RAISE okl_api.g_exception_error;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         -- Raise Exception here after trying to do all splits
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++START
-- RMUNJULU 2757312 ADD code

         -- RMUNJULU Bug # 2484327 16-DEC-02
         -- Set the lp_tqlv_tbl and call OKL_TXL_QUOTE_LINES_PUB, set
         -- success messages
         IF px_klev_tbl.COUNT > 0
         THEN
            FOR i IN px_klev_tbl.FIRST .. px_klev_tbl.LAST
            LOOP
               -- Set the TXL_quote_lines rec to set the split_kle_id
               lp_tqlv_tbl (i).ID := px_klev_tbl (i).p_tql_id;
               lp_tqlv_tbl (i).split_kle_id := px_klev_tbl (i).p_split_kle_id;
            END LOOP;
         END IF;

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                    (g_level_statement,
                     l_module_name,
                     'calling OKL_TXL_QUOTE_LINES_PUB.update_txl_quote_lines'
                    );
         END IF;

         -- Call the TAPI to update TXL_quote_lines
         okl_txl_quote_lines_pub.update_txl_quote_lines
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_tqlv_tbl           => lp_tqlv_tbl,
                                           x_tqlv_tbl           => lx_tqlv_tbl
                                          );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_TXL_QUOTE_LINES_PUB.update_txl_quote_lines , return status: '
                || x_return_status
               );
         END IF;

         -- Raise exception to rollback to if error
         IF (x_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         IF px_klev_tbl.COUNT > 0
         THEN
            -- Set the success messages if successful split and update
            FOR i IN px_klev_tbl.FIRST .. px_klev_tbl.LAST
            LOOP
               OPEN get_asset_name_csr (px_klev_tbl (i).p_split_kle_id);

               FETCH get_asset_name_csr
                INTO l_new_asset_name;

               CLOSE get_asset_name_csr;

               l_new_asset_quantity :=
                    px_klev_tbl (i).p_asset_quantity
                  - px_klev_tbl (i).p_quote_quantity;
               -- Asset ASSET_NUMBER_OLD has been split. Asset ASSET_NUMBER_OLD
               -- retains quantity QUANTITY_OLD. New asset ASSET_NUMBER_NEW has
               -- been created with quantity QUANTITY_NEW.
               -- RMUNJULU 03-JAN-03 2683876 Changed msg token
               -- RMUNJULU 21-JAN-03 2760324 Removed additonal msg token
               okl_api.set_message
                           (p_app_name          => g_app_name,
                            p_msg_name          => 'OKL_AM_SPLIT_ASSET_MSG',
                            p_token1            => 'ASSET_NUMBER_OLD',
                            p_token1_value      => px_klev_tbl (i).p_asset_name,
                            p_token2            => 'QUANTITY_OLD',
                            p_token2_value      => px_klev_tbl (i).p_quote_quantity,
                            p_token3            => 'ASSET_NUMBER_NEW',
                            p_token3_value      => l_new_asset_name,
                            p_token4            => 'QUANTITY_NEW',
                            p_token4_value      => l_new_asset_quantity
                           );
            END LOOP;
         END IF;

         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_SPLIT_ASSET_YN',
                              p_tsu_code            => 'WORKING',
                              px_tcnv_rec           => px_tcnv_rec
                             );
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END
      END IF;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- SECHAWLA 23-DEC-02 2484327 Closed cursors if open
         IF get_ib_lines_cnt_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_cnt_csr;
         END IF;

         IF get_ib_lines_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_csr;
         END IF;

         -- close open cursors
         IF get_asset_name_csr%ISOPEN
         THEN
            CLOSE get_asset_name_csr;
         END IF;

         IF get_split_trn_csr%ISOPEN
         THEN
            CLOSE get_split_trn_csr;
         END IF;

         ROLLBACK TO do_split_asset;
         x_return_status := g_ret_sts_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_SPLIT_ASSET_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- SECHAWLA 23-DEC-02 2484327 Closed cursors if open
         IF get_ib_lines_cnt_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_cnt_csr;
         END IF;

         IF get_ib_lines_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_csr;
         END IF;

         -- close open cursors
         IF get_asset_name_csr%ISOPEN
         THEN
            CLOSE get_asset_name_csr;
         END IF;

         IF get_split_trn_csr%ISOPEN
         THEN
            CLOSE get_split_trn_csr;
         END IF;

         ROLLBACK TO do_split_asset;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_SPLIT_ASSET_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- SECHAWLA 23-DEC-02 2484327 Closed cursors if open
         IF get_ib_lines_cnt_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_cnt_csr;
         END IF;

         IF get_ib_lines_csr%ISOPEN
         THEN
            CLOSE get_ib_lines_csr;
         END IF;

         -- close open cursors
         IF get_asset_name_csr%ISOPEN
         THEN
            CLOSE get_asset_name_csr;
         END IF;

         IF get_split_trn_csr%ISOPEN
         THEN
            CLOSE get_split_trn_csr;
         END IF;

         ROLLBACK TO do_split_asset;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_SPLIT_ASSET_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END do_split_asset;

   -- Start of comments
   --
   -- Procedure Name : split_asset
   -- Desciption     : Checks if split asset needed ( if partial line qte)
   --                  Calls the do_split_asset if split asset needed and
   --                  sets the transaction properly
   -- Business Rules :
   -- Parameters     :
   -- Version      : 1.0
   -- History        : RMUNJULU Bug # 2484327 16-DEC-02, changed logic to set
   --                  split_tbl and call do_split_asset and updating TXL_quote_lines
   --                  and setting success messages
   --                  RMUNJULU 03-JAN-03 2683876 Changed msg token
   --                  RMUNJULU 21-JAN-03 2760324 Removed additonal msg token
   --                  RMUNJULU 2757312 MAJOR CHANGES to the whole procedure
   --                  will now call do_split_trn which will create + update split
   --                  trn and then call do_split_asset which will do split_asset
   --
   -- End of comments
   PROCEDURE split_asset (
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_klev_tbl          IN              klev_tbl_type,
      p_trn_already_set   IN              VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2,
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type,
      x_klev_tbl          OUT NOCOPY      klev_tbl_type,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      l_split_tbl              klev_tbl_type;
      i                        NUMBER;
      j                        NUMBER;
      l_return_status          VARCHAR2 (1)              := g_ret_sts_success;
      lp_tqlv_tbl              okl_txl_quote_lines_pub.tqlv_tbl_type;
      lx_tqlv_tbl              okl_txl_quote_lines_pub.tqlv_tbl_type;
      l_new_asset_name         VARCHAR2 (2000);
      l_new_asset_quantity     NUMBER;
      l_api_version   CONSTANT NUMBER                        := g_api_version;
      l_msg_count              NUMBER                           := g_miss_num;
      l_msg_data               VARCHAR2 (2000);
      l_module_name            VARCHAR2 (500)
                                            := g_module_name || 'split_asset';
      is_debug_exception_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      -- Start a savepoint to rollback to if error in this block
      SAVEPOINT split_asset;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                                  'In param, px_tcnv_rec.tmt_split_asset_yn: '
                               || px_tcnv_rec.tmt_split_asset_yn
                              );
         okl_debug_pub.log_debug
                            (g_level_statement,
                             l_module_name,
                                'In param, px_tcnv_rec.tmt_generic_flag1_yn: '
                             || px_tcnv_rec.tmt_generic_flag1_yn
                            );

         IF p_klev_tbl.COUNT > 0
         THEN
            FOR i IN p_klev_tbl.FIRST .. p_klev_tbl.LAST
            LOOP
               IF (p_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || p_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_quantity: '
                                           || p_klev_tbl (i).p_asset_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || p_klev_tbl (i).p_asset_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_quote_quantity: '
                                           || p_klev_tbl (i).p_quote_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_tql_id: '
                                           || p_klev_tbl (i).p_tql_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_split_kle_name: '
                                           || p_klev_tbl (i).p_split_kle_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_split_kle_id: '
                                           || p_klev_tbl (i).p_split_kle_id
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- if split asset step not done
      IF    (    p_trn_already_set = g_yes
             AND (   NVL (px_tcnv_rec.tmt_split_asset_yn, '?') <> g_yes
                  OR NVL (px_tcnv_rec.tmt_generic_flag1_yn, '?') <> g_yes
                 )
            )
         OR (p_trn_already_set = g_no)
      THEN
         -- For each asset check if split asset needs to be done
         -- only if quote qty < asset qty set the klev_tbl to be passed to
         -- split asset
         IF (p_klev_tbl.COUNT > 0)
         THEN
            i := p_klev_tbl.FIRST;
            j := 1;

            LOOP
               -- get the assets which needs to be splited into l_split_tbl
               -- RMUNJULU Bug # 2484327 16-DEC-02
               -- Removed the cursor access and setting of non_splited_tbl
               IF p_klev_tbl (i).p_quote_quantity <
                                              p_klev_tbl (i).p_asset_quantity
               THEN
                  l_split_tbl (j).p_kle_id := p_klev_tbl (i).p_kle_id;
                  l_split_tbl (j).p_asset_quantity :=
                                              p_klev_tbl (i).p_asset_quantity;
                  l_split_tbl (j).p_asset_name := p_klev_tbl (i).p_asset_name;
                  l_split_tbl (j).p_quote_quantity :=
                                              p_klev_tbl (i).p_quote_quantity;
                  l_split_tbl (j).p_tql_id := p_klev_tbl (i).p_tql_id;
                  l_split_tbl (j).p_split_kle_id :=
                                                p_klev_tbl (i).p_split_kle_id;
                  -- RMUNJULU 2757312
                  l_split_tbl (j).p_split_kle_name :=
                                              p_klev_tbl (i).p_split_kle_name;
                  j := j + 1;
               END IF;

               EXIT WHEN (i = p_klev_tbl.LAST);
               i := p_klev_tbl.NEXT (i);
            END LOOP;
         END IF;

         -- If l_split_tbl is not empty then we do need to do split asset -- IE - Partial Line
         IF (l_split_tbl.COUNT > 0)
         THEN
            -- RMUNJULU 3018641 Step Message
            -- Step : Split Asset
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_STEP_SPL');
            -- Call the do_split_asset_trn with the l_split_tbl
            do_split_asset_trn (p_term_rec             => p_term_rec,
                                p_sys_date             => p_sys_date,
                                p_trn_already_set      => p_trn_already_set,
                                px_overall_status      => px_overall_status,
                                px_tcnv_rec            => px_tcnv_rec,
                                px_klev_tbl            => l_split_tbl,
                                x_return_status        => l_return_status
                               );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                            (g_level_statement,
                             l_module_name,
                                'called do_split_asset_trn , return status: '
                             || l_return_status
                            );
            END IF;

            IF l_return_status <> g_ret_sts_success
            THEN
               -- Split asset failed.
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_AM_ERR_SPLIT_ASST');
               x_return_status := l_return_status;
            END IF;

            IF l_return_status = g_ret_sts_success
            THEN
               -- Call the do_split_asset with the l_split_tbl
               do_split_asset (p_term_rec             => p_term_rec,
                               p_sys_date             => p_sys_date,
                               p_trn_already_set      => p_trn_already_set,
                               px_overall_status      => px_overall_status,
                               px_tcnv_rec            => px_tcnv_rec,
                               px_klev_tbl            => l_split_tbl,
                               x_return_status        => l_return_status
                              );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'called do_split_asset , return status: '
                                 || l_return_status
                                );
               END IF;

               IF l_return_status <> g_ret_sts_success
               THEN
                  -- Split asset failed.
                  okl_api.set_message (p_app_name      => g_app_name,
                                       p_msg_name      => 'OKL_AM_ERR_SPLIT_ASST');
                  x_return_status := l_return_status;
               END IF;
            END IF;
         ELSE
            --( no need for split asset since no partial line )

            -- set the transaction record
            set_transaction_rec (p_return_status       => l_return_status,
                                 p_overall_status      => px_overall_status,
                                 p_tmt_flag            => 'TMT_GENERIC_FLAG1_YN',
                                 p_tsu_code            => 'WORKING',
                                 p_ret_val             => NULL,
                                 px_tcnv_rec           => px_tcnv_rec
                                );
            -- set the transaction record
            set_transaction_rec (p_return_status       => l_return_status,
                                 p_overall_status      => px_overall_status,
                                 p_tmt_flag            => 'TMT_SPLIT_ASSET_YN',
                                 p_tsu_code            => 'WORKING',
                                 p_ret_val             => NULL,
                                 px_tcnv_rec           => px_tcnv_rec
                                );
         END IF;
      END IF;

      -- Set the return status
      x_return_status := l_return_status;
      -- Set the return klev_tbl
      x_klev_tbl := p_klev_tbl;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         ROLLBACK TO split_asset;
         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         ROLLBACK TO split_asset;
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         ROLLBACK TO split_asset;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END split_asset;

   -- Start of comments
   --
   -- Procedure Name : close_streams
   -- Desciption     : Checks if any active streams for the assets and closes
   -- Business Rules :
   -- Parameters     :
   -- Version    : 1.0
   -- History        : RMUNJULU 28-MAR-03 2877278 Changed the cursor and code
   --                  to get only CURRENT streams and HISTORIZE them
   --
   -- End of comments
   PROCEDURE close_streams (
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_klev_tbl          IN              klev_tbl_type,
      p_trn_already_set   IN              VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2,
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      -- Cursor to get the active streams of the asset
      -- RMUNJULU 28-MAR-03 2877278 Added conditions to pick only CURRENT
      -- streams.
      CURSOR k_streams_csr (
         p_kle_id   IN   NUMBER
      )
      IS
         SELECT stm.ID ID
           FROM okl_streams_v stm
          WHERE stm.kle_id = p_kle_id AND stm.say_code = 'CURR';

      k_streams_rec            k_streams_csr%ROWTYPE;
      l_return_status          VARCHAR2 (1)               := g_ret_sts_success;
      lp_stmv_tbl              okl_streams_pub.stmv_tbl_type;
      lx_stmv_tbl              okl_streams_pub.stmv_tbl_type;
      l_streams_found          VARCHAR2 (1)                  := g_no;
      i                        NUMBER;
      j                        NUMBER;
      l_id                     NUMBER;
      l_api_version   CONSTANT NUMBER                        := g_api_version;
      l_msg_count              NUMBER                        := g_miss_num;
      l_msg_data               VARCHAR2 (2000);
      l_module_name            VARCHAR2 (500)
                                           := g_module_name || 'close_streams';
      is_debug_exception_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      -- Start a savepoint to rollback to if error in this block
      SAVEPOINT close_streams;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                          (g_level_statement,
                           l_module_name,
                              'In param, px_tcnv_rec.tmt_streams_updated_yn: '
                           || px_tcnv_rec.tmt_streams_updated_yn
                          );

         IF p_klev_tbl.COUNT > 0
         THEN
            FOR i IN p_klev_tbl.FIRST .. p_klev_tbl.LAST
            LOOP
               IF (p_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || p_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_quantity: '
                                           || p_klev_tbl (i).p_asset_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || p_klev_tbl (i).p_asset_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_quote_quantity: '
                                           || p_klev_tbl (i).p_quote_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_tql_id: '
                                           || p_klev_tbl (i).p_tql_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_split_kle_name: '
                                           || p_klev_tbl (i).p_split_kle_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_split_kle_id: '
                                           || p_klev_tbl (i).p_split_kle_id
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- for each line check if streams exists
      IF (p_klev_tbl.COUNT > 0)
      THEN
         i := p_klev_tbl.FIRST;

         LOOP
            -- check if streams exists
            OPEN k_streams_csr (p_klev_tbl (i).p_kle_id);

            FETCH k_streams_csr
             INTO l_id;

            IF k_streams_csr%FOUND
            THEN
               l_streams_found := g_yes;
            END IF;

            CLOSE k_streams_csr;

            EXIT WHEN (i = p_klev_tbl.LAST);
            i := p_klev_tbl.NEXT (i);
         END LOOP;
      END IF;

      -- if close streams need to be done
      IF    (    p_trn_already_set = g_yes
             AND NVL (px_tcnv_rec.tmt_streams_updated_yn, '?') <> g_yes
            )
         OR (p_trn_already_set = g_no)
      THEN
         -- if streams found then
         IF (l_streams_found = g_yes)
         THEN
            j := 1;

            -- Loop thru the lines table
            IF (p_klev_tbl.COUNT > 0)
            THEN
               i := p_klev_tbl.FIRST;

               LOOP
                  -- for each line's streams set the tbl type for streams pub
                  FOR k_streams_rec IN k_streams_csr (p_klev_tbl (i).p_kle_id)
                  LOOP
                     lp_stmv_tbl (j).khr_id := p_term_rec.p_contract_id;
                     lp_stmv_tbl (j).active_yn := g_no;
                     lp_stmv_tbl (j).ID := k_streams_rec.ID;
                     lp_stmv_tbl (j).kle_id := p_klev_tbl (i).p_kle_id;
                     -- RMUNJULU 28-MAR-03 2877278 Added code to set say_code to HIST
                     lp_stmv_tbl (j).say_code := 'HIST';
                     lp_stmv_tbl (j).date_history := SYSDATE;
                     j := j + 1;
                  END LOOP;

                  EXIT WHEN (i = p_klev_tbl.LAST);
                  i := p_klev_tbl.NEXT (i);
               END LOOP;
            END IF;

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                     'calling OKL_STREAMS_PUB.update_streams'
                                    );
            END IF;

            -- close streams
            okl_streams_pub.update_streams
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_stmv_tbl           => lp_stmv_tbl,
                                           x_stmv_tbl           => lx_stmv_tbl
                                          );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_STREAMS_PUB.update_streams , return status: '
                   || l_return_status
                  );
            END IF;

            IF l_return_status <> g_ret_sts_success
            THEN
               -- Streams table update failed.
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_AM_ERR_UPD_STREAMS');
            END IF;

            -- Raise exception to rollback to if error
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            -- store the highest degree of error
            set_overall_status (p_return_status        => l_return_status,
                                px_overall_status      => px_overall_status);
            -- set the transaction record
            set_transaction_rec (p_return_status       => l_return_status,
                                 p_overall_status      => px_overall_status,
                                 p_tmt_flag            => 'TMT_STREAMS_UPDATED_YN',
                                 p_tsu_code            => 'WORKING',
                                 px_tcnv_rec           => px_tcnv_rec
                                );
         ELSE
            --( no streams found )

            -- No future billable streams found.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_NO_STREAMS');
            -- set the transaction record
            set_transaction_rec (p_return_status       => l_return_status,
                                 p_overall_status      => px_overall_status,
                                 p_tmt_flag            => 'TMT_STREAMS_UPDATED_YN',
                                 p_tsu_code            => 'WORKING',
                                 p_ret_val             => NULL,
                                 px_tcnv_rec           => px_tcnv_rec
                                );
         END IF;
      END IF;

      -- Set the return status
      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- Close any open cursors
         IF k_streams_csr%ISOPEN
         THEN
            CLOSE k_streams_csr;
         END IF;

         ROLLBACK TO close_streams;
         x_return_status := g_ret_sts_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_STREAMS_UPDATED_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- Close any open cursors
         IF k_streams_csr%ISOPEN
         THEN
            CLOSE k_streams_csr;
         END IF;

         ROLLBACK TO close_streams;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_STREAMS_UPDATED_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- Close any open cursors
         IF k_streams_csr%ISOPEN
         THEN
            CLOSE k_streams_csr;
         END IF;

         ROLLBACK TO close_streams;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_STREAMS_UPDATED_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END close_streams;

   -- Start of comments
   --
   -- Procedure Name : accounting_entries
   -- Desciption     : Does the accounting entries for the assets
   -- Business Rules :
   -- Parameters     :
   -- Version      : 1.0
   -- History        : RMUNJULU 23-DEC-02 2726739 Added code for Multi-Currency settings
   --                : RMUNJULU Bug # 3023206 27-JUN-03 Increment the line number before the exit
   --                  to avoid duplicate line numbers when creating accnting transaction lines
   --                : RMUNJULU Bug # 2902876 23-JUL-03 Added code to pass valid GL date to GET_TEMPLATE_INFO
   --                : RMUNJULU 3138794 Added code to pass kle_id to Accounting Engine
   --                : RMUNJULU 28-APR-04 3596626 Added code to set lp_acc_gen_primary_key_tbl
   --
   --                : SMODUGA  3061772 Added call to process_discount_subsidy
   --                : rmunjulu EDAT Added code to pass quote accpt date as accounting date
   --                  also passing the contract_id, quote_id, quote_accept_date and line_id to accounting engine
   --                : rmunjulu EDAT 29-Dec-04 did to_char to convert to right format
   --                : akrangan Bug 5514059 - During termination, do accounting for asset, fees and service
   --                : akrangan SLA Single Accounting Engine Call Uptake
   -- End of comments
   PROCEDURE accounting_entries (
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_klev_tbl          IN              klev_tbl_type,
      p_trn_already_set   IN              VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2,
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      -- Cursor to get the product of the contract
      CURSOR prod_id_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT khr.pdt_id pdt_id,
                CHR.scs_code                               -- rmunjulu 4622198
                            ,
                CHR.org_id                  --akrangan added for sla ae uptake
           FROM okl_k_headers_v khr,
                okc_k_headers_b CHR                        -- rmunjulu 4622198
          WHERE khr.ID = p_khr_id AND khr.ID = CHR.ID;     -- rmunjulu 4622198

      -- Get the product type
      CURSOR l_product_type_csr (
         p_pdt_id   IN   NUMBER
      )
      IS
         SELECT prd.description description
           FROM okl_products_v prd
          WHERE prd.ID = p_pdt_id;

      l_return_status              VARCHAR2 (1)           := g_ret_sts_success;
      l_pdt_id                     NUMBER                                 := 0;
      l_try_id                     NUMBER;
      lp_tmpl_identify_rec         okl_account_dist_pub.tmpl_identify_rec_type;
      lp_dist_info_rec             okl_account_dist_pub.dist_info_rec_type;
      lp_ctxt_val_tbl              okl_account_dist_pub.ctxt_val_tbl_type;
      lp_acc_gen_primary_key_tbl   okl_account_dist_pub.acc_gen_primary_key;
      lx_template_tbl              okl_account_dist_pub.avlv_tbl_type;
      lx_amount_tbl                okl_account_dist_pub.amount_tbl_type;
      lx_tcnv_tbl                  okl_trx_contracts_pub.tcnv_tbl_type;
      lx_tclv_tbl                  okl_trx_contracts_pub.tclv_tbl_type;
      l_catchup_rec                okl_generate_accruals_pub.accrual_rec_type;
      l_lprv_rec                   okl_rev_loss_prov_pub.lprv_rec_type;
      l_trans_meaning              VARCHAR2 (200);
      l_module_name                VARCHAR2 (500)
                                      := g_module_name || 'accounting_entries';
      is_debug_exception_on        BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on        BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on        BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      lp_tclv_rec                  okl_trx_contracts_pub.tclv_rec_type;
      lx_tclv_rec                  okl_trx_contracts_pub.tclv_rec_type;
      li_tclv_rec                  okl_trx_contracts_pub.tclv_rec_type;
      i                            NUMBER;
      l_total_amount               NUMBER                                 := 0;
      lip_tmpl_identify_rec        okl_account_dist_pub.tmpl_identify_rec_type;
      lix_template_tbl             okl_account_dist_pub.avlv_tbl_type;
      lip_tcnv_rec                 tcnv_rec_type;
      lix_tcnv_rec                 tcnv_rec_type;
      l_product_type               VARCHAR2 (2000);
      l_line_number                NUMBER                                 := 1;
      j                            NUMBER;
      l_api_version       CONSTANT NUMBER                     := g_api_version;
      l_msg_count                  NUMBER                        := g_miss_num;
      l_msg_data                   VARCHAR2 (2000);
      -- RMUNJULU 23-DEC-02 2726739 Added variables
      l_functional_currency_code   VARCHAR2 (15);
      l_contract_currency_code     VARCHAR2 (15);
      l_currency_conversion_type   VARCHAR2 (30);
      l_currency_conversion_rate   NUMBER;
      l_currency_conversion_date   DATE;
      l_converted_amount           NUMBER;
      -- Since we do not use the amount or converted amount
      -- set a hardcoded value for the amount (and pass to to
      -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
      -- conversion values )
      l_hard_coded_amount          NUMBER                               := 100;
      -- Bug 2902876
      l_valid_gl_date              DATE;
      -- rmunjulu EDAT
      l_quote_accpt_date           DATE;
      l_quote_eff_date             DATE;
      -- rmunjulu 4622198
      l_scs_code                   okc_k_headers_b.scs_code%TYPE;
      l_fact_synd_code             fnd_lookups.lookup_code%TYPE;
      l_inv_acct_code              okc_rules_b.rule_information1%TYPE;

      --akrangan Bug 5514059 start
      -- Used to get Assets selected for termination and
      -- Fee and Sold Service lines associated to the assets
      CURSOR k_asst_fee_srvc_lns_csr (
         p_chr_id   IN   okc_k_headers_b.ID%TYPE,
         p_qte_id   IN   okc_k_lines_b.ID%TYPE
      )
      IS
         SELECT cle.ID cle_id
           FROM okc_k_lines_b cle,
                okl_txl_quote_lines_b tql
          WHERE tql.qte_id = p_qte_id
            AND tql.qlt_code = 'AMCFIA'
            AND tql.kle_id = cle.ID
         UNION
         SELECT DISTINCT hdrcle.ID cle_id
                    FROM okc_k_lines_b cle,
                         okc_k_lines_b hdrcle,
                         okc_k_items cim,
                         okl_txl_quote_lines_b tql,
                         okc_k_headers_b CHR,
                         okc_line_styles_b lse
                   WHERE hdrcle.chr_id = p_chr_id
                     AND cle.cle_id = hdrcle.ID
                     AND cim.dnz_chr_id = cle.dnz_chr_id
                     AND cim.jtot_object1_code = 'OKX_COVASST'
                     AND cim.cle_id = cle.ID
                     AND cim.object1_id1 = tql.kle_id
                     AND tql.qte_id = p_qte_id
                     AND tql.qlt_code = 'AMCFIA'
                     AND hdrcle.lse_id = lse.ID
                     AND lse.lty_code IN ('FEE', 'SOLD_SERVICE')
                     AND hdrcle.chr_id = CHR.ID
                     AND hdrcle.sts_code = CHR.sts_code;

      --akrangan Bug 5514059 end
      --akrangan sla single accounting call to ae uptake starts
      l_org_id                     NUMBER (15);
      --txl contracts specific tbl types
      l_tclv_tbl                   okl_trx_contracts_pub.tclv_tbl_type;
      --ae new table types declaration
      l_tmpl_identify_tbl          okl_account_dist_pvt.tmpl_identify_tbl_type;
      l_dist_info_tbl              okl_account_dist_pvt.dist_info_tbl_type;
      l_ctxt_tbl                   okl_account_dist_pvt.ctxt_tbl_type;
      l_template_out_tbl           okl_account_dist_pvt.avlv_out_tbl_type;
      l_amount_out_tbl             okl_account_dist_pvt.amount_out_tbl_type;
      l_acc_gen_tbl                okl_account_dist_pvt.acc_gen_tbl_type;
      l_tcn_id                     NUMBER;

      --hdr dff fields cursor
      --this cursor is to populate the
      -- desc flex fields columns in okl_trx_contracts
      CURSOR trx_contracts_dff_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15
           FROM okl_k_headers okl
          WHERE okl.ID = p_khr_id;

      --line dff fields cursor
      --this cursor is to populate the
      -- desc flex fields columns in okl_txl_xontract_lines_b
      CURSOR txl_contracts_dff_csr (
         p_kle_id   IN   NUMBER
      )
      IS
         SELECT attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15
           FROM okl_k_lines okl
          WHERE okl.ID = p_kle_id;

      --record for storing okl_k_lines dffs and linked assets cle_id
      TYPE dff_rec_type IS RECORD (
         attribute_category   okl_k_lines.attribute_category%TYPE,
         attribute1           okl_k_lines.attribute1%TYPE,
         attribute2           okl_k_lines.attribute2%TYPE,
         attribute3           okl_k_lines.attribute3%TYPE,
         attribute4           okl_k_lines.attribute4%TYPE,
         attribute5           okl_k_lines.attribute5%TYPE,
         attribute6           okl_k_lines.attribute6%TYPE,
         attribute7           okl_k_lines.attribute7%TYPE,
         attribute8           okl_k_lines.attribute8%TYPE,
         attribute9           okl_k_lines.attribute9%TYPE,
         attribute10          okl_k_lines.attribute10%TYPE,
         attribute11          okl_k_lines.attribute11%TYPE,
         attribute12          okl_k_lines.attribute12%TYPE,
         attribute13          okl_k_lines.attribute13%TYPE,
         attribute14          okl_k_lines.attribute14%TYPE,
         attribute15          okl_k_lines.attribute15%TYPE
      );

      txl_contracts_dff_rec        dff_rec_type;

      --product name and tax owner
      CURSOR product_name_csr (
         p_pdt_id   IN   NUMBER
      )
      IS
         SELECT NAME,
                tax_owner
           FROM okl_product_parameters_v
          WHERE ID = p_pdt_id;

      l_currency_code              okl_trx_contracts.currency_code%TYPE;
      --loop variables
      k                            NUMBER;
      l                            NUMBER;
      m                            NUMBER;
   --akrangan sla single accounting call to ae uptake ends
   BEGIN


      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_tcnv_rec.try_id: '
                                  || px_tcnv_rec.try_id
                                 );
         okl_debug_pub.log_debug
                       (g_level_statement,
                        l_module_name,
                           'In param, px_tcnv_rec.tmt_accounting_entries_yn: '
                        || px_tcnv_rec.tmt_accounting_entries_yn
                       );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_tcnv_rec.id: '
                                  || px_tcnv_rec.ID
                                 );
      END IF;

      -- Logic

      --Check the product id
      --If product_id NULL Then
      --   Error and Exit
      --End if

      --Get Templates for product ( get sty_id)
      --If no templates found Then
      --   Error and Exit
      --End If

      --Loop thru templates
      --   Loop thru lines
      --     Create TXL Line ( with kle_id)
      --     Do Accnt entries (get back amt)
      --     Update TXL Line (for amt)
      --     Increment total amt
      --     Increment line number
      --   End Loop
      --End Loop
      --Update TRX header with total amt

      -- Start savepoint for this block
      SAVEPOINT accounting_entries;

      -- get the product id
      OPEN prod_id_csr (p_term_rec.p_contract_id);

      FETCH prod_id_csr
       INTO l_pdt_id,
            l_scs_code,
            l_org_id;                                      -- rmunjulu 4622198

      CLOSE prod_id_csr;

      -- CHECK PRODUCT ID

      -- raise error if no pdt_id
      IF l_pdt_id IS NULL OR l_pdt_id = 0
      THEN
         -- Error: Unable to create accounting entries because of a missing
         -- Product Type for the contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_PRODUCT_ID_ERROR',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      -- get the product type
      OPEN l_product_type_csr (l_pdt_id);

      FETCH l_product_type_csr
       INTO l_product_type;

      CLOSE l_product_type_csr;

      -- If accounting entries needed
      IF    (    p_trn_already_set = g_yes
             AND NVL (px_tcnv_rec.tmt_accounting_entries_yn, '?') <> g_yes
            )
         OR (p_trn_already_set = g_no)
      THEN
         -- RMUNJULU 3018641 Step Message
         -- Step : Accounting Entries
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_AM_STEP_ACT');

         -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

         -- rmunjulu EDAT
         -- If quote exists then accnting date is quote accept date else sysdate
         IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
         THEN
            l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
            l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
         ELSE
            l_quote_accpt_date := p_sys_date;
            l_quote_eff_date := p_sys_date;
         END IF;

         -- rmunjulu EDAT
         -- set the additional parameters with contract_id, quote_id and transaction_date
         -- to be passed to formula engine
         lp_ctxt_val_tbl (1).NAME := 'contract_id';
         lp_ctxt_val_tbl (1).VALUE := p_term_rec.p_contract_id;
         lp_ctxt_val_tbl (2).NAME := 'quote_id';
         lp_ctxt_val_tbl (2).VALUE := p_term_rec.p_quote_id;
         lp_ctxt_val_tbl (3).NAME := 'transaction_date';
         lp_ctxt_val_tbl (3).VALUE :=
                                    TO_CHAR (l_quote_accpt_date, 'MM/DD/YYYY');
             -- rmunjulu EDAT 29-Dec-04 did to_char to convert to right format
         -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

         -- GET TEMPLATES

         -- Get the meaning of lookup
         l_trans_meaning :=
            okl_am_util_pvt.get_lookup_meaning
                                (p_lookup_type      => 'OKL_ACCOUNTING_EVENT_TYPE',
                                 p_lookup_code      => 'TERMINATION',
                                 p_validate_yn      => 'Y'
                                );
         -- Set the tmpl_identify_rec in parameter to get
         -- accounting templates for the product
         lip_tmpl_identify_rec.product_id := l_pdt_id;
         lip_tmpl_identify_rec.transaction_type_id := px_tcnv_rec.try_id;
         lip_tmpl_identify_rec.memo_yn := g_no;
         lip_tmpl_identify_rec.prior_year_yn := g_no;
         -- Bug 2902876 Added to get the valid GL date
         l_valid_gl_date :=
            okl_accounting_util.get_valid_gl_date
                                              (p_gl_date      => l_quote_accpt_date);
                                                              -- rmunjulu EDAT

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                    (g_level_statement,
                     l_module_name,
                     'calling okl_securitization_pvt.check_khr_ia_associated'
                    );
         END IF;

         -- rmunjulu 4622198 SPECIAL_ACCNT Get special accounting details
         okl_securitization_pvt.check_khr_ia_associated
                                        (p_api_version         => l_api_version,
                                         p_init_msg_list       => okl_api.g_false,
                                         x_return_status       => l_return_status,
                                         x_msg_count           => l_msg_count,
                                         x_msg_data            => l_msg_data,
                                         p_khr_id              => p_term_rec.p_contract_id,
                                         p_scs_code            => l_scs_code,
                                         p_trx_date            => l_quote_accpt_date,
                                         x_fact_synd_code      => l_fact_synd_code,
                                         x_inv_acct_code       => l_inv_acct_code
                                        );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called okl_securitization_pvt.check_khr_ia_associated , return status: '
                || l_return_status
               );
         END IF;

         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- rmunjulu 4622198 SPECIAL_ACCNT set the special accounting parameters
         lip_tmpl_identify_rec.factoring_synd_flag := l_fact_synd_code;
         lip_tmpl_identify_rec.investor_code := l_inv_acct_code;

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                            (g_level_statement,
                             l_module_name,
                             'calling okl_account_dist_pub.get_template_info'
                            );
         END IF;

         -- Get the accounting templates
         okl_account_dist_pub.get_template_info
                                (p_api_version            => l_api_version,
                                 p_init_msg_list          => g_false,
                                 x_return_status          => l_return_status,
                                 x_msg_count              => l_msg_count,
                                 x_msg_data               => l_msg_data,
                                 p_tmpl_identify_rec      => lip_tmpl_identify_rec,
                                 x_template_tbl           => lix_template_tbl,
                                 p_validity_date          => l_valid_gl_date
                                );  -- Bug 2902876 Added to pass valid GL date

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called okl_account_dist_pub.get_template_info , return status: '
                || l_return_status
               );
         END IF;

         IF l_return_status <> g_ret_sts_success
         THEN
            -- No accounting templates found matching the transaction type
            -- TRX_TYPE and product  PRODUCT.
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_NO_ACC_TEMPLATES',
                                 p_token1            => 'TRX_TYPE',
                                 p_token1_value      => l_trans_meaning,
                                 p_token2            => 'PRODUCT',
                                 p_token2_value      => l_product_type
                                );
         END IF;

         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- If no templates present
         IF lix_template_tbl.COUNT = 0
         THEN
            -- No accounting templates found matching the transaction type
            -- TRX_TYPE and product  PRODUCT.
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_NO_ACC_TEMPLATES',
                                 p_token1            => 'TRX_TYPE',
                                 p_token1_value      => l_trans_meaning,
                                 p_token2            => 'PRODUCT',
                                 p_token2_value      => l_product_type
                                );
            RAISE okl_api.g_exception_error;
         END IF;

-- ******************
-- CURRENCY CONVERSION OPERATIONS
-- ******************
         l_currency_code :=
                   okl_am_util_pvt.get_chr_currency (p_term_rec.p_contract_id);
         l_functional_currency_code :=
                                    okl_am_util_pvt.get_functional_currency
                                                                           ();

         --akrangan Bug 6147049 code fix start
         --call functional currency conversion only
         --if functional currency and contract currency are not same
         IF     l_functional_currency_code IS NOT NULL
            AND l_functional_currency_code <> l_currency_code
         THEN
            --akrangan Bug 6147049 code fix end
            -- Get the currency conversion details from ACCOUNTING_Util
            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                   'calling okl_accounting_util.convert_to_functional_currency'
                  );
            END IF;

            okl_accounting_util.convert_to_functional_currency
                    (p_khr_id                        => p_term_rec.p_contract_id,
                     p_to_currency                   => l_functional_currency_code,
                     p_transaction_date              => l_quote_accpt_date,
                                                              -- rmunjulu EDAT
                     p_amount                        => l_hard_coded_amount,
                     x_return_status                 => l_return_status,
                     x_contract_currency             => l_contract_currency_code,
                     x_currency_conversion_type      => l_currency_conversion_type,
                     x_currency_conversion_rate      => l_currency_conversion_rate,
                     x_currency_conversion_date      => l_currency_conversion_date,
                     x_converted_amount              => l_converted_amount
                    );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called okl_accounting_util.convert_to_functional_currency , return status: '
                   || l_return_status
                  );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_contract_currency_code: '
                                        || l_contract_currency_code
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_currency_conversion_type: '
                                        || l_currency_conversion_type
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_currency_conversion_rate: '
                                        || l_currency_conversion_rate
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_currency_conversion_date: '
                                        || l_currency_conversion_date
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_converted_amount: '
                                        || l_converted_amount
                                       );
            END IF;

            -- If error from OKL_ACCOUNTING_UTIL
            IF l_return_status <> okl_api.g_ret_sts_success
            THEN
               -- Error occurred when creating accounting entries for
               -- transaction TRX_TYPE.
               okl_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKL_AM_ERR_ACC_ENT',
                                    p_token1            => 'TRX_TYPE',
                                    p_token1_value      => l_trans_meaning
                                   );
            END IF;

            -- Raise exception to rollback to savepoint for this block
            IF (l_return_status = okl_api.g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;
         --akrangan Bug 6147049 code fix start
         END IF;

--akrangan Bug 6147049 code fix end
-- *****************************
-- CREATE TXL_CNTRCT LINES
-- ****************************
-- currency operations related variables assigned
         --Start fix for bug 7204083
         l_currency_code := NVL(l_contract_currency_code, l_currency_code);
         --End fix for bug 7204083
         j := 1;
         --looping thru the templates to set line records and template identify tbl
         i := lix_template_tbl.FIRST;
                        -- at this point we know that there are some templates

         LOOP
            -- Loop thru templates
            FOR k_asst_fee_srvc_lns_rec IN
               k_asst_fee_srvc_lns_csr (p_term_rec.p_contract_id,
                                        p_term_rec.p_quote_id)
            LOOP
               -- set the TXL_CNTRCT Line details for template
               l_tclv_tbl (j).line_number := l_line_number;
               l_tclv_tbl (j).khr_id := p_term_rec.p_contract_id;
               l_tclv_tbl (j).tcn_id := px_tcnv_rec.ID;
               l_tclv_tbl (j).sty_id := lix_template_tbl (i).sty_id;
               l_tclv_tbl (j).tcl_type := 'ALT';
               l_tclv_tbl (j).currency_code := l_currency_code;
               l_tclv_tbl (j).kle_id := k_asst_fee_srvc_lns_rec.cle_id;
               l_tclv_tbl (j).org_id := l_org_id;

               FOR txl_contracts_dff_rec IN
                  txl_contracts_dff_csr (k_asst_fee_srvc_lns_rec.cle_id)
               LOOP
                  --set dffs
                  l_tclv_tbl (j).attribute_category :=
                                     txl_contracts_dff_rec.attribute_category;
                  l_tclv_tbl (j).attribute1 :=
                                             txl_contracts_dff_rec.attribute1;
                  l_tclv_tbl (j).attribute2 :=
                                             txl_contracts_dff_rec.attribute2;
                  l_tclv_tbl (j).attribute3 :=
                                             txl_contracts_dff_rec.attribute3;
                  l_tclv_tbl (j).attribute4 :=
                                             txl_contracts_dff_rec.attribute4;
                  l_tclv_tbl (j).attribute5 :=
                                             txl_contracts_dff_rec.attribute5;
                  l_tclv_tbl (j).attribute6 :=
                                             txl_contracts_dff_rec.attribute6;
                  l_tclv_tbl (j).attribute7 :=
                                             txl_contracts_dff_rec.attribute7;
                  l_tclv_tbl (j).attribute8 :=
                                             txl_contracts_dff_rec.attribute8;
                  l_tclv_tbl (j).attribute9 :=
                                             txl_contracts_dff_rec.attribute9;
                  l_tclv_tbl (j).attribute10 :=
                                            txl_contracts_dff_rec.attribute10;
                  l_tclv_tbl (j).attribute11 :=
                                            txl_contracts_dff_rec.attribute11;
                  l_tclv_tbl (j).attribute12 :=
                                            txl_contracts_dff_rec.attribute12;
                  l_tclv_tbl (j).attribute13 :=
                                            txl_contracts_dff_rec.attribute13;
                  l_tclv_tbl (j).attribute14 :=
                                            txl_contracts_dff_rec.attribute14;
                  l_tclv_tbl (j).attribute15 :=
                                            txl_contracts_dff_rec.attribute15;
               END LOOP;

               -- This will calculate the amount and generate accounting entries
               -- Set the tmpl_identify_tbl in parameter
               l_tmpl_identify_tbl (j).product_id := l_pdt_id;
               l_tmpl_identify_tbl (j).transaction_type_id :=
                                                            px_tcnv_rec.try_id;
               l_tmpl_identify_tbl (j).memo_yn := g_no;
               l_tmpl_identify_tbl (j).prior_year_yn := g_no;
               l_tmpl_identify_tbl (j).stream_type_id :=
                                                   lix_template_tbl (i).sty_id;
               l_tmpl_identify_tbl (j).advance_arrears :=
                                          lix_template_tbl (i).advance_arrears;
               l_tmpl_identify_tbl (j).factoring_synd_flag :=
                                      lix_template_tbl (i).factoring_synd_flag;
               l_tmpl_identify_tbl (j).investor_code :=
                                                 lix_template_tbl (i).inv_code;
               l_tmpl_identify_tbl (j).syndication_code :=
                                                 lix_template_tbl (i).syt_code;
               l_tmpl_identify_tbl (j).factoring_code :=
                                                 lix_template_tbl (i).fac_code;
               --increment looping variable
               j := j + 1;
               --increment line number
               l_line_number := l_line_number + 1;
            END LOOP;

            EXIT WHEN (i = lix_template_tbl.LAST);
            i := lix_template_tbl.NEXT (i);
         END LOOP;

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'calling okl_trx_contracts_pub.create_trx_cntrct_lines'
                     );
         END IF;

         --create trx contract lines table
         okl_trx_contracts_pub.create_trx_cntrct_lines
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_tclv_tbl           => l_tclv_tbl,
                                           x_tclv_tbl           => lx_tclv_tbl
                                          );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called okl_trx_contracts_pub.create_trx_cntrct_lines , return status: '
                || l_return_status
               );
         END IF;

         -- If error inserting line then set message
         IF l_return_status <> okl_api.g_ret_sts_success
         THEN
            -- Error occurred when creating accounting entries for transaction TRX_TYPE.
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_ERR_ACC_ENT',
                                 p_token1            => 'TRX_TYPE',
                                 p_token1_value      => l_trans_meaning
                                );
         END IF;

         -- Raise exception to rollback to savepoint for this block
         IF (l_return_status = okl_api.g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = okl_api.g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         --setting the input table type to the obtained outout table type
         l_tclv_tbl := lx_tclv_tbl;

-- ***************************
-- POPULATE ACC GEN PRIMARY KEY TABLE
-- ******************************
-- added code to set lp_acc_gen_primary_key_tbl
-- for account generator
-- *********************************************
-- Accounting Engine Call
-- *********************************************
--txl contracts loop
-- udhenuko Bug 6685693 Start. Moving the loop so that the accounting transactions
-- includes fees service lines for the partially terminated asset.
         IF l_tclv_tbl.COUNT <> 0
         THEN
            i := l_tclv_tbl.FIRST;

            LOOP
               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                              'calling okl_acc_call_pvt.okl_populate_acc_gen'
                             );
               END IF;

               okl_acc_call_pvt.okl_populate_acc_gen
                                 (p_contract_id           => p_term_rec.p_contract_id,
                                  p_contract_line_id      => l_tclv_tbl (i).kle_id,
                                  x_acc_gen_tbl           => lp_acc_gen_primary_key_tbl,
                                  x_return_status         => l_return_status
                                 );

               -- udhenuko Bug 6685693 Bug end.
               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                         'called okl_acc_call_pvt.okl_populate_acc_gen , return status: '
                      || l_return_status
                     );
               END IF;

               IF l_return_status <> okl_api.g_ret_sts_success
               THEN
                  -- Error occurred when creating accounting entries for transaction TRX_TYPE.
                  okl_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => 'OKL_AM_ERR_ACC_ENT',
                                       p_token1            => 'TRX_TYPE',
                                       p_token1_value      => l_trans_meaning
                                      );
               END IF;

               -- Raise exception to rollback to savepoint for this block
               IF (l_return_status = okl_api.g_ret_sts_unexp_error)
               THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (l_return_status = okl_api.g_ret_sts_error)
               THEN
                  RAISE okl_api.g_exception_error;
               END IF;

               --Assigning the account generator table
               l_acc_gen_tbl (i).acc_gen_key_tbl := lp_acc_gen_primary_key_tbl;
               l_acc_gen_tbl (i).source_id := l_tclv_tbl (i).ID;
               --populating dist info tbl
               l_dist_info_tbl (i).source_id := l_tclv_tbl (i).ID;
               l_dist_info_tbl (i).source_table := 'OKL_TXL_CNTRCT_LNS';
               l_dist_info_tbl (i).accounting_date := l_quote_accpt_date;
               l_dist_info_tbl (i).gl_reversal_flag := g_no;
               l_dist_info_tbl (i).post_to_gl := g_yes;
               l_dist_info_tbl (i).contract_id := l_tclv_tbl (i).khr_id;
               l_dist_info_tbl (i).contract_line_id := l_tclv_tbl (i).kle_id;
               l_dist_info_tbl (i).currency_code := l_currency_code;

               IF (    (l_functional_currency_code IS NOT NULL)
                   AND (l_currency_code <> l_functional_currency_code)
                  )
               THEN
                  l_dist_info_tbl (i).currency_conversion_rate :=
                                                   l_currency_conversion_rate;
                  l_dist_info_tbl (i).currency_conversion_type :=
                                                   l_currency_conversion_type;
                  l_dist_info_tbl (i).currency_conversion_date :=
                                                   l_currency_conversion_date;
               END IF;

               --form context val table
               IF lp_ctxt_val_tbl.COUNT > 0
               THEN
                  l_ctxt_tbl (i).ctxt_val_tbl := lp_ctxt_val_tbl;
                  l_ctxt_tbl (i).source_id := l_tclv_tbl (i).ID;
               END IF;

               EXIT WHEN i = l_tclv_tbl.LAST;
               i := l_tclv_tbl.NEXT (i);
            END LOOP;
         END IF;

         l_tcn_id := px_tcnv_rec.ID;

         -- call accounting engine
         -- This will calculate the amount and generate accounting entries
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                       (g_level_statement,
                        l_module_name,
                        'calling okl_account_dist_pvt.create_accounting_dist'
                       );
         END IF;

         okl_account_dist_pvt.create_accounting_dist
                                  (p_api_version                  => l_api_version,
                                   p_init_msg_list                => g_false,
                                   x_return_status                => l_return_status,
                                   x_msg_count                    => l_msg_count,
                                   x_msg_data                     => l_msg_data,
                                   p_tmpl_identify_tbl            => l_tmpl_identify_tbl,
                                   p_dist_info_tbl                => l_dist_info_tbl,
                                   p_ctxt_val_tbl                 => l_ctxt_tbl,
                                   p_acc_gen_primary_key_tbl      => l_acc_gen_tbl,
                                   x_template_tbl                 => l_template_out_tbl,
                                   x_amount_tbl                   => l_amount_out_tbl,
                                   p_trx_header_id                => l_tcn_id
                                  );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called okl_account_dist_pvt.create_accounting_dist , return status: '
                || l_return_status
               );
         END IF;

         IF l_amount_out_tbl.COUNT = 0
         THEN
            l_return_status := okl_api.g_ret_sts_error;
         END IF;

         IF l_return_status <> okl_api.g_ret_sts_success
         THEN
            -- Error occurred when creating accounting entries for transaction TRX_TYPE.
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_ERR_ACC_ENT',
                                 p_token1            => 'TRX_TYPE',
                                 p_token1_value      => l_trans_meaning
                                );
         END IF;

         -- Raise exception to rollback to savepoint for this block
         IF (l_return_status = okl_api.g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = okl_api.g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

-- ******************************************************
--   Update Trx Contracts with Header and Line Amounts
-- ******************************************************

         --call the update trx contract api to update amount per stream type
         lip_tcnv_rec := px_tcnv_rec;
         --set all the necessary attributes of the record type
         lip_tcnv_rec.amount := 0;
         lip_tcnv_rec.set_of_books_id :=
                                    okl_accounting_util.get_set_of_books_id
                                                                           ();
         lip_tcnv_rec.org_id := l_org_id;
         --akrangan bug 6147049 fix start
         lip_tcnv_rec.currency_conversion_rate := l_currency_conversion_rate;
         lip_tcnv_rec.currency_conversion_type := l_currency_conversion_type;
         lip_tcnv_rec.currency_conversion_date := l_currency_conversion_date;
         --akrangan bug 6147049 fix end
         --akrangan bug 6215707 fix start
         lip_tcnv_rec.tsu_code := 'PROCESSED';

         --akrangan bug 6215707 fix end
         --product name and tax owner code
         OPEN product_name_csr (l_pdt_id);

         FETCH product_name_csr
          INTO lip_tcnv_rec.product_name,
               lip_tcnv_rec.tax_owner_code;

         CLOSE product_name_csr;

         --trx contracts hdr dffs
         OPEN trx_contracts_dff_csr (p_term_rec.p_contract_id);

         FETCH trx_contracts_dff_csr
          INTO lip_tcnv_rec.attribute_category,
               lip_tcnv_rec.attribute1,
               lip_tcnv_rec.attribute2,
               lip_tcnv_rec.attribute3,
               lip_tcnv_rec.attribute4,
               lip_tcnv_rec.attribute5,
               lip_tcnv_rec.attribute6,
               lip_tcnv_rec.attribute7,
               lip_tcnv_rec.attribute8,
               lip_tcnv_rec.attribute9,
               lip_tcnv_rec.attribute10,
               lip_tcnv_rec.attribute11,
               lip_tcnv_rec.attribute12,
               lip_tcnv_rec.attribute13,
               lip_tcnv_rec.attribute14,
               lip_tcnv_rec.attribute15;

         CLOSE trx_contracts_dff_csr;

         IF (l_tclv_tbl.COUNT) > 0 AND (l_amount_out_tbl.COUNT > 0)
         THEN
            k := l_tclv_tbl.FIRST;
            m := l_amount_out_tbl.FIRST;

            LOOP
               l_tclv_tbl (k).amount := 0;

               IF l_tclv_tbl (k).ID = l_amount_out_tbl (m).source_id
               THEN
                  lx_amount_tbl := l_amount_out_tbl (m).amount_tbl;
                  lx_template_tbl := l_template_out_tbl (m).template_tbl;

                  IF (lx_amount_tbl.COUNT <> 1 OR lx_template_tbl.COUNT <> 1
                     )
                  THEN
                     --raise error
                     l_return_status := okl_api.g_ret_sts_error;
                     -- Error occurred when creating accounting entries for transaction TRX_TYPE.
                     okl_api.set_message (p_app_name          => g_app_name,
                                          p_msg_name          => 'OKL_AM_ERR_ACC_ENT',
                                          p_token1            => 'TRX_TYPE',
                                          p_token1_value      => l_trans_meaning
                                         );
                     -- Raise exception to rollback to savepoint for this block
                     RAISE okl_api.g_exception_error;
                  ELSE
                     l := lx_amount_tbl.FIRST;
                     --update line amount
                     l_tclv_tbl (k).amount := NVL (lx_amount_tbl (l), 0);
                  END IF;
               END IF;

               --update total header amount
               lip_tcnv_rec.amount :=
                                   lip_tcnv_rec.amount + l_tclv_tbl (k).amount;
               EXIT WHEN k = l_tclv_tbl.LAST OR m = l_amount_out_tbl.LAST;
               k := l_tclv_tbl.NEXT (k);
               m := l_amount_out_tbl.NEXT (m);
            END LOOP;
         END IF;

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling okl_trx_contracts_pub.update_trx_contracts'
                        );
         END IF;

         --call the api to update trx contracts hdr and lines
         okl_trx_contracts_pub.update_trx_contracts
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_tcnv_rec           => lip_tcnv_rec,
                                           p_tclv_tbl           => l_tclv_tbl,
                                           x_tcnv_rec           => lix_tcnv_rec,
                                           x_tclv_tbl           => lx_tclv_tbl
                                          );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called okl_trx_contracts_pub.update_trx_contracts , return status: '
                || l_return_status
               );
         END IF;

         --handle exception
         IF l_return_status <> okl_api.g_ret_sts_success
         THEN
            -- Error occurred when creating accounting entries for transaction TRX_TYPE.
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_ERR_ACC_ENT',
                                 p_token1            => 'TRX_TYPE',
                                 p_token1_value      => l_trans_meaning
                                );
         END IF;

         -- Raise exception to rollback to savepoint for this block
         IF (l_return_status = okl_api.g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = okl_api.g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- Set the return record
         px_tcnv_rec := lix_tcnv_rec;

        OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => l_api_version
                           ,p_init_msg_list => g_false
                           ,x_return_status => l_return_status
                           ,x_msg_count => l_msg_count
                           ,x_msg_data => l_msg_data
                           ,P_TCNV_REC => lip_tcnv_rec
                           ,P_TCLV_TBL => l_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => lp_acc_gen_primary_key_tbl);

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

         -- Bug 3061772
         -- Call to Process dicount and Subsidy during acceptance of a termination quote
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                'calling okl_am_lease_loan_trmnt_pvt.process_discount_subsidy'
               );
         END IF;

         okl_am_lease_loan_trmnt_pvt.process_discount_subsidy
                                          (p_api_version           => l_api_version,
                                           p_init_msg_list         => okl_api.g_false,
                                           x_return_status         => l_return_status,
                                           x_msg_count             => l_msg_count,
                                           x_msg_data              => l_msg_data,
                                           p_term_rec              => p_term_rec,
                                           p_call_origin           => 'PARTIAL',
                                           p_termination_date      => p_sys_date
                                          );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called okl_am_lease_loan_trmnt_pvt.process_discount_subsidy , return status: '
                || l_return_status
               );
         END IF;

         IF l_return_status <> okl_api.g_ret_sts_success
         THEN
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_SUBSIDY_PROC_FAIL');
         END IF;

         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- SUCCESS MESSAGES

         -- Set success messages here
         -- Get the meaning of lookup
         l_trans_meaning :=
            okl_am_util_pvt.get_lookup_meaning
                                (p_lookup_type      => 'OKL_ACCOUNTING_EVENT_TYPE',
                                 p_lookup_code      => 'TERMINATION',
                                 p_validate_yn      => 'Y'
                                );
         -- Accounting entries created for transaction type TRX_TYPE.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_ACC_ENT_CREATED',
                              p_token1            => 'TRX_TYPE',
                              p_token1_value      => l_trans_meaning
                             );
         -- store the highest degree of error
         set_overall_status (p_return_status        => l_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => l_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ACCOUNTING_ENTRIES_YN',
                              p_tsu_code            => 'WORKING',
                              px_tcnv_rec           => px_tcnv_rec
                             );
      END IF;

      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- Close any open cursors
         IF l_product_type_csr%ISOPEN
         THEN
            CLOSE l_product_type_csr;
         END IF;

         IF prod_id_csr%ISOPEN
         THEN
            CLOSE prod_id_csr;
         END IF;

         -- Rollback to savepoint
         ROLLBACK TO accounting_entries;
         -- Set Return status
         x_return_status := g_ret_sts_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ACCOUNTING_ENTRIES_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- Close any open cursors
         IF l_product_type_csr%ISOPEN
         THEN
            CLOSE l_product_type_csr;
         END IF;

         IF prod_id_csr%ISOPEN
         THEN
            CLOSE prod_id_csr;
         END IF;

         -- Rollback to savepoint
         ROLLBACK TO accounting_entries;
         -- Set Return status
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ACCOUNTING_ENTRIES_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- Close any open cursors
         IF l_product_type_csr%ISOPEN
         THEN
            CLOSE l_product_type_csr;
         END IF;

         IF prod_id_csr%ISOPEN
         THEN
            CLOSE prod_id_csr;
         END IF;

         -- Rollback to savepoint
         ROLLBACK TO accounting_entries;
         -- Set Return status
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ACCOUNTING_ENTRIES_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END accounting_entries;

   -- Start of comments
   --
   -- Procedure Name : dispose_assets
   -- Desciption     : Call the Asset Dispose API to dispose off assets
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        : RMUNJULU Bug # 2484327 16-DEC-02, changed parameter value
   --                  to p_quantity to set the quote_quantity
   --                : SECHAWLA 31-DEC-02 Bug #2726739
   --                  Added logic to convert proceeds of sale amount to functional currency
   --                : RMUNJULU 23-JAN-03 2762065 Return E if split asset already
   --                  done
   --                : RMUNJULU 04-FEB-03 2781557 Added code to get and set
   --                  proceeds of sale properly. Also removed the FA related fix
   --                  introduced by bug 2762065 since split asset wont retire if
   --                  dispose also being done
   --                : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
   --                : SECHAWLA 11-MAR-03 Modified kle_pur_amt_csr cursor to nvl the purchase amount
   --                : rmunjulu EDAT Added code to set trn_date as currency conversion trn date
   --                  also send quote eff date and quote acceptance date to disposal api.
   --
   -- End of comments
   PROCEDURE dispose_assets (
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_klev_tbl          IN              klev_tbl_type,
      p_trn_already_set   IN              VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2,
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      -- Cursor to get the purchase amount for the line
      -- RMUNJULU 04-FEB-03 2781557 Changed cursor to get proper purchase amount lines
      CURSOR kle_pur_amt_csr (
         p_kle_id   IN   NUMBER,
         p_qte_id   IN   NUMBER
      )
      IS
         SELECT NVL (tql.amount, 0) amount    --SECHAWLA 11-MAR-03 : Added nvl
           FROM okl_txl_quote_lines_v tql
          WHERE tql.kle_id = p_kle_id
            AND tql.qte_id = p_qte_id
            AND tql.qlt_code = 'AMBPOC';                    -- Purchase Amount

      kle_pur_amt_rec               kle_pur_amt_csr%ROWTYPE;
      l_return_status               VARCHAR2 (1)          := g_ret_sts_success;
      l_overall_dispose_status      VARCHAR2 (1)          := g_ret_sts_success;
      l_asset_id                    NUMBER;
      l_line_number                 VARCHAR2 (200);
      i                             NUMBER                                := 1;
      l_proceeds_of_sale            NUMBER;
      l_api_version        CONSTANT NUMBER                    := g_api_version;
      l_msg_count                   NUMBER                       := g_miss_num;
      l_msg_data                    VARCHAR2 (2000);
      l_module_name                 VARCHAR2 (500)
                                          := g_module_name || 'dispose_assets';
      is_debug_exception_on         BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on         BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on         BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      --SECHAWLA  Bug # 2726739 : new declarations
      l_func_curr_code              gl_ledgers_public_v.currency_code%TYPE;
      l_contract_curr_code          okc_k_headers_b.currency_code%TYPE;
      -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
      lx_contract_currency          okc_k_headers_v.currency_code%TYPE;
      lx_currency_conversion_type   okl_k_headers_v.currency_conversion_type%TYPE;
      lx_currency_conversion_rate   okl_k_headers_v.currency_conversion_rate%TYPE;
      lx_currency_conversion_date   okl_k_headers_v.currency_conversion_date%TYPE;
      lx_converted_amount           NUMBER;
      -- rmunjulu EDAT
      l_quote_accpt_date            DATE;
      l_quote_eff_date              DATE;
      -- RRAVIKIR Legal Entity changes
      l_legal_entity_id             NUMBER;
   -- Legal Entity changes end
   BEGIN
      -- Start savepoint to rollback to if the block fails
      SAVEPOINT asset_dispose;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );
         okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                            'In param, px_tcnv_rec.tmt_asset_disposition_yn: '
                         || px_tcnv_rec.tmt_asset_disposition_yn
                        );

         IF p_klev_tbl.COUNT > 0
         THEN
            FOR i IN p_klev_tbl.FIRST .. p_klev_tbl.LAST
            LOOP
               IF (p_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || p_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_quantity: '
                                           || p_klev_tbl (i).p_asset_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || p_klev_tbl (i).p_asset_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_quote_quantity: '
                                           || p_klev_tbl (i).p_quote_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_tql_id: '
                                           || p_klev_tbl (i).p_tql_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_split_kle_name: '
                                           || p_klev_tbl (i).p_split_kle_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_split_kle_id: '
                                           || p_klev_tbl (i).p_split_kle_id
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Check if disposition done earlier
      IF    (    p_trn_already_set = g_yes
             AND NVL (px_tcnv_rec.tmt_asset_disposition_yn, '?') <> g_yes
            )
         OR (p_trn_already_set = g_no)
      THEN
         -- RMUNJULU 3018641 Step Message
         -- Step : Asset Dispose
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_AM_STEP_ADP');

         -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

         -- rmunjulu EDAT
         -- If quote exists then accnting date is quote accept date else sysdate
         IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
         THEN
            l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
            l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
         ELSE
            l_quote_accpt_date := p_sys_date;
            l_quote_eff_date := p_sys_date;
         END IF;

         -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++
         IF (p_klev_tbl.COUNT > 0)
         THEN
            i := p_klev_tbl.FIRST;

            LOOP
               -- Initialize proceeds_of_sale
               l_proceeds_of_sale := 0;

               -- Loop in the purchase amounts to set proceeds_of_sale
               FOR kle_pur_amt_rec IN
                  kle_pur_amt_csr (p_klev_tbl (i).p_kle_id,
                                   p_term_rec.p_quote_id)
               LOOP
                  l_proceeds_of_sale :=
                                  l_proceeds_of_sale + kle_pur_amt_rec.amount;
               END LOOP;

               -- SECHAWLA 11-MAR-03 : Commented the following IF, as it is not necessary

               /*
               -- RMUNJULU 04-FEB-03 2781557 Added if to set the proceeds of sales if no value
               IF l_proceeds_of_sale IS NULL THEN
                  l_proceeds_of_sale := 0;
               END IF;
               */

               -- SECHAWLA  Bug # 2726739 : added the folowing piece of code

               -- get the functional currency
               l_func_curr_code := okl_am_util_pvt.get_functional_currency;
               -- get the contract currency
               l_contract_curr_code :=
                  okl_am_util_pvt.get_chr_currency
                                         (p_chr_id      => p_term_rec.p_contract_id);

               IF l_contract_curr_code <> l_func_curr_code
               THEN
                  -- convert amount to functional currency
                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling okl_accounting_util.convert_to_functional_currency'
                        );
                  END IF;

                  okl_accounting_util.convert_to_functional_currency
                     (p_khr_id                        => p_term_rec.p_contract_id,
                      p_to_currency                   => l_func_curr_code,
                      p_transaction_date              => p_sys_date,
                      p_amount                        => l_proceeds_of_sale,
                      x_return_status                 => x_return_status,
                      x_contract_currency             => lx_contract_currency,
                      x_currency_conversion_type      => lx_currency_conversion_type,
                      x_currency_conversion_rate      => lx_currency_conversion_rate,
                      x_currency_conversion_date      => lx_currency_conversion_date,
                      x_converted_amount              => lx_converted_amount
                     );

                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                            'called okl_accounting_util.convert_to_functional_currency , return status: '
                         || x_return_status
                        );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'lx_contract_currency_code: '
                                              || lx_contract_currency
                                             );
                     okl_debug_pub.log_debug
                                           (g_level_statement,
                                            l_module_name,
                                               'lx_currency_conversion_type: '
                                            || lx_currency_conversion_type
                                           );
                     okl_debug_pub.log_debug
                                           (g_level_statement,
                                            l_module_name,
                                               'lx_currency_conversion_rate: '
                                            || lx_currency_conversion_rate
                                           );
                     okl_debug_pub.log_debug
                                           (g_level_statement,
                                            l_module_name,
                                               'lx_currency_conversion_date: '
                                            || lx_currency_conversion_date
                                           );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'lx_converted_amount: '
                                              || lx_converted_amount
                                             );
                  END IF;

                  IF x_return_status <> g_ret_sts_success
                  THEN
                     -- Error occurred during disposal of asset NAME.
                     okl_api.set_message
                                (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_ERR_DISPOSAL',
                                 p_token1            => 'NAME',
                                 p_token1_value      => p_klev_tbl (i).p_asset_name
                                );
                  END IF;

                  -- Raise exception to rollback to savepoint if error
                  IF (x_return_status = g_ret_sts_unexp_error)
                  THEN
                     RAISE okl_api.g_exception_unexpected_error;
                  ELSIF (x_return_status = g_ret_sts_error)
                  THEN
                     RAISE okl_api.g_exception_error;
                  END IF;

                  l_proceeds_of_sale := lx_converted_amount;
               END IF;

               -- -- SECHAWLA  Bug # 2726739 : end new code

               -- RMUNJULU 23-JAN-03 2762065 -- START --
               -- Code fix for FA related error in Asset Retirement
               -- We always return error when Asset Dispose called after a split asset

               -- RMUNJULU 04-FEB-03 2781557 Removed the temporary FA related fix
               --              IF NVL(px_tcnv_rec.tmt_split_asset_yn, 'N') = 'Y' THEN

               --                 l_return_status := G_RET_STS_ERROR;

               --              ELSE

               -- RRAVIKIR Legal Entity Changes
               -- Populate the legal entity from the contract
               l_legal_entity_id :=
                  okl_legal_entity_util.get_khr_le_id
                                         (p_khr_id      => p_term_rec.p_contract_id);

               -- Legal Entity Changes end

               -- call asset dispose retirement
               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                            (g_level_statement,
                             l_module_name,
                             'calling OKL_AM_ASSET_DISPOSE_PUB.dispose_asset'
                            );
               END IF;

               okl_am_asset_dispose_pub.dispose_asset
                  (p_api_version             => l_api_version,
                   p_init_msg_list           => g_false,
                   x_return_status           => l_return_status,
                   x_msg_count               => l_msg_count,
                   x_msg_data                => l_msg_data,
                   p_financial_asset_id      => p_klev_tbl (i).p_kle_id,
                   p_quantity                => NULL,
                   p_proceeds_of_sale        => l_proceeds_of_sale,
                   p_quote_eff_date          => l_quote_eff_date,
      -- rmunjulu EDAT Pass additional parameters now required by disposal api
                   p_quote_accpt_date        => l_quote_accpt_date,
      -- rmunjulu EDAT Pass additional parameters now required by disposal api
                   p_legal_entity_id         => l_legal_entity_id
                  );                          -- RRAVIKIR Legal Entity Changes

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                         'called OKL_AM_ASSET_DISPOSE_PUB.dispose_asset , return status: '
                      || l_return_status
                     );
               END IF;

               -- call asset dispose API
               -- RMUNJULU Bug # 2484327 16-DEC-02, changed parameter value to
               -- p_quantity to set the quote_quantity
               -- RMUNJULU 04-FEB-03 2781557 Changed value passed to p_quantity
               -- from quote_quantity to NULL
               /*    OKL_AM_ASSET_DISPOSE_PUB.dispose_asset(
                          p_api_version        => l_api_version,
                          p_init_msg_list      => G_FALSE,
                          x_return_status      => l_return_status,
                          x_msg_count          => l_msg_count,
                          x_msg_data           => l_msg_data,
                          p_financial_asset_id => p_klev_tbl(i).p_kle_id,
                          p_quantity           => NULL,
                          p_proceeds_of_sale   => l_proceeds_of_sale,
                          p_quote_eff_date     => l_quote_eff_date,    -- rmunjulu EDAT Pass additional parameters now required by disposal api
                          p_quote_accpt_date   => l_quote_accpt_date); -- rmunjulu EDAT Pass additional parameters now required by disposal api
               */

               --              END IF;

               -- RMUNJULU 23-JAN-03 2762065 -- END --

               -- Check the return status
               IF l_return_status <> g_ret_sts_success
               THEN
                  -- Error occurred during disposal of asset NAME.
                  okl_api.set_message
                                (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_ERR_DISPOSAL',
                                 p_token1            => 'NAME',
                                 p_token1_value      => p_klev_tbl (i).p_asset_name
                                );
               END IF;

               --08-mar-06 sgorantl -- Bug 3895098
               IF     l_overall_dispose_status = okl_api.g_ret_sts_success
                  AND l_return_status IN
                         (okl_api.g_ret_sts_error,
                          okl_api.g_ret_sts_unexp_error
                         )
               THEN
                  l_overall_dispose_status := l_return_status;
               END IF;

               EXIT WHEN (i = p_klev_tbl.LAST);
               i := p_klev_tbl.NEXT (i);
            END LOOP;

            --08-mar-06 sgorantl -- Bug 3895098
            -- Raise exception to rollback to savepoint if error
            IF (l_overall_dispose_status = okl_api.g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_overall_dispose_status = okl_api.g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            --08-mar-06 sgorantl -- Bug 3895098

            -- Asset dispostion for assets of contract CONTRACT_NUMBER
            -- done successfully.
            okl_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKL_AM_ASS_DISPOSE_SUCCESS',
                                p_token1            => 'CONTRACT_NUMBER',
                                p_token1_value      => p_term_rec.p_contract_number
                               );
            -- store the highest degree of error
            set_overall_status (p_return_status        => l_overall_dispose_status,
                                px_overall_status      => px_overall_status);
            -- set the transaction record for asset disposition
            set_transaction_rec (p_return_status       => l_overall_dispose_status,
                                 p_overall_status      => px_overall_status,
                                 p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                                 p_tsu_code            => 'WORKING',
                                 px_tcnv_rec           => px_tcnv_rec
                                );
         END IF;
      END IF;

      -- set the transaction record for amortization
      set_transaction_rec (p_return_status       => l_return_status,
                           p_overall_status      => px_overall_status,
                           p_tmt_flag            => 'TMT_AMORTIZATION_YN',
                           p_tsu_code            => 'WORKING',
                           p_ret_val             => NULL,
                           px_tcnv_rec           => px_tcnv_rec
                          );
      -- set the transaction record for asset return
      set_transaction_rec (p_return_status       => l_return_status,
                           p_overall_status      => px_overall_status,
                           p_tmt_flag            => 'TMT_ASSET_RETURN_YN',
                           p_tsu_code            => 'WORKING',
                           p_ret_val             => NULL,
                           px_tcnv_rec           => px_tcnv_rec
                          );
      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- Close any open cursors
         IF kle_pur_amt_csr%ISOPEN
         THEN
            CLOSE kle_pur_amt_csr;
         END IF;

         ROLLBACK TO asset_dispose;
         x_return_status := g_ret_sts_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record for amortization
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_AMORTIZATION_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record for asset return
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_RETURN_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- Close any open cursors
         IF kle_pur_amt_csr%ISOPEN
         THEN
            CLOSE kle_pur_amt_csr;
         END IF;

         ROLLBACK TO asset_dispose;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record for amortization
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_AMORTIZATION_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record for asset return
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_RETURN_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- Close any open cursors
         IF kle_pur_amt_csr%ISOPEN
         THEN
            CLOSE kle_pur_amt_csr;
         END IF;

         ROLLBACK TO asset_dispose;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record for amortization
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_AMORTIZATION_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record for asset return
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_RETURN_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END dispose_assets;

   -- Start of comments
   --
   -- Procedure Name : delink_assets
   -- Desciption     : Calls the FA adjustment API to delink the asset from contract
   -- Business Rules :
   -- Parameters     :
   -- Version      : 1.0
   -- History        : AKRANGAN created
   --
   -- End of comments
   PROCEDURE delink_assets (
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_klev_tbl          IN              klev_tbl_type,
      p_trn_already_set   IN              VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2,
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      -- Get all the FA books (corp and tax) that asset belongs to
      CURSOR l_fabooks_csr (
         cp_asset_number   IN   VARCHAR2,
         cp_sysdate        IN   DATE
      )
      IS
         SELECT fb.book_type_code,
                fb.asset_id,
                fb.contract_id
           FROM fa_books fb,
                fa_additions_b fab,
                fa_book_controls fbc
          WHERE fb.asset_id = fab.asset_id
            AND fb.book_type_code = fbc.book_type_code
            AND NVL (fbc.date_ineffective, cp_sysdate + 1) > cp_sysdate
            AND fb.transaction_header_id_out IS NULL
            AND fab.asset_number = cp_asset_number;

      l_return_status               VARCHAR2 (1)          := g_ret_sts_success;
      l_overall_status              VARCHAR2 (1)          := g_ret_sts_success;
      i                             NUMBER                                := 1;
      l_early_term_yn               VARCHAR2 (1)                       := g_no;
      l_k_end_date                  DATE                        := g_miss_date;
      l_api_version        CONSTANT NUMBER                    := g_api_version;
      l_msg_count                   NUMBER                       := g_miss_num;
      l_msg_data                    VARCHAR2 (2000);
      l_module_name                 VARCHAR2 (500)
                                           := g_module_name || 'delink_assets';
      is_debug_exception_on         BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on         BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on         BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      l_evergreen_earlier           VARCHAR2 (3)                        := 'N';
      l_quote_accpt_date            DATE;
      l_quote_eff_date              DATE;
      l_asset_fin_rec_empty_adj     fa_api_types.asset_fin_rec_type;
      l_asset_hdr_empty_rec         fa_api_types.asset_hdr_rec_type;
      l_trans_empty_rec             fa_api_types.trans_rec_type;
      l_adj_trans_rec               fa_api_types.trans_rec_type;
      l_adj_asset_hdr_rec           fa_api_types.asset_hdr_rec_type;
      l_asset_fin_rec_adj           fa_api_types.asset_fin_rec_type;
      l_asset_fin_rec_new           fa_api_types.asset_fin_rec_type;
      l_inv_trans_rec               fa_api_types.inv_trans_rec_type;
      l_adj_inv_tbl                 fa_api_types.inv_tbl_type;
      l_asset_deprn_rec_adj         fa_api_types.asset_deprn_rec_type;
      l_asset_deprn_rec_new         fa_api_types.asset_deprn_rec_type;
      l_asset_deprn_mrc_tbl_new     fa_api_types.asset_deprn_tbl_type;
      l_group_reclass_options_rec   fa_api_types.group_reclass_options_rec_type;
      l_asset_fin_mrc_tbl_new       fa_api_types.asset_fin_tbl_type;
      l_transaction_subtype         VARCHAR2 (20);
      l_tmt_flag                    VARCHAR2 (50);
   BEGIN
      -- Start a savepoint
      SAVEPOINT asset_delink;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );
         okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                                 'In param, px_tcnv_rec.tmt_amortization_yn: '
                              || px_tcnv_rec.tmt_amortization_yn
                             );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_tcnv_rec.id: '
                                  || px_tcnv_rec.ID
                                 );

         IF p_klev_tbl.COUNT > 0
         THEN
            FOR i IN p_klev_tbl.FIRST .. p_klev_tbl.LAST
            LOOP
               IF (p_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || p_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || p_klev_tbl (i).p_asset_name
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                      (g_level_statement,
                       l_module_name,
                       'calling OKL_AM_LEASE_TRMNT_PVT.check_k_evergreen_ear'
                      );
      END IF;

      l_evergreen_earlier :=
         okl_am_lease_trmnt_pvt.check_k_evergreen_ear
                                        (p_khr_id             => p_term_rec.p_contract_id,
                                         p_tcn_id             => px_tcnv_rec.ID,
                                         x_return_status      => l_return_status
                                        );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
            (g_level_statement,
             l_module_name,
                'called OKL_AM_LEASE_TRMNT_PVT.check_k_evergreen_ear , return status: '
             || l_return_status
            );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'l_evergreen_earlier: '
                                  || l_evergreen_earlier
                                 );
      END IF;

      IF l_return_status <> okl_api.g_ret_sts_success
      THEN
         -- Error occurred during the creation of an amortization transaction
         -- for assets of contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_ERR_AMORTIZE',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
      END IF;

      -- If quote exists then cancelation date is quote eff from date else sysdate
      IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
      THEN
         l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
         l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
      ELSE
         l_quote_accpt_date := p_sys_date;
         l_quote_eff_date := p_sys_date;
      END IF;

      IF l_evergreen_earlier = 'Y'
      THEN
         l_transaction_subtype := '';
         l_tmt_flag := '';
      ELSE
         l_transaction_subtype := 'AMORTIZED';
         l_tmt_flag := 'TMT_AMORTIZATION_YN';
      END IF;

      -- if assets present for contract
      IF (p_klev_tbl.COUNT > 0)
      THEN
         -- Loop thru assets table
         i := p_klev_tbl.FIRST;

         LOOP
            FOR l_fabooks_rec IN l_fabooks_csr (p_klev_tbl (i).p_asset_name,
                                                l_quote_accpt_date)
            LOOP
               IF l_fabooks_rec.contract_id IS NOT NULL
               THEN
                  l_asset_fin_rec_adj := l_asset_fin_rec_empty_adj;
                  l_adj_trans_rec := l_trans_empty_rec;
                  l_adj_asset_hdr_rec := l_asset_hdr_empty_rec;
                  l_adj_trans_rec.transaction_subtype :=
                                                        l_transaction_subtype;
                  l_adj_asset_hdr_rec.asset_id := l_fabooks_rec.asset_id;
                  l_adj_asset_hdr_rec.book_type_code :=
                                                 l_fabooks_rec.book_type_code;
                  l_asset_fin_rec_adj.contract_id := fnd_api.g_miss_num;
                  l_adj_trans_rec.transaction_date_entered :=
                                                             l_quote_eff_date;
                  fa_adjustment_pub.do_adjustment
                     (p_api_version                    => l_api_version,
                      p_init_msg_list                  => okc_api.g_false,
                      p_commit                         => fnd_api.g_false,
                      p_validation_level               => fnd_api.g_valid_level_full,
                      p_calling_fn                     => NULL,
                      x_return_status                  => l_return_status,
                      x_msg_count                      => l_msg_count,
                      x_msg_data                       => l_msg_data,
                      px_trans_rec                     => l_adj_trans_rec,
                      px_asset_hdr_rec                 => l_adj_asset_hdr_rec,
                      p_asset_fin_rec_adj              => l_asset_fin_rec_adj,
                      x_asset_fin_rec_new              => l_asset_fin_rec_new,
                      x_asset_fin_mrc_tbl_new          => l_asset_fin_mrc_tbl_new,
                      px_inv_trans_rec                 => l_inv_trans_rec,
                      px_inv_tbl                       => l_adj_inv_tbl,
                      p_asset_deprn_rec_adj            => l_asset_deprn_rec_adj,
                      x_asset_deprn_rec_new            => l_asset_deprn_rec_new,
                      x_asset_deprn_mrc_tbl_new        => l_asset_deprn_mrc_tbl_new,
                      p_group_reclass_options_rec      => l_group_reclass_options_rec
                     );

                  IF l_return_status <> okc_api.g_ret_sts_success
                  THEN
                     -- Error processing TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER in book BOOK.
                     okc_api.set_message
                              (p_app_name          => 'OKL',
                               p_msg_name          => 'OKL_AM_AMT_TRANS_FAILED',
                               p_token1            => 'TRX_TYPE',
                               p_token1_value      => 'Contract Delink',
                               p_token2            => 'ASSET_NUMBER',
                               p_token2_value      => p_klev_tbl (i).p_asset_name,
                               p_token3            => 'BOOK',
                               p_token3_value      => l_fabooks_rec.book_type_code
                              );
                     RAISE okl_api.g_exception_error;
                  END IF;
               END IF;
            END LOOP;

            EXIT WHEN (i = p_klev_tbl.LAST);
            i := p_klev_tbl.NEXT (i);
         END LOOP;

         -- set the transaction record for asset return
         set_transaction_rec (p_return_status       => l_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => l_tmt_flag,
                              p_tsu_code            => 'WORKING',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- Set overall status
         set_overall_status (p_return_status        => l_return_status,
                             px_overall_status      => px_overall_status);
      END IF;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         IF l_fabooks_csr%ISOPEN
         THEN
            CLOSE l_fabooks_csr;
         END IF;

         ROLLBACK TO asset_delink;
         x_return_status := g_ret_sts_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => l_tmt_flag,
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         IF l_fabooks_csr%ISOPEN
         THEN
            CLOSE l_fabooks_csr;
         END IF;

         ROLLBACK TO asset_delink;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => l_tmt_flag,
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         IF l_fabooks_csr%ISOPEN
         THEN
            CLOSE l_fabooks_csr;
         END IF;

         ROLLBACK TO asset_delink;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => l_tmt_flag,
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END delink_assets;

   -- Start of comments
   --
   -- Procedure Name : amortize_assets
   -- Desciption     : Calls the Amortization API to amortize assets of contract
   -- Business Rules :
   -- Parameters     :
   -- Version      : 1.0
   -- History        : RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
   --                : RMUNJULU 3485854 12-MAR-04 Added code to check contract was
   --                  EVERGREEN earlier, if so then amortization was done, DO NOT do again
   --                : rmunjulu EDAT Added code to get the quote eff date and check for early term based on that
   --                  Also pass quote eff date and quote acceptance date to amortize api
   --                : SECHAWLA 14-dec-07 6690811 - Delink contract ID from FA asset, upon partial termination of
   --                  Booked or Evergreen contract.
   --                : SECHAWLA 02-Jan-08 6720667 - Check if contract ID is already null, before updating it to Null
   --
   -- End of comments
   PROCEDURE amortize_assets (
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_klev_tbl          IN              klev_tbl_type,
      p_trn_already_set   IN              VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2,
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      -- Cursor to get the end date of contract
      -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_HDR_FULL
      CURSOR get_k_end_date_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT khr.end_date end_date
           FROM okc_k_headers_v khr
          WHERE khr.ID = p_khr_id;

      l_return_status          VARCHAR2 (1)    := g_ret_sts_success;
      l_overall_status         VARCHAR2 (1)    := g_ret_sts_success;
      i                        NUMBER          := 1;
      l_early_term_yn          VARCHAR2 (1)    := g_no;
      l_k_end_date             DATE            := g_miss_date;
      l_api_version   CONSTANT NUMBER          := g_api_version;
      l_msg_count              NUMBER          := g_miss_num;
      l_msg_data               VARCHAR2 (2000);
      l_module_name            VARCHAR2 (500)
                                         := g_module_name || 'amortize_assets';
      is_debug_exception_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      -- RMUNJULU 3485854
      l_evergreen_earlier      VARCHAR2 (3)    := 'N';
      -- rmunjulu EDAT
      l_quote_accpt_date       DATE;
      l_quote_eff_date         DATE;
   BEGIN
      -- Start a savepoint
      SAVEPOINT asset_amortize;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );
         okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                                 'In param, px_tcnv_rec.tmt_amortization_yn: '
                              || px_tcnv_rec.tmt_amortization_yn
                             );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_tcnv_rec.id: '
                                  || px_tcnv_rec.ID
                                 );

         IF p_klev_tbl.COUNT > 0
         THEN
            FOR i IN p_klev_tbl.FIRST .. p_klev_tbl.LAST
            LOOP
               IF (p_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || p_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || p_klev_tbl (i).p_asset_name
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Check if amortization required
      IF    (    p_trn_already_set = g_yes
             AND NVL (px_tcnv_rec.tmt_amortization_yn, '?') <> g_yes
            )
         OR (p_trn_already_set = g_no)
      THEN

            -- rmunjulu bug 7009808 Set the variables outside so that delink can use the values
            -- If quote exists then cancelation date is quote eff from date else sysdate
            IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
            THEN
               l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
               l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
            ELSE
               l_quote_accpt_date := p_sys_date;
               l_quote_eff_date := p_sys_date;
            END IF;



         -- RMUNJULU 3485854
         -- CHECK TO see IF old evergreen transaction exists
         -- Check if another transaction exists which is processed and for which tmt_evergreen_yn was Y
         -- which means this contract was evergreen earlier
         -- so no need to run amortization again
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                      (g_level_statement,
                       l_module_name,
                       'calling OKL_AM_LEASE_TRMNT_PVT.check_k_evergreen_ear'
                      );
         END IF;

         l_evergreen_earlier :=
            okl_am_lease_trmnt_pvt.check_k_evergreen_ear
                                        (p_khr_id             => p_term_rec.p_contract_id,
                                         p_tcn_id             => px_tcnv_rec.ID,
                                         x_return_status      => l_return_status
                                        );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_AM_LEASE_TRMNT_PVT.check_k_evergreen_ear , return status: '
                || l_return_status
               );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                        'l_evergreen_earlier: '
                                     || l_evergreen_earlier
                                    );
         END IF;

         IF l_return_status <> okl_api.g_ret_sts_success
         THEN
            -- Error occurred during the creation of an amortization transaction
            -- for assets of contract CONTRACT_NUMBER.
            okl_api.set_message
                              (p_app_name          => g_app_name,
                               p_msg_name          => 'OKL_AM_ERR_AMORTIZE',
                               p_token1            => 'CONTRACT_NUMBER',
                               p_token1_value      => p_term_rec.p_contract_number
                              );
         END IF;

         -- RMUNJULU 3485854
         -- Check to make sure amortization was not done
         IF NVL (l_evergreen_earlier, 'N') <> 'Y'
         THEN
            -- RMUNJULU 3018641 Step Message
            -- Step : Amortization
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_STEP_AMT');

            -- get k end date
            OPEN get_k_end_date_csr (p_term_rec.p_contract_id);

            FETCH get_k_end_date_csr
             INTO l_k_end_date;

            CLOSE get_k_end_date_csr;

            -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

            -- rmunjulu EDAT
            -- If quote exists then cancelation date is quote eff from date else sysdate
            IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
            THEN
               l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
               l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
            ELSE
               l_quote_accpt_date := p_sys_date;
               l_quote_eff_date := p_sys_date;
            END IF;

            -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

            -- Set early termination yn flag
            IF     (l_k_end_date <> g_miss_date)
               AND (TRUNC (l_k_end_date) > TRUNC (l_quote_eff_date))
            THEN
               -- rmunjulu EDAT Check based on quote eff date
               l_early_term_yn := g_yes;
            END IF;

            -- if assets present for contract
            IF (p_klev_tbl.COUNT > 0)
            THEN
               -- Loop thru assets table
               i := p_klev_tbl.FIRST;

               LOOP
                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling OKL_AM_AMORTIZE_PUB.create_offlease_asset_trx'
                        );
                  END IF;

                  -- call amortization
                  okl_am_amortize_pub.create_offlease_asset_trx
                        (p_api_version               => l_api_version,
                         p_init_msg_list             => g_false,
                         x_return_status             => l_return_status,
                         x_msg_count                 => l_msg_count,
                         x_msg_data                  => l_msg_data,
                         p_kle_id                    => p_klev_tbl (i).p_kle_id,
                         p_early_termination_yn      => l_early_term_yn,
                         p_quote_eff_date            => l_quote_eff_date,
                                                              -- rmunjulu EDAT
                         p_quote_accpt_date          => l_quote_accpt_date
                        );                                    -- rmunjulu EDAT

                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                            'called OKL_AM_AMORTIZE_PUB.create_offlease_asset_trx , return status: '
                         || l_return_status
                        );
                  END IF;

                  IF l_return_status <> g_ret_sts_success
                  THEN
                     -- Error occurred during the amortization process for asset NAME.
                     okl_api.set_message
                                (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_ERR_LNS_AMORTIZE',
                                 p_token1            => 'NAME',
                                 p_token1_value      => p_klev_tbl (i).p_asset_name
                                );
                     -- Raise exception to rollback to savepoint if error
                     RAISE okl_api.g_exception_error;
                  END IF;

                  EXIT WHEN (i = p_klev_tbl.LAST);
                  i := p_klev_tbl.NEXT (i);
               END LOOP;

               -- set the transaction record for asset return
               set_transaction_rec (p_return_status       => l_return_status,
                                    p_overall_status      => px_overall_status,
                                    p_tmt_flag            => 'TMT_AMORTIZATION_YN',
                                    p_tsu_code            => 'WORKING',
                                    px_tcnv_rec           => px_tcnv_rec
                                   );
               -- Set overall status
               set_overall_status (p_return_status        => l_return_status,
                                   px_overall_status      => px_overall_status);
            END IF;
         END IF;

         -- rmunjulu bug 6853566 make call to delink contract from here
         -- This call will always be made if amortize is supposed to be run
         --
         OKL_AM_LEASE_TRMNT_PVT.delink_contract_from_asset(
                       p_api_version      => l_api_version,
                       x_msg_count        => l_msg_count,
                       x_msg_data         => l_msg_data,
                       p_full_term_yn     => 'N', -- not full termination but partial
                       p_khr_id           => p_term_rec.p_contract_id,
                       p_klev_tbl         => p_klev_tbl,
                       --p_sts_code         => l_dummy_sts_code,
                       p_quote_accpt_date => l_quote_accpt_date,
                       p_quote_eff_date   => l_quote_eff_date,
                       x_return_status    => l_return_status);

         IF l_return_status <> g_ret_sts_success  THEN
            -- Error occurred during the amortization process for asset NAME.
            okl_api.set_message
                    (p_app_name          => g_app_name,
                     p_msg_name          => 'OKL_AM_ERR_LNS_AMORTIZE',
                     p_token1            => 'NAME',
                     p_token1_value      => p_klev_tbl (i).p_asset_name
                     );
             -- Raise exception to rollback to savepoint if error
             RAISE okl_api.g_exception_error;
         END IF;

         -- set the transaction record for asset return
         set_transaction_rec (p_return_status       => l_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_AMORTIZATION_YN',
                              p_tsu_code            => 'WORKING',
                              px_tcnv_rec           => px_tcnv_rec
                              );
         -- Set overall status
         set_overall_status (p_return_status        => l_return_status,
                             px_overall_status      => px_overall_status);
      END IF;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;

      --SET THE AMORTIZATION FLAG
      g_amort_complete_flag := 'Y';
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         IF get_k_end_date_csr%ISOPEN
         THEN
            CLOSE get_k_end_date_csr;
         END IF;

         ROLLBACK TO asset_amortize;
         x_return_status := g_ret_sts_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_AMORTIZATION_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );
         g_amort_complete_flag := 'N';

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         IF get_k_end_date_csr%ISOPEN
         THEN
            CLOSE get_k_end_date_csr;
         END IF;

         ROLLBACK TO asset_amortize;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_AMORTIZATION_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );
         g_amort_complete_flag := 'N';

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         IF get_k_end_date_csr%ISOPEN
         THEN
            CLOSE get_k_end_date_csr;
         END IF;

         ROLLBACK TO asset_amortize;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_AMORTIZATION_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         g_amort_complete_flag := 'N';

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END amortize_assets;

   -- Start of comments
   --
   -- Procedure Name : return_assets
   -- Desciption     : Calls the Asset Return API to return assets of contract
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        :  rmunjulu EDAT modified code to check for quote exists to set reason code
   --                : PAGARG Bug# 3925453: Set the asset return status as
   --                  'RELEASE_IN_PROCESS' for quote type TER_RELEASE_WO_PURCHASE.
   -- End of comments
   PROCEDURE return_assets (
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_klev_tbl          IN              klev_tbl_type,
      p_trn_already_set   IN              VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2,
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      -- Get the non-cancelled asset return for asset
      CURSOR get_asset_return_csr (
         p_kle_id   IN   NUMBER
      )
      IS
         SELECT arr.ID ID,
                okl_am_util_pvt.get_lookup_meaning ('OKL_ASSET_RETURN_STATUS',
                                                    arr.ars_code,
                                                    'N'
                                                   ) ret_status
           FROM okl_asset_returns_v arr
          WHERE arr.kle_id = p_kle_id AND arr.ars_code <> 'CANCELLED';

      l_return_status          VARCHAR2 (1)               := g_ret_sts_success;
      l_overall_status         VARCHAR2 (1)               := g_ret_sts_success;
      lp_artv_rec              okl_am_asset_return_pub.artv_rec_type;
      lx_artv_rec              okl_am_asset_return_pub.artv_rec_type;
      i                        NUMBER                                := 1;
      j                        NUMBER                                := 1;
      l_kle_id                 NUMBER;
      l_k_end_date             DATE                             := g_miss_date;
      l_return_needed          VARCHAR2 (1)                          := g_no;
      l_asset_return_status    VARCHAR2 (2000);
      l_temp_klev_tbl          klev_tbl_type;
      l_api_version   CONSTANT NUMBER                         := g_api_version;
      l_msg_count              NUMBER                            := g_miss_num;
      l_msg_data               VARCHAR2 (2000);
      l_module_name            VARCHAR2 (500)
                                           := g_module_name || 'return_assets';
      is_debug_exception_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      -- rmunjulu EDAT
      l_quote_accpt_date       DATE;
      l_quote_eff_date         DATE;
   BEGIN
      SAVEPOINT asset_return;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_type: '
                                  || p_term_rec.p_quote_type
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                                 'In param, px_tcnv_rec.tmt_asset_return_yn: '
                              || px_tcnv_rec.tmt_asset_return_yn
                             );

         IF p_klev_tbl.COUNT > 0
         THEN
            FOR i IN p_klev_tbl.FIRST .. p_klev_tbl.LAST
            LOOP
               IF (p_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || p_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || p_klev_tbl (i).p_asset_name
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Check if asset return required
      IF    (    p_trn_already_set = g_yes
             AND NVL (px_tcnv_rec.tmt_asset_return_yn, '?') <> g_yes
            )
         OR (p_trn_already_set = g_no)
      THEN
         -- RMUNJULU 3018641 Step Message
         -- Step : Asset Return
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_AM_STEP_ART');

         -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

         -- rmunjulu EDAT
         -- If quote exists then accnting date is quote accept date else sysdate
         IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
         THEN
            l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
            l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
         ELSE
            l_quote_accpt_date := p_sys_date;
            l_quote_eff_date := p_sys_date;
         END IF;

         -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

         -- if assets present for contract
         IF (p_klev_tbl.COUNT > 0)
         THEN
            -- Loop thru assets table
            i := p_klev_tbl.FIRST;

            LOOP
               l_return_needed := g_no;

               -- Check if return created
               OPEN get_asset_return_csr (p_klev_tbl (i).p_kle_id);

               FETCH get_asset_return_csr
                INTO l_kle_id,
                     l_asset_return_status;

               IF get_asset_return_csr%NOTFOUND OR l_kle_id IS NULL
               THEN
                  l_return_needed := g_yes;
               END IF;

               CLOSE get_asset_return_csr;

               -- if no return try creating else set message
               IF l_return_needed = g_yes
               THEN
                  -- set the temp table to contain all assets returned NOW
                  l_temp_klev_tbl (j).p_kle_id := p_klev_tbl (i).p_kle_id;
                  l_temp_klev_tbl (j).p_asset_name :=
                                                  p_klev_tbl (i).p_asset_name;
                  j := j + 1;
                  -- set the asset return id
                  lp_artv_rec.kle_id := p_klev_tbl (i).p_kle_id;

                  -- set the art1_code for asset return 'OKL_ASSET_RETURN_TYPE'
                  -- if early termination assume from quote else contract exp
                  --                  IF (l_k_end_date <> OKL_API.G_MISS_DATE)
                  --                  AND (TRUNC(l_k_end_date) < TRUNC(p_sys_date)) THEN
                  -- rmunjulu EDAT modified condition to say if quote exists then EXE_TERMINATION_QUOTE else EXPIRATION
                  IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') =
                                                                          'Y'
                  THEN
                     -- rmunjulu EDAT
                     lp_artv_rec.art1_code := 'EXE_TERMINATION_QUOTE';
                  ELSE
                     lp_artv_rec.art1_code := 'CONTRACT_EXPIRATION';
                  END IF;

                  --Bug# 3925453: pagarg +++ T and A +++++++ Start ++++++++++
                  IF p_term_rec.p_quote_type = 'TER_RELEASE_WO_PURCHASE'
                  THEN
                     lp_artv_rec.ars_code := 'RELEASE_IN_PROCESS';
                  ELSE
                     -- set the ars_code for asset return 'OKL_ASSET_RETURN_STATUS'
                     lp_artv_rec.ars_code := 'SCHEDULED';
                  END IF;

                  --Bug# 3925453: pagarg +++ T and A +++++++ End ++++++++++

                  --Bug #3925453: pagarg +++ T and A ++++
                  -- Passing quote_id also to create_asset_return
                  -- call asset return
                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling OKL_AM_ASSET_RETURN_PUB.create_asset_return'
                        );
                  END IF;

                  okl_am_asset_return_pub.create_asset_return
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_artv_rec           => lp_artv_rec,
                                           x_artv_rec           => lx_artv_rec,
                                           p_quote_id           => p_term_rec.p_quote_id
                                          );

                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                            'called OKL_AM_ASSET_RETURN_PUB.create_asset_return , return status: '
                         || l_return_status
                        );
                  END IF;

                  IF l_return_status <> g_ret_sts_success
                  THEN
                     -- Error occurred during the creation of an asset
                     -- return record for asset  NAME.
                     okl_api.set_message
                                (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_ERR_ASS_RET',
                                 p_token1            => 'NAME',
                                 p_token1_value      => p_klev_tbl (i).p_asset_name
                                );
                     -- Raise exception to rollback to savepoint if error
                     RAISE okl_api.g_exception_error;
                  END IF;
               ELSE
                  -- Asset return already exists -- This is not an error

                  -- Asset Return already exists for this asset NAME with the
                  -- status STATUS so cannot create a new asset return now.
                  okl_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKL_AM_ASS_RET_ARS_ERR',
                                p_token1            => 'NAME',
                                p_token1_value      => p_klev_tbl (i).p_asset_name,
                                p_token2            => 'STATUS',
                                p_token2_value      => l_asset_return_status
                               );
               END IF;

               EXIT WHEN (i = p_klev_tbl.LAST);
               i := p_klev_tbl.NEXT (i);
            END LOOP;

            -- Set success messages once all returns done NOW
            IF l_temp_klev_tbl.COUNT > 0
            THEN
               i := l_temp_klev_tbl.FIRST;

               LOOP
                  -- Asset return created for asset  NAME.
                  okl_api.set_message
                           (p_app_name          => g_app_name,
                            p_msg_name          => 'OKL_AM_ASS_RET_CREATED',
                            p_token1            => 'NAME',
                            p_token1_value      => l_temp_klev_tbl (i).p_asset_name
                           );
                  EXIT WHEN (i = l_temp_klev_tbl.LAST);
                  i := l_temp_klev_tbl.NEXT (i);
               END LOOP;
            END IF;

            -- set the transaction record for asset return
            set_transaction_rec (p_return_status       => l_return_status,
                                 p_overall_status      => px_overall_status,
                                 p_tmt_flag            => 'TMT_ASSET_RETURN_YN',
                                 p_tsu_code            => 'WORKING',
                                 px_tcnv_rec           => px_tcnv_rec
                                );
            -- Set overall status
            set_overall_status (p_return_status        => l_return_status,
                                px_overall_status      => px_overall_status);
         END IF;
      END IF;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         IF get_asset_return_csr%ISOPEN
         THEN
            CLOSE get_asset_return_csr;
         END IF;

         ROLLBACK TO asset_return;
         x_return_status := g_ret_sts_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_RETURN_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         IF get_asset_return_csr%ISOPEN
         THEN
            CLOSE get_asset_return_csr;
         END IF;

         ROLLBACK TO asset_return;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_RETURN_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         IF get_asset_return_csr%ISOPEN
         THEN
            CLOSE get_asset_return_csr;
         END IF;

         ROLLBACK TO asset_return;
         x_return_status := g_ret_sts_unexp_error;
         -- store the highest degree of error
         set_overall_status (p_return_status        => x_return_status,
                             px_overall_status      => px_overall_status);
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_RETURN_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_ASSET_DISPOSITION_YN',
                              p_tsu_code            => 'ERROR',
                              p_ret_val             => NULL,
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END return_assets;

   -- Start of comments
   --
   -- Procedure Name : close_balances
   -- Desciption     : Calls the AR adjustments apis for K header and
   --                  Lines to close balances
   -- Business Rules :
   -- Parameters     :
   -- Version      : 1.0
   -- History        : RMUNJULU 03-JAN-03 2683876 Created
   --                : RMUNJULU 07-APR-03 2883292 Changed IF to check for NULL
   --                  tolerance_amt instead of -1
   --                : RMUNJULU 28-APR-04 3596626 Added code to set lp_acc_gen_primary_key_tbl
   --
   -- End of comments
   PROCEDURE close_balances (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_term_rec        IN              term_rec_type,
      p_sys_date        IN              DATE,
      p_tcnv_rec        IN              tcnv_rec_type,
      px_msg_tbl        IN OUT NOCOPY   g_msg_tbl
   )
   IS
      -- Cursor to get the balances of contract
      CURSOR k_balances_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT SUM (blp.amount_due_remaining)
           FROM okl_bpd_leasing_payment_trx_v blp
          WHERE blp.contract_id = p_khr_id;

      -- Cursor to get the lines with amount due and payment schedule id for the balances
      CURSOR k_bal_lns_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT oblp.amount_due_remaining amount,
                oblp.stream_type_id stream_type_id,
                osty.NAME stream_meaning,
                oblp.payment_schedule_id schedule_id,
                oblp.receivables_invoice_number ar_invoice_number,
                otil.ID til_id,
                -999 tld_id
           FROM okl_bpd_leasing_payment_trx_v oblp,
                okl_txl_ar_inv_lns_v otil,
                okl_strm_type_v osty
          WHERE oblp.contract_id = p_khr_id
            AND oblp.receivables_invoice_id = otil.receivables_invoice_id
            AND oblp.stream_type_id = osty.ID
            AND oblp.amount_due_remaining > 0
         UNION
         SELECT oblp.amount_due_remaining amount,
                oblp.stream_type_id stream_type_id,
                osty.NAME stream_meaning,
                oblp.payment_schedule_id schedule_id,
                oblp.receivables_invoice_number ar_invoice_number,
                otai.til_id_details til_id,
                otai.ID tld_id
           FROM okl_bpd_leasing_payment_trx_v oblp,
                okl_txd_ar_ln_dtls_v otai,
                okl_strm_type_v osty
          WHERE oblp.contract_id = p_khr_id
            AND oblp.receivables_invoice_id = otai.receivables_invoice_id
            AND oblp.stream_type_id = osty.ID
            AND oblp.amount_due_remaining > 0;

      -- Cursor to get the product of the contract
      CURSOR prod_id_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT khr.pdt_id
           FROM okl_k_headers_v khr
          WHERE khr.ID = p_khr_id;

      -- Cursor to get the distribution for the transaction id and
      -- transaction table
      -- Make sure we get the debit distribution and also it is 100percent
      CURSOR code_combination_id_csr (
         p_source_id      IN   NUMBER,
         p_source_table   IN   VARCHAR2
      )
      IS
         SELECT dst.code_combination_id
           FROM okl_trns_acc_dstrs dst
          WHERE dst.source_id = p_source_id
            AND dst.source_table = p_source_table
            AND dst.cr_dr_flag = 'C'
            AND dst.percentage = 100;

      k_bal_lns_rec                k_bal_lns_csr%ROWTYPE;
      l_return_status              VARCHAR2 (1)   := okl_api.g_ret_sts_success;
      lp_adjv_rec                  okl_trx_ar_adjsts_pub.adjv_rec_type;
      lx_adjv_rec                  okl_trx_ar_adjsts_pub.adjv_rec_type;
      lp_ajlv_tbl                  okl_txl_adjsts_lns_pub.ajlv_tbl_type;
      lx_ajlv_tbl                  okl_txl_adjsts_lns_pub.ajlv_tbl_type;
      l_early_termination_yn       VARCHAR2 (1)             := okl_api.g_false;
      l_total_amount_due           NUMBER                                := -1;
      l_code_combination_id        NUMBER                                := -1;
      i                            NUMBER                                 := 1;
      l_tolerance_amt              NUMBER                                := -1;
      l_api_name                   VARCHAR2 (30)           := 'close_balances';
      l_module_name                VARCHAR2 (500)
                                          := g_module_name || 'close_balances';
      is_debug_exception_on        BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on        BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on        BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      l_pdt_id                     NUMBER                                 := 0;
      lp_tmpl_identify_rec         okl_account_dist_pub.tmpl_identify_rec_type;
      lp_dist_info_rec             okl_account_dist_pub.dist_info_rec_type;
      lp_ctxt_val_tbl              okl_account_dist_pub.ctxt_val_tbl_type;
      lp_acc_gen_primary_key_tbl   okl_account_dist_pub.acc_gen_primary_key;
      lx_template_tbl              okl_account_dist_pub.avlv_tbl_type;
      lx_amount_tbl                okl_account_dist_pub.amount_tbl_type;
      l_try_id                     NUMBER;
      l_trans_meaning              VARCHAR2 (200);
      l_currency_code              VARCHAR2 (200);
      l_formatted_bal_amt          VARCHAR2 (200);
      l_formatted_tol_amt          VARCHAR2 (200);
      l_formatted_adj_amt          VARCHAR2 (200);
      l_functional_currency_code   VARCHAR2 (15);
      l_contract_currency_code     VARCHAR2 (15);
      l_currency_conversion_type   VARCHAR2 (30);
      l_currency_conversion_rate   NUMBER;
      l_currency_conversion_date   DATE;
      l_converted_amount           NUMBER;
      -- Since we do not use the amount or converted amount
      -- set a hardcoded value for the amount (and pass to to
      -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
      -- conversion values )
      l_hard_coded_amount          NUMBER                               := 100;
      l_count                      NUMBER;
   BEGIN
      ---
      --get the tolerance limit from profile
      -- get the total balances of ARs for the contract
      -- if total balance amount within the tolerance limit then
      -- close balances
      -- end if

      -- Establish savepoint so that when error rollback
      SAVEPOINT close_balances;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_tcnv_rec.id: ' || p_tcnv_rec.ID
                                 );
      END IF;

      l_count := px_msg_tbl.COUNT;

      -- get the total balances of ARs for the contract
      OPEN k_balances_csr (p_term_rec.p_contract_id);

      FETCH k_balances_csr
       INTO l_total_amount_due;

      CLOSE k_balances_csr;

      -- set the total amount if it is null
      IF l_total_amount_due IS NULL
      THEN
         l_total_amount_due := 0;
      END IF;

      -- RMUNJULU 3018641 Step Message
      -- Step : Close Balances
      okl_api.set_message (p_app_name      => g_app_name,
                           p_msg_name      => 'OKL_AM_STEP_CLB');

      -- Check if total amount due is +ve else set message and exit
      IF l_total_amount_due <= 0
      THEN
         -- No outstanding balances found.
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_AM_NO_BAL');
      ELSE
         -- can try closing balances

         --get the tolerance limit from profile
         fnd_profile.get ('OKL_SMALL_BALANCE_TOLERANCE', l_tolerance_amt);

         -- if no tolerance amt then assume tolerance amt = 0 ,
         -- raise warning msg and proceed
         -- RMUNJULU 07-APR-03 2883292 Changed IF to check for NULL instead of -1
         IF l_tolerance_amt IS NULL
         THEN
            l_tolerance_amt := 0;
            -- No tolerance amount found for closing of balances.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_NO_TOL_AMT');
         END IF;

         -- IF total balance amount within the tolerance limit and amount due>0 then
         IF (l_total_amount_due <= l_tolerance_amt)
         THEN
            -- set the adjusts rec
            lp_adjv_rec.trx_status_code := 'WORKING';             -- tsu_code
            -- tcn_id is set to transaction id from transaction rec
            lp_adjv_rec.tcn_id := p_tcnv_rec.ID;
            -- adjustment_reason_code comes from OKL_ADJUSTMENT_REASON
            lp_adjv_rec.adjustment_reason_code := 'SMALL AMT REMAINING';
            lp_adjv_rec.apply_date := p_sys_date;
            lp_adjv_rec.gl_date := p_sys_date;

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling OKL_TRX_AR_ADJSTS_PUB.insert_trx_ar_adjsts'
                        );
            END IF;

            -- call the adjusts api
            okl_trx_ar_adjsts_pub.insert_trx_ar_adjsts
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => okl_api.g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_adjv_rec           => lp_adjv_rec,
                                           x_adjv_rec           => lx_adjv_rec
                                          );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_TRX_AR_ADJSTS_PUB.insert_trx_ar_adjsts , return status: '
                   || l_return_status
                  );
            END IF;

            IF l_return_status <> g_ret_sts_success
            THEN
               -- Error occurred when creating adjustment
               -- records to write off balances.
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_AM_ERR_ADJST_BAL');
            END IF;

            -- Raise exception to rollback this whole block
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                 'calling OKL_AM_UTIL_PVT.get_transaction_id'
                                );
            END IF;

            -- Get the transaction id for adjustments
            okl_am_util_pvt.get_transaction_id
                                          (p_try_name           => 'Balance Write off',
                                           x_return_status      => l_return_status,
                                           x_try_id             => l_try_id
                                          );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_AM_UTIL_PVT.get_transaction_id , return status: '
                   || l_return_status
                  );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'l_try_id: ' || l_try_id
                                       );
            END IF;

            IF l_return_status <> g_ret_sts_success
            THEN
               -- Message: Unable to find a transaction type for
               -- the transaction TRY_NAME
               okl_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKL_AM_NO_TRX_TYPE_FOUND',
                                    p_token1            => 'TRY_NAME',
                                    p_token1_value      => l_trans_meaning
                                   );
            END IF;

            -- Raise exception to rollback this whole block
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            -- Get the meaning of lookup BALANCE_WRITE_OFF
            l_trans_meaning :=
               okl_am_util_pvt.get_lookup_meaning
                                (p_lookup_type      => 'OKL_ACCOUNTING_EVENT_TYPE',
                                 p_lookup_code      => 'BALANCE_WRITE_OFF',
                                 p_validate_yn      => 'Y'
                                );

            -- get the product id
            OPEN prod_id_csr (p_term_rec.p_contract_id);

            FETCH prod_id_csr
             INTO l_pdt_id;

            CLOSE prod_id_csr;

            -- raise error message if no pdt_id
            IF l_pdt_id IS NULL OR l_pdt_id = 0
            THEN
               -- Error: Unable to create accounting entries because of a missing
               -- Product Type for the contract CONTRACT_NUMBER.
               okl_api.set_message
                              (p_app_name          => g_app_name,
                               p_msg_name          => 'OKL_AM_PRODUCT_ID_ERROR',
                               p_token1            => 'CONTRACT_NUMBER',
                               p_token1_value      => p_term_rec.p_contract_number
                              );
            END IF;

            -- Raise exception to rollback to savepoint for this block
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            -- Get, set and pass the currency conversion parameters
            -- Get the functional currency from AM_Util
            l_functional_currency_code :=
                                       okl_am_util_pvt.get_functional_currency;

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                   'calling OKL_ACCOUNTING_UTIL.convert_to_functional_currency'
                  );
            END IF;

            -- Get the currency conversion details from ACCOUNTING_Util
            okl_accounting_util.convert_to_functional_currency
                    (p_khr_id                        => p_term_rec.p_contract_id,
                     p_to_currency                   => l_functional_currency_code,
                     p_transaction_date              => p_sys_date,
                     p_amount                        => l_hard_coded_amount,
                     x_return_status                 => l_return_status,
                     x_contract_currency             => l_contract_currency_code,
                     x_currency_conversion_type      => l_currency_conversion_type,
                     x_currency_conversion_rate      => l_currency_conversion_rate,
                     x_currency_conversion_date      => l_currency_conversion_date,
                     x_converted_amount              => l_converted_amount
                    );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called okl_accounting_util.convert_to_functional_currency , return status: '
                   || l_return_status
                  );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_contract_currency_code: '
                                        || l_contract_currency_code
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_currency_conversion_type: '
                                        || l_currency_conversion_type
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_currency_conversion_rate: '
                                        || l_currency_conversion_rate
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_currency_conversion_date: '
                                        || l_currency_conversion_date
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_converted_amount: '
                                        || l_converted_amount
                                       );
            END IF;

            -- If error from OKL_ACCOUNTING_UTIL
            IF l_return_status <> okl_api.g_ret_sts_success
            THEN
               -- Error occurred when creating accounting entries for
               -- transaction TRX_TYPE.
               okl_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKL_AM_ERR_ACC_ENT',
                                    p_token1            => 'TRX_TYPE',
                                    p_token1_value      => l_trans_meaning
                                   );
            END IF;

            -- Raise exception to rollback to savepoint for this block
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            i := 1;

            FOR k_bal_lns_rec IN k_bal_lns_csr (p_term_rec.p_contract_id)
            LOOP
               -- do accounting entries to get code_combination_id
               -- Set the tmpl_identify_rec in parameter
               lp_tmpl_identify_rec.product_id := l_pdt_id;
               lp_tmpl_identify_rec.transaction_type_id := l_try_id;
               lp_tmpl_identify_rec.memo_yn := g_no;
               lp_tmpl_identify_rec.prior_year_yn := g_no;
               lp_tmpl_identify_rec.stream_type_id :=
                                                 k_bal_lns_rec.stream_type_id;
               -- Set the dist_info_rec in parameter
               lp_dist_info_rec.source_id := lx_adjv_rec.ID;
               lp_dist_info_rec.source_table := 'OKL_TRX_AR_ADJSTS_B';
               lp_dist_info_rec.accounting_date := p_sys_date;
               lp_dist_info_rec.gl_reversal_flag := g_no;
               lp_dist_info_rec.post_to_gl := g_no;
               lp_dist_info_rec.contract_id := p_term_rec.p_contract_id;
               lp_dist_info_rec.amount := k_bal_lns_rec.amount;
               -- Set the p_dist_info_rec for currency code
               lp_dist_info_rec.currency_code := l_contract_currency_code;

               -- If the functional currency code is different
               -- from contract currency code
               -- then set the rest of the currency conversion columns
               IF l_functional_currency_code <> l_contract_currency_code
               THEN
                  -- Set the p_dist_info_rec currency conversion columns
                  lp_dist_info_rec.currency_conversion_type :=
                                                   l_currency_conversion_type;
                  lp_dist_info_rec.currency_conversion_rate :=
                                                   l_currency_conversion_rate;
                  lp_dist_info_rec.currency_conversion_date :=
                                                   l_currency_conversion_date;
               END IF;

               -- RMUNJULU 28-APR-04 3596626 Added code to set lp_acc_gen_primary_key_tbl
               -- for account generator
               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                              'calling OKL_ACC_CALL_PVT.okl_populate_acc_gen'
                             );
               END IF;

               okl_acc_call_pvt.okl_populate_acc_gen
                                 (p_contract_id           => p_term_rec.p_contract_id,
                                  p_contract_line_id      => NULL,
                                  x_acc_gen_tbl           => lp_acc_gen_primary_key_tbl,
                                  x_return_status         => l_return_status
                                 );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                         'called OKL_ACC_CALL_PVT.okl_populate_acc_gen , return status: '
                      || l_return_status
                     );
               END IF;

               -- Raise exception to rollback to savepoint for this block
               IF (l_return_status = okl_api.g_ret_sts_unexp_error)
               THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (l_return_status = okl_api.g_ret_sts_error)
               THEN
                  RAISE okl_api.g_exception_error;
               END IF;

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                       (g_level_statement,
                        l_module_name,
                        'calling OKL_ACCOUNT_DIST_PUB.create_accounting_dist'
                       );
               END IF;

               -- call accounting engine
               -- This will calculate the adjstmnts and generate accounting entries
               okl_account_dist_pub.create_accounting_dist
                     (p_api_version                  => p_api_version,
                      p_init_msg_list                => okl_api.g_false,
                      x_return_status                => l_return_status,
                      x_msg_count                    => x_msg_count,
                      x_msg_data                     => x_msg_data,
                      p_tmpl_identify_rec            => lp_tmpl_identify_rec,
                      p_dist_info_rec                => lp_dist_info_rec,
                      p_ctxt_val_tbl                 => lp_ctxt_val_tbl,
                      p_acc_gen_primary_key_tbl      => lp_acc_gen_primary_key_tbl,
                      x_template_tbl                 => lx_template_tbl,
                      x_amount_tbl                   => lx_amount_tbl
                     );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                         'called OKL_ACCOUNT_DIST_PUB.create_accounting_dist , return status: '
                      || l_return_status
                     );
               END IF;

               IF l_return_status <> g_ret_sts_success
               THEN
                  -- Error occurred when creating accounting entries
                  -- for transaction type TRX_TYPE and stream type STREAM_TYPE.
                  okl_api.set_message
                              (p_app_name          => g_app_name,
                               p_msg_name          => 'OKL_AM_ERR_ACC_ENT_MSG',
                               p_token1            => 'TRX_TYPE',
                               p_token1_value      => l_trans_meaning,
                               p_token2            => 'STREAM_TYPE',
                               p_token2_value      => k_bal_lns_rec.stream_meaning
                              );
               END IF;

               -- Raise exception to rollback this whole block
               IF (l_return_status = g_ret_sts_unexp_error)
               THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (l_return_status = g_ret_sts_error)
               THEN
                  RAISE okl_api.g_exception_error;
               END IF;

               -- Get the first code_combination_id for the transaction
               -- from OKL_TRNS_ACC_DSTRS_V
               OPEN code_combination_id_csr (lx_adjv_rec.ID,
                                             'OKL_TRX_AR_ADJSTS_B');

               FETCH code_combination_id_csr
                INTO l_code_combination_id;

               CLOSE code_combination_id_csr;

               -- if code_combination_id not found then raise error
               IF l_code_combination_id = -1 OR l_code_combination_id IS NULL
               THEN
                  -- Error: Unable to process small balance
                  -- adjustments because of a missing Code Combination ID for the
                  -- contract CONTRACT_NUMBER.
                  okl_api.set_message
                              (p_app_name          => g_app_name,
                               p_msg_name          => 'OKL_AM_CODE_CMB_ERROR',
                               p_token1            => 'CONTRACT_NUMBER',
                               p_token1_value      => p_term_rec.p_contract_number
                              );
                  RAISE okl_api.g_exception_error;
               END IF;

               -- Loop thru the code combination ids to set the lns tbl
               FOR code_combination_id_rec IN
                  code_combination_id_csr (lx_adjv_rec.ID,
                                           'OKL_TRX_AR_ADJSTS_B')
               LOOP
                  -- set the tbl for adjsts lns
                  lp_ajlv_tbl (i).adj_id := lx_adjv_rec.ID;
                  lp_ajlv_tbl (i).til_id := k_bal_lns_rec.til_id;

                  IF     k_bal_lns_rec.tld_id <> -999
                     AND k_bal_lns_rec.tld_id IS NOT NULL
                     AND k_bal_lns_rec.tld_id <> okl_api.g_miss_num
                  THEN
                     lp_ajlv_tbl (i).tld_id := k_bal_lns_rec.tld_id;
                  END IF;

                  lp_ajlv_tbl (i).amount := k_bal_lns_rec.amount;
                  lp_ajlv_tbl (i).psl_id := k_bal_lns_rec.schedule_id;
                  lp_ajlv_tbl (i).code_combination_id :=
                                   code_combination_id_rec.code_combination_id;
                  i := i + 1;
               END LOOP;                              -- code combination recs
            END LOOP;                                          -- balances res

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                      (g_level_statement,
                       l_module_name,
                       'calling OKL_TXL_ADJSTS_LNS_PUB.insert_txl_adjsts_lns'
                      );
            END IF;

            --call the txl_lns_adjsts
            okl_txl_adjsts_lns_pub.insert_txl_adjsts_lns
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => okl_api.g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_ajlv_tbl           => lp_ajlv_tbl,
                                           x_ajlv_tbl           => lx_ajlv_tbl
                                          );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_TXL_ADJSTS_LNS_PUB.insert_txl_adjsts_lns , return status: '
                   || l_return_status
                  );
            END IF;

            IF l_return_status <> g_ret_sts_success
            THEN
               -- Error occurred when creating adjustment records to write
               -- off balances.
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_AM_ERR_ADJST_BAL');
            END IF;

            -- Raise exception to rollback this whole block
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            -- Get the currency code for contract
            l_currency_code :=
                   okl_am_util_pvt.get_chr_currency (p_term_rec.p_contract_id);

            -- Set all success messages for all balances
            FOR k_bal_lns_rec IN k_bal_lns_csr (p_term_rec.p_contract_id)
            LOOP
               -- Format the adjustment amt
               l_formatted_adj_amt :=
                  okl_accounting_util.format_amount (k_bal_lns_rec.amount,
                                                     l_currency_code);
               -- Append adjustment amt with currency code
               l_formatted_adj_amt :=
                                l_formatted_adj_amt || ' ' || l_currency_code;
               -- Set the success message in the message table

               -- Adjustment transaction for AR invoice AR_INVOICE_NUM of amount AMOUNT
               -- has been created.
               px_msg_tbl (l_count).msg_desc := 'OKL_AM_ACC_ENT_AR_INV_MSG';
               px_msg_tbl (l_count).msg_token1 := 'AR_INVOICE_NUM';
               px_msg_tbl (l_count).msg_token1_value :=
                                              k_bal_lns_rec.ar_invoice_number;
               px_msg_tbl (l_count).msg_token2 := 'AMOUNT';
               px_msg_tbl (l_count).msg_token2_value := l_formatted_adj_amt;
               l_count := l_count + 1;
               -- Accounting entries created for transaction type TRX_TYPE
               -- and stream type STREAM_TYPE.
               px_msg_tbl (l_count).msg_desc := 'OKL_AM_ACC_ENT_CREATED_MSG';
               px_msg_tbl (l_count).msg_token1 := 'TRX_TYPE';
               px_msg_tbl (l_count).msg_token1_value := l_trans_meaning;
               px_msg_tbl (l_count).msg_token2 := 'STREAM_TYPE';
               px_msg_tbl (l_count).msg_token2_value :=
                                                 k_bal_lns_rec.stream_meaning;
               l_count := l_count + 1;
            END LOOP;
         ELSE
            --(cannot close all balances since tolerance amt is less)

            -- Unable to close all outstanding balances due to tolerance amount.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_ERR_CLOSE_BAL');
            -- Get the currency code for contract
            l_currency_code :=
                  okl_am_util_pvt.get_chr_currency (p_term_rec.p_contract_id);
            -- Format the balance amt
            l_formatted_bal_amt :=
               okl_accounting_util.format_amount (l_total_amount_due,
                                                  l_currency_code);
            -- Append balance amt with currency code
            l_formatted_bal_amt :=
                                l_formatted_bal_amt || ' ' || l_currency_code;
            -- Format the tolerance amt
            l_formatted_tol_amt :=
               okl_accounting_util.format_amount (l_tolerance_amt,
                                                  l_currency_code);
            -- Append tolerance amt with currency code
            l_formatted_tol_amt :=
                                l_formatted_tol_amt || ' ' || l_currency_code;
            -- Outstanding balance BALANCE_AMT exceeds Tolerance Amount TOLERANCE_AMT.
            okl_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKL_AM_BAL_GTR_TOL',
                                 p_token1            => 'BALANCE_AMT',
                                 p_token1_value      => l_formatted_bal_amt,
                                 p_token2            => 'TOLERANCE_AMT',
                                 p_token2_value      => l_formatted_tol_amt
                                );
         END IF;
      END IF;

      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         IF k_balances_csr%ISOPEN
         THEN
            CLOSE k_balances_csr;
         END IF;

         IF k_bal_lns_csr%ISOPEN
         THEN
            CLOSE k_bal_lns_csr;
         END IF;

         IF code_combination_id_csr%ISOPEN
         THEN
            CLOSE code_combination_id_csr;
         END IF;

         ROLLBACK TO close_balances;
         x_return_status := okl_api.g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         IF k_balances_csr%ISOPEN
         THEN
            CLOSE k_balances_csr;
         END IF;

         IF k_bal_lns_csr%ISOPEN
         THEN
            CLOSE k_bal_lns_csr;
         END IF;

         IF code_combination_id_csr%ISOPEN
         THEN
            CLOSE code_combination_id_csr;
         END IF;

         ROLLBACK TO close_balances;
         x_return_status := okl_api.g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         IF k_balances_csr%ISOPEN
         THEN
            CLOSE k_balances_csr;
         END IF;

         IF k_bal_lns_csr%ISOPEN
         THEN
            CLOSE k_bal_lns_csr;
         END IF;

         IF code_combination_id_csr%ISOPEN
         THEN
            CLOSE code_combination_id_csr;
         END IF;

         ROLLBACK TO close_balances;
         x_return_status := okl_api.g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END close_balances;

   -- Start of comments
   --
   -- Procedure Name : mass_rebook
   -- Desciption     : Will do a mass rebook of the contract may have some
   --                  changed lines
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        : RMUNJULU -- 04-DEC-02 Bug # 2484327, removed unnecessary
   --                  cursors and changed others, moved the if condition
   --                  Changed code to set savepoint instead of start/end activity
   --                : RMUNJULU 16-DEC-02 Bug # 2484327, changed cursor to get lines
   --                  which are of the same status as header
   --                : RMUNJULU 20-DEC-02 2484327, corrected the cursor for aliases
   --                : RMUNJULU 07-JAN-03 2736865 Removed processing messages
   --                : RMUNJULU 23-JAN-03 2762065 removed log msgs here, see
   --                  msgs explanation comments in asset_level_termination
   --                : SECHAWLA 10-FEB-03 2793689 Removed the NOT NULL residual
   --                  value condition from l_okclines_csr
   --                  cursor, as the LOAN contracts do not have a residual value.
   --                  Mass Rebook works fine when we pass a null residual value
   --                : RMUNJULU 14-FEB-03 2804703 Added new cursor and check to
   --                  do mass rebook when contract not evergreen
   --                : RMUNJULU 06-MAR-03 Performance Fix Replaced K_LNS_FULL
   --                : RMUNJULU CONTRACT BLOCKING Changed MASS_REBOOK to check if
   --                  the Rebook TRN processed. If NOT then x_mrbk_success = 'E' else 'S'
   --                : RMUNJULU CONTRACT BLOCKING Changed MASS_REBOOK to Call New
   --                  Mass Rebook API done only thru terminations
   --                : rmunjulu EDAT Added code to get quote eff date and call new overloaded mass_rebook api
   --                  which takes trx date as parameter
   -- End of comments
   PROCEDURE mass_rebook (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_term_rec        IN              term_rec_type,
      p_tcnv_rec        IN              tcnv_rec_type,
      p_sys_date        IN              DATE,                 -- rmunjulu EDAT
      x_mrbk_success    OUT NOCOPY      VARCHAR2
   )
   IS
      -- RMUNJULU CONTRACT BLOCKING ADDED

      -- RMUNJULU -- Bug # 2484327 changed to cater to plsql standards
      -- This cursor is used to get a BOOKED contract line.
      -- RMUNJULU 16-DEC-02 Bug # 2484327, get lines which are of the same status as header
      -- RMUNJULU 20-DEC-02 2484327, corrected the cursor for aliases
      -- SECHAWLA 10-FEB-03 2793689, Removed the NOT NULL residual value condition
      -- from the following cursor, as the LOAN contracts do not have a residual value.
      -- Mass Rebook works fine when we pass a null residual value
      -- RMUNJULU 06-MAR-03 Performance Fix Replaced K_LNS_FULL
      CURSOR l_okclines_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT cle.ID ID,
                cle.NAME NAME,
                kle.residual_value residual_value
           FROM okl_k_lines_v kle,
                okc_k_lines_v cle,
                okc_k_headers_v khr
          WHERE cle.chr_id = p_khr_id
            AND cle.chr_id = khr.ID
            AND cle.sts_code = khr.sts_code
            AND kle.ID = cle.ID
            AND ROWNUM < 2;

      --Bug# 3999921: pagarg +++ T and A +++++++ Start ++++++++++
      --Cursor to obtain all the quote asset lines
      CURSOR l_quote_assets_csr (
         p_qte_id   IN   NUMBER
      )
      IS
         SELECT qlt.kle_id
           FROM okl_txl_quote_lines_b qlt
          WHERE qlt.qlt_code = 'AMCFIA' AND qlt.qte_id = p_qte_id;

      l_counter                 NUMBER;

      --Bug# 3999921: pagarg +++ T and A +++++++ End ++++++++++

      -- RMUNJULU 14-FEB-03 2804703 Added cursor
      -- Get the k sts_code
      CURSOR l_k_details_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT khr.sts_code
           FROM okc_k_headers_v khr
          WHERE khr.ID = p_khr_id;

      -- RMUNJULU CONTRACT BLOCKING
      -- RMUNJULU CONTRACT BLOCKING (2)
      -- Get the REBOOK TRN details
      CURSOR get_trn_details_csr (
         p_trx_id   IN   NUMBER
      )
      IS
         SELECT trn.tsu_code
           FROM okl_trx_contracts trn
          WHERE trn.ID = p_trx_id;

      l_strm_lalevl_empty_tbl   okl_mass_rebook_pub.strm_lalevl_tbl_type;
      l_rbk_tbl                 okl_mass_rebook_pub.rbk_tbl_type;
      l_return_status           VARCHAR2 (1)              := g_ret_sts_success;
      l_api_name       CONSTANT VARCHAR2 (30)                 := 'mass_rebook';
      l_module_name             VARCHAR2 (500)
                                             := g_module_name || 'mass_rebook';
      is_debug_exception_on     BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on     BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on     BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      l_api_version    CONSTANT NUMBER                                   := 1;
      l_contract_number         VARCHAR2 (120);
      l_id                      NUMBER;
      l_name                    VARCHAR2 (150);
      l_residual_value          NUMBER;
      l_dummy                   VARCHAR2 (1);
      l_tcnv_rec                tcnv_rec_type                    := p_tcnv_rec;
      -- RMUNJULU 14-FEB-03 2804703 Added variable
      l_sts_code                VARCHAR2 (200);
      -- RMUNJULU CONTRACT BLOCKING (2)
      l_mass_rebook_trx_id      NUMBER;
      -- rmunjulu EDAT
      l_quote_accpt_date        DATE;
      l_quote_eff_date          DATE;
   BEGIN
      -- RMUNJULU Bug # 2484327, added code to set savepoint
      -- Start a savepoint to rollback to if error in this block
      SAVEPOINT mass_rebook;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_tcnv_rec.id: ' || p_tcnv_rec.ID
                                 );
      END IF;

      -- RMUNJULU CONTRACT BLOCKING
      x_mrbk_success := g_ret_sts_success;

      -- Get the contract line details
      OPEN l_okclines_csr (p_term_rec.p_contract_id);

      FETCH l_okclines_csr
       INTO l_id,
            l_name,
            l_residual_value;

      CLOSE l_okclines_csr;

      -- RMUNJULU Bug # 2484327, moved this if down from above cursor loop
      IF l_id IS NULL
      THEN
         -- SECHAWLA 10-FEB-03 2793689: Modified the following message
         -- There are no booked lines for the contract CONTRACT_NUMBER
         okl_api.set_message (p_app_name          => okl_api.g_app_name,
                              p_msg_name          => 'OKL_AM_NO_BOOKED_LINES',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      -- RMUNJULU 14-FEB-03 2804703 get sts_code for contract
      OPEN l_k_details_csr (p_term_rec.p_contract_id);

      FETCH l_k_details_csr
       INTO l_sts_code;

      CLOSE l_k_details_csr;

      -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

      -- rmunjulu EDAT
      -- If quote exists then accnting date is quote accept date else sysdate
      IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
      THEN
         l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
         l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
      ELSE
         l_quote_accpt_date := p_sys_date;
         l_quote_eff_date := p_sys_date;
      END IF;

      -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

      -- RMUNJULU 14-FEB-03 2804703 Added IF to check contract not already
      -- EVERGREEN. Do mass rebook when contract not evergreen
      IF l_sts_code <> 'EVERGREEN'
      THEN
         --Bug# 3999921: pagarg +++ T and A +++++++ Start ++++++++++
         --Pass all the quote assets to mass rebook api
         l_counter := 0;

         FOR l_quote_assets_rec IN l_quote_assets_csr (p_term_rec.p_quote_id)
         LOOP
            l_counter := l_counter + 1;
            l_rbk_tbl (l_counter).khr_id := p_term_rec.p_contract_id;
            l_rbk_tbl (l_counter).kle_id := l_quote_assets_rec.kle_id;
         END LOOP;

         --Bug# 3999921: pagarg +++ T and A +++++++ End ++++++++++
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                              'calling OKL_MASS_REBOOK_PVT.apply_mass_rebook'
                             );
         END IF;

         -- rmunjulu EDAT Changed the signature to call new API which takes transaction date
         okl_mass_rebook_pvt.apply_mass_rebook
            (p_api_version             => p_api_version,
             p_init_msg_list           => g_false,                 --  Changed
             x_return_status           => l_return_status,
             x_msg_count               => x_msg_count,
             x_msg_data                => x_msg_data,
             p_rbk_tbl                 => l_rbk_tbl,
             p_deprn_method_code       => NULL,
             p_in_service_date         => NULL,
             p_life_in_months          => NULL,
             p_basic_rate              => NULL,
             p_adjusted_rate           => NULL,
             --Bug# : pagarg +++ T and A ++++
             --Pass residual value as null
             p_residual_value          => NULL,
             p_strm_lalevl_tbl         => l_strm_lalevl_empty_tbl,
             p_source_trx_id           => p_tcnv_rec.ID,
                                             -- RMUNJULU CONTRACT BLOCKING (2)
             p_source_trx_type         => 'TCN',
                                             -- RMUNJULU CONTRACT BLOCKING (2)
             p_transaction_date        => l_quote_eff_date,   -- rmunjulu EDAT
             x_mass_rebook_trx_id      => l_mass_rebook_trx_id
            );                               -- RMUNJULU CONTRACT BLOCKING (2)

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_MASS_REBOOK_PVT.apply_mass_rebook , return status: '
                || l_return_status
               );
         END IF;

         IF l_return_status <> g_ret_sts_success
         THEN
            -- Mass Rebook failed for the contract CONTRACT_NUMBER
            okl_api.set_message
                              (p_app_name          => g_app_name,
                               p_msg_name          => 'OKL_AM_MASS_REBOOK_FAILED',
                               p_token1            => 'CONTRACT_NUMBER',
                               p_token1_value      => p_term_rec.p_contract_number
                              );
            RAISE okl_api.g_exception_error;
         -- RMUNJULU CONTRACT BLOCKING (2)
         ELSE
            -- Mass Rebook successful
            FOR get_trn_details_rec IN
               get_trn_details_csr (l_mass_rebook_trx_id)
            LOOP
               -- Mass Rebook is NOT Processed
               IF get_trn_details_rec.tsu_code <> 'PROCESSED'
               THEN
                  x_mrbk_success := g_ret_sts_error;
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- Set the x_return_status
      x_return_status := l_return_status;



 -- RBRUNO BUG 6801022  START : UPDATE TERMINATION QUOTES FROM STATUS ACCEPTED


      IF (is_debug_statement_on)     THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'Invoking updating quote status');
                                  end if;

      --IF TERM QUOTE IN STATUS ACCEPTED EXISTS, UPDATE IT TO COMPLETE
      update_quote_status(p_term_rec);

      IF (is_debug_statement_on)   THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'post updating quote status');
                                  end if;
      -- RBRUNO BUG 6801022 END : UPDATE TERMINATION QUOTES FROM STATUS ACCEPTED







     IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         IF l_okclines_csr%ISOPEN
         THEN
            CLOSE l_okclines_csr;
         END IF;

         -- RMUNJULU 14-FEB-03 2804703 Added IF to check if cursor still open
         IF l_k_details_csr%ISOPEN
         THEN
            CLOSE l_k_details_csr;
         END IF;

         -- RMUNJULU Bug # 2484327 added code to rollback to savepoint and set
         -- return status
         ROLLBACK TO mass_rebook;
         x_return_status := g_ret_sts_error;
         -- RMUNJULU CONTRACT BLOCKING
         x_mrbk_success := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         IF l_okclines_csr%ISOPEN
         THEN
            CLOSE l_okclines_csr;
         END IF;

         -- RMUNJULU 14-FEB-03 2804703 Added IF to check if cursor still open
         IF l_k_details_csr%ISOPEN
         THEN
            CLOSE l_k_details_csr;
         END IF;

         -- RMUNJULU Bug # 2484327 added code to rollback to savepoint and set
         -- return status
         ROLLBACK TO mass_rebook;
         x_return_status := g_ret_sts_unexp_error;
         -- RMUNJULU CONTRACT BLOCKING
         x_mrbk_success := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         IF l_okclines_csr%ISOPEN
         THEN
            CLOSE l_okclines_csr;
         END IF;

         -- RMUNJULU 14-FEB-03 2804703 Added IF to check if cursor still open
         IF l_k_details_csr%ISOPEN
         THEN
            CLOSE l_k_details_csr;
         END IF;

         -- RMUNJULU Bug # 2484327 added code to rollback to savepoint and set
         -- return status
         ROLLBACK TO mass_rebook;
         x_return_status := g_ret_sts_unexp_error;
         -- RMUNJULU CONTRACT BLOCKING
         x_mrbk_success := g_ret_sts_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END mass_rebook;

   -- Start of comments
   --
   -- Procedure Name : cancel_activate_insurance
   -- Desciption     : Will cancel and reactivate the insurances for the contract
   -- Business Rules :
   -- Parameters     :
   -- Version      : 1.0
   -- History        : RMUNJULU -- 04-DEC-02 Bug # 2484327
   --                  Changed code to set savepoint instead of start/end activity
   --                : RMUNJULU 14-FEB-03 2804703 Added code to check if contract
   --                  is EVERGREEN
   --                : RMUNJULU 03-MAR-03 2830997 Fixed the exception block
   --
   -- End of comments
   PROCEDURE cancel_activate_insurance (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_term_rec        IN              term_rec_type,
      p_sys_date        IN              DATE,
      p_klev_tbl        IN              klev_tbl_type
   )
   IS
      -- Cursor to get the end date of contract
      -- RMUNJULU 14-FEB-03 2804703 Added code to get sts_code
      CURSOR k_end_date_csr (
         p_chr_id   IN   NUMBER
      )
      IS
         SELECT khr.end_date end_date,
                khr.sts_code sts_code
           FROM okc_k_headers_v khr
          WHERE khr.ID = p_chr_id;

      l_k_end_date             DATE;
      l_return_status          VARCHAR2 (1)   := g_ret_sts_success;
      l_early_termination_yn   VARCHAR2 (1)   := g_no;
      i                        NUMBER;
      l_api_name               VARCHAR2 (30)  := 'cancel_act_insurance';
      l_module_name            VARCHAR2 (500)
                               := g_module_name || 'cancel_activate_insurance';
      is_debug_exception_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      l_api_version   CONSTANT NUMBER         := 1;
      -- RMUNJULU 14-FEB-03 2804703 Added variable
      l_sts_code               VARCHAR2 (200);
   BEGIN
      -- RMUNJULU Bug # 2484327, added code to set savepoint
      -- Start a savepoint to rollback to if error in this block
      SAVEPOINT cancel_activate_insurance;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'In param, p_term_rec.p_early_termination_yn: '
                            || p_term_rec.p_early_termination_yn
                           );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
      END IF;

      -- Get k end date
      -- RMUNJULU 14-FEB-03 2804703 Added sts_code
      OPEN k_end_date_csr (p_term_rec.p_contract_id);

      FETCH k_end_date_csr
       INTO l_k_end_date,
            l_sts_code;

      CLOSE k_end_date_csr;

      -- check if early termination
      IF TRUNC (l_k_end_date) > TRUNC (p_sys_date)
      THEN
         l_early_termination_yn := g_yes;
      END IF;

      -- if early termination then
      -- RMUNJULU 14-FEB-03 2804703 Added condition to check if contract not
      -- already evergreen
      IF     (   NVL (p_term_rec.p_early_termination_yn, '?') = g_yes
              OR l_early_termination_yn = g_yes
             )
         AND l_sts_code <> 'EVERGREEN'
      THEN
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                 (g_level_statement,
                  l_module_name,
                  'calling OKL_INSURANCE_POLICIES_PUB.cancel_create_policies'
                 );
         END IF;

         -- cancel and reactivate insurances
         okl_insurance_policies_pub.cancel_create_policies
                                        (p_api_version            => p_api_version,
                                         p_init_msg_list          => g_false,
                                         x_return_status          => l_return_status,
                                         x_msg_count              => x_msg_count,
                                         x_msg_data               => x_msg_data,
                                         p_khr_id                 => p_term_rec.p_contract_id,
                                         p_cancellation_date      => p_sys_date,
                                         p_transaction_id         => NULL
                                        );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_INSURANCE_POLICIES_PUB.cancel_create_policies , return status: '
                || l_return_status
               );
         END IF;

         IF l_return_status <> g_ret_sts_success
         THEN
            -- Error in cancelling Insurance.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_ERR_CAN_INS');
         END IF;

         -- Raise exception to rollback to the savepoint
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;
      END IF;

      -- Set the return status
      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF k_end_date_csr%ISOPEN
         THEN
            CLOSE k_end_date_csr;
         END IF;

         -- RMUNJULU Bug # 2484327 added code to rollback to savepoint and set
         -- return status
         ROLLBACK TO cancel_activate_insurance;
         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF k_end_date_csr%ISOPEN
         THEN
            CLOSE k_end_date_csr;
         END IF;

         -- RMUNJULU Bug # 2484327 added code to rollback to savepoint and set
         -- return status
         ROLLBACK TO cancel_activate_insurance;
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF k_end_date_csr%ISOPEN
         THEN
            CLOSE k_end_date_csr;
         END IF;

         -- RMUNJULU Bug # 2484327 added code to rollback to savepoint and set
         -- return status
         ROLLBACK TO cancel_activate_insurance;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END cancel_activate_insurance;

   -- Start of comments
   --
   -- Procedure Name : reverse_loss_provisions
   -- Desciption     : Will reverse the non-incomes and loss provisions for contract
   -- Business Rules :
   -- Parameters   :
   -- Version    : 1.0
   -- History        : RMUNJULU 09-JAN-03  2743604 Created
   --                : RMUNJULU 03-MAR-03 2830997 Fixed the exception block
   --                : RMUNJULU Bug # 3097068 20-AUG-03 Added code to pass
   --                  valid GL date to REVERSE LOSS PROVISIONS
   --                : RMUNJULU Bug # 3148215 19-SEP-03 Added code to pass
   --                  valid GL date to CATCHUP OF ACCRUALS
   --
   -- End of comments
   PROCEDURE reverse_loss_provisions (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_term_rec        IN              term_rec_type,
      p_sys_date        IN              DATE,
      px_msg_tbl        IN OUT NOCOPY   g_msg_tbl
   )
   IS
      -- Cursor to get the product of the contract
      CURSOR prod_id_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT A.pdt_id, A.MULTI_GAAP_YN, B.REPORTING_PDT_ID
           FROM okl_k_headers_v A,
                okl_products B
          WHERE A.ID = p_khr_id
          AND   B.ID = A.pdt_id; -- MGAAP 7263041

      l_return_status         VARCHAR2 (1)                := g_ret_sts_success;
      l_try_id                NUMBER;
      l_trans_meaning         VARCHAR2 (200);
      l_pdt_id                NUMBER                                     := 0;

      -- MGAAP 7263041 start
      l_reporting_pdt_id      NUMBER                                     := 0;
      l_multi_gaap_yn      okl_k_headers.MULTI_GAAP_YN%TYPE              := null;
      l_valid_gl_date_rep     DATE;
      l_sob_id_rep            NUMBER;
      -- MGAAP 7263041 end

      l_catchup_rec           okl_generate_accruals_pub.accrual_rec_type;
      lx_tcnv_tbl             okl_trx_contracts_pub.tcnv_tbl_type;
      lx_tclv_tbl             okl_trx_contracts_pub.tclv_tbl_type;
      l_lprv_rec              okl_rev_loss_prov_pub.lprv_rec_type;
      l_count                 NUMBER;
      l_module_name           VARCHAR2 (500)
                                 := g_module_name || 'reverse_loss_provisions';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      -- Bug 3097068
      l_valid_gl_date         DATE;
   BEGIN
      -- Start a savepoint to rollback to if error in this block
      SAVEPOINT reverse_loss_provisions;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );
      END IF;

-- *************
-- REVERSAL OF NON-INCOME
-- *************
      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                 'calling OKL_AM_UTIL_PVT.get_transaction_id'
                                );
      END IF;

      -- Get the transaction id for Accrual
      okl_am_util_pvt.get_transaction_id (p_try_name           => 'Accrual',
                                          x_return_status      => l_return_status,
                                          x_try_id             => l_try_id
                                         );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
            (g_level_statement,
             l_module_name,
                'called OKL_AM_UTIL_PVT.get_transaction_id , return status: '
             || l_return_status
            );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_try_id: ' || l_try_id
                                 );
      END IF;

      -- Get the meaning of lookup
      l_trans_meaning :=
         okl_am_util_pvt.get_lookup_meaning
                                (p_lookup_type      => 'OKL_ACCOUNTING_EVENT_TYPE',
                                 p_lookup_code      => 'ACCRUAL',
                                 p_validate_yn      => 'Y'
                                );

      IF l_return_status <> g_ret_sts_success
      THEN
         -- Unable to find a transaction type for
         -- the transaction TRY_NAME
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_NO_TRX_TYPE_FOUND',
                              p_token1            => 'TRY_NAME',
                              p_token1_value      => l_trans_meaning
                             );
         -- Unable to do reversal of non-income during termination
         -- of contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_REV_NONINC_ERR',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
      END IF;

      -- Raise exception to rollback this whole block
      IF (l_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- get the product id
      OPEN prod_id_csr (p_term_rec.p_contract_id);

      FETCH prod_id_csr
       INTO l_pdt_id,
            l_multi_gaap_yn,
            l_reporting_pdt_id;  -- MGAAP 7263041

      CLOSE prod_id_csr;

      -- raise error if no pdt_id
      IF l_pdt_id IS NULL OR l_pdt_id = 0
      THEN
         -- Unable to do reversal of non-income during termination
         -- of contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_REV_NONINC_ERR',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      -- Bug 3097068 Added to get the valid GL date
      l_valid_gl_date :=
               okl_accounting_util.get_valid_gl_date (p_gl_date      => p_sys_date);
      -- Set the l_catchup_rec rec type
      l_catchup_rec.contract_id := p_term_rec.p_contract_id;
      l_catchup_rec.accrual_date := l_valid_gl_date;       -- RMUNJULU 3148215
      l_catchup_rec.contract_number := p_term_rec.p_contract_number;
      l_catchup_rec.rule_result := g_yes;
      l_catchup_rec.override_status := g_no;
      l_catchup_rec.product_id := l_pdt_id;
      l_catchup_rec.trx_type_id := l_try_id;
      l_catchup_rec.advance_arrears := NULL;
      l_catchup_rec.factoring_synd_flag := NULL;
      l_catchup_rec.post_to_gl := g_yes;
      l_catchup_rec.gl_reversal_flag := g_no;
      l_catchup_rec.memo_yn := g_no;
      l_catchup_rec.description :=
                            'Catchup of income on termination of the contract';

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling OKL_GENERATE_ACCRUALS_PUB.catchup_accruals'
                        );
      END IF;

      -- Do reversal of non-income
      okl_generate_accruals_pub.catchup_accruals
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_catchup_rec        => l_catchup_rec,
                                           x_tcnv_tbl           => lx_tcnv_tbl,
                                           x_tclv_tbl           => lx_tclv_tbl
                                          );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
            (g_level_statement,
             l_module_name,
                'called OKL_GENERATE_ACCRUALS_PUB.catchup_accruals , return status: '
             || l_return_status
            );
      END IF;

      IF l_return_status <> g_ret_sts_success
      THEN
         -- Unable to do reversal of non-income during termination
         -- of contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_REV_NONINC_ERR',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
      END IF;

      -- Raise exception to rollback this whole block
      IF (l_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;

   -- Bug 7263041 start

   IF (l_multi_gaap_yn = 'Y') THEN

      l_sob_id_rep := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID(
                                     p_representation_type => 'SECONDARY');

      l_valid_gl_date_rep :=
               okl_accounting_util.get_valid_gl_date (
                                 p_gl_date      => p_sys_date,
                                 p_ledger_id    => l_sob_id_rep
               );
      l_catchup_rec.product_id := l_reporting_pdt_id;
      l_catchup_rec.accrual_date := l_valid_gl_date_rep;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling OKL_GENERATE_ACCRUALS_PUB.catchup_accruals for SECONDARY'
                        );
      END IF;

      -- Do reversal of non-income
      okl_generate_accruals_pub.catchup_accruals
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_catchup_rec        => l_catchup_rec,
                                           x_tcnv_tbl           => lx_tcnv_tbl,
                                           x_tclv_tbl           => lx_tclv_tbl,
                                           p_representation_type => 'SECONDARY'
                                          );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
            (g_level_statement,
             l_module_name,
                'called OKL_GENERATE_ACCRUALS_PUB.catchup_accruals for SECONDARY, return status: '
             || l_return_status
            );
      END IF;

      IF l_return_status <> g_ret_sts_success
      THEN
         -- Unable to do reversal of non-income during termination
         -- of contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_REV_NONINC_ERR',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
      END IF;

      -- Raise exception to rollback this whole block
      IF (l_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;


   END IF;
   -- Bug 7263041 end

-- *************
-- REVERSAL OF LOSS-PROVISIONS
-- *************

      -- Set the l_lprv_rec rec type
      l_lprv_rec.cntrct_num := p_term_rec.p_contract_number;
      l_lprv_rec.reversal_type := NULL;
      -- RMUNJULU 3097068 Added code to set the reversal date with valid GL date
      l_lprv_rec.reversal_date := l_valid_gl_date;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'calling OKL_REV_LOSS_PROV_PUB.reverse_loss_provisions'
                     );
      END IF;

      -- Do reversal of loss provisions
      okl_rev_loss_prov_pub.reverse_loss_provisions
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_lprv_rec           => l_lprv_rec
                                          );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
            (g_level_statement,
             l_module_name,
                'called OKL_REV_LOSS_PROV_PUB.reverse_loss_provisions , return status: '
             || l_return_status
            );
      END IF;

      IF l_return_status <> g_ret_sts_success
      THEN
         -- Unable to do reversal of loss provisions during
         -- termination of contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_REV_LOSPROV_ERR',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
      END IF;

      -- Raise exception to rollback this whole block
      IF (l_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- Set the success messages to message table
      l_count := px_msg_tbl.COUNT;
      -- Reversal of non-income during termination
      -- of contract CONTRACT_NUMBER done successfully.
      px_msg_tbl (l_count).msg_desc := 'OKL_AM_REV_NONINC_SUC';
      px_msg_tbl (l_count).msg_token1 := 'CONTRACT_NUMBER';
      px_msg_tbl (l_count).msg_token1_value := p_term_rec.p_contract_number;
      l_count := l_count + 1;
      -- Reversal of loss provisions during
      -- termination of contract CONTRACT_NUMBER done successfully.
      px_msg_tbl (l_count).msg_desc := 'OKL_AM_REV_LOSPROV_SUC';
      px_msg_tbl (l_count).msg_token1 := 'CONTRACT_NUMBER';
      px_msg_tbl (l_count).msg_token1_value := p_term_rec.p_contract_number;
      l_count := l_count + 1;
      -- Set the return status
      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF prod_id_csr%ISOPEN
         THEN
            CLOSE prod_id_csr;
         END IF;

         ROLLBACK TO reverse_loss_provisions;
         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF prod_id_csr%ISOPEN
         THEN
            CLOSE prod_id_csr;
         END IF;

         ROLLBACK TO reverse_loss_provisions;
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF prod_id_csr%ISOPEN
         THEN
            CLOSE prod_id_csr;
         END IF;

         ROLLBACK TO reverse_loss_provisions;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END reverse_loss_provisions;

   -- Start of comments
   --
   -- Procedure Name : cancel_insurance
   -- Desciption     : Will cancel the insurances for the contract
   -- Business Rules :
   -- Parameters     :
   -- Version      : 1.0
   -- History        : RMUNJULU -- 20-DEC-02 2484327 Created
   --                : RMUNJULU 14-FEB-03 2804703 Added code to check if contract
   --                  is EVERGREEN
   --                : RMUNJULU 03-MAR-03 2830997 Fixed the exception block
   --
   -- End of comments
   PROCEDURE cancel_insurance (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_term_rec        IN              term_rec_type,
      p_sys_date        IN              DATE,
      p_klev_tbl        IN              klev_tbl_type
   )
   IS
      -- Cursor to get the end date of contract
      -- RMUNJULU 14-FEB-03 2804703 Added code to get sts_code
      CURSOR k_end_date_csr (
         p_chr_id   IN   NUMBER
      )
      IS
         SELECT khr.end_date end_date,
                khr.sts_code sts_code
           FROM okc_k_headers_v khr
          WHERE khr.ID = p_chr_id;

      l_k_end_date             DATE;
      l_return_status          VARCHAR2 (1)   := g_ret_sts_success;
      l_early_termination_yn   VARCHAR2 (1)   := g_no;
      i                        NUMBER;
      l_api_name               VARCHAR2 (30)  := 'cancel_insurance';
      l_api_version   CONSTANT NUMBER         := 1;
      l_module_name            VARCHAR2 (500)
                                        := g_module_name || 'cancel_insurance';
      is_debug_exception_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      -- RMUNJULU 14-FEB-03 2804703 Added variable
      l_sts_code               VARCHAR2 (200);
   BEGIN
      -- Start a savepoint to rollback to if error in this block
      SAVEPOINT cancel_insurance;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'In param, p_term_rec.p_early_termination_yn: '
                            || p_term_rec.p_early_termination_yn
                           );
      END IF;

      -- Get k end date
      -- RMUNJULU 14-FEB-03 2804703 Added sts_code
      OPEN k_end_date_csr (p_term_rec.p_contract_id);

      FETCH k_end_date_csr
       INTO l_k_end_date,
            l_sts_code;

      CLOSE k_end_date_csr;

      -- check if early termination
      IF TRUNC (l_k_end_date) > TRUNC (p_sys_date)
      THEN
         l_early_termination_yn := g_yes;
      END IF;

      -- if early termination then
      -- RMUNJULU 14-FEB-03 2804703 Added condition to check if contract not
      -- already evergreen
      IF     (   NVL (p_term_rec.p_early_termination_yn, '?') = g_yes
              OR l_early_termination_yn = g_yes
             )
         AND l_sts_code <> 'EVERGREEN'
      THEN
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'calling OKL_INSURANCE_POLICIES_PUB.cancel_policies'
                        );
         END IF;

         -- cancel insurances
         okl_insurance_policies_pub.cancel_policies
                                   (p_api_version            => p_api_version,
                                    p_init_msg_list          => g_false,
                                    x_return_status          => l_return_status,
                                    x_msg_count              => x_msg_count,
                                    x_msg_data               => x_msg_data,
                                    p_contract_id            => p_term_rec.p_contract_id,
                                    p_cancellation_date      => p_sys_date
                                   );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_INSURANCE_POLICIES_PUB.cancel_policies , return status: '
                || l_return_status
               );
         END IF;

         IF l_return_status <> g_ret_sts_success
         THEN
            -- Error in cancelling Insurance.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_ERR_CAN_INS');
         END IF;

         -- Raise exception to rollback to the savepoint
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;
      END IF;

      -- Set the return status
      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF k_end_date_csr%ISOPEN
         THEN
            CLOSE k_end_date_csr;
         END IF;

         ROLLBACK TO cancel_insurance;
         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF k_end_date_csr%ISOPEN
         THEN
            CLOSE k_end_date_csr;
         END IF;

         ROLLBACK TO cancel_insurance;
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF k_end_date_csr%ISOPEN
         THEN
            CLOSE k_end_date_csr;
         END IF;

         ROLLBACK TO cancel_insurance;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END cancel_insurance;

   -- Start of Commnets
   --
   -- Procedure Name       : validate_chr_cle_id
   -- Description          : This Local Procedure is used for validation of
   --                        Chr_id and Asset line.
   -- Business Rules       :
   -- Parameters           :
   -- Version              : 1.0
   -- History              : RMUNJULU -- 04-DEC-02 Bug # 2484327 Added comments to
   --                        cursor
   --                        RMUNJULU 16-DEC-02 Bug # 2484327, changed cursor to get lines
   --                        which are of the same status as header
   --
   -- End of Commnets
   PROCEDURE validate_chr_cle_id (
      p_dnz_chr_id      IN              okc_k_lines_v.dnz_chr_id%TYPE,
      p_top_line_id     IN              okc_k_lines_v.ID%TYPE,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      ln_dummy                NUMBER         := 0;
      l_module_name           VARCHAR2 (500)
                                    := g_module_name || 'validate_chr_cle_id';
      is_debug_exception_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);

      -- RMUNJULU Bug #  2484327 Added comments, changed parameters to IN
      -- RMUNJULU 16-DEC-02 Bug # 2484327, get lines which are of the same status as header
      -- Cursor to validate the contract and lines to see if they are booked or not
      CURSOR l_k_lines_validate_csr (
         p_dnz_chr_id    IN   okc_k_lines_v.dnz_chr_id%TYPE,
         p_top_line_id   IN   okc_k_lines_v.ID%TYPE
      )
      IS
         SELECT 1
           FROM DUAL
          WHERE EXISTS (
                   SELECT 1
                     FROM okc_subclass_top_line stl,
                          okc_line_styles_v lse,
                          okc_k_lines_v cle,
                          okc_k_headers_v khr
                    WHERE cle.ID = p_top_line_id
                      AND cle.dnz_chr_id = p_dnz_chr_id
                      AND cle.cle_id IS NULL
                      AND cle.chr_id = cle.dnz_chr_id
                      AND cle.lse_id = lse.ID
                      AND lse.lty_code = g_fin_line_lty_code
                      AND lse.lse_type = g_tls_type
                      AND lse.lse_parent_id IS NULL
                      AND lse.ID = stl.lse_id
                      AND cle.sts_code = khr.sts_code
                      AND cle.dnz_chr_id = khr.ID
                      AND stl.scs_code IN (g_lease_scs_code, g_loan_scs_code));
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_dnz_chr_id: ' || p_dnz_chr_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_top_line_id: ' || p_top_line_id
                                 );
      END IF;

      -- initialize return status
      x_return_status := g_ret_sts_success;

      -- data is required
      IF     (p_dnz_chr_id = g_miss_num OR p_dnz_chr_id IS NULL)
         AND (p_top_line_id = g_miss_num OR p_top_line_id IS NULL)
      THEN
         -- store SQL error message on message stack
         okl_api.set_message
                          (p_app_name          => g_app_name,
                           p_msg_name          => g_required_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'p_dnz_chr_id and p_top_line_id'
                          );
         -- halt validation as it is a required field
         RAISE g_exception_stop_validation;
      ELSIF    (p_dnz_chr_id = g_miss_num OR p_dnz_chr_id IS NULL)
            OR (p_top_line_id = g_miss_num OR p_top_line_id IS NULL)
      THEN
         -- store SQL error message on message stack
         okl_api.set_message
                          (p_app_name          => g_app_name,
                           p_msg_name          => g_required_value,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'p_dnz_chr_id and p_top_line_id'
                          );
         -- halt validation as it is a required field
         RAISE g_exception_stop_validation;
      END IF;

      -- Combination of dnz_chr_id and Top line id should be valid one
      OPEN l_k_lines_validate_csr (p_dnz_chr_id       => p_dnz_chr_id,
                                   p_top_line_id      => p_top_line_id);

      IF l_k_lines_validate_csr%NOTFOUND
      THEN
         okl_api.set_message
                          (p_app_name          => g_app_name,
                           p_msg_name          => g_no_matching_record,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'p_dnz_chr_id and p_top_line_id'
                          );
         -- halt validation as it has no parent record
         RAISE g_exception_halt_validation;
      END IF;

      FETCH l_k_lines_validate_csr
       INTO ln_dummy;

      CLOSE l_k_lines_validate_csr;

      IF (ln_dummy = 0)
      THEN
         okl_api.set_message
                          (p_app_name          => g_app_name,
                           p_msg_name          => g_no_matching_record,
                           p_token1            => g_col_name_token,
                           p_token1_value      => 'p_dnz_chr_id and p_top_line_id'
                          );
         -- halt validation as it has no parent record
         RAISE g_exception_halt_validation;
      END IF;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN g_exception_stop_validation
      THEN
         -- We are here since the field is required
         -- Notify Error
         -- RMUNJULU -- Bug # 2484327 -- Added code to close cursor if open
         IF l_k_lines_validate_csr%ISOPEN
         THEN
            CLOSE l_k_lines_validate_csr;
         END IF;

         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_STOP_VALIDATION'
                                    );
         END IF;
      WHEN g_exception_halt_validation
      THEN
         -- If the cursor is open then it has to be closed
         IF l_k_lines_validate_csr%ISOPEN
         THEN
            CLOSE l_k_lines_validate_csr;
         END IF;

         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_HALT_VALIDATION'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- store SQL error message on message stack
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         -- If the cursor is open then it has to be closed
         IF l_k_lines_validate_csr%ISOPEN
         THEN
            CLOSE l_k_lines_validate_csr;
         END IF;

         -- notify caller of an error as UNEXPETED error
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END validate_chr_cle_id;

   /*========================================================================
   | PRIVATE PROCEDURE update_payments
   |
   | DESCRIPTION
   |    This procedure updates the financial asset, service line and service
   |    subline level payments with the proposed payments calculated during
   |    quote creation
   |
   | CALLED FROM PROCEDURES/FUNCTIONS
   |     update_lines
   |
   | CALLS PROCEDURES/FUNCTIONS
   |
   |
   | PARAMETERS
   |      p_quote_id                 IN        Quote ID
   |
   | KNOWN ISSUES
   |
   | NOTES
   |
   |
   | MODIFICATION HISTORY
   | Date                  Author            Description of Changes
   | 28-OCT-2003           SECHAWLA          22846988  Created
   | 20-SEP-04             SECHAWLA          3816891 : Modified payment processing
   |                                           for Arrears
   | 29-SEP-04             PAGARG            Bug #3921591: Added payment
   |                                         processing for Rollover Fee line
   | 15-JUN-06             SMADHAVA          Bug#5043646: Modified payment processing
   |                                         for fee header level payments
   *=======================================================================*/
   PROCEDURE update_payments (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_quote_id        IN              NUMBER
   )
   IS
      -- This cursor returns all the proposed objects of a particular type, created during quote creation
      -- some of the proposed objects may not have any associated cash flows
      CURSOR l_quoteobjects_csr (
         cp_qte_id   IN   NUMBER
      )
      IS
         SELECT DISTINCT qco.cfo_id cfo_id,
                         qco.base_source_id line_id,
                         caf.sts_code,
                         cfo.oty_code
                    FROM okl_trx_qte_cf_objects qco,
                         okl_cash_flows caf,
                         okl_cash_flow_objects cfo
                   WHERE cfo.ID = qco.cfo_id
                     AND cfo.ID =
                            caf.cfo_id(+)
-- cash flow object is created even if there are no proposed payments (quote eff dt < first level start date)
                     --Bug #3921591: pagarg +++ Rollover +++
                     -- Included fee line and fee asset line type cash flow objects also
                     AND cfo.oty_code IN
                            ('FINANCIAL_ASSET_LINE',
                             'SERVICE_LINE',
                             'SERVICED_ASSET_LINE',
                             'FEE_LINE',
                             'FEE_ASSET_LINE'
                            )
                     AND qco.qte_id = cp_qte_id
                     AND NVL (caf.sts_code, 'PROPOSED') = 'PROPOSED';

      -- get the quote effective date
      CURSOR l_trxquotes_csr (
         cp_qte_id   IN   NUMBER
      )
      IS
         SELECT TRUNC (date_effective_from)
           FROM okl_trx_quotes_b
          WHERE ID = cp_qte_id;

      -- get the quote line info
      CURSOR l_quotelines_csr (
         cp_qte_id   IN   NUMBER,
         cp_kle_id   IN   NUMBER
      )
      IS
         SELECT ID tql_id,
                asset_quantity asset_quantity,
                quote_quantity quote_quantity
           FROM okl_txl_quote_lines_b
          WHERE qte_id = cp_qte_id
            AND qlt_code = 'AMCFIA'
            AND kle_id = cp_kle_id;

      -- get all the stream types from cashflows, for which proposed payment exists
      CURSOR l_cashflowstreams_csr (
         cp_cfo_id   IN   NUMBER
      )
      IS
         SELECT ID caf_id,
                sty_id,
                dnz_khr_id,
                number_of_advance_periods,
                due_arrears_yn
           FROM okl_cash_flows
          WHERE cfo_id = cp_cfo_id
            AND sts_code = 'PROPOSED'
            AND cft_code = 'PAYMENT_SCHEDULE';

      -- get all the cash flow levels for a cashflow header
      CURSOR l_cashflowlevels_csr (
         cp_caf_id   IN   NUMBER
      )
      IS
         SELECT ID cfl_id,
                amount,
                number_of_periods,
                fqy_code,
                stub_days,
                stub_amount,
                start_date
           FROM okl_cash_flow_levels
          WHERE caf_id = cp_caf_id;

      -- This cursor returns the rule group ID and slh ID of all the payments for a given line
      CURSOR l_rgpslh_csr (
         cp_cle_id   IN   NUMBER
      )
      IS
         SELECT DISTINCT rgp.ID rgp_id,
                         slh_rul.ID slh_id,
                         rgp.dnz_chr_id,
                         sttyp.id1 sty_id,
                         sll_rul.rule_information5 advance_periods,
                         sll_rul.rule_information10 due_arrears_yn,
                         sll_rul.object1_id1 frequency
                    FROM okc_rules_b sll_rul,
                         okc_rules_b slh_rul,
                         okc_rule_groups_b rgp,
                         okl_strmtyp_source_v sttyp
                   WHERE sll_rul.object2_id1 = TO_CHAR (slh_rul.ID)
                     AND sll_rul.rgp_id = rgp.ID
                     AND sll_rul.rule_information_category = 'LASLL'
                     AND sttyp.id1 = slh_rul.object1_id1
                     AND slh_rul.rgp_id = rgp.ID
                     AND slh_rul.rule_information_category = 'LASLH'
                     AND rgp.rgd_code = 'LALEVL'
                     AND rgp.cle_id = cp_cle_id;

      -- Get the proposed cashflows for an object, for a given stream type
      CURSOR l_cashflows_csr (
         cp_cfo_id   IN   NUMBER,
         cp_sty_id   IN   NUMBER
      )
      IS
         SELECT   caf.ID,
                  caf.sty_id,
                  cfl.start_date,
                  cfl.amount,
                  cfl.number_of_periods,
                  cfl.stub_days,
                  cfl.stub_amount,
                  NVL (caf.due_arrears_yn, 'N') due_arrears_yn,
                                         -- SECHAWLA 20-SEP-04 3816891 : Added
                  cfl.fqy_code           -- SECHAWLA 20-SEP-04 3816891 : Added
             FROM okl_cash_flows caf,
                  okl_cash_flow_levels cfl
            WHERE cfo_id = cp_cfo_id
              AND caf.sty_id = cp_sty_id
              AND caf.ID = cfl.caf_id
              AND caf.sts_code = 'PROPOSED'
              AND caf.cft_code = 'PAYMENT_SCHEDULE'
         ORDER BY cfl.start_date;

      -- get the current payments for a line, as they exist after split asset has happened
      -- Get the Line Level payments
      CURSOR l_lpayments_csr (
         cp_cle_id   IN   NUMBER,
         cp_sty_id   IN   NUMBER
      )
      IS
         SELECT   rgp.cle_id cle_id,
                  sttyp.id1 sty_id,
                  sttyp.code stream_type,
                  sll_rul.rule_information2 start_date,
                  sll_rul.rule_information3 periods,
                  sll_rul.rule_information6 amount,
                  sll_rul.rule_information7 stub_days,
                  sll_rul.rule_information8 stub_amount,
                  rgp.dnz_chr_id
             FROM okc_rules_b sll_rul,
                  okl_strmtyp_source_v sttyp,
                  okc_rules_b slh_rul,
                  okc_rule_groups_b rgp
            WHERE sll_rul.object2_id1 = TO_CHAR (slh_rul.ID)
              AND sll_rul.rgp_id = rgp.ID
              AND sll_rul.rule_information_category = 'LASLL'
              AND sttyp.id1 = slh_rul.object1_id1
              AND sttyp.id1 = cp_sty_id
              AND slh_rul.rgp_id = rgp.ID
              AND slh_rul.rule_information_category = 'LASLH'
              AND rgp.rgd_code = 'LALEVL'
              AND rgp.cle_id = cp_cle_id
         ORDER BY start_date;

      --Bug #3921591: pagarg +++ Rollover +++
      -- Modified the cursor to get financial assets for a given line type

      -- Get the financial asset associated with a given line type (subline)
      CURSOR l_finasset_csr (
         cp_fee_serviced_asset_line_id   IN   NUMBER,
         cp_line_type                    IN   VARCHAR2
      )
      IS
         SELECT cim.object1_id1,
                cle.cle_id
           FROM okc_k_lines_b cle,
                okc_line_styles_b lse,
                okc_k_items cim
          WHERE cle.lse_id = lse.ID
            AND lse.lty_code = cp_line_type
            AND cim.cle_id = cle.ID
            AND cle.ID = cp_fee_serviced_asset_line_id;

      -- smadhava - Bug#5043646 - Added - Start
      l_active_assets_flag      VARCHAR2 (1);

      -- Find if there are ACTIVE assets associated to fees/services (subline)
      CURSOR c_find_active_link_assets (
         cp_line_id     IN   NUMBER,
         cp_line_type   IN   VARCHAR2
      )
      IS
         SELECT 'X'
           FROM okc_k_lines_b linked_asset,
                okc_line_styles_b line_styl,
                okc_k_items item,
                okc_statuses_b sts
          WHERE linked_asset.lse_id = line_styl.ID
            AND line_styl.lty_code = cp_line_type
            AND item.cle_id = linked_asset.ID
            AND linked_asset.cle_id = cp_line_id
            AND sts.code = linked_asset.sts_code
            AND sts.ste_code = 'ACTIVE';

      -- smadhava - Bug#5043646 - Added - End

      --Bug #3921591: pagarg +++ Rollover +++
      -- Modified the cursor to get the assets for a given line type

      -- Get all the assets associated with the service or fee line
      -- This cursor might also return assets with status = 'TERMINATED'
      -- By the time this procedure is called, financial assets that are included in the quote, will
      -- already be terminated (in update_lines procedure)
      CURSOR l_lineassets_csr (
         cp_line_id     IN   NUMBER,
         cp_line_type   IN   VARCHAR2
      )
      IS
         SELECT cim.object1_id1,
                cle.ID
           FROM okc_k_lines_b cle,
                okc_line_styles_b lse,
                okc_k_items cim
          WHERE cle.lse_id = lse.ID
            AND lse.lty_code = cp_line_type
            AND cim.cle_id = cle.ID
            AND cle.cle_id = cp_line_id;

      -- SECHAWLA 20-SEP-04 3816891 : new declarations begin

      -- Get the next level start date
      CURSOR l_nextlevelstartdt_csr (
         cp_currlevelstartdt   IN   DATE,
         cp_number_of_months   IN   NUMBER
      )
      IS
         SELECT ADD_MONTHS (cp_currlevelstartdt, cp_number_of_months)
           FROM DUAL;

      l_number_of_months        NUMBER;
      l_next_level_start_date   DATE;

      -- SECHAWLA 20-SEP-04 3816891 : new declarations end
      SUBTYPE pym_hdr_rec_type IS okl_la_payments_pvt.pym_hdr_rec_type;

      SUBTYPE pym_tbl_type IS okl_la_payments_pvt.pym_tbl_type;

      SUBTYPE rulv_tbl_type IS okl_rule_pub.rulv_tbl_type;

      SUBTYPE pym_del_tbl_type IS okl_la_payments_pvt.pym_del_tbl_type;

      TYPE splitpymt_rec_type IS RECORD (
         p_start_date          DATE,
         p_number_of_periods   NUMBER,
         p_amount              NUMBER,
         p_stub_days           NUMBER,
         p_stub_amount         NUMBER
      );

      TYPE splitpymt_tbl_type IS TABLE OF splitpymt_rec_type
         INDEX BY BINARY_INTEGER;

      l_tql_id                  NUMBER;
      l_asset_qty               NUMBER;
      l_quote_qty               NUMBER;
      pym_tbl_ind               NUMBER;
      l_pym_freq                VARCHAR2 (30);
      lp_pym_tbl                pym_tbl_type;
      lp_pym_tbl_empty          pym_tbl_type;
      lp_pym_hdr_rec            pym_hdr_rec_type;
      l_return_status           VARCHAR2 (1)      := okl_api.g_ret_sts_success;
      lx_rulv_tbl               rulv_tbl_type;
      l_proppymt_count          NUMBER;
      l_splitpymt_count         NUMBER;
      l_date_eff_from           DATE;
      i                         NUMBER;
      lpym_del_tbl              pym_del_tbl_type;
      lpym_del_tbl_empty        pym_del_tbl_type;
      lpym_del_tbl_count        NUMBER;
      l_freq_found              VARCHAR2 (1)       := 'N';
      l_name                    VARCHAR2 (150);
      l_strm_type_code          VARCHAR2 (150);
      l_splitpymt_tbl           splitpymt_tbl_type;
      l_splitpymt_tbl_empty     splitpymt_tbl_type;
      l_fin_asset_id            NUMBER;
      l_upd_required            VARCHAR2 (1);
      l_count                   NUMBER;
      l_service_line_id         NUMBER;
      --Bug #3921591: pagarg +++ Rollover +++
      -- Variable to store fine line id
      l_fee_line_id             NUMBER;
      l_module_name             VARCHAR2 (500)
                                         := g_module_name || 'update_payments';
      is_debug_exception_on     BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on     BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on     BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   BEGIN
      SAVEPOINT update_payments;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_quote_id: ' || p_quote_id
                                 );
      END IF;

      IF p_quote_id IS NULL OR p_quote_id = okl_api.g_miss_num
      THEN
         -- quote id is required
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_required_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'QUOTE_ID'
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      OPEN l_trxquotes_csr (p_quote_id);

      FETCH l_trxquotes_csr
       INTO l_date_eff_from;

      IF l_trxquotes_csr%NOTFOUND
      THEN
         -- quote id is invalid
         okc_api.set_message (p_app_name          => 'OKC',
                              p_msg_name          => g_invalid_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'QUOTE_ID'
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      CLOSE l_trxquotes_csr;

      --Bug #3921591: pagarg +++ Rollover +++
      -- update payments for all proposed objects of type : financial asset,
      -- service line, serviced assets line, fee line, fee asset line
      FOR l_quoteobjects_rec IN l_quoteobjects_csr (p_quote_id)
      LOOP
         l_upd_required := 'N';

         -- current payment exists, but no future payments exist.
         IF l_quoteobjects_rec.sts_code IS NULL
         THEN
            -- This will
            -- be the case only if quote is created before the first payment start
            -- date. This will not happen now since now first payment start dt
            -- is the K start date and quote will be created only after the
            -- K is created. So quote eff dt will always be >= first pymt start dt

            -- delete all the payments, for all stream types
            lpym_del_tbl_count := 0;
            lpym_del_tbl := lpym_del_tbl_empty;

            FOR l_rgpslh_rec IN l_rgpslh_csr (l_quoteobjects_rec.line_id)
            LOOP
               lpym_del_tbl_count := lpym_del_tbl_count + 1;
               lpym_del_tbl (lpym_del_tbl_count).chr_id :=
                                                      l_rgpslh_rec.dnz_chr_id;
               lpym_del_tbl (lpym_del_tbl_count).rgp_id :=
                                                          l_rgpslh_rec.rgp_id;
               lpym_del_tbl (lpym_del_tbl_count).slh_id :=
                                                          l_rgpslh_rec.slh_id;
            END LOOP;

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                 'calling OKL_LA_PAYMENTS_PVT.delete_payment'
                                );
            END IF;

            okl_la_payments_pvt.delete_payment
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => okc_api.g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_del_pym_tbl        => lpym_del_tbl,
                                          --bug #7498330
                                           p_source_trx         => 'TQ'
                                          );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_LA_PAYMENTS_PVT.delete_payment , return status: '
                   || l_return_status
                  );
            END IF;

            IF (l_return_status = okl_api.g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;
         ELSIF l_quoteobjects_rec.sts_code = 'PROPOSED'
         THEN
            -- future payment exists for one or more stream types
            IF l_quoteobjects_rec.oty_code = 'FINANCIAL_ASSET_LINE'
            THEN
               l_fin_asset_id := l_quoteobjects_rec.line_id;

               -- check if asset belongs to quote
               OPEN l_quotelines_csr (p_quote_id, l_fin_asset_id);

               FETCH l_quotelines_csr
                INTO l_tql_id,
                     l_asset_qty,
                     l_quote_qty;

               IF l_quotelines_csr%FOUND
               THEN
                  l_upd_required := 'Y';
               END IF;

               CLOSE l_quotelines_csr;
            ELSIF l_quoteobjects_rec.oty_code = 'SERVICED_ASSET_LINE'
            THEN
               --Bug #3921591: pagarg +++ Rollover +++
               -- Modified the call to pass line type code also.
               -- get the financial asset associated with the subline
               OPEN l_finasset_csr (l_quoteobjects_rec.line_id,
                                    g_srl_line_lty_code);

               FETCH l_finasset_csr
                INTO l_fin_asset_id,
                     l_service_line_id;

               CLOSE l_finasset_csr;

               -- check if asset belongs to quote
               OPEN l_quotelines_csr (p_quote_id, l_fin_asset_id);

               FETCH l_quotelines_csr
                INTO l_tql_id,
                     l_asset_qty,
                     l_quote_qty;

               IF l_quotelines_csr%FOUND
               THEN
                  l_upd_required := 'Y';
               END IF;

               CLOSE l_quotelines_csr;
            ELSIF l_quoteobjects_rec.oty_code = 'SERVICE_LINE'
            THEN
               --Bug #3921591: pagarg +++ Rollover +++
               -- Modified the call to pass line type code also.
               -- check if service line has any quoted assets.
               -- Get all the assets associated with the service line
               FOR l_servicelineassets_rec IN
                  l_lineassets_csr (l_quoteobjects_rec.line_id,
                                    g_srl_line_lty_code)
               LOOP
                  -- check if asset belongs to quote
                  OPEN l_quotelines_csr (p_quote_id,
                                         l_servicelineassets_rec.object1_id1);

                  FETCH l_quotelines_csr
                   INTO l_tql_id,
                        l_asset_qty,
                        l_quote_qty;

                  IF l_quotelines_csr%FOUND
                  THEN
                     l_upd_required := 'Y';

                     CLOSE l_quotelines_csr;

                     EXIT;
                  END IF;

                  CLOSE l_quotelines_csr;
               END LOOP;
            --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
            -- Check whether payment is required to be updated for fee line and fee asset line
            ELSIF l_quoteobjects_rec.oty_code = 'FEE_ASSET_LINE'
            THEN
               -- as of now fee_asset_line type cash flow object is created for rollover fee only.
               -- get the financial asset associated with the subline
               OPEN l_finasset_csr (l_quoteobjects_rec.line_id,
                                    g_fel_line_lty_code);

               FETCH l_finasset_csr
                INTO l_fin_asset_id,
                     l_fee_line_id;

               CLOSE l_finasset_csr;

               -- check if asset belongs to quote
               OPEN l_quotelines_csr (p_quote_id, l_fin_asset_id);

               FETCH l_quotelines_csr
                INTO l_tql_id,
                     l_asset_qty,
                     l_quote_qty;

               IF l_quotelines_csr%FOUND
               THEN
                  l_upd_required := 'Y';
               END IF;

               CLOSE l_quotelines_csr;
            ELSIF l_quoteobjects_rec.oty_code = 'FEE_LINE'
            THEN
               -- check if fee line has any quoted assets.
               -- Get all the assets associated with the fee line
               FOR l_feelineassets_rec IN
                  l_lineassets_csr (l_quoteobjects_rec.line_id,
                                    g_fel_line_lty_code)
               LOOP
                  -- check if asset belongs to quote
                  OPEN l_quotelines_csr (p_quote_id,
                                         l_feelineassets_rec.object1_id1);

                  FETCH l_quotelines_csr
                   INTO l_tql_id,
                        l_asset_qty,
                        l_quote_qty;

                  IF l_quotelines_csr%FOUND
                  THEN
                     -- smadhava - Bug#5043646 - Added - Start
                     -- Now CHECK  if the all the assets attached to this fee are terminated. Going by this logic
                     -- as payments are updated in termination flow only after the asset statuses are
                     -- updated to TERMINATED. Hence checking for statuses of all assets linked to this fee.
                     -- Never update the header payments for partial termination. This is because for
                     -- partial temination, by this time, the assets have been split and the orignial
                     -- individual units prior to split are separate assets linked to this fee line.
                     l_active_assets_flag := 'N';

                     IF (l_asset_qty = l_quote_qty)
                     THEN
                        -- cursor to check if there are assets associated to this fee which are still ACTIVE
                        -- if there are ACTIVE assets, then donot update the payment at the header
                        OPEN c_find_active_link_assets
                                                 (l_quoteobjects_rec.line_id,
                                                  g_fel_line_lty_code);

                        FETCH c_find_active_link_assets
                         INTO l_active_assets_flag;

                        -- update the payments on header lines only if all the associated assets
                        -- have been terminated
                        IF c_find_active_link_assets%NOTFOUND
                        THEN
                           l_upd_required := 'Y';
                        END IF;

                        CLOSE c_find_active_link_assets;
                     END IF;

                     -- Assigning fee line id to the variable
                     l_fee_line_id := l_quoteobjects_rec.line_id;

                     -- smadhava - Bug#5043646 - Added - End
                     CLOSE l_quotelines_csr;

                     EXIT;
                  END IF;

                  CLOSE l_quotelines_csr;
               END LOOP;
            END IF;

            --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++
            IF l_upd_required = 'Y'
            THEN
               --Bug #3921591: pagarg +++ Rollover +++
               -- Modified the condition to include fee line and fee asset line also
               IF (   (    l_quoteobjects_rec.oty_code IN
                              ('FINANCIAL_ASSET_LINE',
                               'SERVICED_ASSET_LINE',
                               'FEE_ASSET_LINE'
                              )
                       AND l_asset_qty =
                              l_quote_qty
                                 -- full line termination, asset was not split
                      )
                   OR l_quoteobjects_rec.oty_code IN
                                                 ('SERVICE_LINE', 'FEE_LINE')
                  -- service line level pymts are not split, if
                  -- any of the attached assets are partially terminated.
                  -- so we can always overwrite the service line level pymts
                  )
               THEN
                  -- overwrite the payments
                  -- delete all the payments, for all stream types
                  lpym_del_tbl_count := 0;
                  lpym_del_tbl := lpym_del_tbl_empty;

                  FOR l_rgpslh_rec IN
                     l_rgpslh_csr (l_quoteobjects_rec.line_id)
                  LOOP
                     lpym_del_tbl_count := lpym_del_tbl_count + 1;
                     lpym_del_tbl (lpym_del_tbl_count).chr_id :=
                                                      l_rgpslh_rec.dnz_chr_id;
                     lpym_del_tbl (lpym_del_tbl_count).rgp_id :=
                                                          l_rgpslh_rec.rgp_id;
                     lpym_del_tbl (lpym_del_tbl_count).slh_id :=
                                                          l_rgpslh_rec.slh_id;
                  END LOOP;

                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                 'calling OKL_LA_PAYMENTS_PVT.delete_payment'
                                );
                  END IF;

                  okl_la_payments_pvt.delete_payment
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => okc_api.g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_del_pym_tbl        => lpym_del_tbl,
                                          --bug # 7498330
                                           p_source_trx         => 'TQ'
                                          );

                  IF (is_debug_statement_on)
                  THEN
                     okl_debug_pub.log_debug
                            (g_level_statement,
                             l_module_name,
                                'calling OKL_LA_PAYMENTS_PVT.delete_payment '
                             || l_return_status
                            );
                  END IF;

                  IF (l_return_status = okl_api.g_ret_sts_unexp_error)
                  THEN
                     RAISE okl_api.g_exception_unexpected_error;
                  ELSIF (l_return_status = okl_api.g_ret_sts_error)
                  THEN
                     RAISE okl_api.g_exception_error;
                  END IF;
-- Bug 6908509: add start
                 l_freq_found := 'N';
-- Bug 6908509: add end
                  -- create new payments from cash flow tables
                  -- get all the proposed stream types
                  FOR l_cashflowstreams_rec IN
                     l_cashflowstreams_csr (l_quoteobjects_rec.cfo_id)
                  LOOP
                     -- create payment for each proposed stream type
                     pym_tbl_ind := 0;
                     lp_pym_tbl := lp_pym_tbl_empty;

                     -- get all the proposed cash flow levels and populate lp_pym_tbl
                     FOR l_cashflowlevels_rec IN
                        l_cashflowlevels_csr (l_cashflowstreams_rec.caf_id)
                     LOOP
                        IF (    l_freq_found = 'N'
                            AND l_cashflowlevels_rec.fqy_code IS NOT NULL
                           )
                        THEN
                           l_pym_freq := l_cashflowlevels_rec.fqy_code;
                           l_freq_found := 'Y';
                        END IF;

                        pym_tbl_ind := pym_tbl_ind + 1;
                        lp_pym_tbl (pym_tbl_ind).stub_days :=
                                                l_cashflowlevels_rec.stub_days;
                        lp_pym_tbl (pym_tbl_ind).stub_amount :=
                                              l_cashflowlevels_rec.stub_amount;
                        lp_pym_tbl (pym_tbl_ind).period :=
                                        l_cashflowlevels_rec.number_of_periods;
                        lp_pym_tbl (pym_tbl_ind).amount :=
                                                   l_cashflowlevels_rec.amount;
                        lp_pym_tbl (pym_tbl_ind).update_type := 'CREATE';
                     END LOOP;

                     IF l_freq_found = 'N'
                     THEN
                        -- all levels are stub levels
                        l_pym_freq := 'M';
      -- default freq to Monthly for Stub payments, as it is a required field
                     END IF;

                     lp_pym_hdr_rec.STRUCTURE :=
                               l_cashflowstreams_rec.number_of_advance_periods;
                     lp_pym_hdr_rec.frequency := l_pym_freq;
                     lp_pym_hdr_rec.arrears :=
                                          l_cashflowstreams_rec.due_arrears_yn;

                     IF lp_pym_tbl.COUNT > 0
                     THEN
                        IF l_quoteobjects_rec.oty_code =
                                                       'FINANCIAL_ASSET_LINE'
                        THEN
                           -- create asset level payments
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.process_payment'
                                 );
                           END IF;

                           okl_la_payments_pvt.process_payment
                                (p_api_version        => p_api_version,
                                 p_init_msg_list      => okc_api.g_false,
                                 x_return_status      => l_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 p_chr_id             => l_cashflowstreams_rec.dnz_khr_id,
                                 --  p_service_fee_id         => OKC_API.G_MISS_NUM,
                                 p_asset_id           => l_quoteobjects_rec.line_id,
                                 p_payment_id         => l_cashflowstreams_rec.sty_id,
                                 p_pym_hdr_rec        => lp_pym_hdr_rec,
                                 p_pym_tbl            => lp_pym_tbl,
                                 p_update_type        => 'CREATE',
                                 x_rulv_tbl           => lx_rulv_tbl
                                );

                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called OKL_LA_PAYMENTS_PVT.process_payment , return status: '
                                  || l_return_status
                                 );
                           END IF;
                        ELSIF l_quoteobjects_rec.oty_code =
                                                         'SERVICED_ASSET_LINE'
                        THEN
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.process_payment'
                                 );
                           END IF;

                           -- create subline level payments
                           okl_la_payments_pvt.process_payment
                                (p_api_version         => p_api_version,
                                 p_init_msg_list       => okc_api.g_false,
                                 x_return_status       => l_return_status,
                                 x_msg_count           => x_msg_count,
                                 x_msg_data            => x_msg_data,
                                 p_chr_id              => l_cashflowstreams_rec.dnz_khr_id,
                                 p_service_fee_id      => l_service_line_id,
                                 p_asset_id            => l_fin_asset_id,
                                 p_payment_id          => l_cashflowstreams_rec.sty_id,
                                 p_pym_hdr_rec         => lp_pym_hdr_rec,
                                 p_pym_tbl             => lp_pym_tbl,
                                 p_update_type         => 'CREATE',
                                 x_rulv_tbl            => lx_rulv_tbl
                                );

                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called OKL_LA_PAYMENTS_PVT.process_payment , return status: '
                                  || l_return_status
                                 );
                           END IF;
                        ELSIF l_quoteobjects_rec.oty_code = 'SERVICE_LINE'
                        THEN
                           -- create service line level payments
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.process_payment'
                                 );
                           END IF;

                           okl_la_payments_pvt.process_payment
                              (p_api_version         => p_api_version,
                               p_init_msg_list       => okc_api.g_false,
                               x_return_status       => l_return_status,
                               x_msg_count           => x_msg_count,
                               x_msg_data            => x_msg_data,
                               p_chr_id              => l_cashflowstreams_rec.dnz_khr_id,
                               p_service_fee_id      => l_quoteobjects_rec.line_id,
                               --p_asset_id               => l_quoteobjects_rec.line_id,
                               p_payment_id          => l_cashflowstreams_rec.sty_id,
                               p_pym_hdr_rec         => lp_pym_hdr_rec,
                               p_pym_tbl             => lp_pym_tbl,
                               p_update_type         => 'CREATE',
                               x_rulv_tbl            => lx_rulv_tbl
                              );

                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called OKL_LA_PAYMENTS_PVT.process_payment , return status: '
                                  || l_return_status
                                 );
                           END IF;
                        --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
                        -- creating payments for fee line and fee asset line.
                        ELSIF l_quoteobjects_rec.oty_code = 'FEE_ASSET_LINE'
                        THEN
                           -- create fee asset subline level payments
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.process_payment'
                                 );
                           END IF;

                           okl_la_payments_pvt.process_payment
                                (p_api_version         => p_api_version,
                                 p_init_msg_list       => okc_api.g_false,
                                 x_return_status       => l_return_status,
                                 x_msg_count           => x_msg_count,
                                 x_msg_data            => x_msg_data,
                                 p_chr_id              => l_cashflowstreams_rec.dnz_khr_id,
                                 p_service_fee_id      => l_fee_line_id,
                                 p_asset_id            => l_fin_asset_id,
                                 p_payment_id          => l_cashflowstreams_rec.sty_id,
                                 p_pym_hdr_rec         => lp_pym_hdr_rec,
                                 p_pym_tbl             => lp_pym_tbl,
                                 p_update_type         => 'CREATE',
                                 x_rulv_tbl            => lx_rulv_tbl
                                );

                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called OKL_LA_PAYMENTS_PVT.process_payment , return status: '
                                  || l_return_status
                                 );
                           END IF;
                        ELSIF l_quoteobjects_rec.oty_code = 'FEE_LINE'
                        THEN
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.process_payment'
                                 );
                           END IF;

                           -- create fee line level payments
                           okl_la_payments_pvt.process_payment
                                (p_api_version         => p_api_version,
                                 p_init_msg_list       => okc_api.g_false,
                                 x_return_status       => l_return_status,
                                 x_msg_count           => x_msg_count,
                                 x_msg_data            => x_msg_data,
                                 p_chr_id              => l_cashflowstreams_rec.dnz_khr_id,
                                 p_service_fee_id      => l_fee_line_id,
                                 p_payment_id          => l_cashflowstreams_rec.sty_id,
                                 p_pym_hdr_rec         => lp_pym_hdr_rec,
                                 p_pym_tbl             => lp_pym_tbl,
                                 p_update_type         => 'CREATE',
                                 x_rulv_tbl            => lx_rulv_tbl
                                );

                           --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called OKL_LA_PAYMENTS_PVT.process_payment , return status: '
                                  || l_return_status
                                 );
                           END IF;
                        END IF;

                        IF (l_return_status = okl_api.g_ret_sts_unexp_error)
                        THEN
                           RAISE okl_api.g_exception_unexpected_error;
                        ELSIF (l_return_status = okl_api.g_ret_sts_error)
                        THEN
                           RAISE okl_api.g_exception_error;
                        END IF;
                     END IF;
                  END LOOP;
               ELSE
                  -- partial line termination (for fin assets and serviced assets only)
                  -- asset was split. cann't overwrite the split payments with proposed pymts
                  -- on quote. Adjust the split asset payment, save in a table and then overwrite the
                  -- existing payments with the adjusted payments

                  -- get all stream types (from rules), for which payments exist, after split asset
                  FOR l_rgpslh_rec IN
                     l_rgpslh_csr (l_quoteobjects_rec.line_id)
                  LOOP
                     -- get the payments for this stream type (from rules) as they exist after the split asset, and populate l_splitpymt_tbl
                     l_splitpymt_count := 0;
                     l_splitpymt_tbl := l_splitpymt_tbl_empty;

                     -- populate l_splitpymt_tbl with payments as they exist after split
                     FOR l_lpayments_rec IN
                        l_lpayments_csr (l_quoteobjects_rec.line_id,
                                         l_rgpslh_rec.sty_id)
                     LOOP
                        l_splitpymt_count := l_splitpymt_count + 1;
                        l_splitpymt_tbl (l_splitpymt_count).p_start_date :=
                           TO_DATE (l_lpayments_rec.start_date,
                                    'yyyy/mm/dd hh24:mi:ss');
                        l_splitpymt_tbl (l_splitpymt_count).p_number_of_periods :=
                                                      l_lpayments_rec.periods;
                        l_splitpymt_tbl (l_splitpymt_count).p_amount :=
                                                       l_lpayments_rec.amount;
                        l_splitpymt_tbl (l_splitpymt_count).p_stub_days :=
                                                    l_lpayments_rec.stub_days;
                        l_splitpymt_tbl (l_splitpymt_count).p_stub_amount :=
                                                  l_lpayments_rec.stub_amount;
                     END LOOP;

                     -- loop thru the proposed payments, calculated by quote creation process, or this stream type
                     i := 0;

                     FOR l_cashflows_rec IN
                        l_cashflows_csr (l_quoteobjects_rec.cfo_id,
                                         l_rgpslh_rec.sty_id)
                     LOOP
                        i := i + 1;

                        -- if proposed payment exists, current (split) payment will definitely exist
                        IF l_splitpymt_tbl.EXISTS (i)
                        THEN
                           IF     l_cashflows_rec.start_date =
                                             l_splitpymt_tbl (i).p_start_date
                              AND l_cashflows_rec.start_date <=
                                                               l_date_eff_from
                           THEN
                              IF l_cashflows_rec.due_arrears_yn = 'N'
                              THEN
                                 -- SECHAWLA 20-SEP-04 3816891 : ADV, Added this condition
                                 -- SECHAWLA 20-SEP-04 3816891 Keep the same logic for Advance : begin
                                 -- update period or stub days
                                 IF l_cashflows_rec.stub_days IS NULL
                                 THEN
                                    IF l_splitpymt_tbl (i).p_number_of_periods <>
                                            l_cashflows_rec.number_of_periods
                                    THEN
                                       l_splitpymt_tbl (i).p_number_of_periods :=
                                            l_cashflows_rec.number_of_periods;
                                    END IF;
                                 ELSE
                                    IF l_splitpymt_tbl (i).p_stub_days <>
                                                    l_cashflows_rec.stub_days
                                    THEN
                                       l_splitpymt_tbl (i).p_stub_days :=
                                                    l_cashflows_rec.stub_days;
                                    END IF;
                                 END IF;
                              -- SECHAWLA 20-SEP-04 3816891 Keep the same logic for Advance : end
                              ELSIF l_cashflows_rec.due_arrears_yn = 'Y'
                              THEN
                                 -- SECHAWLA 20-SEP-04 3816891 : Arrears, added this section

                                 -- SECHAWLA 20-SEP-04 3816891 : Added following piece of code for Arrears : begin

                                 -----------------------------------
                                 IF l_cashflows_rec.stub_days IS NULL
                                 THEN
                                    -- get the number of months that a payment covers
                                    IF l_cashflows_rec.fqy_code = 'M'
                                    THEN
                                       l_number_of_months :=
                                          (l_cashflows_rec.number_of_periods
                                          );
                                    ELSIF l_cashflows_rec.fqy_code = 'Q'
                                    THEN
                                       l_number_of_months :=
                                            (l_cashflows_rec.number_of_periods
                                            )
                                          * 3;
                                    ELSIF l_cashflows_rec.fqy_code = 'S'
                                    THEN
                                       l_number_of_months :=
                                            (l_cashflows_rec.number_of_periods
                                            )
                                          * 6;
                                    ELSIF l_cashflows_rec.fqy_code = 'A'
                                    THEN
                                       l_number_of_months :=
                                            (l_cashflows_rec.number_of_periods
                                            )
                                          * 12;
                                    END IF;

                                    -- add months
                                    -- Get the first date after the last level period ends
                                    OPEN l_nextlevelstartdt_csr
                                                  (l_cashflows_rec.start_date,
                                                   l_number_of_months);

                                    FETCH l_nextlevelstartdt_csr
                                     INTO l_next_level_start_date;

                                    CLOSE l_nextlevelstartdt_csr;
                                 ELSE
                                    -- sechawla 20-SEP-04  3816891 : still ok
                                    l_next_level_start_date :=
                                         l_cashflows_rec.start_date
                                       + l_cashflows_rec.stub_days;
                                 END IF;

-----------------------
                                 IF l_date_eff_from >=
                                                (l_next_level_start_date - 1
                                                )
                                 THEN
                                    ---last day of the current level
                                    -- keep the level, update p_number_of_periods/p_stub_days, as above

                                    -- update period or stub days
                                    IF l_cashflows_rec.stub_days IS NULL
                                    THEN
                                       IF l_splitpymt_tbl (i).p_number_of_periods <>
                                             l_cashflows_rec.number_of_periods
                                       THEN
                                          l_splitpymt_tbl (i).p_number_of_periods :=
                                             l_cashflows_rec.number_of_periods;
                                       END IF;
                                    ELSE
                                       IF l_splitpymt_tbl (i).p_stub_days <>
                                                    l_cashflows_rec.stub_days
                                       THEN
                                          l_splitpymt_tbl (i).p_stub_days :=
                                                    l_cashflows_rec.stub_days;
                                       END IF;
                                    END IF;
                                 ELSE
                                    l_splitpymt_tbl.DELETE
                                                       (i,
                                                        l_splitpymt_tbl.COUNT);
                                    EXIT;
                                 END IF;
                              -- SECHAWLA 20-SEP-04 3816891 : Added following piece of code for Arrears : end
                              END IF;            -- SECHAWLA 20-SEP-04 3816891
                           ELSIF    l_cashflows_rec.start_date <
                                       l_splitpymt_tbl (i).p_start_date
                                        -- split has happened in proposed pymt
                                 OR l_cashflows_rec.start_date >
                                                               l_date_eff_from
                           THEN
                              -- SECHAWLA 20-SEP-04 3816891 : still ok, no changes
                              l_splitpymt_tbl.DELETE (i,
                                                      l_splitpymt_tbl.COUNT);
                              EXIT;
                           END IF;
                        END IF;
                     END LOOP;

                     IF i = 0
                     THEN
                        -- proposed payment does not exist for this stream type
                        -- delete the payment from rules, for this stream type
                        lpym_del_tbl := lpym_del_tbl_empty;
                        lpym_del_tbl (1).chr_id := l_rgpslh_rec.dnz_chr_id;
                        lpym_del_tbl (1).rgp_id := l_rgpslh_rec.rgp_id;
                        lpym_del_tbl (1).slh_id := l_rgpslh_rec.slh_id;

                        IF (is_debug_statement_on)
                        THEN
                           okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                 'calling OKL_LA_PAYMENTS_PVT.delete_payment'
                                );
                        END IF;

                        okl_la_payments_pvt.delete_payment
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => okc_api.g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_del_pym_tbl        => lpym_del_tbl,
                                          --bug # 7498330
                                           p_source_trx         => 'TQ'
                                          );

                        IF (is_debug_statement_on)
                        THEN
                           okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.delete_payment , return status: '
                               || l_return_status
                              );
                        END IF;

                        IF (l_return_status = okl_api.g_ret_sts_unexp_error)
                        THEN
                           RAISE okl_api.g_exception_unexpected_error;
                        ELSIF (l_return_status = okl_api.g_ret_sts_error)
                        THEN
                           RAISE okl_api.g_exception_error;
                        END IF;
                     END IF;

                     IF l_splitpymt_tbl.COUNT > 0
                     THEN
                        -- delete the payment for this stream type
                        lpym_del_tbl := lpym_del_tbl_empty;
                        lpym_del_tbl (1).chr_id := l_rgpslh_rec.dnz_chr_id;
                        lpym_del_tbl (1).rgp_id := l_rgpslh_rec.rgp_id;
                        lpym_del_tbl (1).slh_id := l_rgpslh_rec.slh_id;

                        IF (is_debug_statement_on)
                        THEN
                           okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                 'calling OKL_LA_PAYMENTS_PVT.delete_payment'
                                );
                        END IF;

                        okl_la_payments_pvt.delete_payment
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => okc_api.g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_del_pym_tbl        => lpym_del_tbl,
                                         --bug # 7498330
                                           p_source_trx         => 'TQ'
                                          );

                        IF (is_debug_statement_on)
                        THEN
                           okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.delete_payment , return status: '
                               || l_return_status
                              );
                        END IF;

                        IF (l_return_status = okl_api.g_ret_sts_unexp_error)
                        THEN
                           RAISE okl_api.g_exception_unexpected_error;
                        ELSIF (l_return_status = okl_api.g_ret_sts_error)
                        THEN
                           RAISE okl_api.g_exception_error;
                        END IF;

                        -- create payment for this stream type from the l_splitpymt_tbl table
                        lp_pym_hdr_rec.STRUCTURE :=
                                                  l_rgpslh_rec.advance_periods;
                        lp_pym_hdr_rec.frequency := l_rgpslh_rec.frequency;
                        lp_pym_hdr_rec.arrears := l_rgpslh_rec.due_arrears_yn;
                        lp_pym_tbl := lp_pym_tbl_empty;
                        i := l_splitpymt_tbl.FIRST;

                        LOOP
                           lp_pym_tbl (i).stub_days :=
                                              l_splitpymt_tbl (i).p_stub_days;
                           lp_pym_tbl (i).stub_amount :=
                                            l_splitpymt_tbl (i).p_stub_amount;
                           lp_pym_tbl (i).period :=
                                      l_splitpymt_tbl (i).p_number_of_periods;
                           lp_pym_tbl (i).amount :=
                                                 l_splitpymt_tbl (i).p_amount;
                           lp_pym_tbl (i).update_type := 'CREATE';
                           EXIT WHEN (i = l_splitpymt_tbl.LAST);
                           i := l_splitpymt_tbl.NEXT (i);
                        END LOOP;

                        IF l_quoteobjects_rec.oty_code =
                                                        'FINANCIAL_ASSET_LINE'
                        THEN
                           -- create asset level payments
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.process_payment'
                                 );
                           END IF;

                           okl_la_payments_pvt.process_payment
                                    (p_api_version        => p_api_version,
                                     p_init_msg_list      => okc_api.g_false,
                                     x_return_status      => l_return_status,
                                     x_msg_count          => x_msg_count,
                                     x_msg_data           => x_msg_data,
                                     p_chr_id             => l_rgpslh_rec.dnz_chr_id,
                                     --  p_service_fee_id         =>         OKC_API.G_MISS_NUM,
                                     p_asset_id           => l_quoteobjects_rec.line_id,
                                     p_payment_id         => l_rgpslh_rec.sty_id,
                                     p_pym_hdr_rec        => lp_pym_hdr_rec,
                                     p_pym_tbl            => lp_pym_tbl,
                                     p_update_type        => 'CREATE',
                                     x_rulv_tbl           => lx_rulv_tbl
                                    );

                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called OKL_LA_PAYMENTS_PVT.process_payment , return status: '
                                  || l_return_status
                                 );
                           END IF;
                        ELSIF l_quoteobjects_rec.oty_code =
                                                         'SERVICED_ASSET_LINE'
                        THEN
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.process_payment'
                                 );
                           END IF;

                           -- create subline level payments
                           okl_la_payments_pvt.process_payment
                                       (p_api_version         => p_api_version,
                                        p_init_msg_list       => okc_api.g_false,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => x_msg_count,
                                        x_msg_data            => x_msg_data,
                                        p_chr_id              => l_rgpslh_rec.dnz_chr_id,
                                        p_service_fee_id      => l_service_line_id,
                                        p_asset_id            => l_fin_asset_id,
                                        p_payment_id          => l_rgpslh_rec.sty_id,
                                        p_pym_hdr_rec         => lp_pym_hdr_rec,
                                        p_pym_tbl             => lp_pym_tbl,
                                        p_update_type         => 'CREATE',
                                        x_rulv_tbl            => lx_rulv_tbl
                                       );

                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called OKL_LA_PAYMENTS_PVT.process_payment , return status: '
                                  || l_return_status
                                 );
                           END IF;
                        --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
                        ELSIF l_quoteobjects_rec.oty_code = 'FEE_ASSET_LINE'
                        THEN
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                  'calling OKL_LA_PAYMENTS_PVT.process_payment'
                                 );
                           END IF;

                           -- create fee asset subline level payments
                           okl_la_payments_pvt.process_payment
                                         (p_api_version         => p_api_version,
                                          p_init_msg_list       => okc_api.g_false,
                                          x_return_status       => l_return_status,
                                          x_msg_count           => x_msg_count,
                                          x_msg_data            => x_msg_data,
                                          p_chr_id              => l_rgpslh_rec.dnz_chr_id,
                                          p_service_fee_id      => l_fee_line_id,
                                          p_asset_id            => l_fin_asset_id,
                                          p_payment_id          => l_rgpslh_rec.sty_id,
                                          p_pym_hdr_rec         => lp_pym_hdr_rec,
                                          p_pym_tbl             => lp_pym_tbl,
                                          p_update_type         => 'CREATE',
                                          x_rulv_tbl            => lx_rulv_tbl
                                         );

                           --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++
                           IF (is_debug_statement_on)
                           THEN
                              okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called OKL_LA_PAYMENTS_PVT.process_payment , return status: '
                                  || l_return_status
                                 );
                           END IF;
                        END IF;

                        IF (l_return_status = okl_api.g_ret_sts_unexp_error)
                        THEN
                           RAISE okl_api.g_exception_unexpected_error;
                        ELSIF (l_return_status = okl_api.g_ret_sts_error)
                        THEN
                           RAISE okl_api.g_exception_error;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;                                       -- if asset in quote
         END IF;
      END LOOP;

      x_return_status := l_return_status;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         IF l_quoteobjects_csr%ISOPEN
         THEN
            CLOSE l_quoteobjects_csr;
         END IF;

         IF l_trxquotes_csr%ISOPEN
         THEN
            CLOSE l_trxquotes_csr;
         END IF;

         IF l_quotelines_csr%ISOPEN
         THEN
            CLOSE l_quotelines_csr;
         END IF;

         IF l_cashflowstreams_csr%ISOPEN
         THEN
            CLOSE l_cashflowstreams_csr;
         END IF;

         IF l_cashflowlevels_csr%ISOPEN
         THEN
            CLOSE l_cashflowlevels_csr;
         END IF;

         IF l_rgpslh_csr%ISOPEN
         THEN
            CLOSE l_rgpslh_csr;
         END IF;

         IF l_cashflows_csr%ISOPEN
         THEN
            CLOSE l_cashflows_csr;
         END IF;

         IF l_lpayments_csr%ISOPEN
         THEN
            CLOSE l_lpayments_csr;
         END IF;

         IF l_finasset_csr%ISOPEN
         THEN
            CLOSE l_finasset_csr;
         END IF;

         --Bug #3921591: pagarg +++ Rollover +++
         -- Changed the cursor name as made it generalised
         IF l_lineassets_csr%ISOPEN
         THEN
            CLOSE l_lineassets_csr;
         END IF;

         ROLLBACK TO update_payments;
         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         IF l_quoteobjects_csr%ISOPEN
         THEN
            CLOSE l_quoteobjects_csr;
         END IF;

         IF l_trxquotes_csr%ISOPEN
         THEN
            CLOSE l_trxquotes_csr;
         END IF;

         IF l_quotelines_csr%ISOPEN
         THEN
            CLOSE l_quotelines_csr;
         END IF;

         IF l_cashflowstreams_csr%ISOPEN
         THEN
            CLOSE l_cashflowstreams_csr;
         END IF;

         IF l_cashflowlevels_csr%ISOPEN
         THEN
            CLOSE l_cashflowlevels_csr;
         END IF;

         IF l_rgpslh_csr%ISOPEN
         THEN
            CLOSE l_rgpslh_csr;
         END IF;

         IF l_cashflows_csr%ISOPEN
         THEN
            CLOSE l_cashflows_csr;
         END IF;

         IF l_lpayments_csr%ISOPEN
         THEN
            CLOSE l_lpayments_csr;
         END IF;

         IF l_finasset_csr%ISOPEN
         THEN
            CLOSE l_finasset_csr;
         END IF;

         --Bug #3921591: pagarg +++ Rollover +++
         -- Changed the cursor name as made it generalised
         IF l_lineassets_csr%ISOPEN
         THEN
            CLOSE l_lineassets_csr;
         END IF;

         ROLLBACK TO update_payments;
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         IF l_quoteobjects_csr%ISOPEN
         THEN
            CLOSE l_quoteobjects_csr;
         END IF;

         IF l_trxquotes_csr%ISOPEN
         THEN
            CLOSE l_trxquotes_csr;
         END IF;

         IF l_quotelines_csr%ISOPEN
         THEN
            CLOSE l_quotelines_csr;
         END IF;

         IF l_cashflowstreams_csr%ISOPEN
         THEN
            CLOSE l_cashflowstreams_csr;
         END IF;

         IF l_cashflowlevels_csr%ISOPEN
         THEN
            CLOSE l_cashflowlevels_csr;
         END IF;

         IF l_rgpslh_csr%ISOPEN
         THEN
            CLOSE l_rgpslh_csr;
         END IF;

         IF l_cashflows_csr%ISOPEN
         THEN
            CLOSE l_cashflows_csr;
         END IF;

         IF l_lpayments_csr%ISOPEN
         THEN
            CLOSE l_lpayments_csr;
         END IF;

         IF l_finasset_csr%ISOPEN
         THEN
            CLOSE l_finasset_csr;
         END IF;

         --Bug #3921591: pagarg +++ Rollover +++
         -- Changed the cursor name as made it generalised
         IF l_lineassets_csr%ISOPEN
         THEN
            CLOSE l_lineassets_csr;
         END IF;

         ROLLBACK TO update_payments;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END update_payments;

   -- Start of Commnets
   --
   -- Procedure Name       : update_lines
   -- Description          : This Procedure is Used to Update the Asset lines by
   --                        changing the status to TERMINATED
   --                        also update other lines like FEE, Sold Sevice and
   --                        Usage Based Billing Lines by
   --                        changing the status to TERMINATED, where the
   --                        Terminated Asset lines are referenced.
   --                        Also Sum the capital amount for fee sub lines and
   --                        Sold service Sub lines excluding the
   --                        terminated Asset lines to update the Top lines of FEE,
   --                        SOLD SERVICE lines. And further
   --                        pro-rate the payment amount respectively associated
   --                        to the top lines of FEE, SOLD SERVICE Lines.

   -- Business Rules       :
   -- Parameters           :
   -- Version              :1.0
   -- History              : 02-DEC-2002 BAKUHCIB 115.2 Bug# 2484327
   --                         Added code to populate Message Stack in case Failure
   --                         and Success of Call to an API
   --                      : RMUNJULU -- 04-DEC-02 Bug #  2484327
   --                         Moved record and tbl types and constants to spec
   --                         Moved the setting of message stack to terminate_lines
   --                         Added parameter p_trn_reason_code and setting that
   --                         when lines terminated, Added x_msg_tbl parameter
   --                         Added comments to cursors, Added code to set trn_code
   --                         Changed code to set savepoint instead of start/end activity
   --                      :  BAKUCHIB 28-MAR-03 2877278 Added code to get the klev_tbl
   --                         and append to it all the top service and fee lines which
   --                         are being terminated, this will be passed to close streams
   --                         which will close the streams for those lines
   --                      :  RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
   --                         Changed SLL rule to LASLL
   --                      :  SECHAWLA 28-OCT-03 2846988 Update payments on quote acceptance
   --                         Added a call to update_payments procedure
   --                      :  rmunjulu EDAT Added code for effective dated terminations
   --                      : rmunjulu LOANS_ENHANCEMENTS get and set termination value in okl_K_lines and okl_contract_balances
   -- End of Comments
   PROCEDURE update_lines (
      p_api_version       IN              NUMBER,
      p_init_msg_list     IN              VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_klev_tbl          IN              klev_tbl_type,
      p_status            IN              VARCHAR2,
      p_trn_reason_code   IN              VARCHAR2,
      x_klev_tbl          OUT NOCOPY      klev_tbl_type,
                                 -- BAKUCHIB 28-MAR-03 2877278 Added parameter
      x_msg_tbl           OUT NOCOPY      g_msg_tbl
   )
   IS
      -- RMUNJULU Bug #  2484327 changed parameters to IN
      -- We need to change the status of lines
      CURSOR l_trmnt_line_csr (
         p_cle_id   IN   okc_k_lines_b.ID%TYPE
      )
      IS
         SELECT     cle.ID ID
               FROM okc_k_lines_b cle
         CONNECT BY PRIOR cle.ID = cle.cle_id
         START WITH cle.ID = p_cle_id;

      -- RMUNJULU Bug #  2484327 changed parameters to IN
      -- We need to change the status of Fee, Sold Service and Usage
      -- Based Billing lines
      CURSOR l_get_sls_csr (
         p_chr_id     IN   okc_k_headers_b.ID%TYPE,
         p_sts_code   IN   okc_k_headers_b.sts_code%TYPE,
         p_cle_id     IN   okc_k_lines_b.ID%TYPE
      )
      IS
         SELECT cim.cle_id cle_id
           FROM okc_k_items cim
          WHERE cim.dnz_chr_id = p_chr_id
            AND cim.jtot_object1_code = 'OKX_COVASST'
            AND cim.object1_id1 IN (
                   SELECT cle.ID
                     FROM okc_k_lines_b cle,
                          okc_line_styles_b lse
                    WHERE cle.dnz_chr_id = p_chr_id
                      AND cle.lse_id = lse.ID
                      AND lse.lty_code = g_fin_line_lty_code
                      AND lse.lse_type = g_tls_type
                      AND cle.sts_code = p_sts_code
                      AND cle.ID = p_cle_id);

      -- RMUNJULU Bug #  2484327 changed parameters to IN
      -- We need to make sure that there are not Orphaned TOP lines of Fee,
      -- Sold Service and Usage Based Billing Lines
      CURSOR l_scan_sls_csr (
         p_cle_id   IN   okc_k_lines_v.ID%TYPE
      )
      IS
         SELECT kle.sts_code sts_code
           FROM okc_k_lines_b kle
          WHERE kle.cle_id = p_cle_id;

      -- RMUNJULU Bug #  2484327 changed parameters to IN
      -- We need to find out weahter we have fee, service, and Usage lines first
      -- so that we can Pro- rate and Sum up the Capital amount
      --and amount to the Top Lines after excluding Terminated Lines
      CURSOR l_chk_other_line_csr (
         p_chr_id   IN   okc_k_headers_b.ID%TYPE
      )
      IS
         SELECT '1'
           FROM DUAL
          WHERE EXISTS (
                   SELECT '1'
                     FROM okc_k_lines_b cle,
                          okc_line_styles_b lse
                    WHERE cle.dnz_chr_id = p_chr_id
                      AND lse.ID = cle.lse_id
                      AND lse.lty_code IN
                             (g_ser_line_lty_code,
                              g_srl_line_lty_code,
                              g_fee_line_lty_code,
                              g_fel_line_lty_code,
                              g_usg_line_lty_code,
                              g_usl_line_lty_code
                             ));

      -- RMUNJULU Bug #  2484327 changed parameters to IN
      -- We need to get the summed up amount for Sub lines of Fee and
      -- Sold Service Lines Excluding the terminated Lines
      CURSOR l_new_sls_amt_csr (
         p_chr_id     IN   okc_k_lines_v.dnz_chr_id%TYPE,
         p_sts_code   IN   okc_k_headers_b.sts_code%TYPE
      )
      IS
         SELECT   SUM (kle.capital_amount) amount,
                  cle.cle_id cle_id
             FROM okc_k_lines_b cle,
                  okl_k_lines kle,
                  okc_line_styles_b lse
            WHERE kle.ID = cle.ID
              AND cle.dnz_chr_id = p_chr_id
              AND cle.lse_id = lse.ID
              AND lse.lty_code IN (g_srl_line_lty_code, g_fel_line_lty_code)
              AND cle.sts_code <> p_sts_code
              AND cle.date_terminated IS NULL
         GROUP BY cle.cle_id;

      -- RMUNJULU Bug #  2484327 changed parameters to IN
      -- We need to get the summed up amount for Sub lines of Fee and
      -- Sold Service Lines, Including the terminated Lines
      CURSOR l_old_sls_amt_csr (
         p_chr_id   IN   okc_k_lines_v.dnz_chr_id%TYPE
      )
      IS
         SELECT   SUM (kle.capital_amount) amount,
                  cle.cle_id cle_id
             FROM okc_k_lines_b cle,
                  okl_k_lines kle,
                  okc_line_styles_b lse
            WHERE kle.ID = cle.ID
              AND cle.dnz_chr_id = p_chr_id
              AND cle.lse_id = lse.ID
              AND lse.lty_code IN (g_srl_line_lty_code, g_fel_line_lty_code)
              AND cle.date_terminated IS NULL
         GROUP BY cle.cle_id;

      -- RMUNJULU Bug #  2484327 changed parameters to IN
      -- We need to get the Payment Info for Fee and Sold Service lines
      CURSOR l_sls_rule_pymnt_csr (
         p_chr_id     IN   okc_k_lines_v.dnz_chr_id%TYPE,
         p_cle_id     IN   okc_k_lines_v.ID%TYPE,
         p_sts_code   IN   okc_k_headers_b.sts_code%TYPE
      )
      IS
         SELECT rl.ID ID,
                rl.rule_information6 payment_amount
           FROM okc_rule_groups_b rg,
                okc_rules_b rl,
                okc_k_lines_v cle,
                okc_line_styles_b lse
          WHERE cle.dnz_chr_id = p_chr_id
            AND cle.ID = p_cle_id
            AND cle.lse_id = lse.ID
            AND lse.lty_code IN (g_ser_line_lty_code, g_fee_line_lty_code)
            AND lse.lse_type = 'TLS'
            AND cle.cle_id IS NULL
            AND rg.dnz_chr_id = cle.dnz_chr_id
            AND rg.cle_id = cle.ID
            AND rg.chr_id IS NULL
            AND rg.ID = rl.rgp_id
            AND rg.rgd_code = 'LALEVL'
            AND rl.rule_information_category =
                              'LASLL'
                                     -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION
            AND EXISTS (
                   SELECT '1'
                     FROM okc_k_lines_v cle_sl,
                          okc_line_styles_b lse_sl
                    WHERE cle_sl.dnz_chr_id = p_chr_id
                      AND cle_sl.cle_id = cle.ID
                      AND cle_sl.lse_id = lse_sl.ID
                      AND cle_sl.sts_code <> p_sts_code
                      AND lse_sl.lty_code IN
                                   (g_srl_line_lty_code, g_fel_line_lty_code));

      l_api_name     CONSTANT VARCHAR2 (30)                  := 'update_lines';
      i                       NUMBER                               := 0;
      j                       NUMBER                               := 0;
      ln_dummy                NUMBER                               := 0;
      l_module_name           VARCHAR2 (500)
                                            := g_module_name || 'update_lines';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      lv_terminate_tls        VARCHAR2 (3)                         := NULL;
      ln_sls_payment_amount   NUMBER                               := 0;
      ln_new_amount           NUMBER                               := 0;
      ln_old_amount           NUMBER                               := 0;
      ln_cle_id               NUMBER                               := 0;
      l_chr_id                okc_k_headers_b.ID%TYPE
                                                   := p_term_rec.p_contract_id;
      l_akle_tbl              klev_tbl_type                      := p_klev_tbl;
      l_clev_rec              okl_okc_migration_pvt.clev_rec_type;
      l_klev_rec              okl_contract_pub.klev_rec_type;
      lx_clev_rec             okl_okc_migration_pvt.clev_rec_type;
      lx_klev_rec             okl_contract_pub.klev_rec_type;
      r_clev_rec              okl_okc_migration_pvt.clev_rec_type;
      r_klev_rec              okl_contract_pub.klev_rec_type;
      rx_clev_rec             okl_okc_migration_pvt.clev_rec_type;
      rx_klev_rec             okl_contract_pub.klev_rec_type;
      m_clev_rec              okl_okc_migration_pvt.clev_rec_type;
      m_klev_rec              okl_contract_pub.klev_rec_type;
      mx_clev_rec             okl_okc_migration_pvt.clev_rec_type;
      mx_klev_rec             okl_contract_pub.klev_rec_type;
      n_clev_rec              okl_okc_migration_pvt.clev_rec_type;
      n_klev_rec              okl_contract_pub.klev_rec_type;
      nx_clev_rec             okl_okc_migration_pvt.clev_rec_type;
      nx_klev_rec             okl_contract_pub.klev_rec_type;
      l_rulv_rec              okl_rule_pub.rulv_rec_type;
      lx_rulv_rec             okl_rule_pub.rulv_rec_type;
      r_rulv_rec              okl_rule_pub.rulv_rec_type;
      rx_rulv_rec             okl_rule_pub.rulv_rec_type;
      lt_old_sls_amt          g_cle_amt_tbl;
      lt_new_sls_amt          g_cle_amt_tbl;
      k                       NUMBER                               := 0;
      lt_msg_tbl              g_msg_tbl;
      lv_id1                  okc_k_items.object1_id1%TYPE;
      lv_id2                  okc_k_items.object1_id2%TYPE;
      lv_code                 okc_k_items.jtot_object1_code%TYPE;
      -- SECHAWLA 28-OCT-03 2846988 : New declarations
      l_return_status         VARCHAR2 (1)        := okl_api.g_ret_sts_success;

      -- RMUNJULU Bug #  2484327 Added comments, changed parameters to IN
      -- We need to find out the object1_id1 and object1_id2 and jtot_object1_code
      -- to get the name of the fee or service or ubb line based on jtot_object1_code
      CURSOR l_item_line_csr (
         p_cle_id       IN   okc_k_lines_b.ID%TYPE,
         p_dnz_chr_id   IN   okc_k_lines_b.dnz_chr_id%TYPE
      )
      IS
         SELECT cim.object1_id1 object1_id1,
                cim.object1_id2 object1_id2,
                cim.jtot_object1_code jtot_object1_code
           FROM okc_k_items cim
          WHERE cim.dnz_chr_id = p_dnz_chr_id AND cim.cle_id = p_cle_id;

      -- RMUNJULU Bug #  2484327 Added comments, changed parameters to IN
      -- We need to get the name of the service line
      CURSOR l_service_line_csr (
         p_id1   IN   okc_k_items.object1_id1%TYPE,
         p_id2   IN   okc_k_items.object1_id2%TYPE
      )
      IS
         SELECT siv.NAME NAME
           FROM okx_system_items_v siv
          WHERE siv.id1 = p_id1 AND siv.id2 = p_id2;

      -- RMUNJULU Bug #  2484327 Added comments, changed parameters to IN
      -- We need to get the name of the fee line
      CURSOR l_fee_line_csr (
         p_id1   IN   okc_k_items.object1_id1%TYPE,
         p_id2   IN   okc_k_items.object1_id2%TYPE
      )
      IS
         SELECT ssv.NAME NAME
           FROM okl_strmtyp_source_v ssv
          WHERE ssv.id1 = p_id1 AND ssv.id2 = p_id2;

      -- RMUNJULU Bug #  2484327 Added comments, changed parameters to IN
      -- We need to get the name of the UBB line
      CURSOR l_usage_line_csr (
         p_id1   IN   okc_k_items.object1_id1%TYPE,
         p_id2   IN   okc_k_items.object1_id2%TYPE
      )
      IS
         SELECT siv.NAME NAME
           FROM okx_system_items_v siv
          WHERE siv.id1 = p_id1 AND siv.id2 = p_id2;

      -- BAKUCHIB 28-MAR-03 2877278 Added variable
      lx_klev_tbl             klev_tbl_type                      := l_akle_tbl;
      -- rmunjulu EDAT
      l_quote_accpt_date      DATE;
      l_quote_eff_date        DATE;

      -- rmunjulu LOANS_ENHACEMENTS
      CURSOR check_balances_rec_exists_csr (
         p_kle_id   IN   NUMBER
      )
      IS
         SELECT 'Y'
           FROM okl_contract_balances
          WHERE kle_id = p_kle_id;

      -- rmunjulu LOANS_ENHACEMENTS
      l_termination_value     NUMBER;
      lap_clev_rec            okl_okc_migration_pvt.clev_rec_type;
      lap_klev_rec            okl_contract_pub.klev_rec_type;
      lax_clev_rec            okl_okc_migration_pvt.clev_rec_type;
      lax_klev_rec            okl_contract_pub.klev_rec_type;
      p_cblv_rec              okl_cbl_pvt.cblv_rec_type;
      x_cblv_rec              okl_cbl_pvt.cblv_rec_type;
      l_empty_clev_rec        okl_okc_migration_pvt.clev_rec_type;
      l_empty_klev_rec        okl_contract_pub.klev_rec_type;
      l_balances_rec_exists   VARCHAR2 (3);
   BEGIN
      -- RMUNJULU Bug # 2484327, added code to set savepoint
      -- Start a savepoint to rollback to if error in this block
      SAVEPOINT update_lines;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_status: ' || p_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_reason_code: '
                                  || p_trn_reason_code
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );

         IF p_klev_tbl.COUNT > 0
         THEN
            FOR i IN p_klev_tbl.FIRST .. p_klev_tbl.LAST
            LOOP
               IF (p_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || p_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || p_klev_tbl (i).p_asset_name
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      x_return_status := g_ret_sts_success;

      -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

      -- rmunjulu EDAT
      -- If quote exists then accnting date is quote accept date else sysdate
      IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
      THEN
         l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
         l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
      ELSE
         l_quote_accpt_date := p_sys_date;
         l_quote_eff_date := p_sys_date;
      END IF;

      -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

      -- Summing up amount of all the sub lines populating Amount and Capital amount
      FOR r_old_sls_amt_csr IN l_old_sls_amt_csr (p_chr_id      => l_chr_id)
      LOOP
         lt_old_sls_amt (j).amount := r_old_sls_amt_csr.amount;
         lt_old_sls_amt (j).cle_id := r_old_sls_amt_csr.cle_id;
         j := j + 1;
      END LOOP;

      -- Verify the Lines and Contract id
      IF l_akle_tbl.COUNT > 0
      THEN
         i := l_akle_tbl.FIRST;

         LOOP
            validate_chr_cle_id (p_dnz_chr_id         => l_chr_id,
                                 p_top_line_id        => l_akle_tbl (i).p_kle_id,
                                 x_return_status      => x_return_status
                                );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called validate_chr_cle_id , return status: '
                            || x_return_status
                           );
            END IF;

            IF (x_return_status = g_ret_sts_unexp_error)
            THEN
               EXIT WHEN (x_return_status = g_ret_sts_unexp_error);
            ELSIF (x_return_status = g_ret_sts_error)
            THEN
               EXIT WHEN (x_return_status = g_ret_sts_error);
            END IF;

            -- Now we Change the status of the Lines
            FOR r_trmnt_line_csr IN
               l_trmnt_line_csr (p_cle_id      => l_akle_tbl (i).p_kle_id)
            LOOP
               l_clev_rec.ID := r_trmnt_line_csr.ID;
               l_klev_rec.ID := r_trmnt_line_csr.ID;
               l_clev_rec.date_terminated := l_quote_eff_date;
                                                             -- rmunjulu EDAT
               l_clev_rec.sts_code := p_status;
               -- RMUNJULU -- Bug # 2484327 -- Added code to set trn_code
               l_clev_rec.trn_code := p_trn_reason_code;

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                              'calling OKL_CONTRACT_PUB.update_contract_line'
                             );
               END IF;

               okl_contract_pub.update_contract_line
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_clev_rec           => l_clev_rec,
                                           p_klev_rec           => l_klev_rec,
                                           x_clev_rec           => lx_clev_rec,
                                           x_klev_rec           => lx_klev_rec
                                          );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                         'calling OKL_CONTRACT_PUB.update_contract_line , return status: '
                      || x_return_status
                     );
               END IF;

               IF x_return_status <> g_ret_sts_success
               THEN
                  -- Error in terminating asset ASSET_NAME.
                  okl_api.set_message
                                (p_app_name          => g_app_name,
                                 p_msg_name          => g_am_err_trmt_asset,
                                 p_token1            => 'ASSET_NAME',
                                 p_token1_value      => l_akle_tbl (i).p_asset_name
                                );
               ELSIF x_return_status = g_ret_sts_success
               THEN
                  lt_msg_tbl (k).msg_desc := g_am_asset_trmt;
                  lt_msg_tbl (k).msg_token1 := 'ASSET_NUMBER';
                  lt_msg_tbl (k).msg_token1_value :=
                                                  l_akle_tbl (i).p_asset_name;
               END IF;

               IF (x_return_status = g_ret_sts_unexp_error)
               THEN
                  EXIT WHEN (x_return_status = g_ret_sts_unexp_error);
               ELSIF (x_return_status = g_ret_sts_error)
               THEN
                  EXIT WHEN (x_return_status = g_ret_sts_error);
               END IF;
            END LOOP;

            IF (x_return_status = g_ret_sts_unexp_error)
            THEN
               EXIT WHEN (x_return_status = g_ret_sts_unexp_error);
            ELSIF (x_return_status = g_ret_sts_error)
            THEN
               EXIT WHEN (x_return_status = g_ret_sts_error);
            END IF;

            --Now we are terminating the Service Line, Fee line, Ubb Lines,
            -- if exists, Where the Asset lines are terminated
            FOR r_get_sls_csr IN
               l_get_sls_csr (p_chr_id        => l_chr_id,
                              p_sts_code      => p_status,
                              p_cle_id        => l_akle_tbl (i).p_kle_id
                             )
            LOOP
               r_clev_rec.ID := r_get_sls_csr.cle_id;
               r_klev_rec.ID := r_get_sls_csr.cle_id;
               r_clev_rec.date_terminated := l_quote_eff_date;
                                                             -- rmunjulu EDAT
               r_clev_rec.sts_code := p_status;
               -- RMUNJULU -- Bug # 2484327 -- Added code to set trn_code
               r_clev_rec.trn_code := p_trn_reason_code;

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                              'calling OKL_CONTRACT_PUB.update_contract_line'
                             );
               END IF;

               okl_contract_pub.update_contract_line
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_clev_rec           => r_clev_rec,
                                           p_klev_rec           => r_klev_rec,
                                           x_clev_rec           => rx_clev_rec,
                                           x_klev_rec           => rx_klev_rec
                                          );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                         'called OKL_CONTRACT_PUB.update_contract_line , return status: '
                      || x_return_status
                     );
               END IF;

               IF x_return_status <> g_ret_sts_success
               THEN
                  -- Error in terminating sublines of service lines, fee lines and
                  -- UBB lines of asset ASSET_NAME.
                  okl_api.set_message
                                (p_app_name          => g_app_name,
                                 p_msg_name          => g_am_err_trmt_asset_ln,
                                 p_token1            => 'ASSET_NAME',
                                 p_token1_value      => l_akle_tbl (i).p_asset_name
                                );
               END IF;

               IF (x_return_status = g_ret_sts_unexp_error)
               THEN
                  EXIT WHEN (x_return_status = g_ret_sts_unexp_error);
               ELSIF (x_return_status = g_ret_sts_error)
               THEN
                  EXIT WHEN (x_return_status = g_ret_sts_error);
               END IF;

               -- Now need to make sure we do not have orphaned Top Lines
               -- Where the sub lines are terminated.
               -- If we have we need to terminate the Top Line also.
               FOR r_l_scan_sls_csr IN
                  l_scan_sls_csr (p_cle_id      => rx_clev_rec.cle_id)
               LOOP
                  IF r_l_scan_sls_csr.sts_code <> p_status
                  THEN
                     lv_terminate_tls := 'N';
                     EXIT WHEN (lv_terminate_tls = 'N');
                  ELSIF r_l_scan_sls_csr.sts_code = p_status
                  THEN
                     lv_terminate_tls := 'Y';
                  END IF;
               END LOOP;

               IF lv_terminate_tls = 'Y'
               THEN
                  IF    rx_clev_rec.cle_id <> g_miss_num
                     OR rx_clev_rec.cle_id IS NOT NULL
                  THEN
                     m_clev_rec.ID := rx_clev_rec.cle_id;
                     m_klev_rec.ID := rx_clev_rec.cle_id;
                     m_clev_rec.date_terminated := l_quote_eff_date;
                                                             -- rmunjulu EDAT
                     m_clev_rec.sts_code := p_status;
                     -- RMUNJULU -- Bug # 2484327 -- Added code to set trn_code
                     m_clev_rec.trn_code := p_trn_reason_code;

                     IF (is_debug_statement_on)
                     THEN
                        okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                              'calling OKL_CONTRACT_PUB.update_contract_line'
                             );
                     END IF;

                     okl_contract_pub.update_contract_line
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_clev_rec           => m_clev_rec,
                                           p_klev_rec           => m_klev_rec,
                                           x_clev_rec           => mx_clev_rec,
                                           x_klev_rec           => mx_klev_rec
                                          );

                     IF (is_debug_statement_on)
                     THEN
                        okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called OKL_CONTRACT_PUB.update_contract_line , return status: '
                            || x_return_status
                           );
                     END IF;

                     IF x_return_status <> g_ret_sts_success
                     THEN
                        -- Error in terminating service lines, fee lines and UBB lines.
                        okl_api.set_message
                                          (p_app_name      => g_app_name,
                                           p_msg_name      => g_am_err_trmt_top_ln);
                     ELSIF x_return_status = g_ret_sts_success
                     THEN
                        OPEN l_item_line_csr
                                      (p_cle_id          => mx_clev_rec.ID,
                                       p_dnz_chr_id      => mx_clev_rec.dnz_chr_id);

                        FETCH l_item_line_csr
                         INTO lv_id1,
                              lv_id2,
                              lv_code;

                        CLOSE l_item_line_csr;

                        IF lv_code = 'OKL_STRMTYP'
                        THEN
                           k := k + 1;

                           OPEN l_fee_line_csr (p_id1      => lv_id1,
                                                p_id2      => lv_id2);

                           FETCH l_fee_line_csr
                            INTO lt_msg_tbl (k).msg_token1_value;

                           CLOSE l_fee_line_csr;

                           lt_msg_tbl (k).msg_desc := g_am_fee_trmt;
                           lt_msg_tbl (k).msg_token1 := 'FEE_NAME';
                        ELSIF lv_code = 'OKX_SERVICE'
                        THEN
                           k := k + 1;

                           OPEN l_service_line_csr (p_id1      => lv_id1,
                                                    p_id2      => lv_id2);

                           FETCH l_service_line_csr
                            INTO lt_msg_tbl (k).msg_token1_value;

                           CLOSE l_service_line_csr;

                           lt_msg_tbl (k).msg_desc := g_am_service_trmt;
                           lt_msg_tbl (k).msg_token1 := 'SERVICE_NAME';
                        ELSIF lv_code = 'OKX_USAGE'
                        THEN
                           k := k + 1;

                           OPEN l_usage_line_csr (p_id1      => lv_id1,
                                                  p_id2      => lv_id2);

                           FETCH l_usage_line_csr
                            INTO lt_msg_tbl (k).msg_token1_value;

                           CLOSE l_usage_line_csr;

                           lt_msg_tbl (k).msg_desc := g_am_usage_trmt;
                           lt_msg_tbl (k).msg_token1 := 'USAGE_NAME';
                        END IF;
                     END IF;

                     -- BAKUCHIB 28-MAR-03 2877278 Append to the klev_tbl this top service/fee
                     -- line which too is being terminated
                     lx_klev_tbl (lx_klev_tbl.LAST + 1).p_kle_id :=
                                                                mx_clev_rec.ID;

                     IF (x_return_status = g_ret_sts_unexp_error)
                     THEN
                        EXIT WHEN (x_return_status = g_ret_sts_unexp_error);
                     ELSIF (x_return_status = g_ret_sts_error)
                     THEN
                        EXIT WHEN (x_return_status = g_ret_sts_error);
                     END IF;
                  ELSE
                     x_return_status := g_ret_sts_error;
                     EXIT WHEN (x_return_status = g_ret_sts_error);
                  END IF;
               END IF;
            END LOOP;

            IF (x_return_status = g_ret_sts_unexp_error)
            THEN
               EXIT WHEN (x_return_status = g_ret_sts_unexp_error);
            ELSIF (x_return_status = g_ret_sts_error)
            THEN
               EXIT WHEN (x_return_status = g_ret_sts_error);
            END IF;

            -- rmunjulu LOANS_ENHACEMENTS -- start
            -- get termination value for the terminated asset
            l_termination_value :=
               okl_am_util_pvt.get_actual_asset_residual
                                           (p_khr_id      => l_chr_id,
                                            p_kle_id      => l_akle_tbl (i).p_kle_id);
            -- update okc_k_lines termination value
            lap_clev_rec := l_empty_clev_rec;
            lap_klev_rec := l_empty_klev_rec;
            lap_clev_rec.ID := l_akle_tbl (i).p_kle_id;
            lap_klev_rec.ID := l_akle_tbl (i).p_kle_id;
            lap_klev_rec.termination_value := l_termination_value;

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                              'calling OKL_CONTRACT_PUB.update_contract_line'
                             );
            END IF;

            okl_contract_pub.update_contract_line
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_clev_rec           => lap_clev_rec,
                                           p_klev_rec           => lap_klev_rec,
                                           x_clev_rec           => lax_clev_rec,
                                           x_klev_rec           => lax_klev_rec
                                          );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_CONTRACT_PUB.update_contract_line , return status: '
                   || l_return_status
                  );
            END IF;

            -- Raise exception to rollback to savepoint
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            -- update balances table
            -- check if rec exists if exists then update else create
            OPEN check_balances_rec_exists_csr (l_akle_tbl (i).p_kle_id);

            FETCH check_balances_rec_exists_csr
             INTO l_balances_rec_exists;

            CLOSE check_balances_rec_exists_csr;

            p_cblv_rec.khr_id := l_chr_id;
            p_cblv_rec.kle_id := l_akle_tbl (i).p_kle_id;
            p_cblv_rec.termination_value_amt := l_termination_value;
            p_cblv_rec.termination_date := l_quote_eff_date;

            IF NVL (l_balances_rec_exists, 'N') = 'Y'
            THEN
               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'calling OKL_CBL_PVT.update_row'
                                          );
               END IF;

               okl_cbl_pvt.update_row (p_api_version        => p_api_version,
                                       p_init_msg_list      => okl_api.g_false,
                                       x_return_status      => x_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_cblv_rec           => p_cblv_rec,
                                       x_cblv_rec           => x_cblv_rec
                                      );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                            'called OKL_CBL_PVT.update_row , return status: '
                         || x_return_status
                        );
               END IF;

               -- Raise exception to rollback to savepoint
               IF (l_return_status = g_ret_sts_unexp_error)
               THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (l_return_status = g_ret_sts_error)
               THEN
                  RAISE okl_api.g_exception_error;
               END IF;
            ELSE
               -- balances rec does not exist so insert
               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'calling OKL_CBL_PVT.insert_row'
                                          );
               END IF;

               okl_cbl_pvt.insert_row (p_api_version        => p_api_version,
                                       p_init_msg_list      => okl_api.g_false,
                                       x_return_status      => x_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_cblv_rec           => p_cblv_rec,
                                       x_cblv_rec           => x_cblv_rec
                                      );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                            'called OKL_CBL_PVT.insert_row , return status: '
                         || x_return_status
                        );
               END IF;

               -- Raise exception to rollback to savepoint
               IF (l_return_status = g_ret_sts_unexp_error)
               THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (l_return_status = g_ret_sts_error)
               THEN
                  RAISE okl_api.g_exception_error;
               END IF;
            END IF;

            -- rmunjulu LOANS_ENHACEMENTS -- end
            EXIT WHEN (i = l_akle_tbl.LAST);
            i := l_akle_tbl.NEXT (i);
            k := k + 1;
         END LOOP;

         IF (x_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;
      ELSE
         -- RMUNJULU -- Bug # 2484327 -- Changed to call set_message with =>
         -- No assets found for termination.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_required_value,
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'p_klev_tbl.id'
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      --29-JUL-04 SECHAWLA 3798158 : Commented out the check for existence of service/fee/usage lines
      -- Payments should be updated even if K has no service/fee/usage lines attached

      /*
      -- We need to find out whether we have fee, service, and Usage lines first
      -- so that we can process further
      OPEN  l_chk_other_line_csr(p_chr_id => l_chr_id);
      FETCH l_chk_other_line_csr INTO ln_dummy;
      CLOSE l_chk_other_line_csr;

      IF ln_dummy = 1 THEN
      */
      -- SECHAWLA 28-OCT-03 2846988  Added the following procedure call to update payments on the
      -- contract, when a partial termination quote is accepted
      update_payments (p_api_version        => p_api_version,
                       p_init_msg_list      => okc_api.g_false,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       x_return_status      => l_return_status,
                       p_quote_id           => p_term_rec.p_quote_id
                      );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                   'called update_payments , return status: '
                                || l_return_status
                               );
      END IF;

      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- SECHAWLA 28-OCT-03 2846988 : Commented out the following code. The above call now updates the payments

      /*  -- Summing up amount of all the sub lines which are not
      -- Terminated populating Amount and Capital amount
      FOR r_new_sls_amt_csr IN l_new_sls_amt_csr(p_chr_id   => l_chr_id,
                                                 p_sts_code => p_status) LOOP

        ln_new_amount             := ROUND(r_new_sls_amt_csr.amount,2);
        n_klev_rec.amount         := ROUND(r_new_sls_amt_csr.amount,2);
        n_klev_rec.capital_amount := ROUND(r_new_sls_amt_csr.amount,2);
        n_klev_rec.id             := r_new_sls_amt_csr.cle_id;
        n_clev_rec.id             := r_new_sls_amt_csr.cle_id;

        OKL_CONTRACT_PUB.update_contract_line(
                         p_api_version   => p_api_version,
                         p_init_msg_list => G_FALSE,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_clev_rec      => n_clev_rec,
                         p_klev_rec      => n_klev_rec,
                         x_clev_rec      => nx_clev_rec,
                         x_klev_rec      => nx_klev_rec);

        IF x_return_status <> G_RET_STS_SUCCESS THEN

            -- Error in updating amounts of service and fee lines.
            OKL_API.set_message(
                          p_app_name      => G_APP_NAME,
                          p_msg_name      => G_AM_ERR_UPD_AMT);


        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = G_RET_STS_ERROR);
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = G_RET_STS_ERROR);
        END IF;

        -- We need to pro-rate the payment amount of top service
        -- or fee line having Sub lines
        FOR r_sls_rule_pymnt_csr IN l_sls_rule_pymnt_csr(
                                                  p_chr_id => l_chr_id,
                                                  p_cle_id => nx_clev_rec.id,
                                                  p_sts_code => p_status) LOOP

          IF lt_old_sls_amt.COUNT > 0 THEN
            j := lt_old_sls_amt.FIRST;
            LOOP
              IF lt_old_sls_amt(j).cle_id = nx_clev_rec.id THEN
                ln_old_amount := lt_old_sls_amt(j).amount;
                EXIT WHEN (lt_old_sls_amt(j).cle_id = nx_clev_rec.id);
              END IF;
              EXIT WHEN (j = lt_old_sls_amt.LAST);
              j := lt_old_sls_amt.NEXT(j);
            END LOOP;
          END IF;

          IF (ln_old_amount IS NOT NULL OR
             ln_old_amount <> G_MISS_NUM) AND
             (ln_new_amount IS NOT NULL OR
             ln_new_amount <> G_MISS_NUM) THEN
             IF ln_old_amount <> 0 THEN
               ln_sls_payment_amount := r_sls_rule_pymnt_csr.payment_amount *
                                        ln_new_amount/ln_old_amount;
               r_rulv_rec.rule_information6 := round(ln_sls_payment_amount,2);
             END IF;
          END IF;

          r_rulv_rec.id := r_sls_rule_pymnt_csr.id;

          OKL_RULE_PUB.update_rule(
                       p_api_version   => p_api_version,
                       p_init_msg_list => G_FALSE,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_rulv_rec      => r_rulv_rec,
                       x_rulv_rec      => rx_rulv_rec);


          IF x_return_status <> G_RET_STS_SUCCESS THEN

              -- Error in updating payment amounts of service and fee lines.
              OKL_API.set_message(
                          p_app_name      => G_APP_NAME,
                          p_msg_name      => G_AM_ERR_UPD_PAY_AMT);

          END IF;



          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = G_RET_STS_ERROR);
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = G_RET_STS_ERROR);
          END IF;

        END LOOP;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = G_RET_STS_ERROR);
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = G_RET_STS_ERROR);
        END IF;

      END LOOP;

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      */

      --  END IF; --29-JUL-04 SECHAWLA 3798158

      -- RMUNJULU -- 04-DEC-02 Bug # 2484327-- Set the x_msg_tbl
      x_msg_tbl := lt_msg_tbl;
      -- BAKUCHIB 28-MAR-03 2877278 Set new klev_tbl which has the top service and fee
      -- lines which too needs to be terminated to x_klev_tbl
      x_klev_tbl := lx_klev_tbl;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         IF l_trmnt_line_csr%ISOPEN
         THEN
            CLOSE l_trmnt_line_csr;
         END IF;

         IF l_chk_other_line_csr%ISOPEN
         THEN
            CLOSE l_chk_other_line_csr;
         END IF;

         IF l_get_sls_csr%ISOPEN
         THEN
            CLOSE l_get_sls_csr;
         END IF;

         IF l_scan_sls_csr%ISOPEN
         THEN
            CLOSE l_scan_sls_csr;
         END IF;

         IF l_new_sls_amt_csr%ISOPEN
         THEN
            CLOSE l_new_sls_amt_csr;
         END IF;

         IF l_old_sls_amt_csr%ISOPEN
         THEN
            CLOSE l_old_sls_amt_csr;
         END IF;

         IF l_sls_rule_pymnt_csr%ISOPEN
         THEN
            CLOSE l_sls_rule_pymnt_csr;
         END IF;

         IF l_item_line_csr%ISOPEN
         THEN
            CLOSE l_item_line_csr;
         END IF;

         IF l_service_line_csr%ISOPEN
         THEN
            CLOSE l_service_line_csr;
         END IF;

         IF l_fee_line_csr%ISOPEN
         THEN
            CLOSE l_fee_line_csr;
         END IF;

         IF l_usage_line_csr%ISOPEN
         THEN
            CLOSE l_usage_line_csr;
         END IF;

         -- RMUNJULU Bug # 2484327 added code to rollback to savepoint and set
         -- return status
         ROLLBACK TO update_lines;
         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         IF l_trmnt_line_csr%ISOPEN
         THEN
            CLOSE l_trmnt_line_csr;
         END IF;

         IF l_chk_other_line_csr%ISOPEN
         THEN
            CLOSE l_chk_other_line_csr;
         END IF;

         IF l_get_sls_csr%ISOPEN
         THEN
            CLOSE l_get_sls_csr;
         END IF;

         IF l_scan_sls_csr%ISOPEN
         THEN
            CLOSE l_scan_sls_csr;
         END IF;

         IF l_new_sls_amt_csr%ISOPEN
         THEN
            CLOSE l_new_sls_amt_csr;
         END IF;

         IF l_old_sls_amt_csr%ISOPEN
         THEN
            CLOSE l_old_sls_amt_csr;
         END IF;

         IF l_sls_rule_pymnt_csr%ISOPEN
         THEN
            CLOSE l_sls_rule_pymnt_csr;
         END IF;

         IF l_item_line_csr%ISOPEN
         THEN
            CLOSE l_item_line_csr;
         END IF;

         IF l_service_line_csr%ISOPEN
         THEN
            CLOSE l_service_line_csr;
         END IF;

         IF l_fee_line_csr%ISOPEN
         THEN
            CLOSE l_fee_line_csr;
         END IF;

         IF l_usage_line_csr%ISOPEN
         THEN
            CLOSE l_usage_line_csr;
         END IF;

         -- RMUNJULU Bug # 2484327 added code to rollback to savepoint and set
         -- return status
         ROLLBACK TO update_lines;
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         IF l_trmnt_line_csr%ISOPEN
         THEN
            CLOSE l_trmnt_line_csr;
         END IF;

         IF l_chk_other_line_csr%ISOPEN
         THEN
            CLOSE l_chk_other_line_csr;
         END IF;

         IF l_get_sls_csr%ISOPEN
         THEN
            CLOSE l_get_sls_csr;
         END IF;

         IF l_scan_sls_csr%ISOPEN
         THEN
            CLOSE l_scan_sls_csr;
         END IF;

         IF l_new_sls_amt_csr%ISOPEN
         THEN
            CLOSE l_new_sls_amt_csr;
         END IF;

         IF l_old_sls_amt_csr%ISOPEN
         THEN
            CLOSE l_old_sls_amt_csr;
         END IF;

         IF l_sls_rule_pymnt_csr%ISOPEN
         THEN
            CLOSE l_sls_rule_pymnt_csr;
         END IF;

         IF l_item_line_csr%ISOPEN
         THEN
            CLOSE l_item_line_csr;
         END IF;

         IF l_service_line_csr%ISOPEN
         THEN
            CLOSE l_service_line_csr;
         END IF;

         IF l_fee_line_csr%ISOPEN
         THEN
            CLOSE l_fee_line_csr;
         END IF;

         IF l_usage_line_csr%ISOPEN
         THEN
            CLOSE l_usage_line_csr;
         END IF;

         -- RMUNJULU Bug # 2484327 added code to rollback to savepoint and set
         -- return status
         ROLLBACK TO update_lines;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END update_lines;

   -- Start of comments
   --
   -- Procedure Name : update_contract
   -- Desciption     : Will terminate the contract if all lines terminated
   -- Business Rules :
   -- Parameters   :
   -- Version    : 1.0
   -- History        : RMUNJULU 04-DEC-02 Bug # 2484327 Procedure Created
   --                : RMUNJULU 18-FEB-03 2805703 Changed logic to terminate
   --                  any hanging lines for the contract before terminating the
   --                  contract
   --                : RMUNJULU 03-MAR-03 2830997 Fixed the exception block
   --                : rmunjulu EDAT Added code to get effective dates and set
   --                  termination date accordingly.
   --
   -- End of comments
   PROCEDURE update_contract (
      p_api_version       IN              NUMBER,
      p_init_msg_list     IN              VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_status            IN              VARCHAR2,
      p_trn_reason_code   IN              VARCHAR2,
      px_msg_tbl          IN OUT NOCOPY   g_msg_tbl
   )
   IS
      -- Get the contract details
      CURSOR get_k_dtls_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT khr.object_version_number object_version_number,
                khr.sts_code sts_code,
                khr.authoring_org_id authoring_org_id
                                      --CDUBEY authoring_org_id added for MOAC
           FROM okc_k_headers_v khr
          WHERE khr.ID = p_khr_id;

      -- Cursor to get the ste code
      CURSOR get_old_ste_code_csr (
         p_sts_code   VARCHAR2
      )
      IS
         SELECT stv.ste_code ste_code
           FROM okc_statuses_v stv
          WHERE stv.code = p_sts_code;

      -- Cursor to get the meaning of the sts_code passed
      CURSOR get_sts_meaning_csr (
         p_sts_code   IN   VARCHAR2
      )
      IS
         SELECT stv.meaning meaning
           FROM okc_statuses_v stv
          WHERE stv.code = p_sts_code;

      -- RMUNJULU 18-FEB-03 2805703 cursor to get active
      -- service or fee lines attached to contract directly
      CURSOR get_k_serv_fee_lines_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT kle.ID ID
           FROM okc_k_lines_v kle,
                okc_k_headers_v khr
          WHERE kle.dnz_chr_id = p_khr_id
            AND kle.sts_code = khr.sts_code
            AND kle.chr_id = khr.ID;

      l_return_status          VARCHAR2 (1)               := g_ret_sts_success;
      l_api_name      CONSTANT VARCHAR2 (30)              := 'update_contract';
      l_api_version   CONSTANT NUMBER                              := 1;
      l_id                     NUMBER                              := -9999;
      get_k_dtls_rec           get_k_dtls_csr%ROWTYPE;
      l_ste_code               okc_statuses_v.code%TYPE;
      lp_chrv_rec              okc_contract_pub.chrv_rec_type;
      lx_chrv_rec              okc_contract_pub.chrv_rec_type;
      l_sts_meaning            VARCHAR2 (300);
      l_msg_tbl                g_msg_tbl                         := px_msg_tbl;
      l_count                  NUMBER;
      l_module_name            VARCHAR2 (500)
                                         := g_module_name || 'update_contract';
      is_debug_exception_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      -- RMUNJULU 18-FEB-03 2805703  Added variables
      l_clev_rec               okl_okc_migration_pvt.clev_rec_type;
      l_klev_rec               okl_contract_pub.klev_rec_type;
      lx_clev_rec              okl_okc_migration_pvt.clev_rec_type;
      lx_klev_rec              okl_contract_pub.klev_rec_type;
      -- rmunjulu EDAT
      l_quote_accpt_date       DATE;
      l_quote_eff_date         DATE;
      l_authoring_org_id       NUMBER;
                                    --CDUBEY l_authoring_org_id added for MOAC
   BEGIN
      -- Start a savepoint to rollback to if error
      SAVEPOINT update_contract;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_status: ' || p_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_reason_code: '
                                  || p_trn_reason_code
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );
         okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                   'In param, p_term_rec.p_termination_date: '
                                || p_term_rec.p_termination_date
                               );
      END IF;

      -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

      -- rmunjulu EDAT
      -- If quote exists then accnting date is quote accept date else sysdate
      IF NVL (okl_am_lease_loan_trmnt_pvt.g_quote_exists, 'N') = 'Y'
      THEN
         l_quote_accpt_date :=
                              okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
         l_quote_eff_date :=
                            okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;
      ELSE
         l_quote_accpt_date := p_sys_date;
         l_quote_eff_date := p_sys_date;
      END IF;

      -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

      -- RMUNJULU 18-FEB-03 2805703 terminate the active service and fee lines
      FOR get_k_serv_fee_lines_rec IN
         get_k_serv_fee_lines_csr (p_term_rec.p_contract_id)
      LOOP
         l_klev_rec.ID := get_k_serv_fee_lines_rec.ID;
         l_clev_rec.ID := get_k_serv_fee_lines_rec.ID;
         l_clev_rec.date_terminated := l_quote_eff_date;     -- rmunjulu EDAT
         l_clev_rec.sts_code := p_status;
         l_clev_rec.trn_code := p_trn_reason_code;

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                              'calling OKL_CONTRACT_PUB.update_contract_line'
                             );
         END IF;

         okl_contract_pub.update_contract_line
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => g_false,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_clev_rec           => l_clev_rec,
                                           p_klev_rec           => l_klev_rec,
                                           x_clev_rec           => lx_clev_rec,
                                           x_klev_rec           => lx_klev_rec
                                          );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_CONTRACT_PUB.update_contract_line , return status: '
                || x_return_status
               );
         END IF;

         IF l_return_status <> g_ret_sts_success
         THEN
            -- Contract line table update failed.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_ERR_K_LINE_UPD');
         END IF;

         -- Raise exception to rollback to savepoint
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;
      END LOOP;

      -- Get the contract details
      OPEN get_k_dtls_csr (p_term_rec.p_contract_id);

      FETCH get_k_dtls_csr
       INTO get_k_dtls_rec;

      CLOSE get_k_dtls_csr;

      -- Get the ste_code
      OPEN get_old_ste_code_csr (get_k_dtls_rec.sts_code);

      FETCH get_old_ste_code_csr
       INTO l_ste_code;

      CLOSE get_old_ste_code_csr;

      -- Get the sts meaning
      OPEN get_sts_meaning_csr (p_status);

      FETCH get_sts_meaning_csr
       INTO l_sts_meaning;

      CLOSE get_sts_meaning_csr;

      -- set the lp_chrv_rec record
      IF     (p_term_rec.p_termination_date IS NOT NULL)
         AND (p_term_rec.p_termination_date <> okl_api.g_miss_date)
      THEN
         lp_chrv_rec.date_terminated := p_term_rec.p_termination_date;
      ELSE
         lp_chrv_rec.date_terminated := l_quote_eff_date;    -- rmunjulu EDAT
      END IF;

      lp_chrv_rec.ID := p_term_rec.p_contract_id;
      lp_chrv_rec.object_version_number :=
                                          get_k_dtls_rec.object_version_number;
      lp_chrv_rec.sts_code := p_status;
      lp_chrv_rec.old_sts_code := get_k_dtls_rec.sts_code;
      lp_chrv_rec.new_sts_code := p_status;
      lp_chrv_rec.old_ste_code := l_ste_code;
      lp_chrv_rec.new_ste_code := p_status;
      lp_chrv_rec.trn_code := p_trn_reason_code;
      lp_chrv_rec.org_id := l_authoring_org_id;        --CDUBEY added for MOAC

      -- Call the okl api to update contract with termination info
      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                            'calling OKC_CONTRACT_PUB.update_contract_header'
                           );
      END IF;

      okc_contract_pub.update_contract_header
                                          (p_api_version            => p_api_version,
                                           p_init_msg_list          => g_false,
                                           x_return_status          => l_return_status,
                                           x_msg_count              => x_msg_count,
                                           x_msg_data               => x_msg_data,
                                           p_restricted_update      => g_true,
                                           p_chrv_rec               => lp_chrv_rec,
                                           x_chrv_rec               => lx_chrv_rec
                                          );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
            (g_level_statement,
             l_module_name,
                'called OKC_CONTRACT_PUB.update_contract_header , return status: '
             || l_return_status
            );
      END IF;

      IF l_return_status <> g_ret_sts_success
      THEN
         -- Error updating contract CONTRACT_NUMBER to status STATUS.
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_AM_K_STATUS_UPD_ERR',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number,
                              p_token2            => 'STATUS',
                              p_token2_value      => l_sts_meaning
                             );
      ELSE
         l_count := l_msg_tbl.COUNT;
         -- Set the success message in the message table
         l_msg_tbl (l_count).msg_desc := g_am_k_status_upd;
         l_msg_tbl (l_count).msg_token1 := 'CONTRACT_NUMBER';
         l_msg_tbl (l_count).msg_token1_value := p_term_rec.p_contract_number;
         l_msg_tbl (l_count).msg_token2 := 'STATUS';
         l_msg_tbl (l_count).msg_token2_value := l_sts_meaning;
      END IF;

      -- Raise exception to rollback to savepoint
      IF (l_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- Set the return status and message table
      x_return_status := l_return_status;
      px_msg_tbl := l_msg_tbl;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF get_k_dtls_csr%ISOPEN
         THEN
            CLOSE get_k_dtls_csr;
         END IF;

         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF get_old_ste_code_csr%ISOPEN
         THEN
            CLOSE get_old_ste_code_csr;
         END IF;

         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF get_sts_meaning_csr%ISOPEN
         THEN
            CLOSE get_sts_meaning_csr;
         END IF;

         ROLLBACK TO update_contract;
         x_return_status := g_ret_sts_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF get_k_dtls_csr%ISOPEN
         THEN
            CLOSE get_k_dtls_csr;
         END IF;

         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF get_old_ste_code_csr%ISOPEN
         THEN
            CLOSE get_old_ste_code_csr;
         END IF;

         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF get_sts_meaning_csr%ISOPEN
         THEN
            CLOSE get_sts_meaning_csr;
         END IF;

         ROLLBACK TO update_contract;
         x_return_status := g_ret_sts_unexp_error;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF get_k_dtls_csr%ISOPEN
         THEN
            CLOSE get_k_dtls_csr;
         END IF;

         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF get_old_ste_code_csr%ISOPEN
         THEN
            CLOSE get_old_ste_code_csr;
         END IF;

         -- RMUNJULU 03-MAR-03 2830997 Changed NOTFOUND to ISOPEN
         IF get_sts_meaning_csr%ISOPEN
         THEN
            CLOSE get_sts_meaning_csr;
         END IF;

         ROLLBACK TO update_contract;
         x_return_status := g_ret_sts_unexp_error;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END update_contract;

   -- Start of comments
   --
   -- Procedure Name : terminate_lines
   -- Desciption     : Terminate the lines
   -- Business Rules :
   -- Parameters   :
   -- Version      : 1.0
   -- History        : RMUNJULU 04-DEC-02 Bug # 2484327
   --                  Added call to update_contract and code to set messages on
   --                  message stack from message table
   --                  Changed logic to do mass_rebook only when BOOKED or
   --                  EVERGREEN lines found
   --                : RMUNJULU 16-DEC-02 Bug # 2484327, changed cursor to get lines
   --                  which are of the same status as header
   --                : RMUNJULU 20-DEC-02 2484327 Added call to cancel_insu procedure
   --                  when no more lines and moved cancel_activate_insu when
   --                  some lines exist
   --                : RMUNJULU 03-JAN-03 2683876 Added call to close_balances
   --                  when no more lines
   --                : RMUNJULU 20-DEC-02 2683876 Set the trn if cancel insurance
   --                  and close balances successful
   --                : RMUNJULU 09-JAN-03 2743604 Added call to reverse loss provisions
   --                : RMUNJULU 18-FEB-03 2805703 Changed cursor to get asset lines
   --                : RMUNJULU 14-MAR-03 2852933 Removed call to cancel activate since is
   --                  now done in Mass Rebook
   --                : RMUNJULU 28-MAR-03 2877278 Added code to call close_streams here
   --                  and changed call to update lines
   --                : RMUNJULU CONTRACT BLOCKING : CHANGED CODE FOR DOING MASS_REBOOK
   --                  MULTIPLE TIMES WHEN IT FAILS
   --                : RMUNJULU CONTRACT BLOCKING (2) Changed to update termination trn
   --                  before mass rebook and update trn after mass rebook properly
   --                : RMUNJULU 3485854 12-MAR-04 Added code to update trn to PROCESSED if Mass rebook
   --                  was not needed, which will be in case of EVERGREEN partial termination
   --                : RMUNJULU 3816891 FORWARDPORT Removed close_streams from central processing
   --                  as rebook does historization
   --                : rmunjulu EDAT called mass_rebook with p_sys_date
   -- End of comments
   PROCEDURE terminate_lines (
      p_api_version       IN              NUMBER,
      p_init_msg_list     IN              VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2,
      px_overall_status   IN OUT NOCOPY   VARCHAR2,
      p_trn_already_set   IN              VARCHAR2,
                                                 -- RMUNJULU CONTRACT BLOCKING
      p_term_rec          IN              term_rec_type,
      p_sys_date          IN              DATE,
      p_klev_tbl          IN              klev_tbl_type,
      p_status            IN              VARCHAR2,
      px_tcnv_rec         IN OUT NOCOPY   tcnv_rec_type
   )
   IS
      -- RMUNJULU Bug # 2484327, added this cursor
      -- RMUNJULU 16-DEC-02 Bug # 2484327, get lines which are of the same status as header
      -- RMUNJULU 18-FEB-03 2805703 Added code to get only financial asset lines
      CURSOR get_k_lines_csr (
         p_khr_id   IN   NUMBER
      )
      IS
         SELECT kle.ID ID
           FROM okc_k_lines_v kle,
                okc_k_headers_v khr,
                okc_line_styles_v lse
          WHERE kle.dnz_chr_id = p_khr_id
            AND kle.dnz_chr_id = khr.ID
            AND kle.sts_code = khr.sts_code
            AND kle.lse_id = lse.ID
            AND lse.lty_code = g_fin_line_lty_code;

      -- RMUNJULU 3485854 12-MAR-04
      -- get the trn status
      CURSOR get_trn_status_csr (
         p_tcn_id   IN   NUMBER
      )
      IS
         SELECT tcn.tmt_status_code    -- akrangan sla tmt_status_code changes
           FROM okl_trx_contracts tcn
          WHERE tcn.ID = p_tcn_id;

      l_return_status          VARCHAR2 (1)   := g_ret_sts_success;
      l_module_name            VARCHAR2 (500)
                                         := g_module_name || 'terminate_lines';
      is_debug_exception_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      -- RMUNJULU Bug # 2484327 Added these variables
      l_msg_tbl                g_msg_tbl;
      k                        NUMBER;
      l_id                     NUMBER         := -9999;
      lx_klev_tbl              klev_tbl_type;
      -- RMUNJULU CONTRACT BLOCKING ADDED VARIABLE
      lx_mass_rebook_success   VARCHAR2 (3)   := g_ret_sts_success;
      -- CONTRACT BLOCKING (2)
      lx_id                    NUMBER;
   BEGIN
      -- LOGIC START
      -- Update Lines
      -- Close Streams
      -- If any more active lines then
      -- Mass Rebook
      -- Cancel Activate Insurance
      -- Else -- no more active lines
      -- Close Balances
      -- Update Contract
      -- reverse loss provisions
      -- Cancel Insurances
      -- End if
      -- Set Success msgs to msg stack
      -- LOGIC END

      -- Create a savepoint
      SAVEPOINT terminate_lines;

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_sys_date: ' || p_sys_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_status: ' || p_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_trn_already_set: '
                                  || p_trn_already_set
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_overall_status: '
                                  || px_overall_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                            (g_level_statement,
                             l_module_name,
                                'In param, px_tcnv_rec.tmt_generic_flag2_yn: '
                             || px_tcnv_rec.tmt_generic_flag2_yn
                            );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_tcnv_rec.trn_code: '
                                  || px_tcnv_rec.trn_code
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, px_tcnv_rec.id: '
                                  || px_tcnv_rec.ID
                                 );

         IF p_klev_tbl.COUNT > 0
         THEN
            FOR i IN p_klev_tbl.FIRST .. p_klev_tbl.LAST
            LOOP
               IF (p_klev_tbl.EXISTS (i))
               THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_kle_id: '
                                           || p_klev_tbl (i).p_kle_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_quantity: '
                                           || p_klev_tbl (i).p_asset_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_asset_name: '
                                           || p_klev_tbl (i).p_asset_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_quote_quantity: '
                                           || p_klev_tbl (i).p_quote_quantity
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_tql_id: '
                                           || p_klev_tbl (i).p_tql_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_split_kle_name: '
                                           || p_klev_tbl (i).p_split_kle_name
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_klev_tbl('
                                           || i
                                           || ').p_split_kle_id: '
                                           || p_klev_tbl (i).p_split_kle_id
                                          );
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- RMUNJULU CONTRACT BLOCKING
      -- Added code to check that generic_flag2 which is now used to check
      -- if update_lines and close_streams was done earlier or not is checked
      -- since we now can recycle if only mass_rebook fails and in that condition
      -- we do mass_rebook only

      -- Check if Update_Lines and Close Streams required
      IF    (    p_trn_already_set = g_yes
             AND NVL (px_tcnv_rec.tmt_generic_flag2_yn, '?') <> g_yes
            )
         OR (p_trn_already_set = g_no)
      THEN
         -- Call the Update Lines to update the lines to terminated
         -- BAKUCHIB 28-MAR-03 2877278 Added parameter to call
         update_lines
               (p_api_version          => p_api_version,
                p_init_msg_list        => g_false,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                x_return_status        => l_return_status,
                p_term_rec             => p_term_rec,
                p_sys_date             => p_sys_date,
                p_klev_tbl             => p_klev_tbl,
                p_status               => p_status,
                p_trn_reason_code      => px_tcnv_rec.trn_code,
                x_klev_tbl             => lx_klev_tbl,
                                           -- BAKUCHIB 28-MAR-03 2877278 Added
                x_msg_tbl              => l_msg_tbl
               );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                                  (g_level_statement,
                                   l_module_name,
                                      'called update_lines , return status: '
                                   || l_return_status
                                  );
         END IF;

         -- RMUNJULU CONTRACT BLOCKING -- Moved this if from exception
         IF l_return_status <> g_ret_sts_success
         THEN
            -- Contract line table update failed.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_ERR_K_LINE_UPD');
         END IF;

         -- rollback if update lines failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- BAKUCHIB 28-MAR-03 2877278 Added call to close streams here
         -- close streams

         /* -- RMUNJULU 3816891 FORWARDPORT Do not historize streams as rebook will do it

           close_streams(
             p_term_rec           => p_term_rec,
             p_sys_date           => p_sys_date,
             p_klev_tbl           => lx_klev_tbl,
             p_trn_already_set    => G_NO,
             px_overall_status    => px_overall_status,
             px_tcnv_rec          => px_tcnv_rec,
             x_return_status      => l_return_status);

           -- RMUNJULU CONTRACT BLOCKING -- Moved this if from exception
           IF l_return_status <> G_RET_STS_SUCCESS THEN

              -- Contract line table update failed.
              OKL_API.set_message(
                          p_app_name => G_APP_NAME,
                          p_msg_name => 'OKL_AM_ERR_K_LINE_UPD');

           END IF;

           -- rollback if close streams failed
           IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         */

         -- RMUNJULU CONTRACT BLOCKING
         -- set the transaction record for new flag being maintained
         set_transaction_rec (p_return_status       => l_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_GENERIC_FLAG2_YN',
                              p_tsu_code            => 'WORKING',
                              px_tcnv_rec           => px_tcnv_rec
                             );
      END IF;                        -- RMUNJULU CONTRACT BLOCKING - END OF IF

      -- RMUNJULU Bug # 2484327
      -- Get any assets which are in BOOKED or EVERGREEN status
      OPEN get_k_lines_csr (p_term_rec.p_contract_id);

      FETCH get_k_lines_csr
       INTO l_id;

      -- RMUNJULU 18-FEB-03 2805703 Added If to set l_id
      IF get_k_lines_csr%NOTFOUND
      THEN
         l_id := -9999;
      END IF;

      CLOSE get_k_lines_csr;

      -- RMUNJULU Bug # 2484327 -- Added this IF
      -- If any BOOKED or EVERGREEN lines then do mass_rebook
      -- else do update_contract
      -- RMUNJULU 18-FEB-03 2805703 Changed IF condition for better check
      IF l_id <> -9999
      THEN
         --+++++++++++++++start -- CONTRACT BLOCKING (2)
         -- Update the transaction before mass rebook, since will be updated again by mass rebook
         -- update the transaction record
         process_transaction (p_id                 => 0,
                              p_term_rec           => p_term_rec,
                              p_tcnv_rec           => px_tcnv_rec,
                              p_trn_mode           => 'UPDATE',
                              x_id                 => lx_id,
                              x_return_status      => l_return_status
                             );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
         END IF;

         -- rollback if processing transaction failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         --+++++++++++++++end -- CONTRACT BLOCKING (2)

         -- Call the Mass Rebook to rebook the contract lines
         mass_rebook (p_api_version        => p_api_version,
                      p_init_msg_list      => g_false,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      x_return_status      => l_return_status,
                      p_term_rec           => p_term_rec,
                      p_tcnv_rec           => px_tcnv_rec,
                      p_sys_date           => p_sys_date,     -- rmunjulu EDAT
                      x_mrbk_success       => lx_mass_rebook_success
                     );                    -- RMUNJULU CONTRACT BLOCKING ADDED

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                                   (g_level_statement,
                                    l_module_name,
                                       'called mass_rebook , return status: '
                                    || l_return_status
                                   );
         END IF;
      ELSE
         -- No more active lines

         -- RMUNJULU 03-JAN-03 2683876 Added call to this procedure
         -- Call the Close Balances to close the remaining balances
         close_balances (p_api_version        => p_api_version,
                         p_init_msg_list      => g_false,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         x_return_status      => l_return_status,
                         p_term_rec           => p_term_rec,
                         p_sys_date           => p_sys_date,
                         p_tcnv_rec           => px_tcnv_rec,
                         px_msg_tbl           => l_msg_tbl
                        );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'called close_balances , return status: '
                                 || l_return_status
                                );
         END IF;

         -- RMUNJULU CONTRACT BLOCKING -- Moved this if from exception
         IF l_return_status <> g_ret_sts_success
         THEN
            -- Contract line table update failed.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_ERR_K_LINE_UPD');
         END IF;

         -- rollback if close balances failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- RMUNJULU 09-JAN-03 2743604 Added call to this procedure
         -- Call to Reverse the non-incomes and loss-provisions
         reverse_loss_provisions (p_api_version        => p_api_version,
                                  p_init_msg_list      => g_false,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  x_return_status      => l_return_status,
                                  p_term_rec           => p_term_rec,
                                  p_sys_date           => p_sys_date,
                                  px_msg_tbl           => l_msg_tbl
                                 );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                       (g_level_statement,
                        l_module_name,
                           'called reverse_loss_provisions , return status: '
                        || l_return_status
                       );
         END IF;

         -- RMUNJULU CONTRACT BLOCKING -- Moved this if from exception
         IF l_return_status <> g_ret_sts_success
         THEN
            -- Contract line table update failed.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_ERR_K_LINE_UPD');
         END IF;

         -- rollback if reverse loss provisions failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- RMUNJULU Bug # 2484327 Added call to this procedure
         -- Call the Update Lines to update the contract to terminated if
         -- all lines of the contract are terminated
         update_contract (p_api_version          => p_api_version,
                          p_init_msg_list        => g_false,
                          x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                          x_return_status        => l_return_status,
                          p_term_rec             => p_term_rec,
                          p_sys_date             => p_sys_date,
                          p_status               => p_status,
                          p_trn_reason_code      => px_tcnv_rec.trn_code,
                          px_msg_tbl             => l_msg_tbl
                         );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                   'called update_contract , return status: '
                                || l_return_status
                               );
         END IF;

         -- RMUNJULU CONTRACT BLOCKING -- Moved this if from exception
         IF l_return_status <> g_ret_sts_success
         THEN
            -- Contract line table update failed.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_ERR_K_LINE_UPD');
         END IF;

         -- rollback if update contract failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- RMUNJULU 20-DEC-02 2484327 Added call to this procedure
         -- Call to Cancel Insurance to cancel the insurances
         cancel_insurance (p_api_version        => p_api_version,
                           p_init_msg_list      => g_false,
                           x_msg_count          => x_msg_count,
                           x_msg_data           => x_msg_data,
                           x_return_status      => l_return_status,
                           p_term_rec           => p_term_rec,
                           p_sys_date           => p_sys_date,
                           p_klev_tbl           => p_klev_tbl
                          );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                              (g_level_statement,
                               l_module_name,
                                  'called cancel_insurance , return status: '
                               || l_return_status
                              );
         END IF;

         -- RMUNJULU CONTRACT BLOCKING -- Moved this if from exception
         IF l_return_status <> g_ret_sts_success
         THEN
            -- Contract line table update failed.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_ERR_K_LINE_UPD');
         END IF;

         -- rollback if cancel insurance failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- RMUNJULU 20-DEC-02 2683876 Set the trn if close balances successful
         -- set the transaction record
         set_transaction_rec (p_return_status       => l_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_CLOSE_BALANCES_YN',
                              p_tsu_code            => 'WORKING',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- RMUNJULU 20-DEC-02 2683876 Set the trn if cancel insurance successful
         -- set the transaction record
         set_transaction_rec (p_return_status       => l_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_CANCEL_INSURANCE_YN',
                              p_tsu_code            => 'WORKING',
                              px_tcnv_rec           => px_tcnv_rec
                             );
      END IF;

      -- RMUNJULU Bug # 2484327. Added code to set the message stack
      -- Set all the success messages to message stack
      IF l_return_status = g_ret_sts_success AND l_msg_tbl.COUNT > 0
      THEN
         k := l_msg_tbl.FIRST;

         LOOP
            okl_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => l_msg_tbl (k).msg_desc,
                             p_token1            => l_msg_tbl (k).msg_token1,
                             p_token1_value      => l_msg_tbl (k).msg_token1_value,
                             p_token2            => l_msg_tbl (k).msg_token2,
                             p_token2_value      => l_msg_tbl (k).msg_token2_value
                            );
            EXIT WHEN (k = l_msg_tbl.LAST);
            k := l_msg_tbl.NEXT (k);
         END LOOP;
      END IF;

      -- RMUNJULU CONTRACT BLOCKING : Now since update_lines can succeed and mass_rebook can hang
      -- Need to set TMT_CONTRACT_UPDATED_YN to 'E' if mass_rebook hangs so that it can be
      -- recycled again
      -- Remember : lx_mass_rebook_success will be 'S' if Mass_Rebook was not called
      -- Also : lx_mass_rebook_success will be 'E' if Mass_Rebook RBK TRN NOT PROCESSED
      --        or IF Mass_Rebook failed and it in that case it would have done rollback
      IF l_id <> -9999
      THEN
         -- When Mass Rebook was called
         --++++++++start -- CONTRACT BLOCKING (2)
         -- If Mass Rebook failed, It did not touch termination trn, so has to update term trn
         IF l_return_status <> g_ret_sts_success
         THEN
            set_transaction_rec (p_return_status       => l_return_status,
                                 p_overall_status      => px_overall_status,
                                 p_tmt_flag            => 'TMT_CONTRACT_UPDATED_YN',
                                 p_tsu_code            => 'ERROR',
                                 px_tcnv_rec           => px_tcnv_rec
                                );
            -- update the transaction record
            process_transaction (p_id                 => 0,
                                 p_term_rec           => p_term_rec,
                                 p_tcnv_rec           => px_tcnv_rec,
                                 p_trn_mode           => 'UPDATE',
                                 x_id                 => lx_id,
                                 x_return_status      => l_return_status
                                );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
            END IF;

            -- rollback if processing transaction failed
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;
         ELSE
            -- Mass Rebook Till Streams was successful

            -- Whole mass rebook was successful, Mass Rebook will have updated the termination trn
            IF lx_mass_rebook_success = g_ret_sts_success
            THEN
               NULL;      --Mass Rebook will have updated the termination trn

               -- RMUNJULU 3485854 12-MAR-04
               -- get trn tsu_code, if not updated then we update here
               -- used when EVERGREEN and partial termination
               FOR get_trn_status_rec IN get_trn_status_csr (px_tcnv_rec.ID)
               LOOP
                  IF get_trn_status_rec.tmt_status_code <> 'PROCESSED'
                  THEN
                     set_transaction_rec
                                    (p_return_status       => l_return_status,
                                     p_overall_status      => px_overall_status,
                                     p_tmt_flag            => 'TMT_CONTRACT_UPDATED_YN',
                                     p_tsu_code            => 'PROCESSED',
                                     px_tcnv_rec           => px_tcnv_rec
                                    );
                     -- update the transaction record
                     process_transaction (p_id                 => 0,
                                          p_term_rec           => p_term_rec,
                                          p_tcnv_rec           => px_tcnv_rec,
                                          p_trn_mode           => 'UPDATE',
                                          x_id                 => lx_id,
                                          x_return_status      => l_return_status
                                         );

                     IF (is_debug_statement_on)
                     THEN
                        okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
                     END IF;

                     -- rollback if processing transaction failed
                     IF (l_return_status = g_ret_sts_unexp_error)
                     THEN
                        RAISE okl_api.g_exception_unexpected_error;
                     ELSIF (l_return_status = g_ret_sts_error)
                     THEN
                        RAISE okl_api.g_exception_error;
                     END IF;
                  END IF;
               END LOOP;
            ELSE
               -- Mass Rebook hanged becos of stream, has not yet updated term trn, so update term trn

               -- Might need to set only tsu_code in this case ***
               -- then l_tcnv_rec.id and l_tcnv_rec.tsu_code should be set
               px_tcnv_rec.tmt_status_code := 'WORKING';
                            -- Since mass rebook hanged set status to WORKING
               -- update the transaction record
               process_transaction (p_id                 => 0,
                                    p_term_rec           => p_term_rec,
                                    p_tcnv_rec           => px_tcnv_rec,
                                    p_trn_mode           => 'UPDATE',
                                    x_id                 => lx_id,
                                    x_return_status      => l_return_status
                                   );

               IF (is_debug_statement_on)
               THEN
                  okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
               END IF;

               -- rollback if processing transaction failed
               IF (l_return_status = g_ret_sts_unexp_error)
               THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (l_return_status = g_ret_sts_error)
               THEN
                  RAISE okl_api.g_exception_error;
               END IF;
            END IF;
         END IF;
      ELSE
         -- When Mass Rebook was not called ie NO MORE ASSETS ie NOT A TRUE PARTIAL TERMINATION

         -- At the point it would have already rolled back if there were an error
         -- so can assume that contract updation went thru successfully
         -- set the transaction record
         set_transaction_rec (p_return_status       => l_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_CONTRACT_UPDATED_YN',
                              p_tsu_code            => 'PROCESSED',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- update the transaction record
         process_transaction (p_id                 => 0,
                              p_term_rec           => p_term_rec,
                              p_tcnv_rec           => px_tcnv_rec,
                              p_trn_mode           => 'UPDATE',
                              x_id                 => lx_id,
                              x_return_status      => l_return_status
                             );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
         END IF;

         -- rollback if processing transaction failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;
      END IF;

      --+++++++++++++end  -- CONTRACT BLOCKING (2)

      -- Set the return status
      x_return_status := l_return_status;
 -- will be 'S' always SHOULD BE OK SINCE THIS IS NOT CONSIDERED GOING FURTHER

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error
      THEN
         -- RMUNJULU Bug # 2484327 Added IF
         IF get_k_lines_csr%ISOPEN
         THEN
            CLOSE get_k_lines_csr;
         END IF;

         ROLLBACK TO terminate_lines;
         x_return_status := g_ret_sts_error;
         -- RMUNJULU CONTRACT BLOCKING -- Moved msg to body above

         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_CONTRACT_UPDATED_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         -- RMUNJULU Bug # 2484327 Added IF
         IF get_k_lines_csr%ISOPEN
         THEN
            CLOSE get_k_lines_csr;
         END IF;

         ROLLBACK TO terminate_lines;
         x_return_status := g_ret_sts_unexp_error;
         -- RMUNJULU CONTRACT BLOCKING -- Moved msg to body above

         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_CONTRACT_UPDATED_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         -- RMUNJULU Bug # 2484327 Added IF
         IF get_k_lines_csr%ISOPEN
         THEN
            CLOSE get_k_lines_csr;
         END IF;

         ROLLBACK TO terminate_lines;
         x_return_status := g_ret_sts_unexp_error;
         -- RMUNJULU CONTRACT BLOCKING -- Moved msg to body above

         -- set the transaction record
         set_transaction_rec (p_return_status       => x_return_status,
                              p_overall_status      => px_overall_status,
                              p_tmt_flag            => 'TMT_CONTRACT_UPDATED_YN',
                              p_tsu_code            => 'ERROR',
                              px_tcnv_rec           => px_tcnv_rec
                             );
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END terminate_lines;

   -- Start of comments
   --
   -- Procedure Name : asset_level_termination
   -- Desciption     : Use this API to terminate lines for
   --                  asset level termination
   -- Business Rules :
   -- Parameters     :
   -- Version        : 1.0
   -- History        : RMUNJULU 20-DEC-02 2484327 Removed validation message
   --                : RMUNJULU 02-JAN-03 2724951 Added code to check lease or loan
   --                  and processing accordingly
   --                : RMUNJULU 07-JAN-03 2736865 Added code to store messages
   --                  and set stack to true
   --                : RMUNJULU 23-JAN-03 2762065 Added code to set msg stack
   --                  before split asset call
   --                : RMUNJULU 31-JAN-03 2780539 Added TER_MAN_PURCHASE check
   --                : RMUNJULU 04-FEB-03 2781557 Added code to set trn to
   --                  WORKING after validation
   --                : RMUNJULU 28-MAR-03 2877278 Removed call to close_streams
   --                  as it moves to Terminate_Lines
   --                : RMUNJULU 3061751  Changed code to create a termination
   --                  trn even when request is NON BATCH and validation has failed
   --                : RMUNJULU 3061751 Changed l_return_status to l_validate in set_trn_rec
   --                  setting the value for tmt_validated_yn properly
   --                : RMUNJULU 2730783 Use OKL_AM_BTCH_EXP_LEASE_LOAN_PVT.POP_ASSET_MSG_TBL
   --                  instead of log_messages to set messages into the POP_ASSET_MSG_TBL
   --                  of OKL_AM_BTCH_EXP_LEASE_LOAN_PVT which will be used in the output
   --                  displayed from concurrent program
   --                : RMUNJULU 3018641 Added code to get and set TMG_RUN on OKL_TRX_MSGS
   --                : RMUNJULU 3018641 Added code to get and set TMG_RUN on OKL_TRX_MSGS  in one more place
   --                : RMUNJULU CONTRACT BLOCKING : CHANGED CALL TO TERMINATE_LINES
   --                  and added condition for validate_k_and_lines
   --                : RMUNJULU CONTRACT BLOCKING (2) Changed to update termination trn
   --                  If Overall status not successful or if mass_rebook was not called
   --                : RMUNJULU CONTRACT BLOCKING (3) -- Added NVLs to Validate condition
   --                : rmunjulu EDAT Added code to get quote eff dates and set them as global
   -- End of comments
   PROCEDURE asset_level_termination (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      p_term_rec        IN              term_rec_type,
      p_tcnv_rec        IN              tcnv_rec_type,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_return_status          VARCHAR2 (1)   := g_ret_sts_success;
      l_overall_status         VARCHAR2 (1)   := g_ret_sts_success;
      lp_tcnv_rec              tcnv_rec_type;
      lp_klev_tbl              klev_tbl_type;
      lx_klev_tbl              klev_tbl_type;
      lx_id                    NUMBER;
      i                        NUMBER         := 1;
      l_tran_started           VARCHAR2 (1)   := g_false;
      l_evergreen_status       VARCHAR2 (1)   := g_false;
      l_api_name               VARCHAR2 (30)  := 'asset_level_termination';
      l_module_name            VARCHAR2 (500)
                                := g_module_name || 'asset_level_termination';
      is_debug_exception_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on    BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
      l_sys_date               DATE;
      l_trn_already_set        VARCHAR2 (1)   := g_no;
      lx_contract_status       VARCHAR2 (200);
      l_validate               VARCHAR2 (1)   := g_ret_sts_error;
      l_api_version   CONSTANT NUMBER         := 1;
      l_status                 VARCHAR2 (200);
      l_term_rec               term_rec_type  := p_term_rec;
      l_lease_or_loan          VARCHAR2 (30);
   BEGIN
      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_contract_id: '
                                  || p_term_rec.p_contract_id
                                 );
         okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || p_term_rec.p_contract_number
                                );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_type: '
                                  || p_term_rec.p_quote_type
                                 );
         okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'In param, p_term_rec.p_early_termination_yn: '
                            || p_term_rec.p_early_termination_yn
                           );
         okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                   'In param, p_term_rec.p_termination_date: '
                                || p_term_rec.p_termination_date
                               );
         okl_debug_pub.log_debug
                             (g_level_statement,
                              l_module_name,
                                 'In param, p_tcnv_rec.tmt_generic_flag2_yn: '
                              || p_tcnv_rec.tmt_generic_flag2_yn
                             );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'In param, p_tcnv_rec.id: ' || p_tcnv_rec.ID
                                 );
         okl_debug_pub.log_debug
                          (g_level_statement,
                           l_module_name,
                              'In param, p_tcnv_rec.tmt_contract_updated_yn: '
                           || p_tcnv_rec.tmt_contract_updated_yn
                          );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_tcnv_rec.tmt_status_code: '
                                  || p_tcnv_rec.tmt_status_code
                                 );
      END IF;

      -- RMUNJULU 23-JAN-03 2762065 -- Added comments to explain msgs manipulation
      -- Issue with msgs and msg stack is resolved the following way
      -- Split asset initializes msg stack so log + process + initialize msgs before
      -- split asset
      -- Mass rebook initializes msg stack so log + process + initialize msgs before
      -- terminate lines
      -- There was a concern of msgs being lost which are set in update lines if mass
      -- rebook is done after it and is sucessful, but that is not a concern since
      -- we are not storing the update lines msgs on stack but in msg_tbl and
      -- putting them on stack only if every step in terminate line is sucessful

      -- Set the transaction
      l_return_status :=
         okl_api.start_activity (l_api_name,
                                 g_pkg_name,
                                 p_init_msg_list,
                                 l_api_version,
                                 p_api_version,
                                 '_PVT',
                                 x_return_status
                                );

      -- Rollback if error setting activity for api
      IF (l_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- store the highest degree of error
      set_overall_status (p_return_status        => l_return_status,
                          px_overall_status      => l_overall_status);
      -- If the termination request is from quote
      -- populate the rest of the quote attributes
      set_database_values (px_term_rec      => l_term_rec);
      -- Set the info messages intially
      set_info_messages (p_term_rec      => l_term_rec);

      -- check if transaction already exists
      IF (p_tcnv_rec.ID IS NOT NULL AND p_tcnv_rec.ID <> g_miss_num)
      THEN
         l_trn_already_set := g_yes;
      END IF;

      --get sysdate
      SELECT SYSDATE
        INTO l_sys_date
        FROM DUAL;

      -- If the transaction is not already set then initialize and insert
      IF l_trn_already_set = g_no
      THEN
         -- initialize the transaction rec
         initialize_transaction (p_term_rec           => l_term_rec,
                                 p_sys_date           => l_sys_date,
                                 p_control_flag       => 'CREATE',
                                 px_tcnv_rec          => lp_tcnv_rec,
                                 x_return_status      => l_return_status
                                );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                            'called initialize_transaction , return status: '
                         || l_return_status
                        );
         END IF;

         -- rollback if intialize transaction failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- insert the transaction record
         process_transaction (p_id                 => 0,
                              p_term_rec           => l_term_rec,
                              p_tcnv_rec           => lp_tcnv_rec,
                              p_trn_mode           => 'INSERT',
                              x_id                 => lx_id,
                              x_return_status      => l_return_status
                             );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
         END IF;

         -- rollback if processing transaction failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- set the trn rec id
         lp_tcnv_rec.ID := lx_id;
      ELSE
         -- transaction already set
         lp_tcnv_rec := p_tcnv_rec;
         -- initialize the transaction rec
         initialize_transaction (p_term_rec           => l_term_rec,
                                 p_sys_date           => l_sys_date,
                                 p_control_flag       => 'UPDATE',
                                 px_tcnv_rec          => lp_tcnv_rec,
                                 x_return_status      => l_return_status
                                );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                            'called initialize_transaction , return status: '
                         || l_return_status
                        );
         END IF;

         -- rollback if intialize transaction failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;
      END IF;

      -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

      -- rmunjulu EDAT Get the quote effectivity date and quote acceptance date
      -- and store as global variables, will be used later on in other procedures
      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                   (g_level_statement,
                    l_module_name,
                    'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_quote_dates'
                   );
      END IF;

      okl_am_lease_loan_trmnt_pvt.get_set_quote_dates
                                           (p_qte_id             => l_term_rec.p_quote_id,
                                            x_return_status      => l_return_status);

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
            (g_level_statement,
             l_module_name,
                'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_quote_dates , return status: '
             || l_return_status
            );
      END IF;

      -- Rollback if error setting activity for api
      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

      -- get the lines
      get_lines (p_term_rec           => l_term_rec,
                 x_klev_tbl           => lp_klev_tbl,
                 x_return_status      => l_return_status
                );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'called get_lines , return status: '
                                  || l_return_status
                                 );
      END IF;

      -- RMUNJULU CONTRACT BLOCKING Do not validate if update_lines done and only mass_rebook pending
      -- RMUNJULU CONTRACT BLOCKING (3) -- Added NVLs
      IF     NVL (lp_tcnv_rec.tmt_contract_updated_yn, 'N') = 'N'
         AND NVL (lp_tcnv_rec.tmt_generic_flag2_yn, 'N') = 'Y'
      THEN
         l_return_status := g_ret_sts_success;
      ELSE
         -- Not a Mass rebook recycle, so do validate

         -- check if lease and lines valid
         validate_contract_and_lines (p_term_rec           => l_term_rec,
                                      p_sys_date           => l_sys_date,
                                      p_klev_tbl           => lp_klev_tbl,
                                      x_return_status      => l_return_status
                                     );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                   (g_level_statement,
                    l_module_name,
                       'called validate_contract_and_lines , return status: '
                    || l_return_status
                   );
         END IF;
      END IF;

      -- Store the validation return status
      l_validate := l_return_status;
      -- store the highest degree of error
      set_overall_status (p_return_status        => l_return_status,
                          px_overall_status      => l_overall_status);

      IF (l_term_rec.p_control_flag = 'BATCH_PROCESS')
      THEN
         -- Since batch process is not checked initially in LLT check here
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'calling OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract'
                     );
         END IF;

         okl_am_lease_loan_trmnt_pub.validate_contract
                                 (p_api_version          => p_api_version,
                                  p_init_msg_list        => g_false,
                                  x_return_status        => l_return_status,
                                  x_msg_count            => x_msg_count,
                                  x_msg_data             => x_msg_data,
                                  p_contract_id          => l_term_rec.p_contract_id,
                                  p_control_flag         => l_term_rec.p_control_flag,
                                  x_contract_status      => lx_contract_status
                                 );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract , return status: '
                || l_return_status
               );
         END IF;

         -- Store the highest validation return status
         -- To capture the return status of validate lease called above
         IF (l_validate = g_ret_sts_success)
         THEN
            l_validate := l_return_status;
         END IF;

         -- store the highest degree of error
         set_overall_status
            (p_return_status        => l_validate,
                              -- RMUNJULU 3061751 Changed from l_return_status
             px_overall_status      => l_overall_status);
         -- set the transaction record
         set_transaction_rec
            (p_return_status       => l_validate,
                              -- RMUNJULU 3061751 Changed from l_return_status
             p_overall_status      => l_overall_status,
             p_tmt_flag            => 'TMT_VALIDATED_YN',
             p_tsu_code            => 'ENTERED',
             px_tcnv_rec           => lp_tcnv_rec
            );

         -- if validation failed then insert transaction
         -- AND abort else continue next process
         IF (l_validate <> g_ret_sts_success)
         THEN
            -- set the transaction record
            set_transaction_rec
               (p_return_status       => l_validate,
                              -- RMUNJULU 3061751 Changed from l_return_status
                p_overall_status      => l_overall_status,
                p_tmt_flag            => 'TMT_VALIDATED_YN',
                p_tsu_code            => 'ERROR',
                px_tcnv_rec           => lp_tcnv_rec
               );
            -- update the transaction record
            process_transaction (p_id                 => 0,
                                 p_term_rec           => l_term_rec,
                                 p_tcnv_rec           => lp_tcnv_rec,
                                 p_trn_mode           => 'UPDATE',
                                 x_id                 => lx_id,
                                 x_return_status      => l_return_status
                                );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
            END IF;

            -- rollback if processing transaction failed
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            -- Save messages from stack into transaction message table
            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                                  (g_level_statement,
                                   l_module_name,
                                   'calling OKL_AM_UTIL_PVT.process_messages'
                                  );
            END IF;

            okl_am_util_pvt.process_messages
                                   (p_trx_source_table      => 'OKL_TRX_CONTRACTS',
                                    p_trx_id                => lp_tcnv_rec.ID,
                                    x_return_status         => l_return_status
                                   );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_AM_UTIL_PVT.process_messages , return status: '
                   || l_return_status
                  );
            END IF;

            -- RMUNJULU 3018641 Added code to get and set TMG_RUN
            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                       (g_level_statement,
                        l_module_name,
                        'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run'
                       );
            END IF;

            okl_am_lease_loan_trmnt_pvt.get_set_tmg_run
                                           (p_trx_id             => lp_tcnv_rec.ID,
                                            x_return_status      => l_return_status);

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run , return status: '
                   || l_return_status
                  );
            END IF;

            -- abort since validation failed
            RAISE g_exception_halt_validation;
         END IF;
      ELSE
         --( not from batch process) then

         -- RMUNJULU 3061751 Changed this code to create a termination trn even when
         -- request is NON BATCH and validation has failed
         IF l_validate <> g_ret_sts_success
         THEN
            -- set the transaction record
            set_transaction_rec
               (p_return_status       => l_validate,
                             -- RMUNJULU 3061751 Changed from l_return_status,
                p_overall_status      => l_overall_status,
                p_tmt_flag            => 'TMT_VALIDATED_YN',
                p_tsu_code            => 'ERROR',
                px_tcnv_rec           => lp_tcnv_rec
               );
            -- update the transaction record
            process_transaction (p_id                 => 0,
                                 p_term_rec           => l_term_rec,
                                 p_tcnv_rec           => lp_tcnv_rec,
                                 p_trn_mode           => 'UPDATE',
                                 x_id                 => lx_id,
                                 x_return_status      => l_return_status
                                );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
            END IF;

            -- rollback if processing transaction failed
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;

            -- Save messages from stack into transaction message table
            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                                  (g_level_statement,
                                   l_module_name,
                                   'calling OKL_AM_UTIL_PVT.process_messages'
                                  );
            END IF;

            okl_am_util_pvt.process_messages
                                   (p_trx_source_table      => 'OKL_TRX_CONTRACTS',
                                    p_trx_id                => lp_tcnv_rec.ID,
                                    x_return_status         => l_return_status
                                   );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_AM_UTIL_PVT.process_messages , return status: '
                   || l_return_status
                  );
            END IF;

            -- RMUNJULU 3018641 Added code to get and set TMG_RUN
            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                       (g_level_statement,
                        l_module_name,
                        'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run'
                       );
            END IF;

            okl_am_lease_loan_trmnt_pvt.get_set_tmg_run
                                           (p_trx_id             => lp_tcnv_rec.ID,
                                            x_return_status      => l_return_status);

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                      'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run , return status: '
                   || l_return_status
                  );
            END IF;

            -- abort since validation failed
            RAISE g_exception_halt_validation;
         ELSE
            -- Validate was successful -- RMUNJULU CONTRACT BLOCKING -- Validate flag was not set properly earlier

            -- set the transaction record
            set_transaction_rec (p_return_status       => l_validate,
                                 p_overall_status      => l_overall_status,
                                 p_tmt_flag            => 'TMT_VALIDATED_YN',
                                 p_tsu_code            => 'ENTERED',
                                 px_tcnv_rec           => lp_tcnv_rec
                                );
         END IF;
      END IF;

      -- RMUNJULU 23-JAN-03 2762065  -- START
      -- Added this code to store msgs in log and tbl since split asset setting the
      -- msg stack again

      -- If batch process then log the messages from stack
      IF p_term_rec.p_control_flag LIKE 'BATCH%'
      THEN
         -- RMUNJULU 2730738 for proper output file
         okl_am_btch_exp_lease_loan_pvt.pop_asset_msg_tbl;    --log_messages;
      END IF;

      -- Store messages in TRX_MSGS
      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'calling OKL_AM_UTIL_PVT.process_messages'
                                 );
      END IF;

      okl_am_util_pvt.process_messages
                                   (p_trx_source_table      => 'OKL_TRX_CONTRACTS',
                                    p_trx_id                => lp_tcnv_rec.ID,
                                    x_return_status         => l_return_status
                                   );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
              (g_level_statement,
               l_module_name,
                  'called OKL_AM_UTIL_PVT.process_messages , return status: '
               || l_return_status
              );
      END IF;

      -- Set message stack to true
      okl_api.init_msg_list (g_true);
      -- RMUNJULU 23-JAN-03 2762065  -- END

      -- RMUNJULU 04-FEB-03 2781557 -- START

      -- Update the transaction to WORKING before starting other steps
      lp_tcnv_rec.tmt_status_code := 'WORKING';
                                 --akrangan changes for sla tmt_status_code cr
      -- update the transaction record with tsu_code = WORKING
      process_transaction (p_id                 => 0,
                           p_term_rec           => l_term_rec,
                           p_tcnv_rec           => lp_tcnv_rec,
                           p_trn_mode           => 'UPDATE',
                           x_id                 => lx_id,
                           x_return_status      => l_return_status
                          );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
      END IF;

      -- rollback if process transaction failed
      IF (l_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = g_ret_sts_error)
      THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- RMUNJULU 04-FEB-03 2781557 -- END

      -- do asset split
      split_asset (p_term_rec             => l_term_rec,
                   p_sys_date             => l_sys_date,
                   p_klev_tbl             => lp_klev_tbl,
                   p_trn_already_set      => l_trn_already_set,
                   px_overall_status      => l_overall_status,
                   px_tcnv_rec            => lp_tcnv_rec,
                   x_klev_tbl             => lx_klev_tbl,
                   x_return_status        => l_return_status
                  );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'called split_asset , return status: '
                                  || l_return_status
                                 );
      END IF;

      -- Log error and exit if split asset fails
      IF l_return_status <> g_ret_sts_success
      THEN
         -- update the transaction record
         process_transaction (p_id                 => 0,
                              p_term_rec           => l_term_rec,
                              p_tcnv_rec           => lp_tcnv_rec,
                              p_trn_mode           => 'UPDATE',
                              x_id                 => lx_id,
                              x_return_status      => l_return_status
                             );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
         END IF;

         -- rollback if processing transaction failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- RMUNJULU 2730738 for proper output file
         IF p_term_rec.p_control_flag LIKE 'BATCH%'
         THEN
            okl_am_btch_exp_lease_loan_pvt.pop_asset_msg_tbl;
         END IF;

         -- Save messages from stack into transaction message table
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                                  (g_level_statement,
                                   l_module_name,
                                   'calling OKL_AM_UTIL_PVT.process_messages'
                                  );
         END IF;

         okl_am_util_pvt.process_messages
                                   (p_trx_source_table      => 'OKL_TRX_CONTRACTS',
                                    p_trx_id                => lp_tcnv_rec.ID,
                                    x_return_status         => l_return_status
                                   );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_AM_UTIL_PVT.process_messages , return status: '
                || l_return_status
               );
         END IF;

         -- RMUNJULU 3018641 Added to get and set latest run - 02-OCT-03
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                       (g_level_statement,
                        l_module_name,
                        'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run'
                       );
         END IF;

         okl_am_lease_loan_trmnt_pvt.get_set_tmg_run
                                           (p_trx_id             => lp_tcnv_rec.ID,
                                            x_return_status      => l_return_status);

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run , return status: '
                || l_return_status
               );
         END IF;

         -- exit since split asset failed
         RAISE g_exception_halt_validation;
      END IF;

      -- do accounting entries
      accounting_entries (p_term_rec             => l_term_rec,
                          p_sys_date             => l_sys_date,
                          p_klev_tbl             => lx_klev_tbl,
                          p_trn_already_set      => l_trn_already_set,
                          px_overall_status      => l_overall_status,
                          px_tcnv_rec            => lp_tcnv_rec,
                          x_return_status        => l_return_status
                         );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                            (g_level_statement,
                             l_module_name,
                                'called accounting_entries , return status: '
                             || l_return_status
                            );
      END IF;

      -- RMUNJULU 02-JAN-03 2724951 Added code to get lease or loan
      -- Check if lease or loan
      check_lease_or_loan (p_khr_id               => l_term_rec.p_contract_id,
                           x_lease_loan_type      => l_lease_or_loan);

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                         (g_level_statement,
                          l_module_name,
                             'called check_lease_or_loan , l_lease_or_loan: '
                          || l_lease_or_loan
                         );
      END IF;

      -- RMUNJULU 02-JAN-03 2724951 Added code to check if loan and do dispose else
      -- if lease then check if with purchase or without and do accordingly
      -- If loan then do only dispose
      IF l_lease_or_loan = 'LOAN'
      THEN
         -- do asset dispose
         dispose_assets (p_term_rec             => l_term_rec,
                         p_sys_date             => l_sys_date,
                         p_klev_tbl             => lx_klev_tbl,
                         p_trn_already_set      => l_trn_already_set,
                         px_overall_status      => l_overall_status,
                         px_tcnv_rec            => lp_tcnv_rec,
                         x_return_status        => l_return_status
                        );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'called dispose_assets , return status: '
                                 || l_return_status
                                );
         END IF;
      ELSE
         --  l_lease_or_loan = 'LEASE'

         -- If termination with purchase then do dispose else amortize and return
         -- RMUNJULU 31-JAN-03 2780539 Added TER_MAN_PURCHASE which is also a
         -- termination with purchase
         IF (l_term_rec.p_quote_type IN
                ('TER_PURCHASE',
                 'TER_RECOURSE',
                 'TER_ROLL_PURCHASE',
                 'TER_MAN_PURCHASE'
                )
            )
         THEN
            -- do asset dispose
            dispose_assets (p_term_rec             => l_term_rec,
                            p_sys_date             => l_sys_date,
                            p_klev_tbl             => lx_klev_tbl,
                            p_trn_already_set      => l_trn_already_set,
                            px_overall_status      => l_overall_status,
                            px_tcnv_rec            => lp_tcnv_rec,
                            x_return_status        => l_return_status
                           );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'called dispose_assets , return status: '
                                 || l_return_status
                                );
            END IF;

            -- Amortization of assets not needed since termination
            -- with purchase.
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_AMORTIZE_NOT_NEED');
            -- Return of assets not needed since termination with purchase
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_RETURN_NOT_NEED');
         ELSE
            -- do amortization
            amortize_assets (p_term_rec             => l_term_rec,
                             p_sys_date             => l_sys_date,
                             p_klev_tbl             => lx_klev_tbl,
                             p_trn_already_set      => l_trn_already_set,
                             px_overall_status      => l_overall_status,
                             px_tcnv_rec            => lp_tcnv_rec,
                             x_return_status        => l_return_status
                            );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                   'called amortize_assets , return status: '
                                || l_return_status
                               );
            END IF;

/* rmunjulu  bug 6853566 do not call delink here, call from amortize.
            IF g_amort_complete_flag = 'Y'
            THEN
               -- do denlink of assets from k if it is going offlease
               delink_assets (p_term_rec             => l_term_rec,
                              p_sys_date             => l_sys_date,
                              p_klev_tbl             => lx_klev_tbl,
                              p_trn_already_set      => l_trn_already_set,
                              px_overall_status      => l_overall_status,
                              px_tcnv_rec            => lp_tcnv_rec,
                              x_return_status        => l_return_status
                             );
            END IF;
*/
            -- do asset return
            return_assets (p_term_rec             => l_term_rec,
                           p_sys_date             => l_sys_date,
                           p_klev_tbl             => lx_klev_tbl,
                           p_trn_already_set      => l_trn_already_set,
                           px_overall_status      => l_overall_status,
                           px_tcnv_rec            => lp_tcnv_rec,
                           x_return_status        => l_return_status
                          );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                                 (g_level_statement,
                                  l_module_name,
                                     'called return_assets , return status: '
                                  || l_return_status
                                 );
            END IF;

            -- Disposition of assets not needed since termination without purchase
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_AM_DISPOSE_NOT_NEED');
         END IF;
      END IF;

      -- update the lines only if the overall_status is success
      IF (l_overall_status = g_ret_sts_success)
      THEN
         -- Set the p_status (which sets the sts_code) for the contract
         IF     l_term_rec.p_control_flag = 'BATCH_PROCESS'
            AND (   l_term_rec.p_quote_id IS NULL
                 OR l_term_rec.p_quote_id = g_miss_num
                )
         THEN
            l_status := 'EXPIRED';
         ELSE
            l_status := 'TERMINATED';
         END IF;

         -- RMUNJULU 3018641 Step Message
         -- Step : Update Contract and Lines
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_AM_STEP_UPD');

         -- RMUNJULU 23-JAN-03 2762065
         -- If batch process then log the messages from stack
         IF p_term_rec.p_control_flag LIKE 'BATCH%'
         THEN
            -- RMUNJULU 2730738 for proper output file
            okl_am_btch_exp_lease_loan_pvt.pop_asset_msg_tbl; --log_messages;
         END IF;

         -- RMUNJULU 07-JAN-03 2736865 Added code to store messages and set stack to true
         -- Store messages in TRX_MSGS
         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                                  (g_level_statement,
                                   l_module_name,
                                   'calling OKL_AM_UTIL_PVT.process_messages'
                                  );
         END IF;

         okl_am_util_pvt.process_messages
                                   (p_trx_source_table      => 'OKL_TRX_CONTRACTS',
                                    p_trx_id                => lp_tcnv_rec.ID,
                                    x_return_status         => l_return_status
                                   );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
               (g_level_statement,
                l_module_name,
                   'called OKL_AM_UTIL_PVT.process_messages , return status: '
                || l_return_status
               );
         END IF;

         -- Set message stack to true
         okl_api.init_msg_list (g_true);
         -- update lines, do mass rebook and activate insurances
         terminate_lines
            (p_api_version          => p_api_version,
             p_init_msg_list        => g_false,
             x_msg_count            => x_msg_count,
             x_msg_data             => x_msg_data,
             x_return_status        => l_return_status,
             px_overall_status      => l_overall_status,
             p_trn_already_set      => l_trn_already_set,
                                        -- RMUNJULU CONTRACT BLOCKING -- ADDED
             p_term_rec             => l_term_rec,
             p_sys_date             => l_sys_date,
             p_klev_tbl             => lx_klev_tbl,
             p_status               => l_status,
             px_tcnv_rec            => lp_tcnv_rec
            );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                   'called terminate_lines , return status: '
                                || l_return_status
                               );
         END IF;

         --++++++++start   -- CONTRACT BLOCKING (2)
         -- Transaction is now updated in terminate lines (before massrebook and after massrebook if needed)
         -- But not if anyproc before mass rebook fails
         IF l_return_status <> g_ret_sts_success
         THEN
            -- update the transaction record
            process_transaction (p_id                 => 0,
                                 p_term_rec           => l_term_rec,
                                 p_tcnv_rec           => lp_tcnv_rec,
                                 p_trn_mode           => 'UPDATE',
                                 x_id                 => lx_id,
                                 x_return_status      => l_return_status
                                );

            IF (is_debug_statement_on)
            THEN
               okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
            END IF;

            -- rollback if processing transaction failed
            IF (l_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = g_ret_sts_error)
            THEN
               RAISE okl_api.g_exception_error;
            END IF;
         END IF;
      --    END IF;
      ELSE
         -- Overall Not successfull so update transaction

         -- update the transaction record
         process_transaction (p_id                 => 0,
                              p_term_rec           => l_term_rec,
                              p_tcnv_rec           => lp_tcnv_rec,
                              p_trn_mode           => 'UPDATE',
                              x_id                 => lx_id,
                              x_return_status      => l_return_status
                             );

         IF (is_debug_statement_on)
         THEN
            okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'called process_transaction , return status: '
                            || l_return_status
                           );
         END IF;

         -- rollback if processing transaction failed
         IF (l_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (l_return_status = g_ret_sts_error)
         THEN
            RAISE okl_api.g_exception_error;
         END IF;
      END IF;

      --+++++++++end -- CONTRACT BLOCKING (2)

      -- RMUNJULU 2730738 for proper output file
      IF p_term_rec.p_control_flag LIKE 'BATCH%'
      THEN
         okl_am_btch_exp_lease_loan_pvt.pop_asset_msg_tbl;
      END IF;

      -- Save messages from stack into transaction message table
      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'calling OKL_AM_UTIL_PVT.process_messages'
                                 );
      END IF;

      okl_am_util_pvt.process_messages
                                   (p_trx_source_table      => 'OKL_TRX_CONTRACTS',
                                    p_trx_id                => lp_tcnv_rec.ID,
                                    x_return_status         => l_return_status
                                   );

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
              (g_level_statement,
               l_module_name,
                  'called OKL_AM_UTIL_PVT.process_messages , return status: '
               || l_return_status
              );
      END IF;

      -- RMUNJULU 3018641 Added code to get and set TMG_RUN
      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
                       (g_level_statement,
                        l_module_name,
                        'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run'
                       );
      END IF;

      okl_am_lease_loan_trmnt_pvt.get_set_tmg_run
                                           (p_trx_id             => lp_tcnv_rec.ID,
                                            x_return_status      => l_return_status);

      IF (is_debug_statement_on)
      THEN
         okl_debug_pub.log_debug
            (g_level_statement,
             l_module_name,
                'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run , return status: '
             || l_return_status
            );
      END IF;

      -- Set the return status
      x_return_status := g_ret_sts_success;
      -- End the activity
      okl_api.end_activity (x_msg_count, x_msg_data);

      IF (is_debug_procedure_on)
      THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'End(-)'
                                 );
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := g_ret_sts_success;

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_HALT_VALIDATION'
                                    );
         END IF;
      WHEN okl_api.g_exception_error
      THEN
         x_return_status :=
            okl_api.handle_exceptions (l_api_name,
                                       g_pkg_name,
                                       'G_RET_STS_ERROR',
                                       x_msg_count,
                                       x_msg_data,
                                       '_PVT'
                                      );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                     'EXCEPTION :' || 'G_EXCEPTION_ERROR'
                                    );
         END IF;
      WHEN okl_api.g_exception_unexpected_error
      THEN
         x_return_status :=
            okl_api.handle_exceptions (l_api_name,
                                       g_pkg_name,
                                       'G_RET_STS_UNEXP_ERROR',
                                       x_msg_count,
                                       x_msg_data,
                                       '_PVT'
                                      );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'G_EXCEPTION_UNEXPECTED_ERROR'
                                    );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status :=
            okl_api.handle_exceptions (l_api_name,
                                       g_pkg_name,
                                       'OTHERS',
                                       x_msg_count,
                                       x_msg_data,
                                       '_PVT'
                                      );

         IF (is_debug_exception_on)
         THEN
            okl_debug_pub.log_debug (g_level_exception,
                                     l_module_name,
                                        'EXCEPTION :'
                                     || 'OTHERS, SQLCODE: '
                                     || SQLCODE
                                     || ' , SQLERRM : '
                                     || SQLERRM
                                    );
         END IF;
   END asset_level_termination;
END okl_am_cntrct_ln_trmnt_pvt;

/
