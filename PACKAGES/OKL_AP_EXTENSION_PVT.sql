--------------------------------------------------------
--  DDL for Package OKL_AP_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AP_EXTENSION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCPXHS.pls 120.1 2007/08/06 13:48:56 prasjain noship $ */
  SUBTYPE pxhv_rec_type IS okl_pxh_pvt.pxhv_rec_type;
  SUBTYPE pxhv_tbl_type IS okl_pxh_pvt.pxhv_tbl_type;

  SUBTYPE pxlv_rec_type IS okl_pxl_pvt.pxlv_rec_type;
  SUBTYPE pxlv_tbl_type IS okl_pxl_pvt.pxlv_tbl_type;
  -- Start : PRASJAIN : Bug# 6268782
  SUBTYPE pxh_rec_type  IS okl_pxh_pvt.pxh_rec_type;
  SUBTYPE pxhl_tbl_type IS okl_pxh_pvt.pxhl_tbl_type;

  SUBTYPE pxl_rec_type  IS okl_pxl_pvt.pxl_rec_type;
  SUBTYPE pxll_tbl_type IS okl_pxl_pvt.pxll_tbl_type;
  -- End : PRASJAIN : Bug# 6268782
  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AP_EXTENSION_PVT';
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
  PROCEDURE create_pxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_pxhv_rec                     IN  pxhv_rec_type
    ,p_pxlv_tbl                     IN  pxlv_tbl_type
    ,x_pxhv_rec                     OUT NOCOPY pxhv_rec_type
    ,x_pxlv_tbl                     OUT NOCOPY pxlv_tbl_type
     );

--Object type procedure for update
  PROCEDURE update_pxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_pxhv_rec                     IN  pxhv_rec_type
    ,p_pxlv_tbl                     IN  pxlv_tbl_type
    ,x_pxhv_rec                     OUT NOCOPY pxhv_rec_type
    ,x_pxlv_tbl                     OUT NOCOPY pxlv_tbl_type
     );

--Object type procedure for validate
  PROCEDURE validate_pxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_pxhv_rec                     IN  pxhv_rec_type
    ,p_pxlv_tbl                     IN  pxlv_tbl_type
     );


--Object type procedure for create
  PROCEDURE create_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_tbl                     IN  pxhv_tbl_type,
     x_pxhv_tbl                     OUT NOCOPY pxhv_tbl_type);

--Object type procedure for create
  PROCEDURE create_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_rec                     IN  pxhv_rec_type,
     x_pxhv_rec                     OUT NOCOPY pxhv_rec_type);

--Object type procedure for lock
  PROCEDURE lock_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_tbl                     IN  pxhv_tbl_type);

--Object type procedure for lock
  PROCEDURE lock_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_rec                     IN  pxhv_rec_type);

--Object type procedure for update
  PROCEDURE update_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_tbl                     IN  pxhv_tbl_type,
     x_pxhv_tbl                     OUT NOCOPY pxhv_tbl_type);

--Object type procedure for update
  PROCEDURE update_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_rec                     IN  pxhv_rec_type,
     x_pxhv_rec                     OUT NOCOPY pxhv_rec_type);

--Object type procedure for delete
  PROCEDURE delete_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_tbl                     IN  pxhv_tbl_type);

--Object type procedure for delete
  PROCEDURE delete_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_rec                     IN pxhv_rec_type);

--Object type procedure for validate
   PROCEDURE validate_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_tbl                     IN  pxhv_tbl_type);

--Object type procedure for validate
  PROCEDURE validate_pxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxhv_rec                     IN  pxhv_rec_type);

--Object type procedure for create
  PROCEDURE create_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_tbl                     IN  pxlv_tbl_type,
     x_pxlv_tbl                     OUT NOCOPY pxlv_tbl_type);

--Object type procedure for create
  PROCEDURE create_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_rec                     IN  pxlv_rec_type,
     x_pxlv_rec                     OUT NOCOPY pxlv_rec_type);

--Object type procedure for lock
  PROCEDURE lock_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_tbl                     IN  pxlv_tbl_type);

--Object type procedure for lock
  PROCEDURE lock_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_rec                     IN  pxlv_rec_type);

 --Object type procedure for update
  PROCEDURE update_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_tbl                     IN  pxlv_tbl_type,
     x_pxlv_tbl                     OUT NOCOPY pxlv_tbl_type);

--Object type procedure for update
  PROCEDURE update_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_rec                     IN  pxlv_rec_type,
     x_pxlv_rec                     OUT NOCOPY pxlv_rec_type);

--Object type procedure for delete
  PROCEDURE delete_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_tbl                     IN  pxlv_tbl_type);

--Object type procedure for delete
  PROCEDURE delete_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_rec                     IN  pxlv_rec_type);

--Object type procedure for validate
   PROCEDURE validate_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_tbl                     IN  pxlv_tbl_type);

--Object type procedure for validate
  PROCEDURE validate_pxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pxlv_rec                     IN  pxlv_rec_type);

--Object type procedure for insert
--Added for Bug# 6268782 : PRASJAIN
  PROCEDURE create_pxh_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_pxh_rec                 IN  pxh_rec_type
    ,p_pxhl_tbl                IN  pxhl_tbl_type
    ,x_pxh_rec                 OUT NOCOPY pxh_rec_type
    ,x_pxhl_tbl                OUT NOCOPY pxhl_tbl_type);

--Object type procedure for insert
--Added for Bug# 6268782 : PRASJAIN
  PROCEDURE create_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxl_rec                        IN  pxl_rec_type
    ,p_pxll_tbl                       IN  pxll_tbl_type
    ,x_pxl_rec                        OUT NOCOPY pxl_rec_type
    ,x_pxll_tbl                       OUT NOCOPY pxll_tbl_type);
END OKL_AP_EXTENSION_PVT;

/
