--------------------------------------------------------
--  DDL for Package OKL_INS_QUOTE_WRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_QUOTE_WRP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQMNS.pls 115.4 2003/02/20 04:09:10 smoduga noship $ */
  SUBTYPE ipyv_rec_type IS Okl_Ipy_Pvt.ipyv_rec_type;
  SUBTYPE ipyv_tbl_type IS okl_ipy_pvt.ipyv_tbl_type;
  SUBTYPE iasset_tbl_type IS Okl_Ins_Quote_Pvt.iasset_tbl_type;
  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE   calc_lease_premium(
         p_api_version                   IN NUMBER,
	     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         px_ipyv_tbl                    IN OUT NOCOPY ipyv_tbl_type,
	     x_message                      OUT NOCOPY VARCHAR2,
         x_iasset_tbl                   OUT NOCOPY  iasset_tbl_type
     );
  PROCEDURE   calc_optional_premium(
         p_api_version                   IN NUMBER,
	     p_init_msg_list                    IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_tbl                     IN  ipyv_tbl_type,
	     x_message                          OUT NOCOPY VARCHAR2,
         x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type
     );
   PROCEDURE   save_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     px_ipyv_tbl                    IN OUT NOCOPY ipyv_tbl_type,
	 x_message                      OUT NOCOPY  VARCHAR2  );

    PROCEDURE   save_accept_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_tbl                    IN ipyv_tbl_type,
	 x_message                      OUT NOCOPY  VARCHAR2  );

   PROCEDURE   create_third_prt_ins(
         p_api_version                   IN NUMBER,
	     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_tbl                     IN  ipyv_tbl_type,
         x_ipyv_tbl                  OUT NOCOPY   ipyv_tbl_type
     );

END OKL_INS_QUOTE_WRP_PVT;

 

/
