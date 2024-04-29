--------------------------------------------------------
--  DDL for Package Body PN_INDEX_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INDEX_AMOUNT_PKG" AS
-- $Header: PNINAMTB.pls 120.39.12010000.2 2008/09/04 12:25:58 mumohan ship $
-- +===========================================================================+
-- |                   Copyright (c) 2001 Oracle Corporation
-- |                      Redwood Shores, California, USA
-- |                            All rights reserved.
-- +===========================================================================+
-- | Name
-- |  pn_index_amount_pkg
-- |
-- | Description
-- |  This package contains procedures used to calculate index amounts.
-- |
-- | History
-- | 27-MAR-01 jreyes    Created
-- | 19-JUN-01 jreyes    Adding call to create schedules and items..
-- | 21-JUN-01 jreyes    Adding call to get amount precision from fnd_currency.get_info...
-- | 24-JUN-01 jreyes    Opened increase on types to all payment term types (LOOKUP Code: PN_PAYMENT_TERM_TYPE)
-- | 04-JUL-01 jreyes    Removed references to _MM procedures
-- | 24-JUL-01 psidhu    Removed code_code_combinaton_id from call to
-- |                     PNT_PAYMENT_TERMS_PKG.Insert_Row.
-- | 03-AUG-01 psidhu    Added WHENEVER SQLERROR EXIT FAILURE ROLLBACK and
-- |                     WHENEVER OSERROR  EXIT FAILURE ROLLBACK.
-- | 07-AUG-01 psidhu    Added code for aggregation functionality.
-- |                     Added public function build_distributions_string
-- |                     Procedure create_payment_term_rec_aggr
-- |                     modified the following packages:
-- |                     - sum_payment_items
-- |                     - chk_normalized_amount
-- |                     - create_payment_term_record
-- | 29-AUG-01 psidhu    Added procedure CREATE_AGGR_PAYMENT_TERM
-- | 13-NOV-01 ahhkumar  Fix for Bug 2101480 In the Procedure Calculate_initial_basis
-- |                     pass the parameter p_include_index_items as 'N' in call to sum_payment_terms
-- | 14-NOV-01 ahhkumar  Fix for Bug 2102073 in the procedure update_index_hist_line_batch initialise the
-- |                     variable v_index_percent_change as null
-- | 05-dEC-01 achauhan  Fix for aggregation - Made changes to create_aggr_payment_terms for
-- |                     aggregation functionality and also to sum_payment_items, for
-- |                     calculation of annualized basis.
-- | 06-DEC-01 achauhan  In approve_index_pay_term added code to update pn_index_lease_terms
-- | 12-DEC-01 achauhan  Added the condition to pick up approved rent increase terms, in the
-- |                     sum_payment_items routine.
-- | 15-JAN-02 mmisra    Added dbdrv command.
-- | 01-FEB-02 achauhan  Commented out NOCOPY the calls to print_payment_terms and print_basis_periods
-- | 01-FEB-02 Mrinal    Added checkfile command.
-- | 24-FEB-02 psidhu    Fix for bug# 2227270. Removed code to default GL accounts from the main lease
-- |                     while creating index rent terms in procedure create_payment_term_record.
-- | 06-MAY-02 psidhu    Fix for bug 2352453 and 2356045.
-- | 19-JUL-02 psidhu    Fix for bug# 2452909. Added procedure process_currency_code.
-- | 01-AUG-02 psidhu    Changes for carry forward funtionality. Added paramters p_index_period_id,
-- |                     p_carry_forward_flag,op_constraint_applied_amount,op_carry_forward_amount
-- |                     to derive_constrained_rent. Added functions derive_carry_forward_amount,
-- |                     derive_prev_negative_rent,get_increase_over_constraint and get_max_assessment_dt.
-- |                     Added procedure calculate_subsequent_periods.
-- | 17-OCT-02 psidhu    Changes for carry forward funtionality.Removed function derive_carry_forward_amount.
-- |                     Added function derive_cum_carry_forward.Added parameter op_constraint_applied_percent
-- |                     and op_carry_forward_percent to procedure calculate_period.Made changes to procedure
-- |                     derive_constrained_rent to handle cumulative carry forward in percent.
-- |                     Added parameter op_carry_forward_percent and op_constraint_applied_percent.
-- | 31-OCT-02 ahhkumar  BUG#2593961 edit procedure create_payment_terms  pass the
-- |                     parmeter p_include_index_items ='N'
-- |                     in sum_payment_items where p_basis_type = c_basis_type_compound
-- | 03-JAN-03 mmisra    Put check to validate term template in calculate_batch and
-- |                     calculate_period.
-- | 14-AUG-03 ftanudja  Handled untouched index lease payment terms. #3027574.
-- | 23-OCT-03 ftanudja  Fixed message logging logic in calculate.#3209774.
-- | 11-NOV-03 ftanudja  Take into account only approved terms for cursor
-- |                     fetch_generated_il_terms in create_aggr... #3243150.
-- | 18-FEB-04 ftanudja  Added parameter for create_payment_term_record.
-- |                     #3255737. Consolidated logic for updating initial
-- |                     basis in calculate_basis_amount, calculate_period.
-- |                     # 3436147
-- | 27-MAY-04 vmmehta  Fix for bug# 3562600.
-- |                    Procedure calculate: Call calculate_initial_basis if retain_initial_basis_flag not set and update initial basis.
-- |                    Procedure calculate_period: Removed update initial_basis as it is done in calculculate.
-- |                    Procedure calculate_basis_amount: Code changes to use initial basis as basis amount for
-- |                    first period for all basis types
-- | 13-Jul-04 ftanudja o Added parameter ip_auto_find_sch_day in
-- |                      approve_index_pay_term_batch. #3701195.
-- | 08-OCT-04 stripath o Modified for BUG# 3961117, Created function Get_Calculate_Date,
-- |                      added new parameter p_calculate_date to procedures create_payment_terms,
-- |                      create_payment_term_record.  Do not to create backbills
-- |                      if Assessment Date <= p__Calculate_Date (CutOff Date).
-- | 01-DEC-04 ftanudja o Added fix for #3964221, term created w/
-- |                      start date > end date.
-- | 27-DEC-04 abanerje Converted hardcoded english text messages
-- |                    to translatable seeded messages.
-- |                    Bug #3592834.
-- | 18-JAN-05 ftanudja o Before approving negative consolidation terms,
-- |                      check if schedule day conflicts in create_
-- |                      aggr_payment_term proc.
-- |                    o Add batch commit for approve_index_pay_
-- |                      term_batch. #4081821.
-- | 19-JAN-05 ftanudja o Fixed range query for batch approval.#4129147
-- | 21-APR-05 ftanudja o Added code to use default area type code if location is
-- |                      not null in create_payment_term_record(). #
-- | 14-Jul-05 SatyaDeepo Replaced bases views with their repective _ALL tables
-- | 19-SEP-05 piagrawa  o Modified the signature of Get_Calculate_Date
-- | 05-MAY-06 Hareesha  o Bug #5115291 Added parameter p_norm_st_date to
-- |                       procedure create_payment_term_record
-- | 31-OCT-06 acprakas  o Bug#4967164. Modified procedure create_aggr_payment_terms
-- |                       to create negative terms only when index payment term type is not 'ATLEAST'
-- | 01-NOV-06 Prabhakar o Added parameter p_end_date to the create_payment_term_record.
-- | 12-DEC-06 Prabhakar o Added p_prorate_factor parameter to derive_constrined_rent
-- |                       and create_payment_terms procedures.
-- +===========================================================================+

------------------------------------------------------------------------
-- PROCEDURE : build_distributions_string
-- DESCRIPTION: This function is used to derive a string that denotes
--              the distributions entries for a certain payment term.
--
--
------------------------------------------------------------------------
FUNCTION build_distributions_string (
   ip_payment_term_id IN NUMBER
)
   RETURN VARCHAR2 IS
   CURSOR c_distributions (
      ip_payment_term_id IN NUMBER
   ) IS
      SELECT   pd.payment_term_id
              ,pd.account_class
              ,pd.account_id
              ,pd.percentage
          FROM pn_distributions_all pd
         WHERE pd.payment_term_id = ip_payment_term_id
      ORDER BY pd.account_class,
               pd.account_id,
               pd.percentage;

   v_big_string   VARCHAR2 (4000);
BEGIN


   FOR c_dist_rec IN c_distributions (ip_payment_term_id)
   LOOP
      v_big_string :=    c_dist_rec.account_class
                      || ','
                      ||   c_dist_rec.account_id
                      || ','
                      || c_dist_rec.percentage
                      || ','
                      || v_big_string;
   END LOOP;

   if v_big_string is null then

      --v_big_string := ip_payment_term_id;
      v_big_string := 'IGNORE';

   end if;

   RETURN v_big_string;

END build_distributions_string;


------------------------------------------------------------------------
-- PROCEDURE : format
-- DESCRIPTION: This function is used the print_basis_periods procedure
--              to format any amount to This is only used to display
--              date to the output or log files.
--
--
--
------------------------------------------------------------------------


    FUNCTION format (
      p_number          IN   NUMBER
     ,p_precision       IN   NUMBER DEFAULT NULL
     ,p_currency_code   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2 IS
      v_currency_code      gl_sets_of_books.currency_code%TYPE;
      v_formatted_number   VARCHAR2 (100);
      v_format_mask        VARCHAR2 (100);
      v_field_length       NUMBER                                := 20;
      v_min_acct_unit      NUMBER;
   BEGIN

      /* if p_number is not blank, apply format
         if it is blank, just print a blank space */

      IF p_number IS NOT NULL THEN

         /* deriving a format mask if precision is specified. */

         IF p_precision IS NOT NULL THEN
            fnd_currency.safe_build_format_mask (
               format_mask                   => v_format_mask
              ,field_length                  => v_field_length
              ,precision                     => p_precision
              ,min_acct_unit                 => v_min_acct_unit
            );
         ELSE

            IF p_currency_code IS NOT NULL THEN
               v_currency_code := p_currency_code;
            ELSE
               v_currency_code := g_currency_code;
            END IF;


            /*  getting format make for currency code defined */

            v_format_mask := fnd_currency.get_format_mask (
                                currency_code                 => v_currency_code
                               ,field_length                  => v_field_length
                             );
         END IF;

         v_formatted_number := TO_CHAR (p_number, v_format_mask);
      ELSE

         /* set formatted number to a space if no number is passed */

         v_formatted_number := ' ';
      END IF;

      RETURN v_formatted_number;


   END format;


------------------------------------------------------------------------
-- PROCEDURE : GET_AMOUNT_PRECISION
-- DESCRIPTION: This function is used any currency amount
--
------------------------------------------------------------------------
   FUNCTION get_amount_precision (
      p_currency_code   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER IS
      v_currency_code   gl_sets_of_books.currency_code%TYPE;
      v_precision       NUMBER;
      v_ext_precision   NUMBER;
      v_min_acct_unit   NUMBER;
   BEGIN

      IF p_currency_code IS NOT NULL THEN
         v_currency_code := p_currency_code;
      ELSE
         v_currency_code := g_currency_code;
      END IF;

      fnd_currency.get_info (
         currency_code                 => v_currency_code
        ,precision                     => v_precision
        ,ext_precision                 => v_ext_precision
        ,min_acct_unit                 => v_min_acct_unit
      );

      RETURN v_precision;

   END get_amount_precision;


------------------------------------------------------------------------
-- PROCEDURE : put_log
-- DESCRIPTION: This procedure will display the text in the log file
--              of a concurrent program
--
------------------------------------------------------------------------

   PROCEDURE put_log (
      p_string   IN   VARCHAR2
   ) IS
   BEGIN
      -- pn_index_lease_common_pkg.put_log (p_string);
      pnp_debug_pkg.log(p_string);
   END put_log;


------------------------------------------------------------------------
-- PROCEDURE : put_output
-- DESCRIPTION: This procedure will display the text in the log file
--              of a concurrent program
--
------------------------------------------------------------------------

   PROCEDURE put_output (
      p_string   IN   VARCHAR2
   ) IS
   BEGIN
      -- pn_index_lease_common_pkg.put_output (p_string);
      pnp_debug_pkg.put_log_msg(p_string);
   END put_output;


------------------------------------------------------------------------
-- PROCEDURE : display_error_messages
-- DESCRIPTION: This procedure will parse a string of error message codes
--              delimited of with a comma.  It will lookup each code using
--              fnd_messages routine.
------------------------------------------------------------------------

   PROCEDURE display_error_messages (
      ip_message_string   IN   VARCHAR2
   ) IS
      message_string   VARCHAR2 (4000);
      msg_len          NUMBER;
      ind_message      VARCHAR2 (40);
      comma_loc        NUMBER;
   BEGIN
      message_string := ip_message_string;

      IF message_string IS NOT NULL THEN
         -- append a comma to the end of the string.
         message_string :=    message_string
                           || ',';
         -- get location of the first comma
         comma_loc := INSTR (message_string, ',', 1, 1);
         -- get length of message
         msg_len := LENGTH (message_string);
      ELSE
         comma_loc := 0;
      END IF;

      fnd_message.clear;

      --
      -- loop will cycle thru each occurrence of delimted text
      -- and display message with its code..
      --
      WHILE comma_loc <> 0
      LOOP
         --
         -- get error message to process
         --
         ind_message := SUBSTR (message_string, 1,   comma_loc
                                                   - 1);

         --
         -- check the length of error message code
         --
         --
         IF LENGTH (ind_message) > 30 THEN
            put_log (   '**** MESSAGE CODE '
                     || ind_message
                     || ' TOO LONG');
         ELSE
            --put_log (   'Message Code='
            --         || ind_message);

            --
            -- Convert error message code to its 'user-friendly' message;
            --
            fnd_message.set_name ('PN', ind_message);
            --
            -- Display message to the output log
            --
            put_output (   '-->'
                        || fnd_message.get
                        || ' ('
                        || ind_message
                        || ')');
            --
            -- delete the current message from string of messges
            -- e.g.
            --  before: message_string = "message1, message2, message3,"
            --  after:  message_string = "message2, message3,"
            --
            message_string := SUBSTR (
                                 message_string
                                ,  comma_loc
                                 + 1
                                ,  LENGTH (message_string)
                                 - comma_loc
                              );
            --
            -- locate the first occurrence of a comma
            --
            comma_loc := INSTR (message_string, ',', 1, 1);
         END IF; --LENGTH (ind_message) > 30
      END LOOP;
   END display_error_messages;


------------------------------------------------------------------------
-- PROCEDURE : print_payment_terms
-- DESCRIPTION: This procedure is will print payment term information
--              for a given index lease period.
--
------------------------------------------------------------------------

   PROCEDURE print_payment_terms (
      p_index_period_id   IN   NUMBER
     ,p_payment_term_id   IN   NUMBER DEFAULT NULL
   ) IS
      CURSOR index_periods_pay (
         ip_index_period_id   IN   NUMBER
      ) IS
         SELECT   ppt.actual_amount
                 ,ppt.frequency_code
                 ,ppt.start_date
                 ,ppt.end_date
                 ,ppt.index_term_indicator
                 ,ppt.status
                 ,DECODE (ppt.normalize, 'Y', 'NORMALIZE') "NORMALIZE"
             FROM pn_payment_terms_all ppt
            WHERE ppt.index_period_id = ip_index_period_id
         ORDER BY ppt.start_date;

      CURSOR index_periods_payments (
         ip_index_period_id   IN   NUMBER
        ,ip_payment_term_id   IN   NUMBER
      ) IS
         SELECT   ppt.actual_amount
                 ,ppt.frequency_code
                 ,ppt.start_date
                 ,ppt.end_date
                 ,ppt.index_term_indicator
                 ,ppt.status
                 ,DECODE (ppt.normalize, 'Y', 'NORMALIZE') "NORMALIZE"
             FROM pn_payment_terms_all ppt
            WHERE ppt.index_period_id = ip_index_period_id
              AND (   ppt.payment_term_id = ip_payment_term_id
                   OR ip_payment_term_id IS NULL
                  )
         ORDER BY ppt.start_date;

      v_line_count   NUMBER;
      ilp_pay_rec    index_periods_payments%ROWTYPE;
      l_message VARCHAR2(2000) := NULL;
   BEGIN
      -- Reset line counter for periods.
      v_line_count := 0;
      --
      -- Printing the index periods of the report report
      --
      v_line_count :=   v_line_count
                      + 1;
      fnd_message.set_name ('PN','PN_RICAL_PAYMENT');
      l_message := '         '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_START');
      l_message := l_message||'      '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_END');
      l_message := l_message||'        '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_PAYMENT');
      l_message := l_message||'                     '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_INDEX');
      l_message := l_message||'        '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_NORZ');
      l_message := l_message||'        '||fnd_message.get;
      put_output(l_message);

      l_message := NULL;

      fnd_message.set_name ('PN','PN_RICAL_FREQ');
      l_message := '         '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_DATE');
      l_message := l_message||'     '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_DATE');
      l_message := l_message||'        '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_AMT');
      l_message := l_message||'        '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_STATUS');
      l_message := l_message||'      '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_PAYMENT_TYPE');
      l_message := l_message||'        '||fnd_message.get;
      fnd_message.set_name ('PN','PN_RICAL_YES_NO');
      l_message := l_message||'        '||fnd_message.get;
      put_output(l_message);

      put_output (
         '         ---------  -----------  -----------  ----------  -----------  ------------------  ---------'
      );

      -- for performance reasons, one of two cursors can be executed..
      --    cursor index_periods_pay is to display all payments for a period..
      --    cursor index_periods_payments is to display payment details for one payment.
      --


      IF p_payment_term_id IS NULL THEN
         OPEN index_periods_pay (p_index_period_id);
      ELSE
         OPEN index_periods_payments (p_index_period_id, p_payment_term_id);
      END IF;

      LOOP
         IF index_periods_pay%ISOPEN THEN
            FETCH index_periods_pay INTO ilp_pay_rec;
            EXIT WHEN index_periods_pay%NOTFOUND;
         ELSE
            FETCH index_periods_payments INTO ilp_pay_rec;
            EXIT WHEN index_periods_payments%NOTFOUND;
         END IF;

         put_output (
               LPAD (ilp_pay_rec.frequency_code, 18, ' ')
            || LPAD (ilp_pay_rec.start_date, 13, ' ')
            || LPAD (ilp_pay_rec.end_date, 13, ' ')
            || LPAD (format (ilp_pay_rec.actual_amount, 2), 12, ' ')
            || LPAD (ilp_pay_rec.status, 13, ' ')
            || LPAD (ilp_pay_rec.index_term_indicator, 20, ' ')
            || LPAD (ilp_pay_rec.normalize, 11, ' ')
         );
      END LOOP;

      put_output ('.         ');

      --
      -- Print Message if no payment terms found for this period
      --
      IF v_line_count = 0 THEN
         put_output ('*********************************************');
         fnd_message.set_name ('PN','PN_RICAL_NO_PAY');
         put_output(fnd_message.get);
         put_output ('*********************************************');
      END IF;
   END print_payment_terms;


------------------------------------------------------------------------
-- PROCEDURE : print_basis_periods
-- DESCRIPTION: This procedure is will print to the output log index rent
--              period details and any payment terms for this period
------------------------------------------------------------------------

   PROCEDURE print_basis_periods (
      p_index_lease_id    IN   NUMBER
     ,p_index_period_id   IN   NUMBER
   ) IS
      CURSOR index_lease_periods (
         ip_index_lease_id    IN   NUMBER
        ,ip_index_period_id   IN   NUMBER
      ) IS
         SELECT   pilp.basis_percent_change
                 ,pilp.current_basis
                 ,pilp.index_percent_change
                 ,pilp.index_finder_date
                 ,pilp.index_period_id
                 ,pilp.basis_start_date
                 ,pilp.basis_end_date
                 ,pilp.assessment_date
                 ,pilp.line_number
                 ,pilp.relationship
                 ,pilp.constraint_rent_due
                 ,pilp.current_index_line_id
                 ,pilp.current_index_line_value
                 ,pilp.previous_index_line_id
                 ,pilp.previous_index_line_value
                 ,pilp.unconstraint_rent_due
             FROM pn_index_lease_periods_all pilp
            WHERE pilp.index_lease_id = ip_index_lease_id
              AND pilp.index_period_id = ip_index_period_id
         ORDER BY pilp.line_number;

      v_line_count   NUMBER;
      l_message VARCHAR2(2000) := NULL;

   BEGIN
      -- Reset line counter for periods.
      v_line_count := 0;

      --
      -- Printing the index periods of the report report
      --
      <<index_periods>>
      FOR ilp_rec IN index_lease_periods (p_index_lease_id, p_index_period_id)
      LOOP
         --
         -- Printing the Headers of the report
         --
         fnd_message.set_name ('PN','PN_RICAL_CUR');
         l_message := '      '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_ASS');
         l_message := l_message||'    '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_INDX');
         l_message := l_message||'                  '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_BAS');
         l_message := l_message||'       '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_UCON');
         l_message := l_message||'  '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_CON');
         l_message := l_message||'   '||fnd_message.get;
         put_output(l_message);

         l_message := NULL;

         fnd_message.set_name ('PN','PN_RICAL_BAS');
         l_message := '       '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_DATE');
         l_message := l_message||'        '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_REL');
         l_message := l_message||'        '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_CHG');
         l_message := l_message||'   '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_CHG');
         l_message := l_message||'  '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_RENT_DUE');
         l_message := l_message||'   '||fnd_message.get;
         l_message := l_message||'   '||fnd_message.get;
         l_message := l_message||' '||fnd_message.get;
         put_output(l_message);

         put_output (
            '     ---------  ------------  -----------  ----------  ----------  ----------  ----------'
         );
         --  Print the Period Details
         --  format function will display 3 decimal places for all numbers
         put_output (
               LPAD (format (ilp_rec.current_basis, 2), 14, ' ')
            || LPAD (TO_CHAR (ilp_rec.assessment_date, 'DD-MON-RRRR'), 14, ' ')
            || LPAD (ilp_rec.relationship, 13, ' ')
            || LPAD (format (ilp_rec.index_percent_change, 3), 13, ' ')
            || LPAD (format (ilp_rec.basis_percent_change, 3), 11, ' ')
            || LPAD (format (ilp_rec.unconstraint_rent_due, 2), 12, ' ')
            || LPAD (format (ilp_rec.constraint_rent_due, 2), 12, ' ')
         );
         v_line_count :=   v_line_count
                         + 1;
          print_payment_terms (p_index_period_id => ilp_rec.index_period_id);
      END LOOP index_periods; -- ilp_rec

      --
      -- Print Message if no basis periods found
      --
      IF v_line_count = 0 THEN
         put_output ('**************************************');
         fnd_message.set_name ('PN','PN_RICAL_NO_PRDS');
         put_output(fnd_message.get);
         put_output ('**************************************');
      END IF;
   END print_basis_periods;


------------------------------------------------------------------------
-- PROCEDURE : derive_index_period_id
-- DESCRIPTION: This procedure is used to derive the index period id of the
--              index rent period prior to the assessment date that is provided.
--              'current assessment date'
--
--              If no assessment date is provided, then the id of the last
--              period will be returned..
------------------------------------------------------------------------

   PROCEDURE derive_index_period_id (
      p_index_lease_id         IN       NUMBER
     ,p_assessment_date        IN       DATE
     ,op_prev_index_lease_id   OUT NOCOPY      NUMBER
   ) IS
   BEGIN
      --
      --put_log ('..In derive_index_period_id');
      --

      SELECT pilp.index_period_id
        INTO op_prev_index_lease_id
        FROM pn_index_lease_periods_all pilp
       WHERE pilp.index_lease_id = p_index_lease_id
         AND pilp.assessment_date = (SELECT MAX (pilp.assessment_date)
                                       FROM pn_index_lease_periods_all pilp
                                      WHERE pilp.index_lease_id = p_index_lease_id
                                      /*
                                      -- if p_assessment_date is null, this will return the
                                      -- assessment date of the last index rent period.
                                      */
                                        AND (   pilp.assessment_date < p_assessment_date
                                             OR p_assessment_date IS NULL
                                            ));
   EXCEPTION
      WHEN OTHERS THEN
         put_log (   'Unable to derive prev. index ID SQLERRM:'
                  || SQLERRM);
   END derive_index_period_id;


------------------------------------------------------------------------
-- PROCEDURE : derive_prev_index_amount
-- DESCRIPTION: This procedure is used to derive the index amount of the
--              the previous index rent period.  This value is needed when
--              calculating index rent basis type of COMPOUND.
--
------------------------------------------------------------------------

   PROCEDURE derive_prev_index_amount (
      p_index_lease_id    IN       NUMBER
     ,p_assessment_date   IN       DATE
     ,op_type             IN       VARCHAR2 -- Type: UNCONSTRAINT OR CONSTRAINT
     ,op_index_amount     OUT NOCOPY      NUMBER
   ) IS
      v_index_period_id   pn_index_lease_periods.index_period_id%TYPE;
   BEGIN
      --put_log ('..In derive_prev_index_amount');

      --
      -- getting the index period of the period prior to this assessment date
      --
      derive_index_period_id (
         p_index_lease_id              => p_index_lease_id
        ,p_assessment_date             => p_assessment_date
        ,op_prev_index_lease_id        => v_index_period_id
      );

      IF v_index_period_id IS NOT NULL THEN
         SELECT DECODE (
                   op_type
                  ,'UNCONSTRAINT', unconstraint_rent_due
                  ,'CONSTRAINT', constraint_rent_due
                )
           INTO op_index_amount
           FROM pn_index_lease_periods_all pilp
          WHERE index_period_id = v_index_period_id;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         put_log (   'Unable to derive prev. index amount SQLERRM:'
                  || SQLERRM);
   END derive_prev_index_amount;


------------------------------------------------------------------------
-- PROCEDURE : derive_prev_index_amount
-- DESCRIPTION: This procedure is used to derive the index amount of the
--              the previous index rent period.  This value is needed when
--              calculating index rent basis type of COMPOUND.
--
------------------------------------------------------------------------

   PROCEDURE derive_next_period_details(
      p_index_lease_id    IN       NUMBER
     ,p_assessment_date   IN       DATE
     ,op_next_index_period_id OUT NOCOPY NUMBER
     ,op_basis_start_date OUT NOCOPY DATE
     ,op_basis_end_date OUT NOCOPY DATE
   ) IS
   BEGIN
      --put_log ('..In derive_next_peroid_details');

        SELECT pilp.index_period_id,pilp.basis_start_date,pilp.basis_end_date
        INTO op_next_index_period_id,op_basis_start_date,op_basis_end_date
        FROM pn_index_lease_periods_all pilp
        WHERE pilp.index_lease_id = p_index_lease_id
        AND pilp.assessment_date = (SELECT MIN (pilp.assessment_date)
                                    FROM pn_index_lease_periods_all pilp
                                    WHERE pilp.index_lease_id = p_index_lease_id
                                    AND pilp.assessment_date > p_assessment_date
                                    );


      EXCEPTION
      WHEN OTHERS THEN
         put_log (   'Unable to derive next periods index information SQLERRM:'
                  || SQLERRM);
   END derive_next_period_details;




------------------------------------------------------------------------
-- PROCEDURE : convert_basis_to_annual_amt
-- DESCRIPTION: This procedure will convert a basis amount for a given index rent
--              period to its annual equivalent
------------------------------------------------------------------------

   PROCEDURE convert_basis_to_annual_amt (
      p_basis_amount           IN       NUMBER
     ,p_basis_start_date       IN       DATE
     ,p_basis_end_date         IN       DATE
     ,op_basis_amount_annual   OUT NOCOPY      NUMBER
   ) IS
      v_basis_duration        NUMBER;
      v_annual_basis_amount   pn_index_lease_periods.current_basis%TYPE;
   BEGIN
      v_basis_duration := CEIL (MONTHS_BETWEEN (p_basis_end_date, p_basis_start_date));

      --
      -- get the duration of basis period (ie. no of months between
      -- basis start and end date.
      --
      IF      p_basis_start_date IS NULL
          AND p_basis_end_date IS NULL THEN
         --
         -- if basis start and end date, are null, assume
         -- that initial basis is used
         --
         v_annual_basis_amount := p_basis_amount;
      ELSIF v_basis_duration = 12 THEN
         --
         -- if the duration between basis dates is 12, assume the basis is the annual amount..
         --
         v_annual_basis_amount := p_basis_amount;
      ELSE
         v_annual_basis_amount :=   (p_basis_amount / v_basis_duration)
                                  * 12;
      END IF; -- p_basis_start_date is null and    p_basis_end_date is null

      --
      -- divide basis amount by the number of months between basis dates
      --

      op_basis_amount_annual := v_annual_basis_amount;
   END convert_basis_to_annual_amt;


------------------------------------------------------------------------
      -- PROCEDURE : derive_sum_prev_actual_amounts
      -- DESCRIPTION: This procedure is used to derive the sum of all the
      --              actual amounts of the previous index rent periods.
      --              This value is needed when calculating annualized basis
      --              for basis type of COMPOUND while creating payment terms.
      --
   ------------------------------------------------------------------------

   PROCEDURE derive_sum_prev_actual_amounts (
      p_lease_id            IN       NUMBER
     ,p_index_lease_id      IN       NUMBER
     ,p_index_period_id     IN       NUMBER
     ,p_prev_index_amount   OUT NOCOPY      NUMBER
   ) IS
   BEGIN
      --put_log ('..In derive_sum_prev_index_amount');

      SELECT SUM (
                  ppt.actual_amount
                * DECODE (
                     frequency_code
                    ,c_spread_frequency_monthly, 12
                    ,c_spread_frequency_quarterly, 4
                    ,c_spread_frequency_semiannual, 2
                    ,c_spread_frequency_annually, 1
                    ,c_spread_frequency_one_time, 0
                  )
             )
        INTO p_prev_index_amount
        FROM pn_payment_terms_all ppt, pn_index_lease_periods_all ppi
       WHERE ppt.index_period_id = ppi.index_period_id
         AND ppi.index_lease_id = p_index_lease_id
         AND ppi.assessment_date < (SELECT assessment_date
                                      FROM pn_index_lease_periods_all
                                     WHERE index_period_id = p_index_period_id)
         AND ppt.lease_id = p_lease_id;
   EXCEPTION
      WHEN OTHERS THEN
         put_log (   'Unable to derive sum of prev. actual amounts SQLERRM:'
                  || SQLERRM);
   END derive_sum_prev_actual_amounts;


------------------------------------------------------------------------
  -- PROCEDURE :   derive_sum_prev_index_amounts
  -- DESCRIPTION: This procedure is used to derive the sum of all the
  --              index rents prior to the assessment date that is provided.
  --              'current assessment date'
  --.
  ------------------------------------------------------------------------

   PROCEDURE derive_sum_prev_index_amounts (
      p_index_lease_id        IN       NUMBER
     ,p_assessment_date       IN       DATE
     ,op_type                 IN       VARCHAR2
     ,p_sum_prev_index_amts   OUT NOCOPY      NUMBER
   ) IS
   BEGIN
      --
      --put_log ('..derive_sum_prev_index_amounts');
      --

      SELECT SUM (
                DECODE (
                   op_type
                  ,'UNCONSTRAINT', unconstraint_rent_due
                  ,'CONSTRAINT', constraint_rent_due
                )
             )
        INTO p_sum_prev_index_amts
        FROM pn_index_lease_periods_all pilp
       WHERE pilp.index_lease_id = p_index_lease_id
         AND pilp.assessment_date < p_assessment_date;
   EXCEPTION
      WHEN OTHERS THEN
         put_log (   'Unable to derive sum of prev. index amounts SQLERRM:'
                  || SQLERRM);
   END derive_sum_prev_index_amounts;


-------------------------------------------------------------------------------------------
-- PROCEDURE : sum_payment_items
-- DESCRIPTION: This procedure will sum all the payment items that is
--              within the date range specified of the type specified.
--              and of payment that is passed. type
--
-- 03-Feb-05 Kiran    o Bug # 4031003 - based on the profile value of
--                      PN_CALC_ANNUALIZED_BASIS decide whether to calculate
--                      annualized basis for the terms active as of the period
--                      End date or the for the entire period.
--                      Replaced the old 2 cursors with 4 new ones.
-- 19-SEP-05 piagrawa o Modified to pass org id to pn_mo_cache_utils.
--                      get_profile_value
-- 14-AUG-06 pikhar   o Added check to find out if contributing terms have
--                      include_in_var_rent = 'INCLUDE_RI'
-- 23-SEP-06 prabhakar o Modified the curosrs to fetch terms from pn_index_exclude_term_all
--                       with flag 'I' or from pn_payment_terms_all
-- 27-NOV-07 acprakas  o Bug#6457105. Modified to consider new values for system option incl_terms_by_default_flag.
--------------------------------------------------------------------------------------------

PROCEDURE sum_payment_items (
  p_index_lease_id      IN NUMBER
 ,p_basis_start_date    IN DATE
 ,p_basis_end_date      IN DATE
 ,p_type_code           IN VARCHAR2 /* Payment Type: Base Rent or Operating Expense */
 ,p_include_index_items IN VARCHAR2
 ,op_sum_amount         OUT NOCOPY NUMBER
) IS

l_count                 NUMBER := 0;
l_total_sum             NUMBER := 0;
l_amount                PN_PAYMENT_TERMS.ACTUAL_AMOUNT%TYPE;
l_frequency             PN_PAYMENT_TERMS.FREQUENCY_CODE%TYPE;
l_payment_term_id       PN_PAYMENT_TERMS.PAYMENT_TERM_ID%TYPE;
l_payments              NUMBER := 0;
/* profile to determine how to calculate annualized basis */
l_calc_annualized_basis VARCHAR2(30);
l_org_id                NUMBER;
l_include_in_var_rent   VARCHAR2(30);
l_increase_on           VARCHAR2(30);

/* if the parameter p_include_index_items = 'N',
   then the select statement should ignore payment items
   whose parent payment term is from an index increase. */

/* gets the data from all terms active in the basis period */
CURSOR csr_exc_get_item_period (p_payment_type VARCHAR2,p_org_id NUMBER) IS
  SELECT ppt.payment_term_id
        ,NVL(ppt.actual_amount, ppt.estimated_amount)
        ,ppt.frequency_code
    FROM pn_payment_terms_all ppt
        ,pn_index_leases_all pil
   WHERE pil.index_lease_id = p_index_lease_id
     AND ppt.lease_id = pil.lease_id
     AND ppt.payment_term_type_code
           = DECODE(p_payment_type, c_increase_on_gross,
                    ppt.payment_term_type_code, p_payment_type)
     AND NVL(ppt.index_period_id, -1) NOT IN
          (SELECT index_period_id
             FROM pn_index_lease_periods_all ppilx
            WHERE ppilx.index_lease_id = p_index_lease_id)
     AND NVL(ppt.status,'-1')
           = DECODE(ppt.index_period_id, NULL,
                    NVL(ppt.status,'-1'), 'APPROVED')
     AND ppt.end_date >= p_basis_start_date
     AND ppt.start_date <= p_basis_end_date
     AND ppt.frequency_code <> c_spread_frequency_one_time
     AND (
         ppt.payment_term_id  IN (SELECT piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id
         AND piet.include_exclude_flag = 'I')
                        OR
         (
         ppt.payment_term_id NOT IN (select piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id)
         AND ( pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'Y' OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'G' and  NVL(pil.gross_flag,'N') = 'Y') OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'U' and  NVL(pil.gross_flag,'N') = 'N')
	     )
         )
         )
     AND ppt.currency_code = pil.currency_code;

/* gets the data from all terms active on the basis period end date */
CURSOR csr_exc_get_item_enddate (p_payment_type VARCHAR2, p_org_id NUMBER) IS
  SELECT ppt.payment_term_id
        ,NVL(ppt.actual_amount, ppt.estimated_amount)
        ,ppt.frequency_code
    FROM pn_payment_terms_all ppt
        ,pn_index_leases_all pil
   WHERE pil.index_lease_id = p_index_lease_id
     AND ppt.lease_id = pil.lease_id
     AND ppt.payment_term_type_code
           = DECODE(p_payment_type, c_increase_on_gross,
                    ppt.payment_term_type_code, p_payment_type)
     AND NVL(ppt.index_period_id, -1) NOT IN
          (SELECT index_period_id
             FROM pn_index_lease_periods_all ppilx
            WHERE ppilx.index_lease_id = p_index_lease_id)
     AND NVL(ppt.status,'-1')
           = DECODE(ppt.index_period_id, NULL,
                    NVL(ppt.status,'-1'), 'APPROVED')
     AND ppt.end_date >= p_basis_end_date
     AND ppt.start_date <= p_basis_end_date
     AND ppt.frequency_code <> c_spread_frequency_one_time
     AND (
         ppt.payment_term_id  IN (SELECT piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id
         AND piet.include_exclude_flag = 'I')
                        OR
         (
         ppt.payment_term_id NOT IN (select piet.payment_term_id
	 FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id)
         AND ( pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'Y' OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'G' and  NVL(pil.gross_flag,'N') = 'Y') OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'U' and  NVL(pil.gross_flag,'N') = 'N')
	     )
	 )
	 )
     AND ppt.currency_code = pil.currency_code;

/* Only approved rent increase terms will be picked up for basis calculation */

/* gets the data from all terms active in the basis period */
CURSOR csr_inc_get_item_period (p_payment_type VARCHAR2,p_org_id NUMBER) IS
  SELECT ppt.payment_term_id
        ,NVL(ppt.actual_amount,ppt.estimated_amount)
        ,ppt.frequency_code
    FROM pn_payment_terms_all ppt
        ,pn_index_leases_all pil
   WHERE pil.index_lease_id = p_index_lease_id
     AND ppt.lease_id = pil.lease_id
     AND ppt.payment_term_type_code
         = DECODE(p_payment_type,c_increase_on_gross,
                  ppt.payment_term_type_code, p_payment_type)
     AND NVL(ppt.status,'-1')
         = DECODE(ppt.index_period_id,NULL,
                  NVL(ppt.status,'-1'),'APPROVED')
     AND ppt.end_date >= p_basis_start_date
     AND ppt.start_date <= p_basis_end_date
     AND ppt.frequency_code <> c_spread_frequency_one_time
     AND (
         ppt.payment_term_id  IN (SELECT piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id
         AND piet.include_exclude_flag = 'I')
                               OR
         (
         ppt.payment_term_id NOT IN (select piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id)
         AND ( pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'Y' OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'G' and  NVL(pil.gross_flag,'N') = 'Y') OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'U' and  NVL(pil.gross_flag,'N') = 'N')
	     )
         )
         )
      AND ppt.currency_code = pil.currency_code;

