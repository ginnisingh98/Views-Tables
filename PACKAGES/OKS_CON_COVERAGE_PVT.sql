--------------------------------------------------------
--  DDL for Package OKS_CON_COVERAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CON_COVERAGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRACCS.pls 120.1 2005/07/05 12:13:56 jvarghes noship $ */

  -- GLOBAL_MESSAGE_CONSTANTS
  -- GLOBAL_MESSAGE_CONSTANTS
  ---------------------------------------------------------------------------------------------
  G_TRUE   	               	 CONSTANT VARCHAR2(200) :=  OKC_API.G_TRUE;
  G_FALSE                      CONSTANT VARCHAR2(200) :=  OKC_API.G_FALSE;
  G_RET_STS_SUCCESS            CONSTANT VARCHAR2(200) :=  OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT VARCHAR2(200) :=  OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT VARCHAR2(200) :=  OKC_API.G_RET_STS_UNEXP_ERROR;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) :=  OKC_API.G_PARENT_TABLE_TOKEN;
  G_NO_PARENT_RECORD		 CONSTANT VARCHAR2(200)	:= 'OKS_NO_PARENT_RECORD';
  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) :=  OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED         CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  ---------------------------------------------------------------------------------------------

  -- GLOBAL EXCEPTION
  ---------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------

  -- GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_PKG_NAME	               CONSTANT VARCHAR2(200) := 'OKS_CON_COVERAGE_PVT';
  G_APP_NAME	               CONSTANT VARCHAR2(3)   :=  'OKC';
  -------------------------------------------------------------------------------

  G_GRACE_PROFILE_SET            CONSTANT VARCHAR2(1)   := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD'); --'Y'; --'N';



  SUBTYPE Gx_Boolean         IS VARCHAR2(1);
  SUBTYPE Gx_YesNo           IS VARCHAR2(1);
  SUBTYPE Gx_Ret_Sts         IS VARCHAR2(1);
  SUBTYPE Gx_ExceptionMsg    IS VARCHAR2(200);

  SUBTYPE ser_tbl_type IS OKS_CON_COVERAGE_PUB.ser_tbl_type;
  SUBTYPE cov_tbl_type IS OKS_CON_COVERAGE_PUB.cov_tbl_type;
  SUBTYPE pricing_tbl_type IS OKS_CON_COVERAGE_PUB.pricing_tbl_type;
  SUBTYPE input_br_rec IS OKS_CON_COVERAGE_PUB.input_br_rec;
  SUBTYPE labor_sch_tbl_type IS OKS_CON_COVERAGE_PUB.labor_sch_tbl_type;
  SUBTYPE bill_rate_tbl_type IS OKS_CON_COVERAGE_PUB.bill_rate_tbl_type;

  TYPE g_work_rec IS RECORD(
			seq_no			Number,
            charges_line_number     Number,
			estimate_detail_id	Number,
			contract_line_id		Number,
			txn_group_id		Number,
			billing_type_id		Number,
			charge_amount		Number,
			discounted_amount		Number,
            status                  Varchar2(1),
            warranty_flag           Varchar2(1),
            business_process_id     number, --11.5.9 changes
            request_date            date, --11.5.9 changes
            allow_full_discount     Varchar2(1)
                  );

  TYPE g_work_tbl IS TABLE of g_work_rec INDEX BY BINARY_INTEGER;

  TYPE g_out_rec IS RECORD(
		txngrp_id		Number,
		btype_id		Number,
		upto_amt		Number,
		per_cvd		Number,
            status            Varchar2(1));
  TYPE g_out_tbl IS TABLE OF g_out_rec INDEX BY BINARY_INTEGER;


  PROCEDURE apply_contract_coverage
	(p_api_version            IN  Number
	,p_init_msg_list          IN Varchar2
      ,p_est_amt_tbl            IN  ser_tbl_type
	,x_return_status          OUT NOCOPY Varchar2
	,x_msg_count              OUT NOCOPY Number
	,x_msg_data               OUT NOCOPY Varchar2
	,x_est_discounted_amt_tbl OUT NOCOPY cov_tbl_type);

  PROCEDURE get_bp_pricelist
	(p_api_version	        IN  Number
	,p_init_msg_list	        IN  Varchar2
    ,p_Contract_line_id		IN NUMBER
    ,p_business_process_id  IN NUMBER
    ,p_request_date         IN DATE
	,x_return_status 	        OUT NOCOPY Varchar2
	,x_msg_count	        OUT NOCOPY Number
	,x_msg_data		        OUT NOCOPY Varchar2
	,x_pricing_tbl		    OUT NOCOPY PRICING_TBL_TYPE );

  PROCEDURE get_bill_rates
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,P_input_br_rec         IN INPUT_BR_REC
    ,P_labor_sch_tbl        IN LABOR_SCH_TBL_TYPE
    ,x_return_status        OUT NOCOPY Varchar2
    ,x_msg_count            OUT NOCOPY Number
    ,x_msg_data             OUT NOCOPY Varchar2
    ,X_bill_rate_tbl        OUT NOCOPY BILL_RATE_TBL_TYPE );

  FUNCTION get_next_wkday
	(p_today         		IN Varchar2)  RETURN Varchar2;

  --Bug# 4194507 (JVARGHES)

  PROCEDURE Remove_Zero_Duration_Billrates
   (p_Input_Tab          IN  BILL_RATE_TBL_TYPE
   ,x_Output_Tab         OUT NOCOPY BILL_RATE_TBL_TYPE
   ,x_Return_Status   	 OUT NOCOPY Gx_Ret_Sts);

  --

  PROCEDURE Sort_Billrates_datetime
    (P_Input_Tab          IN  BILL_RATE_TBL_TYPE
    ,X_Output_Tab         out nocopy BILL_RATE_TBL_TYPE
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  FUNCTION Get_Final_End_Date(
    P_Contract_Id         IN number,
    P_Enddate             IN DATE) Return Date;

--
-- Added for 12.0 Coverage Rearch project (JVARGHES)
--

  FUNCTION Get_BP_Line_Start_Offset
    (P_BPL_Id	              IN NUMBER
    ,P_SVL_Start	              IN DATE
    ,P_BPL_Start                IN DATE
    ,p_Std_Cov_YN               IN VARCHAR2) RETURN DATE;

--
-- Added for 12.0 Coverage Rearch project (JVARGHES)
--

  FUNCTION Get_grace_end_Date
    (P_dnz_chr_Id	        IN NUMBER
    ,P_SVL_end       	  IN DATE
    ,P_BPL_end            IN DATE
    ,p_Std_Cov_YN         IN VARCHAR2) RETURN DATE;

--
--

END OKS_CON_COVERAGE_PVT;

 

/
