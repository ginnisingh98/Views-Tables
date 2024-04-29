--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_POOL_AUTH_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_POOL_AUTH_TRX_PVT" AS
/* $Header: OKLRSIUB.pls 120.2.12010000.2 2008/10/01 22:34:17 rkuttiya ship $ */

G_NO_SUB_POOL_TRX_FOUND CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_NO_SUB_POOL_TRX_FOUND';
G_TRX_SOURCE_TYPE_CODE CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'LEASE_CONTRACT';
G_ADDITION_TYPE_CODE CONSTANT okl_trx_subsidy_pools.trx_type_code%TYPE DEFAULT 'ADDITION';
G_REDUCTION_TYPE_CODE CONSTANT okl_trx_subsidy_pools.trx_type_code%TYPE DEFAULT 'REDUCTION';
G_CONTRACT_REVERSAL_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'REVERSE_CONTRACT';
G_CONTRACT_BOOK_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'ACTIVATE_CONTRACT';
G_CONTRACT_REBOOK_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'REBOOK_CONTRACT';
G_CONTRACT_SPLIT_CODE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'SPLIT_CONTRACT';
G_SOURCE_TRX_DATE_POOL_VAL CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_INVALID_RBK_DATE';
G_NO_POOL_TRANSACTION_EXISTS CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_NO_POOL_TRX_EXISTS';

-- start: cklee 07/12/2005
G_ORIG_CODE_LEASE_APP CONSTANT varchar2(30) := 'OKL_LEASE_APP';
G_ORIG_CODE_QUOTE CONSTANT varchar2(30) := 'OKL_QUOTE';
-- end: cklee 07/12/2005

-- local procedure 1. START
  PROCEDURE pool_trx_khr_rbk(p_source_trx_date IN okl_trx_subsidy_pools.source_trx_date%TYPE
                            ,p_six_tbl         IN okl_six_pvt.sixv_tbl_type
                            ,x_return_status  OUT NOCOPY VARCHAR2)IS

    CURSOR c_get_pool_dates_csr(cp_subsidy_pool_id okl_subsidy_pools_b.id%TYPE) IS
    SELECT effective_from_date
          ,effective_to_date
          ,subsidy_pool_name
      FROM okl_subsidy_pools_b
     WHERE id = cp_subsidy_pool_id;
    cv_get_pool_dates_csr c_get_pool_dates_csr%ROWTYPE;

    CURSOR c_get_pool_trx_details(cp_source_object_id okl_trx_subsidy_pools.source_object_id%TYPE
                                 ,cp_subsidy_pool_id okl_trx_subsidy_pools.subsidy_pool_id%TYPE
                                 ,cp_pool_currency_code okl_trx_subsidy_pools.subsidy_pool_currency_code%TYPE
                                 ,cp_vendor_id okl_trx_subsidy_pools.vendor_id%TYPE
                                 ,cp_asset_number okl_trx_subsidy_pools.dnz_asset_number%TYPE
                                 ,cp_subsidy_id okl_trx_subsidy_pools.subsidy_id%TYPE
                                 ,cp_trx_amount okl_trx_subsidy_pools.trx_amount%TYPE
                                 ,cp_trx_currency_code okl_trx_subsidy_pools.trx_currency_code%TYPE
                                  ) IS
    SELECT trx_reason_code
          ,subsidy_pool_amount
          ,conversion_rate
     FROM okl_trx_subsidy_pools
    WHERE trx_type_code = 'REDUCTION'
      AND source_type_code = G_TRX_SOURCE_TYPE_CODE
      AND source_object_id = cp_source_object_id
      AND subsidy_pool_id = cp_subsidy_pool_id
      AND subsidy_pool_currency_code = cp_pool_currency_code
      AND vendor_id = cp_vendor_id
      AND subsidy_id = cp_subsidy_id
      AND dnz_asset_number = cp_asset_number
      AND trx_amount = cp_trx_amount
      AND trx_currency_code = cp_trx_currency_code;
    cv_get_pool_trx_details c_get_pool_trx_details%ROWTYPE;

    lv_six_tbl okl_six_pvt.sixv_tbl_type;
    lx_six_tbl okl_six_pvt.sixv_tbl_type;
    idx PLS_INTEGER;
    total_num_recs NUMBER;
    x_msg_count NUMBER;
    l_api_version CONSTANT NUMBER DEFAULT '1.0';
    x_msg_data VARCHAR2(100);

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_AUTH_TRX_PVT.POOL_TRX_KHR_RBK';
    l_debug_enabled VARCHAR2(10);
    is_debug_statement_on BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    lv_six_tbl := p_six_tbl;
    idx := 0;
    total_num_recs := p_six_tbl.COUNT;

    FOR idx IN 1 .. total_num_recs LOOP
      -- get the subsidy pool effective dates
      OPEN c_get_pool_dates_csr(lv_six_tbl(idx).subsidy_pool_id); FETCH c_get_pool_dates_csr INTO cv_get_pool_dates_csr;
      CLOSE c_get_pool_dates_csr;
      -- validate if the source transaction date is between the passed subsidy pool dates
      IF NOT(TRUNC(p_source_trx_date) BETWEEN cv_get_pool_dates_csr.effective_from_date AND
             NVL(cv_get_pool_dates_csr.effective_to_date,OKL_ACCOUNTING_UTIL.g_final_date))THEN
        OKL_API.set_message(G_APP_NAME, G_SOURCE_TRX_DATE_POOL_VAL
                            ,'TRX_DATE', p_source_trx_date
                            ,'POOL_NAME', cv_get_pool_dates_csr.subsidy_pool_name
                            ,'ASSET_NUMBER',lv_six_tbl(idx).dnz_asset_number);
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- any errors here would be rolled up to display as a bundled error; i.e. all subsidy elements are
        -- processed to show applicable errors. hence no raise statement
      ELSE
        -- assign the source trx date to the date of the rebook
        lv_six_tbl(idx).source_trx_date := p_source_trx_date;
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  idx||' source trx date check passed for subsidy '||lv_six_tbl(idx).subsidy_id
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
      END IF;
      -- for ADDITION to pool balance, check if there was a prior REDUCTION operation.
      -- this validation ensures that we are not adding back to the pool balance without ever reducing from it
      -- in ideal scenarios, this check never fails, but this check is essential to stop data corruption
      IF(lv_six_tbl(idx).trx_type_code = 'ADDITION' AND x_return_status = OKL_API.G_RET_STS_SUCCESS)THEN
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  ' finding trx for pool '||lv_six_tbl(idx).subsidy_pool_id || ' lv_six_tbl(idx).source_object_id '||lv_six_tbl(idx).source_object_id
                                  ||' lv_six_tbl(idx).vendor_id '||lv_six_tbl(idx).vendor_id||' lv_six_tbl(idx).dnz_asset_number '||lv_six_tbl(idx).dnz_asset_number
                                  ||' lv_six_tbl(idx).subsidy_id '||lv_six_tbl(idx).subsidy_id ||' lv_six_tbl(idx).subsidy_pool_currency_code '||lv_six_tbl(idx).subsidy_pool_currency_code
                                  ||' lv_six_tbl(idx).trx_currency_code '||lv_six_tbl(idx).trx_currency_code
                                  ||' lv_six_tbl(idx).trx_amount '||lv_six_tbl(idx).trx_amount
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
        -- fill up other important columns from the subsidy pool trx table. we are not recalculating
        -- the amount into subsidy pool currency again for consistency reasons.
        OPEN c_get_pool_trx_details(cp_source_object_id   => lv_six_tbl(idx).source_object_id
                                   ,cp_subsidy_pool_id    => lv_six_tbl(idx).subsidy_pool_id
                                   ,cp_pool_currency_code => lv_six_tbl(idx).subsidy_pool_currency_code
                                   ,cp_vendor_id          => lv_six_tbl(idx).vendor_id
                                   ,cp_asset_number       => lv_six_tbl(idx).dnz_asset_number
                                   ,cp_subsidy_id         => lv_six_tbl(idx).subsidy_id
                                   ,cp_trx_amount         => lv_six_tbl(idx).trx_amount
                                   ,cp_trx_currency_code  => lv_six_tbl(idx).trx_currency_code
                                   );
        FETCH c_get_pool_trx_details INTO cv_get_pool_trx_details;
        IF(c_get_pool_trx_details%NOTFOUND)THEN
          CLOSE c_get_pool_trx_details;
          OKL_API.set_message(G_APP_NAME, G_NO_POOL_TRANSACTION_EXISTS
                              ,'ASSET_NUMBER', lv_six_tbl(idx).dnz_asset_number);
          x_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
        CLOSE c_get_pool_trx_details;
        lv_six_tbl(idx).subsidy_pool_amount := cv_get_pool_trx_details.subsidy_pool_amount;
        lv_six_tbl(idx).conversion_rate := cv_get_pool_trx_details.conversion_rate;
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  idx||' found trx for pool '||lv_six_tbl(idx).subsidy_pool_id || ' lv_six_tbl(idx).source_object_id '||lv_six_tbl(idx).source_object_id
                                  ||' lv_six_tbl(idx).vendor_id '||lv_six_tbl(idx).vendor_id||' lv_six_tbl(idx).dnz_asset_number '||lv_six_tbl(idx).dnz_asset_number
                                  ||' lv_six_tbl(idx).subsidy_id '||lv_six_tbl(idx).subsidy_id
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
      END IF; -- end of lv_six_tbl(idx).trx_type_code = 'ADDITION' AND x_return_status = OKL_API.G_RET_STS_SUCCESS
      lv_six_tbl(idx).source_type_code := G_TRX_SOURCE_TYPE_CODE;
      lv_six_tbl(idx).trx_reason_code := G_CONTRACT_REBOOK_CODE;
    END LOOP;
    -- now call the create pool transacation api
    IF(x_return_status = OKL_API.G_RET_STS_SUCCESS)THEN
      okl_subsidy_pool_trx_pvt.create_pool_transaction(p_api_version => l_api_version
                                                      ,p_init_msg_list => OKL_API.G_TRUE
                                                      ,x_return_status => x_return_status
                                                      ,x_msg_count    => x_msg_count
                                                      ,x_msg_data     => x_msg_data
                                                      ,p_sixv_tbl     => lv_six_tbl
                                                      ,x_sixv_tbl     => lx_six_tbl
                                                     );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
  END pool_trx_khr_rbk;
