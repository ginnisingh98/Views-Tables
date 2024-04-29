--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_BOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_BOOK_PVT" AS
/* $Header: OKLRBKGB.pls 120.63.12010000.4 2009/08/05 13:02:52 rpillay ship $ */

   -------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
   g_no_parent_record            CONSTANT VARCHAR2 (200)
                                                    := 'OKC_NO_PARENT_RECORD';
   g_fnd_app                     CONSTANT VARCHAR2 (200) := okl_api.g_fnd_app;
   g_required_value              CONSTANT VARCHAR2 (200)
                                                  := okl_api.g_required_value;
   g_invalid_value               CONSTANT VARCHAR2 (200)
                                                   := okl_api.g_invalid_value;
   g_unexpected_error            CONSTANT VARCHAR2 (200)
                                               := 'OKC_CONTRACTS_UNEXP_ERROR';
   g_sqlerrm_token               CONSTANT VARCHAR2 (200) := 'SQLerrm';
   g_sqlcode_token               CONSTANT VARCHAR2 (200) := 'SQLcode';
   g_uppercase_required          CONSTANT VARCHAR2 (200)
                                             := 'OKL_CONTRACTS_UPPERCASE_REQ';
   g_col_name_token              CONSTANT VARCHAR2 (200)
                                                  := okl_api.g_col_name_token;
   g_debug_enabled               CONSTANT VARCHAR2 (10)
                                           := okl_debug_pub.check_log_enabled;
   g_is_debug_statement_on                BOOLEAN;
   g_auto_approve                CONSTANT VARCHAR2 (15)  := 'AUTO_APPROVE';
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
   g_exception_halt_validation            EXCEPTION;
   g_exception_stop_validation            EXCEPTION;
   g_api_type                    CONSTANT VARCHAR2 (4)   := '_PVT';
   g_api_version                 CONSTANT NUMBER         := 1.0;
   g_scope                       CONSTANT VARCHAR2 (4)   := '_PVT';
   --rviriyal
    /*
    -- mvasudev, 08/17/2004
    -- Added Constants to enable Business Event
    */
   g_wf_evt_khr_validated        CONSTANT VARCHAR2 (43)
                             := 'oracle.apps.okl.la.lease_contract.validated';
   g_wf_evt_khr_gen_strms        CONSTANT VARCHAR2 (61)
           := 'oracle.apps.okl.la.lease_contract.stream_generation_completed';
   g_wf_evt_khr_gen_journal      CONSTANT VARCHAR2 (60)
             := 'oracle.apps.okl.la.lease_contract.journal_entries_generated';
   g_wf_evt_khr_submit_appr      CONSTANT VARCHAR2 (56)
                := 'oracle.apps.okl.la.lease_contract.submitted_for_approval';
   g_wf_evt_khr_activated        CONSTANT VARCHAR2 (43)
                             := 'oracle.apps.okl.la.lease_contract.activated';
   g_wf_evt_khr_rebook_comp      CONSTANT VARCHAR2 (50)
                      := 'oracle.apps.okl.la.lease_contract.rebook_completed';
   g_wf_itm_contract_id          CONSTANT VARCHAR2 (15)  := 'CONTRACT_ID';
   g_wf_itm_contract_process     CONSTANT VARCHAR2 (20) := 'CONTRACT_PROCESS';
   g_wf_itm_src_contract_id      CONSTANT VARCHAR2 (20)
                                                      := 'SOURCE_CONTRACT_ID';
   g_wf_itm_dest_contract_id     CONSTANT VARCHAR2 (25)
                                                 := 'DESTINATION_CONTRACT_ID';
   g_wf_itm_trx_date             CONSTANT VARCHAR2 (20) := 'TRANSACTION_DATE';
   g_khr_process_rebook          CONSTANT VARCHAR2 (6)
                                     := okl_lla_util_pvt.g_khr_process_rebook;
/*
-- cklee, 12/21/2005
-- Added Constants to enable Business Event Bug# 4901292
*/
   g_wf_evt_chr_list_validated   CONSTANT VARCHAR2 (240)
      := 'oracle.apps.okl.sales.leaseapplication.khr_chklist_items_val';
   g_module   VARCHAR2 (255)  := 'okl.stream.esg.okl_esg_transport_pvt';
   g_module_name   VARCHAR2 (255)  := 'okl.plsql.stream.esg.okl_esg_transport_pvt';
   g_level_procedure             CONSTANT NUMBER   := fnd_log.level_procedure;
   g_level_exception             CONSTANT NUMBER   := fnd_log.level_exception;
   g_level_statement             CONSTANT NUMBER   := fnd_log.level_statement;

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------

   --Bug 5909373
   --Function to check whether the contract is a release contract or not
   FUNCTION is_release_contract (p_contract_id NUMBER)
      RETURN VARCHAR2 IS
      l_is_release_contract   VARCHAR2 (1) := 'N';

      --cursor to check if contract is a re-lease contract
      CURSOR l_chk_rel_khr_csr (p_chr_id IN NUMBER) IS
         SELECT 'Y'
           FROM okc_k_headers_b CHR
          WHERE CHR.ID = p_chr_id
            AND NVL (CHR.orig_system_source_code, 'XXXX') = 'OKL_RELEASE';

      l_rel_khr               VARCHAR2 (1) DEFAULT 'N';

      --cursor to check if contract has re-lease assets
      CURSOR l_chk_rel_ast_csr (p_chr_id IN NUMBER) IS
         SELECT 'Y'
           FROM okc_k_headers_b CHR
          WHERE NVL (CHR.orig_system_source_code, 'XXXX') <> 'OKL_RELEASE'
            AND CHR.ID = p_chr_id
            AND EXISTS (
                   SELECT '1'
                     FROM okc_rules_b rul
                    WHERE rul.dnz_chr_id = CHR.ID
                      AND rul.rule_information_category = 'LARLES'
                      AND NVL (rule_information1, 'N') = 'Y');

      l_rel_ast               VARCHAR2 (1) DEFAULT 'N';
   BEGIN
      OPEN l_chk_rel_khr_csr (p_contract_id);

      FETCH l_chk_rel_khr_csr
       INTO l_rel_khr;

      CLOSE l_chk_rel_khr_csr;

      IF (NVL (l_rel_khr, 'N') = 'Y') THEN
         l_is_release_contract := 'Y';
      END IF;

      OPEN l_chk_rel_ast_csr (p_contract_id);

      FETCH l_chk_rel_ast_csr
       INTO l_rel_ast;

      CLOSE l_chk_rel_ast_csr;

      IF (NVL (l_rel_ast, 'N') = 'Y') THEN
         l_is_release_contract := 'Y';
      END IF;

      RETURN l_is_release_contract;
   END is_release_contract;

   --Bug 5909373

   ---------------------------------------------------------------
 --Bug# 3556674 validate chr_id
---------------------------------------------------------------
   PROCEDURE validate_chr_id (
      p_chr_id          IN              NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      --Cursor to check existence of contract
      CURSOR l_chr_csr (p_chr_id IN NUMBER) IS
         SELECT 'Y'
           FROM okc_k_headers_b chrb
          WHERE chrb.ID = p_chr_id AND chrb.scs_code = 'LEASE';

      l_exists   VARCHAR2 (1) DEFAULT 'N';
   BEGIN
      IF (p_chr_id = okl_api.g_miss_num OR p_chr_id IS NULL) THEN
         okl_api.set_message (g_app_name,
                              g_required_value,
                              g_col_name_token,
                              'p_chr_id'
                             );
         x_return_status := okl_api.g_ret_sts_error;
         RAISE g_exception_halt_validation;
      END IF;

      l_exists := 'N';

      --check if chr id passed is valie
      OPEN l_chr_csr (p_chr_id => p_chr_id);

      FETCH l_chr_csr
       INTO l_exists;

      IF l_chr_csr%NOTFOUND THEN
         NULL;
      END IF;

      CLOSE l_chr_csr;

      IF l_exists = 'N' THEN
         okl_api.set_message (g_app_name,
                              g_invalid_value,
                              g_col_name_token,
                              'p_chr_id'
                             );
         x_return_status := okl_api.g_ret_sts_error;
         RAISE g_exception_halt_validation;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation THEN
         NULL;
      WHEN OTHERS THEN
         IF l_chr_csr%ISOPEN THEN
            CLOSE l_chr_csr;
         END IF;

         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         x_return_status := okl_api.g_ret_sts_unexp_error;
   END validate_chr_id;

   PROCEDURE execute_qa_check_list (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_qcl_id          IN              NUMBER,
      p_chr_id          IN              NUMBER,
      p_call_mode       IN              VARCHAR2 DEFAULT 'ACTUAL',
      x_msg_tbl         OUT NOCOPY      okl_qa_check_pub.msg_tbl_type
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)       := 'EXECUTE_QA_CHECK_LIST';
      l_api_version   CONSTANT NUMBER                                  := 1;
      l_return_status          VARCHAR2 (1)      := okl_api.g_ret_sts_success;
      l_passstatus             VARCHAR2 (30)                      := 'PASSED';
      l_failstatus             VARCHAR2 (256)                 := 'INCOMPLETE';
      severity                 VARCHAR2 (1);
      l_msg_tbl                okl_qa_check_pub.msg_tbl_type;
      l_pmsg_tbl               okc_qa_check_pub.msg_tbl_type;
      j                        NUMBER;
      x_batch_number           NUMBER;

      CURSOR l_dltype_csr (chrid NUMBER) IS
         SELECT khr.deal_type
           FROM okc_k_headers_v CHR, okl_k_headers khr
          WHERE CHR.ID = khr.ID AND CHR.ID = chrid;

      l_dltype_rec             l_dltype_csr%ROWTYPE;

      CURSOR l_ptmpl_csr (p_chr_id IN NUMBER) IS
         SELECT chrb.template_yn,
                khr.template_type_code
           FROM okc_k_headers_b chrb, okl_k_headers khr
          WHERE chrb.ID = khr.ID AND chrb.ID = p_chr_id;

      l_template_type_code     okl_k_headers.template_type_code%TYPE;
      l_template_yn            okc_k_headers_b.template_yn%TYPE;
      l_pqcl_id                okc_k_headers_b.qcl_id%TYPE;

      CURSOR l_ptmpl_qcl_csr (p_chr_id IN NUMBER) IS
         SELECT chrb.qcl_id
           FROM okc_k_headers_b chrb
          WHERE chrb.ID = p_chr_id;

    /*
    -- mvasudev, 08/30/2004
    -- Added PROCEDURE to enable Business Event
    */
--START 21-Dec-2005 cklee     Bug# 4901292                                |
-- PROCEDURE raise_business_event(x_return_status OUT NOCOPY VARCHAR2
      PROCEDURE raise_business_event (
         p_event_name      IN              VARCHAR2,
         x_return_status   OUT NOCOPY      VARCHAR2
--END 21-Dec-2005 cklee     Bug# 4901292                                |
      ) IS
         l_process          VARCHAR2 (20);
         l_parameter_list   wf_parameter_list_t;
      BEGIN
         l_process := okl_lla_util_pvt.get_contract_process (p_chr_id);
         wf_event.addparametertolist (g_wf_itm_contract_id,
                                      p_chr_id,
                                      l_parameter_list
                                     );
         wf_event.addparametertolist (g_wf_itm_contract_process,
                                      l_process,
                                      l_parameter_list
                                     );
         okl_wf_pvt.raise_event (p_api_version        => p_api_version,
                                 p_init_msg_list      => p_init_msg_list,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
--START 21-Dec-2005 cklee     Bug# 4901292                                |
--                       p_event_name     => G_WF_EVT_KHR_VALIDATED,
                                 p_event_name         => p_event_name,
--END 21-Dec-2005 cklee     Bug# 4901292                                |
                                 p_parameters         => l_parameter_list
                                );
      EXCEPTION
         WHEN OTHERS THEN
            x_return_status := okl_api.g_ret_sts_unexp_error;
            RAISE okl_api.g_exception_unexpected_error;
      END raise_business_event;
   /*
   -- mvasudev, 08/30/2004
   -- END, PROCEDURE to enable Business Event
   */
   BEGIN
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      OPEN l_dltype_csr (p_chr_id);

      FETCH l_dltype_csr
       INTO l_dltype_rec;

      IF (l_dltype_csr%NOTFOUND) THEN
         RAISE okl_api.g_exception_unexpected_error;
      END IF;

      /* gboomina commenting for Bug Bug 6476425 - start
      -- Revolving Loan contract status will be changed by stream
      -- generation API after pricing the contract (similar to other
      -- type contracts).
      IF ( l_dltype_rec.deal_type = 'LOAN-REVOLVING') THEN
          l_PassStatus := 'COMPLETE';
      END IF;
      gboomina commenting for Bug Bug 6476425 - end */

      -- Initialize records in okl_book_controller_trx table
      okl_book_controller_pvt.init_book_controller_trx
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_khr_id             => p_chr_id,
                                           x_batch_number       => x_batch_number
                                          );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

/*
    --call to cascade status on to lines
    OKL_CONTRACT_STATUS_PVT_WIP.cascade_lease_status
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => p_chr_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
      l_template_yn := 'N';
      l_template_type_code := 'XXX';

      OPEN l_ptmpl_csr (p_chr_id => p_chr_id);

      FETCH l_ptmpl_csr
       INTO l_template_yn,
            l_template_type_code;

      CLOSE l_ptmpl_csr;

      --Bug# 4874338
      IF    (l_template_yn = 'Y' AND l_template_type_code = 'PROGRAM')
         OR (l_template_yn = 'Y' AND l_template_type_code = 'LEASEAPP') THEN
         OPEN l_ptmpl_qcl_csr (p_chr_id => p_chr_id);

         FETCH l_ptmpl_qcl_csr
          INTO l_pqcl_id;

         CLOSE l_ptmpl_qcl_csr;

         okc_qa_check_pub.execute_qa_check_list
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_qcl_id             => l_pqcl_id,
                                           p_chr_id             => p_chr_id,
                                           x_msg_tbl            => l_pmsg_tbl
                                          );
      ELSE
         okl_qa_check_pub.execute_qa_check_list
                                         (p_api_version        => p_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_qcl_id             => p_qcl_id,
                                          p_chr_id             => p_chr_id,
                                          p_call_mode          => p_call_mode,
                                          x_msg_tbl            => x_msg_tbl
                                         );
      END IF;

      -- Bug# 3477560 - Changed l_return_status to x_return_status
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      j := 0;

      FOR i IN 1 .. x_msg_tbl.COUNT
      LOOP
         IF (x_msg_tbl (i).NAME <> 'CHECK Email Address') THEN
            j := j + 1;
            l_msg_tbl (j).severity := x_msg_tbl (i).severity;
            l_msg_tbl (j).NAME := x_msg_tbl (i).NAME;
            l_msg_tbl (j).description := x_msg_tbl (i).description;
            l_msg_tbl (j).package_name := x_msg_tbl (i).package_name;
            l_msg_tbl (j).procedure_name := x_msg_tbl (i).procedure_name;
            l_msg_tbl (j).error_status := x_msg_tbl (i).error_status;
            l_msg_tbl (j).DATA := x_msg_tbl (i).DATA;
         END IF;
      END LOOP;

       --Bug# 4186455
      /*
      --FOR i IN 1..l_msg_tbl.COUNT
      --LOOP
          --IF (( l_msg_tbl(i).error_status = 'E' ) AND (INSTR(l_msg_tbl(i).data,'residual value IS less than 20') > 0)) THEN
              --l_msg_tbl(i).error_status := 'W';
          --END IF;
      --END LOOP;
      */
      severity := 'S';

      FOR i IN 1 .. l_msg_tbl.COUNT
      LOOP
         IF (l_msg_tbl (i).error_status = 'E') THEN
            severity := 'E';
            EXIT;
         END IF;
      END LOOP;

      x_msg_tbl := l_msg_tbl;

      IF (p_call_mode = 'ACTUAL') THEN
         IF (    (x_return_status = okl_api.g_ret_sts_success)
             AND (severity = 'S')
            ) THEN
            okl_contract_status_pub.update_contract_status (l_api_version,
                                                            p_init_msg_list,
                                                            x_return_status,
                                                            x_msg_count,
                                                            x_msg_data,
                                                            l_passstatus,
                                                            p_chr_id
                                                           );
            okl_book_controller_pvt.update_book_controller_trx
               (p_api_version          => p_api_version,
                p_init_msg_list        => p_init_msg_list,
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                p_khr_id               => p_chr_id,
                p_prog_short_name      => okl_book_controller_pvt.g_validate_contract,
                p_progress_status      => okl_book_controller_pvt.g_prog_sts_complete
               );

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         ELSE
            okl_contract_status_pub.update_contract_status (l_api_version,
                                                            p_init_msg_list,
                                                            x_return_status,
                                                            x_msg_count,
                                                            x_msg_data,
                                                            l_failstatus,
                                                            p_chr_id
                                                           );
            okl_book_controller_pvt.update_book_controller_trx
               (p_api_version          => p_api_version,
                p_init_msg_list        => p_init_msg_list,
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                p_khr_id               => p_chr_id,
                p_prog_short_name      => okl_book_controller_pvt.g_validate_contract,
                p_progress_status      => okl_book_controller_pvt.g_prog_sts_error
               );

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         END IF;

         --call to cascade status on to lines
         okl_contract_status_pub.cascade_lease_status
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => p_chr_id
                                          );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;

                /*
                -- mvasudev, 08/30/2004
                -- Code change to enable Business Event
                */
         --START 21-Dec-2005 cklee     Bug# 4901292                                |
         --      raise_business_event(x_return_status => x_return_status);
         raise_business_event (p_event_name         => g_wf_evt_khr_validated,
                               x_return_status      => x_return_status
                              );

         --END 21-Dec-2005 cklee     Bug# 4901292                                |
         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;

         /*
         -- mvasudev, 08/30/2004
         -- END, Code change to enable Business Event
         */

         -- start: cklee okl.h: leaase app IA Authoring
         -- update item function validation results
         okl_checklist_pvt.update_checklist_function
                                          (p_api_version           => p_api_version,
                                           p_init_msg_list         => p_init_msg_list,
                                           x_return_status         => x_return_status,
                                           x_msg_count             => x_msg_count,
                                           x_msg_data              => x_msg_data,
                                           p_checklist_obj_id      => p_chr_id
                                          );

         IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
            RAISE okc_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
            RAISE okc_api.g_exception_error;
         END IF;

         -- end: cklee okl.h: leaase app IA Authoring

         /*
         -- START 21-Dec-2005 cklee     Bug# 4901292
         -- Code change to enable Business Event
         */
         raise_business_event (p_event_name         => g_wf_evt_chr_list_validated,
                               x_return_status      => x_return_status
                              );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;
      /*
      -- 21-Dec-2005 cklee     Bug# 4901292
      -- END, Code change to enable Business Event
      */
      END IF;

      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   ---
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END execute_qa_check_list;

   PROCEDURE generate_journal_entries (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2 DEFAULT okl_api.g_false,
      p_commit             IN              VARCHAR2 DEFAULT okl_api.g_false,
      p_contract_id        IN              NUMBER,
      p_transaction_type   IN              VARCHAR2,
      p_draft_yn           IN              VARCHAR2 DEFAULT okc_api.g_true,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)        := 'GENERATE_JNL_ENTRIES';
      l_api_version   CONSTANT NUMBER                   := 1;
      l_return_status          VARCHAR2 (1)      := okl_api.g_ret_sts_success;
      l_isallowed              BOOLEAN;
      l_passstatus             VARCHAR2 (256);
      l_failstatus             VARCHAR2 (256);

      CURSOR l_rebooked_csr (chrid NUMBER) IS
         SELECT date_transaction_occurred
           FROM okl_trx_contracts trx, okl_trx_types_tl trx_type
          WHERE trx.khr_id_old = chrid
            AND trx.khr_id_new IS NOT NULL
            AND trx.tsu_code = 'ENTERED'
            AND trx.tcn_type = 'TRBK'
            AND trx.rbr_code IS NOT NULL
            AND trx_type.NAME = 'Rebook'
        --rkuttiya added for 12.1.1 Multi GAAP
            AND trx.representation_type = 'PRIMARY'
        --
            AND trx_type.LANGUAGE = 'US'
            AND trx.try_id = trx_type.ID;

      l_rebooked_rec           l_rebooked_csr%ROWTYPE;
      l_transaction_date       DATE;
      old_rec                  old_csr%ROWTYPE;
      rbk_rec                  rbk_csr%ROWTYPE;

      /*
      -- mvasudev, 08/30/2004
      -- Added PROCEDURE to enable Business Event
      */
      PROCEDURE raise_business_event (x_return_status OUT NOCOPY VARCHAR2) IS
         l_process          VARCHAR2 (20);
         l_parameter_list   wf_parameter_list_t;
      BEGIN
         l_process := okl_lla_util_pvt.get_contract_process (p_contract_id);
         wf_event.addparametertolist (g_wf_itm_contract_id,
                                      p_contract_id,
                                      l_parameter_list
                                     );
         wf_event.addparametertolist (g_wf_itm_contract_process,
                                      l_process,
                                      l_parameter_list
                                     );
         okl_wf_pvt.raise_event (p_api_version        => p_api_version,
                                 p_init_msg_list      => p_init_msg_list,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 p_event_name         => g_wf_evt_khr_gen_journal,
                                 p_parameters         => l_parameter_list
                                );
      EXCEPTION
         WHEN OTHERS THEN
            x_return_status := okl_api.g_ret_sts_unexp_error;
            RAISE okl_api.g_exception_unexpected_error;
      END raise_business_event;
   /*
   -- mvasudev, 08/30/2004
   -- END, PROCEDURE to enable Business Event
   */
   BEGIN
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      l_transaction_date := NULL;

      IF (p_transaction_type = 'Rebook') THEN
         OPEN l_rebooked_csr (p_contract_id);

         FETCH l_rebooked_csr
          INTO l_rebooked_rec;

         CLOSE l_rebooked_csr;

         l_transaction_date := l_rebooked_rec.date_transaction_occurred;
      ELSIF (p_transaction_type = 'Booking') THEN
         OPEN old_csr (p_contract_id);

         FETCH old_csr
          INTO old_rec;

         IF (old_csr%FOUND) THEN
            OPEN rbk_csr (old_rec.orig_system_id1, p_contract_id);

            FETCH rbk_csr
             INTO rbk_rec;

            CLOSE rbk_csr;

            l_transaction_date := rbk_rec.date_transaction_occurred;
         END IF;

         CLOSE old_csr;
      END IF;

      okl_la_je_pvt.generate_journal_entries (p_api_version,
                                              p_init_msg_list,
                                              p_commit,
                                              p_contract_id,
                                              p_transaction_type,
                                              l_transaction_date,
                                              p_draft_yn,
                                              okl_api.g_true,
                                              x_return_status,
                                              x_msg_count,
                                              x_msg_data
                                             );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      okl_api.set_message (p_app_name      => g_app_name,
                           p_msg_name      => 'OKL_LLA_JE_SUCCESS'
                          );
      x_return_status := okl_api.g_ret_sts_success;
      /*
      -- mvasudev, 08/30/2004
      -- Code change to enable Business Event
      */
      raise_business_event (x_return_status => x_return_status);

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      /*
      -- mvasudev, 08/30/2004
      -- END, Code change to enable Business Event
      */
      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END generate_journal_entries;

   PROCEDURE generate_streams (
      p_api_version          IN              NUMBER,
      p_init_msg_list        IN              VARCHAR2 DEFAULT okc_api.g_false,
      p_chr_id               IN              VARCHAR2,
      p_generation_context   IN              VARCHAR2,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_trx_number           OUT NOCOPY      NUMBER,
      x_trx_status           OUT NOCOPY      VARCHAR2
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)     := 'MAP_AND_GEN_STREAMS';
      l_api_version   CONSTANT NUMBER            := 1;
      l_return_status          VARCHAR2 (1)      := okl_api.g_ret_sts_success;
      l_isallowed              BOOLEAN;
      l_passstatus             VARCHAR2 (256);
      l_failstatus             VARCHAR2 (256);

      --Bug# 8756653
      CURSOR tmp_csr (chrid NUMBER) IS
         SELECT NVL (b.template_yn, 'N') template_yn,
                b.orig_system_source_code,
                b.orig_system_id1
           FROM okc_k_headers_b b
          WHERE b.ID = chrid;

      tmp_rec                  tmp_csr%ROWTYPE;

      /*
      -- mvasudev, 08/30/2004
      -- Added PROCEDURE to enable Business Event
      */
      PROCEDURE raise_business_event (x_return_status OUT NOCOPY VARCHAR2) IS
         l_process          VARCHAR2 (20);
         l_parameter_list   wf_parameter_list_t;
      BEGIN
         l_process := okl_lla_util_pvt.get_contract_process (p_chr_id);
         wf_event.addparametertolist (g_wf_itm_contract_id,
                                      p_chr_id,
                                      l_parameter_list
                                     );
         wf_event.addparametertolist (g_wf_itm_contract_process,
                                      l_process,
                                      l_parameter_list
                                     );
         okl_wf_pvt.raise_event (p_api_version        => p_api_version,
                                 p_init_msg_list      => p_init_msg_list,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 p_event_name         => g_wf_evt_khr_gen_strms,
                                 p_parameters         => l_parameter_list
                                );
      EXCEPTION
         WHEN OTHERS THEN
            x_return_status := okl_api.g_ret_sts_unexp_error;
            RAISE okl_api.g_exception_unexpected_error;
      END raise_business_event;
   /*
   -- mvasudev, 08/30/2004
   -- END, PROCEDURE to enable Business Event
   */
   BEGIN
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 3556674
      validate_chr_id (p_chr_id             => p_chr_id,
                       x_return_status      => x_return_status
                      );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 3556674
      OPEN tmp_csr (TO_NUMBER (p_chr_id));

      FETCH tmp_csr
       INTO tmp_rec;

      CLOSE tmp_csr;

      IF (tmp_rec.template_yn = 'Y') THEN
         x_return_status := okl_api.g_ret_sts_error;
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_LLA_NO_STRM_TMPLTC'
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 8756653
      IF (tmp_rec.orig_system_source_code = 'OKL_REBOOK') THEN
        -- Check if contract has been upgraded for effective dated rebook
        OKL_LLA_UTIL_PVT.check_rebook_upgrade
          (p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_chr_id          => tmp_rec.orig_system_id1);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      okl_contract_status_pub.get_contract_status (l_api_version,
                                                   p_init_msg_list,
                                                   x_return_status,
                                                   x_msg_count,
                                                   x_msg_data,
                                                   l_isallowed,
                                                   l_passstatus,
                                                   l_failstatus,
                                                   'STRMGEN',
                                                   p_chr_id
                                                  );

      IF (l_isallowed = FALSE) THEN
         x_return_status := okl_api.g_ret_sts_success;
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_LLA_CTGEN_STRMS'
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 4023501: start - Phasing out Stream generation profile option
      okl_la_stream_pub.gen_intr_extr_stream
                                          (p_api_version              => p_api_version,
                                           p_init_msg_list            => p_init_msg_list,
                                           x_return_status            => x_return_status,
                                           x_msg_count                => x_msg_count,
                                           x_msg_data                 => x_msg_data,
                                           p_khr_id                   => TO_NUMBER
                                                                            (p_chr_id
                                                                            ),
                                           p_generation_ctx_code      => 'AUTH',
                                           x_trx_number               => x_trx_number,
                                           x_trx_status               => x_trx_status
                                          );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 4023501: end
      x_return_status := okl_api.g_ret_sts_success;
      okl_api.set_message (p_app_name      => g_app_name,
                           p_msg_name      => 'OKL_LLA_ST_SUCCESS'
                          );
      --raise SUCCESS_MESSAGE;

      /*
      -- mvasudev, 08/30/2004
      -- Code change to enable Business Event
      */
      raise_business_event (x_return_status => x_return_status);

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

          /*
          -- mvasudev, 08/30/2004
          -- END, Code change to enable Business Event
      */
      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END generate_streams;

