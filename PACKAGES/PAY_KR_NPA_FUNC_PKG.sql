--------------------------------------------------------
--  DDL for Package PAY_KR_NPA_FUNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_NPA_FUNC_PKG" AUTHID CURRENT_USER as
/* $Header: pykrnpaf.pkh 120.0 2005/05/29 06:26:32 appldev noship $ */
function get_bp_list(
	p_business_group_id	in		hr_organization_units.organization_id%type,
	p_bp_np_number		in		hr_organization_information.org_information1%type
) return varchar2 ;
end pay_kr_npa_func_pkg ;

 

/
