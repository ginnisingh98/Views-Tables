--------------------------------------------------------
--  DDL for Package Body JTF_RS_WF_EVENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_WF_EVENTS_PUB" AS
  /* $Header: jtfrswpb.pls 120.0 2005/05/11 08:23:27 appldev ship $ */

  /*****************************************************************************************
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_WF_EVENTS_PUB';

  FUNCTION item_key(p_event_name  IN VARCHAR2) RETURN VARCHAR2
  /* Return Item_Key according to Resource Event to be raised
     Item_Key is <Event_Name>-jtf_rs_wf_event_guid_s.nextval */
  IS
  l_key varchar2(240);
  BEGIN
     SELECT p_event_name ||'-'|| jtf_rs_wf_event_guid_s.nextval INTO l_key FROM DUAL;
     RETURN l_key;
  END item_key;

  PROCEDURE create_resource
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST      IN      VARCHAR2,
   P_COMMIT             IN      VARCHAR2,
   P_RESOURCE_ID        IN      NUMBER,
   P_RESOURCE_NAME      IN      VARCHAR2,
   P_CATEGORY           IN      VARCHAR2,
   P_USER_ID            IN      NUMBER,
   P_START_DATE_ACTIVE  IN      DATE,
   P_END_DATE_ACTIVE    IN      DATE,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE';
   l_sysdate                date  := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240) := 'oracle.apps.jtf.jres.resource.create';
   l_resource_id            jtf_rs_resource_extns.resource_id%type := p_resource_id;
   l_resource_name          jtf_rs_resource_extns_vl.resource_name%type := p_resource_name;
   l_category               jtf_rs_resource_extns.category%type := p_category;
   l_start_date_active      jtf_rs_resource_extns.start_date_active%type := trunc(p_start_date_active);
   l_end_date_active        jtf_rs_resource_extns.end_date_active%type := trunc(p_end_date_active);
   l_user_id                jtf_rs_resource_extns.user_id%type := p_user_id;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint cr_emp_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('RESOURCE_ID',l_resource_id,l_list);
    wf_event.AddParameterToList('RESOURCE_NAME',l_resource_name,l_list);
    wf_event.AddParameterToList('CATEGORY',l_category,l_list);
    wf_event.AddParameterToList('USER_ID',l_user_id,l_list);
    wf_event.AddParameterToList('START_DATE_ACTIVE',l_start_date_active,l_list);
    wf_event.AddParameterToList('END_DATE_ACTIVE',l_end_date_active,l_list);

    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO cr_emp_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END create_resource;

