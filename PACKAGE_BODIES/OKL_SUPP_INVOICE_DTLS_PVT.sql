--------------------------------------------------------
--  DDL for Package Body OKL_SUPP_INVOICE_DTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUPP_INVOICE_DTLS_PVT" as
/* $Header: OKLCSIDB.pls 120.3 2005/10/30 04:04:21 appldev noship $ */

   /*
    * sjalasut: aug 18, 04 added constants used in raising business event. BEGIN
    */
   G_WF_EVT_ASSET_SUP_INV_CRTD CONSTANT VARCHAR2(65)   := 'oracle.apps.okl.la.lease_contract.asset_supplier_invoice_created';
   G_WF_EVT_ASSET_SUP_INV_UPTD CONSTANT VARCHAR2(65)   := 'oracle.apps.okl.la.lease_contract.asset_supplier_invoice_updated';
   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30)        := 'CONTRACT_ID';
   G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(30)           := 'ASSET_ID';
   G_WF_ITM_PARTY_ID CONSTANT VARCHAR2(15)           := 'PARTY_ID';
   G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(30)   := 'CONTRACT_PROCESS';
   /*
    * sjalasut: aug 18, 04 added constants used in raising business event. END
    */
   -------------------------------------------------------------------------------
   -- PROCEDURE raise_business_event
   -------------------------------------------------------------------------------
   -- Start of comments
   --
   -- Procedure Name  : raise_business_event
   -- Description     : This procedure is a wrapper that raises a business event
   --                 : when ever supplier invoice is created or updated.
   -- Business Rules  :
   -- Parameters      : p_chr_id,p_asset_id,p_vendor_id,p_event_name along with other api params
   -- Version         : 1.0
   -- History         : 30-AUG-2004 SJALASUT created
   -- End of comments

   PROCEDURE raise_business_event(p_api_version IN NUMBER,
                                  p_init_msg_list IN VARCHAR2,
                                  p_chr_id IN okc_k_headers_b.id%TYPE,
                                  p_asset_id IN okc_k_lines_b.id%TYPE,
                                  p_vendor_id IN po_vendors.vendor_id%TYPE,
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
     wf_event.AddParameterToList(G_WF_ITM_PARTY_ID, p_vendor_id, l_parameter_list);
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


   PROCEDURE Create_sup_inv_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_sidv_rec                     IN sidv_rec_type,
     x_sidv_rec                     OUT NOCOPY sidv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_SUP_INV_DTLS';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     /*
      * sjalasut aug 18, 04: added cursor to derive the dnz_chr_id from the dnz_cle_id
      * to pass the parameters to the business event. BEGIN
      */
     CURSOR get_chr_id (p_cle_id okc_k_lines_b.id%TYPE) IS
     SELECT dnz_chr_id, cle_id
       FROM okc_k_lines_b
      WHERE id = p_cle_id;

     --vthiruva Fix Bug#4047076 27-Dec-04
     --Added cursor to fetch the vendor id to pass to business events
     CURSOR get_vendor_id(p_chr_id okc_k_headers_b.id%TYPE,
                          p_cle_id okc_k_lines_b.id%TYPE) IS
     SELECT object1_id1 vendor_id
       FROM okc_k_party_roles_b
      WHERE dnz_chr_id = p_chr_id
        AND cle_id = p_cle_id
	AND rle_code = 'OKL_VENDOR';

     l_chr_id okc_k_headers_b.id%TYPE;
     l_cle_id okc_k_lines_b.id%TYPE;
     l_vendor_id po_vendors.vendor_id%TYPE;
     /*
      * sjalasut aug 18, 04: added cursor to derive the dnz_chr_id from the dnz_cle_id
      * to pass the parameters to the business event. END
      */

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
     OKL_SID_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_sidv_rec,
                            x_sidv_rec);
     /*
      * sjalasut: aug 18, 04 added code to enable business event. BEGIN
      * raise the event only when the contract in context is a LEASE contract
      */
     OPEN get_chr_id(p_sidv_rec.cle_id);
     FETCH get_chr_id INTO l_chr_id,l_cle_id;
     CLOSE get_chr_id;

     --vthiruva Fix Bug#4047076..27-Dec-04
     --added code to fetch vendor id
     OPEN get_vendor_id(l_chr_id,p_sidv_rec.cle_id);
     FETCH get_vendor_id INTO l_vendor_id;
     CLOSE get_vendor_id;

     IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_chr_id)= OKL_API.G_TRUE)THEN
       raise_business_event(p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => l_chr_id,
                            p_asset_id            => l_cle_id,
                            p_vendor_id           => l_vendor_id,
                            p_event_name          => G_WF_EVT_ASSET_SUP_INV_CRTD,
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
   END Create_sup_inv_dtls;

    PROCEDURE Create_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type,
    x_sidv_tbl                     OUT NOCOPY sidv_tbl_type)
    IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_SUP_INV_DTLS';
    l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
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
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_SID_PVT.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_sidv_tbl,
                           x_sidv_tbl);
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
    END Create_sup_inv_dtls;

   PROCEDURE lock_sup_inv_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_sidv_rec                     IN sidv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_SUP_INV_DTLS';
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
     OKL_SID_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_sidv_rec);
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
   END lock_sup_inv_dtls;

   PROCEDURE lock_sup_inv_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_sidv_tbl                     IN sidv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_SUP_INV_DTLS';
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
     OKL_SID_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_sidv_tbl);
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
   END lock_sup_inv_dtls;

   PROCEDURE update_sup_inv_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_sidv_rec                     IN sidv_rec_type,
     x_sidv_rec                     OUT NOCOPY sidv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_SUP_INV_DTLS';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
     /*
      * sjalasut aug 18, 04: added cursor to derive the dnz_chr_id from the dnz_cle_id
      * to pass the parameters to the business event. BEGIN
      */
     CURSOR get_chr_id (p_cle_id okc_k_lines_b.id%TYPE) IS
     SELECT a.dnz_chr_id, a.cle_id, b.cle_id
       FROM okc_k_lines_b a,
            okl_supp_invoice_dtls b
      WHERE a.id = b.cle_id
        AND b.id = p_cle_id;

     --vthiruva Fix Bug#4047076..27-Dec-04
     --Added cursor to fetch the vendor id to pass to business events
     CURSOR get_vendor_id(p_chr_id okc_k_headers_b.id%TYPE,
                          p_cle_id okc_k_lines_b.id%TYPE) IS
     SELECT object1_id1 vendor_id
       FROM okc_k_party_roles_b
      WHERE dnz_chr_id = p_chr_id
        AND cle_id = p_cle_id
	AND rle_code = 'OKL_VENDOR';

     l_chr_id okc_k_headers_b.id%TYPE;
     l_cle_id okc_k_lines_b.id%TYPE;
     l_supp_inv_ln_id okc_k_lines_b.id%TYPE;
     l_vendor_id po_vendors.vendor_id%TYPE;
     /*
      * sjalasut aug 18, 04: added cursor to derive the dnz_chr_id from the dnz_cle_id
      * to pass the parameters to the business event. END
      */

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
     OKL_SID_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_sidv_rec,
                            x_sidv_rec);
     /*
      * sjalasut: aug 18, 04 added code to enable business event. BEGIN
      * raise the event only is the contract in context is a LEASE contract
      */
     OPEN get_chr_id(p_sidv_rec.id);
     FETCH get_chr_id INTO l_chr_id,l_cle_id,l_supp_inv_ln_id;
     CLOSE get_chr_id;

     --vthiruva Fix Bug#4047076..27-Dec-04
     --added code to fetch vendor id
     OPEN get_vendor_id(l_chr_id,l_supp_inv_ln_id);
     FETCH get_vendor_id INTO l_vendor_id;
     CLOSE get_vendor_id;

     IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_chr_id)= OKL_API.G_TRUE)THEN
       raise_business_event(p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => l_chr_id,
                            p_asset_id            => l_cle_id,
                            p_vendor_id           => l_vendor_id,
                            p_event_name          => G_WF_EVT_ASSET_SUP_INV_UPTD,
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
   END update_sup_inv_dtls;

   PROCEDURE update_sup_inv_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_sidv_tbl                     IN sidv_tbl_type,
     x_sidv_tbl                     OUT NOCOPY sidv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_SUP_INV_DTLS';
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
     OKL_SID_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_sidv_tbl,
                            x_sidv_tbl);
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
   END update_sup_inv_dtls;

   PROCEDURE delete_sup_inv_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_sidv_rec                     IN sidv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_SUP_INV_DTLS';
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
     OKL_SID_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_sidv_rec);
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
   END delete_sup_inv_dtls;

   PROCEDURE delete_sup_inv_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_sidv_tbl                     IN sidv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_SUP_INV_DTLS';
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
     OKL_SID_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_sidv_tbl);
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
   END delete_sup_inv_dtls;

   PROCEDURE validate_sup_inv_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_sidv_rec                     IN sidv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_SUP_INV_DTLS';
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
     OKL_SID_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_sidv_rec);
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
   END validate_sup_inv_dtls;

   PROCEDURE validate_sup_inv_dtls(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_sidv_tbl                     IN sidv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_SUP_INV_DTLS';
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
     OKL_SID_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_sidv_tbl);
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
   END validate_sup_inv_dtls;

END OKL_SUPP_INVOICE_DTLS_PVT;

/
