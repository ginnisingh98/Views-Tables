--------------------------------------------------------
--  DDL for Package MSC_CL_PULL_WORKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_PULL_WORKER" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCCLAAS.pls 120.14 2007/04/05 12:52:03 vpalla ship $ */
   v_table_name             VARCHAR2(32);
   v_view_name              VARCHAR2(32);
   v_union_sql              varchar2(32767);
   v_gmp_routine_name       VARCHAR2(50);
   GMP_ERROR                EXCEPTION;


END MSC_CL_PULL_WORKER;

/
