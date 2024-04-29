--------------------------------------------------------
--  DDL for Package Body XLA_CONTEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CONTEXT_PKG" AS
-- $Header: xlacmctx.pkb 120.3.12010000.2 2009/09/07 11:23:06 kapkumar ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlacmctx.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_context_pkg                                                         |
|                                                                            |
| DESCRIPTION                                                                |
|    This context package is used to set the attribute values for the        |
|    application context namespace "XLA"                                     |
|                                                                            |
| HISTORY                                                                    |
|    23-Jan-03  S. Singhania       Created                                   |
|    17-Apr-03  S. Singhania       Added body for the following:             |
|                                    - set_acct_err_context                  |
|                                    - get_acct_err_context                  |
|                                    - clear_acct_err_context                |
|    12-Oct-05  A.Wan              4645092 - MPA report changes              |
|                                                                            |
+===========================================================================*/

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following are the public routines that can be called to set attributes
-- for a naempsace (application context)
--
--    1.    set_security_context
--    2.    set_acct_err_contex
--    3.    get_acct_err_contex
--    4.    clear_acct_err_contex
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================
--=============================================================================
--
--
--
--=============================================================================
PROCEDURE set_security_context
       (p_security_group             IN  VARCHAR2) IS
BEGIN
   ----------------------------------------------------------------------------
   -- Following sets the value for the attribute 'SECURITY_GROUP' for the
   -- application context namespace 'XLA'
   ----------------------------------------------------------------------------
   dbms_session.set_context
      ('XLA','SECURITY_GROUP',p_security_group);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkgset_security_context');
END set_security_context;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE set_acct_err_context
       (p_error_count                IN NUMBER
       ,p_client_id                  IN VARCHAR2) IS
BEGIN
   ----------------------------------------------------------------------------
   -- Following sets the value for the attribute 'SECURITY_GROUP' for the
   -- application context namespace 'XLA'
   ----------------------------------------------------------------------------
   dbms_session.set_context
      (namespace           => 'XLA_GLOBAL'
      ,attribute           => 'ACCOUNTING_ERRORS_COUNT'
      ,value               => TO_CHAR(p_error_count)
      ,username            => NULL
      ,client_id           => p_client_id);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkgset_security_context');
END set_acct_err_context;

--=============================================================================
--
--
--
--=============================================================================
FUNCTION get_acct_err_context
RETURN NUMBER IS
BEGIN
   RETURN NVL(sys_context('XLA_GLOBAL','ACCOUNTING_ERRORS_COUNT'),0);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkgget_security_context');
END get_acct_err_context;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE clear_acct_err_context
       (p_client_id                  IN VARCHAR2) IS
BEGIN
   ----------------------------------------------------------------------------
   -- Following sets the value for the attribute 'SECURITY_GROUP' for the
   -- application context namespace 'XLA'
   ----------------------------------------------------------------------------
   dbms_session.clear_context
      (namespace           => 'XLA_GLOBAL'
      ,attribute           => 'ACCOUNTING_ERRORS_COUNT'
      ,client_id           => p_client_id);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkgset_security_context');
END clear_acct_err_context;


------------------------------------------------------------------------------
-- 4645092  To set MPA-Accrual context
------------------------------------------------------------------------------
PROCEDURE set_mpa_accrual_context
       (p_mpa_accrual_exists         IN VARCHAR2
       ,p_client_id                  IN VARCHAR2 DEFAULT NULL) IS
BEGIN
   ----------------------------------------------------------------------------
   -- Following sets the value for the attribute 'MPA_ACCRUAL_EXISTS' for the
   -- application context namespace 'XLA_GLOBAL'
   ----------------------------------------------------------------------------
   dbms_session.set_context
      (namespace           => 'XLA_GLOBAL'
      ,attribute           => 'MPA_ACCRUAL_EXISTS'
      ,value               => p_mpa_accrual_exists
      ,username            => NULL
      ,client_id           => p_client_id);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkg.set_mpa_accrual_context');
END set_mpa_accrual_context;

