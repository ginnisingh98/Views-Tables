--------------------------------------------------------
--  DDL for Package Body XLA_ACCT_SETUP_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCT_SETUP_PUB_PKG" AS
-- $Header: xlasuaop.pkb 120.1 2003/02/24 07:04:27 sasingha ship $
/*===========================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|    xla_acct_setup_pub_pkg                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|    XLA Accounting Options Setup Public api                                 |
|                                                                            |
| HISTORY                                                                    |
|    06-Feb-03 Dimple Shah    Created                                        |
|                                                                            |
+===========================================================================*/

--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
g_debug_flag      VARCHAR2(1) := NVL(fnd_profile.value('XLA_DEBUG_TRACE'),'N');

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER) IS
BEGIN
   IF g_debug_flag = 'Y' THEN
      xla_utility_pkg.trace
         (p_msg
         ,p_level);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_acct_setup_pub_pkg.trace');
END trace;


--=============================================================================
--
-- Sets up ledger options for all subledger applications and given ledger
--
--=============================================================================
PROCEDURE setup_ledger_options
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER) IS
l_primary_ledger_id        NUMBER(38) := p_primary_ledger_id;
l_ledger_id                NUMBER(38) := p_ledger_id;
BEGIN
   trace('> xla_acct_setup_pub_pkg.setup_ledger_options', 10);
   trace('ledger_id             = '||p_ledger_id, 20);
   trace('primary_ledger_id     = '||p_primary_ledger_id, 20);

   xla_acct_setup_pkg.setup_ledger_options
      (p_primary_ledger_id  => l_primary_ledger_id
      ,p_ledger_id          => l_ledger_id);

   trace('< xla_acct_setup_pub_pkg.setup_ledger_options'    , 10);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pub_pkg.setup_ledger_options');
END setup_ledger_options;

--=============================================================================
--
-- Checks if a valid accounting method is attached to the ledger
--
--=============================================================================
PROCEDURE check_acctg_method_for_ledger
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER) IS
l_primary_ledger_id        NUMBER(38)   := p_primary_ledger_id;
l_ledger_id                NUMBER(38)   := p_ledger_id;
BEGIN
   trace('> xla_acct_setup_pub_pkg.check_acctg_method_for_ledger', 10);
   trace('ledger_id             = '||p_ledger_id, 20);
   trace('primary_ledger_id     = '||p_primary_ledger_id, 20);

   xla_acct_setup_pkg.check_acctg_method_for_ledger
      (p_primary_ledger_id => l_primary_ledger_id
      ,p_ledger_id         => l_ledger_id);

   trace('< xla_acct_setup_pub_pkg.check_acctg_method_for_ledger'    , 10);
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_setup_pub_pkg.check_acctg_method_for_ledger');
END check_acctg_method_for_ledger;

END xla_acct_setup_pub_pkg;

/
