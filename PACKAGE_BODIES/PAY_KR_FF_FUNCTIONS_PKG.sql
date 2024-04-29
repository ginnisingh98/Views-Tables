--------------------------------------------------------
--  DDL for Package Body PAY_KR_FF_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_FF_FUNCTIONS_PKG" as
/* $Header: pykrfffc.pkb 120.16.12010000.28 2010/02/02 06:08:21 vaisriva ship $ */
--
-- Legislative Parameters Global Variables.
--
type legislative_parameter is record(
	parameter_name	varchar2(255),
	parameter_value	varchar2(255));
type legislative_parameter_tbl is table of legislative_parameter index by binary_integer;
g_payroll_action_id		pay_payroll_actions.payroll_action_id%TYPE;
g_legislative_parameter_tbl	legislative_parameter_tbl;
g_effective_date 		date ; -- Bug 4674552
--
-- NI Component Global Variables.
--
type ni is record(
	national_identifier	per_people_f.national_identifier%TYPE,
	sex			varchar2(1),
	date_of_birth		date);
g_ni	ni;
--------------------------------------------------------------------------------
function get_legislative_parameter(
	p_payroll_action_id	in number,
	p_parameter_name	in varchar2,
	p_default_value		in varchar2,
	p_flash_cache		in varchar2) return varchar2
--------------------------------------------------------------------------------
is
	l_legislative_parameters	pay_payroll_actions.legislative_parameters%TYPE;
	l_str				pay_payroll_actions.legislative_parameters%TYPE;
	l_pos				number;
	l_end_pos			number;
	l_parameter_name		varchar2(255);
	l_parameter_value		varchar2(255);
	l_found 			boolean := FALSE;
	l_index 			number;
	--
	cursor csr_legislative_parameters is
		select	legislative_parameters
		from	pay_payroll_actions
		where	payroll_action_id = p_payroll_action_id;
begin
	if p_flash_cache = 'Y'
	or g_payroll_action_id is null
	or g_payroll_action_id <> p_payroll_action_id then
		g_payroll_action_id := p_payroll_action_id;
		g_legislative_parameter_tbl.delete;
		--
		open csr_legislative_parameters;
		fetch csr_legislative_parameters into l_legislative_parameters;
		if csr_legislative_parameters%NOTFOUND then
			close csr_legislative_parameters;
			raise no_data_found;
		end if;
		close csr_legislative_parameters;
		--
		l_legislative_parameters := trim(l_legislative_parameters);
		while l_legislative_parameters is not null loop
			l_end_pos := instr(l_legislative_parameters, ' ');
			if l_end_pos > 0 then
				l_str := substr(l_legislative_parameters, 1, l_end_pos - 1);
				l_legislative_parameters := trim(substr(l_legislative_parameters, l_end_pos + 1));
			else
				l_str := l_legislative_parameters;
				l_legislative_parameters := null;
			end if;
			--
			l_pos := instr(l_str, '=');
			if l_pos > 1 and l_pos < length(l_str) then
				l_parameter_name  := substr(l_str, 1, l_pos - 1);
				l_parameter_value := substr(l_str, l_pos + 1);
				--
				-- If the same parameter exists, then override.
				--
				l_index := g_legislative_parameter_tbl.count;
				l_found := false;
				for i in 1..l_index loop
					if l_parameter_name = g_legislative_parameter_tbl(i).parameter_name then
						g_legislative_parameter_tbl(i).parameter_value := l_parameter_value;
						l_found := true;
						exit;
					end if;
				end loop;
				--
				-- If not exist, create new element.
				--
				if not l_found then
					g_legislative_parameter_tbl(l_index + 1).parameter_name  := l_parameter_name;
					g_legislative_parameter_tbl(l_index + 1).parameter_value := l_parameter_value;
				end if;
			end if;
		end loop;
	end if;
	--
	-- Derive legislative parameter from global value
	--
	l_found := false;
	for i in 1..g_legislative_parameter_tbl.count loop
		if g_legislative_parameter_tbl(i).parameter_name = p_parameter_name then
			l_parameter_value := g_legislative_parameter_tbl(i).parameter_value;
			l_found := true;
			exit;
		end if;
	end loop;
	--
	-- If not found, default_value is applied.
	--
	if not l_found then
		l_parameter_value := p_default_value;
	end if;
	--
	return l_parameter_value;
end get_legislative_parameter;
--------------------------------------------------------------------------------
function set_message_name(
	p_application_short_name	in varchar2,
	p_message_name			in varchar2) return number
--------------------------------------------------------------------------------
is
begin
	fnd_message.set_name(p_application_short_name, p_message_name);
	return 0;
exception
	when others then
		return -1;
end set_message_name;
--------------------------------------------------------------------------------
function set_message_token(
            p_token_name             in varchar2,
            p_token_value            in varchar2) return number
--------------------------------------------------------------------------------
is
begin
	fnd_message.set_token(p_token_name, p_token_value);
	return 0;
exception
	when others then
		return -1;
end set_message_token;
--------------------------------------------------------------------------------
function get_message return varchar2
--------------------------------------------------------------------------------
is
begin
	return substrb(fnd_message.get, 1, 240);
end get_message;
--------------------------------------------------------------------------------
procedure ni_component(
	p_national_identifier	in         varchar2,
	p_sex			out NOCOPY varchar2,
	p_date_of_birth		out NOCOPY date)
--------------------------------------------------------------------------------
is
	l_ni			varchar2(14);
	l_dob_cent		varchar2(2);
	l_dob_yymmdd		varchar2(6);
	l_sex_code		number;
	l_effective_date_cent	varchar2(2);
	l_effective_date	varchar2(8);
begin
	if p_national_identifier is null then
		fnd_message.set_name('PER', 'PER_KR_NI_NUMBER_NULL');
		fnd_message.raise_error;
	end if;
	--
	if g_ni.national_identifier = p_national_identifier then
		p_sex		:= g_ni.sex;
		p_date_of_birth	:= g_ni.date_of_birth;
	else
		begin
			l_ni := hr_ni_chk_pkg.chk_nat_id_format(p_national_identifier, 'DDDDDD-DDDDDDD');
			if l_ni = '0' then
				raise no_data_found;
			end if;
			--
			l_dob_yymmdd := substr(l_ni, 1, 6);
			l_sex_code := to_number(substr(l_ni, 8, 1));
			--
			if l_sex_code in (1, 2, 5, 6) then	-- Bug 9327240
				l_dob_cent := '19';
			elsif l_sex_code in (3, 4, 7, 8) then	-- Bug 9327240
				l_dob_cent := '20';
			elsif l_sex_code in (0, 9) then		-- Bug 9327240
				l_dob_cent := '18';
                        else
				--
				-- We "GUESS" date of birth in case of sex between 5 to 0 using effective date.
				-- In Korea, there's no exact rule to derive accurate date of birth
				-- from NI number whose sex is between 5 to 0.
				--
				-- Bug 4674552: execute query only if effective date is not cached
				if g_effective_date is null then
					select	effective_date
					into	g_effective_date
					from	fnd_sessions
					where	session_id = userenv('sessionid');
					--
				end if ;
				l_effective_date := to_char(g_effective_date, 'YYYYMMDD') ;
				-- End of 4674552
				-- If effective_date(YYMMDD) >= date_of_birth(YYMMDD), use same century as effective_date.
				-- else use previous century as effective_date.
				--
				l_effective_date_cent := substr(l_effective_date, 1, 2);
				if substr(l_effective_date, 3) >= l_dob_yymmdd then
					l_dob_cent := l_effective_date_cent;
				else
					l_dob_cent := to_char(to_number(l_effective_date_cent) - 1, 'FM09');
				end if;
			end if;
			--
			p_date_of_birth := to_date(l_dob_cent || l_dob_yymmdd, 'YYYYMMDD');
			--
			if mod(l_sex_code, 2) = 1 then
				p_sex := 'M';
			else
				p_sex := 'F';
			end if;
			--
			-- Set current NI information to global variable as cache.
			--
			g_ni.national_identifier	:= p_national_identifier;
			g_ni.sex			:= p_sex;
			g_ni.date_of_birth		:= p_date_of_birth;
		exception
			when others then
				fnd_message.set_name('PER', 'PER_KR_INV_NI_NUMBER');
				fnd_message.set_token('NI_NUMBER', p_national_identifier);
				fnd_message.raise_error;
		end;
	end if;
end ni_component;
/*
--------------------------------------------------------------------------------
procedure ni_component(
	p_national_identifier	in varchar2,
	p_person_name		in varchar2,
	p_sex			out varchar2,
	p_date_of_birth		out date)
--------------------------------------------------------------------------------
is
begin
	if p_national_identifier is null then
		fnd_message.set_name('PER', 'PER_KR_CON_PER_NI_NUMBER_NULL');
		fnd_message.set_token('PERSON_NAME', p_person_name);
		fnd_message.raise_error;
	end if;
	--
	begin
		ni_component(
			p_national_identifier	=> p_national_identifier,
			p_sex			=> p_sex,
			p_date_of_birth		=> p_date_of_birth);
	exception
		when others then
			fnd_message.set_name('PER', 'PER_KR_CON_PER_INV_NI_NUMBER');
			fnd_message.set_token('NI_NUMBER', p_national_identifier);
			fnd_message.set_token('PERSON_NAME', p_person_name);
			fnd_message.raise_error;
	end;
end ni_component;
*/
--------------------------------------------------------------------------------
function ni_sex(p_national_identifier in varchar2) return varchar2
--------------------------------------------------------------------------------
is
	l_sex		varchar2(1);
	l_date_of_birth	date;
begin
	ni_component(
		p_national_identifier	=> p_national_identifier,
		p_sex			=> l_sex,
		p_date_of_birth		=> l_date_of_birth);
	--
	return l_sex;
end ni_sex;
--------------------------------------------------------------------------------
function ni_date_of_birth(p_national_identifier in varchar2) return date
--------------------------------------------------------------------------------
is
	l_sex		varchar2(1);
	l_date_of_birth	date;
begin
	ni_component(
		p_national_identifier	=> p_national_identifier,
		p_sex			=> l_sex,
		p_date_of_birth		=> l_date_of_birth);
	--
	return l_date_of_birth;
end ni_date_of_birth;
--------------------------------------------------------------------------
-- Bug 3172960
function ni_nationality(p_national_identifier in varchar2) return varchar2
--------------------------------------------------------------------------
is
	l_nationality	varchar2(1);
begin
	if to_number(substr(p_national_identifier,8,1)) >= 5 and to_number(substr(p_national_identifier,8,1)) <= 8 then
		l_nationality := 'F';
	else
		l_nationality := 'K';
	end if;
	return l_nationality;
end ni_nationality;
---------------------------------------------------------------------
-- Bug 3172960
function ni_nationality(p_assignment_id 	in number,
			p_effective_date	in date) return varchar2
---------------------------------------------------------------------
is
	cursor csr_ni is
		select
			hr_ni_chk_pkg.chk_nat_id_format(per.national_identifier, 'DDDDDD-DDDDDDD') NI
		from	per_people_f		per,
			per_assignments_f	asg
		where	asg.assignment_id	=	p_assignment_id
		and	per.person_id		=	asg.person_id
		and	p_effective_date between per.effective_start_date and per.effective_end_date
		and	p_effective_date between asg.effective_start_date and asg.effective_end_date;

	l_ni		varchar2(20);
	l_nationality	varchar2(1);
begin
	open csr_ni;
	fetch csr_ni into l_ni;
	close csr_ni;

	l_nationality := pay_kr_ff_functions_pkg.ni_nationality(l_ni);
	return l_nationality;
end;
----------------------------------------------------------------------
-- Returns End Of Year Age
----------------------------------------------------------------------
function eoy_age(
	p_date_of_birth		in date,
	p_effective_date	in date) return number
is
begin
	return to_number(to_char(p_effective_date, 'YYYY')) - to_number(to_char(p_date_of_birth, 'YYYY'));
end eoy_age;
----------------------------------------------------------------------
-- Dependent Spouse Tax Exemption
----------------------------------------------------------------------
function dpnt_spouse_flag(p_contact_type in varchar2,
                          p_kr_cont_type in varchar2) -- Bug 7661820
return varchar2
is
begin
-- Bug 7661820: Added check for the Korean Conatct Type
           if (p_kr_cont_type = '3' or p_contact_type = 'S') then
		return 'Y';
	   else
	   	return 'N';
	   end if;
