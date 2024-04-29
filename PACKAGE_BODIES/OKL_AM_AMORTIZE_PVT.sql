--------------------------------------------------------
--  DDL for Package Body OKL_AM_AMORTIZE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_AMORTIZE_PVT" AS
/* $Header: OKLRTATB.pls 120.22 2008/02/05 22:19:43 rmunjulu noship $ */

-- SECHAWLA 06-MAY-04 3578894 : Added a new type declaration
     TYPE book_rec_type IS RECORD
   (   parent_line_id           NUMBER,
       dnz_chr_id               NUMBER,
       depreciation_category    fa_additions_b.asset_category_id%TYPE,
       book_type_code           FA_BOOKS.book_type_code%TYPE,
       book_class               FA_BOOK_CONTROLS.book_class%TYPE,
       salvage_value            FA_BOOKS.salvage_value%TYPE,
       DEPRN_METHOD_CODE        FA_BOOKS.DEPRN_METHOD_CODE%TYPE ,
       LIFE_IN_MONTHS           FA_BOOKS.LIFE_IN_MONTHS%TYPE,
       -- SECHAWLA 28-MAY-04 3645574 : Added deprn_rate
       DEPRN_RATE               NUMBER,
       asset_number             fa_additions_b.asset_number%TYPE,
       item_description         okc_k_lines_tl.item_description%TYPE,
       asset_id                 fa_books.asset_id%TYPE,
       original_cost            fa_books.original_cost%TYPE,
       current_units            fa_additions_b.current_units%TYPE,
       in_service_date          fa_books.DATE_PLACED_IN_SERVICE%TYPE);