/* gets the data from all terms active on the basis period end date */
CURSOR csr_inc_get_item_enddate (p_payment_type VARCHAR2,p_org_id NUMBER) IS
  SELECT ppt.payment_term_id
        ,NVL(ppt.actual_amount,ppt.estimated_amount)
        ,ppt.frequency_code
    FROM pn_payment_terms_all ppt
        ,pn_index_leases_all pil
   WHERE pil.index_lease_id = p_index_lease_id
     AND ppt.lease_id = pil.lease_id
     AND ppt.payment_term_type_code
         = DECODE(p_payment_type,c_increase_on_gross,
                  ppt.payment_term_type_code, p_payment_type)
     AND NVL(ppt.status,'-1')
         = DECODE(ppt.index_period_id,NULL,
                  NVL(ppt.status,'-1'),'APPROVED')
     AND ppt.end_date >= p_basis_end_date
     AND ppt.start_date <= p_basis_end_date
     AND ppt.frequency_code <> c_spread_frequency_one_time
     AND (
         ppt.payment_term_id  IN (SELECT piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id
         AND piet.include_exclude_flag = 'I')
                               OR
         (
         ppt.payment_term_id NOT IN (select piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id)
         AND ( pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'Y' OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'G' and  NVL(pil.gross_flag,'N') = 'Y') OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',p_org_id) = 'U' and  NVL(pil.gross_flag,'N') = 'N')
	     )
         )
         )
     AND ppt.currency_code = pil.currency_code;

  CURSOR org_id_cur IS
   SELECT org_id, increase_on
   FROM pn_index_leases_all
   WHERE index_lease_id = p_index_lease_id;

BEGIN

  put_log ('..In sum_payment_items');
  put_log ('..In sum_payment_items p_basis_start_date'|| to_char(p_basis_start_date));
  put_log ('..In sum_payment_items p_basis_end_date'|| to_char(p_basis_end_date));

  l_total_sum := 0;
  l_count := 0;

  FOR org_id_rec IN org_id_cur LOOP
     l_org_id := org_id_rec.org_id;
     l_increase_on := org_id_rec.increase_on;
  END LOOP;

  /* get the value for the PN_CALC_ANNUALIZED_BASIS profile */
  l_calc_annualized_basis
    := pn_mo_cache_utils.get_profile_value('PN_CALC_ANNUALIZED_BASIS', l_org_id);

  /*  if increase on GROSS, get all payment items regardless of type */

  IF p_type_code = c_increase_on_gross THEN

    /* summing all cash items regardless of type... */

    IF p_include_index_items = 'N' THEN

      IF NVL(l_calc_annualized_basis,'PERIOD') = 'PERIOD' THEN

        OPEN csr_exc_get_item_period (c_increase_on_gross,l_org_id);

      ELSIF NVL(l_calc_annualized_basis,'PERIOD') = 'ENDDATE' THEN

        OPEN csr_exc_get_item_enddate (c_increase_on_gross,l_org_id);

      END IF;

    ELSIF p_include_index_items = 'Y' THEN

      IF NVL(l_calc_annualized_basis,'PERIOD') = 'PERIOD' THEN

        OPEN csr_inc_get_item_period (c_increase_on_gross,l_org_id);

      ELSIF NVL(l_calc_annualized_basis,'PERIOD') = 'ENDDATE' THEN

        OPEN csr_inc_get_item_enddate (c_increase_on_gross,l_org_id);

      END IF;

    END IF;

  ELSE
    /* summing all cash items for the particular payment type... */

    IF p_include_index_items = 'N' THEN

      IF NVL(l_calc_annualized_basis,'PERIOD') = 'PERIOD' THEN

        OPEN csr_exc_get_item_period (p_type_code,l_org_id);

      ELSIF NVL(l_calc_annualized_basis,'PERIOD') = 'ENDDATE' THEN

        OPEN csr_exc_get_item_enddate (p_type_code,l_org_id);

      END IF;

    ELSIF p_include_index_items = 'Y' THEN

      IF NVL(l_calc_annualized_basis,'PERIOD') = 'PERIOD' THEN

        OPEN csr_inc_get_item_period (p_type_code,l_org_id);

      ELSIF NVL(l_calc_annualized_basis,'PERIOD') = 'ENDDATE' THEN

        OPEN csr_inc_get_item_enddate (p_type_code,l_org_id);

      END IF;

    END IF;

  END IF;

  /* Get each of the payment term and the payment term amount and
     store it in a PL/SQL table . Also add it to op_sum_amount to get the
     total amount of all the payment terms */
  g_include_in_var_check := NULL;
  g_include_in_var_rent  := NULL;
  LOOP

    l_count := l_count + 1;

    put_log('..Before fetch'|| p_include_index_items);
    put_log('..Before fetch...l_payment_term_id = ' || l_payment_term_id);
    put_log('..Before fetch...l_amount = ' || l_amount);
    put_log('..Before fetch...l_frequency = ' || l_frequency);

    IF csr_exc_get_item_period%ISOPEN THEN

      FETCH csr_exc_get_item_period INTO
        l_payment_term_id,
        l_amount,
        l_frequency;

      EXIT WHEN csr_exc_get_item_period%NOTFOUND;

    ELSIF csr_exc_get_item_enddate%ISOPEN THEN

      FETCH csr_exc_get_item_enddate INTO
        l_payment_term_id,
        l_amount,
        l_frequency;

      EXIT WHEN csr_exc_get_item_enddate%NOTFOUND;

    ELSIF csr_inc_get_item_period%ISOPEN THEN

      FETCH csr_inc_get_item_period INTO
        l_payment_term_id,
        l_amount,
        l_frequency;

      EXIT WHEN csr_inc_get_item_period%NOTFOUND;

    ELSIF csr_inc_get_item_enddate%ISOPEN THEN

      FETCH csr_inc_get_item_enddate INTO
        l_payment_term_id,
        l_amount,
        l_frequency;

      EXIT WHEN csr_inc_get_item_enddate%NOTFOUND;

    END IF;

    put_log ('..After fetch'|| p_include_index_items);

    put_log('..After fetch...l_payment_term_id = ' || l_payment_term_id);
    put_log('..After fetch...l_amount = ' || l_amount);
    put_log('..After fetch...l_frequency = ' || l_frequency);

    IF l_frequency = 'MON' THEN
      l_payments := 12;
    ELSIF l_frequency = 'QTR' THEN
       l_payments :=  4;
    ELSIF l_frequency = 'SA' THEN
       l_payments :=  2;
    ELSIF l_frequency = 'YR' THEN
       l_payments :=  1;
    END IF;

    l_total_sum := nvl(l_total_sum,0) + nvl(l_amount,0) * l_payments;

    /* This is used to find if the contributing terms have same value for
       include_in_var_rent */


    IF l_increase_on is NOT NULL THEN
       SELECT include_in_var_rent
       INTO l_include_in_var_rent
       FROM pn_payment_terms_all ppt
       WHERE ppt.payment_term_id = l_payment_term_id
       AND ppt.payment_term_type_code = nvl(p_type_code,ppt.payment_term_type_code);
    ELSE
       SELECT include_in_var_rent
       INTO l_include_in_var_rent
       FROM pn_payment_terms_all ppt
       WHERE ppt.payment_term_id = l_payment_term_id;
    END IF;

    IF l_count = 1 THEN
       g_include_in_var_rent := l_include_in_var_rent;
       g_include_in_var_check := 'T';
       l_count := l_count + 1;
    ELSE
       IF nvl(g_include_in_var_rent,'F') <> nvl(l_include_in_var_rent,'F') THEN
          g_include_in_var_check := 'F';
       END IF;
    END IF;

  END LOOP;

  IF csr_exc_get_item_period%ISOPEN THEN

    CLOSE csr_exc_get_item_period;

  ELSIF csr_exc_get_item_enddate%ISOPEN THEN

    CLOSE csr_exc_get_item_enddate;

  ELSIF csr_inc_get_item_period%ISOPEN THEN

    CLOSE csr_inc_get_item_period;

  ELSIF csr_inc_get_item_enddate%ISOPEN THEN

    CLOSE csr_inc_get_item_enddate;

  END IF;

  op_sum_amount := l_total_sum;

END sum_payment_items;

------------------------------------------------------------------------
-- PROCEDURE : calculate_basis_amount
-- DESCRIPTION: This procedure will calculate the basis amount for a given index rent period
-- HISTORY
-- 13-FEB-04 ftanudja o removed redundant 'UPDATE pn_index_leases set initial_basis..' 3436147
-- 05-JUN-07 Prabhakar o bug #6110109. In case of compound, the annulaised basis amount
--                       amount is made zero instead of NULL, when basis amount is zero.
------------------------------------------------------------------------

   PROCEDURE calculate_basis_amount (
      p_index_lease_id      IN       NUMBER
     ,p_basis_start_date    IN       DATE
     ,p_basis_end_date      IN       DATE
     ,p_assessment_date     IN       DATE
     ,p_initial_basis       IN       NUMBER
     ,p_line_number         IN       NUMBER
     ,p_increase_on         IN       VARCHAR2
     ,p_basis_type          IN       VARCHAR2
     ,p_prev_index_amount   IN       NUMBER
     ,p_recalculate         IN       VARCHAR2   -- Fix for bug# 1956128
     ,op_basis_amount       OUT NOCOPY      NUMBER
     ,op_msg                OUT NOCOPY      VARCHAR2
   ) IS

    --v_basis_amt_oper_expenses   NUMBER;
    --v_basis_amt_base_rent       NUMBER;
      v_prev_index_amt          pn_index_lease_periods.constraint_rent_due%TYPE;
      v_msg                     VARCHAR2 (1000);
      v_basis_amount            pn_index_lease_periods.current_basis%TYPE;
      v_previous_basis_amount   pn_index_lease_periods.current_basis%TYPE;
      v_previous_index_id       pn_index_lease_periods.index_period_id%TYPE;
      v_sum_prev_index_amts     NUMBER;
      v_annual_basis_amount     NUMBER;

   BEGIN
      put_log ('..IN CALCULATE_BASIS_AMOUNT');
      --put_log (   '      Basis Type       = '
      --         || p_basis_type);

      --
      -- if index rent and main lease commencement dates are equal
      --      basis start and end date will be null
      --
      IF      p_basis_start_date IS NULL
          AND p_basis_end_date IS NULL THEN
         --
         -- If Basis Dates are Blank
         --
         --        use initial basis,


         IF p_initial_basis IS NOT NULL THEN
            v_annual_basis_amount := p_initial_basis;
         ELSE
            v_msg := 'PN_INDEX_INIT_BASIS_REQD';
         END IF;
      ELSE

                 IF p_basis_type = c_basis_type_fixed THEN

                           -- if basis type = fixed use initial basis for basis amt.

                           v_annual_basis_amount := p_initial_basis;

                 ELSIF p_basis_type = c_basis_type_rolling THEN

                            IF p_line_number = 1 THEN

                                   v_annual_basis_amount := p_initial_basis;

                            ELSE    -- period <> 1
                          put_log('rolling **** bst dt' || p_basis_start_date);
                          put_log('rolling **** ben dt' || p_basis_end_date);
                          put_log('rolling **** p_increase_on ' || p_increase_on);
                          put_log('rolling **** p_index_lease_id ' || to_char(p_index_lease_id));
                            sum_payment_items (
                               p_index_lease_id              => p_index_lease_id
                              ,p_basis_start_date            => p_basis_start_date
                              ,p_basis_end_date              => p_basis_end_date
                              ,p_type_code                   => p_increase_on
                              ,op_sum_amount                 => v_annual_basis_amount
                            );
                          put_log('rolling **** v_annual_basis_amount ' || to_char(v_annual_basis_amount));

                            END IF;

                 ELSIF p_basis_type = c_basis_type_compound THEN
                            --
                            -- From Compound basis type, we need the index amount from previous period
                            --

                            IF p_prev_index_amount IS NULL and p_line_number <> 1 THEN
                               -- derive previous index amount.
                               derive_prev_index_amount (
                                  p_index_lease_id              => p_index_lease_id
                                 ,p_assessment_date             => p_assessment_date
                                 ,op_type                       => 'CONSTRAINT'
                                 ,op_index_amount               => v_prev_index_amt
                               );
                            ELSE
                               v_prev_index_amt := p_prev_index_amount;
                            END IF;

                            IF v_prev_index_amt IS NULL THEN
                               IF p_line_number = 1 THEN
                                  v_prev_index_amt := 0;
                                  v_sum_prev_index_amts := 0;
                               ELSE
                                  v_msg := 'PN_INDEX_PREV_INDEX_REQ';
                               END IF; -- p_line_number = 1 THEN
                            END IF; --v_prev_index_amt IS NULL

                            --
                            -- the general rule the basis amount for compounding is to use the basis amount
                            --    of the previous period. EXCEPT for the first period..
                            --
                            -- for the first period,
                            --    use initial basis,
                            --      if initial basis is not availble, calculate the basis using INCREASE ON type
                            --



                            IF p_line_number = 1 THEN

                                  -- initial basis for basis amt.
                                  v_previous_basis_amount := p_initial_basis;

                            ELSE -- p_line_number = 1
                                --
                                -- processing line number > 2
                                --
                                --
                                -- in the compound scenario,
                                --  when summing up items, we should not include
                                --    index items b/c the basis amount already includes
                                --    constraint rent amount of previous index periods
                                --

                               sum_payment_items (
                                  p_index_lease_id              => p_index_lease_id
                                 ,p_basis_start_date            => p_basis_start_date
                                 ,p_basis_end_date              => p_basis_end_date
                                 ,p_type_code                   => p_increase_on
                                 ,p_include_index_items         => 'N'
                                 ,op_sum_amount                 => v_previous_basis_amount
                               );

                               -- deriving the sum of all the previous index rent increases
                               IF v_prev_index_amt IS NOT NULL THEN
                                  derive_sum_prev_index_amounts (
                                     p_index_lease_id              => p_index_lease_id
                                    ,p_assessment_date             => p_assessment_date
                                    ,op_type                       => 'CONSTRAINT'
                                    ,p_sum_prev_index_amts         => v_sum_prev_index_amts
                                  );
                               ELSE
                                  v_sum_prev_index_amts := NULL;
                               END IF;
                            END IF; -- p_line_number = ???

                            IF nvl(v_previous_basis_amount,0) = 0 THEN
                               --v_annual_basis_amount := null;  bug #6110109
                               v_annual_basis_amount := 0;
                            ELSE
                               v_annual_basis_amount := v_previous_basis_amount
                                                      + v_sum_prev_index_amts;
                            END IF;

                 END IF; -- p_basis_type = ???
                 put_log ('calculate_basis_amount **** v_previous_basis_amount '||v_previous_basis_amount);
                 put_log ('calculate_basis_amount **** v_sum_prev_index_amts '||v_sum_prev_index_amts);

      END IF; -- p_basis_start_date is not null and p_basis_end_date is not null

      op_msg := v_msg;
      op_basis_amount := v_annual_basis_amount;
       put_log ('calculate_basis_amount **** op_basis_amount ' || to_char(op_basis_amount));
   END calculate_basis_amount;


------------------------------------------------------------------------
-- PROCEDURE : calculate_initial_basis
-- DESCRIPTION: This procedure will calculate the initial basis for a given
--
--
------------------------------------------------------------------------

   PROCEDURE calculate_initial_basis (
      p_index_lease_id   IN       NUMBER
     ,op_basis_amount    OUT NOCOPY      NUMBER
     ,op_msg             OUT NOCOPY      VARCHAR2
   ) IS

/*
   IF INCREASE_ON = Base Rent THEN
            sum all payment items of type = Base Rent (Code: BASER), between the basis start and end date;

         ELSE IF INCREASE_ON = Operating Expenses
            sum all payment items of type = Operating Expenses (Code: OEXP) , between the basis start and end date;

         ELSE IF INCREASE_ON = Gross Rent
            sum all payment items of type = Base Rent (Code: BASER) AND Operating Expenses (Code: OEXP), between the basis
start and end date;

*/

      CURSOR ilp_curr (
         p_index_lease_id   IN   NUMBER
      ) IS
         SELECT pil.index_lease_id
               ,pil.initial_basis
               ,pil.basis_type
               ,nvl(pil.increase_on,c_increase_on_gross) "INCREASE_ON"
               ,pilp.index_period_id
               ,pilp.basis_start_date
               ,pilp.basis_end_date
           FROM pn_index_leases_all pil, pn_index_lease_periods_all pilp
          WHERE pil.index_lease_id = pilp.index_lease_id
            AND pil.index_lease_id = p_index_lease_id
            AND pilp.line_number = 1;

      ilp_rec                     ilp_curr%ROWTYPE;
      v_basis_amt_oper_expenses   pn_index_lease_periods.current_basis%TYPE;
      v_basis_amt_base_rent       pn_index_lease_periods.current_basis%TYPE;
      --v_prev_index_amt            NUMBER;
      v_basis_amount              pn_index_lease_periods.current_basis%TYPE;
      v_msg                       VARCHAR2 (1000);
      v_annual_basis_amt          pn_index_lease_periods.current_basis%TYPE;
      l_include_index_items       VARCHAR2(1) := null;

   BEGIN
      put_log ('..In calculate_initial_basis');
      OPEN ilp_curr (p_index_lease_id);
      FETCH ilp_curr INTO ilp_rec;

      IF (ilp_curr%NOTFOUND) THEN
         CLOSE ilp_curr;
         op_msg := 'PN_AT_LEAST_ONE_PERIOD_REQD';
         put_log ('    Error: Index or Main Lease not found');
         RETURN;
      END IF;

      --
      -- if index rent and main lease commencement dates are equal
      --      basis start and end date will be null
      --
      IF      ilp_rec.basis_start_date IS NULL
          AND ilp_rec.basis_end_date IS NULL THEN
         --
         -- If Basis Dates are Blank
         --
         --        use initial basis,

         IF ilp_rec.initial_basis IS NOT NULL THEN
            v_annual_basis_amt := ilp_rec.initial_basis;
         ELSE
            --
            -- if initial basis is blank, send back error.
            --
            v_msg := 'PN_INDEX_INIT_BASIS_REQD';
         END IF;
      ELSE

         IF ilp_rec.basis_type = c_basis_type_compound THEN

            l_include_index_items := 'N';

         ELSE

            l_include_index_items := 'Y';

         END IF;

         sum_payment_items (
               p_index_lease_id              => p_index_lease_id
              ,p_basis_start_date            => ilp_rec.basis_start_date
              ,p_basis_end_date              => ilp_rec.basis_end_date
              ,p_type_code                   => ilp_rec.increase_on
              ,p_include_index_items         => l_include_index_items                 -- Bug#2101480
              ,op_sum_amount                 => v_annual_basis_amt
            );

      END IF; --p_basis_start_date is not null and p_basis_end_date is not null

      CLOSE ilp_curr;
      op_msg := v_msg;
      op_basis_amount := v_annual_basis_amt;
   END calculate_initial_basis;


------------------------------------------------------------------------
-- PROCEDURE : calculate_index_amount
-- DESCRIPTION: This procedure will calculate the UNCONSTRAINED index amount for
--              a given index rent period
--
------------------------------------------------------------------------
   PROCEDURE calculate_index_amount (
      p_relationship               IN         VARCHAR2
     ,p_basis_percent_change       IN         NUMBER
     ,p_adj_index_percent_change   IN         NUMBER
     ,p_current_basis              IN         NUMBER
     ,op_index_amount         OUT NOCOPY      NUMBER
     ,op_msg                  OUT NOCOPY      VARCHAR2
   ) IS
      v_annual_basis_amt        pn_index_lease_periods.current_basis%TYPE;
      v_percent_multiplier      NUMBER;
      v_found_all_reqd_fields   BOOLEAN;
      v_index_rent_amount       pn_index_lease_periods.unconstraint_rent_due%TYPE;
      v_msg                     VARCHAR2 (1000);
   BEGIN
      --put_log ('..In calculate_index_amount');
      --
      -- detemine if all required to calculate the index is available.
      --
      v_found_all_reqd_fields := FALSE;

      IF p_relationship = c_relation_basis_only THEN
         IF      p_basis_percent_change IS NOT NULL
             AND p_current_basis IS NOT NULL THEN
            v_found_all_reqd_fields := TRUE;
         ELSE
            v_msg := 'PN_INDEX_REQD_FLDS_BASIS_ONLY';
         END IF;
      ELSIF p_relationship = c_relation_index_only THEN
         IF      p_adj_index_percent_change IS NOT NULL
             AND p_current_basis IS NOT NULL THEN
            v_found_all_reqd_fields := TRUE;
         ELSE
            v_msg := 'PN_INDEX_REQD_FLDS_INDEX_ONLY';
         END IF;
      ELSIF p_relationship IN (c_relation_greater_of, c_relation_lesser_of) THEN
         IF      p_adj_index_percent_change IS NOT NULL
             AND p_current_basis IS NOT NULL
             AND p_basis_percent_change IS NOT NULL THEN
            v_found_all_reqd_fields := TRUE;
         ELSE
            v_msg := 'PN_INDEX_REQD_FLDS_GT_LT_ONLY';
         END IF;
      END IF;

      -- Only calculate the index if all required fields are available.

      IF v_found_all_reqd_fields THEN

--   Determine the multiplier to the basis amount to get the index amount.
--   Relationship          Method
--   ************          ****************
--   Basis Only            use the basis percentage as multiplier
--   Index Only            use the index percentage as multiplier
--   Greater of            Get the the greater value between index and basis percentage as multiplier
--   Lesser of             Get the the lesser value between index and basis percentage as multiplier

         IF p_relationship = c_relation_basis_only THEN
            v_percent_multiplier := p_basis_percent_change / 100;
         ELSIF p_relationship = c_relation_index_only THEN
            v_percent_multiplier := p_adj_index_percent_change / 100;
         ELSIF p_relationship = c_relation_greater_of THEN
            v_percent_multiplier :=
                           GREATEST (p_adj_index_percent_change, p_basis_percent_change) / 100;
         ELSIF p_relationship = c_relation_lesser_of THEN
            v_percent_multiplier :=
                              LEAST (p_adj_index_percent_change, p_basis_percent_change) / 100;
         END IF; -- p_relationship =

         v_annual_basis_amt := p_current_basis;
         --
         -- calculating unconstrained index amount.
         --
         v_index_rent_amount := v_annual_basis_amt * v_percent_multiplier;
         op_index_amount := ROUND (v_index_rent_amount, get_amount_precision);
      ELSE
         op_msg := v_msg;
      END IF; --  v_found_all_reqd_fields
   END calculate_index_amount;




------------------------------------------------------------------------
-- PROCEDURE : derive_constrained_rent
-- DESCRIPTION: This procedure will:
--              apply all constraints that have been defined for a given index rent.
--              process negative rent as defined in agreement
--              apply rounding as defined in agreement
--
-- 12-DEC-2006 Prabhakar o Added parameter p_prorate_factor
-- 17-APR-2007 Prabhakar o Bug #5988076. Modifyied the way of deriving
--                         negative rent in case of Next Period.
------------------------------------------------------------------------
   PROCEDURE derive_constrained_rent (
      p_index_lease_id              IN       NUMBER
     ,p_current_basis               IN       NUMBER
     ,p_index_period_id             IN       NUMBER
     ,p_assessment_date             IN       DATE
     ,p_negative_rent_type          IN       VARCHAR2
     ,p_unconstrained_rent_amount   IN       NUMBER
     ,p_prev_index_amount           IN       NUMBER
     ,p_carry_forward_flag          IN       VARCHAR2
     ,p_prorate_factor              IN       NUMBER
     ,op_constrained_rent_amount    OUT NOCOPY      NUMBER
     ,op_constraint_applied_amount  OUT NOCOPY      NUMBER
     ,op_constraint_applied_percent OUT NOCOPY      NUMBER
     ,op_carry_forward_amount       OUT NOCOPY      NUMBER
     ,op_carry_forward_percent      OUT NOCOPY      NUMBER
     ,op_msg                        OUT NOCOPY      VARCHAR2
   )
   IS
   CURSOR il_cons ( ip_index_lease_id   IN   NUMBER, ip_prorate_factor IN NUMBER ) IS
   SELECT scope,
          ( maximum_amount * ip_prorate_factor ) maximum_amount,
          ( maximum_percent * ip_prorate_factor ) maximum_percent,
          ( minimum_amount * ip_prorate_factor ) minimum_amount,
          ( minimum_percent * ip_prorate_factor ) minimum_percent
   FROM pn_index_lease_constraints_all
   WHERE index_lease_id = ip_index_lease_id;

   l_lower_bound_amt                NUMBER:=null;
   l_upper_bound_amt                NUMBER:=null;
   l_min_current_period             NUMBER:=null;
   l_max_current_period             NUMBER:=null;
   l_prev_period_index_amt          pn_index_lease_periods.constraint_rent_due%type:=null;
   l_previous_negative_rent         pn_index_lease_periods.unconstraint_rent_due%type:=null;
   l_constrained_amount             pn_index_lease_periods.constraint_rent_due%type:=null;
   l_unconstrained_amount           pn_index_lease_periods.unconstraint_rent_due%type:=null;
   l_last_index_period_id           pn_index_lease_periods.index_period_id%type:=null;
   l_min_current_constr_pct         pn_index_lease_periods.constraint_applied_percent%type:=null;
   l_max_current_constr_pct         pn_index_lease_periods.constraint_applied_percent%type:=null;
   l_min_current_constr_amt         pn_index_lease_periods.constraint_applied_amount%type:=null;
   l_max_current_constr_amt         pn_index_lease_periods.constraint_applied_amount%type:=null;
   l_lower_bound_const_pct          pn_index_lease_periods.constraint_applied_percent%type:=null;
   l_lower_bound_const_amt          pn_index_lease_periods.constraint_applied_amount%type:=null;
   l_upper_bound_const_pct          pn_index_lease_periods.constraint_applied_percent%type:=null;
   l_upper_bound_const_amt          pn_index_lease_periods.constraint_applied_amount%type:=null;
   l_carry_forward_amount           pn_index_lease_periods.carry_forward_amount%type:=null;
   l_carry_forward_percent          pn_index_lease_periods.carry_forward_percent%type:=null;

   BEGIN

      put_log ('pn_index_amount_pkg.derive_constrained_rent   (+): ');
      put_log('derive_constrained_rent - p_index_lease_id :'||p_index_lease_id);
      put_log('derive_constrained_rent - p_current_basis  :'||p_current_basis);
      put_log('derive_constrained_rent - p_index_period_id :'||p_index_period_id);
      put_log('derive_constrained_rent - p_negative_rent_type :'||p_negative_rent_type);
      put_log('derive_constrained_rent - p_unconstrained_rent_amount :'||p_unconstrained_rent_amount);
      put_log('derive_constrained_rent - p_prev_index_amount :'||p_prev_index_amount);
      put_log('derive_constrained_rent - p_carry_forward_flag :'||p_carry_forward_flag);

      l_prev_period_index_amt := p_prev_index_amount;


      /* Derive the minimum constraint and the maximum constraint */

      FOR il_rec IN il_cons (p_index_lease_id, p_prorate_factor)
      LOOP
         put_log('derive_constrained_rent - Scope           :'||il_rec.scope);
         put_log('derive_constrained_rent - minimum_percent :'||il_rec.minimum_percent);
         put_log('derive_constrained_rent - maximum_percent :'||il_rec.maximum_percent);
         put_log('derive_constrained_rent - minimum_amount  :'||il_rec.minimum_amount);
         put_log('derive_constrained_rent - maximum_amount  :'||il_rec.maximum_amount);

         l_min_current_period := null;
         l_max_current_period := null;
         l_min_current_constr_pct := null;
         l_max_current_constr_pct := null;
         l_min_current_constr_amt := null;
         l_max_current_constr_amt := null;

         IF il_rec.scope = c_constraint_rent_due THEN

            if il_rec.minimum_percent is not null then
               l_min_current_period := (il_rec.minimum_percent/100) * p_current_basis;
               l_min_current_constr_pct := il_rec.minimum_percent;
            elsif il_rec.minimum_amount is not null then
               l_min_current_period := il_rec.minimum_amount;
               l_min_current_constr_amt := il_rec.minimum_amount;
            end if;

            if il_rec.maximum_percent is not null then
               l_max_current_period := (il_rec.maximum_percent/100) * p_current_basis;
               l_max_current_constr_pct := il_rec.maximum_percent;
            elsif il_rec.maximum_amount is not null then
               l_max_current_period := il_rec.maximum_amount;
               l_max_current_constr_amt := il_rec.maximum_amount;
            end if;

         ELSIF il_rec.scope = c_constraint_period_to_period THEN

            /* derive the previous periods constrained rent amount. */

            if l_prev_period_index_amt is null then
               derive_prev_index_amount (
                    p_index_lease_id              => p_index_lease_id,
                    p_assessment_date             => p_assessment_date,
                    op_type                       => 'CONSTRAINT',
                    op_index_amount               => l_prev_period_index_amt);
            end if;

            if il_rec.minimum_percent is not null then
               l_min_current_period := l_prev_period_index_amt * ( (il_rec.minimum_percent/100) + 1);
               l_min_current_constr_pct := il_rec.minimum_percent;
            elsif il_rec.minimum_amount is not null then
               l_min_current_period := l_prev_period_index_amt + il_rec.minimum_amount ;
               l_min_current_constr_amt := il_rec.minimum_amount;
            end if;

            if il_rec.maximum_percent is not null then
               l_max_current_period := l_prev_period_index_amt * ( (il_rec.maximum_percent/100) + 1);
               l_max_current_constr_pct := il_rec.maximum_percent;
            elsif il_rec.maximum_amount is not null then
               l_max_current_period := l_prev_period_index_amt + il_rec.maximum_amount;
               l_max_current_constr_amt := il_rec.maximum_amount;
            end if;

         END IF;     --- il_rec.scope = c_constraint_rent_due

         put_log('derive_constrained_rent - l_min_current_period  :'||l_min_current_period);
         put_log('derive_constrained_rent - l_max_current_period  :'||l_max_current_period);

         /* Get the greatest of all minimums and the least of all maximum constraints */

         IF l_lower_bound_amt is null or
            nvl(l_min_current_period,l_lower_bound_amt) > l_lower_bound_amt then

            l_lower_bound_amt := l_min_current_period;
            l_lower_bound_const_pct := l_min_current_constr_pct;
            l_lower_bound_const_amt := l_min_current_constr_amt;
         END IF;

         IF l_upper_bound_amt is null or
            nvl(l_max_current_period,l_upper_bound_amt) < l_upper_bound_amt then

            l_upper_bound_amt := l_max_current_period;
            l_upper_bound_const_pct := l_max_current_constr_pct;
            l_upper_bound_const_amt := l_max_current_constr_amt;
         END IF;

       END LOOP constraints;


       put_log('derive_constrained_rent - min constraint for the period :'||l_lower_bound_amt);
       put_log('derive_constrained_rent - max constraint for the period :'||l_upper_bound_amt);


       l_unconstrained_amount  := p_unconstrained_rent_amount;


      /* Handle negative rent.
         o if negative rent type is ignore then current rent due is 0
         o if negative rent type is next period then if current period
           is not the last period then l_constrained rent := 0
         o if negative rent type is next period then if current period is
           the last period or l_unconstrained_amount >0 then derive the previous
           periods negative rent and add to the current periods unconstrained rent
           due. */


      IF p_negative_rent_type = c_negative_rent_ignore AND
         l_unconstrained_amount < 0 THEN

         l_unconstrained_amount := 0;

      ELSIF p_negative_rent_type = c_negative_rent_next_period THEN

         /* get the id of the last index rent period.*/

         derive_index_period_id (
               p_index_lease_id              => p_index_lease_id,
               p_assessment_date             => NULL,
               op_prev_index_lease_id        => l_last_index_period_id );

         l_last_index_period_id := nvl(l_last_index_period_id,p_index_period_id);


         if l_unconstrained_amount < 0 and
            l_last_index_period_id <> p_index_period_id then

            l_unconstrained_amount := 0;

         elsif l_unconstrained_amount >= 0   or
               l_last_index_period_id = p_index_period_id  then

          /* get the previous periods negative index rent */

            l_previous_negative_rent := derive_prev_negative_rent(
                                               p_index_lease_id   => p_index_lease_id,
                                               p_assessment_date  => p_assessment_date);

            l_unconstrained_amount :=   l_unconstrained_amount + nvl(l_previous_negative_rent,0);

            if l_unconstrained_amount < 0 and l_last_index_period_id <> p_index_period_id then
                l_unconstrained_amount := 0;
            end if;

         end if;

      END IF; -- p_negative_rent_type = c_negative_rent_next_period



      /* Add carry forward amounts to unconstrained rent due if carry forward flag is checked */


       put_log('derive_constrained_rent - before adding carry forward amt,l_unconstrained_amount :' ||l_unconstrained_amount);

       IF p_carry_forward_flag IN('A','P') THEN

          derive_cum_carry_forward(
                                   p_index_lease_id   => p_index_lease_id,
                                   p_assessment_date  => p_assessment_date,
                                   op_carry_forward_amount => l_carry_forward_amount,
                                   op_carry_forward_percent => l_carry_forward_percent);

          if p_carry_forward_flag ='A' then
             l_unconstrained_amount := l_unconstrained_amount + nvl(l_carry_forward_amount,0);
             l_carry_forward_amount := 0;
          else
             l_unconstrained_amount := l_unconstrained_amount +
                                       (nvl(l_carry_forward_percent,0)* (p_current_basis/100));
             l_carry_forward_percent := 0;
          end if;

       END IF;


       put_log('derive_constrained_rent - after adding carry forward amt,l_unconstrained_amount :'||l_unconstrained_amount);

      /* Apply constraints */

      IF nvl(l_upper_bound_amt, l_lower_bound_amt) < nvl(l_lower_bound_amt, l_upper_bound_amt) THEN

         put_log ('ERROR: INVALID RANGE DERIVED BY CONSTRAINTS.....');
         put_log ('l_lower_bound_amt = ' || l_lower_bound_amt);
         put_log ('l_upper_bound_amt = ' || l_upper_bound_amt);
         op_msg := 'PN_INDEX_CONS_INVALID_RANGE';

         l_constrained_amount := l_unconstrained_amount;

      ELSIF l_lower_bound_amt IS NOT NULL AND
         l_unconstrained_amount < l_lower_bound_amt THEN

         l_constrained_amount := l_lower_bound_amt;
         op_constraint_applied_amount := l_lower_bound_const_amt;
         op_constraint_applied_percent := l_lower_bound_const_pct;

      ELSIF l_upper_bound_amt IS NOT NULL AND
            l_unconstrained_amount > l_upper_bound_amt THEN

         l_constrained_amount := l_upper_bound_amt;
         op_constraint_applied_amount := l_upper_bound_const_amt;
         op_constraint_applied_percent := l_upper_bound_const_pct;

         put_log('max constraint applied : l_constrained_amount :'||l_constrained_amount);

         if p_carry_forward_flag = 'A' then

            l_carry_forward_amount := ROUND(l_unconstrained_amount - l_constrained_amount,
                                             get_amount_precision);
         elsif p_carry_forward_flag = 'P' then

            l_carry_forward_percent := ROUND((l_unconstrained_amount - l_constrained_amount)*
                                              (100/p_current_basis),5);
         end if;

      ELSE
         l_constrained_amount := l_unconstrained_amount;
      END IF;

      op_constrained_rent_amount := l_constrained_amount;
      op_carry_forward_percent := l_carry_forward_percent;
      op_carry_forward_amount := l_carry_forward_amount;

      op_constraint_applied_amount := round(op_constraint_applied_amount,get_amount_precision);
      op_constrained_rent_amount := round(op_constrained_rent_amount,get_amount_precision);
      op_constraint_applied_percent := round(op_constraint_applied_percent,5);

      put_log ('derive_constrained_rent - op_constraint_applied_amount  :'||op_constraint_applied_amount);
      put_log ('derive_constrained_rent - op_carry_forward_amount       :'||op_carry_forward_amount);
      put_log ('derive_constrained_rent - op_constraint_applied_percent :'||op_constraint_applied_percent);
      put_log ('derive_constrained_rent - op_carry_forward_percent      :'||op_carry_forward_percent);
      put_log ('derive_constrained_rent - op_constrained_rent_amount    :'||op_constrained_rent_amount);
      put_log ('pn_index_amount_pkg.derive_constrained_rent   (-): ');

   END derive_constrained_rent;


------------------------------------------------------------------------
-- PROCEDURE : lookup_index_history
-- DESCRIPTION: This procedure will derive the cpi value and index history id using
--              finder date provided.
--
------------------------------------------------------------------------

   PROCEDURE lookup_index_history (
      p_index_history_id    IN       NUMBER
     ,p_index_finder_date   IN       DATE
     ,op_cpi_value          OUT NOCOPY      NUMBER
     ,op_cpi_id             OUT NOCOPY      NUMBER
     ,op_msg                OUT NOCOPY      VARCHAR2
   ) IS
      v_index_line_id   pn_index_history_lines.index_line_id%TYPE;
      v_index_figure    pn_index_history_lines.index_figure%TYPE;
      v_msg             VARCHAR2 (1000);
      v_found_index     BOOLEAN;
   BEGIN
      --put_log ('..In lookup_index_history');
      --
      -- When performing lookup, ignore the day component is optional...
      --
      BEGIN
         --
         -- for performance considerations, lookup will first be done with the full finder date..
         --

         BEGIN
            SELECT phl.index_line_id
                  ,phl.index_figure
              INTO v_index_line_id
                  ,v_index_figure
              FROM pn_index_history_lines phl
             WHERE phl.index_id = p_index_history_id
               AND phl.index_date = p_index_finder_date;
            v_found_index := TRUE;
         EXCEPTION
            WHEN OTHERS THEN
               v_found_index := FALSE;
         END;

         IF NOT v_found_index THEN
            SELECT phl.index_line_id
                  ,phl.index_figure
              INTO v_index_line_id
                  ,v_index_figure
              FROM pn_index_history_lines phl
             WHERE phl.index_id = p_index_history_id
               AND TO_NUMBER (TO_CHAR (phl.index_date, 'MMYYYY')) =
                                       TO_NUMBER (TO_CHAR (p_index_finder_date, 'MMYYYY'));
         END IF; --NOT V_FOUND_INDEX

         --
         -- get
         --
         op_cpi_value := v_index_figure;
         op_cpi_id := v_index_line_id;

         IF op_cpi_value IS NULL THEN
            v_msg := 'PN_INDEX_HIST_REC_IS_BLANK';
         END IF;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            put_log (
                  '      Duplicate records for the finder date: '
               || TO_CHAR (p_index_finder_date, 'MON-YYYY')
            );
            v_msg := 'PN_INDEX_DUP_HIST_REC_NOT_FOUND';
         WHEN NO_DATA_FOUND THEN
            put_log (
                  '      Unable to find a record using the finder date: '
               || TO_CHAR (p_index_finder_date, 'MON-YYYY')
            );
            v_msg := 'PN_INDEX_HIST_REC_NOT_FOUND';
         WHEN OTHERS THEN
            put_log (   '      Cannot Derive Index Amount - Unknow Error:'
                     || SQLERRM);
      END;

      op_msg := v_msg;
   END lookup_index_history;


