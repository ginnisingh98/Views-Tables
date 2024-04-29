--------------------------------------------------------
--  DDL for Package Body OKL_AM_PROCESS_RV_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_PROCESS_RV_TRX_PVT" AS
/* $Header: OKLRRVPB.pls 120.2.12010000.2 2009/08/05 13:03:45 rpillay ship $ */





  -- Start of comments
--
-- Procedure Name  : process_transactions_wrap
-- Description     : This procedure is used to execute OKL_AM_PROCESS_RV_TRX_PVT
--                   as a concurrent program. It has all the input parameters for
--                   OKL_AM_PROCESS_RV_TRX_PVT and 2 standard OUT parameters - ERRBUF and RETCODE
-- Business Rules  :
-- Parameters      :  p_khr_id                       - contract id
--                    p_kle_id                       - line id
--
--
-- Version         : 1.0
-- History         : SECHAWLA 16-JAN-03 Bug # 2754280
--                      Changed the app name from OKL to OKC for g_unexpected_error
-- End of comments

  PROCEDURE process_transactions_wrap(   ERRBUF                  OUT 	NOCOPY VARCHAR2,
                                         RETCODE                 OUT    NOCOPY VARCHAR2 ,
                                         p_api_version           IN  	NUMBER,
           		 	                     p_init_msg_list         IN  	VARCHAR2 ,
                                         p_khr_id                IN     NUMBER  ,
                                         p_kle_id                IN     VARCHAR2
           			            )    IS


   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);

   l_transaction_status  VARCHAR2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'process_transactions_wrap';
   l_total_count         NUMBER;
   l_processed_count     NUMBER;
   l_error_count         NUMBER;

   BEGIN

                         process_transactions(
                                p_api_version           => p_api_version,
           			            p_init_msg_list         => p_init_msg_list ,
           			            x_return_status         => l_return_status,
           			            x_msg_count             => l_msg_count,
           			            x_msg_data              => l_msg_data,
				                p_khr_id        	    => p_khr_id ,
                                p_kle_id                => TO_NUMBER(p_kle_id),
                                x_total_count           => l_total_count,
                                x_processed_count       => l_processed_count,
                                x_error_count           => l_error_count
                                );


                         -- Add couple of blank lines
                         fnd_file.new_line(fnd_file.log,2);
                         fnd_file.new_line(fnd_file.output,2);




                        fnd_file.new_line(fnd_file.log,2);
                        fnd_file.new_line(fnd_file.output,2);

                        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                           fnd_file.put_line(fnd_file.log, 'MASS REBOOK Process Failed, None of the transactions got processed');
                           fnd_file.put_line(fnd_file.output, 'MASS REBOOK Process Failed, None of the transactions got processed');
                        END IF;

                        IF l_total_count = 0 THEN
                            fnd_file.put_line(fnd_file.log, 'There were no Residual Value Writedown transactions to process.');
                            fnd_file.put_line(fnd_file.output,'There were no Residual Value Writedown transactions to process.');
                        ELSE

                            fnd_file.put_line(fnd_file.log, 'Total Transactions : '||l_total_count);
                            fnd_file.put_line(fnd_file.log, 'Transactions Processed Successfully : '||l_processed_count);
                            fnd_file.put_line(fnd_file.log, 'Transactions Failed : '||l_error_count);

                            fnd_file.put_line(fnd_file.output, 'Total Transactions : '||l_total_count);
                            fnd_file.put_line(fnd_file.output, 'Transactions Processed Successfully : '||l_processed_count);
                            fnd_file.put_line(fnd_file.output, 'Transactions Failed : '||l_error_count);

                        END IF;




       EXCEPTION
           WHEN OTHERS THEN
                -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
                OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

 END process_transactions_wrap;




  -- Start of comments
