--------------------------------------------------------
--  DDL for Package OKL_SETUP_ACCRUALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUP_ACCRUALS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPARUS.pls 115.1 2002/02/21 17:40:07 pkm ship       $ */

  SUBTYPE agnv_rec_type IS OKL_SETUP_ACCRUALS_PVT.agnv_rec_type;
  SUBTYPE agnv_tbl_type IS OKL_SETUP_ACCRUALS_PVT.agnv_tbl_type;


  PROCEDURE create_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN  agnv_rec_type,
    x_agnv_rec                     OUT NOCOPY agnv_rec_type);

  PROCEDURE create_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN  agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type);


  PROCEDURE update_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN  agnv_rec_type,
    x_agnv_rec                     OUT NOCOPY agnv_rec_type);

  PROCEDURE update_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN  agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type);

  PROCEDURE delete_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN  agnv_rec_type);

  PROCEDURE delete_accrual_rules(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN  agnv_tbl_type);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_SETUP_ACCRUALS_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


END OKL_SETUP_ACCRUALS_PUB;

 

/