------------------------------------------------------------------------
-- PROCEDURE : calculate_index_percentage
-- DESCRIPTION: This procedure will derive the current and previous CPI for a given index period.
--              It will also calculate the index change percentage
--
-- 09-Jul-2001  psidhu
--              Added Fix for bug # 1873888
-- 23-aug-2001  psidhu
--              Added fix for bug # 1952508
--
------------------------------------------------------------------------

   PROCEDURE calculate_index_percentage (
      p_index_finder_type       IN       VARCHAR2
     ,p_reference_period_type   IN       VARCHAR2
     ,p_index_finder_date       IN       DATE
     ,p_index_history_id        IN       NUMBER
     ,p_base_index              IN       NUMBER
     ,p_base_index_line_id      IN       NUMBER
     ,p_index_lease_id          IN       NUMBER
     ,p_assessment_date         IN       DATE
     ,p_prev_assessment_date    IN       DATE
     ,op_current_cpi_value      IN OUT NOCOPY   NUMBER
     ,op_current_cpi_id         IN OUT NOCOPY   NUMBER
     ,op_previous_cpi_value     IN OUT NOCOPY   NUMBER
     ,op_previous_cpi_id        IN OUT NOCOPY   NUMBER
     ,op_index_percent_change   OUT NOCOPY      NUMBER
     ,op_msg                    OUT NOCOPY      VARCHAR2
   ) IS
      v_current_cpi_value           pn_index_lease_periods.current_index_line_value%TYPE;
      v_current_cpi_id              pn_index_lease_periods.current_index_line_id%TYPE;
      v_previous_cpi_value          pn_index_lease_periods.previous_index_line_value%TYPE;
      v_previous_cpi_id             pn_index_lease_periods.previous_index_line_id%TYPE;
      v_prev_assessment_date        pn_index_lease_periods.assessment_date%TYPE;
      v_prev_period_id              pn_index_lease_periods.index_period_id%TYPE;
      v_num_months_bet_asmnt_date   NUMBER;
      v_num_days_bet_asmnt_date    NUMBER;
      v_msg                         VARCHAR2 (1000);
      v_all_msg                     VARCHAR2 (1000);
      v_current_finder_date         pn_index_lease_periods.index_finder_date%TYPE;
      v_previous_finder_date        pn_index_lease_periods.index_finder_date%TYPE;
      v_upper_index_date_code       NUMBER;
      v_lower_index_date_code       NUMBER;

      CURSOR get_relationship IS
         SELECT relationship
         FROM pn_index_lease_periods_all
         WHERE assessment_date = p_assessment_date
         AND index_lease_id = p_index_lease_id;

      v_relationship_default VARCHAR2(30);

   /*
   - Calculate the index change (CALCULATE_INDEX_PERCENTAGE)



               Derive Current CPI:

                    Note: Finder date lookup only match the year and month and not the day.

                    IF INDEX_FINDER = Always Finder Date (Code: ??) or THEN
                         Current CPI = Lookup PN_INDEX_HISTORY_LINES using finder date

                    ELSE INDEX_FINDER = Backbill (Code: ??)
                         Current CPI = Lookup PN_INDEX_HISTORY_LINES using finder date

                    ELSE INDEX_FINDER = Most Recent(Code: ??)

                         Current CPI = Lookup PN_INDEX_HISTORY_LINES using the most recent reported

                              index from up to a year from the finder date.

               Derive Previous  CPI:

                    Note: Finder date lookup only match the year and month and not the day.

                    IF REFERENCE_PERIOD = Base Year (Code: ??) THEN

                         Previous CPI = Base Index Value from Agreement (PN_INDEX_LEASES.BASE_INDEX)

                    ELSE IF REFERENCE_PERIOD = Previous Year (Code: ??) THEN

                         1> Take the elapsed time between the current assessment date and the prevous period's assessment
date
                         2> Use as finder date the date from (current finder date - number in Step 1) to derive a CPI to be
used as the previous CPI.


               If Both Previous and Current CPI are available, calculate Index

                    - Index = (Current Index - Previous Index)  Previous Index



   */




   BEGIN
      --put_log ('..In calculate_index_percentage');


      --
      -- if no current cpi value, derive a current cpi
      --

      IF op_current_cpi_value IS NOT NULL THEN
         v_current_cpi_value := op_current_cpi_value;
         v_current_cpi_id := op_current_cpi_id;
         v_current_finder_date := p_index_finder_date;
      ELSE
         --
         -- if index finder type
         --     use finder date or use finder w/ backbill
         --
         IF    p_index_finder_type = c_index_finder_finder_date
            OR p_index_finder_type = c_index_finder_backbill THEN
            --
            -- Use the finder date to derive current CPI
            --
            v_current_finder_date := p_index_finder_date;
         ELSIF p_index_finder_type = c_index_finder_most_recent THEN
            --
            -- If finder type = USE MOST RECENT, use the last reported index within a year of the current
            -- date.
            --
            -- Deriving the date of last reported index upto within a year of today's date

            -- first, decide the upper and lower date range to be used:
            --        since the index date has no day component, each date is converted
            --        to its six digit equivalent

            SELECT TO_NUMBER (TO_CHAR (p_index_finder_date, 'YYYYMM'))
                  ,TO_NUMBER (TO_CHAR (ADD_MONTHS (p_index_finder_date, -12), 'YYYYMM'))
              INTO v_upper_index_date_code
                  ,v_lower_index_date_code
              FROM DUAL;
            --
            -- second, derive the finder date to be used.
            --
            SELECT MAX (phl.index_date)
              INTO v_current_finder_date
              FROM pn_index_history_lines phl
             WHERE phl.index_id = p_index_history_id
               AND TO_NUMBER (TO_CHAR (phl.index_date, 'YYYYMM'))
                      BETWEEN v_lower_index_date_code
                          AND v_upper_index_date_code
               AND index_figure IS NOT NULL;
         END IF; -- p_index_finder_type = ??

         lookup_index_history (
            p_index_history_id            => p_index_history_id
           ,p_index_finder_date           => v_current_finder_date
           ,op_cpi_value                  => v_current_cpi_value
           ,op_cpi_id                     => v_current_cpi_id
           ,op_msg                        => v_msg
         );
      --pn_index_lease_common_pkg.append_msg (p_new_msg => v_msg, p_all_msg => v_all_msg);

      END IF; -- op_current_cpi_value is not null 0

      --
      -- if no previous cpi value, derive a current cpi
      --

      IF op_previous_cpi_value IS NOT NULL THEN
         v_previous_cpi_value := op_previous_cpi_value;
         v_previous_cpi_id := op_previous_cpi_id;
      ELSE
         --
         -- Deriving the Previous  CPI
         --
         IF p_reference_period_type = c_ref_period_base_year THEN
            --put_log ('      Reference Period: BASE YEAR');
            --
            -- If Reference Period = Base Year, use the Base Index Value from the agreement
            --    window.
            IF    p_base_index IS NOT NULL
               OR p_base_index_line_id IS NOT NULL THEN
               v_previous_cpi_value := p_base_index;
               v_previous_cpi_id := p_base_index_line_id;
            ELSE
               --put_log ('      Base Index is Missing.');
               pn_index_lease_common_pkg.append_msg (
                  p_new_msg                     => 'PN_INDEX_BASE_INDEX_REQUIRED'
                 ,p_all_msg                     => v_all_msg
               );
            END IF;
         ELSIF p_reference_period_type = c_ref_period_prev_year_asmt_dt THEN
            --put_log ('      Reference Period: PREV YEAR');

            --
            -- If Reference Period = Prev Year

            --
            -- Get the assessment date of the previous period, if not passed from calling program
            --
            IF p_prev_assessment_date IS NULL THEN
               --
               -- Get the latest assessment date before the current assessment date
               --
               SELECT MAX (pilp.assessment_date)
                 INTO v_prev_assessment_date
                 FROM pn_index_lease_periods_all pilp
                WHERE pilp.index_lease_id = p_index_lease_id
                  AND pilp.assessment_date < p_assessment_date;
            ELSE
               v_prev_assessment_date := p_prev_assessment_date;
            END IF; --p_prev_assessment_date IS NULL

            IF v_prev_assessment_date IS NULL THEN
               --
               -- if we can't derive a previous assessment date, then
               -- we must be in the first period, therefore use
               -- base index.
               --
               v_previous_cpi_value := p_base_index;
            ELSE
               --
               -- Get the duration between assessment dates
               --
                 v_num_months_bet_asmnt_date :=
                      CEIL (MONTHS_BETWEEN (p_assessment_date, v_prev_assessment_date));
               --
               -- Derive a new finder date but subtracting the duration between assessment dates from the finder
               --  date used to dervie the current CPI.
               --
               v_previous_finder_date :=
                      ADD_MONTHS (v_current_finder_date, -1 * v_num_months_bet_asmnt_date);
               --
               -- Derive a new index amount using the finder date derived from previous step.
               --
               lookup_index_history (
                  p_index_history_id            => p_index_history_id
                 ,p_index_finder_date           => v_previous_finder_date
                 ,op_cpi_value                  => v_previous_cpi_value
                 ,op_cpi_id                     => v_previous_cpi_id
                 ,op_msg                        => v_msg
               );
            END IF; --v_prev_assessment_date IS NULL
         ELSIF p_reference_period_type = c_ref_period_prev_year_prv_cpi THEN
            --
            -- reference period is previous year, and use the cpi of the previous index rent period
            --


            --
            -- derive the index id of the period id of the previous assessment date
            --

            derive_index_period_id (
               p_index_lease_id              => p_index_lease_id
              ,p_assessment_date             => p_assessment_date
              ,op_prev_index_lease_id        => v_prev_period_id
            );

            --
            -- getting the current cpi info of the prev index rent period
            --
            IF v_prev_period_id IS NOT NULL THEN
               SELECT current_index_line_id
                     ,current_index_line_value
                 INTO v_previous_cpi_id
                     ,v_previous_cpi_value
                 FROM pn_index_lease_periods_all
                WHERE index_period_id = v_prev_period_id;
             ELSE
             -- Fix for bug # 1873888
             -- If no previous CPI is found, then use base index
               IF p_base_index IS NOT NULL
                OR p_base_index_line_id IS NOT NULL THEN
                        v_previous_cpi_value := p_base_index;
                        v_previous_cpi_id := p_base_index_line_id;
                ELSE
                       --put_log ('      Base Index is Missing.');
                         pn_index_lease_common_pkg.append_msg (
                               p_new_msg                     => 'PN_INDEX_BASE_INDEX_REQUIRED'
                              ,p_all_msg                     => v_all_msg
                                                             );
                       END IF;
               --
              END IF;
         END IF; --p_reference_period_type = ????

         put_log (
               '      Finder Date Used:   Current='
            || TO_CHAR (v_current_finder_date, 'MON-YYYY')
            || '    Previous='
            || NVL (TO_CHAR (v_previous_finder_date, 'MON-YYYY'), 'Using Base Year')
         );
      END IF; --op_previous_cpi_value IS NOT NULL

      --
      -- Calculate CPI
      --

      IF      v_current_cpi_value IS NOT NULL
          AND v_previous_cpi_value IS NOT NULL THEN
         op_index_percent_change := ROUND (
                                         (  v_current_cpi_value
                                          - v_previous_cpi_value
                                         )
                                       / v_previous_cpi_value
                                       * 100
                                      ,5             --fix for bug # 1952508
                                    );
      ELSE

         FOR rec IN get_relationship LOOP
            v_relationship_default := rec.relationship;
         END LOOP;

         IF v_relationship_default IN ('GREATER_OF','LESSER_OF') THEN

            pn_index_lease_common_pkg.append_msg (
               p_new_msg                     => 'PN_INDEX_INDEX_CHANGE_REQ'
              ,p_all_msg                     => v_all_msg
            );

         ELSIF v_relationship_default IN ('INDEX_ONLY') THEN
            pn_index_lease_common_pkg.append_msg (
               p_new_msg                     => 'PN_INDEX_PERIOD_INDEX_REQ'
              ,p_all_msg                     => v_all_msg
            );
         END IF;

      END IF;

      op_current_cpi_value := v_current_cpi_value;
      op_current_cpi_id := v_current_cpi_id;
      op_previous_cpi_value := v_previous_cpi_value;
      op_previous_cpi_id := v_previous_cpi_id;
      op_msg := v_all_msg;
   END calculate_index_percentage;


------------------------------------------------------------------------
-- PROCEDURE : chk_normalized_amount
-- DESCRIPTION: This look at a period's payment terms and derive the annual
--                 amount that has been normalized.  This is important
--                 when calculating the backbill amount.
------------------------------------------------------------------------


   PROCEDURE chk_normalized_amount (
      p_index_period_id            IN       NUMBER
     ,op_normalize_amount_annual   OUT NOCOPY      NUMBER
     ,op_msg                       OUT NOCOPY      VARCHAR2
   ) IS
      v_found_normalize        NUMBER (1);
      v_normalized_amount      pn_payment_terms.actual_amount%TYPE;
      v_normalized_frequency   pn_payment_terms.frequency_code%TYPE;
      v_multiplier             NUMBER (3);


     /* cursor to select all normalized payment terms recurring payment that are APPROVED and not normalized.*/

      CURSOR c1 IS
         SELECT ppt.actual_amount
               ,ppt.frequency_code
           FROM pn_payment_terms_all ppt
          WHERE ppt.index_period_id = p_index_period_id
      AND ppt.index_term_indicator = c_index_pay_term_type_atlst;

   BEGIN

      op_normalize_amount_annual := 0;

      FOR c1_rec IN c1
      LOOP
         v_normalized_amount := c1_rec.actual_amount;
         v_normalized_frequency := c1_rec.frequency_code;
         SELECT DECODE (
                   v_normalized_frequency
                  ,c_spread_frequency_monthly, 12
                  ,c_spread_frequency_one_time, 1
                  ,c_spread_frequency_quarterly, 4
                  ,c_spread_frequency_semiannual, 2
                  ,c_spread_frequency_annually, 1
                  ,1
                )
           INTO v_multiplier
           FROM DUAL;
         op_normalize_amount_annual :=   (v_normalized_amount * v_multiplier)
                                       + op_normalize_amount_annual;
      END LOOP;

   END chk_normalized_amount;


------------------------------------------------------------------------
-- PROCEDURE : chk_approved_amount
-- DESCRIPTION: This procedure will check for all approved  non-normailized
--              recurring payment terms
------------------------------------------------------------------------



PROCEDURE chk_approved_amount (
      p_index_period_id IN NUMBER
     ,p_index_term_indicator IN VARCHAR2
     ,op_approved_amount_annual OUT NOCOPY NUMBER
     ,op_msg OUT NOCOPY VARCHAR2
   ) IS
      v_found_approved         NUMBER (1);
      v_all_approved_amounts   NUMBER                                 := 0;
      v_multiplier             NUMBER (3);

      --
      -- cursor to select all recurring payment that are APPROVED.
      --
      CURSOR c1 IS
         SELECT ppt.payment_term_id, ppt.actual_amount, ppt.frequency_code
           FROM pn_payment_terms_all ppt
          WHERE ppt.index_period_id = p_index_period_id
            AND ppt.status =c_payment_term_status_approved
            AND ppt.index_term_indicator = p_index_term_indicator;
   BEGIN
      FOR cursor_rec IN c1
      LOOP

         SELECT DECODE (
                   cursor_rec.frequency_code
                  ,c_spread_frequency_monthly, 12
                  ,c_spread_frequency_one_time, 1
                  ,c_spread_frequency_quarterly, 4
                  ,c_spread_frequency_semiannual, 2
                  ,c_spread_frequency_annually, 1
                  ,1
                )
           INTO v_multiplier
           FROM DUAL;
         v_all_approved_amounts :=   (cursor_rec.actual_amount * v_multiplier)
                                   + v_all_approved_amounts;
      END LOOP;

      op_approved_amount_annual := v_all_approved_amounts;
   END chk_approved_amount;


   ------------------------------------------------------------------------
   -- PROCEDURE : chk_approved_amount
   -- DESCRIPTION: This procedure will check for all approved  non-normailized
   --              recurring payment terms
   ------------------------------------------------------------------------



   PROCEDURE chk_aggregated_approved_amount (
         p_index_period_id IN NUMBER
        ,p_index_term_indicator IN VARCHAR2
        ,p_location_id IN NUMBER
        ,p_payment_purpose_code IN VARCHAR2
        ,p_payment_term_type_code IN VARCHAR2
        ,p_vendor_id IN NUMBER
        ,p_vendor_site_id IN NUMBER
        ,p_customer_id IN NUMBER
        ,p_customer_site_use_id IN NUMBER
        ,p_distribution_string IN VARCHAR2
        ,p_normalize IN VARCHAR2
        ,op_approved_amount_annual OUT NOCOPY NUMBER
        ,op_msg OUT NOCOPY VARCHAR2
      ) IS
         v_found_approved         NUMBER (1);
         v_approved_amount        pn_payment_terms.actual_amount%TYPE;
         v_approved_frequency     pn_payment_terms.frequency_code%TYPE;
         v_all_approved_amounts   NUMBER                                 := 0;
         v_multiplier             NUMBER (3);
         v_exists                 NUMBER := 0;

         --
         -- cursor to select all recurring payment that are APPROVED and not normalized.
         --
         CURSOR c1(ip_location_id IN NUMBER
                  ,ip_payment_purpose_code IN VARCHAR2
                  ,ip_payment_term_type_code IN VARCHAR2
                  ,ip_vendor_id IN NUMBER
                  ,ip_vendor_site_id IN NUMBER
                  ,ip_customer_id IN NUMBER
                  ,ip_customer_site_use_id IN NUMBER
                  ,ip_distribution_string IN VARCHAR2
                  ,ip_index_term_indicator IN VARCHAR2
                  ,ip_normalize IN VARCHAR2
                  ,ip_index_period_id IN NUMBER)IS
         SELECT ppt.payment_term_id, ppt.actual_amount,ppt.frequency_code
         FROM pn_payment_terms_all ppt,
              pn_payment_items_all ppi
         WHERE ppt.index_period_id = ip_index_period_id
         AND ppt.status =c_payment_term_status_approved
         AND ppt.index_term_indicator = ip_index_term_indicator
         AND ppt.payment_purpose_code = ip_payment_purpose_code
         AND ppt.payment_term_type_code = ip_payment_term_type_code
         AND ppt.payment_term_id = ppi.payment_term_id
         AND ppi.payment_item_type_lookup_code = 'CASH'
         AND DECODE (
                     ip_index_term_indicator
                    ,c_index_pay_term_type_atlst, NVL (ppt.normalize, 'N')
                    ,'IGNORE'
                      ) = ip_normalize
         AND (   ppt.location_id = ip_location_id
               OR ip_location_id IS NULL
              )
         AND (   ppt.vendor_id = ip_vendor_id
               OR ip_vendor_id IS NULL
              )
         AND (   ppt.vendor_site_id = ip_vendor_site_id
               OR ip_vendor_site_id IS NULL
             )
         AND (   ppt.customer_id = ip_customer_id
               OR ip_customer_id IS NULL
             )
         AND (   ppt.customer_site_use_id = ip_customer_site_use_id
               OR ip_customer_site_use_id IS NULL
             )
         AND (   build_distributions_string (ppt.payment_term_id) = ip_distribution_string
               OR ip_distribution_string IS NULL
              );
      BEGIN

         SELECT '1'
         INTO v_exists
         FROM pn_payment_terms_all
         WHERE index_period_id = p_index_period_id
         AND   status = c_payment_term_status_approved
         AND   index_term_indicator = p_index_term_indicator;


         IF v_exists = 1   THEN

            FOR cursor_rec IN c1  (ip_location_id => p_location_id
                                  ,ip_payment_purpose_code => p_payment_purpose_code
                                  ,ip_payment_term_type_code => p_payment_term_type_code
                                  ,ip_vendor_id  => p_vendor_id
                                  ,ip_vendor_site_id => p_vendor_site_id
                                  ,ip_customer_id => p_customer_id
                                  ,ip_customer_site_use_id  => p_customer_site_use_id
                                  ,ip_distribution_string  => p_distribution_string
                                  ,ip_index_term_indicator  => p_index_term_indicator
                                  ,ip_normalize => p_normalize
                                  ,ip_index_period_id => p_index_period_id )
            LOOP

               SELECT DECODE (
                      cursor_rec.frequency_code
                     ,c_spread_frequency_monthly, 12
                     ,c_spread_frequency_one_time, 1
                     ,c_spread_frequency_quarterly, 4
                     ,c_spread_frequency_semiannual, 2
                     ,c_spread_frequency_annually, 1
                     ,1
                   )
              INTO v_multiplier
              FROM DUAL;
              v_all_approved_amounts :=   (cursor_rec.actual_amount * v_multiplier)
                                         + v_all_approved_amounts;
           END LOOP;

         op_approved_amount_annual := v_all_approved_amounts;
        END IF;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN  op_approved_amount_annual := 0;
         WHEN OTHERS THEN
            put_log (   '      Cannot Derive Aggregated approved amount - Unknow Error:'
                     || SQLERRM);

      END chk_aggregated_approved_amount;



------------------------------------------------------------------------
-- PROCEDURE : derive_payment_start_date
-- DESCRIPTION: This procedure will derive the current and previous CPI for a given index period.
--              It will also calculate the index change percentage
--
--  08-OCT-2004  Satish Tripathi o Modified for BUG# 3961117, added new parameter p_calculate_date
--                                 for not to create backbills if Assessment Date <= CutOff Date.
--  01-DEC-2006  Prabhakar o Changed the parameter name p_main_lease_termination_date
--                           to p_end_date.
--  30-MAR-2007  Hareesha  o Bug # 5958131 Added handling for new option
--                           of createing single term for backbill + recurring terms.
------------------------------------------------------------------------



   PROCEDURE derive_payment_start_date (
      p_spread_frequency              IN       VARCHAR2
     ,p_assessment_date               IN       DATE
     ,p_end_date                      IN       DATE
     ,p_calculate_date                IN       DATE
     ,p_index_lease_id                IN       NUMBER
     ,op_recur_pay_start_date         OUT NOCOPY DATE
     ,op_num_pymt_since_assmt_dt      OUT NOCOPY NUMBER
   ) IS
      v_recurring_payment_start_date   DATE;
      v_num_months_bet_payments        NUMBER;
      v_num_pymt_since_assmt_dt        NUMBER := 0;
      l_index_finder_method            VARCHAR2(30);

      CURSOR get_index_finder IS
         SELECT index_finder_method
         FROM pn_index_leases_all
         WHERE index_lease_id = p_index_lease_id;

   BEGIN

      put_log(' derive_payment_start_date (+) ');
      --
      -- Determine the start date for the recurring payment.
      -- Will also determine the no. of payments made for this
      -- period since the assessment date.

      SELECT DECODE (
                p_spread_frequency
               ,c_spread_frequency_monthly, 1
               ,c_spread_frequency_quarterly, 3
               ,c_spread_frequency_semiannual, 6
               ,c_spread_frequency_annually, 12
               ,1
             )
        INTO v_num_months_bet_payments
        FROM DUAL;
      v_recurring_payment_start_date := p_assessment_date;

      FOR rec IN get_index_finder LOOP
         l_index_finder_method := rec.index_finder_method;
      END LOOP;
      --
      -- if the current date is later than the assessment date
      --   derive a start date of recurring payments, using the spread
      --   frequency defined in the agreement.
      --

      IF p_calculate_date > p_assessment_date AND
         ( (NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') IN ('OT','RECUR')) OR
            (NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') IN ('SINGLETERM') AND
              l_index_finder_method IN ('FINDER_DATE')))
      THEN
         v_num_pymt_since_assmt_dt := 0;

        /*Fix for bug# 2007492
          If main lease termination date < sysdate then
          derive the num of payments from assessment date to the main lease termination date. */

         WHILE v_recurring_payment_start_date < least(trunc(SYSDATE),trunc(p_end_date))
         LOOP
            -- get the next payment date
            v_recurring_payment_start_date :=
                   ADD_MONTHS (v_recurring_payment_start_date, v_num_months_bet_payments);
            -- increment counter of no. of payments
            v_num_pymt_since_assmt_dt :=   v_num_pymt_since_assmt_dt
                                         + 1;
         END LOOP;
      END IF;

      op_recur_pay_start_date := v_recurring_payment_start_date;
      op_num_pymt_since_assmt_dt := v_num_pymt_since_assmt_dt;
      put_log(' derive_payment_start_date (-) '||v_recurring_payment_start_date);
   END derive_payment_start_date;



------------------------------------------------------------------------
-- PROCEDURE : derive_term_end_date
-- DESCRIPTION : This procedure will derive the RI term end date
--
-- 01-DEC-2006 Prabhakar o Created.
--
-- 07-MAR-2007 Prabhakar o Modified to return index_termination_date
--                         as the last assessment period end date.
--                         Fix for Bug : 5917452
-- 02-APR-2007 Hareesha  o Bug # 5960582 Added handling for new profile-option
--                         PN_RENT_INCREASE_TERM_END_DATE
------------------------------------------------------------------------
PROCEDURE derive_term_end_date (ip_index_lease_id                 NUMBER
                               ,ip_index_period_id                NUMBER
                               ,ip_main_lease_termination_date    DATE
                               ,op_term_end_date     OUT NOCOPY   DATE) IS
   v_end_date                       DATE;
   v_reference_period_type          VARCHAR2(30);
   v_basis_type                     VARCHAR2(30);
   v_max_assessment_date            DATE;
   v_current_assessment_date        DATE;
   v_next_assessment_date           DATE;

   TYPE assessment_date IS
   TABLE OF DATE INDEX BY BINARY_INTEGER;
   assessment_date_table  assessment_date;

   v_period_number                 NUMBER := 0;
   v_assess_in_years               NUMBER;
   v_index_termination_date        DATE;

   CURSOR ref_period_cur(p_index_lease_id NUMBER) IS
   SELECT basis_type,reference_period,assessment_interval,termination_date
   FROM pn_index_leases_all
   WHERE index_lease_id = p_index_lease_id;

   CURSOR assessment_date_cur(p_index_lease_id NUMBER) IS
   SELECT assessment_date, index_period_id
   FROM pn_index_lease_periods_all
   WHERE index_lease_id = p_index_lease_id
   ORDER BY assessment_date;

BEGIN

/* NOTE : If the profile option is period_end and ref type is base yaer and basis type is fixed
                   then term end date is one day prior to the next assessment date.
                   For the last term lease termination date is the term end date.
                   In all other cases the deafult term end date is lease termination date  */

      FOR ref_period_rec IN ref_period_cur(ip_index_lease_id)  LOOP
          v_reference_period_type := ref_period_rec.reference_period;
          v_assess_in_years := ref_period_rec.assessment_interval;
          v_basis_type := ref_period_rec.basis_type;
          v_index_termination_date := ref_period_rec.termination_date;
       END LOOP;

       FOR assessment_date_rec IN assessment_date_cur(ip_index_lease_id) LOOP
           IF assessment_date_rec.index_period_id = ip_index_period_id THEN
              v_current_assessment_date := assessment_date_rec.assessment_date;
           END IF;

           v_period_number := v_period_number + 1;
           assessment_date_table(v_period_number) := assessment_date_rec.assessment_date;

           v_max_assessment_date := assessment_date_rec.assessment_date;
       END LOOP;

        v_end_date := ip_main_lease_termination_date; -- default value

        IF nvl(fnd_profile.value('PN_IR_TERM_END_DATE'),'LEASE_END') = 'PERIOD_END' AND
             v_basis_type = c_basis_type_fixed AND
             v_reference_period_type = c_ref_period_base_year
        THEN
           IF v_current_assessment_date < v_max_assessment_date THEN
              v_period_number := 1;
              WHILE ( assessment_date_table(v_period_number) <= v_current_assessment_date) LOOP
                 v_next_assessment_date := assessment_date_table(v_period_number +1);
                 v_period_number := v_period_number +1;
              END LOOP;
              v_end_date := v_next_assessment_date-1;
            ELSE
               v_end_date := least(ip_main_lease_termination_date,v_index_termination_date);
            END IF;

        ELSE

           IF NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') = 'END_AGRMNT' THEN
              v_end_date := v_index_termination_date;
           ELSE
              v_end_date := ip_main_lease_termination_date;
           END IF;
        END IF;

        op_term_end_date := v_end_date;

END derive_term_end_date;



------------------------------------------------------------------------
-- PROCEDURE : insert_inter_term
-- DESCRIPTION: This procedure will store information of individual terms contribution
--              toward a particular rent increase.
--
------------------------------------------------------------------------

procedure insert_inter_term (ip_index_period_id      NUMBER,
                             ip_index_term_indicator VARCHAR2,
                             ip_combination_amt         NUMBER,
                             ip_total_terms_amt         NUMBER,
                             ip_rent_increase_term_id   NUMBER,
                             ip_index_lease_id          NUMBER) IS

i                     NUMBER;
l_term_contribution   NUMBER;
l_total_inter_term    NUMBER;
l_sum_of_terms_loop   NUMBER := 0;
l_index_lease_term_id pn_index_lease_terms.index_lease_term_id%type;

cursor cur_total_inter_term ( ip_payment_term_id NUMBER) IS
    SELECT SUM(amount) total_inter_term
    FROM   pn_index_lease_terms_all
    WHERE  index_period_id = ip_index_period_id
    AND    lease_term_id   = ip_payment_term_id
    AND    index_term_indicator = ip_index_term_indicator;

begin

/* From the Pl/SQL table which contains the payment term id and the annualized amounts of the
   payment terms contained in an aggregation combination, find out NOCOPY their individual contribution
   towards the rent of the aggregation combination. */

FOR i in 1..item_amt_tab.count
loop
      /* Added the condition if ip_total_terms_amt <> 0 then ..  as a fix for
         bug # 2352453 . Added on 06-May-2002 by psidhu */

      IF ip_total_terms_amt <> 0 THEN
         l_term_contribution := (ip_combination_amt/ip_total_terms_amt) * item_amt_tab(i).amount;
      ELSE
         l_term_contribution := 0;
      END IF;

      /* for the last term the contribution will be the difference of the aggr combination
         rent and the sum of rent contributions by prior payment terms of the combination */

      IF i = item_amt_tab.count THEN

         l_term_contribution :=  ip_combination_amt - l_sum_of_terms_loop;

      ELSE

        l_sum_of_terms_loop := l_sum_of_terms_loop + l_term_contribution;

     END IF;

     /* Get the approved contributions for the payment term, from the intermediate table */

     open cur_total_inter_term(item_amt_tab(i).payment_term_id);

     fetch cur_total_inter_term into l_total_inter_term;

     close cur_total_inter_term;


     IF ((NVL(l_term_contribution,0) - NVL(l_total_inter_term,0)) <> 0 ) THEN


        l_index_lease_term_id := NULL;

        PN_INDEX_LEASE_TERMS_PKG.INSERT_ROW
        (
        X_INDEX_LEASE_TERM_ID     => l_index_lease_term_id
        ,X_INDEX_LEASE_ID         => ip_index_lease_id
        ,X_INDEX_PERIOD_ID        => ip_index_period_id
        ,X_LEASE_TERM_ID          => item_amt_tab(i).payment_term_id
        ,X_RENT_INCREASE_TERM_ID  => ip_rent_increase_term_id
        ,X_AMOUNT                 => (NVL(l_term_contribution,0)- NVL(l_total_inter_term,0))
        ,X_APPROVED_FLAG          => 'DRAFT'
        ,X_INDEX_TERM_INDICATOR   => ip_index_term_indicator
        ,X_LAST_UPDATE_DATE       => SYSDATE
        ,X_LAST_UPDATED_BY        => NVL (fnd_profile.VALUE ('USER_ID'), 0)
        ,X_CREATION_DATE          => SYSDATE
        ,X_CREATED_BY             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
        ,X_LAST_UPDATE_LOGIN      => NVL (fnd_profile.VALUE ('USER_ID'), 0)
        );

    END IF;

END LOOP;

end insert_inter_term;

--------------------------------------------------------------------------------
-- PROCEDURE : create_aggr_payment_terms
-- DESCRIPTION: This procedure will create payment terms during
--              aggregation.
-- 12-FEB-02 psidhu   o bug# 2221341. Added condition in cursor cur_unq_comb to
--                      fetch index rent increase payment terms only if
--                      basis_type <>COMPOUND.
--                    o bug# 2214561. Round payment term contribution for unique
--                      aggregation combination.
-- 14-AUG-03 ftanudja o Handled untouched index lease payment terms. #3027574.
-- 11-NOV-03 ftanudja o Take into account only approved terms for cursor
--                      fetch_generated_il_terms. #3243150.
-- 08-OCT-04 Satish   o BUG# 3961117, added new parameter p_calculate_date for
--                      not to create backbills if Assessment Date <= CutOff Dt
-- 01-DEC-04 ftanudja o Before calling create_payment_term_record, check if
--                      start date < lease termination date. #3964221.
--                    o Changed cursor cur_unq_comb to exclude one time payment
--                      term combinations.
-- 18-JAN-05 ftanudja o Before approving negative consolidation terms,
--                      check if schedule day conflicts. #4081821.
-- 03-Feb-05 Kiran    o Bug # 4031003 - based on the profile value of
--                      PN_CALC_ANNUALIZED_BASIS decide whether to calculate
--                      annualized basis for the terms active as of the period
--                      End date or the for the entire period.
-- 14-APR-05 ftanudja o Added cur_sum_backbill_overlap_items and logic to
--                      take into account recurring term amount overlapping
--                      with backbill. #4307736
-- 19-SEP-05 piagrawa o Modified to pass org id to pn_mo_cache_utils.
--                      get_profile_value
-- 06-APR-06 hkulkarn o Bug4291907 -  check if v_created_payment_term_id IS not
--                      null before making call to insert_inter_term
-- 05-MAY-06 Hareesha o Bug# 5115291 Get the latest norm_st_date of
--                      the parent term and pass it to create_payment_term_record.
-- 31-OCT-06 acprakas o Bug#4967164. Modified the procedure to create negative terms
--                      only when index payment term type is not 'ATLEAST'.
-- 10-AUG-06 Pikhar   o Codev. Added include_in_var_rent to cur_unq_comb
-- 29-Sep-06 Pseeram  o Modified the cursor cur_uniq_comb and cur_payment_terms
-- 01-NOV-06 pseeram  o Added two cursors ref_period_cur and assessment_date_cur
--                      for term length option.
-- 01-DEC-06 Pseeram  o Removed the two cusrors ref_period_cur and assessment_date_cur
--                      and the term length end_date handling is moved to
--                      procedure derive_term_end_date.
-- 09-JAN-07 lbala    o Removed call to get_schedule_date which checked for schedule
--                      day conflicts for M28 item # 11
-- 02-JAn-07 Hareesha o M28#16 Changes for Recurring backbill.
-- 30-MAR-07 Hareesha o Bug # 5958131 Added handling for new option of backbill+recur.
-- 23-APR-07 Hareesha o Bug 6005637 Removed the check of not to create reversal terms for
--                      ATLEAST terms, ATLEAST terms wud get created for basis-only also,
--                      restricting from creation of reversal terms is causing the above bug.
--                      Hence, removed the restriction.
-- 26-APR-07 Hareesha o Bug#6016064 Add condition to check if start-dt <= end-dt,
--                      createterms,else do not.
-- 12-DEC-07 acprakas  o Bug#6457105. Modified to consider new values for system option incl_terms_by_default_flag.
--------------------------------------------------------------------------------

PROCEDURE create_aggr_payment_terms (
      p_index_lease_id              IN       NUMBER
     ,p_basis_start_date            IN        DATE
     ,p_basis_end_date              IN        DATE
     ,p_index_term_indicator        IN       VARCHAR2
     ,p_lease_id                    IN       NUMBER
     ,p_assessment_date             IN       DATE
     ,p_normalized_amount_annual    IN       NUMBER
     ,p_basis_relationship          IN       VARCHAR2
     ,p_basis_type                  IN       VARCHAR2
     ,p_total_rent_amount           IN       NUMBER
     ,p_increase_on                 IN       VARCHAR2
     ,p_rounding_flag               IN       VARCHAR2
     ,p_index_finder_type           IN       VARCHAR2
     ,p_main_lease_termination_date IN       DATE
     ,p_index_period_id             IN       NUMBER
     ,p_calculate_date              IN       DATE
     ,op_msg                        OUT NOCOPY VARCHAR2
     )
AS

    l_gross_flag                      PN_INDEX_LEASES_ALL.GROSS_FLAG%TYPE;

  CURSOR cur_unq_comb (
            ip_index_lease_id IN NUMBER
           ,ip_basis_start_date IN DATE
           ,ip_basis_end_date IN DATE
           ,ip_type_code IN VARCHAR2
           ,ip_index_term_indicator IN VARCHAR2
           ,ip_org_id IN NUMBER
         )
  IS
  SELECT DISTINCT ppt.location_id
        ,ppt.payment_purpose_code
        ,ppt.payment_term_type_code
        ,ppt.vendor_id
        ,ppt.vendor_site_id
        ,ppt.customer_id
        ,ppt.customer_site_use_id
        ,ppt.frequency_code
        ,ppt.include_in_var_rent
        ,build_distributions_string (ppt.payment_term_id) "DISTRIBUTION_STRING"
        ,NVL (ppt.normalize, 'N') "NORMALIZE"
   FROM  pn_payment_terms_all ppt,
         pn_index_leases_all  pil
   WHERE pil.index_lease_id = ip_index_lease_id
   AND   ppt.lease_id = pil.lease_id
   AND   nvl(ppt.status,'-1') = decode(ppt.index_period_id,null,nvl(ppt.status,'-1'),'APPROVED')
   AND   ppt.end_date >= ip_basis_start_date AND ppt.start_date <= ip_basis_end_date
   AND   ppt.payment_term_type_code = decode(ip_type_code,c_increase_on_gross,
                                             ppt.payment_term_type_code,ip_type_code)
   AND   (
         ppt.payment_term_id  IN (SELECT piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id
         AND piet.include_exclude_flag = 'I')
                               OR
         (
         ppt.payment_term_id NOT IN (select piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id)
         AND ( pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',ip_org_id) = 'Y' OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',ip_org_id) = 'G' and  NVL(pil.gross_flag,'N') = 'Y') OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',ip_org_id) = 'U' and  NVL(pil.gross_flag,'N') = 'N')
	     )
         )
         )
   AND (( p_basis_type = c_basis_type_compound AND
                            not exists( SELECT null
                                        FROM pn_index_lease_periods_all plpx
                                        WHERE plpx.index_period_id = ppt.index_period_id
                                        AND plpx.index_lease_id = p_index_lease_id))
          OR p_basis_type <> c_basis_type_compound)
   AND ppt.frequency_code <> c_spread_frequency_one_time
   AND ppt.currency_code = pil.currency_code

   order by 1,2,3,4,5,6,7,8,9,10,11;

   /* Cursor to get the sum of payment term amounts for a given unique
      aggregation combination */

   CURSOR cur_payment_terms (
            ip_lease_id IN NUMBER
           ,ip_location_id IN NUMBER
           ,ip_payment_purpose_code IN VARCHAR2
           ,ip_payment_term_type_code IN VARCHAR2
           ,ip_vendor_id IN NUMBER
           ,ip_vendor_site_id IN NUMBER
           ,ip_customer_id IN NUMBER
           ,ip_customer_site_use_id IN NUMBER
           ,ip_frequency_code IN VARCHAR2
           ,ip_distribution_string IN VARCHAR2
           ,ip_index_term_indicator IN VARCHAR2
           ,ip_normalize IN VARCHAR2
           ,ip_include_in_var_rent IN VARCHAR2
           ,ip_index_lease_id IN NUMBER    -- Fix for bug# 1950708
           ,ip_basis_start_date IN DATE
           ,ip_basis_end_date IN DATE
           ,ip_org_id IN NUMBER
        ) IS
   SELECT ppt.payment_term_id,nvl(ppt.actual_amount,ppt.estimated_amount)
         ,ppt.frequency_code
         ,ppt.norm_start_date
   FROM pn_payment_terms_all ppt
   WHERE ppt.payment_purpose_code = ip_payment_purpose_code
   AND ppt.payment_term_type_code = ip_payment_term_type_code
   AND nvl(ppt.include_in_var_rent,'N') = nvl(ip_include_in_var_rent,'N')
   AND nvl(ppt.status,'-1') = decode(ppt.index_period_id,null,nvl(ppt.status,'-1'),'APPROVED')
   AND NVL (ppt.normalize, 'N')= ip_normalize
   AND nvl(ppt.location_id,-1) = nvl(ip_location_id,nvl(ppt.location_id,-1))
   AND nvl(ppt.vendor_id,-1) = nvl(ip_vendor_id,nvl(ppt.vendor_id,-1))
   AND nvl(ppt.vendor_site_id,-1) = nvl(ip_vendor_site_id,nvl(ppt.vendor_site_id,-1))
   AND nvl(ppt.customer_id ,-1)= nvl(ip_customer_id,nvl(ppt.customer_id,-1))
   AND nvl(ppt.customer_site_use_id,-1) = nvl(ip_customer_site_use_id,
                                              nvl(ppt.customer_site_use_id,-1))
   AND ppt.frequency_code = ip_frequency_code
   AND ( build_distributions_string (ppt.payment_term_id) = ip_distribution_string
         OR ip_distribution_string IS NULL
        )
   AND   (
         ppt.payment_term_id  IN (SELECT piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id
         AND piet.include_exclude_flag = 'I')
                               OR
         (
         ppt.payment_term_id NOT IN (select piet.payment_term_id
         FROM pn_index_exclude_term_all piet
         WHERE piet.index_lease_id = p_index_lease_id)
         AND ( pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',ip_org_id) = 'Y' OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',ip_org_id) = 'G' and l_gross_flag = 'Y' ) OR
	      (pn_mo_cache_utils.get_profile_value('incl_terms_by_default_flag',ip_org_id) = 'U' and l_gross_flag = 'N' )
	     )
         )
         )
   AND ( ( p_basis_type = c_basis_type_compound AND
                           not exists( SELECT null
                                       FROM pn_index_lease_periods_all plpx
                                       WHERE plpx.index_period_id = ppt.index_period_id
                                       AND plpx.index_lease_id = p_index_lease_id))
                  OR p_basis_type <> c_basis_type_compound)
   AND ppt.end_date >= ip_basis_start_date AND ppt.start_date <= ip_basis_end_date
   AND ppt.FREQUENCY_CODE <> c_spread_frequency_one_time
   AND ppt.lease_id = p_lease_id
   AND ppt.currency_code = g_currency_code;

   CURSOR fetch_generated_il_terms IS
    SELECT payment_term_id,
           actual_amount,
           location_id,
           payment_purpose_code,
           payment_term_type_code,
           vendor_id,
           vendor_site_id,
           customer_id,
           customer_site_use_id,
           frequency_code,
           index_term_indicator,
           start_date,
           normalize,
           schedule_day,
           end_date,
           include_in_var_rent
      FROM pn_payment_terms_all
     WHERE lease_id = p_lease_id
       AND index_period_id = p_index_period_id
       AND status = c_payment_term_status_approved;

   CURSOR cur_period_term_sum_amt (
            ip_lease_id               IN NUMBER
           ,ip_location_id            IN NUMBER
           ,ip_payment_purpose_code   IN VARCHAR2
           ,ip_payment_term_type_code IN VARCHAR2
           ,ip_vendor_id              IN NUMBER
           ,ip_vendor_site_id         IN NUMBER
           ,ip_customer_id            IN NUMBER
           ,ip_customer_site_use_id   IN NUMBER
           ,ip_frequency_code         IN VARCHAR2
           ,ip_distribution_string    IN VARCHAR2
           ,ip_index_term_indicator   IN VARCHAR2
           ,ip_normalize              IN VARCHAR2
           ,ip_index_period_id        IN NUMBER
           ,ip_include_in_var_rent    IN VARCHAR2
         ) IS
   SELECT nvl(ppt.actual_amount,0) actual_amount, ppt.index_term_indicator, ppt.payment_term_id
   FROM pn_payment_terms_all ppt
   WHERE ppt.payment_purpose_code = ip_payment_purpose_code
   AND ppt.payment_term_type_code = ip_payment_term_type_code
   AND ppt.index_period_id = ip_index_period_id
   AND nvl(ppt.status,'-1') = 'APPROVED'
   AND ((ip_index_term_indicator = c_index_pay_term_type_atlst
         AND ppt.index_term_indicator in (c_index_pay_term_type_atlst,c_index_pay_term_type_atlst_bb)) OR
        (ip_index_term_indicator = c_index_pay_term_type_recur
         AND ppt.index_term_indicator in (c_index_pay_term_type_recur,c_index_pay_term_type_backbill))
        )
   AND ((ppt.index_term_indicator = 'ATLEAST'
         AND nvl(ppt.normalize,'N') = ip_normalize) OR
                (ppt.index_term_indicator <> 'ATLEAST'))
   AND nvl(ppt.location_id,-1) = nvl(ip_location_id,nvl(ppt.location_id,-1))
   AND nvl(ppt.vendor_id,-1) = nvl(ip_vendor_id,nvl(ppt.vendor_id,-1))
   AND nvl(ppt.vendor_site_id,-1) = nvl(ip_vendor_site_id,nvl(ppt.vendor_site_id,-1))
   AND nvl(ppt.customer_id ,-1)= nvl(ip_customer_id,nvl(ppt.customer_id,-1))
   AND nvl(ppt.customer_site_use_id,-1) = nvl(ip_customer_site_use_id,
                                              nvl(ppt.customer_site_use_id,-1))
   AND  ((ppt.index_term_indicator in (c_index_pay_term_type_atlst,
                                       c_index_pay_term_type_recur)
         AND ppt.frequency_code = ip_frequency_code) OR
        (ppt.index_term_indicator in (c_index_pay_term_type_atlst_bb,
                                      c_index_pay_term_type_backbill)
         AND ppt.frequency_code = ppt.frequency_code)
         )
   AND (build_distributions_string (ppt.payment_term_id) = ip_distribution_string
        OR ip_distribution_string IS NULL
        )
   AND ppt.currency_code = g_currency_code;

   -- NOTE on the end_date logic:
   -- The recurring terms are created on the next available sch date after SYSDATE.
   -- The backbill term takes into account the gap between the assessment date
   -- and the start date of the recurring term.
   -- Therefore, the start date should be assessment date; the end date should be
   -- => last_day_of(month_of(recurring term start date) - 1).

   CURSOR cur_sum_backbill_overlap_items (
            p_end_date                pn_payment_terms.end_date%TYPE
           ,p_location_id             pn_payment_terms.location_id%TYPE
           ,p_payment_purpose_code    pn_payment_terms.payment_purpose_code%TYPE
           ,p_payment_term_type_code  pn_payment_terms.payment_term_type_code%TYPE
           ,p_vendor_id               pn_payment_terms.vendor_id%TYPE
           ,p_vendor_site_id          pn_payment_terms.vendor_site_id%TYPE
           ,p_customer_id             pn_payment_terms.customer_id%TYPE
           ,p_customer_site_use_id    pn_payment_terms.customer_site_use_id%TYPE
           ,p_distribution_string     VARCHAR2
           ,p_normalize               pn_payment_terms.normalize%TYPE
         ) IS
   SELECT sum(item.actual_amount)  sum_overlap_amt
     FROM pn_payment_items_all         item,
          pn_payment_terms_all     term
    WHERE item.payment_term_id                            = term.payment_term_id
      AND item.due_date BETWEEN p_assessment_date AND p_end_date
      AND term.index_period_id                            = p_index_period_id
      AND term.index_term_indicator                       = p_index_term_indicator
      AND nvl(term.location_id, -1)                       = nvl(p_location_id, -1)
      AND nvl(term.payment_purpose_code, 'N')             = nvl(p_payment_purpose_code, 'N')
      AND nvl(term.payment_term_type_code, 'N')           = nvl(p_payment_term_type_code, 'N')
      AND nvl(term.vendor_id, -1)                         = nvl(p_vendor_id, -1)
      AND nvl(term.vendor_site_id, -1)                    = nvl(p_vendor_site_id, -1)
      AND nvl(term.customer_id, -1)                       = nvl(p_customer_id, -1)
      AND nvl(term.customer_site_use_id, -1)              = nvl(p_customer_site_use_id, -1)
      AND nvl(term.normalize, 'N')                        = p_normalize
      AND build_distributions_string(term.payment_term_id) = p_distribution_string;

   CURSOR org_id_cur IS
      SELECT org_id
      FROM pn_index_leases_all
      WHERE index_lease_id = p_index_lease_id;

  CURSOR gross_flag_cur IS
      SELECT NVL(GROSS_FLAG,'N')
      FROM pn_index_leases_all
      WHERE index_lease_id = p_index_lease_id;

   v_op_sum_amount                   NUMBER := 0;
   v_payment_amount                  NUMBER := 0;
   v_type_code                       VARCHAR2(100);
   v_start_date                      DATE;
   v_num_pymt_since_assmt_dt         NUMBER;
   v_payments_per_year               NUMBER;
   v_total_amt                       NUMBER := 0;
   v_total_backbill_rent_amt         NUMBER := 0;
   v_backbill_amt                    NUMBER := 0;
   v_total_backbill_amt              NUMBER := 0;
   v_previous_backbill_amt           NUMBER := 0;
   v_basis_start_date                pn_index_lease_periods.basis_start_date%type;
   v_basis_end_date                  pn_index_lease_periods.basis_end_date%type;
   v_msg                             VARCHAR2(100);
   prev_payment_purpose_code         pn_payment_terms.payment_purpose_code%type := null;
   prev_payment_term_type_code       pn_payment_terms.payment_term_type_code%type := null;
   prev_location_id                  pn_payment_terms.location_id%type := null;
   prev_vendor_id                    pn_payment_terms.vendor_id%type := null;
   prev_vendor_site_id               pn_payment_terms.vendor_site_id%type := null;
   prev_customer_id                  pn_payment_terms.customer_id%type := null;
   prev_customer_site_use_id         pn_payment_terms.customer_site_use_id%type := null;
   prev_distribution_string          VARCHAR2(2000) := null;
   prev_normalize                    VARCHAR2(10)   := null;
   prev_frequency_code               pn_payment_terms.frequency_code%TYPE;
   prev_end_date                     pn_payment_terms.end_date%TYPE;
   v_overlap_backbill_amt            NUMBER := 0;
   prev_include_in_var_rent          VARCHAR2(30)   := null;
   v_count                           NUMBER := 0;
   v_source_payment_term_id          NUMBER := 0;
   v_prev_payment_term_id            NUMBER := 0;
   curr_location_id                  pn_payment_terms.location_id%type := null;
   curr_payment_purpose_code         pn_payment_terms.payment_purpose_code%type := null;
   curr_frequency_code               pn_payment_terms.frequency_code%type := null;
   --curr_include_in_var_rent          pn_payment_terms.include_in_var_rent%type := null;
   curr_include_in_var_rent          VARCHAR2(30);
   p_normalized                      VARCHAR2(1):='N';
   p_backbill_term_indicator         VARCHAR2(100) := null;
   v_date                            VARCHAR2(100);
   v_approved_amount_annual          NUMBER := 0;
   v_prorated_backbill_amt           NUMBER := 0;
   v_existing_payment_amount         NUMBER := 0;
   v_previous_exist_backbill         NUMBER := 0;
   v_total_exist_backbill            NUMBER := 0;
   v_existing_backbill               NUMBER := 0;
   v_created_payment_term_id         PN_PAYMENT_TERMS.PAYMENT_TERM_ID%TYPE;
   l_frequency                       PN_PAYMENT_TERMS.FREQUENCY_CODE%TYPE;
   l_count                           NUMBER := 0;
   i                                 NUMBER := 0;
   l_amount                          NUMBER := 0;

   TYPE term_rec IS  RECORD (amount NUMBER, type VARCHAR2(30));

   exist_term_rec term_rec;

   TYPE exist_payment    IS TABLE OF exist_term_rec%TYPE INDEX BY BINARY_INTEGER;
   TYPE payment_term_tbl IS TABLE OF pn_payment_terms_all%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE id_tbl           IS TABLE OF pn_payment_terms.payment_term_id%TYPE INDEX BY BINARY_INTEGER;

   exist_term_tab   exist_payment;
   appr_ind_lease_tbl  exist_payment;

   l_check_term_tbl    payment_term_tbl;
   l_impacted_term_tbl payment_term_tbl;
   l_chklist_tbl       id_tbl;
   l_used              BOOLEAN;
   l_nxt_schdate       DATE;
   l_day               pn_payment_terms.schedule_day%TYPE;
   l_org_id            NUMBER;

   l_lst_norm_st_date  DATE;
   l_this_norm_st_date  DATE;


   /* for calculate annualized basis on ENDATE/PERIOD option */
   l_calc_annualized_basis VARCHAR2(30);
   v_end_date                       DATE;
   v_reference_period_type          VARCHAR2(30);

   l_backbill_st_date        DATE;
   l_backbill_end_date       DATE;
   l_backbill_end_date_temp  DATE;
   l_backbill_freq           VARCHAR2(30);
   l_backbill_amt            NUMBER;
   l_recur_bb_calc_date      DATE;
   l_backbill_normalize      VARCHAR2(1);

   CURSOR ref_period_cur ( p_index_lease_id NUMBER) IS
   SELECT reference_period
   FROM pn_index_leases_all
   WHERE index_lease_id = p_index_lease_id;


