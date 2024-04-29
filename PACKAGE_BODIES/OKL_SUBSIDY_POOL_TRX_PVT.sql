--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_POOL_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_POOL_TRX_PVT" AS
/* $Header: OKLRSIXB.pls 120.1 2005/10/30 03:17:16 appldev noship $ */

  -- Global Message Constants
  G_SUB_POOL_EXIPRED CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUBSIDY_POOL_EXPIRED';
  G_TRX_AMT_GT_TOT_SUBSIDY CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_TRX_AMT_MORE_THAN_SUB';
  G_TRX_AMT_GT_TOT_BUDGET CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_TRX_AMT_MORE_THAN_TOT';
  G_NO_SUBSIDY_ID CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_NO_SUBSIDY';
  G_TRX_REASON_CD_REVERSE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'REVERSE_CONTRACT';
  -------------------------------------------------------------------------------
  -- PROCEDURE create_pool_transaction
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pool_transaction
  -- Description     : This procedure is a wrapper that creates transaction records for
  --                 : subsidy pool. Note that this procedure will not report any error
  --                   if the subsidy is not attached with a pool
  --
  -- Business Rules  : this procedure is used to add to pool balance or reduce from pool
  --                   balance. the trx_type_code determines this action.
  --                   this procedure inserts records into the OKL_TRX_SUBSIDY_POOLS table
  --                   irrespective of trx_type_code. records can never be updated or
  --                   deleted from this table.
  --
  -- Parameters      : required parameters are source_type_code, source_object_id,
  --                   subsidy_id, trx_type_code, trx_reason_code, trx_amount, source_trx_date
  -- Version         : 1.0
  -- History         : 01-FEB-2005 SJALASUT created
  -- End of comments

  PROCEDURE create_pool_transaction(p_api_version   IN 	NUMBER,
                                    p_init_msg_list IN  VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count     OUT NOCOPY NUMBER,
                                    x_msg_data      OUT NOCOPY VARCHAR2,
                                    p_sixv_rec      IN  sixv_rec_type,
                                    x_sixv_rec      OUT NOCOPY sixv_rec_type)IS

    CURSOR c_get_pool_dates_csr IS
    SELECT pool.id
          , pool.effective_from_date
          , pool.effective_to_date
          , pool.decision_status_code
          , sub.name
          , pool.currency_code
          , pool.currency_conversion_type
          , nvl(pool.total_budgets,0) total_budgets
          , nvl(pool.total_subsidy_amount,0) total_subsidy_amount
          , pool.subsidy_pool_name
      FROM okl_subsidy_pools_b pool,
           okl_subsidies_b sub
     WHERE sub.subsidy_pool_id = pool.id
       AND sub.id = p_sixv_rec.subsidy_id;
     cv_pool_details c_get_pool_dates_csr%ROWTYPE;

    l_sixv_rec sixv_rec_type;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'CREATE_POOL_TRANSACTION';
    l_return_status VARCHAR2(1);
    lv_pool_expired VARCHAR2(1);
    lv_conv_rate NUMBER;
    lv_subsidy_pool_amt okl_trx_subsidy_pools.SUBSIDY_POOL_AMOUNT%TYPE;
    lv_subsidy_pool_round_amt okl_trx_subsidy_pools.SUBSIDY_POOL_AMOUNT%TYPE;
    lv_total_subsidy_amt okl_subsidy_pools_b.total_subsidy_amount%TYPE;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_TRX_PVT.CREATE_POOL_TRANSACTION';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIXB.pls call create_pool_transaction');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    lv_pool_expired := OKL_API.G_FALSE;
    l_sixv_rec := p_sixv_rec;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
      p_api_name      => l_api_name
      ,p_pkg_name      => G_PKG_NAME
      ,p_init_msg_list => p_init_msg_list
      ,l_api_version   => l_api_version
      ,p_api_version   => p_api_version
      ,p_api_type      => g_api_type
      ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check if the subsidy id is passed, all further logic depend on subsidy id
    IF(p_sixv_rec.subsidy_id IS NULL OR p_sixv_rec.subsidy_id = OKL_API.G_MISS_NUM)THEN
      OKC_API.set_message(G_APP_NAME, G_NO_SUBSIDY_ID);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- fetch the subsidy and associated pool details if any
    OPEN c_get_pool_dates_csr; FETCH c_get_pool_dates_csr INTO cv_pool_details;
    CLOSE c_get_pool_dates_csr;

    -- if subsidy pool id is not found, do not throw an error, just return
    IF(cv_pool_details.id IS NOT NULL)THEN
      l_sixv_rec.subsidy_pool_id := cv_pool_details.id;

      -- check the status of the pool attached to the subsidy and expire the pool if need be
      -- if the pool is expired, then raise an error that no transactions are permitted on an expired pool
      -- the code check before date check actually save a DML call
      -- also, for ADDITION type transaction, the expiration check is not required as the pool balance is being
      -- augmented and no harm is being done.
      IF(NVL(cv_pool_details.effective_to_date,to_date('31/12/4712','DD/MM/RRRR')) < TRUNC(SYSDATE) AND p_sixv_rec.trx_type_code <> 'ADDITION')THEN
        lv_pool_expired := OKL_API.G_TRUE;
        IF(cv_pool_details.decision_status_code <> 'EXPIRED')THEN
          -- pool though expired by dates, is not set to status EXPIRED. set the status and do not permit this transaction
          -- THE EXPIRATION IS AN AUTONOMOUS TRANSACTION, see okl_subsidy_pools_pvt for more details
          okl_subsidy_pool_pvt.expire_sub_pool(p_api_version     => p_api_version
                                               ,p_init_msg_list   => p_init_msg_list
                                               ,x_return_status   => x_return_status
                                               ,x_msg_count       => x_msg_count
                                               ,x_msg_data        => x_msg_data
                                               ,p_subsidy_pool_id => cv_pool_details.id
                                              );
          -- write to log
          IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'l_sixv_rec.subsidy_pool_id '||to_char(l_sixv_rec.subsidy_pool_id) || ' p_sixv_rec.source_trx_date '||p_sixv_rec.source_trx_date ||
                                    ' expiring subsidy pool with ret status '||x_return_status||' x_msg_data '||x_msg_data
                                    );
          END IF; -- end of NVL(l_debug_enabled,'N')='Y'

          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- end decision status code check
      END IF; -- end effective to date check
      IF(lv_pool_expired = OKL_API.G_TRUE)THEN
        OKL_API.set_message(G_APP_NAME, G_SUB_POOL_EXIPRED, 'SUB_NAME', cv_pool_details.name, 'ASSET', p_sixv_rec.dnz_asset_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- commenting this for there are no lookups as of now
      -- call validations on the transaction record
      OKL_SIX_PVT.validate_row(p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_sixv_rec      => l_sixv_rec
                              );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'OKL_SIX_PVT.validate_row returned with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- now validate if the ADDITION operation on the subsidy pool balance is not reducing the subsidy less than 0
      IF(l_sixv_rec.trx_type_code = 'ADDITION')THEN
        IF(l_sixv_rec.subsidy_pool_amount > cv_pool_details.total_subsidy_amount)THEN
          OKL_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_SUBSIDY
                              ,'TRX_AMOUNT', l_sixv_rec.trx_amount
                              ,'SUBSIDY', cv_pool_details.name
                              ,'POOL_NAME',cv_pool_details.subsidy_pool_name);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSIF(l_sixv_rec.trx_type_code = 'REDUCTION') THEN
        -- determine the pool amount from the transaction amount.
        IF(l_sixv_rec.trx_currency_code <> cv_pool_details.currency_code)THEN
          lv_conv_rate := 0;
          -- currency conversion date is as on the subsidy pool transaction date which is sysdate
          okl_accounting_util.get_curr_con_rate(p_api_version    => p_api_version
                                                ,p_init_msg_list  => p_init_msg_list
                                                ,x_return_status  => x_return_status
                                                ,x_msg_count      => x_msg_count
                                                ,x_msg_data       => x_msg_data
                                                ,p_from_curr_code => l_sixv_rec.trx_currency_code
                                                ,p_to_curr_code   => cv_pool_details.currency_code
                                                ,p_con_date       => TRUNC(SYSDATE)
                                                ,p_con_type       => cv_pool_details.currency_conversion_type
                                                ,x_conv_rate      => lv_conv_rate
                                               );
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- compute pool amount
          lv_subsidy_pool_amt := 0;
          lv_subsidy_pool_amt := lv_conv_rate * l_sixv_rec.trx_amount;
          l_sixv_rec.conversion_rate := lv_conv_rate;
          -- now round off the amount
          lv_subsidy_pool_round_amt := 0;
          okl_accounting_util.cross_currency_round_amount(p_api_version    => p_api_version
                                                          ,p_init_msg_list   => p_init_msg_list
                                                          ,x_return_status  => x_return_status
                                                          ,x_msg_count      => x_msg_count
                                                          ,x_msg_data       => x_msg_data
                                                          ,p_amount         => lv_subsidy_pool_amt
                                                          ,p_currency_code  => cv_pool_details.currency_code
                                                          ,x_rounded_amount => lv_subsidy_pool_round_amt
                                                         );
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- write to log
          IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'lv_conv_rate '||lv_conv_rate||' l_sixv_rec.trx_amount '||l_sixv_rec.trx_amount||' lv_subsidy_pool_round_amt '||lv_subsidy_pool_round_amt
                                    );
          END IF; -- end of NVL(l_debug_enabled,'N')='Y'
        ELSE -- currency codes are the same, so need to convert
          lv_subsidy_pool_round_amt := l_sixv_rec.trx_amount;
          l_sixv_rec.conversion_rate := 1.0;
        END IF; -- end of trx currency code check

        -- REDUCTION operation on the pool balance is not overshooting the total budget
        -- in other words, REDUCTION operation should not be more than the remaining balance
        IF((lv_subsidy_pool_round_amt + cv_pool_details.total_subsidy_amount) > cv_pool_details.total_budgets)THEN
          OKL_API.set_message(G_APP_NAME, G_TRX_AMT_GT_TOT_BUDGET
                              ,'TRX_AMOUNT', l_sixv_rec.trx_amount
                              ,'SUBSIDY', cv_pool_details.name
                              ,'POOL_NAME',cv_pool_details.subsidy_pool_name);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_sixv_rec.subsidy_pool_currency_code := cv_pool_details.currency_code;
        l_sixv_rec.subsidy_pool_amount := lv_subsidy_pool_round_amt;
      END IF; -- end of trx_type_code check

      l_sixv_rec.trx_date := trunc(sysdate);
      -- call the TAPI insert_row to create a subsidy pool transaction
      OKL_SIX_PVT.insert_row(p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_sixv_rec      => l_sixv_rec
                             ,x_sixv_rec      => x_sixv_rec
                            );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'created pool transaction record with status '||x_return_status || ' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      lv_total_subsidy_amt := 0;
      IF(l_sixv_rec.trx_type_code = 'ADDITION')THEN
        lv_total_subsidy_amt := cv_pool_details.total_subsidy_amount - l_sixv_rec.subsidy_pool_amount;
      ELSIF(l_sixv_rec.trx_type_code = 'REDUCTION')THEN
        lv_total_subsidy_amt := cv_pool_details.total_subsidy_amount + l_sixv_rec.subsidy_pool_amount;
      END IF;
      -- note that (total budget - subsidy amount) = remaining balance
      -- based on the transaction type, the subsidy amount is increased (in case of REDUCTION transaction or reducing  pool balance)
      -- or subsidy amount is decreased (in case of ADDITION transaction or adding back to pool balance)
      okl_subsidy_pool_pvt.update_subsidy_amount(p_api_version     => p_api_version
                                                 ,p_init_msg_list   => p_init_msg_list
                                                 ,x_return_status   => x_return_status
                                                 ,x_msg_count       => x_msg_count
                                                 ,x_msg_data        => x_msg_data
                                                 ,p_subsidy_pool_id => cv_pool_details.id
                                                 ,p_total_subsidy_amt => lv_total_subsidy_amt
                                                );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'updated total_subsisy_amount '||lv_total_subsidy_amt||' with status '||x_return_status || ' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of subsidy pool id is not null

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIXB.pls call create_pool_transaction');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END create_pool_transaction;


  PROCEDURE create_pool_transaction(p_api_version   IN 	NUMBER,
                                    p_init_msg_list IN  VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count     OUT NOCOPY NUMBER,
                                    x_msg_data      OUT NOCOPY VARCHAR2,
                                    p_sixv_tbl      IN  sixv_tbl_type,
                                    x_sixv_tbl      OUT NOCOPY sixv_tbl_type) IS
    l_return_status        VARCHAR2(1);
    l_api_name             CONSTANT varchar2(30) := 'CREATE_POOL_TRANSACTION';
    i                      NUMBER := 0;
    l_six_tbl  sixv_tbl_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_six_tbl := p_sixv_tbl;
    IF(l_six_tbl.COUNT > 0 )THEN
      i := l_six_tbl.FIRST;
      LOOP
        create_pool_transaction(
             p_api_version        => p_api_version,
             p_init_msg_list      => p_init_msg_list,
             x_return_status      => x_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data,
             p_sixv_rec            => l_six_tbl(i),
             x_sixv_rec            => x_sixv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      EXIT WHEN (i = l_six_tbl.LAST);
        i := l_six_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

  END create_pool_transaction;

END okl_subsidy_pool_trx_pvt;

/
