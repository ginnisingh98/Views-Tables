--------------------------------------------------------
--  DDL for Package OKL_VENDOR_AGREEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VENDOR_AGREEMENT_PUB" AUTHID CURRENT_USER AS
/*$Header: OKLPVAGS.pls 120.4 2008/02/29 10:17:25 veramach ship $*/
/*#
 * Vendor Agreement API allows users to perform actions on
 * vendor agreements in  Lease Management.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Vendor Agreement API
 * @rep:category BUSINESS_ENTITY  OKL_VENDOR_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:compatibility S
 */

/* Header Variables */

SUBTYPE chrv_rec_type    IS OKL_VENDOR_PROGRAM_PUB.chrv_rec_type;
SUBTYPE khrv_rec_type    IS OKL_VENDOR_PROGRAM_PUB.khrv_rec_type;
SUBTYPE program_header_rec IS OKL_VENDOR_PROGRAM_PUB.program_header_rec_type;

/* Party Role/Contact Variables */
SUBTYPE ctcv_rec_type is OKL_CONTRACT_PARTY_PUB.ctcv_rec_type;
SUBTYPE ctcv_tbl_type is OKL_CONTRACT_PARTY_PUB.ctcv_tbl_type;
SUBTYPE cplv_rec_type is OKL_CONTRACT_PARTY_PUB.cplv_rec_type;
SUBTYPE cplv_tbl_type is OKL_CONTRACT_PARTY_PUB.cplv_tbl_type;

/* Rule Group */
SUBTYPE rgpv_rec_type IS OKL_VP_RULE_PUB.rgpv_rec_type;
SUBTYPE rgpv_tbl_type IS OKL_VP_RULE_PUB.rgpv_tbl_type;

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
  G_PKG_NAME            CONSTANT VARCHAR2(200) := 'OKL_VENDOR_AGREEMENT_PUB';
  G_APP_NAME            CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_API_TYPE    		CONSTANT VARCHAR2(4)   := '_PVT';
  G_REQUIRED_VALUE      CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE       CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKL_VENDOR_AGREEMENT_UNEXPECTED_ERROR';
  G_COL_NAME_TOKEN      CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

/* Party Role and Contact Record */
TYPE PARTY_ROLE_CONTACT_REC IS RECORD (
    party_role_code    OKC_K_PARTY_ROLES_V.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    party_role_id      NUMBER := OKC_API.G_MISS_NUM,
    contact_role_code  OKC_CONTACTS_V.CRO_CODE%TYPE := OKC_API.G_MISS_CHAR,
    contact_role_id    NUMBER := OKC_API.G_MISS_NUM);

TYPE PARTY_ROLE_CONTACT_TBL IS TABLE OF PARTY_ROLE_CONTACT_REC INDEX BY BINARY_INTEGER;

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

/* Vendor Billing Record */
TYPE VENDOR_BILLING_REC IS RECORD (
    	customer_id		    NUMBER := OKC_API.G_MISS_NUM,
	cust_acct_id          NUMBER := OKC_API.G_MISS_NUM,
    	bill_to_site_use_id   NUMBER := OKC_API.G_MISS_NUM,
    	payment_method	    NUMBER := OKC_API.G_MISS_NUM,
    	bank_account	    NUMBER := OKC_API.G_MISS_NUM,
    	invoice_format	    OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
    	review_invoice	    OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	review_reason	    OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
	review_until_date	    DATE := OKC_API.G_MISS_DATE
);

/* Articles Record */
TYPE ARTICLE_REC IS RECORD (
    article_name OKC_K_ARTICLES_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    version      OKC_K_ARTICLES_V.SAV_SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR);

TYPE ARTICLE_TBL IS TABLE OF ARTICLE_REC INDEX BY BINARY_INTEGER;

/*
* Procedure: CREATE_VENDOR_AGREEMENT
*/
/*#
 * Create Vendor Agreement API allows creation of a vendor agreement.
 * This API can also be used to create a party, contact, term set
 * or a article on a vendor agreement.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Error message data
 * @param p_hdr_rec Vendor program header record
 * @param p_parent_agreement_number Parent agreement number
 * @param p_party_role_contact_tbl Party role and contact
 * @param p_vendor_billing_rec  Vendor Billing Record
 * @param p_terms_n_conditions_tbl Terms and Conditions
 * @param p_article_tbl Articles Record
 * @rep:displayname Create Vendor Agreement
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_VENDOR_RELATIONSHIP
 */
PROCEDURE create_vendor_agreement(
				  p_api_version     	    IN NUMBER,
                          p_init_msg_list           IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          p_hdr_rec                 IN program_header_rec,
                          p_parent_agreement_number IN VARCHAR2 DEFAULT NULL,
                          p_party_role_contact_tbl  IN party_role_contact_tbl,
				  p_vendor_billing_rec	    IN VENDOR_BILLING_REC,
                          p_terms_n_conditions_tbl  IN TERMS_AND_CONDITIONS_TBL,
                          p_article_tbl	          IN article_tbl,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count               OUT NOCOPY NUMBER,
                          x_msg_data                OUT NOCOPY VARCHAR2
					);


END OKL_VENDOR_AGREEMENT_PUB;

/
