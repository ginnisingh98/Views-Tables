--------------------------------------------------------
--  DDL for Package Body PA_PACINTAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PACINTAR_XMLP_PKG" AS
/* $Header: PACINTARB.pls 120.0 2008/01/02 10:54:40 krreddy noship $ */

function BeforeReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;

/*SRW.USER_EXIT('FND GETPROFILE
               NAME="USER_ID"
               FIELD=":P_USER_ID"
               PRINT_ERROR="N"');*/null;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT') ;*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PA_PACINTAR_XMLP_PKG ;


/