-- Start of comments
--
-- Procedure Name  : get_reporting_product
-- Description     : This procedure checks if there is a reporting product attached to the contract and returns
--                   the deal type of the reporting product and MG reporting book
-- Business Rules  :
-- Parameters      :  p_contract_id - Contract ID
-- Version         : 1.0
-- History         : SECHAWLA 06-MAY-04  3578894- Created
-- End of comments

  PROCEDURE get_reporting_product(p_api_version           IN  	NUMBER,
           		 	              p_init_msg_list         IN  	VARCHAR2,
           			              x_return_status         OUT 	NOCOPY VARCHAR2,
           			              x_msg_count             OUT 	NOCOPY NUMBER,
           			              x_msg_data              OUT 	NOCOPY VARCHAR2,
                                  p_contract_id 		  IN 	NUMBER,
                                  x_rep_product           OUT   NOCOPY VARCHAR2,
                                  x_mg_rep_book           OUT   NOCOPY VARCHAR2,
                                  x_rep_deal_type         OUT   NOCOPY VARCHAR2) IS
                                  --,x_rep_tax_owner         OUT   VARCHAR2) IS

  -- Get the financial product of the contract
  CURSOR l_get_fin_product(cp_khr_id IN NUMBER) IS
  SELECT a.start_date, a.contract_number, b.pdt_id
  FROM   okc_k_headers_b a, okl_k_headers b
  WHERE  a.id = b.id
  AND    a.id = cp_khr_id;

  SUBTYPE pdtv_rec_type IS OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
  SUBTYPE pdt_parameters_rec_type IS OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

  l_fin_product_id          NUMBER;
  l_start_date              DATE;
  lp_pdtv_rec               pdtv_rec_type;
  lp_empty_pdtv_rec         pdtv_rec_type;
  lx_no_data_found          BOOLEAN;
  lx_pdt_parameter_rec      pdt_parameters_rec_type ;
  l_contract_number         VARCHAR2(120);
  l_mg_rep_book             fa_book_controls.book_type_code%TYPE;
  mg_error                  EXCEPTION;
  l_reporting_product       OKL_PRODUCTS_V.NAME%TYPE;
  l_reporting_product_id    NUMBER;
  l_rep_deal_type           okl_product_parameters_v.deal_type%TYPE;
 -- l_rep_tax_owner         okl_product_parameters_v.tax_owner%TYPE;


  BEGIN
    -- get the financial product of the contract
    OPEN  l_get_fin_product(p_contract_id);
    FETCH l_get_fin_product INTO l_start_date, l_contract_number, l_fin_product_id;
    CLOSE l_get_fin_product;

    lp_pdtv_rec.id := l_fin_product_id;

    -- check if the fin product has a reporting product
    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters( p_api_version                  => p_api_version,
  				  			               p_init_msg_list                => OKC_API.G_FALSE,
						                   x_return_status                => x_return_status,
							               x_no_data_found                => lx_no_data_found,
							               x_msg_count                    => x_msg_count,
							               x_msg_data                     => x_msg_data,
							               p_pdtv_rec                     => lp_pdtv_rec,
							               p_product_date                 => l_start_date,
							               p_pdt_parameter_rec            => lx_pdt_parameter_rec);

    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        -- Error getting financial product parameters for contract CONTRACT_NUMBER.
        OKC_API.set_message(  p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_FIN_PROD_PARAM_ERR',
                           p_token1        =>  'CONTRACT_NUMBER',
                           p_token1_value  =>  l_contract_number);



    ELSE

        l_reporting_product := lx_pdt_parameter_rec.reporting_product;
        l_reporting_product_id := lx_pdt_parameter_rec.reporting_pdt_id;

        IF l_reporting_product IS NOT NULL AND l_reporting_product <> OKC_API.G_MISS_CHAR THEN
            -- Contract has a reporting product
            x_rep_product :=  l_reporting_product;

            lp_pdtv_rec := lp_empty_pdtv_rec;
            lp_pdtv_rec.id := l_reporting_product_id;

            -- get the deal type of the reporting product
            OKL_SETUPPRODUCTS_PUB.Getpdt_parameters( p_api_version                  => p_api_version,
  				  			               p_init_msg_list                => OKC_API.G_FALSE,
						                   x_return_status                => x_return_status,
							               x_no_data_found                => lx_no_data_found,
							               x_msg_count                    => x_msg_count,
							               x_msg_data                     => x_msg_data,
							               p_pdtv_rec                     => lp_pdtv_rec,
							               p_product_date                 => l_start_date,
							               p_pdt_parameter_rec            => lx_pdt_parameter_rec);

            IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                -- Error getting reporting product parameters for contract CONTRACT_NUMBER.
                OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_REP_PROD_PARAM_ERR',
                                  p_token1        => 'CONTRACT_NUMBER',
                                  p_token1_value  => l_contract_number);


            ELSE

                l_rep_deal_type := lx_pdt_parameter_rec.Deal_Type;
                IF l_rep_deal_type IS NULL OR l_rep_deal_type = OKC_API.G_MISS_CHAR THEN
                    --Deal Type not defined for Reporting product REP_PROD.
                    OKC_API.set_message(  p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_NO_MG_DEAL_TYPE',
                                 p_token1        => 'REP_PROD',
                                 p_token1_value  => l_reporting_product);

                    RAISE mg_error;
                ELSE
                    x_rep_deal_type :=  l_rep_deal_type ;
                END IF;

            /*
            l_rep_tax_owner := lx_pdt_parameter_rec.Tax_Owner;
            IF l_rep_tax_owner IS NULL OR l_rep_tax_owner = OKC_API.G_MISS_CHAR THEN
                -- Tax Owner not defined for Reporting product REP_PROD.
                OKC_API.set_message(  p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_NO_MG_TAX_OWNER',
                                 p_token1        => 'REP_PROD',
                                 p_token1_value  => l_reporting_product);

                RAISE mg_error;
            ELSE
                x_rep_tax_owner := l_rep_tax_owner;
            END IF;
            */

            -- SECHAWLA 06-MAY-04 3578894 : Reporting book can be updated only if the reporting product is Op LEASE
            -- This resriction is added because Authoring does not assign the asset to reporting book is other than
            -- OP LEASE  Bug 3574232  has been raised on Authoring to allow asset entry in Rep book for other deal types
            --IF l_rep_deal_type = 'LEASEOP' THEN  -- SECHAWLA 29-JUL-05 4384784
                -- get the MG reporting book
                l_mg_rep_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
                IF l_mg_rep_book IS NULL THEN
                    --Multi GAAP Reporting Book is not defined.
                    OKC_API.set_message(  p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_NO_MG_REP_BOOK');

                    RAISE mg_error;
                ELSE
                    x_mg_rep_book := l_mg_rep_book;
                END IF;
           -- END IF;

         END IF;

     END IF;

  END IF;

  EXCEPTION
      WHEN mg_error THEN
         IF l_get_fin_product%ISOPEN THEN
            CLOSE l_get_fin_product;
         END IF;
         x_return_status := OKL_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
         IF l_get_fin_product%ISOPEN THEN
            CLOSE l_get_fin_product;
         END IF;
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END get_reporting_product;



  -- Start of comments
  --
  -- Procedure Name  : process_oplease
  -- Description     : This procedure creates off lease transactions for an asset in Operating Lease
  -- Business Rules  :
  -- Parameters      : p_book_rec              : record type parameter with corporate book information
  --                   p_corporate_book        : corporate book
  --                   p_kle_id                : asset line id
  --                   p_try_id                : transaction type id
  --                   p_sysdate               : today's date
  --                   p_func_curr_code        : functional currency code
  -- Version         : 1.0
  -- History         : SECHAWLA 06-APR-04  - Created
  --                   SECHAWLA 28-MAY-04 3645574 - Addded depreciation rate processing logic for diminishing dep methods
  --                   SECHAWLA 15-DEC-04 4028371 : set FA trx date on trx line
  -- End of comments

  PROCEDURE process_oplease( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 ,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_book_rec              IN   book_rec_type,
                             p_corporate_book        IN   VARCHAR2,
                             p_kle_id                IN   NUMBER,
                             p_try_id                IN   NUMBER,
                             p_sysdate               IN   DATE,
                             p_func_curr_code        IN   VARCHAR2,
                             p_legal_entity_id       IN   NUMBER) IS  -- RRAVIKIR Legal Entity Changes

   process_error        EXCEPTION;
   process_unexp_error  EXCEPTION;



  --SECHAWLA 19-FEB-04 3439647 : added life_in_months to the select clause
   -- This cursor will return a method_code corresponding to a unique method_id
   CURSOR l_methodcode_csr(p_method_id fa_methods.method_id%TYPE) IS
   SELECT method_code, life_in_months
   FROM   fa_methods
   WHERE  method_id = p_method_id;



   -- This cursor will return the hold period days and the default depreciation method from a hold period setup table
   -- using category_id and book_type_code.
   CURSOR l_amthld_csr(p_category_id okl_amort_hold_setups.category_id%TYPE,
                       p_book_type_code okl_amort_hold_setups.book_type_code%TYPE) IS
   -- SECHAWLA 28-MAY-04 3645574 : Added deprn_rate
   SELECT hold_period_days, method_id, deprn_rate
   FROM   okl_amort_hold_setups
   WHERE  category_id        = p_category_id
   AND    book_type_code     = p_book_type_code;

   /*
   -- This cursor will return current cost of an asset
   CURSOR l_astbksv_csr(p_id okx_ast_bks_v.asset_id%TYPE, p_btc okx_ast_bks_v.book_type_code%TYPE) IS
   SELECT cost
   FROM   okx_ast_bks_v
   WHERE  asset_id = p_id
   AND    book_type_code = p_btc;
   */

   l_hold_period_days           okl_amort_hold_setups.hold_period_days%TYPE;
   l_setup_method_id            okl_amort_hold_setups.method_id%TYPE;
   l_fa_method_code             fa_methods.method_code%TYPE;
   l_fa_life_in_months          fa_methods.life_in_months%TYPE;
   lp_thpv_rec                  thpv_rec_type;
   lx_thpv_rec                  thpv_rec_type;
   lp_tlpv_rec			        tlpv_rec_type;
   lx_tlpv_rec			        tlpv_rec_type;
   lp_empty_thpv_rec            thpv_rec_type;
   lp_empty_tlpv_rec            tlpv_rec_type;

   SUBTYPE  adpv_rec_type IS OKL_TXD_ASSETS_PUB.adpv_rec_type;
   lp_adpv_rec                  adpv_rec_type;
   lx_adpv_rec                  adpv_rec_type;
   lp_empty_adpv_rec            adpv_rec_type;

   -- SECHAWLA 28-MAY-04 3645574 : new declaration
   l_setup_deprn_rate           NUMBER;

   -- SECHAWLA 15-DEC-04 4028371 : new declartions
   l_fa_trx_date				DATE;
  BEGIN

      -- get the hold period and dep method from setup, for each book/category
      OPEN  l_amthld_csr(p_book_rec.depreciation_category, p_book_rec.book_type_code);
      -- SECHAWLA 28-MAY-04 3645574 : Added l_setup_deprn_rate
      FETCH l_amthld_csr INTO l_hold_period_days,l_setup_method_id, l_setup_deprn_rate; --l_setup_deprn_rate could be null
      CLOSE l_amthld_csr;


      -- If there is a method_id in okl_amort_hold_setups then use it to get deprn method from fa_methods.

      IF l_setup_method_id IS NOT NULL THEN -- either life or rate is defined in the setup. Life is not stored in teh setup table but rate is stores
         OPEN   l_methodcode_csr(l_setup_method_id);
         -- SECHAWLA 19-FEB-04 3439647 : Added l_fa_life_in_months
         FETCH  l_methodcode_csr INTO l_fa_method_code, l_fa_life_in_months;  -- life_in_months will be null for diminishing dep methods
         IF l_methodcode_csr%NOTFOUND THEN
            --  The depreciation method defined for category DEPRN_CAT and book BOOK is invalid.
            OKL_API.set_message(     p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_INVALID_DEPRN_MTHD',
                                     p_token1        => 'DEPRN_CAT',
                                     p_token1_value  => p_book_rec.depreciation_category,
                                     p_token2        => 'BOOK',
                                     p_token2_value  => p_book_rec.book_type_code);
            RAISE process_error;
         END IF;
         CLOSE  l_methodcode_csr;
      END IF;

      -- SECHAWLA 28-MAY-04 3645574 : Removing this validation, as life is null for diminishing dep methods
      /*IF  p_book_rec.life_in_months IS NULL THEN
          -- Life in Months not defined for asset ASSET_NUMBER and book BOOK
          OKL_API.set_message(  p_app_name        => 'OKL',
                                  p_msg_name      => 'OKL_AM_NO_LIFE_IN_MONTHS',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  p_book_rec.asset_number,
                                  p_token2        => 'BOOK',
                                  p_token2_value  => p_book_rec.book_type_code);
          RAISE process_error;
      END IF;
      */
      -- SECHAWLA 28-MAY-04 3645574 : new validation, eithr life or rate should be defined
      IF  p_book_rec.life_in_months IS NULL AND p_book_rec.deprn_rate IS NULL THEN
          --  Life in Months or Depreciation Rate should be defined for asset ASSET_NUMBER and book BOOK.
          OKL_API.set_message(  p_app_name        => 'OKL',
                                  p_msg_name      => 'OKL_AM_NO_LIFE_NO_RATE',
                                  p_token1        => 'ASSET_NUMBER',
                                  p_token1_value  =>  p_book_rec.asset_number,
                                  p_token2        => 'BOOK',
                                  p_token2_value  => p_book_rec.book_type_code);
          RAISE process_error;
      END IF;
      -- SECHAWLA 28-MAY-04 3645574 : end new validation

	  --SECHAWLA 15-DEC-04 4028371 : get the FA trx date
      OKL_ACCOUNTING_UTIL.get_fa_trx_date(p_book_type_code => p_book_rec.book_type_code,
      									  x_return_status  => x_return_status,
   										  x_fa_trx_date    => l_fa_trx_date);

   	  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE process_unexp_error;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE process_error;
      END IF;


      IF l_hold_period_days IS NOT NULL AND l_hold_period_days <> 0 THEN -- SECHAWLA 03-JUN-04 Added check for 0 hold period days
         -- create 1st transaction header
         -- SECHAWLA 06-MAY-04 3578894 : Changed tas_type to a new tas_type
         -- lp_thpv_rec.tas_type := 'AMT';
         lp_thpv_rec.tas_type := 'AUD'; -- depreciation flag adjustment trx

         lp_thpv_rec.tsu_code := 'ENTERED';

         lp_thpv_rec.try_id   :=  p_try_id;
         lp_thpv_rec.date_trans_occurred := p_sysdate;

         -- RRAVIKIR Legal Entity Changes
         lp_thpv_rec.legal_entity_id := p_legal_entity_id;
         -- Legal Entity Changes End

         OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		  p_init_msg_list         => OKL_API.G_FALSE,
           					  x_return_status         => x_return_status,
           					  x_msg_count             => x_msg_count,
           					  x_msg_data              => x_msg_data,
						  p_thpv_rec		  => lp_thpv_rec,
						  x_thpv_rec		  => lx_thpv_rec);

     	  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE process_unexp_error;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE process_error;
          END IF;


          -- create 1st transaction line

          lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
          lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
          lp_tlpv_rec.kle_id 			    := p_kle_id;
   	      lp_tlpv_rec.line_number 	  	    := 1;

          --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for dep flag only updates
          --lp_tlpv_rec.tal_type 		    := 'AML';
          lp_tlpv_rec.tal_type 		        := 'AUF'; -- new tal_type
          lp_tlpv_rec.asset_number 		    := p_book_rec.asset_number;
          lp_tlpv_rec.description           := p_book_rec.item_description;

          -- SECHAWLA 06-MAY-04 3578894 : Dep method and life are populated for display on off lease trx details screen
          -- When this trx is processed, dep method and life will not be updated in FA

          -- SECHAWLA 28-MAY-04 3645574 : Store either life or rate
          IF p_book_rec.life_in_months IS NOT NULL THEN
             lp_tlpv_rec.life_in_months       := p_book_rec.life_in_months;
          ELSE
             lp_tlpv_rec.deprn_rate  := p_book_rec.deprn_rate;
          END IF;


          -- FA Adjustmets API expects a depreciation method and life in months, not the depreciation Id

          -- SECHAWLA 19-FEB-04 3439647 : when we stop the depreciation, there is no need to update the
          -- dep method with the one on setup


          lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code;


          -- SECHAWLA 06-MAY-04 3578894 : need to populate sv for display on the off lse upd screen
   	      lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

          --In case of Operating lease, asset is already assigned to a corporate book

          lp_tlpv_rec.corporate_book 		:= p_corporate_book;
	      lp_tlpv_rec.original_cost 		:= p_book_rec.original_cost;
	      lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
	      lp_tlpv_rec.hold_period_days  	:= l_hold_period_days;
	      lp_tlpv_rec.depreciate_yn	 	:= 'N';
          lp_tlpv_rec.dnz_asset_id		:= to_number(p_book_rec.asset_id);
          lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
          lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

          --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
          lp_tlpv_rec.currency_code        := p_func_curr_code;

          -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
          lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	      OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE process_unexp_error;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE process_error;
          END IF;

          -- When process_oplease procedure is called with mg rep book (tax book), then
          -- we need to create tax book trx also.
          IF p_book_rec.book_type_code <> p_corporate_book THEN
               IF p_book_rec.book_class = 'TAX' THEN
                     lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                     lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                     lp_adpv_rec.asset_number := p_book_rec.asset_number;
                     OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE process_unexp_error;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE process_error;
                      END IF;
               END IF;

          END IF;

          -- Validations for the 2nd trx (if any) should go here

          /* SECHAWLA 06-MAY-04 3578894 : Do not populate cost in case of OP Lease
          -- validations specific to the 2nd transaction line
          OPEN   l_astbksv_csr(l_asset_id, l_corporate_book);
          FETCH  l_astbksv_csr INTO l_cost;
          IF l_astbksv_csr%NOTFOUND THEN
               -- Cost not defined for this asset and book type code
               OKL_API.set_message(  p_app_name        => 'OKL',
                                     p_msg_name        => 'OKL_AM_COST_NOT_FOUND',
                                     p_token1          => 'ASSET_NUMBER',
                                     p_token1_value    => l_asset_number,
                                     p_token2          => 'BOOK_TYPE_CODE',
                                     p_token2_value    => l_corporate_book);
                l_line_status := 'ERROR';
           END IF;
           CLOSE  l_astbksv_csr;
           -- end validation
          */

           -- SECHAWLA 06-MAY-04 3578894 : Split the 2nd trx into 2 transactions. First update the deprn method and
           -- flag and then start the depreciation. This is required because FA does not allow updating depreciation
           -- flag with any other attribute. Details in bug 3501172

           -- SECHAWLA 06-MAY-04 3578894 : Initialize the trx hdr and line for each trx
           lp_thpv_rec := lp_empty_thpv_rec;
           lp_tlpv_rec := lp_empty_tlpv_rec;
           lp_adpv_rec := lp_empty_adpv_rec;
           -- SECHAWLA 06-MAY-04 3578894 : end initialization


           -- Create 2nd Transaction Header
           lp_thpv_rec.tas_type := 'AMT';

           lp_thpv_rec.tsu_code := 'ENTERED';

           lp_thpv_rec.try_id   :=  p_try_id;
           lp_thpv_rec.date_trans_occurred := p_sysdate + l_hold_period_days;

           -- RRAVIKIR Legal Entity Changes
           lp_thpv_rec.legal_entity_id := p_legal_entity_id;
           -- Legal Entity Changes End

           OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           	 		       		    p_init_msg_list         => OKL_API.G_FALSE,
           					    x_return_status         => x_return_status,
           					    x_msg_count             => x_msg_count,
           					    x_msg_data              => x_msg_data,
						    p_thpv_rec		        => lp_thpv_rec,
						    x_thpv_rec		        => lx_thpv_rec);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE process_unexp_error;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE process_error;
           END IF;

           -- create 2nd transaction line.
           lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
           lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
           lp_tlpv_rec.kle_id 			    := p_kle_id;
           lp_tlpv_rec.line_number 		:= 1;
           lp_tlpv_rec.tal_type 		    := 'AML';
           lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
           lp_tlpv_rec.description         := p_book_rec.item_description;

           -- SECHAWLA 19-FEB-04 3439647
           --lp_tlpv_rec.life_in_months      := l_life_in_months;

           -- If there is a method_id in okl_amort_hold_setups then use it. Otherwise get method id
           -- from fa_methods


           IF l_setup_method_id IS NOT NULL THEN
              lp_tlpv_rec.deprn_method        := l_fa_method_code;

              -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
              IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
                 lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
              ELSE
                 -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
                 lp_tlpv_rec.life_in_months      := l_fa_life_in_months;
              END IF;

           ELSE
              lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code;

              -- SECHAWLA 28-MAY-04 3645574: store either life or rate
              IF p_book_rec.life_in_months IS NOT NULL THEN
                -- SECHAWLA 19-FEB-04 3439647 : use original life in months
                lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
              ELSE
                lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
              END IF;
           END IF;


           --In case of Operating lease, asset is already assigned to a corporate book

           lp_tlpv_rec.corporate_book 		:= p_corporate_book;

           -- SECHAWLA 06-MAY-04 3578894 : Do not update cost in case of OP Lease
           --lp_tlpv_rec.depreciation_cost 	:= l_cost ;

           --SECHAWLA 06-MAY-04 3578894 : Populate sv for display on off lse upd screen
           lp_tlpv_rec.salvage_value 	    	:= p_book_rec.salvage_value;


	       lp_tlpv_rec.original_cost 	    	:= p_book_rec.original_cost;
	       lp_tlpv_rec.current_units 	    	:= p_book_rec.current_units;
	       lp_tlpv_rec.hold_period_days	    := l_hold_period_days;

           -- SECHAWLA 06-MAY-04 3578894 : Depreciate_yn flag is set here and also in the 3rd trx,so the process
           -- asset trx program can identify that these are split transactions. When 2nd trx is processed, the flag
           -- is not updated in FA. Only Dep method and life will be updated
	       lp_tlpv_rec.depreciate_yn	 	    := 'Y';

	       lp_tlpv_rec.dnz_asset_id		    := to_number(p_book_rec.asset_id);
           lp_tlpv_rec.dnz_khr_id 		        := p_book_rec.dnz_chr_id;
           lp_tlpv_rec.in_service_date         := p_book_rec.in_service_date;

           --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
           lp_tlpv_rec.currency_code := p_func_curr_code;

	       -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
           lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	       OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);


            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;


            -- When process_oplease procedure is called with mg rep book (tax book), then
            -- we need to create tax book trx also.
            IF p_book_rec.book_type_code <> p_corporate_book THEN
                IF p_book_rec.book_class = 'TAX' THEN
                       lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                       lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                       lp_adpv_rec.asset_number := p_book_rec.asset_number;
                       OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE process_unexp_error;
                       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE process_error;
                       END IF;
                END IF;
           END IF;


           -- Validations for 3rd trx (if any) shold go here
           -- SECHAWLA 06-MAY-04 3578894 : create 3rd trx hdr and line, to start the depreciation

           -- Initialize the trx hdr and line for each trx
           lp_thpv_rec := lp_empty_thpv_rec;
           lp_tlpv_rec := lp_empty_tlpv_rec;
           lp_adpv_rec := lp_empty_adpv_rec;

           -- Create a 3rd trx header and line with dep_yn = 'Y' and dep_method = null, life = null

           -- Create 3rd Transaction Header
           lp_thpv_rec.tas_type := 'AUD';  -- depreciate flag update trx

           lp_thpv_rec.tsu_code := 'ENTERED';

           lp_thpv_rec.try_id   :=  p_try_id;
           lp_thpv_rec.date_trans_occurred := p_sysdate + l_hold_period_days;

           -- RRAVIKIR Legal Entity Changes
           lp_thpv_rec.legal_entity_id := p_legal_entity_id;
           -- Legal Entity Changes End

           OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		    p_init_msg_list         => OKL_API.G_FALSE,
           					    x_return_status         => x_return_status,
           					    x_msg_count             => x_msg_count,
           					    x_msg_data              => x_msg_data,
						    p_thpv_rec		        => lp_thpv_rec,
						    x_thpv_rec		        => lx_thpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE process_error;
            END IF;

            -- create 3rd transaction line.
            lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
            lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
            lp_tlpv_rec.kle_id 			    := p_kle_id;
            lp_tlpv_rec.line_number 		:= 1;

            --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for dep flag only updates
            --lp_tlpv_rec.tal_type 		    := 'AML';
            lp_tlpv_rec.tal_type 		    := 'AUF'; -- new tal_type

            lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
            lp_tlpv_rec.description         := p_book_rec.item_description;

            --In case of Operating lease, asset is already assigned to a corporate book

            lp_tlpv_rec.corporate_book 		:= p_corporate_book;

            lp_tlpv_rec.original_cost 		:= p_book_rec.original_cost;
	        lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
	        lp_tlpv_rec.hold_period_days	:= l_hold_period_days;
            -- SECHAWLA 06-MAY-04 3578894 : When 3rd trx is processed, the flag will be updated in FA. No other
            -- financial attributes will be updated along with the flag
	        lp_tlpv_rec.depreciate_yn	 	:= 'Y';

            --SECHAWLA 06-MAY-04 3578894 : Populate dep method, life and sv for display on off lse upd screen
            IF l_setup_method_id IS NOT NULL THEN
                  lp_tlpv_rec.deprn_method        := l_fa_method_code;

                  -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
                  IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
                     lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
                  ELSE
                     lp_tlpv_rec.life_in_months      := l_fa_life_in_months;
                  END IF;
            ELSE
                  lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code;

                  -- SECHAWLA 28-MAY-04 3645574: store either life or rate
                  IF p_book_rec.life_in_months IS NOT NULL THEN
                     lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
                  ELSE
                     lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
                  END IF;
            END IF;

            lp_tlpv_rec.salvage_value 		   := p_book_rec.salvage_value;

	        lp_tlpv_rec.dnz_asset_id		   := to_number(p_book_rec.asset_id);
            lp_tlpv_rec.dnz_khr_id 		       := p_book_rec.dnz_chr_id;
            lp_tlpv_rec.in_service_date        := p_book_rec.in_service_date;

            lp_tlpv_rec.currency_code          := p_func_curr_code;

            -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
            lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	        OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);


             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE process_unexp_error;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE process_error;
             END IF;
             -- SECHAWLA 06-MAY-04 3578894 : end create 3rd trx hdr and line

             -- When process_oplease procedure is called with mg rep book (tax book), then
             -- we need to create tax book trx also.
             IF p_book_rec.book_type_code <> p_corporate_book THEN
                 IF p_book_rec.book_class = 'TAX' THEN
                        lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                        lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                        lp_adpv_rec.asset_number := p_book_rec.asset_number;
                        OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              RAISE process_unexp_error;
                         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                              RAISE process_error;
                         END IF;
                 END IF;

             END IF;


       ELSE -- LEASEOP, Hold period is null or 0
                    -- do nothing --
            --NULL;

            -- Create 1st Transaction Header
            lp_thpv_rec.tas_type := 'AMT';

            lp_thpv_rec.tsu_code := 'ENTERED';

            lp_thpv_rec.try_id   :=  p_try_id;
            lp_thpv_rec.date_trans_occurred := p_sysdate ;
           -- RRAVIKIR Legal Entity Changes
           lp_thpv_rec.legal_entity_id := p_legal_entity_id;
           -- Legal Entity Changes End

            OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           	 		       		     p_init_msg_list         => OKL_API.G_FALSE,
           					     x_return_status         => x_return_status,
           					     x_msg_count             => x_msg_count,
           					     x_msg_data              => x_msg_data,
						     p_thpv_rec		        => lp_thpv_rec,
						     x_thpv_rec		        => lx_thpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;

            -- create 1st transaction line.
            lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
            lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
            lp_tlpv_rec.kle_id 			    := p_kle_id;
            lp_tlpv_rec.line_number 		:= 1;
            lp_tlpv_rec.tal_type 		    := 'AML';
            lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
            lp_tlpv_rec.description         := p_book_rec.item_description;


            -- If there is a method_id in okl_amort_hold_setups then use it. Otherwise get method id
            -- from fa_methods

            IF l_setup_method_id IS NOT NULL THEN
               lp_tlpv_rec.deprn_method        := l_fa_method_code;

               -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
               IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
                  lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
               ELSE
                  -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
                  lp_tlpv_rec.life_in_months      := l_fa_life_in_months;
               END IF;

            ELSE
               lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code;

               -- SECHAWLA 28-MAY-04 3645574: store either life or rate
               IF p_book_rec.life_in_months IS NOT NULL THEN
                  -- SECHAWLA 19-FEB-04 3439647 : use original life in months
                  lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
               ELSE
                  lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
               END IF;
            END IF;


            --In case of Operating lease, asset is already assigned to a corporate book

            lp_tlpv_rec.corporate_book 		:= p_corporate_book;

            -- SECHAWLA 06-MAY-04 3578894 : Do not update cost in case of OP Lease
            --lp_tlpv_rec.depreciation_cost 	:= l_cost ;

            --SECHAWLA 06-MAY-04 3578894 : Populate sv for display on off lse upd screen
            lp_tlpv_rec.salvage_value 	    	:= p_book_rec.salvage_value;


	        lp_tlpv_rec.original_cost 	    	:= p_book_rec.original_cost;
	        lp_tlpv_rec.current_units 	    	:= p_book_rec.current_units;
	        -- lp_tlpv_rec.hold_period_days	    := l_hold_period_days;

            -- SECHAWLA 06-MAY-04 3578894 : Depreciate_yn flag is set here and also in the 2nd trx,so the process
            -- asset trx program can identify that these are split transactions. When 1st trx is processed, the flag
            -- is not updated in FA. Only Dep method and life will be updated
	        lp_tlpv_rec.depreciate_yn	 	    := 'Y';

	        lp_tlpv_rec.dnz_asset_id		    := to_number(p_book_rec.asset_id);
            lp_tlpv_rec.dnz_khr_id 		        := p_book_rec.dnz_chr_id;
            lp_tlpv_rec.in_service_date         := p_book_rec.in_service_date;

            --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
            lp_tlpv_rec.currency_code := p_func_curr_code;

			-- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
            lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	        OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);


            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE process_error;
            END IF;


            -- When process_oplease procedure is called with mg rep book (tax book), then
            -- we need to create tax book trx also.
            IF p_book_rec.book_type_code <> p_corporate_book THEN
                IF p_book_rec.book_class = 'TAX' THEN
                    lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                    lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                    lp_adpv_rec.asset_number := p_book_rec.asset_number;
                    OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE process_unexp_error;
                     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         RAISE process_error;
                     END IF;
                END IF;

            END IF;


            -- Validations for 2nd trx (if any) shold go here
            -- SECHAWLA 06-MAY-04 3578894 : create 2nd trx hdr and line, to start the depreciation

            -- Initialize the trx hdr and line for each trx
            lp_thpv_rec := lp_empty_thpv_rec;
            lp_tlpv_rec := lp_empty_tlpv_rec;
            lp_adpv_rec := lp_empty_adpv_rec;

            -- Create a 2nd trx header and line with dep_yn = 'Y' and dep_method = null, life = null

            -- Create 2nd Transaction Header
            lp_thpv_rec.tas_type := 'AUD';  -- depreciate flag update trx

            lp_thpv_rec.tsu_code := 'ENTERED';

            lp_thpv_rec.try_id   :=  p_try_id;
            lp_thpv_rec.date_trans_occurred := p_sysdate;
            -- RRAVIKIR Legal Entity Changes
            lp_thpv_rec.legal_entity_id := p_legal_entity_id;
            -- Legal Entity Changes End

            OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		     p_init_msg_list         => OKL_API.G_FALSE,
           					     x_return_status         => x_return_status,
           					     x_msg_count             => x_msg_count,
           					     x_msg_data              => x_msg_data,
						     p_thpv_rec		        => lp_thpv_rec,
						     x_thpv_rec		        => lx_thpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;

            -- create 2nd transaction line.
            lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
            lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
            lp_tlpv_rec.kle_id 			    := p_kle_id;
            lp_tlpv_rec.line_number 		:= 1;

            --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for dep flag only updates
            --lp_tlpv_rec.tal_type 		    := 'AML';
            lp_tlpv_rec.tal_type 		    := 'AUF'; -- new tal_type

            lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
            lp_tlpv_rec.description         := p_book_rec.item_description;

            --In case of Operating lease, asset is already assigned to a corporate book

            lp_tlpv_rec.corporate_book 		:= p_corporate_book;

            lp_tlpv_rec.original_cost 		:= p_book_rec.original_cost;
	        lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
	        -- lp_tlpv_rec.hold_period_days	:= l_hold_period_days;
            -- SECHAWLA 06-MAY-04 3578894 : When 2nd trx is processed, the flag will be updated in FA. No other
            -- financial attributes will be updated along with the flag
	        lp_tlpv_rec.depreciate_yn	 	:= 'Y';

            --SECHAWLA 06-MAY-04 3578894 : Populate dep method, life and sv for display on off lse upd screen
            IF l_setup_method_id IS NOT NULL THEN
                 lp_tlpv_rec.deprn_method        := l_fa_method_code;

               -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
               IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
                  lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
               ELSE
                  lp_tlpv_rec.life_in_months      := l_fa_life_in_months;
               END IF;

            ELSE
                 lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code;

                 -- SECHAWLA 28-MAY-04 3645574: store either life or rate
               IF p_book_rec.life_in_months IS NOT NULL THEN
                  lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
               ELSE
                  lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
               END IF;
            END IF;
            lp_tlpv_rec.salvage_value 		   := p_book_rec.salvage_value;

	        lp_tlpv_rec.dnz_asset_id		   := to_number(p_book_rec.asset_id);
            lp_tlpv_rec.dnz_khr_id 		       := p_book_rec.dnz_chr_id;
            lp_tlpv_rec.in_service_date        := p_book_rec.in_service_date;

            lp_tlpv_rec.currency_code          := p_func_curr_code;

            -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
            lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	        OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);


            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE process_error;
            END IF;
            -- SECHAWLA 06-MAY-04 3578894 : end create 2nd trx hdr and line

            -- When process_oplease procedure is called with mg rep book (tax book), then
            -- we need to create tax book trx also.
            IF p_book_rec.book_type_code <> p_corporate_book THEN
                 IF p_book_rec.book_class = 'TAX' THEN
                     lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                     lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                     lp_adpv_rec.asset_number := p_book_rec.asset_number;
                     OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE process_unexp_error;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE process_error;
                      END IF;
                 END IF;

             END IF;
       END IF; -- IF l_hold_period_days IS NOT NULL THEN
  EXCEPTION
      WHEN process_error THEN
           --IF l_astbksv_csr%ISOPEN THEN
           --     CLOSE l_astbksv_csr;
           --END IF;

           IF l_methodcode_csr%ISOPEN THEN
              CLOSE l_methodcode_csr;
           END IF;

           IF l_amthld_csr%ISOPEN THEN
              CLOSE l_amthld_csr;
           END IF;

           x_return_status := OKL_API.G_RET_STS_ERROR;
      WHEN process_unexp_error THEN
           --IF l_astbksv_csr%ISOPEN THEN
           --     CLOSE l_astbksv_csr;
           --END IF;

           IF l_methodcode_csr%ISOPEN THEN
              CLOSE l_methodcode_csr;
           END IF;

           IF l_amthld_csr%ISOPEN THEN
              CLOSE l_amthld_csr;
           END IF;
           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
          --IF l_astbksv_csr%ISOPEN THEN
           --     CLOSE l_astbksv_csr;
           --END IF;

           IF l_methodcode_csr%ISOPEN THEN
              CLOSE l_methodcode_csr;
           END IF;

           IF l_amthld_csr%ISOPEN THEN
              CLOSE l_amthld_csr;
           END IF;
          -- unexpected error
          OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END process_oplease;


  -- Start of comments
  --
  -- Procedure Name  : process_dfstlease_lessor
  -- Description     : This procedure creates off lease transactions for an asset in DF/Sales lease,
  --                   when tax owner is lessor
  -- Business Rules  :
  -- Parameters      : p_book_rec              : record type parameter with corporate book information
  --                   p_corporate_book        : corporate book
  --                   p_kle_id                : asset line id
  --                   p_df_original_cost      : original cost
  --                   p_oec                   : original equipment cost
  --                   p_net_investment_value  : net investment
  --                   p_try_id                : transaction type id
  --                   p_sysdate               : today's date
  --                   p_func_curr_code        : functional currency code
  -- Version         : 1.0
  -- History         : SECHAWLA 06-APR-04  - Created
  --                   SECHAWLA 28-MAY-04 3645574 - Added deprn rate processing logic for diminishing dep methods
  --                   SECHAWLA 15-DEC-04 4028371 : set FA trx date on trx line
  -- End of comments

  PROCEDURE process_dfstlease_lessor( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 ,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_book_rec              IN   book_rec_type,
                             p_corporate_book        IN   VARCHAR2,
                             p_kle_id                IN   NUMBER,
                             p_df_original_cost      IN   NUMBER,
                             p_oec                   IN   NUMBER,
                             p_net_investment_value  IN   NUMBER,
                             p_try_id                IN  NUMBER,
                             p_sysdate               IN  DATE,
                             p_func_curr_code        IN VARCHAR2,
                             p_legal_entity_id       IN   NUMBER) IS  -- RRAVIKIR Legal Entity Changes

  process_error        EXCEPTION;
   process_unexp_error  EXCEPTION;


  --SECHAWLA 19-FEB-04 3439647 : added life_in_months to the select clause
   -- This cursor will return a method_code corresponding to a unique method_id
   CURSOR l_methodcode_csr(p_method_id fa_methods.method_id%TYPE) IS
   SELECT method_code, life_in_months
   FROM   fa_methods
   WHERE  method_id = p_method_id;


   -- This cursor will return the hold period days and the default depreciation method from a hold period setup table
   -- using category_id and book_type_code.
   CURSOR l_amthld_csr(p_category_id okl_amort_hold_setups.category_id%TYPE,
                       p_book_type_code okl_amort_hold_setups.book_type_code%TYPE) IS
   -- SECHAWLA 28-MAY-04 3645574 : Added deprn_rate
   SELECT hold_period_days, method_id, deprn_rate
   FROM   okl_amort_hold_setups
   WHERE  category_id        = p_category_id
   AND    book_type_code     = p_book_type_code;

   l_hold_period_days           okl_amort_hold_setups.hold_period_days%TYPE;
   l_setup_method_id            okl_amort_hold_setups.method_id%TYPE;
   l_fa_method_code             fa_methods.method_code%TYPE;
   l_fa_life_in_months          fa_methods.life_in_months%TYPE;
   lp_thpv_rec                   thpv_rec_type;
   lx_thpv_rec                  thpv_rec_type;
   lp_tlpv_rec			        tlpv_rec_type;
   lx_tlpv_rec			        tlpv_rec_type;
   lp_empty_thpv_rec            thpv_rec_type;
   lp_empty_tlpv_rec            tlpv_rec_type;

   SUBTYPE  adpv_rec_type IS OKL_TXD_ASSETS_PUB.adpv_rec_type;
   lp_adpv_rec                  adpv_rec_type;
   lx_adpv_rec                  adpv_rec_type;
   lp_empty_adpv_rec            adpv_rec_type;

   -- SECHAWLA 28-MAY-04 3645574 : new declaration
   l_setup_deprn_rate           NUMBER;

   -- SECHAWLA 15-DEC-04 4028371 : new declartions
   l_fa_trx_date				DATE;

   -- SGORANTL 22-MAR-06 5097643 : new declartions
   l_contract_currency_code   VARCHAR2(15);
   l_currency_conversion_type VARCHAR2(30);
   l_currency_conversion_rate NUMBER;
   l_currency_conversion_date DATE;
   l_converted_amount         NUMBER;
   l_orig_cost_contr_currcy    NUMBER; -- orginal cost in contract currency
   l_orig_cost_in_func        NUMBER; -- orginal cost converted to functional currency before the hold period
   l_nest_invest_val_in_func  NUMBER; -- net investment value converted to functional currency before the hold period
   -- end of XILI 22-Feb-06 5029064



  BEGIN


      -- get the hold period and dep method from setup, for each book/category
       -- SECHAWLA 28-MAY-04 3645574 : Added l_setup_deprn_rate

      OPEN  l_amthld_csr(p_book_rec.depreciation_category, p_book_rec.book_type_code);
      FETCH l_amthld_csr INTO l_hold_period_days,l_setup_method_id, l_setup_deprn_rate; --l_setup_deprn_rate could be null;
      CLOSE l_amthld_csr;

      -- If there is a method_id in okl_amort_hold_setups then use it to get deprn method from fa_methods.

      IF l_setup_method_id IS NOT NULL THEN
         OPEN   l_methodcode_csr(l_setup_method_id);
         -- SECHAWLA 19-FEB-04 3439647 : Added l_fa_life_in_months
         FETCH  l_methodcode_csr INTO l_fa_method_code, l_fa_life_in_months;
         IF l_methodcode_csr%NOTFOUND THEN
            --  The depreciation method defined for category DEPRN_CAT and book BOOK is invalid.
            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_INVALID_DEPRN_MTHD',
                                 p_token1        => 'DEPRN_CAT',
                                 p_token1_value  => p_book_rec.depreciation_category,
                                 p_token2        => 'BOOK',
                                 p_token2_value  => p_book_rec.book_type_code);
            RAISE process_error;

         END IF;
         CLOSE  l_methodcode_csr;
      END IF;

      -- SECHAWLA 28-MAY-04 3645574 : Removing this validation, as life is null for diminishing dep methods
      /*
      IF  p_book_rec.life_in_months IS NULL THEN
          -- Life in Months not defined for asset ASSET_NUMBER and book BOOK
          OKL_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      =>  'OKL_AM_NO_LIFE_IN_MONTHS',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  p_book_rec.asset_number,
                                  p_token2        =>  'BOOK',
                                  p_token2_value  =>  p_book_rec.book_type_code);

          RAISE process_error;
      END IF;
      */
      -- SECHAWLA 28-MAY-04 3645574 : new validation, either life or rate should be defined
      IF  p_book_rec.life_in_months IS NULL AND p_book_rec.deprn_rate IS NULL THEN
          -- Either Life in Months or Depreciation Rate should be defined for asset ASSET_NUMBER and book BOOK.
          OKL_API.set_message(  p_app_name        => 'OKL',
                                  p_msg_name      => 'OKL_AM_NO_LIFE_NO_RATE',
                                  p_token1        => 'ASSET_NUMBER',
                                  p_token1_value  =>  p_book_rec.asset_number,
                                  p_token2        => 'BOOK',
                                  p_token2_value  => p_book_rec.book_type_code);
          RAISE process_error;
      END IF;
      -- SECHAWLA 28-MAY-04 3645574 : end new validation
      -------------------

      --SECHAWLA 15-DEC-04 4028371 : get FA trx date
      OKL_ACCOUNTING_UTIL.get_fa_trx_date(p_book_type_code => p_book_rec.book_type_code,
      								      x_return_status  => x_return_status,
   										  x_fa_trx_date    => l_fa_trx_date);

   	  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE process_unexp_error;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE process_error;
      END IF;

     -- SGORANTL 22-MAR-06 5097643 : convert original_cost and depreciation_cost to functional currency
      IF p_df_original_cost IS NOT NULL THEN
          l_orig_cost_contr_currcy 	:= p_df_original_cost;
      ELSE
          l_orig_cost_contr_currcy 	:= p_oec;
      END IF;

      -- convert orginal cost to functional currency, XILI 22-Feb-06 5029064
      OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
          p_khr_id  		  	          => p_book_rec.dnz_chr_id,
          p_to_currency   		        => p_func_curr_code,
          p_transaction_date 		      => p_sysdate,
          p_amount 			              => l_orig_cost_contr_currcy,
          x_return_status             => x_return_status,
          x_contract_currency		      => l_contract_currency_code,
          x_currency_conversion_type  => l_currency_conversion_type,
          x_currency_conversion_rate  => l_currency_conversion_rate,
          x_currency_conversion_date	=> l_currency_conversion_date,
          x_converted_amount 		      => l_converted_amount);

       IF (x_return_status  <> OKC_API.G_RET_STS_SUCCESS) THEN
           RAISE process_unexp_error;
       END IF;

       l_orig_cost_in_func := l_converted_amount;

      -- convert net investment cost to functional currency, XILI 22-Feb-06 5029064
      OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
          p_khr_id  		  	          => p_book_rec.dnz_chr_id,
          p_to_currency   		        => p_func_curr_code,
          p_transaction_date 		      => p_sysdate,
          p_amount 			              => p_net_investment_value,
          x_return_status             => x_return_status,
          x_contract_currency		      => l_contract_currency_code,
          x_currency_conversion_type  => l_currency_conversion_type,
          x_currency_conversion_rate  => l_currency_conversion_rate,
          x_currency_conversion_date	=> l_currency_conversion_date,
          x_converted_amount 		      => l_converted_amount);

       IF (x_return_status  <> OKC_API.G_RET_STS_SUCCESS) THEN
           RAISE process_unexp_error;
       END IF;

      l_nest_invest_val_in_func := l_converted_amount;
     -- end of SGORANTL 22-MAR-06 5097643 : convert original_cost and depreciation_cost to functional currency

	OKL_API.set_message('OKL', 'orig_cost=');



      IF l_hold_period_days IS NOT NULL AND l_hold_period_days <> 0 THEN -- SECHAWLA 03-JUN-04 Added check for 0 hold period days


          -- SECHAWLA 06-MAY-04 3578894 : Split the 1st trx into 2 trasnactions : First Stop the depreciation
          -- and then update the cost. Split 2nd trx into 2 trasnactions : first update the dep method, life,
          -- cost, sv and then start the depreciation. This is required because FA does not allow updating depreciation
          -- flag with any other attributes. Details in bug 3501172

           -- SECHAWLA 19-FEB-04 3439647 : Write asset cost up to the net investment and stop the dpreciation
           -- Start the depreciation when hold period expires

           -- Create 1st transaction header

           -- SECHAWLA 06-MAY-04  3578894 : Use a diff tas_type for dep flag only updates
           --lp_thpv_rec.tas_type := 'AMT';
           lp_thpv_rec.tas_type := 'AUD'; -- new tas_type


           lp_thpv_rec.tsu_code := 'ENTERED';

           lp_thpv_rec.try_id   :=  p_try_id;
           lp_thpv_rec.date_trans_occurred := p_sysdate;
           -- RRAVIKIR Legal Entity Changes
           lp_thpv_rec.legal_entity_id := p_legal_entity_id;
           -- Legal Entity Changes End

           OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		    p_init_msg_list         => OKL_API.G_FALSE,
           					    x_return_status         => x_return_status,
           					    x_msg_count             => x_msg_count,
           					    x_msg_data              => x_msg_data,
						    p_thpv_rec		        => lp_thpv_rec,
						    x_thpv_rec		        => lx_thpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;

            -- Create 1st transaction line to update asset cost and stop depreciation
            lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
            lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
            lp_tlpv_rec.kle_id 			    := p_kle_id;
            lp_tlpv_rec.line_number 		:= 1;

            --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for dep flag only updates
            --lp_tlpv_rec.tal_type 		    := 'AML';
            lp_tlpv_rec.tal_type 		    := 'AUF'; -- new tal_type

	        lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
            lp_tlpv_rec.description         := p_book_rec.item_description;

            -- SECHAWLA 06-MAY-04 3578894 : deprn method and life are populated in the 1st trx for display on
            -- off lease details screen. These will not be processed in FA when 1st trx is processed
            lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code; -- original dep method

            -- SECHAWLA 28-MAY-04 3645574 : Store either life or rate
            IF p_book_rec.life_in_months IS NOT NULL THEN
               lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
            ELSE
               lp_tlpv_rec.deprn_rate  := p_book_rec.deprn_rate;
            END IF;


            lp_tlpv_rec.corporate_book 		:= p_corporate_book;

            -- SECHAWLA 06-MAY-04 3578894 : Do not update cost in 1st trx. Only update the depreciate_yn flag
            -- lp_tlpv_rec.depreciation_cost 	:= l_net_investment_value;

            -- populate sv for display on off lse upd screen
            lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

