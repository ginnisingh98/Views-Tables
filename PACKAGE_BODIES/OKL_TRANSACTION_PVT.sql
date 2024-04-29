--------------------------------------------------------
--  DDL for Package Body OKL_TRANSACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANSACTION_PVT" AS
/* $Header: OKLRTXNB.pls 120.9.12010000.3 2009/10/06 22:12:39 sechawla ship $*/

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

-- Global Variables
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_TRANSACTION_PVT';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';

   -- smadhava Bug# 4542290 - 24-Aug-2005 - Added - Start
   G_REBOOK_TRX CONSTANT VARCHAR(30)    := 'REBOOK';
   -- smadhava Bug# 4542290 - 24-Aug-2005 - Added - End

--   subtype tcnv_rec_type IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

   /*
   -- mvasudev, 08/17/2004
   -- Added Constants to enable Business Event
   */
   G_WF_EVT_KHR_SPLIT_REQ CONSTANT VARCHAR2(60) := 'oracle.apps.okl.la.lease_contract.split_contract_requested';

   G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(20) := 'CONTRACT_PROCESS';
   G_WF_ITM_SRC_CONTRACT_ID CONSTANT VARCHAR2(20) := 'SOURCE_CONTRACT_ID';
   G_WF_ITM_DEST_CONTRACT_ID CONSTANT VARCHAR2(25) := 'DESTINATION_CONTRACT_ID';
   G_WF_ITM_TRX_DATE CONSTANT VARCHAR2(20) := 'TRANSACTION_DATE';

   G_KHR_PROCESS_SPLIT_CONTRACT   CONSTANT VARCHAR2(14) := Okl_Lla_Util_Pvt.G_KHR_PROCESS_SPLIT_CONTRACT;

------------------------------------------------------------------------------
-- PROCEDURE Report_Error
-- It is a generalized routine to display error on Concurrent Manager Log file
-- Calls:
-- Called by:
------------------------------------------------------------------------------
--Added by dpsingh for LE uptake
  CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM OKC_K_HEADERS_B
  WHERE id = p_ctr_id1;

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        ) IS

  x_msg_index_out NUMBER;
  x_msg_out       VARCHAR2(2000);

  BEGIN

    okl_api.end_activity(
                         X_msg_count => x_msg_count,
                         X_msg_data  => x_msg_data
                        );

    FOR i IN 1..x_msg_count
    LOOP
      FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => x_msg_index_out
                     );

    END LOOP;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Report_Error;

------------------------------------------------------------------------------
-- PROCEDURE validate_rebook_reason
--
--  This procedure validate rebook reason code
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE validate_rebook_reason(
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2,
                                   p_rebook_reason_code IN  VARCHAR2
                                  ) IS

  l_proc_name VARCHAR2(35) := 'VALIDATE_REBOOK_REASON';
  l_dummy     VARCHAR2(1);

  CURSOR rebook_csr (p_rebook_reason_code VARCHAR2) IS
  SELECT 'X'
  FROM   FND_LOOKUPS
  WHERE  lookup_type = 'OKL_REBOOK_REASON'
  AND    lookup_code = p_rebook_reason_code;

  rebook_failed EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN rebook_csr(p_rebook_reason_code);
    FETCH rebook_csr INTO l_dummy;
    IF rebook_csr%NOTFOUND THEN
       RAISE rebook_failed;
    END IF;
    CLOSE rebook_csr;

    RETURN;

  EXCEPTION
    WHEN rebook_failed THEN
       okl_api.set_message(
                            G_APP_NAME,
                            G_INVALID_VALUE,
                            'COL_NAME',
                            'REBOOK REASON'
                           );
       x_return_status := OKC_API.G_RET_STS_ERROR;

  END validate_rebook_reason;

