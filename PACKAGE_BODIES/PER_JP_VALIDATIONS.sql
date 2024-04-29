--------------------------------------------------------
--  DDL for Package Body PER_JP_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_VALIDATIONS" AS
/* $Header: pejpvald.pkb 120.1 2005/07/05 03:46:44 shisriva noship $ */
	FUNCTION CHECK_FORMAT(
			p_value		IN VARCHAR2,
			p_format	IN VARCHAR2) RETURN VARCHAR2
	IS
		l_valid		BOOLEAN := TRUE;
		l_char		VARCHAR2(2);
		l_char_seq	NUMBER;
		l_mask		VARCHAR2(2);
		l_mask_seq	NUMBER;
		l_next_mask	BOOLEAN := FALSE;

		l_alphabet	VARCHAR2(26) := 'abcdefghijklmnopqrstuvwxyz';
		l_numeric	VARCHAR2(10) := '0123456789';
		l_dummy		VARCHAR2(1)  := '-';
	BEGIN
		l_char_seq := length(p_value);
		l_mask_seq := nvl(length(p_format),0);

		while l_mask_seq > 0 loop
			l_mask := substr(p_format,l_mask_seq,1);
			l_char := substr(p_value,l_char_seq,1);

			-- Incase the character is ommitable.
			if l_mask in ('9','P','p','C','c') then
				if l_mask='9' then
					if translate(l_char,l_dummy || l_numeric,l_dummy) is not NULL then
						l_next_mask := TRUE;
					end if;
				elsif l_mask='P' then
					if translate(l_char,l_dummy || upper(l_alphabet),l_dummy) is not NULL then
						l_next_mask := TRUE;
					end if;
				elsif l_mask='p' then
					if translate(l_char,l_dummy || l_alphabet,l_dummy) is not NULL then
						l_next_mask := TRUE;
					end if;
				elsif l_mask='C' then
					if translate(l_char,l_dummy || upper(l_alphabet) || l_numeric,l_dummy) is not NULL then
						l_next_mask := TRUE;
					end if;
				elsif l_mask='c' then
					if translate(l_char,l_dummy || l_alphabet || l_numeric,l_dummy) is not NULL then
						l_next_mask := TRUE;
					end if;
				end if;
			-- Incase the character is in-ommitable.
			else
				if l_char is NULL then
					l_valid := FALSE;
					exit;
				end if;

				if l_mask='0' then
					if translate(l_char,l_dummy || l_numeric,l_dummy) is not NULL then
						l_valid := FALSE;
						exit;
					end if;
				elsif l_mask='A' then
					if translate(l_char,l_dummy || upper(l_alphabet),l_dummy) is not NULL then
						l_valid := FALSE;
						exit;
					end if;
				elsif l_mask='a' then
					if translate(l_char,l_dummy || l_alphabet,l_dummy) is not NULL then
						l_valid := FALSE;
						exit;
					end if;
				elsif l_mask='L' then
					if translate(l_char,l_dummy || upper(l_alphabet) || l_numeric,l_dummy) is not NULL then
						l_valid := FALSE;
						exit;
					end if;
				elsif l_mask='l' then
					if translate(l_char,l_dummy || l_alphabet || l_numeric,l_dummy) is not NULL then
						l_valid := FALSE;
						exit;
					end if;
				else
					if l_char <> l_mask then
						l_valid := FALSE;
						exit;
					end if;
				end if;
			end if;

			l_mask_seq := l_mask_seq - 1;
			if not l_next_mask then
				if l_char_seq > 1 then
					l_char_seq := l_char_seq - 1;
				else
					l_char_seq := NULL;
				end if;
			else
				l_next_mask := FALSE;
			end if;
		end loop;

		if l_valid then
			if l_char_seq > 0 then
				return 'FALSE';
			else
				return 'TRUE';
			end if;
		else
			return 'FALSE';
		end if;
	END CHECK_FORMAT;
