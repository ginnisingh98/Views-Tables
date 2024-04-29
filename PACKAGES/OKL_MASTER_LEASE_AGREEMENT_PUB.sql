--------------------------------------------------------
--  DDL for Package OKL_MASTER_LEASE_AGREEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MASTER_LEASE_AGREEMENT_PUB" AUTHID CURRENT_USER AS
/*$Header: OKLPMAGS.pls 120.4 2008/02/29 10:51:52 nikshah noship $*/
/*#
 * Master Lease Agreement API allows users to perform actions on
 * Master Lease Agreements in  Lease Management.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Master Lease Agreement API
 * @rep:category BUSINESS_ENTITY  OKL_ORIGINATION
 * @rep:lifecycle active
 * @rep:compatibility S
 */

/* Header Variables */

SUBTYPE chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
subtype khrv_rec_type is OKL_CONTRACT_PUB.khrv_rec_type;
subtype khrv_tbl_type is OKL_CONTRACT_PUB.khrv_tbl_type;
subtype hdr_tbl_type  is OKL_CONTRACT_PUB.hdr_tbl_type;

/* Governances for Credit Line link */
SUBTYPE gvev_rec_type IS OKL_OKC_MIGRATION_PVT.gvev_rec_type;

/* Party Role*/
subtype cplv_rec_type is OKL_OKC_MIGRATION_PVT.cplv_rec_type;
SUBTYPE cplv_tbl_type is OKL_CONTRACT_PARTY_PUB.cplv_tbl_type;

/* Terms and Conditions */
subtype rgr_rec_type     is OKL_RGRP_RULES_PROCESS_PUB.rgr_rec_type;
subtype rgr_tbl_type     is OKL_RGRP_RULES_PROCESS_PUB.rgr_tbl_type;
subtype rgr_out_rec_type is OKL_RGRP_RULES_PROCESS_PUB.rgr_out_rec_type;
subtype rgr_out_tbl_type is OKL_RGRP_RULES_PROCESS_PUB.rgr_out_tbl_type;

/* Articles */
SUBTYPE catv_rec_type is OKL_VP_K_ARTICLE_PUB.catv_rec_type;
SUBTYPE catv_tbl_type is OKL_VP_K_ARTICLE_PUB.catv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                       CONSTANT VARCHAR2(200) := 'OKL_MASTER_LEASE_AGREEMENT_PUB';
  G_APP_NAME                       CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
  G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_MASTER_LEASE_AGREEMENT_UNEXPECTED_ERROR';
  G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;

/* Party Role Record */
TYPE HEADER_REC IS RECORD (
     	AGREEMENT_NUMBER    	OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
     	DESCRIPTION         	OKC_K_HEADERS_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
     	CUSTOMER_ID	     	  	OKC_K_PARTY_ROLES_V.OBJECT1_ID1%type := OKC_API.G_MISS_CHAR,
     	DATE_SIGNED		  	OKC_K_HEADERS_V.DATE_SIGNED%TYPE := OKC_API.G_MISS_DATE,
	START_DATE		  	OKC_K_HEADERS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
	END_DATE		  	OKC_K_HEADERS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
	CURRENCY_CODE	  	OKC_K_HEADERS_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
	CREDIT_LINE_NUMBER  	OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
	TEMPLATE_YN		  	OKC_K_HEADERS_V.TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
	CONVERTED_ACCOUNT_YN  	OKL_K_HEADERS_V.CONVERTED_ACCOUNT_YN%TYPE := OKC_API.G_MISS_CHAR,
	CONVERTED_LEGACY_NO   	OKC_K_HEADERS_V.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR,
	TC_TPO_MID_TERM_OPTION	OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_TPO_MID_TERM_AMT	OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_TPO_END_TERM_OPTION	OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_TPO_END_TERM_AMT	OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_RO_RENEW_NOTICE_DAYS	OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_RO_RENEW_OPTION	OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_RO_RENEW_AMT		OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_TAX_WITHHOLD_YN	OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_TAX_FORMULA		OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_INS_BLANKET_YN		OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_INS_INSURABLE_YN	OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	TC_INS_CANCEL_YN		OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
        --	added by zrehman for LE Uptake project 17-Nov-2006
        LEGAL_ENTITY_ID         NUMBER :=OKL_API.G_MISS_NUM);


