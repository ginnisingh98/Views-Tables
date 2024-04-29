--------------------------------------------------------
--  DDL for Package Body PA_EVENT_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EVENT_CORE" AS
/* $Header: PAEVAPCB.pls 120.5.12010000.3 2009/05/26 10:51:27 nkapling ship $ */

/* The function returns y if
the given project is a valid project
else returns N*/

FUNCTION CHECK_VALID_PROJECT(
   P_project_num     IN   VARCHAR2
  ,P_project_id     OUT   NOCOPY NUMBER ) RETURN  VARCHAR2 IS --File.Sql.39 bug 4440895

 L_PROJECT_ID NUMBER ;

      CURSOR SEL_PROJ_ID
          IS
      SELECT   project_id
        FROM   pa_projects_basic_v
       WHERE   project_number=ltrim(rtrim(P_project_num))
         AND   project_type_class_code = 'CONTRACT'
         AND   template_flag <> 'Y'
         AND   pa_project_stus_utils.Is_Project_In_Purge_Status(project_status_code) <>'Y'
         AND   nvl(cc_prvdr_flag,'N') <> 'Y';

 BEGIN

            OPEN SEL_PROJ_ID;
           FETCH SEL_PROJ_ID INTO L_PROJECT_ID;
           CLOSE SEL_PROJ_ID;

                     IF L_PROJECT_ID IS NULL THEN
                          RETURN('N');
                     ELSE
                          P_PROJECT_ID :=L_PROJECT_ID;
                          RETURN('Y');
                    END IF;
 Exception
        When others then
          p_project_id := NULL; -- NOCOPY
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_PROJECT->';
        Raise util_excp;--Raising exception to handled in public body.

 END CHECK_VALID_PROJECT;
--------------------------------------------------------------------------------------------------------------

/*This function returns 'n' if  funding  is at task level but
  the event being inserted is at project level.it returns 'y' oterwise*/

FUNCTION CHECK_FUNDING(
 P_project_id            IN   NUMBER
,P_TASK_ID               IN   NUMBER) RETURN  VARCHAR2 IS

   l_funding_level VARCHAR2(1);

       CURSOR   funding_level
           IS
       SELECT   project_level_funding_flag
         FROM   PA_PROJECTS
        WHERE   project_id = P_project_id;

    BEGIN

          OPEN funding_level;
         FETCH funding_level INTO l_funding_level;
         CLOSE funding_level ;

               IF (nvl(l_funding_level,'Y')='N' and P_TASK_ID IS NULL) THEN
                    RETURN('N');
               ELSE
                    RETURN('Y');
               END IF;
 Exception
        When others then
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_FUNDING->';
        Raise util_excp;--Raising exception to handled in public body.

 END CHECK_FUNDING;
---------------------------------------------------------------------------------------------------------

/*it validates that the task is a top task if provided.it also
returns the task_id as an out parameter to be used by
subsequent functions*/

 FUNCTION  CHECK_VALID_TASK(
  P_project_id         IN    NUMBER
 ,P_task_num           IN    VARCHAR2
 ,P_task_id            OUT   NOCOPY NUMBER) RETURN  VARCHAR2 IS --File.Sql.39 bug 4440895

 l_task_id number;

       CURSOR  GET_TASK_ID
           IS
       SELECT  TASK_ID
         FROM  pa_tasks_top_v
        WHERE  project_id   =P_project_id
          AND  task_number  =ltrim(rtrim(P_task_num));

BEGIN

         IF P_task_num IS NOT NULL THEN  /*If task id is provided*/

                    OPEN get_task_id;
                   FETCH get_task_id INTO l_task_id;

                      IF get_task_id%FOUND THEN
                           CLOSE get_task_id;
                           P_task_id :=l_task_id;
                           RETURN ('Y');
                      ELSE
                           CLOSE get_task_id;
                           RETURN ('N');
                      END IF;/*End of GET_TASK_ID%FOUND*/

         ELSE

                    RETURN ('Y');  /*No task id is given,so no validation is required*/
         END IF;/*End of  P_task_num IS NOT NULL*/
Exception
        When others then
          p_task_id := NULL; --NOCOPY
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_TASK->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_TASK;
-----------------------------------------------------------------------------------------------------

/*Validates that the event number is unique for the
project in case of project level events .in case of task level
events the event number should be unique for the combination
of project and top task*/

FUNCTION CHECK_VALID_EVENT_NUM(
 P_project_id      IN   NUMBER
,P_task_id         IN   NUMBER
,P_event_num       IN   NUMBER) RETURN  VARCHAR2 IS

 l_event_num number;

       CURSOR get_proj_event_num IS
       SELECT event_num
         FROM pa_events
        WHERE project_id=P_project_id
          AND task_id IS NULL
          AND event_num=P_event_num;

       CURSOR get_task_event_num IS
       SELECT event_num
         FROM pa_events
        WHERE project_id=P_project_id
          AND task_id =P_task_id
          AND event_num=P_event_num;

BEGIN

        IF (P_EVENT_NUM <=0) THEN
               RETURN('N');
        END IF;

         IF P_task_id IS NULL THEN

                OPEN get_proj_event_num;
               FETCH get_proj_event_num into l_event_num;

                   IF get_proj_event_num%FOUND THEN
                       CLOSE get_proj_event_num;
                       RETURN('N');
                   ELSE
                       CLOSE get_proj_event_num;
                       RETURN('Y');
                   END IF;

         ELSE  /*P_task_id IS NOT NULL*/

                OPEN get_task_event_num;
               FETCH get_task_event_num into l_event_num;

                   IF get_task_event_num%found   THEN
                       CLOSE get_task_event_num;
                       RETURN('N');
                   ELSE
                       CLOSE get_task_event_num;
                       RETURN('Y');
                   END IF;

       END IF;/*End of P_task_id IS NULL*/
