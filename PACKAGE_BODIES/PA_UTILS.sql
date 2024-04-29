--------------------------------------------------------
--  DDL for Package Body PA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_UTILS" AS
/* $Header: PAXGUTLB.pls 120.12.12010000.7 2009/04/30 00:48:54 svivaram ship $ */
-- ==========================================================================
--  Added for bug 5067511 : These global variables should be only used in the
--  function GetPersonInfo
-- ==========================================================================
L_PERSON_ID               per_all_people_f.person_id%TYPE;
L_PERSON_FULL_NAME        per_all_people_f.full_name%TYPE;
L_PERSON_LAST_NAME        per_all_people_f.last_name%TYPE;
L_PERSON_FIRST_NAME       per_all_people_f.first_name%TYPE;
L_PERSON_MIDDLE_NAMES     per_all_people_f.middle_names%TYPE;
L_PERSON_EMPLOYEE_NUMBER  per_all_people_f.employee_number%TYPE;

-- ==========================================================================
-- = PROCEDURE GetProjInfo
-- ==========================================================================

  PROCEDURE  GetProjInfo ( X_proj_id     IN NUMBER
                         , X_proj_num    OUT NOCOPY VARCHAR2
                         , X_proj_name   OUT NOCOPY VARCHAR2 )
  IS
  BEGIN

    SELECT
            segment1
    ,       name
      INTO
            X_proj_num
    ,       X_proj_name
      FROM
            pa_projects_all
     WHERE
            project_id = X_proj_id;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_proj_num  := NULL;
      X_proj_name := NULL;

  END  GetProjInfo;


-- ==========================================================================
-- = PROCEDURE SetGlobalEmpId
-- ==========================================================================

   PROCEDURE SetGlobalEmpId ( p_emp_id NUMBER )
   IS
   BEGIN
       pa_utils.Global_employee_id := p_emp_id;
   END SetGlobalEmpId;

-- ==========================================================================
-- = FUNCTION GetGlobalEmpId
-- ==========================================================================

   FUNCTION GetGlobalEmpId RETURN NUMBER
   IS
   BEGIN
      RETURN (  pa_utils.Global_employee_id  );
   END GetGlobalEmpId;

-- ==========================================================================
-- = PROCEDURE GetTaskInfo
-- ==========================================================================

  PROCEDURE GetTaskInfo ( X_task_id    IN NUMBER
                        , X_task_num   OUT NOCOPY VARCHAR2
                        , X_task_name  OUT NOCOPY VARCHAR2 )
  IS
  BEGIN

    IF (x_task_id  = G_PREV_TASK_ID) THEN

       x_task_num  := G_PREV_TASK_NUM;
       x_task_name := G_PREV_TASK_NAME;

    ELSE

       G_PREV_TASK_ID := x_task_id;

       SELECT
            task_number
           ,task_name
         INTO
            X_task_num
           ,X_task_name
         FROM
            pa_tasks
        WHERE
            task_id = X_task_id;

       G_PREV_TASK_NUM  := x_task_num;
       G_PREV_TASK_NAME := x_task_name;

    END IF;

  EXCEPTION
    WHEN  OTHERS  THEN
      G_PREV_TASK_ID   := x_task_id;
      G_PREV_TASK_NUM  := NULL;
      G_PREV_TASK_NAME := NULL;
      X_task_num  := NULL;
      X_task_name := NULL;

  END GetTaskInfo;



-- ==========================================================================
-- =  FUNCTION  GetProjId
-- ==========================================================================

  FUNCTION  GetProjId ( X_project_num  IN VARCHAR2 ) RETURN NUMBER
  IS
    X_project_id   NUMBER;
  BEGIN

    IF (x_project_num = G_PREV_PROJ_NUM) THEN

       RETURN (G_PREV_PROJECT_ID);

    ELSE

       G_PREV_PROJ_NUM := x_project_num;

       SELECT
	    project_id
         INTO
	    X_project_id
         FROM
	    pa_projects_all
        WHERE
	    segment1 = X_project_num;

       G_PREV_PROJECT_ID := x_project_id;
       RETURN ( X_project_id );

    END IF;

  EXCEPTION
    WHEN  OTHERS  THEN
      G_PREV_PROJ_NUM   := x_project_num;
      G_PREV_PROJECT_ID := NULL;
      RETURN ( NULL );

  END  GetProjId;

-- ==========================================================================
-- = FUNCTION  GetEmpId
-- ==========================================================================

  FUNCTION  GetEmpId ( X_emp_num  IN VARCHAR2 ) RETURN NUMBER
  IS
    X_person_id		NUMBER;
  BEGIN
    SELECT
	    person_id
      INTO
	    X_person_id
      FROM
	    pa_employees
     WHERE
	    employee_number = X_emp_num;

    RETURN ( X_person_id );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END  GetEmpId;



-- ==========================================================================
-- = FUNCTION  GetEmpIdFromUser
-- ==========================================================================

  FUNCTION  GetEmpIdFromUser ( X_userid  IN NUMBER ) RETURN NUMBER
  IS
    X_person_id         NUMBER;
  BEGIN
    SELECT
            employee_id
      INTO
            X_person_id
      FROM
            fnd_user
     WHERE
            user_id = X_userid;

    RETURN ( X_person_id );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END  GetEmpIdFromUser;



-- ==========================================================================
-- = FUNCTION  GetEmpName
-- ==========================================================================

  FUNCTION  GetEmpName ( X_person_id  IN NUMBER ) RETURN VARCHAR2
  IS
    X_person_name   VARCHAR2(240);
  BEGIN
    SELECT
            full_name
      INTO
            X_person_name
      FROM
            pa_employees
     WHERE
            person_id = X_person_id;

    RETURN ( X_person_name );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END  GetEmpName;



-- ==========================================================================
-- = FUNCTION  GetTaskId
-- ==========================================================================

  FUNCTION  GetTaskId ( X_proj_id  IN NUMBER
                      , X_task_num IN VARCHAR2 ) RETURN NUMBER
  IS
    X_task_id   NUMBER;
  BEGIN

    IF (x_proj_id  = G_PREV_PROJ_ID2 AND
        X_task_num = G_PREV_TASK_NUM2) THEN

        RETURN(G_PREV_TASK_ID2);

    ELSE

        G_PREV_PROJ_ID2  := x_proj_id;
        G_PREV_TASK_NUM2 := x_task_num;

        SELECT
            task_id
          INTO
            X_task_id
          FROM
            pa_tasks
         WHERE
	    project_id  = X_proj_id
           AND  task_number = X_task_num;

        G_PREV_TASK_ID2 := x_task_id;
        RETURN ( X_task_id );

    END IF;

  EXCEPTION
    WHEN  OTHERS  THEN
      G_PREV_PROJ_ID2  := x_proj_id;
      G_PREV_TASK_NUM2 := x_task_num;
      G_PREV_TASK_ID2  := NULL;
      RETURN ( NULL );

  END  GetTaskId;
