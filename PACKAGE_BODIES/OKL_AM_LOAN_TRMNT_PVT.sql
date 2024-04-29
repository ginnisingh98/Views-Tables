--------------------------------------------------------
--  DDL for Package Body OKL_AM_LOAN_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_LOAN_TRMNT_PVT" AS
/* $Header: OKLRLOTB.pls 120.6 2007/12/14 13:59:21 nikshah noship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_loan_trmnt_pvt.';
  -- Start of comments
  --
  -- Procedure Name	: validate_loan
  -- Description	: Validates the loan (Contract) -- Add additional validations
  --             if needed, most of the validations covered in validate_contract
  --             of OKL_AM_LEASE_LOAN_TRMNT_PVT api
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  --
  -- End of comments
  PROCEDURE validate_loan(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type) AS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  END validate_loan;

  -- Start of comments
  --
  -- Procedure Name	: loan_termination
  -- Desciption     : Main API which does the termination of Lease
  --                  Always rollback the whole process if processing transaction
  --                  fails this is done or else we lose information as to
  --                  the success/failure of different APIs
  --                  if the process is rolled back, then it will be picked
  --                  again by the batch_process
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU 02-JAN-03 2724951 Always do dispose for loans
  --                : RMUNJULU 04-APR-03 2889694 Changed OR to AND in check for trn exists
  --                  or else was giving error and rolling back the whole trn
  --                : RMUNJULU 27-JUN-03 3023206 Removed Process_Close_Streams
  --                  from this procedure as it is now called from
  --                  update_k_hdr_and_lines
  --                : RMUNJULU 3018641 Added code to get and set TMG_RUN on OKL_TRX_MSGS
  --                : rmunjulu EDAT Added code to get quote eff dates and set them as global
  --                : PAGARG 4190887 Pass klev_tbl to process_Accounting_entries
  --                  to do accounting at line level and populate kle_id in
  --                  OKL_TXL_CNTRCT_LNS
  --                : rmunjulu LOANS_ENHANCEMENTS
  -- End of comments
  PROCEDURE loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type) IS
   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   lp_tcnv_rec             tcnv_rec_type;
   lx_stmv_tbl             stmv_tbl_type;
   lx_adjv_rec             adjv_rec_type;
   lx_ajlv_tbl             ajlv_tbl_type;
   lp_klev_tbl             klev_tbl_type;
   lx_klev_tbl             klev_tbl_type;
   lx_chrv_rec             chrv_rec_type;
   lx_clev_tbl             clev_tbl_type;
   lx_id                   NUMBER;
   i                       NUMBER := 1;
   l_tran_started          VARCHAR2(1)  := OKL_API.G_FALSE;
   l_evergreen_status      VARCHAR2(1)  := OKL_API.G_FALSE;
   l_api_name              VARCHAR2(30) := 'loan_termination';
   l_sys_date              DATE;
   l_trn_already_set       VARCHAR2(1)  := 'N';
   lx_contract_status      VARCHAR2(200);
   l_validate              VARCHAR2(1) := OKC_API.G_RET_STS_ERROR;
   l_api_version           CONSTANT NUMBER := 1;
   l_status                VARCHAR2(200);

   l_term_rec              term_rec_type := p_term_rec;
   l_module_name VARCHAR2(500) := G_MODULE_NAME || 'loan_termination';
   is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
   is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
   is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: ' || p_term_rec.p_contract_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_number: ' || p_term_rec.p_contract_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_modifier: ' || p_term_rec.p_contract_modifier);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_orig_end_date: ' || p_term_rec.p_orig_end_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_version: ' || p_term_rec.p_contract_version);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_termination_date: ' || p_term_rec.p_termination_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_termination_reason: ' || p_term_rec.p_termination_reason);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: ' || p_term_rec.p_quote_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_type: ' || p_term_rec.p_quote_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_reason: ' || p_term_rec.p_quote_reason);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_early_termination_yn: ' || p_term_rec.p_early_termination_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_control_flag: ' || p_term_rec.p_control_flag);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_recycle_flag: ' || p_term_rec.p_recycle_flag);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.id: ' || p_tcnv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.rbr_code: ' || p_tcnv_rec.rbr_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.rpy_code: ' || p_tcnv_rec.rpy_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.rvn_code: ' || p_tcnv_rec.rvn_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.trn_code: ' || p_tcnv_rec.trn_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.khr_id_new: ' || p_tcnv_rec.khr_id_new);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.pvn_id: ' || p_tcnv_rec.pvn_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.pdt_id: ' || p_tcnv_rec.pdt_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.qte_id: ' || p_tcnv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.aes_id: ' || p_tcnv_rec.aes_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.code_combination_id: ' || p_tcnv_rec.code_combination_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.date_accrual: ' || p_tcnv_rec.date_accrual);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.accrual_status_yn: ' || p_tcnv_rec.accrual_status_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.update_status_yn: ' || p_tcnv_rec.update_status_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.amount: ' || p_tcnv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.currency_code: ' || p_tcnv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tcn_type: ' || p_tcnv_rec.tcn_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.rjn_code: ' || p_tcnv_rec.rjn_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.complete_transfer_yn: ' || p_tcnv_rec.complete_transfer_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.org_id: ' || p_tcnv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.khr_id: ' || p_tcnv_rec.khr_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.khr_id_old: ' || p_tcnv_rec.khr_id_old);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.try_id: ' || p_tcnv_rec.try_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tsu_code: ' || p_tcnv_rec.tsu_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.set_of_books_id: ' || p_tcnv_rec.set_of_books_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.trx_number: ' || p_tcnv_rec.trx_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_evergreen_yn: ' || p_tcnv_rec.tmt_evergreen_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_close_balances_yn: ' || p_tcnv_rec.tmt_close_balances_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_accounting_entries_yn: ' || p_tcnv_rec.tmt_accounting_entries_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_cancel_insurance_yn: ' || p_tcnv_rec.tmt_cancel_insurance_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_asset_disposition_yn: ' || p_tcnv_rec.tmt_asset_disposition_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_amortization_yn: ' || p_tcnv_rec.tmt_amortization_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_asset_return_yn: ' || p_tcnv_rec.tmt_asset_return_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_contract_updated_yn: ' || p_tcnv_rec.tmt_contract_updated_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_recycle_yn: ' || p_tcnv_rec.tmt_recycle_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_validated_yn: ' || p_tcnv_rec.tmt_validated_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_streams_updated_yn: ' || p_tcnv_rec.tmt_streams_updated_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_split_asset_yn: ' || p_tcnv_rec.tmt_split_asset_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.chr_id: ' || p_tcnv_rec.chr_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.source_trx_id: ' || p_tcnv_rec.source_trx_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.source_trx_type: ' || p_tcnv_rec.source_trx_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.legal_entity_id: ' || p_tcnv_rec.legal_entity_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.accounting_reversal_yn: ' || p_tcnv_rec.accounting_reversal_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.product_name: ' || p_tcnv_rec.product_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.book_classification_code: ' || p_tcnv_rec.book_classification_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tax_owner_code: ' || p_tcnv_rec.tax_owner_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_status_code: ' || p_tcnv_rec.tmt_status_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.representation_code: ' || p_tcnv_rec.representation_code);
	 END IF;

    -- Set the transaction
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set the x return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_overall_status');
    END IF;
    -- store the highest degree of error
    OKL_AM_LEASE_TRMNT_PVT.set_overall_status(
           p_return_status               => l_return_status,
           px_overall_status             => l_overall_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_overall_status , l_overall_status : ' || l_overall_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_database_values');
    END IF;
    -- If the termination request is from quote, populate the rest of the quote attributes
    OKL_AM_LEASE_TRMNT_PVT.set_database_values(
           px_term_rec                   => l_term_rec);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_database_values');
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_info_messages');
    END IF;
    -- Set the info messages intially
    OKL_AM_LEASE_TRMNT_PVT.set_info_messages(
           p_term_rec                   => l_term_rec);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_info_messages');
    END IF;

    -- check if transaction already exists
    -- RMUNJULU 04-APR-03 2889694 Changed OR to AND
    IF (p_tcnv_rec.id IS NOT NULL AND p_tcnv_rec.id <> OKL_API.G_MISS_NUM) THEN
      l_trn_already_set := 'Y';
    END IF;

    --get sysdate
    SELECT SYSDATE INTO l_sys_date FROM DUAL;

    IF l_trn_already_set = 'N' THEN

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.initialize_transaction');
      END IF;
      -- initialize the transaction rec
      OKL_AM_LEASE_TRMNT_PVT.initialize_transaction (
          px_tcnv_rec                   => lp_tcnv_rec,
          p_term_rec                    => l_term_rec,
          p_sys_date                    => l_sys_date,
          p_control_flag                => 'CREATE',
         x_return_status               => l_return_status,
	  -- akrangan bug 5354501 fix start
	  x_msg_count                   => x_msg_count,
	  x_msg_data                    => x_msg_data);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.initialize_transaction , return status: ' || l_return_status);
      END IF;
          --akrangan bug 5354501 fix end
      -- rollback if intialize transaction failed
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.process_transaction');
      END IF;
      -- insert the transaction record
      OKL_AM_LEASE_TRMNT_PVT.process_transaction(
          p_api_version     	          => p_api_version,
          p_init_msg_list   	          => OKL_API.G_FALSE,
          x_return_status   	          => l_return_status,
          x_msg_count       	          => x_msg_count,
          x_msg_data        	          => x_msg_data,
          p_id                          => 0,
          p_term_rec                    => l_term_rec,
          p_tcnv_rec                    => lp_tcnv_rec,
          x_id                          => lx_id,
          p_trn_mode                    => 'INSERT');
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.process_transaction , return status: ' || l_return_status);
      END IF;

      -- rollback if processing transaction failed
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- set the trn rec id
      lp_tcnv_rec.id := lx_id;

    ELSE -- transaction already set

      lp_tcnv_rec := p_tcnv_rec;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.initialize_transaction');
      END IF;
      -- initialize the transaction rec
      OKL_AM_LEASE_TRMNT_PVT.initialize_transaction (
          px_tcnv_rec                   => lp_tcnv_rec,
          p_term_rec                    => l_term_rec,
          p_sys_date                    => l_sys_date,
          p_control_flag                => 'UPDATE',
          x_return_status               => l_return_status,
	  -- akrangan bug 5354501 fix start
	  x_msg_count                   => x_msg_count,
	  x_msg_data                    => x_msg_data);
          --akrangan bug 5354501 fix end
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.initialize_transaction , return status: ' || l_return_status);
      END IF;

      -- rollback if intialize transaction failed
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_quote_dates');
    END IF;
    -- rmunjulu EDAT Get the quote effectivity date and quote acceptance date
    -- and store as global variables, will be used later on in other procedures
    OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_quote_dates(
          p_qte_id              => l_term_rec.p_quote_id,
          x_return_status       => l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_quote_dates , return status: ' || l_return_status);
    END IF;

    -- Rollback if error setting activity for api
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.validate_lease');
    END IF;
    -- check if loan valid
    -- rmunjulu LOANS_ENHANCEMENTS
    OKL_AM_LEASE_TRMNT_PVT.validate_lease(
        p_api_version     	            => p_api_version,
        p_init_msg_list   	            => OKL_API.G_FALSE,
        x_return_status   	            => l_return_status,
        x_msg_count       	            => x_msg_count,
        x_msg_data        	            => x_msg_data,
        p_sys_date                      => l_sys_date,
        p_term_rec                      => l_term_rec);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.validate_lease , return status: ' || l_return_status);
    END IF;

    -- Store the validation return status
    l_validate  := l_return_status;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_overall_status');
    END IF;
    -- store the highest degree of error
    OKL_AM_LEASE_TRMNT_PVT.set_overall_status(
        p_return_status                 => l_return_status,
        px_overall_status               => l_overall_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_overall_status , l_overall_status : ' || l_overall_status);
    END IF;

    IF (l_term_rec.p_control_flag = 'BATCH_PROCESS') THEN

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract');
      END IF;
      -- Since batch process is not checked initially in LLT check here
      OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   OKL_API.G_FALSE,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_contract_id                 =>   l_term_rec.p_contract_id,
           p_control_flag                =>   l_term_rec.p_control_flag,
           x_contract_status             =>   lx_contract_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract , return status: ' || l_return_status);
      END IF;

      -- Store the highest validation return status
      -- To capture the return status of validate lease called above
      IF (l_validate = OKL_API.G_RET_STS_SUCCESS) THEN
        l_validate  := l_return_status;
      END IF;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_overall_status');
      END IF;
      -- store the highest degree of error
      OKL_AM_LEASE_TRMNT_PVT.set_overall_status(
        p_return_status                 => l_validate, -- RMUNJULU 3018641 changed from l_return_status
        px_overall_status               => l_overall_status);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_overall_status , overall status: ' || l_overall_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
      END IF;
      -- set the transaction record
      OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec(
        p_return_status                 => l_validate, -- RMUNJULU 3018641 changed from l_return_status
        p_overall_status                => l_overall_status,
        p_tmt_flag                      => 'TMT_VALIDATED_YN',
        p_tsu_code                      => 'ENTERED',
        px_tcnv_rec                     => lp_tcnv_rec);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
      END IF;

      -- if validation failed then insert transaction
      -- and abort else continue next process
      IF (l_validate <> OKL_API.G_RET_STS_SUCCESS) THEN
        -- Validation of contract failed.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_VAL_OF_K_FAILED');

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
        END IF;
        -- set the transaction record
        OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec(
          p_return_status               => l_validate, -- RMUNJULU 3018641 changed from l_return_statu
          p_overall_status              => l_overall_status,
          p_tmt_flag                    => 'TMT_VALIDATED_YN',
          p_tsu_code                    => 'ERROR',
          px_tcnv_rec                   => lp_tcnv_rec);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.process_transaction');
        END IF;
        -- update the transaction record
        OKL_AM_LEASE_TRMNT_PVT.process_transaction(
          p_api_version     	          => p_api_version,
          p_init_msg_list   	          => OKL_API.G_FALSE,
          x_return_status   	          => l_return_status,
          x_msg_count       	          => x_msg_count,
          x_msg_data        	          => x_msg_data,
          p_id                            => 0,
          p_term_rec                      => l_term_rec,
          p_tcnv_rec                      => lp_tcnv_rec,
          x_id                            => lx_id,
          p_trn_mode                      => 'UPDATE');
          IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.process_transaction , return status: ' || l_return_status);
          END IF;

        -- rollback if processing transaction failed
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.process_messages');
        END IF;
        -- Save messages from stack into transaction message table
        OKL_AM_UTIL_PVT.process_messages(
        	p_trx_source_table	           => 'OKL_TRX_CONTRACTS',
        	p_trx_id		               => lp_tcnv_rec.id,
        	x_return_status                => l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.process_messages , return status: ' || l_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run');
        END IF;
        -- RMUNJULU 3018641 Added code to get and set TMG_RUN
        OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run(
               p_trx_id         => lp_tcnv_rec.id,
               x_return_status  => l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run , return status: ' || l_return_status);
        END IF;

        -- rollback if api failed
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- abort since validation failed
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE --( not from batch process) then

/*  -- RMUNJULU 3018641 Changed code to do validate step and store messages in trn
-- even when request from quote

      -- rollback if validation failed
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- set the transaction record
      OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec(
        p_return_status                 => l_return_status,
        p_overall_status                => l_overall_status,
        p_tmt_flag                      => 'TMT_VALIDATED_YN',
        p_tsu_code                      => 'ENTERED',
        px_tcnv_rec                     => lp_tcnv_rec);
*/

 -- RMUNJULU 3018641 Changed code to do validate step and store messages in trn

      -- if validation failed then insert transaction
      -- and abort else continue next process
      IF (l_validate <> OKL_API.G_RET_STS_SUCCESS) THEN

        -- Validation of contract failed.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_VAL_OF_K_FAILED');

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
        END IF;
        -- set the transaction record
        OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec(
          p_return_status               => l_validate, -- RMUNJULU 3018641 changed from l_return_status
          p_overall_status              => l_overall_status,
          p_tmt_flag                    => 'TMT_VALIDATED_YN',
          p_tsu_code                    => 'ERROR',
          px_tcnv_rec                   => lp_tcnv_rec);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.process_transaction');
        END IF;
        -- update the transaction record
        OKL_AM_LEASE_TRMNT_PVT.process_transaction(
          p_api_version     	          => p_api_version,
          p_init_msg_list   	          => OKL_API.G_FALSE,
          x_return_status   	          => l_return_status,
          x_msg_count       	          => x_msg_count,
          x_msg_data        	          => x_msg_data,
          p_id                          => 0,
          p_term_rec                    => l_term_rec,
          p_tcnv_rec                    => lp_tcnv_rec,
          x_id                          => lx_id,
          p_trn_mode                    => 'UPDATE');
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.process_transaction , return status: ' || l_return_status);
        END IF;

        -- rollback if processing transaction failed
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.process_messages');
        END IF;
        -- Save messages from stack into transaction message table
        OKL_AM_UTIL_PVT.process_messages(
        	p_trx_source_table	           => 'OKL_TRX_CONTRACTS',
        	p_trx_id		               => lp_tcnv_rec.id,
        	x_return_status                => l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.process_messages , return status: ' || l_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run');
        END IF;
        -- RMUNJULU 3018641 Added code to get and set TMG_RUN
        OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run(
               p_trx_id         => lp_tcnv_rec.id,
               x_return_status  => l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run , return status: ' || l_return_status);
        END IF;

        -- rollback if api failed
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- abort since validation failed
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.get_contract_lines');
    END IF;
    -- get the lines
    OKL_AM_LEASE_TRMNT_PVT.get_contract_lines(
        p_api_version     	            => p_api_version,
        p_init_msg_list   	            => OKL_API.G_FALSE,
        x_return_status   	            => l_return_status,
        x_msg_count       	            => x_msg_count,
        x_msg_data        	            => x_msg_data,
        p_term_rec                      => l_term_rec,
        x_klev_tbl                      => lx_klev_tbl);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.get_contract_lines , return status: ' || l_return_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.process_cancel_insurance');
    END IF;
    -- process to check and cancel insurance
    OKL_AM_LEASE_TRMNT_PVT.process_cancel_insurance(
        p_api_version     	            => p_api_version,
        p_init_msg_list   	            => OKL_API.G_FALSE,
        x_return_status   	            => l_return_status,
        x_msg_count       	            => x_msg_count,
        x_msg_data        	            => x_msg_data,
        p_term_rec                      => l_term_rec,
        px_overall_status               => l_overall_status,
        px_tcnv_rec                     => lp_tcnv_rec,
        p_sys_date                      => l_sys_date,
        p_trn_already_set               => l_trn_already_set);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.process_cancel_insurance , return status: ' || l_return_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.process_close_balances');
    END IF;
    -- set the balances rec, close small balances, set transaction
    OKL_AM_LEASE_TRMNT_PVT.process_close_balances(
        p_api_version     	            => p_api_version,
        p_init_msg_list   	            => OKL_API.G_FALSE,
        x_return_status   	            => l_return_status,
        x_msg_count       	            => x_msg_count,
        x_msg_data        	            => x_msg_data,
        p_term_rec                      => l_term_rec,
        px_overall_status               => l_overall_status,
        px_tcnv_rec                     => lp_tcnv_rec,
        x_adjv_rec                      => lx_adjv_rec,
        x_ajlv_tbl                      => lx_ajlv_tbl,
        p_sys_date                      => l_sys_date,
        p_trn_already_set               => l_trn_already_set);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.process_close_balances , return status: ' || l_return_status);
    END IF;


    -- RMUNJULU BUG # 3023206 Moved Close Streams into update_k_hdr_and_lines
    -- as accounting uses some CURR streams and so they should not be closed
    -- before accounting is done

