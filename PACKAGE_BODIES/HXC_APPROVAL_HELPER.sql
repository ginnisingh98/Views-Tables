--------------------------------------------------------
--  DDL for Package Body HXC_APPROVAL_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APPROVAL_HELPER" AS
/* $Header: hxcaprhlp.pkb 120.1 2006/03/06 19:16:07 arundell noship $ */

  type user_info is record
      (person_id number,
       last_name varchar2(150),
       full_name varchar2(240)
       );

  p_user_info user_info;

  c_role_prefix constant varchar2(4) := 'OTL-';

  Function formAdHocRoleName
     (p_user_info in user_info)
     Return varchar2 is
  Begin

     return c_role_prefix||p_user_info.person_id||'-'||upper(p_user_info.last_name);

  End formAdHocRoleName;

  Function getPersonInfo
     (p_person_id in per_all_people_f.person_id%type)
     Return user_info is

     cursor c_person_info(p_person_id in per_all_people_f.person_id%type) is
       select p1.last_name,
              p1.full_name
         from per_all_people_f p1
        where p1.person_id = p_person_id
          and p1.effective_end_date =
              (select max(p2.effective_end_date)
                 from per_all_people_f p2
                where p2.person_id = p1.person_id);

     l_user_info user_info;

  Begin
     l_user_info.person_id := p_person_id;
     open c_person_info(p_person_id);
     fetch c_person_info into l_user_info.last_name, l_user_info.full_name;
     if(c_person_info%notfound) then
        close c_person_info;
        fnd_message.set_name('PER','PER_289467_REQ_INV_PERSON_ID');
        fnd_message.raise_error;
     else
        close c_person_info;
     end if;

     return l_user_info;
  End getPersonInfo;

/* Public Functions and Procedures */

  Function createAdHocUser
     (p_resource_id in hxc_time_building_blocks.resource_id%type,
      p_effective_date in hxc_time_building_blocks.start_time%type)
     Return varchar2 is

     cursor c_dup_check
        (p_name in wf_users.name%type) is
       select 'Y'
         from wf_users
        where name = p_name;

     l_dummy varchar2(1);

     l_name wf_local_roles.name%type;
     l_user_info user_info;

  Begin

     l_user_info := getPersonInfo(p_resource_id);
     l_name := formAdHocRoleName(l_user_info);

     open c_dup_check(l_name);
     fetch c_dup_check into l_dummy;
     if(c_dup_check%notfound) then
        wf_directory.createAdHocUser
           (name => l_name,
            display_name => l_user_info.full_name,
            description => 'OTL Approval: AdHocRole Generated'
            );
     end if;
     close c_dup_check;

     return l_name;

  End createAdHocUser;

END hxc_approval_helper;

/
