--------------------------------------------------------
--  DDL for Package Body PO_EMPLOYEES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_EMPLOYEES_SV" as
/*$Header: POXEMEMB.pls 120.3.12010000.7 2014/02/18 09:29:35 rkandima ship $*/

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');

-- Bug 4664653 START
g_emp_id        NUMBER;
g_emp_name      PER_EMPLOYEES_CURRENT_X.FULL_NAME%TYPE;
g_location_id   NUMBER;
g_location_code HR_LOCATIONS.LOCATION_CODE%TYPE;
g_is_buyer      BOOLEAN;
g_emp_flag      BOOLEAN;
g_user_id       NUMBER;
-- Bug 4664653 END



/*=============================================================================
  Name: GET_EMPLOYEE() : PO Employee Request Information
  Desc: Returns information relevant to employees
  Args: emp_id           - OUT  :  employee id
        emp_name         - OUT  :  employee name
        location_id      - OUT  :  location id
        location_code    - OUT  :  location code
        is_buyer         - OUT  :  is employee a buyer?
        emp_flag         - OUT  :  returns true if user is an employee
                                   else returns false
  Reqs: No preconditions and no input variables
  Err : Returns FALSE if error. Error message written on message stack
  Algr: get user id of current user
        get emp_id, emp_name and location_id from hr_employees_cur_v
        if NO ROWS return false
        get location_code from hr_locations
        check if employee is a buyer
  Note: If user is an employee then emp_flag is TRUE
        else emp_flag will be FALSE.
        If the employee has a location then location_id will point to his
        location id else location_id will be 0.
=============================================================================*/

FUNCTION get_employee (emp_id OUT NOCOPY number,
		   emp_name OUT NOCOPY varchar2,
		   location_id OUT NOCOPY number,
		   location_code OUT NOCOPY varchar2,
		   is_buyer OUT NOCOPY BOOLEAN,
                   emp_flag OUT NOCOPY BOOLEAN
		  )
RETURN BOOLEAN IS

X_user_id varchar2(80);  /* stores the user id */
X_emp_id	NUMBER := 0 ;		/*   stores the employee_id */
X_location_id	NUMBER := 0 ;		/*   stores the location_id */
X_emp_name	VARCHAR2(240) := '' ;	/* stores the employee_name */
l_cwk_profile VARCHAR2(1);

/** PO UTF8 Column Expansion Project 9/18/2002 tpoon **/
/** Changed X_location_code to use %TYPE **/
-- X_location_code VARCHAR2(20) := '' ;	/* stores the employee location */
X_location_code hr_locations_all.location_code%TYPE := ''; /* stores the employee location */

X_buyer_code VARCHAR2(1) := 'Y' ; 	/* dummy, stores buyer status */
mesg_buffer	VARCHAR2(2000) := '' ;  /* for handling error messages */
X_progress varchar2(3) := '';

BEGIN
    /* get user id */

    FND_PROFILE.GET('USER_ID', X_user_id);
    if X_user_id is null then
      -- dbms_output.put_line('Xuserid is Null');
      -- po_message_s.app_error('PO_ALL_SQL_ERROR');
       return False;
    end if;


    -- Bug 4664653 START
    -- Return the global variables, if the user_id is already cached.
    IF X_user_id = Nvl(g_user_id,-99) THEN
       emp_id        := g_emp_id;
       emp_name      := g_emp_name;
       location_id   := g_location_id;
       location_code := g_location_code;
       is_buyer      := g_is_buyer;
       emp_flag      := g_emp_flag;

       -- Retrun itself.
       RETURN TRUE;
    END IF;
    -- Bug 4664653 END


    BEGIN


         X_progress := '010';

    --<R12 CWK Enhancemment start>
     FND_PROFILE.GET('HR_TREAT_CWK_AS_EMP', l_cwk_profile);

     IF l_cwk_profile = 'N' then

    /* get emp_id, emp_name and location_id */

        -- Bug 4664653
        -- Add to_number to x_user_id
