--------------------------------------------------------
--  DDL for Package Body GL_SRS_INCREMENTOR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SRS_INCREMENTOR_API" AS
/* $Header: gluschpb.pls 120.10 2005/05/05 01:43:31 kvora ship $ */

-- public functions

------------------------------------------------------
--  Increment Journal date by business days offset method
--  then find corresponding period
------------------------------------------------------
   FUNCTION increment_bus_date(
      x_ledger_id             NUMBER,
      x_last_anchor_date            DATE,
      x_last_para_date              DATE,
      x_new_anchor_date             DATE,
      x_new_para_date      IN OUT NOCOPY   DATE,
      x_new_para_period    IN OUT NOCOPY   VARCHAR2)
      RETURN NUMBER IS
      cant_find_bus_day             EXCEPTION;
      not_bus_day                   EXCEPTION;
      --cons_sob_not_allowed          EXCEPTION;
      error_code                    NUMBER;
      days_offset                   NUMBER DEFAULT 0;
      num_rows                      NUMBER DEFAULT 0;
      CURRENT_DATE                  DATE;
      bus_day_flag                  VARCHAR2(1);
      v_trxn_calendar_id            NUMBER(15);
      v_last_anchor_date            DATE := TRUNC(x_last_anchor_date);
      v_last_para_date              DATE := TRUNC(x_last_para_date);
      v_new_anchor_date             DATE := TRUNC(x_new_anchor_date);

      CURSOR get_future_date IS
         SELECT   transaction_date
             FROM gl_transaction_dates
            WHERE transaction_calendar_id = v_trxn_calendar_id
              AND business_day_flag = 'Y'
              AND transaction_date > v_new_anchor_date
         ORDER BY transaction_date ASC;

      CURSOR get_past_date IS
         SELECT   transaction_date
             FROM gl_transaction_dates
            WHERE transaction_calendar_id = v_trxn_calendar_id
              AND business_day_flag = 'Y'
              AND transaction_date < v_new_anchor_date
         ORDER BY transaction_date DESC;

      CURSOR get_bus_day_flag IS
         SELECT business_day_flag
           FROM gl_transaction_dates
          WHERE transaction_calendar_id = v_trxn_calendar_id
            AND transaction_date = CURRENT_DATE;
   BEGIN
      --dbms_output.put_line('x_last_anchor_date = '||to_char(V_Last_Anchor_Date));
      --dbms_output.put_line('x_last_para_date = '||to_char(V_Last_Para_Date));
      error_buffer := '';
      error_code := -30;

      SELECT transaction_calendar_id
        INTO v_trxn_calendar_id
        FROM gl_ledgers
       WHERE ledger_id = x_ledger_id;


------------------------------------------------------
-- Exit if the date to increment is not a business day
------------------------------------------------------
      error_code := -20;
      CURRENT_DATE := v_last_para_date;
      OPEN get_bus_day_flag;
      FETCH get_bus_day_flag INTO bus_day_flag;

      IF bus_day_flag <> 'Y' THEN
         RAISE not_bus_day;
      END IF;

      CLOSE get_bus_day_flag;


------------------------------------------------------
--       Increment Date Parameter
------------------------------------------------------
      IF v_last_para_date = v_last_anchor_date THEN
         CURRENT_DATE := v_new_anchor_date;
         OPEN get_bus_day_flag;
         FETCH get_bus_day_flag INTO bus_day_flag;

         IF bus_day_flag <> 'Y' THEN
            RAISE cant_find_bus_day;
         END IF;

         CLOSE get_bus_day_flag;
         CURRENT_DATE := v_new_anchor_date;
      ELSIF v_last_para_date < v_last_anchor_date THEN
         error_code := -21;

         SELECT COUNT(*)
           INTO days_offset
           FROM gl_transaction_dates
          WHERE transaction_calendar_id = v_trxn_calendar_id
            AND business_day_flag = 'Y'
            AND transaction_date >= v_last_para_date
            AND transaction_date < v_last_anchor_date;

         --dbms_output.put_line('d past offset = '||to_char(days_offset));

         error_code := -22;
         OPEN get_past_date;

         LOOP
            FETCH get_past_date INTO CURRENT_DATE;
            EXIT WHEN get_past_date%NOTFOUND;
            num_rows :=   num_rows
                        + 1;
            EXIT WHEN num_rows >= days_offset;
         END LOOP;

         CLOSE get_past_date;
      ELSE
         error_code := -23;

         SELECT COUNT(*)
           INTO days_offset
           FROM gl_transaction_dates
          WHERE transaction_calendar_id = v_trxn_calendar_id
            AND business_day_flag = 'Y'
            AND transaction_date > v_last_anchor_date
            AND transaction_date <= v_last_para_date;

         --dbms_output.put_line('d offset = '||to_char(days_offset));

         error_code := -24;
         OPEN get_future_date;

         LOOP
            FETCH get_future_date INTO CURRENT_DATE;
            EXIT WHEN get_future_date%NOTFOUND;
            num_rows :=   num_rows
                        + 1;
            EXIT WHEN num_rows >= days_offset;
         END LOOP;

         CLOSE get_future_date;
      END IF;

      IF num_rows = days_offset THEN
         x_new_para_date := TRUNC(CURRENT_DATE);
      ELSE
         RAISE cant_find_bus_day;
      END IF;


----------------------------------------------------------
--   Get the corresponding period for the incremented date
----------------------------------------------------------
      error_code := -25;

      SELECT period_name
        INTO x_new_para_period
        FROM gl_date_period_map m, gl_ledgers b
       WHERE m.period_set_name = b.period_set_name
         AND m.period_type = b.accounted_period_type
         AND b.ledger_id = x_ledger_id
         AND m.accounting_date = x_new_para_date;

      RETURN (1);
   EXCEPTION
      WHEN not_bus_day THEN
         -- Cannot increment the day DAY because it is not a business day
         fnd_message.set_name('SQLGL', 'GL_SCH_INC_NONBUS_DATE');
         fnd_message.set_token('DAY', TO_CHAR(v_last_para_date, 'DD-MON-YYYY'));
         error_buffer := fnd_message.get;
         RETURN error_code;
      WHEN cant_find_bus_day THEN
         -- Cannot find a business day to use for the next request after incrementing DAY
         fnd_message.set_name('SQLGL', 'GL_SCH_INC_NO_NEXT_DAY');
         fnd_message.set_token('DAY', TO_CHAR(v_last_para_date, 'DD-MON-YYYY'));
         error_buffer := fnd_message.get;
         RETURN error_code;
      WHEN OTHERS THEN
         error_buffer :=    'gl_srs_incrementor_api error #'
                         || TO_CHAR(error_code)
                         || ': ( Last Anchor Date='
                         || TO_CHAR(v_last_anchor_date, 'DD-MON-YYYY')
                         || 'This Anchor Date='
                         || TO_CHAR(v_new_anchor_date, 'DD-MON-YYYY')
                         || 'This Date='
                         || TO_CHAR(x_new_para_date, 'DD-MON-YYYY')
                         || ' ) '
                         || SUBSTR(SQLERRM, 1, 50);
         RETURN error_code;
   END increment_bus_date;