-- ==========================================================================
-- = FUNCTION  GetOrdId
-- ==========================================================================

  FUNCTION  GetOrgId ( X_org_name  IN VARCHAR2 ) RETURN NUMBER
  IS
    X_org_id     NUMBER;
  BEGIN
       SELECT
            organization_id
         INTO
            X_org_id
         FROM
            hr_organization_units o,
            pa_implementations i
        WHERE  name = X_org_name
          AND ((pa_utils.IsCrossBGProfile_WNPS = 'N'
          AND  o.business_group_id = i.business_group_id)
           OR  (pa_utils.IsCrossBGProfile_WNPS = 'Y'));

    RETURN ( X_org_id );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END  GetOrgId;


-- ==========================================================================
-- = PROCEDURE  GetOrgnId
   --Bug 3010848. Added to distinguish if for the given organization name
   --one or many organization_id are found
-- ==========================================================================

  PROCEDURE  GetOrgnId ( X_org_name  IN VARCHAR2
                      , X_bg_id     IN NUMBER DEFAULT NULL
                      , X_Orgn_Id  OUT NOCOPY Number
                      , X_Return_Status OUT NOCOPY Varchar2) IS
  BEGIN
    X_Return_Status := NULL;

    If X_bg_id is not null Then
       SELECT
            organization_id
         INTO
            X_orgn_id
         FROM
            hr_organization_units o,
            pa_implementations i
        WHERE  name = X_org_name
          AND ((pa_utils.IsCrossBGProfile_WNPS = 'N'
          AND  o.business_group_id = i.business_group_id)
           OR  (pa_utils.IsCrossBGProfile_WNPS = 'Y'
          AND  o.business_group_id = X_bg_id ));
    Else
       SELECT
            organization_id
         INTO
            X_orgn_id
         FROM
            hr_organization_units o,
            pa_implementations i
        WHERE  name = X_org_name
          AND ((pa_utils.IsCrossBGProfile_WNPS = 'N'
          AND  o.business_group_id = i.business_group_id)
           OR  (pa_utils.IsCrossBGProfile_WNPS = 'Y' ));
    End If;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
          X_Orgn_Id := NULL;
          --return status not set for no_data_found
          --since in trx import different messages are set depending on organization type
    WHEN TOO_MANY_ROWS THEN
          X_Return_Status := 'PA_TOO_MANY_ORGN';

  END  GetOrgnId;


-- ==========================================================================
-- = FUNCTION  GetOrgName
-- ==========================================================================

  FUNCTION  GetOrgName ( X_org_id  IN NUMBER ) RETURN VARCHAR2
  IS
   /* Bug No:- 2487147, UTF8 change : changed X_org_name to %TYPE */
   /* X_org_name    VARCHAR2(60); */
      X_org_name  hr_organization_units.name%TYPE;
  BEGIN
    SELECT
            name
      INTO
            X_org_name
      FROM
            hr_organization_units o,
            pa_implementations i
     WHERE
            organization_id = X_org_id
       AND ((pa_utils.IsCrossBGProfile_WNPS = 'N'
       AND  o.business_group_id = i.business_group_id)
        OR   pa_utils.IsCrossBGProfile_WNPS = 'Y' )
     ;


    RETURN ( X_org_name );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END GetOrgName;

-- ==========================================================================
-- = FUNCTION  GetWeekEnding
-- ==========================================================================

  FUNCTION  GetWeekEnding ( X_date  IN DATE ) RETURN DATE
  IS
    X_week_ending	DATE;
    X_week_ending_day   VARCHAR2(80);
    X_week_ending_day_index   number;
  BEGIN

       SELECT decode( exp_cycle_start_day_code, 1, 8, exp_cycle_start_day_code )-1
         into X_week_ending_day_index
         FROM pa_implementations;

       select to_char(to_date('01-01-1950','DD-MM-YYYY') +X_week_ending_day_index-1, 'Day')
         into X_week_ending_day from dual;

       SELECT
            next_day( trunc( X_date )-1, X_week_ending_day )    /* BUG#3118592 */
         INTO
            X_week_ending
         FROM
            sys.dual;

       RETURN ( X_week_ending );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END  GetWeekEnding;


-- ==========================================================================
-- = FUNCTION  DateInExpWeek
-- ==========================================================================

  FUNCTION  DateInExpWeek ( X_date      IN DATE
                          , X_week_end  IN DATE ) RETURN BOOLEAN
  IS
    dummy  	NUMBER;
  BEGIN

    IF (trunc(x_date)     = G_PREV_DATE AND
        trunc(x_week_end) = G_PREV_WEEK_END) THEN

      IF G_PREV_DATEIN = 1 THEN
         RETURN (TRUE);
      ELSE
         RETURN (FALSE);
      END IF;

    ELSE

        G_PREV_DATE     := trunc(x_date);
        G_PREV_WEEK_END := trunc(x_week_end);

        SELECT
	    count(1)
          INTO
            dummy
          FROM
            sys.dual
          WHERE
 	    trunc(X_date)  BETWEEN  trunc(trunc( X_week_end )-6 ) /* BUG#3118592 */
                               AND trunc( X_week_end );

        IF ( dummy = 0 ) THEN
           G_PREV_DATEIN  := 0;
           RETURN ( FALSE );
        ELSE
           G_PREV_DATEIN  := 1;
           RETURN ( TRUE );
        END IF;

   END IF;

  EXCEPTION
    WHEN  OTHERS  THEN

      G_PREV_DATE     := trunc(x_date);
      G_PREV_WEEK_END := trunc(x_week_end);
      G_PREV_DATEIN   := 0;
      RETURN ( FALSE );

  END  DateInExpWeek;


-- ==========================================================================
-- = FUNCTION  GetEmpOrgId
-- ==========================================================================

/* cwk changes : Modified function to derive the Organization Id for a Person Id of a contingent worker also*/

  FUNCTION  GetEmpOrgId ( X_person_id  IN NUMBER
                        , X_date       IN DATE    ) RETURN NUMBER
  IS
    X_org_id	NUMBER;
    X_Cross_BG_Profile VARCHAR2(2); /* Added local variable for 3194743 */
    X_business_group_id NUMBER;      /* Added local variable for 3194743 */
  BEGIN

    IF (x_person_id = G_PREV_PERSON_ID2 AND
        trunc(x_date) = G_PREV_DATE4) THEN

       RETURN (G_PREV_ORG_ID2);

    ELSE

       G_PREV_PERSON_ID2 := x_person_id;
       G_PREV_DATE4      := x_date;

    X_Cross_BG_Profile:= pa_utils.IsCrossBGProfile_WNPS; --Moved the function call from inside where clause to here

    SELECT  business_group_id    --Moved selection of BG id from inside where clause to here
    INTO    X_business_group_id
    FROM    pa_implementations;

    SELECT
	    max(a.organization_id)
      INTO
	    X_org_id
      FROM
            per_assignment_status_types s
    ,       per_all_assignments_f a        -- Modified for bug 4699231
    WHERE
	    a.person_id = X_person_id
       AND  a.primary_flag = 'Y'
       AND  a.assignment_type in ('E', 'C')
       AND  a.assignment_status_type_id = s.assignment_status_type_id
       AND  s.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK','TERM_ASSIGN')
       AND  trunc(X_date) BETWEEN trunc( a.effective_start_date ) /*Added trunc on X_Date for bug 8278399 */
                       AND trunc( a.effective_end_date   )
       /* Added for bug 2009830 */
       AND ((X_Cross_BG_Profile = 'N'
           AND  X_business_group_id = a.business_group_id+0)
        OR   X_Cross_BG_Profile = 'Y' )
     ; /*Bug 7645561 Changed the Query to include TERM_ASSIGN */

