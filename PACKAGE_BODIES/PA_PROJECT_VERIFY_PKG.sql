--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_VERIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_VERIFY_PKG" AS
/* $Header: PAXPRVRB.pls 120.3 2007/02/06 10:18:36 dthakker ship $ */

  PROCEDURE customer_exists
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
    CURSOR get_top_task_cust_enbled IS
    SELECT enable_top_task_customer_flag
    FROM pa_projects_all
    WHERE project_id = x_project_id;
    l_en_top_task_cust_flag VARCHAR2(1);

    --added the below code for Federal changes by sunkalya
    --sunkalya:federal Bug#5511353
    CURSOR get_date_eff_funds_flag
    IS
    SELECT nvl(DATE_EFF_FUNDS_CONSUMPTION,'N')
    FROM
    pa_projects_all
    WHERE project_id = x_project_id;
    l_date_eff_funds_flag VARCHAR2(1);

    --end of code added for federal changes by sunkalya
    --sunkalya:federal Bug#5511353

    x_old_stack varchar2(630);
    dummy number;
  begin
    x_err_code := 0;
    x_old_stack := x_err_stack;
    x_err_stack := x_err_stack ||'->PA_PROJECT_VERIFY_PKG.client_exists';
    x_err_msgname := NULL;
    x_err_stage := 'Checking client exists...';

    OPEN get_top_task_cust_enbled;
    FETCH get_top_task_cust_enbled INTO l_en_top_task_cust_flag;
    CLOSE get_top_task_cust_enbled;

    OPEN  get_date_eff_funds_flag;
    FETCH get_date_eff_funds_flag INTO l_date_eff_funds_flag;
    CLOSE get_date_eff_funds_flag;

    --modified the below if for federal changes by sunkalya
    --sunkalya:federal Bug#5511353
    IF l_en_top_task_cust_flag <> 'Y' AND l_date_eff_funds_flag <> 'Y' THEN
        SELECT NULL
        INTO dummy
        FROM sys.dual
        WHERE exists (
          SELECT NULL
          FROM    PA_PROJECT_CUSTOMERS
          WHERE   PROJECT_ID = x_project_id
          GROUP   BY PROJECT_ID
          HAVING SUM(CUSTOMER_BILL_SPLIT) = 100);
    END IF;

    x_err_stack := x_old_stack;
  exception
    when NO_DATA_FOUND then
      x_err_code := 10;
      x_err_stage := 'PA_NO_CLIENT_EXISTS';
      x_err_msgname := 'PA_PR_INSUF_BILL_SPLIT';
    when others then
      x_err_code := SQLCODE;
  end customer_exists;

  PROCEDURE contact_exists
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
    x_old_stack varchar2(630);
    dummy number;
  begin
    x_err_code := 0;
    x_old_stack := x_err_stack;
    x_err_stack := x_err_stack ||'->PA_PROJECT_VERIFY_PKG.contact_exists';
    x_err_msgname := NULL;
    x_err_stage := 'Checking contact exists...';
    SELECT NULL
    INTO dummy
    FROM sys.dual
    WHERE exists (
      SELECT NULL
      FROM    PA_PROJECT_CUSTOMERS CUST
      WHERE   CUST.PROJECT_ID = x_project_id
      AND     CUST.CUSTOMER_BILL_SPLIT > 0
      AND     NOT EXISTS (SELECT NULL
                  FROM    PA_PROJECT_CONTACTS CONT
                  WHERE   CONT.PROJECT_ID = x_project_id
                  AND     CONT.CUSTOMER_ID=  CUST.CUSTOMER_ID
                  AND     CONT.PROJECT_CONTACT_TYPE_CODE = 'BILLING'));
    x_err_code := 10;
    x_err_stage := 'PA_NO_CONTACT_EXISTS';
    x_err_msgname := 'PA_PR_INSUF_BILL_CONTACT';
  exception
    when NO_DATA_FOUND then
      x_err_stack := x_old_stack;
    when others then
      x_err_code := SQLCODE;
  end contact_exists;

  PROCEDURE category_required
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
    x_old_stack varchar2(630);
    dummy number;

    /*
    The following cursor has been commented for Performance Bug # 3691123
    The cursor is split into C11 and C12 for performance reasons so that
    queries can be based on base tables directly.

    CURSOR C1
    IS
    SELECT NULL
    FROM    PA_VALID_CATEGORIES_V VC,
            PA_PROJECTS_ALL PPA,
            PA_PROJECT_TYPES_ALL PPTA
    WHERE   VC.MANDATORY_FLAG = 'Y'
    AND     PPA.PROJECT_ID = x_project_id
    AND     PPA.PROJECT_TYPE = PPTA.PROJECT_TYPE
    AND     nvl(PPA.ORG_ID, -99) = nvl(PPTA.ORG_ID, -99)
    AND     VC.OBJECT_TYPE_ID = PPTA.PROJECT_TYPE_ID
    AND     NOT EXISTS (SELECT NULL
                        FROM   PA_PROJECT_CLASSES PC
                       WHERE   PC.PROJECT_ID = x_project_id
                         AND   PC.CLASS_CATEGORY = VC.CLASS_CATEGORY);
    */

    CURSOR C11
    IS
    SELECT NULL
      FROM DUAL
     WHERE EXISTS
    (
    SELECT 1
    FROM   PA_CLASS_CATEGORIES cc,
           PA_VALID_CATEGORIES vc,
           PA_PROJECT_TYPES_ALL PPTA,
           PA_PROJECTS_ALL PPA
    WHERE  VC.CLASS_CATEGORY = CC.CLASS_CATEGORY
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(CC.START_DATE_ACTIVE)
                              AND TRUNC(NVL(CC.END_DATE_ACTIVE, SYSDATE))
    AND    VC.OBJECT_TYPE_ID = PPTA.PROJECT_TYPE_ID
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(PPTA.START_DATE_ACTIVE)
			      AND TRUNC(NVL(PPTA.END_DATE_ACTIVE, SYSDATE))
    AND    VC.MANDATORY_FLAG = 'Y'
    AND    PPA.PROJECT_ID = x_project_id
    AND    PPA.PROJECT_TYPE = PPTA.PROJECT_TYPE
    AND    PPA.ORG_ID = PPTA.ORG_ID --MOAC Changes: Bug 4363092: removed nvl usage with org_id
    AND    NOT EXISTS (SELECT NULL
                        FROM   PA_PROJECT_CLASSES PC
                       WHERE   PC.PROJECT_ID = x_project_id
                         AND   PC.CLASS_CATEGORY = VC.CLASS_CATEGORY)
    );

    CURSOR C12
    IS
    SELECT NULL
      FROM DUAL
     WHERE EXISTS (SELECT 1
                     from PA_CLASS_CATEGORIES CC
                    WHERE CC.MANDATORY_FLAG = 'Y'
                      AND CC.OBJECT_TYPE = 'PA_PROJECTS'
                      AND CC.ALL_TYPES_VALID_FLAG = 'Y'
                      AND TRUNC(SYSDATE) BETWEEN TRUNC(CC.START_DATE_ACTIVE)
					     AND TRUNC(NVL(CC.END_DATE_ACTIVE, SYSDATE))
                      AND NOT EXISTS(SELECT   NULL
                                       FROM   PA_PROJECT_CLASSES PC
                                      WHERE   PC.PROJECT_ID = x_project_id
                                        AND   PC.CLASS_CATEGORY = CC.CLASS_CATEGORY)
    );

    /*
    The following cursor has been commented for Performance Bug # 3691123
    The cursor looks only for sort_order = 'A'
    This View PA_PROJECT_CLASS_TOTALS_V has two select statements joined by UNION
    The 1st select statement is for sort_order A and C / the 2nd select statement for B

    So,the query can be based directly on the base table as in 1st select statement of the view
    CURSOR C2
    IS
    SELECT NULL
    FROM   PA_PROJECT_CLASS_TOTALS_V
    WHERE  project_id = x_project_id
    AND    sort_order = 'A';
    */

    /* Start of new code for Performance Bug # 3691123 */
    CURSOR C2
    IS
    SELECT NULL
    FROM PA_PROJECT_CLASSES
    WHERE  project_id = x_project_id
    AND    OBJECT_TYPE = 'PA_PROJECTS'
    AND    decode(PA_PROJECTS_MAINT_UTILS.GET_CLASS_EXCEPTIONS(object_id,object_type, class_category, 'N'), NULL, 'C', 'A') = 'A'
    ;

    /*End  code for Performance Bug # 3691123 */
  begin
    -- This procedure has been modified for Classification enhancements
    -- It checks whether there are any mandatory categories that have not
    -- been specified
    -- It also checks if there are any categories defined for this project
    -- that have the total 100 percent flag enabled, but whose defined
    -- defined class codes do not actually total 100
    x_err_code := 0;
    x_old_stack := x_err_stack;
    x_err_stack := x_err_stack ||'->PA_PROJECT_VERIFY_PKG.category_required';
    x_err_msgname := NULL;
    x_err_stage := 'Checking required category exists...';

    OPEN C11;
    FETCH C11 INTO dummy;
    if C11%FOUND then
      CLOSE C11;
      x_err_code := 10;
      x_err_stage := 'PA_NO_REQ_CATEGORY_EXISTS';
      x_err_msgname := 'PA_PR_INSUF_CLASS_CODES';
      return;
    else
        OPEN C12;
        FETCH C12 INTO dummy;
        if C12%FOUND then
            CLOSE C12;
            x_err_code := 10;
            x_err_stage := 'PA_NO_REQ_CATEGORY_EXISTS';
            x_err_msgname := 'PA_PR_INSUF_CLASS_CODES';
            return;
        end if;
        CLOSE C12 ;
    end if;

    CLOSE C11 ;

    x_err_stage := 'Checking total class code percentages...';

    OPEN C2;
    FETCH C2 INTO dummy;
    if C2%FOUND then
      CLOSE C2;
      x_err_code := 20;
      x_err_stage := 'PA_CLASS_TOTALS_INVALID';
      x_err_msgname := 'PA_PR_CLASS_TOTAL_INVLD';
      return;
    end if;
    CLOSE C2;

    x_err_stack := x_old_stack;
  exception
    when others then
      x_err_code := SQLCODE;
  end category_required;

  PROCEDURE manager_exists
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
    x_old_stack varchar2(630);
    proj_start_date DATE;
    km_start_date DATE;
    km_end_date DATE;
    l_dummy NUMBER := 0;
    CURSOR c1 IS
      SELECT NVL(Start_Date,trunc(Sysdate)) FROM Pa_Projects_all -- Bug#3807805 : Modified Pa_Projects to Pa_Projects_all
      WHERE   PROJECT_ID = x_project_id;

     /* Added the following cursor instead of select statement to
        handle the "too many rows selected" condition.
        Bug fix for # 824266 */

    CURSOR c2 IS
     SELECT START_DATE_ACTIVE,END_DATE_ACTIVE
     FROM    PA_PROJECT_PLAYERS
     WHERE   PROJECT_ID = x_project_id
     AND     PROJECT_ROLE_TYPE = 'PROJECT MANAGER';
 BEGIN
   x_err_code := 0;
   x_old_stack := x_err_stack;
   x_err_stack := x_err_stack ||'->PA_PROJECT_VERIFY_PKG.manager_exists';
   x_err_msgname := NULL;
   x_err_stage := 'Checking manager exists...';

   OPEN c1 ;
   FETCH c1 INTO proj_start_date ;
   IF c1%notfound then
        SELECT TRUNC(Sysdate) INTO proj_start_date FROM Dual;
   END IF;
   CLOSE c1 ;

   /* Changed the following logic to use cursor and loop */
   /* For bug # 824266 fix  */

   OPEN c2;
   LOOP
     FETCH c2 INTO km_start_date,km_end_date ;
     EXIT WHEN c2%NOTFOUND ;

     IF TRUNC(SYSDATE) BETWEEN
        km_start_date AND nvl(km_end_date,GREATEST(km_start_date,TRUNC(SYSDATE)))
      OR
        proj_start_date BETWEEN
        km_start_date AND nvl(km_end_date,GREATEST(km_start_date,TRUNC(SYSDATE)))
      OR
        (proj_start_date > TRUNC(SYSDATE) AND
         km_start_date BETWEEN TRUNC(SYSDATE) and proj_start_date
         AND km_end_date IS NULL )
     THEN
        l_dummy := 0;
        EXIT ;
     ELSE
        l_dummy := -1;
     END IF;
   END LOOP;

   IF c2%ROWCOUNT = 0 THEN
      close c2;
      raise no_data_found;
   END IF;

   CLOSE c2;
   /* End of changes made for bug # 824266 fix  */

   IF l_dummy = -1 THEN
      x_err_code := 10;
      x_err_stage := 'PA_NO_MANAGER_EXISTS';
      x_err_msgname := 'PA_PR_INSUF_PROJ_MGR';
   END IF;
   x_err_stack := x_old_stack;
  exception
    when NO_DATA_FOUND then
      x_err_code := 10;
      x_err_stage := 'PA_NO_MANAGER_EXISTS';
      x_err_msgname := 'PA_PR_INSUF_PROJ_MGR';
    when others then
      x_err_code := SQLCODE;
 END manager_exists;

  PROCEDURE revenue_budget
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
    x_old_stack varchar2(630);
    dummy number;
  begin
    x_err_code := 0;
    x_old_stack := x_err_stack;
    x_err_stack := x_err_stack ||'->PA_PROJECT_VERIFY_PKG.revenue_budget';
    x_err_msgname := NULL;
    x_err_stage := 'Checking revenue budget exists...';
    SELECT 'x'  INTO dummy
    FROM PA_BUDGET_VERSIONS bv,
		    PA_BUDGET_TYPES bt
    WHERE
    bv.budget_type_code = bt.budget_type_code
    AND bt.budget_amount_code = 'R';
    x_err_stack := x_old_stack;
  exception
    when NO_DATA_FOUND then
      x_err_code := 10;
      x_err_stage := 'PA_NO_REV_BUDGET_EXISTS';
      x_err_msgname := 'PA_PR_NO_REV_BUDGET';
    when others then
      x_err_code := SQLCODE;
  end revenue_budget;

  PROCEDURE cost_budget
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
    x_old_stack varchar2(630);
    dummy number;
  begin
    x_err_code := 0;
    x_old_stack := x_err_stack;
    x_err_stack := x_err_stack ||'->PA_PROJECT_VERIFY_PKG.cost_budget';
    x_err_msgname := NULL;
    x_err_stage := 'Checking cost budget exists...';
    SELECT 'x'  INTO dummy
    FROM PA_BUDGET_VERSIONS bv,
		    PA_BUDGET_TYPES bt
    WHERE
    bv.budget_type_code = bt.budget_type_code
    AND bt.budget_amount_code = 'C';
    x_err_stack := x_old_stack;
  exception
    when NO_DATA_FOUND then
       x_err_code := 10;
       x_err_stage := 'PA_NO_COST_BUDGET_EXISTS';
       x_err_msgname := 'PA_PR_NO_COST_BUDGET';
    when others then
      x_err_code := SQLCODE;
  end cost_budget;

  PROCEDURE billing_event
		 (x_project_id		IN     NUMBER,
                  x_err_stage           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_code            IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		  x_err_stack           IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_err_msgname		IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_eamt_token_name	IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		  x_eamt_token_value	IN OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
    x_old_stack varchar2(630);
    dummy number;
  begin
    x_err_code := 0;
    x_old_stack := x_err_stack;
    x_err_stack := x_err_stack ||'->PA_PROJECT_VERIFY_PKG.billing_event';
    x_err_msgname := NULL;
    x_eamt_token_name := 'EAMT';
    x_eamt_token_value := 0;
/*  Commented out for now,since the code is incorrectly referencing
    pa_subbudgets. Need to fix this since pa_subbudgets is obsolete
    in Rel 11.0 - Ramesh - 01/13/1998
    x_err_stage := 'Checking billing event exists...';
    SELECT NULL
    INTO dummy
    FROM sys.dual
    WHERE exists (
      select  NULL
      from    pa_events e
      ,       pa_event_Types et
      ,       pa_tasks t
      where   nvl(e.task_id,t.task_id) = t.task_id
	and	e.project_id = t.project_id
      and     e.event_type = et.event_Type
      and     t.project_id = x_project_id
      and     e.completion_date is not null
      having  sum(nvl(decode(et.event_type_classification,
                      'INVOICE REDUCTION',-e.bill_amount,
                                           e.bill_amount),0)) =
              (select sum(nvl(revenue,0))
              from pa_subbudgets s
              ,       pa_tasks t
              where   s.project_id = x_project_id
              and     s.budget_Type_code= 'DRAFT'
              and     s.task_id = t.task_id(+)
              and     t.task_id = t.top_task_id
              ));
*/
    x_err_stack := x_old_stack;
  exception
    when NO_DATA_FOUND then
      NULL;
     /*  Commented out since the original sql has been commented out
      begin
        select to_char(sum(nvl(decode(et.event_type_classification,
                        'INVOICE REDUCTION', -e.bill_amount,
                                              e.bill_amount),0)))
        into x_eamt_token_value
        from    pa_events e
        ,       pa_event_Types et
        ,       pa_tasks t
        where   nvl(e.task_id, t.task_id) = t.task_id
        and	e.project_id = t.project_id
        and     e.event_Type = et.event_Type
        and     t.project_id = x_project_id
        and     e.completion_date is not null;
      exception
        when others then
          null;
      end;
      x_err_code := 10;
      x_err_stage := 'PA_NO_BILL_EVENT_EXISTS';
      x_err_msgname := 'PA_PR_NEED_BILLING_EVENTS';
   */
    when others then
      x_err_code := SQLCODE;
  end billing_event;

end PA_PROJECT_VERIFY_PKG;

/
