--------------------------------------------------------
--  DDL for Package OKC_COPY_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_COPY_CONTRACT_PUB" AUTHID CURRENT_USER AS
/*$Header: OKCPCPYS.pls 120.2.12010000.2 2008/10/24 08:01:17 ssreekum ship $*/

    SUBTYPE chrv_rec_type IS		OKC_COPY_CONTRACT_PVT.chrv_rec_type;
    SUBTYPE chrv_tbl_type IS		OKC_COPY_CONTRACT_PVT.chrv_tbl_type;
    SUBTYPE clev_rec_type IS		OKC_COPY_CONTRACT_PVT.clev_rec_type;
    SUBTYPE clev_tbl_type IS		OKC_COPY_CONTRACT_PVT.clev_tbl_type;
    SUBTYPE cacv_rec_type IS		OKC_COPY_CONTRACT_PVT.cacv_rec_type;
    SUBTYPE cacv_tbl_type IS		OKC_COPY_CONTRACT_PVT.cacv_tbl_type;
    SUBTYPE cpsv_rec_type IS 		OKC_COPY_CONTRACT_PVT.cpsv_rec_type;
    SUBTYPE cpsv_tbl_type IS 		OKC_COPY_CONTRACT_PVT.cpsv_tbl_type;
    SUBTYPE rulv_rec_type IS 		OKC_COPY_CONTRACT_PVT.rulv_rec_type;
    SUBTYPE rulv_tbl_type IS 		OKC_COPY_CONTRACT_PVT.rulv_tbl_type;
    SUBTYPE rgpv_rec_type IS 		OKC_COPY_CONTRACT_PVT.rgpv_rec_type;
    SUBTYPE rgpv_tbl_type IS 		OKC_COPY_CONTRACT_PVT.rgpv_tbl_type;
    SUBTYPE catv_rec_type IS 		OKC_COPY_CONTRACT_PVT.catv_rec_type;
    SUBTYPE catv_tbl_type IS 		OKC_COPY_CONTRACT_PVT.catv_tbl_type;
    SUBTYPE cnhv_rec_type IS 		OKC_COPY_CONTRACT_PVT.cnhv_rec_type;
    SUBTYPE cnhv_tbl_type IS 		OKC_COPY_CONTRACT_PVT.cnhv_tbl_type;
    SUBTYPE cnlv_rec_type IS 		OKC_COPY_CONTRACT_PVT.cnlv_rec_type;
    SUBTYPE cnlv_tbl_type IS 		OKC_COPY_CONTRACT_PVT.cnlv_tbl_type;
    SUBTYPE cimv_rec_type IS 		OKC_COPY_CONTRACT_PVT.cimv_rec_type;
    SUBTYPE cimv_tbl_type IS 		OKC_COPY_CONTRACT_PVT.cimv_tbl_type;
    SUBTYPE cplv_rec_type IS 		OKC_COPY_CONTRACT_PVT.cplv_rec_type;
    SUBTYPE cplv_tbl_type IS 		OKC_COPY_CONTRACT_PVT.cplv_tbl_type;
    SUBTYPE cgcv_rec_type IS 		OKC_COPY_CONTRACT_PVT.cgcv_rec_type;
    SUBTYPE cgcv_tbl_type IS 		OKC_CONTRACT_GROUP_PUB.cgcv_tbl_type;


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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_COPY_CONTRACT_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------


  SUBTYPE	api_components_tbl IS OKC_COPY_CONTRACT_PVT.api_components_tbl;
  SUBTYPE	api_lines_tbl      IS OKC_COPY_CONTRACT_PVT.api_lines_tbl;


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
    p_to_chr_id	          	IN NUMBER,
    p_contract_number		     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			IN VARCHAR2 DEFAULT 'N',
    p_copy_reference			IN VARCHAR2 DEFAULT 'COPY',
    p_copy_line_party_yn           IN VARCHAR2,
    p_scs_code                     IN VARCHAR2,
    p_intent                       IN VARCHAR2,
    p_prospect                     IN VARCHAR2,
    p_components_tbl			IN api_components_tbl,
    p_lines_tbl				IN api_lines_tbl,
     x_chr_id                       OUT NOCOPY NUMBER,
    p_concurrent_request           IN VARCHAR2 DEFAULT 'N',
    p_include_cancelled_lines      IN VARCHAR2 DEFAULT 'Y',
    p_include_terminated_lines     IN VARCHAR2 DEFAULT 'Y');