--Bug 13552967
--Included Exception block to avoid failure of below
--sql by bug 10413227
BEGIN
SELECT HR.EMPLOYEE_ID,
                    HR.FULL_NAME,
                    NVL(hr.LOCATION_ID,0)
             INTO   X_emp_id,
                    X_emp_name,
                    X_location_id
             FROM   FND_USER FND, hr_operating_units org, (SELECT p.person_id employee_id, p.full_name, a.SET_OF_BOOKS_ID , a.location_id
                 FROM PER_PEOPLE_F P,
                 PER_ALL_ASSIGNMENTS_F A,
                 PER_PERIODS_OF_SERVICE B
                 WHERE A.PERSON_ID = P.PERSON_ID
                 --AND A.PRIMARY_FLAG = 'Y'
                 AND A.ASSIGNMENT_TYPE = 'E'
                 AND A.PERIOD_OF_SERVICE_ID = B.PERIOD_OF_SERVICE_ID
                 AND TRUNC(SYSDATE) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE
                 AND TRUNC(SYSDATE) BETWEEN A.EFFECTIVE_START_DATE AND A.EFFECTIVE_END_DATE
                 AND (B.ACTUAL_TERMINATION_DATE>= trunc(sysdate) or B.ACTUAL_TERMINATION_DATE is null)
                 AND P.EMPLOYEE_NUMBER IS NOT NULL
                 ORDER BY PRIMARY_FLAG desc) hr
             WHERE  FND.USER_ID = X_user_id
             AND    FND.EMPLOYEE_ID = hr.EMPLOYEE_ID
             AND    hr.set_of_books_id = org.set_of_books_id
             AND    org.organization_id = fnd_global.org_id
             AND    ROWNUM = 1;

	     EXCEPTION
	     WHEN OTHERS THEN
	     x_location_id := 0;
	     END;

      IF (X_location_id = 0) THEN

        SELECT HR.EMPLOYEE_ID,
               HR.FULL_NAME,
               NVL(HR.LOCATION_ID,0)
        INTO   X_emp_id,
               X_emp_name,
               X_location_id
        FROM   FND_USER FND, PER_EMPLOYEES_CURRENT_X HR
        WHERE  FND.USER_ID = TO_NUMBER(X_user_id)
        AND    FND.EMPLOYEE_ID = HR.EMPLOYEE_ID
        AND    ROWNUM = 1;

     END IF ;
	/* DEBUG:
	** GK:This column has been obsoleted by AOL.  Need to check
	** on the implications of this change
        */
        --AND    FND.PERSON_TYPE = 'E'

    /* if no rows selected
       then user is not an employee
       else user is an employee */

    ELSE

        -- Bug 4664653
        -- Add to_number to x_user_id

	--Bug 13552967
