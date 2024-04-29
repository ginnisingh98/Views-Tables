--------------------------------------------------------
--  DDL for Package OKC_CONDITION_EVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONDITION_EVAL_PVT" AUTHID CURRENT_USER as
/* $Header: OKCRCEVS.pls 120.0 2005/05/26 09:35:53 appldev noship $ */

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

 ----------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_CONDITION_EVAL_PVT';
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
 -- declaring record type
    TYPE id_rec_type IS RECORD (
    v_id             NUMBER
    );
    TYPE exec_rec_type IS RECORD (
    name             VARCHAR2(500)
    );
    TYPE outcome_rec_type IS RECORD (
    type             okc_process_defs_b.pdf_type%TYPE,
    name             VARCHAR2(32000)
    );
 -- declaring table of record type
    TYPE id_tab_type IS TABLE OF id_rec_type;
    TYPE exec_tab_type IS TABLE OF exec_rec_type;
    TYPE outcome_tab_type IS TABLE OF outcome_rec_type;
 -----------------------------------------------------------------------------------
 -- This procedure is overloaded to handle synch and asynch events.
 -- For synch events there is out parameter which returns
 -- a table of outcomes to calling program. For date based actions
 -- the evaluator accepts condition header id.

 -- Evaluate single plan
 PROCEDURE evaluate_plan_condition(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnh_id                IN  okc_condition_headers_b.id%TYPE,
    p_msg_tab               IN  okc_aq_pvt.msg_tab_typ,
    x_sync_outcome_tab      OUT NOCOPY okc_condition_eval_pvt.outcome_tab_type
    );


 -- Evaluator for asynchronous actions
 PROCEDURE evaluate_condition(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acn_id                IN  okc_actions_b.id%TYPE,
    p_msg_tab               IN  okc_aq_pvt.msg_tab_typ,
    x_sync_outcome_tab      OUT NOCOPY okc_condition_eval_pvt.outcome_tab_type
    );

 -- Evaluator for standard and counter actions
 PROCEDURE evaluate_condition(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acn_id                IN okc_actions_b.id%TYPE,
    p_msg_tab               IN okc_aq_pvt.msg_tab_typ
    );

 -- Evaluator for date based actions
 PROCEDURE evaluate_date_condition(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnh_id                IN okc_condition_headers_b.id%TYPE,
    p_msg_tab               IN okc_aq_pvt.msg_tab_typ
    );


END okc_condition_eval_pvt;

 

/
