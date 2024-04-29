--------------------------------------------------------
--  DDL for Package XNP_WSGFL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_WSGFL" AUTHID CURRENT_USER as
/* $Header: XNPWSFLS.pls 120.0 2005/05/30 11:48:44 appldev noship $ */


   function Black (Param in varchar2) return varchar2;
   function Blue (Param in varchar2) return varchar2;
   function Cyan (Param in varchar2) return varchar2;
   function Green (Param in varchar2) return varchar2;
   function Grey (Param in varchar2) return varchar2;
   function Magenta (Param in varchar2) return varchar2;
   function Red (Param in varchar2) return varchar2;
   function White (Param in varchar2) return varchar2;
   function Yellow (Param in varchar2) return varchar2;

end;

 

/