-- Bug 2950549 - Added 1 more parameter p_concurrent_request in the
-- above procedure.

 PROCEDURE copy_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit        			IN VARCHAR2 DEFAULT 'F',
    p_chr_id                       IN NUMBER,
    p_contract_number		     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			IN VARCHAR2 DEFAULT 'N',
    p_renew_ref_yn                 IN VARCHAR2 DEFAULT 'N',
    p_copy_from_history_yn         IN VARCHAR2 DEFAULT 'N',
    p_from_version_number          IN NUMBER  DEFAULT NULL,
    p_copy_latest_articles         IN VARCHAR2 DEFAULT 'Y',
    p_calling_mode                 IN VARCHAR2 DEFAULT 'OKC',
    x_chr_id                       OUT NOCOPY NUMBER);

 PROCEDURE copy_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit        			   IN VARCHAR2 DEFAULT 'F',
    p_chr_id                       IN NUMBER,
    p_contract_number		   IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2 DEFAULT 'N',
    p_renew_ref_yn                 IN VARCHAR2 DEFAULT 'N',
    p_copy_lines_yn                IN VARCHAR2,
    p_override_org                 IN VARCHAR2 DEFAULT 'N',
    p_copy_from_history_yn         IN VARCHAR2 DEFAULT 'N',
    p_from_version_number          IN NUMBER DEFAULT NULL,
    p_copy_latest_articles         IN VARCHAR2 DEFAULT 'Y',
    p_calling_mode                 IN VARCHAR2 DEFAULT 'OKC',
    x_chr_id                       OUT NOCOPY NUMBER);


 -- LLC Added additional flag parameter to the call to not allow
 -- change of status of sublines of the topline during update service

 PROCEDURE copy_contract_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_cle_id                  IN NUMBER,
    p_to_cle_id                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_to_chr_id                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_to_template_yn			   IN VARCHAR2 DEFAULT 'N',
    p_copy_reference               IN VARCHAR2 DEFAULT 'COPY',
    p_copy_line_party_yn           IN VARCHAR2 DEFAULT 'Y',
    p_renew_ref_yn                 IN VARCHAR2 DEFAULT 'N',
    x_cle_id		           OUT NOCOPY NUMBER,
    p_change_status		          IN  VARCHAR2 DEFAULT 'Y');

  PROCEDURE copy_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_to_template_yn			   IN VARCHAR2,
    x_rgp_id		           OUT NOCOPY NUMBER);

  PROCEDURE copy_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_id                  	IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    P_rle_code                     IN VARCHAR2,
    x_cpl_id		           	OUT NOCOPY NUMBER);

  PROCEDURE copy_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_sav_sav_release		     IN VARCHAR2 DEFAULT NULL,
    x_cat_id		           	OUT NOCOPY NUMBER);

  PROCEDURE copy_latest_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    x_cat_id		           	OUT NOCOPY NUMBER);

    -- Bug 2950549 - Added this procedure
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
						 p_copy_entire_k_yn IN VARCHAR2,/* hkamdar R12 copy project*/				p_include_cancelled_lines IN VARCHAR2,
					p_include_terminated_lines IN VARCHAR2);
   -- Bug 2950549 End of the procedure

   -- IKON ER 3819893
    PROCEDURE UPDATE_TEMPLATE_CONTRACT (p_api_version   IN NUMBER,
                                     p_init_msg_list IN VARCHAR2,
                                     p_chr_id        IN NUMBER,
                                     p_start_date    IN DATE,
				     p_end_date      IN DATE,
				     x_msg_count     OUT  NOCOPY  NUMBER,
				     x_msg_data      OUT   NOCOPY VARCHAR2,
                                     x_return_status OUT   NOCOPY VARCHAR2) ;

END OKC_COPY_CONTRACT_PUB;

/
