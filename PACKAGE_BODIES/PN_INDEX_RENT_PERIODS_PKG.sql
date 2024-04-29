--------------------------------------------------------
--  DDL for Package Body PN_INDEX_RENT_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INDEX_RENT_PERIODS_PKG" AS
-- $Header: PNINRPRB.pls 120.26.12010000.3 2010/01/22 11:24:58 jsundara ship $

-- +===========================================================================+
-- |                Copyright (c) 2001 Oracle Corporation
-- |                   Redwood Shores, California, USA
-- |                        All rights reserved.
-- +===========================================================================+
-- |  Name
-- |    pn_index_rent_periods_pkg
-- |
-- |  Description
-- |    This package contains procedures used to maintain index rent periods
-- |
-- |
-- |  History
-- | 27-MAR-01 jreyes    Created
-- | 22-jul-01  psidhu   Added procedure PROCESS_PAYMENT_TERM_AMENDMENT.
-- |                     Added condition 'ALL' to procedure DELETE_PERIODS.
-- | 20-Sep-01  psidhu   Added procedure RECALC_OT_PAYMENT_TERMS.
-- |                     Added parameters p_old_main_lease_term_date and
-- |                     p_lease_context to procedure PROCESS_MAIN_LEASE_TERM_DATE.
-- | 05-dec-01 achauhan  In the call to create_payment_term_record added the parameter
-- |                     op_payment_term_id.
-- | 06-dec-01 achauhan  In delete_periods added the code to delete from
-- |                     pn_index_lease_terms
-- | 07-Mar-02 lkatputu  Bug Fix for #2254491.
-- |                     For the generate_periods_BATCH Procedure the datatype of
-- |                     p_index_lease_num has been changed from NUMBER to VARCHAR2
-- |                     in the Cursor index_lease_periods.
-- | 08-Mar-02 lkatputu  Added the following lines at the beginning.
-- |                     Added for ARU db drv auto generation
-- | 17-May-04 vmmehta   Changed procedure process_payment_term_amendment
-- |                     Check for retain_initial_basis_flag and overwrite initial_basis only if flag is not set.
-- |
-- | 24-AUG-04 ftanudja  o Added logic to check profile option value before
-- |                       extending index rent term in process_main_lease_term_date().
-- |                       #3756208.
-- |                     o Changed instances of updation using nvl(fnd_profile(),0)
-- |                       to use fnd_global.user_id|login_id.
-- | 14-JUL-05 SatyaDeep o Replaced base views with their respective _ALL tables.
-- | 19-JAN-06 piagrawa  o Bug#4931780 - Modified signature of
-- |                        process_main_lease_term_date, recalc_ot_payment_terms
-- | 24-NOV-06 Prabhakar o Added parameter index_multiplier to create_periods.
-- +===========================================================================+


------------------------------------------------------------------------
-- PROCEDURE : put_log
-- DESCRIPTION: This procedure will display the text in the log file
--              of a concurrent program
--
------------------------------------------------------------------------

   PROCEDURE put_log (
      p_string   IN   VARCHAR2) IS
   BEGIN
      pn_index_lease_common_pkg.put_log (p_string);
   END put_log;


------------------------------------------------------------------------
-- PROCEDURE : put_output
-- DESCRIPTION: This procedure will display the text in the log file
--              of a concurrent program
--
------------------------------------------------------------------------

   PROCEDURE put_output (
      p_string   IN   VARCHAR2) IS
   BEGIN
      pn_index_lease_common_pkg.put_output (p_string);
   END put_output;


------------------------------------------------------------------------
-- PROCEDURE : display_error_messages
-- DESCRIPTION: This procedure will parse a string of error message codes
--              delimited of with a comma.  It will lookup each code using
--              fnd_messages routine.
------------------------------------------------------------------------

   PROCEDURE display_error_messages (
      ip_message_string   IN   VARCHAR2) IS
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
                                 - comma_loc);
            --
            -- locate the first occurrence of a comma
            --
            comma_loc := INSTR (message_string, ',', 1, 1);
         END IF; --LENGTH (ind_message) > 30
      END LOOP;
   END display_error_messages;


------------------------------------------------------------------------
-- PROCEDURE : get_basis_dates
-- DESCRIPTION: This procedure will derive an index rent period's basis start and
--              end dates.
--
------------------------------------------------------------------------
   PROCEDURE get_basis_dates (
      p_prev_asmt_dt       IN       DATE
     ,p_curr_asmt_dt       IN       DATE
     ,p_ml_start_dt        IN       DATE
     ,p_basis_start_date   OUT NOCOPY      DATE
     ,p_basis_end_date     OUT NOCOPY      DATE) IS
      v_temp_assmt_dt   DATE;
   BEGIN

--
-- Derive Basis End Date
--    General Rule, Basis ends the day before assesment date.
      p_basis_end_date :=   p_curr_asmt_dt
                          - 1;

--
-- Derive Basis Start Date
--    The basis start date will be the latest date of the following:
--
--       . main lease start date
--       . the prev. periods assessment date
--       . date a year before the basis end date

       -- v_temp_assmt_dt is the day a year before the basis end-date.
      --
      v_temp_assmt_dt :=   ADD_MONTHS (p_basis_end_date, -12)
                         + 1;
      --p_basis_start_date :=
      --   GREATEST (NVL (p_prev_asmt_dt, v_temp_assmt_dt), v_temp_assmt_dt, p_ml_start_dt);
      p_basis_start_date := GREATEST (v_temp_assmt_dt, p_ml_start_dt);


--
-- When Main Lease Start and Index Rent are equal, leave basis start and basis end blank.
--
      IF p_ml_start_dt = p_curr_asmt_dt THEN
         p_basis_start_date := NULL;
         p_basis_end_date := NULL;
      END IF;
   END get_basis_dates;


------------------------------------------------------------------------
-- PROCEDURE  : generate_basis_data_check
-- DESCRIPTION: This procedure will check that all business rules are enforced before
--              generating periods.
--                    -
-- ARGUEMENTS : p_index_lease_id - Index Lease ID
--
------------------------------------------------------------------------
   PROCEDURE generate_basis_data_check (
      p_index_lease_id   IN       NUMBER
     ,p_msg              OUT NOCOPY      VARCHAR2) AS
      CURSOR il_rec (
         ip_index_lease_id   IN   NUMBER) IS
         SELECT pld.lease_commencement_date
               ,pil.index_lease_number
               ,pil.assessment_date
               ,pil.commencement_date
               ,pil.termination_date
               ,pil.assessment_interval
               ,pil.relationship_default
               ,pil.basis_percent_default
           FROM pn_index_leases_all pil, pn_lease_details_all pld
          WHERE pld.lease_id = pil.lease_id
            AND pil.index_lease_id = ip_index_lease_id;

      tlinfo   il_rec%ROWTYPE;
      v_msg    VARCHAR2 (200);
   BEGIN
      OPEN il_rec (p_index_lease_id);
      FETCH il_rec INTO tlinfo;

      IF (il_rec%NOTFOUND) THEN
         CLOSE il_rec;
         v_msg := 'PN_LEASE_NOT_FOUND';
         put_log ('    Error: Index or Main Lease not found');
         RETURN;
      END IF;

      --Business Rule:  The following fields are required
      --  - Index Rent Commencement and Termination Date
      --  - Main Lease Start Date
      --  - Date Assessed
      --  - Assessment Frequency
      -- as of 5/17 removed relationship default and basis % default are optional
      -- will keep code, just in case.
      --  - Relationship Default
      --  - Basis Percent Default
      IF (   tlinfo.lease_commencement_date IS NULL
          OR tlinfo.assessment_date IS NULL
          OR tlinfo.commencement_date IS NULL
          OR tlinfo.termination_date IS NULL
          OR tlinfo.assessment_interval IS NULL --OR tlinfo.relationship_default IS NULL
                                                --OR tlinfo.basis_percent_default IS NULL
                                               ) THEN
         put_log (
               'tlinfo.lease_commencement_date '
            || NVL (TO_CHAR (tlinfo.lease_commencement_date, 'DD-MON-YYYY'), 'NOT FOUND'));
         put_log (
               'tlinfo.assessment_date         '
            || NVL (TO_CHAR (tlinfo.assessment_date, 'DD-MON-YYYY'), 'NOT FOUND'));
         put_log (
               'tlinfo.commencement_date       '
            || NVL (TO_CHAR (tlinfo.commencement_date, 'DD-MON-YYYY'), 'NOT FOUND'));
         put_log (
               'tlinfo.termination_date        '
            || NVL (TO_CHAR (tlinfo.termination_date, 'DD-MON-YYYY'), 'NOT FOUND'));
         put_log (
               'tlinfo.assessment_interval     '
            || NVL (TO_CHAR (tlinfo.assessment_interval), 'NOT FOUND'));
         -- as of 5/17 removed relationship default and basis % default are optional
         -- will keep code, just in case.
            --
            --put_log (
            --      'tlinfo.relationship_default    '
            --   || NVL (tlinfo.relationship_default, 'NOT FOUND')
            --);
            --put_log (
            --      'tlinfo.basis_percent_default   '
            --   || NVL (TO_CHAR (tlinfo.basis_percent_default), 'NOT FOUND')
            --);
         v_msg := 'PN_REQ_FIELD_MISSING_GEN_BASIS';
         put_log ('    ERROR: Missing one or more required fields');
      --Business Rule:  The following fields are required
      --  - Assessment Frequency must be greater than 0
      ELSIF (NVL (tlinfo.assessment_interval, 0) <= 0) THEN
         v_msg := 'PN_ASMT_FREQ_MIN';
         put_log ('    ERROR: Assessment Frequency must be greater than 0');
      ELSE
         v_msg := 'PN_FOUND_ALL_REQD_FLDS';
      END IF;

      CLOSE il_rec;
      p_msg := v_msg;
   END generate_basis_data_check;


------------------------------------------------------------------------
-- PROCEDURE : DELETE_PERIODS
-- DESCRIPTION:  This procedure will create periods for an index rent
--
-- 20-FEB-07  Hareesha o Bug #5884029 Delete terms and items,schedules
--                       only when it has no approved schedules.
--                       Else disassociate the term with the period.
-- 11-MAY-07  Hareesha o Bug6042299 Added parameter p_new_termination_date
--                       When a period containing approved terms gets deleted,
--                       populate those terms index_period_id with latest
--                       index_period_id.
------------------------------------------------------------------------
   PROCEDURE delete_periods (
      p_index_lease_id          IN   NUMBER
     ,p_index_period_id         IN   NUMBER
     ,p_ignore_approved_terms   IN   VARCHAR2
     ,p_new_termination_date    IN   DATE) AS

      CURSOR index_lease_periods (
         ip_index_lease_id    IN   NUMBER
        ,ip_index_period_id   IN   NUMBER) IS
         SELECT pilp.index_lease_id,
               pilp.index_period_id
           FROM pn_index_lease_periods_all pilp
          WHERE pilp.index_lease_id = ip_index_lease_id
            AND (   pilp.index_period_id = ip_index_period_id
                 OR ip_index_period_id IS NULL);


      CURSOR index_leases_payments (
         ip_index_lease_id    IN   NUMBER
        ,ip_index_period_id   IN   NUMBER) IS
         SELECT pilp.index_period_id
               ,ppt.payment_term_id
               ,ppt.lease_id
           FROM pn_index_lease_periods_all pilp, pn_payment_terms_all ppt
          WHERE pilp.index_lease_id = ip_index_lease_id
            AND pilp.index_period_id = ppt.index_period_id
            AND pilp.index_period_id = ip_index_period_id;
            var number;

      CURSOR exists_approved_schedule( p_payment_term_id IN NUMBER) IS
         SELECT 'Y'
         FROM DUAL
         WHERE EXISTS( SELECT payment_item_id
                       FROM pn_payment_items_all items,
                            pn_payment_schedules_all sched
                       WHERE sched.payment_schedule_id = items.payment_schedule_id
                       AND items.payment_term_id = p_payment_term_id
                       AND sched.payment_status_lookup_code = 'APPROVED');

      CURSOR get_latest_period IS
         SELECT index_period_id
         FROM pn_index_lease_periods_all
         WHERE index_lease_id = p_index_lease_id
         AND assessment_date <= p_new_termination_date
         ORDER BY assessment_date DESC;

      l_latest_period_id NUMBER := NULL;
      l_exists_appr_schedule BOOLEAN := FALSE;

   BEGIN
      --
      -- When deleting index rent periods.
      --   You need to delete:
      --      All payment items
      --      All index rent periods


      FOR il_rec_periods IN index_lease_periods (p_index_lease_id, p_index_period_id)
      LOOP
      --DBMS_OUTPUT.put_line ('il_rec_periods.index_lease_id=' || il_rec_periods.index_lease_id);


      --DBMS_OUTPUT.put_line ('il_rec_periods.index_period_id=' ||il_rec_periods.index_period_id );



      FOR il_rec IN index_leases_payments (il_rec_periods.index_lease_id, il_rec_periods.index_period_id)
      LOOP

         --
         -- delete payment terms..
         --
         -- if p_ignore_approved_terms = 'Y', only delete payment
         --    terms that are not of status 'APPROVED'
         --
         IF p_ignore_approved_terms = 'Y' THEN
          --DBMS_OUTPUT.put_line ('deleting only non-approved payment terms...');
            DELETE FROM pn_distributions_all
                  WHERE payment_term_id IN
                              (SELECT payment_term_id
                                 FROM pn_payment_terms_all
                                WHERE payment_term_id = il_rec.payment_term_id
                                  AND status<>
                                            pn_index_amount_pkg.c_payment_term_status_approved);

            DELETE FROM pn_payment_terms_all
            WHERE payment_term_id = il_rec.payment_term_id
            AND status <> pn_index_amount_pkg.c_payment_term_status_approved;

            DELETE FROM pn_index_lease_terms_all
            WHERE  rent_increase_term_id = il_rec.payment_term_id
            AND    approved_flag <> pn_index_amount_pkg.c_payment_term_status_approved;

         ELSIF p_ignore_approved_terms = 'ALL'   THEN
           --since we are also deleting approved payment terms, schedules and items
           --associated with those approved terms would have to be deleted too.
           put_log(' delete periods : payment term id ='||il_rec.payment_term_id);

           FOR appr_sched IN exists_approved_schedule(il_rec.payment_term_id) LOOP
              l_exists_appr_schedule := TRUE;
           END LOOP;

           IF l_exists_appr_schedule THEN

              FOR last_period_rec IN get_latest_period LOOP
                 l_latest_period_id := last_period_rec.index_period_id;
                 EXIT;
              END LOOP;

              UPDATE pn_payment_terms_all
              SET index_period_id = l_latest_period_id,
                  index_term_indicator = 'REVERSED'
              WHERE payment_term_id = il_rec.payment_term_id;

           ELSE
                        BEGIN

                                DELETE FROM pn_payment_items_all
                                WHERE payment_term_id =il_rec.payment_term_id;

                                DELETE FROM pn_payment_schedules_all pps
                                WHERE not exists(SELECT 1
                                                 FROM PN_PAYMENT_ITEMS_ALL ppi
                                                 WHERE ppi.payment_schedule_id=pps.payment_schedule_id)
                                AND pps.lease_id=il_rec.lease_id;


                         EXCEPTION
                         When others then null;
                         END;




                          DELETE FROM pn_distributions_all
                          WHERE payment_term_id = il_rec.payment_term_id;


                          DELETE FROM pn_payment_terms_all
                          WHERE payment_term_id = il_rec.payment_term_id;

                          DELETE FROM pn_index_lease_terms_all
                          where  rent_increase_term_id = il_rec.payment_term_id;
           END IF;

         ELSE

            DELETE FROM pn_payment_terms_all
                  WHERE payment_term_id = il_rec.payment_term_id;

            DELETE FROM pn_distributions_all
                  WHERE payment_term_id = il_rec.payment_term_id;

            DELETE FROM pn_index_lease_terms_all
                   WHERE  rent_increase_term_id = il_rec.payment_term_id;
         END IF;

      END LOOP;

         --
         -- deleting index rent period record.
         --
         DELETE  pn_index_lease_periods_all
         WHERE index_lease_id = p_index_lease_id
         AND index_period_id = il_rec_periods.index_period_id;
          --DBMS_OUTPUT.put_line ('deleting periods...'||sql%rowcount);
      end loop;
   END delete_periods;

