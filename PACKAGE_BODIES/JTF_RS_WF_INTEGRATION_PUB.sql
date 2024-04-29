--------------------------------------------------------
--  DDL for Package Body JTF_RS_WF_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_WF_INTEGRATION_PUB" AS
  /* $Header: jtfrswfb.pls 120.1 2005/06/24 20:30:40 baianand ship $ */

  /*****************************************************************************************
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_WF_INTEGRATION_PUB';

  G_GRP_ORIG_SYSTEM         CONSTANT VARCHAR2(10) := 'JRES_GRP';
  G_TEAM_ORIG_SYSTEM         CONSTANT VARCHAR2(10) := 'JRES_TEAM';

 PROCEDURE get_wf_role
   (p_resource_id         IN   number,
    x_role_name           OUT NOCOPY  varchar2,
    x_orig_system         OUT NOCOPY  varchar2,
    x_orig_system_id      OUT NOCOPY  number
   ) IS

   cursor res_cur IS
   select user_id
   from   jtf_rs_resource_extns
   where  resource_id  = p_resource_id;

   l_user_id         number;

 BEGIN

--xx    OPEN res_cur;
--xx    FETCH res_cur INTO l_user_id;
--xx    CLOSE res_cur;

    l_user_id  := NULL;

    jtf_rs_wf_integration_pub.get_wf_role
                             (p_resource_id         => p_resource_id,
                              p_user_id             => l_user_id,
                              x_role_name           => x_role_name,
                              x_orig_system         => x_orig_system,
                              x_orig_system_id      => x_orig_system_id);
    EXCEPTION when OTHERS then
       null;
 END get_wf_role;

PROCEDURE get_wf_role
   (p_resource_id         IN   number,
    p_user_id             IN   number,
    x_role_name           OUT NOCOPY  varchar2,
    x_orig_system         OUT NOCOPY  varchar2,
    x_orig_system_id      OUT NOCOPY  number
   ) IS

   l_res_usr_orig_system  wf_local_roles.orig_system%TYPE := 'JRES_IND';
   l_res_usr_role_name    wf_local_roles.name%TYPE := l_res_usr_orig_system||':'||to_char(p_resource_id);
   l_res_hz_orig_system   wf_local_roles.orig_system%TYPE := 'HZ_PARTY';

   l_role_name            wf_local_roles.name%TYPE;
   l_orig_system          wf_local_roles.orig_system%TYPE;
   l_orig_system_id       wf_local_roles.orig_system_id%TYPE;

   l_category             jtf_rs_resource_extns.category%TYPE;
   l_source_id            jtf_rs_resource_extns.source_id%TYPE;
   l_person_party_id      jtf_rs_resource_extns.person_party_id%TYPE;
   l_party_id             hz_parties.party_id%TYPE;

   cursor res_cur IS
   select category, source_id, person_party_id
   from   jtf_rs_resource_extns
   where  resource_id  = p_resource_id;

   cursor res_wfrole_cur IS
   select name, orig_system, orig_system_id
   from   wf_local_roles
   where  name = l_res_usr_role_name
   and    orig_system = l_res_usr_orig_system
   and    orig_system_id = p_resource_id;

   cursor res_hz_wfrole_cur(c_party_id number) IS
   select name, orig_system, orig_system_id
   from   wf_local_roles
   where  orig_system = l_res_hz_orig_system
   and    orig_system_id = c_party_id;

   cursor res_po_party_cur(c_vendor_contact_id number) IS
   select per_party_id
   from   po_vendor_contacts
   where  vendor_contact_id = c_vendor_contact_id;

--xx   cursor fnd_wfrole_cur IS
--xx   select user_name, 'FND_USR', user_id
--xx   from   fnd_user
--xx   where  user_id = p_user_id;

 BEGIN

       OPEN  res_cur;
       FETCH res_cur INTO l_category, l_source_id, l_person_party_id;
       CLOSE res_cur;

       if l_category = 'EMPLOYEE' then
         l_party_id := l_person_party_id;
       elsif l_category in ('PARTY','PARTNER') then
         l_party_id := l_source_id;
       elsif (l_category  = 'SUPPLIER_CONTACT') then
          OPEN  res_po_party_cur(l_source_id);
          FETCH res_po_party_cur INTO l_party_id;
          CLOSE res_po_party_cur;
       end if;

    /*  If user is addtached to the given resource_id */
--xx    if (p_user_id is NULL) then
--xx
       if l_category not in ('EMPLOYEE','PARTY','PARTNER','SUPPLIER_CONTACT') then
          OPEN  res_wfrole_cur;
          FETCH res_wfrole_cur INTO l_role_name, l_orig_system, l_orig_system_id;
          CLOSE res_wfrole_cur;
       else
          OPEN  res_hz_wfrole_cur(l_party_id);
          FETCH res_hz_wfrole_cur INTO l_role_name, l_orig_system, l_orig_system_id;
          CLOSE res_hz_wfrole_cur;
       end if;
--xx
--xx    else
--xx       OPEN  fnd_wfrole_cur;
--xx       FETCH fnd_wfrole_cur INTO x_role_name, x_orig_system, x_orig_system_id;
--xx       CLOSE fnd_wfrole_cur;
--xx
--xx       Wf_Directory.GetRoleOrigSysInfo(
--xx       x_role_name,
--xx       x_orig_system,
--xx       x_orig_system_id );
--xx
--xx    end if; /* End of  If user is addtached to the given resource_id */

    x_role_name      := l_role_name;
    x_orig_system    := l_orig_system;
    x_orig_system_id := l_orig_system_id;

    EXCEPTION when OTHERS then
       null;

 END  get_wf_role;

 FUNCTION get_wf_role(p_resource_id IN number) RETURN varchar2
 IS
    l_role_name         wf_local_roles.name%TYPE;
    l_orig_system       wf_local_roles.orig_system%TYPE;
    l_orig_system_id    wf_local_roles.orig_system_id%TYPE;
 BEGIN
    jtf_rs_wf_integration_pub.get_wf_role
                             (p_resource_id         => p_resource_id,
                              x_role_name           => l_role_name,
                              x_orig_system         => l_orig_system,
                              x_orig_system_id      => l_orig_system_id);
    RETURN l_role_name;
    EXCEPTION when OTHERS then
       RETURN NULL;
 END get_wf_role;

/*
 AddParameterToList - adds name and value to wf_parameter_list_t
	              If the list is null, will initialize, otherwise just adds to the end of list
*/
 PROCEDURE AddParameterToList(p_name  in varchar2,
                              p_value in varchar2,
                              p_parameterlist in out nocopy wf_parameter_list_t)
 IS
    j       number;
 BEGIN
    if (p_ParameterList is null) then
    --
    -- Initialize Parameter List and set value
    --
       p_ParameterList := wf_parameter_list_t(null);
       p_ParameterList(1) := wf_parameter_t(p_Name, p_Value);
    else
    --
    -- parameter list exists, add parameter to list
    --
       p_ParameterList.EXTEND;
       j := p_ParameterList.COUNT;
       p_ParameterList(j) := wf_parameter_t(p_Name, p_Value);
    end if;
 END AddParameterToList;

/*
 PROCEDURE get_user_role_dates
   (p_user_start_date         IN   DATE,
    p_user_end_date           IN   DATE,
    p_role_start_date         IN   DATE,
    p_role_end_date           IN   DATE,
    x_user_role_start_date    OUT NOCOPY  DATE,
    x_user_role_end_date      OUT NOCOPY  DATE
   ) IS

   l_g_miss_date         date := trunc(to_date('31-12-4712','DD-MM-YYYY'));

 BEGIN

       if p_role_start_date >= p_user_start_date then
          x_user_role_start_date := p_role_start_date;
       else
          x_user_role_start_date := p_user_start_date;
       end if;

       if nvl(p_role_end_date,l_g_miss_date) >= nvl(p_user_end_date,l_g_miss_date) then
          x_user_role_end_date := p_user_end_date;
       else
          x_user_role_end_date := p_role_end_date;
       end if;

 END get_user_role_dates;
*/

 PROCEDURE create_resource
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   NUMBER,
   P_RESOURCE_NAME        IN   VARCHAR2,
   P_CATEGORY             IN   VARCHAR2,
   P_USER_ID              IN   NUMBER,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE    IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE';

   l_start_date_active   date  := trunc(p_start_date_active);
   l_end_date_active     date  := trunc(p_end_date_active);
   l_sysdate             date  := trunc(sysdate);

   l_res_usr_orig_system wf_local_roles.orig_system%TYPE := 'JRES_IND';
   l_res_usr_role_name   wf_local_roles.name%TYPE := l_res_usr_orig_system||':'||to_char(p_resource_id);

   l_list                WF_PARAMETER_LIST_T;

   /* Cursor to get the party id of the employee */
   cursor emp_party_id_cur IS
   select ppf.party_id
   from   per_all_people_f ppf,
          jtf_rs_resource_extns res
   where  res.category  = 'EMPLOYEE'
   and    res.source_id = ppf.person_id
   and    res.resource_id  = p_resource_id
   order by ppf.effective_start_date desc;

   /* Cursor to get the party id of the party/partner */
   cursor partner_party_id_cur IS
   select res.source_id
   from   jtf_rs_resource_extns res
   where  res.resource_id  = p_resource_id;

   l_person_party_id number;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint cr_emp_wf_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
    if p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    /*  If the resource is not attached to an fnd user */
--    if (p_user_id is NULL) then

      if (p_category not in ('EMPLOYEE','PARTY','PARTNER','SUPPLIER_CONTACT')) then

       /* Looking for resources with l_end_date_active >= l_sysdate at the time of creation */
--       if ( (l_start_date_active <= l_sysdate) AND
--            ((l_end_date_active >= l_sysdate) OR (l_end_date_active is NULL)) ) then
       if ((l_end_date_active >= l_sysdate) OR (l_end_date_active is NULL)) then

          /* Below If statement is to derive the party_id of the resource.
             If the category is not EMPLOYEE, PARTY or PARTNER, then party_id will be NULL */
          l_person_party_id := NULL;
          if p_category = 'EMPLOYEE' then
             OPEN  emp_party_id_cur;
             FETCH emp_party_id_cur INTO l_person_party_id;
             CLOSE emp_party_id_cur;
          elsif (p_category = 'PARTY' OR p_category = 'PARTNER') then
             OPEN  partner_party_id_cur;
             FETCH partner_party_id_cur INTO l_person_party_id;
             CLOSE partner_party_id_cur;
          end if;

          /* Changed the code to call Wf_local_synch instead of Wf_Directory
             Fix for bug # 2671368 */
          AddParameterToList('USER_NAME',l_res_usr_role_name,l_list);
          AddParameterToList('DISPLAYNAME',p_resource_name,l_list);
          AddParameterToList('MAIL',p_email_address,l_list);
          AddParameterToList('ORCLISENABLED','ACTIVE',l_list);
          AddParameterToList('PERSON_PARTY_ID',l_person_party_id,l_list);

          Wf_local_synch.propagate_role(
                       p_orig_system           => l_res_usr_orig_system,
                       p_orig_system_id        => p_resource_id,
                       p_attributes            => l_list,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active);

          l_list.DELETE;

          Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => l_res_usr_orig_system,
                       p_user_orig_system_id   => p_resource_id,
                       p_role_orig_system      => l_res_usr_orig_system,
                       p_role_orig_system_id   => p_resource_id,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active);

      end if;  /* End of - looking for active resource at the time of creation */

    end if; /* End of - If the resource is not an EMPLOYEE, PARTY, PARTNER or SUPPLIER_CONTACT */
