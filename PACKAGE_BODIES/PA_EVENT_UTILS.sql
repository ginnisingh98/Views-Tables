--------------------------------------------------------
--  DDL for Package Body PA_EVENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EVENT_UTILS" AS
/* $Header: PAEVAPUB.pls 120.3 2007/02/07 10:44:47 rgandhi ship $ */

-- ============================================================================
--
--Name:         CHECK_VALID_PROJECT
--Type:         function
--Description:  This function validates the project_number and returns the project_id.
--
--Called subprograms: PA_EVENT_CORE.CHECK_VALID_PROJECT
--
-- ============================================================================
FUNCTION CHECK_VALID_PROJECT
        (P_project_num  IN      VARCHAR2
        ,P_project_id   OUT     NOCOPY NUMBER) --File.Sql.39 bug 4440895
RETURN VARCHAR2
IS
BEGIN

RETURN PA_EVENT_CORE.CHECK_VALID_PROJECT(
                   P_project_num  =>P_project_num
                  ,P_project_id   =>p_project_id);

        --handling exceptions
        Exception
        When pa_event_core.util_excp then
                p_project_id := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_PROJECT->';
                Raise pa_event_pvt.pub_excp;

        When others then
                p_project_id := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_PROJECT->';
		Raise pa_event_pvt.pub_excp;

END CHECK_VALID_PROJECT;
-- ============================================================================
--
--Name:         CHECK_VALID_TASK
--Type:         function
--Description:  This function validates the task number and returns the task_id.
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_TASK
--
-- ============================================================================
FUNCTION CHECK_VALID_TASK
        (P_project_id   IN      NUMBER
        ,P_task_num     IN      VARCHAR2
        ,P_task_id      OUT     NOCOPY NUMBER) --File.Sql.39 bug 4440895
RETURN VARCHAR2
IS
BEGIN
RETURN  PA_EVENT_CORE.CHECK_VALID_TASK(
                      P_project_id => P_project_id
                     ,P_task_num   => P_task_num
                     ,P_task_id    => P_task_id    );

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                p_task_id := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_TASK->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
		then
                p_task_id := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_TASK->';
		Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_TASK;
