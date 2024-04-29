--------------------------------------------------------
--  DDL for Package Body PA_FUNDING_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FUNDING_CORE" AS
/* $Header: PAXBIPFB.pls 120.4 2007/02/07 10:46:35 rgandhi ship $ */

-- ==========================================================================
--  Get_funding is used to get funding amount for a specified
--     project id, task id, budget type code
-- ==========================================================================
FUNCTION Get_Funding(     p_project_id    IN      NUMBER,
                          p_task_id       IN      NUMBER DEFAULT NULL,
			  p_budget_type	  IN	VARCHAR2) RETURN NUMBER IS
	l_amount	NUMBER:=0;
BEGIN

	SELECT NVL(SUM(allocated_amount),0)
	  INTO l_amount
	  FROM pa_project_fundings
	 WHERE project_id	= p_project_id
	   AND NVL(task_id,-99)	= NVL(p_task_id ,-99)
	   AND RTRIM(budget_type_code) = RTRIM(p_budget_type);

       RETURN(l_amount);

END Get_Funding;

--
--Name:			check_fund_allocated
--Type:			Function
--Description:		This function will return 'Y' IF funds have been allocated to the
--			passed agreement ELSE will return 'N'
--
--
--Called subprograms: none
--
--
--
--History:
--    			16-APR-2000	Created		Adwait Marathe.
--

FUNCTION check_fund_allocated
( p_agreement_id			IN	NUMBER
) RETURN VARCHAR2
IS
  dummy number;
  l_total_unbaselined_amount number;
  l_total_baselined_amount number;

BEGIN
	--dbms_output.put_line('Inside:PA_FUNDING_CORE.CHECK_FUND_ALLOCATED');
	--dbms_output.put_line('Agreement_id = '||nvl(to_char(p_agreement_id),'NULL'));
	Select 	sum(total_unbaselined_amount) , sum(total_baselined_amount)
	Into    l_total_unbaselined_amount, l_total_baselined_amount
	From  	Pa_summary_project_fundings
	Where agreement_id = p_agreement_id;
  	   IF (nvl(l_total_unbaselined_amount, 0) = 0 AND
      	   nvl(l_total_baselined_amount, 0) = 0) THEN
        	BEGIN
        		--dbms_output.put_line('NO MONEY!!!');
            		select 1
              		into dummy
              		from dual
              		where exists ( 	select 1
                               		from pa_project_fundings
                              		where agreement_id = p_agreement_id);

           		IF dummy = 1 THEN
		 	return 'Y';
			END IF;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
		--dbms_output.put_line('NO RECORD!!!');
		return 'N';
		END;
	ELSE
	return 'Y';
END IF;
END check_fund_allocated;


--
--Name:                 check_accrued_billed_baselined
--Type:                 Function
--Description:          This function will return 'Y'
--			Total amount of funds allocated is less than amount accrued or billed.
--			ELSE will return 'N' for given Projet_id, agreement_id, task_id and fund amount.
--
--Called subprograms: none
--
--History:
--                      16-APR-2000     Created         Adwait Marathe.

FUNCTION check_accrued_billed_baselined
( p_agreement_id			IN	NUMBER
 ,p_project_id		                IN	NUMBER
 ,p_task_id				IN	NUMBER
 ,p_amount				IN	NUMBER
) RETURN VARCHAR2
IS
    	cursor c1 is
	Select 	sign(p_amount +
	            greatest(nvl(total_accrued_amount, 0),
		    nvl(total_billed_amount, 0),
		    nvl(total_baselined_amount, 0) +
		    nvl(total_unbaselined_amount, 0)))
	From 	pa_summary_project_fundings
	Where 	project_id = p_project_id
	And 	agreement_id = p_agreement_id
	And 	nvl(task_id, 0) = nvl(p_task_id, 0);
    	mflag 	number;
BEGIN
   	open c1;
    	fetch c1 into mflag;

    	IF (c1%found) THEN
      	  IF (mflag < 0) THEN
		RETURN 'N';
	  END IF;
    	END IF;
	close c1;
EXCEPTION
   	WHEN NO_DATA_FOUND THEN
	RETURN 'Y';
    	WHEN OTHERS THEN
	RETURN 'N' ;
END check_accrued_billed_baselined;



--
--Name:                 check_valid_project
--Type:                 Function
--Description:          This function will return 'Y'
--                       IF the project is a valid project ELSE will return 'N'
--
--Called subprograms: none
--
--History:
--                      16-APR-2000     Created         Adwait Marathe.
--  07-sep-2001  Modified for MCB2
--               Added new param p_project_id and used pa_proj_fund_valid_v

FUNCTION check_valid_project
(p_customer_id            		IN	NUMBER,
 p_project_id				IN	NUMBER,
 p_agreement_id                         IN      NUMBER /*Federal*/
) RETURN VARCHAR2
IS
/*
Cursor c1 is
        Select 1
        From    Pa_lookups lk, Pa_projects_all P , pa_project_types pt, pa_project_customers c
        where   (decode(p.template_flag, 'Y', 'Y', pa_security.allow_query(p.project_id)) = 'Y'
                and decode(p.template_flag, 'Y', 'Y', pa_security.allow_update(p.project_id)) = 'Y' )
                and pt.project_type = p.project_type and p.project_id = c.project_id
                and pa_project_stus_utils.is_project_status_closed(p.project_status_code) = 'N'
                and c.customer_id = p_customer_id and lk.lookup_type(+) = 'ALLOWABLE FUNDING LEVEL'
                and lk.lookup_code(+) = pt.allowable_funding_level_code;
 commented for mcb2 change */
Cursor c1 is select 1 from pa_proj_fund_valid_v
	     where project_id = p_project_id
	     and customer_id = p_customer_id
	     AND project_type_class_code = 'CONTRACT';     /* Added for bug 3017733 */

project_exists number;

l_return_status  VARCHAR2(1):='N';
l_count          NUMBER;
l_proj_type      VARCHAR2(30);
l_proj_type1     VARCHAR2(30);

BEGIN
	--dbms_output.put_line('Inside: PA_FUNDING_CORE.CHECK_VALID_PROJECT');
	--dbms_output.put_line('Customer_id: '||nvl(to_char(p_customer_id),'NULL'));

	Open c1;
  	fetch c1 into project_exists;

        IF (c1%found) THEN
                l_return_status := 'Y';
	ELSE    l_return_status := 'N';
        END IF;
	close c1;


  /*Added for federal*/

        IF (l_return_status ='Y') THEN

	      SELECT count(*)
	        INTO l_count
                FROM pa_agreements
	       WHERE agreement_id = p_agreement_id
	         AND advance_amount >0;

	      IF (l_count >0) THEN

	         SELECT project_type
		   INTO l_proj_type
		   FROM pa_projects
	          WHERE project_id = p_project_id;

                 SELECT project_type
		   INTO l_proj_type1
		   FROM pa_project_types
	          WHERE project_type  = l_proj_type
	            AND nvl(cc_prvdr_flag,'N') ='N';
              END IF;

	      l_return_status := 'Y';
        END IF;

	return l_return_status;

EXCEPTION
	WHEN no_data_found THEN return 'N';
END check_valid_project;

