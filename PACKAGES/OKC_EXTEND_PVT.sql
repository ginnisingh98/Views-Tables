--------------------------------------------------------
--  DDL for Package OKC_EXTEND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_EXTEND_PVT" AUTHID CURRENT_USER as
/* $Header: OKCREXTS.pls 120.0 2005/05/25 22:35:38 appldev noship $ */

   Type extend_in_parameters_rec is RECORD (
            p_contract_id              number,
            p_contract_number          okc_k_headers_v.contract_number%type,
            p_contract_modifier        okc_k_headers_v.contract_number_modifier%type,
            p_contract_version         varchar2(9),
            p_object_version_number    number,
            p_orig_start_date          date,
            p_orig_end_date            date,
            p_end_date                 date,
            p_uom_code                 okx_units_of_measure_v.uom_code%type ,
            p_duration                 number,
            p_perpetual_flag           Varchar2(1) DEFAULT OKC_API.G_FALSE);

 TYPE extend_in_parameters_tbl is TABLE of extend_in_parameters_rec
                INDEX BY BINARY_INTEGER;

 TYPE extend_in_cle_rec is RECORD (
           p_cle_id                  number,
           p_line_number             okc_k_lines_v.line_number%type,
           p_item_description        okc_k_lines_v.item_description%type,
           p_dnz_chr_id              number,
           p_object_version_number   number,
           p_orig_start_date         date,
           p_orig_end_date           date,
           p_end_date                date,
           p_uom_code                okx_units_of_measure_v.uom_code%type,
           p_duration                number,
           p_perpetual_flag          Varchar2(1) DEFAULT OKC_API.G_FALSE);

 TYPE extend_in_cle_tbl is TABLE of extend_in_cle_rec
                INDEX BY BINARY_INTEGER;

 g_rulv_rec OKC_RULE_PUB.rulv_rec_type;

 g_lines_count number := 0; -- this is used for header validation. enforces header validation
                           -- only once even if several lines are passed

  g_called_from varchar2(15) := 'HEADER';

 -- GLOBAL VARIABLES
  -------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN        	  CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN  		       CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			       CONSTANT VARCHAR2(200) := 'OKC_EXTEND_PVT';
  G_APP_NAME			       CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_FND_APP			       CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC  CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  ---------------------------------------------------------------------------------------------

FUNCTION is_k_extend_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION is_kl_extend_allowed(p_cle_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE extend_chr( p_api_version                 IN NUMBER,
  		            p_init_msg_list               IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status               OUT NOCOPY VARCHAR2,
                      x_msg_count                   OUT NOCOPY NUMBER,
                      x_msg_data                    OUT NOCOPY VARCHAR2,
	                 p_extend_in_parameters_rec 	  IN extend_in_parameters_rec
	               );

PROCEDURE validate_chr( p_api_version                  IN NUMBER,
		              p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_rec 	IN extend_in_parameters_rec
				   );

PROCEDURE extend_cle( p_api_version               IN  NUMBER,
		            p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status             OUT NOCOPY VARCHAR2,
                      x_msg_count                 OUT NOCOPY NUMBER,
                      x_msg_data                  OUT NOCOPY VARCHAR2,
	                 p_extend_in_parameters_rec	IN extend_in_cle_rec
	               );

PROCEDURE validate_cle( p_api_version                  IN NUMBER,
		              p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                   p_extend_in_parameters_rec 	IN  extend_in_cle_rec
				   );


END OKC_EXTEND_PVT;

 

/
