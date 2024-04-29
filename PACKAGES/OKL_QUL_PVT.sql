--------------------------------------------------------
--  DDL for Package OKL_QUL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QUL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSQULS.pls 120.1 2005/08/31 23:33:25 rravikir noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_QUL_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(30)  := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
  G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
  G_COL_ERROR            CONSTANT VARCHAR2(30)  := 'OKL_COL_ERROR';
  G_OVN_ERROR            CONSTANT VARCHAR2(30)  := 'OKL_OVN_ERROR';
  G_OVN_ERROR2           CONSTANT VARCHAR2(30)  := 'OKL_OVN_ERROR2';
  G_OVN_ERROR3           CONSTANT VARCHAR2(30)  := 'OKL_OVN_ERROR3';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
  G_COL_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'COL_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLERRM';

  ------------------
  -- DATA STRUCTURES
  ------------------

  -- Do not include WHO columns in the base table record structure
  TYPE qul_rec_type IS RECORD (
   id                             okl_quote_subpool_usage.id%TYPE
  ,object_version_number          okl_quote_subpool_usage.object_version_number%TYPE
  ,attribute_category             okl_quote_subpool_usage.attribute_category%TYPE
  ,attribute1                     okl_quote_subpool_usage.attribute1%TYPE
  ,attribute2                     okl_quote_subpool_usage.attribute2%TYPE
  ,attribute3                     okl_quote_subpool_usage.attribute3%TYPE
  ,attribute4                     okl_quote_subpool_usage.attribute4%TYPE
  ,attribute5                     okl_quote_subpool_usage.attribute5%TYPE
  ,attribute6                     okl_quote_subpool_usage.attribute6%TYPE
  ,attribute7                     okl_quote_subpool_usage.attribute7%TYPE
  ,attribute8                     okl_quote_subpool_usage.attribute8%TYPE
  ,attribute9                     okl_quote_subpool_usage.attribute9%TYPE
  ,attribute10                    okl_quote_subpool_usage.attribute10%TYPE
  ,attribute11                    okl_quote_subpool_usage.attribute11%TYPE
  ,attribute12                    okl_quote_subpool_usage.attribute12%TYPE
  ,attribute13                    okl_quote_subpool_usage.attribute13%TYPE
  ,attribute14                    okl_quote_subpool_usage.attribute14%TYPE
  ,attribute15                    okl_quote_subpool_usage.attribute15%TYPE
  ,subpool_trx_id                 okl_quote_subpool_usage.subpool_trx_id%TYPE
  ,source_type_code               okl_quote_subpool_usage.source_type_code%TYPE
  ,source_object_id               okl_quote_subpool_usage.source_object_id%TYPE
  ,asset_number                   okl_quote_subpool_usage.asset_number%TYPE
  ,asset_start_date               okl_quote_subpool_usage.asset_start_date%TYPE
  ,subsidy_pool_id                okl_quote_subpool_usage.subsidy_pool_id%TYPE
  ,subsidy_pool_amount            okl_quote_subpool_usage.subsidy_pool_amount%TYPE
  ,subsidy_pool_currency_code     okl_quote_subpool_usage.subsidy_pool_currency_code%TYPE
  ,subsidy_id                     okl_quote_subpool_usage.subsidy_id%TYPE
  ,subsidy_amount                 okl_quote_subpool_usage.subsidy_amount%TYPE
  ,subsidy_currency_code          okl_quote_subpool_usage.subsidy_currency_code%TYPE
  ,vendor_id                      okl_quote_subpool_usage.vendor_id%TYPE
  ,conversion_rate                okl_quote_subpool_usage.conversion_rate%TYPE
  );

  -- view record structure
  TYPE qulv_rec_type IS RECORD (
   id                             okl_quote_subpool_usage.id%TYPE
  ,object_version_number          okl_quote_subpool_usage.object_version_number%TYPE
  ,attribute_category             okl_quote_subpool_usage.attribute_category%TYPE
  ,attribute1                     okl_quote_subpool_usage.attribute1%TYPE
  ,attribute2                     okl_quote_subpool_usage.attribute2%TYPE
  ,attribute3                     okl_quote_subpool_usage.attribute3%TYPE
  ,attribute4                     okl_quote_subpool_usage.attribute4%TYPE
  ,attribute5                     okl_quote_subpool_usage.attribute5%TYPE
  ,attribute6                     okl_quote_subpool_usage.attribute6%TYPE
  ,attribute7                     okl_quote_subpool_usage.attribute7%TYPE
  ,attribute8                     okl_quote_subpool_usage.attribute8%TYPE
  ,attribute9                     okl_quote_subpool_usage.attribute9%TYPE
  ,attribute10                    okl_quote_subpool_usage.attribute10%TYPE
  ,attribute11                    okl_quote_subpool_usage.attribute11%TYPE
  ,attribute12                    okl_quote_subpool_usage.attribute12%TYPE
  ,attribute13                    okl_quote_subpool_usage.attribute13%TYPE
  ,attribute14                    okl_quote_subpool_usage.attribute14%TYPE
  ,attribute15                    okl_quote_subpool_usage.attribute15%TYPE
  ,subpool_trx_id                 okl_quote_subpool_usage.subpool_trx_id%TYPE
  ,source_type_code               okl_quote_subpool_usage.source_type_code%TYPE
  ,source_object_id               okl_quote_subpool_usage.source_object_id%TYPE
  ,asset_number                   okl_quote_subpool_usage.asset_number%TYPE
  ,asset_start_date               okl_quote_subpool_usage.asset_start_date%TYPE
  ,subsidy_pool_id                okl_quote_subpool_usage.subsidy_pool_id%TYPE
  ,subsidy_pool_amount            okl_quote_subpool_usage.subsidy_pool_amount%TYPE
  ,subsidy_pool_currency_code     okl_quote_subpool_usage.subsidy_pool_currency_code%TYPE
  ,subsidy_id                     okl_quote_subpool_usage.subsidy_id%TYPE
  ,subsidy_amount                 okl_quote_subpool_usage.subsidy_amount%TYPE
  ,subsidy_currency_code          okl_quote_subpool_usage.subsidy_currency_code%TYPE
  ,vendor_id                      okl_quote_subpool_usage.vendor_id%TYPE
  ,conversion_rate                okl_quote_subpool_usage.conversion_rate%TYPE
  );

  TYPE qulv_tbl_type IS TABLE OF qulv_rec_type INDEX BY BINARY_INTEGER;

  ----------------
  -- PROGRAM UNITS
  ----------------

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_tbl                     IN qulv_tbl_type,
    x_qulv_tbl                     OUT NOCOPY qulv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_tbl                     IN qulv_tbl_type,
    x_qulv_tbl                     OUT NOCOPY qulv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_tbl                     IN qulv_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_rec                     IN qulv_rec_type,
    x_qulv_rec                     OUT NOCOPY qulv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_rec                     IN qulv_rec_type,
    x_qulv_rec                     OUT NOCOPY qulv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_rec                     IN qulv_rec_type);

END OKL_QUL_PVT;

 

/
