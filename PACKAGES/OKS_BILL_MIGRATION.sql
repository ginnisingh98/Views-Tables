--------------------------------------------------------
--  DDL for Package OKS_BILL_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILL_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: OKSBMIGS.pls 120.0 2005/05/25 17:39:29 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  G_INVALID_END_DATE            CONSTANT VARCHAR2(200) := 'OKC_INVALID_END_DATE';
--
  G_QA_SUCCESS   		CONSTANT VARCHAR2(200) := 'OKS__QA_SUCCESS';
  G_PARTY_COUNT   		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_PARTY_COUNT';
  G_REQUIRED_RULE   		CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE';
  G_REQUIRED_RULE_VALUES        CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE_VALUES';
  G_REQUIRED_RULE_PARTY_ROLE    CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE_PARTY_ROLE';
  G_RULE_DEPENDENT_VALUE        CONSTANT VARCHAR2(200) := 'OKC_RULE_DEPENDENT_VALUE';
  G_INVALID_LINE_DATES          CONSTANT VARCHAR2(200) := 'OKC_INVALID_LINE_DATES';
  G_REQUIRED_LINE_VALUE		CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_LINE_FIELD';
  G_INVALID_LINE_CURRENCY       CONSTANT VARCHAR2(200) := 'OKC_INVALID_LINE_CURRENCY';
  G_INVALID_LINE_ITEM		CONSTANT VARCHAR2(200) := 'OKS_INVALID_LINE_ITEM';
  G_REQUIRED_COVERED_LINE       CONSTANT VARCHAR2(200) := 'OKS_REQUIRED_COVERED_LINE';
  G_INVALID_COVERAGE_LINE       CONSTANT VARCHAR2(200) := 'OKS_INVALID_COVERAGE_LINE';
  G_COVERAGE_OVERLAP            CONSTANT VARCHAR2(200) := 'OKS_COVERAGE_OVERLAP';
  G_PARTY_ROLE                  CONSTANT VARCHAR2(200) := 'OKS_PARTY_ROLE';
  G_BASE_READING                CONSTANT VARCHAR2(200) := 'OKS_COUNTER_BASE_READING';
  G_BILL_ATTR                   CONSTANT VARCHAR2(200) := 'OKS_BILLING_ATTRIBUTES';
  G_SHORT_DESC                  CONSTANT VARCHAR2(200) := 'OKS_HDR_SHORT_DESC';
  G_QA_CHECK                    CONSTANT VARCHAR2(200) := 'OKS_QA_CHECK_LIST';
  G_K_GROUP                     CONSTANT VARCHAR2(200) := 'OKS_CONTRACT_GROUP';
  G_WORKFLOW                    CONSTANT VARCHAR2(200) := 'OKS_WORK_FLOW';
  G_DEFAULT_READING             CONSTANT VARCHAR2(200) := 'OKS_COUNTER_DEFAULT_READING';
  G_PRICE_LIST                  CONSTANT VARCHAR2(200) := 'OKS_PRICE_LIST';

  G_ONE_CUST_CONTACT            CONSTANT VARCHAR2(200) := 'OKS_ONE_CUST_CONTACT';
  G_INVALID_TAX_EXEMPT		  CONSTANT VARCHAR2(200) := 'OKS_INVALID_TAX_EXEMPT';
  G_CUSTOMER_ON_CREDIT_HOLD	  CONSTANT VARCHAR2(200) := 'OKS_CUST_ON_CREDIT_HOLD';
  G_REQUIRED_FIELD              CONSTANT VARCHAR2(200) := 'OKS_REQUIRED_FIELD';
  G_AUTHORIZE_PAYMENT           CONSTANT VARCHAR2(200) := 'AUTHORIZE_PAYMENT';
  G_PRECESION                   CONSTANT NUMBER        := .01;
  G_Return_Status               Varchar2(1)      := 'S';

  TYPE numeric_tab_typ IS TABLE of number INDEX BY BINARY_INTEGER;

 ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_QA_DATA_INTEGRITY';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKS';
  ---------------------------------------------------------------------------

TYPE bill_cont_type IS RECORD
(cle_id		oks_bill_cont_lines.cle_id%type,
 amount		oks_bill_cont_lines.amount%type);

TYPE bill_cont_tbl IS TABLE of bill_cont_type index by binary_integer;


/********************* Rules Rearch *************************
PROCEDURE update_lvl_elements
     (
       p_lvl_element_tbl  IN  oks_bill_level_elements_pvt.letv_tbl_type
      ,x_lvl_element_tbl  OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type
      ,x_return_status    OUT NOCOPY Varchar2
      ,x_msg_count        OUT NOCOPY Number
      ,x_msg_data         OUT NOCOPY Varchar2
     );

********************* Rules Rearch *************************/
/********************* Rules Rearch *************************

FUNCTION Create_Timevalue (p_chr_id IN NUMBER,p_start_date IN DATE) RETURN NUMBER;

********************* Rules Rearch *************************/


PROCEDURE BILL_UPGRADATION
(
 p_chr_id_lo                 IN NUMBER DEFAULT NULL,
 p_chr_id_hi                 IN NUMBER DEFAULT NULL
);



PROCEDURE BILL_UPGRADATION_OM
(
 p_chr_id_lo                 IN NUMBER DEFAULT NULL,
 p_chr_id_hi                 IN NUMBER DEFAULT NULL
);


PROCEDURE BILL_UPGRADATION_ALL
(
 x_return_status            OUT NOCOPY VARCHAR2
);

PROCEDURE BILL_UPGRADATION_ALL_OM
(
 x_return_status            OUT NOCOPY VARCHAR2
);

PROCEDURE Update_line_numbers
(
 p_chr_id_lo                 IN NUMBER DEFAULT NULL,
 p_chr_id_hi                 IN NUMBER DEFAULT NULL
);

PROCEDURE migrate_line_numbers
(
 x_return_status            OUT NOCOPY VARCHAR2
);


Procedure MIGRATE_CURRENCY;
/**********************************************************
PROCEDURE CREATE_BILL_DTLS_FOR_ORDER
    ( p_dnz_chr_id    IN          NUMBER ,
      x_return_status OUT  NOCOPY VARCHAR2 ) ;
**************/

PROCEDURE CREATE_BILL_DTLS
    ( p_dnz_chr_id IN number ,
      p_top_line_id in number ,
      p_top_line_start_date in date ,
      p_top_line_end_date in date ,
      p_top_line_UPG_ORIG_SYSTEM_REF in varchar2,
      p_top_line_UPG_ORIG_SYSTEM_id in number,
      p_top_line_date_terminated in date ,
      x_return_status OUT  NOCOPY varchar2 ) ;



procedure Create_Billing_Schd
(
  P_srv_sdt          IN  Date
  , P_srv_edt          IN  Date
  , P_amount           IN  Number
  , P_chr_id           IN  Number
  , P_rule_id          IN  Varchar2
  , P_line_id          IN  Number
  , P_invoice_rule_id  IN  Number
  , X_msg_data         OUT NOCOPY Varchar2
  , X_msg_count        OUT  NOCOPY Number
  , X_Return_status    OUT  NOCOPY Varchar2
  );



PROCEDURE UPDATE_OKS_LEVEL_ELEMENTS
    ( p_dnz_chr_id    IN         NUMBER ,
      x_return_status OUT NOCOPY VARCHAR2 ) ;

-----------------------------------------------------------------------------------------
-- Specification changes as part of rules Migration .                                  --
-----------------------------------------------------------------------------------------


END OKS_BILL_MIGRATION;


 

/
