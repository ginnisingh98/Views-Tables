--------------------------------------------------------
--  DDL for Package OKL_LSQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LSQ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLSQS.pls 120.2 2007/03/20 23:16:18 rravikir noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LSQ_PVT';
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
  TYPE lsq_rec_type IS RECORD (
   id                             okl_lease_quotes_b.id%TYPE
  ,object_version_number          okl_lease_quotes_b.object_version_number%TYPE
  ,attribute_category             okl_lease_quotes_b.attribute_category%TYPE
  ,attribute1                     okl_lease_quotes_b.attribute1%TYPE
  ,attribute2                     okl_lease_quotes_b.attribute2%TYPE
  ,attribute3                     okl_lease_quotes_b.attribute3%TYPE
  ,attribute4                     okl_lease_quotes_b.attribute4%TYPE
  ,attribute5                     okl_lease_quotes_b.attribute5%TYPE
  ,attribute6                     okl_lease_quotes_b.attribute6%TYPE
  ,attribute7                     okl_lease_quotes_b.attribute7%TYPE
  ,attribute8                     okl_lease_quotes_b.attribute8%TYPE
  ,attribute9                     okl_lease_quotes_b.attribute9%TYPE
  ,attribute10                    okl_lease_quotes_b.attribute10%TYPE
  ,attribute11                    okl_lease_quotes_b.attribute11%TYPE
  ,attribute12                    okl_lease_quotes_b.attribute12%TYPE
  ,attribute13                    okl_lease_quotes_b.attribute13%TYPE
  ,attribute14                    okl_lease_quotes_b.attribute14%TYPE
  ,attribute15                    okl_lease_quotes_b.attribute15%TYPE
  ,reference_number               okl_lease_quotes_b.reference_number%TYPE
  ,status                         okl_lease_quotes_b.status%TYPE
  ,parent_object_code             okl_lease_quotes_b.parent_object_code%TYPE
  ,parent_object_id               okl_lease_quotes_b.parent_object_id%TYPE
  ,valid_from                     okl_lease_quotes_b.valid_from%TYPE
  ,valid_to                       okl_lease_quotes_b.valid_to%TYPE
  ,customer_bookclass             okl_lease_quotes_b.customer_bookclass%TYPE
  ,customer_taxowner              okl_lease_quotes_b.customer_taxowner%TYPE
  ,expected_start_date            okl_lease_quotes_b.expected_start_date%TYPE
  ,expected_funding_date          okl_lease_quotes_b.expected_funding_date%TYPE
  ,expected_delivery_date         okl_lease_quotes_b.expected_delivery_date%TYPE
  ,pricing_method                 okl_lease_quotes_b.pricing_method%TYPE
  ,term                           okl_lease_quotes_b.term%TYPE
  ,product_id                     okl_lease_quotes_b.product_id%TYPE
  ,end_of_term_option_id          okl_lease_quotes_b.end_of_term_option_id%TYPE
  ,structured_pricing             okl_lease_quotes_b.structured_pricing%TYPE
  ,line_level_pricing             okl_lease_quotes_b.line_level_pricing%TYPE
  ,rate_template_id               okl_lease_quotes_b.rate_template_id%TYPE
  ,rate_card_id                   okl_lease_quotes_b.rate_card_id%TYPE
  ,lease_rate_factor              okl_lease_quotes_b.lease_rate_factor%TYPE
  ,target_rate_type               okl_lease_quotes_b.target_rate_type%TYPE
  ,target_rate                    okl_lease_quotes_b.target_rate%TYPE
  ,target_amount                  okl_lease_quotes_b.target_amount%TYPE
  ,target_frequency               okl_lease_quotes_b.target_frequency%TYPE
  ,target_arrears_yn              okl_lease_quotes_b.target_arrears_yn%TYPE
  ,target_periods                 okl_lease_quotes_b.target_periods%TYPE
  ,iir                            okl_lease_quotes_b.iir%TYPE
  ,booking_yield                  okl_lease_quotes_b.booking_yield%TYPE
  ,pirr                           okl_lease_quotes_b.pirr%TYPE
  ,airr                           okl_lease_quotes_b.airr%TYPE
  ,sub_iir                        okl_lease_quotes_b.sub_iir%TYPE
  ,sub_booking_yield              okl_lease_quotes_b.sub_booking_yield%TYPE
  ,sub_pirr                       okl_lease_quotes_b.sub_pirr%TYPE
  ,sub_airr                       okl_lease_quotes_b.sub_airr%TYPE
  ,usage_category                 okl_lease_quotes_b.usage_category%TYPE
  ,usage_industry_class           okl_lease_quotes_b.usage_industry_class%TYPE
  ,usage_industry_code            okl_lease_quotes_b.usage_industry_code%TYPE
  ,usage_amount                   okl_lease_quotes_b.usage_amount%TYPE
  ,usage_location_id              okl_lease_quotes_b.usage_location_id%TYPE
  ,property_tax_applicable        okl_lease_quotes_b.property_tax_applicable%TYPE
  ,property_tax_billing_type      okl_lease_quotes_b.property_tax_billing_type%TYPE
  ,upfront_tax_treatment          okl_lease_quotes_b.upfront_tax_treatment%TYPE
  ,upfront_tax_stream_type        okl_lease_quotes_b.upfront_tax_stream_type%TYPE
  ,transfer_of_title              okl_lease_quotes_b.transfer_of_title%TYPE
  ,age_of_equipment               okl_lease_quotes_b.age_of_equipment%TYPE
  ,purchase_of_lease              okl_lease_quotes_b.purchase_of_lease%TYPE
  ,sale_and_lease_back            okl_lease_quotes_b.sale_and_lease_back%TYPE
  ,interest_disclosed             okl_lease_quotes_b.interest_disclosed%TYPE
  ,primary_quote                  okl_lease_quotes_b.primary_quote%TYPE
  ,legal_entity_id                okl_lease_quotes_b.legal_entity_id%TYPE
  -- Bug 5908845. eBTax Enhancement Project
  ,line_intended_use              okl_lease_quotes_b.line_intended_use%TYPE
  -- End Bug 5908845. eBTax Enhancement Project
  );

  -- Do not include WHO, LANGUAGE and SFWT_FLAG columns in the _TL record structure
  TYPE lsqtl_rec_type IS RECORD (
   id                             okl_lease_quotes_tl.id%TYPE
  ,short_description              okl_lease_quotes_tl.short_description%TYPE
  ,description                    okl_lease_quotes_tl.description%TYPE
  ,comments                       okl_lease_quotes_tl.comments%TYPE
  );

  -- view record structure
  TYPE lsqv_rec_type IS RECORD (
   id                             okl_lease_quotes_b.id%TYPE := OKL_API.G_MISS_NUM
  ,object_version_number          okl_lease_quotes_b.object_version_number%TYPE
  ,attribute_category             okl_lease_quotes_b.attribute_category%TYPE := OKL_API.G_MISS_CHAR
  ,attribute1                     okl_lease_quotes_b.attribute1%TYPE := OKL_API.G_MISS_CHAR
  ,attribute2                     okl_lease_quotes_b.attribute2%TYPE := OKL_API.G_MISS_CHAR
  ,attribute3                     okl_lease_quotes_b.attribute3%TYPE := OKL_API.G_MISS_CHAR
  ,attribute4                     okl_lease_quotes_b.attribute4%TYPE := OKL_API.G_MISS_CHAR
  ,attribute5                     okl_lease_quotes_b.attribute5%TYPE := OKL_API.G_MISS_CHAR
  ,attribute6                     okl_lease_quotes_b.attribute6%TYPE := OKL_API.G_MISS_CHAR
  ,attribute7                     okl_lease_quotes_b.attribute7%TYPE := OKL_API.G_MISS_CHAR
  ,attribute8                     okl_lease_quotes_b.attribute8%TYPE := OKL_API.G_MISS_CHAR
  ,attribute9                     okl_lease_quotes_b.attribute9%TYPE := OKL_API.G_MISS_CHAR
  ,attribute10                    okl_lease_quotes_b.attribute10%TYPE := OKL_API.G_MISS_CHAR
  ,attribute11                    okl_lease_quotes_b.attribute11%TYPE := OKL_API.G_MISS_CHAR
  ,attribute12                    okl_lease_quotes_b.attribute12%TYPE := OKL_API.G_MISS_CHAR
  ,attribute13                    okl_lease_quotes_b.attribute13%TYPE := OKL_API.G_MISS_CHAR
  ,attribute14                    okl_lease_quotes_b.attribute14%TYPE := OKL_API.G_MISS_CHAR
  ,attribute15                    okl_lease_quotes_b.attribute15%TYPE := OKL_API.G_MISS_CHAR
  ,reference_number               okl_lease_quotes_b.reference_number%TYPE := OKL_API.G_MISS_CHAR
  ,status                         okl_lease_quotes_b.status%TYPE := OKL_API.G_MISS_CHAR
  ,parent_object_code             okl_lease_quotes_b.parent_object_code%TYPE := OKL_API.G_MISS_CHAR
  ,parent_object_id               okl_lease_quotes_b.parent_object_id%TYPE := OKL_API.G_MISS_NUM
  ,valid_from                     okl_lease_quotes_b.valid_from%TYPE := OKL_API.G_MISS_DATE
  ,valid_to                       okl_lease_quotes_b.valid_to%TYPE := OKL_API.G_MISS_DATE
  ,customer_bookclass             okl_lease_quotes_b.customer_bookclass%TYPE := OKL_API.G_MISS_CHAR
  ,customer_taxowner              okl_lease_quotes_b.customer_taxowner%TYPE := OKL_API.G_MISS_CHAR
  ,expected_start_date            okl_lease_quotes_b.expected_start_date%TYPE := OKL_API.G_MISS_DATE
  ,expected_funding_date          okl_lease_quotes_b.expected_funding_date%TYPE := OKL_API.G_MISS_DATE
  ,expected_delivery_date         okl_lease_quotes_b.expected_delivery_date%TYPE := OKL_API.G_MISS_DATE
  ,pricing_method                 okl_lease_quotes_b.pricing_method%TYPE := OKL_API.G_MISS_CHAR
  ,term                           okl_lease_quotes_b.term%TYPE := OKL_API.G_MISS_NUM
  ,product_id                     okl_lease_quotes_b.product_id%TYPE := OKL_API.G_MISS_NUM
  ,end_of_term_option_id          okl_lease_quotes_b.end_of_term_option_id%TYPE := OKL_API.G_MISS_NUM
  ,structured_pricing             okl_lease_quotes_b.structured_pricing%TYPE := OKL_API.G_MISS_CHAR
  ,line_level_pricing             okl_lease_quotes_b.line_level_pricing%TYPE := OKL_API.G_MISS_CHAR
  ,rate_template_id               okl_lease_quotes_b.rate_template_id%TYPE := OKL_API.G_MISS_NUM
  ,rate_card_id                   okl_lease_quotes_b.rate_card_id%TYPE := OKL_API.G_MISS_NUM
  ,lease_rate_factor              okl_lease_quotes_b.lease_rate_factor%TYPE := OKL_API.G_MISS_NUM
  ,target_rate_type               okl_lease_quotes_b.target_rate_type%TYPE := OKL_API.G_MISS_CHAR
  ,target_rate                    okl_lease_quotes_b.target_rate%TYPE := OKL_API.G_MISS_NUM
  ,target_amount                  okl_lease_quotes_b.target_amount%TYPE := OKL_API.G_MISS_NUM
  ,target_frequency               okl_lease_quotes_b.target_frequency%TYPE := OKL_API.G_MISS_CHAR
  ,target_arrears_yn              okl_lease_quotes_b.target_arrears_yn%TYPE := OKL_API.G_MISS_CHAR
  ,target_periods                 okl_lease_quotes_b.target_periods%TYPE := OKL_API.G_MISS_NUM
  ,iir                            okl_lease_quotes_b.iir%TYPE := OKL_API.G_MISS_NUM
  ,booking_yield                  okl_lease_quotes_b.booking_yield%TYPE := OKL_API.G_MISS_NUM
  ,pirr                           okl_lease_quotes_b.pirr%TYPE := OKL_API.G_MISS_NUM
  ,airr                           okl_lease_quotes_b.airr%TYPE := OKL_API.G_MISS_NUM
  ,sub_iir                        okl_lease_quotes_b.sub_iir%TYPE := OKL_API.G_MISS_NUM
  ,sub_booking_yield              okl_lease_quotes_b.sub_booking_yield%TYPE := OKL_API.G_MISS_NUM
  ,sub_pirr                       okl_lease_quotes_b.sub_pirr%TYPE := OKL_API.G_MISS_NUM
  ,sub_airr                       okl_lease_quotes_b.sub_airr%TYPE := OKL_API.G_MISS_NUM
  ,usage_category                 okl_lease_quotes_b.usage_category%TYPE := OKL_API.G_MISS_CHAR
  ,usage_industry_class           okl_lease_quotes_b.usage_industry_class%TYPE := OKL_API.G_MISS_CHAR
  ,usage_industry_code            okl_lease_quotes_b.usage_industry_code%TYPE := OKL_API.G_MISS_CHAR
  ,usage_amount                   okl_lease_quotes_b.usage_amount%TYPE := OKL_API.G_MISS_NUM
  ,usage_location_id              okl_lease_quotes_b.usage_location_id%TYPE := OKL_API.G_MISS_NUM
  ,property_tax_applicable        okl_lease_quotes_b.property_tax_applicable%TYPE := OKL_API.G_MISS_CHAR
  ,property_tax_billing_type      okl_lease_quotes_b.property_tax_billing_type%TYPE := OKL_API.G_MISS_CHAR
  ,upfront_tax_treatment          okl_lease_quotes_b.upfront_tax_treatment%TYPE := OKL_API.G_MISS_CHAR
  ,upfront_tax_stream_type        okl_lease_quotes_b.upfront_tax_stream_type%TYPE := OKL_API.G_MISS_NUM
  ,transfer_of_title              okl_lease_quotes_b.transfer_of_title%TYPE := OKL_API.G_MISS_CHAR
  ,age_of_equipment               okl_lease_quotes_b.age_of_equipment%TYPE := OKL_API.G_MISS_NUM
  ,purchase_of_lease              okl_lease_quotes_b.purchase_of_lease%TYPE := OKL_API.G_MISS_CHAR
  ,sale_and_lease_back            okl_lease_quotes_b.sale_and_lease_back%TYPE := OKL_API.G_MISS_CHAR
  ,interest_disclosed             okl_lease_quotes_b.interest_disclosed%TYPE := OKL_API.G_MISS_CHAR
  ,primary_quote                  okl_lease_quotes_b.primary_quote%TYPE := OKL_API.G_MISS_CHAR
  ,legal_entity_id                okl_lease_quotes_b.legal_entity_id%TYPE := OKL_API.G_MISS_NUM
  -- Bug 5908845. eBTax Enhancement Project
  ,line_intended_use              okl_lease_quotes_b.line_intended_use%TYPE := OKL_API.G_MISS_CHAR
  -- End Bug 5908845. eBTax Enhancement Project
  ,short_description              okl_lease_quotes_tl.short_description%TYPE := OKL_API.G_MISS_CHAR
  ,description                    okl_lease_quotes_tl.description%TYPE := OKL_API.G_MISS_CHAR
  ,comments                       okl_lease_quotes_tl.comments%TYPE := OKL_API.G_MISS_CHAR
  );

  TYPE lsqv_tbl_type IS TABLE OF lsqv_rec_type INDEX BY BINARY_INTEGER;

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
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type);

END OKL_LSQ_PVT;

/
