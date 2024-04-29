--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_GROUP_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPCGPS.pls 120.0 2005/05/26 09:51:14 appldev noship $ */

  subtype cgpv_rec_type is okc_contract_group_pvt.cgpv_rec_type;
  subtype cgpv_tbl_type is okc_contract_group_pvt.cgpv_tbl_type;
  subtype cgcv_rec_type is okc_contract_group_pvt.cgcv_rec_type;
  subtype cgcv_tbl_type is okc_contract_group_pvt.cgcv_tbl_type;
  subtype qry_k_tbl     is okc_cgc_pvt.qry_k_tbl;

  g_cgpv_rec cgpv_rec_type;
  g_cgpv_tbl cgpv_tbl_type;
  g_cgcv_rec cgcv_rec_type;
  g_cgcv_tbl cgcv_tbl_type;

  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_GROUP_PUB';
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
                          p_cgpv_tbl IN cgpv_tbl_type);
  PROCEDURE Validate_Public_YN(x_return_status OUT NOCOPY VARCHAR2,
                               p_cgpv_tbl IN cgpv_tbl_type);
  PROCEDURE Validate_Short_Description(x_return_status OUT NOCOPY VARCHAR2,
                                       p_cgpv_tbl IN cgpv_tbl_type);

  FUNCTION Validate_Record(p_cgpv_tbl IN cgpv_tbl_type)
    RETURN VARCHAR2;

  PROCEDURE Set_Search_String(
	 p_srch_str      IN         VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE Get_Queried_Contracts(
	 p_cgp_parent_id IN  NUMBER,
	 x_qry_k_tbl     OUT NOCOPY qry_k_tbl,
      x_return_status OUT NOCOPY VARCHAR2);

END OKC_CONTRACT_GROUP_PUB;

 

/
