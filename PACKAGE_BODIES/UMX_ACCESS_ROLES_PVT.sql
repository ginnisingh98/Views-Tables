--------------------------------------------------------
--  DDL for Package Body UMX_ACCESS_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_ACCESS_ROLES_PVT" AS
/*$Header: UMXVARPB.pls 120.3.12010000.4 2010/02/23 13:37:45 jstyles ship $*/

procedure populateRecord(p_role_name        in varchar2,
                         p_display_name     in varchar2,
                         p_owner_tag        in varchar2,
                         p_description      in varchar2,
                         p_params           in out nocopy wf_parameter_list_t) IS

l_notif_preference varchar2(30);

 begin

  --  Populating the structure wf_parameter_list_t

  WF_EVENT.AddParameterToList(p_name          => 'USER_NAME',
                              p_value         => p_role_name,
                              p_parameterlist => p_params);

  WF_EVENT.AddParameterToList(p_name          => 'DISPLAYNAME',
                              p_value         => p_display_name,
                              p_parameterlist => p_params);

  WF_EVENT.AddParameterToList(p_name          => 'DESCRIPTION',
                              p_value         => p_description,
                              p_parameterlist => p_params);

  WF_EVENT.AddParameterToList(p_name          => 'OWNER_TAG',
                              p_value         => p_owner_tag,
                              p_parameterlist => p_params);

  -- Setting the default values

  WF_EVENT.AddParameterToList(p_name          => 'ORCLNLSTERRITORY',
                              p_value         => 'AMERICA',
                              p_parameterlist => p_params);

  WF_EVENT.AddParameterToList(p_name          => 'RAISEERRORS',
                              p_value         => 'TRUE',
                              p_parameterlist => p_params);

l_notif_preference := NVL(wf_pref.get_pref('-WF_DEFAULT-', 'MAILTYPE'), 'QUERY');

  WF_EVENT.AddParameterToList(p_name	   => 'orclWorkFlowNotificationPref',
                              p_value	   => l_notif_preference,
                              p_parameterlist => p_params);

end populateRecord;

function getParentRoles(p_role_name varchar2) return varchar2 is

l_superiors WF_ROLE_HIERARCHY.relTAB;
l_subordinates WF_ROLE_HIERARCHY.relTAB;
length_sup number :=0;
l_role_name WF_ALL_ROLES_VL.NAME%TYPE;
l_role_display_name WF_ALL_ROLES_VL.DISPLAY_NAME%TYPE;
i number :=1;

cursor find_role_disp_name is select display_name from
WF_ALL_ROLES_vl where name = l_role_name;

begin

  IF p_role_name IS NULL THEN
   RETURN NULL;
  END IF;

  WF_ROLE_HIERARCHY.GetRelationships(p_name         => p_role_name,
                                     p_superiors    => l_superiors,
                                     p_subordinates => l_subordinates);

  length_sup := l_superiors.count;

  IF length_sup = 0 THEN
   RETURN NULL;
  END IF;

  jtf_dbstream_utils.clearOutputStream;
  jtf_dbstream_utils.writeInt(length_sup);

  -- Iterate through the table and create a delimited string
  loop

     if i > length_sup then -- terminating condition
     exit;
     end if;

       l_role_name := l_superiors(i).SUPER_NAME;

       open find_role_disp_name;
        fetch find_role_disp_name into l_role_display_name;

        jtf_dbstream_utils.writeString(l_role_display_name);
       close find_role_disp_name;
     i := i+1;
  end loop;

 return jtf_dbstream_utils.getOutputStream;

end getParentRoles;

function getAffectedRoles(p_role_name varchar2) return varchar2 is

l_superiors WF_ROLE_HIERARCHY.relTAB;
l_subordinates WF_ROLE_HIERARCHY.relTAB;
length_sup number :=0;
l_role_name WF_ALL_ROLES_VL.NAME%TYPE;
l_role_display_name WF_ALL_ROLES_VL.DISPLAY_NAME%TYPE;
i number :=1;

cursor find_role_disp_name is select display_name from
WF_ALL_ROLES_vl where name = l_role_name;

begin

  IF p_role_name IS NULL THEN
   RETURN NULL;
  END IF;

  WF_ROLE_HIERARCHY.GetRelationships(p_name         => p_role_name,
                                     p_superiors    => l_superiors,
                                     p_subordinates => l_subordinates);

  length_sup := l_subordinates.count;

  IF length_sup = 0 THEN
   RETURN NULL;
  END IF;

  jtf_dbstream_utils.clearOutputStream;
  jtf_dbstream_utils.writeInt(length_sup);

  -- Iterate through the table and create a delimited string
  loop

     if i > length_sup then -- terminating condition
     exit;
     end if;

       l_role_name := l_subordinates(i).SUB_NAME;

       open find_role_disp_name;
        fetch find_role_disp_name into l_role_display_name;

        jtf_dbstream_utils.writeString(l_role_display_name);
       close find_role_disp_name;
     i := i+1;
  end loop;

 return jtf_dbstream_utils.getOutputStream;

