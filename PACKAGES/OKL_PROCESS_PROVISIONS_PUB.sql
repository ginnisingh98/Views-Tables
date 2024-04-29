--------------------------------------------------------
--  DDL for Package OKL_PROCESS_PROVISIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_PROVISIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPRVS.pls 115.2 2002/02/18 20:12:05 pkm ship       $ */

  SUBTYPE pvnv_rec_type IS OKL_PROCESS_PROVISIONS_PVT.pvnv_rec_type;
  SUBTYPE pvnv_tbl_type IS OKL_PROCESS_PROVISIONS_PVT.pvnv_tbl_type;


  PROCEDURE create_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type);

  PROCEDURE create_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type);


  PROCEDURE update_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type);

  PROCEDURE update_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type);

  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type);

  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_PROCESS_PROVISIONS_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


END OKL_PROCESS_PROVISIONS_PUB;

 

/