----------------------------------------------------------------------------
--start of comments
--API Name    : Approve_Contract
--Description : Called if the contract approval path profile option
--              is set to 'NONE' or the approval process is called
--              from Mass Rebook or Import Contract
--Parameters  : IN - pchr_id - Contract requiring Approval
--History     : 19-Nov-2003  avsingh Bug# 2566822 Created
--end of comments
-----------------------------------------------------------------------------
   PROCEDURE approve_contract (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_chr_id          IN              VARCHAR2
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)       := 'APPROVE_CONTRACT';
      l_api_version   CONSTANT NUMBER              := 1.0;
      l_return_status          VARCHAR2 (1)      := okl_api.g_ret_sts_success;
      l_isallowed              BOOLEAN;
      l_passstatus             VARCHAR2 (100)      := 'APPROVED';
      l_failstatus             VARCHAR2 (100)      := 'PENDING_APPROVAL';
      l_event                  VARCHAR2 (100)
                                 := okl_contract_status_pub.g_k_submit4apprvl;
      l_process_id             NUMBER;
      l_approval_path          VARCHAR2 (30)       DEFAULT 'NONE';

      CURSOR l_sts_csr (chrid NUMBER) IS
         SELECT sts_code,
                NVL (orig_system_source_code, 'XXX') src_code
           FROM okc_k_headers_v
          WHERE ID = chrid;

      l_sts_rec                l_sts_csr%ROWTYPE;
   BEGIN
      l_return_status := okl_api.g_ret_sts_success;
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      OPEN l_sts_csr (TO_NUMBER (p_chr_id));

      FETCH l_sts_csr
       INTO l_sts_rec;

      CLOSE l_sts_csr;

      okl_contract_status_pub.get_contract_status (l_api_version,
                                                   p_init_msg_list,
                                                   x_return_status,
                                                   x_msg_count,
                                                   x_msg_data,
                                                   l_isallowed,
                                                   l_passstatus,
                                                   l_failstatus,
                                                   l_event,
                                                   p_chr_id
                                                  );

      IF (l_isallowed = FALSE) THEN
         x_return_status := okl_api.g_ret_sts_success;

         IF (l_sts_rec.sts_code = 'APPROVED') THEN
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_LLA_ALRDY_APPRVD'
                                );
         ELSE
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_LLA_NOT_COMPLETE'
                                );
         END IF;

         RAISE okl_api.g_exception_error;
      END IF;

      IF (l_return_status = okl_api.g_ret_sts_success) THEN
         --temp fix to set status to approved
         okl_contract_status_pub.update_contract_status (l_api_version,
                                                         p_init_msg_list,
                                                         x_return_status,
                                                         x_msg_count,
                                                         x_msg_data,
                                                         'APPROVED',
                                                         p_chr_id
                                                        );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;
      ELSE
         okl_contract_status_pub.update_contract_status (l_api_version,
                                                         p_init_msg_list,
                                                         x_return_status,
                                                         x_msg_count,
                                                         x_msg_data,
                                                         l_failstatus,
                                                         p_chr_id
                                                        );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;
      END IF;

      --call to cascade status on to lines
      okl_contract_status_pub.cascade_lease_status
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => p_chr_id
                                          );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      ---

      --call post approval process
      okl_contract_book_pvt.post_approval_process
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => p_chr_id,
                                           p_call_mode          => g_auto_approve
                                          );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      ---
      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END approve_contract;

----------------------------------------------------------------------------
--start of comments
--API Name    : Submit_for_Approval
--Description : Called from the contract booking page to initiate the approval
--              process for the contract.
--Parameters  : IN - pchr_id - Contract requiring Approval
--History     : Bug# 2566822 - Integration with approval WF/AME
--              will check the profile and choose appropriate approval
--              patch
--end of comments
-----------------------------------------------------------------------------
   PROCEDURE submit_for_approval (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_chr_id          IN              VARCHAR2
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)         := 'SUBMIT_FOR_APPROVAL';
      l_api_version   CONSTANT NUMBER                       := 1.0;
      l_return_status          VARCHAR2 (1)      := okl_api.g_ret_sts_success;
      l_isallowed              BOOLEAN;
      l_passstatus             VARCHAR2 (100)               := 'APPROVED';
      l_failstatus             VARCHAR2 (100)           := 'PENDING_APPROVAL';
      l_event                  VARCHAR2 (100)
                                 := okl_contract_status_pub.g_k_submit4apprvl;
      l_process_id             NUMBER;
      l_approval_path          VARCHAR2 (30)                DEFAULT 'NONE';

      CURSOR l_sts_csr (chrid NUMBER) IS
         SELECT sts_code,
                NVL (orig_system_source_code, 'XXX') src_code
           FROM okc_k_headers_v
          WHERE ID = chrid;

      l_sts_rec                l_sts_csr%ROWTYPE;

      --Bug# 4502754
      --cursor to check for vendor program template
      CURSOR l_chk_template_csr (p_chr_id IN NUMBER) IS
         SELECT CHR.template_yn,
                khr.template_type_code
           FROM okc_k_headers_b CHR, okl_k_headers khr
          WHERE CHR.ID = p_chr_id AND CHR.ID = khr.ID;

      l_chk_template_rec       l_chk_template_csr%ROWTYPE;

    /*
    -- mvasudev, 08/30/2004
    -- Added PROCEDURE to enable Business Event
    */
-- START 21-Dec-2005 cklee     Bug# 4901292
-- PROCEDURE raise_business_event(x_return_status OUT NOCOPY VARCHAR2
      PROCEDURE raise_business_event (
         p_event_name      IN              VARCHAR2,
         x_return_status   OUT NOCOPY      VARCHAR2
-- END 21-Dec-2005 cklee     Bug# 4901292
      ) IS
         l_process          VARCHAR2 (20);
         l_parameter_list   wf_parameter_list_t;
      BEGIN
         l_process := okl_lla_util_pvt.get_contract_process (p_chr_id);
         wf_event.addparametertolist (g_wf_itm_contract_id,
                                      p_chr_id,
                                      l_parameter_list
                                     );
         wf_event.addparametertolist (g_wf_itm_contract_process,
                                      l_process,
                                      l_parameter_list
                                     );
         okl_wf_pvt.raise_event (p_api_version        => p_api_version,
                                 p_init_msg_list      => p_init_msg_list,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
-- START 21-Dec-2005 cklee     Bug# 4901292
--                       p_event_name     => G_WF_EVT_KHR_SUBMIT_APPR,
                                 p_event_name         => p_event_name,
-- START 21-Dec-2005 cklee     Bug# 4901292
                                 p_parameters         => l_parameter_list
                                );
      EXCEPTION
         WHEN OTHERS THEN
            x_return_status := okl_api.g_ret_sts_unexp_error;
            RAISE okl_api.g_exception_unexpected_error;
      END raise_business_event;
   /*
   -- mvasudev, 08/30/2004
   -- END, PROCEDURE to enable Business Event
   */
   BEGIN
      l_return_status := okl_api.g_ret_sts_success;
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 3556674
      validate_chr_id (p_chr_id             => p_chr_id,
                       x_return_status      => x_return_status
                      );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 3556674
      OPEN l_sts_csr (TO_NUMBER (p_chr_id));

      FETCH l_sts_csr
       INTO l_sts_rec;

      CLOSE l_sts_csr;

      okl_contract_status_pub.get_contract_status (l_api_version,
                                                   p_init_msg_list,
                                                   x_return_status,
                                                   x_msg_count,
                                                   x_msg_data,
                                                   l_isallowed,
                                                   l_passstatus,
                                                   l_failstatus,
                                                   l_event,
                                                   p_chr_id
                                                  );

      IF (l_isallowed = FALSE) THEN
         x_return_status := okl_api.g_ret_sts_success;

         IF (l_sts_rec.sts_code = 'APPROVED') THEN
            okl_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_LLA_ALRDY_APPRVD'
                                );
         ELSE
            --Bug# 4502754
            OPEN l_chk_template_csr (p_chr_id => p_chr_id);

            FETCH l_chk_template_csr
             INTO l_chk_template_rec;

            CLOSE l_chk_template_csr;

            IF    (    l_chk_template_rec.template_yn = 'Y'
                   AND l_chk_template_rec.template_type_code = 'PROGRAM'
                  )
               OR
                  --Bug# 4874338
                  (    l_chk_template_rec.template_yn = 'Y'
                   AND l_chk_template_rec.template_type_code = 'LEASEAPP'
                  ) THEN
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_LLA_NOT_PASSED'
                                   );
            ELSE
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_LLA_NOT_COMPLETE'
                                   );
            END IF;
         END IF;

         RAISE okl_api.g_exception_error;
      END IF;

-- start: cklee okl.h: leaase app IA Authoring
       -- update item function validation results
      okl_checklist_pvt.update_checklist_function
                                          (p_api_version           => p_api_version,
                                           p_init_msg_list         => p_init_msg_list,
                                           x_return_status         => x_return_status,
                                           x_msg_count             => x_msg_count,
                                           x_msg_data              => x_msg_data,
                                           p_checklist_obj_id      => p_chr_id
                                          );

      IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
         RAISE okc_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
         RAISE okc_api.g_exception_error;
      END IF;

-- end: cklee okl.h: leaase app IA Authoring

      /*
      -- START 21-Dec-2005 cklee     Bug# 4901292
      -- Code change to enable Business Event
      */
      raise_business_event (p_event_name         => g_wf_evt_chr_list_validated,
                            x_return_status      => x_return_status
                           );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      /*
      -- 21-Dec-2005 cklee     Bug# 4901292
      -- END, Code change to enable Business Event
      */

      --read profile for approval path
      l_approval_path :=
                     fnd_profile.VALUE ('OKL_LEASE_CONTRACT_APPROVAL_PROCESS');

      IF NVL (l_approval_path, 'NONE') = 'NONE' THEN
         -- Change Status
         IF (l_return_status = okl_api.g_ret_sts_success) THEN
            --temp fix to set status to approved
            okl_contract_status_pub.update_contract_status (l_api_version,
                                                            p_init_msg_list,
                                                            x_return_status,
                                                            x_msg_count,
                                                            x_msg_data,
                                                            'APPROVED',
                                                            p_chr_id
                                                           );

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         ELSE
            okl_contract_status_pub.update_contract_status (l_api_version,
                                                            p_init_msg_list,
                                                            x_return_status,
                                                            x_msg_count,
                                                            x_msg_data,
                                                            l_failstatus,
                                                            p_chr_id
                                                           );

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         END IF;

         --call to cascade status on to lines
         okl_contract_status_pub.cascade_lease_status
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => p_chr_id
                                          );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;

         ---

         --call post approval process
         okl_contract_book_pvt.post_approval_process
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => p_chr_id,
                                           p_call_mode          => g_auto_approve
                                          );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;
      ---
      ELSIF NVL (l_approval_path, 'NONE') IN ('AME', 'WF') THEN
         okl_book_controller_pvt.update_book_controller_trx
             (p_api_version          => p_api_version,
              p_init_msg_list        => p_init_msg_list,
              x_return_status        => x_return_status,
              x_msg_count            => x_msg_count,
              x_msg_data             => x_msg_data,
              p_khr_id               => p_chr_id,
              p_prog_short_name      => okl_book_controller_pvt.g_submit_contract,
              p_progress_status      => okl_book_controller_pvt.g_prog_sts_running
             );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;

         okl_kbk_approvals_wf.raise_approval_event
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_contract_id        => p_chr_id
                                          );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;
      ---
      END IF;

       /*
       -- mvasudev, 08/30/2004
       -- Code change to enable Business Event
       */
-- START 21-Dec-2005 cklee     Bug# 4901292
      raise_business_event (p_event_name         => g_wf_evt_khr_submit_appr,
                            x_return_status      => x_return_status
                           );

