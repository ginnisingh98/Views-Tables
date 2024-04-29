--------------------------------------------------------
--  DDL for Package Body HR_JP_GENERAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JP_GENERAL_PKG" AS
/* $Header: hrjpgen.pkb 115.8 2003/12/09 21:59:33 ttagawa ship $ */
--------------------------------------------------------------
	FUNCTION GET_SESSION_DATE
--------------------------------------------------------------
	RETURN DATE
	IS
		l_effective_date	DATE;
		CURSOR cur_effective_date IS
			select	effective_date
			from	fnd_sessions
			where	session_id=userenv('sessionid');
	BEGIN
		open cur_effective_date;
		fetch cur_effective_date into l_effective_date;
		if cur_effective_date%NOTFOUND then
			l_effective_date:=NULL;
		end if;
		close cur_effective_date;

		return l_effective_date;
	END GET_SESSION_DATE;

--------------------------------------------------------------
	FUNCTION DECODE_ORG(
--------------------------------------------------------------
		P_ORGANIZATION_ID	IN NUMBER)
	RETURN VARCHAR2
	IS
		l_name	HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
		CURSOR cur_org_name IS
			select	tl.name
			from	hr_all_organization_units_tl	tl,
				hr_all_organization_units	hou
			where	hou.organization_id=p_organization_id
			and	tl.organization_id=hou.organization_id
			and	tl.language=userenv('LANG');
	BEGIN
		open cur_org_name;
		fetch cur_org_name into l_name;
		if cur_org_name%notfound then
			l_name:=NULL;
		end if;
		close cur_org_name;

		return l_name;
	END DECODE_ORG;

--------------------------------------------------------------
	FUNCTION DECODE_DISTRICT(
--------------------------------------------------------------
		P_DISTRICT_CODE		IN VARCHAR2)
	RETURN VARCHAR2
	IS
		l_district_name	PER_JP_ADDRESS_LOOKUPS.ADDRESS_LINE_1%TYPE;
		CURSOR cur_district_name IS
			select	address_line_1
			from	per_jp_address_lookups
			where	district_code=p_district_code;
	BEGIN
		open cur_district_name;
		fetch cur_district_name into l_district_name;
		if cur_district_name%NOTFOUND then
			l_district_name:=NULL;
		end if;
		close cur_district_name;

		return l_district_name;
	END DECODE_DISTRICT;

--------------------------------------------------------------
	FUNCTION GET_ADDRESS(
--------------------------------------------------------------
		P_PERSON_ID		IN NUMBER,
		P_ADDRESS_TYPE		IN VARCHAR2,
		P_EFFECTIVE_DATE	IN DATE)
	RETURN VARCHAR2
	IS
		l_address	VARCHAR2(180);
		CURSOR cur_address IS
			select	pad.address_line1 || pad.address_line2 || pad.address_line3
			from	per_addresses	pad
			where	pad.person_id=p_person_id
			and	pad.address_type=p_address_type
			and	p_effective_date
				between pad.date_from and nvl(pad.date_to,p_effective_date);
	BEGIN
		l_address := NULL;

		open cur_address;
		fetch cur_address into l_address;
		if cur_address%NOTFOUND then
			l_address := NULL;
		end if;
		close cur_address;

		return l_address;
	END GET_ADDRESS;

--------------------------------------------------------------
	FUNCTION GET_DISTRICT_CODE(
--------------------------------------------------------------
		P_PERSON_ID		IN NUMBER,
		P_ADDRESS_TYPE		IN VARCHAR2,
		P_EFFECTIVE_DATE	IN DATE)
	RETURN VARCHAR2
	IS
		l_district_code	VARCHAR2(30);
		CURSOR cur_district_code IS
			select	pad.town_or_city
			from	per_addresses	pad
			where	pad.person_id=p_person_id
			and	pad.address_type=p_address_type
			and	p_effective_date
				between pad.date_from and nvl(pad.date_to,p_effective_date);
	BEGIN
		l_district_code := NULL;

		open cur_district_code;
		fetch cur_district_code into l_district_code;
		if cur_district_code%NOTFOUND then
			l_district_code := NULL;
		end if;
		close cur_district_code;

		return l_district_code;
	END GET_DISTRICT_CODE;

