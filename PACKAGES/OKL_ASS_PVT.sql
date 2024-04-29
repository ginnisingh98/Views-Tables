--------------------------------------------------------
--  DDL for Package OKL_ASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ASS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSASSS.pls 120.0 2005/11/30 17:17:55 stmathew noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_ASS_PVT';
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
  TYPE ass_rec_type IS RECORD (
   id                             okl_assets_b.id%TYPE
  ,object_version_number          okl_assets_b.object_version_number%TYPE
  ,attribute_category             okl_assets_b.attribute_category%TYPE
  ,attribute1                     okl_assets_b.attribute1%TYPE
  ,attribute2                     okl_assets_b.attribute2%TYPE
  ,attribute3                     okl_assets_b.attribute3%TYPE
  ,attribute4                     okl_assets_b.attribute4%TYPE
  ,attribute5                     okl_assets_b.attribute5%TYPE
  ,attribute6                     okl_assets_b.attribute6%TYPE
  ,attribute7                     okl_assets_b.attribute7%TYPE
  ,attribute8                     okl_assets_b.attribute8%TYPE
  ,attribute9                     okl_assets_b.attribute9%TYPE
  ,attribute10                    okl_assets_b.attribute10%TYPE
  ,attribute11                    okl_assets_b.attribute11%TYPE
  ,attribute12                    okl_assets_b.attribute12%TYPE
  ,attribute13                    okl_assets_b.attribute13%TYPE
  ,attribute14                    okl_assets_b.attribute14%TYPE
  ,attribute15                    okl_assets_b.attribute15%TYPE
  ,parent_object_code             okl_assets_b.parent_object_code%TYPE
  ,parent_object_id               okl_assets_b.parent_object_id%TYPE
  ,asset_number                   okl_assets_b.asset_number%TYPE
  ,install_site_id                okl_assets_b.install_site_id%TYPE
  ,structured_pricing             okl_assets_b.structured_pricing%TYPE
  ,rate_template_id               okl_assets_b.rate_template_id%TYPE
  ,rate_card_id                   okl_assets_b.rate_card_id%TYPE
  ,lease_rate_factor              okl_assets_b.lease_rate_factor%TYPE
  ,target_arrears                 okl_assets_b.target_arrears%TYPE
  ,oec                            okl_assets_b.oec%TYPE
  ,oec_percentage                 okl_assets_b.oec_percentage%TYPE
  ,end_of_term_value_default      okl_assets_b.end_of_term_value_default%TYPE
  ,end_of_term_value              okl_assets_b.end_of_term_value%TYPE
  ,orig_asset_id				  okl_assets_b.orig_asset_id%TYPE
  ,target_amount                  okl_assets_b.target_amount%TYPE
  ,target_frequency               okl_assets_b.target_frequency%TYPE
  );

  -- Do not include WHO, LANGUAGE and SFWT_FLAG columns in the _TL record structure
  TYPE asstl_rec_type IS RECORD (
   id                             okl_assets_tl.id%TYPE
  ,short_description              okl_assets_tl.short_description%TYPE
  ,description                    okl_assets_tl.description%TYPE
  ,comments                       okl_assets_tl.comments%TYPE
  );

  -- view record structure
  TYPE assv_rec_type IS RECORD (
   id                             okl_assets_b.id%TYPE
  ,object_version_number          okl_assets_b.object_version_number%TYPE
  ,attribute_category             okl_assets_b.attribute_category%TYPE
  ,attribute1                     okl_assets_b.attribute1%TYPE
  ,attribute2                     okl_assets_b.attribute2%TYPE
  ,attribute3                     okl_assets_b.attribute3%TYPE
  ,attribute4                     okl_assets_b.attribute4%TYPE
  ,attribute5                     okl_assets_b.attribute5%TYPE
  ,attribute6                     okl_assets_b.attribute6%TYPE
  ,attribute7                     okl_assets_b.attribute7%TYPE
  ,attribute8                     okl_assets_b.attribute8%TYPE
  ,attribute9                     okl_assets_b.attribute9%TYPE
  ,attribute10                    okl_assets_b.attribute10%TYPE
  ,attribute11                    okl_assets_b.attribute11%TYPE
  ,attribute12                    okl_assets_b.attribute12%TYPE
  ,attribute13                    okl_assets_b.attribute13%TYPE
  ,attribute14                    okl_assets_b.attribute14%TYPE
  ,attribute15                    okl_assets_b.attribute15%TYPE
  ,parent_object_code             okl_assets_b.parent_object_code%TYPE
  ,parent_object_id               okl_assets_b.parent_object_id%TYPE
  ,asset_number                   okl_assets_b.asset_number%TYPE
  ,install_site_id                okl_assets_b.install_site_id%TYPE
  ,structured_pricing             okl_assets_b.structured_pricing%TYPE
  ,rate_template_id               okl_assets_b.rate_template_id%TYPE
  ,rate_card_id                   okl_assets_b.rate_card_id%TYPE
  ,lease_rate_factor              okl_assets_b.lease_rate_factor%TYPE
  ,target_arrears                 okl_assets_b.target_arrears%TYPE
  ,oec                            okl_assets_b.oec%TYPE
  ,oec_percentage                 okl_assets_b.oec_percentage%TYPE
  ,end_of_term_value_default      okl_assets_b.end_of_term_value_default%TYPE
  ,end_of_term_value              okl_assets_b.end_of_term_value%TYPE
  ,orig_asset_id				  okl_assets_b.orig_asset_id%TYPE
  ,target_amount                  okl_assets_b.target_amount%TYPE
  ,target_frequency               okl_assets_b.target_frequency%TYPE
  ,short_description              okl_assets_tl.short_description%TYPE
  ,description                    okl_assets_tl.description%TYPE
  ,comments                       okl_assets_tl.comments%TYPE
  );

  TYPE assv_tbl_type IS TABLE OF assv_rec_type INDEX BY BINARY_INTEGER;

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
    p_assv_tbl                     IN assv_tbl_type,
    x_assv_tbl                     OUT NOCOPY assv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_assv_tbl                     IN assv_tbl_type,
    x_assv_tbl                     OUT NOCOPY assv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_assv_tbl                     IN assv_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_assv_rec                     IN assv_rec_type,
    x_assv_rec                     OUT NOCOPY assv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_assv_rec                     IN assv_rec_type,
    x_assv_rec                     OUT NOCOPY assv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_assv_rec                     IN assv_rec_type);

END OKL_ASS_PVT;

 

/
