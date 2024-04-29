--------------------------------------------------------
--  DDL for Package Body PAY_GB_P46V6_EDI_BIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_P46V6_EDI_BIP" as
/* $Header: pygbp46v6.pkb 120.0.12010000.1 2010/01/22 13:34:43 namgoyal noship $ */

procedure set_address_lines(p_assignment_action_id IN NUMBER)
is

  Cursor emp_address_line
  IS
    Select nvl(upper(substr(addr.action_information5,1,35)),' '),
           nvl(upper(substr(addr.action_information6,1,35)),' '),
           nvl(upper(substr(addr.action_information7,1,35)),' '),
           nvl(upper(addr.action_information8),' ')
    From pay_action_information addr
    where  addr.action_context_id = p_assignment_action_id
    and    addr.action_information_category = 'ADDRESS DETAILS'
    and    addr.action_context_type = 'AAP';

begin

	open emp_address_line;
	fetch emp_address_line into g_address1, g_address2, g_address3, g_address4;
	close emp_address_line;

  if g_address3 = ' '
  then
      g_address3 := g_address4;
      g_address4 := ' ';
  end if;

  if g_address2 = ' '
  then
      g_address2 := g_address3;
      g_address3 := g_address4;
      g_address4 := ' ';
  end if;

  if LENGTH(TRIM(g_address4)) > 0
  then
      g_address4 := g_address4;
  else
      g_address4 := ' ';
  end if;

  if LENGTH(TRIM(g_address3)) > 0
  then
      g_address3 := g_address3;
  else
      g_address3 := g_address4;
      g_address4 := ' ';
  end if;

  if LENGTH(TRIM(g_address2)) > 0
  then
      g_address2 := g_address2;
  else
      g_address2 := g_address3;
      g_address3 := g_address4;
      g_address4 := ' ';
  end if;

end set_address_lines;

function cp_address(p_assignment_action_id IN NUMBER)
return varchar2 is

l_address VARCHAR2(1000):= ' ';

begin
    set_address_lines(p_assignment_action_id);
    l_address:= 'add1='||g_address1||' add2='||g_address2||' add3='||g_address3||' add4='||g_address4;
    return l_address;
end;

END pay_gb_p46v6_edi_bip;

/