end getAffectedRoles;

PROCEDURE  insert_role(p_role_name        in varchar2,
                         p_orig_system      in varchar2,
                         p_orig_system_id   in number,
                         p_start_date       in date,
                         p_expiration_date  in date,
                         p_display_name     in varchar2,
                         p_owner_tag        in varchar2,
                         p_description      in varchar2) IS

l_params wf_parameter_list_t;
begin

  populateRecord(p_role_name        => p_role_name,
                 p_display_name     => p_display_name,
                 p_owner_tag        => p_owner_tag,
                 p_description      => p_description,
                 p_params           => l_params     );

  WF_LOCAL_SYNCH.propagate_role(p_orig_system     => p_orig_system,
                                p_orig_system_id  => p_orig_system_id,
                                p_attributes      => l_params,
                                p_start_date      => p_start_date,
                                p_expiration_date => p_expiration_date);


end insert_role;

PROCEDURE  update_role(p_role_name        in varchar2,
                         p_orig_system      in varchar2,
                         p_orig_system_id   in number,
                         p_start_date       in date,
                         p_expiration_date  in date,
                         p_display_name     in varchar2,
                         p_owner_tag        in varchar2,
                         p_description      in varchar2) IS

l_params wf_parameter_list_t;
begin

  populateRecord(p_role_name        => p_role_name,
                 p_display_name     => p_display_name,
                 p_owner_tag        => p_owner_tag,
                 p_description      => p_description,
                 p_params           => l_params     );

  WF_EVENT.AddParameterToList(p_name          => 'UPDATEONLY',
                              p_value         => 'TRUE',
                              p_parameterlist => l_params);


  WF_EVENT.AddParameterToList(p_name          => 'WFSYNCH_OVERWRITE',
                              p_value         => 'TRUE',
                              p_parameterlist => l_params);

  WF_LOCAL_SYNCH.propagate_role(p_orig_system     => p_orig_system,
                                p_orig_system_id  => p_orig_system_id,
                                p_attributes      => l_params,
                                p_start_date      => p_start_date,
                                p_expiration_date => p_expiration_date);


end update_role;

PROCEDURE propagateUserRole(p_user_name             in varchar2,
                            p_role_name             in varchar2,
                            p_start_date            in date,
                            p_expiration_date       in date
                            )IS

begin

  WF_LOCAL_SYNCH.propagateUserRole(p_user_name    => p_user_name,
                                p_role_name       => p_role_name,
                                p_start_date      => p_start_date,
                                p_expiration_date => p_expiration_date,
                                p_overwrite       => TRUE ,
                                p_raiseErrors     => TRUE);

end propagateUserRole;

PROCEDURE propagateUserRole(p_user_name             in varchar2,
                            p_role_name             in varchar2,
                            p_start_date            in date,
                            p_expiration_date       in date,
                            p_assignmentReason	    in varchar2
                            )IS

begin

  WF_LOCAL_SYNCH.propagateUserRole(p_user_name    => p_user_name,
                                p_role_name       => p_role_name,
                                p_start_date      => p_start_date,
                                p_expiration_date => p_expiration_date,
                                p_overwrite       => TRUE ,
                                p_raiseErrors     => TRUE,
                                p_assignmentReason => p_assignmentreason);

end propagateUserRole;

   --
   -- HierarchyEnabled
   --
   -- IN
   --   p_origSystem  (VARCHAR2)
   --
   -- RETURNS
   --   'Y' - if orig system is hierarchy enabled, 'N' otherwise
   --
   -- NOTES
   --  Wrapper on top of WF_ROLE_HIERARCHY.HierarchyEnabled
   --
     function HierarchyEnabled (p_origSystem in VARCHAR2) return varchar2
     is
       l_result  boolean;

     begin

       -- for orig system UMX or FND_RESP, always return 'Y'
       if( (p_origSystem = 'UMX') or ( p_origSystem = 'FND_RESP' ) ) then
         return 'Y';
       end if;

       l_result := WF_ROLE_HIERARCHY.HierarchyEnabled( p_origSystem);

       if( l_result = TRUE ) then
         return 'Y';
       else
         return 'N';
       end if;
     end HierarchyEnabled;

  --
  -- TEST
  --   Wrapper to Test if function is accessible under current responsibility.
  -- IN
  --   p_function_name          - function to test
  --   p_TEST_MAINT_AVAILABILTY - 'Y' (default) means check if available for
  --                              current value of profile APPS_MAINTENANCE_MODE
  --                              'N' means the caller is checking so it's
  --                              unnecessary to check.
  -- RETURNS
  --  'Y' if function is accessible
  --
  function test (p_function_name           in varchar2,
                 p_test_maint_availability in varchar2 default 'Y') return varchar2 is

  begin
    if (fnd_function.test(p_function_name, p_test_maint_availability)) then
      return ('Y');
    else
      return ('N');
    end if;
  end test;

end UMX_ACCESS_ROLES_PVT;

/
