--------------------------------------------------------
--  DDL for Package Body IEU_WORK_SOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WORK_SOURCE_PVT" AS
/* $Header: IEUWSAB.pls 120.0 2005/06/02 15:42:08 appldev noship $ */


--===================================================================
-- NAME
--   CREATE_action_map
--
-- PURPOSE
--    Private api to create action map
--
-- NOTES
--    1. UWQ Admin will use this procedure to create action map
--
--
-- HISTORY
--   8-may-2002     dolee   Created
--   14-Aug-2003    gpagadal updated

--===================================================================


PROCEDURE loadWorkSource(x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                            p_ws_id  IN varchar2,
                             p_ws_type IN VARCHAR2,
                             p_ws_name IN  VARCHAR2,
                             p_ws_code   IN VARCHAR2,
                             p_ws_desc   IN  VARCHAR2,
                             p_ws_parent_id   IN   number,
                             p_ws_child_id     IN  number,
                             p_ws_dis_from   IN    VARCHAR2,
                             p_ws_dis_to     IN    VARCHAR2,
                             p_ws_dis_func  IN VARCHAR2,
                             p_ws_object_code  IN  VARCHAR2,
                             p_ws_application_id IN varchar2,
                             p_ws_not_valid_flag IN VARCHAR2,
                             p_ws_dis_parent_flag IN VARCHAR2,
                             p_ws_profile_id     IN varchar2,
                             p_ws_profile IN varchar2,
                             p_sqlValidation IN varchar2,
					    p_ws_task_rule_func  IN varchar2,
                              r_mode  IN VARCHAR2
) AS

    l_action_map_id     NUMBER(15);
    sql_stmt   varchar2(2000);
    l_count  number:=0;
    l_language ieu_uwqm_work_sources_tl.language%type;
    x_rowid varchar2(20000);

  l_ws_id  number;
  l_ws_assoc_prop_id  number;
  l_profile_id number;
  l_applId  NUMBER :=696;
  l_yes VARCHAR2(1);
  l_no VARCHAR2(1);
  l_end VARCHAR2(200) := null;
  l_temp_date VARCHAR2(15);
  l_appl_short_name  varchar2(15);
  l_ws_not_valid_flag varchar2(1);
  l_deactive_time Date;


