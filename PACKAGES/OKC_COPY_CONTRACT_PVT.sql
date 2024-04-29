--------------------------------------------------------
--  DDL for Package OKC_COPY_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_COPY_CONTRACT_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCRCPYS.pls 120.2.12010000.3 2008/10/31 10:22:40 harchand ship $*/


    SUBTYPE chrv_rec_type IS		OKC_CONTRACT_PUB.chrv_rec_type;
    SUBTYPE chrv_tbl_type IS		OKC_CONTRACT_PUB.chrv_tbl_type;
    SUBTYPE clev_rec_type IS		OKC_CONTRACT_PUB.clev_rec_type;
    SUBTYPE clev_tbl_type IS		OKC_CONTRACT_PUB.clev_tbl_type;
    SUBTYPE cacv_rec_type IS		OKC_CONTRACT_PUB.cacv_rec_type;
    SUBTYPE cacv_tbl_type IS		OKC_CONTRACT_PUB.cacv_tbl_type;
    SUBTYPE cpsv_rec_type IS 		OKC_CONTRACT_PUB.cpsv_rec_type;
    SUBTYPE cpsv_tbl_type IS 		OKC_CONTRACT_PUB.cpsv_tbl_type;
    SUBTYPE rulv_rec_type IS 		OKC_RULE_PUB.rulv_rec_type;
    SUBTYPE rulv_tbl_type IS 		OKC_RULE_PUB.rulv_tbl_type;
    SUBTYPE rgpv_rec_type IS 		OKC_RULE_PUB.rgpv_rec_type;
    SUBTYPE rgpv_tbl_type IS 		OKC_RULE_PUB.rgpv_tbl_type;
    SUBTYPE rmpv_rec_type IS 		OKC_RULE_PUB.rmpv_rec_type;
    SUBTYPE rmpv_tbl_type IS 		OKC_RULE_PUB.rmpv_tbl_type;
    SUBTYPE catv_rec_type IS 		OKC_K_ARTICLE_PUB.catv_rec_type;
    SUBTYPE catv_tbl_type IS 		OKC_K_ARTICLE_PUB.catv_tbl_type;
    SUBTYPE atnv_rec_type IS 		OKC_K_ARTICLE_PUB.atnv_rec_type;
    SUBTYPE atnv_tbl_type IS 		OKC_K_ARTICLE_PUB.atnv_tbl_type;
    SUBTYPE cnhv_rec_type IS 		OKC_CONDITIONS_PUB.cnhv_rec_type;
    SUBTYPE cnhv_tbl_type IS 		OKC_CONDITIONS_PUB.cnhv_tbl_type;
    SUBTYPE cnlv_rec_type IS 		OKC_CONDITIONS_PUB.cnlv_rec_type;
    SUBTYPE cnlv_tbl_type IS 		OKC_CONDITIONS_PUB.cnlv_tbl_type;
    SUBTYPE cimv_rec_type IS 		OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    SUBTYPE cimv_tbl_type IS 		OKC_CONTRACT_ITEM_PUB.cimv_tbl_type;
    SUBTYPE cplv_rec_type IS 		OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    SUBTYPE cplv_tbl_type IS 		OKC_CONTRACT_PARTY_PUB.cplv_tbl_type;
    SUBTYPE cgcv_rec_type IS 		OKC_CONTRACT_GROUP_PUB.cgcv_rec_type;
    SUBTYPE cgcv_tbl_type IS 		OKC_CONTRACT_GROUP_PUB.cgcv_tbl_type;
    SUBTYPE ctcv_rec_type IS 		OKC_CONTRACT_PARTY_PUB.ctcv_rec_type;
    SUBTYPE ctcv_tbl_type IS 		OKC_CONTRACT_PARTY_PUB.ctcv_tbl_type;
    SUBTYPE tvev_rec_type IS 		OKC_TIMEVALUES_V%ROWTYPE;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQ';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_COPY_CONTRACT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  g_rulv_rec             rulv_rec_type;
  ---------------------------------------------------------------------------

  TYPE 	api_components_rec IS RECORD(id             NUMBER,
                                         to_k	        NUMBER,
                                         component_type VARCHAR2(30),
                                         attribute1     VARCHAR2(100));
  TYPE	api_components_tbl IS TABLE OF api_components_rec
  INDEX	BY BINARY_INTEGER;

  TYPE 	api_lines_rec IS RECORD(id             NUMBER,
                                    to_k           NUMBER,
                                    to_line        NUMBER,
							 lse_id         NUMBER,
                                    line_exists_yn VARCHAR2(1),
				    line_exp_yn VARCHAR2(1));  --Bug 3990643
  TYPE	api_lines_tbl IS TABLE OF api_lines_rec
  INDEX	BY BINARY_INTEGER;

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
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id	          	   IN NUMBER,
    p_contract_number		        IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2 DEFAULT 'N',
    p_copy_reference			   IN VARCHAR2 DEFAULT 'COPY',
    p_copy_line_party_yn              IN VARCHAR2,
    p_scs_code                     IN VARCHAR2,
    p_intent                       IN VARCHAR2,
    p_prospect                     IN VARCHAR2,
    p_components_tbl			   IN api_components_tbl,
    p_lines_tbl				   IN api_lines_tbl,
     x_chr_id                       OUT NOCOPY NUMBER,
    p_concurrent_request           IN VARCHAR2 DEFAULT 'N',
    p_include_cancelled_lines      IN VARCHAR2 DEFAULT 'Y',
    p_include_terminated_lines     IN VARCHAR2 DEFAULT 'Y');
 -- Bug 2950549 - Added  parameter p_concurrent_request in the above procedure


 PROCEDURE copy_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit        			   IN VARCHAR2 DEFAULT 'F',
    p_chr_id                       IN NUMBER,
    p_contract_number		     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    p_copy_lines_yn                IN VARCHAR2,
    p_override_org                 IN VARCHAR2 DEFAULT 'N',
    p_copy_from_history_yn         IN VARCHAR2 DEFAULT 'N',
    p_from_version_number          IN NUMBER DEFAULT NULL,
    p_copy_latest_articles         IN VARCHAR2 DEFAULT 'Y',
    p_calling_mode                 IN VARCHAR2 DEFAULT 'OKC',
    x_chr_id                       OUT NOCOPY NUMBER);

 PROCEDURE copy_contract_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_cle_id                  IN NUMBER,
    p_to_cle_id                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_to_chr_id                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_to_template_yn			   IN VARCHAR2,
    p_copy_reference               IN VARCHAR2,
    p_copy_line_party_yn           IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    p_generate_line_number         IN VARCHAR2   DEFAULT 'Y', -- Added for Bug 2489856
    x_cle_id		               OUT NOCOPY NUMBER,
    p_change_status		          IN  VARCHAR2 DEFAULT 'Y'); -- LLC Added additional flag parameter to the call
    												  -- to not allow change of status of sublines of the
												  -- topline during update service

 PROCEDURE copy_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_contract_number		   IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_scs_code                     IN VARCHAR2,
    p_intent                       IN VARCHAR2,
    p_prospect                     IN VARCHAR2,
    p_called_from                  IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    p_override_org                 IN VARCHAR2 DEFAULT 'N',
    p_calling_mode                 IN VARCHAR2 DEFAULT 'OKC',
    x_chr_id                       OUT NOCOPY NUMBER);

 PROCEDURE copy_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_cle_id                  IN NUMBER,
    p_from_chr_id                  IN NUMBER,
    p_to_cle_id                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_to_chr_id                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_lse_id                       IN NUMBER,
    p_to_template_yn		   IN VARCHAR2,
    p_copy_reference		   IN VARCHAR2 DEFAULT 'COPY',
    p_copy_line_party_yn           IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    p_generate_line_number         IN VARCHAR2   DEFAULT 'Y', -- Added for Bug 2489856
    x_cle_id		           OUT NOCOPY NUMBER,
    p_change_status		          IN  VARCHAR2 DEFAULT 'Y'); -- LLC Added additional flag parameter to the call
    												  -- to not allow change of status of sublines of the
												  -- topline during update service

  PROCEDURE copy_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_rle_code                     IN VARCHAR2,
    x_cpl_id		           OUT NOCOPY NUMBER);

  PROCEDURE copy_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_sav_sav_release              IN VARCHAR2 DEFAULT NULL,
    x_cat_id		               OUT NOCOPY NUMBER);

  PROCEDURE copy_latest_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    x_cat_id		               OUT NOCOPY NUMBER);

  PROCEDURE copy_events(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnh_id                  	   IN NUMBER,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_to_template_yn		   IN VARCHAR2,
    x_cnh_id		           OUT NOCOPY NUMBER);

  PROCEDURE copy_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_to_template_yn		   IN VARCHAR2,
    x_rgp_id		           OUT NOCOPY NUMBER);

  -- Bug 2950549 Added following 2 procedures add_concurrent and