------------------------------------------------------------------------------
-- PROCEDURE populate_transaction_rec
--
--  This procedure populate transaction records, tcnv_rec
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE populate_transaction_rec(
                                     x_return_status      OUT NOCOPY VARCHAR2,
                                     x_msg_count          OUT NOCOPY NUMBER,
                                     x_msg_data           OUT NOCOPY VARCHAR2,
                                     p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                                     p_new_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                                     p_reason_code        IN  VARCHAR2,
                                     p_description        IN  VARCHAR2,
                                     p_trx_date           IN  DATE,
                                     p_trx_type           IN  VARCHAR2,
                                     x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                                    ) IS
   l_proc_name     VARCHAR2(35) := 'POPULATE_TRANSACTION_REC';
   l_try_id        NUMBER;
   l_id            NUMBER;
   l_currency_code OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
   l_org_id        OKL_K_HEADERS_FULL_V.AUTHORING_ORG_ID%TYPE;

   CURSOR con_header_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT currency_code,
          authoring_org_id
   FROM   okl_k_headers_full_v
   WHERE  id = p_chr_id;

   CURSOR try_csr(p_trx_type VARCHAR2) IS
   SELECT id
   FROM   okl_trx_types_tl
   WHERE  LANGUAGE = 'US'
   AND    name = DECODE(p_trx_type,'REBOOK','Rebook',
                                   'SPLIT', 'Split Contract',
                                            'Error');
   populate_failed EXCEPTION;

     --Added by dpsingh for LE uptake
  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

     OPEN con_header_csr(p_chr_id);
     FETCH con_header_csr INTO l_currency_code,
                               l_org_id;
     IF con_header_csr%NOTFOUND THEN
        okl_api.set_message(
                            G_APP_NAME,
                            G_LLA_CHR_ID
                           );
        RAISE populate_failed;
     END IF;

     CLOSE con_header_csr;

/* Not required as TAPI is generating TRX_NUMBER

     SELECT okl_txn_number_s.nextval
     INTO   l_id
     FROM   dual;

     x_tcnv_rec.trx_number                := l_id;
*/

     IF (p_trx_type = 'REBOOK') THEN
        x_tcnv_rec.rbr_code                  := p_reason_code;
     END IF;

     OPEN try_csr (p_trx_type);
     FETCH try_csr INTO l_try_id;
     IF try_csr%NOTFOUND THEN
        okl_api.set_message(
                            G_APP_NAME,
                            G_LLA_NO_TRY,
                            'TRX_TYPE',
                            p_trx_type
                           );
        RAISE populate_failed;
     END IF;

     CLOSE try_csr;
     x_tcnv_rec.try_id                    := l_try_id;

     x_tcnv_rec.tsu_code                  := 'ENTERED';
     x_tcnv_rec.description               := p_description;

     IF (p_trx_type = 'REBOOK') THEN
        x_tcnv_rec.tcn_type := 'TRBK';
     ELSE
        x_tcnv_rec.tcn_type := 'SPLC';
     END IF;

     x_tcnv_rec.khr_id                    := p_chr_id;
     x_tcnv_rec.khr_id_old                := p_chr_id;
     x_tcnv_rec.khr_id_new                := p_new_chr_id;
     x_tcnv_rec.currency_code             := l_currency_code;
     x_tcnv_rec.date_transaction_occurred := p_trx_date;
     x_tcnv_rec.org_id                    := l_org_id;
     --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       x_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_chr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
     RETURN;


    EXCEPTION
       WHEN populate_failed  THEN

          IF try_csr%ISOPEN THEN
             CLOSE try_csr;
          END IF;

          IF con_header_csr%ISOPEN THEN
             CLOSE con_header_csr;
          END IF;

          x_return_status := OKC_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_UNEXPECTED_ERROR,
                             'OKL_SQLCODE',
                             SQLCODE,
                             'OKL_SQLERRM',
                             SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                            );
         x_return_status := OKC_API.G_RET_STS_ERROR;

   END populate_transaction_rec;

