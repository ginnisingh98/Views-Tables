--------------------------------------------------------
--  DDL for Package OKC_CONDITION_EVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONDITION_EVAL_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPCEVS.pls 120.0 2005/05/25 18:43:31 appldev noship $ */

 subtype cnhv_rec_type is okc_cnh_pvt.cnhv_rec_type;
 subtype cnhv_tbl_type is okc_cnh_pvt.cnhv_tbl_type;
 subtype cnlv_rec_type is okc_cnl_pvt.cnlv_rec_type;
 subtype cnlv_tbl_type is okc_cnl_pvt.cnlv_tbl_type;
 subtype coev_rec_type is okc_coe_pvt.coev_rec_type;
 subtype coev_tbl_type is okc_coe_pvt.coev_tbl_type;
 subtype acnv_rec_type is okc_acn_pvt.acnv_rec_type;
 subtype acnv_tbl_type is okc_acn_pvt.acnv_tbl_type;
 subtype aaev_rec_type is okc_aae_pvt.aaev_rec_type;
 subtype aaev_tbl_type is okc_aae_pvt.aaev_tbl_type;
 subtype aavv_rec_type is okc_aav_pvt.aavv_rec_type;
 subtype aavv_tbl_type is okc_aav_pvt.aavv_tbl_type;
 subtype aalv_rec_type is okc_aal_pvt.aalv_rec_type;
 subtype aalv_tbl_type is okc_aal_pvt.aalv_tbl_type;
 subtype fepv_rec_type is okc_fep_pvt.fepv_rec_type;
 subtype fepv_tbl_type is okc_fep_pvt.fepv_tbl_type;
 subtype pdfv_rec_type is okc_pdf_pvt.pdfv_rec_type;
 subtype pdfv_tbl_type is okc_pdf_pvt.pdfv_tbl_type;
 subtype pdpv_rec_type is okc_pdp_pvt.pdpv_rec_type;
 subtype pdpv_tbl_type is okc_pdp_pvt.pdpv_tbl_type;
 subtype id_tab_type   is okc_condition_eval_pvt.id_tab_type;
 subtype exec_tab_type is okc_condition_eval_pvt.exec_tab_type;
 subtype outcome_tab_type is okc_condition_eval_pvt.outcome_tab_type;

 ----------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_CONDITION_EVAL_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ----------------------------------------------------------------------------------
  --Global Exception
 ----------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ----------------------------------------------------------------------------------
 -- GLOBAL DATASTRUCTURES
 ----------------------------------------------------------------------------------
 -- TYPES
 -----------------------------------------------------------------------------------

-- Bug 2217934 This procedure evaluates condition attached to a plan
-- Input is condition id p_cnh_id and p_msg_tab.
-- Output is x_sync_outcome_tab containing the table of outcomes.
 PROCEDURE evaluate_plan_condition (
     p_api_version           IN NUMBER,
     p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     p_cnh_id                IN okc_condition_headers_b.id%TYPE,
     p_msg_tab               IN okc_aq_pvt.msg_tab_typ,
     x_sync_outcome_tab      OUT NOCOPY okc_condition_eval_pub.outcome_tab_type
    );

 -- this procedure is overloaded to handle sync and async events. For sync events
 -- an out parameter of table type 'x_outcome_tab' is returned to the calling API
 PROCEDURE evaluate_condition (
     p_api_version           IN NUMBER,
     p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     p_acn_id                IN okc_actions_b.id%TYPE,
     p_msg_tab               IN okc_aq_pvt.msg_tab_typ,
     x_sync_outcome_tab      OUT NOCOPY okc_condition_eval_pub.outcome_tab_type
    );



 PROCEDURE evaluate_condition (
     p_api_version           IN NUMBER,
     p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     p_acn_id                IN okc_actions_b.id%TYPE,
     p_msg_tab               IN okc_aq_pvt.msg_tab_typ
    );

 PROCEDURE evaluate_date_condition (
     p_api_version           IN NUMBER,
     p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     p_cnh_id                IN okc_condition_headers_b.id%TYPE,
     p_msg_tab               IN okc_aq_pvt.msg_tab_typ
    );

END okc_condition_eval_pub;

 

/
