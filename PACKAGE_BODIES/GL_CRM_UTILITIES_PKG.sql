--------------------------------------------------------
--  DDL for Package Body GL_CRM_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CRM_UTILITIES_PKG" AS
   /* $Header: glcrmutb.pls 120.12.12010000.4 2010/04/27 08:53:05 sommukhe ship $ */
         p_from_currency                 VARCHAR2(240);
         p_to_currency                   VARCHAR2(240);
         p_from_conversion_date          DATE;
         p_to_conversion_date            DATE;
         p_conversion_type               VARCHAR2(240);
         p_conversion_rate               NUMBER;
         p_inverse_conversion_rate       NUMBER;
         p_mode_flag                     VARCHAR2(240);
         ekey                            VARCHAR2(100);
   PROCEDURE change_flag(
      flag                                BOOLEAN) IS
   BEGIN
      enable_trigger := flag;
   END change_flag;

-------------------------------------------------------------------
   PROCEDURE print_report_title IS
      c_text_files   VARCHAR2(200);
   BEGIN
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0023');
      c_text_files :=
         RPAD(fnd_message.get || ' '
              || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MM:SS'),
              36, ' ');
      fnd_message.set_name('SQLGL', 'CRM0025');
      c_text_files := c_text_files || LPAD(fnd_message.get, 48, ' ');
      fnd_message.set_name('SQLGL', 'CRM0024');
      c_text_files :=
          c_text_files || LPAD(fnd_message.get || ' ' || page_count, 49, ' ');
      fnd_file.put_line(fnd_file.output, c_text_files);
      page_line_count := page_line_count + 2;
   END print_report_title;

-------------------------------------------------------------------
   PROCEDURE print_validation_failure IS
      c_text_files   VARCHAR2(200);
   BEGIN
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0026');
      fnd_file.put_line(fnd_file.output,
                        LPAD('  ', 45, '=') || fnd_message.get
                        || RPAD('  ', 45, '='));
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0032');
      c_text_files := RPAD(fnd_message.get, 31, ' ');
      fnd_message.set_name('SQLGL', 'CRM0033');
      c_text_files := c_text_files || RPAD(fnd_message.get, 15, ' ');
      fnd_message.set_name('SQLGL', 'CRM0034');
      c_text_files := c_text_files || RPAD(fnd_message.get, 15, ' ');
      fnd_message.set_name('SQLGL', 'CRM0035');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0036');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0037');
      c_text_files := c_text_files || LPAD(fnd_message.get || ' ', 13, ' ');
      fnd_message.set_name('SQLGL', 'CRM0038');
      c_text_files := c_text_files || LPAD(fnd_message.get || ' ', 13, ' ');
      fnd_message.set_name('SQLGL', 'CRM0039');
      c_text_files := c_text_files || RPAD(fnd_message.get, 14, ' ');
      fnd_file.put_line(fnd_file.output, c_text_files);
      fnd_file.put_line(fnd_file.output,
                        LPAD(' ', 31, '-') || LPAD(' ', 15, '-')
                        || LPAD(' ', 15, '-') || LPAD(' ', 16, '-')
                        || LPAD(' ', 16, '-') || LPAD(' ', 13, '-')
                        || LPAD(' ', 13, '-') || LPAD('-', 14, '-'));
      page_line_count := page_line_count + 6;
   END print_validation_failure;

-------------------------------------------------------------------
   PROCEDURE print_delete_user_rate_warning IS
      c_text_files   VARCHAR2(200);
   BEGIN
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0027');
      fnd_file.put_line(fnd_file.output,
                        LPAD('  ', 45, '=') || fnd_message.get
                        || RPAD('  ', 46, '='));
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0032');
      c_text_files := RPAD(fnd_message.get, 31, ' ');
      fnd_message.set_name('SQLGL', 'CRM0040');
      c_text_files := c_text_files || RPAD(fnd_message.get, 30, ' ');
      fnd_message.set_name('SQLGL', 'CRM0035');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0036');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0037');
      c_text_files := c_text_files || LPAD(fnd_message.get || ' ', 13, ' ');
      fnd_message.set_name('SQLGL', 'CRM0041');
      c_text_files := c_text_files || RPAD(fnd_message.get, 26, ' ');
      fnd_file.put_line(fnd_file.output, c_text_files);
      fnd_file.put_line(fnd_file.output,
                        LPAD(' ', 31, '-') || LPAD(' ', 30, '-')
                        || LPAD(' ', 16, '-') || LPAD(' ', 16, '-')
                        || LPAD(' ', 13, '-') || LPAD('-', 26, '-'));
      page_line_count := page_line_count + 6;
   END print_delete_user_rate_warning;

-------------------------------------------------------------------
   PROCEDURE print_override_user_rate_warn IS
      c_text_files   VARCHAR2(200);
   BEGIN
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0028');
      fnd_file.put_line(fnd_file.output,
                        LPAD('  ', 45, '=') || fnd_message.get
                        || RPAD('  ', 46, '='));
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0032');
      c_text_files := RPAD(fnd_message.get, 31, ' ');
      fnd_message.set_name('SQLGL', 'CRM0040');
      c_text_files := c_text_files || RPAD(fnd_message.get, 30, ' ');
      fnd_message.set_name('SQLGL', 'CRM0035');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0036');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0037');
      c_text_files := c_text_files || LPAD(fnd_message.get || ' ', 13, ' ');
      fnd_message.set_name('SQLGL', 'CRM0041');
      c_text_files := c_text_files || RPAD(fnd_message.get, 26, ' ');
      fnd_file.put_line(fnd_file.output, c_text_files);
      fnd_file.put_line(fnd_file.output,
                        LPAD(' ', 31, '-') || LPAD(' ', 30, '-')
                        || LPAD(' ', 16, '-') || LPAD(' ', 16, '-')
                        || LPAD(' ', 13, '-') || LPAD('-', 26, '-'));
      page_line_count := page_line_count + 6;
   END print_override_user_rate_warn;

-------------------------------------------------------------------
   PROCEDURE print_delete_sys_rate_warning IS
      c_text_files   VARCHAR2(200);
   BEGIN
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0029');
      fnd_file.put_line(fnd_file.output,
                        LPAD('  ', 43, '=') || fnd_message.get
                        || RPAD('  ', 44, '='));
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0032');
      c_text_files := RPAD(fnd_message.get, 31, ' ');
      fnd_message.set_name('SQLGL', 'CRM0040');
      c_text_files := c_text_files || RPAD(fnd_message.get, 30, ' ');
      fnd_message.set_name('SQLGL', 'CRM0035');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0036');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0037');
      c_text_files := c_text_files || LPAD(fnd_message.get || ' ', 13, ' ');
      fnd_message.set_name('SQLGL', 'CRM0041');
      c_text_files := c_text_files || RPAD(fnd_message.get, 26, ' ');
      fnd_file.put_line(fnd_file.output, c_text_files);
      fnd_file.put_line(fnd_file.output,
                        LPAD(' ', 31, '-') || LPAD(' ', 30, '-')
                        || LPAD(' ', 16, '-') || LPAD(' ', 16, '-')
                        || LPAD(' ', 13, '-') || LPAD('-', 26, '-'));
      page_line_count := page_line_count + 6;
   END print_delete_sys_rate_warning;

-------------------------------------------------------------------
   PROCEDURE print_override_sys_rate_warn IS
      c_text_files   VARCHAR2(200);
   BEGIN
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0030');
      fnd_file.put_line(fnd_file.output,
                        LPAD('  ', 43, '=') || fnd_message.get
                        || RPAD('  ', 44, '='));
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0032');
      c_text_files := RPAD(fnd_message.get, 31, ' ');
      fnd_message.set_name('SQLGL', 'CRM0040');
      c_text_files := c_text_files || RPAD(fnd_message.get, 30, ' ');
      fnd_message.set_name('SQLGL', 'CRM0035');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0036');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0037');
      c_text_files := c_text_files || LPAD(fnd_message.get || ' ', 13, ' ');
      fnd_message.set_name('SQLGL', 'CRM0041');
      c_text_files := c_text_files || RPAD(fnd_message.get, 26, ' ');
      fnd_file.put_line(fnd_file.output, c_text_files);
      fnd_file.put_line(fnd_file.output,
                        LPAD(' ', 31, '-') || LPAD(' ', 30, '-')
                        || LPAD(' ', 16, '-') || LPAD(' ', 16, '-')
                        || LPAD(' ', 13, '-') || LPAD('-', 26, '-'));
      page_line_count := page_line_count + 6;
   END print_override_sys_rate_warn;

-------------------------------------------------------------------
   PROCEDURE print_missing_pivot_rate IS
      c_text_files   VARCHAR2(200);
   BEGIN
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0031');
      fnd_file.put_line(fnd_file.output,
                        LPAD('  ', 51, '=') || fnd_message.get
                        || RPAD('  ', 51, '='));
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0032');
      c_text_files := RPAD(fnd_message.get, 31, ' ');
      fnd_message.set_name('SQLGL', 'CRM0040');
      c_text_files := c_text_files || RPAD(fnd_message.get, 30, ' ');
      fnd_message.set_name('SQLGL', 'CRM0042');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_message.set_name('SQLGL', 'CRM0043');
      c_text_files := c_text_files || RPAD(fnd_message.get, 16, ' ');
      fnd_file.put_line(fnd_file.output, c_text_files);
      fnd_file.put_line(fnd_file.output,
                        LPAD(' ', 31, '-') || LPAD(' ', 30, '-')
                        || LPAD(' ', 16, '-') || LPAD('-', 16, '-'));
      page_line_count := page_line_count + 6;
   END print_missing_pivot_rate;

-------------------------------------------------------------------
   PROCEDURE print_validation_failure_codes IS
   BEGIN
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0022');
      fnd_file.put_line(fnd_file.output,
                        LPAD('  ', 61, '=') || fnd_message.get
                        || RPAD('  ', 61, '='));
      fnd_file.put_line(fnd_file.output, ' ');
      fnd_message.set_name('SQLGL', 'CRM0021');
      fnd_file.put_line(fnd_file.output, fnd_message.get);
      fnd_file.put_line(fnd_file.output, RPAD('-', 133, '-'));
      fnd_message.set_name('SQLGL', 'CRM0007');
      fnd_file.put_line(fnd_file.output, '    VF01    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0008');
      fnd_file.put_line(fnd_file.output, '    VF02    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0009');
      fnd_file.put_line(fnd_file.output, '    VF03    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0010');
      fnd_file.put_line(fnd_file.output, '    VF04    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0011');
      fnd_file.put_line(fnd_file.output, '    VF05    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0012');
      fnd_file.put_line(fnd_file.output, '    VF06    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0013');
      fnd_file.put_line(fnd_file.output, '    VF07    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0014');
      fnd_file.put_line(fnd_file.output, '    VF08    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0015');
      fnd_file.put_line(fnd_file.output, '    VF09    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0016');
      fnd_file.put_line(fnd_file.output, '    VF10    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0017');
      fnd_file.put_line(fnd_file.output, '    VF11    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0018');
      fnd_file.put_line(fnd_file.output, '    VF12    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0019');
      fnd_file.put_line(fnd_file.output, '    VF13    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0020');
      fnd_file.put_line(fnd_file.output, '    VF14    ' || fnd_message.get);
      fnd_message.set_name('SQLGL', 'CRM0044');
      fnd_file.put_line(fnd_file.output, '    VF15    ' || fnd_message.get);
   END print_validation_failure_codes;