--  tsaifee  01/29/97 : Bug 442432 - Perf. for the above query.
--  the last line of the query modified : 0 added to a.business_group_id
--  so as not to use that index, as its use was giving an index merge.

    G_PREV_ORG_ID2 := x_org_id;
    RETURN ( X_org_id );

    END IF;

  EXCEPTION
    WHEN  OTHERS  THEN
      G_PREV_PERSON_ID2 := x_person_id;
      G_PREV_DATE4      := x_date;
      G_PREV_ORG_ID2    := NULL;
      RETURN ( NULL );

  END  GetEmpOrgId;


-- ==========================================================================
-- = FUNCTION  GetEmpCostRate
-- ==========================================================================

--
-- Date : 31-OCT-02
-- Updated By : Sandeep Bharathan
--
-- For any new functionality that requires the employee cost rate please
-- use PA_COST_RATE_PUB.GetEmpCostRate rather than using this function
--

  FUNCTION  GetEmpCostRate ( X_person_id  IN NUMBER
                           , X_date       IN DATE    ) RETURN NUMBER
  IS
    X_cost_rate                NUMBER(22,5);
    l_job_id                   pa_expenditure_items_all.job_id%type;
    l_costing_rule             pa_compensation_details_all.compensation_rule_set%type;
    l_start_date_active        date;
    l_end_date_active          date;
    l_organization_id          number;
    l_org_id                   number;         /*2879644*/
    l_org_labor_sch_rule_id    pa_org_labor_sch_rule.org_labor_sch_rule_id%type;
    l_rate_sch_id              pa_std_bill_rate_schedules.bill_rate_sch_id%type;
    l_override_type            pa_compensation_details.override_type%type;
    l_cost_rate_curr_code      pa_compensation_details.cost_rate_currency_code%type;
    l_acct_rate_type           pa_compensation_details.acct_rate_type%type;
    l_acct_rate_date_code      pa_compensation_details.acct_rate_date_code%type;
    l_acct_exch_rate           pa_compensation_details.acct_exchange_rate%type;
    l_acct_cost_rate           pa_compensation_details.acct_exchange_rate%type;
    l_ot_project_id            pa_projects_all.project_id%type;
    l_ot_task_id               pa_tasks.task_id%type;
    l_err_code                 varchar2(200);
    l_err_stage                number;
    l_return_value             varchar2(100);

  BEGIN

       --
       -- Changed for labor costing enhancements
       --
       PA_COST_RATE_PUB.get_labor_rate(p_person_id             =>x_person_id
                                      ,x_job_id                =>l_job_id
                                      ,p_calling_module        =>'STAFFED'
                                      ,p_org_id                => l_org_id         /*2879644*/
                                      ,p_txn_date              =>x_date
                                      ,x_organization_id       =>l_organization_id
                                      ,x_cost_rate             =>x_cost_rate
                                      ,x_start_date_active     =>l_start_date_active
                                      ,x_end_date_active       =>l_end_date_active
                                      ,x_org_labor_sch_rule_id =>l_org_labor_sch_rule_id
                                      ,x_costing_rule          =>l_costing_rule
                                      ,x_rate_sch_id           =>l_rate_sch_id
                                      ,x_cost_rate_curr_code   =>l_cost_rate_curr_code
                                      ,x_acct_rate_type        =>l_acct_rate_type
                                      ,x_acct_rate_date_code   =>l_acct_rate_date_code
                                      ,x_acct_exch_rate        =>l_acct_exch_rate
                                      ,x_ot_project_id         =>l_ot_project_id
                                      ,x_ot_task_id            =>l_ot_task_id
                                      ,x_err_stage             =>l_err_stage
                                      ,x_err_code              =>l_err_code
                                      );

/*
    SELECT
            cd.hourly_cost_rate
      INTO
            X_cost_rate
      FROM
            pa_compensation_details cd
     WHERE
            cd.person_id = X_person_id
       AND  X_date  BETWEEN cd.start_date_active
                        AND nvl( cd.end_date_active, X_date );
*/
    RETURN ( X_cost_rate );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END  GetEmpCostRate;



-- ==========================================================================
-- = FUNCTION  GetExpTypeCostRate
-- ==========================================================================

  FUNCTION  GetExpTypeCostRate ( X_expenditure_type  IN VARCHAR2
                               , X_date              IN DATE ) RETURN NUMBER
  IS
    X_exp_type_cost_rate   NUMBER(22,5);
  BEGIN
    SELECT
            nvl( r.cost_rate, 1 )
      INTO
            X_exp_type_cost_rate
      FROM
            pa_expenditure_cost_rates r
     WHERE
            r.expenditure_type = X_expenditure_type
       AND  X_date  BETWEEN r.start_date_active
                        AND nvl( r.end_date_active, X_date );

    RETURN ( X_exp_type_cost_rate );

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      RETURN ( 1 );
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END  GetExpTypeCostRate;



-- ==========================================================================
-- = FUNCTION  GetEmpJobId
-- ==========================================================================

