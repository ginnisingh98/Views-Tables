--------------------------------------------------------
--  DDL for Package Body OKL_VERSION_IB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VERSION_IB_PVT" as
/* $Header: OKLCVIBB.pls 115.0 2002/02/05 15:12:47 pkm ship        $ */

   PROCEDURE Create_version_ib(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vibv_rec                     IN vibv_rec_type,
     x_vibv_rec                     OUT NOCOPY vibv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_VERSION_IB';
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
     OKL_VIB_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vibv_rec,
                            x_vibv_rec);
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
   END Create_version_ib;

    PROCEDURE Create_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type,
    x_vibv_tbl                     OUT NOCOPY vibv_tbl_type)
    IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_VERSION_IB';
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
    OKL_VIB_PVT.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_vibv_tbl,
                           x_vibv_tbl);

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
    END Create_version_ib;

   PROCEDURE lock_version_ib(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vibv_rec                     IN vibv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_VERSION_IB';
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
     OKL_VIB_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vibv_rec);
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
   END lock_version_ib;

   PROCEDURE lock_version_ib(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vibv_tbl                     IN vibv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_VERSION_IB';
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
     OKL_VIB_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vibv_tbl);
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
   END lock_version_ib;

   PROCEDURE update_version_ib(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vibv_rec                     IN vibv_rec_type,
     x_vibv_rec                     OUT NOCOPY vibv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_VERSION_IB';
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
     OKL_VIB_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vibv_rec,
                            x_vibv_rec);
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
   END update_version_ib;

   PROCEDURE update_version_ib(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vibv_tbl                     IN vibv_tbl_type,
     x_vibv_tbl                     OUT NOCOPY vibv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_VERSION_IB';
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
     OKL_VIB_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vibv_tbl,
                            x_vibv_tbl);
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
   END update_version_ib;

   PROCEDURE delete_version_ib(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vibv_rec                     IN vibv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_VERSION_IB';
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
     OKL_VIB_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vibv_rec);
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
   END delete_version_ib;

   PROCEDURE delete_version_ib(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vibv_tbl                     IN vibv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_VERSION_IB';
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
     OKL_VIB_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vibv_tbl);
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
   END delete_version_ib;

   PROCEDURE validate_version_ib(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vibv_rec                     IN vibv_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_VERSION_IB';
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
     OKL_VIB_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vibv_rec);
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
   END validate_version_ib;

   PROCEDURE validate_version_ib(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vibv_tbl                     IN vibv_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_VERSION_IB';
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
     OKL_VIB_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vibv_tbl);
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
   END validate_version_ib;

END OKL_VERSION_IB_PVT;

/
