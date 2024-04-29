--------------------------------------------------------
--  DDL for Package Body OKL_AM_BTCH_EXP_LEASE_LOAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_BTCH_EXP_LEASE_LOAN_PVT" AS
/* $Header: OKLRLLBB.pls 120.16.12010000.2 2008/10/03 18:37:21 rkuttiya ship $ */

   -- RMUNJULU PERF
   TYPE req_tab_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE batch_tab_type IS TABLE OF VARCHAR2 (30)
      INDEX BY BINARY_INTEGER;

   -- RMUNJULU 2730738 Added GLOBAL PACKAGE BODY VARIABLES for proper output file
   success_exp_message_table    message_tbl_type;
   error_exp_message_table      message_tbl_type;
   success_recy_message_table   message_tbl_type;
   error_recy_message_table     message_tbl_type;
   l_success_exp_tbl_index      NUMBER           := 0;
   l_error_exp_tbl_index        NUMBER           := 0;
   l_success_recy_tbl_index     NUMBER           := 0;
   l_error_recy_tbl_index       NUMBER           := 0;
   g_first             CONSTANT NUMBER           := fnd_msg_pub.g_first;
   g_next              CONSTANT NUMBER           := fnd_msg_pub.g_next;
   g_true              CONSTANT VARCHAR2 (1)     := fnd_api.g_true;
   g_false             CONSTANT VARCHAR2 (1)     := fnd_api.g_false;
   g_prin_bal_zero              VARCHAR2 (3);
   --akrangan added for debug logging begin
   g_module_name                VARCHAR2 (255)
                             := 'okl.am.plsql.okl_am_btch_exp_lease_loan_pvt';
   g_level_procedure   CONSTANT NUMBER           := fnd_log.level_procedure;
   g_level_exception   CONSTANT NUMBER           := fnd_log.level_exception;
   g_level_statement   CONSTANT NUMBER           := fnd_log.level_statement;

   --akrangan added for debug logging end

   -- Start of comments
   --
   -- Procedure Name  : RESET_ASSET_MSG_TBL
   -- Desciption     : Resets the ASSET_MSG_TBL
   -- Business Rules  :
   -- Parameters       :
   -- Version      : 1.0
   -- History        : RMUNJULU 2730738 created for proper output file
   --
   -- End of comments
   PROCEDURE reset_asset_msg_tbl IS
   BEGIN
      asset_msg_tbl.DELETE;
      g_msg_tbl_counter := 1;
   END reset_asset_msg_tbl;

   -- Start of comments
   --
   -- Procedure Name  : POP_ASSET_MSG_TBL
   -- Desciption     : Populates the ASSET_MSG_TBL
   -- Business Rules  :
   -- Parameters       :
   -- Version      : 1.0
   -- History        : RMUNJULU 2730738 created for proper output file
   --
   -- End of comments
   PROCEDURE pop_asset_msg_tbl IS
      lx_error_rec   okl_api.error_rec_type;
      l_msg_idx      INTEGER                := g_first;
      l_msg_tbl      msg_tbl_type;
   BEGIN
      -- Get the messages in the log
      LOOP
         fnd_msg_pub.get (p_msg_index          => l_msg_idx,
                          p_encoded            => g_false,
                          p_data               => lx_error_rec.msg_data,
                          p_msg_index_out      => lx_error_rec.msg_count
                         );

         IF (lx_error_rec.msg_count IS NOT NULL) THEN
            asset_msg_tbl (g_msg_tbl_counter).msg := lx_error_rec.msg_data;
            g_msg_tbl_counter := g_msg_tbl_counter + 1;
         END IF;

         EXIT WHEN (   (lx_error_rec.msg_count = fnd_msg_pub.count_msg)
                    OR (lx_error_rec.msg_count IS NULL)
                   );
         l_msg_idx := g_next;
      END LOOP;
   END pop_asset_msg_tbl;

   -- Start of comments
   --
   -- Procedure Name  : fnd_output
   -- Desciption     : Logs the messages in the output log
   -- Business Rules  :
   -- Parameters       :
   -- Version      : 1.0
   -- History        : RMUNJULU 2730738 created for proper output file
   --                : rmunjulu 4016497 Changed to cater for NON EXPIRED/NON RECYCLED Contract
   --
   -- End of comments
   PROCEDURE fnd_output (
      p_chr_id         IN   NUMBER,
      p_chr_number     IN   VARCHAR2,
      p_start_date     IN   DATE,
      p_end_date       IN   DATE,
      p_status         IN   VARCHAR2,
      p_exp_recy       IN   VARCHAR2,
      p_control_flag   IN   VARCHAR2
   ) IS
      lx_error_rec            okl_api.error_rec_type;
      l_msg_idx               INTEGER                := g_first;
      l_msg_tbl               msg_tbl_type;
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500) := g_module_name || 'fnd_output';
      is_debug_exception_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      -- SECHAWLA 26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
      -- of db/Pl Sql  Commented out the code that populates the message table as it was not being used to display messages.
      /*
      -- Get the messages in the log
      LOOP

        FND_MSG_PUB.get(
                  p_msg_index     => l_msg_idx,
               p_encoded       => G_FALSE,
               p_data          => lx_error_rec.msg_data,
               p_msg_index_out => lx_error_rec.msg_count);


           IF (lx_error_rec.msg_count IS NOT NULL) THEN
                l_msg_tbl(lx_error_rec.msg_count).msg := lx_error_rec.msg_data;
        END IF;


           EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
               OR (lx_error_rec.msg_count IS NULL));

           l_msg_idx   := G_NEXT;

      END LOOP;
      */
      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_chr_id       =' || p_chr_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_chr_number   =' || p_chr_number
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_start_date   =' || p_start_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_end_date     =' || p_end_date
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_status       =' || p_status
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_exp_recy     =' || p_exp_recy
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_control_flag =' || p_control_flag
                                 );
      END IF;

      IF p_control_flag = 'SUCCESS' THEN
         IF p_exp_recy = 'EXP' THEN
            l_success_exp_tbl_index := l_success_exp_tbl_index + 1;
            success_exp_message_table (l_success_exp_tbl_index).ID :=
                                                                     p_chr_id;
            success_exp_message_table (l_success_exp_tbl_index).contract_number :=
                                                                 p_chr_number;
            success_exp_message_table (l_success_exp_tbl_index).start_date :=
                                                                 p_start_date;
            success_exp_message_table (l_success_exp_tbl_index).end_date :=
                                                                   p_end_date;
            success_exp_message_table (l_success_exp_tbl_index).status :=
                                                                     p_status;
         -- SECHAWLA 26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
         -- of db/Pl Sql  Removed the msg_tbl field as it was not being used to display messages.

         --  success_exp_message_table(l_success_exp_tbl_index).msg_tbl :=  l_msg_tbl;
         ELSE                                                          -- RECY
            IF asset_msg_tbl.COUNT > 0 THEN            -- Partial Termination
               l_success_recy_tbl_index := l_success_recy_tbl_index + 1;
               success_recy_message_table (l_success_recy_tbl_index).ID :=
                                                                     p_chr_id;
               success_recy_message_table (l_success_recy_tbl_index).contract_number :=
                                                                 p_chr_number;
               success_recy_message_table (l_success_recy_tbl_index).start_date :=
                                                                 p_start_date;
               success_recy_message_table (l_success_recy_tbl_index).end_date :=
                                                                   p_end_date;
               success_recy_message_table (l_success_recy_tbl_index).status :=
                                                                     p_status;
            -- SECHAWLA 26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
            -- of db/Pl Sql  Removed the msg_tbl field as it was not being used to display messages.

            --success_recy_message_table(l_success_recy_tbl_index).msg_tbl :=  ASSET_MSG_TBL;
            ELSE                                           -- Full Termination
               l_success_recy_tbl_index := l_success_recy_tbl_index + 1;
               success_recy_message_table (l_success_recy_tbl_index).ID :=
                                                                     p_chr_id;
               success_recy_message_table (l_success_recy_tbl_index).contract_number :=
                                                                 p_chr_number;
               success_recy_message_table (l_success_recy_tbl_index).start_date :=
                                                                 p_start_date;
               success_recy_message_table (l_success_recy_tbl_index).end_date :=
                                                                   p_end_date;
               success_recy_message_table (l_success_recy_tbl_index).status :=
                                                                     p_status;
            -- SECHAWLA 26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
            -- of db/Pl Sql  Removed the msg_tbl field as it was not being used to display messages.

            --success_recy_message_table(l_success_recy_tbl_index).msg_tbl :=  l_msg_tbl;
            END IF;
         END IF;
      ELSIF p_control_flag = 'FAIL' THEN                               -- FAIL
         IF p_exp_recy = 'EXP' THEN
            l_error_exp_tbl_index := l_error_exp_tbl_index + 1;
            error_exp_message_table (l_error_exp_tbl_index).ID := p_chr_id;
            error_exp_message_table (l_error_exp_tbl_index).contract_number :=
                                                                 p_chr_number;
            error_exp_message_table (l_error_exp_tbl_index).start_date :=
                                                                 p_start_date;
            error_exp_message_table (l_error_exp_tbl_index).end_date :=
                                                                   p_end_date;
            error_exp_message_table (l_error_exp_tbl_index).status :=
                                                                     p_status;
         -- SECHAWLA 26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
         -- of db/Pl Sql  Removed the msg_tbl field as it was not being used to display messages.
         --error_exp_message_table(l_error_exp_tbl_index).msg_tbl :=  l_msg_tbl;
         ELSE                                                          -- RECY
            IF asset_msg_tbl.COUNT > 0 THEN            -- Partial Termination
               l_error_recy_tbl_index := l_error_recy_tbl_index + 1;
               error_recy_message_table (l_error_recy_tbl_index).ID :=
                                                                     p_chr_id;
               error_recy_message_table (l_error_recy_tbl_index).contract_number :=
                                                                 p_chr_number;
               error_recy_message_table (l_error_recy_tbl_index).start_date :=
                                                                 p_start_date;
               error_recy_message_table (l_error_recy_tbl_index).end_date :=
                                                                   p_end_date;
               error_recy_message_table (l_error_recy_tbl_index).status :=
                                                                     p_status;
            -- SECHAWLA 26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
            -- of db/Pl Sql  Removed the msg_tbl field as it was not being used to display messages.
            --error_recy_message_table(l_error_recy_tbl_index).msg_tbl :=  ASSET_MSG_TBL;
            ELSE                                           -- Full Termination
               l_error_recy_tbl_index := l_error_recy_tbl_index + 1;
               error_recy_message_table (l_error_recy_tbl_index).ID :=
                                                                     p_chr_id;
               error_recy_message_table (l_error_recy_tbl_index).contract_number :=
                                                                 p_chr_number;
               error_recy_message_table (l_error_recy_tbl_index).start_date :=
                                                                 p_start_date;
               error_recy_message_table (l_error_recy_tbl_index).end_date :=
                                                                   p_end_date;
               error_recy_message_table (l_error_recy_tbl_index).status :=
                                                                     p_status;
            -- SECHAWLA 26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
            -- of db/Pl Sql  Removed the msg_tbl field as it was not being used to display messages.
            --error_recy_message_table(l_error_recy_tbl_index).msg_tbl :=  l_msg_tbl;
            END IF;
         END IF;
      ELSE                                      -- Other than SUCCESS and FAIL
         l_error_exp_tbl_index := l_error_exp_tbl_index + 1;
         error_exp_message_table (l_error_exp_tbl_index).ID := p_chr_id;
         error_exp_message_table (l_error_exp_tbl_index).contract_number :=
                                                                 p_chr_number;
         error_exp_message_table (l_error_exp_tbl_index).start_date :=
                                                                 p_start_date;
         error_exp_message_table (l_error_exp_tbl_index).end_date :=
                                                                   p_end_date;
         error_exp_message_table (l_error_exp_tbl_index).status := p_status;
      END IF;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
              IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => okc_api.g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END fnd_output;

   -- Start of comments
   --
   -- Procedure Name  : create_report
   -- Desciption     : Creates the Output and Log Reports
   -- Business Rules  :
   -- Parameters       :
   -- Version      : 1.0
   -- History        : RMUNJULU 2730738 created for proper output file
   --                  rmunjulu 4016497 Added parameters and modified to check for parameters
   --
   -- End of comments
   PROCEDURE create_report (
      p_source    IN   VARCHAR2 DEFAULT NULL,
      -- rmunjulu 4016497 Added parameter
      p_message   IN   VARCHAR2 DEFAULT NULL
   ) IS                                    -- rmunjulu 4016497 Added parameter
      i                       NUMBER;
      j                       NUMBER;
      l_success_exp           NUMBER;
      l_success_recy          NUMBER;
      l_error_exp             NUMBER;
      l_error_recy            NUMBER;
      l_total_exp             NUMBER;
      l_total_recy            NUMBER;

      -- Get the  Org Name
      CURSOR org_csr (p_org_id IN NUMBER) IS
         SELECT hou.NAME
           FROM hr_operating_units hou
          WHERE hou.organization_id = p_org_id;

      l_org_id                NUMBER        := mo_global.get_current_org_id
                                                                           ();
      l_org_name              VARCHAR2 (300);
      l_orcl_logo             VARCHAR2 (300);
      l_term_heading          VARCHAR2 (300);
      l_set_of_books          VARCHAR2 (300);
      l_set_of_books_name     VARCHAR2 (300);
      l_run_date              VARCHAR2 (300);
      l_oper_unit             VARCHAR2 (300);
      l_type                  VARCHAR2 (300);
      l_expired_k             VARCHAR2 (300);
      l_recy_k                VARCHAR2 (300);
      l_k_term_succ           VARCHAR2 (300);
      l_k_not_term            VARCHAR2 (300);
      l_exp_k_err             VARCHAR2 (300);
      l_serial                VARCHAR2 (300);
      l_k_num                 VARCHAR2 (300);
      l_start_date            VARCHAR2 (300);
      l_end_date              VARCHAR2 (300);
      l_status                VARCHAR2 (300);
      l_messages              VARCHAR2 (300);
      l_recy_k_err            VARCHAR2 (300);
      l_succ_exp_k            VARCHAR2 (300);
      l_succ_recy_k           VARCHAR2 (300);
      l_eop                   VARCHAR2 (300);
      l_printed               VARCHAR2 (1);
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                           := g_module_name || 'create_report';
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
                                  'p_source       =' || p_source
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_message   =' || p_message
                                 );
      END IF;

      l_success_exp := success_exp_message_table.COUNT;
      l_success_recy := success_recy_message_table.COUNT;
      l_error_exp := error_exp_message_table.COUNT;
      l_error_recy := error_recy_message_table.COUNT;
      l_total_exp := l_success_exp + l_error_exp;
      l_total_recy := l_success_recy + l_error_recy;

      -- Get the Org Name
      FOR org_rec IN org_csr (l_org_id)
      LOOP
         l_org_name := org_rec.NAME;
      END LOOP;

      l_set_of_books_name :=
         okl_accounting_util.get_set_of_books_name
                                      (okl_accounting_util.get_set_of_books_id);
      -- Get all the tokens
      l_orcl_logo :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_ACCT_LEASE_MANAGEMENT'
                                               );
      l_term_heading :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_TERM_EXP_K'
                                               );
      -- 'Terminate Expired Contracts';
      l_set_of_books :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_SET_OF_BOOKS'
                                               );
      l_run_date :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_RUN_DATE'
                                               );
      l_oper_unit :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_OPERUNIT'
                                               );
      l_type :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_TYPE'
                                               );
      l_expired_k :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_EXP_K'
                                               );      -- 'Expired Contracts';
      l_recy_k :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_RECY_K'
                                               );     -- 'Recycled Contracts';
      l_k_term_succ :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_SUCCESS'
                                               );             -- 'Successful';
      l_k_not_term :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_ERROR'
                                               );                -- 'Errored';
      l_exp_k_err :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_EXP_ERROR'
                                               );
      -- 'Expired Contracts With Errors';
      l_serial :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_SERIAL_NUMBER'
                                               );
      l_k_num :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_K_NUMBER'
                                               );        -- 'Contract Number';
      l_start_date :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_START_DATE'
                                               );
      l_end_date :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_END_DATE'
                                               );
      l_status :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_STATUS'
                                               );
      l_messages :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_MESSAGES'
                                               );
      l_recy_k_err :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_RECY_ERROR'
                                               );
      -- 'Recycled Contracts With Errors';
      l_succ_exp_k :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_SUCCESS_EXP'
                                               );
      -- 'Successfully Expired Contracts';
      l_eop :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_END_OF_REPORT'
                                               );
      l_succ_recy_k :=
         okl_accounting_util.get_message_token ('OKL_AM_CONC_OUTPUT',
                                                'OKL_AM_SUCCESS_RECY'
                                               );
                                          --'Successfully Recycled Contracts';
      -- Log --
      fnd_file.put_line (fnd_file.LOG, '');
      fnd_file.put_line (fnd_file.LOG, RPAD ('=', 128, '='));
      fnd_file.put_line (fnd_file.LOG, '');
      fnd_file.put_line (fnd_file.LOG,
                            l_type
                         || RPAD (' ', 40 - LENGTH (l_type), ' ')
                         || l_expired_k
                         || RPAD (' ', 35 - LENGTH (l_expired_k), ' ')
                         || l_recy_k
                         || RPAD (' ', 35 - LENGTH (l_recy_k), ' ')
                        );
      fnd_file.put_line (fnd_file.LOG, RPAD ('-', 128, '-'));
      fnd_file.put_line (fnd_file.LOG,
                            l_k_term_succ
                         || RPAD (' ', 40 - LENGTH (l_k_term_succ), ' ')
                         || l_success_exp
                         || RPAD (' ', 35 - LENGTH (l_success_exp), ' ')
                         || l_success_recy
                         || RPAD (' ', 35 - LENGTH (l_success_recy), ' ')
                        );
      fnd_file.put_line (fnd_file.LOG,
                            l_k_not_term
                         || RPAD (' ', 40 - LENGTH (l_k_not_term), ' ')
                         || l_error_exp
                         || RPAD (' ', 35 - LENGTH (l_error_exp), ' ')
                         || l_error_recy
                         || RPAD (' ', 35 - LENGTH (l_error_recy), ' ')
                        );
      fnd_file.put_line (fnd_file.LOG, '');
      fnd_file.put_line (fnd_file.LOG, RPAD ('=', 128, '='));
      -- Output --
      fnd_file.put_line (fnd_file.output,
                            RPAD (' ', 128 / 2 - LENGTH (l_orcl_logo) / 2,
                                  ' ')
                         || l_orcl_logo
                        );
      fnd_file.put_line (fnd_file.output,
                            RPAD (' ',
                                  128 / 2 - LENGTH (l_term_heading) / 2,
                                  ' '
                                 )
                         || l_term_heading
                        );
      fnd_file.put_line (fnd_file.output,
                            RPAD (' ',
                                  128 / 2 - LENGTH (l_term_heading) / 2,
                                  ' '
                                 )
                         || RPAD ('-', LENGTH (l_term_heading), '-')
                        );
      fnd_file.put_line (fnd_file.output, '');
      fnd_file.put_line (fnd_file.output,
                            l_set_of_books
                         || ': '
                         || RPAD (SUBSTR (l_set_of_books_name, 1, 60), 60,
                                  ' ')
                         || LPAD (' ', 25, ' ')
                         || l_run_date
                         || ':'
                         || SUBSTR (TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI'),
                                    1,
                                    27
                                   )
                        );
      fnd_file.put_line (fnd_file.output,
                         l_oper_unit || ':' || SUBSTR (l_org_name, 1, 30)
                        );
      fnd_file.put_line (fnd_file.output, '');
      fnd_file.put_line (fnd_file.output, '');
      fnd_file.put_line (fnd_file.output,
                            l_type
                         || RPAD (' ', 40 - LENGTH (l_type), ' ')
                         || l_expired_k
                         || RPAD (' ', 35 - LENGTH (l_expired_k), ' ')
                         || l_recy_k
                         || RPAD (' ', 35 - LENGTH (l_recy_k), ' ')
                        );
      fnd_file.put_line (fnd_file.output, RPAD ('-', 128, '-'));
      fnd_file.put_line (fnd_file.output,
                            l_k_term_succ
                         || RPAD (' ', 40 - LENGTH (l_k_term_succ), ' ')
                         || l_success_exp
                         || RPAD (' ', 35 - LENGTH (l_success_exp), ' ')
                         || l_success_recy
                         || RPAD (' ', 35 - LENGTH (l_success_recy), ' ')
                        );
      fnd_file.put_line (fnd_file.output,
                            l_k_not_term
                         || RPAD (' ', 40 - LENGTH (l_k_not_term), ' ')
                         || l_error_exp
                         || RPAD (' ', 35 - LENGTH (l_error_exp), ' ')
                         || l_error_recy
                         || RPAD (' ', 35 - LENGTH (l_error_recy), ' ')
                        );
      fnd_file.put_line (fnd_file.output, '');
      fnd_file.put_line (fnd_file.output, RPAD ('=', 128, '='));
      fnd_file.put_line (fnd_file.output, '');

      IF p_source IS NULL THEN                             -- rmunjulu 4016497
         -- errored expired contracts
         IF l_error_exp > 0 THEN
            fnd_file.put_line (fnd_file.output, '');
            fnd_file.put_line (fnd_file.output, l_exp_k_err);
            fnd_file.put_line (fnd_file.output,
                               RPAD ('-', LENGTH (l_exp_k_err), '-')
                              );
            fnd_file.put_line (fnd_file.output, '');
            l_printed := 'N';

            -- Display the contract details
            FOR i IN
               error_exp_message_table.FIRST .. error_exp_message_table.LAST
            LOOP
               -- Print Header only once
               IF l_printed = 'N' THEN
                  fnd_file.put_line (fnd_file.output,
                                        l_serial
                                     || RPAD (' ', 15 - LENGTH (l_serial),
                                              ' ')
                                     || l_k_num
                                     || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                                     || l_start_date
                                     || RPAD (' ',
                                              15 - LENGTH (l_start_date),
                                              ' '
                                             )
                                     || l_end_date
                                     || RPAD (' ',
                                              15 - LENGTH (l_end_date),
                                              ' '
                                             )
                                     || l_status
                                     || RPAD (' ', 15 - LENGTH (l_status),
                                              ' ')
                                    );
                  fnd_file.put_line (fnd_file.output,
                                        RPAD ('-', LENGTH (l_serial), '-')
                                     || RPAD (' ', 15 - LENGTH (l_serial),
                                              ' ')
                                     || RPAD ('-', LENGTH (l_k_num), '-')
                                     || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                                     || RPAD ('-', LENGTH (l_start_date), '-')
                                     || RPAD (' ',
                                              15 - LENGTH (l_start_date),
                                              ' '
                                             )
                                     || RPAD ('-', LENGTH (l_end_date), '-')
                                     || RPAD (' ',
                                              15 - LENGTH (l_end_date),
                                              ' '
                                             )
                                     || RPAD ('-', LENGTH (l_status), '-')
                                     || RPAD (' ', 15 - LENGTH (l_status),
                                              ' ')
                                    );
               END IF;

               l_printed := 'Y';
               fnd_file.put_line
                  (fnd_file.output,
                      i
                   || RPAD (' ', 15 - LENGTH (i), ' ')
                   || error_exp_message_table (i).contract_number
                   || RPAD
                          (' ',
                             35
                           - LENGTH
                                   (error_exp_message_table (i).contract_number
                                   ),
                           ' '
                          )
                   || error_exp_message_table (i).start_date
                   || RPAD (' ',
                              15
                            - LENGTH (error_exp_message_table (i).start_date),
                            ' '
                           )
                   || error_exp_message_table (i).end_date
                   || RPAD (' ',
                            15 - LENGTH (error_exp_message_table (i).end_date),
                            ' '
                           )
                   || error_exp_message_table (i).status
                   || RPAD (' ',
                            15 - LENGTH (error_exp_message_table (i).status),
                            ' '
                           )
                  );

               --FND_FILE.put_line(FND_FILE.output,'');

               --FND_FILE.put_line(FND_FILE.output,  RPAD(' ',5,' ') || l_messages || ' :');

               -- Get the messages in the log
               --FOR j IN error_exp_message_table(i).msg_tbl.FIRST..error_exp_message_table(i).msg_tbl.LAST LOOP
                   --FND_FILE.put(FND_FILE.output, RPAD(' ',5,' ') || j || ': ' || error_exp_message_table(i).msg_tbl(j).msg);
               --END LOOP;

               --FND_FILE.put_line(FND_FILE.output,'');
               IF NVL (g_prin_bal_zero, 'N') = 'Y' THEN
                  fnd_file.put_line (fnd_file.output, '');
                  fnd_file.put_line (fnd_file.output,
                                     RPAD (' ', 5, ' ') || l_messages || ' :'
                                    );
                  fnd_file.put
                           (fnd_file.output,
                               RPAD (' ', 5, ' ')
                            || 1
                            || ': '
                            || 'Principal Balance for this contract is not Zero.'
                           );
                  fnd_file.put_line (fnd_file.output, '');
               END IF;
            END LOOP;
         END IF;

         -- errorred recycled contracts
         IF l_error_recy > 0 THEN
            fnd_file.put_line (fnd_file.output, '');
            fnd_file.put_line (fnd_file.output, l_recy_k_err);
            fnd_file.put_line (fnd_file.output,
                               RPAD ('-', LENGTH (l_recy_k_err), '-')
                              );
            fnd_file.put_line (fnd_file.output, '');
            l_printed := 'N';

            -- Display the contract details
            FOR i IN
               error_recy_message_table.FIRST .. error_recy_message_table.LAST
            LOOP
               -- Print Header only once
               IF l_printed = 'N' THEN
                  fnd_file.put_line (fnd_file.output,
                                        l_serial
                                     || RPAD (' ', 15 - LENGTH (l_serial),
                                              ' ')
                                     || l_k_num
                                     || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                                     || l_start_date
                                     || RPAD (' ',
                                              15 - LENGTH (l_start_date),
                                              ' '
                                             )
                                     || l_end_date
                                     || RPAD (' ',
                                              15 - LENGTH (l_end_date),
                                              ' '
                                             )
                                     || l_status
                                     || RPAD (' ', 15 - LENGTH (l_status),
                                              ' ')
                                    );
                  fnd_file.put_line (fnd_file.output,
                                        RPAD ('-', LENGTH (l_serial), '-')
                                     || RPAD (' ', 15 - LENGTH (l_serial),
                                              ' ')
                                     || RPAD ('-', LENGTH (l_k_num), '-')
                                     || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                                     || RPAD ('-', LENGTH (l_start_date), '-')
                                     || RPAD (' ',
                                              15 - LENGTH (l_start_date),
                                              ' '
                                             )
                                     || RPAD ('-', LENGTH (l_end_date), '-')
                                     || RPAD (' ',
                                              15 - LENGTH (l_end_date),
                                              ' '
                                             )
                                     || RPAD ('-', LENGTH (l_status), '-')
                                     || RPAD (' ', 15 - LENGTH (l_status),
                                              ' ')
                                    );
               END IF;

               l_printed := 'Y';
               fnd_file.put_line
                  (fnd_file.output,
                      i
                   || RPAD (' ', 15 - LENGTH (i), ' ')
                   || error_recy_message_table (i).contract_number
                   || RPAD
                         (' ',
                            35
                          - LENGTH
                                  (error_recy_message_table (i).contract_number
                                  ),
                          ' '
                         )
                   || error_recy_message_table (i).start_date
                   || RPAD (' ',
                              15
                            - LENGTH (error_recy_message_table (i).start_date),
                            ' '
                           )
                   || error_recy_message_table (i).end_date
                   || RPAD (' ',
                            15
                            - LENGTH (error_recy_message_table (i).end_date),
                            ' '
                           )
                   || error_recy_message_table (i).status
                   || RPAD (' ',
                            15 - LENGTH (error_recy_message_table (i).status),
                            ' '
                           )
                  );
            --FND_FILE.put_line(FND_FILE.output,'');

            --FND_FILE.put_line(FND_FILE.output,  RPAD(' ',5,' ') || l_messages || ' :');

            -- Get the messages in the log
            --FOR j IN error_recy_message_table(i).msg_tbl.FIRST..error_recy_message_table(i).msg_tbl.LAST LOOP
                --FND_FILE.put(FND_FILE.output, RPAD(' ',5,' ') || j || ': ' || error_recy_message_table(i).msg_tbl(j).msg);
            --END LOOP;

            --FND_FILE.put_line(FND_FILE.output,'');
            END LOOP;
         END IF;

         -- successfully expired contracts
         IF l_success_exp > 0 THEN
            fnd_file.put_line (fnd_file.output, '');
            fnd_file.put_line (fnd_file.output, l_succ_exp_k);
            fnd_file.put_line (fnd_file.output,
                               RPAD ('-', LENGTH (l_succ_exp_k), '-')
                              );
            fnd_file.put_line (fnd_file.output, '');
            l_printed := 'N';

            -- Display the contract details
            FOR i IN
               success_exp_message_table.FIRST .. success_exp_message_table.LAST
            LOOP
               -- Print Header only once
               IF l_printed = 'N' THEN
                  fnd_file.put_line (fnd_file.output,
                                        l_serial
                                     || RPAD (' ', 15 - LENGTH (l_serial),
                                              ' ')
                                     || l_k_num
                                     || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                                     || l_start_date
                                     || RPAD (' ',
                                              15 - LENGTH (l_start_date),
                                              ' '
                                             )
                                     || l_end_date
                                     || RPAD (' ',
                                              15 - LENGTH (l_end_date),
                                              ' '
                                             )
                                     || l_status
                                     || RPAD (' ', 15 - LENGTH (l_status),
                                              ' ')
                                    );
                  fnd_file.put_line (fnd_file.output,
                                        RPAD ('-', LENGTH (l_serial), '-')
                                     || RPAD (' ', 15 - LENGTH (l_serial),
                                              ' ')
                                     || RPAD ('-', LENGTH (l_k_num), '-')
                                     || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                                     || RPAD ('-', LENGTH (l_start_date), '-')
                                     || RPAD (' ',
                                              15 - LENGTH (l_start_date),
                                              ' '
                                             )
                                     || RPAD ('-', LENGTH (l_end_date), '-')
                                     || RPAD (' ',
                                              15 - LENGTH (l_end_date),
                                              ' '
                                             )
                                     || RPAD ('-', LENGTH (l_status), '-')
                                     || RPAD (' ', 15 - LENGTH (l_status),
                                              ' ')
                                    );
               END IF;

               l_printed := 'Y';
               fnd_file.put_line
                  (fnd_file.output,
                      i
                   || RPAD (' ', 15 - LENGTH (i), ' ')
                   || success_exp_message_table (i).contract_number
                   || RPAD
                         (' ',
                            35
                          - LENGTH
                                 (success_exp_message_table (i).contract_number
                                 ),
                          ' '
                         )
                   || success_exp_message_table (i).start_date
                   || RPAD (' ',
                              15
                            - LENGTH (success_exp_message_table (i).start_date),
                            ' '
                           )
                   || success_exp_message_table (i).end_date
                   || RPAD (' ',
                              15
                            - LENGTH (success_exp_message_table (i).end_date),
                            ' '
                           )
                   || success_exp_message_table (i).status
                   || RPAD (' ',
                            15 - LENGTH (success_exp_message_table (i).status),
                            ' '
                           )
                  );
            END LOOP;
         END IF;

         -- successfully recycled contracts
         IF l_success_recy > 0 THEN
            fnd_file.put_line (fnd_file.output, '');
            fnd_file.put_line (fnd_file.output, l_succ_recy_k);
            fnd_file.put_line (fnd_file.output,
                               RPAD ('-', LENGTH (l_succ_recy_k), '-')
                              );
            fnd_file.put_line (fnd_file.output, '');
            l_printed := 'N';

            -- Display the contract details
            FOR i IN
               success_recy_message_table.FIRST .. success_recy_message_table.LAST
            LOOP
               -- Print Header only once
               IF l_printed = 'N' THEN
                  fnd_file.put_line (fnd_file.output,
                                        l_serial
                                     || RPAD (' ', 15 - LENGTH (l_serial),
                                              ' ')
                                     || l_k_num
                                     || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                                     || l_start_date
                                     || RPAD (' ',
                                              15 - LENGTH (l_start_date),
                                              ' '
                                             )
                                     || l_end_date
                                     || RPAD (' ',
                                              15 - LENGTH (l_end_date),
                                              ' '
                                             )
                                     || l_status
                                     || RPAD (' ', 15 - LENGTH (l_status),
                                              ' ')
                                    );
                  fnd_file.put_line (fnd_file.output,
                                        RPAD ('-', LENGTH (l_serial), '-')
                                     || RPAD (' ', 15 - LENGTH (l_serial),
                                              ' ')
                                     || RPAD ('-', LENGTH (l_k_num), '-')
                                     || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                                     || RPAD ('-', LENGTH (l_start_date), '-')
                                     || RPAD (' ',
                                              15 - LENGTH (l_start_date),
                                              ' '
                                             )
                                     || RPAD ('-', LENGTH (l_end_date), '-')
                                     || RPAD (' ',
                                              15 - LENGTH (l_end_date),
                                              ' '
                                             )
                                     || RPAD ('-', LENGTH (l_status), '-')
                                     || RPAD (' ', 15 - LENGTH (l_status),
                                              ' ')
                                    );
               END IF;

               l_printed := 'Y';
               fnd_file.put_line
                  (fnd_file.output,
                      i
                   || RPAD (' ', 15 - LENGTH (i), ' ')
                   || success_recy_message_table (i).contract_number
                   || RPAD
                         (' ',
                            35
                          - LENGTH
                                (success_recy_message_table (i).contract_number
                                ),
                          ' '
                         )
                   || success_recy_message_table (i).start_date
                   || RPAD (' ',
                              15
                            - LENGTH (success_recy_message_table (i).start_date
                                     ),
                            ' '
                           )
                   || success_recy_message_table (i).end_date
                   || RPAD (' ',
                              15
                            - LENGTH (success_recy_message_table (i).end_date),
                            ' '
                           )
                   || success_recy_message_table (i).status
                   || RPAD (' ',
                            15
                            - LENGTH (success_recy_message_table (i).status),
                            ' '
                           )
                  );
            END LOOP;
         END IF;
      ELSE                    -- p_source IS NOT NULL THEN -- rmunjulu 4016497
         fnd_file.put_line (fnd_file.output, '');
         fnd_file.put_line (fnd_file.output, l_exp_k_err);
         fnd_file.put_line (fnd_file.output,
                            RPAD ('-', LENGTH (l_exp_k_err), '-')
                           );
         fnd_file.put_line (fnd_file.output, '');
         fnd_file.put_line (fnd_file.output,
                               l_serial
                            || RPAD (' ', 15 - LENGTH (l_serial), ' ')
                            || l_k_num
                            || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                            || l_start_date
                            || RPAD (' ', 15 - LENGTH (l_start_date), ' ')
                            || l_end_date
                            || RPAD (' ', 15 - LENGTH (l_end_date), ' ')
                            || l_status
                            || RPAD (' ', 15 - LENGTH (l_status), ' ')
                           );
         fnd_file.put_line (fnd_file.output,
                               RPAD ('-', LENGTH (l_serial), '-')
                            || RPAD (' ', 15 - LENGTH (l_serial), ' ')
                            || RPAD ('-', LENGTH (l_k_num), '-')
                            || RPAD (' ', 35 - LENGTH (l_k_num), ' ')
                            || RPAD ('-', LENGTH (l_start_date), '-')
                            || RPAD (' ', 15 - LENGTH (l_start_date), ' ')
                            || RPAD ('-', LENGTH (l_end_date), '-')
                            || RPAD (' ', 15 - LENGTH (l_end_date), ' ')
                            || RPAD ('-', LENGTH (l_status), '-')
                            || RPAD (' ', 15 - LENGTH (l_status), ' ')
                           );
         fnd_file.put_line
                  (fnd_file.output,
                      '1'
                   || RPAD (' ', 14, ' ')
                   || error_exp_message_table (1).contract_number
                   || RPAD
                          (' ',
                             35
                           - LENGTH
                                   (error_exp_message_table (1).contract_number
                                   ),
                           ' '
                          )
                   || error_exp_message_table (1).start_date
                   || RPAD (' ',
                              15
                            - LENGTH (error_exp_message_table (1).start_date),
                            ' '
                           )
                   || error_exp_message_table (1).end_date
                   || RPAD (' ',
                            15 - LENGTH (error_exp_message_table (1).end_date),
                            ' '
                           )
                   || error_exp_message_table (1).status
                   || RPAD (' ',
                            15 - LENGTH (error_exp_message_table (1).status),
                            ' '
                           )
                  );
         -- Set message
         fnd_file.put_line (fnd_file.output, p_message);
      END IF;

      fnd_file.put_line (fnd_file.output, '');
      fnd_file.put_line (fnd_file.output, '');
      fnd_file.put_line (fnd_file.output, RPAD (' ', 53, ' ') || l_eop);

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
              IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => okc_api.g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END create_report;

   -- Start of comments
   --
   -- Procedure Name  : check_contract
   -- Desciption     : checks if contract termination was successful or failure
   -- Business Rules  :
   -- Parameters       :
   -- Version      : 1.0
   -- History        : RMUNJULU 2730738 created for proper output file
   --
   -- End of comments
   PROCEDURE check_contract (
      p_chr_id         IN              NUMBER,
      x_start_date     OUT NOCOPY      DATE,
      x_end_date       OUT NOCOPY      DATE,
      x_status         OUT NOCOPY      VARCHAR2,
      x_control_flag   OUT NOCOPY      VARCHAR2
   ) IS
      -- Get contract details
      CURSOR l_get_k_dtls_csr (p_chr_id IN NUMBER) IS
         SELECT CHR.start_date,
                CHR.end_date,
                CHR.sts_code
           FROM okc_k_headers_b CHR
          WHERE CHR.ID = p_chr_id;

      -- Get contract termination transaction which is not PROCESSED or CANCELED ie ERROR
      CURSOR l_get_k_trn_csr (p_chr_id IN NUMBER) IS
         SELECT trn.tmt_status_code status
           --akrangan changes for sla tmt_status_code cr
         FROM   okl_trx_contracts trn
          WHERE trn.khr_id = p_chr_id
            AND trn.tcn_type IN ('TMT', 'ALT')
           --rkuttiya added for 12.1.1 Multi GAAP
            AND trn.representation_type = 'PRIMARY'
          --
            AND trn.tmt_status_code NOT IN ('PROCESSED', 'CANCELED');

      --akrangan changes for sla tmt_status_code cr

      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                          := g_module_name || 'check_contract';
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
                                  'p_chr_id       =' || p_chr_id
                                 );
      END IF;

      x_control_flag := 'SUCCESS';

      -- Get K Details
      FOR l_get_k_dtls_rec IN l_get_k_dtls_csr (p_chr_id)
      LOOP
         x_start_date := l_get_k_dtls_rec.start_date;
         x_end_date := l_get_k_dtls_rec.end_date;
         x_status := l_get_k_dtls_rec.sts_code;

         -- If Non Processed/Non Canceled TRN exists then Error
         FOR l_get_k_trn_rec IN l_get_k_trn_csr (p_chr_id)
         LOOP
            x_control_flag := 'FAIL';
         END LOOP;
      END LOOP;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
              IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
         -- Set the oracle error message
         okl_api.set_message (p_app_name          => okc_api.g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END check_contract;

   -- Start of comments
   --
   -- Procedure Name  : check_if_quotes_existing
   -- Description     : procedure to check if accepted quotes exist for contract
   --                   being terminated
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   PROCEDURE check_if_quotes_existing (
      p_term_rec        IN              term_rec_type,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_quotes_found    OUT NOCOPY      VARCHAR2
   ) IS
      -- Check if Termination or Restructure Quotes Exists
      CURSOR k_quotes_csr (p_khr_id IN NUMBER) IS
         SELECT ID
           FROM okl_trx_quotes_v
          WHERE khr_id = p_khr_id
            AND qst_code = 'ACCEPTED'
            AND (qtp_code LIKE 'TER%' OR qtp_code LIKE 'RES%');

      l_return_status         VARCHAR2 (1)   := okl_api.g_ret_sts_success;
      l_id                    NUMBER;
      l_quotes_found          VARCHAR2 (1)   := 'N';
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                := g_module_name || 'check_if_quotes_existing';
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
                                     'p_term_rec.p_contract_id       ='
                                  || p_term_rec.p_contract_id
                                 );
      END IF;

      -- Check if Termination quotes or Restructure quotes exist
      OPEN k_quotes_csr (p_term_rec.p_contract_id);

      FETCH k_quotes_csr
       INTO l_id;

      IF k_quotes_csr%FOUND THEN
         l_quotes_found := 'Y';
      END IF;

      CLOSE k_quotes_csr;

      x_return_status := l_return_status;
      x_quotes_found := l_quotes_found;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
              IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
         IF k_quotes_csr%ISOPEN THEN
            CLOSE k_quotes_csr;
         END IF;

         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         x_return_status := okl_api.g_ret_sts_unexp_error;
   END check_if_quotes_existing;

   -- Start of comments
   --
   -- Procedure Name  : get_trn_rec
   -- Description     : procedure to get the transaction record for the contract
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- History         : RMUNJULU -- 26-NOV-02: Bug # 2484327 : Changed cursor to
   --                   get asset level termination transactions
   --                   RMUNJULU 17-DEC-02 Bug # 2484327: Added tmt_split_asset_yn
   --                   to cursor
   --                   RMUNJULU 02-OCT-03 2757312 Added tmt_generic_flag1_yn,
   --                   tmt_generic_flag2_yn, tmt_generic_flag3_yn to select
   -- End of comments
   PROCEDURE get_trn_rec (
      p_contract_id     IN              NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_trn_exists      OUT NOCOPY      VARCHAR2,
      x_tcnv_rec        OUT NOCOPY      tcnv_rec_type
   ) IS
      -- Cursor to get the termination transaction details for the contract

      -- RMUNJULU -- Bug # 2484327 : Added ALT to get asset level termination trns
      -- And tsu_code since a contract can have multiple transactions
      -- RMUNJULU 17-DEC-02 Bug # 2484327 Added tmt_split_asset_yn to cursor select
      CURSOR trn_rec_csr (p_khr_id IN NUMBER) IS
         SELECT ID,
                tcn_type,
                khr_id,
                try_id,
                tmt_status_code, --akrangan changes for sla tmt_status_code cr
                date_transaction_occurred,
                tmt_evergreen_yn,
                tmt_close_balances_yn,
                tmt_accounting_entries_yn,
                tmt_cancel_insurance_yn,
                tmt_asset_disposition_yn,
                tmt_amortization_yn,
                tmt_asset_return_yn,
                tmt_contract_updated_yn,
                tmt_recycle_yn,
                tmt_validated_yn,
                tmt_streams_updated_yn,
                tmt_split_asset_yn,
                tmt_generic_flag1_yn,                -- RMUNJULU 2757312 Added
                tmt_generic_flag2_yn,                -- RMUNJULU 2757312 Added
                tmt_generic_flag3_yn,                -- RMUNJULU 2757312 Added
                qte_id
           FROM okl_trx_contracts
          WHERE khr_id = p_khr_id
            AND tcn_type IN ('TMT', 'ALT', 'EVG')
            --rkuttiya added for 12.1.1. Multi GAAP
            AND representation_type = 'PRIMARY'
            --
            -- akrangan bug 5354501 fix  ADDED 'EVG'
            AND tmt_status_code NOT IN ('PROCESSED', 'CANCELED');

      --akrangan changes for sla tmt_status_Code cr
      lp_tcnv_rec             tcnv_rec_type;
      l_trn_exists            VARCHAR2 (1)   := 'N';
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500) := g_module_name || 'get_trn_rec';
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
                                  'p_contract_id       =' || p_contract_id
                                 );
      END IF;

      x_return_status := okl_api.g_ret_sts_success;

      -- set the trn_rec
      OPEN trn_rec_csr (p_contract_id);

      FETCH trn_rec_csr
       INTO lp_tcnv_rec.ID,
            lp_tcnv_rec.tcn_type,
            lp_tcnv_rec.khr_id,
            lp_tcnv_rec.try_id,
            lp_tcnv_rec.tmt_status_code,
            --akrangan changes for sla tmt_status_code cr
            lp_tcnv_rec.date_transaction_occurred,
            lp_tcnv_rec.tmt_evergreen_yn,
            lp_tcnv_rec.tmt_close_balances_yn,
            lp_tcnv_rec.tmt_accounting_entries_yn,
            lp_tcnv_rec.tmt_cancel_insurance_yn,
            lp_tcnv_rec.tmt_asset_disposition_yn,
            lp_tcnv_rec.tmt_amortization_yn,
            lp_tcnv_rec.tmt_asset_return_yn,
            lp_tcnv_rec.tmt_contract_updated_yn,
            lp_tcnv_rec.tmt_recycle_yn,
            lp_tcnv_rec.tmt_validated_yn,
            lp_tcnv_rec.tmt_streams_updated_yn,
            lp_tcnv_rec.tmt_split_asset_yn,
            --RMUNJULU 17-DEC-02 Bug # 2484327 Added
            lp_tcnv_rec.tmt_generic_flag1_yn,        -- RMUNJULU 2757312 Added
            lp_tcnv_rec.tmt_generic_flag2_yn,        -- RMUNJULU 2757312 Added
            lp_tcnv_rec.tmt_generic_flag3_yn,        -- RMUNJULU 2757312 Added
            lp_tcnv_rec.qte_id;

      IF trn_rec_csr%FOUND THEN
         l_trn_exists := 'Y';
      END IF;

      CLOSE trn_rec_csr;

      x_tcnv_rec := lp_tcnv_rec;
      x_trn_exists := l_trn_exists;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
              IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
         IF trn_rec_csr%ISOPEN THEN
            CLOSE trn_rec_csr;
         END IF;

         x_return_status := okl_api.g_ret_sts_error;
         x_tcnv_rec := lp_tcnv_rec;
         x_trn_exists := l_trn_exists;
   END get_trn_rec;

   -- Start of comments
   --
   -- Procedure Name  : get_trn_rec
   -- Description     : procedure to get the transaction record for the transaction id
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- History         : RMUNJULU 17-NOV-02: Bug # 2484327 : Created
   --                   RMUNJULU 20-DEC-02 2484327 Changed cursor to get trn_id
   --                   RMUNJULU 02-OCT-03 2757312 Added tmt_generic_flag1_yn,
   --                   tmt_generic_flag2_yn, tmt_generic_flag3_yn to select
   -- End of comments
   PROCEDURE get_trn_rec (
      p_trn_id          IN              NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_trn_exists      OUT NOCOPY      VARCHAR2,
      x_tcnv_rec        OUT NOCOPY      tcnv_rec_type
   ) IS
      -- Cursor to get the termination transaction details for the transaction id
      -- RMUNJULU 20-DEC-02 2484327 Changed cursor to get trn rec for trn_id not khr_id
      CURSOR trn_rec_csr (p_trn_id IN NUMBER) IS
         SELECT trx.ID,
                trx.tcn_type,
                trx.khr_id,
                trx.try_id,
                trx.tmt_status_code,
                trx.date_transaction_occurred,
                trx.tmt_evergreen_yn,
                trx.tmt_close_balances_yn,
                trx.tmt_accounting_entries_yn,
                trx.tmt_cancel_insurance_yn,
                trx.tmt_asset_disposition_yn,
                trx.tmt_amortization_yn,
                trx.tmt_asset_return_yn,
                trx.tmt_contract_updated_yn,
                trx.tmt_recycle_yn,
                trx.tmt_validated_yn,
                trx.tmt_streams_updated_yn,
                trx.tmt_split_asset_yn,
                trx.tmt_generic_flag1_yn,            -- RMUNJULU 2757312 Added
                trx.tmt_generic_flag2_yn,            -- RMUNJULU 2757312 Added
                trx.tmt_generic_flag3_yn,            -- RMUNJULU 2757312 Added
                trx.qte_id
           FROM okl_trx_contracts trx
          WHERE trx.ID = p_trn_id;

      lp_tcnv_rec             tcnv_rec_type;
      l_trn_exists            VARCHAR2 (1)   := 'N';
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500) := g_module_name || 'get_trn_rec';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      x_return_status := okl_api.g_ret_sts_success;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'p_trn_id       =' || p_trn_id
                                 );
      END IF;

      -- set the trn_rec
      OPEN trn_rec_csr (p_trn_id);

      FETCH trn_rec_csr
       INTO lp_tcnv_rec.ID,
            lp_tcnv_rec.tcn_type,
            lp_tcnv_rec.khr_id,
            lp_tcnv_rec.try_id,
            lp_tcnv_rec.tmt_status_code,
            --akrangan changes for sla tmt_status_code cr
            lp_tcnv_rec.date_transaction_occurred,
            lp_tcnv_rec.tmt_evergreen_yn,
            lp_tcnv_rec.tmt_close_balances_yn,
            lp_tcnv_rec.tmt_accounting_entries_yn,
            lp_tcnv_rec.tmt_cancel_insurance_yn,
            lp_tcnv_rec.tmt_asset_disposition_yn,
            lp_tcnv_rec.tmt_amortization_yn,
            lp_tcnv_rec.tmt_asset_return_yn,
            lp_tcnv_rec.tmt_contract_updated_yn,
            lp_tcnv_rec.tmt_recycle_yn,
            lp_tcnv_rec.tmt_validated_yn,
            lp_tcnv_rec.tmt_streams_updated_yn,
            lp_tcnv_rec.tmt_split_asset_yn,
            lp_tcnv_rec.tmt_generic_flag1_yn,        -- RMUNJULU 2757312 Added
            lp_tcnv_rec.tmt_generic_flag2_yn,        -- RMUNJULU 2757312 Added
            lp_tcnv_rec.tmt_generic_flag3_yn,        -- RMUNJULU 2757312 Added
            lp_tcnv_rec.qte_id;

      IF trn_rec_csr%FOUND THEN
         l_trn_exists := 'Y';
      END IF;

      CLOSE trn_rec_csr;

      x_tcnv_rec := lp_tcnv_rec;
      x_trn_exists := l_trn_exists;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
              IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
         IF trn_rec_csr%ISOPEN THEN
            CLOSE trn_rec_csr;
         END IF;

         x_return_status := okl_api.g_ret_sts_error;
         x_tcnv_rec := lp_tcnv_rec;
         x_trn_exists := l_trn_exists;
   END get_trn_rec;

   -- Start of comments
   --
   -- Procedure Name  : process_termination
   -- Description     : procedure which calls lease_loan_termination api after checks
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- History         : RMUNJULU 17-NOV-02 Bug # 2484327 : Added parameter p_trn_id
   --                   Changed logic to call the new get_trn_rec based on trn_id
   --                   if trn_id is passed
   -- End of comments
   PROCEDURE process_termination (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okl_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_term_rec        IN              term_rec_type,
      p_trn_id          IN              NUMBER DEFAULT NULL,
      --RMUNJULU 17-NOV-02: Bug # 2484327 Added
      x_tcnv_rec        OUT NOCOPY      tcnv_rec_type,
      x_term_rec        OUT NOCOPY      term_rec_type
   ) IS
      lp_term_rec             term_rec_type          := p_term_rec;
      lx_term_rec             term_rec_type;
      lp_tcnv_rec             tcnv_rec_type;
      lx_tcnv_rec             tcnv_rec_type;
      l_quotes_found          VARCHAR2 (1)           := 'N';
      l_return_status         VARCHAR2 (1)       := okl_api.g_ret_sts_success;
      l_trn_exists            VARCHAR2 (1);
      lx_error_rec            okl_api.error_rec_type;
      l_msg_idx               INTEGER                := fnd_msg_pub.g_first;
      l_quote_type            VARCHAR2 (200);
      l_quote_reason          VARCHAR2 (200);
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                    := g_module_name || 'process_termination';
      is_debug_exception_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
             := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      okl_api.init_msg_list (p_init_msg_list);

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure,
                                  l_module_name,
                                  'Begin(+)'
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
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
                                  'In param, p_term_rec.p_contract_modifier: '
                               || p_term_rec.p_contract_modifier
                              );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_orig_end_date: '
                                  || p_term_rec.p_orig_end_date
                                 );
         okl_debug_pub.log_debug
                               (g_level_statement,
                                l_module_name,
                                   'In param, p_term_rec.p_contract_version: '
                                || p_term_rec.p_contract_version
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
                                 'In param, p_term_rec.p_termination_reason: '
                              || p_term_rec.p_termination_reason
                             );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_id: '
                                  || p_term_rec.p_quote_id
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_type: '
                                  || p_term_rec.p_quote_type
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_quote_reason: '
                                  || p_term_rec.p_quote_reason
                                 );
         okl_debug_pub.log_debug
                           (g_level_statement,
                            l_module_name,
                               'In param, p_term_rec.p_early_termination_yn: '
                            || p_term_rec.p_early_termination_yn
                           );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_control_flag: '
                                  || p_term_rec.p_control_flag
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'In param, p_term_rec.p_recycle_flag: '
                                  || p_term_rec.p_recycle_flag
                                 );
      END IF;

      -- RMUNJULU 17-NOV-02 Bug # 2484327 Added the if condition
      -- If the p_trn_id is passed then from recycle
      IF p_trn_id IS NOT NULL AND p_trn_id <> okl_api.g_miss_num THEN
         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'Before get_trn_rec In param, p_trn_id: '
                                 || p_trn_id
                                );
         END IF;

         -- Get transaction rec
         get_trn_rec (p_trn_id             => p_trn_id,
                      x_return_status      => l_return_status,
                      x_trn_exists         => l_trn_exists,
                      x_tcnv_rec           => lp_tcnv_rec
                     );

         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug
                          (g_level_statement,
                           l_module_name,
                              'After get_trn_rec In param, l_return_status: '
                           || l_return_status
                          );
         END IF;
      ELSE
         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'Before get_trn_rec In param, p_trn_id: '
                                 || p_trn_id
                                );
         END IF;

         -- Get transaction if exists
         get_trn_rec (p_contract_id        => lp_term_rec.p_contract_id,
                      x_return_status      => l_return_status,
                      x_trn_exists         => l_trn_exists,
                      x_tcnv_rec           => lp_tcnv_rec
                     );

         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug
                                   (g_level_statement,
                                    l_module_name,
                                       'After get_trn_rec  l_return_status: '
                                    || l_return_status
                                   );
         END IF;
      END IF;

      -- If error then abort this contract
      IF (l_return_status <> okl_api.g_ret_sts_success) THEN
         -- Error retrieving transactions for the contract CONTRACT_NUMBER.
         okl_api.set_message (p_app_name          => 'OKL',
                              p_msg_name          => 'OKL_AM_ERR_GETTING_TRN',
                              p_token1            => 'CONTRACT_NUMBER',
                              p_token1_value      => p_term_rec.p_contract_number
                             );
         RAISE g_exception_halt;
      END IF;

      -- If trn exists then set the out tcnv_rec
      -- (have to do this or else tcnv_rec set wrong)
      IF (l_trn_exists = 'Y') THEN
         lx_tcnv_rec := lp_tcnv_rec;
         -- Also set the qte_id of term_Rec
         lp_term_rec.p_quote_id := lx_tcnv_rec.qte_id;
      ELSE
         lx_tcnv_rec.ID := okl_api.g_miss_num;
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                     'After get_trn_rec l_return_status: '
                                  || l_return_status
                                 );
      END IF;

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
             (g_level_statement,
              l_module_name,
                 'before OKL_AM_LEASE_LOAN_TRMNT_PUB.lease_loan_termination '
              || l_return_status
             );
      END IF;

      -- Call the lease loan terminate api
      okl_am_lease_loan_trmnt_pub.lease_loan_termination
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => okl_api.g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_term_rec           => lp_term_rec,
                                           p_tcnv_rec           => lx_tcnv_rec
                                          );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug
            (g_level_statement,
             l_module_name,
                'After OKL_AM_LEASE_LOAN_TRMNT_PUB.lease_loan_termination  l_return_status: '
             || l_return_status
            );
      END IF;

