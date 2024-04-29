--------------------------------------------------------
--  DDL for Package Body OKL_TXL_ASSETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXL_ASSETS_PVT" as
/* $Header: OKLCTALB.pls 120.8.12010000.2 2008/10/29 22:11:02 cklee ship $ */

------------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
------------------------------------------------------------------------------------
   G_LINE_RECORD             CONSTANT  VARCHAR2(200) := 'OKL_LLA_LINE_RECORD';
   G_AMOUNT_ROUNDING         CONSTANT  VARCHAR2(200) := 'OKL_LA_ROUNDING_ERROR';

   /*
    * sjalasut: aug 18, 04 added constants used in raising business event. BEGIN
    */
   G_WF_EVT_ASSETBOOK_DPRN_CRTD CONSTANT VARCHAR2(65)   := 'oracle.apps.okl.la.lease_contract.asset_book_depreciation_created';
   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30)        := 'CONTRACT_ID';
   G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(30)           := 'ASSET_ID';
   G_WF_ITM_BOOK_CODE CONSTANT VARCHAR2(30)          := 'BOOK_CODE';
   G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(30)   := 'CONTRACT_PROCESS';
   /*
    * sjalasut: aug 18, 04 added constants used in raising business event. END
    */

   /*
    * sjalasut: aug 18, 04 added procedure to call private wrapper that raises the business event. BEGIN
    * the procedure is located at the global level and not at the insert row level as the same procedure
    * can later be used for capturing other DML logic.
    */
   -------------------------------------------------------------------------------
   -- PROCEDURE raise_business_event
   -------------------------------------------------------------------------------
   -- Start of comments
   --
   -- Procedure Name  : raise_business_event
   -- Description     : This procedure is a wrapper that raises a business event
   --                 : when ever asset book depreciation is created.
   -- Business Rules  :
   -- Parameters      : p_chr_id,p_asset_id,p_book_code,p_event_name along with other api params
   -- Version         : 1.0
   -- History         : 30-AUG-2004 SJALASUT created
   -- End of comments

   PROCEDURE raise_business_event(p_api_version IN NUMBER,
                                  p_init_msg_list IN VARCHAR2,
                                  p_chr_id IN okc_k_headers_b.id%TYPE,
                                  p_asset_id IN okc_k_lines_b.id%TYPE,
                                  p_book_code IN okl_txl_assets_b.corporate_book%TYPE,
                                  p_event_name IN VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2
                                  ) IS
     l_new_contract VARCHAR2(10);
     l_rebook_contract VARCHAR2(10);
     l_parameter_list wf_parameter_list_t;
     l_contract_process VARCHAR2(20);
   BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- wrapper API to get contract process. this API determines in which status the
     -- contract in question is.
     l_contract_process := okl_lla_util_pvt.get_contract_process(p_chr_id => p_chr_id);
     wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID, p_chr_id, l_parameter_list);
     wf_event.AddParameterToList(G_WF_ITM_ASSET_ID, p_asset_id, l_parameter_list);
     wf_event.AddParameterToList(G_WF_ITM_BOOK_CODE, p_book_code, l_parameter_list);
     wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS, l_contract_process, l_parameter_list);
     OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_event_name     => p_event_name,
                            p_parameters     => l_parameter_list);

   EXCEPTION
     WHEN OTHERS THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   END raise_business_event;

   /*
    * sjalasut: aug 18, 04 added procedure to call private wrapper that raises the business event. END
    */



   PROCEDURE Create_txl_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_talv_rec                     IN tlvv_rec_type,
     x_talv_rec                     OUT NOCOPY tlvv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_TRX_ASSETS_LINES';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     CURSOR header_curr_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
     SELECT currency_code,
            currency_conversion_type,
            currency_conversion_date
     FROM   okl_k_headers_full_v
     WHERE  id = p_chr_id;

