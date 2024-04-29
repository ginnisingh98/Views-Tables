--------------------------------------------------------
--  DDL for Package AMW_FINSTMT_CERT_BES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_FINSTMT_CERT_BES_PKG" AUTHID CURRENT_USER AS
/* $Header: amwfbuss.pls 120.2.12000000.2 2007/03/12 15:34:24 dliao ship $ */


G_REFRESH_FLAG VARCHAR2(1) := 'N';

/**05.25.2006 npanandi: bug 5142819 test***/
G_ORG_ERROR varchar2(1) := 'N';

TYPE certification_array is TABLE of NUMBER INDEX by pls_integer;
m_certification_list  certification_array;


procedure DELETE_ROWS
( x_fin_certification_id    IN NUMBER,
 x_table_name IN VARCHAR2 );

FUNCTION Populate_Fin_Stmt_Cert_Sum
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;

FUNCTION Update_Fin_Stmt_Cert_Sum
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;

FUNCTION Evaluation_Create
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;

FUNCTION Evaluation_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;


PROCEDURE Evaluation_Update_Handler(
   p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_opinion_log_id  IN       NUMBER,
     x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Certification_Update_Handler(
   p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_opinion_log_id  IN       NUMBER,
     x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
);

FUNCTION Certification_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;

PROCEDURE Master_Fin_Proc_Eval_Sum(
 p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
p_start_date	IN DATE := null,
p_mode	IN VARCHAR2 := 'NEW',
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_All_Fin_Proc_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Refresh_All_Fin_Proc_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

/***
PROCEDURE Populate_All_Fin_Risk_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_All_Fin_Ctrl_Ass_Sum(
 p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_All_Fin_AP_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);
***/

PROCEDURE Populate_All_Fin_Org_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);



PROCEDURE build_amw_fin_cert_eval_sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE compute_values_for_eval_sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id IN NUMBER,
p_financial_statement_id IN NUMBER ,
p_statement_group_id IN NUMBER ,
p_financial_item_id IN NUMBER,
p_account_group_id IN NUMBER,
p_account_id   IN NUMBER,
p_object_type IN VARCHAR2,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE  Populate_Fin_Org_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id          IN      NUMBER,
p_start_date                IN      DATE,
p_end_date			IN      DATE,
p_organization_id		IN 	NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE  Populate_Fin_Process_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id          IN      NUMBER,
p_start_date                IN      DATE,
p_end_date                  IN      DATE,
p_process_org_rev_id	IN   	NUMBER,
p_process_id   		IN	NUMBER,
p_revision_number		IN	NUMBER,
p_organization_id		IN 	NUMBER,
p_account_process_flag      IN      VARCHAR2,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_Fin_Risk_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_Fin_Risk_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_Fin_Ctrl_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_Fin_Ctrl_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_Fin_AP_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_Fin_AP_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE POPULATE_PROC_HIERARCHY(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
P_CERTIFICATION_ID IN NUMBER,
P_PROCESS_ID IN NUMBER,
P_ORGANIZATION_ID IN NUMBER,
p_account_process_flag IN VARCHAR2,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE INSERT_FIN_CERT_SCOPE(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE INSERT_FIN_CTRL(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE INSERT_FIN_RISK(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

Procedure GetGLPeriodfor_FinCertEvalSum
(P_Certification_ID in number,
P_start_date out NOCOPY  date,
P_end_date out NOCOPY  date
);

PROCEDURE Initialize
(P_Certification_ID in number
);


--Get ratio for financial item and account
FUNCTION Get_Ratio_Fin_Cert
( P_CERTIFICATION_ID IN NUMBER,
P_FINANCIAL_STATEMENT_ID IN NUMBER,
P_STATEMENT_GROUP_ID IN NUMBER ,
P_ACCOUNT_ID      IN NUMBER,
P_FINANCIAL_ITEM_ID IN NUMBER,
P_OBJECT_TYPE IN VARCHAR2,
P_STMT IN VARCHAR2) RETURN NUMBER;

/*
PROCEDURE Get_Fin_Evaluation
( P_CERTIFICATION_ID IN NUMBER,
P_FINANCIAL_ITEM_ID  IN NUMBER,
P_ACCOUNT_ID  	     IN NUMBER,
P_OBJECT_TYPE 	     IN VARCHAR2,
X_FIN_EVALUATION     OUT  NOCOPY NUMBER
);*/

procedure insert_fin_cert_eval_sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
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
-- X_ORG_CERTIFIED                            IN         NUMBER,
 x_orgs_FOR_CERT_DONE                         IN         NUMBER,
 x_orgs_evaluated                             IN         NUMBER,
 x_total_orgs			 IN         NUMBER,
 X_PROC_WITH_INEFFECTIVE_CTRLS                IN         NUMBER,
 X_UNMITIGATED_RISKS                          IN         NUMBER,
 X_RISKS_VERIFIED                             IN         NUMBER,
 X_TOTAL_RISKS			 IN         NUMBER,
 X_INEFFECTIVE_CONTROLS                       IN         NUMBER,
 X_CONTROLS_VERIFIED                          IN         NUMBER,
 X_TOTAL_CONTROLS			IN         NUMBER,
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
 X_OBJECT_VERSION_NUMBER                      IN         NUMBER,
 x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);


FUNCTION GetTotalProcesses
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;


FUNCTION Get_Proc_Certified_Done
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_Proc_Verified
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_Proc_Verified_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_PROC_CERT_WITH_ISSUES
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;


FUNCTION Get_ORG_WITH_INEFF_CTRLS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_ORG_EVALUATED
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_ORG_EVALUATED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_ORG_CERTIFIED
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_TOTAL_ORGS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_PROC_WITH_INEFF_CTRLS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 ) RETURN Number;

FUNCTION Get_INEFFECTIVE_CONTROLS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2)RETURN Number;

FUNCTION Get_UNMITIGATED_RISKS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 )RETURN Number;

FUNCTION Get_RISKS_VERIFIED
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_RISKS_VERIFIED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_Total_RISKS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 ) RETURN Number;

