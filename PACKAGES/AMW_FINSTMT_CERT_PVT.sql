--------------------------------------------------------
--  DDL for Package AMW_FINSTMT_CERT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_FINSTMT_CERT_PVT" AUTHID CURRENT_USER as
/* $Header: amwvfscs.pls 120.0 2005/05/31 20:29:53 appldev noship $ */
PROCEDURE UPDATE_NEXT_LEVEL_PROC_INFO
(p_process_id 		IN 	NUMBER,
 p_org_id 		IN 	NUMBER,
 p_certification_id 	IN 	NUMBER
);

PROCEDURE UPDATE_CERTIFICATION_DETAIL
(p_process_id 		IN 	NUMBER,
 p_org_id 		IN 	NUMBER,
 p_certification_id 	IN 	NUMBER
);

PROCEDURE UPDATE_GLOBAL_PROC_INFO
(p_process_id 		IN 	NUMBER,
 p_certification_id 	IN 	NUMBER,
 p_global_org_id 	IN 	NUMBER
);

PROCEDURE UPDATE_LAST_EVALUATION_INFO
(p_process_id 		IN 	NUMBER,
 p_org_id 		IN 	NUMBER,
 p_certification_id 	IN 	NUMBER
);

PROCEDURE UPDATE_UNMITIGATED_RISKS
(p_process_id 		IN 	NUMBER,
 p_org_id 		IN 	NUMBER,
 p_certification_id 	IN 	NUMBER
);

PROCEDURE UPDATE_INEFFECTIVE_CONTROLS
(p_process_id 		IN 	NUMBER,
 p_org_id 		IN 	NUMBER,
 p_certification_id 	IN 	NUMBER
);

PROCEDURE POPULATE_SUMMARY
(p_certification_id 	IN 	VARCHAR2
);

PROCEDURE POPULATE_ALL_CERT_SUMMARY
(x_errbuf 		OUT 	NOCOPY VARCHAR2,
 x_retcode 		OUT 	NOCOPY NUMBER,
 p_certification_id     IN    	NUMBER
);

PROCEDURE  POPULATE_CERT_GENERAL_SUM
(p_certification_id     IN    	NUMBER,
 p_start_date		IN  	DATE
);

/***comment out since amw.d ***************
PROCEDURE POPULATE_ALL_CERT_GENERAL_SUM
(errbuf       		OUT NOCOPY      VARCHAR2,
 retcode      		OUT NOCOPY      VARCHAR2,
 p_certification_id	IN	 	NUMBER
);
******************/

PROCEDURE Populate_All_Fin_Proc_Eval_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id  IN       NUMBER
);

/***comment out since amw.d ***************
PROCEDURE Populate_All_Fin_Org_Eval_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id  IN       NUMBER
);
******************/
PROCEDURE Populate_Fin_Stmt_Cert_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id  IN       NUMBER
);

----------- Begining of the block of code added by Krishnan --------------------------------
/***comment out since amw.d
PROCEDURE build_amw_fin_cert_eval_sum(errbuf OUT NOCOPY  VARCHAR2,retcode OUT NOCOPY VARCHAR2, P_CERTIFICATION_ID in number);
***/

PROCEDURE reset_amw_fin_cert_eval_sum(p_certification_id in number) ;



Procedure  compute_values_for_eval_sum(P_CERTIFICATION_ID IN NUMBER,
     P_FINANCIAL_STATEMENT_ID in number, P_STATEMENT_GROUP_ID in number,
      --P_PARENT_FIN_ITEM_ID  NUMBER,
      P_ACCOUNT_ID in NUMBER, P_ACCOUNT_GROUP_ID in number, P_FINANCIAL_ITEM_ID in number,
      P_OBJECT_TYPE in varchar2           ,          P_PROC_PENDING_CERTIFICATION out NOCOPY  number,
      P_TOTAL_NUMBER_OF_PROCESSES  out NOCOPY  number, P_PROC_CERTIFIED_WITH_ISSUES out NOCOPY  number,
      P_PROC_VERIFIED              out NOCOPY  number, P_org_with_ineffective_ctrls  out NOCOPY  number,
      P_org_certified              out NOCOPY  number, P_proc_with_ineffective_ctrls  out NOCOPY  number,
      P_unmitigated_risks          out NOCOPY  number, P_risks_verified             out NOCOPY  number,
      P_ineffective_controls       out NOCOPY  number, P_controls_verified          out NOCOPY  number,
      P_open_issues                out NOCOPY  number, P_PRO_PENDING_CERT_PRCNT out NOCOPY  number,
      P_PROCESSES_WITH_ISSUES_PRCNT out NOCOPY  number, P_ORG_WITH_INEFF_CTRLS_PRCNT out NOCOPY  number,
      P_PROC_WITH_INEFF_CTRLS_PRCNT out NOCOPY  number, P_UNMITIGATED_RISKS_PRCNT out NOCOPY  number,
      P_INEFFECTIVE_CONTROLS_PRCNT out NOCOPY  number, P_START_DATE  IN DATE ,
      P_END_DATE  IN  DATE, P_PROCS_FOR_CERT_DONE out NOCOPY  NUMBER, p_org_evaluated out NOCOPY  NUMBER);



