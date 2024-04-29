--------------------------------------------------------
--  DDL for Package OKL_CREATE_KLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREATE_KLE_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRKLLS.pls 120.3 2007/09/19 17:57:31 rbruno ship $ */

  subtype klev_rec_type is OKL_CONTRACT_PUB.klev_rec_type;
  subtype klev_tbl_type is OKL_CONTRACT_PUB.klev_tbl_type;
  subtype clev_rec_type is OKL_OKC_MIGRATION_PVT.clev_rec_type;
  subtype clev_tbl_type is OKL_OKC_MIGRATION_PVT.clev_tbl_type;
  subtype cimv_rec_type is OKL_OKC_MIGRATION_PVT.cimv_rec_type;
  subtype cimv_tbl_type is OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
  subtype cplv_rec_type is OKL_OKC_MIGRATION_PVT.cplv_rec_type;
  subtype trxv_rec_type is OKL_TRX_ASSETS_PUB.thpv_rec_type;
  subtype talv_rec_type is OKL_TXL_ASSETS_PUB.tlpv_rec_type;
  subtype itiv_rec_type is OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;
  subtype itiv_tbl_type is OKL_TXL_ITM_INSTS_PUB.iipv_tbl_type;
  subtype txdv_tbl_type is OKL_TXD_ASSETS_PUB.adpv_tbl_type;
  subtype txdv_rec_type is OKL_TXD_ASSETS_PUB.adpv_rec_type;
  G_FIN_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_FIN_LINE_LTY_ID	                  OKC_LINE_STYLES_V.ID%TYPE := 33;
  G_MODEL_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ITEM';
  G_MODEL_LINE_LTY_ID                     OKC_LINE_STYLES_V.ID%TYPE := 34;
  G_ADDON_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ADD_ITEM';
  G_FA_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_FA_LINE_LTY_ID                        OKC_LINE_STYLES_V.ID%TYPE := 42;
  G_INST_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_INST_LINE_LTY_ID                      OKC_LINE_STYLES_V.ID%TYPE := 43;
  G_IB_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';
  G_IB_LINE_LTY_ID                        OKC_LINE_STYLES_V.ID%TYPE := 45;

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

 --rbruno bug 6185552 start
    PROCEDURE get_nbv(p_api_version     IN  NUMBER,
                    p_init_msg_list   IN  VARCHAR2,
                    x_return_status   OUT NOCOPY VARCHAR2,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR2,
                    p_asset_id        IN  NUMBER,
                    p_book_type_code  IN  VARCHAR2,
                    p_chr_id          IN  NUMBER,
                    p_release_date    IN  DATE,
                    x_nbv             OUT NOCOPY Number);
 --rbruno bug 6185552 end

End OKL_CREATE_KLE_PVT;

/