-------------------------------------------------------------------------------
-- PROCDURE     : create_periods
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 29-JUL-05  piagrawa  o Bug 4284035 - Passed org id in call to
--                        pn_index_lease_periods_pkg.insert_row
-- 24-NOV-06 Prabhakar  o Added index_multiplier parameter.
-------------------------------------------------------------------------------
   PROCEDURE create_periods (
      p_index_lease_id          NUMBER
     ,p_ir_start_dt             DATE
     ,p_ir_end_dt               DATE
     ,p_ml_start_dt             DATE
     ,p_date_assessed           DATE
     ,p_assessment_freq_years   NUMBER
     ,p_index_finder_months     NUMBER
     ,p_relationship_default    pn_index_leases.relationship_default%TYPE
     ,p_basis_percent_default   pn_index_leases.basis_percent_default%TYPE
     ,p_starting_period_num     NUMBER
     ,p_index_multiplier        NUMBER)
  IS
      v_basis_start_date        DATE;
      v_basis_end_date          DATE;
      v_x_index_finder_date     DATE;
      v_prev_asmt_dt            DATE;
      v_curr_asmt_dt            DATE;
      v_next_asmt_dt            DATE;
      v_period_number           NUMBER         := 0;
      v_x_rowid                 VARCHAR2 (100);
      v_period_id               NUMBER;
      v_assessment_freq_month   NUMBER;
      v_next_assessment_year    VARCHAR2 (20);
      v_org_id                  NUMBER;

      CURSOR c IS
         SELECT ORG_ID
         FROM pn_index_leases_all
         WHERE index_lease_id = p_index_lease_id;
   BEGIN
      -- all date calculation uses month
      -- convert assessment frequency from years to month
      --
      v_assessment_freq_month := p_assessment_freq_years * 12;
      -- First assessment date will always be the IR Commencement Date
      --
      v_curr_asmt_dt := p_ir_start_dt;

      -- Derive Next Assessment Date:
      --  if Indx Rent Comm Month and Day  equal to or after Date Assessed  Month and Day
      --       use MM-DD of date assessed and Indx Rent Comm year + p_assessment_freq_years
      --  otherwise
      --      use MM-DD of date assessed and Indx Rent Comm + p_assessment_freq_years -1 ;
      --

      -- Deriving the year of next assessment date.
      IF TO_NUMBER (TO_CHAR (p_ir_start_dt, 'MMDD')) <
                                             TO_NUMBER (TO_CHAR (p_date_assessed, 'MMDD')) THEN
         v_next_assessment_year :=
                  TO_NUMBER (TO_CHAR (p_ir_start_dt, 'YYYY'))
                + p_assessment_freq_years
                - 1;
      ELSE
         v_next_assessment_year :=
                      TO_NUMBER (TO_CHAR (p_ir_start_dt, 'YYYY'))
                    + p_assessment_freq_years;
      END IF;

      FOR c1 IN c LOOP
         v_org_id := c1.org_id;
      END LOOP;

      -- Derive the next assessment date by gettin the mon-day of assesment date
      --  and the year as calculated above.
      v_next_asmt_dt := TO_DATE (
                              TO_CHAR (p_date_assessed, 'DD-MON-')
                           || v_next_assessment_year
                          ,'DD-MON-YYYY');
      -- reset the period counter
      v_period_number := p_starting_period_num;

      --
      -- Generate periods incrementing anniv_dt
      --
      WHILE v_curr_asmt_dt < p_ir_end_dt
      LOOP
         -- reset period_id
         v_period_id := NULL;
         --  Derive Basis Start and End Dates
         --
         get_basis_dates (
            v_prev_asmt_dt
           ,v_curr_asmt_dt
           ,p_ml_start_dt
           ,v_basis_start_date
           ,v_basis_end_date);
         -- Derive Index Finder Date
         --   Finder Date is adjusted based on the index finder months field on
         --   the defaults tab...
         --
         v_x_index_finder_date :=
                              ADD_MONTHS (v_curr_asmt_dt, NVL (p_index_finder_months, 0));
         -- Add a record to pn_index_lease_periods table
         --
         pn_index_lease_periods_pkg.insert_row (
            x_rowid                       => v_x_rowid
           ,x_org_id                      => v_org_id
           ,x_index_period_id             => v_period_id
           -- should not be in out??
           ,x_index_lease_id              => p_index_lease_id
           ,x_line_number                 => v_period_number
           ,x_assessment_date             => v_curr_asmt_dt
           ,x_basis_start_date            => v_basis_start_date
           ,x_basis_end_date              => v_basis_end_date
           ,x_last_update_date            => SYSDATE
           ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_creation_date               => SYSDATE
           ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_index_finder_date           => v_x_index_finder_date
           ,x_current_index_line_id       => NULL
           ,x_current_index_line_value    => NULL
           ,x_previous_index_line_id      => NULL
           ,x_previous_index_line_value   => NULL
           ,x_current_basis               => NULL
           ,x_relationship                => p_relationship_default
           ,x_index_percent_change        => NULL
           ,x_basis_percent_change        => p_basis_percent_default
           ,x_unconstraint_rent_due       => NULL
           ,x_constraint_rent_due         => NULL
           ,x_last_update_login           => NULL
           ,x_attribute_category          => NULL
           ,x_attribute1                  => NULL
           ,x_attribute2                  => NULL
           ,x_attribute3                  => NULL
           ,x_attribute4                  => NULL
           ,x_attribute5                  => NULL
           ,x_attribute6                  => NULL
           ,x_attribute7                  => NULL
           ,x_attribute8                  => NULL
           ,x_attribute9                  => NULL
           ,x_attribute10                 => NULL
           ,x_attribute11                 => NULL
           ,x_attribute12                 => NULL
           ,x_attribute13                 => NULL
           ,x_attribute14                 => NULL
           ,x_attribute15                 => NULL
           ,x_index_multiplier            => p_index_multiplier);
         --
           -- set dates to be used for next period
           --
         v_period_number :=   v_period_number
                            + 1;
         v_prev_asmt_dt := v_curr_asmt_dt;
         v_curr_asmt_dt := v_next_asmt_dt;
         v_next_asmt_dt := ADD_MONTHS (v_curr_asmt_dt, v_assessment_freq_month);
      END LOOP; --curr_aniv_dt < index_rent_end_dt
   END create_periods;


------------------------------------------------------------------------
-- PROCEDURE : CREATE_PERIOD
-- DESCRIPTION:  This procedure will create periods for an index rent
--
------------------------------------------------------------------------


/*===========================================================================+
 | PROCEDURE
 |   print_basis_periods
 |
 | DESCRIPTION
 |   Sends report to output log of basis periods:
     Sample:

     Index Lease Number  : 1020
     Commencement Date   : 31-MAY-99
     End Date            : 28-JUN-10
     Assement Frequency  : every 2 year(s)


     Period     Basis          Basis           Index           Index
     Number   Start Date      End Date      Finder Date    Assessment Date
     -------  -----------    -----------    -----------    ---------------
           1  01-MAY-1999    30-MAY-1999    31-JAN-1999    31-MAY-1999
           2  22-MAR-2000    22-MAR-2001    23-NOV-2000    23-MAR-2001
           3  22-MAR-2002    22-MAR-2003    23-NOV-2002    23-MAR-2003
           4  22-MAR-2004    22-MAR-2005    23-NOV-2004    23-MAR-2005
           5  22-MAR-2006    22-MAR-2007    23-NOV-2006    23-MAR-2007
           6  22-MAR-2008    22-MAR-2009    23-NOV-2008    23-MAR-2009


 |
 | ARGUMENTS: p_index_lease_id
 |
 | NOTES:
 |   Called at all Debug points spread across this file
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

   PROCEDURE print_basis_periods (
      p_index_lease_id   NUMBER) IS
      CURSOR index_leases (
         ip_index_lease_id   IN   NUMBER) IS
         SELECT pil.index_lease_number
               ,pil.commencement_date
               ,pil.termination_date
               ,pil.assessment_date "DATE_ASSESSED"
               ,pil.assessment_interval
               ,pil.relationship_default
               ,pil.basis_percent_default
           FROM pn_index_leases_all pil
          WHERE pil.index_lease_id = ip_index_lease_id;

      CURSOR index_lease_periods (
         ip_index_lease_id   IN   NUMBER) IS
         SELECT   pilp.line_number
                 ,pilp.basis_start_date
                 ,pilp.basis_end_date
                 ,pilp.index_finder_date
                 ,pilp.assessment_date
             FROM pn_index_lease_periods_all pilp
            WHERE pilp.index_lease_id = ip_index_lease_id
         ORDER BY pilp.line_number;

      v_line_count   NUMBER;
      l_message VARCHAR2(2000) := NULL;

   BEGIN
      FOR il_rec IN index_leases (p_index_lease_id)
      LOOP
         --  Print the Header info of report
         --  Will only be done once
         fnd_message.set_name ('PN','PN_RICAL_LSNO');
         fnd_message.set_token ('NUM', il_rec.index_lease_number);
         put_output(fnd_message.get);

         fnd_message.set_name ('PN','PN_MRIP_CM_DATE');
         fnd_message.set_token ('DATE', il_rec.commencement_date);
         put_output(fnd_message.get);

         fnd_message.set_name ('PN','PN_MRIP_TM_DATE');
         fnd_message.set_token ('DATE', il_rec.termination_date);
         put_output(fnd_message.get);

         fnd_message.set_name ('PN','PN_RICAL_ASS_DATE');
         fnd_message.set_token ('DATE', TO_CHAR (il_rec.date_assessed, 'DD-MON'));
         put_output(fnd_message.get);

         fnd_message.set_name ('PN','PN_MRIP_ASM_FREQ');
         fnd_message.set_token ('FREQ', il_rec.assessment_interval);
         put_output(fnd_message.get);

         fnd_message.set_name ('PN','PN_MRIP_PRD');
         l_message := fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_BAS');
         l_message := l_message||'      '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_BAS');
         l_message := l_message||'          '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_INDX');
         l_message := l_message||'         '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_INDX');
         l_message := l_message||'           '||fnd_message.get;
         put_output(l_message);

         fnd_message.set_name ('PN','PN_MRIP_NUM');
         l_message := fnd_message.get;
         fnd_message.set_name ('PN','PN_MRIP_ST_DATE');
         l_message := l_message||'   '||fnd_message.get;
         fnd_message.set_name ('PN','PN_MRIP_END_DATE');
         l_message := l_message||'      '||fnd_message.get;
         fnd_message.set_name ('PN','PN_MRIP_FND_DATE');
         l_message := l_message||'      '||fnd_message.get;
         fnd_message.set_name ('PN','PN_MRIP_ASM_DATE');
         l_message := l_message||'    '||fnd_message.get;
         put_output(l_message);

         put_output (
            '-------  -----------    -----------    -----------    ---------------');
         -- Reset line counter for periods.
         v_line_count := 0;

         FOR ilp_rec IN index_lease_periods (p_index_lease_id)
         LOOP
            --  Print the Period Details
            put_output (
                  LPAD (ilp_rec.line_number, 7, ' ')
               || LPAD (
                     NVL (TO_CHAR (ilp_rec.basis_start_date, 'DD-MON-RRRR'), ' ')
                    ,13
                    ,' ')
               || LPAD (NVL (TO_CHAR (ilp_rec.basis_end_date, 'DD-MON-RRRR'), ' '), 15, ' ')
               || LPAD (TO_CHAR (ilp_rec.index_finder_date, 'MON-RRRR'), 13, ' ')
               || LPAD (TO_CHAR (ilp_rec.assessment_date, 'DD-MON-RRRR'), 17, ' '));
            v_line_count :=   v_line_count
                            + 1;
         END LOOP;

         --
         -- Print Message if no basis periods found
         --
         IF v_line_count = 0 THEN
            put_output ('**************************************');
            fnd_message.set_name ('PN','PN_RICAL_NO_PRDS');
            put_output(fnd_message.get);
            put_output ('**************************************');
         END IF;

      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
   END print_basis_periods;


/*
Does
Get all periods that have an assessment date after the termination date.

    For each period:
        Check if period is approved,
            If found, display message: "New termination date is not valid."
           exit loop;
   .



*/