Exception
        When others then
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_EVENT_NUM->';
        Raise util_excp;--Raising exception to handled in public body.


END  CHECK_VALID_EVENT_NUM;
-------------------------------------------------------------------------------------------------

/*This function checks that
the event is of a valid event
type.it passes the event type
classification as an out parameter*/

FUNCTION  CHECK_VALID_EVENT_TYPE(
  P_event_type	                     IN	    VARCHAR2
 ,P_context                          IN     VARCHAR2
 ,P_event_type_classification        OUT    NOCOPY VARCHAR2)  RETURN  VARCHAR2 IS --File.Sql.39 bug 4440895

 l_event_type_classification PA_EVENT_TYPES.EVENT_TYPE_CLASSIFICATION %TYPE;

       CURSOR valid_event
           IS
       SELECT  event_type_classification
         FROM  pa_event_types_lov_v
        WHERE  event_type=P_event_type;

       CURSOR valid_delv_event
           IS
       SELECT  event_type_classification
         FROM  pa_event_types_lov_v
        WHERE  event_type=P_event_type
          AND  event_type_classification = 'MANUAL';

 BEGIN

       IF P_context = 'D' Then
           OPEN VALID_DELV_EVENT;
          FETCH VALID_DELV_EVENT INTO l_event_type_classification;

                  IF  VALID_DELV_EVENT%FOUND THEN
                      P_event_type_classification :=L_event_type_classification ;
                      CLOSE VALID_DELV_EVENT;
                      RETURN('Y');
                  ELSE
                      CLOSE VALID_DELV_EVENT;
                      RETURN('N');
                  END IF;
       ELSE
           OPEN VALID_EVENT;
          FETCH VALID_EVENT INTO l_event_type_classification;

                  IF  VALID_EVENT%FOUND THEN
                      P_event_type_classification :=L_event_type_classification ;
                      CLOSE VALID_EVENT;
                      RETURN('Y');
                  ELSE
                      CLOSE VALID_EVENT;
                      RETURN('N');
                  END IF;
       END IF;
Exception
        When others then
          p_event_type_classification := NULL; --NOCOPY
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_EVENT_TYPE->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_EVENT_TYPE;
---------------------------------------------------------------------------------------------------

/*It validates that the event organization
is an active and valid one*/

FUNCTION CHECK_VALID_EVENT_ORG(
  P_event_org_name      IN   VARCHAR2
 ,P_event_org_id        OUT  NOCOPY NUMBER) RETURN  VARCHAR2 IS --File.Sql.39 bug 4440895

  l_event_org_id   NUMBER;

  CURSOR valid_event_org IS
  SELECT organization_id
    FROM pa_organizations_event_v
   WHERE name=P_event_org_name
     AND TRUNC(SYSDATE) BETWEEN date_from AND nvl(date_to, TRUNC(SYSDATE));

BEGIN

       OPEN valid_event_org;
      FETCH valid_event_org INTO l_event_org_id;
      CLOSE valid_event_org;

          IF l_event_org_id IS NULL THEN
              RETURN('N');
          ELSE
              P_event_org_id:=l_event_org_id;
              RETURN('Y');
          END IF;
Exception
        When others then
            p_event_org_id := NULL; --NOCOPY
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_EVENT_ORG->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_EVENT_ORG;
-------------------------------------------------------------------------------------------------------

FUNCTION CHECK_VALID_CURR(
 P_bill_trans_curr        IN    VARCHAR2) RETURN  VARCHAR2 IS

l_valid_bill_trans_code Pa_events.bill_trans_currency_code%TYPE;

   CURSOR  VALID_CURR
       IS
   SELECT 1
     FROM fnd_currencies /* Changed vl into base for bug 4403197*/
    WHERE  nvl(enabled_flag, 'Y') = 'Y'
      AND    trunc(sysdate)
             BETWEEN  DECODE(TRUNC(start_date_active), null, TRUNC(SYSDATE), trunc(start_date_active))
                 AND decode (trunc(end_date_active), null, trunc(sysdate), trunc(end_date_active))
      AND  currency_code=p_bill_trans_curr;

BEGIN

         OPEN VALID_CURR;
        FETCH VALID_CURR INTO l_valid_bill_trans_code;

               IF VALID_CURR%FOUND THEN
                    CLOSE VALID_CURR;
                    RETURN('Y');
               ELSE
                    CLOSE VALID_CURR;
                    RETURN('N');
               END IF;
Exception
        When others then
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_CURR->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_CURR;
-------------------------------------------------------------------------------------------------------------

 FUNCTION CHECK_VALID_FUND_RATE_TYPE(
 P_fund_rate_type	 IN	 VARCHAR2,
 x_fund_rate_type	 OUT	 NOCOPY VARCHAR2 -- Added for bug 3009307 --File.Sql.39 bug 4440895
) RETURN VARCHAR2 IS

 -- dummy number; Commented  for bug 3009307
    CURSOR FUND_RATE_TYPE
        IS
   -- Commented  for bug 3009307 SELECT 1
    SELECT conversion_type  -- Added  for bug 3009307
      FROM pa_conversion_types_v
     WHERE user_conversion_type = P_fund_rate_type;

    BEGIN

        OPEN FUND_RATE_TYPE;
       --  Commented for bug 3009307 FETCH FUND_RATE_TYPE INTO dummy;
       FETCH fund_rate_type
       INTO x_fund_rate_type;

              IF FUND_RATE_TYPE%FOUND THEN
                  CLOSE FUND_RATE_TYPE;
                  RETURN('Y');
              ELSE
                  CLOSE FUND_RATE_TYPE;
                  RETURN('N');
              END IF;