procedure insert_fin_cert_eval_sum(
 X_FIN_CERTIFICATION_ID                       IN         NUMBER,
 X_FINANCIAL_STATEMENT_ID                     IN         NUMBER,
 X_FINANCIAL_ITEM_ID                          IN         NUMBER,
 X_ACCOUNT_GROUP_ID                           IN         NUMBER,
 X_NATURAL_ACCOUNT_ID                         IN         NUMBER,
 X_OBJECT_TYPE                                IN         VARCHAR,
 X_PROC_PENDING_CERTIFICATION                 IN         NUMBER,
 X_TOTAL_NUMBER_OF_PROCESSES                  IN         NUMBER,
 X_PROC_CERTIFIED_WITH_ISSUES                 IN         NUMBER,
 X_PROCS_FOR_CERT_DONE                        IN         NUMBER,
 x_proc_evaluated                             IN         NUMBER,
 X_ORG_WITH_INEFFECTIVE_CTRLS                 IN         NUMBER,
-- X_ORG_CERTIFIED                              IN         NUMBER,
 x_orgs_FOR_CERT_DONE                         IN         NUMBER,
 x_orgs_evaluated                             IN         NUMBER,
 X_PROC_WITH_INEFFECTIVE_CTRLS                IN         NUMBER,
 X_UNMITIGATED_RISKS                          IN         NUMBER,
 X_RISKS_VERIFIED                             IN         NUMBER,
 X_INEFFECTIVE_CONTROLS                       IN         NUMBER,
 X_CONTROLS_VERIFIED                          IN         NUMBER,
 X_OPEN_ISSUES                                IN         NUMBER,
 X_PRO_PENDING_CERT_PRCNT                     IN         NUMBER,
 X_PROCESSES_WITH_ISSUES_PRCNT                IN         NUMBER,
 X_ORG_WITH_INEFF_CTRLS_PRCNT                 IN         NUMBER,
 X_PROC_WITH_INEFF_CTRLS_PRCNT                IN         NUMBER,
 X_UNMITIGATED_RISKS_PRCNT                    IN         NUMBER,
 X_INEFFECTIVE_CTRLS_PRCNT                    IN         NUMBER,
 X_OBJ_CONTEXT                                IN         NUMBER,
 X_CREATED_BY                                 IN         NUMBER,
 X_CREATION_DATE                              IN         DATE,
 X_LAST_UPDATED_BY                            IN         NUMBER,
 X_LAST_UPDATE_DATE                           IN         DATE,
 X_LAST_UPDATE_LOGIN                          IN         NUMBER,
 X_SECURITY_GROUP_ID                          IN         NUMBER,
 X_OBJECT_VERSION_NUMBER                      IN         NUMBER
)

;



Procedure GetTotalProcesses_for_account(P_NATURAL_ACCOUNT_ID in number, P_account_group_id IN NUMBER, P_TOTAL_NUMBER_OF_PROCESSES OUT NOCOPY number);

Procedure GetGLPeriodfor_FinCertEvalSum(P_Certification_ID in number, P_start_date out NOCOPY date, P_end_date out NOCOPY date);

Procedure CountProcsCertRecorded_Accnts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id IN NUMBER, P_PROCS_IN_CERTIFICATION OUT NOCOPY  Number, p_start_date in date, p_end_date in date , p_fin_cert_id in number) ;

Procedure CountProcsEvaluated_Accnts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id IN NUMBER, P_PROCS_EVALUATED OUT NOCOPY  Number, p_start_date in date, p_end_date in date) ;

Procedure  CountOrgsEvaluated_accounts(P_NATURAL_ACCOUNT_ID in number, P_account_group_id IN NUMBER, P_org_evaluated OUT NOCOPY  Number,

p_start_date in date, p_end_date in date) ;



Procedure  CountProcswithIssues_Accounts(P_NATURAL_ACCOUNT_ID in number,  P_account_group_id IN NUMBER, P_PROC_CERTIFIED_WITH_ISSUES  OUT NOCOPY  Number, p_start_date in date, p_end_date in date, p_fin_cert_id in number)  ;

Procedure  CountOrgsIneffCtrl_Accounts(P_NATURAL_ACCOUNT_ID in number,  P_account_group_id IN NUMBER, P_org_with_ineffective_ctrls OUT NOCOPY  Number, p_start_date in date, p_end_date in date)  ;

