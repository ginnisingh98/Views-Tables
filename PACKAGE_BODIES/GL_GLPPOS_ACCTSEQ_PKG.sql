--------------------------------------------------------
--  DDL for Package Body GL_GLPPOS_ACCTSEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLPPOS_ACCTSEQ_PKG" as
/* $Header: gluposqb.pls 120.2.12010000.2 2009/06/17 05:27:07 dthakker ship $ */

PROCEDURE Batch_Init(
            p_request_id            IN  NUMBER,
            p_coa_id                IN  NUMBER,
            p_prun_id               IN  NUMBER,
            p_ledgers_locked       OUT  NOCOPY NUMBER) IS

  l_ldr_tbl           FUN_SEQ_BATCH.num15_tbl_type;
  l_ldr_locked_tbl    FUN_SEQ_BATCH.num15_tbl_type;
  l_ldr_locked_count  NUMBER;

BEGIN

   SELECT distinct JEH.ledger_id BULK COLLECT
   INTO   l_ldr_tbl
   FROM   GL_JE_BATCHES JEB,
          GL_JE_HEADERS JEH
   WHERE  JEB.posting_run_id = p_prun_id
   AND    JEB.chart_of_accounts_id = p_coa_id
   AND    JEB.status = 'I'
   AND    JEH.je_batch_id = JEB.je_batch_id;

   IF l_ldr_tbl.COUNT > 0 THEN
      FUN_SEQ_BATCH.batch_init(p_request_id, l_ldr_tbl,
                               l_ldr_locked_tbl, l_ldr_locked_count);

      IF l_ldr_locked_tbl.COUNT > 0 THEN
         /* Bug8581442 modified FORALL statement */
         FORALL i IN INDICES OF l_ldr_locked_tbl
            INSERT INTO GL_POSTING_ACCT_SEQ_GT(ledger_id)
                        VALUES (l_ldr_locked_tbl(i));
         p_ledgers_locked := l_ldr_locked_tbl.COUNT;
      ELSE
         p_ledgers_locked := 0;
      END IF;
   ELSE
      p_ledgers_locked := 0;
   END IF;

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'GL_GLPPOS_ACCTSEQ_PKG.batch_init');
    RAISE;
END Batch_Init;

END GL_GLPPOS_ACCTSEQ_PKG;

/
