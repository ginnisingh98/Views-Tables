--------------------------------------------------------
--  DDL for Package Body PER_PERUSCNL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERUSCNL_XMLP_PKG" AS
/* $Header: PERUSCNLB.pls 120.1 2008/03/12 10:39:16 amakrish noship $ */

function BeforeReport return boolean is
begin
LP_SESSION_DATE := to_char(P_SESSION_DATE, 'dd-mon-yyyy');
declare
        v_organization_name varchar2(60);
begin

-- hr_standard.event('BEFORE REPORT');

 c_business_group_name :=
   hr_reports.get_business_group(PER_BUSINESS_GROUP_ID);
   v_organization_name := c_business_group_name;

 c_employee_name := hr_reports.get_person_name(
                      p_session_date => lp_session_date,
                      p_person_id    => TO_NUMBER(p_person_id ));

IF ( p_qualifying_date IS NOT NULL )
THEN
 c_qualifying_date := TO_CHAR(p_qualifying_date, 'DD-MON-YYYY');
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
END PER_PERUSCNL_XMLP_PKG ;

/