--Included Exception block to avoid failure of below
--sql by bug 10413227
-- subquery merged with main queyr as part of bug:15924594 to improve the performance.
BEGIN
SELECT HR.EMPLOYEE_ID,
               HR.FULL_NAME,
               NVL(HR.LOCATION_ID,0)
        INTO   X_emp_id,
               X_emp_name,
               X_location_id
        FROM   ( SELECT employee_id,
                       full_name,
                       set_of_books_id,
                       location_id,
                       primary_flag
        FROM   (SELECT p.person_id employee_id,
                  p.full_name,
                  a.set_of_books_id,
                  a.location_id,
                  a.primary_flag
                FROM per_people_f p,
                  per_all_assignments_f a,
                  per_periods_of_service ps,
                  fnd_user fnd,
                  hr_operating_units org
                WHERE a.person_id          = p.person_id
                AND a.person_id            = ps.person_id
                AND a.assignment_type      = 'E'
                AND p.employee_number     IS NOT NULL
                AND a.period_of_service_id = ps.period_of_service_id
                  --  AND a.primary_flag = 'Y'
                AND TRUNC(SYSDATE) BETWEEN p.effective_start_date AND p.effective_end_date
                AND TRUNC(SYSDATE) BETWEEN a.effective_start_date AND a.effective_end_date
                AND ( ps.actual_termination_date >= TRUNC(SYSDATE)
                OR ps.actual_termination_date    IS NULL )
                AND fnd.user_id                   = TO_NUMBER(X_user_id)
                AND fnd.employee_id               = p.person_id
                AND a.set_of_books_id             = org.set_of_books_id
                AND org.organization_id           = fnd_global.org_id
                UNION ALL
                SELECT p.person_id employee_id,
                  p.full_name,
                  a.set_of_books_id,
                  a.location_id,
                  a.primary_flag
                FROM per_people_f p,
                  per_all_assignments_f a,
                  per_periods_of_placement pp,
                  fnd_user fnd,
                  hr_operating_units org
                WHERE a.person_id                    = p.person_id
                AND a.person_id                      = pp.person_id
                AND a.assignment_type                = 'C'
                AND p.npw_number                    IS NOT NULL
                AND a.period_of_placement_date_start = pp.date_start
                  --   AND a.primary_flag = 'Y'
                AND TRUNC(SYSDATE) BETWEEN p.effective_start_date AND p.effective_end_date
                AND TRUNC(SYSDATE) BETWEEN a.effective_start_date AND a.effective_end_date
                AND ( pp.actual_termination_date >= TRUNC(SYSDATE)
                OR pp.actual_termination_date    IS NULL )
                AND fnd.user_id                   = TO_NUMBER(X_user_id)
                AND fnd.employee_id               = p.person_id
                AND a.set_of_books_id             = org.set_of_books_id
                AND org.organization_id           = fnd_global.org_id
                )
                ORDER BY primary_flag desc) HR
        WHERE   ROWNUM = 1;
	 EXCEPTION
	 WHEN OTHERS THEN
	  x_location_id := 0;
	 END;

IF  (X_location_id = 0) THEN


         SELECT HR.PERSON_ID,
               HR.FULL_NAME,
               NVL(HR.LOCATION_ID,0)
        INTO   X_emp_id,
               X_emp_name,
               X_location_id
        FROM   FND_USER FND, PER_WORKFORCE_CURRENT_X HR
        WHERE  FND.USER_ID = TO_NUMBER(X_user_id)
        AND    FND.EMPLOYEE_ID = HR.PERSON_ID
        AND    ROWNUM = 1;

END IF ;

   END IF;
   --<R12 CWK Enhancemment End>

    -- R12 CWK Enhancemment
    -- emp_flag would now refelect whether  either an employee
    --   or Contigent Worker setup as employee is valid
     emp_flag := TRUE;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		/* the user is not an employee */
		emp_flag := FALSE ;

		-- Bug 4664653. Need not return at this stage.
		-- Go ahead and complete the procedure.
		-- return(TRUE) ;

	WHEN OTHERS THEN
		po_message_s.sql_error('poxpoeri',X_progress,sqlcode);
                raise;
    END ;


    /* get location_code */

    IF (X_location_id <> 0) THEN
    BEGIN

         X_Progress := '020';

        /* if location id belongs to an org
              if the org is in the current set of books
                 return location code
              else
                 return location id is 0

         */
            --<R12 MOAC removed FSP from the query>
            SELECT HR.LOCATION_CODE
	    INTO   X_location_code
            FROM   HR_LOCATIONS HR,
		   ORG_ORGANIZATION_DEFINITIONS OOD
            WHERE  HR.LOCATION_ID = X_location_id
	    AND    HR.INVENTORY_ORGANIZATION_ID = OOD.ORGANIZATION_ID (+) ;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		X_location_id := 0 ;
	WHEN OTHERS THEN
		po_message_s.sql_error('poxpoeri',X_progress,sqlcode);
                raise;
    END ;
    END IF ;

    /* check if employee is a buyer */
    -- Bug 4664653. Check for buyer only if employee id is not null
    --
    IF (NVL(x_emp_id, 0) <> 0) THEN
      BEGIN

        X_progress := '030';

        SELECT 'Y'
        INTO   X_buyer_code
        FROM   PO_AGENTS
        WHERE  agent_id = X_emp_id
        AND    SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE - 1)
                       AND NVL(END_DATE_ACTIVE, SYSDATE + 1);

        /* if no rows returned
           then user is not a buyer
           else user is a buyer */

       is_buyer := TRUE ;

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
		/* user is not a buyer */
		is_buyer := FALSE ;
	WHEN OTHERS THEN
		po_message_s.sql_error('get_employee',X_progress,sqlcode);
                raise;
      END ;
    END IF;


    /* assign all the local variables to the parameters */

    emp_id := X_emp_id;
    emp_name := X_emp_name ;


    IF (X_location_id <> 0) THEN
        location_id :=  X_location_id ;
	location_code := X_location_code ;
    ELSE
