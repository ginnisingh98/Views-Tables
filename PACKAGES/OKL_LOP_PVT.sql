--------------------------------------------------------
--  DDL for Package OKL_LOP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LOP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLOPS.pls 120.4 2007/03/20 23:18:04 rravikir noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LOP_PVT';
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
  TYPE lop_rec_type IS RECORD (
   id                             okl_lease_opportunities_b.id%TYPE
  ,object_version_number          okl_lease_opportunities_b.object_version_number%TYPE
  ,attribute_category             okl_lease_opportunities_b.attribute_category%TYPE
  ,attribute1                     okl_lease_opportunities_b.attribute1%TYPE
  ,attribute2                     okl_lease_opportunities_b.attribute2%TYPE
  ,attribute3                     okl_lease_opportunities_b.attribute3%TYPE
  ,attribute4                     okl_lease_opportunities_b.attribute4%TYPE
  ,attribute5                     okl_lease_opportunities_b.attribute5%TYPE
  ,attribute6                     okl_lease_opportunities_b.attribute6%TYPE
  ,attribute7                     okl_lease_opportunities_b.attribute7%TYPE
  ,attribute8                     okl_lease_opportunities_b.attribute8%TYPE
  ,attribute9                     okl_lease_opportunities_b.attribute9%TYPE
  ,attribute10                    okl_lease_opportunities_b.attribute10%TYPE
  ,attribute11                    okl_lease_opportunities_b.attribute11%TYPE
  ,attribute12                    okl_lease_opportunities_b.attribute12%TYPE
  ,attribute13                    okl_lease_opportunities_b.attribute13%TYPE
  ,attribute14                    okl_lease_opportunities_b.attribute14%TYPE
  ,attribute15                    okl_lease_opportunities_b.attribute15%TYPE
  ,reference_number               okl_lease_opportunities_b.reference_number%TYPE
  ,status                         okl_lease_opportunities_b.status%TYPE
  ,valid_from                     okl_lease_opportunities_b.valid_from%TYPE
  ,expected_start_date            okl_lease_opportunities_b.expected_start_date%TYPE
  ,org_id                         okl_lease_opportunities_b.org_id%TYPE
  ,inv_org_id                     okl_lease_opportunities_b.inv_org_id%TYPE
  ,prospect_id                    okl_lease_opportunities_b.prospect_id%TYPE
  ,prospect_address_id            okl_lease_opportunities_b.prospect_address_id%TYPE
  ,cust_acct_id                   okl_lease_opportunities_b.cust_acct_id%TYPE
  ,currency_code                  okl_lease_opportunities_b.currency_code%TYPE
  ,currency_conversion_type       okl_lease_opportunities_b.currency_conversion_type%TYPE
  ,currency_conversion_rate       okl_lease_opportunities_b.currency_conversion_rate%TYPE
  ,currency_conversion_date       okl_lease_opportunities_b.currency_conversion_date%TYPE
  ,program_agreement_id           okl_lease_opportunities_b.program_agreement_id%TYPE
  ,master_lease_id                okl_lease_opportunities_b.master_lease_id%TYPE
  ,sales_rep_id                   okl_lease_opportunities_b.sales_rep_id%TYPE
  ,sales_territory_id             okl_lease_opportunities_b.sales_territory_id%TYPE
  ,supplier_id                    okl_lease_opportunities_b.supplier_id%TYPE
  ,delivery_date                  okl_lease_opportunities_b.delivery_date%TYPE
  ,funding_date                   okl_lease_opportunities_b.funding_date%TYPE
  ,property_tax_applicable        okl_lease_opportunities_b.property_tax_applicable%TYPE
  ,property_tax_billing_type      okl_lease_opportunities_b.property_tax_billing_type%TYPE
  ,upfront_tax_treatment          okl_lease_opportunities_b.upfront_tax_treatment%TYPE
  ,install_site_id                okl_lease_opportunities_b.install_site_id%TYPE
  ,usage_category                 okl_lease_opportunities_b.usage_category%TYPE
  ,usage_industry_class           okl_lease_opportunities_b.usage_industry_class%TYPE
  ,usage_industry_code            okl_lease_opportunities_b.usage_industry_code%TYPE
  ,usage_amount                   okl_lease_opportunities_b.usage_amount%TYPE
  ,usage_location_id              okl_lease_opportunities_b.usage_location_id%TYPE
  ,originating_vendor_id          okl_lease_opportunities_b.originating_vendor_id%TYPE
  --Fixed Bug #5647107 ssdeshpa start
  ,legal_entity_id                okl_lease_opportunities_b.legal_entity_id%TYPE
  --Fixed Bug #5647107 ssdeshpa end
  -- Bug 5908845. eBTax Enhancement Project
  ,line_intended_use              okl_lease_opportunities_b.line_intended_use%TYPE
  -- End Bug 5908845. eBTax Enhancement Project
  );

  -- Do not include WHO, LANGUAGE and SFWT_FLAG columns in the _TL record structure
  TYPE loptl_rec_type IS RECORD (
   id                             okl_lease_opportunities_tl.id%TYPE
  ,short_description              okl_lease_opportunities_tl.short_description%TYPE
  ,description                    okl_lease_opportunities_tl.description%TYPE
  ,comments                       okl_lease_opportunities_tl.comments%TYPE
  );

  -- view record structure
  TYPE lopv_rec_type IS RECORD (
   id                             okl_lease_opportunities_b.id%TYPE	:= OKL_API.G_MISS_NUM
  ,object_version_number          okl_lease_opportunities_b.object_version_number%TYPE
  ,attribute_category             okl_lease_opportunities_b.attribute_category%TYPE := OKL_API.G_MISS_CHAR
  ,attribute1                     okl_lease_opportunities_b.attribute1%TYPE := OKL_API.G_MISS_CHAR
  ,attribute2                     okl_lease_opportunities_b.attribute2%TYPE := OKL_API.G_MISS_CHAR
  ,attribute3                     okl_lease_opportunities_b.attribute3%TYPE := OKL_API.G_MISS_CHAR
  ,attribute4                     okl_lease_opportunities_b.attribute4%TYPE := OKL_API.G_MISS_CHAR
  ,attribute5                     okl_lease_opportunities_b.attribute5%TYPE := OKL_API.G_MISS_CHAR
  ,attribute6                     okl_lease_opportunities_b.attribute6%TYPE := OKL_API.G_MISS_CHAR
  ,attribute7                     okl_lease_opportunities_b.attribute7%TYPE := OKL_API.G_MISS_CHAR
  ,attribute8                     okl_lease_opportunities_b.attribute8%TYPE := OKL_API.G_MISS_CHAR
  ,attribute9                     okl_lease_opportunities_b.attribute9%TYPE := OKL_API.G_MISS_CHAR
  ,attribute10                    okl_lease_opportunities_b.attribute10%TYPE := OKL_API.G_MISS_CHAR
  ,attribute11                    okl_lease_opportunities_b.attribute11%TYPE := OKL_API.G_MISS_CHAR
  ,attribute12                    okl_lease_opportunities_b.attribute12%TYPE := OKL_API.G_MISS_CHAR
  ,attribute13                    okl_lease_opportunities_b.attribute13%TYPE := OKL_API.G_MISS_CHAR
  ,attribute14                    okl_lease_opportunities_b.attribute14%TYPE := OKL_API.G_MISS_CHAR
  ,attribute15                    okl_lease_opportunities_b.attribute15%TYPE := OKL_API.G_MISS_CHAR
  ,reference_number               okl_lease_opportunities_b.reference_number%TYPE := OKL_API.G_MISS_CHAR
  ,status                         okl_lease_opportunities_b.status%TYPE := OKL_API.G_MISS_CHAR
  ,valid_from                     okl_lease_opportunities_b.valid_from%TYPE := OKL_API.G_MISS_DATE
  ,expected_start_date            okl_lease_opportunities_b.expected_start_date%TYPE := OKL_API.G_MISS_DATE
  ,org_id                         okl_lease_opportunities_b.org_id%TYPE := OKL_API.G_MISS_NUM
  ,inv_org_id                     okl_lease_opportunities_b.inv_org_id%TYPE := OKL_API.G_MISS_NUM
  ,prospect_id                    okl_lease_opportunities_b.prospect_id%TYPE := OKL_API.G_MISS_NUM
  ,prospect_address_id            okl_lease_opportunities_b.prospect_address_id%TYPE := OKL_API.G_MISS_NUM
  ,cust_acct_id                   okl_lease_opportunities_b.cust_acct_id%TYPE := OKL_API.G_MISS_NUM
  ,currency_code                  okl_lease_opportunities_b.currency_code%TYPE := OKL_API.G_MISS_CHAR
  ,currency_conversion_type       okl_lease_opportunities_b.currency_conversion_type%TYPE := OKL_API.G_MISS_CHAR
  ,currency_conversion_rate       okl_lease_opportunities_b.currency_conversion_rate%TYPE := OKL_API.G_MISS_NUM
  ,currency_conversion_date       okl_lease_opportunities_b.currency_conversion_date%TYPE := OKL_API.G_MISS_DATE
  ,program_agreement_id           okl_lease_opportunities_b.program_agreement_id%TYPE := OKL_API.G_MISS_NUM
  ,master_lease_id                okl_lease_opportunities_b.master_lease_id%TYPE := OKL_API.G_MISS_NUM
  ,sales_rep_id                   okl_lease_opportunities_b.sales_rep_id%TYPE := OKL_API.G_MISS_NUM
  ,sales_territory_id             okl_lease_opportunities_b.sales_territory_id%TYPE := OKL_API.G_MISS_NUM
  ,supplier_id                    okl_lease_opportunities_b.supplier_id%TYPE := OKL_API.G_MISS_NUM
  ,delivery_date                  okl_lease_opportunities_b.delivery_date%TYPE := OKL_API.G_MISS_DATE
  ,funding_date                   okl_lease_opportunities_b.funding_date%TYPE := OKL_API.G_MISS_DATE
  ,property_tax_applicable        okl_lease_opportunities_b.property_tax_applicable%TYPE := OKL_API.G_MISS_CHAR
  ,property_tax_billing_type      okl_lease_opportunities_b.property_tax_billing_type%TYPE := OKL_API.G_MISS_CHAR
  ,upfront_tax_treatment          okl_lease_opportunities_b.upfront_tax_treatment%TYPE := OKL_API.G_MISS_CHAR
  ,install_site_id                okl_lease_opportunities_b.install_site_id%TYPE := OKL_API.G_MISS_NUM
  ,usage_category                 okl_lease_opportunities_b.usage_category%TYPE  := OKL_API.G_MISS_CHAR
  ,usage_industry_class           okl_lease_opportunities_b.usage_industry_class%TYPE := OKL_API.G_MISS_CHAR
  ,usage_industry_code            okl_lease_opportunities_b.usage_industry_code%TYPE := OKL_API.G_MISS_CHAR
  ,usage_amount                   okl_lease_opportunities_b.usage_amount%TYPE := OKL_API.G_MISS_NUM
  ,usage_location_id              okl_lease_opportunities_b.usage_location_id%TYPE := OKL_API.G_MISS_NUM
  ,originating_vendor_id          okl_lease_opportunities_b.originating_vendor_id%TYPE := OKL_API.G_MISS_NUM
  --Fixed Bug# 5647107 ssdeshpa start
  ,legal_entity_id                okl_lease_opportunities_b.legal_entity_id%TYPE := OKL_API.G_MISS_NUM
  --Fixed Bug#5647107 ssdeshpa start
  -- Bug 5908845. eBTax Enhancement Project
  ,line_intended_use              okl_lease_opportunities_b.line_intended_use%TYPE := OKL_API.G_MISS_CHAR
  -- End Bug 5908845. eBTax Enhancement Project
  ,short_description              okl_lease_opportunities_tl.short_description%TYPE := OKL_API.G_MISS_CHAR
  ,description                    okl_lease_opportunities_tl.description%TYPE := OKL_API.G_MISS_CHAR
  ,comments                       okl_lease_opportunities_tl.comments%TYPE := OKL_API.G_MISS_CHAR
  );

  TYPE lopv_tbl_type IS TABLE OF lopv_rec_type INDEX BY BINARY_INTEGER;

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
    p_lopv_tbl                     IN lopv_tbl_type,
    x_lopv_tbl                     OUT NOCOPY lopv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_tbl                     IN lopv_tbl_type,
    x_lopv_tbl                     OUT NOCOPY lopv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_tbl                     IN lopv_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_rec                     IN lopv_rec_type,
    x_lopv_rec                     OUT NOCOPY lopv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_rec                     IN lopv_rec_type,
    x_lopv_rec                     OUT NOCOPY lopv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lopv_rec                     IN lopv_rec_type);

END OKL_LOP_PVT;

/
