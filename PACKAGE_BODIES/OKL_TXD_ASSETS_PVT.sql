--------------------------------------------------------
--  DDL for Package Body OKL_TXD_ASSETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXD_ASSETS_PVT" as
/* $Header: OKLCASDB.pls 120.6 2006/02/22 17:17:56 rpillay noship $ */

------------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
------------------------------------------------------------------------------------
   G_LINE_RECORD             CONSTANT  VARCHAR2(200) := 'OKL_LLA_LINE_RECORD';
   G_AMOUNT_ROUNDING         CONSTANT  VARCHAR2(200) := 'OKL_LA_ROUNDING_ERROR';

   /*
    * sjalasut: aug 18, 04 added constants used in raising business event. BEGIN
    */
   G_WF_EVT_ASSETTAX_DPRN_CRTD CONSTANT VARCHAR2(65) := 'oracle.apps.okl.la.lease_contract.asset_tax_depreciation_created';
   G_WF_EVT_ASSETTAX_DPRN_RMVD CONSTANT VARCHAR2(65)  := 'oracle.apps.okl.la.lease_contract.remove_asset_tax_depreciation';
   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30)        := 'CONTRACT_ID';
   G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(30)           := 'ASSET_ID';
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
   --                 : when ever asset tax depreciation is created or updated.
   -- Business Rules  :
   -- Parameters      : p_chr_id,p_asset_id, p_event_name along with other api params
   -- Version         : 1.0
   -- History         : 30-AUG-2004 SJALASUT created
   -- End of comments

   PROCEDURE raise_business_event(p_api_version IN NUMBER,
                                  p_init_msg_list IN VARCHAR2,
                                  p_chr_id IN okc_k_headers_b.id%TYPE,
                                  p_asset_id IN okc_k_lines_b.id%TYPE,
                                  p_event_name IN VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2
                                  ) IS
     l_parameter_list wf_parameter_list_t;
     l_contract_process VARCHAR2(20);
   BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- wrapper API to get contract process. this API determines in which status the
     -- contract in question is.
     l_contract_process := okl_lla_util_pvt.get_contract_process(p_chr_id => p_chr_id);
     wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID, p_chr_id, l_parameter_list);
     wf_event.AddParameterToList(G_WF_ITM_ASSET_ID, p_asset_id, l_parameter_list);
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


   PROCEDURE Create_txd_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_rec                     IN advv_rec_type,
     x_asdv_rec                     OUT NOCOPY advv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_TRX_ASSETS_LINE_DTL';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     -- Temp parameters to store cost and currency code
     l_cost                       OKL_TXD_ASSETS_B.COST%TYPE;
     l_currency_code              OKL_TXD_ASSETS_B.CURRENCY_CODE%TYPE;
     l_asdv_rec             advv_rec_type := p_asdv_rec;

     -- Bug# 3477560
     ln_chr_id                    OKC_K_LINES_B.DNZ_CHR_ID%TYPE;
     CURSOR get_chr_id(p_tal_id OKL_TXD_ASSETS_B.TAL_ID%TYPE)
     IS
     SELECT to_char(cle.dnz_chr_id)
     FROM okc_k_lines_b cle,
          okl_txl_assets_b tal,
          okl_txd_assets_b txd
     WHERE tal.kle_id = cle.id
     AND tal.id = txd.tal_id
     AND tal.tal_type in ('CFA','CIB','CRB','CRL','CRV','CSP','ALI')
     AND txd.tal_id = p_tal_id;

