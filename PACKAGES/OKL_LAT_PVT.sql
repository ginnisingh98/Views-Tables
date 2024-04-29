--------------------------------------------------------
--  DDL for Package OKL_LAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LAT_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLSLATS.pls 120.2 2006/04/13 10:45:39 pagarg noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LAT_PVT';
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
  TYPE lat_rec_type IS RECORD (
   id                             okl_leaseapp_templates.id%TYPE
  ,object_version_number          okl_leaseapp_templates.object_version_number%TYPE
  ,attribute_category             okl_leaseapp_templates.attribute_category%TYPE
  ,attribute1                     okl_leaseapp_templates.attribute1%TYPE
  ,attribute2                     okl_leaseapp_templates.attribute2%TYPE
  ,attribute3                     okl_leaseapp_templates.attribute3%TYPE
  ,attribute4                     okl_leaseapp_templates.attribute4%TYPE
  ,attribute5                     okl_leaseapp_templates.attribute5%TYPE
  ,attribute6                     okl_leaseapp_templates.attribute6%TYPE
  ,attribute7                     okl_leaseapp_templates.attribute7%TYPE
  ,attribute8                     okl_leaseapp_templates.attribute8%TYPE
  ,attribute9                     okl_leaseapp_templates.attribute9%TYPE
  ,attribute10                    okl_leaseapp_templates.attribute10%TYPE
  ,attribute11                    okl_leaseapp_templates.attribute11%TYPE
  ,attribute12                    okl_leaseapp_templates.attribute12%TYPE
  ,attribute13                    okl_leaseapp_templates.attribute13%TYPE
  ,attribute14                    okl_leaseapp_templates.attribute14%TYPE
  ,attribute15                    okl_leaseapp_templates.attribute15%TYPE
  ,org_id                         okl_leaseapp_templates.org_id%TYPE
  ,name                           okl_leaseapp_templates.name%TYPE
  ,template_status                okl_leaseapp_templates.template_status%TYPE
  ,credit_review_purpose          okl_leaseapp_templates.credit_review_purpose%TYPE
  ,cust_credit_classification     okl_leaseapp_templates.cust_credit_classification%TYPE
  ,industry_class                 okl_leaseapp_templates.industry_class%TYPE
  ,industry_code                  okl_leaseapp_templates.industry_code%TYPE
  ,valid_from                     okl_leaseapp_templates.valid_from%TYPE
  ,valid_to                       okl_leaseapp_templates.valid_to%TYPE
  );

  -- view record structure
  TYPE latv_rec_type IS RECORD (
   id                             okl_leaseapp_templates.id%TYPE
  ,object_version_number          okl_leaseapp_templates.object_version_number%TYPE
  ,attribute_category             okl_leaseapp_templates.attribute_category%TYPE
  ,attribute1                     okl_leaseapp_templates.attribute1%TYPE
  ,attribute2                     okl_leaseapp_templates.attribute2%TYPE
  ,attribute3                     okl_leaseapp_templates.attribute3%TYPE
  ,attribute4                     okl_leaseapp_templates.attribute4%TYPE
  ,attribute5                     okl_leaseapp_templates.attribute5%TYPE
  ,attribute6                     okl_leaseapp_templates.attribute6%TYPE
  ,attribute7                     okl_leaseapp_templates.attribute7%TYPE
  ,attribute8                     okl_leaseapp_templates.attribute8%TYPE
  ,attribute9                     okl_leaseapp_templates.attribute9%TYPE
  ,attribute10                    okl_leaseapp_templates.attribute10%TYPE
  ,attribute11                    okl_leaseapp_templates.attribute11%TYPE
  ,attribute12                    okl_leaseapp_templates.attribute12%TYPE
  ,attribute13                    okl_leaseapp_templates.attribute13%TYPE
  ,attribute14                    okl_leaseapp_templates.attribute14%TYPE
  ,attribute15                    okl_leaseapp_templates.attribute15%TYPE
  ,org_id                         okl_leaseapp_templates.org_id%TYPE
  ,name                           okl_leaseapp_templates.name%TYPE
  ,template_status                okl_leaseapp_templates.template_status%TYPE
  ,credit_review_purpose          okl_leaseapp_templates.credit_review_purpose%TYPE
  ,cust_credit_classification     okl_leaseapp_templates.cust_credit_classification%TYPE
  ,industry_class                 okl_leaseapp_templates.industry_class%TYPE
  ,industry_code                  okl_leaseapp_templates.industry_code%TYPE
  ,valid_from                     okl_leaseapp_templates.valid_from%TYPE
  ,valid_to                       okl_leaseapp_templates.valid_to%TYPE
  );

  TYPE latv_tbl_type IS TABLE OF latv_rec_type INDEX BY BINARY_INTEGER;

  ----------------
  -- PROGRAM UNITS
  ----------------

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_latv_tbl                     IN latv_tbl_type,
    x_latv_tbl                     OUT NOCOPY latv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_latv_tbl                     IN latv_tbl_type,
    x_latv_tbl                     OUT NOCOPY latv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_latv_tbl                     IN latv_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_latv_rec                     IN latv_rec_type,
    x_latv_rec                     OUT NOCOPY latv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_latv_rec                     IN latv_rec_type,
    x_latv_rec                     OUT NOCOPY latv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_latv_rec                     IN latv_rec_type);

  FUNCTION get_rec (
    p_id                           IN  NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2)
   RETURN latv_rec_type;

END OKL_LAT_PVT;

/
