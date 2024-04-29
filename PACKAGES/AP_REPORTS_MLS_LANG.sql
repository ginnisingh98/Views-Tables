--------------------------------------------------------
--  DDL for Package AP_REPORTS_MLS_LANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_REPORTS_MLS_LANG" AUTHID CURRENT_USER AS
/* $Header: apxlangs.pls 120.2 2004/10/29 19:19:15 pjena noship $ */

   FUNCTION APXVDLET RETURN VARCHAR2;
   FUNCTION APXPPREM RETURN VARCHAR2;
   FUNCTION APXINPRT RETURN VARCHAR2;
   FUNCTION APXSOBLX   RETURN VARCHAR2;

END AP_REPORTS_MLS_LANG;

 

/
