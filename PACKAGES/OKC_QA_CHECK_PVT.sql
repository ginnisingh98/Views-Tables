--------------------------------------------------------
--  DDL for Package OKC_QA_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_QA_CHECK_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRQACS.pls 120.0 2005/05/25 22:43:28 appldev noship $ */
  TYPE qa_msg_rec_type IS RECORD (
        severity                OKC_QA_LIST_PROCESSES_V.SEVERITY%TYPE,
        name                    OKC_PROCESS_DEFS_V.NAME%TYPE,
        description             OKC_PROCESS_DEFS_V.DESCRIPTION%TYPE,
        package_name            OKC_PROCESS_DEFS_V.PACKAGE_NAME%TYPE,
        procedure_name          OKC_PROCESS_DEFS_V.PROCEDURE_NAME%TYPE,
      	error_status            VARCHAR2(1),
        data                    VARCHAR2(2000)
  );

  TYPE qa_msg_tbl_type IS TABLE OF qa_msg_rec_type
  	INDEX BY BINARY_INTEGER;

  pub_qa_msg_tbl qa_msg_tbl_type;

--  subtype msg_tbl_type is OKC_API.MSG_TBL_TYPE;
  subtype msg_tbl_type is qa_msg_tbl_type;

TYPE parameter_type IS RECORD (
        param_value varchar2(150));

Type parameter_tbl_type is table of parameter_type INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_DEFAULT_QA_CHECK_LIST	CONSTANT VARCHAR2(200) := 'DEFAULT QA CHECK LIST';
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
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
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPERCASE_REQUIRED';
  G_QA_PROCESS_ERROR		CONSTANT VARCHAR2(200) := 'OKC_QA_PROCESS_ERROR';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_QA_CHECK_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    p_override_flag                IN  VARCHAR2 DEFAULT 'N',
    x_msg_tbl                      OUT NOCOPY msg_tbl_type);

END OKC_QA_CHECK_PVT;

 

/
