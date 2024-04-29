--------------------------------------------------------
--  DDL for Package OKL_PTL_QUALITYS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PTL_QUALITYS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCPTQS.pls 115.2 2002/02/05 11:49:59 pkm ship       $ */

  SUBTYPE ptqv_rec_type IS okl_ptq_pvt.ptqv_rec_type;
  SUBTYPE ptqv_tbl_type IS okl_ptq_pvt.ptqv_tbl_type;

  SUBTYPE ptvv_rec_type IS okl_ptv_pvt.ptvv_rec_type;
  SUBTYPE ptvv_tbl_type IS okl_ptv_pvt.ptvv_tbl_type;
  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PTL_QUALITYS_PVT';
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
  PROCEDURE create_ptl_qualitys(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_ptqv_rec                     IN  ptqv_rec_type
    ,p_ptvv_tbl                     IN  ptvv_tbl_type
    ,x_ptqv_rec                     OUT NOCOPY ptqv_rec_type
    ,x_ptvv_tbl                     OUT NOCOPY ptvv_tbl_type
     );

  --Object type procedure for update
  PROCEDURE update_ptl_qualitys(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_ptqv_rec                     IN  ptqv_rec_type
    ,p_ptvv_tbl                     IN  ptvv_tbl_type
    ,x_ptqv_rec                     OUT NOCOPY ptqv_rec_type
    ,x_ptvv_tbl                     OUT NOCOPY ptvv_tbl_type
     );

  --Object type procedure for validate
  PROCEDURE validate_ptl_qualitys(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_ptqv_rec                     IN  ptqv_rec_type
    ,p_ptvv_tbl                     IN  ptvv_tbl_type
     );



  PROCEDURE create_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_tbl                     IN  ptqv_tbl_type,
     x_ptqv_tbl                     OUT NOCOPY ptqv_tbl_type);

  PROCEDURE create_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_rec                     IN  ptqv_rec_type,
     x_ptqv_rec                     OUT NOCOPY ptqv_rec_type);

  PROCEDURE lock_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_tbl                     IN  ptqv_tbl_type);

  PROCEDURE lock_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_rec                     IN  ptqv_rec_type);

  PROCEDURE update_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_tbl                     IN  ptqv_tbl_type,
     x_ptqv_tbl                     OUT NOCOPY ptqv_tbl_type);

  PROCEDURE update_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_rec                     IN  ptqv_rec_type,
     x_ptqv_rec                     OUT NOCOPY ptqv_rec_type);

  PROCEDURE delete_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_tbl                     IN  ptqv_tbl_type);

  PROCEDURE delete_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_rec                     IN ptqv_rec_type);

   PROCEDURE validate_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_tbl                     IN  ptqv_tbl_type);

  PROCEDURE validate_ptl_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptqv_rec                     IN  ptqv_rec_type);


  PROCEDURE create_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_tbl                     IN  ptvv_tbl_type,
     x_ptvv_tbl                     OUT NOCOPY ptvv_tbl_type);

  PROCEDURE create_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_rec                     IN  ptvv_rec_type,
     x_ptvv_rec                     OUT NOCOPY ptvv_rec_type);

  PROCEDURE lock_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_tbl                     IN  ptvv_tbl_type);

  PROCEDURE lock_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_rec                     IN  ptvv_rec_type);

  PROCEDURE update_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_tbl                     IN  ptvv_tbl_type,
     x_ptvv_tbl                     OUT NOCOPY ptvv_tbl_type);

  PROCEDURE update_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_rec                     IN  ptvv_rec_type,
     x_ptvv_rec                     OUT NOCOPY ptvv_rec_type);

  PROCEDURE delete_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_tbl                     IN  ptvv_tbl_type);

  PROCEDURE delete_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_rec                     IN  ptvv_rec_type);

   PROCEDURE validate_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_tbl                     IN  ptvv_tbl_type);

  PROCEDURE validate_ptl_qlty_values(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ptvv_rec                     IN  ptvv_rec_type);

END OKL_PTL_QUALITYS_PVT;

 

/
