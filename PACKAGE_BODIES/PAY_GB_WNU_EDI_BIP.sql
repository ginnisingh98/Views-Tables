--------------------------------------------------------
--  DDL for Package Body PAY_GB_WNU_EDI_BIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_WNU_EDI_BIP" as
/* $Header: PYGBWNU.pkb 120.0.12010000.2 2010/01/12 07:18:26 dwkrishn noship $ */


function beforereport return boolean is

l_wrap_point number;
l_employers_address_line varchar2(500);

cursor empl_address_line is
select 	nvl(upper(hoi.org_information4),' ') employers_address_line
from   pay_payroll_actions pact,
	   hr_organization_information hoi
where  pact.payroll_action_id = p_payroll_action_id
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters,instr(pact.legislative_parameters,'TAX_REF=') + 8,
	   instr(pact.legislative_parameters||' ',' ', instr(pact.legislative_parameters,'TAX_REF=')+8) -
	   instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;

begin


	open empl_address_line;
	fetch empl_address_line into l_employers_address_line;
	close empl_address_line;



	g_address1 := l_employers_address_line;

	if length(g_address1) > 35 then
	  l_wrap_point := instr(g_address1, ',', 34-length(g_address1));

		if l_wrap_point = 0 then
		  l_wrap_point := 35;
		  g_address2 := ltrim(substr(g_address1,1+l_wrap_point),' ,');
		  g_address1 := substr(g_address1,1,l_wrap_point);
		end if;
	end if;



	if length(g_address2) > 35 then
	  l_wrap_point := instr(g_address2, ',', 34-length(g_address2));
		if l_wrap_point = 0 then
		  l_wrap_point := 35;
		  g_address3 := ltrim(substr(g_address2,1+l_wrap_point),' ,');
		  g_address2 := substr(g_address2,1,l_wrap_point);
		end if;
	end if;



	if length(g_address3) > 35 then
	  l_wrap_point := instr(g_address3, ',', 34-length(g_address3));
		if l_wrap_point = 0 then
		  l_wrap_point := 35;
		  g_address4 := ltrim(substr(g_address3,1+l_wrap_point),' ,');
		  g_address3 := substr(g_address3,1,l_wrap_point);
		end if;
	end if;



     return true;
end beforereport;

function cp_address_1 return varchar2 is
begin
  return g_address1;
end;

function cp_address_2 return varchar2 is
begin
  return g_address2;
end;


function cp_address_3 return varchar2 is
begin
  return g_address3;
end;


function cp_address_4 return varchar2 is
begin
  return g_address4;
end;

function cp_address_5 return varchar2 is
begin
  return g_address5;
end;


END pay_gb_wnu_edi_bip;

/
