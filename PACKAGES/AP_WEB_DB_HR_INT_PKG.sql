--------------------------------------------------------
--  DDL for Package AP_WEB_DB_HR_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_HR_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbhrs.pls 120.21.12010000.2 2008/08/06 07:49:08 rveliche ship $ */

/*HR Employees */
---------------------------------------------------------------------------------------------------
SUBTYPE empCurrent_employeeID			IS HR_EMPLOYEES_CURRENT_V.employee_id%TYPE;
SUBTYPE empCurrent_fullName			IS HR_EMPLOYEES_CURRENT_V.full_name%TYPE;
SUBTYPE empCurrent_empNum			IS HR_EMPLOYEES_CURRENT_V.employee_num%TYPE;
SUBTYPE empCurrent_checkAddrFlag	        IS HR_EMPLOYEES_CURRENT_V.expense_check_address_flag%TYPE;
SUBTYPE empCurrent_defaultCodeCombID		IS HR_EMPLOYEES_CURRENT_V.default_code_combination_id%TYPE;
SUBTYPE empCurrent_orgID			IS
HR_EMPLOYEES_CURRENT_V.ORGANIZATION_ID%TYPE;
---------------------------------------------------------------------------------------------------

/*PER Employees */
---------------------------------------------------------------------------------------------------
SUBTYPE perEmp_employeeID			IS PER_EMPLOYEES_CURRENT_X.employee_id%TYPE;
SUBTYPE perEmp_supervisorID			IS PER_EMPLOYEES_CURRENT_X.supervisor_id%TYPE;
---------------------------------------------------------------------------------------------------

/* FND User */
---------------------------------------------------------------------------------------------------
SUBTYPE fndUser_userID				IS FND_USER.user_id%TYPE;
SUBTYPE fndUser_employeeID			IS FND_USER.employee_id%TYPE;
---------------------------------------------------------------------------------------------------

/* AK Web User Security Attribute Values */
---------------------------------------------------------------------------------------------------
SUBTYPE usrSecAttr_attrCode			IS AK_WEB_USER_SEC_ATTR_VALUES.attribute_code%TYPE;
SUBTYPE usrSecAttr_webUserID			IS AK_WEB_USER_SEC_ATTR_VALUES.web_user_id%TYPE;
---------------------------------------------------------------------------------------------------


TYPE UserIdRefCursor		IS REF CURSOR;
TYPE EmpInfoCursor 		IS REF CURSOR;
TYPE EmpNameCursor 		IS REF CURSOR;

--------------------------------------------------------------------------
TYPE EmployeeInfoRec	IS RECORD (
	employee_id 		empCurrent_employeeID,
	employee_name 		empCurrent_fullName,
	employee_num 		empCurrent_empNum,
	emp_ccid 		empCurrent_defaultCodeCombID
);
--------------------------------------------------------------------------

--------------------------------------------------------------------------
FUNCTION GetUserIdForEmpCursor(
	p_emp_id		IN	fndUser_employeeID,
	p_user_id_ref_cursor OUT NOCOPY UserIdRefCursor
) RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetAllEmpListForWebUserCursor(
	p_web_user_id		IN	usrSecAttr_webUserID,
	p_emp_name_cursor OUT NOCOPY EmpNameCursor
) RETURN BOOLEAN;
--------------------------------------------------------------------------------
FUNCTION GetEmpListForWebUserCursor(
	p_web_user_id		IN	usrSecAttr_webUserID,
	p_emp_name_cursor OUT NOCOPY EmpNameCursor
) RETURN BOOLEAN;

FUNCTION getEmployeeID return number;