------------------------------------------------------
--  Increment Period using journals days offset method
--    This method is used for Non-ADB and ADB consolidation
--    ledgers.
------------------------------------------------------
   FUNCTION inc_period_by_days_offset(
      x_ledger_id                      NUMBER,
      x_start_date_last_run            DATE,
      x_period_last_run                VARCHAR2,
      x_start_date_this_run            DATE,
      x_period_this_run       IN OUT NOCOPY   VARCHAR2)
      RETURN NUMBER IS
      no_period_this_run            EXCEPTION;
      error_code                    NUMBER;
      dummy                         VARCHAR2(15);
      l_eff_period_num              NUMBER;
      l_start_period_num            NUMBER;
      c_start_period_num            NUMBER;
      is_future                     BOOLEAN;
      num_rows                      NUMBER DEFAULT 0;
      period_offset                 NUMBER DEFAULT 0;
      current_period                VARCHAR2(15);
      c_start_period                VARCHAR2(15);

      CURSOR get_future_period_this_run IS
         SELECT   period_name
             FROM gl_period_statuses
            WHERE application_id = 101
              AND ledger_id = x_ledger_id
              AND adjustment_period_flag = 'N'
              AND effective_period_num >= c_start_period_num
         ORDER BY effective_period_num ASC;

      CURSOR get_past_period_this_run IS
         SELECT   period_name
             FROM gl_period_statuses
            WHERE application_id = 101
              AND ledger_id = x_ledger_id
              AND adjustment_period_flag = 'N'
              AND effective_period_num <= c_start_period_num
         ORDER BY effective_period_num DESC;
   BEGIN
      -- dbms_output.put_line('X_last_start_date='||to_char(X_Start_Date_Last_Run));
      -- dbms_output.put_line('X_last_period='||X_Period_Last_Run);
      -- dbms_output.put_line('X_this_start_date='||to_char(X_Start_Date_this_Run));

      error_buffer := '';
      -- Get period info of last run period
      error_code := -11;

      SELECT effective_period_num
        INTO l_eff_period_num
        FROM gl_period_statuses p
       WHERE p.application_id = 101
         AND p.ledger_id = x_ledger_id
         AND p.period_name = x_period_last_run
         AND p.adjustment_period_flag = 'N';

      --  Get period of last start run date
      --  We add 0.99998843 to the end_date because the dates are stored with their
      --  timestamp information truncated in GL_PERIOD_STATUSES. This means that
      --  a daily period will have exactly the same start date/time and end
      --  date/time. Since the scheduling feature is extremely time sensitive,
      --  we need to add the timestamp while retrieving the value from the table.
      --  0.99998843 stands for 23 Hours, 59 Minutes and 59 seconds.
      error_code := -12;

      SELECT effective_period_num, period_name
        INTO l_start_period_num, dummy
        FROM gl_period_statuses p
       WHERE p.application_id = 101
         AND p.ledger_id = x_ledger_id
         AND x_start_date_last_run BETWEEN p.start_date
                                       AND   p.end_date
                                           + 0.99998843
         AND p.adjustment_period_flag = 'N';

      -- dbms_output.put_line('last start = '||dummy);
      -- dbms_output.put_line('last start num = '||to_char(l_start_period_num));

      --  Get period of current start run date
      --  We add 0.99998843 to the end_date because the dates are stored with their
      --  timestamp information truncated in GL_PERIOD_STATUSES. This means that
      --  a daily period will have exactly the same start date/time and end
      --  date/time. Since the scheduling feature is extremely time sensitive,
      --  we need to add the timestamp while retrieving the value from the table.
      --  0.99998843 stands for 23 Hours, 59 Minutes and 59 seconds.
      error_code := -13;

      SELECT effective_period_num, period_name
        INTO c_start_period_num, c_start_period
        FROM gl_period_statuses p
       WHERE p.application_id = 101
         AND p.ledger_id = x_ledger_id
         AND x_start_date_this_run BETWEEN p.start_date
                                       AND   p.end_date
                                           + 0.99998843
         AND p.adjustment_period_flag = 'N';

      -- dbms_output.put_line('current start = '||c_start_period);
      -- dbms_output.put_line('current start num = '||to_char(c_start_period_num));

      -- Calculate period increment
      error_code := -14;

      IF l_eff_period_num = l_start_period_num THEN
         x_period_this_run := c_start_period;
         RETURN (1);
      ELSIF l_eff_period_num > l_start_period_num THEN
         SELECT COUNT(*)
           INTO period_offset
           FROM gl_period_statuses p
          WHERE p.application_id = 101
            AND p.ledger_id = x_ledger_id
            AND p.effective_period_num BETWEEN l_start_period_num
                                           AND l_eff_period_num
            AND p.adjustment_period_flag = 'N';

         is_future := TRUE;
         -- dbms_output.put_line('period_offset = '||to_char(period_offset));

         OPEN get_future_period_this_run;

         LOOP
            FETCH get_future_period_this_run INTO current_period;
            EXIT WHEN get_future_period_this_run%NOTFOUND;
            num_rows :=   num_rows
                        + 1;
            EXIT WHEN num_rows >= period_offset;
         END LOOP;

         CLOSE get_future_period_this_run;
      ELSE
         SELECT COUNT(*)
           INTO period_offset
           FROM gl_period_statuses p
          WHERE p.application_id = 101
            AND p.ledger_id = x_ledger_id
            AND p.effective_period_num BETWEEN l_eff_period_num
                                           AND l_start_period_num
            AND p.adjustment_period_flag = 'N';

         is_future := FALSE;
         -- dbms_output.put_line('period_offset = '||to_char(period_offset));

         OPEN get_past_period_this_run;

         LOOP
            FETCH get_past_period_this_run INTO current_period;
            EXIT WHEN get_past_period_this_run%NOTFOUND;
            num_rows :=   num_rows
                        + 1;
            EXIT WHEN num_rows >= period_offset;
         END LOOP;

         CLOSE get_past_period_this_run;
      END IF;

      IF num_rows = period_offset THEN
         x_period_this_run := current_period;
      ELSE
         RAISE no_period_this_run;
      END IF;

      RETURN (1);
   EXCEPTION
      WHEN no_period_this_run THEN
         -- Cannot find a period to use for the next request after period increment
         error_buffer :=
                   fnd_message.get_string('SQLGL', 'GL_SCH_INC_NO_NEXT_PERIOD');
         RETURN (error_code);
      WHEN OTHERS THEN
         IF error_code = -11 THEN
            -- Cannot increment an adjusting period
            error_buffer :=
                       fnd_message.get_string('SQLGL', 'GL_SCH_INC_ADJ_PERIOD');
            error_buffer :=
                         SUBSTR(error_buffer, 1, 100)
                      || SUBSTR(SQLERRM, 1, 100);
         ELSIF error_code = -12 THEN
            -- The schedule start date DAY must map to a period in your calendar.
            fnd_message.set_name('SQLGL', 'GL_SCH_INC_START_DAY_NO_PERIOD');
            fnd_message.set_token(
               'DAY',
               TO_CHAR(x_start_date_last_run, 'DD-MON-YYYY'));
            error_buffer := fnd_message.get;
            error_buffer :=
                         SUBSTR(error_buffer, 1, 100)
                      || SUBSTR(SQLERRM, 1, 100);
         ELSIF error_code = -13 THEN
            -- The resubmission schedule start date DAY must map
            -- to a period in your calendar.
            fnd_message.set_name('SQLGL', 'GL_SCH_INC_RESUB_DAY_NO_PERIOD');
            fnd_message.set_token(
               'DAY',
               TO_CHAR(x_start_date_this_run, 'DD-MON-YYYY'));
            error_buffer := fnd_message.get;
            error_buffer :=
                         SUBSTR(error_buffer, 1, 100)
                      || SUBSTR(SQLERRM, 1, 100);
         ELSE
            error_buffer :=    'gl_srs_incrementor_api error #'
                            || TO_CHAR(error_code)
                            || ' : '
                            || SUBSTR(SQLERRM, 1, 100);
         END IF;

         RETURN (error_code);
   END inc_period_by_days_offset;


