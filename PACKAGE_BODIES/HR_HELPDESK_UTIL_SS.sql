--------------------------------------------------------
--  DDL for Package Body HR_HELPDESK_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HELPDESK_UTIL_SS" As
/* $Header: hrhdutilss.pkb 120.1.12010000.11 2009/09/23 08:58:10 tkghosh ship $ */
--
-- Package variables
--

FUNCTION get_person_id
     ( emp_id IN per_all_people_f.employee_number%type,
       bg_id IN per_all_people_f.business_group_id%type,
       cwk_id IN per_all_people_f.npw_number%type)
     RETURN  varchar2
     IS
     pers_id varchar2(10);
BEGIN

     if (trim(cwk_id) is not null or trim(cwk_id) <> 0) then

        select distinct person_id into pers_id
        from per_all_people_f
        where npw_number = cwk_id and
        business_group_id = bg_id and
        current_npw_flag='Y' and
        sysdate between effective_start_date and
        effective_end_date;

     else

        select distinct person_id into pers_id
        from per_all_people_f
        where employee_number = emp_id and
        business_group_id = bg_id and
        current_employee_flag='Y' and
        sysdate between effective_start_date and
        effective_end_date;

    end if;

     return pers_id;

EXCEPTION
        when others then
        return 'E';

END get_person_id;


FUNCTION get_assgn_id
     (pers_id per_all_people_f.person_id%type )
     RETURN  varchar2 is
     --pers_id varchar2(10);
     ass_id varchar2(10);
BEGIN

     --pers_id := get_person_id(emp_id,bg_id,cwk_id);

     select distinct assignment_id into ass_id
     from per_all_assignments_f
     where person_id = pers_id
     and assignment_type in('E','A','C')
     and sysdate between effective_start_date and
     effective_end_date and
     decode(assignment_type,'A','N','Y') = primary_flag;

     return ass_id;

EXCEPTION
        when others then
        return 'E';

END get_assgn_id;


FUNCTION get_person_status
     ( person_id IN per_all_people_f.person_id%type)
     RETURN  varchar2 is
     per_sts number;
BEGIN
        select count(*) into per_sts from per_people_f
        where person_id = person_id and
        sysdate between effective_start_date and effective_end_date;

        if per_sts > 0 then
            return 'Y';
        else
             return 'E';
        end if;


EXCEPTION
        when others then
        return 'E';

END get_person_status;

FUNCTION get_assign_status
     ( assig_id IN per_all_assignments_f.assignment_id%type)
     RETURN  varchar2 is
     ass_sts number;
BEGIN
        select count(*) into ass_sts from per_assignments_f
        where assignment_id = assig_id and
        sysdate between effective_start_date and
        effective_end_date and
        primary_flag ='Y';

        if ass_sts > 0 then
            return 'Y';
        else
            return 'E';
        end if;

EXCEPTION
        when others then
        return 'E';

END get_assign_status;


FUNCTION validate_function
    (func_name fnd_form_functions.function_name%type,
     bus_grp_id per_all_people_f.business_group_id%type)
    RETURN varchar2 is
     l_count number;
     p_count number;

BEGIN


SELECT COUNT(function_id)
INTO l_count
FROM
  (SELECT fme.function_id,
     fme.menu_id
   FROM fnd_menu_entries fme START WITH fme.menu_id IN
    (SELECT menu_id
     FROM fnd_responsibility
     WHERE responsibility_id IN
      (SELECT responsibility_id
       FROM fnd_user_resp_groups
       WHERE user_id = fnd_global.user_id)
    )
  CONNECT BY fme.menu_id = PRIOR fme.sub_menu_id)
WHERE function_id IN
  (SELECT function_id
   FROM fnd_form_functions
   WHERE function_name = 'HR_HELPDESK_SS')
;


if l_count > 0 then

