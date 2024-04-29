--------------------------------------------------------
--  DDL for Package Body PA_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCES_PKG" AS
/* $Header: PARESOTB.pls 120.1.12010000.3 2009/03/12 07:41:52 rkartha ship $ */
-- Standard Table Handler procedures for PA_RESOURCES table
PROCEDURE Insert_row (
                X_Row_Id     IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                X_RESOURCE_ID IN NUMBER,
                X_NAME IN VARCHAR2,
                X_DESCRIPTION IN VARCHAR2,
                X_RESOURCE_TYPE_ID IN NUMBER,
                X_UNIT_OF_MEASURE IN VARCHAR2,
                X_ROLLUP_QUANTITY_FLAG IN VARCHAR2,
                X_START_DATE_ACTIVE IN DATE,
                X_END_DATE_ACTIVE IN DATE,
                X_TRACK_AS_LABOR_FLAG IN VARCHAR2,
                X_LAST_UPDATE_DATE IN DATE,
                X_LAST_UPDATED_BY IN NUMBER,
                X_CREATION_DATE IN DATE,
                X_CREATED_BY IN NUMBER,
                X_LAST_UPDATE_LOGIN IN NUMBER,
                X_ATTRIBUTE_CATEGORY IN VARCHAR2,
                X_ATTRIBUTE1 IN VARCHAR2)
IS
CURSOR RES_CUR IS Select Rowid from PA_RESOURCES
 Where Resource_Id = X_Resource_Id;
BEGIN
    Insert Into PA_RESOURCES (
                RESOURCE_ID,
                NAME,
                DESCRIPTION,
                RESOURCE_TYPE_ID,
                UNIT_OF_MEASURE,
                ROLLUP_QUANTITY_FLAG,
                START_DATE_ACTIVE,
                END_DATE_ACTIVE,
                TRACK_AS_LABOR_FLAG,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1)
     Values (
                X_RESOURCE_ID,
                X_NAME,
                X_DESCRIPTION,
                X_RESOURCE_TYPE_ID,
                X_UNIT_OF_MEASURE,
                X_ROLLUP_QUANTITY_FLAG,
                X_START_DATE_ACTIVE,
                X_END_DATE_ACTIVE,
                X_TRACK_AS_LABOR_FLAG,
                X_LAST_UPDATE_DATE,
                X_LAST_UPDATED_BY,
                X_CREATION_DATE,
                X_CREATED_BY,
                X_LAST_UPDATE_LOGIN,
                X_ATTRIBUTE_CATEGORY,
                X_ATTRIBUTE1);
       Open Res_Cur;
       Fetch Res_Cur Into X_Row_Id;
       If (Res_Cur%NOTFOUND)  then
           Close Res_Cur;
           Raise NO_DATA_FOUND;
        End If;
       Close Res_Cur;
END Insert_Row;
Procedure Update_Row (
                X_Row_Id     IN VARCHAR2,
                X_RESOURCE_ID IN NUMBER,
                X_NAME IN VARCHAR2,
                X_DESCRIPTION IN VARCHAR2,
                X_RESOURCE_TYPE_ID IN NUMBER,
                X_UNIT_OF_MEASURE IN VARCHAR2,
                X_ROLLUP_QUANTITY_FLAG IN VARCHAR2,
                X_START_DATE_ACTIVE IN DATE,
                X_END_DATE_ACTIVE IN DATE,
                X_TRACK_AS_LABOR_FLAG IN VARCHAR2,
                X_LAST_UPDATE_DATE IN DATE,
                X_LAST_UPDATED_BY IN NUMBER,
                X_LAST_UPDATE_LOGIN IN NUMBER,
                X_ATTRIBUTE_CATEGORY IN VARCHAR2,
                X_ATTRIBUTE1 IN VARCHAR2) IS