--| start          29-Oct-08 cklee     Bug: 7492324 default salvage in here so that |
--|                               when create and copy asset can refer to the  |
--|                               same source                                  |

    --Bug# 4186455 : Do not default SV for LOANS
    --cursor to check deal type of the contract
    Cursor l_deal_type_csr (p_chr_id in number) is
    select khr.deal_type,
           khr.pdt_id,
           pdt.reporting_pdt_id
    from   okl_products pdt,
           okl_k_headers            khr
    where  pdt.id           =  khr.pdt_id
    and    khr.id           =  p_chr_id;

    l_deal_type_rec    l_deal_type_csr%ROWTYPE;

    --dkagrawa changed cursor to use view OKL_PROD_QLTY_VAL_UV than okl_product_parameters_v
    --cursor to get deal type corresponding to a product
    Cursor l_pdt_deal_csr (p_pdt_id in number) is
    SELECT ppv.quality_val deal_type
    FROM   okl_prod_qlty_val_uv ppv
    WHERE  ppv.quality_name IN ('LEASE','INVESTOR')
    AND    ppv.pdt_id = p_pdt_id;

    l_pdt_deal_rec l_pdt_deal_csr%ROWTYPE;


    Cursor l_residual_value_csr (p_kle_id in number) is
    select kle.residual_value
    from   okl_k_lines kle
    where  kle.id           =  p_kle_id;

    l_residual_value_rec    l_residual_value_csr%ROWTYPE;
    --End Bug# 4186455 : Do not default SV for LOANS
--| end          29-Oct-08 cklee     Bug: 7492324 default salvage in here so that |
--|                               when create and copy asset can refer to the  |
--|                               same source                                  |

     l_header_curr_code       OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
     l_header_curr_conv_type  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_TYPE%TYPE;
     l_header_curr_conv_date  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_DATE%TYPE;

     l_talv_rec tlvv_rec_type;

     /*
      * sjalasut: oct 14, 04 added cursor and cursor variable to obtain the asset id against which
      * the book depreciation is being created. BEGIN
      */
     CURSOR c_get_cle_id IS
     SELECT cle_id
       FROM okc_k_lines_b
      WHERE id = p_talv_rec.kle_id;

     l_cle_id okc_k_lines_b.cle_id%TYPE;

   BEGIN
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     l_talv_rec := p_talv_rec;
     --
     -- Get Currency from contract header if not provided
     -- at p_talv_rec record
     -- Fix Bug# 2737014
     --
     IF (p_talv_rec.currency_code IS NULL) THEN

        l_header_curr_code      := NULL;
        l_header_curr_conv_type := NULL;
        l_header_curr_conv_date := NULL;

        OPEN header_curr_csr (p_talv_rec.dnz_khr_id);
        FETCH header_curr_csr INTO l_header_curr_code,
                                   l_header_curr_conv_type,
                                   l_header_curr_conv_date;
        CLOSE header_curr_csr;

        IF (l_header_curr_code IS NOT NULL) THEN
           l_talv_rec.currency_code            := l_header_curr_code;
           l_talv_rec.currency_conversion_type := l_header_curr_conv_type;
           l_talv_rec.currency_conversion_date := l_header_curr_conv_date;
        END IF;
     END IF;