-- local procedure 1. END

-- local procedure 2. START
  PROCEDURE reduce_pool_balance(p_khr_id IN okc_k_headers_b.id%TYPE
                               ,p_source_trx_date IN okl_trx_subsidy_pools.source_trx_date%TYPE
                               ,x_return_status OUT NOCOPY VARCHAR2) IS

    -- cursor to fetch all subsidies attached to assets on the contract
    CURSOR c_subsidy_csr(cp_chr_id IN okc_k_headers_b.id%TYPE) IS
    SELECT kle.subsidy_id
           ,clet.name
           ,clet.item_description
           ,kle.amount
           ,kle.subsidy_override_amount
           ,cplb.object1_id1  vendor_id
           ,cplb.id           cpl_id
           ,kle.sty_id        sty_id
           ,cleb.cle_id       asset_id
           ,cleb.currency_code
      FROM okl_k_lines          kle
           ,okc_k_lines_tl       clet
           ,okc_k_lines_b        cleb
           ,okc_statuses_b       stsb
           ,okc_line_styles_b    lseb
           ,okc_k_party_roles_b  cplb
     WHERE kle.id          = cleb.id
       AND clet.id         = cleb.id
       AND clet.language   = userenv('LANG')
       AND cleb.dnz_chr_id = cp_chr_id
       AND stsb.code       = cleb.sts_code
       AND stsb.ste_code   not in ('CANCELLED')
       AND lseb.id         =  cleb.lse_id
       AND lseb.lty_code   =  'SUBSIDY'
       AND cplb.cle_id     = cleb.id
       AND cplb.rle_code   = 'OKL_VENDOR'
       AND cplb.dnz_chr_id = cp_chr_id;

    CURSOR c_get_asset_csr (cp_asset_id okc_k_lines_b.id%TYPE)IS
    SELECT clev_asst.name asset_number
      FROM okc_k_lines_v clev_asst
     WHERE clev_asst.id = cp_asset_id;
    lv_asset_number okc_k_lines_v.name%TYPE;

    lx_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
    lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
    lv_subsidy_applic VARCHAR2(10);
    lv_six_tbl okl_six_pvt.sixv_tbl_type;
    lx_six_tbl okl_six_pvt.sixv_tbl_type;
    idx NUMBER;
    total_num_recs NUMBER;
    x_msg_count NUMBER;
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    x_msg_data VARCHAR2(1000);

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_AUTH_TRX_PVT.REDUCE_POOL_BALANCE';
    l_debug_enabled VARCHAR2(10);
    is_debug_statement_on BOOLEAN;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'inside local procedure reduce_pool_balance '||p_khr_id
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on


    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- initialize tbl type parameters and idx
    lv_six_tbl.DELETE; lx_six_tbl.DELETE;
    idx := 0;

    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'before processing REDUCTION records '||p_khr_id
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on


    FOR cv_susidy_rec IN c_subsidy_csr(cp_chr_id => p_khr_id) LOOP
      lx_subsidy_pool_id := NULL;
      lx_sub_pool_curr_code := NULL;
      lv_subsidy_applic := 'N';
      lv_subsidy_applic := okl_asset_subsidy_pvt.is_sub_assoc_with_pool(p_subsidy_id => cv_susidy_rec.subsidy_id
                                                                           ,x_subsidy_pool_id => lx_subsidy_pool_id
                                                                           ,x_sub_pool_curr_code => lx_sub_pool_curr_code);
      IF(lv_subsidy_applic = 'Y')THEN
        idx := idx + 1;
        lv_six_tbl(idx).trx_type_code := G_REDUCTION_TYPE_CODE;
        lv_six_tbl(idx).source_type_code := G_TRX_SOURCE_TYPE_CODE;
        lv_six_tbl(idx).source_object_id := p_khr_id;
        lv_six_tbl(idx).subsidy_pool_id := lx_subsidy_pool_id;
        lv_asset_number := NULL;
        OPEN c_get_asset_csr(cv_susidy_rec.asset_id); FETCH c_get_asset_csr INTO lv_asset_number;
        CLOSE c_get_asset_csr;
        lv_six_tbl(idx).dnz_asset_number := lv_asset_number;
        lv_six_tbl(idx).vendor_id := cv_susidy_rec.vendor_id;
        lv_six_tbl(idx).source_trx_date := p_source_trx_date;
        lv_six_tbl(idx).subsidy_id := cv_susidy_rec.subsidy_id;
        lv_six_tbl(idx).trx_reason_code := G_CONTRACT_BOOK_CODE;
        lv_six_tbl(idx).trx_currency_code := cv_susidy_rec.currency_code;
        lv_six_tbl(idx).trx_amount := NVL(cv_susidy_rec.subsidy_override_amount,NVL(cv_susidy_rec.amount,0));
        lv_six_tbl(idx).subsidy_pool_currency_code := lx_sub_pool_curr_code;
      END IF;
    END LOOP;
    -- now check the length of the table lv_sixv_tbl and then call the okl_subsidy_pool_trx_pvt api to create ADDITION transactions
    IF(lv_six_tbl.COUNT > 0)THEN
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                lv_six_tbl.COUNT||' records found for reversing from the contract '||p_khr_id || ' p_source_trx_date '|| p_source_trx_date
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

      okl_subsidy_pool_trx_pvt.create_pool_transaction(p_api_version => l_api_version
                                                      ,p_init_msg_list => OKL_API.G_FALSE
                                                      ,x_return_status => x_return_status
                                                      ,x_msg_count    => x_msg_count
                                                      ,x_msg_data     => x_msg_data
                                                      ,p_sixv_tbl     => lv_six_tbl
                                                      ,x_sixv_tbl     => lx_six_tbl
                                                     );
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_subsidy_pool_trx_pvt.create_pool_transaction from reduce_pool_balance returned with status '||x_return_status
                                ||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

  EXCEPTION WHEN OTHERS THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
  END reduce_pool_balance;