/*Bug 2105925. We should not be passing 0 for the location_id if it is
               not found. Instead we have to return null.
*/
        location_id := '' ;
	location_code := '' ;
    END IF ;

    -- Bug 4664653 START
    -- Cache the information in global variables for later use
    --
    g_emp_id        := emp_id;
    g_emp_name      := emp_name;
    g_location_id   := location_id;
    g_location_code := location_code;
    g_is_buyer      := is_buyer;
    g_emp_flag      := emp_flag;
    g_user_id       := X_user_id;

    -- Bug 4664653 END
    return(TRUE);



exception
     when others then
      po_message_s.sql_error('get_employee','000', sqlcode);
      raise;

END get_employee ;

/*===========================================================================

  PROCEDURE NAME:       test_online_user

===========================================================================*/

  PROCEDURE test_online_user (x_person_id NUMBER) IS
	x_online_user       BOOLEAN;
	x_str  VARCHAR2(30);
  BEGIN

    --dbms_output.put_line('before call');


    x_online_user := po_employees_sv.online_user(x_person_id);

    --dbms_output.put_line('after call');
    If x_online_user = TRUE THEN
	x_str := 'TRUE';
    ELSE
	x_str := 'FALSE';
    END IF;

    --dbms_output.put_line('Return Value =' ||x_str);

  END;

/*===========================================================================

  PROCEDURE NAME:	online_user

===========================================================================*/

FUNCTION online_user (x_person_id NUMBER) RETURN BOOLEAN IS
    x_progress	  VARCHAR2(3) := '';
    x_data_exists NUMBER := 0;
BEGIN

    IF x_person_id IS NOT NULL THEN

        x_progress := '010';

        SELECT count(*)
        INTO   x_data_exists
        FROM   fnd_user
        WHERE  employee_id = x_person_id
        AND    sysdate < nvl(end_date, sysdate + 1);
	/* DEBUG:
	** GK:This column has been obsoleted by AOL.  Need to check
	** on the implications of this change
        */
	-- AND    person_type = 'E'

    ELSE
	return(FALSE);
    END IF;

    x_progress := '020';
    IF x_data_exists > 0 THEN
	return TRUE;
    ELSE
	return FALSE;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	--dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('PO_EMPLOYEES_SV.ONLINE_USER', x_progress, sqlcode);
        RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       test_get_employee_name

===========================================================================*/

  PROCEDURE test_get_employee_name (x_emp_id   IN NUMBER) IS
        x_emp_name	VARCHAR2(30) := '';
  BEGIN

    --dbms_output.put_line('before call');

    get_employee_name (x_emp_id, x_emp_name) ;


    --dbms_output.put_line('after call');
    --dbms_output.put_line('Employee Name ='||x_emp_name);

  END;

/*===========================================================================

  PROCEDURE NAME:	get_employee_name

===========================================================================*/

PROCEDURE get_employee_name (x_emp_id    IN   NUMBER,
			     x_emp_name  OUT NOCOPY  VARCHAR2) IS
      x_progress	  VARCHAR2(3) := '';
