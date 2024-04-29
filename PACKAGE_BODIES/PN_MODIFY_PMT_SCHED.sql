--------------------------------------------------------
--  DDL for Package Body PN_MODIFY_PMT_SCHED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_MODIFY_PMT_SCHED" AS
  -- $Header: PNMPMTSB.pls 120.1 2005/07/25 06:47:10 appldev ship $

--
--

-------------------------------------------------------------------------------
-- PROCDURE     : modify_sched_and_items
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 15-JUL-05  SatyaDeep     o Replaced base views with their _ALL tables
-------------------------------------------------------------------------------
procedure modify_sched_and_items (
                                   error_buf      OUT NOCOPY VARCHAR2,
                                   ret_code       OUT NOCOPY VARCHAR2,
                                   pn_lease_id    IN  NUMBER,
                                   pn_user_id     IN  NUMBER
                                 ) IS


CURSOR pt_cur (p_lease_id NUMBER) IS
   SELECT payment_term_id,
          start_date,
          end_date,
          actual_amount,
          estimated_amount,
          payment_term_type_code,
          frequency_code,
          lease_id,
          set_of_books_id,
          currency_code
   FROM   pn_payment_terms_all               /*sdm14jul*/
   WHERE  lease_id = p_lease_id
   FOR    UPDATE OF end_date;

   pt_rec pt_cur%ROWTYPE;

/* Early Termination Variables */

first_payment_date      DATE;
item_to_change_date     DATE;
items_paid              NUMBER;
lease_start_date        DATE;
lease_end_date          DATE;
pi_id                   NUMBER;
pro_start_date          DATE;
pt_months               NUMBER;
sched_status            VARCHAR2(30);
min_sched_date          DATE;
l_org_id                NUMBER;         /*sdm14jul*/

/* Normalization Variables */

actual_items            NUMBER;
amount                  NUMBER;
day_to_pay              NUMBER := 1;
months                  NUMBER;
next_payment_date       DATE;
partial                 NUMBER;
payment_date            DATE;
proration_rule          NUMBER;
ps_id                   NUMBER;
rent_sched_date         DATE;
term_on_start_date      DATE;
term_on_end_date        DATE;
total_cash              NUMBER;
total_partial           NUMBER;
pn_lease_change_id      NUMBER;