------------------------------------------------------------------------------
-- PROCEDURE update_trx_status
--
--  This procedure updates Transaction Status for a transaction
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE update_trx_status(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                              p_status             IN  VARCHAR2,
                              x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                             ) IS

  l_api_name    VARCHAR2(35)    := 'update_trx_status';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_TRX_STATUS';
  l_api_version CONSTANT NUMBER := 1;

  CURSOR trx_csr(p_chr_id_new OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id, representation_type --sechawla 01-oct-09 8967918 : added representation type
  FROM   OKL_TRX_CONTRACTS
  WHERE  khr_id_new = p_chr_id_new
  --rkuttiya added for 12.1.1 Multi GAAP
  --AND    representation_type = 'PRIMARY'; --sechawla 01-oct-09 8967918
  --When this API is called from upgrade script OKLTXRBKUG.sql, to cancel the
  --in process rebook transactions, MGAAP upgrade to update the representation_type
  --has not happened as yet. Hence representation_type is null at that point, which
  --cause upgrade to fail. Moreover, this condition is not needed. At the time of upgrade 11i > r12
  --there will be only one transaction for Primary, there won't be any secondary rep transactions
  AND   tcn_type = 'TRBK'; --sechawla 01-oct-09 8967918 : added this condition to pick only main rebook
                          --rebook transaction. Tax rebook transaction (PRBK) which is created once rebook
                          --copy is validated, need not be picked here, as that one is handled separately
                          --inside abandon_revisions procedure
  --

  l_tcnv_rec   tcnv_rec_type;
  lx_tcnv_rec  tcnv_rec_type; --sechawla 01-oct-09 8967918

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => G_PKG_NAME,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => G_API_TYPE,
                        x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    FOR trx_rec IN trx_csr(p_chr_id)
    LOOP
       l_tcnv_rec.id         := trx_rec.id;
       l_tcnv_rec.tsu_code   := p_status; --CANCELED
    --END LOOP; --sechawla 01-oct-09 8967918 : moved update within the loop

       Okl_Trx_Contracts_Pub.update_trx_contracts(
                                               p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_tcnv_rec      => l_tcnv_rec,
                                               x_tcnv_rec      => lx_tcnv_rec
                                              );

      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;

      IF (trx_rec.representation_type IS NULL --upgrade case, only 1 record will exist
         OR
         trx_rec.representation_type = 'PRIMARY') --UI case
         THEN
         x_tcnv_rec := lx_tcnv_rec; --need to return the record for primary only
      END IF;

    END LOOP; --sechawla 01-oct-09 8967918

    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END update_trx_status;

------------------------------------------------------------------------------
-- PROCEDURE check_contract_securitized
--
--  This procedure checks whether the contract is securitized and returns x_return_status
--  'F' - if securitized
--  'S' - if it is not securitized
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE check_contract_securitized(
                                 p_api_version        IN  NUMBER,
                                 p_init_msg_list      IN  VARCHAR2,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_msg_count          OUT NOCOPY NUMBER,
                                 x_msg_data           OUT NOCOPY VARCHAR2,
                                 p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                                 p_trx_date           IN  DATE
                                ) IS

  l_api_name    VARCHAR2(35)    := 'check_contract_securitized';
  l_proc_name   VARCHAR2(35)    := 'CHECK_CONTRACT_SECURITIZED';
  l_api_version CONSTANT NUMBER := 1;

  l_contract_secu       VARCHAR2(1);
  l_inv_agmt_chr_id_tbl inv_agmt_chr_id_tbl_type;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    okl_securitization_pvt.check_khr_securitized(
                                                 p_api_version         => 1.0,
                                                 p_init_msg_list       => OKC_API.G_FALSE,
                                                 x_return_status       => x_return_status,
                                                 x_msg_count           => x_msg_count,
                                                 x_msg_data            => x_msg_data,
                                                 p_khr_id              => p_chr_id,
                                                 p_effective_date      => p_trx_date,
                                                 x_value               => l_contract_secu,
                                                 x_inv_agmt_chr_id_tbl => l_inv_agmt_chr_id_tbl
                                                );

    IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
       IF (l_contract_secu = OKL_API.G_TRUE) THEN
           okl_api.set_message(
                            G_APP_NAME,
                            G_LLA_SECU_ERROR
                           );
           x_return_status := OKL_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    RETURN;

  EXCEPTION
    WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END check_contract_securitized;

------------------------------------------------------------------------------
-- PROCEDURE check_contract_securitized
--
--  This procedure checks whether the asset residual value is securitized
--  The value in x_return_status will be
--  'F' - if securitized
--  'S' - if it is not securitized
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE check_contract_securitized(
                                 p_api_version        IN  NUMBER,
                                 p_init_msg_list      IN  VARCHAR2,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_msg_count          OUT NOCOPY NUMBER,
                                 x_msg_data           OUT NOCOPY VARCHAR2,
                                 p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                                 p_cle_id             IN  OKC_K_LINES_V.ID%TYPE,
                                 p_stream_type_class  IN  okl_strm_type_b.stream_type_subclass%TYPE,
                                 p_trx_date           IN  DATE
                                ) IS

  l_api_name    VARCHAR2(35)    := 'check_contract_securitized';
  l_proc_name   VARCHAR2(35)    := 'CHECK_CONTRACT_SECURITIZED';
  l_api_version CONSTANT NUMBER := 1;

  l_asset_secu          VARCHAR2(1);
  l_inv_agmt_chr_id_tbl inv_agmt_chr_id_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    okl_securitization_pvt.check_kle_securitized(
                                                 p_api_version              => p_api_version,
                                                 p_init_msg_list            => OKL_API.G_FALSE,
                                                 x_return_status            => x_return_status,
                                                 x_msg_count                => x_msg_count,
                                                 x_msg_data                 => x_msg_data,
                                                 p_kle_id                   => p_cle_id,
                                                 p_effective_date           => p_trx_date,
                                                 p_stream_type_subclass     => p_stream_type_class,
                                                 x_value                    => l_asset_secu,
                                                 x_inv_agmt_chr_id_tbl      => l_inv_agmt_chr_id_tbl
                                               );

    IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
       IF (l_asset_secu = OKL_API.G_TRUE) THEN
           okl_api.set_message(
                            G_APP_NAME,
                            G_LLA_SECU_ERROR
                           );
           x_return_status := OKL_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    RETURN;

  EXCEPTION
    WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END check_contract_securitized;

------------------------------------------------------------------------------
-- PROCEDURE create_transaction
--
--  This procedure creates Transaction as a first step to REBOOKing
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_transaction(
                          p_api_version        IN  NUMBER,
                          p_init_msg_list      IN  VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2,
                          p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_new_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_reason_code        IN  VARCHAR2,
                          p_description        IN  VARCHAR2,
                          p_trx_date           IN  DATE,
                          p_trx_type           IN  VARCHAR2, -- 'REBOOK' or 'SPLIT'
                          x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                         ) IS

  l_api_name    VARCHAR2(35)    := 'create_transaction';
  l_proc_name   VARCHAR2(35)    := 'CREATE_TRANSACTION';
  l_api_version CONSTANT NUMBER := 1;

  l_tcnv_rec        tcnv_rec_type;
  l_out_tcnv_rec    tcnv_rec_type;

  CURSOR con_eff_csr (p_chr_id   OKC_K_HEADERS_B.ID%TYPE) IS
  SELECT start_date,
         end_date
  FROM   okc_k_headers_b
  WHERE  id = p_chr_id;

  CURSOR check_date_csr (p_start_date DATE,
                         p_end_date   DATE,
                         p_trx_date   DATE) IS
  SELECT 'Y'
  FROM   DUAL
  WHERE  p_trx_date BETWEEN p_start_date AND p_end_date;

  l_con_start_date DATE;
  l_con_end_date   DATE;
  l_date_valid     VARCHAR2(1);

  --akrangan start
  --CURSOR FOR CHECKING WHETHER A ASSET LOCATION CHANGE TRANSACTION IS
  --CREATED FOR THE ASSETS USED IN THE CONTRACT
  CURSOR chk_asst_loc_khr_csr(p_chr_id NUMBER)
  IS
  SELECT 'N'
  FROM   okc_k_lines_b  okc ,
	     okc_line_styles_b ols,
	     okl_trx_assets trx ,
	     okl_txl_itm_insts itm
  WHERE  okc.dnz_chr_id = p_chr_id
	AND  okc.id = itm.kle_id
	AND  okc.lse_id = ols.id
	AND  ols.lty_code =  'INST_ITEM'
	AND  trx.tsu_code = 'ENTERED'
	AND  trx.tas_type = 'ALG'
	AND  trx.id =  itm.tas_id ;

  l_rebook_allowed      VARCHAR2(1) := 'Y';
  l_contract_number     OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  --akrangan end
    /*
    -- mvasudev, 08/30/2004
    -- Added PROCEDURE to enable Business Event
    */
        PROCEDURE raise_business_event(x_return_status OUT NOCOPY VARCHAR2
    )
        IS
      l_parameter_list           wf_parameter_list_t;
        BEGIN

          IF (p_trx_type = 'SPLIT') THEN

                 wf_event.AddParameterToList(G_WF_ITM_SRC_CONTRACT_ID,p_chr_id,l_parameter_list);
                 wf_event.AddParameterToList(G_WF_ITM_DEST_CONTRACT_ID,p_new_chr_id,l_parameter_list);
                 wf_event.AddParameterToList(G_WF_ITM_TRX_DATE,fnd_date.date_to_canonical(p_trx_date),l_parameter_list);
                 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,G_KHR_PROCESS_SPLIT_CONTRACT,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
                                                                 x_return_status  => x_return_status,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data,
                                                                 p_event_name     => G_WF_EVT_KHR_SPLIT_REQ,
                                                                 p_parameters     => l_parameter_list);


     END IF;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;


    /*
    -- mvasudev, 08/30/2004
    -- END, PROCEDURE to enable Business Event
    */



  BEGIN -- main process begins here

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => G_PKG_NAME,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => G_API_TYPE,
                        x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (p_trx_type NOT IN ('REBOOK','SPLIT')) THEN
        okl_api.set_message(
                            G_APP_NAME,
                            G_LLA_INVALID_TRX_TYPE,
                            'TRX_TYPE',
                            p_trx_type
                           );
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF (p_trx_type = 'SPLIT') THEN
         --
         -- Check for securitization during split contract
         --
         check_contract_securitized(
                                    p_api_version   => p_api_version,
                                    p_init_msg_list => OKL_API.G_FALSE,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_chr_id        => p_chr_id,
                                    p_trx_date      => p_trx_date
                                   );

         IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
      END IF;

      IF (p_trx_type = 'REBOOK') THEN
         --akrangan start
         --If there are any Asset Location Transaction is
         --in progress for asset lines in the contract
         --Rebook will not allowed in that case.
         OPEN chk_asst_loc_khr_csr(p_chr_id);
         FETCH chk_asst_loc_khr_csr INTO l_rebook_allowed;
         CLOSE chk_asst_loc_khr_csr;
         IF l_rebook_allowed = 'N' THEN

	 OPEN contract_num_csr(p_chr_id);
         FETCH contract_num_csr INTO l_contract_number;
         CLOSE contract_num_csr;

         okl_api.set_message(
                             G_APP_NAME,
                             'OKL_TX_AST_LOC_RBK_NOTALLWED',
                             'CONTRACT_NUMBER',
                             l_contract_number
                            );

         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;
         --akrangan end
         validate_rebook_reason(
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                p_rebook_reason_code => p_reason_code
                               );

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;
      END IF;

      --
      -- Check for Transaction Date, it is mandetory
      --
      IF (p_trx_date IS NULL) THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_MISSING_TRX_DATE
                            );
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      --
      -- Transaction date should be within contract effectivity
      -- Bug# 2504598
      --
      OPEN con_eff_csr (p_chr_id);
      FETCH con_eff_csr INTO l_con_start_date,
                             l_con_end_date;
      CLOSE con_eff_csr;

      l_date_valid := 'N';
      OPEN check_date_csr (l_con_start_date,
                           l_con_end_date,
                           p_trx_date);

      FETCH check_date_csr INTO l_date_valid;
      CLOSE check_date_csr;

      IF (l_date_valid = 'N') THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_WRONG_TRX_DATE,
                             'START_DATE',
                             l_con_start_date,
                             'END_DATE',
                             l_con_end_date
                            );
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      /* Bug 4766555 : Code commented here and moved to
      -- smadhava Bug# 4542290 - 24-Aug-2005 - Added - Start
      IF (p_trx_type = G_REBOOK_TRX) THEN
        -- check if the rebook transaction is allowed for the contract for this rebook date
        OKL_K_RATE_PARAMS_PVT.check_rebook_allowed(
                                 p_api_version   => p_api_version
                               , p_init_msg_list => OKL_API.G_FALSE
                               , x_return_status => x_return_status
                               , x_msg_count     => x_msg_count
                               , x_msg_data      => x_msg_data
                               , p_chr_id        => p_chr_id
                               , p_rebook_date   => p_trx_date);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- end of check for rebook transaction
      -- smadhava Bug# 4542290 - 24-Aug-2005 - Added - End
      */

      populate_transaction_rec(
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               p_chr_id             => p_chr_id,
                               p_new_chr_id         => p_new_chr_id,
                               p_reason_code        => p_reason_code,
                               p_description        => p_description,
                               p_trx_date           => p_trx_date,
                               p_trx_type           => p_trx_type,
                               x_tcnv_rec           => l_tcnv_rec
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- Create Transaction Header only
      okl_trx_contracts_pub.create_trx_contracts(
                                                 p_api_version    => 1.0,
                                                 p_init_msg_list  => p_init_msg_list,
                                                 x_return_status  => x_return_status,
                                                 x_msg_count      => x_msg_count,
                                                 x_msg_data       => x_msg_data,
                                                 p_tcnv_rec       => l_tcnv_rec,
                                                 x_tcnv_rec       => l_out_tcnv_rec
                                                );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- smadhava Bug# 4542290 - 24-Aug-2005 - Added - Start
      -- apaul 4766555. Code moved here.
      IF (p_trx_type = G_REBOOK_TRX) THEN
        -- check if the rebook transaction is allowed for the contract for this rebook date
        OKL_K_RATE_PARAMS_PVT.check_rebook_allowed(
                                 p_api_version   => p_api_version
                               , p_init_msg_list => OKL_API.G_FALSE
                               , x_return_status => x_return_status
                               , x_msg_count     => x_msg_count
                               , x_msg_data      => x_msg_data
                               , p_chr_id        => p_chr_id
                               , p_rebook_date   => p_trx_date);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- end of check for rebook transaction
      -- smadhava Bug# 4542290 - 24-Aug-2005 - Added - End

      x_tcnv_rec := l_out_tcnv_rec;

       /*
       -- mvasudev, 08/30/2004
       -- Code change to enable Business Event
       */
        raise_business_event(x_return_status => x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

       /*
       -- mvasudev, 08/30/2004
       -- END, Code change to enable Business Event
       */

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END create_transaction;

------------------------------------------------------------------------------
-- PROCEDURE abandon_revisions
--
--  This procedure abandons created transaction and corresponding contracts
--
-- Calls:
-- Called By:  This API is called from 2 places -
--             1)  At the time of upgrade from 11i > r12, to cancel pending rebook transactions : OKLTXRBKUG.sql
--             2)  When rebook copy is abandoned from the UI
------------------------------------------------------------------------------
  PROCEDURE abandon_revisions(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rev_tbl            IN  rev_tbl_type,
                              p_contract_status    IN  VARCHAR2,
                              p_tsu_code           IN  VARCHAR2,
			      --akrangan added for ebtax rebook changes starts : these paramaters are sent by the upgrade script
			      p_source_trx_id      IN  NUMBER DEFAULT NULL ,
			      p_source_trx_name    IN  VARCHAR2 DEFAULT NULL
			      --akrangan added for ebtax rebook changes ends : these paramaters are sent by the upgrade script
                             ) IS

  l_api_name    VARCHAR2(17)    := 'abandon_revisions';
  l_proc_name   VARCHAR2(17)    := 'ABANDON_REVISIONS';
  l_api_version CONSTANT NUMBER := 1;
  i             NUMBER          := 0;

  l_rev_tbl         rev_tbl_type  := p_rev_tbl;
  x_tcnv_rec        tcnv_rec_type;

  l_chrv_rec        chrv_rec_type;
  x_chrv_rec        chrv_rec_type;

  --akrangan added for ebtax rebook changes starts
  l_source_trx_id    NUMBER;
  l_source_trx_name  VARCHAR2(150);
  l_source_table     VARCHAR2(30) := 'OKL_TRX_CONTRACTS';
  l_prbk_tcnv_rec    tcnv_rec_type;
  x_prbk_tcnv_rec    tcnv_rec_type;
  --akrangan added for ebtax rebook changes ends

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'BEFORE call ....');
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => G_PKG_NAME,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => G_API_TYPE,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    LOOP
      i := i + 1;

      l_chrv_rec.id       := l_rev_tbl(i).chr_id;
      l_chrv_rec.sts_code := p_contract_status;

      update_trx_status(
                        p_api_version    => l_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        p_chr_id         => l_rev_tbl(i).chr_id,
                        p_status         => p_tsu_code,
                        x_tcnv_rec       => x_tcnv_rec --record for the primary rep
                       );

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER Trx UPDATE status: '|| x_return_status);
      END IF;

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --akrangan ebtax rebook impacts starts
      IF ( p_source_trx_id IS NULL ) AND ( p_source_trx_name IS NULL ) THEN -- called from rebook abandon UI
        l_source_trx_id   := x_tcnv_rec.id;
        l_source_trx_name := 'Rebook';
      -- Bug 6379268
      ELSIF (p_source_trx_id IS NOT NULL) AND (p_source_trx_name IS NOT NULL) THEN --called from upgrade, copy contract was validated and PRBK trx exists
         l_source_trx_id   := p_source_trx_id;
         l_source_trx_name := p_source_trx_name;

         -- Cancel 'Pre-Rebook' transaction
         IF l_source_trx_name = 'Pre-Rebook' THEN
           l_prbk_tcnv_rec.id         := l_source_trx_id;
           l_prbk_tcnv_rec.tsu_code   := p_tsu_code;

           Okl_Trx_Contracts_Pub.update_trx_contracts(
             p_api_version   => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data,
             p_tcnv_rec      => l_prbk_tcnv_rec,
             x_tcnv_rec      => x_prbk_tcnv_rec
            );

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER Cancel Pre-Rebook transaction status: '|| x_return_status);
           END IF;

           IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
             RAISE Okc_Api.G_EXCEPTION_ERROR;
           END IF;
         END IF;
      ELSE
         -- p_source_trx_id IS NULL and p_source_trx_name IS NOT NULL
         -- called from upgrade script. rebook copy is created but not validated yet, hence PRBK trx does not exist
         l_source_trx_id := NULL;
         l_source_trx_name := NULL;
      END IF;

      -- Bug 6379268
      IF (l_source_trx_id IS NOT NULL) AND (l_source_trx_name IS NOT NULL) THEN
        ---cancel tax lines call
        OKL_PROCESS_SALES_TAX_PVT.cancel_document_tax(
                        p_api_version          => l_api_version,
                        p_init_msg_list        => p_init_msg_list,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data,
			p_source_trx_id        => l_source_trx_id,
			p_source_trx_name      => l_source_trx_name,
			p_source_table         => l_source_table
			);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER Canel Document Tax status: '|| x_return_status);
        END IF;

        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      --akrangan ebtax rebook impacts ends

      okl_okc_migration_pvt.update_contract_header(
                        p_api_version          => l_api_version,
                        p_init_msg_list        => p_init_msg_list,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data,
                        p_restricted_update    => 'F',
                        p_chrv_rec             => l_chrv_rec,
                        x_chrv_rec             => x_chrv_rec
                       );
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER Contract Header UPDATE status: '|| x_return_status);
      END IF;

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      okl_contract_status_pub.cascade_lease_status(
                        p_api_version          => l_api_version,
                        p_init_msg_list        => p_init_msg_list,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data,
                        p_chr_id               => l_chrv_rec.id
                       );
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER Contract Line UPDATE status: '|| x_return_status);
      END IF;

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


      EXIT WHEN (i >= l_rev_tbl.last);

    END LOOP;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END abandon_revisions;

