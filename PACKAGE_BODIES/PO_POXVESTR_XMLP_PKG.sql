--------------------------------------------------------
--  DDL for Package Body PO_POXVESTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXVESTR_XMLP_PKG" AS
/* $Header: POXVESTRB.pls 120.1 2007/12/25 12:43:09 krreddy noship $ */

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;

RETURN TRUE;  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXVESTR_XMLP_PKG ;


/
