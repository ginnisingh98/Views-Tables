--------------------------------------------------------
--  DDL for Package OKL_CSH_ALLCT_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CSH_ALLCT_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCSAS.pls 115.3 2002/02/12 14:31:11 pkm ship        $ */


 SUBTYPE cahv_rec_type IS Okl_Csh_Allct_Srchs_Pub.cahv_rec_type;
 SUBTYPE cahv_tbl_type IS Okl_Csh_Allct_Srchs_Pub.cahv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE delete_row (p_api_version  IN NUMBER
        ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
        ,x_return_status   OUT NOCOPY VARCHAR2
        ,x_msg_count       OUT NOCOPY NUMBER
        ,x_msg_data        OUT NOCOPY VARCHAR2
        ,p_cahv_rec        IN cahv_rec_type
                        );

END OKL_CSH_ALLCT_RULES_Pvt;

 

/