end dpnt_spouse_flag;
----------------------------------------------------------------------
-- Aged Dependent Tax Exemption
----------------------------------------------------------------------
function aged_dpnt_flag(
	p_contact_type		in varchar2,
	p_kr_cont_type	 	in varchar2, -- Bug 7661820
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2
is
	l_sex		varchar2(1);
	l_date_of_birth	date;
	l_eoy_age	number;
	l_flag		varchar2(1);
	l_var		varchar2(1); -- Bug 7661820
	l_male_age_limit 	number default 0; -- Bug 7676136
	l_female_age_limit 	number default 0; -- Bug 7676136
begin
	l_flag  := 'N';
	l_male_age_limit   := get_globalvalue('KR_YEA_MALE_AGE_LIM',p_effective_date);   -- Bug 7676136
	l_female_age_limit := get_globalvalue('KR_YEA_FEMALE_AGE_LIM',p_effective_date); -- Bug 7676136

	-- Bug 7661820: Added check for the Korean Conatct Type
        if (p_kr_cont_type = '3' or p_contact_type = 'S')  then
		l_var := 'Y';
	else
	   	l_var := 'N';
	end if;

	if l_var = 'N' then
		ni_component(
			p_national_identifier	=> p_national_identifier,
			p_sex			=> l_sex,
			p_date_of_birth		=> l_date_of_birth);
		l_eoy_age := eoy_age(l_date_of_birth, p_effective_date);
		--
		-- Bug 7676136
		if (l_sex = 'M' and l_eoy_age >= l_male_age_limit) or (l_sex = 'F' and l_eoy_age >= l_female_age_limit) then
			l_flag := 'Y';
		end if;
	end if;
	--
	return l_flag;
end aged_dpnt_flag;
----------------------------------------------------------------------
-- Adult Dependent Tax Exemption
----------------------------------------------------------------------
function adult_dpnt_flag(
	p_contact_type		in varchar2,
	p_kr_cont_type	 	in varchar2, -- Bug 7661820
	p_national_identifier	in varchar2,
	p_effective_date	in date,
	p_disabled_flag         in varchar2,
        p_age_exception_flag    in varchar2) return varchar2
is
	l_sex		varchar2(1);
	l_date_of_birth	date;
	l_eoy_age	number;
	l_flag		varchar2(1);
	l_var		varchar2(1); -- Bug 7661820
	l_male_age_limit 	number default 0; -- Bug 7676136
	l_female_age_limit 	number default 0; -- Bug 7676136
begin
	l_flag	:= 'N';
	l_male_age_limit   := get_globalvalue('KR_YEA_MALE_AGE_LIM',p_effective_date);   -- Bug 7676136
	l_female_age_limit := get_globalvalue('KR_YEA_FEMALE_AGE_LIM',p_effective_date); -- Bug 7676136

	-- Bug 7661820: Added check for the Korean Conatct Type
        if (p_kr_cont_type = '3' or p_contact_type = 'S') then
		l_var := 'Y';
	else
	   	l_var := 'N';
	end if;

	if l_var = 'N' then
		ni_component(
			p_national_identifier	=> p_national_identifier,
			p_sex			=> l_sex,
			p_date_of_birth		=> l_date_of_birth);
		l_eoy_age := eoy_age(l_date_of_birth, p_effective_date);
		--
		-- Bug 7676136
		if  ((l_sex = 'M' and l_eoy_age > 20 and l_eoy_age < l_male_age_limit)
		or  (l_sex = 'F' and l_eoy_age > 20 and l_eoy_age < l_female_age_limit))
		and (p_disabled_flag ='Y' or p_age_exception_flag='Y' ) then
		     -- Bug 3073424 added the above disabled and age exception check
			l_flag := 'Y';
		end if;
	end if;
	--
	return l_flag;
end adult_dpnt_flag;
----------------------------------------------------------------------
-- Underaged Dependent Tax Exemption
----------------------------------------------------------------------
function underaged_dpnt_flag(
	p_contact_type		in varchar2,
	p_kr_cont_type	 	in varchar2, -- Bug 7661820
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2
is
	l_sex		varchar2(1);
	l_date_of_birth	date;
	l_eoy_age	number;
	l_flag		varchar2(1);
	l_var		varchar2(1); -- Bug 7661820
begin
	l_flag	:= 'N';

	-- Bug 7661820: Added check for the Korean Conatct Type
	if (p_kr_cont_type = '3' or p_contact_type = 'S') then
		l_var := 'Y';
	else
	   	l_var := 'N';
	end if;

	if l_var = 'N' then
		ni_component(
			p_national_identifier	=> p_national_identifier,
			p_sex			=> l_sex,
			p_date_of_birth		=> l_date_of_birth);
		l_eoy_age := eoy_age(l_date_of_birth, p_effective_date);
		--
		if l_eoy_age <= 20 then
			l_flag := 'Y';
		end if;
	end if;
	--
	return l_flag;
end underaged_dpnt_flag;
----------------------------------------------------------------------
-- Aged Tax Exemption
----------------------------------------------------------------------
function aged_flag(
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2
is
	l_sex		varchar2(1);
	l_date_of_birth	date;
	l_eoy_age	number;
	l_flag		varchar2(1);
begin
	l_flag := 'N';
	ni_component(
		p_national_identifier	=> p_national_identifier,
		p_sex			=> l_sex,
		p_date_of_birth		=> l_date_of_birth);
	l_eoy_age := eoy_age(l_date_of_birth, p_effective_date);
	--
	if l_eoy_age >= 65 then
		l_flag := 'Y';
	end if;
	--
	return l_flag;
end aged_flag;
----------------------------------------------------------------------
-- Bug 3172960
-- Super Aged Tax Exemption
----------------------------------------------------------------------
function super_aged_flag(
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2
is
	l_sex		varchar2(1);
	l_date_of_birth	date;
	l_eoy_age	number;
	l_flag		varchar2(1);
begin
	l_flag := 'N';
	ni_component(
		p_national_identifier	=> p_national_identifier,
		p_sex			=> l_sex,
		p_date_of_birth		=> l_date_of_birth);
	l_eoy_age := eoy_age(l_date_of_birth, p_effective_date);
	--
	if l_eoy_age >= 70 then
		l_flag := 'Y';
	end if;
	--
	return l_flag;
end super_aged_flag;
----------------------------------------------------------------------
-- Disabled Tax Exemption
----------------------------------------------------------------------
function disabled_flag(
	p_person_id		in number,
	p_effective_date	in date) return varchar2
is
	l_flag	varchar2(1);

        -- Bug# 2657588
        -- Cursor modified to return 'N' if dis_information3 is 'N' for any one of the record.

	cursor csr_disabled(p_person_id number)
	is
        	select	nvl(dis_information3, 'Y')
        	from	per_disabilities_f
		where	person_id = p_person_id
	       	and	dis_information_category = 'KR'
		and	p_effective_date between effective_start_date and effective_end_date
		order by dis_information3 ;
begin
	l_flag	:= 'N';
	open csr_disabled(p_person_id);
	fetch csr_disabled into l_flag;
	if csr_disabled%NOTFOUND then
		l_flag := 'N';
	end if;
	close csr_disabled;
	--
	return l_flag;
end disabled_flag;
----------------------------------------------------------------------
-- Child Tax Exemption
----------------------------------------------------------------------
function child_flag(
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2
is
	l_sex		varchar2(1);
	l_date_of_birth	date;
	l_eoy_age	number;
	l_flag		varchar2(1);
begin
	l_flag := 'N';
	ni_component(
		p_national_identifier	=> p_national_identifier,
		p_sex			=> l_sex,
		p_date_of_birth		=> l_date_of_birth);
	l_eoy_age := eoy_age(l_date_of_birth, p_effective_date);
	--
	if l_eoy_age <= 6 then
		l_flag := 'Y';
	end if;
	--
	return l_flag;
end child_flag;
--------------------------------------------------------------------------------
-- National Pension Exception Reason (Formula Function)
-- Skip processing of National Pension Prem element, if National Pension
-- exception rules are entered against the employee
-- Bug 2815425
--------------------------------------------------------------------------------
function get_np_exception_flag (
        p_date_earned        IN DATE
        ,p_business_group_id IN NUMBER
        ,p_assignment_id     IN NUMBER ) RETURN VARCHAR2 IS
        --
	l_exception_flag per_people_extra_info.pei_information1%TYPE;
        --
	cursor csr_exception_flag is
	select pei.pei_information1
	  from per_people_f           pap
	       ,per_people_extra_info pei
	       ,per_assignments_f     paa
	 where paa.assignment_id = p_assignment_id
	   and paa.business_group_id = p_business_group_id
	   and paa.person_id = pap.person_id
	   and pap.person_id = pei.person_id
	   and pei.information_type = 'PER_KR_NP_EXCEPTIONS'
	   and p_date_earned between paa.effective_start_date and paa.effective_end_date
	   and p_date_earned between pap.effective_start_date and pap.effective_end_date
	   and p_date_earned between fnd_date.canonical_to_date(pei.pei_information2)
	                         and fnd_date.canonical_to_date(pei.pei_information3);
        --
begin
	l_exception_flag :='N';
	open csr_exception_flag;
	fetch csr_exception_flag into l_exception_flag;
	close csr_exception_flag;
        --
        if l_exception_flag = 'N' then
		return 'N';
	else
		return 'Y';
	end if;
        --
end get_np_exception_flag;
--------------------------------------------------------------------------------
/* Bug 6784288 */
function addtl_child_flag(
	p_contact_type		in varchar2,
	p_national_identifier	in varchar2,
	p_cont_information4 	in varchar2,	-- Bug 7615517
	p_cont_information11	in varchar2,	-- Bug 7615517
	p_cont_information15	in varchar2,	-- Bug 7661820
	p_effective_date	in date) return varchar2
is
  Cursor csr is
  SELECT lookup_code
  FROM hr_leg_lookups
  WHERE lookup_type = 'CONTACT'
    AND meaning LIKE '%Child%'
    AND lookup_code = p_contact_type;

  l_flag   varchar2(2);
  l_dummy  hr_leg_lookups.lookup_code%type;
  l_sex	varchar2(1);
  l_date_of_birth date;
  l_eoy_age number;
begin
  l_flag := 'N';
  -- Bug 7615517
  ni_component(
  		p_national_identifier	=> p_national_identifier,
  		p_sex			=> l_sex,
  		p_date_of_birth		=> l_date_of_birth);
		l_eoy_age := eoy_age(l_date_of_birth, p_effective_date);
  --
  		if l_eoy_age <= 20 then
  			l_flag := 'Y';
		end if;
  --

  open csr;
  fetch csr into l_dummy;
  close csr;

  -- Bug 7615517, Bug 7661820, Bug 9213683
  if p_cont_information11 is not null then
     	if (p_cont_information11 = '4'
     	and (l_flag = 'Y' or nvl(p_cont_information4,'N') = 'Y')
     	and (nvl(p_cont_information15,'N') = 'N')) then
     		return 'Y';
     	else
     		return 'N';
     	end if;
  else
  	if (l_dummy is not null
  	and (l_flag = 'Y' or nvl(p_cont_information4,'N') = 'Y')
  	and (nvl(p_cont_information15,'N') = 'N')) then
        	return 'Y';
  	else
        	return 'N';
  	end if;
  end if;
--
end addtl_child_flag;
--------------------------------------------------------------------------------
-- Bug 3172960
function get_dependent_info(
	p_assignment_id			in         number,
	p_date_earned			in         date,
	p_non_resident_flag		in         varchar2,
	p_dpnt_spouse_flag		out NOCOPY varchar2,
	p_num_of_aged_dpnts		out NOCOPY number,
	p_num_of_adult_dpnts		out NOCOPY number,
	p_num_of_underaged_dpnts	out NOCOPY number,
	p_num_of_dpnts			out NOCOPY number,
	p_num_of_ageds			out NOCOPY number,
	p_num_of_disableds		out NOCOPY number,
	p_female_ee_flag		out NOCOPY varchar2,
	p_num_of_children		out NOCOPY number) return number
--------------------------------------------------------------------------------
is
	l_return			number(10);
	l_num_of_super_ageds		number(10);
begin
	l_return := get_dependent_info(
			p_assignment_id,
			p_date_earned,
			p_non_resident_flag,
			p_dpnt_spouse_flag,
			p_num_of_aged_dpnts,
			p_num_of_adult_dpnts,
			p_num_of_underaged_dpnts,
			p_num_of_dpnts,
			p_num_of_ageds,
			p_num_of_disableds,
			p_female_ee_flag,
			p_num_of_children,
			l_num_of_super_ageds);

	return l_return;

end get_dependent_info;
--------------------------------------------------------------------------------
/* Bug 6784288 */
function get_dependent_info(
	p_assignment_id 		in         number,
	p_date_earned			in         date,
	p_non_resident_flag		in         varchar2,
	p_dpnt_spouse_flag		out NOCOPY varchar2,
	p_num_of_aged_dpnts		out NOCOPY number,
	p_num_of_adult_dpnts		out NOCOPY number,
	p_num_of_underaged_dpnts	out NOCOPY number,
	p_num_of_dpnts			out NOCOPY number,
	p_num_of_ageds			out NOCOPY number,
	p_num_of_disableds		out NOCOPY number,
	p_female_ee_flag		out NOCOPY varchar2,
	p_num_of_children		out NOCOPY number,
	p_num_of_super_ageds		out NOCOPY number) return number
--------------------------------------------------------------------------------
is
	l_return			number(10);
	l_num_of_addtl_child		number(10);      /* Bug 6784288 */
begin
	l_return := get_dependent_info(
			p_assignment_id,
			p_date_earned,
			p_non_resident_flag,
			p_dpnt_spouse_flag,
			p_num_of_aged_dpnts,
			p_num_of_adult_dpnts,
			p_num_of_underaged_dpnts,
			p_num_of_dpnts,
			p_num_of_ageds,
			p_num_of_disableds,
			p_female_ee_flag,
			p_num_of_children,
			p_num_of_super_ageds,
			l_num_of_addtl_child);        /* Bug 6784288 */

	return l_return;

end get_dependent_info;
--------------------------------------------------------------------------------
/* Bug 6705170 : Function get_dependent_info() has been overloaded
                 to fetch the New Born/Adopted Child count         */
--------------------------------------------------------------------------------
function get_dependent_info(
	p_assignment_id			in         number,
	p_date_earned			in         date,
	p_non_resident_flag		in         varchar2,
	p_dpnt_spouse_flag		out NOCOPY varchar2,
	p_num_of_aged_dpnts		out NOCOPY number,
	p_num_of_adult_dpnts		out NOCOPY number,
	p_num_of_underaged_dpnts	out NOCOPY number,
	p_num_of_dpnts			out NOCOPY number,
	p_num_of_ageds			out NOCOPY number,
	p_num_of_disableds		out NOCOPY number,
	p_female_ee_flag		out NOCOPY varchar2,
	p_num_of_children		out NOCOPY number,
	p_num_of_super_ageds		out NOCOPY number,
	p_num_of_new_born_adopted       out NOCOPY number,
	p_num_of_addtl_child            out NOCOPY number) return number         /* Bug 6784288 */
--------------------------------------------------------------------------------
is
        l_return			number(10);
	type l_flag_tbl is table of varchar2(1) index by binary_integer;
	l_new_born_adopted_flag_tbl		l_flag_tbl;
	--
	cursor csr_new_born is
		select
			nvl(cei.cei_information13, 'N')
		from	per_people_f		        per,
			per_contact_relationships	ctr,
			per_assignments_f		asg,
			per_contact_extra_info_f	cei
		where	asg.assignment_id = p_assignment_id
		and	p_date_earned
			between asg.effective_start_date and asg.effective_end_date
		and	ctr.person_id = asg.person_id
		and	ctr.cont_information_category = 'KR'
		and	ctr.cont_information1 = 'Y'
		and    ((ctr.cont_information9 ='D' and p_date_earned between nvl(date_start, p_date_earned) and nvl(trunc(add_months(date_end,12),'YYYY')-1,p_date_earned))
		         or (nvl(ctr.cont_information9,'XXX') <>'D' and p_date_earned between nvl(date_start, p_date_earned) and nvl(date_end, p_date_earned))
		        )
		and	per.person_id = ctr.contact_person_id
		and	cei.contact_relationship_id = ctr.contact_relationship_id
		and	cei.information_type = 'KR_DPNT_EXPENSE_INFO'
		and	to_char(cei.effective_start_date, 'YYYY') = to_char(p_date_earned,'YYYY')
		and	(
				(
					p_date_earned
					between per.effective_start_date and per.effective_end_date
				)
				or
				(
					per.start_date = per.effective_start_date
				and	not exists(
					    select  null
					    from    per_people_f per2
					    where   per2.person_id = per.person_id
					    and     p_date_earned
						    between per2.effective_start_date and per2.effective_end_date)
				)
			);
begin
	p_num_of_new_born_adopted := 0;
        g_effective_date := p_date_earned;
	--
	-- Dependents
	--
	if p_non_resident_flag = 'N' then
		open csr_new_born;
		fetch csr_new_born bulk collect into l_new_born_adopted_flag_tbl;
		close csr_new_born;
		--
		for i in 1..l_new_born_adopted_flag_tbl.count loop
			if l_new_born_adopted_flag_tbl(i) = 'Y' then
				p_num_of_new_born_adopted := p_num_of_new_born_adopted + 1;
			end if;
		end loop;
	end if;
	--
		l_return := get_dependent_info(
				p_assignment_id,
				p_date_earned,
				p_non_resident_flag,
				p_dpnt_spouse_flag,
				p_num_of_aged_dpnts,
				p_num_of_adult_dpnts,
				p_num_of_underaged_dpnts,
				p_num_of_dpnts,
				p_num_of_ageds,
				p_num_of_disableds,
				p_female_ee_flag,
				p_num_of_children,
			        p_num_of_super_ageds,
				p_num_of_addtl_child);        /* Bug 6784288 */
	return l_return;
end get_dependent_info;
--------------------------------------------------------------------------------
function get_dependent_info(
	p_assignment_id			in         number,
	p_date_earned			in         date,
	p_non_resident_flag		in         varchar2,
	p_dpnt_spouse_flag		out NOCOPY varchar2,
	p_num_of_aged_dpnts		out NOCOPY number,
	p_num_of_adult_dpnts		out NOCOPY number,
	p_num_of_underaged_dpnts	out NOCOPY number,
	p_num_of_dpnts			out NOCOPY number,
	p_num_of_ageds			out NOCOPY number,
	p_num_of_disableds		out NOCOPY number,
	p_female_ee_flag		out NOCOPY varchar2,
	p_num_of_children		out NOCOPY number,
	p_num_of_super_ageds		out NOCOPY number,
	p_num_of_addtl_child            out NOCOPY number) return number   /* Bug 6784288 */
--------------------------------------------------------------------------------
is
	type t_flag_tbl is table of varchar2(1) index by binary_integer;
	l_dpnt_spouse_flag_tbl		t_flag_tbl;
	l_aged_dpnt_flag_tbl		t_flag_tbl;
	l_adult_dpnt_flag_tbl		t_flag_tbl;
	l_underaged_dpnt_flag_tbl	t_flag_tbl;
	l_aged_flag_tbl			t_flag_tbl;
	l_super_aged_flag_tbl		t_flag_tbl;
	l_disabled_flag_tbl		t_flag_tbl;
	l_child_flag_tbl		t_flag_tbl;
	l_addtl_child_flag_tbl          t_flag_tbl;       /* Bug 6784288 */
	l_sex				varchar2(1);
	l_date_of_birth			date;
	--
	-- Bug 7661820: Added check for the Korean Conatct Type
	cursor csr_dpnt is
		select
			decode(ctr.cont_information2, 'Y', dpnt_spouse_flag(ctr.contact_type, ctr.cont_information11), 'N') DPNT_SPOUSE_FLAG,
			decode(ctr.cont_information2, 'Y', aged_dpnt_flag(ctr.contact_type,ctr.cont_information11, per.national_identifier, p_date_earned), 'N') AGED_DPNT_FLAG,
			decode(ctr.cont_information2, 'Y', adult_dpnt_flag(ctr.contact_type, ctr.cont_information11, per.national_identifier, p_date_earned,nvl(ctr.cont_information4, 'N'),nvl(ctr.cont_information8, 'N')), 'N') ADULT_DPNT_FLAG,
			decode(ctr.cont_information2, 'Y', underaged_dpnt_flag(ctr.contact_type, ctr.cont_information11, per.national_identifier, p_date_earned), 'N')	 UNDERAGED_DPNT_FLAG,
			decode(ctr.cont_information3, 'Y', aged_flag(per.national_identifier, p_date_earned), 'N') AGED_FLAG,
			-- Bug 3172960
			decode(ctr.cont_information3, 'Y', super_aged_flag(per.national_identifier, p_date_earned), 'N') SUPER_AGED_FLAG,
			nvl(ctr.cont_information4, 'N')	DISABLED_FLAG,
			decode(ctr.cont_information7, 'Y', child_flag(per.national_identifier, p_date_earned), 'N') CHILD_FLAG,
			-- Bug 6784288; Bug 6825145; Bug 7615517
			decode(ctr.cont_information2, 'Y', decode(addtl_child_flag(ctr.contact_type, per.national_identifier, ctr.cont_information4, ctr.cont_information11, ctr.cont_information15, p_date_earned),'Y','Y','N'), 'N') ADDTL_CHILD
		from	per_people_f		        per,
			per_contact_relationships	ctr,
			per_assignments_f		asg
		where	asg.assignment_id = p_assignment_id
		and	p_date_earned
			between asg.effective_start_date and asg.effective_end_date
		and	ctr.person_id = asg.person_id
		and	ctr.cont_information_category = 'KR'
		and	ctr.cont_information1 = 'Y'
		and    ((ctr.cont_information9 ='D' and p_date_earned between nvl(date_start, p_date_earned) and nvl(trunc(add_months(date_end,12),'YYYY')-1,p_date_earned))
		         or (nvl(ctr.cont_information9,'XXX') <>'D' and p_date_earned between nvl(date_start, p_date_earned) and nvl(date_end, p_date_earned))
		        )
		and	per.person_id = ctr.contact_person_id
		and	(
				(
					p_date_earned
					between per.effective_start_date and per.effective_end_date
				)
				or
				(
					per.start_date = per.effective_start_date
				and	not exists(
					    select  null
					    from    per_people_f per2
					    where   per2.person_id = per.person_id
					    and     p_date_earned
						    between per2.effective_start_date and per2.effective_end_date)
				)
			);
	cursor csr_ee is
		select
			per.national_identifier,
			per.marital_status,
			ni_sex(per.national_identifier)				NI_SEX,
			aged_flag(per.national_identifier, p_date_earned)	AGED_FLAG,
			disabled_flag(per.person_id, p_date_earned)		DISABLED_FLAG,
			child_flag(per.national_identifier, p_date_earned)	CHILD_FLAG,
			nvl(pei.pei_information3,'N')                           FEMALE_EMP_DOC,
			super_aged_flag(per.national_identifier, p_date_earned)	SUPER_AGED_FLAG		-- Bug 4124430
		from	per_people_f      per,
			per_assignments_f asg,
			per_people_extra_info pei
		where	asg.assignment_id = p_assignment_id
		and	p_date_earned
			between asg.effective_start_date and asg.effective_end_date
		and	per.person_id = asg.person_id
		and	p_date_earned
			between per.effective_start_date and per.effective_end_date
		and     per.person_id = pei.person_id(+)
		and     pei.information_type(+) = 'PER_KR_RELATED_YEA_INFORMATION';
	l_ee	csr_ee%ROWTYPE;
begin
	p_dpnt_spouse_flag		:= 'N';
	p_num_of_aged_dpnts		:= 0;
	p_num_of_adult_dpnts		:= 0;
	p_num_of_dpnts			:= 0;
	p_num_of_underaged_dpnts	:= 0;
	p_num_of_ageds			:= 0;
	p_num_of_super_ageds		:= 0;
	p_num_of_disableds		:= 0;
	p_female_ee_flag		:= 'N';
	p_num_of_children		:= 0;
	p_num_of_addtl_child            := 0;    /* Bug 6784288 */

        -- Bug 5080878
        g_effective_date := p_date_earned;
	--
	-- Dependents
	--
	if p_non_resident_flag = 'N' then
		open csr_dpnt;
		fetch csr_dpnt bulk collect into
			l_dpnt_spouse_flag_tbl,
			l_aged_dpnt_flag_tbl,
			l_adult_dpnt_flag_tbl,
			l_underaged_dpnt_flag_tbl,
			l_aged_flag_tbl,
			l_super_aged_flag_tbl,
			l_disabled_flag_tbl,
			l_child_flag_tbl,
			l_addtl_child_flag_tbl;        /* Bug 6784288 */
		close csr_dpnt;
		--
		for i in 1..l_dpnt_spouse_flag_tbl.count loop
			if l_dpnt_spouse_flag_tbl(i) = 'Y' then
				p_dpnt_spouse_flag := 'Y';
			end if;
			if l_aged_dpnt_flag_tbl(i) = 'Y' then
				p_num_of_aged_dpnts := p_num_of_aged_dpnts + 1;
			end if;
			if l_adult_dpnt_flag_tbl(i) = 'Y' then
				p_num_of_adult_dpnts := p_num_of_adult_dpnts + 1;
			end if;
			if l_underaged_dpnt_flag_tbl(i) = 'Y' then
				p_num_of_underaged_dpnts := p_num_of_underaged_dpnts + 1;
			end if;
			-- Bug 3172960
			if l_aged_flag_tbl(i) = 'Y' then
				if l_super_aged_flag_tbl(i) = 'Y' then
					p_num_of_super_ageds := p_num_of_super_ageds + 1;
				else
					p_num_of_ageds := p_num_of_ageds + 1;
				end if;
			end if;
                        -- Bug# 3637372
                        -- For 2003 and before the no of super ageds should be counted into no of ageds.
                        --
			if p_date_earned <= to_date('31/12/2003','dd/mm/yyyy') then
                                p_num_of_ageds := p_num_of_ageds + p_num_of_super_ageds;
                                p_num_of_super_ageds := 0;
                        end if;

			if l_disabled_flag_tbl(i) = 'Y' then
				p_num_of_disableds := p_num_of_disableds + 1;
			end if;
			if l_child_flag_tbl(i) = 'Y' then
				p_num_of_children := p_num_of_children + 1;
			end if;
                        -- Bug 6784288
			if l_addtl_child_flag_tbl(i) = 'Y' then
                                p_num_of_addtl_child := p_num_of_addtl_child + 1;
			end if;
                        -- End of Bug 6784288
		end loop;
		--
		p_num_of_dpnts := p_num_of_aged_dpnts + p_num_of_adult_dpnts + p_num_of_underaged_dpnts;
	end if;
	--
	-- Employee
	--
	open csr_ee;
	fetch csr_ee into l_ee;
	close csr_ee;
	--
	-- Bug 4124430: Super aged exemption is given for the employee also
	--
	if l_ee.aged_flag = 'Y' then
		if l_ee.super_aged_flag = 'Y' then
			p_num_of_super_ageds := p_num_of_super_ageds + 1 ;
		else
			p_num_of_ageds := p_num_of_ageds + 1;
		end if ;
	end if;
	-- End of bug 4124430
	if l_ee.disabled_flag = 'Y' then
		p_num_of_disableds := p_num_of_disableds + 1;
	end if;
	if l_ee.child_flag = 'Y' then
		p_num_of_children := p_num_of_children + 1;
	end if;
	--
	-- Female Employee Tax Exemption
	-- Modified for Bug 2729763
        --
	if l_ee.ni_sex = 'F' and (l_ee.marital_status = 'M' or p_dpnt_spouse_flag = 'Y' or (p_num_of_dpnts > 0 and l_ee.female_emp_doc = 'Y')) then
		p_female_ee_flag := 'Y';
	end if;
	--
	return 0;
end get_dependent_info;
--
-- Employment Insurance Exception codes
-- This function checks for the employee eligibility for EI Prem deduction
-- this is  used for formula function KR_EI_LOSS_EXCEPTION_CODES

function get_ei_loss_exception_codes(
       p_date_earned       	 in         date
      ,p_business_group_id 	 in         number
      ,p_assignment_id      	 in         number
      ,p_loss_ineligible_flag    out nocopy varchar2
      ,p_exception_flag    	 out nocopy varchar2
      ,p_exception_type   	 out nocopy varchar2
      ,p_overlapped_ex_flag      out nocopy varchar2
      ) return number is

 --

cursor csr_ei_loss_code
is
select pei_information8   loss_code
      ,pei_information9   loss_date
from per_people_extra_info  pei
    ,per_people_f           pp
    ,per_assignments_f      paa
    ,per_time_periods       ptp
where paa.assignment_id     = p_assignment_id
  and paa.business_group_id = p_business_group_id
  and pp.person_id          = paa.person_id
  and pei.person_id         = pp.person_id
  and pei.information_type  = 'PER_KR_EMPLOYMENT_INS_INFO'
  and ptp.payroll_id        = paa.payroll_id
  and p_date_earned between paa.effective_start_date and paa.effective_end_date
  and p_date_earned between pp.effective_start_date  and pp.effective_end_date
  and p_date_earned between ptp.start_date and ptp.end_date
  and ptp.end_date >= fnd_date.canonical_to_date(pei_information9);


cursor csr_ei_exception_code
is
select pei_information1       ei_exception_code
      ,pei_information4       ei_exception_type
from per_people_extra_info  pei
    ,per_assignments_f      paa
    ,per_time_periods       ptp
where paa.assignment_id      = p_assignment_id
  and paa.business_group_id  = p_business_group_id
  and pei.person_id          = paa.person_id
  and pei.information_type   ='PER_KR_EI_EXCEPTIONS'
  and p_date_earned between paa.effective_start_date and paa.effective_end_date
  and ptp.payroll_id         = paa.payroll_id
  and p_date_earned between ptp.start_date and ptp.end_date
  and fnd_date.canonical_to_date(pei.pei_information2) <= ptp.end_date
  and fnd_date.canonical_to_date(pei.pei_information3) >= ptp.start_date
order by pei.pei_information2 desc,pei.pei_information3 desc;

 l_ei_loss_code       per_people_extra_info.pei_information8%TYPE;
 l_ei_loss_date       per_people_extra_info.pei_information9%TYPE;
 l_ei_exception_type  per_people_extra_info.pei_information4%TYPE;
 l_ei_exception_code  per_people_extra_info.pei_information1%TYPE;
 l_ei_ex_dummy1       per_people_extra_info.pei_information8%TYPE;
 l_ei_ex_dummy2       per_people_extra_info.pei_information9%TYPE;


 begin

   open  csr_ei_loss_code;
   fetch csr_ei_loss_code into l_ei_loss_code,l_ei_loss_date;
   close csr_ei_loss_code;

   if l_ei_loss_code is not null then

       p_loss_ineligible_flag  := 'Y';
       p_exception_flag	       := 'N';
       p_exception_type        := null;
       p_overlapped_ex_flag    := null;

   else
       p_loss_ineligible_flag := 'N';
       p_overlapped_ex_flag   := 'N';

       open  csr_ei_exception_code;
       fetch csr_ei_exception_code into l_ei_exception_code,l_ei_exception_type;

       if csr_ei_exception_code%FOUND then

          p_exception_flag   := 'Y';
          p_exception_type   := l_ei_exception_type;

          -- check for overlapped exception codes
	  fetch csr_ei_exception_code into l_ei_ex_dummy1,l_ei_ex_dummy2;

	  if csr_ei_exception_code%ROWCOUNT >1 then
	     p_overlapped_ex_flag   := 'Y';
          end if;

       else

          p_exception_flag   := 'N';
          p_exception_type   := null;

       end if;

       close csr_ei_exception_code;

   end if;

  return 0;

 end get_ei_loss_exception_codes;

 -- Bug 4674552: Added function is_exempted_dependent
 --              Return: 'Y' if the dependent is eligible
 --                      for any basic or additional exemption,
 --                      'N' otherwise.
 --
 --
 function is_exempted_dependent(
	p_cont_type		  in	per_contact_relationships.contact_type%type,
	p_kr_cont_typ		  in	per_contact_relationships.cont_information11%type, -- Bug 7661820
 	p_ni			  in	per_people_f.national_identifier%type,
	p_itax_dpnt_flag	  in	per_contact_relationships.cont_information2%type,
	p_addl_tax_exem_flag	  in	per_contact_relationships.cont_information3%type,
	p_addl_disabled_flag	  in	per_contact_relationships.cont_information4%type,
	p_addl_exem_flag_child	  in	per_contact_relationships.cont_information7%type,
	p_age_ckh_exp_flag	  in	per_contact_relationships.cont_information8%type,
	p_eff_date		  in	pay_payroll_actions.effective_date%type,
        p_ins_prem_exem_incl_flag in    per_contact_relationships.cont_information10%type, -- Bug 4931542
        p_med_exp_exem_incl_flag  in    per_contact_relationships.cont_information12%type, -- Bug 4931542
        p_edu_exp_exem_incl_flag  in    per_contact_relationships.cont_information13%type, -- Bug 4931542
        p_card_exp_exem_incl_flag in    per_contact_relationships.cont_information14%type,  -- Bug 4931542
        p_contact_extra_info_id   in    per_contact_extra_info_f.contact_extra_info_id%type -- Bug 5879106
 ) return varchar2 is
 --
    cursor csr_contact_extra_info(p_cont_extra_info_id number) is
      select nvl(cei_information1,0) cei_information1,
             nvl(cei_information2,0) cei_information2,
             nvl(cei_information3,0) cei_information3,
             nvl(cei_information4,0) cei_information4,
             nvl(cei_information5,0) cei_information5,
             nvl(cei_information6,0) cei_information6,
             nvl(cei_information7,0) cei_information7,
             nvl(cei_information8,0) cei_information8,
             nvl(cei_information9,0) cei_information9,
             nvl(cei_information10,0) cei_information10,
             nvl(cei_information11,0) cei_information11
             --
       from  per_contact_extra_info_f
             --
      where  contact_Extra_info_id = p_cont_extra_info_id;
      --
      l_cei_record     csr_contact_extra_info%rowtype;
begin
	--
	g_effective_date := p_eff_date ;

        -- Look for basic dependent exemptions: spouse_dpnt, underaged_dpnt, aged_dpnt, and adult_dpnt
        --
	if nvl(p_itax_dpnt_flag, 'N') = 'Y' then
		--
		if dpnt_spouse_flag(p_contact_type => p_cont_type,
				    p_kr_cont_type => p_kr_cont_typ) = 'Y' then  -- Bug 7661820
			return 'Y' ;
		end if ;
		--
		if underaged_dpnt_flag(
			p_contact_type		=> p_cont_type,
			p_kr_cont_type		=> p_kr_cont_typ, -- Bug 7661820
			p_national_identifier	=> p_ni,
			p_effective_date	=> p_eff_date
		) = 'Y' then
			return 'Y' ;
		end if ;
		--
		if adult_dpnt_flag(
			p_contact_type		=> p_cont_type,
			p_kr_cont_type		=> p_kr_cont_typ, -- Bug 7661820
			p_national_identifier	=> p_ni,
			p_effective_date	=> p_eff_date,
			p_disabled_flag		=> nvl(p_addl_disabled_flag, 'N'),
			p_age_exception_flag	=> nvl(p_age_ckh_exp_flag, 'N')
		) = 'Y' then
			return 'Y' ;
		end if ;
		--
		if aged_dpnt_flag(
			p_contact_type		=> p_cont_type,
			p_kr_cont_type		=> p_kr_cont_typ, -- Bug 7661820
			p_national_identifier	=> p_ni,
			p_effective_date	=> p_eff_date
		) = 'Y' then
			return 'Y' ;
		end if ;
		--
	end if ; -- Finished looking for basic exemptions
	--
	-- Look for additional exemptions
	-- Look for additional exemption: aged/superaged
	--
	if nvl(p_addl_tax_exem_flag, 'N') = 'Y' and aged_flag(p_ni, p_eff_date) = 'Y' then
		-- Both Aged and Superaged would be caught here
		return 'Y' ;
	end if ;
	--
	-- Look for additional exemption: child
	--
	if nvl(p_addl_exem_flag_child, 'N') = 'Y' and child_flag(p_ni, p_eff_date) = 'Y' then
		return 'Y' ;
	end if ;
	--
	-- Look for additional exemption: disabled
	--
	if nvl(p_addl_disabled_flag, 'N') = 'Y' then
		return 'Y' ;
	end if ;
	--
	-- Bug 5879106. Check dependent expense amounts
	-- This check should always be last in this function to avoid running SQL when not required
	--
	if ((p_eff_date > to_date('31-12-2005','dd-mm-yyyy')) and (p_contact_extra_info_id is not null)) then
	  --
	  open csr_contact_extra_info(p_contact_extra_info_id);
	  fetch csr_contact_extra_info into l_cei_record;
	    --
	    if (l_cei_record.cei_information1 + l_cei_record.cei_information2
	        + l_cei_record.cei_information10 + l_cei_record.cei_information11) > 0
	    then
		return 'Y' ;
	    end if;
	    --
	    if (l_cei_record.cei_information3 + l_cei_record.cei_information4) > 0 then
		return 'Y' ;
	    end if;
	    --
	    if (l_cei_record.cei_information5 + l_cei_record.cei_information6) > 0 then
		return 'Y' ;
	    end if;
	    --
	    if (l_cei_record.cei_information7 + l_cei_record.cei_information8
	       + l_cei_record.cei_information9) > 0
	    then
		return 'Y' ;
	    end if;
	    --
	  close csr_contact_extra_info;

	elsif (p_eff_date <= to_date('31-12-2005','dd-mm-yyyy')) then
	   --
	   if     nvl(p_ins_prem_exem_incl_flag, 'N') = 'Y'
	       or nvl(p_med_exp_exem_incl_flag,  'N') = 'Y'
	       or nvl(p_edu_exp_exem_incl_flag,  'N') = 'Y'
	       or nvl(p_card_exp_exem_incl_flag, 'N') = 'Y'
	   then
		return 'Y' ;
	   end if ;
	   --
	end if;
	--
	return 'N' ;
	--
 end is_exempted_dependent ;

 -- Bug 4750653: Added function dpnt_eligible_for_basic_exem
 --              Return: 'Y' if the dependent is eligible
 --                      for basic exemption, 'N' otherwise.
 --
function dpnt_eligible_for_basic_exem(
	p_cont_type		in	per_contact_relationships.contact_type%type,
	p_kr_cont_typ		in	per_contact_relationships.cont_information11%type, -- Bug 7661820
	p_ni			in 	per_people_f.national_identifier%type,
	p_itax_dpnt_flag	in	per_contact_relationships.cont_information2%type,
	p_addl_disabled_flag	in	per_contact_relationships.cont_information4%type,
	p_age_ckh_exp_flag	in	per_contact_relationships.cont_information8%type,
	p_eff_date		in	pay_payroll_actions.effective_date%type
) return varchar2
is
begin
	-- Bug 5356651
	g_effective_date := p_eff_date ;
	--
	if nvl(p_itax_dpnt_flag, 'N') <> 'Y' then
		return 'N' ;
	end if ;
	--
	if dpnt_spouse_flag(p_contact_type => p_cont_type,
			    p_kr_cont_type => p_kr_cont_typ) = 'Y' then -- Bug 7661820
		return 'Y' ;
	end if ;
	--
	if underaged_dpnt_flag(
		p_contact_type		=> p_cont_type,
		p_kr_cont_type 		=> p_kr_cont_typ,	 -- Bug 7661820
		p_national_identifier	=> p_ni,
		p_effective_date	=> p_eff_date
	) = 'Y' then
		return 'Y' ;
	end if ;
	--
	if adult_dpnt_flag(
		p_contact_type		=> p_cont_type,
		p_kr_cont_type 		=> p_kr_cont_typ,	 -- Bug 7661820
		p_national_identifier	=> p_ni,
		p_effective_date	=> p_eff_date,
		p_disabled_flag		=> nvl(p_addl_disabled_flag, 'N'),
		p_age_exception_flag	=> nvl(p_age_ckh_exp_flag, 'N')
	) = 'Y' then
		return 'Y' ;
	end if ;
	--
	if aged_dpnt_flag(
		p_contact_type		=> p_cont_type,
		p_kr_cont_type 		=> p_kr_cont_typ,	 -- Bug 7661820
		p_national_identifier	=> p_ni,
		p_effective_date	=> p_eff_date
	) = 'Y' then
		return 'Y' ;
	end if ;
	--
	return 'N' ;
end dpnt_eligible_for_basic_exem ;
--
---------------------------------------------------------------------------
-- This function checks whether a dependent is eligible for
-- Additional Child Exemption
-- Bug: 4738717
function dpnt_addl_child_exempted(
        p_addl_child_exem     in varchar2,
        p_ni                  in varchar2,
        p_eff_date            in date
) return varchar2
is
    l_child_flag varchar2(5);
    l_ret        varchar2(5);
begin
    l_child_flag  := child_flag(p_ni, p_eff_date);
    if( p_addl_child_exem = 'Y' and l_child_flag = 'Y') then
       l_ret := 'Y';
    else
       l_ret := 'N';
    end if;

    return l_ret;

end dpnt_addl_child_exempted;
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- procedure get_double_exem_amt for Bug 6716401
procedure get_double_exem_amt(p_assignment_id in per_assignments_f.assignment_id%type,
                          p_effective_year in varchar2,
			  p_double_exm_amt out nocopy number)
is


cursor csr_get_ass_act_id(p_assignment_id per_assignments_f.assignment_id%type,
                          p_effective_year varchar2)
is
SELECT paa.assignment_action_id ass_act_id
from pay_payroll_actions ppa,
 pay_assignment_actions paa
where paa.assignment_id = p_assignment_id
and paa.action_status = 'C'
and ppa.payroll_action_id = paa.payroll_action_id
and     to_char(ppa.effective_date, 'YYYY') = p_effective_year
and ppa.report_type = 'YEA'
and ppa.report_qualifier = 'KR'
and ppa.action_type in ('B','X')
order by paa.action_sequence desc ;

l_assignment_action_id per_assignments_f.assignment_id%type;

Begin
     p_double_exm_amt := 0;
  Open csr_get_ass_act_id(p_assignment_id,p_effective_year);
  fetch csr_get_ass_act_id into  l_assignment_action_id;

  if csr_get_ass_act_id%FOUND then

  p_double_exm_amt := nvl(pay_kr_report_pkg.get_dbitem_value(l_assignment_action_id,'X_YEA_DOUBLE_EXEM_AMT'),0);
  else
   p_double_exm_amt := 0;
  end if;
 close csr_get_ass_act_id;

End get_double_exem_amt;
-----------------------------------------------------------------------------------
-- Bug 6849941: New Validation Checks for Credit Card Fields on the Income Tax Form
-----------------------------------------------------------------------------------
Function enable_credit_card(
	p_person_id                     in         number,
	p_contact_person_id             in         number,
	p_contact_relationship_id	in         number,
	p_date_earned			in         date) return varchar2
-----------------------------------------------------------------------------------
is
  --
  l_itax_law 		varchar2(2);
  l_cont_type 		varchar2(2);
  l_kr_cont_type 	varchar2(2);
  --
  cursor csr_dpnt is
  select
	ctr.cont_information2 itax_law,
	nvl(ctr.cont_information11, '0') kr_cont_type,
	decode(ctr.contact_type,   'P',   '1',   'S',   '3',   'A',   '4',   'C',   '4',   'R',   '4',   'O',   '4',   'T',   '4',  '6') cont_type
    from
	per_contact_relationships	ctr
   where
	 ctr.person_id = p_person_id
     and ctr.cont_information_category = 'KR'
     and ctr.cont_information1 = 'Y'
     and ((ctr.cont_information9 ='D' and p_date_earned between nvl(date_start, p_date_earned) and nvl(trunc(add_months(date_end,12),'YYYY')-1,p_date_earned))
		         or (nvl(ctr.cont_information9,'XXX') <>'D' and p_date_earned between nvl(date_start, p_date_earned) and nvl(date_end, p_date_earned))
		        )
     and     ctr.contact_person_id = p_contact_person_id
     and     ctr.contact_relationship_id = p_contact_relationship_id;

begin
--
       open csr_dpnt;
       fetch csr_dpnt into l_itax_law, l_kr_cont_type, l_cont_type;
       close csr_dpnt;
--
        -- Bug 8644512
       if ((l_cont_type in ('1','2','3','4') or l_kr_cont_type in ('1','2','3','4','7')) and ( l_itax_law = 'Y')) then
             return 'Y';
       else
             return 'N';
       end if;
end enable_credit_card;
-----------------------------------------------------------------------------------
--  Bug 7164589: Long Term Care Insurance Premium
--  Bug 7228788: Added a new input parameter to the function for the Input Value Name
-----------------------------------------------------------------------------------
FUNCTION get_long_term_ins_skip_flag(
		p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
	       ,p_input_value_name	in	varchar2
		) RETURN VARCHAR2
IS
--
      l_flag pay_run_result_values.result_value%type;
      -- Bug 7228788: Added a new argument for the Input Value Name to the cursor
      CURSOR csr(l_assignment_action_id pay_assignment_actions.assignment_action_id%type, l_input_value_name varchar2) is
      SELECT   	upper(nvl(prrv.result_value, 'N'))
	FROM    pay_input_values_f       piv
	       ,pay_run_result_values    prrv
	       ,pay_run_results          prr
	       ,pay_payroll_actions      ppa
	       ,pay_assignment_actions   paa
	       ,pay_element_types_f      pet
	WHERE   paa.assignment_action_id = l_assignment_action_id
	and     ppa.payroll_action_id 	= paa.payroll_action_id
	and     prr.assignment_action_id = paa.assignment_action_id
	and     prr.status 		in ('P', 'PA')
	and     prr.element_type_id 	= pet.element_type_id
	and     pet.element_name 	= 'LTCI_PREM'
        and     piv.legislation_code 	= 'KR'
        and     pet.legislation_code 	= 'KR'
	and     prrv.run_result_id 	= prr.run_result_id
	and     piv.input_value_id 	= prrv.input_value_id
	and	piv.name 		= l_input_value_name
	and     ppa.effective_date
		between piv.effective_start_date and piv.effective_end_date;
--
BEGIN
--
      l_flag := 'N';

      OPEN csr(p_assignment_action_id,p_input_value_name);
      FETCH csr into l_flag;

      IF csr%NOTFOUND THEN
	l_flag := 'N';
      END IF;

      CLOSE csr;

RETURN l_flag;
--
END;
--
----------------------------------------------------------------------------------------------------
-- Bug 7361372: FUNCTION chk_id_format() checks if the argument1 is in the same format as argument2.
--              If not then an error is raised. Else the same string as argument1 is returned.
----------------------------------------------------------------------------------------------------
FUNCTION chk_id_format(
	p_chk_string		IN VARCHAR2,
	p_format_string		IN VARCHAR2) RETURN VARCHAR2
IS
l_dummy varchar2(30);
--
BEGIN
--
	l_dummy := hr_ni_chk_pkg.chk_nat_id_format(p_chk_string,p_format_string);
--
	IF l_dummy = '0' THEN
		fnd_message.set_name('PAY', 'PAY_KR_YEA_INV_TAX_GRP_REGNO');
		fnd_message.set_token('REGNO',p_chk_string);
		fnd_message.raise_error;
	END IF;
--
RETURN l_dummy;
--
END;
--
-----------------------------------------------------------------------------------
-- Bug : 7142612
-----------------------------------------------------------------------------------
FUNCTION enable_donation_fields(
	p_person_id                     in         number,
	p_contact_person_id             in         number,
	p_contact_relationship_id	in         number,
	p_date_earned			in         date) return varchar2
-----------------------------------------------------------------------------------
IS
  --
  l_itax_law 		varchar2(2);
  l_cont_type 		varchar2(2);
  l_kr_cont_type 	varchar2(2);
  --
  cursor csr_dpnt is
  select
        ctr.cont_information2 itax_law,
	nvl(ctr.cont_information11, '0') kr_cont_type,
	decode(ctr.contact_type,   'P',   '1',   'S',   '3',   'A',   '4',   'C',   '4',   'R',   '4',   'O',   '4',   'T',   '4',  '6') cont_type
    from
	per_contact_relationships	ctr
   where
	 ctr.person_id = p_person_id
     and ctr.cont_information_category = 'KR'
     and ctr.cont_information1 = 'Y'
     and ((ctr.cont_information9 ='D' and p_date_earned between nvl(date_start, p_date_earned) and nvl(trunc(add_months(date_end,12),'YYYY')-1,p_date_earned))
		         or (nvl(ctr.cont_information9,'XXX') <>'D' and p_date_earned between nvl(date_start, p_date_earned) and nvl(date_end, p_date_earned))
		        )
     and     ctr.contact_person_id = p_contact_person_id
     and     ctr.contact_relationship_id = p_contact_relationship_id;

begin
--
       open csr_dpnt;
       fetch csr_dpnt into l_itax_law, l_kr_cont_type, l_cont_type;
       close csr_dpnt;
--
       -- Bug 8644512
       if ((l_cont_type in ('3','4') or l_kr_cont_type in ('3','4','7')) and ( l_itax_law = 'Y')) then
          return 'Y';
       else
          return 'N';
       end if;
--
END;
--
-----------------------------------------------------------------------------------
-- Bug 7526435 FUNCTION validate_bus_reg_num() checks the validation logic for provider reg.
--             no. of medical service provider and returns false if validation fails
-----------------------------------------------------------------------------------
FUNCTION validate_bus_reg_num(p_national_identifier IN VARCHAR2) RETURN VARCHAR2 IS
l_return_bool varchar2(30);
l_dummy varchar2(30);
sum1 integer;
dummy integer;
dummychk integer;
type getlist_var is varray(10) of integer;
getlist getlist_var := getlist_var();
chkvalue getlist_var := getlist_var(1,3,7,1,3,7,1,3,5);
BEGIN
                sum1 := 0;
                l_dummy := replace (p_national_identifier,'-','');
                for i in 1..10 loop
                        getlist.extend;
                        getlist(i) := substr(l_dummy,i,1);
                end loop;
                for i in 1..9 loop
                        sum1 := sum1 +  (getlist(i) * chkvalue(i));
                end loop;
                sum1 := sum1 + trunc((getlist(9) * 5)/10);
                dummy := sum1 - (trunc(sum1/10)* 10);
                dummychk := 0;
                if(dummy <> 0) then
                        dummychk := 10-dummy;
                end if;
                if(dummychk <> getlist(10)) then
                        l_return_bool := 'false';
                else
                l_return_bool := 'true';
                end if;
RETURN l_return_bool;
END;
--------------------------------------------------------------------------
-- Bug 7676136: Function to get the Global value
--------------------------------------------------------------------------
function get_globalvalue(p_glbvar in varchar2,p_process_date in date) return number
        is
          --
          cursor csr_ff_global
          is
          select to_number(glb.global_value,'99999999999999999999.99999')
          from   ff_globals_f glb
          where glb.global_name = p_glbvar
          and   p_process_date between glb.effective_start_date and glb.effective_end_date;
          --
          l_glbvalue number default 0;
        begin
          Open csr_ff_global;
          fetch csr_ff_global into l_glbvalue;
          close csr_ff_global;
          --
          if l_glbvalue is null then
             l_glbvalue := 0;
          end if;
          --
          return l_glbvalue;
        end;
--------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--  Bug 8341054: Gets the Flag for Input Value of an Element
-----------------------------------------------------------------------------------
FUNCTION get_element_input_value(
		p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
	       ,p_input_value_name	in	varchar2
	       ,p_element_name          in      varchar2
		) RETURN VARCHAR2
IS
--
      l_flag pay_run_result_values.result_value%type;
      -- Bug 7228788: Added a new argument for the Input Value Name to the cursor
      CURSOR csr(l_assignment_action_id pay_assignment_actions.assignment_action_id%type, l_input_value_name varchar2, l_element_name varchar2) is
      SELECT   	upper(nvl(prrv.result_value, 'N'))
	FROM    pay_input_values_f       piv
	       ,pay_run_result_values    prrv
	       ,pay_run_results          prr
	       ,pay_payroll_actions      ppa
	       ,pay_assignment_actions   paa
	       ,pay_element_types_f      pet
	WHERE   paa.assignment_action_id = l_assignment_action_id
	and     ppa.payroll_action_id 	= paa.payroll_action_id
	and     prr.assignment_action_id = paa.assignment_action_id
	and     prr.status 		in ('P', 'PA')
	and     prr.element_type_id 	= pet.element_type_id
	and     pet.element_name 	= l_element_name
        and     piv.legislation_code 	= 'KR'
        and     pet.legislation_code 	= 'KR'
	and     prrv.run_result_id 	= prr.run_result_id
	and     piv.input_value_id 	= prrv.input_value_id
	and	piv.name 		= l_input_value_name
	and     ppa.effective_date
		between piv.effective_start_date and piv.effective_end_date;
--
BEGIN
--
      l_flag := 'N';

      OPEN csr(p_assignment_action_id,p_input_value_name,p_element_name);
      FETCH csr into l_flag;

      IF csr%NOTFOUND THEN
	l_flag := 'N';
      END IF;

      CLOSE csr;

RETURN l_flag;
--
END;
--
-----------------------------------------------------------------------------------
--  Bug 8466662: Gets the Run Result Value for an Input Value of Type Money
-----------------------------------------------------------------------------------
FUNCTION get_element_rr_value(
		p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
	       ,p_input_value_name	in	varchar2
	       ,p_element_name          in      varchar2
		) RETURN number
IS
--
      l_dummy pay_run_result_values.result_value%type;
      CURSOR csr(l_assignment_action_id pay_assignment_actions.assignment_action_id%type, l_input_value_name varchar2, l_element_name varchar2) is
      SELECT   	nvl(prrv.result_value, 0)
	FROM    pay_input_values_f       piv
	       ,pay_run_result_values    prrv
	       ,pay_run_results          prr
	       ,pay_payroll_actions      ppa
	       ,pay_assignment_actions   paa
	       ,pay_element_types_f      pet
	WHERE   paa.assignment_action_id = l_assignment_action_id
	and     ppa.payroll_action_id 	= paa.payroll_action_id
	and     prr.assignment_action_id = paa.assignment_action_id
	and     prr.status 		in ('P', 'PA')
	and     prr.element_type_id 	= pet.element_type_id
	and     pet.element_name 	= l_element_name
        and     piv.legislation_code 	= 'KR'
        and     pet.legislation_code 	= 'KR'
	and     prrv.run_result_id 	= prr.run_result_id
	and     piv.input_value_id 	= prrv.input_value_id
	and	piv.name 		= l_input_value_name
	and     ppa.effective_date
		between piv.effective_start_date and piv.effective_end_date;
--
BEGIN
--
      l_dummy := 0;

      OPEN csr(p_assignment_action_id,p_input_value_name,p_element_name);
      FETCH csr into l_dummy;

      IF csr%NOTFOUND THEN
	l_dummy := 0;
      END IF;

      CLOSE csr;

RETURN l_dummy;
--
END;
--

--------------------------------------------------------------------------------------------------
--  Bug 8466662: Gets the Flag for Input Value of an Element and returns 'yes' if value not found
--------------------------------------------------------------------------------------------------
FUNCTION get_element_input_value_y(
		p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
	       ,p_input_value_name	in	varchar2
	       ,p_element_name          in      varchar2
		) RETURN VARCHAR2
IS
--
      l_flag pay_run_result_values.result_value%type;
      -- Bug 7228788: Added a new argument for the Input Value Name to the cursor
      CURSOR csr(l_assignment_action_id pay_assignment_actions.assignment_action_id%type, l_input_value_name varchar2, l_element_name varchar2) is
      SELECT   	upper(nvl(prrv.result_value, 'Y'))
	FROM    pay_input_values_f       piv
	       ,pay_run_result_values    prrv
	       ,pay_run_results          prr
	       ,pay_payroll_actions      ppa
	       ,pay_assignment_actions   paa
	       ,pay_element_types_f      pet
	WHERE   paa.assignment_action_id = l_assignment_action_id
	and     ppa.payroll_action_id 	= paa.payroll_action_id
	and     prr.assignment_action_id = paa.assignment_action_id
	and     prr.status 		in ('P', 'PA')
	and     prr.element_type_id 	= pet.element_type_id
	and     pet.element_name 	= l_element_name
        and     piv.legislation_code 	= 'KR'
        and     pet.legislation_code 	= 'KR'
	and     prrv.run_result_id 	= prr.run_result_id
	and     piv.input_value_id 	= prrv.input_value_id
	and	piv.name 		= l_input_value_name
	and     ppa.effective_date
		between piv.effective_start_date and piv.effective_end_date;
--
BEGIN
--
      l_flag := 'Y';

      OPEN csr(p_assignment_action_id,p_input_value_name,p_element_name);
      FETCH csr into l_flag;

      IF csr%NOTFOUND THEN
	l_flag := 'Y';
      END IF;

      CLOSE csr;

RETURN l_flag;
--
END;
--
-----------------------------------------------------------------------------------
--  Bug 8466662: Gets the Run Result Value for an Input Value of Date
-----------------------------------------------------------------------------------
FUNCTION get_element_rr_date_value(
		p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
	       ,p_input_value_name	in	varchar2
	       ,p_element_name          in      varchar2
		) RETURN date
IS
--
      l_dummy pay_run_result_values.result_value%type;
      CURSOR csr(l_assignment_action_id pay_assignment_actions.assignment_action_id%type, l_input_value_name varchar2, l_element_name varchar2) is
      SELECT   	nvl(fnd_date.canonical_to_date(prrv.result_value), to_date('01-01-1900','dd-mm-yyyy'))
	FROM    pay_input_values_f       piv
	       ,pay_run_result_values    prrv
	       ,pay_run_results          prr
	       ,pay_payroll_actions      ppa
	       ,pay_assignment_actions   paa
	       ,pay_element_types_f      pet
	WHERE   paa.assignment_action_id = l_assignment_action_id
	and     ppa.payroll_action_id 	= paa.payroll_action_id
	and     prr.assignment_action_id = paa.assignment_action_id
	and     prr.status 		in ('P', 'PA')
	and     prr.element_type_id 	= pet.element_type_id
	and     pet.element_name 	= l_element_name
        and     piv.legislation_code 	= 'KR'
        and     pet.legislation_code 	= 'KR'
	and     prrv.run_result_id 	= prr.run_result_id
	and     piv.input_value_id 	= prrv.input_value_id
	and	piv.name 		= l_input_value_name
	and     ppa.effective_date
		between piv.effective_start_date and piv.effective_end_date;
--
BEGIN
--
      l_dummy := to_date('01-01-1900','dd-mm-yyyy');

      OPEN csr(p_assignment_action_id,p_input_value_name,p_element_name);
      FETCH csr into l_dummy;

      IF csr%NOTFOUND THEN
	l_dummy := to_date('01-01-1900','dd-mm-yyyy');
      END IF;

      CLOSE csr;

RETURN l_dummy;
--
END;
--
---------------------------------------------------------------------------------------------
--  Bug 8466662: This function will be called from the TAX formula to fetch the individual
--               Calculated Taxes. Based on the value for the input p_class it will return
--       	 the calculated tax values
-- 		 (p_class = 1 => individual calculated tax for each working place irrespective
-- 		 of their eligiblity for the Post tax deduction.
--		 p_class = 2 => individual calculated tax values for all the eligible working
--		 places.
---------------------------------------------------------------------------------------------
function SepPayPostTax( p_assignment_id 	  in   number,
                        p_business_group_id       in   number,
                        p_date_earned	 	  in   date,
			p_assignment_action_id    in   number,
                        p_total_taxable_earnings  in   number,
                        p_nst_taxable_earnings    in   number,
                        p_wkpd_int_sep_pay        in   number,
                        p_sep_pay_income_exem_rate in  number,
                        p_class                   in   number,
                        p_sep_cal_mode            in  varchar2,
                        p_sep_lump_sum_amount	  in   number,
                        p_emp_eligibility_flag    in   varchar2,
                        p_st_emp_hire_date	  in   date,
                        p_st_emp_leaving_date	  in   date,
                        p_nst_emp_hire_date	  in   date,
                        p_nst_emp_leaving_date	  in   date,
			p_sep_max_post_tax_deduc  in   number,
                        p_amount_expected         in   number,
			p_personal_contribution   in   number,
			p_pension_exemption       in   number,
			p_principal_interest      in   number,
			p_nst_amount_expected     in   number,
			p_prev_sep_lump_sum_amt   in   number,
                        p_nst_sep_calc_tax        out NOCOPY number,
                        p_sep_calc_tax            out NOCOPY number,
			p_st_max_lim		  out NOCOPY number,
			p_nst_max_lim		  out NOCOPY number
		) return number
is

/* Cursor to fetch the sum of the Statutory Sep pay Earnings */
cursor get_prev_stat_sp_earn(l_effective_date in date, l_assignment_id in number, l_element_entry_id in number) is
SELECT peevf.element_entry_id	 	 element_entry_id,
       sum(peevf.screen_entry_value)	 prev_earnings
FROM pay_element_entry_values_f peevf,
     pay_element_entries_f peef,
     pay_element_types_f petf,
     pay_input_values_f pivf
WHERE peevf.element_entry_id = peef.element_entry_id
and peevf.element_entry_id = nvl(l_element_entry_id,peevf.element_entry_id)
and peef.element_type_id = petf.element_type_id
and petf.element_name LIKE 'PREV_ER_INFO'
and petf.legislation_code = 'KR'
and peef.assignment_id = l_assignment_id
and peevf.input_value_id = pivf.input_value_id
and pivf.element_type_id = petf.element_type_id
and pivf.name IN ('SEP_INS',    'SEP_PAY',    'SP_SEP_ALW')
and l_effective_date BETWEEN peevf.effective_start_date AND peevf.effective_end_date
and l_effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
and l_effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
and l_effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
group by peevf.element_entry_id;

/* Cursor to fetch the sum of the Non-Statutory Sep pay Earnings */
cursor get_prev_non_stat_sp_earn(l_effective_date in date, l_assignment_id in number, l_element_entry_id in number) is
SELECT peevf.screen_entry_value 	prev_earnings
FROM pay_element_entry_values_f peevf,
     pay_element_entries_f peef,
     pay_element_types_f petf,
     pay_input_values_f pivf
WHERE peevf.element_entry_id = peef.element_entry_id
and peevf.element_entry_id = nvl(l_element_entry_id,peevf.element_entry_id)
and peef.element_type_id = petf.element_type_id
and petf.element_name LIKE 'PREV_ER_INFO'
and petf.legislation_code = 'KR'
and peef.assignment_id = l_assignment_id
and peevf.input_value_id = pivf.input_value_id
and pivf.element_type_id = petf.element_type_id
and pivf.name = 'SP_SEP_ALW'
and l_effective_date BETWEEN peevf.effective_start_date AND peevf.effective_end_date
and l_effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
and l_effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
and l_effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date;

/* Cursor to find the eligible working place entries for the Sep Pay Post Tax Deduction */
cursor get_eligible_earnings(l_effective_date in date, l_assignment_id in number) is
SELECT peevf.element_entry_id 		element_entry_id
FROM pay_element_entry_values_f peevf,
     pay_element_entries_f peef,
     pay_element_types_f petf,
     pay_input_values_f pivf
WHERE peevf.element_entry_id = peef.element_entry_id
and peef.element_type_id = petf.element_type_id
and petf.element_name LIKE 'PREV_ER_INFO'
and petf.legislation_code = 'KR'
and peef.assignment_id = l_assignment_id
and peevf.input_value_id = pivf.input_value_id
and pivf.element_type_id = petf.element_type_id
and pivf.name IN ('ELIGIBLE_POST_TAX_DEDUC_FLAG')
and nvl(peevf.screen_entry_value,'N') = 'Y'
and l_effective_date BETWEEN peevf.effective_start_date AND peevf.effective_end_date
and l_effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
and l_effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
and l_effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date;

/* Cursor to fetch the Hiring, Leaving and Final Interim Separation Pay date for the previous
   employer to calculate the Service Period and Overlap Periods */
cursor get_prev_hire_leave_dt(l_effective_date in date, l_assignment_id in number, l_element_entry_id in number) is
SELECT fnd_date.canonical_to_date(peevf.screen_entry_value) dt_value
FROM pay_element_entry_values_f peevf,
     pay_element_entries_f peef,
     pay_element_types_f petf,
     pay_input_values_f pivf
WHERE peevf.element_entry_id = peef.element_entry_id
and peevf.element_entry_id = nvl(l_element_entry_id,peevf.element_entry_id)
and peef.element_type_id = petf.element_type_id
and petf.element_name LIKE 'PREV_ER_INFO'
and petf.legislation_code = 'KR'
and peef.assignment_id = l_assignment_id
and peevf.input_value_id = pivf.input_value_id
and pivf.element_type_id = petf.element_type_id
and pivf.name IN ('H_DATE','L_DATE','FINAL_INT_DATE')
and l_effective_date BETWEEN peevf.effective_start_date AND peevf.effective_end_date
and l_effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
and l_effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
and l_effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
order by pivf.name;

/* Start of Bug 8525925 */
/* Cursor to get the business Registration number of Separation Pension */
cursor get_prev_bus_reg_num_sep (l_effective_date in date, l_assignment_id in number, l_element_entry_id in number) is
SELECT peevf.element_entry_id	 	 element_entry_id
 FROM pay_element_entry_values_f peevf,
     pay_element_entries_f peef,
     pay_element_types_f petf,
     pay_input_values_f pivf
WHERE peevf.element_entry_id = peef.element_entry_id
and peef.element_type_id = petf.element_type_id
and petf.element_name LIKE 'PREV_SEP_PENS_DTLS'
and petf.legislation_code = 'KR'
and peef.assignment_id = l_assignment_id
and peevf.input_value_id = pivf.input_value_id
and pivf.element_type_id = petf.element_type_id
and pivf.name IN ('BP_NUMBER')
and l_effective_date BETWEEN peevf.effective_start_date AND peevf.effective_end_date
and l_effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
and l_effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
and l_effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
and peevf.screen_entry_value in (SELECT   peevf.screen_entry_value 	 bus_reg_num
FROM pay_element_entry_values_f peevf,
     pay_element_entries_f peef,
     pay_element_types_f petf,
     pay_input_values_f pivf
WHERE peevf.element_entry_id = peef.element_entry_id
and peevf.element_entry_id = nvl(l_element_entry_id,peevf.element_entry_id)
and peef.element_type_id = petf.element_type_id
and petf.element_name LIKE 'PREV_ER_INFO'
and petf.legislation_code = 'KR'
and peef.assignment_id = l_assignment_id
and peevf.input_value_id = pivf.input_value_id
and pivf.element_type_id = petf.element_type_id
and pivf.name IN ('BP_NUMBER')
and l_effective_date BETWEEN peevf.effective_start_date AND peevf.effective_end_date
and l_effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
and l_effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
and l_effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
group by peevf.screen_entry_value)

group by peevf.element_entry_id;

/* Cursor to get the Total Amount Received */
cursor get_prev_emp_amt (l_effective_date in date, l_assignment_id in number, l_element_entry_id in number) is
SELECT       nvl(peevf.screen_entry_value,0)	 entry_value
FROM pay_element_entry_values_f peevf,
     pay_element_entries_f peef,
     pay_element_types_f petf,
     pay_input_values_f pivf
WHERE peevf.element_entry_id = peef.element_entry_id
and peevf.element_entry_id = nvl(l_element_entry_id,peevf.element_entry_id)
and peef.element_type_id = petf.element_type_id
and petf.element_name LIKE 'PREV_SEP_PENS_DTLS'
and petf.legislation_code = 'KR'
and peef.assignment_id = l_assignment_id
and peevf.input_value_id = pivf.input_value_id
and pivf.element_type_id = petf.element_type_id
and pivf.name IN ('PRINCIPAL_INTRST','PERS_CONTRIBUTION','PENS_EXEM','AMT_EXP_STAT_SEP','AMT_EXP_NONSTAT_SEP','TOTAL_RECEIVED')
and l_effective_date BETWEEN peevf.effective_start_date AND peevf.effective_end_date
and l_effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
and l_effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
and l_effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
order by pivf.name;

/* Bug 8601387: 2009 Non Statutory Separation Pay Tax Receipt Layout Updates */
cursor csr_prev_lsa(l_element_entry_id in number,l_assignment_action_id in number) is
select nvl(result_value,0) result_value
from pay_element_types_f petf,
     pay_run_results prr,
     pay_run_result_values prrv,
     pay_element_entries_f peef
where petf.element_name = 'PREV_EMP_SEP_LUMP_SUM_AMOUNT'
and petf.element_type_id = prr.element_type_id
and prr.assignment_action_id = l_assignment_action_id
and prrv.run_result_id = prr.run_result_id
and prr.source_id = l_element_entry_id
and petf.legislation_code = 'KR';

/* End of Bug 8525925 */
-- Local Variables --
l_taxable_earnings		number;
l_sep_taxable_earnings		number;
l_receivable_sep_pay		number;
l_element_entry_id		number;
l_dummy				number;
l_total_eligible_earnings 	number;
l_nst_prev_earnings 		number;
l_total_nst_eligible_earnings 	number;
l_sep_calc_tax			number;
l_nst_sep_calc_tax		number;
l_nst_taxable_earnings    	number;
l_emp_hire_date			date;
l_emp_leaving_date		date;
l_nst_emp_hire_date		date;
l_nst_emp_leaving_date		date;
l_prev_hire_date                date;
l_prev_int_date              	date;
l_prev_leaving_date             date;
l_st_overlap_period		number;
l_st_overlap_date1		date;
l_st_overlap_date2		date;
l_nst_overlap_period		number;
l_nst_overlap_date1		date;
l_nst_overlap_date2		date;
l_curr_max_lim			number;
l_prev_max_lim			number;
l_st_curr_max_lim		number;
l_nst_curr_max_lim		number;
l_st_prev_max_lim		number;
l_nst_prev_max_lim		number;
l_count 			number;
/* Bug 8525925 */
l_sep_tax_conversion_reqd       varchar2(1);
prev_principal_interest		number;
prev_pension_exemption		number;
prev_personal_contibution	number;
prev_total_received             number;
prev_amt_exp_stat_sep		number;
prev_total_lump_sum_amount      number;
l_nst_receivable_sep_pay        number;
l_nst_sep_taxable_earnings      number;
prev_amt_nonstat_sep            number;
l_total_lump_sum_amount         number;
prev_sep_lump_sum_amt           number;

begin
--
hr_utility.trace('Entering Function SepPayPostTax.......');
hr_utility.trace('p_assignment_id = '||p_assignment_id);
--
p_nst_sep_calc_tax 	:= 0;
p_sep_calc_tax 		:= 0;
p_st_max_lim		:= 0;
p_nst_max_lim		:= 0;

-- First check if the function call is for Statutory Sep Pay or
-- for Non-Statutory Sep Pay
hr_utility.trace('Sep Pay Mode = '||p_sep_cal_mode);
--
if p_sep_cal_mode = 'NORMAL_SEP_PAY' then

   -- New variable used to find the type of the total tax to be returned
   -- p_class = 1 means that the function call will return the total of the
   -- individual working place calculated tax amount
   -- p_class = 2 means that the function call will return the total of the
   -- calculated tax for the eligible working places

   if p_class = 1 then /* if we have to return the total tax for the individual working places */

      l_taxable_earnings		:= 0;
      l_sep_taxable_earnings		:= 0;
      l_receivable_sep_pay		:= 0;
      p_sep_calc_tax			:= 0;
      l_dummy				:= 0;
      l_emp_hire_date			:= null;
      l_emp_leaving_date		:= null;
      l_prev_hire_date                	:= null;
      l_prev_int_date                	:= null;
      l_prev_leaving_date             	:= null;
      -- Bug 8525925
      l_sep_tax_conversion_reqd         := null;
      l_total_lump_sum_amount           := 0 ;

      -- For Current Employer
      l_taxable_earnings     := p_total_taxable_earnings;
      l_sep_taxable_earnings := p_total_taxable_earnings;

      -- Bug 8525925
      -- If Tax Conversion is required then calculate the receivable_sep_pay and
      -- modify the taxable earnings
      if p_amount_expected > 0 then
         l_sep_tax_conversion_reqd := 'Y';
      -- Bug 8996756
	if p_principal_interest > 0 then
         l_total_lump_sum_amount := p_amount_expected *
                        ( 1 - (p_personal_contribution - p_pension_exemption) / p_principal_interest );
        else
	 l_total_lump_sum_amount := p_amount_expected;
	end if;
      --  End of 8996756
	 l_total_lump_sum_amount := greatest(0,trunc(l_total_lump_sum_amount)) ;
         l_receivable_sep_pay := l_taxable_earnings - p_sep_lump_sum_amount + l_total_lump_sum_amount;
         l_taxable_earnings   := greatest(trunc(l_receivable_sep_pay),0);
      end if;

      l_emp_hire_date := p_st_emp_hire_date;
      l_emp_leaving_date := p_st_emp_leaving_date;

      -- Call the function to calculate the Statutory Separation Pay Tax
      -- for the current employer
      p_sep_calc_tax := SepPayTaxCalc(
                       ceil(months_between(l_emp_leaving_date,l_emp_hire_date)/12),
		       0,
                       l_taxable_earnings,
                       l_sep_taxable_earnings,
                       l_receivable_sep_pay,
                       l_sep_tax_conversion_reqd,
                       p_business_group_id,
                       p_date_earned,
                       p_sep_pay_income_exem_rate);

      -- For Previous Employers
      l_element_entry_id 	:= null;
      l_taxable_earnings 	:= 0;
      l_sep_taxable_earnings 	:= 0;
      l_receivable_sep_pay 	:= 0;
      l_dummy			:= 0;


      for i in get_prev_stat_sp_earn(p_date_earned, p_assignment_id, l_element_entry_id) loop
       /* Bug 8525925 */
      l_sep_tax_conversion_reqd := null;
      prev_principal_interest   := 0;
      prev_pension_exemption    := 0;
      prev_personal_contibution := 0;
      prev_amt_exp_stat_sep     := 0;
       prev_total_received       := 0;
      prev_total_lump_sum_amount := 0;
      l_count 		:= 0;
      prev_sep_lump_sum_amt := 0;

            l_taxable_earnings     := i.prev_earnings ;
	    l_taxable_earnings	   := nvl(l_taxable_earnings,0);
      	    l_sep_taxable_earnings := l_taxable_earnings;

	  for j in  get_prev_bus_reg_num_sep(p_date_earned, p_assignment_id,i.element_entry_id) loop

            /* Bug 8601387*/

            open csr_prev_lsa(j.element_entry_id,p_assignment_action_id);
		fetch csr_prev_lsa into prev_sep_lump_sum_amt;
		close csr_prev_lsa;
		l_taxable_earnings     :=  l_taxable_earnings + nvl(prev_sep_lump_sum_amt,0);

	    for k in get_prev_emp_amt (p_date_earned, p_assignment_id,j.element_entry_id) loop

		if l_count = 0 then
		prev_amt_nonstat_sep := k.entry_value;
		l_count := l_count + 1;
	      elsif l_count = 1 then
      	        prev_amt_exp_stat_sep := k.entry_value;
		l_count := l_count + 1;
      	      elsif l_count = 2 then
      	         prev_pension_exemption := k.entry_value;
 		 l_count := l_count + 1;
              elsif l_count = 3 then
	         prev_personal_contibution := k.entry_value;
                  l_count := l_count + 1;
	       elsif l_count = 4 then
	         prev_principal_interest := k.entry_value;
		 l_count := l_count + 1;
 	       elsif l_count = 5 then
	         prev_total_received := k.entry_value;
      	      end if;

	    end loop;

         end loop;

	  -- If Tax Conversion is required then calculate the receivable_sep_pay and
          -- modify the taxable earnings
     if (nvl(prev_amt_exp_stat_sep,0) > 0 and nvl(prev_total_received,0) > 0) then

		l_sep_tax_conversion_reqd := 'Y';
	      if prev_principal_interest > 0 then
	        prev_total_lump_sum_amount := nvl(prev_amt_exp_stat_sep,0) *
                        ( 1 - (nvl(prev_personal_contibution,0) - nvl(prev_pension_exemption,0)) / prev_principal_interest);
	      else
		prev_total_lump_sum_amount := nvl(prev_amt_exp_stat_sep,0);
	      end if;
                prev_total_lump_sum_amount := greatest(0,trunc(prev_total_lump_sum_amount));
		l_receivable_sep_pay := l_taxable_earnings + prev_total_lump_sum_amount - p_prev_sep_lump_sum_amt;
         	l_taxable_earnings   := greatest(l_receivable_sep_pay,0);

	     elsif nvl(prev_amt_exp_stat_sep,0) > 0 then

	         l_sep_tax_conversion_reqd := 'Y';
                 prev_total_lump_sum_amount := greatest(0,trunc(prev_amt_exp_stat_sep));
		 l_receivable_sep_pay := l_taxable_earnings + prev_total_lump_sum_amount - p_prev_sep_lump_sum_amt;
         	 l_taxable_earnings   := greatest(l_receivable_sep_pay,0);

      	    end if;

	  /* End of Bug 8525925 */
      	  l_prev_hire_date 	:= null;
      	  l_prev_int_date  	:= null;
      	  l_prev_leaving_date 	:= null;
      	  l_st_overlap_date1 	:= null;
      	  l_st_overlap_date2 	:= null;
      	  l_st_overlap_period 	:= 0;
	  l_count 		:= 0;

	  -- Loop to fetch the date for the previous employer to calculate the Service Period and Overlap Periods
      	  for prev in get_prev_hire_leave_dt(p_date_earned, p_assignment_id, i.element_entry_id) loop
	      if l_count = 0 then
		l_prev_int_date := prev.dt_value;
		l_count := l_count + 1;
	      elsif l_count = 1 then
      	        l_prev_hire_date:= prev.dt_value;
		l_count := l_count + 1;
      	      elsif l_count = 2 then
      	         l_prev_leaving_date := prev.dt_value;
 		 l_count := l_count + 1;
      	      end if;

      	  end loop;

      	      if l_prev_int_date is null then
      	         l_prev_int_date := l_prev_hire_date;
	      end if;

      	      if (l_prev_hire_date is null) or (l_prev_leaving_date is null) then
		 fnd_message.set_name('PAY','PAY_KR_PREV_SEP_DATE_REQ');
		 fnd_message.raise_error;
	      end if;

          if l_emp_hire_date > l_prev_int_date then
             l_st_overlap_date1 := l_emp_hire_date;
          else
             l_st_overlap_date1 := l_prev_int_date;
          end if;

          if l_emp_leaving_date > l_prev_leaving_date then
             l_st_overlap_date2 := l_prev_leaving_date;
          else
             l_st_overlap_date2 := l_emp_leaving_date;
          end if;

          if ceil(months_between(l_st_overlap_date2,l_st_overlap_date1)/12) <= 0 then
             l_st_overlap_period := 0;
          else
             l_st_overlap_period := ceil(months_between(l_st_overlap_date2,l_st_overlap_date1)/12);
          end if;

          -- Call the function to calculate the Statutory Separation Pay Tax
          -- for the previous employer
      	  l_dummy := SepPayTaxCalc(
                       			ceil(months_between(l_prev_leaving_date,l_prev_int_date)/12),
					l_st_overlap_period,
                       			l_taxable_earnings,
                       			l_sep_taxable_earnings,
                       			l_receivable_sep_pay,
                       			l_sep_tax_conversion_reqd,
                       			p_business_group_id,
                       			p_date_earned,
                       			p_sep_pay_income_exem_rate);

          p_sep_calc_tax := p_sep_calc_tax + l_dummy;

      end loop;
      --
      return 0;

   elsif p_class = 2 then /* if we have to return the total tax for the eligible working places */
      --
      hr_utility.trace('Inside the loop to return the Calculated tax for the Eligible Working places ....class 2');
      --
      l_taxable_earnings		:= 0;
      l_sep_taxable_earnings		:= 0;
      l_receivable_sep_pay		:= 0;
      p_sep_calc_tax			:= 0;
      l_element_entry_id		:= 0;
      l_total_eligible_earnings		:= 0;
      l_dummy				:= 0;
      l_emp_hire_date                 	:= null;
      l_emp_leaving_date                := null;
      l_prev_hire_date                	:= null;
      l_prev_int_date                	:= null;
      l_prev_leaving_date             	:= null;
      l_st_curr_max_lim			:= 0;
      l_st_prev_max_lim			:= 0;
      -- Bug 8525925
      l_sep_tax_conversion_reqd         := null;
      l_total_lump_sum_amount           := 0 ;

      -- For Current Employer
      if p_emp_eligibility_flag = 'Y' then
         l_taxable_earnings     := p_total_taxable_earnings;
         l_sep_taxable_earnings := p_total_taxable_earnings;
      end if;

       -- Bug 8525925
      -- If Tax Conversion is required then calculate the receivable_sep_pay and
      -- modify the taxable earnings
        if p_amount_expected > 0 then
         l_sep_tax_conversion_reqd := 'Y';
       -- Bug 8996756
	if p_principal_interest > 0 then
         l_total_lump_sum_amount := p_amount_expected *
                        ( 1 - (p_personal_contribution - p_pension_exemption) / p_principal_interest );
	else
	 l_total_lump_sum_amount := p_amount_expected;
	end if;
	-- End of Bug 8996756
	 l_total_lump_sum_amount := greatest(0,trunc(l_total_lump_sum_amount)) ;
         l_receivable_sep_pay := l_taxable_earnings - p_sep_lump_sum_amount + l_total_lump_sum_amount;
         l_taxable_earnings   := greatest(trunc(l_receivable_sep_pay),0);
      end if;

      l_emp_hire_date := p_st_emp_hire_date;
      l_emp_leaving_date := p_st_emp_leaving_date;

      -- Call the function to calculate the Statutory Separation Pay Tax
      -- for the current employer
      p_sep_calc_tax := SepPayTaxCalc(
                       ceil(months_between(l_emp_leaving_date,l_emp_hire_date)/12),
		       0,
                       l_taxable_earnings,
                       l_sep_taxable_earnings,
                       l_receivable_sep_pay,
                       l_sep_tax_conversion_reqd,
                       p_business_group_id,
                       p_date_earned,
                       p_sep_pay_income_exem_rate);

      if p_emp_eligibility_flag = 'Y' then
      	   l_st_curr_max_lim 	:= ceil(months_between(l_emp_leaving_date,l_emp_hire_date)/12) * p_sep_max_post_tax_deduc;
      end if;

      if (l_st_curr_max_lim - l_st_prev_max_lim) > 0 then
      	   p_st_max_lim		:= l_st_curr_max_lim;
      else
           p_st_max_lim		:= l_st_prev_max_lim;
      end if;

      -- For Previous Employers
        l_taxable_earnings 	:= 0;
        l_sep_taxable_earnings 	:= 0;
        l_receivable_sep_pay 	:= 0;
      	l_dummy			:= 0;


      for i in get_eligible_earnings(p_date_earned, p_assignment_id)  loop
      /* Bug 8525925 */
      l_sep_tax_conversion_reqd := null;
      prev_principal_interest   := 0;
      prev_pension_exemption    := 0;
      prev_personal_contibution := 0;
      prev_amt_exp_stat_sep     := 0;
      prev_total_lump_sum_amount := 0;
      prev_total_received       := 0;
      prev_sep_lump_sum_amt := 0;
      l_count 		:= 0;

          for j in get_prev_stat_sp_earn(p_date_earned, p_assignment_id, i.element_entry_id) loop
          	l_taxable_earnings     := j.prev_earnings;
		l_taxable_earnings     := nvl(l_taxable_earnings,0);
      	  	l_sep_taxable_earnings := l_taxable_earnings;
         for k in  get_prev_bus_reg_num_sep(p_date_earned, p_assignment_id,i.element_entry_id) loop

          open csr_prev_lsa(k.element_entry_id,p_assignment_action_id);
		fetch csr_prev_lsa into prev_sep_lump_sum_amt;
		close csr_prev_lsa;
		l_taxable_earnings     :=  l_taxable_earnings + nvl(prev_sep_lump_sum_amt,0);

	      for m in get_prev_emp_amt (p_date_earned, p_assignment_id,k.element_entry_id) loop

	       if l_count = 0 then
		prev_amt_nonstat_sep := m.entry_value;
		l_count := l_count + 1;
	      elsif l_count = 1 then
      	        prev_amt_exp_stat_sep := m.entry_value;
		l_count := l_count + 1;
      	      elsif l_count = 2 then
      	         prev_pension_exemption := m.entry_value;
 		 l_count := l_count + 1;
              elsif l_count = 3 then
	         prev_personal_contibution := m.entry_value;
                  l_count := l_count + 1;
	       elsif l_count = 4 then
	         prev_principal_interest := m.entry_value;
		 l_count := l_count + 1;
 	       elsif l_count = 5 then
	         prev_total_received := m.entry_value;
      	      end if;

	    end loop;
	 end loop;

          -- If Tax Conversion is required then calculate the receivable_sep_pay and
          -- modify the taxable earnings
     if (nvl(prev_amt_exp_stat_sep,0) > 0 and  nvl(prev_total_received,0) >0) then

		l_sep_tax_conversion_reqd := 'Y';
  		if prev_principal_interest >0 then
	        prev_total_lump_sum_amount := nvl(prev_amt_exp_stat_sep,0) *
                        ( 1 - (nvl(prev_personal_contibution,0) - nvl(prev_pension_exemption,0)) / prev_principal_interest);
		else
		prev_total_lump_sum_amount := nvl(prev_amt_exp_stat_sep,0);
		end if;
                prev_total_lump_sum_amount := greatest(0,trunc(prev_total_lump_sum_amount));
		l_receivable_sep_pay := l_taxable_earnings + prev_total_lump_sum_amount - p_prev_sep_lump_sum_amt;
         	l_taxable_earnings   := greatest(l_receivable_sep_pay,0);
	 elsif nvl(prev_amt_exp_stat_sep,0) > 0 then
	        l_sep_tax_conversion_reqd := 'Y';
		prev_total_lump_sum_amount := greatest(0,trunc(prev_amt_exp_stat_sep));
                l_receivable_sep_pay := l_taxable_earnings + prev_total_lump_sum_amount - p_prev_sep_lump_sum_amt;
         	l_taxable_earnings   := greatest(l_receivable_sep_pay,0);
      	 end if;

            /* End of Bug 8525925 */

      	  l_prev_hire_date 	:= null;
      	  l_prev_int_date 	:= null;
      	  l_prev_leaving_date 	:= null;
      	  l_st_overlap_date1 	:= null;
      	  l_st_overlap_date2 	:= null;
      	  l_st_overlap_period 	:= 0;
	  l_count		:= 0;

	  -- Loop to fetch the date for the previous employer to calculate the Service Period and Overlap Periods
      	  for prev in get_prev_hire_leave_dt(p_date_earned, p_assignment_id, i.element_entry_id) loop
	      if l_count = 0 then
		l_prev_int_date := prev.dt_value;
		l_count := l_count + 1;
	      elsif l_count = 1 then
      	        l_prev_hire_date:= prev.dt_value;
		l_count := l_count + 1;
      	      elsif l_count = 2 then
      	         l_prev_leaving_date := prev.dt_value;
 		 l_count := l_count + 1;
      	      end if;

      	  end loop;

      	      if l_prev_int_date is null then
      	         l_prev_int_date := l_prev_hire_date;
	      end if;

      	      if (l_prev_hire_date is null) or (l_prev_leaving_date is null) then
		 fnd_message.set_name('PAY','PAY_KR_PREV_SEP_DATE_REQ');
		 fnd_message.raise_error;
	      end if;

          if l_emp_hire_date > l_prev_int_date then
             l_st_overlap_date1 := l_emp_hire_date;
          else
             l_st_overlap_date1 := l_prev_int_date;
          end if;

          if l_emp_leaving_date > l_prev_leaving_date then
             l_st_overlap_date2 := l_prev_leaving_date;
          else
             l_st_overlap_date2 := l_emp_leaving_date;
          end if;

          if ceil(months_between(l_st_overlap_date2,l_st_overlap_date1)/12) <= 0 then
             l_st_overlap_period := 0;
          else
             l_st_overlap_period := ceil(months_between(l_st_overlap_date2,l_st_overlap_date1)/12);
          end if;

          -- Call the function to calculate the Statutory Separation Pay Tax
          -- for the previous employer
      	  l_dummy := SepPayTaxCalc(
                       			ceil(months_between(l_prev_leaving_date,l_prev_int_date)/12),
					l_st_overlap_period,
                       			l_taxable_earnings,
                       			l_sep_taxable_earnings,
                       			l_receivable_sep_pay,
                       			l_sep_tax_conversion_reqd,
                       			p_business_group_id,
                       			p_date_earned,
                       			p_sep_pay_income_exem_rate);

     	   -- Code to calculate the maximum limit for the Statutory Separation Pay Post Tax deduction
      	   l_st_prev_max_lim 	:= ceil(months_between(l_prev_leaving_date,l_prev_int_date)/12) * p_sep_max_post_tax_deduc;

      	   if (l_st_curr_max_lim - l_st_prev_max_lim) > 0 then
      	   	p_st_max_lim		:= l_st_curr_max_lim;
      	   else
           	p_st_max_lim		:= l_st_prev_max_lim;
      	   end if;

          p_sep_calc_tax := p_sep_calc_tax + l_dummy;

          end loop;

      end loop;

	 hr_utility.trace('Total Calculated Tax for the Eligible Earnings for Post Tax = '||p_sep_calc_tax);

      return 0;

   end if;

elsif p_sep_cal_mode = 'NON_STAT_SEP_PAY' then
   --
   hr_utility.trace('Inside the Non-Statutory Separation Pay Process...');
   --
   if p_class = 1 then /* if we have to return the total tax for the individual working places */
      --
      hr_utility.trace('Inside the loop to return the Individual Calculated tax for all working places...');
      --
      l_taxable_earnings		:= 0;
      l_sep_taxable_earnings		:= 0;
      l_receivable_sep_pay		:= 0;
      p_sep_calc_tax			:= 0;
      p_nst_sep_calc_tax		:= 0;
      l_sep_calc_tax			:= 0;
      l_nst_sep_calc_tax		:= 0;
      l_nst_taxable_earnings            := 0;
      l_dummy				:= 0;
      l_emp_hire_date                   := null;
      l_emp_leaving_date                := null;
      l_nst_emp_hire_date               := null;
      l_nst_emp_leaving_date            := null;
      l_prev_hire_date                	:= null;
      l_prev_int_date                	:= null;
      l_prev_leaving_date             	:= null;
      -- Bug 8525925
      l_nst_receivable_sep_pay          := 0;
      l_nst_sep_taxable_earnings        := 0;
      l_sep_tax_conversion_reqd         := null;
      l_total_lump_sum_amount           := 0 ;

      -- For Current Employer
      l_nst_taxable_earnings := p_nst_taxable_earnings;
      l_nst_sep_taxable_earnings := p_nst_taxable_earnings;
      l_taxable_earnings     := p_total_taxable_earnings;
      l_sep_taxable_earnings := l_taxable_earnings;

      hr_utility.trace('Entering Class 1 current employer');

      -- Bug 8525925
      -- If Tax Conversion is required then calculate the receivable_sep_pay and
      -- modify the taxable earnings
      if p_amount_expected > 0 then
         l_sep_tax_conversion_reqd := 'Y';
      -- Bug 8996756
	if p_principal_interest > 0 then
         l_total_lump_sum_amount := p_amount_expected *
                        ( 1 - (p_personal_contribution - p_pension_exemption) / p_principal_interest );
	else
	 l_total_lump_sum_amount := p_amount_expected;
	end if;
       -- End of Bug 8996756
	 l_total_lump_sum_amount := greatest(0,trunc(l_total_lump_sum_amount)) ;
         l_receivable_sep_pay := l_taxable_earnings - p_sep_lump_sum_amount + l_total_lump_sum_amount;
         l_taxable_earnings   := greatest(trunc(l_receivable_sep_pay),0);
      end if;

      if p_nst_amount_expected > 0 then
         l_nst_receivable_sep_pay := l_nst_taxable_earnings + p_nst_amount_expected ;
	 l_nst_taxable_earnings := greatest(l_nst_receivable_sep_pay,0);
      end if;

      -- End of Bug 8525925
      l_emp_hire_date 		:= p_st_emp_hire_date;
      l_emp_leaving_date 	:= p_st_emp_leaving_date;
      l_nst_emp_hire_date 	:= p_nst_emp_hire_date;
      l_nst_emp_leaving_date 	:= p_nst_emp_leaving_date;

      NonStatTaxCalc(
                        ceil(months_between(l_emp_leaving_date,l_emp_hire_date)/12),
                        ceil(months_between(l_nst_emp_leaving_date,l_nst_emp_hire_date)/12),
                        0,
                        0,
                        l_sep_taxable_earnings    ,
                        l_taxable_earnings        ,
                        l_nst_taxable_earnings    ,
                        p_wkpd_int_sep_pay        ,
                        l_sep_tax_conversion_reqd ,
                        l_receivable_sep_pay      ,
                        p_date_earned          ,
                        p_business_group_id       ,
                        p_sep_pay_income_exem_rate,
                        l_nst_sep_calc_tax        ,
                        l_sep_calc_tax ,
			l_nst_receivable_sep_pay,
			l_nst_sep_taxable_earnings);

      p_sep_calc_tax			:= p_sep_calc_tax + l_sep_calc_tax;
      p_nst_sep_calc_tax		:= p_nst_sep_calc_tax + l_nst_sep_calc_tax;
      --
      --
      -- For Previous Employers
      l_element_entry_id 	:= null;
      l_taxable_earnings 	:= 0;
      l_sep_taxable_earnings 	:= 0;
      l_receivable_sep_pay 	:= 0;
      l_nst_taxable_earnings    := 0;
      l_nst_sep_calc_tax	:= 0;
      l_sep_calc_tax  		:= 0;

      hr_utility.trace('Entering Class 1 Previous employer.......');

      for i in get_prev_stat_sp_earn(p_date_earned, p_assignment_id, l_element_entry_id) loop

        	/* Bug 8525925 */
      l_sep_tax_conversion_reqd := null;
      prev_principal_interest   := 0;
      prev_pension_exemption    := 0;
      prev_personal_contibution := 0;
      prev_amt_exp_stat_sep     := 0;
      prev_total_lump_sum_amount := 0;
      prev_amt_nonstat_sep      := 0;
      prev_total_received       := 0;
      l_nst_receivable_sep_pay  := 0;
      l_nst_sep_taxable_earnings := 0;
      l_count 		:= 0;
      prev_sep_lump_sum_amt := 0;

          l_taxable_earnings     := i.prev_earnings ;
      	  l_taxable_earnings	   := nvl(l_taxable_earnings,0);

      	  for j in get_prev_non_stat_sp_earn(p_date_earned, p_assignment_id, i.element_entry_id) loop

              l_nst_taxable_earnings := j.prev_earnings;
              l_nst_sep_taxable_earnings := j.prev_earnings; -- Bug 8525925

          end loop;
	  /* Start of  Bug 8525925 */
	  for k in  get_prev_bus_reg_num_sep(p_date_earned, p_assignment_id,i.element_entry_id) loop

	  open csr_prev_lsa(k.element_entry_id,p_assignment_action_id);
		fetch csr_prev_lsa into prev_sep_lump_sum_amt;
		close csr_prev_lsa;
		l_taxable_earnings     :=  l_taxable_earnings + nvl(prev_sep_lump_sum_amt,0);

	    for m in get_prev_emp_amt (p_date_earned, p_assignment_id,k.element_entry_id) loop

	       if l_count = 0 then
		prev_amt_nonstat_sep := m.entry_value;
		l_count := l_count + 1;
	      elsif l_count = 1 then
      	        prev_amt_exp_stat_sep := m.entry_value;
		l_count := l_count + 1;
      	      elsif l_count = 2 then
      	         prev_pension_exemption := m.entry_value;
 		 l_count := l_count + 1;
              elsif l_count = 3 then
	         prev_personal_contibution := m.entry_value;
                  l_count := l_count + 1;
	       elsif l_count = 4 then
	         prev_principal_interest := m.entry_value;
		 l_count := l_count + 1;
		elsif l_count = 5 then
		 prev_total_received := m.entry_value;
      	      end if;
            end loop;

	  end loop;

           l_taxable_earnings     := l_taxable_earnings - l_nst_taxable_earnings;
           l_sep_taxable_earnings := l_taxable_earnings;

          -- If Tax Conversion is required then calculate the receivable_sep_pay and
          -- modify the taxable earnings
        	  if (nvl(prev_amt_exp_stat_sep,0) > 0 and nvl(prev_total_received,0) > 0) then

		l_sep_tax_conversion_reqd := 'Y';
		if prev_principal_interest > 0 then
	        prev_total_lump_sum_amount := nvl(prev_amt_exp_stat_sep,0) *
                        ( 1 - (nvl(prev_personal_contibution,0) - nvl(prev_pension_exemption,0)) / prev_principal_interest);
		else
		prev_total_lump_sum_amount := nvl(prev_amt_exp_stat_sep,0);
		end if;
                prev_total_lump_sum_amount := greatest(0,trunc(prev_total_lump_sum_amount));
		l_receivable_sep_pay := l_taxable_earnings + prev_total_lump_sum_amount - p_prev_sep_lump_sum_amt;
         	l_taxable_earnings   := greatest(l_receivable_sep_pay,0);

	     elsif nvl(prev_amt_exp_stat_sep,0) > 0 then
	        l_sep_tax_conversion_reqd := 'Y';
		prev_total_lump_sum_amount := greatest(0,trunc(prev_amt_exp_stat_sep));
                l_receivable_sep_pay := l_taxable_earnings + prev_total_lump_sum_amount - p_prev_sep_lump_sum_amt;
         	l_taxable_earnings   := greatest(l_receivable_sep_pay,0);
      	    end if;

           if (nvl(prev_amt_nonstat_sep,0) > 0 ) then
		 l_nst_receivable_sep_pay := l_nst_taxable_earnings + prev_amt_nonstat_sep ;
		 l_nst_taxable_earnings := greatest(l_nst_receivable_sep_pay,0);
	    end if;

           /* End of Bug 8525925 */
      	  l_prev_hire_date 	:= null;
      	  l_prev_int_date  	:= null;
      	  l_prev_leaving_date 	:= null;
      	  l_st_overlap_date1 	:= null;
      	  l_st_overlap_date2 	:= null;
      	  l_nst_overlap_date1 	:= null;
      	  l_nst_overlap_date2 	:= null;
      	  l_st_overlap_period 	:= 0;
      	  l_nst_overlap_period 	:= 0;
	  l_count		:= 0;

	  -- Loop to fetch the dates for the previous employer to calculate the Service Period and Overlap Periods
      	  for prev in get_prev_hire_leave_dt(p_date_earned, p_assignment_id, i.element_entry_id) loop
	      if l_count = 0 then
		l_prev_int_date := prev.dt_value;
		l_count := l_count + 1;
	      elsif l_count = 1 then
      	        l_prev_hire_date:= prev.dt_value;
		l_count := l_count + 1;
      	      elsif l_count = 2 then
      	         l_prev_leaving_date := prev.dt_value;
 		 l_count := l_count + 1;
      	      end if;

      	  end loop;

      	      if l_prev_int_date is null then
      	         l_prev_int_date := l_prev_hire_date;
	      end if;

      	      if (l_prev_hire_date is null) or (l_prev_leaving_date is null) then
		 fnd_message.set_name('PAY','PAY_KR_PREV_SEP_DATE_REQ');
		 fnd_message.raise_error;
	      end if;

          if l_emp_hire_date > l_prev_int_date then
             l_st_overlap_date1 := l_emp_hire_date;
          else
             l_st_overlap_date1 := l_prev_int_date;
          end if;

          if l_emp_leaving_date > l_prev_leaving_date then
             l_st_overlap_date2 := l_prev_leaving_date;
          else
             l_st_overlap_date2 := l_emp_leaving_date;
          end if;

          if ceil(months_between(l_st_overlap_date2,l_st_overlap_date1)/12) <= 0 then
             l_st_overlap_period := 0;
          else
             l_st_overlap_period := ceil(months_between(l_st_overlap_date2,l_st_overlap_date1)/12);
          end if;

          if l_nst_emp_hire_date > l_prev_hire_date then
             l_nst_overlap_date1 := l_nst_emp_hire_date;
          else
             l_nst_overlap_date1 := l_prev_hire_date;
          end if;

          if l_nst_emp_leaving_date > l_prev_leaving_date then
             l_nst_overlap_date2 := l_prev_leaving_date;
          else
             l_nst_overlap_date2 := l_nst_emp_leaving_date;
          end if;

          if ceil(months_between(l_nst_overlap_date2,l_nst_overlap_date1)/12) <= 0 then
             l_nst_overlap_period := 0;
          else
             l_nst_overlap_period := ceil(months_between(l_nst_overlap_date2,l_nst_overlap_date1)/12);
          end if;

          NonStatTaxCalc(
          		ceil(months_between(l_prev_leaving_date,l_prev_int_date)/12),
          		ceil(months_between(l_prev_leaving_date,l_prev_hire_date)/12),
                        l_st_overlap_period       ,
                        l_nst_overlap_period      ,
                        l_sep_taxable_earnings    ,
                        l_taxable_earnings        ,
                        l_nst_taxable_earnings    ,
                        p_wkpd_int_sep_pay        ,
                        l_sep_tax_conversion_reqd ,
                        l_receivable_sep_pay      ,
                        p_date_earned          ,
                        p_business_group_id       ,
                        p_sep_pay_income_exem_rate,
                        l_nst_sep_calc_tax        ,
                        l_sep_calc_tax,
			l_nst_receivable_sep_pay,
			l_nst_sep_taxable_earnings
			);

          p_sep_calc_tax		:= p_sep_calc_tax + l_sep_calc_tax;
          p_nst_sep_calc_tax		:= p_nst_sep_calc_tax + l_nst_sep_calc_tax;
          --
      end loop;
      return 0;

   elsif p_class = 2 then /* if we have to return the total tax for the eligible working places */
      --
      hr_utility.trace('Inside the loop to return the Calculated tax for the Eligible Working places ....');
      --
      l_taxable_earnings		:= 0;
      l_sep_taxable_earnings		:= 0;
      l_receivable_sep_pay		:= 0;
      p_sep_calc_tax			:= 0;
      p_nst_sep_calc_tax		:= 0;
      l_element_entry_id		:= 0;
      l_nst_prev_earnings 		:= 0;
      l_nst_taxable_earnings 		:= 0;
      l_sep_calc_tax			:= 0;
      l_nst_sep_calc_tax		:= 0;
      l_curr_max_lim			:= 0;
      l_prev_max_lim			:= 0;
      l_st_curr_max_lim			:= 0;
      l_nst_curr_max_lim		:= 0;
      l_st_prev_max_lim			:= 0;
      l_nst_prev_max_lim		:= 0;
      -- Bug 8525925
      l_nst_receivable_sep_pay          := 0;
      l_nst_sep_taxable_earnings        := 0;
      l_sep_tax_conversion_reqd         := null;

      -- For Current Employer
      if p_emp_eligibility_flag = 'Y' then
      	l_nst_taxable_earnings := p_nst_taxable_earnings;
	l_nst_sep_taxable_earnings := p_nst_taxable_earnings;
      	l_taxable_earnings     := p_total_taxable_earnings;
      	l_sep_taxable_earnings := l_taxable_earnings;
      end if;

      -- Bug 8525925
      -- If Tax Conversion is required then calculate the receivable_sep_pay and
      -- modify the taxable earnings
         if p_amount_expected > 0 then
         l_sep_tax_conversion_reqd := 'Y';
	-- Bug 8996756
	if p_principal_interest > 0 then
         l_total_lump_sum_amount := p_amount_expected *
                        ( 1 - (p_personal_contribution - p_pension_exemption) / p_principal_interest );
	else
	 l_total_lump_sum_amount := p_amount_expected;
	end if;
	-- End of Bug 8996756
	 l_total_lump_sum_amount := greatest(0,trunc(l_total_lump_sum_amount)) ;
         l_receivable_sep_pay := l_taxable_earnings - p_sep_lump_sum_amount + l_total_lump_sum_amount;
         l_taxable_earnings   := greatest(trunc(l_receivable_sep_pay),0);
      end if;

       if p_nst_amount_expected > 0 then
         l_nst_receivable_sep_pay := l_nst_taxable_earnings + p_nst_amount_expected ;
	 l_nst_taxable_earnings := greatest(l_nst_receivable_sep_pay,0);
      end if;

     -- End of Bug 8525925

      l_emp_hire_date 		:= p_st_emp_hire_date;
      l_emp_leaving_date 	:= p_st_emp_leaving_date;
      l_nst_emp_hire_date 	:= p_nst_emp_hire_date;
      l_nst_emp_leaving_date 	:= p_nst_emp_leaving_date;


      NonStatTaxCalc(
                        ceil(months_between(l_emp_leaving_date,l_emp_hire_date)/12),
                        ceil(months_between(l_nst_emp_leaving_date,l_nst_emp_hire_date)/12),
                        0,
                        0,
                        l_sep_taxable_earnings    ,
                        l_taxable_earnings        ,
                        l_nst_taxable_earnings    ,
                        p_wkpd_int_sep_pay        ,
                        l_sep_tax_conversion_reqd ,
                        l_receivable_sep_pay      ,
                        p_date_earned          ,
                        p_business_group_id       ,
                        p_sep_pay_income_exem_rate,
                        l_nst_sep_calc_tax        ,
                        l_sep_calc_tax ,
                        l_nst_receivable_sep_pay,
                        l_nst_sep_taxable_earnings);

      p_sep_calc_tax			:= p_sep_calc_tax + l_sep_calc_tax;
      p_nst_sep_calc_tax		:= p_nst_sep_calc_tax + l_nst_sep_calc_tax;
      --
      -- Code to calculate the maximum limits for the Non-Statutory Process
      if p_emp_eligibility_flag = 'Y' then
      	   l_st_curr_max_lim 	:= ceil(months_between(l_emp_leaving_date,l_emp_hire_date)/12) * p_sep_max_post_tax_deduc;
      	   l_nst_curr_max_lim	:= ceil(months_between(l_nst_emp_leaving_date,l_nst_emp_hire_date)/12) * p_sep_max_post_tax_deduc;
      	   l_curr_max_lim	:= greatest(l_st_curr_max_lim,l_nst_curr_max_lim);
      end if;

      if (l_curr_max_lim - l_prev_max_lim) > 0 then
      	   p_st_max_lim		:= l_st_curr_max_lim;
      	   p_nst_max_lim	:= l_curr_max_lim - l_st_curr_max_lim;
      else
           p_st_max_lim		:= l_st_prev_max_lim;
           p_nst_max_lim	:= l_nst_prev_max_lim;
      end if;
      --
      -- For Previous Employers
      l_element_entry_id 	:= null;
      l_taxable_earnings 	:= 0;
      l_sep_taxable_earnings 	:= 0;
      l_receivable_sep_pay 	:= 0;
      l_nst_taxable_earnings    := 0;
      l_nst_sep_calc_tax	:= 0;
      l_sep_calc_tax  		:= 0;


          hr_utility.trace('Entering Class 2 for previous employer');

      for i in get_eligible_earnings(p_date_earned, p_assignment_id)  loop
       /* Bug 8525925 */
      l_sep_tax_conversion_reqd := null;
      prev_principal_interest   := 0;
      prev_pension_exemption    := 0;
      prev_personal_contibution := 0;
      prev_amt_exp_stat_sep     := 0;
      prev_total_lump_sum_amount := 0;
      prev_amt_nonstat_sep      := 0;
      prev_total_received       := 0;
      l_nst_receivable_sep_pay  := 0;
      l_nst_sep_taxable_earnings := 0;
      l_count 		:= 0;
      prev_sep_lump_sum_amt := 0;

          for j in get_prev_stat_sp_earn(p_date_earned, p_assignment_id, i.element_entry_id) loop

              l_taxable_earnings := j.prev_earnings ;
	      l_taxable_earnings := nvl(l_taxable_earnings,0);

          	for k in get_prev_non_stat_sp_earn(p_date_earned, p_assignment_id, i.element_entry_id) loop

              		l_nst_taxable_earnings 	:= k.prev_earnings;
                        l_nst_sep_taxable_earnings := k.prev_earnings;
          	end loop;
	  /* Start of  Bug 8525925 */
	  for m in  get_prev_bus_reg_num_sep(p_date_earned, p_assignment_id,i.element_entry_id) loop

	  open csr_prev_lsa(m.element_entry_id,p_assignment_action_id);
		fetch csr_prev_lsa into prev_sep_lump_sum_amt;
		close csr_prev_lsa;
		l_taxable_earnings     :=  l_taxable_earnings + nvl(prev_sep_lump_sum_amt,0);

	     for n in get_prev_emp_amt (p_date_earned, p_assignment_id,m.element_entry_id) loop

	       if l_count = 0 then
		prev_amt_nonstat_sep := n.entry_value;
		l_count := l_count + 1;
	      elsif l_count = 1 then
      	        prev_amt_exp_stat_sep := n.entry_value;
		l_count := l_count + 1;
      	      elsif l_count = 2 then
      	         prev_pension_exemption := n.entry_value;
 		 l_count := l_count + 1;
              elsif l_count = 3 then
	         prev_personal_contibution := n.entry_value;
                  l_count := l_count + 1;
	       elsif l_count = 4 then
	         prev_principal_interest := n.entry_value;
		  l_count := l_count + 1;
	       elsif l_count = 5 then
	         prev_total_received := n.entry_value;
      	      end if;

	     end loop;

	  end loop;


           l_taxable_earnings     := l_taxable_earnings - l_nst_taxable_earnings;
           l_sep_taxable_earnings := l_taxable_earnings;

          -- If Tax Conversion is required then calculate the receivable_sep_pay and
          -- modify the taxable earnings
      	      if (nvl(prev_amt_exp_stat_sep,0) > 0 and nvl(prev_total_received,0) > 0) then

		l_sep_tax_conversion_reqd := 'Y';
		if prev_principal_interest > 0 then
	        prev_total_lump_sum_amount := nvl(prev_amt_exp_stat_sep,0) *
                        ( 1 - (nvl(prev_personal_contibution,0) - nvl(prev_pension_exemption,0)) / prev_principal_interest);
		else
		prev_total_lump_sum_amount := nvl(prev_amt_exp_stat_sep,0);
		end if;
                prev_total_lump_sum_amount := greatest(0,trunc(prev_total_lump_sum_amount));
		l_receivable_sep_pay := l_taxable_earnings + prev_total_lump_sum_amount - p_prev_sep_lump_sum_amt;
         	l_taxable_earnings   := greatest(l_receivable_sep_pay,0);

	      elsif nvl(prev_amt_exp_stat_sep,0) > 0 then
                 l_sep_tax_conversion_reqd := 'Y';
		 prev_total_lump_sum_amount := greatest(0,trunc(prev_amt_exp_stat_sep));
		l_receivable_sep_pay := l_taxable_earnings + prev_total_lump_sum_amount - p_prev_sep_lump_sum_amt;
         	l_taxable_earnings   := greatest(l_receivable_sep_pay,0);

      	    end if;

            if (nvl(prev_amt_nonstat_sep,0) > 0 ) then
		 l_nst_receivable_sep_pay := l_nst_taxable_earnings + prev_amt_nonstat_sep ;
		 l_nst_taxable_earnings := greatest(l_nst_receivable_sep_pay,0);
	    end if;

	      /* End of Bug 8525925 */

      	  l_prev_hire_date 	:= null;
      	  l_prev_int_date  	:= null;
      	  l_prev_leaving_date 	:= null;
      	  l_st_overlap_date1 	:= null;
      	  l_st_overlap_date2 	:= null;
      	  l_nst_overlap_date1 	:= null;
      	  l_nst_overlap_date2 	:= null;
      	  l_st_overlap_period 	:= 0;
      	  l_nst_overlap_period 	:= 0;
	  l_count		:= 0;

	  -- Loop to fetch the dates for the previous employer to calculate the Service Period
      	  for prev in get_prev_hire_leave_dt(p_date_earned, p_assignment_id, i.element_entry_id) loop
	      if l_count = 0 then
		l_prev_int_date := prev.dt_value;
		l_count := l_count + 1;
	      elsif l_count = 1 then
      	        l_prev_hire_date:= prev.dt_value;
		l_count := l_count + 1;
      	      elsif l_count = 2 then
      	         l_prev_leaving_date := prev.dt_value;
 		 l_count := l_count + 1;
      	      end if;

      	  end loop;

      	      if l_prev_int_date is null then
      	         l_prev_int_date := l_prev_hire_date;
	      end if;

      	      if (l_prev_hire_date is null) or (l_prev_leaving_date is null) then
		 fnd_message.set_name('PAY','PAY_KR_PREV_SEP_DATE_REQ');
		 fnd_message.raise_error;
	      end if;

          if l_emp_hire_date > l_prev_int_date then
             l_st_overlap_date1 := l_emp_hire_date;
          else
             l_st_overlap_date1 := l_prev_int_date;
          end if;

          if l_emp_leaving_date > l_prev_leaving_date then
             l_st_overlap_date2 := l_prev_leaving_date;
          else
             l_st_overlap_date2 := l_emp_leaving_date;
          end if;

          if ceil(months_between(l_st_overlap_date2,l_st_overlap_date1)/12) <= 0 then
             l_st_overlap_period := 0;
          else
             l_st_overlap_period := ceil(months_between(l_st_overlap_date2,l_st_overlap_date1)/12);
          end if;

          if l_nst_emp_hire_date > l_prev_hire_date then
             l_nst_overlap_date1 := l_nst_emp_hire_date;
          else
             l_nst_overlap_date1 := l_prev_hire_date;
          end if;

          if l_nst_emp_leaving_date > l_prev_leaving_date then
             l_nst_overlap_date2 := l_prev_leaving_date;
          else
             l_nst_overlap_date2 := l_nst_emp_leaving_date;
          end if;

          if ceil(months_between(l_nst_overlap_date2,l_nst_overlap_date1)/12) <= 0 then
             l_nst_overlap_period := 0;
          else
             l_nst_overlap_period := ceil(months_between(l_nst_overlap_date2,l_nst_overlap_date1)/12);
          end if;

          NonStatTaxCalc(
          		ceil(months_between(l_prev_leaving_date,l_prev_int_date)/12),
          		ceil(months_between(l_prev_leaving_date,l_prev_hire_date)/12),
                        l_st_overlap_period       ,
                        l_nst_overlap_period      ,
                        l_sep_taxable_earnings    ,
                        l_taxable_earnings        ,
                        l_nst_taxable_earnings    ,
                        p_wkpd_int_sep_pay        ,
                        l_sep_tax_conversion_reqd ,
                        l_receivable_sep_pay      ,
                        p_date_earned          ,
                        p_business_group_id       ,
                        p_sep_pay_income_exem_rate,
                        l_nst_sep_calc_tax        ,
                        l_sep_calc_tax,
			l_nst_receivable_sep_pay  ,
                        l_nst_sep_taxable_earnings );

          p_sep_calc_tax		:= p_sep_calc_tax + l_sep_calc_tax;
          p_nst_sep_calc_tax		:= p_nst_sep_calc_tax + l_nst_sep_calc_tax;

          -- Code to calculate the maximum limits for the Non-Statutory Process
      	   l_st_prev_max_lim 	:= ceil(months_between(l_prev_leaving_date,l_prev_int_date)/12) * p_sep_max_post_tax_deduc;
      	   l_nst_prev_max_lim	:= ceil(months_between(l_prev_leaving_date,l_prev_hire_date)/12) * p_sep_max_post_tax_deduc;
      	   l_prev_max_lim	:= greatest(l_st_prev_max_lim,l_nst_prev_max_lim);

           if (l_curr_max_lim - l_prev_max_lim) > 0 then
      	      p_st_max_lim	:= l_st_curr_max_lim;
      	      p_nst_max_lim	:= l_curr_max_lim - l_st_curr_max_lim;
           else
              p_st_max_lim	:= l_st_prev_max_lim;
              p_nst_max_lim	:= l_nst_prev_max_lim;
           end if;
          --
          end loop;

      end loop;
      --
      return 0;

   end if;

end if;


exception
when others then
raise;

end;
-----------------------------------------------------------------------------------------------
-- Bug 8466662: This function simulates the Statutory Separation Pay Process and returns the
--    		Statutory Calculated Tax value.
-----------------------------------------------------------------------------------------------
function SepPayTaxCalc(
                       p_service_period           in number,
		       p_overlap_period          in number,
                       p_taxable_earnings 	  in number,
                       p_sep_taxable_earnings 	  in number,
                       p_receivable_sep_pay 	  in number,
                       p_sep_tax_conversion_reqd  in varchar2,
                       p_business_group_id        in number,
                       p_effective_date           in date,
                       p_sep_pay_income_exem_rate in number) return number
is

l_addend               number;
l_multiplier           number;
l_subtrahend           number;
l_svpd_income_exem     number;
l_sep_pay_income_exem  number;
l_income_exem          number;
l_sep_taxation_base    number;
l_ytaxation_base       number;
l_taxation_base        number;
l_ycalc_tax            number;
l_calc_tax             number;
l_sep_calc_tax         number;


begin
          l_svpd_income_exem := 0;
	  if (p_service_period - p_overlap_period) > 0 then
	    l_addend     := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'ADDEND',
							p_row_value		=> to_char(p_service_period - p_overlap_period),
							p_effective_date	=> p_effective_date));
	    l_multiplier := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'MULTIPLIER',
							p_row_value		=> to_char(p_service_period - p_overlap_period),
							p_effective_date	=> p_effective_date));
	    l_subtrahend := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'SUBTRAHEND',
							p_row_value		=> to_char(p_service_period - p_overlap_period),
							p_effective_date	=> p_effective_date));
	    l_svpd_income_exem := l_addend + trunc(l_multiplier * (p_service_period - l_subtrahend));
	  end if;
	  l_sep_pay_income_exem := 0;
	  if p_taxable_earnings > 0 then
	    l_sep_pay_income_exem := trunc(p_taxable_earnings * p_sep_pay_income_exem_rate/ 100);
	  end if;
	  l_income_exem := l_svpd_income_exem + l_sep_pay_income_exem;

	  /******************/
	  /* Taxable Income */
	  /******************/
	  l_sep_taxation_base := greatest(greatest(p_taxable_earnings, 0) - l_income_exem, 0);
	  l_ytaxation_base := 0;
	  if p_service_period >= 1 then
	    l_ytaxation_base := trunc(l_sep_taxation_base / p_service_period);
	  end if;
	  /*****************/
	  /* Taxation Base */
	  /*****************/
	  l_taxation_base := greatest(l_ytaxation_base, 0);
	  /******************/
	  /* Calculated Tax */
	  /******************/
	  l_ycalc_tax := 0;
	  l_calc_tax := 0;
	  l_sep_calc_tax := 0;
	  if l_taxation_base > 0 then
	    l_multiplier := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'CALC_TAX',
							p_col_name		=> 'MULTIPLIER',
							p_row_value		=> to_char(l_taxation_base),
							p_effective_date	=> p_effective_date));
	    l_subtrahend := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'CALC_TAX',
							p_col_name		=> 'SUBTRAHEND',
							p_row_value		=> to_char(l_taxation_base),
							p_effective_date	=> p_effective_date));
	    l_ycalc_tax := trunc(l_taxation_base * l_multiplier / 100) - l_subtrahend;
	    /* To avoid to return calc tax result in other process */
	    l_calc_tax := l_ycalc_tax;
	    if p_service_period >= 1 then
	      l_sep_calc_tax := l_calc_tax * p_service_period;
	    end if;
	  end if;

          /******************************************/
          /* Converted Separation Tax Calculation   */
          /******************************************/
          if p_sep_tax_conversion_reqd = 'Y' and p_receivable_sep_pay > 0 then
              /* assign converted tax to o_sep_calc_tax for further processing */
              l_sep_calc_tax := trunc(l_ycalc_tax * p_service_period
                  * (p_sep_taxable_earnings / p_receivable_sep_pay));
          end if;
