--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_LIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_LIST_PKG" AS
/* $Header: PARELITB.pls 120.1 2005/08/19 16:50:13 mwasowic noship $ */
-- Standard Table Handler procedures for PA_RESOURCE_LISTS table

PROCEDURE Insert_parent_row (X_ROW_ID IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_RESOURCE_ID             NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_MEMBER_LEVEL            NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_TRACK_AS_LABOR_FLAG     VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_CREATION_DATE           DATE,
                             X_CREATED_BY              NUMBER,
                             X_LAST_UPDATE_LOGIN       NUMBER,
                             X_Funds_Control_Level_Code VARCHAR2,
                             p_migration_code          VARCHAR2
                             ) IS
CURSOR PARENT_RES_CUR IS
Select
Rowid
from
PA_RESOURCE_LIST_MEMBERS
Where Resource_List_Member_Id   =  X_Resource_List_Member_Id;

-- Added for bug 1889671

l_person_id              pa_resource_txn_attributes.person_id%TYPE;
l_job_id                 pa_resource_txn_attributes.job_id%TYPE;
l_organization_id        pa_resource_txn_attributes.organization_id%TYPE;
l_vendor_id              pa_resource_txn_attributes.vendor_id%TYPE;
l_project_role_id        pa_resource_txn_attributes.project_role_id%TYPE;
l_expenditure_type       pa_resource_txn_attributes.expenditure_type%TYPE;
l_event_type             pa_resource_txn_attributes.event_type%TYPE;
l_expenditure_category   pa_resource_txn_attributes.expenditure_category%TYPE;
l_revenue_category       pa_resource_txn_attributes.revenue_category%TYPE;
l_nlr_resource           pa_resource_txn_attributes.non_labor_resource%TYPE;
l_nlr_res_org_id         pa_resource_txn_attributes.non_labor_resource_org_id%TYPE;
l_event_type_cls         pa_resource_txn_attributes.event_type_classification%TYPE;
l_system_link_function   pa_resource_txn_attributes.system_linkage_function%TYPE;
l_resource_format_id     pa_resource_txn_attributes.resource_format_id%TYPE;
l_resource_type_id       pa_resource_types.resource_type_id%TYPE;
l_res_type_code          pa_resource_types.resource_type_code%TYPE;

BEGIN

/* Added for bug 1889671. This will fetch 13 txn attributed from pa_resource_txn_attributes table
along with resource_format_id. Also,resoure_type_id and resource_type_code is also fetched.*/

  SELECT prta.person_id,
         prta.job_id,
         prta.organization_id,
         prta.vendor_id,
         prta.project_role_id,
         prta.expenditure_type,
         prta.event_type,
         prta.expenditure_category,
         prta.revenue_category,
         prta.non_labor_resource,
         prta.non_labor_resource_org_id,
         prta.event_type_classification,
         prta.system_linkage_function,
         prta.resource_format_id,
         prt.resource_type_id,
         prt.resource_type_code
  INTO   l_person_id,
         l_job_id,
         l_organization_id,
         l_vendor_id,
         l_project_role_id,
         l_expenditure_type,
         l_event_type,
         l_expenditure_category,
         l_revenue_category,
         l_nlr_resource,
         l_nlr_res_org_id,
         l_event_type_cls,
         l_system_link_function,
         l_resource_format_id,
         l_resource_type_id,
         l_res_type_code
  FROM   PA_RESOURCE_TXN_ATTRIBUTES PRTA,
         PA_RESOURCES PR,
         PA_RESOURCE_TYPES PRT
  WHERE  prta.resource_id = pr.resource_id
    AND  pr.resource_id =X_RESOURCE_ID
    AND  pr.resource_type_id= prt.resource_type_id;

