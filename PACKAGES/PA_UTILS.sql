--------------------------------------------------------
--  DDL for Package PA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAXGUTLS.pls 120.3 2006/03/15 02:06:12 degupta noship $ */

-- Global variable for business group id
  G_Business_Group_Id   NUMBER;

  TYPE  Char1TabTyp   IS TABLE OF VARCHAR2(1)
    INDEX BY BINARY_INTEGER;

  EmptyChar1Tab       Char1TabTyp;

  TYPE  Char10TabTyp  IS TABLE OF VARCHAR2(10)
    INDEX BY BINARY_INTEGER;

  EmptyChar10Tab      Char10TabTyp;

  TYPE  Char20TabTyp  IS TABLE OF VARCHAR2(20)
    INDEX BY BINARY_INTEGER;

  EmptyChar20Tab      Char20TabTyp;

  TYPE  Char25TabTyp  IS TABLE OF VARCHAR2(25)
    INDEX BY BINARY_INTEGER;

  EmptyChar25Tab      Char25TabTyp;

  TYPE  Char30TabTyp  IS TABLE OF VARCHAR2(30)
    INDEX BY BINARY_INTEGER;

  EmptyChar30Tab      Char30TabTyp;

  TYPE  Char150TabTyp IS TABLE OF VARCHAR2(150)
    INDEX BY BINARY_INTEGER;

  EmptyChar150Tab     Char150TabTyp;

  TYPE  Char240TabTyp IS TABLE OF VARCHAR2(240)
    INDEX BY BINARY_INTEGER;

  EmptyChar240Tab     Char240TabTyp;

  TYPE  DateTabTyp    IS TABLE OF DATE
    INDEX BY BINARY_INTEGER;

  EmptyDateTab        DateTabTyp;

  TYPE  IdTabTyp      IS TABLE OF NUMBER(15)
    INDEX BY BINARY_INTEGER;

  EmptyIdTab          IdTabTyp;

  TYPE  AmtTabTyp     IS TABLE OF NUMBER(22,5)
    INDEX BY BINARY_INTEGER;

  EmptyAmtTab         AmtTabTyp;

  TYPE NewAmtTabTyp  IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  EmptyNewAmtTab     NewAmtTabTyp;

  TYPE Char15TabTyp  IS TABLE OF VARCHAR2(15)
    INDEX BY BINARY_INTEGER;

  EmptyChar15Tab     Char15TabTyp;

  record_count        BINARY_INTEGER DEFAULT 0;

  --Global variable to store employee_id
  Global_Employee_Id   NUMBER := NULL;

  TYPE WeekEndDateTab IS TABLE OF DATE
        INDEX BY BINARY_INTEGER;
  G_WeekEndDateTab WeekEndDateTab;


-- PUBLIC PROCEDURES and FUNCTIONS
--

  PROCEDURE  GetProjInfo ( X_proj_id     IN NUMBER
                         , X_proj_num    OUT NOCOPY VARCHAR2
                         , X_proj_name   OUT NOCOPY VARCHAR2 );

--  This procedure accepts as input a project ID and returns as output the
--  project's project number and name.  If there is no project record that
--  matches the given project ID, then this procedure returns NULL for both
--  the project number and project name.

  PROCEDURE GetTaskInfo ( X_task_id    IN NUMBER
                        , X_task_num   OUT NOCOPY VARCHAR2
                        , X_task_name  OUT NOCOPY VARCHAR2 );

--  This procedure accepts as input a task ID and returns as output the
--  task's task number and name.  If there is no task record that
--  matches the given task ID, then this procedure returns NULL for both
--  the task number and task name.

  FUNCTION  GetProjId ( X_project_num  IN VARCHAR2 ) RETURN NUMBER;
--  pragma RESTRICT_REFERENCES ( GetProjId, WNDS, WNPS);

--  This function accepts as input a project number and returns as output the
--  project's project ID.  If there is no project that matches the project
--  number given, then this function returns NULL.

  FUNCTION  GetEmpId ( X_emp_num  IN VARCHAR2 ) RETURN NUMBER;
  pragma  RESTRICT_REFERENCES ( GetEmpId, WNDS, WNPS );

