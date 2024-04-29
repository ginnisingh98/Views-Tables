--------------------------------------------------------
--  DDL for Package Body OKL_LOAN_BAL_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LOAN_BAL_UPDATE_PVT" AS
  /* $Header: OKLRLBUB.pls 120.4 2006/07/13 12:36:41 adagur noship $ */


  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       smadhava
    -- Procedure Name:   get_loan_amounts
    -- Description:      This Procedure is called from concurrent program "OKL Loan Balances Update"
    --                   as of a given date for a Loan
    --                   Inputs :
    --                   Output :
    -- Dependencies:
    -- Parameters:       Contract id, As of Date
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------
  PROCEDURE get_loan_amounts(
                              p_api_version      IN         NUMBER
                            , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                            , x_return_status    OUT NOCOPY VARCHAR2
                            , x_msg_count        OUT NOCOPY NUMBER
                            , x_msg_data         OUT NOCOPY VARCHAR2
                            , p_khr_rec          IN         khr_rec_type
                            , p_as_of_date       IN         DATE) IS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;
    l_api_name CONSTANT VARCHAR2(30) DEFAULT 'GET_LOAN_AMOUNTS';

    l_module CONSTANT fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_LOAN_BAL_UPDATE_PVT.GET_LOAN_AMOUNTS';
    l_debug_enabled VARCHAR2(10);

    --l_khr_id NUMBER;
    --l_asset_exists BOOLEAN := FALSE;

    l_kle_prin_bal              NUMBER := 0;
    l_khr_prin_bal              NUMBER := 0;
    l_tot_interest_amt_due      NUMBER := 0;
    l_tot_interest_amt_billed   NUMBER := 0;
    l_tot_interest_amt_received NUMBER := 0;

    l_cblv_rec okl_cblv_rec;
    l_crt_cblv_tbl okl_cblv_tbl;
    lx_crt_cblv_tbl okl_cblv_tbl;
    l_upd_cblv_tbl okl_cblv_tbl;
    lx_upd_cblv_tbl okl_cblv_tbl;


    i   NUMBER   := 0;
    j   NUMBER   := 0;

    /*
       CURSOR TO CHECK IF THE contract's Book classification is LOAN or REVOLVING-LOAN
       AND IF contract status is booked or terminated
     */
    /*CURSOR check_contract_loan_bal(p_contract_number VARCHAR2) IS
      SELECT
             KHR.ID
       FROM
             OKC_K_HEADERS_B CHR
           , OKL_K_HEADERS KHR
           , OKL_PRODUCT_PARAMETERS_V PPM
           , OKC_STATUSES_V STS
       WHERE chr.id = khr.id
       AND   khr.pdt_id = ppm.id
       AND   chr.sts_code = sts.code
       AND   (sts.code = 'BOOKED'    OR sts.ste_code = 'TERMINATED')
       AND   (ppm.deal_type = 'LOAN' OR ppm.deal_type = 'LOAN-REVOLVING')
       AND   CHR.CONTRACT_NUMBER = p_contract_number;*/

    -- Cursor to obtain the Assets in a contract
    CURSOR get_assets(cp_khr_id NUMBER) IS
      SELECT assets.id     asset_id
          , assets.name   asset_number
      FROM okc_k_lines_v     assets
          , okc_line_styles_b lse
          ,okc_statuses_v sts
      WHERE assets.dnz_chr_id   = cp_khr_id
      AND lse.id              = assets.lse_id
      AND lse.lty_code        = 'FREE_FORM1'
      AND assets.sts_code = sts.code
      AND sts.ste_code in ('ACTIVE', 'TERMINATED');

    -- Cursor to check the presence of contract balances for a contract
    CURSOR chk_contract_bal(p_chr_id NUMBER) IS
      SELECT  id
            , object_version_number
      FROM  okl_contract_balances
      WHERE  khr_id = p_chr_id
      AND kle_id IS NULL ;

    -- Cursor to check the presence of contract balances for a contract asset
    CURSOR chk_asset_bal(p_chr_id NUMBER, p_kle_id NUMBER) IS
      SELECT  id
            , object_version_number
      FROM  okl_contract_balances
      WHERE khr_id = p_chr_id
      AND kle_id = p_kle_id;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRLBUB.pls call GET_LOAN_AMOUNTS');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    /*x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;*/

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check if the contract is of Book classification LOAN or REVOLVING-LOAN and is Booked
    /*OPEN check_contract_loan_bal(p_contract_number);
      FETCH check_contract_loan_bal INTO l_khr_id;
      IF check_contract_loan_bal%NOTFOUND THEN
         FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Book classification is not valid or the contract status is not Booked ');
         FND_FILE.PUT_LINE (FND_FILE.LOG,'Contract Book classification is not valid or the contract status is not Booked ');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    CLOSE check_contract_loan_bal;*/

    i :=1;
    j :=1;
    -- Get the asset IDs of the contract
    IF (p_khr_rec.deal_type = 'LOAN') THEN
      FOR l_kle_rec IN get_assets(p_khr_rec.khr_id)
      LOOP
         --l_asset_exists := TRUE;
         --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Calculation for Asset Number: '|| l_kle_rec.asset_number);
         --FND_FILE.PUT_LINE (FND_FILE.LOG,'Calculation for Asset Number: '|| l_kle_rec.asset_number);
        /********************************************
         * Calculation FOR Actual Principal Balance *
         ********************************************/
         FND_FILE.PUT_LINE (FND_FILE.LOG,'Calculation for Actual Principal Balance');
         -- Get the total principal balance
         l_kle_prin_bal :=
               OKL_VARIABLE_INT_UTIL_PVT.get_principal_bal( x_return_status
                                                          , p_khr_rec.khr_id -- Contract ID
                                                          , l_kle_rec.asset_id -- Asset ID
                                                          , p_as_of_date );

        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate principal balance for Asset Number: '|| l_kle_rec.asset_number);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate principal balance for Asset Number: '|| l_kle_rec.asset_number);
        END IF;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Asset Number: '|| l_kle_rec.asset_number || ' Principal Balance : ' || l_kle_prin_bal);
        --l_khr_prin_bal := l_khr_prin_bal + l_kle_prin_bal;

        -- Actual Principal balance = outstanding principal balance
        --l_actual_prin_bal := l_outstanding_prin_bal;
        --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Actual Principal balance (outstanding principal balance)='||l_actual_prin_bal);
        --FND_FILE.PUT_LINE (FND_FILE.LOG,'Actual Principal balance (outstanding principal balance )='||l_actual_prin_bal);

        -- Initialize the contract balances record with the values
        l_cblv_rec.khr_id                          := p_khr_rec.khr_id;
        l_cblv_rec.kle_id                          := l_kle_rec.asset_id;
        l_cblv_rec.actual_principal_balance_amt    := l_kle_prin_bal;
        l_cblv_rec.actual_principal_balance_date   := p_as_of_date;

        -- Check if there are balances for this asset
        OPEN chk_asset_bal(p_khr_rec.khr_id, l_kle_rec.asset_id);
        FETCH chk_asset_bal INTO l_cblv_rec.id, l_cblv_rec.object_version_number;

        IF chk_asset_bal%NOTFOUND THEN
            l_crt_cblv_tbl(i) := l_cblv_rec;
            i := i + 1;
        ELSE
            l_upd_cblv_tbl(j) := l_cblv_rec;
            j := j + 1;
        END IF; -- end of check for presence of contract asset balances
        CLOSE chk_asset_bal; -- end of check for Balances for asset

      END LOOP; -- end of for loop for Assets
   END IF;


    --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'--------------------------------------------------------------------------');
    --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Balances for Contract Number: ' ||p_contract_number);
    --FND_FILE.PUT_LINE (FND_FILE.LOG,'--------------------------------------------------------------------------');
    --FND_FILE.PUT_LINE (FND_FILE.LOG,'Contract Balances for Contract Number: ' ||p_contract_number);

    -- Re-initialize the principal balance columns
    l_cblv_rec.actual_principal_balance_amt    := null;
    l_cblv_rec.actual_principal_balance_date   := null;

    -- A revolving loan doesnot have any assets and hence has a contract level information only.
    --IF NOT l_asset_exists THEN
      /********************************************
       * Calculation FOR Actual Principal Balance *
       ********************************************/
       --FND_FILE.PUT_LINE (FND_FILE.LOG,'Calculation for Actual Principal Balance');
      -- Get the total principal balance
      l_khr_prin_bal :=
             OKL_VARIABLE_INT_UTIL_PVT.get_principal_bal( x_return_status
                                                        , p_khr_rec.khr_id -- Contract ID
                                                        , null     --Asset id is null for revolving Loan
                                                        , p_as_of_date );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate principal balance for Contract Number: '|| p_khr_rec.contract_number);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate principal balance for Contract Number: '|| p_khr_rec.contract_number);
      END IF;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Number: '|| p_khr_rec.contract_number || ' Principal Balance : ' || l_khr_prin_bal);

      -- Actual Principal balance = outstanding principal balance
      --l_actual_prin_bal := l_outstanding_prin_bal;

      l_cblv_rec.actual_principal_balance_amt    := l_khr_prin_bal;
      l_cblv_rec.actual_principal_balance_date   := p_as_of_date;

      --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Actual Principal balance (outstanding principal balance)='||l_actual_prin_bal);
      --FND_FILE.PUT_LINE (FND_FILE.LOG,'Actual Principal balance (outstanding principal balance )='||l_actual_prin_bal);
    --END IF; -- end of check for existence of asset for the contract

     /*********************************************
      * Calculation FOR Total Interest Amount Due *
      *********************************************/
      --FND_FILE.PUT_LINE (FND_FILE.LOG,'Calculation for Total Interest Amount Due');
      -- Get the total interest amount due
      l_tot_interest_amt_due :=
             OKL_VARIABLE_INT_UTIL_PVT.get_interest_due(  x_return_status
                                                        , p_khr_rec.khr_id -- Contract ID
                                                        , p_as_of_date );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate interest due for Contract Number: '|| p_khr_rec.contract_number);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate interest due for Contract Number: '|| p_khr_rec.contract_number);
      END IF;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Number: '|| p_khr_rec.contract_number || ' Interest Due : ' || l_tot_interest_amt_due);
      /************************************************
       * Calculation FOR Total Interest Amount Billed *
       ************************************************/
      -- Get the total interest amount billed
      l_tot_interest_amt_billed :=
             OKL_VARIABLE_INT_UTIL_PVT.get_interest_billed( x_return_status
                                                          , p_khr_rec.khr_id -- Contract ID
                                                          , NULL
                                                          , p_as_of_date );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate interest billed for Contract Number: '|| p_khr_rec.contract_number);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate interest billed for Contract Number: '|| p_khr_rec.contract_number);
      END IF;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Number: '|| p_khr_rec.contract_number || ' Interest Billed : ' || l_tot_interest_amt_billed);
      --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Total interest amount billed ='|| l_tot_interest_amt_billed );
      --FND_FILE.PUT_LINE (FND_FILE.LOG,'Total interest amount billed ='|| l_tot_interest_amt_billed );
      /**************************************************
       * Calculation FOR Total Interest Amount Received *
       **************************************************/
      -- Get the total interest amount received
      l_tot_interest_amt_received :=
             OKL_VARIABLE_INT_UTIL_PVT.get_interest_paid( x_return_status
                                                        , p_khr_rec.khr_id -- Contract ID
                                                        , NULL
                                                        , p_as_of_date );
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate interest received for Contract Number: '|| p_khr_rec.contract_number);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to calculate interest received for Contract Number: '|| p_khr_rec.contract_number);
      END IF;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Number: '|| p_khr_rec.contract_number || ' Interest Received : ' || l_tot_interest_amt_received);
      --FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Total interest amount received ='|| l_tot_interest_amt_received);
      --FND_FILE.PUT_LINE (FND_FILE.LOG,'Total interest amount received ='|| l_tot_interest_amt_received);

      -- Initialize the contract balances record with the values
      l_cblv_rec.khr_id                          := p_khr_rec.khr_id;
      l_cblv_rec.kle_id                          := NULL;
      l_cblv_rec.interest_amt                    := l_tot_interest_amt_due;
      l_cblv_rec.interest_calc_date              := p_as_of_date;
      l_cblv_rec.interest_billed_amt             := l_tot_interest_amt_billed;
      l_cblv_rec.interest_billed_date            := p_as_of_date;
      l_cblv_rec.interest_received_amt           := l_tot_interest_amt_received;
      l_cblv_rec.interest_received_date          := p_as_of_date;

      -- Check if there are balances for this contract
      OPEN chk_contract_bal(p_khr_rec.khr_id);
      FETCH chk_contract_bal INTO l_cblv_rec.id, l_cblv_rec.object_version_number;
      IF chk_contract_bal%NOTFOUND THEN
          l_crt_cblv_tbl(i) := l_cblv_rec;
      ELSE
          l_upd_cblv_tbl(j) := l_cblv_rec;
      END IF; -- end of check for presence of contract asset balances
      CLOSE chk_contract_bal;

    IF l_crt_cblv_tbl.COUNT > 0 THEN
      -- Insert the table of records into OKL_CONTRACT_BALANCES
      OKL_CONTRACT_BALANCES_PVT.create_contract_balance(
                         p_api_version      => l_api_version
                       , p_init_msg_list    => p_init_msg_list
                       , x_return_status    => x_return_status
                       , x_msg_count        => x_msg_count
                       , x_msg_data         => x_msg_data
                       , p_cblv_tbl         => l_crt_cblv_tbl
                       , x_cblv_tbl         => lx_crt_cblv_tbl);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to create balances for Contract Number: '|| p_khr_rec.contract_number);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to create balances for Contract Number: '|| p_khr_rec.contract_number);
      END IF;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Successfully created balances for Contract Number: '|| p_khr_rec.contract_number);
    END IF;

    IF l_upd_cblv_tbl.COUNT > 0 THEN
      -- Update the table of records in OKL_CONTRACT_BALANCES
      OKL_CONTRACT_BALANCES_PVT.update_contract_balance(
                         p_api_version      => l_api_version
                       , p_init_msg_list    => p_init_msg_list
                       , x_return_status    => x_return_status
                       , x_msg_count        => x_msg_count
                       , x_msg_data         => x_msg_data
                       , p_cblv_tbl         => l_upd_cblv_tbl
                       , x_cblv_tbl         => lx_upd_cblv_tbl);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to update balances for Contract Number: '|| p_khr_rec.contract_number);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Unable to update balances for Contract Number: '|| p_khr_rec.contract_number);
      END IF;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Successfully updated balances for Contract Number: '|| p_khr_rec.contract_number);
    END IF;
    -- commit the savepoint
    --OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRLBUB.pls call GET_LOAN_AMOUNTS');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := x_return_status;
  END get_loan_amounts;

  --------------------------------------------------------------------------------
    --Start of Comments
    --API Name    : calculate_loan_amounts
    --Description : Process API to calculate the balances for a contract and its
    --              assets. The API is called by the Loan Balances concurrent
    --              program to create/update the balances for the contract based
    --              on the given date.
    --History     :
    --              02-SEP-2005 dkagrawa Created
    --End of Comments
  ------------------------------------------------------------------------------

  PROCEDURE calculate_loan_amounts(
                       errbuf  OUT NOCOPY VARCHAR2
                     , retcode OUT NOCOPY NUMBER
                     , p_contract_number IN VARCHAR2
                     , p_as_of_date         IN VARCHAR2 ) IS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;

    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(450);
    l_msg_index_out   NUMBER;
    lx_return_status  VARCHAR(1) := OKL_API.G_RET_STS_SUCCESS;
    l_as_of_date      DATE := TRUNC(SYSDATE);
    l_khr_rec         khr_rec_type;

    CURSOR c_khr_csr(cp_contract_number IN VARCHAR2) IS SELECT chr.id khr_id,
        chr.contract_number,
        sts.code status,
        ppm.deal_type,
        ppm.interest_calculation_basis ,
        ppm.revenue_recognition_method
    FROM okc_k_headers_b chr
       , okl_k_headers khr
       , okl_product_parameters_v ppm
       , okc_statuses_v sts
    WHERE chr.contract_number = NVL(cp_contract_number, chr.contract_number)
    AND   chr.id = khr.id
    AND   khr.pdt_id = ppm.id
    AND   chr.sts_code = sts.code
    AND   (sts.code = 'BOOKED'     OR sts.ste_code = 'TERMINATED')
    AND   (ppm.deal_type = 'LOAN' OR ppm.deal_type = 'LOAN-REVOLVING')
    AND   (NOT(ppm.interest_calculation_basis = 'FIXED' AND ppm.revenue_recognition_method = 'STREAMS'))
    ORDER BY chr.contract_number;
  BEGIN

    IF p_as_of_date IS NOT NULL THEN
      l_as_of_date :=  FND_DATE.CANONICAL_TO_DATE(p_as_of_date);
    END IF;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Loan Balances Update for Variable Interest');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date: '||sysdate);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'To Date: '||l_as_of_date);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Success or Error Detailed Messages Each Update');

    FOR cur_khr IN c_khr_csr(p_contract_number) LOOP
      l_khr_rec := cur_khr;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing Contract Number: '|| l_khr_rec.contract_number);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  Status: ' || l_khr_rec.status);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  Book classification: ' || l_khr_rec.deal_type);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  Interest calculation method: ' || l_khr_rec.interest_calculation_basis);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  Revenue recognition method: ' || l_khr_rec.revenue_recognition_method);

      get_loan_amounts(
                      p_api_version      => l_api_version,
                      p_init_msg_list    => FND_API.G_FALSE,
                      x_return_status    => lx_return_status,
                      x_msg_count        => lx_msg_count,
                      x_msg_data         => errbuf,
                      p_khr_rec          => l_khr_rec,
                      p_as_of_date       => l_as_of_date);

      IF (lx_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Successfully processed contract: ' || l_khr_rec.contract_number);
        Commit;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error processing contract: ' || l_khr_rec.contract_number);
      ELSIF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Unexpected error processing contract: ' || l_khr_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    END LOOP;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Loan Balances Update for Variable Interest Completed Successfully');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program End Date: '||sysdate);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');

    errbuf := lx_msg_data;
    IF lx_msg_count >= 1 THEN
      FOR i in 1..lx_msg_count LOOP
        fnd_msg_pub.get (p_msg_index     => i,
                         p_encoded       => 'F',
                         p_data          => lx_msg_data,
                         p_msg_index_out => l_msg_index_out);

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || lx_msg_data);
      END LOOP; -- end of for loop
    END IF; -- end of check for message count
    retcode := 0;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      retcode := 2;
      lx_return_status := Okl_Api.HANDLE_EXCEPTIONS(G_APP_NAME,
                                                    G_PKG_NAME,
                                                   'Okl_Api.G_RET_STS_ERROR',
                                                    lx_msg_count,
                                                    lx_msg_data,
                                                    '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      retcode := 2;
      lx_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => G_APP_NAME,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => lx_msg_count,
                           x_msg_data  => lx_msg_data,
                           p_api_type  => '_PVT');
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := SQLERRM;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||SQLCODE||': '||SQLERRM);
  END calculate_loan_amounts;

END OKL_LOAN_BAL_UPDATE_PVT; -- end of Body

/
