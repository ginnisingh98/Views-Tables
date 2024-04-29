--------------------------------------------------------
--  DDL for Package OKE_RELATED_ENTITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_RELATED_ENTITIES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPRLES.pls 115.6 2002/08/14 01:42:36 alaw ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKE_RELATED_ENTITIES_PUB';
G_APP_NAME     CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;

SUBTYPE rle_rec_type IS oke_rle_pvt.rle_rec_type;

  PROCEDURE create_related_entity(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_rle_rec			   IN  oke_rle_pvt.rle_rec_type,
    x_rle_rec			   OUT NOCOPY  oke_rle_pvt.rle_rec_type);

  PROCEDURE create_related_entity(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_rle_tbl			   IN  oke_rle_pvt.rle_tbl_type,
    x_rle_tbl			   OUT NOCOPY oke_rle_pvt.rle_tbl_type);


  PROCEDURE update_related_entity(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_rec			   IN oke_rle_pvt.rle_rec_type,
    x_rle_rec			   OUT NOCOPY oke_rle_pvt.rle_rec_type);


  PROCEDURE update_related_entity(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_tbl			   IN oke_rle_pvt.rle_tbl_type,
    x_rle_tbl			   OUT NOCOPY oke_rle_pvt.rle_tbl_type);


  PROCEDURE delete_related_entity(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_rec			   IN oke_rle_pvt.rle_rec_type);


  PROCEDURE delete_related_entity(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_tbl			   IN oke_rle_pvt.rle_tbl_type);

  PROCEDURE validate_related_entity(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_rec			   IN oke_rle_pvt.rle_rec_type);

  PROCEDURE validate_related_entity(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_tbl			   IN oke_rle_pvt.rle_tbl_type);


  PROCEDURE lock_related_entity(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_rle_rec           IN OKE_RLE_PVT.rle_rec_type);

  PROCEDURE lock_related_entity(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_tbl                     IN oke_rle_pvt.rle_tbl_type);

END OKE_RELATED_ENTITIES_PUB;


 

/
