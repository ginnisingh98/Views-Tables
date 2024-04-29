--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCCHRS.pls 120.4 2005/11/15 03:29:29 maanand noship $ */

  subtype chrv_rec_type is okc_chr_pvt.chrv_rec_type;
  subtype chrv_tbl_type is okc_chr_pvt.chrv_tbl_type;
  subtype clev_rec_type is okc_cle_pvt.clev_rec_type;
  subtype clev_tbl_type is okc_cle_pvt.clev_tbl_type;
  subtype cacv_rec_type is okc_cac_pvt.cacv_rec_type;
  subtype cacv_tbl_type is okc_cac_pvt.cacv_tbl_type;
  subtype cpsv_rec_type is okc_cps_pvt.cpsv_rec_type;
  subtype cpsv_tbl_type is okc_cps_pvt.cpsv_tbl_type;
  subtype gvev_rec_type is okc_gve_pvt.gvev_rec_type;
  subtype gvev_tbl_type is okc_gve_pvt.gvev_tbl_type;
  subtype cvmv_rec_type is okc_cvm_pvt.cvmv_rec_type;
  subtype cvmv_tbl_type is okc_cvm_pvt.cvmv_tbl_type;
  subtype control_rec_type is okc_util.okc_control_rec_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_PVT';
  ---------------------------------------------------------------------------

  PROCEDURE GENERATE_CONTRACT_NUMBER(
    p_scs_code                  IN VARCHAR2,
    p_modifier			IN  VARCHAR2,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_contract_number	        IN OUT NOCOPY OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE);

  FUNCTION Update_Allowed(p_chr_id IN NUMBER) RETURN VARCHAR2;

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  OKC_CHR_PVT.chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY  OKC_CHR_PVT.chrv_rec_type,
    p_check_access                 IN  VARCHAR2 DEFAULT 'N');

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN OKC_CHR_PVT.chrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY OKC_CHR_PVT.chrv_tbl_type,
    p_check_access                 IN VARCHAR2 DEFAULT 'N');

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY OKC_CHR_PVT.chrv_rec_type);


  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_tbl                     IN OKC_CHR_PVT.chrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY OKC_CHR_PVT.chrv_tbl_type);

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update		   IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type,
    p_control_rec		   IN control_rec_type,
    x_chrv_rec                     OUT NOCOPY OKC_CHR_PVT.chrv_rec_type);

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type);

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN OKC_CHR_PVT.chrv_tbl_type);

  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type);

  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN OKC_CHR_PVT.chrv_tbl_type);

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type);

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN OKC_CHR_PVT.chrv_tbl_type);

  PROCEDURE create_ancestry(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type);

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT 'F',
    p_clev_rec                     IN  OKC_CLE_PVT.clev_rec_type,
    x_clev_rec                     OUT NOCOPY  OKC_CLE_PVT.clev_rec_type);

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN OKC_CLE_PVT.clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY OKC_CLE_PVT.clev_tbl_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type,
    x_clev_rec                     OUT NOCOPY OKC_CLE_PVT.clev_rec_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update			IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_tbl                     IN OKC_CLE_PVT.clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY OKC_CLE_PVT.clev_tbl_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN OKC_CLE_PVT.clev_tbl_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                      IN NUMBER);

  PROCEDURE force_delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                      IN NUMBER);

  PROCEDURE delete_ancestry(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_id                       IN  NUMBER);

  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type);

  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN OKC_CLE_PVT.clev_tbl_type);

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type);

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN OKC_CLE_PVT.clev_tbl_type);

  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY OKC_GVE_PVT.gvev_rec_type);

  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY OKC_GVE_PVT.gvev_tbl_type);

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY OKC_GVE_PVT.gvev_rec_type);

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY OKC_GVE_PVT.gvev_tbl_type);

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type);

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type);

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type);

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type);

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type);

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type);

  PROCEDURE create_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type,
    x_cpsv_rec                     OUT NOCOPY OKC_CPS_PVT.cpsv_rec_type);

  PROCEDURE create_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type,
    x_cpsv_tbl                     OUT NOCOPY OKC_CPS_PVT.cpsv_tbl_type);

  PROCEDURE update_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type,
    x_cpsv_rec                     OUT NOCOPY OKC_CPS_PVT.cpsv_rec_type);

  PROCEDURE update_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type,
    x_cpsv_tbl                     OUT NOCOPY OKC_CPS_PVT.cpsv_tbl_type);

  PROCEDURE delete_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type);

  PROCEDURE delete_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type);

  PROCEDURE lock_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type);

  PROCEDURE lock_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type);

  PROCEDURE validate_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type);

  PROCEDURE validate_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type);

  PROCEDURE create_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type,
    x_cacv_rec                     OUT NOCOPY OKC_CAC_PVT.cacv_rec_type);

  PROCEDURE create_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type,
    x_cacv_tbl                     OUT NOCOPY OKC_CAC_PVT.cacv_tbl_type);

  PROCEDURE update_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type,
    x_cacv_rec                     OUT NOCOPY OKC_CAC_PVT.cacv_rec_type);

  PROCEDURE update_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type,
    x_cacv_tbl                     OUT NOCOPY OKC_CAC_PVT.cacv_tbl_type);

  PROCEDURE delete_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type);

  PROCEDURE delete_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type);

  PROCEDURE lock_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type);

  PROCEDURE lock_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type);

  PROCEDURE validate_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type);

  PROCEDURE validate_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type);

  PROCEDURE add_language;

  PROCEDURE Get_Active_Process (
		p_api_version				IN NUMBER,
		p_init_msg_list			IN VARCHAR2,
		x_return_status		 OUT NOCOPY VARCHAR2,
		x_msg_count			 OUT NOCOPY NUMBER,
		x_msg_data			 OUT NOCOPY VARCHAR2,
		p_contract_number             IN VARCHAR2,
		p_contract_number_modifier    IN VARCHAR2,
		x_wf_name				 OUT NOCOPY VARCHAR2,
		x_wf_process_name		 OUT NOCOPY VARCHAR2,
		x_package_name			 OUT NOCOPY VARCHAR2,
		x_procedure_name		 OUT NOCOPY VARCHAR2,
		x_usage				 OUT NOCOPY VARCHAR2);

  FUNCTION Increment_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2;

  --added by smhanda for renew and status related changes

  PROCEDURE CLEAN_REN_LINKS(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_target_chr_id                IN number,
    clean_relink_flag              IN VARCHAR2 DEFAULT 'CLEAN');