/* -- SGORANTL 22-Feb-06 5097643

            IF p_df_original_cost IS NOT NULL THEN
               lp_tlpv_rec.original_cost 		:= p_df_original_cost;
            ELSE
               lp_tlpv_rec.original_cost 		:= p_oec;
            END IF;
*/

            lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; --rmunjulu bug 6766343 - Added to pass asset orginal cost

            lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
            lp_tlpv_rec.hold_period_days	:= l_hold_period_days;
            lp_tlpv_rec.depreciate_yn	 	:= 'N';
            lp_tlpv_rec.dnz_asset_id		:= to_number(p_book_rec.asset_id);
            lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
            lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

            --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
            lp_tlpv_rec.currency_code := p_func_curr_code;

            -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
            lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

            OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;


            -- When process_dfstlease_lessor procedure is called with mg rep book (tax book), then
            -- we need to create tax book trx also.
            IF p_book_rec.book_type_code <> p_corporate_book THEN
               IF p_book_rec.book_class = 'TAX' THEN
                  lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                  lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                  lp_adpv_rec.asset_number := p_book_rec.asset_number;
                  OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                       RAISE process_unexp_error;
                   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                       RAISE process_error;
                   END IF;
               END IF;

            END IF;
            ----------------------------------

            -- Validations for 2nd trx (if any) shold go here


            -- SECHAWLA 06-MAY-04 3578894 : Create 2nd trx (split from 1st) to update asset cost

            -- Initialize the trx hdr and line for each trx
            lp_thpv_rec := lp_empty_thpv_rec;
            lp_tlpv_rec := lp_empty_tlpv_rec;
            lp_adpv_rec := lp_empty_adpv_rec;

            -- SECHAWLA 22-MAR-04 : use a diff tas_type for cost only updates
            --lp_thpv_rec.tas_type := 'AMT';
            lp_thpv_rec.tas_type := 'AUS'; -- new tas_type


            lp_thpv_rec.tsu_code := 'ENTERED';

            lp_thpv_rec.try_id   :=  p_try_id;
            lp_thpv_rec.date_trans_occurred := p_sysdate;
            -- RRAVIKIR Legal Entity Changes
            lp_thpv_rec.legal_entity_id := p_legal_entity_id;
            -- Legal Entity Changes End

            OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		     p_init_msg_list         => OKL_API.G_FALSE,
           					     x_return_status         => x_return_status,
           					     x_msg_count             => x_msg_count,
           					     x_msg_data              => x_msg_data,
						     p_thpv_rec		        => lp_thpv_rec,
						     x_thpv_rec		        => lx_thpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;

            -- Create 2nd transaction line to update asset cost
            lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
            lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
            lp_tlpv_rec.kle_id 			    := p_kle_id;
   	        lp_tlpv_rec.line_number 		:= 1;

            --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for cost only updates
            --lp_tlpv_rec.tal_type 		    := 'AML';
            lp_tlpv_rec.tal_type 		    := 'AUT'; -- new tal_type

	        lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
            lp_tlpv_rec.description         := p_book_rec.item_description;

            -- SECHAWLA 06-MAY-04 3578894 : deprn method and life are populated in the 2nd trx for display on
            -- off lease details screen. These will not be processed in FA when 2nd trx is processed
            lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code; -- original dep method

            -- SECHAWLA 28-MAY-04 3645574 : Store either life or rate
            IF p_book_rec.life_in_months IS NOT NULL THEN
               lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
            ELSE
               lp_tlpv_rec.deprn_rate  := p_book_rec.deprn_rate;
            END IF;

            lp_tlpv_rec.corporate_book 		:= p_corporate_book;

            --SECHAWLA 06-MAY-04 3578894 : Update cost
/* -- SGORANTL 22-MAR-06 5097643

            lp_tlpv_rec.depreciation_cost 	:= p_net_investment_value; -- This would be reporting NIV if this
                                                                               -- procedure is called for reporting book
                                                                               -- Otherwise it would have base NIV value

            IF p_df_original_cost IS NOT NULL THEN
               lp_tlpv_rec.original_cost 	:= p_df_original_cost;
            ELSE
               lp_tlpv_rec.original_cost 	:= p_oec;
            END IF;
*/
         -- rmunjulu bug 6766343  - Pass depreciation cost and original cost
         lp_tlpv_rec.depreciation_cost       := l_nest_invest_val_in_func;
         lp_tlpv_rec.original_cost           := l_orig_cost_in_func;

	        lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
	        lp_tlpv_rec.hold_period_days	:= l_hold_period_days;

            -- SECHAWLA 06-MAY-04 3578894 : Depreciate_yn flag is set here and also in the 1st trx,so the process
            -- asset trx program can identify that these are split transactions. When this trx is processed, the flag
            -- is not updated in FA. Only cost will be updated
	        lp_tlpv_rec.depreciate_yn	 	:= 'N';

            -- populate sv for display on off lse upd screen
            lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

	        lp_tlpv_rec.dnz_asset_id		:= to_number(p_book_rec.asset_id);
            lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
            lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

            --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
            lp_tlpv_rec.currency_code := p_func_curr_code;

            -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx line
            lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	        OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;

            -- When process_dfstlease_lessor procedure is called with mg rep book (tax book), then
            -- we need to create tax book trx also.
            IF p_book_rec.book_type_code <> p_corporate_book THEN
                 IF p_book_rec.book_class = 'TAX' THEN
                       lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                       lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                       lp_adpv_rec.asset_number := p_book_rec.asset_number;
                       OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE process_unexp_error;
                       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                           RAISE process_error;
                       END IF;
                 END IF;

            END IF;

            -- SECHAWLA 06-MAY-04 3578894 : end 2nd trx
            -----------------------------------

            -- Validations for 3rd trx (if any) should go here


            -- SECHAWLA 06-MAY-04 3578894 : Split the 2nd trx into 2 transactions : first update dep method, life,
            -- cost, sv  and then start the depreciation

            -- Initialize the trx hdr and line for each trx
            lp_thpv_rec := lp_empty_thpv_rec;
            lp_tlpv_rec := lp_empty_tlpv_rec;
            lp_adpv_rec := lp_empty_adpv_rec;

            -- Create 3rd Transaction Header
            lp_thpv_rec.tas_type := 'AMT';

            lp_thpv_rec.tsu_code := 'ENTERED';


            lp_thpv_rec.try_id   :=  p_try_id;
            lp_thpv_rec.date_trans_occurred := p_sysdate + l_hold_period_days;
            -- RRAVIKIR Legal Entity Changes
            lp_thpv_rec.legal_entity_id := p_legal_entity_id;
            -- Legal Entity Changes End

            OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		     p_init_msg_list         => OKL_API.G_FALSE,
           					     x_return_status         => x_return_status,
           					     x_msg_count             => x_msg_count,
           					     x_msg_data              => x_msg_data,
						     p_thpv_rec		        => lp_thpv_rec,
						     x_thpv_rec		        => lx_thpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;

            -- create 3rd transaction line
            lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
            lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
            lp_tlpv_rec.kle_id 			    := p_kle_id;
            lp_tlpv_rec.line_number 		:= 1;
            lp_tlpv_rec.tal_type 		    := 'AML';
	        lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
            lp_tlpv_rec.description         := p_book_rec.item_description;

            -- SECHAWLA 19-FEB-04 3439647
            --lp_tlpv_rec.life_in_months      := l_life_in_months;

            -- If there is a method_id in okl_amort_hold_setups then use it. Otherwise get method id
            -- from fa_methods

            IF l_setup_method_id IS NOT NULL THEN
                lp_tlpv_rec.deprn_method        := l_fa_method_code;

                -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
                IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
                   lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
                ELSE
                   -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
                   lp_tlpv_rec.life_in_months      := l_fa_life_in_months;
                END IF;
            ELSE
                lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code;

                -- SECHAWLA 28-MAY-04 3645574: store either life or rate
                IF p_book_rec.life_in_months IS NOT NULL THEN
                   -- SECHAWLA 19-FEB-04 3439647 : use original life in months
                   lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
                ELSE
                   lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
                END IF;
            END IF;

            lp_tlpv_rec.corporate_book 		:= p_corporate_book;


            --In case of direct finance/sales type of lease,Asset will exist in the corporate book, but with the Cost
            --and Original cost set to zero. Get Original cost from original creation line in Txl_assets, if it is
            --not found, then use OEC from OKL_K_LINES.OEC of the top financial asset line.

            -- SECHAWLA 19-FEB-04 3439647 : Always update cost with net investment. At the end of the term, net investment = rv
            --IF p_early_termination_yn = 'N' THEN
            --lp_tlpv_rec.depreciation_cost 	:= l_residual_value;
            --ELSE

            -- SECHAWLA 19-FEB-04 3439647 : Moved this piece of code to the beginning
            ---  /*okl_am_util_pvt.get_formula_value(
            --      p_formula_name	=> G_NET_INVESTMENT_FORMULA,
            --      p_chr_id	        => l_dnz_chr_id,
            --      p_cle_id	        => p_kle_id,
		    --     x_formula_value	=> l_net_investment_value,
		    --     x_return_status	=> x_return_status);

            -- IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            --      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            --   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            --       RAISE OKL_API.G_EXCEPTION_ERROR;
            --   END IF;
            --   */
/* -- SGORANTL 22-MAR-06 5097643

            lp_tlpv_rec.depreciation_cost 	:= p_net_investment_value;

            -- END IF;


            lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;
            IF p_df_original_cost IS NOT NULL THEN
               lp_tlpv_rec.original_cost 		:= p_df_original_cost;
            ELSE
               lp_tlpv_rec.original_cost 		:= p_oec;
            END IF;
*/

            lp_tlpv_rec.depreciation_cost 	:= l_nest_invest_val_in_func; -- XILI 22-Feb-06 5029064
            lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- XILI 22-Feb-06 5029064
            lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;
            lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
            lp_tlpv_rec.hold_period_days	:= l_hold_period_days;


            -- SECHAWLA 06-MAY-04 3578894 : Depreciate_yn flag is set here and also in the 4th trx,so the process
            -- asset trx program can identify that these are split transactions. When this trx is processed, the flag
            -- is not updated in FA. Only dep method, life, cost and sv will be updated
	        lp_tlpv_rec.depreciate_yn	 	:= 'Y';

	        lp_tlpv_rec.dnz_asset_id		:= to_number(p_book_rec.asset_id);
            lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
            lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

            --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
            lp_tlpv_rec.currency_code := p_func_curr_code;

            -- SECHAWLA 15-NOV-04  : set FA date on trx line
            lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	        OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;


            -- When process_dfstlease_lessor procedure is called with mg rep book (tax book), then
            -- we need to create tax book trx also.
            IF p_book_rec.book_type_code <> p_corporate_book THEN
               IF p_book_rec.book_class = 'TAX' THEN
                     lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                     lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                     lp_adpv_rec.asset_number := p_book_rec.asset_number;
                     OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE process_unexp_error;
                     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         RAISE process_error;
                     END IF;
               END IF;

           END IF;
           -----------------------------------------------------

           -- Validations for 4th trx (if any) shold go here


           -- SECHAWLA 06-MAY-04 3578894 : Create 4th trx (split from 3rd)

           -- Initialize the trx hdr and line for each trx
           lp_thpv_rec := lp_empty_thpv_rec;
           lp_tlpv_rec := lp_empty_tlpv_rec;
           lp_adpv_rec := lp_empty_adpv_rec;

           -- Create 4th Transaction Header

           --SECHAWLA 06-MAY-04 3578894 : Use a diff tas_type for dep flag only updates

           lp_thpv_rec.tas_type := 'AUD';  -- new tas_type


           lp_thpv_rec.tsu_code := 'ENTERED';

           lp_thpv_rec.try_id   :=  p_try_id;
           lp_thpv_rec.date_trans_occurred := p_sysdate + l_hold_period_days;
           -- RRAVIKIR Legal Entity Changes
           lp_thpv_rec.legal_entity_id := p_legal_entity_id;
           -- Legal Entity Changes End

           OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		    p_init_msg_list         => OKL_API.G_FALSE,
           					    x_return_status         => x_return_status,
           					    x_msg_count             => x_msg_count,
           					    x_msg_data              => x_msg_data,
						    p_thpv_rec		        => lp_thpv_rec,
						    x_thpv_rec		        => lx_thpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;

            -- create 4th transaction line
            lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
            lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
            lp_tlpv_rec.kle_id 			    := p_kle_id;
            lp_tlpv_rec.line_number 		:= 1;

            --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for dep flag only updates
            --lp_tlpv_rec.tal_type 		    := 'AML';
            lp_tlpv_rec.tal_type 		    := 'AUF'; -- new tal_type

	        lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
            lp_tlpv_rec.description         := p_book_rec.item_description;


            lp_tlpv_rec.corporate_book 		:= p_corporate_book;
       /* -- SGORANTL 22-MAR-06 5097643

            IF p_df_original_cost IS NOT NULL THEN
               lp_tlpv_rec.original_cost 	:= p_df_original_cost;
            ELSE
               lp_tlpv_rec.original_cost 	:= p_oec;
            END IF;
       */

            lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- XILI 22-Feb-06 5029064
            lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
            lp_tlpv_rec.hold_period_days	:= l_hold_period_days;

            -- SECHAWLA 06-MAY-04 3578894 : Start the depreciation. Dep method, life, cost and sv are null
            -- when 4th trx is processed, only the dep flag will get updated
	        lp_tlpv_rec.depreciate_yn	 	:= 'Y';

            -- SECHAWLA 06-MAY-04 3578894 : populate dep method, life and sv for display on off lse trx upd screen
            IF l_setup_method_id IS NOT NULL THEN
               lp_tlpv_rec.deprn_method     := l_fa_method_code;

               -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
               IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
                  lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
               ELSE
                 -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
                 lp_tlpv_rec.life_in_months   := l_fa_life_in_months;
               END IF;
            ELSE
               lp_tlpv_rec.deprn_method     := p_book_rec.deprn_method_code;

               -- SECHAWLA 28-MAY-04 3645574: store either life or rate
               IF p_book_rec.life_in_months IS NOT NULL THEN
                  -- SECHAWLA 19-FEB-04 3439647 : use original life in months
                  lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
               ELSE
                  lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
               END IF;
            END IF;
            lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

	        lp_tlpv_rec.dnz_asset_id		:= to_number(p_book_rec.asset_id);
            lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
            lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

            --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
            lp_tlpv_rec.currency_code := p_func_curr_code;

            -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
            lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	        OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;

            -- When process_dfstlease_lessor procedure is called with mg rep book (tax book), then
            -- we need to create tax book trx also.
            IF p_book_rec.book_type_code <> p_corporate_book THEN
               IF p_book_rec.book_class = 'TAX' THEN
                   lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                   lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                   lp_adpv_rec.asset_number := p_book_rec.asset_number;
                   OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE process_unexp_error;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE process_error;
                    END IF;
              END IF;

           END IF;

      ELSE  -- Hold period is null or 0

           -- Split this trx into 2 trasnactions : first update dep method, life, cost, sv and then start depreciation


           -- Create 1st Transaction Header

           lp_thpv_rec.tas_type := 'AMT';

           lp_thpv_rec.tsu_code := 'ENTERED';

           lp_thpv_rec.try_id   :=  p_try_id;
           lp_thpv_rec.date_trans_occurred := p_sysdate;
           -- RRAVIKIR Legal Entity Changes
           lp_thpv_rec.legal_entity_id := p_legal_entity_id;
           -- Legal Entity Changes End

           OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		    p_init_msg_list         => OKL_API.G_FALSE,
           					    x_return_status         => x_return_status,
           					    x_msg_count             => x_msg_count,
           					    x_msg_data              => x_msg_data,
						    p_thpv_rec		        => lp_thpv_rec,
						    x_thpv_rec		        => lx_thpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE process_error;
            END IF;

            -- create transaction line
            lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
            lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
            lp_tlpv_rec.kle_id 			    := p_kle_id;
            lp_tlpv_rec.line_number 	   	:= 1;
            lp_tlpv_rec.tal_type 		    := 'AML';
	        lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
            lp_tlpv_rec.description         := p_book_rec.item_description;

            -- SECHAWLA 19-FEB-04 3439647
            --lp_tlpv_rec.life_in_months       := l_life_in_months;

            -- If there is a method_id in okl_amort_hold_setups then use it. Otherwise get method id
            -- from fa_methods

            IF l_setup_method_id IS NOT NULL THEN
               lp_tlpv_rec.deprn_method        := l_fa_method_code;

               -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
               IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
                  lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
               ELSE
                  -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
                  lp_tlpv_rec.life_in_months      := l_fa_life_in_months;
               END IF;
            ELSE
               lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code;

               -- SECHAWLA 28-MAY-04 3645574: store either life or rate
               IF p_book_rec.life_in_months IS NOT NULL THEN
                  -- SECHAWLA 19-FEB-04 3439647 : use original life in months
                  lp_tlpv_rec.life_in_months       := p_book_rec.life_in_months;
               ELSE
                  lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
               END IF;
            END IF;

            lp_tlpv_rec.corporate_book 		:= p_corporate_book;
            lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

            --In case of direct finance/sales type of lease,Asset will exist in the corporate book, but with the Cost
            --and Original cost set to zero. Get Original cost from original creation line in Txl_assets, if it is
            --not found, then use OEC from OKL_K_LINES.OEC of the top financial asset line.

            -- SECHAWLA 19-FEB-04 3439647 : Always update cost with net investment. At the end of the term, net investment = rv
            --IF p_early_termination_yn = 'N' THEN
            --  lp_tlpv_rec.depreciation_cost 	:= l_residual_value;
            -- ELSE

            -- SECHAWLA 19-FEB-04 3439647 : Moved this piece of code to the beginning
            --  /*
            --   okl_am_util_pvt.get_formula_value(
            --   p_formula_name	=> G_NET_INVESTMENT_FORMULA,
            --    p_chr_id	        => l_dnz_chr_id,
            --    p_cle_id	        => p_kle_id,
            --    x_formula_value	=> l_net_investment_value,
		    --     x_return_status	=> x_return_status);

            --    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            --    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            --     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            --    RAISE OKL_API.G_EXCEPTION_ERROR;
            --    END IF;
            --    */
            lp_tlpv_rec.depreciation_cost 	:= p_net_investment_value;

            --  END IF;
           /* -- SGORANTL 22-MAR-06 5097643

            IF p_df_original_cost IS NOT NULL THEN
               lp_tlpv_rec.original_cost 	:= p_df_original_cost;
            ELSE
               lp_tlpv_rec.original_cost 	:= p_oec;
            END IF;
           */

            lp_tlpv_rec.depreciation_cost 	:= l_nest_invest_val_in_func; -- SGORANTL 22-MAR-06 5097643
            lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- SGORANTL 22-MAR-06 5097643
            lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
            -- SECHAWLA 06-MAY-04 3578894 : Depreciate_yn flag is set here and also in the 2nd trx,so the process
            -- asset trx program can identify that these are split transactions. When this trx is processed, the flag
            -- is not updated in FA. Only dep method, life, cost and sv will be updated
            lp_tlpv_rec.depreciate_yn	 	:= 'Y';

	        lp_tlpv_rec.dnz_asset_id	   	:= to_number(p_book_rec.asset_id);
            lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
            lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

            --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets

            lp_tlpv_rec.currency_code       := p_func_curr_code;

			-- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
            lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	        OKL_TXL_ASSETS_PUB.create_txl_asset_def( p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE process_error;
            END IF;


            -- When process_dfstlease_lessor procedure is called with mg rep book (tax book), then
            -- we need to create tax book trx also.
            IF p_book_rec.book_type_code <> p_corporate_book THEN
               IF p_book_rec.book_class = 'TAX' THEN
                    lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                    lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                    lp_adpv_rec.asset_number := p_book_rec.asset_number;
                    OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE process_unexp_error;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE process_error;
                    END IF;
               END IF;

           END IF;
           -------------------------------------------------

           -- Validations for 2nd trx (if any) should go here


           --SECHAWLA 06-MAY-04 3578894 : Create 2nd trx to start the depreciation

           -- Initialize the trx hdr and line for each trx
           lp_thpv_rec := lp_empty_thpv_rec;
           lp_tlpv_rec := lp_empty_tlpv_rec;
           lp_adpv_rec := lp_empty_adpv_rec;

           -- Create 2nd Transaction Header

           -- SECHAWLA 06-MAY-04 3578894 : use a diff tas_type from dep flag only updates
           --lp_thpv_rec.tas_type := 'AMT';
           lp_thpv_rec.tas_type := 'AUD';  -- new tas_type

           lp_thpv_rec.tsu_code := 'ENTERED';
           lp_thpv_rec.try_id   :=  p_try_id;
           lp_thpv_rec.date_trans_occurred := p_sysdate;
           -- RRAVIKIR Legal Entity Changes
           lp_thpv_rec.legal_entity_id := p_legal_entity_id;
           -- Legal Entity Changes End

           OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
          			       		    p_init_msg_list         => OKL_API.G_FALSE,
           					    x_return_status         => x_return_status,
           					    x_msg_count             => x_msg_count,
           					    x_msg_data              => x_msg_data,
						    p_thpv_rec		        => lp_thpv_rec,
						    x_thpv_rec		        => lx_thpv_rec);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE process_unexp_error;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE process_error;
           END IF;

           -- create 2nd transaction line
           lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
           lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
           lp_tlpv_rec.kle_id 			    := p_kle_id;
           lp_tlpv_rec.line_number 	   	:= 1;

           --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for dep flag only updates
           --lp_tlpv_rec.tal_type 		    := 'AML';
           lp_tlpv_rec.tal_type 		    := 'AUF'; -- new tal_type

	       lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
           lp_tlpv_rec.description         := p_book_rec.item_description;

           lp_tlpv_rec.corporate_book 		:= p_corporate_book;

            /* -- SGORANTL 22-MAR-06 5097643

           IF p_df_original_cost IS NOT NULL THEN
              lp_tlpv_rec.original_cost 	:= p_df_original_cost;
           ELSE
              lp_tlpv_rec.original_cost 	:= p_oec;
           END IF;
           */

           lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- SGORANTL 22-MAR-06 5097643
           lp_tlpv_rec.current_units 		:= p_book_rec.current_units;

           -- SECHAWLA 06-MAY-04 3578894 : start the depreciation. dep method, life, cost and sv are null. When
           -- this trx is processed in FA, only dep flag will be updated.
           lp_tlpv_rec.depreciate_yn	 	:= 'Y';

           -- SECHAWLA 06-MAY-04 3578894 : populate dep method, life and sv for display on off lse trx upd screen
           IF l_setup_method_id IS NOT NULL THEN
              lp_tlpv_rec.deprn_method    := l_fa_method_code;

              -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
              IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
                 lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
              ELSE
                 -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
                 lp_tlpv_rec.life_in_months  := l_fa_life_in_months;
              END IF;
           ELSE
              lp_tlpv_rec.deprn_method    := p_book_rec.deprn_method_code;

              -- SECHAWLA 28-MAY-04 3645574: store either life or rate
              IF p_book_rec.life_in_months IS NOT NULL THEN
                 -- SECHAWLA 19-FEB-04 3439647 : use original life in months
                 lp_tlpv_rec.life_in_months       := p_book_rec.life_in_months;
              ELSE
                 lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
              END IF;
           END IF;
           lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

	       lp_tlpv_rec.dnz_asset_id	  	:= to_number(p_book_rec.asset_id);
           lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
           lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

           --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
           lp_tlpv_rec.currency_code       := p_func_curr_code;

		   -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
           lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

           OKL_TXL_ASSETS_PUB.create_txl_asset_def( p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
           END IF;

            -- When process_dfstlease_lessor procedure is called with mg rep book (tax book), then
            -- we need to create tax book trx also.
            IF p_book_rec.book_type_code <> p_corporate_book THEN
                IF p_book_rec.book_class = 'TAX' THEN
                    lp_adpv_rec.tal_id := lx_tlpv_rec.id;
                    lp_adpv_rec.tax_book := p_book_rec.book_type_code;
                    lp_adpv_rec.asset_number := p_book_rec.asset_number;
                    OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE process_unexp_error;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE process_error;
                    END IF;
                END IF;

           END IF;

     END IF; -- hold period days is null


   EXCEPTION
      WHEN process_error THEN
           IF l_methodcode_csr%ISOPEN THEN
              CLOSE l_methodcode_csr;
           END IF;

           IF l_amthld_csr%ISOPEN THEN
              CLOSE l_amthld_csr;
           END IF;


           x_return_status := OKL_API.G_RET_STS_ERROR;
      WHEN process_unexp_error THEN

           IF l_methodcode_csr%ISOPEN THEN
              CLOSE l_methodcode_csr;
           END IF;

           IF l_amthld_csr%ISOPEN THEN
              CLOSE l_amthld_csr;
           END IF;

           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN

          IF l_methodcode_csr%ISOPEN THEN
              CLOSE l_methodcode_csr;
           END IF;

           IF l_amthld_csr%ISOPEN THEN
              CLOSE l_amthld_csr;
           END IF;
          -- unexpected error
          OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END process_dfstlease_lessor;


  -- Start of comments
  --
  -- Procedure Name  : process_dfstlease_lessee
  -- Description     : This procedure creates off lease transactions for an asset in DF/Sales lease,
  --                   when tax owner is lessee
  -- Business Rules  :
  -- Parameters      : p_book_rec              : record type parameter with corporate/tax book information
  --                   p_corporate_book        : corporate book
  --                   p_kle_id                : asset line id
  --                   p_df_original_cost      : original cost
  --                   p_oec                   : original equipment cost
  --                   p_net_investment_value  : net investment
  --                   p_try_id                : transaction type id
  --                   p_sysdate               : today's date
  --                   p_func_curr_code        : functional currency code
  -- Version         : 1.0
  -- History         : SECHAWLA 06-APR-04  - Created
  --                   SECHAWLA 28-MAY-04 3645574 : Added processing logic for deprn rate for diminishing dep methods
  --                   SECHAWLA 15-DEC-04 4028371 : set FA trx date on trx line
  -- End of comments

  PROCEDURE process_dfstlease_lessee( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 ,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_book_rec              IN   book_rec_type,
                             p_corporate_book        IN   VARCHAR2,
                             p_kle_id                IN   NUMBER,
                             p_df_original_cost      IN   NUMBER,
                             p_oec                   IN   NUMBER,
                             p_net_investment_value  IN   NUMBER,
                             p_try_id                IN  NUMBER,
                             p_sysdate               IN  DATE,
                             p_func_curr_code        IN VARCHAR2,
                             p_legal_entity_id       IN   NUMBER) IS  -- RRAVIKIR Legal Entity Changes

   process_error      EXCEPTION;
   process_unexp_error  EXCEPTION;



  --SECHAWLA 19-FEB-04 3439647 : added life_in_months to the select clause
   -- This cursor will return a method_code corresponding to a unique method_id
   CURSOR l_methodcode_csr(p_method_id fa_methods.method_id%TYPE) IS
   SELECT method_code, life_in_months
   FROM   fa_methods
   WHERE  method_id = p_method_id;



   -- This cursor will return the hold period days and the default depreciation method from a hold period setup table
   -- using category_id and book_type_code.
   CURSOR l_amthld_csr(p_category_id okl_amort_hold_setups.category_id%TYPE,
                       p_book_type_code okl_amort_hold_setups.book_type_code%TYPE) IS
   -- SECHAWLA 28-MAY-04 3645574 : Added deprn_rate
   SELECT hold_period_days, method_id, deprn_rate
   FROM   okl_amort_hold_setups
   WHERE  category_id        = p_category_id
   AND    book_type_code     = p_book_type_code;

   l_hold_period_days           okl_amort_hold_setups.hold_period_days%TYPE;
   l_setup_method_id            okl_amort_hold_setups.method_id%TYPE;
   l_fa_method_code             fa_methods.method_code%TYPE;
   l_fa_life_in_months          fa_methods.life_in_months%TYPE;
   lp_thpv_rec                   thpv_rec_type;
   lx_thpv_rec                  thpv_rec_type;
   lp_tlpv_rec			        tlpv_rec_type;
   lx_tlpv_rec			        tlpv_rec_type;
   lp_empty_thpv_rec            thpv_rec_type;
   lp_empty_tlpv_rec            tlpv_rec_type;
   SUBTYPE  adpv_rec_type IS OKL_TXD_ASSETS_PUB.adpv_rec_type;
   lp_adpv_rec                  adpv_rec_type;
   lx_adpv_rec                  adpv_rec_type;
   lp_empty_adpv_rec            adpv_rec_type;

   -- SECHAWLA 28-MAY-04 3645574 : new declaration
   l_setup_deprn_rate           NUMBER;

   -- SECHAWLA 15-DEC-04 4028371 : new declartions
   l_fa_trx_date				DATE;

   -- SGORANTL 22-MAR-06 5097643 : new declartions
   l_contract_currency_code   VARCHAR2(15);
   l_currency_conversion_type VARCHAR2(30);
   l_currency_conversion_rate NUMBER;
   l_currency_conversion_date DATE;
   l_converted_amount         NUMBER;
   l_orig_cost_contr_currcy    NUMBER; -- orginal cost in contract currency
   l_orig_cost_in_func        NUMBER; -- orginal cost converted to functional currency before the hold period
   l_nest_invest_val_in_func  NUMBER; -- net investment value converted to functional currency before the hold period
   -- end of SGORANTL 22-MAR-06 5097643



  BEGIN
  -- get the hold period and dep method from setup, for each book/category
     OPEN  l_amthld_csr(p_book_rec.depreciation_category, p_book_rec.book_type_code);
     -- SECHAWLA 28-MAY-04 3645574 : Added l_setup_deprn_rate
     FETCH l_amthld_csr INTO l_hold_period_days,l_setup_method_id, l_setup_deprn_rate; --l_setup_deprn_rate could be null;
     CLOSE l_amthld_csr;



     -- If there is a method_id in okl_amort_hold_setups then use it to get deprn method from fa_methods.

     IF l_setup_method_id IS NOT NULL THEN
        OPEN   l_methodcode_csr(l_setup_method_id);
        -- SECHAWLA 19-FEB-04 3439647 : Added l_fa_life_in_months
        FETCH  l_methodcode_csr INTO l_fa_method_code, l_fa_life_in_months;
        IF l_methodcode_csr%NOTFOUND THEN
           --  The depreciation method defined for category DEPRN_CAT and book BOOK is invalid.
           OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_INVALID_DEPRN_MTHD',
                                     p_token1        => 'DEPRN_CAT',
                                     p_token1_value  => p_book_rec.depreciation_category,
                                     p_token2        => 'BOOK',
                                     p_token2_value  => p_book_rec.book_type_code);
           RAISE process_error;

        END IF;
        CLOSE  l_methodcode_csr;
    END IF;

    -- SECHAWLA 28-MAY-04 3645574 : Removing this validation, as life is null for diminishing dep methods
    /*
    IF  p_book_rec.life_in_months IS NULL THEN
        -- Life in Months not defined for asset
        OKL_API.set_message(  p_app_name      => 'OKL',
                              p_msg_name      => 'OKL_AM_NO_LIFE_IN_MONTHS',
                              p_token1        =>  'ASSET_NUMBER',
                              p_token1_value  =>  p_book_rec.asset_number,
                              p_token2        =>  'BOOK',
                              p_token2_value  =>  p_book_rec.book_type_code);
        RAISE process_error;
    END IF;
    */

    -- SECHAWLA 28-MAY-04 3645574 : new validation, eithr life or rate should be defined
      IF  p_book_rec.life_in_months IS NULL AND p_book_rec.deprn_rate IS NULL THEN
          -- Either Life in Months or Depreciation Rate should be defined for asset ASSET_NUMBER and book BOOK.
          OKL_API.set_message(  p_app_name        => 'OKL',
                                  p_msg_name      => 'OKL_AM_NO_LIFE_NO_RATE',
                                  p_token1        => 'ASSET_NUMBER',
                                  p_token1_value  =>  p_book_rec.asset_number,
                                  p_token2        => 'BOOK',
                                  p_token2_value  => p_book_rec.book_type_code);
          RAISE process_error;
      END IF;
      -- SECHAWLA 28-MAY-04 3645574 : end new validation
    -------------------
    --SECHAWLA 15-DEC-04 4028371 : get FA trx date
     OKL_ACCOUNTING_UTIL.get_fa_trx_date(p_book_type_code => p_book_rec.book_type_code,
      								  	 x_return_status  => x_return_status,
   										 x_fa_trx_date    => l_fa_trx_date);

   	 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE process_unexp_error;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE process_error;
     END IF;

     -- SGORANTL 22-MAR-06 5097643 : convert original_cost and depreciation_cost to functional currency
      IF p_df_original_cost IS NOT NULL THEN
          l_orig_cost_contr_currcy 	:= p_df_original_cost;
      ELSE
          l_orig_cost_contr_currcy 	:= p_oec;
      END IF;

      -- convert orginal cost to functional currency, XILI 22-Feb-06 5029064
      OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
          p_khr_id  		  	          => p_book_rec.dnz_chr_id,
          p_to_currency   		        => p_func_curr_code,
          p_transaction_date 		      => p_sysdate,
          p_amount 			              => l_orig_cost_contr_currcy,
          x_return_status             => x_return_status,
          x_contract_currency		      => l_contract_currency_code,
          x_currency_conversion_type  => l_currency_conversion_type,
          x_currency_conversion_rate  => l_currency_conversion_rate,
          x_currency_conversion_date	=> l_currency_conversion_date,
          x_converted_amount 		      => l_converted_amount);

       IF (x_return_status  <> OKC_API.G_RET_STS_SUCCESS) THEN
           RAISE process_unexp_error;
       END IF;

       l_orig_cost_in_func := l_converted_amount;

      -- convert net investment cost to functional currency, XILI 22-Feb-06 5029064
      OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
          p_khr_id  		  	          => p_book_rec.dnz_chr_id,
          p_to_currency   		        => p_func_curr_code,
          p_transaction_date 		      => p_sysdate,
          p_amount 			              => p_net_investment_value,
          x_return_status             => x_return_status,
          x_contract_currency		      => l_contract_currency_code,
          x_currency_conversion_type  => l_currency_conversion_type,
          x_currency_conversion_rate  => l_currency_conversion_rate,
          x_currency_conversion_date	=> l_currency_conversion_date,
          x_converted_amount 		      => l_converted_amount);

       IF (x_return_status  <> OKC_API.G_RET_STS_SUCCESS) THEN
           RAISE process_unexp_error;
       END IF;

      l_nest_invest_val_in_func := l_converted_amount;
     -- end of SGORANTL 22-MAR-06 5097643 : convert original_cost and depreciation_cost to functional currency



    IF l_hold_period_days IS NOT NULL AND l_hold_period_days <> 0 THEN -- SECHAWLA 03-JUN-04 Added check for 0 hold period days


       -- SECHAWLA 06-MAY-04 3578894 : Split the 1st trx into 2 trasnactions : First Stop the depreciation
       -- and then update the cost. Split 2nd trx into 2 trasnactions : first update the dep method, life,
       -- cost, sv and then start the depreciation. This is required because FA does not allow updating depreciation
       -- flag with any other attributes. Details in bug 3501172

       -- SECHAWLA 19-FEB-04 3439647 : Write asset cost up to the net investment and stop the dpreciation
       -- Start the depreciation when hold period expires

       -- Create 1st transaction header

       -- SECHAWLA 06-MAY-04  3578894 : Use a diff tas_type for dep flag only updates
       --lp_thpv_rec.tas_type := 'AMT';
       lp_thpv_rec.tas_type := 'AUD'; -- new tas_type

       lp_thpv_rec.tsu_code := 'ENTERED';

       lp_thpv_rec.try_id   :=  p_try_id;
       lp_thpv_rec.date_trans_occurred := p_sysdate;
       -- RRAVIKIR Legal Entity Changes
       lp_thpv_rec.legal_entity_id := p_legal_entity_id;
       -- Legal Entity Changes End

       OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		p_init_msg_list         => OKL_API.G_FALSE,
           					x_return_status         => x_return_status,
           					x_msg_count             => x_msg_count,
           					x_msg_data              => x_msg_data,
						p_thpv_rec		        => lp_thpv_rec,
						x_thpv_rec		        => lx_thpv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE process_unexp_error;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE process_error;
       END IF;

       -- Create 1st transaction line to update asset cost and stop depreciation
       lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
       lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
       lp_tlpv_rec.kle_id 			    := p_kle_id;
       lp_tlpv_rec.line_number 		:= 1;

       --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for dep flag only updates
       --lp_tlpv_rec.tal_type 		    := 'AML';
       lp_tlpv_rec.tal_type 		    := 'AUF'; -- new tal_type

	   lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
       lp_tlpv_rec.description         := p_book_rec.item_description;

       -- SECHAWLA 06-MAY-04 3578894 : deprn method and life are populated in the 1st trx for display on
       -- off lease details screen. These will not be processed in FA when 1st trx is processed
       lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code; -- original dep method

       -- SECHAWLA 28-MAY-04 3645574 : Store either life or rate
       IF p_book_rec.life_in_months IS NOT NULL THEN
          lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
       ELSE
          lp_tlpv_rec.deprn_rate  := p_book_rec.deprn_rate;
       END IF;


       lp_tlpv_rec.corporate_book 		:= p_corporate_book;

       -- SECHAWLA 06-MAY-04 3578894 : Do not update cost in 1st trx. Only update the depreciate_yn flag
       -- lp_tlpv_rec.depreciation_cost 	:= l_net_investment_value;

       -- populate sv for display on off lse upd screen
       lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