BEGIN

   put_log ('In create_aggr_payment_terms (+)');

   FOR org_id_rec IN org_id_cur LOOP
     l_org_id := org_id_rec.org_id;
   END LOOP;

    /* to get the reference period_type */
    FOR ref_period_rec IN ref_period_cur(p_index_lease_id) LOOP
            v_reference_period_type := ref_period_rec.reference_period;
    END LOOP;

   l_calc_annualized_basis
     := pn_mo_cache_utils.get_profile_value('PN_CALC_ANNUALIZED_BASIS', l_org_id);

   SELECT NVL (p_increase_on, c_increase_on_gross)
   INTO v_type_code
   FROM  DUAL;

   v_basis_start_date := p_basis_start_date;
   v_basis_end_date   := p_basis_end_date;


   IF p_basis_type = c_basis_type_compound   THEN

      put_log('create_aggr_payment_terms - getting annualized basis');

      sum_payment_items (
            p_index_lease_id              => p_index_lease_id
           ,p_basis_start_date            => v_basis_start_date
           ,p_basis_end_date              => v_basis_end_date
           ,p_type_code                   => v_type_code
           ,p_include_index_items         => 'N'
           ,op_sum_amount                 => v_op_sum_amount );
   ELSE
      put_log('create_aggr_payment_terms - getting basis');

      sum_payment_items (
            p_index_lease_id              => p_index_lease_id
           ,p_basis_start_date            => v_basis_start_date
           ,p_basis_end_date              => v_basis_end_date
           ,p_type_code                   => v_type_code
           ,op_sum_amount                 => v_op_sum_amount );
   END IF;

   l_check_term_tbl.delete;
   l_chklist_tbl.delete;

   FOR cache_cur IN fetch_generated_il_terms LOOP
      l_count := l_check_term_tbl.COUNT;
      l_check_term_tbl(l_count).payment_term_id        := cache_cur.payment_term_id;
      l_check_term_tbl(l_count).frequency_code         := cache_cur.frequency_code;
      l_check_term_tbl(l_count).index_term_indicator   := cache_cur.index_term_indicator;
      l_check_term_tbl(l_count).start_date             := cache_cur.start_date;
      l_check_term_tbl(l_count).actual_amount          := cache_cur.actual_amount;

      l_check_term_tbl(l_count).payment_purpose_code   := cache_cur.payment_purpose_code;
      l_check_term_tbl(l_count).payment_term_type_code := cache_cur.payment_term_type_code;
      l_check_term_tbl(l_count).location_id            := cache_cur.location_id;
      l_check_term_tbl(l_count).vendor_id              := cache_cur.vendor_id;
      l_check_term_tbl(l_count).vendor_site_id         := cache_cur.vendor_site_id;
      l_check_term_tbl(l_count).customer_id            := cache_cur.customer_id;
      l_check_term_tbl(l_count).customer_site_use_id   := cache_cur.customer_site_use_id;
      l_check_term_tbl(l_count).normalize              := cache_cur.normalize;
      l_check_term_tbl(l_count).include_in_var_rent    := cache_cur.include_in_var_rent;
      l_check_term_tbl(l_count).end_date               := cache_cur.end_date;
      l_check_term_tbl(l_count).schedule_day           := cache_cur.schedule_day;

   END LOOP;

   put_log ('create_aggr_payment_terms - basis amt '|| to_char(v_op_sum_amount));

   v_count := 0;

   /* getting unique combination of payment terms for a lease. */

    put_log('create_aggr_payment_terms - getting unique comb.');

    FOR rec_unq_comb IN cur_unq_comb (
                   ip_index_lease_id             => p_index_lease_id
                  ,ip_basis_start_date           => v_basis_start_date
                  ,ip_basis_end_date             => v_basis_end_date
                  ,ip_type_code                  => v_type_code
                  ,ip_index_term_indicator       => p_index_term_indicator
                  ,ip_org_id                     => l_org_id )

    LOOP
       put_log('create_aggr_payment_terms - in unique comb. loop');

       put_log('create_aggr_payment_terms - derive_payment_start_date');

       /* to get the term_end_date */
       derive_term_end_date(ip_index_lease_id               =>  p_index_lease_id
                           ,ip_index_period_id              =>  p_index_period_id
                           ,ip_main_lease_termination_date  =>  p_main_lease_termination_date
                           ,op_term_end_date                =>  v_end_date);

       derive_payment_start_date (
                  p_spread_frequency            => rec_unq_comb.frequency_code
                 ,p_assessment_date             => p_assessment_date
                 ,p_end_date                    => v_end_date
                 ,p_calculate_date              => p_calculate_date
                 ,p_index_lease_id              => p_index_lease_id
                 ,op_recur_pay_start_date       => v_start_date
                 ,op_num_pymt_since_assmt_dt    => v_num_pymt_since_assmt_dt
                 );

       SELECT DECODE (
                  rec_unq_comb.frequency_code
                 ,c_spread_frequency_monthly, 12
                 ,c_spread_frequency_quarterly, 4
                 ,c_spread_frequency_semiannual, 2
                 ,c_spread_frequency_annually, 1
                 ,1 )
       INTO v_payments_per_year
       FROM DUAL;

       IF p_index_finder_type in ( c_index_finder_backbill, c_index_finder_most_recent) AND
          NVL (v_num_pymt_since_assmt_dt, 0) <> 0 THEN

          SELECT decode(p_index_term_indicator,
                        c_index_pay_term_type_atlst,
                        c_index_pay_term_type_atlst_bb,
                        c_index_pay_term_type_recur,
                        c_index_pay_term_type_backbill)
          INTO p_backbill_term_indicator
          FROM DUAL;

       END IF;


       put_log('create_aggr_payment_terms - getting annualized payments');

       /* Get the sum of annualized payments of all the payment terms that belong
          to a given unique aggr. combination */

       /* Initialize the table and the counter variables */

       item_amt_tab.delete;

       l_count := 0;
       v_total_amt := 0;

       OPEN gross_flag_cur;
       FETCH gross_flag_cur INTO l_gross_flag;
       Close gross_flag_cur;

       IF NVL(l_calc_annualized_basis,'PERIOD') = 'PERIOD' THEN
         /* annualized basis calculated for terms active for the IR period */
         OPEN cur_payment_terms ( p_lease_id
                                 ,rec_unq_comb.location_id
                                 ,rec_unq_comb.payment_purpose_code
                                 ,rec_unq_comb.payment_term_type_code
                                 ,rec_unq_comb.vendor_id
                                 ,rec_unq_comb.vendor_site_id
                                 ,rec_unq_comb.customer_id
                                 ,rec_unq_comb.customer_site_use_id
                                 ,rec_unq_comb.frequency_code
                                 ,rec_unq_comb.distribution_string
                                 ,p_index_term_indicator
                                 ,rec_unq_comb.normalize
                                 ,rec_unq_comb.include_in_var_rent
                                 ,p_index_lease_id
                                 ,v_basis_start_date
                                 ,v_basis_end_date
                                 ,l_org_id);

       ELSIF NVL(l_calc_annualized_basis,'PERIOD') = 'ENDDATE' THEN
         /* annualized basis calculated for terms active on period end date */
         OPEN cur_payment_terms ( p_lease_id
                                 ,rec_unq_comb.location_id
                                 ,rec_unq_comb.payment_purpose_code
                                 ,rec_unq_comb.payment_term_type_code
                                 ,rec_unq_comb.vendor_id
                                 ,rec_unq_comb.vendor_site_id
                                 ,rec_unq_comb.customer_id
                                 ,rec_unq_comb.customer_site_use_id
                                 ,rec_unq_comb.frequency_code
                                 ,rec_unq_comb.distribution_string
                                 ,p_index_term_indicator
                                 ,rec_unq_comb.normalize
                                 ,rec_unq_comb.include_in_var_rent
                                 ,p_index_lease_id
                                 ,v_basis_end_date
                                 ,v_basis_end_date
                                 ,l_org_id);
       END IF;

       l_lst_norm_st_date := NULL;
       l_this_norm_st_date := NULL;

       LOOP

          put_log ('create_aggr_payment_terms - in annualized payments loop');
          l_count := l_count + 1;

          FETCH cur_payment_terms INTO
                item_amt_tab(l_count).payment_term_id,
                l_amount,
                l_frequency,
                l_this_norm_st_date;

          EXIT WHEN cur_payment_terms%NOTFOUND;

          IF l_frequency = 'MON' THEN
            item_amt_tab(l_count).amount := l_amount * 12;
          ELSIF l_frequency = 'QTR' THEN
            item_amt_tab(l_count).amount := l_amount * 4;
          ELSIF l_frequency = 'SA' THEN
            item_amt_tab(l_count).amount := l_amount * 2;
          ELSIF l_frequency = 'YR' THEN
            item_amt_tab(l_count).amount := l_amount;
          END IF;

          IF l_lst_norm_st_date IS NULL THEN
            l_lst_norm_st_date := l_this_norm_st_date;
          ELSE
            IF l_this_norm_st_date > l_lst_norm_st_date THEN
              l_lst_norm_st_date := l_this_norm_st_date;
            END IF;
          END IF;

          v_total_amt := v_total_amt + item_amt_tab(l_count).amount;

          /* store the payment_term_id to be used later on in the program
             when creating the new payment term */

          v_source_payment_term_id := item_amt_tab(l_count).payment_term_id;

       END LOOP;

       put_log ('create_aggr_payment_terms - annualized payments amt '|| to_char(v_total_amt));

       close cur_payment_terms;

       put_log ('create_aggr_payment_terms - v_source_payment_term_id'|| to_char(v_source_payment_term_id));
       put_log ('create_aggr_payment_terms - total rent'||to_char(p_total_rent_amount) );

       /* Get the payment contribution for the unique aggr. combination */

       IF v_op_sum_amount <> 0 THEN
          v_payment_amount := ROUND(p_total_rent_amount * (v_total_amt/v_op_sum_amount)
                                   ,get_amount_precision);
       ELSE
          v_payment_amount := 0;
       END IF;

       /* get the amount of the approved payment terms for a
          given period. If p_index_term_indicator is 'ATLEAST'
          then get the amounts for both the 'ATLEAST'and the
          'ATLEAST BACKBILL' in one go and store in a PL/SQL
          table. Similarly, if the p_index_term_indicator in
          'RECUR' then get the amounts for both the 'RECUR' and
           the 'RECUR back Bill' and store it in a PL/SQL table */

       put_log ('create_aggr_payment_terms - delete tab ' );

       i := 0;

       exist_term_tab.delete;
       appr_ind_lease_tbl.delete;

       /* fetch all contributing index lease payment terms */

       FOR sum_amt_cur IN cur_period_term_sum_amt(
                             p_lease_id
                            ,rec_unq_comb.location_id
                            ,rec_unq_comb.payment_purpose_code
                            ,rec_unq_comb.payment_term_type_code
                            ,rec_unq_comb.vendor_id
                            ,rec_unq_comb.vendor_site_id
                            ,rec_unq_comb.customer_id
                            ,rec_unq_comb.customer_site_use_id
                            ,rec_unq_comb.frequency_code
                            ,rec_unq_comb.distribution_string
                            ,p_index_term_indicator
                            ,rec_unq_comb.normalize
                            ,p_index_period_id
                            ,rec_unq_comb.include_in_var_rent) LOOP

          i                                     := appr_ind_lease_tbl.COUNT;
          l_chklist_tbl(l_chklist_tbl.COUNT)    := sum_amt_cur.payment_term_id;
          appr_ind_lease_tbl(i).amount          := sum_amt_cur.actual_amount;
          appr_ind_lease_tbl(i).type            := sum_amt_cur.index_term_indicator;

       END LOOP;

       /* sum the actual amount values based on its type */

       FOR c1 IN 0 .. appr_ind_lease_tbl.COUNT - 1 LOOP
          i := 0;
          FOR c2 IN 1 .. exist_term_tab.COUNT LOOP
             IF exist_term_tab(c2).type = appr_ind_lease_tbl(c1).type THEN
                exist_term_tab(c2).amount := exist_term_tab(c2).amount + appr_ind_lease_tbl(c1).amount;
                i := 1;
                exit;
             END IF;
          END LOOP;

          IF i = 0 THEN
             i                        := exist_term_tab.COUNT + 1;
             exist_term_tab(i).type   := appr_ind_lease_tbl(c1).type;
             exist_term_tab(i).amount := appr_ind_lease_tbl(c1).amount;
          END IF;
       END LOOP;

       /* get the existing terms amount for type of ATLEASE/RECUR */

       v_existing_payment_amount := 0;

       for i in 1 .. exist_term_tab.count
       loop

          if exist_term_tab(i).type in (c_index_pay_term_type_atlst,
                                        c_index_pay_term_type_recur) then

             v_existing_payment_amount := exist_term_tab(i).amount * v_payments_per_year;

             exit;
          end if;
       end loop;

       put_log('create_aggr_payment_terms p_index_term_indicator - '|| p_index_term_indicator);
       put_log ('create_aggr_payment_terms - v_payment_amount ' || to_char(v_payment_amount));
       put_log ('create_aggr_payment_terms - rec_unq_comb.vendor_id ' || to_char(rec_unq_comb.vendor_id));
       put_log ('create_aggr_payment_terms - rec_unq_comb.vendor_site_id ' || to_char(rec_unq_comb.vendor_site_id));
       put_log ('create_aggr_payment_terms - rec_unq_comb.payment_term_type_code ****'|| rec_unq_comb.payment_term_type_code);

       put_log ('create_aggr_payment_terms - existing pay amt ' || to_char(v_existing_payment_amount));

      /* Create atleast/recurring payment terms if main lease termination date > sysdate
         Fix for bug# 2007492 */

       -- NOTE: assumption is payment end date = lease termination date
       IF ((v_payment_amount - v_existing_payment_amount) <> 0) AND
          (v_start_date <= p_main_lease_termination_date) THEN


          p_normalized := NVL(rec_unq_comb.normalize,'N');

          IF v_start_date <= v_end_date  AND
             (( TRUNC(p_main_lease_termination_date) > p_calculate_date AND
               NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') IN ('OT','RECUR') ) OR
              NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'SINGLETERM')
          THEN

          create_payment_term_record (
                p_lease_id               => p_lease_id
               ,p_location_id            => rec_unq_comb.location_id
               ,p_purpose_code           => rec_unq_comb.payment_purpose_code
               ,p_index_period_id        => p_index_period_id
               ,p_term_template_id       => NULL
               ,p_spread_frequency       => rec_unq_comb.frequency_code
               ,p_rounding_flag          => p_rounding_flag
               ,p_payment_amount         => v_payment_amount - v_existing_payment_amount
               ,p_normalized             => p_normalized
               ,p_include_in_var_rent    => rec_unq_comb.include_in_var_rent
               ,p_start_date             => v_start_date
               ,p_index_term_indicator   => p_index_term_indicator
               ,p_payment_term_id        => v_source_payment_term_id
               ,p_basis_relationship     => p_basis_relationship
               ,p_called_from            => 'INDEX'
               ,p_calculate_date         => p_calculate_date
               ,p_norm_st_date           => l_lst_norm_st_date
               ,p_end_date               => v_end_date
               ,op_payment_term_id       => v_created_payment_term_id
               ,op_msg                   => v_msg
               );
          END IF;

          IF NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'RECUR' AND
   	     p_index_finder_type in (c_index_finder_backbill,
                                     c_index_finder_most_recent)
	  THEN
             derive_term_end_date(
                            ip_index_lease_id               =>  p_index_lease_id
                           ,ip_index_period_id              =>  p_index_period_id
                           ,ip_main_lease_termination_date  =>  p_main_lease_termination_date
                           ,op_term_end_date                =>  l_backbill_end_date_temp);

                   l_backbill_st_date   := p_assessment_date ;
                   l_backbill_end_date  := LEAST(v_start_date - 1,l_backbill_end_date_temp);
                   l_backbill_freq      := rec_unq_comb.frequency_code;
                   l_backbill_amt       := v_payment_amount - v_existing_payment_amount;
                   l_recur_bb_calc_date := p_calculate_date;
                   l_backbill_normalize := NVL(rec_unq_comb.normalize,'N');

             IF l_backbill_st_date <= NVL(l_backbill_end_date,TRUNC(SYSDATE)) THEN

                create_payment_term_record (
                         p_lease_id               => p_lease_id
                        ,p_location_id            => rec_unq_comb.location_id
                        ,p_purpose_code           => rec_unq_comb.payment_purpose_code
                        ,p_index_period_id        => p_index_period_id
                        ,p_term_template_id       => NULL
                        ,p_spread_frequency       => l_backbill_freq
                        ,p_rounding_flag          => p_rounding_flag
                        ,p_payment_amount         => l_backbill_amt
                        ,p_normalized             => l_backbill_normalize
                        ,p_include_in_var_rent    => rec_unq_comb.include_in_var_rent
                        ,p_start_date             => l_backbill_st_date
                        ,p_index_term_indicator   => p_backbill_term_indicator
                        ,p_payment_term_id        => v_source_payment_term_id
                        ,p_basis_relationship     => p_basis_relationship
                        ,p_called_from            => 'INDEX'
                        ,p_calculate_date         => p_calculate_date
                        ,p_norm_st_date           => l_lst_norm_st_date
                        ,p_end_date               => l_backbill_end_date
                        ,p_recur_bb_calc_date     => l_recur_bb_calc_date
                        ,op_payment_term_id       => v_created_payment_term_id
                        ,op_msg                   => v_msg );
             END IF;
          END IF;

          /* insert records into intermediate table */
          IF v_created_payment_term_id IS NOT NULL THEN --#@#Bug4291907
          insert_inter_term (
                ip_index_period_id       => p_index_period_id,
                ip_index_term_indicator  => p_index_term_indicator,
                ip_combination_amt       => v_payment_amount,
                ip_total_terms_amt       => v_total_amt,
                ip_rent_increase_term_id => v_created_payment_term_id,
                ip_index_lease_id        => p_index_lease_id);
          END IF; --#@#Bug4291907

       END IF;

       IF v_count = 0  THEN
          prev_payment_purpose_code    := rec_unq_comb.payment_purpose_code;
          prev_payment_term_type_code  := rec_unq_comb.payment_term_type_code;
          prev_location_id             := rec_unq_comb.location_id;
          prev_vendor_id               := rec_unq_comb.vendor_id;
          prev_vendor_site_id          := rec_unq_comb.vendor_site_id;
          prev_include_in_var_rent     := rec_unq_comb.include_in_var_rent;
          prev_customer_id             := rec_unq_comb.customer_id;
          prev_customer_site_use_id    := rec_unq_comb.customer_site_use_id;
          prev_distribution_string     := rec_unq_comb.distribution_string;
          prev_frequency_code          := rec_unq_comb.frequency_code;
          prev_normalize               := p_normalized;
          prev_end_date                := last_day(add_months(v_start_date, -1));

          v_count := 1;
       END IF;

       /* Determine the amounts for the backbill payment terms */

       IF p_index_finder_type in (c_index_finder_backbill,
                                  c_index_finder_most_recent) AND
          NVL (v_num_pymt_since_assmt_dt, 0) <> 0 THEN

          IF NVL(prev_payment_purpose_code,'N')       = NVL(rec_unq_comb.payment_purpose_code,'N')   AND
             NVL(prev_payment_term_type_code,'N')     = NVL(rec_unq_comb.payment_term_type_code,'N') AND
             NVL(prev_location_id,0)                  = NVL(rec_unq_comb.location_id,0)              AND
             NVL(prev_vendor_id,0)                    = NVL(rec_unq_comb.vendor_id,0)                AND
             NVL(prev_vendor_site_id,0)               = NVL(rec_unq_comb.vendor_site_id,0)           AND
             NVL(prev_customer_id,0)                  = NVL(rec_unq_comb.customer_id ,0)             AND
             NVL(prev_customer_site_use_id,0)         = NVL(rec_unq_comb.customer_site_use_id,0)     AND
             prev_distribution_string                 = rec_unq_comb.distribution_string             AND
             NVL(prev_normalize,'N')                  = nvl(p_normalized, 'N')                       AND
             NVL(prev_include_in_var_rent,'N')        = NVL(rec_unq_comb.include_in_var_rent,'N')
          THEN

             v_backbill_amt := ROUND (  (v_payment_amount / v_payments_per_year)
                                         * v_num_pymt_since_assmt_dt
                                      ,get_amount_precision );
             v_total_backbill_amt := v_total_backbill_amt + v_backbill_amt;
             v_prev_payment_term_id := v_source_payment_term_id;

             /* get the existing terms amount for type of ATLEASE/RECUR */

             v_existing_backbill := 0;

             for i in 1 .. exist_term_tab.count
             loop
                if exist_term_tab(i).type in (c_index_pay_term_type_atlst_bb,
                                              c_index_pay_term_type_backbill) then

                   v_existing_backbill := exist_term_tab(i).amount ;
                   exit;
                end if;
             end loop;

             v_total_exist_backbill := v_total_exist_backbill + v_existing_backbill;

          ELSE
             v_previous_backbill_amt := v_total_backbill_amt;
             v_previous_exist_backbill := v_total_exist_backbill;

             v_overlap_backbill_amt := 0; -- reset

             put_log('determining the back bill overlap amount');

             FOR sum_amt_rec IN cur_sum_backbill_overlap_items (
                                   p_end_date               => prev_end_date
                                  ,p_location_id            => prev_location_id
                                  ,p_payment_purpose_code   => prev_payment_purpose_code
                                  ,p_payment_term_type_code => prev_payment_term_type_code
                                  ,p_vendor_id              => prev_vendor_id
                                  ,p_vendor_site_id         => prev_vendor_site_id
                                  ,p_customer_id            => prev_customer_id
                                  ,p_customer_site_use_id   => prev_customer_site_use_id
                                  ,p_distribution_string    => prev_distribution_string
                                  ,p_normalize              => p_normalized)
             LOOP
                v_overlap_backbill_amt := nvl(sum_amt_rec.sum_overlap_amt,0);
             END LOOP;

             put_log('back bill overlap amount: '||v_overlap_backbill_amt);

             if (v_previous_backbill_amt - v_previous_exist_backbill - v_overlap_backbill_amt) <> 0 THEN

                /* Creating the backbill/atleast backbill payment term for the earlier
                   combination */

                IF NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'OT' THEN
                   l_backbill_st_date   := TRUNC(SYSDATE) ;
                   l_backbill_end_date  := NULL;
                   l_backbill_freq      := c_spread_frequency_one_time;
                   l_backbill_amt       := (v_previous_backbill_amt -
                                            v_previous_exist_backbill -
                                            v_overlap_backbill_amt);
                   l_backbill_normalize := 'N';



                  IF l_backbill_st_date <= NVL(l_backbill_end_date,TRUNC(SYSDATE)) THEN

                   create_payment_term_record (
                         p_lease_id               => p_lease_id
                        ,p_location_id            => prev_location_id
                        ,p_purpose_code           => prev_payment_purpose_code
                        ,p_index_period_id        => p_index_period_id
                        ,p_term_template_id       => NULL
                        ,p_spread_frequency       => l_backbill_freq
                        ,p_rounding_flag          => p_rounding_flag
                        ,p_payment_amount         => l_backbill_amt
                        ,p_normalized             => l_backbill_normalize
                        ,p_include_in_var_rent    => prev_include_in_var_rent
                        ,p_start_date             => l_backbill_st_date
                        ,p_index_term_indicator   => p_backbill_term_indicator
                        ,p_payment_term_id        => v_prev_payment_term_id
                        ,p_basis_relationship     => p_basis_relationship
                        ,p_called_from            => 'INDEX'
                        ,p_calculate_date         => p_calculate_date
                        ,p_norm_st_date           => l_lst_norm_st_date
                        ,p_end_date               => l_backbill_end_date
                        ,p_recur_bb_calc_date     => l_recur_bb_calc_date
                        ,op_payment_term_id       => v_created_payment_term_id
                        ,op_msg                   => v_msg );

                  END IF;
                END IF;

                   /* Insert records into the intermediate table , for the backbill amounts */

              IF v_created_payment_term_id IS NOT NULL THEN --#@#Bug4291907
                insert_inter_term (
                         ip_index_period_id => p_index_period_id,
                         ip_index_term_indicator      => p_backbill_term_indicator,
                         ip_combination_amt           => v_payment_amount,
                         ip_total_terms_amt           => v_total_amt,
                         ip_rent_increase_term_id     => v_created_payment_term_id,
                         ip_index_lease_id            => p_index_lease_id);
              END IF; --#@#Bug4291907

             end if;

             v_total_backbill_amt := 0;
             v_backbill_amt :=0;
             v_total_exist_backbill := 0;
             v_backbill_amt := ROUND ((v_payment_amount / v_payments_per_year)
                                       * v_num_pymt_since_assmt_dt
                                        ,get_amount_precision );
             v_existing_backbill := 0;

             v_total_backbill_amt := v_total_backbill_amt + v_backbill_amt;

             /* get the existing terms amount for type of ATLEASE/RECUR */

             for i in 1 .. exist_term_tab.count
             loop
                if exist_term_tab(i).type in (c_index_pay_term_type_atlst_bb,
                                              c_index_pay_term_type_backbill) then

                   v_existing_backbill := exist_term_tab(i).amount ;
                   exit;
                end if;
             end loop;

             v_total_exist_backbill := v_total_exist_backbill + v_existing_backbill;
             v_prev_payment_term_id := v_source_payment_term_id;

             prev_payment_purpose_code    := rec_unq_comb.payment_purpose_code;
             prev_payment_term_type_code  := rec_unq_comb.payment_term_type_code;
             prev_location_id             := rec_unq_comb.location_id;
             prev_vendor_id               := rec_unq_comb.vendor_id;
             prev_vendor_site_id          := rec_unq_comb.vendor_site_id;
             prev_customer_id             := rec_unq_comb.customer_id;
             prev_customer_site_use_id    := rec_unq_comb.customer_site_use_id;
             prev_normalize               := p_normalized;
             prev_include_in_var_rent     := rec_unq_comb.include_in_var_rent;
             prev_distribution_string     := rec_unq_comb.distribution_string;
             prev_end_date                := last_day(add_months(v_start_date, -1));

          END IF; /* Combination comparison suing the prev and current variables */
       END IF;  /* index_finder_backbill */

      -- END IF; /*  p_total_rent_amount > 0 */

       curr_location_id             := rec_unq_comb.location_id;
       curr_payment_purpose_code    := rec_unq_comb.payment_purpose_code;
       curr_frequency_code          := rec_unq_comb.frequency_code;
       curr_include_in_var_rent     := rec_unq_comb.include_in_var_rent;
   END LOOP;

   /* check to see if you need to do the backbill creation for the last combination record */

   IF p_index_finder_type in ( c_index_finder_backbill, c_index_finder_most_recent) AND
      NVL (v_num_pymt_since_assmt_dt, 0) <> 0 THEN

      put_log('determining the back bill overlap amount');

      v_overlap_backbill_amt := 0; -- reset

      FOR sum_amt_rec IN cur_sum_backbill_overlap_items (
                            p_end_date               => prev_end_date
                           ,p_location_id            => prev_location_id
                           ,p_payment_purpose_code   => prev_payment_purpose_code
                           ,p_payment_term_type_code => prev_payment_term_type_code
                           ,p_vendor_id              => prev_vendor_id
                           ,p_vendor_site_id         => prev_vendor_site_id
                           ,p_customer_id            => prev_customer_id
                           ,p_customer_site_use_id   => prev_customer_site_use_id
                           ,p_distribution_string    => prev_distribution_string
                           ,p_normalize              => p_normalized)
      LOOP
         v_overlap_backbill_amt := nvl(sum_amt_rec.sum_overlap_amt,0);
      END LOOP;

      put_log('back bill overlap amount: '||v_overlap_backbill_amt);

      IF (v_total_backbill_amt - v_total_exist_backbill - v_overlap_backbill_amt) <> 0 THEN

         IF NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'OT' THEN
           l_backbill_st_date   := TRUNC(SYSDATE) ;
           l_backbill_end_date  := NULL;
           l_backbill_freq      := c_spread_frequency_one_time;
           l_backbill_amt       := (v_total_backbill_amt - v_total_exist_backbill - v_overlap_backbill_amt);
         /*ELSE

           derive_term_end_date(
                ip_index_lease_id               =>  p_index_lease_id
               ,ip_index_period_id              =>  p_index_period_id
               ,ip_main_lease_termination_date  =>  p_main_lease_termination_date
               ,op_term_end_date                =>  l_backbill_end_date_temp);

            l_backbill_st_date   := p_assessment_date ;
            l_backbill_end_date  := LEAST(v_start_date - 1,l_backbill_end_date_temp);
            l_backbill_freq      := curr_frequency_code;
            l_backbill_amt       := v_payment_amount - v_existing_payment_amount;
            l_recur_bb_calc_date := p_calculate_date;
            l_backbill_normalize := NVL(p_normalized,'N');*/

          /* Create a backbill term for the differnece */

         IF l_backbill_st_date <= NVL(l_backbill_end_date,TRUNC(SYSDATE)) THEN

            create_payment_term_record (
               p_lease_id               => p_lease_id
              ,p_location_id            => curr_location_id
              ,p_purpose_code           => curr_payment_purpose_code
              ,p_index_period_id        => p_index_period_id
              ,p_term_template_id       => NULL
              ,p_spread_frequency       => l_backbill_freq
              ,p_rounding_flag          => p_rounding_flag
              ,p_payment_amount         => l_backbill_amt
              ,p_normalized             => l_backbill_normalize
              ,p_include_in_var_rent    => curr_include_in_var_rent
              ,p_start_date             => l_backbill_st_date
              ,p_index_term_indicator   => p_backbill_term_indicator
              ,p_payment_term_id        => v_source_payment_term_id
              ,p_basis_relationship     => p_basis_relationship
              ,p_called_from            => 'INDEX'
              ,p_calculate_date         => p_calculate_date
              ,p_norm_st_date           => l_lst_norm_st_date
              ,p_end_date               => l_backbill_end_date
              ,p_recur_bb_calc_date     => l_recur_bb_calc_date
              ,op_payment_term_id       => v_created_payment_term_id
              ,op_msg                   => v_msg );

           END IF;
        END IF;

         /* Insert record into the intermediate table */
        IF v_created_payment_term_id IS NOT NULL THEN --#@#Bug4291907
         insert_inter_term (
              ip_index_period_id => p_index_period_id,
              ip_index_term_indicator      => p_backbill_term_indicator,
              ip_combination_amt           => v_payment_amount,
              ip_total_terms_amt           => v_total_amt,
              ip_rent_increase_term_id     => v_created_payment_term_id,
              ip_index_lease_id            => p_index_lease_id);
        END IF ;--#@#Bug4291907


      END IF;

   END IF;

   /* clean up: determine which index rent payment terms hasn't been touched */

   FOR c1 IN 0 .. l_check_term_tbl.COUNT - 1 LOOP
      l_used := FALSE;
      FOR c2 IN 0 .. l_chklist_tbl.COUNT - 1 LOOP
         IF l_chklist_tbl(c2) = l_check_term_tbl(c1).payment_term_id THEN
            l_used := TRUE;
            exit;
         END IF;
      END LOOP;

      IF NOT l_used THEN
         l_check_term_tbl(c1).attribute1 := 'NOTUSED';
      ELSE
         l_check_term_tbl(c1).attribute1 := 'USED';
      END IF;
   END LOOP;

   /* group them together in a new consolidated table, grouped using given criteria */

   l_impacted_term_tbl.delete;

   FOR c1 IN 0 .. l_check_term_tbl.COUNT - 1 LOOP
      IF l_check_term_tbl(c1).attribute1 = 'NOTUSED' THEN
         l_used := FALSE;

         FOR c2 IN 0 .. l_impacted_term_tbl.COUNT - 1 LOOP
           /* if found, add the amount and exit */
           IF
            l_impacted_term_tbl(c2).frequency_code         = l_check_term_tbl(c1).frequency_code AND
            l_impacted_term_tbl(c2).index_term_indicator   = l_check_term_tbl(c1).index_term_indicator AND
            l_impacted_term_tbl(c2).start_date             = l_check_term_tbl(c1).start_date AND
            l_impacted_term_tbl(c2).payment_purpose_code   = l_check_term_tbl(c1).payment_purpose_code AND
            l_impacted_term_tbl(c2).payment_term_type_code = l_check_term_tbl(c1).payment_term_type_code AND
            ((l_impacted_term_tbl(c2).location_id          = l_check_term_tbl(c1).location_id) OR
             (l_impacted_term_tbl(c2).location_id IS NULL AND l_check_term_tbl(c1).location_id IS NULL)) AND
            ((l_impacted_term_tbl(c2).vendor_id            = l_check_term_tbl(c1).vendor_id) OR
             (l_impacted_term_tbl(c2).vendor_id IS NULL AND l_check_term_tbl(c1).vendor_id IS NULL)) AND
            ((l_impacted_term_tbl(c2).vendor_site_id       = l_check_term_tbl(c1).vendor_site_id) OR
             (l_impacted_term_tbl(c2).vendor_site_id IS NULL AND l_check_term_tbl(c1).vendor_site_id IS NULL)) AND
            ((l_impacted_term_tbl(c2).customer_id          = l_check_term_tbl(c1).customer_id) OR
             (l_impacted_term_tbl(c2).customer_id IS NULL AND l_check_term_tbl(c1).customer_id IS NULL)) AND
            ((l_impacted_term_tbl(c2).customer_site_use_id = l_check_term_tbl(c1).customer_site_use_id) OR
             (l_impacted_term_tbl(c2).customer_site_use_id IS NULL AND l_check_term_tbl(c1).customer_site_use_id IS NULL)) AND
            ((l_impacted_term_tbl(c2).include_in_var_rent            = l_check_term_tbl(c1).include_in_var_rent) OR
             (l_impacted_term_tbl(c2).include_in_var_rent IS NULL AND l_check_term_tbl(c1).include_in_var_rent IS NULL)) AND
            ((l_impacted_term_tbl(c2).normalize            = l_check_term_tbl(c1).normalize) OR
             (l_impacted_term_tbl(c2).normalize IS NULL AND l_check_term_tbl(c1).normalize IS NULL)) AND
            build_distributions_string(l_impacted_term_tbl(c2).payment_term_id) =
            build_distributions_string(l_check_term_tbl(c1).payment_term_id)
          THEN
              l_impacted_term_tbl(c2).actual_amount := l_impacted_term_tbl(c2).actual_amount +
                                                       l_check_term_tbl(c1).actual_amount;
              l_used := TRUE;
              exit;
          END IF;
         END LOOP;

         IF NOT l_used THEN
            /* add to the table */
            l_count := l_impacted_term_tbl.COUNT;

            l_impacted_term_tbl(l_count).payment_term_id        := l_check_term_tbl(c1).payment_term_id;
            l_impacted_term_tbl(l_count).frequency_code         := l_check_term_tbl(c1).frequency_code;
            l_impacted_term_tbl(l_count).index_term_indicator   := l_check_term_tbl(c1).index_term_indicator;
            l_impacted_term_tbl(l_count).actual_amount          := l_check_term_tbl(c1).actual_amount;
            l_impacted_term_tbl(l_count).payment_purpose_code   := l_check_term_tbl(c1).payment_purpose_code;
            l_impacted_term_tbl(l_count).payment_term_type_code := l_check_term_tbl(c1).payment_term_type_code;
            l_impacted_term_tbl(l_count).location_id            := l_check_term_tbl(c1).location_id;
            l_impacted_term_tbl(l_count).vendor_id              := l_check_term_tbl(c1).vendor_id;
            l_impacted_term_tbl(l_count).vendor_site_id         := l_check_term_tbl(c1).vendor_site_id;
            l_impacted_term_tbl(l_count).customer_id            := l_check_term_tbl(c1).customer_id;
            l_impacted_term_tbl(l_count).customer_site_use_id   := l_check_term_tbl(c1).customer_site_use_id;
            l_impacted_term_tbl(l_count).normalize              := l_check_term_tbl(c1).normalize;
            l_impacted_term_tbl(l_count).include_in_var_rent    := l_check_term_tbl(c1).include_in_var_rent;
            l_impacted_term_tbl(l_count).start_date             := l_check_term_tbl(c1).start_date;
            l_impacted_term_tbl(l_count).end_date               := l_check_term_tbl(c1).end_date;
            l_impacted_term_tbl(l_count).schedule_day           := l_check_term_tbl(c1).schedule_day;

         END IF;
      END IF;
   END LOOP;

   /* consolidate amounts and create payment terms to negate the lefovers */

   FOR c1 IN 0 .. l_impacted_term_tbl.COUNT - 1 LOOP

      IF l_impacted_term_tbl(c1).actual_amount <> 0 THEN

         IF l_impacted_term_tbl(c1).frequency_code = 'MON' THEN
           l_impacted_term_tbl(c1).actual_amount := 12 * l_impacted_term_tbl(c1).actual_amount;
         ELSIF l_impacted_term_tbl(c1).frequency_code = 'QTR' THEN
           l_impacted_term_tbl(c1).actual_amount :=  4 * l_impacted_term_tbl(c1).actual_amount;
         ELSIF l_impacted_term_tbl(c1).frequency_code = 'SA' THEN
           l_impacted_term_tbl(c1).actual_amount :=  2 * l_impacted_term_tbl(c1).actual_amount;
         END IF;

         create_payment_term_record (
            p_lease_id               => p_lease_id
           ,p_location_id            => l_impacted_term_tbl(c1).location_id
           ,p_purpose_code           => l_impacted_term_tbl(c1).payment_purpose_code
           ,p_index_period_id        => p_index_period_id
           ,p_term_template_id       => NULL
           ,p_spread_frequency       => l_impacted_term_tbl(c1).frequency_code
           ,p_rounding_flag          => p_rounding_flag
           ,p_payment_amount         => l_impacted_term_tbl(c1).actual_amount * -1
           ,p_normalized             => l_impacted_term_tbl(c1).normalize
           ,p_include_in_var_rent    => l_impacted_term_tbl(c1).include_in_var_rent
           ,p_start_date             => l_impacted_term_tbl(c1).start_date
           ,p_index_term_indicator   => l_impacted_term_tbl(c1).index_term_indicator
           ,p_payment_term_id        => l_impacted_term_tbl(c1).payment_term_id
           ,p_basis_relationship     => p_basis_relationship
           ,p_called_from            => 'NEGRENT'
           ,p_calculate_date         => p_calculate_date
           ,p_norm_st_date           => l_lst_norm_st_date
           ,p_end_date               => NULL
           ,op_payment_term_id       => v_created_payment_term_id
           ,op_msg                   => v_msg );

       IF v_created_payment_term_id IS NOT NULL THEN --#@#Bug4291907
         insert_inter_term (
           ip_index_period_id           => p_index_period_id,
           ip_index_term_indicator      => l_impacted_term_tbl(c1).index_term_indicator,
           ip_combination_amt           => l_impacted_term_tbl(c1).actual_amount,
           ip_total_terms_amt           => l_impacted_term_tbl(c1).actual_amount,
           ip_rent_increase_term_id     => v_created_payment_term_id,
           ip_index_lease_id            => p_index_lease_id);
        END IF; --#@#Bug4291907

                 put_log(' approving payment term ID: '||v_created_payment_term_id);

                 approve_index_pay_term (
                     ip_lease_id            => p_lease_id
                    ,ip_index_pay_term_id   => v_created_payment_term_id
                    ,op_msg                 => v_msg);

      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      PUT_LOG('Error in pn_index_amount_pkg.create_aggr_payment_terms :'||to_char(sqlcode)||' : '||sqlerrm);
      RAISE;

END create_aggr_payment_terms;

------------------------------------------------------------------------
-- PROCEDURE   : get_backbill_overlap_amt
-- DESCRIPTION : Gets overlap amount from recurring term given 1) a start
--               2) an end date 3) term template id and 4) index period id
-- HISTORY:
-- 14-APR-05 ftanudja o Created. #4307736.
-- 12-JUL-2005   Mrinal Misra   o Added NOCOPY with OUT parameter.
------------------------------------------------------------------------

