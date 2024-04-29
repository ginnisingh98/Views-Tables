--------------------------------------------------------
--  DDL for Package Body OKL_AM_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_INTEGRATION_PVT" AS
/* $Header: OKLRKRBB.pls 120.3.12010000.3 2008/10/03 18:17:41 rkuttiya ship $ */

  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

-- Start of comments
--
-- Procedure Name       : cancel_termination_quotes
-- Description          : Invalidates all the termination quotes
--                      : for the contract
-- Business Rules       :
-- Parameters           : contract_id and quote_id which caused the rebook process
-- Version              : 1.0
-- History              : SPILLAIP  -- Created
--                      : SECHAWLA 23-OCT-03 -- Changed p_quote_id parameter to p_source_trx_id
--                        SECHAWLA 10-NOV-03 3248212 -- Changed quote status COMPLETED to COMPLETE
-- End of comments


  PROCEDURE cancel_termination_quotes  (p_api_version     IN          NUMBER,
                                        p_init_msg_list   IN          VARCHAR2 DEFAULT G_FALSE,
                                        p_khr_id          IN          NUMBER,
                                        p_source_trx_id   IN          NUMBER,
                                        p_source          IN          VARCHAR2 DEFAULT NULL, -- rmunjulu bug 4508497
                                        x_return_status   OUT NOCOPY  VARCHAR2,
                                        x_msg_count       OUT NOCOPY  NUMBER,
                                        x_msg_data        OUT NOCOPY  VARCHAR2) IS

       lp_source_trx_id         NUMBER           := p_source_trx_id;
       lp_khr_id                NUMBER           := p_khr_id;
       l_return_status          VARCHAR2(1)      := OKL_API.G_RET_STS_SUCCESS;
       l_program_name  CONSTANT VARCHAR2(61)     := 'cancel_termination_quotes';
       l_api_name      CONSTANT VARCHAR2(61)     := G_PKG_NAME||'.'||l_program_name;
       lx_quote_tbl             OKL_AM_UTIL_PVT.quote_tbl_type;
       lp_canceled_qtev_rec     OKL_QTE_PVT.qtev_rec_type;
       lx_canceled_qtev_rec     OKL_QTE_PVT.qtev_rec_type;
       l_contract_number        OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE    :=  NULL;
       i                        NUMBER;
       l_quote_id               NUMBER;
  -- cursor to check whether contract is valid or not
  CURSOR is_khr_exists_csr IS
    SELECT contract_number
    FROM OKC_K_HEADERS_B
    WHERE id = p_khr_id;

  -- SECHAWLA 23-OCT-03 : Added this cursor
  -- get the quote id from the termination transaction
  CURSOR l_trxcontracts_csr(cp_trx_id IN NUMBER) IS
  SELECT qte_id
  FROM   OKL_TRX_CONTRACTS
  WHERE  id = cp_trx_id;

	-- rmunjulu bug 4508497 added to check the setup
    CURSOR l_sys_prms_csr IS
      SELECT NVL(upper(CANCEL_QUOTES_YN), 'N') CANCEL_QUOTES
      FROM   OKL_SYSTEM_PARAMS;

	-- rmunjulu bug 4508497
    l_keep_existing_quotes_yn VARCHAR2(3);
  BEGIN

    SAVEPOINT l_program_name;

    IF(lp_khr_id IS NULL OR lp_khr_id = OKL_API.G_MISS_NUM) THEN
        -- set the message and raise an exception if contract id is passed as null
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'chr_id');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- cursor to check whether the contract id exists or not by retrieving the contract number
    FOR l_khr_exists_rec IN is_khr_exists_csr
    LOOP
        l_contract_number := l_khr_exists_rec.contract_number;
    END LOOP;

    IF(l_contract_number IS NULL) THEN
       -- set the message and raise an exception if contract id is passed as null
       --SECHAWLA 28-JUL-04 3789019 : Use OKL application ans OKL_message instead of OKC
       /*OKL_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                           p_token1        => 'COL_NAME',
                           p_token1_value  => 'CONTRACT_NUMBER');
       */
         OKL_API.set_message(p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_CONTRACTS_INVALID_VALUE',
                           p_token1        => 'COL_NAME',
                           p_token1_value  => 'CONTRACT_NUMBER');
    END IF;

	-- rmunjulu bug 4508497 ++++++++ start ++++++++++++++++++++++
	l_keep_existing_quotes_yn := 'N';

	IF nvl(p_source,'*') = 'EVERGREEN' THEN

	  l_keep_existing_quotes_yn := 'N'; -- always cancel quotes whatever be the setup

	ELSIF nvl(p_source,'*') = 'ALT' THEN -- source is rebook partial termination

      -- Check system option
      OPEN l_sys_prms_csr;
      FETCH l_sys_prms_csr INTO l_keep_existing_quotes_yn;
      IF l_sys_prms_csr%NOTFOUND THEN
        l_keep_existing_quotes_yn := 'N';
      END IF;
      CLOSE l_sys_prms_csr;

    ELSIF nvl(p_source,'*') = 'PPD' THEN -- source is rebook Principal Paydown

	  l_keep_existing_quotes_yn := 'N'; -- always cancel quotes whatever be the setup

    ELSIF nvl(p_source,'*') <> '*' THEN -- source is some other transaction

	  l_keep_existing_quotes_yn := 'N'; -- always cancel quotes whatever be the setup

	ELSIF p_source IS NULL THEN  -- no value passed means online rebook

      -- Check system option
      OPEN l_sys_prms_csr;
      FETCH l_sys_prms_csr INTO l_keep_existing_quotes_yn;
      IF l_sys_prms_csr%NOTFOUND THEN
        l_keep_existing_quotes_yn := 'N';
      END IF;
      CLOSE l_sys_prms_csr;

	END IF;
	-- rmunjulu bug 4508497 ++++++++ start ++++++++++++++++++++++

	-- rmunjulu bug 4508497 -- added condition -- only if keep existing quotes is NO
	IF nvl(l_keep_existing_quotes_yn,'N') = 'N' THEN

    -- Get all quotes for the contract
    OKL_AM_UTIL_PVT.get_all_term_qte_for_contract(p_khr_id          => lp_khr_id,
                                                  x_quote_tbl       => lx_quote_tbl,
                                                  x_return_status   => l_return_status);

    IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        -- Loop thru the quotes for the contract
        IF lx_quote_tbl.COUNT > 0 THEN
            -- SECHAWLA 23-OCT-03 Added the following piece of code to get the quote id if a termination transaction
            -- exists and was created thru a quote.
            IF lp_source_trx_id IS NOT NULL THEN
                OPEN  l_trxcontracts_csr(lp_source_trx_id);
                FETCH l_trxcontracts_csr INTO l_quote_id;
                IF  l_trxcontracts_csr%NOTFOUND THEN
                    OKC_API.set_message( p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'SOURCE_TRX_ID');

                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                CLOSE l_trxcontracts_csr;
             END IF;
            -- SECHAWLA 23-OCT-03 : End new code

            i := lx_quote_tbl.FIRST;
            LOOP
              -- if the quote id different and quote not consolidated and not
              -- completed/canceled then cancel it
              -- do not cancel the  quote that initiated the rebook
              -- l_quote_id will be null if the termination is not initiated thru a quote
              IF ((l_quote_id IS NULL OR lx_quote_tbl(i).id <> l_quote_id)
                 AND NVL(lx_quote_tbl(i).consolidated_yn,'N') <> 'Y'
                 -- SECHAWLA 28-JUL-04 3788993 : Added check for ACCEPTED quotes
                 AND lx_quote_tbl(i).qst_code NOT IN('COMPLETE','CANCELLED','ACCEPTED')) THEN -- 3248212 Changed COMPLETED to COMPLETE

                -- set the canceled qtev rec
                lp_canceled_qtev_rec.id := lx_quote_tbl(i).id;
                lp_canceled_qtev_rec.qst_code := 'CANCELLED';

                -- update the quote to canceled
                OKL_TRX_QUOTES_PUB.update_trx_quotes( p_api_version     => p_api_version,
                                                      p_init_msg_list   => OKL_API.G_FALSE,
                                                      x_return_status   => l_return_status,
                                                      x_msg_count       => x_msg_count,
                                                      x_msg_data        => x_msg_data,
                                                      p_qtev_rec        => lp_canceled_qtev_rec,
                                                      x_qtev_rec        => lx_canceled_qtev_rec);

                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
              EXIT WHEN i = lx_quote_tbl.LAST; -- exit when the last record is processed
              i := lx_quote_tbl.NEXT(i);
            END LOOP;
        END IF;
    ELSE
       -- set the message if OKL_AM_UTIL_PVT.get_all_term_quotes_for_contract throws error
       -- with contract number as token value
       OKL_API.SET_MESSAGE(p_app_name     => 'OKL',
    	                   p_msg_name	  => 'OKL_AM_ERR_RET_QTES',
                           p_token1        => 'CONTRACT_NUMBER',
                           p_token1_value  => l_contract_number);
        --message("Error retrieving existing quotes for this contract for cancellation");
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
	END IF;
    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
    -- roll back and return the status as error(E)
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO l_program_name;
      x_return_status := G_RET_STS_ERROR;
    -- roll back and return the status as un expected error(U)
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO l_program_name;
      x_return_status := G_RET_STS_UNEXP_ERROR;
    -- set the message, roll back and return the status as un expected error(U)
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      ROLLBACK TO l_program_name;
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END cancel_termination_quotes; -- end of the procedure

END  OKL_AM_INTEGRATION_PVT;

/