--
--Name:                 get_funding_id
--Type:                 FUNCTION
--Description:          This function will get the corresponding function_id for the funding_id or funding _reference given
-- 			the corresponding funding reference.
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION get_funding_id
	( p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS

CURSOR c1
IS
SELECT f.project_funding_id
FROM PA_PROJECT_FUNDINGS f
WHERE f.pm_funding_reference = p_funding_reference;

l_fund_rec1 c1%ROWTYPE;

BEGIN
	--dbms_output.put_line('Inside: PA_FUNDING_CORE.GET_FUNDING_ID');
	IF p_funding_reference is NOT NULL
	   OR (p_funding_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	THEN
		OPEN c1;
		FETCH c1 INTO l_fund_rec1;
		IF c1%FOUND THEN
		RETURN  l_fund_rec1.project_funding_id;
		END IF;
		CLOSE c1;
	END IF;

END get_funding_id;

--
--Name:                 check_valid_task
--Type:                 Function
--Description:          This function will return 'Y'
--                       IF the task is a valid task for project_id passed ELSE will return 'N'
--
--Called subprograms: none
--
--History:
--                      16-APR-2000     Created         Adwait Marathe.



FUNCTION check_valid_task
( p_project_id 				IN 	NUMBER
 ,p_task_id        			IN      NUMBER
) RETURN VARCHAR2
IS
task_exists number;
BEGIN
--dbms_output.put_line('Inside: PA_FUNDING_CORE.CHECK_VALID_TASK');
	--dbms_output.put_line('p_task_id:'||nvl(to_char(p_task_id),'NULL'));
	IF p_task_id is not null THEN
		--dbms_output.put_line('Task id is not null');
	Select 	1
	Into 	task_exists
	From	Dual
	Where 	exists(
		select 	task_name, task_number, task_id
		from 	pa_tasks_top_v
		where 	project_id = p_project_id
		and	task_id = p_task_id );
	--dbms_output.put_line('Returning Y');
	RETURN 'Y';
	END IF;

EXCEPTION
	When no_data_found THEN
		--dbms_output.put_line('Returning N');
		RETURN 'N';
END	check_valid_task;



--
--Name:                 CHECK_PROJECT_TEMPLATE
--Type:                 Function
--Description:          This function will return 'Y'
--                      IF the project is a template rpoject ELSE will return 'N'
--
--Called subprograms: none
--
--History:
--                      16-APR-2000     Created         Adwait Marathe.



FUNCTION CHECK_PROJECT_TEMPLATE
(p_project_id                          IN      NUMBER
) RETURN VARCHAR2
IS
l_template_flag 	pa_projects_all.template_flag%type;
BEGIN
	Select 	nvl(template_flag,'N')
	into	l_template_flag
	From	pa_projects_all
	Where	project_id = p_project_id;
RETURN	l_template_flag;
EXCEPTION
	When Others THEN RETURN 'N';
END	CHECK_PROJECT_TEMPLATE;

--
--Name:                 check_task_fund_allowed
--Type:                 Function
--Description:          This function will return 'Y'
--                      IF the task level funding is allowed for the project ELSE will return 'N'
--
--Called subprograms: none
--
--History:
--                      16-APR-2000     Created         Adwait Marathe.


FUNCTION check_task_fund_allowed
(  p_project_id        		IN 	NUMBER
) RETURN VARCHAR2
IS
l_ALLOWABLE_FUNDING_LEVEL_CODE pa_project_types_all.ALLOWABLE_FUNDING_LEVEL_CODE%type;

BEGIN
	Select 	ALLOWABLE_FUNDING_LEVEL_CODE
	Into 	l_ALLOWABLE_FUNDING_LEVEL_CODE
	From 	pa_project_types_all pt, pa_projects_all p
	Where 	p.project_id=p_project_id
	And 	p.project_type=pt.project_type
	AND	    p.org_id = pt.org_id; /*Bug5374298 Removed NVL join on org_id*/

	IF 	l_ALLOWABLE_FUNDING_LEVEL_CODE = 'T'
	Then 	RETURN 	'Y';
	ELSE 	RETURN 	'N';
	END	IF;
END check_task_fund_allowed;

--
--Name:                 check_task_fund_allowed
--Type:                 Function
--Description:          This function will return 'Y'
--                      IF there is not task level evenrs defined ELSE will return 'N'
--
--Called subprograms: none
--
--History:
--                      16-APR-2000     Created         Adwait Marathe.

FUNCTION check_project_fund_allowed
( p_project_id        		IN 	NUMBER
 ,p_task_id			In	NUMBER
) RETURN VARCHAR2
IS
Proj_ev_exists number;
BEGIN
	IF p_task_id is not null THEN
	select 	1
	into 	proj_ev_exists
	from 	pa_events
	where 	project_id = p_project_id
	and 	task_Id IS NULL
	and 	rownum = 1;

	    IF (proj_ev_exists = 1) THEN
	     	RETURN 'Y';
	    ELSE
		RETURN 'N';
	    END IF;
	END IF;
END check_project_fund_allowed;

--
--Name:                 Validate_Level_Change
--Type:                 Function
--Description:          This function will return 'Y' IF the funding level change is a valid one.
--                      ELSE will return 'N'
--			this can be dome by checking
--			(1) Any expenditure item is revenue distributed ?
--			(2) Any event is revenue distributed?
--			(3) Any event is billed ??
--
--Called subprograms: pa_events_pkg.Is_Event_Billed
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--

FUNCTION validate_level_change
(  p_project_id			IN	NUMBER
  ,p_task_id			IN	NUMBER
 )
RETURN varchar2 IS

   V_valid_level_change   Varchar2(1);
   v_billed_flag          varchar2(1);

BEGIN

   BEGIN
     -- Any expenditure item is revenue distributed ?
/*  Commented for Bug 3457824
     select 'N' into v_valid_level_change from dual
      where exists
         (select T.project_id
          from pa_expenditure_items E, pa_tasks T
          where T.project_id = p_project_id
          and  E.task_id = T.task_id
          and  E.revenue_distributed_flag <> 'N');
*/

/* Code Added for Bug 3457824 starts here */

  select 'N' into v_valid_level_change from dual
  where exists
 (select E.project_id
  from pa_expenditure_items E
  where E.project_id = p_project_id
  and  E.revenue_distributed_flag <> 'N');

/* Code Added for Bug 3457824 ends here */

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          V_valid_level_change := 'Y';

   END;


   IF v_valid_level_change = 'Y' THEN

        BEGIN
                 -- Any event is revenue distributed?

                SELECT 'N'
                INTO v_valid_level_change
                FROM DUAL
                WHERE  EXISTS (
                        SELECT project_id FROM PA_EVENTS
                        WHERE  project_id = p_project_id AND
                               revenue_distributed_flag ='Y');

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                v_valid_level_change := 'Y';

        END;

     END IF;

     IF v_valid_level_change ='Y' THEN

                -- Any event is billed ??

           BEGIN

             FOR evt_rec IN( SELECT project_id, task_id, event_num, bill_amount
                                FROM pa_events
                                WHERE project_id = p_project_id AND
                                      revenue_distributed_flag ='N' AND
                                      bill_amount <> 0 ) LOOP

                        v_billed_flag := pa_events_pkg.Is_Event_Billed(
                                                evt_rec.project_id,
                                                evt_rec.task_id,
                                                evt_rec.event_num,
                                                evt_rec.bill_amount);
                        IF v_billed_flag ='Y' THEN
                                v_valid_level_change := 'N';
                                 exit;
                         END IF;

              END LOOP;

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                v_valid_level_change := 'Y';

           END;

   END IF;

   RETURN V_valid_level_change;

END validate_level_change;


--
--Name:                 check_level_change
--Type:                 Function
--Description:          This function will return 'Y' IF the funding level has been changed.
--                      and the chenged level is a valis one. this can be done by
--			calling validate_level_change
--
--Called subprograms: validate_level_change
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--


FUNCTION check_level_change
(p_agreement_id			IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 )
RETURN VARCHAR2
IS
   V_task_id   Number := 0;
   V_Is_level_Valid Varchar2(1);

BEGIN
   V_task_id := NULL;
   SELECT  task_id INTO V_task_id
   FROM pa_project_fundings
   WHERE project_funding_id =
         (SELECT max(project_funding_id)
          FROM pa_project_fundings
          WHERE project_id    = p_project_id
          AND   agreement_id  = p_agreement_id);

   IF (((V_task_id IS NULL) AND (p_task_id IS NULL)) OR
       ((nvl(V_task_id,0) <> 0) AND (nvl(p_task_id,0) <> 0))) THEN
       V_Is_level_Valid := 'Y';
   ELSE
       V_Is_level_Valid := validate_level_change(p_project_id,p_task_id);
   END IF;
   RETURN (V_Is_level_Valid);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
         V_Is_level_Valid := 'Y';
         RETURN (V_Is_level_Valid);
END check_level_change;

--
--Name:                 check_proj_agr_fund_ok
--Type:                 Function
--Description:          This function will return 'Y' if it is ok to fund a project from the
--                      given agreement else 'N'
--Called subprograms:   None
--
--
--History:
--                      24-JAN-2003     Created         Puneet  Rastogi.
--
/* added function bug 2756047 */
FUNCTION  check_proj_agr_fund_ok
        (  p_agreement_id                       IN      NUMBER
          ,p_project_id                         IN      NUMBER
        ) RETURN VARCHAR2
is

    Is_agr_fund_ok  varchar2(1) := 'N';

BEGIN
   --dbms_output.put_line('Inside: PA_FUNDING_CORE.CHECK_PROJ_AGR_FUND_OK');
     SELECT   'Y'
     INTO     Is_agr_fund_ok
     FROM     PA_PROJECTS_ALL P, PA_AGREEMENTS_ALL A
     WHERE    P.PROJECT_ID = p_project_id
     AND      A.AGREEMENT_ID = p_agreement_id
     AND     (P.multi_currency_billing_flag = 'Y'
              OR (p.multi_currency_billing_flag = 'N'
                   AND p.projfunc_currency_code = a.agreement_currency_code))
     AND      not exists ( SELECT null
                 FROM PA_SUMMARY_PROJECT_FUNDINGS spf
                 WHERE spf.project_id = p.project_id
                 AND p.invproc_currency_type = 'FUNDING_CURRENCY'
                 AND spf.funding_currency_code <> a.agreement_currency_code
                 AND (spf.total_baselined_amount <> 0
                      OR spf.total_unbaselined_amount <> 0))
     AND      (nvl(p.template_flag,'N') = 'N'
               OR ( p.template_flag = 'Y'
                    AND not exists ( select null
                           FROM PA_SUMMARY_PROJECT_FUNDINGS spf
                           where  spf.project_id=p.project_id
                           and spf.agreement_id <> a.agreement_id))
               )
     AND       (nvl(a.template_flag,'N') = 'N'
                OR ( a.template_flag = 'Y'
                     AND not exists ( select null
                           FROM PA_SUMMARY_PROJECT_FUNDINGS spf
                           where  spf.project_id <> p.project_id
                           and spf.agreement_id = a.agreement_id))
               ) ;

    --dbms_output.put_line('Outside: PA_FUNDING_CORE.CHECK_PROJ_AGR_FUND_OK');
    RETURN 'Y';

EXCEPTION WHEN NO_DATA_FOUND THEN
    --dbms_output.put_line('Outside:Exception PA_FUNDING_CORE.CHECK_PROJ_AGR_FUND_OK');
   RETURN 'N';
END check_proj_agr_fund_ok;


--
--Name:                 check_proj_task_lvl_funding
--Type:                 Function
--Description:          This function will return variour  values. the interpretation of those
--			is as follows
--			"A" IF user is entering Project Level Funding WHEN task level funding exists
--			Or IF the revenue have been distributed. Message is PA_PROJ_FUND_NO_TASK_TRANS
--			"P" IF user in entering task level funding WHEN project level funding exists
--			Message is PA_BU_PROJECT_ALLOC_ONLY
--			"T" IF user is allocating funding at Project level WHEN Top task level
--			funding exists. Message is PA_BU_TASK_ALLOC_ONLY
--			"B" IF user change to task-level funding WHEN project-level events exist,
--			or IF Revenue has been distributed. Message is PA_TASK_FUND_NO_PROJ_TRANS
--Called subprograms: check_level_change
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--


FUNCTION  check_proj_task_lvl_funding
	(  p_agreement_id                      	IN      NUMBER
 	  ,p_project_id                  	IN      NUMBER
 	  ,p_task_id                     	IN      NUMBER
 	) RETURN VARCHAR2
is

    dummy_amount   number;
    Is_level_change_valid  varchar2(1);
BEGIN
   --dbms_output.put_line('Inside: PA_FUNDING_CORE.CHECK_PROJ_TASK_LVL_FUNDING');

   Is_level_change_valid := check_level_change(p_agreement_id,p_project_id,p_task_id);

   IF p_task_id is null THEN

      -- Project Level Funding Entered. Check for task level Funding
      IF (Is_level_change_valid = 'N') THEN
      	--dbms_output.put_line('Returning A');
	RETURN 'A';
         -- control.app_error('ERROR', 'PA_PROJ_FUND_NO_TASK_TRANS');
      END IF;


      SELECT nvl(max(sum(nvl(allocated_amount,0))),0)
      INTO   dummy_amount
      FROM  PA_PROJECT_FUNDINGS P
      WHERE P.PROJECT_ID   = p_project_id
      AND   TASK_ID IS NOT NULL
      AND   BUDGET_TYPE_CODE IN ('BASELINE', 'DRAFT')
      GROUP BY TASK_ID;

      IF dummy_amount > 0   THEN
      	--dbms_output.put_line('Returning T');
	RETURN 'T';
         -- control.app_error('ERROR','PA_BU_TASK_ALLOC_ONLY');
      END IF;

  ELSE

      -- Top Task Level Funding Entered. Check for project level Funding
      IF (Is_level_change_valid = 'N') THEN
      	--dbms_output.put_line('Returning B');
	RETURN 'B';
         -- control.app_error('ERROR', 'PA_TASK_FUND_NO_PROJ_TRANS');
      END IF;

      SELECT NVL(SUM(ALLOCATED_AMOUNT), 0)
      INTO  dummy_amount
      FROM  PA_PROJECT_FUNDINGS P
      WHERE P.PROJECT_ID   = p_project_id
      AND   P.TASK_ID IS NULL
      AND   P.BUDGET_TYPE_CODE IN ('BASELINE', 'DRAFT');

      IF dummy_amount > 0   THEN
        --dbms_output.put_line('Returning P');
	RETURN 'P';
         -- control.app_error('ERROR','PA_BU_TASK_ALLOC_ONLY');
      END IF;

  END IF;
  RETURN 'Y';
   --dbms_output.put_line('Outside: PA_FUNDING_CORE.CHECK_PROJ_TASK_LVL_FUNDING');
END check_proj_task_lvl_funding;

--
--Name:                 check_project_type
--Type:                 Function
--Description:          This function will return variour  values. the interpretation of those
--			is as follows
--			"Y" IF the project type is CONTRACT
--			"N" IF the project type is not CONTRACT
--Called subprograms:   N/A
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--

FUNCTION check_project_type
(p_project_id        		IN 	NUMBER
) RETURN VARCHAR2
IS
l_class_code pa_project_types_all.project_type_class_code%type;
BEGIN

	Select 	pt.project_type_class_code
	Into	l_class_code
 	From 	pa_projects_all p, pa_project_types_all pt
	where 	p.project_type = pt.project_type
	AND	    p.org_id = pt.org_id /*Bug5374298 Removed NVL join on org_id*/
	and p.project_id = p_project_id;

	   IF 		l_class_code = 'CONTRACT'
	   Then 	RETURN  'Y';
	   ELSE		RETURN  'N';
	   END IF;
EXCEPTION
	When Others Then RETURN 'N';
END check_project_type;

--
--Name:                 check_budget_type
--Type:                 Function
--Description:          This function will return 'Y'IF the budget type is DRAFT else 'N'
--
--Called subprograms: none
--
--History:
--                      16-APR-2000     Created         Adwait Marathe.
FUNCTION check_budget_type
(p_funding_id        		IN 	NUMBER
) RETURN VARCHAR2
IS
l_budget_code pa_project_fundings.budget_type_code%type;
BEGIN

	Select 	pf.budget_type_code
	Into	l_budget_code
 	From 	pa_project_fundings pf
	where 	pf.project_funding_id = p_funding_id;

	   IF 		l_budget_code = 'DRAFT'
	   THEN 	RETURN  'Y';
	   ELSE		RETURN  'N';
	   END IF;
EXCEPTION
	When Others Then RETURN 'N';
END check_budget_type;

--
--Name:                 create_funding
--Type:                 PROCEDURE
--Description:          This procedure is used to create a funding record in PA_PROJECT_FUNDINGS
--Called subprograms:   pa_project_fundings_pkg.insert_row
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--                      15-MAY-2000     Created         Nikhil Mishra
--                      07-SEP-2001     Modified        Srividya Sivaraman
--                     Added all new columns corresponding to MCB2

  PROCEDURE create_funding(
	    p_Rowid                   IN OUT NOCOPY VARCHAR2,/*File.sql.39*/
            p_Project_Funding_Id      IN OUT NOCOPY NUMBER,/*File.sql.39*/
            p_Last_Update_Date	      IN     DATE,
            p_Last_Updated_By	      IN     NUMBER,
            p_Creation_Date	      IN     DATE,
            p_Created_By	      IN     NUMBER,
            p_Last_Update_Login	      IN     NUMBER,
            p_Agreement_Id	      IN     NUMBER,
            p_Project_Id	      IN     NUMBER,
            p_Task_id		      IN     NUMBER,
            p_Budget_Type_Code	      IN     VARCHAR2,
            p_Allocated_Amount	      IN     NUMBER,
            p_Date_Allocated	      IN     DATE,
	    p_Control_Item_ID	      IN     NUMBER DEFAULT NULL,    -- FP_M changes
            p_Attribute_Category      IN     VARCHAR2,
            p_Attribute1	      IN     VARCHAR2,
            p_Attribute2	      IN     VARCHAR2,
            p_Attribute3	      IN     VARCHAR2,
            p_Attribute4	      IN     VARCHAR2,
            p_Attribute5	      IN     VARCHAR2,
            p_Attribute6	      IN     VARCHAR2,
            p_Attribute7	      IN     VARCHAR2,
            p_Attribute8	      IN     VARCHAR2,
            p_Attribute9	      IN     VARCHAR2,
            p_Attribute10	      IN     VARCHAR2,
            p_pm_funding_reference    IN     VARCHAR2,
            p_pm_product_code	      IN     VARCHAR2,
	    p_project_rate_type	      IN     VARCHAR2	DEFAULT NULL,
	    p_project_rate_date	      IN     DATE	DEFAULT NULL,
	    p_project_exchange_rate   IN     NUMBER	DEFAULT	NULL,
	    p_projfunc_rate_type      IN     VARCHAR2	DEFAULT NULL,
	    p_projfunc_rate_date      IN     DATE	DEFAULT NULL,
	    p_projfunc_exchange_rate  IN     NUMBER	DEFAULT	NULL,
            x_err_code                OUT    NOCOPY NUMBER,/*File.sql.39*/
            x_err_msg                 OUT    NOCOPY VARCHAR2,/*File.sql.39*/
            p_funding_category        IN     VARCHAR2   /* Bug 2244796 */
                     )
  IS
	l_Project_Funding_Id  NUMBER := p_Project_Funding_Id;
        l_err_msg                        VARCHAR2(150);
        l_err_code                      NUMBER;
	l_funding_currency_code		VARCHAR2(15);

	l_project_currency_code		VARCHAR2(15);
	l_project_rate_type		VARCHAR2(30);
	l_project_rate_date		DATE;
	l_project_exchange_rate		NUMBER;
	l_project_allocated_amount	NUMBER;

	l_projfunc_currency_code	VARCHAR2(15);
	l_projfunc_rate_type		VARCHAR2(30);
	l_projfunc_rate_date		DATE;
	l_projfunc_exchange_rate	NUMBER;
	l_projfunc_allocated_amount	NUMBER;

	l_invproc_currency_code	        VARCHAR2(15);
	l_invproc_rate_type		VARCHAR2(30);
	l_invproc_rate_date		DATE;
	l_invproc_exchange_rate		NUMBER;
	l_invproc_allocated_amount	NUMBER;

	l_revproc_currency_code	        VARCHAR2(15);
	l_revproc_rate_type		VARCHAR2(30);
	l_revproc_rate_date		DATE;
	l_revproc_exchange_rate		NUMBER;
	l_revproc_allocated_amount	NUMBER;
  BEGIN

    --dbms_output.put_line('Inside: pa_funding_core.create_funding');

    --dbms_output.put_line(   p_Project_Funding_Id);
    --dbms_output.put_line(   p_Last_Update_Date );
    --dbms_output.put_line(   p_Last_Updated_By);
    --dbms_output.put_line(   p_Creation_Date);
    --dbms_output.put_line(   p_Created_By);
    --dbms_output.put_line(   p_Last_Update_Login);
    --dbms_output.put_line(   p_Agreement_Id);
    --dbms_output.put_line(   p_Project_Id);
    --dbms_output.put_line(nvl(to_char(p_Task_Id),'NULL'));
    --dbms_output.put_line(   p_Allocated_Amount);
    --dbms_output.put_line(   p_Date_Allocated);

    --dbms_output.put_line('Inside: pa_funding_core.create_funding inserting row');

   x_err_code := 0;
   x_err_msg  := NULL;

   l_project_rate_type	    := p_project_rate_type;
   l_project_rate_date	    := p_project_rate_date;
   l_project_exchange_rate   := p_project_exchange_rate;
   l_projfunc_rate_type	    := p_projfunc_rate_type;
   l_projfunc_rate_date	    := p_projfunc_rate_date;
   l_projfunc_exchange_rate  := p_projfunc_exchange_rate;


   get_MCB2_attributes (
 	    p_project_id		   =>   p_project_id,
	    p_agreement_id		   =>	p_agreement_id,
	    p_date_allocated		   =>   p_date_allocated,
	    p_allocated_amount		   =>   p_allocated_amount,
            p_funding_currency_code	   =>   l_funding_currency_code,
	    p_project_currency_code	   =>   l_project_currency_code,
      	    p_project_rate_type		   =>   l_project_rate_type,
	    p_project_rate_date		   =>   l_project_rate_date,
	    p_project_exchange_rate	   =>   l_project_exchange_rate,
	    p_project_allocated_amount	   =>	l_project_allocated_amount,
	    p_projfunc_currency_code	   =>   l_projfunc_currency_code,
	    p_projfunc_rate_type	   =>   l_projfunc_rate_type,
	    p_projfunc_rate_date	   =>   l_projfunc_rate_date,
	    p_projfunc_exchange_rate	   =>   l_projfunc_exchange_rate,
	    p_projfunc_allocated_amount	   =>	l_projfunc_allocated_amount,
            p_invproc_currency_code	   =>   l_invproc_currency_code,
            p_invproc_rate_type		   =>   l_invproc_rate_type,
	    p_invproc_rate_date		   =>   l_invproc_rate_date,
	    p_invproc_exchange_rate	   =>   l_invproc_exchange_rate,
	    p_invproc_allocated_amount	   =>	l_invproc_allocated_amount,
	    p_revproc_currency_code	   =>   l_revproc_currency_code,
            p_revproc_rate_type		   =>   l_revproc_rate_type,
	    p_revproc_rate_date		   =>   l_revproc_rate_date,
	    p_revproc_exchange_rate	   =>   l_revproc_exchange_rate,
	    p_revproc_allocated_amount	   =>	l_revproc_allocated_amount,
            p_validate_parameters          =>   'Y',
            x_err_code                     =>   l_err_code,
            x_err_msg                      =>   l_err_msg
	    );

   x_err_code := l_err_code;
   x_err_msg := l_err_msg;

   if x_err_code = 0 then

       pa_project_fundings_pkg.insert_row(
	    x_rowid			   =>	p_rowid,
	    x_project_funding_id	   =>	p_project_funding_id,
	    x_last_update_date		   =>	p_last_update_date,
	    x_last_updated_by		   =>	p_last_updated_by,
	    x_creation_date		   =>	p_creation_date,
	    x_created_by		   =>	p_created_by,
	    x_last_update_login		   =>	p_last_update_login,
	    x_agreement_id		   =>	p_agreement_id,
	    x_project_id		   =>	p_project_id,
	    x_task_id			   =>	p_task_id,
	    x_budget_type_code		   =>	p_budget_type_code,
	    x_allocated_amount		   =>	p_allocated_amount,
	    x_date_allocated		   =>	p_date_allocated,
	    X_Control_Item_ID		   =>   p_Control_Item_ID,    -- FP_M changes
	    x_attribute_category	   =>	p_attribute_category,
	    x_attribute1		   =>	p_attribute1,
	    x_attribute2		   =>	p_attribute2,
	    x_attribute3		   =>	p_attribute3,
	    x_attribute4		   =>	p_attribute4,
	    x_attribute5		   =>	p_attribute5,
	    x_attribute6		   =>	p_attribute6,
	    x_attribute7		   =>	p_attribute7,
	    x_attribute8		   =>	p_attribute8,
	    x_attribute9		   =>	p_attribute9,
	    x_attribute10		   =>	p_attribute10,
	    x_pm_funding_reference	   =>	p_pm_funding_reference,
	    x_pm_product_code		   =>	p_pm_product_code,
            x_funding_currency_code	   =>   l_funding_currency_code,
	    x_project_currency_code	   =>   l_project_currency_code,
      	    x_project_rate_type		   =>   l_project_rate_type,
	    x_project_rate_date		   =>   l_project_rate_date,
	    x_project_exchange_rate	   =>   l_project_exchange_rate,
	    x_project_allocated_amount	   =>	l_project_allocated_amount,
	    x_projfunc_currency_code	   =>   l_projfunc_currency_code,
	    x_projfunc_rate_type	   =>   l_projfunc_rate_type,
	    x_projfunc_rate_date	   =>   l_projfunc_rate_date,
	    x_projfunc_exchange_rate	   =>   l_projfunc_exchange_rate,
	    x_projfunc_allocated_amount	   =>	l_projfunc_allocated_amount,
            x_invproc_currency_code	   =>   l_invproc_currency_code,
            x_invproc_rate_type		   =>   l_invproc_rate_type,
	    x_invproc_rate_date		   =>   l_invproc_rate_date,
	    x_invproc_exchange_rate	   =>   l_invproc_exchange_rate,
	    x_invproc_allocated_amount	   =>	l_invproc_allocated_amount,
	    x_revproc_currency_code	   =>   l_revproc_currency_code,
            x_revproc_rate_type		   =>   l_revproc_rate_type,
	    x_revproc_rate_date		   =>   l_revproc_rate_date,
	    x_revproc_exchange_rate	   =>   l_revproc_exchange_rate,
	    x_revproc_allocated_amount	   =>	l_revproc_allocated_amount,
            x_funding_category             =>   p_funding_category  /* For Bug2244796 */
	);

   end if;

    --dbms_output.put_line('Done: create_funding');
    -- summary_funding.insert_row;
EXCEPTION

   WHEN OTHERS THEN
   --dbms_output.put_line(SQLERRM);
	-- Null added by johnson P
      x_err_code := SQLCODE;
      x_err_msg   := SQLERRM;
      p_Project_Funding_Id := l_Project_Funding_Id;

END create_funding;

--
--Name:                 update_funding
--Type:                 PROCEDURE
--Description:          This procedure is used to create a funding record in PA_PROJECT_FUNDINGS
--Called subprograms:   pa_project_fundings_pkg.update_row
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--                      15-MAY-2000     Created         Nikhil Mishra.

  PROCEDURE Update_funding(
	    p_Project_Funding_Id      IN     NUMBER,
            p_Last_Update_Date	      IN     DATE,
            p_Last_Updated_By	      IN     NUMBER,
            p_Last_Update_Login	      IN     NUMBER,
            p_Agreement_Id	      IN     NUMBER,
            p_Project_Id	      IN     NUMBER,
            p_Task_id		      IN     NUMBER,
            p_Budget_Type_Code	      IN     VARCHAR2,
            p_Allocated_Amount	      IN     NUMBER,
            p_Date_Allocated	      IN     DATE,
            p_Attribute_Category      IN     VARCHAR2,
            p_Attribute1	      IN     VARCHAR2,
            p_Attribute2	      IN     VARCHAR2,
            p_Attribute3	      IN     VARCHAR2,
            p_Attribute4	      IN     VARCHAR2,
            p_Attribute5	      IN     VARCHAR2,
            p_Attribute6	      IN     VARCHAR2,
            p_Attribute7	      IN     VARCHAR2,
            p_Attribute8	      IN     VARCHAR2,
            p_Attribute9	      IN     VARCHAR2,
            p_Attribute10	      IN     VARCHAR2,
            p_pm_funding_reference    IN     VARCHAR2,
            p_pm_product_code	      IN     VARCHAR2,
	    p_project_rate_type	      IN     VARCHAR2	DEFAULT NULL,
	    p_project_rate_date	      IN     DATE	DEFAULT NULL,
	    p_project_exchange_rate   IN     NUMBER	DEFAULT	NULL,
	    p_projfunc_rate_type      IN     VARCHAR2	DEFAULT NULL,
	    p_projfunc_rate_date      IN     DATE	DEFAULT NULL,
	    p_projfunc_exchange_rate  IN     NUMBER	DEFAULT	NULL,
            x_err_code                OUT    NOCOPY NUMBER,/*File.sql.39*/
            x_err_msg                 OUT    NOCOPY VARCHAR2,/*File.sql.39*/
            p_funding_category        IN     VARCHAR2     /* Bug 2244796 */

	)

IS
     CURSOR C IS
      SELECT
        rowid
      FROM PA_PROJECT_FUNDINGS
      WHERE project_funding_id = p_Project_Funding_Id;
      fun_rec C%ROWTYPE;
	l_funding_currency_code		VARCHAR2(15);
	l_project_currency_code		VARCHAR2(15);
	l_project_rate_type		VARCHAR2(30);
	l_project_rate_date		DATE;
	l_project_exchange_rate		NUMBER;
	l_project_allocated_amount	NUMBER;
	l_projfunc_currency_code	VARCHAR2(15);
	l_projfunc_rate_type		VARCHAR2(30);
	l_projfunc_rate_date		DATE;
	l_projfunc_exchange_rate	NUMBER;
	l_projfunc_allocated_amount	NUMBER;
	l_invproc_currency_code		VARCHAR2(15);
	l_invproc_rate_type		VARCHAR2(30);
	l_invproc_rate_date		DATE;
	l_invproc_exchange_rate		NUMBER;
	l_invproc_allocated_amount	NUMBER;
	l_revproc_currency_code		VARCHAR2(15);
	l_revproc_rate_type		VARCHAR2(30);
	l_revproc_rate_date		DATE;
	l_revproc_exchange_rate		NUMBER;
	l_revproc_allocated_amount	NUMBER;

        l_err_msg                       VARCHAR2(150);
        l_err_code                      NUMBER;
  BEGIN
      x_err_code := 0;
      x_err_msg  := NULL;

      OPEN C;
      FETCH C INTO fun_rec;
      IF C%FOUND THEN

         l_project_rate_type	    := p_project_rate_type;
         l_project_rate_date	    := p_project_rate_date;
         l_project_exchange_rate   := p_project_exchange_rate;
         l_projfunc_rate_type	    := p_projfunc_rate_type;
         l_projfunc_rate_date	    := p_projfunc_rate_date;
         l_projfunc_exchange_rate  := p_projfunc_exchange_rate;

         get_MCB2_attributes (
 	    p_project_id		   =>   p_project_id,
	    p_agreement_id		   =>	p_agreement_id,
	    p_date_allocated		   =>   p_date_allocated,
	    p_allocated_amount		   =>   p_allocated_amount,
            p_funding_currency_code	   =>   l_funding_currency_code,
	    p_project_currency_code	   =>   l_project_currency_code,
      	    p_project_rate_type		   =>   l_project_rate_type,
	    p_project_rate_date		   =>   l_project_rate_date,
	    p_project_exchange_rate	   =>   l_project_exchange_rate,
	    p_project_allocated_amount	   =>	l_project_allocated_amount,
	    p_projfunc_currency_code	   =>   l_projfunc_currency_code,
	    p_projfunc_rate_type	   =>   l_projfunc_rate_type,
	    p_projfunc_rate_date	   =>   l_projfunc_rate_date,
	    p_projfunc_exchange_rate	   =>   l_projfunc_exchange_rate,
	    p_projfunc_allocated_amount	   =>	l_projfunc_allocated_amount,
            p_invproc_currency_code	   =>   l_invproc_currency_code,
            p_invproc_rate_type		   =>   l_invproc_rate_type,
	    p_invproc_rate_date		   =>   l_invproc_rate_date,
	    p_invproc_exchange_rate	   =>   l_invproc_exchange_rate,
	    p_invproc_allocated_amount	   =>	l_invproc_allocated_amount,
	    p_revproc_currency_code	   =>   l_revproc_currency_code,
            p_revproc_rate_type		   =>   l_revproc_rate_type,
	    p_revproc_rate_date		   =>   l_revproc_rate_date,
	    p_revproc_exchange_rate	   =>   l_revproc_exchange_rate,
	    p_revproc_allocated_amount	   =>	l_revproc_allocated_amount,
            p_validate_parameters          =>   'Y',
            x_err_code                     =>   l_err_code,
            x_err_msg                       =>  l_err_msg
	    );
     x_err_code := l_err_code;
     x_err_msg := l_err_msg;

     if x_err_code = 0 then
        pa_project_fundings_pkg.update_row(
	    x_rowid			   =>	fun_rec.rowid,
	    x_project_funding_id	   =>	p_project_funding_id,
	    x_last_update_date		   =>	p_last_update_date,
	    x_last_updated_by		   =>	p_last_updated_by,
	    x_last_update_login		   =>	p_last_update_login,
	    x_agreement_id		   =>	p_agreement_id,
	    x_project_id		   =>	p_project_id,
	    x_task_id			   =>	p_task_id,
	    x_budget_type_code		   =>	p_budget_type_code,
	    x_allocated_amount		   =>	p_allocated_amount,
	    x_date_allocated		   =>	p_date_allocated,
	    x_attribute_category	   =>	p_attribute_category,
	    x_attribute1		   =>	p_attribute1,
	    x_attribute2		   =>	p_attribute2,
	    x_attribute3		   =>	p_attribute3,
	    x_attribute4		   =>	p_attribute4,
	    x_attribute5		   =>	p_attribute5,
	    x_attribute6		   =>	p_attribute6,
	    x_attribute7		   =>	p_attribute7,
	    x_attribute8		   =>	p_attribute8,
	    x_attribute9		   =>	p_attribute9,
	    x_attribute10		   =>	p_attribute10,
	    x_pm_funding_reference	   =>	p_pm_funding_reference,
	    x_pm_product_code		   =>	p_pm_product_code,
            x_funding_currency_code	   =>   l_funding_currency_code,
	    x_project_currency_code	   =>   l_project_currency_code,
      	    x_project_rate_type		   =>   l_project_rate_type,
	    x_project_rate_date		   =>   l_project_rate_date,
	    x_project_exchange_rate	   =>   l_project_exchange_rate,
	    x_project_allocated_amount	   =>	l_project_allocated_amount,
	    x_projfunc_currency_code	   =>   l_projfunc_currency_code,
	    x_projfunc_rate_type	   =>   l_projfunc_rate_type,
	    x_projfunc_rate_date	   =>   l_projfunc_rate_date,
	    x_projfunc_exchange_rate	   =>   l_projfunc_exchange_rate,
	    x_projfunc_allocated_amount	   =>	l_projfunc_allocated_amount,
            x_invproc_currency_code	   =>   l_invproc_currency_code,
            x_invproc_rate_type		   =>   l_invproc_rate_type,
	    x_invproc_rate_date		   =>   l_invproc_rate_date,
	    x_invproc_exchange_rate	   =>   l_invproc_exchange_rate,
	    x_invproc_allocated_amount	   =>	l_invproc_allocated_amount,
	    x_revproc_currency_code	   =>   l_revproc_currency_code,
            x_revproc_rate_type		   =>   l_revproc_rate_type,
	    x_revproc_rate_date		   =>   l_revproc_rate_date,
	    x_revproc_exchange_rate	   =>   l_revproc_exchange_rate,
	    x_revproc_allocated_amount	   =>	l_revproc_allocated_amount,
            x_funding_category             =>   p_funding_category   /* Bug 2244796 */
	);

       END IF;

    END IF;
    CLOSE C;
    -- summary_funding.update_row;

 EXCEPTION

   WHEN OTHERS THEN
   --dbms_output.put_line(SQLERRM);
      x_err_code := SQLCODE;
      x_err_msg   := SQLERRM;


  END update_funding;

--
--Name:                 delete_funding
--Type:                 PROCEDURE
--Description:          This procedure is used to delete a funding record in PA_PROJECT_FUNDINGS
--Called subprograms:   pa_project_fundings_pkg.delete_row
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--                      15-MAY-2000     Created         Nikhil Mishra

  PROCEDURE Delete_funding(p_project_funding_id IN NUMBER)
  is
     CURSOR C IS
      SELECT rowid
      FROM PA_PROJECT_FUNDINGS
      WHERE project_funding_id = p_project_funding_id;
      fun_row_id  VARCHAR2(2000);
  BEGIN
   OPEN C;
      FETCH C INTO fun_row_id;
       IF C%FOUND THEN
--dbms_output.put_line('yes');
	    pa_project_fundings_pkg.delete_row(fun_row_id);
	END IF;
    CLOSE C;
  END delete_funding;
--
--Name:                 lock_funding
--Type:                 PROCEDURE
--Description:          This procedure is used to lock a funding record in PA_PROJECT_FUNDINGS
--Called subprograms:   pa_project_fundings_pkg.lock_row
--
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--                      15-MAY-2000     Created         Nikhil Mishra


  PROCEDURE Lock_funding
  (p_Project_Funding_Id IN NUMBER)
  is
 CURSOR C IS
      SELECT  rowid,
      project_funding_id,
      agreement_id,
      project_id,
      task_id,
      budget_type_code,
      allocated_amount,
      date_allocated,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      pm_funding_reference,
      pm_product_code,
      funding_currency_code, project_currency_code, project_rate_type,
      project_rate_date, project_exchange_rate, project_allocated_amount,
      projfunc_currency_code, projfunc_rate_type, projfunc_rate_date,
      projfunc_exchange_rate, projfunc_allocated_amount,
      funding_category   /* For Bug2244796 */
      FROM PA_PROJECT_FUNDINGS
      WHERE project_funding_id = p_Project_Funding_Id;
      fun_rec C%ROWTYPE;
  BEGIN
     OPEN C;
      FETCH C INTO fun_rec;
      IF C%FOUND THEN
    pa_project_fundings_pkg.lock_row(
      fun_rec.rowid,
      fun_rec.project_funding_id,
      fun_rec.agreement_id,
      fun_rec.project_id,
      fun_rec.task_id,
      fun_rec.budget_type_code,
      fun_rec.allocated_amount,
      fun_rec.date_allocated,
      fun_rec.attribute_category,
      fun_rec.attribute1,
      fun_rec.attribute2,
      fun_rec.attribute3,
      fun_rec.attribute4,
      fun_rec.attribute5,
      fun_rec.attribute6,
      fun_rec.attribute7,
      fun_rec.attribute8,
      fun_rec.attribute9,
      fun_rec.attribute10,
      fun_rec.pm_funding_reference,
      fun_rec.pm_product_code,
      fun_rec.funding_currency_code,
      fun_rec.project_currency_code,
      fun_rec.project_rate_type,
      fun_rec.project_rate_date,
      fun_rec.project_exchange_rate,
      fun_rec.project_allocated_amount,
      fun_rec.projfunc_currency_code,
      fun_rec.projfunc_rate_type,
      fun_rec.projfunc_rate_date,
      fun_rec.projfunc_exchange_rate,
      fun_rec.projfunc_allocated_amount,
      fun_rec.funding_category      /* For Bug2244796 */
);
      END IF;
    CLOSE C;
  END lock_funding;
--
--Name:                summary_funding_insert_row
--Type: 		Procedure
--Description: 	This procedure inserts row(s) in to PA_SUMMARY_PROJECT_FUNDINGS.
--
--Called subprograms:   summary_fundings_update_row
--
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--                      21-AUG-2000     Modified        Srividya.
--                         Added all columns corresponding to MCB2
--

PROCEDURE summary_funding_insert_row
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_login_id			IN	VARCHAR2
 ,p_user_id			IN	VARCHAR2
 ,p_budget_type_code		IN	VARCHAR2
 )
IS
BEGIN
declare
      cursor c1 is
      	select 1
      	from pa_summary_project_fundings
      	where project_id = p_project_id
      	and agreement_id = p_agreement_id
      	and nvl(task_id, 0) = nvl(p_task_id, 0);
      dummy number;

    BEGIN

      open c1;
      fetch c1 into dummy;

      IF (c1%found) THEN
        pa_funding_core.summary_funding_update_row (	p_agreement_id
 					,p_project_id
 					,p_task_id
 					,p_login_id
 					,p_user_id
					,p_budget_type_code
 				    );


      ELSE

        INSERT INTO PA_SUMMARY_PROJECT_FUNDINGS
	   (AGREEMENT_ID, PROJECT_ID, TASK_ID,
            TOTAL_BASELINED_AMOUNT, TOTAL_UNBASELINED_AMOUNT,
            TOTAL_ACCRUED_AMOUNT, TOTAL_BILLED_AMOUNT,
            LAST_UPDATE_LOGIN, LAST_UPDATE_DATE, LAST_UPDATED_BY,
	    CREATION_DATE, CREATED_BY, FUNDING_CURRENCY_CODE,
	    PROJECT_CURRENCY_CODE, PROJECT_BASELINED_AMOUNT,
	    PROJECT_UNBASELINED_AMOUNT, PROJECT_ACCRUED_AMOUNT,
	    PROJECT_BILLED_AMOUNT,
	    PROJFUNC_CURRENCY_CODE, PROJFUNC_BASELINED_AMOUNT,
	    PROJFUNC_UNBASELINED_AMOUNT, PROJFUNC_ACCRUED_AMOUNT,
	    PROJFUNC_BILLED_AMOUNT,
	    INVPROC_CURRENCY_CODE, INVPROC_BASELINED_AMOUNT,
	    INVPROC_UNBASELINED_AMOUNT,
	    INVPROC_BILLED_AMOUNT,
	    REVPROC_CURRENCY_CODE, REVPROC_BASELINED_AMOUNT,
	    REVPROC_UNBASELINED_AMOUNT, REVPROC_ACCRUED_AMOUNT)
        SELECT AGREEMENT_ID,PROJECT_ID,TASK_ID,
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'BASELINE',
				NVL(ALLOCATED_AMOUNT,0))),0),
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'DRAFT',
				NVL(ALLOCATED_AMOUNT,0))),0),
	       0, 0, p_login_id, trunc(SYSDATE), p_user_id,
	       trunc(SYSDATE), p_user_id, FUNDING_CURRENCY_CODE,
	       PROJECT_CURRENCY_CODE,
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'BASELINE',
				NVL(PROJECT_ALLOCATED_AMOUNT,0))),0),
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'DRAFT',
				NVL(PROJECT_ALLOCATED_AMOUNT,0))),0),
	       0, 0,
	       PROJFUNC_CURRENCY_CODE,
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'BASELINE',
				NVL(PROJFUNC_ALLOCATED_AMOUNT,0))),0),
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'DRAFT',
				NVL(PROJFUNC_ALLOCATED_AMOUNT,0))),0),
	       0, 0,
	       INVPROC_CURRENCY_CODE,
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'BASELINE',
				NVL(INVPROC_ALLOCATED_AMOUNT,0))),0),
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'DRAFT',
				NVL(INVPROC_ALLOCATED_AMOUNT,0))),0),
	       0,
	       REVPROC_CURRENCY_CODE,
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'BASELINE',
				NVL(REVPROC_ALLOCATED_AMOUNT,0))),0),
	       NVL(SUM(DECODE(BUDGET_TYPE_CODE,'DRAFT',
				NVL(REVPROC_ALLOCATED_AMOUNT,0))),0),
	       0
        FROM PA_PROJECT_FUNDINGS
        WHERE BUDGET_TYPE_CODE IN ('BASELINE','DRAFT')
        AND PROJECT_ID = p_project_id
        AND AGREEMENT_ID = p_agreement_id
        AND NVL(TASK_ID,0) = NVL(p_task_id,0)
        AND NOT EXISTS
	    (select NULL from PA_SUMMARY_PROJECT_FUNDINGS S
	     WHERE s.PROJECT_ID = p_project_id
	     AND s.AGREEMENT_ID = p_agreement_id
	     AND NVL(s.TASK_ID,0) = NVL(p_task_id,0))
        GROUP BY AGREEMENT_ID,PROJECT_ID,TASK_ID,FUNDING_CURRENCY_CODE,
	      PROJECT_CURRENCY_CODE, PROJFUNC_CURRENCY_CODE,
	      INVPROC_CURRENCY_CODE, REVPROC_CURRENCY_CODE
