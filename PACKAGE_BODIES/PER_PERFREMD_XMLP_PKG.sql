--------------------------------------------------------
--  DDL for Package Body PER_PERFREMD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERFREMD_XMLP_PKG" AS
/* $Header: PERFREMDB.pls 120.0 2007/12/24 13:18:44 amakrish noship $ */

function BeforeReport return boolean is
begin
   --hr_standard.event('BEFORE REPORT');
   cp_business_group_name :=
      hr_reports.get_business_group(p_business_group_id);
   return (TRUE);

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

 Function CP_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return CP_BUSINESS_GROUP_NAME;
	 END;
END PER_PERFREMD_XMLP_PKG ;

/