-------------------------------------------------------------------
   PROCEDURE insert_cross_rate_set(
      p_conversion_type          IN       VARCHAR2,
      p_contra_currency          IN       VARCHAR2,
      p_login_user               IN       NUMBER) IS
      existed_curr_rec   curr_rec;
      x_pivot_currency   VARCHAR2(15);
   BEGIN
      SELECT pivot_currency
        INTO x_pivot_currency
        FROM gl_cross_rate_rules
       WHERE conversion_type = p_conversion_type;

      SELECT DISTINCT from_currency
      BULK COLLECT INTO existed_curr_rec.r_from_curr
                 FROM gl_cross_rate_rule_dtls
                WHERE conversion_type = p_conversion_type;

      --IF (existed_curr_rec.r_from_curr.COUNT = 0) THEN
      -- modify this, always insert the dummy rows, we can use those rows in VO.
      INSERT INTO gl_cross_rate_rule_dtls
                  (conversion_type, from_currency, to_currency,
                   enabled_flag, last_update_date, last_updated_by,
                   creation_date, created_by, last_update_login)
           VALUES (p_conversion_type, p_contra_currency, p_contra_currency,
                   'N', SYSDATE, p_login_user,
                   SYSDATE, p_login_user, p_login_user);

      IF (existed_curr_rec.r_from_curr.COUNT > 0) THEN
         /* at least one contra currency is existed */
         FORALL i IN 1 .. existed_curr_rec.r_from_curr.COUNT
            INSERT INTO gl_cross_rate_rule_dtls
                        (conversion_type, from_currency,
                         to_currency, enabled_flag, last_update_date,
                         last_updated_by, creation_date, created_by,
                         last_update_login)
                 VALUES (p_conversion_type, p_contra_currency,
                         existed_curr_rec.r_from_curr(i), 'Y', SYSDATE,
                         p_login_user, SYSDATE, p_login_user,
                         p_login_user);
         FORALL i IN 1 .. existed_curr_rec.r_from_curr.COUNT
            INSERT INTO gl_cross_rate_rule_dtls
                        (conversion_type, from_currency,
                         to_currency, enabled_flag, last_update_date,
                         last_updated_by, creation_date, created_by,
                         last_update_login)
                 VALUES (p_conversion_type, existed_curr_rec.r_from_curr(i),
                         p_contra_currency, 'Y', SYSDATE,
                         p_login_user, SYSDATE, p_login_user,
                         p_login_user);
      END IF;
   END insert_cross_rate_set;

-------------------------------------------------------------------
   PROCEDURE update_cross_rate_set(
      p_conversion_type          IN       VARCHAR2,
      p_new_contra_currency      IN       VARCHAR2,
      p_old_contra_currency      IN       VARCHAR2,
      p_login_user               IN       NUMBER) IS
      x_pivot_currency   VARCHAR2(15);
   BEGIN
      SELECT pivot_currency
        INTO x_pivot_currency
        FROM gl_cross_rate_rules
       WHERE conversion_type = p_conversion_type;

      UPDATE gl_cross_rate_rule_dtls
         SET from_currency = p_new_contra_currency,
             last_update_date = SYSDATE,
             last_updated_by = p_login_user,
             last_update_login = p_login_user
       WHERE conversion_type = p_conversion_type
         AND from_currency = p_old_contra_currency;

      UPDATE gl_cross_rate_rule_dtls
         SET to_currency = p_new_contra_currency,
             last_update_date = SYSDATE,
             last_updated_by = p_login_user,
             last_update_login = p_login_user
       WHERE conversion_type = p_conversion_type
         AND to_currency = p_old_contra_currency;
   END update_cross_rate_set;

-------------------------------------------------------------------
   PROCEDURE delete_cross_rate_set(
      p_conversion_type          IN       VARCHAR2,
      p_contra_currency          IN       VARCHAR2) IS
   BEGIN
      DELETE FROM gl_cross_rate_rule_dtls
            WHERE conversion_type = p_conversion_type
              AND (   from_currency = p_contra_currency
                   OR to_currency = p_contra_currency);
   END delete_cross_rate_set;

-------------------------------------------------------------------
-- Created the Procedure for raising Business Events for Daily   --
-- Rates Insert, Update and Delete Bug 4758732 JVARKEY           --
-------------------------------------------------------------------
   PROCEDURE raise_dr_buz_events(
      p_from_currency                 VARCHAR2,
      p_to_currency                   VARCHAR2,
      p_from_conversion_date          DATE,
      p_to_conversion_date            DATE,
      p_conversion_type               VARCHAR2,
      p_conversion_rate               NUMBER,
      p_inverse_conversion_rate       NUMBER,
      p_mode_flag                     VARCHAR2) IS

      ekey            VARCHAR2(100);

   BEGIN

      ekey := p_from_currency||':'||p_to_currency||':'||p_conversion_type||':'
               ||to_char(p_from_conversion_date,'RRDDDSSSSS')||':'
               ||to_char(p_to_conversion_date,'RRDDDSSSSS')||':'
               ||to_char(sysdate, 'RRDDDSSSSS');

      IF (p_mode_flag = 'D') THEN

         -- Raise the remove conversion event
         gl_business_events.raise(
           p_event_name =>
             'oracle.apps.gl.CurrencyConversionRates.dailyRate.remove',
           p_event_key => ekey,
           p_parameter_name1 => 'FROM_CURRENCY',
           p_parameter_value1 => p_from_currency,
           p_parameter_name2 => 'TO_CURRENCY',
           p_parameter_value2 => p_to_currency,
           p_parameter_name3 => 'FROM_CONVERSION_DATE',
           p_parameter_value3 => to_char(p_from_conversion_date,'YYYY/MM/DD'),
           p_parameter_name4 => 'TO_CONVERSION_DATE',
           p_parameter_value4 => to_char(p_to_conversion_date,'YYYY/MM/DD'),
           p_parameter_name5 => 'CONVERSION_TYPE',
           p_parameter_value5 => p_conversion_type);

      ELSE

         -- Raise the specify conversion event
         gl_business_events.raise(
           p_event_name =>
             'oracle.apps.gl.CurrencyConversionRates.dailyRate.specify',
           p_event_key => ekey,
           p_parameter_name1 => 'FROM_CURRENCY',
           p_parameter_value1 => p_from_currency,
           p_parameter_name2 => 'TO_CURRENCY',
           p_parameter_value2 => p_to_currency,
           p_parameter_name3 => 'FROM_CONVERSION_DATE',
           p_parameter_value3 => to_char(p_from_conversion_date,'YYYY/MM/DD'),
           p_parameter_name4 => 'TO_CONVERSION_DATE',
           p_parameter_value4 => to_char(p_to_conversion_date,'YYYY/MM/DD'),
           p_parameter_name5 => 'CONVERSION_TYPE',
           p_parameter_value5 => p_conversion_type,
           p_parameter_name6 => 'CONVERSION_RATE',
           p_parameter_value6 => to_char(p_conversion_rate,
                                '99999999999999999999.99999999999999999999'),
           p_parameter_name7 => 'INVERSE_CONVERSION_RATE',
           p_parameter_value7 => to_char(p_inverse_conversion_rate,
                                '99999999999999999999.99999999999999999999'));

      END IF;

   END raise_dr_buz_events;