;
      END IF;
      close c1;
    exception
      WHEN NO_DATA_FOUND THEN
	pa_funding_core.summary_funding_update_row (	p_agreement_id
 					,p_project_id
 					,p_task_id
 					,p_login_id
 					,p_user_id
					,p_budget_type_code
				    );
      WHEN OTHERS THEN
	raise ;

    end;
END summary_funding_insert_row;


--
--Name:                 summary_fundings_update_row
--Type:                 Procedure
--Description:          This procedure updates row(s) in to PA_SUMMARY_PROJECT_FUNDINGS.
--
--Called subprograms:   pa_agreement_utils.summary_fundings_insert_row
--
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--                      21-AUG-2000     Modified        Srividya.
--                         Added all columns corresponding to MCB2
--
PROCEDURE summary_funding_update_row
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_login_id			IN	VARCHAR2
 ,p_user_id			IN	VARCHAR2
 ,p_budget_type_code		IN	VARCHAR2
 )
IS
BEGIN
	--dbms_output.put_line('Inside: PA_AGREEMENT_CORE.SUMMARY_FUNDING_UPDATE_ROW');
        IF (p_budget_type_code = 'DRAFT') THEN

           UPDATE PA_SUMMARY_PROJECT_FUNDINGS S
           SET (S.TOTAL_UNBASELINED_AMOUNT, S.PROJECT_UNBASELINED_AMOUNT,
	        S.PROJFUNC_UNBASELINED_AMOUNT,
           S.INVPROC_UNBASELINED_AMOUNT, S.REVPROC_UNBASELINED_AMOUNT) =
                (SELECT SUM(DECODE(F.BUDGET_TYPE_CODE, 'BASELINE',0,
                       'DRAFT',nvl(F.ALLOCATED_AMOUNT,0))),
		       SUM(DECODE(F.BUDGET_TYPE_CODE, 'BASELINE',0,
                       'DRAFT',nvl(F.PROJECT_ALLOCATED_AMOUNT,0))),
		       SUM(DECODE(F.BUDGET_TYPE_CODE, 'BASELINE',0,
                       'DRAFT',nvl(F.PROJFUNC_ALLOCATED_AMOUNT,0))),
		       SUM(DECODE(F.BUDGET_TYPE_CODE, 'BASELINE',0,
                       'DRAFT',nvl(F.INVPROC_ALLOCATED_AMOUNT,0))),
		       SUM(DECODE(F.BUDGET_TYPE_CODE, 'BASELINE',0,
                       'DRAFT',nvl(F.REVPROC_ALLOCATED_AMOUNT,0)))
                 FROM PA_PROJECT_FUNDINGS F
                 WHERE F.PROJECT_ID = S.PROJECT_ID
                 AND F.AGREEMENT_ID = S.AGREEMENT_ID
                 AND NVL(F.TASK_ID,0) = NVL(S.TASK_ID,0)
                 GROUP BY F.AGREEMENT_ID, F.PROJECT_ID, F.TASK_ID)
                 WHERE S.AGREEMENT_ID = p_agreement_id
                 AND S.PROJECT_ID =   p_project_id
                 AND NVL(S.TASK_ID,0) = NVL(p_task_id,0);

           IF (SQL%NOTFOUND) THEN

		pa_funding_core.summary_funding_insert_row (	p_agreement_id
 						,p_project_id
 						,p_task_id
 						,p_login_id
 						,p_user_id
						,p_budget_type_code
	 				    );

           END IF;
        END IF;