----------------------------------------------------------
--  Increment GL Period and Date for ADB Consolidation ledger
--    Incrementing period for Consolidation ADB ledger is similar
--    to Standard ledger, and the journal date is set to
--    the first day of the period.
----------------------------------------------------------
   PROCEDURE cons_inc_private(
      x_ledger_id        NUMBER,
      x_period_para      VARCHAR2,
      x_je_date_para     VARCHAR2,
      x_calc_date_para   VARCHAR2,
      x_date_format      VARCHAR2) IS
      error_code                    NUMBER;
      v_last_period                 VARCHAR2(15);
      v_period                      VARCHAR2(15);
      v_pstart_date                 DATE;
      v_last_sch_date               DATE;
      v_sch_date                    DATE;
      v_last_je_date                DATE;
      v_je_date                     DATE;
      v_last_calc_date              DATE;
      v_calc_date                   DATE;
      v_days_elapsed                NUMBER;
      period_pnum                   NUMBER;
      je_date_pnum                  NUMBER;
      calc_date_pnum                NUMBER;
      exit_fail                     EXCEPTION;
   BEGIN
      error_buffer := '';
      v_sch_date := fnd_resub.get_requested_start_date;
      v_days_elapsed := fnd_resub.get_rusub_delta;
      v_last_sch_date := TRUNC(  v_sch_date
                               - v_days_elapsed);

      IF fnd_resub.get_param_number(x_period_para, period_pnum) <> 0 THEN
         error_code := -230;
         -- Cannot get parameter number for PARA. Please check your
         -- concurrent program definition
         fnd_message.set_name('SQLGL', 'GL_SCH_INC_GET_PARA_NUM');
         fnd_message.set_token('PARA', x_period_para);
         error_buffer := fnd_message.get;
         RAISE exit_fail;
      END IF;

      v_last_period := fnd_resub.get_parameter(period_pnum);
      error_code := inc_period_by_days_offset(
                       x_ledger_id,
                       v_last_sch_date,
                       v_last_period,
                       v_sch_date,
                       v_period);

      IF error_code < 0 THEN
         RAISE exit_fail;
      END IF;

      fnd_resub.set_parameter(period_pnum, v_period);
      error_code := -200;

      SELECT start_date
        INTO v_pstart_date
        FROM gl_period_statuses
       WHERE application_id = 101
         AND ledger_id = x_ledger_id
         AND period_name = v_period;

      IF fnd_resub.get_param_number(x_je_date_para, je_date_pnum) <> 0 THEN
         error_code := -210;
         fnd_message.set_name('SQLGL', 'GL_SCH_INC_GET_PARA_NUM');
         fnd_message.set_token('PARA', x_je_date_para);
         error_buffer := fnd_message.get;
         RAISE exit_fail;
      ELSE
         IF fnd_resub.get_param_number(x_calc_date_para, calc_date_pnum) <> 0 THEN
            error_code := -220;
            fnd_message.set_name('SQLGL', 'GL_SCH_INC_GET_PARA_NUM');
            fnd_message.set_token('PARA', x_calc_date_para);
            error_buffer := fnd_message.get;
            RAISE exit_fail;
         END IF;
      END IF;

      fnd_resub.set_parameter(
         je_date_pnum,
         TO_CHAR(v_pstart_date, x_date_format));
      fnd_resub.set_parameter(
         calc_date_pnum,
         TO_CHAR(v_pstart_date, x_date_format));
      fnd_resub.return_info(0, error_buffer);
   EXCEPTION
      WHEN exit_fail THEN
         fnd_resub.return_info(error_code, error_buffer);
      WHEN OTHERS THEN
         error_buffer :=    'gl_srs_incrementor_api.cons_inc_private error #'
                         || TO_CHAR(error_code)
                         || ' : '
                         || SUBSTR(SQLERRM, 1, 100);
         fnd_resub.return_info(error_code, error_buffer);
   END cons_inc_private;


