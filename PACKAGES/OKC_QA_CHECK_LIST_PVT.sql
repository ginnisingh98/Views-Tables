--------------------------------------------------------
--  DDL for Package OKC_QA_CHECK_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_QA_CHECK_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCQCLS.pls 120.0 2005/05/25 22:34:52 appldev noship $ */

  -- simple entity object subtype definitions
  subtype qclv_rec_type is OKC_QCL_PVT.qclv_rec_type;
  subtype qclv_tbl_type is OKC_QCL_PVT.qclv_tbl_type;
  subtype qlpv_rec_type is OKC_QLP_PVT.qlpv_rec_type;
  subtype qlpv_tbl_type is OKC_QLP_PVT.qlpv_tbl_type;
  subtype qppv_rec_type is OKC_QPP_PVT.qppv_rec_type;
  subtype qppv_tbl_type is OKC_QPP_PVT.qppv_tbl_type;

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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_QA_CHECK_LIST_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE create_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type,
    x_qclv_rec                     OUT NOCOPY qclv_rec_type);

  PROCEDURE update_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type,
    x_qclv_rec                     OUT NOCOPY qclv_rec_type);

  PROCEDURE delete_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type);

  PROCEDURE lock_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type);

  PROCEDURE validate_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN  qclv_rec_type);

  PROCEDURE create_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type,
    x_qlpv_rec                     OUT NOCOPY qlpv_rec_type);

  PROCEDURE update_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type,
    x_qlpv_rec                     OUT NOCOPY qlpv_rec_type);

  PROCEDURE delete_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type);

  PROCEDURE lock_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type);

  PROCEDURE validate_qa_process(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN  qlpv_rec_type);

  PROCEDURE create_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type,
    x_qppv_rec                     OUT NOCOPY qppv_rec_type);

  PROCEDURE update_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type,
    x_qppv_rec                     OUT NOCOPY qppv_rec_type);

  PROCEDURE delete_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type);

  PROCEDURE lock_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type);

  PROCEDURE validate_qa_parm(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN  qppv_rec_type);

  PROCEDURE add_language;

END OKC_QA_CHECK_LIST_PVT;

 

/
