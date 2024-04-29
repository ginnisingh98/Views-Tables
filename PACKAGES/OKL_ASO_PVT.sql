--------------------------------------------------------
--  DDL for Package OKL_ASO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ASO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSASOS.pls 120.0 2005/11/30 17:17:53 stmathew noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_ASO_PVT';
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
  TYPE aso_rec_type IS RECORD (
   id                             okl_asset_components_b.id%TYPE
  ,object_version_number          okl_asset_components_b.object_version_number%TYPE
  ,attribute_category             okl_asset_components_b.attribute_category%TYPE
  ,attribute1                     okl_asset_components_b.attribute1%TYPE
  ,attribute2                     okl_asset_components_b.attribute2%TYPE
  ,attribute3                     okl_asset_components_b.attribute3%TYPE
  ,attribute4                     okl_asset_components_b.attribute4%TYPE
  ,attribute5                     okl_asset_components_b.attribute5%TYPE
  ,attribute6                     okl_asset_components_b.attribute6%TYPE
  ,attribute7                     okl_asset_components_b.attribute7%TYPE
  ,attribute8                     okl_asset_components_b.attribute8%TYPE
  ,attribute9                     okl_asset_components_b.attribute9%TYPE
  ,attribute10                    okl_asset_components_b.attribute10%TYPE
  ,attribute11                    okl_asset_components_b.attribute11%TYPE
  ,attribute12                    okl_asset_components_b.attribute12%TYPE
  ,attribute13                    okl_asset_components_b.attribute13%TYPE
  ,attribute14                    okl_asset_components_b.attribute14%TYPE
  ,attribute15                    okl_asset_components_b.attribute15%TYPE
  ,asset_id                       okl_asset_components_b.asset_id%TYPE
  ,inv_item_id                    okl_asset_components_b.inv_item_id%TYPE
  ,supplier_id                    okl_asset_components_b.supplier_id%TYPE
  ,primary_component              okl_asset_components_b.primary_component%TYPE
  ,unit_cost                      okl_asset_components_b.unit_cost%TYPE
  ,number_of_units                okl_asset_components_b.number_of_units%TYPE
  ,manufacturer_name              okl_asset_components_b.manufacturer_name%TYPE
  ,year_manufactured              okl_asset_components_b.year_manufactured%TYPE
  ,model_number                   okl_asset_components_b.model_number%TYPE
  );

  -- Do not include WHO, LANGUAGE and SFWT_FLAG columns in the _TL record structure
  TYPE asotl_rec_type IS RECORD (
   id                             okl_asset_components_tl.id%TYPE
  ,short_description              okl_asset_components_tl.short_description%TYPE
  ,description                    okl_asset_components_tl.description%TYPE
  ,comments                       okl_asset_components_tl.comments%TYPE
  );

  -- view record structure
  TYPE asov_rec_type IS RECORD (
   id                             okl_asset_components_b.id%TYPE
  ,object_version_number          okl_asset_components_b.object_version_number%TYPE
  ,attribute_category             okl_asset_components_b.attribute_category%TYPE
  ,attribute1                     okl_asset_components_b.attribute1%TYPE
  ,attribute2                     okl_asset_components_b.attribute2%TYPE
  ,attribute3                     okl_asset_components_b.attribute3%TYPE
  ,attribute4                     okl_asset_components_b.attribute4%TYPE
  ,attribute5                     okl_asset_components_b.attribute5%TYPE
  ,attribute6                     okl_asset_components_b.attribute6%TYPE
  ,attribute7                     okl_asset_components_b.attribute7%TYPE
  ,attribute8                     okl_asset_components_b.attribute8%TYPE
  ,attribute9                     okl_asset_components_b.attribute9%TYPE
  ,attribute10                    okl_asset_components_b.attribute10%TYPE
  ,attribute11                    okl_asset_components_b.attribute11%TYPE
  ,attribute12                    okl_asset_components_b.attribute12%TYPE
  ,attribute13                    okl_asset_components_b.attribute13%TYPE
  ,attribute14                    okl_asset_components_b.attribute14%TYPE
  ,attribute15                    okl_asset_components_b.attribute15%TYPE
  ,asset_id                       okl_asset_components_b.asset_id%TYPE
  ,inv_item_id                    okl_asset_components_b.inv_item_id%TYPE
  ,supplier_id                    okl_asset_components_b.supplier_id%TYPE
  ,primary_component              okl_asset_components_b.primary_component%TYPE
  ,unit_cost                      okl_asset_components_b.unit_cost%TYPE
  ,number_of_units                okl_asset_components_b.number_of_units%TYPE
  ,manufacturer_name              okl_asset_components_b.manufacturer_name%TYPE
  ,year_manufactured              okl_asset_components_b.year_manufactured%TYPE
  ,model_number                   okl_asset_components_b.model_number%TYPE
  ,short_description              okl_asset_components_tl.short_description%TYPE
  ,description                    okl_asset_components_tl.description%TYPE
  ,comments                       okl_asset_components_tl.comments%TYPE
  );

  TYPE asov_tbl_type IS TABLE OF asov_rec_type INDEX BY BINARY_INTEGER;

  ----------------
  -- PROGRAM UNITS
  ----------------
  PROCEDURE add_language;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asov_tbl                     IN asov_tbl_type,
    x_asov_tbl                     OUT NOCOPY asov_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asov_tbl                     IN asov_tbl_type,
    x_asov_tbl                     OUT NOCOPY asov_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asov_tbl                     IN asov_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asov_rec                     IN asov_rec_type,
    x_asov_rec                     OUT NOCOPY asov_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asov_rec                     IN asov_rec_type,
    x_asov_rec                     OUT NOCOPY asov_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asov_rec                     IN asov_rec_type);

END OKL_ASO_PVT;

 

/
