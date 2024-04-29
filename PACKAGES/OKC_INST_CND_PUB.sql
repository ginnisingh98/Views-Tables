--------------------------------------------------------
--  DDL for Package OKC_INST_CND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_INST_CND_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPINCS.pls 120.0 2005/05/25 22:42:55 appldev noship $ */

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
  SUBTYPE instcnd_inp_rec IS OKC_INST_CND_PVT.instcnd_inp_rec;

  ----------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ----------------------------------------------------------------------------
  g_pkg_name     CONSTANT varchar2(100) := 'OKC_INST_CND_PUB';
  g_app_name     CONSTANT varchar2(100) := OKC_API.G_APP_NAME;

  ----------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ----------------------------------------------------------------------------
  g_exception_halt_validation  EXCEPTION;

  ----------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ----------------------------------------------------------------------------
  g_fnd_app                     CONSTANT varchar2(200) := OKC_API.G_FND_APP;
  g_form_unable_to_reserve_rec  CONSTANT varchar2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  g_form_record_deleted         CONSTANT varchar2(200) := OKC_API.G_FORM_RECORD_DELETED;
  g_form_record_changed         CONSTANT varchar2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  g_record_logically_deleted    CONSTANT varchar2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  g_required_value              CONSTANT varchar2(200) := OKC_API.G_REQUIRED_VALUE;
  g_invalid_value      CONSTANT varchar2(200) := OKC_API.G_INVALID_VALUE;
  g_col_name_token     CONSTANT varchar2(200) := OKC_API.G_COL_NAME_TOKEN;
  g_parent_table_token CONSTANT varchar2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  g_child_table_token  CONSTANT varchar2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  g_unexpected_error   CONSTANT varchar2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  g_sqlerrm_token     CONSTANT varchar2(200) :=  'SQLerrm';
  g_sqlcode_token     CONSTANT varchar2(200) :=  'SQLcode';
  g_uppercase_required  CONSTANT varchar2(200) := 'OKC_UPPER_CASE_REQUIRED';

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
END OKC_INST_CND_PUB;

 

/
