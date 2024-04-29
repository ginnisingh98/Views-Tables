--------------------------------------------------------
--  DDL for Package OKS_SRVAVLEXC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SRVAVLEXC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRSVES.pls 120.0 2005/05/25 18:21:04 appldev noship $ */

  SUBTYPE saxv_rec_type IS OKS_AVLEXC_PVT.saxv_rec_type;
  SUBTYPE saxv_tbl_type IS OKS_AVLEXC_PVT.saxv_tbl_type;

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_SERVAVAILEXC_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------


  PROCEDURE insert_serv_avail_exc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type,
    x_saxv_rec                     OUT NOCOPY saxv_rec_type);


  PROCEDURE lock_serv_avail_exc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type);


  PROCEDURE update_serv_avail_exc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type,
    x_saxv_rec                     OUT NOCOPY saxv_rec_type);


  PROCEDURE delete_serv_avail_exc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type);


  PROCEDURE validate_serv_avail_exc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type);

End OKS_SRVAVLEXC_PVT;

 

/