PROCEDURE get_backbill_overlap_amt(
            p_term_template_id     pn_payment_terms.term_template_id%TYPE,
            p_index_period_id      pn_payment_terms.index_period_id%TYPE,
            p_index_term_indicator pn_payment_terms.index_term_indicator%TYPE,
            p_start_date           pn_payment_terms.start_date%TYPE,
            p_end_date             pn_payment_terms.end_date%TYPE,
            p_overlap_amt          OUT NOCOPY NUMBER)
IS
  CURSOR get_overlap_sum IS
   SELECT sum(item.actual_amount) sum_overlap_amt
     FROM pn_payment_items_all item,
          pn_payment_terms_all term
    WHERE item.payment_term_id = term.payment_term_id
      AND term.term_template_id = p_term_template_id
      AND term.index_period_id  = p_index_period_id
      AND term.index_term_indicator = p_index_term_indicator
      AND item.due_date BETWEEN p_start_date AND p_end_date;

  l_answer NUMBER;

BEGIN

   put_log('pn_index_amount_pkg.get_backbill_overlap_amt:  (+) ');

   l_answer := 0;

   FOR ans_rec IN get_overlap_sum LOOP
      l_answer := nvl(ans_rec.sum_overlap_amt,0);
   END LOOP;

   p_overlap_amt := l_answer;

   put_log('pn_index_amount_pkg.get_backbill_overlap_amt:  (-) : '||l_answer);

END get_backbill_overlap_amt;

   ------------------------------------------------------------------------
   -- PROCEDURE : create_payment_terms
   -- DESCRIPTION: This procedure will create payment terms for a particular index
   --              period id.
   -- HISTORY:
   -- 06-MAY-02 psidhu   o Added parameter p_negative_rent_type. Fix for bug# 2356045.
   -- 31-OCT-02 ahhkumar o BUG#2593961  pass the parmeter p_include_index_items ='N'
   --                      in sum_payment_items where p_basis_type = c_basis_type_compound
   -- 08-OCT-04 stripath o Modified for BUG# 3961117, added new parameter p_calculate_date
   --                      for not to create backbills if Assessment Date <= CutOff Date.
   -- 01-DEC-04 ftanudja o Before calling create_payment_term_record, check if
   --                      start date < lease termination date. Reference #3964221.
   -- 14-APR-05 ftanudja o Add call to get_backbill_overlap_amt() and logic to
   --                      take into account recurring term amount overlapping
   --                      with backbill. #4307736
   -- 01-NOV-06 prabhakar o Added two cursors ref_period_cur and assessment_date_cur
   --                         for term length option.
   -- 01-DEC-06 Prabhakar o Removed the two cusrors ref_period_cur and assessment_date_cur
   --                         and the term length end_date handling is moved to
   --                         procedure derive_term_end_date.
   -- 11-DEC-06 Prabhakar o Moved the call to derive_term_end_date before the normailzed
   --                         if condition for the bug fix #5704914
   -- 12-DEC-06 Prabhakr  o Added p_prorate_factor parameter.
   -- 02-JAN-07 Hareesha  o M28#16 Changes fro recurring backbill.
   -- 30-MAR-07 Hareesha o Bug # 5958131 Added handling for new option of backbill+recur.
   -- 26-APR-07 Hareesha o Bug # 6016064 Added a check if st-dt <= end-dt,
   --                      create terms else do not.
   ------------------------------------------------------------------------
      PROCEDURE create_payment_terms (
         p_lease_id               IN       NUMBER
        ,p_index_lease_id         IN       NUMBER
        ,p_location_id            IN       NUMBER
        ,p_purpose_code           IN       VARCHAR2
        ,p_index_period_id        IN       NUMBER
        ,p_term_template_id       IN       NUMBER
        ,p_relationship           IN       VARCHAR2
        ,p_assessment_date        IN       DATE
        ,p_basis_amount           IN       NUMBER
        ,p_basis_percent_change   IN       NUMBER
        ,p_spread_frequency       IN       VARCHAR2
        ,p_rounding_flag          IN       VARCHAR2
        ,p_index_amount           IN       NUMBER
        ,p_index_finder_type      IN       VARCHAR2
        ,p_basis_type             IN       VARCHAR2
        ,p_basis_start_date       IN       DATE
        ,p_basis_end_date         IN       DATE
        ,p_increase_on            IN       VARCHAR2
        ,p_negative_rent_type     IN       VARCHAR2
        ,p_carry_forward_flag     IN       VARCHAR2
        ,p_calculate_date         IN       DATE
        ,p_prorate_factor         IN       NUMBER
        ,op_msg                   OUT NOCOPY      VARCHAR2
      ) IS
         v_msg                            VARCHAR2 (1000);
         v_normalize                      pn_term_templates.normalize%TYPE;
         v_index_amount                   pn_index_lease_periods.constraint_rent_due%TYPE;
         v_uncontrained_index_amount      NUMBER;
         v_constrained_rent_amount        NUMBER := 0;
         v_normalized_amount_annual       NUMBER;
         v_adjusted_amount                NUMBER;
         v_num_pymt_since_assmt_dt        NUMBER;
         v_payments_per_year              NUMBER;
         v_backbill_amt                   NUMBER;
         v_backbill_overlap_amt           NUMBER;
         v_backbill_chk_str_dt            DATE;
         v_backbill_chk_end_dt            DATE;
         v_recurring_payment_start_date   DATE;
         v_normalize_basis_amount         NUMBER;
         v_basis_amount                   NUMBER;
         v_annual_basis_amount            NUMBER;
         v_existing_amounts               pn_payment_terms.actual_amount%TYPE;
         v_prev_index_amt                 NUMBER;
         v_adjusted_amount_aggr           NUMBER;
         v_atleast_indicator              VARCHAR2(1):= 'N';
         v_prv_normalized_amount          NUMBER := 0;
         v_main_lease_termination_date    DATE;
         v_approved_amt_annual_atlst_bb   NUMBER := 0;
         v_approved_amt_annual_bb         NUMBER := 0;
         v_num_years                      NUMBER;
         v_constrained_backbill_amt       NUMBER := 0;
         v_ot_amount                      NUMBER := 0;
         v_created_payment_term_id        NUMBER;
         v_constraint_applied_amount      pn_index_lease_periods.constraint_applied_amount%type;
         v_carry_forward_amount           pn_index_lease_periods.carry_forward_amount%type;
         v_constraint_applied_percent     pn_index_lease_periods.constraint_applied_percent%type;
         v_carry_forward_percent          pn_index_lease_periods.carry_forward_percent%type;
         v_end_date                       DATE;
         v_reference_period_type          VARCHAR2(30);

         CURSOR ref_period_cur ( p_index_lease_id NUMBER) IS
         SELECT reference_period
         FROM pn_index_leases_all
         WHERE index_lease_id = p_index_lease_id;

         l_backbill_st_date        DATE;
         l_backbill_end_date       DATE;
         l_backbill_end_date_temp  DATE;
         l_backbill_freq           VARCHAR2(30);
         l_backbill_amt            NUMBER;
         l_recur_bb_calc_date      DATE;
         l_backbill_normalize      VARCHAR2(1);
         l_found_atlst_bb          NUMBER := 0;