-- END 21-Dec-2005 cklee     Bug# 4901292
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      /*
      -- mvasudev, 08/30/2004
      -- END, Code change to enable Business Event
      */
      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END submit_for_approval;

------------------------------------------------------------------
--start of comments
--API Name    : post_approval_process
--Description : Called by contract approval process after the contract
--              is approved. Will be called by online approval or
--              WF/AME after contract has been approved.
--Parameters  : IN - p_chr_id Varchar2 : Contract identifier
--History     : 19-Nov-2003 avsingh  Bug# 2566822 Created
--                                   by modifying original
--                                   submit_for_Approval API
--end of comments
-------------------------------------------------------------------
   PROCEDURE post_approval_process (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_chr_id          IN              VARCHAR2,
      p_call_mode       IN              VARCHAR2 DEFAULT NULL
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)       := 'POST_APPROVAL_PROCESS';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_return_status          VARCHAR2 (1)      := okl_api.g_ret_sts_success;

      CURSOR l_sts_csr (chrid NUMBER) IS
         SELECT sts_code,
                NVL (orig_system_source_code, 'XXX') src_code
           FROM okc_k_headers_v
          WHERE ID = chrid;

      l_sts_rec                l_sts_csr%ROWTYPE;

      CURSOR l_svclne_csr (ltycode VARCHAR2, chrid okl_k_headers.khr_id%TYPE) IS
         SELECT cle.ID,
                cle.price_negotiated amount
           FROM okc_k_lines_b cle, okc_line_styles_b ls, okc_statuses_b sts
          WHERE cle.lse_id = ls.ID
            AND ls.lty_code = ltycode
            AND cle.dnz_chr_id = chrid
            AND sts.code = cle.sts_code
            AND sts.ste_code NOT IN
                               ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

      x_link_line_tbl          okl_service_integration_pub.link_line_tbl_type;
      x_service_contract_id    NUMBER;
      l_svclne                 l_svclne_csr%ROWTYPE;
      i                        NUMBER;
      j                        NUMBER;
      n                        NUMBER;

      CURSOR l_rl_csr1 (
         rgcode   okc_rule_groups_b.rgd_code%TYPE,
         rlcat    okc_rules_b.rule_information_category%TYPE,
         chrid    NUMBER,
         cleid    NUMBER
      ) IS
         SELECT   crl.ID slh_id,
                  crl.object1_id1,
                  crl.rule_information1,
                  crl.rule_information2,
                  crl.rule_information3,
                  crl.rule_information5,
                  crl.rule_information6,
                  crl.rule_information7,
                  crl.rule_information10
             FROM okc_rule_groups_b crg, okc_rules_b crl
            WHERE crl.rgp_id = crg.ID
              AND crg.rgd_code = rgcode
              AND crl.rule_information_category = rlcat
              AND crg.dnz_chr_id = chrid
              AND NVL (crg.cle_id, -1) = cleid
         ORDER BY crl.rule_information1;

      l_rl_rec1                l_rl_csr1%ROWTYPE;
      l_rl_rec2                l_rl_csr1%ROWTYPE;

      --Bug# 3257595 : OKS Rules Migration
      CURSOR l_rl_oks_v10_csr (chrid NUMBER, cleid NUMBER) IS
         SELECT   uom_code,
                  sequence_no,
                  start_date,
                  level_periods,
                  advance_periods,
                  amount,
                  invoice_offset_days,
                  due_arr_yn
             FROM oks_stream_levels_b
            WHERE dnz_chr_id = chrid AND NVL (cle_id, -1) = cleid
         ORDER BY sequence_no;

      l_rl_oks_v10_rec         l_rl_oks_v10_csr%ROWTYPE;

      --Bug# 3257595 : OKS Rules Migration
      CURSOR l_oks_csr (cleid NUMBER, dt DATE) IS
         SELECT   schd.date_to_interface
             FROM okc_rules_v rule,
                  okc_rule_groups_v rg,
                  okc_k_lines_v line,
                  oks_level_elements_v schd
            WHERE rg.ID = rule.rgp_id
              AND rg.cle_id = line.ID
              AND schd.rul_id = rule.ID
              AND line.ID = cleid
              --Bug# 3124577:11.5.10 Rule Migration
              AND rule.rule_information_category = 'LASLL'
              --AND rule.rule_information_category = 'SLL'
              AND schd.date_to_interface >= dt
         ORDER BY schd.date_to_interface;

      l_oks_rec                l_oks_csr%ROWTYPE;

      --Bug# 3257597 : 11.5.10 OKS Rule Migration Impact
      CURSOR l_oks_v10_csr (cleid NUMBER, dt DATE) IS
         SELECT   schd.date_to_interface
             FROM oks_level_elements_v schd, oks_stream_levels_b strm
            WHERE schd.rul_id = strm.ID
              AND strm.cle_id = cleid
              AND schd.date_to_interface >= dt
         ORDER BY schd.date_to_interface;

      l_oks_v10_rec            l_oks_v10_csr%ROWTYPE;

      --Bug# 3257597 : 11.5.10 OKS Rule Migration Impact
      CURSOR l_finlne_csr (cleid NUMBER) IS
         SELECT object1_id1
           FROM okc_k_items
          WHERE cle_id = cleid;

      l_finlne_rec             l_finlne_csr%ROWTYPE;

      --  nikshah -- Bug # 5484903 Fixed,
      --  Changed CURSOR l_check_date_csr SQL definition
      CURSOR l_check_date_csr (
         p_okl_free_form   okc_k_lines_b.ID%TYPE,
         p_oks_cov_prod    okc_k_lines_b.ID%TYPE
      ) IS
         SELECT 'Y' y
           FROM DUAL
          WHERE EXISTS (
                   SELECT 'Y' y
                     FROM okl_strm_elements_v ele,
                          okl_streams_v strm,
                          okl_strm_type_v strm_type
                    WHERE strm.kle_id =
                             p_okl_free_form
                                     --288266273543735169864512904074336514176
                      AND strm.ID = ele.stm_id
                      AND strm.sty_id = strm_type.ID
                      AND strm_type.NAME = 'RENT'
                      AND strm.say_code = 'CURR'
                      AND strm.active_yn = 'Y'
                      AND EXISTS (
                             SELECT schd.date_to_interface
                               FROM okc_rules_v rule,
                                    okc_rule_groups_v rg,
                                    okc_k_lines_v line,
                                    oks_level_elements_v schd
                              WHERE rg.ID = rule.rgp_id
                                AND rg.cle_id = line.ID
                                AND schd.rul_id = rule.ID
                                AND line.ID =
                                       p_oks_cov_prod
                                    -- 288176626842234160596172204397403418752
                                AND rule.rule_information_category = 'SLL'
                                AND schd.date_to_interface =
                                                       ele.stream_element_date));

      l_check_date_rec         l_check_date_csr%ROWTYPE;

--Bug# 3257597 : 11.5.10 OKS Rules Migration Impact
--  nikshah -- Bug # 5484903 Fixed
--  Changed CURSOR l_check_date_v10_csr SQL definition
      CURSOR l_check_date_v10_csr (
         p_okl_free_form   okc_k_lines_b.ID%TYPE,
         p_oks_cov_prod    okc_k_lines_b.ID%TYPE
      ) IS
         SELECT 'Y' y
           FROM DUAL
          WHERE EXISTS (
                   SELECT 'Y' y
                     FROM okl_strm_elements_v ele,
                          okl_streams_v strm,
                          okl_strm_type_v strm_type
                    WHERE strm.kle_id =
                             p_okl_free_form
                                     --288266273543735169864512904074336514176
                      AND strm.ID = ele.stm_id
                      AND strm.sty_id = strm_type.ID
--udhenuko bug 5665097 start Using Stream Type purpose instead of Name
                      AND strm_type.stream_type_purpose = 'RENT'
--udhenuko bug 5665097 end
                      AND strm.say_code = 'CURR'
                      AND strm.active_yn = 'Y'
                      AND EXISTS (
                             SELECT schd.date_to_interface
                               FROM oks_level_elements_v schd,
                                    oks_stream_levels_b strm
                              WHERE schd.rul_id = strm.ID
                                AND strm.cle_id = p_oks_cov_prod
                                AND schd.date_to_interface =
                                                       ele.stream_element_date));

      l_check_date_v10_rec     l_check_date_v10_csr%ROWTYPE;

--Bug# 3257597 : 11.5.10 OKS Rules Migration Impact
      CURSOR l_name_csr (n VARCHAR2) IS
         SELECT NAME
           FROM okl_time_units_v
          WHERE id1 = n;

      l_name_rec1              l_name_csr%ROWTYPE;
      l_name_rec2              l_name_csr%ROWTYPE;

      --Bug# 3257597 : 11.5.10 OKS rule migration impact
      CURSOR l_chk_oks_rulemig_csr IS
         SELECT 'Y'
           FROM okc_class_operations
          WHERE cls_code = 'SERVICE' AND opn_code = 'CHECK_RULE';

      l_oks_rulemig_exists     VARCHAR2 (1)                        DEFAULT 'N';
      --Bug# 3257597 : 11.5.10 OKS rule migration impact
      l_approval_path          VARCHAR2 (30)                    DEFAULT 'NONE';
      l_process_status         VARCHAR2 (30);

      --Cursor to check existence of contract trx records
      CURSOR c_book_ctrl_trx (p_khr_id IN NUMBER) IS
         SELECT 'Y'
           FROM okl_book_controller_trx
          WHERE khr_id = p_khr_id
            AND progress_status = 'PENDING'
            AND NVL (active_flag, 'N') = 'N';

      l_exists                 VARCHAR2 (1)                        DEFAULT 'N';
   BEGIN
      l_return_status := okl_api.g_ret_sts_success;
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 3257597 : 11.5.10 OKS Rules migration impact :
      l_oks_rulemig_exists := 'N';

      OPEN l_chk_oks_rulemig_csr;

      FETCH l_chk_oks_rulemig_csr
       INTO l_oks_rulemig_exists;

      IF l_chk_oks_rulemig_csr%NOTFOUND THEN
         NULL;
      END IF;

      CLOSE l_chk_oks_rulemig_csr;

      --Bug# 3257597 : 11.5.10 OKS Rules migration impact :
      OPEN l_sts_csr (TO_NUMBER (p_chr_id));

      FETCH l_sts_csr
       INTO l_sts_rec;

      CLOSE l_sts_csr;

------------------------------------------------------------------
--Bug# 2566822 : following code which was part of original
--submit_for_approval has been moved to the new submit_for_approval
--API . So it is being commented
/*---------------------------------------------------------------
    okl_contract_status_pub.get_contract_status( l_api_version,
                                                 p_init_msg_list,
                                                 x_return_status,
                                                 x_msg_count,
                                                 x_msg_data,
                                                 l_isAllowed,
                                                 l_PassStatus,
                                                 l_FailStatus,
                                                 l_event,
                                                 p_chr_id );

    if( l_isAllowed = FALSE ) then
        x_return_status := OKL_API.G_RET_STS_SUCCESS;


   if ( l_sts_rec.sts_code = 'APPROVED') Then
            OKL_API.set_message(
                   p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKL_LLA_ALRDY_APPRVD');
        Else
            OKL_API.set_message(
                   p_app_name      => G_APP_NAME,
                   p_msg_name      => 'OKL_LLA_NOT_COMPLETE');
        End If;

        RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    -- Change Status
    IF(l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
        --temp fix to set status to approved
        okl_contract_status_pub.update_contract_status(
                                       l_api_version,
                                       p_init_msg_list,
                                       x_return_status,
                                       x_msg_count,
                                       x_msg_data,
                                       'APPROVED',
                                       p_chr_id );
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR)  THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
    ELSE
        okl_contract_status_pub.update_contract_status(
                                       l_api_version,
                                       p_init_msg_list,
                                       x_return_status,
                                       x_msg_count,
                                       x_msg_data,
                                       l_failStatus,
                                       p_chr_id );
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR)  THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
    END IF;

    --call to cascade status on to lines
        OKL_CONTRACT_STATUS_PUB.cascade_lease_status
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => p_chr_id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        ---
--------------------------------------------------------------------------------*/
--Bug# 2566822 : End of commented code
---------------------------------------------------------------------------------
--Bug# 4478685 : commented
/*---------------------------------------------------------------------------
IF (( l_sts_rec.src_code = 'XXX') OR
    ( l_sts_rec.src_code = 'OKL_REBOOK' ) OR
    ( l_sts_rec.src_code = 'OKC_HDR' )  )THEN
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data    => x_msg_data);


    COMMIT;
    x_return_status := OKL_API.START_ACTIVITY(
         p_api_name      => l_api_name,
         p_pkg_name      => g_pkg_name,
         p_init_msg_list => p_init_msg_list,
         l_api_version   => l_api_version,
         p_api_version   => p_api_version,
         p_api_type      => G_API_TYPE,
         x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

END IF;
-------------------------------------------------------------------*/

      -- Bug# 3800843 - Changed p_api_version from '1.0' to p_api_version
      okl_service_integration_pub.get_service_link_line
                               (p_api_version              => p_api_version,
                                p_init_msg_list            => okl_api.g_false,
                                x_return_status            => x_return_status,
                                x_msg_count                => x_msg_count,
                                x_msg_data                 => x_msg_data,
                                p_lease_contract_id        => p_chr_id,
                                x_link_line_tbl            => x_link_line_tbl,
                                x_service_contract_id      => x_service_contract_id
                               );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      j := 0;

      FOR i IN 1 .. x_link_line_tbl.COUNT
      LOOP
         OPEN l_finlne_csr (x_link_line_tbl (i).okl_service_line_id);

         FETCH l_finlne_csr
          INTO l_finlne_rec;

         CLOSE l_finlne_csr;

         --Bug# 3124577: 11.5.10 Rule Migration
         OPEN l_rl_csr1 ('LALEVL',
                         'LASLL',
                         p_chr_id,
                         TO_NUMBER (l_finlne_rec.object1_id1)
                        );

         --OPEN l_rl_csr1( 'LALEVL', 'SLL', p_chr_id, to_NUMBER(l_finlne_rec.object1_id1));
         FETCH l_rl_csr1
          INTO l_rl_rec1;

         CLOSE l_rl_csr1;

         j := j + 1;

         --Bug# 3257592 : 11.5.10 OKS Rule Migration impact
         IF l_oks_rulemig_exists = 'N' THEN
            FOR l_rl_rec2 IN
               l_rl_csr1 ('SVC_K',
                          'SLL',
                          x_service_contract_id,
                          x_link_line_tbl (i).oks_service_line_id
                         )
            LOOP
               IF (   (    UPPER (l_rl_rec2.object1_id1) = 'MTH'
                       AND UPPER (l_rl_rec1.object1_id1) <> 'M'
                      )
                   OR (    UPPER (l_rl_rec2.object1_id1) = 'QRT'
                       AND UPPER (l_rl_rec1.object1_id1) <> 'Q'
                      )
                   OR (    UPPER (l_rl_rec2.object1_id1) = 'YR'
                       AND UPPER (l_rl_rec1.object1_id1) <> 'A'
                      )
                  ) THEN
                  OPEN l_name_csr (UPPER (l_rl_rec1.object1_id1));

                  FETCH l_name_csr
                   INTO l_name_rec1;

                  CLOSE l_name_csr;

                  IF (UPPER (l_rl_rec2.object1_id1) = 'MTH') THEN
                     OPEN l_name_csr ('M');
                  ELSIF (UPPER (l_rl_rec2.object1_id1) = 'QRT') THEN
                     OPEN l_name_csr ('Q');
                  ELSIF (UPPER (l_rl_rec2.object1_id1) = 'YR') THEN
                     OPEN l_name_csr ('A');
                  ELSE
                     OPEN l_name_csr (UPPER (l_rl_rec2.object1_id1));
                  END IF;

                  FETCH l_name_csr
                   INTO l_name_rec2;

                  CLOSE l_name_csr;

                  okl_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => 'OKL_LLA_SERV_PMNT_FREQ',
                                       p_token1            => 'PMNT_FREQ1',
                                       p_token1_value      => l_name_rec2.NAME,
                                       p_token2            => 'PMNT_FREQ2',
                                       p_token2_value      => l_name_rec1.NAME
                                      );

                  IF (   (l_sts_rec.src_code = 'XXX')
                      OR (l_sts_rec.src_code = 'OKL_REBOOK')
                      OR (l_sts_rec.src_code = 'OKC_HDR')
                     ) THEN
                     RAISE okl_api.g_exception_error;
                  END IF;
               END IF;
            END LOOP;
         --Bug# 3257592 : 11.5.10 OKS Rule Migration impact
         ELSIF l_oks_rulemig_exists = 'Y' THEN
            FOR l_rl_oks_v10_rec IN
               l_rl_oks_v10_csr (x_service_contract_id,
                                 x_link_line_tbl (i).oks_service_line_id
                                )
            LOOP
               IF (   (    UPPER (l_rl_oks_v10_rec.uom_code) = 'MTH'
                       AND UPPER (l_rl_rec1.object1_id1) <> 'M'
                      )
                   OR (    UPPER (l_rl_oks_v10_rec.uom_code) = 'QRT'
                       AND UPPER (l_rl_rec1.object1_id1) <> 'Q'
                      )
                   OR (    UPPER (l_rl_oks_v10_rec.uom_code) = 'YR'
                       AND UPPER (l_rl_rec1.object1_id1) <> 'A'
                      )
                  ) THEN
                  OPEN l_name_csr (UPPER (l_rl_rec1.object1_id1));

                  FETCH l_name_csr
                   INTO l_name_rec1;

                  CLOSE l_name_csr;

                  IF (UPPER (l_rl_oks_v10_rec.uom_code) = 'MTH') THEN
                     OPEN l_name_csr ('M');
                  ELSIF (UPPER (l_rl_oks_v10_rec.uom_code) = 'QRT') THEN
                     OPEN l_name_csr ('Q');
                  ELSIF (UPPER (l_rl_oks_v10_rec.uom_code) = 'YR') THEN
                     OPEN l_name_csr ('A');
                  ELSE
                     OPEN l_name_csr (UPPER (l_rl_oks_v10_rec.uom_code));
                  END IF;

                  FETCH l_name_csr
                   INTO l_name_rec2;

                  CLOSE l_name_csr;

                  okl_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => 'OKL_LLA_SERV_PMNT_FREQ',
                                       p_token1            => 'PMNT_FREQ1',
                                       p_token1_value      => l_name_rec2.NAME,
                                       p_token2            => 'PMNT_FREQ2',
                                       p_token2_value      => l_name_rec1.NAME
                                      );

                  IF (   (l_sts_rec.src_code = 'XXX')
                      OR (l_sts_rec.src_code = 'OKL_REBOOK')
                      OR (l_sts_rec.src_code = 'OKC_HDR')
                     ) THEN
                     RAISE okl_api.g_exception_error;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         --Bug# 3257592 End.

         --Bug# 3257592 : 11.5.10 OKS rules migration impacts
         IF l_oks_rulemig_exists = 'N' THEN
            OPEN l_check_date_csr (TO_NUMBER (l_finlne_rec.object1_id1),
                                   x_link_line_tbl (i).oks_service_line_id
                                  );

            FETCH l_check_date_csr
             INTO l_check_date_rec;

            CLOSE l_check_date_csr;

-- nikshah -- Bug # 5484903 start, replaced with new IF condition
            IF (NVL (l_check_date_rec.y, 'X') <> 'Y') THEN
