--------------------------------------------------------
--  DDL for Package OKL_VERSION_IB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VERSION_IB_PVT" AUTHID CURRENT_USER as
/* $Header: OKLCVIBS.pls 115.0 2002/02/05 15:12:55 pkm ship        $ */

  subtype vib_rec_type  is okl_vib_pvt.vib_rec_type;
  subtype vib_tbl_type  is okl_vib_pvt.vib_tbl_type;
  subtype vibv_rec_type is okl_vib_pvt.vibv_rec_type;
  subtype vibv_tbl_type is okl_vib_pvt.vibv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS , VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_VERSION_IB_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';

 ----------------------------------------------------------------------------------
  --Global Exception
 ----------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ----------------------------------------------------------------------------------
  --Public Procedures and Functions
 ----------------------------------------------------------------------------------
--  PROCEDURE add_language;
  PROCEDURE Create_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type,
    x_vibv_rec                     OUT NOCOPY vibv_rec_type);

  PROCEDURE Create_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type,
    x_vibv_tbl                     OUT NOCOPY vibv_tbl_type);

  PROCEDURE lock_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type);

  PROCEDURE lock_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type);

  PROCEDURE update_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type,
    x_vibv_rec                     OUT NOCOPY vibv_rec_type);

  PROCEDURE update_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type,
    x_vibv_tbl                     OUT NOCOPY vibv_tbl_type);

  PROCEDURE delete_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type);

  PROCEDURE delete_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type);

  PROCEDURE validate_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type);

  PROCEDURE validate_version_ib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type);

END OKL_VERSION_IB_PVT;

 

/