BEGIN
   put_log('pn_index_amount_pkg.create_payment_terms   :  (+) ');

   v_index_amount := p_index_amount;


  /* sets date for payment terms that will have todays date.*/

   SELECT pld.lease_termination_date
   INTO v_main_lease_termination_date
   FROM pn_lease_details_all pld
   WHERE pld.lease_id = p_lease_id;

   IF g_create_terms_ext_period = 'Y' THEN
      SELECT NVL(pld.lease_extension_end_date,pld.lease_termination_date)
      INTO v_main_lease_termination_date
      FROM pn_lease_details_all pld
      WHERE pld.lease_id = p_lease_id;
   END IF;

   /* derive payment defaults for this index lease */

   BEGIN

      put_log ('Checking if normalizing...');

      IF p_term_template_id IS NOT NULL THEN
         SELECT normalize
         INTO v_normalize
         FROM pn_term_templates_all
         WHERE term_template_id = p_term_template_id;
      ELSE
        /* if p_term_template_id is null, then payment term aggregation will be done */
         v_normalize := 'Y';
      END IF;

   EXCEPTION
   WHEN OTHERS THEN
       put_log (   'Cannot Get Payment Term Defaults - Unknown Error:'
                || SQLERRM);
   END;

   /* to get the reference period_type */
    FOR ref_period_rec IN ref_period_cur(p_index_lease_id) LOOP
            v_reference_period_type := ref_period_rec.reference_period;
    END LOOP;

   /* check if index rent period already has a normalized amount.*/

   chk_normalized_amount (
           p_index_period_id             => p_index_period_id
          ,op_normalize_amount_annual    => v_normalized_amount_annual
          ,op_msg                        => v_msg
        );


  /* create a normalized payment term, if no normalized record is found
     and 'Normalize' flag is set to 'Y'and relation is 'Greater Of' or 'Basis Only'


     jreyes 22-AUG-01 - added clause "p_assessment_date > sysdate" to IF statement

     IF v_normalized_amount_annual = 0
     AND NVL (v_normalize, 'N') = 'Y'
     AND p_relationship IN (c_relation_greater_of, c_relation_basis_only) THEN


     Calculate index amount to normalize.Do this by calculating the index amount as
     if using basis only If no basis amount is provided, calculate index amount as
     the annualized basis of the current period +  sum of previous index increases */

    /* to get the term end date */
    derive_term_end_date(ip_index_lease_id               =>  p_index_lease_id
                        ,ip_index_period_id              =>  p_index_period_id
                        ,ip_main_lease_termination_date  =>  v_main_lease_termination_date
                        ,op_term_end_date                =>  v_end_date);


   IF NVL (v_normalize, 'N') = 'Y' AND
      p_relationship IN (c_relation_greater_of, c_relation_basis_only) THEN

      IF p_basis_amount IS NULL THEN

         BEGIN

            IF p_basis_type = c_basis_type_compound THEN

               sum_payment_items (
                        p_index_lease_id              => p_index_lease_id
                       ,p_basis_start_date            => p_basis_start_date
                       ,p_basis_end_date              => p_basis_end_date
                       ,p_type_code                   => p_increase_on
                       ,p_include_index_items         => 'N'               --Added for BUG#2593961
                       ,op_sum_amount                 => v_annual_basis_amount
                                       );

               derive_sum_prev_actual_amounts (
                        p_lease_id                    => p_lease_id
                       ,p_index_lease_id              => p_index_lease_id
                       ,p_index_period_id             => p_index_period_id
                       ,p_prev_index_amount           => v_prev_index_amt
                                      );

               v_normalize_basis_amount := v_annual_basis_amount +
                                           NVL (v_prev_index_amt, 0);
            ELSE
               SELECT current_basis
               INTO v_normalize_basis_amount
               FROM pn_index_lease_periods_all pilp
               WHERE pilp.index_lease_id = p_index_lease_id
               AND line_number = 1;
            END IF;

         EXCEPTION
         WHEN OTHERS THEN
              v_normalize_basis_amount := 0;
         END;

      ELSE
         v_normalize_basis_amount := p_basis_amount;
      END IF;  -- p_basis_amount IS NULL


      /* calculate the amount of the the at least amount.. */

      calculate_index_amount (
           p_relationship                => c_relation_basis_only
          ,p_adj_index_percent_change    => NULL
          ,p_basis_percent_change        => p_basis_percent_change
          ,p_current_basis               => v_normalize_basis_amount
          ,op_index_amount               => v_uncontrained_index_amount
          ,op_msg                        => v_msg
                                  );

      /* Applying constraints to the at least amount */

      IF v_uncontrained_index_amount IS NOT NULL THEN

         derive_constrained_rent (
                    p_index_lease_id              => p_index_lease_id
                   ,p_current_basis               => p_basis_amount
                   ,p_index_period_id             => p_index_period_id
                   ,p_assessment_date             => p_assessment_date
                   ,p_negative_rent_type          => p_negative_rent_type
                   ,p_unconstrained_rent_amount   => v_uncontrained_index_amount
                   ,p_carry_forward_flag          => nvl(p_carry_forward_flag,'N')
                   ,p_prorate_factor              => p_prorate_factor
                   ,op_constrained_rent_amount    => v_constrained_rent_amount
                   ,op_constraint_applied_amount  => v_constraint_applied_amount
                   ,op_constraint_applied_percent => v_constraint_applied_percent
                   ,op_carry_forward_amount       => v_carry_forward_amount
                   ,op_carry_forward_percent      => v_carry_forward_percent
                   ,op_msg                        => v_msg
                                        );

      END IF; --v_uncontrained_index_amount IS NOT NULL


      /* Changed the logic so that the ATLEAST amount is always checked for the correct
         amount and not only when the atleast amount = 0 */

      IF (v_constrained_rent_amount - v_normalized_amount_annual) >= 0  and
         p_term_template_id IS NOT NULL THEN

         /* non aggregation ... */

         /* determine the start date */

         derive_payment_start_date (
               p_spread_frequency            => p_spread_frequency
              ,p_assessment_date             => p_assessment_date
              ,p_end_date                    => v_end_date
              ,p_calculate_date              => p_calculate_date
              ,p_index_lease_id               =>  p_index_lease_id
              ,op_recur_pay_start_date       => v_recurring_payment_start_date
              ,op_num_pymt_since_assmt_dt    => v_num_pymt_since_assmt_dt
              );
         /* Fix for bug# 1988909 */

         IF   p_spread_frequency = c_spread_frequency_one_time THEN

            v_num_years := CEIL (MONTHS_BETWEEN (v_main_lease_termination_date,
                                                 v_recurring_payment_start_date)) / 12;
            v_constrained_backbill_amt := v_constrained_rent_amount;
            v_constrained_rent_amount := v_constrained_rent_amount * v_num_years;

         END IF;


         /* create a record on pn_payment_terms table if main lease termination
            date > sysdate.
            Fix for bug# 2007492 */

       IF TRUNC(v_main_lease_termination_date) > p_calculate_date AND
            v_recurring_payment_start_date <= v_main_lease_termination_date AND
            v_recurring_payment_start_date <= v_end_date  THEN

            create_payment_term_record (
                       p_lease_id                    => p_lease_id
                      ,p_location_id                 => p_location_id
                      ,p_purpose_code                => p_purpose_code
                      ,p_index_period_id             => p_index_period_id
                      ,p_term_template_id            => p_term_template_id
                      ,p_spread_frequency            => p_spread_frequency
                      ,p_rounding_flag               => p_rounding_flag
                      ,p_start_date                  => v_recurring_payment_start_date
                      ,p_payment_amount              => v_constrained_rent_amount
                      ,p_normalized                  => 'Y'
                      ,p_index_term_indicator        => c_index_pay_term_type_atlst
                      ,p_payment_term_id             => NULL
                      ,p_basis_relationship          => p_relationship
                      ,p_called_from                 => 'INDEX'
                      ,p_end_date                    => v_end_date
                      ,op_payment_term_id            => v_created_payment_term_id
                      ,p_calculate_date              => p_calculate_date
                      ,op_msg                        => v_msg
                                             );
         END IF;


         /* Determine if we need to calculate a normalized backbill amount */

         IF p_index_finder_type in ( c_index_finder_backbill, c_index_finder_most_recent) AND
            NVL(v_num_pymt_since_assmt_dt, 0) <> 0 THEN
            /* Derive Backbill Amount:
               Count number of payments between sysdate and assessment date
               (SQL: (months_between (assessment_date, sysdate) + 1 )invoiced per year,
               Calculate the backbill amount (monthly amount X no. of months between
               sysdate and assessment date) */

            SELECT DECODE (
                p_spread_frequency
               ,c_spread_frequency_monthly, 12
               ,c_spread_frequency_quarterly, 4
               ,c_spread_frequency_semiannual, 2
               ,c_spread_frequency_annually, 1
               ,1
              )
            INTO v_payments_per_year
            FROM DUAL;

            chk_approved_amount (
                 p_index_period_id             => p_index_period_id
                ,p_index_term_indicator        => c_index_pay_term_type_atlst_bb
                ,op_approved_amount_annual     => v_approved_amt_annual_atlst_bb
                ,op_msg                        => v_msg );

            /* Fix for bug# 1988909 */

            IF p_spread_frequency = c_spread_frequency_one_time AND
               NVL(v_constrained_rent_amount,0) <>0  THEN

               v_num_years := CEIL (MONTHS_BETWEEN (v_recurring_payment_start_date,
                                                    p_assessment_date)) / 12;
               v_backbill_amt := ROUND(v_constrained_backbill_amt * v_num_years,
                                                        get_amount_precision);
            ELSE
               v_backbill_amt := ROUND (
                                        (v_constrained_rent_amount / v_payments_per_year)
                                         * v_num_pymt_since_assmt_dt
                                       ,get_amount_precision
                                       );
            END IF;

            put_log('create_payment_Terms :v_approved_amt_annual_atlst_bb *******'||v_approved_amt_annual_atlst_bb);

            v_backbill_overlap_amt := 0;
            v_backbill_chk_str_dt  := p_assessment_date;
            v_backbill_chk_end_dt  := last_day(add_months(v_recurring_payment_start_date, -1));

            get_backbill_overlap_amt(
               p_term_template_id     => p_term_template_id,
               p_index_period_id      => p_index_period_id,
               p_index_term_indicator => c_index_pay_term_type_atlst,
               p_start_date           => v_backbill_chk_str_dt,
               p_end_date             => v_backbill_chk_end_dt,
               p_overlap_amt          => v_backbill_overlap_amt);

            v_backbill_amt := v_backbill_amt - v_approved_amt_annual_atlst_bb - v_backbill_overlap_amt;

            IF v_backbill_amt <> 0 THEN

               IF NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'OT' THEN
                   l_backbill_st_date   := TRUNC(SYSDATE) ;
                   l_backbill_end_date  := NULL;
                   l_backbill_freq      := c_spread_frequency_one_time;
                   l_backbill_amt       := v_backbill_amt;
                ELSIF NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'RECUR' THEN

                   derive_term_end_date(
                         ip_index_lease_id               =>  p_index_lease_id
                        ,ip_index_period_id              =>  p_index_period_id
                        ,ip_main_lease_termination_date  =>  v_main_lease_termination_date
                        ,op_term_end_date                =>  l_backbill_end_date_temp);

                   l_backbill_st_date   := p_assessment_date ;
                   l_backbill_end_date  := LEAST(v_recurring_payment_start_date - 1,l_backbill_end_date_temp);
                   l_backbill_freq      := p_spread_frequency;
                   l_backbill_amt       := v_constrained_rent_amount;
                   l_recur_bb_calc_date := p_calculate_date;

                END IF;

                IF l_backbill_st_date <= NVL(l_backbill_end_date,TRUNC(SYSDATE)) THEN

                   create_payment_term_record (
                      p_lease_id                    => p_lease_id
                     ,p_location_id                 => p_location_id
                     ,p_purpose_code                => p_purpose_code
                     ,p_index_period_id             => p_index_period_id
                     ,p_term_template_id            => p_term_template_id
                     ,p_spread_frequency            => l_backbill_freq
                     ,p_rounding_flag               => p_rounding_flag
                     ,p_payment_amount              => l_backbill_amt
                     ,p_start_date                  => l_backbill_st_date
                     ,p_normalized                  => 'Y' --6/8/2001change from 'BACKBILL' to 'ATLEAST'
                     ,p_index_term_indicator        => c_index_pay_term_type_atlst_bb
                     ,p_payment_term_id             => NULL
                     ,p_basis_relationship          => p_relationship
                     ,p_called_from                 => 'INDEX'
                     ,p_calculate_date              => p_calculate_date
                     ,p_end_date                    => l_backbill_end_date
                     ,p_recur_bb_calc_date          => l_recur_bb_calc_date
                     ,op_payment_term_id            => v_created_payment_term_id
                     ,op_msg                        => v_msg);

                END IF;

             END IF;
          END IF;

        ELSE
                  /* aggregation */

                   create_aggr_payment_terms (
                        p_index_lease_id            => p_index_lease_id
                       ,p_basis_start_date          => p_basis_start_date
                       ,p_basis_end_date            => p_basis_end_date
                       ,p_index_term_indicator      => c_index_pay_term_type_atlst
                       ,p_lease_id                  => p_lease_id
                       ,p_assessment_date           => p_assessment_date
                       ,p_normalized_amount_annual  => v_normalized_amount_annual
                       ,p_basis_relationship        => p_relationship
                       ,p_basis_type                => p_basis_type
                       ,p_total_rent_amount         => v_constrained_rent_amount
                       ,p_increase_on               => p_increase_on
                       ,p_rounding_flag             => p_rounding_flag
                       ,p_main_lease_termination_date => v_main_lease_termination_date
                       ,p_index_finder_type         => p_index_finder_type
                       ,p_index_period_id           => p_index_period_id
                       ,p_calculate_date            => p_calculate_date
                       ,op_msg                      => v_msg
                       );

        END IF; -- p_index_finder_type in(c_index_finder_backbill ...

   END IF; --  NVL(v_normalize,'N') = 'Y'



   /* create recurring payments */


   IF v_index_amount IS NOT NULL THEN

      /* Check if we have normalized amount.  If so, get the amount normalized,
         this amount must be subtracted from the calculated index amount */


      chk_normalized_amount (
              p_index_period_id             => p_index_period_id
             ,op_normalize_amount_annual    => v_normalized_amount_annual
             ,op_msg                        => v_msg
                                );

      IF v_normalized_amount_annual = 0 THEN
         SELECT count(*)
         INTO l_found_atlst_bb
         FROM pn_payment_terms_all
         WHERE index_period_id = p_index_period_id
         AND index_term_indicator = c_index_pay_term_type_atlst_bb;
      END IF;

      IF TRUNC(v_main_lease_termination_date) <= p_calculate_date OR
         l_found_atlst_bb <> 0  THEN

         IF NVL(p_rounding_flag,'N') = 'Y' THEN
            v_ot_amount :=   ROUND( v_constrained_rent_amount ,0);
         ELSE
            v_ot_amount :=   ROUND( v_constrained_rent_amount , get_amount_precision);
         END IF;

         v_normalized_amount_annual := v_normalized_amount_annual + v_ot_amount;

      END IF;


      /* checking to see if there any recurring payments that have been approved..
         if so, subtract that amount from the current index amount. */

      chk_approved_amount (
          p_index_period_id             => p_index_period_id
         ,p_index_term_indicator        => c_index_pay_term_type_recur
         ,op_approved_amount_annual     => v_existing_amounts
         ,op_msg                        => v_msg );


      IF p_term_template_id IS NOT NULL    THEN   -- non aggregation

         SELECT DECODE (
                  p_spread_frequency
                 ,c_spread_frequency_monthly, 12
                 ,c_spread_frequency_quarterly, 4
                 ,c_spread_frequency_semiannual, 2
                 ,c_spread_frequency_annually, 1
                 ,1
               )
         INTO v_payments_per_year
         FROM DUAL;


         /* deriving the start date of the recurring payment */

         derive_payment_start_date (
               p_spread_frequency            => p_spread_frequency
              ,p_assessment_date             => p_assessment_date
              ,p_end_date                    => v_end_date
              ,p_calculate_date              => p_calculate_date
              ,p_index_lease_id               =>  p_index_lease_id
              ,op_recur_pay_start_date       => v_recurring_payment_start_date
              ,op_num_pymt_since_assmt_dt    => v_num_pymt_since_assmt_dt
              );

         /* Fix for bug# 1988909  */

         IF p_spread_frequency = c_spread_frequency_one_time THEN

            v_num_years := CEIL (MONTHS_BETWEEN (v_main_lease_termination_date,
                                                 v_recurring_payment_start_date)) / 12;
            v_index_amount := v_index_amount * v_num_years;
         END IF;

         /* Fix for bug# 2007844 */

         IF TRUNC(v_main_lease_termination_date) > p_calculate_date THEN
            IF NVL(p_rounding_flag,'N') = 'Y' THEN
               v_index_amount := ROUND(
                                   v_index_amount / v_payments_per_year
                                  ,0 ) * v_payments_per_year;
            ELSE
               v_index_amount := ROUND (
                                   v_index_amount / v_payments_per_year
                                  ,get_amount_precision
                                    )  * v_payments_per_year;
            END IF;
         END IF;

         /* Subtract the normalized amount from the current index amount
            This new amount is what we will use for the recurring payment amount */

         put_log('create_payment_terms : v_index_amount '||v_index_amount);
         put_log('create_payment_terms : v_normalized_amount_annual '||v_normalized_amount_annual);
         put_log('create_payment_terms : v_existing_amounts '||v_existing_amounts);

         v_adjusted_amount :=   v_index_amount
                              - v_normalized_amount_annual
                              - v_existing_amounts ;

         put_log('create_payment_terms : v_adjusted_amount '||v_adjusted_amount);

         IF v_adjusted_amount IS NOT NULL THEN

            /* creating the payment term record
               added on 22-AUG-01
               create a record on pn_payment_terms table if main lease termination
               date > sysdate.
               Fix for bug# 2007492 */

            IF TRUNC(v_main_lease_termination_date) > p_calculate_date AND
               v_recurring_payment_start_date <= v_main_lease_termination_date AND
               v_recurring_payment_start_date <= v_end_date  THEN

               create_payment_term_record (
                                        p_lease_id                    => p_lease_id
                                       ,p_location_id                 => p_location_id
                                       ,p_purpose_code                => p_purpose_code
                                       ,p_index_period_id             => p_index_period_id
                                       ,p_term_template_id            => p_term_template_id
                                       ,p_spread_frequency            => p_spread_frequency
                                       ,p_rounding_flag               => p_rounding_flag
                                       ,p_payment_amount              => v_adjusted_amount
                                       ,p_start_date                  => v_recurring_payment_start_date
                                       ,p_normalized                  => v_normalize
                                       ,p_index_term_indicator        => c_index_pay_term_type_recur
                                       ,p_payment_term_id             => NULL
                                       ,p_basis_relationship          => p_relationship
                                       ,p_called_from                 => 'INDEX'
                                       ,p_calculate_date              => p_calculate_date
                                       ,p_end_date                    => v_end_date
                                       ,op_payment_term_id            => v_created_payment_term_id
                                       ,op_msg                        => v_msg
                                                               );
            END IF;

            /* check to see if we need to calculate a backbill amount. */


            IF p_index_finder_type in ( c_index_finder_backbill, c_index_finder_most_recent)
               AND NVL (v_num_pymt_since_assmt_dt, 0) <> 0 THEN

               /* Derive Backbill Amount:
                  Count number of payments between sysdate and assessment date
                  (SQL: (months_between (assessment_date, sysdate) + 1 )invoiced per year,
                   Calculate the backbill amount (monthly amount X no. of months
                   between sysdate and assessment date) */


               SELECT DECODE (
                              p_spread_frequency
                             ,c_spread_frequency_monthly, 12
                             ,c_spread_frequency_quarterly, 4
                             ,c_spread_frequency_semiannual, 2
                             ,c_spread_frequency_annually, 1
                             ,1
                              )
               INTO v_payments_per_year
               FROM DUAL;

               chk_approved_amount (
                              p_index_period_id             => p_index_period_id
                             ,p_index_term_indicator        => c_index_pay_term_type_backbill
                             ,op_approved_amount_annual     => v_approved_amt_annual_bb
                             ,op_msg                        => v_msg );

               put_log('create_payment_terms :v_approved_amt_annual_bb  **** '||v_approved_amt_annual_bb);

               /* Fix for bug# 1988909             */

               IF p_spread_frequency = c_spread_frequency_one_time AND
                  NVL(v_adjusted_amount,0) <> 0  THEN

                  v_num_years := CEIL (MONTHS_BETWEEN (v_recurring_payment_start_date,
                                                       p_assessment_date)) / 12;
                  v_backbill_amt := ROUND(p_index_amount * v_num_years,
                                          get_amount_precision);
               ELSE
                  v_backbill_amt := ((v_index_amount - v_normalized_amount_annual)/
                                      v_payments_per_year) * v_num_pymt_since_assmt_dt;
                                    --(v_adjusted_amount / v_payments_per_year)
               END IF;

               put_log('create_payment_terms : v_backbill_amt '||v_backbill_amt);

               v_backbill_overlap_amt := 0;
               v_backbill_chk_str_dt  := p_assessment_date;
               v_backbill_chk_end_dt  := last_day(add_months(v_recurring_payment_start_date, -1));

               get_backbill_overlap_amt(
                  p_term_template_id     => p_term_template_id,
                  p_index_period_id      => p_index_period_id,
                  p_index_term_indicator => c_index_pay_term_type_recur,
                  p_start_date           => v_backbill_chk_str_dt,
                  p_end_date             => v_backbill_chk_end_dt,
                  p_overlap_amt          => v_backbill_overlap_amt);

               v_backbill_amt := v_backbill_amt - v_approved_amt_annual_bb - v_backbill_overlap_amt;

               IF v_backbill_amt <> 0 THEN
                  IF NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'OT' THEN
                     l_backbill_st_date   := TRUNC(SYSDATE) ;
                     l_backbill_end_date  := NULL;
                     l_backbill_freq      := c_spread_frequency_one_time;
                     l_backbill_amt       := v_backbill_amt;
                     l_backbill_normalize := 'N';
                  ELSIF NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'RECUR' THEN

                     derive_term_end_date(
                         ip_index_lease_id               =>  p_index_lease_id
                        ,ip_index_period_id              =>  p_index_period_id
                        ,ip_main_lease_termination_date  =>  v_main_lease_termination_date
                        ,op_term_end_date                =>  l_backbill_end_date_temp);

                     l_backbill_st_date   := p_assessment_date ;
                     l_backbill_end_date  := LEAST(v_recurring_payment_start_date - 1,l_backbill_end_date_temp);
                     l_backbill_freq      := p_spread_frequency;
                     l_backbill_amt       := v_adjusted_amount;
                     l_recur_bb_calc_date := p_calculate_date;
                     l_backbill_normalize := NVL(v_normalize,'N');

                  END IF;

                  IF l_backbill_st_date <= NVL(l_backbill_end_date,TRUNC(SYSDATE)) THEN

                     create_payment_term_record (
                          p_lease_id                    => p_lease_id
                         ,p_location_id                 => p_location_id
                         ,p_purpose_code                => p_purpose_code
                         ,p_index_period_id             => p_index_period_id
                         ,p_term_template_id            => p_term_template_id
                         ,p_spread_frequency            => l_backbill_freq
                         ,p_rounding_flag               => p_rounding_flag
                         ,p_payment_amount              => l_backbill_amt
                         ,p_start_date                  => l_backbill_st_date
                         ,p_normalized                  => l_backbill_normalize
                         ,p_index_term_indicator        => c_index_pay_term_type_backbill
                         ,p_payment_term_id             => NULL
                         ,p_basis_relationship          => p_relationship
                         ,p_called_from                 => 'INDEX'
                         ,p_calculate_date              => p_calculate_date
                         ,p_end_date                    => l_backbill_end_date
                         ,p_recur_bb_calc_date          => l_recur_bb_calc_date
                         ,op_payment_term_id            => v_created_payment_term_id
                         ,op_msg                        => v_msg);

                  END IF;
              END IF;

            END IF; --p_index_finder_type = c_index_finder_backbill

         END IF; -- v_adjusted_amount IS NOT NULL


      ELSE

         /* aggregation .. */

         put_log('in aggregation *');

         IF (p_relationship IN (c_relation_greater_of, c_relation_basis_only)) then

            IF (p_index_amount > NVL(v_constrained_rent_amount,0))AND
               NVL(p_index_amount,0) <> 0  THEN

               v_adjusted_amount_aggr :=  p_index_amount - NVL(v_constrained_rent_amount,0);
            ELSE
               v_adjusted_amount_aggr := 0;
            END IF;

            put_log ('p_index-amount ' || to_char(p_index_amount));
            put_log ('v_constrained_rent_amount ' || to_char(v_constrained_rent_amount));

         ELSE
            v_adjusted_amount_aggr :=  p_index_amount;
         END IF;

         IF v_adjusted_amount_aggr <> 0   THEN

            create_aggr_payment_terms (
                             p_index_lease_id            => p_index_lease_id
                            ,p_basis_start_date          => p_basis_start_date
                            ,p_basis_end_date            => p_basis_end_date
                            ,p_index_term_indicator      => c_index_pay_term_type_recur
                            ,p_lease_id                  => p_lease_id
                            ,p_assessment_date           => p_assessment_date
                            ,p_normalized_amount_annual  => null
                            ,p_basis_relationship        => p_relationship
                            ,p_basis_type                => p_basis_type
                            ,p_total_rent_amount         => v_adjusted_amount_aggr
                            ,p_increase_on               => p_increase_on
                            ,p_rounding_flag             => p_rounding_flag
                            ,p_main_lease_termination_date => v_main_lease_termination_date
                            ,p_index_finder_type         => p_index_finder_type
                            ,p_index_period_id           => p_index_period_id
                            ,p_calculate_date            => p_calculate_date
                            ,op_msg                      => v_msg
                            );
         END IF;

      END IF;  -- p_termplate_id is not null

   END IF; --v_index_amount IS NOT NULL

 END create_payment_terms;


-------------------------------------------------------------------------------
-- PROCEDURE  : create_payment_term_record
--
-- 21-FEB-02  psidhu  o Added x_calling_form parameter in the call to procedure
--                      pnt_payment_terms_pkg.insert_row.
-- 16-APR-02  kkhegde o Bug#2205537
--                      Added select statement to get location_id so that when
--                      user defines a rent increase
--                      ( using a default term template )
--                      and specifies a location
--                      ( in the agreements header ), this
--                      same location shld be defaulted for all
--                       index rent terms  created for that rent increase.
-- 18-SEP-02 ftanudja o changed call from fnd_profile.value('PN_SET..')
--                      to wrapper function
--                      pn_mo_cache_utils.get_profile_value('PN_SET..').
-- 26-JAN-04 ftanudja o added handling logic for p_called_from ='NEGRENT'.
--                      #3255737.
--                      If 'NEGRENT' then use the term end dt,
--                      not lease term dt.
-- 14-JUN-04 abanerje o Modified call to pnt_payment_terms_pkg.insert_row
--                      to populate the term_template_id. Bug #3657130.
-- 08-OCT-04 stripath o Modified for BUG# 3961117, added new parameter p_calculate_date
--                      for not to create backbills if Assessment Date <= CutOff Date.
-- 21-APR-05 ftanudja o Added area_type_code, area defaulting. #4324777
-- 15-JUL-05 ftanudja o R12: tax_classification_code. #4495054.
-- 19-SEP-05 piagrawa o Modified to pass org id to pn_mo_cache_utils.
--                      get_profile_value
-- 25-NOV-05 pikhar   o Modified org id passed to pn_mo_cache_utils.
--                      get_profile_value
-- 06-APR-06 hkulkarn o Bug#4291907 - modified to comapre the term amount
--                      with value in system option SMALLEST_TERM_AMOUNT
-- 18-APR-06 Hareesha o Bug#5115291 - Get the latest norm_start_date
--                      of the parent term and insert it into the RI term
--                      created it.
-- 05-MAY-06 Hareesha o Bug# 5115291 - Added parameter p_norm_st_date
--                      Populate norm_st_date into RI term from parameter.
-- 10-AUG-06 Pikhar   o Codev. Added include_in_var_rent
-- 01-NOV-06 Prabhkar o Added parameter p_end_date.
-- 02-JAN-07 Hareesha o M28#16 Changes for recurring backbill.
-- 15-FEB-07 Pikhar   o bug 5881424. Copied include_in_var_rent to NULL if it
--                      is not INCLUDE_RI
-- 09-JUL-08 mumohan  o bug#6967722: In create_payment_term_record procedure,
--                      corrected the code in call pnt_payment_terms_pkg.insert_row,
--                      to copy the payment terms DFF into payment terms DFF of
--                      new IR term and not in AR Projects DFF.
-------------------------------------------------------------------------------


   PROCEDURE create_payment_term_record (
      p_lease_id               IN       NUMBER
     ,p_location_id            IN       NUMBER
     ,p_purpose_code           IN       VARCHAR2
     ,p_index_period_id        IN       NUMBER
     ,p_term_template_id       IN       NUMBER
     ,p_spread_frequency       IN       VARCHAR2
     ,p_rounding_flag          IN       VARCHAR2
     ,p_payment_amount         IN       NUMBER
     ,p_normalized             IN       VARCHAR2
     ,p_start_date             IN       DATE
     ,p_index_term_indicator   IN       VARCHAR2
     ,p_payment_term_id        IN       NUMBER
     ,p_basis_relationship     IN       VARCHAR2
     ,p_called_from            IN       VARCHAR2
     ,p_calculate_date         IN       DATE
     ,p_norm_st_date           IN       DATE
     ,p_end_date               IN       DATE
     ,p_recur_bb_calc_date     IN       DATE
     ,op_payment_term_id       OUT NOCOPY      NUMBER
     ,op_msg                   OUT NOCOPY      VARCHAR2
     ,p_include_in_var_rent    IN VARCHAR2
   ) IS
      v_name                     pn_term_templates.name%TYPE;
      v_normalize                pn_term_templates.normalize%TYPE := 'N';
      v_schedule_day             pn_term_templates.schedule_day%TYPE;
      v_payment_purpose_code     pn_term_templates.payment_purpose_code%TYPE;
      v_payment_term_type_code   pn_term_templates.payment_term_type_code%TYPE;
      v_accrual_account_id       pn_term_templates.accrual_account_id%TYPE;
      v_project_id               pn_term_templates.project_id%TYPE;
      v_task_id                  pn_term_templates.task_id%TYPE;
      v_organization_id          pn_term_templates.organization_id%TYPE;
      v_expenditure_type         pn_term_templates.expenditure_type%TYPE;
      v_expenditure_item_date    pn_term_templates.expenditure_item_date%TYPE;
      v_vendor_id                pn_term_templates.vendor_id%TYPE;
      v_vendor_site_id           pn_term_templates.vendor_site_id%TYPE;
      v_customer_id              pn_term_templates.customer_id%TYPE;
      v_customer_site_use_id     pn_term_templates.customer_site_use_id%TYPE;
      v_cust_ship_site_id        pn_term_templates.cust_ship_site_id%TYPE;
      v_ap_ar_term_id            pn_term_templates.ap_ar_term_id%TYPE;
      v_cust_trx_type_id         pn_term_templates.cust_trx_type_id%TYPE;
      v_tax_group_id             pn_term_templates.tax_group_id%TYPE;
      v_tax_code_id              pn_term_templates.tax_code_id%TYPE;
      v_tax_classification_code  pn_term_templates.tax_classification_code%TYPE;
      v_tax_included             pn_term_templates.tax_included%TYPE;
      v_distribution_set_id      pn_term_templates.distribution_set_id%TYPE;
      v_inv_rule_id              pn_term_templates.inv_rule_id%TYPE;
      v_account_rule_id          pn_term_templates.account_rule_id%TYPE;
      v_salesrep_id              pn_term_templates.salesrep_id%TYPE;
      v_set_of_books_id          pn_term_templates.set_of_books_id%TYPE;
      v_currency_code            pn_payment_terms.currency_code%TYPE;
      v_po_header_id             pn_term_templates.po_header_id%TYPE;
      v_cust_po_number           pn_term_templates.cust_po_number%TYPE;
      v_receipt_method_id        pn_term_templates.receipt_method_id%TYPE;
      v_attribute_category       pn_term_templates.attribute_category%TYPE;
      v_attribute1               pn_term_templates.attribute1%TYPE;
      v_attribute2               pn_term_templates.attribute2%TYPE;
      v_attribute3               pn_term_templates.attribute3%TYPE;
      v_attribute4               pn_term_templates.attribute4%TYPE;
      v_attribute5               pn_term_templates.attribute5%TYPE;
      v_attribute6               pn_term_templates.attribute6%TYPE;
      v_attribute7               pn_term_templates.attribute7%TYPE;
      v_attribute8               pn_term_templates.attribute8%TYPE;
      v_attribute9               pn_term_templates.attribute9%TYPE;
      v_attribute10              pn_term_templates.attribute10%TYPE;
      v_attribute11              pn_term_templates.attribute11%TYPE;
      v_attribute12              pn_term_templates.attribute12%TYPE;
      v_attribute13              pn_term_templates.attribute13%TYPE;
      v_attribute14              pn_term_templates.attribute14%TYPE;
      v_attribute15              pn_term_templates.attribute15%TYPE;
      v_lease_termination_date   pn_lease_details.lease_termination_date%TYPE;
      v_lease_change_id          pn_lease_details.lease_change_id%TYPE;
      v_lease_class_code         pn_leases.lease_class_code%TYPE;
      v_distribution_id          pn_distributions.distribution_id%TYPE;
      v_rowid                    VARCHAR2 (100);
      v_payment_term_id          pn_payment_terms.payment_term_id%TYPE;
      v_freq_divisor             NUMBER;
      v_converted_amount         NUMBER;
      v_actual_amount            pn_payment_terms.actual_amount%TYPE;
      v_gl_set_of_books_id       gl_sets_of_books.set_of_books_id%TYPE;
      v_expense_account_id       pn_lease_details.expense_account_id%TYPE;
      v_receivable_account_id    pn_lease_details.receivable_account_id%TYPE;
      v_account_class            pn_distributions.account_class%TYPE;
      v_payment_end_date         DATE;
      v_num_years                NUMBER;
      rec_payment_details        pn_payment_terms%ROWTYPE;
      c_rec                      pn_distributions%ROWTYPE;
      v_frequency_code           pn_payment_terms.frequency_code%type;
      v_location_id              pn_payment_terms.location_id%type;
      v_payment_start_date       DATE := null;
      v_term_end_date            DATE := null;
      v_assessment_date          DATE := null;
      v_org_id                   pn_payment_terms_all.org_id%type;
      v_area                     pn_payment_terms.area%TYPE;
      v_area_type_code           pn_payment_terms.area_type_code%TYPE;
      l_org_id                   NUMBER;
      l_norm_st_date             DATE := NULL;
      v_include_in_var_rent      pn_payment_terms_all.include_in_var_rent%TYPE ;

      CURSOR distributions (ip_term_template_id   IN   NUMBER)
      IS
      SELECT *
      FROM pn_distributions_all
      WHERE term_template_id = ip_term_template_id;

      CURSOR distributions_aggr (ip_payment_term_id IN   NUMBER )
      IS
      SELECT *
      FROM pn_distributions_all
      WHERE payment_term_id = ip_payment_term_id;

      CURSOR get_location_id IS
       SELECT location_id
       FROM pn_index_leases_all
       WHERE index_lease_id =
              (SELECT index_lease_id
               FROM pn_index_lease_periods_all
               WHERE index_period_id = p_index_period_id);

      CURSOR org_id_cur IS
       SELECT org_id
       FROM pn_leases_all
       WHERE lease_id = p_lease_id;


      CURSOR get_vr_nbp_flag IS
       SELECT vr_nbp_flag
       FROM pn_index_leases_all
       WHERE index_lease_id =
              (SELECT index_lease_id
               FROM pn_index_lease_periods_all
               WHERE index_period_id = p_index_period_id);

   BEGIN
      put_log ('pn_index_amount_pkg.create_payment_term_record  (+) :');

      IF NVL (p_payment_amount, 0) <> 0 THEN

           /* derive payment defaults for this index lease */

           BEGIN

           v_location_id := null;

           IF p_term_template_id is NULL THEN
                        SELECT include_in_var_rent
                              ,normalize
                              ,schedule_day
                              ,end_date
                              ,payment_purpose_code
                              ,payment_term_type_code
                              ,project_id
                              ,task_id
                              ,organization_id
                              ,expenditure_type
                              ,expenditure_item_date
                              ,vendor_id
                              ,vendor_site_id
                              ,customer_id
                              ,customer_site_use_id
                              ,cust_ship_site_id
                              ,ap_ar_term_id
                              ,cust_trx_type_id
                              ,tax_group_id
                              ,tax_code_id
                              ,tax_classification_code
                              ,tax_included
                              ,distribution_set_id
                              ,inv_rule_id
                              ,account_rule_id
                              ,salesrep_id
                              ,set_of_books_id
                              ,currency_code
                              ,po_header_id
                              ,cust_po_number
                              ,receipt_method_id
                              ,attribute_category
                              ,attribute1
                              ,attribute2
                              ,attribute3
                              ,attribute4
                              ,attribute5
                              ,attribute6
                              ,attribute7
                              ,attribute8
                              ,attribute9
                              ,attribute10
                              ,attribute11
                              ,attribute12
                              ,attribute13
                              ,attribute14
                              ,attribute15
                              ,frequency_code
                              ,location_id
                              ,org_id
                          INTO v_include_in_var_rent
                              ,v_normalize
                              ,v_schedule_day
                              ,v_term_end_date
                              ,v_payment_purpose_code
                              ,v_payment_term_type_code
                              ,v_project_id
                              ,v_task_id
                              ,v_organization_id
                              ,v_expenditure_type
                              ,v_expenditure_item_date
                              ,v_vendor_id
                              ,v_vendor_site_id
                              ,v_customer_id
                              ,v_customer_site_use_id
                              ,v_cust_ship_site_id
                              ,v_ap_ar_term_id
                              ,v_cust_trx_type_id
                              ,v_tax_group_id
                              ,v_tax_code_id
                              ,v_tax_classification_code
                              ,v_tax_included
                              ,v_distribution_set_id
                              ,v_inv_rule_id
                              ,v_account_rule_id
                              ,v_salesrep_id
                              ,v_set_of_books_id
                              ,v_currency_code
                              ,v_po_header_id
                              ,v_cust_po_number
                              ,v_receipt_method_id
                              ,v_attribute_category
                              ,v_attribute1
                              ,v_attribute2
                              ,v_attribute3
                              ,v_attribute4
                              ,v_attribute5
                              ,v_attribute6
                              ,v_attribute7
                              ,v_attribute8
                              ,v_attribute9
                              ,v_attribute10
                              ,v_attribute11
                              ,v_attribute12
                              ,v_attribute13
                              ,v_attribute14
                              ,v_attribute15
                              ,v_frequency_code
                              ,v_location_id
                              ,v_org_id
                          FROM pn_payment_terms_all
                         WHERE payment_term_id = p_payment_term_id;
           ELSE
                         SELECT name
                              ,normalize
                              ,schedule_day
                              ,payment_purpose_code
                              ,payment_term_type_code
                              ,accrual_account_id
                              ,project_id
                              ,task_id
                              ,organization_id
                              ,expenditure_type
                              ,expenditure_item_date
                              ,vendor_id
                              ,vendor_site_id
                              ,customer_id
                              ,customer_site_use_id
                              ,cust_ship_site_id
                              ,ap_ar_term_id
                              ,cust_trx_type_id
                              ,tax_group_id
                              ,tax_code_id
                              ,tax_classification_code
                              ,tax_included
                              ,distribution_set_id
                              ,inv_rule_id
                              ,account_rule_id
                              ,salesrep_id
                              ,set_of_books_id
                              ,po_header_id
                              ,cust_po_number
                              ,receipt_method_id
                              ,attribute_category
                              ,attribute1
                              ,attribute2
                              ,attribute3
                              ,attribute4
                              ,attribute5
                              ,attribute6
                              ,attribute7
                              ,attribute8
                              ,attribute9
                              ,attribute10
                              ,attribute11
                              ,attribute12
                              ,attribute13
                              ,attribute14
                              ,attribute15
                              ,org_id
                          INTO v_name
                              ,v_normalize
                              ,v_schedule_day
                              ,v_payment_purpose_code
                              ,v_payment_term_type_code
                              ,v_accrual_account_id
                              ,v_project_id
                              ,v_task_id
                              ,v_organization_id
                              ,v_expenditure_type
                              ,v_expenditure_item_date
                              ,v_vendor_id
                              ,v_vendor_site_id
                              ,v_customer_id
                              ,v_customer_site_use_id
                              ,v_cust_ship_site_id
                              ,v_ap_ar_term_id
                              ,v_cust_trx_type_id
                              ,v_tax_group_id
                              ,v_tax_code_id
                              ,v_tax_classification_code
                              ,v_tax_included
                              ,v_distribution_set_id
                              ,v_inv_rule_id
                              ,v_account_rule_id
                              ,v_salesrep_id
                              ,v_set_of_books_id
                              ,v_po_header_id
                              ,v_cust_po_number
                              ,v_receipt_method_id
                              ,v_attribute_category
                              ,v_attribute1
                              ,v_attribute2
                              ,v_attribute3
                              ,v_attribute4
                              ,v_attribute5
                              ,v_attribute6
                              ,v_attribute7
                              ,v_attribute8
                              ,v_attribute9
                              ,v_attribute10
                              ,v_attribute11
                              ,v_attribute12
                              ,v_attribute13
                              ,v_attribute14
                              ,v_attribute15
                              ,v_org_id
                          FROM pn_term_templates_all
                          WHERE term_template_id = p_term_template_id;

                  IF p_term_template_id is NOT NULL THEN
                     FOR nbp_rec IN get_vr_nbp_flag
                     LOOP
                        IF g_include_in_var_check = 'T' THEN
                           v_include_in_var_rent := g_include_in_var_rent;
                        ELSIF g_include_in_var_check = 'F' AND nbp_rec.vr_nbp_flag = 'Y' THEN
                           v_include_in_var_rent := 'INCLUDE_RI';
                        ELSE
                           v_include_in_var_rent := NULL;
                        END IF;
                     END LOOP;
                  END IF;

                  FOR locn_rec IN get_location_id LOOP
                     v_location_id := locn_rec.location_id;
                  END LOOP;

                  IF v_location_id IS NULL THEN
                     put_log ('Cannot Get Location Id for Payment Term Record - NO_DATA_FOUND');
                  END IF;

              END IF;

       EXCEPTION
           WHEN TOO_MANY_ROWS THEN
             put_log ('Cannot Get Payment Term Details - TOO_MANY_ROWS');
           WHEN NO_DATA_FOUND THEN
             put_log ('Cannot Get Payment Term Details - NO_DATA_FOUND');
           WHEN OTHERS THEN
             put_log ('Cannot Get Payment Term Details - Unknown Error:'|| SQLERRM);
       END;

       IF p_term_template_id is null THEN

             IF p_index_term_indicator not in (c_index_pay_term_type_atlst) AND
             NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'OT' then
                v_normalize := 'N';
             ELSE
                v_normalize := p_normalized;
             END IF;

             IF p_index_term_indicator in (c_index_pay_term_type_atlst_bb,
                                           c_index_pay_term_type_backbill) AND
                NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'OT'
             THEN
                 v_frequency_code := c_spread_frequency_one_time;
             END IF;
       ELSE
               v_normalize := p_normalized;

       END IF;

       BEGIN
           SELECT trunc(pilp.assessment_date)
           INTO v_assessment_date
           FROM pn_index_lease_periods_all pilp
           WHERE pilp.index_period_id = p_index_period_id;

       EXCEPTION
           WHEN TOO_MANY_ROWS THEN
              put_log ('Cannot Get Index Period Details - TOO_MANY_ROWS');
           WHEN NO_DATA_FOUND THEN
              put_log ('Cannot Get Index Period Details - NO_DATA_FOUND');
           WHEN OTHERS THEN
              put_log (   'Cannot Get Index Period Details - Unknown Error:'
                  || SQLERRM);
       END;

       BEGIN

           SELECT pl.lease_class_code
                 ,pld.expense_account_id
                 ,pld.lease_termination_date
                 ,pld.lease_change_id
           INTO v_lease_class_code
               ,v_expense_account_id
               ,v_lease_termination_date
               ,v_lease_change_id
           FROM pn_leases_all pl, pn_lease_details_all pld
           WHERE pl.lease_id = pld.lease_id
           AND pld.lease_id = p_lease_id;

      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
           put_log ('Cannot Get Main Lease Details - TOO_MANY_ROWS');
        WHEN NO_DATA_FOUND THEN
           put_log ('Cannot Get Main Lease Details - NO_DATA_FOUND');
        WHEN OTHERS THEN
           put_log (   'Cannot Get Main Lease Details - Unknown Error:'
                     || SQLERRM);
      END;

      IF v_org_id IS NULL THEN
        FOR org_id_rec IN org_id_cur LOOP
          v_org_id := org_id_rec.org_id;
        END LOOP;
      END IF;

      /* Derive SET_OF_BOOKS_ID and currency code */

      v_gl_set_of_books_id := pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID', v_org_id);


      IF p_term_template_id is not null THEN
         v_currency_code := g_currency_code;
      END IF;


     /*  if the payment frequency is one-time the payment start and end date will be the same
         Bug: 1817219 */

      v_payment_start_date := p_start_date;

      IF p_spread_frequency IN (c_spread_frequency_one_time)  THEN

         IF v_assessment_date < p_calculate_date AND
            p_index_term_indicator IN (c_index_pay_term_type_recur,c_index_pay_term_type_atlst) AND
            p_called_from IN ('INDEX','NEGRENT')  THEN
            v_payment_start_date := p_calculate_date;
         END IF;

         IF TRUNC(v_lease_termination_date) <= p_calculate_date AND
            p_called_from IN ('INDEX','NEGRENT')  THEN
            v_payment_start_date := v_assessment_date;
         END IF;

         v_payment_end_date := v_payment_start_date;
      ELSE

         IF p_called_from = 'NEGRENT' THEN
            v_payment_end_date := v_term_end_date;
         ELSE
            v_payment_end_date := p_end_date;
         END IF;

      END IF;

      /* convert annualized amount to value based on frequency code */

      IF p_spread_frequency = c_spread_frequency_monthly THEN
         v_freq_divisor := 12;
      ELSIF p_spread_frequency = c_spread_frequency_one_time THEN
         v_freq_divisor := 1;
      ELSIF p_spread_frequency = c_spread_frequency_quarterly THEN
         v_freq_divisor := 4;
      ELSIF p_spread_frequency = c_spread_frequency_semiannual THEN
         v_freq_divisor := 2;
      ELSIF p_spread_frequency = c_spread_frequency_annually THEN
         v_freq_divisor := 1;
      END IF;

      /* since the index rent is an annual amount.  it has to be converted
         to the amount to be paid based on the frequency */

      v_converted_amount := p_payment_amount / v_freq_divisor;

     /* if no schedule day from template set schedule day to the day of  today's date or
        that of the derived start date,whichever is of the two dates is later.. */

      IF v_schedule_day IS NULL THEN
         IF p_calculate_date > p_start_date THEN
            v_schedule_day := TO_NUMBER(TO_CHAR(p_calculate_date, 'DD'));
         ELSE
            v_schedule_day := TO_NUMBER(TO_CHAR(p_start_date, 'DD'));
         END IF;
      END IF;


      /* Depending on the lease class code, certain fields are not needed and will be nulled out*/


      IF v_lease_class_code = c_lease_class_direct THEN
         v_customer_id := NULL;
         v_customer_site_use_id := NULL;
         v_cust_ship_site_id := NULL;
         v_cust_trx_type_id := NULL;
         v_inv_rule_id := NULL;
         v_account_rule_id := NULL;
         v_salesrep_id := NULL;
         v_cust_po_number := NULL;
         v_receipt_method_id := NULL;
      ELSE
         v_project_id := NULL;
         v_task_id := NULL;
         v_organization_id := NULL;
         v_expenditure_type := NULL;
         v_expenditure_item_date := NULL;
         v_vendor_id := NULL;
         v_vendor_site_id := NULL;
         v_tax_group_id := NULL;
         v_distribution_set_id := NULL;
         v_po_header_id := NULL;
      END IF; --v_lease_class_code = C_LEASE_CLASS_DIRECT

      IF pn_r12_util_pkg.is_r12 THEN
         v_tax_group_id := NULL;
         v_tax_code_id := NULL;
      ELSE
         v_tax_classification_code := NULL;
      END IF;

      /* round off the index amount if necessary */

      IF NVL (p_rounding_flag, 'N') = 'Y' THEN
         v_actual_amount := ROUND (v_converted_amount, 0);
      ELSE
         v_actual_amount :=
                  ROUND (v_converted_amount, get_amount_precision);
      END IF; -- NVL (p_rounding_flag, 'N') = 'Y'

       /* figure out location and default area type and area size */

       IF v_location_id IS NOT NULL AND
          v_payment_start_date IS NOT NULL THEN

          v_area_type_code := 'LOCTN_RENTABLE';
          v_area := pnp_util_func.fetch_tenancy_area(
                       p_lease_id       => p_lease_id,
                       p_location_id    => p_location_id,
                       p_as_of_date     => v_payment_start_date,
                       p_area_type_code => v_area_type_code);

      END IF;

      /* Create a record in PN_PAYMENT_TERMS table */

      IF ( v_actual_amount <> 0
      AND abs(v_actual_amount) > nvl(pn_mo_cache_utils.get_profile_value('SMALLEST_TERM_AMOUNT',v_org_id),0)
         ) THEN  --#@#Bug4291907

         /* pikhar Start - Added for bug 5881424 - 15-FEB-07 */
         IF v_include_in_var_rent = 'INCLUDE_RI' THEN
           NULL;
         ELSE
           v_include_in_var_rent := NULL;
         END IF;
         /* pikhar Finished - Added for bug 5881424 - 15-FEB-07 */

         pnt_payment_terms_pkg.insert_row (
            x_rowid                       => v_rowid
           ,x_payment_term_id             => v_payment_term_id
           ,x_index_period_id             => p_index_period_id
           ,x_index_term_indicator        => p_index_term_indicator
           ,x_last_update_date            => SYSDATE
           ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_creation_date               => SYSDATE
           ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_payment_purpose_code        => NVL (v_payment_purpose_code, p_purpose_code)
           ,x_payment_term_type_code      => NVL (v_payment_term_type_code,c_payment_term_type_index)
           ,x_frequency_code              => p_spread_frequency
           ,x_lease_id                    => p_lease_id
           ,x_lease_change_id             => v_lease_change_id
           ,x_start_date                  => v_payment_start_date   --p_start_date
           ,x_end_date                    => v_payment_end_date
           ,x_set_of_books_id             => NVL(v_set_of_books_id,v_gl_set_of_books_id)
           ,x_currency_code               => v_currency_code
           ,x_rate                        => 1 -- not used in application
           ,x_last_update_login           => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_vendor_id                   => v_vendor_id
           ,x_vendor_site_id              => v_vendor_site_id
           ,x_target_date                 => NULL
           ,x_actual_amount               => v_actual_amount
           ,x_estimated_amount            => NULL
           ,x_attribute_category          => v_attribute_category
           ,x_attribute1                  => v_attribute1
           ,x_attribute2                  => v_attribute2
           ,x_attribute3                  => v_attribute3
           ,x_attribute4                  => v_attribute4
           ,x_attribute5                  => v_attribute5
           ,x_attribute6                  => v_attribute6
           ,x_attribute7                  => v_attribute7
           ,x_attribute8                  => v_attribute8
           ,x_attribute9                  => v_attribute9
           ,x_attribute10                 => v_attribute10
           ,x_attribute11                 => v_attribute11
           ,x_attribute12                 => v_attribute12
           ,x_attribute13                 => v_attribute13
           ,x_attribute14                 => v_attribute14
           ,x_attribute15                 => v_attribute15
           ,x_project_attribute_category  => NULL
           ,x_project_attribute1          => NULL
           ,x_project_attribute2          => NULL
           ,x_project_attribute3          => NULL
           ,x_project_attribute4          => NULL
           ,x_project_attribute5          => NULL
           ,x_project_attribute6          => NULL
           ,x_project_attribute7          => NULL
           ,x_project_attribute8          => NULL
           ,x_project_attribute9          => NULL
           ,x_project_attribute10         => NULL
           ,x_project_attribute11         => NULL
           ,x_project_attribute12         => NULL
           ,x_project_attribute13         => NULL
           ,x_project_attribute14         => NULL
           ,x_project_attribute15         => NULL
           ,x_customer_id                 => v_customer_id
           ,x_customer_site_use_id        => v_customer_site_use_id
           ,x_normalize                   => v_normalize --p_normalized
           ,x_location_id                 => v_location_id
           ,x_schedule_day                => v_schedule_day
           ,x_cust_ship_site_id           => v_cust_ship_site_id
           ,x_ap_ar_term_id               => v_ap_ar_term_id
           ,x_cust_trx_type_id            => v_cust_trx_type_id
           ,x_project_id                  => v_project_id
           ,x_task_id                     => v_task_id
           ,x_organization_id             => v_organization_id
           ,x_expenditure_type            => v_expenditure_type
           ,x_expenditure_item_date       => v_expenditure_item_date
           ,x_tax_group_id                => v_tax_group_id
           ,x_tax_code_id                 => v_tax_code_id
           ,x_tax_classification_code     => v_tax_classification_code
           ,x_tax_included                => v_tax_included
           ,x_distribution_set_id         => v_distribution_set_id
           ,x_inv_rule_id                 => v_inv_rule_id
           ,x_account_rule_id             => v_account_rule_id
           ,x_salesrep_id                 => v_salesrep_id
           ,x_approved_by                 => NULL
           ,x_status                      => c_payment_term_status_draft
           ,x_po_header_id                => v_po_header_id
           ,x_cust_po_number              => v_cust_po_number
           ,x_receipt_method_id           => v_receipt_method_id
           ,x_calling_form                => 'PNTRENTI'
           ,x_org_id                      => v_org_id
           ,x_term_template_id            => p_term_template_id
           ,x_area                        => v_area
           ,x_area_type_code              => v_area_type_code
           ,x_norm_start_date             => p_norm_st_date
           ,x_include_in_var_rent         => v_include_in_var_rent
           ,x_recur_bb_calc_date          => p_recur_bb_calc_date
         );

         op_payment_term_id := v_payment_term_id;

         put_output (
               LPAD (p_spread_frequency, 18, ' ')
            || LPAD (v_payment_start_date, 13, ' ')
            || LPAD (v_payment_end_date, 13, ' ')
            || LPAD (format (v_actual_amount, 2), 12, ' ')
            || LPAD (c_payment_term_status_draft, 13, ' ')
            || LPAD (p_index_term_indicator, 20, ' ')
            || LPAD (v_normalize, 11, ' ')
         );

         put_output ('.         ');


         /* Get distributions from template. */

         IF p_term_template_id IS NULL THEN
               OPEN distributions_aggr (p_payment_term_id);
          ELSE
               OPEN distributions (p_term_template_id);
         END IF;


         LOOP
             IF distributions_aggr%ISOPEN THEN
                   FETCH distributions_aggr into c_rec;
                   EXIT WHEN distributions_aggr%NOTFOUND;
              ELSIF distributions%ISOPEN  THEN
                   FETCH distributions into c_rec;
                   EXIT WHEN distributions%NOTFOUND;
              END IF;

            put_log('create_payment_term_record - account_class :'||c_rec.account_class);

            /* Create a record in PN_DISTRIBUTIONS table */

            pn_distributions_pkg.insert_row (
               x_rowid                       => v_rowid
              ,x_distribution_id             => v_distribution_id
              ,x_account_id                  => c_rec.account_id
              ,x_payment_term_id             => v_payment_term_id
              ,x_term_template_id            => NULL
              ,x_account_class               => c_rec.account_class
              ,x_percentage                  => c_rec.percentage
              ,x_line_number                 => c_rec.line_number
              ,x_last_update_date            => SYSDATE
              ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
              ,x_creation_date               => SYSDATE
              ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
              ,x_last_update_login           => NVL (fnd_profile.VALUE ('USER_ID'), 0)
              ,x_attribute_category          => c_rec.attribute_category
              ,x_attribute1                  => c_rec.attribute1
              ,x_attribute2                  => c_rec.attribute2
              ,x_attribute3                  => c_rec.attribute3
              ,x_attribute4                  => c_rec.attribute4
              ,x_attribute5                  => c_rec.attribute5
              ,x_attribute6                  => c_rec.attribute6
              ,x_attribute7                  => c_rec.attribute7
              ,x_attribute8                  => c_rec.attribute8
              ,x_attribute9                  => c_rec.attribute9
              ,x_attribute10                 => c_rec.attribute10
              ,x_attribute11                 => c_rec.attribute11
              ,x_attribute12                 => c_rec.attribute12
              ,x_attribute13                 => c_rec.attribute13
              ,x_attribute14                 => c_rec.attribute14
              ,x_attribute15                 => c_rec.attribute15
            );
            v_rowid := NULL;
            v_distribution_id := NULL;

         END LOOP payment_term_template;

         v_payment_term_id := NULL;

      END IF; --v_actual_amount <> 0

     END IF; --p_amount <> 0 then

   put_log ('pn_index_amount_pkg.create_payment_term_record  (-) :');

   END create_payment_term_record;

-------------------------------------------------------------------------------
--  FUNCTION   : Get_Calculate_Date
--  DESCRIPTION: This function returns returns the lease of assessment date and
--               the profile option cut off date (change from Legacy to PN).
--  HISTORY    :
--  08-OCT-2004  Satish Tripathi o Created for BUG# 3961117.
--                                 Do not to create backbills if Assessment
--                                 Date <= CutOff Date.
--  21-OCT-2004  Satish Tripathi o Added TO_DATE to profile PN_CUTOFF_DATE,
--                                 default 01/01/0001.
-------------------------------------------------------------------------------
FUNCTION Get_Calculate_Date (p_assessment_date  IN DATE,
                             p_period_str_date  IN DATE)
RETURN   DATE
IS
   l_prof_cut_off    VARCHAR2(30) := pn_mo_cache_utils.get_profile_value('PN_CUTOFF_DATE');
   l_cut_off_date    DATE := NULL;
   l_calculate_date  DATE;
BEGIN

   put_log('PN_INDEX_AMOUNT_PKG.Get_Calculate_Date (+) Asmt Dt: '||p_assessment_date
           ||', PrdStrDt: '||p_period_str_date||', CutOffDt: '||l_prof_cut_off);

   IF l_prof_cut_off IS NOT NULL THEN
      l_cut_off_date := TO_DATE(l_prof_cut_off, 'MM/DD/YYYY');
   ELSE
      l_cut_off_date := TO_DATE('01/01/0001', 'DD/MM/YYYY');
   END IF;

   IF TRUNC(l_cut_off_date) >= TRUNC(p_assessment_date) THEN
      l_calculate_date := TRUNC(p_assessment_date);
   ELSE
      l_calculate_date := TRUNC(SYSDATE);
   END IF;

   put_log('PN_INDEX_AMOUNT_PKG.Get_Calculate_Date (-) Calc Dt: '||l_calculate_date);

   RETURN l_calculate_date;
END Get_Calculate_Date;


-------------------------------------------------------------------------------
--  FUNCTION    : Get_Calculate_Date (overloaded)
--  DESCRIPTION : This function returns returns the lease of assessment date
--                and the profile option cut off date(change from Legacy to PN)
--  HISTORY     :
--  19-SEP-05   piagrawa  o Modified the signature of procedure. Also passed
--                          org id in pn_mo_cache_utils.get_profile_value
-------------------------------------------------------------------------------
FUNCTION Get_Calculate_Date (p_assessment_date  IN DATE,
                             p_period_str_date  IN DATE,
                             p_org_id           IN NUMBER)
RETURN   DATE
IS
   l_prof_cut_off    VARCHAR2(30) := pn_mo_cache_utils.get_profile_value('PN_CUTOFF_DATE', p_org_id);
   l_cut_off_date    DATE := NULL;
   l_calculate_date  DATE;
BEGIN

   put_log('PN_INDEX_AMOUNT_PKG.Get_Calculate_Date (+) Asmt Dt: '||p_assessment_date
           ||', PrdStrDt: '||p_period_str_date||', CutOffDt: '||l_prof_cut_off);

   IF l_prof_cut_off IS NOT NULL THEN
      l_cut_off_date := TO_DATE(l_prof_cut_off, 'MM/DD/YYYY');
   ELSE
      l_cut_off_date := TO_DATE('01/01/0001', 'DD/MM/YYYY');
   END IF;

   IF TRUNC(l_cut_off_date) >= TRUNC(p_assessment_date) THEN
      l_calculate_date := TRUNC(p_assessment_date);
   ELSE
      l_calculate_date := TRUNC(SYSDATE);
   END IF;

   put_log('PN_INDEX_AMOUNT_PKG.Get_Calculate_Date (-) Calc Dt: '||l_calculate_date);

   RETURN l_calculate_date;
END Get_Calculate_Date;

--------------------------------------------------------------------------------
-- PROCEDURE : calculate_period
-- DESCRIPTION: This procedure will calculate the index amount for a period
--             o Calculate Basis Amount
--             o Calculate Index Percentage Change (if necessary)
-- HISTORY
-- 13-FEB-04 ftanudja  o Fixed logic for 'UPDATE pn_index_leases set
--                       initial_basis..' Bug # 3436147
-- 08-OCT-04 Satish    o BUG# 3961117. Get calculate_date and pass it for not to
--                       create backbills if Assessment Date <= CutOff Date.
-- 03-Feb-05 Vivek     o Bug 4099136. Select NULL as purpose in cursor c1
-- 19-sep-05 piagrawa  o passed org id in pn_mo_cache_utils.get_profile_value
-- 24-NOV-06 Prabhakar o Added handling for index multiplier in calculating RI
--                       by passing adjusted index percentage to index_amonut.
-- 12-DEC-06 Prabhakar o Added the derivation of proration_factor
--                     o Added proration_rule,proration_period_start_date and
--                       assessment_interval columns to cursor c1.
-- 09-Jan-07 Lokesh    o Removed code to change schedule_day as the value
--                       returned by get_schedule_date for M28 item# 11
-- 30-Jan-07 Lokesh    o Removed to_date for GSCC error
-- 23-Jul-07 Prabhakar o Bug # 6263259.
--------------------------------------------------------------------------------

   PROCEDURE calculate_period (
      ip_index_lease_id              IN       NUMBER
     ,ip_index_lease_period_id       IN       NUMBER
     ,ip_recalculate                 IN       VARCHAR2
     ,op_current_basis               OUT NOCOPY      NUMBER
     ,op_unconstraint_rent_due       OUT NOCOPY      NUMBER
     ,op_constraint_rent_due         OUT NOCOPY      NUMBER
     ,op_index_percent_change        OUT NOCOPY      NUMBER
     ,op_current_index_line_id       OUT NOCOPY      NUMBER
     ,op_current_index_line_value    OUT NOCOPY      NUMBER
     ,op_previous_index_line_id      OUT NOCOPY      NUMBER
     ,op_previous_index_line_value   OUT NOCOPY      NUMBER
     ,op_previous_index_amount       IN OUT NOCOPY   NUMBER
     ,op_previous_asmt_date          IN OUT NOCOPY   DATE
     ,op_constraint_applied_amount   OUT NOCOPY      NUMBER
     ,op_carry_forward_amount        OUT NOCOPY      NUMBER
     ,op_constraint_applied_percent  OUT NOCOPY      NUMBER
     ,op_carry_forward_percent       OUT NOCOPY      NUMBER
     ,op_msg                         OUT NOCOPY      VARCHAR2
   ) IS
      v_basis_amount                pn_index_lease_periods.current_basis%TYPE;
      v_index_percent_change        pn_index_lease_periods.index_percent_change%TYPE;
      v_uncontrained_index_amount   pn_index_lease_periods.unconstraint_rent_due%TYPE;
      v_msg                         VARCHAR2 (100);
      v_all_msg                     VARCHAR2 (4000);
      v_period_msg                  VARCHAR2 (1000); -- messages for current period only
      v_constrained_rent_amount     pn_index_lease_periods.constraint_rent_due%TYPE;
      v_current_cpi_value           pn_index_lease_periods.current_index_line_value%TYPE;
      v_current_cpi_id              pn_index_lease_periods.current_index_line_id%TYPE;
      v_previous_cpi_value          pn_index_lease_periods.previous_index_line_value%TYPE;
      v_previous_cpi_id             pn_index_lease_periods.previous_index_line_id%TYPE;
      v_main_lease_commencement_date pn_lease_details.lease_commencement_date%type;
      v_initial_basis_amt           NUMBER := 0;
      v_constraint_applied_amount   pn_index_lease_periods.constraint_applied_amount%type;
      v_carry_forward_amount        pn_index_lease_periods.carry_forward_amount%type;
      v_constraint_applied_percent  pn_index_lease_periods.constraint_applied_percent%type;
      v_carry_forward_percent       pn_index_lease_periods.carry_forward_percent%type;
      l_err_flag                    VARCHAR2 (1);
      l_pre_index_rent_id           NUMBER;
      l_calculate_date              DATE;
      v_adj_index_percent_change    NUMBER;
      l_proration_rule              VARCHAR2(30);
      l_proration_period_start_date  DATE;
      l_prorate_factor              NUMBER :=1;
      l_months                      NUMBER := NULL;


      CURSOR c1 (
         p_index_lease_period_id   NUMBER
      ) IS
         SELECT pil.index_lease_id
               ,pil.index_id
               ,pil.lease_id
               ,pil.commencement_date
               ,pil.currency_code
               ,nvl(pil.increase_on,c_increase_on_gross) "INCREASE_ON"
               ,pil.basis_type
               ,pil.initial_basis
               ,pil.index_finder_method
               ,pil.base_index
               ,pil.base_index_line_id
               ,NVL (pil.rounding_flag, 'N') "ROUNDING_FLAG"
               ,pil.reference_period
               ,pil.spread_frequency
               ,pil.term_template_id
               ,pil.negative_rent_type
               ,NULL as purpose
               ,pil.location_id
               ,pil.index_lease_number
               ,pil.carry_forward_flag
               ,pilp.basis_percent_change
               ,pilp.current_basis
               ,pilp.index_percent_change
               ,pilp.index_finder_date
               ,pilp.index_period_id
               ,pilp.basis_start_date
               ,pilp.basis_end_date
               ,pilp.assessment_date
               ,pilp.line_number
               ,pilp.relationship
               ,pilp.constraint_rent_due
               ,pilp.unconstraint_rent_due
               ,pilp.current_index_line_id
               ,pilp.current_index_line_value
               ,pilp.previous_index_line_id
               ,pilp.previous_index_line_value
               ,pilp.carry_forward_amount
               ,pilp.constraint_applied_amount
               ,pilp.carry_forward_percent
               ,pilp.constraint_applied_percent
               ,pl.lease_class_code
               ,pil.org_id
               ,nvl (pilp.index_multiplier, 1) "INDEX_MULTIPLIER"
               ,nvl (pil.proration_rule, 'NO_PRORATION') "PRORATION_RULE"
               ,pil.proration_period_start_date
               ,pil.assessment_interval
           FROM pn_index_leases_all pil,
                pn_index_lease_periods_all pilp,
                pn_leases_all pl
          WHERE pil.index_lease_id = pilp.index_lease_id
            AND pil.lease_id = pl.lease_id
            AND pilp.index_period_id = p_index_lease_period_id;

      l_message VARCHAR2(2000) := NULL;

      CURSOR get_lease_details(p_lease_id NUMBER) IS
         SELECT lease_commencement_date,
                lease_termination_date,
                lease_extension_end_date
         FROM pn_leases_all lease, pn_lease_details_all ldet
         WHERE lease.lease_id = ldet.lease_id
         AND   lease.lease_id = p_lease_id;

      CURSOR get_extendable_terms(p_index_period_id NUMBER,l_term_date DATE) IS
         SELECT *
         FROM pn_payment_terms_all
         WHERE index_period_id = p_index_period_id
         AND end_date = l_term_date;

      l_comm_date DATE;
      l_term_date DATE;
      l_ext_end_dt DATE;
      l_term_rec pn_payment_terms_all%ROWTYPE;
      l_return_status VARCHAR2(100);
      l_schd_date  DATE := NULL;
      l_schd_day   NUMBER := NULL;
      l_terms_exist BOOLEAN := FALSE;

   BEGIN

      put_log('PN_INDEX_AMOUNT_PKG.calculate_period (+) LeaseId: '||ip_index_lease_id
              ||', PrdId: '||ip_index_lease_period_id||', ReCalc: '||ip_recalculate);
      v_all_msg := 'PN_INDEX_SUCCESS';
      l_pre_index_rent_id := NULL;

      FOR c_rec IN c1 (ip_index_lease_period_id)
      LOOP

         IF c_rec.index_period_id <> NVL(l_pre_index_rent_id,-9999) THEN
            l_err_flag := 'N';
            l_pre_index_rent_id := c_rec.index_period_id;
            IF c_rec.term_template_id IS NOT NULL AND
               NOT pnp_util_func.validate_term_template(p_term_temp_id   => c_rec.term_template_id,
                                                        p_lease_cls_code => c_rec.lease_class_code) THEN

               l_err_flag := 'Y';
               v_all_msg := 'PN_MISS_TERM_TEMP_DATA';
            END IF;
         END IF;
         IF l_err_flag = 'N' THEN
            l_calculate_date := Get_Calculate_Date(
                                    p_assessment_date => c_rec.assessment_date
                                   ,p_period_str_date => c_rec.basis_start_date
                                   ,p_org_id          => c_rec.org_id
                                   );
         put_output ('****************************************');
         fnd_message.set_name ('PN','PN_RICAL_PROC');
         put_output(fnd_message.get||'...');
         fnd_message.set_name ('PN','PN_RICAL_LSNO');
         fnd_message.set_token ('NUM', c_rec.index_lease_number);
         put_output(fnd_message.get);
         fnd_message.set_name ('PN','PN_RICAL_LS_PRD');
         fnd_message.set_token ('NUM', c_rec.line_number);
         fnd_message.set_token ('ID', c_rec.index_period_id);
         put_output(fnd_message.get);
         fnd_message.set_name ('PN','PN_RICAL_ASS_DATE');
         fnd_message.set_token ('DATE', c_rec.assessment_date);
         put_output(fnd_message.get);
         put_output ('****************************************');

        /* Initialize global variable g_currency_code */

         g_currency_code := c_rec.currency_code;

        /* Calculate index rent if no constrained rent is found or
           RECALCULATE parameter is set to 'Y'es. */

         IF c_rec.constraint_rent_due IS NULL
            OR NVL (ip_recalculate, 'N') = 'Y' THEN

               calculate_basis_amount (
                  p_index_lease_id              => c_rec.index_lease_id
                 ,p_basis_start_date            => c_rec.basis_start_date
                 ,p_basis_end_date              => c_rec.basis_end_date
                 ,p_assessment_date             => c_rec.assessment_date
                 ,p_initial_basis               => c_rec.initial_basis
                 ,p_line_number                 => c_rec.line_number
                 ,p_increase_on                 => c_rec.increase_on
                 ,p_basis_type                  => c_rec.basis_type
                 ,p_prev_index_amount           => op_previous_index_amount
                 ,p_recalculate                 => ip_recalculate
                 ,op_basis_amount               => v_basis_amount
                 ,op_msg                        => v_msg
               );

            pn_index_lease_common_pkg.append_msg (
               p_new_msg                     => v_msg
              ,p_all_msg                     => v_period_msg );

            v_msg := NULL;


            put_log ('Calculating the Index Percentage');

            IF c_rec.relationship IN (c_relation_index_only, c_relation_greater_of, c_relation_lesser_of) AND
              (   c_rec.index_percent_change IS NULL OR
                 (c_rec.index_finder_method = c_index_finder_most_recent AND
                  c_rec.assessment_date >= l_calculate_date)
              ) THEN

               calculate_index_percentage (
                  p_index_finder_type           => c_rec.index_finder_method
                 ,p_reference_period_type       => c_rec.reference_period
                 ,p_index_finder_date           => c_rec.index_finder_date
                 ,p_index_history_id            => c_rec.index_id
                 ,p_base_index                  => c_rec.base_index
                 ,p_base_index_line_id          => c_rec.base_index_line_id
                 ,p_index_lease_id              => c_rec.index_lease_id
                 ,p_assessment_date             => c_rec.assessment_date
                 ,p_prev_assessment_date        => op_previous_asmt_date
                 ,op_current_cpi_value          => v_current_cpi_value
                 ,op_current_cpi_id             => v_current_cpi_id
                 ,op_previous_cpi_value         => v_previous_cpi_value
                 ,op_previous_cpi_id            => v_previous_cpi_id
                 ,op_index_percent_change       => v_index_percent_change
                 ,op_msg                        => v_msg
               );

            ELSE
               v_index_percent_change := c_rec.index_percent_change;
               v_current_cpi_value := c_rec.current_index_line_value;
               v_current_cpi_id := c_rec.current_index_line_id;
               v_previous_cpi_value := c_rec.previous_index_line_value;
               v_previous_cpi_id := c_rec.previous_index_line_id;
            END IF; -- c_rec.relationship in ???

            v_adj_index_percent_change := v_index_percent_change * c_rec.index_multiplier;

            put_log ('v_msg ' || v_msg);
            pn_index_lease_common_pkg.append_msg (
               p_new_msg                     => v_msg
              ,p_all_msg                     => v_period_msg
            );
            v_msg := NULL;

            calculate_index_amount (
               p_relationship                => c_rec.relationship
              ,p_adj_index_percent_change    => v_adj_index_percent_change
              ,p_basis_percent_change        => c_rec.basis_percent_change
              ,p_current_basis               => v_basis_amount
              ,op_index_amount               => v_uncontrained_index_amount
              ,op_msg                        => v_msg
            );

            put_log ('3 v_msg ' || v_msg);
            pn_index_lease_common_pkg.append_msg (
               p_new_msg                     => v_msg
              ,p_all_msg                     => v_period_msg
            );
            v_msg := NULL;

           put_log('********************** p_unconstrained_rent_amount ******************************'||
                   v_uncontrained_index_amount);

               l_prorate_factor := 1;
               IF c_rec.commencement_date = c_rec.assessment_date THEN

                   IF c_rec.proration_rule = 'DAYS_365' THEN
                       l_prorate_factor := (
                                             c_rec.commencement_date -
                                             c_rec.proration_period_start_date
                                            )/(365*c_rec.assessment_interval);

                   ELSIF c_rec.proration_rule = 'FUL_PART_MON_12' THEN
                       l_months := MONTHS_BETWEEN (
                                                   c_rec.commencement_date,
                                                   c_rec.proration_period_start_date
                                                  );

                      IF TRUNC (l_months, 0) <> l_months THEN
                         l_months := TRUNC (l_months, 0) + 1;
                      END IF;

                      l_prorate_factor := l_months/(12*c_rec.assessment_interval);

                   END IF;

               END IF;

	    IF v_uncontrained_index_amount IS NOT NULL THEN  -- Bug #6263259

               derive_constrained_rent (
                  p_index_lease_id              => c_rec.index_lease_id
                 ,p_current_basis               => v_basis_amount
                 ,p_index_period_id             => c_rec.index_period_id
                 ,p_assessment_date             => c_rec.assessment_date
                 ,p_negative_rent_type          => c_rec.negative_rent_type
                 ,p_unconstrained_rent_amount   => v_uncontrained_index_amount
                 ,p_carry_forward_flag          => nvl(c_rec.carry_forward_flag,'N')
                 ,p_prorate_factor              => l_prorate_factor
                 ,op_constrained_rent_amount    => v_constrained_rent_amount
                 ,op_constraint_applied_amount  => v_constraint_applied_amount
                 ,op_constraint_applied_percent => v_constraint_applied_percent
                 ,op_carry_forward_amount       => v_carry_forward_amount
                 ,op_carry_forward_percent      => v_carry_forward_percent
                 ,op_msg                        => v_msg
                                );

               put_log ('v_msg ' || v_msg);
               pn_index_lease_common_pkg.append_msg (
                  p_new_msg                     => v_msg
                 ,p_all_msg                     => v_period_msg
               );
               v_msg := NULL;

            END IF; -- v_uncontrained_index_amount


            /* Delete from the Intermediate table PN_INDEX_LEASE_TERMS_ALL */


            DELETE FROM pn_index_lease_terms_all ilt
            WHERE ilt.index_period_id = c_rec.index_period_id
            AND ilt.approved_flag <> c_payment_term_status_approved ;

            DELETE FROM pn_distributions_all
                  WHERE payment_term_id IN (SELECT payment_term_id
                                            FROM pn_payment_terms_all ppt
                                            WHERE ppt.index_period_id = c_rec.index_period_id
                                               AND ppt.status <> c_payment_term_status_approved);

            DELETE FROM pn_payment_terms_all ppt
                  WHERE ppt.index_period_id = c_rec.index_period_id
                    AND ppt.status <> c_payment_term_status_approved;

         --
         -- Printing the Headers of the report
         --
         fnd_message.set_name ('PN','PN_RICAL_CUR');
         l_message := '      '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_ASS');
         l_message := l_message||'    '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_INDX');
         l_message := l_message||'                  '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_BAS');
         l_message := l_message||'       '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_UCON');
         l_message := l_message||'  '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_CON');
         l_message := l_message||'   '||fnd_message.get;
         put_output(l_message);

         l_message := NULL;

         fnd_message.set_name ('PN','PN_RICAL_BAS');
         l_message := '       '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_DATE');
         l_message := l_message||'        '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_REL');
         l_message := l_message||'        '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_CHG');
         l_message := l_message||'   '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_CHG');
         l_message := l_message||'  '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_RENT_DUE');
         l_message := l_message||'   '||fnd_message.get;
         l_message := l_message||'   '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_DUE');
         l_message := l_message||' '||fnd_message.get;
         put_output(l_message);

         put_output (
            '     ---------  ------------  -----------  ----------  ----------  ----------  ----------'
         );

         --  Print the Period Details
         --  format function will display 3 decimal places for all numbers

         put_output (
               LPAD (format (v_basis_amount, 2), 14, ' ')
            || LPAD (TO_CHAR (c_rec.assessment_date, 'DD-MON-RRRR'), 14, ' ')
            || LPAD (c_rec.relationship, 13, ' ')
            || LPAD (format (v_index_percent_change, 3), 13, ' ')
            || LPAD (format (c_rec.basis_percent_change, 3), 11, ' ')
            || LPAD (format (v_uncontrained_index_amount, 2), 12, ' ')
            || LPAD (format (v_constrained_rent_amount, 2), 12, ' ')
         );

           put_output ('.         ');

           fnd_message.set_name ('PN','PN_RICAL_PAYMENT');
           l_message := '         '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_START');
           l_message := l_message||'      '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_END');
           l_message := l_message||'        '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_PAYMENT');
           l_message := l_message||'                     '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_INDEX');
           l_message := l_message||'        '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_NORZ');
           l_message := l_message||'        '||fnd_message.get;
           put_output(l_message);

           l_message := NULL;

           fnd_message.set_name ('PN','PN_RICAL_FREQ');
           l_message := '         '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_DATE');
           l_message := l_message||'     '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_DATE');
           l_message := l_message||'        '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_AMT');
           l_message := l_message||'        '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_STATUS');
           l_message := l_message||'      '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_PAYMENT_TYPE');
           l_message := l_message||'        '||fnd_message.get;
           fnd_message.set_name ('PN','PN_RICAL_YES_NO');
           l_message := l_message||'      '||fnd_message.get;
           put_output(l_message);

           put_output (
         '         ---------  -----------  -----------  ----------  -----------  ------------------  ---------'
           );

           FOR l_rec IN get_lease_details(c_rec.lease_id) LOOP
               l_comm_date := l_rec.lease_commencement_date;
               l_term_date := l_rec.lease_termination_date;
               l_ext_end_dt := l_rec.lease_extension_end_date;
            END LOOP;

       FOR terms_rec IN get_extendable_terms(c_rec.index_period_id,l_term_date) LOOP
               l_terms_exist := TRUE;
       END LOOP;

       IF (NVL(fnd_profile.value('PN_IR_TERM_END_DATE'),'LEASE_END') <> 'PERIOD_END' OR
               (c_rec.basis_type <> c_basis_type_fixed AND
                c_rec.reference_period <> c_ref_period_base_year))
       AND NVL(l_ext_end_dt, l_term_date) > l_term_date
       AND NOT(l_terms_exist)
       THEN
               g_create_terms_ext_period := 'Y';
       END IF;


            put_log ('Creating Payment Terms');

            create_payment_terms (
               p_lease_id                    => c_rec.lease_id
              ,p_index_lease_id              => c_rec.index_lease_id
              ,p_location_id                 => c_rec.location_id
              ,p_purpose_code                => c_rec.purpose
              ,p_index_period_id             => c_rec.index_period_id
              ,p_term_template_id            => c_rec.term_template_id
              ,p_relationship                => c_rec.relationship
              ,p_assessment_date             => c_rec.assessment_date
              ,p_basis_amount                => v_basis_amount
              ,p_basis_percent_change        => c_rec.basis_percent_change
              ,p_spread_frequency            => c_rec.spread_frequency
              ,p_rounding_flag               => c_rec.rounding_flag
              ,p_index_amount                => v_constrained_rent_amount
              ,p_index_finder_type           => c_rec.index_finder_method
              ,p_basis_type                  => c_rec.basis_type
              ,p_basis_start_date            => c_rec.basis_start_date
              ,p_basis_end_date              => c_rec.basis_end_date
              ,p_increase_on                 => c_rec.increase_on
              ,p_negative_rent_type          => c_rec.negative_rent_type
              ,p_carry_forward_flag          => c_rec.carry_forward_flag
              ,p_calculate_date              => l_calculate_date
              ,p_prorate_factor              => l_prorate_factor
              ,op_msg                        => v_msg
            );

            put_log ('v_msg ' || v_msg);
            pn_index_lease_common_pkg.append_msg (
               p_new_msg                     => v_msg
              ,p_all_msg                     => v_period_msg
            );
            v_msg := NULL;

            op_current_basis := v_basis_amount;
            op_unconstraint_rent_due := v_uncontrained_index_amount;
            op_constraint_rent_due := v_constrained_rent_amount;
            op_index_percent_change := v_index_percent_change;
            op_current_index_line_id := v_current_cpi_id;
            op_current_index_line_value := v_current_cpi_value;
            op_previous_index_line_id := v_previous_cpi_id;
            op_previous_index_line_value := v_previous_cpi_value;
            op_previous_index_amount := v_constrained_rent_amount;
            op_previous_asmt_date := c_rec.assessment_date;
            op_constraint_applied_amount := v_constraint_applied_amount;
            op_carry_forward_amount := v_carry_forward_amount;
            op_constraint_applied_percent := v_constraint_applied_percent;
            op_carry_forward_percent := v_carry_forward_percent;

         ELSE
            op_current_basis := c_rec.current_basis;
            op_unconstraint_rent_due := c_rec.unconstraint_rent_due;
            op_constraint_rent_due := c_rec.constraint_rent_due;
            op_index_percent_change := c_rec.index_percent_change;
            op_current_index_line_id := c_rec.current_index_line_id;
            op_current_index_line_value := c_rec.current_index_line_value;
            op_previous_index_line_id := c_rec.previous_index_line_id;
            op_previous_index_line_value := c_rec.previous_index_line_value;
            op_previous_index_amount := c_rec.constraint_rent_due;
            op_previous_asmt_date := c_rec.assessment_date;
            op_constraint_applied_amount := c_rec.constraint_applied_amount;
            op_carry_forward_amount := c_rec.carry_forward_amount;
            op_constraint_applied_percent := c_rec.constraint_applied_percent;
            op_carry_forward_percent := c_rec.carry_forward_percent;

            v_msg := 'PN_INDEX_INDEX_AMOUNT_EXISTS';
            pn_index_lease_common_pkg.append_msg (
               p_new_msg                     => v_msg
              ,p_all_msg                     => v_period_msg
            );

         END IF; --C_REC.constraint_rent_due IS NULL

         pn_index_lease_common_pkg.append_msg (
            p_new_msg                     => v_period_msg
           ,p_all_msg                     => v_all_msg
         );
         v_period_msg := NULL;

         END IF;

         /* create terms for extended period */
        FOR l_rec IN get_lease_details(c_rec.lease_id) LOOP
            l_comm_date := l_rec.lease_commencement_date;
            l_term_date := l_rec.lease_termination_date;
            l_ext_end_dt := l_rec.lease_extension_end_date;
         END LOOP;

    IF (NVL(fnd_profile.value('PN_IR_TERM_END_DATE'),'LEASE_END') <> 'PERIOD_END' OR
       (c_rec.basis_type <> c_basis_type_fixed AND
        c_rec.reference_period <> c_ref_period_base_year))
    AND NVL(l_ext_end_dt, l_term_date) > l_term_date
    AND NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') ='END_LEASE'
    THEN
       FOR terms_rec IN get_extendable_terms(c_rec.index_period_id,l_term_date) LOOP
               l_term_rec := terms_rec;

               IF NVL(terms_rec.normalize,'N') = 'N' THEN

                  l_schd_date := pn_schedules_items.Get_Schedule_Date (
                                      p_lease_id   => c_rec.lease_id,
                                      p_day        => terms_rec.schedule_day,
                                      p_start_date => l_term_date + 1,
                                      p_end_date   => l_ext_end_dt,
                                      p_freq       => pn_schedules_items.get_frequency(terms_rec.frequency_code)
                                 );

                  l_schd_day  := TO_NUMBER(TO_CHAR(l_schd_date,'DD'));
                  IF l_schd_day <> terms_rec.schedule_day THEN
                     l_term_rec.start_date      := l_term_date + 1;
                     l_term_rec.end_date        := l_ext_end_dt;

                     pn_schedules_items.Insert_Payment_Term(
                        p_payment_term_rec   => l_term_rec,
                        x_return_status      => l_return_status,
                        x_return_message     => op_msg);

                  ELSE
                      UPDATE pn_payment_terms_all
                      SET end_date          = l_ext_end_dt,
                         last_update_date  = SYSDATE,
                         last_updated_by   = fnd_global.user_id,
                         last_update_login = fnd_global.login_id
                      WHERE payment_term_id = terms_rec.payment_term_id;
                  END IF;

               ELSE

                  l_term_rec.normalize := 'N';
                  l_term_rec.start_date := l_term_date + 1;
                  l_term_rec.end_date   := l_ext_end_dt;
                  l_term_rec.index_norm_flag := 'Y';
                  l_term_rec.parent_term_id  := terms_rec.payment_term_id;

                  pn_schedules_items.Insert_Payment_Term(
                     p_payment_term_rec   => l_term_rec,
                     x_return_status      => l_return_status,
                     x_return_message     => op_msg);

                END IF;
             END LOOP;

      END IF;


      END LOOP index_lease_period;

      fnd_message.set_name ('PN','PN_RICAL_MSG');
      put_output (fnd_message.get||' :');

      display_error_messages (ip_message_string => v_all_msg);
      op_msg := SUBSTR (v_all_msg, 1,   INSTR (   v_all_msg
                                                 || ',', ',')
                                 - 1);

      put_log('PN_INDEX_AMOUNT_PKG.calculate_period (-) PrvAmt: '||op_previous_index_amount
              ||', ConsAmt: '||op_constraint_applied_amount||', CFAmt: '||op_carry_forward_amount);

   END calculate_period;


------------------------------------------------------------------------
-- PROCEDURE : calculate
-- DESCRIPTION: This procedure will invoke the ff procedures:
--                 - Calculate Basis Amount
--                 - Calculate Index Percentage Change (if necessary)
--
-- HISTORY:
-- 23-OCT-03  ftanudja  o fixed msg logging logic.3209774
------------------------------------------------------------------------

   PROCEDURE calculate (
      ip_index_lease_id          IN       NUMBER
     ,ip_index_lease_period_id   IN       NUMBER
     ,ip_recalculate             IN       VARCHAR2
     ,ip_commit                  IN       VARCHAR2
     ,op_msg                     OUT NOCOPY      VARCHAR2
   ) IS
      v_basis_amount                NUMBER;
      v_index_percent_change        NUMBER;
      v_uncontrained_index_amount   NUMBER;
      v_all_msg                     VARCHAR2 (4000);
      v_period_msg                  VARCHAR2 (1000);
      v_p_constrained_rent_amount   NUMBER;
      v_prev_index_amount           NUMBER;
      v_prev_asmt_date              DATE;
      v_current_cpi_value           NUMBER;
      v_current_cpi_id              NUMBER;
      v_previous_cpi_value          NUMBER;
      v_previous_cpi_id             NUMBER;
      v_index_lease_id              NUMBER;
      v_index_period_id             NUMBER;
      v_lease_id                    NUMBER;
      v_constraint_applied_amount   pn_index_lease_periods.constraint_applied_amount%type;
      v_carry_forward_amount        pn_index_lease_periods.carry_forward_amount%type;
      v_constraint_applied_percent  pn_index_lease_periods.constraint_applied_percent%type;
      v_carry_forward_percent       pn_index_lease_periods.carry_forward_percent%type;
      v_initial_basis               pn_index_leases.initial_basis%type;
      v_retain_initial_basis_flag   pn_index_leases.retain_initial_basis_flag%type;
      v_msg                         VARCHAR2(1000);


      CURSOR c1 (
         p_index_lease_id   IN   NUMBER
      ) IS
         SELECT   pil.index_lease_id
                 ,pilp.index_period_id
                 ,pil.lease_id
                 ,pil.retain_initial_basis_flag
                 ,pil.initial_basis
             FROM pn_index_leases_all pil, pn_index_lease_periods_all pilp
            WHERE pil.index_lease_id = pilp.index_lease_id
              AND pil.index_lease_id = p_index_lease_id
         ORDER BY pilp.line_number;

      CURSOR c2 (
         p_index_lease_id          IN   NUMBER
        ,p_index_lease_period_id   IN   NUMBER
      ) IS
         SELECT   pil.index_lease_id
                 ,pilp.index_period_id
                 ,pil.lease_id
                 ,pil.retain_initial_basis_flag
                 ,pil.initial_basis
             FROM pn_index_leases_all pil, pn_index_lease_periods_all pilp
            WHERE pil.index_lease_id = pilp.index_lease_id
              AND pil.index_lease_id = p_index_lease_id
              AND pilp.index_period_id = p_index_lease_period_id
         ORDER BY pilp.line_number;


   BEGIN

      v_all_msg := 'PN_INDEX_SUCCESS';


     /* for performance reasons, one of two cursors can be executed..
        cursor c1 is need when all periods of an index rent is processed (IP_INDEX_PERIOD_ID IS NULL)
        cursor c2 is need when all an individual period is processed */


      IF ip_index_lease_period_id IS NULL THEN
         OPEN c1 (ip_index_lease_id);
      ELSE
         OPEN c2 (ip_index_lease_id, ip_index_lease_period_id);
      END IF;

      LOOP

         IF c1%ISOPEN THEN
            FETCH c1 INTO v_index_lease_id, v_index_period_id,v_lease_id,v_retain_initial_basis_flag,v_initial_basis;
            EXIT WHEN c1%NOTFOUND;
         ELSE
            FETCH c2 INTO v_index_lease_id, v_index_period_id,v_lease_id,v_retain_initial_basis_flag,v_initial_basis;
            EXIT WHEN c2%NOTFOUND;
         END IF;

      /* Check if retain initial basis flag is set, if not re-calculate initial_basis */

         IF (v_initial_basis IS NULL OR (NVL(v_retain_initial_basis_flag,'N')='N')) THEN
                calculate_initial_basis
                (
                p_index_lease_id => v_index_lease_id,
                op_basis_amount  => v_initial_basis,
                op_msg           => v_msg
                );

             IF v_msg IS NULL THEN
               UPDATE pn_index_leases_all
                  SET initial_basis = v_initial_basis
                     ,last_update_date = SYSDATE
                     ,last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0)
               WHERE index_lease_id = v_index_lease_id;
             END IF;
         END IF;

         calculate_period (
            ip_index_lease_id             => v_index_lease_id
           ,ip_index_lease_period_id      => v_index_period_id
           ,ip_recalculate                => ip_recalculate
           ,op_current_basis              => v_basis_amount
           ,op_unconstraint_rent_due      => v_uncontrained_index_amount
           ,op_constraint_rent_due        => v_p_constrained_rent_amount
           ,op_index_percent_change       => v_index_percent_change
           ,op_current_index_line_id      => v_current_cpi_id
           ,op_current_index_line_value   => v_current_cpi_value
           ,op_previous_index_line_id     => v_previous_cpi_id
           ,op_previous_index_line_value  => v_previous_cpi_value
           ,op_previous_index_amount      => v_prev_index_amount
           ,op_previous_asmt_date         => v_prev_asmt_date
           ,op_constraint_applied_amount  => v_constraint_applied_amount
           ,op_carry_forward_amount       => v_carry_forward_amount
           ,op_constraint_applied_percent => v_constraint_applied_percent
           ,op_carry_forward_percent      => v_carry_forward_percent
           ,op_msg                        => v_period_msg
         );

         pn_index_lease_common_pkg.append_msg (
            p_new_msg                     => v_period_msg
           ,p_all_msg                     => v_all_msg
         );

         UPDATE pn_index_lease_periods_all
            SET current_basis = v_basis_amount
               ,unconstraint_rent_due = v_uncontrained_index_amount
               ,constraint_rent_due = v_p_constrained_rent_amount
               ,index_percent_change = v_index_percent_change
               ,current_index_line_id = v_current_cpi_id
               ,current_index_line_value = v_current_cpi_value
               ,previous_index_line_id = v_previous_cpi_id
               ,previous_index_line_value = v_previous_cpi_value
               ,constraint_applied_amount = v_constraint_applied_amount
               ,carry_forward_amount = v_carry_forward_amount
               ,constraint_applied_percent = v_constraint_applied_percent
               ,carry_forward_percent = v_carry_forward_percent
               ,last_update_date = SYSDATE
               ,last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0)
          WHERE index_period_id = v_index_period_id;


         v_prev_index_amount := v_p_constrained_rent_amount;

      END LOOP index_lease;

      IF ip_index_lease_period_id IS NULL THEN
         CLOSE c1;
      ELSE
         CLOSE c2;
      END IF;


     /*  only passback the first message.*/

      op_msg := SUBSTR (v_all_msg, 1,INSTR (   v_all_msg|| ',', ',')- 1);


    /* Issue COMMIT if required by calling program.
       Primarily used by index rent form.
       To avoid multiple save message appearing on the form. */

     IF NVL (ip_commit, 'N') = 'Y' THEN
        COMMIT;
     END IF;


  END calculate;