/* RMUNJULU 2730738
    -- Add couple of blank lines
    fnd_file.put_line(fnd_file.log, '');
    fnd_file.put_line(fnd_file.output, '');
    fnd_file.put_line(fnd_file.log, '');
    fnd_file.put_line(fnd_file.output, '');

    -- Get the messages in the log
    LOOP

         fnd_msg_pub.get(
              p_msg_index     => l_msg_idx,
                p_encoded       => FND_API.G_FALSE,
                p_data          => lx_error_rec.msg_data,
                p_msg_index_out => lx_error_rec.msg_count);

            IF (lx_error_rec.msg_count IS NOT NULL) THEN

            fnd_file.put_line(fnd_file.log,  lx_error_rec.msg_data);
            fnd_file.put_line(fnd_file.output,  lx_error_rec.msg_data);

         END IF;

            EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
            OR (lx_error_rec.msg_count IS NULL));

            l_msg_idx   := FND_MSG_PUB.G_NEXT;
      END LOOP;
*/

      -- If error then abort this contract
      IF (l_return_status <> okl_api.g_ret_sts_success) THEN
         RAISE g_exception_halt;
      END IF;

      x_return_status := l_return_status;
      x_term_rec := lp_term_rec;
      x_tcnv_rec := lx_tcnv_rec;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN g_exception_halt THEN
              IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'G_EXCEPTION_HALT');
        END IF;
         x_return_status := l_return_status;
         x_term_rec := lp_term_rec;
         x_tcnv_rec := lx_tcnv_rec;
      WHEN OTHERS THEN
              IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
         x_return_status := l_return_status;
         x_term_rec := lp_term_rec;
         x_tcnv_rec := lx_tcnv_rec;
   END process_termination;

   -- Start of comments
   --
   -- Procedure Name  : batch_expire_lease_loan
   -- Description     : procedure to terminate the contract in batch process
   --                   checks if any open quotes for the contract and if not then calls
   --                   lease_loan_terminate api to terminate the lease/loan
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- History         : RMUNJULU -- 26-NOV-02: Bug # 2484327 : Changed cursor
   --                   ter_cnt_recy_csr to get asset level termination trns
   --                   Changed cursor ter_cnt_csr asset level termination trns
   --                 : RMUNJULU 17-NOV-02 Bug # 2484327 Added trn_id to cursor
   --                 : RMUNJULU 20-DEC-02 2484327 Changed ter_cnt_csr cursor
   --                 : RMUNJULU 23-DEC-02 2484327 Changed ter_cnt_csr cursor
   --                   to get the correct data
   --                 : RMUNJULU 25-FEB-03 2818866 Changed ter_cnt_recy_csr cursor
   --                 : RMUNJULU 05-MAR-03 Performance Fix Replaced K_HDR_FULL
   --                 : rmunjulu 01-Dec-04 4016497 Added code to do processing when single K
   -- End of comments
   PROCEDURE batch_expire_lease_loan (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okl_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_contract_id     IN              NUMBER DEFAULT okl_api.g_miss_num,
      x_term_tbl        OUT NOCOPY      term_tbl_type
   ) IS
      -- Get the contract details for contract number passed
      -- RMUNJULU 05-MAR-03 Performance Fix Replaced K_HDR_FULL
      CURSOR single_k_csr (p_khr_id IN NUMBER) IS
         SELECT k.contract_number
           FROM okc_k_headers_v k
          WHERE k.ID = p_khr_id;

      -- rmunjulu Added for bug 4385077 to do org strip

      --Pick Contracts which have reached their end date and booked
      --and only Lease or Loan and no termination transaction with status
      --other than cancelled exists and no accepted quotes exists
      --and non templates

      -- RMUNJULU -- Bug # 2484327 : Changed to check tsu_code not in PROCESSED or
      -- CANCELED. Also the Accepted quote is checked using the QST_CODE instead of
      -- accepted_yn flag

      -- RMUNJULU 20-DEC-02 2484327
      -- Changed the cursor to get the contracts which have reached the end date
      -- and which do not have unprocessed transactions and also which do not have
      -- accepted quotes with no transactions
      -- RMUNJULU 23-DEC-02 2484327
      -- Added NVLs to get the correct data
      -- RMUNJULU 05-MAR-03 Performance Fix Replaced K_HDR_FULL
      CURSOR ter_cnt_csr (p_sysdate IN DATE) IS
         SELECT khr.ID,
                khr.contract_number
           FROM okc_k_headers_v khr
          WHERE TRUNC (khr.end_date) < TRUNC (p_sysdate)
            AND NVL (khr.sts_code, '?') IN ('BOOKED')
            AND khr.scs_code IN ('LEASE', 'LOAN')
            AND khr.ID NOT IN (
                   -- Contracts which have unprocessed transactions
                   SELECT NVL (tcn.khr_id, -9999) khr_id
                     FROM okl_trx_contracts tcn
                    WHERE NVL (tcn.tcn_type, '?') IN ('TMT', 'ALT', 'EVG')
                      -- akrangan bug 5354501 fix added 'EVG'
                      AND tcn.tmt_status_code NOT IN
                                                    ('CANCELED', 'PROCESSED')
                      --rkuttiya added for 12.1.1 Multi GAAP
                      AND tcn.representation_type = 'PRIMARY'
                      --
                      --akrangan changed for sla tmt_status_Code cr
                      AND tcn.khr_id = khr.ID)                -- rmunjulu PERF
            AND khr.ID NOT IN (
                   -- Contracts which have accepted quotes with no transactions
                   SELECT NVL (qte.khr_id, -9999) khr_id
                     FROM okl_trx_quotes_v qte
                    WHERE NVL (qte.accepted_yn, 'N') = 'Y'
                      AND NVL (qte.consolidated_yn, 'N') = 'N'
                      AND qte.khr_id = khr.ID                 -- rmunjulu PERF
                      AND qte.ID NOT IN (
                             SELECT NVL (tcn.qte_id, -9999) qte_id
                               FROM okl_trx_contracts tcn
                              WHERE NVL (tcn.tcn_type, '?') IN
                                                        ('TMT', 'ALT', 'EVG')
                                --rkuttiya added for 12.1.1 Multi GAAP
                                AND tcn.representation_type = 'PRIMARY'
                                --
                                -- akrangan bug 5354501 fix added 'EVG'
                                AND tcn.qte_id = qte.ID));    -- rmunjulu PERF

      -- rmunjulu Added for bug 4385077 to do org strip

      -- Pick Contracts set for recycle and booked and only Lease or Loan

      -- RMUNJULU -- Bug # 2484327 : Added ALT to get asset level termination trns
      -- And check tsu_code not in CANCELED along with PROCESSED
      -- RMUNJULU 17-NOV-02 Bug # 2484327 Added trn_id to cursor select
      -- RMUNJULU 25-FEB-03 2818866 Changed cursor to NON BOOKED contracts
      -- since a quote can be created and TRN recycled for other types of contracts
      -- like EVERGREEN etc
      -- RMUNJULU 05-MAR-03 Performance Fix Replaced K_HDR_FULL
      CURSOR ter_cnt_recy_csr (p_sysdate IN DATE) IS
         SELECT k.ID,
                k.contract_number,
                t.ID trn_id          -- RMUNJULU 17-NOV-02 Bug # 2484327 Added
           FROM okc_k_headers_v k, okl_trx_contracts t
          WHERE NVL (t.tmt_recycle_yn, '?') = 'Y'
            AND NVL (t.tmt_status_code, '?') NOT IN ('PROCESSED', 'CANCELED')
           --rkuttiya added for 12.1.1 Multi GAAP
            AND t.representation_type = 'PRIMARY'
           --
            --akrangan changed for sla tmt_status_Code cr
            AND NVL (t.tcn_type, '?') IN ('TMT', 'ALT', 'EVG')
                                       -- akrangan bug 5354501 fix added 'EVG'
            --AND     NVL(K.sts_code,'?') IN('BOOKED')
            AND k.scs_code IN ('LEASE', 'LOAN')
            AND k.ID = t.khr_id;

      -- rmunjulu Added for bug 4385077 to do org strip

      -- rmunjulu 4016497
      -- Cursor to check if contract has expired and no unprocessed trn
      -- and no accepted quotes.
      CURSOR exp_chr_csr (p_khr_id IN NUMBER, p_sysdate IN DATE) IS
         SELECT khr.ID,
                khr.contract_number
           FROM okc_k_headers_v khr
          WHERE khr.ID = p_khr_id
            AND TRUNC (khr.end_date) < TRUNC (p_sysdate)
            AND NVL (khr.sts_code, '?') IN ('BOOKED')
            AND khr.scs_code IN ('LEASE', 'LOAN')
            AND khr.ID NOT IN (
                   -- Contracts which have unprocessed transactions
                   SELECT NVL (tcn.khr_id, -9999) khr_id
                     FROM okl_trx_contracts tcn
                    WHERE NVL (tcn.tcn_type, '?') IN ('TMT', 'ALT', 'EVG')
                      -- akrangan bug 5354501 fix added 'EVG'
                      AND tcn.tmt_status_code NOT IN
                                                    ('CANCELED', 'PROCESSED')
                      --akrangan changed for sla tmt_status_Code cr
                      --rkuttiya added for 12.1.1 Multi GAAP
                      AND tcn.representation_type = 'PRIMARY'
                      AND tcn.khr_id = khr.ID)                -- rmunjulu PERF
            AND khr.ID NOT IN (
                   -- Contracts which have accepted quotes with no transactions
                   SELECT NVL (qte.khr_id, -9999) khr_id
                     FROM okl_trx_quotes_v qte
                    WHERE NVL (qte.accepted_yn, 'N') = 'Y'
                      AND NVL (qte.consolidated_yn, 'N') = 'N'
                      AND qte.khr_id = khr.ID                 -- rmunjulu PERF
                      AND qte.ID NOT IN (
                             SELECT NVL (tcn.qte_id, -9999) qte_id
                               FROM okl_trx_contracts tcn
                              WHERE NVL (tcn.tcn_type, '?') IN
                                                        ('TMT', 'ALT', 'EVG')
                                -- akrangan bug 5354501 fix added 'EVG'
                                --rkuttiya added for 12.1.1. Multi GAAP
                                AND representation_type = 'PRIMARY'
                                --
                                AND tcn.qte_id = qte.ID));    -- rmunjulu PERF

      -- rmunjulu Added for bug 4385077 to do org strip

      -- rmunjulu 4016497
      -- Cursor to get the recycled termination transaction of contract if exists
      CURSOR recy_chr_csr (p_khr_id IN NUMBER, p_sysdate IN DATE) IS
         SELECT k.ID,
                k.contract_number,
                t.ID trn_id
           FROM okc_k_headers_v k, okl_trx_contracts t
          WHERE k.ID = p_khr_id
            AND NVL (t.tmt_recycle_yn, '?') = 'Y'
            AND NVL (t.tmt_status_code, '?') NOT IN ('PROCESSED', 'CANCELED')
            --akrangan changed for sla tmt_status_Code cr
            AND NVL (t.tcn_type, '?') IN ('TMT', 'ALT', 'EVG')
            -- akrangan bug 5354501 fix added 'EVG'
            AND k.scs_code IN ('LEASE', 'LOAN')
            --rkuttiya added for 12.1.1 Multi GAAP
            AND t.representation_type = 'PRIMARY'
            --
            AND k.ID = t.khr_id;

      -- rmunjulu Added for bug 4385077 to do org strip

      -- rmunjulu LOANS_ENHANCEMENTS
      CURSOR k_details_csr (p_khr_id IN NUMBER) IS
         SELECT deal_type
           FROM okl_k_headers
          WHERE ID = p_khr_id;

      lp_term_rec             term_rec_type;
      lx_term_rec             term_rec_type;
      lx_term_tbl             term_tbl_type;
      lp_tcnv_rec             tcnv_rec_type;
      lx_tcnv_rec             tcnv_rec_type;
      db_sysdate              DATE;
      i                       NUMBER                 := 1;
      j                       NUMBER                 := 1;
      l_chr_id                NUMBER;
      l_return_status         VARCHAR2 (1)        := okl_api.g_ret_sts_success;
      l_api_name              VARCHAR2 (200)      := 'batch_expire_lease_loan';
      l_overall_status        VARCHAR2 (1)        := okl_api.g_ret_sts_success;
      -- RMUNJULU 2730738
      l_start_date            DATE;
      l_end_date              DATE;
      l_status                VARCHAR2 (200);
      l_control_flag          VARCHAR2 (10);
      -- rmunjulu 4016497
      exp_chr_rec             exp_chr_csr%ROWTYPE;
      recy_chr_rec            recy_chr_csr%ROWTYPE;
      l_exp_chr_yn            VARCHAR2 (3);
      l_recy_chr_yn           VARCHAR2 (3);
      l_message               VARCHAR2 (30000);
      -- rmunjulu LOANS_ENHANCEMENTS
      l_prin_bal              NUMBER                 := 0;
      l_deal_type             VARCHAR2 (300);
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)  := g_module_name || 'fnd_output';
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
                                  'p_contract_id       =' || p_contract_id
                                 );
      END IF;

      x_return_status := okl_api.g_ret_sts_success;

      SELECT SYSDATE
        INTO db_sysdate
        FROM DUAL;

      -- Check if value passed for contract number
      IF p_contract_id IS NOT NULL AND p_contract_id <> okl_api.g_miss_num THEN
         FOR single_k_rec IN single_k_csr (p_contract_id)
         LOOP
            -- set the term_rec_type of terminate_contract
            lp_term_rec.p_contract_id := p_contract_id;
            lp_term_rec.p_contract_number := single_k_rec.contract_number;
            lp_term_rec.p_termination_date := db_sysdate;
            lp_term_rec.p_control_flag := 'BATCH_PROCESS';

            -- rmunjulu 4016497
            -- check if contract expired
            OPEN exp_chr_csr (p_contract_id, db_sysdate);

            FETCH exp_chr_csr
             INTO exp_chr_rec;

            IF exp_chr_csr%FOUND THEN
               l_exp_chr_yn := 'Y';
            END IF;

            CLOSE exp_chr_csr;

            -- rmunjulu 4016497
            -- check if contract recycled
            OPEN recy_chr_csr (p_contract_id, db_sysdate);

            FETCH recy_chr_csr
             INTO recy_chr_rec;

            IF recy_chr_csr%FOUND THEN
               l_recy_chr_yn := 'Y';
            END IF;

            CLOSE recy_chr_csr;

            -- rmunjulu 4016497
            IF NVL (l_exp_chr_yn, 'N') = 'Y' THEN      -- Contract has expired
               -- rmunjulu LOANS_ENHANCEMENTS
               OPEN k_details_csr (lp_term_rec.p_contract_id);

               FETCH k_details_csr
                INTO l_deal_type;

               CLOSE k_details_csr;

               -- rmunjulu LOANS_ENHANCEMENTS
               IF l_deal_type LIKE 'LOAN%' THEN
                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'Before OKL_VARIABLE_INT_UTIL_PVT.get_principal_bal '
                        );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'In param, p_contract_id: '
                                              || lp_term_rec.p_contract_id
                                             );
                  END IF;

                  -- get principal balance of loan contract
                  l_prin_bal :=
                     okl_variable_int_util_pvt.get_principal_bal
                                       (x_return_status      => l_return_status,
                                        p_khr_id             => lp_term_rec.p_contract_id,
                                        p_kle_id             => NULL,
                                        p_date               => SYSDATE
                                       );

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'After OKL_VARIABLE_INT_UTIL_PVT.get_principal_bal '
                        );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'l_prin_bal: ' || l_prin_bal
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'l_return_status: '
                                              || l_return_status
                                             );
                  END IF;
               END IF;

               -- rmunjulu LOANS_ENHANCEMENTS
               IF NVL (l_prin_bal, 0) <= 0 THEN
                                   -- rmunjulu 5058848 check for prin bal <= 0
                  -- set the out tbl
                  lx_term_tbl (i).p_contract_id := lp_term_rec.p_contract_id;
                  lx_term_tbl (i).p_contract_number :=
                                                lp_term_rec.p_contract_number;

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'Before process_termination'
                                             );
                     okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
                     okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
                  END IF;

                  process_termination (p_api_version        => p_api_version,
                                       p_init_msg_list      => okl_api.g_true,
                                       x_return_status      => l_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_term_rec           => lp_term_rec,
                                       x_tcnv_rec           => lx_tcnv_rec,
                                       x_term_rec           => lx_term_rec
                                      );

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'After process_termination '
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'l_return_status: '
                                              || l_return_status
                                             );
                  END IF;

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'Before check_contract'
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'In param, p_contract_id: '
                                              || lp_term_rec.p_contract_id
                                             );
                  END IF;

                  -- RMUNJULU 2730738 For proper output file
                  check_contract (p_chr_id            => lp_term_rec.p_contract_id,
                                  x_start_date        => l_start_date,
                                  x_end_date          => l_end_date,
                                  x_status            => l_status,
                                  x_control_flag      => l_control_flag
                                 );

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'After check_contract '
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'x_start_date: ' || l_start_date
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'x_end_date: ' || l_end_date
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'x_status: ' || l_status
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'x_control_flag: '
                                              || l_control_flag
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'l_return_status: '
                                              || l_return_status
                                             );
                  END IF;

                  -- RMUNJULU 2730738 For proper output file
                  fnd_output (p_chr_id            => lp_term_rec.p_contract_id,
                              p_chr_number        => lp_term_rec.p_contract_number,
                              p_start_date        => l_start_date,
                              p_end_date          => l_end_date,
                              p_status            => l_status,
                              p_exp_recy          => 'EXP',
                              p_control_flag      => l_control_flag
                             );

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'After fnd_output '
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'l_return_status: '
                                              || l_return_status
                                             );
                  END IF;

                  -- RMUNJULU 2730738 For proper output file
                  reset_asset_msg_tbl;
                  -- set the out tbl termination date
                  lx_term_tbl (i) := lx_term_rec;

                  -- update the overall status only if l_return_status is not success
                  IF (l_return_status <> okl_api.g_ret_sts_success) THEN
                     l_overall_status := l_return_status;
                  END IF;

                  -- rmunjulu 4016497
                  create_report;
               ELSE
                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'Before check_contract'
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'In param, p_contract_id: '
                                              || lp_term_rec.p_contract_id
                                             );
                  END IF;

                  -- RMUNJULU 2730738 For proper output file
                  check_contract (p_chr_id            => lp_term_rec.p_contract_id,
                                  x_start_date        => l_start_date,
                                  x_end_date          => l_end_date,
                                  x_status            => l_status,
                                  x_control_flag      => l_control_flag
                                 );

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'After check_contract '
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'x_start_date: ' || l_start_date
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'x_end_date: ' || l_end_date
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'x_status: ' || l_status
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'x_control_flag: '
                                              || l_control_flag
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'l_return_status: '
                                              || l_return_status
                                             );
                  END IF;

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'Before fnd_output '
                                             );
                     okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
                     okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
                  END IF;

                  -- RMUNJULU 2730738 For proper output file
                  fnd_output (p_chr_id            => lp_term_rec.p_contract_id,
                              p_chr_number        => lp_term_rec.p_contract_number,
                              p_start_date        => l_start_date,
                              p_end_date          => l_end_date,
                              p_status            => l_status,
                              p_exp_recy          => 'EXP',
                              p_control_flag      => 'FAIL'
                             );

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                              'After fnd_output '
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'l_return_status: '
                                              || l_return_status
                                             );
                  END IF;

                  -- RMUNJULU 2730738 For proper output file
                  reset_asset_msg_tbl;
                  g_prin_bal_zero := 'Y';
                  create_report;
               END IF;
            ELSIF NVL (l_recy_chr_yn, 'N') = 'Y' THEN
               -- Contract has been recycled
               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'Before process_termination'
                                          );
                  okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
                  okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
               END IF;

               process_termination (p_api_version        => p_api_version,
                                    p_init_msg_list      => okl_api.g_true,
                                    x_return_status      => l_return_status,
                                    x_msg_count          => x_msg_count,
                                    x_msg_data           => x_msg_data,
                                    p_term_rec           => lp_term_rec,
                                    p_trn_id             => recy_chr_rec.trn_id,
                                    x_tcnv_rec           => lx_tcnv_rec,
                                    x_term_rec           => lx_term_rec
                                   );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After process_termination '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'Before check_contract'
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_contract_id: '
                                           || lp_term_rec.p_contract_id
                                          );
               END IF;

               -- RMUNJULU 2730738 For proper output file
               check_contract (p_chr_id            => lp_term_rec.p_contract_id,
                               x_start_date        => l_start_date,
                               x_end_date          => l_end_date,
                               x_status            => l_status,
                               x_control_flag      => l_control_flag
                              );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After check_contract '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_start_date: ' || l_start_date
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_end_date: ' || l_end_date
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_status: ' || l_status
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_control_flag: '
                                           || l_control_flag
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'Before fnd_output '
                                          );
                  okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
                  okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
               END IF;

               -- RMUNJULU 2730738 For proper output file
               fnd_output (p_chr_id            => lp_term_rec.p_contract_id,
                           p_chr_number        => lp_term_rec.p_contract_number,
                           p_start_date        => l_start_date,
                           p_end_date          => l_end_date,
                           p_status            => l_status,
                           p_exp_recy          => 'RECY',
                           p_control_flag      => l_control_flag
                          );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After fnd_output '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;

               -- RMUNJULU 2730738 For proper output file
               reset_asset_msg_tbl;
               -- set the out tbl termination date
               lx_term_tbl (i) := lx_term_rec;

               -- update the overall status only if l_return_status is not success
               IF (l_return_status <> okl_api.g_ret_sts_success) THEN
                  l_overall_status := l_return_status;
               END IF;

               -- rmunjulu 4016497
               create_report;
            ELSE
               -- Either the contract is invalid or contract has not reached its end date
                          -- or there is no recycled termination transaction for the contract.

               -- Set the message
               fnd_message.set_name ('OKL', 'OKL_AM_BTCH_ERR');
               -- Get the message
               l_message := fnd_message.get;

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'Before check_contract'
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_contract_id: '
                                           || lp_term_rec.p_contract_id
                                          );
               END IF;

               -- RMUNJULU 2730738 For proper output file
               check_contract (p_chr_id            => lp_term_rec.p_contract_id,
                               x_start_date        => l_start_date,
                               x_end_date          => l_end_date,
                               x_status            => l_status,
                               x_control_flag      => l_control_flag
                              );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After check_contract '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_start_date: ' || l_start_date
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_end_date: ' || l_end_date
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_status: ' || l_status
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_control_flag: '
                                           || l_control_flag
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'Before fnd_output '
                                          );
                  okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
                  okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
               END IF;

               -- RMUNJULU 2730738 For proper output file
               fnd_output (p_chr_id            => lp_term_rec.p_contract_id,
                           p_chr_number        => lp_term_rec.p_contract_number,
                           p_start_date        => l_start_date,
                           p_end_date          => l_end_date,
                           p_status            => l_status,
                           p_exp_recy          => 'RECY',
                           p_control_flag      => NULL
                          );  -- Pass NULL so that it goes to ELSE of this API

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After fnd_output '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;

               -- rmunjulu 4016497
               create_report (p_source => 'NOTNULL', p_message => l_message);
            END IF;

            -- increment i
            i := i + 1;
         END LOOP;
      ELSE                            -- no value passed for p contract number
