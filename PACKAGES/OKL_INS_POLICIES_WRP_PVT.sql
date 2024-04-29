--------------------------------------------------------
--  DDL for Package OKL_INS_POLICIES_WRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_POLICIES_WRP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRFPYS.pls 115.2 2002/11/30 08:47:49 spillaip noship $ */
  SUBTYPE ipyv_rec_type IS Okl_Ipy_Pvt.ipyv_rec_type;
  SUBTYPE ipyv_tbl_type IS okl_ipy_pvt.ipyv_tbl_type;
  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE cancel_policy(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_ipyv_tbl                  IN  ipyv_tbl_type,
        x_ipyv_tbl                  OUT NOCOPY  ipyv_tbl_type
        );

        PROCEDURE delete_policy(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_ipyv_tbl                  IN  ipyv_tbl_type,
        x_ipyv_tbl                  OUT NOCOPY  ipyv_tbl_type
      );

END OKL_INS_POLICIES_WRP_PVT;

 

/