-- local procedure 2. END

  PROCEDURE create_pool_trx_khr_book(p_api_version   IN NUMBER
                                   ,p_init_msg_list IN VARCHAR2
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER
                                   ,x_msg_data      OUT NOCOPY VARCHAR2
                                   ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                   ,p_asset_id      IN okc_k_lines_b.id%TYPE
                                   ,p_subsidy_id    IN okl_subsidies_b.id%TYPE
                                   ,p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                   ,p_trx_amount    IN okl_k_lines.amount%TYPE
                                   ) IS

    -- cursor to fetch asset details
    CURSOR c_get_asset_csr IS
    SELECT clev_asst.name asset_number
          ,clev_asst.start_date asset_start_date
          ,clev_asst.currency_code
      FROM okc_k_lines_v clev_asst
     WHERE clev_asst.id = p_asset_id;
    cv_get_asset_rec c_get_asset_csr%ROWTYPE;

    -- cursor to check if the contract has been originated from quote or lease application
    CURSOR c_chk_orig_source_csr IS
    SELECT orig_system_id1
          ,orig_system_source_code
          ,scs_code
      FROM okc_k_headers_b
     WHERE id = p_chr_id;
    cv_chk_orig_source c_chk_orig_source_csr%ROWTYPE;

    -- cursor to fetch the vendor details of the asset
    CURSOR c_get_vendor_csr IS
    SELECT vendor_id
      FROM okl_asset_subsidy_uv
     WHERE asset_cle_id = p_asset_id;
    cv_get_vendor c_get_vendor_csr%ROWTYPE;

    lv_sixv_rec sixv_rec_type;
    lx_sixv_rec sixv_rec_type;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'POOL_TRX_KHR_BOOK';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_AUTH_TRX_PVT.CREATE_POOL_TRX_KHR_BOOK';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIUB.pls call create_pool_trx_khr_book');
    END IF;

    -- Call start_activity to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    -- populate all the attributes that are necessary for the subsidy pool transaction record
    lv_sixv_rec.source_object_id := p_chr_id;
    lv_sixv_rec.subsidy_id := p_subsidy_id;
    lv_sixv_rec.subsidy_pool_id := p_subsidy_pool_id;

    -- derive immediate values from the parameters passed
    -- derive asset number.
    OPEN c_get_asset_csr; FETCH c_get_asset_csr INTO cv_get_asset_rec;
    CLOSE c_get_asset_csr;
    lv_sixv_rec.dnz_asset_number := cv_get_asset_rec.asset_number;
    -- source transaction date is the start date of the asset.
    lv_sixv_rec.source_trx_date := TRUNC(cv_get_asset_rec.asset_start_date);
    -- trx currency code is the contract or asset currency code.
    lv_sixv_rec.trx_currency_code := cv_get_asset_rec.currency_code;
    lv_sixv_rec.trx_amount := p_trx_amount;

    -- now get the vendor on the asset subsidy
    OPEN c_get_vendor_csr; FETCH c_get_vendor_csr INTO cv_get_vendor;
    CLOSE c_get_vendor_csr;
    lv_sixv_rec.vendor_id := cv_get_vendor.vendor_id;

    -- fetch the scs code from p_chr_id
    OPEN c_chk_orig_source_csr; FETCH c_chk_orig_source_csr INTO cv_chk_orig_source;
    CLOSE c_chk_orig_source_csr;

    lv_sixv_rec.source_type_code := G_TRX_SOURCE_TYPE_CODE;

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'lv_sixv_rec.source_object_id '||lv_sixv_rec.source_object_id || ' lv_sixv_rec.subsidy_id '||lv_sixv_rec.subsidy_id ||
                              ' lv_sixv_rec.subsidy_pool_id '||lv_sixv_rec.subsidy_pool_id ||' lv_sixv_rec.dnz_asset_number '||lv_sixv_rec.dnz_asset_number||
                              ' lv_sixv_rec.source_trx_date '||lv_sixv_rec.source_trx_date ||' lv_sixv_rec.trx_amount '||lv_sixv_rec.trx_amount||
                              ' lv_sixv_rec.vendor_id '||lv_sixv_rec.vendor_id||' lv_sixv_rec.source_type_code '||lv_sixv_rec.source_type_code
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on


    -- now switch based on the orig_system_source_code
-- 09/09/2005 cklee:comment out  IF(cv_chk_orig_source.orig_system_source_code = G_ORIG_CODE_QUOTE)THEN
    IF(cv_chk_orig_source.orig_system_source_code IN (G_ORIG_CODE_QUOTE, G_ORIG_CODE_LEASE_APP))THEN
      -- the contract has been originated from a Sales Quote. here we need to add back the subsidy amount from
      -- Sales Quote (if not earlier added back) and reduce the subsidy amount on the Contract from the Pool. datamodel is not
      -- yet ready. work in progress code

-- START 09/09/2005 cklee: integration with Quote/Lease App API
      OKL_LEASE_QUOTE_SUBPOOL_PVT.process_active_contract (p_api_version         => p_api_version
                                                          ,p_init_msg_list       => p_init_msg_list
                                                          ,x_return_status       => x_return_status
                                                          ,x_msg_count           => x_msg_count
                                                          ,x_msg_data            => x_msg_data
                                                          ,p_transaction_control => FND_API.G_TRUE
                                                          ,p_contract_id         => p_chr_id
                                                          );
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'OKL_LEASE_QUOTE_SUBPOOL_PVT.process_active_contract with status '||x_return_status||' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
-- END 09/09/2005 cklee

-- start: cklee 07/12/2005
-- 09/09/2005 cklee:comment out      ELSIF(cv_chk_orig_source.orig_system_source_code = G_ORIG_CODE_LEASE_APP)THEN
      -- contract has been originated from Lease Application. here we need to add back the subsidy amount on
      -- the Lease Application (if not earlier added back) and reduce the subsidy amount on the Contract from the Pool. datamodel is not
      -- yet ready. work in progress code
