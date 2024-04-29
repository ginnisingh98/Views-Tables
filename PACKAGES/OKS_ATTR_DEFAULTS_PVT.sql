--------------------------------------------------------
--  DDL for Package OKS_ATTR_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ATTR_DEFAULTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRDFTS.pls 120.4.12000000.1 2007/01/16 22:10:16 appldev ship $*/
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
TYPE header_lines_rec_type IS RECORD (
    chr_id                   NUMBER       ,
    cle_id                   NUMBER       ,
    header_sto               VARCHAR2(150) ,
    header_bto               VARCHAR2(150) ,
    header_dates             VARCHAR2(150) ,
    header_arl               VARCHAR2(150) ,
    header_ire               VARCHAR2(150) ,
    header_tax               VARCHAR2(150) ,
    header_exception_number  VARCHAR2(150) ,
    -- IKON ENHANCEMENT --
    header_bca               VARCHAR2(150) ,
    header_sca               VARCHAR2(150) ,
    -- IKON ENHANCEMENT --
    --Fixed bug#4026268 --gbgupta
    header_tax_code_id       NUMBER,
    header_tax_code          VARCHAR2(150) ,
    header_sales_credits     VARCHAR2(150),
    header_billto_contact     VARCHAR2(150),
    billto_id     VARCHAR2(150) ,
    billing_profile          VARCHAR2(150),
    billing_profile_id       NUMBER,
    calculate_tax            VARCHAR2(3),
    payment_method           VARCHAR2(3),
    price_uom                VARCHAR2(150), -- hkamdar 8/23/05 R12 PPE project
    price_list               VARCHAR2(150), -- hkamdar 8/23/05 R12 PPE project
    header_tax_cls_code      VARCHAR2(50) /*  nechatur 12-07-06 bug#5380870 Increased the header_tax_cls_code length from 30 to 50 */

 );
 TYPE header_lines_tbl_type IS TABLE OF header_lines_rec_type
 INDEX BY BINARY_INTEGER;

 TYPE lines_sublines_rec_type IS RECORD (
    chr_id                   NUMBER       ,
    cle_id                   NUMBER      ,
    subline_id               NUMBER       ,
    line_irt                 VARCHAR2(150) ,
    line_renewal             VARCHAR2(150) ,
    line_inv_print           VARCHAR2(150) ,
    line_dates               VARCHAR2(150) ,
    line_cov_eff             VARCHAR2(150) ,
    header_to_lines          VARCHAR2(1),
    price_uom                VARCHAR2(150) -- hkamdar 8/23/05 R12 PPE project
    );

 TYPE lines_sublines_tbl_type IS TABLE OF lines_sublines_rec_type
 INDEX BY BINARY_INTEGER;

 TYPE attr_msg_rec_type IS RECORD (
        status                    varchar2(150),
        description              varchar2(2000)

  );

TYPE attr_msg_tbl_type IS TABLE OF attr_msg_rec_type
  	INDEX BY BINARY_INTEGER;

 -- GCHADHA --
 -- BUG 4093005 --
  TYPE lines_id_rec_type IS RECORD (
     id                   NUMBER );

  TYPE lines_id_tbl_type IS TABLE OF lines_id_rec_type
  INDEX BY BINARY_INTEGER;
 -- END GCHADHA --


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE  CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE   CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN  CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN  CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN   CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED  CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_ATTR_DEFAULTS_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  G_REQUEST_ID                  CONSTANT NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  G_PROGRAM_APPLICATION_ID      CONSTANT NUMBER := FND_GLOBAL.PROG_APPL_ID;
  G_PROGRAM_ID                  CONSTANT NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;

--transfer mnagement
  G_APP_NAME_OKS	               CONSTANT VARCHAR2(3)   :=  'OKS';
  G_RET_STS_UNEXP_ERROR        CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_UNEXP_ERROR;
