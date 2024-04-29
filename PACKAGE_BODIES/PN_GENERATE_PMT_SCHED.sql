--------------------------------------------------------
--  DDL for Package Body PN_GENERATE_PMT_SCHED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_GENERATE_PMT_SCHED" AS
  -- $Header: PNCPMTSB.pls 120.1 2005/07/25 06:13:25 appldev ship $

--
--

-------------------------------------------------------------------------------
-- PROCDURE     : create_sched_and_items
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_payment_terms,pn_payment_items
--                                     with _ALL table.
-------------------------------------------------------------------------------
procedure create_sched_and_items (
                                   error_buf      OUT NOCOPY VARCHAR2,
                                   ret_code       OUT NOCOPY VARCHAR2,
                                   pn_lease_id    IN  NUMBER,
                                   normalize_only IN  VARCHAR2,
                                   pn_user_id     IN  NUMBER
                                 ) IS

  next_payment_date    DATE;        /* Date of next payment to be made */
  payment_date         DATE;        /* Date that the current payment item must be paid */
  day_to_pay           NUMBER := 1; /* Day of month that all payment terms are paid */
  months               NUMBER;
  partial              NUMBER;
  amount               NUMBER;
  round_amount         NUMBER;
  proration_rule       NUMBER;
  term_on_start_date   DATE;
  term_on_end_date     DATE;
  items_paid           NUMBER;
  actual_items         NUMBER;
  sched_status         VARCHAR2(30);
  pt_start_date        DATE;
  pt_end_date          DATE;
  pt_target_date       DATE;
  pt_amount            NUMBER;
  pt_estimated_amount  NUMBER;
  pt_type_code         VARCHAR2(30);
  pt_frequency_code    VARCHAR2(30);
  pt_lease_id          NUMBER;
  pt_lease_change_id   NUMBER;
  pt_lease_num         NUMBER;
  ps_id                NUMBER;       /* Payment Schedule ID number */
  min_sched_date       DATE;
  rent_sched_date      DATE;       /* Date of rent schedule */
  lease_start_date     DATE;
  lease_end_date       DATE;
  iteration            NUMBER;
  iteration_start      NUMBER;

  cur_start_date       DATE;
  cur_end_date         DATE;
  cur_months           NUMBER;
  cur_pit_lookup_code  VARCHAR2(30);
  cur_amount           NUMBER;
  cur_estimated_amount NUMBER;
  total_cash           NUMBER;
  total_partial        NUMBER;
  l_org_id             NUMBER;                                                 /*sdm14jul*/


  cursor pt_cur (p_lease_id NUMBER) IS
    SELECT ppta.start_date,
           ppta.end_date,
           ppta.target_date,
           ppta.actual_amount,
           ppta.estimated_amount,
           ppta.payment_term_type_code,
           ppta.frequency_code,
           ppta.payment_term_id,
           pn_leases.lease_commencement_date,
           pn_leases.lease_termination_date,
           pn_leases.lease_id,
           pn_leases.lease_change_id,
           nvl(pn_leases.payment_term_rule,365) proration_rule,
           ppta.vendor_id,
           ppta.customer_id,
           ppta.vendor_site_id,
           ppta.customer_site_use_id,
           ppta.set_of_books_id,
           ppta.currency_code
    FROM   pn_payment_terms_all ppta,                      /*sdm14jul*/
           pn_leases_v pn_leases                        /*sdm? shud form view be replaced*/
    WHERE  ppta.lease_id        = pn_leases.lease_id      /*sdm14jul*/
    AND    ppta.lease_id        = p_lease_id              /*sdm14jul*/
    AND    not exists
                      ( SELECT 'x'
                        FROM   pn_payment_items_all a       /*sdm14jul*/
                        WHERE  a.payment_term_id = ppta.payment_term_id
                      );

    pt_rec pt_cur%ROWTYPE;


