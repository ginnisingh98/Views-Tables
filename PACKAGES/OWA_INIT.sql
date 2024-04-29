--------------------------------------------------------
--  DDL for Package OWA_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OWA_INIT" AUTHID CURRENT_USER as
/* $Header: AFOAUTHS.pls 115.3 99/07/16 23:25:35 porting  $ */

   -- If your timezone is not in the list of standard timezones,
   -- then use dbms_server_gmtdiff to give the number of hours
   -- that your database server is ahead (or negative if behind)
   -- Greenwich Mean Time
   dbms_server_timezone constant varchar2(3) := 'PST';
   dbms_server_gmtdiff  constant number      := NULL;

   -- Global DCD Authorization callback function
   --    it is used when DCD's authorization scheme is set to GLOBAL
   function authorize return boolean;
end OWA_INIT;

 

/