--| start          29-Oct-08 cklee     Bug: 7492324 default salvage in here so that |
--|                               when create and copy asset can refer to the  |
--|                               same source                                  |
      --------------
      --Bug# 4082635
      -------------
      OPEN l_residual_value_csr (p_talv_rec.kle_id);
      FETCH l_residual_value_csr INTO l_residual_value_rec;
      CLOSE l_residual_value_csr;


      If nvl(l_talv_rec.salvage_value,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM AND
         nvl(l_talv_rec.percent_salvage_value, OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM  then
          --Bug# 4186455 : Do not populate salvage value for Loan and loan revolving deal types
          for l_deal_type_rec in l_deal_type_csr(p_chr_id => l_talv_rec.dnz_khr_id)
          loop
              If l_deal_type_rec.deal_type = 'LOAN' then
                  If nvl(l_deal_type_rec.reporting_pdt_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      for l_pdt_deal_rec in l_pdt_deal_csr(p_pdt_id => l_deal_type_rec.reporting_pdt_id)
                      loop
                          If l_pdt_deal_rec.deal_type = 'LEASEOP' then -- reporting pdt is operating lease

                               l_talv_rec.salvage_value := nvl(l_residual_value_rec.residual_value,0);

                          End If;
                      End loop;
                  End If;
              Elsif l_deal_type_rec.deal_type = 'LOAN-REVOLVING' then
                  null;
              Else -- for LEASEOP, LEASEDF, LEASEST
                  l_talv_rec.salvage_value := nvl(l_residual_value_rec.residual_value,0);

              End If;
          End Loop;
      End If;
      ------------------
      --End Bug# 4082635
      ------------------
--| end          29-Oct-08 cklee     Bug: 7492324 default salvage in here so that |
--|                               when create and copy asset can refer to the  |
--|                               same source                                  |

     --Bug# 3657624 : Depreciation Rate should not be divided by 100
     /*
     --Bug# 3621663 : To support flat rate methods
     If nvl(l_talv_rec.deprn_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
        l_talv_rec.deprn_rate := l_talv_rec.deprn_rate/100;
     End If;
     --Bug# 3621663
     */
     --Bug# 3657624 End

     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_TAL_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_talv_rec,
                            x_talv_rec);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     /*
      * sjalasut: aug 18, 04 added code to enable business event. BEGIN
      * raise the event only if the contract in context is a LEASE contract
      */
     OPEN c_get_cle_id;
     FETCH c_get_cle_id INTO l_cle_id;
     CLOSE c_get_cle_id;
     IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_talv_rec.dnz_khr_id)= OKL_API.G_TRUE
        AND (l_talv_rec.corporate_book IS NOT NULL
             AND l_talv_rec.corporate_book <> OKL_API.G_MISS_CHAR))THEN
       raise_business_event(p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => l_talv_rec.dnz_khr_id,
                            p_asset_id            => l_cle_id,
                            p_book_code           => l_talv_rec.corporate_book,
                            p_event_name          => G_WF_EVT_ASSETBOOK_DPRN_CRTD,
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data
                           );
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     /*
      * sjalasut: aug 18, 04 added code to enable business event. END
      */

     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PVT');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');
   END Create_txl_asset_def;

    PROCEDURE Create_txl_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN tlvv_tbl_type,
    x_talv_tbl                     OUT NOCOPY tlvv_tbl_type)
    IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_TRX_ASSETS_LINES';
    l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

    p                      NUMBER := 0;
    i                      NUMBER := 0;
    BEGIN
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY (l_api_name
	                                       ,p_init_msg_list
                                               ,'_PVT'
                                               , x_return_status);
    -- Check if activity started successfully
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        Create_txl_asset_def (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i),
          x_talv_rec                     => x_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
      END LOOP;
    END IF;
/*
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TAL_PVT.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_talv_tbl,
                           x_talv_tbl);
*/

    OKC_API.END_ACTIVITY (x_msg_count
                          ,x_msg_data );

    EXCEPTION
	     WHEN OKC_API.G_EXCEPTION_ERROR THEN
			    x_return_status := OKC_API.HANDLE_EXCEPTIONS
						 (l_api_name,
						 G_PKG_NAME,
						 'OKC_API.G_RET_STS_ERROR',
						 x_msg_count,
						 x_msg_data,
						 '_PVT');
             WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
			    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
						(l_api_name,
						G_PKG_NAME,
						'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count,
						x_msg_data,
						'_PVT');
             WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                          ( l_api_name,
						  G_PKG_NAME,
						  'OTHERS',
						  x_msg_count,
						  x_msg_data,
						  '_PVT');
    END Create_txl_asset_def;

   PROCEDURE lock_txl_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_talv_rec                     IN tlvv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_TRX_ASSETS_LINES';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_TAL_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_talv_rec);
     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PVT');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');
   END lock_txl_asset_def;

   PROCEDURE lock_txl_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_talv_tbl                     IN tlvv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_TRX_ASSETS_LINES';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_TAL_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_talv_tbl);
     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PVT');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');
   END lock_txl_asset_def;

   PROCEDURE update_txl_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_talv_rec                     IN tlvv_rec_type,
     x_talv_rec                     OUT NOCOPY tlvv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_TRX_ASSETS_LINES';
     ln_chr_id                    OKC_K_LINES_B.DNZ_CHR_ID%TYPE;

     -- Temp parameters to store depreciation cost and salvage values.
     l_deprn_cost           NUMBER;
     l_salvage_value        NUMBER;
     l_currency_code        VARCHAR2(15);

     l_talv_rec        tlvv_rec_type;

     CURSOR get_chr_id(p_kle_id OKL_TXL_ASSETS_B.KLE_ID%TYPE)
     IS
     SELECT cle.dnz_chr_id
     FROM okc_k_lines_b cle,
          okl_txl_assets_b tal
     WHERE tal.kle_id = cle.id
     AND tal.kle_id = p_kle_id;