/* cwk changes: Modified function to derive the job id for a contingent worker person id also */
/* cwk changes: Modified function to derive job id for the entered PO number and line - Bug 4044057 */

  FUNCTION  GetEmpJobId ( X_person_id  IN NUMBER
                        , X_date       IN DATE
                        , X_person_type IN VARCHAR2 DEFAULT NULL
                        , X_po_number IN VARCHAR2 DEFAULT NULL
                        , X_po_line_num IN NUMBER DEFAULT NULL
                        , X_po_header_id IN NUMBER DEFAULT NULL
                        , X_po_line_id IN NUMBER DEFAULT NULL ) RETURN NUMBER
  IS
    X_emp_job_id      NUMBER;
    X_Cross_BG_Profile VARCHAR2(2); /* Added local variable for 3194743 */
    X_business_group_id NUMBER;      /* Added local variable for 3194743 */
    l_person_type VARCHAR2(1) ;
    l_assignment_status VARCHAR2(20);
    l_po_header_id NUMBER;
    l_po_line_id NUMBER;
    l_po_number VARCHAR2(20);
    l_po_line_num NUMBER;

  BEGIN
   If x_person_type is NOT NULL then
       if x_person_type = 'EMP' then
         l_person_type := 'E' ;
         l_assignment_status := 'ACTIVE_ASSIGN' ;
       else
         l_person_type := 'C';
         l_assignment_status := 'ACTIVE_CWK' ;
       end if;
   end if ;

    IF (x_person_id = G_PREV_PERSON_ID AND
        trunc(x_date) = G_PREV_DATE3 AND
        x_po_number is null AND
        x_po_header_id is null) THEN

       RETURN (G_PREV_EMPJOB_ID);

    ELSE

       G_PREV_PERSON_ID := x_person_id;
       G_PREV_DATE3     := trunc(x_date);

    X_Cross_BG_Profile:= pa_utils.IsCrossBGProfile_WNPS; --Moved the function call from inside where clause to here

    SELECT  business_group_id    --Moved selection of BG id from inside where clause to here
    INTO    X_business_group_id
    FROM    pa_implementations;

    If x_po_header_id is not null then --Bug 4044057

       hr_po_info.get_po_for_primary_asg(X_person_id, X_date,l_po_header_id,l_po_line_id);
       /* Bug 6978184 : Added Condition (and not...) */
       if ( (x_po_header_id <> l_po_header_id or x_po_line_id <> l_po_line_id) and not (PO_PA_INTEGRATION_GRP.is_PO_active(X_person_id, X_date,x_po_header_id,x_po_line_id)) ) then
	       RETURN( NULL );
       end if;

    elsIf x_po_number is not null then --Bug 4044057

       hr_po_info.get_po_for_primary_asg(X_person_id, X_date,l_po_header_id,l_po_line_id);

       BEGIN
	       select poh.segment1, pol.line_num
	       into   l_po_number, l_po_line_num
	       from   po_headers poh,
	              po_lines pol
	       where  poh.po_header_id = pol.po_header_id
	       and    poh.po_header_id = l_po_header_id
	       and    pol.po_line_id   = l_po_line_id;
   	   EXCEPTION                                      /* Bug 6978184 : Added Exception Block */
	     WHEN NO_DATA_FOUND THEN
			NULL;
		 WHEN OTHERS THEN
            Raise;
       END;


       if (l_po_number <> x_po_number or l_po_line_num <> x_po_line_num ) then
               /* Bug 6978184 : Added Query and IF below */
		       select poh.po_header_id, pol.po_line_id
		       into   l_po_header_id, l_po_line_id
		       from   po_headers poh,
		              po_lines pol
		       where  poh.po_header_id = pol.po_header_id
			   and    poh.type_lookup_code = 'STANDARD'
		       and    poh.segment1 = x_po_number
		       and    pol.line_num   = x_po_line_num;

   			    if NOT PO_PA_INTEGRATION_GRP.is_PO_active(X_person_id, X_date, l_po_header_id, l_po_line_id) then
					RETURN( NULL );
				end if;
       end if;

    end if;  -- End of Bug 4044057


    If x_person_type IS NULL then

       SELECT
            max(a.job_id)
         INTO
            X_emp_job_id
         FROM
            per_assignment_status_types s
    ,       per_all_assignments_f a     -- Modified for bug 4699231
       WHERE
            a.job_id IS NOT NULL
       AND  a.primary_flag = 'Y'
       AND  X_date BETWEEN trunc( a.effective_start_date )
                       AND trunc( a.effective_end_date   )
       AND  a.person_id = X_person_id
       AND  a.assignment_type in ('E', 'C')
       AND  s.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK','TERM_ASSIGN')
       AND  s.assignment_status_type_id = a.assignment_status_type_id
       /* Added for bug 2009830 */
       AND ((  X_Cross_BG_Profile = 'N'
           AND  X_business_group_id = a.business_group_id+0)
        OR   X_Cross_BG_Profile = 'Y' ) ;
       G_PREV_EMPJOB_ID   := x_emp_job_id;
       RETURN( X_emp_job_id );
/* Bug 7645561 Changed the Query to include TERM_ASSIGN */

    else

       SELECT
            a.job_id
         INTO
            X_emp_job_id
         FROM
            per_assignment_status_types s
    ,       per_all_assignments_f a         -- for Bug 4699231
       WHERE
            a.job_id IS NOT NULL
       AND  a.primary_flag = 'Y'
       AND  X_date BETWEEN trunc( a.effective_start_date )
                       AND trunc( a.effective_end_date   )
       AND  a.person_id = X_person_id
   --    AND  a.assignment_type in ('E', 'C') -- commented out for bug : 3568109
       AND  a.assignment_type = l_person_type
    --   AND  s.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK') -- commented out for bug : 3568109
       AND  s.per_system_status = l_assignment_status
       AND  s.assignment_status_type_id = a.assignment_status_type_id
       /* Added for bug 2009830 */
       AND ((  X_Cross_BG_Profile = 'N'
           AND  X_business_group_id = a.business_group_id+0)
        OR   X_Cross_BG_Profile = 'Y' ) ;
       G_PREV_EMPJOB_ID   := x_emp_job_id;
       RETURN( X_emp_job_id );

    end if ; -- end if for x_person_type
   END IF;

  EXCEPTION
    WHEN  OTHERS  THEN
      G_PREV_PERSON_ID := x_person_id;
      G_PREV_DATE3     := x_date;
      G_PREV_EMPJOB_ID := NULL;
      RETURN( NULL );

  END  GetEmpJobId;

-- ==========================================================================
-- = FUNCTION  GetNextEiId
-- ==========================================================================

  FUNCTION  GetNextEiId  RETURN NUMBER
  IS
    X_expenditure_item_id     NUMBER(15);
  BEGIN
    SELECT
            pa_expenditure_items_s.nextval
      INTO
            X_expenditure_item_id
      FROM
            sys.dual;

    RETURN( X_expenditure_item_id );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN( NULL );

  END  GetNextEiId;

-- ==========================================================================
-- = FUNCTION  CheckExpTypeActive
-- ==========================================================================

  FUNCTION CheckExpTypeActive( X_expenditure_type  IN VARCHAR2
                             , X_date              IN DATE )
                                                 RETURN BOOLEAN
  IS
    dummy     NUMBER;
  BEGIN
    SELECT
            count(*)
      INTO
            dummy
      FROM
            pa_expenditure_types et
     WHERE
            et.expenditure_type = X_expenditure_type
       AND  X_date  BETWEEN et.start_date_active
                        AND nvl( et.end_date_active, X_date );

    IF ( dummy = 0 ) THEN
      RETURN ( FALSE );
    ELSE
      RETURN ( TRUE );
    END IF;

  END  CheckExpTypeActive;


-- ==========================================================================
-- = FUNCTION  get_org_hierarchy_top
-- ==========================================================================

  FUNCTION get_org_hierarchy_top ( X_org_structure_version_id  IN NUMBER )
     RETURN NUMBER
  IS
    X_top_org_id   NUMBER(15);
  BEGIN
