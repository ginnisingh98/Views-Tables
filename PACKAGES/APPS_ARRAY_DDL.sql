--------------------------------------------------------
--  DDL for Package APPS_ARRAY_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."APPS_ARRAY_DDL" AUTHID DEFINER as
/* $Header: adaaddls.pls 115.2 1999/11/09 16:51:03 pkm ship     $ */
   --
   -- Package
   --   APPS_ARRAY_DDL
   -- Purpose
   --   Dynamic DDL support for large objects needing >32K SQL statements
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
glprogtext dbms_sql.varchar2s;
procedure apps_array_ddl(lb           in integer,
                         ub           in integer,
                         newline_flag in varchar2 default 'FALSE');
end APPS_ARRAY_DDL;

 

/
