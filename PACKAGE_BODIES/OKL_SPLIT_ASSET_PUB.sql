--------------------------------------------------------
--  DDL for Package Body OKL_SPLIT_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPLIT_ASSET_PUB" As
  /* $Header: OKLPSPAB.pls 120.3 2007/12/14 06:04:50 rpillay ship $ */
FUNCTION is_serialized(p_cle_id IN NUMBER) Return VARCHAR2 is
  l_serialized VARCHAR2(1) default OKL_API.G_FALSE;
Begin
  l_serialized := OKL_SPLIT_ASSET_PVT.IS_SERIALIZED(p_cle_id => p_cle_id);
  Return(l_serialized);
End is_serialized;
PROCEDURE Create_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_split_into_individuals_yn IN VARCHAR2,
                                   p_split_into_units IN NUMBER,
                                   p_ib_tbl    IN  ib_tbl_type,
                                   x_txdv_tbl  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec  OUT NOCOPY trxv_rec_type) IS
Begin
     OKL_SPLIT_ASSET_PVT.Create_Split_Transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_cle_id        => p_cle_id,
                                   p_split_into_individuals_yn => p_split_into_individuals_yn,
                                   p_split_into_units => p_split_into_units,
                                   p_ib_tbl   => p_ib_tbl,
                                   x_txdv_tbl  => x_txdv_tbl,
                                   x_txlv_rec  => x_txlv_rec,
                                   x_trxv_rec  => x_trxv_rec);
End create_split_transaction;

PROCEDURE Create_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_split_into_individuals_yn IN VARCHAR2,
                                   p_split_into_units IN NUMBER,
                                   x_txdv_tbl  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec  OUT NOCOPY trxv_rec_type) IS
Begin
     OKL_SPLIT_ASSET_PVT.Create_Split_Transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_cle_id        => p_cle_id,
                                   p_split_into_individuals_yn => p_split_into_individuals_yn,
                                   p_split_into_units => p_split_into_units,
                                   x_txdv_tbl  => x_txdv_tbl,
                                   x_txlv_rec  => x_txlv_rec,
                                   x_trxv_rec  => x_trxv_rec);
End create_split_transaction;

-----------------------
--Bug# 3156924
-----------------------
 Procedure validate_trx_date(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_chr_id         IN  NUMBER,
                              p_trx_date       IN  VARCHAR2) is
  BEGIN
      OKL_SPLIT_ASSET_PVT.validate_trx_date
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_chr_id        => p_chr_id,
                            p_trx_date      => p_trx_date);
  End validate_trx_date;

  PROCEDURE Create_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_split_into_individuals_yn IN VARCHAR2,
                                   p_split_into_units IN NUMBER,
                                   p_ib_tbl    IN  ib_tbl_type,
                                   p_trx_date  IN  date,
                                   x_txdv_tbl  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec  OUT NOCOPY trxv_rec_type) IS
  Begin
     OKL_SPLIT_ASSET_PVT.Create_Split_Transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_cle_id        => p_cle_id,
                                   p_split_into_individuals_yn => p_split_into_individuals_yn,
                                   p_split_into_units => p_split_into_units,
                                   p_ib_tbl   => p_ib_tbl,
                                   p_trx_date => p_trx_date,
                                   x_txdv_tbl  => x_txdv_tbl,
                                   x_txlv_rec  => x_txlv_rec,
                                   x_trxv_rec  => x_trxv_rec);
  End create_split_transaction;

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
                                   x_trxv_rec  OUT NOCOPY trxv_rec_type) IS
  Begin
     OKL_SPLIT_ASSET_PVT.Create_Split_Transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_cle_id        => p_cle_id,
                                   p_split_into_individuals_yn => p_split_into_individuals_yn,
                                   p_split_into_units => p_split_into_units,
                                   p_trx_date  => p_trx_date,
                                   x_txdv_tbl  => x_txdv_tbl,
                                   x_txlv_rec  => x_txlv_rec,
                                   x_trxv_rec  => x_trxv_rec);
End create_split_transaction;
------------------
--Bug# 3156924
-----------------

PROCEDURE Update_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_txdv_tbl      IN  txdv_tbl_type,
                                   x_txdv_tbl      OUT NOCOPY txdv_tbl_type) is
begin
    okl_split_asset_pvt.Update_Split_Transaction(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_cle_id        => p_cle_id,
                                   p_txdv_tbl      => p_txdv_tbl,
                                   x_txdv_tbl      => x_txdv_tbl);
end update_split_transaction;

