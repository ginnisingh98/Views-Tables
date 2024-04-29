--------------------------------------------------------
--  DDL for Package OKS_SALES_CREDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SALES_CREDIT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPSCRS.pls 120.0 2005/05/25 18:04:05 appldev noship $ */

  subtype scrv_rec_type is oks_Sales_credit_pvt.scrv_rec_type;
  subtype scrv_tbl_type is oks_Sales_credit_pvt.scrv_tbl_type;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------


  PROCEDURE insert_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec                     IN scrv_rec_type,
    x_scrv_rec                     OUT NOCOPY scrv_rec_type);

  PROCEDURE insert_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl                     IN scrv_tbl_type,
    x_scrv_tbl                     OUT NOCOPY scrv_tbl_type);

  PROCEDURE lock_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec                     IN scrv_rec_type);

  PROCEDURE lock_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl                     IN scrv_tbl_type);

  PROCEDURE update_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec                     IN scrv_rec_type,
    x_scrv_rec                     OUT NOCOPY scrv_rec_type);

  PROCEDURE update_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl                     IN scrv_tbl_type,
    x_scrv_tbl                     OUT NOCOPY scrv_tbl_type);

  PROCEDURE delete_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec                     IN scrv_rec_type);

  PROCEDURE delete_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl                     IN scrv_tbl_type);

  PROCEDURE validate_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec                     IN scrv_rec_type);

  PROCEDURE validate_Sales_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl                     IN scrv_tbl_type);

END OKS_Sales_credit_PUB;

 

/
