--------------------------------------------------------
--  DDL for Package Body GL_GLXRDRTS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRDRTS_XMLP_PKG" AS
/* $Header: GLXRDRTSB.pls 120.0 2007/12/27 15:08:40 vijranga noship $ */

function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END GL_GLXRDRTS_XMLP_PKG ;


/
