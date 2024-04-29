--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_ROLES_PVT" AS
 /* $Header: PARPRPVB.pls 120.1 2005/08/19 16:59:35 mwasowic noship $ */

procedure INSERT_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_PROJECT_ROLE_TYPE            IN         VARCHAR2,
 X_MEANING                      IN         VARCHAR2,
 X_QUERY_LABOR_COST_FLAG        IN         VARCHAR2,
 X_START_DATE_ACTIVE            IN         DATE,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_END_DATE_ACTIVE              IN         DATE,
 X_DESCRIPTION                  IN         VARCHAR2,
 X_DEFAULT_MIN_JOB_LEVEL        IN         NUMBER,
 X_DEFAULT_MAX_JOB_LEVEL        IN         NUMBER,
 X_MENU_ID                      IN         NUMBER,
 X_DEFAULT_JOB_ID               IN         NUMBER,
 X_FREEZE_RULES_FLAG            IN         VARCHAR2,
 X_ATTRIBUTE_CATEGORY           IN         VARCHAR2,
 X_ATTRIBUTE1                   IN         VARCHAR2,
 X_ATTRIBUTE2                   IN         VARCHAR2,
 X_ATTRIBUTE3                   IN         VARCHAR2,
 X_ATTRIBUTE4                   IN         VARCHAR2,
 X_ATTRIBUTE5                   IN         VARCHAR2,
 X_ATTRIBUTE6                   IN         VARCHAR2,
 X_ATTRIBUTE7                   IN         VARCHAR2,
 X_ATTRIBUTE8                   IN         VARCHAR2,
 X_ATTRIBUTE9                   IN         VARCHAR2,
 X_ATTRIBUTE10                  IN         VARCHAR2,
 X_ATTRIBUTE11                  IN         VARCHAR2,
 X_ATTRIBUTE12                  IN         VARCHAR2,
 X_ATTRIBUTE13                  IN         VARCHAR2,
 X_ATTRIBUTE14                  IN         VARCHAR2,
 X_ATTRIBUTE15                  IN         VARCHAR2,
 X_DEFAULT_ACCESS_LEVEL         IN         VARCHAR2,
 X_ROLE_PARTY_CLASS             IN         VARCHAR2 DEFAULT 'PERSON',
 X_STATUS_LEVEL                 IN         VARCHAR2 DEFAULT NULL,
 x_return_status                OUT        NOCOPY varchar2, --File.Sql.39 bug 4440895
 x_msg_count                    out        NOCOPY number, --File.Sql.39 bug 4440895
 x_msg_data                     out        NOCOPY varchar2 --File.Sql.39 bug 4440895
) IS
v_sqlcode varchar2(30);
v_error_message_code varchar2(30);
begin
 FND_MSG_PUB.initialize;
 x_msg_count:=0;
 ----Check if the role name is duplicate
 pa_role_utils.check_dup_role_name(x_meaning,
                                     x_return_status,
                                     v_error_message_code);
