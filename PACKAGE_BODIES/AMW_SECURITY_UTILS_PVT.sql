--------------------------------------------------------
--  DDL for Package Body AMW_SECURITY_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_SECURITY_UTILS_PVT" AS
/*$Header: amwsutlb.pls 120.0 2005/05/31 21:07:54 appldev noship $*/


procedure give_dependant_grants (p_grant_guid  IN  raw,
                                 p_parent_obj_name in varchar2,
                                 p_parent_role in varchar2,
                                 p_parent_pk1 in varchar2,
                                 p_parent_pk2 in varchar2,
                                 p_parent_pk3 in varchar2,
                                 p_parent_pk4 in varchar2,
                                 p_parent_pk5 in varchar2,
                                 p_grantee_type in varchar2,
                                 p_grantee_key in varchar2,
                                 p_start_date in date,
                                 p_end_date in date,
                                 x_success  OUT NOCOPY VARCHAR, /* Boolean */
                                 x_errorcode OUT NOCOPY NUMBER)
is


l_api_name constant varchar2(30) := 'give_dependant_grants';



l_grant_guid  fnd_grants.grant_guid%type;



l_default_name constant varchar2(80) := 'AMW_AUTOMATIC_DEPENDANT_GRANT';
l_default_description constant varchar2(240) := 'Dependant instance set based grant on child object';

cursor c is (select parent_role_name, child_obj_name,
                    child_role_name, child_instance_set_id
from amw_security_role_mappings where parent_obj_name = p_parent_obj_name
and  (parent_role_name = p_parent_role or parent_role_name = 'ANY'));


type t_c is table of c%rowtype;
t_ctbl t_c;

l_start_date date;
l_child_role_name amw_security_role_mappings.child_role_name%type;


begin


if p_start_date is null
then l_start_date := sysdate;
else l_start_date := p_start_date;
end if;


open c;
fetch c bulk collect into t_ctbl;
close c;

if t_ctbl.exists(1) then
for ctr in t_ctbl.first .. t_ctbl.last loop
  if (t_ctbl(ctr).parent_role_name = 'ANY' and t_ctbl(ctr).child_role_name = 'SAME')
  then
    l_child_role_name := p_parent_role;
  else
    l_child_role_name := t_ctbl(ctr).child_role_name;
  end if;


  fnd_grants_pkg.grant_function(p_api_version => g_api_version,
                                p_menu_name   => l_child_role_name,
                                p_object_name => t_ctbl(ctr).child_obj_name,
                                p_instance_type => 'SET',
                                p_instance_set_id => t_ctbl(ctr).child_instance_set_id,
                                p_grantee_type => p_grantee_type,
                                p_grantee_key => p_grantee_key,
                                p_start_date => l_start_date,
                                p_end_date => p_end_date,
                                p_parameter1 => p_parent_pk1,
                                p_parameter2 => p_parent_pk2,
                                p_parameter3 => p_parent_pk3,
                                p_parameter4 => p_parent_pk4,
                                p_parameter5 => p_parent_pk5,
                                p_parameter10 => p_grant_guid, --store a pointer to parent grant
                                p_name => l_default_name,
                                p_description => l_default_description,
                                x_success    => x_success, /* Boolean */
                                x_errorcode  => x_errorcode,
                                x_grant_guid => l_grant_guid);








end loop;
end if;

exception
  when OTHERS then

     x_success := FND_API.G_FALSE ;
     x_errorcode:=-1;


end give_dependant_grants;

procedure update_dependant_grants(p_grant_guid in raw,
                                  p_new_start_date in date,
                                  p_new_end_date in date,
                                  x_success  OUT NOCOPY VARCHAR /* Boolean */)
is
l_api_name constant varchar2(30) := 'update_dependant_grants';




l_start_date date;



l_grant_guid fnd_grants.grant_guid%type;
type t_guid is table of fnd_grants.grant_guid%type;
guid_tbl t_guid;

