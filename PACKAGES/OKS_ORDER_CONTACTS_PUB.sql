--------------------------------------------------------
--  DDL for Package OKS_ORDER_CONTACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ORDER_CONTACTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPCOCS.pls 120.0 2005/05/25 17:54:55 appldev noship $ */

  subtype cocv_rec_type is oks_Order_Contacts_pvt.cocv_rec_type;
  subtype cocv_tbl_type is oks_Order_Contacts_pvt.cocv_tbl_type;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------


  PROCEDURE insert_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type,
    x_cocv_rec                     OUT NOCOPY cocv_rec_type);

  PROCEDURE insert_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type,
    x_cocv_tbl                     OUT NOCOPY cocv_tbl_type);

  PROCEDURE lock_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type);

  PROCEDURE lock_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type);

  PROCEDURE update_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type,
    x_cocv_rec                     OUT NOCOPY cocv_rec_type);

  PROCEDURE update_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type,
    x_cocv_tbl                     OUT NOCOPY cocv_tbl_type);

  PROCEDURE delete_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type);

  PROCEDURE delete_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type);

  PROCEDURE validate_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type);

  PROCEDURE validate_Order_Contact(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type);

END OKS_Order_Contacts_PUB;

 

/
