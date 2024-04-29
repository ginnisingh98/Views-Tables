--------------------------------------------------------
--  DDL for Package OKS_ORDER_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ORDER_DETAILS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPCODS.pls 120.0 2005/05/25 17:41:38 appldev noship $*/

  subtype codv_rec_type is oks_Order_details_pvt.codv_rec_type;
  subtype codv_tbl_type is oks_Order_details_pvt.codv_tbl_type;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------


  PROCEDURE insert_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type,
    x_codv_rec                     OUT NOCOPY codv_rec_type);

  PROCEDURE insert_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type);

  PROCEDURE lock_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type);

  PROCEDURE lock_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type);

  PROCEDURE update_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type,
    x_codv_rec                     OUT NOCOPY codv_rec_type);

  PROCEDURE update_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type);

  PROCEDURE delete_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type);

  PROCEDURE delete_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type);

  PROCEDURE validate_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type);

  PROCEDURE validate_Order_detail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type);

END OKS_Order_details_PUB;

 

/
