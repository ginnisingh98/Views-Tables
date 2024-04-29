--------------------------------------------------------
--  DDL for Package OKS_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILLING_PUB" AUTHID CURRENT_USER as
 /* $Header: OKSPBILS.pls 120.1.12000000.1 2007/01/16 22:05:25 appldev ship $ */

G_REQUIRED_VALUE  CONSTANT VARCHAR2(200)     := OKC_API.G_REQUIRED_VALUE;
G_INVALID_VALUE   CONSTANT VARCHAR2(200)     := OKC_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN  CONSTANT VARCHAR2(200)     := OKC_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN  CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN   CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';
G_UPPERCASE_REQUIRED  CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';


------------------------------------------------------------------------------------

  -- GLOBAL EXCEPTION

---------------------------------------------------------------------------

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_EXCEPTION_ROLLBACK EXCEPTION;

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'OKS_BILLING_PUB';
  G_APP_NAME                  CONSTANT VARCHAR2(3) := 'OKS';
  G_NUM_DAYS_WEEK             CONSTANT NUMBER := 7;
  G_QUATERLY                  CONSTANT NUMBER := 3;
  G_HALFYEARLY                CONSTANT NUMBER := 6;
  G_YEARLY                    CONSTANT NUMBER := 12;
  G_SERVICE_LINE_STYLE        CONSTANT NUMBER := 1;
  G_COVERAGE_LEVEL_STYLE      CONSTANT NUMBER := 2;
  G_USAGE_LINE_STYLE	      CONSTANT NUMBER := 3;
  G_INSTALLED_ITEM_STYLE      CONSTANT NUMBER := 4;
  G_REGULAR                   CONSTANT NUMBER := 1;
  G_NONREGULAR                CONSTANT NUMBER := 2;
  G_STAT_REG_INV_TO_AR        CONSTANT NUMBER := 1;
  G_STAT_TER_CR_INV_TO_AR     CONSTANT NUMBER :=2;
  G_BILLACTION_TR             CONSTANT VARCHAR2(9) := 'TR';
  G_BILLACTION_RI             CONSTANT VARCHAR2(9) := 'RI';

  l_write_log              BOOLEAN;
  l_write_report           BOOLEAN;
  l_yes_no                 VARCHAR2(10);

Type l_calc_rec_type is Record
(
l_calc_sdate Date,
l_calc_edate Date,
l_bill_stdt  date,
l_bill_eddt  Date,
l_bcl_id     Number,
l_bcl_amount Number,
l_stat       Varchar2(3)
);

l_calc_rec l_calc_rec_type;


l_cov_tbl             OKS_BILL_REC_PUB.COVERED_TBL;
l_line_rec            OKS_QP_PKG.INPUT_DETAILS ;
l_price_rec           OKS_QP_PKG.PRICE_DETAILS ;
l_modifier_details    QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
l_price_break_details OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;

--l_line_tbl        OKS_QP_INT_PVT.G_SLINE_TBL_TYPE ;




PROCEDURE  Billing_Main
(
ERRBUF             OUT NOCOPY  VARCHAR2,
RETCODE            OUT NOCOPY  NUMBER,
p_contract_hdr_id   IN         NUMBER,
--P_cont_modifier   IN         VARCHAR2,
-- nechatur 29-Nov-2005 bug#4459229 Changing the type of P-default_date to VARCHAR2
-- P_default_date      IN         DATE,
P_default_date      IN         VARCHAR2,
-- end bug#4459229
p_org_id            IN         NUMBER,
P_Customer_id       IN         NUMBER,
P_category          IN         VARCHAR2,
P_Grp_Id            IN         NUMBER,
P_Process           IN         VARCHAR2
);

Procedure Calculate_bill
 (
  ERRBUF                     OUT  NOCOPY VARCHAR2
 ,RETCODE                    OUT  NOCOPY NUMBER
 ,P_calledfrom                IN         NUMBER
 ,P_flag                      IN         NUMBER
 ,P_date                      IN         DATE
 ,p_process_from              IN         NUMBER
 ,p_process_to                IN         NUMBER
 ,P_Prv                       IN         NUMBER
 );



Procedure Process_Suppress_Credits
  (
   ERRBUF            OUT NOCOPY VARCHAR2,
   RETCODE           OUT NOCOPY NUMBER,
   P_CONTRACT_HDR_ID IN         NUMBER,
   P_ORG_ID          IN         NUMBER,
   P_CATEGORY        IN         VARCHAR2
  );



end OKS_BILLING_PUB;



 

/
