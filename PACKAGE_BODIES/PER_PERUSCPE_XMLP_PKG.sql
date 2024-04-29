--------------------------------------------------------
--  DDL for Package Body PER_PERUSCPE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERUSCPE_XMLP_PKG" AS
/* $Header: PERUSCPEB.pls 120.0 2007/12/28 06:57:47 srikrish noship $ */

function BeforeReport return boolean is
begin

declare
        v_organization_name varchar2(60);
begin

--hr_standard.event('BEFORE REPORT');
LP_SESSION_DATE := to_char(P_SESSION_DATE, 'dd-mon-yyyy');

 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);
   v_organization_name := c_business_group_name;

 c_employee_name := hr_reports.get_person_name(
                      p_session_date => lp_session_date,
                      p_person_id    => TO_NUMBER(p_person_id ));

IF ( p_qual_date IS NOT NULL )
THEN
 c_qualifying_date := TO_CHAR(p_qual_date, 'DD-MON-YYYY');
ELSE
 c_qualifying_date := '';
END IF;

end;  return (TRUE);
end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_LETTER_DATE_p return date is
	Begin
	 return C_LETTER_DATE;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_EMPLOYEE_NAME_p return varchar2 is
	Begin
	 return C_EMPLOYEE_NAME;
	 END;
 Function C_QUALIFYING_DATE_p return varchar2 is
	Begin
	 return C_QUALIFYING_DATE;
	 END;
END PER_PERUSCPE_XMLP_PKG ;

/
