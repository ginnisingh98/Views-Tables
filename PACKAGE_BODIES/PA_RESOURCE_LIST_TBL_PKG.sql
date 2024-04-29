--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_LIST_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_LIST_TBL_PKG" AS
/* $Header: PARELSTB.pls 120.1 2005/08/19 16:50:21 mwasowic noship $ */
-- Standard Table Handler procedures for PA_RESOURCE_LISTS table

--      History:
--
--      16-MAR-2004     smullapp                created
-------------------------------------------------------------------
PROCEDURE Insert_Row(
			p_name                     PA_RESOURCE_LISTS_ALL_BG.name%TYPE,
                        p_description              PA_RESOURCE_LISTS_ALL_BG.description%TYPE,
                        p_public_flag              PA_RESOURCE_LISTS_ALL_BG.public_flag%TYPE,
                        p_group_resource_type_id   NUMBER,
                        p_start_date_active        DATE,
                        p_end_date_active          DATE,
                        p_uncategorized_flag       PA_RESOURCE_LISTS_ALL_BG.uncategorized_flag%TYPE,
                        p_business_group_id        NUMBER,
                        p_adw_notify_flag          PA_RESOURCE_LISTS_ALL_BG.adw_notify_flag%TYPE,
                        p_job_group_id             NUMBER,
                        p_resource_list_type       PA_RESOURCE_LISTS_ALL_BG.resource_list_type%TYPE,
                        p_control_flag             PA_RESOURCE_LISTS_ALL_BG.control_flag%TYPE,
                        p_use_for_wp_flag          PA_RESOURCE_LISTS_ALL_BG.use_for_wp_flag%TYPE,
                        p_migration_code           PA_RESOURCE_LISTS_ALL_BG.migration_code%TYPE,
                        x_resource_list_id  OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_return_status     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_msg_data	    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 )
IS

        l_row_id        VARCHAR2(100);

	--This cursor selects rowid from pa_resource_lists_all_bg
        CURSOR c_res_cur IS
        SELECT
        Rowid
        FROM
        pa_resource_lists_all_bg
        WHERE resource_list_id   =  x_resource_list_id;

	--This sets the value for resource_list_id of pa_resource_lists_all_bg fro pa_resource_lists_s sequence
	CURSOR  c_res_list_seq_csr IS
        SELECT pa_resource_lists_s.NEXTVAL
        FROM
        SYS.DUAL;

BEGIN

	x_return_status:='S';

	OPEN  c_res_list_seq_csr;
        FETCH c_res_list_seq_csr INTO  X_RESOURCE_LIST_ID;
        CLOSE c_res_list_seq_csr;


	--Inserts a record into pa_resource_lists_all_bg
        Insert Into PA_RESOURCE_LISTS_ALL_BG
	    (
                                  RESOURCE_LIST_ID,
                                  NAME,
                                  DESCRIPTION,
                                  PUBLIC_FLAG,
                                  GROUP_RESOURCE_TYPE_ID,
                                  START_DATE_ACTIVE,
                                  END_DATE_ACTIVE,
                                  UNCATEGORIZED_FLAG,
                                  BUSINESS_GROUP_ID,
                                  ADW_NOTIFY_FLAG,
                                  JOB_GROUP_ID,
                                  RESOURCE_LIST_TYPE,
                                  CONTROL_FLAG,
                                  USE_FOR_WP_FLAG,
                                  MIGRATION_CODE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_DATE,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  LAST_UPDATE_LOGIN,
                                  RECORD_VERSION_NUMBER
                                )
                VALUES(
                                X_RESOURCE_LIST_ID,
                                P_NAME,
                                P_DESCRIPTION,
                                P_PUBLIC_FLAG,
                                P_GROUP_RESOURCE_TYPE_ID,
                                P_START_DATE_ACTIVE,
                                P_END_DATE_ACTIVE,
                                P_UNCATEGORIZED_FLAG,
                                P_BUSINESS_GROUP_ID,
                                P_ADW_NOTIFY_FLAG,
                                P_JOB_GROUP_ID,
                                P_RESOURCE_LIST_TYPE,
                                P_CONTROL_FLAG,
                                P_USE_FOR_WP_FLAG,
                                P_MIGRATION_CODE,
                                FND_GLOBAL.USER_ID,
				SYSDATE,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                FND_GLOBAL.LOGIN_ID,
                                1
                        );

	--Checks for failure of Insert stmt
        OPEN c_res_cur;
        FETCH c_res_cur INTO l_row_id;
        IF(c_res_cur%NOTFOUND) THEN
                CLOSE c_res_cur;
                Raise NO_DATA_FOUND;
        END IF;
        CLOSE c_res_cur;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status:='U';
		x_msg_data:=sqlerrm;
		RAISE;

