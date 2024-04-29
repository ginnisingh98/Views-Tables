--------------------------------------------------------
--  DDL for Package OKL_CREATE_KLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREATE_KLE_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPKLLS.pls 115.5 2002/11/30 08:36:15 spillaip noship $ */

  subtype klev_rec_type is OKL_CREATE_KLE_PVT.klev_rec_type;
  subtype klev_tbl_type is OKL_CREATE_KLE_PVT.klev_tbl_type;
  subtype clev_rec_type is OKL_CREATE_KLE_PVT.clev_rec_type;
  subtype clev_tbl_type is OKL_CREATE_KLE_PVT.clev_tbl_type;
  subtype cimv_rec_type is OKL_CREATE_KLE_PVT.cimv_rec_type;
  subtype cimv_tbl_type is OKL_CREATE_KLE_PVT.cimv_tbl_type;
  subtype cplv_rec_type is OKL_CREATE_KLE_PVT.cplv_rec_type;
  subtype trxv_rec_type is OKL_CREATE_KLE_PVT.trxv_rec_type;
  subtype talv_rec_type is OKL_CREATE_KLE_PVT.talv_rec_type;
  subtype itiv_rec_type is OKL_CREATE_KLE_PVT.itiv_rec_type;
  subtype itiv_tbl_type is OKL_CREATE_KLE_PVT.itiv_tbl_type;
  subtype txdv_tbl_type is OKL_TXD_ASSETS_PUB.adpv_tbl_type;
  subtype txdv_rec_type is OKL_TXD_ASSETS_PUB.adpv_rec_type;

  G_FIN_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_MODEL_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ITEM';
  G_ADDON_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ADD_ITEM';
  G_FA_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_INST_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_IB_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';


  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'SQLERRM';