--    end if; /* End of - If the resource is not attached to an fnd user */

    IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    EXCEPTION when OTHERS then
       ROLLBACK TO cr_emp_wf_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
 END create_resource;

 PROCEDURE update_resource
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   NUMBER,
   P_RESOURCE_NAME        IN   VARCHAR2,
   P_USER_ID              IN   NUMBER,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE    IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';

   l_start_date_active  date  := trunc(p_start_date_active);
   l_end_date_active    date  := trunc(p_end_date_active);
   l_sysdate            date  := trunc(sysdate);

   cursor res_cur IS
   select resource_name, source_email, user_id, source_id, category,
          trunc(start_date_active) start_date_active,
          trunc(end_date_active) end_date_active
   from   jtf_rs_resource_extns_vl
   where  resource_id  = p_resource_id;

   res_rec  res_cur%rowtype;

   l_res_usr_orig_system wf_local_roles.orig_system%TYPE := 'JRES_IND';
   l_res_usr_role_name   wf_local_roles.name%TYPE := l_res_usr_orig_system||':'||to_char(p_resource_id);

   cursor res_wfrole_cur IS
   select name
   from   wf_local_roles
   where  name = l_res_usr_role_name
   and    orig_system = l_res_usr_orig_system
   and    orig_system_id = p_resource_id;

   l_role_name       wf_local_roles.name%TYPE;
   res_wfrole_exists varchar2(1) := 'N';

   cursor fnd_wfrole_cur(l_user_id number) IS
   select user_name
   from   fnd_user
   where  user_id = l_user_id;

   l_fnd_old_user_name               wf_local_roles.name%TYPE;
   l_fnd_new_user_name               wf_local_roles.name%TYPE;
   l_fnd_usr_old_orig_system         wf_local_roles.orig_system%TYPE;
   l_fnd_usr_new_orig_system         wf_local_roles.orig_system%TYPE;
   l_fnd_usr_old_orig_system_id      wf_local_roles.orig_system_id%TYPE;
   l_fnd_usr_new_orig_system_id      wf_local_roles.orig_system_id%TYPE;

   PROCEDURE create_wf_role_usr_role (ll_role_name            VARCHAR2,
                                      ll_role_orig_system     VARCHAR2,
                                      ll_role_orig_system_id  NUMBER,
                                      ll_role_display_name    VARCHAR2,
                                      ll_email_address        VARCHAR2,
                                      ll_start_date_active    DATE,
                                      ll_expiration_date      DATE,
                                      ll_source_id            NUMBER,
                                      ll_category             VARCHAR2) IS

   l_list           WF_PARAMETER_LIST_T;

   /* Cursor to get the party id of the employee */
   cursor emp_party_id_cur IS
   select party_id
   from   per_all_people_f ppf
   where  ppf.person_id = ll_source_id
   order by ppf.effective_start_date desc;

   l_person_party_id number;

   BEGIN

      /* Below If statement is to derive the party_id of the resource.
         If the category is not EMPLOYEE, PARTY or PARTNER, then party_id will be NULL */
      l_person_party_id := NULL;
      if ll_category = 'EMPLOYEE' then
         OPEN  emp_party_id_cur;
         FETCH emp_party_id_cur INTO l_person_party_id;
         CLOSE emp_party_id_cur;
      elsif (ll_category = 'PARTY' OR ll_category = 'PARTNER') then
         l_person_party_id := ll_source_id;
      end if;

      /* Changed the code to call Wf_local_synch instead of Wf_Directory
         Fix for bug # 2671368 */

      AddParameterToList('USER_NAME',ll_role_name,l_list);
      AddParameterToList('DISPLAYNAME',ll_role_display_name,l_list);
      AddParameterToList('MAIL',ll_email_address,l_list);
      AddParameterToList('ORCLISENABLED','ACTIVE',l_list);
      AddParameterToList('PERSON_PARTY_ID',l_person_party_id,l_list);

      Wf_local_synch.propagate_role(
                       p_orig_system           => ll_role_orig_system,
                       p_orig_system_id        => ll_role_orig_system_id,
                       p_attributes            => l_list,
                       p_start_date            => ll_start_date_active,
                       p_expiration_date       => ll_expiration_date);

      l_list.DELETE;

      Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => ll_role_orig_system,
                       p_user_orig_system_id   => ll_role_orig_system_id,
                       p_role_orig_system      => ll_role_orig_system,
                       p_role_orig_system_id   => ll_role_orig_system_id,
                       p_start_date            => ll_start_date_active,
                       p_expiration_date       => ll_expiration_date);

   EXCEPTION when others then
      null;
   END create_wf_role_usr_role;

   PROCEDURE update_wf_role (ll_role_name            VARCHAR2,
                             ll_role_orig_system     VARCHAR2,
                             ll_role_orig_system_id  NUMBER,
                             ll_role_display_name    VARCHAR2,
                             ll_email_address        VARCHAR2,
                             ll_status               VARCHAR2,
                             ll_start_date_active    DATE,
                             ll_expiration_date      DATE,
                             ll_source_id            NUMBER,
                             ll_category             VARCHAR2) IS
   l_list           WF_PARAMETER_LIST_T;

   /* Cursor to get the party id of the employee */
   cursor emp_party_id_cur IS
   select party_id
   from   per_all_people_f ppf
   where  ppf.person_id = ll_source_id
   order by ppf.effective_start_date desc;

   l_person_party_id number;

   BEGIN

      /* Below If statement is to derive the party_id of the resource.
         If the category is not EMPLOYEE, PARTY or PARTNER, then party_id will be NULL */
      l_person_party_id := NULL;
      if ll_category = 'EMPLOYEE' then
         OPEN  emp_party_id_cur;
         FETCH emp_party_id_cur INTO l_person_party_id;
         CLOSE emp_party_id_cur;
      elsif (ll_category = 'PARTY' OR ll_category = 'PARTNER') then
         l_person_party_id := ll_source_id;
      end if;

      /* Changed the code to call Wf_local_synch instead of Wf_Directory
         Fix for bug # 2671368 */

      if ((nvl(ll_expiration_date,l_sysdate) < l_sysdate)) then
         Wf_local_synch.propagate_user_role(
               p_user_orig_system      => ll_role_orig_system,
               p_user_orig_system_id   => ll_role_orig_system_id,
               p_role_orig_system      => ll_role_orig_system,
               p_role_orig_system_id   => ll_role_orig_system_id,
               p_start_date            => ll_start_date_active,
               p_expiration_date       => ll_expiration_date,
               p_overwrite             => TRUE);
      end if;
      AddParameterToList('USER_NAME',ll_role_name,l_list);
      AddParameterToList('DISPLAYNAME',ll_role_display_name,l_list);
      AddParameterToList('MAIL',ll_email_address,l_list);
      AddParameterToList('ORCLISENABLED',ll_status,l_list);
      AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);
      AddParameterToList('PERSON_PARTY_ID',l_person_party_id,l_list);

      Wf_local_synch.propagate_role(
               p_orig_system           => ll_role_orig_system,
               p_orig_system_id        => ll_role_orig_system_id,
               p_attributes            => l_list,
               p_start_date            => ll_start_date_active,
               p_expiration_date       => ll_expiration_date);

      l_list.DELETE;

      if ((nvl(ll_expiration_date,l_sysdate) >= l_sysdate)) then
         Wf_local_synch.propagate_user_role(
               p_user_orig_system      => ll_role_orig_system,
               p_user_orig_system_id   => ll_role_orig_system_id,
               p_role_orig_system      => ll_role_orig_system,
               p_role_orig_system_id   => ll_role_orig_system_id,
               p_start_date            => ll_start_date_active,
               p_expiration_date       => ll_expiration_date,
               p_overwrite             => TRUE);
      end if;

--   EXCEPTION when others then
--      null;
   END update_wf_role;

   PROCEDURE move_wf_user_role (ll_resource_id              VARCHAR2,
                                ll_start_date_active        DATE,
                                ll_end_date_active          DATE,
                                ll_old_user_name            VARCHAR2,
                                ll_old_user_orig_system     VARCHAR2,
                                ll_old_user_orig_system_id  NUMBER,
                                ll_new_user_name            VARCHAR2,
                                ll_new_user_orig_system     VARCHAR2,
                                ll_new_user_orig_system_id  NUMBER) IS

   CURSOR grp_cur IS
   SELECT mem.group_id, grp.group_number,
          trunc(grp.start_date_active) start_date_active,
          trunc(grp.end_date_active) end_date_active
   FROM   jtf_rs_group_members mem, jtf_rs_groups_b grp
   WHERE  mem.group_id = grp.group_id
   AND    nvl(mem.delete_flag,'N') <> 'Y'
   AND    l_sysdate between trunc(grp.start_date_active) and nvl(trunc(grp.end_date_active),l_sysdate)
   AND    mem.resource_id  = ll_resource_id;

   cursor grp_wfrole_cur(c_group_id number, c_grp_role_name varchar2) IS
   select name
   from   wf_local_roles
   where  name = c_grp_role_name
   and    orig_system = g_grp_orig_system
   and    orig_system_id = c_group_id;

   CURSOR team_cur IS
   SELECT mem.team_id,
          trunc(tm.start_date_active) start_date_active,
          trunc(tm.end_date_active) end_date_active
   FROM   jtf_rs_team_members mem, jtf_rs_teams_b tm
   WHERE  mem.team_id = tm.team_id
   AND    nvl(mem.delete_flag,'N') <> 'Y'
   AND    l_sysdate between trunc(tm.start_date_active) and nvl(trunc(tm.end_date_active),l_sysdate)
   AND    mem.team_resource_id  = ll_resource_id
   AND    mem.RESOURCE_TYPE = 'INDIVIDUAL';

   cursor tm_wfrole_cur(c_team_id number, c_team_role_name varchar2) IS
   select name
   from   wf_local_roles
   where  name = c_team_role_name
   and    orig_system = g_team_orig_system
   and    orig_system_id = c_team_id;

   l_grp_role_name            wf_local_roles.name%TYPE;
   l_team_role_name           wf_local_roles.name%TYPE;
   l_role_name                wf_local_user_roles.role_name%TYPE;
   l_role_orig_system_id      wf_local_user_roles.role_orig_system_id%TYPE;

   l_mem_role_start_date date;
   l_mem_role_end_date   date;
   l_g_miss_date         date := trunc(to_date('31-12-4712','DD-MM-YYYY'));

   BEGIN

      /* Changed the code to call Wf_local_synch instead of Wf_Directory
         Fix for bug # 2671368 */

      l_mem_role_start_date := sysdate;
      l_mem_role_end_date   := l_g_miss_date;

      /* Processing for Group members */
      for i in grp_cur LOOP
         l_role_orig_system_id := i.group_id;
         l_role_name := g_grp_orig_system ||':'|| to_char(l_role_orig_system_id);
         OPEN grp_wfrole_cur(l_role_orig_system_id,l_role_name);
         FETCH grp_wfrole_cur INTO l_grp_role_name;
         if grp_wfrole_cur%FOUND then /* If the group has a corresponding record in wf_local_user */
            if ll_old_user_orig_system is NOT NULL then
            BEGIN
               Wf_local_synch.propagate_user_role(
                 p_user_orig_system      => ll_old_user_orig_system,
                 p_user_orig_system_id   => ll_old_user_orig_system_id,
                 p_role_orig_system      => g_grp_orig_system,
                 p_role_orig_system_id   => l_role_orig_system_id,
      --         p_start_date            => sysdate,
                 p_expiration_date       => sysdate-1);

            EXCEPTION when others then
              null;
            END;
            end if;
            if ll_new_user_orig_system is NOT NULL then
            BEGIN

               l_mem_role_start_date := greatest(ll_start_date_active, i.start_date_active);
               l_mem_role_end_date   := least (nvl(ll_end_date_active, l_g_miss_date), nvl(i.end_date_active, l_g_miss_date));

               if (l_mem_role_end_date = l_g_miss_date) then
                  l_mem_role_end_date := NULL;
               end if;