/* -- SGORANTL 22-MAR-06 5097643

       IF p_df_original_cost IS NOT NULL THEN
          lp_tlpv_rec.original_cost 	:= p_df_original_cost;
       ELSE
          lp_tlpv_rec.original_cost 	:= p_oec;
       END IF;
*/
       lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- SGORANTL 22-MAR-06 5097643
       lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
       lp_tlpv_rec.hold_period_days	:= l_hold_period_days;
	   lp_tlpv_rec.depreciate_yn	 	:= 'N';
	   lp_tlpv_rec.dnz_asset_id		:= to_number(p_book_rec.asset_id);
       lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
       lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

       --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
       lp_tlpv_rec.currency_code := p_func_curr_code;

	   -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
       lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	   OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE process_unexp_error;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE process_error;
       END IF;

       -- SECHAWLA 06-MAY-04 3578894 : If this book is a tax book, also create a row in okl_txd_assets_b
       IF p_book_rec.book_class = 'TAX' THEN
          lp_adpv_rec.tal_id := lx_tlpv_rec.id;
          lp_adpv_rec.tax_book := p_book_rec.book_type_code;
          lp_adpv_rec.asset_number := p_book_rec.asset_number;
          OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE process_unexp_error;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE process_error;
          END IF;
      END IF;

      ----------------------------------



      -- Validations for 2nd trx (if any) shold go here


      -- SECHAWLA 06-MAY-04 3578894 : Create 2nd trx (split from 1st) to update asset cost

      -- Initialize the trx hdr and line for each trx
      lp_thpv_rec := lp_empty_thpv_rec;
      lp_tlpv_rec := lp_empty_tlpv_rec;
      lp_adpv_rec := lp_empty_adpv_rec;

      -- SECHAWLA 22-MAR-04 : use a diff tas_type for cost only updates
      --lp_thpv_rec.tas_type := 'AMT';
      lp_thpv_rec.tas_type := 'AUS'; -- new tas_type

      lp_thpv_rec.tsu_code := 'ENTERED';
      lp_thpv_rec.try_id   :=  p_try_id;
      lp_thpv_rec.date_trans_occurred := p_sysdate;
      -- RRAVIKIR Legal Entity Changes
      lp_thpv_rec.legal_entity_id := p_legal_entity_id;
      -- Legal Entity Changes End

      OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
                                               p_init_msg_list         => OKL_API.G_FALSE,
                                               x_return_status         => x_return_status,
                                               x_msg_count             => x_msg_count,
                                               x_msg_data              => x_msg_data,
                                               p_thpv_rec		        => lp_thpv_rec,
                                               x_thpv_rec		        => lx_thpv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE process_unexp_error;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE process_error;
      END IF;

      -- Create 2nd transaction line to update asset cost
      lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
      lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
      lp_tlpv_rec.kle_id 			    := p_kle_id;
      lp_tlpv_rec.line_number 		:= 1;

      --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for cost only updates
      --lp_tlpv_rec.tal_type 		    := 'AML';
      lp_tlpv_rec.tal_type 		    := 'AUT'; -- new tal_type

	  lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
      lp_tlpv_rec.description         := p_book_rec.item_description;

      -- SECHAWLA 06-MAY-04 3578894 : deprn method and life are populated in the 2nd trx for display on
      -- off lease details screen. These will not be processed in FA when 2nd trx is processed
      lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code; -- original dep method

      -- SECHAWLA 28-MAY-04 3645574 : Store either life or rate
      IF p_book_rec.life_in_months IS NOT NULL THEN
         lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
      ELSE
         lp_tlpv_rec.deprn_rate  := p_book_rec.deprn_rate;
      END IF;

      lp_tlpv_rec.corporate_book 		:= p_corporate_book;

      --SECHAWLA 06-MAY-04 3578894 : Update cost
      lp_tlpv_rec.depreciation_cost 	:= p_net_investment_value;
     /* -- SGORANTL 22-MAR-06 5097643

      IF p_df_original_cost IS NOT NULL THEN
         lp_tlpv_rec.original_cost 	:= p_df_original_cost;
      ELSE
         lp_tlpv_rec.original_cost 	:= p_oec;
      END IF;
     */
          lp_tlpv_rec.depreciation_cost 	:= l_nest_invest_val_in_func; -- SGORANTL 22-MAR-06 5097643
          lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- SGORANTL 22-MAR-06 5097643
	  lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
	  lp_tlpv_rec.hold_period_days	:= l_hold_period_days;

      -- SECHAWLA 06-MAY-04 3578894 : Depreciate_yn flag is set here and also in the 1st trx,so the process
      -- asset trx program can identify that these are split transactions. When this trx is processed, the flag
      -- is not updated in FA. Only cost will be updated
	  lp_tlpv_rec.depreciate_yn	 	:= 'N';

      -- populate sv for display on off lse upd screen
      lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

	  lp_tlpv_rec.dnz_asset_id		:= to_number(p_book_rec.asset_id);
      lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
      lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

      --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
      lp_tlpv_rec.currency_code       := p_func_curr_code;

	  -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
      lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	  OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE process_unexp_error;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE process_error;
      END IF;

      -- SECHAWLA 06-MAY-04 3578894 : If this book is a tax book, also create a row in okl_txd_assets_b
      IF p_book_rec.book_class = 'TAX' THEN
         lp_adpv_rec.tal_id := lx_tlpv_rec.id;
         lp_adpv_rec.tax_book := p_book_rec.book_type_code;
         lp_adpv_rec.asset_number := p_book_rec.asset_number;
         OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE process_unexp_error;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE process_error;
         END IF;

     END IF;

     -- SECHAWLA 06-MAY-04 3578894 : end 2nd trx
     -----------------------------------

     -- Validations for 3rd trx (if any) shold go here


     -- SECHAWLA 06-MAY-04 3578894 : Split the 2nd trx into 2 transactions : first update dep method, life,
     -- cost, sv  and then start the depreciation

     -- Initialize the trx hdr and line for each trx
     lp_thpv_rec := lp_empty_thpv_rec;
     lp_tlpv_rec := lp_empty_tlpv_rec;
     lp_adpv_rec := lp_empty_adpv_rec;

     -- Create 3rd Transaction Header
     lp_thpv_rec.tas_type := 'AMT';
     lp_thpv_rec.tsu_code := 'ENTERED';

     lp_thpv_rec.try_id   :=  p_try_id;
     lp_thpv_rec.date_trans_occurred := p_sysdate + l_hold_period_days;
     -- RRAVIKIR Legal Entity Changes
     lp_thpv_rec.legal_entity_id := p_legal_entity_id;
     -- Legal Entity Changes End

     OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
                                              p_init_msg_list         => OKL_API.G_FALSE,
                                              x_return_status         => x_return_status,
                                              x_msg_count             => x_msg_count,
                                              x_msg_data              => x_msg_data,
                                              p_thpv_rec		        => lp_thpv_rec,
                                              x_thpv_rec		        => lx_thpv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE process_unexp_error;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE process_error;
      END IF;

      -- create 3rd transaction line
      lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
      lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
      lp_tlpv_rec.kle_id 			    := p_kle_id;
      lp_tlpv_rec.line_number 		:= 1;
      lp_tlpv_rec.tal_type 		    := 'AML';
	  lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
      lp_tlpv_rec.description         := p_book_rec.item_description;

      -- SECHAWLA 19-FEB-04 3439647
      --lp_tlpv_rec.life_in_months      := l_life_in_months;

      -- If there is a method_id in okl_amort_hold_setups then use it. Otherwise get method id
      -- from fa_methods

      IF l_setup_method_id IS NOT NULL THEN
          lp_tlpv_rec.deprn_method        := l_fa_method_code;

          -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
          IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
             lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
          ELSE
             -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
             lp_tlpv_rec.life_in_months      := l_fa_life_in_months;
          END IF;

      ELSE
          lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code;

          -- SECHAWLA 28-MAY-04 3645574: store either life or rate
          IF p_book_rec.life_in_months IS NOT NULL THEN
             -- SECHAWLA 19-FEB-04 3439647 : use original life in months
             lp_tlpv_rec.life_in_months      := p_book_rec.life_in_months;
          ELSE
             lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
          END IF;
      END IF;

      lp_tlpv_rec.corporate_book 		    := p_corporate_book;


      --In case of direct finance/sales type of lease,Asset will exist in the corporate book, but with the Cost
      --and Original cost set to zero. Get Original cost from original creation line in Txl_assets, if it is
      --not found, then use OEC from OKL_K_LINES.OEC of the top financial asset line.

      -- SECHAWLA 19-FEB-04 3439647 : Always update cost with net investment. At the end of the term, net investment = rv
      --IF p_early_termination_yn = 'N' THEN
      --lp_tlpv_rec.depreciation_cost 	:= l_residual_value;
      --ELSE

      -- SECHAWLA 19-FEB-04 3439647 : Moved this piece of code to the beginning
      --       /*okl_am_util_pvt.get_formula_value(
      --             p_formula_name	=> G_NET_INVESTMENT_FORMULA,
      --         p_chr_id	        => l_dnz_chr_id,
      --       p_cle_id	        => p_kle_id,
	  --      x_formula_value	=> l_net_investment_value,
	  --       x_return_status	=> x_return_status);

      --   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      --        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      --    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      --        RAISE OKL_API.G_EXCEPTION_ERROR;
      --     END IF;
      --    */

/* -- SGORANTL 22-MAR-06 5097643

      lp_tlpv_rec.depreciation_cost 	:= p_net_investment_value;

      -- END IF;


      lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;
      IF p_df_original_cost IS NOT NULL THEN
         lp_tlpv_rec.original_cost 	:= p_df_original_cost;
      ELSE
         lp_tlpv_rec.original_cost 	:= p_oec;
      END IF;
*/

      lp_tlpv_rec.depreciation_cost 	:= l_nest_invest_val_in_func; -- SGORANTL 22-MAR-06 5097643
      lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- SGORANTL 22-MAR-06 5097643
      lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;
      lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
      lp_tlpv_rec.hold_period_days	:= l_hold_period_days;


      -- SECHAWLA 06-MAY-04 3578894 : Depreciate_yn flag is set here and also in the 4th trx,so the process
      -- asset trx program can identify that these are split transactions. When this trx is processed, the flag
      -- is not updated in FA. Only dep method, life, cost and sv will be updated
      lp_tlpv_rec.depreciate_yn	 	:= 'Y';

      lp_tlpv_rec.dnz_asset_id		:= to_number(p_book_rec.asset_id);
      lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
      lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

      --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
      lp_tlpv_rec.currency_code       := p_func_curr_code;

	  -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
      lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

      OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE process_unexp_error;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE process_error;
      END IF;

      -- SECHAWLA 06-MAY-04 3578894 : If this book is a tax book, also create a row in okl_txd_assets_b
      IF p_book_rec.book_class = 'TAX' THEN
           lp_adpv_rec.tal_id := lx_tlpv_rec.id;
           lp_adpv_rec.tax_book := p_book_rec.book_type_code;
           lp_adpv_rec.asset_number := p_book_rec.asset_number;
           OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE process_error;
            END IF;

      END IF;

      -----------------------------------------------------

      -- Validations for 4th trx (if any) shold go here


      -- SECHAWLA 06-MAY-04 3578894 : Create 4th trx (split from 3rd)

      -- Initialize the trx hdr and line for each trx
      lp_thpv_rec := lp_empty_thpv_rec;
      lp_tlpv_rec := lp_empty_tlpv_rec;
      lp_adpv_rec := lp_empty_adpv_rec;

      -- Create 4th Transaction Header

      --SECHAWLA 06-MAY-04 3578894 : Use a diff tas_type for dep flag only updates
      --lp_thpv_rec.tas_type := 'AMT';
      lp_thpv_rec.tas_type := 'AUD';  -- new tas_type

      lp_thpv_rec.tsu_code := 'ENTERED';

      lp_thpv_rec.try_id   :=  p_try_id;
      lp_thpv_rec.date_trans_occurred := p_sysdate + l_hold_period_days;
      -- RRAVIKIR Legal Entity Changes
      lp_thpv_rec.legal_entity_id := p_legal_entity_id;
      -- Legal Entity Changes End

      OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
                                               p_init_msg_list         => OKL_API.G_FALSE,
           				       x_return_status         => x_return_status,
           				       x_msg_count             => x_msg_count,
           				       x_msg_data              => x_msg_data,
                                               p_thpv_rec		        => lp_thpv_rec,
                                               x_thpv_rec		        => lx_thpv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE process_unexp_error;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE process_error;
      END IF;

      -- create 4th transaction line
      lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
      lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
      lp_tlpv_rec.kle_id 			    := p_kle_id;
      lp_tlpv_rec.line_number 		:= 1;

      --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for dep flag only updates
      --lp_tlpv_rec.tal_type 		    := 'AML';
      lp_tlpv_rec.tal_type 		    := 'AUF'; -- new tal_type

	  lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
      lp_tlpv_rec.description         := p_book_rec.item_description;


      lp_tlpv_rec.corporate_book 		:= p_corporate_book;