Exception
        When others then
                  x_fund_rate_type := NULL; --NOCOPY
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_FUND_RATE_TYPE->';
        Raise util_excp;--Raising exception to handled in public body.


 END CHECK_VALID_FUND_RATE_TYPE;
--------------------------------------------------------------------------------------------------

/*It checks that the rate type
provided is a valid one*/

 FUNCTION CHECK_VALID_PROJ_RATE_TYPE(
 P_proj_rate_type	         IN	 VARCHAR2
 ,P_bill_trans_currency_code	 IN	 VARCHAR2
 ,P_project_currency_code	 IN	 VARCHAR2
 ,P_proj_level_rt_dt_cod	 IN	 VARCHAR2
 ,P_project_rate_date	         IN	 DATE
 ,P_event_date	                 IN	 DATE
 ,x_proj_rate_type	         OUT	 NOCOPY VARCHAR2 -- Added for bug 3009307 --File.Sql.39 bug 4440895
) RETURN VARCHAR2 IS

 -- dummy number; Commented for bug 3009307

    CURSOR PROJ_RATE_TYPE
        IS
 -- Commented for bug 3009307   SELECT 1
     SELECT conversion_type
     FROM   pa_conversion_types_v
     WHERE  conversion_type <>'User'
     AND    (pa_multi_currency.is_user_rate_type_allowed(
               p_bill_trans_currency_code,
               p_project_currency_code,
               decode(p_proj_level_rt_dt_cod, 'PA_INVOICE_DATE',
                          nvl(p_project_rate_date, p_event_date),
                        'FIXED_DATE', p_project_rate_date))= 'N')
       AND  user_conversion_type=P_proj_rate_type
   UNION ALL
 -- Commented for bug 3009307   SELECT 1
      SELECT conversion_type
        FROM   pa_conversion_types_v
       WHERE  pa_multi_currency.is_user_rate_type_allowed(
               p_bill_trans_currency_code,
               p_project_currency_code,
               decode(p_proj_level_rt_dt_cod, 'PA_INVOICE_DATE',
                            nvl(p_project_rate_date, p_event_date),
               		'FIXED_DATE', p_project_rate_date))= 'Y'
        AND  user_conversion_type=P_proj_rate_type;

BEGIN

       OPEN proj_rate_type;
       -- Commented for bug 3009307 FETCH proj_rate_type INTO dummy;
       FETCH proj_rate_type
       INTO x_proj_rate_type;

              IF proj_rate_type%FOUND THEN
                  CLOSE proj_rate_type;
                  RETURN('Y');
              ELSE
                  CLOSE proj_rate_type;
                  RETURN('N');
              END IF;
Exception
        When others then
       x_proj_rate_type := NULL; -- NOCOPY
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_PROJ_RATE_TYPE->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_PROJ_RATE_TYPE;

--------------------------------------------------------------------------------------------
FUNCTION CHECK_VALID_PFC_RATE_TYPE(
  P_pfc_rate_type	         IN	 VARCHAR2
 ,P_bill_trans_currency_code	 IN	 VARCHAR2
 ,P_proj_func_currency_code	 IN	 VARCHAR2
 ,P_proj_level_func_rt_dt_cod	 IN	 VARCHAR2
 ,P_proj_func_rate_date	         IN	 DATE
 ,P_event_date	                 IN	 DATE
 ,x_pfc_rate_type	         OUT	 NOCOPY VARCHAR2 -- Added for bug 3009307 --File.Sql.39 bug 4440895
) RETURN VARCHAR2 IS

-- Commented for bug 3009307 dummy number;

     CURSOR PFC_RATE_TYPE
     IS
  -- Commented for bug 3009307  SELECT 1
    SELECT conversion_type
    FROM   pa_conversion_types_v
    WHERE  conversion_type <>'User'
    AND    (pa_multi_currency.is_user_rate_type_allowed(
               p_bill_trans_currency_code,
               p_proj_func_currency_code,
               decode(p_proj_level_func_rt_dt_cod,  'PA_INVOICE_DATE',
                          nvl(p_proj_func_rate_date, p_event_date),
                        'FIXED_DATE', p_proj_func_rate_date))= 'N')
       AND  user_conversion_type=P_pfc_rate_type
    UNION ALL
  -- Commented for bug 3009307  SELECT 1
    SELECT conversion_type
    FROM   pa_conversion_types_v
    WHERE  pa_multi_currency.is_user_rate_type_allowed(
                   p_bill_trans_currency_code,
               p_proj_func_currency_code,
               decode(p_proj_level_func_rt_dt_cod,
                       'PA_INVOICE_DATE', nvl(p_proj_func_rate_date, p_event_date),
                       'FIXED_DATE', p_proj_func_rate_date))= 'Y'
       AND  user_conversion_type=P_pfc_rate_type;