-- index on org_structure_version_id is turned off assuming there won't be
-- that many version of org hierarchy. Hence better performance.
-- added the below optimiser hint based on the suggestion of performance team for bug 2474299
    SELECT /*+ index_ffs(se1 PER_ORG_STRUCTURE_ELEMENTS_N50) */
    DISTINCT
             se1.organization_id_parent
       INTO
             X_top_org_id
       FROM
             per_org_structure_elements se1
      WHERE
             se1.org_structure_version_id||'' = X_org_structure_version_id
        AND  NOT exists
         ( SELECT null
             FROM per_org_structure_elements se2
            WHERE se2.org_structure_version_id = X_org_structure_version_id
              AND se2.organization_id_child = se1.organization_id_parent );

    RETURN( X_top_org_id );

  END get_org_hierarchy_top;


-- ==========================================================================
-- = FUNCTION  business_group_id
-- ==========================================================================

  FUNCTION business_group_id RETURN NUMBER
  IS
    X_business_group_id   NUMBER(15);
  BEGIN
    SELECT DISTINCT business_group_id /*Distinct added for Bug 6043451*/
      INTO X_business_group_id
      FROM pa_implementations;

    RETURN(X_business_group_id);

  END business_group_id;

-- ==========================================================================
-- FUNCTION  Get_business_group_id
-- ==========================================================================

  FUNCTION Get_business_group_id RETURN NUMBER
  IS
    l_business_group_id   NUMBER;
  BEGIN
    IF G_Business_Group_Id IS NULL THEN
       l_business_group_id := pa_utils.business_group_id;
    ELSE
       l_business_group_id := G_Business_Group_Id;
    END IF;

    RETURN l_business_group_id;

  EXCEPTION
   WHEN OTHERS THEN RAISE;

  END Get_business_group_id;

-- ==========================================================================
-- PROCEDURE  Set_business_group_id
-- ==========================================================================

  PROCEDURE Set_business_group_id
  IS
  BEGIN
    G_Business_Group_Id := pa_utils.business_group_id;

  END Set_business_group_id;

-- ==========================================================================
-- = FUNCTION  is_project_costing_installed
-- ==========================================================================

  FUNCTION is_project_costing_installed RETURN VARCHAR2
  IS
    x_pa_costing_installed VARCHAR2(2);
  BEGIN

    if (fnd_profile.value('PA_PROJECT_COSTING_INSTALLED') = 'Y') then
	x_pa_costing_installed := 'Y';
    else
	x_pa_costing_installed := 'N';
    end if;
    return(x_pa_costing_installed);

  EXCEPTION
    when OTHERS then
	return('N');
  END is_project_costing_installed;

-- ==========================================================================
-- = FUNCTION  IsCrossChargeable
-- ==========================================================================

  FUNCTION IsCrossChargeable( X_Project_Id  Number )  RETURN BOOLEAN
  IS

     dummy   NUMBER(15);
  BEGIN

   IF (x_project_id = G_PREV_PROJ_ID) THEN

      IF G_PREV_CHARGE = 1 then
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

   ELSE

        Select 1
          Into dummy
          From sys.dual
         Where exists
            ( Select null
                From  pa_projects_expend_v p
               Where p.project_Id = X_project_Id );

        G_PREV_PROJ_ID := x_project_id;

        If dummy = 1 then
           G_PREV_CHARGE     := 1;
           Return TRUE ;
        ELSE
           G_PREV_CHARGE := 0;
           RETURN FALSE;
        End if;

     END IF;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          G_PREV_PROJ_ID := x_project_id;
          G_PREV_CHARGE  := 0;
          return FALSE;
      WHEN OTHERS THEN
          Return TRUE ;
  END ;


-- ==========================================================================
-- = FUNCTION  pa_morg_implemented
-- ==========================================================================

  FUNCTION pa_morg_implemented RETURN VARCHAR2
  IS
    x_dummy   VARCHAR2(1);

  BEGIN

    SELECT 'Y'
      INTO x_dummy
      FROM sys.dual
     WHERE EXISTS (
       SELECT NULL
         FROM pa_implementations_all
        WHERE org_id IS NOT NULL );

    IF ( x_dummy = 'Y' ) THEN
      RETURN( 'Y' );
    ELSE
      RETURN( 'N' );
    END IF;

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN( 'N' );


  END pa_morg_implemented;


-- ==========================================================================
-- = FUNCTION  CheckProjectOrg
-- ==========================================================================

  FUNCTION CheckProjectOrg (x_org_id IN NUMBER) RETURN VARCHAR2 IS

-- This function returns 'Y' if a given org is a project organization ,
-- otherwise , it returns 'N'

CURSOR l_proj_org_csr IS
SELECT DISTINCT 'x'
FROM pa_organizations_proj_all_bg_v
WHERE organization_id = x_org_id;

l_dummy  VARCHAR2(1);
BEGIN

       OPEN l_proj_org_csr;
       FETCH l_proj_org_csr INTO l_dummy;
       IF l_proj_org_csr%NOTFOUND THEN
          CLOSE l_proj_org_csr;
          RETURN 'N';
       ELSE
          CLOSE l_proj_org_csr;
          RETURN 'Y';
       END IF;

EXCEPTION
  WHEN OTHERS THEN
       RETURN 'N';
END CheckProjectOrg;

----------------------------------------------------------------------
-- Function  : get_pa_date
--	Derive PA date from GL date and ei date .
-- This function accepts the expenditure item date and the GL date
-- and derives the period name based on this.  This is mainly used
-- for AP invoices and transactions imported from other systems
-- where the GL date is known in advance and the PA date has to
-- be determined. In the current logic, the PA date is derived solely
-- based on the EI date. The GL date which is passed as a parameter is
-- ignored. However, it is still retained as a parameter in case the
-- logic for the derivation of the PA date is changed on a later date.
-----------------------------------------------------------------------

FUNCTION get_pa_date( x_ei_date  IN date, x_gl_date IN date ) return date
IS
   l_pa_date  date ;
BEGIN

-- The PA date is derived solely from the EI date as the earliest open
-- or future period on or after the EI date...sparames Nov 14, 1997

    SELECT MIN(pap.end_date)
	    INTO l_pa_date
	    FROM pa_periods pap
   	WHERE status in ('O','F')
	  AND pap.end_date >= x_ei_date;

     return(l_pa_date) ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_pa_date :=NULL ;
    WHEN OTHERS THEN
      RAISE ;
END get_pa_date ;

----------------------------------------------------------------------
-- Function  : get_pa_end_date
--	Derive the period end date based on the period name
--
--   This function accepts the period name and gets the period end
--   date from the pa_periods table.  The function created for
--   burden cost accounting.
--   Created by Sandeep 04-MAR-1998
-----------------------------------------------------------------------

FUNCTION get_pa_end_date( x_pa_period_name IN VARCHAR2 ) return date
IS
   l_pa_end_date  date ;