return l_sep_calc_tax;
exception
when others then
raise;

end;
-----------------------------------------------------------------------------------------------
-- Bug 8466662: This procedure simulates the Non-Statutory Separation Pay Process and returns the
--    		Statutory and Non-Statutory Calculated Tax values.
-----------------------------------------------------------------------------------------------
Procedure NonStatTaxCalc(
                        p_service_period          in   number,
                        p_nst_service_period      in   number,
                        p_st_overlap_period	  in   number,
                        p_nst_overlap_period	  in   number,
                        p_sep_taxable_earnings    in   number,
                        p_taxable_earnings        in   number,
                        p_nst_taxable_earnings    in   number,
                        p_wkpd_int_sep_pay        in   number,
                        p_sep_tax_conversion_reqd in   varchar2,
                        p_receivable_sep_pay      in   number,
                        p_effective_date          in   date,
                        p_business_group_id       in   number,
                        p_sep_pay_income_exem_rate in  number,
                        l_nst_sep_calc_tax        out NOCOPY number,
                        l_sep_calc_tax            out NOCOPY number,
			p_nst_receivable_sep_pay   in   number,
			p_nst_sep_taxable_earnings in   number)
is

l_addend     			number;
l_multiplier 			number;
l_subtrahend 			number;
l_nst_addend 			number;
l_nst_multiplier		number;
l_nst_subtrahend		number;
l_svpd_income_exem		number;
l_sep_pay_income_exem		number;
l_income_exem			number;
l_sep_taxation_base		number;
l_ytaxation_base		number;
l_taxation_base			number;
l_nst_sep_taxable_earnings	number;
l_nst_svpd_income_exem		number;
l_nst_int_service_period	number;
l_wkpd_int_sep_pay		number;
l_nst_ent_svpd_income_exem	number;
l_nst_int_svpd_income_exem	number;
l_nst_st_svpd_income_exem       number;
l_nst_st_service_period		number;
l_nst_sep_pay_income_exem	number;
l_nst_income_exem		number;
l_nst_sep_taxation_base		number;
l_nst_ytaxation_base		number;
l_nst_taxation_base		number;
l_total_taxation_base		number;
l_total_ycalc_tax		number;
l_tot_multiplier		number;
l_tot_subtrahend		number;
l_ycalc_tax			number;
l_nst_ycalc_tax			number;
-- Bug 8525925
l_nst_receivable_sep_pay        number;

