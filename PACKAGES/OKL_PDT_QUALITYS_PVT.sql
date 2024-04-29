--------------------------------------------------------
--  DDL for Package OKL_PDT_QUALITYS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PDT_QUALITYS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCPQYS.pls 115.3 2002/02/05 11:49:56 pkm ship       $ */

  SUBTYPE pqyv_rec_type IS okl_pqy_pvt.pqyv_rec_type;
  SUBTYPE pqyv_tbl_type IS okl_pqy_pvt.pqyv_tbl_type;

  SUBTYPE qvev_rec_type IS okl_qve_pvt.qvev_rec_type;
  SUBTYPE qvev_tbl_type IS okl_qve_pvt.qvev_tbl_type;
  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PDT_QUALITYS_PVT';
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
  PROCEDURE create_pdt_qualitys(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_pqyv_rec                     IN  pqyv_rec_type
    ,p_qvev_tbl                     IN  qvev_tbl_type
    ,x_pqyv_rec                     OUT NOCOPY pqyv_rec_type
    ,x_qvev_tbl                     OUT NOCOPY qvev_tbl_type
     );

  --Object type procedure for update
  PROCEDURE update_pdt_qualitys(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_pqyv_rec                     IN  pqyv_rec_type
    ,p_qvev_tbl                     IN  qvev_tbl_type
    ,x_pqyv_rec                     OUT NOCOPY pqyv_rec_type
    ,x_qvev_tbl                     OUT NOCOPY qvev_tbl_type
     );

  --Object type procedure for validate
  PROCEDURE validate_pdt_qualitys(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_pqyv_rec                     IN  pqyv_rec_type
    ,p_qvev_tbl                     IN  qvev_tbl_type
     );



  PROCEDURE create_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_tbl                     IN  pqyv_tbl_type,
     x_pqyv_tbl                     OUT NOCOPY pqyv_tbl_type);

  PROCEDURE create_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_rec                     IN  pqyv_rec_type,
     x_pqyv_rec                     OUT NOCOPY pqyv_rec_type);

  PROCEDURE lock_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_tbl                     IN  pqyv_tbl_type);

  PROCEDURE lock_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_rec                     IN  pqyv_rec_type);

  PROCEDURE update_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_tbl                     IN  pqyv_tbl_type,
     x_pqyv_tbl                     OUT NOCOPY pqyv_tbl_type);

  PROCEDURE update_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_rec                     IN  pqyv_rec_type,
     x_pqyv_rec                     OUT NOCOPY pqyv_rec_type);

  PROCEDURE delete_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_tbl                     IN  pqyv_tbl_type);

  PROCEDURE delete_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_rec                     IN pqyv_rec_type);

   PROCEDURE validate_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_tbl                     IN  pqyv_tbl_type);

  PROCEDURE validate_pdt_qualitys(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_rec                     IN  pqyv_rec_type);


  PROCEDURE create_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_tbl                     IN  qvev_tbl_type,
     x_qvev_tbl                     OUT NOCOPY qvev_tbl_type);

  PROCEDURE create_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_rec                     IN  qvev_rec_type,
     x_qvev_rec                     OUT NOCOPY qvev_rec_type);

  PROCEDURE lock_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_tbl                     IN  qvev_tbl_type);

  PROCEDURE lock_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_rec                     IN  qvev_rec_type);

  PROCEDURE update_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_tbl                     IN  qvev_tbl_type,
     x_qvev_tbl                     OUT NOCOPY qvev_tbl_type);

  PROCEDURE update_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_rec                     IN  qvev_rec_type,
     x_qvev_rec                     OUT NOCOPY qvev_rec_type);

  PROCEDURE delete_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_tbl                     IN  qvev_tbl_type);

  PROCEDURE delete_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_rec                     IN  qvev_rec_type);

   PROCEDURE validate_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_tbl                     IN  qvev_tbl_type);

  PROCEDURE validate_pdt_quality_vals(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_qvev_rec                     IN  qvev_rec_type);

END OKL_PDT_QUALITYS_PVT;

 

/