BEGIN

    SELECT pap.end_date
	    INTO l_pa_end_date
	    FROM pa_periods pap
   	WHERE pap.period_name = x_pa_period_name;

     return(l_pa_end_date) ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_pa_end_date :=NULL ;
    WHEN OTHERS THEN
       RAISE ;
END get_pa_end_date ;

------------------------------------------------------------------
-- Function  : get_pa_period_name
--	Derive PA date from GL date and ei date .
-- This function accepts the expenditure item date and the GL date
-- and derives the period name based on this.  This is mainly used
-- for AP invoices and transactions imported from other systems
-- where the GL date is known in advance and the PA date has to
-- be determined. This function is identical to the
-- pa_date_from_gl_date function except that it returns the
-- corresponding period name instead of the PA date
-------------------------------------------------------------------

FUNCTION get_pa_period_name( x_ei_date  IN date, x_gl_date IN date ) return varchar2
IS
   l_period_name  pa_periods_all.period_name%TYPE;
BEGIN

-- The PA date is derived as the end date of the earliest open or
-- future PA period on or after the EI date. The GL date which is
-- passed as a parameter to this function is not used at present but
-- is retained for future use...sparames Nov 14,1997

 SELECT pa_periods.period_name
   INTO l_period_name
   FROM pa_periods
  WHERE pa_periods.end_Date =
    (SELECT MIN(pap.end_date)
	    FROM pa_periods pap
   	WHERE status in ('O','F')
	  AND pap.end_date >= x_ei_date)
  AND  status in ('O','F'); /* Added the check for bug #1550929 */

     return(l_period_name) ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_period_name :=NULL ;
    WHEN OTHERS THEN
    RAISE ;
END get_pa_period_name;

-- ==========================================================================
-- = FUNCTION  GetETypeClassCode
-- ==========================================================================

  FUNCTION GetETypeClassCode ( X_system_linkage IN VARCHAR2)  RETURN VARCHAR2
  IS
  etypeclass_code VARCHAR2(3) ;
  BEGIN

   IF (X_system_linkage = G_PREV_SYS_LINK) THEN

       RETURN (G_PREV_FUNCTION);
   ELSE

        G_PREV_SYS_LINK := X_system_linkage;

        SELECT function
          INTO etypeclass_code
          FROM pa_system_linkages
         WHERE function = X_system_linkage ;

        G_PREV_FUNCTION := etypeclass_code;
        RETURN( etypeclass_code ) ;

   END IF;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
         G_PREV_SYS_LINK := X_system_linkage;
         G_PREV_FUNCTION := NULL;
         etypeclass_code := NULL ;
         RETURN( etypeclass_code ) ;
  END GetEtypeClassCode;

-- ==========================================================================
-- = FUNCTION  Get_Org_Window_Title
-- ==========================================================================
/* These comments are added for bug 1812275.
   Please have a look at the solution provided in this bug if you face any issue
   with this procedure like no_data_found in pa_implementations.
   We are not suppressing any exceptions because and exception should be raised
   if there are no records found in pa_implementations
*/


  FUNCTION Get_Org_Window_Title RETURN VARCHAR2
  IS

  l_multi_org           VARCHAR2(1);
  l_multi_cur           VARCHAR2(1);
  /* Bug 2657833 - UTF8 change Impact */
  /* l_wnd_context         VARCHAR2(80); */
  l_wnd_context         HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
  l_id                  VARCHAR2(15);

BEGIN

  /*
  ***
  *** Get multi-org and MRC information on the current
  *** product installation.
  ***
   */

  SELECT        nvl(multi_org_flag, 'N')
                   ---- Bug#MRC_SCHEMA_ELIM , nvl(multi_currency_flag, 'N')
  INTO          l_multi_org
                   ---,             l_multi_cur
  FROM          fnd_product_groups;

   --Added this check that does the same job as the above select
   If  gl_mc_info.alc_enabled(275) Then -- 12i MOAC changes
   -- IF  gl_mc_info.mrc_enabled(275) THEN -- 12i MOAC changes
       l_multi_cur := 'Y';
   ELSE
       l_multi_cur := 'N';
   END IF;

  /*
  ***
  *** Case #1 : Non-Multi-Org or Multi-SOB
  ***
  ***  A. MRC not installed, OR
  ***     MRC installed, Non-Primary/Reporting Books
  ***       Form Name (SOB Short Name) - Context Info
  ***       e.g. Maintain Forecast(US OPS) - Forecast Context Info
  ***
  ***  B. MRC installed, Primary Books
  ***       Form Name (SOB Short Name: Primary Currency) - Context Info
  ***       e.g. Maintain Forecast(US OPS: USD) - Forecast Context Info
  ***
  ***  C. MRC installed, Reporting Books
  ***       Form Name (SOB Short Name: Reporting Currency) - Context Info
  ***       e.g. Maintain Forecast(US OPS: EUR) - Forecast Context Info
  ***
   */
  IF (l_multi_org = 'N') THEN

    select      g.short_name ||
                  decode(g.mrc_sob_type_code, 'N', NULL,
                    decode(l_multi_cur, 'N', NULL,
                      ': ' || g.currency_code))
    into        l_wnd_context
    from        gl_sets_of_books g
    ,           pa_implementations c
    where       c.set_of_books_id = g.set_of_books_id;

  /*
  ***
  *** Case #2 : Multi-Org
  ***
  ***  A. MRC not installed, OR
  ***     MRC installed, Non-Primary/Reporting Books
  ***       Form Name (OU Name) - Context Info
  ***       e.g. Maintain Forecast(US West) - Forecast Context Info
  ***
  ***  B. MRC installed, Primary Books
  ***       Form Name (OU Name: Primary Currency) - Context Info
  ***       e.g. Maintain Forecast(US West: USD) - Forecast Context Info
  ***
  ***  C. MRC installed, Reporting Books
  ***       Form Name (OU Name: Reporting Currency) - Context Info
  ***       e.g. Maintain Forecast(US West: EUR) - Forecast Context Info
  ***
   */
  ELSE

    -- start 12i MOAC changes
    -- FND_PROFILE.GET ('ORG_ID', l_id);
    l_id := Pa_Moac_Utils.Get_Current_Org_Id;
    -- end 12i MOAC changes

    /* Bug 2657833 - UTF8 change Impact, Using substr for organization name,
       selecting length 55 instead of 60 as 5 characters(for currency code) are concatenated here*/
   /* Bug6884654 - Changed substr to substrb  */
    select      substrb(h.name,1,55) ||
                  decode(g.mrc_sob_type_code, 'N', NULL,
                    decode(l_multi_cur, 'N', NULL,
                      ': ' || g.currency_code))
    into        l_wnd_context
    from        gl_sets_of_books g
    ,           pa_implementations c
    ,           hr_operating_units h
    where       h.organization_id = to_number(l_id)
    and         c.set_of_books_id = g.set_of_books_id;


  END IF;

  return l_wnd_context;


  END Get_Org_Window_Title;

