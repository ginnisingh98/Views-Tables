--------------------------------------------------------
--  DDL for Package OKL_FEE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FEE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSFEES.pls 120.2 2007/08/08 21:12:33 rravikir noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_FEE_PVT';
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
  TYPE fee_rec_type IS RECORD (
   id                             okl_fees_b.id%TYPE
  ,object_version_number          okl_fees_b.object_version_number%TYPE
  ,attribute_category             okl_fees_b.attribute_category%TYPE
  ,attribute1                     okl_fees_b.attribute1%TYPE
  ,attribute2                     okl_fees_b.attribute2%TYPE
  ,attribute3                     okl_fees_b.attribute3%TYPE
  ,attribute4                     okl_fees_b.attribute4%TYPE
  ,attribute5                     okl_fees_b.attribute5%TYPE
  ,attribute6                     okl_fees_b.attribute6%TYPE
  ,attribute7                     okl_fees_b.attribute7%TYPE
  ,attribute8                     okl_fees_b.attribute8%TYPE
  ,attribute9                     okl_fees_b.attribute9%TYPE
  ,attribute10                    okl_fees_b.attribute10%TYPE
  ,attribute11                    okl_fees_b.attribute11%TYPE
  ,attribute12                    okl_fees_b.attribute12%TYPE
  ,attribute13                    okl_fees_b.attribute13%TYPE
  ,attribute14                    okl_fees_b.attribute14%TYPE
  ,attribute15                    okl_fees_b.attribute15%TYPE
  ,parent_object_code             okl_fees_b.parent_object_code%TYPE
  ,parent_object_id               okl_fees_b.parent_object_id%TYPE
  ,stream_type_id                 okl_fees_b.stream_type_id%TYPE
  ,fee_type                       okl_fees_b.fee_type%TYPE
  ,structured_pricing             okl_fees_b.structured_pricing%TYPE
  ,rate_template_id               okl_fees_b.rate_template_id%TYPE
  ,rate_card_id                   okl_fees_b.rate_card_id%TYPE
  ,lease_rate_factor              okl_fees_b.lease_rate_factor%TYPE
  ,target_arrears                 okl_fees_b.target_arrears%TYPE
  ,effective_from                 okl_fees_b.effective_from%TYPE
  ,effective_to                   okl_fees_b.effective_to%TYPE
  ,supplier_id                    okl_fees_b.supplier_id%TYPE
  ,rollover_quote_id              okl_fees_b.rollover_quote_id%TYPE
  ,initial_direct_cost            okl_fees_b.initial_direct_cost%TYPE
  ,fee_amount                     okl_fees_b.fee_amount%TYPE
  ,target_amount                  okl_fees_b.target_amount%TYPE
  ,target_frequency               okl_fees_b.target_frequency%TYPE
  ,payment_type_id                okl_fees_b.payment_type_id%TYPE
  ,fee_purpose_code               okl_fees_b.fee_purpose_code%TYPE
  );

  -- Do not include WHO, LANGUAGE and SFWT_FLAG columns in the _TL record structure
  TYPE feetl_rec_type IS RECORD (
   id                             okl_fees_tl.id%TYPE
  ,short_description              okl_fees_tl.short_description%TYPE
  ,description                    okl_fees_tl.description%TYPE
  ,comments                       okl_fees_tl.comments%TYPE
  );

  -- view record structure
  TYPE feev_rec_type IS RECORD (
   id                             okl_fees_b.id%TYPE
  ,object_version_number          okl_fees_b.object_version_number%TYPE
  ,attribute_category             okl_fees_b.attribute_category%TYPE
  ,attribute1                     okl_fees_b.attribute1%TYPE
  ,attribute2                     okl_fees_b.attribute2%TYPE
  ,attribute3                     okl_fees_b.attribute3%TYPE
  ,attribute4                     okl_fees_b.attribute4%TYPE
  ,attribute5                     okl_fees_b.attribute5%TYPE
  ,attribute6                     okl_fees_b.attribute6%TYPE
  ,attribute7                     okl_fees_b.attribute7%TYPE
  ,attribute8                     okl_fees_b.attribute8%TYPE
  ,attribute9                     okl_fees_b.attribute9%TYPE
  ,attribute10                    okl_fees_b.attribute10%TYPE
  ,attribute11                    okl_fees_b.attribute11%TYPE
  ,attribute12                    okl_fees_b.attribute12%TYPE
  ,attribute13                    okl_fees_b.attribute13%TYPE
  ,attribute14                    okl_fees_b.attribute14%TYPE
  ,attribute15                    okl_fees_b.attribute15%TYPE
  ,parent_object_code             okl_fees_b.parent_object_code%TYPE
  ,parent_object_id               okl_fees_b.parent_object_id%TYPE
  ,stream_type_id                 okl_fees_b.stream_type_id%TYPE
  ,fee_type                       okl_fees_b.fee_type%TYPE
  ,structured_pricing             okl_fees_b.structured_pricing%TYPE
  ,rate_template_id               okl_fees_b.rate_template_id%TYPE
  ,rate_card_id                   okl_fees_b.rate_card_id%TYPE
  ,lease_rate_factor              okl_fees_b.lease_rate_factor%TYPE
  ,target_arrears                 okl_fees_b.target_arrears%TYPE
  ,effective_from                 okl_fees_b.effective_from%TYPE
  ,effective_to                   okl_fees_b.effective_to%TYPE
  ,supplier_id                    okl_fees_b.supplier_id%TYPE
  ,rollover_quote_id              okl_fees_b.rollover_quote_id%TYPE
  ,initial_direct_cost            okl_fees_b.initial_direct_cost%TYPE
  ,fee_amount                     okl_fees_b.fee_amount%TYPE
  ,target_amount                  okl_fees_b.target_amount%TYPE
  ,target_frequency               okl_fees_b.target_frequency%TYPE
  ,short_description              okl_fees_tl.short_description%TYPE
  ,description                    okl_fees_tl.description%TYPE
  ,comments                       okl_fees_tl.comments%TYPE
  ,payment_type_id                okl_fees_b.payment_type_id%TYPE
  ,fee_purpose_code               okl_fees_b.fee_purpose_code%TYPE
  );

  TYPE feev_tbl_type IS TABLE OF feev_rec_type INDEX BY BINARY_INTEGER;

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
    p_feev_tbl                     IN feev_tbl_type,
    x_feev_tbl                     OUT NOCOPY feev_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_feev_tbl                     IN feev_tbl_type,
    x_feev_tbl                     OUT NOCOPY feev_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_feev_tbl                     IN feev_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_feev_rec                     IN feev_rec_type,
    x_feev_rec                     OUT NOCOPY feev_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_feev_rec                     IN feev_rec_type,
    x_feev_rec                     OUT NOCOPY feev_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_feev_rec                     IN feev_rec_type);

END OKL_FEE_PVT;

/
