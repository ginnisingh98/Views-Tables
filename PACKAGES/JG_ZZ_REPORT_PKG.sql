--------------------------------------------------------
--  DDL for Package JG_ZZ_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_REPORT_PKG" AUTHID CURRENT_USER as
/* $Header: jgzzreps.pls 115.0 99/07/16 02:36:56 porting s $ */


  PROCEDURE set_body_print_object (p_object VARCHAR2);
  FUNCTION  print_page_group_total RETURN boolean;
  FUNCTION  first_page             RETURN boolean;
  FUNCTION last_body_object        RETURN varchar2;
  g_last_body_object    VARCHAR2(30) := 'TOTAL';
  g_first_page          BOOLEAN      := TRUE;


END JG_ZZ_REPORT_PKG;

 

/
