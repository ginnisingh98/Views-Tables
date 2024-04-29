--------------------------------------------------------
--  DDL for Package PA_EVENT_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EVENT_CORE" AUTHID CURRENT_USER AS
/* $Header: PAEVAPCS.pls 120.2 2007/02/07 10:42:17 rgandhi ship $ */
util_excp  exception;
FUNCTION CHECK_VALID_PROJECT(
   P_project_num     IN   VARCHAR2
  ,P_project_id     OUT   NOCOPY NUMBER )  --File.Sql.39 bug 4440895
  RETURN  VARCHAR2;

  FUNCTION CHECK_FUNDING(
 P_project_id            IN   NUMBER
,P_TASK_ID              IN   NUMBER)
RETURN  VARCHAR2;

FUNCTION  CHECK_VALID_TASK(
  P_project_id         IN    NUMBER
 ,P_task_num           IN    VARCHAR2
 ,P_task_id            OUT   NOCOPY NUMBER)  --File.Sql.39 bug 4440895
 RETURN  VARCHAR2 ;

 FUNCTION CHECK_VALID_EVENT_NUM(
 P_project_id      IN   NUMBER
,P_task_id         IN   NUMBER
,P_event_num       IN   NUMBER)
RETURN  VARCHAR2 ;

FUNCTION CHECK_VALID_EVENT_TYPE(
  P_event_type	                     IN	    VARCHAR2
 ,P_context                          IN     VARCHAR2
 ,P_event_type_classification        OUT    NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
 RETURN  VARCHAR2 ;

FUNCTION CHECK_VALID_EVENT_ORG(
  P_event_org_name      IN   VARCHAR2
 ,P_event_org_id        OUT  NOCOPY NUMBER)  --File.Sql.39 bug 4440895
 RETURN  VARCHAR2 ;

FUNCTION CHECK_VALID_CURR(
 P_bill_trans_curr	      IN	 VARCHAR2)
 RETURN VARCHAR2 ;

FUNCTION CHECK_VALID_FUND_RATE_TYPE(
 P_fund_rate_type	 IN	 VARCHAR2,
 x_fund_rate_type	 OUT	 NOCOPY VARCHAR2 -- Added for bug 3009307 --File.Sql.39 bug 4440895
)
 RETURN VARCHAR2 ;

 FUNCTION CHECK_VALID_PROJ_RATE_TYPE(
  P_proj_rate_type	         IN	 VARCHAR2
 ,P_bill_trans_currency_code	 IN	 VARCHAR2
 ,P_project_currency_code	 IN	 VARCHAR2
 ,P_proj_level_rt_dt_cod	 IN	 VARCHAR2
 ,P_project_rate_date	         IN	 DATE
 ,P_event_date	                 IN	 DATE
 ,x_proj_rate_type	         OUT	 NOCOPY VARCHAR2 -- Added for bug 3009307 --File.Sql.39 bug 4440895
)
 RETURN VARCHAR2;

 FUNCTION CHECK_VALID_PFC_RATE_TYPE(
  P_pfc_rate_type	         IN	 VARCHAR2
 ,P_bill_trans_currency_code	 IN	 VARCHAR2
 ,P_proj_func_currency_code	 IN	 VARCHAR2
 ,P_proj_level_func_rt_dt_cod	 IN	 VARCHAR2
 ,P_proj_func_rate_date	         IN	 DATE
 ,P_event_date	                 IN	 DATE
 ,x_pfc_rate_type	         OUT	 NOCOPY VARCHAR2 -- Added for bug 3009307 --File.Sql.39 bug 4440895
)
 RETURN VARCHAR2 ;

 FUNCTION CHECK_VALID_BILL_AMT(
 P_event_type_classification   IN  VARCHAR2
,P_bill_amt                    IN  NUMBER)
RETURN  VARCHAR2 ;

FUNCTION CHECK_VALID_REV_AMT(
 P_event_type_classification   IN  VARCHAR2
 ,P_rev_amt                   IN  NUMBER)
 RETURN  VARCHAR2;


FUNCTION CHECK_EVENT_PROCESSED(
 P_event_id        IN      NUMBER)
 RETURN VARCHAR2;

FUNCTION CHECK_VALID_INV_ORG(
P_inv_org_name	IN	VARCHAR2,
P_inv_org_id    OUT     NOCOPY NUMBER)  --File.Sql.39 bug 4440895
RETURN VARCHAR2;


FUNCTION  CHECK_WRITE_OFF_AMT(
 P_project_id           IN      NUMBER
,P_task_id              IN      NUMBER
,P_event_id             IN      NUMBER
,P_rev_amt              IN      NUMBER
,P_bill_trans_currency  IN      VARCHAR2
,P_proj_func_currency   IN      VARCHAR2
,P_proj_func_rate_type  IN      VARCHAR2
,P_proj_func_rate       IN      NUMBER
,P_proj_func_rate_date  IN      DATE
,P_event_date           IN      DATE )
RETURN VARCHAR2 ;

FUNCTION CHECK_VALID_INV_ITEM(
P_inv_item_id   IN      NUMBER) RETURN VARCHAR2;

-- Federal Uptake
FUNCTION  CHECK_VALID_AGREEMENT(
 P_project_id           IN      NUMBER
,P_task_id              IN      NUMBER
,P_agreement_number     IN      VARCHAR2
,P_agreement_type       IN      VARCHAR2
,P_customer_number      IN      VARCHAR2
,P_agreement_id         OUT     NOCOPY NUMBER) --Federal Uptake
RETURN VARCHAR2;

-- Federal Uptake
FUNCTION CHECK_VALID_EVENT_DATE(
 P_event_date           IN      DATE
,P_agreement_id         IN      NUMBER )
RETURN VARCHAR2;

END PA_EVENT_CORE;


/