Begin
  Update PA_RESOURCES
     SET
       NAME                =   X_Name,
       DESCRIPTION         =   X_Description,
       RESOURCE_TYPE_ID    =   X_Resource_Type_Id,
       UNIT_OF_MEASURE     =   X_Unit_Of_Measure,
       ROLLUP_QUANTITY_FLAG =  X_Rollup_Quantity_Flag,
       START_DATE_ACTIVE   =   X_Start_Date_Active,
       END_DATE_ACTIVE     =   X_End_Date_Active,
       TRACK_AS_LABOR_FLAG =   X_Track_As_Labor_Flag,
       LAST_UPDATE_DATE    =   X_Last_Update_Date,
       LAST_UPDATED_BY     =   X_Last_Updated_By,
       LAST_UPDATE_LOGIN   =   X_Last_Update_Login,
       ATTRIBUTE_CATEGORY  =   X_ATTRIBUTE_CATEGORY,
       ATTRIBUTE1          =   X_ATTRIBUTE1
Where RowId = X_Row_Id;
If SQL%NOTFOUND Then
   Raise NO_DATA_FOUND;
End If;
End Update_Row;
Procedure Delete_Row (X_Row_Id In Varchar2) Is
Begin
   Delete from PA_RESOURCES Where RowId = X_Row_Id;
If SQL%NOTFOUND Then
   Raise NO_DATA_FOUND;
End If;
End Delete_Row;
Procedure Lock_Row (
                X_Row_Id     IN VARCHAR2,
                X_RESOURCE_ID IN NUMBER,
                X_NAME IN VARCHAR2,
                X_DESCRIPTION IN VARCHAR2,
                X_RESOURCE_TYPE_ID IN NUMBER,
                X_UNIT_OF_MEASURE IN VARCHAR2,
                X_ROLLUP_QUANTITY_FLAG IN VARCHAR2,
                X_START_DATE_ACTIVE IN DATE,
                X_END_DATE_ACTIVE IN DATE,
                X_TRACK_AS_LABOR_FLAG IN VARCHAR2,
                X_LAST_UPDATE_DATE IN DATE,
                X_LAST_UPDATED_BY IN NUMBER,
                X_LAST_UPDATE_LOGIN IN NUMBER,
                X_ATTRIBUTE_CATEGORY IN VARCHAR2,
                X_ATTRIBUTE1 IN VARCHAR2) IS
    CURSOR C Is
    Select * From PA_RESOURCES WHERE ROWID = X_ROW_ID
    For Update of RESOURCE_ID NOWAIT;
    Recinfo C%ROWTYPE;
Begin
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) THEN
       Close C;
       FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END If;
   CLOSE C;
   If (
      (X_RESOURCE_ID = Recinfo.RESOURCE_ID ) AND
      (X_NAME        = RecInfo.Name ) AND
      ((X_DESCRIPTION = RecInfo.Description) OR
        (Recinfo.Description is Null)) AND
      (X_RESOURCE_TYPE_ID  = Recinfo.Resource_Type_Id) AND
      ((X_UNIT_OF_MEASURE   = Recinfo.Unit_Of_Measure) OR
        (Recinfo.Unit_Of_Measure is Null ) ) AND
      (X_ROLLUP_QUANTITY_FLAG = Recinfo.Rollup_Quantity_Flag) AND
      (X_START_DATE_ACTIVE  = Recinfo.Start_Date_Active) AND
      ((X_END_DATE_ACTIVE =
       Recinfo.End_Date_Active) OR (Recinfo.End_Date_Active is Null)) AND
       (X_TRACK_AS_LABOR_FLAG = Recinfo.Track_As_Labor_Flag)  AND
       ((X_ATTRIBUTE_CATEGORY = Recinfo.Attribute_Category) OR
         (Recinfo.Attribute_Category Is Null ))
     AND
       ((X_ATTRIBUTE1 = Recinfo.Attribute1) OR
       (Recinfo.Attribute1 is Null ))
     )
     Then
       Return;
     Else
       FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
     END If;

End Lock_Row ;

/* Added function get_resource_name for bug 1299456 */
FUNCTION Get_Resource_Name(P_Resource_Id IN NUMBER,
                           P_resource_type_id IN NUMBER
                           ) RETURN VARCHAR2 IS
   P_Resource_Type_Code VARCHAR2(30);
   P_organization_name VARCHAR2(60);
   P_job_name VARCHAR2(60);
   P_employee_name VARCHAR2(60);

/* Bug Fix Code for Bug#2487415 UTF8. Changing the variable type to %TYPE. Modified the bug fix of
   2178043 */
   P_vendor_name po_vendors.vendor_name%TYPE;

   P_Name VARCHAR2(80);  -- Bug 2191972, incresed the size from 60 to 80.
   /*Commented the code for bug# 4143659 as this is not required.
   P_START_DATE_ACTIVE  pa_resources.start_date_active%TYPE; */
   l_uncateg_rl_name pa_resource_list_members.alias%TYPE;  /* added the variable for bug 2738156 */