if x_return_status =FND_API.G_RET_STS_SUCCESS then

 --- call table handler to insert into the table
 pa_project_role_types_pkg.insert_row(
 X_ROWID                        ,
 X_PROJECT_ROLE_ID              ,
 X_PROJECT_ROLE_TYPE            ,
 X_MEANING                      ,
 X_QUERY_LABOR_COST_FLAG        ,
 NVL(X_START_DATE_ACTIVE, TRUNC(SYSDATE))            ,
 X_LAST_UPDATE_DATE             ,
 X_LAST_UPDATED_BY              ,
 X_CREATION_DATE                ,
 X_CREATED_BY                   ,
 X_LAST_UPDATE_LOGIN            ,
 X_END_DATE_ACTIVE              ,
 X_DESCRIPTION                  ,
 X_DEFAULT_MIN_JOB_LEVEL        ,
 X_DEFAULT_MAX_JOB_LEVEL        ,
 X_MENU_ID                      ,
 X_DEFAULT_JOB_ID               ,
 X_FREEZE_RULES_FLAG            ,
 X_ATTRIBUTE_CATEGORY           ,
 X_ATTRIBUTE1                   ,
 X_ATTRIBUTE2                   ,
 X_ATTRIBUTE3                   ,
 X_ATTRIBUTE4                   ,
 X_ATTRIBUTE5                   ,
 X_ATTRIBUTE6                   ,
 X_ATTRIBUTE7                   ,
 X_ATTRIBUTE8                   ,
 X_ATTRIBUTE9                   ,
 X_ATTRIBUTE10                  ,
 X_ATTRIBUTE11                  ,
 X_ATTRIBUTE12                  ,
 X_ATTRIBUTE13                  ,
 X_ATTRIBUTE14                  ,
 X_ATTRIBUTE15                  ,
 X_DEFAULT_ACCESS_LEVEL         ,
 X_ROLE_PARTY_CLASS             ,
 X_STATUS_LEVEL
);
elsif x_return_status =FND_API.G_RET_STS_ERROR then
      fnd_message.set_name('PA',v_error_message_code);
       fnd_msg_pub.ADD;
      x_msg_count:=x_msg_count+1;

elsif  x_return_status =FND_API.G_RET_STS_UNEXP_ERROR then
       fnd_msg_pub.add_exc_msg
       (p_pkg_name => 'PA_ROLE_UTILS',
        p_procedure_name => 'check_dup_role_name',
        P_ERROR_TEXT =>v_error_message_code);
        x_msg_count:=x_msg_count+1;
end if;

exception
  when others then
    x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
    v_sqlcode:=SQLCODE;
    fnd_msg_pub.add_exc_msg
       (p_pkg_name => 'PA_PROJECT_ROLES_PVT',
        p_procedure_name => 'INSERT_ROW',
        P_ERROR_TEXT =>v_sqlcode);
        x_msg_count:=x_msg_count+1;

end;

procedure LOCK_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_RECORD_VERSION_NUMBER        IN         NUMBER,
 x_return_status                OUT        NOCOPY varchar2, --File.Sql.39 bug 4440895
 x_msg_count                    out        NOCOPY number, --File.Sql.39 bug 4440895
 x_msg_data                     out        NOCOPY varchar2 --File.Sql.39 bug 4440895
 ) IS
v_sqlcode varchar2(30);
begin
 FND_MSG_PUB.initialize;
 x_msg_count:=0;
  -----any validation to be added here ?
  -----call table handler to lock the row
  pa_project_role_types_pkg.lock_row (
                  X_ROWID  ,
                  X_RECORD_VERSION_NUMBER );
x_return_status:=FND_API.G_RET_STS_SUCCESS;
exception
  when others  then
     x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
     v_sqlcode:=SQLCODE;
     fnd_msg_pub.add_exc_msg
       (p_pkg_name => 'PA_PROJECT_ROLES_PVT',
        p_procedure_name => 'LOCK_ROW',
        P_ERROR_TEXT =>v_sqlcode);
        x_msg_count:=x_msg_count+1;
end;

