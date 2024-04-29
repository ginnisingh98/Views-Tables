--------------------------------------------------------
--  DDL for Package OKC_TERMINATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMINATE_PVT" AUTHID CURRENT_USER as
/* $Header: OKCRTERS.pls 120.0 2005/05/26 09:50:19 appldev noship $ */

 Type terminate_in_parameters_rec is RECORD (
   p_Contract_id              number ,
   p_contract_number          okc_k_headers_v.contract_number%type,
   p_contract_modifier        okc_k_headers_v.contract_number_modifier%type,
   p_orig_end_date            date ,
   p_contract_version         varchar2(9),
   p_termination_date         date ,
   p_termination_reason       fnd_lookups.lookup_code%type );


 Type terminate_in_parameters_tbl is table of terminate_in_parameters_rec
                INDEX BY BINARY_INTEGER;

 Type terminate_in_cle_rec is RECORD (
   p_cle_id                   number ,
   p_line_number              okc_k_lines_v.line_number%type ,
   p_item_description         okc_k_lines_v.item_description%type ,
   p_dnz_chr_id               number ,
   p_sts_code                 okc_k_lines_v.sts_code%type ,
   p_date_terminated          okc_k_lines_v.date_terminated%type ,
   p_orig_end_date            date ,
   p_lse_id                   number  ,
   p_termination_date         date ,
   p_termination_reason       fnd_lookups.lookup_code%type );

 Type terminate_in_cle_tbl is table of terminate_in_cle_rec
                INDEX BY BINARY_INTEGER;

  l_rulv_rec OKC_RULE_PUB.rulv_rec_type;

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN        	CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN  		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_TERMINATE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  ---------------------------------------------------------------------------

FUNCTION is_k_term_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION is_kl_term_allowed(p_cle_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE terminate_chr( p_api_version                 IN  NUMBER,
		               p_init_msg_list               IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_rec 	IN terminate_in_parameters_rec
   	               );

PROCEDURE validate_chr( p_api_version                  IN  NUMBER,
		              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_terminate_in_parameters_rec  IN  terminate_in_parameters_rec
                      );

PROCEDURE terminate_cle( p_api_version                 IN  NUMBER,
		               p_init_msg_list               IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status               OUT NOCOPY VARCHAR2,
                         x_msg_count                   OUT NOCOPY NUMBER,
                         x_msg_data                    OUT NOCOPY VARCHAR2,
	                    p_terminate_in_parameters_rec IN  terminate_in_cle_rec
   	                  );


PROCEDURE validate_cle( p_api_version                  IN  NUMBER,
		              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_terminate_in_parameters_rec  IN  terminate_in_cle_rec);


END OKC_TERMINATE_PVT;

 

/
