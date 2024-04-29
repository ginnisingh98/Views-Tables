--------------------------------------------------------
--  DDL for Package OKL_MLA_CREATE_UPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MLA_CREATE_UPDATE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPMCUS.pls 120.1 2006/11/22 15:11:07 zrehman noship $ */

  -------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) :=  'OKL_MLA_CREATE_UPDATE_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
  OKL_TEMP_TYPE_PROGRAM		CONSTANT VARCHAR2(30)   := 'PROGRAM';
  OKL_TEMP_TYPE_LEASEAPP	CONSTANT VARCHAR2(30)   := 'LEASEAPP';
  OKL_TEMP_TYPE_CONTRACT	CONSTANT VARCHAR2(30)   := 'CONTRACT';
  ---------------------------------------------------------------------------


  TYPE deal_rec_type is record (
	chr_id okl_k_headers_full_v.id%type,
	chr_contract_number okl_k_headers_full_v.contract_number%type,
	chr_description okl_k_headers_full_v.description%type,
	vers_version VARCHAR2(30),
	chr_sts_code okl_k_headers_full_v.sts_code%type,
	chr_start_date okl_k_headers_full_v.start_date%type,
	chr_end_date okl_k_headers_full_v.end_date%type,
	khr_term_duration okl_k_headers_full_v.term_duration%type,
	chr_CUST_PO_NUMBER okl_k_headers_full_v.CUST_PO_NUMBER%type,
	chr_INV_ORGANIZATION_ID okl_k_headers_full_v.INV_ORGANIZATION_ID%type,
	chr_AUTHORING_ORG_ID okl_k_headers_full_v.AUTHORING_ORG_ID%type,
	khr_GENERATE_ACCRUAL_YN okl_k_headers_full_v.GENERATE_ACCRUAL_YN%type,
	khr_SYNDICATABLE_YN okl_k_headers_full_v.SYNDICATABLE_YN%type,
	khr_PREFUNDING_ELIGIBLE_YN okl_k_headers_full_v.PREFUNDING_ELIGIBLE_YN%type,
	khr_REVOLVING_CREDIT_YN okl_k_headers_full_v.REVOLVING_CREDIT_YN%type,
	khr_CONVERTED_ACCOUNT_YN okl_k_headers_full_v.CONVERTED_ACCOUNT_YN%type,
	khr_CREDIT_ACT_YN okl_k_headers_full_v.CREDIT_ACT_YN%type,
	chr_TEMPLATE_YN  okl_k_headers_full_v.TEMPLATE_YN%type,
	chr_DATE_SIGNED okl_k_headers_full_v.DATE_SIGNED%type,
	khr_DATE_DEAL_TRANSFERRED okl_k_headers_full_v.DATE_DEAL_TRANSFERRED%type,
	khr_ACCEPTED_DATE  okl_k_headers_full_v.ACCEPTED_DATE%type,
	khr_EXPECTED_DELIVERY_DATE okl_k_headers_full_v.EXPECTED_DELIVERY_DATE%type,
	khr_AMD_CODE okl_k_headers_full_v.AMD_CODE%type,
	khr_DEAL_TYPE okl_k_headers_full_v.DEAL_TYPE%type,
	mla_contract_number okl_k_headers_full_v.contract_number%type,
	mla_gvr_chr_id_referred okc_governances_v.chr_id_referred%type,
	mla_gvr_id okl_k_headers_full_v.id%type,
	cust_id okc_k_party_roles_v.id%type,
	cust_object1_id1 okc_k_party_roles_v.object1_id1%type,
	cust_object1_id2 okc_k_party_roles_v.object1_id2%type,
	cust_jtot_object1_code okc_k_party_roles_v.jtot_object1_code%type,
	cust_name varchar2(250),
	lessor_id okc_k_party_roles_v.id%type,
	lessor_object1_id1 okc_k_party_roles_v.object1_id1%type,
	lessor_object1_id2 okc_k_party_roles_v.object1_id2%type,
	lessor_jtot_object1_code okc_k_party_roles_v.jtot_object1_code%type,
	lessor_name varchar2(250),
	chr_currency_code okl_k_headers_full_v.currency_code%type,
	currency_name varchar2(250),
	khr_pdt_id okl_k_headers_full_v.pdt_id%type,
	product_name okl_products_v.name%type,
	product_description okl_products_v.description%type,
	khr_khr_id okl_k_headers_full_v.khr_id%type,
	program_contract_number okl_k_headers_full_v.contract_number%type,
	cl_contract_number okl_k_headers_full_v.contract_number%type,
	cl_gvr_chr_id_referred okl_k_headers_full_v.id%type,
	cl_gvr_id okl_k_headers_full_v.id%type,
	rg_larles_id okc_rule_groups_v.id%type,
	r_larles_id okc_rule_groups_v.id%type,
	r_larles_rule_information1 okc_rules_v.rule_information1%type,
	col_larles_form_left_prompt  varchar2(250),
	rg_LAREBL_id  okc_rule_groups_v.id%type,
	r_LAREBL_id  okc_rule_groups_v.id%type,
	r_LAREBL_rule_information1  okc_rules_v.rule_information1%type,
	col_larebl_form_left_prompt varchar2(250),
        chr_cust_acct_id  okc_k_headers_b.cust_acct_id%type,
        customer_account varchar2(250),
	cust_site_description varchar2(250),
	contact_id okc_contacts_v.id%type,
	contact_object1_id1 okc_contacts_v.object1_id1%type,
	contact_object1_id2 okc_contacts_v.object1_id2%type,
	contact_jtot_object1_code okc_contacts_v.jtot_object1_code%type,
	contact_name varchar2(250),
	rg_LATOWN_id okc_rule_groups_v.id%type,
	r_LATOWN_id okc_rule_groups_v.id%type,
	r_LATOWN_rule_information1 okc_rules_v.rule_information1%type,
	col_latown_form_left_prompt varchar2(250),
	rg_LANNTF_id okc_rule_groups_v.id%type,
	r_LANNTF_id okc_rule_groups_v.id%type,
	r_LANNTF_rule_information1 okc_rules_v.rule_information1%type,
	col_lanntf_form_left_prompt varchar2(250),
	rg_LACPLN_id okc_rule_groups_v.id%type,
	r_LACPLN_id okc_rule_groups_v.id%type,
	r_LACPLN_rule_information1 okc_rules_v.rule_information1%type,
	col_lacpln_form_left_prompt varchar2(250),
	rg_LAPACT_id okc_rule_groups_v.id%type,
	r_LAPACT_id okc_rule_groups_v.id%type,
	r_LAPACT_rule_information1 okc_rules_v.rule_information1%type,
	col_lapact_form_left_prompt  varchar2(250),
	khr_CURRENCY_CONV_TYPE  okl_k_headers_full_v.CURRENCY_CONVERSION_TYPE%type,
	khr_CURRENCY_CONV_RATE  okl_k_headers_full_v.CURRENCY_CONVERSION_RATE%type,
	khr_CURRENCY_CONV_DATE  okl_k_headers_full_v.CURRENCY_CONVERSION_DATE%type,
	khr_ASSIGNABLE_YN  okl_k_headers_full_v.ASSIGNABLE_YN%type,
	legal_entity_id NUMBER
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
   );

  TYPE party_tab_type is table of party_rec_type INDEX BY BINARY_INTEGER;


  TYPE upd_deal_rec_type is record (
	chr_id okl_k_headers_full_v.id%type,
	chr_contract_number okl_k_headers_full_v.contract_number%type,
	chr_description okl_k_headers_full_v.description%type,
	chr_start_date okl_k_headers_full_v.start_date%type,
	chr_end_date okl_k_headers_full_v.end_date%type,
	khr_CONVERTED_ACCOUNT_YN okl_k_headers_full_v.CONVERTED_ACCOUNT_YN%type,
	chr_TEMPLATE_YN  okl_k_headers_full_v.TEMPLATE_YN%type,
	chr_DATE_SIGNED okl_k_headers_full_v.DATE_SIGNED%type,
	chr_currency_code okl_k_headers_full_v.currency_code%type,
	legal_entity_id NUMBER
	);

  TYPE upd_deal_tab_type is table of upd_deal_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE update_deal(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_durv_rec                     IN  upd_deal_rec_type,
      x_durv_rec                     OUT NOCOPY upd_deal_rec_type
      );


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
    p_legal_entity_id              IN NUMBER);

PROCEDURE create_party(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_kpl_rec                 IN  party_rec_type,
      x_kpl_rec                 OUT NOCOPY party_rec_type
      );


END  OKL_MLA_CREATE_UPDATE_PUB;

/