--
	FUNCTION CHECK_DATE_FORMAT(
			p_value		IN VARCHAR2,
			p_format	IN VARCHAR2) RETURN VARCHAR2
	IS
		INVALID_FORMAT	EXCEPTION;
		l_message	VARCHAR2(255);
		l_dummy		DATE;
	BEGIN
		if lengthb(p_value) <> lengthb(p_format) then
			raise INVALID_FORMAT;
		else
			l_dummy := to_date(p_value,p_format);
		end if;

		l_message := 'TRUE';
		return l_message;
	EXCEPTION
		WHEN INVALID_FORMAT THEN
			fnd_message.set_name('PER','HR_JP_INVALID_FORMAT');
			--Bug Fix:3153731, changed the token values of 'VALUE' and 'FORMAT'
			fnd_message.set_token('VALUE',substr(p_value,1,lengthb(p_value)-2));
			fnd_message.set_token('FORMAT',substr(p_format,1,6));
			--
			l_message := fnd_message.get;
			return l_message;
		WHEN OTHERS THEN
			l_message := SQLERRM;
			return l_message;
	END CHECK_DATE_FORMAT;
--
	FUNCTION DISTRICT_CODE_CHECK_DIGIT(
			p_district_code IN VARCHAR2) RETURN NUMBER
	IS
		l_first		NUMBER;
		l_second	NUMBER;
		l_third		NUMBER;
		l_fourth	NUMBER;
		l_fifth		NUMBER;
		l_remainder	NUMBER;
		l_check_digit	NUMBER;
	BEGIN
		l_first		:= to_number(substrb(p_district_code,1,1));
		l_second	:= to_number(substrb(p_district_code,2,1));
		l_third		:= to_number(substrb(p_district_code,3,1));
		l_fourth	:= to_number(substrb(p_district_code,4,1));
		l_fifth		:= to_number(substrb(p_district_code,5,1));

		l_remainder := mod(l_first*6 + l_second*5 + l_third*4 + l_fourth*3 + l_fifth*2,11);

		if l_remainder = 0 then
			l_check_digit := 1;
		elsif l_remainder = 1 then
			l_check_digit := 0;
		else
			l_check_digit := 11 - l_remainder;
		end if;

		return l_check_digit;
	END DISTRICT_CODE_CHECK_DIGIT;
--
	FUNCTION DISTRICT_CODE_EXISTS(
			p_district_code	IN VARCHAR2,
			p_check_digit	IN VARCHAR2 DEFAULT 'TRUE') RETURN VARCHAR2
	IS
		INVALID_FORMAT		EXCEPTION;
		INVALID_DISTRICT_CODE	EXCEPTION;
		INVALID_CHECK_DIGIT	EXCEPTION;

		l_format	VARCHAR2(6);
		l_lengthb	NUMBER;
		l_district_code	VARCHAR2(5);
		l_check_digit	NUMBER;
		l_sixth		NUMBER;
		l_message	VARCHAR2(255);

		PROCEDURE CHECK_DISTRICT_CODE(
				p_district_code IN VARCHAR2)
		IS
			l_dummy		VARCHAR2(1);
			CURSOR cur_district_code(p_district_code IN VARCHAR2) IS
				select	'X'
				from	per_jp_address_lookups
				where	district_code = p_district_code;
		BEGIN
			open cur_district_code(p_district_code);
			fetch cur_district_code into l_dummy;
			if cur_district_code%NOTFOUND then
				close cur_district_code;
				raise INVALID_DISTRICT_CODE;
			end if;
			close cur_district_code;
		END CHECK_DISTRICT_CODE;
	BEGIN
		if p_check_digit = 'TRUE' then
			l_format := '000000';
			if check_format(p_district_code,l_format)='FALSE' then
				raise INVALID_FORMAT;
			end if;

			l_district_code	:= substrb(p_district_code,1,5);
			check_district_code(l_district_code);

			l_check_digit	:= district_code_check_digit(l_district_code);
			l_sixth		:= to_number(substrb(p_district_code,6,1));
			if l_sixth = l_check_digit then
				NULL;
			else
				raise INVALID_CHECK_DIGIT;
			end if;
		else
			l_format := '00000';
			if check_format(p_district_code,l_format)='FALSE' then
				raise INVALID_FORMAT;
			end if;

			l_district_code := p_district_code;
			check_district_code(l_district_code);
		end if;

		l_message := 'TRUE';
		return l_message;
	EXCEPTION
		WHEN INVALID_FORMAT THEN
			fnd_message.set_name('PER','HR_JP_INVALID_FORMAT');
			fnd_message.set_token('VALUE',p_district_code);
			fnd_message.set_token('FORMAT',l_format);
			l_message := fnd_message.get;
			return l_message;
		WHEN INVALID_DISTRICT_CODE THEN
			fnd_message.set_name('PER','HR_JP_DISTRICT_NOT_REGISTERED');
			fnd_message.set_token('VALUE',p_district_code);
			l_message := fnd_message.get;
			return l_message;
		WHEN INVALID_CHECK_DIGIT THEN
			fnd_message.set_name('PER','HR_JP_INVALID_CHECK_DIGIT');
			l_message := fnd_message.get;
			return l_message;
		WHEN OTHERS THEN
			l_message := SQLERRM;
			return l_message;
	END DISTRICT_CODE_EXISTS;
