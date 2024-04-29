--------------------------------------------------------
--  DDL for Package Body JTF_TASK_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_SECURITY_PVT" AS
/* $Header: jtftkttb.pls 120.2 2005/09/02 00:03:28 akaran ship $ */



----
-- Creted on July 22, 2002 by mmarovic
-- This is a wrapper around FND function created to support Java API.
-- Please do not use it before ask Milan or Girish.
----
PROCEDURE get_privileges
  (
   p_api_version         IN  NUMBER,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value  IN  VARCHAR2 DEFAULT NULL, -- NULL= only chk global gnts
   p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_user_name           IN  VARCHAR2 DEFAULT NULL,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_privileges          OUT NOCOPY FND_TABLE_OF_VARCHAR2_30
 ) IS
    l_privilege_tbl        fnd_data_security.FND_PRIVILEGE_NAME_TABLE_TYPE;
    l_index                BINARY_INTEGER;
    l_return_status        VARCHAR2(1);
begin
  fnd_data_security.get_functions (
    p_api_version        => 1.0,
    p_object_name        => p_object_name,
    p_instance_pk1_value => p_instance_pk1_value,
    p_instance_pk2_value => p_instance_pk2_value,
    p_instance_pk3_value => p_instance_pk3_value,
    p_instance_pk4_value => p_instance_pk4_value,
    p_instance_pk5_value => p_instance_pk5_value,
    p_user_name          => p_user_name,
    x_return_status      => x_return_status,
    x_privilege_tbl      => l_privilege_tbl
  );

  x_privileges := FND_TABLE_OF_VARCHAR2_30();
  if x_return_status = 'T' then
    FOR l_index IN l_privilege_tbl.FIRST..l_privilege_tbl.LAST LOOP
      x_privileges.EXTEND;
      x_privileges(x_privileges.COUNT):= l_privilege_tbl(l_index);
    END LOOP;
  end if;

exception
  when others then
    fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
    fnd_msg_pub.add;
    x_return_status := 'U' ;
end get_privileges;

    function get_object_name ( p_object_code in varchar2 )
    return varchar2
    is
        l_name varchar2(30) ;
    begin
        select  name into l_name from jtf_objects_tl
        where object_code = p_object_code
        and language = userenv('lang');
        return l_name ;
    end ;




   FUNCTION check_privelege_for_task (
      p_task_id              NUMBER,
      p_resource_id          NUMBER,
      p_resource_type   IN   VARCHAR2
      )
      RETURN VARCHAR2
   IS
      x   CHAR;
      l_privlege_name fnd_form_functions.function_name%type;
      err varchar2(2000);
      l_current_privelege fnd_form_functions.function_name%type;

   BEGIN

      BEGIN
         SELECT 1
           INTO x
           FROM jtf_task_all_assignments
          WHERE task_id = p_task_id
            AND resource_id = p_resource_id
            AND resource_type_code = p_resource_type
            AND ROWNUM < 2;

         l_current_privelege := 'FULL';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
                  BEGIN
         		SELECT 1
           		INTO x
           		FROM jtf_task_all_assignments, jtf_rs_group_members
          		WHERE task_id = p_task_id
            		AND jtf_task_all_assignments.resource_id = group_id
            		AND resource_type_code = 'RS_GROUP'
            		AND jtf_rs_group_members.resource_id = p_resource_id
            		AND ROWNUM < 2;

        		l_current_privelege := 'FULL';
      		EXCEPTION
         		WHEN NO_DATA_FOUND THEN
            			BEGIN
         				SELECT 1
				        INTO x
           				FROM jtf_task_all_assignments, jtf_rs_team_members
          				WHERE task_id	 = p_task_id
            				AND jtf_task_all_assignments.resource_id = team_id
            				AND resource_type_code = 'RS_TEAM'
            				AND jtf_rs_team_members.team_resource_id = p_resource_id
            				AND ROWNUM < 2;

				         l_current_privelege := 'FULL';
      				EXCEPTION
         				WHEN NO_DATA_FOUND THEN
         				      begin
        						SELECT function_name
        						into l_privlege_name
        						FROM fnd_form_functions fff,
        						fnd_menu_entries fme,
        						fnd_menus fm,
        						fnd_grants fg,
        						fnd_objects,
        						jtf_tasks_b
        						WHERE fff.function_id = fme.function_id
        						AND fme.menu_id =  fm.menu_id
        						and fm.menu_id = fg.menu_id
        						and fg.instance_pk1_value = jtf_tasks_b.owner_id
        						and fg.instance_pk2_value = jtf_tasks_b.owner_type_code
        						and fg.grantee_key = TO_CHAR(p_resource_id)
        						and fg.object_id =  fnd_objects.object_id
        						and task_id = p_task_id
        						and obj_name = 'JTF_TASK_RESOURCE' ;



        					if l_privlege_name = jtf_task_utl.g_tasks_read_privelege then
            						l_current_privelege := 'READ';
        					end if ;

					        if l_privlege_name = jtf_task_utl.g_tasks_full_privelege then
            						l_current_privelege := 'FULL';
        					end if ;

    						exception
        						when no_data_found then
            						l_current_privelege := 'DENIED';
    						end ;
      				END;
      		END;
      END;

      if l_current_privelege  in ('FULL' )
      then
         BEGIN
         SELECT NVL (enter_from_task, 'N')
           INTO x
           FROM jtf_tasks_b, jtf_objects_b
          WHERE task_id = p_task_id
            AND source_object_type_code = object_code
            AND ROWNUM < 2;

         IF (x = 'N')
         THEN
            l_current_privelege := 'READ';
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;
      end if ;

      return l_current_privelege;

   EXCEPTION
   when others then
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         return 'UNKNOWN_ERROR' ;
   END;




