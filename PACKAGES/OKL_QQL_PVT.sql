--------------------------------------------------------
--  DDL for Package OKL_QQL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QQL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSQQLS.pls 120.0 2005/11/30 17:18:17 stmathew noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_QQL_PVT';
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
  TYPE qql_rec_type IS RECORD (
   id                             okl_quick_quote_lines_b.id%TYPE
  ,object_version_number          okl_quick_quote_lines_b.object_version_number%TYPE
  ,attribute_category             okl_quick_quote_lines_b.attribute_category%TYPE
  ,attribute1                     okl_quick_quote_lines_b.attribute1%TYPE
  ,attribute2                     okl_quick_quote_lines_b.attribute2%TYPE
  ,attribute3                     okl_quick_quote_lines_b.attribute3%TYPE
  ,attribute4                     okl_quick_quote_lines_b.attribute4%TYPE
  ,attribute5                     okl_quick_quote_lines_b.attribute5%TYPE
  ,attribute6                     okl_quick_quote_lines_b.attribute6%TYPE
  ,attribute7                     okl_quick_quote_lines_b.attribute7%TYPE
  ,attribute8                     okl_quick_quote_lines_b.attribute8%TYPE
  ,attribute9                     okl_quick_quote_lines_b.attribute9%TYPE
  ,attribute10                    okl_quick_quote_lines_b.attribute10%TYPE
  ,attribute11                    okl_quick_quote_lines_b.attribute11%TYPE
  ,attribute12                    okl_quick_quote_lines_b.attribute12%TYPE
  ,attribute13                    okl_quick_quote_lines_b.attribute13%TYPE
  ,attribute14                    okl_quick_quote_lines_b.attribute14%TYPE
  ,attribute15                    okl_quick_quote_lines_b.attribute15%TYPE
  ,quick_quote_id                 okl_quick_quote_lines_b.quick_quote_id%TYPE
  ,type                           okl_quick_quote_lines_b.type%TYPE
  ,basis                          okl_quick_quote_lines_b.basis%TYPE
  ,value                          okl_quick_quote_lines_b.value%TYPE
  ,end_of_term_value_default      okl_quick_quote_lines_b.end_of_term_value_default%TYPE
  ,end_of_term_value              okl_quick_quote_lines_b.end_of_term_value%TYPE
  ,percentage_of_total_cost       okl_quick_quote_lines_b.percentage_of_total_cost%TYPE
  ,item_category_id               okl_quick_quote_lines_b.item_category_id%TYPE
  ,item_category_set_id           okl_quick_quote_lines_b.item_category_set_id%TYPE
  ,lease_rate_factor              okl_quick_quote_lines_b.lease_rate_factor%TYPE
  );

  -- Do not include WHO, LANGUAGE and SFWT_FLAG columns in the _TL record structure
  TYPE qqltl_rec_type IS RECORD (
   id                             okl_quick_quote_lines_tl.id%TYPE
  ,short_description              okl_quick_quote_lines_tl.short_description%TYPE
  ,description                    okl_quick_quote_lines_tl.description%TYPE
  ,comments                       okl_quick_quote_lines_tl.comments%TYPE
  );

  -- view record structure
  TYPE qqlv_rec_type IS RECORD (
   id                             okl_quick_quote_lines_b.id%TYPE
  ,object_version_number          okl_quick_quote_lines_b.object_version_number%TYPE
  ,attribute_category             okl_quick_quote_lines_b.attribute_category%TYPE
  ,attribute1                     okl_quick_quote_lines_b.attribute1%TYPE
  ,attribute2                     okl_quick_quote_lines_b.attribute2%TYPE
  ,attribute3                     okl_quick_quote_lines_b.attribute3%TYPE
  ,attribute4                     okl_quick_quote_lines_b.attribute4%TYPE
  ,attribute5                     okl_quick_quote_lines_b.attribute5%TYPE
  ,attribute6                     okl_quick_quote_lines_b.attribute6%TYPE
  ,attribute7                     okl_quick_quote_lines_b.attribute7%TYPE
  ,attribute8                     okl_quick_quote_lines_b.attribute8%TYPE
  ,attribute9                     okl_quick_quote_lines_b.attribute9%TYPE
  ,attribute10                    okl_quick_quote_lines_b.attribute10%TYPE
  ,attribute11                    okl_quick_quote_lines_b.attribute11%TYPE
  ,attribute12                    okl_quick_quote_lines_b.attribute12%TYPE
  ,attribute13                    okl_quick_quote_lines_b.attribute13%TYPE
  ,attribute14                    okl_quick_quote_lines_b.attribute14%TYPE
  ,attribute15                    okl_quick_quote_lines_b.attribute15%TYPE
  ,quick_quote_id                 okl_quick_quote_lines_b.quick_quote_id%TYPE
  ,type                           okl_quick_quote_lines_b.type%TYPE
  ,basis                          okl_quick_quote_lines_b.basis%TYPE
  ,value                          okl_quick_quote_lines_b.value%TYPE
  ,end_of_term_value_default      okl_quick_quote_lines_b.end_of_term_value_default%TYPE
  ,end_of_term_value              okl_quick_quote_lines_b.end_of_term_value%TYPE
  ,percentage_of_total_cost       okl_quick_quote_lines_b.percentage_of_total_cost%TYPE
  ,item_category_id               okl_quick_quote_lines_b.item_category_id%TYPE
  ,item_category_set_id           okl_quick_quote_lines_b.item_category_set_id%TYPE
  ,lease_rate_factor              okl_quick_quote_lines_b.lease_rate_factor%TYPE
  ,short_description              okl_quick_quote_lines_tl.short_description%TYPE
  ,description                    okl_quick_quote_lines_tl.description%TYPE
  ,comments                       okl_quick_quote_lines_tl.comments%TYPE
  );

  TYPE qqlv_tbl_type IS TABLE OF qqlv_rec_type INDEX BY BINARY_INTEGER;

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
    p_qqlv_tbl                     IN qqlv_tbl_type,
    x_qqlv_tbl                     OUT NOCOPY qqlv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_tbl                     IN qqlv_tbl_type,
    x_qqlv_tbl                     OUT NOCOPY qqlv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_tbl                     IN qqlv_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_rec                     IN qqlv_rec_type,
    x_qqlv_rec                     OUT NOCOPY qqlv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_rec                     IN qqlv_rec_type,
    x_qqlv_rec                     OUT NOCOPY qqlv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_rec                     IN qqlv_rec_type);

END OKL_QQL_PVT;

 

/