procedure UPDATE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_PROJECT_ROLE_TYPE            IN         VARCHAR2,
 X_MEANING                      IN         VARCHAR2,
 X_QUERY_LABOR_COST_FLAG        IN         VARCHAR2,
 X_START_DATE_ACTIVE            IN         DATE,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_END_DATE_ACTIVE              IN         DATE,
 X_DESCRIPTION                  IN         VARCHAR2,
 X_DEFAULT_MIN_JOB_LEVEL        IN         NUMBER,
 X_DEFAULT_MAX_JOB_LEVEL        IN         NUMBER,
 X_MENU_ID                      IN         NUMBER,
 X_DEFAULT_JOB_ID               IN         NUMBER,
 X_FREEZE_RULES_FLAG            IN         VARCHAR2,
 X_ATTRIBUTE_CATEGORY           IN         VARCHAR2,
 X_ATTRIBUTE1                   IN         VARCHAR2,
 X_ATTRIBUTE2                   IN         VARCHAR2,
 X_ATTRIBUTE3                   IN         VARCHAR2,
 X_ATTRIBUTE4                   IN         VARCHAR2,
 X_ATTRIBUTE5                   IN         VARCHAR2,
 X_ATTRIBUTE6                   IN         VARCHAR2,
 X_ATTRIBUTE7                   IN         VARCHAR2,
 X_ATTRIBUTE8                   IN         VARCHAR2,
 X_ATTRIBUTE9                   IN         VARCHAR2,
 X_ATTRIBUTE10                  IN         VARCHAR2,
 X_ATTRIBUTE11                  IN         VARCHAR2,
 X_ATTRIBUTE12                  IN         VARCHAR2,
 X_ATTRIBUTE13                  IN         VARCHAR2,
 X_ATTRIBUTE14                  IN         VARCHAR2,
 X_ATTRIBUTE15                  IN         VARCHAR2,
 X_DEFAULT_ACCESS_LEVEL         IN         VARCHAR2,
 X_ROLE_PARTY_CLASS             IN         VARCHAR2 DEFAULT 'PERSON',
 X_STATUS_LEVEL                 IN         VARCHAR2 DEFAULT NULL,
 x_return_status                OUT        NOCOPY varchar2, --File.Sql.39 bug 4440895
 x_msg_count                    out        NOCOPY number, --File.Sql.39 bug 4440895
 x_msg_data                     out        NOCOPY varchar2 --File.Sql.39 bug 4440895
) is
v_menu_id number;
v_meaning varchar2(80);
v_created_by NUMBER;
v_error_message_code varchar2(30);
v_sqlcode varchar2(30);

begin
-- hr_utility.trace_on(NULL, 'RMFORM');
-- hr_utility.trace('start');
 FND_MSG_PUB.initialize;
  x_msg_count:=0;
  ---any validation to be added here
 select menu_id, meaning, created_by
  into   v_menu_id, v_meaning, v_created_by
  from pa_project_role_types_vl
  where row_id=x_rowid;
  --dbms_output.put_line('v_menu_id: '||v_menu_id);

  x_return_status:=FND_API.G_RET_STS_SUCCESS;

  --Throwing an error if seeded role
  /* Commented for bug 2661505
  IF v_created_by = 1 THEN
    x_return_status:=FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('PA', 'PA_COMMON_SEEDED_ROLES');
    fnd_msg_pub.ADD;
    x_msg_count:=x_msg_count+1;
    RETURN;
  END IF;
 */

 if v_meaning <>x_meaning then
     pa_role_utils.check_dup_role_name(x_meaning,
                                       x_return_status,
                                       v_error_message_code);
  end if;
--dbms_output.put_line('check1');
If  x_return_status =FND_API.G_RET_STS_SUCCESS then
--dbms_output.put_line('check2');
-- hr_utility.trace('update');
  pa_project_role_types_pkg.update_row(
 X_ROWID                        ,
 X_PROJECT_ROLE_ID              ,
 X_PROJECT_ROLE_TYPE            ,
 X_MEANING                      ,
 X_QUERY_LABOR_COST_FLAG        ,
 X_START_DATE_ACTIVE            ,
 X_LAST_UPDATE_DATE             ,
 X_LAST_UPDATED_BY              ,
 X_CREATION_DATE                ,
 X_CREATED_BY                   ,
 X_LAST_UPDATE_LOGIN            ,
 X_END_DATE_ACTIVE              ,
 X_DESCRIPTION                  ,
 X_DEFAULT_MIN_JOB_LEVEL        ,
 X_DEFAULT_MAX_JOB_LEVEL        ,
 X_MENU_ID                      ,
 X_DEFAULT_JOB_ID               ,
 X_FREEZE_RULES_FLAG            ,
 X_ATTRIBUTE_CATEGORY           ,
 X_ATTRIBUTE1                   ,
 X_ATTRIBUTE2                   ,
 X_ATTRIBUTE3                   ,
 X_ATTRIBUTE4                   ,
 X_ATTRIBUTE5                   ,
 X_ATTRIBUTE6                   ,
 X_ATTRIBUTE7                   ,
 X_ATTRIBUTE8                   ,
 X_ATTRIBUTE9                   ,
 X_ATTRIBUTE10                  ,
 X_ATTRIBUTE11                  ,
 X_ATTRIBUTE12                  ,
 X_ATTRIBUTE13                  ,
 X_ATTRIBUTE14                  ,
 X_ATTRIBUTE15                  ,
 X_DEFAULT_ACCESS_LEVEL         ,
 X_ROLE_PARTY_CLASS             ,
 X_STATUS_LEVEL
) ;
-- hr_utility.trace('end update');
--dbms_output.put_line('check3');
   ---If the menu_id changes,then update menu_id in fnd_grants
   if (v_menu_id is not null and x_menu_id is not null and v_menu_id<> x_menu_id ) then