PROCEDURE merge_resource
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST      IN      VARCHAR2,
   P_COMMIT             IN      VARCHAR2,
   P_RESOURCE_ID        IN      NUMBER,
   P_END_DATE_ACTIVE    IN      DATE,
   P_REPL_RESOURCE_ID   IN      NUMBER,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'MERGE_RESOURCE';

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240) := 'oracle.apps.jtf.jres.resource.merge';
   l_resource_id            jtf_rs_resource_extns.resource_id%type := p_resource_id;
   l_repl_resource_id       jtf_rs_resource_extns.resource_id%type := p_repl_resource_id;
   l_end_date_active        jtf_rs_resource_extns.end_date_active%type := trunc(p_end_date_active);

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint merge_res_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('RESOURCE_ID',l_resource_id,l_list);
    wf_event.AddParameterToList('REPLACEMENT_RESOURCE_ID',l_repl_resource_id,l_list);
    wf_event.AddParameterToList('END_DATE_ACTIVE',l_end_date_active,l_list);

    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO merge_res_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END merge_resource;


  PROCEDURE update_resource
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST      IN      VARCHAR2,
   P_COMMIT             IN      VARCHAR2,
   P_RESOURCE_REC       IN      jtf_rs_resource_pvt.RESOURCE_REC_TYPE,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
  ) IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';

   l_sysdate                   date  := trunc(sysdate);

   l_list                       WF_PARAMETER_LIST_T;
   l_key                        varchar2(240);
   l_exist                      varchar2(30);
   l_event_name                 varchar2(240);
   l_resource_id                jtf_rs_resource_extns.resource_id%type := p_resource_rec.resource_id;
   l_category                   jtf_rs_resource_extns.category%type := p_resource_rec.category;
   l_new_resource_name          jtf_rs_resource_extns_vl.resource_name%type := p_resource_rec.resource_name;
   l_new_start_date_active      jtf_rs_resource_extns.start_date_active%type := trunc(p_resource_rec.start_date_active);
   l_new_end_date_active        jtf_rs_resource_extns.end_date_active%type := trunc(p_resource_rec.end_date_active);
   l_new_user_id                jtf_rs_resource_extns.user_id%type := p_resource_rec.user_id;
   l_new_time_zone              jtf_rs_resource_extns.time_zone%type := p_resource_rec.time_zone;
   l_new_cost_per_hr            jtf_rs_resource_extns.cost_per_hr%type := p_resource_rec.cost_per_hr;
   l_new_primary_language       jtf_rs_resource_extns.primary_language%type := p_resource_rec.primary_language;
   l_new_secondary_language     jtf_rs_resource_extns.secondary_language%type := p_resource_rec.secondary_language;
   l_new_ies_agent_login        jtf_rs_resource_extns.ies_agent_login%type := p_resource_rec.ies_agent_login;
   l_new_server_group_id        jtf_rs_resource_extns.server_group_id%type := p_resource_rec.server_group_id;
   l_new_assigned_to_group_id   jtf_rs_resource_extns.assigned_to_group_id%type := p_resource_rec.assigned_to_group_id;
   l_new_cost_center            jtf_rs_resource_extns.cost_center%type := p_resource_rec.cost_center;
   l_new_charge_to_cost_center  jtf_rs_resource_extns.charge_to_cost_center%type := p_resource_rec.charge_to_cost_center;
   l_new_comp_currency_code     jtf_rs_resource_extns.compensation_currency_code%type := p_resource_rec.comp_currency_code;
   l_new_commissionable_flag    jtf_rs_resource_extns.commissionable_flag%type := p_resource_rec.commissionable_flag;
   l_new_hold_reason_code       jtf_rs_resource_extns.hold_reason_code%type := p_resource_rec.hold_reason_code;
   l_new_hold_payment           jtf_rs_resource_extns.hold_payment%type := p_resource_rec.hold_payment;
   l_new_comp_service_team_id   jtf_rs_resource_extns.comp_service_team_id%type := p_resource_rec.comp_service_team_id;
   l_new_support_site_id        jtf_rs_resource_extns.support_site_id%type := p_resource_rec.support_site_id;


   cursor res_cur IS
   select user_id,
          resource_name,
          trunc(start_date_active) start_date_active,
          trunc(end_date_active) end_date_active,
          time_zone,
          cost_per_hr,
          primary_language,
          secondary_language,
          ies_agent_login,
          server_group_id,
          assigned_to_group_id,
          cost_center,
          charge_to_cost_center,
          compensation_currency_code,
          commissionable_flag,
          hold_reason_code,
          hold_payment,
          comp_service_team_id,
          support_site_id
   from   jtf_rs_resource_extns_vl
   where  resource_id  = p_resource_rec.resource_id;

   res_rec  res_cur%rowtype;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint upd_emp_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    OPEN res_cur;
    FETCH res_cur INTO res_rec;

    /* If user is changed, raise the event oracle.apps.jtf.jres.resource.update.user */
    if (nvl(res_rec.user_id,-9999) <> nvl(l_new_user_id,-9999)) then

       l_event_name := 'oracle.apps.jtf.jres.resource.update.user';

       --Get the item key
       l_key := item_key(l_event_name);

       -- initialization of object variables

       wf_event.AddParameterToList('RESOURCE_ID',l_resource_id,l_list);
       wf_event.AddParameterToList('CATEGORY',l_category,l_list);
       wf_event.AddParameterToList('RESOURCE_NAME',l_new_resource_name,l_list);
       wf_event.AddParameterToList('OLD_USER_ID',res_rec.user_id,l_list);
       wf_event.AddParameterToList('NEW_USER_ID',l_new_user_id,l_list);

       -- Raise Event
       wf_event.raise(
                      p_event_name        => l_event_name
                     ,p_event_key         => l_key
                     ,p_parameters        => l_list
                     );

       l_list.DELETE;

    end if;

    /* If date effectivity is changed, raise the event oracle.apps.jtf.jres.resource.update.effectivedate */
    if (((res_rec.end_date_active is NULL) AND (l_new_end_date_active is NOT NULL)) OR
        ((res_rec.end_date_active is NOT NULL) AND (l_new_end_date_active is NULL)) OR
        (res_rec.end_date_active <> l_new_end_date_active) OR
        (res_rec.start_date_active <> l_new_start_date_active)
       ) then

       l_event_name := 'oracle.apps.jtf.jres.resource.update.effectivedate';

       --Get the item key
       l_key := item_key(l_event_name);

       -- initialization of object variables

       wf_event.AddParameterToList('RESOURCE_ID',l_resource_id,l_list);
       wf_event.AddParameterToList('CATEGORY',l_category,l_list);
       wf_event.AddParameterToList('RESOURCE_NAME',l_new_resource_name,l_list);
       wf_event.AddParameterToList('OLD_START_DATE_ACTIVE',res_rec.start_date_active,l_list);
       wf_event.AddParameterToList('NEW_START_DATE_ACTIVE',l_new_start_date_active,l_list);
       wf_event.AddParameterToList('OLD_END_DATE_ACTIVE',res_rec.end_date_active,l_list);
       wf_event.AddParameterToList('NEW_END_DATE_ACTIVE',l_new_end_date_active,l_list);

       -- Raise Event
       wf_event.raise(
                      p_event_name        => l_event_name
                     ,p_event_key         => l_key
                     ,p_parameters        => l_list
                     );

       l_list.DELETE;

    end if;

    /* If any other attribute changes, other than user_id and date effectivity,
      raise the event oracle.apps.jtf.jres.resource.update.attributes */
    if (((res_rec.resource_name is NULL) AND (l_new_resource_name is NOT NULL)) OR
        ((res_rec.resource_name is NOT NULL) AND (l_new_resource_name is NULL)) OR
        (res_rec.resource_name <> l_new_resource_name) OR
        ((res_rec.time_zone is NULL) AND (l_new_time_zone is NOT NULL)) OR
        ((res_rec.time_zone is NOT NULL) AND (l_new_time_zone is NULL)) OR
        (res_rec.time_zone <> l_new_time_zone) OR
        ((res_rec.cost_per_hr is NULL) AND (l_new_cost_per_hr is NOT NULL)) OR
        ((res_rec.cost_per_hr is NOT NULL) AND (l_new_cost_per_hr is NULL)) OR
        (res_rec.cost_per_hr <> l_new_cost_per_hr) OR
        ((res_rec.primary_language is NULL) AND (l_new_primary_language is NOT NULL)) OR
        ((res_rec.primary_language is NOT NULL) AND (l_new_primary_language is NULL)) OR
        (res_rec.primary_language <> l_new_primary_language) OR
        ((res_rec.secondary_language is NULL) AND (l_new_secondary_language is NOT NULL)) OR
        ((res_rec.secondary_language is NOT NULL) AND (l_new_secondary_language is NULL)) OR
        (res_rec.secondary_language <> l_new_secondary_language) OR
        ((res_rec.ies_agent_login is NULL) AND (l_new_ies_agent_login is NOT NULL)) OR
        ((res_rec.ies_agent_login is NOT NULL) AND (l_new_ies_agent_login is NULL)) OR
        (res_rec.ies_agent_login <> l_new_ies_agent_login) OR
        ((res_rec.server_group_id is NULL) AND (l_new_server_group_id is NOT NULL)) OR
        ((res_rec.server_group_id is NOT NULL) AND (l_new_server_group_id is NULL)) OR
        (res_rec.server_group_id <> l_new_server_group_id) OR
        ((res_rec.assigned_to_group_id is NULL) AND (l_new_assigned_to_group_id is NOT NULL)) OR
        ((res_rec.assigned_to_group_id is NOT NULL) AND (l_new_assigned_to_group_id is NULL)) OR
        (res_rec.assigned_to_group_id <> l_new_assigned_to_group_id) OR
        ((res_rec.cost_center is NULL) AND (l_new_cost_center is NOT NULL)) OR
        ((res_rec.cost_center is NOT NULL) AND (l_new_cost_center is NULL)) OR
        (res_rec.cost_center <> l_new_cost_center) OR
        ((res_rec.charge_to_cost_center is NULL) AND (l_new_charge_to_cost_center is NOT NULL)) OR
        ((res_rec.charge_to_cost_center is NOT NULL) AND (l_new_charge_to_cost_center is NULL)) OR
        (res_rec.charge_to_cost_center <> l_new_charge_to_cost_center) OR
        ((res_rec.compensation_currency_code is NULL) AND (l_new_comp_currency_code is NOT NULL)) OR
        ((res_rec.compensation_currency_code is NOT NULL) AND (l_new_comp_currency_code is NULL)) OR
        (res_rec.compensation_currency_code <> l_new_comp_currency_code) OR
        ((res_rec.commissionable_flag is NULL) AND (l_new_commissionable_flag is NOT NULL)) OR
        ((res_rec.commissionable_flag is NOT NULL) AND (l_new_commissionable_flag is NULL)) OR
        (res_rec.commissionable_flag <> l_new_commissionable_flag) OR
        ((res_rec.hold_reason_code is NULL) AND (l_new_hold_reason_code is NOT NULL)) OR
        ((res_rec.hold_reason_code is NOT NULL) AND (l_new_hold_reason_code is NULL)) OR
        (res_rec.hold_reason_code <> l_new_hold_reason_code) OR
        ((res_rec.hold_payment is NULL) AND (l_new_hold_payment is NOT NULL)) OR
        ((res_rec.hold_payment is NOT NULL) AND (l_new_hold_payment is NULL)) OR
        (res_rec.hold_payment <> l_new_hold_payment) OR
        ((res_rec.comp_service_team_id is NULL) AND (l_new_comp_service_team_id is NOT NULL)) OR
        ((res_rec.comp_service_team_id is NOT NULL) AND (l_new_comp_service_team_id is NULL)) OR
        (res_rec.comp_service_team_id <> l_new_comp_service_team_id) OR
        ((res_rec.support_site_id is NULL) AND (l_new_support_site_id is NOT NULL)) OR
        ((res_rec.support_site_id is NOT NULL) AND (l_new_support_site_id is NULL)) OR
        (res_rec.support_site_id <> l_new_support_site_id)
       ) then

       l_event_name := 'oracle.apps.jtf.jres.resource.update.attributes';

       --Get the item key
       l_key := item_key(l_event_name);

       -- initialization of object variables

       wf_event.AddParameterToList('RESOURCE_ID',l_resource_id,l_list);
       wf_event.AddParameterToList('CATEGORY',l_category,l_list);
       wf_event.AddParameterToList('OLD_RESOURCE_NAME',res_rec.resource_name,l_list);
       wf_event.AddParameterToList('NEW_RESOURCE_NAME',l_new_resource_name,l_list);
       wf_event.AddParameterToList('OLD_TIME_ZONE',res_rec.time_zone,l_list);
       wf_event.AddParameterToList('NEW_TIME_ZONE',l_new_time_zone,l_list);
       wf_event.AddParameterToList('OLD_COST_PER_HR',res_rec.cost_per_hr,l_list);
       wf_event.AddParameterToList('NEW_COST_PER_HR',l_new_cost_per_hr,l_list);
       wf_event.AddParameterToList('OLD_PRIMARY_LANGUAGE',res_rec.primary_language,l_list);
       wf_event.AddParameterToList('NEW_PRIMARY_LANGUAGE',l_new_primary_language,l_list);
       wf_event.AddParameterToList('OLD_SECONDARY_LANGUAGE',res_rec.secondary_language,l_list);
       wf_event.AddParameterToList('NEW_SECONDARY_LANGUAGE',l_new_secondary_language,l_list);
       wf_event.AddParameterToList('OLD_IES_AGENT_LOGIN',res_rec.ies_agent_login,l_list);
       wf_event.AddParameterToList('NEW_IES_AGENT_LOGIN',l_new_ies_agent_login,l_list);
       wf_event.AddParameterToList('OLD_SERVER_GROUP_ID',res_rec.server_group_id,l_list);
       wf_event.AddParameterToList('NEW_SERVER_GROUP_ID',l_new_server_group_id,l_list);
       wf_event.AddParameterToList('OLD_ASSIGNED_TO_GROUP_ID',res_rec.assigned_to_group_id,l_list);
       wf_event.AddParameterToList('NEW_ASSIGNED_TO_GROUP_ID',l_new_assigned_to_group_id,l_list);
       wf_event.AddParameterToList('OLD_COST_CENTER',res_rec.cost_center,l_list);
       wf_event.AddParameterToList('NEW_COST_CENTER',l_new_cost_center,l_list);
       wf_event.AddParameterToList('OLD_CHARGE_TO_COST_CENTER',res_rec.charge_to_cost_center,l_list);
       wf_event.AddParameterToList('NEW_CHARGE_TO_COST_CENTER',l_new_charge_to_cost_center,l_list);
       wf_event.AddParameterToList('OLD_COMPENSATION_CURRENCY_CODE',res_rec.compensation_currency_code,l_list);
       wf_event.AddParameterToList('NEW_COMPENSATION_CURRENCY_CODE',l_new_comp_currency_code,l_list);
       wf_event.AddParameterToList('OLD_COMMISSIONABLE_FLAG',res_rec.commissionable_flag,l_list);
       wf_event.AddParameterToList('NEW_COMMISSIONABLE_FLAG',l_new_commissionable_flag,l_list);
       wf_event.AddParameterToList('OLD_HOLD_REASON_CODE',res_rec.hold_reason_code,l_list);
       wf_event.AddParameterToList('NEW_HOLD_REASON_CODE',l_new_hold_reason_code,l_list);
       wf_event.AddParameterToList('OLD_HOLD_PAYMENT',res_rec.hold_payment,l_list);
       wf_event.AddParameterToList('NEW_HOLD_PAYMENT',l_new_hold_payment,l_list);
       wf_event.AddParameterToList('OLD_COMP_SERVICE_TEAM_ID',res_rec.comp_service_team_id,l_list);
       wf_event.AddParameterToList('NEW_COMP_SERVICE_TEAM_ID',l_new_comp_service_team_id,l_list);
       wf_event.AddParameterToList('OLD_SUPPORT_SITE_ID',res_rec.support_site_id,l_list);
       wf_event.AddParameterToList('NEW_SUPPORT_SITE_ID',l_new_support_site_id,l_list);

       -- Raise Event
       wf_event.raise(
                      p_event_name        => l_event_name
                     ,p_event_key         => l_key
                     ,p_parameters        => l_list
                     );

       l_list.DELETE;

    end if;

    CLOSE res_cur;

    EXCEPTION when OTHERS then
       ROLLBACK TO upd_emp_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END update_resource;

  PROCEDURE delete_resource
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST      IN      VARCHAR2,
   P_COMMIT             IN      VARCHAR2,
   P_RESOURCE_ID        IN      NUMBER,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
  ) IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE';

   l_sysdate             date  := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240) := 'oracle.apps.jtf.jres.resource.delete';
   l_resource_id            jtf_rs_resource_extns.resource_id%type := p_resource_id;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint del_emp_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('RESOURCE_ID',l_resource_id,l_list);

    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO del_emp_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
 END delete_resource;


  PROCEDURE create_resource_role
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST      IN      VARCHAR2,
   P_COMMIT             IN      VARCHAR2,
   P_ROLE_ID            IN      NUMBER,
   P_ROLE_TYPE_CODE     IN      VARCHAR2,
   P_ROLE_CODE          IN      VARCHAR2,
   P_ROLE_NAME          IN      VARCHAR2,
   P_ROLE_DESC          IN      VARCHAR2,
   P_ACTIVE_FLAG        IN      VARCHAR2,
   P_MEMBER_FLAG        IN      VARCHAR2,
   P_ADMIN_FLAG         IN      VARCHAR2,
   P_LEAD_FLAG          IN      VARCHAR2,
   P_MANAGER_FLAG       IN      VARCHAR2,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_ROLE';
   l_sysdate                date  := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240) := 'oracle.apps.jtf.jres.role.create';

   l_role_id                jtf_rs_roles_b.role_id%type := p_role_id;
   l_role_type_code         jtf_rs_roles_b.role_type_code%type := p_role_type_code;
   l_role_code              jtf_rs_roles_b.role_code%type := p_role_code;
   l_role_name              jtf_rs_roles_tl.role_name%type := p_role_name;
   l_role_desc              jtf_rs_roles_tl.role_desc%type := p_role_desc;
   l_active_flag            jtf_rs_roles_b.active_flag%type := p_active_flag;
   l_member_flag            jtf_rs_roles_b.member_flag%type := p_member_flag;
   l_admin_flag             jtf_rs_roles_b.admin_flag%type := p_admin_flag;
   l_lead_flag              jtf_rs_roles_b.lead_flag%type := p_lead_flag;
   l_manager_flag           jtf_rs_roles_b.manager_flag%type := p_manager_flag;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint cr_res_role_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('ROLE_ID',l_role_id,l_list);
    wf_event.AddParameterToList('ROLE_TYPE_CODE',l_role_type_code,l_list);
    wf_event.AddParameterToList('ROLE_CODE',l_role_code,l_list);
    wf_event.AddParameterToList('ROLE_NAME',l_role_name,l_list);
    wf_event.AddParameterToList('ROLE_DESC',l_role_desc,l_list);
    wf_event.AddParameterToList('ACTIVE_FLAG',l_active_flag,l_list);
    wf_event.AddParameterToList('MEMBER_FLAG',l_member_flag,l_list);
    wf_event.AddParameterToList('ADMIN_FLAG',l_admin_flag,l_list);
    wf_event.AddParameterToList('LEAD_FLAG',l_lead_flag,l_list);
    wf_event.AddParameterToList('MANAGER_FLAG',l_manager_flag,l_list);

    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO cr_res_role_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END create_resource_role;


  PROCEDURE update_resource_role
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST      IN      VARCHAR2,
   P_COMMIT             IN      VARCHAR2,
   P_RESOURCE_ROLE_REC  IN      jtf_rs_roles_pvt.RESOURCE_ROLE_REC_TYPE,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
  ) IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_ROLE';

   l_sysdate                   date  := trunc(sysdate);

   l_list                       WF_PARAMETER_LIST_T;
   l_key                        varchar2(240);
   l_exist                      varchar2(30);
   l_event_name                 varchar2(240) := 'oracle.apps.jtf.jres.role.update';

   l_role_id                    jtf_rs_roles_b.role_id%type := p_resource_role_rec.role_id;
   l_new_role_type_code         jtf_rs_roles_b.role_type_code%type := p_resource_role_rec.role_type_code;
   l_new_role_code              jtf_rs_roles_b.role_code%type := p_resource_role_rec.role_code;
   l_new_role_name              jtf_rs_roles_tl.role_name%type := p_resource_role_rec.role_name;
   l_new_role_desc              jtf_rs_roles_tl.role_desc%type := p_resource_role_rec.role_desc;
   l_new_active_flag            jtf_rs_roles_b.active_flag%type := p_resource_role_rec.active_flag;
   l_new_member_flag            jtf_rs_roles_b.member_flag%type := p_resource_role_rec.member_flag;
   l_new_admin_flag             jtf_rs_roles_b.admin_flag%type := p_resource_role_rec.admin_flag;
   l_new_lead_flag              jtf_rs_roles_b.lead_flag%type := p_resource_role_rec.lead_flag;
   l_new_manager_flag           jtf_rs_roles_b.manager_flag%type := p_resource_role_rec.manager_flag;

   cursor res_role_cur IS
   select
          role_id,
          role_type_code,
          role_code,
          role_name,
          role_desc,
          active_flag,
          member_flag,
          admin_flag,
          lead_flag,
          manager_flag
   from   jtf_rs_roles_vl
   where  role_id  = p_resource_role_rec.role_id;

   res_role_rec  res_role_cur%rowtype;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint upd_res_role_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    OPEN res_role_cur;
    FETCH res_role_cur INTO res_role_rec;

    /* If any of the following attributes changes, raise the event oracle.apps.jtf.jres.role.update */

    if ((res_role_rec.role_type_code <> l_new_role_type_code) OR
        (res_role_rec.role_code <> l_new_role_code) OR
        (res_role_rec.role_name <> l_new_role_name) OR
        ((res_role_rec.role_desc is NULL) AND (l_new_role_desc is NOT NULL)) OR
        ((res_role_rec.role_desc is NOT NULL) AND (l_new_role_desc is NULL)) OR
        (res_role_rec.role_desc <> l_new_role_desc) OR
        (res_role_rec.active_flag <> l_new_active_flag) OR
        (nvl(res_role_rec.member_flag,'X') <> nvl(l_new_member_flag,'X')) OR
        (nvl(res_role_rec.admin_flag,'X') <> nvl(l_new_admin_flag,'X')) OR
        (nvl(res_role_rec.lead_flag,'X') <> nvl(l_new_lead_flag,'X')) OR
        (nvl(res_role_rec.manager_flag,'X') <> nvl(l_new_manager_flag,'X'))
       ) then

       --Get the item key
       l_key := item_key(l_event_name);

       -- initialization of object variables

       wf_event.AddParameterToList('ROLE_ID',l_role_id,l_list);
       wf_event.AddParameterToList('OLD_ROLE_TYPE_CODE',res_role_rec.role_type_code,l_list);
       wf_event.AddParameterToList('NEW_ROLE_TYPE_CODE',l_new_role_type_code,l_list);
       wf_event.AddParameterToList('OLD_ROLE_CODE',res_role_rec.role_code,l_list);
       wf_event.AddParameterToList('NEW_ROLE_CODE',l_new_role_code,l_list);
       wf_event.AddParameterToList('OLD_ROLE_NAME',res_role_rec.role_name,l_list);
       wf_event.AddParameterToList('NEW_ROLE_NAME',l_new_role_name,l_list);
       wf_event.AddParameterToList('OLD_ROLE_DESC',res_role_rec.role_desc,l_list);
       wf_event.AddParameterToList('NEW_ROLE_DESC',l_new_role_desc,l_list);
       wf_event.AddParameterToList('OLD_ACTIVE_FLAG',res_role_rec.active_flag,l_list);
       wf_event.AddParameterToList('NEW_ACTIVE_FLAG',l_new_active_flag,l_list);
       wf_event.AddParameterToList('OLD_MEMBER_FLAG',res_role_rec.member_flag,l_list);
       wf_event.AddParameterToList('NEW_MEMBER_FLAG',l_new_member_flag,l_list);
       wf_event.AddParameterToList('OLD_ADMIN_FLAG',res_role_rec.admin_flag,l_list);
       wf_event.AddParameterToList('NEW_ADMIN_FLAG',l_new_admin_flag,l_list);
       wf_event.AddParameterToList('OLD_LEAD_FLAG',res_role_rec.lead_flag,l_list);
       wf_event.AddParameterToList('NEW_LEAD_FLAG',l_new_lead_flag,l_list);
       wf_event.AddParameterToList('OLD_MANAGER_FLAG',res_role_rec.manager_flag,l_list);
       wf_event.AddParameterToList('NEW_MANAGER_FLAG',l_new_manager_flag,l_list);

       -- Raise Event
       wf_event.raise(
                      p_event_name        => l_event_name
                     ,p_event_key         => l_key
                     ,p_parameters        => l_list
                     );

       l_list.DELETE;

    end if;

    CLOSE res_role_cur;

    EXCEPTION when OTHERS then
       ROLLBACK TO upd_res_role_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END update_resource_role;

 PROCEDURE delete_resource_role
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST      IN      VARCHAR2,
   P_COMMIT             IN      VARCHAR2,
   P_ROLE_ID	        IN      NUMBER,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
  ) IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_ROLE';

   l_sysdate             date  := trunc(sysdate);

   l_list                WF_PARAMETER_LIST_T;
   l_key                 varchar2(240);
   l_exist               varchar2(30);
   l_event_name          varchar2(240) := 'oracle.apps.jtf.jres.role.delete';

   l_role_id             jtf_rs_roles_b.role_id%type := p_role_id;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint del_res_role_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('ROLE_ID',l_role_id,l_list);

    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO del_res_role_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
 END delete_resource_role;


 PROCEDURE create_resource_role_relate
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST      IN      VARCHAR2,
   P_COMMIT             IN      VARCHAR2,
   P_ROLE_RELATE_ID     IN      NUMBER,
   P_ROLE_RESOURCE_TYPE IN      VARCHAR2,
   P_ROLE_RESOURCE_ID   IN      NUMBER,
   P_ROLE_ID            IN      NUMBER,
   P_START_DATE_ACTIVE  IN      DATE,
   P_END_DATE_ACTIVE    IN      DATE,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_ROLE_RELATE';
   l_sysdate                date  := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240) := 'oracle.apps.jtf.jres.rolerelate.create';

   l_role_relate_id         jtf_rs_role_relations.role_relate_id%type      := p_role_relate_id;
   l_role_resource_type     jtf_rs_role_relations.role_resource_type%type  := p_role_resource_type;
   l_role_resource_id       jtf_rs_role_relations.role_resource_id%type    := p_role_resource_id;
   l_role_id                jtf_rs_role_relations.role_id%type             := p_role_id;
   l_start_date_active      jtf_rs_role_relations.start_date_active%type   := trunc(p_start_date_active);
   l_end_date_active        jtf_rs_role_relations.end_date_active%type     := trunc(p_end_date_active);


 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint cr_rolerelate_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('ROLE_RELATE_ID',l_role_relate_id,l_list);
    wf_event.AddParameterToList('ROLE_RESOURCE_TYPE',l_role_resource_type,l_list);
    wf_event.AddParameterToList('ROLE_RESOURCE_ID',l_role_resource_id,l_list);
    wf_event.AddParameterToList('ROLE_ID',l_role_id,l_list);
    wf_event.AddParameterToList('START_DATE_ACTIVE',l_start_date_active,l_list);
    wf_event.AddParameterToList('END_DATE_ACTIVE',l_end_date_active,l_list);

    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO cr_rolerelate_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END create_resource_role_relate;


 PROCEDURE update_resource_role_relate
  (P_API_VERSION                IN      NUMBER,
   P_INIT_MSG_LIST              IN      VARCHAR2,
   P_COMMIT                     IN      VARCHAR2,
   P_ROLE_RELATE_ID             IN      NUMBER,
   P_ROLE_RESOURCE_TYPE         IN      VARCHAR2,
   P_ROLE_RESOURCE_ID           IN      NUMBER,
   P_ROLE_ID                    IN      NUMBER,
   P_START_DATE_ACTIVE          IN      DATE,
   P_END_DATE_ACTIVE            IN      DATE,
   X_RETURN_STATUS              OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT                  OUT     NOCOPY NUMBER,
   X_MSG_DATA                   OUT     NOCOPY VARCHAR2
  ) IS

   l_api_version                CONSTANT NUMBER := 1.0;
   l_api_name                   CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_ROLE_RELATE';

   l_sysdate                    date  := trunc(sysdate);

   l_list                       WF_PARAMETER_LIST_T;
   l_key                        varchar2(240);
   l_exist                      varchar2(30);
   l_event_name                 varchar2(240) := 'oracle.apps.jtf.jres.rolerelate.update';

   l_role_relate_id             jtf_rs_role_relations.role_relate_id%type      := p_role_relate_id;
   l_role_resource_type         jtf_rs_role_relations.role_resource_type%type  := p_role_resource_type;
   l_role_resource_id           jtf_rs_role_relations.role_resource_id%type    := p_role_resource_id;
   l_role_id                    jtf_rs_role_relations.role_id%type             := p_role_id;
   l_new_start_date_active      jtf_rs_role_relations.start_date_active%type   := trunc(p_start_date_active);
   l_new_end_date_active        jtf_rs_role_relations.end_date_active%type     := trunc(p_end_date_active);

   cursor res_rolerelate_cur IS
   select trunc(start_date_active) start_date_active,
          trunc(end_date_active) end_date_active
   from   jtf_rs_role_relations
   where  role_relate_id  = p_role_relate_id;

   res_rolerelate_rec  res_rolerelate_cur%rowtype;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint upd_rolerelate_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    OPEN res_rolerelate_cur;
    FETCH res_rolerelate_cur INTO res_rolerelate_rec;

    /* If any of the following attributes changes, raise the event oracle.apps.jtf.jres.rolerelate.update */

    if (((res_rolerelate_rec.end_date_active is NULL) AND (l_new_end_date_active is NOT NULL)) OR
        ((res_rolerelate_rec.end_date_active is NOT NULL) AND (l_new_end_date_active is NULL)) OR
        (res_rolerelate_rec.end_date_active <> l_new_end_date_active) OR
        (res_rolerelate_rec.start_date_active <> l_new_start_date_active)
       ) then

       --Get the item key
       l_key := item_key(l_event_name);

       -- initialization of object variables

       wf_event.AddParameterToList('ROLE_RELATE_ID',l_role_relate_id,l_list);
       wf_event.AddParameterToList('ROLE_RESOURCE_TYPE',l_role_resource_type,l_list);
       wf_event.AddParameterToList('ROLE_RESOURCE_ID',l_role_resource_id,l_list);
       wf_event.AddParameterToList('ROLE_ID',l_role_id,l_list);
       wf_event.AddParameterToList('OLD_START_DATE_ACTIVE',res_rolerelate_rec.start_date_active,l_list);
       wf_event.AddParameterToList('NEW_START_DATE_ACTIVE',l_new_start_date_active,l_list);
       wf_event.AddParameterToList('OLD_END_DATE_ACTIVE',res_rolerelate_rec.end_date_active,l_list);
       wf_event.AddParameterToList('NEW_END_DATE_ACTIVE',l_new_end_date_active,l_list);

       -- Raise Event
       wf_event.raise(
                      p_event_name        => l_event_name
                     ,p_event_key         => l_key
                     ,p_parameters        => l_list
                     );

       l_list.DELETE;

    end if;

    CLOSE res_rolerelate_cur;

    EXCEPTION when OTHERS then
       ROLLBACK TO upd_rolerelate_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END update_resource_role_relate;

 PROCEDURE delete_resource_role_relate
  (P_API_VERSION        IN      NUMBER,
   P_INIT_MSG_LIST      IN      VARCHAR2,
   P_COMMIT             IN      VARCHAR2,
   P_ROLE_RELATE_ID     IN      NUMBER,
   X_RETURN_STATUS      OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT     NOCOPY NUMBER,
   X_MSG_DATA           OUT     NOCOPY VARCHAR2
  ) IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_ROLE_RELATE';

   l_sysdate             date  := trunc(sysdate);

   l_list                WF_PARAMETER_LIST_T;
   l_key                 varchar2(240);
   l_exist               varchar2(30);
   l_event_name          varchar2(240) := 'oracle.apps.jtf.jres.rolerelate.delete';

   l_role_relate_id      jtf_rs_role_relations.role_relate_id%type      := p_role_relate_id;

   cursor del_rolerelate_cur IS
   select role_resource_type,
          role_resource_id,
          role_id
   from   jtf_rs_role_relations
   where  role_relate_id  = p_role_relate_id
   and    nvl(delete_flag,'N') = 'Y';

   del_rolerelate_rec  del_rolerelate_cur%rowtype;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint del_rolerelate_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    OPEN del_rolerelate_cur;
    FETCH del_rolerelate_cur INTO del_rolerelate_rec;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('ROLE_RELATE_ID',l_role_relate_id,l_list);
    wf_event.AddParameterToList('ROLE_RESOURCE_TYPE',del_rolerelate_rec.role_resource_type,l_list);
    wf_event.AddParameterToList('ROLE_RESOURCE_ID',del_rolerelate_rec.role_resource_id,l_list);
    wf_event.AddParameterToList('ROLE_ID',del_rolerelate_rec.role_id,l_list);

    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    CLOSE del_rolerelate_cur;

    EXCEPTION when OTHERS then
       ROLLBACK TO del_rolerelate_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
 END delete_resource_role_relate;

END jtf_rs_wf_events_pub;

/
