--------------------------------------------------------
--  DDL for Package Body HXT_HXT953A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT953A_XMLP_PKG" AS
/* $Header: HXT953AB.pls 120.0 2007/12/03 10:56:49 amakrish noship $ */

function high1formula(TOT_HOURS in number, HIGH in number) return number is
 HIGH1       NUMBER(8,2);
begin
   IF NVL(TOT_HOURS,0) > NVL(HIGH,0) THEN
   HIGH1 := NVL(TOT_HOURS,0) - NVL(HIGH,0);
   ELSE
      HIGH1 := 0;
   END IF;
   RETURN HIGH1;
end;

function low1formula(TOT_HOURS in number, LOW in number) return number is
   LOW1       NUMBER(8,2);
begin
   IF NVL(TOT_HOURS,0) < NVL(LOW,0) THEN
   LOW1 := NVL(LOW,0) - NVL(TOT_HOURS,0);
   ELSE
   LOW1 := 0;
   END IF;
   RETURN LOW1;
end;

function average1formula(TOT_HOURS in number, AVERAGE in number) return number is
   AVERAGE1       NUMBER(8,2);
begin
   AVERAGE1 := NVL(TOT_HOURS,0) - NVL(AVERAGE,0);
   RETURN AVERAGE1;
END;

function BeforeReport return boolean is
begin

  /*SRW.USER_EXIT('FND SRWINIT');*/null;


  if start_date is null then
     start_date := hr_general.start_of_time;
  end if;
  if end_date is null then
     end_date := hr_general.end_of_time;
  end if;
  return (TRUE);
end;

function AfterReport return boolean is
begin

   /*SRW.USER_EXIT('FND SRWEXIT');*/null;


  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT953A_XMLP_PKG ;

/