--      NULL;
--    ELSIF(cv_chk_orig_source.orig_system_source_code = 'OKC_HDR')THEN
--  This column may be null if user create contract from scrach. This column could be OKL_IMPORT, however,
--  this is an internal API called from OKL booking procesdure, no further validations needed at this point. cklee
--    ELSE
-- end: cklee 07/12/2005

    lv_sixv_rec.trx_type_code := 'REDUCTION';
    lv_sixv_rec.trx_reason_code := G_CONTRACT_BOOK_CODE;
    OKL_SUBSIDY_POOL_TRX_PVT.create_pool_transaction(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_sixv_rec      => lv_sixv_rec
                                                    ,x_sixv_rec      => lx_sixv_rec
                                                    );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'OKL_SUBSIDY_POOL_TRX_PVT.create_pool_transaction with status '||x_return_status||' x_msg_data '||x_msg_data
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- start: cklee 07/12/2005
/*    ELSIF(cv_chk_orig_source.orig_system_source_code = 'LEASE_APPLICATION')THEN
      -- contract has been originated from Lease Application. here we need to add back the subsidy amount on
      -- the Lease Application (if not earlier added back) and reduce the subsidy amount on the Contract from the Pool. datamodel is not
      -- yet ready. work in progress code
      NULL;
*/
-- 09/09/2005 cklee:comment out      END IF;
-- end: cklee 07/12/2005

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIUB.pls call create_pool_trx_khr_book');
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
  END create_pool_trx_khr_book;

  PROCEDURE create_pool_trx_khr_reverse(p_api_version   IN NUMBER
                                       ,p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                       ,p_reversal_date IN DATE
                                       ,p_override_trx_reason IN okl_trx_subsidy_pools.trx_reason_code%TYPE
                                     ) IS

    -- cursor to fetch all subsidies attached in the contract
    CURSOR c_subsidy_csr(cp_chr_id IN okc_k_headers_b.id%TYPE) IS
    SELECT clet_sub.name                       subsidy_name,
           clet_asst.name                      asset_number,
           subb.id                             subsidy_id
      FROM okl_subsidies_b   subb,
           okl_k_lines       kle_sub,
           okc_k_lines_tl    clet_sub,
           okc_k_lines_b     cleb_sub,
           okc_line_styles_b lseb_sub,
           okc_k_lines_tl    clet_asst,
           okc_k_lines_b     cleb_asst,
           okc_line_styles_b lseb_asst
     WHERE subb.id              = kle_sub.subsidy_id
       AND kle_sub.id           = cleb_sub.id
       AND clet_sub.id          = cleb_sub.id
       AND clet_sub.language    = userenv('LANG')
       AND cleb_sub.cle_id      = cleb_asst.id
       AND cleb_sub.dnz_chr_id  = cleb_asst.dnz_chr_id
       AND cleb_sub.sts_code   <> 'ABANDONED'
       AND lseb_sub.id          = cleb_sub.lse_id
       AND lseb_sub.lty_code    = 'SUBSIDY'
       AND clet_asst.id         = cleb_asst.id
       AND clet_asst.language   = userenv('LANG')
       AND cleb_asst.chr_id     = cp_chr_id
       AND cleb_asst.dnz_chr_id = cp_chr_id
       AND lseb_asst.id         = cleb_asst.lse_id
       AND lseb_asst.lty_code   = 'FREE_FORM1'
       AND cleb_asst.sts_code   <> 'ABANDONED';

    -- cursor to fetch the pool transaction records with REDUCTION operation, created when the contract was booked
    CURSOR c_sub_pool_trx_csr (cp_chr_id IN okc_k_headers_b.id%TYPE
                              ,cp_asset_number IN okc_k_lines_tl.name%TYPE
                              ,cp_subsidy_id IN okl_subsidies_b.id%TYPE
                              ,cp_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                              ) IS
    SELECT source_type_code
          ,source_object_id
          ,subsidy_pool_id
          ,dnz_asset_number
          ,vendor_id
          ,source_trx_date
          ,trx_date
          ,subsidy_id
          ,trx_reason_code
          ,trx_currency_code
          ,trx_amount
          ,subsidy_pool_currency_code
          ,subsidy_pool_amount
          ,conversion_rate
      FROM okl_trx_subsidy_pools
     WHERE source_object_id = cp_chr_id
       AND dnz_asset_number = cp_asset_number
       AND subsidy_id = cp_subsidy_id
       AND subsidy_pool_id = cp_subsidy_pool_id
       AND source_type_code = G_TRX_SOURCE_TYPE_CODE
       AND trx_type_code = G_REDUCTION_TYPE_CODE;
    cv_sub_pool_trx_rec c_sub_pool_trx_csr%ROWTYPE;

     lx_sub_pool_id okl_subsidy_pools_b.id%TYPE;
     lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
     lv_sixv_tbl sixv_tbl_type;
     lx_sixv_tbl sixv_tbl_type;
     idx PLS_INTEGER;
     l_sub_pool_applicable VARCHAR2(10);
     l_api_name CONSTANT VARCHAR2(30) DEFAULT 'POOL_TRX_KHR_REVERSE';

     l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_AUTH_TRX_PVT.CREATE_POOL_TRX_KHR_REVERSE';
     l_debug_enabled VARCHAR2(10);
     is_debug_procedure_on BOOLEAN;
     is_debug_statement_on BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIUB.pls call create_pool_trx_khr_reverse');
    END IF;

    -- Call start_activity to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    idx := 0; lv_sixv_tbl.DELETE; lx_sixv_tbl.DELETE;
    -- loop for all subsidies and process for subsidy pool transaction reversal
    FOR c_subsidy_csr_rec IN c_subsidy_csr(cp_chr_id => p_chr_id) LOOP
      -- check if the subsidy is associated with a subsidy pool
      -- initialize for every iteration
      l_sub_pool_applicable := 'N';
      -- check if the subisdy is associated with a subsidy pool, process further only if subsidy pool exists.
      l_sub_pool_applicable := okl_asset_subsidy_pvt.is_sub_assoc_with_pool(p_subsidy_id => c_subsidy_csr_rec.subsidy_id
                                                                           ,x_subsidy_pool_id => lx_sub_pool_id
                                                                           ,x_sub_pool_curr_code => lx_sub_pool_curr_code
                                                                           );

      IF(l_sub_pool_applicable = 'Y')THEN
        -- now that the pool is applicable, verify if there exists a pool transaction for the contract, asset, subsidy, subsidy_pool,
        -- and trx_type_code of REDUCTION. this record should be present for reversal. if the record is not found then we need to
        -- raise an error. this is because the transaction reversal cannot be done until the transaction was not created in the first instance
        -- there can never be the case that a subsidy pool is applicable to a subsidy and there are no REDUCTION type transactions
        -- for that subsidy in the okl_trx_subsidy_pools table
        OPEN c_sub_pool_trx_csr(cp_chr_id => p_chr_id
                               ,cp_asset_number => c_subsidy_csr_rec.asset_number
                               ,cp_subsidy_id => c_subsidy_csr_rec.subsidy_id
                               ,cp_subsidy_pool_id => lx_sub_pool_id
                               );
        FETCH c_sub_pool_trx_csr INTO cv_sub_pool_trx_rec;
        IF(c_sub_pool_trx_csr%NOTFOUND)THEN
          CLOSE c_sub_pool_trx_csr;
          x_return_status := OKL_API.G_RET_STS_ERROR;
           OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_NO_SUB_POOL_TRX_FOUND,
                               p_token1       => 'SUBSIDY',
                               p_token1_value => c_subsidy_csr_rec.subsidy_name,
                               p_token2       => 'ASSET_NUMBER',
                               p_token2_value => c_subsidy_csr_rec.asset_number);
        ELSE
          -- increment the index
          idx := idx + 1;
          -- since we are adding back to pool balance, the trx_type_code is ADDITION
          lv_sixv_tbl(idx).trx_type_code := G_ADDITION_TYPE_CODE;
          lv_sixv_tbl(idx).source_type_code := cv_sub_pool_trx_rec.source_type_code;
          lv_sixv_tbl(idx).source_object_id := cv_sub_pool_trx_rec.source_object_id;
          lv_sixv_tbl(idx).subsidy_pool_id := cv_sub_pool_trx_rec.subsidy_pool_id;
          lv_sixv_tbl(idx).dnz_asset_number := cv_sub_pool_trx_rec.dnz_asset_number;
          lv_sixv_tbl(idx).vendor_id := cv_sub_pool_trx_rec.vendor_id;
          lv_sixv_tbl(idx).source_trx_date := p_reversal_date;
          lv_sixv_tbl(idx).subsidy_id := cv_sub_pool_trx_rec.subsidy_id;
          -- note that the default trx_reason_code is that of G_CONTRACT_REVERSAL_CODE
          -- but this api can also be called from split contract, in which case the p_override_trx_reason is substitued for the
          -- transaction reason code
          lv_sixv_tbl(idx).trx_reason_code := NVL(p_override_trx_reason, G_CONTRACT_REVERSAL_CODE);
          lv_sixv_tbl(idx).trx_currency_code := cv_sub_pool_trx_rec.trx_currency_code;
          -- the transaction amount is that amount that was initially reduced.
          lv_sixv_tbl(idx).trx_amount := cv_sub_pool_trx_rec.trx_amount;
          lv_sixv_tbl(idx).subsidy_pool_currency_code := cv_sub_pool_trx_rec.subsidy_pool_currency_code;
          -- the subsidy pool amount is that amount that was initially reduced. this is not recalculated for ADDITION operation
          -- as the conversion rate factor might result into a different amount the differential becomes then unexplained
          lv_sixv_tbl(idx).subsidy_pool_amount := cv_sub_pool_trx_rec.subsidy_pool_amount;
          lv_sixv_tbl(idx).conversion_rate := cv_sub_pool_trx_rec.conversion_rate;

          -- write to log
          IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    idx ||' record processed for '||lv_sixv_tbl(idx).trx_type_code||' lv_sixv_tbl(idx).trx_reason_code '||lv_sixv_tbl(idx).trx_reason_code
                                    );
          END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
          CLOSE c_sub_pool_trx_csr;
        END IF; -- end of c_sub_pool_trx_csr%NOTFOUND
      ELSE
        -- case of subsidy is a stand alone subsidy
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'c_subsidy_csr_rec.subsidy_id '||c_subsidy_csr_rec.subsidy_id||' l_sub_pool_applicable '||l_sub_pool_applicable
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
      END IF; -- end of l_sub_pool_applicable = 'Y'
    END LOOP; -- end of for c_subsidy_csr_rec IN c_subsidy_csr(cp_chr_id => p_chr_id) loop

    -- now check the length of the table lv_sixv_tbl and then call the okl_subsidy_pool_trx_pvt api to create ADDITION transactions
    IF(lv_sixv_tbl.COUNT > 0)THEN
      okl_subsidy_pool_trx_pvt.create_pool_transaction(p_api_version => p_api_version
                                                      ,p_init_msg_list => OKL_API.G_TRUE
                                                      ,x_return_status => x_return_status
                                                      ,x_msg_count    => x_msg_count
                                                      ,x_msg_data     => x_msg_data
                                                      ,p_sixv_tbl     => lv_sixv_tbl
                                                      ,x_sixv_tbl     => lx_sixv_tbl
                                                     );
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'okl_subsidy_pool_trx_pvt.create_pool_transaction with status '||x_return_status || ' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIUB.pls call create_pool_trx_khr_reverse');
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);

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

  END create_pool_trx_khr_reverse;

  PROCEDURE create_pool_trx_khr_rbk(p_api_version IN NUMBER
                                   ,p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER
                                   ,x_msg_data      OUT NOCOPY VARCHAR2
                                   ,p_rbk_chr_id    IN okc_k_headers_b.id%TYPE
                                   ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                   ) IS

    ---------------------------------------------------------------------------
    --get subsidy elements from rebook copy contract
    ---------------------------------------------------------------------------
    CURSOR l_subelm_rbk_csr(p_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT kle.SUBSIDY_ID
           ,clet.NAME
           ,clet.ITEM_DESCRIPTION
           ,kle.AMOUNT
           ,kle.SUBSIDY_OVERRIDE_AMOUNT
           ,cleb.orig_system_id1
           ,cplb.object1_id1  vendor_id
           ,cplb.id           cpl_id
           ,kle.sty_id        sty_id
           ,cleb.cle_id       asset_id
           ,cleb.currency_code
      FROM okl_k_lines          kle
           ,okc_k_lines_tl       clet
           ,okc_k_lines_b        cleb
           ,okc_statuses_b       stsb
           ,okc_line_styles_b    lseb
           ,okc_k_party_roles_b  cplb
     WHERE kle.id          = cleb.id
       AND clet.id         = cleb.id
       AND clet.language   = userenv('LANG')
       AND cleb.dnz_chr_id = p_chr_id
       AND cleb.orig_system_id1 is not null
       AND stsb.code       = cleb.sts_code
       AND stsb.ste_code   not in ('CANCELLED')
       AND lseb.id         =  cleb.lse_id
       AND lseb.lty_code   =  'SUBSIDY'
       AND cplb.cle_id     = cleb.id
       AND cplb.rle_code   = 'OKL_VENDOR'
       AND cplb.dnz_chr_id = p_chr_id;
    l_subelm_rbk_rec l_subelm_rbk_csr%ROWTYPE;

    ---------------------------------------------------------------------------
    --get subsidy elements from original contract
    ---------------------------------------------------------------------------
    cursor l_subelm_orig_csr(p_cle_id in number,
                             p_chr_id okc_k_headers_b.id%TYPE) is
     SELECT kle.SUBSIDY_ID
           ,clet.NAME
           ,clet.ITEM_DESCRIPTION
           ,kle.AMOUNT
           ,kle.SUBSIDY_OVERRIDE_AMOUNT
           ,cplb.object1_id1  vendor_id
           ,cplb.id           cpl_id
           ,kle.sty_id        sty_id
           ,cleb.cle_id       asset_id
           ,cleb.currency_code
      FROM okl_k_lines          kle
           ,okc_k_lines_tl       clet
           ,okc_k_lines_b        cleb
           ,okc_statuses_b       stsb
           ,okc_line_styles_b    lseb
           ,okc_k_party_roles_b  cplb
     WHERE kle.id          = cleb.id
       AND clet.id         = cleb.id
       AND clet.language   = userenv('LANG')
       AND cleb.id         = p_cle_id
       AND cleb.dnz_chr_id = p_chr_id
       AND stsb.code       = cleb.sts_code
       AND stsb.ste_code   not in ('CANCELLED')
       AND lseb.id         =  cleb.lse_id
       AND lseb.lty_code   =  'SUBSIDY'
       AND cplb.cle_id     = cleb.id
       AND cplb.rle_code   = 'OKL_VENDOR'
       AND cplb.dnz_chr_id = p_chr_id;
    l_subelm_orig_rec l_subelm_orig_csr%ROWTYPE;

    ------------------------------------------------------------------------------
    --cursor to find out subsidy line which has been deleted
    ------------------------------------------------------------------------------
    cursor l_del_sub_csr (p_orig_chr_id okc_k_headers_b.id%TYPE,
                          p_rbk_chr_id  okc_k_headers_b.id%TYPE) is
    SELECT cleb.id  subsidy_id
           ,cplb.id  cpl_id
           ,cplb.object1_id1 vendor_id
           ,kle.AMOUNT
           ,kle.SUBSIDY_OVERRIDE_AMOUNT
           ,cleb.cle_id  asset_id
           ,cleb.currency_code
           ,kle.subsidy_id subsidy
      FROM okc_k_lines_b        cleb
           ,okc_line_styles_b    lseb
           ,okc_k_party_roles_b  cplb
           ,okl_k_lines kle
     WHERE cleb.dnz_chr_id = p_orig_chr_id
       AND lseb.id         =  cleb.lse_id
       AND lseb.lty_code   =  'SUBSIDY'
       AND cplb.cle_id     = cleb.id
       AND cplb.dnz_chr_id = p_orig_chr_id
       AND cplb.rle_code   = 'OKL_VENDOR'
       AND kle.id          = cleb.id
    --line was deleted from rebook copy :
      AND NOT EXISTS (SELECT '1'
                        FROM okc_k_lines_b cleb2
                       WHERE cleb2.orig_system_id1 = cleb.id
                         AND cleb2.dnz_chr_id       = p_rbk_chr_id)
    --line is not a new line created during this rebook
      AND NOT EXISTS (SELECT '1'
                        FROM okc_k_lines_b cleb3
                       WHERE cleb3.id   = cleb.orig_system_id1
                         AND cleb3.dnz_chr_id = p_rbk_chr_id);
    lv_rec_del_sub_csr l_del_sub_csr%ROWTYPE;

    ------------------------------------------------------------------------------
    --cursor to find out new subsidy lines which have been added
    ------------------------------------------------------------------------------
    CURSOR l_new_sub_csr (p_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT kle.subsidy_id              subsidy_id
           ,cleb.id                     subsidy_cle_id
           ,clet.name                   name
           ,kle.amount                  amount
           ,kle.subsidy_override_amount subsidy_override_amount
           ,cleb.dnz_chr_id             dnz_chr_id
           ,cleb.cle_id                 asset_cle_id
           ,cplb.id                     cpl_id
           ,cplb.object1_id1            vendor_id
           ,cleb.lse_id                 lse_id
           ,cleb.start_date             start_date
           ,cleb.end_date               end_date
           ,cleb.currency_code          currency_code
           ,cleb.sts_code               sts_code
           ,kle.sty_id                  sty_id
           ,asst_cleb.orig_system_id1   orig_asst_cle_id
      FROM okc_k_lines_b              asst_cleb
           ,okc_statuses_b             asst_sts
           ,okc_k_party_roles_b        cplb
           ,okc_k_lines_tl             clet
           ,okl_k_lines                kle
           ,okc_line_styles_b          lseb
           ,okc_k_lines_b              cleb
     WHERE asst_cleb.id              =   cleb.cle_id
       AND asst_cleb.dnz_chr_id      =   cleb.dnz_chr_id
       AND asst_sts.code             =   asst_cleb.sts_code
       AND asst_sts.ste_code         not in ('HOLD','EXPIRED','TERMINATED','CANCELLED')
       AND cplb.jtot_object1_code    =   'OKX_VENDOR'
       AND cplb.dnz_chr_id           =   cleb.dnz_chr_id
       AND cplb.cle_id               =   cleb.id
       AND cplb.rle_code             =   'OKL_VENDOR'
       AND clet.id                   =   cleb.id
       AND clet.language             =   userenv('LANG')
       AND kle.id                    =   cleb.id
       AND lseb.id                   =   cleb.lse_id
       AND lseb.lty_code             =   'SUBSIDY'
       AND cleb.dnz_chr_id           =   p_chr_id
       AND cleb.orig_system_id1  is null
       AND asst_cleb.orig_system_id1 is not null
       AND cleb.sts_code <> 'ABANDONED';
    l_new_sub_rec     l_new_sub_csr%ROWTYPE;

    -- cursor to get the asset number for pool transaction record
    -- added for subsidy pools enhancement
    CURSOR c_get_asst_number (cp_asset_id okc_k_lines_b.id%TYPE)IS
    SELECT name asset_number
      FROM okc_k_lines_v
     WHERE id = cp_asset_id;
    lv_asset_number okc_k_lines_v.name%TYPE;

    CURSOR c_get_orig_asst (cp_asset_id okc_k_lines_b.id%TYPE) IS
    SELECT orig_system_id1
      FROM okc_k_lines_b
     WHERE id = cp_asset_id;
    cv_get_orig_asst c_get_orig_asst%ROWTYPE;

    lv_orig_subsidy_applic VARCHAR2(10);
    lv_rbk_subsidy_applic VARCHAR2(10);
    lx_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
    lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
    -- sjalasut, added variables for subsidy pools enhancement. END

    CURSOR l_chk_rbk_csr IS
    SELECT ktrx.date_transaction_occurred
      FROM okc_k_headers_b chr
           ,okl_trx_contracts ktrx
     WHERE ktrx.khr_id_new = chr.id
       AND ktrx.tsu_code = 'ENTERED'
       AND ktrx.rbr_code IS NOT NULL
       AND ktrx.tcn_type = 'TRBK'
--rkuttiya added for 12.1.1 Multi GAAP
       AND ktrx.representation_type = 'PRIMARY'
--
       AND CHR.id = p_rbk_chr_id
       AND CHR.ORIG_SYSTEM_SOURCE_CODE = 'OKL_REBOOK';

    lv_source_trx_date okl_trx_subsidy_pools.source_trx_date%TYPE;
    -- counter to manage all pool transaction rows.
    idx PLS_INTEGER;

    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'POOL_TRX_KHR_RBK';
    lv_six_tbl sixv_tbl_type;
    lx_six_tbl sixv_tbl_type;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_AUTH_TRX_PVT.CREATE_POOL_TRX_KHR_RBK';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIUB.pls call create_pool_trx_khr_rbk');
    END IF;

    -- Call start_activity to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,p_init_msg_list,'_PVT',x_return_status);
    -- Check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF(x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    -- initialize the counter. this is done only once for the complete pool transaction synchronization
    idx := 0;
    -- initialize the plsql table
    lv_six_tbl.DELETE; lx_six_tbl.DELETE;
    -- start of processing. first compare the lines that have changed between the original contract and rebook copy
    OPEN l_subelm_rbk_csr(p_chr_id => p_rbk_chr_id);
    LOOP
      FETCH l_subelm_rbk_csr INTO l_subelm_rbk_rec;
      EXIT WHEN l_subelm_rbk_csr%NOTFOUND;

      --2. Fetch subsidy line attributes for original contract
      OPEN l_subelm_orig_csr(p_cle_id => l_subelm_rbk_rec.orig_system_id1,p_chr_id => p_orig_chr_id);
      FETCH l_subelm_orig_csr INTO l_subelm_orig_rec;
      IF l_subelm_orig_csr%NOTFOUND THEN
        NULL;
      ELSE
        --3. syncronize subsidy line attributes in case of differences
        IF(NVL(l_subelm_orig_rec.amount,0)                  <>  NVL(l_subelm_rbk_rec.Amount,0)) OR
          (NVL(l_subelm_orig_rec.subsidy_override_amount,0) <>  NVL(l_subelm_rbk_rec.subsidy_override_Amount,0)) OR
          (l_subelm_orig_rec.subsidy_id                     <>  l_subelm_rbk_rec.subsidy_id) OR
          (l_subelm_orig_rec.sty_id                         <>  l_subelm_rbk_rec.sty_id) THEN

          lv_orig_subsidy_applic := 'N';
          lv_orig_subsidy_applic := okl_asset_subsidy_pvt.is_sub_assoc_with_pool(p_subsidy_id => l_subelm_orig_rec.subsidy_id
                                                                                ,x_subsidy_pool_id => lx_subsidy_pool_id
                                                                                ,x_sub_pool_curr_code => lx_sub_pool_curr_code);
          IF(lv_orig_subsidy_applic = 'Y')THEN
            idx := idx + 1;
            lv_six_tbl(idx).trx_type_code := G_ADDITION_TYPE_CODE;
            lv_six_tbl(idx).source_object_id := p_orig_chr_id; -- this will always be p_orig_chr_id for a rebook case
            lv_six_tbl(idx).subsidy_pool_id := lx_subsidy_pool_id;
            lv_six_tbl(idx).vendor_id := l_subelm_orig_rec.vendor_id;
            lv_six_tbl(idx).subsidy_id := l_subelm_orig_rec.subsidy_id;
            lv_six_tbl(idx).trx_amount := NVL(l_subelm_orig_rec.subsidy_override_amount,NVL(l_subelm_orig_rec.amount,0));
            lv_six_tbl(idx).trx_currency_code := l_subelm_orig_rec.currency_code;
            lv_six_tbl(idx).subsidy_pool_currency_code := lx_sub_pool_curr_code;
            -- since this is the original contract, the asset line is the line we are interested to get asset_number from
            lv_asset_number := NULL;
            OPEN c_get_asst_number(l_subelm_orig_rec.asset_id); FETCH c_get_asst_number INTO lv_asset_number;
            CLOSE c_get_asst_number;
            lv_six_tbl(idx).dnz_asset_number := lv_asset_number;
            -- write to log
            IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                      l_module,
                                      'synch ADD lv_six_tbl('||idx||').source_object_id'||lv_six_tbl(idx).source_object_id||
                                      ' subsidy_pool_id '||lx_subsidy_pool_id||' vendor_id '||lv_six_tbl(idx).vendor_id||
                                      ' subsidy_id '||l_subelm_orig_rec.subsidy_id||' trx_amount '||lv_six_tbl(idx).trx_amount||
                                      ' dnz_asset_number '||lv_six_tbl(idx).dnz_asset_number
                                      );
            END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
          END IF;

          lx_subsidy_pool_id := NULL;
          lx_sub_pool_curr_code := NULL;
          -- check to see if the subsidy on the rebook contract is associated with a subsidy pool, and if so then reduce the pool balance
          lv_rbk_subsidy_applic := 'N';
          lv_rbk_subsidy_applic := okl_asset_subsidy_pvt.is_sub_assoc_with_pool(p_subsidy_id => l_subelm_rbk_rec.subsidy_id
                                                                               ,x_subsidy_pool_id => lx_subsidy_pool_id
                                                                               ,x_sub_pool_curr_code => lx_sub_pool_curr_code);
          IF(lv_rbk_subsidy_applic = 'Y')THEN
            idx := idx + 1;
            lv_six_tbl(idx).trx_type_code := G_REDUCTION_TYPE_CODE;
            lv_six_tbl(idx).source_object_id := p_orig_chr_id; -- this will always be p_orig_chr_id for a rebook case
            lv_six_tbl(idx).subsidy_pool_id := lx_subsidy_pool_id;
            lv_six_tbl(idx).vendor_id := l_subelm_rbk_rec.vendor_id;
            lv_six_tbl(idx).subsidy_id := l_subelm_rbk_rec.subsidy_id;
            lv_six_tbl(idx).trx_amount := NVL(l_subelm_rbk_rec.subsidy_override_Amount,NVL(l_subelm_rbk_rec.Amount,0));
            lv_six_tbl(idx).trx_currency_code := l_subelm_rbk_rec.currency_code;
            lv_six_tbl(idx).subsidy_pool_currency_code := lx_sub_pool_curr_code;
            -- fetch the original asset number from the new asset line on the rebook copy
            OPEN c_get_orig_asst (l_subelm_rbk_rec.asset_id); FETCH c_get_orig_asst INTO cv_get_orig_asst;
            CLOSE c_get_orig_asst;
            lv_asset_number := NULL;
            OPEN c_get_asst_number(cv_get_orig_asst.orig_system_id1); FETCH c_get_asst_number INTO lv_asset_number;
            CLOSE c_get_asst_number;
            lv_six_tbl(idx).dnz_asset_number := lv_asset_number;
            -- write to log
            IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
              okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                      l_module,
                                      'synch REDUCE lv_six_tbl('||idx||').source_object_id'||lv_six_tbl(idx).source_object_id||
                                      ' subsidy_pool_id '||lx_subsidy_pool_id||' vendor_id '||lv_six_tbl(idx).vendor_id||
                                      ' subsidy_id '||lv_six_tbl(idx).subsidy_id||' trx_amount '||lv_six_tbl(idx).trx_amount||
                                      ' dnz_asset_number '||lv_six_tbl(idx).dnz_asset_number
                                      );
            END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
          END IF; -- end of lv_rbk_subsidy_applic = 'Y'
        END IF; -- end of amount comparision
      END IF; -- end of l_subelm_orig_csr%NOTFOUND
      CLOSE L_subelm_orig_csr;
    END LOOP;
    CLOSE l_subelm_rbk_csr;

    -- process subsidy pool transactions whose subsidy lines have been deleted during rebook
    FOR lv_rec_del_sub_csr IN l_del_sub_csr (p_orig_chr_id => p_orig_chr_id, p_rbk_chr_id  => p_rbk_chr_id) LOOP
      lx_subsidy_pool_id := NULL;
      lx_sub_pool_curr_code := NULL;
      lv_rbk_subsidy_applic := 'N';
      lv_rbk_subsidy_applic := okl_asset_subsidy_pvt.is_sub_assoc_with_pool(p_subsidy_id => lv_rec_del_sub_csr.subsidy
                                                                           ,x_subsidy_pool_id => lx_subsidy_pool_id
                                                                           ,x_sub_pool_curr_code => lx_sub_pool_curr_code);
      IF(lv_rbk_subsidy_applic = 'Y')THEN
        idx := idx + 1;
        lv_six_tbl(idx).trx_type_code := G_ADDITION_TYPE_CODE;
        lv_six_tbl(idx).source_object_id := p_orig_chr_id; -- this will always be p_orig_chr_id for a rebook case
        lv_six_tbl(idx).subsidy_pool_id := lx_subsidy_pool_id;
        lv_six_tbl(idx).vendor_id := lv_rec_del_sub_csr.vendor_id;
        lv_six_tbl(idx).subsidy_id := lv_rec_del_sub_csr.subsidy;
        lv_six_tbl(idx).trx_amount := NVL(lv_rec_del_sub_csr.subsidy_override_amount,NVL(lv_rec_del_sub_csr.amount,0));
        lv_six_tbl(idx).trx_currency_code := lv_rec_del_sub_csr.currency_code;
        lv_six_tbl(idx).subsidy_pool_currency_code := lx_sub_pool_curr_code;
        lv_asset_number := NULL;
        OPEN c_get_asst_number(lv_rec_del_sub_csr.asset_id); FETCH c_get_asst_number INTO lv_asset_number;
        CLOSE c_get_asst_number;
        lv_six_tbl(idx).dnz_asset_number := lv_asset_number;

        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'synch ADD for deleted subsidy lv_six_tbl('||idx||').source_object_id'||lv_six_tbl(idx).source_object_id||
                                  ' subsidy_pool_id '||lx_subsidy_pool_id||' vendor_id '||lv_six_tbl(idx).vendor_id||
                                  ' subsidy_id '||lv_six_tbl(idx).subsidy_id||' trx_amount '||lv_six_tbl(idx).trx_amount||
                                  ' dnz_asset_number '||lv_six_tbl(idx).dnz_asset_number
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
      END IF; -- end of lv_rbk_subsidy_applic = 'Y'
    END LOOP;

    -- process for subsidy pool transactions for new subsidy lines that have been added on the rebook copy
    FOR l_new_sub_rec IN l_new_sub_csr (p_chr_id => p_rbk_chr_id)
    LOOP
      lx_subsidy_pool_id := NULL;
      lx_sub_pool_curr_code := NULL;
      -- check to see if the subsidy on the rebook contract is associated with a subsidy pool, and if so
      -- then reduce the pool balance
      lv_rbk_subsidy_applic := 'N';
      lv_rbk_subsidy_applic := okl_asset_subsidy_pvt.is_sub_assoc_with_pool(p_subsidy_id => l_subelm_rbk_rec.subsidy_id
                                                                           ,x_subsidy_pool_id => lx_subsidy_pool_id
                                                                           ,x_sub_pool_curr_code => lx_sub_pool_curr_code);
      IF(lv_rbk_subsidy_applic = 'Y')THEN
        idx := idx + 1;
        lv_six_tbl(idx).trx_type_code := G_REDUCTION_TYPE_CODE;
        lv_six_tbl(idx).source_object_id := p_orig_chr_id; -- this will always be p_orig_chr_id for a rebook case
        lv_six_tbl(idx).subsidy_pool_id := lx_subsidy_pool_id;
        lv_six_tbl(idx).vendor_id := l_new_sub_rec.vendor_id;
        lv_six_tbl(idx).subsidy_id := l_new_sub_rec.subsidy_id;
        lv_six_tbl(idx).trx_amount := NVL(l_new_sub_rec.subsidy_override_Amount,NVL(l_new_sub_rec.Amount,0));
        lv_six_tbl(idx).trx_currency_code := l_new_sub_rec.currency_code;
        lv_six_tbl(idx).subsidy_pool_currency_code := lx_sub_pool_curr_code;
        lv_asset_number := NULL;
        OPEN c_get_asst_number(l_new_sub_rec.asset_cle_id); FETCH c_get_asst_number INTO lv_asset_number;
        CLOSE c_get_asst_number;
        lv_six_tbl(idx).dnz_asset_number := lv_asset_number;

        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                  l_module,
                                  'synch REDUCE for new subsidy lv_six_tbl('||idx||').source_object_id'||lv_six_tbl(idx).source_object_id||
                                  ' subsidy_pool_id '||lx_subsidy_pool_id||' vendor_id '||lv_six_tbl(idx).vendor_id||
                                  ' subsidy_id '||lv_six_tbl(idx).subsidy_id||' trx_amount '||lv_six_tbl(idx).trx_amount||
                                  ' dnz_asset_number '||lv_six_tbl(idx).dnz_asset_number
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
      END IF; -- end of lv_rbk_subsidy_applic = 'Y'
    END LOOP;

    IF(idx > 0) THEN
      -- derive the source transaction date
      lv_source_trx_date := NULL;
      OPEN l_chk_rbk_csr; FETCH l_chk_rbk_csr INTO lv_source_trx_date;
      CLOSE l_chk_rbk_csr;
      -- call local procedure that populates other parameters and then calls the okl_subsidy_pool_trx_pvt.create_pool_transaction
      pool_trx_khr_rbk(p_source_trx_date => lv_source_trx_date, p_six_tbl => lv_six_tbl, x_return_status => x_return_status);
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                l_module,
                                'pool_trx_khr_rbk returned with status '||x_return_status || ' x_msg_data '||x_msg_data
                                );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF(x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIUB.pls call create_pool_trx_khr_rbk');
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);
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

  END create_pool_trx_khr_rbk;

  PROCEDURE create_pool_trx_khr_split(p_api_version   IN NUMBER
                                   ,p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER
                                   ,x_msg_data      OUT NOCOPY VARCHAR2
                                   ,p_new1_chr_id    IN okc_k_headers_b.id%TYPE
                                   ,p_new2_chr_id   IN okc_k_headers_b.id%TYPE
                                   ) IS

    CURSOR c_get_orig_khr_csr(cp_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT orig_system_id1
      FROM okc_k_headers_b
     WHERE id = cp_chr_id
       AND orig_system_source_code = 'OKL_SPLIT';
    lv_orig_khr_id okc_k_headers_b.id%TYPE;

    CURSOR c_split_info_csr(cp_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT khr.id, khr.contract_number, khr.start_date, trx.date_transaction_occurred
      FROM okc_k_headers_b khr
           ,okl_trx_contracts trx
     WHERE trx.khr_id = khr.id
       AND trx.tsu_code = 'PROCESSED'
       AND trx.tcn_type = 'SPLC'
--rkuttiya added for 12.1.1 Multi GAAP
       AND trx.representation_type = 'PRIMARY'
--
       AND khr.id = cp_chr_id;
     cv_split_info_rec c_split_info_csr%ROWTYPE;

    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'POOL_TRX_KHR_SPLIT';

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_AUTH_TRX_PVT.CREATE_POOL_TRX_KHR_SPLIT';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIUB.pls call create_pool_trx_khr_split');
    END IF;

    -- Call start_activity to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,p_init_msg_list,'_PVT',x_return_status);
    -- Check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF(x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    -- derive the original contract information from the first split contract
    lv_orig_khr_id := NULL;
    OPEN c_get_orig_khr_csr(cp_chr_id => p_new1_chr_id); FETCH c_get_orig_khr_csr INTO lv_orig_khr_id;
    CLOSE c_get_orig_khr_csr;

    -- derive the split contract date from the contract id
    OPEN c_split_info_csr(cp_chr_id => lv_orig_khr_id); FETCH c_split_info_csr INTO cv_split_info_rec;
    CLOSE c_split_info_csr;

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'first split copy khr '||lv_orig_khr_id||' cv_split_info_rec.contract_number '||
                              cv_split_info_rec.contract_number||' cv_split_info_rec.date_transaction_occurred '||
                              cv_split_info_rec.date_transaction_occurred
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

    -- for this original contract, all the subsidy pool transactions should be reversed.
    -- in pool terms, the pool balances should be added back. only those amounts are added back, whose subsidy lines
    -- are attached with a subsidy pool
    -- call the create_pool_trx_khr_reverse api as the logic is similar, pass the split contract date, contract id
    -- and the p_override_trx_reason
    create_pool_trx_khr_reverse(p_api_version => p_api_version
                               ,p_init_msg_list    => p_init_msg_list
                               ,x_return_status    => x_return_status
                               ,x_msg_count        => x_msg_count
                               ,x_msg_data         => x_msg_data
                               ,p_chr_id           => lv_orig_khr_id
                               ,p_reversal_date    => cv_split_info_rec.date_transaction_occurred
                               ,p_override_trx_reason => G_CONTRACT_SPLIT_CODE
                               );
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'create_pool_trx_khr_reverse called from create_pool_trx_khr_split return status '||x_return_status || ' x_msg_data '||x_msg_data
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF(x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'now reducing pool balance from the first split copy contract '||p_new1_chr_id||' '||trunc(cv_split_info_rec.date_transaction_occurred)
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

    -- now process the first split contract. reduce from the pool balance for all the subsidy lines which are associated with a subsidy pool
    -- call local api for this reduction operation
    reduce_pool_balance(p_khr_id => to_number(p_new1_chr_id)
                       ,p_source_trx_date => trunc(cv_split_info_rec.date_transaction_occurred)
                       ,x_return_status => x_return_status);
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'reduce pool balance from first contract api return status '||x_return_status||' x_msg_data '||x_msg_data
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF(x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- no errors from the first contract, process the second split contract for pool balance reduction.
    -- call local api for this reduction operation
    reduce_pool_balance(p_khr_id => to_number(p_new2_chr_id)
                       ,p_source_trx_date => trunc(cv_split_info_rec.date_transaction_occurred)
                       ,x_return_status => x_return_status);
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                              l_module,
                              'reduce pool balance from second contract api return status '||x_return_status|| ' x_msg_data '||x_msg_data
                              );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF(x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIUB.pls call create_pool_trx_khr_split');
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data		=> x_msg_data);
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
  END create_pool_trx_khr_split;

END okl_subsidy_pool_auth_trx_pvt;

/