------------------------------------------------------------------------------
-- PROCEDURE create_service_transaction
--
--  This procedure creates Transaction (LINK/DELINK) during service integration
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_service_transaction(
                          p_api_version        IN  NUMBER,
                          p_init_msg_list      IN  VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2,
                          p_lease_id           IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_service_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_description        IN  VARCHAR2,
                          p_trx_date           IN  DATE,
                          p_status             IN  VARCHAR2,
                          x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                         ) IS

  l_api_name    VARCHAR2(35)    := 'create_service_transaction';
  l_proc_name   VARCHAR2(35)    := 'CREATE_SERVICE_TRANSACTION';
  l_api_version CONSTANT NUMBER := 1;

  l_tcnv_rec        tcnv_rec_type;
  l_out_tcnv_rec    tcnv_rec_type;

  CURSOR try_csr IS
  SELECT id
  FROM   okl_trx_types_tl
  WHERE  LANGUAGE = 'US'
  AND    name     = 'Service Integration';

  CURSOR con_header_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT currency_code,
         authoring_org_id
  FROM   okl_k_headers_full_v
  WHERE  id = p_chr_id;

  l_try_id NUMBER;
  service_txn_failed EXCEPTION;
  --Added by dpsingh for LE Uptake
  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => G_PKG_NAME,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => G_API_TYPE,
                        x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      l_tcnv_rec := NULL;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER START...');
      END IF;
      --
      -- Check for Transaction Date, it is mandetory
      --
      IF (p_trx_date IS NULL) THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_MISSING_TRX_DATE
                            );
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Afer DATE CHECK');
      END IF;

      l_try_id := NULL;

      OPEN try_csr;
      FETCH try_csr INTO l_try_id;
      CLOSE try_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER getting try id');
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Try ID: '||l_try_id);
      END IF;

      l_tcnv_rec.try_id                    := l_try_id;
      l_tcnv_rec.tsu_code                  := p_status;
      l_tcnv_rec.description               := p_description;
      l_tcnv_rec.tcn_type                  := 'SER';
      l_tcnv_rec.khr_id                    := p_lease_id;      -- OKL Contract ID
      l_tcnv_rec.chr_id                    := p_service_id;      -- OKS Contract ID
      --l_tcnv_rec.khr_id_new                := p_new_chr_id;
      l_tcnv_rec.date_transaction_occurred := p_trx_date;
        --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_lease_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_lease_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
      FOR con_header_rec IN con_header_csr (p_lease_id)
      LOOP
         l_tcnv_rec.org_id        := con_header_rec.authoring_org_id;
         l_tcnv_rec.currency_code := con_header_rec.currency_code;
      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'BEFORE calling okl_trx_contracts_pub.create_trx_contracts');
      END IF;
      -- Create Transaction Header only
      okl_trx_contracts_pub.create_trx_contracts(
                                                 p_api_version    => 1.0,
                                                 p_init_msg_list  => p_init_msg_list,
                                                 x_return_status  => x_return_status,
                                                 x_msg_count      => x_msg_count,
                                                 x_msg_data       => x_msg_data,
                                                 p_tcnv_rec       => l_tcnv_rec,
                                                 x_tcnv_rec       => l_out_tcnv_rec
                                                );

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER calling okl_trx_contracts_pub.create_trx_contracts');
      END IF;

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_tcnv_rec := l_out_tcnv_rec;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done...');
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION

      WHEN service_txn_failed THEN
         IF try_csr%ISOPEN THEN
            CLOSE try_csr;
         END IF;
         x_return_status := OKL_API.G_RET_STS_ERROR;

      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END create_service_transaction;