-------------------------------------------------------------------
   PROCEDURE daily_rates_import(
      errbuf                     OUT NOCOPY VARCHAR2,
      retcode                    OUT NOCOPY NUMBER,
      p_batch_number             IN    VARCHAR2 DEFAULT NULL) IS
      ab_used                          VARCHAR2(1);
      run_program                      VARCHAR2(1);
      euro_code                        VARCHAR2(30);
      RESULT                           BOOLEAN;
      set_completion_status_result     BOOLEAN;
      user_id                          NUMBER;
      req_id                           NUMBER;
      rows_need_calculation            NUMBER;
      daily_rate_validation_failure    daily_rate_interface_rec;
      sys_daily_rate_cannot_delete     daily_rate_rec;
      usr_daily_rate_cannot_delete     daily_rate_rec;
      sys_daily_rate_cannot_override   daily_rate_rec;
      usr_daily_rate_cannot_override   daily_rate_rec;
      daily_rate_missing_base_rate     daily_rate_rec;
      p_pivot_currency                 VARCHAR2(15);
      golden_rule_flag                 VARCHAR2(15);
      l_launch_rate_change             VARCHAR2(1) := 'N';

      l_batch_number                   VARCHAR2(40):= p_batch_number;
      l_return_status                  VARCHAR2(1) := 'S';
      l_error_message                  VARCHAR2(240);

   --Bug 4758732 JVARKEY Cursor to raise business events
      CURSOR raise_buz_events IS
      SELECT dri.from_currency,
             dri.to_currency,
             dri.from_conversion_date,
             dri.to_conversion_date,
             dct.conversion_type,
             dri.conversion_rate,
             NVL(dri.inverse_conversion_rate, 1/conversion_rate) inverse_conversion_rate,
             dri.mode_flag
       FROM  gl_daily_rates_interface dri,
             gl_daily_conversion_types dct
       WHERE mode_flag IN ('I', 'D', 'T', 'N')
       AND   dct.user_conversion_type = dri.user_conversion_type
       AND   dri.batch_number = l_batch_number;

   BEGIN
      -- Validate the following:
      --
      --   o Conversion_type exists,
      --   o Conversion_rate is not a negative number
      --   o Inverse_conversion_rate is not a negative number
      --   o From_Currency and To_Currency:
      --     a. Currency exists in the FND_CURRENCIES table
      --     b. Currency is enabled
      --     c. Currency is not a statistical currency
      --     d. Currency is not out of date
      --     e. Currency is not an EMU currency
      --   o Range of dates specified does not exceeds 366 days
      --
      -- If there is any error, an appropriate error_code will be set.
      gl_message.func_ent('Daily Rates Import');

      -- GL_CRM_UTILITIES_PKG.DEBUG_MODE := TRUE;
      /*If the Batch Number is NULL, it'll process only the records with Batch Number NULL records in the GL_DAILY_RATES_INTERFACE Table.*/
      /* Updating BATCH_NUMNER '-99999' in the Interface table if Batch Number Parameter is NULL*/
      IF l_batch_number IS NULL THEN
      UPDATE gl_daily_rates_interface ri
         SET ERROR_CODE =
                (SELECT DECODE
                           (ct.ROWID,
                            NULL, 'NONEXISTANT_CONVERSION_TYPE',
                            DECODE
                               (LEAST(TRUNC(ri2.to_conversion_date)
                                      - TRUNC(ri2.from_conversion_date),
                                      367),
                                367, 'DATE_RANGE_TOO_LARGE',
                                DECODE
                                   (LEAST(ri.conversion_rate, 0),
                                    ri.conversion_rate, 'NEGATIVE_CONVERSION_RATE',
                                    DECODE
                                       (LEAST
                                            (NVL(ri.inverse_conversion_rate,
                                                 1),
                                             0),
                                        ri.inverse_conversion_rate, 'NEGATIVE_INVERSE_RATE',
                                        DECODE
                                           (from_curr.ROWID,
                                            NULL, 'NONEXISTANT_FROM_CURRENCY',
                                            DECODE
                                               (from_curr.enabled_flag,
                                                'N', 'DISABLED_FROM_CURRENCY',
                                                -- Bug 4222440 JVARKEY Error the never enabled currency
                                                'X', 'DISABLED_FROM_CURRENCY',
                                                DECODE
                                                   (from_curr.currency_flag,
                                                    'N', 'STATISTICAL_FROM_CURRENCY',
                                                    DECODE
                                                       (from_curr.currency_code,
                                                        'STAT', 'STATISTICAL_FROM_CURRENCY',
                                                        DECODE
                                                           (SIGN
                                                               (TRUNC(SYSDATE)
                                                                - NVL
                                                                    (TRUNC
                                                                        (from_curr.start_date_active),
                                                                     TRUNC
                                                                        (SYSDATE))),
                                                            -1, 'OUT_OF_DATE_FROM_CURRENCY',
                                                            DECODE
                                                               (SIGN
                                                                   (TRUNC
                                                                       (SYSDATE)
                                                                    - NVL
                                                                        (TRUNC
                                                                            (from_curr.end_date_active),
                                                                         TRUNC
                                                                            (SYSDATE))),
                                                                1, 'OUT_OF_DATE_FROM_CURRENCY',
                                                                DECODE
                                                                   (DECODE
                                                                       (from_curr.derive_type,
                                                                        'EMU', SIGN
                                                                           (TRUNC
                                                                               (from_curr.derive_effective)
                                                                            - TRUNC
                                                                                (ri2.to_conversion_date)),
                                                                        1),
                                                                    -1, 'EMU_FROM_CURRENCY',
                                                                    0, 'EMU_FROM_CURRENCY',
                                                                    DECODE
                                                                       (to_curr.ROWID,
                                                                        NULL, 'NONEXISTANT_TO_CURRENCY',
                                                                        DECODE
                                                                           (to_curr.enabled_flag,
                                                                            'N', 'DISABLED_TO_CURRENCY',
                                                                            -- Bug 4222440 JVARKEY Error the never enabled currency
                                                                            'X', 'DISABLED_TO_CURRENCY',
                                                                            DECODE
                                                                               (to_curr.currency_flag,
                                                                                'N', 'STATISTICAL_TO_CURRENCY',
                                                                                DECODE
                                                                                   (to_curr.currency_code,
                                                                                    'STAT', 'STATISTICAL_TO_CURRENCY',
                                                                                    DECODE
                                                                                       (SIGN
                                                                                           (TRUNC
                                                                                               (SYSDATE)
                                                                                            - NVL
                                                                                                (TRUNC
                                                                                                    (to_curr.start_date_active),
                                                                                                 TRUNC
                                                                                                    (SYSDATE))),
                                                                                        -1, 'OUT_OF_DATE_TO_CURRENCY',
                                                                                        DECODE
                                                                                           (SIGN
                                                                                               (TRUNC
                                                                                                   (SYSDATE)
                                                                                                - NVL
                                                                                                    (TRUNC
                                                                                                        (to_curr.end_date_active),
                                                                                                     TRUNC
                                                                                                        (SYSDATE))),
                                                                                            1, 'OUT_OF_DATE_TO_CURRENCY',
                                                                                            DECODE
                                                                                               (DECODE
                                                                                                   (to_curr.derive_type,
                                                                                                    'EMU', SIGN
                                                                                                       (TRUNC
                                                                                                           (to_curr.derive_effective)
                                                                                                        - TRUNC
                                                                                                            (ri2.to_conversion_date)),
                                                                                                    1),
                                                                                                -1, 'EMU_TO_CURRENCY',
                                                                                                0, 'EMU_TO_CURRENCY',
                                                                                                ''))))))))))))))))))
                   FROM gl_daily_rates_interface ri2,
                        gl_daily_conversion_types ct,
                        fnd_currencies from_curr,
                        fnd_currencies to_curr
                  WHERE ri2.ROWID = ri.ROWID
                    AND ct.user_conversion_type(+) = ri2.user_conversion_type
                    AND from_curr.currency_code(+) = ri2.from_currency
                      AND to_curr.currency_code(+) = ri2.to_currency),
           ri.batch_number = DECODE(l_batch_number,null,-99999,ri.batch_number)
         WHERE ri.mode_flag IN('I', 'D', 'T', 'N')
         AND ri.batch_number is NULL;

	UPDATE GL_DAILY_RATES_INTERFACE T1
         SET T1.error_code = 'DUPLICATE_ROWS'
       WHERE
             (T1.FROM_CURRENCY,T1.TO_CURRENCY,T1.USER_CONVERSION_TYPE,
              T1.FROM_CONVERSION_DATE, T1.TO_CONVERSION_DATE)
         IN
             (
              SELECT /*+ NO_MERGE */ T2.FROM_CURRENCY,T2.to_CURRENCY,T2.USER_CONVERSION_TYPE,
                     T2.FROM_CONVERSION_DATE, T2.TO_CONVERSION_DATE
              FROM GL_DAILY_RATES_INTERFACE  T2
              WHERE mode_flag IN ('I', 'D', 'T', 'N')
	          GROUP BY T2.FROM_CURRENCY,T2.TO_CURRENCY,T2.USER_CONVERSION_TYPE,
                       T2.FROM_CONVERSION_DATE, T2.TO_CONVERSION_DATE
              HAVING count(*) > 1)
         AND mode_flag IN ('I', 'D', 'T', 'N')
         AND T1.batch_number IS NULL;


         l_batch_number := '-99999';

        ELSE
            UPDATE gl_daily_rates_interface ri
                   SET ERROR_CODE =
                          (SELECT DECODE
                                     (ct.ROWID,
                                      NULL, 'NONEXISTANT_CONVERSION_TYPE',
                                      DECODE
                                         (LEAST(TRUNC(ri2.to_conversion_date)
                                                - TRUNC(ri2.from_conversion_date),
                                                367),
                                          367, 'DATE_RANGE_TOO_LARGE',
                                          DECODE
                                             (LEAST(ri.conversion_rate, 0),
                                              ri.conversion_rate, 'NEGATIVE_CONVERSION_RATE',
                                              DECODE
                                                 (LEAST
                                                      (NVL(ri.inverse_conversion_rate,
                                                           1),
                                                       0),
                                                  ri.inverse_conversion_rate, 'NEGATIVE_INVERSE_RATE',
                                                  DECODE
                                                     (from_curr.ROWID,
                                                      NULL, 'NONEXISTANT_FROM_CURRENCY',
                                                      DECODE
                                                         (from_curr.enabled_flag,
                                                          'N', 'DISABLED_FROM_CURRENCY',
                                                          -- Bug 4222440 JVARKEY Error the never enabled currency
                                                          'X', 'DISABLED_FROM_CURRENCY',
                                                          DECODE
                                                             (from_curr.currency_flag,
                                                              'N', 'STATISTICAL_FROM_CURRENCY',
                                                              DECODE
                                                                 (from_curr.currency_code,
                                                                  'STAT', 'STATISTICAL_FROM_CURRENCY',
                                                                  DECODE
                                                                     (SIGN
                                                                         (TRUNC(SYSDATE)
                                                                          - NVL
                                                                              (TRUNC
                                                                                  (from_curr.start_date_active),
                                                                               TRUNC
                                                                                  (SYSDATE))),
                                                                      -1, 'OUT_OF_DATE_FROM_CURRENCY',
                                                                      DECODE
                                                                         (SIGN
                                                                             (TRUNC
                                                                                 (SYSDATE)
                                                                              - NVL
                                                                                  (TRUNC
                                                                                      (from_curr.end_date_active),
                                                                                   TRUNC
                                                                                      (SYSDATE))),
                                                                          1, 'OUT_OF_DATE_FROM_CURRENCY',
                                                                          DECODE
                                                                             (DECODE
                                                                                 (from_curr.derive_type,
                                                                                  'EMU', SIGN
                                                                                     (TRUNC
                                                                                         (from_curr.derive_effective)
                                                                                      - TRUNC
                                                                                          (ri2.to_conversion_date)),
                                                                                  1),
                                                                              -1, 'EMU_FROM_CURRENCY',
                                                                              0, 'EMU_FROM_CURRENCY',
                                                                              DECODE
                                                                                 (to_curr.ROWID,
                                                                                  NULL, 'NONEXISTANT_TO_CURRENCY',
                                                                                  DECODE
                                                                                     (to_curr.enabled_flag,
                                                                                      'N', 'DISABLED_TO_CURRENCY',
                                                                                      -- Bug 4222440 JVARKEY Error the never enabled currency
                                                                                      'X', 'DISABLED_TO_CURRENCY',
                                                                                      DECODE
                                                                                         (to_curr.currency_flag,
                                                                                          'N', 'STATISTICAL_TO_CURRENCY',
                                                                                          DECODE
                                                                                             (to_curr.currency_code,
                                                                                              'STAT', 'STATISTICAL_TO_CURRENCY',
                                                                                              DECODE
                                                                                                 (SIGN
                                                                                                     (TRUNC
                                                                                                         (SYSDATE)
                                                                                                      - NVL
                                                                                                          (TRUNC
                                                                                                              (to_curr.start_date_active),
                                                                                                           TRUNC
                                                                                                              (SYSDATE))),
                                                                                                  -1, 'OUT_OF_DATE_TO_CURRENCY',
                                                                                                  DECODE
                                                                                                     (SIGN
                                                                                                         (TRUNC
                                                                                                             (SYSDATE)
                                                                                                          - NVL
                                                                                                              (TRUNC
                                                                                                                  (to_curr.end_date_active),
                                                                                                               TRUNC
                                                                                                                  (SYSDATE))),
                                                                                                      1, 'OUT_OF_DATE_TO_CURRENCY',
                                                                                                      DECODE
                                                                                                         (DECODE
                                                                                                             (to_curr.derive_type,
                                                                                                              'EMU', SIGN
                                                                                                                 (TRUNC
                                                                                                                     (to_curr.derive_effective)
                                                                                                                  - TRUNC
                                                                                                                      (ri2.to_conversion_date)),
                                                                                                              1),
                                                                                                          -1, 'EMU_TO_CURRENCY',
                                                                                                          0, 'EMU_TO_CURRENCY',
                                                                                                          ''))))))))))))))))))
                            FROM gl_daily_rates_interface ri2,
                                  gl_daily_conversion_types ct,
                                  fnd_currencies from_curr,
                                  fnd_currencies to_curr
                            WHERE ri2.ROWID = ri.ROWID
                              AND ct.user_conversion_type(+) = ri2.user_conversion_type
                              AND from_curr.currency_code(+) = ri2.from_currency
                    AND to_curr.currency_code(+) = ri2.to_currency)
            WHERE ri.mode_flag IN('I', 'D', 'T', 'N')
            AND ri.batch_number = l_batch_number;

      UPDATE GL_DAILY_RATES_INTERFACE T1
         SET T1.error_code = 'DUPLICATE_ROWS'
       WHERE
             (T1.FROM_CURRENCY,T1.TO_CURRENCY,T1.USER_CONVERSION_TYPE,
              T1.FROM_CONVERSION_DATE, T1.TO_CONVERSION_DATE)
         IN
             (
              SELECT /*+ NO_MERGE */ T2.FROM_CURRENCY,T2.to_CURRENCY,T2.USER_CONVERSION_TYPE,
                     T2.FROM_CONVERSION_DATE, T2.TO_CONVERSION_DATE
              FROM GL_DAILY_RATES_INTERFACE  T2
              WHERE mode_flag IN ('I', 'D', 'T', 'N')
	          GROUP BY T2.FROM_CURRENCY,T2.TO_CURRENCY,T2.USER_CONVERSION_TYPE,
                       T2.FROM_CONVERSION_DATE, T2.TO_CONVERSION_DATE
              HAVING count(*) > 1)
         AND mode_flag IN ('I', 'D', 'T', 'N')
         AND T1.batch_number = l_batch_number;

        END IF;

      -- added N and T for Treasury team
      -- N - no override GL rates
      -- T - Treasury Insert (override existing GL rates).
      /*
      -- Update mode flag to 'X' for each erroneous row
      UPDATE gl_daily_rates_interface
         SET mode_flag = 'X'
       WHERE mode_flag IN('I', 'D') AND ERROR_CODE IS NOT NULL;

      -- Update mode flag to 'X' for each erroneous row from Treasury
      UPDATE gl_daily_rates_interface
         SET mode_flag = 'F'
       WHERE mode_flag IN('T', 'N') AND ERROR_CODE IS NOT NULL;
      */


      -- Update mode flag to X/F for each erroneous row
      UPDATE gl_daily_rates_interface ri
      SET    mode_flag =
                Decode(mode_flag,'T','F','N','F','I','X','D','X',mode_flag)
      WHERE (mode_flag IN('T', 'N','I','D') AND batch_number = l_batch_number AND ERROR_CODE IS NOT NULL)
      OR    (mode_flag = 'N'
        AND (EXISTS (SELECT 1 FROM gl_daily_rates dr,
                                   gl_daily_conversion_types ct
                     WHERE  dr.from_currency         = ri.from_currency
                     AND    dr.to_currency           = ri.to_currency
                     AND    dr.conversion_type       = ct.conversion_type
                     AND    ct.user_conversion_type  = ri.user_conversion_type
                     AND    dr.conversion_date BETWEEN ri.from_conversion_date
                                               AND     ri.to_conversion_date)
         OR  EXISTS (SELECT 1 FROM gl_daily_rates dr,
                                   gl_daily_conversion_types ct
                     WHERE  dr.from_currency         = ri.to_currency
                     AND    dr.to_currency           = ri.from_currency
                     AND    dr.conversion_type       = ct.conversion_type
                     AND    ct.user_conversion_type  = ri.user_conversion_type
                     AND    dr.conversion_date BETWEEN ri.from_conversion_date
                                               AND     ri.to_conversion_date)));

      IF DEBUG_MODE THEN
          fnd_file.put_line(fnd_file.LOG,
                                    SQL%ROWCOUNT || ' Error records');
      END IF;

      BEGIN
        SELECT 'E'
        INTO   l_return_status
        FROM   gl_daily_rates_interface
        WHERE  mode_flag in ('X','F')
	AND batch_number = l_batch_number
        AND    ROWNUM < 2;

      EXCEPTION
            WHEN OTHERS THEN
                l_return_status := 'S';
      END;


      UPDATE gl_daily_rates_interface
         SET inverse_conversion_rate = 1 / conversion_rate
       WHERE inverse_conversion_rate IS NULL AND conversion_rate > 0
       AND batch_number = l_batch_number;

      IF DEBUG_MODE THEN
         fnd_file.put_line
                      (fnd_file.LOG,
                       'Finish Validation on GL_DAILY_RATES_INTERFACE table.');
      END IF;

      SELECT from_currency,
             to_currency,
             from_conversion_date,
             to_conversion_date,
             user_conversion_type,
             conversion_rate,
             inverse_conversion_rate,
             DECODE(ERROR_CODE,
                    'NONEXISTANT_CONVERSION_TYPE', 'VF01',
                    'DATE_RANGE_TOO_LARGE', 'VF02',
                    'NEGATIVE_CONVERSION_RATE', 'VF03',
                    'NEGATIVE_INVERSE_RATE', 'VF04',
                    'NONEXISTANT_FROM_CURRENCY', 'VF05',
                    'DISABLED_FROM_CURRENCY', 'VF06',
                    'STATISTICAL_FROM_CURRENCY', 'VF07',
                    'OUT_OF_DATE_FROM_CURRENCY', 'VF08',
                    'EMU_FROM_CURRENCY', 'VF09',
                    'NONEXISTANT_TO_CURRENCY', 'VF10',
                    'DISABLED_TO_CURRENCY', 'VF11',
                    'STATISTICAL_TO_CURRENCY', 'VF12',
                    'OUT_OF_DATE_TO_CURRENCY', 'VF13',
                    'EMU_TO_CURRENCY', 'VF14',
                    'DUPLICATE_ROWS','VF15',
                    'VF16')
      BULK COLLECT INTO daily_rate_validation_failure.r_from_curr,
             daily_rate_validation_failure.r_to_curr,
             daily_rate_validation_failure.r_from_date,
             daily_rate_validation_failure.r_to_date,
             daily_rate_validation_failure.r_type,
             daily_rate_validation_failure.r_rate,
             daily_rate_validation_failure.r_inverse_rate,
             daily_rate_validation_failure.r_error_code
        FROM gl_daily_rates_interface
       WHERE mode_flag IN('X', 'F')
       AND batch_number = l_batch_number;

      FOR i IN 1 .. daily_rate_validation_failure.r_from_curr.COUNT LOOP
         IF page_line_count = 1 THEN
            gl_crm_utilities_pkg.print_report_title;
            gl_crm_utilities_pkg.print_validation_failure;
         END IF;

         page_line_count := page_line_count + 1;
         fnd_file.put_line
                    (fnd_file.output,
                     RPAD(daily_rate_validation_failure.r_type(i), 31, ' ')
                     || RPAD(daily_rate_validation_failure.r_from_date(i), 15,
                             ' ')
                     || RPAD(daily_rate_validation_failure.r_to_date(i), 15,
                             ' ')
                     || RPAD(daily_rate_validation_failure.r_from_curr(i), 16,
                             ' ')
                     || RPAD(daily_rate_validation_failure.r_to_curr(i), 16,
                             ' ')
                     || LPAD(daily_rate_validation_failure.r_rate(i) || ' ',
                             13, ' ')
                     || LPAD
                            (daily_rate_validation_failure.r_inverse_rate(i)
                             || ' ',
                             13, ' ')
                     || RPAD(daily_rate_validation_failure.r_error_code(i),
                             14, ' '));

         IF page_line_count >= page_line_numbers - 2 THEN
            page_line_count := 1;
            page_count := page_count + 1;
            fnd_file.put_line(fnd_file.output, ' ');
            fnd_file.put_line(fnd_file.output, ' ');
         END IF;
      END LOOP;

      IF DEBUG_MODE THEN
         IF page_count * page_line_count = 1 THEN
            fnd_file.put_line(fnd_file.LOG, 'No Validation Failure.');
         ELSE
            fnd_file.put_line(fnd_file.LOG,
                              page_count * page_line_count - 1
                              || ' rows failed validation.');
         END IF;
      END IF;

      -- those validation already done by the Web ADI spreadsheet or OA pages
      -- we do this because customer may use sqlloader to upload this to
      -- interface table and then run Concurrent Program via SRS

      -- Check if average balances is used in the system

      --- will run the gl_rate_rates here, which will remove all the gl_daily_rates lines.
      fnd_profile.get('GL_CRM_CR_OVERRIDE', golden_rule_flag);

      IF DEBUG_MODE THEN
         gl_message.write_log('CRM0004', 1, 'VALUE', golden_rule_flag);
      END IF;

      IF (golden_rule_flag = 'SYSTEM') OR(golden_rule_flag = 'BOTH') THEN
         IF DEBUG_MODE THEN
            fnd_file.put_line
                           (fnd_file.LOG,
                            'Searching system rates that cannot be override.');
         END IF;

