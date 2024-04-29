--------------------------------------------------------
--  DDL for Package PA_CC_IDENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_IDENT" 
--  $Header: PACCINTS.pls 120.1 2005/08/10 14:25:06 eyefimov noship $       |
AUTHID CURRENT_USER AS
  ExpOrganizationIdTab       PA_PLSQL_DATATYPES.IdTabTyp;
  ExpOrgIdTab                PA_PLSQL_DATATYPES.IdTabTyp;
  ProjectIdTab               PA_PLSQL_DATATYPES.IdTabTyp;
  TaskIdTab                  PA_PLSQL_DATATYPES.IdTabTyp;
  ExpItemDateTab             PA_PLSQL_DATATYPES.DateTabTyp;
  ExpItemIdTab               PA_PLSQL_DATATYPES.IdTabTyp;
  ExpTypeTab                 PA_PLSQL_DATATYPES.Char30TabTyp;
  SysLinkTab                 PA_PLSQL_DATATYPES.Char30TabTyp;
  PersonIdTab                PA_PLSQL_DATATYPES.IdTabTyp;
  PrjOrganizationIdTab       PA_PLSQL_DATATYPES.IdTabTyp;
  PrjorgIdTab                PA_PLSQL_DATATYPES.IdTabTyp;
  TransSourceTab             PA_PLSQL_DATATYPES.Char30TabTyp;
  NLROrganizationIdTab       PA_PLSQL_DATATYPES.IdTabTyp;
  PrvdrLEIdTab               PA_PLSQL_DATATYPES.IdTabTyp;
  RecvrLEIdTab               PA_PLSQL_DATATYPES.IdTabTyp;
  CrossChargeCodeTab         PA_PLSQL_DATATYPES.Char1TabTyp;
  CrossChargeTypeTab         PA_PLSQL_DATATYPES.Char3TabTyp;
  PrvdrOrganizationIdTab     PA_PLSQL_DATATYPES.IdTabTyp;
  RecvrOrganizationIdTab     PA_PLSQL_DATATYPES.IdTabTyp;
  PrvdrOrgIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
  RecvrOrgIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
  ErrorStageTab              PA_PLSQL_DATATYPES.Char150TabTyp;
  ErrorCodeTab               PA_PLSQL_DATATYPES.Char150TabTyp;
  AcctRawCostTab             PA_PLSQL_DATATYPES.NewAmtTabTyp;
  --
  -- AcctRateDateTab is supposed to be of datatype data. But due
  -- to bug# 951161 currently we are createing this table with
  -- datatype varchar2.
  --
  AcctRateDateTab            PA_PLSQL_DATATYPES.Char30TabTyp;
  AcctRateTypeTab            PA_PLSQL_DATATYPES.Char30TabTyp;
  AcctRateTab                PA_PLSQL_DATATYPES.NewAmtTabTyp;
  ProjRawCostTab             PA_PLSQL_DATATYPES.NewAmtTabTyp;
  --
  -- ProjRateDateTab is supposed to be of datatype data. But due
  -- to bug# 951161 currently we are createing this table with
  -- datatype varchar2.
  --
  ProjRateDateTab            PA_PLSQL_DATATYPES.Char30TabTyp;
  ProjRateTypeTab            PA_PLSQL_DATATYPES.Char30TabTyp;
  ProjRateTab                PA_PLSQL_DATATYPES.NewAmtTabTyp;
/** EPP **/
  ProjFuncRawCostTab             PA_PLSQL_DATATYPES.NewAmtTabTyp;
  ProjFuncRateDateTab            PA_PLSQL_DATATYPES.Char30TabTyp;
  ProjFuncRateTypeTab            PA_PLSQL_DATATYPES.Char30TabTyp;
  ProjFuncRateTab                PA_PLSQL_DATATYPES.NewAmtTabTyp;
/** EPP **/
--  StageTab                   PA_PLSQL_DATATYPES.NewAmtTabTyp;
  DenomCurrCodeTab           PA_PLSQL_DATATYPES.Char15TabTyp;
  StatusTab                  PA_PLSQL_DATATYPES.Char30TabTyp;


PROCEDURE PA_CC_IDENTIFY_TXN_FI(
          P_ExpOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpOrgidTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ProjectIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TaskIdTab                IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemDateTab           IN  PA_PLSQL_DATATYPES.DateTabTyp,
          P_ExpItemIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PersonIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpTypeTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_SysLinkTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_PrjOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrjOrgIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TransSourceTab           IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_NLROrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrvdrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          /* Added nocopy for 2672653 */
          X_StatusTab                IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          X_CrossChargeTypeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char3TabTyp,
          X_CrossChargeCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_PrvdrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrgIdTab            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_PrvdrOrgIdTab            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER);