-- Global variables for user hooks
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CREATE_KLE_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  g_klev_rec                             klev_rec_type;
  g_klev_tbl                             klev_tbl_type;
  g_clev_rec                             clev_rec_type;
  g_clev_tbl                             clev_tbl_type;

  g_cimv_rec                             cimv_rec_type;
  g_cimv_tbl                             cimv_tbl_type;
  g_cplv_rec                             cplv_rec_type;
  g_trxv_rec                             trxv_rec_type;
  g_talv_rec                             talv_rec_type;
  g_itiv_rec                             itiv_rec_type;
  g_itiv_tbl                             itiv_tbl_type;

  g_clev_fin_rec                         clev_rec_type;
  g_klev_fin_rec                         klev_rec_type;

  g_clev_model_rec                       clev_rec_type;
  g_klev_model_rec                       klev_rec_type;
  g_cimv_model_rec                       cimv_rec_type;

  g_clev_fa_rec                          clev_rec_type;
  g_klev_fa_rec                          klev_rec_type;
  g_cimv_fa_rec                          cimv_rec_type;
  g_trxv_fa_rec                          trxv_rec_type;
  g_talv_fa_rec                          talv_rec_type;

  g_clev_inst_rec                        clev_rec_type;
  g_klev_inst_rec                        klev_rec_type;
  g_itiv_inst_tbl                        itiv_tbl_type;

  g_clev_ib_rec                          clev_rec_type;
  g_clev_ib_tbl                          clev_tbl_type;
  g_klev_ib_rec                          klev_rec_type;
  g_cimv_ib_rec                          cimv_rec_type;
  g_trxv_ib_rec                          trxv_rec_type;
  g_itiv_ib_tbl                          itiv_tbl_type;
  g_itiv_ib_rec                          itiv_rec_type;

  g_txdv_tbl                             txdv_tbl_type;
  g_txdv_rec                             txdv_rec_type;

  PROCEDURE Update_fin_cap_cost(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type);

  Procedure Create_add_on_line(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            P_new_yn          IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number    IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_tbl        IN  clev_tbl_type,
            p_klev_tbl        IN  klev_tbl_type,
            p_cimv_tbl        IN  cimv_tbl_type,
            x_clev_tbl        OUT NOCOPY clev_tbl_type,
            x_klev_tbl        OUT NOCOPY klev_tbl_type,
            x_fin_clev_rec    OUT NOCOPY clev_rec_type,
            x_fin_klev_rec    OUT NOCOPY klev_rec_type,
            x_cimv_tbl        OUT NOCOPY cimv_tbl_type);

  PROCEDURE update_add_on_line(
            p_api_version   IN NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            p_cimv_tbl       IN  cimv_tbl_type,
            x_clev_tbl       OUT NOCOPY clev_tbl_type,
            x_klev_tbl       OUT NOCOPY klev_tbl_type,
            x_cimv_tbl       OUT NOCOPY cimv_tbl_type,
            x_fin_clev_rec   OUT NOCOPY clev_rec_type,
            x_fin_klev_rec   OUT NOCOPY klev_rec_type);

  PROCEDURE delete_add_on_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            x_fin_clev_rec   OUT NOCOPY clev_rec_type,
            x_fin_klev_rec   OUT NOCOPY klev_rec_type);

  PROCEDURE Create_party_roles_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cplv_rec       IN  cplv_rec_type,
            x_cplv_rec       OUT NOCOPY cplv_rec_type);

  PROCEDURE Update_party_roles_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cplv_rec       IN  cplv_rec_type,
            x_cplv_rec       OUT NOCOPY cplv_rec_type);

  PROCEDURE Create_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_fin_rec   IN  clev_rec_type,
            p_klev_fin_rec   IN  klev_rec_type,
            p_cimv_model_rec IN  cimv_rec_type,
            p_clev_fa_rec    IN  clev_rec_type,
            p_cimv_fa_rec    IN  cimv_rec_type,
            p_talv_fa_rec    IN  talv_rec_type,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_clev_model_rec OUT NOCOPY clev_rec_type,
            x_clev_fa_rec    OUT NOCOPY clev_rec_type,
            x_clev_ib_rec    OUT NOCOPY clev_rec_type);

  PROCEDURE Update_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_fin_rec   IN  clev_rec_type,
            p_klev_fin_rec   IN  klev_rec_type,
            p_clev_model_rec IN  clev_rec_type,
            p_cimv_model_rec IN  cimv_rec_type,
            p_clev_fa_rec    IN  clev_rec_type,
            p_cimv_fa_rec    IN  cimv_rec_type,
            p_talv_fa_rec    IN  talv_rec_type,
            p_clev_ib_rec    IN  clev_rec_type,
            p_itiv_ib_rec    IN  itiv_rec_type,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_clev_model_rec OUT NOCOPY clev_rec_type,
            x_clev_fa_rec    OUT NOCOPY clev_rec_type,
            x_clev_ib_rec    OUT NOCOPY clev_rec_type);

  PROCEDURE create_ints_ib_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_current_units  IN  OKL_TXL_ASSETS_V.CURRENT_UNITS%TYPE,
            p_clev_ib_rec    IN  clev_rec_type,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            x_clev_ib_tbl    OUT NOCOPY clev_tbl_type,
            x_itiv_ib_tbl    OUT NOCOPY itiv_tbl_type,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_klev_fin_rec   OUT NOCOPY klev_rec_type,
            x_cimv_model_rec OUT NOCOPY cimv_rec_type,
            x_cimv_fa_rec    OUT NOCOPY cimv_rec_type,
            x_talv_fa_rec    OUT NOCOPY talv_rec_type);

  PROCEDURE update_ints_ib_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_top_line_id    IN  OKC_K_LINES_V.ID%TYPE,
            p_dnz_chr_id     IN  OKC_K_HEADERS_V.ID%TYPE,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            x_clev_ib_tbl    OUT NOCOPY clev_tbl_type,
            x_itiv_ib_tbl    OUT NOCOPY itiv_tbl_type);

  PROCEDURE delete_ints_ib_line(
            p_api_version         IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2,
            P_new_yn              IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number        IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_ib_tbl         IN  clev_tbl_type,
            x_clev_fin_rec        OUT NOCOPY clev_rec_type,
            x_klev_fin_rec        OUT NOCOPY klev_rec_type,
            x_cimv_model_rec      OUT NOCOPY cimv_rec_type,
            x_cimv_fa_rec         OUT NOCOPY cimv_rec_type,
            x_talv_fa_rec         OUT NOCOPY talv_rec_type);

  PROCEDURE Create_asset_line_details(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_txdv_tbl       IN  txdv_tbl_type,
            x_txdv_tbl       OUT NOCOPY txdv_tbl_type);

  PROCEDURE update_asset_line_details(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_txdv_tbl       IN  txdv_tbl_type,
            x_txdv_tbl       OUT NOCOPY txdv_tbl_type);

End OKL_CREATE_KLE_PUB;

 

/
