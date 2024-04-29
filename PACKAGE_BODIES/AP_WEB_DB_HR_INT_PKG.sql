--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_HR_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_HR_INT_PKG" AS
/* $Header: apwdbhrb.pls 120.31.12010000.5 2009/10/21 09:53:59 dsadipir ship $ */

--------------------------------------------------------------------------------
FUNCTION GetUserIdForEmpCursor(
	p_emp_id		IN	fndUser_employeeID,
	p_user_id_ref_cursor OUT NOCOPY UserIdRefCursor
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	OPEN p_user_id_ref_cursor FOR
		SELECT	user_id
		FROM	fnd_user
		WHERE	employee_id = p_emp_id
		ORDER BY creation_date;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetUserIdForEmpCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;

END GetUserIdForEmpCursor;

--------------------------------------------------------------------------------
FUNCTION GetAllEmpListForWebUserCursor(
	p_web_user_id		IN	usrSecAttr_webUserID,
	p_emp_name_cursor OUT NOCOPY EmpNameCursor
) RETURN BOOLEAN IS
-- 3176205: Inactive Employees and Contingent Workers changes
-- This function will return a cursor to all employees, whether
-- current or inactive. It will not return any contingent workers.
--------------------------------------------------------------------------------
BEGIN
	OPEN p_emp_name_cursor FOR
    		SELECT h.employee_id, h.full_name ||' ('||h.employee_num||') ' nameNum
    		FROM   per_employees_x h,
           		ak_web_user_sec_attr_values a
     		WHERE  a.attribute_code = 'ICX_HR_PERSON_ID'
    		AND    a.web_user_id = p_web_user_id
    		AND    h.employee_id = a.number_value
    		ORDER BY UPPER(h.full_name);

	return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetWorkerListForWebUserCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;

END GetAllEmpListForWebUserCursor;

--------------------------------------------------------------------------------
FUNCTION GetEmpListForWebUserCursor(
	p_web_user_id		IN	usrSecAttr_webUserID,
	p_emp_name_cursor OUT NOCOPY EmpNameCursor
) RETURN BOOLEAN IS
-- This function will return a cursor to current employees only.
-- It will not include terminated employees.
--------------------------------------------------------------------------------
BEGIN
	OPEN p_emp_name_cursor FOR
    		SELECT h.employee_id, h.full_name ||' ('||h.employee_num||') ' nameNum
    		FROM   per_employees_current_x h,
           		ak_web_user_sec_attr_values a
     		WHERE  a.attribute_code = 'ICX_HR_PERSON_ID'
    		AND    a.web_user_id = p_web_user_id
    		AND    h.employee_id = a.number_value
    		ORDER BY UPPER(h.full_name);

	return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetEmpListForWebUserCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;

END GetEmpListForWebUserCursor;

--------------------------------------------------------------------------------
FUNCTION GetEmployeeInfoCursor(
	p_name_str 		    IN 	VARCHAR2,
	p_upper_approver_name_fuzzy IN  empCurrent_fullName,
	p_emp_info_cursor	    OUT NOCOPY EmpInfoCursor
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
/*
  	l_1st_char_approver_name 	VARCHAR2(4);
  	l_2nd_char_approver_name 	VARCHAR2(4);
  	l_1st_like_constant 	        VARCHAR2(9);
  	l_2nd_like_constant 	        VARCHAR2(9);
  	l_3rd_like_constant 	        VARCHAR2(9);
  	l_4th_like_constant 	        VARCHAR2(9);
*/

BEGIN

-- Bug 3818881 : commented
/*
-- chiho: know why the substr is used but not substrb?:'cause that's what we intended to do here, extract exactly one single char from the source string:
    	l_1st_char_approver_name := substr( p_name_str, 1, 1 );
    	l_2nd_char_approver_name := substr( p_name_str, 2, 1 );

    	l_1st_like_constant := UPPER(l_1st_char_approver_name || l_2nd_char_approver_name) || '%';
    	l_2nd_like_constant := LOWER(l_1st_char_approver_name || l_2nd_char_approver_name) || '%';
    	l_3rd_like_constant := UPPER(l_1st_char_approver_name) || LOWER(l_2nd_char_approver_name) || '%';
    	l_4th_like_constant := LOWER(l_1st_char_approver_name) || UPPER(l_2nd_char_approver_name) || '%';
*/

        -- Bug 1363739, Added order by clause inorder to catch
        -- "Frost, Mr. Jamie" in the following example:
        -- Frost, Mr. Jamie
        -- Frost, Mr. Jamie K.
        -- Frost, Mr. Jamie M.

	OPEN p_emp_info_cursor FOR
        -- 3176205: Inactive Employees and Contingent Workers changes
        -- This query should only return ACTIVE
        -- employees and contingent workers, depicted by the statuses
        -- ACTIVE_ASSIGN and ACTIVE_CWK.
        -- Bug 3818881 : Changing the query for performance reasons
		SELECT emp.person_id, full_name
                FROM
		     (
			SELECT employee_id person_id, full_name
			FROM   per_employees_x emp
			WHERE upper(full_name) like upper(p_upper_approver_name_fuzzy)
			AND   NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
		     UNION ALL
			SELECT person_id, full_name
			FROM  per_cont_workers_current_x emp
			WHERE upper(full_name) like upper(p_upper_approver_name_fuzzy)
		     )  emp,
	                per_assignments_f pera,
	                per_assignment_status_types peras
	        WHERE  emp.person_id = pera.person_id
	        AND pera.assignment_status_type_id = peras.assignment_status_type_id
		AND trunc(sysdate) between pera.effective_start_date and pera.effective_end_date
		AND pera.assignment_type in ('C', 'E')
		AND pera.primary_flag='Y'
		AND peras.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK')
		AND rownum < 3;


	return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetEmployeeInfoCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;

END GetEmployeeInfoCursor;

-------------------------------------------------------------------
FUNCTION GetNumOfEmpForWebUser(
	p_attribute_code 	IN usrSecAttr_attrCode,
	p_web_user_id   	IN usrSecAttr_webUserID,
	p_count		 OUT NOCOPY NUMBER
)
RETURN BOOLEAN IS
-------------------------------------------------------------------

BEGIN
   -- This query should count all contingent workers and employees
   -- No need to restrict to current employees
   -- 3176205: Inactive Employees and Contingent Workers changes
   -- This query selects from PER_PEOPLE_X, because that view will
   -- return one row per person_id. PER_WORKFORCE_X could return 2 rows.
   SELECT count(*)
   INTO   p_count
   FROM   per_people_x h,
          ak_web_user_sec_attr_values a
   WHERE  a.attribute_code = p_attribute_code
   AND    a.web_user_id = p_web_user_id
   AND    h.person_id = a.number_value;

 RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetNumOfEmpForWebUser' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;

END GetNumOfEmpForWebUser;


-------------------------------------------------------------------
FUNCTION GetSupervisorID(
	p_employee_id 	IN	perEmp_employeeID,
	p_manager_id OUT NOCOPY perEmp_supervisorID
) RETURN BOOLEAN IS
  p_manager_name VARCHAR2(240);
  p_manager_org_id  NUMBER;
-------------------------------------------------------------------
BEGIN
 /* Bug 3003105 : Should not retrieve the manager if his record
                  has been end dated. */
 /* Bug 3282097 : Should get the manager of terminated employees
                  and contingent workers. */

  RETURN (GetSupervisorInfo(p_employee_id, p_manager_id, p_manager_name, p_manager_org_id));

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetSupervisorID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;

END GetSupervisorID;


--------------------------------------------------------------------------------
FUNCTION GetEmpOrgId(
	P_EmployeeID	IN 	empCurrent_employeeID,
	p_org_id OUT NOCOPY empCurrent_orgID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
  -- 3176205: Contingent Workers and Inactive Employees.
  -- Should not return terminated contingent workers or
  -- ex employees that became contingent workers
  -- 4042775: Changed query to not use per_workforce_x

        select ORGANIZATION_ID
        into   p_org_id
        from
          (  select organization_id
             from per_employees_x emp
             where  employee_id = P_EmployeeID
             and not AP_WEB_DB_HR_INT_PKG.isPersonCwk(emp.employee_id)='Y'
           union all
             select organization_id
             from per_cont_workers_current_x emp
             where  person_id = P_EmployeeID);
	return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetEmpOrgId' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;
END GetEmpOrgId;

-------------------------------------------------------------------
FUNCTION GetEmployeeInfo(p_employee_id  IN  empCurrent_employeeID,
			 p_emp_info_rec OUT NOCOPY EmployeeInfoRec
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
 -- 3176205: Congtingent workers and inactive employees
 -- This query includes all workers except for
 -- terminated contingent workers and ex employees who become
 -- contingent workers.
 -- Bug  3818881 : Changed the query for performance reasons
/*	SELECT emp1.full_name, emp1.employee_num, emp1.default_code_combination_id
        INTO   p_emp_info_rec.employee_name,
               p_emp_info_rec.employee_num,
               p_emp_info_rec.emp_ccid
	FROM
	   (
	     SELECT emp.full_name,
                   emp.employee_num,
                   emp.default_code_combination_id,
	           employee_id person_id
	     FROM  per_employees_x emp
	     WHERE  emp.employee_id = p_employee_id
	     AND NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
	   UNION ALL
	     SELECT cwk.full_name,
                   cwk.npw_number employee_num,
	           cwk.default_code_combination_id,
                   cwk. person_id
	     FROM  per_cont_workers_current_x cwk
	     WHERE  cwk.person_id = p_employee_id
           ) emp1;
*/
	-- Bug: 7284573, Latest Assignment being picked up for employees terminated in the future.
        SELECT emp1.full_name, emp1.employee_num, pera.default_code_comb_id
        INTO   p_emp_info_rec.employee_name,
               p_emp_info_rec.employee_num,
               p_emp_info_rec.emp_ccid
        FROM
           (
             SELECT emp.full_name,
                   emp.employee_num,
                   emp.default_code_combination_id,
                   employee_id person_id
             FROM  per_employees_x emp
             WHERE  emp.employee_id = p_employee_id
             AND NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
           UNION ALL
             SELECT cwk.full_name,
                   cwk.npw_number employee_num,
                   cwk.default_code_combination_id,
                   cwk. person_id
             FROM  per_cont_workers_current_x cwk
             WHERE  cwk.person_id = p_employee_id
           ) emp1,
        per_assignments_f pera
        -- per_assignment_status_types peras
        WHERE  emp1.person_id = pera.person_id
        -- AND pera.assignment_status_type_id = peras.assignment_status_type_id
        AND trunc(sysdate) between trunc(pera.effective_start_date) and trunc(pera.effective_end_date)
        AND pera.assignment_type in ('C', 'E')
        AND pera.primary_flag='Y';
	-- Bug# 8996584 - Inactive Employees or Contigent Workers should be shown until the Final Process date is entered
        -- AND peras.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK');

  RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetEmployeeInfo' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;

END GetEmployeeInfo;


--------------------------------------------------------------------------------
FUNCTION GetEmpIdForUser(
	p_user_id	IN	fndUser_userID,
	p_emp_id OUT NOCOPY fndUser_employeeID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	SELECT 	employee_id
	INTO	p_emp_id
	FROM	fnd_user
	WHERE	user_id = p_user_id;

	return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetEmpIdForUser' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;

END GetEmpIdForUser;


FUNCTION getEmployeeID return number IS

  l_user_id                       NUMBER;
  l_employee_id                   NUMBER;

BEGIN

  -- Bug 1480911. Replaced this code with a workaround
  -- because it would always return -1 in New UI

  -- return icx_sec.getID(icx_sec.PV_INI_CONTACT_ID);

  l_user_id := FND_PROFILE.VALUE('USER_ID');

  if (NOT GetEmpIdForUser (l_user_id, l_employee_id))
    then
    raise NO_DATA_FOUND;
  end if;

  return (l_employee_id);
END;


FUNCTION GetSecurAttrCount(
	P_WebUserID	IN	usrSecAttr_webUserID
) RETURN NUMBER IS
  l_security_attr_cnt  	      NUMBER := 0;
BEGIN
      SELECT   COUNT(*)
      INTO     l_security_attr_cnt
      FROM   hr_employees_current_v h,
	     ak_web_user_sec_attr_values a
      WHERE  a.attribute_code = 'ICX_HR_PERSON_ID'
      AND    a.web_user_id = P_WebUserID
      AND    h.employee_id = a.number_value;

      RETURN(l_security_attr_cnt);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 0;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetSecurAttrCount' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return 0;
END;

/*------------------------------------------------------------+
  Created By: Amulya Mishra
  Bug 1347380: Created a function to get the supervisor name
	       which will be displayed in the Review Page.
+-------------------------------------------------------------*/

FUNCTION GetSupervisorName(
        p_employee_id   IN      NUMBER
) RETURN VARCHAR2 IS
p_manager_id NUMBER;
p_manager_name PER_WORKFORCE_CURRENT_X.FULL_NAME%TYPE;
p_manager_org_id  NUMBER;

------------------------------------------------------------------_
BEGIN
  -- 3176205: Contingent workers and inactive employees
  -- The supervisor returned should be an active contingent worker
  -- or employee.
    IF (GetSupervisorInfo(p_employee_id, p_manager_id, p_manager_name, p_manager_org_id)) THEN
      RETURN p_manager_name;
    ELSE
      RETURN NULL;
    END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN NULL;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'GetSupervisorName' );
                APP_EXCEPTION.RAISE_EXCEPTION;
                RETURN NULL;

END GetSupervisorName;

PROCEDURE GetSupervisorDetails(
         p_employee_id                     IN  NUMBER,
         p_supervisor_id            OUT NOCOPY NUMBER,
         p_supervisor_name          OUT NOCOPY VARCHAR2
 )IS

p_manager_id NUMBER;
p_manager_name PER_WORKFORCE_CURRENT_X.FULL_NAME%TYPE;
p_manager_org_id  NUMBER;

------------------------------------------------------------------_
BEGIN
  -- 3176205: Contingent workers and inactive employees
  -- The supervisor returned should be an active contingent worker
  -- or employee.
    IF (GetSupervisorInfo(p_employee_id, p_manager_id, p_manager_name, p_manager_org_id)) THEN
      p_supervisor_id:=p_manager_id;
      p_supervisor_name:=p_manager_name;
    END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_supervisor_id :=NULL;
      p_supervisor_name :=NULL;
        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'GetSupervisorDetails' );
                APP_EXCEPTION.RAISE_EXCEPTION;


END GetSupervisorDetails;


-- Use GetManagerIdAndStatus if you need to get the supervisor info
-- (Manager_id, name and status) of supervisor of any status
--------------------------------------------------------------------------------
FUNCTION GetSupervisorInfo(
	p_employee_id		    IN 	NUMBER,
    p_manager_id            OUT NOCOPY NUMBER,
    p_manager_name          OUT NOCOPY VARCHAR2,
    p_manager_org_id        OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
  -- 3176205: Contingent workers and inactive employees
  -- The supervisor returned should be an active contingent worker
  -- or employee.

  -- The subquery should allow any person's
  -- supervisor to be selected except for
  -- terminated cwk's or ex-employees that
  -- are a current contingent worker.
  -- bug 3650767 : changed the suquery get the supervisor from
  -- per_employees_x, per_cont_workers_current_x instead of per_workforce_x
        SELECT mgr.person_id, mgr.full_name, pera.business_group_id
        INTO   p_manager_id, p_manager_name, p_manager_org_id
        FROM   per_people_x mgr,
               per_assignments_f pera,
               per_assignment_status_types peras
        WHERE  mgr.person_id = (
                         SELECT emp.supervisor_id
                         FROM  per_employees_x emp
                         WHERE  emp.employee_id = p_employee_id
                         AND NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
                           UNION ALL
                         SELECT emp.supervisor_id
                         FROM  per_cont_workers_current_x emp
                         WHERE  emp.person_id = p_employee_id
                        )
        AND mgr.person_id = pera.person_id
        AND pera.assignment_status_type_id = peras.assignment_status_type_id
        AND trunc(sysdate) between pera.effective_start_date and pera.effective_end_date
        AND pera.assignment_type in ('C', 'E')
        AND pera.primary_flag='Y'
        AND peras.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK');

  	RETURN TRUE;


EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN FALSE;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'GetSupervisorInfo' );
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;

END GetSupervisorInfo;

--
-- IsPersonActive
-- Author: Kristian Widjaja
-- Purpose: To determine whether a person is an active employee
--          or active contingent worker.
-- Bug 3215993: Inactive Employees and Contingent Workers project
--
-- Input: p_person_id
--
-- Output: 'Y' (Yes) or 'N' (No)
--

FUNCTION IsPersonActive (p_person_id IN NUMBER) return VARCHAR2
IS
  v_numRows NUMBER := 0;
BEGIN
  -- This query returns rows if there exist an active employee or cwk
  -- record for the given person ID.
  SELECT 1
  INTO v_numRows
  FROM DUAL
  WHERE exists
  (SELECT 1
  FROM
    per_people_f p,
    per_assignments_f a,
    per_assignment_status_types past
  WHERE a.person_id = p.person_id
    AND p.person_id = p_person_id
    AND a.assignment_status_type_id = past.assignment_status_type_id
    AND a.primary_flag = 'Y'
    AND trunc(sysdate) between p.effective_start_date  AND p.effective_end_date
    AND trunc(sysdate) between a.effective_start_date  AND a.effective_end_date
    AND a.assignment_type in ('E', 'C')
    AND past.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK', 'SUSP_ASSIGN', 'SUSP_CWK_ASG')); -- Bug 8357892(sodash) Added SUSP_ASSIGN for active suspended employees

  -- Return true if there were rows, return false otherwise
  IF v_numRows = 1 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return('N');
 WHEN OTHERS THEN
  raise;
END IsPersonActive;

--
-- IsPersonCwk
-- Author: Kristian Widjaja
-- Purpose: To determine whether a person is a contingent worker or not.
-- Bug 3215993: Inactive Employees and Contingent Workers project
--
-- Input: p_person_id
--
-- Output: 'Y' (Yes) or 'N' (No)
--

FUNCTION IsPersonCwk (p_person_id IN NUMBER) return VARCHAR2
IS
  v_numRows NUMBER := 0;
BEGIN
  -- This query returns rows if there exist an active employee or cwk
  -- record for the given person ID.
  SELECT 1
   INTO v_numRows
  FROM DUAL
  WHERE EXISTS
  (SELECT 1
   FROM
     per_cont_workers_current_x p
   WHERE
     p.person_id = p_person_id);

  -- Return true if there were rows, return false otherwise
  IF v_numRows = 1 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return('N');
 WHEN OTHERS THEN
  raise;
END IsPersonCwk;

--
-- Procedure:     GetVendorAndVendorSite
-- Author:        Kristian Widjaja
-- Purpose:       This procedure gets the vendor and vendor site
--                of a person's primary assignment
--
-- Input:         p_person_id
--                p_effective_date
--
-- Output:        p_vendor_id, p_vendor_site_id
--
-- Notes:         Bug 3215993
--                Inactive Employees and Contingent Workers project

PROCEDURE GetVendorAndVendorSite
    (p_person_id            IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_vendor_id            OUT NOCOPY NUMBER
    ,p_vendor_site_id       OUT NOCOPY NUMBER)
IS
BEGIN
  -- Call HR API
  HR_PO_INFO.get_vendor_for_primary_asg(p_person_id,
                                        p_effective_date,
                                        p_vendor_id,
                                        p_vendor_site_id);

END GetVendorAndVendorSite;

--
-- IsPersonTerminated
-- Author: Kristian Widjaja
-- Purpose: To determine whether a person is a terminated person
-- Bug 3251447: Pending employee approval for terminated employee.
--
-- Input: p_person_id
--
-- Output: 'Y' (Yes) or 'N' (No)
--

FUNCTION IsPersonTerminated (p_person_id IN NUMBER) return VARCHAR2
IS
  v_numRows NUMBER := 0;
BEGIN
  -- This query returns rows if there exist any active or suspended
  -- employee or cwk record for the given person ID.

  SELECT 1
  INTO v_numRows
  FROM DUAL
  WHERE exists
  (SELECT 1
  FROM
    per_people_f p,
    per_assignments_f a,
    per_assignment_status_types past
  WHERE a.person_id = p.person_id
    AND p.person_id = p_person_id
    AND a.assignment_status_type_id = past.assignment_status_type_id
    AND a.primary_flag = 'Y'
    AND trunc(sysdate) between p.effective_start_date  AND p.effective_end_date
    AND trunc(sysdate) between a.effective_start_date  AND a.effective_end_date
    AND a.assignment_type in ('E', 'C')
    AND past.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK',
                                   'SUSP_ASSIGN', 'SUSP_CWK_ASG'));

  -- Return false if there were rows, return true otherwise
  IF v_numRows = 1 THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return('Y');
 WHEN OTHERS THEN
  raise;
END IsPersonTerminated;

FUNCTION GetEmpInactiveDate(p_employee_id IN NUMBER)
RETURN Date IS
l_date Date;
BEGIN
	SELECT inactive_date
	INTO   l_date
	FROM   per_employees_x
	WHERE  employee_id = p_employee_id;
   RETURN l_date;
EXCEPTION
  WHEN OTHERS THEN
       raise;
END GetEmpInactiveDate;

--
-- GetManagerIdAndStatus
-- Author: skoukunt
-- Purpose: Get the manager ID, name and status
--          of an active/terminated/suspended employee
--          or contingent worker
-- Bug 3257576
--
-- Input: p_employee_id
--
-- Output: p_manager_id - Manager ID
--         p_manager_name - Manager Name
--         p_manager_status - Manager Status (SUSP_ASSIGN, SUSP_CWK_ASG
--                            TERM_ASSIGN, ACTIVE_ASSIGN, ACTIVE_CWK)
--
-- use GetSupervisorInfo if you need to get supervisor info for
-- only active contingent worker or employee
--
--------------------------------------------------------------------------------
PROCEDURE GetManagerIdAndStatus(
    p_employee_id		    IN 	NUMBER,
    p_manager_id            OUT NOCOPY NUMBER,
    p_manager_name          OUT NOCOPY VARCHAR2,
    p_manager_status        OUT NOCOPY VARCHAR2
) IS
--------------------------------------------------------------------------------
BEGIN
        SELECT mgr.person_id, mgr.full_name, peras.per_system_status
        INTO   p_manager_id, p_manager_name, p_manager_status
        FROM   per_people_x mgr,
               per_assignments_f pera,
               per_assignment_status_types peras
        WHERE  mgr.person_id = (
                         SELECT emp.supervisor_id
                         FROM  per_employees_x emp
                         WHERE  emp.employee_id = p_employee_id
                         AND NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
                         UNION ALL
                         SELECT emp.supervisor_id
                         FROM  per_cont_workers_current_x emp
                         WHERE  emp.person_id = p_employee_id
                        )
        AND mgr.person_id = pera.person_id
        AND pera.assignment_status_type_id = peras.assignment_status_type_id
        AND trunc(sysdate) between pera.effective_start_date and pera.effective_end_date
        AND pera.assignment_type in ('C', 'E')
        AND pera.primary_flag='Y'
        AND rownum =1;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                null;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'GetSupervisorInfo' );
                APP_EXCEPTION.RAISE_EXCEPTION;

END GetManagerIdAndStatus;

FUNCTION GetEmployeeName(
        p_employee_id   IN      NUMBER
) RETURN VARCHAR2 IS
l_employee_name wf_users.name%type;
l_employee_display_name       wf_users.display_name%type;

BEGIN

    WF_DIRECTORY.GetUserName('PER',
                           p_employee_id,
                           l_employee_name,
                           l_employee_display_name);
    RETURN l_employee_display_name;

END GetEmployeeName;

FUNCTION GetEmpOrgId(
	p_employee_id      IN    empCurrent_employeeID,
	p_effective_date  IN    Date,
	P_organization_id OUT   NOCOPY empCurrent_orgID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN

      SELECT asg.organization_id
      INTO   p_organization_id
      FROM   per_assignments_f asg
      WHERE  asg.person_id = p_employee_id
      AND   asg.assignment_type in ('E','C')
      AND   asg.primary_flag='Y'
      AND   TRUNC(p_effective_date)
           BETWEEN asg.effective_start_date
           AND     asg.effective_end_date;

	return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetEmpOrgId' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
		return FALSE;
END GetEmpOrgId;

--
-- HasValidFndUserAndWfAccount
-- Author: Maulik Vadera
-- Purpose: To determine whether a person is validate USER and has validate
--          Workflow account.
--
-- Input: p_emp_id
--
-- Output: 'Y' (Yes) or 'N' (No)
--
---
FUNCTION HasValidFndUserAndWfAccount(p_emp_id IN NUMBER) return VARCHAR2
IS
  v_numRows NUMBER := 0;
BEGIN

  SELECT 1 into  v_numRows
  FROM DUAL
  WHERE EXISTS
    (SELECT 1 FROM fnd_user fnd, wf_users wf
     WHERE fnd.user_name = wf.name and employee_id = p_emp_id
     AND ORIG_SYSTEM not in ('HZ_PARTY','CUST_CONT')
     AND status = 'ACTIVE')
  and rownum=1;

  -- Return true if there were rows, return false otherwise
  IF v_numRows = 1 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return('N');
 WHEN OTHERS THEN
  raise;
END HasValidFndUserAndWfAccount;

/*-----------------------------------------------------------------------
  Bug 4387063 - returns final active manager.
  returns null if active manager does not exist.
 -----------------------------------------------------------------------*/
FUNCTION getFinalActiveManager(p_employee_id IN NUMBER) RETURN NUMBER IS
-------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);
  l_manager_id			NUMBER		:= NULL;
  l_manager_name                per_workforce_x.full_name%TYPE;
  l_manager_status              per_assignment_status_types.per_system_status%Type;

BEGIN


  AP_WEB_DB_HR_INT_PKG.GetManagerIdAndStatus(
                           p_employee_id,
                           l_manager_id,
                           l_manager_name,
                           l_manager_status);

  if l_manager_id is null then
    return l_manager_id;
  end if;

  --------------------------------------------------------------
  l_debug_info := l_manager_id || ' Status ' || l_manager_status;
  --------------------------------------------------------------
  if l_manager_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK') then
     return l_manager_id;
  else
     --------------------------------------------------------------
     l_debug_info := 'Calling getFinalActiveManager';
     --------------------------------------------------------------
     return (getFinalActiveManager(l_manager_id));
  end if;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AP_WEB_CUST_AME_PKG.getFinalActiveManager',
				    l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
END getFinalActiveManager;

PROCEDURE GetEmpNameNumber(
	p_employee_id		   IN 	NUMBER,
        p_employee_number          OUT NOCOPY VARCHAR2,
        p_employee_name            OUT NOCOPY VARCHAR2
    ) AS

l_debug_info			VARCHAR2(200);
l_emp_info_rec 			EmployeeInfoRec;

BEGIN

  IF GetEmployeeInfo(p_employee_id, l_emp_info_rec) THEN
     p_employee_number := l_emp_info_rec.employee_num;
     p_employee_name := l_emp_info_rec.employee_name;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('AP_WEB_DB_HR_INT_PKG.GetEmpNameNumber',
				    l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
END GetEmpNameNumber;

PROCEDURE GetUserIdFromName(
  p_user_name IN VARCHAR2,
  p_user_id OUT NOCOPY NUMBER
  ) IS
------------------------------------------------------------------
BEGIN

    SELECT	user_id INTO p_user_id
    FROM	fnd_user
    WHERE	user_name = p_user_name;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_user_id := -1;
    WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException( 'GetUserIdFromName' );
      APP_EXCEPTION.RAISE_EXCEPTION;
END GetUserIdFromName;

END AP_WEB_DB_HR_INT_PKG;

/
