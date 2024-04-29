--------------------------------------------------------
--  DDL for Package Body OKL_VERSION_FA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VERSION_FA_PVT" as
/* $Header: OKLCVFAB.pls 115.0 2002/02/05 15:12:30 pkm ship        $ */

   PROCEDURE Create_version_fa(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vfav_rec                     IN vfav_rec_type,
     x_vfav_rec                     OUT NOCOPY vfav_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_VERSION_FA';
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
     OKL_VFA_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vfav_rec,
                            x_vfav_rec);
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
   END Create_version_fa;

    PROCEDURE Create_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type,
    x_vfav_tbl                     OUT NOCOPY vfav_tbl_type)
    IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_VERSION_FA';
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
    OKL_VFA_PVT.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_vfav_tbl,
                           x_vfav_tbl);

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
    END Create_version_fa;

   PROCEDURE lock_version_fa(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vfav_rec                     IN vfav_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_VERSION_FA';
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
     OKL_VFA_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vfav_rec);
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
   END lock_version_fa;

   PROCEDURE lock_version_fa(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vfav_tbl                     IN vfav_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_VERSION_FA';
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
     OKL_VFA_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vfav_tbl);
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
   END lock_version_fa;

   PROCEDURE update_version_fa(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vfav_rec                     IN vfav_rec_type,
     x_vfav_rec                     OUT NOCOPY vfav_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_VERSION_FA';
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
     OKL_VFA_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vfav_rec,
                            x_vfav_rec);
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
   END update_version_fa;

   PROCEDURE update_version_fa(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vfav_tbl                     IN vfav_tbl_type,
     x_vfav_tbl                     OUT NOCOPY vfav_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_VERSION_FA';
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
     OKL_VFA_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vfav_tbl,
                            x_vfav_tbl);
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
   END update_version_fa;

   PROCEDURE delete_version_fa(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vfav_rec                     IN vfav_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_VERSION_FA';
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
     OKL_VFA_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vfav_rec);
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
   END delete_version_fa;

   PROCEDURE delete_version_fa(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vfav_tbl                     IN vfav_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_VERSION_FA';
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
     OKL_VFA_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vfav_tbl);
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
   END delete_version_fa;

   PROCEDURE validate_version_fa(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vfav_rec                     IN vfav_rec_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_VERSION_FA';
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
     OKL_VFA_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vfav_rec);
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
   END validate_version_fa;

   PROCEDURE validate_version_fa(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vfav_tbl                     IN vfav_tbl_type)
     IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_VERSION_FA';
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
     OKL_VFA_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vfav_tbl);
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
   END validate_version_fa;

END OKL_VERSION_FA_PVT;

/
