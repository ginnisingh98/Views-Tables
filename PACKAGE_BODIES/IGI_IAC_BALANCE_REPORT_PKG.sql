--------------------------------------------------------
--  DDL for Package Body IGI_IAC_BALANCE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_BALANCE_REPORT_PKG" AS
-- $Header: igiiabrb.pls 120.6 2007/08/01 10:46:17 npandya ship $
--
--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiabrb.igi_iac_balance_report_pkg.';

--===========================FND_LOG.END=======================================

Function IGI_IAC_CHECK_ACCOUNTS ( p_sql VARCHAR2 , p_accval OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN AS
    l_path 			 VARCHAR2(150) := g_path||'IGI_IAC_CHECK_ACCOUNTS';
BEGIN
  EXECUTE IMMEDIATE  p_sql INTO p_accval ;
  RETURN TRUE ;
EXCEPTION
  WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(l_path);
     RETURN FALSE ;
END IGI_IAC_CHECK_ACCOUNTS;
END;

/