/* RMUNJULU 2730738
       fnd_file.put_line(fnd_file.log, '');
       fnd_file.put_line(fnd_file.output, '');
       fnd_file.put_line(fnd_file.log, 'Processing the expired contracts.');
       fnd_file.put_line(fnd_file.output, 'Processing the expired contracts.');
       fnd_file.put_line(fnd_file.log, '');
       fnd_file.put_line(fnd_file.output, '');
*/    -- for leases/loans whose end date is less than today and which are not already
      -- terminated call the lease_loan_terminate api
         FOR ter_cnt_rec IN ter_cnt_csr (db_sysdate)
         LOOP
            -- set the term_rec_type of terminate_contract
            lp_term_rec.p_contract_id := ter_cnt_rec.ID;
            lp_term_rec.p_contract_number := ter_cnt_rec.contract_number;
            lp_term_rec.p_termination_date := db_sysdate;
            lp_term_rec.p_control_flag := 'BATCH_PROCESS';

            -- rmunjulu LOANS_ENHANCEMENTSS
            OPEN k_details_csr (lp_term_rec.p_contract_id);

            FETCH k_details_csr
             INTO l_deal_type;

            CLOSE k_details_csr;

            -- rmunjulu LOANS_ENHANCEMENTS
            IF l_deal_type LIKE 'LOAN%' THEN
               -- get principal balance of loan contract
               l_prin_bal :=
                  okl_variable_int_util_pvt.get_principal_bal
                                      (x_return_status      => l_return_status,
                                       p_khr_id             => lp_term_rec.p_contract_id,
                                       p_kle_id             => NULL,
                                       p_date               => SYSDATE
                                      );
            END IF;

            -- rmunjulu LOANS_ENHANCEMENTS
            IF NVL (l_prin_bal, 0) <= 0 THEN
                                   -- rmunjulu 5058848 check for prin bal <= 0
               -- set the out tbl
               lx_term_tbl (i).p_contract_id := lp_term_rec.p_contract_id;
               lx_term_tbl (i).p_contract_number :=
                                                lp_term_rec.p_contract_number;

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'Before process_termination'
                                          );
                  okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
                  okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
               END IF;

               process_termination (p_api_version        => p_api_version,
                                    p_init_msg_list      => okl_api.g_true,
                                    x_return_status      => l_return_status,
                                    x_msg_count          => x_msg_count,
                                    x_msg_data           => x_msg_data,
                                    p_term_rec           => lp_term_rec,
                                    x_tcnv_rec           => lx_tcnv_rec,
                                    x_term_rec           => lx_term_rec
                                   );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After process_termination '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;

               -- RMUNJULU 2730738  For proper output file
               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'Before check_contract'
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'In param, p_contract_id: '
                                           || lp_term_rec.p_contract_id
                                          );
               END IF;

               check_contract (p_chr_id            => lp_term_rec.p_contract_id,
                               x_start_date        => l_start_date,
                               x_end_date          => l_end_date,
                               x_status            => l_status,
                               x_control_flag      => l_control_flag
                              );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After check_contract '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_start_date: ' || l_start_date
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_end_date: ' || l_end_date
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_status: ' || l_status
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'x_control_flag: '
                                           || l_control_flag
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'Before fnd_output '
                                          );
                  okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
                  okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
               END IF;

               -- RMUNJULU 2730738 For proper output file
               fnd_output (p_chr_id            => lp_term_rec.p_contract_id,
                           p_chr_number        => lp_term_rec.p_contract_number,
                           p_start_date        => l_start_date,
                           p_end_date          => l_end_date,
                           p_status            => l_status,
                           p_exp_recy          => 'EXP',
                           p_control_flag      => l_control_flag
                          );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After fnd_output '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;

               -- RMUNJULU 2730738 For proper output file
               reset_asset_msg_tbl;
               -- set the out tbl termination date
               lx_term_tbl (i) := lx_term_rec;

               -- update the overall status only if l_return_status is not success
               IF (l_return_status <> okl_api.g_ret_sts_success) THEN
                  l_overall_status := l_return_status;
               END IF;

               -- increment i
               i := i + 1;
            END IF;
         END LOOP;