END summary_funding_update_row;

--
--Name:                 summary_funding_delete_row
--Type:                 Procedure
--Description:          This procedure deletes row(s) in to PA_SUMMARY_PROJECT_FUNDINGS.
--
--Called subprograms:   summary_fundings_insert_row
--
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

PROCEDURE summary_funding_delete_row
(p_agreement_id                 IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_login_id			IN	VARCHAR2
 ,p_user_id			IN	VARCHAR2
 ,p_budget_type_code		IN	VARCHAR2
 )
IS
BEGIN
declare
      dummy	number;

      cursor d1 is
	select 1
	from pa_project_fundings
	where project_id = p_project_id
	and nvl(task_id, 0) = nvl(p_task_id, 0)
	and agreement_id = p_agreement_id;
    BEGIN
      open d1;
      fetch d1 into dummy;
      IF d1%found THEN
		pa_funding_core.summary_funding_update_row (	p_agreement_id
 						,p_project_id
 						,p_task_id
 						,p_login_id
 						,p_user_id
						,p_budget_type_code
	 				    );

      ELSE
    	DELETE FROM PA_SUMMARY_PROJECT_FUNDINGS S
    	WHERE S.PROJECT_ID = p_project_id
    	AND S.AGREEMENT_ID  =  p_agreement_id
    	AND NVL(S.TASK_ID,0) = NVL(p_task_id,0);
      END IF;
      close d1;
    end;

  exception
    WHEN OTHERS THEN
	raise ;