/* As this select will not be used to insert unclassified resource, so no outer join is kept for
   prta table  */

  Insert Into PA_RESOURCE_LIST_MEMBERS
                            (RESOURCE_LIST_MEMBER_ID,
                             RESOURCE_LIST_ID,
                             RESOURCE_ID ,
                             ALIAS ,
                             SORT_ORDER ,
                             MEMBER_LEVEL,
                             DISPLAY_FLAG ,
                             ENABLED_FLAG,
                             TRACK_AS_LABOR_FLAG,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_DATE,
                             CREATION_DATE,
                             CREATED_BY,
                             LAST_UPDATE_LOGIN,
                             PARENT_MEMBER_ID,
                             Funds_Control_Level_Code,
                             PERSON_ID,             /*16 newly added columns-bug 1889671*/
                             JOB_ID,
                             ORGANIZATION_ID,
                             VENDOR_ID,
                             PROJECT_ROLE_ID,
                             EXPENDITURE_TYPE,
                             EVENT_TYPE,
                             EXPENDITURE_CATEGORY,
                             REVENUE_CATEGORY,
                             NON_LABOR_RESOURCE,
                             NON_LABOR_RESOURCE_ORG_ID,
                             EVENT_TYPE_CLASSIFICATION,
                             SYSTEM_LINKAGE_FUNCTION,
                             RESOURCE_FORMAT_ID,
                             RESOURCE_TYPE_ID,
                             RESOURCE_TYPE_CODE,
                             migration_code
                             )
              VALUES
                            (X_RESOURCE_LIST_MEMBER_ID,
                             X_RESOURCE_LIST_ID,
                             X_RESOURCE_ID,
                             X_ALIAS ,
                             X_SORT_ORDER ,
                             X_MEMBER_LEVEL,
                             X_DISPLAY_FLAG,
                             X_ENABLED_FLAG,
                             X_TRACK_AS_LABOR_FLAG,
                             X_LAST_UPDATED_BY,
                             X_LAST_UPDATE_DATE,
                             X_CREATION_DATE,
                             X_CREATED_BY,
                             X_LAST_UPDATE_LOGIN,
                             NULL,
                             X_Funds_Control_Level_Code,
                             l_person_id,         /*16 newly added columns-bug 1889671*/
                             l_job_id,
                             l_organization_id,
                             l_vendor_id,
                             l_project_role_id,
                             l_expenditure_type,
                             l_event_type,
                             l_expenditure_category,
                             l_revenue_category,
                             l_nlr_resource,
                             l_nlr_res_org_id,
                             l_event_type_cls,
                             l_system_link_function,
                             l_resource_format_id,
                             l_resource_type_id,
                             l_res_type_code,
                             p_migration_code
                             );

       Open Parent_Res_Cur;
       Fetch Parent_Res_Cur Into X_Row_Id;
       If (Parent_Res_Cur%NOTFOUND)  then
           Close Parent_Res_Cur;
           Raise NO_DATA_FOUND;
        End If;
       Close Parent_Res_Cur;
/*Commenting the exception block for the bug 3355209 since 1)it is again standards
2) FND_MESSAGE.SET_NAME('PA' ,SQLERRM) is wrong which was returning no_data_found
Exception
       When Others Then
       FND_MESSAGE.SET_NAME('PA' ,SQLERRM);
       APP_EXCEPTION.RAISE_EXCEPTION;*/
END Insert_Parent_Row;

PROCEDURE Update_Parent_Row (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_MEMBER_LEVEL            NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_TRACK_AS_LABOR_FLAG     VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_LAST_UPDATE_LOGIN       NUMBER,
                             X_Funds_Control_Level_Code VARCHAR2,
                             p_migration_code          VARCHAR2
                             ) IS
BEGIN

         Update PA_RESOURCE_LIST_MEMBERS
                SET
                ALIAS               = X_ALIAS,
                SORT_ORDER          = X_SORT_ORDER,
                DISPLAY_FLAG        = X_DISPLAY_FLAG,
                ENABLED_FLAG        = X_ENABLED_FLAG,
                TRACK_AS_LABOR_FLAG = X_TRACK_AS_LABOR_FLAG,
                MIGRATION_CODE      = p_migration_code,
                LAST_UPDATED_BY     = X_LAST_UPDATED_BY,
                LAST_UPDATE_DATE    = X_LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN   = X_LAST_UPDATE_LOGIN,
                Funds_Control_Level_Code = X_Funds_Control_Level_Code
                WHERE ROWID         = X_ROW_ID;
  If SQL%NOTFOUND Then
     Raise NO_DATA_FOUND;
  End If;
END Update_parent_row;

Procedure Lock_Parent_Row   (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_RESOURCE_ID             NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_Funds_Control_Level_Code VARCHAR2,
                             p_migration_code          VARCHAR2) IS