/* RMUNJULU 2730738
       fnd_file.put_line(fnd_file.log, '');
       fnd_file.put_line(fnd_file.output, '');
       fnd_file.put_line(fnd_file.log, 'Processing the recycled termination transactions.');
       fnd_file.put_line(fnd_file.output, 'Processing the recycled termination transactions.');
       fnd_file.put_line(fnd_file.log, '');
       fnd_file.put_line(fnd_file.output, '');
*/    -- for leases/loans which have been recycled call the
      -- lease_loan_termination api
         FOR ter_cnt_recy_rec IN ter_cnt_recy_csr (db_sysdate)
         LOOP
            -- set the term_rec_type of terminate_contract
            lp_term_rec.p_contract_id := ter_cnt_recy_rec.ID;
            lp_term_rec.p_contract_number := ter_cnt_recy_rec.contract_number;
            lp_term_rec.p_termination_date := db_sysdate;
            lp_term_rec.p_control_flag := 'BATCH_PROCESS';
            -- set the out tbl
            lx_term_tbl (i + j).p_contract_id := lp_term_rec.p_contract_id;
            lx_term_tbl (i + j).p_contract_number :=
                                                lp_term_rec.p_contract_number;

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'Before process_termination'
                                       );
               okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
               okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
            END IF;

            process_termination (p_api_version        => p_api_version,
                                 p_init_msg_list      => okl_api.g_true,
                                 x_return_status      => l_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 p_term_rec           => lp_term_rec,
                                 p_trn_id             => ter_cnt_recy_rec.trn_id,
                                 --RMUNJULU 17-NOV-02 Bug # 2484327 Added
                                 x_tcnv_rec           => lx_tcnv_rec,
                                 x_term_rec           => lx_term_rec
                                );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'After process_termination '
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'l_return_status: ' || l_return_status
                                       );
            END IF;

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'Before check_contract'
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'In param, p_contract_id: '
                                        || lp_term_rec.p_contract_id
                                       );
            END IF;

            -- RMUNJULU 2730738 For proper output file
            check_contract (p_chr_id            => lp_term_rec.p_contract_id,
                            x_start_date        => l_start_date,
                            x_end_date          => l_end_date,
                            x_status            => l_status,
                            x_control_flag      => l_control_flag
                           );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'After check_contract '
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_start_date: ' || l_start_date
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_end_date: ' || l_end_date
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_status: ' || l_status
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_control_flag: ' || l_control_flag
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'l_return_status: ' || l_return_status
                                       );
            END IF;

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'Before fnd_output '
                                       );
               okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
               okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
            END IF;

            -- RMUNJULU 2730738 For proper output file
            fnd_output (p_chr_id            => lp_term_rec.p_contract_id,
                        p_chr_number        => lp_term_rec.p_contract_number,
                        p_start_date        => l_start_date,
                        p_end_date          => l_end_date,
                        p_status            => l_status,
                        p_exp_recy          => 'RECY',
                        p_control_flag      => l_control_flag
                       );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'After fnd_output '
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'l_return_status: ' || l_return_status
                                       );
            END IF;

            -- RMUNJULU 2730738 For proper output file
            reset_asset_msg_tbl;
            -- set the out tbl termination date
            lx_term_tbl (i + j) := lx_term_rec;

            -- update the overall status only if l_return_status is not success
            IF (l_return_status <> okl_api.g_ret_sts_success) THEN
               l_overall_status := l_return_status;
            END IF;

            -- increment i
            j := j + 1;
         END LOOP;
      END IF;

      -- set the out parameters
      x_term_tbl := lx_term_tbl;
      x_return_status := l_overall_status;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'G_EXCEPTION_ERROR :' );
        END IF;
         x_return_status := okl_api.g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR' );
        END IF;
         x_return_status := okl_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
         okl_api.set_message (p_app_name          => g_app_name_1,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         x_return_status := okl_api.g_ret_sts_unexp_error;
   END batch_expire_lease_loan;

   -- Start of comments
   --
   -- Procedure Name  : concurrent_expire_lease_loan
   -- Description     : This procedure calls batch_expire_lease_loan procedure, used
   --                   by concurrent program
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- History         : rmunjulu 4016497 Changed to not check validity (it will be checked in batch_expire_lease_loan)
   -- End of comments
   PROCEDURE concurrent_expire_lease_loan (
      errbuf            OUT NOCOPY      VARCHAR2,
      retcode           OUT NOCOPY      VARCHAR2,
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okl_api.g_false,
      p_contract_id     IN              NUMBER DEFAULT okl_api.g_miss_num
   ) IS
      l_return_status         VARCHAR2 (1);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2 (2000);
      l_mesg                  VARCHAR2 (4000);
      l_mesg_len              NUMBER;
      l_term_tbl              term_tbl_type;
      lx_contract_status      VARCHAR2 (200);
      lx_error_rec            okl_api.error_rec_type;
      l_msg_idx               INTEGER                := fnd_msg_pub.g_first;
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                           := g_module_name || 'concurrent_expire_lease_loan';
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
                                  'p_contract_id       =' || p_contract_id
                                 );
      END IF;

      -- Check if a single contract termination request
      IF p_contract_id IS NOT NULL AND p_contract_id <> okl_api.g_miss_num THEN