PROCEDURE Split_Fixed_Asset(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_txdv_tbl      IN  txdv_tbl_type,
                            p_txlv_rec      IN  txlv_rec_type,
                            x_cle_tbl       OUT NOCOPY cle_tbl_type,
                            p_source_call   IN VARCHAR2 DEFAULT 'UI') is
Begin
     okl_split_asset_pvt.Split_Fixed_Asset
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_txdv_tbl      => p_txdv_tbl,
                            p_txlv_rec      => p_txlv_rec,
                            x_cle_tbl       => x_cle_tbl,
                            p_source_call   => p_source_call);
End Split_Fixed_Asset;
PROCEDURE Split_Fixed_Asset(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_cle_id        IN  NUMBER,
                            x_cle_tbl       OUT NOCOPY cle_tbl_type,
                            p_source_call   IN VARCHAR2 DEFAULT 'UI')  is
Begin
     okl_split_asset_pvt.Split_Fixed_Asset
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_cle_id        => p_cle_id,
                            x_cle_tbl       => x_cle_tbl,
                            p_source_call   => p_source_call);
End Split_Fixed_Asset;

Procedure Is_Inv_Item_Serialized(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 ,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_inv_item_id   IN  NUMBER,
                            p_chr_id        IN  NUMBER,
                            p_cle_id        IN  NUMBER,
                            x_serialized    OUT NOCOPY VARCHAR2) is
Begin
       OKL_SPLIT_ASSET_PVT.Is_Inv_Item_Serialized
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_inv_item_id   => p_inv_item_id,
                            p_chr_id        => p_chr_id,
                            p_cle_id        => p_cle_id,
                            x_serialized    => x_serialized);
End Is_Inv_Item_serialized;

Procedure Is_Asset_Serialized(p_api_version      IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_cle_id           IN  NUMBER,
                              x_serialized       OUT NOCOPY VARCHAR2) is
Begin
     OKL_SPLIT_ASSET_PVT.Is_Asset_Serialized
                         (p_api_version      => p_api_version,
                          p_init_msg_list    => p_init_msg_list,
                          x_return_status    => x_return_status,
                          x_msg_count        => x_msg_count,
                          x_msg_data         => x_msg_data,
                          p_cle_id           => p_cle_id,
                          x_serialized       => x_serialized);
End Is_asset_Serialized;

Procedure Asset_Not_Srlz_Halt(p_api_version      IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_cle_id           IN  NUMBER,
                              x_serialized       OUT NOCOPY VARCHAR2) is
Begin
    OKL_SPLIT_ASSET_PVT.Asset_Not_Srlz_Halt
                         (p_api_version      => p_api_version,
                          p_init_msg_list    => p_init_msg_list,
                          x_return_status    => x_return_status,
                          x_msg_count        => x_msg_count,
                          x_msg_data         => x_msg_data,
                          p_cle_id           => p_cle_id,
                          x_serialized       => x_serialized);
End Asset_Not_Srlz_Halt;

Procedure Item_Not_Srlz_Halt(p_api_version       IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_inv_item_id      IN  NUMBER,
                              p_chr_id           IN  NUMBER,
                              p_cle_id           IN  NUMBER,
                              x_serialized       OUT NOCOPY VARCHAR2) is
Begin
       OKL_SPLIT_ASSET_PVT.Item_Not_Srlz_Halt
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_inv_item_id   => p_inv_item_id,
                            p_chr_id        => p_chr_id,
                            p_cle_id        => p_cle_id,
                            x_serialized    => x_serialized);
End Item_Not_Srlz_Halt;

Procedure create_split_comp_srl_num(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 ,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_itiv_tbl      IN  itiv_tbl_type,
                            x_itiv_tbl      OUT NOCOPY itiv_tbl_type) is
Begin
     OKL_SPLIT_ASSET_PVT.create_split_comp_srl_num
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_itiv_tbl      => p_itiv_tbl,
                            x_itiv_tbl      => x_itiv_tbl);
End create_split_comp_srl_num;

Procedure Cancel_Split_Asset_Trs
                           (p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status OUT NOCOPY   VARCHAR2,
                            x_msg_count     OUT NOCOPY   NUMBER,
                            x_msg_data      OUT NOCOPY   VARCHAR2,
                            p_cle_id        IN  NUMBER) IS
Begin
    OKL_SPLIT_ASSET_PVT.Cancel_Split_Asset_Trs
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_cle_id        => p_cle_id);
End Cancel_Split_Asset_Trs;

END OKL_SPLIT_ASSET_PUB;

/