------------------------------------------------------------------------------
-- 4645092  To get MPA-accrual context
------------------------------------------------------------------------------
FUNCTION get_mpa_accrual_context
RETURN VARCHAR2 IS
BEGIN
   RETURN NVL(sys_context('XLA_GLOBAL','MPA_ACCRUAL_EXISTS'),'N');
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkgget_mpa_accrual_context');
END get_mpa_accrual_context;


------------------------------------------------------------------------------
-- 4645092  To clear MPA-accrual context
------------------------------------------------------------------------------
PROCEDURE clear_mpa_accrual_context
       (p_client_id                  IN VARCHAR2) IS
BEGIN
   ----------------------------------------------------------------------------
   -- Following sets the value for the attribute 'MPA_ACCRUAL_EXISTS' for the
   -- application context namespace 'XLA_GLOBAL'
   ----------------------------------------------------------------------------
   dbms_session.clear_context
      (namespace           => 'XLA_GLOBAL'
      ,attribute           => 'MPA_ACCRUAL_EXISTS'
      ,client_id           => p_client_id);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkgclear_mpa_accrual_context');
END clear_mpa_accrual_context;

---------------------------------------------------------------------
-- 4865292 Event context
---------------------------------------------------------------------
PROCEDURE set_event_count_context
       (p_event_count                IN NUMBER
       ,p_client_id                  IN VARCHAR2 DEFAULT NULL) IS

BEGIN
   ----------------------------------------------------------------------------
   -- Following sets the value for the attribute 'EVENT_COUNT' for the
   -- application context namespace 'XLA'
   ----------------------------------------------------------------------------

--changed namespace parameter from global to local bug8744290


   dbms_session.set_context
      (namespace           => 'XLA'
      ,attribute           => 'EVENT_COUNT'
      ,value               => TO_CHAR(p_event_count)
      ,username            => NULL
      ,client_id           => p_client_id);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkg.set_event_count_context');
END set_event_count_context;

FUNCTION get_event_count_context
RETURN NUMBER IS
BEGIN

--changed namespace parameter from global to local bug8744290


   RETURN NVL(sys_context('XLA','EVENT_COUNT'),0);

END get_event_count_context;

PROCEDURE set_event_nohdr_context
       (p_nohdr_extract_flag         IN VARCHAR2
       ,p_client_id                  IN VARCHAR2 DEFAULT NULL) IS
BEGIN
   ----------------------------------------------------------------------------
   -- Following sets the value for the attribute 'NO_HDR_EXTRACT_FLAG' for
   -- the application context namespace 'XLA'
   ----------------------------------------------------------------------------
   dbms_session.set_context
      (namespace           => 'XLA_GLOBAL'
      ,attribute           => 'NO_HDR_EXTRACT_FLAG'
      ,value               => p_nohdr_extract_flag
      ,username            => NULL
      ,client_id           => p_client_id);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkg.set_event_nohdr_context');
END set_event_nohdr_context;

FUNCTION get_event_nohdr_context
RETURN VARCHAR2 IS
BEGIN

   RETURN NVL(SYS_CONTEXT('XLA_GLOBAL','NO_HDR_EXTRACT_FLAG'),'N');

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkg.get_event_nohdr_context');
END get_event_nohdr_context;

PROCEDURE clear_event_context
       (p_client_id                  IN VARCHAR2) IS
BEGIN
   ---------------------------------------------------------------------------
   -- Following sets the value for the attribute 'EVENT_COUNT' and
   -- 'NO_HDR_EXTRACT_FLAG' for the application context namespace
   -- 'XLA_GLOBAL'
   ---------------------------------------------------------------------------
   dbms_session.clear_context
      (namespace           => 'XLA_GLOBAL'
      ,attribute           => 'EVENT_COUNT'
      ,client_id           => p_client_id);

   dbms_session.clear_context
      (namespace           => 'XLA_GLOBAL'
      ,attribute           => 'NO_HDR_EXTRACT_FLAG'
      ,client_id           => p_client_id);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location       => 'xla_context_pkg.clear_event_context');
END clear_event_context;

END xla_context_pkg;

/