/* -- SGORANTL 22-MAR-06 5097643

      IF p_df_original_cost IS NOT NULL THEN
         lp_tlpv_rec.original_cost 	:= p_df_original_cost;
      ELSE
         lp_tlpv_rec.original_cost 	:= p_oec;
      END IF;
*/
          lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- SGORANTL 22-MAR-06 5097643
          lp_tlpv_rec.current_units 		:= p_book_rec.current_units;
	  lp_tlpv_rec.hold_period_days	:= l_hold_period_days;

      -- SECHAWLA 06-MAY-04 3578894 : Start the depreciation. Dep method, life, cost and sv are null
      -- when 4th trx is processed, only the dep flag will get updated
	  lp_tlpv_rec.depreciate_yn	 	:= 'Y';

      -- SECHAWLA 06-MAY-04 3578894 : populate dep method, life and sv for display on off lse trx upd screen
      IF l_setup_method_id IS NOT NULL THEN
         lp_tlpv_rec.deprn_method    := l_fa_method_code;
         -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
         IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
            lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
         ELSE
            -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
            lp_tlpv_rec.life_in_months  := l_fa_life_in_months;
         END IF;
      ELSE
         lp_tlpv_rec.deprn_method    := p_book_rec.deprn_method_code;

         -- SECHAWLA 28-MAY-04 3645574: store either life or rate
         IF p_book_rec.life_in_months IS NOT NULL THEN
            -- SECHAWLA 19-FEB-04 3439647 : use original life in months
            lp_tlpv_rec.life_in_months  := p_book_rec.life_in_months;
         ELSE
            lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
         END IF;
      END IF;
      lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

	  lp_tlpv_rec.dnz_asset_id		:= to_number(p_book_rec.asset_id);
      lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
      lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

      --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
      lp_tlpv_rec.currency_code := p_func_curr_code;

	  -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
      lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

	  OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE process_unexp_error;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE process_error;
       END IF;

       -- SECHAWLA 06-MAY-04 3578894 : If this book is a tax book, also create a row in okl_txd_assets_b
       IF p_book_rec.book_class = 'TAX' THEN
           lp_adpv_rec.tal_id := lx_tlpv_rec.id;
           lp_adpv_rec.tax_book := p_book_rec.book_type_code;
           lp_adpv_rec.asset_number := p_book_rec.asset_number;
           OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE process_unexp_error;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE process_error;
            END IF;

      END IF;

    ELSE  -- Hold period is null or 0

      -- Split this trx into 2 trasnactions : first update dep method, life, cost, sv and then start depreciation


      -- Create 1st Transaction Header

      lp_thpv_rec.tas_type := 'AMT';
      lp_thpv_rec.tsu_code := 'ENTERED';

      lp_thpv_rec.try_id   :=  p_try_id;
      lp_thpv_rec.date_trans_occurred := p_sysdate;
      -- RRAVIKIR Legal Entity Changes
      lp_thpv_rec.legal_entity_id := p_legal_entity_id;
      -- Legal Entity Changes End

      OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
                                               p_init_msg_list         => OKL_API.G_FALSE,
                                               x_return_status         => x_return_status,
                                               x_msg_count             => x_msg_count,
                                               x_msg_data              => x_msg_data,
                                               p_thpv_rec		        => lp_thpv_rec,
                                               x_thpv_rec		        => lx_thpv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE process_unexp_error;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE process_error;
       END IF;

       -- create transaction line
       lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
       lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
       lp_tlpv_rec.kle_id 			    := p_kle_id;
       lp_tlpv_rec.line_number 	   	:= 1;
       lp_tlpv_rec.tal_type 		    := 'AML';
	   lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
       lp_tlpv_rec.description         := p_book_rec.item_description;

       -- SECHAWLA 19-FEB-04 3439647
       --lp_tlpv_rec.life_in_months       := l_life_in_months;

       -- If there is a method_id in okl_amort_hold_setups then use it. Otherwise get method id
       -- from fa_methods

       IF l_setup_method_id IS NOT NULL THEN
          lp_tlpv_rec.deprn_method    := l_fa_method_code;

          -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
          IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
             lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
          ELSE
             -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
             lp_tlpv_rec.life_in_months  := l_fa_life_in_months;
          END IF;

       ELSE
          lp_tlpv_rec.deprn_method    := p_book_rec.deprn_method_code;

          -- SECHAWLA 28-MAY-04 3645574: store either life or rate
          IF p_book_rec.life_in_months IS NOT NULL THEN
             -- SECHAWLA 19-FEB-04 3439647 : use original life in months
             lp_tlpv_rec.life_in_months  := p_book_rec.life_in_months;
          ELSE
             lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
          END IF;
       END IF;

       lp_tlpv_rec.corporate_book 		:= p_corporate_book;
       lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;

       --In case of direct finance/sales type of lease,Asset will exist in the corporate book, but with the Cost
       --and Original cost set to zero. Get Original cost from original creation line in Txl_assets, if it is
       --not found, then use OEC from OKL_K_LINES.OEC of the top financial asset line.

       -- SECHAWLA 19-FEB-04 3439647 : Always update cost with net investment. At the end of the term, net investment = rv
       --IF p_early_termination_yn = 'N' THEN
       --  lp_tlpv_rec.depreciation_cost 	:= l_residual_value;
       -- ELSE

       -- SECHAWLA 19-FEB-04 3439647 : Moved this piece of code to the beginning
       --   /*
       --    okl_am_util_pvt.get_formula_value(
       --    p_formula_name	=> G_NET_INVESTMENT_FORMULA,
       --   p_chr_id	        => l_dnz_chr_id,
       --    p_cle_id	        => p_kle_id,
	   --     x_formula_value	=> l_net_investment_value,
	   --    x_return_status	=> x_return_status);

       --   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       --    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       --    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       --    RAISE OKL_API.G_EXCEPTION_ERROR;
       --    END IF;
       --    */
