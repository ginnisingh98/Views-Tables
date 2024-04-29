--------------------------------------------------------
--  DDL for Package OKL_VAR_INT_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VAR_INT_PARAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRVIRS.pls 120.1 2005/09/29 21:38:51 pjgomes noship $ */

  SUBTYPE virv_rec_type IS okl_vir_pvt.virv_rec_type;
  SUBTYPE virv_tbl_type IS okl_vir_pvt.virv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                      CONSTANT VARCHAR2(200) := 'OKL_VAR_INT_PARAMS_PVT';
  G_APP_NAME                      CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE                      CONSTANT VARCHAR2(30)  := '_PVT';
  G_REQUIRED_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN                CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE create_var_int_params(p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_virv_rec      IN  virv_rec_type,
                                  x_virv_rec      OUT NOCOPY virv_rec_type);

  PROCEDURE create_var_int_params(p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_virv_tbl      IN  virv_tbl_type,
                                  x_virv_tbl      OUT NOCOPY virv_tbl_type);

  PROCEDURE update_var_int_params(p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_virv_rec      IN  virv_rec_type,
                                  x_virv_rec      OUT NOCOPY virv_rec_type);

  PROCEDURE update_var_int_params(p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_virv_tbl      IN  virv_tbl_type,
                                  x_virv_tbl      OUT NOCOPY virv_tbl_type);

  PROCEDURE delete_var_int_params(p_api_version   IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_virv_tbl       IN  virv_tbl_type
                                 );

  PROCEDURE validate_var_int_params(
                                 p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_virv_rec       IN  virv_rec_type);

  PROCEDURE validate_var_int_params(
                                 p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_virv_tbl       IN  virv_tbl_type);

END OKL_VAR_INT_PARAMS_PVT;

 

/