--               get_user_role_dates
--                            (p_user_start_date         => ll_start_date_active,
--                             p_user_end_date           => ll_end_date_active,
--                             p_role_start_date         => i.start_date_active,
--                             p_role_end_date           => i.end_date_active,
--                             x_user_role_start_date    => l_mem_role_start_date,
--                             x_user_role_end_date      => l_mem_role_end_date);

               Wf_local_synch.propagate_user_role(
                            p_user_orig_system      => ll_new_user_orig_system,
                            p_user_orig_system_id   => ll_new_user_orig_system_id,
                            p_role_orig_system      => g_grp_orig_system,
                            p_role_orig_system_id   => l_role_orig_system_id,
                            p_start_date            => l_mem_role_start_date,
                            p_expiration_date       => l_mem_role_end_date,
                            p_overwrite             => TRUE);

            EXCEPTION when others then
              null;
            END;
            end if;
         end if; /* End of - If the group has a corresponding record in wf_local_user */
         CLOSE grp_wfrole_cur;
      END LOOP;

      l_mem_role_start_date := sysdate;
      l_mem_role_end_date   := l_g_miss_date;

      /* Processing for Team members */
      for i in team_cur LOOP
         l_role_orig_system_id := i.team_id;
         l_role_name := g_team_orig_system ||':'|| to_char(l_role_orig_system_id);
         OPEN tm_wfrole_cur(l_role_orig_system_id,l_role_name);
         FETCH tm_wfrole_cur INTO l_team_role_name;
         if tm_wfrole_cur%FOUND then /* If the team has a corresponding record in wf_local_user */
            if ll_old_user_orig_system is NOT NULL then
            BEGIN

               Wf_local_synch.propagate_user_role(
                            p_user_orig_system      => ll_old_user_orig_system,
                            p_user_orig_system_id   => ll_old_user_orig_system_id,
                            p_role_orig_system      => g_team_orig_system,
                            p_role_orig_system_id   => l_role_orig_system_id,
      --                    p_start_date            => sysdate,
                            p_expiration_date       => sysdate-1);

            EXCEPTION when others then
              null;
            END;
            end if;
            if ll_new_user_orig_system is NOT NULL then
            BEGIN

               l_mem_role_start_date := greatest(ll_start_date_active, i.start_date_active);
               l_mem_role_end_date   := least (nvl(ll_end_date_active, l_g_miss_date), nvl(i.end_date_active, l_g_miss_date));

               if (l_mem_role_end_date = l_g_miss_date) then
                  l_mem_role_end_date := NULL;
               end if;

--               get_user_role_dates
--                            (p_user_start_date         => ll_start_date_active,
--                             p_user_end_date           => ll_end_date_active,
--                             p_role_start_date         => i.start_date_active,
--                             p_role_end_date           => i.end_date_active,
--                             x_user_role_start_date    => l_mem_role_start_date,
--                             x_user_role_end_date      => l_mem_role_end_date);

               Wf_local_synch.propagate_user_role(
                            p_user_orig_system      => ll_new_user_orig_system,
                            p_user_orig_system_id   => ll_new_user_orig_system_id,
                            p_role_orig_system      => g_team_orig_system,
                            p_role_orig_system_id   => l_role_orig_system_id,
                            p_start_date            => l_mem_role_start_date,
                            p_expiration_date       => l_mem_role_end_date,
                            p_overwrite             => TRUE);

            EXCEPTION when others then
              null;
            END;
            end if;
         end if; /* End of - If the team has a corresponding record in wf_local_user */
         CLOSE tm_wfrole_cur;
      END LOOP;

   END move_wf_user_role;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint upd_emp_wf_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
    if p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    OPEN res_cur;
    FETCH res_cur INTO res_rec;

    /* there are some changes and not a past to past updation */
    if ( ( (res_rec.source_email <> p_email_address ) OR
           ((res_rec.source_email is NULL) AND (p_email_address is NOT NULL)) OR
           ((res_rec.source_email is NOT NULL) AND (p_email_address is NULL)) OR
--           (nvl(res_rec.user_id,-9999) <> nvl(p_user_id,-9999)) OR
           (res_rec.resource_name <> p_resource_name) OR
           (nvl(res_rec.end_date_active,fnd_api.g_miss_date) <> nvl(l_end_date_active,fnd_api.g_miss_date)) OR
           (res_rec.start_date_active <> l_start_date_active) )
         AND
         ( (nvl(res_rec.end_date_active,l_sysdate) >= l_sysdate) OR
           (nvl(l_end_date_active,l_sysdate) >= l_sysdate) )
       ) then

       OPEN res_wfrole_cur;
       FETCH res_wfrole_cur INTO l_role_name;
       if res_wfrole_cur%FOUND then /* If the resource has a corresponding record in wf_local_user */
          res_wfrole_exists := 'Y';
       end if; /* End of - If the resource has a corresponding record in wf_local_user */
       CLOSE res_wfrole_cur;

        /* Commented the below if condition to check the Resource validitiy.
           The new Wf_local_synch API accepts start and end date for roles and user roles */

--       /* If the Resource is VALID within the new date range */
--       if ( (l_start_date_active <= l_sysdate) AND
--            ((l_end_date_active >= l_sysdate) OR (l_end_date_active is NULL)) ) then

--xx          if (p_user_id is NULL) then  /* If p_user_id is NULL */
--xx
--xx             if res_rec.user_id IS NOT NULL then  /* If p_user_id is changed to NULL */
--xx
--xx               if res_wfrole_exists = 'N' then /* If the resource does not have a corresponding record in wf_local_user */
--xx                 create_wf_role_usr_role(ll_role_name   => l_res_usr_role_name,
--xx                                  ll_role_orig_system     => l_res_usr_orig_system,
--xx                                  ll_role_orig_system_id  => p_resource_id,
--xx                                  ll_role_display_name    => p_resource_name,
--xx                                  ll_email_address        => p_email_address,
--xx                                  ll_start_date_active    => l_start_date_active,
--xx                                  ll_expiration_date      => l_end_date_active,
--xx                                  ll_source_id            => res_rec.source_id,
--xx                                  ll_category             => res_rec.category);
--xx                else
--xx                   update_wf_role(ll_role_name            => l_res_usr_role_name,
--xx                                  ll_role_orig_system     => l_res_usr_orig_system,
--xx                                  ll_role_orig_system_id  => p_resource_id,
--xx                                  ll_role_display_name    => p_resource_name,
--xx                                  ll_email_address        => p_email_address,
--xx                                  ll_status               => 'ACTIVE',
--xx                                  ll_start_date_active    => l_start_date_active,
--xx                                  ll_expiration_date      => l_end_date_active,
--xx                                  ll_source_id            => res_rec.source_id,
--xx                                  ll_category             => res_rec.category);
--xx                end if; /* If the resource has a record in wf_local_user */

--xx                OPEN fnd_wfrole_cur(res_rec.user_id);
--xx                FETCH fnd_wfrole_cur INTO l_fnd_old_user_name;
--xx                CLOSE fnd_wfrole_cur;
--xx
--xx                Wf_Directory.GetRoleOrigSysInfo(
--xx                             l_fnd_old_user_name,
--xx                             l_fnd_usr_old_orig_system,
--xx                             l_fnd_usr_old_orig_system_id);
--xx
--xx                move_wf_user_role(ll_resource_id          => p_resource_id,
--xx                              ll_start_date_active        => l_start_date_active,
--xx                              ll_end_date_active          => l_end_date_active,
--xx                              ll_old_user_name            => l_fnd_old_user_name,
--xx                              ll_old_user_orig_system     => l_fnd_usr_old_orig_system,
--xx                              ll_old_user_orig_system_id  => l_fnd_usr_old_orig_system_id, /* res_rec.user_id */
--xx                              ll_new_user_name            => l_res_usr_role_name,
--xx                              ll_new_user_orig_system     => l_res_usr_orig_system,
--xx                              ll_new_user_orig_system_id  => p_resource_id);
--xx
--xx             else /* If p_user_id is already NULL, no change user_id */

                if ((l_sysdate not between l_start_date_active and nvl(l_end_date_active,l_sysdate)) AND
                         (l_sysdate between res_rec.start_date_active and  nvl(res_rec.end_date_active,l_sysdate))) then
                       /* above if is to find out if the resource is changed from active to inactive */
                   if res_wfrole_exists = 'Y' then

                      /* following procedure will end date all the user roles for the resource */
                      move_wf_user_role(ll_resource_id              => p_resource_id,
                                        ll_start_date_active        => l_start_date_active,
                                        ll_end_date_active          => l_end_date_active,
                                        ll_old_user_name            => l_res_usr_role_name,
                                        ll_old_user_orig_system     => l_res_usr_orig_system,
                                        ll_old_user_orig_system_id  => p_resource_id,
                                        ll_new_user_name            => NULL,
                                        ll_new_user_orig_system     => NULL,
                                        ll_new_user_orig_system_id  => NULL);

                      /* following procedure will update the roles with latest info */
                      update_wf_role(ll_role_name            => l_res_usr_role_name,
                                     ll_role_orig_system     => l_res_usr_orig_system,
                                     ll_role_orig_system_id  => p_resource_id,
                                     ll_role_display_name    => p_resource_name,
                                     ll_email_address        => p_email_address,
                                     ll_status               => 'ACTIVE',
                                     ll_start_date_active    => l_start_date_active,
                                     ll_expiration_date      => l_end_date_active,
                                     ll_source_id            => res_rec.source_id,
                                     ll_category             => res_rec.category);
                   end if;
                else
                   if res_wfrole_exists = 'N' then
                      /* If the resource does not have a corresponding record in wf_local_user */
                      create_wf_role_usr_role(ll_role_name   => l_res_usr_role_name,
                                     ll_role_orig_system     => l_res_usr_orig_system,
                                     ll_role_orig_system_id  => p_resource_id,
                                     ll_role_display_name    => p_resource_name,
                                     ll_email_address        => p_email_address,
                                     ll_start_date_active    => l_start_date_active,
                                     ll_expiration_date      => l_end_date_active,
                                     ll_source_id            => res_rec.source_id,
                                     ll_category             => res_rec.category);
                   else
                      /* following procedure will update the wf_local_user with latest info */
                      update_wf_role(ll_role_name            => l_res_usr_role_name,
                                     ll_role_orig_system     => l_res_usr_orig_system,
                                     ll_role_orig_system_id  => p_resource_id,
                                     ll_role_display_name    => p_resource_name,
                                     ll_email_address        => p_email_address,
                                     ll_status               => 'ACTIVE',
                                     ll_start_date_active    => l_start_date_active,
                                     ll_expiration_date      => l_end_date_active,
                                     ll_source_id            => res_rec.source_id,
                                     ll_category             => res_rec.category);
                   end if; /* End of - If the resource does not have a corresponding record in wf_local_user */

                   /* following procedure will reactivate all the user roles for the resource
                      if the resource any of the resource dates are changed. */
                   if ((l_start_date_active <> res_rec.start_date_active) OR
                       (l_end_date_active is null and res_rec.end_date_active is not null) OR
                       (l_end_date_active is not null and res_rec.end_date_active is null)) THEN
                      move_wf_user_role(ll_resource_id              => p_resource_id,
                                        ll_start_date_active        => l_start_date_active,
                                        ll_end_date_active          => l_end_date_active,
                                        ll_old_user_name            => NULL,
                                        ll_old_user_orig_system     => NULL,
                                        ll_old_user_orig_system_id  => NULL,
                                        ll_new_user_name            => l_res_usr_role_name,
                                        ll_new_user_orig_system     => l_res_usr_orig_system,
                                        ll_new_user_orig_system_id  => p_resource_id);
                   end if;
                end if;

