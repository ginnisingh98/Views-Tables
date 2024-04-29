--------------------------------------------------------
--  DDL for Package OKE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_CONTRACT_PUB" AUTHID CURRENT_USER AS
/*$Header: OKEPCCCS.pls 120.1 2005/06/02 11:59:44 appldev  $ */

  subtype chr_rec_type is oke_contract_pvt.chr_rec_type;
  subtype chr_tbl_type is oke_contract_pvt.chr_tbl_type;
  subtype cle_rec_type is oke_contract_pvt.cle_rec_type;
  subtype cle_tbl_type is oke_contract_pvt.cle_tbl_type;
  subtype del_rec_type is oke_deliverable_pvt.del_rec_type;
  subtype del_tbl_type is oke_deliverable_pvt.del_tbl_type;
  subtype chrv_rec_type is okc_contract_pub.chrv_rec_type;
  subtype chrv_tbl_type is okc_contract_pub.chrv_tbl_type;
  subtype clev_rec_type is okc_contract_pub.clev_rec_type;
  subtype clev_tbl_type is okc_contract_pub.clev_tbl_type;

  G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKE_CONTRACT_PUB';
  G_APP_NAME     CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;

  PROCEDURE Assign_Doc_Number
    ( X_K_Type_Code   IN     VARCHAR2
    , X_Buy_Or_Sell   IN     VARCHAR2
    , X_Template_Flag IN     VARCHAR2
    , X_K_Number      IN OUT NOCOPY VARCHAR2
    , X_Return_Status IN OUT NOCOPY VARCHAR2
    );

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec			   IN  oke_chr_pvt.chr_rec_type,
    p_chrv_rec                     IN  okc_contract_pub.chrv_rec_type,
    x_chr_rec			   OUT NOCOPY  oke_chr_pvt.chr_rec_type,
    x_chrv_rec                     OUT NOCOPY  okc_contract_pub.chrv_rec_type);

  PROCEDURE create_contract_header(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_chr_tbl			   IN oke_chr_pvt.chr_tbl_type,
    p_chrv_tbl                     IN okc_contract_pub.chrv_tbl_type,
    x_chr_tbl			   OUT NOCOPY oke_chr_pvt.chr_tbl_type,
    x_chrv_tbl                     OUT NOCOPY okc_contract_pub.chrv_tbl_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update		   IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_chr_rec			   IN oke_chr_pvt.chr_rec_type,
    p_chrv_rec                     IN okc_contract_pub.chrv_rec_type,

    x_chr_rec			   OUT NOCOPY oke_chr_pvt.chr_rec_type,
    x_chrv_rec                     OUT NOCOPY okc_contract_pub.chrv_rec_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update		   IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_chr_tbl			   IN oke_chr_pvt.chr_tbl_type,
    p_chrv_tbl                     IN okc_contract_pub.chrv_tbl_type,

    x_chr_tbl			   OUT NOCOPY oke_chr_pvt.chr_tbl_type,
    x_chrv_tbl                     OUT NOCOPY okc_contract_pub.chrv_tbl_type);

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec			   IN oke_chr_pvt.chr_rec_type,
    p_chrv_rec                     IN okc_contract_pub.chrv_rec_type);

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl			   IN oke_chr_pvt.chr_tbl_type,
    p_chrv_tbl                     IN okc_contract_pub.chrv_tbl_type);



  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_rec			   IN oke_chr_pvt.chr_rec_type,
    p_chrv_rec                     IN okc_contract_pub.chrv_rec_type);

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_tbl			   IN oke_chr_pvt.chr_tbl_type,
    p_chrv_tbl                     IN okc_contract_pub.chrv_tbl_type);

  PROCEDURE create_contract_line(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update		   IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_cle_rec			   IN  oke_cle_pvt.cle_rec_type,
    p_clev_rec                     IN  okc_contract_pub.clev_rec_type,
    x_cle_rec			   OUT NOCOPY  oke_cle_pvt.cle_rec_type,
    x_clev_rec                     OUT NOCOPY  okc_contract_pub.clev_rec_type);

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update		   IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_cle_tbl			   IN  oke_cle_pvt.cle_tbl_type,
    p_clev_tbl                     IN okc_contract_pub.clev_tbl_type,
    x_cle_tbl			   OUT NOCOPY oke_cle_pvt.cle_tbl_type,
    x_clev_tbl                     OUT NOCOPY okc_contract_pub.clev_tbl_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update		   IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_cle_rec			   IN oke_cle_pvt.cle_rec_type,
    p_clev_rec                     IN okc_contract_pub.clev_rec_type,

    x_cle_rec			   OUT NOCOPY oke_cle_pvt.cle_rec_type,
    x_clev_rec                     OUT NOCOPY okc_contract_pub.clev_rec_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update		   IN VARCHAR2 DEFAULT OKE_API.G_TRUE,
    p_cle_tbl			   IN oke_cle_pvt.cle_tbl_type,
    p_clev_tbl                     IN okc_contract_pub.clev_tbl_type,

    x_cle_tbl			   OUT NOCOPY oke_cle_pvt.cle_tbl_type,
    x_clev_tbl                     OUT NOCOPY okc_contract_pub.clev_tbl_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_rec			   IN oke_cle_pvt.cle_rec_type,
    p_clev_rec                     IN okc_contract_pub.clev_rec_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl			   IN oke_cle_pvt.cle_tbl_type,
    p_clev_tbl                     IN okc_contract_pub.clev_tbl_type);

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
    p_cle_rec			   IN oke_cle_pvt.cle_rec_type,
    p_clev_rec                     IN okc_contract_pub.clev_rec_type);

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_tbl			   IN oke_cle_pvt.cle_tbl_type,
    p_clev_tbl                     IN okc_contract_pub.clev_tbl_type);

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

  PROCEDURE default_deliverable (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_header_id			   IN NUMBER,
    p_first_default_flag	   IN VARCHAR2,
    x_del_tbl                      OUT NOCOPY /* file.sql.39 change */ oke_deliverable_pvt.del_tbl_type);




	PROCEDURE Check_Delete_Contract(
	p_api_version       IN NUMBER,
	p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
	x_return_status     OUT NOCOPY VARCHAR2,
	x_msg_count         OUT NOCOPY NUMBER,
	x_msg_data          OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER,
	x_return_code	    OUT NOCOPY VARCHAR2);


	PROCEDURE delete_contract (
	p_api_version       IN NUMBER,
	p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
	x_return_status     OUT NOCOPY VARCHAR2,
	x_msg_count        OUT NOCOPY NUMBER,
	x_msg_data          OUT NOCOPY VARCHAR2,
	p_chr_id	        IN  NUMBER,
	p_pre_deletion_check_yn    IN VARCHAR2  DEFAULT 'Y');



END OKE_CONTRACT_PUB;


 

/
