--------------------------------------------------------
--  DDL for Package Body PAY_KR_HIA_FUNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_HIA_FUNC_PKG" as
/* $Header: pykrhiafn.pkb 120.0 2005/05/29 10:45:55 appldev noship $ */

    /*************************************************************************
     * This function is used to get the comma-separated concatenation of
     * all business places under a HI Business Place
     *************************************************************************/

    function get_concat_bp_names (
        p_payroll_action_id      in number,
        p_hi_bp_number           in varchar2,
        p_trunc_length           in number
        ) return varchar2
    is
	cursor bp_names is
	select  hou1.name
	from 	hr_organization_units       hou1,
		hr_organization_information hoi2,
		pay_payroll_actions         ppa
	where   ppa.payroll_action_id        = p_payroll_action_id
	and     hou1.business_group_id       = ppa.business_group_id
	and     hou1.organization_id         = hoi2.organization_id
	and     hoi2.org_information_context = 'KR_HI_INFORMATION'
	and     hoi2.org_information1        = p_hi_bp_number;


        l_concat varchar2(1000);
        l_length number;

    begin

        if(p_trunc_length > 1000) then
            l_length := 1000;
        else
            l_length := p_trunc_length;
        end if;

	for rec in bp_names
	loop
	    l_concat  := substr(l_concat ||rec.name,0 ,l_length);
	    l_concat  := substr(l_concat || ', ',0 ,l_length);
	end loop;

	l_concat  := rtrim(l_concat, ', ');
	return l_concat;

    end get_concat_bp_names;

begin
    null;
end pay_kr_hia_func_pkg;

/
