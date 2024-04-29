--------------------------------------------------------
--  DDL for Package Body AP_WEB_AUDIT_LIST_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_AUDIT_LIST_VAL_PVT" AS
/* $Header: apwvalvb.pls 115.4 2004/06/30 14:43:48 jrautiai noship $ */

PROCEDURE Validate_Employee(p_emp_rec          IN OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                            x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE Find_Employee(p_emp_rec       IN OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                        x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Audit_dates(p_emp_rec          IN             AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                               p_audit_rec        IN  OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type,
                               x_return_status        OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDUDE Validate_Employee_Info
 |
 | DESCRIPTION
 |   This procedure validates that a single employee exists for the given
 |   parameter and returns the identifier for the match.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   AP_WEB_AUDIT_LIST_PUB.Audit_Employee
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Employee identifier matching the given parameters.
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec       IN OUT Employee record containg criteria used to find a given employee
 |   x_return_status    OUT   Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Employee_Info(p_emp_rec       IN OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                                 x_return_status    OUT NOCOPY VARCHAR2) IS

  l_required_return_status VARCHAR2(1);
  l_emp_return_status      VARCHAR2(1);

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate employee info
  Validate_Employee(p_emp_rec,
                    l_emp_return_status);

  IF l_required_return_status <> FND_API.G_RET_STS_SUCCESS OR
     l_emp_return_status  <> FND_API.G_RET_STS_SUCCESS THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

END Validate_Employee_Info;

/*========================================================================
 | PUBLIC PROCEDUDE Validate_Required_Input
 |
 | DESCRIPTION
 |   This procedure validates that the required parameters are passed to the api.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   AP_WEB_AUDIT_LIST_PUB.Audit_Employee
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec       IN  Employee record containg criteria used to find a given employee
 |   p_audit_rec     IN  Audit record containg information about the record to be created
 |   x_return_status OUT Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Required_Input(p_emp_rec          IN  AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                                  p_audit_rec        IN  AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type,
                                  x_return_status    OUT NOCOPY VARCHAR2) IS

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Business group id is always required
  IF p_emp_rec.business_group_id IS NULL THEN

    FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_BG_NULL');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  -- Audit reason is always required
  IF p_audit_rec.audit_reason_code IS NULL THEN

    FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_AR_NULL');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

 /*=======================================================================*
  | Either start date or end date must be provided                        |
  *=======================================================================*/
  IF p_audit_rec.start_date IS NULL and p_audit_rec.end_date IS NULL THEN
    FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_TED_NULL');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

 /*======================================================================*
  | If all required parameters were provided, then at least one employee |
  | criteria is required.                                                |
  *======================================================================*/
  IF x_return_status = FND_API.G_RET_STS_SUCCESS
     AND p_emp_rec.person_id IS NULL
     AND p_emp_rec.employee_number IS NULL
     AND p_emp_rec.national_identifier IS NULL
     AND p_emp_rec.email_address IS NULL THEN

    FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_NO_EMP_INFO');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

END Validate_Required_Input;

/*========================================================================
 | PRIVATE PROCEDUDE Validate_Employee
 |
 | DESCRIPTION
 |   This procedure validates that a single employee exists for the given
 |   parameter and returns the identifier for the match.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Validate_Employee_Info
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Employee identifier matching the given parameters.
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec       IN OUT Employee record containg criteria used to find a given employee
 |   x_return_status    OUT   Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Employee(p_emp_rec          IN OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                            x_return_status       OUT NOCOPY VARCHAR2) IS
 l_person_id         NUMBER;
 l_emp_return_status VARCHAR2(1);
BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Try to match the criteria to a single employee
  Find_Employee(p_emp_rec, l_emp_return_status);

  x_return_status := l_emp_return_status;

END Validate_Employee;

/*========================================================================
 | PRIVATE PROCEDUDE Find_Employee
 |
 | DESCRIPTION
 |   This procedure tries to find a single employee for the criteria given
 |   as parameters and returns the identifier for the match.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Validate_Employee
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Employee identifier matching the given parameters.
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec       IN OUT Employee record containg criteria used to find a given employee
 |   x_return_status    OUT   Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Find_Employee(p_emp_rec       IN OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                        x_return_status    OUT NOCOPY VARCHAR2) IS

  l_query_stmt	   VARCHAR2(4000) := to_char(null);
  l_where_clause   VARCHAR2(4000) := to_char(null);
  l_counter        NUMBER := 0;

  cur_hdl         INTEGER;
  rows_processed  BINARY_INTEGER;
  l_person_id     NUMBER;
BEGIN

 /*======================================================================*
  | Business group is always required, so it is always part of the query.|
  | Other criteria is only added is it was provided.                     |
  *======================================================================*/
  l_where_clause := 'WHERE business_group_id = :business_group_id';

  IF p_emp_rec.person_id IS NOT NULL THEN
    l_where_clause := l_where_clause || ' AND person_id = :person_id';
  END IF;

  IF p_emp_rec.employee_number IS NOT NULL THEN
    l_where_clause := l_where_clause || ' AND employee_number = :employee_number';
  END IF;

  IF p_emp_rec.national_identifier IS NOT NULL THEN
    l_where_clause := l_where_clause || ' AND national_identifier = :national_identifier';
  END IF;

  IF p_emp_rec.email_address IS NOT NULL THEN
    l_where_clause := l_where_clause || ' AND email_address = :email_address';
  END IF;

 /* 2-Oct-2003 J Rautiainen Contingent project changes
  * This procedure is used to fetch the id a employee to be added to audit list.
  * Since person can be added to audit list regardless of current status we
  * should use per_workforce_x, however that view does not contain the national
  * identifier, so no change here.
  */
 /*===================================================================================*
  | Select statement using the given  employee matching criteria in the where clause. |
  *===================================================================================*/
  l_query_stmt := 'select distinct(person_id) from PER_ALL_PEOPLE_F '||l_where_clause;

  -- open cursor
  cur_hdl := dbms_sql.open_cursor;

  -- parse cursor
  dbms_sql.parse(cur_hdl, l_query_stmt,dbms_sql.native);

  dbms_sql.bind_variable(cur_hdl, ':business_group_id', p_emp_rec.business_group_id);

  IF p_emp_rec.person_id IS NOT NULL THEN
    dbms_sql.bind_variable(cur_hdl, ':person_id', p_emp_rec.person_id);
  END IF;

  IF p_emp_rec.employee_number IS NOT NULL THEN
    dbms_sql.bind_variable(cur_hdl, ':employee_number', p_emp_rec.employee_number);
  END IF;

  IF p_emp_rec.national_identifier IS NOT NULL THEN
    dbms_sql.bind_variable(cur_hdl, ':national_identifier', p_emp_rec.national_identifier);
  END IF;

  IF p_emp_rec.email_address IS NOT NULL THEN
    dbms_sql.bind_variable(cur_hdl, ':email_address', p_emp_rec.email_address);
  END IF;

  dbms_sql.define_column(cur_hdl, 1, l_person_id);

  -- execute cursor
  rows_processed := dbms_sql.execute(cur_hdl);


 /*==========================================================================*
  | Loop through the results to find out whether multiple matches were found.|
  *==========================================================================*/
  LOOP
    -- fetch a row
    IF dbms_sql.fetch_rows(cur_hdl) > 0 then

      -- fetch columns from the row
      dbms_sql.column_value(cur_hdl, 1, l_person_id);

      l_counter := l_counter+1;

      IF l_counter >= 2 THEN
        EXIT;
      END IF;

    ELSE
      EXIT;
    END IF;

  END LOOP;

  -- close cursor
  dbms_sql.close_cursor(cur_hdl);

  IF l_counter >= 2 THEN
   /*======================================================================*
    | Employee must be uniquelly identified, several matches were found.   |
    *======================================================================*/
    FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_MULTIPLE_EMP');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    p_emp_rec.person_id := to_number(null);
  ELSIF l_counter = 0 THEN
   /*======================================================================*
    | Employee must be uniquelly identified, no matches were found.        |
    *======================================================================*/
    FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_NO_EMP_MATCH');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    p_emp_rec.person_id := to_number(null);
  ELSE
    p_emp_rec.person_id := l_person_id;
  END IF;
END Find_Employee;

/*========================================================================
 | PUBLIC PROCEDUDE Validate_Audit_Info
 |
 | DESCRIPTION
 |   This procedure validates that the audit information used to create
 |   the new record is valid.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   AP_WEB_AUDIT_LIST_PUB.Audit_Employee
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec       IN     Employee record containg criteria used to find a given employee
 |   p_audit_rec     IN OUT Audit record containg information about the record to be created
 |   x_return_status OUT    Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Audit_Info(p_emp_rec          IN             AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                              p_audit_rec        IN  OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type,
                              x_return_status        OUT NOCOPY VARCHAR2) IS

 /*===================================================================*
  | Cursor to verify that the given audit reason is valid and active. |
  *===================================================================*/
  CURSOR reason_cur(p_lookup_code VARCHAR2) IS
    select lookup_code
    from ap_lookup_codes lu
    where lu.lookup_type = 'OIE_AUTO_AUDIT_REASONS'
    and lu.lookup_code = p_lookup_code
    and NVL(lu.enabled_flag,'Y') = 'Y'
    AND TRUNC(SYSDATE)
        BETWEEN TRUNC(NVL(lu.START_DATE_ACTIVE,SYSDATE))
        AND     TRUNC(NVL(lu.INACTIVE_DATE,SYSDATE));

  reason_rec       reason_cur%ROWTYPE;
  l_return_status1 VARCHAR2(1);
  l_return_status2 VARCHAR2(1);
BEGIN

  OPEN reason_cur(p_audit_rec.audit_reason_code);
  FETCH reason_cur INTO reason_rec;

  IF reason_cur%NOTFOUND THEN

   /*====================================================*
    | Given audit reason is not available or not active. |
    *====================================================*/
    FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_NO_AC_MATCH');
    FND_MSG_PUB.Add;
    l_return_status1 := FND_API.G_RET_STS_ERROR;

  END IF;

  CLOSE reason_cur;

  Validate_Audit_dates(p_emp_rec, p_audit_rec, l_return_status2);

  IF (l_return_status1 = FND_API.G_RET_STS_ERROR OR l_return_status2 = FND_API.G_RET_STS_ERROR) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

END Validate_Audit_Info;

/*========================================================================
 | PRIVATE PROCEDUDE Validate_Audit_dates
 |
 | DESCRIPTION
 |   This procedure validates the audit dates given as parameter.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Validate_Audit_Info
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec       IN     Employee record containg criteria used to find a given employee
 |   p_audit_rec     IN OUT Audit record containg information about the record to be created
 |   x_return_status OUT    Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Audit_dates(p_emp_rec          IN             AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                               p_audit_rec        IN  OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type,
                               x_return_status        OUT NOCOPY VARCHAR2) IS

 /*============================================*
  | Cursor to find existing open ended record. |
  *============================================*/
  CURSOR open_cur IS
    SELECT auto_audit_id
    FROM ap_aud_auto_audits
    WHERE employee_id = p_emp_rec.person_id
    AND   audit_reason_code = p_audit_rec.audit_reason_code
    AND   end_date is NULL;

  open_rec open_cur%ROWTYPE;

BEGIN

  IF (    p_audit_rec.end_date is not null
      AND p_audit_rec.start_date is null ) THEN

    OPEN open_cur;
    FETCH open_cur INTO open_rec;

    IF open_cur%NOTFOUND THEN
     /*=======================================================================*
      | For record with only end date provided, there must exist a open ended |
      | record with same reason_code. This is used when an employee returns   |
      *=======================================================================*/
      FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_MISSING_ED_REC');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    CLOSE open_cur;

  END IF;

END Validate_Audit_dates;

/*========================================================================
 | PUBLIC PROCEDUDE Validate_Required_Input
 |
 | DESCRIPTION
 |   This procedure validates that the required parameters are passed to the api.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   AP_WEB_AUDIT_LIST_PUB.Deaudit_Employee
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec        IN  Employee record containg criteria used to find a given employee
 |   p_date_range_rec IN  Record containg date range
 |   x_return_status  OUT Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Jun-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Required_Input(p_emp_rec          IN  AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                                  p_date_range_rec   IN  AP_WEB_AUDIT_LIST_PUB.Date_Range_Type,
                                  x_return_status    OUT NOCOPY VARCHAR2) IS

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Business group id is always required
  IF p_emp_rec.business_group_id IS NULL THEN

    FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_BG_NULL');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

 /*======================================================================*
  | If all required parameters were provided, then at least one employee |
  | criteria is required.                                                |
  *======================================================================*/
  IF x_return_status = FND_API.G_RET_STS_SUCCESS
     AND p_emp_rec.person_id IS NULL
     AND p_emp_rec.employee_number IS NULL
     AND p_emp_rec.national_identifier IS NULL
     AND p_emp_rec.email_address IS NULL THEN

    FND_MESSAGE.SET_NAME('SQLAP','OIE_AUD_ALAPI_NO_EMP_INFO');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

END Validate_Required_Input;

END AP_WEB_AUDIT_LIST_VAL_PVT;

/