/*********************************************************************************
             Bug 4641250 JVARKEY Changed the following query
 *********************************************************************************/
         SELECT dr.from_currency,
                dr.to_currency,
                gldct.user_conversion_type,
                dr.conversion_date,
                dr.conversion_rate,
                dr.rate_source_code
         BULK COLLECT INTO sys_daily_rate_cannot_delete.r_from_curr,
                sys_daily_rate_cannot_delete.r_to_curr,
                sys_daily_rate_cannot_delete.r_type,
                sys_daily_rate_cannot_delete.r_conversion_date,
                sys_daily_rate_cannot_delete.r_rate,
                sys_daily_rate_cannot_delete.r_rate_source_code
           FROM gl_daily_rates dr,
                gl_daily_conversion_types gldct,
                gl_row_multipliers rm,
                gl_daily_conversion_types ct,
                gl_daily_rates_interface ri
          WHERE ri.mode_flag = 'D'
          AND ct.user_conversion_type = ri.user_conversion_type || ''
          AND rm.multiplier BETWEEN 1 AND (TRUNC(ri.to_conversion_date)
                                        - TRUNC(ri.from_conversion_date)
                                        + 1)
          AND ((dr.from_currency = ri.from_currency
            AND dr.to_currency = ri.to_currency)
            OR (dr.from_currency = ri.to_currency
            AND dr.to_currency = ri.from_currency))
          AND dr.conversion_type = ct.conversion_type
          AND dr.conversion_date = TRUNC(ri.from_conversion_date)+rm.multiplier-1
          AND dr.rate_source_code = 'SYSTEM'
          AND dr.conversion_type = gldct.conversion_type
          AND ri.batch_number = l_batch_number;

         IF DEBUG_MODE THEN
            IF sys_daily_rate_cannot_delete.r_from_curr.COUNT > 0 THEN
               fnd_file.put_line
                           (fnd_file.LOG,
                            sys_daily_rate_cannot_delete.r_from_curr.COUNT
                            || ' system rates found (which cannot be deleted)!');
            ELSE
               fnd_file.put_line
                           (fnd_file.LOG,
                            'No system rate found (which cannot be deleted)!');
            END IF;
         END IF;

         FOR i IN 1 .. sys_daily_rate_cannot_delete.r_from_curr.COUNT LOOP
            IF page_line_count = 1 THEN
               gl_crm_utilities_pkg.print_report_title;
               gl_crm_utilities_pkg.print_delete_user_rate_warning;
            ELSIF i = 1 THEN
               gl_crm_utilities_pkg.print_delete_user_rate_warning;
            END IF;

            page_line_count := page_line_count + 1;
            fnd_file.put_line
                    (fnd_file.output,
                     RPAD(sys_daily_rate_cannot_delete.r_type(i), 31, ' ')
                     || RPAD
                            (sys_daily_rate_cannot_delete.r_conversion_date(i),
                             30, ' ')
                     || RPAD(sys_daily_rate_cannot_delete.r_from_curr(i), 16,
                             ' ')
                     || RPAD(sys_daily_rate_cannot_delete.r_to_curr(i), 16,
                             ' ')
                     || LPAD(sys_daily_rate_cannot_delete.r_rate(i) || ' ',
                             13, ' ')
                     || RPAD
                           (sys_daily_rate_cannot_delete.r_rate_source_code(i),
                            26, ' '));

            IF page_line_count >= page_line_numbers - 2 THEN
               page_line_count := 1;
               page_count := page_count + 1;
               fnd_file.put_line(fnd_file.output, ' ');
               fnd_file.put_line(fnd_file.output, ' ');
            END IF;
         END LOOP;

