--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_DON_EFILE_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_DON_EFILE_CONC_PKG" as
/*$Header: pykrydcon.pkb 120.1 2006/10/20 08:29:44 vaisriva noship $ */

/*************************************************************************
 * Procedure to submit e-file request indirectly
 *************************************************************************/

procedure submit_efile(
	errbuf			out nocopy  varchar2,
	retcode			out nocopy  varchar2,
	p_business_place	in varchar2,
	p_REPORT_FOR		in varchar2,		--5069923
	p_magnetic_file_name	in varchar2,
	p_report_file_name	in varchar2,
	p_payroll_action	in varchar2,
	p_assignment_set	in varchar2,
	p_report_type		in varchar2,
	p_reported_date		in varchar2,
	p_target_year		in varchar2,
	p_characterset		in varchar2,
	p_home_tax_id   	in varchar2,
	p_ORG_STRUC_VERSION_ID	in varchar2		--5069923
)

is

	l_req_id		number;
	l_message		varchar2(2000);
	l_phase			varchar2(100);
	l_status		varchar2(100);
	l_action_completed	boolean;
	l_bg_id			number;

begin
	get_bg_id(p_business_place, l_bg_id) ;
	l_req_id := fnd_request.submit_request (
		APPLICATION           =>   'PAY',
                PROGRAM              =>   'PYKRYEAM_DON_I',
		DESCRIPTION          =>   'KR Year End Adjustment Donation eFile (Internal)',
		ARGUMENT1            =>   'pay_magtape_generic.new_formula',
		ARGUMENT2            =>    p_magnetic_file_name,
		ARGUMENT3            =>    p_report_file_name,
		ARGUMENT4            =>    null,
		ARGUMENT5            =>   'MAGTAPE_REPORT_ID=KR_YEA_DON_EFILE',
		ARGUMENT6            =>   'PRIMARY_BP_ID='     || p_business_place,
		ARGUMENT7            =>   'REPORTED_DATE='     || p_reported_date,
		ARGUMENT8            =>   'PAYROLL_ACTION_ID=' || p_payroll_action,
		ARGUMENT9            =>   'ASSIGNMENT_SET_ID=' || p_assignment_set,
		ARGUMENT10           =>   'REPORT_TYPE='       || p_report_type,
		ARGUMENT11           =>   'REPORT_DATE='       || p_reported_date,
		ARGUMENT12           =>   'TARGET_YEAR='       || p_target_year,
		ARGUMENT13           =>   'CHARACTER_SET='     || p_characterset,
		ARGUMENT14           =>   'HOME_TAX_ID='       || p_home_tax_id,
		ARGUMENT15           =>   'BG_ID='             || (l_bg_id),
		ARGUMENT16           =>   'REPORT_FOR='	       || p_REPORT_FOR,
		ARGUMENT17	     =>   'ORG_STRUC_VERSION_ID='	|| p_ORG_STRUC_VERSION_ID
	) ;

	if (l_req_id = 0) then
		retcode := 2;
		fnd_message.retrieve(errbuf);
	else
		commit;
	end if;

end submit_efile;
--------------------------------------------------------------------------------------------------
procedure get_bg_id(
	p_business_place 	in  varchar2,
	p_business_group_id	out nocopy number
)
is

	cursor csr_business_group_id is
		select  hou.business_group_id
		from    hr_organization_units hou
		where  	hou.organization_id = p_business_place ;
begin
	open csr_business_group_id ;
	fetch csr_business_group_id into p_business_group_id ;
	close csr_business_group_id ;
end get_bg_id;
--------------------------------------------------------------------------------------------------
end pay_kr_yea_don_efile_conc_pkg ;

/
