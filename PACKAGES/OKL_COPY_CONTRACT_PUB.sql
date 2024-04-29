--------------------------------------------------------
--  DDL for Package OKL_COPY_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_COPY_CONTRACT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCOPS.pls 120.2 2005/10/14 19:35:19 apaul noship $ */

    SUBTYPE chrv_rec_type IS		OKL_COPY_CONTRACT_PVT.chrv_rec_type;
    SUBTYPE chrv_tbl_type IS		OKL_COPY_CONTRACT_PVT.chrv_tbl_type;
    SUBTYPE clev_rec_type IS		OKL_COPY_CONTRACT_PVT.clev_rec_type;
    SUBTYPE clev_tbl_type IS		OKL_COPY_CONTRACT_PVT.clev_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			                 CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	     CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		         CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		         CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		             CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		             CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		             CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		         CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		         CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR                 CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN                    CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN                    CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		         CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQ';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_COPY_CONTRACT_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------


  SUBTYPE	api_components_tbl IS OKL_COPY_CONTRACT_PVT.api_components_tbl;
  SUBTYPE	api_lines_tbl      IS OKL_COPY_CONTRACT_PVT.api_lines_tbl;


  FUNCTION update_target_contract(p_chr_id IN NUMBER) RETURN BOOLEAN;
  FUNCTION is_copy_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;
  FUNCTION is_subcontract_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;

  PROCEDURE derive_line_style(p_old_lse_id     IN  NUMBER,
                              p_old_jtot_code  IN  VARCHAR2,
                              p_new_subclass   IN  VARCHAR2,
                              p_new_parent_lse IN  NUMBER,
                              x_new_lse_count  OUT NOCOPY NUMBER,
                              x_new_lse_ids    OUT NOCOPY VARCHAR2);

 PROCEDURE copy_components(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id	          	       IN NUMBER,
    p_contract_number		       IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2 DEFAULT 'N',
    p_copy_reference			   IN VARCHAR2 DEFAULT 'COPY',
    p_copy_line_party_yn           IN VARCHAR2,
    p_scs_code                     IN VARCHAR2,
    p_intent                       IN VARCHAR2,
    p_prospect                     IN VARCHAR2,
    p_components_tbl			   IN api_components_tbl,
    p_lines_tbl				       IN api_lines_tbl,
    x_chr_id                       OUT NOCOPY NUMBER);

 PROCEDURE copy_lease_contract(
            p_api_version              IN  NUMBER,
            p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status            OUT NOCOPY VARCHAR2,
            x_msg_count                OUT NOCOPY NUMBER,
            x_msg_data                 OUT NOCOPY VARCHAR2,
            p_commit                   IN  VARCHAR2 DEFAULT 'F',
            p_chr_id                   IN  NUMBER,
            p_contract_number	       IN  VARCHAR2,
            p_contract_number_modifier IN  VARCHAR2,
            p_to_template_yn	       IN  VARCHAR2 DEFAULT 'N',
            p_renew_ref_yn             IN  VARCHAR2,
            p_override_org	       IN  VARCHAR2 DEFAULT 'N',
            p_trans_type               IN  VARCHAR2,
            x_chr_id                   OUT NOCOPY NUMBER);

 PROCEDURE copy_lease_contract(
            p_api_version              IN  NUMBER,
            p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status            OUT NOCOPY VARCHAR2,
            x_msg_count                OUT NOCOPY NUMBER,
            x_msg_data                 OUT NOCOPY VARCHAR2,
            p_commit                   IN  VARCHAR2 DEFAULT 'F',
            p_chr_id                   IN  NUMBER,
            p_contract_number	       IN  VARCHAR2,
            p_contract_number_modifier IN  VARCHAR2,
            p_to_template_yn	       IN  VARCHAR2 DEFAULT 'N',
            p_renew_ref_yn             IN  VARCHAR2,
            p_copy_lines_yn            IN  VARCHAR2,
            p_override_org	           IN  VARCHAR2 DEFAULT 'N',
            p_trans_type               IN  VARCHAR2,
            x_chr_id                   OUT NOCOPY NUMBER);

 PROCEDURE copy_lease_contract_new(
            p_api_version              IN  NUMBER,
            p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status            OUT NOCOPY VARCHAR2,
            x_msg_count                OUT NOCOPY NUMBER,
            x_msg_data                 OUT NOCOPY VARCHAR2,
            p_commit                   IN  VARCHAR2 DEFAULT 'F',
            p_chr_id                   IN  NUMBER,
            p_contract_number	       IN  VARCHAR2,
            p_contract_number_modifier IN  VARCHAR2,
            p_to_template_yn	       IN  VARCHAR2 DEFAULT 'N',
            p_renew_ref_yn             IN  VARCHAR2,
            p_override_org	       IN  VARCHAR2 DEFAULT 'N',
            p_trans_type               IN  VARCHAR2,
            x_chr_id                   OUT NOCOPY NUMBER,
            p_rbk_date                 IN  DATE DEFAULT NULL);

 PROCEDURE copy_lease_contract_new(
            p_api_version              IN  NUMBER,
            p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status            OUT NOCOPY VARCHAR2,
            x_msg_count                OUT NOCOPY NUMBER,
            x_msg_data                 OUT NOCOPY VARCHAR2,
            p_commit                   IN  VARCHAR2 DEFAULT 'F',
            p_chr_id                   IN  NUMBER,
            p_contract_number	       IN  VARCHAR2,
            p_contract_number_modifier IN  VARCHAR2,
            p_to_template_yn	       IN  VARCHAR2 DEFAULT 'N',
            p_renew_ref_yn             IN  VARCHAR2,
            p_copy_lines_yn            IN  VARCHAR2,
            p_override_org	           IN  VARCHAR2 DEFAULT 'N',
            p_trans_type               IN  VARCHAR2,
            x_chr_id                   OUT NOCOPY NUMBER);

 PROCEDURE copy_contract(
            p_api_version                  	IN NUMBER,
    		p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    		x_return_status                	OUT NOCOPY VARCHAR2,
    		x_msg_count                    	OUT NOCOPY NUMBER,
    		x_msg_data                     	OUT NOCOPY VARCHAR2,
    		p_commit             	       	IN VARCHAR2 DEFAULT 'F',
    		p_chr_id                       	IN NUMBER,
    		p_contract_number	        	IN VARCHAR2,
    		p_contract_number_modifier      IN VARCHAR2,
    		p_to_template_yn		        IN VARCHAR2 DEFAULT 'N',
    		p_renew_ref_yn                 	IN VARCHAR2,
    		p_override_org                 	IN VARCHAR2 DEFAULT 'N',
    		x_chr_id                       	OUT NOCOPY NUMBER);

 PROCEDURE copy_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit        			   IN VARCHAR2 DEFAULT 'F',
    p_chr_id                       IN NUMBER,
    p_contract_number		       IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2 DEFAULT 'N',
    p_renew_ref_yn                 IN VARCHAR2,
    p_copy_lines_yn                IN VARCHAR2,
    p_override_org		           IN VARCHAR2 DEFAULT 'N',
    x_chr_id                       OUT NOCOPY NUMBER);

   PROCEDURE copy_contract_lines(
    	p_api_version                  IN NUMBER,
    	p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    	x_return_status                OUT NOCOPY VARCHAR2,
    	x_msg_count                    OUT NOCOPY NUMBER,
    	x_msg_data                     OUT NOCOPY VARCHAR2,
    	p_from_cle_id                  IN NUMBER,
    	p_to_cle_id                    IN NUMBER,
    	p_to_chr_id                    IN NUMBER,
    	p_to_template_yn	           IN VARCHAR2,
    	p_copy_reference	           IN VARCHAR2,
    	p_copy_line_party_yn           IN VARCHAR2,
    	p_renew_ref_yn                 IN VARCHAR2,
    	x_cle_id		               OUT NOCOPY NUMBER);

  PROCEDURE copy_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_to_template_yn			   IN VARCHAR2,
    x_rgp_id		               OUT NOCOPY NUMBER);

  PROCEDURE copy_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    P_rle_code                     IN VARCHAR2,
    x_cpl_id		               OUT NOCOPY NUMBER);

  PROCEDURE copy_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_sav_sav_release		       IN VARCHAR2 DEFAULT NULL,
    x_cat_id		               OUT NOCOPY NUMBER);

  PROCEDURE copy_latest_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    x_cat_id		           	   OUT NOCOPY NUMBER);

END okl_copy_contract_pub;

 

/