END summary_funding_delete_row;

/*============================================================================+
| Name         : check_valid_exch_rate
| Type:        : FUNCTION
| Description  : This function will return
|                "T" - if rate type is invalid
|                "R" - if rate is invalid
|                "Y" - if both are valid
|                Created for MCB2
+============================================================================*/


FUNCTION check_valid_exch_rate (
         p_funding_currency_code         IN     VARCHAR2,
         p_to_currency_code              IN     VARCHAR2,
	 p_exchange_rate_type		 IN	VARCHAR2,
	 p_exchange_rate		 IN	NUMBER,
         p_exchange_rate_date            IN     DATE) RETURN VARCHAR2 IS

	 l_valid_rate_type		 VARCHAR2(1);

BEGIN


        SELECT 'Y' INTO l_valid_rate_type
        from pa_conversion_types_v
/*      WHERE user_conversion_type = p_exchange_rate_type  Commented for bug 5478703 */
        WHERE conversion_type = p_exchange_rate_type      /* Added for bug 5478703 */
        AND (    (p_exchange_rate_type = 'User'
                  AND pa_multi_currency.is_user_rate_type_allowed(
                      p_funding_currency_code,
                      p_to_currency_code,
                      p_exchange_rate_date )= 'Y')
              OR p_exchange_rate_type <> 'User');

