--------------------------------------------------------
--  DDL for Package OKL_FA_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FA_EXTENSION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCFXHS.pls 120.1 2007/08/06 13:47:47 prasjain noship $ */

  SUBTYPE fxhv_rec_type IS okl_fxh_pvt.fxhv_rec_type;
  SUBTYPE fxhv_tbl_type IS okl_fxh_pvt.fxhv_tbl_type;

  SUBTYPE fxlv_rec_type IS okl_fxl_pvt.fxlv_rec_type;
  SUBTYPE fxlv_tbl_type IS okl_fxl_pvt.fxlv_tbl_type;
  -- Start : Bug# 6268782 : PRASJAIN
  SUBTYPE fxh_rec_type  IS okl_fxh_pvt.fxh_rec_type;
  SUBTYPE fxhl_tbl_type IS okl_fxh_pvt.fxhl_tbl_type;

  SUBTYPE fxl_rec_type  IS okl_fxl_pvt.fxl_rec_type;
  SUBTYPE fxll_tbl_type IS okl_fxl_pvt.fxll_tbl_type;

  SUBTYPE fxl_tbl_tbl_type IS okl_fxl_pvt.fxl_tbl_tbl_type;
  -- End : Bug# 6268782 : PRASJAIN
  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_FA_EXTENSION_PVT';
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
  PROCEDURE create_fxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_fxhv_rec                     IN  fxhv_rec_type
    ,p_fxlv_tbl                     IN  fxlv_tbl_type
    ,x_fxhv_rec                     OUT NOCOPY fxhv_rec_type
    ,x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type
     );

--Object type procedure for update
  PROCEDURE update_fxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_fxhv_rec                     IN  fxhv_rec_type
    ,p_fxlv_tbl                     IN  fxlv_tbl_type
    ,x_fxhv_rec                     OUT NOCOPY fxhv_rec_type
    ,x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type
     );

--Object type procedure for validate
  PROCEDURE validate_fxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_fxhv_rec                     IN  fxhv_rec_type
    ,p_fxlv_tbl                     IN  fxlv_tbl_type
     );


--Object type procedure for create
  PROCEDURE create_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_tbl                     IN  fxhv_tbl_type,
     x_fxhv_tbl                     OUT NOCOPY fxhv_tbl_type);

--Object type procedure for create
  PROCEDURE create_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_rec                     IN  fxhv_rec_type,
     x_fxhv_rec                     OUT NOCOPY fxhv_rec_type);

--Object type procedure for lock
  PROCEDURE lock_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_tbl                     IN  fxhv_tbl_type);

--Object type procedure for lock
  PROCEDURE lock_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_rec                     IN  fxhv_rec_type);

--Object type procedure for update
  PROCEDURE update_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_tbl                     IN  fxhv_tbl_type,
     x_fxhv_tbl                     OUT NOCOPY fxhv_tbl_type);

--Object type procedure for update
  PROCEDURE update_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_rec                     IN  fxhv_rec_type,
     x_fxhv_rec                     OUT NOCOPY fxhv_rec_type);

--Object type procedure for delete
  PROCEDURE delete_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_tbl                     IN  fxhv_tbl_type);

--Object type procedure for delete
  PROCEDURE delete_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_rec                     IN fxhv_rec_type);

--Object type procedure for validate
   PROCEDURE validate_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_tbl                     IN  fxhv_tbl_type);

--Object type procedure for validate
  PROCEDURE validate_fxh_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxhv_rec                     IN  fxhv_rec_type);

--Object type procedure for create
  PROCEDURE create_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_tbl                     IN  fxlv_tbl_type,
     x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type);

--Object type procedure for create
  PROCEDURE create_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_rec                     IN  fxlv_rec_type,
     x_fxlv_rec                     OUT NOCOPY fxlv_rec_type);

--Object type procedure for lock
  PROCEDURE lock_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_tbl                     IN  fxlv_tbl_type);

--Object type procedure for lock
  PROCEDURE lock_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_rec                     IN  fxlv_rec_type);

 --Object type procedure for update
  PROCEDURE update_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_tbl                     IN  fxlv_tbl_type,
     x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type);

--Object type procedure for update
  PROCEDURE update_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_rec                     IN  fxlv_rec_type,
     x_fxlv_rec                     OUT NOCOPY fxlv_rec_type);

--Object type procedure for delete
  PROCEDURE delete_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_tbl                     IN  fxlv_tbl_type);

--Object type procedure for delete
  PROCEDURE delete_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_rec                     IN  fxlv_rec_type);

--Object type procedure for validate
   PROCEDURE validate_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_tbl                     IN  fxlv_tbl_type);

--Object type procedure for validate
  PROCEDURE validate_fxl_extension(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_fxlv_rec                     IN  fxlv_rec_type);
--Object type procedure for validate
--Added : Bug# 6268782 : PRASJAIN
  PROCEDURE create_fxh_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_fxh_rec                 IN  fxh_rec_type
    ,p_fxhl_tbl                IN  fxhl_tbl_type
    ,x_fxh_rec                 OUT NOCOPY fxh_rec_type
    ,x_fxhl_tbl                OUT NOCOPY fxhl_tbl_type);
--Object type procedure for validate
--Added : Bug# 6268782 : PRASJAIN
  PROCEDURE create_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxl_rec                        IN  fxl_rec_type
    ,p_fxll_tbl                       IN  fxll_tbl_type
    ,x_fxl_rec                        OUT NOCOPY fxl_rec_type
    ,x_fxll_tbl                       OUT NOCOPY fxll_tbl_type);
--Object type procedure for validate
--Added : Bug# 6268782 : PRASJAIN
  PROCEDURE create_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxl_tbl_tbl                    IN  fxl_tbl_tbl_type
    ,x_fxl_tbl_tbl                    OUT NOCOPY fxl_tbl_tbl_type);
END OKL_FA_EXTENSION_PVT;

/