BEGIN

         OPEN pfc_rate_type;
         -- Commented for bug 3009307 FETCH PFC_RATE_TYPE INTO dummy;
         FETCH pfc_rate_type INTO x_pfc_rate_type;

             IF PFC_RATE_TYPE%FOUND THEN
                CLOSE PFC_RATE_TYPE;
              RETURN('Y');
           ELSE
                 CLOSE PFC_RATE_TYPE;
              RETURN('N');
           END IF;
Exception
        When others then
             x_pfc_rate_type := NULL; --NOCOPY
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_PFC_RATE_TYPE->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_PFC_RATE_TYPE;


---------------------------------------------------------------------------------------------------------

FUNCTION CHECK_VALID_BILL_AMT(
 P_event_type_classification   IN  VARCHAR2
,P_bill_amt                    IN  NUMBER) RETURN  VARCHAR2 IS

BEGIN

    IF P_event_type_classification IN ('DEFERRED REVENUE','INVOICE REDUCTION','SCHEDULED PAYMENTS') THEN
       IF NVL(P_bill_amt,-1)>0 THEN
           RETURN('Y');
       ELSE
           RETURN('N');
       END IF;
   END IF;

  RETURN('Y');
Exception
        When others then
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_BILL_AMT->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_BILL_AMT;
-------------------------------------------------------------------------------------------------------------

/*Validates the revenue
amount for revenue events*/

FUNCTION CHECK_VALID_REV_AMT(
 P_event_type_classification   IN  VARCHAR2
 ,P_rev_amt                   IN  NUMBER) RETURN  VARCHAR2 IS

 BEGIN

    IF P_event_type_classification IN ('WRITE OFF','WRITE ON') THEN
       IF NVL(P_rev_amt,-1)>0 THEN
           RETURN('Y');
       ELSE
           RETURN('N');
       END IF;
    END IF;
 RETURN('Y');/*Not a revenue event*/

Exception
        When others then
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_REV_AMT->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_REV_AMT;
-------------------------------------------------------------------------------------------------------------


/*This function checks if the
  event has been processed i.e
  either revenue generated or billed.
  if the event has been processed it returns
  'N' ,if the event is partially billed it returns 'P'.
 If invoice was generated and then cancelled it returns 'C'.
 If the event has never been processed it returns 'Y' */

 FUNCTION CHECK_EVENT_PROCESSED(
 P_event_id        IN      NUMBER) RETURN VARCHAR2 IS

   CURSOR EVENT_PROCESSED IS
   SELECT REVENUE_DISTRIBUTED_FLAG,BILLED_FLAG
     FROM PA_EVENTS
    WHERE EVENT_ID=P_event_id;

   CURSOR EVENT_BILL_AMOUNT IS
   SELECT SUM(NVL(AMOUNT,0))
     FROM PA_DRAFT_INVOICE_ITEMS DI,PA_EVENTS EV,PA_DRAFT_INVOICES_ALL DIA
    WHERE DI.PROJECT_ID=EV.PROJECT_ID
     AND nvl(DI.TASK_ID,-1) =nvl(EV.TASK_ID,-1)
     AND DI.EVENT_NUM = EV.EVENT_NUM
     AND DI.PROJECT_ID=DIA.PROJECT_ID
     AND DI.DRAFT_INVOICE_NUM=DIA.DRAFT_INVOICE_NUM
     AND NVL(DIA.WRITE_OFF_FLAG,'N')<>'Y'
     AND EV.EVENT_ID = P_event_id;

  l_rev_flag     VARCHAR2(1);
  l_billed_flag  VARCHAR2(1);
  L_BILL_AMOUNT pa_draft_invoice_items.amount%type;
  l_invoiced_flag  VARCHAR2(1):= 'N';
  BEGIN

  OPEN EVENT_PROCESSED;
  FETCH EVENT_PROCESSED INTO l_rev_flag,l_billed_flag;
  CLOSE EVENT_PROCESSED;

    IF (NVL(l_rev_flag,'N')='Y' AND NVL(l_billed_flag,'N')='Y') THEN /*The event has been processed */
        RETURN('N');
    ELSIF (NVL(l_billed_flag,'N')='Y') THEN
        l_invoiced_flag := 'Y';
    END IF;

    IF l_invoiced_flag = 'N' THEN

        DECLARE
               dummy NUMBER;
        BEGIN

 		SELECT 1
                  INTO dummy
		  FROM DUAL
		 WHERE EXISTS (  SELECT NULL
                                   FROM  PA_DRAFT_INVOICE_ITEMS DI,PA_EVENTS EV
                                  WHERE  DI.project_id=EV.project_id
				    AND nvl(DI.TASK_ID,-1) =nvl(EV.TASK_ID,-1)
				    AND DI.EVENT_NUM = EV.EVENT_NUM
				    AND EV.EVENT_ID = P_event_id);

                 OPEN EVENT_BILL_AMOUNT;
		FETCH EVENT_BILL_AMOUNT INTO L_BILL_AMOUNT;

		    IF L_BILL_AMOUNT <> 0 THEN  /*The event has been partially billed */
			  CLOSE EVENT_BILL_AMOUNT;
			  /* Added following if condition for bug 8485535*/
			  IF nvl(l_rev_flag, 'N') = 'Y' THEN
				  RETURN('P');
			  ELSE
				  RETURN('I');
			  END IF;
		    ELSE       /*The invoice for the project has been cancelled */

			  CLOSE EVENT_BILL_AMOUNT;
			  /* Added following if condition for bug 8485535*/
			  IF nvl(l_rev_flag, 'N') = 'Y' THEN
				  RETURN('C');
			  ELSE
				  RETURN('Q');
			  END IF;

	            END IF;

        EXCEPTION
               WHEN NO_DATA_FOUND THEN  /*The event has not been billed */
                    l_invoiced_flag := 'N';
        END;

    END IF;

