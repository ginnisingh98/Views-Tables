--------------------------------------------------------
--  DDL for Package Body GL_JOURNAL_IMPORT_SLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JOURNAL_IMPORT_SLA_PKG" as
/* $Header: glujislb.pls 120.6 2006/08/24 00:18:19 kvora ship $ */

  PROCEDURE delete_batches(x_je_source_name  VARCHAR2,
			   x_group_id        NUMBER) IS
  BEGIN

    UPDATE GL_BC_PACKETS
      SET  je_batch_id = -1, group_id = NULL
    WHERE  group_id = x_group_id;

    DELETE gl_import_references
    WHERE je_header_id IN
      (SELECT jeh.je_header_id
       FROM gl_je_batches jeb,
            gl_je_headers jeh
       WHERE jeb.status = 'U'
       AND   jeb.group_id = x_group_id
       AND   jeh.je_batch_id = jeb.je_batch_id
       AND   jeh.ledger_id < 0
       AND   jeh.je_source = x_je_source_name);

    DELETE gl_je_lines
    WHERE je_header_id IN
      (SELECT jeh.je_header_id
       FROM gl_je_batches jeb,
            gl_je_headers jeh
       WHERE jeb.status = 'U'
       AND   jeb.group_id = x_group_id
       AND   jeh.je_batch_id = jeb.je_batch_id
       AND   jeh.ledger_id < 0
       AND   jeh.je_source = x_je_source_name);

    DELETE gl_je_headers jeh
    WHERE jeh.ledger_id < 0
    AND   jeh.je_source = x_je_source_name
    AND   jeh.je_batch_id IN
      (SELECT jeb.je_batch_id
       FROM gl_je_batches jeb
       WHERE jeb.status = 'U'
       AND   jeb.group_id = x_group_id);

    DELETE gl_je_batches jeb
    WHERE jeb.status = 'U'
    AND   jeb.group_id = x_group_id
    AND NOT EXISTS
      (SELECT 'has journals'
       FROM gl_je_headers jeh
       WHERE jeh.je_batch_id = jeb.je_batch_id);
  END delete_batches;

  PROCEDURE keep_batches(x_je_source_name             VARCHAR2,
		         x_group_id                   NUMBER,
                         start_posting                BOOLEAN,
                         data_access_set_id           NUMBER,
                         req_id            OUT NOCOPY NUMBER) IS
    prun_id         NUMBER;
    coa_id          NUMBER;
    single_led_id   NUMBER;
    dummy           NUMBER;
    found_batch     BOOLEAN;

   CURSOR single_ledger (c_prun_id NUMBER) IS
     SELECT max(abs(JEH.ledger_id))
     FROM   GL_JE_BATCHES JEB,
            GL_JE_HEADERS JEH
     WHERE  JEB.status = 'S'
     AND    JEB.posting_run_id = c_prun_id
     AND    JEH.je_batch_id = JEB.je_batch_id
     GROUP BY JEB.posting_run_id
     HAVING count(distinct abs(JEH.ledger_id)) = 1;

   CURSOR alc_exists (c_prun_id NUMBER) IS
     SELECT '1'
     FROM   GL_JE_BATCHES JEB,
            GL_JE_HEADERS JEH
     WHERE  JEB.status = 'S'
     AND    JEB.posting_run_id = c_prun_id
     AND    JEH.je_batch_id = JEB.je_batch_id
     AND    JEH.actual_flag <> 'B'
     AND    JEH.reversed_je_header_id IS NULL
     AND EXISTS
       (SELECT 1
        FROM   GL_LEDGER_RELATIONSHIPS LRL
        WHERE  LRL.source_ledger_id = abs(JEH.ledger_id)
        AND    LRL.target_ledger_category_code = 'ALC'
        AND    LRL.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')
        AND    LRL.application_id = 101
        AND    LRL.relationship_enabled_flag = 'Y'
        AND    JEH.je_source NOT IN
          (SELECT INC.je_source_name
           FROM   GL_JE_INCLUSION_RULES INC
           WHERE  INC.je_rule_set_id =
                     LRL.gl_je_conversion_set_id
           AND    INC.je_source_name = JEH.je_source
           AND    INC.je_category_name = 'Other'
           AND    INC.include_flag = 'N'
           AND    INC.user_updatable_flag = 'N'));

  BEGIN

    -- If so requested, start posting if there are valid
    -- batches to post.
    req_id := 0;
    prun_id := 0;
    found_batch := FALSE;
    IF (start_posting) THEN
      SELECT GL_JE_POSTING_S.nextval
      INTO prun_id
      FROM dual;

      UPDATE gl_je_batches jeb
      SET    status = 'S',
             posting_run_id = prun_id
      WHERE jeb.status = 'U'
      AND   jeb.group_id = x_group_id
      AND   jeb.approval_status_code = 'Z'
      AND NOT EXISTS
        (SELECT 'not open period'
         FROM   gl_je_headers jeh,
                gl_ledgers lgr,
                gl_period_statuses ps
         WHERE  jeh.je_batch_id = jeb.je_batch_id
         AND    lgr.ledger_id = - jeh.ledger_id
         AND    ps.application_id = 101
         AND    ps.ledger_id = - jeh.ledger_id
         AND    ps.period_name = jeh.period_name
         AND    (    (    (jeh.actual_flag = 'A')
                      AND (ps.closing_status <> 'O'))
                 OR  (    (jeh.actual_flag = 'E')
                      AND (least(nvl(lgr.latest_encumbrance_year,0),
                                    ps.period_year) <> ps.period_year))
                 OR  (    (jeh.actual_flag = 'B')
                      AND (NOT EXISTS
                             (SELECT 'open year'
                              FROM   gl_budget_period_ranges pr
                              WHERE  pr.budget_version_id
                                       = jeh.budget_version_id
                              AND    pr.period_year = ps.period_year
                              AND    ps.period_num
                                       between pr.start_period_num
                                       and pr.end_period_num)))))
      AND  EXISTS
        (SELECT 'has negative journals'
         FROM  gl_je_headers jeh
         WHERE jeh.je_batch_id = jeb.je_batch_id
         AND   jeh.ledger_id < 0
         AND   jeh.je_source = x_je_source_name);

      IF (SQL%FOUND) THEN
        found_batch := TRUE;
      END IF;

      -- Start posting if one or more batches found
      IF (found_batch) THEN

        SELECT chart_of_accounts_id
        INTO coa_id
        FROM gl_je_batches jeb
        WHERE jeb.status = 'S'
        AND   jeb.posting_run_id = prun_id
        AND   rownum = 1;

        -- Set single_ledger_id to the journal ledger id if the batch
        -- has journals only for a single ledger which has no enabled
        -- journal or subledger RCs.
        OPEN single_ledger(prun_id);
        FETCH single_ledger INTO single_led_id;
        IF single_ledger%NOTFOUND THEN
          single_led_id := -99;
        ELSE
          OPEN alc_exists(prun_id);
          FETCH alc_exists INTO dummy;
          IF alc_exists%FOUND THEN
            single_led_id := -99;
          END IF;
          CLOSE alc_exists;
        END IF;
        CLOSE single_ledger;

        -- Submit Posting...
        IF (single_led_id = -99) THEN
          req_id := fnd_request.submit_request(
 	            'SQLGL',
                    'GLPPOS',
                    '',
                    '',
                    FALSE,
                    to_char(single_led_id),
                    to_char(data_access_set_id),
		    to_char(coa_id),
                    to_char(prun_id),
  	            chr(0),
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '');
        ELSE
          req_id := fnd_request.submit_request(
 	            'SQLGL',
                    'GLPPOSS',
                    '',
                    '',
                    FALSE,
                    to_char(single_led_id),
                    to_char(data_access_set_id),
		    to_char(coa_id),
                    to_char(prun_id),
  	            chr(0),
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '');
        END IF;

        IF (req_id <> 0) THEN
          UPDATE gl_je_batches jeb
          SET request_id = req_id
          WHERE jeb.status = 'S'
          AND  EXISTS
            (SELECT 'has negative journals'
             FROM  gl_je_headers jeh
             WHERE jeh.je_batch_id = jeb.je_batch_id
             AND   jeh.ledger_id < 0
             AND   jeh.je_source = x_je_source_name);
        END IF;
      END IF;
    END IF;

    -- Make the negative ledger ids positive
    UPDATE /*+ INDEX(jel GL_JE_LINES_U1) */
           gl_je_lines jel
    SET   jel.ledger_id = -jel.ledger_id
    WHERE jel.je_header_id IN
      (SELECT /*+ ORDERED
                  INDEX(jeb GL_JE_BATCHES_N1)
                  INDEX(jeh GL_JE_HEADERS_N1)
               */
              jeh.je_header_id
       FROM gl_je_batches jeb,
            gl_je_headers jeh
       WHERE jeb.status in ('U','S')
       AND   nvl(jeb.posting_run_id, prun_id) = prun_id
       AND   jeb.group_id = x_group_id
       AND   jeh.je_batch_id = jeb.je_batch_id
       AND   jeh.ledger_id < 0
       AND   jeh.je_source = x_je_source_name);

    -- Make the negative ledger ids positive
    UPDATE gl_je_headers jeh
    SET jeh.ledger_id = -jeh.ledger_id
    WHERE jeh.ledger_id < 0
    AND   jeh.je_source = x_je_source_name
    AND   jeh.je_batch_id IN
      (SELECT jeb.je_batch_id
       FROM gl_je_batches jeb
       WHERE jeb.status in ('U','S')
       AND   nvl(jeb.posting_run_id, prun_id) = prun_id
       AND   jeb.group_id = x_group_id);

  END keep_batches;

END GL_JOURNAL_IMPORT_SLA_PKG;

/