FUNCTION get_default_query (profilename IN VARCHAR2,p_parameter_name in varchar2)
RETURN NUMBER  IS
   l_query_id number    := '-99';
BEGIN
   BEGIN
      SELECT query_id
        INTO l_query_id
        FROM jtf_perz_query_param
       WHERE parameter_name = p_parameter_name
       and parameter_value = 'Y'
	  and rownum < 2
       AND QUERY_ID IN
        ( select query_id from jtf_perz_query where profile_id in
            ( select profile_id from jtf_perz_profile where profile_name = profilename ));

    RETURN l_query_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            SELECT query_id
              INTO l_query_id
              FROM jtf_perz_query
             WHERE profile_id IN ( SELECT profile_id
                                     FROM jtf_perz_profile
                                    WHERE profile_name = '-99999:JTF_TASK');
            RETURN l_query_id;
         END;
   END;
END;



FUNCTION GET_CATEGORY_ID ( p_task_id in number ,
   p_resource_id in number ,
   p_resource_type_code in varchar2
)
  RETURN  number IS

  l_category_id number ;


BEGIN
select category_id into l_category_id
from jtf_task_all_assignments
where task_id = p_task_id
and resource_id = p_resource_id
and resource_type_code  = p_resource_type_code
and rownum < 2;


return l_category_id ;

EXCEPTION
   WHEN no_data_found THEN
    return 0;
END;


   FUNCTION check_private_task_privelege(
      p_task_id              IN   NUMBER,
      p_resource_id          IN   NUMBER,
      p_resource_type_code   IN   VARCHAR2
      )


      RETURN varchar2 is

      x char ;
      begin
      /* for optimization, the UI should check if the task is private .*/

      select 1 into x
      from jtf_task_all_assignments
      where task_id = p_task_id
      and p_resource_id = resource_id
      and p_resource_type_code = resource_type_code ;

      return 'Y' ;

      exception
      when  no_data_found then
        /* Bug 2186841 Private Tasks belonging to a group can't be queried upon */
        BEGIN
         		SELECT 1
           		INTO x
           		FROM jtf_task_all_assignments, jtf_rs_group_members
          		WHERE task_id = p_task_id
            		AND jtf_task_all_assignments.resource_id = group_id
            		AND resource_type_code = 'RS_GROUP'
            		AND jtf_rs_group_members.resource_id = p_resource_id
            		AND ROWNUM < 2;
                return 'Y' ;

      		    EXCEPTION
         		WHEN NO_DATA_FOUND THEN
            		BEGIN
         				SELECT 1
				        INTO x
           				FROM jtf_task_all_assignments, jtf_rs_team_members
          				WHERE task_id	 = p_task_id
            				AND jtf_task_all_assignments.resource_id = team_id
            				AND resource_type_code = 'RS_TEAM'
            				AND jtf_rs_team_members.team_resource_id = p_resource_id
            				AND ROWNUM < 2;
			           return 'Y' ;

      				   EXCEPTION
         			   WHEN NO_DATA_FOUND THEN
                       return 'N' ;
                    END ;
        END ;
      END ;


   procedure delete_category ( p_category_name in varchar2 )
   is
   l_perz_data_id number;

   begin

   select perz_data_id into l_perz_data_id
   from jtf_perz_data
   where perz_data_name = p_category_name ;

    update  jtf_task_all_assignments
    set category_id =  null
    where category_id = l_perz_data_id  ;

    update  jtf_cal_addresses
    set category =  null
    where category = l_perz_data_id  ;

    delete from jtf_perz_data
    where perz_data_id = l_perz_data_id ;

    commit;

   end ;


   Function priveleges_from_other_resource
  ( logged_in_resource  in number ,
    priveleges_from_resource_id in number ,
    priveleges_from_resource_type in varchar2
   )
  RETURN  varchar2 IS

  l_privlege_name varchar2(30) ;
BEGIN

/*
If the logged in resource is same as the resource whose privleges are checked,
then return full access.
*/
if priveleges_from_resource_type not in ( 'RS_GROUP', 'RS_TEAM' ) and
logged_in_resource = priveleges_from_resource_id
then
	return 'JTF_TASK_FULL_ACCESS' ;
end if ;





if priveleges_from_resource_type = 'RS_GROUP' then
begin
    select 1
    into l_privlege_name
    from jtf_rs_group_members
    where group_id = priveleges_from_resource_id
    and resource_id = logged_in_resource
    and rownum < 2;

    return 'JTF_TASK_FULL_ACCESS' ;
exception
    when no_data_found then
        null ;
        --return 'DENIED';*/
end ;
end if ;

if priveleges_from_resource_type = 'RS_TEAM' then
begin
    select 1
    into l_privlege_name
    from jtf_rs_team_members
    where TEAM_id = priveleges_from_resource_id
    and TEAM_resource_id = logged_in_resource
    and rownum < 2;

    return 'JTF_TASK_FULL_ACCESS' ;
exception
    when no_data_found  then
        null ;
        -- return 'DENIED';*/
end ;
end if ;

begin
SELECT function_name
into l_privlege_name
FROM fnd_form_functions fff,
fnd_menu_entries fme,
fnd_menus fm,
fnd_grants fg,
fnd_objects
WHERE fff.function_id = fme.function_id
AND fme.menu_id =  fm.menu_id
and fm.menu_id = fg.menu_id
and fg.instance_pk1_value = priveleges_from_resource_id
and fg.instance_pk2_value = priveleges_from_resource_type
and fg.grantee_key = TO_CHAR(logged_in_resource)
and fg.object_id =  fnd_objects.object_id
and obj_name = 'JTF_TASK_RESOURCE' ;

return l_privlege_name  ;
exception
    when no_data_found then
        return 'DENIED';
end ;

END;

END;

/
