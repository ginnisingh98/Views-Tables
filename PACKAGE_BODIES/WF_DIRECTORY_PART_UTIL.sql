--------------------------------------------------------
--  DDL for Package Body WF_DIRECTORY_PART_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_DIRECTORY_PART_UTIL" as
/* $Header: wfdpub.pls 120.1 2005/07/02 03:45:45 appldev noship $ */

procedure validate_display_name (
p_display_name in varchar2,
p_user_name    in out nocopy varchar2) IS

l_colon         NUMBER := 0;
l_names_count   NUMBER := 0;
l_name          VARCHAR2(320);
l_upper_name    VARCHAR2(360);
l_orig_system_id NUMBER;
l_get_role      BOOLEAN := TRUE;

role_info_tbl wf_directory.wf_local_roles_tbl_type;

--Bug 3626135
--Added the order by clause to recterive the record
--based on status and start date in ascending order
cursor r_name_lov is
  select NAME
    from WF_ROLE_LOV_VL
   where DISPLAY_NAME = p_display_name
   order by status, start_date;

BEGIN

   /*
   ** Make sure to blank out the internal name if the user originally
   ** used the LOV to select the name and then blanked out the display
   ** name then make sure here to blank out the insternal name and return
   */
   if (p_display_name is null) then

      p_user_name := NULL;
      return;

   end if;

   /*
   ** Bug# 2236250 validating the display name to contain a valid number
   ** after the colon to be used as a internal name for the role
   */
   l_colon := instr(p_display_name, ':');
   if (l_colon > 0) then
      begin
         l_orig_system_id := to_number(substr(p_display_name, l_colon+1));
      exception
         when value_error then
             l_get_role := FALSE;
         when others then
             raise;
      end;
      l_colon := 0;
   end if;

   /*
   ** First look first for internal name to see if you find a match.  If
   ** there are duplicate internal names that match the criteria then
   ** there is a problem with directory services but what can you do.  Go
   ** ahead and pick the first name so you return something
   **
   ** Bug# 2236250 calling Wf_Directory.GetRoleInfo2 only if the value
   ** after ':' is numeric.
   */
   if (l_get_role) then
      Wf_Directory.GetRoleInfo2(upper(p_display_name),role_info_tbl);
      l_name := role_info_tbl(1).name;
   end if;

   /*
   ** If you found a match on internal name then set the p_user_name
   ** accordingly.
   */
   if (l_name IS NOT NULL) then

      p_user_name := l_name;

   /*
   ** If there was no match on internal name then check for a display
   ** name
   */
   else

      open r_name_lov;
      loop

         /*
         ** Check out how many names match the display name
         */
         fetch r_name_lov into l_name;
         /*
         ** If there are no matches for the display name then raise an error
         */
         if (r_name_lov%ROWCOUNT = 0) then
            close r_name_lov;
            -- Not displayed or internal role name, error
            wf_core.token('ROLE', p_display_name);
            wf_core.raise('WFNTF_ROLE');
         end if;

         exit when r_name_lov%NOTFOUND;

         /*
         ** If there is more than one match then see if the user
         ** used the lov to select the name in which case the combination
         ** of the display name and the user name should be unique
         */
         if (r_name_lov%ROWCOUNT > 1) then
            close r_name_lov;

            -- copy logic from wf_directory.getroleinfo2
            l_colon := instr(p_user_name,':');

            if (l_colon = 0) then
             select count(1)
               into l_names_count
               from WF_ROLES
              where NAME = p_user_name
                and ORIG_SYSTEM not in ('HZ_PARTY','POS','ENG_LIST','AMV_CHN',
                                        'HZ_GROUP','CUST_CONT')
                and DISPLAY_NAME = p_display_name;
            else
            /*
            ** Bug# 2236250 validate if the value after ':' is number
            ** before using it in the query
            */
              begin
                 l_orig_system_id := to_number(substr(p_user_name, l_colon+1));
              exception
                 when value_error then
                    wf_core.raise('WFNTF_ORIGSYSTEMID');
                 when others then
                    raise;
              end;
              select count(1)
                into l_names_count
                from WF_ROLES
               where NAME = p_user_name
                 and ORIG_SYSTEM    = substr(p_user_name, 1, l_colon-1)
                 and ORIG_SYSTEM_ID = l_orig_system_id
                 and DISPLAY_NAME = p_display_name;
            end if;

            if (l_names_count <> 1) then
              wf_core.token('ROLE', p_display_name);
              wf_core.raise('WFNTF_UNIQUE_ROLE');
            end if;

            exit;
         end if;

         /*
         ** If there is just one match then get the internal name
         ** and assign it.
         */
         p_user_name  := l_name;
      end loop;
      if (r_name_lov%ISOPEN) then
        close r_name_lov;
      end if;
   end if;

exception
  when others then
    if (r_name_lov%ISOPEN) then
      close r_name_lov;
    end if;
    wf_core.context('Wf_Directory_Part_Util', 'validate_display_name',
      p_display_name, p_user_name);
    raise;
end validate_display_name;

end WF_DIRECTORY_PART_UTIL;

/
