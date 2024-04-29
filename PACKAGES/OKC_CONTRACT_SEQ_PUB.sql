--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_SEQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_SEQ_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPKSQS.pls 120.0 2005/05/25 19:43:45 appldev noship $ */

  subtype ksqv_rec_type is okc_contract_seq_pvt.ksqv_rec_type;
  subtype ksqv_tbl_type is okc_contract_seq_pvt.ksqv_tbl_type;
  subtype lsqv_rec_type is okc_contract_seq_pvt.lsqv_rec_type;
  subtype lsqv_tbl_type is okc_contract_seq_pvt.lsqv_tbl_type;

  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN   CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN    CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_SEQ_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
--
  NO_SETUP_FOUND CONSTANT VARCHAR2(1) := 'N';
--
  PROCEDURE create_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type);

  PROCEDURE create_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type);

  PROCEDURE update_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type);

  PROCEDURE update_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type);

  PROCEDURE delete_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type);

  PROCEDURE delete_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type);

  PROCEDURE lock_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type);

  PROCEDURE lock_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type);

  PROCEDURE validate_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type);

  PROCEDURE validate_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type);

  PROCEDURE create_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type);

  PROCEDURE create_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type);

  PROCEDURE update_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type);

  PROCEDURE update_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type);

  PROCEDURE delete_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type);

  PROCEDURE delete_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type);

  PROCEDURE lock_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type);

  PROCEDURE lock_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type);

  PROCEDURE validate_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type);

  PROCEDURE validate_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type);

  PROCEDURE Is_K_Autogenerated(
    p_scs_code Varchar2,
    x_return_status OUT NOCOPY Varchar2);

  PROCEDURE Get_K_Number(
    p_scs_code                     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    x_contract_number              OUT NOCOPY VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2);

END OKC_CONTRACT_SEQ_PUB;

 

/
