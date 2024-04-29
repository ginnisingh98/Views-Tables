--------------------------------------------------------
--  DDL for Package Body GL_DATE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DATE_HANDLER_PKG" as
/* $Header: glustdtb.pls 120.5 2005/05/05 01:44:30 kvora ship $ */

  ---
  --- PUBLIC FUNCTIONS
  ---

  PROCEDURE find_active_period(	lgr_id			NUMBER,
				calendar		VARCHAR2,
				per_type		VARCHAR2,
				active_date		DATE,
				active_period	IN OUT NOCOPY	VARCHAR2,
				per_start_date	IN OUT NOCOPY	DATE,
				per_end_date	IN OUT NOCOPY	DATE,
				per_number	IN OUT NOCOPY  NUMBER,
				per_year	IN OUT NOCOPY	NUMBER
			      ) IS

    x_active_period	VARCHAR2(15);
    x_per_start_date	DATE;
    x_per_end_date	DATE;
    x_per_number	NUMBER;
    x_per_year		NUMBER;
    period_status	VARCHAR2(1);

    CURSOR find_period IS
      SELECT ps.period_name, ps.start_date, ps.end_date, ps.period_num,
	     ps.period_year
      FROM   gl_period_statuses ps
      WHERE  ps.application_id = 101
      AND    ps.ledger_id = lgr_id
      AND    ps.start_date <= trunc(active_date)
      AND    ps.end_date   >= trunc(active_date)
      AND    ps.closing_status IN ('O', 'F')
      ORDER BY ps.effective_period_num ASC;

  BEGIN
    -- First, see if the nonadjusting period that contains this
    -- date is open
    SELECT ps.period_name, ps.closing_status, ps.start_date, ps.end_date,
	   ps.period_num, ps.period_year
    INTO x_active_period, period_status, x_per_start_date, x_per_end_date,
	 x_per_number, x_per_year
    FROM gl_date_period_map map, gl_period_statuses ps
    WHERE map.period_set_name = calendar
    AND   map.period_type = per_type
    AND   map.accounting_date = trunc(active_date)
    AND   ps.application_id = 101
    AND   ps.ledger_id = lgr_id
    AND   ps.period_name = map.period_name;

    IF (period_status NOT IN ('O', 'F')) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    active_period := x_active_period;
    per_start_date := x_per_start_date;
    per_end_date := x_per_end_date;
    per_number := x_per_number;
    per_year := x_per_year;

    RETURN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- Search for an adjusting period that is open or future enterable
      OPEN find_period;
      FETCH find_period INTO x_active_period, x_per_start_date, x_per_end_date,
			     x_per_number, x_per_year;

      IF (find_period%NOTFOUND) THEN
        CLOSE find_period;
        fnd_message.set_name('SQLGL', 'GL_JE_NOT_OPEN_OR_FUTURE_ENT');
        app_exception.raise_exception;
      END IF;

      CLOSE find_period;

      active_period := x_active_period;
      per_start_date := x_per_start_date;
      per_end_date := x_per_end_date;
      per_number := x_per_number;
      per_year := x_per_year;
  END find_active_period;

  PROCEDURE find_enc_period(	lgr_id			NUMBER,
				calendar		VARCHAR2,
				per_type		VARCHAR2,
				active_date		DATE,
				active_period	IN OUT NOCOPY	VARCHAR2,
				per_start_date	IN OUT NOCOPY	DATE,
				per_end_date	IN OUT NOCOPY	DATE,
				per_number	IN OUT NOCOPY  NUMBER,
				per_year	IN OUT NOCOPY	NUMBER
			      ) IS

    x_active_period	VARCHAR2(15);
    x_per_start_date	DATE;
    x_per_end_date	DATE;
    x_per_number	NUMBER;
    x_per_year		NUMBER;
    x_latest_year       NUMBER;
    period_status	VARCHAR2(1);

    CURSOR find_period IS
      SELECT ps.period_name, ps.start_date, ps.end_date, ps.period_num,
	     ps.period_year
      FROM   gl_period_statuses ps
      WHERE  ps.application_id = 101
      AND    ps.ledger_id = lgr_id
      AND    ps.start_date <= trunc(active_date)
      AND    ps.end_date   >= trunc(active_date)
      AND    ps.period_year <= x_latest_year
      ORDER BY ps.effective_period_num ASC;

  BEGIN
    SELECT latest_encumbrance_year
    INTO   x_latest_year
    FROM   gl_ledgers
    WHERE  ledger_id = lgr_id;

    -- First, see if the non-adjusting period that contains this
    -- date is within
    SELECT ps.period_name, ps.start_date, ps.end_date,
	   ps.period_num, ps.period_year
    INTO x_active_period, x_per_start_date, x_per_end_date,
	 x_per_number, x_per_year
    FROM gl_date_period_map map, gl_period_statuses ps
    WHERE map.period_set_name = calendar
    AND   map.period_type = per_type
    AND   map.accounting_date = trunc(active_date)
    AND   ps.application_id = 101
    AND   ps.ledger_id = lgr_id
    AND   ps.period_name = map.period_name;

    IF (x_per_year > x_latest_year) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    active_period := x_active_period;
    per_start_date := x_per_start_date;
    per_end_date := x_per_end_date;
    per_number := x_per_number;
    per_year := x_per_year;

    RETURN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- Search for an adjusting period that is open or future enterable
      OPEN find_period;
      FETCH find_period INTO x_active_period, x_per_start_date, x_per_end_date,
			     x_per_number, x_per_year;

      IF (find_period%NOTFOUND) THEN
        CLOSE find_period;
        fnd_message.set_name('SQLGL', 'GL_JE_NOT_OPEN_ENC_YEAR');
        app_exception.raise_exception;
      END IF;

      CLOSE find_period;

      active_period := x_active_period;
      per_start_date := x_per_start_date;
      per_end_date := x_per_end_date;
      per_number := x_per_number;
      per_year := x_per_year;
  END find_enc_period;

  PROCEDURE find_enc_period_batch(
				batch_id		NUMBER,
				calendar		VARCHAR2,
				per_type		VARCHAR2,
				active_date		DATE,
				active_period	IN OUT NOCOPY	VARCHAR2,
				per_start_date	IN OUT NOCOPY	DATE,
				per_end_date	IN OUT NOCOPY	DATE,
				per_number	IN OUT NOCOPY  NUMBER,
				per_year	IN OUT NOCOPY	NUMBER
			      ) IS

    x_active_period	VARCHAR2(15);
    x_per_start_date	DATE;
    x_per_end_date	DATE;
    x_per_number	NUMBER;
    x_per_year		NUMBER;
    period_status	VARCHAR2(1);

    one_ledger_id       NUMBER;
    one_latest_year     NUMBER;

    CURSOR find_period IS
      SELECT ps.period_name, ps.start_date, ps.end_date, ps.period_num,
	     ps.period_year
      FROM   gl_period_statuses ps
      WHERE  ps.application_id = 101
      AND    ps.ledger_id = one_ledger_id
      AND    ps.start_date <= trunc(active_date)
      AND    ps.end_date   >= trunc(active_date)
      AND    ps.period_year <= one_latest_year
      AND    NOT EXISTS
               (SELECT 'not open or future'
                FROM gl_je_headers jeh, gl_ledgers lgr
                WHERE  jeh.je_batch_id = batch_id
                AND    lgr.ledger_id = jeh.ledger_id
                AND    nvl(lgr.latest_encumbrance_year,-1) < ps.period_year)
      ORDER BY ps.effective_period_num ASC;

  BEGIN
    SELECT lgr.ledger_id, lgr.latest_encumbrance_year
    INTO   one_ledger_id, one_latest_year
    FROM   gl_je_headers jeh, gl_ledgers lgr
    WHERE  jeh.je_batch_id = batch_id
    AND    lgr.ledger_id = jeh.ledger_id
    AND    rownum = 1;

    -- First, see if the non-adjusting period that contains this
    -- date has a valid year
    SELECT ps.period_name, ps.start_date, ps.end_date,
	   ps.period_num, ps.period_year
    INTO x_active_period, x_per_start_date, x_per_end_date,
	 x_per_number, x_per_year
    FROM gl_date_period_map map, gl_period_statuses ps
    WHERE map.period_set_name = calendar
    AND   map.period_type = per_type
    AND   map.accounting_date = trunc(active_date)
    AND   ps.application_id = 101
    AND   ps.ledger_id = one_ledger_id
    AND   ps.period_name = map.period_name
    AND   ps.period_year <= one_latest_year
    AND   NOT EXISTS
             (SELECT 'not open or future'
              FROM gl_je_headers jeh, gl_ledgers lgr
              WHERE  jeh.je_batch_id = batch_id
              AND    lgr.ledger_id = jeh.ledger_id
              AND    nvl(lgr.latest_encumbrance_year,-1) < ps.period_year);

    IF (x_per_year > one_latest_year) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    active_period := x_active_period;
    per_start_date := x_per_start_date;
    per_end_date := x_per_end_date;
    per_number := x_per_number;
    per_year := x_per_year;

    RETURN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- Search for an adjusting period that is open or future enterable
      OPEN find_period;
      FETCH find_period INTO x_active_period, x_per_start_date, x_per_end_date,
			     x_per_number, x_per_year;

      IF (find_period%NOTFOUND) THEN
        CLOSE find_period;
        fnd_message.set_name('SQLGL', 'GL_JE_NOT_OPEN_ENC_YEAR');
        app_exception.raise_exception;
      END IF;

      CLOSE find_period;

      active_period := x_active_period;
      per_start_date := x_per_start_date;
      per_end_date := x_per_end_date;
      per_number := x_per_number;
      per_year := x_per_year;
  END find_enc_period_batch;

  PROCEDURE validate_date(lgr_id				NUMBER,
			  roll_date				VARCHAR2,
			  initial_accounting_date		DATE,
                          minimum_date				DATE,
                          minimum_period			VARCHAR2,
			  period_name			IN OUT NOCOPY	VARCHAR2,
			  start_date			IN OUT NOCOPY  DATE,
			  end_date			IN OUT NOCOPY  DATE,
			  period_num			IN OUT NOCOPY  NUMBER,
			  period_year			IN OUT NOCOPY  NUMBER,
			  rolled_accounting_date	IN OUT NOCOPY  DATE) IS

    got_period 		BOOLEAN;

    acct_cal_name	VARCHAR2(15);
    trans_cal_id	NUMBER;
    business_day        VARCHAR2(1);
    period_status       VARCHAR2(1);
    new_accounting_date DATE;
    acc_period_type     VARCHAR2(15);

    period_start_date   DATE;
    period_end_date     DATE;
    tmp_num             NUMBER;
    tmp_year            NUMBER;

    x_period_name       VARCHAR2(15);
    min_eff_period_num  NUMBER := 0;

    CURSOR find_period IS
      SELECT ps.period_name, ps.start_date, ps.end_date, ps.period_year,
             ps.period_num
      FROM   gl_period_statuses ps
      WHERE  ps.application_id = 101
      AND    ps.ledger_id = lgr_id
      AND    ps.start_date <= trunc(initial_accounting_date)
      AND    ps.end_date   >= trunc(initial_accounting_date)
      AND    ps.closing_status IN ('O', 'F')
      AND    ps.effective_period_num >= min_eff_period_num
      ORDER BY ps.effective_period_num ASC;
  BEGIN

    -- Get the ledger information
    SELECT period_set_name, transaction_calendar_id, accounted_period_type
    INTO   acct_cal_name, trans_cal_id, acc_period_type
    FROM   gl_ledgers
    WHERE  ledger_id = lgr_id;

    -- Determine the status of the period
    BEGIN
      IF (period_name IS NULL) THEN

        IF (minimum_period IS NOT NULL) THEN
          SELECT effective_period_num
          INTO   min_eff_period_num
          FROM   gl_period_statuses
          WHERE  application_id = 101
          AND    ledger_id = lgr_id
          AND    period_name = minimum_period;
        END IF;

        SELECT ps.period_name, ps.closing_status, ps.start_date, ps.end_date,
               ps.period_year, ps.period_num
        INTO   x_period_name, period_status, period_start_date,
               period_end_date, tmp_year, tmp_num
        FROM   gl_date_period_map map, gl_period_statuses ps
        WHERE  map.period_set_name = acct_cal_name
        AND    map.period_type = acc_period_type
        AND    map.accounting_date = initial_accounting_date
        AND    ps.application_id = 101
        AND    ps.ledger_id = lgr_id
        AND    ps.period_name = map.period_name
        AND    ps.effective_period_num >= min_eff_period_num;

        IF (period_status NOT IN ('O', 'F')) THEN
          RAISE NO_DATA_FOUND;
        ELSE
          period_name := x_period_name;
          start_date  := period_start_date;
          end_date    := period_end_date;
          period_year := tmp_year;
          period_num  := tmp_num;
        END IF;
      ELSE
        x_period_name := period_name;
        SELECT ps.closing_status, ps.start_date, ps.end_date,
               ps.period_year, ps.period_num
        INTO   period_status, period_start_date, period_end_date,
               tmp_year, tmp_num
        FROM   gl_period_statuses ps
        WHERE  ps.application_id = 101
        AND    ps.ledger_id = lgr_id
        AND    ps.period_name = x_period_name
        AND    ps.effective_period_num >= min_eff_period_num;

        start_date := period_start_date;
        end_date   := period_end_date;
        period_year := tmp_year;
        period_num  := tmp_num;

        IF (period_status NOT IN ('O', 'F')) THEN
          fnd_message.set_name('SQLGL', 'GL_JE_NOT_OPEN_OR_FUTURE_ENT');
          app_exception.raise_exception;
        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Search for an adjusting period that is open or future enterable
        OPEN find_period;
        FETCH find_period INTO x_period_name, period_start_date,
                               period_end_date, tmp_year, tmp_num;
        IF find_period%FOUND THEN
          CLOSE find_period;
        ELSE
          CLOSE find_period;
          fnd_message.set_name('SQLGL', 'GL_JE_NOT_OPEN_OR_FUTURE_ENT');
          app_exception.raise_exception;
        END IF;

        period_name := x_period_name;
        start_date  := period_start_date;
        end_date    := period_end_date;
        period_year := tmp_year;
        period_num  := tmp_num;
    END;

    -- Determine if the day is a business day
    BEGIN
      SELECT business_day_flag
      INTO   business_day
      FROM   gl_transaction_dates
      WHERE  transaction_calendar_id = trans_cal_id
      AND    transaction_date = initial_accounting_date;

      IF (business_day = 'Y') THEN
        rolled_accounting_date := initial_accounting_date;
        RETURN;
      ELSIF (roll_date <> 'Y') THEN
        fnd_message.set_name('SQLGL', 'GL_JE_NOT_BUSINESS_DAY');
        app_exception.raise_exception;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('SQLGL', 'GL_JE_NOT_OPEN_OR_FUTURE_ENT');
        app_exception.raise_exception;
    END;

    -- Roll the date back to a business day
    BEGIN
      SELECT max(transaction_date)
      INTO   new_accounting_date
      FROM   gl_transaction_dates trans
      WHERE  trans.transaction_calendar_id = trans_cal_id
      AND    trans.transaction_date >= greatest(period_start_date,
                                                nvl(minimum_date,
                                                    period_start_date))
      AND    trans.business_day_flag = 'Y'
      AND    trans.transaction_date < initial_accounting_date;

      IF (new_accounting_date IS NOT NULL) THEN
        rolled_accounting_date := new_accounting_date;
        RETURN;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;

    -- Roll the date forward to a business day
    BEGIN
      SELECT min(transaction_date)
      INTO   new_accounting_date
      FROM   gl_transaction_dates trans
      WHERE  trans.transaction_calendar_id = trans_cal_id
      AND    trans.transaction_date <= period_end_date
      AND    trans.business_day_flag = 'Y'
      AND    trans.transaction_date > initial_accounting_date;

      IF (new_accounting_date IS NOT NULL) THEN
        rolled_accounting_date := new_accounting_date;
        RETURN;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        rolled_accounting_date := null;
    END;

  END validate_date;


  PROCEDURE validate_date_batch(
                          batch_id				NUMBER,
			  roll_date				VARCHAR2,
			  initial_accounting_date		DATE,
                          minimum_date				DATE,
                          minimum_period			VARCHAR2,
			  period_name			IN OUT NOCOPY	VARCHAR2,
			  start_date			IN OUT NOCOPY  DATE,
			  end_date			IN OUT NOCOPY  DATE,
			  period_num			IN OUT NOCOPY  NUMBER,
			  period_year			IN OUT NOCOPY  NUMBER,
			  rolled_accounting_date	IN OUT NOCOPY  DATE) IS

    got_period 		BOOLEAN;

    acct_cal_name	VARCHAR2(15);
    business_day        VARCHAR2(1);
    period_status       VARCHAR2(1);
    new_accounting_date DATE;
    acc_period_type     VARCHAR2(15);
    roll_dates          VARCHAR2(1);

    period_start_date   DATE;
    period_end_date     DATE;
    tmp_num             NUMBER;
    tmp_year            NUMBER;

    one_ledger_id       NUMBER;
    one_trans_cal_id    NUMBER;

    x_period_name       VARCHAR2(15);
    min_eff_period_num  NUMBER := 0;

    CURSOR find_period IS
      SELECT ps.period_name, ps.start_date, ps.end_date, ps.period_year,
             ps.period_num
      FROM   gl_period_statuses ps
      WHERE  ps.application_id = 101
      AND    ps.ledger_id = one_ledger_id
      AND    ps.start_date <= trunc(initial_accounting_date)
      AND    ps.end_date   >= trunc(initial_accounting_date)
      AND    ps.effective_period_num >= min_eff_period_num
      AND    ps.closing_status IN ('O', 'F')
      AND    NOT EXISTS
               (SELECT 'not open or future'
                FROM gl_je_headers jeh, gl_period_statuses ps2
                WHERE  jeh.je_batch_id = batch_id
                AND    ps2.application_id = 101
                AND    ps2.ledger_id = jeh.ledger_id
                AND    ps2.period_name = ps.period_name
                AND    ps2.closing_status NOT IN ('O', 'F'))
      ORDER BY ps.effective_period_num ASC;
  BEGIN

    -- Get the ledger information
    SELECT min(lgr.period_set_name), min(lgr.accounted_period_type),
           min(lgr.transaction_calendar_id), min(lgr.ledger_id)
    INTO   acct_cal_name, acc_period_type, one_trans_cal_id, one_ledger_id
    FROM   gl_je_headers jeh, gl_ledgers lgr
    WHERE  jeh.je_batch_id = batch_id
    AND    lgr.ledger_id = jeh.ledger_id;

    -- Get information for one ledger and transaction calendar
    -- Determine the status of the period
    BEGIN
      IF (period_name IS NULL) THEN

        IF (minimum_period IS NOT NULL) THEN
          SELECT period_year * 10000 + period_num
          INTO   min_eff_period_num
          FROM   gl_periods
          WHERE  period_set_name = acct_cal_name
          AND    period_type = acc_period_type
          AND    period_name = minimum_period;
        END IF;

        SELECT ps.period_name, ps.closing_status, ps.start_date, ps.end_date,
               ps.period_year, ps.period_num
        INTO   x_period_name, period_status, period_start_date,
               period_end_date, tmp_year, tmp_num
        FROM   gl_date_period_map map, gl_period_statuses ps
        WHERE  map.period_set_name = acct_cal_name
        AND    map.period_type = acc_period_type
        AND    map.accounting_date = initial_accounting_date
        AND    ps.application_id = 101
        AND    ps.ledger_id = one_ledger_id
        AND    ps.period_name = map.period_name
        AND    ps.effective_period_num >= min_eff_period_num
        AND    ps.closing_status IN ('O', 'F')
        AND    NOT EXISTS
                 (SELECT 'not open or future'
                  FROM gl_je_headers jeh, gl_period_statuses ps2
                  WHERE  jeh.je_batch_id = batch_id
                  AND    ps2.application_id = 101
                  AND    ps2.ledger_id = jeh.ledger_id
                  AND    ps2.period_name = ps.period_name
                  AND    ps2.closing_status NOT IN ('O', 'F'));

        IF (period_status NOT IN ('O', 'F')) THEN
          RAISE NO_DATA_FOUND;
        ELSE
          period_name := x_period_name;
          start_date  := period_start_date;
          end_date    := period_end_date;
          period_year := tmp_year;
          period_num  := tmp_num;
        END IF;
      ELSE
        x_period_name := period_name;
        SELECT ps.closing_status, ps.start_date, ps.end_date,
               ps.period_year, ps.period_num
        INTO   period_status, period_start_date, period_end_date,
               tmp_year, tmp_num
        FROM   gl_period_statuses ps
        WHERE  ps.application_id = 101
        AND    ps.ledger_id = one_ledger_id
        AND    ps.period_name = x_period_name
        AND    ps.effective_period_num >= min_eff_period_num
        AND    ps.closing_status IN ('O', 'F')
        AND    NOT EXISTS
                 (SELECT 'not open or future'
                  FROM gl_je_headers jeh, gl_period_statuses ps2
                  WHERE  jeh.je_batch_id = batch_id
                  AND    ps2.application_id = 101
                  AND    ps2.ledger_id = jeh.ledger_id
                  AND    ps2.period_name = ps.period_name
                  AND    ps2.closing_status NOT IN ('O', 'F'));

        start_date := period_start_date;
        end_date   := period_end_date;
        period_year := tmp_year;
        period_num  := tmp_num;

        IF (period_status NOT IN ('O', 'F')) THEN
          fnd_message.set_name('SQLGL', 'GL_JE_NOT_OPEN_OR_FUTURE_ENT');
          app_exception.raise_exception;
        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Search for an adjusting period that is open or future enterable
        OPEN find_period;
        FETCH find_period INTO x_period_name, period_start_date,
                               period_end_date, tmp_year, tmp_num;
        IF find_period%FOUND THEN
          CLOSE find_period;
        ELSE
          CLOSE find_period;
          fnd_message.set_name('SQLGL', 'GL_JE_NOT_OPEN_OR_FUTURE_ENT');
          app_exception.raise_exception;
        END IF;

        period_name := x_period_name;
        start_date  := period_start_date;
        end_date    := period_end_date;
        period_year := tmp_year;
        period_num  := tmp_num;
    END;

    -- Determine if we need to roll dates
    BEGIN
      roll_dates := 'N';

      SELECT nvl(max('Y'),'N')
      INTO roll_dates
      FROM gl_je_headers jeh, gl_ledgers lgr
      WHERE jeh.je_batch_id = batch_id
      AND   lgr.ledger_id = jeh.ledger_id
      AND   lgr.enable_average_balances_flag = 'Y'
      AND   lgr.consolidation_ledger_flag = 'N'
      AND   rownum = 1;

      IF (roll_dates = 'N') THEN
        rolled_accounting_date := initial_accounting_date;
        RETURN;
      END IF;
    END;

    -- Determine if the day is a business day
    BEGIN
      SELECT decode(min(decode(business_day_flag, 'Y', 1, 0)),1, 'Y', 'N')
      INTO   business_day
      FROM   gl_transaction_dates
      WHERE  transaction_calendar_id
               IN (SELECT transaction_calendar_id
                   FROM gl_je_headers jeh, gl_ledgers lgr
                   WHERE jeh.je_batch_id = batch_id
                   AND   lgr.ledger_id = jeh.ledger_id)
      AND    transaction_date = initial_accounting_date;

      IF (business_day = 'Y') THEN
        rolled_accounting_date := initial_accounting_date;
        RETURN;
      ELSIF (roll_date <> 'Y') THEN
        fnd_message.set_name('SQLGL', 'GL_JE_NOT_BUSINESS_DAY');
        app_exception.raise_exception;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('SQLGL', 'GL_JE_NOT_OPEN_OR_FUTURE_ENT');
        app_exception.raise_exception;
    END;

    -- Roll the date back to a business day
    BEGIN
      SELECT max(transaction_date)
      INTO   new_accounting_date
      FROM   gl_transaction_dates trans
      WHERE  trans.transaction_calendar_id = one_trans_cal_id
      AND    trans.transaction_date >= greatest(period_start_date,
                                                nvl(minimum_date,
                                                    period_start_date))
      AND    trans.business_day_flag = 'Y'
      AND    trans.transaction_date < initial_accounting_date
      AND    NOT EXISTS
               (SELECT 'not business'
                FROM   gl_je_headers jeh, gl_ledgers lgr,
                       gl_transaction_dates trans2
                WHERE  jeh.je_batch_id = batch_id
                AND    lgr.ledger_id = jeh.ledger_id
                AND    trans2.transaction_calendar_id
                         = lgr.transaction_calendar_id
                AND    trans2.business_day_flag = 'N'
                AND    trans2.transaction_date = trans.transaction_date);

      IF (new_accounting_date IS NOT NULL) THEN
        rolled_accounting_date := new_accounting_date;
        RETURN;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;

    -- Roll the date forward to a business day
    BEGIN
      SELECT min(transaction_date)
      INTO   new_accounting_date
      FROM   gl_transaction_dates trans
      WHERE  trans.transaction_calendar_id = one_trans_cal_id
      AND    trans.transaction_date <= period_end_date
      AND    trans.business_day_flag = 'Y'
      AND    trans.transaction_date > initial_accounting_date
      AND    NOT EXISTS
               (SELECT 'not business'
                FROM   gl_je_headers jeh, gl_ledgers lgr,
                       gl_transaction_dates trans2
                WHERE  jeh.je_batch_id = batch_id
                AND    lgr.ledger_id = jeh.ledger_id
                AND    trans2.transaction_calendar_id
                         = lgr.transaction_calendar_id
                AND    trans2.business_day_flag = 'N'
                AND    trans2.transaction_date = trans.transaction_date);

      IF (new_accounting_date IS NOT NULL) THEN
        rolled_accounting_date := new_accounting_date;
        RETURN;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        rolled_accounting_date := null;
    END;

  END validate_date_batch;


  PROCEDURE find_from_period(	lgr_id			NUMBER,
				calendar		VARCHAR2,
				per_type		VARCHAR2,
				active_date		DATE,
				from_period	IN OUT NOCOPY	VARCHAR2,
				per_start_date	IN OUT NOCOPY	DATE,
				per_end_date	IN OUT NOCOPY	DATE,
				per_number	IN OUT NOCOPY  NUMBER,
				per_year	IN OUT NOCOPY	NUMBER
			      ) IS

    x_from_period	VARCHAR2(15);
    x_per_start_date	DATE;
    x_per_end_date	DATE;
    x_per_number	NUMBER;
    x_per_year		NUMBER;
    period_status	VARCHAR2(1);

    CURSOR find_period IS
      SELECT ps.period_name, ps.start_date, ps.end_date, ps.period_num,
	     ps.period_year
      FROM   gl_period_statuses ps
      WHERE  ps.application_id = 101
      AND    ps.ledger_id = lgr_id
      AND    ps.start_date <= trunc(active_date)
      AND    ps.end_date   >= trunc(active_date)
      AND    ps.closing_status IN ('O', 'C', 'P')
      ORDER BY ps.effective_period_num ASC;

  BEGIN
    -- First, see if the non-adjusting period that contains this
    -- date is open, closed or permanently closed.
    SELECT ps.period_name, ps.closing_status, ps.start_date, ps.end_date,
	   ps.period_num, ps.period_year
    INTO x_from_period, period_status, x_per_start_date, x_per_end_date,
	 x_per_number, x_per_year
    FROM gl_date_period_map map, gl_period_statuses ps
    WHERE map.period_set_name = calendar
    AND   map.period_type = per_type
    AND   map.accounting_date = trunc(active_date)
    AND   ps.application_id = 101
    AND   ps.ledger_id = lgr_id
    AND   ps.period_name = map.period_name;

    IF (period_status NOT IN ('O', 'C', 'P')) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    from_period := x_from_period;
    per_start_date := x_per_start_date;
    per_end_date := x_per_end_date;
    per_number := x_per_number;
    per_year := x_per_year;

    RETURN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- Search for an adjusting period that is open, closed or permanently
      -- closed.
      OPEN find_period;
      FETCH find_period INTO x_from_period, x_per_start_date, x_per_end_date,
			     x_per_number, x_per_year;

      IF (find_period%NOTFOUND) THEN
        CLOSE find_period;
        fnd_message.set_name('SQLGL', 'GL_CONS_DATE_NOT_OPEN_CLOSED');
        app_exception.raise_exception;
      END IF;

      CLOSE find_period;

      from_period := x_from_period;
      per_start_date := x_per_start_date;
      per_end_date := x_per_end_date;
      per_number := x_per_number;
      per_year := x_per_year;
  END find_from_period;


END GL_DATE_HANDLER_PKG;

/