-------------------------------------------------------------------------------
-- PROCEDURE   : calculate_batch
-- DESCRIPTION : This procedure is used by concurrent process that will
--               allow users to choose on or more index leases to calculate and
--               index rent amount for.
-- HISTORY
-- 25-MAR-04 ftanudja o Fixed csr il_recs p_location_code logic.
-- 09-MAR-05 ftanudja o Used profile option 'PN_RECALC_INDEX_RENT'
--                      for recalculate logic. #4212326.
-- 15-SEP-05 pikhar   o replaced fnd_profile.value(PN_RECALC_INDEX_RENT)
--                      with pn_mo_cache_utils.get_profile_value
-- 25-NOV-05 pikhar   o Replaced pn_locations_all with pn_locations
-- 15-DEC-05 pikhar   o replaced get_profile_value(PN_RECALC_INDEX_RENT) with
--                      get_profile_value('RECALC_IR_ON_ACC_CHG_FLAG'
-------------------------------------------------------------------------------

   PROCEDURE calculate_batch (
      errbuf                        OUT NOCOPY      VARCHAR2
     ,retcode                       OUT NOCOPY      VARCHAR2
     ,ip_index_lease_number_lower   IN       VARCHAR2
     ,ip_index_lease_number_upper   IN       VARCHAR2
     ,ip_assessment_date_lower      IN       VARCHAR2
     ,ip_assessment_date_upper      IN       VARCHAR2
     ,ip_lease_class                IN       VARCHAR2
     ,ip_main_lease_number          IN       VARCHAR2
     ,ip_location_code              IN       VARCHAR2
     ,ip_user_responsible           IN       VARCHAR2
     ,ip_recalculate                IN       VARCHAR2
   ) IS
      CURSOR il_recs (
         p_index_rent_number_lower   IN   VARCHAR2
        ,p_index_rent_number_upper   IN   VARCHAR2
        ,p_assessment_date_lower     IN   VARCHAR2
        ,p_assessment_date_upper     IN   VARCHAR2
        ,p_lease_class               IN   VARCHAR2
        ,p_main_lease_number         IN   VARCHAR2
        ,p_location_code             IN   VARCHAR2
        ,p_user_responsible          IN   VARCHAR2
        ) IS
         SELECT pil.index_lease_id
               ,pilp.index_period_id
               ,pl.lease_class_code
               ,pl.lease_num
               ,pil.abstracted_by
               ,pil.location_id
               ,pilp.assessment_date
               ,pil.index_lease_number
               ,pil.term_template_id
               ,pil.org_id
           FROM pn_leases_all pl, pn_index_leases pil, pn_index_lease_periods_all pilp
          WHERE pl.lease_id = pil.lease_id
            AND pil.index_lease_id = pilp.index_lease_id
            AND (pil.index_lease_number >= nvl(p_index_rent_number_lower,pil.index_lease_number))
            AND (pil.index_lease_number <= nvl(p_index_rent_number_upper,pil.index_lease_number))
            AND (pl.lease_num = nvl(p_main_lease_number,pl.lease_num))
            AND (pilp.assessment_date >= nvl(p_assessment_date_lower,pilp.assessment_date))
            AND ((nvl(pil.carry_forward_flag,'N') = 'N' and
                    pilp.assessment_date <= nvl(p_assessment_date_upper,pilp.assessment_date)) OR
                 (nvl(pil.carry_forward_flag,'N') in ('A','P') and
                  pilp.assessment_date <= nvl(get_max_assessment_dt(pil.index_lease_id,p_assessment_date_upper),
                                          pilp.assessment_date))
                )
            AND (pl.lease_class_code = nvl(p_lease_class,pl.lease_class_code))
            AND (p_location_code is null OR pil.location_id IN
                 (SELECT location_id FROM pn_locations
                  START WITH location_code = p_location_code
                  CONNECT BY PRIOR location_id = parent_location_id)
                )
            AND (pil.abstracted_by = p_user_responsible OR
                 p_user_responsible is null);

      v_msg                 VARCHAR2 (1000);
      l_pre_index_lease_id  NUMBER;
      l_err_flag            VARCHAR2(1);
      l_recalculate         VARCHAR2(1);
   BEGIN

      put_log('ip_index_lease_number_lower    '|| ip_index_lease_number_lower);
      put_log('ip_index_lease_number_upper    '|| ip_index_lease_number_upper);
      put_log('ip_assessment_date_lower  '     || ip_assessment_date_lower);
      put_log('ip_assessment_date_upper  '     || ip_assessment_date_upper);
      put_log('ip_lease_class          '       || ip_lease_class);
      put_log('ip_main_lease_number    '       || ip_main_lease_number);
      put_log('ip_location_id          '       || ip_location_code);
      put_log('ip_user_responsible     '       || ip_user_responsible);
      put_log('ip_recalculate          '       || ip_recalculate);
      put_log('Processing the Following Lease Periods:');


      FOR il_rec IN il_recs (
                       ip_index_lease_number_lower
                      ,ip_index_lease_number_upper
                      ,fnd_date.canonical_to_date(ip_assessment_date_lower)
                      ,fnd_date.canonical_to_date(ip_assessment_date_upper)
                      ,ip_lease_class
                      ,ip_main_lease_number
                      ,ip_location_code
                      ,ip_user_responsible --,ip_recalculate
                    )
      LOOP

         put_log( 'Lease ID: '|| il_rec.index_lease_id|| ' Period ID: '|| il_rec.index_period_id);

         IF il_rec.index_lease_id <> NVL(l_pre_index_lease_id,-9999) THEN
          l_err_flag := 'N';
          l_pre_index_lease_id := il_rec.index_lease_id;

          IF il_rec.term_template_id IS NOT NULL AND
             NOT pnp_util_func.validate_term_template(p_term_temp_id   => il_rec.term_template_id,
                                                      p_lease_cls_code => il_rec.lease_class_code) THEN

             l_err_flag := 'Y';
             fnd_message.set_name ('PN', 'PN_MISS_TERM_TEMP_DATA');
             put_output(fnd_message.get);
          END IF;
       END IF;

       IF nvl(pn_mo_cache_utils.get_profile_value('RECALC_IR_ON_ACC_CHG_FLAG',il_rec.org_id),'Y') = 'N' THEN
          l_recalculate := 'N';
       ELSE
          l_recalculate := ip_recalculate;
       END IF;

       IF l_err_flag = 'N' THEN
         calculate (
            ip_index_lease_id             => il_rec.index_lease_id
           ,ip_index_lease_period_id      => il_rec.index_period_id
           ,ip_recalculate                => l_recalculate
           ,op_msg                        => v_msg
         );
      END IF;

      END LOOP index_lease_period;

   END calculate_batch;

-------------------------------------------------------------------------------
-- PROCEDURE : update_index_hist_line
-- DESCRIPTION: This procedure is by the index history window any time index
--             history line is updated.
--
-------------------------------------------------------------------------------
   PROCEDURE update_index_hist_line (
      ip_index_history_line_id   IN       NUMBER
     ,ip_recalculate             IN       VARCHAR2
     ,op_msg                     OUT NOCOPY      VARCHAR2
   ) IS
      CURSOR index_periods (
         p_index_history_line_id   IN   NUMBER
      ) IS
         SELECT pilp.index_lease_id
               ,pilp.index_period_id
           FROM pn_index_lease_periods_all pilp
          WHERE (   pilp.previous_index_line_id = p_index_history_line_id
                 OR pilp.current_index_line_id = p_index_history_line_id
                );

      v_msg   VARCHAR2 (1000);
   BEGIN
      v_msg := 'PN_NEW_INDEX_HIST_SUCCESS';

      --op_msg := v_msg;



      --
      -- pick index periods the that use the index_history_line_id
      -- either as current or previous index rent
      --
      <<index_rent_periods>>
      FOR ilp_rec IN index_periods (ip_index_history_line_id)
      LOOP
         --put_log (
         --   'Lease ID: '|| ilp_rec.index_lease_id || '   Period ID: ' || ilp_rec.index_period_id);

         --
         -- calculate index rent for this index rent period
         --
         calculate (
            ip_index_lease_id             => ilp_rec.index_lease_id
           ,ip_index_lease_period_id      => ilp_rec.index_period_id
           ,ip_recalculate                => ip_recalculate
           ,op_msg                        => v_msg
         );
      END LOOP index_rent_periods; --ilp_pay_rec
   END update_index_hist_line;


-------------------------------------------------------------------------------
-- PROCEDURE : update_index_hist_line_batch
-- DESCRIPTION: This procedure is used by the index history window any time index
--             history line is updated.  It will be submitted as a batch program
--             by the form.
--
-- 02-MAR-2007  Hareesha  o Bug #5909546 When the Base-index is updated in the
--                          index-history, update the base-index of impacted
--                          RI agreements.
-- 02-MAY-2007  Prabhakar o Bug #6027113. When Index History is modified,
--                          only the base index of the impacted RI agreement
--                          will be updated by checking the base_year and
--                          modified index_date.
-------------------------------------------------------------------------------
   PROCEDURE update_index_hist_line_batch (
      errbuf                OUT NOCOPY      VARCHAR2
     ,retcode               OUT NOCOPY      VARCHAR2
     ,ip_index_history_id   IN       NUMBER
     ,ip_recalculate        IN       VARCHAR2
   ) IS
      CURSOR index_hist_lines_modified (
         p_index_history_id   IN   NUMBER
      ) IS
         SELECT pihl.index_line_id
               ,pihl.index_figure
	       ,pihl.index_date
           FROM pn_index_history_lines pihl
          WHERE pihl.updated_flag = 'Y'
            AND pihl.index_id = p_index_history_id;

      CURSOR index_periods (
         p_index_history_line_id   IN   NUMBER
      ) IS
         SELECT pilp.index_lease_id
               ,pilp.index_period_id
               ,pilp.previous_index_line_id
               ,pilp.current_index_line_id
               ,pilp.current_index_line_value
               ,pilp.previous_index_line_value
               ,pilp.constraint_rent_due
           FROM pn_index_lease_periods_all pilp
          WHERE (   pilp.previous_index_line_id = p_index_history_line_id
                 OR pilp.current_index_line_id = p_index_history_line_id
                );

      v_msg                    VARCHAR2 (1000);
      v_current_cpi_value      NUMBER;
      v_previous_cpi_value     NUMBER;
      v_index_percent_change   NUMBER := null;   --  #Bug2102073
      v_new_index_figure       pn_index_history_lines.index_figure%TYPE;
      v_updated_index_date     pn_index_history_lines.index_date%TYPE;

   BEGIN
      put_log (   'ip_index_history_line_id     '
               || ip_index_history_id);
      put_log (   'ip_recalculate          '
               || ip_recalculate);
      v_msg := 'PN_NEW_INDEX_HIST_SUCCESS';

      --
      -- get all index history line that have been updated
      --
      <<index_history_lines>>
      FOR ihl_rec IN index_hist_lines_modified (ip_index_history_id)
      LOOP
         v_new_index_figure := ihl_rec.index_figure;
	 v_updated_index_date := ihl_rec.index_date;

         --
         -- get index period lines that use the current index history line
         --
         <<index_rent_periods>>
         FOR ilp_rec IN index_periods (ihl_rec.index_line_id)
         LOOP
            put_log (
                  'Lease ID: '
               || ilp_rec.index_lease_id
               || '   Period ID: '
               || ilp_rec.index_period_id
               || '   Value: '
               || ihl_rec.index_figure
            );

            --
            -- checking which index value (current or previous) is going to be updated
            --

            -- for each period found,
            --  check if previous or current is being updated by looking at the
            --  id field.
            --  if it's being updated, then

            --
            -- check if the current cpi value is being updated
            --    if not, use existing value as cpi..

            IF ilp_rec.current_index_line_id = ihl_rec.index_line_id THEN
               v_current_cpi_value := v_new_index_figure;
            ELSE
               v_current_cpi_value := ilp_rec.current_index_line_value;
            END IF; --ilp_rec.current_index_line_id = ihl_rec.index_line_id

            --
            -- check if the previous cpi value is being updated
            --    if not, use existing value as cpi..

            IF ilp_rec.previous_index_line_id = ihl_rec.index_line_id THEN
               v_previous_cpi_value := v_new_index_figure;
            ELSE
               v_previous_cpi_value := ilp_rec.previous_index_line_value;
            END IF; --ilp_rec.previous_index_line_id = ihl_rec.index_line_id

            --
            -- if we have a current and  previous cpi value, calculate a new index change percentag
            --

            IF      v_current_cpi_value IS NOT NULL
                AND v_previous_cpi_value IS NOT NULL THEN
               v_index_percent_change := ROUND (
                                              (  v_current_cpi_value
                                               - v_previous_cpi_value
                                              )
                                            / v_previous_cpi_value
                                            * 100
                                           ,2
                                         );
            END IF;

            --
            -- update the current index period record only if:
            --     contrained rent is null
            --     OR recalculate is set yes
            --

            IF    ilp_rec.constraint_rent_due IS NULL
               OR NVL (ip_recalculate, 'N') = 'Y' THEN
               UPDATE pn_index_lease_periods_all
                  SET index_percent_change = v_index_percent_change
                     ,current_index_line_value = v_current_cpi_value
                     ,previous_index_line_value = v_previous_cpi_value
                WHERE index_period_id = ilp_rec.index_period_id;
            END IF;
                        v_index_percent_change := null;   -- Bug #2102073
            --
            -- calculate index rent for this index rent period
            --

            calculate (
               ip_index_lease_id             => ilp_rec.index_lease_id
              ,ip_index_lease_period_id      => ilp_rec.index_period_id
              ,ip_recalculate                => ip_recalculate
              ,op_msg                        => v_msg
            );

            UPDATE pn_index_leases_all
            SET base_index = v_new_index_figure
            WHERE index_lease_id = ilp_rec.index_lease_id
	    AND base_year = v_updated_index_date;

         END LOOP index_rent_periods; --ilp_pay_rec

         --
         -- null out NOCOPY the update flag of history line
         -- this column is always updated by the index history
         -- form every time a record is updated.
         --
         UPDATE pn_index_history_lines
            SET updated_flag = NULL
          WHERE index_line_id = ihl_rec.index_line_id;

      END LOOP index_history_lines;
   END update_index_hist_line_batch;


-------------------------------------------------------------------------------
-- PROCEDURE : approve_index_pay_term
-- DESCRIPTION: This procedure is called every time a index rent payment is term
--              is approved.
-- 09-Jul-01  psidhu o Added parameters err_msg and err_code to
--                     pn_schedules.schedules_items.
-- 14-AUG-06  pikhar o Conver the value of include_in_var_rent to NULL if it is
--                     not equal to INCLUDE_RI
-------------------------------------------------------------------------------

   PROCEDURE approve_index_pay_term (ip_lease_id            IN          NUMBER
                                    ,ip_index_pay_term_id   IN          NUMBER
                                    ,op_msg                 OUT NOCOPY  VARCHAR2
                                    ) IS
      v_msg                  VARCHAR2(1000);
      err_msg                VARCHAR2(2000);
      err_code               VARCHAR2(2000);
      l_include_in_var_rent  VARCHAR2(30);

   BEGIN
      pn_index_lease_common_pkg.chk_for_payment_reqd_fields (
         p_payment_term_id             => ip_index_pay_term_id
        ,p_msg                         => v_msg
      );

      IF v_msg IS NULL THEN
         v_msg := 'PN_INDEX_APPROVE_SUCCESS';
         --
         -- call api to create schedules and items
         --

         pn_schedules_items.schedules_items (
            errbuf                        => err_msg
           ,retcode                       => err_code
           ,p_lease_id                    => ip_lease_id
           ,p_lease_context               => 'ADD'
           ,p_called_from                 => 'IND'
           ,p_term_id                     => ip_index_pay_term_id
           ,p_term_end_dt                 => NULL
         );

         --
         -- update status of payment term record
         --

         select include_in_var_rent
         into l_include_in_var_rent
         from pn_payment_terms_all
         where payment_term_id = ip_index_pay_term_id;

         IF l_include_in_var_rent = 'INCLUDE_RI' THEN
            /* NBPs need to be recalculated */
            update pn_payment_terms_all
            set update_nbp_flag = 'Y'
            where payment_term_id = ip_index_pay_term_id;
         ELSE
            l_include_in_var_rent := NULL;
         END IF;


         UPDATE pn_payment_terms_all
            SET status = c_payment_term_status_approved
               ,include_in_var_rent = l_include_in_var_rent
               ,last_update_date = SYSDATE
               ,last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0)
               ,approved_by = NVL (fnd_profile.VALUE ('USER_ID'), 0)
          WHERE payment_term_id = ip_index_pay_term_id;

         --
         -- update status of records in pn_index_lease_terms
         --
         UPDATE pn_index_lease_terms_all
            SET APPROVED_FLAG = c_payment_term_status_approved
               ,last_update_date = SYSDATE
               ,last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0)
          WHERE rent_increase_term_id = ip_index_pay_term_id;
      END IF;

      op_msg := v_msg;
   END approve_index_pay_term;


