--------------------------------------------------------
--  DDL for Package OKC_EXTEND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_EXTEND_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPEXTS.pls 120.0 2005/05/25 19:00:22 appldev noship $ */

SUBTYPE extend_in_parameters_rec is OKC_EXTEND_PVT.extend_in_parameters_rec;
SUBTYPE extend_in_parameters_tbl is OKC_EXTEND_PVT.extend_in_parameters_tbl;
SUBTYPE extend_in_cle_rec is OKC_EXTEND_PVT.extend_in_cle_rec;
SUBTYPE extend_in_cle_tbl is OKC_EXTEND_PVT.extend_in_cle_tbl;


 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN        	CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN  		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_EXTEND_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  ---------------------------------------------------------------------------

g_extend_in_parameters_rec   extend_in_parameters_rec;
g_extend_in_cle_rec   extend_in_cle_rec;


FUNCTION is_k_extend_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION is_kl_extend_allowed(p_cle_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;


PROCEDURE extend_chr( p_api_version                  IN  NUMBER,
   	                 p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status                OUT NOCOPY VARCHAR2,
                      x_msg_count                    OUT NOCOPY NUMBER,
                      x_msg_data                     OUT NOCOPY VARCHAR2,
	                 p_extend_in_parameters_tbl     IN  extend_in_parameters_tbl,
				  p_do_commit                    IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	               );

PROCEDURE extend_chr( p_api_version                 IN  NUMBER,
		            p_init_msg_list               IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status               OUT NOCOPY VARCHAR2,
                      x_msg_count                   OUT NOCOPY NUMBER,
                      x_msg_data                    OUT NOCOPY VARCHAR2,
	                 p_extend_in_parameters_rec    IN  extend_in_parameters_rec,
				  p_do_commit                    IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	                );

PROCEDURE validate_chr( p_api_version                  IN  NUMBER,
	  	              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_tbl     IN  extend_in_parameters_tbl);

PROCEDURE validate_chr( p_api_version                  IN  NUMBER,
                        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_rec     IN  extend_in_parameters_rec );

PROCEDURE extend_cle( p_api_version                  IN  NUMBER,
 	  	            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status                OUT NOCOPY VARCHAR2,
                      x_msg_count                    OUT NOCOPY NUMBER,
                      x_msg_data                     OUT NOCOPY VARCHAR2,
	                 p_extend_in_parameters_tbl     IN  extend_in_cle_tbl,
				  p_do_commit                    IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	               );

PROCEDURE extend_cle( p_api_version                 IN  NUMBER,
		            p_init_msg_list               IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status               OUT NOCOPY VARCHAR2,
                      x_msg_count                   OUT NOCOPY NUMBER,
                      x_msg_data                    OUT NOCOPY VARCHAR2,
	                 p_extend_in_parameters_rec 	  IN  extend_in_cle_rec,
				  p_do_commit                    IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	               );

PROCEDURE validate_cle( p_api_version                  IN  NUMBER,
 	  	              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_tbl 	 IN extend_in_cle_tbl);

PROCEDURE validate_cle( p_api_version                  IN  NUMBER,
		              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_rec 	 IN extend_in_cle_rec);

END OKC_EXTEND_PUB;

 

/