/* -- SGORANTL 22-MAR-06 5097643

       lp_tlpv_rec.depreciation_cost 	:= p_net_investment_value;

       --  END IF;

       IF p_df_original_cost IS NOT NULL THEN
          lp_tlpv_rec.original_cost 	:= p_df_original_cost;
       ELSE
          lp_tlpv_rec.original_cost 	:= p_oec;
       END IF;
*/

       lp_tlpv_rec.depreciation_cost 	:= l_nest_invest_val_in_func; -- SGORANTL 22-MAR-06 5097643
       lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- SGORANTL 22-MAR-06 5097643
       lp_tlpv_rec.current_units 		:= p_book_rec.current_units;

       -- SECHAWLA 06-MAY-04 3578894 : Depreciate_yn flag is set here and also in the 2nd trx,so the process
       -- asset trx program can identify that these are split transactions. When this trx is processed, the flag
       -- is not updated in FA. Only dep method, life, cost and sv will be updated
       lp_tlpv_rec.depreciate_yn	 	:= 'Y';

	   lp_tlpv_rec.dnz_asset_id	   	:= to_number(p_book_rec.asset_id);
       lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
       lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;

       --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
       lp_tlpv_rec.currency_code       := p_func_curr_code;

	   -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
       lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

       OKL_TXL_ASSETS_PUB.create_txl_asset_def( p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE process_unexp_error;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE process_error;
       END IF;

       -- SECHAWLA 06-MAY-04 3578894 : If this book is a tax book, also create a row in okl_txd_assets_b
       IF p_book_rec.book_class = 'TAX' THEN
          lp_adpv_rec.tal_id := lx_tlpv_rec.id;
          lp_adpv_rec.tax_book := p_book_rec.book_type_code;
          lp_adpv_rec.asset_number := p_book_rec.asset_number;
          OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE process_unexp_error;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE process_error;
          END IF;

       END IF;

       -------------------------------------------------

       -- Validations for 2nd trx (if any) should go here


       --SECHAWLA 06-MAY-04 3578894 : Create 2nd trx to start the depreciation

       -- Initialize the trx hdr and line for each trx
       lp_thpv_rec := lp_empty_thpv_rec;
       lp_tlpv_rec := lp_empty_tlpv_rec;
       lp_adpv_rec := lp_empty_adpv_rec;

       -- Create 2nd Transaction Header

       -- SECHAWLA 06-MAY-04 3578894 : use a diff tas_type from dep flag only updates
       --lp_thpv_rec.tas_type := 'AMT';
       lp_thpv_rec.tas_type := 'AUD';  -- new tas_type
       lp_thpv_rec.tsu_code := 'ENTERED';

       lp_thpv_rec.try_id   :=  p_try_id;
       lp_thpv_rec.date_trans_occurred := p_sysdate;
       -- RRAVIKIR Legal Entity Changes
       lp_thpv_rec.legal_entity_id := p_legal_entity_id;
       -- Legal Entity Changes End

       OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		p_init_msg_list         => OKL_API.G_FALSE,
           					x_return_status         => x_return_status,
           					x_msg_count             => x_msg_count,
           					x_msg_data              => x_msg_data,
						p_thpv_rec		        => lp_thpv_rec,
						x_thpv_rec		        => lx_thpv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE process_unexp_error;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE process_error;
       END IF;

       -- create 2nd transaction line
       lp_tlpv_rec.tas_id 			    := lx_thpv_rec.id; 		-- FK
       lp_tlpv_rec.iay_id 			    := p_book_rec.depreciation_category;
       lp_tlpv_rec.kle_id 			    := p_kle_id;
       lp_tlpv_rec.line_number 	   	:= 1;

       --SECHAWLA 06-MAY-04 3578894 : use a diff tal_type for dep flag only updates
       --lp_tlpv_rec.tal_type 		    := 'AML';
       lp_tlpv_rec.tal_type 		    := 'AUF'; -- new tal_type

	   lp_tlpv_rec.asset_number 		:= p_book_rec.asset_number;
       lp_tlpv_rec.description         := p_book_rec.item_description;

       lp_tlpv_rec.corporate_book 		:= p_corporate_book;

/* -- SGORANTL 22-MAR-06 5097643

       IF p_df_original_cost IS NOT NULL THEN
          lp_tlpv_rec.original_cost 	:= p_df_original_cost;
       ELSE
          lp_tlpv_rec.original_cost 	:= p_oec;
       END IF;
*/
       lp_tlpv_rec.original_cost 		:= l_orig_cost_in_func; -- SGORANTL 22-MAR-06 5097643
       lp_tlpv_rec.current_units 		:= p_book_rec.current_units;

       -- SECHAWLA 06-MAY-04 3578894 : start the depreciation. dep method, life, cost and sv are null. When
       -- this trx is processed in FA, only dep flag will be updated.
       lp_tlpv_rec.depreciate_yn	 	:= 'Y';

       -- SECHAWLA 06-MAY-04 3578894 : populate dep method, life and sv for display on off lse trx upd screen
       IF l_setup_method_id IS NOT NULL THEN
          lp_tlpv_rec.deprn_method        := l_fa_method_code;

          -- SECHAWLA 28-MAY-04 3645574 : check if  l_setup_deprn_rate has a value. Is so, store rate otherwise store life
          IF l_setup_deprn_rate IS NOT NULL THEN  -- setup has diminishing dep method
             lp_tlpv_rec.deprn_rate := l_setup_deprn_rate;
          ELSE
             -- SECHAWLA 19-FEB-04 3439647 : use life in months from the hold period setup
             lp_tlpv_rec.life_in_months      := l_fa_life_in_months;
          END IF;
       ELSE
          lp_tlpv_rec.deprn_method        := p_book_rec.deprn_method_code;

          -- SECHAWLA 28-MAY-04 3645574: store either life or rate
          IF p_book_rec.life_in_months IS NOT NULL THEN
             -- SECHAWLA 19-FEB-04 3439647 : use original life in months
             lp_tlpv_rec.life_in_months       := p_book_rec.life_in_months;
          ELSE
             lp_tlpv_rec.deprn_rate := p_book_rec.deprn_rate;
          END IF;
       END IF;
       lp_tlpv_rec.salvage_value 		:= p_book_rec.salvage_value;


	   lp_tlpv_rec.dnz_asset_id	   	:= to_number(p_book_rec.asset_id);
       lp_tlpv_rec.dnz_khr_id 		    := p_book_rec.dnz_chr_id;
       lp_tlpv_rec.in_service_date     := p_book_rec.in_service_date;
       --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
       lp_tlpv_rec.currency_code := p_func_curr_code;

	   -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx header
       lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

       OKL_TXL_ASSETS_PUB.create_txl_asset_def( p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => OKL_API.G_FALSE,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE process_unexp_error;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE process_error;
       END IF;

       -- SECHAWLA 06-MAY-04 3578894 : If this book is a tax book, also create a row in okl_txd_assets_b
       IF p_book_rec.book_class = 'TAX' THEN
          lp_adpv_rec.tal_id := lx_tlpv_rec.id;
          lp_adpv_rec.tax_book := p_book_rec.book_type_code;
          lp_adpv_rec.asset_number := p_book_rec.asset_number;
          OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                                                    p_api_version               => p_api_version,
                                                    p_init_msg_list             => OKL_API.G_FALSE,
                                                    x_return_status             => x_return_status,
                                                    x_msg_count                 => x_msg_count,
                                                    x_msg_data                  => x_msg_data,
                                                    p_adpv_rec                  => lp_adpv_rec,
                                                    x_adpv_rec                  => lx_adpv_rec );
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE process_unexp_error;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE process_unexp_error;
           END IF;

       END IF;
   END IF; -- hold period days is null

  EXCEPTION
      WHEN process_error THEN

        IF l_methodcode_csr%ISOPEN THEN
           CLOSE l_methodcode_csr;
        END IF;

        IF l_amthld_csr%ISOPEN THEN
           CLOSE l_amthld_csr;
        END IF;

        x_return_status := OKL_API.G_RET_STS_ERROR;
      WHEN process_unexp_error THEN
        IF l_methodcode_csr%ISOPEN THEN
           CLOSE l_methodcode_csr;
        END IF;

        IF l_amthld_csr%ISOPEN THEN
           CLOSE l_amthld_csr;
        END IF;

        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
        IF l_methodcode_csr%ISOPEN THEN
           CLOSE l_methodcode_csr;
        END IF;

        IF l_amthld_csr%ISOPEN THEN
           CLOSE l_amthld_csr;
        END IF;

        -- unexpected error
        OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END process_dfstlease_lessee;

----------SECHAWLA 06-MAY-04 3578894 end new procedures --------------------


-- Start of comments
--
-- Procedure Name  : create_offlease_asset_trx
-- Description     : This procedure populates the transaction
--                   header- okl_trx_assets_v and transaction lines- okl_txl_assets_v with amortization transactions
--                   for off-lease assets for a particular financial asset
-- Business Rules  :
-- Parameters      :  p_kle_id                       - Finacial Asset id
--                    p_early_termination_yn         - early termination / end of term flag
-- Version         : 1.0
-- History         : SECHAWLA 03-JAN-03 2683876 Added logic to populate currency_code in txl assets
--                   SECHAWLA 05-JUN-03 2993071 Check for both Direct Finance and Sales type of lease while
--                        deriving the original cost / oec / residual value
--                   SECHAWLA 11-Oct-2003 3167323 Create amortization transaction for operating lease, w/o hold period
--                   SECHAWLA 03-MAY-04 3521126
--                        Always update asset cost with NIV for DF/Sales lease, in corp book
--                        Update asset cost with NIV for DF/Sales lease, in tax books, when tax owner = LESSEE
--
--                        For DF/Sales lease, if hold period exists, then first update the cost with NIV and stop the
--                        depreciation. and then start the depreciation with the new dep method (if defined in setup)
--                        after the hold period expires
--
--                        If hold period setup has a depreciation method defined, then also use the corresponding
--                        life in months from the setup
--                  SECJAWLA 07-MAY-04 3578894
--                        Split the off lease transactions so that the dep flag
--                        is updated independent of other updates(dep method,
--                        life, cost, sv)
--                        Create separate transactions for corporate, tax and
--                        Milti GAAP reporting book
--                  rmunjulu EDAT Added two additional parameters for effective dated processing
--                  Also made following changes
--                  1. Set 'OFF_LSE_TRX_DATE' and pass as additional param to calculate net investment
--                  2. Get the corporate books that the asset belongs to using quote eff date
--                  3. Get the tax books that the asset belongs to using quote eff date
--                  4. To process_oplease pass quote eff date
--                  5. Get the reporting books that the asset belongs to using quote eff date
--                  6. To process_dfstlease_lessee pass quote eff date
--                  7. To process_dfstlease_lessor pass quote eff date
--                 rmunjulu EDAT 29-Dec-04 did to_char to convert to right format
--                 PAGARG 10-Feb-2005 3730369: Pass correct variable as out parameter
--                 for return status in call to get_reporting_product get_rule_record
--                 sechawla 20-Nov-07 Split Asset Enhancements - create off lease transactions
--                 when reporting product is DF/ST lease
-- End of comments

   PROCEDURE create_offlease_asset_trx(
                             p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 ,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_kle_id                IN   NUMBER  ,
                             p_early_termination_yn  IN   VARCHAR2,
                             p_quote_eff_date        IN   DATE DEFAULT NULL,  -- rmunjulu EDAT Added parameter
                             p_quote_accpt_date      IN   DATE DEFAULT NULL)  -- rmunjulu EDAT Added parameter
                             IS



   l_df_original_cost           NUMBER;
   l_oec                        NUMBER;
   l_residual_value             NUMBER;

   l_cost                       NUMBER;
   l_accumulated_deprn		    NUMBER;
   l_try_id 		            okl_trx_types_v.id%TYPE;

   l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_api_name                   CONSTANT VARCHAR2(30) := 'create_offlease_asset_trx';
   l_tax_owner                  VARCHAR2(10);
   l_rulv_rec                   okl_rule_pub.rulv_rec_type;

   l_api_version                CONSTANT NUMBER := 1;
   l_sysdate                    DATE;




   l_corporate_book             okx_asset_lines_v.corporate_book%TYPE;

   l_deal_type                  OKL_K_HEADERS_FULL_V.deal_type%TYPE;

   --SECHAWLA 03-JAN-03 Bug # 2683876 : new declaration
   l_func_curr_code             GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;


      --SECHAWLA 06-MAY-04 3578894
   l_base_NIV                   NUMBER;
   l_reporting_NIV              NUMBER;
   l_name                       VARCHAR2(150);
   l_contract_id                NUMBER;
   l_contract_number            VARCHAR2(120);

   lx_rep_product               OKL_PRODUCTS_V.NAME%TYPE;
   lx_mg_rep_book               fa_book_controls.book_type_code%TYPE;
   lx_rep_deal_type             okl_product_parameters_v.deal_type%TYPE;

   l_rep_book_found             VARCHAR2(1) := 'N';

   l_legal_entity_id            NUMBER;

   -- SECHAWLA 06-MAY-04 3578894 : added cp_sysdate parameter
   -- get all the tax books and validate that mg rep book (set in profile) is one of the asset tax books
   CURSOR l_fataxbooks_csr(cp_asset_number IN VARCHAR2, cp_sysdate IN DATE) IS
   SELECT fb.book_type_code
   FROM   fa_books fb, fa_additions_b fab, fa_book_controls fbc
   WHERE  fb.asset_id = fab.asset_id
   AND    fb.book_type_code = fbc.book_type_code
   AND    nvl(fbc.date_ineffective,cp_sysdate+1) > cp_sysdate
   AND    fb.transaction_header_id_out IS NULL
   AND    fab.asset_number = cp_asset_number
   AND    fbc.book_class = 'TAX';

   -- SECHAWLA 06-MAY-04 3578894 : added cp_sysdate parameter
   --Get the asset corporate book
   CURSOR l_facorpbook_csr(cp_asset_number IN VARCHAR2, cp_sysdate IN DATE) IS
   SELECT fb.book_type_code
   FROM   fa_books fb, fa_additions_b fab, fa_book_controls fbc
   WHERE  fb.asset_id = fab.asset_id
   AND    fb.book_type_code = fbc.book_type_code
   AND    nvl(fbc.date_ineffective,cp_sysdate+1) > cp_sysdate
   AND    fb.transaction_header_id_out IS NULL
   AND    fab.asset_number = cp_asset_number
   AND    fbc.book_class = 'CORPORATE';


   /* SECHAWLA 06-MAY-04 3578894 : This cursor cann't be used as it does not return tax book info
   -- This cursor will return all the Fixed Asset Lines for a particular contract.
   CURSOR l_linesv_csr IS
   SELECT dnz_chr_id, depreciation_category, corporate_book, salvage_value, deprn_method_code, life_in_months,
          asset_number, item_description, asset_id,original_cost, current_units, in_service_date, deal_type
   FROM   okx_asset_lines_v lines, OKL_K_HEADERS_FULL_V hdr
   WHERE  lines.dnz_chr_id = hdr.id
   AND    lines.parent_line_id = p_kle_id;
   */

   -- SECHAWLA 06-MAY-04 3578894 : added cp_sysdate parameter
   -- SECHAWLA 06-MAY-04 3578894 : Use the following cursor to get corp book info
   -- This cursor will return 1 record for corp book
   CURSOR l_assetcorpbook_csr(cp_kle_id IN NUMBER, cp_sysdate IN DATE) IS
   SELECT cleb_fin.id parent_line_id,
       cleb_fin.dnz_chr_id,
       fab.asset_category_id depreciation_category,
       fb.book_type_code,
       fbc.book_class,
       fb.salvage_value,
       fb.DEPRN_METHOD_CODE,
       fb.LIFE_IN_MONTHS,
       -- SECHAWLA 28-MAY-04 : 3645574 :added adjusted_rate
       fb.adjusted_rate deprn_rate,
       fab.asset_number asset_number,
       clet_fin.item_description,
       fb.asset_id,
       fb.original_cost,
       fab.current_units,
       fb.DATE_PLACED_IN_SERVICE in_service_date
  FROM fa_books fb,
       fa_additions_b fab,
       fa_book_controls fbc,
       okc_k_items cim_fa,
       okc_k_lines_b cleb_fa,
       okc_line_styles_b lseb_fa,
       okc_k_lines_tl clet_fin,
       okc_k_lines_b cleb_fin,
       okc_line_styles_b lseb_fin
  WHERE  fb.asset_id       = fab.asset_id
  AND    fb.transaction_header_id_out IS NULL
  AND    fb.book_type_code = fbc.book_type_code
  AND    nvl(fbc.date_ineffective,cp_sysdate+1) > cp_sysdate
  AND    fab.asset_id      = to_number(cim_fa.object1_id1)
  AND    cim_fa.object1_id2 = '#'
  AND    cim_fa.cle_id     = cleb_fa.id
  AND    cim_fa.dnz_chr_id = cleb_fa.dnz_chr_id
  AND    cleb_fa.cle_id    = cleb_fin.id
  AND    cleb_fa.dnz_chr_id = cleb_fin.dnz_chr_id
  AND    cleb_fa.lse_id     = lseb_fa.id
  AND    lseb_fa.lty_code   = 'FIXED_ASSET'
  AND    clet_fin.id        = cleb_fin.id
  AND    clet_fin.language  = userenv('LANG')
  AND    cleb_fin.lse_id    = lseb_fin.id
  AND    lseb_fin.lty_code   = 'FREE_FORM1'
  AND    cleb_fin.sts_code <> 'ABANDONED'
  AND    cleb_fin.id = cp_kle_id
  AND    fbc.book_class = 'CORPORATE';

  -- SECHAWLA 06-MAY-04 3578894 : added cp_sysdate parameter
  -- Cursor to get both corp and tax books
  -- This cursor will return 1 record for corp book and may return one or more records for tax books
   CURSOR l_corptaxbooks_csr(cp_kle_id IN NUMBER, cp_sysdate IN DATE) IS
   SELECT cleb_fin.id parent_line_id,
       cleb_fin.dnz_chr_id,
       fab.asset_category_id depreciation_category,
       fb.book_type_code,
       fbc.book_class,
       fb.salvage_value,
       fb.DEPRN_METHOD_CODE,
       fb.LIFE_IN_MONTHS,
       -- SECHAWLA 28-MAY-04 : 3645574 :added adjusted_rate
       fb.adjusted_rate deprn_rate,
       fab.asset_number asset_number,
       clet_fin.item_description,
       fb.asset_id,
       fb.original_cost,
       fab.current_units,
       fb.DATE_PLACED_IN_SERVICE in_service_date
  FROM fa_books fb,
       fa_additions_b fab,
       fa_book_controls fbc,
       okc_k_items cim_fa,
       okc_k_lines_b cleb_fa,
       okc_line_styles_b lseb_fa,
       okc_k_lines_tl clet_fin,
       okc_k_lines_b cleb_fin,
       okc_line_styles_b lseb_fin
  WHERE  fb.asset_id       = fab.asset_id
  AND    fb.transaction_header_id_out is null
  AND    fb.book_type_code = fbc.book_type_code
  AND    nvl(fbc.date_ineffective,cp_sysdate+1) > cp_sysdate
  AND    fab.asset_id      = to_number(cim_fa.object1_id1)
  AND    cim_fa.object1_id2 = '#'
  AND    cim_fa.cle_id     = cleb_fa.id
  AND    cim_fa.dnz_chr_id = cleb_fa.dnz_chr_id
  AND    cleb_fa.cle_id    = cleb_fin.id
  AND    cleb_fa.dnz_chr_id = cleb_fin.dnz_chr_id
  AND    cleb_fa.lse_id     = lseb_fa.id
  AND    lseb_fa.lty_code   = 'FIXED_ASSET'
  AND    clet_fin.id        = cleb_fin.id
  AND    clet_fin.language  = userenv('LANG')
  AND    cleb_fin.lse_id    = lseb_fin.id
  AND    lseb_fin.lty_code   = 'FREE_FORM1'
  AND    cleb_fin.sts_code <> 'ABANDONED'
  AND    cleb_fin.id = cp_kle_id
  AND    fbc.book_class IN ('CORPORATE','TAX')
  ORDER BY fbc.book_class;

  -- SECHAWLA 06-MAY-04 3578894 : added cp_sysdate parameter
  -- Cursir to get both corp and tax books (excluding mg rep book)
  -- This cursor will return 1 record for corp book and may return one or more records for tax books
   CURSOR l_corptax_norep_books_csr(cp_kle_id IN NUMBER, cp_rep_book IN VARCHAR2, cp_sysdate IN DATE) IS
   SELECT cleb_fin.id parent_line_id,
       cleb_fin.dnz_chr_id,
       fab.asset_category_id depreciation_category,
       fb.book_type_code,
       fbc.book_class,
       fb.salvage_value,
       fb.DEPRN_METHOD_CODE,
       fb.LIFE_IN_MONTHS,
       -- SECHAWLA 28-MAY-04 : 3645574 :added adjusted_rate
       fb.adjusted_rate deprn_rate,
       fab.asset_number asset_number,
       clet_fin.item_description,
       fb.asset_id,
       fb.original_cost,
       fab.current_units,
       fb.DATE_PLACED_IN_SERVICE in_service_date
  FROM fa_books fb,
       fa_additions_b fab,
       fa_book_controls fbc,
       okc_k_items cim_fa,
       okc_k_lines_b cleb_fa,
       okc_line_styles_b lseb_fa,
       okc_k_lines_tl clet_fin,
       okc_k_lines_b cleb_fin,
       okc_line_styles_b lseb_fin
  WHERE  fb.asset_id       = fab.asset_id
  AND    fb.transaction_header_id_out is null
  AND    fb.book_type_code = fbc.book_type_code
  AND    nvl(fbc.date_ineffective,cp_sysdate+1) > cp_sysdate
  AND    fab.asset_id      = to_number(cim_fa.object1_id1)
  AND    cim_fa.object1_id2 = '#'
  AND    cim_fa.cle_id     = cleb_fa.id
  AND    cim_fa.dnz_chr_id = cleb_fa.dnz_chr_id
  AND    cleb_fa.cle_id    = cleb_fin.id
  AND    cleb_fa.dnz_chr_id = cleb_fin.dnz_chr_id
  AND    cleb_fa.lse_id     = lseb_fa.id
  AND    lseb_fa.lty_code   = 'FIXED_ASSET'
  AND    clet_fin.id        = cleb_fin.id
  AND    clet_fin.language  = userenv('LANG')
  AND    cleb_fin.lse_id    = lseb_fin.id
  AND    lseb_fin.lty_code   = 'FREE_FORM1'
  AND    cleb_fin.sts_code <> 'ABANDONED'
  AND    cleb_fin.id = cp_kle_id
  AND    fbc.book_class IN ('CORPORATE','TAX')
  AND    fb.book_type_code <> cp_rep_book
  ORDER BY fbc.book_class;

  -- SECHAWLA 06-MAY-04 3578894 : added cp_sysdate parameter
  -- This cursor will return 1 record for mg reporting book
   CURSOR l_assetrepbook_csr(cp_kle_id IN NUMBER, cp_rep_book IN VARCHAR2, cp_sysdate IN DATE) IS
   SELECT cleb_fin.id parent_line_id,
       cleb_fin.dnz_chr_id,
       fab.asset_category_id depreciation_category,
       fb.book_type_code,
       fbc.book_class,
       fb.salvage_value,
       fb.DEPRN_METHOD_CODE,
       fb.LIFE_IN_MONTHS,
       -- SECHAWLA 28-MAY-04 : 3645574 :added adjusted_rate
       fb.adjusted_rate deprn_rate,
       fab.asset_number asset_number,
       clet_fin.item_description,
       fb.asset_id,
       fb.original_cost,
       fab.current_units,
       fb.DATE_PLACED_IN_SERVICE in_service_date
  FROM fa_books fb,
       fa_additions_b fab,
       fa_book_controls fbc,
       okc_k_items cim_fa,
       okc_k_lines_b cleb_fa,
       okc_line_styles_b lseb_fa,
       okc_k_lines_tl clet_fin,
       okc_k_lines_b cleb_fin,
       okc_line_styles_b lseb_fin
  WHERE  fb.asset_id       = fab.asset_id
  AND    fb.transaction_header_id_out is null
  AND    fb.book_type_code = fbc.book_type_code
  AND    nvl(fbc.date_ineffective,cp_sysdate+1) > cp_sysdate
  AND    fab.asset_id      = to_number(cim_fa.object1_id1)
  AND    cim_fa.object1_id2 = '#'
  AND    cim_fa.cle_id     = cleb_fa.id
  AND    cim_fa.dnz_chr_id = cleb_fa.dnz_chr_id
  AND    cleb_fa.cle_id    = cleb_fin.id
  AND    cleb_fa.dnz_chr_id = cleb_fin.dnz_chr_id
  AND    cleb_fa.lse_id     = lseb_fa.id
  AND    lseb_fa.lty_code   = 'FIXED_ASSET'
  AND    clet_fin.id        = cleb_fin.id
  AND    clet_fin.language  = userenv('LANG')
  AND    cleb_fin.lse_id    = lseb_fin.id
  AND    lseb_fin.lty_code   = 'FREE_FORM1'
  AND    cleb_fin.sts_code <> 'ABANDONED'
  AND    cleb_fin.id = cp_kle_id
  AND    fbc.book_class = 'TAX'
  AND    fb.book_type_code = cp_rep_book;


   -- SECHAWLA 06-MAY-04 3578894 : Added this cursor
  -- get the deal type for the asset
  CURSOR l_oklhdr_csr(cp_kle_id IN NUMBER) IS
  SELECT a.id, a.deal_type, a.legal_entity_id
  FROM   okl_k_headers a, okc_k_lines_b b
  WHERE  a.id = b.dnz_chr_id
  AND    b.id = cp_kle_id;

  -- SECHAWLA 06-MAY-04 3578894 : Added this cursor to validate the kle id
  CURSOR l_okllines_csr(cp_kle_id IN NUMBER) IS
  SELECT name
  FROM   okl_k_lines_full_v
  WHERE  id = cp_kle_id;

   -- This cursor is used to get the cost, residual value of an asset from the Financial Asset (TOP LINE)
   CURSOR  l_linesfullv_csr(p_id  NUMBER) IS
   SELECT  oec, residual_value
   FROM    okl_k_lines_full_v
   WHERE   id = p_id;

   -- This cursor returns the original cost from the original asset creation line
   CURSOR l_txlassetsv_csr(p_asset_number okl_txl_assets_v.asset_number%type) IS
   SELECT original_cost
   FROM   okl_txl_assets_v
   WHERE  tal_type = 'CFA'
   AND    asset_number = p_asset_number
   AND    ROWNUM < 2;

   --SECHAWLA 06-MAY-04 3578894 : passing additonal parameter for calling G_NET_INVESTMENT_FORMULA
   --if original product is op lease and reporting product is DF/ST lease. In this case net investment
   l_add_params		okl_execute_formula_pub.ctxt_val_tbl_type;

    -- rmunjulu EDAT
    l_quote_eff_date DATE;
    l_quote_accpt_date DATE;
    l_additional_params okl_execute_formula_pub.ctxt_val_tbl_type;

   BEGIN

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

      IF p_kle_id IS NULL OR p_kle_id = OKL_API.G_MISS_NUM THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- kle id parameter is null
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'KLE_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- SECHAWLA 06-MAY-04 3578894 : Validate p_kle_id
      OPEN  l_okllines_csr(p_kle_id);
      FETCH l_okllines_csr INTO l_name;
      IF l_okllines_csr%NOTFOUND THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- kle id is invalid
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'KLE_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE l_okllines_csr;

      --SECHAWLA 06-MAY-04 3578894 : These validations are not required as p_early_termination_yn parameter
      --will not be used any more in this API. This parameter was used to populate depreciation cost with RV if it
      --is EOT  and with NIV if early termination. As part of bug fix 3578894, depreciation cost should always be
      --NIV . Still keeping the parameter in the API call for possibility of future use
      /*
      IF p_early_termination_yn IS NULL OR p_early_termination_yn = OKL_API.G_MISS_CHAR THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- early_termination_yn parameter is null
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'EARLY_TERMINATION_YN');


          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF p_early_termination_yn <> 'Y' AND  p_early_termination_yn <> 'N' THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- early_termination_yn parameter is invalid
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'EARLY_TERMINATION_YN');


          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      */

      SELECT SYSDATE INTO l_sysdate FROM DUAL;

      -- rmunjulu EDAT Added condition to default
      IF  p_quote_eff_date IS NOT NULL
      AND p_quote_eff_date <> OKL_API.G_MISS_DATE THEN

         l_quote_eff_date := p_quote_eff_date;

      ELSE

         l_quote_eff_date := l_sysdate;

      END IF;

      -- rmunjulu EDAT Added condition to default
      IF  p_quote_accpt_date IS NOT NULL
      AND p_quote_accpt_date <> OKL_API.G_MISS_DATE THEN

         l_quote_accpt_date := p_quote_accpt_date;

      ELSE

         l_quote_accpt_date := l_sysdate;

      END IF;

      okl_am_util_pvt.get_transaction_id(p_try_name      => 'Off Lease Amortization',
                                         x_return_status => x_return_status,
                                         x_try_id        => l_try_id);


      IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            --Unable to find a transaction type for this transaction .
            OKL_API.set_message(p_app_name    => 'OKL',
                        p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                        p_token1              => 'TRY_NAME',
                        p_token1_value        => 'Off Lease Amortization');
            RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --SECHAWLA 03-JAN-03 2683876 get the functional currency code
      l_func_curr_code := okl_am_util_pvt.get_functional_currency;

      -- SECHAWLA 06-MAY-04 3578894 : Get the deal type
      OPEN  l_oklhdr_csr(p_kle_id);
      FETCH l_oklhdr_csr INTO l_contract_id, l_deal_type, l_legal_entity_id;
      CLOSE l_oklhdr_csr;

      -- SECHAWLA 06-MAY-04 3578894 : Off lease trx not craeted for loans
      IF l_deal_type IN ('LEASEDF','LEASEOP','LEASEST') THEN


         -- get the original cost from the original asset creation line
         OPEN  l_txlassetsv_csr(l_name);
         FETCH l_txlassetsv_csr INTO l_df_original_cost;
         CLOSE l_txlassetsv_csr;

         -- get the oec and rv
         OPEN  l_linesfullv_csr(p_kle_id);
         FETCH l_linesfullv_csr INTO l_oec, l_residual_value;
         CLOSE l_linesfullv_csr;


         IF l_df_original_cost IS NULL THEN
             IF l_oec IS NULL THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                -- OEC not defined for the asset
                OKL_API.set_message(      p_app_name      => 'OKL',
                                      p_msg_name      => 'OKL_AM_NO_OEC',
                                      p_token1        =>  'ASSET_NUMBER',
                                      p_token1_value  =>  l_name);

                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
         END IF;



         IF l_deal_type IN ('LEASEDF','LEASEST') THEN
             -- SECHAWLA 19-FEB-04 3439647 : Moved this piece of code here from the following sections
             --SECHAWLA 06-MAY-04 3578894 : By default, NIV is calculated based upon base product's streams.
             -- No additional parameters are passed in this case

             -- rmunjulu EDAT Pass additional parameters to set quote eff date as transaction date
             l_additional_params(1).name := 'quote_effective_from_date'; -- rmunjulu EDAT Pass quote eff from date
             l_additional_params(1).value := to_char(l_quote_eff_date,'MM/DD/YYYY');    -- rmunjulu EDAT 29-Dec-04 did to_char to convert to right format

             okl_am_util_pvt.get_formula_value(
                  p_formula_name	=> G_NET_INVESTMENT_FORMULA,
                  p_chr_id	        => l_contract_id,
                  p_cle_id	        => p_kle_id,
                  -- rmunjulu EDAT
                  p_additional_parameters => l_additional_params,

		          x_formula_value	=> l_base_NIV,
		          x_return_status	=> x_return_status);

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             -- SECHAWLA 19-FEB-04 3439647 : end moved code

         END IF;
         -- end direct finance data validation

         ----------------------
         -- get the tax owner (LESSOR/LESSEE) for the contract
         -- In case of OP Lease, tax owner is always LESSOR. In case of DF/Sales Lease, it can be LESSOR or LESSEE
         -- PAGARG 10-Feb-2005 3730369: Pass correct variable as out parameter for return status
         okl_am_util_pvt.get_rule_record(
                                      p_rgd_code         => 'LATOWN'
                                     ,p_rdf_code         =>'LATOWN'
                                     ,p_chr_id           => l_contract_id
                                     ,p_cle_id           => NULL
                                     ,x_rulv_rec         => l_rulv_rec
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;



         IF l_rulv_rec.rule_information1 IS NULL OR l_rulv_rec.rule_information1 = OKL_API.G_MISS_CHAR THEN
             x_return_status := OKL_API.G_RET_STS_ERROR;
             -- tax owner is not defined for contract CONTRACT_NUMBER.
             OKL_API.set_message(  p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_NO_TAX_OWNER',
                                p_token1        => 'CONTRACT_NUMBER',
                                p_token1_value  => l_contract_number);

             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- l_rulv_rec.RULE_INFORMATION1 will contain the value 'LESSEE' or 'LESSOR'
         l_tax_owner := l_rulv_rec.RULE_INFORMATION1;

         -- get the corporate book that the asset belongs to
         OPEN   l_facorpbook_csr(l_name, l_quote_accpt_date); -- rmunjulu EDAT pass quote accpt date
         FETCH  l_facorpbook_csr INTO l_corporate_book;
         CLOSE  l_facorpbook_csr;

         -- SECHAWLA 06-MAY-04 3578894 :Check if the contract has a reporting product attached
         -- PAGARG 10-Feb-2005 3730369: Pass correct variable as out parameter for return status
         get_reporting_product(
                                  p_api_version           => p_api_version,
           		 	              p_init_msg_list         => OKC_API.G_FALSE,
           			              x_return_status         => x_return_status,
           			              x_msg_count             => x_msg_count,
           			              x_msg_data              => x_msg_data,
                                  p_contract_id 		  => l_contract_id,
                                  x_rep_product           => lx_rep_product,
                                  x_mg_rep_book           => lx_mg_rep_book,
                                  x_rep_deal_type         => lx_rep_deal_type);
                                --  x_rep_tax_owner         => lx_rep_tax_owner);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- If lx_rep_product is not null then  lx_rep_deal_type and lx_mg_rep_book will also be populated

         -- If a reporting product is attached to the contract and reporting deal type is OP LEASE
         -- then mg rep book (set in the profile) should be one of the asset books

         -- SECHAWLA 06-MAY-04 3578894 : Added a deal type check to the folloiwng condition because of Authoring bug 3574232
         -- asset is being assigned to the reporting book only if rep product is OP lEASE, as of now
         IF lx_rep_product IS NOT NULL THEN --AND lx_rep_deal_type = 'LEASEOP' THEN  -- SECHAWLA 29-JUL-05 4384784 : removed dela type check
            FOR l_fataxbooks_rec IN l_fataxbooks_csr(l_name, l_quote_accpt_date) LOOP -- rmunjulu EDAT pass quote accpt date LOOP
                IF l_fataxbooks_rec.book_type_code = lx_mg_rep_book THEN
                  l_rep_book_found := 'Y';
                  EXIT;
                END IF;
            END LOOP;
            IF l_rep_book_found = 'N' THEN
              x_return_status := OKL_API.G_RET_STS_ERROR;
              -- Multi GAAP asset book is invalid
              OKL_API.set_message(   p_app_name      => 'OKL',
                                    p_msg_name      => 'OKL_AM_INVALID_MG_BOOK');

              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;

         -- At this point we know that if K has OP LEASE rep product attached, then mg rep book in profile is one of the
         -- asset books

         IF  l_deal_type = 'LEASEOP' THEN

            -- Get the corporate book info. This cursor will return only 1 row for corp book
            FOR l_assetcorpbook_rec IN l_assetcorpbook_csr(p_kle_id, l_quote_accpt_date) LOOP -- rmunjulu EDAT pass quote accpt date

                process_oplease(p_api_version       => p_api_version,
                                p_init_msg_list     => OKL_API.G_FALSE,
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data,
                                p_book_rec          => l_assetcorpbook_rec,
                                p_corporate_book    => l_corporate_book,
                                p_kle_id            => p_kle_id,
                                p_try_id            => l_try_id,
                                p_sysdate           => l_quote_eff_date, -- rmunjulu EDAT
                                p_func_curr_code    => l_func_curr_code,
                                p_legal_entity_id   => l_legal_entity_id); -- RRAVIKIR Legal Entity changes

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;



            END LOOP;

            -- Process reporting book if rep product is attached
            IF lx_rep_product IS NOT NULL THEN
               IF    lx_rep_deal_type = 'LEASEOP' THEN
                     -- This cursor will return 1 row for the reporting book
                     FOR l_assetrepbook_rec IN l_assetrepbook_csr(p_kle_id, lx_mg_rep_book, l_quote_accpt_date) LOOP -- rmunjulu EDAT pass quote accpt date
                           process_oplease(
                                p_api_version       => p_api_version,
                                p_init_msg_list     => OKL_API.G_FALSE,
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data,
                                p_book_rec          => l_assetrepbook_rec,
                                p_corporate_book    => l_corporate_book,
                                p_kle_id            => p_kle_id,
                                p_try_id            => l_try_id,
                                p_sysdate           => l_quote_eff_date, -- rmunjulu EDAT
                                p_func_curr_code    => l_func_curr_code,
                                p_legal_entity_id   => l_legal_entity_id); -- RRAVIKIR Legal Entity changes

                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;
                     END LOOP;
               ELSIF lx_rep_deal_type IN ('LEASEDF','LEASEST') THEN

                  /*  -- SECHAWLA 06-MAY-04 3578894 : Do nothing till Authoring bug 3574232 is fixed */
                  -- 20-Nov-07 sechawla - Split Asset ER - create off lease transactions when reporting dela type IN ('LEASEDF','LEASEST')
                     FOR l_assetrepbook_rec IN l_assetrepbook_csr(p_kle_id, lx_mg_rep_book, l_quote_accpt_date) LOOP

                         --SECHAWLA 06-MAY-04 3578894 : calculate NIV of the reporting product
                         l_add_params(1).name	:= 'REP_PRODUCT_STRMS_YN';
	                     l_add_params(1).value	:= 'Y';

                         l_add_params(2).name	:= 'OFF_LSE_TRX_DATE';
	                     l_add_params(2).value	:= to_char(l_quote_eff_date,'MM/DD/YYYY');

	                     l_add_params(3).name	:= 'quote_effective_from_date';
	                     l_add_params(3).value	:= to_char(l_quote_eff_date,'MM/DD/YYYY');

                         okl_am_util_pvt.get_formula_value(
                            p_formula_name	         => G_NET_INVESTMENT_FORMULA,
                            p_chr_id	             => l_contract_id,
                            p_cle_id	             => p_kle_id,
                            p_additional_parameters  => l_add_params,
		                    x_formula_value          => l_reporting_NIV,
		                    x_return_status          => x_return_status);

                         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                         END IF;

                         process_dfstlease_lessor( p_api_version         => p_api_version,
                             p_init_msg_list         => OKL_API.G_FALSE,
                             x_return_status         => x_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data ,
                             p_book_rec              => l_assetrepbook_rec,
                             p_corporate_book        => l_corporate_book,
                             p_kle_id                => p_kle_id,
                             p_df_original_cost      => l_df_original_cost,
                             p_oec                   => l_oec,
                             p_net_investment_value  => l_reporting_NIV,
                             p_try_id                => l_try_id,
                             p_sysdate               => l_quote_eff_date, --l_sysdate,
                             p_func_curr_code        => l_func_curr_code,
                             p_legal_entity_id       => l_legal_entity_id);

                          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                          END IF;


                     END LOOP;

               END IF;
            END IF;

       ELSIF  (l_deal_type = 'LEASEDF' OR l_deal_type = 'LEASEST') AND l_tax_owner = 'LESSEE' THEN


            -- Process reporting book differently if rep product is attached
            IF lx_rep_product IS NOT NULL THEN

               -- process corp and tax book (excuding mg rep book)
               FOR l_corptax_norep_books_rec IN l_corptax_norep_books_csr(p_kle_id, lx_mg_rep_book, l_quote_accpt_date) LOOP -- rmunjulu EDAT pass quote accpt date


                    process_dfstlease_lessee(p_api_version           => p_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data,
                                p_book_rec              => l_corptax_norep_books_rec,
                                p_corporate_book        => l_corporate_book,
                                p_kle_id                => p_kle_id,
                                p_df_original_cost      => l_df_original_cost,
                                p_oec                   => l_oec,
                                p_net_investment_value  => l_base_NIV,
                                p_try_id                => l_try_id,
                                p_sysdate               => l_quote_eff_date, -- rmunjulu EDAT
                                p_func_curr_code        => l_func_curr_code,
                                p_legal_entity_id   => l_legal_entity_id); -- RRAVIKIR Legal Entity changes

                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

               END LOOP;

               IF    lx_rep_deal_type = 'LEASEOP' THEN
                     FOR l_assetrepbook_rec IN l_assetrepbook_csr(p_kle_id, lx_mg_rep_book, l_quote_accpt_date) LOOP -- rmunjulu EDAT pass quote accpt date
                           process_oplease(
                                p_api_version       => p_api_version,
                                p_init_msg_list     => OKL_API.G_FALSE,
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data,
                                p_book_rec          => l_assetrepbook_rec,
                                p_corporate_book    => l_corporate_book,
                                p_kle_id            => p_kle_id,
                                p_try_id            => l_try_id,
                                p_sysdate           => l_quote_eff_date, -- rmunjulu EDAT
                                p_func_curr_code    => l_func_curr_code,
                                p_legal_entity_id   => l_legal_entity_id); -- RRAVIKIR Legal Entity changes

                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;
                     END LOOP;
               ELSIF lx_rep_deal_type IN ('LEASEDF','LEASEST') THEN
                   -- -- SECHAWLA 06-MAY-04 3578894 : Do nothing till Authoring bug 3574232 is fixed
                   --sechawla 20-Nov-07 Split Asset ER - create off lease transactions when reporting deal type IN ('LEASEDF','LEASEST')

                     FOR l_assetrepbook_rec IN l_assetrepbook_csr(p_kle_id, lx_mg_rep_book, l_quote_eff_date) LOOP

                          --SECHAWLA 06-MAY-04 3578894 : calculate NIV of the reporting product
                         l_add_params(1).name	:= 'REP_PRODUCT_STRMS_YN';
	                     l_add_params(1).value	:= 'Y';

                         l_add_params(2).name	:= 'OFF_LSE_TRX_DATE';
	                     l_add_params(2).value	:= to_char(l_quote_eff_date,'MM/DD/YYYY');

	                     l_add_params(3).name	:= 'quote_effective_from_date';
	                     l_add_params(3).value	:= to_char(l_quote_eff_date,'MM/DD/YYYY');

                         okl_am_util_pvt.get_formula_value(
                            p_formula_name	         => G_NET_INVESTMENT_FORMULA,
                            p_chr_id	             => l_contract_id,
                            p_cle_id	             => p_kle_id,
                            p_additional_parameters  => l_add_params,
		                    x_formula_value          => l_reporting_NIV,
		                    x_return_status          => x_return_status);

                         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                         END IF;

                          process_dfstlease_lessor(p_api_version           => p_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data,
                                p_book_rec              => l_assetrepbook_rec,
                                p_corporate_book        => l_corporate_book,
                                p_kle_id                => p_kle_id,
                                p_df_original_cost      => l_df_original_cost,
                                p_oec                   => l_oec,
                                p_net_investment_value  => l_reporting_NIV,
                                p_try_id                => l_try_id,
                                p_sysdate               => l_quote_eff_date, --l_sysdate,
                                p_func_curr_code        => l_func_curr_code,
                                p_legal_entity_id       => l_legal_entity_id);

                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                    END LOOP;

               END IF;
            ELSE  -- no rep product attached. Process all tax books the same way
                -- Get the corporate and tax book info. This cursor will return all the books
                FOR l_corptaxbooks_rec IN l_corptaxbooks_csr(p_kle_id, l_quote_accpt_date) LOOP -- rmunjulu EDAT pass quote accpt date


                    process_dfstlease_lessee(p_api_version           => p_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data,
                                p_book_rec              => l_corptaxbooks_rec,
                                p_corporate_book        => l_corporate_book,
                                p_kle_id                => p_kle_id,
                                p_df_original_cost      => l_df_original_cost,
                                p_oec                   => l_oec,
                                p_net_investment_value  => l_base_NIV,
                                p_try_id                => l_try_id,
                                p_sysdate               => l_quote_eff_date, -- rmunjulu EDAT
                                p_func_curr_code        => l_func_curr_code,
                                p_legal_entity_id   => l_legal_entity_id); -- RRAVIKIR Legal Entity changes

                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                END LOOP;
            END IF;
           -------------------------------------------------
        ELSIF  (l_deal_type = 'LEASEDF' OR l_deal_type = 'LEASEST') AND l_tax_owner = 'LESSOR' THEN

            -- Get the corporate and tax book info. This cursor will return all the books
            FOR l_assetcorpbook_rec IN l_assetcorpbook_csr(p_kle_id, l_quote_accpt_date) LOOP -- rmunjulu EDAT pass quote accpt date

                process_dfstlease_lessor(p_api_version           => p_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data,
                                p_book_rec              => l_assetcorpbook_rec,
                                p_corporate_book        => l_corporate_book,
                                p_kle_id                => p_kle_id,
                                p_df_original_cost      => l_df_original_cost,
                                p_oec                   => l_oec,
                                p_net_investment_value  => l_base_NIV,
                                p_try_id                => l_try_id,
                                p_sysdate               => l_quote_eff_date, -- rmunjulu EDAT
                                p_func_curr_code        => l_func_curr_code,
                                p_legal_entity_id   => l_legal_entity_id); -- RRAVIKIR Legal Entity changes

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

           END LOOP;

            -- Process reporting book if rep product is attached
            IF lx_rep_product IS NOT NULL THEN
               IF    lx_rep_deal_type = 'LEASEOP' THEN
                     FOR l_assetrepbook_rec IN l_assetrepbook_csr(p_kle_id, lx_mg_rep_book, l_quote_eff_date) LOOP -- rmunjulu EDAT pass quote eff date
                           process_oplease(
                                p_api_version       => p_api_version,
                                p_init_msg_list     => OKL_API.G_FALSE,
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data,
                                p_book_rec          => l_assetrepbook_rec,
                                p_corporate_book    => l_corporate_book,
                                p_kle_id            => p_kle_id,
                                p_try_id            => l_try_id,
                                p_sysdate           => l_quote_eff_date, -- rmunjulu EDAT
                                p_func_curr_code    => l_func_curr_code,
                                p_legal_entity_id   => l_legal_entity_id); -- RRAVIKIR Legal Entity changes

                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;
                     END LOOP;
               ELSIF lx_rep_deal_type IN ('LEASEDF','LEASEST') THEN

                     -- SECHAWLA 06-MAY-04 3578894 : Do nothing till Authoring bug 3574232 is fixed
                     --sechawla 20-Nov-07 Splot Asset ER - create off lease transactions when reporting deal type IN ('LEASEDF','LEASEST')
                     FOR l_assetrepbook_rec IN l_assetrepbook_csr(p_kle_id, lx_mg_rep_book, l_quote_eff_date) LOOP

                          --SECHAWLA 06-MAY-04 3578894 : calculate NIV of the reporting product
                         l_add_params(1).name	:= 'REP_PRODUCT_STRMS_YN';
	                     l_add_params(1).value	:= 'Y';

                         l_add_params(2).name	:= 'OFF_LSE_TRX_DATE';
	                     l_add_params(2).value	:= to_char(l_quote_eff_date,'MM/DD/YYYY');

	                     l_add_params(3).name	:= 'quote_effective_from_date';
	                     l_add_params(3).value	:= to_char(l_quote_eff_date,'MM/DD/YYYY');

                         okl_am_util_pvt.get_formula_value(
                            p_formula_name	         => G_NET_INVESTMENT_FORMULA,
                            p_chr_id	             => l_contract_id,
                            p_cle_id	             => p_kle_id,
                            p_additional_parameters  => l_add_params,
		                    x_formula_value          => l_reporting_NIV,
		                    x_return_status          => x_return_status);

                         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                         END IF;

                          process_dfstlease_lessor(p_api_version           => p_api_version,
                                p_init_msg_list         => OKL_API.G_FALSE,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data,
                                p_book_rec              => l_assetrepbook_rec,
                                p_corporate_book        => l_corporate_book,
                                p_kle_id                => p_kle_id,
                                p_df_original_cost      => l_df_original_cost,
                                p_oec                   => l_oec,
                                p_net_investment_value  => l_reporting_NIV,
                                p_try_id                => l_try_id,
                                p_sysdate               => l_quote_eff_date,
                                p_func_curr_code        => l_func_curr_code,
                                p_legal_entity_id       => l_legal_entity_id);

                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                    END LOOP;

               END IF;
            END IF;


       END IF;
     END IF; --IF l_deal_type IN ('LEASEDF','LEASEOP','LEASEST') THEN








      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
      EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        -- SECHAWLA 06-MAY-04 3578894 : Changed cursor name l_linesv_csr to l_assetbooks_csr
        IF l_assetcorpbook_csr%ISOPEN THEN
           CLOSE l_assetcorpbook_csr;
        END IF;

        IF l_corptaxbooks_csr%ISOPEN THEN
           CLOSE l_corptaxbooks_csr;
        END IF;


        IF l_corptax_norep_books_csr%ISOPEN THEN
           CLOSE l_corptax_norep_books_csr;
        END IF;

        IF l_assetrepbook_csr%ISOPEN THEN
           CLOSE l_assetrepbook_csr;
        END IF;


        -- SECHAWLA 06-MAY-04 3578894 : Close new cursors

        IF l_oklhdr_csr%ISOPEN THEN
           CLOSE l_oklhdr_csr;
        END IF;

        IF l_okllines_csr%ISOPEN THEN
           CLOSE l_okllines_csr;
        END IF;

        IF l_txlassetsv_csr%ISOPEN THEN
           CLOSE l_txlassetsv_csr;
        END IF;
        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;

        IF l_fataxbooks_csr%ISOPEN THEN
           CLOSE l_fataxbooks_csr;
        END IF;

        IF l_facorpbook_csr%ISOPEN THEN
           CLOSE l_facorpbook_csr;
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
        -- SECHAWLA 06-MAY-04 3578894 : Changed cursor name l_linesv_csr to l_assetbooks_csr
        IF l_assetcorpbook_csr%ISOPEN THEN
           CLOSE l_assetcorpbook_csr;
        END IF;

        IF l_corptaxbooks_csr%ISOPEN THEN
           CLOSE l_corptaxbooks_csr;
        END IF;

        IF l_corptax_norep_books_csr%ISOPEN THEN
           CLOSE l_corptax_norep_books_csr;
        END IF;

        IF l_assetrepbook_csr%ISOPEN THEN
           CLOSE l_assetrepbook_csr;
        END IF;

        -- SECHAWLA 06-MAY-04 3578894 : Close new cursors

        IF l_oklhdr_csr%ISOPEN THEN
           CLOSE l_oklhdr_csr;
        END IF;

        IF l_okllines_csr%ISOPEN THEN
           CLOSE l_okllines_csr;
        END IF;

        IF l_txlassetsv_csr%ISOPEN THEN
           CLOSE l_txlassetsv_csr;
        END IF;
        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;

        IF l_fataxbooks_csr%ISOPEN THEN
           CLOSE l_fataxbooks_csr;
        END IF;

        IF l_facorpbook_csr%ISOPEN THEN
           CLOSE l_facorpbook_csr;
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
        -- SECHAWLA 06-MAY-04 3578894 : Changed cursor name l_linesv_csr to l_assetbooks_csr
        IF l_assetcorpbook_csr%ISOPEN THEN
           CLOSE l_assetcorpbook_csr;
        END IF;

        IF l_corptaxbooks_csr%ISOPEN THEN
           CLOSE l_corptaxbooks_csr;
        END IF;

        IF l_corptax_norep_books_csr%ISOPEN THEN
           CLOSE l_corptax_norep_books_csr;
        END IF;

        IF l_assetrepbook_csr%ISOPEN THEN
           CLOSE l_assetrepbook_csr;
        END IF;

        -- SECHAWLA 06-MAY-04 3578894 : Close new cursors

        IF l_oklhdr_csr%ISOPEN THEN
           CLOSE l_oklhdr_csr;
        END IF;

        IF l_okllines_csr%ISOPEN THEN
           CLOSE l_okllines_csr;
        END IF;

        IF l_txlassetsv_csr%ISOPEN THEN
           CLOSE l_txlassetsv_csr;
        END IF;
        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;

        IF l_fataxbooks_csr%ISOPEN THEN
           CLOSE l_fataxbooks_csr;
        END IF;

        IF l_facorpbook_csr%ISOPEN THEN
           CLOSE l_facorpbook_csr;
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
   END create_offlease_asset_trx;


   -- Start of comments
   --
   -- Procedure Name  : create_offlease_asset_trx
   -- Description     : This procedure gets all Fixed Asset Lines (off-lease assets)
   --                   for a particular contract using okx_asset_lines_v view and then calls the line level procedure
   --                   to create amortization transactions.
   -- Business Rules  :
   -- Parameters      :  p_contract_id                  - Contract id
   --                    p_early_termination_yn         - early termination / end of term flag
   -- Version         : 1.0
   -- History         : rmunjulu EDAT Added 2 new parameters p_quote_eff_date and p_quote_accpt_date
   --                 : SECHAWLA 19-NOV-2004 4022466 : amortize active contract lines
   -- End of comments

   PROCEDURE create_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 ,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_contract_id           IN   NUMBER  ,
                             p_early_termination_yn  IN   VARCHAR2,
                             p_quote_eff_date        IN   DATE DEFAULT NULL,  -- rmunjulu EDAT Added parameter
                             p_quote_accpt_date      IN   DATE DEFAULT NULL)  -- rmunjulu EDAT Added parameter
                             IS

   /* -- SECHAWLA 19-NOV-2004  4022466
   -- This cursor is used to get all the line items for a given contract
   CURSOR l_linesv_csr IS
   SELECT parent_line_id
   FROM   okx_asset_lines_v
   WHERE  dnz_chr_id = p_contract_id;
   */

   -- SECHAWLA 19-NOV-2004 4022466 :added
   -- get the contract status
   CURSOR l_okckhdr_csr(cp_khr_id IN NUMBER) IS
   SELECT sts_code
   FROM   okc_k_headers_b
   WHERE  id = cp_khr_id;

   -- SECHAWLA 19-NOV-2004 4022466 :added
   -- get the active financial asset lines for the contract
   CURSOR l_okcklines_csr(cp_khr_id IN NUMBER, cp_sts_code IN VARCHAR2) IS
   SELECT a.id
   FROM   okc_k_lines_b a , okc_line_styles_b b
   WHERE  a.chr_id = cp_khr_id
   AND    a.lse_id = b.id
   AND    b.lty_code = 'FREE_FORM1'
   AND    a.sts_code = cp_sts_code;

   l_sts_code                VARCHAR2(30);

   l_api_name                CONSTANT VARCHAR2(30) := 'create_offlease_asset_trx';
   l_api_version             CONSTANT NUMBER := 1;
   l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

   BEGIN
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

      -- SECHAWLA 19-NOV-2004 4022466 : added validations
      IF p_contract_id IS NULL OR p_contract_id = OKL_API.G_MISS_NUM THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- chr id is required
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CONTRACT_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN   l_okckhdr_csr(p_contract_id);
      FETCH  l_okckhdr_csr INTO l_sts_code;
      IF l_okckhdr_csr%NOTFOUND THEN
       	 x_return_status := OKL_API.G_RET_STS_ERROR;
         -- chr id is invalid
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CONTRACT_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE  l_okckhdr_csr;
      -- SECHAWLA 19-NOV-2004 4022466 : end

     --FOR l_linesv_rec IN l_linesv_csr LOOP -- SECHAWLA 19-NOV-2004 4022466
       FOR l_okcklines_rec IN l_okcklines_csr(p_contract_id, l_sts_code) LOOP
         create_offlease_asset_trx( p_api_version    => p_api_version,
                             p_init_msg_list         => p_init_msg_list,
                             x_return_status         => x_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data,
                             p_kle_id                => l_okcklines_rec.id, -- SECHAWLA 19-NOV-2004 4022466
                             p_early_termination_yn  => p_early_termination_yn,
                             p_quote_eff_date        => p_quote_eff_date,    -- rmunjulu EDAT
                             p_quote_accpt_date      => p_quote_accpt_date); -- rmunjulu EDAT

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

     END LOOP;

     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

     EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF l_okcklines_csr%ISOPEN THEN
           CLOSE l_okcklines_csr;
        END IF;
        -- SECHAWLA 19-NOV-2004 4022466
        IF l_okckhdr_csr%ISOPEN THEN
           CLOSE l_okckhdr_csr;
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
        IF l_okcklines_csr%ISOPEN THEN
           CLOSE l_okcklines_csr;
        END IF;
        -- SECHAWLA 19-NOV-2004 4022466
        IF l_okckhdr_csr%ISOPEN THEN
           CLOSE l_okckhdr_csr;
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
        IF l_okcklines_csr%ISOPEN THEN
           CLOSE l_okcklines_csr;
        END IF;

        -- SECHAWLA 19-NOV-2004 4022466
        IF l_okckhdr_csr%ISOPEN THEN
           CLOSE l_okckhdr_csr;
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
   END;

   -- Start of comments
