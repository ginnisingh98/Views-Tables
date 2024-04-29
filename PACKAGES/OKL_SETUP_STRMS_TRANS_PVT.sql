--------------------------------------------------------
--  DDL for Package OKL_SETUP_STRMS_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUP_STRMS_TRANS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSMNS.pls 115.2 2002/07/22 23:39:00 smahapat noship $ */

  G_UNEXPECTED_ERROR                CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN                   CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN                   CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_PKG_NAME                        CONSTANT VARCHAR2(200) := 'OKL_SETUP_STRMS_TRANS_PVT' ;
  G_APP_NAME                        CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
  G_FALSE				            CONSTANT VARCHAR2(1)   :=  OKL_API.G_FALSE;
  G_EXC_NAME_ERROR		            CONSTANT VARCHAR2(50)  := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	        CONSTANT VARCHAR2(50)  := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	                CONSTANT VARCHAR2(6)   := 'OTHERS';
  G_RET_STS_SUCCESS		            CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		            CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;

  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			  		EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;
  G_EXCEPTION_EXCEPTION_DATA		EXCEPTION;

  SUBTYPE sgnv_rec_type IS okl_sgt_pvt.sgnv_rec_type;
  SUBTYPE sgnv_tbl_type IS okl_sgt_pvt.sgnv_tbl_type;


  PROCEDURE insert_translations (p_api_version        IN     NUMBER
                                ,p_init_msg_list      IN     VARCHAR2
								,p_sgnv_tbl           IN     sgnv_tbl_type
        	                    ,x_sgnv_tbl           OUT    NOCOPY sgnv_tbl_type
                                ,x_return_status      OUT    NOCOPY VARCHAR2
                                ,x_msg_count          OUT    NOCOPY NUMBER
                                ,x_msg_data           OUT    NOCOPY VARCHAR2);

  PROCEDURE update_translations (p_api_version        IN     NUMBER
                                ,p_init_msg_list      IN     VARCHAR2
								,p_sgnv_tbl           IN     sgnv_tbl_type
        	                    ,x_sgnv_tbl           OUT    NOCOPY sgnv_tbl_type
                                ,x_return_status      OUT    NOCOPY VARCHAR2
                                ,x_msg_count          OUT    NOCOPY NUMBER
                                ,x_msg_data           OUT    NOCOPY VARCHAR2);

  PROCEDURE delete_translations (p_api_version        IN     NUMBER
                                ,p_init_msg_list      IN     VARCHAR2
        	                    ,p_sgnv_tbl           IN     sgnv_tbl_type
                                ,x_return_status      OUT    NOCOPY VARCHAR2
                                ,x_msg_count          OUT    NOCOPY NUMBER
                                ,x_msg_data           OUT    NOCOPY VARCHAR2);

END OKL_SETUP_STRMS_TRANS_PVT;

 

/