BEGIN
  l_yes := 'Y';
  l_no := 'N';
  l_ws_not_valid_flag := 'Y';
  l_deactive_time := sysdate-1;
  fnd_msg_pub.delete_msg();
  x_return_status := fnd_api.g_ret_sts_success;
  FND_MSG_PUB.initialize;
  x_msg_data := '';
  select to_char(sysdate, 'yyyy/mm/dd') into l_temp_date from dual;
  l_language := FND_GLOBAL.CURRENT_LANGUAGE;
  -- for update description and dis function for not active case,
  -- do not check ws  object code
  -- check ws object code only when deactive -> active
  if (r_mode = 'update' ) then
   EXECUTE IMMEDIATE 'select not_valid_flag from ieu_uwqm_work_sources_b '||
   ' where ws_id =:1'
   into l_ws_not_valid_flag
   using p_ws_id;
  end if;

   if (r_mode = 'create' or (l_ws_not_valid_flag = 'Y' and p_ws_not_valid_flag = 'N')) then
    validateObj(x_return_status, x_msg_count, x_msg_data, p_ws_name,p_ws_code, p_ws_parent_id, p_ws_child_id, r_mode);
   end if;
    IF (x_return_status = 'S') then
  --x_msg_data := x_msg_data || 'validate is ok, dis function is '||p_ws_dis_func||', not_valid_flag is '||
   --           p_ws_not_valid_flag||', p_ws_id is '|| p_ws_id||' user_id is '|| fnd_global.user_id ||
    --          ' login id is '|| fnd_global.login_id || ', profile id is '||p_ws_profile_id||',profile is '||
     --         p_ws_profile||' p_sqlValidation is '||p_sqlValidation;

   IF (r_mode = 'update') then
   IEU_UWQM_WORK_SOURCES_PKG.update_row(
                        p_ws_id,
                        p_ws_type,
                        p_ws_dis_to,
                        p_ws_dis_from,
                        p_ws_dis_func,
                        p_ws_not_valid_flag,
                        p_ws_object_code,
                        p_ws_name,
                        p_ws_desc,
                        p_ws_profile_id,
                        p_ws_application_id);

   IF (p_ws_type = 'ASSOCIATION') then
      EXECUTE IMMEDIATE 'select ws_association_prop_id from ieu_uwqm_ws_assct_props '||
   ' where  parent_ws_id = :1 and child_ws_id = :2 and ws_id = :3'
   into l_ws_assoc_prop_id
   USING p_ws_parent_id, p_ws_child_id, p_ws_id;

   IEU_UWQM_WS_ASSCT_PROPS_PKG.update_row(
          p_ws_association_prop_id =>l_ws_assoc_prop_id,
          p_parent_ws_id => p_ws_parent_id,
          p_child_ws_id =>p_ws_child_id ,
          p_dist_st_based_on_parent_flag => p_ws_dis_parent_flag,
          p_ws_id => p_ws_id,
          p_tasks_rules_function => p_ws_task_rule_func);
   END if;

   -- when active or deactive, modified the end_active_date for profile_options
   if (l_ws_not_valid_flag = 'N' and p_ws_not_valid_flag = 'Y') then
      sql_stmt := 'update FND_PROFILE_OPTIONS ' ||
                    ' set end_date_active= :1 '||
                    ' , last_updated_by =  :2 '||
                    ' , last_update_login = :3 '||
                    ', last_update_date = :4 '||
                    ' where profile_option_name = :5 ';
   EXECUTE IMMEDIATE sql_stmt
   USING l_deactive_time,fnd_global.user_id,fnd_global.login_id,sysdate, p_ws_profile_id;
  ELSE IF (l_ws_not_valid_flag = 'Y' and p_ws_not_valid_flag = 'N') then
      sql_stmt := 'update FND_PROFILE_OPTIONS ' ||
                    ' set end_date_active= :1 '||
                    ' , last_updated_by =  :2 '||
                    ' , last_update_login = :3 '||
                    ', last_update_date = :4 '||
                    ' where profile_option_name = :5 ';
   EXECUTE IMMEDIATE sql_stmt
   USING l_end,fnd_global.user_id,fnd_global.login_id,sysdate, p_ws_profile_id;
   END if;--active
  end if;--deactive

   else-- create case
      EXECUTE IMMEDIATE 'select application_short_name from fnd_application where application_id = :1 '
   into l_appl_short_name
   using p_ws_application_id;

   -- a. update/insert fnd_profile_options and fnd_profile_options_tl
  FND_PROFILE_OPTIONS_PKG.LOAD_ROW (
    x_profile_name    =>  p_ws_profile_id ,
    x_owner        => fnd_global.user_id,
    x_application_short_name  => l_appl_short_name,
    x_user_profile_option_name  =>p_ws_profile,
    x_description           => null,
    x_user_changeable_flag => l_no,
    x_user_visible_flag    => l_no,
    x_read_allowed_flag    => l_yes,
    x_write_allowed_flag   => l_yes,
    x_site_enabled_flag   => l_yes,
    x_site_update_allowed_flag => l_yes,
    x_app_enabled_flag    =>  l_yes,
    x_app_update_allowed_flag =>  l_yes,
    x_resp_enabled_flag  =>   l_yes,
    x_resp_update_allowed_flag  => l_yes,
    x_user_enabled_flag     => l_yes,
    x_user_update_allowed_flag => l_yes,
    x_start_date_active    => l_temp_date,
    x_end_date_active       => null,
  x_sql_validation     => p_sqlValidation);

    -- b. insert ieu_uwqm_work_sources_b and tl
   select IEU_UWQM_WORK_SOURCES_B_S1.NEXTVAL into l_ws_id from sys.dual;
   IEU_UWQM_WORK_SOURCES_PKG.load_row(
                        l_ws_id,
                        p_ws_type,
                        p_ws_dis_to,
                        p_ws_dis_from,
                        p_ws_dis_func,
                        p_ws_not_valid_flag,
                        p_ws_object_code,
                        p_ws_name,
                        p_ws_desc,
                        'ORACLE',
                        p_ws_code,
                        p_ws_profile_id,
                        p_ws_application_id,
				    'N');


    -- c. if this is association type, insert ieu_uwqm_ws_assct_props
    IF (p_ws_parent_id <> '0') then
      select IEU_UWQM_WS_ASSCT_PROPS_S1.NEXTVAL into l_ws_assoc_prop_id from sys.dual;

      IEU_UWQM_WS_ASSCT_PROPS_PKG.insert_row(
          x_rowid => x_rowid,
          p_ws_association_prop_id =>l_ws_assoc_prop_id,
          p_parent_ws_id => p_ws_parent_id,
          p_child_ws_id =>p_ws_child_id ,
          p_dist_st_based_on_parent_flag => p_ws_dis_parent_flag,
          p_ws_id => l_ws_id,
          p_tasks_rules_function => p_ws_task_rule_func);


   END IF ;-- props table

   END if;
   else
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count := x_msg_count+1;
            x_msg_data := x_msg_data||'IEU_PROV_WS_CREATE_ERROR$';
   END if;
   commit;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;
               x_msg_data := x_msg_data || ' , fnd_api.g_exc_error.';


        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
           x_msg_data := x_msg_data || ' , fnd_api.g_exc_unexpected_error.';

        WHEN no_data_found THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
           x_msg_data := x_msg_data || ' , no_data_found.';


        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
           x_msg_data := x_msg_data || ' , others.'|| sqlerrm;

