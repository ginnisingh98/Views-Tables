--------------------------------------------------------
--  DDL for Package OKS_SRVAVL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SRVAVL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRSVAS.pls 120.0 2005/05/25 17:48:44 appldev noship $ */

  SUBTYPE savv_rec_type IS OKS_AVL_PVT.savv_rec_type;
  SUBTYPE savv_tbl_type IS OKS_AVL_PVT.savv_tbl_type;

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_SERVAVAIL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE insert_serv_avail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type,
    x_savv_rec                     OUT NOCOPY savv_rec_type);

  PROCEDURE lock_serv_avail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type);

  PROCEDURE update_serv_avail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type,
    x_savv_rec                     OUT NOCOPY savv_rec_type);

  PROCEDURE delete_serv_avail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type);

  PROCEDURE validate_serv_avail(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type);

END OKS_SRVAVL_PVT;

 

/
