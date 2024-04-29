--------------------------------------------------------
--  DDL for Package Body PAY_CA_EMP_ADDRESS_DTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_EMP_ADDRESS_DTLS" as
/* $Header: paycaaddwrpr.pkb 120.1 2005/10/05 00:36 saurgupt noship $ */
function get_emp_address (p_person_id in number,
                          p_address1  out nocopy  varchar2,
                          p_address2  out nocopy varchar2,
                          p_address3  out nocopy varchar2,
                          p_city     out nocopy varchar2,
                          p_postal_code out nocopy varchar2,
                          p_country out nocopy  varchar2,
                          p_province out nocopy varchar2 ) return Number is

/* Local Variables  */
addr pay_ca_rl1_reg.primaryaddress ;

begin

         addr := pay_ca_rl1_reg.get_primary_address(p_person_id,sysdate);

	 p_address1    := nvl(addr.addr_line_1,' ');
	 p_address2    := nvl(rtrim(ltrim(addr.addr_line_2)),' ');
	 p_address3    := nvl(rtrim(ltrim(addr.addr_line_3)),' ');
	 p_city        := nvl(addr.city,' ');
	 p_postal_code := nvl(addr.postal_code,' ');
	 p_country     := nvl(addr.addr_line_5,' ');
	 p_province    := nvl(addr.province,' ');

return 0;

end;

end;

/