CURSOR C Is
    Select * From PA_RESOURCE_LIST_MEMBERS WHERE ROWID = X_ROW_ID
    For Update of RESOURCE_LIST_MEMBER_ID NOWAIT;
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
   IF (
        (X_RESOURCE_LIST_MEMBER_ID = Recinfo.RESOURCE_LIST_MEMBER_ID) And
        (X_RESOURCE_ID             = Recinfo.RESOURCE_ID) And
        ((X_ALIAS                  = Recinfo.ALIAS) OR
        (Recinfo.ALIAS Is Null))  AND
        (nvl(p_migration_code, '-99') = nvl(Recinfo.migration_code, '-99')) AND
        (X_SORT_ORDER              = Recinfo.SORT_ORDER ) AND
        (X_DISPLAY_FLAG            = Recinfo.DISPLAY_FLAG ) AND
        (X_ENABLED_FLAG            = Recinfo.ENABLED_FLAG) AND
        ( (Recinfo.Funds_Control_Level_Code =  X_Funds_Control_Level_Code)
                OR ( (Recinfo.Funds_Control_Level_Code IS NULL)
                      AND (X_Funds_Control_Level_Code IS NULL)  )
        )

      ) Then
         Return;
   Else
         FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
         APP_EXCEPTION.RAISE_EXCEPTION;
   END If;

End Lock_Parent_Row;

Procedure Delete_Parent_Row (X_ROW_ID IN VARCHAR2) Is
Begin
   Delete from PA_RESOURCE_LIST_MEMBERS Where RowId = X_Row_Id;
If SQL%NOTFOUND Then
   Raise NO_DATA_FOUND;
End If;

End Delete_Parent_Row;

PROCEDURE Insert_child_row  (X_ROW_ID IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_RESOURCE_ID             NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_PARENT_MEMBER_ID        NUMBER,
                             X_SORT_ORDER              NUMBER,
                             X_MEMBER_LEVEL            NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_TRACK_AS_LABOR_FLAG     VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_CREATION_DATE           DATE,
                             X_CREATED_BY              NUMBER,
                             X_LAST_UPDATE_LOGIN       NUMBER,
                             X_Funds_Control_Level_Code VARCHAR2
                             ) IS

CURSOR CHILD_RES_CUR IS Select Rowid from PA_RESOURCE_LIST_MEMBERS
 Where Resource_List_Member_Id   =  X_Resource_List_Member_Id;

-- Added for bug 1889671

l_person_id              pa_resource_txn_attributes.person_id%TYPE;
l_job_id                 pa_resource_txn_attributes.job_id%TYPE;
l_organization_id        pa_resource_txn_attributes.organization_id%TYPE;
l_vendor_id              pa_resource_txn_attributes.vendor_id%TYPE;
l_project_role_id        pa_resource_txn_attributes.project_role_id%TYPE;
l_expenditure_type       pa_resource_txn_attributes.expenditure_type%TYPE;
l_event_type             pa_resource_txn_attributes.event_type%TYPE;
l_expenditure_category   pa_resource_txn_attributes.expenditure_category%TYPE;
l_revenue_category       pa_resource_txn_attributes.revenue_category%TYPE;
l_nlr_resource           pa_resource_txn_attributes.non_labor_resource%TYPE;
l_nlr_res_org_id         pa_resource_txn_attributes.non_labor_resource_org_id%TYPE;
l_event_type_cls         pa_resource_txn_attributes.event_type_classification%TYPE;
l_system_link_function   pa_resource_txn_attributes.system_linkage_function%TYPE;
l_resource_format_id     pa_resource_txn_attributes.resource_format_id%TYPE;
l_resource_type_id       pa_resource_types.resource_type_id%TYPE;
l_res_type_code          pa_resource_types.resource_type_code%TYPE;


BEGIN

/* Added for bug 1889671. This will fetch 13 txn attributed from pa_resource_txn_attributes table
along with resource_format_id. Also,resoure_type_id and resource_type_code is also fetched.*/

SELECT   prta.person_id,
         prta.job_id,
         prta.organization_id,
         prta.vendor_id,
         prta.project_role_id,
         prta.expenditure_type,
         prta.event_type,
         prta.expenditure_category,
         prta.revenue_category,
         prta.non_labor_resource,
         prta.non_labor_resource_org_id,
         prta.event_type_classification,
         prta.system_linkage_function,
         prta.resource_format_id,
         prt.resource_type_id,
         prt.resource_type_code

  INTO   l_person_id,
         l_job_id,
         l_organization_id,
         l_vendor_id,
         l_project_role_id,
         l_expenditure_type,
         l_event_type,
         l_expenditure_category,
         l_revenue_category,
         l_nlr_resource,
         l_nlr_res_org_id,
         l_event_type_cls,
         l_system_link_function,
         l_resource_format_id,
         l_resource_type_id,
         l_res_type_code
  FROM   PA_RESOURCE_TXN_ATTRIBUTES PRTA,
         PA_RESOURCES PR,
         PA_RESOURCE_TYPES PRT
  WHERE  prta.resource_id(+) = pr.resource_id
    AND  pr.resource_id =X_RESOURCE_ID
    AND  pr.resource_type_id= prt.resource_type_id;