-------------------------------------------------------------------------------
-- PROCEDURE : approve_index_pay_term_batch
-- DESCRIPTION: This procedure is called by the mass index payment term
--              approval concurrent index program.
--
-- NOTES: how the parameter ip_auto_find_sch_day plays a role when
--        approved schedules exist
--
-- IF ip_auto_find_sch_day = 'Y' :
--  a) record current schedule day => N
--  b) find next available schedule day => X
--  c) if found:
--       update term sch day to X
--       generate schedules and items
--       update item transaction date to N
--     else:
--       error
-- ELSE
--   error
--
-- 20-Feb-2002  Pooja Sidhu o Added code to approve a payment term only if
--                            main lease is in the final status. Fix for
--                            bug# 2215729.
-- 21-Feb-2002  Pooja Sidhu o Added check to approve a payment term if schedule
--                            day of payment term does not overlap with an existing
--                            approved schedule by calling procedure
--                            pnt_payment_terms_pkg.check_approved_schedule_exists.
--                            Fix for bug# 2235148.
-- 13-Jul-2004  ftanudja    o Added parameter ip_auto_find_sch_day. #3701195.
-- 18-Jan-2005  ftanudja    o Added batch commit capability. #4081821.
-- 19-Jan-2005  ftanudja    o Fixed il_recs CSR for range queries. #4129147.
-- 25-Nov-2005  pikhar      o Replaced pn_index_leases_all with pn_index_leases
-- 09-JAN-07    lbala       o Removed call to get_schedule_date and auto creation
--                            of shedules for M28 item# 11
-------------------------------------------------------------------------------

   PROCEDURE approve_index_pay_term_batch (
      errbuf                        OUT NOCOPY      VARCHAR2
     ,retcode                       OUT NOCOPY      VARCHAR2
     ,ip_index_lease_number_lower   IN       VARCHAR2
     ,ip_index_lease_number_upper   IN       VARCHAR2
     ,ip_assessment_date_lower      IN       VARCHAR2
     ,ip_assessment_date_upper      IN       VARCHAR2
     ,ip_lease_class                IN       VARCHAR2
     ,ip_main_lease_number_lower    IN       VARCHAR2
     ,ip_main_lease_number_upper    IN       VARCHAR2
     ,ip_location_code              IN       VARCHAR2
     ,ip_user_responsible           IN       VARCHAR2
     ,ip_payment_start_date_lower   IN       VARCHAR2
     ,ip_payment_start_date_upper   IN       VARCHAR2
     ,ip_approve_normalize_only     IN       VARCHAR2
     ,ip_index_period_id            IN       VARCHAR2
     ,ip_payment_status             IN       VARCHAR2
     ,ip_auto_find_sch_day          IN       VARCHAR2
   ) IS

      v_msg                   VARCHAR2 (1000);
      v_counter               NUMBER          := 0;
      l_errmsg                VARCHAR2(2000);
      l_errmsg1               VARCHAR2(2000);
      l_return_status         VARCHAR2 (2) := NULL;
      l_nxt_schdate           DATE;
      l_day                   pn_payment_terms.schedule_day%TYPE;
      l_info                  VARCHAR2(1000);
      l_message               VARCHAR2(2000) := NULL;
      l_appr_count            NUMBER := 0;
      l_batch_size            NUMBER := 1000;
      l_errbuf                VARCHAR2(80);
      l_retcode               VARCHAR2(80);
      l_update_nbp_flag       VARCHAR2(1);
      l_dummy                 VARCHAR2(1);
      l_var_rent_id           NUMBER;

      CURSOR il_recs (
         p_index_rent_number_lower    IN   VARCHAR2
        ,p_index_rent_number_upper    IN   VARCHAR2
        ,p_assessment_date_lower      IN   VARCHAR2
        ,p_assessment_date_upper      IN   VARCHAR2
        ,p_lease_class                IN   VARCHAR2
        ,p_main_lease_number_lower    IN   VARCHAR2
        ,p_main_lease_number_upper    IN   VARCHAR2
        ,p_location_code              IN   VARCHAR2
        ,p_user_responsible           IN   VARCHAR2
        ,p_payment_start_date_lower   IN   VARCHAR2
        ,p_payment_start_date_upper   IN   VARCHAR2
        ,p_approve_normalize_only     IN   VARCHAR2
        ,p_index_period_id            IN   NUMBER
        ,p_payment_status             IN   VARCHAR2
      ) IS
         SELECT pil.lease_id
               ,pil.index_lease_id
               ,pilp.index_period_id
               ,ppt.payment_term_id
               ,pl.lease_class_code
               ,pl.lease_num
               ,pl.status lease_status
               ,pil.index_lease_number
               ,pil.abstracted_by
               ,pil.location_id
               ,pilp.assessment_date
               ,pilp.line_number
               ,ppt.start_date
               ,ppt.actual_amount
               ,ppt.frequency_code
               ,ppt.end_date
               ,ppt.index_term_indicator
               ,ppt.status
               ,DECODE (ppt.normalize, 'Y', 'NORMALIZE') "NORMALIZE"
               ,ppt.schedule_day
           FROM pn_leases_all pl
               ,pn_index_leases pil
               ,pn_index_lease_periods_all pilp
               ,pn_payment_terms_all ppt
          WHERE pl.lease_id = pil.lease_id
            AND pil.index_lease_id = pilp.index_lease_id
            AND pilp.index_period_id = ppt.index_period_id
            AND (pilp.index_period_id = p_index_period_id
                 OR p_index_period_id IS NULL)
            AND (pil.index_lease_number BETWEEN
                 nvl(p_index_rent_number_lower, pil.index_lease_number) AND
                 nvl(p_index_rent_number_upper, pil.index_lease_number))
            AND (pl.lease_num BETWEEN
                 nvl(p_main_lease_number_lower, pl.lease_num) AND
                 nvl(p_main_lease_number_upper, pl.lease_num))
            AND (pilp.assessment_date BETWEEN
                 nvl(fnd_date.canonical_to_date (p_assessment_date_lower), pilp.assessment_date) AND
                 nvl(fnd_date.canonical_to_date (p_assessment_date_upper), pilp.assessment_date))
            AND (pl.lease_class_code = p_lease_class
                 OR p_lease_class IS NULL)
            AND (pil.location_id = p_location_code
                 OR p_location_code IS NULL)
            AND (pil.abstracted_by = p_user_responsible
                 OR p_user_responsible IS NULL)
            AND (ppt.start_date BETWEEN
                 nvl(fnd_date.canonical_to_date (p_payment_start_date_lower), ppt.start_date) AND
                 nvl(fnd_date.canonical_to_date (p_payment_start_date_upper), ppt.start_date))
            AND ((p_approve_normalize_only = 'Y'
                  AND NVL (ppt.normalize, 'N') = 'Y')
                  OR p_approve_normalize_only = 'N')
            AND ppt.status = p_payment_status;


      CURSOR var_cur(p1_lease_id IN NUMBER)
      IS
         SELECT var_rent_id
         FROM pn_var_rents_all
         WHERE lease_id = p1_lease_id;

      CURSOR terms_cur (p1_lease_id IN NUMBER)
      IS
         SELECT UPDATE_NBP_FLAG
         FROM PN_PAYMENT_TERMS_ALL
         WHERE lease_id = p1_lease_id
         FOR UPDATE NOWAIT;

      CURSOR bkhd_exists_cur
      IS
         select 'x'
         FROM DUAL
         where exists (select BKHD_DEFAULT_ID
                       from pn_var_bkpts_head_all
                       where period_id IN (select PERIOD_ID
                                           FROM pn_var_periods_all
                                           where VAR_RENT_ID = l_var_rent_id)
                       AND BKHD_DEFAULT_ID IS NOT NULL);

   BEGIN
      put_log('pn_index_amount_pkg.approve_index_pay_term_batch (+) : ');

      put_log ('ip_index_lease_number_lower    '|| ip_index_lease_number_lower);
      put_log ('ip_index_lease_number_upper    '|| ip_index_lease_number_upper);
      put_log ('ip_assessment_date_lower  '     || ip_assessment_date_lower);
      put_log ('ip_assessment_date_upper  '     || ip_assessment_date_upper);
      put_log ('ip_lease_class          '       || ip_lease_class);
      put_log ('ip_main_lease_number_lower    ' || ip_main_lease_number_lower);
      put_log ('ip_main_lease_number_upper    ' || ip_main_lease_number_upper);
      put_log ('ip_location_id          '       || ip_location_code);
      put_log ('ip_user_responsible     '       || ip_user_responsible);
      put_log ('ip_payment_start_date_lower  '  || ip_payment_start_date_lower);
      put_log ('ip_payment_start_date_upper  '  || ip_payment_start_date_upper);
      put_log ('ip_approve_normalize_only  '    || ip_approve_normalize_only);
      put_log ('ip_index_period_id  '           || ip_index_period_id);
      put_log ('ip_payment_status  '            || ip_payment_status);
      put_log ('Processing the Following Lease Periods:');

      /* get all index rent payment terms to process */

      FOR il_rec IN il_recs (
                       ip_index_lease_number_lower
                      ,ip_index_lease_number_upper
                      ,ip_assessment_date_lower
                      ,ip_assessment_date_upper
                      ,ip_lease_class
                      ,ip_main_lease_number_lower
                      ,ip_main_lease_number_upper
                      ,ip_location_code
                      ,ip_user_responsible
                      ,ip_payment_start_date_lower
                      ,ip_payment_start_date_upper
                      ,ip_approve_normalize_only
                      ,ip_index_period_id
                      ,ip_payment_status
                    )
      LOOP
         v_counter :=   v_counter  +  1;

         put_output ('****************************************');
         fnd_message.set_name ('PN','PN_RICAL_PROC');
         put_output(fnd_message.get||'...');
         fnd_message.set_name ('PN','PN_RICAL_LSNO');
         fnd_message.set_token ('NUM', il_rec.index_lease_number);
         put_output(fnd_message.get);
         fnd_message.set_name ('PN','PN_RICAL_LS_PRD');
         fnd_message.set_token ('NUM', il_rec.line_number);
         fnd_message.set_token ('ID', il_rec.index_period_id);
         put_output(fnd_message.get);
         fnd_message.set_name ('PN','PN_RICAL_ASS_DATE');
         fnd_message.set_token ('DATE', il_rec.assessment_date);
         put_output(fnd_message.get);
         put_output ('****************************************');

         /* if main lease is in draft status disallow approval */

         IF nvl(il_rec.lease_status,'D') = 'D' THEN
            fnd_message.set_name('PN','PN_NO_APPR_TERM');
            l_errmsg := fnd_message.get;
            put_output('+----------------------------------------------------------+');
            put_output(l_errmsg);
            put_output('+----------------------------------------------------------+');
         ELSE

               l_info := ' approving payment term ID: '||il_rec.payment_term_id||' ';
               approve_index_pay_term (
                   ip_lease_id                   => il_rec.lease_id
                  ,ip_index_pay_term_id          => il_rec.payment_term_id
                  ,op_msg                        => v_msg);


                --Recalculate Natural Breakpoint if any changes in Lease Payment Terms

                l_update_nbp_flag := NULL;
                l_dummy           := NULL;
                FOR terms_rec IN terms_cur(p1_lease_id => il_rec.lease_id)
                LOOP
                   IF terms_rec.UPDATE_NBP_FLAG = 'Y' THEN
                      l_update_nbp_flag := 'Y';
                      EXIT;
                   END IF;
                END LOOP;

                IF l_update_nbp_flag = 'Y' THEN
                   FOR var_rec in var_cur(p1_lease_id => il_rec.lease_id)
                   LOOP

                      l_var_rent_id := var_rec.var_rent_id;

                      OPEN bkhd_exists_cur;
                      FETCH bkhd_exists_cur INTO l_dummy;
                      CLOSE bkhd_exists_cur;

                      pn_var_natural_bp_pkg.build_bkpt_details_main(errbuf        => l_errbuf,
                                                                    retcode       => l_retcode,
                                                                    p_var_rent_id => var_rec.var_rent_id);

                      IF l_dummy IS NOT NULL THEN
                         pn_var_defaults_pkg.create_setup_data (x_var_rent_id => var_rec.var_rent_id);
                      END IF;

                      pnp_debug_pkg.log('Updated Natural Breakpoints for VR - '||var_rec.var_rent_id);


                   END LOOP;

                   UPDATE pn_payment_terms_all
                   SET UPDATE_NBP_FLAG = NULL
                   WHERE lease_id = il_rec.lease_id;



                END IF;

                -- Finished Recalculating Natural Breakpoint if any changes in Lease Payment Terms

         END IF;  --nvl(il_rec.lease_status,'D') = 'D'

         l_message := NULL;
         fnd_message.set_name ('PN','PN_RICAL_PAYMENT');
         l_message := '         '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_START');
         l_message := l_message||'      '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_END');
         l_message := l_message||'        '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_PAYMENT');
         l_message := l_message||'                     '||fnd_message.get;
         /*fnd_message.set_name ('PN','PN_RICAL_INDEX');
         l_message := l_message||'                        '||fnd_message.get; */
         fnd_message.set_name ('PN','PN_RICAL_NORZ');
         l_message := l_message||'                          '||fnd_message.get;
         put_output(l_message);

         l_message := NULL;

         fnd_message.set_name ('PN','PN_RICAL_FREQ');
         l_message := '         '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_DATE');
         l_message := l_message||'    '||fnd_message.get;
	 fnd_message.set_name ('PN','PN_RICAL_DATE');
         l_message := l_message||'         '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_AMT');
         l_message := l_message||'       '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_STATUS');
         l_message := l_message||'       '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_PAYMENT_TYPE');
         l_message := l_message||'      '||fnd_message.get;
        /* fnd_message.set_name ('PN','PN_RICAL_YES_NO');
         l_message := l_message||'       '||fnd_message.get;*/
         put_output(l_message);

         put_output (
         '         ---------  -----------  -----------  ----------  -----------  ------------------  ------------'
                    );
         put_output ('.         ');
         put_output (
               LPAD (il_rec.frequency_code, 18, ' ')
            || LPAD (il_rec.start_date, 13, ' ')
            || LPAD (il_rec.end_date, 13, ' ')
            || LPAD (format (il_rec.actual_amount, 2), 12, ' ')
            || LPAD (il_rec.status, 13, ' ')
            || LPAD (il_rec.index_term_indicator, 20, ' ')
            || LPAD (il_rec.NORMALIZE, 11, ' '));
         put_output ('.         ');
         display_error_messages (ip_message_string => v_msg);

      END LOOP;

      IF v_counter = 0 THEN
         fnd_message.set_name ('PN','PN_RICAL_MSG');
         put_output (fnd_message.get||' :');
         display_error_messages (ip_message_string => 'PN_INDEX_NO_PAYT_TO_APPROVE');
      END IF;



      put_log('pn_index_amount_pkg.approve_index_pay_term_batch (-) : ');

   END approve_index_pay_term_batch;


-------------------------------------------------------------------------------
-- PROCEDURE  : process_currency_code
-- DESCRIPTION: This procedure is called by the index rent form
--              when the currency_code field is changed. Fix for
--              bug# 2452909.
--
-------------------------------------------------------------------------------

   PROCEDURE process_currency_code (p_index_lease_id in number) IS
   l_msg1 varchar2(1000);
   l_msg2 varchar2(1000);

   BEGIN

    /* Delete from table pn_index_exclude_term */

     Delete pn_index_exclude_term_all
     where index_lease_id = p_index_lease_id;

    /* undo the periods */

     pn_index_rent_periods_pkg.undo_periods(
         p_index_lease_id => p_index_lease_id,
         p_msg => l_msg1);

    /* generate periods */

     pn_index_rent_periods_pkg.generate_periods(
         ip_index_lease_id => p_index_lease_id,
         op_msg => l_msg2);


   EXCEPTION
   when others then
   put_log('Error in pn_index_amount_pkg.process_currency_code :'||to_char(sqlcode)||' : '||sqlerrm);
   raise;

END process_currency_code;


-------------------------------------------------------------------------------
-- PROCEDURE  : derive_cum_carry_forward
-- DESCRIPTION: Derive the value of the column carry_forward_amount and
--              carry_forward_percent of the period prior to the current period.
--
-------------------------------------------------------------------------------
  PROCEDURE derive_cum_carry_forward (
      p_index_lease_id    IN       NUMBER,
      p_assessment_date   IN       DATE,
      op_carry_forward_amount OUT NOCOPY NUMBER,
      op_carry_forward_percent OUT NOCOPY NUMBER) IS
  CURSOR csr_cum_carry_for IS
  SELECT pilp.carry_forward_amount,
         pilp.carry_forward_percent
  FROM pn_index_lease_periods_all pilp
  WHERE pilp.index_lease_id = p_index_lease_id
  AND pilp.assessment_date = (SELECT MAX (pilp.assessment_date)
                              FROM pn_index_lease_periods_all pilp
                              WHERE pilp.index_lease_id = p_index_lease_id
                              AND   pilp.assessment_date < p_assessment_date);

  BEGIN

  put_log ('pn_index_amount_pkg.derive_cum_carry_forward   (+) : ');

  OPEN csr_cum_carry_for;
  FETCH csr_cum_carry_for into op_carry_forward_amount,op_carry_forward_percent;
  CLOSE csr_cum_carry_for;

  put_log ('pn_index_amount_pkg.derive_cum_carry_forward   (-) :');

  EXCEPTION
  WHEN OTHERS then
  put_log ('derive_cum_carry_forward : Unable to derive previous periods carry forward amount :'
            || SQLERRM);


  END derive_cum_carry_forward;

  -----------------------------------------------------------------------------
  -- FUNCTION   : derive_prev_negative_rent
  -- DESCRIPTION: If the negative rent option for the index rent agreement
  --              is 'NEXT PERIOD' for the current period derive the negative
  --              unconstrained rent amounts of the previous periods.
  --
  --  17-APR-2007  Prabhakar o Bug : #5988076. The derivation of previous
  --                           negative rent was corrected.( see the Note.)
  --
  -----------------------------------------------------------------------------

 FUNCTION derive_prev_negative_rent (
      p_index_lease_id    IN       NUMBER
     ,p_assessment_date   IN       DATE)
  RETURN number
  IS
  CURSOR csr_negative_rent IS
  SELECT unconstraint_rent_due, constraint_rent_due
  FROM pn_index_lease_periods_all
  WHERE index_lease_id = p_index_lease_id
  AND assessment_date < p_assessment_date
  ORDER BY assessment_date desc;

  l_previous_negative_rent number := 0;

  BEGIN

  put_log ('pn_index_amount_pkg.derive_prev_negative_rent   (+) : ');

  /*

  Note : The previous sum of negative rents can be found out as
          "the sum of the all previous unconstrained rent-dues
           whose constrained rent due is greater than zero."

         The constrained rent due can be zero because of neagtive rent or
         zero percent change. For the periods whose Ri is not computed,
         default value of zero is taken.

  */

  for rec_negative_rent in csr_negative_rent
  loop

     exit when rec_negative_rent.constraint_rent_due is not null and rec_negative_rent.constraint_rent_due > 0;
     l_previous_negative_rent := nvl(rec_negative_rent.unconstraint_rent_due,0) + l_previous_negative_rent;

  end loop;

  put_log ('pn_index_amount_pkg.derive_prev_negative_rent   (-) :');

  RETURN l_previous_negative_rent;

  END derive_prev_negative_rent;

  -----------------------------------------------------------------------------
  -- FUNCTION   : get_increase_over_constraint
  -- DESCRIPTION:
  --
  -----------------------------------------------------------------------------

  FUNCTION get_increase_over_constraint (
      p_carry_forward_flag     IN VARCHAR2,
      p_constraint_amount      IN NUMBER,
      p_unconstrained_rent     IN NUMBER,
      p_constrained_rent       IN NUMBER)
  RETURN number
  IS
  BEGIN

  if nvl(p_carry_forward_flag,'N') = 'Y' and
     p_constraint_amount is not null then

     if p_unconstrained_rent > p_constrained_rent  then
        return (p_unconstrained_rent - p_constrained_rent);
     else
        return 0;
     end if;
  else
     return null;
  end if;

  END get_increase_over_constraint;


  -----------------------------------------------------------------------------
  -- FUNCTION   : get_max_assessment_dt
  -- DESCRIPTION: get the maximum assessment date after the current assessment
  --              date where the calcuation has been done.
  --
  -----------------------------------------------------------------------------

  FUNCTION get_max_assessment_dt(p_index_lease_id IN NUMBER,
                                 p_assessment_date IN DATE)
  RETURN DATE
  IS
  CURSOR csr_get_dt
  IS
  SELECT max(assessment_date)
  FROM pn_index_lease_periods_all
  WHERE index_lease_id = p_index_lease_id
  AND assessment_date > p_assessment_date
  AND constraint_rent_due is not null;

  l_max_assmt_dt DATE := null;

  BEGIN

     OPEN csr_get_dt;
     FETCH csr_get_dt into l_max_assmt_dt;
     IF csr_get_dt%notfound THEN
        l_max_assmt_dt := p_assessment_date;
     END IF;
     CLOSE csr_get_dt;

     RETURN l_max_assmt_dt;

  END get_max_assessment_dt;


  -----------------------------------------------------------------------------
  -- PROCEDURE   : calculate_subsequent_periods
  -- DESCRIPTION:  This procedure is called by table handler
  --               pn_index_periods_pkg while calculating for an index lease
  --               period. If carry forward flag is 'Y' then calculate for
  --               all subsequent periods after the current period.
  --
  -----------------------------------------------------------------------------

  PROCEDURE calculate_subsequent_periods(p_index_lease_id  IN NUMBER,
                                         p_assessment_date IN DATE)
  IS
  CURSOR csr_get_periods is
  SELECT index_lease_id,
         index_period_id,
         assessment_date
  FROM  pn_index_lease_periods_all
  WHERE index_lease_id = p_index_lease_id
  AND assessment_date > p_assessment_date
  AND assessment_date <= get_max_assessment_dt(index_lease_id,p_assessment_date);

  v_msg VARCHAR2(1000);

  BEGIN

  put_log('pn_index_amount_pkg.calculate_subsequent_periods  (+) : ');

  FOR rec_get_periods in csr_get_periods
  LOOP

     put_log('Calculate_subsequent_periods : Assessment Date '|| rec_get_periods.assessment_date);

     calculate (
            ip_index_lease_id             => rec_get_periods.index_lease_id
           ,ip_index_lease_period_id      => rec_get_periods.index_period_id
           ,ip_recalculate                => 'Y'
           ,op_msg                        => v_msg );

     put_log('v_msg   : '||v_msg);

  END LOOP;

  put_log('pn_index_amount_pkg.calculate_subsequent_periods  (-)  : ');

  END calculate_subsequent_periods;


END pn_index_amount_pkg;


/
