--------------------------------------------------------
--  DDL for Package Body UMX_W3H_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_W3H_UTL" AS
 /* $Header: UMXW3HUTLB.pls 120.6 2008/05/23 07:55:36 kkasibha noship $ */

	/*type to store the excluded function list*/
	TYPE TYPE_W3H_FUNCTIONS_TAB is table of VARCHAR2(1000) index by VARCHAR2(1000);
	l_function_list TYPE_W3H_FUNCTIONS_TAB; --stores the excluded functions list for a given resp

   --  Function
  --  getObjectDetails
  --
  -- Description
  -- This method takes in the name of permission set for the corresponding
  -- database security object and returns the list for the
  -- permission set
  -- IN
  -- p_menu_name - takes in FND_MENUS.MENU_NAME%TYPE object
  -- RETURNS
  -- List for the permission set

function getObjectDetails(p_menu_name in FND_MENUS.MENU_NAME%TYPE)
           return varchar2

IS

l_menu_name FND_MENUS.MENU_NAME%TYPE;
l_function_name FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
l_list varchar2(3200);

cursor function_list IS
select frm.function_name
from fnd_form_functions frm,fnd_compiled_menu_functions fcm,fnd_menus fm
where frm.function_id=fcm.function_id
and fcm.menu_id=fm.menu_id
and fm.menu_name=l_menu_name;

begin
   l_menu_name := p_menu_name;
   l_list := null;
   if function_list%ISOPEN then
      close function_list;
   end if;
   open function_list;
   loop
      fetch function_list into l_function_name;
      EXIT WHEN function_list%NOTFOUND;
      l_list := l_list || l_function_name || ',';
      if length(l_list) > 3000 then
         exit;
      end if;
   end loop;
   close function_list;
   if length(l_list) > 0 then
      l_list :=  substr(l_list,1,length(l_list)-1);
   end if;
   if length(l_list) > 3000 then
      l_list := substr(l_list,1,2996);
      l_list := substr(l_list,1,instr(l_list,',',-1,1)) || '...';
   end if;
   -- dbms_output.put_line('Menu List:' || l_list);
   return l_list;
end getObjectDetails;
/***************************************************************************************/


  -- Function
  -- isFunctionAccessible
  --
  -- Description
  -- This method takes in user name and role name for the a list of functions
  -- for a user and returns true or false for accessibility
  -- IN
  -- p_user_name - varchar2 (takes the user_name)
  -- p_role_name - varchar2 (takes the role_name)
  -- RETURNS
  -- result as true or false

function isFunctionAccessible(
      p_user_name in varchar2,p_role_name in varchar2) return varchar2

IS

l_result varchar2(5);
l_user_name varchar2(100);
l_role_name varchar2(480);
l_user_start_date date;
l_user_end_date date;
l_role_start_date date;
l_role_end_date date;
l_effective_start_date date;
l_effective_end_date date;
l_assignment_start_date date;
l_assignment_end_date date;

begin
 select start_date,end_date into l_user_start_date,l_user_end_date
 from fnd_user where user_name = p_user_name;

 select min(role_start_date) ,max(nvl(role_end_date,to_date('31-12-9999','DD-MM-YYYY'))),min(effective_start_date),
max(nvl(effective_end_date,to_date('31-12-9999','DD-MM-YYYY'))),min( start_date),max(nvl(end_date,to_date('31-12-9999','DD-MM-YYYY')))
 into l_role_start_date,l_role_end_date,l_effective_start_date,l_effective_end_date,
 l_assignment_start_date,l_assignment_end_date
 from wf_user_role_assignments
 where user_name=p_user_name and role_name = p_role_name;