------------------------------------------------------------------------
-- PROCEDURE : undo_periods
-- DESCRIPTION: This procedure will undo index periods of an certain
--             index rent.
--             Periods can only be deleted if, no invoices has been exported
--             for any periods.
--
------------------------------------------------------------------------
   PROCEDURE undo_periods (
      p_index_lease_id   IN       NUMBER
     ,p_msg              OUT NOCOPY      VARCHAR2) AS
      v_msg   VARCHAR2 (100);
   BEGIN

-----------------------------------------------------
--
-- Periods can only be deleted if no periods are approved, the following steps are taken:
--    - check that no index rent period has payment terms that have been approved.
--
--
      pn_index_lease_common_pkg.chk_for_approved_index_periods (
         p_index_lease_id              => p_index_lease_id
        ,p_index_lease_period_id       => NULL
        ,p_msg                         => v_msg);

      IF v_msg = 'PN_APPROVED_PERIODS_NOT_FOUND' THEN
         v_msg := NULL;
         delete_periods (
            p_index_lease_id              => p_index_lease_id
           ,p_index_period_id             => NULL
           ,p_ignore_approved_terms       => 'N');
      --v_msg := 'PN_UNDO_PRDS_SUCCESS';
      ELSE
         v_msg := 'PN_UNDO_PRDS_FAIL_APPROVE_PRDS';
      END IF;

      p_msg := v_msg;
   END undo_periods;


--------------------------------------------------------------------------------
-- PROCEDURE  : generate_periods_BATCH
-- DESCRIPTION: This procedure will get all the index rent to be processed
-- ARGUEMENTS : ip_index_lease_low_num - Index Number (From)
--              ip_index_lease_high_num - Index Number (To)
--
-- 07-Mar-02 lkatputu  o Bug#2254491. datatype of p_index_lease_num changed from
--                       NUMBER to VARCHAR2 in the Cursor index_lease_periods.
-- 25-NOV-05 Kiran     o replaced pn_index_leases_all with pn_index_leases
-- 24-NOV-06 Prabhakar o Added index_multiplier in cursor attributes.
--------------------------------------------------------------------------------
   PROCEDURE generate_periods_batch (
      errbuf               OUT NOCOPY      VARCHAR2
     ,retcode              OUT NOCOPY      VARCHAR2
     ,ip_index_lease_num   IN       VARCHAR2
     ,ip_regenerate_yn     IN       VARCHAR2) AS
      CURSOR index_lease_periods (
         p_index_lease_num   IN   VARCHAR2) IS
         SELECT   pil.index_lease_id
                 ,pil.index_lease_number
                 ,pld.lease_commencement_date
                 ,pil.assessment_date
                 ,pil.commencement_date
                 ,pil.termination_date
                 ,pil.assessment_interval
                 ,pil.relationship_default
                 ,pil.basis_percent_default
                 ,pil.index_finder_months
                 ,nvl (pil.index_multiplier,1) "INDEX_MULTIPLIER"
             FROM pn_index_leases pil
                 ,pn_lease_details_all pld
            WHERE pld.lease_id = pil.lease_id
              AND (   pil.index_lease_number = p_index_lease_num
                   OR p_index_lease_num IS NULL)
         ORDER BY pil.index_lease_number;

      v_msg             VARCHAR2 (100);
      v_counter         NUMBER         := 0; -- no. of index leases found
      v_periods_found   BOOLEAN;
   --
   BEGIN
      FOR ilp IN index_lease_periods (ip_index_lease_num)
      LOOP
         put_output ('****************************************');
         fnd_message.set_name ('PN','PN_RICAL_PROC');
         put_output(fnd_message.get||' ...');
         fnd_message.set_name ('PN','PN_RICAL_LSNO');
         fnd_message.set_token ('NUM', ilp.index_lease_number);
         put_output(fnd_message.get);
         put_output ('****************************************');
         v_msg := NULL;

         --
         -- check if periods already exist for this index lease
         --
         --  results  '1' - periods exists
         --           NULL - no periods found

         IF NVL (
               pn_index_lease_common_pkg.find_if_period_exists (
                  p_index_lease_id              => ilp.index_lease_id)
              ,0) = 1 -- OR ip_regenerate_YN ='Y'
                      THEN
            v_periods_found := TRUE;
         ELSE
            v_periods_found := FALSE;
         END IF;

         --
         -- Generate periods if
         --       - no periods found OR
         --       - regenerate periods ="Y"
         --
         IF    (NOT v_periods_found)
            OR ip_regenerate_yn = 'Y' THEN
            --
            -- if periods were found then delete existing periods first..
            --
            IF v_periods_found THEN
               pn_index_rent_periods_pkg.undo_periods (
                  p_index_lease_id              => ilp.index_lease_id
                 ,p_msg                         => v_msg);
            END IF;

            --
            --
            --
            IF v_msg IS NULL THEN
               -- Verify that all required fields to generate periods
               -- are available
               generate_basis_data_check (ilp.index_lease_id, v_msg);

               IF v_msg = 'PN_FOUND_ALL_REQD_FLDS' THEN
                  --create_periods (ilp.index_lease_id);
                  create_periods (
                     p_index_lease_id              => ilp.index_lease_id
                    ,p_ir_start_dt                 => ilp.commencement_date
                    ,p_ir_end_dt                   => ilp.termination_date
                    ,p_ml_start_dt                 => ilp.lease_commencement_date
                    ,p_date_assessed               => ilp.assessment_date
                    ,p_assessment_freq_years       => ilp.assessment_interval
                    ,p_index_finder_months         => ilp.index_finder_months
                    ,p_relationship_default        => ilp.relationship_default
                    ,p_basis_percent_default       => ilp.basis_percent_default
                    ,p_starting_period_num         => 1
                    ,p_index_multiplier            => ilp.index_multiplier);
                  v_msg := 'PN_GEN_PRDS_SUCCESS';
               ELSE
                  v_msg := 'PN_GEN_PRDS_FAIL_REQD_FLDS';
               END IF; -- v_msg is null;

               print_basis_periods (ilp.index_lease_id);
               v_counter :=   v_counter
                            + 1;
            ELSE
               --
               -- cannot delete existing periods because approved periods were found
               --

               v_msg := 'PN_UNDO_PRDS_FAIL_APPROVE_PRDS';
            END IF; --v_msg = 'PN_UNDO_PRDS_SUCCESS'
         ELSE
            v_msg := 'PN_INDX_PERIODS_EXISTS';
         END IF; --!v_periods_found OR ip_regenerate_yn = 'Y'

    fnd_message.set_name ('PN','PN_RICAL_MSG');
         put_output (fnd_message.get);

    fnd_message.set_name ('PN',v_msg);
         put_log (fnd_message.get);

         display_error_messages (ip_message_string => v_msg);
      END LOOP;

      IF v_counter = 0 THEN
         put_log ('***********************************');
         put_log ('No Index Rent to process was found.');
         put_log ('***********************************');
      END IF;
   --op_msg := v_msg;
   END generate_periods_batch;


------------------------------------------------------------------------
-- PROCEDURE  : generate_periods
-- DESCRIPTION: This procedure will get all the index rent to be processed
-- ARGUEMENTS : ip_index_lease_low_num - Index Number (From)
--              ip_index_lease_high_num - Index Number (To)
--
-- 24-NOV-2006 Prabhakar o Added index_multiplier in cursor attributes.
------------------------------------------------------------------------
   PROCEDURE generate_periods (
      ip_index_lease_id   IN       NUMBER
     ,op_msg              OUT NOCOPY      VARCHAR2) AS
      CURSOR index_lease_periods (
         p_index_lease_id   IN   NUMBER) IS
         SELECT pil.index_lease_id
               ,pil.index_lease_number
               ,pld.lease_commencement_date
               ,pil.assessment_date
               ,pil.commencement_date
               ,pil.termination_date
               ,pil.assessment_interval
               ,pil.relationship_default
               ,pil.basis_percent_default
               ,pil.index_finder_months
               ,nvl (pil.index_multiplier, 1) "INDEX_MULTIPLIER"
           FROM pn_index_leases_all pil, pn_lease_details_all pld
          WHERE pld.lease_id = pil.lease_id
            AND pil.index_lease_id = p_index_lease_id;

      v_msg       VARCHAR2 (100);
      v_counter   NUMBER         := 0; -- no. of index leases found
   --
   BEGIN
      --
      -- do not create periods if periods exists.
      --

      IF NVL (
            pn_index_lease_common_pkg.find_if_period_exists (
               p_index_lease_id              => ip_index_lease_id)
           ,0) <> 1 THEN
         FOR ilp IN index_lease_periods (ip_index_lease_id)
         LOOP
            put_log (   'Processing Index Lease Number :'
                     || ilp.index_lease_number);
            v_msg := NULL;
            -- Verify that all required fields to generate periods
            -- are available
            generate_basis_data_check (ilp.index_lease_id, v_msg);

            IF v_msg = 'PN_FOUND_ALL_REQD_FLDS' THEN
               v_msg := NULL;
               create_periods (
                  p_index_lease_id              => ilp.index_lease_id
                 ,p_ir_start_dt                 => ilp.commencement_date
                 ,p_ir_end_dt                   => ilp.termination_date
                 ,p_ml_start_dt                 => ilp.lease_commencement_date
                 ,p_date_assessed               => ilp.assessment_date
                 ,p_assessment_freq_years       => ilp.assessment_interval
                 ,p_index_finder_months         => ilp.index_finder_months
                 ,p_relationship_default        => ilp.relationship_default
                 ,p_basis_percent_default       => ilp.basis_percent_default
                 ,p_starting_period_num         => 1
                 ,p_index_multiplier            => ilp.index_multiplier);
            --v_msg := 'PN_GEN_PRDS_SUCCESS';
            ELSE
               v_msg := 'PN_GEN_PRDS_FAIL_REQD_FLDS';
            END IF; -- v_msg is null;

            put_log (v_msg);
            print_basis_periods (ilp.index_lease_id);
            v_counter :=   v_counter
                         + 1;
         --v_msg := NULL;
         END LOOP;

         IF v_counter = 0 THEN
            put_log ('***********************************');
            put_log ('No Index Rent to process was found.');
            put_log ('***********************************');
         END IF;
      ELSE
         v_msg := 'PN_GEN_PRDS_FAIL_APPRV_PAY_FND';
      END IF;

      op_msg := v_msg;
   END generate_periods;

-------------------------------------------------------------------------------
-- PROCEDURE remove_agreement
-- DESCRIPTION: This procedure will delete the future dated RI agreements
--              with no approved schedules when a lease is early terminated.
-- HISTORY:
-- 17-OCT-06   Hareesha    o Created.
-------------------------------------------------------------------------------
PROCEDURE remove_agreement (
      p_index_lease_id        IN   NUMBER
     ,p_new_termination_date  IN DATE)
IS

   CURSOR approved_sched_exist(p_index_lease_id IN NUMBER) IS
      SELECT term.payment_term_id
      FROM pn_payment_schedules_all sched,
           pn_index_leases_all ilease,
           pn_payment_terms_all term,
           pn_payment_items_all item,
           pn_index_lease_periods_all period
      WHERE  sched.lease_id = ilease.lease_id
      AND    sched.payment_schedule_id = item.payment_schedule_id
      AND    item.payment_term_id = term.payment_term_id
      AND    term.lease_id = ilease.lease_id
      AND    ilease.index_lease_id = p_index_lease_id
      AND    period.index_lease_id = ilease.index_lease_id
      AND    term.index_period_id = period.index_period_id
      AND    term.index_period_id IS NOT NULL
      AND    sched.payment_status_lookup_code = 'APPROVED'
      AND    ilease.commencement_date > p_new_termination_date
      AND    ilease.termination_date > p_new_termination_date ;

   l_appr_sched_exists BOOLEAN := FALSE;

BEGIN
   put_log('remove_agreement (+) ');

   FOR rec IN approved_sched_exist(p_index_lease_id) LOOP
      l_appr_sched_exists := TRUE;
   END LOOP;

   IF NOT(l_appr_sched_exists) THEN

      DELETE FROM pn_index_exclude_term_all
      WHERE index_lease_id = p_index_lease_id ;

      DELETE FROM pn_index_lease_terms_all
      WHERE index_lease_id = p_index_lease_id ;

      DELETE FROM pn_index_lease_constraints_all
      WHERE index_lease_id = p_index_lease_id ;

      DELETE FROM pn_payment_items_all
      WHERE payment_term_id IN ( SELECT term.payment_term_id
                                 FROM pn_payment_terms_all term,pn_index_lease_periods_all iperiod
                                 WHERE term.index_period_id = iperiod.index_period_id
                                 AND   iperiod.index_lease_id = p_index_lease_id
                                 AND term.index_period_id IS NOT NULL);

      DELETE FROM pn_payment_schedules_all sched
      WHERE sched.payment_status_lookup_code = 'DRAFT'
      AND NOT EXISTS( SELECT payment_schedule_id
                      FROM pn_payment_items_all item
                      WHERE item.payment_schedule_id = sched.payment_schedule_id);

      DELETE FROM pn_distributions_all
      WHERE payment_term_id IN (SELECT payment_term_id
                                FROM pn_payment_terms_all term,pn_index_lease_periods_all period
                                WHERE term.index_period_id = period.index_period_id
                                AND   period.index_lease_id = p_index_lease_id);

      DELETE FROM pn_payment_terms_all
      WHERE index_period_id IN (SELECT index_period_id
                                FROM pn_index_lease_periods_all
                                WHERE index_lease_id = p_index_lease_id);

      DELETE FROM pn_index_lease_periods_all
      WHERE index_lease_id = p_index_lease_id ;

      DELETE FROM pn_index_leases_all
      WHERE index_lease_id = p_index_lease_id ;

      put_log(' deleted agreements');

   END IF;

   put_log('remove_agreement (-) ');

EXCEPTION
   WHEN OTHERS THEN RAISE;
END remove_agreement;