/* Code added and modified for bug 7110782 - starts */

/* Both invoiced and revenue distributed, event has been processed.
   No update will be allowed */
    IF l_invoiced_flag = 'Y' AND nvl(l_rev_flag, 'N') = 'Y' THEN
           RETURN('N');
    END IF;

/* Only invoiced and not revenue distributed.
   Only update of bill_trans_rev_amount will be allowed */
    IF l_invoiced_flag = 'Y' AND nvl(l_rev_flag, 'N') = 'N' THEN
           RETURN('I');
    END IF;

/* Only revenue distributed but not invoiced
   Only update of bill_trans_bill_amount and bill_hold_flag will be allowed */
    IF l_invoiced_flag = 'N' AND nvl(l_rev_flag, 'N') = 'Y' THEN
           RETURN('R');
    END IF;

/* Neither revenue distributed nor invoiced.Event is not processed. */
    IF l_invoiced_flag = 'N' AND nvl(l_rev_flag, 'N') = 'N' THEN
          RETURN('Y');
    END IF;

/* Code added and modified for bug 7110782 - ends */

Exception
        When others then
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_EVENT_PROCESSED->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_EVENT_PROCESSED;
-------------------------------------------------------------------------------------------------------

/*This function checks if the
  organization provided is a valid one
  returns Y if valid N otherwise*/

FUNCTION CHECK_VALID_INV_ORG(
P_inv_org_name	IN	VARCHAR2,
P_inv_org_id    OUT      NOCOPY NUMBER) RETURN VARCHAR2 IS --File.Sql.39 bug 4440895

 l  NUMBER;

 CURSOR VALID_INV_ORG
     IS
 SELECT HOU.organization_id
   FROM PA_IMPLEMENTATIONS I,HR_ORGANIZATION_UNITS HOU
  WHERE HOU.BUSINESS_GROUP_ID=I.BUSINESS_GROUP_ID
    AND HOU.NAME=P_inv_org_name;

BEGIN

   OPEN VALID_INV_ORG;
  FETCH VALID_INV_ORG INTO  l;

    IF VALID_INV_ORG%FOUND THEN
         CLOSE VALID_INV_ORG;
         P_inv_org_id :=l;
         RETURN('Y');
    ELSE
         CLOSE VALID_INV_ORG;
         RETURN('N');
    END IF;

Exception
        When others then
          p_inv_org_id := NULL; -- NOCOPY
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_INV_ORG->';
        Raise util_excp;--Raising exception to handled in public body.


 END CHECK_VALID_INV_ORG;
----------------------------------------------------------------------------------
FUNCTION CHECK_VALID_INV_ITEM(
P_inv_item_id	IN	NUMBER) RETURN VARCHAR2 IS

dummy number;

  CURSOR VALID_INV_ITEM
      IS
  SELECT 1
    FROM mtl_item_flexfields
   WHERE item_id=P_inv_item_id
     AND    trunc(sysdate)
             BETWEEN  decode(trunc(start_date_active), null, trunc(sysdate), trunc(start_date_active))
                 AND decode (trunc(end_date_active), null, trunc(sysdate), trunc(end_date_active));

BEGIN

   OPEN VALID_INV_ITEM;
  FETCH VALID_INV_ITEM  INTO dummy;

        IF ( VALID_INV_ITEM%FOUND) THEN
              CLOSE  VALID_INV_ITEM;
              RETURN('Y');
        ELSE
              CLOSE  VALID_INV_ITEM;
              RETURN('N');
        END IF;

Exception
        When others then
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_INV_ITEM->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_INV_ITEM;
--------------------------------------------------------------------------------------------------------------------------

/*THIs function validates the revenue  amount for write-off events.
It gets the total accrued amount(1) and total invoiced amount(2) in
projfunc currency.next it converst the revenue amount of unprocessed
write-off events to projfunc currency(3).write-off events can be
entered only if revenue amount(in projfunc currency) is <(1-2-3).*/

FUNCTION  CHECK_WRITE_OFF_AMT(
 P_project_id	        IN	NUMBER
,P_task_id        	IN	NUMBER
,P_event_id             IN      NUMBER
,P_rev_amt        	IN	NUMBER
,P_bill_trans_currency	IN	VARCHAR2
,P_proj_func_currency	IN	VARCHAR2
,P_proj_func_rate_type	IN	VARCHAR2
,P_proj_func_rate	IN	NUMBER
,P_proj_func_rate_date	IN	DATE
,P_event_date	        IN	DATE )RETURN VARCHAR2 IS


        CURSOR proj_rev_bill_amount
            IS
        SELECT SUM(NVL(projfunc_accrued_amount,0)),SUM(NVL(projfunc_billed_amount,0))
        FROM pa_summary_project_fundings
        WHERE project_id= P_project_id
        AND  task_id IS NULL;

        CURSOR task_rev_bill_amount
            IS
        SELECT SUM(NVL(projfunc_accrued_amount,0)),SUM(NVL(projfunc_billed_amount,0))
        FROM pa_summary_project_fundings
        WHERE project_id= P_project_id
        AND task_id=P_task_id;