Procedure  CountOrgswithIssues_Accounts(P_NATURAL_ACCOUNT_ID in number,  P_account_group_id IN NUMBER, P_org_cert_with_issues OUT NOCOPY  Number, p_start_date in date, p_end_date in date)  ;

Procedure  CountOrgsCertified_accounts(P_NATURAL_ACCOUNT_ID in number,  P_account_group_id IN NUMBER, P_org_certified OUT NOCOPY  Number, p_start_date in date, p_end_date in date)  ;

Procedure  CountProcsIneffCtrl_accounts(P_NATURAL_ACCOUNT_ID in number,  P_account_group_id IN NUMBER, P_proc_with_ineffective_ctrls OUT NOCOPY  Number, p_start_date in date, p_end_date in date)  ;

Procedure  CountIneffectiveCtrls_account(P_NATURAL_ACCOUNT_ID in number,  P_account_group_id IN NUMBER, p_ineffective_controls OUT NOCOPY  Number, p_start_date in date, p_end_date in date)  ;

Procedure  CountUnmittigatedRisk_account(P_NATURAL_ACCOUNT_ID in number,  P_account_group_id IN NUMBER, p_unmitigated_risks OUT NOCOPY  Number, p_start_date in date, p_end_date in date)  ;

Procedure  CountRisksVerified_account(P_NATURAL_ACCOUNT_ID in number,  P_account_group_id IN NUMBER, p_risks_verified OUT NOCOPY  Number, p_start_date in date, p_end_date in date) ;

Procedure  CountControlsVerified_account(P_NATURAL_ACCOUNT_ID in number,  P_account_group_id IN NUMBER, p_controls_verified OUT NOCOPY  Number, p_start_date in date, p_end_date in date)  ;

----------------------------------------- Financial Item Level Computation for Fin Item Tab -----------------------
Procedure GetTotalProcesses_for_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_TOTAL_NUMBER_OF_PROCESSES OUT NOCOPY Number
                                        ) ;


Procedure CountProcsCertRecorded_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_PROCS_IN_CERTIFICATION OUT NOCOPY Number
                                        , p_start_date in DATE  , p_end_date in DATE, p_fin_cert_id in number) ;

Procedure  CountProcsEvaluated_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_PROCS_EVALUATED OUT NOCOPY Number
                                        , p_start_date in DATE  , p_end_date in DATE) ;

Procedure   CountProcswithIssues_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_PROC_CERTIFIED_WITH_ISSUES  OUT NOCOPY Number
                                        , p_start_date in DATE  , p_end_date in DATE, p_fin_cert_id in number) ;


Procedure   CountOrgsIneffCtrl_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_org_with_ineffective_ctrls  OUT NOCOPY number
                                        , p_start_date in DATE  , p_end_date in DATE) ;

Procedure   CountOrgsEvaluated_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number ,   P_org_evaluated  OUT NOCOPY number
                                        , p_start_date in DATE  , p_end_date in DATE) ;

Procedure   CountOrgsCertified_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number ,    P_org_certified OUT NOCOPY number
                                        , p_start_date in DATE  , p_end_date in DATE) ;


Procedure   CountProcsIneffCtrl_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number , P_proc_with_ineffective_ctrls OUT NOCOPY number
                                        , p_start_date in DATE  , p_end_date in DATE) ;


Procedure   CountIneffectiveCtrls_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number, p_ineffective_controls OUT NOCOPY number
                                      , p_start_date in DATE  , p_end_date in DATE) ;

Procedure CountUnmittigatedRisk_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                         P_FINANCIAL_ITEM_ID in number,  p_unmitigated_risks OUT NOCOPY number
                                       , p_start_date in DATE  , p_end_date in DATE) ;


Procedure  CountRisksVerified_finitem( P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                       P_FINANCIAL_ITEM_ID in number,  p_risks_verified OUT NOCOPY number
                                       , p_start_date in DATE  , p_end_date in DATE) ;


Procedure  CountControlsVerified_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                       P_FINANCIAL_ITEM_ID in number,   p_controls_verified OUT NOCOPY number
                                       , p_start_date in DATE  , p_end_date in DATE) ;

Procedure  CountOrgswithIssues_finitem(P_STATEMENT_GROUP_ID in number, P_FINANCIAL_STATEMENT_ID in number,
                                       P_FINANCIAL_ITEM_ID in number,   P_org_cert_with_issues OUT NOCOPY number
                                       , p_start_date in DATE  , p_end_date in DATE) ;



---------------- end of code added by Krishnan --------------------------------------------

END  AMW_FINSTMT_CERT_PVT;

 

/