--xx             end if; /* If p_user_id is already NULL or changed to NULL */
--xx          else /* If p_user_id is NOT NULL */
--xx
--xx             if (res_rec.user_id is NULL) then  /* If res_rec.user_id is NULL */
--xx
--xx                OPEN fnd_wfrole_cur(p_user_id);
--xx                FETCH fnd_wfrole_cur INTO l_fnd_new_user_name;
--xx                CLOSE fnd_wfrole_cur;
--xx
--xx                Wf_Directory.GetRoleOrigSysInfo(
--xx                             l_fnd_new_user_name,
--xx                             l_fnd_usr_new_orig_system,
--xx                             l_fnd_usr_new_orig_system_id);
--xx
--xx                move_wf_user_role(ll_resource_id          => p_resource_id,
--xx                              ll_start_date_active        => l_start_date_active,
--xx                              ll_end_date_active          => l_end_date_active,
--xx                              ll_old_user_name            => l_res_usr_role_name,
--xx                              ll_old_user_orig_system     => l_res_usr_orig_system,
--xx                              ll_old_user_orig_system_id  => p_resource_id,
--xx                              ll_new_user_name            => l_fnd_new_user_name,
--xx                              ll_new_user_orig_system     => l_fnd_usr_new_orig_system,
--xx                              ll_new_user_orig_system_id  => l_fnd_usr_new_orig_system_id); /* p_user_id */
--xx
--xx                /* If the resource does not have a corresponding record in wf_local_user */
--xx                if res_wfrole_exists = 'Y' then
--xx                   update_wf_role(ll_role_name            => l_res_usr_role_name,
--xx                                  ll_role_orig_system     => l_res_usr_orig_system,
--xx                                  ll_role_orig_system_id  => p_resource_id,
--xx                                  ll_role_display_name    => p_resource_name,
--xx                                  ll_email_address        => p_email_address,
--xx                                  ll_status               => 'INACTIVE',
--xx                                  ll_start_date_active    => l_start_date_active,
--xx                                  ll_expiration_date      => l_sysdate-1,
--xx                                  ll_source_id            => res_rec.source_id,
--xx                                  ll_category             => res_rec.category);
--xx
--xx
--xx                end if; /* End of - If the resource does not have a corresponding record in wf_local_user */
--xx
--xx             else  /* If res_rec.user_id is NOT NULL */
--xx
--xx               if (res_rec.user_id <> p_user_id) then  /* If user_id is changed from one value to another value */
--xx
--xx                   OPEN fnd_wfrole_cur(res_rec.user_id);
--xx                   FETCH fnd_wfrole_cur INTO l_fnd_old_user_name;
--xx                   CLOSE fnd_wfrole_cur;
--xx                   Wf_Directory.GetRoleOrigSysInfo(
--xx                                l_fnd_old_user_name,
--xx                                l_fnd_usr_old_orig_system,
--xx                                l_fnd_usr_old_orig_system_id);
--xx
--xx                   OPEN fnd_wfrole_cur(p_user_id);
--xx                   FETCH fnd_wfrole_cur INTO l_fnd_new_user_name;
--xx                   CLOSE fnd_wfrole_cur;
--xx                   Wf_Directory.GetRoleOrigSysInfo(
--xx                                l_fnd_new_user_name,
--xx                                l_fnd_usr_new_orig_system,
--xx                                l_fnd_usr_new_orig_system_id);
--xx
--xx                   move_wf_user_role(ll_resource_id              => p_resource_id,
--xx                                     ll_start_date_active        => l_start_date_active,
--xx                                     ll_end_date_active          => l_end_date_active,
--xx                                     ll_old_user_name            => l_fnd_old_user_name,
--xx                                     ll_old_user_orig_system     => l_fnd_usr_old_orig_system,
--xx                                     ll_old_user_orig_system_id  => l_fnd_usr_old_orig_system_id, /*  res_rec.user_id */
--xx                                     ll_new_user_name            => l_fnd_new_user_name,
--xx                                     ll_new_user_orig_system     => l_fnd_usr_new_orig_system,
--xx                                     ll_new_user_orig_system_id  => l_fnd_usr_new_orig_system_id); /* p_user_id */
--xx                else /* User id is NOT NULL and no change. So, no need to update the local roles.
--xx                        only end date the user role if the resource is inacticated and
--xx                        reactivate the user role if the resource is acticated */
--xx
--xx                    /* below if is to find out if there a change in resource dates
--xx                       if there is no change, the no need to update the user roles table */
--xx                   if ((l_start_date_active <> res_rec.start_date_active) OR
--xx                       (l_end_date_active is null and res_rec.end_date_active is not null) OR
--xx                       (l_end_date_active is not null and res_rec.end_date_active is null)) THEN
--xx
--xx                      OPEN fnd_wfrole_cur(p_user_id);
--xx                      FETCH fnd_wfrole_cur INTO l_fnd_new_user_name;
--xx                      CLOSE fnd_wfrole_cur;
--xx                      Wf_Directory.GetRoleOrigSysInfo(
--xx                                l_fnd_new_user_name,
--xx                                l_fnd_usr_new_orig_system,
--xx                                l_fnd_usr_new_orig_system_id);
--xx
--xx                      /* following procedure will reactivate all the user roles for the resource */
--xx                      move_wf_user_role(ll_resource_id              => p_resource_id,
--xx                                        ll_start_date_active        => l_start_date_active,
--xx                                        ll_end_date_active          => l_end_date_active,
--xx                                        ll_old_user_name            => NULL,
--xx                                        ll_old_user_orig_system     => NULL,
--xx                                        ll_old_user_orig_system_id  => NULL,
--xx                                        ll_new_user_name            => l_fnd_new_user_name,
--xx                                        ll_new_user_orig_system     => l_fnd_usr_new_orig_system,
--xx                                        ll_new_user_orig_system_id  => l_fnd_usr_new_orig_system_id);
--xx
--xx                   end if;
--xx
--                   if ((l_sysdate between l_start_date_active and nvl(l_end_date_active,l_sysdate)) AND
--                      (l_sysdate not between res_rec.start_date_active and nvl(res_rec.end_date_active,l_sysdate))) then
--                      /* above if is to find out if the resource is changed from inactive to active */
--
--                     OPEN fnd_wfrole_cur(p_user_id);
--                     FETCH fnd_wfrole_cur INTO l_fnd_new_user_name;
--                     CLOSE fnd_wfrole_cur;
--                     Wf_Directory.GetRoleOrigSysInfo(
--                               l_fnd_new_user_name,
--                               l_fnd_usr_new_orig_system,
--                               l_fnd_usr_new_orig_system_id);
--
--                     /* following procedure will reactivate all the user roles for the resource */
--                     move_wf_user_role(ll_resource_id              => p_resource_id,
--                                       ll_start_date_active        => l_start_date_active,
--                                       ll_end_date_active          => l_end_date_active,
--                                       ll_old_user_name            => NULL,
--                                       ll_old_user_orig_system     => NULL,
--                                       ll_old_user_orig_system_id  => NULL,
--                                       ll_new_user_name            => l_fnd_new_user_name,
--                                       ll_new_user_orig_system     => l_fnd_usr_new_orig_system,
--                                       ll_new_user_orig_system_id  => l_fnd_usr_new_orig_system_id);
 --                 elsif ((l_sysdate not between l_start_date_active and nvl(l_end_date_active,l_sysdate)) AND
--                         (l_sysdate between res_rec.start_date_active and  nvl(res_rec.end_date_active,l_sysdate))) then
--                      /* above if is to find out if the resource is changed from active to inactive */
--
--                     OPEN fnd_wfrole_cur(p_user_id);
--                     FETCH fnd_wfrole_cur INTO l_fnd_old_user_name;
--                     CLOSE fnd_wfrole_cur;
--                     Wf_Directory.GetRoleOrigSysInfo(
--                               l_fnd_old_user_name,
--                               l_fnd_usr_old_orig_system,
--                               l_fnd_usr_old_orig_system_id);
--
--                     /* following procedure will end date all the user roles for the resource */
--                     move_wf_user_role(ll_resource_id              => p_resource_id,
--                                       ll_start_date_active        => l_start_date_active,
--                                       ll_end_date_active          => l_end_date_active,
--                                       ll_old_user_name            => l_fnd_old_user_name,
--                                       ll_old_user_orig_system     => l_fnd_usr_old_orig_system,
--                                       ll_old_user_orig_system_id  => l_fnd_usr_old_orig_system_id,
--                                       ll_new_user_name            => NULL,
--                                       ll_new_user_orig_system     => NULL,
--                                       ll_new_user_orig_system_id  => NULL);
--                  end if;
--xx                end if; /* If user_id is changed/not changed from one value to another value */
--xx             end if; /* If res_rec.user_id is NULL or NOT NULL */
--xx          end if; /* If p_user_id is NULL or NOT NULL*/
    end if; /* there are some changes and not a future to future updation  */

    CLOSE res_cur;

    IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    EXCEPTION when OTHERS then
       ROLLBACK TO upd_emp_wf_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END update_resource;

 PROCEDURE delete_resource
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE';

   l_sysdate             date  := trunc(sysdate);

   l_res_usr_orig_system     wf_local_roles.orig_system%TYPE := 'JRES_IND';
   l_res_usr_role_name       wf_local_roles.name%TYPE := l_res_usr_orig_system||':'||to_char(p_resource_id);

   CURSOR res_user_role_cur IS
   SELECT role_name, role_orig_system, role_orig_system_id
   FROM   wf_local_user_roles
   WHERE  user_name = l_res_usr_role_name
   AND    user_orig_system = l_res_usr_orig_system
   AND    user_orig_system_id = p_resource_id
   AND    role_name <> l_res_usr_role_name;

   l_list           WF_PARAMETER_LIST_T;

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint del_emp_wf_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
    if p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

       for i in res_user_role_cur LOOP
          Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => l_res_usr_orig_system,
                       p_user_orig_system_id   => p_resource_id,
                       p_role_orig_system      => i.role_orig_system,
                       p_role_orig_system_id   => i.role_orig_system_id,
                       p_expiration_date       => l_sysdate-1);

       END LOOP;

          /* Changed the code to call Wf_local_synch instead of Wf_Directory
             Fix for bug # 2671368 */

          AddParameterToList('USER_NAME',l_res_usr_role_name,l_list);
          AddParameterToList('RAISEERRORS','TRUE',l_list);
          AddParameterToList('DELETE','TRUE',l_list);

          Wf_local_synch.propagate_role(
                       p_orig_system           => l_res_usr_orig_system,
                       p_orig_system_id        => p_resource_id,
                       p_attributes            => l_list,
                       p_expiration_date       => l_sysdate-1);

          l_list.DELETE;

    IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    EXCEPTION when OTHERS then
       ROLLBACK TO del_emp_wf_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
 END delete_resource;

  PROCEDURE create_resource_group
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_GROUP_ID             IN   NUMBER,
   P_GROUP_NAME           IN   VARCHAR2,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE    IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) IS
     l_api_version         CONSTANT NUMBER := 1.0;
     l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_GROUP';
     l_grp_role_name       wf_local_roles.name%TYPE := g_grp_orig_system||':'||to_char(p_group_id);
     l_start_date_active   date := trunc(P_START_DATE_ACTIVE);
     l_end_date_active   date := trunc(P_END_DATE_ACTIVE);
     l_sysdate date := trunc(sysdate);

     l_list           WF_PARAMETER_LIST_T;

   BEGIN
     SAVEPOINT wf_int_create_resource_group;
     x_return_status := fnd_api.g_ret_sts_success;

     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     IF p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
     END IF;

