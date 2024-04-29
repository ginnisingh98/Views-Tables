--------------------------------------------------------
--  DDL for Package OKL_QA_CHECK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QA_CHECK_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPQAKS.pls 120.2 2007/05/15 17:44:30 asahoo ship $ */

  TYPE msg_rec_type IS RECORD (
      severity                OKC_QA_LIST_PROCESSES_V.SEVERITY%TYPE,
      name                    OKC_PROCESS_DEFS_V.NAME%TYPE,
      description             OKC_PROCESS_DEFS_V.DESCRIPTION%TYPE,
      package_name            OKC_PROCESS_DEFS_V.PACKAGE_NAME%TYPE,
      procedure_name          OKC_PROCESS_DEFS_V.PROCEDURE_NAME%TYPE,
      error_status            VARCHAR2(1),
      data                    VARCHAR2(2000));

  TYPE msg_tbl_type is TABLE of msg_rec_type
       INDEX BY BINARY_INTEGER;
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
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPERCASE_REQUIRED';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_QA_CHECK_PUB';
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
    x_msg_tbl                      OUT NOCOPY msg_tbl_type,
    p_call_mode                    IN  VARCHAR2 DEFAULT 'ACTUAL');

END OKL_QA_CHECK_PUB;

/