/*
    -- process close streams
    OKL_AM_LEASE_TRMNT_PVT.process_close_streams(
        p_api_version     	            => p_api_version,
        p_init_msg_list   	            => OKL_API.G_FALSE,
        x_return_status   	            => l_return_status,
        x_msg_count       	            => x_msg_count,
        x_msg_data        	            => x_msg_data,
        p_term_rec                      => l_term_rec,
        px_overall_status               => l_overall_status,
        px_tcnv_rec                     => lp_tcnv_rec,
        x_stmv_tbl                      => lx_stmv_tbl,
        p_sys_date                      => l_sys_date,
        p_trn_already_set               => l_trn_already_set);
*/

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.process_accounting_entries');
    END IF;
    -- do accounting entries
    OKL_AM_LEASE_TRMNT_PVT.process_accounting_entries(
         p_api_version     	            => p_api_version,
         p_init_msg_list   	            => OKL_API.G_FALSE,
         x_return_status   	            => l_return_status,
         x_msg_count       	            => x_msg_count,
         x_msg_data        	            => x_msg_data,
         p_term_rec                     => l_term_rec,
         px_overall_status              => l_overall_status,
         px_tcnv_rec                    => lp_tcnv_rec,
         p_sys_date                     => l_sys_date,
         p_klev_tbl                     => lx_klev_tbl, -- PAGARG 4190887 Added
         p_trn_already_set              => l_trn_already_set);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.process_accounting_entries , return status: ' || l_return_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.process_asset_dispose');
    END IF;
    -- RMUNJULU 02-JAN-03 2724951 always do dispose for loans
    -- do asset dispose
    OKL_AM_LEASE_TRMNT_PVT.process_asset_dispose(
         p_api_version     	            => p_api_version,
         p_init_msg_list   	            => OKL_API.G_FALSE,
         x_return_status   	            => l_return_status,
         x_msg_count       	            => x_msg_count,
         x_msg_data        	            => x_msg_data,
         p_term_rec                     => l_term_rec,
         px_overall_status              => l_overall_status,
         px_tcnv_rec                    => lp_tcnv_rec,
         p_klev_tbl                     => lx_klev_tbl,
         p_trn_already_set              => l_trn_already_set);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.process_asset_dispose , return status: ' || l_return_status);
    END IF;