--             copy_concurrent

 PROCEDURE add_concurrent(p_components_tbl   IN api_components_tbl,
     				     p_lines_tbl    IN api_lines_tbl,
					     p_from_chr_id  IN NUMBER,
						p_to_chr_id    IN NUMBER,
						p_contract_number IN VARCHAR2,
						p_contract_number_modifier IN VARCHAR2,
						p_to_template_yn IN VARCHAR2 DEFAULT 'N',
						p_copy_reference IN VARCHAR2 DEFAULT 'COPY',
						p_copy_line_party_yn IN VARCHAR2,
						p_scs_code     IN VARCHAR2,
						p_intent       IN VARCHAR2,
						p_prospect     IN VARCHAR,
						p_include_cancelled_lines IN VARCHAR2 DEFAULT 'Y', p_include_terminated_lines IN VARCHAR2 DEFAULT 'Y');

 PROCEDURE copy_concurrent(errbuf out NOCOPY VARCHAR2,
					   retcode out NOCOPY NUMBER,
					   p_id in NUMBER,
					   p_from_chr_id IN NUMBER,
					   p_to_chr_id IN NUMBER,
					   p_contract_number IN VARCHAR2,
					   p_contract_number_modifier IN VARCHAR2,
					   p_to_template_yn IN VARCHAR2,
					   p_copy_reference IN VARCHAR2,
					   p_copy_line_party_yn IN VARCHAR2,
					   p_scs_code IN VARCHAR2,
					   p_intent   IN VARCHAR2,
					   p_prospect IN VARCHAR2,
                                           p_copy_entire_k_yn IN VARCHAR2, /*hkamdar added new parameter for R12 copy enhancements.*/     p_include_cancelled_lines IN VARCHAR2 DEFAULT 'Y',
					   p_include_terminated_lines IN VARCHAR2 DEFAULT 'Y');
-- Bug 2950549 End of the procedures added

-- IKON ER 3819893
 PROCEDURE UPDATE_TEMPLATE_CONTRACT (p_api_version   IN NUMBER,
				     p_chr_id        IN NUMBER,
				     p_start_date    IN DATE,
				     p_end_date      IN DATE,
				     x_msg_count     OUT  NOCOPY  NUMBER,
				     x_msg_data      OUT   NOCOPY VARCHAR2,
                                     x_return_status OUT   NOCOPY VARCHAR2) ;



END OKC_COPY_CONTRACT_PVT;

/