END Insert_Row;


PROCEDURE Insert_row        (X_ROW_ID IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_NAME                    VARCHAR2,
                             X_DESCRIPTION             VARCHAR2,
                             X_PUBLIC_FLAG             VARCHAR2,
                             X_GROUP_RESOURCE_TYPE_ID  NUMBER,
                             X_START_DATE_ACTIVE       DATE,
                             X_END_DATE_ACTIVE         DATE,
                             X_UNCATEGORIZED_FLAG      VARCHAR2,
                             X_BUSINESS_GROUP_ID       NUMBER,
--                             X_ADW_NOTIFY_FLAG         VARCHAR2,
                             X_JOB_GROUP_ID            NUMBER,
                             X_RESOURCE_LIST_TYPE      VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_CREATION_DATE           DATE,
                             X_CREATED_BY              NUMBER,
                             X_LAST_UPDATE_LOGIN       NUMBER ) IS
CURSOR RES_CUR IS
Select
Rowid
from
PA_RESOURCE_LISTS_ALL_BG
Where Resource_List_Id   =  X_Resource_List_Id;
BEGIN
  Insert Into PA_RESOURCE_LISTS_ALL_BG
                            (
                             RESOURCE_LIST_ID,
                             NAME         ,
                             DESCRIPTION  ,
                             PUBLIC_FLAG ,
                             GROUP_RESOURCE_TYPE_ID  ,
                             START_DATE_ACTIVE     ,
                             END_DATE_ACTIVE      ,
                             UNCATEGORIZED_FLAG  ,
                             BUSINESS_GROUP_ID  ,
                             --ADW_NOTIFY_FLAG   ,
                             JOB_GROUP_ID     ,
                             RESOURCE_LIST_TYPE,
                             LAST_UPDATED_BY ,
                             LAST_UPDATE_DATE,
                             CREATION_DATE ,
                             CREATED_BY   ,
                             LAST_UPDATE_LOGIN,
                             CONTROL_FLAG,
                             USE_FOR_WP_FLAG,
                             MIGRATION_CODE
                             )
                             VALUES
                             (
                             X_RESOURCE_LIST_ID,
                             X_NAME         ,
                             X_DESCRIPTION  ,
                             X_PUBLIC_FLAG ,
                             X_GROUP_RESOURCE_TYPE_ID  ,
                             X_START_DATE_ACTIVE     ,
                             X_END_DATE_ACTIVE      ,
                             X_UNCATEGORIZED_FLAG  ,
                             X_BUSINESS_GROUP_ID  ,
                            -- X_ADW_NOTIFY_FLAG   ,
                             X_JOB_GROUP_ID     ,
                             X_RESOURCE_LIST_TYPE,
                             X_LAST_UPDATED_BY ,
                             X_LAST_UPDATE_DATE,
                             X_CREATION_DATE ,
                             X_CREATED_BY   ,
                             X_LAST_UPDATE_LOGIN,
                             'Y',
                             'N', -- open issue
                             NULL);

      insert into pa_resource_lists_tl (
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         RESOURCE_LIST_ID,
         NAME,
         DESCRIPTION,
         LANGUAGE,
         SOURCE_LANG
  ) select
    FND_GLOBAL.LOGIN_ID,
    sysdate,
    FND_GLOBAL.USER_ID,
    sysdate,
    FND_GLOBAL.USER_ID,
    X_RESOURCE_LIST_ID,
    X_NAME,
    NVL(X_DESCRIPTION,X_NAME),
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from pa_resource_lists_tl T
    where T.RESOURCE_LIST_ID = X_RESOURCE_LIST_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

       Open  Res_Cur;
       Fetch Res_Cur Into X_Row_Id;
       If (Res_Cur%NOTFOUND)  then
           Close Res_Cur;
           Raise NO_DATA_FOUND;
        End If;
       Close Res_Cur;
 /*Commenting the exception block for the bug 3355209 since it is again standards
Exception
       When Others Then
        Bug2510641 Begin
       --       FND_MESSAGE.SET_NAME('PA' ,SQLERRM);
       FND_MESSAGE.SET_NAME('PA' ,'PA_UNEXPECTED_ERROR_WTH_TKNS');
       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','PA_Resource_List_tbl_Pkg');
       FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','Insert_Row');
       FND_MESSAGE.SET_TOKEN('ERROR_TEXT ',SQLERRM);
        Bug2510641 End
       APP_EXCEPTION.RAISE_EXCEPTION;*/
