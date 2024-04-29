--------------------------------------------------------
--  DDL for Package OKC_INST_CND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_INST_CND_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRINCS.pls 120.0 2005/05/25 18:39:17 appldev noship $ */

/***********************  HAND-CODED  ***************************************/
  ----------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ----------------------------------------------------------------------------

  SUBTYPE cnhv_rec_type IS OKC_CONDITIONS_PUB.cnhv_rec_type;
  SUBTYPE cnhv_tbl_type IS OKC_CONDITIONS_PUB.cnhv_tbl_type;
  SUBTYPE cnlv_rec_type IS OKC_CONDITIONS_PUB.cnlv_rec_type;
  SUBTYPE cnlv_tbl_type IS OKC_CONDITIONS_PUB.cnlv_tbl_type;
  SUBTYPE coev_rec_type IS OKC_CONDITIONS_PUB.coev_rec_type;
  SUBTYPE coev_tbl_type IS OKC_CONDITIONS_PUB.coev_tbl_type;
  SUBTYPE aavv_rec_type IS OKC_CONDITIONS_PUB.aavv_rec_type;
  SUBTYPE aavv_tbl_type IS OKC_CONDITIONS_PUB.aavv_tbl_type;
  SUBTYPE aalv_rec_type IS OKC_CONDITIONS_PUB.aalv_rec_type;
  SUBTYPE aalv_tbl_type IS OKC_CONDITIONS_PUB.aalv_tbl_type;
  SUBTYPE fepv_rec_type IS OKC_CONDITIONS_PUB.fepv_rec_type;
  SUBTYPE fepv_tbl_type IS OKC_CONDITIONS_PUB.fepv_tbl_type;
  SUBTYPE ocev_rec_type IS OKC_OUTCOME_PUB.ocev_rec_type;
  SUBTYPE ocev_tbl_type IS OKC_OUTCOME_PUB.ocev_tbl_type;
  SUBTYPE oatv_rec_type IS OKC_OUTCOME_PUB.oatv_rec_type;
  SUBTYPE oatv_tbl_type IS OKC_OUTCOME_PUB.oatv_tbl_type;
  ----------------------------------------------------------------------------
  -- RECORD TYPE DECLARATION
  ----------------------------------------------------------------------------
  TYPE INSTCND_INP_REC IS RECORD
  ( chr_id                NUMBER,
    cle_id                NUMBER,
    inv_item_id           NUMBER,
    jtot_object_code      OKC_CONDITION_HEADERS_B.JTOT_OBJECT_CODE%TYPE,
    tmp_ctr_grp_id        NUMBER,
    ins_ctr_grp_id        NUMBER
    );

  ----------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ----------------------------------------------------------------------------
  g_pkg_name     CONSTANT varchar2(100) := 'OKC_INST_CND_PVT';
  g_app_name     CONSTANT varchar2(3)   :=  OKC_API.G_APP_NAME;
  g_unexpected_error CONSTANT varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token    CONSTANT varchar2(200) := 'SQLerrm';
  g_sqlcode_token    CONSTANT varchar2(200) := 'SQLcode';

  ----------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ----------------------------------------------------------------------------
  g_exception_halt_validation      EXCEPTION;


  ----------------------------------------------------------------------------
  -- PROCEDURE inst_condition
  ----------------------------------------------------------------------------
  PROCEDURE inst_condition(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_instcnd_inp_rec              IN  INSTCND_INP_REC);

END OKC_INST_CND_PVT;

 

/