/*This is commented for performance reason*/
/*      CURSOR PROJ_WRITE_OFF_AMOUNT
            IS
        SELECT NVL(bill_trans_rev_amount,0),bill_trans_currency_code,projfunc_currency_code,
                projfunc_rate_type,projfunc_rate_date,projfunc_exchange_rate,event_date
          FROM PA_EVENTS_V
         WHERE event_type_classification='WRITE OFF'
           AND NVL(revenue_distributed_flag,'N')='N'
           AND event_date IS NOT NULL
           AND NVL(event_id,-1)<>NVL(P_event_id,-2)
           AND project_id= P_project_id;  */

/*     CURSOR TASK_WRITE_OFF_AMOUNT
           IS
       SELECT NVL(bill_trans_rev_amount,0),bill_trans_currency_code,projfunc_currency_code,
              projfunc_rate_type,projfunc_rate_date,projfunc_exchange_rate,event_date
         FROM PA_EVENTS_V
        WHERE event_type_classification='WRITE OFF'
          AND NVL(REVENUE_DISTRIBUTED_FLAG,'N')='N'
          AND event_date IS NOT NULL
          AND project_id= P_project_id
          AND NVL(event_id,-1)<>NVL(P_event_id,-2)
          AND task_id=P_task_id;*/

/* Commented the below and added new for perf bug 3604238
        CURSOR proj_write_off_amount
            IS
        SELECT NVL(bill_trans_rev_amount,0),bill_trans_currency_code,projfunc_currency_code,
                projfunc_rate_type,projfunc_rate_date,projfunc_exchange_rate,completion_date
        FROM PA_EVENTS EV,PA_EVENT_TYPES EVT
        WHERE EVT.event_type_classification='WRITE OFF'
        AND EVT.event_type=EV.event_type
        AND NVL(EV.revenue_distributed_flag,'N')='N'
        AND EV.completion_date IS NOT NULL
        AND NVL(EV.event_id,-1)<>NVL(P_event_id,-2)
        AND EV.project_id= P_project_id;   */

        CURSOR proj_write_off_amount
            IS
        SELECT NVL(bill_trans_rev_amount,0),bill_trans_currency_code,projfunc_currency_code,
                projfunc_rate_type,projfunc_rate_date,projfunc_exchange_rate,completion_date
          FROM PA_EVENTS EV
         WHERE EV.revenue_distributed_flag ='N'
           AND EV.completion_date IS NOT NULL
           AND NVL(EV.event_id,-1)<>NVL(P_event_id,-2)
           AND exists (select 1 from PA_EVENT_TYPES EVT
                        where EVT.event_type_classification='WRITE OFF'
                          and  EVT.event_type=EV.event_type )
           AND EV.project_id= P_project_id;

       CURSOR task_write_off_amount
           IS
       SELECT NVL(bill_trans_rev_amount,0),bill_trans_currency_code,projfunc_currency_code,
              projfunc_rate_type,projfunc_rate_date,projfunc_exchange_rate,completion_date
       FROM PA_EVENTS EV ,PA_EVENT_TYPES EVT
       WHERE EVT.event_type_classification='WRITE OFF'
       AND EVT.event_type=EV.event_type
       AND NVL(EV.revenue_distributed_flag,'N')='N'
       AND EV.completion_date IS NOT NULL
       AND EV.project_id= P_project_id
       AND NVL(EV.event_id,-1)<>NVL(P_event_id,-2)
       AND EV.task_id=P_task_id;

l_accrued_amount                 NUMBER;
l_billed_amount                  NUMBER;
l_bill_trans_amount              NUMBER;
l_bill_trans_currency_code       PA_EVENTS.bill_trans_currency_code%TYPE;  /*VARCHAR2(2000);*/
l_projfunc_currency_code         PA_EVENTS.projfunc_currency_code%TYPE;   /*VARCHAR2(2000);*/
l_projfunc_rate_type             PA_EVENTS.projfunc_rate_type%TYPE; /*VARCHAR2(2000);*/
l_projfunc_rate_date             DATE;
l_projfunc_exchange_rate         NUMBER;
l_event_date                     DATE;
l_conv_date                      DATE;
l_projfunc_rev_amt               NUMBER;
l_denominator                    NUMBER;
l_numerator                      NUMBER;
l_status                         VARCHAR2(2000);
l_sum_revenue                    NUMBER  :=0;

BEGIN