begin
	  /* 1.Service Period Income Exemption */
	  /* 2.Separation Pay Income Exemption */
	  l_svpd_income_exem := 0;


	  if (p_service_period - p_st_overlap_period) > 0 then
	    l_addend     := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'ADDEND',
							p_row_value		=> to_char(p_service_period - p_st_overlap_period),
							p_effective_date	=> p_effective_date));
	    l_multiplier := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'MULTIPLIER',
							p_row_value		=> to_char(p_service_period - p_st_overlap_period),
							p_effective_date	=> p_effective_date));
	    l_subtrahend := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'SUBTRAHEND',
							p_row_value		=> to_char(p_service_period - p_st_overlap_period),
							p_effective_date	=> p_effective_date));
	    l_svpd_income_exem := l_addend + trunc(l_multiplier * ((p_service_period - p_st_overlap_period) - l_subtrahend));
	  end if;

	  l_sep_pay_income_exem := 0;
	  if p_taxable_earnings > 0 then
	    l_sep_pay_income_exem := trunc(p_taxable_earnings * p_sep_pay_income_exem_rate/ 100);
	  end if;
	  l_income_exem := l_svpd_income_exem + l_sep_pay_income_exem;
	  /* Taxable Income */

	  l_sep_taxation_base := greatest(greatest(p_taxable_earnings, 0) - l_income_exem, 0);
	  l_ytaxation_base := 0;
	  if p_service_period >= 1 then
	    l_ytaxation_base := greatest(trunc(l_sep_taxation_base / p_service_period), 0);
	  end if;
	  /* To avoid to return taxation base result in other process */
	  l_taxation_base := l_ytaxation_base;


	/* -------------   Non Statutory Sep Pay ------------------*/
             -- Bug 8525925
	     l_nst_sep_taxable_earnings := p_nst_sep_taxable_earnings;
	     l_nst_receivable_sep_pay   := p_nst_receivable_sep_pay;

	     /* 1.Service Period Income Exemption */
	     /* 2.Separation Pay Income Exemption */
	     l_nst_svpd_income_exem := 0;
	     l_nst_int_service_period := 0  ;
             l_wkpd_int_sep_pay := 0 ;
             l_nst_ent_svpd_income_exem := 0;
             l_nst_int_svpd_income_exem := 0;
	     if (p_nst_service_period - p_nst_overlap_period) > 0 then
                      l_nst_st_service_period := p_service_period;

		      if p_wkpd_int_sep_pay > 0 and p_wkpd_int_sep_pay <= (p_nst_service_period - p_nst_overlap_period) then

			     l_nst_int_service_period := p_wkpd_int_sep_pay;

                      else
			     l_nst_int_service_period := (p_nst_service_period - p_nst_overlap_period) - l_nst_st_service_period ;
         	      end if;
                     /* Deductions for entire working Period */
	       l_nst_addend     := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'ADDEND',
							p_row_value		=> to_char(p_nst_service_period - p_nst_overlap_period),
							p_effective_date	=> p_effective_date));
	       l_nst_multiplier := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'MULTIPLIER',
							p_row_value		=> to_char(p_nst_service_period - p_nst_overlap_period),
							p_effective_date	=> p_effective_date));
	       l_nst_subtrahend := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'SUBTRAHEND',
							p_row_value		=> to_char(p_nst_service_period - p_nst_overlap_period),
							p_effective_date	=> p_effective_date));
	       l_nst_ent_svpd_income_exem := l_nst_addend + trunc(l_nst_multiplier * ((p_nst_service_period - p_nst_overlap_period) - l_nst_subtrahend));
                     /* Deductions for the working period of interim separation pay */
	       l_nst_addend     := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'ADDEND',
							p_row_value		=> to_char(l_nst_int_service_period),
							p_effective_date	=> p_effective_date));
	       l_nst_multiplier := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'MULTIPLIER',
							p_row_value		=> to_char(l_nst_int_service_period),
							p_effective_date	=> p_effective_date));
	       l_nst_subtrahend := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'SUBTRAHEND',
							p_row_value		=> to_char(l_nst_int_service_period),
							p_effective_date	=> p_effective_date));
	       l_nst_int_svpd_income_exem := l_nst_addend + trunc(l_nst_multiplier * (l_nst_int_service_period - l_nst_subtrahend));
                     /* Deductions for the working period of statutory separation pay */
	       l_nst_addend     := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'ADDEND',
							p_row_value		=> to_char(l_nst_st_service_period),
							p_effective_date	=> p_effective_date));

	       l_nst_multiplier := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'MULTIPLIER',
							p_row_value		=> to_char(l_nst_st_service_period),
							p_effective_date	=> p_effective_date));

	       l_nst_subtrahend := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'SVPD_INCOME_EXEM',
							p_col_name		=> 'SUBTRAHEND',
							p_row_value		=> to_char(l_nst_st_service_period),
							p_effective_date	=> p_effective_date));

	       l_nst_st_svpd_income_exem := l_nst_addend + trunc(l_nst_multiplier * (l_nst_st_service_period - l_nst_subtrahend));
	       l_nst_svpd_income_exem := l_nst_ent_svpd_income_exem - l_nst_int_svpd_income_exem - l_nst_st_svpd_income_exem;
	     end if;
	     l_nst_sep_pay_income_exem := 0;
	     if p_nst_taxable_earnings > 0 then
	       l_nst_sep_pay_income_exem := trunc(p_nst_taxable_earnings * p_sep_pay_income_exem_rate/ 100);
	     end if;
	     l_nst_income_exem := l_nst_svpd_income_exem + l_nst_sep_pay_income_exem;
	     /* Taxable Income */

	     l_nst_sep_taxation_base := greatest(greatest(p_nst_taxable_earnings, 0) - l_nst_income_exem, 0);
	     l_nst_ytaxation_base := 0;

	     if p_nst_service_period >= 1 then
	       l_nst_ytaxation_base := greatest(trunc(l_nst_sep_taxation_base / p_nst_service_period), 0);
	      end if;

	     /* To avoid to return taxation base result in other process */
	     l_nst_taxation_base := l_nst_ytaxation_base;

             /* -------- Tax Calculation for Stat and Non Stat Sep Pay ---------*/
             /* Total taxation Base */
                   l_total_taxation_base := l_taxation_base + l_nst_taxation_base;
	     /* Total yearly calculated tax */
	     l_total_ycalc_tax := 0;
	     if l_total_taxation_base > 0 then
	       l_tot_multiplier     :=   to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'CALC_TAX',
							p_col_name		=> 'MULTIPLIER',
							p_row_value		=> to_char(l_total_taxation_base),
							p_effective_date	=> p_effective_date));

	       l_tot_subtrahend  :=   to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'CALC_TAX',
							p_col_name		=> 'SUBTRAHEND',
							p_row_value		=> to_char(l_total_taxation_base),
							p_effective_date	=> p_effective_date));

	       l_total_ycalc_tax := trunc(l_total_taxation_base * l_tot_multiplier / 100) - l_tot_subtrahend;
             end if;
             l_ycalc_tax := 0;
             l_nst_ycalc_tax := 0;
	     if l_total_taxation_base > 0 then
                     /* Yearly Calculated Tax for Stat and non stat sep pay */
	       l_ycalc_tax :=  trunc(l_total_ycalc_tax *( l_taxation_base/l_total_taxation_base ));
	       l_nst_ycalc_tax :=  trunc(l_total_ycalc_tax *( l_nst_taxation_base/l_total_taxation_base ));
             end if;

	      /* Calculated Tax for Stat and non stat sep pay */
             l_sep_calc_tax := 0;
	     if p_service_period >= 1 then
                 /* Converted Stat Sep Tax Calculation   */
                 if p_sep_tax_conversion_reqd = 'Y' and p_receivable_sep_pay > 0then
                     l_sep_calc_tax := trunc(l_ycalc_tax * p_service_period
                         * (p_sep_taxable_earnings / p_receivable_sep_pay));

                 else
                     l_sep_calc_tax := l_ycalc_tax * p_service_period;
                 end if;
	     end if;

	    -- Bug 8525925
	    l_nst_sep_calc_tax := 0;
	     if p_nst_service_period >= 1 then
                 /* Converted non-stat tax calculation is identical to   */
                 /* Normal non-stat calculation */
		 if l_nst_receivable_sep_pay > 0 then
                     l_nst_sep_calc_tax := trunc(l_nst_ycalc_tax * p_nst_service_period
                         * (l_nst_sep_taxable_earnings / l_nst_receivable_sep_pay));
                 else
		 l_nst_sep_calc_tax := l_nst_ycalc_tax * p_nst_service_period;
		 end if;

	     end if;