--  This function accepts as input an employee number and returns as output the
--  employee's person ID.  If there is no employee record that matches the
--  employee number given, then this function returns NULL.

  FUNCTION  GetEmpIdFromUser ( X_userid  IN NUMBER ) RETURN NUMBER;
  pragma  RESTRICT_REFERENCES ( GetEmpIdFromUser, WNDS, WNPS);

--  This function accepts as input a user ID and returns as output the user's
--  person ID.  If the user is not an employee, or the user ID given is not
--  valid, then this function returns NULL.

  FUNCTION  GetEmpName ( X_person_id  IN NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES ( GetEmpName, WNDS, WNPS );

--  This function accepts as input a person ID and returns as output the
--  person's full name.  If there is no person record that matches the person
--  ID given, then this function returns NULL.

  FUNCTION  GetTaskId ( X_proj_id  IN NUMBER
                      , X_task_num IN VARCHAR2 ) RETURN NUMBER;
--  pragma RESTRICT_REFERENCES ( GetTaskId, WNDS, WNPS );

--  This function accepts as input a project ID and a task number and returns
--  as output the task's task ID.  If there is no task record for the given
--  project ID and task number, then this function returns NULL.

    FUNCTION  GetOrgId ( X_org_name  IN VARCHAR2 ) RETURN NUMBER;
--  pragma RESTRICT_REFERENCES ( GetOrgId, WNDS, WNPS );

--Bug#3010848
  PROCEDURE  GetOrgnId ( X_org_name  IN VARCHAR2
                        ,X_bg_id     IN NUMBER DEFAULT NULL
                        ,X_Orgn_Id  OUT NOCOPY Number
                        ,X_Return_Status OUT NOCOPY Varchar2);


--  This function accepts as input an organization name and business group id.
--  and returns as output the organization's organization ID.
--  If there is no organization record
--  for the given organization name, then this function returns NULL.

  FUNCTION  GetOrgName ( X_org_id  IN NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES ( GetOrgName, WNDS, WNPS );

--  This function accepts as input an organization ID and returns as output
--  the organization's name.  If there is no organization record for the
--  given organization ID, then this function returns NULL.

  FUNCTION  GetWeekEnding ( X_date  IN DATE ) RETURN DATE;
  pragma RESTRICT_REFERENCES ( GetWeekEnding, WNDS, WNPS );

--  This function accepts as input a date in the format DD-MON-YY and returns
--  as output the ending date of the expenditure week in which this date
--  occurs.

  FUNCTION  DateInExpWeek ( X_date      IN DATE
                          , X_week_end  IN DATE ) RETURN BOOLEAN;
--  pragma RESTRICT_REFERENCES ( DateInExpWeek, WNDS, WNPS );

--  This function accepts as input a test date and a week ending date.  If the
--  the test date is within the expenditure week that ends on the week end
--  date provided, then this function returns TRUE.  Otherwise, it returns
--  FALSE.  Note: this function assumes that the week end date provided is
--  a valid week ending date.

  FUNCTION  GetEmpOrgId ( X_person_id  IN NUMBER
                        , X_date       IN DATE    ) RETURN NUMBER;
--  pragma RESTRICT_REFERENCES ( GetEmpOrgId, WNDS, WNPS );

--  This function accepts as input a person ID and a date and returns the
--  organization ID of the person's organization assignment as of the input
--  date.  If the person does not have a current assignment, or if the person
--  ID passed is not valid, then this function returns NULL.

  FUNCTION  GetEmpCostRate ( X_person_id  IN NUMBER
                           , X_date       IN DATE    ) RETURN NUMBER;
--  pragma RESTRICT_REFERENCES ( GetEmpCostRate, WNDS, WNPS );

--  This function accepts as input a person ID and a date and returns the
--  hourly cost rate defined for the person as of the input date.  If the
--  person does not have a cost rate as of the input date, then this function
--  returns NULL.

  FUNCTION  GetExpTypeCostRate ( X_expenditure_type  IN VARCHAR2
                               , X_date              IN DATE ) RETURN NUMBER;
  pragma RESTRICT_REFERENCES ( GetExpTypeCostRate, WNDS, WNPS );

  FUNCTION  GetEmpJobId ( X_person_id  IN NUMBER
                        , X_date       IN DATE
                        , X_person_type IN VARCHAR2 DEFAULT NULL
                        , X_po_number IN VARCHAR2 DEFAULT NULL -- Bug 4044057
                        , X_po_line_num IN NUMBER DEFAULT NULL -- Bug 4044057
                        , X_po_header_id IN NUMBER DEFAULT NULL -- Bug 4044057
                        , X_po_line_id IN NUMBER DEFAULT NULL ) RETURN NUMBER;
--  pragma RESTRICT_REFERENCES ( GetEmpJobId, WNDS, WNPS );

  FUNCTION  GetNextEiId  RETURN NUMBER;

--  This function selects and returns the next value in the sequence,
--  PA_EXPENDITURE_ITEMS_S.

  FUNCTION  CheckExpTypeActive( X_expenditure_type  IN VARCHAR2
                              , X_date              IN DATE ) RETURN BOOLEAN;
  pragma RESTRICT_REFERENCES (CheckExpTypeActive, WNDS, WNPS );

--  This function accepts as input an expenditure type and a date and returns
--  either TRUE or FALSE depending on wheter the expenditure type exists and
--  is active as of the date parameter.


  FUNCTION get_org_hierarchy_top ( X_org_structure_version_id  IN NUMBER )
     RETURN NUMBER;
  pragma RESTRICT_REFERENCES (get_org_hierarchy_top, WNDS, WNPS);

--  This function accepts as input the ORG_STRUCTURE_VERSION_ID for the
--  organization hierarchy for which you want to get the top organization.
--  The return value is the organization_id for the top organization in that
--  hierarchy.

  FUNCTION  Get_business_group_id  RETURN NUMBER;
  pragma  RESTRICT_REFERENCES ( Get_business_group_id, WNDS, WNPS );

  PROCEDURE Set_business_group_id ; --sets global var. G_Business_Group_Id

  FUNCTION business_group_id RETURN NUMBER;
  pragma RESTRICT_REFERENCES (business_group_id, WNDS, WNPS,RNPS);

--  Ramesh Krishnamurthy - 01-APR-1997 -- Added pragma RNPS since in the
--  absence of this pragma,views which reference this function cannot
--  be accessed remotely.

--  This function returns the BUSINESS_GROUP_ID defined in PA_IMPLEMENTATIONS
--  for the current operating unit.

  FUNCTION is_project_costing_installed RETURN VARCHAR2;
--  pragma RESTRICT_REFERENCES (is_project_costing_installed, WNDS, WNPS );

-- This function returns the 'Y' if Project Costing is installed.
-- Otherwise, the function returns 'N'.

  FUNCTION IsCrossChargeable( X_Project_Id  Number )  RETURN BOOLEAN;
--  pragma RESTRICT_REFERENCES (IsCrossChargeable, WNDS, WNPS);

--  This function returns if the project Id passed is cross chargeable


  FUNCTION pa_morg_implemented RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (pa_morg_implemented, WNDS, WNPS);

-- This function returns 'Y' if multi-org is implemented, otherwise, it
-- returns 'N'.

  FUNCTION CheckProjectOrg (x_org_id IN NUMBER) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES ( CheckProjectOrg, WNDS, WNPS);

--  G.Prothia  - 15-AUG-97 - Removed pragma RNPS
--
--  Ramesh Krishnamurthy - 01-APR-1997 -- Added pragma RNPS since in the
--  absence of this pragma,views which reference this function cannot
--  be accessed remotely.

-- This function returns 'Y' if a given org is a project organization ,
-- otherwise , it returns 'N'

------------------------------------------------------------------------
--function  : get_pa_date
--	(Formerly called pa_date_from_gl_date)
--	Derive PA Date from GL date and ei date .
-- This function accepts the expenditure item date and the GL date and
-- derives the PA date based on this. The function has been modified
-- to not use the gl_Date (though it is still accepted as a parameter
-- just in case the logic changes in the future to use the gl_Date).
-- This is mainly used for AP invoices and transactions imported from
-- other systems where the GL date is known in advance and the PA date
-- has to be determined.
------------------------------------------------------------------------
FUNCTION get_pa_date( x_ei_date  IN date, x_gl_date IN date ) return date ;
-- PRAGMA RESTRICT_REFERENCES ( get_pa_date, WNDS, WNPS ) ;

----------------------------------------------------------------------
-- Function  : get_pa_end_date
--	Derive the period end date based on the period name
--
--   This function accepts the period name and gets the period end
--   date from the pa_periods table.  The function created for
--   burden cost accounting.
--   Created by Sandeep 04-MAR-1998
-----------------------------------------------------------------------
FUNCTION get_pa_end_date( x_pa_period_name IN varchar2 ) return date ;
PRAGMA RESTRICT_REFERENCES ( get_pa_end_date, WNDS, WNPS ) ;

------------------------------------------------------------------------
-- function  : get_pa_period_name
--	Derive Period name from GL date and ei date .
-- This function accepts the expenditure item date and the GL date and
-- derives the period name based on this. In its current form, it does
-- not use the GL date but derives the period name solely based on the
-- expenditure item date. However, the GL date is retained as a
-- parameter just in case it is required to derive the pa_date based
-- on it in the future.
-- This is mainly used for AP invoices and transactions imported from
-- other systems where the GL date is known in advance and the PA date
-- has to be determined. The pa_date_from_gl_date function returns the
-- PA date. This function is identical except that it returns the
-- corresponding period name.
------------------------------------------------------------------------
FUNCTION get_pa_period_name( x_ei_date  IN date, x_gl_date IN date ) return varchar2 ;
-- PRAGMA RESTRICT_REFERENCES ( get_pa_period_name, WNDS, WNPS ) ;

FUNCTION GetETypeClassCode (x_system_linkage IN VARCHAR2) RETURN VARCHAR2;
--pragma RESTRICT_REFERENCES ( GetETypeClassCode, WNDS, WNPS );

---------------------------------------------------------------
-- function  : Get_Org_Window_Title
--	This function that returns the organization name. If multi-org
-- is enabled then the organization name (operating Unit) is derived from
-- the profile option instead of implementation options. If multi-org is not
-- enabled then display set of books name in window title.
---------------------------------------------------------------

FUNCTION Get_Org_Window_Title return varchar2;


---------------------------------------------------------------
-- Function : GetGlobalEmpId
-- This function returns the packaged variable Global_Employee_Id.
---------------------------------------------------------------
FUNCTION GetGlobalEmpId RETURN NUMBER;

---------------------------------------------------------------
-- Procedure : SetGlobalEmpId
-- This procedure sets the packaged variable Global_Employee_Id.
---------------------------------------------------------------

PROCEDURE SetGlobalEmpId( p_emp_id NUMBER );

---------------------------------------------------------------
-- Procedure : Get_Encoded_Msg
--    This procedure serves as a wrapper to the function
--    FND_MSG_PUB.Get.  It is needed to access the call from
--    client FORMS.
---------------------------------------------------------------

Procedure Get_Encoded_Msg(p_index	IN   	NUMBER,
			  p_msg_out	IN OUT  NOCOPY VARCHAR2 );

---------------------------------------------------------------
-- Procedure : Add_Message
--    This procedure serves as a wrapper to the FND_MEG_PUB
--    procedures to add the specified message onto the message
--    stack.
---------------------------------------------------------------

Procedure Add_Message( p_app_short_name	IN	VARCHAR2,
		       p_msg_name	IN	VARCHAR2,
		       p_token1		IN	VARCHAR2 DEFAULT NULL,
		       p_value1		IN	VARCHAR2 DEFAULT NULL,
		       p_token2		IN	VARCHAR2 DEFAULT NULL,
		       p_value2		IN	VARCHAR2 DEFAULT NULL,
		       p_token3		IN	VARCHAR2 DEFAULT NULL,
		       p_value3		IN	VARCHAR2 DEFAULT NULL,
		       p_token4		IN	VARCHAR2 DEFAULT NULL,
		       p_value4		IN	VARCHAR2 DEFAULT NULL,
		       p_token5		IN	VARCHAR2 DEFAULT NULL,
		       p_value5		IN	VARCHAR2 DEFAULT NULL );

---------------------------------------------------------------
-- Function : IsCrossBGProfile_WNPS
--    This procedure serves as a wrapper to the FND_PROFILE.VALUE_WNPS.
---------------------------------------------------------------
FUNCTION IsCrossBGProfile_WNPS
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES ( IsCrossBGProfile_WNPS, WNDS, WNPS);

---------------------------------------------------------------
-- Function : Conv_Special_JS_Chars
-- This function converts special characters in javascript link.
-- Currently, this function only handles apostrophe sign.
---------------------------------------------------------------
FUNCTION Conv_Special_JS_Chars(p_string in varchar2) RETURN VARCHAR2;

---------------------------------------------------------------
-- Function :Pa_Round_Currency
-- This function rounds the amount to the required precision based
-- on the currency code
---------------------------------------------------------------
FUNCTION Pa_Round_Currency (P_Amount IN NUMBER, P_Currency_Code  IN VARCHAR2)
RETURN NUMBER;

---------------------------------------------------------------
FUNCTION get_party_id (
 p_user_id in number ) return number;


  PROCEDURE  GetEmpOrgJobId ( X_person_id  IN NUMBER
                            , X_date       IN DATE
                            , X_Emp_Org_Id OUT NOCOPY NUMBER
                            , X_Emp_Job_Id OUT NOCOPY NUMBER
                            , X_po_number IN VARCHAR2 DEFAULT NULL -- Bug 4044057
                            , X_po_line_num IN NUMBER DEFAULT NULL); -- Bug 4044057

 FUNCTION  NewGetWeekEnding ( X_date  IN DATE ) RETURN DATE;

/* Added for bug 5067511 */
 FUNCTION  GetPersonInfo( p_person_id IN per_all_people_f.person_id%TYPE,
                          p_data IN VARCHAR2 DEFAULT 'PERSON_ID') RETURN VARCHAR2;

   G_PREV_TASK_ID    NUMBER(15);
   G_PREV_TASK_NUM   VARCHAR2(25);
   G_PREV_TASK_NAME  VARCHAR2(20);
   G_PREV_ORG_NAME   VARCHAR2(240); -- fix for bug : 4598283
   G_PREV_ORG_ID     NUMBER(15);
   G_PREV_DATE       DATE;
   G_PREV_WEEK_END   DATE;
   G_PREV_DATEIN     NUMBER(15);
   G_PREV_PROJ_ID    NUMBER(15);
   G_PREV_CHARGE     NUMBER(15);
   G_PREV_PROJ_NUM   VARCHAR2(25);
   G_PREV_PROJECT_ID NUMBER(15);
   G_PREV_PROJ_ID2   NUMBER(15);
   G_PREV_TASK_NUM2  VARCHAR2(25);
   G_PREV_TASK_ID2   NUMBER(15);
   G_PREV_DATE2      DATE;
   G_PREV_WEEK_END2  DATE;
   G_PREV_PERSON_ID  NUMBER(15);
   G_PREV_DATE3      DATE;
   G_PREV_EMPJOB_ID  NUMBER(15);
   G_PREV_PERSON_ID2 NUMBER(15);
   G_PREV_DATE4      DATE;
   G_PREV_ORG_ID2    NUMBER(15);
   G_EmpOrgId     NUMBER;
   G_EmpJobID     NUMBER;
   G_PersonIdPrev NUMBER;
   G_DatePrev     DATE;
   G_PREV_SYS_LINK   VARCHAR(30);
   G_PREV_FUNCTION   VARCHAR(30);
   G_PREV_DATE5   DATE;
   G_PREV_DAY_INDEX NUMBER;
   G_PREV_END_DAY   VARCHAR2(80);
   G_PREV_WEEK_END3  DATE;

END PA_UTILS;

 

/