--
-- Procedure Name  : update_offlease_asset_trx
-- Description     : This procedure is used to update a single off-lease transaction header and line
-- Business Rules  :
-- Parameters      :  p_header_rec     (transaction header)
--                    p_lines_rec      (transaction line)
-- Version         :  1.0
-- History         :  SECHAWLA 07-FEB-03 Bug # 2789656
--                       Added a validation to prevent negative salvage value
--                    SECHAWLA 03-JUN-04 Bug # 3657624
--                       Divide Depreciation rate by 100 before updating in okl_txl_assets_b. Rate passed from the
--                       screen is a percentage
--                    SECHAWLA 24-FEB-05 Bug # 4147143
--                       sync up other transactions for an asset when a particular transaction is updated for an asset
--                    SECHAWLA 27-FEB-05 Bug # 4147143
--                       Always update trx date on Asset Dep trx that stops dep, with date on Asset Amortization trx.	|
--                       Restrict the transaction updates to appropriate book
-- End of comments

   PROCEDURE update_offlease_asset_trx(
                             p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 ,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_header_rec            IN   thpv_rec_type,
                             p_lines_rec             IN   tlpv_rec_type
                             ) IS

   l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_api_name                CONSTANT VARCHAR2(30) := 'update_offlease_asset_trx';
   lx_header_rec             thpv_rec_type;
   lx_lines_rec              tlpv_rec_type;

   l_old_trans_date          DATE;
   l_old_hold_days           NUMBER;
   l_asset_number            VARCHAR2(15);
   l_depreciate_yn           VARCHAR2(1);
   l_new_trans_date          DATE;
   l_hold_diff               NUMBER;
   lp_header_temp_rec        thpv_rec_type;
   lp_lines_temp_rec         tlpv_rec_type;
   l_api_version             CONSTANT NUMBER := 1;
   l_sysdate                 DATE;

   -- This cursor returns the transaction date from okl_trx_assets_v
   CURSOR l_hdrtransdate_csr(p_id number) IS
   SELECT DATE_TRANS_OCCURRED
   FROM   okl_trx_assets -- SECHAWLA 24-FEB-05 4147143 : changed view to base table
   WHERE  id = p_id;

   -- SECHAWLA 24-FEB-05 4147143 : added kle_id, tal_type
   -- SECHAWLA 27-FEB-05 4147143 : added asset book
   -- This cursor returns the transaction line information from okl_txl_assets_v
   CURSOR l_lines_csr(p_id number) IS
   SELECT l.asset_number, l.hold_period_days, l.depreciate_yn, l.kle_id, l.tal_type,
          decode(d.tax_book,NULL,l.CORPORATE_BOOK,d.tax_book ) ASSET_BOOK
   FROM   okl_txl_assets_b l, -- SECHAWLA 24-FEB-05 4147143 : changed view to base table
          OKL_TXD_ASSETS_B d -- SECHAWLA 27-FEB-05 4147143 : added
   WHERE  l.id = p_id
   AND    l.id = d.tal_id(+); -- SECHAWLA 27-FEB-05 4147143 : added

   -- SECHAWLA 24-FEB-05 4147143 : new declarations
   -- get the first 2 transaction lines
   -- SECHAWLA 27-FEB-05 4147143 : added check for book and status
   CURSOR l_nodeplines_csr(cp_kle_id IN NUMBER, cp_book_type_code IN VARCHAR2) IS
   SELECT l.id, l.tas_id
   FROM   okl_trx_assets h, okl_txl_assets_b l, OKL_TXD_ASSETS_B d
   WHERE  l.kle_id = cp_kle_id
   AND    l.tas_id = h.id
   AND    h.tsu_code IN ( 'ENTERED','ERROR')
   AND    l.tal_type IN ('AUF','AUT')
   AND    l.depreciate_yn = 'N'
   AND    l.id = d.tal_id(+)
   AND    decode(d.tax_book,NULL,l.CORPORATE_BOOK,d.tax_book ) = cp_book_type_code;

   -- Get the 4th transaction
   -- SECHAWLA 27-FEB-05 4147143 : added check for book and status
   CURSOR l_depstartline_csr(cp_kle_id IN NUMBER, cp_book_type_code IN VARCHAR2) IS
   SELECT hdr.id hdr_id ,line.id line_id
   FROM   okl_trx_assets hdr, okl_txl_assets_b line,  OKL_TXD_ASSETS_B txd
   WHERE  line.kle_id = cp_kle_id
   AND    line.tas_id = hdr.id
   AND    hdr.tsu_code IN ( 'ENTERED','ERROR')
   AND    tal_type = 'AUF'
   AND    depreciate_yn = 'Y'
   AND    line.tas_id = hdr.id
   AND    line.id = txd.tal_id(+)
   AND    decode(txd.tax_book,NULL,line.CORPORATE_BOOK,txd.tax_book ) = cp_book_type_code;

   -- get the 3rd transaction header
   -- SECHAWLA 27-FEB-05 4147143 : added check for book and status
   CURSOR l_amortline_csr(cp_kle_id IN NUMBER, cp_book_type_code IN VARCHAR2) IS
   SELECT h.DATE_TRANS_OCCURRED
   FROM   okl_trx_assets h, okl_txl_assets_b l, OKL_TXD_ASSETS_B d
   WHERE  l.kle_id = cp_kle_id
   AND    l.tas_id = h.id
   AND    h.tsu_code IN ( 'ENTERED','ERROR')
   AND    l.tal_type = 'AML'
   AND    l.tas_id = h.id
   AND    l.id = d.tal_id(+)
   AND    decode(d.tax_book,NULL,l.CORPORATE_BOOK,d.tax_book ) = cp_book_type_code;


   lp_header_rec                thpv_rec_type;
   lp_header_empty_rec			thpv_rec_type;
   lp_lines_rec					tlpv_rec_type;
   l_kle_id						NUMBER;
   l_tal_type					VARCHAR2(10);
   l_DATE_TRANS_OCCURRED        DATE;
   l_hold_zero					VARCHAR2(1) := 'N';
   l_booktype_code              VARCHAR2(15);
   -- SECHAWLA 24-FEB-05 4147143 : end new declarations

   BEGIN


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

      SELECT SYSDATE INTO l_sysdate FROM DUAL;

      lp_lines_temp_rec         := p_lines_rec;

      IF p_header_rec.id IS NULL OR p_header_rec.id = OKL_API.G_MISS_NUM OR
         p_lines_rec.id IS NULL OR p_lines_rec.id = OKL_API.G_MISS_NUM THEN
           x_return_status := OKL_API.G_RET_STS_ERROR;
           -- transaction id is requierd
           OKC_API.set_message(      p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'TRANSACTION_ID');
           RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;



      OPEN  l_lines_csr(p_lines_rec.id);
      -- SECHAWLA 24-FEB-05 4147143 : added kle_id, tal_type
      -- SECHAWLA 27-FEB-05 4147143 : added booktype_code
      FETCH l_lines_csr INTO l_asset_number, l_old_hold_days, l_depreciate_yn, l_kle_id, l_tal_type, l_booktype_code ;
      IF l_lines_csr%NOTFOUND THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Line ID in the input line record is invalid
         OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'LINE_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE l_lines_csr;

      -- SECHAWLA 28-MAY-04 3645574 : Depreciation method can not be null
      IF p_lines_rec.deprn_method IS NULL OR p_lines_rec.deprn_method = OKL_API.G_MISS_CHAR THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Depreciation method can not be null
         OKL_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'Depreciation Method');
         RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

      -- SECHAWLA 03-JUN-04 3657624 : depreciation rate needs to be divided by 100 before storing
      -- in okl_txl_assets_b
      IF lp_lines_temp_rec.deprn_rate IS NOT NULL AND lp_lines_temp_rec.deprn_rate <> OKL_API.G_MISS_NUM THEN
         lp_lines_temp_rec.deprn_rate := lp_lines_temp_rec.deprn_rate / 100;
      END IF;


      -- SECHAWLA 07-FEB-03 Bug # 2789656 : Added the following validation to prevent negative salvage value
      IF p_lines_rec.salvage_value < 0 THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Asset failed because the new Salvage Value is negative
         OKL_API.set_message(        p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NEGATIVE_SALVAGE_VALUE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_asset_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- SECHAWLA 03-JUN-04 Added check for 0 hold period days
      IF l_old_hold_days IS NOT NULL
	     --AND l_old_hold_days <> 0  -- SECHAWLA 24-FEB-05 4147143
		 AND l_depreciate_yn = 'Y' THEN
          -- Incase of following scenarios update the hold_period_days when there is a change in the transcation date
          -- scenario 1 - Operating lease with hold period, where depreciate_yn = 'Y'
          -- scenario 2 - Direct Finance Lease with hold period.
         IF p_header_rec.date_trans_occurred IS NOT NULL AND p_header_rec.date_trans_occurred <> OKL_API.G_MISS_DATE THEN

            OPEN  l_hdrtransdate_csr(p_header_rec.id);
            FETCH l_hdrtransdate_csr INTO l_old_trans_date;
            IF l_hdrtransdate_csr%NOTFOUND THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                -- Header ID in the input header record is invalid
                OKC_API.set_message( p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'HEADER_ID');
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;



            CLOSE l_hdrtransdate_csr;

            l_new_trans_date := p_header_rec.date_trans_occurred;
            -- hold period days is not updateable thru the screen

            -- SECHAWLA 24-FEB-05 4147143 : begin
            IF l_tal_type = 'AUF' AND l_depreciate_yn = 'Y' THEN  -- 4th trx is being updated

               -- get the trx date of 3rd trx
               OPEN  l_amortline_csr(l_kle_id, l_booktype_code); -- SECHAWLA 27-FEB-05 4147143 ; added book type code
			   FETCH l_amortline_csr INTO l_date_trans_occurred;
			   CLOSE l_amortline_csr;

			   IF l_new_trans_date < l_date_trans_occurred THEN
			        x_return_status := OKL_API.G_RET_STS_ERROR;
                    -- Asset failed because the new Transaction Date is invalid
                    OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_INVALID_DEP_DT');
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            END IF;
            -- SECHAWLA 24-FEB-05 4147143 : end

            IF trunc(l_new_trans_date) <> trunc(l_old_trans_date) THEN
              IF trunc(l_old_trans_date) > trunc(l_new_trans_date) THEN
                 IF trunc(l_new_trans_date) >= trunc(l_sysdate) THEN
                    l_hold_diff := trunc(l_old_trans_date) - trunc(l_new_trans_date);
                    lp_lines_temp_rec.hold_period_days := l_old_hold_days - l_hold_diff;

                 ELSE
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    -- Asset failed because the new Transaction Date is invalid
                    OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_INVALID_TRANS_DATE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_asset_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
              ELSE

                l_hold_diff :=  trunc(l_new_trans_date) - trunc(l_old_trans_date) ;
                lp_lines_temp_rec.hold_period_days := l_old_hold_days + l_hold_diff;
              END IF;
           -- SECHAWLA 24-FEB-05 4147143 : added else section
            ELSE
              lp_lines_temp_rec.hold_period_days := l_old_hold_days;
            END IF;


          END IF;
      END IF;

      -- SECHAWLA 24-FEB-05 4147143 : begin
      IF lp_lines_temp_rec.hold_period_days = 0 THEN
         l_hold_zero := 'Y';
         lp_lines_temp_rec.hold_period_days := NULL;
      END IF;
      -- SECHAWLA 24-FEB-05 4147143 : end

      OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKL_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => p_header_rec,
                            x_thpv_rec          => lx_header_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;



      OKL_TXL_ASSETS_PUB.update_txl_asset_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKL_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_tlpv_rec          => lp_lines_temp_rec,
                            x_tlpv_rec          => lx_lines_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;


       -- SECHAWLA 24-FEB-05 4147143 :
       IF l_tal_type = 'AML' THEN -- 3rd trx is updated
         IF trunc(l_new_trans_date) <> trunc(l_old_trans_date) THEN -- date changed during 3rd trx updte
            --If trx date = termination date then cancel 1st 2 transcations
	        IF  l_hold_zero = 'Y' THEN
	          -- cancel 1st 2 transactions
          	  FOR  l_nodeplines_rec IN l_nodeplines_csr(l_kle_id, l_booktype_code) LOOP -- SECHAWLA 27-FEB-05 4147143 : added booktype_code
            	lp_header_rec.id := l_nodeplines_rec.tas_id;
            	lp_header_rec.tsu_code := 'CANCELED';

            	OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKL_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_header_rec,
                            x_thpv_rec          => lx_header_rec);

      			IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          			RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      			ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          			RAISE OKL_API.G_EXCEPTION_ERROR;
      			END IF;

          	  END LOOP;
            ELSE
              -- update only hold period days of 1st 2 transactions
              FOR  l_nodeplines_rec IN l_nodeplines_csr(l_kle_id,l_booktype_code) LOOP -- SECHAWLA 27-FEB-05 4147143 : added booktype_code
            	lp_lines_rec.id := l_nodeplines_rec.id;
            	lp_lines_rec.hold_period_days := lp_lines_temp_rec.hold_period_days;

            	OKL_TXL_ASSETS_PUB.update_txl_asset_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKL_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_tlpv_rec          => lp_lines_rec,
                            x_tlpv_rec          => lx_lines_rec);

      			IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          			RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      			ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          			RAISE OKL_API.G_EXCEPTION_ERROR;
      			END IF;

          	  END LOOP;
            END IF;
          END IF;

          -- update 4th transaction hdr and line
          lp_header_rec := lp_header_empty_rec;
          FOR l_depstartline_rec IN l_depstartline_csr(l_kle_id, l_booktype_code) LOOP -- SECHAWLA 27-FEB-05 4147143 : added book type code
            -- IF trunc(l_new_trans_date) <> trunc(l_old_trans_date) THEN -- date changed during 3rd trx updte
                -- update header
                lp_header_rec.id := l_depstartline_rec.hdr_id;
                lp_header_rec.date_trans_occurred := trunc(p_header_rec.date_trans_occurred);

                OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKL_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_header_rec,
                            x_thpv_rec          => lx_header_rec);

      		    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          			RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      		    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          			RAISE OKL_API.G_EXCEPTION_ERROR;
      		    END IF;
              --END IF;
              -- Update line
              lp_lines_temp_rec.id := l_depstartline_rec.line_id;
              -- change id on the lines record with id of 4th trx and keep all other attributes same as that of 3rd trx
              OKL_TXL_ASSETS_PUB.update_txl_asset_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKL_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_tlpv_rec          => lp_lines_temp_rec,
                            x_tlpv_rec          => lx_lines_rec);

       		 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       	     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           		RAISE OKL_API.G_EXCEPTION_ERROR;
       		 END IF;
          END LOOP;
        END IF; -- IF l_tal_type = 'AML' THEN


      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
      EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF l_lines_csr%ISOPEN THEN
           CLOSE l_lines_csr;
        END IF;
        IF l_hdrtransdate_csr%ISOPEN THEN
           CLOSE l_hdrtransdate_csr;
        END IF;

        -- SECHAWLA 24-FEB-05 4147143 : close new cursors
        IF l_nodeplines_csr%ISOPEN THEN
           CLOSE l_nodeplines_csr;
        END IF;

        IF l_depstartline_csr%ISOPEN THEN
   		   CLOSE l_depstartline_csr;
   		END IF;

        IF l_amortline_csr%ISOPEN THEN
           CLOSE l_amortline_csr;
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
        IF l_lines_csr%ISOPEN THEN
           CLOSE l_lines_csr;
        END IF;
        IF l_hdrtransdate_csr%ISOPEN THEN
           CLOSE l_hdrtransdate_csr;
        END IF;

        -- SECHAWLA 24-FEB-05 4147143 : close new cursors
        IF l_nodeplines_csr%ISOPEN THEN
           CLOSE l_nodeplines_csr;
        END IF;

        IF l_depstartline_csr%ISOPEN THEN
   		   CLOSE l_depstartline_csr;
   		END IF;

        IF l_amortline_csr%ISOPEN THEN
           CLOSE l_amortline_csr;
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
        IF l_lines_csr%ISOPEN THEN
           CLOSE l_lines_csr;
        END IF;
        IF l_hdrtransdate_csr%ISOPEN THEN
           CLOSE l_hdrtransdate_csr;
        END IF;

        -- SECHAWLA 24-FEB-05 4147143 : close new cursors
        IF l_nodeplines_csr%ISOPEN THEN
           CLOSE l_nodeplines_csr;
        END IF;

        IF l_depstartline_csr%ISOPEN THEN
   		   CLOSE l_depstartline_csr;
   		END IF;

        IF l_amortline_csr%ISOPEN THEN
           CLOSE l_amortline_csr;
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

   END update_offlease_asset_trx;



