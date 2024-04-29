--------------------------------------------------------
--  DDL for Package CSC_ACTION_ASSEMBLER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_ACTION_ASSEMBLER_PVT" AUTHID CURRENT_USER AS
/* $Header: cscvrens.pls 115.14 2004/07/13 07:47:34 bhroy ship $ */

G_OUTCOME_TBL  OKC_CONDITION_EVAL_PUB.OUTCOME_TAB_TYPE;

G_MSG_REC OKC_AQ_PVT.MSG_REC_TYP;
G_MSG_TBL OKC_AQ_PVT.MSG_TAB_TYP;


TYPE Params_Rec_Type IS RECORD (
	PNAME	VARCHAR2(2000),
	Name 	VARCHAR2(200),
	Value   VARCHAR2(2000) );
TYPE Params_Tab_Type IS TABLE OF Params_Rec_Type
 INDEX BY BINARY_INTEGER;

TYPE Plan_Id_Type IS RECORD (
  PLAN_ID NUMBER );
TYPE Plan_id_Tab_Type IS TABLE OF Plan_Id_Type
 INDEX BY BINARY_INTEGER;

TYPE Results_Rec_Type IS RECORD (
	NAME	VARCHAR2(1000),
	TYPE 	VARCHAR2(1000),
        DESCRIPTION VARCHAR2(1800) );

TYPE Results_Tab_Type IS TABLE OF Results_Rec_Type
 INDEX BY BINARY_INTEGER;

TYPE Condition_ID_Rec_Type IS RECORD  (
       Condition_Id NUMBER );

TYPE Condition_ID_Tab_Type IS TABLE OF Condition_ID_Rec_Type
  INDEX BY BINARY_INTEGER;


PROCEDURE ENABLE_PLAN (P_PARTY_ID 	     NUMBER,
		    P_CUST_ACCOUNT_ID        NUMBER,
		    P_END_USER_TYPE          VARCHAR2 := NULL,
                    X_CONDITION_ID_TBL      OUT NOCOPY CONDITION_ID_Tab_Type ) ;


PROCEDURE ENABLE_PLAN_AND_GET_OUTCOMES (
		    P_PARTY_ID                   NUMBER,
		    P_Cust_Account_Id            NUMBER,
		    P_End_User_Type              VARCHAR2 :=  NULL,
                    P_Application_Short_Name     VARCHAR2,
		    p_Msg_Tbl                    OKC_AQ_PVT.MSG_TAB_TYP,
		    x_results_tbl            OUT NOCOPY RESULTS_TAB_TYPE ) ;

PROCEDURE GET_OUTCOMES(
 	           p_api_version_number IN  NUMBER,
 	           p_init_msg_list      IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
 	           p_condition_id		IN  okc_condition_headers_b.id%TYPE,
                   p_application_short_name IN VARCHAR2,
 	           p_Msg_Tbl		IN  OKC_AQ_PVT.MSG_TAB_TYP,
 	           x_return_status      OUT NOCOPY VARCHAR2,
 	           x_msg_count          OUT NOCOPY NUMBER,
   	           x_msg_data           OUT NOCOPY VARCHAR2,
                   X_RESULTS_TBL        IN OUT NOCOPY RESULTS_TAB_TYPE  );

FUNCTION GET_ALERT_NAME(P_String VARCHAR2,p_Application_Short_Name IN VARCHAR2,
                   x_name OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2;

FUNCTION GET_SCRIPT_NAME( P_String  VARCHAR2 ) RETURN VARCHAR2;

FUNCTION DETACH_STRING ( p_string VARCHAR2,x_Name OUT NOCOPY VARCHAR2 ) RETURN params_tab_type;



END CSC_ACTION_ASSEMBLER_PVT;

 

/
