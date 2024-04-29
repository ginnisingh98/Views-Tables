--------------------------------------------------------
--  DDL for Package OKL_VERSION_FA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VERSION_FA_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPVFAS.pls 115.0 2002/02/04 19:07:27 pkm ship       $ */

  subtype vfav_rec_type is okl_version_fa_pvt.vfav_rec_type;
  subtype vfav_tbl_type is okl_version_fa_pvt.vfav_tbl_type;


  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'SQLERRM';

-- Global variables for user hooks
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_VERSION_FA_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  g_vfav_rec			vfav_rec_type;
  g_vfav_tbl			vfav_tbl_type;


  PROCEDURE create_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type,
    x_vfav_rec                     OUT NOCOPY vfav_rec_type);

  PROCEDURE create_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type,
    x_vfav_tbl                     OUT NOCOPY vfav_tbl_type);


  PROCEDURE update_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type,
    x_vfav_rec                     OUT NOCOPY vfav_rec_type);

  PROCEDURE update_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type,
    x_vfav_tbl                     OUT NOCOPY vfav_tbl_type);

  PROCEDURE delete_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type);

  PROCEDURE delete_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type);

  PROCEDURE lock_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type);

  procedure lock_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type);

  PROCEDURE validate_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type);

  procedure validate_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type);


END OKL_VERSION_FA_PUB;

 

/
