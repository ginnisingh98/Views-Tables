--------------------------------------------------------
--  DDL for Package Body HR_NL_CALC_TARGET_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_CALC_TARGET_GROUP" AS
/* $Header: pernlctg.pkb 115.3 2002/06/12 02:40:49 pkm ship        $ */

--
FUNCTION get_country_code (p_person_id per_all_people_f.person_id%type,
			   p_contact_type per_contact_relationships.contact_type%type,
                           p_session_date date)
return VARCHAR2 is

l_cnty_of_birth per_all_people_f.country_of_birth%type;
l_data_flag varchar2(1);

begin
    l_data_flag := 'Y';
    begin
      select  a.country_of_birth
      into    l_cnty_of_birth
      from    per_all_people_f a,
	      per_contact_relationships b
      where   a.person_id = b.contact_person_id and
	      b.person_id = p_person_id and
	      b.contact_type = p_contact_type and
	      p_session_date between a.effective_start_date and a.effective_end_date and
              p_session_date between nvl(b.date_start, p_session_date) and
                                     nvl(b.date_end, p_session_date) and
              ROWNUM = 1
      order by b.date_start desc;
    exception
        when no_data_found then
	        l_cnty_of_birth := null;
                l_data_flag := 'N';
    end;

    if l_data_flag = 'N' then
      begin
        select a.country_of_birth
        into   l_cnty_of_birth
	from   per_all_people_f a,
	       per_contact_relationships b
	where  a.person_id = b.contact_person_id and
	       b.person_id = p_person_id and
	       b.contact_type = p_contact_type and
               p_session_date between nvl(b.date_start, p_session_date) and
                                      nvl(b.date_end, p_session_date) and
               ROWNUM = 1
        order by b.date_start desc, a.effective_start_date desc;
      exception
        when no_data_found then
	        l_cnty_of_birth := null;
      end;
    end if;

    return l_cnty_of_birth ;

end;
--
FUNCTION run_formula (p_country_of_birth_fth per_all_people_f.country_of_birth%type,
		      p_country_of_birth_mth per_all_people_f.country_of_birth%type,
		      p_country_of_birth_emp per_all_people_f.country_of_birth%type,
		      p_business_group_id per_all_people_f.business_group_id%type,
                      p_session_date date)
return VARCHAR2 is

l_formula_id 		ff_formulas_f_v.formula_id%type;
l_effective_start_date 	ff_formulas_f_v.effective_start_date%type;
l_target_group 		varchar2(10);

begin
	begin
		select formula_id ,effective_start_date
			into l_formula_id,l_effective_start_date
		from ff_formulas_f_v
		where formula_name = 'NL_TARGET_GROUP'
			and p_session_date between effective_start_date and
                                                   effective_end_date
                   and verified = 'Y';
	exception
	        when no_data_found then
		      hr_utility.set_message(800,'HR_NL_INVALID_FORMULA');
	              hr_utility.raise_error;
	end;
        --insert into fnd_sessions values (userenv('sessionid'),p_session_date);
	ff_client_engine.init_formula(l_formula_id,l_effective_start_date);
	ff_client_engine.set_input('BIRTH_COUNTRY_EMP', NVL(p_country_of_birth_emp,' '));
	ff_client_engine.set_input('BIRTH_COUNTRY_FATHER',p_country_of_birth_fth);
	ff_client_engine.set_input('BIRTH_COUNTRY_MOTHER',p_country_of_birth_mth);
	ff_client_engine.set_input('BUSINESS_GROUP_ID',p_business_group_id);
	ff_client_engine.run_formula;
	ff_client_engine.get_output('RETURN_VALUE',l_target_group);

	return l_target_group;
end;
--
FUNCTION get_target_group (p_person_id per_all_people_f.person_id%type,
                            p_session_date date) return VARCHAR2 is

l_country_of_birth_fth	per_all_people_f.country_of_birth%type;
l_country_of_birth_mth	per_all_people_f.country_of_birth%type;
l_country_of_birth_emp	per_all_people_f.country_of_birth%type;
l_business_group_id	per_all_people_f.business_group_id%type;
l_formula_id 		ff_formulas_f.formula_id%type;
l_effective_start_date 	ff_formulas_f.effective_start_date%type;
l_target_group 		varchar2(10);
l_label_text 		hr_lookups.meaning%type;
l_rec_status 		varchar2(20);
l_return_target_group   varchar2(1);
l_local_birth_country_fth per_all_people_f.per_information11%type;
l_local_birth_country_mth per_all_people_f.per_information12%type;

begin
        begin
          select per_information11, per_information12
          into   l_local_birth_country_fth, l_local_birth_country_mth
          from   per_all_people_f
	  where  person_id = p_person_id
          and    p_session_date between effective_start_date
                 and effective_end_date;
        exception
           when no_data_found then
            l_local_birth_country_fth:='';
            l_local_birth_country_mth:='';
        end;

        l_country_of_birth_fth:= get_country_code(p_person_id,'JP_FT',p_session_date);

	l_country_of_birth_mth:= get_country_code(p_person_id,'JP_MT',p_session_date);
        if l_country_of_birth_fth is null then
           if l_local_birth_country_fth is not null then
             l_country_of_birth_fth := l_local_birth_country_fth;
           else
             l_country_of_birth_fth := ' ';
           end if;
        end if;
        if l_country_of_birth_mth is null then
           if l_local_birth_country_mth is not null then
             l_country_of_birth_mth := l_local_birth_country_mth;
           else
             l_country_of_birth_mth := ' ';
           end if;
        end if;
        begin
          select country_of_birth,
                 business_group_id
          into   l_country_of_birth_emp,
                 l_business_group_id
	  from   per_all_people_f
	  where  person_id = p_person_id and
                 p_session_date between effective_start_date and effective_end_date;
        exception
          when no_data_found then
	        l_country_of_birth_emp := null;
                l_business_group_id := null;
        end;

        if l_country_of_birth_emp is null then
           l_country_of_birth_emp := ' ';
        end if;

	if (l_country_of_birth_emp = ' ' and
            l_country_of_birth_fth = ' ' and
            l_country_of_birth_mth = ' ') then

                l_return_target_group := 'N';

	 else

	        l_target_group := run_formula(l_country_of_birth_fth,
					      l_country_of_birth_mth,
					      l_country_of_birth_emp,
					      l_business_group_id,
                                              p_session_date
					      );

		if l_target_group = '1' then
                  l_return_target_group := 'Y';
		else
                  l_return_target_group := 'N';
		end if;

       	 end if;

         return l_return_target_group;

end;

END HR_NL_CALC_TARGET_GROUP;

/