------------------------------------------------------------------------
-- PROCEDURE : process_new_termination_date
-- DESCRIPTION:  This procedure will create periods for an index rent
--
-- 24-NOV-2006 Prabhakar o added index_multiplier in cursor attributes.
-- 14-DEC-06  Hareesha  o M28#19 Remove future-dated RI agreements who have
--                        no approved schedules when lease is early terminated.
--                       delete the RI agreement if there exist no periods for it
------------------------------------------------------------------------
   PROCEDURE process_new_termination_date (
      p_index_lease_id          IN       NUMBER
     ,p_new_termination_date    IN       DATE
     ,p_ignore_approved_terms   IN       VARCHAR2 --DEFAULT 'N'
     ,p_msg                     OUT NOCOPY      VARCHAR2) AS

      /*Given a new termination date;
        Get the latest date of index of assessment.

        if termination date > latest assessment date
        POSSIBLE EXTENSION..
        if duration  between termination date and latest assessment date > assesment frequency
        we have an index rent extension.
        Generate basis periods:
            - index number - start from last one + 1
            - start date (latest assessment date + assessment freq)
            - termination date (new date)
        else
          EARLY TERMINATE...

        end if;*/

      CURSOR il_rec (ip_index_lease_id   IN   NUMBER)
      IS
      SELECT pld.lease_commencement_date
            ,pil.index_lease_number
            ,pil.assessment_date
            ,pil.commencement_date
            ,pil.termination_date
            ,pil.assessment_interval
            ,pil.relationship_default
            ,pil.basis_percent_default
            ,pil.index_finder_months
            ,nvl (pil.index_multiplier, 1) "INDEX_MULTIPLIER"
       FROM pn_index_leases_all pil, pn_lease_details_all pld
       WHERE pld.lease_id = pil.lease_id
       AND pil.index_lease_id = ip_index_lease_id;

       tlinfo                       il_rec%ROWTYPE;

       CURSOR il_recs_to_delete (ip_index_lease_id         IN   NUMBER
                                ,ip_new_termination_date   IN   DATE)
       IS
       SELECT pilp.index_period_id
       FROM pn_index_lease_periods_all pilp
       WHERE pilp.index_lease_id = ip_index_lease_id
       AND pilp.assessment_date > ip_new_termination_date;

       v_latest_assessment_date     DATE;
       v_months_bet_term_assmt_dt   NUMBER;
       v_new_termination_date       DATE;
       v_msg                        VARCHAR2 (1000);
       v_new_commencement_date      DATE; -- used only for debugging...
   BEGIN
      -- getting the latest assessment date for this index rent period
        SELECT MAX (assessment_date)
        INTO v_latest_assessment_date
        FROM pn_index_lease_periods_all
        WHERE index_lease_id = p_index_lease_id;
      -- retreive index lease information.

        OPEN il_rec (p_index_lease_id);
        FETCH il_rec INTO tlinfo;

        IF (il_rec%NOTFOUND) THEN
           CLOSE il_rec;
           v_msg := 'PN_LEASE_NOT_FOUND';
           put_log ('    Error: Index or Main Lease not found');
           p_msg := v_msg;
           RETURN;
        END IF;

        IF tlinfo.commencement_date > p_new_termination_date  THEN
           remove_agreement(p_index_lease_id,p_new_termination_date);
        END IF;

        -- get the date to be used as new termination date.
        -- use the date passed in as a parameter or if none is passed,
        -- use what is saved in the database.
        IF p_new_termination_date IS NOT NULL THEN
           v_new_termination_date := p_new_termination_date;
        ELSE
           v_new_termination_date := tlinfo.termination_date;
        END IF;

        -- determine if an early termination or extension of index rent.
        v_months_bet_term_assmt_dt :=MONTHS_BETWEEN (v_new_termination_date,
                                                     v_latest_assessment_date);


      -- If months between terminate date and latest assessment date is positive,
      --      Processing an index extension,
      -- if negative, Processing an early termination.


      IF v_months_bet_term_assmt_dt > 0 THEN

                 --PROCESSING AN INDEX RENT EXTENSION
                 put_log ('Processing an index rent extension');


                 -- Only extend if the duration between the termination date and
                 -- assessment date is larger than the assessment interval.
                 --

                 IF v_months_bet_term_assmt_dt > (tlinfo.assessment_interval * 12) THEN

                           put_log ('   Definitely Process extension');
                           -- getting the greatest index period_number

                          create_periods (p_index_lease_id              => p_index_lease_id
                                         ,p_ir_start_dt                 => ADD_MONTHS (v_latest_assessment_date
                                                                            , (tlinfo.assessment_interval * 12))
                                         ,p_ir_end_dt                   => v_new_termination_date
                                         ,p_ml_start_dt                 => tlinfo.lease_commencement_date
                                         ,p_date_assessed               => tlinfo.assessment_date
                                         ,p_assessment_freq_years       => tlinfo.assessment_interval
                                         ,p_index_finder_months         => tlinfo.index_finder_months
                                         ,p_relationship_default        => tlinfo.relationship_default
                                         ,p_basis_percent_default       => tlinfo.basis_percent_default
                                         ,p_starting_period_num         => NULL
                                         ,p_index_multiplier            => tlinfo.index_multiplier);
                          v_msg := 'PN_TERM_DATE_EXTENSION';
                  END IF;
      ELSE
                  ----PROCESSING AN INDEX RENT TERMINATION
                  put_log ('Processing an index rent early termination request');

                  --
                  -- check if any of the periods to be deleted have approved payment terms
                  --


               /*IF p_ignore_approved_terms = 'N' THEN
                            FOR il_rec IN il_recs_to_delete (p_index_lease_id, v_new_termination_date)
                            LOOP
                                pn_index_lease_common_pkg.chk_for_approved_index_periods (
                                p_index_lease_id              => p_index_lease_id
                               ,p_index_lease_period_id       => il_rec.index_period_id
                               ,p_msg                         => v_msg);
                                DBMS_OUTPUT.put_line (   '*******V_MSG='
                                     || v_msg);
                                EXIT WHEN v_msg = 'PN_APPROVED_PERIODS_FOUND';
                            END LOOP;
                  ELSE
                            v_msg := NULL;
                  END IF;  */

                  --
            -- if at least one approved payment term is found...
            --
            --IF v_msg = 'PN_APPROVED_PERIODS_FOUND' THEN
            --
            -- set error message
            --
            --   v_msg := 'PN_TERM_DATE_INV_APPR_PRDS';
            --ELSE


            --
            -- for early termination, delete all periods that have an assessment date,
            -- after the termination date
            --
            FOR il_rec IN il_recs_to_delete (p_index_lease_id, v_new_termination_date)
            LOOP
               put_log('process new termination date'||il_rec.index_period_id);

       --      IF p_ignore_approved_terms = 'Y' THEN
                  delete_periods (
                     p_index_lease_id              => p_index_lease_id
                    ,p_index_period_id             => il_rec.index_period_id
                    ,p_ignore_approved_terms       => 'ALL'
                    ,p_new_termination_date        => p_new_termination_date);

              /* ELSE
                  delete_periods (
                     p_index_lease_id              => p_index_lease_id
                    ,p_index_period_id             => il_rec.index_period_id
                    ,p_ignore_approved_terms       => 'N');
               END IF; */
            END LOOP;

            v_msg := 'PN_TERM_DATE_EARLY_TERMINATION';
         --END IF; --V_MSG = 'PN_APPROVED_PERIODS_FOUND'
      END IF; --v_months_bet_term_assmt_dt > 0

      CLOSE il_rec;
      print_basis_periods (p_index_lease_id);
      --p_msg := 'Comm Date:'||TO_CHAR( v_new_commencement_date, 'dd-Mon-yyyy   ...' ) ||v_msg;
      p_msg := v_msg;
   END process_new_termination_date;


--------------------------------------------------------------------------------
-- PROCEDURE :  recalc_ot_payment_terms
-- DESCRIPTION: This procedure will recalculate payment terms amounts
--              for one time recurring/atleast index rent payment terms
--              when the main lease is expanded.
--  19-OCT-04  STripathi o BUG# 3961117 - get calculate_date and pass it for not
--                         to create backbills if Assessment Date <= CutOff Date
--  19-SEP-05  piagrawa  o Modified to pass org id in call to Get_Calculate_Date
--  04-Jan-06  Kiran     o Bug # 4922324 - fixed query
--                         SELECT '1' INTO v_approved_sch.. for perf.
--  19-JAN-06  piagrawa  o Bug#4931780 - Modified signature and did handling to
--                         make sure that recalculation done only if norm end
--                         date > cut off date or term end date > cut off date
--  16-NOV-06  Prabhakar o Added p_end_date parameter in calls to the procedure
--                         create_payment_record.
--------------------------------------------------------------------------------

PROCEDURE recalc_ot_payment_terms (ip_lease_id IN NUMBER,
                                   ip_index_lease_id IN NUMBER,
                                   ip_old_main_lease_term_date IN DATE,
                                   ip_new_main_lease_term_date IN DATE,
                                   ip_context IN VARCHAR2,
                                   ip_rounding_flag IN VARCHAR2,
                                   ip_relationship IN VARCHAR2,
                                   ip_cutoff_date IN DATE)
IS

   CURSOR cur_payment_terms(p_index_lease_id IN NUMBER)
   IS
      SELECT pilp.index_period_id,
             pilp.assessment_date,
             pilp.basis_start_date,
             ppt.payment_term_id,
             ppt.start_date,
             ppt.location_id,
             ppt.payment_purpose_code,
             ppt.frequency_code,
             ppt.normalize,
             ppt.index_term_indicator,
             ppt.status,
             ppt.currency_code,
             ppt.actual_amount,
             ppt.estimated_amount,
             decode(ppt.actual_amount,null,ppt.estimated_amount,ppt.actual_amount) term_amount,
             ppt.org_id,
             ppt.norm_end_date
      FROM pn_payment_terms_all ppt,
           pn_index_lease_periods_all pilp
      WHERE ppt.index_period_id =  pilp.index_period_id
      AND pilp.index_lease_id = p_index_lease_id
      AND ppt.frequency_code = pn_index_amount_pkg.c_spread_frequency_one_time
      AND ppt.index_term_indicator not in(pn_index_amount_pkg.c_index_pay_term_type_atlst_bb,
                                          pn_index_amount_pkg.c_index_pay_term_type_backbill)
      AND ppt.start_date =  ppt.end_date
      AND NVL( decode(ppt.actual_amount,null,ppt.estimated_amount,ppt.actual_amount),0 ) <> 0;

   CURSOR cur_total_amount(p_payment_term_id IN NUMBER)
   IS
      SELECT sum(ppi.actual_amount) total_amount
      FROM pn_payment_items_all ppi
      WHERE ppi.payment_term_id = p_payment_term_id
      AND ppi.payment_item_type_lookup_code = 'CASH';

   v_old_num_months            NUMBER;
   v_new_num_months            NUMBER;
   v_total_amount              NUMBER := 0;
   v_prorated_amount           NUMBER := 0;
   v_new_amount                NUMBER := 0;
   v_exp_amount                NUMBER := 0;
   v_con_amount                NUMBER := 0;
   v_start_date                PN_PAYMENT_TERMS.start_date%type := null;
   v_term_start_date           DATE := null;
   v_term_day                  NUMBER;
   v_term_mth_year             VARCHAR2(20);
   l_precision                 NUMBER;
   l_ext_precision             NUMBER;
   l_min_acct_unit             NUMBER;
   v_approved_sch              NUMBER := 0;
   v_msg                       VARCHAR2(2000);
   l_payment_term_id           PN_PAYMENT_TERMS.PAYMENT_TERM_ID%TYPE;
   l_calculate_date            DATE;

