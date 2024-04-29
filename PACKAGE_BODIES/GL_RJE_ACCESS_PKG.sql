--------------------------------------------------------
--  DDL for Package Body GL_RJE_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RJE_ACCESS_PKG" AS
/* $Header: glirecab.pls 120.5 2005/05/05 01:19:24 kvora ship $ */

--*******************************************************************

  FUNCTION validate_calc_effective_date (x_batch_id   NUMBER,
                                       x_selected_ced DATE) RETURN BOOLEAN IS
-- x_batch_id is recurring batch id, x_selected_ced is the calculation
-- effective date

  CURSOR formulas (num NUMBER) IS
    SELECT  recurring_header_id
      FROM  gl_recurring_headers
     WHERE  recurring_batch_id = x_batch_id
       AND  rownum <= num;

    num_formula    NUMBER;
    Lgr_id         NUMBER;
    profile_buffer VARCHAR2(80);
    start_date     DATE;
    end_date       DATE;
    DEFAULT_NUM_FORMULAS_TO_CHECK	CONSTANT NUMBER := 5;

  BEGIN
    -- get profile option
    FND_PROFILE.GET('GL_RJE_NUMBER_OF_FORMULAS_TO_VALIDATE', profile_buffer);
    num_formula := to_number(profile_buffer);
    if (num_formula IS NULL) then
      num_formula := DEFAULT_NUM_FORMULAS_TO_CHECK;
    end if;

    FOR next_formula IN formulas(num_formula) LOOP

      SELECT   nvl(ru.ledger_id, hd.ledger_id)
        INTO   lgr_id
        FROM   gl_recurring_line_calc_rules ru, gl_recurring_headers hd
       WHERE   hd.recurring_header_id = next_formula.recurring_header_id
         AND   hd.recurring_header_id = ru.recurring_header_id(+)
         AND   rownum <2;

-- for each ledger id found, check if the selected calculation
-- effective date falls in its never opened period

        gl_period_statuses_pkg.get_calendar_range(lgr_id,
                                                  start_date,
                                                  end_date);
        if (x_selected_ced > end_date
            OR x_selected_ced < start_date) then
          RETURN FALSE;
        end if;
    END LOOP;

    RETURN TRUE;
  END validate_calc_effective_date;

--********************************************************************

  FUNCTION allow_average_usage(x_batch_id NUMBER) RETURN BOOLEAN IS

  CURSOR non_cons_ledgers (formula_id NUMBER) IS
      SELECT 'non consolidation ledger exist'
      FROM   gl_recurring_headers hd,
             gl_ledgers lgr
      WHERE  hd.recurring_header_id = formula_id
      AND    lgr.ledger_id  =  hd.ledger_id
      AND    lgr.consolidation_ledger_flag = 'N'
      AND    rownum < 2;

  CURSOR formulas (num NUMBER) IS
      SELECT recurring_header_id
      FROM   gl_recurring_headers
      WHERE  recurring_batch_id = x_batch_id
      AND    rownum <= num;


    DEFAULT_NUM_FORMULAS_TO_CHECK	CONSTANT NUMBER := 5;
    num_formula     NUMBER;
    profile_buffer  VARCHAR2(80);
    dummy           VARCHAR2(40);

  BEGIN
    FND_PROFILE.GET('GL_RJE_NUMBER_OF_FORMULAS_TO_VALIDATE', profile_buffer);
    num_formula := to_number(profile_buffer);
    if (num_formula IS NULL) then
      num_formula := DEFAULT_NUM_FORMULAS_TO_CHECK;
    end if;

    FOR formula_rec IN formulas(num_formula) LOOP

    OPEN non_cons_ledgers(formula_rec.recurring_header_id);
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

--************************************************************************

  FUNCTION set_random_ledger_id (x_allocation_batch_id NUMBER) RETURN NUMBER IS
    CURSOR random_ledger IS
    SELECT  ledger_id
      FROM  gl_recurring_headers
     WHERE  recurring_batch_id = x_allocation_batch_id;

     random_ledger_id      NUMBER;
  BEGIN
    OPEN  random_ledger;
    FETCH random_ledger INTO random_ledger_id;

       CLOSE random_ledger;
       RETURN( random_ledger_id );

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RJE_ACCESS_PKG.set_random_ledger_id');
      RAISE;

  END set_random_ledger_id;

END GL_RJE_ACCESS_PKG;

/
