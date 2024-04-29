--------------------------------------------------------
--  DDL for Package PA_UTILS3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_UTILS3" AUTHID CURRENT_USER AS
/* $Header: PAXGUT3S.pls 120.7.12010000.3 2011/01/18 13:12:08 ethella ship $*/

  TYPE ProjectsRec IS RECORD (
	Project_Number  Pa_Projects_All.Segment1%TYPE);

  TYPE ProjectsTab IS TABLE OF ProjectsRec
        INDEX BY BINARY_INTEGER;

  TYPE TasksRec IS RECORD (
        Task_Number  Pa_Tasks.Task_Number%TYPE);

  TYPE TasksTab IS TABLE OF TasksRec
        INDEX BY BINARY_INTEGER;

  TYPE EmpInfoRec IS RECORD (
	Employee_Number     Per_People_F.Employee_Number%TYPE,
	Business_Group_Name Hr_Organization_Units.Name%TYPE);

  TYPE EmpInfoTab Is TABLE OF EmpInfoRec
	INDEX BY BINARY_INTEGER;

  TYPE OrgNameRec IS RECORD (
	PersonId_Date      VARCHAR2(60),
	Org_Name           HR_Organization_Units.Name%TYPE);

  TYPE OrgNameTab IS TABLE OF OrgNameRec
	INDEX BY BINARY_INTEGER;

  TYPE OrgIdRec IS RECORD (
        Person_Id NUMBER,
	Start_Date DATE,
	End_Date   DATE,
        Org_Id   HR_Organization_Units.Organization_Id%TYPE);

  TYPE OrgIdTab IS TABLE OF OrgIdRec
        INDEX BY BINARY_INTEGER;

/* R12 Changes Start */
  TYPE OUNameRec IS RECORD (
        Org_ID             HR_ALL_ORGANIZATION_UNITS_TL.ORGANIZATION_ID%TYPE,
        OU_Name            HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE);

  TYPE OUNameTab IS TABLE OF OUNameRec
        INDEX BY BINARY_INTEGER;
/* R12 Changes End */

  Function Get_System_Linkage ( P_Expenditure_Type IN varchar2,
                                P_System_Linkage_Function IN varchar2,
                                P_System_Linkage_M IN varchar2 ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES ( Get_System_Linkage, WNDS );


  Procedure GetCachedProjNum (P_Project_Id IN NUMBER,
			      X_Project_Number OUT NOCOPY VARCHAR2);

  Procedure GetCachedTaskNum (P_Task_Id IN NUMBER,
			      X_Task_Number OUT NOCOPY VARCHAR2);

  Procedure GetCachedEmpInfo (P_Inc_By_Per_Id IN NUMBER,
                    P_exp_date       IN DATE ,
			      X_Inc_By_Per_Number OUT NOCOPY VARCHAR2,
			      X_Business_Group_Name OUT NOCOPY VARCHAR2);

  Procedure GetCachedOrgName (P_Inc_By_Per_Id IN NUMBER,
			      P_Exp_Item_Date IN DATE,
			      X_Inc_By_Org_Name OUT NOCOPY VARCHAR2);

  Procedure GetCachedOrgId (P_Inc_By_Per_Id IN NUMBER,
                            P_Exp_Item_Date IN DATE,
                            X_Inc_By_Org_Id OUT NOCOPY NUMBER);

  Function GetCachedProjNum (P_Project_Id IN NUMBER) RETURN pa_projects_all.segment1%TYPE;

  Function GetCachedTaskNum (P_Task_Id IN NUMBER) RETURN pa_tasks.task_number%TYPE;
  Function GetEmpNum (P_Person_Id IN NUMBER,P_ei_date  IN DATE DEFAULT sysdate) RETURN per_people_f.employee_number%TYPE;

  Function GetEiProjTask (P_exp_item_id   IN NUMBER,
                          P_Net_Zero_Flag IN VARCHAR2,
                          P_Transferred_from_exp_id IN NUMBER)
      RETURN VARCHAR2;

PROCEDURE get_asset_addition_flag
             (p_project_id           IN  pa_projects_all.project_id%TYPE,
              x_asset_addition_flag  OUT NOCOPY ap_invoice_distributions_all.assets_addition_flag%TYPE);

FUNCTION Get_Project_Type ( p_project_id IN pa_projects_all.project_id%TYPE)
RETURN varchar2;

/* Bug 10158684 changes start */
Function GetPastEmpNum (P_Person_Id IN NUMBER,P_ei_date  IN DATE DEFAULT sysdate)
              RETURN per_people_f.employee_number%TYPE;
/* Bug 10158684 changes end */

/* R12 Changes Start */
/***************************************************************************
   Function         : GetCachedOUName
   Purpose          : This function caches Operating Unit Identifier and names
                      in a PL/SQL table and retrieves the OU Name using the
                      Org ID passedas a input parameter.
   Arguments        : P_Org_ID - Organization Identifier
   Return           : Operating Unit Name
 ***************************************************************************/
  FUNCTION GetCachedOUName (P_Org_ID HR_ALL_ORGANIZATION_UNITS_TL.ORGANIZATION_ID%TYPE)
  RETURN HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
/* R12 Changes End */

END PA_UTILS3;

/
