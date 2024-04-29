--------------------------------------------------------
--  DDL for Package APPS_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."APPS_DDL" AUTHID DEFINER as
/* $Header: adaddls.pls 115.1 99/07/17 04:29:35 porting ship $ */
   --
   -- Package
   --   APPS_DDL
   -- Purpose
   --   Dynamic DDL support
   -- Notes
   --   1. This package is created in each Oracle Applications account
   --   2. Each account requires the following explicit
   --      privileges to run (i.e. these privileges cannot be obtained
   --      from a role, like 'connect'):
   --		grant create session to <schema>;
   --		grant alter session to <schema>;
   --		grant create database link to <schema>;
   --		grant create synonym to <schema>;
   --		grant create view to <schema>;
   --		grant create cluster to <schema>;
   --		grant create procedure to <schema>;
   --		grant create sequence to <schema>;
   --		grant create table to <schema>;
   --		grant create trigger to <schema>;
   --	Currently AutoInstall grants the neccessary privs to each schema
   --
procedure apps_ddl(ddl_text in varchar2);
end APPS_DDL;

 

/

  GRANT EXECUTE ON "APPS"."APPS_DDL" TO "OKC";
