--------------------------------------------------------
--  DDL for Package OKL_BP_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BP_RULES" AUTHID CURRENT_USER AS
/* $Header: OKLRBPRS.pls 115.1 2002/03/21 19:04:43 pkm ship        $ */

-----------------------------------------------
--global variables
-----------------------------------------------
G_API_TYPE          CONSTANT VARCHAR2(5)   := '_PVT';
G_PKG_NAME          CONSTANT VARCHAR2(30)  := 'OKL_BP_RULES';
G_APP_NAME		    CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
G_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_CONTRACTS_ERROR';
G_UNEXPECTED_ERROR  CONSTANT VARCHAR2(30)  := 'OKL_CONTRACTS_UNEXP_ERROR';
------------------------------------------------

l_rgpv_tbl			Okl_Rule_Apis_Pvt.rgpv_tbl_type;
l_rgpv_rec		 	Okl_Rule_Apis_Pvt.rgpv_rec_type;

l_rulv_rec			Okl_Rule_Apis_Pvt.rulv_rec_type;
l_rulv_tbl			Okl_Rule_Apis_Pvt.rulv_tbl_type;

l_rulv_disp_rec     Okl_Rule_Apis_Pvt.rulv_disp_rec_type;


   SUBTYPE rulv_disp_rec_type IS Okl_Rule_Apis_Pvt.rulv_disp_rec_type;
   SUBTYPE rulv_rec_type IS Okl_Rule_Apis_Pvt.rulv_rec_type;

   PROCEDURE extract_rules(
       p_api_version                  IN NUMBER,
   	   p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
	   p_khr_id						  IN NUMBER,
	   p_kle_id						  IN NUMBER,
	   p_rgd_code					  IN VARCHAR2,
	   p_rdf_code					  IN VARCHAR2,
   	   x_return_status                OUT NOCOPY VARCHAR2,
   	   x_msg_count                    OUT NOCOPY NUMBER,
   	   x_msg_data                     OUT NOCOPY VARCHAR2,
	   x_rulv_rec				  	  OUT NOCOPY rulv_rec_type);

END Okl_Bp_Rules;

 

/