/*
    -- Check if termination with purchase
    IF (l_term_rec.p_quote_type IN('TER_PURCHASE', 'TER_RECOURSE', 'TER_ROLL_PURCHASE')) THEN

      -- do asset dispose
      OKL_AM_LEASE_TRMNT_PVT.process_asset_dispose(
         p_api_version     	            => p_api_version,
         p_init_msg_list   	            => OKL_API.G_FALSE,
         x_return_status   	            => l_return_status,
         x_msg_count       	            => x_msg_count,
         x_msg_data        	            => x_msg_data,
         p_term_rec                     => l_term_rec,
         px_overall_status              => l_overall_status,
         px_tcnv_rec                    => lp_tcnv_rec,
         p_klev_tbl                     => lx_klev_tbl,
         p_trn_already_set              => l_trn_already_set);

      -- Amortization of assets not needed since termination with purchase
      OKL_API.set_message( p_app_name   => G_APP_NAME,
                           p_msg_name   => 'OKL_AM_AMORTIZE_NOT_NEED');

      -- Return of assets not needed since termination with purchase
      OKL_API.set_message( p_app_name   => G_APP_NAME,
                           p_msg_name   => 'OKL_AM_RETURN_NOT_NEED');

    ELSE -- termination without purchase

      -- do amortization and asset return
      OKL_AM_LEASE_TRMNT_PVT.process_amortize_and_return(
         p_api_version     	            => p_api_version,
         p_init_msg_list   	            => OKL_API.G_FALSE,
         x_return_status   	            => l_return_status,
         x_msg_count       	            => x_msg_count,
         x_msg_data        	            => x_msg_data,
         p_term_rec                     => l_term_rec,
         px_overall_status              => l_overall_status,
         px_tcnv_rec                    => lp_tcnv_rec,
         p_sys_date                     => l_sys_date,
         p_klev_tbl                     => lx_klev_tbl,
         p_trn_already_set              => l_trn_already_set);

      -- Disposition of assets not needed since termination without purchase
      OKL_API.set_message( p_app_name   => G_APP_NAME,
                           p_msg_name   => 'OKL_AM_DISPOSE_NOT_NEED');

    END IF;
*/

    -- update the contract only if the overall_status is success
    IF (l_overall_status = OKL_API.G_RET_STS_SUCCESS) THEN

      -- Set the p_status (which sets the sts_code) for the contract
      IF  l_term_rec.p_control_flag = 'BATCH_PROCESS'
      AND (   l_term_rec.p_quote_id IS NULL
           OR l_term_rec.p_quote_id = OKL_API.G_MISS_NUM) THEN
         l_status := 'EXPIRED';
      ELSE
         l_status := 'TERMINATED';
      END IF;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.update_k_hdr_and_lines');
      END IF;
      -- set_and_update_contract
      OKL_AM_LEASE_TRMNT_PVT.update_k_hdr_and_lines(
        p_api_version     	            => p_api_version,
        p_init_msg_list   	            => OKL_API.G_FALSE,
        x_return_status   	            => l_return_status,
        x_msg_count       	            => x_msg_count,
        x_msg_data        	            => x_msg_data,
        p_status        	              => l_status,
        p_term_rec                      => l_term_rec,
        p_klev_tbl                      => lx_klev_tbl,
        p_trn_reason_code               => lp_tcnv_rec.trn_code,
        px_overall_status               => l_overall_status,
        px_tcnv_rec                     => lp_tcnv_rec,
        x_chrv_rec                      => lx_chrv_rec,
        x_clev_tbl                      => lx_clev_tbl,
        p_sys_date                      => l_sys_date);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.update_k_hdr_and_lines , return status: ' || l_return_status);
      END IF;

      IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
        END IF;
        -- set the transaction record
        OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec(
          p_return_status               => l_return_status,
          p_overall_status              => l_overall_status,
          p_tmt_flag                    => 'TMT_CONTRACT_UPDATED_YN',
          p_tsu_code                    => 'PROCESSED',
          px_tcnv_rec                   => lp_tcnv_rec);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
        END IF;

      ELSE -- Update of K hdr and lines failed

        -- Contract table update failed.
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_ERR_K_UPD');

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
        END IF;
        -- set the transaction record
        OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec(
          p_return_status               => l_return_status,
          p_overall_status              => l_overall_status,
          p_tmt_flag                    => 'TMT_CONTRACT_UPDATED_YN',
          p_tsu_code                    => 'ERROR',
          px_tcnv_rec                   => lp_tcnv_rec);
         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.set_transaction_rec');
         END IF;
      END IF;
    END IF;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_TRMNT_PVT.process_transaction');
    END IF;
    -- update the transaction record
    OKL_AM_LEASE_TRMNT_PVT.process_transaction(
          p_api_version     	          => p_api_version,
          p_init_msg_list   	          => OKL_API.G_FALSE,
          x_return_status   	          => l_return_status,
          x_msg_count       	          => x_msg_count,
          x_msg_data        	          => x_msg_data,
          p_id                          => 0,
          p_term_rec                    => l_term_rec,
          p_tcnv_rec                    => lp_tcnv_rec,
          x_id                          => lx_id,
          p_trn_mode                    => 'UPDATE');
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_TRMNT_PVT.process_transaction , return status: ' || l_return_status);
    END IF;

    -- rollback if processing transaction failed
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.process_messages');
    END IF;
    -- Save messages from stack into transaction message table
    OKL_AM_UTIL_PVT.process_messages(
    	p_trx_source_table	            => 'OKL_TRX_CONTRACTS',
    	p_trx_id		                    => lp_tcnv_rec.id,
    	x_return_status	              	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.process_messages , return status: ' || l_return_status);
    END IF;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run');
    END IF;
    -- RMUNJULU 3018641 Added code to get and set TMG_RUN
    OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run(
               p_trx_id         => lp_tcnv_rec.id,
               x_return_status  => l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run , return status: ' || l_return_status);
    END IF;

    -- rollback if api failed
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set the return status
    x_return_status  :=  OKL_API.G_RET_STS_SUCCESS;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_HALT_VALIDATION');
      END IF;
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END loan_termination;

END OKL_AM_LOAN_TRMNT_PVT;

/