-- nikshah -- Bug # 5484903 end
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_LLA_SERV_SCHDT_DATE'
                                   );

               IF (   (l_sts_rec.src_code = 'XXX')
                   OR (l_sts_rec.src_code = 'OKL_REBOOK')
                   OR (l_sts_rec.src_code = 'OKC_HDR')
                  ) THEN
                  RAISE okl_api.g_exception_error;
               END IF;
            END IF;
         ELSIF l_oks_rulemig_exists = 'Y' THEN
            OPEN l_check_date_v10_csr (TO_NUMBER (l_finlne_rec.object1_id1),
                                       x_link_line_tbl (i).oks_service_line_id
                                      );

            FETCH l_check_date_v10_csr
             INTO l_check_date_v10_rec;

            CLOSE l_check_date_v10_csr;

-- nikshah -- Bug # 5484903 start, replaced with new IF condition
            IF (NVL (l_check_date_v10_rec.y, 'X') <> 'Y') THEN
-- nikshah -- Bug # 5484903 end
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_LLA_SERV_SCHDT_DATE'
                                   );

               IF (   (l_sts_rec.src_code = 'XXX')
                   OR (l_sts_rec.src_code = 'OKL_REBOOK')
                   OR (l_sts_rec.src_code = 'OKC_HDR')
                  ) THEN
                  RAISE okl_api.g_exception_error;
               END IF;
            END IF;
         END IF;
      --Bug# 3257593 End.
      END LOOP;

      --Call contract activation if approval path is AME or WF and approval is complete
      --Do not call contract activation if the approval path is NONE or if the contract is
      --being auto-approved in Mass Rebook or Import flow
      IF (p_call_mode = g_auto_approve) THEN
         NULL;
      ELSE
         -- Open the cursor to see Batch or Online Booking
         OPEN c_book_ctrl_trx (p_khr_id => p_chr_id);

         FETCH c_book_ctrl_trx
          INTO l_exists;

         CLOSE c_book_ctrl_trx;

         IF (l_exists = 'Y') THEN
            okl_book_controller_pvt.submit_controller_prg2
                                         (p_api_version        => p_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_khr_id             => p_chr_id
                                         );

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         ELSE
            okl_contract_book_pvt.approve_activate_contract
                                        (p_api_version         => p_api_version,
                                         p_init_msg_list       => p_init_msg_list,
                                         x_return_status       => x_return_status,
                                         x_msg_count           => x_msg_count,
                                         x_msg_data            => x_msg_data,
                                         p_chr_id              => p_chr_id,
                                         x_process_status      => l_process_status
                                        );

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         END IF;
      END IF;

      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END post_approval_process;

--Bug# 3948361 - Transfer and assumption changes
-------------------------------------------------------------------------------
---------------------Terminate Original Contract-------------------------------
-------------------------------------------------------------------------------
   PROCEDURE terminate_original_contract (
      p_api_version               IN              NUMBER,
      p_init_msg_list             IN              VARCHAR2
            DEFAULT okl_api.g_false,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      p_chr_id                    IN              okc_k_headers_b.ID%TYPE,
      x_termination_complete_yn   OUT NOCOPY      VARCHAR2
   ) IS
      l_api_name                   VARCHAR2 (35)  := 'TERM_ORIGINAL_CONTRACT';
      l_proc_name                  VARCHAR2 (35)  := 'TERM_ORIGINAL_CONTRACT';
      ln_orig_system_source_code   okc_k_headers_b.orig_system_source_code%TYPE;
      ln_orig_system_id1           okc_k_headers_b.orig_system_id1%TYPE;
      ln_orig_contract_number      okc_k_headers_b.contract_number%TYPE;

      -- To get the orig system id for p_chr_id
      CURSOR get_orig_sys_code (p_chr_id okc_k_headers_b.ID%TYPE) IS
         SELECT chr_new.orig_system_source_code,
                chr_new.orig_system_id1,
                chr_old.contract_number
           FROM okc_k_headers_b chr_new, okc_k_headers_b chr_old
          WHERE chr_new.ID = p_chr_id AND chr_old.ID = chr_new.orig_system_id1;

      l_assn_tbl                   okl_am_create_quote_pvt.assn_tbl_type;
      l_assn_rec                   okl_am_create_quote_pvt.assn_rec_type;
      l_quot_rec                   okl_am_create_quote_pvt.quot_rec_type;
      l_tqlv_tbl                   okl_am_create_quote_pvt.tqlv_tbl_type;
      l_qpyv_tbl                   okl_am_create_quote_pvt.qpyv_tbl_type;
      x_quot_rec                   okl_am_create_quote_pvt.quot_rec_type;
      x_tqlv_tbl                   okl_am_create_quote_pvt.tqlv_tbl_type;
      x_qpyv_tbl                   okl_am_create_quote_pvt.qpyv_tbl_type;
      x_assn_tbl                   okl_am_create_quote_pvt.assn_tbl_type;
      l_term_rec                   okl_am_termnt_quote_pvt.term_rec_type;
      x_term_rec                   okl_am_termnt_quote_pvt.term_rec_type;
      x_err_msg                    VARCHAR2 (2000);

      CURSOR taa_trx_csr (p_orig_chr_id IN NUMBER, p_new_chr_id IN NUMBER) IS
         SELECT tcn.ID,
                tcn.source_trx_id,
                tcn.date_transaction_occurred,
                tcn.qte_id
           FROM okl_trx_contracts tcn, okl_trx_types_tl try
          WHERE tcn.khr_id_old = p_orig_chr_id
            AND tcn.khr_id_new = p_new_chr_id
            AND tcn_type = 'MAE'
            AND tcn.tsu_code <> 'PROCESSED'
            AND tcn.try_id = try.ID
--rkuttiya added for 12.1.1 Multi GAAP Project
            AND tcn.representation_type = 'PRIMARY'