/*
     CURSOR c_get_currency_code(p_kle_id OKC_K_LINES_B.ID%TYPE) IS
     SELECT currency_code
     FROM OKC_K_LINES_B
     WHERE id = p_kle_id;
*/
     CURSOR header_curr_csr(p_txl_id OKL_TXL_ASSETS_V.ID%TYPE) IS
     SELECT h.currency_code,
            h.currency_conversion_type,
            h.currency_conversion_date
     FROM   okl_k_headers_full_v h,
            okl_txl_assets_v asset
     WHERE  h.id     = asset.dnz_khr_id
     AND    asset.id = p_txl_id;

    /*
     *vthiruva..fix for business events..30-Dec-2004..Start
     *added cursor to fetch the params to pass to raise business event
     */
     CURSOR get_event_params(p_id OKL_TXL_ASSETS_B.ID%TYPE) IS
     SELECT lines.dnz_chr_id,lines.cle_id,tal.corporate_book
     FROM okc_k_lines_b lines,
          okl_txl_assets_b tal
     WHERE tal.id = p_id
     AND lines.id = tal.kle_id;

--| start          29-Oct-08 cklee     Bug: 7492324 default salvage in here so that |
--|                               when create and copy asset can refer to the  |
--|                               same source                                  |

    --Bug# 4186455 : Do not default SV for LOANS
    --cursor to check deal type of the contract
    Cursor l_deal_type_csr (p_chr_id in number) is
    select khr.deal_type,
           khr.pdt_id,
           pdt.reporting_pdt_id
    from   okl_products pdt,
           okl_k_headers            khr
    where  pdt.id           =  khr.pdt_id
    and    khr.id           =  p_chr_id;

    l_deal_type_rec    l_deal_type_csr%ROWTYPE;

    --dkagrawa changed cursor to use view OKL_PROD_QLTY_VAL_UV than okl_product_parameters_v
    --cursor to get deal type corresponding to a product
    Cursor l_pdt_deal_csr (p_pdt_id in number) is
    SELECT ppv.quality_val deal_type
    FROM   okl_prod_qlty_val_uv ppv
    WHERE  ppv.quality_name IN ('LEASE','INVESTOR')
    AND    ppv.pdt_id = p_pdt_id;

    l_pdt_deal_rec l_pdt_deal_csr%ROWTYPE;


    Cursor l_residual_value_csr (p_kle_id in number) is
    select kle.residual_value
    from   okl_k_lines kle
    where  kle.id           =  p_kle_id;

    l_residual_value_rec    l_residual_value_csr%ROWTYPE;
    --End Bug# 4186455 : Do not default SV for LOANS