---------------------------------------------------------------
-- Procedure : Get_Encoded_Msg
--    This procedure serves as a wrapper to the function
--    FND_MSG_PUB.Get.  It is needed to access the call from
--    client FORMS.
---------------------------------------------------------------

Procedure Get_Encoded_Msg(p_index	IN   	NUMBER,
			  p_msg_out	IN OUT  NOCOPY VARCHAR2 ) IS
  l_message	VARCHAR2(2000);
BEGIN
  p_msg_out := fnd_msg_pub.get(p_msg_index => p_index,
			       p_encoded   => FND_API.G_FALSE);

END Get_Encoded_Msg;


---------------------------------------------------------------
-- Procedure : Add_Message
--    This procedure serves as a wrapper to the FND_MEG_PUB
--    procedures to add the specified message onto the message
--    stack.
-- 25-APR-02 MAnsari  Modified call FND_MESSAGE.SET_NAME to
--                    use SUBSTR.
---------------------------------------------------------------

Procedure Add_Message( p_app_short_name	IN	VARCHAR2,
		       p_msg_name	IN	VARCHAR2,
		       p_token1		IN	VARCHAR2 ,
		       p_value1		IN	VARCHAR2 ,
		       p_token2		IN	VARCHAR2 ,
		       p_value2		IN	VARCHAR2 ,
		       p_token3		IN	VARCHAR2 ,
		       p_value3		IN	VARCHAR2 ,
		       p_token4		IN	VARCHAR2 ,
		       p_value4		IN	VARCHAR2 ,
		       p_token5		IN	VARCHAR2 ,
		       p_value5		IN	VARCHAR2 ) IS

BEGIN

  FND_MESSAGE.Set_Name(p_app_short_name, SUBSTR( p_msg_name, 1, 30 ));
  IF (p_token1 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token1, p_value1);
  END IF;
  IF (p_token2 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token2, p_value2);
  END IF;
  IF (p_token3 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token3, p_value3);
  END IF;
  IF (p_token4 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token4, p_value4);
  END IF;
  IF (p_token5 IS NOT NULL) THEN
    FND_MESSAGE.Set_Token(p_token5, p_value5);
  END IF;

  FND_MSG_PUB.Add;

END Add_Message;


--------------------------------------------------------------
FUNCTION IsCrossBGProfile_WNPS
RETURN VARCHAR2

IS

BEGIN

  RETURN(FND_PROFILE.VALUE_WNPS('HR_CROSS_BUSINESS_GROUP'));

EXCEPTION
  WHEN OTHERS THEN
    RAISE ;

END IsCrossBGProfile_WNPS ;
--------------------------------------------------------------

---------------------------------------------------------------
-- Function : Conv_Special_JS_Chars
-- This function converts special characters in javascript link.
-- Currently, this function only handles apostrophe sign.
---------------------------------------------------------------
FUNCTION Conv_Special_JS_Chars(p_string in varchar2) RETURN VARCHAR2
 IS

 BEGIN

   RETURN icx_util.replace_quotes(p_string);

 END Conv_Special_JS_Chars;

---------------------------------------------------------------
-- Function :Pa_Round_Currency
-- This function rounds the amount to the required precsion based
-- on the currency code
---------------------------------------------------------------
FUNCTION Pa_Round_Currency
                         (P_Amount         IN NUMBER
                         ,P_Currency_Code  IN VARCHAR2)
RETURN NUMBER IS
  l_rounded_amount  NUMBER;
BEGIN

  SELECT  decode(FC.minimum_accountable_unit,
            NULL, round(P_Amount, FC.precision),
                  round(P_Amount/FC.minimum_accountable_unit) *
                               FC.minimum_accountable_unit)
  INTO    l_rounded_amount
  FROM    fnd_currencies FC
  WHERE   FC.currency_code = P_Currency_Code;

  RETURN(l_rounded_amount);

EXCEPTION

  WHEN NO_DATA_FOUND THEN
     RETURN (NULL);
END PA_ROUND_CURRENCY;

---------------------------------------------------------------
FUNCTION get_party_id (
                        p_user_id in number )
 return number
 IS
    Cursor external is
    select person_party_id from fnd_user -- For Bug 4527617.
    where user_id = p_user_id;

    Cursor internal is
    select h.party_id
    from hz_parties h
    ,fnd_user f
    where h.orig_system_reference = CONCAT('PER:',f.employee_id)
    and f.user_id = p_user_id;

    l_party_id number;

    Begin
        Open internal;
        fetch internal into l_party_id;
            if (internal%NOTFOUND) then
                l_party_id := NULL;
            end if;
        close internal;

        if (l_party_id IS NULL) then
            Open external;
            fetch external into l_party_id;
                if (external%NOTFOUND) then
                    l_party_id := NULL;
                end if;
            close external;
        end if;

  return l_party_id;
 Exception
  When others then
   RAISE;
 End get_party_id;

--
/*==========================================================================*/

--  PROCEDURE GetEmpOrgJobId
--
/*==========================================================================*/

