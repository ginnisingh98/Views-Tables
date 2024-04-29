--------------------------------------------------------
--  DDL for Package Body JG_ZZ_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_REPORT_PKG" as
/* $Header: jgzzrepb.pls 115.0 99/07/16 02:36:51 porting s $ */


PROCEDURE set_body_print_object (p_object VARCHAR2) is
BEGIN

   /* Possible values are 'TOTAL' or 'DETAIL' */

   g_last_body_object := p_object;
END;

FUNCTION  print_page_group_total RETURN boolean is
BEGIN
  if (g_last_body_object = 'TOTAL')
  then
    return (FALSE);
  else
    return (TRUE);
  end if;
END;

FUNCTION last_body_object RETURN varchar2 is
BEGIN
  return(g_last_body_object);
END;

FUNCTION  first_page RETURN boolean is
BEGIN
   if (g_first_page)
   then
      g_first_page := FALSE;
      return(TRUE);
   else
      return(g_first_page);
   end if;
END;


END JG_ZZ_REPORT_PKG;

/
