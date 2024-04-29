--------------------------------------------------------
--  DDL for Package Body OKL_SYSTEM_PARAMS_ALL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SYSTEM_PARAMS_ALL_PUB" AS
/* $Header: OKLPSYPB.pls 120.2 2006/07/31 06:20:00 akrangan noship $ */
  -- Start of comments
  --
  -- Procedure Name  : insert_system_parameters
  -- Description     : procedure to insert into OKL_SYSTEM_PARAMS_ALL_V - REC
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE insert_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT insert_row_trx;
     OKL_SYP_PVT.insert_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_rec       => p_sypv_rec,
                    x_sypv_rec       => x_sypv_rec);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO insert_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO insert_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','insert_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END insert_system_parameters;
  -- Start of comments
  --
  -- Procedure Name  : insert_system_parameters
  -- Description     : procedure to insert into OKL_SYSTEM_PARAMS_ALL_V - TBL
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE insert_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT insert_row_trx;
     OKL_SYP_PVT.insert_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_tbl       => p_sypv_tbl,
                    x_sypv_tbl       => x_sypv_tbl);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO insert_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO insert_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','insert_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END insert_system_parameters;
  -- Start of comments
  --
  -- Procedure Name  : lock_system_parameters
  -- Description     : procedure to lock OKL_SYSTEM_PARAMS_ALL_V - REC
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE lock_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT lock_row_trx;
     OKL_SYP_PVT.lock_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_rec       => p_sypv_rec);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO lock_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO lock_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','lock_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END lock_system_parameters;
  -- Start of comments
  --
  -- Procedure Name  : lock_system_parameters
  -- Description     : procedure to lock OKL_SYSTEM_PARAMS_ALL_V - TBL
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE lock_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT lock_row_trx;
     OKL_SYP_PVT.lock_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_tbl       => p_sypv_tbl);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO lock_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO lock_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','lock_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END lock_system_parameters;
  -- Start of comments
  --
  -- Procedure Name  : update_system_parameters
  -- Description     : procedure to update OKL_SYSTEM_PARAMS_ALL_V - REC
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE update_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT update_row_trx;
     OKL_SYP_PVT.update_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_rec       => p_sypv_rec,
                    x_sypv_rec       => x_sypv_rec);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO update_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO update_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','update_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END update_system_parameters;
  -- Start of comments
  --
  -- Procedure Name  : update_system_parameters
  -- Description     : procedure to update OKL_SYSTEM_PARAMS_ALL_V - TBL
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE update_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT update_row_trx;
     OKL_SYP_PVT.update_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_tbl       => p_sypv_tbl,
                    x_sypv_tbl       => x_sypv_tbl);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO update_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO update_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','update_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END update_system_parameters;
  -- Start of comments
  --
  -- Procedure Name  : delete_system_parameters
  -- Description     : procedure to delete from OKL_SYSTEM_PARAMS_ALL_V - REC
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE delete_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT delete_row_trx;
     OKL_SYP_PVT.delete_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_rec       => p_sypv_rec);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO delete_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO delete_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','delete_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END delete_system_parameters;
  -- Start of comments
  --
  -- Procedure Name  : delete_system_parameters
  -- Description     : procedure to delete from OKL_SYSTEM_PARAMS_ALL_V - TBL
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE delete_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT delete_row_trx;
     OKL_SYP_PVT.delete_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_tbl       => p_sypv_tbl);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO delete_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO delete_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','delete_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END delete_system_parameters;
  -- Start of comments
  --
  -- Procedure Name  : validate_system_parameters
  -- Description     : procedure to validate OKL_SYSTEM_PARAMS_ALL_V - REC
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE validate_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT validate_row_trx;
     OKL_SYP_PVT.validate_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_rec       => p_sypv_rec);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO validate_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO validate_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','validate_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END validate_system_parameters;
  -- Start of comments
  --
  -- Procedure Name  : validate_system_parameters
  -- Description     : procedure to validate OKL_SYSTEM_PARAMS_ALL_V - TBL
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE validate_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type) IS
    l_return_status VARCHAR2(3) := G_RET_STS_SUCCESS;
  BEGIN
     SAVEPOINT validate_row_trx;
     OKL_SYP_PVT.validate_row(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_tbl       => p_sypv_tbl);
     -- raise exception if api returns error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
     END IF;
     x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO validate_row_trx;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
     WHEN OTHERS THEN
      ROLLBACK TO validate_row_trx;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_PARAMS_ALL_PUB','validate_system_parameters');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END validate_system_parameters;
   -- Start of comments
  --
  -- Procedure Name  : get_system_param_value
  -- Description     : function to get  OKL_SYSTEM_PARAMS_ALL - TBL
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : AKRANGAN Created
  --
  -- End of comments
  FUNCTION get_system_param_value(
  p_param_name IN VARCHAR2,
  p_org_id IN NUMBER DEFAULT NULL
  )
  RETURN VARCHAR2
  IS
  x_ret_value    VARCHAR2(50);
  l_org_id       NUMBER := nvl(p_org_id , mo_global.get_current_org_id );
  CURSOR C IS SELECT item_inv_org_id      ,
  		             rpt_prod_book_type_code	,
  		             asst_add_book_type_code	,
  		             ccard_remittance_id
             FROM okl_system_params_all
  	         WHERE org_id = l_org_id ;
  BEGIN
  FOR I IN C
  LOOP
    IF p_param_name = g_item_inv_org_id THEN
           x_ret_value := i.item_inv_org_id;
    ELSIF  p_param_name = g_rpt_prod_book_type_code THEN
           x_ret_value := i.rpt_prod_book_type_code;
    ELSIF  p_param_name = g_asst_add_book_type_code THEN
           x_ret_value := i.asst_add_book_type_code;
    ELSIF p_param_name = g_ccard_remittance_id THEN
           x_ret_value := i.ccard_remittance_id;
    END IF ;
  END LOOP;
  --returns the reqd the system value here
  RETURN x_ret_value;
  END  get_system_param_value;
END OKL_SYSTEM_PARAMS_ALL_PUB;

/