-- hr_utility.trace('menu update');
      pa_role_utils.update_menu_in_grants(x_project_role_id,
                                        x_menu_id,
                                        x_return_status,
                                        v_error_message_code);
      if x_return_status=FND_API.G_RET_STS_ERROR then
            fnd_message.set_name('PA',v_error_message_code);
            fnd_msg_pub.ADD;
            x_msg_count:=x_msg_count+1;
            return;
      elsif  x_return_status =FND_API.G_RET_STS_UNEXP_ERROR then
            fnd_msg_pub.add_exc_msg
            (p_pkg_name => 'PA_ROLE_UTILS',
            p_procedure_name => 'update_menu_in_grants',
            P_ERROR_TEXT =>v_error_message_code);
            x_msg_count:=x_msg_count+1;
            return;
      end if;
   ----if role based security is disabled, remove records from fnd_grants
   elsif v_menu_id is not null and x_menu_id is null then
       pa_role_utils.disable_role_based_sec(x_project_role_id,
                                            x_return_status,
                                            v_error_message_code) ;
       if x_return_status=FND_API.G_RET_STS_ERROR then
            fnd_message.set_name('PA',v_error_message_code);
            fnd_msg_pub.ADD;
            x_msg_count:=x_msg_count+1;
            return;
      elsif  x_return_status =FND_API.G_RET_STS_UNEXP_ERROR then
            fnd_msg_pub.add_exc_msg
            (p_pkg_name => 'PA_ROLE_UTILS',
            p_procedure_name => 'disable_role_based_sec',
            P_ERROR_TEXT =>v_error_message_code);
            x_msg_count:=x_msg_count+1;
            return;
      end if;
    -----if role based security is enabled, insert records into fnd_grants
   elsif v_menu_id is null and x_menu_id is not null then
-- hr_utility.trace('enable menu update');
          pa_role_utils.Enable_role_based_sec(x_project_role_id,
                                            x_return_status,
                                            v_error_message_code) ;
-- hr_utility.trace('x_return_status is ' || x_return_status);
-- hr_utility.trace('v_error_message_code is ' || v_error_message_code);
-- hr_utility.trace('after enable menu update');
          if x_return_status=FND_API.G_RET_STS_ERROR then
            fnd_message.set_name('PA',v_error_message_code);
            fnd_msg_pub.ADD;
            x_msg_count:=x_msg_count+1;
-- hr_utility.trace('The end');
            return;
         elsif  x_return_status =FND_API.G_RET_STS_UNEXP_ERROR then
            fnd_msg_pub.add_exc_msg
            (p_pkg_name => 'PA_ROLE_UTILS',
            p_procedure_name => 'Enable_role_based_sec',
            P_ERROR_TEXT =>v_error_message_code);
            x_msg_count:=x_msg_count+1;
            return;
        end if;
  end if;