/* cwk changes : Modified Procedure to derive the organization and job for a contingent worker person Id also */
/* cwk changes: Modified function to derive job id for the entered PO number and line - Bug 4044057 */

  PROCEDURE  GetEmpOrgJobId ( X_person_id  IN NUMBER
                            , X_date       IN DATE
                            , X_Emp_Org_Id OUT NOCOPY NUMBER
                            , X_Emp_Job_Id OUT NOCOPY NUMBER
                            , X_po_number IN VARCHAR2 DEFAULT NULL --Bug 4044057
                            , X_po_line_num IN NUMBER DEFAULT NULL ) --Bug 4044057
  IS
  l_po_header_id NUMBER;
  l_po_line_id NUMBER;
  l_po_number VARCHAR2(20);
  l_po_line_num NUMBER;
  X_Cross_BG_Profile VARCHAR2(2);  /*Bug 6355926*/

  BEGIN
    X_Cross_BG_Profile := pa_utils.IsCrossBGProfile_WNPS;   /*Bug 6355926*/
    If (G_PersonIdPrev    = X_Person_Id  AND
        trunc(G_DatePrev) = trunc(X_Date) AND
        x_po_number is null AND
        x_po_line_num is null) Then

        X_Emp_Org_Id := G_EmpOrgId;
        X_Emp_Job_Id := G_EmpJobId;

    Else

     If x_po_number is not null then -- Bug 4044057

       hr_po_info.get_po_for_primary_asg(X_person_id, X_date,l_po_header_id,l_po_line_id);

	   BEGIN
		   select poh.segment1, pol.line_num
		   into   l_po_number, l_po_line_num
		   from   po_headers poh,
				  po_lines pol
		   where  poh.po_header_id = pol.po_header_id
		   and    poh.po_header_id = l_po_header_id
		   and    pol.po_line_id   = l_po_line_id;
	   EXCEPTION                                      /* Bug 6978184 : Added Exception Block */
	     WHEN NO_DATA_FOUND THEN
			NULL;
		 WHEN OTHERS THEN
            Raise;
       END;


       if (l_po_number <> x_po_number or l_po_line_num <> x_po_line_num) then
               /* Bug 6978184 : Added Query and IF below */
		       select poh.po_header_id, pol.po_line_id
		       into   l_po_header_id, l_po_line_id
		       from   po_headers poh,
		              po_lines pol
		       where  poh.po_header_id = pol.po_header_id
			   and    poh.type_lookup_code = 'STANDARD'
		       and    poh.segment1 = x_po_number
		       and    pol.line_num   = x_po_line_num;

   			    if NOT PO_PA_INTEGRATION_GRP.is_PO_active(X_person_id, X_date, l_po_header_id, l_po_line_id) then
			  	     X_emp_job_id := NULL;
			         X_Emp_Org_Id := NULL;
			         RETURN;
				end if;
       end if;

     end if;  -- End of Bug 4044057

     SELECT
            a.job_id,
            a.organization_id
     INTO
            X_emp_job_id,
            X_Emp_Org_Id
     FROM
            per_assignment_status_types s
         ,       per_all_assignments_f a  -- modified for Bug 4699231
         ,       pa_implementations i
     WHERE
            a.job_id IS NOT NULL
       AND  a.primary_flag = 'Y'
       AND  trunc(X_date) BETWEEN trunc( a.effective_start_date )
                         AND trunc( a.effective_end_date   )
       AND  a.person_id = X_person_id
       AND  ((X_Cross_BG_Profile ='N' AND a.business_group_id = i.business_group_id) OR
              X_Cross_BG_Profile ='Y')    /*bug6355926*/
       AND  a.assignment_type in ('E', 'C')
       AND  s.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK')
       AND  s.assignment_status_type_id = a.assignment_status_type_id;

       G_EmpOrgId := X_Emp_Org_Id;
       G_EmpJobID := X_Emp_Job_Id;
       G_PersonIdPrev := X_Person_Id;
       G_DatePrev := X_Date;

    End If;


  EXCEPTION
    WHEN  OTHERS  THEN
       G_PersonIdPrev := X_Person_Id;
       G_DatePrev := X_Date;
       X_emp_job_id := NULL;
       X_Emp_Org_Id := NULL;

  END  GetEmpOrgJobId;

-- ==========================================================================
-- = FUNCTION  NewGetWeekEnding
-- ==========================================================================

  FUNCTION  NewGetWeekEnding ( X_date  IN DATE ) RETURN DATE
  IS

    X_week_ending       DATE;
    X_week_ending_day   VARCHAR2(80);
    X_week_ending_day_index   number;
    x_week_start number; /*Bug 7601460 */
    l_Found		BOOLEAN := FALSE;

  BEGIN

	Begin

	select exp_cycle_start_day_code into x_week_start from pa_implementations; /*Bug 7601460 */

		-- Check if there are any records in the pl/sql table.
		If G_WeekEndDateTab.COUNT > 0 Then

			-- Get the Project Number from the pl/sql table.
               		-- If there is no index with the value of the project_id passed
               		-- in then an ora-1403: no_data_found is generated.
			X_Week_Ending := G_WeekEndDateTab(to_number(to_char(X_Date,'YYYYMMDD')||to_char(x_week_start))); /*Bug 7601460 */
			l_Found := TRUE;

		End If;

	Exception
		When No_Data_Found Then
			X_Week_Ending := null;
			l_Found := FALSE;
		When Others Then
			RAISE;

	End;

	If Not l_Found Then

                -- Since the ei date has not been cached yet, will need to add it.
                -- So check to see if there are already 200 records in the pl/sql table.
		-- We don't want the pl/sql table to get large than 200 records.
                If G_WeekEndDateTab.COUNT > 200 Then

                        G_WeekEndDateTab.Delete;

                End If;

       		SELECT decode( exp_cycle_start_day_code, 1, 8, exp_cycle_start_day_code )-1
         	into X_week_ending_day_index
         	FROM pa_implementations;

       		select to_char(to_date('01-01-1950','DD-MM-YYYY') +X_week_ending_day_index-1, 'Day')
         	into X_week_ending_day
		from dual;

       		SELECT Next_Day( trunc( X_date )-1, X_Week_Ending_Day )  /* BUG#3118592 */
         	INTO   X_Week_Ending
         	FROM sys.dual;

		-- Add the week ending date to the pl/sql table using the ei date
                -- as the index value.
			G_WeekEndDateTab(to_number(to_char(X_date,'YYYYMMDD')||to_char(x_week_start))) := X_Week_Ending; /*Bug 7601460 */

	End If;

       	RETURN ( X_Week_Ending );

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( NULL );

  END  NewGetWeekEnding;

/* Added for bug 5067511 */

-- ==========================================================================
-- FUNCTION  GetPersonInfo : Used only in the view PA_PROJECT_PLAYERS_V
-- Returns the requested data in l_data.  Returns 'NOT_FOUND' when no records
-- found or invalid l_data
-- This Function Can also be used whenever pa_employees is not scanned by index and we want to force index scan on pa_employees view.
-- ==========================================================================

  FUNCTION  GetPersonInfo( p_person_id IN per_all_people_f.person_id%TYPE,
                           p_data IN VARCHAR2 DEFAULT 'PERSON_ID') RETURN VARCHAR2
  IS
  BEGIN
	If NVL(L_PERSON_ID, 0) <> p_person_id Then
	    Begin
		select PERSON_ID
		   , FULL_NAME
		   , LAST_NAME
		   , FIRST_NAME
		   , MIDDLE_NAMES
		   , EMPLOYEE_NUMBER
		into
		   L_PERSON_ID
 		 , L_PERSON_FULL_NAME
		 , L_PERSON_LAST_NAME
		 , L_PERSON_FIRST_NAME
		 , L_PERSON_MIDDLE_NAMES
		 , L_PERSON_EMPLOYEE_NUMBER
		from pa_employees where person_id = p_person_id;
	    Exception
  	        When No_Data_Found Then
		    RETURN('NOT_FOUND');
            END;
	End If;

        If p_data = 'PERSON_ID' Then
	    Return ('FOUND');
	End If;
	If p_data = 'FULL_NAME' Then
	    Return (L_PERSON_FULL_NAME);
	End If;
        If p_data = 'LAST_NAME' Then
	    Return (L_PERSON_LAST_NAME);
	End If;
	If p_data = 'FIRST_NAME' Then
	    Return (L_PERSON_FIRST_NAME);
	End If;
	If p_data = 'MIDDLE_NAMES' Then
	    Return (L_PERSON_MIDDLE_NAMES);
	End If;
	If p_data = 'EMPLOYEE_NUMBER' Then
	    Return (L_PERSON_EMPLOYEE_NUMBER);
	End If;

	Return ('NOT_FOUND');
  END GetPersonInfo;

END pa_utils;

/
