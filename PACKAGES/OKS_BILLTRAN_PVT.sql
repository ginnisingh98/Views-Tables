--------------------------------------------------------
--  DDL for Package OKS_BILLTRAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILLTRAN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRBTNS.pls 120.0 2005/05/25 18:12:33 appldev noship $ */

  SUBTYPE btnv_rec_type IS OKS_BTN_PVT.btnv_rec_type;
  SUBTYPE btnv_tbl_type IS OKS_BTN_PVT.btnv_tbl_type;

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_BILLCONT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE insert_bill_Tran_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
   p_btnv_rec      IN btnv_rec_type,
 x_btnv_rec      OUT NOCOPY btnv_rec_type);

  PROCEDURE lock_bill_Tran_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_rec      IN btnv_rec_type);

  PROCEDURE update_bill_Tran_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_rec      IN btnv_rec_type,
 x_btnv_rec      OUT NOCOPY btnv_rec_type);

  PROCEDURE delete_bill_Tran_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_rec      IN btnv_rec_type);

  PROCEDURE validate_bill_Tran_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
   p_btnv_rec      IN btnv_rec_type);

END OKS_BILLTRAN_PVT;

 

/