BEGIN
  put_log('Recalculating one time index rent payment terms ..');
  put_log('Context       :'||ip_context);
  put_log('Index Lease id :'||ip_index_lease_id);
  put_log('---------------');

  FOR rec_payment_terms in cur_payment_terms(ip_index_lease_id)
  LOOP
     put_log('Index Period id : '||rec_payment_terms.index_period_id);
     put_log('Payment term id : '||rec_payment_terms.payment_term_id);

     v_total_amount := 0;
     v_new_amount := 0;
     IF rec_payment_terms.status = pn_index_amount_pkg.c_payment_term_status_approved THEN

        FOR rec_total_amount in cur_total_amount(rec_payment_terms.payment_term_id)
            LOOP
           v_total_amount := rec_total_amount.total_amount;
        END LOOP;
     ELSE
        v_total_amount := rec_payment_terms.term_amount;
     END IF;

     l_calculate_date := pn_index_amount_pkg.Get_Calculate_Date(
                             p_assessment_date => rec_payment_terms.assessment_date
                            ,p_period_str_date => rec_payment_terms.basis_start_date
                            ,p_org_id          => rec_payment_terms.org_id
                            );

     IF trunc(rec_payment_terms.assessment_date) < trunc(rec_payment_terms.start_date) THEN
        IF to_char(rec_payment_terms.assessment_date,'DD') >
           to_char(rec_payment_terms.start_date,'DD') THEN
           v_term_mth_year := to_char(  rec_payment_terms.start_date,'mm/yyyy');
        ELSE
           v_term_mth_year := to_char( last_day(rec_payment_terms.start_date)+1,'mm/yyyy');
        END IF;

        v_term_start_date := TO_DATE( to_char(rec_payment_terms.assessment_date,'dd')||'/'||
                                      v_term_mth_year,'dd/mm/yyyy');
     ELSE
        v_term_start_date := rec_payment_terms.start_date;
     END IF;

     v_old_num_months := CEIL (MONTHS_BETWEEN (ip_old_main_lease_term_date,
                                               v_term_start_date));
     v_new_num_months := CEIL (MONTHS_BETWEEN (ip_new_main_lease_term_date,
                                               v_term_start_date));

     v_prorated_amount := v_total_amount / v_old_num_months;
     v_new_amount := v_prorated_amount * v_new_num_months;

     IF ip_context = 'EXP'   THEN

        IF (( rec_payment_terms.normalize = 'Y'
         AND NVL(rec_payment_terms.norm_end_date, rec_payment_terms.start_date) > ip_cutoff_date)
         OR  ( NVL(rec_payment_terms.normalize,'N') = 'N' AND rec_payment_terms.start_date > ip_cutoff_date))
        THEN
           v_exp_amount := v_new_amount - v_total_amount;
           v_start_date := trunc(ip_old_main_lease_term_date) + 1;

           IF v_exp_amount <> 0 THEN
              pn_index_amount_pkg.create_payment_term_record (
                  p_lease_id               => ip_lease_id
                 ,p_location_id            => rec_payment_terms.location_id
                 ,p_purpose_code           => rec_payment_terms.payment_purpose_code
                 ,p_index_period_id        => rec_payment_terms.index_period_id
                 ,p_term_template_id       => NULL
                 ,p_spread_frequency       => rec_payment_terms.frequency_code
                 ,p_rounding_flag          => ip_rounding_flag
                 ,p_payment_amount         => v_exp_amount
                 ,p_normalized             => rec_payment_terms.normalize
                 ,p_start_date             => rec_payment_terms.start_date
                 ,p_index_term_indicator   => rec_payment_terms.index_term_indicator
                 ,p_payment_term_id        => rec_payment_terms.payment_term_id
                 ,p_basis_relationship     => ip_relationship
                 ,p_called_from            => 'MAIN'
                 ,p_calculate_date         => l_calculate_date
                 ,op_payment_term_id       => l_payment_term_id
                 ,op_msg                   => v_msg
                 ,p_end_date               => NULL);
           END IF;
         END IF;
     ELSIF ip_context = 'CON'  THEN
        IF v_new_amount <> v_total_amount AND
           NVL(v_new_amount,0) <> 0  THEN

           BEGIN

              SELECT '1'
              INTO   v_approved_sch
              FROM   pn_payment_schedules_all pps
              WHERE  pps.payment_schedule_id IN
                     (SELECT ppt.payment_schedule_id
                      FROM pn_payment_items_all ppt
                      WHERE ppt.payment_term_id = rec_payment_terms.payment_term_id
                      AND   ppt.export_currency_amount <> 0
                      AND   ppt.payment_item_type_lookup_code = 'CASH')
              AND   pps.payment_status_lookup_code = 'APPROVED'
              AND   ROWNUM < 2;

           EXCEPTION
              WHEN no_data_found THEN null;
              WHEN others THEN put_log (  'Unknow Error:' || SQLERRM);
           END;

           IF NVL(v_approved_sch,0)  <> 1 THEN
              fnd_currency.get_info(rec_payment_terms.currency_code, l_precision,l_ext_precision,
                                    l_min_acct_unit);
              v_new_amount := ROUND(v_new_amount, l_precision);

              IF rec_payment_terms.actual_amount IS NOT NULL THEN
                 UPDATE pn_payment_terms_all
                 SET    actual_amount = v_new_amount,
                        last_update_date = SYSDATE,
                        last_updated_by = fnd_global.user_id,
                        last_update_login = fnd_global.login_id
                 WHERE payment_term_id = rec_payment_terms.payment_term_id;

                 BEGIN
                    UPDATE pn_payment_items_all
                    SET   actual_amount = v_new_amount,
                          export_currency_amount = v_new_amount,
                          last_update_date = SYSDATE,
                          last_updated_by = fnd_global.user_id,
                          last_update_login = fnd_global.login_id
                    WHERE payment_term_id = rec_payment_terms.payment_term_id
                    AND   export_currency_amount <> 0
                    AND   payment_item_type_lookup_code = 'CASH';

                 EXCEPTION
                    WHEN no_data_found THEN null;
                 END;

              ELSIF rec_payment_terms.estimated_amount IS NOT NULL THEN

                 UPDATE pn_payment_terms_all
                 SET    estimated_amount = v_new_amount,
                        last_update_date = SYSDATE,
                        last_updated_by = fnd_global.user_id,
                        last_update_login = fnd_global.login_id
                 WHERE payment_term_id = rec_payment_terms.payment_term_id;

                 BEGIN
                    UPDATE pn_payment_items_all
                    SET    actual_amount = v_new_amount,
                           estimated_amount = v_new_amount,
                           export_currency_amount = v_new_amount,
                           last_update_date = SYSDATE,
                           last_updated_by = fnd_global.user_id,
                           last_update_login = fnd_global.login_id
                    WHERE payment_term_id = rec_payment_terms.payment_term_id
                    AND   export_currency_amount <> 0
                    AND   payment_item_type_lookup_code = 'CASH';

                 EXCEPTION
                    WHEN no_data_found THEN null;
                 END;

              END IF;  -- v_actual_amount is not null
           ELSE
              v_con_amount := v_new_amount - v_total_amount ;

              pn_index_amount_pkg.create_payment_term_record (
                  p_lease_id               => ip_lease_id
                 ,p_location_id            => rec_payment_terms.location_id
                 ,p_purpose_code           => rec_payment_terms.payment_purpose_code
                 ,p_index_period_id        => rec_payment_terms.index_period_id
                 ,p_term_template_id       => NULL
                 ,p_spread_frequency       => rec_payment_terms.frequency_code
                 ,p_rounding_flag          => ip_rounding_flag
                 ,p_payment_amount         => v_con_amount
                 ,p_normalized             => rec_payment_terms.normalize
                 ,p_start_date             => rec_payment_terms.start_date
                 ,p_index_term_indicator   => rec_payment_terms.index_term_indicator
                 ,p_payment_term_id        => rec_payment_terms.payment_term_id
                 ,p_basis_relationship     => ip_relationship
                 ,p_called_from            => 'MAIN'
                 ,p_calculate_date         => l_calculate_date
                 ,op_payment_term_id       => l_payment_term_id
                 ,op_msg                   => v_msg
                 ,p_end_date               => NULL);

           END IF;  -- v_draft_sch = 1

        END IF;
     END IF;  -- ip_context = 'EXP' ...
  END LOOP;
EXCEPTION
   WHEN OTHERS then
      put_log (  'Unknow Error:' || SQLERRM);

END recalc_ot_payment_terms;