--------------------------------------------------------------
	FUNCTION RUN_ASSACT_EXISTS(
	-- This function elapses cpu-time about 0.012 sec per 1 call.
--------------------------------------------------------------
			p_assignment_id		IN NUMBER,
			p_element_set_name	IN VARCHAR2,
			p_validation_start_date	IN DATE DEFAULT NULL,
			p_validation_end_date	IN DATE DEFAULT NULL,
			p_effective_date	IN DATE DEFAULT NULL) RETURN VARCHAR2
	IS
		l_effective_date	DATE;
		l_found			VARCHAR2(5) := 'FALSE';

		CURSOR cur_effective_date IS
			select	effective_date
			from	fnd_sessions
			where	session_id=userenv('sessionid');
		-- It doesn't matter whether action_status is 'C' or other values.
		CURSOR cur_run_assact IS
			select	/*+ ORDERED USE_NL(PPA PES PTP) */
				'TRUE'
			from	pay_assignment_actions	paa,
				pay_payroll_actions	ppa,
				pay_element_sets	pes,
				per_time_periods	ptp
			where	paa.assignment_id=p_assignment_id
			and	ppa.payroll_action_id=paa.payroll_action_id
			-- Element set will be supported in near future.
			and	ppa.action_type in ('R','Q')
			and	pes.element_set_id=ppa.element_set_id
			and	pes.element_set_name=p_element_set_name
			and	ptp.time_period_id=ppa.time_period_id
			and	l_effective_date
				between nvl(p_validation_start_date,ptp.start_date) and nvl(p_validation_end_date,ptp.end_date);
	BEGIN
		if p_effective_date is NULL then
			open cur_effective_date;
			fetch cur_effective_date into l_effective_date;
			close cur_effective_date;
		else
			l_effective_date := p_effective_date;
		end if;

		open cur_run_assact;
		fetch cur_run_assact into l_found;
		if cur_run_assact%NOTFOUND then
			l_found := 'FALSE';
		end if;
		close cur_run_assact;

		return l_found;
	END run_assact_exists;

--------------------------------------------------------------
        FUNCTION GET_ORG_SHORT_NAME(
--------------------------------------------------------------
                 p_organization_id in number
                ,p_column_name     in varchar2 default 'NAME1')
                 return varchar2
        IS
        cursor cur_org_short_name is
          select /*+ NO_INDEX(HOI1 HR_ORGANIZATION_INFORMATIO_IX1)
                     NO_INDEX(HOI2 HR_ORGANIZATION_INFORMATIO_FK1) */
             hoi2.org_information1
            ,hoi2.org_information2
            ,hoi2.org_information3
            ,hoi2.org_information4
            ,hoi2.org_information5
          from
             hr_organization_information hoi1
            ,hr_organization_information hoi2
          where
              hoi1.organization_id = p_organization_id
          and hoi1.org_information_context = 'CLASS'
          and hoi1.org_information1 = 'JP_EXTRA_NAME'
          and hoi1.org_information2 = 'Y'
          and hoi2.org_information_context = 'JP_ORG_SHORT_NAME'
          and hoi2.organization_id = hoi1.organization_id
          ;

        l_rec_org_short_name cur_org_short_name%rowtype;
        l_return_value varchar2(150);
        begin
        --
        -- Open and fetch cursor for organization information
        --
        open cur_org_short_name;
        fetch cur_org_short_name into l_rec_org_short_name;

        --
        -- Check the return column name
        --
        if p_column_name = 'NAME1' then
          l_return_value := l_rec_org_short_name.org_information1;
        elsif p_column_name = 'NAME2' then
          l_return_value := l_rec_org_short_name.org_information2;
        elsif p_column_name = 'NAME3' then
          l_return_value := l_rec_org_short_name.org_information3;
        elsif p_column_name = 'NAME4' then
          l_return_value := l_rec_org_short_name.org_information4;
        elsif p_column_name = 'NAME5' then
          l_return_value := l_rec_org_short_name.org_information5;
        end if;

        --
        -- Return value
        --
        return l_return_value;

        end get_org_short_name;
--
-- The following function is to avoid bug.2668811
--
--------------------------------------------------------------
function date_to_jp_char(
--------------------------------------------------------------
	p_date			in date,
	p_format		in varchar2) return varchar2
is
	l_char	varchar2(255);
begin
	--
	-- The following code is to avoid the PL/SQL to_char call.
	-- Never call PL/SQL to_char with nlsparam specified
	-- which will raise ORA-06502(Bug.2668811).
	--
	select	to_char(p_date, p_format, 'NLS_CALENDAR=''Japanese Imperial''')
	into	l_char
	from	dual;
	--
	return l_char;
end date_to_jp_char;
--
--------------------------------------------------------------
	FUNCTION DECODE_VEHICLE(
--------------------------------------------------------------
		P_VEHICLE_ALLOCATION_ID		IN NUMBER,
		P_EFFECTIVE_DATE		IN DATE)
	RETURN VARCHAR2
	IS
		l_name	PQP_VEHICLE_REPOSITORY_F.REGISTRATION_NUMBER%TYPE;
		CURSOR cur_vehicle_name IS
			select	pvr.registration_number
			from	pqp_vehicle_allocations_f pva,
				pqp_vehicle_repository_f  pvr
			where	pva.vehicle_allocation_id=p_vehicle_allocation_id
			and	p_effective_date
				between pva.effective_start_date and nvl(pva.effective_end_date,p_effective_date)
			and	pvr.vehicle_repository_id = pva.vehicle_repository_id
			and	p_effective_date
				between pvr.effective_start_date and nvl(pvr.effective_end_date,p_effective_date);
	BEGIN
		open cur_vehicle_name;
		fetch cur_vehicle_name into l_name;
		if cur_vehicle_name%notfound then
			l_name:=NULL;
		end if;
		close cur_vehicle_name;

		return l_name;
	END DECODE_VEHICLE;
--
END HR_JP_GENERAL_PKG;

/