--transfer mnagement

   Type rule_rec_type Is RECORD
                     (
OBJECT_VERSION_NUMBER        NUMBER,
SFWT_FLAG                                VARCHAR2(3),
OBJECT1_ID1                              VARCHAR2(40),
OBJECT2_ID1                              VARCHAR2(40),
OBJECT3_ID1                              VARCHAR2(40),
OBJECT1_ID2                              VARCHAR2(200),
OBJECT2_ID2                              VARCHAR2(200),
OBJECT3_ID2                              VARCHAR2(200),
JTOT_OBJECT1_CODE                        VARCHAR2(30),
JTOT_OBJECT2_CODE                        VARCHAR2(30),
JTOT_OBJECT3_CODE                        VARCHAR2(30),
DNZ_CHR_ID                               NUMBER,
RGP_ID                                   NUMBER,
PRIORITY                                 NUMBER,
STD_TEMPLATE_YN                          VARCHAR2(3),
COMMENTS                                 VARCHAR2(1995),
WARN_YN                                  VARCHAR2(3),
CREATED_BY                               NUMBER,
CREATION_DATE                            DATE,
LAST_UPDATED_BY                          NUMBER,
LAST_UPDATE_DATE                         DATE,
LAST_UPDATE_LOGIN                        NUMBER,
TEXT                                     CLOB,
RULE_INFORMATION_CATEGORY                VARCHAR2(90),
RULE_INFORMATION1                        VARCHAR2(450),
RULE_INFORMATION2                        VARCHAR2(450),
RULE_INFORMATION3                        VARCHAR2(450),
RULE_INFORMATION4                        VARCHAR2(450),
RULE_INFORMATION5                        VARCHAR2(450),
RULE_INFORMATION6                        VARCHAR2(450),
RULE_INFORMATION7                        VARCHAR2(450),
RULE_INFORMATION8                        VARCHAR2(450),
RULE_INFORMATION9                        VARCHAR2(450),
RULE_INFORMATION10                       VARCHAR2(450),
RULE_INFORMATION11                       VARCHAR2(450),
RULE_INFORMATION12                       VARCHAR2(450),
RULE_INFORMATION13                       VARCHAR2(450),
RULE_INFORMATION14                       VARCHAR2(450),
RULE_INFORMATION15                       VARCHAR2(450));

PROCEDURE Default_header_to_lines(header_lines_tbl    IN  header_lines_tbl_type
                                    ,X_return_status       OUT NOCOPY Varchar2
                                    ,x_msg_tbl        IN   OUT NOCOPY attr_msg_tbl_type) ;

PROCEDURE update_line
   (
    p_clev_tbl      IN  okc_contract_pub.clev_tbl_type
   ,x_clev_tbl      OUT NOCOPY okc_contract_pub.clev_tbl_type
   ,x_return_status OUT NOCOPY Varchar2
   ,x_msg_count     OUT NOCOPY Number
   ,x_msg_data      OUT NOCOPY Varchar2
   );



PROCEDURE Default_lines_to_sublines(lines_sublines_tbl  IN  lines_sublines_tbl_type
     ,X_return_status  OUT          NOCOPY Varchar2
     ,x_msg_tbl        IN       OUT NOCOPY attr_msg_tbl_type);


PROCEDURE Rollback_Work;

--PROCEDURE populate_slh_record(x_slh_rec OUT OKS_BILL_SCH.streamhdr_type);
--PROCEDURE  populate_sll_table(x_sll_tbl OUT OKS_BILL_SCH.streamLVL_tbl);

-- Bank Account Consolidation --
Procedure Delete_credit_Card
 (p_trnx_ext_id IN NUMBER,
  p_line_id  IN NUMBER,
  p_party_id IN NUMBER,
  p_cust_account_id IN NUMBER ,
  x_return_status  OUT NOCOPY VARCHAR2 ,
  x_msg_data OUT NOCOPY VARCHAR2);

 Function Create_credit_Card
 (p_line_id IN NUMBER,
  p_party_id IN NUMBER,
  p_org IN NUMBER,
  p_account_site_id IN NUMBER,
  p_cust_account_id IN NUMBER,
  p_trnx_ext_id IN NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_data OUT NOCOPY VARCHAR2) RETURN NUMBER;
 -- Bank Account Consolidation --

 END OKS_ATTR_DEFAULTS_PVT;

 

/