------------------------------------------------------------------------------
-- PROCEDURE create_ppd_transaction
--
--  This procedure creates PPD Transaction initiated from customer service
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_ppd_transaction(
                          p_api_version        IN  NUMBER,
                          p_init_msg_list      IN  VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2,
                          p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_trx_date           IN  DATE,
                          p_trx_type           IN  VARCHAR2,
                          p_reason_code        IN  VARCHAR2,
                          x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                         ) IS

  l_api_name    VARCHAR2(35)    := 'create_ppd_transaction';
  l_proc_name   VARCHAR2(35)    := 'CREATE_PPD_TRANSACTION';
  l_api_version CONSTANT NUMBER := 1;

  l_tcnv_rec        tcnv_rec_type;
  l_out_tcnv_rec    tcnv_rec_type;

  CURSOR try_csr IS
  SELECT id
  FROM   okl_trx_types_tl
  WHERE  LANGUAGE = 'US'
  AND    name     = 'Principal Paydown';

  CURSOR con_header_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT currency_code,
         authoring_org_id
  FROM   okl_k_headers_full_v
  WHERE  id = p_chr_id;

  l_try_id NUMBER;
  ppd_txn_failed EXCEPTION;
  --Added by dpsingh for LE Uptake
  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => G_PKG_NAME,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => G_API_TYPE,
                        x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      l_tcnv_rec := NULL;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER START...');
      END IF;
      --
      -- Check for Transaction Date, it is mandetory
      --
      IF (p_trx_date IS NULL) THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_MISSING_TRX_DATE
                            );
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Afer DATE CHECK');
      END IF;

      l_try_id := NULL;

      OPEN try_csr;
      FETCH try_csr INTO l_try_id;
      IF try_csr%NOTFOUND THEN
         RAISE ppd_txn_failed;
      END IF;
      CLOSE try_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER getting try id');
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Try ID: '||l_try_id);
      END IF;

      l_tcnv_rec.try_id                    := l_try_id;
      l_tcnv_rec.tsu_code                  := 'ENTERED';
      l_tcnv_rec.description               := 'Principal Paydown';
      l_tcnv_rec.tcn_type                  := 'PPD';
      l_tcnv_rec.khr_id                    := p_chr_id;
      l_tcnv_rec.date_transaction_occurred := p_trx_date;
        --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_chr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
      FOR con_header_rec IN con_header_csr (p_chr_id)
      LOOP
         l_tcnv_rec.org_id        := con_header_rec.authoring_org_id;
         l_tcnv_rec.currency_code := con_header_rec.currency_code;
      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'BEFORE calling okl_trx_contracts_pub.create_trx_contracts');
      END IF;
      -- Create Transaction Header only
      okl_trx_contracts_pub.create_trx_contracts(
                                                 p_api_version    => 1.0,
                                                 p_init_msg_list  => p_init_msg_list,
                                                 x_return_status  => x_return_status,
                                                 x_msg_count      => x_msg_count,
                                                 x_msg_data       => x_msg_data,
                                                 p_tcnv_rec       => l_tcnv_rec,
                                                 x_tcnv_rec       => l_out_tcnv_rec
                                                );

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER calling okl_trx_contracts_pub.create_trx_contracts');
      END IF;

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_tcnv_rec := l_out_tcnv_rec;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done...');
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION

      WHEN ppd_txn_failed THEN
         IF try_csr%ISOPEN THEN
            CLOSE try_csr;
         END IF;
         x_return_status := OKL_API.G_RET_STS_ERROR;

      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END create_ppd_transaction;
END OKL_TRANSACTION_PVT;

/