--
-- Procedure Name  : process_transactions
-- Description     : This procedure is used to process Residual Value Writedown Transactions
-- Business Rules  :
-- Parameters      :  p_khr_id                       - contract id
--                    p_kle_id                       - line id
--                    x_total_count                  - Total number of transactions
--                    x_processed_count              - Number of transactions processed
--                    x_error_count                  - Number of transactions Errored out
-- Version         : 1.0
-- End of comments

  PROCEDURE process_transactions(
                                p_api_version           IN  	NUMBER,
           		 	            p_init_msg_list         IN  	VARCHAR2 ,
           			            x_return_status         OUT 	NOCOPY VARCHAR2,
           			            x_msg_count             OUT 	NOCOPY NUMBER,
           			            x_msg_data              OUT 	NOCOPY VARCHAR2,
                                p_khr_id 		        IN 	    NUMBER ,
                                p_kle_id                IN      NUMBER ,
                                x_total_count           OUT     NOCOPY NUMBER,
                                x_processed_count       OUT     NOCOPY NUMBER,
                                x_error_count           OUT     NOCOPY NUMBER)    IS


   SUBTYPE   thpv_rec_type          IS  okl_trx_assets_pub.thpv_rec_type;
   SUBTYPE   rbk_tbl_type           IS  okl_mass_rebook_pub.rbk_tbl_type;
   SUBTYPE   strm_lalevl_tbl_type   IS  okl_mass_rebook_pub.strm_lalevl_tbl_type;


   lp_thpv_rec                  thpv_rec_type;
   lx_thpv_rec                  thpv_rec_type;
   l_total_count                NUMBER;
   l_sysdate                    DATE;
   l_strm_lalevl_empty_tbl      strm_lalevl_tbl_type  ;
   l_rbk_tbl                    rbk_tbl_type ;
   lx_error_rec                 OKL_API.error_rec_type;
   l_msg_idx                    INTEGER := FND_MSG_PUB.G_FIRST;

   l_return_status              VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name                   CONSTANT VARCHAR2(30) := 'process_transactions';


   l_method_code		        fa_methods.method_code%TYPE;
   l_fa_cost                    NUMBER;
   l_fa_salvage_value           NUMBER;
   l_delta_cost                 NUMBER;
   l_delta_salvage_value        NUMBER;
   l_api_version                CONSTANT NUMBER := 1;
   l_transaction_status         VARCHAR2(1);
   l_process_count              NUMBER;
   l_count                      NUMBER;

   -- This cursor is used to get all active Residual Value Writedown transactions from OKL tables
   CURSOR l_assettrx_csr(p_sysdate  DATE) IS
   SELECT h.id, h.tas_type, date_trans_occurred, depreciate_yn, dnz_asset_id, corporate_book, in_service_date,
          deprn_method,life_in_months, nvl(depreciation_cost,0) depreciation_cost , asset_number, old_residual_value,
          new_residual_value, kle_id, dnz_khr_id, contract_number, sts_code
   FROM   OKL_TRX_ASSETS h, okl_txl_assets_v l, okc_k_headers_b khr
   WHERE  h.id = l.tas_id
   AND    h.tsu_code NOT IN  ('PROCESSED')
   AND    h.tas_type = 'ARC'
   AND    khr.id = l.dnz_khr_id
   AND    h.date_trans_occurred <= p_sysdate
   AND    (
             --  all 2 parameter values are provided
            ( p_khr_id IS NOT NULL  AND p_kle_id IS NOT NULL AND
              l.dnz_khr_id = p_khr_id AND l.kle_id = p_kle_id)
            OR
            -- none of the parameter values are provided
            ( p_khr_id IS NULL AND p_kle_id IS NULL)
            OR
            -- contract Id is provided,  kle_id not provided
            (p_khr_id IS NOT NULL AND l.dnz_khr_id = p_khr_id AND p_kle_id IS NULL)
            OR
            -- contract Id is not provided,  kle_id is provided
            (p_khr_id IS NULL AND p_kle_id IS NOT NULL AND l.kle_id = p_kle_id)

          )
   ORDER BY h.last_update_date;


   -- This cursor is used to check if an accepted termination quote exists for a contract.
   CURSOR l_quotes_csr(p_khr_id NUMBER) IS
   SELECT count(*)
   FROM   okl_trx_quotes_b
   WHERE  qst_code = 'ACCEPTED'
   AND    khr_id = p_khr_id;




   BEGIN

      l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;



      SELECT SYSDATE INTO l_sysdate  FROM DUAL;


      l_total_count := 0;
      l_process_count := 0;

      -- loop thru all the transactions in the OKL tables and process them
      FOR l_assettrx_rec IN l_assettrx_csr(l_sysdate) LOOP

          l_transaction_status  :=  OKC_API.G_RET_STS_SUCCESS;
          l_total_count := l_total_count + 1;



          IF l_assettrx_rec.dnz_khr_id IS NULL OR l_assettrx_rec.dnz_khr_id = OKL_API.G_MISS_NUM THEN
             -- Residual Value Writedown transaction could not be processed for asset ASSET_NUMBER because the Contract Id  is missing.
             OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_KHR_REQUIRED',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_assettrx_rec.asset_number);
             l_transaction_status  := OKC_API.G_RET_STS_ERROR;

          ELSIF l_assettrx_rec.sts_code <> 'BOOKED' THEN
             -- Residual Value Writedown transaction could not be processed for asset ASSET_NUMBER because the Contract is not booked
             OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_KHR_NOT_BOOKED',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_assettrx_rec.asset_number,
                                     p_token2        => 'CONTRACT_NUMBER',
                                     p_token2_value  => l_assettrx_rec.contract_number);

             l_transaction_status  := OKC_API.G_RET_STS_ERROR;

          ELSE

             OPEN  l_quotes_csr(l_assettrx_rec.dnz_khr_id);
             FETCH l_quotes_csr INTO l_count;
             CLOSE l_quotes_csr;

             IF l_count > 0 THEN
                --Can not process Residual Value Writedown transaction for asset ASSET_NUMBER as an accepted termination quote exists for the contract CONTRACT_NUMBER.
                OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RVW_NOT_PROCESSED',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_assettrx_rec.asset_number,
                                     p_token2        => 'CONTRACT_NUMBER',
                                     p_token2_value  => l_assettrx_rec.contract_number);

                l_transaction_status  := OKC_API.G_RET_STS_ERROR;


             ELSE

               --Bug# 8756653
               -- Check if contract has been upgraded for effective dated rebook
               OKL_LLA_UTIL_PVT.check_rebook_upgrade
               (p_api_version     => p_api_version,
                p_init_msg_list   => OKC_API.G_FALSE,
                x_return_status   => l_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => l_assettrx_rec.dnz_khr_id);

               IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                 l_transaction_status  := OKC_API.G_RET_STS_ERROR;

               ELSE

                IF l_assettrx_rec.new_residual_value IS NULL OR l_assettrx_rec.new_residual_value = OKL_API.G_MISS_NUM THEN
                    --Residual Value Writedown transaction could not be processed for asset ASSET_NUMBER because the new residual value is missing.
                    OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RV_REQUIRED',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_assettrx_rec.asset_number);

                    l_transaction_status  := OKC_API.G_RET_STS_ERROR;
                ELSE

                    l_rbk_tbl(1).khr_id := l_assettrx_rec.dnz_khr_id;
                    l_rbk_tbl(1).kle_id := l_assettrx_rec.kle_id;

                    okl_mass_rebook_pub.apply_mass_rebook(
                              p_api_version        => p_api_version,
                              p_init_msg_list      => OKC_API.G_FALSE,
                              x_return_status      => l_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              p_rbk_tbl            => l_rbk_tbl,
                              p_deprn_method_code  => NULL,
                              p_in_service_date    => NULL,
                              p_life_in_months     => NULL,
                              p_basic_rate         => NULL,
                              p_adjusted_rate      => NULL,
                              p_residual_value     => l_assettrx_rec.new_residual_value,
                              p_strm_lalevl_tbl    => l_strm_lalevl_empty_tbl);


                    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                        --  Residual Value Writedown transaction could not be processed for asset ASSET_NUMBER.
                        OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_RVP_TRANS_FAILED',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  l_assettrx_rec.asset_number);
                        l_transaction_status  := l_return_status;
                    ELSE
                        -- update the staus (tsu_code) in okl_trx_assets_v
                        lp_thpv_rec.id  := l_assettrx_rec.id;
                        lp_thpv_rec.tsu_code := 'PROCESSED';
                        OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => l_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

                        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                            -- Transaction status STATUS could not be updated in OKL for asset ASSET_NUMBER
                            OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_TRXASSET_UPD_FAILED',
                                  p_token1        => 'STATUS',
                                  p_token1_value  => 'PROCESSED',
                                  p_token2        =>  'ASSET_NUMBER',
                                  p_token2_value  =>  l_assettrx_rec.asset_number);
                        ELSE
                            l_process_count := l_process_count + 1;
                            -- Residual Value Writedown transaction processed successfully for asset ASSET_NUMBER.
                            OKC_API.set_message(
                                  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_RVW_PROCESSED',
                                  p_token1        => 'ASSET_NUMBER',
                                  p_token1_value  => l_assettrx_rec.asset_number);

                            -- Old Residual Value :
                            OKC_API.set_message(
                                  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_OLD_RESIDUAL_VALUE',
                                  p_token1        => 'OLD_RV',
                                  p_token1_value  => l_assettrx_rec.old_residual_value);

                            -- New Residual Value :
                            OKC_API.set_message(
                                  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_NEW_RESIDUAL_VALUE',
                                  p_token1        => 'NEW_RV',
                                  p_token1_value  => l_assettrx_rec.new_residual_value);
                        END IF;
                    END IF;
                END IF;
               END IF;
             END IF;
          END IF;

         IF l_transaction_status <> OKC_API.G_RET_STS_SUCCESS THEN
            -- update the staus (tsu_code) in okl_trx_assets_v
            lp_thpv_rec.id  := l_assettrx_rec.id;
            lp_thpv_rec.tsu_code := 'ERROR';
            OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => l_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            -- Transaction status STATUS could not be updated in OKL for asset ASSET_NUMBER
                OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      =>  'OKL_AM_TRXASSET_UPD_FAILED',
                                  p_token1        =>  'STATUS',
                                  p_token1_value  =>  'ERROR',
                                  p_token2        =>  'ASSET_NUMBER',
                                  p_token2_value  =>  l_assettrx_rec.asset_number);
            END IF;
         END IF;

         -- Print the messages from the stack

         -- The following piece of code has been moved from procedure process_transactions_wrap to this procedure,
         -- to address the problem in the bug 2491164, where we loose messages after call to mass rebook API.
         -- Printing the message stack after each call to Mass Rebook helps prevent that problem.

         fnd_msg_pub.reset;
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

                EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG) OR (lx_error_rec.msg_count IS NULL));
                l_msg_idx := FND_MSG_PUB.G_NEXT;
        END LOOP;

        -- This explicit deletion of messages is required for those contracts in the loop which fail validations
        -- before the call to mass rebook api. Without the following reset statement, error messages for those contarcts
        -- will be printed more than once.

        --OKL_API.init_msg_list(p_init_msg_list => OKL_API.G_TRUE);
        fnd_msg_pub.delete_msg;


      END LOOP;



      x_total_count := l_total_count;
      x_processed_count := l_process_count;
      x_error_count := l_total_count - l_process_count;

      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

      EXCEPTION

      WHEN OKC_API.G_EXCEPTION_ERROR THEN

       IF l_assettrx_csr%ISOPEN THEN
         CLOSE l_assettrx_csr;
       END IF;
       IF l_quotes_csr%ISOPEN THEN
         CLOSE l_quotes_csr;
       END IF;
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

       IF l_assettrx_csr%ISOPEN THEN
         CLOSE l_assettrx_csr;
       END IF;
       IF l_quotes_csr%ISOPEN THEN
         CLOSE l_quotes_csr;
       END IF;
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN

       IF l_assettrx_csr%ISOPEN THEN
         CLOSE l_assettrx_csr;
       END IF;
       IF l_quotes_csr%ISOPEN THEN
         CLOSE l_quotes_csr;
       END IF;
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );


   END process_transactions;


END;

/
