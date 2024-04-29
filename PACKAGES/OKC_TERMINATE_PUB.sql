--------------------------------------------------------
--  DDL for Package OKC_TERMINATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMINATE_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPTERS.pls 120.0 2005/05/25 22:32:22 appldev noship $ */

SUBTYPE terminate_in_parameters_rec IS OKC_TERMINATE_PVT.terminate_in_parameters_rec;
SUBTYPE terminate_in_parameters_tbl IS OKC_TERMINATE_PVT.terminate_in_parameters_tbl;
SUBTYPE terminate_in_cle_rec IS OKC_TERMINATE_PVT.terminate_in_cle_rec;
SUBTYPE terminate_in_cle_tbl IS OKC_TERMINATE_PVT.terminate_in_cle_tbl;


 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION      EXCEPTION;
  G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN        	     CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN  		          CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			          CONSTANT VARCHAR2(200) := 'OKC_terminate_PUB';
  G_APP_NAME		 	          CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_FND_APP			          CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  ---------------------------------------------------------------------------
 g_terminate_in_parameters_rec   terminate_in_parameters_rec;
 g_terminate_in_cle_rec          terminate_in_cle_rec;

FUNCTION is_k_term_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION is_kl_term_allowed(p_cle_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE terminate_chr( p_api_version                  IN  NUMBER,
   	                    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_tbl   IN terminate_in_parameters_tbl,
					p_do_commit                     IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	                  );

 PROCEDURE terminate_chr( p_api_version                 IN  NUMBER,
		                p_init_msg_list               IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status               OUT NOCOPY VARCHAR2,
                          x_msg_count                   OUT NOCOPY NUMBER,
                          x_msg_data                    OUT NOCOPY VARCHAR2,
	                     p_terminate_in_parameters_rec IN  terminate_in_parameters_rec,
					 p_do_commit                   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	                  );

 PROCEDURE validate_chr( p_api_version                  IN  NUMBER,
	  	               p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_tbl	 IN  terminate_in_parameters_tbl);

 PROCEDURE validate_chr( p_api_version                  IN  NUMBER,
		               p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_rec	 IN  terminate_in_parameters_rec );

PROCEDURE terminate_cle( p_api_version                  IN  NUMBER,
 	  	               p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status                OUT NOCOPY VARCHAR2,
                         x_msg_count                    OUT NOCOPY NUMBER,
                         x_msg_data                     OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_tbl  IN  terminate_in_cle_tbl,
					p_do_commit                    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE);

PROCEDURE terminate_cle( p_api_version                 IN  NUMBER,
		               p_init_msg_list               IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_rec	IN  terminate_in_cle_rec,
					p_do_commit                   IN  VARCHAR2  DEFAULT OKC_API.G_FALSE
	                  );

PROCEDURE validate_cle( p_api_version                  IN  NUMBER,
	  	              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_terminate_in_parameters_tbl 	 IN terminate_in_cle_tbl);

PROCEDURE validate_cle( p_api_version                  IN  NUMBER,
		              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_terminate_in_parameters_rec 	 IN terminate_in_cle_rec);

END OKC_TERMINATE_PUB;

 

/
