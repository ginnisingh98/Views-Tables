--------------------------------------------------------
--  DDL for Package Body FEM_SESSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_SESSION_PKG" AS
/* $Header: fem_session.plb 120.0.12010000.2 2010/04/20 19:11:12 ghall ship $ */

PROCEDURE start_alter_session (p_enable IN BOOLEAN) IS
BEGIN

   EXECUTE IMMEDIATE 'alter session set nls_date_format = ''MM/DD/YYYY''';

   IF p_enable THEN

      NULL;

   -- Normal SQL Trace
      EXECUTE IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER=''FEMCCE''';
      EXECUTE IMMEDIATE 'alter session set sql_trace TRUE';

   -- SQL Trace including wait events
   -- EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever, level 8''';

   -- _px_trace (for parallel query)
   -- EXECUTE IMMEDIATE 'alter session set "_px_trace"="high", "messaging", "medium", "execution", "time"';

   END IF;

END start_alter_session;


PROCEDURE stop_alter_session (p_enable IN BOOLEAN) IS
BEGIN

   IF p_enable THEN

      NULL;

   -- Turn off normal SQL Trace
      EXECUTE IMMEDIATE 'alter session set sql_trace FALSE';

   -- Turn off SQL Trace including wait events
   -- EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context off''';

   -- Turn off _px_trace
   -- EXECUTE IMMEDIATE 'alter session set "_px_trace"="none"';

   END IF;

END stop_alter_session;

END fem_session_pkg;

/