-- ============================================================================
--
--Name:         CHECK_VALID_EVENT_TYPE
--Type:         function
--Description:  This function validates the user entered event_type
--		And returns the event_type_classification.
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_EVENT_TYPE
--
-- ============================================================================
FUNCTION CHECK_VALID_EVENT_TYPE
(P_event_type                   IN      VARCHAR2
,P_context                      IN      VARCHAR2
,X_event_type_classification    OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
RETURN VARCHAR2
IS
BEGIN
RETURN  PA_EVENT_CORE.CHECK_VALID_EVENT_TYPE(
                       P_event_type                   =>  P_event_type
                      ,P_context                      =>  P_context
                      ,P_event_type_classification    => X_event_type_classification);

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                x_event_type_classification := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_EVENT_TYPE->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                x_event_type_classification := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_EVENT_TYPE->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_EVENT_TYPE;
-- ============================================================================
--
--Name:         CHECK_VALID_EVENT_ORG
--Type:         function
--Description:  This function validates and
--		derive the organisation_id from organisation name.
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_EVENT_ORG
--
-- ============================================================================
FUNCTION CHECK_VALID_EVENT_ORG
(P_event_org_name       IN      VARCHAR2
,P_event_org_id         OUT     NOCOPY NUMBER) --File.Sql.39 bug 4440895
RETURN VARCHAR2
IS
BEGIN
 RETURN  PA_EVENT_CORE.CHECK_VALID_EVENT_ORG(
                         P_event_org_name => P_event_org_name
                        ,P_event_org_id   => P_event_org_id  );

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                p_event_org_id := NULL; -- NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_EVENT_ORG->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                p_event_org_id := NULL; -- NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_EVENT_ORG->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_EVENT_ORG;
-- ============================================================================
--
--Name:         CHECK_VALID_CURR
--Type:         function
--Description:  This function validates the currency fields if MCB is enabled.
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_CURR
--
-- ============================================================================
FUNCTION CHECK_VALID_CURR
(P_bill_trans_curr      IN      VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
 RETURN PA_EVENT_CORE.CHECK_VALID_CURR(
                        P_bill_trans_curr => P_bill_trans_curr);

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_CURR->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_CURR->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_CURR;
-- ============================================================================
--
--Name:         CHECK_VALID_FUND_RATE_TYPE
--Type:         function
--Description:  This function validates the currency fields if MCB is enabled.
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_FUND_RATE_TYPE
--
-- ============================================================================
FUNCTION CHECK_VALID_FUND_RATE_TYPE
(P_fund_rate_type       IN      VARCHAR2
,x_fund_rate_type       OUT     NOCOPY VARCHAR2 -- Added for bug 3009307 --File.Sql.39 bug 4440895
)
RETURN VARCHAR2
IS
BEGIN
 RETURN PA_EVENT_CORE.CHECK_VALID_FUND_RATE_TYPE(
                        P_fund_rate_type => P_fund_rate_type,
                        x_fund_rate_type => x_fund_rate_type); -- Added for bug 3009307

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                x_fund_rate_type := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_FUND_RATE_TYPE->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                x_fund_rate_type := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_FUND_RATE_TYPE->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_FUND_RATE_TYPE;

-- ============================================================================
--
--Name:         CHECK_VALID_PROJ_RATE_TYPE
--Type:         function
--Description:  This function validates the currency fields if MCB is enabled.
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_PROJ_RATE_TYPE
--
-- ============================================================================
FUNCTION CHECK_VALID_PROJ_RATE_TYPE
(P_proj_rate_type               IN      VARCHAR2
,P_bill_trans_currency_code     IN      VARCHAR2
,P_project_currency_code        IN      VARCHAR2
,P_proj_level_rt_dt_code        IN      VARCHAR2
,P_project_rate_date            IN      DATE
,P_event_date                   IN      DATE
,x_proj_rate_type               OUT     NOCOPY VARCHAR2 -- Added for bug 3009307  --File.Sql.39 bug 4440895
)
RETURN VARCHAR2
IS
BEGIN
 RETURN PA_EVENT_CORE.CHECK_VALID_PROJ_RATE_TYPE(
                          P_proj_rate_type            => P_proj_rate_type
                         ,P_bill_trans_currency_code  => P_bill_trans_currency_code
                         ,P_project_currency_code     => P_project_currency_code
                         ,P_proj_level_rt_dt_cod      => P_proj_level_rt_dt_code
                         ,P_project_rate_date         => P_project_rate_date
                         ,P_event_date                => P_event_date
                         ,x_proj_rate_type            => x_proj_rate_type -- Added for bug 3009307
                         );

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                x_proj_rate_type := NULL; -- NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_PROJ_RATE_TYPE->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                x_proj_rate_type := NULL; -- NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_PROJ_RATE_TYPE->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_PROJ_RATE_TYPE;
-- ============================================================================
--
--Name:         CHECK_VALID_PFC_RATE_TYPE
--Type:         function
--Description:  This function validates the currency fields if MCB is enabled.
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_PFC_RATE_TYPE
--
-- ============================================================================
FUNCTION CHECK_VALID_PFC_RATE_TYPE
(P_pfc_rate_type                IN      VARCHAR2
,P_bill_trans_currency_code     IN      VARCHAR2
,P_proj_func_currency_code      IN      VARCHAR2
,P_proj_level_func_rt_dt_code   IN      VARCHAR2
,P_projfunc_rate_date           IN      DATE
,P_event_date                   IN      DATE
,x_pfc_rate_type                OUT     NOCOPY VARCHAR2 -- Added for bug 3009307 --File.Sql.39 bug 4440895
)
RETURN VARCHAR2
IS
BEGIN
 RETURN PA_EVENT_CORE.CHECK_VALID_PFC_RATE_TYPE(
		 P_pfc_rate_type              =>P_pfc_rate_type
		,P_bill_trans_currency_code   =>P_bill_trans_currency_code
		,P_proj_func_currency_code    =>P_proj_func_currency_code
		,P_proj_level_func_rt_dt_cod  =>P_proj_level_func_rt_dt_code
		,P_proj_func_rate_date        =>P_projfunc_rate_date
		,P_event_date                 =>P_event_date
		,x_pfc_rate_type              =>x_pfc_rate_type -- Added for bug 3009307
                );

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                x_pfc_rate_type := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_PFC_RATE_TYPE->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                x_pfc_rate_type := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_PFC_RATE_TYPE->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_PFC_RATE_TYPE;

-- ============================================================================
--
--Name:         CHECK_VALID_REV_AMT
--Type:         function
--Description:  This function validates the revenue amount.
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_REV_AMT
--
-- ============================================================================
FUNCTION CHECK_VALID_REV_AMT
(P_event_type_classification   IN      VARCHAR2
,P_rev_amt      	       IN      NUMBER)
RETURN VARCHAR2
IS
BEGIN
 RETURN  PA_EVENT_CORE.CHECK_VALID_REV_AMT(
                         p_event_type_classification => P_event_type_classification
                        ,P_rev_amt                  => P_rev_amt                  );

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_REV_AMT->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_REV_AMT->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_REV_AMT;
-- ============================================================================
--
--Name:         CHECK_VALID_BILL_AMT
--Type:         function
--Description:  This function validates the bill amount.
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_BILL_AMT
--
-- ============================================================================
FUNCTION CHECK_VALID_BILL_AMT
(P_event_type_classification   IN      VARCHAR2
,P_bill_amt     	       IN      NUMBER)
RETURN VARCHAR2
IS
BEGIN
RETURN  PA_EVENT_CORE.CHECK_VALID_BILL_AMT(
                         P_event_type_classification  => P_event_type_classification
                        ,P_bill_amt                   => P_bill_amt                  );

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_BILL_AMT->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_BILL_AMT->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_BILL_AMT;
-- ============================================================================
--
--Name:         CHECK_VALID_EVENT_NUM
--Type:         function
--Description:  This function validates the event number.
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_EVENT_NUM
--
-- ============================================================================
FUNCTION CHECK_VALID_EVENT_NUM
(P_project_id   IN      NUMBER
,P_task_id      IN      NUMBER
,P_event_num    IN      NUMBER)
RETURN VARCHAR2
IS
BEGIN
RETURN PA_EVENT_CORE.CHECK_VALID_EVENT_NUM(
                      P_project_id    =>P_project_id
                     ,P_task_id       =>P_task_id
                     ,P_event_num     =>P_event_num);

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_EVENT_NUM->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_EVENT_NUM->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_EVENT_NUM;
-- ============================================================================
--
--Name:         CHECK_VALID_INV_ORG
--Type:         function
--Description:  This function validates the inventory organization name
--		should be valid and active
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_INV_ORG
--
-- ============================================================================
FUNCTION CHECK_VALID_INV_ORG
(P_inv_org_name IN      VARCHAR2
,P_inv_org_id   OUT     NOCOPY NUMBER) --File.Sql.39 bug 4440895
RETURN VARCHAR2
IS
BEGIN
RETURN PA_EVENT_CORE.CHECK_VALID_INV_ORG(
                         P_inv_org_name => P_inv_org_name
			,P_inv_org_id  => P_inv_org_id);

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                p_inv_org_id := NULL; -- NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_INV_ORG->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                p_inv_org_id := NULL; -- NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_INV_ORG->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_INV_ORG;
-- ============================================================================
--
--Name:         CHECK_VALID_INV_ITEM
--Type:         function
--Description:  This function validates the inventory item_id
--
--Called subprograms:PA_EVENT_CORE.CHECK_VALID_INV_ITEM
--
-- ============================================================================
FUNCTION CHECK_VALID_INV_ITEM
(P_inv_item_id  IN      NUMBER)
RETURN VARCHAR2
IS
BEGIN
RETURN PA_EVENT_CORE.CHECK_VALID_INV_ITEM(
                        P_inv_item_id =>P_inv_item_id );

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_INV_ITEM->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_INV_ITEM->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_VALID_INV_ITEM;
-- ============================================================================
--
--Name:         CHECK_EVENT_PROCESSED
--Type:         function
--Description:  This function calls core where it is validated whether has been
--		processed.
--
--Called subprograms:PA_EVENT_CORE.CHECK_EVENT_PROCESSED
--
-- ============================================================================
FUNCTION CHECK_EVENT_PROCESSED
(P_event_id             IN      NUMBER)
RETURN VARCHAR2
IS
BEGIN
 RETURN PA_EVENT_CORE.CHECK_EVENT_PROCESSED(
                        P_event_id  => P_event_id);

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_EVENT_PROCESSED->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_EVENT_PROCESSED->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_EVENT_PROCESSED;
-- ============================================================================
--
--Name:         CHECK_FUNDING
--Type:         function
--Description:  This function validates the funding provided.
--
--Called subprograms:PA_EVENT_CORE.CHECK_FUNDING
--
-- ============================================================================
FUNCTION CHECK_FUNDING
(P_project_id	IN	NUMBER
,P_task_id	IN	NUMBER)
RETURN VARCHAR2
IS
BEGIN
RETURN PA_EVENT_CORE.CHECK_FUNDING(
                    P_project_id => P_project_id
                   ,P_TASK_ID    =>P_TASK_ID   );

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_FUNDING->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_FUNDING->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_FUNDING;
-- ============================================================================
--
--Name:         CHECK_WRITE_OFF_AMT
--Type:         function
--Description:  This function validates the write-off amount.
--
--Called subprograms:PA_EVENT_CORE.CHECK_WRITE_OFF_AMT
--
-- ============================================================================
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
,P_event_date           IN      DATE ) RETURN VARCHAR2  IS

BEGIN
RETURN PA_EVENT_CORE.CHECK_WRITE_OFF_AMT(
                         P_project_id          =>P_project_id
                        ,P_task_id             =>P_task_id
                        ,P_event_id            =>P_event_id
                        ,P_rev_amt             =>P_rev_amt
                        ,P_bill_trans_currency =>P_bill_trans_currency
                        ,P_proj_func_currency  =>P_proj_func_currency
                        ,P_proj_func_rate_type =>P_proj_func_rate_type
                        ,P_proj_func_rate      =>P_proj_func_rate
                        ,P_proj_func_rate_date =>P_proj_func_rate_date
                        ,P_event_date          =>P_event_date          );

        --handling exceptions
Exception
        When pa_event_core.util_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_WRITE_OFF_AMT->';
		Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_WRITE_OFF_AMT->';
                Raise pa_event_utils.pvt_excp;--Raising exception to handled in private body.

END CHECK_WRITE_OFF_AMT;

-- ============================================================================
--   Federal Uptake
--Name:         CHECK_VALID_AGREEMENT
--Type:         function
--Description:  This function validates the agreement_number and returns the agreement_id.
--
--Called subprograms: PA_EVENT_CORE.CHECK_VALID_AGREEMENT
--
-- ============================================================================
FUNCTION CHECK_VALID_AGREEMENT (
 P_project_id           IN      NUMBER
,P_task_id              IN      NUMBER
,P_agreement_number     IN      VARCHAR2
,P_agreement_type       IN      VARCHAR2
,P_customer_number      IN      VARCHAR2
,P_agreement_id         OUT     NOCOPY NUMBER) --Federal Uptake
RETURN VARCHAR2
IS
BEGIN
RETURN PA_EVENT_CORE.CHECK_VALID_AGREEMENT(
			 P_project_id       =>  P_project_id
			,P_task_id          =>  P_task_id
			,P_agreement_number =>  P_agreement_number
			,P_agreement_type   =>  P_agreement_type
			,P_customer_number  =>  P_customer_number
			,P_agreement_id     =>  P_agreement_id );

        --handling exceptions
        Exception
        When pa_event_core.util_excp then
                p_agreement_id := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_AGREEMENT->';
                Raise pa_event_pvt.pub_excp;

        When others then
                p_agreement_id := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_AGREEMENT->';
                Raise pa_event_pvt.pub_excp;

END CHECK_VALID_AGREEMENT;


-- ============================================================================
--  Federal Uptake
--Name:         CHECK_VALID_EVENT_DATE
--Type:         function
--Description:  This function validates if the event date is between the
--              agreement start date and end date
--Called subprograms: PA_EVENT_CORE.CHECK_VALID_EVENT_DATE
--
-- ============================================================================
FUNCTION CHECK_VALID_EVENT_DATE(
 P_event_date           IN      DATE
,P_agreement_id         IN      NUMBER )
RETURN VARCHAR2
IS
BEGIN
RETURN PA_EVENT_CORE.CHECK_VALID_EVENT_DATE (
			 P_event_date      =>  P_event_date
			,P_agreement_id    =>  P_agreement_id);

        --handling exceptions
Exception
        When pa_event_core.util_excp then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_VALID_EVENT_DATE->';
                Raise pa_event_pvt.pub_excp;

        When others then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'UTILS->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_VALID_EVENT_DATE->';
                Raise pa_event_pvt.pub_excp;

END CHECK_VALID_EVENT_DATE;

END PA_EVENT_UTILS;

/