BEGIN

    IF x_emp_id IS NOT NULL THEN

        x_progress := '010';

    /* bug 1845314 replaced hr_employees with per_employees_current_x
       for global supervisor support */
        SELECT full_name
        INTO   x_emp_name
        FROM   po_workforce_current_x   --<BUG 6615913>
        WHERE  person_id = x_emp_id;

    ELSE
	x_progress := '015';
	x_emp_name := '';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	--dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('GET_EMPLOYEE_NAME', x_progress, sqlcode);
	RAISE;
END get_employee_name;

/*===========================================================================

  PROCEDURE NAME:	derive_employee_info()

===========================================================================*/

 PROCEDURE derive_employee_info (
               p_emp_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Employee_id_record_type) IS

 cid            INTEGER;
 rows_processed INTEGER;
 sql_str        VARCHAR2(2000);

 Emp_name_null  BOOLEAN := TRUE;
 Emp_id_null    BOOLEAN := TRUE;

 BEGIN

    sql_str := 'select hr_employees.full_name, hr_employees.employee_id from hr_employees where ';

    IF p_emp_record.employee_id    IS NULL   and
       p_emp_record.employee_name  IS NULL   THEN

          p_emp_record.error_record.error_status := 'W';
          RETURN;

    END IF;

    IF p_emp_record.employee_name IS NOT NULL and
       p_emp_record.employee_id   IS NOT NULL   THEN

          p_emp_record.error_record.error_status := 'S';
          RETURN;

    END IF;

    IF p_emp_record.employee_name IS NOT NULL THEN

      sql_str := sql_str || ' full_name  = :v_emp_name and';
      emp_name_null := FALSE;

    END IF;

    IF p_emp_record.employee_id IS NOT NULL THEN

      sql_str := sql_str || ' employee_id = :v_emp_id and';
      emp_id_null := FALSE;

    END IF;

    sql_str := substr(sql_str,1,length(sql_str)-3);

    --dbms_output.put_line(substr(sql_str,1,255));
    --dbms_output.put_line(substr(sql_str,256,255));
    --dbms_output.put_line(substr(sql_str,513,255));

    cid := dbms_sql.open_cursor;

    dbms_sql.parse(cid, sql_str , dbms_sql.native);

    dbms_sql.define_column(cid,1,p_emp_record.employee_name,255);
    dbms_sql.define_column(cid,2,p_emp_record.employee_id);

    IF NOT emp_name_null THEN

      dbms_sql.bind_variable(cid,'v_emp_name',p_emp_record.employee_name);

    END IF;

    IF NOT emp_id_null THEN

      dbms_sql.bind_variable(cid,'v_emp_id',p_emp_record.employee_id);

    END IF;

    rows_processed := dbms_sql.execute_and_fetch(cid);

    IF rows_processed = 1 THEN

       IF emp_name_null THEN
          dbms_sql.column_value(cid,1,p_emp_record.employee_name);
       END IF;

       IF emp_id_null THEN
          dbms_sql.column_value(cid,2,p_emp_record.employee_id);
       END IF;

       p_emp_record.error_record.error_status := 'S';

    ELSIF rows_processed = 0 THEN

       p_emp_record.error_record.error_status := 'W';

    ELSE

       p_emp_record.error_record.error_status := 'W';

    END IF;

    IF dbms_sql.is_open(cid) THEN
       dbms_sql.close_cursor(cid);
    END IF;

 EXCEPTION
    WHEN others THEN

       IF dbms_sql.is_open(cid) THEN
           dbms_sql.close_cursor(cid);
       END IF;

       p_emp_record.error_record.error_status := 'U';
       p_emp_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_emp_record.error_record.error_message);
       END IF;

 END derive_employee_info;