--------------------------------------------------------------------------------
FUNCTION GetEmployeeInfoCursor(
	p_name_str 			IN  VARCHAR2,
	p_upper_approver_name_fuzzy IN  empCurrent_fullName,
	p_emp_info_cursor	 OUT NOCOPY EmpInfoCursor
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetNumOfEmpForWebUser(
		p_attribute_code 	IN usrSecAttr_attrCode,
		p_web_user_id   	IN usrSecAttr_webUserID,
		p_count		 OUT NOCOPY NUMBER
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetSupervisorID(
	p_employee_id 	IN	perEmp_employeeID,
	p_manager_id OUT NOCOPY perEmp_supervisorID
) RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetEmpOrgId(
	P_EmployeeID	IN 	empCurrent_employeeID,
	p_org_id OUT NOCOPY empCurrent_orgID
) RETURN BOOLEAN;


-------------------------------------------------------------------
FUNCTION GetEmployeeInfo(p_employee_id  IN  empCurrent_employeeID,
			 p_emp_info_rec OUT NOCOPY EmployeeInfoRec
) RETURN BOOLEAN;
-------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetEmpIdForUser(
	p_user_id	IN	fndUser_userID,
	p_emp_id OUT NOCOPY fndUser_employeeID
) RETURN BOOLEAN;


FUNCTION GetSecurAttrCount(
	P_WebUserID	IN	usrSecAttr_webUserID) RETURN NUMBER;

/*Bug 1347380: Function to get The Supervisor Name*/
FUNCTION GetSupervisorName(
        p_employee_id   IN      NUMBER
) RETURN VARCHAR2;

/* Bug 3176205: Inactive Employees and Contingent Workers project */
FUNCTION IsPersonActive (p_person_id IN NUMBER) RETURN VARCHAR2;

/* Bug 3176205: Inactive Employees and Contingent Workers project */
FUNCTION IsPersonCwk (p_person_id IN NUMBER) RETURN VARCHAR2;

/* Bug 3176205: Inactive Employees and Contingent Workers project */
PROCEDURE GetVendorAndVendorSite
    (p_person_id            IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_vendor_id            OUT NOCOPY NUMBER
    ,p_vendor_site_id       OUT NOCOPY NUMBER);

/* Bug 3251447: Bypass employee approval for terminated employee */
FUNCTION IsPersonTerminated (p_person_id IN NUMBER) return VARCHAR2;

/* Bug 3282097: Get supervisor id should also return supervisor for
   terminated employees and contingent workers. */
/* returs only an active contingent worker or employee. */

FUNCTION GetSupervisorInfo(
	p_employee_id		    IN 	NUMBER,
    p_manager_id            OUT NOCOPY NUMBER,
    p_manager_name          OUT NOCOPY VARCHAR2,
    p_manager_org_id        OUT NOCOPY NUMBER
) RETURN BOOLEAN;

PROCEDURE GetSupervisorDetails(
	p_employee_id		    IN 	NUMBER,
    p_supervisor_id            OUT NOCOPY NUMBER,
    p_supervisor_name          OUT NOCOPY VARCHAR2
    );



/* Bug 3243527: Get Employee's Inactive Date */
FUNCTION GetEmpInactiveDate(
	p_employee_id IN NUMBER
)RETURN DATE;

/* 3257576 : Get the manager ID, name and status.
   returs an active/terminated/suspended employee
   or contingent worker */
PROCEDURE GetManagerIdAndStatus(
    p_employee_id		    IN 	NUMBER,
    p_manager_id            OUT NOCOPY NUMBER,
    p_manager_name          OUT NOCOPY VARCHAR2,
    p_manager_status        OUT NOCOPY VARCHAR2
);

FUNCTION GetEmployeeName(
        p_employee_id   IN      NUMBER
) RETURN VARCHAR2;


FUNCTION GetEmpOrgId(
	p_employee_id      IN 	empCurrent_employeeID,
	p_effective_date  IN 	Date,
	P_organization_id OUT NOCOPY empCurrent_orgID
) RETURN BOOLEAN;

FUNCTION HasValidFndUserAndWfAccount(
         p_emp_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION getFinalActiveManager(p_employee_id IN NUMBER) RETURN NUMBER;

PROCEDURE GetEmpNameNumber(
	p_employee_id		   IN 	NUMBER,
        p_employee_number          OUT NOCOPY VARCHAR2,
        p_employee_name            OUT NOCOPY VARCHAR2
    );

PROCEDURE GetUserIdFromName(
  p_user_name IN VARCHAR2,
  p_user_id OUT NOCOPY NUMBER
  );

END AP_WEB_DB_HR_INT_PKG;

/