END Insert_Row;

PROCEDURE Update_Row        (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_NAME                    VARCHAR2,
                             X_DESCRIPTION             VARCHAR2,
                             X_PUBLIC_FLAG             VARCHAR2,
                             X_GROUP_RESOURCE_TYPE_ID  NUMBER,
                             X_START_DATE_ACTIVE       DATE,
                             X_END_DATE_ACTIVE         DATE,
                             X_UNCATEGORIZED_FLAG      VARCHAR2,
                             X_BUSINESS_GROUP_ID       NUMBER,
                         --    X_ADW_NOTIFY_FLAG         VARCHAR2,
                             X_JOB_GROUP_ID            NUMBER,
                             X_RESOURCE_LIST_TYPE      VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_LAST_UPDATE_LOGIN       NUMBER ) IS
BEGIN

         Update PA_RESOURCE_LISTS_ALL_BG
         SET
             -- For bug 4202015
             -- RESOURCE_LIST_ID        =   X_RESOURCE_LIST_ID       ,
                NAME                    =   X_NAME                   ,
                DESCRIPTION             =   X_DESCRIPTION            ,
                PUBLIC_FLAG             =   X_PUBLIC_FLAG            ,
                GROUP_RESOURCE_TYPE_ID  =   X_GROUP_RESOURCE_TYPE_ID ,
                START_DATE_ACTIVE       =   X_START_DATE_ACTIVE      ,
                END_DATE_ACTIVE         =   X_END_DATE_ACTIVE        ,
                UNCATEGORIZED_FLAG      =   X_UNCATEGORIZED_FLAG     ,
                BUSINESS_GROUP_ID       =   X_BUSINESS_GROUP_ID      ,
             -- ADW_NOTIFY_FLAG         =   X_ADW_NOTIFY_FLAG        ,
                JOB_GROUP_ID            =   X_JOB_GROUP_ID           ,
                RESOURCE_LIST_TYPE      =   X_RESOURCE_LIST_TYPE     ,
                LAST_UPDATED_BY         =   X_LAST_UPDATED_BY        ,
                LAST_UPDATE_DATE        =   X_LAST_UPDATE_DATE       ,
                LAST_UPDATE_LOGIN       =   X_LAST_UPDATE_LOGIN
         WHERE  RESOURCE_LIST_ID        =   X_RESOURCE_LIST_ID;

  If SQL%NOTFOUND Then
     Raise NO_DATA_FOUND;
  End If;

  update pa_resource_lists_tl set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = fnd_global.user_id,
    LAST_UPDATE_LOGIN = fnd_global.login_id,
    SOURCE_LANG = userenv('LANG')
  where resource_list_id = X_RESOURCE_LIST_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

END Update_row;

