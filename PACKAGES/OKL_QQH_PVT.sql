--------------------------------------------------------
--  DDL for Package OKL_QQH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QQH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSQQHS.pls 120.1 2005/12/28 09:30:47 abhsaxen noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_QQH_PVT';
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
  TYPE qqh_rec_type IS RECORD (
   id                             okl_quick_quotes_b.id%TYPE
  ,object_version_number          okl_quick_quotes_b.object_version_number%TYPE
  ,attribute_category             okl_quick_quotes_b.attribute_category%TYPE
  ,attribute1                     okl_quick_quotes_b.attribute1%TYPE
  ,attribute2                     okl_quick_quotes_b.attribute2%TYPE
  ,attribute3                     okl_quick_quotes_b.attribute3%TYPE
  ,attribute4                     okl_quick_quotes_b.attribute4%TYPE
  ,attribute5                     okl_quick_quotes_b.attribute5%TYPE
  ,attribute6                     okl_quick_quotes_b.attribute6%TYPE
  ,attribute7                     okl_quick_quotes_b.attribute7%TYPE
  ,attribute8                     okl_quick_quotes_b.attribute8%TYPE
  ,attribute9                     okl_quick_quotes_b.attribute9%TYPE
  ,attribute10                    okl_quick_quotes_b.attribute10%TYPE
  ,attribute11                    okl_quick_quotes_b.attribute11%TYPE
  ,attribute12                    okl_quick_quotes_b.attribute12%TYPE
  ,attribute13                    okl_quick_quotes_b.attribute13%TYPE
  ,attribute14                    okl_quick_quotes_b.attribute14%TYPE
  ,attribute15                    okl_quick_quotes_b.attribute15%TYPE
  ,reference_number               okl_quick_quotes_b.reference_number%TYPE
  ,expected_start_date            okl_quick_quotes_b.expected_start_date%TYPE
  ,org_id                         okl_quick_quotes_b.org_id%TYPE
  ,inv_org_id                     okl_quick_quotes_b.inv_org_id%TYPE
  ,currency_code                  okl_quick_quotes_b.currency_code%TYPE
  ,term                           okl_quick_quotes_b.term%TYPE
  ,end_of_term_option_id          okl_quick_quotes_b.end_of_term_option_id%TYPE
  ,pricing_method                 okl_quick_quotes_b.pricing_method%TYPE
  ,lease_opportunity_id           okl_quick_quotes_b.lease_opportunity_id%TYPE
  ,originating_vendor_id          okl_quick_quotes_b.originating_vendor_id%TYPE
  ,program_agreement_id           okl_quick_quotes_b.program_agreement_id%TYPE
  ,sales_rep_id                   okl_quick_quotes_b.sales_rep_id%TYPE
  ,sales_territory_id             okl_quick_quotes_b.sales_territory_id%TYPE
  ,structured_pricing             okl_quick_quotes_b.structured_pricing%TYPE
  ,line_level_pricing             okl_quick_quotes_b.line_level_pricing%TYPE
  ,rate_template_id               okl_quick_quotes_b.rate_template_id%TYPE
  ,rate_card_id                   okl_quick_quotes_b.rate_card_id%TYPE
  ,lease_rate_factor              okl_quick_quotes_b.lease_rate_factor%TYPE
  ,target_rate_type               okl_quick_quotes_b.target_rate_type%TYPE
  ,target_rate                    okl_quick_quotes_b.target_rate%TYPE
  ,target_amount                  okl_quick_quotes_b.target_amount%TYPE
  ,target_frequency               okl_quick_quotes_b.target_frequency%TYPE
  ,target_arrears                 okl_quick_quotes_b.target_arrears%TYPE
  ,target_periods                 okl_quick_quotes_b.target_periods%TYPE
  ,iir                            okl_quick_quotes_b.iir%TYPE
  ,sub_iir                        okl_quick_quotes_b.sub_iir%TYPE
  ,booking_yield                  okl_quick_quotes_b.booking_yield%TYPE
  ,sub_booking_yield              okl_quick_quotes_b.sub_booking_yield%TYPE
  ,pirr                           okl_quick_quotes_b.pirr%TYPE
  ,sub_pirr                       okl_quick_quotes_b.sub_pirr%TYPE
  ,airr                           okl_quick_quotes_b.airr%TYPE
  ,sub_airr                       okl_quick_quotes_b.sub_airr%TYPE
  -- abhsaxen - added - start
  ,sts_code                       okl_quick_quotes_b.sts_code%TYPE
  -- abhsaxen - added - end
  );

  -- Do not include WHO, LANGUAGE and SFWT_FLAG columns in the _TL record structure
  TYPE qqhtl_rec_type IS RECORD (
   id                             okl_quick_quotes_tl.id%TYPE
  ,short_description              okl_quick_quotes_tl.short_description%TYPE
  ,description                    okl_quick_quotes_tl.description%TYPE
  ,comments                       okl_quick_quotes_tl.comments%TYPE
  );

  -- view record structure
  TYPE qqhv_rec_type IS RECORD (
   id                             okl_quick_quotes_b.id%TYPE
  ,object_version_number          okl_quick_quotes_b.object_version_number%TYPE
  ,attribute_category             okl_quick_quotes_b.attribute_category%TYPE
  ,attribute1                     okl_quick_quotes_b.attribute1%TYPE
  ,attribute2                     okl_quick_quotes_b.attribute2%TYPE
  ,attribute3                     okl_quick_quotes_b.attribute3%TYPE
  ,attribute4                     okl_quick_quotes_b.attribute4%TYPE
  ,attribute5                     okl_quick_quotes_b.attribute5%TYPE
  ,attribute6                     okl_quick_quotes_b.attribute6%TYPE
  ,attribute7                     okl_quick_quotes_b.attribute7%TYPE
  ,attribute8                     okl_quick_quotes_b.attribute8%TYPE
  ,attribute9                     okl_quick_quotes_b.attribute9%TYPE
  ,attribute10                    okl_quick_quotes_b.attribute10%TYPE
  ,attribute11                    okl_quick_quotes_b.attribute11%TYPE
  ,attribute12                    okl_quick_quotes_b.attribute12%TYPE
  ,attribute13                    okl_quick_quotes_b.attribute13%TYPE
  ,attribute14                    okl_quick_quotes_b.attribute14%TYPE
  ,attribute15                    okl_quick_quotes_b.attribute15%TYPE
  ,reference_number               okl_quick_quotes_b.reference_number%TYPE
  ,expected_start_date            okl_quick_quotes_b.expected_start_date%TYPE
  ,org_id                         okl_quick_quotes_b.org_id%TYPE
  ,inv_org_id                     okl_quick_quotes_b.inv_org_id%TYPE
  ,currency_code                  okl_quick_quotes_b.currency_code%TYPE
  ,term                           okl_quick_quotes_b.term%TYPE
  ,end_of_term_option_id          okl_quick_quotes_b.end_of_term_option_id%TYPE
  ,pricing_method                 okl_quick_quotes_b.pricing_method%TYPE
  ,lease_opportunity_id           okl_quick_quotes_b.lease_opportunity_id%TYPE
  ,originating_vendor_id          okl_quick_quotes_b.originating_vendor_id%TYPE
  ,program_agreement_id           okl_quick_quotes_b.program_agreement_id%TYPE
  ,sales_rep_id                   okl_quick_quotes_b.sales_rep_id%TYPE
  ,sales_territory_id             okl_quick_quotes_b.sales_territory_id%TYPE
  ,structured_pricing             okl_quick_quotes_b.structured_pricing%TYPE
  ,line_level_pricing             okl_quick_quotes_b.line_level_pricing%TYPE
  ,rate_template_id               okl_quick_quotes_b.rate_template_id%TYPE
  ,rate_card_id                   okl_quick_quotes_b.rate_card_id%TYPE
  ,lease_rate_factor              okl_quick_quotes_b.lease_rate_factor%TYPE
  ,target_rate_type               okl_quick_quotes_b.target_rate_type%TYPE
  ,target_rate                    okl_quick_quotes_b.target_rate%TYPE
  ,target_amount                  okl_quick_quotes_b.target_amount%TYPE
  ,target_frequency               okl_quick_quotes_b.target_frequency%TYPE
  ,target_arrears                 okl_quick_quotes_b.target_arrears%TYPE
  ,target_periods                 okl_quick_quotes_b.target_periods%TYPE
  ,iir                            okl_quick_quotes_b.iir%TYPE
  ,sub_iir                        okl_quick_quotes_b.sub_iir%TYPE
  ,booking_yield                  okl_quick_quotes_b.booking_yield%TYPE
  ,sub_booking_yield              okl_quick_quotes_b.sub_booking_yield%TYPE
  ,pirr                           okl_quick_quotes_b.pirr%TYPE
  ,sub_pirr                       okl_quick_quotes_b.sub_pirr%TYPE
  ,airr                           okl_quick_quotes_b.airr%TYPE
  ,sub_airr                       okl_quick_quotes_b.sub_airr%TYPE
  ,short_description              okl_quick_quotes_tl.short_description%TYPE
  ,description                    okl_quick_quotes_tl.description%TYPE
  ,comments                       okl_quick_quotes_tl.comments%TYPE
  -- abhsaxen - added - start
  ,sts_code                       okl_quick_quotes_b.sts_code%TYPE
  -- abhsaxen - added - end
  );

  TYPE qqhv_tbl_type IS TABLE OF qqhv_rec_type INDEX BY BINARY_INTEGER;

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
    p_qqhv_tbl                     IN qqhv_tbl_type,
    x_qqhv_tbl                     OUT NOCOPY qqhv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqhv_tbl                     IN qqhv_tbl_type,
    x_qqhv_tbl                     OUT NOCOPY qqhv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqhv_tbl                     IN qqhv_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqhv_rec                     IN qqhv_rec_type,
    x_qqhv_rec                     OUT NOCOPY qqhv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqhv_rec                     IN qqhv_rec_type,
    x_qqhv_rec                     OUT NOCOPY qqhv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqhv_rec                     IN qqhv_rec_type);

END OKL_QQH_PVT;

/