--| end          29-Oct-08 cklee     Bug: 7492324 default salvage in here so that |
--|                               when create and copy asset can refer to the  |
--|                               same source                                  |

     l_contract_id    okc_k_headers_b.id%TYPE;
     l_asset_id       okc_k_lines_b.id%TYPE;
     l_old_book_code  okl_txl_assets_b.corporate_book%TYPE;
     --vthiruva..fix for business events..30-Dec-2004..end

     l_header_curr_code       OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
     l_header_curr_conv_type  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_TYPE%TYPE;
     l_header_curr_conv_date  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_DATE%TYPE;

   BEGIN
     x_return_status  := OKL_API.G_RET_STS_SUCCESS;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     --Bug# 4959361
    OKL_LLA_UTIL_PVT.check_line_update_allowed
      (p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_cle_id          => p_talv_rec.kle_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 4959361

     l_talv_rec := p_talv_rec;
     --
     -- Get Currency from contract header if not provided
     -- at p_talv_rec record
     -- Fix Bug# 2737014
     --
     IF (p_talv_rec.currency_code IS NULL) THEN

        l_header_curr_code      := NULL;
        l_header_curr_conv_type := NULL;
        l_header_curr_conv_date := NULL;

        OPEN header_curr_csr (p_talv_rec.id);
        FETCH header_curr_csr INTO l_header_curr_code,
                                   l_header_curr_conv_type,
                                   l_header_curr_conv_date;
        CLOSE header_curr_csr;

        IF (l_header_curr_code IS NOT NULL) THEN
           l_talv_rec.currency_code            := l_header_curr_code;
           l_talv_rec.currency_conversion_type := l_header_curr_conv_type;
           l_talv_rec.currency_conversion_date := l_header_curr_conv_date;
        END IF;
     END IF;

/* Rounding is done on corresponding TAPI

    -- Modified by rravikir
    -- Call to Accounting Util package to address Multi Currency requirement
    -- Start
    -- Copy p_talv_rec to l_talv_rec
    l_talv_rec := p_talv_rec;
    OPEN c_get_currency_code(p_kle_id => l_talv_rec.kle_id);

    IF c_get_currency_code%NOTFOUND THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_get_currency_code INTO l_currency_code;
    CLOSE c_get_currency_code;

    l_deprn_cost := l_talv_rec.depreciation_cost;
    l_salvage_value := l_talv_rec.salvage_value;

    l_talv_rec.depreciation_cost :=
        OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_talv_rec.depreciation_cost,
                                                        l_currency_code);

    IF (l_deprn_cost <> 0 AND l_talv_rec.depreciation_cost = 0) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_AMOUNT_ROUNDING,
                          p_token1       => 'AMT',
                          p_token1_value => to_char(l_deprn_cost));
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_talv_rec.salvage_value :=
        OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_talv_rec.salvage_value,
                                                        l_currency_code);

    IF (l_salvage_value <> 0 AND l_talv_rec.salvage_value = 0) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_AMOUNT_ROUNDING,
                          p_token1       => 'AMT',
                          p_token1_value => to_char(l_salvage_value));
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- End Modification for Multi Currency
 */

     --Bug# 3657624 : Depreciation Rate should not be divided by 100
     /*
     --Bug# 3621663 : To support flat rate methods
     If nvl(l_talv_rec.deprn_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
        l_talv_rec.deprn_rate := l_talv_rec.deprn_rate/100;
     End If;
     --Bug# 3621663
     */
     --Bug# 3657624 End
     --vthiruva..fix for business events..30-Dec-2004..Start
     OPEN get_event_params(l_talv_rec.id);
     IF get_event_params%NOTFOUND THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     FETCH get_event_params INTO l_contract_id, l_asset_id, l_old_book_code;
     CLOSE get_event_params;
     --vthiruva..fix for business events..30-Dec-2004..End

--| start          29-Oct-08 cklee     Bug: 7492324 default salvage in here so that |
--|                               when create and copy asset can refer to the  |
--|                               same source                                  |

      --------------
      --Bug# 4082635
      -------------
      OPEN l_residual_value_csr (p_talv_rec.kle_id);
      FETCH l_residual_value_csr INTO l_residual_value_rec;
      CLOSE l_residual_value_csr;

      If nvl(l_talv_rec.salvage_value,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM AND
         nvl(l_talv_rec.percent_salvage_value, OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM  then
          --Bug# 4186455 : Do not populate salvage value for Loan and loan revolving deal types

          for l_deal_type_rec in l_deal_type_csr(p_chr_id => l_contract_id)
          loop

              If l_deal_type_rec.deal_type = 'LOAN' then
                  If nvl(l_deal_type_rec.reporting_pdt_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      for l_pdt_deal_rec in l_pdt_deal_csr(p_pdt_id => l_deal_type_rec.reporting_pdt_id)
                      loop
                          If l_pdt_deal_rec.deal_type = 'LEASEOP' then -- reporting pdt is operating lease
                            IF l_talv_rec.salvage_value is null THEN
                               l_talv_rec.salvage_value := nvl(l_residual_value_rec.residual_value,0);

                            END IF;
                          End If;
                      End loop;
                  End If;
              Elsif l_deal_type_rec.deal_type = 'LOAN-REVOLVING' then
                  null;
              Else -- for LEASEOP, LEASEDF, LEASEST
                IF l_talv_rec.salvage_value is null THEN
                  l_talv_rec.salvage_value := nvl(l_residual_value_rec.residual_value,0);
                END IF;
              End If;
          End Loop;
      End If;
      ------------------
      --End Bug# 4082635
      ------------------
--| end         29-Oct-08 cklee     Bug: 7492324 default salvage in here so that |
--|                               when create and copy asset can refer to the  |
--|                               same source                                  |

     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_TAL_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_talv_rec,
                            x_talv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     IF x_talv_rec.tal_type in ('CFA','CIB','CRB','CRL','CRV','CSP','ALI') THEN
       OPEN get_chr_id(x_talv_rec.kle_Id);
       IF get_chr_id%NOTFOUND THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       FETCH get_chr_id INTO ln_chr_id;
       CLOSE get_chr_id;
       -- We need to change the status of the header whenever there is updating happening
       -- after the contract status is approved
       IF (ln_chr_id is NOT NULL) AND
          (ln_chr_id <> OKL_API.G_MISS_NUM) THEN
         --cascade edit status on to lines
         okl_contract_status_pub.cascade_lease_status_edit
                  (p_api_version     => p_api_version,
                   p_init_msg_list   => p_init_msg_list,
                   x_return_status   => x_return_status,
                   x_msg_count       => x_msg_count,
                   x_msg_data        => x_msg_data,
                   p_chr_id          => ln_chr_id);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
     END IF;

     --vthiruva..fix for business events..30-Dec-2004..Start
     IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_contract_id)= OKL_API.G_TRUE
        AND l_old_book_code IS NULL
        AND (l_talv_rec.corporate_book IS NOT NULL
             AND l_talv_rec.corporate_book <> OKL_API.G_MISS_CHAR))THEN
       raise_business_event(p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => l_contract_id,
                            p_asset_id            => l_asset_id,
                            p_book_code           => l_talv_rec.corporate_book,
                            p_event_name          => G_WF_EVT_ASSETBOOK_DPRN_CRTD,
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data
                           );
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --vthiruva..fix for business events..30-Dec-2004..end

     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PVT');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');
   END update_txl_asset_def;

   PROCEDURE update_txl_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_talv_tbl                     IN tlvv_tbl_type,
     x_talv_tbl                     OUT NOCOPY tlvv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_TRX_ASSETS_LINES';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     p                      NUMBER := 0;

   BEGIN
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

    -- Modified by rravikir
    -- calling update_txl_asset_def record version to update records

    IF p_talv_tbl.COUNT > 0 THEN
      p := p_talv_tbl.FIRST;
      LOOP
        update_txl_asset_def(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_talv_rec       => p_talv_tbl(p),
                             x_talv_rec       => x_talv_tbl(p));

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (p = p_talv_tbl.LAST);
        p := p_talv_tbl.NEXT(p);
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- End Modification

     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
/*     OKL_TAL_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_talv_tbl,
                            x_talv_tbl);*/
     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PVT');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');
   END update_txl_asset_def;

   PROCEDURE delete_txl_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_talv_rec                     IN tlvv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_TRX_ASSETS_LINES';
     ln_chr_id                    OKC_K_LINES_B.DNZ_CHR_ID%TYPE;
     CURSOR get_chr_id(p_kle_id OKL_TXL_ASSETS_B.KLE_ID%TYPE)
     IS
     SELECT cle.dnz_chr_id
     FROM okc_k_lines_b cle,
          okl_txl_assets_b tal
     WHERE tal.kle_id = cle.id
     AND tal.kle_id = p_kle_id;
   BEGIN
     x_return_status  := OKC_API.G_RET_STS_SUCCESS;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_TAL_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_talv_rec);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     IF p_talv_rec.tal_type in ('CFA','CIB','CRB','CRL','CRV','CSP','ALI') THEN
       OPEN get_chr_id(p_talv_rec.kle_Id);
       IF get_chr_id%NOTFOUND THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       FETCH get_chr_id INTO ln_chr_id;
       CLOSE get_chr_id;
       -- We need to change the status of the header whenever there is updating happening
       -- after the contract status is approved
       IF (ln_chr_id is NOT NULL) AND
          (ln_chr_id <> OKL_API.G_MISS_NUM) THEN
         --cascade edit status on to lines
         okl_contract_status_pub.cascade_lease_status_edit
                  (p_api_version     => p_api_version,
                   p_init_msg_list   => p_init_msg_list,
                   x_return_status   => x_return_status,
                   x_msg_count       => x_msg_count,
                   x_msg_data        => x_msg_data,
                   p_chr_id          => ln_chr_id);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
     END IF;
     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PVT');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');
   END delete_txl_asset_def;

   PROCEDURE delete_txl_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_talv_tbl                     IN tlvv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_TRX_ASSETS_LINES';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_TAL_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_talv_tbl);
     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PVT');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');
   END delete_txl_asset_def;

   PROCEDURE validate_txl_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_talv_rec                     IN tlvv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_TRX_ASSETS_LINES';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_TAL_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_talv_rec);
     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PVT');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');
   END validate_txl_asset_def;

   PROCEDURE validate_txl_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_talv_tbl                     IN tlvv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_TRX_ASSETS_LINES';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_TAL_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_talv_tbl);
     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PVT');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PVT');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PVT');
   END validate_txl_asset_def;

END OKL_TXL_ASSETS_PVT;

/