/*l_sum_revenue gets the sum of revenue amounts of all unprocessed WRITE OFF events
  in project functional currency.*/
    IF  P_task_id IS NULL THEN   /*project level event is being inserted So check for only project funding*/
         OPEN proj_rev_bill_amount;
          FETCH proj_rev_bill_amount
          INTO l_accrued_amount,l_billed_amount;

          IF   proj_rev_bill_amount%NOTFOUND THEN
                   CLOSE proj_rev_bill_amount;
                 -- RETURN('Y'); /*there is no funding*/
                   RETURN('N'); /*there is no funding*/

          ELSE   /*of proj_rev_bill_amount%NOTFOUND*/
            OPEN proj_write_off_amount;

              LOOP

                 FETCH proj_write_off_amount
                 INTO l_bill_trans_amount,l_bill_trans_currency_code,
                      l_projfunc_currency_code,l_projfunc_rate_type,
                      l_projfunc_rate_date,l_projfunc_exchange_rate,l_event_date;

                 EXIT WHEN proj_write_off_amount%NOTFOUND;

                 l_conv_date := NVL(l_projfunc_rate_date,l_event_date);
                 /* Calling convert amount proc to convert this amount in PFC */
                 PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_bill_trans_currency_code,
                            P_TO_CURRENCY            => l_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_conv_date,
                            P_CONVERSION_TYPE        => l_projfunc_rate_type,
                            P_AMOUNT                 => l_bill_trans_amount,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_projfunc_rev_amt,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_projfunc_exchange_rate,
                            X_STATUS                 => l_status);
                  IF   l_status IS NOT NULL THEN
                       CLOSE proj_write_off_amount;
                       CLOSE proj_rev_bill_amount;
                       RETURN(l_status);
                  ELSE
                       l_sum_revenue :=NVL(l_sum_revenue,0)+NVL(l_projfunc_rev_amt,0);
                      /*This gives the total revenue amount of unprocessed
                       write-off events in project functional currency*/
                  END IF;
              END LOOP;
              CLOSE proj_write_off_amount;
              CLOSE proj_rev_bill_amount;
          END IF; /*proj_rev_bill_amount%NOTFOUND*/

    ELSE   /*p_task_id NOT NULL*/
           /*Task level event is being inserted .So we have to check both
            project as well as task level funding*/

	 OPEN proj_rev_bill_amount;
         FETCH proj_rev_bill_amount
         INTO l_accrued_amount,l_billed_amount;

	 IF proj_rev_bill_amount%FOUND THEN  /*There is project level funding*/
           OPEN proj_write_off_amount;
             LOOP

               FETCH proj_write_off_amount
               INTO l_bill_trans_amount,l_bill_trans_currency_code,l_projfunc_currency_code,
                    l_projfunc_rate_type,l_projfunc_rate_date,l_projfunc_exchange_rate,
                    l_event_date;

               EXIT WHEN proj_write_off_amount%NOTFOUND;

               l_conv_date := NVL(l_projfunc_rate_date,l_event_date);
              /* Calling convert amount proc to convert this amount in PFC */
               PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_bill_trans_currency_code,
                            P_TO_CURRENCY            => l_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_conv_date,
                            P_CONVERSION_TYPE        => l_projfunc_rate_type,
                            P_AMOUNT                 => l_bill_trans_amount,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_projfunc_rev_amt,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_projfunc_exchange_rate,
                            X_STATUS                 => l_status);
                  IF l_status IS NOT NULL THEN
                    CLOSE proj_rev_bill_amount;
                    CLOSE proj_write_off_amount;
                    RETURN(l_status);
                  ELSE
                       l_sum_revenue :=NVL(l_sum_revenue,0)+NVL(l_projfunc_rev_amt,0);
                      /*This gives the total revenue amount of unprocessed
                       write-off events*/
                  END IF;
             END LOOP;
             CLOSE proj_write_off_amount;
             CLOSE proj_rev_bill_amount;

         ELSE  /*proj_rev_bill_amount%FOUND*/
	   CLOSE  proj_rev_bill_amount;/*Close the cusrsor as it won't be used any more*/

           OPEN  task_rev_bill_amount ;
           FETCH task_rev_bill_amount
           INTO l_accrued_amount,l_billed_amount;

	   IF task_rev_bill_amount%NOTFOUND THEN
             CLOSE proj_rev_bill_amount;
	     CLOSE task_rev_bill_amount;
            --  RETURN('Y'); /*there is no funding*/
             RETURN('N'); /*there is no funding*/

           ELSE  /*else of task_rev_bill_amount%NOTFOUND*/

             OPEN task_write_off_amount;
             LOOP

                FETCH task_write_off_amount
                INTO l_bill_trans_amount,l_bill_trans_currency_code,l_projfunc_currency_code,
                     l_projfunc_rate_type,l_projfunc_rate_date,l_projfunc_exchange_rate,l_event_date;

                EXIT WHEN task_write_off_amount%NOTFOUND;

                l_conv_date := NVL(l_projfunc_rate_date,l_event_date);
                /* Calling convert amount proc to convert this amount in PFC */
                PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_bill_trans_currency_code,
                            P_TO_CURRENCY            => l_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_conv_date,
                            P_CONVERSION_TYPE        => l_projfunc_rate_type,
                            P_AMOUNT                 => l_bill_trans_amount,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_projfunc_rev_amt,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_projfunc_exchange_rate,
                            X_STATUS                 => l_status);
                     IF l_status IS NOT NULL THEN
                           CLOSE task_rev_bill_amount;
                           CLOSE task_write_off_amount;
                           RETURN(l_status);
                     ELSE
                          l_sum_revenue :=NVL(l_sum_revenue,0)+NVL(l_projfunc_rev_amt,0);
                         /*This gives the total revenue amount of unprocessed
                          write-off events*/
                     END IF;
             END LOOP;
             CLOSE task_write_off_amount;
             CLOSE task_rev_bill_amount;
           END IF; /*END OF task_rev_bill_amount%NOTFOUND*/
         END IF; /*proj_rev_bill_amount%FOUND*/
    END IF;/*p_task_id NOT NULL*/
/*END OF CALCULATION OF l_sum_revenue*/

