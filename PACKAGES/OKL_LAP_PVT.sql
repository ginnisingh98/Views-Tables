--------------------------------------------------------
--  DDL for Package OKL_LAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LAP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLAPS.pls 120.3 2006/03/02 16:29:18 pagarg noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LAP_PVT';
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
  TYPE lap_rec_type IS RECORD (
   id                             okl_lease_applications_b.id%TYPE
  ,object_version_number          okl_lease_applications_b.object_version_number%TYPE
  ,attribute_category             okl_lease_applications_b.attribute_category%TYPE
  ,attribute1                     okl_lease_applications_b.attribute1%TYPE
  ,attribute2                     okl_lease_applications_b.attribute2%TYPE
  ,attribute3                     okl_lease_applications_b.attribute3%TYPE
  ,attribute4                     okl_lease_applications_b.attribute4%TYPE
  ,attribute5                     okl_lease_applications_b.attribute5%TYPE
  ,attribute6                     okl_lease_applications_b.attribute6%TYPE
  ,attribute7                     okl_lease_applications_b.attribute7%TYPE
  ,attribute8                     okl_lease_applications_b.attribute8%TYPE
  ,attribute9                     okl_lease_applications_b.attribute9%TYPE
  ,attribute10                    okl_lease_applications_b.attribute10%TYPE
  ,attribute11                    okl_lease_applications_b.attribute11%TYPE
  ,attribute12                    okl_lease_applications_b.attribute12%TYPE
  ,attribute13                    okl_lease_applications_b.attribute13%TYPE
  ,attribute14                    okl_lease_applications_b.attribute14%TYPE
  ,attribute15                    okl_lease_applications_b.attribute15%TYPE
  ,reference_number               okl_lease_applications_b.reference_number%TYPE
  ,application_status             okl_lease_applications_b.application_status%TYPE
  ,valid_from                     okl_lease_applications_b.valid_from%TYPE
  ,valid_to                       okl_lease_applications_b.valid_to%TYPE
  ,org_id                         okl_lease_applications_b.org_id%TYPE
  ,inv_org_id                     okl_lease_applications_b.inv_org_id%TYPE
  ,prospect_id                    okl_lease_applications_b.prospect_id%TYPE
  ,prospect_address_id            okl_lease_applications_b.prospect_address_id%TYPE
  ,cust_acct_id                   okl_lease_applications_b.cust_acct_id%TYPE
  ,industry_class                 okl_lease_applications_b.industry_class%TYPE
  ,industry_code                  okl_lease_applications_b.industry_code%TYPE
  ,currency_code                  okl_lease_applications_b.currency_code%TYPE
  ,currency_conversion_type       okl_lease_applications_b.currency_conversion_type%TYPE
  ,currency_conversion_rate       okl_lease_applications_b.currency_conversion_rate%TYPE
  ,currency_conversion_date       okl_lease_applications_b.currency_conversion_date%TYPE
  ,leaseapp_template_id           okl_lease_applications_b.leaseapp_template_id%TYPE
  ,parent_leaseapp_id             okl_lease_applications_b.parent_leaseapp_id%TYPE
  ,credit_line_id                 okl_lease_applications_b.credit_line_id%TYPE
  ,program_agreement_id           okl_lease_applications_b.program_agreement_id%TYPE
  ,master_lease_id                okl_lease_applications_b.master_lease_id%TYPE
  ,sales_rep_id                   okl_lease_applications_b.sales_rep_id%TYPE
  ,sales_territory_id             okl_lease_applications_b.sales_territory_id%TYPE
  ,originating_vendor_id          okl_lease_applications_b.originating_vendor_id%TYPE
  ,lease_opportunity_id           okl_lease_applications_b.lease_opportunity_id%TYPE
  ,cr_exp_days                    okl_lease_applications_b.cr_exp_days%TYPE  --VARANGAN - for bug#4747179
  ,action                         okl_lease_applications_b.action%TYPE --PAGARG Bug 4872271
  ,orig_status                    okl_lease_applications_b.orig_status%TYPE --PAGARG Bug 4872271
  );

  -- Do not include WHO, LANGUAGE and SFWT_FLAG columns in the _TL record structure
  TYPE laptl_rec_type IS RECORD (
   id                             okl_lease_applications_tl.id%TYPE
  ,short_description              okl_lease_applications_tl.short_description%TYPE
  ,comments                       okl_lease_applications_tl.comments%TYPE
  );

  -- view record structure
  TYPE lapv_rec_type IS RECORD (
   id                             okl_lease_applications_b.id%TYPE
  ,object_version_number          okl_lease_applications_b.object_version_number%TYPE
  ,attribute_category             okl_lease_applications_b.attribute_category%TYPE
  ,attribute1                     okl_lease_applications_b.attribute1%TYPE
  ,attribute2                     okl_lease_applications_b.attribute2%TYPE
  ,attribute3                     okl_lease_applications_b.attribute3%TYPE
  ,attribute4                     okl_lease_applications_b.attribute4%TYPE
  ,attribute5                     okl_lease_applications_b.attribute5%TYPE
  ,attribute6                     okl_lease_applications_b.attribute6%TYPE
  ,attribute7                     okl_lease_applications_b.attribute7%TYPE
  ,attribute8                     okl_lease_applications_b.attribute8%TYPE
  ,attribute9                     okl_lease_applications_b.attribute9%TYPE
  ,attribute10                    okl_lease_applications_b.attribute10%TYPE
  ,attribute11                    okl_lease_applications_b.attribute11%TYPE
  ,attribute12                    okl_lease_applications_b.attribute12%TYPE
  ,attribute13                    okl_lease_applications_b.attribute13%TYPE
  ,attribute14                    okl_lease_applications_b.attribute14%TYPE
  ,attribute15                    okl_lease_applications_b.attribute15%TYPE
  ,reference_number               okl_lease_applications_b.reference_number%TYPE
  ,application_status             okl_lease_applications_b.application_status%TYPE
  ,valid_from                     okl_lease_applications_b.valid_from%TYPE
  ,valid_to                       okl_lease_applications_b.valid_to%TYPE
  ,org_id                         okl_lease_applications_b.org_id%TYPE
  ,inv_org_id                     okl_lease_applications_b.inv_org_id%TYPE
  ,prospect_id                    okl_lease_applications_b.prospect_id%TYPE
  ,prospect_address_id            okl_lease_applications_b.prospect_address_id%TYPE
  ,cust_acct_id                   okl_lease_applications_b.cust_acct_id%TYPE
  ,industry_class                 okl_lease_applications_b.industry_class%TYPE
  ,industry_code                  okl_lease_applications_b.industry_code%TYPE
  ,currency_code                  okl_lease_applications_b.currency_code%TYPE
  ,currency_conversion_type       okl_lease_applications_b.currency_conversion_type%TYPE
  ,currency_conversion_rate       okl_lease_applications_b.currency_conversion_rate%TYPE
  ,currency_conversion_date       okl_lease_applications_b.currency_conversion_date%TYPE
  ,leaseapp_template_id           okl_lease_applications_b.leaseapp_template_id%TYPE
  ,parent_leaseapp_id             okl_lease_applications_b.parent_leaseapp_id%TYPE
  ,credit_line_id                 okl_lease_applications_b.credit_line_id%TYPE
  ,program_agreement_id           okl_lease_applications_b.program_agreement_id%TYPE
  ,master_lease_id                okl_lease_applications_b.master_lease_id%TYPE
  ,sales_rep_id                   okl_lease_applications_b.sales_rep_id%TYPE
  ,sales_territory_id             okl_lease_applications_b.sales_territory_id%TYPE
  ,originating_vendor_id          okl_lease_applications_b.originating_vendor_id%TYPE
  ,lease_opportunity_id           okl_lease_applications_b.lease_opportunity_id%TYPE
  ,short_description              okl_lease_applications_tl.short_description%TYPE
  ,comments                       okl_lease_applications_tl.comments%TYPE
  ,cr_exp_days                    okl_lease_applications_b.cr_exp_days%TYPE --VARANGAN for bug#4747179
  ,action                         okl_lease_applications_b.action%TYPE --PAGARG Bug 4872271
  ,orig_status                    okl_lease_applications_b.orig_status%TYPE --PAGARG Bug 4872271
  );

  TYPE lapv_tbl_type IS TABLE OF lapv_rec_type INDEX BY BINARY_INTEGER;

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
    p_lapv_tbl                     IN lapv_tbl_type,
    x_lapv_tbl                     OUT NOCOPY lapv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lapv_tbl                     IN lapv_tbl_type,
    x_lapv_tbl                     OUT NOCOPY lapv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lapv_tbl                     IN lapv_tbl_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lapv_rec                     IN lapv_rec_type,
    x_lapv_rec                     OUT NOCOPY lapv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lapv_rec                     IN lapv_rec_type,
    x_lapv_rec                     OUT NOCOPY lapv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lapv_rec                     IN lapv_rec_type);

END OKL_LAP_PVT;

/
