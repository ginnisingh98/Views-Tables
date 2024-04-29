--------------------------------------------------------
--  DDL for Package Body PER_PERRPGEN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPGEN_XMLP_PKG" AS
/* $Header: PERGENRPB.pls 120.1 2007/12/06 11:26:14 amakrish noship $ */

function BeforeReport return boolean is
begin

begin


--hr_standard.event('BEFORE REPORT');

 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

end;


declare
cursor c1 is
select line_content from per_generic_report_output
where line_type = 'H';

cursor c2 is
select line_content from per_generic_report_output
where line_type = 'F';

cursor c3 is
select line_content from per_generic_report_output
where line_type = 'T';

begin
per_generic_report_pkg.generate_report
                      ( P_Report_Name,
		        P_PARAM_1,
			P_PARAM_2,
			P_PARAM_3,
			P_PARAM_4,
			P_PARAM_5,
			P_PARAM_6,
			P_PARAM_7,
			P_PARAM_8,
			P_PARAM_9,
			P_PARAM_10,
			P_PARAM_11,
			P_PARAM_12);
commit;
open c1;
fetch c1 into P_Header;
if c1%notfound then

P_Header := '';
end if;
close c1;
open c2;
fetch c2 into P_footer;
if c2%notfound then
P_Footer := '';
end if;
close c2;
open c3;
fetch c3 into P_Title;
if c3%notfound then
P_Title := '';
end if;
close c3;
end;  return (TRUE);
end;

function BeforePForm return boolean is
begin



  return (TRUE);
end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
END PER_PERRPGEN_XMLP_PKG ;

/