BEGIN
         select resource_type_code
           into  P_Resource_Type_Code
           from  pa_resource_types
          where resource_type_id = P_resource_type_id;

/*Added for bug 1807084 to get star_date_active */

         /* Commented the code for bug# 4143659 as this is not required.
         Select start_date_active
         into p_start_date_active
         from pa_resources
         Where resource_id = P_resource_id; */

         if P_Resource_Type_Code = 'ORGANIZATION' then
            select substrb(org.name,1,60)   -- Bug#7832726
             into  P_organization_name
             from  hr_all_organization_units org       --For 1807084 hr_all_organization_units
                  ,pa_resource_txn_attributes prta
             where  prta.organization_id = org.organization_id
               and  prta.resource_id = P_resource_id;

            RETURN P_organization_name;

          elsif
            P_Resource_Type_Code = 'JOB' then
            select SUBSTR(pj.name,1,60)
             into  P_job_name
             from  per_jobs pj  -- For 1807084, per_jobs replaces pa_jobs_res_v
                  ,pa_resource_txn_attributes prta
            where  prta.job_id = pj.job_id
              and  prta.resource_id = P_resource_id;

            RETURN P_job_name;

          elsif
            P_Resource_Type_Code = 'EMPLOYEE' then
            select substrb(pe.full_name,1,60)   -- Bug#7832726
             into  P_employee_name
             from  per_all_people_f  pe    --For 1807084, per_all_people_f replaces pa_employees_res_v
                  ,pa_resource_txn_attributes prta
            where  prta.person_id = pe.person_id
              and  prta.resource_id = P_resource_id
	      /* Commented the below condition and added new and condition for bug# 4143659
              and  P_start_date_active between pe.effective_start_date and pe.effective_end_date */
	      and trunc(sysdate) between trunc(pe.effective_start_date) and trunc(pe.effective_end_date)
              and  (pe.employee_number is not NULL OR
                    pe.npw_number is not NULL);

            return P_employee_name;

          elsif
            P_Resource_Type_Code = 'VENDOR' then
            select pv.vendor_name     -- Bug#2178043
             into  P_vendor_name
              from  po_vendors pv              --For 1807084, po_vendors replaces pa_vendors_res_v
                   ,pa_resource_txn_attributes prta
            where  prta.vendor_id = pv.vendor_id
              and  prta.resource_id = P_resource_id;

             return P_vendor_name;

  elsif P_Resource_Type_Code = 'UNCATEGORIZED' then  /* added this elsif condition for bug 2738156 */

	        select distinct m.alias /* bug 7615636 */
		into l_uncateg_rl_name
	        from pa_resources r,
		     pa_resource_list_members m,
         	     pa_resource_lists_all_bg rl,
	             pa_implementations i
	        where  rl.uncategorized_flag = 'Y'
		  and  rl.resource_list_id = m.resource_list_id
		  and  m.resource_id = r.resource_id
		  and  rl.business_group_id = i.business_group_id;

		  return l_uncateg_rl_name;
         else
            select substr(name,1,80)  -- Bug 2191972 , replaced 60 with 80
             into P_name
              from pa_resources
             where resource_id = P_resource_id;

             return P_name;
          end if;

EXCEPTION
WHEN OTHERS THEN
     RAISE;
END Get_Resource_Name;

Function Get_Resource_List_Member_Name(p_resource_list_member_Id IN pa_resource_list_members.resource_list_member_id%TYPE)
RETURN VARCHAR2
IS
   l_resource_id        pa_resource_list_members.resource_id%TYPE;
   l_resource_type_id   pa_resource_list_members.resource_type_id%TYPE;
BEGIN

select resource_id, resource_type_id
into  l_resource_id,l_resource_type_id
from  pa_resource_list_members
where resource_list_member_id = p_resource_list_member_Id;

return Get_Resource_Name(l_resource_id, l_resource_type_id);

EXCEPTION
WHEN OTHERS THEN
     RAISE;
End Get_Resource_List_Member_Name;

END PA_Resources_Pkg;

/
