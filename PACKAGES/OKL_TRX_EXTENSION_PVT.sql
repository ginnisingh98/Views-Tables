--------------------------------------------------------
--  DDL for Package OKL_TRX_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRX_EXTENSION_PVT" AUTHID CURRENT_USER AS
/*$Header: OKLCTEHS.pls 120.2 2007/08/06 13:50:49 prasjain noship $*/

  SUBTYPE tehv_rec_type IS okl_teh_pvt.tehv_rec_type;
  SUBTYPE tehv_tbl_type IS okl_teh_pvt.tehv_tbl_type;

  SUBTYPE telv_rec_type IS okl_tel_pvt.telv_rec_type;
  SUBTYPE telv_tbl_type IS okl_tel_pvt.telv_tbl_type;
  -- Start : PRASJAIN : Bug# 6268782
  SUBTYPE teh_rec_type  IS okl_teh_pvt.teh_rec_type;
  SUBTYPE tehl_tbl_type IS okl_teh_pvt.tehl_tbl_type;

  SUBTYPE tel_rec_type  IS okl_tel_pvt.tel_rec_type;
  SUBTYPE tell_tbl_type IS okl_tel_pvt.tell_tbl_type;

  SUBTYPE tel_tbl_tbl_type IS okl_tel_pvt.tel_tbl_tbl_type;
  -- End : PRASJAIN : Bug# 6268782
  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_TRX_EXTENSION_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ------------------------------------------------------------------------------

--Object type procedure for insert
  PROCEDURE create_trx_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tehv_rec                     IN  tehv_rec_type
    ,p_telv_tbl                     IN  telv_tbl_type
    ,x_tehv_rec                     OUT NOCOPY tehv_rec_type
    ,x_telv_tbl                     OUT NOCOPY telv_tbl_type
     );

--Object type procedure for update
  PROCEDURE update_trx_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tehv_rec                     IN  tehv_rec_type
    ,p_telv_tbl                     IN  telv_tbl_type
    ,x_tehv_rec                     OUT NOCOPY tehv_rec_type
    ,x_telv_tbl                     OUT NOCOPY telv_tbl_type
     );

--Object type procedure for validate
  PROCEDURE validate_trx_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tehv_rec                     IN  tehv_rec_type
    ,p_telv_tbl                     IN  telv_tbl_type
     );


--Object type procedure for create
  PROCEDURE create_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_tbl                     IN  tehv_tbl_type,
     x_tehv_tbl                     OUT NOCOPY tehv_tbl_type);

--Object type procedure for create
  PROCEDURE create_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_rec                     IN  tehv_rec_type,
     x_tehv_rec                     OUT NOCOPY tehv_rec_type);

--Object type procedure for lock
  PROCEDURE lock_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_tbl                     IN  tehv_tbl_type);

--Object type procedure for lock
  PROCEDURE lock_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_rec                     IN  tehv_rec_type);

--Object type procedure for update
  PROCEDURE update_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_tbl                     IN  tehv_tbl_type,
     x_tehv_tbl                     OUT NOCOPY tehv_tbl_type);

--Object type procedure for update
  PROCEDURE update_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_rec                     IN  tehv_rec_type,
     x_tehv_rec                     OUT NOCOPY tehv_rec_type);

--Object type procedure for delete
  PROCEDURE delete_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_tbl                     IN  tehv_tbl_type);

--Object type procedure for delete
  PROCEDURE delete_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_rec                     IN tehv_rec_type);

--Object type procedure for validate
   PROCEDURE validate_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_tbl                     IN  tehv_tbl_type);

--Object type procedure for validate
  PROCEDURE validate_trx_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tehv_rec                     IN  tehv_rec_type);

--Object type procedure for create
  PROCEDURE create_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_tbl                     IN  telv_tbl_type,
     x_telv_tbl                     OUT NOCOPY telv_tbl_type);

--Object type procedure for create
  PROCEDURE create_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_rec                     IN  telv_rec_type,
     x_telv_rec                     OUT NOCOPY telv_rec_type);

--Object type procedure for lock
  PROCEDURE lock_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_tbl                     IN  telv_tbl_type);

--Object type procedure for lock
  PROCEDURE lock_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_rec                     IN  telv_rec_type);

 --Object type procedure for update
  PROCEDURE update_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_tbl                     IN  telv_tbl_type,
     x_telv_tbl                     OUT NOCOPY telv_tbl_type);

--Object type procedure for update
  PROCEDURE update_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_rec                     IN  telv_rec_type,
     x_telv_rec                     OUT NOCOPY telv_rec_type);

--Object type procedure for delete
  PROCEDURE delete_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_tbl                     IN  telv_tbl_type);

--Object type procedure for delete
  PROCEDURE delete_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_rec                     IN  telv_rec_type);

--Object type procedure for validate
   PROCEDURE validate_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_tbl                     IN  telv_tbl_type);

--Object type procedure for validate
  PROCEDURE validate_txl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_telv_rec                     IN  telv_rec_type);

--Object type procedure for validate
--Added : PRASJAIN : Bug# 6268782
  PROCEDURE create_trx_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_teh_rec                 IN  teh_rec_type
    ,p_tehl_tbl                IN  tehl_tbl_type
    ,x_teh_rec                 OUT NOCOPY teh_rec_type
    ,x_tehl_tbl                OUT NOCOPY tehl_tbl_type);

--Object type procedure for validate
--Added : PRASJAIN : Bug# 6268782
  PROCEDURE create_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tel_rec                        IN  tel_rec_type
    ,p_tell_tbl                       IN  tell_tbl_type
    ,x_tel_rec                        OUT NOCOPY tel_rec_type
    ,x_tell_tbl                       OUT NOCOPY tell_tbl_type);

--Object type procedure for validate
--Added : PRASJAIN : Bug# 6268782
  PROCEDURE create_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tel_tbl_tbl                    IN  tel_tbl_tbl_type
    ,x_tel_tbl_tbl                    OUT NOCOPY tel_tbl_tbl_type);
END OKL_TRX_EXTENSION_PVT;

/
