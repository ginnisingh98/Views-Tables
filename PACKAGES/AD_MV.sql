--------------------------------------------------------
--  DDL for Package AD_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_MV" AUTHID CURRENT_USER AS
/* $Header: admvs.pls 115.6 2004/04/15 05:03:34 sallamse noship $*/

   g_mv_data_tablespace            VARCHAR2(100);
   g_mv_index_tablespace           VARCHAR2(100);

   mv_create                       CONSTANT PLS_INTEGER := 1;
   mv_alter                        CONSTANT PLS_INTEGER := 2;
   mv_drop                         CONSTANT PLS_INTEGER := 3;

   PROCEDURE alter_mv (
     as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   );

   PROCEDURE create_mv (
     as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   , ab_long_stmt_i                BOOLEAN DEFAULT FALSE
   );

   PROCEDURE create_mv2 (
     as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   , ab_long_stmt_i                INTEGER DEFAULT 0
   );

   PROCEDURE drop_mv (
     as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   );

   PROCEDURE do_mv_ddl2 (
     an_operation_i                PLS_INTEGER
   , as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   , ab_execute_i                  INTEGER DEFAULT NULL
   );

   PROCEDURE do_mv_ddl (
     an_operation_i                PLS_INTEGER
   , as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   , ab_execute_i                  BOOLEAN DEFAULT NULL
   );

END ad_mv;

 

/
