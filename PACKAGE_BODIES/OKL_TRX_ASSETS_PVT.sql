--------------------------------------------------------
--  DDL for Package Body OKL_TRX_ASSETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRX_ASSETS_PVT" as
/* $Header: OKLCTASB.pls 115.4 2002/02/05 11:50:20 pkm ship       $ */

   PROCEDURE Create_trx_ass_h_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tasv_rec                     IN tavv_rec_type,
     x_tasv_rec                     OUT NOCOPY tavv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_TRX_ASSET_HEADER';
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
     OKL_TAS_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tasv_rec,
                            x_tasv_rec);
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
   END Create_trx_ass_h_def;

    PROCEDURE Create_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tavv_tbl_type,
    x_tasv_tbl                     OUT NOCOPY tavv_tbl_type)
    IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_TRX_ASSET_HEADER';
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
    OKL_TAS_PVT.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_tasv_tbl,
                           x_tasv_tbl);

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
    END Create_trx_ass_h_def;

   PROCEDURE lock_trx_ass_h_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tasv_rec                     IN tavv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_TRX_ASSEST_HEADER_DEfINITION';
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
     OKL_TAS_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tasv_rec);
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
   END lock_trx_ass_h_def;

   PROCEDURE lock_trx_ass_h_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tasv_tbl                     IN tavv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_TRX_ASSET_HEADER';
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
     OKL_TAS_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tasv_tbl);
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
   END lock_trx_ass_h_def;

   PROCEDURE update_trx_ass_h_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tasv_rec                     IN tavv_rec_type,
     x_tasv_rec                     OUT NOCOPY tavv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_TRX_ASSET_HEADER';
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
     OKL_TAS_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tasv_rec,
                            x_tasv_rec);
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
   END update_trx_ass_h_def;

   PROCEDURE update_trx_ass_h_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tasv_tbl                     IN tavv_tbl_type,
     x_tasv_tbl                     OUT NOCOPY tavv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_TRX_ASSET_HEADER';
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
     OKL_TAS_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tasv_tbl,
                            x_tasv_tbl);
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
   END update_trx_ass_h_def;

   PROCEDURE delete_trx_ass_h_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tasv_rec                     IN tavv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_TRX_ASSET_HEADER';
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
     OKL_TAS_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tasv_rec);
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
   END delete_trx_ass_h_def;

   PROCEDURE delete_trx_ass_h_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tasv_tbl                     IN tavv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_TRX_ASSET_HEADER';
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
     OKL_TAS_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tasv_tbl);
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
   END delete_trx_ass_h_def;

   PROCEDURE validate_trx_ass_h_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tasv_rec                     IN tavv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_TRX_ASSET_HEADER';
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
     OKL_TAS_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tasv_rec);
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
   END validate_trx_ass_h_def;

   PROCEDURE validate_trx_ass_h_def(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tasv_tbl                     IN tavv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_TRX_ASSET_HEADER';
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
     OKL_TAS_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tasv_tbl);
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
   END validate_trx_ass_h_def;

END OKL_TRX_ASSETS_PVT;

/
