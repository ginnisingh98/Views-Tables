--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCKHRS.pls 120.1 2005/06/29 16:53:29 apaul noship $ */

  subtype khrv_rec_type is OKL_KHR_pvt.khrv_rec_type;
  subtype khrv_tbl_type is OKL_KHR_pvt.khrv_tbl_type;
  subtype klev_rec_type is okl_kle_pvt.klev_rec_type;
  subtype klev_tbl_type is okl_kle_pvt.klev_tbl_type;

  TYPE hdr_tbl_type IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;
  -- GLOBAL VARIABLES

  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type);

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY okl_okc_migration_pvt.chrv_tbl_type,
    x_khrv_tbl                     OUT NOCOPY khrv_tbl_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN khrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY okl_okc_migration_pvt.chrv_tbl_type,
    x_khrv_tbl                     OUT NOCOPY khrv_tbl_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    p_edit_mode                    IN  VARCHAR2,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type);


  PROCEDURE delete_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_id                  IN  okc_k_headers_b.id%type);

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type);

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type);

  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type);

  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type);

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type);

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type);

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type);

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type);
------------------------
--Bug# 2525554  start
------------------------
   PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_edit_mode                    IN  VARCHAR2,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type);

 PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_edit_mode                    IN  VARCHAR2,
    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type);

------------------------
--Bug# 2525554  end
------------------------

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                       IN  NUMBER);

   PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_delete_cascade_yn           IN  VARCHAR2);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_delete_cascade_yn           IN  varchar2);


  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type);

  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type);

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type);

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type);

PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY okl_okc_migration_pvt.gvev_rec_type);

  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN okl_okc_migration_pvt.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY okl_okc_migration_pvt.gvev_tbl_type);

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY okl_okc_migration_pvt.gvev_rec_type);

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN okl_okc_migration_pvt.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY okl_okc_migration_pvt.gvev_tbl_type);

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type);

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN okl_okc_migration_pvt.gvev_tbl_type);

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type);

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN okl_okc_migration_pvt.gvev_tbl_type);

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type);

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN  okl_okc_migration_pvt.gvev_tbl_type);

  Procedure get_contract_header_info(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_chr_id_old                   IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_orgId                        IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_custId                       IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_invOrgId                     IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_oldOKL_STATUS                IN  VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
    p_oldOKC_STATUS                IN  VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
    x_hdr_tbl                      OUT NOCOPY hdr_tbl_type);
/*
  FUNCTION Increment_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2;
*/
END OKL_CONTRACT_PVT;

 

/