--     if (l_start_date_active <= l_sysdate AND
--          (l_end_date_active is null OR
--          l_end_date_active >= l_sysdate)) THEN
     if ((l_end_date_active >= l_sysdate) OR (l_end_date_active is NULL)) then
     /* Create role only if the group is currently active or future active*/

          /* Changed the code to call Wf_local_synch instead of Wf_Directory
             Fix for bug # 2671368 */

          AddParameterToList('USER_NAME',l_grp_role_name,l_list);
          AddParameterToList('DISPLAYNAME',p_group_name,l_list);
          AddParameterToList('MAIL',p_email_address,l_list);
          AddParameterToList('ORCLISENABLED','ACTIVE',l_list);
          AddParameterToList('RAISEERRORS','TRUE',l_list);

          Wf_local_synch.propagate_role(
                       p_orig_system           => g_grp_orig_system,
                       p_orig_system_id        => p_group_id,
                       p_attributes            => l_list,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active);

          l_list.DELETE;

          Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => g_grp_orig_system,
                       p_user_orig_system_id   => p_group_id,
                       p_role_orig_system      => g_grp_orig_system,
                       p_role_orig_system_id   => p_group_id,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active);

     END IF;

     IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

   EXCEPTION
    WHEN OTHERS THEN
    /* Since we don't care about
       the errors/exceptions in WF API, we are just catching when OTHERS */
--      DBMS_OUTPUT.put_line (' ========================================== ');
--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Group Pvt ========= ');
--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO wf_int_create_resource_group;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;


   PROCEDURE update_resource_group
   (P_API_VERSION          IN   NUMBER,
    P_INIT_MSG_LIST        IN   VARCHAR2,
    P_COMMIT               IN   VARCHAR2,
    P_GROUP_ID             IN   NUMBER,
    P_GROUP_NAME           IN   VARCHAR2,
    P_EMAIL_ADDRESS        IN   VARCHAR2,
    P_START_DATE_ACTIVE    IN   DATE,
    P_END_DATE_ACTIVE      IN   DATE,
    X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT            OUT NOCOPY  NUMBER,
    X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) IS
     l_api_version         CONSTANT NUMBER := 1.0;
     l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_GROUP';
     l_grp_role_name       wf_local_roles.name%TYPE := g_grp_orig_system||':'||to_char(p_group_id);
     l_start_date_active   date := trunc(P_START_DATE_ACTIVE);
     l_end_date_active   date := trunc(P_END_DATE_ACTIVE);
     l_sysdate date := trunc(sysdate);
     l_g_miss_date         date := trunc(to_date('31-12-4712','DD-MM-YYYY'));

     CURSOR C_ROLE_EXISTS (P_NAME IN VARCHAR2, P_ORG_SYS IN VARCHAR2, P_ORG_SYS_ID IN NUMBER) IS
       SELECT 'Y'
       FROM WF_LOCAL_ROLES
       WHERE NAME = P_NAME AND
	 ORIG_SYSTEM_ID = P_ORG_SYS_ID AND
	 ORIG_SYSTEM = P_ORG_SYS;

     CURSOR C_GRP_OLD_VALS(P_GROUP_ID IN NUMBER) IS
       SELECT EMAIL_ADDRESS, GROUP_NAME, trunc(START_DATE_ACTIVE) START_DATE_ACTIVE, trunc(END_DATE_ACTIVE) END_DATE_ACTIVE
       FROM JTF_RS_GROUPS_VL WHERE GROUP_ID = P_GROUP_ID;

     l_old_grp_vals C_GRP_OLD_VALS%ROWTYPE;
     l_check_role varchar2(1);

     CURSOR grp_mem_cur IS
     SELECT mem.resource_id,
            greatest(l_start_date_active, res.start_date_active) grp_mem_start_date,
            least (nvl(l_end_date_active, l_g_miss_date), nvl(res.end_date_active, l_g_miss_date)) grp_mem_end_date
     FROM   jtf_rs_group_members mem, jtf_rs_groups_b grp, jtf_rs_resource_extns res
     WHERE  mem.group_id = grp.group_id
     AND    mem.resource_id = res.resource_id
     AND    nvl(mem.delete_flag,'N') <> 'Y'
     AND    l_sysdate between trunc(res.start_date_active) and nvl(trunc(res.end_date_active),l_sysdate)
     AND    mem.group_id  = p_group_id;

     CURSOR grp_as_team_mem_cur IS
     SELECT mem.team_id,
            trunc(tm.start_date_active) start_date_active,
            trunc(tm.end_date_active) end_date_active
     FROM   jtf_rs_team_members mem, jtf_rs_teams_b tm
     WHERE  mem.team_id = tm.team_id
     AND    nvl(mem.delete_flag,'N') <> 'Y'
--     AND    l_sysdate between trunc(tm.start_date_active) and nvl(trunc(tm.end_date_active),l_sysdate)
     AND    mem.team_resource_id  = p_group_id
     AND    mem.RESOURCE_TYPE = 'GROUP';

     l_grp_mem_user_name           wf_local_roles.name%TYPE;
     l_grp_mem_orig_system         wf_local_roles.orig_system%TYPE;
     l_grp_mem_orig_system_id      wf_local_roles.orig_system_id%TYPE;

     l_mem_role_start_date         date;
     l_mem_role_end_date           date;

     l_list           WF_PARAMETER_LIST_T;

   BEGIN
     SAVEPOINT wf_int_update_resource_group;
     x_return_status := fnd_api.g_ret_sts_success;

     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     IF p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
     END IF;

     /* Role record exists then update if group name, email, start date
        or end date is changed */
      OPEN C_GRP_OLD_VALS(p_group_id);
      FETCH C_GRP_OLD_VALS into l_old_grp_vals;

      IF C_GRP_OLD_VALS%FOUND AND
         (P_GROUP_NAME <> l_old_grp_vals.group_name OR
         (P_EMAIL_ADDRESS is null and
          l_old_grp_vals.email_address is not null) OR
         (P_EMAIL_ADDRESS is not null and
          l_old_grp_vals.email_address is null) OR
         P_EMAIL_ADDRESS <> l_old_grp_vals.email_address OR
         L_START_DATE_ACTIVE <> l_old_grp_vals.start_date_active OR
         (L_END_DATE_ACTIVE is null and
          l_old_grp_vals.end_date_active is not null) OR
         (L_END_DATE_ACTIVE is not null and
          l_old_grp_vals.end_date_active is null) OR
         L_END_DATE_ACTIVE <> l_old_grp_vals.end_date_active) AND
         ((nvl(l_old_grp_vals.end_date_active,l_sysdate) >= l_sysdate) OR
          (nvl(l_end_date_active,l_sysdate) >= l_sysdate)) THEN
           /* If any of the above is changed and the group old/new end_date is >= l_sysdate, then update the group */

          if ((nvl(l_end_date_active,l_sysdate) >= l_sysdate)) then

             AddParameterToList('USER_NAME',l_grp_role_name,l_list);
             AddParameterToList('DISPLAYNAME',p_group_name,l_list);
             AddParameterToList('MAIL',p_email_address,l_list);
             AddParameterToList('ORCLISENABLED','ACTIVE',l_list);
             AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);

             Wf_local_synch.propagate_role(
                       p_orig_system           => g_grp_orig_system,
                       p_orig_system_id        => p_group_id,
                       p_attributes            => l_list,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active);

             l_list.DELETE;

             Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => g_grp_orig_system,
                       p_user_orig_system_id   => p_group_id,
                       p_role_orig_system      => g_grp_orig_system,
                       p_role_orig_system_id   => p_group_id,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active,
                       p_overwrite             => TRUE);
          end if;
          if ((l_start_date_active <> l_old_grp_vals.start_date_active) OR
              (l_end_date_active is null and l_old_grp_vals.end_date_active is not null) OR
              (l_end_date_active is not null and l_old_grp_vals.end_date_active is null)) THEN
              /* above if is to find out if there a change in group dates */

             for i in grp_mem_cur LOOP
                jtf_rs_wf_integration_pub.get_wf_role(P_RESOURCE_ID => i.resource_id,
                                               X_ROLE_NAME => l_grp_mem_user_name,
                                               X_ORIG_SYSTEM => l_grp_mem_orig_system,
                                               X_ORIG_SYSTEM_ID => l_grp_mem_orig_system_id);
                if (i.grp_mem_end_date = l_g_miss_date) then
                   l_mem_role_end_date := NULL;
                else
                   l_mem_role_end_date := i.grp_mem_end_date;
                end if;

                IF l_grp_mem_user_name is not null THEN
                   Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => l_grp_mem_orig_system,
                       p_user_orig_system_id   => l_grp_mem_orig_system_id,
                       p_role_orig_system      => g_grp_orig_system,
                       p_role_orig_system_id   => p_group_id,
                       p_start_date            => i.grp_mem_start_date,
                       p_expiration_date       => l_mem_role_end_date,
                       p_overwrite             => TRUE);
                END IF;
             END LOOP;

             for j in grp_as_team_mem_cur LOOP
                l_mem_role_start_date := greatest(l_start_date_active, j.start_date_active);
                l_mem_role_end_date   := least (nvl(l_end_date_active, l_g_miss_date), nvl(j.end_date_active, l_g_miss_date));

                if (l_mem_role_end_date = l_g_miss_date) then
                   l_mem_role_end_date := NULL;
                end if;

                l_check_role := 'N';
                OPEN c_role_exists(g_team_orig_system||':'||to_char(j.team_id), g_team_orig_system, j.team_id);
                FETCH c_role_exists into l_check_role;
                CLOSE c_role_exists;

                IF (l_check_role = 'Y') THEN
                   Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => g_grp_orig_system,
                       p_user_orig_system_id   => p_group_id,
                       p_role_orig_system      => g_team_orig_system,
                       p_role_orig_system_id   => j.team_id,
                       p_start_date            => l_mem_role_start_date,
                       p_expiration_date       => l_mem_role_end_date,
                       p_overwrite             => TRUE);
                END IF;
             END LOOP;
         end if;
         if ((nvl(l_end_date_active,l_sysdate) < l_sysdate)) then

            Wf_local_synch.propagate_user_role(
                      p_user_orig_system      => g_grp_orig_system,
                      p_user_orig_system_id   => p_group_id,
                      p_role_orig_system      => g_grp_orig_system,
                      p_role_orig_system_id   => p_group_id,
                      p_start_date            => l_start_date_active,
                      p_expiration_date       => l_end_date_active,
                      p_overwrite             => TRUE);

            AddParameterToList('USER_NAME',l_grp_role_name,l_list);
            AddParameterToList('DISPLAYNAME',p_group_name,l_list);
            AddParameterToList('MAIL',p_email_address,l_list);
            AddParameterToList('ORCLISENABLED','ACTIVE',l_list);
            AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);

            Wf_local_synch.propagate_role(
                      p_orig_system           => g_grp_orig_system,
                      p_orig_system_id        => p_group_id,
                      p_attributes            => l_list,
                      p_start_date            => l_start_date_active,
                      p_expiration_date       => l_end_date_active);

            l_list.DELETE;

         end if;

         END IF; /* C_GRP_OLD_VALS%FOUND .. */

     IF c_grp_old_vals%ISOPEN THEN
       CLOSE c_grp_old_vals;
     END IF;

     IF c_role_exists%ISOPEN THEN
       CLOSE c_role_exists;
     END IF;

     IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
    /* Since we don't care about
       the errors/exceptions in WF API, we are just catching when OTHERS */