/*
     CURSOR c_get_currency_code(p_tal_id OKL_TXL_ASSETS_B.ID%TYPE) IS
     SELECT tal.currency_code
     FROM OKL_TXL_ASSETS_B tal
     WHERE tal.id = p_tal_id;
*/
     CURSOR header_curr_csr(p_tal_id OKL_TXD_ASSETS_V.TAL_ID%TYPE) IS
     SELECT h.currency_code,
            h.currency_conversion_type,
            h.currency_conversion_date
     FROM   okl_k_headers_full_v h,
            okl_txl_assets_v txl
     WHERE  h.id = txl.dnz_khr_id
     AND    txl.id = p_tal_id;

     /*
      * sjalasut added cursor to derive the contract header id and contract line id. BEGIN
      *
      */
     CURSOR get_chr_and_cle_id(p_tal_id OKL_TXD_ASSETS_B.TAL_ID%TYPE)
     IS
     SELECT to_char(cle.dnz_chr_id) chr_id, cle.cle_id cle_id
     FROM okc_k_lines_b cle,
          okl_txl_assets_b tal,
          okl_txd_assets_b txd
     WHERE tal.kle_id = cle.id
     AND tal.id = txd.tal_id
     AND tal.tal_type in ('CFA','CIB','CRB','CRL','CRV','CSP','ALI')
     AND txd.tal_id = p_tal_id;

     l_chr_id okc_k_headers_b.id%TYPE;
     l_cle_id okc_k_lines_b.id%TYPE;

     /*
      * sjalasut added cursor to derive the contract header id and contract line id. END
      *
      */

     l_header_curr_code       OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
     l_header_curr_conv_type  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_TYPE%TYPE;
     l_header_curr_conv_date  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_DATE%TYPE;

     --Bug# 4959361
     CURSOR l_tal_csr(p_tal_id IN NUMBER) IS
     SELECT kle_id
     FROM okl_txl_assets_b tal
     WHERE tal.id = p_tal_id;

     l_tal_rec l_tal_csr%ROWTYPE;
     --Bug# 4959361

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