-- check whether user is inactive
  if(l_user_start_date > sysdate or l_user_end_date <= sysdate) then

    if(l_role_start_date > sysdate or l_role_end_date <= sysdate) then
        l_result := 'false';
    elsif(l_assignment_start_date > sysdate or l_assignment_end_date <= sysdate) then
        l_result := 'false';
    else
         l_result := 'true';
    end if;
   -- this means user is active, we check for effective dates
  elsif(l_effective_start_date > sysdate or l_effective_end_date <= sysdate) then
        l_result := 'false';
  else
         l_result := 'true';
  end if;

  -- return the result
  return l_result;
end isFunctionAccessible;
/***************************************************************************************/


  -- Function
  -- get_excluded_function_list
  --
  -- Description
  -- This method takes in the name of the responsibility, gets all the excluded function for the resps in its hierarchy and places them in a associative array
  -- IN
  -- p_resp_name - varchar2 (name of the responsibility)
  -- RETURNS
  -- result as Success on success, error message on failure
/* This procedure will populate the l_function_list table type with all the excluded functions*/

FUNCTION get_excluded_function_list(p_resp_name WF_ROLES.NAME%TYPE) RETURN VARCHAR2 IS
	/*cursor to gte all the functions excluded for a given reponsibility hierarchy*/
	CURSOR func_list IS
	select distinct wur.name||frm.function_name
	from fnd_responsibility fr,fnd_resp_functions frf, wf_local_roles wur,fnd_form_functions frm,
	(select wur1.name roleName from wf_local_roles wur1
		where wur1.name = p_resp_name
	union
	select super_name roleName from wf_role_hierarchies
		  where enabled_flag='Y'
		  connect by prior super_name=sub_name
		  and prior enabled_flag='Y'
		  start with sub_name= p_resp_name) roles
	where wur.name = roles.roleName
	and	fr.responsibility_key = substr(wur.name,instr(wur.name,'|',1,2)+1,(instr(wur.name,'|',1,3)-1-instr(wur.name,'|',1,2)))
	and frf.responsibility_id=fr.responsibility_id
	and ((frf.rule_type='F' and frf.action_id = frm.function_id)
			  or (frf.rule_type='M' and frm.function_id in (select fcm.function_id from fnd_compiled_menu_functions fcm
															where fcm.menu_id=frf.action_id)
				 ));

	func varchar2(1000);	/*temp var to store thevalues fetched from the cursor*/
	RET NUMBER;
BEGIN
	/*clear the table before adding the new data*/
	begin
		l_function_list.delete(l_function_list.first,l_function_list.last);
	exception
		when others then
			null;
	end;

	OPEN func_list;
	LOOP
		FETCH func_list INTO func;
		EXIT WHEN func_list%NOTFOUND;
		l_function_list(func) := func;	--insert the fuction into the table
	END LOOP;
	close func_list;
	RETURN 'SUCCESS';
EXCEPTION
	WHEN OTHERS THEN
		RETURN 'ERROR : '||SQLCODE||' : '||SQLERRM;
END get_excluded_function_list;
/***************************************************************************************/

  -- Function
  -- is_function_menu_excluded
  --
  -- Description
  -- This method takes in the name of the function to find
  -- and the responsibility name under which the function is to be searched for accssiblity
  -- IN
  -- func_to_find - varchar2 (name of the function to find)
  -- resp_name - varchar2 (responsibility name)
  -- RETURNS
  -- result as Yes or No
/*This function accepts the function anme and the resp name in which the function is tobe searched,.
Returns 'Yes', if the function is found under the resp else 'no' is returned.
*/

FUNCTION is_function_menu_excluded(func_to_find FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE,resp_name WF_LOCAL_ROLES.NAME%TYPE) RETURN VARCHAR2 IS
BEGIN
	/*Check whether the function is present in the function list*/
	IF(l_function_list(resp_name||func_to_find)=resp_name||func_to_find) THEN
		RETURN 'Yes';
	END IF;
	RETURN 'NO';
EXCEPTION
	WHEN OTHERS THEN
		RETURN 'No';
END is_function_menu_excluded;
/***************************************************************************************/


end UMX_W3H_UTL;

/