/* -- rmunjulu BUG 4016497
      -- Check the validity of the contract
      OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   l_msg_count,
           x_msg_data                    =>   l_msg_data,
           p_contract_id                 =>   p_contract_id,
           p_control_flag                =>   'BATCH_PROCESS_CHR',
           x_contract_status             =>   lx_contract_status);
*/

         /*
      -- Check if contract valid or not
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN -- Contract validity failed

        fnd_file.put_line(fnd_file.log, 'Processing termination request from concurrent manager.');
        fnd_file.put_line(fnd_file.output, 'Processing termination request from concurrent manager.');

        fnd_file.put_line(fnd_file.log, '');
        fnd_file.put_line(fnd_file.output, '');

         LOOP

         fnd_msg_pub.get(
              p_msg_index     => l_msg_idx,
                p_encoded       => FND_API.G_FALSE,
                p_data          => lx_error_rec.msg_data,
                p_msg_index_out => lx_error_rec.msg_count);

            IF (lx_error_rec.msg_count IS NOT NULL) THEN

            fnd_file.put_line(fnd_file.log,  lx_error_rec.msg_data);
            fnd_file.put_line(fnd_file.output,  lx_error_rec.msg_data);

         END IF;

            EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
            OR (lx_error_rec.msg_count IS NULL));

            l_msg_idx   := FND_MSG_PUB.G_NEXT;
         END LOOP;

        fnd_file.put_line(fnd_file.log, '');
        fnd_file.put_line(fnd_file.output, '');
        fnd_file.put_line(fnd_file.log, 'Termination of contract failed');
        fnd_file.put_line(fnd_file.output, 'Termination of contract failed');

      ELSE -- Contract valid
*/
/* RMUNJULU 2730738
        fnd_file.put_line(fnd_file.log, 'Processing termination request from concurrent manager.');
        fnd_file.put_line(fnd_file.output, 'Processing termination request from concurrent manager.');

        fnd_file.put_line(fnd_file.log, '');
        fnd_file.put_line(fnd_file.output, '');
*/
        -- Terminate the contract
         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'before batch_expire_lease_loan'
                                    );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'p_contract_id       =' || p_contract_id
                                    );
         END IF;

         batch_expire_lease_loan (p_api_version        => p_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data,
                                  p_contract_id        => p_contract_id,
                                  x_term_tbl           => l_term_tbl
                                 );

         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'after batch_expire_lease_loan'
                                    );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                        'l_return_status       ='
                                     || l_return_status
                                    );
         END IF;
        -- rmunjulu 4016497 Report will be generated inside ABOVE API
