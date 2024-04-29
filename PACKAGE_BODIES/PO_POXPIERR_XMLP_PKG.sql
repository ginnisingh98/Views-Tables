--------------------------------------------------------
--  DDL for Package Body PO_POXPIERR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPIERR_XMLP_PKG" AS
/* $Header: POXPIERRB.pls 120.2 2008/01/11 11:57:40 dwkrishn noship $ */

function afterreport(c_count in number) return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;

if ( c_count > 0 ) then
  DELETE FROM po_interface_errors
  WHERE interface_type = p_source_program
  AND p_purge_data = 'Y';
  return (TRUE);
else
  return (true);
end if;
RETURN NULL; end;

function m_header_grpfrformattrigger(c_count in number) return boolean is
begin
  if c_count = 0 then
    return (FALSE);
  else
    return (TRUE);
  end if;
RETURN NULL; end;

function AFTERREPORT0007 (c_count in number)return boolean is
begin
  return (afterreport(c_count) );
end;

function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXPIERR_XMLP_PKG ;


/
