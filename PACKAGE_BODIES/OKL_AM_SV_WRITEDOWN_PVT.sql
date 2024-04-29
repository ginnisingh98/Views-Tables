--------------------------------------------------------
--  DDL for Package Body OKL_AM_SV_WRITEDOWN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SV_WRITEDOWN_PVT" AS
/* $Header: OKLRSVWB.pls 120.4 2006/11/22 18:45:11 rravikir noship $ */

-- Start of comments
--
-- Procedure Name  : create_salvage_value_trx
-- Description     : The main body of the package. This procedure gets a table of line ids along with the new
--                   salvage values as parameter. It then validates the new SV to make sure that it is less than
--                   the current SV and then creates  salvage value transactions in  OKL_TRX_ASSETS_V and
--                   OKL_TXL_ASSETS_V
-- Business Rules  :
-- Parameters      :  p_assets_tbl
-- Version         : 1.0
-- History         : SECHAWLA 03-JAN-03 2683876
--                      Added logic to populate currency code while creating/updating amounts in txl assets
--                   SECHAWLA 07-FEB-03 2789656
--                      Changed the sequence of validations so that the validation to check for a pending SVW
--                      transaction is done before all other validations.
-- End of comments


   PROCEDURE create_salvage_value_trx( p_api_version           IN  	NUMBER,
           			       p_init_msg_list         IN  	VARCHAR2,
           			       x_return_status         OUT 	NOCOPY VARCHAR2,
           			       x_msg_count             OUT 	NOCOPY NUMBER,
           			       x_msg_data              OUT 	NOCOPY VARCHAR2,
                                       p_assets_tbl            IN     assets_tbl_type,
                                       x_salvage_value_status  OUT    NOCOPY VARCHAR2) IS

   SUBTYPE   thpv_rec_type   IS  okl_trx_assets_pub.thpv_rec_type;
   SUBTYPE   tlpv_rec_type   IS  okl_txl_assets_pub.tlpv_rec_type;


   l_return_status                   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_overall_status                  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_record_status                   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

   l_api_name                        CONSTANT VARCHAR2(30) := 'create_salvage_value_trx';
   l_api_version                     CONSTANT NUMBER := 1;

   i                                 NUMBER := 0;
   l_asset_id                        NUMBER;
   l_asset_number                    VARCHAR2(15);
   l_description                     VARCHAR2(1995);
   l_old_salvage_value               NUMBER;
   l_original_cost                   NUMBER;
   l_current_units                   NUMBER;
   l_corporate_book                  VARCHAR2(70);
   l_dnz_chr_id                      NUMBER;
   l_try_id  			             okl_trx_types_v.id%TYPE;
   lp_thpv_rec                       thpv_rec_type;
   lx_thpv_rec                       thpv_rec_type;
   lp_tlpv_rec			             tlpv_rec_type;
   lx_tlpv_rec			             tlpv_rec_type;
   l_sysdate                         DATE;
   l_contract_number                 VARCHAR2(120);
   l_count                           NUMBER;

   --SECHAWLA 03-JAN-03 Bug # 2683876 : new declaration
   l_func_curr_code                  GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;

   -- This cursor fetches the asset lines from okx_asset_lines_v corresponding to the parent_line_id passed as
   -- input parameter
   CURSOR l_assetlinesv_csr(p_cle_id  NUMBER) IS
   SELECT to_number(l.asset_id) , l.asset_number, l.item_description, l.salvage_value, l.original_cost, l.current_units,
          l.corporate_book, l.dnz_chr_id, h.contract_number
   FROM   okx_asset_lines_v l, okc_k_headers_b h
   WHERE  l.dnz_chr_id = h.id
   AND    l.parent_line_id = p_cle_id;


   -- SECHAWLA 07-FEB-03 Bug # 2789656 : Changed the cursor to select asset_number instead of count(*)
   -- This cursor is used to check if a pending salvage value writedown transaction already exists for a financial asset.
   CURSOR l_assettrx_csr(p_kle_id NUMBER) IS
   SELECT l.asset_number
   FROM   OKL_TRX_ASSETS h, okl_txl_assets_v l
   WHERE  h.id = l.tas_id
   AND    h.tsu_code = 'ENTERED'
   AND    h.tas_type = 'FSC'
   AND    l.kle_id = p_kle_id;

   -- This cursor is used to check if an accepted termination quote exists for an asset line.
   CURSOR  l_quotes_csr(p_kle_id NUMBER) IS
   SELECT  l.asset_number
   FROM    okl_trx_quotes_b qh, okl_txl_quote_lines_b ql, okx_asset_lines_v l
   WHERE   qh.id = ql.qte_id
   AND     qh.qst_code = 'ACCEPTED'
   AND     ql.qlt_code = 'AMCFIA'
   AND     ql.kle_id  = l.parent_line_id
   AND     ql.kle_id = p_kle_id;

   -- RRAVIKIR Legal Entity Changes
   CURSOR  l_oklheaders_csr(cp_khr_id NUMBER) IS
   SELECT  legal_entity_id
   FROM    okl_k_headers
   WHERE   id = cp_khr_id;

   l_legal_entity_id    NUMBER;
   -- Legal Entity Changes End

   BEGIN

      l_record_status := OKL_API.G_RET_STS_SUCCESS;


      l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
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

      SELECT SYSDATE INTO l_sysdate FROM dual;

      IF p_assets_tbl.COUNT > 0 THEN


          okl_am_util_pvt.get_transaction_id(p_try_name         => 'Fixed Asset Salvage Change',
                                             x_return_status    => x_return_status,
                                             x_try_id           => l_try_id);

          IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
              -- Unable to find a transaction type for this transaction
              OKL_API.set_message(p_app_name    => 'OKL',
                          p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                          p_token1              => 'TRY_NAME',
                          p_token1_value        => 'Fixed Asset Salvage Change');
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;





         i := p_assets_tbl.FIRST;
         -- fetch the asset line information from okx_asset_lines_v for each cle_id in the input table,
         -- validate the old salvage value(in the view), new salvage value (in the input table) and then
         -- create salvage value writedown transactions (FSC/FSL) in OKL tables.
         LOOP


            IF p_assets_tbl(i).p_cle_id IS NULL OR p_assets_tbl(i).p_cle_id = OKL_API.G_MISS_NUM THEN
                l_record_status := OKL_API.G_RET_STS_ERROR;
                -- cle_id is required
                OKC_API.set_message( p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CLE_ID');
            ELSE
                -- SECHAWLA 07-FEB-03 Bug # 2789656 : Moved the following validation here in the beginning of the code
                -- Check if a pending transaction already exists for this financial asset
                OPEN  l_assettrx_csr(p_assets_tbl(i).p_cle_id);
                FETCH l_assettrx_csr INTO l_asset_number;
                IF l_assettrx_csr%FOUND THEN
                   l_record_status := OKL_API.G_RET_STS_ERROR;
                    -- Asset failed because a pending salvage value writedown transaction already exists for the financial asset
                    OKL_API.set_message(
                                            p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_SVW_TRX_EXISTS',
                                            p_token1        => 'ASSET_NUMBER',
                                            p_token1_value  => l_asset_number);
                ELSE


                    -- Check if an accepted termination quote exists for this line
                    OPEN  l_quotes_csr(p_assets_tbl(i).p_cle_id);
                    FETCH l_quotes_csr INTO l_asset_number;
                    IF l_quotes_csr%FOUND THEN
                       l_record_status := OKL_API.G_RET_STS_ERROR;
                       -- Can not change Salvage value for asset ASSET_NUMBER as an accepted termination quote exists for this asset.
                       OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_SVW_NOT_ALLOWED',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_asset_number);
                    ELSE

                       OPEN  l_assetlinesv_csr(p_assets_tbl(i).p_cle_id) ;
                       FETCH l_assetlinesv_csr INTO l_asset_id, l_asset_number, l_description, l_old_salvage_value,
                          l_original_cost, l_current_units, l_corporate_book, l_dnz_chr_id, l_contract_number;


                       IF  l_assetlinesv_csr%NOTFOUND THEN

                          l_record_status := OKL_API.G_RET_STS_ERROR;

                          -- asset_number is invalid
                          OKC_API.set_message( p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ASSET_NUMBER');




                       ELSIF p_assets_tbl(i).p_new_salvage_value IS NULL OR p_assets_tbl(i).p_new_salvage_value = OKL_API.G_MISS_NUM THEN

                           l_record_status := OKL_API.G_RET_STS_ERROR;
                           --Asset failed because the new Salvage Value is missing
                           OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_NEW_SALVAGE_VALUE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_asset_number);

                       ELSIF p_assets_tbl(i).p_new_salvage_value < 0  THEN

                           l_record_status := OKL_API.G_RET_STS_ERROR;
                           -- Asset failed because the new Salvage Value is negative
                           OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NEGATIVE_SALVAGE_VALUE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_asset_number);

                       ELSE



                           IF l_old_salvage_value IS NULL THEN
                               l_record_status := OKL_API.G_RET_STS_ERROR;
                               -- Asset failed because the old Salvage Value is missing
                               OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_OLD_SALVAGE_VALUE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_asset_number);

                           ELSE
                                IF p_assets_tbl(i).p_new_salvage_value < l_old_salvage_value THEN

                                    -- RRAVIKIR Legal Entity Changes
                                    OPEN l_oklheaders_csr(cp_khr_id  =>  l_dnz_chr_id);
                                    FETCH l_oklheaders_csr into l_legal_entity_id;
                                    CLOSE l_oklheaders_csr;

                                    IF (l_legal_entity_id is null or l_legal_entity_id = OKC_API.G_MISS_NUM) THEN
                                      l_record_status := OKL_API.G_RET_STS_ERROR;
                                        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                            p_msg_name     => g_required_value,
                                                            p_token1       => g_col_name_token,
                                                            p_token1_value => 'legal_entity_id');
                                        RAISE OKC_API.G_EXCEPTION_ERROR;
                                    ELSE
                                      lp_thpv_rec.legal_entity_id := l_legal_entity_id;
                                      lp_thpv_rec.tas_type := 'FSC';
                                      lp_thpv_rec.tsu_code := 'ENTERED';
                                      lp_thpv_rec.try_id   :=  l_try_id;
                                      lp_thpv_rec.date_trans_occurred := l_sysdate;
                                    END IF;
                                    -- Legal Entity Changes End

                                    -- create transaction header
                                    OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                                                p_api_version           => p_api_version,
                                                p_init_msg_list         => OKL_API.G_FALSE,
                                                x_return_status         => l_record_status,
                                                x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data,
                                                p_thpv_rec	        => lp_thpv_rec,
                                                x_thpv_rec		=> lx_thpv_rec);

                                    IF l_record_status = OKL_API.G_RET_STS_SUCCESS THEN

                                        --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
                                        l_func_curr_code := okl_am_util_pvt.get_functional_currency;
                                        lp_tlpv_rec.currency_code := l_func_curr_code;

                                        -- Create transaction Line
                                        lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
                                        lp_tlpv_rec.kle_id 			    := p_assets_tbl(i).p_cle_id;
                                        lp_tlpv_rec.line_number 		:= 1;
                                        lp_tlpv_rec.tal_type 		    := 'FSL';
                                        lp_tlpv_rec.asset_number 		:= l_asset_number;
                                        lp_tlpv_rec.description         := l_description;
                                        lp_tlpv_rec.old_salvage_value   := l_old_salvage_value;
                                        lp_tlpv_rec.salvage_value       := p_assets_tbl(i).p_new_salvage_value;
                                        lp_tlpv_rec.corporate_book 		:= l_corporate_book;
                                        lp_tlpv_rec.original_cost 		:= l_original_cost;
                                        lp_tlpv_rec.current_units 		:= l_current_units;
                                        lp_tlpv_rec.dnz_asset_id		:= l_asset_id;
                                        lp_tlpv_rec.dnz_khr_id 		    := l_dnz_chr_id;

                                        OKL_TXL_ASSETS_PUB.create_txl_asset_def(
                                                p_api_version           => p_api_version,
                                                p_init_msg_list         => OKL_API.G_FALSE,
                                                x_return_status         => l_record_status,
                                                x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data,
                                                p_tlpv_rec		        => lp_tlpv_rec,
                                                x_tlpv_rec		        => lx_tlpv_rec);
                                    END IF;

                                ELSIF p_assets_tbl(i).p_new_salvage_value = l_old_salvage_value THEN
                                    l_record_status := OKL_API.G_RET_STS_ERROR;
                                    -- Asset failed because the new Salvage Value is not lower than the old value.
                                    OKL_API.set_message( p_app_name      => 'OKL',
                                                 p_msg_name      => 'OKL_AM_SAME_SALVAGE_VALUE',
                                                 p_token1        => 'ASSET_NUMBER',
                                                 p_token1_value  => l_asset_number);
                                ELSE  -- if new sv > old sv

                                    l_record_status := OKL_API.G_RET_STS_ERROR;
                                    -- Asset failed because the new Salvage Value is not lower than the old value.
                                    OKL_API.set_message(
                                     p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_INVALID_SALVAGE_VALUE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_asset_number);




                                END IF;


                           END IF ;   --l_old_salvage_value is null
                       END IF;   -- end fetch
                       CLOSE l_assetlinesv_csr;
                    END IF;
                    CLOSE l_quotes_csr;
                END IF;
                CLOSE l_assettrx_csr;

            END IF;
            -- If it reaches this point for the current record, that means x_return_status is SUCCESS
            IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN
               IF l_record_status <> OKL_API.G_RET_STS_SUCCESS THEN
                  l_overall_status := OKL_API.G_RET_STS_ERROR;
               END IF;
            END IF;


            EXIT WHEN (i = p_assets_tbl.LAST);
            i := p_assets_tbl.NEXT(i);


         END LOOP;

         x_return_status := l_overall_status;

      END IF;


      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

      EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN


        IF l_assetlinesv_csr%ISOPEN THEN
           CLOSE l_assetlinesv_csr;
        END IF;

        IF l_quotes_csr%ISOPEN THEN
           CLOSE l_quotes_csr;
        END IF;

        -- SECHAWLA 07-FEB-03 Bug # 2789656 : Close the cursor
        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;

        -- RRAVIKIR Legal Entity Changes
        IF l_oklheaders_csr%ISOPEN THEN
          CLOSE l_oklheaders_csr;
        END IF;
        -- Legal Entity Changes End

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


        IF l_assetlinesv_csr%ISOPEN THEN
           CLOSE l_assetlinesv_csr;
        END IF;
        IF l_quotes_csr%ISOPEN THEN
           CLOSE l_quotes_csr;
        END IF;

        -- SECHAWLA 07-FEB-03 Bug # 2789656 : Close the cursor
        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;

        -- RRAVIKIR Legal Entity Changes
        IF l_oklheaders_csr%ISOPEN THEN
          CLOSE l_oklheaders_csr;
        END IF;
        -- Legal Entity Changes End

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

        IF l_assetlinesv_csr%ISOPEN THEN
           CLOSE l_assetlinesv_csr;
        END IF;
        IF l_quotes_csr%ISOPEN THEN
           CLOSE l_quotes_csr;
        END IF;

        -- SECHAWLA 07-FEB-03 Bug # 2789656 : Close the cursor
        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;

        -- RRAVIKIR Legal Entity Changes
        IF l_oklheaders_csr%ISOPEN THEN
          CLOSE l_oklheaders_csr;
        END IF;
        -- Legal Entity Changes End

        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
   END create_salvage_value_trx;
END OKL_AM_SV_WRITEDOWN_PVT;

/