--
            AND try.NAME = 'Release'
            AND try.LANGUAGE = 'US';

      taa_trx_rec                  taa_trx_csr%ROWTYPE;

      CURSOR taa_term_assets_csr (
         p_orig_chr_id     IN   NUMBER,
         p_source_trx_id   IN   NUMBER
      ) IS
         SELECT fin_ast_cle.ID asset_id,
                fab.asset_number asset_number,
                fab.current_units current_units
           FROM okl_txl_cntrct_lns tcl,
                okc_k_lines_b fin_ast_cle,
                okc_k_lines_b fa_cle,
                okc_line_styles_b fa_lse,
                okc_k_items cim,
                fa_additions_b fab
          WHERE tcl.tcn_id = p_source_trx_id
            AND tcl.before_transfer_yn = 'N'
            AND fin_ast_cle.chr_id = p_orig_chr_id
            AND fin_ast_cle.dnz_chr_id = p_orig_chr_id
            AND fin_ast_cle.ID = tcl.kle_id
            AND fa_cle.dnz_chr_id = fin_ast_cle.chr_id
            AND fa_cle.cle_id = fin_ast_cle.ID
            AND fa_cle.lse_id = fa_lse.ID
            AND fa_lse.lty_code = 'FIXED_ASSET'
            AND cim.cle_id = fa_cle.ID
            AND cim.dnz_chr_id = fa_cle.dnz_chr_id
            AND fab.asset_id = cim.object1_id1;

      CURSOR chr_term_assets_csr (p_orig_chr_id IN NUMBER) IS
         SELECT fin_ast_cle.ID asset_id,
                fab.asset_number asset_number,
                fab.current_units current_units
           FROM okc_k_lines_b fin_ast_cle,
                okc_k_lines_b fa_cle,
                okc_k_headers_b CHR,
                okc_line_styles_b fin_ast_lse,
                okc_line_styles_b fa_lse,
                okc_k_items cim,
                fa_additions_b fab
          WHERE CHR.ID = p_orig_chr_id
            AND fin_ast_cle.chr_id = CHR.ID
            AND fin_ast_cle.dnz_chr_id = CHR.ID
            AND fin_ast_cle.sts_code = CHR.sts_code
            AND fin_ast_cle.lse_id = fin_ast_lse.ID
            AND fin_ast_lse.lty_code = 'FREE_FORM1'
            AND fa_cle.dnz_chr_id = fin_ast_cle.chr_id
            AND fa_cle.cle_id = fin_ast_cle.ID
            AND fa_cle.lse_id = fa_lse.ID
            AND fa_lse.lty_code = 'FIXED_ASSET'
            AND cim.cle_id = fa_cle.ID
            AND cim.dnz_chr_id = fa_cle.dnz_chr_id
            AND fab.asset_id = cim.object1_id1;

      CURSOR chk_taa_term_csr (
         p_orig_chr_id     IN   NUMBER,
         p_source_trx_id   IN   NUMBER
      ) IS
         SELECT fin_ast_cle.ID,
                fin_ast_cle.sts_code
           FROM okl_txl_cntrct_lns tcl, okc_k_lines_b fin_ast_cle
          WHERE tcl.tcn_id = p_source_trx_id
            AND tcl.before_transfer_yn = 'N'
            AND fin_ast_cle.chr_id = p_orig_chr_id
            AND fin_ast_cle.dnz_chr_id = p_orig_chr_id
            AND fin_ast_cle.ID = tcl.kle_id
            AND fin_ast_cle.sts_code <> 'TERMINATED';

      chk_taa_term_rec             chk_taa_term_csr%ROWTYPE;

      CURSOR chk_chr_term_csr (p_orig_chr_id IN NUMBER) IS
         SELECT CHR.sts_code
           FROM okc_k_headers_b CHR
          WHERE ID = p_orig_chr_id;

      chk_chr_term_rec             chk_chr_term_csr%ROWTYPE;

      CURSOR quote_num_csr (p_qte_id IN NUMBER) IS
         SELECT quote_number
           FROM okl_trx_quotes_b
          WHERE ID = p_qte_id;

      quote_num_rec                quote_num_csr%ROWTYPE;
      i                            NUMBER;
      l_tcnv_rec                   okl_trx_contracts_pvt.tcnv_rec_type;
      l_out_tcnv_rec               okl_trx_contracts_pvt.tcnv_rec_type;
      l_termination_complete       VARCHAR2 (30);

      --Bug# 4061058
      CURSOR taa_request_csr (p_source_trx_id IN NUMBER) IS
         SELECT complete_transfer_yn
           FROM okl_trx_contracts
          WHERE ID = p_source_trx_id;

      taa_request_rec              taa_request_csr%ROWTYPE;

      --Bug# 4072796
      CURSOR termination_trx_csr (p_qte_id IN NUMBER, p_khr_id IN NUMBER) IS
         --Bug# 6504515
         --SELECT tsu_code
         SELECT tmt_status_code
           FROM okl_trx_contracts
          WHERE qte_id = p_qte_id
            AND khr_id = p_khr_id
            AND tcn_type IN ('ALT', 'TMT')
  --rkuttiya added for 12.1.1 Multi GAAP Project
            AND representation_type = 'PRIMARY';
  --

      termination_trx_rec          termination_trx_csr%ROWTYPE;
      --Bug# 4515347:
      l_total_count                NUMBER;
      l_error_count                NUMBER;
      l_processed_count            NUMBER;

      --Bug# 4631549
      CURSOR off_lease_ast_csr (p_orig_chr_id IN NUMBER) IS
         SELECT fin_ast_cle.ID
           FROM okc_k_lines_b fin_ast_cle, okc_line_styles_b fin_ast_lse
          WHERE fin_ast_cle.chr_id = p_orig_chr_id
            AND fin_ast_cle.dnz_chr_id = p_orig_chr_id
            AND fin_ast_cle.lse_id = fin_ast_lse.ID
            AND fin_ast_lse.lty_code = 'FREE_FORM1'
            AND fin_ast_cle.sts_code = 'TERMINATED';

      --Bug# 4631549 : modified to calcel hold period trx
      CURSOR chk_off_lease_csr (p_orig_chr_id IN NUMBER) IS
         SELECT tas.ID,
                tas.tsu_code,
                txl.hold_period_days
           FROM okc_k_lines_b fin_ast_cle,
                okc_line_styles_b fin_ast_lse,
                okl_trx_assets tas,
                okl_txl_assets_b txl
          WHERE fin_ast_cle.chr_id = p_orig_chr_id
            AND fin_ast_cle.dnz_chr_id = p_orig_chr_id
            AND fin_ast_cle.lse_id = fin_ast_lse.ID
            AND fin_ast_lse.lty_code = 'FREE_FORM1'
            AND fin_ast_cle.sts_code = 'TERMINATED'
            AND txl.kle_id = fin_ast_cle.ID
            AND tas.ID = txl.tas_id
            AND tas.tas_type IN ('AMT', 'AUD', 'AUS');

      --Bug# 4631549
      --AND    tas.tsu_code <> 'PROCESSED';
      chk_off_lease_rec            chk_off_lease_csr%ROWTYPE;
      --Bug# 4631549
      l_tasv_rec                   okl_trx_assets_pub.thpv_rec_type;
      lx_tasv_rec                  okl_trx_assets_pub.thpv_rec_type;
      -- akrangan added for debug feature start
      l_module_name                VARCHAR2 (500)
                             := g_module_name || 'terminate_original_contract';
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
                                  'p_chr_id = ' || p_chr_id
                                 );
      END IF;

      x_termination_complete_yn := 'Y';
      x_return_status := okl_api.g_ret_sts_success;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status :=
         okl_api.start_activity (l_api_name,
                                 p_init_msg_list,
                                 '_PVT',
                                 x_return_status
                                );

      -- Check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- To get the orig system id for
      OPEN get_orig_sys_code (p_chr_id => p_chr_id);

      FETCH get_orig_sys_code
       INTO ln_orig_system_source_code,
            ln_orig_system_id1,
            ln_orig_contract_number;

      IF get_orig_sys_code%NOTFOUND THEN
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_LLA_NO_MATCHING_RECORD',
                              p_token1            => g_col_name_token,
                              p_token1_value      => 'OKC_K_HEADERS_V.ID'
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      CLOSE get_orig_sys_code;

      IF ln_orig_system_source_code = 'OKL_RELEASE' THEN
         -- Terminate original contract
         OPEN taa_trx_csr (p_orig_chr_id      => ln_orig_system_id1,
                           p_new_chr_id       => p_chr_id
                          );

         FETCH taa_trx_csr
          INTO taa_trx_rec;

         CLOSE taa_trx_csr;

         -- If Termination quote does not exist, initiate Termination process
         IF taa_trx_rec.qte_id IS NULL THEN
            -- Bug# 4072796
            -- Do Re-lease contract validations prior to initiating
            -- Termination
            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'BEFORE OKL_RELEASE_PVT.VALIDATE_RELEASE_CONTRACT CALL'
                     );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'p_chr_id =' || ln_orig_system_id1
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'p_release_date='
                                        || taa_trx_rec.date_transaction_occurred
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'p_source_trx_id='
                                        || taa_trx_rec.source_trx_id
                                       );
            END IF;

            okl_release_pvt.validate_release_contract
                     (p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      p_chr_id             => ln_orig_system_id1,
                      p_release_date       => taa_trx_rec.date_transaction_occurred,
                      p_source_trx_id      => taa_trx_rec.source_trx_id,
                      p_call_program       => 'ACTIVATE'
                     );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug
                      (g_level_statement,
                       l_module_name,
                       'AFTER OKL_RELEASE_PVT.VALIDATE_RELEASE_CONTRACT CALL'
                      );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_return_status =' || x_return_status
                                       );
            END IF;

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;

            l_quot_rec.khr_id := ln_orig_system_id1;
            l_quot_rec.qtp_code := 'TER_RELEASE_WO_PURCHASE';
            l_quot_rec.date_effective_from :=
                                     taa_trx_rec.date_transaction_occurred - 1;

            -- If Transfer and Assumption transaction then
            -- fetch asset lines to be terminated from the
            -- T and A request
            IF (taa_trx_rec.source_trx_id IS NOT NULL) THEN
               --Bug# 4478685
               l_quot_rec.qrs_code := 'TRANSFER_ASSUMPTION';

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'before OKL_AM_CREATE_QUOTE_PUB.create_terminate_quote CALL'
                     );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_quot_rec.khr_id ='
                                           || l_quot_rec.khr_id
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'l_quot_rec.qtp_code ='
                                           || l_quot_rec.qtp_code
                                          );
                  okl_debug_pub.log_debug
                                        (g_level_statement,
                                         l_module_name,
                                            'l_quot_rec.date_effective_from ='
                                         || l_quot_rec.date_effective_from
                                        );
               END IF;

               i := 1;

               FOR taa_term_assets_rec IN
                  taa_term_assets_csr
                                 (p_orig_chr_id        => ln_orig_system_id1,
                                  p_source_trx_id      => taa_trx_rec.source_trx_id
                                 )
               LOOP
                  l_assn_rec.p_asset_id := taa_term_assets_rec.asset_id;
                  l_assn_rec.p_asset_number :=
                                             taa_term_assets_rec.asset_number;
                  l_assn_rec.p_asset_qty := taa_term_assets_rec.current_units;
                  l_assn_rec.p_quote_qty := taa_term_assets_rec.current_units;
                  l_assn_tbl (i) := l_assn_rec;

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug
                                           (g_level_statement,
                                            l_module_name,
                                               'l_assn_rec.p_asset_id     = '
                                            || l_assn_rec.p_asset_id
                                           );
                     okl_debug_pub.log_debug
                                           (g_level_statement,
                                            l_module_name,
                                               'l_assn_rec.p_asset_number  = '
                                            || l_assn_rec.p_asset_number
                                           );
                     okl_debug_pub.log_debug
                                            (g_level_statement,
                                             l_module_name,
                                                'l_assn_rec.p_asset_qty    = '
                                             || l_assn_rec.p_asset_qty
                                            );
                     okl_debug_pub.log_debug
                                           (g_level_statement,
                                            l_module_name,
                                               'l_assn_rec.p_quote_qty     = '
                                            || l_assn_rec.p_quote_qty
                                           );
                  END IF;

                  i := i + 1;
               END LOOP;
            -- If Re-lease contract then terminate all asset lines
            ELSE
               i := 1;

               FOR chr_term_assets_rec IN
                  chr_term_assets_csr (p_orig_chr_id => ln_orig_system_id1)
               LOOP
                  l_assn_rec.p_asset_id := chr_term_assets_rec.asset_id;
                  l_assn_rec.p_asset_number :=
                                             chr_term_assets_rec.asset_number;
                  l_assn_rec.p_asset_qty := chr_term_assets_rec.current_units;
                  l_assn_rec.p_quote_qty := chr_term_assets_rec.current_units;
                  l_assn_tbl (i) := l_assn_rec;

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug
                                           (g_level_statement,
                                            l_module_name,
                                               'l_assn_rec.p_asset_id     = '
                                            || l_assn_rec.p_asset_id
                                           );
                     okl_debug_pub.log_debug
                                           (g_level_statement,
                                            l_module_name,
                                               'l_assn_rec.p_asset_number  = '
                                            || l_assn_rec.p_asset_number
                                           );
                     okl_debug_pub.log_debug
                                            (g_level_statement,
                                             l_module_name,
                                                'l_assn_rec.p_asset_qty    = '
                                             || l_assn_rec.p_asset_qty
                                            );
                     okl_debug_pub.log_debug
                                           (g_level_statement,
                                            l_module_name,
                                               'l_assn_rec.p_quote_qty     = '
                                            || l_assn_rec.p_quote_qty
                                           );
                  END IF;

                  i := i + 1;
               END LOOP;
            END IF;

            okl_am_create_quote_pub.create_terminate_quote
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_quot_rec           => l_quot_rec,
                                           p_assn_tbl           => l_assn_tbl,
                                           p_qpyv_tbl           => l_qpyv_tbl,
                                           x_quot_rec           => x_quot_rec,
                                           x_tqlv_tbl           => x_tqlv_tbl,
                                           x_assn_tbl           => x_assn_tbl
                                          );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug
                  (g_level_statement,
                   l_module_name,
                   'AFTER OKL_AM_CREATE_QUOTE_PUB.create_terminate_quote CALL'
                  );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_return_status =' || x_return_status
                                       );
            END IF;

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;

            l_term_rec.ID := x_quot_rec.ID;
            l_term_rec.accepted_yn := 'Y';

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug
                         (g_level_statement,
                          l_module_name,
                          'Before OKL_TRX_CONTRACTS_PUB.update_trx_contracts'
                         );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_term_rec.id           =>'
                                        || l_term_rec.ID
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_term_rec.accepted_yn         =>'
                                        || l_term_rec.accepted_yn
                                       );
            END IF;

            okl_am_termnt_quote_pub.terminate_quote
                                    (p_api_version            => p_api_version,
                                     p_init_msg_list          => p_init_msg_list,
                                     x_return_status          => x_return_status,
                                     x_msg_count              => x_msg_count,
                                     x_msg_data               => x_msg_data,
                                     p_term_rec               => l_term_rec,
                                     x_term_rec               => x_term_rec,
                                     x_err_msg                => x_err_msg,
                                     p_acceptance_source      => 'RELEASE_CONTRACT'
                                    );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'AFTER OKL_AM_TERMNT_QUOTE_PUB.terminate_quote CALL'
                        );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_return_status =' || x_return_status
                                       );
            END IF;

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;

            -- Save Termination Quote Id on the Transaction row
            l_tcnv_rec.ID := taa_trx_rec.ID;
            l_tcnv_rec.qte_id := x_quot_rec.ID;

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug
                         (g_level_statement,
                          l_module_name,
                          'Before OKL_TRX_CONTRACTS_PUB.update_trx_contracts'
                         );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_tcnv_rec.id           =>'
                                        || taa_trx_rec.ID
                                       );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                           'l_tcnv_rec.qte_id         =>'
                                        || x_quot_rec.ID
                                       );
            END IF;

            okl_trx_contracts_pub.update_trx_contracts
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_tcnv_rec           => l_tcnv_rec,
                                           x_tcnv_rec           => l_out_tcnv_rec
                                          );

            IF (is_debug_statement_on) THEN
               okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'AFTER OKL_AM_TERMNT_QUOTE_PUB.terminate_quote CALL'
                        );
               okl_debug_pub.log_debug (g_level_statement,
                                        l_module_name,
                                        'x_return_status =' || x_return_status
                                       );
            END IF;

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         END IF;                               -- Termination quote exists Y/N

         -- Check if Termination process is Complete
         l_termination_complete := 'Y';

         -- Bug# 4061058
         IF (taa_trx_rec.source_trx_id IS NOT NULL) THEN
            -- For T and A transaction, check if all asset lines in
            -- T and A request are Terminated
            OPEN chk_taa_term_csr
                                (p_orig_chr_id        => ln_orig_system_id1,
                                 p_source_trx_id      => taa_trx_rec.source_trx_id
                                );

            FETCH chk_taa_term_csr
             INTO chk_taa_term_rec;

            IF chk_taa_term_csr%FOUND THEN
               l_termination_complete := 'N';
            END IF;

            CLOSE chk_taa_term_csr;

            -- Check Contract status to confirm if Termination is complete
            IF (l_termination_complete = 'Y') THEN
               OPEN taa_request_csr
                                (p_source_trx_id      => taa_trx_rec.source_trx_id);

               FETCH taa_request_csr
                INTO taa_request_rec;

               CLOSE taa_request_csr;

               OPEN chk_chr_term_csr (p_orig_chr_id => ln_orig_system_id1);

               FETCH chk_chr_term_csr
                INTO chk_chr_term_rec;

               CLOSE chk_chr_term_csr;

               -- For Partial TA check if Original contract status is
               -- Active or Hold
               IF (taa_request_rec.complete_transfer_yn = 'N') THEN
                  IF chk_chr_term_rec.sts_code NOT IN
                        ('BOOKED',
                         'EVERGREEN',
                         'BANKRUPTCY_HOLD',
                         'LITIGATION_HOLD'
                        ) THEN
                     l_termination_complete := 'N';
                  END IF;
               -- For Full TA check if Original contract status is
               -- Terminated
               ELSE
                  IF chk_chr_term_rec.sts_code <> 'TERMINATED' THEN
                     l_termination_complete := 'N';
                  END IF;
               END IF;
            END IF;
         -- For Re-lease Contract, check if Contract is Terminated
         ELSE
            OPEN chk_chr_term_csr (p_orig_chr_id => ln_orig_system_id1);

            FETCH chk_chr_term_csr
             INTO chk_chr_term_rec;

            CLOSE chk_chr_term_csr;

            IF chk_chr_term_rec.sts_code <> 'TERMINATED' THEN
               l_termination_complete := 'N';
            END IF;
         END IF;

         --Bug# 4072796
         -- Check termination transaction status to confirm if Termination is complete
         IF (l_termination_complete = 'Y') THEN
            OPEN termination_trx_csr (p_qte_id      => NVL
                                                          (taa_trx_rec.qte_id,
                                                           x_quot_rec.ID
                                                          ),
                                      p_khr_id      => ln_orig_system_id1
                                     );

            FETCH termination_trx_csr
             INTO termination_trx_rec;

            CLOSE termination_trx_csr;

            --Bug# 6504515
            --if termination_trx_rec.tsu_code <> 'PROCESSED' then
            IF termination_trx_rec.tmt_status_code <> 'PROCESSED' THEN
               l_termination_complete := 'N';
            END IF;
         END IF;

         -- Raise error if Termination process is not complete
         IF (l_termination_complete = 'N') THEN
            OPEN quote_num_csr (p_qte_id      => NVL (taa_trx_rec.qte_id,
                                                      x_quot_rec.ID
                                                     )
                               );

            FETCH quote_num_csr
             INTO quote_num_rec;

            CLOSE quote_num_csr;

            okl_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKL_LLA_REL_TERMN_NO_COMPLETE',
                                p_token1            => 'QUOTE_NUM',
                                p_token1_value      => quote_num_rec.quote_number
                               );
            x_termination_complete_yn := 'N';
            x_return_status := okl_api.g_ret_sts_success;
         END IF;                            --Termination process complete Y/N

         --Bug# 4515347
         --call process FA transactions
         IF x_termination_complete_yn = 'Y' THEN
            --Bug# 4631549
            FOR off_lease_ast_rec IN
               off_lease_ast_csr (p_orig_chr_id => ln_orig_system_id1)
            LOOP
               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'Before OKL_AM_PROCESS_ASSET_TRX_PVT.process_transactions'
                     );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'p_api_version           =>'
                                           || p_api_version
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'p_init_msg_list         =>'
                                           || p_init_msg_list
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'p_contract_id           => '
                                           || ln_orig_system_id1
                                          );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'p_kle_id                => '
                                           || off_lease_ast_rec.ID
                                          );
               END IF;

               okl_am_process_asset_trx_pvt.process_transactions
                                      (p_api_version               => p_api_version,
                                       p_init_msg_list             => p_init_msg_list,
                                       x_return_status             => x_return_status,
                                       x_msg_count                 => x_msg_count,
                                       x_msg_data                  => x_msg_data,
                                       --Bug# 4631549
                                       p_contract_id               => ln_orig_system_id1,
                                       p_asset_id                  => NULL,
                                       p_kle_id                    => off_lease_ast_rec.ID,
                                       --Bug# 4631549
                                       p_salvage_writedown_yn      => 'Y',
                                       x_total_count               => l_total_count,
                                       x_processed_count           => l_processed_count,
                                       x_error_count               => l_error_count
                                      );

               IF (is_debug_statement_on) THEN
                  okl_debug_pub.log_debug
                     (g_level_statement,
                      l_module_name,
                      'AFTER OKL_AM_PROCESS_ASSET_TRX_PVT.process_transactions CALL'
                     );
                  okl_debug_pub.log_debug (g_level_statement,
                                           l_module_name,
                                              'x_return_status ='
                                           || x_return_status
                                          );
               END IF;

               IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
               END IF;
            END LOOP;

            -- Check if Process FA transations is Complete
            --Bug# 4631549
            OPEN chk_off_lease_csr (p_orig_chr_id => ln_orig_system_id1);

            LOOP
               FETCH chk_off_lease_csr
                INTO chk_off_lease_rec;

               EXIT WHEN chk_off_lease_csr%NOTFOUND;

               IF     chk_off_lease_rec.tsu_code NOT IN
                                                    ('PROCESSED', 'CANCELED')
                  AND NVL (chk_off_lease_rec.hold_period_days, 0) = 0 THEN
                  x_termination_complete_yn := 'N';
                  x_return_status := okl_api.g_ret_sts_success;
                  EXIT;
               ELSIF     chk_off_lease_rec.tsu_code NOT IN
                                                    ('PROCESSED', 'CANCELED')
                     AND NVL (chk_off_lease_rec.hold_period_days, 0) > 0 THEN
                  --Mark off-lease transaction as canceled
                  l_tasv_rec.ID := chk_off_lease_rec.ID;
                  l_tasv_rec.tsu_code := 'CANCELED';

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'before okl_trx_assets_pub.update_trx_Ass_h_Def CALL'
                        );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'l_tasv_rec.id  ='
                                              || l_tasv_rec.ID
                                             );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'l_tasv_rec.tsu_code  ='
                                              || l_tasv_rec.tsu_code
                                             );
                  END IF;

                  okl_trx_assets_pub.update_trx_ass_h_def
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_thpv_rec           => l_tasv_rec,
                                           x_thpv_rec           => lx_tasv_rec
                                          );

                  IF (is_debug_statement_on) THEN
                     okl_debug_pub.log_debug
                        (g_level_statement,
                         l_module_name,
                         'AFTER okl_trx_assets_pub.update_trx_Ass_h_Def CALL'
                        );
                     okl_debug_pub.log_debug (g_level_statement,
                                              l_module_name,
                                                 'x_return_status ='
                                              || x_return_status
                                             );
                  END IF;

                  IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                     RAISE okl_api.g_exception_unexpected_error;
                  ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                     RAISE okl_api.g_exception_error;
                  END IF;
               END IF;
            END LOOP;

            CLOSE chk_off_lease_csr;
         --Bug# 4631549
         --if  chk_off_lease_rec.off_lease_exists = 'Y' then
           --x_termination_complete_yn := 'N';
           --x_return_status := OKL_API.G_RET_STS_SUCCESS;
         --end if;
         --Bug# 4631549
         END IF;                                               -- Bug# 4515347
      ELSE
         okl_api.set_message
                    (p_app_name      => g_app_name,
                     p_msg_name      => 'This Contract is not a Re-Lease Contract'
                    );
         RAISE okl_api.g_exception_error;
      END IF;

      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         IF get_orig_sys_code%ISOPEN THEN
            CLOSE get_orig_sys_code;
         END IF;

         x_return_status :=
            okl_api.handle_exceptions
                                     (p_api_name       => l_api_name,
                                      p_pkg_name       => g_pkg_name,
                                      p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_api_type       => g_api_type
                                     );
      WHEN okl_api.g_exception_unexpected_error THEN
         IF get_orig_sys_code%ISOPEN THEN
            CLOSE get_orig_sys_code;
         END IF;

         x_return_status :=
            okl_api.handle_exceptions
                               (p_api_name       => l_api_name,
                                p_pkg_name       => g_pkg_name,
                                p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_api_type       => g_api_type
                               );
      WHEN OTHERS THEN
         IF get_orig_sys_code%ISOPEN THEN
            CLOSE get_orig_sys_code;
         END IF;

         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END terminate_original_contract;

   PROCEDURE activate_contract (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_chr_id          IN              VARCHAR2
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)           := 'ACTIVATE_CONTRACT';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_return_status          VARCHAR2 (1)      := okl_api.g_ret_sts_success;
      l_isallowed              BOOLEAN;
      l_passstatus             VARCHAR2 (100)                     := 'BOOKED';
      l_failstatus             VARCHAR2 (100)                   := 'APPROVED';
      l_event                  VARCHAR2 (100)
                                      := okl_contract_status_pub.g_k_activate;
      l_cimv_tbl               okl_okc_migration_pvt.cimv_tbl_type;
      x_message                VARCHAR2 (256);

      -- Sales Tax project changes START - BUG 4373029
      SUBTYPE tcnv_rec_type IS okl_trx_contracts_pvt.tcnv_rec_type;

      x_trxh_rec               tcnv_rec_type;

      -- Sales Tax project changes END
      CURSOR l_chk_mass_rbk_csr (p_chr_id IN NUMBER) IS
         SELECT 'Y' what
           FROM okc_k_headers_b CHR
          WHERE CHR.ID = p_chr_id
            AND EXISTS (
                   SELECT '1'
                     FROM okl_trx_contracts ktrx
                    WHERE ktrx.khr_id = CHR.ID
                      AND ktrx.tsu_code = 'ENTERED'
                      AND ktrx.rbr_code IS NOT NULL
                      AND ktrx.tcn_type = 'TRBK'
               --rkuttiya added for 12.1.1 Multi GAAP Project
                      AND ktrx.representation_type = 'PRIMARY')
               --
            AND EXISTS (
                   SELECT '1'
                     FROM okl_rbk_selected_contract rbk_khr
                    WHERE rbk_khr.khr_id = CHR.ID
                      AND rbk_khr.status <> 'PROCESSED');

      l_chk_mass_rbk_rec       l_chk_mass_rbk_csr%ROWTYPE;
      l_commit                 VARCHAR2 (256)               := okl_api.g_false;
      l_transaction_type       VARCHAR2 (256);
      l_acct_trans_type        VARCHAR2 (256);                   --Bug 5909373
      l_draft_yn               VARCHAR2 (1)                 := okl_api.g_false;
      l_chr_for_sts_change     NUMBER;
      old_rec                  old_csr%ROWTYPE;
      rbk_rec                  rbk_csr%ROWTYPE;

      CURSOR l_hdr_csr (chrid NUMBER) IS
         SELECT CHR.orig_system_source_code,
                CHR.start_date,
                CHR.template_yn,
                CHR.authoring_org_id,
                CHR.inv_organization_id,
                khr.deal_type,
                pdt.ID pid,
                NVL (pdt.reporting_pdt_id, -1) report_pdt_id,
                CHR.currency_code currency_code,
                khr.term_duration term
           FROM okc_k_headers_v CHR, okl_k_headers khr, okl_products_v pdt
          WHERE khr.ID = CHR.ID AND CHR.ID = chrid AND khr.pdt_id = pdt.ID(+);

      l_hdr_rec                l_hdr_csr%ROWTYPE;
      p_pdtv_rec               okl_setupproducts_pub.pdtv_rec_type;
      x_pdt_parameter_rec      okl_setupproducts_pub.pdt_parameters_rec_type;
      x_no_data_found          BOOLEAN;

        /* Suresh 22-Sep-2004 Start
           update the creditline contract with total rollover amount
        */
      /* Manu 18-Aug-2004 Start
      Cursor to get the rollover fee lines for a contract
      that is booked for the first time. */

      -- nikshah -- Bug # 5484903 Fixed,
      -- Changed l_rq_fee_lns_bkg_csr SQL definition
      CURSOR l_rq_fee_lns_bkg_csr (chrid IN okc_k_headers_b.ID%TYPE) IS
         SELECT kle.qte_id
           FROM okc_k_headers_b khr, okc_k_lines_b cleb, okl_k_lines kle
          WHERE khr.ID = chrid
            AND cleb.dnz_chr_id = khr.ID
            AND kle.ID = cleb.ID
            AND kle.fee_type = 'ROLLOVER'
            AND NOT EXISTS (
                   SELECT 'Y'
                     FROM okc_statuses_b okcsts
                    WHERE okcsts.code = cleb.sts_code
                      AND okcsts.ste_code IN
                             ('EXPIRED',
                              'HOLD',
                              'CANCELLED',
                              'TERMINATED',
                              'ABANDONED'
                             ));

      l_ro_fee_bkg_found       BOOLEAN                                := FALSE;

      /* Cursor to get the NEW rollover fee lines  that are added
          to a re-book contract. */

      -- nikshah -- Bug # 5484903 Fixed
      -- Changed CURSOR l_rq_fee_lns_rbk_csr SQL definition
      CURSOR l_rq_fee_lns_rbk_csr (chrid IN okc_k_headers_b.ID%TYPE) IS
         SELECT kle.qte_id
           FROM okc_k_headers_b khr, okc_k_lines_b cleb, okl_k_lines kle
          WHERE khr.ID = chrid
            AND cleb.dnz_chr_id = khr.ID
            AND kle.ID = cleb.ID
            AND kle.fee_type = 'ROLLOVER'
            AND cleb.orig_system_id1 IS NULL
                                          --This means new Fee Line (top line)
            AND NOT EXISTS (
                   SELECT 'Y'
                     FROM okc_statuses_b okcsts
                    WHERE okcsts.code = cleb.sts_code
                      AND okcsts.ste_code IN
                             ('EXPIRED',
                              'HOLD',
                              'CANCELLED',
                              'TERMINATED',
                              'ABANDONED'
                             ));

      l_ro_fee_rbk_found       BOOLEAN                                := FALSE;

      /* Cursor to check if the contract is rebooked contract. */
      CURSOR l_chk_rbk_csr (chrid IN okc_k_headers_b.ID%TYPE) IS
         SELECT '!'
           FROM okc_k_headers_b CHR
          WHERE CHR.ID = chrid AND CHR.orig_system_source_code = 'OKL_REBOOK';

      l_qte_id                 okl_k_lines.qte_id%TYPE;
      l_creditline_id          okl_k_lines.qte_id%TYPE;
      x_rem_amt                NUMBER;
      p_term_tbl               okl_trx_quotes_pub.qtev_tbl_type;
      x_term_tbl               okl_trx_quotes_pub.qtev_tbl_type;
      x_err_msg                VARCHAR2 (1000);
      l_rbk_khr                VARCHAR2 (1)                        DEFAULT '?';
      l_tq_rec_count           NUMBER                                     := 0;
                                      -- Rollover fee line count on a contract

      /* Manu 18-Aug-2004 End */

      /* Manu 18-Nov-2004 Start */
      /* Cursor to if the contract start date is not in the future
             (less than or equal to SYSDATE). */

      --  nikshah -- Bug # 5484903 Fixed,
      --  Changed CURSOR l_k_std_csr SQL definition
      CURSOR l_k_std_csr (chrid okc_k_headers_b.ID%TYPE) IS
         SELECT 1
           FROM okc_k_lines_v cleb, okl_k_lines kle, okc_k_headers_b khr
          WHERE khr.ID = chrid
            AND cleb.dnz_chr_id = khr.ID
            AND kle.ID = cleb.ID
            AND kle.fee_type = 'ROLLOVER'
            AND TRUNC (khr.start_date) > SYSDATE
            AND NOT EXISTS (
                   SELECT 'Y'
                     FROM okc_statuses_b okcsts
                    WHERE okcsts.code = cleb.sts_code
                      AND okcsts.ste_code IN
                             ('EXPIRED',
                              'HOLD',
                              'CANCELLED',
                              'TERMINATED',
                              'ABANDONED'
                             ));

        /* Cursor for Re-book contract */
      --  nikshah -- Bug # 5484903 Fixed,
      --  Changed CURSOR l_k_std__4rbk_csr SQL definition
      CURSOR l_k_std__4rbk_csr (chrid okc_k_headers_b.ID%TYPE) IS
         SELECT 1
           FROM okc_k_lines_v cleb, okl_k_lines kle, okc_k_headers_b khr
          WHERE khr.ID = chrid
            AND cleb.dnz_chr_id = khr.ID
            AND kle.ID = cleb.ID
            AND kle.fee_type = 'ROLLOVER'
            AND TRUNC (khr.start_date) > SYSDATE
            AND cleb.orig_system_id1 IS NULL
                                          --This means new Fee Line (top line)
            AND NOT EXISTS (
                   SELECT 'Y'
                     FROM okc_statuses_b okcsts
                    WHERE okcsts.code = cleb.sts_code
                      AND okcsts.ste_code IN
                             ('EXPIRED',
                              'HOLD',
                              'CANCELLED',
                              'TERMINATED',
                              'ABANDONED'
                             ));

      l_in_future              BOOLEAN                                := FALSE;
      l_found                  VARCHAR2 (1);

      /* Manu 18-Nov-2004 End */

      --Bug# 3948361: start
      --cursor to check if contract is a re-lease contract
      CURSOR l_chk_rel_khr_csr (p_chr_id IN NUMBER) IS
         SELECT '!'
           FROM okc_k_headers_b CHR
          WHERE CHR.ID = p_chr_id
            AND NVL (CHR.orig_system_source_code, 'XXXX') = 'OKL_RELEASE';

      l_rel_khr                VARCHAR2 (1);
      l_proceed_activation     VARCHAR2 (30);

      --Bug# 3948361: end

      --Bug# 4502754
      --cursor to check for vendor program template
      CURSOR l_chk_template_csr (p_chr_id IN NUMBER) IS
         SELECT CHR.template_yn,
                khr.template_type_code
           FROM okc_k_headers_b CHR, okl_k_headers khr
          WHERE CHR.ID = p_chr_id AND CHR.ID = khr.ID;

      l_chk_template_rec       l_chk_template_csr%ROWTYPE;

      /*
      -- mvasudev, 08/30/2004
      -- Added PROCEDURE to enable Business Event
      */
      CURSOR l_rbk_trx_csr IS
         SELECT ktrx.khr_id,
                ktrx.date_transaction_occurred
           FROM okc_k_headers_b CHR, okl_trx_contracts ktrx
          WHERE ktrx.khr_id_new = CHR.ID
            AND ktrx.tsu_code = 'ENTERED'
            AND ktrx.rbr_code IS NOT NULL
            AND ktrx.tcn_type = 'TRBK'
   --rkuttiya added for 12.1.1 Multi GAAP Project
            AND ktrx.representation_type = 'PRIMARY'
   --
            AND CHR.ID = p_chr_id
            AND CHR.orig_system_source_code = 'OKL_REBOOK';

      l_rbk_khr_id             NUMBER;
      l_rbk_date               DATE;

      --ramurt Bug#4622438
      CURSOR chk_product_status (p_chr_id IN NUMBER) IS
         SELECT pdt.NAME,
                pdt.product_status_code
           FROM okl_products_v pdt, okl_k_headers_v khr, okc_k_headers_b CHR
          WHERE 1 = 1
            AND khr.ID = p_chr_id
            AND pdt_id = pdt.ID
            AND khr.ID = CHR.ID;

      l_product_status_code    okl_products_v.product_status_code%TYPE;
      l_product_name           okl_products_v.NAME%TYPE;
      -- 4577840 end
      l_tcnv_rec               okl_trx_contracts_pvt.tcnv_rec_type;
                                                                   -- 4895333;
      --Bug# 4631549
      l_mass_rebook_yn         VARCHAR2 (1);

      --Bug# 4631549 end
      PROCEDURE raise_business_event (
         p_rbk_khr_id                  IN              NUMBER,
         p_date_transaction_occurred   IN              DATE,
         x_return_status               OUT NOCOPY      VARCHAR2
      ) IS
         l_process          VARCHAR2 (20);
         l_parameter_list   wf_parameter_list_t;
      BEGIN
         x_return_status := okl_api.g_ret_sts_success;
         l_process := okl_lla_util_pvt.get_contract_process (p_chr_id);

         -- Raise "Rebook Completed" for Rebook Process
         FOR l_chk_rbk_rec IN l_chk_rbk_csr (p_chr_id)
         LOOP
            wf_event.addparametertolist (g_wf_itm_src_contract_id,
                                         p_chr_id,
                                         l_parameter_list
                                        );
            wf_event.addparametertolist (g_wf_itm_dest_contract_id,
                                         p_rbk_khr_id,
                                         l_parameter_list
                                        );
            wf_event.addparametertolist
                     (g_wf_itm_trx_date,
                      fnd_date.date_to_canonical (p_date_transaction_occurred),
                      l_parameter_list
                     );
            wf_event.addparametertolist (g_wf_itm_contract_process,
                                         g_khr_process_rebook,
                                         l_parameter_list
                                        );
            okl_wf_pvt.raise_event (p_api_version        => p_api_version,
                                    p_init_msg_list      => p_init_msg_list,
                                    x_return_status      => x_return_status,
                                    x_msg_count          => x_msg_count,
                                    x_msg_data           => x_msg_data,
                                    p_event_name         => g_wf_evt_khr_rebook_comp,
                                    p_parameters         => l_parameter_list
                                   );
         END LOOP;

         -- Raise "Contract Activated" always
         wf_event.addparametertolist (g_wf_itm_contract_id,
                                      p_chr_id,
                                      l_parameter_list
                                     );
         wf_event.addparametertolist (g_wf_itm_contract_process,
                                      l_process,
                                      l_parameter_list
                                     );
         okl_wf_pvt.raise_event (p_api_version        => p_api_version,
                                 p_init_msg_list      => p_init_msg_list,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 p_event_name         => g_wf_evt_khr_activated,
                                 p_parameters         => l_parameter_list
                                );
      EXCEPTION
         WHEN OTHERS THEN
            x_return_status := okl_api.g_ret_sts_unexp_error;
            RAISE okl_api.g_exception_unexpected_error;
      END raise_business_event;
   /*
   -- mvasudev, 08/30/2004
   -- END, PROCEDURE to enable Business Event
   */
   BEGIN
      x_return_status := okl_api.g_ret_sts_success;
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 3556674
      validate_chr_id (p_chr_id             => p_chr_id,
                       x_return_status      => x_return_status
                      );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --Bug# 3556674

      /*
      -- mvasudev, 11/08/2004
      -- Added to enable Business Event
      */
      FOR l_rbk_trx_rec IN l_rbk_trx_csr
      LOOP
         l_rbk_khr_id := l_rbk_trx_rec.khr_id;
         l_rbk_date := l_rbk_trx_rec.date_transaction_occurred;
      END LOOP;

      /*
      -- mvasudev, 11/08/2004
      -- END,Added to enable Business Event
      */
      okl_contract_status_pub.get_contract_status (l_api_version,
                                                   p_init_msg_list,
                                                   x_return_status,
                                                   x_msg_count,
                                                   x_msg_data,
                                                   l_isallowed,
                                                   l_passstatus,
                                                   l_failstatus,
                                                   l_event,
                                                   p_chr_id
                                                  );

      IF (l_isallowed = FALSE) THEN
         x_return_status := okl_api.g_ret_sts_success;
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_LLA_NOT_APPROVED'
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      --ramurt Bug#4622438
      OPEN chk_product_status (p_chr_id => TO_NUMBER (p_chr_id));

      FETCH chk_product_status
       INTO l_product_name,
            l_product_status_code;

      CLOSE chk_product_status;

      IF (l_product_status_code = 'INVALID') THEN
         --   x_return_status := OKL_API.G_RET_STS_SUCCESS;
         okl_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKL_LLA_INVALID_PRODUCT',
                              p_token1            => 'PRODUCT_NAME',
                              p_token1_value      => l_product_name
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      -- End

      --Bug# 3948361
        -- For Re-lease contract, Terminate the Original contract
      l_rel_khr := '?';

      --check for release contract
      OPEN l_chk_rel_khr_csr (p_chr_id => TO_NUMBER (p_chr_id));

      FETCH l_chk_rel_khr_csr
       INTO l_rel_khr;

      IF l_chk_rel_khr_csr%NOTFOUND THEN
         NULL;
      END IF;

      CLOSE l_chk_rel_khr_csr;

      --Bug# 4631549
      l_mass_rebook_yn := okl_api.g_false;
      l_mass_rebook_yn :=
            okl_lla_util_pvt.check_mass_rebook_contract (p_chr_id      => p_chr_id);
      --End Bug# 4631549
      l_proceed_activation := 'Y';

      --Bug# 4631549
      IF l_rel_khr = '!' AND l_mass_rebook_yn = okl_api.g_false THEN
         --IF l_rel_khr = '!' Then
         okl_contract_book_pvt.terminate_original_contract
                           (p_api_version                  => l_api_version,
                            p_init_msg_list                => p_init_msg_list,
                            x_return_status                => x_return_status,
                            x_msg_count                    => x_msg_count,
                            x_msg_data                     => x_msg_data,
                            p_chr_id                       => p_chr_id,
                            x_termination_complete_yn      => l_proceed_activation
                           );

         -- check if activity started successfully
         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- Bug# 4061058
         -- If Termination is successfully completed then
         -- do Commit
         IF l_proceed_activation = 'Y' THEN
            okl_api.end_activity (x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data
                                 );
            COMMIT;
            x_return_status :=
               okl_api.start_activity (p_api_name           => l_api_name,
                                       p_pkg_name           => g_pkg_name,
                                       p_init_msg_list      => p_init_msg_list,
                                       l_api_version        => l_api_version,
                                       p_api_version        => p_api_version,
                                       p_api_type           => g_api_type,
                                       x_return_status      => x_return_status
                                      );

            -- check if activity started successfully
            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         END IF;
      END IF;

      IF l_proceed_activation = 'Y' THEN
         --Bug# 4502754
         -- Vendor Program Template: Start
         -- For Vendor Program Template activation, skip all
         -- processing and set the status to Booked.
         OPEN l_chk_template_csr (p_chr_id => p_chr_id);

         FETCH l_chk_template_csr
          INTO l_chk_template_rec;

         CLOSE l_chk_template_csr;

         IF    (    l_chk_template_rec.template_yn = 'Y'
                AND l_chk_template_rec.template_type_code = 'PROGRAM'
               )
            OR
               --Bug# 4874338:
               (    l_chk_template_rec.template_yn = 'Y'
                AND l_chk_template_rec.template_type_code = 'LEASEAPP'
               ) THEN
            l_chr_for_sts_change := TO_NUMBER (p_chr_id);
            x_return_status := okl_api.g_ret_sts_success;
         ELSE
            OPEN l_hdr_csr (p_chr_id);

            FETCH l_hdr_csr
             INTO l_hdr_rec;

            IF l_hdr_csr%NOTFOUND THEN
               CLOSE l_hdr_csr;

               RAISE okl_api.g_exception_unexpected_error;
            END IF;

            CLOSE l_hdr_csr;

            OPEN old_csr (TO_NUMBER (p_chr_id));

            FETCH old_csr
             INTO old_rec;

            CLOSE old_csr;