SELECT COUNT(function_id)
INTO p_count
FROM
  (SELECT fme.function_id,
     fme.menu_id
   FROM fnd_menu_entries fme START WITH fme.menu_id IN
    (SELECT menu_id
     FROM fnd_responsibility
     WHERE responsibility_id IN
      (SELECT responsibility_id
       FROM fnd_user_resp_groups
       WHERE user_id = fnd_global.user_id
       AND security_group_id =
        (SELECT security_group_id
         FROM per_business_groups
         WHERE business_group_id = bus_grp_id)
      )
    )
  CONNECT BY fme.menu_id = PRIOR fme.sub_menu_id)
WHERE function_id IN
  (SELECT function_id
   FROM fnd_form_functions
   WHERE function_name = func_name)
;

	if p_count > 0 then
		return 'Y';
	else
		return 'N';
	end if;

else
	return 'E';
end if;

EXCEPTION
	when others then
	return 'E';

END validate_function;



FUNCTION get_function_type(func_name IN VARCHAR2)
     return varchar2 is

     func_type varchar2(5);

BEGIN

     SELECT type INTO func_type FROM fnd_form_functions WHERE function_name = func_name;
     If func_type = 'FORM' then
      return 'F';
     Elsif func_type = 'JSP' then
      return 'J';
    Else
      return 'E';
    End if;

EXCEPTION
      When others then
        return 'E';

END get_function_type;


FUNCTION get_resp_name(func_name fnd_form_functions.function_name%type,
    bus_grp_id per_all_people_f.business_group_id%type)
RETURN VARCHAR2 IS

l_resp_name fnd_responsibility.RESPONSIBILITY_KEY%type;

BEGIN

SELECT responsibility_key
INTO l_resp_name
FROM fnd_responsibility
WHERE menu_id IN
  (SELECT menu_id
   FROM fnd_menu_entries fme START WITH fme.function_id =
    (SELECT function_id
     FROM fnd_form_functions
     WHERE function_name = func_name)
  CONNECT BY PRIOR fme.menu_id = fme.sub_menu_id)
AND responsibility_id IN
  (SELECT responsibility_id
   FROM fnd_user_resp_groups
   WHERE user_id = fnd_global.user_id
   AND security_group_id =
    (SELECT security_group_id
     FROM per_business_groups
     WHERE business_group_id = bus_grp_id)
  )
;

   RETURN l_resp_name;

   EXCEPTION

	 WHEN OTHERS THEN
    RETURN 'E';

END get_resp_name;


FUNCTION get_secgrp_key(bus_grp_id IN PER_BUSINESS_GROUPS.business_group_id%type)
   RETURN VARCHAR2 IS

   l_secgrp_key fnd_security_groups.SECURITY_GROUP_KEY%type;
BEGIN

   SELECT security_group_key
   INTO l_secgrp_key
   FROM fnd_security_groups
   WHERE security_group_id =
   (select security_group_id from PER_BUSINESS_GROUPS
    where business_group_id = bus_grp_id);

   RETURN l_secgrp_key;

   EXCEPTION
   WHEN OTHERS THEN
    RETURN 'E';

END get_secgrp_key;

FUNCTION get_person_type_status
   (p_person_id IN per_all_people_f.person_id%type,
    eff_date IN varchar2,
    p_fn_name  IN varchar2)
   RETURN VARCHAR2 IS

   p_fet_emp boolean;
   p_fet_cwk boolean;
   p_eff_date Date;

BEGIN
  p_eff_date := to_date(eff_date, 'yyyy-MM-dd');

  p_fet_emp := hr_general2.is_person_type
               (p_person_id           => p_person_id
               ,p_person_type  => 'EMP'
               ,p_effective_date      => p_eff_date);

  p_fet_cwk := hr_general2.is_person_type
               (p_effective_date      => p_eff_date
               ,p_person_id           => p_person_id
               ,p_person_type  => 'CWK');

	if (not p_fet_emp  and p_fn_name = 'PERWSQHM_MAINTAIN_EMPS') then
		return 'F';
	end if;

	if  (not p_fet_cwk and p_fn_name = 'PERWSQHM_MAINTAIN_CWK') then
		return 'F';
	end if;

	return 'T';

EXCEPTION
	when others then
	return 'F';

END get_person_type_status;


END;

/
