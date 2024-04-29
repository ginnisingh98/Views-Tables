--------------------------------------------------------
--  DDL for Package OKL_OPT_RUL_TMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OPT_RUL_TMP_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRTMS.pls 115.1 2002/02/25 17:08:06 pkm ship        $ */

 SUBTYPE rgrv_rec_type IS Okl_Opt_Rul_Tmp_Pvt.rgrv_rec_type;
 SUBTYPE rgrv_tbl_type IS Okl_Opt_Rul_Tmp_Pvt.rgrv_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_Options_Rule_Template_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ovd_id                       IN  NUMBER
    ,p_rgrv_tbl                     IN  rgrv_tbl_type
    ,x_rgrv_tbl                     OUT  NOCOPY rgrv_tbl_type);

 PROCEDURE insert_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_ovd_id                       IN  NUMBER
    ,p_rgrv_rec                     IN  rgrv_rec_type
    ,x_rgrv_rec                     OUT  NOCOPY rgrv_rec_type);

 PROCEDURE lock_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_rgrv_tbl                     IN  rgrv_tbl_type);

 PROCEDURE lock_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_rgrv_rec                     IN  rgrv_rec_type);

 PROCEDURE update_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_rgrv_tbl                     IN  rgrv_tbl_type
    ,x_rgrv_tbl                     OUT  NOCOPY rgrv_tbl_type);

 PROCEDURE update_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_rgrv_rec                     IN  rgrv_rec_type
    ,x_rgrv_rec                     OUT  NOCOPY rgrv_rec_type);

 PROCEDURE delete_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_rgrv_tbl                     IN  rgrv_tbl_type);

 PROCEDURE delete_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_rgrv_rec                     IN  rgrv_rec_type);

  PROCEDURE validate_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_rgrv_tbl                     IN  rgrv_tbl_type);

 PROCEDURE validate_Opt_Rul_Tmp(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_rgrv_rec                     IN  rgrv_rec_type);

END Okl_Opt_Rul_Tmp_Pub;


 

/