-------------------------------------------------------------------------------------
-- PROCEDURE  :  Process_main_lease_term_date
-- DESCRIPTION:  This procedure will be called every time a new termination
--               create periods for an index rent
--
-- HISTORY:
-- 24-AUG-04 ftanudja o Added logic to check profile option value before
--                      extending index rent term. #3756208.
-- 23-NOV-05 pikhar   o Passed org_id in pn_mo_cache_utils.get_profile_value
-- 19-JAN-06 piagrawa o Bug#4931780 - Modified signature and did handling to
--                      make sure that recalculation done only if norm end
--                      date > cut off date or term end date > cut off date
-- 01-NOV-2006 prabhakar o added basis type and reference type records to il_rec
--                         and added p_end_date in call to create_payment_term_record
--                         for term length option.
-- 09-OCT-06 Hareesha o Added handling to extend RI agreements when lease
--                      extended due to MTM/HLD.
-- 03-JAN-07 Hareesha o Bug #5738834 when sys-opt to extend RI on lease expansion is
--                      set to Yes and context is 'EXP', then extend only terms
--                      ending on old effective lease end date.
-- 09-JAN-07 lbala    o Removed code which changes schedule_day to the value
--                      returned by procedure get_schedule_date for M28 item#11
-- 07-APR-07 Hareesha o Added handling of expansion of RI terms upon the profile-option
--                      PN_RENT_INCREASE_TERM_END_DATE
-- 18-APR-07 sdmahesh o Bug # 5985779. Enhancement for new profile
--                      option for lease early termination.
--                      Added p_term_end_dt. For DRAFT terms contraction,set the end
--                      date as NVL(P_TERM_END_DT,P_NEW_MAIN_LEASE_TERM_DATE)
-- 22-Jan-10 jsundara o Bug#8839033. Modified Submission of CALNDX to send
--                      "Recalculate Index" parameter as 'N'
--------------------------------------------------------------------------------------
   PROCEDURE process_main_lease_term_date (
      p_lease_id                   IN       NUMBER
     ,p_new_main_lease_term_date   IN       DATE
     ,p_old_main_lease_term_date   IN       DATE
     ,p_lease_context              IN       VARCHAR2
     ,p_msg                        OUT NOCOPY      VARCHAR2
     ,p_cutoff_date                IN       DATE
     ,p_term_end_dt                IN       DATE) AS
      /*

        A new lease termination date can impact index rent.  It can:
               - decrease the number of index rent assessment periods
               - extend or early terminate the unapproved index rent payment terms:


          get all index rents for a given lease

               for each index rent lease

                    if the IR termination date > ML termination date then
                         - early terminate the index rent
                    end if;

                    update of the end date of any index rent payment term that were:
                         - that are non-approved.
                         - whose frequency is NOT one time...

               end for

       */
      CURSOR il_rec (
         ip_lease_id   IN   NUMBER) IS
         SELECT pil.index_lease_id
               ,pil.index_lease_number
               ,pil.assessment_date
               ,pil.commencement_date
               ,pil.termination_date
               ,pil.assessment_interval
               ,pil.relationship_default
               ,pil.basis_percent_default
               ,pil.rounding_flag
               ,pil.org_id
               ,pil.basis_type
               ,pil.reference_period
           FROM pn_index_leases_all pil
          WHERE pil.lease_id = ip_lease_id;

      tlinfo   il_rec%ROWTYPE;
      v_msg    VARCHAR2 (1000);
      l_profile_value pn_system_setup_options.extend_indexrent_term_flag%TYPE;
      v_max_index_period_id                NUMBER;
      v_max_assessment_date                DATE;
      v_last_period_assess_end_date        DATE;

      CURSOR get_last_index_period_cur(p_index_lease_id NUMBER) IS
      SELECT max(index_period_id) last_index_period_id, max(assessment_date) last_assessment_date
      FROM pn_index_lease_periods_all
      WHERE index_lease_id = p_index_lease_id;

      CURSOR extendable_index_cur(p_old_ls_end_date IN DATE) IS
         SELECT index_lease_id
         FROM   pn_index_leases_all
         WHERE  lease_id = p_lease_id
         AND    termination_date =  p_old_ls_end_date;

     CURSOR  index_periods_cur (p_index_lease_id NUMBER ) IS
         SELECT  index_period_id
         FROM    pn_index_lease_periods_all
         WHERE   index_lease_id = p_index_lease_id
         AND     assessment_date > p_old_main_lease_term_date;

      CURSOR get_term_4_mtm_update(p_index_lease_id NUMBER) IS
         SELECT term.payment_term_id payment_term_id,
                NVL(term.normalize,'N') normalize
         FROM  pn_payment_terms_all term,pn_index_lease_periods_all period
         WHERE term.index_period_id = period.index_period_id
         AND   period.index_lease_id  = p_index_lease_id
         AND   term.frequency_code  <> pn_index_amount_pkg.c_spread_frequency_one_time
         AND   term.end_date = p_old_main_lease_term_date;

      CURSOR get_term_details ( p_term_id NUMBER) IS
         SELECT *
         FROM pn_payment_terms_all
         WHERE payment_term_id = p_term_id;

      CURSOR get_old_ls_end_date IS
         SELECT NVL(plh.lease_extension_end_date, plh.lease_termination_date) old_ls_end_date
         FROM  pn_lease_details_history plh,
               pn_lease_details_all pld
        WHERE  pld.lease_change_id = plh.new_lease_change_id
        AND    pld.lease_id = p_lease_id;

      CURSOR get_lease_comm_date IS
         SELECT lease_commencement_date
         FROM pn_lease_details_all
         WHERE lease_id = p_lease_id;

      CURSOR get_lease_num IS
         SELECT lease_num
         FROM pn_leases_all
         WHERE lease_id = p_lease_id;

      CURSOR get_appr_terms_to_extend(p_index_lease_id IN NUMBER) IS
         SELECT *
         FROM pn_payment_terms_all
         WHERE payment_term_id IN ( SELECT payment_term_id
                                    FROM pn_payment_terms_all terms, pn_index_lease_periods_all period
                                    WHERE terms.index_period_id = period.index_period_id
                                    AND   period.index_lease_id = p_index_lease_id)
         AND status ='APPROVED'
         AND frequency_code <>'OT'
         AND end_date = p_old_main_lease_term_date;

      l_term_rec pn_payment_terms_all%ROWTYPE;
      l_return_status   VARCHAR2(100);
      l_schd_date       DATE := NULL;
      l_schd_day        NUMBER := NULL;
      l_extended        BOOLEAN := FALSE;
      INVALID_SCHD_DATE EXCEPTION;
      l_old_ls_end_date DATE := NULL;
      l_ls_comm_dt      DATE ;
      l_mths            NUMBER;
      l_requestId       NUMBER := NULL;
      l_lease_num       PN_LEASES_ALL.lease_num%TYPE;
      l_ri_term_rec     pn_payment_terms_all%ROWTYPE;

   BEGIN
      put_log('Processing Main Lease Termination Date for Index Rent increases');
      put_log('Parameters ');
      put_log('---------------------------------');
      put_log('lease_id             : '||p_lease_id);
      put_log('new termination date : '||p_new_main_lease_term_date);
      put_log('old termination date : '||p_old_main_lease_term_date);
      put_log('Lease context        : '||p_lease_context);

      FOR lease_comm_dt_rec IN get_lease_comm_date LOOP
         l_ls_comm_dt := lease_comm_dt_rec.lease_commencement_date;
      END LOOP;

      l_mths := ROUND(MONTHS_BETWEEN(p_new_main_lease_term_date,l_ls_comm_dt))+1;

      FOR c_rec IN il_rec (p_lease_id)
      LOOP
         --
         -- if the index rent termination date  is later than
         --    the new main lease termination date
         --
         put_log(' index lease id '|| c_rec.index_lease_id);
         IF trunc(c_rec.termination_date) > trunc(p_new_main_lease_term_date) THEN
            --
            -- adjust index rent periods with the new termination date
            --
            put_log(' processing new term date ');
            process_new_termination_date (
               p_index_lease_id              => c_rec.index_lease_id
              ,p_new_termination_date        => p_new_main_lease_term_date
              ,p_ignore_approved_terms       => 'Y'
              ,p_msg                         => v_msg);

            --
            -- update index rent with a new termination date
            --
            UPDATE pn_index_leases_all
               SET termination_date = GREATEST(p_new_main_lease_term_date,commencement_date)
                  ,last_update_date = SYSDATE
                  ,last_updated_by = fnd_global.user_id
                  ,last_update_login = fnd_global.login_id
             WHERE index_lease_id = c_rec.index_lease_id;
         END IF; -- c_rec.termination_date > p_new_main_lease_term_date

         IF p_lease_context IN ('EXP') AND
            NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') ='END_LEASE'
         THEN
            handle_MTM_ACT ( p_lease_id      => p_lease_id,
                             p_extended      => l_extended,
                             x_return_status => l_return_status);

         END IF;

         l_profile_value
           := nvl(pn_mo_cache_utils.get_profile_value('PN_EXTEND_INDEXRENT_TERM', c_rec.org_id),'Y');

         IF (l_profile_value = 'Y' AND p_lease_context='EXP') OR
             p_lease_context IN ('CON','ROLLOVER','ROLLOVER_RI') THEN

            IF trunc(p_new_main_lease_term_date) <> trunc(p_old_main_lease_term_date)  THEN
               --
               -- update one-time payment terms which are not created
               -- as part of a backbill, in effect extending the term
               -- end date
               --

               recalc_ot_payment_terms (
                    ip_lease_id                  => p_lease_id,
                    ip_index_lease_id            => c_rec.index_lease_id,
                    ip_old_main_lease_term_date  => p_old_main_lease_term_date,
                    ip_new_main_lease_term_date  => p_new_main_lease_term_date,
                    ip_context                   => p_lease_context,
                    ip_rounding_flag             => c_rec.rounding_flag,
                    ip_relationship              => c_rec.relationship_default,
                    ip_cutoff_date               => p_cutoff_date);
            END IF;

            --
            -- updating the end date of any non-approved index rent
            -- payment terms..
            --
            IF nvl(fnd_profile.value('PN_IR_TERM_END_DATE'),'LEASE_END') = 'LEASE_END' OR
               (c_rec.basis_type <> 'FIXED' AND c_rec.reference_period <> 'BASE_YEAR') THEN

               IF p_lease_context='EXP' AND NOT(l_extended) AND
                  NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') ='END_LEASE'
               THEN
                  UPDATE pn_payment_terms_all
                     SET end_date = p_new_main_lease_term_date,
                         last_update_date = SYSDATE,
                         last_updated_by = fnd_global.user_id,
                         last_update_login = fnd_global.login_id
                  WHERE payment_term_id IN
                        (SELECT ppt.payment_term_id
                           FROM pn_payment_terms_all ppt, pn_index_lease_periods_all pilp
                           WHERE pilp.index_period_id = ppt.index_period_id
                           AND pilp.index_lease_id = c_rec.index_lease_id
                           AND p_lease_context <> 'CON'
                           AND ppt.frequency_code <>
                              pn_index_amount_pkg.c_spread_frequency_one_time
                           AND ppt.end_date > p_cutoff_date)
                    AND end_date = p_old_main_lease_term_date;

               ELSIF  p_lease_context='CON' THEN
                  UPDATE pn_payment_terms_all
                     SET end_date = NVL(p_term_end_dt,p_new_main_lease_term_date),
                        last_update_date = SYSDATE,
                        last_updated_by = fnd_global.user_id,
                        last_update_login = fnd_global.login_id
                  WHERE payment_term_id IN
                        (SELECT ppt.payment_term_id
                           FROM pn_payment_terms_all ppt, pn_index_lease_periods_all pilp
                           WHERE pilp.index_period_id = ppt.index_period_id
                            AND pilp.index_lease_id = c_rec.index_lease_id
                            AND (ppt.status = pn_index_amount_pkg.c_payment_term_status_draft AND
                                p_lease_context = 'CON')
                            AND ppt.frequency_code <>
                                pn_index_amount_pkg.c_spread_frequency_one_time);
               END IF;

            ELSIF nvl(fnd_profile.value('PN_IR_TERM_END_DATE'),'LEASE_END') = 'PERIOD_END' AND
                  (c_rec.basis_type = 'FIXED' AND c_rec.reference_period = 'BASE_YEAR') AND
                   p_lease_context='CON' THEN

                FOR get_last_index_period_rec IN get_last_index_period_cur(c_rec.index_lease_id) LOOP
                    v_max_index_period_id := get_last_index_period_rec.last_index_period_id;
                    v_max_assessment_date := get_last_index_period_rec.last_assessment_date;
                END LOOP;
                    v_last_period_assess_end_date := add_months(v_max_assessment_date, 12*(c_rec.assessment_interval)) -1;
                UPDATE pn_payment_terms_all
                  SET end_date = least(NVL(p_term_end_dt,p_new_main_lease_term_date), v_last_period_assess_end_date),
                      last_update_date = SYSDATE,
                      last_updated_by = fnd_global.user_id,
                      last_update_login = fnd_global.login_id
                WHERE payment_term_id IN
                      (SELECT ppt.payment_term_id
                         FROM pn_payment_terms_all ppt, pn_index_lease_periods_all pilp
                        WHERE pilp.index_period_id = ppt.index_period_id
                          AND pilp.index_lease_id = c_rec.index_lease_id
                          AND (ppt.status = pn_index_amount_pkg.c_payment_term_status_draft AND
                                p_lease_context = 'CON')
                          AND ppt.frequency_code <>
                              pn_index_amount_pkg.c_spread_frequency_one_time)
                      AND index_period_id = v_max_index_period_id;

            END IF;
         END IF;

      IF (p_lease_context IN ('ROLLOVER','ROLLOVER_RI') AND
         (nvl(fnd_profile.value('PN_IR_TERM_END_DATE'),'LEASE_END') = 'LEASE_END' OR
          (c_rec.basis_type <> 'FIXED' AND c_rec.reference_period <> 'BASE_YEAR')) AND
          NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') ='END_LEASE' ) OR
          ( p_lease_context IN ('ROLLOVER_RI') AND
            NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') ='END_AGRMNT')
      THEN
         FOR terms_rec IN get_term_4_mtm_update(c_rec.index_lease_id) LOOP

            FOR term_details_rec IN get_term_details(terms_rec.payment_term_id) LOOP
               l_term_rec := term_details_rec;
            END LOOP;

            IF terms_rec.normalize = 'Y' THEN

               l_term_rec.start_date      := p_old_main_lease_term_date + 1;
               l_term_rec.end_date        := p_new_main_lease_term_date;
               l_term_rec.normalize       := 'N';
               l_term_rec.parent_term_id  := terms_rec.payment_term_id;
               l_term_rec.index_norm_flag := 'Y';
               l_term_rec.lease_status    := 'MTM';
               l_term_rec.status          := 'DRAFT';

               pn_schedules_items.Create_Payment_Term
                            (p_payment_term_rec  => l_term_rec,
                             p_lease_end_date    => p_new_main_lease_term_date,
                             p_term_start_date   => l_term_rec.start_date,
                             p_term_end_date     => l_term_rec.end_date ,
                             p_new_lea_term_dt   => p_new_main_lease_term_date,
                             p_new_lea_comm_dt   => l_ls_comm_dt,
                             p_mths              => l_mths,
                             x_return_status     => l_return_status,
                             x_return_message    => v_msg);


            ELSIF terms_rec.normalize = 'N' THEN

               l_schd_date := pn_schedules_items.Get_Schedule_Date (
                         p_lease_id   => p_lease_id,
                         p_day        => l_term_rec.schedule_day,
                         p_start_date => p_old_main_lease_term_date + 1,
                         p_end_date   => p_new_main_lease_term_date,
                         p_freq       => pn_schedules_items.get_frequency(l_term_rec.frequency_code)
                         );

              l_schd_day  := TO_NUMBER(TO_CHAR(l_schd_date,'DD'));
              IF l_schd_day <> l_term_rec.schedule_day THEN
                 l_term_rec.start_date      := p_old_main_lease_term_date + 1;
                 l_term_rec.end_date        := p_new_main_lease_term_date;
                 l_term_rec.status          := 'DRAFT';

                 pn_schedules_items.Create_Payment_Term
                            (p_payment_term_rec  => l_term_rec,
                             p_lease_end_date    => p_new_main_lease_term_date,
                             p_term_start_date   => l_term_rec.start_date,
                             p_term_end_date     => l_term_rec.end_date ,
                             p_new_lea_term_dt   => p_new_main_lease_term_date,
                             p_new_lea_comm_dt   => l_ls_comm_dt,
                             p_mths              => l_mths,
                             x_return_status     => l_return_status,
                             x_return_message    => v_msg);
              ELSE

                 l_term_rec.end_date := p_new_main_lease_term_date;

                 UPDATE pn_payment_terms_all
                 SET end_date = p_new_main_lease_term_date,
                     last_update_date  = SYSDATE,
                     last_updated_by   = fnd_global.user_id,
                     last_update_login = fnd_global.login_id
                 WHERE payment_term_id = terms_rec.payment_term_id;

                 pn_schedules_items.Extend_Payment_Term
                            (p_payment_term_rec => l_term_rec,
                             p_new_lea_comm_dt   => l_ls_comm_dt,
                             p_new_lea_term_dt   => p_new_main_lease_term_date,
                             p_mths              => l_mths,
                             p_new_start_date    => p_old_main_lease_term_date + 1,
                             p_new_end_date      => p_new_main_lease_term_date,
                             x_return_status     => l_return_status,
                             x_return_message    => v_msg);

              END IF;
           END IF;
         END LOOP;

        END IF;
     END LOOP;

      /* Extend RI agreements and create/expand periods when lease
         extended due to MTM/HLD */
      IF p_lease_context IN ('ROLLOVER_RI','EXP_RI') THEN

         FOR rec IN get_old_ls_end_date LOOP
            l_old_ls_end_date := rec.old_ls_end_date;
         END LOOP;

         FOR lease_num_rec IN get_lease_num LOOP
            l_lease_num := lease_num_rec.lease_num;
         END LOOP;


         FOR index_leases_rec IN extendable_index_cur(l_old_ls_end_date)
         LOOP
            UPDATE pn_index_leases_all
            SET    termination_date = p_new_main_lease_term_date,
                   last_update_date = SYSDATE,
                   last_updated_by = NVL(fnd_profile.value('USER_ID'),0),
                   last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
            WHERE  index_lease_id   = index_leases_rec.index_lease_id;


            -- This will create new period for index rent for extended period
            pn_index_rent_periods_pkg.process_new_termination_date (
               p_index_lease_id          => index_leases_rec.index_lease_id
              ,p_new_termination_date    => p_new_main_lease_term_date
              ,p_ignore_approved_terms   => 'N'
              ,p_msg                     => v_msg);

            IF p_lease_context = 'EXP_RI' AND
               NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') ='END_AGRMNT'
            THEN

               FOR appr_terms_rec IN get_appr_terms_to_extend( index_leases_rec.index_lease_id) LOOP

                  l_ri_term_rec := appr_terms_rec;

                  UPDATE pn_payment_terms_all
                  SET end_date = p_new_main_lease_term_date,
                      last_update_date  = SYSDATE,
                      last_updated_by   = fnd_global.user_id,
                      last_update_login = fnd_global.login_id
                  WHERE payment_term_id = l_ri_term_rec.payment_term_id;

                  pn_schedules_items.Extend_Payment_Term
                            (p_payment_term_rec  => l_ri_term_rec,
                             p_new_lea_comm_dt   => l_ls_comm_dt,
                             p_new_lea_term_dt   => p_new_main_lease_term_date,
                             p_mths              => l_mths,
                             p_new_start_date    => p_old_main_lease_term_date + 1,
                             p_new_end_date      => p_new_main_lease_term_date,
                             x_return_status     => l_return_status,
                             x_return_message    => v_msg);

               END LOOP;
            END IF;

          END LOOP;

            IF p_lease_context = 'EXP_RI' AND
               NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') ='END_AGRMNT'
            THEN

               handle_MTM_ACT ( p_lease_id      => p_lease_id,
                                p_extended      => l_extended,
                                x_return_status => l_return_status);

               IF NOT(l_extended) THEN

                 l_requestId := fnd_request.submit_request
                                                       ('PN',
                                                        'PNCALNDX',
                                                        NULL,
                                                        NULL,
                                                        FALSE,
                              null,null,null,null, null,l_lease_num,null,null,'N',
                              chr(0),  '', '',  '',
                             '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                             '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                             '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                             '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                             '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                             '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                             '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                             '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
                             '',  '',  '',  '',  '',  '',  ''
                               );

               IF (l_requestId = 0 ) THEN
                  pnp_debug_pkg.log(' ');
                  pnp_debug_pkg.log('Could not submit Concurrent Request PNCALNDX'
                                     ||' (PN - Calculate Index Rent)');
                  fnd_message.set_name('PN', 'PN_SCHIT_CONC_FAIL');
                  pnp_debug_pkg.put_log_msg(fnd_message.get);

               ELSE                                        -- Got a request Id
                  pnp_debug_pkg.log(' ');
                  pnp_debug_pkg.log('Concurrent Request '||TO_CHAR(l_requestId)
                                     ||' has been submitted for: PN - Calculate Index Rent');
                  fnd_message.set_name('PN', 'PN_SCHIT_CONC_SUCC');
                  pnp_debug_pkg.put_log_msg(fnd_message.get);
               END IF;
             END IF;

           END IF;
      END IF;

   EXCEPTION
      WHEN INVALID_SCHD_DATE THEN
         v_msg := FND_API.G_RET_STS_ERROR;

   END process_main_lease_term_date;


      ------------------------------------------------------------------------
      -- PROCEDURE : process_payment_term_amendment
      -- DESCRIPTION: This procedure is used by the PNTLEASE form to recalculate index
      --              rent amount when a payment term is added from the main lease.
      --
      -- History:
      --
      -- 22-jul-2001  psidhu
      --              Created.
      ------------------------------------------------------------------------

      PROCEDURE process_payment_term_amendment (
               p_lease_id                        IN      NUMBER
              ,p_payment_type_code               IN      VARCHAR2 --payment_fdr_blk.payment_term_type_code
              ,p_payment_start_date              IN      DATE
              ,p_payment_end_date                IN      DATE
              ,p_msg                             OUT NOCOPY      VARCHAR2)
      IS
         CURSOR cur1 (ip_lease_id            IN NUMBER
                     ,ip_payment_type_code   IN VARCHAR2
                     ,ip_payment_start_date  IN DATE
                     ,ip_payment_end_date    IN DATE)
         IS
         SELECT pil.index_lease_id
               ,pilp.index_period_id
               ,pilp.basis_start_date
               ,pilp.basis_end_date
               ,pilp.line_number
               ,pil.initial_basis
               ,pil.retain_initial_basis_flag
         FROM pn_leases_all pl, pn_index_leases_all pil, pn_index_lease_periods_all pilp
         WHERE pl.lease_id = pil.lease_id
         AND pil.index_lease_id = pilp.index_lease_id
         AND pl.lease_id=p_lease_id
         AND exists(SELECT 'x'
                    FROM pn_index_leases_all pilx
                    WHERE ip_payment_end_date >=(SELECT min(pilpx.basis_start_date)
                                                 FROM pn_index_lease_periods_all pilpx
                                                 WHERE pilpx.index_lease_id=pilx.index_lease_id)
                    AND   pilx.termination_date  >= ip_payment_start_date
                    AND   pilx.index_lease_id=pil.index_lease_id
                    AND (pilx.increase_on=ip_payment_type_code OR
                         pilx.gross_flag='Y')
                     );

         v_msg   VARCHAR2 (1000);
         v_initial_basis_amt  NUMBER := NULL;

         BEGIN

               put_log (   'p_lease_id         '|| p_lease_id);
               put_log ('Processing the Following Lease Periods:');

               -- get all index rent periods to process

               FOR rec1 IN cur1 (p_lease_id
                                ,p_payment_type_code
                                ,p_payment_start_date
                                ,p_payment_end_date)

               LOOP
                      put_log ('Index Lease ID: '|| rec1.index_lease_id||
                               ' Period ID: '|| rec1.index_period_id );
                      --
                      -- call calculate routine to process this index rent period
                      --

                      IF rec1.basis_start_date IS NOT NULL AND
                         rec1.basis_end_date IS NOT NULL   AND
                         ((rec1.initial_basis IS NULL) OR (nvl(rec1.retain_initial_basis_flag,'N') = 'N')) AND
                         rec1.line_number = 1      THEN

                          pn_index_amount_pkg.calculate_initial_basis (
                              p_index_lease_id  => rec1.index_lease_id
                             ,op_basis_amount   => v_initial_basis_amt
                             ,op_msg            => v_msg);

                          UPDATE pn_index_leases_all
                          SET initial_basis = v_initial_basis_amt
                             ,last_update_date = SYSDATE
                             ,last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0)
                          WHERE index_lease_id = rec1.index_lease_id;
                      END IF;

                      pn_index_amount_pkg.calculate (
                              ip_index_lease_id             => rec1.index_lease_id
                             ,ip_index_lease_period_id      => rec1.index_period_id
                             ,ip_recalculate                => 'Y'
                             ,op_msg                        => v_msg
                                                    );
                END LOOP index_lease_period;
    END process_payment_term_amendment;


-------------------------------------------------------------------------------
-- PROCEDURE handle_MTM_ACT
-- DESCRIPTION: This procedure handling of RI terms when lease changes from
--              MTM/HLD to ACT and lease is extended.
-- HISTORY:
-- 17-OCT-06   Hareesha    o Created.
-- 09-JAN-07   lbala       o Removed code to change schedule_date to value returned
--                           by get_schedule_date for M28 item# 11
-------------------------------------------------------------------------------
PROCEDURE handle_MTM_ACT (
      p_lease_id          IN         NUMBER
     ,p_extended          IN OUT NOCOPY BOOLEAN
     ,x_return_status     OUT NOCOPY VARCHAR2)
IS

   l_lease_change_id    NUMBER;
   l_lease_status_old   VARCHAR2(30);
   l_lease_status_new   VARCHAR2(30);
   l_lease_comm_date    DATE;
   l_lease_term_date    DATE;
   l_lease_ext_end_date DATE;
   l_amd_comm_date      DATE;
   l_term_rec           pn_payment_terms_all%ROWTYPE;
   l_term_st_date       DATE;
   v_msg                VARCHAR2(100);
   l_schd_date          DATE;
   l_schd_day           NUMBER := NULL;
   INVALID_SCHD_DATE    EXCEPTION;

   CURSOR get_lease_details(p_lease_id  NUMBER) IS
      SELECT details.lease_change_id              lease_change_id,
             det_history.lease_status             lease_status_old,
             lease.lease_status                   lease_status_new,
             details.lease_commencement_date      lease_comm_date,
             details.lease_termination_date       lease_term_date,
             det_history.lease_extension_end_date lease_ext_end_date,
             changes.change_commencement_date     amd_comm_date
      FROM pn_lease_details_all details,
           pn_lease_details_history det_history,
           pn_lease_changes_all changes,
           pn_leases_all        lease
      WHERE details.lease_id = p_lease_id
      AND   det_history.lease_id = p_lease_id
      AND   changes.lease_id = p_lease_id
      AND   lease.lease_id = p_lease_id
      AND   details.lease_change_id = det_history.new_lease_change_id
      AND   changes.lease_change_id = details.lease_change_id;

   CURSOR get_last_appr_schd_dt (p_lease_id NUMBER) IS
      SELECT MAX(pps.schedule_date) lst_schedule_date
      FROM pn_payment_schedules_all pps
      WHERE pps.payment_status_lookup_code = 'APPROVED'
      AND pps.lease_id = p_lease_id;

   CURSOR get_mtm_terms( p_lease_id NUMBER,p_term_end_date DATE) IS
      SELECT *
      FROM pn_payment_terms_all terms
      WHERE index_period_id IN ( SELECT index_period_id
                                 FROM pn_index_leases_all
                                 WHERE lease_id = p_lease_id)
       AND end_date = p_term_end_date
       AND lease_id = p_lease_id
       AND frequency_code <> 'OT';

   CURSOR get_index_lease_details( p_payment_term_id NUMBER) Is
      SELECT basis_type,
             reference_period
      FROM pn_index_leases_all ileases,
           pn_index_lease_periods_all periods,
      pn_payment_terms_all terms
      WHERE ileases.index_lease_id = periods.index_lease_id
      AND   periods.index_period_id = terms.index_period_id
      AND   terms.payment_term_id = p_payment_term_id;

   l_basis_type VARCHAR2(30);
   l_reference_period VARCHAR2(30);


BEGIN
   put_log('handle_MTM_ACT (+) ');

   FOR rec IN get_lease_details(p_lease_id) LOOP
      l_lease_change_id   := rec.lease_change_id;
      l_lease_status_old  := rec.lease_status_old;
      l_lease_status_new  := rec.lease_status_new;
      l_lease_comm_date   := rec.lease_comm_date;
      l_lease_term_date   := rec.lease_term_date;
      l_lease_ext_end_date :=rec.lease_ext_end_date;
      l_amd_comm_date     := rec.amd_comm_date;
   END LOOP;

   IF l_lease_status_new = 'ACT' AND ( l_lease_status_old = 'MTM' OR l_lease_status_old ='HLD')
      AND l_lease_term_date > l_lease_ext_end_date
   THEN

      FOR term_details IN get_mtm_terms( p_lease_id,l_lease_ext_end_date) LOOP

         l_term_rec := term_details;

         FOR ilease_details IN get_index_lease_details(l_term_rec.payment_term_id) LOOP
            l_basis_type := ilease_details.basis_type;
            l_reference_period := ilease_details.reference_period;
         END LOOP;

         IF NVL(fnd_profile.value('PN_IR_TERM_END_DATE'),'LEASE_END') = 'PERIOD_END' AND
            l_basis_type = 'FIXED' AND l_reference_period = 'BASE_YEAR'
         THEN
            EXIT;
         END IF;

         l_schd_date := pn_schedules_items.get_schedule_date
                        ( p_lease_id   => p_lease_id,
                          p_day        => l_term_rec.schedule_day,
                          p_start_date => l_lease_ext_end_date + 1,
                          p_end_date   => l_lease_term_date,
                          p_freq       => pn_schedules_items.get_frequency(l_term_rec.frequency_code)
                        );

         l_schd_day  := TO_NUMBER(TO_CHAR(l_schd_date,'DD'));

         IF  NVL(term_details.index_norm_flag,'N') = 'Y' AND term_details.parent_term_id IS NOT NULL
         THEN

            FOR lst_appr_sched IN get_last_appr_schd_dt ( p_lease_id) LOOP
               l_term_rec.norm_start_date := lst_appr_sched.lst_schedule_date;
            END LOOP;

            IF l_amd_comm_date > l_term_st_date THEN
               l_term_rec.norm_start_date := l_amd_comm_date;
            END IF;

            l_term_rec.normalize  := 'Y';
            l_term_rec.start_date := l_lease_ext_end_date + 1;
            l_term_rec.end_date   := l_lease_term_date;
            l_term_rec.norm_end_date   := l_lease_term_date;
            l_term_rec.parent_term_id := NVL(l_term_rec.parent_term_id,
                                             l_term_rec.payment_term_id);
            l_term_rec.lease_status := l_lease_status_new;
            l_term_rec.index_norm_flag := NULL;
            l_term_rec.lease_change_id := l_lease_change_id;
            l_term_rec.status := 'DRAFT';

            pn_schedules_items.Insert_Payment_Term
           (  p_payment_term_rec              => l_term_rec,
              x_return_status                 => x_return_status,
              x_return_message                => v_msg   );

            p_extended := TRUE;

         ELSE

            IF l_schd_day <> l_term_rec.schedule_day THEN
               l_term_rec.start_date   := l_lease_ext_end_date + 1;
               l_term_rec.end_date     := l_lease_term_date;
               l_term_rec.lease_change_id := l_lease_change_id;
               l_term_rec.status := 'DRAFT';

                pn_schedules_items.Insert_Payment_Term
                (  p_payment_term_rec              => l_term_rec,
                   x_return_status                 => x_return_status,
                   x_return_message                => v_msg   );

                p_extended := TRUE;

            ELSE

               UPDATE pn_payment_terms_all
               SET end_date          = l_lease_term_date,
                   lease_change_id   = l_lease_change_id,
                   last_update_date  = SYSDATE,
                   last_updated_by   = fnd_global.user_id,
                   last_update_login = fnd_global.login_id
               WHERE payment_term_id = l_term_rec.payment_term_id;

               p_extended := TRUE;

            END IF;

         END IF;
      END LOOP;

   END IF;

   put_log('handle_MTM_ACT (-) ');

EXCEPTION
   WHEN INVALID_SCHD_DATE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status :=  SQLERRM;
      put_log(' handle_MTM_ACT :'||SQLERRM);
      RAISE;
END handle_MTM_ACT;

-------------------------------------------------------------------------------
-- PROCEDURE handle_term_date_change
-- DESCRIPTION: This procedure handles Term-end-dates of RI terms on change of
--              agreement termination date.
-- HISTORY:
-- 03-APR-07   Hareesha  o Created.
-- 04-MAY-07   Pikhar    o Added handling for Updating Natural Breakpoints
-------------------------------------------------------------------------------
PROCEDURE handle_term_date_change (
      p_index_lease_id        IN    NUMBER
      ,p_old_termination_date IN    DATE
      ,p_new_termination_date IN    DATE
      ,p_msg                  OUT NOCOPY VARCHAR2)
IS

   l_payment_term_rec pn_payment_terms_all%ROWTYPE;
   x_return_message           VARCHAR2(2000);
   x_return_status            VARCHAR2(2000);
   l_lease_comm_date          DATE;
   l_lease_term_date          DATE;
   l_mths                     NUMBER;
   l_appr_sched_exists        BOOLEAN := FALSE;
   l_sched_tbl pn_retro_adjustment_pkg.payment_item_tbl_type;
   l_lease_id                 NUMBER;
   l_payment_item_id pn_payment_items_all.payment_item_id%TYPE;
   l_lst_cash_sch_dt          DATE;
   l_var_rent_id              NUMBER;

   CURSOR get_lease_id IS
      SELECT lease_id FROM pn_index_leases_all
      WHERE index_lease_id = p_index_lease_id;

   CURSOR get_ri_terms_to_modify IS
      SELECT *
      FROM pn_payment_terms_all
      WHERE ((index_period_id IN (SELECT index_period_id
                                FROM pn_index_lease_periods_all
                                WHERE index_lease_id = p_index_lease_id))
                  OR
             index_period_id IS NULL)
      AND end_date = p_old_termination_date
      AND frequency_code <>'OT'
      AND status = 'APPROVED';

   CURSOR get_lease_details IS
      SELECT lease_commencement_date,
             lease_termination_date,
             ROUND(MONTHS_BETWEEN(lease_termination_date,lease_commencement_date))+1 p_mts
      FROM pn_lease_details_all
      WHERE lease_id IN (SELECT lease_id
                         FROM pn_index_leases_all
                         WHERE index_lease_id = p_index_lease_id);

   CURSOR approved_sched_exist_cur(p_payment_term_id IN NUMBER)
   IS
      SELECT payment_schedule_id
      FROM pn_payment_schedules_all
      WHERE lease_id IN ( SELECT lease_id
                          FROM pn_payment_terms_all
                          WHERE payment_term_id = p_payment_term_id)
      AND payment_status_lookup_code = 'APPROVED'
      AND payment_schedule_id IN (SELECT payment_schedule_id
                                  FROM   pn_payment_items_all
                                  WHERE  payment_term_id = p_payment_term_id);

   CURSOR total_amt_old_term_cur(p_term_id IN NUMBER) IS
      SELECT SUM(ppi.actual_amount) AS total_amount
      FROM  pn_payment_items_all ppi
      WHERE ppi.payment_term_id = p_term_id
      AND   ppi.payment_item_type_lookup_code = 'CASH';

   CURSOR draft_schedule_exists_cur (p_sched_date DATE) IS
      SELECT pps.payment_schedule_id
      FROM   pn_payment_schedules_all pps
      WHERE  pps.schedule_date = p_sched_date
      AND    pps.lease_id IN (SELECT lease_id FROM pn_index_leases_all
                              WHERE index_lease_id = p_index_lease_id)
      AND    pps.payment_status_lookup_code = 'DRAFT';

   CURSOR cash_item_exist_cur(p_sched_id NUMBER,p_payment_term_id IN NUMBER) IS
      SELECT payment_item_id
      FROM   pn_payment_items_all
      WHERE  payment_item_type_lookup_code = 'CASH'
      AND    payment_schedule_id = p_sched_id
      AND    payment_term_id = p_payment_term_id;


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

   l_amt_due_to_term      NUMBER :=0;
   l_amt_due_to_old_term  NUMBER;
   l_cash_act_amt         NUMBER;
   l_last_sched_draft     VARCHAR2(1);
   l_payment_schedule_id  pn_payment_items_all.payment_schedule_id%TYPE;
   l_lease_change_id      NUMBER;
   l_errbuf               VARCHAR2(80);
   l_retcode              VARCHAR2(80);
   l_update_nbp_flag      VARCHAR2(1);
   l_dummy                VARCHAR2(1);

BEGIN

   put_log('handle_term_date_change (+) ');

  IF NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') = 'END_AGRMNT' AND
      p_old_termination_date <> p_new_termination_date
   THEN

      /* RI agreement expansion */

      FOR lease_id_rec IN get_lease_id LOOP
          l_lease_id := lease_id_rec.lease_id;
      END LOOP;

      IF p_old_termination_date < p_new_termination_date THEN
         p_msg := 'RI agreement expansion';

         FOR ri_terms_rec IN get_ri_terms_to_modify LOOP
            l_payment_term_rec := ri_terms_rec;

            UPDATE pn_payment_terms_all
            SET end_date = p_new_termination_date
            WHERE payment_term_id = l_payment_term_rec.payment_term_id;

            UPDATE pn_payment_terms_all
            SET UPDATE_NBP_FLAG = 'Y'
            WHERE payment_term_id = l_payment_term_rec.payment_term_id
            AND INCLUDE_IN_VAR_RENT IN ('BASETERM', 'INCLUDE_RI');

            FOR rec IN get_lease_details LOOP
               l_lease_comm_date := rec.lease_commencement_date;
               l_lease_term_date := rec.lease_termination_date;
               l_mths := rec.p_mts;
            END LOOP;

            pn_schedules_items.extend_payment_term(
                             p_payment_term_rec => l_payment_term_rec,
                             p_new_lea_comm_dt   => l_lease_comm_date,
                             p_new_lea_term_dt   => l_lease_term_date,
                             p_mths              => l_mths,
                             p_new_start_date    => p_old_termination_date + 1,
                             p_new_end_date      => p_new_termination_date,
                             x_return_status     => x_return_status,
                             x_return_message    => x_return_message);

         END LOOP;



      /* RI agreement contraction */
      ELSIF p_old_termination_date > p_new_termination_date THEN
         p_msg := 'RI agreement contraction';

         FOR lease_id_rec IN get_lease_id LOOP
            l_lease_id := lease_id_rec.lease_id;
         END LOOP;

         FOR ri_terms_rec IN get_ri_terms_to_modify LOOP

            l_payment_term_rec := ri_terms_rec;

            IF l_payment_term_rec.start_date > p_new_termination_date AND
               l_payment_term_rec.start_date <= p_old_termination_date
            THEN

               FOR rec IN approved_sched_exist_cur(l_payment_term_rec.payment_term_id) LOOP
                  l_appr_sched_exists := TRUE;
               END LOOP;

               IF l_appr_sched_exists THEN

                   UPDATE pn_payment_terms_all
                   SET end_date = p_new_termination_date,
                       start_date = p_new_termination_date,
                       actual_amount = 0
                   WHERE payment_term_id = l_payment_term_rec.payment_term_id;

                   UPDATE pn_payment_terms_all
                   SET UPDATE_NBP_FLAG = 'Y'
                   WHERE payment_term_id = l_payment_term_rec.payment_term_id
                   AND INCLUDE_IN_VAR_RENT IN ('BASETERM', 'INCLUDE_RI');

                   DELETE pn_payment_items_all
                   WHERE payment_schedule_id IN
                                 (SELECT payment_schedule_id
                                  FROM   pn_payment_schedules_all
                                  WHERE  lease_id IN (SELECT lease_id FROM pn_payment_terms_all
                                                      WHERE payment_term_id = l_payment_term_rec.payment_term_id)
                                   AND    schedule_date > p_new_termination_date
                                   AND    payment_status_lookup_code IN ('DRAFT', 'ON_HOLD'))
                   AND payment_term_id = l_payment_term_rec.payment_term_id;

                   l_sched_tbl.DELETE;

                   pn_retro_adjustment_pkg.create_virtual_schedules
                         (p_start_date => l_payment_term_rec.start_date,
                          p_end_date   => p_new_termination_date,
                          p_sch_day    => l_payment_term_rec.schedule_day,
                          p_amount     => nvl(l_payment_term_rec.actual_amount,l_payment_term_rec.estimated_amount),
                          p_term_freq  => l_payment_term_rec.frequency_code,
			  p_payment_term_id => l_payment_term_rec.payment_term_id,
                          x_sched_tbl  => l_sched_tbl);

                   l_amt_due_to_term := 0;

                   IF l_sched_tbl.COUNT > 0 THEN
                      FOR i IN 0..l_sched_tbl.COUNT - 1 LOOP
                         l_amt_due_to_term := l_amt_due_to_term + l_sched_tbl(i).amount ;
                      END LOOP;
                   END IF;

                   l_amt_due_to_old_term := 0;

                   FOR rec IN total_amt_old_term_cur(l_payment_term_rec.payment_term_id) LOOP
                      l_amt_due_to_old_term := rec.total_amount;
                   END LOOP;

                   l_cash_act_amt := l_amt_due_to_term - NVL(l_amt_due_to_old_term, 0);

                   IF l_cash_act_amt <> 0 THEN

                       l_last_sched_draft := 'N';

                      FOR rec IN draft_schedule_exists_cur(l_sched_tbl(l_sched_tbl.LAST).schedule_date) LOOP
                         l_last_sched_draft := 'Y';
                         l_payment_schedule_id := rec.payment_schedule_id;
                         l_lst_cash_sch_dt := l_sched_tbl(l_sched_tbl.LAST).schedule_date;
                      END LOOP;

                      IF l_last_sched_draft = 'N' THEN

                          l_lst_cash_sch_dt
                                := TO_DATE(TO_CHAR(l_payment_term_rec.schedule_day)
                                   ||'/'||TO_CHAR(l_payment_term_rec.end_date,'MM/YYYY')
                                   ,'DD/MM/YYYY');
                         l_lease_change_id := pn_schedules_items.Get_Lease_Change_Id(l_lease_id);

                         pn_retro_adjustment_pkg.find_schedule( l_lease_id
                                                               ,l_lease_change_id
                                                               ,l_payment_term_rec.payment_term_id
                                                               ,l_lst_cash_sch_dt
                                                               ,l_payment_schedule_id);
                      END IF;

                      l_payment_item_id := NULL;
                      FOR rec IN cash_item_exist_cur(l_payment_schedule_id, l_payment_term_rec.payment_term_id) LOOP
                         l_payment_item_id := rec.payment_item_id;
                      END LOOP;

                      IF l_payment_item_id IS NOT NULL THEN
                         pn_schedules_items.update_cash_item
                                (p_item_id  => l_payment_item_id
                                ,p_term_id  => l_payment_term_rec.payment_term_id
                                ,p_sched_id => l_payment_schedule_id
                                ,p_act_amt  => l_cash_act_amt);

                      ELSE
                          pn_schedules_items.create_cash_items
                                (p_est_amt           => l_cash_act_amt,
                                 p_act_amt           => l_cash_act_amt,
                                 p_sch_dt            => l_lst_cash_sch_dt,
                                 p_sch_id            => l_payment_schedule_id,
                                 p_term_id           => l_payment_term_rec.payment_term_id,
                                 p_vendor_id         => l_payment_term_rec.vendor_id,
                                 p_cust_id           => l_payment_term_rec.customer_id,
                                 p_vendor_site_id    => l_payment_term_rec.vendor_site_id,
                                 p_cust_site_use_id  => l_payment_term_rec.customer_site_use_id,
                                 p_cust_ship_site_id => l_payment_term_rec.cust_ship_site_id,
                                 p_sob_id            => l_payment_term_rec.set_of_books_id,
                                 p_curr_code         => l_payment_term_rec.currency_code,
                                 p_rate              => l_payment_term_rec.rate);

                      END IF;
                   END IF;

               ELSE

                   DELETE pn_payment_items_all
                   WHERE  payment_term_id = l_payment_term_rec.payment_term_id;

                   DELETE pn_distributions_all
                   WHERE payment_term_id = l_payment_term_rec.payment_term_id;

                   DELETE pn_payment_terms_all
                   WHERE payment_term_id = l_payment_term_rec.payment_term_id;

               END IF;

            ELSIF l_payment_term_rec.start_date <= p_new_termination_date AND
                  l_payment_term_rec.end_date >= p_new_termination_date
            THEN

               UPDATE pn_payment_terms_all
               SET end_date = p_new_termination_date
               WHERE payment_term_id = l_payment_term_rec.payment_term_id;

               DELETE pn_payment_items_all
               WHERE payment_schedule_id IN
                             (SELECT payment_schedule_id
                              FROM   pn_payment_schedules_all
                              WHERE  lease_id IN (SELECT lease_id FROM pn_payment_terms_all
                                                  WHERE payment_term_id = l_payment_term_rec.payment_term_id)
                               AND    schedule_date > p_new_termination_date
                               AND    payment_status_lookup_code IN ('DRAFT', 'ON_HOLD'))
               AND payment_term_id = l_payment_term_rec.payment_term_id;

               l_sched_tbl.DELETE;

               pn_retro_adjustment_pkg.create_virtual_schedules
                     (p_start_date => l_payment_term_rec.start_date,
                      p_end_date   => p_new_termination_date,
                      p_sch_day    => l_payment_term_rec.schedule_day,
                      p_amount     => nvl(l_payment_term_rec.actual_amount,l_payment_term_rec.estimated_amount),
                      p_term_freq  => l_payment_term_rec.frequency_code,
		      p_payment_term_id => l_payment_term_rec.payment_term_id,
                      x_sched_tbl  => l_sched_tbl);

               l_amt_due_to_term := 0;

               IF l_sched_tbl.COUNT > 0 THEN
                   FOR i IN 0..l_sched_tbl.COUNT - 1 LOOP
                     l_amt_due_to_term := l_amt_due_to_term + l_sched_tbl(i).amount ;
                   END LOOP;
                END IF;

                l_amt_due_to_old_term := 0;

                FOR rec IN total_amt_old_term_cur(l_payment_term_rec.payment_term_id) LOOP
                   l_amt_due_to_old_term := rec.total_amount;
                END LOOP;

                l_cash_act_amt := l_amt_due_to_term - NVL(l_amt_due_to_old_term, 0);

                IF l_cash_act_amt <> 0 THEN

                   l_last_sched_draft := 'N';

                   FOR rec IN draft_schedule_exists_cur(l_sched_tbl(l_sched_tbl.LAST).schedule_date) LOOP
                     l_last_sched_draft := 'Y';
                     l_payment_schedule_id := rec.payment_schedule_id;
                     l_lst_cash_sch_dt := l_sched_tbl(l_sched_tbl.LAST).schedule_date;
                   END LOOP;

                   IF l_last_sched_draft = 'N' THEN

                      l_lst_cash_sch_dt
                            := TO_DATE(TO_CHAR(l_payment_term_rec.schedule_day)
                               ||'/'||TO_CHAR(p_new_termination_date,'MM/YYYY')
                               ,'DD/MM/YYYY');

                     l_lease_change_id := pn_schedules_items.Get_Lease_Change_Id(l_lease_id);

                     pn_retro_adjustment_pkg.find_schedule( l_lease_id
                                                           ,l_lease_change_id
                                                           ,l_payment_term_rec.payment_term_id
                                                           ,l_lst_cash_sch_dt
                                                           ,l_payment_schedule_id);
                  END IF;

                  l_payment_item_id := NULL;
                  FOR rec IN cash_item_exist_cur(l_payment_schedule_id, l_payment_term_rec.payment_term_id) LOOP
                     l_payment_item_id := rec.payment_item_id;
                  END LOOP;

                  IF l_payment_item_id IS NOT NULL THEN
                     pn_schedules_items.update_cash_item
                       ( p_item_id  => l_payment_item_id
                        ,p_term_id  => l_payment_term_rec.payment_term_id
                        ,p_sched_id => l_payment_schedule_id
                        ,p_act_amt  => l_cash_act_amt);

                  ELSE
                      pn_schedules_items.create_cash_items
                            (p_est_amt           => l_cash_act_amt,
                             p_act_amt           => l_cash_act_amt,
                             p_sch_dt            => l_lst_cash_sch_dt,
                             p_sch_id            => l_payment_schedule_id,
                             p_term_id           => l_payment_term_rec.payment_term_id,
                             p_vendor_id         => l_payment_term_rec.vendor_id,
                             p_cust_id           => l_payment_term_rec.customer_id,
                             p_vendor_site_id    => l_payment_term_rec.vendor_site_id,
                             p_cust_site_use_id  => l_payment_term_rec.customer_site_use_id,
                             p_cust_ship_site_id => l_payment_term_rec.cust_ship_site_id,
                             p_sob_id            => l_payment_term_rec.set_of_books_id,
                             p_curr_code         => l_payment_term_rec.currency_code,
                             p_rate              => l_payment_term_rec.rate);

                  END IF;
               END IF;

            END IF;
         END LOOP;

         pn_retro_adjustment_pkg.cleanup_schedules(l_lease_id);

      END IF;

      --Recalculate Natural Breakpoint if any changes in Lease Payment Terms

      l_update_nbp_flag := NULL;
      FOR terms_rec IN terms_cur(p1_lease_id => l_lease_id)
      LOOP
         IF terms_rec.UPDATE_NBP_FLAG = 'Y' THEN
            l_update_nbp_flag := 'Y';
            EXIT;
         END IF;
      END LOOP;

      IF l_update_nbp_flag = 'Y' THEN
         FOR var_rec in var_cur(p1_lease_id => l_lease_id)
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
         WHERE lease_id = l_lease_id;

      END IF;

      -- Finished Recalculating Natural Breakpoint if any changes in Lease Payment Terms

   END IF;

   put_log('handle_term_date_change (-) ');

EXCEPTION
   WHEN OTHERS THEN NULL;

END handle_term_date_change;


END pn_index_rent_periods_pkg;

/