elsif  x_return_status =FND_API.G_RET_STS_ERROR then
     fnd_message.set_name('PA',v_error_message_code);
     fnd_msg_pub.ADD;
     x_msg_count:=x_msg_count+1;
elsif  x_return_status =FND_API.G_RET_STS_UNEXP_ERROR then
       fnd_msg_pub.add_exc_msg
       (p_pkg_name => 'PA_ROLE_UTILS',
        p_procedure_name => 'check_dup_role_name',
        P_ERROR_TEXT =>v_error_message_code);
        x_msg_count:=x_msg_count+1;
end if;

exception
  when others then
--dbms_output.put_line('check4');
     x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
     v_sqlcode:=SQLCODE;
      fnd_msg_pub.add_exc_msg
       (p_pkg_name => 'PA_PROJECT_ROLES_PVT',
        p_procedure_name => 'UPDATE_ROW',
        P_ERROR_TEXT =>v_sqlcode);
        x_msg_count:=x_msg_count+1;
end;


procedure DELETE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 X_ROWID in varchar2,
 x_return_status                OUT        NOCOPY varchar2, --File.Sql.39 bug 4440895
 x_msg_count                    out        NOCOPY number, --File.Sql.39 bug 4440895
 x_msg_data                     out        NOCOPY varchar2 --File.Sql.39 bug 4440895
) is
 v_role_id  number;
 v_created_by NUMBER;
 v_error_message_code varchar2(30);
 v_sqlcode varchar2(30);
begin
  FND_MSG_PUB.initialize;
  x_msg_count:=0;
--validate if the role can be deleted or not
  select project_role_id, created_by
  into v_role_id, v_created_by
  from pa_project_role_types_vl
  where row_id=X_ROWID;

  --Throwing an error if seeded role
  IF v_created_by = 1 THEN
    x_return_status:=FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('PA', 'PA_COMMON_SEEDED_ROLES');
    fnd_msg_pub.ADD;
    x_msg_count:=x_msg_count+1;
    RETURN;
  END IF;

--dbms_output.put_line('v_role_id: '||v_role_id);
  pa_role_utils.check_delete_role_ok(v_role_id,
                                     x_return_status,
                                     v_error_message_code);
--dbms_output.put_line('x_return_status: '||x_return_status);

 if x_return_status =FND_API.G_RET_STS_SUCCESS then
     ----call the table handler to delete roles
     pa_project_role_types_pkg.delete_row(X_ROWID);
--dbms_output.put_line('called delete_row');

      delete from pa_role_controls
      where project_role_id=v_role_id;
--dbms_output.put_line('delete controls');

     delete from pa_role_list_members
     where project_role_id=v_role_id;
--dbms_output.put_line('delete list mem');

     OKE_K_ACCESS_RULES_PKG.delete_all(v_role_id);
--dbms_output.put_line('called delete_all');

     delete from per_competence_elements
     where OBJECT_ID=v_role_id
     and  OBJECT_NAME='PROJECT_ROLE';
--dbms_output.put_line('delete competence ele');

  elsif x_return_status =FND_API.G_RET_STS_ERROR then
      fnd_message.set_name('PA',v_error_message_code);
       fnd_msg_pub.ADD;
      x_msg_count:=x_msg_count+1;
  elsif  x_return_status =FND_API.G_RET_STS_UNEXP_ERROR then
       fnd_msg_pub.add_exc_msg
       (p_pkg_name => 'PA_ROLE_UTILS',
        p_procedure_name => 'check_delete_role_ok',
        P_ERROR_TEXT =>v_error_message_code);
        x_msg_count:=x_msg_count+1;
 end if;
exception
  when others then
       x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       v_sqlcode:=SQLCODE;
       fnd_msg_pub.add_exc_msg
       (p_pkg_name => 'PA_PROJECT_ROLES_PVT',
        p_procedure_name => 'DELETE_ROW',
        P_ERROR_TEXT =>v_sqlcode);
        x_msg_count:=x_msg_count+1;

end;
end PA_PROJECT_ROLES_PVT;

/
