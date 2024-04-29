--------------------------------------------------------
--  DDL for Package Body OKL_TXL_ITM_INSTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXL_ITM_INSTS_PVT" as
/* $Header: OKLCITIB.pls 120.6 2005/10/30 04:03:39 appldev noship $ */

/*
 * sjalasut: aug 18, 04 added constants used in raising business event. BEGIN
 */
G_WF_EVT_ASSET_SERIAL_CRTD CONSTANT VARCHAR2(65) := 'oracle.apps.okl.la.lease_contract.asset_serial_numbers_created';
G_WF_EVT_ASSET_SERIAL_RMVD CONSTANT VARCHAR2(65)  := 'oracle.apps.okl.la.lease_contract.remove_asset_serial_numbers';
G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30)        := 'CONTRACT_ID';
G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(30)           := 'ASSET_ID';
G_WF_ITM_SERIAL_NUM CONSTANT VARCHAR2(30)         := 'SERIAL_NUMBER';
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
--                 : when ever asset serial numbers are created or deleted.
-- Business Rules  :
-- Parameters      : p_chr_id,p_asset_id, p_ser_num,p_event_name along with other api params
-- Version         : 1.0
-- History         : 30-AUG-2004 SJALASUT created
-- End of comments

PROCEDURE raise_business_event(p_api_version IN NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               p_chr_id IN okc_k_headers_b.id%TYPE,
                               p_asset_id IN okc_k_lines_b.id%TYPE,
                               p_ser_num IN okl_txl_itm_insts.serial_number%TYPE,
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
  wf_event.AddParameterToList(G_WF_ITM_SERIAL_NUM, p_ser_num, l_parameter_list);
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


   PROCEDURE Create_txl_itm_insts(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_iivv_rec                     IN iivv_rec_type,
     x_iivv_rec                     OUT NOCOPY iivv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_TXL_ITM_INSTS';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

     /*
      * sjalasut aug 18, 04: added cursor to derive the dnz_chr_id from the dnz_cle_id
      * to pass the parameters to the business event. BEGIN
      */
     CURSOR get_chr_id (p_cle_id okc_k_lines_b.id%TYPE) IS
     SELECT dnz_chr_id
       FROM okc_k_lines_b
      WHERE id = p_cle_id;

     l_chr_id okc_k_headers_b.id%TYPE;
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
     OKL_ITI_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_iivv_rec,
                            x_iivv_rec);
     /*
      * sjalasut: oct 14, 04 added code to enable business event. BEGIN
      * raise the event only if the context contract is LEASE contract
      */
     -- get the contract header id
     OPEN get_chr_id(p_iivv_rec.DNZ_CLE_ID);
     FETCH get_chr_id INTO l_chr_id;
     CLOSE get_chr_id;
     --vthiruva..09-Dec-2004..added condition to check thats serial number is not null
     IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_chr_id)= OKL_API.G_TRUE AND
        p_iivv_rec.serial_number IS NOT NULL AND p_iivv_rec.serial_number <> OKL_API.G_MISS_CHAR)THEN
       raise_business_event(p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => l_chr_id,
                            p_asset_id            => p_iivv_rec.DNZ_CLE_ID,
                            p_ser_num             => p_iivv_rec.serial_number,
                            p_event_name          => G_WF_EVT_ASSET_SERIAL_CRTD,
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
      * sjalasut: oct 14, 04 added code to enable business event. END
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
   END Create_txl_itm_insts;

    PROCEDURE Create_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iivv_tbl                     IN iivv_tbl_type,
    x_iivv_tbl                     OUT NOCOPY iivv_tbl_type)
    IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_TXL_ITM_INSTS';
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
    OKL_ITI_PVT.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_iivv_tbl,
                           x_iivv_tbl);

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
    END Create_txl_itm_insts;

   PROCEDURE lock_txl_itm_insts(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_iivv_rec                     IN iivv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_TXL_ITM_INSTS';
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
     OKL_ITI_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_iivv_rec);
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
   END lock_txl_itm_insts;

   PROCEDURE lock_txl_itm_insts(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_iivv_tbl                     IN iivv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_TXL_ITM_INSTS';
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
     OKL_ITI_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_iivv_tbl);
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
   END lock_txl_itm_insts;

   PROCEDURE update_txl_itm_insts(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_iivv_rec                     IN iivv_rec_type,
     x_iivv_rec                     OUT NOCOPY iivv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_TXL_ITM_INSTS';
     ln_chr_id                    OKC_K_LINES_B.DNZ_CHR_ID%TYPE;
     -- Bug# 3477560
     CURSOR get_chr_id(p_kle_id OKL_TXL_ASSETS_B.KLE_ID%TYPE)
     IS
     SELECT cle.dnz_chr_id
     FROM okc_k_lines_b cle
     WHERE cle.id = p_kle_id;
     --vthiruva..09-Dec-2004..Added code to enable Business Events..START
     --cursor to fetch the serial number of the item instance record being updated
     CURSOR get_serial_num(p_id okl_txl_itm_insts.id%TYPE) IS
     SELECT serial_number, dnz_cle_id
     FROM okl_txl_itm_insts
     WHERE id = p_id;

     l_old_serial_num    okl_txl_itm_insts.serial_number%TYPE;
     l_asset_id          okl_txl_itm_insts.dnz_cle_id%TYPE;
     --vthiruva..09-Dec-2004..Added code to enable Business Events..END
   BEGIN
     x_return_status   := OKC_API.G_RET_STS_SUCCESS;
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

     --vthiruva..09-Dec-2004..Added code to enable Business Events..START
     OPEN get_serial_num(p_iivv_rec.id);
     IF get_serial_num%NOTFOUND THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     FETCH get_serial_num INTO l_old_serial_num, l_asset_id;
     CLOSE get_serial_num;
     --vthiruva..09-Dec-2004..Added code to enable Business Events..END
     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_ITI_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_iivv_rec,
                            x_iivv_rec);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     IF x_iivv_rec.tal_type in ('CFA','CIB','CRB','CRL','CRV','CSP','ALI') THEN
       OPEN get_chr_id(x_iivv_rec.kle_Id);
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
       --vthiruva..09-Dec-2004..Added code to enable Business Events..START
       IF(OKL_LLA_UTIL_PVT.is_lease_contract(ln_chr_id)= OKL_API.G_TRUE)THEN
         IF(l_old_serial_num IS NULL AND
	    (p_iivv_rec.serial_number IS NOT NULL AND
	     p_iivv_rec.serial_number <> OKL_API.G_MISS_CHAR)) THEN
           raise_business_event(p_api_version         => p_api_version,
                                p_init_msg_list       => p_init_msg_list,
                                p_chr_id              => ln_chr_id,
                                p_asset_id            => p_iivv_rec.dnz_cle_id,
                                p_ser_num             => p_iivv_rec.serial_number,
                                p_event_name          => G_WF_EVT_ASSET_SERIAL_CRTD,
                                x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data
                               );
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         ELSIF(l_old_serial_num IS NOT NULL AND
	       (p_iivv_rec.serial_number IS NULL OR
	        p_iivv_rec.serial_number = OKL_API.G_MISS_CHAR)) THEN
           raise_business_event(p_api_version         => p_api_version,
                                p_init_msg_list       => p_init_msg_list,
                                p_chr_id              => ln_chr_id,
                                p_asset_id            => l_asset_id,
                                p_ser_num             => l_old_serial_num,
                                p_event_name          => G_WF_EVT_ASSET_SERIAL_RMVD,
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
       END IF;
       --vthiruva..09-Dec-2004..Added code to enable Business Events..END
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
   END update_txl_itm_insts;

   PROCEDURE update_txl_itm_insts(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_iivv_tbl                     IN iivv_tbl_type,
     x_iivv_tbl                     OUT NOCOPY iivv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_TXL_ITM_INSTS';
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
     OKL_ITI_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_iivv_tbl,
                            x_iivv_tbl);
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
   END update_txl_itm_insts;

   PROCEDURE delete_txl_itm_insts(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_iivv_rec                     IN iivv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_TXL_ITM_INSTS';
     ln_chr_id                    OKC_K_LINES_B.DNZ_CHR_ID%TYPE;
     -- Bug# 3477560
     CURSOR get_chr_id(p_kle_id OKL_TXL_ASSETS_B.KLE_ID%TYPE)
     IS
     SELECT cle.dnz_chr_id
     FROM okc_k_lines_b cle
     WHERE cle.id = p_kle_id;
    /*
     * sjalasut aug 18, 04: added cursor to derive the dnz_chr_id and dnz_cle_id
     * from the item instance to pass the parameters to the business event. BEGIN
     */
     CURSOR get_chr_cle_id(p_inst_id okl_txl_itm_insts.id%TYPE) IS
     SELECT lines.dnz_chr_id, items.dnz_cle_id, items.serial_number
       FROM okc_k_lines_b lines, okl_txl_itm_insts items
      WHERE items.id = p_inst_id
        AND lines.id = items.dnz_cle_id;

    l_chr_id  okc_k_headers_b.id%TYPE;
    l_cle_id  okc_k_lines_b.id%TYPE;
    l_ser_num okl_txl_itm_insts.serial_number%TYPE;

    /*
     * sjalasut aug 18, 04: added cursor to derive the dnz_chr_id and dnz_cle_id
     * from the item instance to pass the parameters to the business event. EMD
     */

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
     /*
      * sjalasut: oct 19, 04 added cursor to fetch the contract in context. BEGIN
      *
      */
     OPEN get_chr_cle_id(p_iivv_rec.id);
     FETCH get_chr_cle_id INTO l_chr_id,l_cle_id,l_ser_num;
     CLOSE get_chr_cle_id;
     /*
      * sjalasut: oct 19, 04 added cursor to fetch the contract in context. END
      *
      */
     -- evaluate conditions, build outcomes for true conditions and
     -- put them on outcome queue
     OKL_ITI_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_iivv_rec);
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     /*
      * sjalasut: oct 14, 04 added code to enable business event. BEGIN
      * raise business event only if the contract is a LEASE contract
      */
     IF(OKL_LLA_UTIL_PVT.is_lease_contract(l_chr_id)= OKL_API.G_TRUE)THEN
       raise_business_event(p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            p_chr_id              => l_chr_id,
                            p_asset_id            => l_cle_id,
                            p_ser_num             => l_ser_num,
                            p_event_name          => G_WF_EVT_ASSET_SERIAL_RMVD,
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
      * sjalasut: oct 14, 04 added code to enable business event. END
      */

     IF p_iivv_rec.tal_type in ('CFA','CIB','CRB','CRL','CRV','CSP','ALI') THEN
       OPEN get_chr_id(p_iivv_rec.kle_Id);
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
   END delete_txl_itm_insts;

   PROCEDURE delete_txl_itm_insts(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_iivv_tbl                     IN iivv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_TXL_ITM_INSTS';
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
     OKL_ITI_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_iivv_tbl);
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
   END delete_txl_itm_insts;

   PROCEDURE validate_txl_itm_insts(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_iivv_rec                     IN iivv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_TXL_ITM_INSTS';
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
     OKL_ITI_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_iivv_rec);
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
   END validate_txl_itm_insts;

   PROCEDURE validate_txl_itm_insts(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_iivv_tbl                     IN iivv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_TXL_ITM_INSTS';
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
     OKL_ITI_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_iivv_tbl);
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
   END validate_txl_itm_insts;

  -- Start of comments
  -- Procedure Name  : reset_item_srl_number
  --
  -- Description     : This API resets non-serialized item's
  --                   serial number to NULL.
  --
  -- Business Rules  : Blank out serial numbers from an asset
  --                   for which associated item is not serialized.
  --
  --                   In case p_asset_line_id is NULL, the program
  --                   will update serial number(s) to NULL for all
  --                   asset line(s) having non-serialized item.
  --                   Assets with Serialized items will be ignored.
  --
  --                   In case p_asset_line_id is NOT NULL and the item
  --                   associated to it is serialized, the program
  --                   will raise an error and will not update
  --                   serial number(s).
  --
  -- Parameters      : p_chr_id - Contract ID (Must be not null)
  --                            - Contract must not be BOOKED
  --                   p_asset_line_id - Asset Top Line ID
  --                                   - Either provide a valid line ID
  --                                     or NULL for all assets
  --
  -- Version         : 1.0, dedey
  -- End of comments

   PROCEDURE reset_item_srl_number(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_chr_id                       IN NUMBER,
     p_asset_line_id                IN NUMBER
   ) IS

   l_api_name          CONSTANT VARCHAR2(30) := 'RESET_ITEM_SRL_NUMBER';

   CURSOR chr_csr (p_chr_id IN NUMBER) IS
   SELECT 'Y'
   FROM   okc_k_headers_b chr,
          okc_statuses_b sts
   WHERE  chr.id       = p_chr_id
   AND    sts.code     = chr.sts_code
   AND    sts.ste_code IN ('SIGNED', 'ENTERED');

   CURSOR ff1_csr (p_chr_id IN NUMBER,
                   p_line_id IN NUMBER) IS
   SELECT line.id asset_id
   FROM   okc_k_lines_b line,
          okc_line_styles_b style,
          okc_statuses_b sts
   WHERE  line.lse_id     = style.id
   AND    style.lty_code  = 'FREE_FORM1'
   AND    line.dnz_chr_id = p_chr_id
   AND    line.id         = nvl(p_line_id,line.id)
   AND    sts.code        = line.sts_code
   AND    sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED','CANCELLED');

   CURSOR check_item_csr (p_line_id IN NUMBER) IS
   SELECT mtl.serial_number_control_code,
          mtl.description item_desc
   FROM   okc_k_lines_b line,
          okc_line_styles_b style,
          okc_k_items kitem,
          mtl_system_items mtl
   WHERE  line.lse_id                    = style.id
   AND    style.lty_code                 = 'ITEM'
   AND    line.id                        = kitem.cle_id
   AND    kitem.jtot_object1_code        = 'OKX_SYSITEM'
   AND    kitem.object1_id1              = mtl.inventory_item_id
   AND    kitem.object1_id2              = TO_CHAR(mtl.organization_id)
   AND    line.cle_id                    = p_line_id;

   CURSOR inst_csr (p_asset_id IN NUMBER) IS
   SELECT inst.id inst_id
   FROM   okc_k_lines_b ff2,
          okc_k_lines_b inst,
          okc_line_styles_b ff2style,
          okc_line_styles_b inststyle,
          okl_txl_itm_insts txl
   WHERE  ff2.lse_id         = ff2style.id
   AND    ff2style.lty_code  = 'FREE_FORM2'
   AND    ff2.id             = inst.cle_id
   AND    inst.lse_id        = inststyle.id
   AND    inststyle.lty_code = 'INST_ITEM'
   AND    txl.kle_id         = inst.id
   AND    ff2.cle_id         = p_asset_id;

   l_iivv_tbl okl_txl_itm_insts_pvt.iivv_tbl_type;
   x_iivv_tbl okl_txl_itm_insts_pvt.iivv_tbl_type;

   l_iti_rec  okl_iti_pvt.iti_rec_type;
   l_iivv_rec okl_txl_itm_insts_pvt.iivv_rec_type;
   x_iivv_rec okl_txl_itm_insts_pvt.iivv_rec_type;

   l_itiv_rec okl_iti_pvt.itiv_rec_type;

   x_no_data_found BOOLEAN;

   l_chr_valid     VARCHAR2(1);
   l_asset_line_id NUMBER;
   l_return_status VARCHAR2(1);
   l_serial_control mtl_system_items.serial_number_control_code%TYPE;
   l_item_desc     mtl_system_items.description%TYPE;


  FUNCTION get_rec (
    p_id                           IN  NUMBER,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_iti_pvt.itiv_rec_type IS
    CURSOR okl_itiv_pk_csr (p_id                 IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           TAS_ID,
           TAL_ID,
           KLE_ID,
           TAL_TYPE,
           LINE_NUMBER,
           INSTANCE_NUMBER_IB,
           OBJECT_ID1_NEW,
           OBJECT_ID2_NEW,
           JTOT_OBJECT_CODE_NEW,
           OBJECT_ID1_OLD,
           OBJECT_ID2_OLD,
           JTOT_OBJECT_CODE_OLD,
           INVENTORY_ORG_ID,
           SERIAL_NUMBER,
           MFG_SERIAL_NUMBER_YN,
           INVENTORY_ITEM_ID,
           INV_MASTER_ORG_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           DNZ_CLE_ID,
           instance_id,
           selected_for_split_flag,
           asd_id
    FROM OKL_TXL_ITM_INSTS_V iti
    WHERE iti.kle_id  = p_id;
    l_okl_itiv_pk                  okl_itiv_pk_csr%ROWTYPE;
    l_itiv_rec                     okl_iti_pvt.itiv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_itiv_pk_csr (p_id);
    FETCH okl_itiv_pk_csr INTO
              l_itiv_rec.ID,
              l_itiv_rec.OBJECT_VERSION_NUMBER,
              l_itiv_rec.TAS_ID,
              l_itiv_rec.TAL_ID,
              l_itiv_rec.KLE_ID,
              l_itiv_rec.TAL_TYPE,
              l_itiv_rec.LINE_NUMBER,
              l_itiv_rec.INSTANCE_NUMBER_IB,
              l_itiv_rec.OBJECT_ID1_NEW,
              l_itiv_rec.OBJECT_ID2_NEW,
              l_itiv_rec.JTOT_OBJECT_CODE_NEW,
              l_itiv_rec.OBJECT_ID1_OLD,
              l_itiv_rec.OBJECT_ID2_OLD,
              l_itiv_rec.JTOT_OBJECT_CODE_OLD,
              l_itiv_rec.INVENTORY_ORG_ID,
              l_itiv_rec.SERIAL_NUMBER,
              l_itiv_rec.MFG_SERIAL_NUMBER_YN,
              l_itiv_rec.INVENTORY_ITEM_ID,
              l_itiv_rec.INV_MASTER_ORG_ID,
              l_itiv_rec.ATTRIBUTE_CATEGORY,
              l_itiv_rec.ATTRIBUTE1,
              l_itiv_rec.ATTRIBUTE2,
              l_itiv_rec.ATTRIBUTE3,
              l_itiv_rec.ATTRIBUTE4,
              l_itiv_rec.ATTRIBUTE5,
              l_itiv_rec.ATTRIBUTE6,
              l_itiv_rec.ATTRIBUTE7,
              l_itiv_rec.ATTRIBUTE8,
              l_itiv_rec.ATTRIBUTE9,
              l_itiv_rec.ATTRIBUTE10,
              l_itiv_rec.ATTRIBUTE11,
              l_itiv_rec.ATTRIBUTE12,
              l_itiv_rec.ATTRIBUTE13,
              l_itiv_rec.ATTRIBUTE14,
              l_itiv_rec.ATTRIBUTE15,
              l_itiv_rec.CREATED_BY,
              l_itiv_rec.CREATION_DATE,
              l_itiv_rec.LAST_UPDATED_BY,
              l_itiv_rec.LAST_UPDATE_DATE,
              l_itiv_rec.LAST_UPDATE_LOGIN,
              l_itiv_rec.DNZ_CLE_ID,
              l_itiv_rec.instance_id,
              l_itiv_rec.selected_for_split_flag,
              l_itiv_rec.asd_id;
    x_no_data_found := okl_itiv_pk_csr%NOTFOUND;
    CLOSE okl_itiv_pk_csr;
    RETURN(l_itiv_rec);
  END get_rec;

   BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

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

     l_chr_valid := 'N';
     OPEN chr_csr(p_chr_id);
     FETCH chr_csr INTO l_chr_valid;
     CLOSE chr_csr;

     IF (l_chr_valid <> 'Y') THEN
        OKL_API.set_message(
                            p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_INVALID_VALUE',
                            p_token1       => 'COL_NAME',
                            p_token1_value => 'p_chr_id'
                           );

        --dbms_output.put_line('No data found: CHR_ID');
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     IF (p_asset_line_id IS NOT NULL) THEN -- check for FREE_FORM1 line

        OPEN ff1_csr (p_chr_id,
                      p_asset_line_id);
        FETCH ff1_csr INTO l_asset_line_id;
        IF ff1_csr%NOTFOUND THEN
           OKL_API.set_message(
                               p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_INVALID_VALUE',
                               p_token1       => 'COL_NAME',
                               p_token1_value => 'p_asset_line_id'
                              );
           --dbms_output.put_line('No data found: LINE_ID');
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE ff1_csr;
     END IF;

     FOR ff1_rec IN ff1_csr (p_chr_id,
                             p_asset_line_id)
     LOOP

        -- Check for item type
        -- report error is asset line id is passed
        -- otherwise skip the asset line with serialized item
        -- note: ff1_rec.asset_id will be same as p_asset_line_id
        --       when user specified p_asset_line_id

        OPEN check_item_csr (ff1_rec.asset_id);
        FETCH check_item_csr INTO l_serial_control,
                                  l_item_desc;
        CLOSE check_item_csr;

        IF (l_serial_control <> 1) THEN  -- seriallized
           IF (p_asset_line_id IS NOT NULL) THEN
               --dbms_output.put_line('Item: '||l_item_desc);
               OKL_API.set_message(
                                   p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_LLA_SRL_CNTRL',
                                   p_token1       => 'ITEM_DESC',
                                   p_token1_value => l_item_desc
                                  );
               RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
        ELSE -- reset serial number
           FOR inst_rec IN inst_csr(ff1_rec.asset_id)
           LOOP

              --dbms_output.put_line('ID before get_rec: '||inst_rec.inst_id);
              l_itiv_rec := get_rec(inst_rec.inst_id,
                                    x_no_data_found);

              IF (x_no_data_found) THEN

                 --dbms_output.put_line('No Data Found');
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              END IF;

              l_iivv_rec := l_itiv_rec;
              l_iivv_rec.serial_number := NULL; -- reset serial number to NULL

              --dbms_output.put_line('ID: '||l_iivv_rec.id);
              --dbms_output.put_line('SRL No: '||l_iivv_rec.serial_number);

              okl_txl_itm_insts_pvt.update_txl_itm_insts(
                       p_api_version                  => 1.0,
                       p_init_msg_list                => p_init_msg_list,
                       x_return_status                => x_return_status,
                       x_msg_count                    => x_msg_count,
                       x_msg_data                     => x_msg_data,
                       p_iivv_rec                     => l_iivv_rec,
                       x_iivv_rec                     => x_iivv_rec
                      );
              --dbms_output.put_line('After Update call...'||x_return_status);
              --dbms_output.put_line('Error: '||x_msg_data);

              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;

           END LOOP; --inst_csr

        END IF; -- l_non_srl

     END LOOP; --ff1_csr

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
   END reset_item_srl_number;

END OKL_TXL_ITM_INSTS_PVT;

/
