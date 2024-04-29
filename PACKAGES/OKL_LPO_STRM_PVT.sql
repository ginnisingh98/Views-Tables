--------------------------------------------------------
--  DDL for Package OKL_LPO_STRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LPO_STRM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLSXS.pls 115.2 2002/02/12 14:31:23 pkm ship        $ */
  SUBTYPE SLX_REC_TYPE IS OKL_SLX_PVT.slxv_rec_type;
  SUBTYPE SLX_TBL_TYPE IS OKL_SLX_PVT.slxv_tbl_type;


  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LPO_STRM_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ------------------------------------------------------------------------------

  l_msg_data VARCHAR2(4000);

  --PROCEDURE ADD_LANGUAGE;

  --Object type procedure for creating Accounting Transaction
  PROCEDURE create_lpo_streams(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_lpo_id						IN  NUMBER
     );


END OKL_LPO_STRM_PVT;

 

/
