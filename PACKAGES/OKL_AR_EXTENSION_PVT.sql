--------------------------------------------------------
--  DDL for Package OKL_AR_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AR_EXTENSION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCRXHS.pls 120.1 2007/08/06 13:49:55 prasjain noship $ */

  SUBTYPE rxhv_rec_type IS okl_rxh_pvt.rxhv_rec_type;
  SUBTYPE rxhv_tbl_type IS okl_rxh_pvt.rxhv_tbl_type;

  SUBTYPE rxlv_rec_type IS okl_rxl_pvt.rxlv_rec_type;
  SUBTYPE rxlv_tbl_type IS okl_rxl_pvt.rxlv_tbl_type;
  -- Start : PRASJAIN : Bug# 6268782
  SUBTYPE rxh_rec_type  IS okl_rxh_pvt.rxh_rec_type;
  SUBTYPE rxhl_tbl_type IS okl_rxh_pvt.rxhl_tbl_type;

  SUBTYPE rxl_rec_type  IS okl_rxl_pvt.rxl_rec_type;
  SUBTYPE rxll_tbl_type IS okl_rxl_pvt.rxll_tbl_type;
  -- End : PRASJAIN : Bug# 6268782
  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AR_EXTENSION_PVT';
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
  PROCEDURE create_rxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_rxhv_rec                     IN  rxhv_rec_type
    ,p_rxlv_tbl                     IN  rxlv_tbl_type
    ,x_rxhv_rec                     OUT NOCOPY rxhv_rec_type
    ,x_rxlv_tbl                     OUT NOCOPY rxlv_tbl_type
     );

--Object type procedure for update
  PROCEDURE update_rxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_rxhv_rec                     IN  rxhv_rec_type
    ,p_rxlv_tbl                     IN  rxlv_tbl_type
    ,x_rxhv_rec                     OUT NOCOPY rxhv_rec_type
    ,x_rxlv_tbl                     OUT NOCOPY rxlv_tbl_type
     );

--Object type procedure for validate
  PROCEDURE validate_rxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_rxhv_rec                     IN  rxhv_rec_type
    ,p_rxlv_tbl                     IN  rxlv_tbl_type
     );


--Object type procedure for create
  PROCEDURE create_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_tbl                     IN  rxhv_tbl_type,
     x_rxhv_tbl                     OUT NOCOPY rxhv_tbl_type);

--Object type procedure for create
  PROCEDURE create_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_rec                     IN  rxhv_rec_type,
     x_rxhv_rec                     OUT NOCOPY rxhv_rec_type);

--Object type procedure for lock
  PROCEDURE lock_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_tbl                     IN  rxhv_tbl_type);

--Object type procedure for lock
  PROCEDURE lock_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_rec                     IN  rxhv_rec_type);

--Object type procedure for update
  PROCEDURE update_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_tbl                     IN  rxhv_tbl_type,
     x_rxhv_tbl                     OUT NOCOPY rxhv_tbl_type);

--Object type procedure for update
  PROCEDURE update_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_rec                     IN  rxhv_rec_type,
     x_rxhv_rec                     OUT NOCOPY rxhv_rec_type);

--Object type procedure for delete
  PROCEDURE delete_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_tbl                     IN  rxhv_tbl_type);

--Object type procedure for delete
  PROCEDURE delete_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_rec                     IN rxhv_rec_type);

--Object type procedure for validate
   PROCEDURE validate_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_tbl                     IN  rxhv_tbl_type);

--Object type procedure for validate
  PROCEDURE validate_rxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxhv_rec                     IN  rxhv_rec_type);

--Object type procedure for create
  PROCEDURE create_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_tbl                     IN  rxlv_tbl_type,
     x_rxlv_tbl                     OUT NOCOPY rxlv_tbl_type);

--Object type procedure for create
  PROCEDURE create_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_rec                     IN  rxlv_rec_type,
     x_rxlv_rec                     OUT NOCOPY rxlv_rec_type);

--Object type procedure for lock
  PROCEDURE lock_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_tbl                     IN  rxlv_tbl_type);

--Object type procedure for lock
  PROCEDURE lock_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_rec                     IN  rxlv_rec_type);

 --Object type procedure for update
  PROCEDURE update_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_tbl                     IN  rxlv_tbl_type,
     x_rxlv_tbl                     OUT NOCOPY rxlv_tbl_type);

--Object type procedure for update
  PROCEDURE update_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_rec                     IN  rxlv_rec_type,
     x_rxlv_rec                     OUT NOCOPY rxlv_rec_type);

--Object type procedure for delete
  PROCEDURE delete_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_tbl                     IN  rxlv_tbl_type);

--Object type procedure for delete
  PROCEDURE delete_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_rec                     IN  rxlv_rec_type);

--Object type procedure for validate
   PROCEDURE validate_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_tbl                     IN  rxlv_tbl_type);

--Object type procedure for validate
  PROCEDURE validate_rxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_rxlv_rec                     IN  rxlv_rec_type);

--Object type procedure for insert
--Added for Bug# 6268782 : PRASJAIN
  PROCEDURE create_rxh_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_rxh_rec                 IN  rxh_rec_type
    ,p_rxhl_tbl                IN  rxhl_tbl_type
    ,x_rxh_rec                 OUT NOCOPY rxh_rec_type
    ,x_rxhl_tbl                OUT NOCOPY rxhl_tbl_type);

--Object type procedure for insert
--Added for Bug# 6268782 : PRASJAIN
  PROCEDURE create_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxl_rec                        IN  rxl_rec_type
    ,p_rxll_tbl                       IN  rxll_tbl_type
    ,x_rxl_rec                        OUT NOCOPY rxl_rec_type
    ,x_rxll_tbl                       OUT NOCOPY rxll_tbl_type);
END OKL_AR_EXTENSION_PVT;

/