--       DBMS_OUTPUT.put_line (' ========================================== ');
--       DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Resource Group Pvt ========= ');
--       DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

       IF c_grp_old_vals%ISOPEN THEN
	 CLOSE c_grp_old_vals;
       END IF;

       IF c_role_exists%ISOPEN THEN
	 CLOSE c_role_exists;
       END IF;

       ROLLBACK TO wf_int_update_resource_group;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  END;


  PROCEDURE create_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) IS
     l_api_version         CONSTANT NUMBER := 1.0;
     l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_GROUP_MEMBERS';
     l_grp_role_name       wf_local_roles.name%TYPE := g_grp_orig_system||':'||to_char(p_group_id);
     l_sysdate date := trunc(sysdate);

     CURSOR C_ROLE_EXISTS (P_NAME IN VARCHAR2, P_ORG_SYS IN VARCHAR2, P_ORG_SYS_ID IN NUMBER) IS
       SELECT 'Y'
       FROM WF_LOCAL_ROLES
       WHERE NAME = P_NAME AND
	 ORIG_SYSTEM_ID = P_ORG_SYS_ID AND
	 ORIG_SYSTEM = P_ORG_SYS;

     CURSOR c_grp_active (p_group_id IN NUMBER) IS
        SELECT trunc(START_DATE_ACTIVE) START_DATE_ACTIVE,
               trunc(END_DATE_ACTIVE) END_DATE_ACTIVE
        FROM JTF_RS_GROUPS_B
        WHERE GROUP_ID = P_GROUP_ID AND
             trunc(START_DATE_ACTIVE) <= l_sysdate AND
             NVL(trunc(END_DATE_ACTIVE), l_sysdate) >= l_sysdate;

     CURSOR c_res_active (p_resource_id IN NUMBER) IS
        SELECT trunc(START_DATE_ACTIVE) START_DATE_ACTIVE,
               trunc(END_DATE_ACTIVE) END_DATE_ACTIVE
        FROM JTF_RS_RESOURCE_EXTNS
        WHERE RESOURCE_ID = P_RESOURCE_ID AND
             trunc(START_DATE_ACTIVE) <= l_sysdate AND
             NVL(trunc(END_DATE_ACTIVE), l_sysdate) >= l_sysdate;

     l_group_role_exists c_role_exists%ROWTYPE;
     l_grp_active c_grp_active%ROWTYPE;
     l_res_active c_res_active%ROWTYPE;

     l_user_name wf_local_roles.name%TYPE;
     l_orig_system wf_local_roles.orig_system%TYPE;
     l_orig_system_id wf_local_roles.orig_system_id%TYPE;

     l_mem_role_start_date date;
     l_mem_role_end_date   date;
     l_g_miss_date         date := trunc(to_date('31-12-4712','DD-MM-YYYY'));

   BEGIN
     SAVEPOINT wf_int_cr_res_grp_mbr;
     x_return_status := fnd_api.g_ret_sts_success;

     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     IF p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
     END IF;

     OPEN c_grp_active(p_group_id);
     FETCH c_grp_active INTO l_grp_active;

     IF (c_grp_active%FOUND) THEN
       OPEN c_res_active(p_resource_id);
       FETCH c_res_active INTO l_res_active;
       IF (c_res_active%FOUND) THEN

          l_mem_role_start_date := greatest(l_res_active.start_date_active, l_grp_active.start_date_active);
          l_mem_role_end_date   := least (nvl(l_res_active.end_date_active, l_g_miss_date), nvl(l_grp_active.end_date_active, l_g_miss_date));

          if (l_mem_role_end_date = l_g_miss_date) then
             l_mem_role_end_date := NULL;
          end if;

--          get_user_role_dates
--                           (p_user_start_date         => l_res_active.start_date_active,
--                            p_user_end_date           => l_res_active.end_date_active,
--                            p_role_start_date         => l_grp_active.start_date_active,
--                            p_role_end_date           => l_grp_active.end_date_active,
--                            x_user_role_start_date    => l_mem_role_start_date,
--                            x_user_role_end_date      => l_mem_role_end_date);

       /* Group as well as resource are active */
       OPEN c_role_exists(l_grp_role_name, g_grp_orig_system, p_group_id);
       FETCH c_role_exists into l_group_role_exists;
       IF (c_role_exists%FOUND) THEN
	 jtf_rs_wf_integration_pub.get_wf_role(P_RESOURCE_ID => P_RESOURCE_ID,
					       X_ROLE_NAME => l_user_name,
					       X_ORIG_SYSTEM => l_orig_system,
					       X_ORIG_SYSTEM_ID => l_orig_system_id);


	 IF l_user_name is not null THEN
          Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => l_orig_system,
                       p_user_orig_system_id   => l_orig_system_id,
                       p_role_orig_system      => g_grp_orig_system,
                       p_role_orig_system_id   => p_group_id,
                       p_start_date            => l_mem_role_start_date,
                       p_expiration_date       => l_mem_role_end_date,
                       p_overwrite             => TRUE);
	 END IF;
       END IF;
       CLOSE c_role_exists;
       END IF;
       CLOSE c_res_active;
     END IF;

     CLOSE c_grp_active;

     IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

   EXCEPTION
    WHEN OTHERS THEN
    /* Since we don't care about
       the errors/exceptions in WF API, we are just catching when OTHERS */
--      DBMS_OUTPUT.put_line (' ========================================== ');
--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Group Member Pvt ========= ');
--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      IF c_role_exists%ISOPEN THEN
	CLOSE c_role_exists;
      END IF;

      IF c_grp_active%ISOPEN THEN
	CLOSE c_grp_active;
      END IF;

      IF c_res_active%ISOPEN THEN
	CLOSE c_res_active;
      END IF;

      ROLLBACK TO wf_int_cr_res_grp_mbr;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

  PROCEDURE delete_resource_group_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) IS
     l_api_version         CONSTANT NUMBER := 1.0;
     l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_GROUP_MEMBERS';
     l_grp_role_name       wf_local_roles.name%TYPE := g_grp_orig_system||':'||to_char(p_group_id);

     l_user_name wf_local_roles.name%TYPE;
     l_orig_system wf_local_roles.orig_system%TYPE;
     l_orig_system_id wf_local_roles.orig_system_id%TYPE;
   BEGIN
     SAVEPOINT wf_int_del_res_grp_mbr;
     x_return_status := fnd_api.g_ret_sts_success;

     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     IF p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
     END IF;

     jtf_rs_wf_integration_pub.get_wf_role(P_RESOURCE_ID => P_RESOURCE_ID,
					   X_ROLE_NAME => l_user_name,
					   X_ORIG_SYSTEM => l_orig_system,
					   X_ORIG_SYSTEM_ID => l_orig_system_id);

     IF l_user_name is not null THEN

          /* Changed the code to call Wf_local_synch instead of Wf_Directory
             Fix for bug # 2671368 */

       Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => l_orig_system,
                       p_user_orig_system_id   => l_orig_system_id,
                       p_role_orig_system      => g_grp_orig_system,
                       p_role_orig_system_id   => p_group_id,
              --         p_start_date            => sysdate,
                       p_expiration_date       => sysdate-1);
     END IF;


     IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

   EXCEPTION
    WHEN OTHERS THEN
    /* Since we don't care about
       the errors/exceptions in WF API, we are just catching when OTHERS */