/* As this select will not be used to insert unclassified resource, so no outer join is kept for
   prta table  */

  Insert Into PA_RESOURCE_LIST_MEMBERS
                            (RESOURCE_LIST_MEMBER_ID,
                             RESOURCE_LIST_ID,
                             RESOURCE_ID ,
                             ALIAS ,
                             PARENT_MEMBER_ID,
                             SORT_ORDER ,
                             MEMBER_LEVEL,
                             DISPLAY_FLAG ,
                             ENABLED_FLAG,
                             TRACK_AS_LABOR_FLAG,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_DATE,
                             CREATION_DATE,
                             CREATED_BY,
                             LAST_UPDATE_LOGIN,
                             Funds_Control_Level_Code,
                             PERSON_ID,       /*16 newly added columns-bug 1889671*/
                             JOB_ID,
                             ORGANIZATION_ID,
                             VENDOR_ID,
                             PROJECT_ROLE_ID,
                             EXPENDITURE_TYPE,
                             EVENT_TYPE,
                             EXPENDITURE_CATEGORY,
                             REVENUE_CATEGORY,
                             NON_LABOR_RESOURCE,
                             NON_LABOR_RESOURCE_ORG_ID,
                             EVENT_TYPE_CLASSIFICATION,
                             SYSTEM_LINKAGE_FUNCTION,
                             RESOURCE_FORMAT_ID,
                             RESOURCE_TYPE_ID,
                             RESOURCE_TYPE_CODE
                             )
              VALUES
                            (X_RESOURCE_LIST_MEMBER_ID,
                             X_RESOURCE_LIST_ID,
                             X_RESOURCE_ID,
                             X_ALIAS ,
                             X_PARENT_MEMBER_ID,
                             X_SORT_ORDER ,
                             X_MEMBER_LEVEL,
                             X_DISPLAY_FLAG,
                             X_ENABLED_FLAG,
                             X_TRACK_AS_LABOR_FLAG,
                             X_LAST_UPDATED_BY,
                             X_LAST_UPDATE_DATE,
                             X_CREATION_DATE,
                             X_CREATED_BY,
                             X_LAST_UPDATE_LOGIN,
                             X_Funds_Control_Level_Code,
                             l_person_id,          /*16 newly added columns-bug 1889671*/
                             l_job_id,
                             l_organization_id,
                             l_vendor_id,
                             l_project_role_id,
                             l_expenditure_type,
                             l_event_type,
                             l_expenditure_category,
                             l_revenue_category,
                             l_nlr_resource,
                             l_nlr_res_org_id,
                             l_event_type_cls,
                             l_system_link_function,
                             l_resource_format_id,
                             l_resource_type_id,
                             l_res_type_code
                             );

       Open CHILD_Res_Cur;
       Fetch CHILD_Res_Cur Into X_Row_Id;
       If (CHILD_Res_Cur%NOTFOUND)  then
           Close Child_Res_Cur;
           Raise NO_DATA_FOUND;
        End If;
       Close CHILD_Res_Cur;
 /*Commenting the exception block for the bug 3355209 since 1)it is again standards
2) FND_MESSAGE.SET_NAME('PA' ,SQLERRM) is wrong which was returning no_data_found
Exception
       When Others Then
       FND_MESSAGE.SET_NAME('PA' ,SQLERRM);
       APP_EXCEPTION.RAISE_EXCEPTION;*/
END Insert_CHILD_Row;

PROCEDURE Update_CHILD_Row (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_MEMBER_LEVEL            NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_TRACK_AS_LABOR_FLAG     VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_LAST_UPDATE_LOGIN       NUMBER,
                             X_Funds_Control_Level_Code VARCHAR2
                             ) IS
BEGIN

         Update PA_RESOURCE_LIST_MEMBERS
                SET
                    ALIAS = X_ALIAS,
               SORT_ORDER = X_SORT_ORDER,
             DISPLAY_FLAG = X_DISPLAY_FLAG,
             ENABLED_FLAG = X_ENABLED_FLAG,
       TRACK_AS_LABOR_FLAG = X_TRACK_AS_LABOR_FLAG,
       LAST_UPDATED_BY    = X_LAST_UPDATED_BY,
       LAST_UPDATE_DATE   = X_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN   = X_LAST_UPDATE_LOGIN,
      Funds_Control_Level_Code = X_Funds_Control_Level_Code
  Where ROWID   = X_ROW_ID;
  If SQL%NOTFOUND Then
     Raise NO_DATA_FOUND;
  End If;