Procedure Lock_Row          (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_NAME                    VARCHAR2,
                             X_DESCRIPTION             VARCHAR2,
                             X_PUBLIC_FLAG             VARCHAR2,
                             X_GROUP_RESOURCE_TYPE_ID  NUMBER,
                             X_START_DATE_ACTIVE       DATE,
                             X_END_DATE_ACTIVE         DATE,
                             X_UNCATEGORIZED_FLAG      VARCHAR2,
                             X_BUSINESS_GROUP_ID       NUMBER,
                             X_JOB_GROUP_ID		       NUMBER,
                         --    X_ADW_NOTIFY_FLAG         VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER) IS

CURSOR C Is
    Select * From PA_RESOURCE_LISTS_ALL_BG WHERE ROWID = X_ROW_ID
    For Update of RESOURCE_LIST_ID NOWAIT;
    Recinfo C%ROWTYPE;
Begin
--hr_utility.trace_on(NULL, 'RMUPG');
--hr_utility.trace('X_ROW_ID is ' || X_ROW_ID);
--hr_utility.trace('X_RESOURCE_LIST_ID is ' || X_RESOURCE_LIST_ID);
--hr_utility.trace('X_NAME is ' || X_NAME);
--hr_utility.trace('X_DESCRIPTION is ' || X_DESCRIPTION);
--hr_utility.trace('X_PUBLIC_FLAG is ' || X_PUBLIC_FLAG);
--hr_utility.trace('X_GROUP_RESOURCE_TYPE_ID is ' || X_GROUP_RESOURCE_TYPE_ID);
--hr_utility.trace('X_START_DATE_ACTIVE is ' || X_START_DATE_ACTIVE);
--hr_utility.trace('X_END_DATE_ACTIVE is ' || X_END_DATE_ACTIVE);
--hr_utility.trace('X_UNCATEGORIZED_FLAG is ' || X_UNCATEGORIZED_FLAG);
--hr_utility.trace('X_BUSINESS_GROUP_ID is ' || X_BUSINESS_GROUP_ID);

    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) THEN
--hr_utility.trace('NOT FOUND');
       Close C;
       FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END If;
   CLOSE C;
   IF (
         (X_RESOURCE_LIST_ID       = recinfo.resource_list_id) And
         ((X_NAME                   = recinfo.name) or
            (( X_NAME is null ) and ( recinfo.name is null)))  And
         ((X_PUBLIC_FLAG           = recinfo.public_flag) or
            (( X_PUBLIC_FLAG is null ) and ( recinfo.public_flag is null)))  And
         ((X_GROUP_RESOURCE_TYPE_ID   = recinfo.group_resource_type_id) or
            (( X_GROUP_RESOURCE_TYPE_ID is null ) and
              ( recinfo.group_resource_type_id is null)))  And
         (X_START_DATE_ACTIVE       = recinfo.start_date_active ) And
         ((X_END_DATE_ACTIVE        = recinfo.end_date_active) or
            (( X_END_DATE_ACTIVE is null ) and
               ( recinfo.end_date_active is null)))  And
         ((X_UNCATEGORIZED_FLAG       = recinfo.uncategorized_flag) or
            (( X_UNCATEGORIZED_FLAG is null ) and
              ( recinfo.uncategorized_flag is null)))  And
         (X_BUSINESS_GROUP_ID      = recinfo.business_group_id)  and
         ((X_JOB_GROUP_ID       = recinfo.job_group_id) or
            (( X_job_group_id is null ) and
              ( recinfo.job_group_id is null)))
    ) Then
         Return;
   Else
--hr_utility.trace('ELSE IF');
         FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
         APP_EXCEPTION.RAISE_EXCEPTION;
   END If;

End Lock_Row;

Procedure Delete_Row (X_ROW_ID IN VARCHAR2) Is
Begin

delete from pa_resource_lists_tl
where resource_list_id in (select resource_list_id
                             from PA_RESOURCE_LISTS_ALL_BG
                            Where RowId = X_Row_Id);

   Delete from PA_RESOURCE_LISTS_ALL_BG Where RowId = X_Row_Id;
If SQL%NOTFOUND Then
   Raise NO_DATA_FOUND;
End If;

End Delete_Row;

End  PA_Resource_List_tbl_Pkg;

/
