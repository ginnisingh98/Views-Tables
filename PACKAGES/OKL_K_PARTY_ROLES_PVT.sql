--------------------------------------------------------
--  DDL for Package OKL_K_PARTY_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_K_PARTY_ROLES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRKPLS.pls 120.0 2005/10/18 17:44:05 rpillay noship $ */

  subtype kplv_rec_type is okl_kpl_pvt.kplv_rec_type;
  subtype kplv_tbl_type is okl_kpl_pvt.kplv_tbl_type;

  -- GLOBAL VARIABLES

  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_K_PARTY_ROLES_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;

  PROCEDURE create_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN  okl_okc_migration_pvt.cplv_rec_type,
    p_kplv_rec                     IN  kplv_rec_type,
    x_cplv_rec                     OUT NOCOPY okl_okc_migration_pvt.cplv_rec_type,
    x_kplv_rec                     OUT NOCOPY kplv_rec_type);

  PROCEDURE create_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN  okl_okc_migration_pvt.cplv_tbl_type,
    p_kplv_tbl                     IN  kplv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY okl_okc_migration_pvt.cplv_tbl_type,
    x_kplv_tbl                     OUT NOCOPY kplv_tbl_type);

  PROCEDURE update_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN  okl_okc_migration_pvt.cplv_rec_type,
    p_kplv_rec                     IN  kplv_rec_type,
    x_cplv_rec                     OUT NOCOPY okl_okc_migration_pvt.cplv_rec_type,
    x_kplv_rec                     OUT NOCOPY kplv_rec_type);

  PROCEDURE update_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN  okl_okc_migration_pvt.cplv_tbl_type,
    p_kplv_tbl                     IN  kplv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY okl_okc_migration_pvt.cplv_tbl_type,
    x_kplv_tbl                     OUT NOCOPY kplv_tbl_type);

  PROCEDURE delete_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN  okl_okc_migration_pvt.cplv_rec_type,
    p_kplv_rec                     IN  kplv_rec_type);

  PROCEDURE delete_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN  okl_okc_migration_pvt.cplv_tbl_type,
    p_kplv_tbl                     IN  kplv_tbl_type);

END OKL_K_PARTY_ROLES_PVT;

 

/
