--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_GROUP_PVT" AUTHID CURRENT_USER as
/* $Header: OKCCCGPS.pls 120.0 2005/05/25 18:39:56 appldev noship $ */

  subtype cgpv_rec_type is okc_cgp_pvt.cgpv_rec_type;
  subtype cgpv_tbl_type is okc_cgp_pvt.cgpv_tbl_type;
  subtype cgcv_rec_type is okc_cgc_pvt.cgcv_rec_type;
  subtype cgcv_tbl_type is okc_cgc_pvt.cgcv_tbl_type;

  g_cgpv_rec cgpv_rec_type;
  g_cgpv_tbl cgpv_tbl_type;
  g_cgcv_rec cgcv_rec_type;
  g_cgcv_tbl cgcv_tbl_type;

  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_GROUP_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  PROCEDURE add_language;

  PROCEDURE create_ctr_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type);

  PROCEDURE update_ctr_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type);

  PROCEDURE validate_ctr_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    p_cgcv_tbl                     IN cgcv_tbl_type);

  PROCEDURE create_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type);

  PROCEDURE create_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type,
    x_cgpv_tbl                     OUT NOCOPY cgpv_tbl_type);

  PROCEDURE update_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type,
    x_cgpv_rec                     OUT NOCOPY cgpv_rec_type);

  PROCEDURE update_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type,
    x_cgpv_tbl                     OUT NOCOPY cgpv_tbl_type);

  PROCEDURE delete_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type);

  PROCEDURE delete_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type);

  PROCEDURE lock_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type);

  PROCEDURE lock_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type);

  PROCEDURE validate_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_rec                     IN cgpv_rec_type);

  PROCEDURE validate_contract_group(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgpv_tbl                     IN cgpv_tbl_type);

  PROCEDURE create_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type,
    x_cgcv_rec                     OUT NOCOPY cgcv_rec_type);

  PROCEDURE create_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type);

  PROCEDURE update_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type,
    x_cgcv_rec                     OUT NOCOPY cgcv_rec_type);

  PROCEDURE update_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type);

  PROCEDURE delete_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type);

  PROCEDURE delete_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type);

  PROCEDURE lock_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type);

  PROCEDURE lock_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type);

  PROCEDURE validate_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type);

  PROCEDURE validate_contract_grpngs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type);

  PROCEDURE Validate_Name(x_return_status OUT NOCOPY VARCHAR2,
                          p_cgpv_rec IN cgpv_rec_type);
  PROCEDURE Validate_Public_YN(x_return_status OUT NOCOPY VARCHAR2,
                               p_cgpv_rec IN cgpv_rec_type);
  PROCEDURE Validate_Short_Description(x_return_status OUT NOCOPY VARCHAR2,
                                       p_cgpv_rec IN cgpv_rec_type);
  FUNCTION Validate_Record(p_cgpv_rec IN cgpv_rec_type)
    RETURN VARCHAR2;

END OKC_CONTRACT_GROUP_PVT;

 

/
