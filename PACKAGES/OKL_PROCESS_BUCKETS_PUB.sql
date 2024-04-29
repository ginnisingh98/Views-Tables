--------------------------------------------------------
--  DDL for Package OKL_PROCESS_BUCKETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_BUCKETS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPBUKS.pls 115.2 2002/02/18 20:11:59 pkm ship       $ */

  SUBTYPE bktv_rec_type IS OKL_PROCESS_BUCKETS_PVT.bktv_rec_type;
  SUBTYPE bktv_tbl_type IS OKL_PROCESS_BUCKETS_PVT.bktv_tbl_type;


  PROCEDURE create_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN  bktv_rec_type,
    x_bktv_rec                     OUT NOCOPY bktv_rec_type);

  PROCEDURE create_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN  bktv_tbl_type,
    x_bktv_tbl                     OUT NOCOPY bktv_tbl_type);


  PROCEDURE update_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN  bktv_rec_type,
    x_bktv_rec                     OUT NOCOPY bktv_rec_type);

  PROCEDURE update_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN  bktv_tbl_type,
    x_bktv_tbl                     OUT NOCOPY bktv_tbl_type);

  PROCEDURE delete_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN  bktv_rec_type);

  PROCEDURE delete_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN  bktv_tbl_type);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_PROCESS_BUCKETS_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


END OKL_PROCESS_BUCKETS_PUB;

 

/
