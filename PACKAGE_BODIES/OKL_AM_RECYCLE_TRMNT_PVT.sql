--------------------------------------------------------
--  DDL for Package Body OKL_AM_RECYCLE_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_RECYCLE_TRMNT_PVT" AS
/* $Header: OKLRRTXB.pls 120.4 2007/12/14 14:02:18 nikshah noship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_loan_trmnt_pvt.';

  -- Start of comments
  --
  -- Procedure Name	: validate_recycle
  -- Description	  : Validates the recycle transaction
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE validate_recycle(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_recy_rec					         	  IN  recy_rec_type) IS

    -- Cursor to get the DB values for the recycled transaction
    CURSOR get_recycle_vals_csr (p_rcy_id IN NUMBER) IS
      SELECT  id,
              khr_id,
              tmt_status_code,--akrangan changed for sla tmt_status_code cr
              tmt_recycle_yn,
              date_transaction_occurred
      FROM    OKL_TRX_CONTRACTS
      WHERE   id = p_rcy_id;

    -- Cursor to get the DB values for the recycled transaction
    CURSOR get_recycle_k_vals_csr (p_khr_id IN NUMBER) IS
      SELECT  id,
              contract_number,
              sts_code
      FROM    OKL_K_HEADERS_FULL_V
      WHERE   id = p_khr_id;

    get_recycle_vals_rec     get_recycle_vals_csr%ROWTYPE;
    get_recycle_k_vals_rec   get_recycle_k_vals_csr%ROWTYPE;
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_recycle_exception      EXCEPTION;
    lp_recy_rec              recy_rec_type := p_recy_rec;
    l_meaning                VARCHAR2(2000);
    l_term_meaning           VARCHAR2(2000);
    l_exp_meaning            VARCHAR2(2000);
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_recycle';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_contract_id: ' || p_recy_rec.p_contract_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_contract_number: ' || p_recy_rec.p_contract_number);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_contract_status: ' || p_recy_rec.p_contract_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_transaction_id: ' || p_recy_rec.p_transaction_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_transaction_status: ' || p_recy_rec.p_transaction_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_tmt_recycle_yn: ' || p_recy_rec.p_tmt_recycle_yn);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_transaction_date: ' || p_recy_rec.p_transaction_date);
    END IF;

    OPEN  get_recycle_vals_csr(lp_recy_rec.p_transaction_id);
    FETCH get_recycle_vals_csr INTO get_recycle_vals_rec;
    CLOSE get_recycle_vals_csr;

    -- Check if valid transaction id
    IF get_recycle_vals_rec.id IS NULL
    OR get_recycle_vals_rec.id = OKL_API.G_MISS_NUM THEN

      OKL_API.SET_MESSAGE(
                          p_app_name     => 'OKC',
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_transaction_id');

      RAISE l_recycle_exception;
    END IF;

    OPEN  get_recycle_k_vals_csr(get_recycle_vals_rec.khr_id);
    FETCH get_recycle_k_vals_csr INTO get_recycle_k_vals_rec;
    CLOSE get_recycle_k_vals_csr;

    -- Check if contract id valid
    IF get_recycle_k_vals_rec.id IS NULL
    OR get_recycle_k_vals_rec.id = OKL_API.G_MISS_NUM THEN

      OKL_API.SET_MESSAGE(
                           p_app_name     => 'OKC',
                           p_msg_name     => G_INVALID_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'p_contract_id');

      RAISE l_recycle_exception;
    END IF;


    -- Check if transaction already processed
    IF get_recycle_vals_rec.tmt_status_code = 'PROCESSED' THEN --akrangan changed for sla tmt_status_code cr

      l_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                          p_lookup_type  => 'OKL_TRANSACTION_STATUS',
                          p_lookup_code  => 'PROCESSED',
                          p_validate_yn  => 'Y');

      -- Cannot recycle transaction for contract CONTRACT_NUMBER which is already STATUS.
      OKL_API.SET_MESSAGE(
                          p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_AM_K_RECYCLE_STS_ERR',
                          p_token1        => 'CONTRACT_NUMBER',
                          p_token1_value  => get_recycle_k_vals_rec.contract_number,
                          p_token2        => 'STATUS',
                          p_token2_value  => l_meaning);

      RAISE l_recycle_exception;
    END IF;

    -- Check if transaction already set for recycle
    IF get_recycle_vals_rec.tmt_recycle_yn = 'Y' THEN

      -- Cannot recycle transaction for contract CONTRACT_NUMBER which is already set for recycle.
      OKL_API.SET_MESSAGE(
                          p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_AM_K_RECYCLE_RCY_ERR',
                          p_token1        => 'CONTRACT_NUMBER',
                          p_token1_value  => get_recycle_k_vals_rec.contract_number);

      RAISE l_recycle_exception;
    END IF;

    -- Check if contract status already terminated or expired
    IF get_recycle_k_vals_rec.sts_code IN ( 'TERMINATED', 'EXPIRED') THEN

      l_term_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                          p_lookup_type  => 'OKC_STATUS_TYPE',
                          p_lookup_code  => 'TERMINATED',
                          p_validate_yn  => 'Y');

      l_exp_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                          p_lookup_type  => 'OKC_STATUS_TYPE',
                          p_lookup_code  => 'EXPIRED',
                          p_validate_yn  => 'Y');

      -- Cannot recycle transaction for TERM_STATUS or EXP_STATUS contract CONTRACT_NUMBER.
      OKL_API.SET_MESSAGE(
                          p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_AM_K_RECYCLE_TMT_ERR',
                          p_token1        => 'CONTRACT_NUMBER',
                          p_token1_value  => get_recycle_k_vals_rec.contract_number,
                          p_token2        => 'TERM_STATUS',
                          p_token2_value  => l_term_meaning,
                          p_token3        => 'EXP_STATUS',
                          p_token3_value  => l_exp_meaning);

      RAISE l_recycle_exception;
    END IF;

    x_return_status  := l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;


  EXCEPTION

    WHEN l_recycle_exception THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'l_recycle_exception');
      END IF;
      IF get_recycle_vals_csr%ISOPEN THEN
        CLOSE get_recycle_vals_csr;
      END IF;
      IF get_recycle_k_vals_csr%ISOPEN THEN
        CLOSE get_recycle_k_vals_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      IF get_recycle_vals_csr%ISOPEN THEN
        CLOSE get_recycle_vals_csr;
      END IF;
      IF get_recycle_k_vals_csr%ISOPEN THEN
        CLOSE get_recycle_k_vals_csr;
      END IF;
      -- Set the oracle error message
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_recycle;

  -- Start of comments
  --
  -- Procedure Name	: recycle_termination
  -- Description	: Sets the transaction to recyle
  -- Business Rules	:
  -- Parameters	    :
  -- Version	    : 1.0
  -- History        : RMUNJULU 3018641 Added code to get_set_tmg_run
  --
  -- End of comments
  PROCEDURE recycle_termination(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_recy_rec					    IN  recy_rec_type,
    x_recy_rec				        OUT NOCOPY recy_rec_type) IS

    -- Cursor to get the contract details for the transaction being recycled
    CURSOR contract_details_csr ( p_tcn_id IN NUMBER) IS
      SELECT K.contract_number
      FROM   OKL_TRX_CONTRACTS   T,
             OKL_K_HEADERS_FULL_V  K
      WHERE  T.id     = p_tcn_id
      AND    T.khr_id = K.id;

    lp_tcnv_rec          OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
    lx_tcnv_rec          OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
    l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name           CONSTANT VARCHAR2(30) := 'recycle_termination';
    l_api_version        CONSTANT NUMBER := 1;
    l_contract_number    VARCHAR2(200);

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'recycle_termination';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_contract_id: ' || p_recy_rec.p_contract_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_contract_number: ' || p_recy_rec.p_contract_number);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_contract_status: ' || p_recy_rec.p_contract_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_transaction_id: ' || p_recy_rec.p_transaction_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_transaction_status: ' || p_recy_rec.p_transaction_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_tmt_recycle_yn: ' || p_recy_rec.p_tmt_recycle_yn);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_transaction_date: ' || p_recy_rec.p_transaction_date);
    END IF;

    -- Set the transaction
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    -- Rollback if error setting activity for api
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Validate the recycle transaction
    validate_recycle (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_recy_rec                     => p_recy_rec);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called validate_recycle , return status: ' || l_return_status);
    END IF;

    -- Rollback if error in validation
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- set tcnv_rec
    lp_tcnv_rec.id               :=     p_recy_rec.p_transaction_id;
    lp_tcnv_rec.tmt_recycle_yn   :=     'Y';

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_TRX_CONTRACTS_PUB.update_trx_contracts');
    END IF;
    -- call update of transaction
    OKL_TRX_CONTRACTS_PUB.update_trx_contracts(
              p_api_version                  => p_api_version,
              p_init_msg_list                => OKL_API.G_FALSE,
              x_return_status                => l_return_status,
              x_msg_count                    => x_msg_count,
              x_msg_data                     => x_msg_data,
              p_tcnv_rec                     => lp_tcnv_rec,
              x_tcnv_rec                     => lx_tcnv_rec);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_TRX_CONTRACTS_PUB.update_trx_contracts , return status: ' || l_return_status);
    END IF;

    -- raise exception if error
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get the contract details
    OPEN  contract_details_csr(lx_tcnv_rec.id);
    FETCH contract_details_csr INTO l_contract_number;
    CLOSE contract_details_csr;

    -- Set the message
    -- Message: Contract CONTRACT_NUMBER is scheduled to recycle.
    OKL_API.set_message(
               p_app_name                     => OKL_API.G_APP_NAME,
               p_msg_name                     => 'OKL_AM_K_SET_TO_RECYCLE',
               p_token1                       => 'CONTRACT_NUMBER',
               p_token1_value                 => l_contract_number);

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.process_messages');
    END IF;
    -- Save message from stack into transaction message table
    OKL_AM_UTIL_PVT.process_messages(
    	        p_trx_source_table  => 'OKL_TRX_CONTRACTS',
    	        p_trx_id		    => lx_tcnv_rec.id,
    	        x_return_status     => l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.process_messages , return status: ' || l_return_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run');
    END IF;

    -- RMUNJULU 3018641 Added code to get and set TMG_RUN
    OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run(
               p_trx_id         => lx_tcnv_rec.id,
               x_return_status  => l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.get_set_tmg_run , return status: ' || l_return_status);
    END IF;

    -- raise exception if error
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- set return variables
    x_return_status := l_return_status;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
      IF contract_details_csr%ISOPEN THEN
        CLOSE contract_details_csr;
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
      IF contract_details_csr%ISOPEN THEN
        CLOSE contract_details_csr;
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
      IF contract_details_csr%ISOPEN THEN
        CLOSE contract_details_csr;
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

  END recycle_termination;


  -- Start of comments
  --
  -- Procedure Name	: recycle_termination
  -- Description	  : Sets the transactions to recyle
  -- Business Rules	:
  -- Parameters		  :
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE recycle_termination(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_recy_tbl					   	        IN  recy_tbl_type,
    x_recy_tbl					   	        OUT NOCOPY recy_tbl_type) IS

    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER := 0;
    l_api_name                  CONSTANT VARCHAR2(30) := 'recycle_termination';
    l_api_version               CONSTANT NUMBER := 1;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'recycle_termination';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_tbl.COUNT: ' || p_recy_tbl.COUNT);
    END IF;


    -- Set the transaction
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    -- Rollback if error setting activity for api
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    IF (p_recy_tbl.COUNT > 0) THEN
      i := p_recy_tbl.FIRST;
      LOOP
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling recycle_termination');
        END IF;
        recycle_termination (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_recy_rec                     => p_recy_tbl(i),
          x_recy_rec                     => x_recy_tbl(i));
         IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called recycle_termination , return status: ' || l_return_status);
         END IF;

        -- raise exception if error
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        EXIT WHEN (i = p_recy_tbl.LAST);
        i := p_recy_tbl.NEXT(i);
      END LOOP;
    END IF;

    -- set return variables
    x_return_status := l_return_status;


    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
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

  END recycle_termination;


END OKL_AM_RECYCLE_TRMNT_PVT;

/