/*Copying the input parameter into local variables*/
l_bill_trans_amount        :=P_rev_amt;
l_bill_trans_currency_code := P_bill_trans_currency;
l_projfunc_currency_code   := P_proj_func_currency;
l_projfunc_rate_type       := P_proj_func_rate_type;
l_projfunc_exchange_rate   := P_proj_func_rate;
l_projfunc_rate_date       := P_proj_func_rate_date;
l_event_date               := P_event_date;
l_projfunc_rev_amt         := 0.00;
/*Next  convert the revenue amount of the event into projfunc currency*/
      l_conv_date := NVL(l_projfunc_rate_date,l_event_date);
     /* Calling convert amount proc to convert this amount in PFC */
                   PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_bill_trans_currency_code,
                            P_TO_CURRENCY            => l_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_conv_date,
                            P_CONVERSION_TYPE        => l_projfunc_rate_type,
                            P_AMOUNT                 => l_bill_trans_amount,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_projfunc_rev_amt,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => l_projfunc_exchange_rate,
                            X_STATUS                 => l_status);
                     IF l_status IS NOT NULL THEN
                            RETURN(l_status);
                     END IF;
/*l_projfunc_rev_amt  contains the revenue amount of the event being inserted in projfunc curency*/

IF   (l_projfunc_rev_amt <= (l_accrued_amount-l_billed_amount-l_sum_revenue)) THEN
       RETURN('Y');
ELSE
       RETURN('N');
END IF;

Exception
        When others then
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_WRITE_OFF_AMT->';
        Raise util_excp;--Raising exception to handled in public body.


END  CHECK_WRITE_OFF_AMT;
--------------------------------------------------------------------------------------------
-- Federal Uptake
/*it validates that the agreement number, agreement type, customer number
returns the agreement_id as an out parameter to be used by
subsequent functions*/

FUNCTION  CHECK_VALID_AGREEMENT (
 P_project_id           IN      NUMBER
,P_task_id              IN      NUMBER
,P_agreement_number     IN      VARCHAR2
,P_agreement_type       IN      VARCHAR2
,P_customer_number      IN      VARCHAR2
,P_agreement_id         OUT     NOCOPY NUMBER) RETURN  VARCHAR2 IS

 l_agreement_id number;

       CURSOR  GET_AGREEMENT_ID
           IS
       SELECT  AG.AGREEMENT_ID
         FROM  pa_projects_all p,
	       pa_agreements_all ag,
               hz_cust_accounts cust,
               Pa_summary_project_fundings fun
        WHERE  p.project_id = P_project_id
	  AND  nvl(p.date_eff_funds_consumption, 'N') = 'Y'
	  AND  fun.project_id = p.project_id
          AND  ag.agreement_id = fun.agreement_id
          And  nvl(fun.task_id, nvl(P_task_id,-999)) = nvl(P_task_id,-999)
          AND  cust.account_number = P_customer_number
          AND  ag.customer_id = cust.cust_account_id
          AND  ag.agreement_num = P_agreement_number
          AND  ag.agreement_type = P_agreement_type
          AND  fun.TOTAL_BASELINED_AMOUNT   >0;

BEGIN

         IF (P_agreement_number IS NOT NULL  OR
             P_agreement_type    IS NOT NULL  OR
             P_customer_number   IS NOT NULL  ) THEN  /*If agreement number is provided*/

                    OPEN get_agreement_id;
                   FETCH get_agreement_id INTO l_agreement_id;

                      IF get_agreement_id%FOUND THEN
                           CLOSE get_agreement_id;
                           P_agreement_id :=l_agreement_id;
                           RETURN ('Y');
                      ELSE
                           CLOSE get_agreement_id;
                           RETURN ('N');
                      END IF;/*End of GET_AGREEMENT_ID%FOUND*/

         ELSE

                    RETURN ('Y');  /*No agreement number, agreement type,
                                     customer numberis given,so no validation is required*/
         END IF;/*End of  P_agreement_number IS NOT NULL*/
Exception
        When others then
          p_agreement_id := NULL; --NOCOPY
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_AGREEMENT->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_AGREEMENT;
-----------------------------------------------------------------------------------------------------
-- Federal Uptake
FUNCTION CHECK_VALID_EVENT_DATE (
 P_event_date           IN      DATE
,P_agreement_id         IN      NUMBER ) RETURN VARCHAR2 IS

l_agmt_start_date   DATE;
l_agmt_end_date     DATE;

     CURSOR get_agmt_date
         IS
     SELECT start_date, expiration_date
       FROM pa_agreements_all
      WHERE agreement_id = P_agreement_id;

BEGIN

   IF P_event_date IS NOT NULL THEN
      OPEN get_agmt_date;
      FETCH get_agmt_date INTO l_agmt_start_date, l_agmt_end_date ;

      IF (P_event_date between NVL(l_agmt_start_date,(P_event_date - 1))
                           and NVL(l_agmt_end_date ,(P_event_date + 1))) THEN
          CLOSE get_agmt_date;
          RETURN ('Y');
      ELSE
          CLOSE get_agmt_date;
          RETURN('N');
      END IF;
    ELSE
      RETURN ('Y');  /*No event date is given,so no validation is required*/
    END IF;/*End of  P_event_date IS NOT NULL*/
Exception
        When others then
        --This user defined exception is used to track the packages and procedures
        --involved in that flow.
        --this user defined exception will be handled in private body which shall again
        --raise another user defined exception which will be handled in public body.
        --At each of these places like CORE,PRIVATE and PUBLIC packages we shall not
        --only record the package name but also the procedure involved.
        PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'CORE->';
        PA_EVENT_PUB.procedure_name := PA_EVENT_PUB.procedure_name ||'CHECK_VALID_EVENT_DATE->';
        Raise util_excp;--Raising exception to handled in public body.


END CHECK_VALID_EVENT_DATE;
----------------------------------------------------------------------------------------------------


END PA_EVENT_CORE;

/
