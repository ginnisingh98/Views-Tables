--------------------------------------------------------
--  DDL for Package OKL_CSH_ALLCT_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CSH_ALLCT_RULES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCSAS.pls 115.3 2002/02/12 16:26:03 pkm ship        $ */


 SUBTYPE cahv_rec_type IS Okl_Csh_Allct_Rules_Pvt.cahv_rec_type;
 SUBTYPE cahv_tbl_type IS Okl_Csh_Allct_Rules_Pvt.cahv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CSH_ALLCT_RULES_PUB';
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE delete_comb_rules (p_api_version  IN NUMBER
        ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
        ,x_return_status   OUT NOCOPY VARCHAR2
        ,x_msg_count       OUT NOCOPY NUMBER
        ,x_msg_data        OUT NOCOPY VARCHAR2
        ,p_cahv_rec        IN cahv_rec_type
                        );

PROCEDURE delete_comb_rules (p_api_version  IN NUMBER
        ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
        ,x_return_status   OUT NOCOPY VARCHAR2
        ,x_msg_count       OUT NOCOPY NUMBER
        ,x_msg_data        OUT NOCOPY VARCHAR2
        ,p_cahv_tbl        IN cahv_tbl_type
                        );

END OKL_CSH_ALLCT_RULES_Pub;

 

/
