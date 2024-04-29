--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_ACCOUNTING_PKG" AS
/* $Header: faxlacab.pls 120.0.12010000.3 2009/10/29 12:44:58 bridgway ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_extract_deprn_pkg                                           |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for XLA extract package body generation                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-FEB-2006 BRIDGWAY      Created                                      |
|                                                                            |
+===========================================================================*/


G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_cmp_accounting_pkg.';


--+==========================================================================+
--| PUBLIC procedure                                                         |
--|    Compile                                                               |
--| DESCRIPTION : generates the PL/SQL packages from the Product Accounting  |
--|               definition.                                                |
--|                                                                          |
--|  RETURNS                                                                 |
--|   1. l_IsCompiled  : BOOLEAN, TRUE if Extract package have               |
--|                      been successfully created, FALSE otherwise.         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

PROCEDURE Compile IS

   PRAGMA AUTONOMOUS_TRANSACTION;
   l_IsCompiled          BOOLEAN;
   l_procedure_name      varchar2(80) := 'Compile';

   error_found           exception;

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_IsCompiled := fa_xla_cmp_extract_pkg.Compile;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(G_LEVEL_STATEMENT,
                  G_MODULE_NAME||l_procedure_name,
                  'return value. = '||
                  CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);
   END IF;

   if not l_IsCompiled then
      raise error_found;
   end if;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

EXCEPTION
   WHEN error_found THEN
        raise;

   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;

END Compile;

--=============================================================================

END fa_xla_cmp_accounting_pkg;

/