/*
	SELECT 'Y' INTO l_valid_rate_type
	from pa_conversion_types_v
	WHERE user_conversion_type = p_exchange_rate_type;
*/
	IF p_exchange_rate_type = 'User' THEN
	   IF p_exchange_rate is NULL then
	      return 'R';
	   END IF;
	END IF;

        RETURN ('Y');
EXCEPTION
	WHEN OTHERS THEN
	     RETURN 'T';

END check_valid_exch_rate;
/*============================================================================+
| Name         : get_MCB2_attributes
| Type:        : PROCEDURE
| Description  : This function will derive all MCB2 computed values based on
|                input parameters
|                Created for MCB2
+============================================================================*/

PROCEDURE   get_MCB2_attributes (
 	    p_project_id		IN	NUMBER,
	    p_agreement_id		IN	NUMBER,
	    p_date_allocated		IN	DATE,
	    p_allocated_amount		IN	NUMBER,
            p_funding_currency_code	IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
	    p_project_currency_code	IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
      	    p_project_rate_type		IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
	    p_project_rate_date		IN OUT  NOCOPY DATE,/*file.sql.39*/
	    p_project_exchange_rate	IN OUT  NOCOPY NUMBER,/*file.sql.39*/
	    p_project_allocated_amount	IN OUT  NOCOPY NUMBER,/*file.sql.39*/
	    p_projfunc_currency_code	IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
	    p_projfunc_rate_type	IN OUT	NOCOPY VARCHAR2,     /*file.sql.39*/
	    p_projfunc_rate_date	IN OUT	NOCOPY DATE,/*file.sql.39*/
	    p_projfunc_exchange_rate	IN OUT	NOCOPY NUMBER,/*file.sql.39*/
	    p_projfunc_allocated_amount	IN OUT	NOCOPY NUMBER,/*file.sql.39*/
            p_invproc_currency_code	IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
            p_invproc_rate_type		IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
	    p_invproc_rate_date		IN OUT  NOCOPY DATE,/*file.sql.39*/
	    p_invproc_exchange_rate	IN OUT  NOCOPY NUMBER,/*file.sql.39*/
	    p_invproc_allocated_amount	IN OUT	NOCOPY NUMBER,/*file.sql.39*/
	    p_revproc_currency_code	IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
            p_revproc_rate_type		IN OUT  NOCOPY VARCHAR2,/*file.sql.39*/
	    p_revproc_rate_date		IN OUT  NOCOPY DATE,/*file.sql.39*/
	    p_revproc_exchange_rate	IN OUT  NOCOPY NUMBER,/*file.sql.39*/
	    p_revproc_allocated_amount	IN OUT	NOCOPY NUMBER,/*file.sql.39*/
            p_validate_parameters       IN      VARCHAR2 DEFAULT 'N',
            x_err_code                  OUT     NOCOPY NUMBER,/*file.sql.39*/
            x_err_msg                   OUT     NOCOPY VARCHAR2/*file.sql.39*/
	    ) is

	l_multi_currency_billing_flag	VARCHAR2(1);
	l_baseline_funding_flag		VARCHAR2(1);
	l_funding_rate_date_code	VARCHAR2(30);
	l_funding_rate_type		VARCHAR2(30);
	l_funding_rate_date		DATE;
	l_funding_exchange_rate		NUMBER;

	l_project_rate_date_code	VARCHAR2(30);
	l_project_rate_type		VARCHAR2(30);
	l_project_rate_date		DATE;
	l_project_exchange_rate		NUMBER;
	l_project_allocated_amount	NUMBER;

	l_projfunc_rate_date_code	VARCHAR2(30);
	l_projfunc_rate_type		VARCHAR2(30);
	l_projfunc_rate_date		DATE;
	l_projfunc_exchange_rate	NUMBER;
	l_projfunc_allocated_amount	NUMBER;

	l_invproc_currency_type		VARCHAR2(30);
	l_invproc_rate_type		VARCHAR2(30);
	l_invproc_rate_date		DATE;
	l_invproc_exchange_rate		NUMBER;
	l_invproc_allocated_amount	NUMBER;

	l_revproc_rate_type		VARCHAR2(30);
	l_revproc_rate_date		DATE;
	l_revproc_exchange_rate		NUMBER;
	l_revproc_allocated_amount	NUMBER;

	l_return_status			VARCHAR2(50);
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(250);

	l_denominator	                NUMBER;
	l_numerator	                NUMBER;
        l_validate                      VARCHAR2(1) := 'N';
        l_is_rate_type_valid            VARCHAR2(1) := 'Y';


        l_err_code                      NUMBER;
        l_err_msg                       VARCHAR2(150);

        l_mult_funding_flag             VARCHAR2(1);

/*File.sql.39 . np variables are nocopy dummy variables define to
revert the changes for any failure*/
            np_p_funding_currency_code     VARCHAR2(50) := p_funding_currency_code;
            np_p_project_currency_code     VARCHAR2(50) := p_project_currency_code;
            np_p_project_rate_type         VARCHAR2(50) := p_project_rate_type;
            np_p_project_rate_date         DATE         := p_project_rate_date;
            np_p_project_exchange_rate     NUMBER       := p_project_exchange_rate;
            np_p_project_allocated_amount  NUMBER       := p_project_allocated_amount;
            np_p_projfunc_currency_code    VARCHAR2(50) := p_projfunc_currency_code;
            np_p_projfunc_rate_type        VARCHAR2(50) := p_projfunc_rate_type;
            np_p_projfunc_rate_date        DATE         := p_projfunc_rate_date;
            np_p_projfunc_exchange_rate    NUMBER       := p_projfunc_exchange_rate;
            np_p_projfunc_allocated_amount NUMBER       := p_projfunc_allocated_amount;
            np_p_invproc_currency_code     VARCHAR2(50) := p_invproc_currency_code;
            np_p_invproc_rate_type         VARCHAR2(50) := p_invproc_rate_type;
            np_p_invproc_rate_date         DATE         := p_invproc_rate_date;
            np_p_invproc_exchange_rate     NUMBER       := p_invproc_exchange_rate;
            np_p_invproc_allocated_amount  NUMBER       := p_invproc_allocated_amount;
            np_p_revproc_currency_code     VARCHAR2(50) := p_revproc_currency_code;
            np_p_revproc_rate_type         VARCHAR2(50) := p_revproc_rate_type;
            np_p_revproc_rate_date         DATE         := p_revproc_rate_date;
            np_p_revproc_exchange_rate     NUMBER       := p_revproc_exchange_rate;
            np_p_revproc_allocated_amount  NUMBER       := p_revproc_allocated_amount;