/*
  PROCEDURE CLEAN_REN_COPY(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN number);
*/

  PROCEDURE RELINK_RENEW(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_target_chr_id                IN number);

    --end added by smhanda

  FUNCTION Is_Process_Active(p_chr_id IN NUMBER) RETURN VARCHAR2;

--For Bug.No.1789860, Function Get_concat_line_no is added.

  FUNCTIOn Get_concat_line_no(p_cle_id IN NUMBER,
						x_return_status OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;


--[llc] Update Contract Amount

/*
   The Header and Line Amounts should be updated when Change Status action is taken
   at the header/line/subline level. This is to ensure that the calualated amounts
   (price_negotiated, cancelled_amount, estimated_amount) ignores cancelled lines/sublines.

   A new procedure Update_Contract_Amount is define which is called
   when cancel actions is taken at header/line/subline level.

*/

   PROCEDURE UPDATE_CONTRACT_AMOUNT (
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_id                IN NUMBER,
    p_from_ste_code     IN VARCHAR2,
    p_to_ste_code       IN VARCHAR2,
    p_cle_id            IN NUMBER,
    x_return_status     OUT NOCOPY    VARCHAR2,
    x_msg_count         OUT NOCOPY    NUMBER,
    x_msg_data          OUT NOCOPY    VARCHAR2 );


--[llc] Cancellation Amount Calculation

/*
  These functions [ Get_hdr_cancelled_amount() and Get_line_cancelled_amount() ]
  calculates the cancelled amounts for a contract or a contract line.
  Cancellation amount is exclusive of the tax amount.

  These functions are defined to be called from post_query of oks_headers and oks_lines respectively.
  This will populate the appropriate fields on the form.
*/


FUNCTION Get_hdr_cancelled_amount (p_id in Number) RETURN NUMBER;

FUNCTION Get_line_cancelled_amount (p_cle_id in Number, p_id in Number) RETURN NUMBER;


--[llc] Procedure to clear/relink renewal links

Procedure Line_Renewal_links (
    p_api_version       IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_target_chr_id     IN NUMBER ,
    p_target_line_id	IN NUMBER ,
    clean_relink_flag   IN VARCHAR2 default 'CLEAN');



END OKC_CONTRACT_PVT;

 

/