PROCEDURE PA_CC_IDENTIFY_TXN_ADJ (
          P_ExpOrganizationId    IN  NUMBER,
          P_ExpOrgid             IN  NUMBER,
          P_ProjectId            IN  NUMBER,
          P_TaskId               IN  NUMBER,
          P_ExpItemDate          IN  DATE,
          P_ExpItemId            IN  NUMBER,
          P_ExpType              IN  VARCHAR2,
          P_PersonId           IN  NUMBER,
          P_SysLink              IN  VARCHAR2,
          P_PrjOrganizationId    IN  NUMBER,
          P_PrjOrgId             IN  NUMBER,
          P_TransSource          IN  VARCHAR2,
          P_NLROrganizationId    IN  NUMBER,
          P_PrvdrLEId            IN  NUMBER,
          P_RecvrLEId            IN  NUMBER,
          X_Status               IN OUT NOCOPY VARCHAR2,
          X_CrossChargeType      IN OUT NOCOPY VARCHAR2,
          X_CrossChargeCode      IN OUT NOCOPY VARCHAR2,
          X_PrvdrOrganizationId  IN OUT NOCOPY NUMBER,
          X_RecvrOrganizationId  IN OUT NOCOPY NUMBER,
          X_RecvrOrgId           IN OUT NOCOPY NUMBER,
          X_Error_Stage          OUT NOCOPY VARCHAR2,
          X_Error_Code           OUT NOCOPY NUMBER,
  	      /* Added calling module for 3234973 */
	      X_Calling_Module       IN VARCHAR2 DEFAULT 'TRANSACTION') ;

PROCEDURE PA_CC_IDENTIFY_TXN(
          P_ExpOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpOrgidTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ProjectIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TaskIdTab                IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemDateTab           IN  PA_PLSQL_DATATYPES.DateTabTyp,
          P_ExpItemIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PersonIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpTypeTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_SysLinkTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_PrjOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrjOrgIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TransSourceTab           IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_NLROrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrvdrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          /* Added nocopy for 2672653 */
          X_StatusTab                IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          X_CrossChargeTypeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char3TabTyp,
          X_CrossChargeCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_PrvdrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrgIdTab            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER,
	      /* Added calling module for 3234973 */
	      X_Calling_Module           IN VARCHAR2 DEFAULT 'TRANSACTION') ;

PROCEDURE PA_CC_GET_PRVDR_RECVR_ORGS (
          P_ExpOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpOrgidTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TaskIdTab                IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_SysLinkTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_ProjectIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_NLROrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemDateTab           IN  PA_PLSQL_DATATYPES.DateTabTyp,
          P_ExpTypeTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_PrjOrganizationIdTab     IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrjOrgIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          /* Added nocopy for 2672653 */
          X_StatusTab                IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          X_PrvdrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrganizationIdTab   IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_RecvrOrgIdTab            IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
          X_CCProcessIOCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_CCProcessIUCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_CCPrjFlagTab             IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER,
  	      /* Added calling module for 3234973 */
	      X_Calling_Module           IN VARCHAR2 DEFAULT 'TRANSACTION');

PROCEDURE PA_CC_GET_CROSS_CHARGE_TYPE (
          P_PrvdrOrganizationIdTab   IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrOrganizationIdTab   IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ProjectIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TaskIdTab                IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_SysLinkTab               IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_ExpItemIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PersonIdTab              IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_ExpItemDateTab           IN  PA_PLSQL_DATATYPES.DateTabTyp,
          P_PrvdrOrgIdTab            IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrOrgIdTab            IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_PrvdrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_RecvrLEIdTab             IN  PA_PLSQL_DATATYPES.IdTabTyp,
          P_TransSourceTab           IN  PA_PLSQL_DATATYPES.Char30TabTyp,
          P_CCProcessIOCodeTab       IN  PA_PLSQL_DATATYPES.Char1TabTyp,
          P_CCProcessIUCodeTab       IN  PA_PLSQL_DATATYPES.Char1TabTyp,
          P_CCPrjFlagTab             IN  PA_PLSQL_DATATYPES.Char1TabTyp,
          P_calling_mode             IN  VARCHAR2 default 'TRANSACTION',
          /* Added nocopy for 2672653 */
          X_StatusTab                IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          X_CrossChargeTypeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char3TabTyp,
          X_CrossChargeCodeTab       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
          X_Error_Stage              OUT NOCOPY VARCHAR2,
          X_Error_Code               OUT NOCOPY NUMBER);

  FUNCTION  GetLegalEntity( p_org_id  IN NUMBER ) RETURN NUMBER;
  --pragma RESTRICT_REFERENCES ( GetLegalEntity, WNDS, WNPS);


END PA_CC_IDENT;

 

/