BEGIN

        x_err_code := 0;
        x_err_msg := NULL;
	p_funding_currency_code :=
	  pa_agreement_utils.get_agr_curr_code(p_agreement_id);

     /* Added for bug 5478703 */
        IF p_project_rate_type is not null
         THEN
             SELECT conversion_type
               INTO p_project_rate_type
               FROM pa_conversion_types_v
              WHERE user_conversion_type = p_project_rate_type
                 or conversion_type = p_project_rate_type;
         END IF;

          IF p_projfunc_rate_type is not null
                THEN
                 SELECT conversion_type
                   INTO p_projfunc_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_projfunc_rate_type
                     or conversion_type = p_projfunc_rate_type;
           END IF;
        /* bug 5478703 - Code change Ends here*/

	pa_multi_currency_billing.get_project_defaults(
	   p_project_id			 => p_project_id,
	   x_multi_currency_billing_flag => l_multi_currency_billing_flag,
	   x_baseline_funding_flag	 => l_baseline_funding_flag,
	   x_revproc_currency_code	 => p_revproc_currency_code,
	   x_invproc_currency_type	 => l_invproc_currency_type,
	   x_invproc_currency_code	 => p_invproc_currency_code,
	   x_project_currency_code	 => p_project_currency_code,
	   x_project_bil_rate_date_code	 => l_project_rate_date_code,
	   x_project_bil_rate_type	 => l_project_rate_type,
	   x_project_bil_rate_date	 => l_project_rate_date,
	   x_project_bil_exchange_rate	 => l_project_exchange_rate,
	   x_projfunc_currency_code	 => p_projfunc_currency_code,
	   x_projfunc_bil_rate_date_code => l_projfunc_rate_date_code,
	   x_projfunc_bil_rate_type	 => l_projfunc_rate_type,
	   x_projfunc_bil_rate_date	 => l_projfunc_rate_date,
	   x_projfunc_bil_exchange_rate	 => l_projfunc_exchange_rate,
	   x_funding_rate_date_code	 => l_funding_rate_date_code,
	   x_funding_rate_type		 => l_funding_rate_type,
	   x_funding_rate_date		 => l_funding_rate_date,
	   x_funding_exchange_rate	 => l_funding_exchange_rate,
	   x_return_status		 => l_return_status,
	   x_msg_count			 => l_msg_count,
	   x_msg_data			 => l_msg_data);

           if l_return_status <> FND_API.G_RET_STS_SUCCESS then

              x_err_code := 30;
              x_err_msg   := l_msg_data;

           end if;

	/* Source and destination currency are same so null out attributes and copy amount */

        if x_err_code = 0 then

           if l_invproc_currency_type = 'FUNDING_CURRENCY' THEN

             if p_invproc_currency_code is null then

                p_invproc_currency_code := p_funding_currency_code;

             end if;

             l_mult_funding_flag := 'N';

             BEGIN

                 SELECT 'Y' into l_mult_funding_flag
                 FROM dual
                 WHERE exists ( select null
                                FROM PA_SUMMARY_PROJECT_FUNDINGS spf
                                WHERE spf.project_id = p_project_id
                                AND spf.funding_currency_code <> p_funding_currency_code
                                AND spf.total_baselined_amount <> 0
                                AND spf.total_unbaselined_amount <> 0);

             EXCEPTION

                  when no_data_found then

                       l_mult_funding_flag := 'N';

             END;


             if l_mult_funding_flag = 'Y' then

                x_err_code := 30;
                x_err_msg   := 'PA_MULTPLE_FUNDING_CURR';

             end if;

           end if;

        end if;

        if x_err_code = 0 then

           if p_funding_currency_code = p_project_currency_code then
	      p_project_rate_type :=  null;
	      p_project_rate_date := null;
	      p_project_exchange_rate := null;
	      p_project_allocated_amount := p_allocated_amount;

	   else

              if p_validate_parameters = 'Y' and p_project_rate_type is not null then

                 l_validate := 'Y';

              end if;

	      p_project_rate_type := nvl(p_project_rate_type, l_project_rate_type);
	      p_project_exchange_rate := nvl(p_project_exchange_rate,
					   l_project_exchange_rate);
              if p_project_rate_date is null then

	         if l_project_rate_date_code = 'FIXED_DATE' then
		    p_project_rate_date := l_project_rate_date;
	         else
		    p_project_rate_date := p_date_allocated;
	         end if;
	      end if;

              if l_validate = 'Y' then

                 l_is_rate_type_valid := check_valid_exch_rate (
                          p_funding_currency_code => p_funding_currency_code,
	                  p_to_currency_code	  => p_project_currency_code,
                          p_exchange_rate_type    => p_project_rate_type,
                          p_exchange_rate_date    => p_project_rate_date,
                          p_exchange_rate         => p_project_exchange_rate);

                 if l_is_rate_type_valid = 'R' then

                     x_err_code := '30';
                     x_err_msg   := 'PA_EXCH_RATE_NULL_PC';

                 elsif l_is_rate_type_valid = 'T' then
                     x_err_code := '30';
                     x_err_msg   := 'PA_INVALID_RATE_TYPE_PC';

                 end if;

              end if;

              if x_err_code = 0  then

	         pa_multi_currency.convert_amount (
	           p_from_currency	   => p_funding_currency_code,
	           p_to_currency	   => p_project_currency_code,
	           p_conversion_date       => p_project_rate_date,
	           p_conversion_type       => p_project_rate_type,
	           p_handle_exception_flag => 'Y',
	           p_amount		   => p_allocated_amount,
	           p_user_validate_flag    => 'Y',
	           p_converted_amount      => p_project_allocated_amount,
	           p_denominator	   => l_denominator,
	           p_numerator	           => l_numerator,
	           p_rate		   => p_project_exchange_rate,
	           x_status	           => l_return_status);

                   if l_return_status is not null then

                      x_err_code := 30;
                      /* Bug 2341576 - Prepended the _FC in the following message */
                      x_err_msg := l_return_status || '_FC_PC';

                   end if;

	      end if;

           end if;

        end if;

        if x_err_code = 0 then

           if p_funding_currency_code = p_projfunc_currency_code then
	      p_projfunc_rate_type :=  null;
	      p_projfunc_rate_date := null;
	      p_projfunc_exchange_rate := null;
	      p_projfunc_allocated_amount := p_allocated_amount;

	   else
              if p_validate_parameters = 'Y' and p_projfunc_rate_type is not null then

                 l_validate := 'Y';

              else

                 l_validate := 'N';

              end if;

	      p_projfunc_rate_type := nvl(p_projfunc_rate_type,
				  	   l_projfunc_rate_type);
	      p_projfunc_exchange_rate := nvl(p_projfunc_exchange_rate,
					   l_projfunc_exchange_rate);
              if p_projfunc_rate_date is null then
	         if l_projfunc_rate_date_code = 'FIXED_DATE' then
		    p_projfunc_rate_date := l_projfunc_rate_date;
	         else
		    p_projfunc_rate_date := p_date_allocated;
	         end if;
	      end if;
              if l_validate = 'Y' then

                 l_is_rate_type_valid := check_valid_exch_rate (
                          p_funding_currency_code => p_funding_currency_code,
                          p_to_currency_code      => p_projfunc_currency_code,
                          p_exchange_rate_type    => p_projfunc_rate_type,
                          p_exchange_rate_date    => p_projfunc_rate_date,
                          p_exchange_rate         => p_projfunc_exchange_rate);

                 if l_is_rate_type_valid = 'R' then

                     x_err_code := '30';
                     x_err_msg   := 'PA_EXCH_RATE_NULL_PF';

                 elsif l_is_rate_type_valid = 'T' then
                     x_err_code := '30';
                     x_err_msg   := 'PA_INVALID_RATE_TYPE_PF';

                 end if;

              end if;

              if x_err_code = 0  then

	         pa_multi_currency.convert_amount (
	             p_from_currency	       => p_funding_currency_code,
	             p_to_currency	       => p_projfunc_currency_code,
	             p_conversion_date       => p_projfunc_rate_date,
	             p_conversion_type       => p_projfunc_rate_type,
	             p_handle_exception_flag => 'Y',
	             p_amount		       => p_allocated_amount,
	             p_user_validate_flag    => 'Y',
	             p_converted_amount      => p_projfunc_allocated_amount,
	             p_denominator	       => l_denominator,
	             p_numerator	       => l_numerator,
	             p_rate		       => p_projfunc_exchange_rate,
	             x_status		       => l_return_status);

                   if l_return_status is not null then

                      x_err_code := 30;
                     /* Bug 2341576 - Prepended the _FC in the following message */
                      x_err_msg := l_return_status || '_FC_PF';

                   end if;

              end if;

           end if;

	end if;

        if x_err_code = 0 then

	   if p_funding_currency_code = p_invproc_currency_code then
	      p_invproc_rate_type := null;
	      p_invproc_rate_date := null;
	      p_invproc_exchange_rate := null;
	      p_invproc_allocated_amount := p_allocated_amount;
	   elsif p_invproc_currency_code = p_project_currency_code then
	      p_invproc_rate_type := p_project_rate_type;
	      p_invproc_rate_date := p_project_rate_date;
	      p_invproc_exchange_rate := p_project_exchange_rate;
	      p_invproc_allocated_amount := p_project_allocated_amount;
	   elsif p_invproc_currency_code = p_projfunc_currency_code then
	      p_invproc_rate_type := p_projfunc_rate_type;
	      p_invproc_rate_date := p_projfunc_rate_date;
	      p_invproc_exchange_rate := p_projfunc_exchange_rate;
	      p_invproc_allocated_amount := p_projfunc_allocated_amount;
	   end if;

	   if p_funding_currency_code = p_revproc_currency_code then
	      p_revproc_rate_type := null;
	      p_revproc_rate_date := null;
	      p_revproc_exchange_rate := null;
	      p_revproc_allocated_amount := p_allocated_amount;
	   elsif p_revproc_currency_code = p_project_currency_code then
	      p_revproc_rate_type := p_project_rate_type;
	      p_revproc_rate_date := p_project_rate_date;
	      p_revproc_exchange_rate := p_project_exchange_rate;
	      p_revproc_allocated_amount := p_project_allocated_amount;
	   elsif p_revproc_currency_code = p_projfunc_currency_code then
	      p_revproc_rate_type := p_projfunc_rate_type;
	      p_revproc_rate_date := p_projfunc_rate_date;
	      p_revproc_exchange_rate := p_projfunc_exchange_rate;
	      p_revproc_allocated_amount := p_projfunc_allocated_amount;
	   end if;

        end if;

EXCEPTION

     WHEN OTHERS THEN
            p_funding_currency_code     := np_p_funding_currency_code;
            p_project_currency_code     := np_p_project_currency_code;
            p_project_rate_type         := np_p_project_rate_type;
            p_project_rate_date         := np_p_project_rate_date;
            p_project_exchange_rate     := np_p_project_exchange_rate;
            p_project_allocated_amount  := np_p_project_allocated_amount;
            p_projfunc_currency_code    := np_p_projfunc_currency_code;
            p_projfunc_rate_type        := np_p_projfunc_rate_type;
            p_projfunc_rate_date        := np_p_projfunc_rate_date;
            p_projfunc_exchange_rate    := np_p_projfunc_exchange_rate;
            p_projfunc_allocated_amount := np_p_projfunc_allocated_amount;
            p_invproc_currency_code     := np_p_invproc_currency_code;
            p_invproc_rate_type         := np_p_invproc_rate_type;
            p_invproc_rate_date         := np_p_invproc_rate_date;
            p_invproc_exchange_rate     := np_p_invproc_exchange_rate;
            p_invproc_allocated_amount  := np_p_invproc_allocated_amount;
            p_revproc_currency_code     := np_p_revproc_currency_code;
            p_revproc_rate_type         := np_p_revproc_rate_type;
            p_revproc_rate_date         := np_p_revproc_rate_date;
            p_revproc_exchange_rate     := np_p_revproc_exchange_rate;
            p_revproc_allocated_amount  := np_p_revproc_allocated_amount;

          x_err_code := SQLCODE;
          x_err_msg   := SQLERRM;

