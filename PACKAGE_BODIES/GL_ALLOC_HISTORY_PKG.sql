--------------------------------------------------------
--  DDL for Package Body GL_ALLOC_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ALLOC_HISTORY_PKG" AS
/* $Header: glimahib.pls 120.5 2005/05/05 01:17:09 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE period_last_run(batch_id NUMBER,
			    access_set_id NUMBER,
                            period_name IN OUT NOCOPY VARCHAR2,
                            calculation_eff_date IN OUT NOCOPY DATE,
                            journal_eff_date IN OUT NOCOPY DATE) IS
    CURSOR get_period IS
      SELECT H1.to_period_name, H1.calculation_effective_date,
             H1.journal_effective_date
      FROM   GL_ALLOC_HISTORY H1
      WHERE  H1.ALLOCATION_BATCH_ID = batch_id
      AND    H1.ACCESS_SET_ID = access_set_id
      AND    H1.LAST_UPDATE_DATE
                           = (SELECT MAX(H2.LAST_UPDATE_DATE)
                              FROM   GL_ALLOC_HISTORY H2
                              WHERE  H2.ALLOCATION_BATCH_ID
                                       = batch_id
                              AND    H2.ACCESS_SET_ID
                                       = access_set_id
                              AND    RUN_STATUS = 'C')
      AND    RUN_STATUS = 'C';
  BEGIN
    OPEN get_period;
    FETCH get_period INTO period_name, calculation_eff_date, journal_eff_date;
    CLOSE get_period;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_alloc_history_pkg.period_last_run');
      RAISE;
  END period_last_run;


  FUNCTION set_random_ledger_id (x_allocation_batch_id NUMBER,
                                 x_line_selection VARCHAR2,
                                 x_ledger_override_id NUMBER) RETURN NUMBER IS
    CURSOR random_abc_ledger IS
      SELECT ldg.ledger_id
      FROM   gl_alloc_formulas af,
             gl_alloc_formula_lines afl,
             gl_ledger_set_assignments lsa,
             gl_ledgers ldg
      WHERE  af.allocation_batch_id = x_allocation_batch_id
      AND    afl.allocation_formula_id = af.allocation_formula_id
      AND    afl.line_number IN (1, 2, 3)
      AND    lsa.ledger_set_id (+) = nvl(afl.ledger_id, x_ledger_override_id)
      AND    sysdate BETWEEN
                     nvl(trunc(lsa.start_date), sysdate - 1)
                 AND nvl(trunc(lsa.end_date), sysdate + 1)
      AND    ldg.ledger_id = nvl(lsa.ledger_id,
                                 nvl(afl.ledger_id, x_ledger_override_id))
      AND    ldg.object_type_code = 'L';

    CURSOR random_to_ledger IS
      SELECT ldg.ledger_id
      FROM   gl_alloc_formulas af,
             gl_alloc_formula_lines afl,
             gl_ledger_set_assignments lsa,
             gl_ledgers ldg
      WHERE  af.allocation_batch_id = x_allocation_batch_id
      AND    afl.allocation_formula_id = af.allocation_formula_id
      AND    afl.line_number IN (4, 5)
      AND    lsa.ledger_set_id (+) = nvl(afl.ledger_id, x_ledger_override_id)
      AND    sysdate BETWEEN
                     nvl(trunc(lsa.start_date), sysdate - 1)
                 AND nvl(trunc(lsa.end_date), sysdate + 1)
      AND    ldg.ledger_id = nvl(lsa.ledger_id,
                                 nvl(afl.ledger_id, x_ledger_override_id))
      AND    ldg.object_type_code = 'L';

    CURSOR null_ledger_in_t_o IS
      SELECT 'has null ledger'
      FROM   gl_alloc_formulas af,
             gl_alloc_formula_lines afl
      WHERE  af.allocation_batch_id = x_allocation_batch_id
      AND    af.allocation_formula_id = afl.allocation_formula_id
      AND    afl.line_number IN (4, 5)
      AND    afl.ledger_id IS NULL;

    random_id   NUMBER;
  BEGIN

    IF (x_line_selection = 'ABC') THEN
      OPEN random_abc_ledger;
      FETCH random_abc_ledger INTO random_id;
      CLOSE random_abc_ledger;
    ELSIF (x_line_selection = 'TO') THEN
      OPEN random_to_ledger;
      FETCH random_to_ledger INTO random_id;
      CLOSE random_to_ledger;
    ELSE
      random_id := -1;
    END IF;

    RETURN random_id;
  END set_random_ledger_id;


  FUNCTION validate_calc_effective_date (x_allocation_batch_id NUMBER,
                                         x_check_date DATE,
                                         x_selected_ced DATE) RETURN BOOLEAN IS
    CURSOR ledger_ids (formula_id NUMBER) IS
      SELECT ldg.ledger_id
      FROM   gl_alloc_formula_lines afl,
             gl_ledgers ldg,
             gl_ledger_set_assignments lsa
      WHERE  afl.allocation_formula_id = formula_id
      AND    afl.line_number IN (1, 2, 3)
      AND    afl.ledger_id IS NOT NULL
      AND    lsa.ledger_set_id(+) = afl.ledger_id
      AND    sysdate BETWEEN
                         nvl(trunc(lsa.start_date),sysdate - 1)
                     AND nvl(trunc(lsa.end_date), sysdate + 1)
      AND    ldg.ledger_id = nvl(lsa.ledger_id, afl.ledger_id)
      AND    ldg.object_type_code = 'L';

    CURSOR formulas (num NUMBER) IS
      SELECT allocation_formula_id
      FROM   gl_alloc_formulas
      WHERE  allocation_batch_id = x_allocation_batch_id
      AND    rownum <= num;

    num_formula    NUMBER;
    profile_buffer VARCHAR2(80);
    start_date     DATE;
    end_date       DATE;
  BEGIN
    -- get profile option
    FND_PROFILE.GET('GL_ALLOC_NUMBER_OF_FORMULAS_TO_VALIDATE', profile_buffer);
    num_formula := to_number(profile_buffer);
    if (num_formula IS NULL) then
      num_formula := DEFAULT_NUM_FORMULAS_TO_CHECK;
    end if;

    FOR next_formula IN formulas(num_formula) LOOP
      FOR next_rec IN ledger_ids(next_formula.allocation_formula_id) LOOP

        -- for each ledger id found, check if the selected calculation
        -- effective date falls in its never opened period
        gl_period_statuses_pkg.get_calendar_range(next_rec.ledger_id,
                                                  start_date,
                                                  end_date);
        if (   x_selected_ced > end_date
            OR x_selected_ced < start_date) then
          RETURN FALSE;
        end if;

      END LOOP;
    END LOOP;

    RETURN TRUE;
  END validate_calc_effective_date;


  FUNCTION allow_average_usage(x_allocation_batch_id NUMBER,
                               x_period_end_date DATE,
                               x_ledger_override_id NUMBER) RETURN BOOLEAN IS
    CURSOR non_cons_ledgers (formula_id NUMBER) IS
      SELECT 'non consolidation ledger exist'
      FROM   gl_alloc_formula_lines afl,
             gl_ledgers ldg,
             gl_ledger_set_assignments lsa
      WHERE  afl.allocation_formula_id = formula_id
      AND    afl.line_number IN (4,5)
      AND    lsa.ledger_set_id(+)  = nvl(afl.ledger_id, x_ledger_override_id)
      AND    sysdate BETWEEN
                     nvl(trunc(lsa.start_date), sysdate - 1)
                 AND nvl(trunc(lsa.end_date), sysdate + 1)
      AND    ldg.ledger_id  =  decode(lsa.ledger_id, null,
                                      nvl(afl.ledger_id,x_ledger_override_id),
                                      lsa.ledger_id)
      AND    ldg.consolidation_ledger_flag = 'N'
      AND    ldg.object_type_code = 'L'
      AND    rownum < 2;

    CURSOR formulas (num NUMBER) IS
      SELECT allocation_formula_id
      FROM   gl_alloc_formulas
      WHERE  allocation_batch_id = x_allocation_batch_id
      AND    rownum <= num;

    num_formula     NUMBER;
    profile_buffer  VARCHAR2(80);
    fid             NUMBER;
    dummy           VARCHAR2(40);
  BEGIN
    FND_PROFILE.GET('GL_ALLOC_NUMBER_OF_FORMULAS_TO_VALIDATE', profile_buffer);
    num_formula := to_number(profile_buffer);
    if (num_formula IS NULL) then
      num_formula := DEFAULT_NUM_FORMULAS_TO_CHECK;
    end if;

    FOR formula_rec IN formulas(num_formula) LOOP

      OPEN non_cons_ledgers(formula_rec.allocation_formula_id);
      FETCH non_cons_ledgers INTO dummy;
      if (non_cons_ledgers%FOUND) then
        CLOSE non_cons_ledgers;
        RETURN FALSE;
      else
        CLOSE non_cons_ledgers;
      end if;

    END LOOP;

    RETURN TRUE;
  END allow_average_usage;

END gl_alloc_history_pkg;

/
