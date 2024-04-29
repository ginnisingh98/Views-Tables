--------------------------------------------------------
--  DDL for Package Body PER_PERUSCNE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERUSCNE_XMLP_PKG" AS
/* $Header: PERUSCNEB.pls 120.1 2008/03/12 13:46:03 vjaganat noship $ */

function BeforeReport return boolean is
begin

begin

-- hr_standard.event('BEFORE REPORT');
--LP_SESSION_DATE := to_char(P_SESSION_DATE, 'YYYY/MM/DD');
LP_SESSION_DATE := P_SESSION_DATE ;

c_person_name := hr_reports.get_person_name( p_session_date, p_person_id );

end;  return (TRUE);
end;

function AfterReport return boolean is
begin

-- hr_standard.event('AFTER REPORT');

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
 Function C_PERSON_NAME_p return varchar2 is
	Begin
	 return C_PERSON_NAME;
	 END;
END PER_PERUSCNE_XMLP_PKG ;

/