END GET_MCB2_ATTRIBUTES;


/*This is added for finplan impact on billing*/
FUNCTION  check_proj_task_lvl_funding_fp
        (  p_agreement_id                       IN      NUMBER
          ,p_project_id                         IN      NUMBER
          ,p_task_id                            IN      NUMBER
        ) RETURN VARCHAR2
is
p_proposed_fund_level varchar2(1);
l_return_status varchar2(2000);
l_msg_count number;
l_msg_data varchar2(2000);
x_return_status varchar2(2000);
BEGIN
IF (p_task_id is null) then
p_proposed_fund_level :='P';
  Pa_Fp_Control_Items_Utils.isFundingLevelChangeAllowed(
                        p_project_id  =>p_project_id,
                        p_proposed_fund_level =>p_proposed_fund_level,
                        x_return_status =>l_return_status,
                        x_msg_count    =>l_msg_count,
                        x_msg_data     =>l_msg_data);
   if (x_return_status=FND_API.G_RET_STS_ERROR)
   then return('A');
   end if;
else
 p_proposed_fund_level :='T';
 Pa_Fp_Control_Items_Utils.isFundingLevelChangeAllowed(
                        p_project_id  =>p_project_id,
                        p_proposed_fund_level =>p_proposed_fund_level,
                        x_return_status =>l_return_status,
                        x_msg_count    =>l_msg_count,
                        x_msg_data     =>l_msg_data);

    if (x_return_status=FND_API.G_RET_STS_ERROR)
    then return('A');
    end if;
end if;
return ('Y');
end check_proj_task_lvl_funding_fp;

  -- API for creating funding lines for Control Items changes
  PROCEDURE create_funding_CO(
	    p_Rowid                   IN OUT NOCOPY VARCHAR2,/*FILE.sql.39*/
            p_Project_Funding_Id      IN OUT NOCOPY NUMBER,/*FILE.sql.39*/
            p_Last_Update_Date	      IN     DATE,
            p_Last_Updated_By	      IN     NUMBER,
            p_Creation_Date	      IN     DATE,
            p_Created_By	      IN     NUMBER,
            p_Last_Update_Login	      IN     NUMBER,
            p_Agreement_Id	      IN     NUMBER,
            p_Project_Id	      IN     NUMBER,
            p_Task_id		      IN     NUMBER,
            p_Budget_Type_Code	      IN     VARCHAR2,
            p_Allocated_Amount	      IN     NUMBER,
            p_Date_Allocated	      IN     DATE,
	    P_Funding_Currency_Code   IN     VARCHAR2,   	     -- FP_M  CI changes
	    p_Control_Item_ID	      IN     NUMBER DEFAULT NULL,    -- FP_M changes
            p_Attribute_Category      IN     VARCHAR2,
            p_Attribute1	      IN     VARCHAR2,
            p_Attribute2	      IN     VARCHAR2,
            p_Attribute3	      IN     VARCHAR2,
            p_Attribute4	      IN     VARCHAR2,
            p_Attribute5	      IN     VARCHAR2,
            p_Attribute6	      IN     VARCHAR2,
            p_Attribute7	      IN     VARCHAR2,
            p_Attribute8	      IN     VARCHAR2,
            p_Attribute9	      IN     VARCHAR2,
            p_Attribute10	      IN     VARCHAR2,
            p_pm_funding_reference    IN     VARCHAR2,
            p_pm_product_code	      IN     VARCHAR2,
	    p_Project_Allocated_Amount IN    NUMBER DEFAULT 0,  -- FP_M changes
	    p_project_rate_type	      IN     VARCHAR2	DEFAULT NULL,
	    p_project_rate_date	      IN     DATE	DEFAULT NULL,
	    p_project_exchange_rate   IN     NUMBER	DEFAULT	NULL,
	    p_Projfunc_Allocated_Amount IN    NUMBER DEFAULT 0,  -- FP_M changes
	    p_projfunc_rate_type      IN     VARCHAR2	DEFAULT NULL,
	    p_projfunc_rate_date      IN     DATE	DEFAULT NULL,
	    p_projfunc_exchange_rate  IN     NUMBER	DEFAULT	NULL,
            x_err_code                OUT    NOCOPY NUMBER,/*FILE.sql.39*/
            x_err_msg                 OUT    NOCOPY VARCHAR2,/*FILE.sql.39*/
            p_funding_category        IN     VARCHAR2   /* Bug 2244796 */
                     )
  IS
        l_Project_Funding_Id     NUMBER := p_Project_Funding_Id;
        l_err_msg                        VARCHAR2(150);
        l_err_code                      NUMBER;
	l_funding_currency_code		VARCHAR2(15);

	l_project_currency_code		VARCHAR2(15);
	l_project_rate_type		VARCHAR2(30);
	l_project_rate_date		DATE;
	l_project_exchange_rate		NUMBER;
	l_project_allocated_amount	NUMBER;

	l_projfunc_currency_code	VARCHAR2(15);
	l_projfunc_rate_type		VARCHAR2(30);
	l_projfunc_rate_date		DATE;
	l_projfunc_exchange_rate	NUMBER;
	l_projfunc_allocated_amount	NUMBER;

	l_invproc_currency_Type	        VARCHAR2(30);
	l_invproc_currency_code	        VARCHAR2(15);
	l_invproc_rate_type		VARCHAR2(30);
	l_invproc_rate_date		DATE;
	l_invproc_exchange_rate		NUMBER;
	l_invproc_allocated_amount	NUMBER;

	l_revproc_currency_code	        VARCHAR2(15);
	l_revproc_rate_type		VARCHAR2(30);
	l_revproc_rate_date		DATE;
	l_revproc_exchange_rate		NUMBER;
	l_revproc_allocated_amount	NUMBER;
  BEGIN

    --dbms_output.put_line('Inside: pa_funding_core.create_funding_CO');

    Select Invproc_Currency_Type, Project_Currency_Code, ProjFunc_Currency_Code
    INTO   l_Invproc_Currency_Type, l_Project_Currency_Code, l_ProjFunc_Currency_Code
    FROM   PA_Projects
    Where  Project_ID = P_Project_ID;

    IF l_Invproc_Currency_Type = 'PROJECT_CURRENCY' THEN
       l_Invproc_Currency_Code     := l_Project_Currency_Code;
       l_Invproc_Rate_Type         := p_Project_Rate_Type;
       l_Invproc_Rate_Date         := p_Project_Rate_Date;
       l_Invproc_Exchange_Rate     := p_Project_Exchange_Rate;
       l_Invproc_Allocated_Amount := p_Project_Allocated_Amount;
    Elsif l_Invproc_Currency_Type = 'PROJFUNC_CURRENCY' THEN
       l_Invproc_Currency_Code 	   := l_Projfunc_Currency_Code;
       l_Invproc_Rate_Type         := p_Projfunc_Rate_Type;
       l_Invproc_Rate_Date         := p_Projfunc_Rate_Date;
       l_Invproc_Exchange_Rate     := p_Projfunc_Exchange_Rate;
       l_Invproc_Allocated_Amount := p_Projfunc_Allocated_Amount;
    Elsif l_Invproc_Currency_Type = 'FUNDING_CURRENCY' THEN
       l_Invproc_Currency_Code 	   := p_Funding_Currency_Code;
       l_Invproc_Rate_Type         := NULL;
       l_Invproc_Rate_Date         := NULL;
       l_Invproc_Exchange_Rate     := NULL;
       l_Invproc_Allocated_Amount := p_Allocated_Amount;
    END IF;

       pa_project_fundings_pkg.insert_row(
	    x_rowid			   =>	p_rowid,
	    x_project_funding_id	   =>	p_project_funding_id,
	    x_last_update_date		   =>	p_last_update_date,
	    x_last_updated_by		   =>	p_last_updated_by,
	    x_creation_date		   =>	p_creation_date,
	    x_created_by		   =>	p_created_by,
	    x_last_update_login		   =>	p_last_update_login,
	    x_agreement_id		   =>	p_agreement_id,
	    x_project_id		   =>	p_project_id,
	    x_task_id			   =>	p_task_id,
	    x_budget_type_code		   =>	p_budget_type_code,
	    x_allocated_amount		   =>	p_allocated_amount,
	    x_date_allocated		   =>	p_date_allocated,
	    X_Control_Item_ID		   =>   p_Control_Item_ID,    -- FP_M changes
	    x_attribute_category	   =>	p_attribute_category,
	    x_attribute1		   =>	p_attribute1,
	    x_attribute2		   =>	p_attribute2,
	    x_attribute3		   =>	p_attribute3,
	    x_attribute4		   =>	p_attribute4,
	    x_attribute5		   =>	p_attribute5,
	    x_attribute6		   =>	p_attribute6,
	    x_attribute7		   =>	p_attribute7,
	    x_attribute8		   =>	p_attribute8,
	    x_attribute9		   =>	p_attribute9,
	    x_attribute10		   =>	p_attribute10,
	    x_pm_funding_reference	   =>	p_pm_funding_reference,
	    x_pm_product_code		   =>	p_pm_product_code,
            x_funding_currency_code	   =>   p_funding_currency_code,
	    x_project_currency_code	   =>   l_project_currency_code,
      	    x_project_rate_type		   =>   p_project_rate_type,
	    x_project_rate_date		   =>   p_project_rate_date,
	    x_project_exchange_rate	   =>   p_project_exchange_rate,
	    x_project_allocated_amount	   =>	p_project_allocated_amount,
	    x_projfunc_currency_code	   =>   l_projfunc_currency_code,
	    x_projfunc_rate_type	   =>   p_projfunc_rate_type,
	    x_projfunc_rate_date	   =>   p_projfunc_rate_date,
	    x_projfunc_exchange_rate	   =>   p_projfunc_exchange_rate,
	    x_projfunc_allocated_amount	   =>	p_projfunc_allocated_amount,
            x_invproc_currency_code	   =>   l_invproc_currency_code,
            x_invproc_rate_type		   =>   l_invproc_rate_type,
	    x_invproc_rate_date		   =>   l_invproc_rate_date,
	    x_invproc_exchange_rate	   =>   l_invproc_exchange_rate,
	    x_invproc_allocated_amount	   =>	l_invproc_allocated_amount,
	    x_revproc_currency_code	   =>   l_projfunc_currency_code,
            x_revproc_rate_type		   =>   p_projfunc_rate_type,
	    x_revproc_rate_date		   =>   p_projfunc_rate_date,
	    x_revproc_exchange_rate	   =>   p_projfunc_exchange_rate,
	    x_revproc_allocated_amount	   =>	p_projfunc_allocated_amount,
            x_funding_category             =>   p_funding_category  /* For Bug2244796 */
	);

    --dbms_output.put_line('Done: create_funding_CO');
EXCEPTION

   WHEN OTHERS THEN
      x_err_code := SQLCODE;
      x_err_msg   := SQLERRM;
     p_Project_Funding_Id := l_Project_Funding_Id;
END create_funding_CO;

END PA_FUNDING_CORE;

/
