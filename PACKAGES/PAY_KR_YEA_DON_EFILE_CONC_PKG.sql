--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_DON_EFILE_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_DON_EFILE_CONC_PKG" AUTHID CURRENT_USER as
/*$Header: pykrydcon.pkh 120.1 2006/10/20 08:34:12 vaisriva noship $ */
--
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
	p_home_tax_id		in varchar2,
	p_ORG_STRUC_VERSION_ID	in varchar2		--5069923
) ;

procedure get_bg_id(
	p_business_place 	in varchar2,
	p_business_group_id	out nocopy number
) ;

--
end pay_kr_yea_don_efile_conc_pkg ;

/
