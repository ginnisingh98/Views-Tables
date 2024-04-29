--------------------------------------------------------
--  DDL for Package Body HXT_HXT958A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT958A_XMLP_PKG" AS
/* $Header: HXT958AB.pls 120.1 2008/03/27 08:13:25 vjaganat noship $ */

function BeforeReport return boolean is
c_date_format varchar2(25) := 'DD-MON-YYYY';
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;



  if start_date is null then
     start_date := hr_general.start_of_time;
  end if;
  if end_date is null then
     end_date := hr_general.end_of_time;
  end if;

  P_START_DATE :=to_char(start_date,'DD MON YYYY');
  P_END_DATE :=to_char(end_date,'DD MON YYYY');
  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;


  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT958A_XMLP_PKG ;

/
