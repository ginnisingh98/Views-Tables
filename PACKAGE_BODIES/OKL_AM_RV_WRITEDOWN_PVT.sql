--------------------------------------------------------
--  DDL for Package Body OKL_AM_RV_WRITEDOWN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_RV_WRITEDOWN_PVT" AS
/* $Header: OKLRRVWB.pls 120.4.12010000.2 2009/06/02 10:47:42 racheruv ship $ */

-- Start of comments
--
-- Procedure Name  : create_residual_value_trx
-- Description     : The main body of the package. This procedure gets a table of line ids along with the new
--                   residual values as parameter. It then validates the new RV to make sure that it is less than
--                   the current RV and then creates  residual value transactions in  OKL_TRX_ASSETS_V and
--                   OKL_TXL_ASSETS_V
-- Business Rules  :
-- Parameters      :  p_assets_tbl
-- History         : SECHAWLA  24-DEC-02 : Bug # 2726739
--                   Added logic to store currency codes and conversion factors
-- Version         : 1.0
-- History         : SECHAWLA 07-FEB-03 2789656
--                      Changed the sequence of validations so that the validation to check for a pending RVW
--                      transaction is done before all other validations.
-- End of comments


   PROCEDURE create_residual_value_trx(    p_api_version           IN  	NUMBER,
           			                 p_init_msg_list         IN  	VARCHAR2 ,
           			                 x_return_status         OUT 	NOCOPY VARCHAR2,
           			                 x_msg_count             OUT 	NOCOPY NUMBER,
           			                 x_msg_data              OUT 	NOCOPY VARCHAR2,
                                     p_assets_tbl            IN     assets_tbl_type,
                                     x_residual_value_status OUT    NOCOPY  VARCHAR2) IS -- this flag is redundant,
                                                                                  -- we are keeping it for the time
                                                                                  -- being to avoid
                                                                                  -- rosetta regeneration

   SUBTYPE   thpv_rec_type   IS  okl_trx_assets_pub.thpv_rec_type;
   SUBTYPE   tlpv_rec_type   IS  okl_txl_assets_pub.tlpv_rec_type;


   l_return_status                   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_overall_status                  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_record_status                   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;


   l_api_name                        CONSTANT VARCHAR2(30) := 'create_residual_value_trx';
   l_api_version                     CONSTANT NUMBER := 1;

   i                                 NUMBER := 0;
   l_name                            VARCHAR2(150);
   l_description                     VARCHAR2(1995);
   l_old_residual_value              NUMBER;
   l_oec                             NUMBER;
   l_chr_id                          NUMBER;
   l_try_id  			             okl_trx_types_v.id%TYPE;
   lp_thpv_rec                       thpv_rec_type;
   lx_thpv_rec                       thpv_rec_type;
   lp_tlpv_rec			             tlpv_rec_type;
   lx_tlpv_rec			             tlpv_rec_type;
   l_sysdate                         DATE;
   l_sts_code                        VARCHAR2(30);
   l_contract_number                 VARCHAR2(120);
   l_count                           NUMBER;

    --SECHAWLA  Bug # 2726739 : new declarations
    l_func_curr_code             GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
    l_contract_curr_code         okc_k_headers_b.currency_code%TYPE;
    lx_contract_currency         okl_k_headers_full_v.currency_code%TYPE;
    lx_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
    lx_currency_conversion_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
    lx_currency_conversion_date  okl_k_headers_full_v.currency_conversion_date%TYPE;
    lx_converted_amount          NUMBER;


   -- This cursor selects line item fields and contract status for a given line ID
   CURSOR  l_linesfullv_csr(p_id  NUMBER) IS
   SELECT  l.name, l.item_description, l.residual_value, l.oec, l.chr_id, h.contract_number
   FROM    okl_k_lines_full_v l, okc_k_headers_b h
   WHERE   l.chr_id = h.id
   AND     l.id = p_id;
   -- we can use chr_id in the above cursor as we will be pulling data only for the TOP LINE (Financial Asset) which
   -- will always have the chr_id.

   -- This cursor is used to check if a pending residual value writedown transaction already exists for a contract.
   -- Included ERROR for Bug# 7014234
   CURSOR l_assettrx_csr(p_khr_id NUMBER) IS
   SELECT count(*)
   FROM   OKL_TRX_ASSETS h, okl_txl_assets_v l
   WHERE  h.id = l.tas_id
   AND    h.tsu_code IN ('ENTERED', 'ERROR')
   AND    h.tas_type = 'ARC'
   AND    l.dnz_khr_id = p_khr_id;

   -- This cursor is used to check if an accepted termination quote exists for an asset line.
   CURSOR  l_quotes_csr(p_kle_id NUMBER) IS
   SELECT  l.name
   FROM    okl_trx_quotes_b qh, okl_txl_quote_lines_b ql, okl_k_lines_full_v l
   WHERE   qh.id = ql.qte_id
   AND     qh.qst_code = 'ACCEPTED'
   AND     ql.qlt_code = 'AMCFIA'
   AND     ql.kle_id  = l.id
   AND     ql.kle_id = p_kle_id;

   -- RRAVIKIR Legal Entity Changes
   CURSOR  l_oklheaders_csr(cp_khr_id NUMBER) IS
   SELECT  legal_entity_id
   FROM    okl_k_headers
   WHERE   id = cp_khr_id;

   l_legal_entity_id    NUMBER;
   -- Legal Entity Changes End

   -- Begin -- Check the contract term to allow RV updates.Bug# 7014234
   CURSOR c_contract_date_csr(p_chr_id  IN NUMBER)IS
   SELECT start_date,
          end_date
   FROM okc_k_headers_b
   WHERE id = p_chr_id;

   chr_rec  c_contract_date_csr%ROWTYPE;
   l_icx_date_format    varchar2(240);
   -- End -- Check the contract term to allow RV updates.Bug# 7014234

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

         okl_am_util_pvt.get_transaction_id(p_try_name         => 'Asset Residual Change',
                                            x_return_status    => x_return_status,
                                            x_try_id           => l_try_id);


         IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
              -- Unable to find a transaction type for this transaction
              OKL_API.set_message(p_app_name    => 'OKL',
                          p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                          p_token1              => 'TRY_NAME',
                          p_token1_value        => 'Asset Residual Change');
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;




         i := p_assets_tbl.FIRST;
         -- loop thru the table of records receieved as input. For each record get the line item information from
         -- cursor l_linesfullv_csr. Validate the input data and then create transaction header and transaction line records
         -- in okl_trx_assets_v and okl_txl_assets_v
         LOOP
            IF p_assets_tbl(i).p_id IS NULL OR p_assets_tbl(i).p_id = OKL_API.G_MISS_NUM THEN
                l_record_status := OKL_API.G_RET_STS_ERROR;
                -- Line id is required
                OKC_API.set_message( p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'LINE_ID');
            ELSE
                OPEN  l_linesfullv_csr(p_assets_tbl(i).p_id) ;
                FETCH l_linesfullv_csr INTO l_name, l_description, l_old_residual_value, l_oec, l_chr_id, l_contract_number;
                IF  l_linesfullv_csr%NOTFOUND THEN
                    l_record_status := OKL_API.G_RET_STS_ERROR;
                    -- Asset number is invalid
                    OKC_API.set_message( p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ASSET_NUMBER');
                ELSE
                  -- Begin -- Check the contract term to allow RV updates.Bug# 7014234
                  OPEN c_contract_date_csr(l_chr_id);
                  FETCH c_contract_date_csr INTO chr_rec;
                  CLOSE c_contract_date_csr;

                  IF NOT (l_sysdate BETWEEN chr_rec.start_date AND chr_rec.end_date) THEN
                    l_icx_date_format := NVL(FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');
                    OKL_API.SET_MESSAGE(G_APP_NAME,
                                        'OKL_LLA_WRONG_TRX_DATE',
                                        'START_DATE',
                                        TO_CHAR(chr_rec.start_date,l_icx_date_format),
                                        'END_DATE',
                                        TO_CHAR(chr_rec.end_date,l_icx_date_format),
                                        'ASSET_NUMBER',
                                        l_name
                                        );
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                  -- End -- Check the contract term to allow RV updates.Bug# 7014234

                   -- SECHAWLA 07-FEB-03 Bug # 2789656 : Moved the following validation here in the beginning of the code
                   -- Check if a pending transaction already exists for this contract
                   OPEN  l_assettrx_csr(l_chr_id);
                   FETCH l_assettrx_csr INTO l_count;
                   CLOSE l_assettrx_csr;

                   IF l_count > 0 THEN
                       l_record_status := OKL_API.G_RET_STS_ERROR;
                       -- Asset failed because a pending salvage value writedown transaction already exists for the financial asset
                       OKL_API.set_message(
                                            p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_RVW_TRX_EXISTS',
                                            p_token1        => 'ASSET_NUMBER',
                                            p_token1_value  => l_name,
                                            p_token2        => 'CONTRACT_NUMBER',
                                            p_token2_value  => l_contract_number);
                   ELSE

                       -- Check if an accepted termination quote exists for this line
                       OPEN  l_quotes_csr(p_assets_tbl(i).p_id);
                       FETCH l_quotes_csr INTO l_name;
                       IF l_quotes_csr%FOUND THEN
                          l_record_status := OKL_API.G_RET_STS_ERROR;
                          -- Can not change Residual value for asset ASSET_NUMBER as an accepted termination quote exists for this asset.
                          OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RVW_NOT_ALLOWED',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_name);

                       ELSIF p_assets_tbl(i).p_new_residual_value IS NULL OR p_assets_tbl(i).p_new_residual_value = OKL_API.G_MISS_NUM THEN

                              l_record_status := OKL_API.G_RET_STS_ERROR;

                              -- Asset failed because the new Residual Value is missing
                              OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_NEW_RESIDUAL_VALUE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_name);

                       ELSIF p_assets_tbl(i).p_new_residual_value < 0  THEN

                              l_record_status := OKL_API.G_RET_STS_ERROR;
                              -- Asset failed because the new Residual Value is negative
                              OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NEGATIVE_RESIDUAL_VALUE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_name);

                       ELSIF l_old_residual_value IS NULL THEN
                                  l_record_status := OKL_API.G_RET_STS_ERROR;
                                  -- Asset failed because the old Residual Value is missing
                                  OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_OLD_RESIDUAL_VALUE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_name);

                       ELSIF p_assets_tbl(i).p_new_residual_value < l_old_residual_value THEN

                            -- RRAVIKIR Legal Entity Changes
                            OPEN l_oklheaders_csr(cp_khr_id  =>  l_chr_id);
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
                              -- create transaction header
                              lp_thpv_rec.tas_type := 'ARC';
                              lp_thpv_rec.tsu_code := 'ENTERED';
                              lp_thpv_rec.try_id   :=  l_try_id;
                              lp_thpv_rec.date_trans_occurred := l_sysdate;
                            END IF;

                            OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                                                    p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => l_record_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_thpv_rec		        => lp_thpv_rec,
						                            x_thpv_rec		        => lx_thpv_rec);



     	                      IF l_record_status = OKL_API.G_RET_STS_SUCCESS THEN

                                  -- SECHAWLA  Bug # 2726739 : Added the following piece of code

                                  -- get the functional currency
                                  l_func_curr_code := okl_am_util_pvt.get_functional_currency;

                                  -- get the contract currency
                                  l_contract_curr_code := okl_am_util_pvt.get_chr_currency( p_chr_id => l_chr_id);

                                  lp_tlpv_rec.currency_code := l_contract_curr_code;
                                  --    lp_tlpv_rec.currency_conversion_code := l_func_curr_code;

                                  IF l_contract_curr_code <> l_func_curr_code  THEN
                                     -- get the conversion factors from accounting util. No conversion is required here. We use
                                     -- convert_to_functional_currency procedure just to get the conversion factors

                                     okl_accounting_util.convert_to_functional_currency(
   	                                            p_khr_id  		  	       => l_chr_id,
   	                                            p_to_currency   		   => l_func_curr_code,
   	                                            p_transaction_date 	       => l_sysdate ,
   	                                            p_amount 			       => p_assets_tbl(i).p_new_residual_value,
                                                x_return_status		       => x_return_status,
   	                                            x_contract_currency	       => lx_contract_currency,
   		                                        x_currency_conversion_type => lx_currency_conversion_type,
   		                                        x_currency_conversion_rate => lx_currency_conversion_rate,
   		                                        x_currency_conversion_date => lx_currency_conversion_date,
   		                                        x_converted_amount 	       => lx_converted_amount );

                                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                          RAISE OKL_API.G_EXCEPTION_ERROR;
                                      END IF;

                                      lp_tlpv_rec.currency_conversion_type := lx_currency_conversion_type;
                                      lp_tlpv_rec.currency_conversion_rate := lx_currency_conversion_rate;
                                      lp_tlpv_rec.currency_conversion_date := lx_currency_conversion_date;
                                  END IF;
                                        --- SECHAWLA  Bug # 2726739 : end new code -----


                                  -- Create transaction Line
                                  lp_tlpv_rec.tas_id 			  := lx_thpv_rec.id; 		-- FK
	                              lp_tlpv_rec.kle_id 			  := p_assets_tbl(i).p_id;
   	                              lp_tlpv_rec.line_number 		  := 1;
                                  lp_tlpv_rec.tal_type 		      := 'ADL';
                                  lp_tlpv_rec.asset_number 		  := l_name;
                                  lp_tlpv_rec.description         := l_description;
                                  lp_tlpv_rec.old_residual_value  := l_old_residual_value;
                                  lp_tlpv_rec.new_residual_value  := p_assets_tbl(i).p_new_residual_value;
                                  lp_tlpv_rec.original_cost 	  := l_oec;
	                              lp_tlpv_rec.current_units 	  := 1;
                                  --lp_tlpv_rec.dnz_asset_id	  := l_asset_id;
                                  lp_tlpv_rec.dnz_khr_id 		  := l_chr_id;

                                  OKL_TXL_ASSETS_PUB.create_txl_asset_def(
                                                    p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => l_record_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);
                              END IF;


                      ELSIF p_assets_tbl(i).p_new_residual_value = l_old_residual_value THEN
                            l_record_status := OKL_API.G_RET_STS_ERROR;
                            -- Asset failed because the new Residual Value is same as the old value.
                            OKL_API.set_message( p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_SAME_RESIDUAL_VALUE',
                                             p_token1        => 'ASSET_NUMBER',
                                             p_token1_value  => l_name);

                      ELSE    -- new residual < old residual

                                    l_record_status := OKL_API.G_RET_STS_ERROR;
                                    -- Asset failed because the new Residual Value is not lower than the old value.
                                    OKL_API.set_message( p_app_name      => 'OKL',
                                       p_msg_name      => 'OKL_AM_INVALID_RESIDUAL_VALUE',
                                       p_token1        => 'ASSET_NUMBER',
                                       p_token1_value  => l_name);



                     END IF;
                     CLOSE l_quotes_csr;

                   END IF;

                END IF;  -- end fetch
                CLOSE l_linesfullv_csr;

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
      END IF;  -- p_assets_tbl.COUNT > 0


      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

      EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;
        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;
        IF l_quotes_csr%ISOPEN THEN
           CLOSE l_quotes_csr;
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
        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;
        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;
        IF l_quotes_csr%ISOPEN THEN
           CLOSE l_quotes_csr;
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
        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;
        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;
        IF l_quotes_csr%ISOPEN THEN
           CLOSE l_quotes_csr;
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
   END create_residual_value_trx;
END OKL_AM_RV_WRITEDOWN_PVT;

/