------------------------------------------------------
--  Increment GL Period for Standard (Non-ADB) ledger
------------------------------------------------------
   PROCEDURE increment_period(
      x_ledger_id     NUMBER,
      x_period_para   VARCHAR2) IS
      l_value                       fnd_profile_option_values.profile_option_value%TYPE;
      error_code                    NUMBER;
      v_last_period                 VARCHAR2(15);
      v_period                      VARCHAR2(15);
      v_last_sch_date               DATE;
      v_sch_date                    DATE;
      v_days_elapsed                NUMBER;
      period_pnum                   NUMBER;
      exit_fail                     EXCEPTION;
   BEGIN
      error_buffer := '';

      IF fnd_resub.get_increment_flag = 'N' THEN
         fnd_resub.return_info(0, error_buffer);
         RETURN;
      END IF;

      --fnd_profile.get('GL_SET_OF_BKS_ID', l_value);
      --v_sob_id := TO_NUMBER(l_value);
      v_sch_date := fnd_resub.get_requested_start_date;
      v_days_elapsed := fnd_resub.get_rusub_delta;
      v_last_sch_date := TRUNC(  v_sch_date
                               - v_days_elapsed);

      IF fnd_resub.get_param_number(x_period_para, period_pnum) <> 0 THEN
         error_code := -100;
         -- Cannot get parameter number for PARA. Please check your
         -- concurrent program definition
         fnd_message.set_name('SQLGL', 'GL_SCH_INC_GET_PARA_NUM');
         fnd_message.set_token('PARA', x_period_para);
         error_buffer := fnd_message.get;
         RAISE exit_fail;
      END IF;

      v_last_period := fnd_resub.get_parameter(period_pnum);
      error_code := inc_period_by_days_offset(
                       x_ledger_id,
                       v_last_sch_date,
                       v_last_period,
                       v_sch_date,
                       v_period);

      IF error_code >= 0 THEN
         fnd_resub.set_parameter(period_pnum, v_period);
      ELSE
         RAISE exit_fail;
      END IF;

      fnd_resub.return_info(0, error_buffer);
   EXCEPTION
      WHEN exit_fail THEN
         fnd_resub.return_info(error_code, error_buffer);
      WHEN OTHERS THEN
         error_buffer :=    'gl_srs_incrementor_api.increment_period error #'
                         || TO_CHAR(error_code)
                         || ' : '
                         || SUBSTR(SQLERRM, 1, 100);
         fnd_resub.return_info(error_code, error_buffer);
   END increment_period;

   --PROCEDURE increment_period IS
   --BEGIN
   --   increment_period('PERIOD_NAME');
   --END increment_period;


