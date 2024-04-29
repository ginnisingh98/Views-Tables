--------------------------------------------------------
--  DDL for Package Body OKL_REV_LOSS_PROV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REV_LOSS_PROV_PVT" AS
/* $Header: OKLRRPVB.pls 120.8.12010000.2 2008/08/28 22:57:26 sgiyer ship $ */

 G_PRIMARY   CONSTANT VARCHAR2(200) := 'PRIMARY';

   -- this procedure reverses specific loss provision,general loss provision or both transactions
  PROCEDURE REVERSE_LOSS_PROVISIONS (
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_lprv_rec             IN  lprv_rec_type)

  IS
  l_return_status          VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;

  /* variables */
  l_api_name               CONSTANT VARCHAR2(40) := 'REVERSE_LOSS_PROVISIONS';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_source_table           CONSTANT OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
  l_cntrct_id              OKL_K_HEADERS_FULL_V.ID%TYPE;
  l_sysdate                DATE := SYSDATE;
  l_reversal_date          DATE;
  l_COUNT                  NUMBER :=0;
  /* record and table structure variables */
  l_tcnv_rec               OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  x_tclv_tbl               OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
  l_tcnv_tbl               OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
  x_tcnv_tbl               OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
  l_source_id_tbl          OKL_REVERSAL_PUB.source_id_tbl_type;
--
  TYPE t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  l_trx_date_tbl	 t_date;