/* rounding is doen at corresponding TAPI
    -- Modified by rravikir
    -- Call to Accounting Util package to address Multi Currency requirement
    -- Start
    OPEN c_get_currency_code(p_tal_id => l_asdv_rec.tal_id);
    IF c_get_currency_code%NOTFOUND THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_get_currency_code INTO l_currency_code;
    CLOSE c_get_currency_code;

    l_cost := l_asdv_rec.cost;
    l_asdv_rec.cost :=
        OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_asdv_rec.cost,
                                                        l_currency_code);
    IF (l_cost <> 0 AND l_asdv_rec.cost = 0) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_AMOUNT_ROUNDING,
                          p_token1       => 'AMT',
                          p_token1_value => to_char(l_cost));
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- End Modification for Multi Currency
*/

    --Bug# 4959361
    OPEN l_tal_csr(p_tal_id => p_asdv_rec.tal_id);
    FETCH l_tal_csr INTO l_tal_rec;
    CLOSE l_tal_csr;

    IF l_tal_rec.kle_id IS NOT NULL THEN
      OKL_LLA_UTIL_PVT.check_line_update_allowed
        (p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_cle_id          => l_tal_rec.kle_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    --Bug# 4959361

     l_asdv_rec := p_asdv_rec;
     --
     -- Get Currency from contract header if not provided
     -- at p_talv_rec record
     -- Fix Bug# 2737014
     --
     IF (p_asdv_rec.currency_code IS NULL) THEN

        l_header_curr_code      := NULL;
        l_header_curr_conv_type := NULL;
        l_header_curr_conv_date := NULL;

        OPEN header_curr_csr (p_asdv_rec.tal_id);
        FETCH header_curr_csr INTO l_header_curr_code,
                                   l_header_curr_conv_type,
                                   l_header_curr_conv_date;
        CLOSE header_curr_csr;

        IF (l_header_curr_code IS NOT NULL) THEN
           l_asdv_rec.currency_code            := l_header_curr_code;
           l_asdv_rec.currency_conversion_type := l_header_curr_conv_type;
           l_asdv_rec.currency_conversion_date := l_header_curr_conv_date;
        END IF;
     END IF;

     --Bug# 3657624 : Depreciation Rate should not be divided by 100
     /*
     --Bug# 3573504 : Flat rate method support
     If nvl(l_asdv_rec.DEPRN_RATE_TAX,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
         l_asdv_rec.DEPRN_RATE_TAX := l_asdv_rec.DEPRN_RATE_TAX/100;
     End If;
     --Bug# 3573504
     */
     --Bug# 3657624

     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_ASD_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_asdv_rec,
                            x_asdv_rec);

     /*
      * sjalasut: aug 18, 04 added code to enable business event. BEGIN
      * raise event only if the context contract is a LEASE contract
      */
     -- get the contract header id
     OPEN get_chr_and_cle_id(x_asdv_rec.tal_id);
     FETCH get_chr_and_cle_id INTO l_chr_id, l_cle_id;
     CLOSE get_chr_and_cle_id;
     IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_chr_id)= OKL_API.G_TRUE)THEN
       raise_business_event(p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => l_chr_id,
                            p_asset_id            => l_cle_id,
                            p_event_name          => G_WF_EVT_ASSETTAX_DPRN_CRTD,
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

     -- Bug# 3477560
     OPEN get_chr_id(x_asdv_rec.tal_Id);
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
   END Create_txd_asset_def;

    PROCEDURE Create_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN advv_tbl_type,
    x_asdv_tbl                     OUT NOCOPY advv_tbl_type)
    IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_TRX_ASSETS_LINE_DTL';
    l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

    p                      NUMBER := 0;
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

    -- Modified by rravikir
    -- calling create_txd_asset_def record version to create records

    IF p_asdv_tbl.COUNT > 0 THEN
      p := p_asdv_tbl.FIRST;
      LOOP
        create_txd_asset_def(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_asdv_rec       => p_asdv_tbl(p),
                             x_asdv_rec       => x_asdv_tbl(p));

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (p = p_asdv_tbl.LAST);
        p := p_asdv_tbl.NEXT(p);
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
/*    OKL_ASD_PVT.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_asdv_tbl,
                           x_asdv_tbl);*/

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
    END Create_txd_asset_def;

   PROCEDURE lock_txd_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_rec                     IN advv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_TRX_ASSETS_LINE_DTL';
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
     OKL_ASD_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_rec);
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
   END lock_txd_asset_def;

   PROCEDURE lock_txd_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_tbl                     IN advv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_TRX_ASSETS_LINE_DTL';
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
     OKL_ASD_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_tbl);
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
   END lock_txd_asset_def;

   PROCEDURE update_txd_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_rec                     IN advv_rec_type,
     x_asdv_rec                     OUT NOCOPY advv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_TRX_ASSETS_LINE_DTL';
     ln_chr_id                    OKC_K_LINES_B.DNZ_CHR_ID%TYPE;

     -- Temp parameters to store cost and currency code
     l_cost                       OKL_TXD_ASSETS_B.COST%TYPE;
     l_currency_code              OKL_TXD_ASSETS_B.CURRENCY_CODE%TYPE;

     l_asdv_rec             advv_rec_type := p_asdv_rec;

     CURSOR get_chr_id(p_tal_id OKL_TXD_ASSETS_B.TAL_ID%TYPE)
     IS
     SELECT to_char(cle.dnz_chr_id)
     FROM okc_k_lines_b cle,
          okl_txl_assets_b tal,
          okl_txd_assets_b txd
     WHERE tal.kle_id = cle.id
     AND tal.id = txd.tal_id
     AND tal.tal_type in ('CFA','CIB','CRB','CRL','CRV','CSP','ALI')
     AND txd.tal_id = p_tal_id;
/*
     CURSOR c_get_currency_code(p_id OKL_TXD_ASSETS_B.ID%TYPE) IS
     SELECT tas.currency_code
     FROM OKL_TXD_ASSETS_B tas
     WHERE tas.id = p_id;
*/
     CURSOR header_curr_csr(p_txd_id OKL_TXD_ASSETS_V.ID%TYPE) IS
     SELECT h.currency_code,
            h.currency_conversion_type,
            h.currency_conversion_date
     FROM   okl_k_headers_full_v h,
            okl_txl_assets_v txl,
            okl_txd_assets_v txd
     WHERE  h.id     = txl.dnz_khr_id
     AND    txl.id   = txd.tal_id
     AND    txd.id   = p_txd_id;

     l_header_curr_code       OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
     l_header_curr_conv_type  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_TYPE%TYPE;
     l_header_curr_conv_date  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_DATE%TYPE;

     --Bug# 4959361
     CURSOR l_tal_csr(p_tal_id IN NUMBER) IS
     SELECT kle_id
     FROM okl_txl_assets_b tal
     WHERE tal.id = p_tal_id;

     l_tal_rec l_tal_csr%ROWTYPE;
     --Bug# 4959361

   BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
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

