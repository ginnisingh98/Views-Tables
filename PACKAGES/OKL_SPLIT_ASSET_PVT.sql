--------------------------------------------------------
--  DDL for Package OKL_SPLIT_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SPLIT_ASSET_PVT" AUTHID CURRENT_USER As
  /* $Header: OKLRSPAS.pls 120.5 2007/12/20 22:50:55 srsreeni ship $ */

  subtype trxv_rec_type is OKL_TRX_ASSETS_PUB.thpv_rec_type;
  subtype txlv_rec_type is OKL_TXL_ASSETS_PUB.tlpv_rec_type;
  subtype txdv_rec_type is OKL_TXD_ASSETS_PUB.adpv_rec_type;
  subtype txdv_tbl_type is OKL_TXD_ASSETS_PUB.adpv_tbl_type;
  subtype itiv_rec_type is OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;
  subtype itiv_tbl_type is OKL_TXL_ITM_INSTS_PUB.iipv_tbl_type;
--  subtype cimv_rec_type is OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
  subtype cimv_rec_type is OKL_OKC_MIGRATION_PVT.cimv_rec_type;
  subtype klev_rec_type is OKL_CONTRACT_PUB.klev_rec_type;
--  subtype clev_rec_type is OKC_CONTRACT_PUB.clev_rec_type;
  subtype clev_rec_type is OKL_OKC_MIGRATION_PVT.clev_rec_type;

  type cle_rec_type is record (cle_id NUMBER := OKL_API.G_MISS_NUM);
  type cle_tbl_type is table of cle_rec_type INDEX BY BINARY_INTEGER;

  type    ast_line_rec_type is record (
          ID1                       NUMBER:= OKL_API.G_MISS_NUM,
          ID2                       OKX_ASSET_LINES_V.ID2%TYPE := OKL_API.G_MISS_CHAR,
          NAME                      OKX_ASSET_LINES_V.NAME%TYPE := OKL_API.G_MISS_CHAR,
          DESCRIPTION               OKX_ASSET_LINES_V.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
          ITEM_DESCRIPTION          OKX_ASSET_LINES_V.ITEM_DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
          COMMENTS                  OKX_ASSET_LINES_V.COMMENTS%TYPE := OKL_API.G_MISS_CHAR,
          CHR_ID                    NUMBER := OKL_API.G_MISS_NUM,
          DNZ_CHR_ID                NUMBER := OKL_API.G_MISS_NUM,
          LTY_CODE                  OKX_ASSET_LINES_V.LTY_CODE%TYPE := OKL_API.G_MISS_CHAR,
          LSE_TYPE                  OKX_ASSET_LINES_V.LSE_TYPE%TYPE := OKL_API.G_MISS_CHAR,
          LSE_PARENT_ID             NUMBER := OKL_API.G_MISS_NUM,
          PARENT_LINE_ID            NUMBER := OKL_API.G_MISS_NUM,
          LINE_NUMBER               OKX_ASSET_LINES_V.LINE_NUMBER%TYPE := OKL_API.G_MISS_CHAR,
          DATE_TERMINATED           OKX_ASSET_LINES_V.DATE_TERMINATED%TYPE := OKL_API.G_MISS_DATE,
          START_DATE_ACTIVE         OKX_ASSET_LINES_V.START_DATE_ACTIVE%TYPE := OKL_API.G_MISS_DATE,
          END_DATE_ACTIVE           OKX_ASSET_LINES_V.END_DATE_ACTIVE%TYPE := OKL_API.G_MISS_DATE,
          STATUS                    OKX_ASSET_LINES_V.STATUS%TYPE := OKL_API.G_MISS_CHAR,
          ASSET_ID                  NUMBER  := OKL_API.G_MISS_NUM,
          QUANTITY                  NUMBER := OKL_API.G_MISS_NUM,
          UNIT_OF_MEASURE_CODE      OKX_ASSET_LINES_V.UNIT_OF_MEASURE_CODE%TYPE := OKL_API.G_MISS_CHAR,
          ASSET_NUMBER              OKX_ASSET_LINES_V.ASSET_NUMBER%TYPE := OKL_API.G_MISS_CHAR,
          CORPORATE_BOOK            OKX_ASSET_LINES_V.CORPORATE_BOOK%TYPE := OKL_API.G_MISS_CHAR,
          LIFE_IN_MONTHS            NUMBER := OKL_API.G_MISS_NUM,
          ORIGINAL_COST             NUMBER := OKL_API.G_MISS_NUM,
          COST                      NUMBER := OKL_API.G_MISS_NUM,
          ADJUSTED_COST             NUMBER := OKL_API.G_MISS_NUM,
          TAG_NUMBER                OKX_ASSET_LINES_V.TAG_NUMBER%TYPE := OKL_API.G_MISS_CHAR,
          CURRENT_UNITS             NUMBER := OKL_API.G_MISS_NUM,
          SERIAL_NUMBER             OKX_ASSET_LINES_V.SERIAL_NUMBER%TYPE := OKL_API.G_MISS_CHAR,
          REVAL_CEILING             NUMBER := OKL_API.G_MISS_NUM,
          NEW_USED                  OKX_ASSET_LINES_V.NEW_USED%TYPE := OKL_API.G_MISS_CHAR,
          IN_SERVICE_DATE           OKX_ASSET_LINES_V.IN_SERVICE_DATE%TYPE := OKL_API.G_MISS_DATE,
          MANUFACTURER_NAME         OKX_ASSET_LINES_V.MANUFACTURER_NAME%TYPE := OKL_API.G_MISS_CHAR,
          MODEL_NUMBER              OKX_ASSET_LINES_V.MODEL_NUMBER%TYPE := OKL_API.G_MISS_CHAR,
          ASSET_TYPE                OKX_ASSET_LINES_V.ASSET_TYPE%TYPE := OKL_API.G_MISS_CHAR,
          SALVAGE_VALUE             NUMBER := OKL_API.G_MISS_NUM,
          PERCENT_SALVAGE_VALUE     NUMBER := OKL_API.G_MISS_NUM,
          DEPRECIATION_CATEGORY     NUMBER := OKL_API.G_MISS_NUM,
          DEPRN_START_DATE          OKX_ASSET_LINES_V.DEPRN_START_DATE%TYPE := OKL_API.G_MISS_DATE,
          DEPRN_METHOD_CODE         OKX_ASSET_LINES_V.DEPRN_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR,
          RATE_ADJUSTMENT_FACTOR    NUMBER := OKL_API.G_MISS_NUM,
          BASIC_RATE                NUMBER := OKL_API.G_MISS_NUM,
          ADJUSTED_RATE             NUMBER := OKL_API.G_MISS_NUM,
          RECOVERABLE_COST          NUMBER := OKL_API.G_MISS_NUM,
          ORG_ID                    NUMBER := OKL_API.G_MISS_NUM,
          SET_OF_BOOKS_ID           NUMBER := OKL_API.G_MISS_NUM,
          PROPERTY_TYPE_CODE        OKX_ASSET_LINES_V.PROPERTY_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR,
          PROPERTY_1245_1250_CODE   OKX_ASSET_LINES_V.PROPERTY_1245_1250_CODE%TYPE := OKL_API.G_MISS_CHAR,
          IN_USE_FLAG               OKX_ASSET_LINES_V.IN_USE_FLAG%TYPE := OKL_API.G_MISS_CHAR,
          OWNED_LEASED              OKX_ASSET_LINES_V.OWNED_LEASED%TYPE := OKL_API.G_MISS_CHAR,
          INVENTORIAL               OKX_ASSET_LINES_V.INVENTORIAL%TYPE := OKL_API.G_MISS_CHAR,
          LINE_STATUS               OKX_ASSET_LINES_V.LINE_STATUS%TYPE := OKL_API.G_MISS_CHAR
          );

