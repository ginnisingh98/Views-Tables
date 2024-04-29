--------------------------------------------------------
--  DDL for Package OKL_OPTION_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OPTION_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCORLS.pls 115.2 2002/02/05 11:49:48 pkm ship       $ */

  SUBTYPE orlv_rec_type IS okl_orl_pvt.orlv_rec_type;
  SUBTYPE orlv_tbl_type IS okl_orl_pvt.orlv_tbl_type;

  SUBTYPE ovdv_rec_type IS okl_ovd_pvt.ovdv_rec_type;
  SUBTYPE ovdv_tbl_type IS okl_ovd_pvt.ovdv_tbl_type;
  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_OPTION_RULES_PVT';
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
  PROCEDURE create_option_rules(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_orlv_rec                     IN  orlv_rec_type
    ,p_ovdv_tbl                     IN  ovdv_tbl_type
    ,x_orlv_rec                     OUT NOCOPY orlv_rec_type
    ,x_ovdv_tbl                     OUT NOCOPY ovdv_tbl_type
     );

  --Object type procedure for update
  PROCEDURE update_option_rules(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_orlv_rec                     IN  orlv_rec_type
    ,p_ovdv_tbl                     IN  ovdv_tbl_type
    ,x_orlv_rec                     OUT NOCOPY orlv_rec_type
    ,x_ovdv_tbl                     OUT NOCOPY ovdv_tbl_type
     );

  --Object type procedure for validate
  PROCEDURE validate_option_rules(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_orlv_rec                     IN  orlv_rec_type
    ,p_ovdv_tbl                     IN  ovdv_tbl_type
     );



  PROCEDURE create_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_tbl                     IN  orlv_tbl_type,
     x_orlv_tbl                     OUT NOCOPY orlv_tbl_type);

  PROCEDURE create_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_rec                     IN  orlv_rec_type,
     x_orlv_rec                     OUT NOCOPY orlv_rec_type);

  PROCEDURE lock_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_tbl                     IN  orlv_tbl_type);

  PROCEDURE lock_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_rec                     IN  orlv_rec_type);

  PROCEDURE update_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_tbl                     IN  orlv_tbl_type,
     x_orlv_tbl                     OUT NOCOPY orlv_tbl_type);

  PROCEDURE update_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_rec                     IN  orlv_rec_type,
     x_orlv_rec                     OUT NOCOPY orlv_rec_type);

  PROCEDURE delete_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_tbl                     IN  orlv_tbl_type);

  PROCEDURE delete_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_rec                     IN orlv_rec_type);

   PROCEDURE validate_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_tbl                     IN  orlv_tbl_type);

  PROCEDURE validate_option_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_orlv_rec                     IN  orlv_rec_type);


  PROCEDURE create_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_tbl                     IN  ovdv_tbl_type,
     x_ovdv_tbl                     OUT NOCOPY ovdv_tbl_type);

  PROCEDURE create_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_rec                     IN  ovdv_rec_type,
     x_ovdv_rec                     OUT NOCOPY ovdv_rec_type);

  PROCEDURE lock_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_tbl                     IN  ovdv_tbl_type);

  PROCEDURE lock_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_rec                     IN  ovdv_rec_type);

  PROCEDURE update_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_tbl                     IN  ovdv_tbl_type,
     x_ovdv_tbl                     OUT NOCOPY ovdv_tbl_type);

  PROCEDURE update_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_rec                     IN  ovdv_rec_type,
     x_ovdv_rec                     OUT NOCOPY ovdv_rec_type);

  PROCEDURE delete_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_tbl                     IN  ovdv_tbl_type);

  PROCEDURE delete_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_rec                     IN  ovdv_rec_type);

   PROCEDURE validate_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_tbl                     IN  ovdv_tbl_type);

  PROCEDURE validate_option_val_rules(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ovdv_rec                     IN  ovdv_rec_type);

END OKL_OPTION_RULES_PVT;

 

/
