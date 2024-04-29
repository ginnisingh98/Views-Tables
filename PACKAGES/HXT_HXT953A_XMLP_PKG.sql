--------------------------------------------------------
--  DDL for Package HXT_HXT953A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT953A_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT953AS.pls 120.0 2007/12/03 10:55:50 amakrish noship $ */
	Start_Date	date;
	Period_Type	varchar2(32767);
	End_date	date;
	P_CONC_REQUEST_ID	number;
	function high1formula(TOT_HOURS in number, HIGH in number) return number  ;
	function low1formula(TOT_HOURS in number, LOW in number) return number  ;
	function average1formula(TOT_HOURS in number, AVERAGE in number) return number  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT953A_XMLP_PKG;

/