/*===========================================================================

  PROCEDURE NAME:	validate_employee_info()

===========================================================================*/

 PROCEDURE validate_employee_info (
               p_emp_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Employee_id_record_type) IS

 X_cid            INTEGER;
 X_rows_processed INTEGER;
 X_sql_str        VARCHAR2(2000);

 X_Emp_name_null  BOOLEAN := TRUE;
 X_Emp_id_null    BOOLEAN := TRUE;

 begin

    X_sql_str := 'select hr_employees.full_name, hr_employees.employee_id from hr_employees where ';

    IF p_emp_record.employee_id    IS NULL   and
       p_emp_record.employee_name  IS NULL   THEN

          --dbms_output.put_line('ALLNULL');
          p_emp_record.error_record.error_status := 'E';
          p_emp_record.error_record.error_message := 'ALLNULL';
          RETURN;

    END IF;


    IF p_emp_record.employee_name IS NOT NULL THEN

      X_sql_str := X_sql_str || ' full_name  = :v_emp_name and';
      X_emp_name_null := FALSE;

    END IF;

    IF p_emp_record.employee_id IS NOT NULL THEN

      X_sql_str := X_sql_str || ' employee_id = :v_emp_id and';
      X_emp_id_null := FALSE;

    END IF;

    X_sql_str := substr(X_sql_str,1,length(X_sql_str)-3);

    --dbms_output.put_line(substr(X_sql_str,1,255));
    --dbms_output.put_line(substr(X_sql_str,256,255));
    --dbms_output.put_line(substr(X_sql_str,513,255));

    X_cid := dbms_sql.open_cursor;

    dbms_sql.parse(X_cid, X_sql_str , dbms_sql.native);

    dbms_sql.define_column(X_cid,1,p_emp_record.employee_name,255);
    dbms_sql.define_column(X_cid,2,p_emp_record.employee_id);

    IF NOT X_emp_name_null THEN

      dbms_sql.bind_variable(X_cid,'v_emp_name',p_emp_record.employee_name);

    END IF;

    IF NOT X_emp_id_null THEN

      dbms_sql.bind_variable(X_cid,'v_emp_id',p_emp_record.employee_id);

    END IF;

    X_rows_processed := dbms_sql.execute_and_fetch(X_cid);

    IF X_rows_processed = 1 THEN

       dbms_sql.column_value(X_cid,1,p_emp_record.employee_name);
       dbms_sql.column_value(X_cid,2,p_emp_record.employee_id);

       p_emp_record.error_record.error_status := 'S';
       p_emp_record.error_record.error_message := NULL;

    ELSIF X_rows_processed = 0 THEN

       p_emp_record.error_record.error_status := 'E';
       p_emp_record.error_record.error_message := 'RECEIVER_ID';

       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;
       RETURN;

    ELSE

       p_emp_record.error_record.error_status := 'E';
       p_emp_record.error_record.error_message := 'TOOMANYROWS';

       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;
       RETURN;

    END IF;

    IF dbms_sql.is_open(X_cid) THEN
      dbms_sql.close_cursor(X_cid);
    END IF;

 EXCEPTION
    WHEN others THEN

       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;

       p_emp_record.error_record.error_status := 'U';
       p_emp_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_emp_record.error_record.error_message);
       END IF;

 END validate_employee_info;

 /**************************************************************************
  * This function returns the full name of the employee *
  *  added for bug 2228195
  **************************************************************************/
FUNCTION get_emp_name(x_person_id IN NUMBER) RETURN VARCHAR2 IS

x_value  VARCHAR2(1000) := '';
x_date date;

cursor c1 is
select distinct prf.full_name,prf.effective_start_date
from   per_all_people_f prf
where  prf.person_id = x_person_id
order by prf.effective_start_date desc;

begin

    /*
     *  (1) Even the approver is no longer with the org, still need to retieve his/her
     *      Full Name.
     *  (2) Suppose a person has multiple employing history with the org, there're
     *      multiple records for the person in per_all_people_f table.
     */

    open c1;
     fetch c1 into x_value,x_date;
    close c1;

    return x_value;

  exception
     when others then
        return null;

end get_emp_name;

END PO_EMPLOYEES_SV;

/