--
	FUNCTION ORG_EXISTS(
			p_business_group_id	IN NUMBER,
			p_effective_date	IN DATE,
			p_organization_id	IN NUMBER,
			p_org_class		IN VARCHAR2) RETURN VARCHAR2
	IS
			l_found		BOOLEAN := FALSE;
			l_dummy		VARCHAR2(1);
        		CURSOR cur_org_exists IS
			select	'X'
			from	hr_organization_information	hoi,
				hr_all_organization_units	hou
			where	hou.business_group_id=p_business_group_id
			and	hou.organization_id=p_organization_id
			-- and	to_date(p_effective_date,'DD-MON-YYYY')
			--between hou.date_from and nvl(hou.date_to,to_date(p_effective_date,'DD-MON-YYYY'))
			and	p_effective_date
				between hou.date_from and nvl(hou.date_to,p_effective_date)
			and	hoi.organization_id=hou.organization_id
			and	hoi.org_information_context='CLASS'
			and	hoi.org_information1=p_org_class
			and	hoi.org_information2='Y';
	BEGIN
		open cur_org_exists;
		fetch cur_org_exists into l_dummy;
		if cur_org_exists%FOUND then
			l_found	:= TRUE;
		else
			l_found	:= FALSE;
		end if;
		close cur_org_exists;

		if l_found then
			return 'TRUE';
		else
			return 'FALSE';
		end if;
	END ORG_EXISTS;
--
	FUNCTION CHECK_HALF_KANA(
			p_value		IN VARCHAR2) RETURN VARCHAR2
	IS
			l_output	VARCHAR2(80);
			l_rgeflg	VARCHAR2(80);
		     	l_correct 	VARCHAR2(10) := 'TRUE';
			l_value		VARCHAR2(80);
	BEGIN
		l_value := p_value;
		hr_spec_pkg.checkformat(l_value,'K',l_output,null,null,'Y',l_rgeflg,null);
		return l_correct;

	EXCEPTION
		WHEN OTHERS THEN
			l_correct := 'FALSE';
			return l_correct;
	END CHECK_HALF_KANA;
--
	FUNCTION VEHICLE_EXISTS(
			p_business_group_id	IN NUMBER,
			p_assignment_id		IN NUMBER,
			p_effective_date	IN DATE,
			p_vehicle_allocation_id	IN NUMBER)	RETURN VARCHAR2
	IS
			l_found		BOOLEAN := FALSE;
			l_dummy		VARCHAR2(1);
        		CURSOR cur_vehicle_exists IS
			select	'X'
			from	pqp_vehicle_allocations_f pva,
				pqp_vehicle_repository_f  pvr
			where	pva.business_group_id=p_business_group_id
			and	pva.assignment_id=p_assignment_id
			and	pva.vehicle_allocation_id=p_vehicle_allocation_id
			and	p_effective_date
				between pva.effective_start_date and nvl(pva.effective_end_date,p_effective_date)
			and	pvr.vehicle_repository_id = pva.vehicle_repository_id
			and	p_effective_date
				between pvr.effective_start_date and nvl(pvr.effective_end_date,p_effective_date);
	BEGIN
		open cur_vehicle_exists;
		fetch cur_vehicle_exists into l_dummy;
		if cur_vehicle_exists%FOUND then
			l_found	:= TRUE;
		else
			l_found	:= FALSE;
		end if;
		close cur_vehicle_exists;

		if l_found then
			return 'TRUE';
		else
			return 'FALSE';
		end if;
	END VEHICLE_EXISTS;
--
END per_jp_validations;

/
