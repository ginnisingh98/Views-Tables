--------------------------------------------------------
--  DDL for Package OKL_SPLIT_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SPLIT_ASSET_PUB" AUTHID CURRENT_USER As
  /* $Header: OKLPSPAS.pls 120.3 2007/12/14 06:04:07 rpillay ship $ */

  subtype trxv_rec_type is OKL_SPLIT_ASSET_PVT.trxv_rec_type;
  subtype txlv_rec_type is OKL_SPLIT_ASSET_PVT.txlv_rec_type;
  subtype txdv_rec_type is OKL_SPLIT_ASSET_PVT.txdv_rec_type;
  subtype txdv_tbl_type is OKL_SPLIT_ASSET_PVT.txdv_tbl_type;
  subtype itiv_rec_type is OKL_SPLIT_ASSET_PVT.itiv_rec_type;
  subtype itiv_tbl_type is OKL_SPLIT_ASSET_PVT.itiv_tbl_type;
--  subtype cimv_rec_type is OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
  subtype cimv_rec_type is OKL_SPLIT_ASSET_PVT.cimv_rec_type;
  subtype klev_rec_type is OKL_SPLIT_ASSET_PVT.klev_rec_type;
--  subtype clev_rec_type is OKC_CONTRACT_PUB.clev_rec_type;
  subtype clev_rec_type is OKL_SPLIT_ASSET_PVT.clev_rec_type;

  subtype cle_rec_type is OKL_SPLIT_ASSET_PVT.cle_rec_type;
  subtype cle_tbl_type is OKL_SPLIT_ASSET_PVT.cle_tbl_type;
  subtype ast_line_rec_type is OKL_SPLIT_ASSET_PVT.ast_line_rec_type;

  subtype ib_rec_type is OKL_SPLIT_ASSET_PVT.ib_rec_type;
  subtype ib_tbl_type is OKL_SPLIT_ASSET_PVT.ib_tbl_type;

FUNCTION is_serialized(p_cle_id IN NUMBER) Return VARCHAR2;

PROCEDURE Create_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_split_into_individuals_yn IN VARCHAR2,
                                   p_split_into_units IN NUMBER,
                                   p_ib_tbl    IN  ib_tbl_type,
                                   x_txdv_tbl  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec  OUT NOCOPY trxv_rec_type);

PROCEDURE Create_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_split_into_individuals_yn IN VARCHAR2,
                                   p_split_into_units IN NUMBER,
                                   x_txdv_tbl  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec  OUT NOCOPY trxv_rec_type);

------------------------
--Bug# 3156924
------------------------
 Procedure validate_trx_date(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_chr_id         IN  NUMBER,
                              p_trx_date       IN  VARCHAR2);

 PROCEDURE Create_Split_Transaction(p_api_version               IN  NUMBER,
                                   p_init_msg_list             IN  VARCHAR2,
                                   x_return_status             OUT NOCOPY VARCHAR2,
                                   x_msg_count                 OUT NOCOPY NUMBER,
                                   x_msg_data                  OUT NOCOPY VARCHAR2,
                                   p_cle_id                    IN  NUMBER,
                                   p_split_into_individuals_yn IN  VARCHAR2,
                                   p_split_into_units          IN  NUMBER,
                                   p_ib_tbl                    IN  ib_tbl_type,
                                   --Bug# 3156924
                                   p_trx_date                  IN  DATE,
                                   --bug# 3156924
                                   x_txdv_tbl                  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec                  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec                  OUT NOCOPY trxv_rec_type);

 PROCEDURE Create_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_split_into_individuals_yn IN VARCHAR2,
                                   p_split_into_units IN NUMBER,
                                   p_trx_date  IN  DATE,
                                   x_txdv_tbl  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec  OUT NOCOPY trxv_rec_type);
------------------------
--Bug# 3156924
------------------------

Procedure Update_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_txdv_tbl      IN  txdv_tbl_type,
                                   x_txdv_tbl      OUT NOCOPY txdv_tbl_type);

PROCEDURE Split_Fixed_Asset(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_txdv_tbl      IN  txdv_tbl_type,
                            p_txlv_rec      IN  txlv_rec_type,
                            x_cle_tbl       OUT NOCOPY cle_tbl_type,
                            p_source_call   IN VARCHAR2 DEFAULT 'UI');

Procedure Split_Fixed_Asset(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_cle_id        IN  NUMBER,
                            x_cle_tbl       OUT NOCOPY cle_tbl_type,
                            p_source_call   IN VARCHAR2 DEFAULT 'UI');

Procedure Is_Inv_Item_Serialized(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_inv_item_id   IN  NUMBER,
                            p_chr_id        IN  NUMBER,
                            p_cle_id        IN  NUMBER,
                            x_serialized    OUT NOCOPY VARCHAR2);

Procedure Is_Asset_Serialized(p_api_version      IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_cle_id           IN  NUMBER,
                              x_serialized       OUT NOCOPY VARCHAR2);

Procedure Asset_Not_Srlz_Halt(p_api_version      IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_cle_id           IN  NUMBER,
                              x_serialized       OUT NOCOPY VARCHAR2);

Procedure Item_Not_Srlz_Halt(p_api_version       IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_inv_item_id      IN  NUMBER,
                              p_chr_id           IN  NUMBER,
                              p_cle_id           IN  NUMBER,
                              x_serialized       OUT NOCOPY VARCHAR2);

Procedure create_split_comp_srl_num(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_itiv_tbl      IN  itiv_tbl_type,
                            x_itiv_tbl      OUT NOCOPY itiv_tbl_type);

Procedure Cancel_Split_Asset_Trs
                           (p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status OUT NOCOPY   VARCHAR2,
                            x_msg_count     OUT NOCOPY   NUMBER,
                            x_msg_data      OUT NOCOPY   VARCHAR2,
                            p_cle_id        IN  NUMBER);

END OKL_SPLIT_ASSET_PUB;

/