----------------------------------------------------------------------------------------
--Bug# 3379294 : Deal type is coming as null on some of the contracts copied from old contracts
--       We should check for it and raise an error here
----------------------------------------------------------------------------------------
            IF NVL (old_rec.deal_type, okl_api.g_miss_char) =
                                                           okl_api.g_miss_char THEN
               --check for incomplete product setup
               p_pdtv_rec.ID := l_hdr_rec.pid;
               okl_setupproducts_pub.getpdt_parameters
                                  (p_api_version            => p_api_version,
                                   p_init_msg_list          => p_init_msg_list,
                                   x_return_status          => x_return_status,
                                   x_msg_count              => x_msg_count,
                                   x_msg_data               => x_msg_data,
                                   p_pdtv_rec               => p_pdtv_rec,
                                   x_no_data_found          => x_no_data_found,
                                   p_pdt_parameter_rec      => x_pdt_parameter_rec
                                  );

               IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
               ELSIF (NVL (x_pdt_parameter_rec.NAME, okl_api.g_miss_char) =
                                                           okl_api.g_miss_char
                     ) THEN
                  x_return_status := okl_api.g_ret_sts_error;
                  RAISE okl_api.g_exception_error;
               END IF;

               --if product setup is also complete raise an error on balnk deal type
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_NULL_DEAL_TYPE'
                                   );
               x_return_status := okl_api.g_ret_sts_error;
               RAISE okl_api.g_exception_error;
            --Bug# : End : modified following 'IF' to 'ELSIF'

            --ELSIF ( old_rec.deal_type <> 'LOAN-REVOLVING' ) THEN -- 4895333
            ELSE
               IF (old_rec.orig_system_source_code = 'OKL_REBOOK') THEN
                  l_transaction_type := 'Rebook';
                  l_chr_for_sts_change := old_rec.orig_system_id1;

                  --Bug# 2857843
                  IF l_transaction_type = 'Booking' THEN
                     p_pdtv_rec.ID := l_hdr_rec.pid;
                     okl_setupproducts_pub.getpdt_parameters
                                  (p_api_version            => p_api_version,
                                   p_init_msg_list          => p_init_msg_list,
                                   x_return_status          => x_return_status,
                                   x_msg_count              => x_msg_count,
                                   x_msg_data               => x_msg_data,
                                   p_pdtv_rec               => p_pdtv_rec,
                                   x_no_data_found          => x_no_data_found,
                                   p_pdt_parameter_rec      => x_pdt_parameter_rec
                                  );

                     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                        RAISE okl_api.g_exception_unexpected_error;
                     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                        RAISE okl_api.g_exception_error;
                     --Bug# 3379294:
                     --ELSIF ( x_pdt_parameter_rec.Name = OKL_API.G_MISS_CHAR )THEN
                     ELSIF NVL (x_pdt_parameter_rec.NAME, okl_api.g_miss_char) =
                                                           okl_api.g_miss_char THEN
                        x_return_status := okl_api.g_ret_sts_error;
                        RAISE okl_api.g_exception_error;
                     END IF;
                  END IF;

                  --Bug Fix# 2857843 End
                  OPEN rbk_csr (l_chr_for_sts_change, TO_NUMBER (p_chr_id));

                  FETCH rbk_csr
                   INTO rbk_rec;

                  CLOSE rbk_csr;

                  okl_la_je_pvt.generate_journal_entries
                                           (l_api_version,
                                            p_init_msg_list,
                                            l_commit,
                                            old_rec.orig_system_id1,
                                            l_transaction_type,
                                            rbk_rec.date_transaction_occurred,
                                            l_draft_yn,
                                            okl_api.g_true,
                                            x_return_status,
                                            x_msg_count,
                                            x_msg_data
                                           );
               ELSE
                  l_transaction_type := 'Booking';
                  l_chr_for_sts_change := p_chr_id;

                  OPEN l_chk_mass_rbk_csr (TO_NUMBER (p_chr_id));

                  FETCH l_chk_mass_rbk_csr
                   INTO l_chk_mass_rbk_rec;

                  CLOSE l_chk_mass_rbk_csr;

                  IF (NVL (l_chk_mass_rbk_rec.what, 'N') = 'N') THEN
                     --Bug# 2857843
                     IF l_transaction_type = 'Booking' THEN
                        p_pdtv_rec.ID := l_hdr_rec.pid;
                        okl_setupproducts_pub.getpdt_parameters
                                  (p_api_version            => p_api_version,
                                   p_init_msg_list          => p_init_msg_list,
                                   x_return_status          => x_return_status,
                                   x_msg_count              => x_msg_count,
                                   x_msg_data               => x_msg_data,
                                   p_pdtv_rec               => p_pdtv_rec,
                                   x_no_data_found          => x_no_data_found,
                                   p_pdt_parameter_rec      => x_pdt_parameter_rec
                                  );

                        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                           RAISE okl_api.g_exception_unexpected_error;
                        ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                           RAISE okl_api.g_exception_error;
                        --Bug# 3379294:
                        --ELSIF ( x_pdt_parameter_rec.Name = OKL_API.G_MISS_CHAR )THEN
                        ELSIF NVL (x_pdt_parameter_rec.NAME,
                                   okl_api.g_miss_char
                                  ) = okl_api.g_miss_char THEN
                           x_return_status := okl_api.g_ret_sts_error;
                           RAISE okl_api.g_exception_error;
                        END IF;
                     END IF;

                     --Bug Fix# 2857843 End

                     --Bug 5909373
                     l_acct_trans_type := l_transaction_type;

                     IF (is_release_contract (TO_NUMBER (p_chr_id)) = 'Y') THEN
                        l_acct_trans_type := 'Release';
                     END IF;

                     --Bug 5909373

                     -- Sales Tax Changes START
                     okl_la_je_pvt.generate_journal_entries
                                              (l_api_version,
                                               p_init_msg_list,
                                               l_commit,
                                               TO_NUMBER (p_chr_id),
                                               l_acct_trans_type,
                                                                 --Bug 5909373
                                               NULL,
                                               l_draft_yn,
                                               okl_api.g_true,
                                               x_return_status,
                                               x_msg_count,
                                               x_msg_data,
                                               x_trxh_rec
                                              );

                     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                        RAISE okl_api.g_exception_unexpected_error;
                     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                        RAISE okl_api.g_exception_error;
                     END IF;

                     okl_la_sales_tax_pvt.process_sales_tax
                                        (p_api_version           => l_api_version,
                                         p_init_msg_list         => p_init_msg_list,
                                         p_commit                => okl_api.g_false,
                                         p_contract_id           => TO_NUMBER
                                                                       (p_chr_id
                                                                       ),
                                         p_transaction_type      => 'Booking',
                                         p_transaction_id        => x_trxh_rec.ID,
                                         x_return_status         => x_return_status,
                                         x_msg_count             => x_msg_count,
                                         x_msg_data              => x_msg_data
                                        );

                     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                        RAISE okl_api.g_exception_unexpected_error;
                     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                        RAISE okl_api.g_exception_error;
                     END IF;
                  -- Sales Tax Changes END

                  /*OKL_LA_JE_PUB.generate_journal_entries(
                                l_api_version,
                                p_init_msg_list,
                                l_commit,
                                TO_NUMBER(p_chr_id),
                                l_transaction_type,
                                l_draft_yn,
                                OKL_API.G_TRUE,
                                x_return_status,
                                x_msg_count,
                                x_msg_data);*/
                  END IF;
               END IF;

               IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
               END IF;

               /* Manu 18-Aug-2004 Start
                  Get the rollover fee lines for a contract and call
                  validate_rollover_termQuote to validate the rollover fee line. */

               -- Check for rebook contract
               l_rbk_khr := '?';

               OPEN l_chk_rbk_csr (chrid => p_chr_id);

               FETCH l_chk_rbk_csr
                INTO l_rbk_khr;

               IF l_chk_rbk_csr%NOTFOUND THEN
                  NULL;
               END IF;

               CLOSE l_chk_rbk_csr;

               IF (l_rbk_khr = '?') THEN
                               -- This is a new Contract, booked for 1st time.
                  OPEN l_rq_fee_lns_bkg_csr (chrid => p_chr_id);

                  LOOP
                     FETCH l_rq_fee_lns_bkg_csr
                      INTO l_qte_id;

                     IF (l_rq_fee_lns_bkg_csr%FOUND) THEN
                        l_ro_fee_bkg_found := TRUE;
                        okl_maintain_fee_pvt.validate_rollover_feeline
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_chr_id             => p_chr_id,
                                          p_qte_id             => l_qte_id,
                                          p_for_qa_check       => FALSE
                                         );

                        IF (x_return_status <> okl_api.g_ret_sts_success) THEN
                           CLOSE l_rq_fee_lns_bkg_csr;

                           RAISE okl_api.g_exception_error;
                        ELSIF (x_return_status = okl_api.g_ret_sts_success) THEN
                           l_tq_rec_count := l_tq_rec_count + 1;
                           p_term_tbl (l_tq_rec_count).ID := l_qte_id;
                           p_term_tbl (l_tq_rec_count).accepted_yn := 'Y';
                           p_term_tbl (l_tq_rec_count).date_effective_to :=
                                                                      SYSDATE;
                           p_term_tbl (l_tq_rec_count).org_id :=
                                                okl_context.get_okc_org_id
                                                                          ();
                        END IF;
                     ELSIF (l_rq_fee_lns_bkg_csr%NOTFOUND) THEN
                        EXIT;
                     END IF;
                  END LOOP;

                  CLOSE l_rq_fee_lns_bkg_csr;

                  /* Manu 18-Nov-2004 Start */
                  /* Check if the if the contract has a rollover fee and it's start date
                     is not in the future date (less than or equal sysdate). */
                  OPEN l_k_std_csr (p_chr_id);

                  FETCH l_k_std_csr
                   INTO l_found;

                  l_in_future := l_k_std_csr%FOUND;               -- IN future

                  CLOSE l_k_std_csr;

                  IF (l_in_future AND l_ro_fee_bkg_found) THEN
                                              -- Contract Start date in future
                     x_return_status := okl_api.g_ret_sts_error;
                     l_in_future := NULL;
                     l_found := NULL;
                     okl_api.set_message
                                     (p_app_name      => g_app_name,
                                      p_msg_name      => 'OKL_LLA_RQ_SD_IN_FUTURE'
                                     );
                     RAISE okl_api.g_exception_error;
                  END IF;

                  l_ro_fee_bkg_found := FALSE;
                  /* Manu 18-Nov-2004 End */

                  /* smereddy 22-Sep-2004 Start
                     update the creditline contract with total rollover amount
                  */
                  l_qte_id := NULL;

                  OPEN l_rq_fee_lns_bkg_csr (chrid => p_chr_id);

                  FETCH l_rq_fee_lns_bkg_csr
                   INTO l_qte_id;

                  CLOSE l_rq_fee_lns_bkg_csr;

                  -- check whether creditline exists
                  l_creditline_id :=
                             okl_credit_pub.get_creditline_by_chrid (p_chr_id);

                  IF (l_creditline_id IS NOT NULL AND l_qte_id IS NOT NULL) THEN
                                         -- creditline exists for the contract
                     -- check whether tot rollover quote amount against the creditlimit exceeds
                     okl_maintain_fee_pvt.rollover_fee
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_chr_id             => p_chr_id,
                                          p_cl_id              => l_creditline_id,
                                          x_rem_amt            => x_rem_amt
                                         );
                  END IF;
               /* Suresh 22-Sep-2004 End */
               ELSIF (l_rbk_khr = '!') THEN     -- This is a Re-book Contract.
                  OPEN l_rq_fee_lns_rbk_csr (chrid => p_chr_id);

                  LOOP
                     FETCH l_rq_fee_lns_rbk_csr
                      INTO l_qte_id;

                     IF (l_rq_fee_lns_rbk_csr%FOUND) THEN
                        l_ro_fee_rbk_found := TRUE;
                        okl_maintain_fee_pvt.validate_rollover_feeline
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_chr_id             => p_chr_id,
                                          p_qte_id             => l_qte_id
                                         );

                        IF (x_return_status <> okl_api.g_ret_sts_success) THEN
                           CLOSE l_rq_fee_lns_rbk_csr;

                           RAISE okl_api.g_exception_error;
                        ELSIF (x_return_status = okl_api.g_ret_sts_success) THEN
                           l_tq_rec_count := l_tq_rec_count + 1;
                           p_term_tbl (l_tq_rec_count).ID := l_qte_id;
                           p_term_tbl (l_tq_rec_count).accepted_yn := 'Y';
                           p_term_tbl (l_tq_rec_count).date_effective_to :=
                                                                      SYSDATE;
                           p_term_tbl (l_tq_rec_count).org_id :=
                                                okl_context.get_okc_org_id
                                                                          ();
                        END IF;
                     ELSIF (l_rq_fee_lns_rbk_csr%NOTFOUND) THEN
                        EXIT;
                     END IF;
                  END LOOP;

                  CLOSE l_rq_fee_lns_rbk_csr;

                  /* Manu 18-Nov-2004 Start */
                  /* Check if the if the contract has a rollover fee and it's start date
                     is not in the future date (less than or equal sysdate). */
                  OPEN l_k_std__4rbk_csr (p_chr_id);

                  FETCH l_k_std__4rbk_csr
                   INTO l_found;

                  l_in_future := l_k_std__4rbk_csr%FOUND;         -- IN future

                  CLOSE l_k_std__4rbk_csr;

                  IF (l_in_future AND l_ro_fee_rbk_found) THEN
                                              -- Contract Start date in future
                     x_return_status := okl_api.g_ret_sts_error;
                     l_in_future := NULL;
                     l_found := NULL;
                     okl_api.set_message
                                     (p_app_name      => g_app_name,
                                      p_msg_name      => 'OKL_LLA_RQ_SD_IN_FUTURE'
                                     );
                     RAISE okl_api.g_exception_error;
                  END IF;

                  l_ro_fee_rbk_found := FALSE;
                  /* Manu 18-Nov-2004 End */

                  /* smereddy 22-Sep-2004 Start
                     update the creditline contract with total rollover amount
                  */
                  l_qte_id := NULL;

                  OPEN l_rq_fee_lns_bkg_csr (chrid => p_chr_id);

                  FETCH l_rq_fee_lns_bkg_csr
                   INTO l_qte_id;

                  CLOSE l_rq_fee_lns_bkg_csr;

                  -- check whether creditline exists
                  l_creditline_id :=
                             okl_credit_pub.get_creditline_by_chrid (p_chr_id);

                  IF (l_creditline_id IS NOT NULL AND l_qte_id IS NOT NULL) THEN
                                         -- creditline exists for the contract
                     -- check whether tot rollover quote amount against the creditlimit exceeds
                     okl_maintain_fee_pvt.rollover_fee
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_chr_id             => p_chr_id,
                                          p_cl_id              => l_creditline_id,
                                          x_rem_amt            => x_rem_amt
                                         );
                  END IF;
               /* Suresh 22-Sep-2004 End */
               END IF;

               l_tq_rec_count := 0;
               /* Initiate the Terminate Quote Process */
               okl_am_termnt_quote_pvt.terminate_quote
                                          (p_api_version            => l_api_version,
                                           p_init_msg_list          => p_init_msg_list,
                                           x_return_status          => x_return_status,
                                           x_msg_count              => x_msg_count,
                                           x_msg_data               => x_msg_data,
                                           p_term_tbl               => p_term_tbl,
                                           x_term_tbl               => x_term_tbl,
                                           x_err_msg                => x_err_msg,
                                           p_acceptance_source      => 'ROLLOVER'
                                          );

               IF (x_return_status <> okl_api.g_ret_sts_success) THEN
                  RAISE okl_api.g_exception_error;
               END IF;

               /* Manu 18-Aug-2004 End */

               --rviriyal  bug 5982201 start
               okl_qa_data_integrity.check_cust_active
                                          (x_return_status      => x_return_status,
                                           p_chr_id             => p_chr_id
                                          );

               IF (x_return_status = okl_api.g_ret_sts_success) THEN
                  okl_api.init_msg_list ('T');
               ELSIF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
               END IF;

               --rviriyal  bug 5982201 end
               okl_activate_contract_pub.activate_contract
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chrv_id            => p_chr_id,
                                           p_call_mode          => 'BOOK'
                                          );

               -- check if activity started successfully
               IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
               END IF;

               IF     (l_transaction_type = 'Booking')
                  AND
                      --Bug # 2927232 : was creating CASE for mass rebooks
                      -- Added this additional and clause to fix that issue.
                      (NVL (l_chk_mass_rbk_rec.what, 'N') = 'N') THEN
                  okl_case_util_pvt.create_case
                                       (p_api_version        => l_api_version,
                                        p_init_msg_list      => p_init_msg_list,
                                        p_contract_id        => TO_NUMBER
                                                                     (p_chr_id),
                                        x_return_status      => x_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data
                                       );