--      DBMS_OUTPUT.put_line (' ========================================== ');
--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Resource Group Member Pvt ========= ');
--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO wf_int_del_res_grp_mbr;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

  PROCEDURE create_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_TEAM_ID             IN   NUMBER,
   P_TEAM_NAME           IN   VARCHAR2,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE      IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) IS
     l_api_version         CONSTANT NUMBER := 1.0;
     l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_TEAM';
     l_team_role_name       wf_local_roles.name%TYPE := g_team_orig_system||':'||to_char(p_team_id);
     l_start_date_active   date := trunc(P_START_DATE_ACTIVE);
     l_end_date_active   date := trunc(P_END_DATE_ACTIVE);
     l_sysdate date := trunc(sysdate);

     l_list           WF_PARAMETER_LIST_T;

   BEGIN
     SAVEPOINT wf_int_create_resource_team;
     x_return_status := fnd_api.g_ret_sts_success;

     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name,
 g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     IF p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
     END IF;

--     if (l_start_date_active <= l_sysdate AND
--         (l_end_date_active is null OR
--          l_end_date_active >= l_sysdate)) THEN
       if ( (l_end_date_active >= l_sysdate) OR (l_end_date_active is NULL) ) then
     /* Create role only if team is active */

          /* Changed the code to call Wf_local_synch instead of Wf_Directory
             Fix for bug # 2671368 */

          AddParameterToList('USER_NAME',l_team_role_name,l_list);
          AddParameterToList('DISPLAYNAME',p_team_name,l_list);
          AddParameterToList('MAIL',p_email_address,l_list);
          AddParameterToList('ORCLISENABLED','ACTIVE',l_list);

          Wf_local_synch.propagate_role(
                       p_orig_system           => g_team_orig_system,
                       p_orig_system_id        => p_team_id,
                       p_attributes            => l_list,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active);

          l_list.DELETE;

          Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => g_team_orig_system,
                       p_user_orig_system_id   => p_team_id,
                       p_role_orig_system      => g_team_orig_system,
                       p_role_orig_system_id   => p_team_id,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active);
     END IF;

     IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

   EXCEPTION
    WHEN OTHERS THEN
    /* Since we don't care about
       the errors/exceptions in WF API, we are just catching when OTHERS */
--      DBMS_OUTPUT.put_line (' ========================================== ');
--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Team Pvt ========= ');
--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO wf_int_create_resource_team;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

  PROCEDURE update_resource_team
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_TEAM_ID             IN   NUMBER,
   P_TEAM_NAME           IN   VARCHAR2,
   P_EMAIL_ADDRESS        IN   VARCHAR2,
   P_START_DATE_ACTIVE      IN   DATE,
   P_END_DATE_ACTIVE      IN   DATE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
  ) IS
     l_api_version         CONSTANT NUMBER := 1.0;
     l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_TEAM';
     l_team_role_name       wf_local_roles.name%TYPE := g_team_orig_system||':'||to_char(p_team_id);
     l_start_date_active   date := trunc(P_START_DATE_ACTIVE);
     l_end_date_active   date := trunc(P_END_DATE_ACTIVE);
     l_sysdate date := trunc(sysdate);
     l_g_miss_date         date := trunc(to_date('31-12-4712','DD-MM-YYYY'));

     CURSOR C_ROLE_EXISTS (P_NAME IN VARCHAR2, P_ORG_SYS IN VARCHAR2, P_ORG_SYS_ID IN NUMBER) IS
       SELECT 'Y'
       FROM WF_LOCAL_ROLES
       WHERE NAME = P_NAME AND
	 ORIG_SYSTEM_ID = P_ORG_SYS_ID AND
	 ORIG_SYSTEM = P_ORG_SYS;

     CURSOR C_TEAM_OLD_VALS(P_TEAM_ID IN NUMBER) IS
       SELECT EMAIL_ADDRESS, TEAM_NAME, trunc(START_DATE_ACTIVE) START_DATE_ACTIVE, trunc(END_DATE_ACTIVE) END_DATE_ACTIVE
       FROM JTF_RS_TEAMS_VL WHERE TEAM_ID = P_TEAM_ID;

     l_old_team_vals C_TEAM_OLD_VALS%ROWTYPE;
     l_check_role C_ROLE_EXISTS%ROWTYPE;

     CURSOR team_mem_cur IS
     SELECT mem.team_resource_id,
            mem.resource_type
     FROM   jtf_rs_team_members mem, jtf_rs_teams_b team
     WHERE  mem.team_id = team.team_id
     AND    nvl(mem.delete_flag,'N') <> 'Y'
--     AND    l_sysdate between trunc(team.start_date_active) and nvl(trunc(team.end_date_active),l_sysdate)
     AND    team.team_id  = p_team_id;

     CURSOR res_dates(c_resource_id NUMBER) IS
     SELECT trunc(start_date_active) start_date_active,
            trunc(end_date_active) end_date_active
     FROM   jtf_rs_resource_extns
     WHERE  resource_id = c_resource_id;

     CURSOR group_dates(c_group_id NUMBER) IS
     SELECT trunc(start_date_active) start_date_active,
            trunc(end_date_active) end_date_active
     FROM   jtf_rs_groups_b
     WHERE  group_id = c_group_id;

     l_team_mem_user_name           wf_local_roles.name%TYPE;
     l_team_mem_orig_system         wf_local_roles.orig_system%TYPE;
     l_team_mem_orig_system_id      wf_local_roles.orig_system_id%TYPE;

     l_team_mem_start_date         date;
     l_team_mem_end_date           date;

     l_list           WF_PARAMETER_LIST_T;

   BEGIN
     SAVEPOINT wf_int_update_resource_team;
     x_return_status := fnd_api.g_ret_sts_success;

     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     IF p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
     END IF;

     /* Role record exists then update if team name, email, start date
        or end date is changed */
     OPEN C_TEAM_OLD_VALS(p_team_id);
     FETCH C_TEAM_OLD_VALS into l_old_team_vals;

     IF C_TEAM_OLD_VALS%FOUND AND
        (P_TEAM_NAME <> l_old_team_vals.team_name OR
        (P_EMAIL_ADDRESS is null and
         l_old_team_vals.email_address is not null) OR
        (P_EMAIL_ADDRESS is not null and
         l_old_team_vals.email_address is null) OR
         P_EMAIL_ADDRESS <> l_old_team_vals.email_address OR
         L_START_DATE_ACTIVE <> l_old_team_vals.start_date_active OR
        (L_END_DATE_ACTIVE is null and
         l_old_team_vals.end_date_active is not null) OR
        (L_END_DATE_ACTIVE is not null and
         l_old_team_vals.end_date_active is null) OR
         L_END_DATE_ACTIVE <> l_old_team_vals.end_date_active) AND
        ((nvl(l_old_team_vals.end_date_active,l_sysdate) >= l_sysdate) OR
          (nvl(l_end_date_active,l_sysdate) >= l_sysdate)) THEN
           /* If any of the above is changed and the team old/new end_date is >= l_sysdate, then update the team */

          if ((nvl(l_end_date_active,l_sysdate) >= l_sysdate)) then

             AddParameterToList('USER_NAME',l_team_role_name,l_list);
             AddParameterToList('DISPLAYNAME',p_team_name,l_list);
             AddParameterToList('MAIL',p_email_address,l_list);
             AddParameterToList('ORCLISENABLED','ACTIVE',l_list);
             AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);

             Wf_local_synch.propagate_role(
                       p_orig_system           => g_team_orig_system,
                       p_orig_system_id        => p_team_id,
                       p_attributes            => l_list,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active);

             l_list.DELETE;

             Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => g_team_orig_system,
                       p_user_orig_system_id   => p_team_id,
                       p_role_orig_system      => g_team_orig_system,
                       p_role_orig_system_id   => p_team_id,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active,
                       p_overwrite             => TRUE);
          end if;

          if ((l_start_date_active <> l_old_team_vals.start_date_active) OR
              (l_end_date_active is null and l_old_team_vals.end_date_active is not null) OR
              (l_end_date_active is not null and l_old_team_vals.end_date_active is null)) THEN
              /* above if is to find out if there a change in group dates */

             for i in team_mem_cur LOOP

                 if i.resource_type = 'INDIVIDUAL' then
                    jtf_rs_wf_integration_pub.get_wf_role(P_RESOURCE_ID => i.team_resource_id,
                                               X_ROLE_NAME => l_team_mem_user_name,
                                               X_ORIG_SYSTEM => l_team_mem_orig_system,
                                               X_ORIG_SYSTEM_ID => l_team_mem_orig_system_id);

                     OPEN res_dates(i.team_resource_id);
                     FETCH res_dates into l_team_mem_start_date, l_team_mem_end_date;
                     CLOSE res_dates;
                 elsif i.resource_type = 'GROUP' then
                    l_team_mem_orig_system    := g_grp_orig_system;
                    l_team_mem_orig_system_id := i.team_resource_id;
                    l_team_mem_user_name      := l_team_mem_orig_system||':'||to_char(l_team_mem_orig_system_id);

                    OPEN group_dates(i.team_resource_id);
                    FETCH group_dates into l_team_mem_start_date, l_team_mem_end_date;
                    CLOSE group_dates;
                 end if;

                 l_team_mem_start_date := greatest(l_team_mem_start_date, l_start_date_active);
                 l_team_mem_end_date   := least (nvl(l_team_mem_end_date, l_g_miss_date), nvl(l_end_date_active, l_g_miss_date));

                 if (l_team_mem_end_date = l_g_miss_date) then
                    l_team_mem_end_date := NULL;
                 end if;

                 Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => l_team_mem_orig_system,
                       p_user_orig_system_id   => l_team_mem_orig_system_id,
                       p_role_orig_system      => g_team_orig_system,
                       p_role_orig_system_id   => p_team_id,
                       p_start_date            => l_team_mem_start_date,
                       p_expiration_date       => l_team_mem_end_date,
                       p_overwrite             => TRUE);

             END LOOP;
          end if;

          if ((nvl(l_end_date_active,l_sysdate) < l_sysdate)) then

             Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => g_team_orig_system,
                       p_user_orig_system_id   => p_team_id,
                       p_role_orig_system      => g_team_orig_system,
                       p_role_orig_system_id   => p_team_id,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active,
                       p_overwrite             => TRUE);

             AddParameterToList('USER_NAME',l_team_role_name,l_list);
             AddParameterToList('DISPLAYNAME',p_team_name,l_list);
             AddParameterToList('MAIL',p_email_address,l_list);
             AddParameterToList('ORCLISENABLED','ACTIVE',l_list);
             AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);

             Wf_local_synch.propagate_role(
                       p_orig_system           => g_team_orig_system,
                       p_orig_system_id        => p_team_id,
                       p_attributes            => l_list,
                       p_start_date            => l_start_date_active,
                       p_expiration_date       => l_end_date_active);

             l_list.DELETE;

          end if;

         END IF; /* C_TEAM_OLD_VALS%FOUND .. */

     IF c_team_old_vals%ISOPEN THEN
       CLOSE c_team_old_vals;
     END IF;

     IF c_role_exists%ISOPEN THEN
       CLOSE c_role_exists;
     END IF;

     IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
    /* Since we don't care about
       the errors/exceptions in WF API, we are just catching when OTHERS */
