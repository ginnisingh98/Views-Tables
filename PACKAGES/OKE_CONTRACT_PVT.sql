--------------------------------------------------------
--  DDL for Package OKE_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_CONTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKEVCCCS.pls 120.1 2005/10/03 12:46:29 ausmani noship $ */

  subtype chr_rec_type is oke_chr_pvt.chr_rec_type;
  subtype chr_tbl_type is oke_chr_pvt.chr_tbl_type;
  subtype cle_rec_type is oke_cle_pvt.cle_rec_type;
  subtype cle_tbl_type is oke_cle_pvt.cle_tbl_type;



  -- GLOBAL VARIABLES

  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKE_CONTRACT_PVT';

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec                      IN  OKE_CHR_PVT.chr_rec_type,
    x_chr_rec                      OUT NOCOPY  OKE_CHR_PVT.chr_rec_type);

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl                      IN OKE_CHR_PVT.chr_tbl_type,
    x_chr_tbl                      OUT NOCOPY OKE_CHR_PVT.chr_tbl_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec                      IN OKE_CHR_PVT.chr_rec_type,
    x_chr_rec                      OUT NOCOPY OKE_CHR_PVT.chr_rec_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl                      IN OKE_CHR_PVT.chr_tbl_type,
    x_chr_tbl                      OUT NOCOPY OKE_CHR_PVT.chr_tbl_type);


  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec                      IN OKE_CHR_PVT.chr_rec_type);

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl                      IN OKE_CHR_PVT.chr_tbl_type);


  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec                      IN OKE_CHR_PVT.chr_rec_type);

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl                      IN OKE_CHR_PVT.chr_tbl_type);



  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                      IN  OKE_CLE_PVT.cle_rec_type,
    x_cle_rec                      OUT NOCOPY  OKE_CLE_PVT.cle_rec_type);


  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                      IN OKE_CLE_PVT.cle_tbl_type,
    x_cle_tbl                      OUT NOCOPY OKE_CLE_PVT.cle_tbl_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                     IN OKE_CLE_PVT.cle_rec_type,
    x_cle_rec                     OUT NOCOPY OKE_CLE_PVT.cle_rec_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                      IN OKE_CLE_PVT.cle_tbl_type,
    x_cle_tbl                      OUT NOCOPY OKE_CLE_PVT.cle_tbl_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                      IN OKE_CLE_PVT.cle_tbl_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                     IN OKE_CLE_PVT.cle_rec_type);


  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                      IN NUMBER);


  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec                     IN OKE_CLE_PVT.cle_rec_type);

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl                      IN OKE_CLE_PVT.cle_tbl_type);

  PROCEDURE create_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                      IN  OKE_DELIVERABLE_PVT.del_rec_type,
    x_del_rec                      OUT NOCOPY  OKE_DELIVERABLE_PVT.del_rec_type);


  PROCEDURE create_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                      IN OKE_DELIVERABLE_PVT.del_tbl_type,
    x_del_tbl                      OUT NOCOPY OKE_DELIVERABLE_PVT.del_tbl_type);

  PROCEDURE update_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN OKE_DELIVERABLE_PVT.del_rec_type,
    x_del_rec                     OUT NOCOPY OKE_DELIVERABLE_PVT.del_rec_type);

  PROCEDURE update_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                      IN OKE_DELIVERABLE_PVT.del_tbl_type,
    x_del_tbl                      OUT NOCOPY OKE_DELIVERABLE_PVT.del_tbl_type);

  PROCEDURE delete_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                      IN OKE_DELIVERABLE_PVT.del_tbl_type);

  PROCEDURE delete_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN OKE_DELIVERABLE_PVT.del_rec_type);

  PROCEDURE delete_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_deliverable_id               IN NUMBER);

  PROCEDURE validate_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN OKE_DELIVERABLE_PVT.del_rec_type);

  PROCEDURE validate_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                      IN OKE_DELIVERABLE_PVT.del_tbl_type);

  PROCEDURE lock_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN OKE_DELIVERABLE_PVT.del_rec_type);

  PROCEDURE lock_deliverable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN OKE_DELIVERABLE_PVT.del_tbl_type);

  FUNCTION Increment_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2;


  PROCEDURE delete_minor_entities (
	p_header_id	IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE delete_version_records (
	p_api_version   IN VARCHAR2,
	p_header_id	IN NUMBER,
	x_return_status OUT NOCOPY varchar2,
	x_msg_count	OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2);


END OKE_CONTRACT_PVT;


 

/