-- added the call against bug # 2457920 for creating contract portfolio.
                  okl_am_contract_prtfl_pub.create_cntrct_prtfl
                                         (p_api_version        => l_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_contract_id        => TO_NUMBER
                                                                     (p_chr_id)
                                         );
/*
        OKL_INS_QUOTE_PUB.activate_ins_streams(
        p_api_version         => l_api_version,
        p_init_msg_list       => p_init_msg_list,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_contract_id         => to_number(p_chr_id)
        );

*/      -- Bug 4917614
                  okl_k_rate_params_pvt.sync_base_rate
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_khr_id             => TO_NUMBER
                                                                      (p_chr_id
                                                                      )
                                          );

                  IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                     RAISE okl_api.g_exception_unexpected_error;
                  ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                     RAISE okl_api.g_exception_error;
                  END IF;

                  x_return_status := okl_api.g_ret_sts_success;
/*
        If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := OKL_API.G_RET_STS_SUCCESS;
           --Bug#2393795-this call will not raise error as
           --not tested properly. So should not stop Booking
           --if this fails in PROD.
           --raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
           x_return_status := OKL_API.G_RET_STS_SUCCESS;
           --raise OKL_API.G_EXCEPTION_ERROR;
        End If;
*/
               END IF;
            --ELSE 4895333
                --l_chr_for_sts_change := TO_NUMBER(p_chr_id);
            END IF;
         END IF;                               -- Vendor Program Template: End

         -- Change Status
         IF (x_return_status = okl_api.g_ret_sts_success) THEN
            okl_contract_status_pub.update_contract_status
                                                        (l_api_version,
                                                         p_init_msg_list,
                                                         x_return_status,
                                                         x_msg_count,
                                                         x_msg_data,
                                                         l_passstatus,
                                                         l_chr_for_sts_change
                                                        );
         --p_chr_id );
         ELSE
            okl_contract_status_pub.update_contract_status
                                                        (l_api_version,
                                                         p_init_msg_list,
                                                         x_return_status,
                                                         x_msg_count,
                                                         x_msg_data,
                                                         l_failstatus,
                                                         l_chr_for_sts_change
                                                        );

            --p_chr_id );
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         END IF;

         -- 4895333
         IF (old_rec.deal_type <> 'LOAN-REVOLVING') THEN
            --call to cascade status on to lines
            okl_contract_status_pub.cascade_lease_status
                                         (p_api_version        => p_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_chr_id             => l_chr_for_sts_change
                                         );

            --p_chr_id          => p_chr_id);
            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         ---
         END IF;

/*


    If ( old_rec.ORIG_SYSTEM_ID1 IS NOT NULL ) Then
        okl_contract_status_pub.update_contract_status(
                                       l_api_version,
                                       p_init_msg_list,
                                       x_return_status,
                                       x_msg_count,
                                       x_msg_data,
                                       'CANCELED',
                                       old_rec.ORIG_SYSTEM_ID1 );

        OKL_CONTRACT_STATUS_PUB.cascade_lease_status
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => old_rec.ORIG_SYSTEM_ID1 );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        ---

    End If;
*/
         okl_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_LLA_AC_SUCCESS'
                             );
         x_return_status := okl_api.g_ret_sts_success;
         /*
         -- mvasudev, 08/30/2004
         -- Code change to enable Business Event
         */
         raise_business_event (p_rbk_khr_id                     => l_rbk_khr_id,
                               p_date_transaction_occurred      => l_rbk_date,
                               x_return_status                  => x_return_status
                              );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;
          /*
          -- mvasudev, 08/30/2004
          -- END, Code change to enable Business Event
      */
      END IF;                                      -- l_proceed_activation Y/N

      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         /* Manu 18-Aug-2004 Start Clean Up. */
         IF l_rq_fee_lns_bkg_csr%ISOPEN THEN
            CLOSE l_rq_fee_lns_bkg_csr;
         END IF;

         IF l_rq_fee_lns_rbk_csr%ISOPEN THEN
            CLOSE l_rq_fee_lns_rbk_csr;
         END IF;

         IF l_chk_rbk_csr%ISOPEN THEN
            CLOSE l_chk_rbk_csr;
         END IF;

         /* Manu 18-Aug-2004 End */

         /* Manu 18-Nov-2004 Start */
         IF l_k_std_csr%ISOPEN THEN
            CLOSE l_k_std_csr;
         END IF;

         IF l_k_std__4rbk_csr%ISOPEN THEN
            CLOSE l_k_std__4rbk_csr;
         END IF;

         /* Manu 18-Nov-2004 End */

         --ramurt Bug#4622438
         IF chk_product_status%ISOPEN THEN
            CLOSE chk_product_status;
         END IF;

         -- end
         x_return_status :=
            okl_api.handle_exceptions
                                     (p_api_name       => l_api_name,
                                      p_pkg_name       => g_pkg_name,
                                      p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_api_type       => g_api_type
                                     );
      WHEN okl_api.g_exception_unexpected_error THEN
         /* Manu 18-Aug-2004 Start Clean Up. */
         IF l_rq_fee_lns_bkg_csr%ISOPEN THEN
            CLOSE l_rq_fee_lns_bkg_csr;
         END IF;

         IF l_rq_fee_lns_rbk_csr%ISOPEN THEN
            CLOSE l_rq_fee_lns_rbk_csr;
         END IF;

         IF l_chk_rbk_csr%ISOPEN THEN
            CLOSE l_chk_rbk_csr;
         END IF;

         /* Manu 18-Aug-2004 End */

         /* Manu 18-Nov-2004 Start */
         IF l_k_std_csr%ISOPEN THEN
            CLOSE l_k_std_csr;
         END IF;

         IF l_k_std__4rbk_csr%ISOPEN THEN
            CLOSE l_k_std__4rbk_csr;
         END IF;

         /* Manu 18-Nov-2004 End */
         x_return_status :=
            okl_api.handle_exceptions
                               (p_api_name       => l_api_name,
                                p_pkg_name       => g_pkg_name,
                                p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_api_type       => g_api_type
                               );
      WHEN OTHERS THEN
         /* Manu 18-Aug-2004 Start Clean Up. */
         IF l_rq_fee_lns_bkg_csr%ISOPEN THEN
            CLOSE l_rq_fee_lns_bkg_csr;
         END IF;

         IF l_rq_fee_lns_rbk_csr%ISOPEN THEN
            CLOSE l_rq_fee_lns_rbk_csr;
         END IF;

         IF l_chk_rbk_csr%ISOPEN THEN
            CLOSE l_chk_rbk_csr;
         END IF;

         /* Manu 18-Aug-2004 End */

         /* Manu 18-Nov-2004 Start */
         IF l_k_std_csr%ISOPEN THEN
            CLOSE l_k_std_csr;
         END IF;

         IF l_k_std__4rbk_csr%ISOPEN THEN
            CLOSE l_k_std__4rbk_csr;
         END IF;

         /* Manu 18-Nov-2004 End */
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END activate_contract;

----------------------------------------------------------------
--Bug# 3556674 : validate contract api to be called as an api to
--               run qa check list
-----------------------------------------------------------------
   PROCEDURE validate_contract (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_qcl_id          IN              NUMBER,
      p_chr_id          IN              NUMBER,
      p_call_mode       IN              VARCHAR2 DEFAULT 'ACTUAL',
      x_msg_tbl         OUT NOCOPY      okl_qa_check_pub.msg_tbl_type
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)           := 'VALIDATE_CONTRACT';
      l_api_version   CONSTANT NUMBER                         := 1;
      l_return_status          VARCHAR2 (1)      := okl_api.g_ret_sts_success;

      --Cursor to get QA checklist id from contract header
      CURSOR l_chr_csr (p_chr_id IN NUMBER) IS
         SELECT chrb.qcl_id,
                stsv.ste_code,
                stsv.meaning
           FROM okc_k_headers_b chrb, okc_statuses_v stsv
          WHERE chrb.ID = p_chr_id
            AND chrb.sts_code = stsv.code
            AND chrb.scs_code = 'LEASE';

      l_chr_rec                l_chr_csr%ROWTYPE;

      --Cursor to get QA checklist id from
      CURSOR l_qcl_csr (p_qclid IN NUMBER) IS
         SELECT ID
           FROM okc_qa_check_lists_v
          WHERE ID = p_qclid;

      l_qcl_id                 okc_qa_check_lists_b.ID%TYPE;
      l_qclid                  okc_qa_check_lists_b.ID%TYPE
                               DEFAULT 253090624152411882761357215253616454772;
   BEGIN
      x_return_status := okl_api.g_ret_sts_success;
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      l_qcl_id := p_qcl_id;
      validate_chr_id (p_chr_id             => p_chr_id,
                       x_return_status      => x_return_status
                      );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      OPEN l_chr_csr (p_chr_id => p_chr_id);

      FETCH l_chr_csr
       INTO l_chr_rec;

      IF l_chr_csr%NOTFOUND THEN
         --error : contract does not exist
         okl_api.set_message (g_app_name,
                              g_invalid_value,
                              g_col_name_token,
                              'p_chr_id'
                             );
         x_return_status := okl_api.g_ret_sts_error;
         RAISE okl_api.g_exception_error;
      END IF;

      CLOSE l_chr_csr;

      IF l_chr_rec.ste_code NOT IN ('ENTERED', 'SIGNED') THEN
         --error : Contract with status can not be validated.
         okl_api.set_message (g_app_name,
                              'OKL_LA_CAN_NOT_QA',
                              'STATUS',
                              l_chr_rec.meaning
                             );
         RAISE okl_api.g_exception_error;
      END IF;

      IF l_qcl_id IS NULL OR l_qcl_id = okl_api.g_miss_num THEN
         --get qcl_id from k hdr
         l_qcl_id := l_chr_rec.qcl_id;
      END IF;

      IF l_qcl_id IS NULL OR l_qcl_id = okl_api.g_miss_num THEN
         --get seeded QCL id
         OPEN l_qcl_csr (p_qclid => l_qclid);

         FETCH l_qcl_csr
          INTO l_qcl_id;

         IF l_qcl_csr%NOTFOUND THEN
            NULL;
         END IF;

         CLOSE l_qcl_csr;
      END IF;

      IF l_qcl_id IS NOT NULL AND l_qcl_id <> okl_api.g_miss_num THEN
         execute_qa_check_list (p_api_version        => p_api_version,
                                p_init_msg_list      => p_init_msg_list,
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                p_qcl_id             => l_qcl_id,
                                p_chr_id             => p_chr_id,
                                p_call_mode          => p_call_mode,
                                x_msg_tbl            => x_msg_tbl
                               );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;
      ELSIF l_qcl_id IS NULL OR l_qcl_id = okl_api.g_miss_num THEN
         --error
         okl_api.set_message (g_app_name,
                              g_invalid_value,
                              g_col_name_token,
                              'p_qcl_id'
                             );
         x_return_status := okl_api.g_ret_sts_error;
         RAISE okl_api.g_exception_error;
      END IF;

      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   ---
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END validate_contract;

----------------------------------------------------------------
--Bug# 3556674 : generate_draft_accounting to be called  as an api to
--               generate draft 'Booking' accounting entries
-----------------------------------------------------------------
   PROCEDURE generate_draft_accounting (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT okc_api.g_false,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      p_chr_id          IN              NUMBER
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)         := 'GENERATE_DRAFT_ACCT';
      l_api_version   CONSTANT NUMBER                       := 1;
      l_return_status          VARCHAR2 (1)      := okl_api.g_ret_sts_success;
      l_booking_trx_type       okl_trx_types_tl.NAME%TYPE   DEFAULT 'Booking';
   BEGIN
      x_return_status := okl_api.g_ret_sts_success;
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --1. validate chr id
      validate_chr_id (p_chr_id             => p_chr_id,
                       x_return_status      => x_return_status
                      );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --2. call api for generating journal entries
      generate_journal_entries (p_api_version           => p_api_version,
                                p_init_msg_list         => p_init_msg_list,
                                p_commit                => okl_api.g_false,
                                p_contract_id           => p_chr_id,
                                p_transaction_type      => l_booking_trx_type,
                                p_draft_yn              => okl_api.g_true,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data
                               );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
   END generate_draft_accounting;