/*
        -- RMUNJULU 2730738
        create_report;

      END IF;
*/
      ELSE                         -- No contract passed, so scheduled request
/* RMUNJULU 2730738
      fnd_file.put_line(fnd_file.log, 'Processing termination request from concurrent manager.');
      fnd_file.put_line(fnd_file.output, 'Processing termination request from concurrent manager.');

      fnd_file.put_line(fnd_file.log, '');
      fnd_file.put_line(fnd_file.output, '');
*/
         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'before batch_expire_lease_loan'
                                    );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'p_contract_id       =' || p_contract_id
                                    );
         END IF;

         -- Terminate the contract
         batch_expire_lease_loan (p_api_version        => p_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data,
                                  p_contract_id        => p_contract_id,
                                  x_term_tbl           => l_term_tbl
                                 );

         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'after batch_expire_lease_loan'
                                    );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                        'l_return_status       ='
                                     || l_return_status
                                    );
         END IF;

         -- RMUNJULU 2730738
         create_report;
      END IF;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   END concurrent_expire_lease_loan;

   PROCEDURE write_to_log (p_message IN VARCHAR2) IS
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                           := g_module_name || 'write_to_log';
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
                                  'p_message       =' || p_message
                                 );
      END IF;

      -- dbms_output.put_line(p_message);
      fnd_file.put_line (fnd_file.output, p_message);

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   END write_to_log;

   -- RMUNJULU PERF
   PROCEDURE batch_expire_lease_loan (
      p_api_version          IN              NUMBER,
      p_init_msg_list        IN              VARCHAR2 DEFAULT okl_api.g_false,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      p_assigned_processes   IN              VARCHAR2,
      x_term_tbl             OUT NOCOPY      term_tbl_type
   ) IS
      -- get contracts assigned to current process
      CURSOR get_contracts_of_process_csr (p_assigned_process IN VARCHAR2) IS
         SELECT opp.khr_id khr_id,
                opp.object_value contract_number,
                opp.trx_id trx_id
           FROM okl_parallel_processes opp
          WHERE opp.assigned_process = p_assigned_process;

      -- rmunjulu LOANS_ENHANCEMENTS
      CURSOR k_details_csr (p_khr_id IN NUMBER) IS
         SELECT deal_type
           FROM okl_k_headers
          WHERE ID = p_khr_id;

      lp_term_rec             term_rec_type;
      lx_term_rec             term_rec_type;
      lx_term_tbl             term_tbl_type;
      lp_tcnv_rec             tcnv_rec_type;
      lx_tcnv_rec             tcnv_rec_type;
      db_sysdate              DATE;
      i                       NUMBER           := 1;
      j                       NUMBER           := 1;
      l_chr_id                NUMBER;
      l_return_status         VARCHAR2 (1)     := okl_api.g_ret_sts_success;
      l_api_name              VARCHAR2 (200)   := 'batch_expire_lease_loan';
      l_overall_status        VARCHAR2 (1)     := okl_api.g_ret_sts_success;
      l_start_date            DATE;
      l_end_date              DATE;
      l_status                VARCHAR2 (200);
      l_control_flag          VARCHAR2 (10);
      l_exp_chr_yn            VARCHAR2 (3);
      l_recy_chr_yn           VARCHAR2 (3);
      l_message               VARCHAR2 (30000);
      -- rmunjulu LOANS_ENHANCEMENTS
      l_prin_bal              NUMBER           := 0;
      l_deal_type             VARCHAR2 (300);
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)  := g_module_name || 'fnd_output';
      is_debug_exception_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_exception);
      is_debug_procedure_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_procedure);
      is_debug_statement_on   BOOLEAN
              := okl_debug_pub.check_log_on (l_module_name, g_level_statement);
   -- akrangan added for debug feature end
   BEGIN
      FOR get_contracts_of_process_rec IN
         get_contracts_of_process_csr (p_assigned_processes)
      LOOP
         -- set the term_rec_type of terminate_contract
         lp_term_rec.p_contract_id := get_contracts_of_process_rec.khr_id;
         lp_term_rec.p_contract_number :=
                                 get_contracts_of_process_rec.contract_number;
         lp_term_rec.p_termination_date := SYSDATE;
         lp_term_rec.p_control_flag := 'BATCH_PROCESS';

         -- rmunjulu LOANS_ENHANCEMENTS
         OPEN k_details_csr (lp_term_rec.p_contract_id);

         FETCH k_details_csr
          INTO l_deal_type;

         CLOSE k_details_csr;

         -- rmunjulu LOANS_ENHANCEMENTS
         IF l_deal_type LIKE 'LOAN%' THEN
            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug
                       (g_level_statement,
                        l_module_name,
                        'Before OKL_VARIABLE_INT_UTIL_PVT.get_principal_bal '
                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'In param, p_contract_id: '
                                        || lp_term_rec.p_contract_id
                                       );
            END IF;

            -- get principal balance of loan contract
            l_prin_bal :=
               okl_variable_int_util_pvt.get_principal_bal
                                       (x_return_status      => l_return_status,
                                        p_khr_id             => lp_term_rec.p_contract_id,
                                        p_kle_id             => NULL,
                                        p_date               => SYSDATE
                                       );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'After OKL_VARIABLE_INT_UTIL_PVT.get_principal_bal '
                        );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'l_prin_bal: ' || l_prin_bal
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'l_return_status: ' || l_return_status
                                       );
            END IF;
         END IF;

         -- rmunjulu LOANS_ENHANCEMENTS
         IF NVL (l_prin_bal, 0) <= 0 THEN
                                    --rmunjulu 5058848 check for prin bal <= 0
            -- set the out tbl
            lx_term_tbl (i).p_contract_id := lp_term_rec.p_contract_id;
            lx_term_tbl (i).p_contract_number :=
                                                lp_term_rec.p_contract_number;

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'Before process_termination'
                                       );
               okl_debug_pub.log_debug
                                    (g_level_statement,
                                     l_module_name,
                                        'In param, p_term_rec.p_contract_id: '
                                     || lp_term_rec.p_contract_id
                                    );
               okl_debug_pub.log_debug
                                (g_level_statement,
                                 l_module_name,
                                    'In param, p_term_rec.p_contract_number: '
                                 || lp_term_rec.p_contract_number
                                );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'In param, p_trn_id: '
                                        || get_contracts_of_process_rec.trx_id
                                       );
            END IF;

            process_termination
                             (p_api_version        => p_api_version,
                              p_init_msg_list      => okl_api.g_true,
                              x_return_status      => l_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              p_term_rec           => lp_term_rec,
                              p_trn_id             => get_contracts_of_process_rec.trx_id,
                              -- rmunjulu added to pass trx_id if exists
                              x_tcnv_rec           => lx_tcnv_rec,
                              x_term_rec           => lx_term_rec
                             );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'After process_termination '
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'l_return_status: ' || l_return_status
                                       );
            END IF;

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'Before check_contract'
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'In param, p_contract_id: '
                                        || lp_term_rec.p_contract_id
                                       );
            END IF;

            -- RMUNJULU 2730738  For proper output file
            check_contract (p_chr_id            => lp_term_rec.p_contract_id,
                            x_start_date        => l_start_date,
                            x_end_date          => l_end_date,
                            x_status            => l_status,
                            x_control_flag      => l_control_flag
                           );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'After check_contract '
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_start_date: ' || l_start_date
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_end_date: ' || l_end_date
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_status: ' || l_status
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_control_flag: ' || l_control_flag
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'l_return_status: ' || l_return_status
                                       );
            END IF;

            -- rmunjulu for proper output need to tell if recy or exp
            IF     get_contracts_of_process_rec.trx_id IS NOT NULL
               AND get_contracts_of_process_rec.trx_id <> okl_api.g_miss_num THEN
               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'before fnd_output '
                                          );
               END IF;

               fnd_output (p_chr_id            => lp_term_rec.p_contract_id,
                           p_chr_number        => lp_term_rec.p_contract_number,
                           p_start_date        => l_start_date,
                           p_end_date          => l_end_date,
                           p_status            => l_status,
                           p_exp_recy          => 'RECY',
                           p_control_flag      => l_control_flag
                          );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After fnd_output '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;
            ELSE
               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'before fnd_output '
                                          );
               END IF;

               fnd_output (p_chr_id            => lp_term_rec.p_contract_id,
                           p_chr_number        => lp_term_rec.p_contract_number,
                           p_start_date        => l_start_date,
                           p_end_date          => l_end_date,
                           p_status            => l_status,
                           p_exp_recy          => 'EXP',
                           p_control_flag      => l_control_flag
                          );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                           'After fnd_output '
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_return_status: '
                                           || l_return_status
                                          );
               END IF;
            END IF;

            -- RMUNJULU 2730738 For proper output file
            reset_asset_msg_tbl;
            -- set the out tbl termination date
            lx_term_tbl (i) := lx_term_rec;

            -- update the overall status only if l_return_status is not success
            IF (l_return_status <> okl_api.g_ret_sts_success) THEN
               l_overall_status := l_return_status;
            END IF;

            -- increment i
            i := i + 1;
         END IF;
      END LOOP;

      x_term_tbl := lx_term_tbl;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   END batch_expire_lease_loan;

   -- RMUNJULU PERF
   -- THIS PROCESS IS CALLED FROM CHILD PROCESS WHICH WAS SPAWNED FROM MAIN
   -- PROCESSESOR
   -- GETS THE CONTRACTS ASSIGNED TO PROCESSOR AND LAUNCHES TERMINATION FOR THOSE
   PROCEDURE child_process (
      errbuf                 OUT NOCOPY      VARCHAR2,
      retcode                OUT NOCOPY      NUMBER,
      p_assigned_processes   IN              VARCHAR2                      --,
   --p_api_version               IN NUMBER,
   --p_init_msg_list             IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ) IS
      l_return_status         VARCHAR2 (1);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2 (2000);
      l_term_tbl              term_tbl_type;
      l_api_version           NUMBER          := 1;
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                           := g_module_name || 'write_to_log';
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
                                  'before batch_expire_lease_loan '
                                 );
      END IF;

      -- Terminate the contract -- call the new batch_expire procedure
      batch_expire_lease_loan (p_api_version             => l_api_version,
                               p_init_msg_list           => okl_api.g_true,
                               x_return_status           => l_return_status,
                               x_msg_count               => l_msg_count,
                               x_msg_data                => l_msg_data,
                               p_assigned_processes      => p_assigned_processes,
                               x_term_tbl                => l_term_tbl
                              );

      IF (is_debug_statement_on) THEN
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'after batch_expire_lease_loan '
                                 );
         okl_debug_pub.log_debug (g_level_statement,
                                  l_module_name,
                                  'l_return_status = ' || l_return_status
                                 );
      END IF;

      -- create report
      create_report;

      -- Do clean up of parallel processes
      DELETE FROM okl_parallel_processes
            WHERE assigned_process = p_assigned_processes;

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   END child_process;

   -- RMUNJULU PERF
   -- MASTER PROGRAM WHICH DOES PARALLEL LOAD BALANCE AND SPAWNS CHILD PROCESSES
   -- THIS PROCEDURE IS CALLED FROM MASTER CONCURRENT PROGRAM
   PROCEDURE process_spawner (
      errbuf            OUT NOCOPY      VARCHAR2,
      retcode           OUT NOCOPY      NUMBER,
      p_num_processes   IN              NUMBER,
      p_term_date       IN              VARCHAR2
   ) IS
      request_id              NUMBER            := 0;

      -- GETS CONTRACTS
      CURSOR chk_update_header_csr IS
         SELECT contract_number,
                khr_id,
                trx_id
           FROM (SELECT khr.contract_number contract_number,
                        khr.ID khr_id,
                        NULL trx_id
                   FROM okc_k_headers_b khr
                  WHERE TRUNC (khr.end_date) < TRUNC (SYSDATE)
                    AND NVL (khr.sts_code, '?') IN ('BOOKED')
                    AND khr.scs_code IN ('LEASE', 'LOAN')
                    -- rmunjulu --start -- added the following or else same record picked twice
                    AND khr.ID NOT IN (
                           -- Contracts which have unprocessed transactions
                           SELECT NVL (tcn.khr_id, -9999) khr_id
                             FROM okl_trx_contracts tcn
                            WHERE NVL (tcn.tcn_type, '?') IN
                                                        ('TMT', 'ALT', 'EVG')
                              -- akrangan bug 5354501 fix added 'EVG'
                              AND tcn.tmt_status_code NOT IN
                                                    ('CANCELED', 'PROCESSED')
                              --akrangan changed for sla tmt_status_Code cr
                              --rkuttiya added for 12.1.1 Multi GAAP
                              AND tcn.representation_type = 'PRIMARY'
                              --
                              AND tcn.khr_id = khr.ID)        -- rmunjulu PERF
                    AND khr.ID NOT IN (
                           -- Contracts which have accepted quotes with no transactions
                           SELECT NVL (qte.khr_id, -9999) khr_id
                             FROM okl_trx_quotes_v qte
                            WHERE NVL (qte.accepted_yn, 'N') = 'Y'
                              AND NVL (qte.consolidated_yn, 'N') = 'N'
                              AND qte.khr_id = khr.ID         -- rmunjulu PERF
                              AND qte.ID NOT IN (
                                     SELECT NVL (tcn.qte_id, -9999) qte_id
                                       FROM okl_trx_contracts tcn
                                      WHERE NVL (tcn.tcn_type, '?') IN
                                                        ('TMT', 'ALT', 'EVG')
                                        -- akrangan bug 5354501 fix added 'EVG'
                                        --rkuttiya added for 12.1.1 Multi GAAP
                                        AND tcn.representation_type = 'PRIMARY'
                                        --
                                        AND tcn.qte_id = qte.ID))
                                                              -- rmunjulu PERF
                 -- rmunjulu -- end
                 UNION
                 SELECT k.contract_number,
                        k.ID khr_id,
                        t.ID trx_id
                   FROM okc_k_headers_b k, okl_trx_contracts t
                  WHERE NVL (t.tmt_recycle_yn, '?') = 'Y'
                    AND NVL (t.tmt_status_code, '?') NOT IN
                                                    ('PROCESSED', 'CANCELED')
                    --akrangan changed for sla tmt_status_Code cr
                    AND NVL (t.tcn_type, '?') IN ('TMT', 'ALT', 'EVG')
                    -- akrangan bug 5354501 fix added 'EVG'
                    AND k.scs_code IN ('LEASE', 'LOAN')
                    --rkuttiya added for 12.1.1 Multi GAAP
                    AND t.representation_type = 'PRIMARY'
                    --
                    AND k.ID = t.khr_id)
          WHERE NOT EXISTS (
                   SELECT '1'
                     FROM okl_parallel_processes opp
                    WHERE contract_number = opp.object_value
                      AND opp.object_type = 'CONT_TERM'
                      AND opp.process_status IN
                                           ('PENDING_ASSIGNMENT', 'ASSIGNED'));

      -- GET DATA VOLUME BASED ON WHICH WILL DECIDE WHICH PARALLEL PROCESS TO USE.
      --Bug # 6174484 fixed for SQL Performance ssdehpa start
      CURSOR chk_data_volume_csr (p_seq_next VARCHAR2) IS
         /* SELECT  opp.object_value contract_number ,  count(KLE.id) line_count
          FROM    OKC_K_LINES_B KLE,
                  okl_parallel_processes opp
          WHERE   opp.khr_id = KLE.dnz_chr_id
          AND     KLE.sts_code = ('BOOKED')
          AND     opp.khr_id NOT IN(
                  SELECT  NVL(TCN.khr_id,-9999) khr_id
                  FROM    OKL_TRX_CONTRACTS  TCN
                  WHERE   NVL(TCN.tcn_type,'?') IN ('TMT','ALT','EVG') -- akrangan bug 5354501 fix added 'EVG'
                  AND     TCN.tmt_status_code NOT IN ('CANCELED','PROCESSED')--akrangan changed for sla tmt_status_Code cr
                  AND     TCN.khr_id = opp.khr_id)
          AND     opp.khr_id NOT IN (
                  SELECT  NVL(QTE.khr_id,-9999)  khr_id
                  FROM    OKL_TRX_QUOTES_V  QTE
                  WHERE   NVL(QTE.accepted_yn,'N') = 'Y'
                  AND     NVL(QTE.consolidated_yn,'N') = 'N'
                  AND     QTE.khr_id = opp.khr_id
                  AND     QTE.id NOT IN (
                          SELECT  NVL(TCN.qte_id,-9999) qte_id
                          FROM    OKL_TRX_CONTRACTS TCN
                          WHERE   NVL(TCN.tcn_type,'?') IN ('TMT','ALT','EVG')  -- akrangan bug 5354501 fix added 'EVG'
                          AND     TCN.qte_id = QTE.id))
          AND   opp.object_type = 'CONT_TERM'
          AND   opp.assigned_process = p_seq_next
          GROUP BY opp.object_value
          UNION
          SELECT  opp.object_value contract_number, count(KLE.id) line_count
          FROM    okl_parallel_processes  opp,
                  OKL_TRX_CONTRACTS   T,
                  OKC_K_LINES_B KLE
          WHERE   NVL(T.tmt_recycle_yn,'?') = 'Y'
          AND     opp.khr_id = KLE.dnz_chr_id
          AND     KLE.sts_code = 'BOOKED'
          AND     NVL(T.tmt_status_code,'?') NOT IN('PROCESSED', 'CANCELED')--akrangan changed for sla tmt_status_Code cr
          AND     NVL(T.tcn_type,'?') IN( 'TMT', 'ALT','EVG')  -- akrangan bug 5354501 fix added 'EVG'
          AND     opp.khr_id = T.khr_id
          AND     opp.object_type = 'CONT_TERM'
          AND     opp.assigned_process = p_seq_next
          GROUP BY opp.object_value; */
         SELECT   opp.object_value contract_number,
                  COUNT (kle.ID) line_count
             FROM okc_k_lines_b kle, okl_parallel_processes opp
            WHERE opp.khr_id = kle.dnz_chr_id
              AND kle.sts_code = ('BOOKED')
              AND opp.khr_id NOT IN (
                     SELECT NVL (tcn.khr_id, -9999) khr_id
                       FROM okl_trx_contracts_all tcn
                      WHERE tcn.tcn_type IN ('TMT', 'ALT', 'EVG')
                        -- akrangan bug 5354501 fix added 'EVG'
                        AND tcn.tmt_status_code NOT IN
                                                    ('CANCELED', 'PROCESSED')
                        --akrangan changed for sla tmt_status_Code cr
                        --rkuttiya added for 12.1.1 Multi GAAP
                        AND tcn.representation_Type = 'PRIMARY'
                        --
                        AND tcn.khr_id = opp.khr_id)
              AND opp.khr_id NOT IN (
                     SELECT NVL (qte.khr_id, -9999) khr_id
                       FROM okl_trx_quotes_b qte
                      WHERE NVL (qte.accepted_yn, 'N') = 'Y'
                        AND NVL (qte.consolidated_yn, 'N') = 'N'
                        AND qte.khr_id = opp.khr_id
                        AND qte.ID NOT IN (
                               SELECT NVL (tcn.qte_id, -9999) qte_id
                                 FROM okl_trx_contracts_all tcn
                                WHERE tcn.tcn_type IN ('TMT', 'ALT', 'EVG')
                                  -- akrangan bug 5354501 fix added 'EVG'
                                  --rkuttiya added for 12.1.1 Multi GAAP
                                  AND tcn.representation_type = 'PRIMARY'
                                  --
                                  AND tcn.qte_id = qte.ID))
              AND opp.object_type = 'CONT_TERM'
              AND opp.assigned_process = p_seq_next
         GROUP BY opp.object_value
         UNION
         SELECT   opp.object_value contract_number,
                  COUNT (kle.ID) line_count
             FROM okl_parallel_processes opp,
                  okl_trx_contracts t,
                  okc_k_lines_b kle
            WHERE NVL (t.tmt_recycle_yn, '?') = 'Y'
              AND opp.khr_id = kle.dnz_chr_id
              AND kle.sts_code = 'BOOKED'
              AND NVL (t.tmt_status_code, '?') NOT IN
                                                    ('PROCESSED', 'CANCELED')
              --akrangan changed for sla tmt_status_Code cr
              AND t.tcn_type IN ('TMT', 'ALT', 'EVG')
              -- akrangan bug 5354501 fix added 'EVG'
              AND opp.khr_id = t.khr_id
              --rkuttiya added for 12.1.1. Multi GAAP
              AND t.representation_type = 'PRIMARY'
              --
              AND opp.object_type = 'CONT_TERM'
              AND opp.assigned_process = p_seq_next
         GROUP BY opp.object_value;

      --Bug # 6174484 fixed for SQL Performance ssdehpa end
      TYPE l_contract_rec IS RECORD (
         batch_number      VARCHAR2 (60),
         contract_number   VARCHAR2 (60),
         line_count        NUMBER,
         worker_number     NUMBER,
         khr_id            NUMBER,
         trx_id            NUMBER
      );

      TYPE contract_tab IS TABLE OF l_contract_rec
         INDEX BY PLS_INTEGER;

      TYPE worker_load_rec IS RECORD (
         worker_number   NUMBER,
         worker_load     NUMBER
      );

      TYPE worker_load_tab IS TABLE OF worker_load_rec
         INDEX BY PLS_INTEGER;

      TYPE contract_list IS RECORD (
         contract_number   VARCHAR2 (60)
      );

      TYPE contract_list_tab IS TABLE OF contract_list
         INDEX BY PLS_INTEGER;

      l_contract_list         contract_list_tab;
      l_worker_load           worker_load_tab;
      l_contract_tab          contract_tab;
      l_sort_tab1             contract_tab;
      l_temp_tab              contract_tab;
      l_int_counter           INTEGER;
      l_max_lines             NUMBER;
      l_init_loop             BOOLEAN           := TRUE;
      l_sort_int_counter      INTEGER;
      l_next_highest_val      NUMBER;
      l_lightest_worker       NUMBER;
      l_lightest_load         NUMBER;
      l_seq_next              NUMBER;
      l_data_found            BOOLEAN           := FALSE;
      lp_term_date            DATE;
      l_return_status         VARCHAR2 (1);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2 (2000);
      l_term_tbl              term_tbl_type;
      -- akrangan added for debug feature start
      l_module_name           VARCHAR2 (500)
                                            := g_module_name || 'write_to_log';
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

      lp_term_date := fnd_date.canonical_to_date (p_term_date);

      IF NVL (p_num_processes, 0) = 0 THEN
         write_to_log ('Number of parallel processors should be provided.');
         RETURN;
      ELSIF NVL (p_num_processes, 0) = 1 THEN
         --write_to_log('Single worker requested');
         -- no need to run algorithm, directly call single thread program here
         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'before batch_expire_lease_loan '
                                    );
         END IF;

         -- Terminate the contract
         batch_expire_lease_loan (p_api_version        => 1,
                                  p_init_msg_list      => 'T',
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data,
                                  p_contract_id        => NULL,
                                  x_term_tbl           => l_term_tbl
                                 );

         IF (is_debug_statement_on) THEN
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'after batch_expire_lease_loan '
                                    );
            okl_debug_pub.log_debug (g_level_statement,
                                     l_module_name,
                                     'l_return_status = ' || l_return_status
                                    );
         END IF;

         -- RMUNJULU
         create_report;
         RETURN;
      END IF;

      l_int_counter := 0;
      l_max_lines := 0;

      -- Select sequence for marking processes
      SELECT okl_opp_seq.NEXTVAL
        INTO l_seq_next
        FROM DUAL;

      -- mark records for processing
      FOR chk_update_header_csr_rec IN chk_update_header_csr
      LOOP
         INSERT INTO okl_parallel_processes
                     (object_type,
                      object_value,
                      assigned_process,
                      process_status,
                      start_date,
                      khr_id,
                      trx_id
                     )
              VALUES ('CONT_TERM',
                      chk_update_header_csr_rec.contract_number,
                      TO_CHAR (l_seq_next),
                      'PENDING_ASSIGNMENT',
                      SYSDATE,
                      chk_update_header_csr_rec.khr_id,
                      chk_update_header_csr_rec.trx_id
                     );

         COMMIT;
         l_data_found := TRUE;
      END LOOP;

      IF l_data_found THEN
         FOR chk_data_volume_csr_rec IN chk_data_volume_csr (l_seq_next)
         LOOP
            l_int_counter := l_int_counter + 1;

            IF l_init_loop THEN       -- initialize minimum and maximum lines
               l_init_loop := FALSE;
               l_max_lines := chk_data_volume_csr_rec.line_count;
            END IF;

            l_contract_tab (l_int_counter).contract_number :=
                                       chk_data_volume_csr_rec.contract_number;
            l_contract_tab (l_int_counter).line_count :=
                                            chk_data_volume_csr_rec.line_count;

            IF chk_data_volume_csr_rec.line_count > l_max_lines THEN
               l_max_lines := chk_data_volume_csr_rec.line_count;
            END IF;
         END LOOP;

         -- reset, ready for use again
         l_init_loop := TRUE;

         IF l_int_counter = 0 THEN
            write_to_log ('No Data Found for criteria passed ');
         END IF;

         -- find the maximum line count from the original table and delete it
         -- put this as the first element of the new sorted table
         l_sort_int_counter := 0;

         FOR i IN 1 .. l_int_counter
         LOOP
            IF l_contract_tab (i).line_count = l_max_lines THEN
               l_sort_int_counter := l_sort_int_counter + 1;
               l_sort_tab1 (l_sort_int_counter).contract_number :=
                                           l_contract_tab (i).contract_number;
               l_sort_tab1 (l_sort_int_counter).line_count :=
                                                l_contract_tab (i).line_count;
               l_contract_tab.DELETE (i);
            END IF;
         END LOOP;

         -- start sorting
         IF l_contract_tab.FIRST IS NOT NULL THEN
            FOR i IN 1 .. l_contract_tab.COUNT
            LOOP
               -- find the next highest value in original table
               FOR i IN 1 .. l_contract_tab.LAST
               LOOP
                  IF l_init_loop THEN
                     IF l_contract_tab.EXISTS (i) THEN
                        l_next_highest_val := l_contract_tab (i).line_count;
                        l_init_loop := FALSE;
                     END IF;
                  END IF;

                  IF     l_contract_tab.EXISTS (i)
                     AND l_contract_tab (i).line_count > l_next_highest_val THEN
                     l_next_highest_val := l_contract_tab (i).line_count;
                  END IF;
               END LOOP;

               -- reset flag, ready for use again
               l_init_loop := TRUE;

               -- continue populating sort table in order
               FOR i IN 1 .. l_contract_tab.LAST
               LOOP
                  IF     l_contract_tab.EXISTS (i)
                     AND l_contract_tab (i).line_count = l_next_highest_val THEN
                     l_sort_int_counter := l_sort_int_counter + 1;
                     l_sort_tab1 (l_sort_int_counter).contract_number :=
                                           l_contract_tab (i).contract_number;
                     l_sort_tab1 (l_sort_int_counter).line_count :=
                                                l_contract_tab (i).line_count;
                     l_contract_tab.DELETE (i);
                  END IF;
               END LOOP;

               EXIT WHEN l_contract_tab.LAST IS NULL;
            END LOOP;
         END IF;                                                -- end sorting

         -- begin processing load for workers
         FOR i IN 1 .. p_num_processes
         LOOP                                  -- put all workers into a table
            l_worker_load (i).worker_number := i;
            l_worker_load (i).worker_load := 0;  -- initialize load with zero
         END LOOP;

         IF p_num_processes > 0 THEN
            l_lightest_worker := 1;

            IF l_sort_tab1.COUNT > 0 THEN                         -- rmunjulu
               -- loop through the sorted table and ensure each contract has a worker
               FOR i IN 1 .. l_sort_tab1.COUNT
               LOOP
                  l_sort_tab1 (i).worker_number := l_lightest_worker;

                  -- put current contract into the lightest worker
                  IF l_worker_load.EXISTS (l_lightest_worker) THEN
                     l_worker_load (l_lightest_worker).worker_load :=
                          l_worker_load (l_lightest_worker).worker_load
                        + l_sort_tab1 (i).line_count;
                  END IF;

                  -- default the lighest load with the first element as a starting point
                  IF l_worker_load.EXISTS (1) THEN
                     l_lightest_load := l_worker_load (1).worker_load;
                     l_lightest_worker := l_worker_load (1).worker_number;

                     -- logic to find lightest load
                     FOR i IN 1 .. l_worker_load.COUNT
                     LOOP
                        IF    (l_worker_load (i).worker_load = 0)
                           OR (l_worker_load (i).worker_load < l_lightest_load
                              ) THEN
                           l_lightest_load := l_worker_load (i).worker_load;
                           l_lightest_worker :=
                                              l_worker_load (i).worker_number;
                        END IF;
                     END LOOP;
                  END IF;
               END LOOP;
            END IF;                                                -- rmunjulu
         END IF;

         l_sort_int_counter := 0;

         IF l_worker_load.COUNT > 0 THEN                           -- rmunjulu
            FOR j IN 1 .. l_worker_load.LAST
            LOOP
               IF l_sort_tab1.COUNT > 0 THEN                      -- rmunjulu
                  FOR i IN 1 .. l_sort_tab1.LAST
                  LOOP
                     IF     l_sort_tab1.EXISTS (i)
                        AND (l_sort_tab1 (i).worker_number =
                                               l_worker_load (j).worker_number
                            ) THEN
                        UPDATE okl_parallel_processes
                           SET assigned_process =
                                     l_seq_next
                                  || '-'
                                  || l_sort_tab1 (i).worker_number,
                               volume = l_sort_tab1 (i).line_count,
                               process_status = 'ASSIGNED'
                         WHERE object_type = 'CONT_TERM'
                           AND object_value = l_sort_tab1 (i).contract_number
                           AND process_status = 'PENDING_ASSIGNMENT';

                        COMMIT;
                        l_sort_tab1.DELETE (i);
                     END IF;
                  END LOOP;
               END IF;                                             -- rmunjulu
            END LOOP;
         END IF;                                                   -- rmunjulu

         -- SPAWN THE CHILD CONCURRENT PROGRAM WHICH WILL DO THE ACTUAL EXPIRATION PROCESSING
         FOR j IN l_worker_load.FIRST .. l_worker_load.LAST
         LOOP
            -- Do not spawn a worker if theres no data to process
            -- This occurs if more workers are requested and the
            -- distribution of data does not utilize them all
            IF l_worker_load (j).worker_load > 0 THEN
               fnd_request.set_org_id (mo_global.get_current_org_id);
               --MOAC- Concurrent request
               request_id :=
                  fnd_request.submit_request (application      => 'OKL',
                                              program          => 'OKL_AM_CHILD_TERM',
                                              sub_request      => FALSE,
                                              argument1        =>    l_seq_next
                                                                  || '-'
                                                                  || j
                                             );
               write_to_log (   'Launching Process '
                             || l_seq_next
                             || '-'
                             || j
                             || ' with Request ID '
                             || request_id
                            );

               IF (request_id = 0) THEN
                  errbuf := fnd_message.get;
                  retcode := 2;
               END IF;
            END IF;
         END LOOP;

         -- clean up
         -- Delete records from in chk_update_header_csr that were unassigned
         DELETE      okl_parallel_processes
               WHERE process_status = 'PENDING_ASSIGNMENT'
                 AND assigned_process = TO_CHAR (l_seq_next);

         COMMIT;
      ELSE
         write_to_log
                   ('No workers assigned due to no data found for prcocesing');
      END IF;                                                  -- l_data_found

      IF (is_debug_procedure_on) THEN
         okl_debug_pub.log_debug (g_level_procedure, l_module_name, 'End(-)');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
         write_to_log ('Unhandled Exception ' || SQLERRM);
   END process_spawner;
END okl_am_btch_exp_lease_loan_pvt;

/
