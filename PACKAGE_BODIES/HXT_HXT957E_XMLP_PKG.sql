--------------------------------------------------------
--  DDL for Package Body HXT_HXT957E_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT957E_XMLP_PKG" AS
/* $Header: HXT957EB.pls 120.0 2007/12/03 11:24:02 amakrish noship $ */

function BeforeReport return boolean is
begin
    /*SRW.USER_EXIT('FND SRWINIT');*/null;


  return (TRUE);
end;

function AfterReport return boolean is
begin
    /*SRW.USER_EXIT('FND SRWEXIT');*/null;


  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT957E_XMLP_PKG ;

/
