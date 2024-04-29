--------------------------------------------------------
--  DDL for Package Body MSD_DEM_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_EVENT" AS
/* $Header: msddemevntb.pls 120.2.12010000.7 2009/02/09 12:10:10 sjagathe ship $ */


   /* Private Function - Added for creating the SOP component user in Demantra */
   FUNCTION SOP_USER_CHANGE (
   		p_subscription_guid in     raw,
    		p_event             in out nocopy wf_event_t)
   RETURN VARCHAR2;

   PROCEDURE log_debug (p_msg VARCHAR2)
   IS
   BEGIN
      IF (fnd_profile.value ('MSD_DEM_DEBUG_MODE') = 'Y' OR 1=1)
      THEN
         RETURN;
      END IF;

      RETURN;

   EXCEPTION
      WHEN OTHERS THEN
         RETURN;
   END;


   FUNCTION USER_CHANGE (
   		p_subscription_guid in     raw,
    		p_event             in out nocopy wf_event_t)
   RETURN VARCHAR2
   IS
      eventName varchar2(100);
      key    varchar2(401);
      userQuery varchar(10000);
      DuserQuery varchar(1000);
      DOlduserQuery varchar(1000);
      p_user_name fnd_user.user_name%type;
	  p_user_pwd  varchar2(10) := dbms_random.string('A', 10); --bug#7375774 nallkuma
      p_user_valid number;
      p_user_resp number;
      p_user_fname per_all_people_f.first_name%type;
      p_user_lname per_all_people_f.last_name%type;
      p_user_org_name hr_all_organization_units.name%type;
      p_user_wrkphone per_all_people_f.work_telephone%type;
      p_user_fax fnd_user.fax%type;
      p_user_email fnd_user.email_address%type;
      p_user_product number;
      Duser_cnt number;
      DOlduser_cnt number;
      userid varchar2 (400);

      x_schema		VARCHAR2(30)	:= NULL;
      x_user_permission	VARCHAR2(10)    := NULL;
      x_component_name	VARCHAR2(100)	:= NULL;

      x_create_user_sql	VARCHAR2(2000)	:= NULL;
      x_update_user_sql VARCHAR2(2000)	:= NULL;
      x_drop_user_sql	VARCHAR2(2000)	:= NULL;
      x_drop_old_user_sql VARCHAR2(2000)	:= NULL;

      x_old_name	VARCHAR2(320)	:= NULL;
      x_curr_name	VARCHAR2(320)	:= NULL;

      x_ret_val		VARCHAR2(255)   := NULL;

    x_table_name    VARCHAR2(50)	:= NULL;

    l_stmt varchar2(2000) := null; --syenamar bug#7199587

    CURSOR c_is_mdp_matrix_present (p_schema_name	VARCHAR2)
    IS
        SELECT table_name
        FROM all_tables
        WHERE  owner = upper(p_schema_name)
        AND table_name = 'MDP_MATRIX';

    CURSOR c_get_user_id (p_user_name varchar2)
    IS
        SELECT to_char(user_id)
        FROM fnd_user
        WHERE user_name = p_user_name;

   BEGIN

        --Bug#7140524
        /* Check if Demantra is installed before proceeding further */
        x_schema := fnd_profile.value('MSD_DEM_SCHEMA');

        log_debug ('Schema: ' || x_schema);

        IF (x_schema IS NULL)
        THEN
            log ('msd_dem_event.user_change - Profile MSD_DEM_SCHEMA is not set.');
            log_debug ('msd_dem_event.user_change - Profile MSD_DEM_SCHEMA is not set.');
            RETURN SUCCESS;
        ELSE
            OPEN c_is_mdp_matrix_present (x_schema);
            FETCH c_is_mdp_matrix_present INTO x_table_name;
            CLOSE c_is_mdp_matrix_present;

            IF (x_table_name IS NULL)
            THEN
                log ('msd_dem_event.user_change - Profile MSD_DEM_SCHEMA is incorrectly set or Demantra schema is not installed.');
                log_debug ('msd_dem_event.user_change - Profile MSD_DEM_SCHEMA is incorrectly set or Demantra schema is not installed.');
                RETURN SUCCESS;
            END IF;
        END IF;
        --Bug#7140524

      /* Create the SOP component user for Demantra */
      x_ret_val := sop_user_change (p_subscription_guid, p_event);
      IF x_ret_val <> SUCCESS
      THEN
         log ('Creation of SOP component user failed.');
         log_debug ('Creation of SOP component user failed.');
      END IF;

      log('start');
      log_debug('start');

      eventName := p_event.getEventName();
      key       := p_event.getEventKey();

      log_debug ('Event Name: ' || eventName);
      log_debug ('Key: ' || key);

      /*** BEGIN - Get the user name from the event  ***/
      If (   eventName = 'oracle.apps.fnd.wf.ds.userRole.created'
          OR eventName = 'oracle.apps.fnd.wf.ds.userRole.updated'
          OR eventName = 'oracle.apps.fnd.user.delete'
          OR eventName = 'oracle.apps.fnd.wf.ds.user.updated'
          OR eventName = 'oracle.apps.fnd.wf.ds.user.nameChanged')
      THEN
         x_curr_name := p_event.getValueForParameter('USER_NAME');
         log_debug ('Current User Name: ' || x_curr_name);

         IF (eventName = 'oracle.apps.fnd.wf.ds.user.nameChanged')
         THEN
            x_old_name  := p_event.getValueForParameter('OLD_USER_NAME');
            log_debug ('Old User Name: ' || x_old_name);
         END IF;

      ELSE
         log_debug('Exiting msd_dem_event.user_change: Unknown Event');
         RETURN SUCCESS;
      END IF;

      /*** END- Get the user name from the event  ***/

      /* Get the user id from the user name */
      OPEN c_get_user_id (x_curr_name);
      FETCH c_get_user_id INTO userid;
      CLOSE c_get_user_id;

      log_debug ('User Id: ' || userid);

      IF (userid IS NULL)
      THEN
         log ('Unable to get user id for user name = ' || x_curr_name);
         log_debug ('Unable to get user id for user name = ' || x_curr_name);
         --Bug#7140524 : returning success in case user id not found, so that workflow calling this method will proceed without erroring out
         return SUCCESS;
         /*return ( handleError ( PKG_NAME
                         , 'msd_dem_event.user_change'
                         , p_event
                         , p_subscription_guid
                         , ERROR
                         ));*/
         --Bug#7140524
      END IF;

      userQuery :=
           ' select fu.user_name, decode(sign(fu.end_date - sysdate),-1,2,1),
             (SELECT sum(a) FROM (SELECT 1 a
                                     FROM dual
                                     WHERE EXISTS ( SELECT 1
                                                       FROM fnd_user_resp_groups_all fug,
                                                            fnd_responsibility fr,
                                                            fnd_menu_entries fme,
                                                            fnd_form_functions fff
                                                       WHERE
                                                               fug.user_id = :user_id1
                                                           AND fug.responsibility_application_id = 722
                                                           AND decode(sign(fug.end_date - sysdate), -1, 2, 1) = 1
                                                           AND fr.application_id = 722
                                                           AND fr.responsibility_id = fug.responsibility_id
                                                           AND fme.menu_id = fr.menu_id
                                                           AND fme.grant_flag = ''Y''
                                                           AND fme.sub_menu_id IS NULL
                                                           AND fff.function_id = fme.function_id
                                                           AND fff.function_name = ''MSD_DEM_DEMPLANR'')
                                  UNION ALL
                                  SELECT 2 a
                                     FROM dual
                                     WHERE EXISTS ( SELECT 1
                                                       FROM fnd_user_resp_groups_all fug,
                                                            fnd_responsibility fr,
                                                            fnd_menu_entries fme,
                                                            fnd_form_functions fff
                                                       WHERE
                                                               fug.user_id = :user_id2
                                                           AND fug.responsibility_application_id = 722
                                                           AND decode(sign(fug.end_date - sysdate), -1, 2, 1) = 1
                                                           AND fr.application_id = 722
                                                           AND fr.responsibility_id = fug.responsibility_id
                                                           AND fme.menu_id = fr.menu_id
                                                           AND fme.grant_flag = ''Y''
                                                           AND fme.sub_menu_id IS NULL
                                                           AND fff.function_id = fme.function_id
                                                           AND fff.function_name = ''MSD_DEM_WF_MGR''))) user_type,
             ( select first_name
              from per_all_people_f
              where ((person_id = fu.employee_id
                     and fu.employee_id is not null)
              or
                    (party_id = fu.person_party_id
                     and fu.person_party_id is not null)
              or    (party_id = fu.supplier_id
                     and fu.supplier_id is not null)
              or    (party_id = fu.customer_id
                     and fu.customer_id is not null))
              and rownum <2) first_name,
            ( select last_name
              from per_all_people_f
              where ((person_id = fu.employee_id
                     and fu.employee_id is not null)
              or
                    (party_id = fu.person_party_id
                     and fu.person_party_id is not null)
              or    (party_id = fu.supplier_id
                     and fu.supplier_id is not null)
              or    (party_id = fu.customer_id
                     and fu.customer_id is not null))
              and rownum <2) last_name,
            ( select name
              from hr_all_organization_units
              where business_group_id in
              (select pap.business_group_id
              from per_all_people_f pap
              where (pap.person_id = fu.employee_id
                     and fu.employee_id is not null)
              or
                    (pap.party_id = fu.person_party_id
                     and fu.person_party_id is not null)
              or    (pap.party_id = fu.supplier_id
                     and fu.supplier_id is not null)
              or    (pap.party_id = fu.customer_id
                     and fu.customer_id is not null))
              and rownum < 2) company,
            ( select work_telephone
              from per_all_people_f
              where ((person_id = fu.employee_id
                     and fu.employee_id is not null)
              or
                    (party_id = fu.person_party_id
                     and fu.person_party_id is not null)
              or    (party_id = fu.supplier_id
                     and fu.supplier_id is not null)
              or    (party_id = fu.customer_id
                     and fu.customer_id is not null))
              and rownum <2) phone_num,
             fu.fax,
             decode(fu.email_address,
               null,
               (select pap.email_address
               from per_all_people_f pap
               where ((person_id = fu.employee_id
                     and fu.employee_id is not null)
               or
                    (party_id = fu.person_party_id
                     and fu.person_party_id is not null)
               or    (party_id = fu.supplier_id
                     and fu.supplier_id is not null)
               or    (party_id = fu.customer_id
                     and fu.customer_id is not null))
               and pap.email_address is not null
               and rownum <2),
               fu.email_address) email_address,
             1 product
      	from fnd_user fu
      	where fu.user_id = :userid3';

      IF (eventName = 'oracle.apps.fnd.user.delete')
      THEN
         p_user_name := x_curr_name;
      ELSE

         begin
            execute immediate userQuery
            into p_user_name,p_user_valid,p_user_resp,p_user_fname,p_user_lname,p_user_org_name,
                 p_user_wrkphone,p_user_fax,p_user_email,p_user_product
            using userid, userid, userid;
         exception
            when others then
               log_debug (substr(SQLERRM,1,150));
               log ('Query on user_id ' || to_char(userid) || ' failed. Please ignore if not an Demand Management User.');
               return ( handleError ( PKG_NAME
                         , 'msd_dem_event.user_change'
                         , p_event
                         , p_subscription_guid
                         , ERROR
                         ));
         end;
      END IF;


      /* Get the user type */
      IF (eventName = 'oracle.apps.fnd.user.delete')
      THEN
         NULL;
      ELSIF (p_user_resp = 1)
      THEN
         x_user_permission := 'DP';
      ELSIF (p_user_resp = 3)
      THEN
         x_user_permission := 'DPA';
      ELSIF (   eventName = 'oracle.apps.fnd.wf.ds.userRole.updated'
             OR eventName = 'oracle.apps.fnd.wf.ds.user.updated')
      THEN
         eventName := 'oracle.apps.fnd.user.resp.delete';
      ELSE
         log ('Not a DM User');
         RETURN SUCCESS;
      END IF;

      /* Get the Demand Management Component */
      x_component_name := msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                   'COMP_DM',
                                                                   1,
                                                                   'product_name');

      log_debug ('Component: ' || x_component_name);

      /* CREATE USER */
      x_create_user_sql := 'BEGIN ' || x_schema || '.API_CREATE_ORA_DEM_USER ( ' ||
                                                      ' ''' || p_user_name || ''' , ' ||
                                                      ' ''' || p_user_pwd || ''' , ' ||
                                                      ' ''' || x_user_permission || ''' , ' ||
                                                      ' ''' || p_user_fname || ''' , ' ||
                                                      ' ''' || p_user_lname || ''' , ' ||
                                                      ' ''' || p_user_org_name || ''' , ' ||
                                                      ' ''' || p_user_wrkphone || ''' , ' ||
                                                      ' ''' || p_user_fax || ''' , ' ||
                                                      ' ''' || p_user_email || ''' , ' ||
                                                      ' ''0'' , ' ||
                                                      ' null, ' ||
                                                      ' ''' || x_component_name || ''' , ' ||
                                                      ' null, ' ||
                                                      ' ''ADD''); END;';

      /* UPDATE USER */
      x_update_user_sql := 'BEGIN ' || x_schema || '.API_CREATE_ORA_DEM_USER ( ' ||
                                                      ' ''' || p_user_name || ''' , ' ||
                                                      ' ''' || p_user_pwd || ''' , ' ||
                                                      ' ''' || x_user_permission || ''' , ' ||
                                                      ' ''' || p_user_fname || ''' , ' ||
                                                      ' ''' || p_user_lname || ''' , ' ||
                                                      ' ''' || p_user_org_name || ''' , ' ||
                                                      ' ''' || p_user_wrkphone || ''' , ' ||
                                                      ' ''' || p_user_fax || ''' , ' ||
                                                      ' ''' || p_user_email || ''' , ' ||
                                                      ' ''0'' , ' ||
                                                      ' null, ' ||
                                                      ' ''' || x_component_name || ''' , ' ||
                                                      ' null, ' ||
                                                      ' ''UPDATE''); END;';

      /* DROP USER */
      x_drop_user_sql := 'BEGIN ' || x_schema || '.API_DROP_ORA_DEM_USER ( ''' || p_user_name || ''' ); END;';
      x_drop_old_user_sql := 'BEGIN ' || x_schema || '.API_DROP_ORA_DEM_USER ( ''' || x_old_name || ''' ); END;';

      /* USER EXISTS IN DEMANTRA */
      DuserQuery := 'select count(user_name) from ' || x_schema || '.user_id where user_name = '''||p_user_name||'''';
      log_debug ('User Query - ' || DuserQuery);

      execute immediate DuserQuery Into Duser_cnt;
      log_debug('User count - ' || to_char (Duser_cnt) );

      /* OLD USER EXISTS IN DEMANTRA */
      DOlduserQuery := 'select count(user_name) from ' || x_schema || '.user_id where user_name = '''||x_old_name||'''';
      log_debug ('Old User Query - ' || DOlduserQuery);

      log_debug ('Start processing the event - ' || eventName);

      /*  insert/Update responsibility for user  */
      If (   eventName = 'oracle.apps.fnd.wf.ds.userRole.created'
          OR eventName = 'oracle.apps.fnd.wf.ds.userRole.updated') THEN

         /* User does not exist in Demantra... Add the user */
         If Duser_cnt = 0 Then

            /* invoke API_CREATE_ORA_DEM_USER.(ADD) */
            log_debug ('Insert/Update Responsibility - Creating User');
            log_debug (x_create_user_sql);

            EXECUTE IMMEDIATE x_create_user_sql;

         /* User exists in Demantra, Update the responsibility */
         Elsif Duser_cnt > 0 Then

            /* invoke API_CREATE_ORA_DEM_USER (UPDATE) */
            log_debug ('Insert/Update Responsibility - Updating User');
            log_debug (x_update_user_sql);

            EXECUTE IMMEDIATE x_update_user_sql;

         End if;

      /*  Update Existing User  */
      Elsif (eventName = 'oracle.apps.fnd.wf.ds.user.updated') THEN

         /* Effective date has been disabled OR DM responsibilities have been disabled for user....delete user */
         If (p_user_valid = 2 OR p_user_resp  = 0) Then

            /* invoke API_DROP_ORA_DEM_USER(user name) */
            log_debug ('User Update - Deleting User');
            log_debug (x_drop_user_sql);

            EXECUTE IMMEDIATE x_drop_user_sql;

         Else

             /* User does not exist in Demantra but effective date is enabled....Add user */
             If (Duser_cnt = 0) Then

                /* invoke API_CREATE_ORA_DEM_USER.(ADD) */
                log_debug ('User Update - Creating User');
                log_debug (x_create_user_sql);

                EXECUTE IMMEDIATE x_create_user_sql;

             /* User exists in Demantra and effective date is enabled....Update user */
             Else

                /* invoke API_CREATE_ORA_DEM_USER (UPDATE) */
                log_debug('User Update - Updating User');
                log_debug (x_update_user_sql);

                EXECUTE IMMEDIATE x_update_user_sql;

             End If;
         End If;

      /*   Delete existing User  */
      Elsif (eventName = 'oracle.apps.fnd.user.delete') THEN

         /* invoke API_DROP_ORA_DEM_USER(user name) */
         log_debug('User Delete - Deleting User');
         log_debug(x_drop_user_sql);

         EXECUTE IMMEDIATE x_drop_user_sql;

      /*   Delete responsibility  */
      Elsif (eventName = 'oracle.apps.fnd.user.resp.delete') THEN

         /*  User exists in Demantra  */
         If (Duser_cnt > 0 AND x_user_permission IS NOT NULL) Then

            /* invoke API_CREATE_ORA_DEM_USER (UPDATE) */
            log_debug ('Responsibility Delete - Updating user');
            log_debug (x_update_user_sql);

            EXECUTE IMMEDIATE x_update_user_sql;
         Elsif (Duser_cnt > 0)
         THEN
            /* invoke API_DROP_ORA_DEM_USER(user name) */
            log_debug('Responsibility Delete - Deleting user');
            log_debug(x_drop_user_sql);

            EXECUTE IMMEDIATE x_drop_user_sql;
         End If;

      Elsif (eventName = 'oracle.apps.fnd.wf.ds.user.nameChanged') Then

         execute immediate DOlduserQuery Into DOlduser_cnt;
         log_debug('Old User count - ' || to_char (DOlduser_cnt) );

         /*  Old User exists in Demantra  */
         IF (DOlduser_cnt > 0)
         THEN

            /* invoke API_DROP_ORA_DEM_USER(user name) */
            log_debug('Drop User with Old Name');
            log_debug(x_drop_old_user_sql);

            EXECUTE IMMEDIATE x_drop_old_user_sql;
         END IF;

         IF (p_user_valid = 1)
         THEN

            /* invoke API_CREATE_ORA_DEM_USER.(ADD) */
            log_debug ('Add User with New Name');
            log_debug (x_create_user_sql);

            EXECUTE IMMEDIATE x_create_user_sql;
         END IF;

      End if;

      log('end');
      RETURN SUCCESS;


   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         log_debug ('excep no data');
         LOG('No rows returned');
         return ( handleError ( PKG_NAME
                         , 'msd_dem_event.user_change'
                         , p_event
                         , p_subscription_guid
                         , ERROR
                         ));
      WHEN OTHERS THEN
         return ( handleError ( PKG_NAME
                         , 'msd_dem_event.user_change'
                         , p_event
                         , p_subscription_guid
                         , ERROR
                         ));

   END USER_CHANGE;




function handleError     ( p_pkg_name          in     varchar2
                         , p_function_name     in     varchar2
                         , p_event             in out nocopy wf_event_t
                         , p_subscription_guid in     raw
                         , p_error_type        in     varchar2
                         ) return varchar2 is

  l_error_type varchar2(100);

begin
  if p_error_type in (ERROR,WARNING) then
    l_error_type := p_error_type;
  else
    l_error_type := p_error_type;
  end if;
  if l_error_type = WARNING then
     wf_core.context ( p_pkg_name
                     , p_function_name
                     , p_event.getEventName()
                     , p_subscription_guid
                     );
     wf_event.setErrorInfo (p_event, WARNING);
     return WARNING;
  else
     wf_core.context ( p_pkg_name
                     , p_function_name
                     , p_event.getEventName()
                     , p_subscription_guid
                     );
     wf_event.setErrorInfo (p_event, ERROR);
     return ERROR;
  end if;
end handleError;


procedure log (msg in varchar2) is
begin
  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level ) then
    fnd_log.string ( fnd_log.level_statement
                   , PKG_NAME
                   , msg
                   );
  end if;
end log;


   FUNCTION SOP_USER_CHANGE (
   		p_subscription_guid in     raw,
    		p_event             in out nocopy wf_event_t)
   RETURN VARCHAR2
   IS
      eventName varchar2(100);
      key    varchar2(401);
      userQuery varchar(10000);
      DuserQuery varchar(1000);
      DOlduserQuery varchar(1000);
      p_user_name fnd_user.user_name%type;
	  p_user_pwd  varchar2(10) := dbms_random.string('A', 10);  --bug#7375774 nallkuma
      p_user_valid number;
      p_user_resp number;
      p_user_fname per_all_people_f.first_name%type;
      p_user_lname per_all_people_f.last_name%type;
      p_user_org_name hr_all_organization_units.name%type;
      p_user_wrkphone per_all_people_f.work_telephone%type;
      p_user_fax fnd_user.fax%type;
      p_user_email fnd_user.email_address%type;
      p_user_product number;
      Duser_cnt number;
      DOlduser_cnt number;
      userid varchar2 (400);

      x_schema		VARCHAR2(30)	:= NULL;
      x_user_permission	VARCHAR2(10)    := NULL;
      x_component_name	VARCHAR2(100)	:= NULL;

      x_create_user_sql	VARCHAR2(2000)	:= NULL;
      x_update_user_sql VARCHAR2(2000)	:= NULL;
      x_drop_user_sql	VARCHAR2(2000)	:= NULL;
      x_drop_old_user_sql VARCHAR2(2000)	:= NULL;

      x_old_name	VARCHAR2(320)	:= NULL;
      x_curr_name	VARCHAR2(320)	:= NULL;

      l_stmt varchar2(2000) := null; --syenamar bug#7199587

      CURSOR c_get_user_id (p_user_name varchar2)
      IS
         SELECT to_char(user_id)
            FROM fnd_user
            WHERE user_name = p_user_name;


   BEGIN

      log('start');
      log_debug('start');

      eventName := p_event.getEventName();
      key       := p_event.getEventKey();

      log_debug ('Event Name: ' || eventName);
      log_debug ('Key: ' || key);

      /*** BEGIN - Get the user name from the event  ***/
      If (   eventName = 'oracle.apps.fnd.wf.ds.userRole.created'
          OR eventName = 'oracle.apps.fnd.wf.ds.userRole.updated'
          OR eventName = 'oracle.apps.fnd.user.delete'
          OR eventName = 'oracle.apps.fnd.wf.ds.user.updated'
          OR eventName = 'oracle.apps.fnd.wf.ds.user.nameChanged')
      THEN
         x_curr_name := p_event.getValueForParameter('USER_NAME');
         log_debug ('Current User Name: ' || x_curr_name);

         IF (eventName = 'oracle.apps.fnd.wf.ds.user.nameChanged')
         THEN
            x_old_name  := p_event.getValueForParameter('OLD_USER_NAME');
            log_debug ('Old User Name: ' || x_old_name);
         END IF;

      ELSE
         log_debug('Exiting msd_dem_event.user_change: Unknown Event');
         RETURN SUCCESS;
      END IF;

      /*** END- Get the user name from the event  ***/

      /* Get the user id from the user name */
      OPEN c_get_user_id (x_curr_name);
      FETCH c_get_user_id INTO userid;
      CLOSE c_get_user_id;

      log_debug ('User Id: ' || userid);

      IF (userid IS NULL)
      THEN
         log ('Unable to get user id for user name = ' || x_curr_name);
         log_debug ('Unable to get user id for user name = ' || x_curr_name);
         --Bug#7140524 : returning success in case user id not found, so that workflow calling this method will proceed without erroring out
         return SUCCESS;
         /*return ( handleError ( PKG_NAME
                         , 'msd_dem_event.user_change'
                         , p_event
                         , p_subscription_guid
                         , ERROR
                         ));*/
         --Bug#7140524
      END IF;

      userQuery :=
           ' select fu.user_name, decode(sign(fu.end_date - sysdate),-1,2,1),
             (SELECT sum(a) FROM (SELECT 1 a
                                     FROM dual
                                     WHERE EXISTS ( SELECT 1
                                                       FROM fnd_user_resp_groups_all fug,
                                                            fnd_responsibility fr,
                                                            fnd_menu_entries fme,
                                                            fnd_form_functions fff
                                                       WHERE
                                                               fug.user_id = :user_id1
                                                           AND fug.responsibility_application_id = 722
                                                           AND decode(sign(fug.end_date - sysdate), -1, 2, 1) = 1
                                                           AND fr.application_id = 722
                                                           AND fr.responsibility_id = fug.responsibility_id
                                                           AND fme.menu_id = fr.menu_id
                                                           AND fme.grant_flag = ''Y''
                                                           AND fme.sub_menu_id IS NULL
                                                           AND fff.function_id = fme.function_id
                                                           AND fff.function_name = ''MSD_DEM_SOP_SOPPLANR'')
                                  UNION ALL
                                  SELECT 2 a
                                     FROM dual
                                     WHERE EXISTS ( SELECT 1
                                                       FROM fnd_user_resp_groups_all fug,
                                                            fnd_responsibility fr,
                                                            fnd_menu_entries fme,
                                                            fnd_form_functions fff
                                                       WHERE
                                                               fug.user_id = :user_id2
                                                           AND fug.responsibility_application_id = 722
                                                           AND decode(sign(fug.end_date - sysdate), -1, 2, 1) = 1
                                                           AND fr.application_id = 722
                                                           AND fr.responsibility_id = fug.responsibility_id
                                                           AND fme.menu_id = fr.menu_id
                                                           AND fme.grant_flag = ''Y''
                                                           AND fme.sub_menu_id IS NULL
                                                           AND fff.function_id = fme.function_id
                                                           AND fff.function_name = ''MSD_DEM_SOP_WF_MGR''))) user_type,
             ( select first_name
              from per_all_people_f
              where ((person_id = fu.employee_id
                     and fu.employee_id is not null)
              or
                    (party_id = fu.person_party_id
                     and fu.person_party_id is not null)
              or    (party_id = fu.supplier_id
                     and fu.supplier_id is not null)
              or    (party_id = fu.customer_id
                     and fu.customer_id is not null))
              and rownum <2) first_name,
            ( select last_name
              from per_all_people_f
              where ((person_id = fu.employee_id
                     and fu.employee_id is not null)
              or
                    (party_id = fu.person_party_id
                     and fu.person_party_id is not null)
              or    (party_id = fu.supplier_id
                     and fu.supplier_id is not null)
              or    (party_id = fu.customer_id
                     and fu.customer_id is not null))
              and rownum <2) last_name,
            ( select name
              from hr_all_organization_units
              where business_group_id in
              (select pap.business_group_id
              from per_all_people_f pap
              where (pap.person_id = fu.employee_id
                     and fu.employee_id is not null)
              or
                    (pap.party_id = fu.person_party_id
                     and fu.person_party_id is not null)
              or    (pap.party_id = fu.supplier_id
                     and fu.supplier_id is not null)
              or    (pap.party_id = fu.customer_id
                     and fu.customer_id is not null))
              and rownum < 2) company,
            ( select work_telephone
              from per_all_people_f
              where ((person_id = fu.employee_id
                     and fu.employee_id is not null)
              or
                    (party_id = fu.person_party_id
                     and fu.person_party_id is not null)
              or    (party_id = fu.supplier_id
                     and fu.supplier_id is not null)
              or    (party_id = fu.customer_id
                     and fu.customer_id is not null))
              and rownum <2) phone_num,
             fu.fax,
             decode(fu.email_address,
               null,
               (select pap.email_address
               from per_all_people_f pap
               where ((person_id = fu.employee_id
                     and fu.employee_id is not null)
               or
                    (party_id = fu.person_party_id
                     and fu.person_party_id is not null)
               or    (party_id = fu.supplier_id
                     and fu.supplier_id is not null)
               or    (party_id = fu.customer_id
                     and fu.customer_id is not null))
               and pap.email_address is not null
               and rownum <2),
               fu.email_address) email_address,
             1 product
      	from fnd_user fu
      	where fu.user_id = :userid3';

      IF (eventName = 'oracle.apps.fnd.user.delete')
      THEN
         p_user_name := x_curr_name;
      ELSE

         begin
            execute immediate userQuery
            into p_user_name,p_user_valid,p_user_resp,p_user_fname,p_user_lname,p_user_org_name,
                 p_user_wrkphone,p_user_fax,p_user_email,p_user_product
            using userid, userid, userid;
         exception
            when others then
               log_debug (substr(SQLERRM,1,150));
               log ('Query on user_id ' || to_char(userid) || ' failed. Please ignore if not an Sales and Operations Planning User.');
               return ( handleError ( PKG_NAME
                         , 'msd_dem_event.user_change'
                         , p_event
                         , p_subscription_guid
                         , ERROR
                         ));
         end;
      END IF;


      /* Get the user type */
      IF (eventName = 'oracle.apps.fnd.user.delete')
      THEN
         NULL;
      ELSIF (p_user_resp = 1)
      THEN
         x_user_permission := 'DP';
      ELSIF (p_user_resp = 3)
      THEN
         x_user_permission := 'DPA';
      ELSIF (   eventName = 'oracle.apps.fnd.wf.ds.userRole.updated'
             OR eventName = 'oracle.apps.fnd.wf.ds.user.updated')
      THEN
         eventName := 'oracle.apps.fnd.user.resp.delete';
      ELSE
         log ('Not a SOP User');
         RETURN SUCCESS;
      END IF;

      x_schema := fnd_profile.value('MSD_DEM_SCHEMA');

      /* Get the Sales and Operations Planning Component */
      x_component_name := msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                   'COMP_SOP',
                                                                   1,
                                                                   'product_name');

      log_debug ('Component: ' || x_component_name);

      /* For SOP component user the string _SOP will be appended to the EBS user name */
      p_user_name := p_user_name || '_SOP';
      x_old_name := x_old_name || '_SOP';

      /* CREATE USER */
      x_create_user_sql := 'BEGIN ' || x_schema || '.API_CREATE_ORA_DEM_USER ( ' ||
                                                      ' ''' || p_user_name || ''' , ' ||
                                                      ' ''' || p_user_pwd || ''' , ' ||
                                                      ' ''' || x_user_permission || ''' , ' ||
                                                      ' ''' || p_user_fname || ''' , ' ||
                                                      ' ''' || p_user_lname || ''' , ' ||
                                                      ' ''' || p_user_org_name || ''' , ' ||
                                                      ' ''' || p_user_wrkphone || ''' , ' ||
                                                      ' ''' || p_user_fax || ''' , ' ||
                                                      ' ''' || p_user_email || ''' , ' ||
                                                      ' ''0'' , ' ||
                                                      ' null, ' ||
                                                      ' ''' || x_component_name || ''' , ' ||
                                                      ' null, ' ||
                                                      ' ''ADD''); END;';

      /* UPDATE USER */
      x_update_user_sql := 'BEGIN ' || x_schema || '.API_CREATE_ORA_DEM_USER ( ' ||
                                                      ' ''' || p_user_name || ''' , ' ||
                                                      ' ''' || p_user_pwd || ''' , ' ||
                                                      ' ''' || x_user_permission || ''' , ' ||
                                                      ' ''' || p_user_fname || ''' , ' ||
                                                      ' ''' || p_user_lname || ''' , ' ||
                                                      ' ''' || p_user_org_name || ''' , ' ||
                                                      ' ''' || p_user_wrkphone || ''' , ' ||
                                                      ' ''' || p_user_fax || ''' , ' ||
                                                      ' ''' || p_user_email || ''' , ' ||
                                                      ' ''0'' , ' ||
                                                      ' null, ' ||
                                                      ' ''' || x_component_name || ''' , ' ||
                                                      ' null, ' ||
                                                      ' ''UPDATE''); END;';

      /* DROP USER */
      x_drop_user_sql := 'BEGIN ' || x_schema || '.API_DROP_ORA_DEM_USER ( ''' || p_user_name || ''' ); END;';
      x_drop_old_user_sql := 'BEGIN ' || x_schema || '.API_DROP_ORA_DEM_USER ( ''' || x_old_name || ''' ); END;';

      /* USER EXISTS IN DEMANTRA */
      DuserQuery := 'select count(user_name) from ' || x_schema || '.user_id where user_name = '''||p_user_name||'''';
      log_debug ('User Query - ' || DuserQuery);

      execute immediate DuserQuery Into Duser_cnt;
      log_debug('User count - ' || to_char (Duser_cnt) );

      /* OLD USER EXISTS IN DEMANTRA */
      DOlduserQuery := 'select count(user_name) from ' || x_schema || '.user_id where user_name = '''||x_old_name||'''';
      log_debug ('Old User Query - ' || DOlduserQuery);

      log_debug ('Start processing the event - ' || eventName);

      /*  insert/Update responsibility for user  */
      If (   eventName = 'oracle.apps.fnd.wf.ds.userRole.created'
          OR eventName = 'oracle.apps.fnd.wf.ds.userRole.updated') THEN

         /* User does not exist in Demantra... Add the user */
         If Duser_cnt = 0 Then

            /* invoke API_CREATE_ORA_DEM_USER.(ADD) */
            log_debug ('Insert/Update Responsibility - Creating User');
            log_debug (x_create_user_sql);

            EXECUTE IMMEDIATE x_create_user_sql;

         /* User exists in Demantra, Update the responsibility */
         Elsif Duser_cnt > 0 Then

            /* invoke API_CREATE_ORA_DEM_USER (UPDATE) */
            log_debug ('Insert/Update Responsibility - Updating User');
            log_debug (x_update_user_sql);

            EXECUTE IMMEDIATE x_update_user_sql;

         End if;

      /*  Update Existing User  */
      Elsif (eventName = 'oracle.apps.fnd.wf.ds.user.updated') THEN

         /* Effective date has been disabled OR DM responsibilities have been disabled for user....delete user */
         If (p_user_valid = 2 OR p_user_resp  = 0) Then

            /* invoke API_DROP_ORA_DEM_USER(user name) */
            log_debug ('User Update - Deleting User');
            log_debug (x_drop_user_sql);

            EXECUTE IMMEDIATE x_drop_user_sql;

         Else

             /* User does not exist in Demantra but effective date is enabled....Add user */
             If (Duser_cnt = 0) Then

                /* invoke API_CREATE_ORA_DEM_USER.(ADD) */
                log_debug ('User Update - Creating User');
                log_debug (x_create_user_sql);

                EXECUTE IMMEDIATE x_create_user_sql;

             /* User exists in Demantra and effective date is enabled....Update user */
             Else

                /* invoke API_CREATE_ORA_DEM_USER (UPDATE) */
                log_debug('User Update - Updating User');
                log_debug (x_update_user_sql);

                EXECUTE IMMEDIATE x_update_user_sql;

             End If;
         End If;

      /*   Delete existing User  */
      Elsif (eventName = 'oracle.apps.fnd.user.delete') THEN

         /* invoke API_DROP_ORA_DEM_USER(user name) */
         log_debug('User Delete - Deleting User');
         log_debug(x_drop_user_sql);

         EXECUTE IMMEDIATE x_drop_user_sql;

      /*   Delete responsibility  */
      Elsif (eventName = 'oracle.apps.fnd.user.resp.delete') THEN

         /*  User exists in Demantra  */
         If (Duser_cnt > 0 AND x_user_permission IS NOT NULL) Then

            /* invoke API_CREATE_ORA_DEM_USER (UPDATE) */
            log_debug ('Responsibility Delete - Updating user');
            log_debug (x_update_user_sql);

            EXECUTE IMMEDIATE x_update_user_sql;
         Elsif (Duser_cnt > 0)
         THEN
            /* invoke API_DROP_ORA_DEM_USER(user name) */
            log_debug('Responsibility Delete - Deleting user');
            log_debug(x_drop_user_sql);

            EXECUTE IMMEDIATE x_drop_user_sql;
         End If;

      Elsif (eventName = 'oracle.apps.fnd.wf.ds.user.nameChanged') Then

         execute immediate DOlduserQuery Into DOlduser_cnt;
         log_debug('Old User count - ' || to_char (DOlduser_cnt) );

         /*  Old User exists in Demantra  */
         IF (DOlduser_cnt > 0)
         THEN

            /* invoke API_DROP_ORA_DEM_USER(user name) */
            log_debug('Drop User with Old Name');
            log_debug(x_drop_old_user_sql);

            EXECUTE IMMEDIATE x_drop_old_user_sql;
         END IF;

         IF (p_user_valid = 1)
         THEN

            /* invoke API_CREATE_ORA_DEM_USER.(ADD) */
            log_debug ('Add User with New Name');
            log_debug (x_create_user_sql);

            EXECUTE IMMEDIATE x_create_user_sql;
         END IF;

      End if;

      log('end');
      RETURN SUCCESS;


   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         log_debug ('excep no data');
         LOG('No rows returned');
         return ( handleError ( PKG_NAME
                         , 'msd_dem_event.user_change'
                         , p_event
                         , p_subscription_guid
                         , ERROR
                         ));
      WHEN OTHERS THEN
         return ( handleError ( PKG_NAME
                         , 'msd_dem_event.user_change'
                         , p_event
                         , p_subscription_guid
                         , ERROR
                         ));

   END SOP_USER_CHANGE;

end msd_dem_event;

/
