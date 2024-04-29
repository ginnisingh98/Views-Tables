--------------------------------------------------------
--  DDL for Package OKS_RENCPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_RENCPY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRCPYS.pls 120.2 2005/09/27 14:32:40 anjkumar noship $*/

    SUBTYPE chrv_rec_type IS		OKC_CONTRACT_PUB.chrv_rec_type;
    SUBTYPE chrv_tbl_type IS		OKC_CONTRACT_PUB.chrv_tbl_type;
    SUBTYPE clev_rec_type IS		OKC_CONTRACT_PUB.clev_rec_type;
    SUBTYPE clev_tbl_type IS		OKC_CONTRACT_PUB.clev_tbl_type;
    SUBTYPE cacv_rec_type IS		OKC_CONTRACT_PUB.cacv_rec_type;
    SUBTYPE cacv_tbl_type IS		OKC_CONTRACT_PUB.cacv_tbl_type;
    SUBTYPE cpsv_rec_type IS 		OKC_CONTRACT_PUB.cpsv_rec_type;
    SUBTYPE cpsv_tbl_type IS 		OKC_CONTRACT_PUB.cpsv_tbl_type;
    SUBTYPE klnv_rec_type IS 		OKS_KLN_PVT.klnv_rec_type;
    --SUBTYPE klnv_tbl_type IS 		OKS_KLN_PVT.klnv_tbl_type;
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
    G_PROGRAM_NAME		CONSTANT VARCHAR2(200) := 'OKS_RENCPY_PVT';
    G_OKS_APP_NAME        CONSTANT VARCHAR2(3) := 'OKS'; --all new nessages should use this

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
    G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_COPY_CONTRACT_PVT';
    G_APP_NAME			CONSTANT VARCHAR2(3) := OKC_API.G_APP_NAME;
    g_klnv_rec                    klnv_rec_type;
  ---------------------------------------------------------------------------

    TYPE 	api_components_rec IS RECORD(id             NUMBER,
                                          to_k	        NUMBER,
                                          component_type VARCHAR2(30),
                                          attribute1     VARCHAR2(100));

    TYPE	api_components_tbl IS TABLE OF api_components_rec INDEX	BY BINARY_INTEGER;

    TYPE 	api_lines_rec IS RECORD(id             NUMBER,
                                     to_k           NUMBER,
                                     to_line        NUMBER,
                                     lse_id         NUMBER,
                                     line_exists_yn VARCHAR2(1));

    TYPE	api_lines_tbl IS TABLE OF api_lines_rec INDEX	BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------


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
        p_to_template_yn			   IN VARCHAR2,
        p_copy_reference			   IN VARCHAR2 DEFAULT 'COPY',
        p_copy_line_party_yn              IN VARCHAR2,
        p_renew_ref_yn                 IN VARCHAR2,
        p_need_conversion              IN VARCHAR2 DEFAULT 'N',
        x_cle_id		           OUT NOCOPY NUMBER);

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
        x_cat_id		           OUT NOCOPY NUMBER);


    PROCEDURE copy_rules(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_old_cle_id                   IN NUMBER,
        p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
        p_chr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
        p_cust_acct_id                 IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
        p_bill_to_site_use_id          IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
        p_to_template_yn			   IN VARCHAR2);


    PROCEDURE create_trxn_extn(
        p_api_version                   IN NUMBER,
        p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2,
        p_old_trx_ext_id                IN NUMBER,
        p_order_id                      IN NUMBER,
        p_cust_acct_id                  IN NUMBER,
        p_bill_to_site_use_id           IN NUMBER,
        x_trx_ext_id                    OUT NOCOPY NUMBER);

END OKS_RENCPY_PVT;


 

/
