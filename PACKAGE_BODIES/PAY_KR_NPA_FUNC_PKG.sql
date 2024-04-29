--------------------------------------------------------
--  DDL for Package Body PAY_KR_NPA_FUNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_NPA_FUNC_PKG" as
/* $Header: pykrnpaf.pkb 120.0 2005/05/29 06:26:24 appldev noship $ */
--
-- get_bp_list: Get a comma separated list of business places
--              that report to the same National Pension office
--              in a business group
function get_bp_list(
	p_business_group_id	in		hr_organization_units.organization_id%type,
	p_bp_np_number		in		hr_organization_information.org_information1%type
) return varchar2
is
	cursor csr_bp_names is
		select distinct
			hou.name bp_name
		from
			hr_organization_units hou,
			hr_organization_information npi
		where
			hou.business_group_id		= p_business_group_id
			and npi.organization_id 	= hou.organization_id
			and npi.org_information_context = 'KR_NP_INFORMATION'
			and npi.org_information1	= p_bp_np_number
		order by
			1 ;
	r_bp_list	varchar2(260) ;
	l_trunc_len	number ;
	rec		csr_bp_names%rowtype ;
begin
	l_trunc_len := 256 ;
	r_bp_list := '' ;
	--
	open csr_bp_names ;
	loop
		fetch csr_bp_names into rec ;
		exit when csr_bp_names%notfound ;
		if length(r_bp_list) = l_trunc_len then
			exit ;
		end if ;
		r_bp_list := substr(r_bp_list || rec.bp_name, 	0, l_trunc_len) ;
		r_bp_list := substr(r_bp_list || ', ', 		0, l_trunc_len) ;
	end loop ;
	close csr_bp_names ;
	--
	r_bp_list := rtrim(r_bp_list, ', ') ;
	--
	return r_bp_list ;
	--
end get_bp_list ;
--
end pay_kr_npa_func_pkg ;

/