END Update_CHILD_row;

Procedure Lock_CHILD_Row   (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_RESOURCE_ID             NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_Funds_Control_Level_Code VARCHAR2
                            ) IS
CURSOR C Is
    Select * From PA_RESOURCE_LIST_MEMBERS WHERE ROWID = X_ROW_ID
    For Update of RESOURCE_LIST_MEMBER_ID NOWAIT;
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
   IF (
        (X_RESOURCE_LIST_MEMBER_ID = Recinfo.RESOURCE_LIST_MEMBER_ID) And
        (X_RESOURCE_ID             = Recinfo.RESOURCE_ID) And
        ((X_ALIAS                  = Recinfo.ALIAS) OR
        (Recinfo.ALIAS Is Null))  AND
        (X_SORT_ORDER              = Recinfo.SORT_ORDER ) AND
        (X_DISPLAY_FLAG            = Recinfo.DISPLAY_FLAG ) AND
        (X_ENABLED_FLAG            = Recinfo.ENABLED_FLAG)  AND
        ( (Recinfo.Funds_Control_Level_Code =  X_Funds_Control_Level_Code)
                OR ( (Recinfo.Funds_Control_Level_Code IS NULL)
                      AND (X_Funds_Control_Level_Code IS NULL)  )
        )

      ) Then
         Return;
   Else
         FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
         APP_EXCEPTION.RAISE_EXCEPTION;
   END If;

End Lock_CHILD_Row;

Procedure Delete_CHILD_Row (X_ROW_ID IN VARCHAR2) Is
Begin
   Delete from PA_RESOURCE_LIST_MEMBERS Where RowId = X_Row_Id;
If SQL%NOTFOUND Then
   Raise NO_DATA_FOUND;
End If;
End Delete_Child_Row;

/* This procedure is added for bug 1889671. This is part of Resource Mapping Enhancement.
This procedure will delete the unclassified resource list member if all the children for
parent is deleted */

Procedure Delete_Unclassified_Child (x_resource_list_id IN
                                          PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_ID%TYPE,
                                     x_parent_member_id IN
                                          PA_RESOURCE_LIST_MEMBERS.Parent_Member_ID%TYPE,
                                     X_msg_Count  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     X_msg_Data   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     X_return_Status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    ) IS


CURSOR Cur_Child_Count IS
SELECT count(*)
FROM pa_resource_list_members PRLM
WHERE prlm.Parent_member_id=x_parent_member_id
AND   NVL(prlm.resource_type_code,'xyz') <> 'UNCLASSIFIED';


l_count  NUMBER;
x_err_code NUMBER;
x_err_stage VARCHAR2(100);
l_resource_id  pa_resource_list_members.resource_id%TYPE;
l_group_resource_type_id pa_resource_lists_all_bg.group_resource_type_id%TYPE;
l_resource_list_member_id  pa_resource_list_members.resource_list_member_id%TYPE;

Begin

/* In case when resource list is not grouped then  this procedure will not get called.To check this
condition, we are checking that there is non zero value for group_resource_type_id for resource list id in table  */

 SELECT Group_Resource_Type_ID
 INTO  l_group_resource_type_id
 FROM  PA_RESOURCE_LISTS_ALL_BG
 WHERE resource_list_id = x_resource_list_id;

 If SQL%NOTFOUND Then
   Raise NO_DATA_FOUND;
 End If;

 IF L_group_Resource_type_ID = 0 THEN
    Return;
 END IF;

 OPEN cur_child_count;
 Fetch Cur_Child_Count Into l_count;

/*IF the number of children for resource parent is zero, delete the unclassified list member also.*/
 If L_count = 0 THEN

    Delete pa_resource_list_members prlm
    WHere prlm.parent_member_id=x_parent_member_id
    AND   resource_type_code = 'UNCLASSIFIED';

 END IF;
 Close Cur_Child_Count;


/*Commenting the exception block for the bug 3355209 since the usage is wrong
EXCEPTION
When Others Then

  --FND_MESSAGE.SET_NAME('PA' ,SQLERRM);
  APP_EXCEPTION.RAISE_EXCEPTION;*/

end DELETE_UNCLASSIFIED_CHILD;

End  PA_Resource_List_Pkg;

/