FUNCTION Get_CONTROLS_VERIFIED
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 )RETURN Number;

FUNCTION Get_CONTROLS_VERIFIED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 )RETURN Number;

FUNCTION Get_TOTAL_CONTROLS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 ) RETURN Number;

------followings are the procedure for dashboard population
/**************
PROCEDURE Populate_All_Cert_General_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);
*************/

PROCEDURE  Populate_Cert_General_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id          IN    	NUMBER,
p_start_date		IN  	DATE,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE  Get_global_proc_not_certified
(
    p_certification_id          IN    	NUMBER,
    x_global_proc_not_certified OUT NOCOPY Number
);

PROCEDURE  Get_global_proc_with_issue
(
    p_certification_id          IN    	NUMBER,
    x_global_proc_with_issue OUT NOCOPY Number
);

PROCEDURE  Get_local_proc_not_certified
(
    p_certification_id          IN    	NUMBER,
    x_local_proc_not_certified OUT NOCOPY Number
);
PROCEDURE  Get_local_proc_with_issue
(
    p_certification_id          IN    	NUMBER,
    x_local_proc_with_issue OUT NOCOPY Number
);

PROCEDURE  Get_global_proc_ineff_ctrl
(
    p_certification_id          IN    	NUMBER,
    x_global_proc_ineff_ctrl OUT NOCOPY Number
);
PROCEDURE  Get_local_proc_ineff_ctrl
(
    p_certification_id          IN    	NUMBER,
    x_local_proc_ineff_ctrl OUT NOCOPY Number
);
PROCEDURE  Get_unmitigated_risks
(
    p_certification_id          IN    	NUMBER,
    x_unmitigated_risks OUT NOCOPY Number
);


PROCEDURE  Get_ineffective_controls
(
    p_certification_id          IN    	NUMBER,
    x_ineffective_controls	 OUT NOCOPY Number
);
PROCEDURE  Get_orgs_pending_in_scope
(
    p_certification_id          IN    	NUMBER,
    x_orgs_pending_in_scope OUT NOCOPY Number
);


PROCEDURE  Is_Eval_Change
(
    old_opinion_log_id          IN    	NUMBER,
    new_opinion_log_id          IN    	NUMBER,
    x_change_flag	    OUT NOCOPY  VARCHAR2
);

PROCEDURE RISK_EVALUATION_HANDLER(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_risk_id 		IN 	NUMBER,
p_org_id 		IN 	NUMBER,
p_process_id 		IN 	NUMBER,
p_opinion_log_id 	IN	NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE CONTROL_EVALUATION_HANDLER(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_ctrl_id 		IN 	NUMBER,
p_org_id 		IN 	NUMBER,
p_opinion_log_id 	IN	NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE ORGANIZATION_CHANGE_HANDLER(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_org_id 		IN 	NUMBER,
p_opinion_log_id 	IN	NUMBER,
p_action 		IN 	VARCHAR2,
 x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE PROCESS_CHANGE_HANDLER(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_org_id 		IN 	NUMBER,
p_process_id 		IN 	NUMBER,
p_opinion_log_id 	IN	NUMBER,
p_action 		IN 	VARCHAR2,
 x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE reset_amw_fin_cert_eval_sum(p_certification_id in number) ;

PROCEDURE reset_amw_fin_proc_eval_sum(p_certification_id in number);

PROCEDURE reset_amw_fin_org_eval_sum(p_certification_id in number);

PROCEDURE reset_amw_cert_dashboard_sum(p_certification_id in number);

PROCEDURE reset_fin_all(p_certification_id in number);

END AMW_FINSTMT_CERT_BES_PKG;

 

/