cursor c_guid
is select grant_guid from fnd_grants where
parameter10 = p_grant_guid;



begin


if p_new_start_date is null
then l_start_date := sysdate;
else l_start_date := p_new_start_date;
end if;





  open c_guid;
  fetch c_guid bulk collect into guid_tbl;
  close c_guid;

  if guid_tbl.exists(1) then
    for i in guid_tbl.first .. guid_tbl.last loop


      fnd_grants_pkg.update_grant(p_api_version  => g_api_version,
                                  p_grant_guid   => guid_tbl(i),
                                  p_start_date   => l_start_date,
                                  p_end_date     => p_new_end_date,
                                  x_success      => x_success);

    end loop;
  end if;


exception
  when OTHERS then
    x_success := FND_API.G_FALSE ;

end update_dependant_grants;

procedure revoke_dependant_grants(p_grant_guid in raw,
                                  x_success        OUT NOCOPY VARCHAR2, /* Boolean */
                                  x_errorcode      OUT NOCOPY NUMBER)
is
l_api_name constant varchar2(30) := 'revoke_dependant_grants';


l_grant_guid fnd_grants.grant_guid%type;
type t_guid is table of fnd_grants.grant_guid%type;
guid_tbl t_guid;

cursor c_guid
is select grant_guid from fnd_grants where
parameter10 = p_grant_guid;


begin

  open c_guid;
  fetch c_guid bulk collect into guid_tbl;
  close c_guid;

  if guid_tbl.exists(1) then
    for i in guid_tbl.first .. guid_tbl.last loop


      fnd_grants_pkg.revoke_grant(p_api_version  => g_api_version,
                                  p_grant_guid   => guid_tbl(i),
                                  x_success      => x_success,
                                  x_errorcode    => x_errorcode);

    end loop;
  end if;


exception
  when OTHERS then
    x_success := FND_API.G_FALSE ;
    x_errorcode := -1;
end revoke_dependant_grants;

FUNCTION get_party_id return number

is

l_party_id number;

begin
  select party_id into l_party_id
  from amw_employees_current_v
  where employee_id = (select employee_id from fnd_user where user_name = FND_GLOBAL.user_name)
  and   rownum = 1;

  return l_party_id;

exception
  when others then
    return null;


end get_party_id;


FUNCTION check_function
  (
   p_function            IN  VARCHAR2,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value  IN  VARCHAR2,
   p_instance_pk2_value  IN  VARCHAR2,
   p_instance_pk3_value  IN  VARCHAR2,
   p_instance_pk4_value  IN  VARCHAR2,
   p_instance_pk5_value  IN  VARCHAR2
 )
 RETURN VARCHAR2 IS

 l_data_security_switch varchar2(1);
 l_user_name varchar2(80);
 l_party_id number;

 BEGIN

 if (fnd_global.user_name is null) then
   raise FND_API.G_EXC_UNEXPECTED_ERROR;
 end if;

 l_data_security_switch := fnd_profile.value('AMW_DATA_SECURITY_SWITCH');


 if(l_data_security_switch is null or l_data_security_switch = 'N') then
   return 'T';
 else
   l_party_id := get_party_id;

   if(l_party_id is null) then
     l_user_name := FND_GLOBAL.user_name;
   else
      l_user_name := 'HZ_PARTY:' || l_party_id;
   end if;

   return FND_DATA_SECURITY.check_function( p_api_version => g_api_version
   					   ,p_function => p_function
   					   ,p_object_name => p_object_name
   					   ,p_instance_pk1_value => p_instance_pk1_value
   					   ,p_instance_pk2_value => p_instance_pk2_value
   					   ,p_instance_pk3_value => p_instance_pk3_value
   					   ,p_instance_pk4_value => p_instance_pk4_value
   					   ,p_instance_pk5_value => p_instance_pk5_value
   					   ,p_user_name          => l_user_name);
 end if;

 exception
   when others then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;

 END;


end AMW_SECURITY_UTILS_PVT;

/