--Bug #2723498 : 11.5.9 Split by serial numbers

  type   ib_rec_type is record
          (id NUMBER := OKL_API.G_MISS_NUM);

  type ib_tbl_type is table of ib_rec_type INDEX BY BINARY_INTEGER;


--Bug #2723498 Overloaded
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
--Bug #2723498
FUNCTION is_serialized(p_cle_id IN NUMBER) Return VARCHAR2;
--
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
                            --Bug# 6344223
                            p_source_call   IN VARCHAR2 DEFAULT 'UI');

Procedure Split_Fixed_Asset(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_cle_id        IN  NUMBER,
                            x_cle_tbl       OUT NOCOPY cle_tbl_type,
                            --Bug# 6344223
                            p_source_call   IN VARCHAR2 DEFAULT 'UI');

Procedure Is_Inv_Item_Serialized(p_api_version  IN  NUMBER,
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

--Bug# 6344223
PROCEDURE SPLIT_ASSET_AFTER_YIELD (p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status OUT NOCOPY   VARCHAR2,
                                   x_msg_count     OUT NOCOPY   NUMBER,
                                   x_msg_data      OUT NOCOPY   VARCHAR2,
                                   p_chr_id        IN  NUMBER);
--Bug 6667726
Procedure check_ser_num_checked(x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_cle_id        IN  NUMBER);
END OKL_SPLIT_ASSET_PVT;

/