/*********************************************************************************
                Bug 4641250 JVARKEY Changed the following query
 *********************************************************************************/

-- Bug 4746397 JVARKEY Changed the array variables
         SELECT dr.from_currency,
                dr.to_currency,
                gldct.user_conversion_type,
                dr.conversion_date,
                dr.conversion_rate,
                dr.rate_source_code
         BULK COLLECT INTO sys_daily_rate_cannot_override.r_from_curr,
                sys_daily_rate_cannot_override.r_to_curr,
                sys_daily_rate_cannot_override.r_type,
                sys_daily_rate_cannot_override.r_conversion_date,
                sys_daily_rate_cannot_override.r_rate,
                sys_daily_rate_cannot_override.r_rate_source_code
           FROM gl_daily_rates dr,
                gl_daily_conversion_types gldct,
                gl_row_multipliers rm,
                gl_daily_conversion_types ct,
                gl_daily_rates_interface ri
          WHERE ct.user_conversion_type = ri.user_conversion_type || ''
          AND rm.multiplier BETWEEN 1 AND (TRUNC(ri.to_conversion_date)
                                        - TRUNC(ri.from_conversion_date)
                                        + 1)
          AND ((dr.from_currency = ri.from_currency
            AND dr.to_currency = ri.to_currency
            AND ri.mode_flag in ('I','T'))
            OR (dr.from_currency = ri.to_currency
            AND dr.to_currency = ri.from_currency
            AND ri.mode_flag = 'I'))
          AND dr.conversion_type = ct.conversion_type
          AND dr.conversion_date = TRUNC(ri.from_conversion_date)+rm.multiplier-1
          AND dr.rate_source_code = 'SYSTEM'
          AND dr.conversion_type = gldct.conversion_type
          AND ri.batch_number = l_batch_number;

         FOR i IN 1 .. sys_daily_rate_cannot_override.r_from_curr.COUNT LOOP
            IF page_line_count = 1 THEN
               gl_crm_utilities_pkg.print_report_title;
               gl_crm_utilities_pkg.print_override_user_rate_warn;
            ELSIF i = 1 THEN
               gl_crm_utilities_pkg.print_override_user_rate_warn;
            END IF;

            page_line_count := page_line_count + 1;
            fnd_file.put_line
                  (fnd_file.output,
                   RPAD(sys_daily_rate_cannot_override.r_type(i), 31, ' ')
                   || RPAD
                          (sys_daily_rate_cannot_override.r_conversion_date(i),
                           30, ' ')
                   || RPAD(sys_daily_rate_cannot_override.r_from_curr(i), 16,
                           ' ')
                   || RPAD(sys_daily_rate_cannot_override.r_to_curr(i), 16,
                           ' ')
                   || LPAD(sys_daily_rate_cannot_override.r_rate(i) || ' ',
                           13, ' ')
                   || RPAD
                         (sys_daily_rate_cannot_override.r_rate_source_code(i),
                          26, ' '));

            IF page_line_count >= page_line_numbers - 2 THEN
               page_line_count := 1;
               page_count := page_count + 1;
               fnd_file.put_line(fnd_file.output, ' ');
               fnd_file.put_line(fnd_file.output, ' ');
            END IF;
         END LOOP;

         IF DEBUG_MODE THEN
            fnd_file.put_line
                       (fnd_file.LOG,
                        'Ended finding system rates that cannot be override.');
         END IF;
      END IF;

         -- Update used_for_ab_translation = 'Y' if the currency and
         -- conversion type is used in average translation in the system
         -- R12 Change in the following update
      UPDATE gl_daily_rates_interface ri
      SET used_for_ab_translation =
          ( SELECT nvl(max('Y'), 'N')
            FROM   gl_daily_conversion_types  ct,
                   gl_ledgers                 led,
                   gl_ledger_relationships    rel
            WHERE  ct.user_conversion_type = ri.user_conversion_type
            AND    rel.source_ledger_id = led.ledger_id
            AND    rel.target_ledger_id = led.ledger_id
            AND    rel.target_ledger_category_code = 'ALC'
            AND    rel.application_id = 101
            AND    led.currency_code IN (ri.from_currency, ri.to_currency)
            AND    rel.target_currency_code IN (ri.from_currency, ri.to_currency)
            AND    (   led.daily_translation_rate_type = ct.conversion_type
                    OR nvl(rel.alc_period_average_rate_type,
                           led.period_average_rate_type) = ct.conversion_type
                    OR nvl(rel.alc_period_end_rate_type,
                           led.period_end_rate_type) = ct.conversion_type)
            AND    ri.mode_flag IN ('I', 'D', 'T', 'N')
            AND    ri.batch_number = l_batch_number);

      BEGIN

          SELECT 'Y'
          INTO   l_launch_rate_change
          FROM   gl_daily_rates_interface
          WHERE  used_for_ab_translation = 'Y'
          AND    ROWNUM < 2;

      EXCEPTION

          WHEN OTHERS THEN

               l_launch_rate_change := 'N';

      END;

            IF DEBUG_MODE THEN
               fnd_file.put_line
                         (fnd_file.LOG,
                          'Marking D for rates meant to delete with types used for ab translation');
            END IF;

            UPDATE gl_daily_rates dr
               SET status_code = 'D'
             WHERE (   (dr.rate_source_code IS NULL)
                    OR (    dr.rate_source_code IN('USER', 'TREASURY')
                        AND golden_rule_flag <> 'USER')
                    OR      golden_rule_flag = 'USER')
               AND (dr.from_currency,
                    dr.to_currency,
                    dr.conversion_type,
                    dr.conversion_date) IN(
                      SELECT ri.from_currency, ri.to_currency, --direct rate
                             ct.conversion_type,
                             TRUNC(ri.from_conversion_date) + rm.multiplier
                             - 1
                        FROM gl_row_multipliers rm,
                             gl_daily_conversion_types ct,
                             gl_daily_rates_interface ri
                       WHERE ri.mode_flag = 'D'
                         AND ri.batch_number = l_batch_number
                         AND ri.used_for_ab_translation = 'Y'
                         AND ct.user_conversion_type =
                                                 ri.user_conversion_type || ''
                         AND rm.multiplier BETWEEN 1
                                               AND TRUNC
                                                        (ri.to_conversion_date)
                                                   - TRUNC
                                                       (ri.from_conversion_date)
                                                   + 1
                      UNION ALL
                      SELECT ri.to_currency, ri.from_currency,  --inverse rate
                             ct.conversion_type,
                             TRUNC(ri.from_conversion_date) + rm.multiplier
                             - 1
                        FROM gl_row_multipliers rm,
                             gl_daily_conversion_types ct,
                             gl_daily_rates_interface ri
                       WHERE ri.mode_flag = 'D'
                         AND ri.batch_number = l_batch_number
                         AND ri.used_for_ab_translation = 'Y'
                         AND ct.user_conversion_type =
                                                 ri.user_conversion_type || ''
                         AND rm.multiplier BETWEEN 1
                                               AND TRUNC
                                                        (ri.to_conversion_date)
                                                   - TRUNC
                                                       (ri.from_conversion_date)
                                                   + 1
                      );

            -- Delete existing rows with conversion rate in GL_DAILY_RATES
                 IF DEBUG_MODE THEN
                      fnd_file.put_line(fnd_file.LOG,
                                    SQL%ROWCOUNT || ' rows marked');
                      fnd_file.put_line
                                (fnd_file.LOG,
                                 'Deleting rates meant for insert and for deleted rates with types not used for ab translation');
                 END IF;

                 DELETE  gl_daily_rates dr
                  WHERE  (   (dr.rate_source_code IS NULL)
                      OR (    dr.rate_source_code IN('USER', 'TREASURY')
                          AND golden_rule_flag <> 'USER')
                      OR      golden_rule_flag = 'USER')
                    AND (dr.from_currency,
                         dr.to_currency,
                         dr.conversion_type,
                         dr.conversion_date) IN(
                           SELECT ri.from_currency, ri.to_currency, --direct rates
                                  ct.conversion_type,
                                  TRUNC(ri.from_conversion_date)
                                  + rm.multiplier - 1
                             FROM gl_row_multipliers rm,
                                  gl_daily_conversion_types ct,
                                  gl_daily_rates_interface ri
                            WHERE ri.batch_number = l_batch_number
                              AND (   ri.mode_flag IN('I', 'T')
                                   OR (    ri.mode_flag = 'D'
                                       AND ri.used_for_ab_translation <> 'Y'))
                              AND ct.user_conversion_type =
                                                 ri.user_conversion_type || ''
                              AND rm.multiplier BETWEEN 1
                                                    AND TRUNC
                                                           (ri.to_conversion_date)
                                                        - TRUNC
                                                            (ri.from_conversion_date)
                                                        + 1
                           UNION ALL
                           SELECT ri.to_currency, ri.from_currency,  --inverse rates
                                  ct.conversion_type,
                                  TRUNC(ri.from_conversion_date)
                                  + rm.multiplier - 1
                             FROM gl_row_multipliers rm,
                                  gl_daily_conversion_types ct,
                                  gl_daily_rates_interface ri
                            WHERE ri.batch_number = l_batch_number
                              AND (   ri.mode_flag IN('I', 'T')
                                   OR (    ri.mode_flag = 'D'
                                       AND ri.used_for_ab_translation <> 'Y'))
                              AND ct.user_conversion_type =
                                                 ri.user_conversion_type || ''
                              AND rm.multiplier BETWEEN 1
                                                    AND TRUNC
                                                           (ri.to_conversion_date)
                                                        - TRUNC
                                                            (ri.from_conversion_date)
                                                        + 1
                            );

                 IF DEBUG_MODE THEN
                      fnd_file.put_line(fnd_file.LOG,
                                    SQL%ROWCOUNT || ' rows deleted');
                 END IF;

         BEGIN
            -- Insert all rows with conversion rate
            IF DEBUG_MODE THEN
               fnd_file.put_line(fnd_file.LOG, 'Insert all rates.');
            END IF;

            INSERT INTO gl_daily_rates
                        (from_currency, to_currency, conversion_date,
                         conversion_type, conversion_rate, status_code,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login, CONTEXT,
                         attribute1, attribute2, attribute3, attribute4,
                         attribute5, attribute6, attribute7, attribute8,
                         attribute9, attribute10, attribute11, attribute12,
                         attribute13, attribute14, attribute15,
                         rate_source_code)
               SELECT ri.from_currency, ri.to_currency,  --direct rates
                      TRUNC(ri.from_conversion_date) + rm.multiplier - 1,
                      ct.conversion_type, ri.conversion_rate,
                      DECODE(ri.used_for_ab_translation, 'Y', 'O', 'C'),
                      SYSDATE, NVL(ri.user_id, 1), SYSDATE,
                      NVL(ri.user_id, 1), 1, ri.CONTEXT, ri.attribute1,
                      ri.attribute2, ri.attribute3, ri.attribute4,
                      ri.attribute5, ri.attribute6, ri.attribute7,
                      ri.attribute8, ri.attribute9, ri.attribute10,
                      ri.attribute11, ri.attribute12, ri.attribute13,
                      ri.attribute14, ri.attribute15,
                      DECODE(ri.mode_flag, 'T', 'TREASURY', 'N', 'TREASURY', 'USER')
                 FROM gl_row_multipliers rm,
                      gl_daily_conversion_types ct,
                      gl_daily_rates_interface ri
                WHERE ri.mode_flag IN('I', 'T', 'N')
                  AND ct.user_conversion_type = ri.user_conversion_type || ''
                  AND rm.multiplier BETWEEN 1
                                        AND TRUNC(ri.to_conversion_date)
                                            - TRUNC(ri.from_conversion_date)
                                            + 1
                  AND ri.batch_number = l_batch_number
                  AND NOT EXISTS(
                         SELECT 1
                           FROM gl_daily_rates dr
                          WHERE dr.from_currency = ri.from_currency
                            AND dr.to_currency = ri.to_currency
                            AND dr.conversion_type = ct.conversion_type
                            AND dr.conversion_date =
                                   TRUNC(ri.from_conversion_date)
                                   + rm.multiplier - 1)
               UNION ALL
               SELECT ri.to_currency, ri.from_currency,  --inverse rates
                      TRUNC(ri.from_conversion_date) + rm.multiplier - 1,
                      ct.conversion_type,
                      NVL(ri.inverse_conversion_rate, 1 / ri.conversion_rate),
                      DECODE(ri.used_for_ab_translation, 'Y', 'O', 'C'),
                      SYSDATE, NVL(ri.user_id, 1), SYSDATE,
                      NVL(ri.user_id, 1), 1, ri.CONTEXT, ri.attribute1,
                      ri.attribute2, ri.attribute3, ri.attribute4,
                      ri.attribute5, ri.attribute6, ri.attribute7,
                      ri.attribute8, ri.attribute9, ri.attribute10,
                      ri.attribute11, ri.attribute12, ri.attribute13,
                      ri.attribute14, ri.attribute15,
                      DECODE(ri.mode_flag, 'T', 'TREASURY', 'N', 'TREASURY', 'USER')
                 FROM gl_row_multipliers rm,
                      gl_daily_conversion_types ct,
                      gl_daily_rates_interface ri
                WHERE ri.mode_flag IN('I', 'T', 'N')
                  AND ct.user_conversion_type = ri.user_conversion_type || ''
                  AND rm.multiplier BETWEEN 1
                                        AND TRUNC(ri.to_conversion_date)
                                            - TRUNC(ri.from_conversion_date)
                                            + 1
                  AND ri.batch_number = l_batch_number
                  AND NOT EXISTS(
                         SELECT 1
                           FROM gl_daily_rates dr
                          WHERE dr.from_currency = ri.to_currency
                            AND dr.to_currency = ri.from_currency
                            AND dr.conversion_type = ct.conversion_type
                            AND dr.conversion_date =
                                   TRUNC(ri.from_conversion_date)
                                   + rm.multiplier - 1);

                 IF DEBUG_MODE THEN
                      fnd_file.put_line(fnd_file.LOG,
                                    SQL%ROWCOUNT || ' rows inserted');
                 END IF;

         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               l_error_message := SQLERRM;--for returning SQL Error Message in the BE
               l_return_status := 'U'; --for returning when Unexpected Error

               ekey := l_batch_number;
                           --Raise the Business Event when Unexpected Error
               gl_business_events.raise(
                                        p_event_name =>
                                        'oracle.apps.gl.CurrencyConversionRates.dailyRate.completeImport',
                                        /*'oracle.apps.gl.CurrencyConversionRates.dailyRate.specify',*/
                                        p_event_key => ekey,
                                        p_parameter_name1 => 'CORRELATION_ID',
                                        p_parameter_value1 => ekey,
                                        p_parameter_name2 => 'RETURN_STATUS',
                                        p_parameter_value2 => l_return_status,
                                        p_parameter_name3 => 'ERROR_MESSAGE',
                                        p_parameter_value3 => l_error_message
                                        );

               fnd_file.put_line
                     (fnd_file.LOG,
                      'Error: Duplicate Row or Overlapping Date Range found.');
               fnd_file.put_line
                     (fnd_file.output,
                      'Error: Duplicate Row or Overlapping Date Range found.');
               set_completion_status_result :=
                  fnd_concurrent.set_completion_status
                     ('ERROR',
                      'Error: Duplicate Row or Overlapping Date Range found.');
         END;

         -- Bug 4758732 JVARKEY Call to raise Business Events
         IF DEBUG_MODE THEN
               fnd_file.put_line(fnd_file.LOG, 'Firing Business events');
         END IF;

         FOR dri_rec in raise_buz_events LOOP

             raise_dr_buz_events(dri_rec.from_currency, dri_rec.to_currency,
                                 dri_rec.from_conversion_date, dri_rec.to_conversion_date,
                                 dri_rec.conversion_type, dri_rec.conversion_rate,
                                 dri_rec.inverse_conversion_rate, dri_rec.mode_flag);

         END LOOP;

         --- Cross Rates Calculation ---
         SELECT COUNT(*)
           INTO rows_need_calculation
           FROM gl_daily_rates_interface
          WHERE mode_flag IN('I', 'D', 'T', 'N')
            AND user_conversion_type IN(
                   SELECT user_conversion_type
                     FROM gl_daily_conversion_types gct,
                          gl_cross_rate_rules gcrs
                    WHERE gct.conversion_type = gcrs.conversion_type)
            AND batch_number = l_batch_number
            AND rownum < 2;

         IF DEBUG_MODE THEN
            IF rows_need_calculation = 0 THEN
               fnd_file.put_line(fnd_file.LOG,
                                 'NO need cross rate calculation.');
            ELSE
               fnd_file.put_line(fnd_file.LOG,
                                 'Cross rates calculation needed.');
            END IF;
         END IF;

         IF rows_need_calculation > 0 THEN
            -- Delete all valid rows in GL_DAILY_RATES_INTERFACE and do not need
            -- crossing rates calculation
            DELETE FROM gl_daily_rates_interface
                  WHERE mode_flag IN('I', 'D', 'T', 'N')
                    AND batch_number = l_batch_number
                    AND user_conversion_type NOT IN(
                           SELECT user_conversion_type
                             FROM gl_daily_conversion_types gct,
                                  gl_cross_rate_rules gcrs
                            WHERE gct.conversion_type = gcrs.conversion_type);

            gl_message.func_ent('Cross Rates Calculation');

            -- select all the lines who can be calculate cross rate from the gl_daily_rates table
            IF DEBUG_MODE THEN
               fnd_file.put_line(fnd_file.LOG, 'Clean gl_cross_rate_temp.');
            END IF;

            DELETE FROM gl_cross_rate_temp;

            IF DEBUG_MODE THEN
               fnd_file.put_line
                     (fnd_file.LOG,
                      'Copy rows from interface table to gl_cross_rate_temp.');
            END IF;

            INSERT INTO gl_cross_rate_temp
                        (conversion_type, pivot_currency, from_currency,
                         to_currency, from_conversion_date,
                         to_conversion_date, conversion_rate,
                         inverse_conversion_rate, mode_flag,
                         used_for_ab_translation)
               SELECT gldct.conversion_type,
                      DECODE(gldri.from_currency,
                             glcrs.pivot_currency, gldri.from_currency,
                             gldri.to_currency),
                      DECODE(gldri.from_currency,
                             glcrs.pivot_currency, gldri.to_currency,
                             gldri.from_currency),
                      glcrsd.to_currency, gldri.from_conversion_date,
                      gldri.to_conversion_date,
                      DECODE(gldri.from_currency,
                             glcrs.pivot_currency, gldri.conversion_rate,
                             gldri.inverse_conversion_rate),
                      DECODE(gldri.from_currency,
                             glcrs.pivot_currency, gldri.inverse_conversion_rate,
                             gldri.conversion_rate),
                      DECODE(gldri.mode_flag, 'D', 'D', 'I'),
                      gldri.used_for_ab_translation
                 FROM gl_daily_rates_interface gldri,
                      gl_daily_conversion_types gldct,
                      gl_cross_rate_rules glcrs,
                      gl_cross_rate_rule_dtls glcrsd
                WHERE gldri.mode_flag IN('I', 'D', 'T', 'N')
                  AND gldri.user_conversion_type = gldct.user_conversion_type
                  AND gldct.conversion_type = glcrs.conversion_type
                  AND (   (    (gldri.from_currency = glcrs.pivot_currency)
                           AND (gldri.to_currency IN(
                                   SELECT DISTINCT from_currency
                                              FROM gl_cross_rate_rule_dtls glcrsd2
                                             WHERE glcrs.conversion_type =
                                                       glcrsd2.conversion_type
                                               --AND glcrs.pivot_currency = glcrsd2.pivot_currency
                                               AND glcrsd2.enabled_flag = 'Y')))
                       OR (    (gldri.to_currency = glcrs.pivot_currency)
                           AND (gldri.from_currency IN(
                                   SELECT DISTINCT from_currency
                                              FROM gl_cross_rate_rule_dtls glcrsd3
                                             WHERE glcrs.conversion_type =
                                                       glcrsd3.conversion_type
                                               --AND glcrs.pivot_currency = glcrsd3.pivot_currency
                                               AND glcrsd3.enabled_flag = 'Y'))))
                  AND glcrsd.conversion_type = gldct.conversion_type
                  AND glcrs.pivot_currency =
                         DECODE(gldri.from_currency,
                                glcrs.pivot_currency, gldri.from_currency,
                                gldri.to_currency)
                  AND glcrsd.from_currency =
                         DECODE(gldri.from_currency,
                                glcrs.pivot_currency, gldri.to_currency,
                                gldri.from_currency)
                  AND glcrsd.enabled_flag = 'Y'
                  AND gldri.batch_number = l_batch_number;

            IF DEBUG_MODE THEN
               fnd_file.put_line(fnd_file.LOG, 'Update the used for ab translation');
            END IF;

            UPDATE gl_cross_rate_temp ri
            SET used_for_ab_translation =
                ( SELECT nvl(max('Y'), 'N')
                  FROM   gl_daily_conversion_types  ct,
                         gl_ledgers                 led,
                         gl_ledger_relationships    rel
                  WHERE  ct.conversion_type = ri.conversion_type
                  AND    rel.source_ledger_id = led.ledger_id
                  AND    rel.target_ledger_id = led.ledger_id
                  AND    rel.target_ledger_category_code = 'ALC'
                  AND    rel.application_id = 101
                  AND    led.currency_code IN (ri.from_currency, ri.to_currency)
                  AND    rel.target_currency_code IN (ri.from_currency, ri.to_currency)
                  AND    (   led.daily_translation_rate_type = ct.conversion_type
                          OR nvl(rel.alc_period_average_rate_type,
                                 led.period_average_rate_type) = ct.conversion_type
                          OR nvl(rel.alc_period_end_rate_type,
                                 led.period_end_rate_type) = ct.conversion_type)
                  AND    ri.mode_flag IN ('I', 'D', 'T', 'N'));

            IF (l_launch_rate_change = 'N') THEN

                  BEGIN

                      SELECT 'Y'
                      INTO   l_launch_rate_change
                      FROM   gl_cross_rate_temp
                      WHERE  used_for_ab_translation = 'Y'
                      AND    ROWNUM < 2;

                  EXCEPTION

                      WHEN OTHERS THEN

                           l_launch_rate_change := 'N';

                  END;

            END IF;

            IF ((golden_rule_flag = 'USER') OR(golden_rule_flag = 'BOTH')) THEN
               -- user defined rates overrides, user defined rates rules
               IF DEBUG_MODE THEN
                  fnd_file.put_line
                     (fnd_file.LOG,
                      'User Rate Rule or Both Rule; Checking if any user-defined rates cannot been cross-deleted.');
               END IF;

               SELECT DISTINCT gldr.from_currency,
                               gldr.to_currency,
                               gldct.user_conversion_type,
                               gldr.conversion_date,
                               gldr.conversion_rate,
                               gldr.rate_source_code
               BULK COLLECT INTO usr_daily_rate_cannot_delete.r_from_curr,
                               usr_daily_rate_cannot_delete.r_to_curr,
                               usr_daily_rate_cannot_delete.r_type,
                               usr_daily_rate_cannot_delete.r_conversion_date,
                               usr_daily_rate_cannot_delete.r_rate,
                               usr_daily_rate_cannot_delete.r_rate_source_code
                          FROM gl_daily_rates gldr,
                               gl_daily_conversion_types gldct,
                               gl_cross_rate_temp glcrt,
                               gl_row_multipliers glrm
                         WHERE gldr.conversion_type = gldct.conversion_type
                           AND (   (gldr.rate_source_code IS NULL)
                                OR (    (gldr.rate_source_code IS NOT NULL)
                                    AND (gldr.rate_source_code IN
                                                          ('USER', 'TREASURY'))))
                           AND glcrt.mode_flag = 'D'
                           AND (   (    (gldr.from_currency =
                                                           glcrt.from_currency)
                                    AND (gldr.to_currency = glcrt.to_currency))
                                OR (    (gldr.to_currency =
                                                           glcrt.from_currency)
                                    AND (gldr.from_currency =
                                                             glcrt.to_currency)))
                           AND gldr.conversion_type = glcrt.conversion_type
                           AND gldr.conversion_date =
                                  TRUNC(glcrt.from_conversion_date)
                                  + glrm.multiplier - 1
                           AND glrm.multiplier BETWEEN 1
                                                   AND TRUNC
                                                          (glcrt.to_conversion_date)
                                                       - TRUNC
                                                           (glcrt.from_conversion_date)
                                                       + 1;

               FOR i IN 1 .. usr_daily_rate_cannot_delete.r_from_curr.COUNT LOOP
                  IF page_line_count = 1 THEN
                     gl_crm_utilities_pkg.print_report_title;
                     gl_crm_utilities_pkg.print_delete_sys_rate_warning;
                  ELSIF i = 1 THEN
                     gl_crm_utilities_pkg.print_delete_sys_rate_warning;
                  END IF;

                  page_line_count := page_line_count + 1;
                  fnd_file.put_line
                     (fnd_file.output,
                      RPAD(usr_daily_rate_cannot_delete.r_type(i), 31, ' ')
                      || RPAD
                            (usr_daily_rate_cannot_delete.r_conversion_date(i),
                             30, ' ')
                      || RPAD(usr_daily_rate_cannot_delete.r_from_curr(i), 16,
                              ' ')
                      || RPAD(usr_daily_rate_cannot_delete.r_to_curr(i), 16,
                              ' ')
                      || LPAD(usr_daily_rate_cannot_delete.r_rate(i) || ' ',
                              13, ' ')
                      || RPAD
                           (usr_daily_rate_cannot_delete.r_rate_source_code(i),
                            26, ' '));

                  IF page_line_count >= page_line_numbers - 2 THEN
                     page_line_count := 1;
                     page_count := page_count + 1;
                     fnd_file.put_line(fnd_file.output, ' ');
                     fnd_file.put_line(fnd_file.output, ' ');
                  END IF;
               END LOOP;

               SELECT DISTINCT gldr.from_currency,
                               gldr.to_currency,
                               gldct.user_conversion_type,
                               gldr.conversion_date,
                               gldr.conversion_rate,
                               gldr.rate_source_code
               BULK COLLECT INTO usr_daily_rate_cannot_override.r_from_curr,
                               usr_daily_rate_cannot_override.r_to_curr,
                               usr_daily_rate_cannot_override.r_type,
                               usr_daily_rate_cannot_override.r_conversion_date,
                               usr_daily_rate_cannot_override.r_rate,
                               usr_daily_rate_cannot_override.r_rate_source_code
                          FROM gl_daily_rates gldr,
                               gl_daily_conversion_types gldct,
                               gl_cross_rate_temp glcrt,
                               gl_row_multipliers glrm
                         WHERE gldr.conversion_type = gldct.conversion_type
                           AND (   (gldr.rate_source_code IS NULL)
                                OR (    (gldr.rate_source_code IS NOT NULL)
                                    AND (gldr.rate_source_code IN
                                                          ('USER', 'TREASURY'))))
                           AND glcrt.mode_flag in ('I', 'T', 'N')
                           AND (   (    (gldr.from_currency =
                                                           glcrt.from_currency)
                                    AND (gldr.to_currency = glcrt.to_currency))
                                OR (    (gldr.to_currency =
                                                           glcrt.from_currency)
                                    AND (gldr.from_currency =
                                                             glcrt.to_currency)))
                           AND gldr.conversion_type = glcrt.conversion_type
                           AND gldr.conversion_date =
                                  TRUNC(glcrt.from_conversion_date)
                                  + glrm.multiplier - 1
                           AND glrm.multiplier BETWEEN 1
                                                   AND TRUNC
                                                          (glcrt.to_conversion_date)
                                                       - TRUNC
                                                           (glcrt.from_conversion_date)
                                                       + 1;

               FOR i IN 1 .. usr_daily_rate_cannot_override.r_from_curr.COUNT LOOP
                  IF page_line_count = 1 THEN
                     gl_crm_utilities_pkg.print_report_title;
                     gl_crm_utilities_pkg.print_override_sys_rate_warn;
                  ELSIF i = 1 THEN
                     gl_crm_utilities_pkg.print_override_sys_rate_warn;
                  END IF;

                  page_line_count := page_line_count + 1;
                  fnd_file.put_line
                     (fnd_file.output,
                      RPAD(usr_daily_rate_cannot_override.r_type(i), 31, ' ')
                      || RPAD
                           (usr_daily_rate_cannot_override.r_conversion_date
                                                                            (i),
                            30, ' ')
                      || RPAD(usr_daily_rate_cannot_override.r_from_curr(i),
                              16, ' ')
                      || RPAD(usr_daily_rate_cannot_override.r_to_curr(i), 16,
                              ' ')
                      || LPAD(usr_daily_rate_cannot_override.r_rate(i) || ' ',
                              13, ' ')
                      || RPAD
                           (usr_daily_rate_cannot_override.r_rate_source_code
                                                                            (i),
                            26, ' '));

                  IF page_line_count >= page_line_numbers - 2 THEN
                     page_line_count := 1;
                     page_count := page_count + 1;
                     fnd_file.put_line(fnd_file.output, ' ');
                     fnd_file.put_line(fnd_file.output, ' ');
                  END IF;
               END LOOP;
            END IF;

               -- if golden rule as user override, that's user rates rile, we can only delete SYSTEM rates
               IF DEBUG_MODE THEN
                  fnd_file.put_line
                     (fnd_file.LOG,
                      'Mark D for Cross Rates');
               END IF;

               -- For each row with conversion rate in
               -- GL_DAILY_RATES_INTERFACE where mode = 'D',
               -- set status_code to 'D' in the corresponding row in GL_DAILY_RATES.
               UPDATE gl_daily_rates gldr
                  SET status_code = 'D'
                WHERE (   (gldr.rate_source_code IS NOT NULL
                       AND gldr.rate_source_code = 'SYSTEM'
                       AND golden_rule_flag <> 'SYSTEM')
                        OR golden_rule_flag = 'SYSTEM')
                  AND (gldr.from_currency,
                       gldr.to_currency,
                       gldr.conversion_type,
                       gldr.conversion_date) IN(
                         SELECT glcrt.from_currency, glcrt.to_currency, --direct rates
                                glcrt.conversion_type,
                                TRUNC(glcrt.from_conversion_date)
                                + glrm.multiplier - 1
                           FROM gl_row_multipliers glrm,
                                gl_cross_rate_temp glcrt,
                                gl_daily_rates gldr
                          WHERE glcrt.mode_flag = 'D'
                            AND glcrt.used_for_ab_translation = 'Y'
                            AND gldr.from_currency = glcrt.from_currency
                            AND gldr.to_currency = glcrt.to_currency
                            AND gldr.conversion_type = glcrt.conversion_type
                            AND gldr.conversion_date =
                                   TRUNC(glcrt.from_conversion_date)
                                   + glrm.multiplier - 1
                            AND glrm.multiplier BETWEEN 1
                                                    AND TRUNC
                                                           (glcrt.to_conversion_date)
                                                        - TRUNC
                                                            (glcrt.from_conversion_date)
                                                        + 1
                         UNION ALL
                         SELECT glcrt.to_currency, glcrt.from_currency, -- inverse rates
                                glcrt.conversion_type,
                                TRUNC(glcrt.from_conversion_date)
                                + glrm.multiplier - 1
                           FROM gl_row_multipliers glrm,
                                gl_cross_rate_temp glcrt,
                                gl_daily_rates gldr
                          WHERE glcrt.mode_flag = 'D'
                            AND glcrt.used_for_ab_translation = 'Y'
                            AND gldr.to_currency = glcrt.from_currency
                            AND gldr.from_currency = glcrt.to_currency
                            AND gldr.conversion_type = glcrt.conversion_type
                            AND gldr.conversion_date =
                                   TRUNC(glcrt.from_conversion_date)
                                   + glrm.multiplier - 1
                            AND glrm.multiplier BETWEEN 1
                                                    AND TRUNC
                                                           (glcrt.to_conversion_date)
                                                        - TRUNC
                                                            (glcrt.from_conversion_date)
                                                        + 1
                         );

               IF DEBUG_MODE THEN
                  fnd_file.put_line(fnd_file.LOG,
                                    SQL%ROWCOUNT || ' rows marked.');
                  fnd_file.put_line
                     (fnd_file.LOG,
                      'Delete for Cross Rates');
               END IF;

               DELETE FROM gl_daily_rates gldr
                     WHERE (   (gldr.rate_source_code IS NOT NULL
                            AND gldr.rate_source_code = 'SYSTEM'
                            AND golden_rule_flag <> 'SYSTEM')
                             OR golden_rule_flag = 'SYSTEM')
                       AND (gldr.from_currency,
                            gldr.to_currency,
                            gldr.conversion_type,
                            gldr.conversion_date) IN(
                              SELECT glcrt.from_currency, glcrt.to_currency,
                                     glcrt.conversion_type,
                                     TRUNC(glcrt.from_conversion_date)
                                     + glrm.multiplier - 1
                                FROM gl_row_multipliers glrm,
                                     gl_cross_rate_temp glcrt,
                                     gl_daily_rates gldr
                               WHERE (   glcrt.mode_flag in ('I', 'T')
                                      OR (    glcrt.mode_flag = 'D'
                                          AND glcrt.used_for_ab_translation <>
                                                                           'Y'))
                                 AND gldr.from_currency = glcrt.from_currency
                                 AND gldr.to_currency = glcrt.to_currency
                                 AND gldr.conversion_type =
                                                         glcrt.conversion_type
                                 AND gldr.conversion_date =
                                        TRUNC(glcrt.from_conversion_date)
                                        + glrm.multiplier - 1
                                 AND glrm.multiplier BETWEEN 1
                                                         AND TRUNC
                                                                (glcrt.to_conversion_date)
                                                             - TRUNC
                                                                 (glcrt.from_conversion_date)
                                                             + 1
                              UNION ALL
                              SELECT glcrt.to_currency, glcrt.from_currency,
                                     glcrt.conversion_type,
                                     TRUNC(glcrt.from_conversion_date)
                                     + glrm.multiplier - 1
                                FROM gl_row_multipliers glrm,
                                     gl_cross_rate_temp glcrt,
                                     gl_daily_rates gldr
                               WHERE (   glcrt.mode_flag in ('I', 'T')
                                      OR (    glcrt.mode_flag = 'D'
                                          AND glcrt.used_for_ab_translation <>
                                                                           'Y'))
                                 AND gldr.to_currency = glcrt.from_currency
                                 AND gldr.from_currency = glcrt.to_currency
                                 AND gldr.conversion_type =
                                                         glcrt.conversion_type
                                 AND gldr.conversion_date =
                                        TRUNC(glcrt.from_conversion_date)
                                        + glrm.multiplier - 1
                                 AND glrm.multiplier BETWEEN 1
                                                         AND TRUNC
                                                                (glcrt.to_conversion_date)
                                                             - TRUNC
                                                                 (glcrt.from_conversion_date)
                                                             + 1
                              );

               IF DEBUG_MODE THEN
                  fnd_file.put_line(fnd_file.LOG,
                                    SQL%ROWCOUNT || ' rows deleted.');
               END IF;

               UPDATE gl_cross_rate_temp rt
               SET    mode_flag = 'F'
               WHERE  mode_flag = 'N'
               AND   (EXISTS (SELECT 1 FROM gl_daily_rates dr
                              WHERE  dr.from_currency         = rt.from_currency
                              AND    dr.to_currency           = rt.to_currency
                              AND    dr.conversion_type       = rt.conversion_type
                              AND    dr.conversion_date BETWEEN rt.from_conversion_date
                                                        AND     rt.to_conversion_date)
                  OR  EXISTS (SELECT 1 FROM gl_daily_rates dr
                              WHERE  dr.from_currency         = rt.to_currency
                              AND    dr.to_currency           = rt.from_currency
                              AND    dr.conversion_type       = rt.conversion_type
                              AND    dr.conversion_date BETWEEN rt.from_conversion_date
                                                        AND     rt.to_conversion_date));

            BEGIN
               IF DEBUG_MODE THEN
                  fnd_file.put_line(fnd_file.LOG,
                                    'creating all cross rates ....');
               END IF;

               INSERT INTO gl_daily_rates
                           (from_currency, to_currency, conversion_date,
                            conversion_type, conversion_rate, status_code,
                            creation_date, created_by, last_update_date,
                            last_updated_by, last_update_login,
                            rate_source_code)
                  SELECT glcrt.from_currency, glcrt.to_currency,
                         TRUNC(glcrt.from_conversion_date) + glrm.multiplier
                         - 1,
                         glcrt.conversion_type,
                         glcrt.inverse_conversion_rate * gldr.conversion_rate,
                         DECODE(glcrt.used_for_ab_translation, 'Y', 'O', 'C'),
                         SYSDATE, 1, SYSDATE, 1, 1, 'SYSTEM'
                    FROM gl_row_multipliers glrm,
                         gl_cross_rate_temp glcrt,
                         gl_daily_rates gldr
                   WHERE glcrt.mode_flag in ('I', 'T', 'N')
                     AND gldr.from_currency = glcrt.pivot_currency
                     AND gldr.to_currency = glcrt.to_currency
                     AND gldr.conversion_type = glcrt.conversion_type
                     AND gldr.conversion_date =
                            TRUNC(glcrt.from_conversion_date)
                            + glrm.multiplier - 1
                     AND glrm.multiplier BETWEEN 1
                                             AND TRUNC
                                                     (glcrt.to_conversion_date)
                                                 - TRUNC
                                                     (glcrt.from_conversion_date)
                                                 + 1
                     AND (   NOT EXISTS(
                                SELECT 1
                                  FROM gl_daily_rates dr
                                 WHERE dr.from_currency = glcrt.from_currency
                                   AND dr.to_currency = glcrt.to_currency
                                   AND dr.conversion_type =
                                                         glcrt.conversion_type
                                   AND dr.conversion_date =
                                          TRUNC(glcrt.from_conversion_date)
                                          + glrm.multiplier - 1)
                          OR NOT EXISTS(
                                SELECT 1
                                  FROM gl_daily_rates dr
                                 WHERE dr.from_currency = glcrt.to_currency
                                   AND dr.to_currency = glcrt.from_currency
                                   AND dr.conversion_type =
                                                         glcrt.conversion_type
                                   AND dr.conversion_date =
                                          TRUNC(glcrt.from_conversion_date)
                                          + glrm.multiplier - 1))
                  UNION
                  SELECT glcrt.to_currency, glcrt.from_currency,
                         TRUNC(glcrt.from_conversion_date) + glrm.multiplier
                         - 1,
                         glcrt.conversion_type,
                         glcrt.conversion_rate * gldr.conversion_rate,
                         DECODE(glcrt.used_for_ab_translation, 'Y', 'O', 'C'),
                         SYSDATE, 1, SYSDATE, 1, 1, 'SYSTEM'
                    FROM gl_row_multipliers glrm,
                         gl_cross_rate_temp glcrt,
                         gl_daily_rates gldr
                   WHERE glcrt.mode_flag in ('I', 'T', 'N')
                     AND gldr.to_currency = glcrt.pivot_currency
                     AND gldr.from_currency = glcrt.to_currency
                     AND gldr.conversion_type = glcrt.conversion_type
                     AND gldr.conversion_date =
                            TRUNC(glcrt.from_conversion_date)
                            + glrm.multiplier - 1
                     AND glrm.multiplier BETWEEN 1
                                             AND TRUNC
                                                     (glcrt.to_conversion_date)
                                                 - TRUNC
                                                     (glcrt.from_conversion_date)
                                                 + 1
                     AND (   NOT EXISTS(
                                SELECT 1
                                  FROM gl_daily_rates dr
                                 WHERE dr.from_currency = glcrt.from_currency
                                   AND dr.to_currency = glcrt.to_currency
                                   AND dr.conversion_type =
                                                         glcrt.conversion_type
                                   AND dr.conversion_date =
                                          TRUNC(glcrt.from_conversion_date)
                                          + glrm.multiplier - 1)
                          OR NOT EXISTS(
                                SELECT 1
                                  FROM gl_daily_rates dr
                                 WHERE dr.from_currency = glcrt.to_currency
                                   AND dr.to_currency = glcrt.from_currency
                                   AND dr.conversion_type =
                                                         glcrt.conversion_type
                                   AND dr.conversion_date =
                                          TRUNC(glcrt.from_conversion_date)
                                          + glrm.multiplier - 1));


               IF DEBUG_MODE THEN
                  fnd_file.put_line(fnd_file.LOG,
                                    SQL%ROWCOUNT || ' rows inserted.');
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  ROLLBACK;
                  l_error_message := SQLERRM;--for returning SQL Error Message in the BE
                  l_return_status := 'U'; --for returning when Unexpected Error

                  ekey := l_batch_number;
                  --Raise the Business Event when Unexpected Error
                  gl_business_events.raise(
                                           p_event_name =>
                                           'oracle.apps.gl.CurrencyConversionRates.dailyRate.completeImport',
                                           /*'oracle.apps.gl.CurrencyConversionRates.dailyRate.specify',*/
                                           p_event_key => ekey,
                                           p_parameter_name1 => 'CORRELATION_ID',
                                           p_parameter_value1 => ekey,
                                           p_parameter_name2 => 'RETURN_STATUS',
                                           p_parameter_value2 => l_return_status,
                                           p_parameter_name3 => 'ERROR_MESSAGE',
                                           p_parameter_value3 => l_error_message
                                          );

                  gl_message.write_log('CRM0002', 0);
                  fnd_file.put_line
                     (fnd_file.LOG,
                      'Error: Duplicate Row or Overlapping Date Range found.');
                  fnd_file.put_line
                     (fnd_file.output,
                      'Error: Duplicate Row or Overlapping Date Range found.');
                  set_completion_status_result :=
                     fnd_concurrent.set_completion_status
                        ('ERROR',
                         'Error: Duplicate Row or Overlapping Date Range found.');
            END;

            gl_message.func_succ('Cross Rates Calculation');
         END IF;

         ---- End Calculation

         DELETE FROM gl_daily_rates_interface
               WHERE mode_flag IN('I', 'D', 'T', 'N')
               AND batch_number = l_batch_number;

         -- Launch the Rate Change Program if needed
         IF (l_launch_rate_change = 'Y') THEN

               IF DEBUG_MODE THEN
                  fnd_file.put_line(fnd_file.LOG,
                                    'Launching Rate Change Program');
               END IF;

            RESULT := fnd_request.set_mode(TRUE);

            -- Launch concurrent request to run the Rate Change Program
            req_id :=
               fnd_request.submit_request('SQLGL', 'GLTTRC', '', '', FALSE,
                                          'D', '', CHR(0), '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '', '', '', '', '', '', '', '',
                                          '', '');
         END IF;

      IF page_count * page_line_count > 1 THEN
         gl_crm_utilities_pkg.print_validation_failure_codes;
         set_completion_status_result :=
            fnd_concurrent.set_completion_status
                   ('WARNING',
                    'Exceptions occurs, please check the output for details.');
      END IF;

      DELETE FROM gl_daily_rates_interface
            WHERE mode_flag IN('I', 'D', 'T', 'N')
            AND batch_number = l_batch_number;

                 --ekey := req_id;
                 ekey := l_batch_number;
            --Raise the Business Event
             gl_business_events.raise(
                            p_event_name =>
                            'oracle.apps.gl.CurrencyConversionRates.dailyRate.completeImport',
                             /*'oracle.apps.gl.CurrencyConversionRates.dailyRate.specify',*/
                            p_event_key => ekey,
                            p_parameter_name1 => 'CORRELATION_ID',
                            p_parameter_value1 => ekey,
                            p_parameter_name2 => 'RETURN_STATUS',
                            p_parameter_value2 => l_return_status,
                            p_parameter_name3 => 'ERROR_MESSAGE',
                            p_parameter_value3 => l_error_message
                            );
      END daily_rates_import;
-------------------------------------------------------------------
   FUNCTION submit_conc_request
      RETURN NUMBER IS
      RESULT   NUMBER := -1;
   BEGIN
      -- Submit the request to run Rate Change concurrent program
      RESULT :=
         fnd_request.submit_request('SQLGL', 'GLDRICCP', '', '', FALSE,
                                    CHR(0), '', '', '', '', '', '', '', '',
                                    '', '', '', '', '', '', '', '', '', '',
                                    '', '', '', '', '', '', '', '', '', '',
                                    '', '', '', '', '', '', '', '', '', '',
                                    '', '', '', '', '', '', '', '', '', '',
                                    '', '', '', '', '', '', '', '', '', '',
                                    '', '', '', '', '', '', '', '', '', '',
                                    '', '', '', '', '', '', '', '', '', '',
                                    '', '', '', '', '', '', '', '', '', '',
                                    '', '', '', '', '', '', '', '', '', '',
                                    '');
      RETURN(RESULT);
   END submit_conc_request;
END GL_CRM_UTILITIES_PKG;

/