-------------------------------------------------------------------------------
-- PROCDURE     : CREATE_OT_PAYMENT_ITEMS
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_payment_terms,pn_payment_items with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE   CREATE_OT_PAYMENT_ITEMS (p_paymentTermId IN NUMBER) AS
   cursor ot_cur is
      SELECT ppt.start_date,
         ppt.end_date,
         ppt.target_date,
         ppt.actual_amount,
         ppt.estimated_amount,
         ppt.payment_term_type_code,
         ppt.frequency_code,
         ppt.payment_term_id,
         pls.lease_commencement_date,
         pls.lease_termination_date,
         pls.lease_id,
         pls.lease_change_id,
         nvl(pls.payment_term_rule,365) proration_rule,
         ppt.vendor_id,
         ppt.customer_id,
         ppt.vendor_site_id,
         ppt.customer_site_use_id,
         ppt.set_of_books_id,
         ppt.currency_code
      FROM    pn_leases_v     pls,                                      /*sdm should form view be replaced?*/
              pn_payment_terms_all ppt                                /*sdm14jul*/
      WHERE   ppt.lease_id            = pls.lease_id
         AND  ppt.lease_id            = pn_lease_id
         AND  ppt.payment_term_id        = p_paymentTermId
         AND  ppt.frequency_code           = 'OT'
         AND  not exists
         (  SELECT 'x'
            FROM   pn_payment_items_all a                            /*sdm14jul*/
            WHERE  a.payment_term_id = ppt.payment_term_id
         );
   l_paymentScheduleDate      DATE           := NULL;
   l_paymentScheduleId        NUMBER         := NULL;
   l_paymentStatusLookupCode  VARCHAR2(30)   := 'DRAFT';
   l_org_id                   NUMBER;
BEGIN

   FOR i in ot_cur LOOP

      l_paymentStatusLookupCode  := 'DRAFT';

      -- get the first of the month
      select   trunc (i.start_date, 'MM')
      into  l_paymentScheduleDate
      from  dual;

      select   max (payment_schedule_id)
      into  l_paymentScheduleId
      from  pn_payment_schedules_all            /*sdm14jul*/
      where lease_id = i.lease_id
      and   schedule_date = l_paymentScheduleDate;

      -- we need to create the schedule record
      IF (l_paymentScheduleId IS NULL) THEN

         SELECT pn_payment_schedules_s.nextval
         INTO   l_paymentScheduleId
         FROM   dual;

        /*sdm14jul*/
         SELECT org_id INTO l_org_id
         FROM   pn_leases_all
         WHERE  lease_id = i.lease_id;

         INSERT INTO pn_payment_schedules_all            /*sdm14jul*/
         (
            payment_schedule_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            schedule_date,
            lease_id,
            lease_change_id,
            payment_status_lookup_code,
            org_id                                      /*sdm14jul*/
         )
         VALUES
         (
            l_paymentScheduleId,
            sysdate,
            pn_user_id,
            sysdate,
            pn_user_id,
            l_paymentScheduleDate,
            i.lease_id,
            i.lease_change_id,
            'DRAFT',
            l_org_id                                    /*sdm14jul*/
         );
      ELSE
         -- we trying to find if the schedule is approved or not
         select   payment_status_lookup_code
         into  l_paymentStatusLookupCode
         from  pn_payment_schedules_all                       /*sdm14jul*/
         where payment_schedule_id  = l_paymentScheduleId;
      END IF;


      INSERT INTO pn_payment_items_all                       /*sdm14jul*/
      (
         payment_item_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         actual_amount,
         estimated_amount,
         due_date,
         payment_item_type_lookup_code,
         payment_term_id,
         payment_schedule_id,
         period_fraction,
         vendor_id,
         customer_id,
         vendor_site_id,
         customer_site_use_id,
         set_of_books_id,
         currency_code,
         export_currency_code,
         export_currency_amount,
         rate,
         export_to_ap_flag,
         org_id                                 /*sdm14jul*/
      )
      SELECT
         pn_payment_items_s.nextval,
         sysdate,
         pn_user_id,
         sysdate,
         pn_user_id,
         i.actual_amount,
         decode(i.actual_amount, null, i.estimated_amount,
               null),
         i.start_date,
         'CASH',
         i.payment_term_id,
         l_paymentScheduleId,
         1,
         i.vendor_id,
         i.customer_id,
         i.vendor_site_id,
         i.customer_site_use_id,
         i.set_of_books_id,
         i.currency_code,
         i.currency_code,
         i.actual_amount,
         1,
         decode (l_paymentStatusLookupCode, 'APPROVED', 'Y',NULL),
         l_org_id                                                       /*sdm14jul*/
      from  dual;

   END LOOP;
END CREATE_OT_PAYMENT_ITEMS;