----------------------------------------------------------
--  Increment GL Date and Period for Standard ADB ledger
----------------------------------------------------------
   PROCEDURE increment_adb(
      x_ledger_id           NUMBER,
      x_period_para      VARCHAR2,
      x_je_date_para     VARCHAR2,
      x_calc_date_para   VARCHAR2,
      x_date_format      VARCHAR2) IS
      v_ledger_id                      NUMBER := x_ledger_id;
      error_code                    NUMBER;
      v_period                      VARCHAR2(15);
      dummy                         VARCHAR2(15);
      v_last_sch_date               DATE;
      v_sch_date                    DATE;
      v_last_je_date                DATE;
      v_je_date                     DATE;
      v_last_calc_date              DATE;
      v_calc_date                   DATE;
      v_days_elapsed                NUMBER;
      period_pnum                   NUMBER;
      je_date_pnum                  NUMBER;
      calc_date_pnum                NUMBER;
      exit_fail                     EXCEPTION;
   BEGIN
      error_buffer := '';
      error_code := -300;
      v_sch_date := fnd_resub.get_requested_start_date;
      v_days_elapsed := fnd_resub.get_rusub_delta;
      v_last_sch_date := TRUNC(  v_sch_date
                               - v_days_elapsed);

      IF fnd_resub.get_param_number(x_period_para, period_pnum) <> 0 THEN
         error_code := -310;
         -- Cannot get parameter number for PARA. Please check your
         -- concurrent program definition
         fnd_message.set_name('SQLGL', 'GL_SCH_INC_GET_PARA_NUM');
         fnd_message.set_token('PARA', x_period_para);
         error_buffer := fnd_message.get;
         RAISE exit_fail;
      END IF;

      IF fnd_resub.get_param_number(x_je_date_para, je_date_pnum) <> 0 THEN
         error_code := -320;
         fnd_message.set_name('SQLGL', 'GL_SCH_INC_GET_PARA_NUM');
         fnd_message.set_token('PARA', x_je_date_para);
         error_buffer := fnd_message.get;
         RAISE exit_fail;
      ELSE
         IF fnd_resub.get_param_number(x_calc_date_para, calc_date_pnum) <> 0 THEN
            error_code := -330;
            fnd_message.set_name('SQLGL', 'GL_SCH_INC_GET_PARA_NUM');
            fnd_message.set_token('PARA', x_calc_date_para);
            error_buffer := fnd_message.get;
            RAISE exit_fail;
         END IF;
      END IF;

      v_last_je_date :=
                  TO_DATE(fnd_resub.get_parameter(je_date_pnum), x_date_format);
      v_last_calc_date :=
                TO_DATE(fnd_resub.get_parameter(calc_date_pnum), x_date_format);
      -- Get journal effective date
      error_code := increment_bus_date(
                       v_ledger_id,
                       v_last_sch_date,
                       v_last_je_date,
                       v_sch_date,
                       v_je_date,
                       v_period);

      IF error_code < 0 THEN
         RAISE exit_fail;
      END IF;

      -- Get calculation effective date
      error_code := increment_bus_date(
                       v_ledger_id,
                       v_last_je_date,
                       v_last_calc_date,
                       v_je_date,
                       v_calc_date,
                       dummy);

      IF error_code < 0 THEN
         RAISE exit_fail;
      END IF;

      fnd_resub.set_parameter(period_pnum, v_period);
      fnd_resub.set_parameter(je_date_pnum, TO_CHAR(v_je_date, x_date_format));
      fnd_resub.set_parameter(
         calc_date_pnum,
         TO_CHAR(v_calc_date, x_date_format));
      fnd_resub.return_info(0, error_buffer);
   EXCEPTION
      WHEN exit_fail THEN
         fnd_resub.return_info(error_code, error_buffer);
      WHEN OTHERS THEN
         error_buffer :=    'gl_srs_incrementor_api.incremnt_adb error #'
                         || TO_CHAR(error_code)
                         || ' : '
                         || SUBSTR(SQLERRM, 1, 100);
         fnd_resub.return_info(error_code, error_buffer);
   END increment_adb;

   PROCEDURE increment_parameters IS
      l_value                       fnd_profile_option_values.profile_option_value%TYPE;
      v_adb_ledger_id               NUMBER := NULL;
      v_con_ledger_id               NUMBER := NULL;
      program_name                  VARCHAR2(30);
      application_name              VARCHAR2(30);
      error_code                    NUMBER;
      random_ledger_id              NUMBER;
      current_bid                   NUMBER;
      batch_code                    VARCHAR2(1);
      usage_flag                    VARCHAR2(1);
      con_ledger_flag               VARCHAR2(1) := 'N';
      v_last_period                 VARCHAR2(15);
      v_period                      VARCHAR2(15);
      v_pstart_date                 DATE;
      v_last_sch_date               DATE;

      v_sch_date                    DATE;
      v_last_je_date                DATE;
      v_je_date                     DATE;
      v_last_calc_date              DATE;
      v_calc_date                   DATE;
      v_days_elapsed                NUMBER;
      v_batch_id                    NUMBER;
      v_ledger_id                   NUMBER;
      period_pnum                   NUMBER;
      je_date_pnum                  NUMBER;
      calc_date_pnum                NUMBER;
      batch_pnum                    NUMBER;
      ledger_pnum                   NUMBER;
      usage_pnum                    NUMBER;
      exit_fail                     EXCEPTION;

      CURSOR get_adb_batches IS
        SELECT batch_id,batch_type_code
        FROM gl_auto_alloc_batches
        WHERE allocation_set_id = v_batch_id
        AND batch_type_code IN ('A','R','E','B');

   BEGIN
      error_buffer := '';

      -- Do not increment if user did not check the increment date flag
      IF fnd_resub.get_increment_flag = 'N' THEN
         fnd_resub.return_info(0, error_buffer);
         RETURN;
      END IF;
      error_code := -1;

      -- get program name;
      fnd_resub.get_program(program_name, application_name);
      error_code := -2;

      --con_ledger_flag := 'Y';
      SELECT consolidation_ledger_flag
      into con_ledger_flag
      FROM gl_system_usages;
      error_code := -3;

      IF (program_name = 'GLCRVL') THEN
         IF fnd_resub.get_param_number('Ledger Id',ledger_pnum) <> 0 THEN
           error_code := -31;
           fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
           fnd_message.set_token('PARA','Ledger Id');
           error_buffer := fnd_message.get;
           RAISE exit_fail;
         END IF;
         v_ledger_id := fnd_resub.get_parameter(ledger_pnum);
         increment_date('Effective Date', 'Y', 'Period', v_ledger_id);
         increment_date('Rate Date', 'N', NULL, v_ledger_id);
      ELSIF program_name = 'GLPRJE' THEN
         IF fnd_resub.get_param_number('Recurring Batch Id',batch_pnum) <>0 THEN
           error_code := -32;
           fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
           fnd_message.set_token('PARA','Recurring Batch Id');
           error_buffer := fnd_message.get;
           RAISE exit_fail;
         END IF;
         v_batch_id := fnd_resub.get_parameter(batch_pnum);

         IF(con_ledger_flag = 'Y') THEN
             IF fnd_resub.get_param_number('Average Journal Flag',usage_pnum) <>0 THEN
               error_code := -33;
               fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
               fnd_message.set_token('PARA','Average Journal Flag');
               error_buffer := fnd_message.get;
               RAISE exit_fail;
             END IF;
             usage_flag := fnd_resub.get_parameter(usage_pnum);
         ELSE
             usage_flag := 'N';
         END IF;

         -- Check if ADB ledgers exist in the batch
         BEGIN
           SELECT lgr.ledger_id
           into v_adb_ledger_id
           FROM gl_recurring_headers rh, gl_ledgers lgr
           WHERE rh.recurring_batch_id = v_batch_id
           AND   lgr.ledger_id = rh.ledger_id
           AND   lgr.enable_average_balances_flag = 'Y'
           AND   lgr.consolidation_ledger_flag = 'N'
           AND   rownum = 1;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                v_adb_ledger_id := NULL;
         END;

         -- Check if consolidation ledgers exist in the batch
         BEGIN
           SELECT lgr.ledger_id
           into  v_con_ledger_id
           FROM gl_recurring_headers rh, gl_ledgers lgr
           WHERE rh.recurring_batch_id = v_batch_id
           AND   lgr.ledger_id = rh.ledger_id
           AND   lgr.enable_average_balances_flag = 'Y'
           AND   lgr.consolidation_ledger_flag = 'Y'
           AND   rownum =1;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  v_con_ledger_id := NULL;
         END;

         IF (v_adb_ledger_id IS NULL and v_con_ledger_id IS NULL )THEN
            random_ledger_id := get_random_ledger('GLPRJE',NULL,v_batch_id);
            increment_period(random_ledger_id,'PERIOD_NAME');
         ELSIF (v_adb_ledger_id IS NOT NULL AND v_con_ledger_id IS NOT NULL ) THEN
            IF(usage_flag = 'Y') THEN
               cons_inc_private(
                 v_con_ledger_id,
                 'PERIOD_NAME',
                 'JOURNAL_EFFECTIVE_DATE',
                 'CALCULATION_EFFECTIVE_DATE',
                 'YYYY/MM/DD');
            ELSE
              increment_adb(
                 v_adb_ledger_id,
                 'PERIOD_NAME',
                 'JOURNAL_EFFECTIVE_DATE',
                 'CALCULATION_EFFECTIVE_DATE',
                 'YYYY/MM/DD');
            END IF;
         ELSIF (v_adb_ledger_id IS NOT NULL) THEN
            increment_adb(
               v_adb_ledger_id,
               'PERIOD_NAME',
               'JOURNAL_EFFECTIVE_DATE',
               'CALCULATION_EFFECTIVE_DATE',
               'YYYY/MM/DD');
         ELSIF (v_con_ledger_id IS NOT NULL) THEN
              cons_inc_private(
               v_con_ledger_id,
               'PERIOD_NAME',
               'JOURNAL_EFFECTIVE_DATE',
               'CALCULATION_EFFECTIVE_DATE',
               'YYYY/MM/DD');
         END IF;
      ELSIF (program_name = 'GLAMAS') THEN
         IF fnd_resub.get_param_number('allocation_batch_id',batch_pnum) <>0 THEN
           error_code := -34;
           fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
           fnd_message.set_token('PARA','allocation_batch_id');
           error_buffer := fnd_message.get;
           RAISE exit_fail;
         END IF;

         v_batch_id := fnd_resub.get_parameter(batch_pnum);
         IF fnd_resub.get_param_number('ledger_override_id',ledger_pnum) <> 0 THEN
           error_code := -35;
           fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
           fnd_message.set_token('PARA','ledger_override_id');
           error_buffer := fnd_message.get;
           RAISE exit_fail;
         END IF;
         v_ledger_id := fnd_resub.get_parameter(ledger_pnum);

         IF(con_ledger_flag = 'Y') THEN
             IF fnd_resub.get_param_number('average_je_flag',usage_pnum) <>0 THEN
               error_code := -36;
               fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
               fnd_message.set_token('PARA','average_je_flag');
               error_buffer := fnd_message.get;
               RAISE exit_fail;
             END IF;
             usage_flag := fnd_resub.get_parameter(usage_pnum);
         ELSE
             usage_flag := 'N';
         END IF;

         -- Check if ADB ledgers exist in the batch
         BEGIN
           SELECT lgr.ledger_id
           into v_adb_ledger_id
           FROM   gl_alloc_formulas af,
                  gl_alloc_formula_lines al,
                  gl_ledger_set_assignments lsa,
                  gl_ledgers lgr
           WHERE  af.allocation_batch_id = v_batch_id
           AND    al.allocation_formula_id = af.allocation_formula_id
           AND    al.line_number IN (4, 5)
           AND    lsa.ledger_set_id (+) = nvl(al.ledger_id,v_ledger_id)
           AND    sysdate BETWEEN
                       nvl(trunc(lsa.start_date), sysdate - 1)
                   AND nvl(trunc(lsa.end_date), sysdate + 1)
           AND    lgr.ledger_id = nvl(lsa.ledger_id,
                              nvl(al.ledger_id,v_ledger_id))
           AND    lgr.object_type_code = 'L'
           AND    lgr.enable_average_balances_flag= 'Y'
           AND    lgr.consolidation_ledger_flag = 'N'
           AND    rownum = 1;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                v_adb_ledger_id := NULL;
           END;

         -- Check if consolidation ledgers exist in the batch
         BEGIN
           SELECT lgr.ledger_id
           into v_con_ledger_id
           FROM   gl_alloc_formulas af,
                  gl_alloc_formula_lines al,
                  gl_ledger_set_assignments ls,
                  gl_ledgers lgr
           WHERE  af.allocation_batch_id = v_batch_id
           AND    al.allocation_formula_id = af.allocation_formula_id
           AND    al.line_number IN (4, 5)
           AND    ls.ledger_set_id (+) = nvl(al.ledger_id,v_ledger_id)
           AND    sysdate BETWEEN
                       nvl(trunc(ls.start_date), sysdate - 1)
                   AND nvl(trunc(ls.end_date), sysdate + 1)
           AND    lgr.ledger_id = nvl(ls.ledger_id,
                                  nvl(al.ledger_id,v_ledger_id))
           AND    lgr.object_type_code = 'L'
           AND    lgr.enable_average_balances_flag = 'Y'
           AND    lgr.consolidation_ledger_flag = 'Y'
           AND    rownum = 1;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 v_con_ledger_id := NULL;
         END;

         IF (v_adb_ledger_id IS NULL and v_con_ledger_id IS NULL) THEN
            random_ledger_id := get_random_ledger('GLAMAS',v_ledger_id,v_batch_id);
            increment_period(random_ledger_id,'PERIOD_NAME');
         ELSIF (v_adb_ledger_id IS NOT NULL AND v_con_ledger_id IS NOT NULL ) THEN
            IF(usage_flag = 'Y') THEN
               cons_inc_private(
                 v_con_ledger_id,
                 'PERIOD_NAME',
                 'JOURNAL_EFFECTIVE_DATE',
                 'CALCULATION_EFFECTIVE_DATE',
                 'YYYY/MM/DD HH24:MI:SS');
           ELSE
              increment_adb(
                 v_adb_ledger_id,
                 'PERIOD_NAME',
                 'JOURNAL_EFFECTIVE_DATE',
                 'CALCULATION_EFFECTIVE_DATE',
                 'YYYY/MM/DD HH24:MI:SS');
           END IF;
         ELSIF (v_adb_ledger_id IS NOT NULL) THEN
            increment_adb(
               v_adb_ledger_id,
               'PERIOD_NAME',
               'JOURNAL_EFFECTIVE_DATE',
               'CALCULATION_EFFECTIVE_DATE',
               'YYYY/MM/DD HH24:MI:SS');
         ELSIF (v_con_ledger_id IS NOT NULL) THEN
              cons_inc_private(
               v_con_ledger_id,
               'PERIOD_NAME',
               'JOURNAL_EFFECTIVE_DATE',
               'CALCULATION_EFFECTIVE_DATE',
               'YYYY/MM/DD HH24:MI:SS');
         END IF;
      ELSIF program_name = 'GLALGEN' THEN
         IF fnd_resub.get_param_number('allocation_set_id',batch_pnum)<> 0 THEN
           error_code := -37;
           fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
           fnd_message.set_token('PARA','allocation_set_id');
           error_buffer := fnd_message.get;
           RAISE exit_fail;
         END IF;

         v_batch_id := fnd_resub.get_parameter(batch_pnum);

         IF fnd_resub.get_param_number('LEDGER_ID',ledger_pnum) <>0 THEN
           error_code := -38;
           fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
           fnd_message.set_token('PARA','LEDGER_ID');
           error_buffer := fnd_message.get;
           RAISE exit_fail;
         END IF;

         v_ledger_id := fnd_resub.get_parameter(ledger_pnum);

         IF(con_ledger_flag = 'Y') THEN
             IF fnd_resub.get_param_number('average_journal_flag',usage_pnum) <>0 THEN
               error_code := -39;
               fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
               fnd_message.set_token('PARA','average_journal_flag');
               error_buffer := fnd_message.get;
               RAISE exit_fail;
             END IF;
             usage_flag := fnd_resub.get_parameter(usage_pnum);
         ELSE
             usage_flag := 'N';
         END IF;

         OPEN get_adb_batches;
         LOOP
           FETCH get_adb_batches into current_bid,batch_code;
           EXIT WHEN get_adb_batches%NOTFOUND;

             IF (batch_code = 'A') THEN
               if(v_adb_ledger_id IS NULL) THEN
                 -- Check if ADB ledgers exist in the batch
                 BEGIN
                   SELECT lgr.ledger_id
                   into v_adb_ledger_id
                   FROM   gl_alloc_formulas af,
                          gl_alloc_formula_lines al,
                          gl_ledger_set_assignments lsa,
                          gl_ledgers lgr
                   WHERE  af.allocation_batch_id = current_bid
                   AND    al.allocation_formula_id = af.allocation_formula_id
                   AND    al.line_number IN (4, 5)
                   AND    lsa.ledger_set_id (+) = nvl(al.ledger_id,v_ledger_id)
                   AND    sysdate BETWEEN
                           nvl(trunc(lsa.start_date), sysdate - 1)
                       AND nvl(trunc(lsa.end_date), sysdate + 1)
                   AND    lgr.ledger_id = nvl(lsa.ledger_id,
                              nvl(al.ledger_id,v_ledger_id))
                   AND    lgr.object_type_code = 'L'
                   AND    lgr.enable_average_balances_flag = 'Y'
                   AND    lgr.consolidation_ledger_flag = 'N'
                   AND    rownum = 1;
                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    v_adb_ledger_id := NULL;
                 END;
               END IF;

               if(v_con_ledger_id IS NULL) THEN
                 -- Check if consolidation ledgers exist in the batch
                 BEGIN
                   SELECT lgr.ledger_id
                   into v_con_ledger_id
                   FROM   gl_alloc_formulas af,
                          gl_alloc_formula_lines al,
                          gl_ledger_set_assignments ls,
                          gl_ledgers lgr
                   WHERE  af.allocation_batch_id = current_bid
                   AND    al.allocation_formula_id = af.allocation_formula_id
                   AND    al.line_number IN (4, 5)
                   AND    ls.ledger_set_id (+) = nvl(al.ledger_id,v_ledger_id)
                   AND    sysdate BETWEEN
                              nvl(trunc(ls.start_date), sysdate - 1)
                          AND nvl(trunc(ls.end_date), sysdate + 1)
                   AND    lgr.ledger_id = nvl(ls.ledger_id,
                                  nvl(al.ledger_id,v_ledger_id))
                   AND    lgr.object_type_code = 'L'
                   AND    lgr.enable_average_balances_flag = 'Y'
                   AND    lgr.consolidation_ledger_flag = 'Y'
                   AND    rownum = 1;
	         EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      v_con_ledger_id := NULL;
                 END;
               END IF;

               if(v_con_ledger_id IS NOT NULL AND v_adb_ledger_id IS NOT NULL) THEN
                 EXIT;
               end if;
             ELSIF (batch_code = 'R') THEN
               IF(v_adb_ledger_id IS NULL) THEN
                 -- Check if ADB ledgers exist in the batch
                 BEGIN
                   SELECT lgr.ledger_id
                   into v_adb_ledger_id
                   FROM gl_recurring_headers rh, gl_ledgers lgr
                   WHERE rh.recurring_batch_id = current_bid
                   AND   lgr.ledger_id = rh.ledger_id
                   AND   lgr.enable_average_balances_flag = 'Y'
                   AND   lgr.consolidation_ledger_flag = 'N'
                   AND   rownum = 1;
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         v_adb_ledger_id := NULL;
                 END;
               END IF;

               IF(v_con_ledger_id IS NULL) THEN
                 -- Check if consolidation ledgers exist in the batch
                 BEGIN
                   SELECT lgr.ledger_id
                   into  v_con_ledger_id
                   FROM gl_recurring_headers rh, gl_ledgers lgr
                   WHERE rh.recurring_batch_id = current_bid
                   AND   lgr.ledger_id = rh.ledger_id
                   AND   lgr.enable_average_balances_flag = 'Y'
                   AND   lgr.consolidation_ledger_flag = 'Y'
                   AND   rownum =1;
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_con_ledger_id := NULL;
                 END;
               END IF;

               IF(v_con_ledger_id IS NOT NULL AND v_adb_ledger_id IS NOT NULL) THEN
                 EXIT;
               END IF;

             END IF;
         END LOOP;
         CLOSE get_adb_batches;

         IF (v_adb_ledger_id IS NULL and v_con_ledger_id IS NULL) THEN
            random_ledger_id := get_random_ledger('GLALGEN',v_ledger_id,v_batch_id);
            increment_period(random_ledger_id,'PERIOD_NAME');
         ELSIF (v_adb_ledger_id IS NOT NULL AND v_con_ledger_id IS NOT NULL ) THEN
            IF(usage_flag = 'Y') THEN
               cons_inc_private(
                 v_con_ledger_id,
                 'PERIOD_NAME',
                 'JOURNAL_EFFECTIVE_DATE',
                 'CALCULATION_EFFECTIVE_DATE',
                 'YYYY/MM/DD HH24:MI:SS');
            ELSE
              increment_adb(
                 v_adb_ledger_id,
                 'PERIOD_NAME',
                 'JOURNAL_EFFECTIVE_DATE',
                 'CALCULATION_EFFECTIVE_DATE',
                 'YYYY/MM/DD HH24:MI:SS');
            END IF;
         ELSIF (v_adb_ledger_id IS NOT NULL) THEN
            increment_adb(
               v_adb_ledger_id,
               'PERIOD_NAME',
               'JOURNAL_EFFECTIVE_DATE',
               'CALCULATION_EFFECTIVE_DATE',
               'YYYY/MM/DD HH24:MI:SS');
         ELSIF (v_con_ledger_id IS NOT NULL) THEN
              cons_inc_private(
               v_con_ledger_id,
               'PERIOD_NAME',
               'JOURNAL_EFFECTIVE_DATE',
               'CALCULATION_EFFECTIVE_DATE',
               'YYYY/MM/DD HH24:MI:SS');
         END IF;

      ELSIF program_name = 'GLPRBE' THEN
         IF fnd_resub.get_param_number('Budget Batch Id',batch_pnum) <> 0 THEN
           error_code := -40;
           fnd_message.set_name('SQLGL','GL_SCH_INC_GET_PARA_NUM');
           fnd_message.set_token('PARA','Ledger Id');
           error_buffer := fnd_message.get;
           RAISE exit_fail;
         END IF;

         v_batch_id := fnd_resub.get_parameter(batch_pnum);
         random_ledger_id := get_random_ledger('GLPRBE',NULL,v_batch_id);
         increment_period(random_ledger_id,'PERIOD_NAME_START');
         increment_period(random_ledger_id,'PERIOD_NAME_END');
      END IF;

      fnd_resub.return_info(0, error_buffer);
   EXCEPTION
      WHEN exit_fail THEN
         fnd_resub.return_info(error_code, error_buffer);
      WHEN OTHERS THEN
         error_buffer :=
                  'gl_srs_incrementor_api.increment_parameters error #'
               || TO_CHAR(error_code)
               || ' : '
               || SUBSTR(SQLERRM, 1, 100);
         fnd_resub.return_info(error_code, error_buffer);
   END increment_parameters;

   PROCEDURE increment_date(
      x_date_para     VARCHAR2,
      x_period_flag   VARCHAR2,
      x_period_para   VARCHAR2,
      x_ledger_id     NUMBER) IS
      l_value                       fnd_profile_option_values.profile_option_value%TYPE;
      error_code                    NUMBER;
      v_last_period                 VARCHAR2(15);
      temp_date                     VARCHAR2(45);
      c_date                        DATE;
      v_date                        VARCHAR2(45);
      v_last_sch_date               DATE;
      v_sch_date                    DATE;
      v_days_elapsed                NUMBER;
      date_pnum                     NUMBER;
      period_pnum                   NUMBER;
      exit_fail                     EXCEPTION;
      c_start_period                VARCHAR2(15);
   BEGIN
      error_buffer := '';

      -- Do not increment if user did not check the increment date flag
      IF fnd_resub.get_increment_flag = 'N' THEN
         fnd_resub.return_info(0, error_buffer);
         RETURN;
      END IF;

      --fnd_profile.get('GL_SET_OF_BKS_ID', l_value);
      --v_sob_id := TO_NUMBER(l_value);
      v_sch_date := fnd_resub.get_requested_start_date;
      v_days_elapsed := fnd_resub.get_rusub_delta;
      v_last_sch_date := TRUNC(  v_sch_date
                               - v_days_elapsed);

      IF fnd_resub.get_param_number(x_date_para, date_pnum) <> 0 THEN
         error_code := -400;
         -- Cannot get parameter number for PARA. Please check your
         -- concurrent program definition
         fnd_message.set_name('SQLGL', 'GL_SCH_INC_GET_PARA_NUM');
         fnd_message.set_token('PARA', x_date_para);
         error_buffer := fnd_message.get;
         RAISE exit_fail;
      END IF;

      temp_date := fnd_resub.get_parameter(date_pnum);
      temp_date := SUBSTR(temp_date, 1, 10);
      c_date := TO_DATE(temp_date, 'YYYY/MM/DD');
      c_date :=   c_date
                + v_days_elapsed;
      v_date :=    TO_CHAR(c_date, 'YYYY/MM/DD')
                || ' 00:00:00';
      fnd_resub.set_parameter(date_pnum, v_date);

      IF (x_period_flag = 'Y') THEN
         BEGIN
            SELECT period_name
              INTO c_start_period
              FROM gl_period_statuses p
             WHERE p.application_id = 101
               AND p.ledger_id = x_ledger_id
               AND c_date BETWEEN p.start_date
                              AND p.end_date + 0.99998843
               AND p.adjustment_period_flag = 'N';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               error_code := -410;
               fnd_message.set_name('SQLGL', 'GL_SCH_INC_ADJ_PERIOD');
               error_buffer := fnd_message.get;
               RAISE exit_fail;
         END;

         IF fnd_resub.get_param_number(x_period_para, period_pnum) <> 0 THEN
            error_code := -420;
            -- Cannot get parameter number for PARA. Please check your
            -- concurrent program definition
            fnd_message.set_name('SQLGL', 'GL_SCH_INC_GET_PARA_NUM');
            fnd_message.set_token('PARA', x_period_para);
            error_buffer := fnd_message.get;
            RAISE exit_fail;
         END IF;

         fnd_resub.set_parameter(period_pnum, c_start_period);
      END IF;

      fnd_resub.return_info(0, error_buffer);
   EXCEPTION
      WHEN exit_fail THEN
         fnd_resub.return_info(error_code, error_buffer);
      WHEN OTHERS THEN
         error_buffer :=    'gl_srs_incrementor_api.increment_date error #'
                         || TO_CHAR(error_code)
                         || ' : '
                         || SUBSTR(SQLERRM, 1, 100);
         fnd_resub.return_info(error_code, error_buffer);
   END increment_date;


  FUNCTION get_random_ledger(
      x_batch_type                  VARCHAR2,
      x_ledger_id                   NUMBER,
      x_batch_id                    NUMBER) return NUMBER IS

  CURSOR random_batch IS
      SELECT batch_id,batch_type_code
      FROM   gl_auto_alloc_batches
      WHERE  allocation_set_id = x_batch_id;

  CURSOR rje_ledger(random_bid number) IS
      SELECT ledger_id
      FROM   gl_recurring_headers
      WHERE  recurring_batch_id = random_bid;


  CURSOR ma_ledger (random_bid number) IS
      SELECT lgr.ledger_id
      FROM   gl_alloc_formulas af,
             gl_alloc_formula_lines afl,
             gl_ledger_set_assignments lsa,
             gl_ledgers lgr
      WHERE  af.allocation_batch_id = random_bid
      AND    afl.allocation_formula_id = af.allocation_formula_id
      AND    afl.line_number IN (4, 5)
      AND    lsa.ledger_set_id (+) = nvl(afl.ledger_id, x_ledger_id)
      AND    sysdate BETWEEN
                     nvl(trunc(lsa.start_date), sysdate - 1)
                 AND nvl(trunc(lsa.end_date), sysdate + 1)
      AND    lgr.ledger_id = nvl(lsa.ledger_id,
                                 nvl(afl.ledger_id, x_ledger_id))
      AND    lgr.object_type_code = 'L';

  CURSOR mb_ledger (random_bid number)IS
      SELECT lgr.ledger_id
      FROM   gl_alloc_formulas af,
             gl_alloc_formula_lines afl,
             gl_ledger_set_assignments lsa,
             gl_ledgers lgr
      WHERE  af.allocation_batch_id = random_bid
      AND    afl.allocation_formula_id = af.allocation_formula_id
      AND    afl.line_number IN (4, 5)
      AND    lsa.ledger_set_id (+) = afl.ledger_id
      AND    sysdate BETWEEN
                     nvl(trunc(lsa.start_date), sysdate - 1)
                 AND nvl(trunc(lsa.end_date), sysdate + 1)
      AND    lgr.ledger_id = nvl(lsa.ledger_id, afl.ledger_id)
      AND    lgr.object_type_code = 'L';

   random_id   NUMBER;
   random_bid  NUMBER;
   random_btype VARCHAR2(1);
  BEGIN

     IF (x_batch_type = 'GLALGEN') THEN

        OPEN random_batch;
        FETCH random_batch into random_bid, random_btype;
        CLOSE random_batch;

        IF(random_btype = 'R') THEN
           OPEN rje_ledger(random_bid);
           FETCH rje_ledger INTO random_id;
           CLOSE rje_ledger;
        ELSIF (random_btype = 'B') THEN
           OPEN mb_ledger(random_bid);
           FETCH mb_ledger INTO random_id;
           CLOSE mb_ledger;
        ELSIF (random_btype = 'A' or random_btype = 'E') THEN
           OPEN ma_ledger(random_bid);
           FETCH ma_ledger INTO random_id;
           CLOSE ma_ledger;
        END IF;

    ELSIF (x_batch_type = 'GLAMAS') THEN

         random_bid := x_batch_id;
         OPEN ma_ledger(random_bid);
         FETCH ma_ledger INTO random_id;
         CLOSE ma_ledger;

    ELSIF (x_batch_type = 'GLPRJE' OR x_batch_type = 'GLPRBE') THEN

         random_bid := x_batch_id;
         OPEN rje_ledger(random_bid);
         FETCH rje_ledger INTO random_id;
         CLOSE rje_ledger;
    ELSE

         random_id := -1;

    END IF;

    RETURN random_id;

   END get_random_ledger;

END gl_srs_incrementor_api;

/
