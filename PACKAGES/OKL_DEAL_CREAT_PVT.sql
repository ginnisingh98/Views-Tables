--------------------------------------------------------
--  DDL for Package OKL_DEAL_CREAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DEAL_CREAT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRDCRS.pls 120.1.12010000.2 2009/06/02 10:41:06 racheruv ship $ */

  -------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) :=  'OKL_DEAL_CREAT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
  OKL_TEMP_TYPE_PROGRAM		CONSTANT VARCHAR2(30)   := 'PROGRAM';
  OKL_TEMP_TYPE_LEASEAPP	CONSTANT VARCHAR2(30)   := 'LEASEAPP';
  OKL_TEMP_TYPE_CONTRACT	CONSTANT VARCHAR2(30)   := 'CONTRACT';
  ---------------------------------------------------------------------------

  -- SUBTYPE chrv_rec_type IS		OKL_OKC_MIGRATION_PVT.chrv_rec_type;
  -- SUBTYPE khrv_rec_type IS		OKL_CONTRACT_PUB.khrv_rec_type;

  TYPE deal_rec_type is record (
    chr_id okl_k_headers_full_v.id%type
   ,chr_contract_number okl_k_headers_full_v.contract_number%type
   ,chr_description okl_k_headers_full_v.description%type
   ,vers_version VARCHAR2(30)
   ,chr_sts_code okl_k_headers_full_v.sts_code%type
   ,chr_start_date okl_k_headers_full_v.start_date%type
   ,chr_end_date okl_k_headers_full_v.end_date%type
   ,khr_term_duration okl_k_headers_full_v.term_duration%type
   ,chr_CUST_PO_NUMBER okl_k_headers_full_v.CUST_PO_NUMBER%type
   ,chr_INV_ORGANIZATION_ID okl_k_headers_full_v.INV_ORGANIZATION_ID%type
   ,chr_AUTHORING_ORG_ID okl_k_headers_full_v.AUTHORING_ORG_ID%type
   ,khr_GENERATE_ACCRUAL_YN okl_k_headers_full_v.GENERATE_ACCRUAL_YN%type
   ,khr_SYNDICATABLE_YN okl_k_headers_full_v.SYNDICATABLE_YN%type
   ,khr_PREFUNDING_ELIGIBLE_YN okl_k_headers_full_v.PREFUNDING_ELIGIBLE_YN%type
   ,khr_REVOLVING_CREDIT_YN okl_k_headers_full_v.REVOLVING_CREDIT_YN%type
   ,khr_CONVERTED_ACCOUNT_YN okl_k_headers_full_v.CONVERTED_ACCOUNT_YN%type
   ,khr_CREDIT_ACT_YN okl_k_headers_full_v.CREDIT_ACT_YN%type
   ,chr_TEMPLATE_YN  okl_k_headers_full_v.TEMPLATE_YN%type
   ,chr_DATE_SIGNED okl_k_headers_full_v.DATE_SIGNED%type
   ,khr_DATE_DEAL_TRANSFERRED okl_k_headers_full_v.DATE_DEAL_TRANSFERRED%type
   ,khr_ACCEPTED_DATE  okl_k_headers_full_v.ACCEPTED_DATE%type
   ,khr_EXPECTED_DELIVERY_DATE okl_k_headers_full_v.EXPECTED_DELIVERY_DATE%type
   ,khr_AMD_CODE okl_k_headers_full_v.AMD_CODE%type
   ,khr_DEAL_TYPE okl_k_headers_full_v.DEAL_TYPE%type
   ,mla_contract_number okl_k_headers_full_v.contract_number%type
   ,mla_gvr_chr_id_referred okc_governances_v.chr_id_referred%type
   ,mla_gvr_id okl_k_headers_full_v.id%type
   ,cust_id okc_k_party_roles_v.id%type
   ,cust_object1_id1 okc_k_party_roles_v.object1_id1%type
   ,cust_object1_id2 okc_k_party_roles_v.object1_id2%type
   ,cust_jtot_object1_code okc_k_party_roles_v.jtot_object1_code%type
   ,cust_name varchar2(250)
   ,lessor_id okc_k_party_roles_v.id%type
   ,lessor_object1_id1 okc_k_party_roles_v.object1_id1%type
   ,lessor_object1_id2 okc_k_party_roles_v.object1_id2%type
   ,lessor_jtot_object1_code okc_k_party_roles_v.jtot_object1_code%type
   ,lessor_name varchar2(250)
   ,chr_currency_code okl_k_headers_full_v.currency_code%type
   ,currency_name varchar2(250)
   ,khr_pdt_id okl_k_headers_full_v.pdt_id%type
   ,product_name okl_products_v.name%type
   ,product_description okl_products_v.description%type
   ,khr_khr_id okl_k_headers_full_v.khr_id%type
   ,program_contract_number okl_k_headers_full_v.contract_number%type
   ,cl_contract_number okl_k_headers_full_v.contract_number%type
   ,cl_gvr_chr_id_referred okl_k_headers_full_v.id%type
   ,cl_gvr_id okl_k_headers_full_v.id%type
   ,rg_larles_id okc_rule_groups_v.id%type
   ,r_larles_id okc_rule_groups_v.id%type
   ,r_larles_rule_information1 okc_rules_v.rule_information1%type
   ,col_larles_form_left_prompt  varchar2(250)
   ,rg_LAREBL_id  okc_rule_groups_v.id%type
   ,r_LAREBL_id  okc_rule_groups_v.id%type
   ,r_LAREBL_rule_information1  okc_rules_v.rule_information1%type
   ,col_larebl_form_left_prompt varchar2(250)
   ,chr_cust_acct_id  okc_k_headers_b.cust_acct_id%type
   ,customer_account varchar2(250)
   ,cust_site_description varchar2(250)
   ,contact_id okc_contacts_v.id%type
   ,contact_object1_id1 okc_contacts_v.object1_id1%type
   ,contact_object1_id2 okc_contacts_v.object1_id2%type
   ,contact_jtot_object1_code okc_contacts_v.jtot_object1_code%type
   ,contact_name varchar2(250)
   ,rg_LATOWN_id okc_rule_groups_v.id%type
   ,r_LATOWN_id okc_rule_groups_v.id%type
   ,r_LATOWN_rule_information1 okc_rules_v.rule_information1%type
   ,col_latown_form_left_prompt varchar2(250)
   ,rg_LANNTF_id okc_rule_groups_v.id%type
   ,r_LANNTF_id okc_rule_groups_v.id%type
   ,r_LANNTF_rule_information1 okc_rules_v.rule_information1%type
   ,col_lanntf_form_left_prompt varchar2(250)
   ,rg_LACPLN_id okc_rule_groups_v.id%type
   ,r_LACPLN_id okc_rule_groups_v.id%type
   ,r_LACPLN_rule_information1 okc_rules_v.rule_information1%type
   ,col_lacpln_form_left_prompt varchar2(250)
   ,rg_LAPACT_id okc_rule_groups_v.id%type
   ,r_LAPACT_id okc_rule_groups_v.id%type
   ,r_LAPACT_rule_information1 okc_rules_v.rule_information1%type
   ,col_lapact_form_left_prompt  varchar2(250)
   ,khr_CURRENCY_CONV_TYPE  okl_k_headers_full_v.CURRENCY_CONVERSION_TYPE%type
   ,khr_CURRENCY_CONV_RATE  okl_k_headers_full_v.CURRENCY_CONVERSION_RATE%type
   ,khr_CURRENCY_CONV_DATE  okl_k_headers_full_v.CURRENCY_CONVERSION_DATE%type
   ,khr_ASSIGNABLE_YN  okl_k_headers_full_v.ASSIGNABLE_YN%type
   --Added by dpsingh for LE Uptake
   ,legal_entity_id NUMBER
   -- sjalasut, added attribute columns below for okl_k_headers. START code changes
   ,attribute_category okl_k_headers.attribute_category%TYPE
   ,attribute1 okl_k_headers.attribute1%TYPE
   ,attribute2 okl_k_headers.attribute2%TYPE
   ,attribute3 okl_k_headers.attribute3%TYPE
   ,attribute4 okl_k_headers.attribute4%TYPE
   ,attribute5 okl_k_headers.attribute5%TYPE
   ,attribute6 okl_k_headers.attribute6%TYPE
   ,attribute7 okl_k_headers.attribute7%TYPE
   ,attribute8 okl_k_headers.attribute8%TYPE
   ,attribute9 okl_k_headers.attribute9%TYPE
   ,attribute10 okl_k_headers.attribute10%TYPE
   ,attribute11 okl_k_headers.attribute11%TYPE
   ,attribute12 okl_k_headers.attribute12%TYPE
   ,attribute13 okl_k_headers.attribute13%TYPE
   ,attribute14 okl_k_headers.attribute14%TYPE
   ,attribute15 okl_k_headers.attribute15%TYPE
   -- sjalasut, added attribute columns below for okl_k_headers. END code changes
   -- ,labill_labacc_billto    varchar2(200)
   -- sjalasut, modified the record structure to have labill_labacc_billto data type of as number
   ,labill_labacc_billto       number
   ,labill_labacc_rgp_id       okc_rule_groups_b.id%TYPE
   ,labill_labacc_rgd_code     okc_rule_groups_b.rgd_code%TYPE
   ,labill_labacc_rul_id       okc_rules_b.id%TYPE
   ,labill_labacc_rul_info_cat okc_rules_b.rule_information_category%TYPE
	);

  TYPE deal_tab_type is table of deal_rec_type INDEX BY BINARY_INTEGER;

  TYPE party_rec_type is record (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_K_PARTY_ROLES.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_K_PARTY_ROLES.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_K_PARTY_ROLES.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_K_PARTY_ROLES.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_K_PARTY_ROLES.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_K_PARTY_ROLES.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_K_PARTY_ROLES.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_K_PARTY_ROLES.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_K_PARTY_ROLES.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_K_PARTY_ROLES.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_K_PARTY_ROLES.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_K_PARTY_ROLES.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_K_PARTY_ROLES.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_K_PARTY_ROLES.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_K_PARTY_ROLES.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_K_PARTY_ROLES.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,object1_id1                    OKC_K_PARTY_ROLES_B.object1_id1%type := OKL_API.G_MISS_CHAR
    ,object1_id2                    OKC_K_PARTY_ROLES_B.object1_id2%type := OKL_API.G_MISS_CHAR
    ,jtot_object1_code              OKC_K_PARTY_ROLES_B.jtot_object1_code%type := OKL_API.G_MISS_CHAR
    ,rle_code              	    OKC_K_PARTY_ROLES_B.rle_code%type := OKL_API.G_MISS_CHAR
    ,chr_id              	    OKC_K_PARTY_ROLES_B.chr_id%type := OKL_API.G_MISS_NUM
    ,dnz_chr_id              	    OKC_K_PARTY_ROLES_B.dnz_chr_id%type := OKL_API.G_MISS_NUM
    ,cle_id              	    OKC_K_PARTY_ROLES_B.cle_id%type := OKL_API.G_MISS_NUM
    ,cognomen			    OKC_K_PARTY_ROLES_TL.cognomen%type := OKL_API.G_MISS_CHAR
    ,alias			    OKC_K_PARTY_ROLES_TL.alias%type := OKL_API.G_MISS_CHAR
   );

  TYPE party_tab_type is table of party_rec_type INDEX BY BINARY_INTEGER;

  TYPE deal_values_rec IS RECORD(
    ACCEPTANCE_METHOD_MEANING           VARCHAR2(200)
  , ASSIGNABLE_MEANING                  VARCHAR2(200)
  , BILL_TO_ADDRESS_DESC                VARCHAR2(200)
  , BILL_TO_SITE_USE_ID                 NUMBER
  , BOOK_CLASS_MEANING                  VARCHAR2(200)
  , CAP_INTERIM_INTERST_MEANING         VARCHAR2(200)
  , CAP_INTERIM_INT_RGD_CODE            VARCHAR2(200)
  , CAP_INTERIM_INT_RGP_ID              VARCHAR2(200)
  , CAP_INTERIM_INT_RUL_ID              VARCHAR2(200)
  , CAP_INTERIM_INT_RUL_INF1            VARCHAR2(200)
  , CAP_INTERIM_INT_RUL_INF_CAT         VARCHAR2(200)
  , COL_LACPLN_FORM_LEFT_PROMPT         VARCHAR2(200)
  , COL_LANNTF_FORM_LEFT_PROMPT         VARCHAR2(200)
  , COL_LAPACT_FORM_LEFT_PROMPT         VARCHAR2(200)
  , COL_LAREBL_FORM_LEFT_PROMPT         VARCHAR2(200)
  , COL_LARLES_FORM_LEFT_PROMPT         VARCHAR2(200)
  , COL_LATOWN_FORM_LEFT_PROMPT         VARCHAR2(200)
  , CONSUMER_CREDIT_ACT_MEANING         VARCHAR2(200)
  , CONVERTED_ACCT_MEANING              VARCHAR2(200)
  , CREDIT_GVR_ID                       VARCHAR2(200)
  , CREDIT_LINE_CHR_ID                  VARCHAR2(200)
  , CREDIT_LINE_CONTRACT_NUMBER         VARCHAR2(200)
  , CURRENCY_CONV_TYPE_MEANING          VARCHAR2(200)
  , CUSTOMER_ACCOUNT                    VARCHAR2(200)
  , CUSTOMER_CPL_ID                     VARCHAR2(200)
  , CUSTOMER_JTOT_OBJECT1_CODE          VARCHAR2(200)
  , CUSTOMER_NAME                       VARCHAR2(200)
  , CUSTOMER_OBJECT1_ID1                VARCHAR2(200)
  , CUSTOMER_OBJECT1_ID2                VARCHAR2(200)
  , CUST_ACCT_ID                        NUMBER
  , CUST_PO_NUMBER                      VARCHAR2(150)
  , DEAL_TYPE                           VARCHAR2(30)
  , DESCRIPTION                         VARCHAR2(1995)
  , ELIG_FOR_PREFUNDING_MEANING         VARCHAR2(200)
  , ID                                  VARCHAR2(40)
  , INTEREST_CALC_MEANING               VARCHAR2(200)
  , LEASE_APPLICATION_ID                VARCHAR2(200)
  , LEASE_APPLICATION_NAME              VARCHAR2(200)
  , LEDGER_ID                           NUMBER
  , LEDGER_NAME                         VARCHAR2(200)
  , LEGACY_NUMBER                       VARCHAR2(200)
  , LEGAL_ADDRESS                       VARCHAR2(200)
  , LEGAL_ADDRESS_ID                    VARCHAR2(200)
  , LEGAL_ENTITY_NAME                   VARCHAR2(200)
  , LESSOR_INSURED_MEANING              VARCHAR2(200)
  , LESSOR_PAYEE_MEANING                VARCHAR2(200)
  , LESSOR_SERV_ORG_CODE                VARCHAR2(30)
  , MLA_CHR_ID                          VARCHAR2(200)
  , MLA_CONTRACT_NUMBER                 VARCHAR2(200)
  , MLA_GVR_ID                          VARCHAR2(200)
  , NNTF_RGD_CODE                       VARCHAR2(200)
  , NNTF_RGP_ID                         VARCHAR2(200)
  , NNTF_RUL_ID                         VARCHAR2(200)
  , NNTF_RUL_INF1                       VARCHAR2(200)
  , NNTF_RUL_INF_CAT                    VARCHAR2(200)
  , NON_NOTIFICATION_MEANING            VARCHAR2(200)
  , OPERATING_UNIT_NAME                 VARCHAR2(200)
  , ORIGINATION_LEASE_APPLICATION       VARCHAR2(200)
  , ORIGINATION_QUOTE_ID                VARCHAR2(200)
  , ORIGINATION_QUOTE_NAME              VARCHAR2(200)
  , ORIG_SYSTEM_ID1                     NUMBER
  , ORIG_SYSTEM_REFERENCE1              VARCHAR2(30)
  , ORIG_SYSTEM_SOURCE_CODE             VARCHAR2(30)
  , PRIVATE_ACT_BOND_MEANING            VARCHAR2(200)
  , PRODUCT_DESCRIPTION                 VARCHAR2(200)
  , PRODUCT_NAME                        VARCHAR2(200)
  , PROGRAM_TEMPLATE_CHR_ID             VARCHAR2(200)
  , PROGRAM_TEMPLATE_NAME               VARCHAR2(200)
  , PRV_ACT_BOND_RGD_CODE               VARCHAR2(200)
  , PRV_ACT_BOND_RGP_ID                 VARCHAR2(200)
  , PRV_ACT_BOND_RUL_ID                 VARCHAR2(200)
  , PRV_ACT_BOND_RUL_INF1               VARCHAR2(200)
  , PRV_ACT_BOND_RUL_INF_CAT            VARCHAR2(200)
  , REBOOK_LIMIT_DATE                   DATE
  , REBOOK_LIMIT_DATE_RGD_CODE          VARCHAR2(200)
  , REBOOK_LIMIT_DATE_RGP_ID            VARCHAR2(200)
  , REBOOK_LIMIT_DATE_RUL_ID            VARCHAR2(200)
  , REBOOK_LIMIT_RUL_INF1               VARCHAR2(200)
  , REBOOK_LIMIT_RUL_INF_CAT            VARCHAR2(200)
  , REPLACES_CHR_ID                     VARCHAR2(200)
  , REPLACES_CONTRACT_NUMBER            VARCHAR2(200)
  , REP_CONTACT_ID                      NUMBER
  , REP_CONTACT_JTOT_OBJECT1_CODE       VARCHAR2(200)
  , REP_CONTACT_OBJECT1_ID1             NUMBER
  , REP_CONTACT_OBJECT1_ID2             NUMBER
  , REVENUE_RECOGNITION_MEANING         VARCHAR2(200)
  , REVOLVING_CREDIT_YN                 VARCHAR2(3)
  , RLES_RGD_CODE                       VARCHAR2(200)
  , RLES_RGP_ID                         VARCHAR2(200)
  , RLES_RUL_ID                         VARCHAR2(200)
  , RLES_RUL_INF1                       VARCHAR2(200)
  , RLES_RUL_INF_CAT                    VARCHAR2(200)
  , RELEASED_ASSET_MEANING              VARCHAR2(200)
  , SALES_REPRESENTATIVE_NAME           VARCHAR2(200)
  , SCS_CODE_MEANING                    VARCHAR2(200)
  , SPLIT_FROM_CHR_ID                   VARCHAR2(200)
  , SPLIT_FROM_CONTRACT_NUMBER          VARCHAR2(200)
  , STS_CODE_MEANING                    VARCHAR2(200)
  , TAX_OWNER_CODE                      VARCHAR2(200)
  , TAX_OWNER_MEANING                   VARCHAR2(200)
  , TAX_OWNER_RGD_CODE                  VARCHAR2(200)
  , TAX_OWNER_RGP_ID                    VARCHAR2(200)
  , TAX_OWNER_RUL_ID                    VARCHAR2(200)
  , TAX_OWNER_RUL_INF1                  VARCHAR2(200)
  , TAX_OWNER_RUL_INF_CAT               VARCHAR2(200)
  , UPG_ORIG_SYSTEM_REF                 VARCHAR2(60)
  , UPG_ORIG_SYSTEM_REF_ID              NUMBER
  , VPA_CONTRACT_NUMBER                 VARCHAR2(200)
  , VPA_KHR_ID                          VARCHAR2(40)
  , VERS_VERSION                        VARCHAR2(200)
  , PRODUCT_SUBCLASS_CODE               VARCHAR2(200)
  , BILL_TO_RGP_ID                      VARCHAR2(40)
  , BILL_TO_RUL_ID                      VARCHAR2(40)
  , BILL_TO_RGD_CODE                    VARCHAR2(40)
  , BILL_TO_RUL_INF_CAT                 VARCHAR2(40)
  , BILL_TO_RUL_INF1                    NUMBER
  , LAST_ACTIVATION_DATE                DATE
  );

  TYPE deal_values_tbl is table of deal_rec_type INDEX BY BINARY_INTEGER;

  TYPE booking_summary_rec IS RECORD(
    DNZ_CHR_ID                          NUMBER
  , TOTAL_FINANCED_AMOUNT               VARCHAR2(200)
  , TOTAL_RESIDUAL_AMOUNT               VARCHAR2(200)
  , TOTAL_FUNDED                        VARCHAR2(200)
  , TOTAL_SUBSIDIES                     VARCHAR2(200)
  , EOT_OPTION                          VARCHAR2(200)
  , EOT_AMOUNT                          VARCHAR2(200)
  , TOTAL_UPFRONT_SALES_TAX             VARCHAR2(200)
  , RVI_PREMIUM                         VARCHAR2(200));

  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_id2                 IN  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN NUMBER);

  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_code                  IN  VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_id2                 IN  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN NUMBER);

  PROCEDURE update_deal(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_durv_rec                     IN  deal_rec_type,
      x_durv_rec                     OUT NOCOPY deal_rec_type
      );

 PROCEDURE load_deal(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_durv_rec                     IN  deal_rec_type,
      x_durv_rec                     OUT NOCOPY deal_rec_type
      );


  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_code                  IN  VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN OUT NOCOPY VARCHAR2,
    p_customer_id2                 IN OUT NOCOPY VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN OUT NOCOPY NUMBER,
    p_source_contract_number       IN  VARCHAR2,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN NUMBER);

  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_code                  IN  VARCHAR2,
    p_template_yn                  IN  VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN OUT NOCOPY VARCHAR2,
    p_customer_id2                 IN OUT NOCOPY VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN OUT NOCOPY  NUMBER,
    p_source_contract_number       IN  VARCHAR2,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN NUMBER);

  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_code                  IN  VARCHAR2,
    p_template_type                IN  VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  OUT NOCOPY VARCHAR2,
    p_customer_id2                 IN  OUT NOCOPY VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_effective_from               IN  DATE,
    p_program_name               IN  VARCHAR2,
    p_program_id                   IN  NUMBER,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN  OUT NOCOPY  NUMBER,
    p_source_contract_number       IN  VARCHAR2,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN NUMBER);


  PROCEDURE copy_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_id                    IN  NUMBER,
    p_dest_id                      IN  NUMBER,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER);

  Procedure confirm_cancel_contract
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_contract_id          IN  NUMBER,
                   p_contract_number      IN VARCHAR2);

  PROCEDURE create_party(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_kpl_rec                 IN  party_rec_type,
      x_kpl_rec                 OUT NOCOPY party_rec_type
      );

  PROCEDURE update_party(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_kpl_rec                 IN  party_rec_type,
      x_kpl_rec                 OUT NOCOPY party_rec_type
      );

  PROCEDURE copy_lease_contract(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_contract_number            IN  VARCHAR2,
      p_source_chr_id              IN  NUMBER,
      x_chr_id                     OUT NOCOPY NUMBER);

  PROCEDURE load_deal(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_deal_values_rec            OUT NOCOPY deal_values_rec
  );

  -- Start of comments
  -- API name       : load_booking_summary
  -- Pre-reqs       : None
  -- Function       : This procedure loads booking summary record
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : asahoo created.
  -- End of comments

  PROCEDURE load_booking_summary(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_booking_summary_rec        OUT NOCOPY booking_summary_rec);

END  OKL_DEAL_CREAT_PVT;

/