-----------------------------------------------------------------------------
 -- PROCEDURE calculate_upfront_tax
 -----------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : calculate_upfront_tax
 -- Description     : Procedure will be called to calculate upfront tax during
 --                   online and batch contract activation.
 -- Business Rules  :
 -- Parameters      : p_chr_id
 -- Version         : 1.0
 -- History         : 24-Apr-2007 rpillay Created
 -- End of comments
   PROCEDURE calculate_upfront_tax (
      p_api_version      IN              NUMBER,
      p_init_msg_list    IN              VARCHAR2 DEFAULT okl_api.g_false,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      p_chr_id           IN              VARCHAR2,
      x_process_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)       := 'CALCULATE_UPFRONT_TAX';
      l_api_version   CONSTANT NUMBER                                  := 1.0;

      -- check whether this contract is rebook contract
      CURSOR l_chk_rbk_csr (p_chr_id IN NUMBER) IS
         SELECT '!',
                CHR.orig_system_id1,
                ktrx.date_transaction_occurred,
                ktrx.ID
           FROM okc_k_headers_b CHR, okl_trx_contracts ktrx
          WHERE ktrx.khr_id_new = CHR.ID
            AND ktrx.tsu_code = 'ENTERED'
            AND ktrx.rbr_code IS NOT NULL
            AND ktrx.tcn_type = 'TRBK'
           --rkuttiya added for 12.1.1 Multi GAAP Project
            AND ktrx.representation_type = 'PRIMARY'
           --
            AND CHR.ID = p_chr_id
            AND CHR.orig_system_source_code = 'OKL_REBOOK';

      -- Bug 6157438
      --cursor to check if the contract is selected for Mass Rebook
      CURSOR l_chk_mass_rbk_csr (p_chr_id IN NUMBER) IS
         SELECT '!'
           FROM okc_k_headers_b CHR, okl_trx_contracts ktrx
          WHERE CHR.ID = p_chr_id
            AND ktrx.khr_id = CHR.ID
            AND ktrx.tsu_code = 'ENTERED'
            AND ktrx.rbr_code IS NOT NULL
            AND ktrx.tcn_type = 'TRBK'
   -- rkuttiya added for 12.1.1 Multi GAAP Project
            AND ktrx.representation_type = 'PRIMARY'
    --
            AND EXISTS (
                   SELECT '1'
                     FROM okl_rbk_selected_contract rbk_khr
                    WHERE rbk_khr.khr_id = CHR.ID
                      AND rbk_khr.status <> 'PROCESSED');

      l_rbk_khr                VARCHAR2 (1)                             := '?';
      l_mass_rbk_khr           VARCHAR2 (1)                             := '?';
      l_orig_khr_id            NUMBER;
      l_transaction_id         NUMBER;
      l_rebook_date            DATE;
      l_upfront_tax_prog_sts   okl_book_controller_trx.progress_status%TYPE;

      --Bug# 6512668
      CURSOR sys_param_csr IS
         SELECT NVL (tax_upfront_yn, 'N')
           FROM okl_system_params;

      l_upfront_tax_yn         VARCHAR2 (1);

      CURSOR check_st_fee_csr (p_chr_id IN NUMBER) IS
         SELECT cle.ID
           FROM okc_k_lines_b cle, okl_k_lines kle
          WHERE cle.ID = kle.ID
            AND cle.dnz_chr_id = p_chr_id
            AND cle.chr_id = p_chr_id
            AND kle.fee_purpose_code = 'SALESTAX'
            AND cle.sts_code <> 'ABANDONED';

      l_del_fee_line_id        okc_k_lines_b.ID%TYPE;
      l_del_fee_types_rec      okl_maintain_fee_pvt.fee_types_rec_type;
   --Bug# 6512668
   BEGIN
      x_process_status := okl_api.g_ret_sts_success;
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      l_upfront_tax_prog_sts := okl_book_controller_pvt.g_prog_sts_complete;

      IF (g_debug_enabled = 'Y') THEN
         g_is_debug_statement_on :=
               okl_debug_pub.check_log_on (g_module, fnd_log.level_statement);
      END IF;

      --check for rebook contract
      l_rbk_khr := '?';
      l_orig_khr_id := NULL;
      l_transaction_id := NULL;

      OPEN l_chk_rbk_csr (p_chr_id => p_chr_id);

      FETCH l_chk_rbk_csr
       INTO l_rbk_khr,
            l_orig_khr_id,
            l_rebook_date,
            l_transaction_id;

      IF l_chk_rbk_csr%NOTFOUND THEN
         NULL;
      END IF;

      CLOSE l_chk_rbk_csr;

      -- Bug 6157438
      -- check for mass rebook contract
      l_mass_rbk_khr := '?';

      OPEN l_chk_mass_rbk_csr (p_chr_id => p_chr_id);

      FETCH l_chk_mass_rbk_csr
       INTO l_mass_rbk_khr;

      IF l_chk_mass_rbk_csr%NOTFOUND THEN
         NULL;
      END IF;

      CLOSE l_chk_mass_rbk_csr;

      IF (l_rbk_khr = '!') THEN
         IF (g_is_debug_statement_on = TRUE) THEN
            okl_debug_pub.log_debug (fnd_log.level_statement,
                                     g_module,
                                     'Rebook, Orig :' || l_orig_khr_id
                                    );
         END IF;

         -- Rebook
         -- Bug 4769822 - START
         okl_la_sales_tax_pvt.process_sales_tax
            (p_api_version           => p_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => okl_api.g_false,
             p_contract_id           => l_orig_khr_id,
             p_transaction_type      => 'Pre-Rebook',
             p_transaction_id        => l_transaction_id,
                                        -- R12 change NULL to l_transaction_id
             p_transaction_date      => l_rebook_date,
                                           -- R12 change NULL to l_rebook_date
             p_rbk_contract_id       => p_chr_id,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data
            );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- Bug 4769822 - END
         okl_la_sales_tax_pvt.validate_upfront_tax_fee
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => p_chr_id
                                          );

         IF (x_return_status <> okl_api.g_ret_sts_success) THEN
            l_upfront_tax_prog_sts :=
                                     okl_book_controller_pvt.g_prog_sts_error;
            x_process_status := okl_api.g_ret_sts_error;
            x_return_status := okl_api.g_ret_sts_success;
         ELSE
            l_upfront_tax_prog_sts :=
                                  okl_book_controller_pvt.g_prog_sts_complete;
         END IF;
      ELSIF (l_mass_rbk_khr = '!') THEN
         NULL;

         IF (g_is_debug_statement_on = TRUE) THEN
            okl_debug_pub.log_debug (fnd_log.level_statement,
                                     g_module,
                                     'Mass-Rebook, Orig :' || p_chr_id
                                    );
         END IF;
      -- Mass-rebook
      ELSE
         -- authoring
         IF (g_is_debug_statement_on = TRUE) THEN
            okl_debug_pub.log_debug (fnd_log.level_statement,
                                     g_module,
                                     'Authoring : ' || p_chr_id
                                    );
         END IF;

         okl_la_sales_tax_pvt.process_sales_tax
                                         (p_api_version           => p_api_version,
                                          p_init_msg_list         => p_init_msg_list,
                                          p_commit                => okl_api.g_false,
                                          p_contract_id           => p_chr_id,
                                          p_transaction_type      => 'Pre-Booking',
                                          p_transaction_id        => NULL,
                                          p_transaction_date      => NULL,
                                          p_rbk_contract_id       => NULL,
                                          x_return_status         => x_return_status,
                                          x_msg_count             => x_msg_count,
                                          x_msg_data              => x_msg_data
                                         );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;

         -- Bug# 6512668: Delete Upfront Tax Fee line if Upfront
         -- Tax System Option is set to 'N'
         OPEN sys_param_csr;

         FETCH sys_param_csr
          INTO l_upfront_tax_yn;

         CLOSE sys_param_csr;

         IF l_upfront_tax_yn = 'N' THEN
            -- Check if Sales Tax Fee exists
            OPEN check_st_fee_csr (p_chr_id => p_chr_id);

            FETCH check_st_fee_csr
             INTO l_del_fee_line_id;

            CLOSE check_st_fee_csr;

            IF (l_del_fee_line_id IS NOT NULL) THEN
               l_del_fee_types_rec.line_id := l_del_fee_line_id;
               l_del_fee_types_rec.dnz_chr_id := p_chr_id;
               -- delete fee line
               okl_maintain_fee_pvt.delete_fee_type
                                      (p_api_version        => p_api_version,
                                       p_init_msg_list      => p_init_msg_list,
                                       x_return_status      => x_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_fee_types_rec      => l_del_fee_types_rec
                                      );

               IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
               ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
               END IF;
            END IF;
         END IF;

         okl_la_sales_tax_pvt.validate_upfront_tax_fee
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => p_chr_id
                                          );

         IF (x_return_status <> okl_api.g_ret_sts_success) THEN
            l_upfront_tax_prog_sts :=
                                     okl_book_controller_pvt.g_prog_sts_error;
            x_process_status := okl_api.g_ret_sts_error;
            x_return_status := okl_api.g_ret_sts_success;
         ELSE
            l_upfront_tax_prog_sts :=
                                  okl_book_controller_pvt.g_prog_sts_complete;
         END IF;
      END IF;

      --Update Contract Status to Passed
      okl_contract_status_pub.update_contract_status
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_khr_status         => 'PASSED',
                                           p_chr_id             => p_chr_id
                                          );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --call to cascade status on to lines
      okl_contract_status_pub.cascade_lease_status
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => p_chr_id
                                          );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      -- Update status of Validate Contract process to Complete
      okl_book_controller_pvt.update_book_controller_trx
            (p_api_version          => p_api_version,
             p_init_msg_list        => p_init_msg_list,
             x_return_status        => x_return_status,
             x_msg_count            => x_msg_count,
             x_msg_data             => x_msg_data,
             p_khr_id               => p_chr_id,
             p_prog_short_name      => okl_book_controller_pvt.g_validate_contract,
             p_progress_status      => okl_book_controller_pvt.g_prog_sts_complete
            );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      okl_book_controller_pvt.update_book_controller_trx
             (p_api_version          => p_api_version,
              p_init_msg_list        => p_init_msg_list,
              x_return_status        => x_return_status,
              x_msg_count            => x_msg_count,
              x_msg_data             => x_msg_data,
              p_khr_id               => p_chr_id,
              p_prog_short_name      => okl_book_controller_pvt.g_calc_upfront_tax,
              p_progress_status      => l_upfront_tax_prog_sts
             );

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   EXCEPTION
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
         x_process_status := okl_api.g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
         x_process_status := okl_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
         x_process_status := okl_api.g_ret_sts_error;
   END calculate_upfront_tax;

-----------------------------------------------------------------------------
-- PROCEDURE approve_activate_contract
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : approve_activate_contract
-- Description     : Procedure will be called from Submit button on Contract Booking UI and
--                   from OKL_CONTRACT_BOOK_PVT.post_approval_process and Batch booking.
--                   This procedure will submit the contract for approval.
--                   If the contract has been approved, this will process contract activation
-- Business Rules  :
-- Parameters      : p_chr_id
-- Version         : 1.0
-- History         : 24-Apr-2007 rpillay Created
-- End of comments
   PROCEDURE approve_activate_contract (
      p_api_version      IN              NUMBER,
      p_init_msg_list    IN              VARCHAR2 DEFAULT okl_api.g_false,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      p_chr_id           IN              VARCHAR2,
      x_process_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_api_name          CONSTANT VARCHAR2 (30)
                                               := 'APPROVE_ACTIVATE_CONTRACT';
      l_api_version       CONSTANT NUMBER                              := 1.0;

      --cursor to fetch the contract status
      CURSOR sts_code_csr (p_khr_id okc_k_headers_b.ID%TYPE) IS
         SELECT sts_code
           FROM okc_k_headers_b
          WHERE ID = p_khr_id;

      --cursor to fetch quote number to check for re-leasing
      CURSOR get_term_qte_num (p_khr_id okc_k_headers_b.ID%TYPE) IS
         SELECT qte.quote_number
           FROM okl_trx_contracts tcn,
                okl_trx_types_tl try,
                okl_trx_quotes_b qte,
                okc_k_headers_b CHR
          WHERE tcn.khr_id_old = CHR.orig_system_id1
            AND tcn.khr_id_new = CHR.ID
            AND tcn_type = 'MAE'
            AND tcn.tsu_code <> 'PROCESSED'
            AND tcn.try_id = try.ID
    --rkuttiya added for 12.1.1 Multi GAAP Project
            AND tcn.representation_type = 'PRIMARY'
    --
            AND try.NAME = 'Release'
            AND try.LANGUAGE = 'US'
            AND tcn.qte_id = qte.ID
            AND CHR.ID = p_khr_id;

      l_rem_amt                    NUMBER;
      l_sts_code                   okc_k_headers_b.sts_code%TYPE;
      l_qte_num                    okl_trx_quotes_b.quote_number%TYPE;
      l_approval_path              VARCHAR2 (30);
      contract_activation_failed   EXCEPTION;

      -- Bug# 5038395
      CURSOR l_chk_mass_rbk_csr (p_chr_id IN NUMBER) IS
         SELECT 'Y' mass_rbk_yn
           FROM okc_k_headers_b CHR
          WHERE CHR.ID = p_chr_id
            AND EXISTS (
                   SELECT '1'
                     FROM okl_trx_contracts ktrx
                    WHERE ktrx.khr_id = CHR.ID
                      AND ktrx.tsu_code = 'ENTERED'
                      AND ktrx.rbr_code IS NOT NULL
                      AND ktrx.tcn_type = 'TRBK'
        --rkuttiya added for 12.1.1 Multi GAAP Project
                      AND ktrx.representation_type = 'PRIMARY')
       --
            AND EXISTS (
                   SELECT '1'
                     FROM okl_rbk_selected_contract rbk_khr
                    WHERE rbk_khr.khr_id = CHR.ID
                      AND rbk_khr.status <> 'PROCESSED');

      l_chk_mass_rbk_rec           l_chk_mass_rbk_csr%ROWTYPE;
   BEGIN
      x_process_status := okl_api.g_ret_sts_success;
      x_return_status :=
         okl_api.start_activity (p_api_name           => l_api_name,
                                 p_pkg_name           => g_pkg_name,
                                 p_init_msg_list      => p_init_msg_list,
                                 l_api_version        => l_api_version,
                                 p_api_version        => p_api_version,
                                 p_api_type           => g_api_type,
                                 x_return_status      => x_return_status
                                );

      -- check if activity started successfully
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

      --fetch contract status code
      OPEN sts_code_csr (p_chr_id);

      FETCH sts_code_csr
       INTO l_sts_code;

      CLOSE sts_code_csr;

      -- Bug# 5038395
      -- Check if Mass rebook is in progress
      OPEN l_chk_mass_rbk_csr (TO_NUMBER (p_chr_id));

      FETCH l_chk_mass_rbk_csr
       INTO l_chk_mass_rbk_rec;

      CLOSE l_chk_mass_rbk_csr;

      -- Bug# 5038395
      -- If Mass Rebook not in progress, then do regular contract activation
      IF (NVL (l_chk_mass_rbk_rec.mass_rbk_yn, 'N') = 'N') THEN
         IF l_sts_code <> 'APPROVED' THEN
            --call program to submit for approval
            okl_contract_book_pub.submit_for_approval
                                         (p_api_version        => p_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_chr_id             => p_chr_id
                                         );

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;

            --read profile for approval path
            l_approval_path :=
               NVL (fnd_profile.VALUE ('OKL_LEASE_CONTRACT_APPROVAL_PROCESS'),
                    'NONE'
                   );
         END IF;

         IF (l_sts_code = 'APPROVED') OR (l_approval_path = 'NONE') THEN
            --call program for contract activation
            okl_contract_book_pub.activate_contract
                                         (p_api_version        => p_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_chr_id             => p_chr_id
                                         );

            IF (x_return_status IN
                     (okl_api.g_ret_sts_unexp_error, okl_api.g_ret_sts_error)
               ) THEN
               RAISE contract_activation_failed;
            END IF;

            --get rollover fee amount
            okl_maintain_fee_pvt.rollover_fee
                                          (p_api_version        => p_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_chr_id             => p_chr_id,
                                           x_rem_amt            => l_rem_amt
                                          );

            IF (x_return_status IN
                     (okl_api.g_ret_sts_unexp_error, okl_api.g_ret_sts_error)
               ) THEN
               RAISE contract_activation_failed;
            END IF;

            --fetch contract status code
            OPEN sts_code_csr (p_chr_id);

            FETCH sts_code_csr
             INTO l_sts_code;

            CLOSE sts_code_csr;

            IF (l_sts_code IS NOT NULL AND l_sts_code = 'APPROVED') THEN
               --checking for re-lease processing
               OPEN get_term_qte_num (p_chr_id);

               FETCH get_term_qte_num
                INTO l_qte_num;

               IF get_term_qte_num%NOTFOUND THEN
                  l_qte_num := NULL;
               END IF;

               CLOSE get_term_qte_num;

               okl_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKL_LLA_REL_TERMN_NO_COMPLETE',
                                p_token1            => 'QUOTE_NUM',
                                p_token1_value      => l_qte_num
                               );
               RAISE contract_activation_failed;
            ELSIF (    l_rem_amt IS NOT NULL
                   AND l_rem_amt <> okl_api.g_miss_num
                   AND ROUND (l_rem_amt) < 0
                  ) THEN
               --rollover fee amount warning
               okl_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKL_ROLL_QT_WRNG'
                                   );
               x_process_status := okl_api.g_ret_sts_warning;
            END IF;

            okl_book_controller_pvt.update_book_controller_trx
               (p_api_version          => p_api_version,
                p_init_msg_list        => okl_api.g_false,
                                                     --To retain message stack
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                p_khr_id               => p_chr_id,
                p_prog_short_name      => okl_book_controller_pvt.g_submit_contract,
                p_progress_status      => okl_book_controller_pvt.g_prog_sts_complete
               );

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
            END IF;
         END IF;
      -- Bug# 5038395
      -- If Mass Rebook is in progress, then do mass rebook activation
      ELSE
         okl_mass_rebook_pvt.mass_rebook_activate
                                         (p_api_version        => p_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_chr_id             => p_chr_id
                                         );

         IF (x_return_status IN
                     (okl_api.g_ret_sts_unexp_error, okl_api.g_ret_sts_error)
            ) THEN
            RAISE contract_activation_failed;
         END IF;
      END IF;

      x_return_status := okl_api.g_ret_sts_success;
      okl_api.end_activity (x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data
                           );
   EXCEPTION
      WHEN contract_activation_failed THEN
         x_process_status := okl_api.g_ret_sts_error;
         okl_book_controller_pvt.update_book_controller_trx
             (p_api_version          => p_api_version,
              p_init_msg_list        => okl_api.g_false,
                                                     --To retain message stack
              x_return_status        => x_return_status,
              x_msg_count            => x_msg_count,
              x_msg_data             => x_msg_data,
              p_khr_id               => p_chr_id,
              p_prog_short_name      => okl_book_controller_pvt.g_submit_contract,
              p_progress_status      => okl_book_controller_pvt.g_prog_sts_error
             );

         IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
         ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
         END IF;

         x_return_status := okl_api.g_ret_sts_success;
      WHEN okl_api.g_exception_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                                    (p_api_name       => l_api_name,
                                     p_pkg_name       => g_pkg_name,
                                     p_exc_name       => 'OKL_API.G_RET_STS_ERROR',
                                     x_msg_count      => x_msg_count,
                                     x_msg_data       => x_msg_data,
                                     p_api_type       => g_api_type
                                    );
         x_process_status := okl_api.g_ret_sts_error;
      WHEN okl_api.g_exception_unexpected_error THEN
         x_return_status :=
            okl_api.handle_exceptions
                              (p_api_name       => l_api_name,
                               p_pkg_name       => g_pkg_name,
                               p_exc_name       => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_api_type       => g_api_type
                              );
         x_process_status := okl_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status :=
            okl_api.handle_exceptions (p_api_name       => l_api_name,
                                       p_pkg_name       => g_pkg_name,
                                       p_exc_name       => 'OTHERS',
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_api_type       => g_api_type
                                      );
         x_process_status := okl_api.g_ret_sts_error;
   END approve_activate_contract;
END okl_contract_book_pvt;

/
