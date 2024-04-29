--------------------------------------------------------
--  DDL for Package OKC_PRICE_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PRICE_ADJUSTMENT_PUB" AUTHID CURRENT_USER AS
 /* $Header: OKCPPATS.pls 120.0 2005/05/25 18:34:31 appldev noship $*/
 -- Sub types for price adjustments
 subtype patv_rec_type is okc_price_adjustment_pvt.patv_rec_type;
 subtype patv_tbl_type is okc_price_adjustment_pvt.patv_tbl_type;

 -- Sub types for price adjustment assoc
 subtype pacv_rec_type is okc_price_adjustment_pvt.pacv_rec_type;
 subtype pacv_tbl_type is okc_price_adjustment_pvt.pacv_tbl_type;

 -- Sub types for price adjustment attributes
 subtype pavv_rec_type is okc_price_adjustment_pvt.pavv_rec_type;
 subtype pavv_tbl_type is okc_price_adjustment_pvt.pavv_tbl_type;

 -- Sub types for price attribute value
 subtype paav_rec_type is okc_price_adjustment_pvt.paav_rec_type;
 subtype paav_tbl_type is okc_price_adjustment_pvt.paav_tbl_type;


 G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_GROUP_PUB';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
PROCEDURE create_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type);

 PROCEDURE create_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type);

 PROCEDURE update_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type);

 PROCEDURE update_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type);

 PROCEDURE delete_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type);

 PROCEDURE delete_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type);

 PROCEDURE validate_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type);

 PROCEDURE validate_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type);

 PROCEDURE lock_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type);

 PROCEDURE lock_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type);



 PROCEDURE create_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type,
    x_pacv_rec                     OUT NOCOPY pacv_rec_type);

 PROCEDURE create_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type,
    x_pacv_tbl                     OUT NOCOPY pacv_tbl_type);

 PROCEDURE update_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type,
    x_pacv_rec                     OUT NOCOPY pacv_rec_type);

 PROCEDURE update_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type,
    x_pacv_tbl                     OUT NOCOPY pacv_tbl_type);

 PROCEDURE delete_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type);

 PROCEDURE delete_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type );

 PROCEDURE validate_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type);

 PROCEDURE validate_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type);

 PROCEDURE lock_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type );

 PROCEDURE lock_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type );

  PROCEDURE create_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type,
    x_pavv_rec                     OUT NOCOPY pavv_rec_type);

 PROCEDURE create_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type,
    x_pavv_tbl                     OUT NOCOPY pavv_tbl_type);


 PROCEDURE update_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type,
    x_pavv_rec                     OUT NOCOPY pavv_rec_type);

 PROCEDURE update_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type,
    x_pavv_tbl                     OUT NOCOPY pavv_tbl_type);

 PROCEDURE delete_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type);

 PROCEDURE delete_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type );

 PROCEDURE validate_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type);

 PROCEDURE validate_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type );

 PROCEDURE lock_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type );

 PROCEDURE lock_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type);

 PROCEDURE create_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type);

 PROCEDURE create_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type);

 PROCEDURE update_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type);

 PROCEDURE update_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type);

 PROCEDURE delete_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type);

 PROCEDURE delete_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type);

 PROCEDURE validate_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type);

 PROCEDURE validate_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type );

 PROCEDURE lock_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type);

 PROCEDURE lock_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type);


END okc_price_adjustment_pub;

 

/