/* Terms and Conditions Record */
TYPE TERMS_AND_CONDITIONS_REC IS RECORD (
	RULE_GROUP_CODE	   OKC_RULE_GROUPS_V.RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
      RULE_CODE		   OKC_RULES_V.RULE_INFORMATION_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
      object1_id1          OKC_RULES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
      object2_id1          OKC_RULES_V.OBJECT2_ID1%TYPE := OKC_API.G_MISS_CHAR,
      object3_id1          OKC_RULES_V.OBJECT3_ID1%TYPE := OKC_API.G_MISS_CHAR,
      object1_id2          OKC_RULES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
      object2_id2          OKC_RULES_V.OBJECT2_ID2%TYPE := OKC_API.G_MISS_CHAR,
      object3_id2          OKC_RULES_V.OBJECT3_ID2%TYPE := OKC_API.G_MISS_CHAR,
      jtot_object1_code    OKC_RULES_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
      jtot_object2_code    OKC_RULES_V.JTOT_OBJECT2_CODE%TYPE := OKC_API.G_MISS_CHAR,
      jtot_object3_code    OKC_RULES_V.JTOT_OBJECT3_CODE%TYPE := OKC_API.G_MISS_CHAR,
      rule_information1    OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
      rule_information2    OKC_RULES_V.RULE_INFORMATION2%TYPE := OKC_API.G_MISS_CHAR,
      rule_information3    OKC_RULES_V.RULE_INFORMATION3%TYPE := OKC_API.G_MISS_CHAR,
      rule_information4    OKC_RULES_V.RULE_INFORMATION4%TYPE := OKC_API.G_MISS_CHAR,
      rule_information5    OKC_RULES_V.RULE_INFORMATION5%TYPE := OKC_API.G_MISS_CHAR,
      rule_information6    OKC_RULES_V.RULE_INFORMATION6%TYPE := OKC_API.G_MISS_CHAR,
      rule_information7    OKC_RULES_V.RULE_INFORMATION7%TYPE := OKC_API.G_MISS_CHAR,
      rule_information8    OKC_RULES_V.RULE_INFORMATION8%TYPE := OKC_API.G_MISS_CHAR,
      rule_information9    OKC_RULES_V.RULE_INFORMATION9%TYPE := OKC_API.G_MISS_CHAR,
      rule_information10   OKC_RULES_V.RULE_INFORMATION10%TYPE := OKC_API.G_MISS_CHAR,
      rule_information11   OKC_RULES_V.RULE_INFORMATION11%TYPE := OKC_API.G_MISS_CHAR,
      rule_information12   OKC_RULES_V.RULE_INFORMATION12%TYPE := OKC_API.G_MISS_CHAR,
      rule_information13   OKC_RULES_V.RULE_INFORMATION13%TYPE := OKC_API.G_MISS_CHAR,
      rule_information14   OKC_RULES_V.RULE_INFORMATION14%TYPE := OKC_API.G_MISS_CHAR,
      rule_information15   OKC_RULES_V.RULE_INFORMATION15%TYPE := OKC_API.G_MISS_CHAR
);

TYPE TERMS_AND_CONDITIONS_TBL IS TABLE OF TERMS_AND_CONDITIONS_REC INDEX BY BINARY_INTEGER;

/* Articles Record */
TYPE ARTICLE_REC IS RECORD (
    article_name OKC_K_ARTICLES_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    version      OKC_K_ARTICLES_V.SAV_SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR);

TYPE ARTICLE_TBL IS TABLE OF ARTICLE_REC INDEX BY BINARY_INTEGER;

/*
* Procedure: CREATE_MASTER_LEASE_AGREEMENT
*/
/*#
 * Create Master Lease Agreement
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param p_header_rec Master lease agreement header and terms and Conditions
 * @param p_article_tbl Articles
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Error message data
 * @rep:displayname Create Master Lease Agreement
 * @rep:scope public
 * @rep:lifecycle active
 */
PROCEDURE create_master_lease_agreement(
				  p_api_version     	 IN NUMBER,
                          p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
				  p_header_rec           IN HEADER_REC,
                          p_article_tbl	       IN article_tbl,
                          x_return_status        OUT NOCOPY VARCHAR2,
                          x_msg_count            OUT NOCOPY NUMBER,
                          x_msg_data             OUT NOCOPY VARCHAR2);


END OKL_MASTER_LEASE_AGREEMENT_PUB;

/