exception
when others then
raise;
--
end;

---------------------------------------------------------------------------------------------------
-- Bug 8644512
---------------------------------------------------------------------------------------------------

function get_cont_lookup_code (p_lookup_code  in varchar2, p_target_year in number) return varchar2
IS
lookup_code varchar2(1);

BEGIN

lookup_code := null;

if p_target_year <= 2008
then
if (p_lookup_code = '7') then
 lookup_code := '6' ;
else
lookup_code := p_lookup_code;
end if;

elsif p_target_year > 2008
then
if (p_lookup_code = '7') then
lookup_code := '5';
elsif (p_lookup_code = '5') then
lookup_code := '6';
elsif (p_lookup_code = '6') then
lookup_code := '7';
else
lookup_code := p_lookup_code;
end if;

end if ;

return lookup_code;

END;
------------------------------------------------------------------------------------------------
-- Bug 9079450: Function to return the lookup meaning for the dependent education expense region
------------------------------------------------------------------------------------------------
function decode_lookup(
			p_effective_date	in	varchar2,
			p_code			in	varchar2) return varchar2 is
--
l_meaning	varchar2(80) := null;
l_year		number := null;
--
begin
--
l_year := to_number(to_char(fnd_date.canonical_to_date(p_effective_date),'YYYY'));
if l_year < 2009 then
   l_meaning := hr_general.decode_lookup('CONTACT',p_code);
else
   l_meaning := hr_general.decode_lookup('KR_CONTACT_RELATIONSHIPS',p_code);
end if;
--
return l_meaning;
end;
------------------------------------------------------------------------------------------------
end pay_kr_ff_functions_pkg;

/