--
  -- Cursor to select transaction headers for reversal
  CURSOR reverse_trx_csr(p_khr_id NUMBER, p_tcn_type VARCHAR2) IS
  SELECT id, date_transaction_occurred, transaction_date
  FROM OKL_TRX_CONTRACTS
  WHERE khr_id = p_khr_id
  AND tsu_code = 'PROCESSED'
  AND tcn_type = p_tcn_type
  AND representation_type = G_PRIMARY;

  -- Cursor to select transaction lines for reversal
  CURSOR reverse_txl_csr(p_khr_id NUMBER, p_tcn_id NUMBER, p_tcn_type VARCHAR2) IS
  SELECT txl.id, txl.amount, txl.currency_code
  FROM OKL_TXL_CNTRCT_LNS txl, OKL_TRX_CONTRACTS trx
  WHERE trx.khr_id = p_khr_id
  AND txl.tcn_id = trx.id
  AND txl.tcn_id = p_tcn_id --trx.id
  AND trx.tsu_code = 'PROCESSED'
  AND trx.tcn_type = p_tcn_type
  AND trx.representation_type = G_PRIMARY;

  -- Cursor to select all transaction headers for reversal
  CURSOR reverse_all_trx_csr(p_khr_id NUMBER) IS
  SELECT id, date_transaction_occurred, transaction_date
  FROM OKL_TRX_CONTRACTS
  WHERE khr_id = p_khr_id
  AND tsu_code = 'PROCESSED'
  AND (tcn_type = 'PSP' OR tcn_type = 'PGL')
  AND representation_type = G_PRIMARY;

  -- Cursor to select all transaction lines for reversal
  CURSOR reverse_all_txl_csr(p_khr_id NUMBER, p_tcn_id NUMBER) IS
  SELECT txl.id, txl.amount, txl.currency_code
  FROM OKL_TXL_CNTRCT_LNS txl, OKL_TRX_CONTRACTS trx
  WHERE trx.khr_id = p_khr_id
  AND txl.tcn_id = trx.id
  AND txl.tcn_id = p_tcn_id --trx.id
  AND trx.tsu_code = 'PROCESSED'
  AND (trx.tcn_type = 'PSP' OR trx.tcn_type = 'PGL')
  AND trx.representation_type = G_PRIMARY;

  -- Cursor to select the contract number for the given contract id
  CURSOR contract_num_csr (p_ctr_num VARCHAR2) IS
  SELECT  id
  FROM OKC_K_HEADERS_ALL_B
  WHERE CONTRACT_NUMBER = p_ctr_num;

  BEGIN

       l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       /* validate input record parameters */
       IF (p_lprv_rec.cntrct_num IS NULL) THEN
           Okl_Api.set_message(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_REV_LPV_CNTRCT_ERROR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- get the contract number
       OPEN contract_num_csr(p_lprv_rec.cntrct_num);
       FETCH contract_num_csr INTO l_cntrct_id;
         IF contract_num_csr%NOTFOUND THEN
		   CLOSE contract_num_csr;
           Okl_Api.set_message(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       CLOSE contract_num_csr;

       /* validate input record parameters */
       IF (p_lprv_rec.reversal_type IS NULL) THEN
         -- Open reverse trx csr all for update of transaction header
         --Bug 6961282. Used l_COUNT variable instead of cursor percent rowcount
         FOR l_reverse_trx_csr IN reverse_all_trx_csr(l_cntrct_id)
         LOOP
           l_tcnv_tbl(l_COUNT).id := l_reverse_trx_csr.id;
           l_trx_date_tbl(l_COUNT) := l_reverse_trx_csr.date_transaction_occurred;
           l_tcnv_tbl(l_COUNT).transaction_date := l_reverse_trx_csr.transaction_date;
           l_COUNT := l_COUNT+1;
         END LOOP;
       ELSIF (p_lprv_rec.reversal_type IN ('PSP','PGL')) THEN
           -- Open reverse trx csr for update of transaction header
           FOR l_reverse_trx_csr IN reverse_trx_csr(l_cntrct_id, p_lprv_rec.reversal_type)
           LOOP
             l_tcnv_tbl(l_COUNT).id := l_reverse_trx_csr.id;
             l_trx_date_tbl(l_COUNT) := l_reverse_trx_csr.date_transaction_occurred;
             l_tcnv_tbl(l_COUNT).transaction_date := l_reverse_trx_csr.transaction_date;
             l_COUNT := l_COUNT+1;
           END LOOP;
       ELSE
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_REV_LPV_TYPE_ERROR');
       END IF;

       l_COUNT :=0;

/* -- Bug 6194225 and 6194204 .. Reversals should be done by the transaction
      and cannot be the same for all loss provision transactions.
	   IF p_lprv_rec.reversal_date IS NULL
	      OR p_lprv_rec.reversal_date = OKL_API.G_MISS_DATE THEN
         l_reversal_date := l_sysdate;
       ELSE
         l_reversal_date := p_lprv_rec.reversal_date;
       END IF;
*/

       IF l_tcnv_tbl.COUNT > 0 THEN
       -- proceed only if records found for reversal

/* moved this logic down to process by tcn_id .. for bugs 6194225 and 6194204
         IF p_lprv_rec.reversal_type IS NOT NULL THEN
         -- Open reverse txl cursor to find out transaction line id's for reversal
           FOR l_reverse_txl_csr IN reverse_txl_csr(l_cntrct_id, p_lprv_rec.reversal_type)
           LOOP
             l_source_id_tbl(reverse_txl_csr%ROWCOUNT) := l_reverse_txl_csr.id;
           END LOOP;
         ELSE
         -- Open reverse all txl cursor to find out transaction line id's for reversal
           FOR l_reverse_txl_csr IN reverse_all_txl_csr(l_cntrct_id)
           LOOP
             l_source_id_tbl(reverse_all_txl_csr%ROWCOUNT) := l_reverse_txl_csr.id;
           END LOOP;
         END IF;
*/
       -- Build the transaction record for update
       FOR i IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
       LOOP
         l_tcnv_tbl(i).tsu_code := 'CANCELED';
         --l_tcnv_tbl(i).canceled_date :=l_reversal_date; -- Bugs 6194225 and 6194204 .. logic below

	   IF p_lprv_rec.reversal_date IS NULL OR p_lprv_rec.reversal_date = OKL_API.G_MISS_DATE THEN
	      l_reversal_date := GREATEST(TRUNC(SYSDATE), l_trx_date_tbl(i));
	   ELSE
	      l_reversal_date := GREATEST(l_trx_date_tbl(i), p_lprv_rec.reversal_date);
	   END IF;

	   l_tcnv_tbl(i).canceled_date :=l_reversal_date;

       END LOOP;

-- New code to process reversals by tcn_id .. bugs 6194225 and 6194204
	   FOR i IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST LOOP
           IF p_lprv_rec.reversal_type IS NOT NULL THEN
           -- Open reverse txl cursor to find out transaction line id's for reversal
              FOR l_reverse_txl_csr IN reverse_txl_csr(l_cntrct_id, l_tcnv_tbl(i).id, p_lprv_rec.reversal_type)
              LOOP
                l_source_id_tbl(l_COUNT) := l_reverse_txl_csr.id;
                l_COUNT := l_COUNT+1;
              END LOOP;
           ELSE
           -- Open reverse all txl cursor to find out transaction line id's for reversal
             FOR l_reverse_txl_csr IN reverse_all_txl_csr(l_cntrct_id, l_tcnv_tbl(i).id)
             LOOP
               l_source_id_tbl(l_COUNT) := l_reverse_txl_csr.id;
               l_COUNT:=l_COUNT+1;
             END LOOP;
           END IF;

         -- reverse accounting entries
            Okl_Reversal_Pub.REVERSE_ENTRIES(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => l_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_source_table => l_source_table,
                          p_acct_date => l_tcnv_tbl(i).canceled_date, -- l_reversal_date,
                          p_source_id_tbl => l_source_id_tbl);

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               Okl_Api.set_message(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                                   p_token1       => g_contract_number_token,
                                   p_token1_value => p_lprv_rec.cntrct_num);
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               Okl_Api.set_message(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                                   p_token1       => g_contract_number_token,
                                   p_token1_value => p_lprv_rec.cntrct_num);
             END IF;

	    END LOOP; -- new logic for reversing by tcn_id.

       --Call the transaction public api to update tsu_code
       Okl_Trx_Contracts_Pub.update_trx_contracts
                         (p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => l_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_tcnv_tbl => l_tcnv_tbl,
                          x_tcnv_tbl => x_tcnv_tbl);

       -- store the highest degree of error
       IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_lprv_rec.cntrct_num);
           RAISE OKL_API.G_EXCEPTION_ERROR;
         ELSE
         -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_lprv_rec.cntrct_num);
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;
       END IF;
       END IF; -- for if l_tcnv_tbl.count > 0 condition

       --SGIYER - MGAAP Bug 7263041
       IF x_tcnv_tbl.COUNT > 0 THEN

          OKL_MULTIGAAP_ENGINE_PVT.REVERSE_SEC_REP_TRX
                         (p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => l_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_tcnv_tbl => x_tcnv_tbl);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

       END IF; -- for if xcnv_tbl.count > 0 condition

       -- set the return status
       x_return_status := l_return_status;

       OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END REVERSE_LOSS_PROVISIONS;

   -- this procedure reverses specific loss provision,general loss provision or both transactions
  PROCEDURE REVERSE_LOSS_PROVISIONS (
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_lprv_tbl             IN  lprv_tbl_type)
  IS

  /* variables */
  l_api_name               CONSTANT VARCHAR2(40) := 'REVERSE_LOSS_PROVISIONS';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_return_status          VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

       l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- call recrod level implementation in loop
       IF p_lprv_tbl.COUNT > 0 THEN
	   FOR i in p_lprv_tbl.FIRST..p_lprv_tbl.LAST
	   LOOP
	     REVERSE_LOSS_PROVISIONS (
                           p_api_version    => p_api_version
                          ,p_init_msg_list  => p_init_msg_list
                          ,x_return_status  => l_return_status
                          ,x_msg_count      => x_msg_count
                          ,x_msg_data       => x_msg_data
                          ,p_lprv_rec       => p_lprv_tbl(i));

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END LOOP;
       END IF; -- IF p_lprv_tbl.COUNT > 0 THEN
       -- set the return status
       x_return_status := l_return_status;

       OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END REVERSE_LOSS_PROVISIONS;



END OKL_REV_LOSS_PROV_PVT;

/