-- Start of comments
--
-- Procedure Name  : update_offlease_asset_trx
-- Description     : This procedure is used to update more than one off-lease transaction headers and lines
-- Business Rules  :
-- Parameters      :  p_header_tbl     (table of  transaction header records)
--                    p_lines_tbl      (table of transaction line records)
--                    x_record_status   (this flag is set to 'S' if all records in the input tables got processed
--                                       successfully. Otherwise it is set to 'E' or 'U'
-- Version         : 1.0
-- History         : SECHAWLA 07-FEB-03 Bug # 2789656 : Added a validation to prevent negative salvage value
-- End of comments

   PROCEDURE update_offlease_asset_trx(
                             p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 ,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_header_tbl            IN   thpv_tbl_type,
                             p_lines_tbl             IN   tlpv_tbl_type,
                             x_record_status         OUT  NOCOPY VARCHAR2 ) IS

   l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_api_name                CONSTANT VARCHAR2(30) := 'update_offlease_asset_trx';
   lx_header_rec             thpv_rec_type;
   lx_lines_rec              tlpv_rec_type;

   l_old_trans_date          DATE;
   l_old_hold_days           NUMBER;
   l_asset_number            VARCHAR2(15);
   l_depreciate_yn           VARCHAR2(1);
   l_new_trans_date          DATE;
   l_api_version             CONSTANT NUMBER := 1;
   l_sysdate                 DATE;
   i                         NUMBER;
   -- This cursor returns the transaction date from okl_trx_assets_v
   CURSOR l_hdrtransdate_csr(p_id NUMBER) IS
   SELECT DATE_TRANS_OCCURRED
   FROM   OKL_TRX_ASSETS
   WHERE  id = p_id;

   -- This cursor returns the transaction line information from okl_txl_assets_v
   CURSOR l_lines_csr(p_id number) IS
   SELECT asset_number, hold_period_days, depreciate_yn
   FROM   okl_txl_assets_v
   WHERE  id = p_id;

   lp_header_temp_rec        thpv_rec_type;
   lp_lines_temp_rec         tlpv_rec_type;
   l_hold_diff               NUMBER;
   l_date_valid_yn           VARCHAR2(1);

   BEGIN

     x_record_status := OKL_API.G_RET_STS_SUCCESS;

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

      /* -- SECHAWLA 24-FEB-05 4147143 : commented out as this procedure is not being used.
      With new logic of updating off-lease transctions, update to one transaction results in updat to other
      transactions for an asset. This procedure needs to be modified to uptake the new logic, if required
      IF p_header_tbl.count <> p_lines_tbl.count THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Number of records in the input header and lines table should be same.
         OKL_API.set_message( p_app_name      => 'OKL',
                              p_msg_name      => 'OKL_AM_INVALID_RECORD_COUNT');

         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      SELECT SYSDATE INTO l_sysdate FROM DUAL;

      IF p_header_tbl.count > 0  THEN
         i := p_header_tbl.FIRST;

         -- loop thru all the records in the input table, validate data an then update okl_trx_assets_v and
         -- okl_txl_assets_v
         LOOP

         l_date_valid_yn := 'Y';

         lp_lines_temp_rec   := p_lines_tbl(i);

            -- << LABEL 1 >>
            IF p_header_tbl(i).id IS NULL OR p_header_tbl(i).id = OKL_API.G_MISS_NUM OR
               p_lines_tbl(i).id IS NULL OR p_lines_tbl(i).id = OKL_API.G_MISS_NUM THEN
                x_record_status := OKL_API.G_RET_STS_ERROR;
                -- transaction Id is required
                OKC_API.set_message( p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'TRANSACTION_ID');

            ELSE


              OPEN  l_hdrtransdate_csr(p_header_tbl(i).id);
              FETCH l_hdrtransdate_csr INTO l_old_trans_date;
              -- << LABEL 4 >>
              IF l_hdrtransdate_csr%NOTFOUND THEN
                 x_record_status := OKL_API.G_RET_STS_ERROR;
                 -- Header Id for the current record in the input table is invalid
                 OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'HEADER_ID');


             ELSE


                OPEN  l_lines_csr(p_lines_tbl(i).id);
                FETCH l_lines_csr INTO l_asset_number, l_old_hold_days, l_depreciate_yn ;
                -- << LABEL 2 >>
                IF  l_lines_csr%NOTFOUND THEN
                    x_record_status := OKL_API.G_RET_STS_ERROR;
                    -- Line Id for the current record in the input table is invalid
                    OKC_API.set_message(        p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'LINE_ID');

                -- SECHAWLA 07-FEB-03 Bug # 2789656 : Added the following validation to prevent negative salvage value
                ELSIF p_lines_tbl(i).salvage_value < 0 THEN
                    x_record_status := OKL_API.G_RET_STS_ERROR;
                    -- Asset failed because the new Salvage Value is negative
                    OKL_API.set_message(        p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NEGATIVE_SALVAGE_VALUE',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_asset_number);

                ELSE
                --SECHAWLA 03-JUN-04 Added a check for 0 hold period days
                -- << LABEL 3 >>
                   IF l_old_hold_days IS NOT NULL AND l_old_hold_days <> 0 AND l_depreciate_yn = 'Y' THEN
                       -- Incase of following scenarios update the hold_period_days when there is a change in the transcation date
                       -- scenario 1 - Operating lease with hold period, where depreciate_yn = 'Y'
                       -- scenario 2 - Direct Finance Lease with hold period.

                       IF p_header_tbl(i).date_trans_occurred IS NOT NULL AND
                               p_header_tbl(i).date_trans_occurred <> OKL_API.G_MISS_DATE THEN


                           l_new_trans_date := p_header_tbl(i).date_trans_occurred;
                           -- hold period days is not updateable thru the screen

                           -- << LABEL 5 >>
                           IF trunc(l_new_trans_date) <> trunc(l_old_trans_date) THEN
                               IF trunc(l_old_trans_date) > trunc(l_new_trans_date) THEN
                                   IF trunc(l_new_trans_date) >= trunc(l_sysdate) THEN
                                      l_hold_diff := trunc(l_old_trans_date) - trunc(l_new_trans_date);
                                      lp_lines_temp_rec.hold_period_days := l_old_hold_days - l_hold_diff;
                                   ELSE
                                      x_record_status := OKL_API.G_RET_STS_ERROR;
                                      -- Asset failed because the new Transaction Date is invalid
                                      OKL_API.set_message( p_app_name      => 'OKL',
                                                           p_msg_name      => 'OKL_AM_INVALID_TRANS_DATE',
                                                           p_token1        => 'ASSET_NUMBER',
                                                           p_token1_value  => l_asset_number);

                                     l_date_valid_yn := 'N';
                                  END IF;
                               ELSE
                                   l_hold_diff :=  trunc(l_new_trans_date) - trunc(l_old_trans_date) ;
                                   lp_lines_temp_rec.hold_period_days := l_old_hold_days + l_hold_diff;
                               END IF;
                           END IF;  -- << LABEL 5 >>

                       END IF;

               END IF; -- << LABEL 3 >>


               IF l_date_valid_yn = 'Y' THEN
                   OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKL_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => p_header_tbl(i),
                            x_thpv_rec          => lx_header_rec);

                   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;

                   OKL_TXL_ASSETS_PUB.update_txl_asset_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKL_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_tlpv_rec          => lp_lines_temp_rec,
                            x_tlpv_rec          => lx_lines_rec);

                   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;
                 END IF;


                END IF; -- << LABEL 2 >>
                CLOSE l_lines_csr;

               END IF; -- << LABEL 4 >>
               CLOSE l_hdrtransdate_csr;

             END IF; --   << LABEL 1 >>

            EXIT WHEN (i = p_header_tbl.LAST);
            i := p_header_tbl.NEXT(i);

         END LOOP;
      END IF;   -- p_header_tbl.count > 0
*/
      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
      EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF l_lines_csr%ISOPEN THEN
           CLOSE l_lines_csr;
        END IF;
        IF l_hdrtransdate_csr%ISOPEN THEN
           CLOSE l_hdrtransdate_csr;
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
        IF l_lines_csr%ISOPEN THEN
           CLOSE l_lines_csr;
        END IF;
        IF l_hdrtransdate_csr%ISOPEN THEN
           CLOSE l_hdrtransdate_csr;
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
        IF l_lines_csr%ISOPEN THEN
           CLOSE l_lines_csr;
        END IF;
        IF l_hdrtransdate_csr%ISOPEN THEN
           CLOSE l_hdrtransdate_csr;
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

   END update_offlease_asset_trx;


  -- Start of comments
  --
  -- Procedure Name  : update_depreciation
  -- Description     : Published API for update of Depreciation method and Salvage value
  -- Business Rules  : This API will do validations which are done from screen and then call the
  --                   screen level api for additional validations and updates
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU 3608615 Added
  --                   RMUNJULU 3600565 Added IF conditions for checking both deprn_method
  --                   and life_in_months passed if passed
  --                   SECHAWLA 28-MAY-04 3645574 Added deprn rate processing logic for diminishing dep methods
  -- End of comments
  PROCEDURE update_depreciation(
                             p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_deprn_rec             IN   deprn_rec_type) IS

     -- Get the Trn details
     CURSOR trns_csr (p_id IN NUMBER) IS
     SELECT TAS.id,
            TAS.tsu_code,
            TAS.tas_type,
            TAS.date_trans_occurred
     FROM   OKL_TRX_ASSETS TAS
     WHERE  TAS.id = p_id;

     -- Check the Dep Method and Life In months
     CURSOR dep_csr (p_dep_method IN VARCHAR2, p_life_in_months IN NUMBER) IS
     SELECT FAM.method_code
     FROM   FA_METHODS FAM
     WHERE  FAM.method_code = p_dep_method
     AND    FAM.life_in_months = p_life_in_months;

     -- Get the Line details
     CURSOR line_csr (p_header_id IN NUMBER) IS
     SELECT TXL.id
     FROM   OKL_TXL_ASSETS_V TXL
     WHERE  TXL.tas_id = p_header_id;

     -- Get the lookup meaning for OKL_TRANS_HEADER_TYPE
     CURSOR amt_csr (p_code IN VARCHAR2) IS
     SELECT fnd.meaning
     FROM   fnd_lookups fnd
     WHERE  fnd.lookup_type = 'OKL_TRANS_HEADER_TYPE'
     AND    fnd.lookup_code = p_code;

     -- Get the lookup meaning for ENTERED status
     CURSOR status_csr (p_code IN VARCHAR2) IS
     SELECT fnd.meaning
     FROM   fnd_lookups fnd
     WHERE  fnd.lookup_type = 'OKL_TRANSACTION_STATUS'
     AND    fnd.lookup_code = p_code;


     -- SECHAWLA 28-MAY-04 3645574 : new cursor for validating deprn rate
     CURSOR l_flatrates_csr(cp_deprn_method IN VARCHAR2,cp_deprn_rate_percent IN NUMBER)  IS
     SELECT 'x'
     FROM   fa_methods famet, fa_flat_rates fart
     WHERE  famet.method_code = cp_deprn_method
     AND    famet.method_id = fart.method_id
     AND    fart.adjusted_rate = cp_deprn_rate_percent / 100 -- sechawla 03-jun-04 3657624 : divide by 100
     AND    nvl(fart.adjusting_rate,0) = 0 ;

     l_return_status VARCHAR2(3);
     l_api_name VARCHAR2(30);
     l_api_version NUMBER;

     l_id NUMBER;
     l_tsu_code OKL_TRX_ASSETS.tsu_code%TYPE;
     l_tas_type OKL_TRX_ASSETS.tas_type%TYPE;
     l_date_trn OKL_TRX_ASSETS.date_trans_occurred%TYPE;
     l_val  FA_METHODS.method_code%TYPE;
     l_line_id NUMBER;

     lp_header_rec   thpv_rec_type;
     lp_lines_rec    tlpv_rec_type;

     l_trns_type fnd_lookups.meaning%TYPE;
     l_status    fnd_lookups.meaning%TYPE;

     -- SECHAWLA 28-MAY-04 3645574 : new declaration
     l_dummy     VARCHAR2(1);

  BEGIN

     -- Initialize variables
     l_api_name := 'update_depreciation';
     l_api_version := 1;
     l_id := -999;
     l_line_id := -999;
     l_val := NULL;

     -- Start activity
     l_return_status :=  OKL_API.START_ACTIVITY( l_api_name,
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

     -- Get trn details
     FOR trns_rec IN trns_csr(p_deprn_rec.p_tas_id) LOOP

        l_id := trns_rec.id;
        l_tsu_code := trns_rec.tsu_code;
        l_tas_type := trns_rec.tas_type;
        l_date_trn := trns_rec.date_trans_occurred;

     END LOOP;

     -- Check trx_id
     IF l_id IS NULL
     OR l_id = -999 THEN

        OKL_API.set_message(
                  p_app_name      => 'OKC',
                  p_msg_name      => G_INVALID_VALUE,
                  p_token1        => G_COL_NAME_TOKEN,
                  p_token1_value  => 'p_tas_id');

        RAISE OKL_API.G_EXCEPTION_ERROR;

     END IF;

     -- Check trn type
     IF l_tas_type <> 'AMT' THEN

        -- get the trn type OKL_TRANS_HEADER_TYPE
        FOR amt_rec IN amt_csr (l_tas_type) LOOP

           l_trns_type := amt_rec.meaning;

        END LOOP;

        -- Transaction type TRANSACTION_TYPE is not updateable.
        OKL_API.set_message(
                  p_app_name      => 'OKL',
                  p_msg_name      => 'OKL_AM_DEPRN_TYPE_ERR',
                  p_token1        => 'TRANSACTION_TYPE',
                  p_token1_value  => l_trns_type);

        RAISE OKL_API.G_EXCEPTION_ERROR;

     END IF;

     -- Check trn status
     IF l_tsu_code NOT IN ('ENTERED') THEN

        -- get the trn status
        FOR status_rec IN status_csr (l_tsu_code) LOOP

           l_status := status_rec.meaning;

        END LOOP;

        -- Transaction with status STATUS is not updateable.
        OKL_API.set_message(
                  p_app_name      => 'OKL',
                  p_msg_name      => 'OKL_AM_DEPRN_STATUS_ERR',
                  p_token1        => 'STATUS',
                  p_token1_value  => l_status);

        RAISE OKL_API.G_EXCEPTION_ERROR;

     END IF;



     -- RMUNJULU 06-May-2004
     -- Check if deprn_method passed but not life_in_months/rate
     IF  (p_deprn_rec.p_dep_method IS NOT NULL AND p_deprn_rec.p_dep_method <> OKL_API.G_MISS_CHAR )
     AND (p_deprn_rec.p_life_in_months IS NULL OR p_deprn_rec.p_life_in_months = OKL_API.G_MISS_NUM)
     -- SECHAWLA 28-MAY-04 3645574 : Added check for deprn rate
     AND (p_deprn_rec.p_deprn_rate_percent IS NULL OR p_deprn_rec.p_deprn_rate_percent = OKL_API.G_MISS_NUM) THEN

        -- SECHAWLA 28-MAY-04 3645574
        /*OKL_API.set_message(
                  p_app_name      => 'OKC',
                  p_msg_name      => G_INVALID_VALUE,
                  p_token1        => G_COL_NAME_TOKEN,
                  p_token1_value  => 'p_life_in_months');
        */

        -- SECHAWLA 28-MAY-04 3645574
        --Please provide Life In Months or Depreciation Rate.
        OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_PROV_LIFE_OR_RATE');

        RAISE OKL_API.G_EXCEPTION_ERROR;

     END IF;

     -- RMUNJULU 06-May-2004
     -- Check if life_in_months/rate is passed but not deprn_method
     IF ( (p_deprn_rec.p_life_in_months IS NOT NULL AND p_deprn_rec.p_life_in_months <> OKL_API.G_MISS_NUM )
          OR -- SECHAWLA 28-MAY-04 3645574  : added check for deprn rate
          (p_deprn_rec.p_deprn_rate_percent IS NOT NULL AND p_deprn_rec.p_deprn_rate_percent <> OKL_API.G_MISS_NUM )
        )
     AND (p_deprn_rec.p_dep_method IS NULL OR p_deprn_rec.p_dep_method = OKL_API.G_MISS_CHAR) THEN

        OKL_API.set_message(
                  p_app_name      => 'OKC',
                  --p_msg_name      => G_INVALID_VALUE, -- SECHAWLA 28-MAY-04 3645574
                  p_msg_name      => G_REQUIRED_VALUE,  -- SECHAWLA 28-MAY-04 3645574
                  p_token1        => G_COL_NAME_TOKEN,
                  p_token1_value  => 'p_dep_method');

        RAISE OKL_API.G_EXCEPTION_ERROR;

     END IF;

     -- SECHAWLA 26-MAY-04 3645574 : all 3 should not be populated
     IF (p_deprn_rec.p_dep_method IS NOT NULL AND p_deprn_rec.p_dep_method <> OKL_API.G_MISS_CHAR ) AND
        (p_deprn_rec.p_life_in_months IS NOT NULL AND p_deprn_rec.p_life_in_months <> OKL_API.G_MISS_NUM ) AND
        (p_deprn_rec.p_deprn_rate_percent IS NOT NULL AND p_deprn_rec.p_deprn_rate_percent <> OKL_API.G_MISS_NUM ) THEN
        --A depreciation method can not have both Life In Months and Depreciation Rate. Please provide only one of these values.
        OKL_API.set_message(
                  p_app_name      => 'OKL',
                  p_msg_name      => 'OKL_AM_BOTH_LIFE_AND_RATE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


     -- RMUNJULU 06-May-2004
     -- when both deprn_method and life_in_months/rate passed
     IF  (p_deprn_rec.p_dep_method IS NOT NULL AND p_deprn_rec.p_dep_method <> OKL_API.G_MISS_CHAR )
     AND ( (p_deprn_rec.p_life_in_months IS NOT NULL AND p_deprn_rec.p_life_in_months <> OKL_API.G_MISS_NUM)
           OR -- SECHAWLA 28-MAY-04 3645574  : added check for deprn rate
           (p_deprn_rec.p_deprn_rate_percent IS NOT NULL AND p_deprn_rec.p_deprn_rate_percent <> OKL_API.G_MISS_NUM )
         )  THEN

        IF p_deprn_rec.p_life_in_months IS NOT NULL THEN  -- SECHAWLA 28-MAY-04 3645574 : added this IF condition
            -- Check dep method and life in months
            FOR dep_rec IN dep_csr(p_deprn_rec.p_dep_method, p_deprn_rec.p_life_in_months) LOOP

                l_val := dep_rec.method_code;

            END LOOP;

            IF l_val IS NULL THEN

                -- Depreciation method DEPRECIATION_METHOD and life in months LIFE_IN_MONTHS is an invalid combination.
                OKL_API.set_message(
                    p_app_name      => 'OKL',
                    p_msg_name      => 'OKL_AM_DEPRN_INVALID_COMB',
                    p_token1        => 'DEPRECIATION_METHOD',
                    p_token1_value  => p_deprn_rec.p_dep_method,
                    p_token2        => 'LIFE_IN_MONTHS',
                    p_token2_value  => p_deprn_rec.p_life_in_months);

                RAISE OKL_API.G_EXCEPTION_ERROR;

            END IF;
        ELSE  -- SECHAWLA 28-MAY-04 3645574 : deprn rate is provided

            OPEN  l_flatrates_csr(p_deprn_rec.p_dep_method, p_deprn_rec.p_deprn_rate_percent);
            FETCH l_flatrates_csr INTO l_dummy;
            IF l_flatrates_csr%NOTFOUND THEN
                -- This combination of Depreciation Method DEP_METHOD and Depreciation Rate DEP_RATE is invalid.
                OKL_API.set_message(
                    p_app_name      => 'OKL',
                    p_msg_name      => 'OKL_AM_INVALID_MTHD_RATE',
                    p_token1        => 'DEP_METHOD',
                    p_token1_value  => p_deprn_rec.p_dep_method,
                    p_token2        => 'DEP_RATE',
                    p_token2_value  => p_deprn_rec.p_deprn_rate_percent);

                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            CLOSE l_flatrates_csr;

        END IF;
     END IF;

     -- if line_id is supplied
     IF p_deprn_rec.p_tal_id IS NOT NULL
     AND  p_deprn_rec.p_tal_id <> OKL_API.G_MISS_NUM THEN

        l_line_id := p_deprn_rec.p_tal_id;

     ELSE -- line id not supplied -- get from database
        -- Get line details
        FOR line_rec IN line_csr(p_deprn_rec.p_tas_id) LOOP

           l_line_id := line_rec.id;

        END LOOP;
     END IF;

     -- Set the Header rec
     lp_header_rec.id := p_deprn_rec.p_tas_id;

     -- if date trn occurred supplied
     IF p_deprn_rec.p_date_trns_occured IS NOT NULL
     AND  p_deprn_rec.p_date_trns_occured <> OKL_API.G_MISS_DATE  THEN
       lp_header_rec.date_trans_occurred := p_deprn_rec.p_date_trns_occured;
     ELSE -- date not supplied-- get from database
       lp_header_rec.date_trans_occurred := l_date_trn;
     END IF;

     -- Set the line rec
     lp_lines_rec.id := l_line_id;

     -- RMUNJULU 06-May-2004
     -- when both deprn_method and life_in_months/rate are supplied then set for update
     IF  (p_deprn_rec.p_dep_method IS NOT NULL AND p_deprn_rec.p_dep_method <> OKL_API.G_MISS_CHAR)
     AND ( (p_deprn_rec.p_life_in_months IS NOT NULL AND p_deprn_rec.p_life_in_months <> OKL_API.G_MISS_NUM)
           OR --  SECHAWLA 28-MAY-04 3645574 : added deprn rate  check
           (p_deprn_rec.p_deprn_rate_percent IS NOT NULL AND p_deprn_rec.p_deprn_rate_percent <> OKL_API.G_MISS_NUM)
         ) THEN

        lp_lines_rec.deprn_method := p_deprn_rec.p_dep_method;

        --SECHAWLA 28-MAY-04 3645574 : populate life or rate
        IF p_deprn_rec.p_life_in_months IS NOT NULL THEN
           lp_lines_rec.life_in_months := p_deprn_rec.p_life_in_months;
           lp_lines_rec.deprn_rate := NULL;
        ELSE
           lp_lines_rec.deprn_rate := p_deprn_rec.p_deprn_rate_percent;
           lp_lines_rec.life_in_months := NULL;
        END IF;

     END IF;

     -- if salvage value supplied
     IF p_deprn_rec.p_salvage_value IS NOT NULL
     AND  p_deprn_rec.p_salvage_value <> OKL_API.G_MISS_NUM THEN
        lp_lines_rec.salvage_value := p_deprn_rec.p_salvage_value;
     END IF;

     -- Update header and line trns
     update_offlease_asset_trx(
             p_api_version       => p_api_version,
             p_init_msg_list     => OKL_API.G_FALSE,
             x_return_status     => l_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_header_rec        => lp_header_rec,
             p_lines_rec         => lp_lines_rec);

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     x_return_status := l_return_status;

     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      -- SECHAWLA 28-MAY-04 3645574 : close the new cursor
      IF l_flatrates_csr%ISOPEN THEN
         CLOSE l_flatrates_csr;
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

      -- SECHAWLA 28-MAY-04 3645574 : close the new cursor
      IF l_flatrates_csr%ISOPEN THEN
         CLOSE l_flatrates_csr;
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

      -- SECHAWLA 28-MAY-04 3645574 : close the new cursor
      IF l_flatrates_csr%ISOPEN THEN
         CLOSE l_flatrates_csr;
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
  END update_depreciation;

END OKL_AM_AMORTIZE_PVT;

/