END loadWorkSource;

PROCEDURE validateObj (x_return_status  OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data  OUT NOCOPY VARCHAR2,
                       p_ws_name IN Varchar2,
                       p_ws_code IN varchar2,
                       p_ws_parent_id IN varchar2,
                       p_ws_child_id IN varchar2,
                       r_mode  IN VARCHAR2
                       ) is
l_count  NUMBER :=0;
l_not_valid_flag varchar2(1);


begin
  l_not_valid_flag := 'N';
  fnd_msg_pub.delete_msg();
  x_return_status := fnd_api.g_ret_sts_success;
  FND_MSG_PUB.initialize;
  x_msg_data := '';
  -- nothing need to check here since distribution function already be checked in javabean
    -- check work source name and work source code
    EXECUTE IMMEDIATE ' select count(*) from ieu_uwqm_work_sources_b where upper(ws_code) = upper(:1) and not_valid_flag=:2 '
    INTO l_count USING p_ws_code, l_not_valid_flag ;
    IF (l_count > 0) then
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count := x_msg_count+1;
            x_msg_data := 'IEU_PROV_WS_CODE_INVALID$';
    END if;
    IF (r_mode = 'create') then
    EXECUTE IMMEDIATE ' select count(*) from ieu_uwqm_work_sources_b b, ieu_uwqm_work_sources_tl tl  '||
                      ' where upper(tl.ws_name) = upper(:1) and b.not_valid_flag=:2  ' ||
                      ' and b.ws_id = tl.ws_id and tl.language = :3 '
    INTO l_count USING p_ws_name, l_not_valid_flag, FND_GLOBAL.CURRENT_LANGUAGE ;
    IF (l_count > 0) then
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count := x_msg_count+1;
            x_msg_data :=x_msg_data||'IEU_PROV_WS_NAME_INVALID$';
    END if;
    IF (p_ws_parent_id <> '0') then
      EXECUTE IMMEDIATE ' select count(*) from ieu_uwqm_ws_assct_props where parent_ws_id = :1 and child_ws_id = :2 '
      INTO l_count USING p_ws_parent_id, p_ws_child_id;
      IF (l_count > 0) then
              x_return_status := fnd_api.g_ret_sts_error;
              x_msg_count := x_msg_count+1;
              x_msg_data := x_msg_data||'IEU_PROV_WS_COMB_INVALID$';
      END if;
    END if;
  END if;
  EXCEPTION

        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN NO_DATA_FOUND THEN
            null;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;


commit;
END validateObj;



END ieu_work_source_pvt;

/
