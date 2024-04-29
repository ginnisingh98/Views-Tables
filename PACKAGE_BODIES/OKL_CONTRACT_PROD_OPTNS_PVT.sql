--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_PROD_OPTNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_PROD_OPTNS_PVT" as
/* $Header: OKLCCSPB.pls 115.3 2002/02/25 10:12:08 pkm ship        $ */
------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_contract_option
-- Description     : creates selected product option value for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type,
    x_cspv_rec                     OUT NOCOPY cspv_rec_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_OPTION';
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
    okl_csp_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cspv_rec,
	    x_cspv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  END create_contract_option;
------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_contract_option
-- Description     : creates selected product option value for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type,
    x_cspv_tbl                     OUT NOCOPY cspv_tbl_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_OPTION';
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
    okl_csp_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cspv_tbl,
	    x_cspv_tbl);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  END create_contract_option;
------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_contract_option
-- Description     : updates selected product option value for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type,
    x_cspv_rec                     OUT NOCOPY cspv_rec_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_OPTION';
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
    okl_csp_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cspv_rec,
	    x_cspv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  END update_contract_option;
--------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_contract_option
-- Description     : updates selected product option value for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type,
    x_cspv_tbl                     OUT NOCOPY cspv_tbl_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_OPTION';
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
    okl_csp_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cspv_tbl,
	    x_cspv_tbl);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  END update_contract_option;
----------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_contract_option
-- Description     : deletes selected product option value for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_OPTION';
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
    okl_csp_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cspv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  END delete_contract_option;
-----------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_contract_option
-- Description     : deletes selected product option value for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_OPTION';
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
    okl_csp_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_cspv_tbl);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  END delete_contract_option;
------------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : lock_contract_option
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure lock_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_OPTION';
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
    okl_csp_pvt.lock_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cspv_rec      => p_cspv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  end lock_contract_option;
------------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : lock_contract_option
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure lock_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_OPTION';
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
    okl_csp_pvt.lock_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cspv_tbl      => p_cspv_tbl);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  end lock_contract_option;
---------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_contract_option
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure validate_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_OPTION';
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
    okl_csp_pvt.validate_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cspv_rec      => p_cspv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  end validate_contract_option;
------------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_contract_option
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure validate_contract_option(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_OPTION';
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
    okl_csp_pvt.validate_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_cspv_tbl      => p_cspv_tbl);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
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
      WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                                (l_api_name,
                                G_PKG_NAME,
				'OTHERS',
				x_msg_count,
				x_msg_data,
				'_PVT');
  end validate_contract_option;

END OKL_CONTRACT_PROD_OPTNS_PVT;

/