BEGIN

     OPEN pt_cur (pn_lease_id);

     LOOP

          FETCH pt_cur INTO pt_rec;
          EXIT WHEN pt_cur%NOTFOUND;

          SELECT pn_leases.lease_commencement_date,
                 pn_leases.lease_termination_date,
                 nvl(pn_leases.payment_term_rule,365),
                 pn_leases.lease_change_id
          INTO   lease_start_date, lease_end_date, proration_rule, pn_lease_change_id
          FROM   pn_leases_v pn_leases                   /*sdm??should form view be replaced*/
          WHERE  pn_leases.lease_id  = pt_rec.lease_id;


          IF (pt_rec.end_date > lease_end_date) THEN

            -------------------------------------------------------------------------
            -- Hardcoded Frequency Code
            -------------------------------------------------------------------------
            IF    pt_rec.frequency_code = 'OT'  THEN
              pt_months := 0;
            ELSIF pt_rec.frequency_code = 'MON' THEN
              pt_months := 1;
            ELSIF pt_rec.frequency_code = 'QTR' THEN
              pt_months := 3;
            ELSIF pt_rec.frequency_code = 'YR'  THEN
              pt_months := 12;
            ELSIF pt_rec.frequency_code = 'SA'  THEN
              pt_months := 6;
            END IF;

            SELECT count(*)
            INTO   items_paid
            FROM   pn_payment_schedules_all ps,             /*sdm14jul*/
                   pn_payment_items_all     pi              /*sdm14jul*/
            WHERE  ps.payment_schedule_id           = pi.payment_schedule_id
            AND    pi.payment_term_id               = pt_rec.payment_term_id
            AND    ps.payment_status_lookup_code   <> 'DRAFT'
            AND    pi.payment_item_type_lookup_code = 'CASH';

            IF ((pt_rec.start_date > lease_end_date) and (items_paid = 0)) THEN

              delete from pn_payment_items_all              /*sdm14jul*/
              where  payment_term_id = pt_rec.payment_term_id;

              /* Not Required in PN
              delete from pn_lease_milestones
              where  payment_term_id = pt_rec.payment_term_id
              and    RESPONSIBILITY_LOOKUP_CODE = 'PAYMENT_TERM';*/

              delete from pn_payment_terms_all              /*sdm14jul*/
              where  current of pt_cur;

            ELSE IF ((pt_rec.end_date > lease_end_date) or (items_paid <> 0)) THEN

              SELECT min(due_date)
              INTO   first_payment_date
              FROM   pn_payment_items_all             /*sdm14jul*/
              WHERE  payment_term_id               = pt_rec.payment_term_id
              AND    payment_item_type_lookup_code = 'CASH';

              SELECT nvl(max(due_date),first_payment_date)
              INTO   item_to_change_date
              FROM   pn_payment_items_all             /*sdm14jul*/
              WHERE  payment_term_id = pt_rec.payment_term_id
              AND    due_date       <= greatest(lease_end_date, pt_rec.start_date);

              -----------------------------------------------------------------------
              -- No Cash Item exists for Pmt Terms of frequency other than Monthly
              -----------------------------------------------------------------------
              BEGIN

                SELECT ps.payment_status_lookup_code, pi.payment_item_id
                INTO   sched_status, pi_id
                FROM   pn_payment_schedules_all ps,            /*sdm14jul*/
                       pn_payment_items_all     pi          /*sdm14jul*/
                WHERE  pi.payment_schedule_id           = ps.payment_schedule_id
                AND    pi.due_date                      = item_to_change_date
                AND    pi.payment_term_id               = pt_rec.payment_term_id
                AND    pi.payment_item_type_lookup_code = 'CASH';

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  NULL;

              END;

              IF (sched_status = 'DRAFT') THEN

                IF (first_payment_date = item_to_change_date) THEN
                  pro_start_date := pt_rec.start_date;
                ELSE
                  pro_start_date := item_to_change_date;
                END IF;

                /* Prorate partial period from pro_start to termination date */

                /* PL SQL bug sometimes returns a negative value for the months
                   between function */

                months := months_between (lease_end_date + 1, pro_start_date);

                IF (months < 0) then
                  months := -months;
                END IF;

                months := Trunc(months);

                partial := (lease_end_date + 1 - add_months(pro_start_date,months)) *
                                          12 / proration_rule;

                IF partial > 1 then
                  partial := 1;
                END IF;

                months := months + partial;
                amount := nvl(pt_rec.actual_amount, pt_rec.estimated_amount) *
                                        months / pt_months;

                UPDATE pn_payment_items_all           /*sdm14jul*/
                SET   actual_amount    = decode(pt_rec.actual_amount,
                                                null,null, round(amount,2)),
                      estimated_amount = decode(pt_rec.actual_amount,
                                                null,round(amount,2),null),
                      period_fraction  = amount / nvl(pt_rec.actual_amount,
                                                      pt_rec.estimated_amount),
                      last_update_date = sysdate,
                      last_updated_by  = pn_user_id
                WHERE payment_item_id               = pi_id
                AND   payment_item_type_lookup_code = 'CASH';

              END IF;

              DELETE from pn_payment_items_all              /*sdm14jul*/
              WHERE  payment_term_id               = pt_rec.payment_term_id
              AND    due_date                      > item_to_change_date
              AND    payment_item_type_lookup_code = 'CASH'
              AND    payment_schedule_id in (SELECT payment_schedule_id
                                             FROM   pn_payment_schedules_all     /*sdm14jul*/
                                             WHERE  payment_status_lookup_code = 'DRAFT'
                                             AND    lease_id                   = pt_rec.lease_id
                                            );

              IF (lease_end_date) > (pt_rec.start_date) THEN

                update pn_payment_terms_all           /*sdm14jul*/
                set    end_date = lease_end_date,
                       last_update_date = sysdate,
                       last_updated_by = pn_user_id
                where  payment_term_id = pt_rec.payment_term_id;

                /* Not Required in PN...
                update pn_lease_milestones
                set    milestone_date = lease_end_date,
                       last_update_date = sysdate,
                       last_updated_by = pn_user_id
                where  payment_term_id = pt_rec.payment_term_id
                and    RESPONSIBILITY_LOOKUP_CODE = 'PAYMENT_TERM'
                and    (description like 'End%'
                                      or description like 'Security Deposit refund due');*/

              ELSE

                update pn_payment_terms_all           /*sdm14jul*/
                set    end_date = pt_rec.start_date,
                       last_update_date = sysdate,
                       last_updated_by = pn_user_id
                where  payment_term_id = pt_rec.payment_term_id;

                /* Not required in PN....
                update pn_lease_milestones
                set    milestone_date = pt_rec.start_date,
                       last_update_date = sysdate,
                       last_updated_by = pn_user_id
                where  payment_term_id = pt_rec.payment_term_id
                and    responsibility_lookup_code = 'PAYMENT_TERM'
                and    (description like 'End%'
                or description like 'Security Deposit refund due');*/

              END IF;

            END IF;

          END IF;

        END IF;

        /* ------------------  Renormalize ------------------------- */

        SELECT max(schedule_date)
        INTO   min_sched_date
        FROM   pn_payment_schedules_all               /*sdm14jul*/
        WHERE  lease_id                    = pt_rec.lease_id
        AND    payment_status_lookup_code <> 'DRAFT';

        IF min_sched_date is not null THEN
          min_sched_date := add_months(min_sched_date,1);
        END IF;

        DELETE from pn_payment_items_all           /*sdm14jul*/
        WHERE  payment_item_type_lookup_code = 'NORMALIZED'
        AND    payment_term_id               = pt_rec.payment_term_id;

        SELECT count(*)
        INTO   actual_items
        FROM   pn_payment_items_all             /*sdm14jul*/
        WHERE  payment_term_id               = pt_rec.payment_term_id
        AND    actual_amount                is not null
        AND    payment_item_type_lookup_code = 'CASH';

        IF  ((pt_rec.actual_amount is not null) and
             (pt_rec.payment_term_type_code in ('BASE','ABATE')))
              or (actual_items <> 0) THEN /* IF E */
          /* Normalize actuals base and abates */

          /* Loop and figure out NOCOPY sum of partial months */

          total_partial := 0;

          IF TO_NUMBER(TO_CHAR(lease_start_date,'DD')) >= day_to_pay THEN
            payment_date := trunc(lease_start_date,'MM') + day_to_pay - 1;
            IF trunc(payment_date,'MM') <> trunc(lease_start_date,'MM') THEN
              payment_date := LAST_DAY(lease_start_date);
            END IF;

          ELSE

            payment_date := add_months(trunc(lease_start_date,'MM'),
                                    -1) + day_to_pay - 1;
            IF trunc(payment_date,'MM') <> add_months(trunc( lease_start_date,'MM'),1) THEN
              payment_date := LAST_DAY(add_months(lease_start_date,-1));
            END IF;

          END IF;

          LOOP /* Loop D */
            next_payment_date := add_months(trunc(payment_date,'MM'),1) + day_to_pay -1;

            IF trunc(next_payment_date,'MM') <> add_months(trunc(payment_date, 'MM'),1) THEN
              next_payment_date := LAST_DAY(add_months(trunc(payment_date, 'MM'),1));
            END IF;

            IF (lease_start_date < payment_date) THEN
              term_on_start_date := payment_date;
            ELSE
              term_on_start_date := lease_start_date;
            END IF;

            IF (next_payment_date - 1 > lease_end_date) THEN
              term_on_end_date := lease_end_date;
            ELSE
              term_on_end_date := next_payment_date - 1;
            END IF;

            /* PL SQL bug sometimes returns a negative value
               for the months between function */

            months := months_between(term_on_start_date, term_on_end_date + 1);

            IF (months < 0) then
              months := -months;
            END IF;

            months := Trunc(months);

            /* Calculate partial months that are in range */

            partial := (term_on_end_date + 1 - add_months(term_on_start_date, months)) *
                        12 / proration_rule;

            IF partial > 1 THEN
              partial := 1;
            END IF;

            months := months + partial;

            total_partial := total_partial + months;

            EXIT WHEN next_payment_date > lease_end_date;

            payment_date := next_payment_date;

          END LOOP; /* Loop D */

          /* Find total of all cash items */

          SELECT nvl(sum(actual_amount),0)
          INTO   total_cash
          FROM   pn_payment_items_all                 /*sdm14jul*/
          WHERE  payment_term_id               = pt_rec.payment_term_id
          AND    payment_item_type_lookup_code = 'CASH';

          /* Set amount to this the normalized per period */

          IF (total_cash <> 0) THEN
            amount := total_cash / total_partial;
          ELSE
            amount := 0;
          END IF;

          /* If amount is null, we are using the estimated
             amount, otherwise this is a known escalation. */

          IF TO_NUMBER(TO_CHAR(lease_start_date,'DD')) >= day_to_pay
          THEN
            payment_date := trunc(lease_start_date,'MM') + day_to_pay - 1;
            IF trunc(payment_date,'MM') <> trunc(lease_start_date,'MM') THEN
              payment_date := LAST_DAY(lease_start_date);
            END IF;

          ELSE

            payment_date := add_months(trunc(lease_start_date, 'MM'), - 1) + day_to_pay - 1;
            IF trunc(payment_date,'MM') <> add_months(trunc( lease_start_date, 'MM'),1) THEN
              payment_date := LAST_DAY(add_months(lease_start_date, -1));
            END IF;

          END IF;

          /* Process each payment item */

          LOOP /* Loop E */

            /* Determine the next payment date to define the
               date range of the current payment */

            next_payment_date := add_months(trunc(payment_date, 'MM'),1) + day_to_pay -1;

            IF trunc(next_payment_date,'MM') <> add_months(trunc(payment_date, 'MM'),1) THEN
              next_payment_date := LAST_DAY(add_months(trunc(payment_date, 'MM'),1));
            END IF;

            /* Tie to rent_schedule of payment_item_due_date or sysdate
               whichever is greater.  Payment schedules are always
               assigned to the first of the month. */

            rent_sched_date := Trunc(payment_date,'MM');

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

              /*sdm14jul*/
              SELECT org_id INTO l_org_id
              FROM pn_payment_schedules_all
              WHERE payment_schedule_id = ps_id;


                INSERT INTO pn_payment_schedules_all        /*sdm14jul*/
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
                  org_id                                /*sdm14jul*/
                )
                VALUES
                ( ps_id,
                  sysdate,
                  pn_user_id,
                  sysdate,
                  pn_user_id,
                  rent_sched_date,
                  pt_rec.lease_id,
                  pn_lease_change_id,
                  'APPROVED',
                  l_org_id                              /*sdm14jul*/
                 );

              ELSE

                INSERT INTO pn_payment_schedules_all        /*sdm14jul*/
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
                  org_id                                /*sdm14jul*/
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
                  pn_lease_change_id,
                  'DRAFT',
                  l_org_id                              /*sdm14jul*/
                );
              END IF;
            END IF;

            IF (lease_start_date < payment_date) THEN
              term_on_start_date := payment_date;
            ELSE
              term_on_start_date := lease_start_date;
            END IF;

            IF (next_payment_date - 1 > lease_end_date) THEN
              term_on_end_date := lease_end_date;
            ELSE
              term_on_end_date := next_payment_date - 1;
            END IF;

            /* PL SQL bug sometimes returns a negative value
               for the months between function */

            months := months_between(term_on_start_date, term_on_end_date + 1);

            IF (months < 0) then
              months := -months;
            END IF;

            months := Trunc(months);

            /* Calculate partial months that are in range */

            partial := (term_on_end_date + 1 - add_months(term_on_start_date, months)) *
                        12 / proration_rule;

            IF partial > 1 THEN
              partial := 1;
            END IF;

            months := months + partial;

            amount := amount * months ;

            ---------------------------------------------------------------
            -- No Need to create NORMALIZED items when amount = 0
            ---------------------------------------------------------------
            if nvl(amount,0) <> 0 then

                /*sdm14jul*/
              SELECT org_id INTO l_org_id
              FROM pn_payment_terms_all
              WHERE payment_term_id = pt_rec.payment_term_id;

              INSERT INTO pn_payment_items_all           /*sdm14jul*/
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
                rate,
                org_id                          /*sdm14jul*/
              )
              VALUES
              (
                pn_payment_items_s.nextval,
                sysdate,
                pn_user_id,
                sysdate,
                pn_user_id,
                amount,
                null,
                payment_date,
                'NORMALIZED',
                pt_rec.payment_term_id,
                ps_id,
                amount/decode(amount,0,1,months),
                null,
                null,
                null,
                null,
                pt_rec.set_of_books_id,
                pt_rec.currency_code,
                1,
                l_org_id                        /*sdm14jul*/
              );
            end if;

            EXIT WHEN next_payment_date > lease_end_date;

            payment_date := next_payment_date;

          END LOOP; /* Loop E */

        END IF; /* IF E */

        INSERT INTO pn_payment_items_all           /*sdm14jul*/
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
          org_id
        )
        SELECT
                pn_payment_items_s.nextval,
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
                set_of_books_id,
                currency_code,
                rate,
                l_org_id                        /*sdm14jul*/
        FROM    pn_payment_items_all            /*sdm14jul*/
        WHERE   payment_term_id = pt_rec.payment_term_id
        AND     actual_amount  is null;

     END LOOP;

   CLOSE pt_cur;

   DELETE FROM pn_payment_schedules_all ps         /*sdm14jul*/
   WHERE  ps.lease_id = pn_lease_id
   AND    NOT exists (SELECT 'x'
                      FROM   pn_payment_items_all pi     /*sdm14jul*/
                      WHERE  pi.payment_schedule_id = ps.payment_schedule_id);

commit;
END;

END PN_MODIFY_PMT_SCHED;

/