/* Rounding logic is at TAPI
    -- Modified by rravikir
    -- Call to Accounting Util package to address Multi Currency requirement
    -- Start
    OPEN c_get_currency_code(p_id => l_asdv_rec.id);

    IF c_get_currency_code%NOTFOUND THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_get_currency_code INTO l_currency_code;
    CLOSE c_get_currency_code;

    l_cost := l_asdv_rec.cost;

    l_asdv_rec.cost :=
        OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_asdv_rec.cost,
                                                        l_currency_code);

    IF (l_cost <> 0 AND l_asdv_rec.cost = 0) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_AMOUNT_ROUNDING,
                          p_token1       => 'AMT',
                          p_token1_value => to_char(l_cost));
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- End Modification for Multi Currency
*/

     --Bug# 4959361
     OPEN l_tal_csr(p_tal_id => p_asdv_rec.tal_id);
     FETCH l_tal_csr INTO l_tal_rec;
     CLOSE l_tal_csr;

     IF l_tal_rec.kle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_tal_rec.kle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

     l_asdv_rec := p_asdv_rec;
     --
     -- Get Currency from contract header if not provided
     -- at p_asdv_rec record
     -- Fix Bug# 2737014
     --
     IF (p_asdv_rec.currency_code IS NULL) THEN

        l_header_curr_code      := NULL;
        l_header_curr_conv_type := NULL;
        l_header_curr_conv_date := NULL;

        OPEN header_curr_csr (p_asdv_rec.id);
        FETCH header_curr_csr INTO l_header_curr_code,
                                   l_header_curr_conv_type,
                                   l_header_curr_conv_date;
        CLOSE header_curr_csr;

        IF (l_header_curr_code IS NOT NULL) THEN
           l_asdv_rec.currency_code            := l_header_curr_code;
           l_asdv_rec.currency_conversion_type := l_header_curr_conv_type;
           l_asdv_rec.currency_conversion_date := l_header_curr_conv_date;
        END IF;
     END IF;

     --Bug# 3657624 : Depreciation Rate should not be divided by 100
     /*
     --Bug# 3573504 : Flat rate method support
     If nvl(l_asdv_rec.DEPRN_RATE_TAX,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
         l_asdv_rec.DEPRN_RATE_TAX := l_asdv_rec.DEPRN_RATE_TAX/100;
     End If;
     --Bug# 3573504
     */
     --Bug# 3657624

     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_ASD_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_asdv_rec,
                            x_asdv_rec);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OPEN get_chr_id(x_asdv_rec.tal_Id);
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
   END update_txd_asset_def;

   PROCEDURE update_txd_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_tbl                     IN advv_tbl_type,
     x_asdv_tbl                     OUT NOCOPY advv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_TRX_ASSETS_LINE_DTL';
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
    -- calling update_txd_asset_def record version to create records

    IF p_asdv_tbl.COUNT > 0 THEN
      p := p_asdv_tbl.FIRST;
      LOOP
        update_txd_asset_def(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_asdv_rec       => p_asdv_tbl(p),
                             x_asdv_rec       => x_asdv_tbl(p));

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (p = p_asdv_tbl.LAST);
        p := p_asdv_tbl.NEXT(p);
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
     OKL_ASD_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_tbl,
                            x_asdv_tbl);
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
   END update_txd_asset_def;

   PROCEDURE delete_txd_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_rec                     IN advv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_TRX_ASSETS_LINE_DTL';
     ln_chr_id                    OKC_K_LINES_B.DNZ_CHR_ID%TYPE;

     -- Bug# 3477560
     CURSOR get_chr_id(p_txd_id OKL_TXD_ASSETS_B.ID%TYPE)
     IS
     SELECT to_char(cle.dnz_chr_id)
     FROM okc_k_lines_b cle,
          okl_txl_assets_b tal,
          okl_txd_assets_b txd
     WHERE tal.kle_id = cle.id
     AND tal.id = txd.tal_id
     AND tal.tal_type in ('CFA','CIB','CRB','CRL','CRV','CSP','ALI')
     AND txd.id = p_txd_id;

     /*
      * sjalasut added cursor to derive the contract header id and contract line id. BEGIN
      *
      */
     CURSOR get_chr_and_cle_id(p_id OKL_TXD_ASSETS_B.ID%TYPE)
     IS
     SELECT to_char(cle.dnz_chr_id) chr_id, cle.cle_id cle_id
     FROM okc_k_lines_b cle,
          okl_txl_assets_b tal,
          okl_txd_assets_b txd
     WHERE tal.kle_id = cle.id
     AND tal.id = txd.tal_id
     AND tal.tal_type in ('CFA','CIB','CRB','CRL','CRV','CSP','ALI')
     AND txd.id = p_id;

     l_chr_id okc_k_headers_b.id%TYPE;
     l_cle_id okc_k_lines_b.id%TYPE;

     /*
      * sjalasut added cursor to derive the contract header id and contract line id. END
      *
      */

     --Bug# 4959361
     CURSOR l_tal_csr(p_txd_id IN NUMBER) IS
     SELECT tal.kle_id
     FROM okl_txl_assets_b tal,
          okl_txd_assets_b txd
     WHERE tal.id = txd.tal_id
     AND   txd.id = p_txd_id;

     l_tal_rec l_tal_csr%ROWTYPE;
     --Bug# 4959361

   BEGIN
     x_return_status           := OKC_API.G_RET_STS_SUCCESS;
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
     OPEN l_tal_csr(p_txd_id => p_asdv_rec.id);
     FETCH l_tal_csr INTO l_tal_rec;
     CLOSE l_tal_csr;

     IF l_tal_rec.kle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
        (p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_cle_id          => l_tal_rec.kle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

     -- Bug# 3477560
     OPEN get_chr_id(p_asdv_rec.Id);
     FETCH get_chr_id INTO ln_chr_id;
     CLOSE get_chr_id;

     /*
      * sjalasut: aug 18, 04 added code to enable business event. BEGIN
      */
     -- get the contract header id
     OPEN get_chr_and_cle_id(p_asdv_rec.id);
     FETCH get_chr_and_cle_id INTO l_chr_id, l_cle_id;
     CLOSE get_chr_and_cle_id;
     /*
      * sjalasut: aug 18, 04 added code to enable business event. END
      */
     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_ASD_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_rec);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     /*
      * sjalasut: aug 18, 04 added code to enable business event. BEGIN
      */
     IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_chr_id)= OKL_API.G_TRUE)THEN
       raise_business_event(p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => l_chr_id,
                            p_asset_id            => l_cle_id,
                            p_event_name          => G_WF_EVT_ASSETTAX_DPRN_RMVD,
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
   END delete_txd_asset_def;

   PROCEDURE delete_txd_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_tbl                     IN advv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_TRX_ASSETS_LINE_DTL';
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
     OKL_ASD_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_tbl);
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
   END delete_txd_asset_def;

   PROCEDURE validate_txd_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_rec                     IN advv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_TRX_ASSETS_LINE_DTL';
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
     OKL_ASD_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_rec);
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
   END validate_txd_asset_def;

   PROCEDURE validate_txd_asset_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_tbl                     IN advv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_TRX_ASSETS_LINE_DTL';
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
     OKL_ASD_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_tbl);
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
   END validate_txd_asset_def;

END OKL_TXD_ASSETS_PVT;

/