--       DBMS_OUTPUT.put_line (' ========================================== ');
--       DBMS_OUTPUT.put_line (' ===========  Raised Others in Update Resource Team Pvt ========= ');
--       DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

       IF c_team_old_vals%ISOPEN THEN
	 CLOSE c_team_old_vals;
       END IF;

       IF c_role_exists%ISOPEN THEN
	 CLOSE c_role_exists;
       END IF;

       ROLLBACK TO wf_int_update_resource_team;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  END;

  PROCEDURE create_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   NUMBER,
   P_GROUP_ID           IN    NUMBER,
   P_TEAM_ID             IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) IS
     l_api_version         CONSTANT NUMBER := 1.0;
     l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE_TEAM_MEMBERS';
     l_team_role_name       wf_local_roles.name%TYPE := g_team_orig_system||':'||to_char(p_team_id);
     l_sysdate date := trunc(sysdate);

     CURSOR C_ROLE_EXISTS (P_NAME IN VARCHAR2, P_ORG_SYS IN VARCHAR2, P_ORG_SYS_ID IN NUMBER) IS
       SELECT 'Y'
       FROM WF_LOCAL_ROLES
       WHERE NAME = P_NAME AND
	 ORIG_SYSTEM_ID = P_ORG_SYS_ID AND
	 ORIG_SYSTEM = P_ORG_SYS;

     CURSOR c_team_active (p_team_id IN NUMBER) IS
        SELECT trunc(START_DATE_ACTIVE) START_DATE_ACTIVE,
               trunc(END_DATE_ACTIVE) END_DATE_ACTIVE
        FROM JTF_RS_TEAMS_B
        WHERE TEAM_ID = P_TEAM_ID AND
             trunc(START_DATE_ACTIVE) <= l_sysdate AND
             NVL(trunc(END_DATE_ACTIVE), l_sysdate) >= l_sysdate;

     CURSOR c_res_active (p_resource_id IN NUMBER) IS
        SELECT trunc(START_DATE_ACTIVE) START_DATE_ACTIVE,
               trunc(END_DATE_ACTIVE) END_DATE_ACTIVE
        FROM JTF_RS_RESOURCE_EXTNS
        WHERE RESOURCE_ID = P_RESOURCE_ID AND
             trunc(START_DATE_ACTIVE) <= l_sysdate AND
             NVL(trunc(END_DATE_ACTIVE), l_sysdate) >= l_sysdate;

     CURSOR c_grp_active (p_group_id IN NUMBER) IS
        SELECT trunc(START_DATE_ACTIVE) START_DATE_ACTIVE,
               trunc(END_DATE_ACTIVE) END_DATE_ACTIVE
        FROM JTF_RS_GROUPS_B
        WHERE GROUP_ID = P_GROUP_ID AND
             trunc(START_DATE_ACTIVE) <= l_sysdate AND
             NVL(trunc(END_DATE_ACTIVE), l_sysdate) >= l_sysdate;

     l_role_exists c_role_exists%ROWTYPE;
     l_team_active c_team_active%ROWTYPE;
     l_res_active c_res_active%ROWTYPE;
     l_grp_active c_grp_active%ROWTYPE;

     l_user_name wf_local_roles.name%TYPE;
     l_orig_system wf_local_roles.orig_system%TYPE;
     l_orig_system_id wf_local_roles.orig_system_id%TYPE;

     l_mem_role_start_date date;
     l_mem_role_end_date   date;
     l_g_miss_date         date := trunc(to_date('31-12-4712','DD-MM-YYYY'));

   BEGIN
     SAVEPOINT wf_int_cr_res_team_mbr;
     x_return_status := fnd_api.g_ret_sts_success;

     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     IF p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
     END IF;

     OPEN c_team_active(p_team_id);
     FETCH c_team_active INTO l_team_active;

     IF (c_team_active%FOUND) THEN
       IF (p_resource_id is not null) THEN
         OPEN c_res_active(p_resource_id);
         FETCH c_res_active INTO l_res_active;
	 IF (c_res_active%FOUND) THEN

            l_mem_role_start_date := greatest(l_res_active.start_date_active, l_team_active.start_date_active);
            l_mem_role_end_date   := least (nvl(l_res_active.end_date_active, l_g_miss_date), nvl(l_team_active.end_date_active, l_g_miss_date));

            if (l_mem_role_end_date = l_g_miss_date) then
               l_mem_role_end_date := NULL;
            end if;

--            get_user_role_dates
--                            (p_user_start_date         => l_res_active.start_date_active,
--                             p_user_end_date           => l_res_active.end_date_active,
--                             p_role_start_date         => l_team_active.start_date_active,
--                             p_role_end_date           => l_team_active.end_date_active,
--                             x_user_role_start_date    => l_mem_role_start_date,
--                             x_user_role_end_date      => l_mem_role_end_date);

	   /* Team as well as resource are active */
	   OPEN c_role_exists(l_team_role_name, g_team_orig_system, p_team_id);
	   FETCH c_role_exists into l_role_exists;
	   IF (c_role_exists%FOUND) THEN
	     jtf_rs_wf_integration_pub.get_wf_role(P_RESOURCE_ID => P_RESOURCE_ID,
						   X_ROLE_NAME => l_user_name,
						   X_ORIG_SYSTEM => l_orig_system,
						   X_ORIG_SYSTEM_ID => l_orig_system_id);


	     IF l_user_name is not null THEN

                Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => l_orig_system,
                       p_user_orig_system_id   => l_orig_system_id,
                       p_role_orig_system      => g_team_orig_system,
                       p_role_orig_system_id   => p_team_id,
                       p_start_date            => l_mem_role_start_date,
                       p_expiration_date       => l_mem_role_end_date,
                       p_overwrite             => TRUE);
	     END IF;
	   END IF;
	   CLOSE c_role_exists;
	 END IF;
	 CLOSE c_res_active;
       ELSIF (p_group_id is not null) THEN
         OPEN c_grp_active(p_group_id);
         FETCH c_grp_active INTO l_grp_active;
	 IF (c_grp_active%FOUND) THEN

            l_mem_role_start_date := greatest(l_grp_active.start_date_active, l_team_active.start_date_active);
            l_mem_role_end_date   := least (nvl(l_grp_active.end_date_active, l_g_miss_date), nvl(l_team_active.end_date_active, l_g_miss_date));

            if (l_mem_role_end_date = l_g_miss_date) then
               l_mem_role_end_date := NULL;
            end if;

--            get_user_role_dates
--                            (p_user_start_date         => l_grp_active.start_date_active,
--                             p_user_end_date           => l_grp_active.end_date_active,
--                             p_role_start_date         => l_team_active.start_date_active,
--                             p_role_end_date           => l_team_active.end_date_active,
--                             x_user_role_start_date    => l_mem_role_start_date,
--                             x_user_role_end_date      => l_mem_role_end_date);

	   /* Team as well as group are active */
	   OPEN c_role_exists(l_team_role_name, g_team_orig_system, p_team_id);
	   FETCH c_role_exists into l_role_exists;
	   IF (c_role_exists%FOUND) THEN
	     /* Team - role record exists */
	     l_user_name := g_grp_orig_system||':'||to_char(p_group_id);
	     CLOSE c_role_exists;
	     OPEN c_role_exists(l_user_name, g_grp_orig_system, p_group_id);
	     FETCH c_role_exists into l_role_exists;
	     IF (c_role_exists%FOUND) THEN

	       /* Group - role record exists */
                Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => g_grp_orig_system,
                       p_user_orig_system_id   => p_group_id,
                       p_role_orig_system      => g_team_orig_system,
                       p_role_orig_system_id   => p_team_id,
                       p_start_date            => l_mem_role_start_date,
                       p_expiration_date       => l_mem_role_end_date,
                       p_overwrite             => TRUE);
	     END IF;
	   END IF;
	   CLOSE c_role_exists;
	 END IF;
	 CLOSE c_grp_active;
       END IF;
     END IF;

     CLOSE c_team_active;

     IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

   EXCEPTION
    WHEN OTHERS THEN
    /* Since we don't care about
       the errors/exceptions in WF API, we are just catching when OTHERS */
--      DBMS_OUTPUT.put_line (' ========================================== ');
--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Create Resource Team Member Pvt ========= ');
--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      IF c_role_exists%ISOPEN THEN
	CLOSE c_role_exists;
      END IF;

      IF c_team_active%ISOPEN THEN
	CLOSE c_team_active;
      END IF;

      IF c_res_active%ISOPEN THEN
	CLOSE c_res_active;
      END IF;

      IF c_grp_active%ISOPEN THEN
	CLOSE c_res_active;
      END IF;

      ROLLBACK TO wf_int_cr_res_team_mbr;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;


  PROCEDURE delete_resource_team_members
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   P_TEAM_ID             IN   NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) IS
     l_api_version         CONSTANT NUMBER := 1.0;
     l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_RESOURCE_TEAM_MEMBERS';
     l_team_role_name       wf_local_roles.name%TYPE := g_team_orig_system||':'||to_char(p_team_id);

     l_user_name wf_local_roles.name%TYPE;
     l_orig_system wf_local_roles.orig_system%TYPE;
     l_orig_system_id wf_local_roles.orig_system_id%TYPE;
   BEGIN
     SAVEPOINT wf_int_del_res_team_mbr;
     x_return_status := fnd_api.g_ret_sts_success;

     IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name,
 g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     IF p_init_msg_list is not NULL and fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
     END IF;

     IF (P_RESOURCE_ID is not null) THEN
       jtf_rs_wf_integration_pub.get_wf_role(P_RESOURCE_ID => P_RESOURCE_ID,
					     X_ROLE_NAME => l_user_name,
					     X_ORIG_SYSTEM => l_orig_system,
					     X_ORIG_SYSTEM_ID => l_orig_system_id);

       IF l_user_name is not null THEN

          /* Changed the code to call Wf_local_synch instead of Wf_Directory
             Fix for bug # 2671368 */

          Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => l_orig_system,
                       p_user_orig_system_id   => l_orig_system_id,
                       p_role_orig_system      => g_team_orig_system,
                       p_role_orig_system_id   => p_team_id,
              --         p_start_date            => sysdate,
                       p_expiration_date       => sysdate-1);
       END IF;
     ELSIF (P_GROUP_ID is not null) THEN
       l_user_name := g_grp_orig_system||':'||to_char(p_group_id);

       Wf_local_synch.propagate_user_role(
                       p_user_orig_system      => g_grp_orig_system,
                       p_user_orig_system_id   => p_group_id,
                       p_role_orig_system      => g_team_orig_system,
                       p_role_orig_system_id   => p_team_id,
              --         p_start_date            => sysdate,
                       p_expiration_date       => sysdate-1);
     END IF;


     IF p_commit is not NULL and fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

   EXCEPTION
    WHEN OTHERS THEN
    /* Since we don't care about
       the errors/exceptions in WF API, we are just catching when OTHERS */
--      DBMS_OUTPUT.put_line (' ========================================== ');
--      DBMS_OUTPUT.put_line (' ===========  Raised Others in Delete Resource Team Member Pvt ========= ');
--      DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

      ROLLBACK TO wf_int_del_res_team_mbr;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

END jtf_rs_wf_integration_pub;

/