BEGIN

     OPEN pt_cur (pn_lease_id);

     LOOP
          FETCH pt_cur INTO pt_rec;
          EXIT WHEN pt_cur%NOTFOUND;

    -------------------------------------------------------------------------
    -- Hardcoded Frequency Code
    -------------------------------------------------------------------------
    IF    pt_rec.frequency_code = 'OT'  THEN
      cur_months := 0;
    ELSIF pt_rec.frequency_code = 'MON' THEN
      cur_months := 1;
    ELSIF pt_rec.frequency_code = 'QTR' THEN
      cur_months := 3;
    ELSIF pt_rec.frequency_code = 'YR'  THEN
      cur_months := 12;
    ELSIF pt_rec.frequency_code = 'SA'  THEN
      cur_months := 6;
    END IF;

    /* Loop - 1st time - insert CASH items and delete normalized items */
    /*        2nd time - insert NORMALIZED items                       */


    IF (normalize_only = 'Y') THEN

      iteration_start := 2;

      DELETE from pn_payment_items_all                /*sdm14jul*/
      WHERE  payment_item_type_lookup_code = 'NORMALIZED'
      AND    payment_term_id               = pt_rec.payment_term_id;

    ELSE

      iteration_start := 1;

    END IF;

    SELECT max(schedule_date)
    INTO   min_sched_date
    FROM   pn_payment_schedules_all             /*sdm14jul*/
    WHERE  lease_id                    = pt_rec.lease_id
    AND    payment_status_lookup_code <> 'DRAFT';

    IF min_sched_date is not null THEN
      min_sched_date := add_months(min_sched_date,1);
    END IF;

    FOR iteration IN iteration_start..2
    LOOP /* Loop A */

        IF (iteration = 1) THEN

          cur_start_date       := pt_rec.start_date;
          cur_end_date         := pt_rec.end_date;
          cur_pit_lookup_code  := 'CASH';
          cur_amount           := pt_rec.actual_amount;
          cur_estimated_amount := pt_rec.estimated_amount;

        ELSE

          cur_start_date       := pt_rec.lease_commencement_date;
          cur_end_date         := pt_rec.lease_termination_date;
          cur_months           := 1;
          cur_pit_lookup_code  := 'NORMALIZED';
          cur_estimated_amount := ''; /* cur_amount to be set later */

        END IF;

        IF (pt_rec.payment_term_type_code = 'PRE') and (iteration = 1)  THEN /* IF A */

            /* Prepayments */

          DELETE FROM pn_payment_items_all               /*sdm14jul*/
          WHERE  payment_term_id = pt_rec.payment_term_id;

          rent_sched_date := Trunc(pt_rec.start_date,'MM');

          IF (rent_sched_date < min_sched_date) THEN
            rent_sched_date := min_sched_date;
          END IF;

            /* See if a payment schedule exists for this lease and gl period */

          SELECT max(payment_schedule_id)
          INTO   ps_id
          FROM   pn_payment_schedules_all          /*sdm14jul*/
          WHERE  lease_id      = pt_rec.lease_id
          AND    schedule_date = rent_sched_date;

          IF ps_id is null THEN

            SELECT pn_payment_schedules_s.nextval
            INTO   ps_id
            FROM   dual;

            /*sdm14jul*/
            SELECT org_id INTO l_org_id
            FROM   pn_leases_all
            WHERE  lease_id = pt_rec.lease_id;

            INSERT INTO pn_payment_schedules_all         /*sdm14jul*/
            ( payment_schedule_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              schedule_date,
              lease_id,
              lease_change_id,
              payment_status_lookup_code,
              org_id                                    /*sdm14jul*/
            )
            values
            ( ps_id,sysdate,
              pn_user_id,
              sysdate,
              pn_user_id,
              rent_sched_date,
              pt_rec.lease_id,
              pt_rec.lease_change_id,
              'DRAFT',
              l_org_id                                  /*sdm14jul*/
            );

          END IF;

          INSERT INTO pn_payment_items_all         /*sdm14jul*/
          ( payment_item_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            actual_amount,
            estimated_amount,
            due_date,
            payment_item_type_lookup_code,
            payment_term_id,
            payment_schedule_id,
            period_fraction,
            vendor_id,
            customer_id,
            vendor_site_id,
            customer_site_use_id,
            set_of_books_id,
            currency_code,
            export_currency_code,
            export_currency_amount,
            rate,
            org_id                              /*sdm14jul*/
          )
          VALUES
          ( pn_payment_items_s.nextval,
            sysdate,
            pn_user_id,
            sysdate,
            pn_user_id,
            pt_rec.actual_amount,
            decode(pt_rec.actual_amount,null,pt_rec.estimated_amount,null),
            pt_rec.start_date,
            'CASH',
            pt_rec.payment_term_id,
            ps_id,
            1,
            pt_rec.vendor_id,
            pt_rec.customer_id,
            pt_rec.vendor_site_id,
            pt_rec.customer_site_use_id,
            pt_rec.set_of_books_id,
            pt_rec.currency_code,
            pt_rec.currency_code,
            pt_rec.actual_amount,
            1,
            l_org_id                            /*sdm14jul*/
           );

            /* Prepayment offseting payment */

          rent_sched_date := Trunc(pt_rec.target_date,'MM');

          IF (rent_sched_date < min_sched_date) THEN
            rent_sched_date := min_sched_date;
          END IF;

          /* See if a payment schedule exists for this lease and gl period */

          SELECT max(payment_schedule_id)
          INTO   ps_id
          FROM   pn_payment_schedules_all       /*sdm14jul*/
          WHERE  lease_id      = pt_rec.lease_id
          AND    schedule_date = rent_sched_date;

          IF ps_id is null THEN

            SELECT pn_payment_schedules_s.nextval
            INTO   ps_id
            FROM   dual;

            INSERT INTO pn_payment_schedules_all      /*sdm14jul*/
            ( payment_schedule_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              schedule_date,
              lease_id,
              lease_change_id,
              payment_status_lookup_code,
              org_id                                    /*sdm14jul*/
            )
            values
            ( ps_id,sysdate,
              pn_user_id,
              sysdate,
              pn_user_id,
              rent_sched_date,
              pt_rec.lease_id,
              pt_rec.lease_change_id,
              'DRAFT',
              l_org_id                                  /*sdm14jul*/
            );

          END IF;

          INSERT INTO pn_payment_items_all      /*sdm14jul*/
          ( payment_item_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            actual_amount,
            estimated_amount,
            due_date,
            payment_item_type_lookup_code,
            payment_term_id,
            payment_schedule_id,
            period_fraction,
            vendor_id,
            customer_id,
            vendor_site_id,
            customer_site_use_id,
            set_of_books_id,
            currency_code,
            export_currency_code,
            export_currency_amount,
            rate,
            org_id                              /*sdm14jul*/
          )
          VALUES
          ( pn_payment_items_s.nextval,
            sysdate,
            pn_user_id,
            sysdate,
            pn_user_id,
            -pt_rec.actual_amount,
            decode(pt_rec.actual_amount,null,-pt_rec.estimated_amount,null),
            pt_rec.target_date,
            'CASH',
            pt_rec.payment_term_id,
            ps_id,
            1,
            pt_rec.vendor_id,
            pt_rec.customer_id,
            pt_rec.vendor_site_id,
            pt_rec.customer_site_use_id,
            pt_rec.set_of_books_id,
            pt_rec.currency_code,
            pt_rec.currency_code,
            pt_rec.actual_amount,
            1,
            l_org_id                            /*sdm14jul*/
          );

          /* End of CASH Pre-payments */

        ELSE IF ((pt_rec.frequency_code = 'OT') and (iteration = 1)) THEN /* IF D */

          DELETE FROM pn_payment_items_all                  /*sdm14jul*/
          WHERE  payment_term_id = pt_rec.payment_term_id
          AND    payment_item_type_lookup_code = 'NORMALIZED';

         ------------------------------------------------
         -- create OT 's
         ------------------------------------------------
         CREATE_OT_PAYMENT_ITEMS (pt_rec.payment_term_id);

        ELSE IF (iteration = 2) THEN

          SELECT count(*)
          INTO   actual_items
          FROM   pn_payment_items_all                 /*sdm14jul*/
          WHERE  payment_term_id = pt_rec.payment_term_id
          AND    actual_amount is NOT NULL
          AND    payment_item_type_lookup_code = 'CASH';

        ELSE

          actual_items := 0;

        END IF;

        IF (iteration = 1)                                                  or
           ((pt_rec.actual_amount is not null) and (pt_rec.payment_term_type_code in ('BASE','ABATE'))) or /* IF E */
           (actual_items <> 0) THEN /* Normalize actual base and abates if iteration = 2 or
                                       Cash base and abates if iteration = 1 */

          SELECT count(*)
          INTO   items_paid
          FROM   pn_payment_items_all pi,          /*sdm14jul*/
                 pn_payment_schedules_all ps       /*sdm14jul*/
          WHERE  pi.payment_schedule_id = ps.payment_schedule_id
          AND    pi.payment_term_id = pt_rec.payment_term_id
          AND    pi.payment_item_type_lookup_code = 'CASH'
          AND    ps.payment_status_lookup_code <> 'DRAFT';

          IF (items_paid = 0) or (iteration = 2) THEN /* IF F */

             IF (iteration = 1) THEN /* IF G */

                DELETE FROM pn_payment_items_all               /*sdm14jul*/
                WHERE  payment_term_id = pt_rec.payment_term_id;

             ELSE

                DELETE FROM pn_payment_items_all               /*sdm14jul*/
                WHERE  payment_term_id               = pt_rec.payment_term_id
                AND    payment_item_type_lookup_code = 'NORMALIZED';

                /* Loop and figure out NOCOPY sum of partial months */

                total_partial := 0;

                IF TO_NUMBER(TO_CHAR(cur_start_date,'DD')) >= day_to_pay THEN

                  payment_date := trunc(cur_start_date,'MM') + day_to_pay - 1;

                  IF trunc(payment_date,'MM') <> trunc(cur_start_date,'MM') THEN
                    payment_date := LAST_DAY(cur_start_date);
                  END IF;

                ELSE

                  payment_date := add_months(trunc( cur_start_date,'MM'), - 1) + day_to_pay - 1;

                  IF trunc(payment_date,'MM') <> add_months(trunc(cur_start_date,'MM'),1) THEN

                    payment_date := LAST_DAY(add_months( cur_start_date,-1));

                  END IF;

                END IF;

                LOOP /* Loop D */

                  next_payment_date := add_months(trunc( payment_date,'MM'),cur_months) +
                                       day_to_pay -1;


                  IF trunc(next_payment_date,'MM') <> add_months(
                                                      trunc(payment_date,'MM'),cur_months) THEN
                    next_payment_date := LAST_DAY(add_months( trunc(payment_date,'MM'),cur_months));

                  END IF;

                  IF (cur_start_date < payment_date) THEN
                    term_on_start_date := payment_date;
                  ELSE
                    term_on_start_date := cur_start_date;
                  END IF;

                  IF (next_payment_date - 1 > cur_end_date) THEN
                    term_on_end_date := cur_end_date;
                  ELSE
                    term_on_end_date := next_payment_date - 1;
                  END IF;

                  /* PL SQL bug sometimes returns a negative value for the months between function */

                  months := months_between(term_on_start_date, term_on_end_date + 1);

                  IF (months < 0) then
                    months := -months;
                  END IF;

                  months := Trunc(months);

                  /* Calculate partial months that are in range */

                  partial := (term_on_end_date + 1 - add_months(term_on_start_date, months))
                              * 12 / pt_rec.proration_rule;

                  IF partial > 1 THEN
                    partial := 1;
                  END IF;

                  months        := months + partial;
                  total_partial := total_partial + months;

                  EXIT WHEN next_payment_date > cur_end_date;

                  payment_date := next_payment_date;

                END LOOP; /* Loop D */

                /* Find total of all cash items */

                SELECT nvl(sum(actual_amount),0)
                INTO   total_cash
                FROM   pn_payment_items_all              /*sdm14jul*/
                WHERE  payment_term_id  = pt_rec.payment_term_id
                AND    payment_item_type_lookup_code = 'CASH';

                /* Set cur_amount to this the normalized per period */

                IF (total_cash <> 0) THEN
                  cur_amount := total_cash / total_partial;
                ELSE
                  cur_amount := 0;
                END IF;

             END IF; /* IF G */

             /* If amount is null, we are using the estimated amount,
                otherwise this is a known escalation. */

             IF TO_NUMBER(TO_CHAR(cur_start_date,'DD')) >= day_to_pay THEN

               payment_date := trunc(cur_start_date,'MM') + day_to_pay - 1;

               IF trunc(payment_date,'MM') <> trunc(cur_start_date,'MM') THEN
                 payment_date := LAST_DAY(cur_start_date);
               END IF;

             ELSE

               payment_date := add_months(trunc(cur_start_date, 'MM'), - 1) + day_to_pay - 1;

               IF trunc(payment_date,'MM') <> add_months(trunc(cur_start_date,'MM'),1) THEN
                 payment_date := LAST_DAY(add_months( cur_start_date,-1));
               END IF;

             END IF;

             /* Process each payment item */

             LOOP /* Loop E */

               /* Determine the next payment date to define the date range of the current payment */

               next_payment_date := add_months(trunc(payment_date, 'MM'),cur_months) + day_to_pay -1;


               IF trunc(next_payment_date,'MM') <> add_months( trunc(payment_date,'MM'),cur_months)
               THEN
                 next_payment_date := LAST_DAY(add_months(trunc (payment_date,'MM'),cur_months));
               END IF;

               rent_sched_date := Trunc(payment_date,'MM');

               IF (rent_sched_date < min_sched_date) and (iteration = 1) THEN
                 rent_sched_date := min_sched_date;
               END IF;

               /* See if a payment schedule exists for this lease and gl period */

               SELECT max(payment_schedule_id)
               INTO   ps_id
               FROM   pn_payment_schedules_all           /*sdm14jul*/
               WHERE  lease_id = pt_rec.lease_id
               AND    schedule_date = rent_sched_date;

               IF ps_id is null THEN

                 SELECT pn_payment_schedules_s.nextval
                 INTO   ps_id
                 FROM   dual;

                 IF (rent_sched_date < min_sched_date) THEN

                   INSERT INTO pn_payment_schedules_all              /*sdm14jul*/
                  (
                     payment_schedule_id,
                     last_update_date,
                     last_updated_by,creation_date,created_by,
                     schedule_date, lease_id,
                     lease_change_id,
                     payment_status_lookup_code,
                     org_id
                  )
                  VALUES
                  (
                     ps_id,
                     sysdate,
                     pn_user_id,
                     sysdate,
                     pn_user_id,
                     rent_sched_date,
                     pt_rec.lease_id,
                     pt_rec.lease_change_id,
                     'APPROVED',
                     l_org_id
                  );
                 ELSE
                   INSERT INTO pn_payment_schedules_all              /*sdm14jul*/
                   (
                     payment_schedule_id,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     schedule_date,
                     lease_id,
                     lease_change_id,
                     payment_status_lookup_code,
                     org_id
                    )
                   VALUES
                   (
                     ps_id,
                     sysdate,
                     pn_user_id,
                     sysdate,
                     pn_user_id,
                     rent_sched_date,
                     pt_rec.lease_id,
                     pt_rec.lease_change_id,
                     'DRAFT',
                     l_org_id
                   );

                 END IF;

               END IF;

               IF (cur_start_date < payment_date) THEN
                 term_on_start_date := payment_date;
               ELSE
                 term_on_start_date := cur_start_date;
               END IF;

               IF (next_payment_date - 1 > cur_end_date) THEN
                 term_on_end_date := cur_end_date;
               ELSE
                 term_on_end_date := next_payment_date - 1;
               END IF;

               /* PL SQL bug sometimes returns a negative value for the months between function */

               months := months_between(term_on_start_date, term_on_end_date + 1);

               IF (months < 0) then
                 months := -months;
               END IF;

               months := Trunc(months);

               /* Calculate partial months that are in range */

               partial := (term_on_end_date + 1 - add_months(term_on_start_date, months))
                           * 12 / pt_rec.proration_rule;

               IF partial > 1 THEN
                 partial := 1;
               END IF;

               months := months + partial;

               IF ((pt_rec.actual_amount is null) and (iteration = 1)) THEN
                 amount := cur_estimated_amount * months / cur_months;
               ELSE
                 amount := cur_amount * months / cur_months;
               END IF;

               IF (iteration = 1) THEN
                 round_amount := round(amount,2);
               ELSE
                 round_amount := amount;
               END IF;

               INSERT INTO pn_payment_items_all             /*sdm14jul*/
               (
                  payment_item_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 actual_amount,
                 estimated_amount,
                 due_date,
                 payment_item_type_lookup_code,
                 payment_term_id,
                 payment_schedule_id,
                 period_fraction,
                 vendor_id,
                 customer_id,
                 vendor_site_id,
                 customer_site_use_id,
                 set_of_books_id,
                 currency_code,
                 export_currency_code,
                 export_currency_amount,
                 rate,
                 org_id                         /*sdm14jul*/
               )
               values
               ( pn_payment_items_s.nextval,
                 sysdate,
                 pn_user_id,
                 sysdate,
                 pn_user_id,
                 decode (iteration,2,
                         round_amount,
                         decode (pt_rec.actual_amount,null,
                                 null,round_amount
                                )
                        ),
                 decode(iteration,2,
                        null,
                        decode(pt_rec.actual_amount,null,
                               round_amount,null
                              )
                       ),
                 payment_date,
                 cur_pit_lookup_code,
                 pt_rec.payment_term_id,
                 ps_id,
                 amount/decode(iteration,2,
                               decode(cur_amount,0,
                                      1, cur_amount
                                     ),
                               decode(pt_rec.actual_amount,null,
                                      cur_estimated_amount, cur_amount
                                     )
                              ),
                 decode(iteration,2,
                        null,pt_rec.vendor_id
                       ),
                 decode(iteration,2,
                        null,pt_rec.customer_id
                       ),
                 decode(iteration,2,
                        null,pt_rec.vendor_site_id
                       ),
                 decode(iteration,2,
                        null,pt_rec.customer_site_use_id
                       ),
                 pt_rec.set_of_books_id,
                 pt_rec.currency_code,
                 pt_rec.currency_code,
                 decode (iteration,2,
                         round_amount,
                         decode (pt_rec.actual_amount,null,
                                 null,round_amount
                                )
                        ),
                 1,
                 l_org_id                                       /*sdm14jul*/
               );

               EXIT WHEN next_payment_date > cur_end_date;

               payment_date := next_payment_date;

             END LOOP; /* Loop E */

           ELSE /* Some items have been paid */

             DELETE from pn_payment_items_all               /*sdm14jul*/
             WHERE  payment_term_id               = pt_rec.payment_term_id
             and    payment_item_type_lookup_code = 'NORMALIZED';

             UPDATE pn_payment_items_all                    /*sdm14jul*/
             SET    actual_amount    = cur_amount * period_fraction,
                    estimated_amount = decode(pt_rec.actual_amount,null,
                                              cur_estimated_amount * period_fraction,
                                              null
                                             ),
                    last_update_date = sysdate,
                    last_updated_by  = pn_user_id
             WHERE  payment_term_id               = pt_rec.payment_term_id
             AND    payment_item_type_lookup_code = 'CASH'
             AND    payment_schedule_id in (
                                             SELECT payment_schedule_id
                                             FROM   pn_payment_schedules_all        /*sdm14jul*/
                                             WHERE  payment_status_lookup_code = 'DRAFT'
                                           );

           END IF; /* IF F */

         END IF; /* IF E */

         /* Normalize for estimates and non-BASE or ABATEs */
         IF (iteration = 2) THEN

           INSERT INTO pn_payment_items_all                 /*sdm14jul*/
           (
            payment_item_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            estimated_amount,
            due_date,
            payment_item_type_lookup_code,
            payment_term_id,
            payment_schedule_id,
            period_fraction,
            set_of_books_id,
            currency_code,
            rate,
            org_id                                      /*sdm14jul*/
           )
            SELECT pn_payment_items_s.nextval,
            sysdate,
            pn_user_id,
            sysdate,
            pn_user_id,
            nvl(actual_amount, estimated_amount),
            due_date,
            'NORMALIZED',
            payment_term_id,
            payment_schedule_id,
            1,
            pt_rec.set_of_books_id,
            pt_rec.currency_code,
            1,
            l_org_id                                    /*sdm14jul*/
            FROM   pn_payment_items_all             /*sdm14jul*/
            WHERE  payment_term_id = pt_rec.payment_term_id
            AND   actual_amount is null;
         END IF;

       END IF; /* IF D */

     END IF; /* IF A */

   END LOOP; /* Loop A */

 END LOOP;

 CLOSE pt_cur;
 commit;

END;

END PN_GENERATE_PMT_SCHED;

/
