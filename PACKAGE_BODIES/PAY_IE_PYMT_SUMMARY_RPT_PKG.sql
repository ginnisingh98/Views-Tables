--------------------------------------------------------
--  DDL for Package Body PAY_IE_PYMT_SUMMARY_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PYMT_SUMMARY_RPT_PKG" AS
/* $Header: pyiepysm.pkb 120.2 2006/03/01 03:47:34 rbhardwa noship $ */

-------------------------------------------------------------------------------
-- WRITETOCLOB
--------------------------------------------------------------------------------
   PROCEDURE writetoclob (p_xfdf_string OUT NOCOPY CLOB)
   IS
      l_str1   VARCHAR2 (1000);
      l_str2   VARCHAR2 (20);
      l_str3   VARCHAR2 (20);
      l_str4   VARCHAR2 (20);
      l_str5   VARCHAR2 (20);
      l_str6   VARCHAR2 (30);
      l_str7   VARCHAR2 (1000);
      l_str8   VARCHAR2 (240);
      l_str9   VARCHAR2 (240);
   BEGIN
      l_str1 :=
            '<?xml version="1.0" encoding="UTF-8"?> <PAYMENT_SUMMARY_REPORT>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</PAYMENT_SUMMARY_REPORT>';
      l_str7 :=
         '<?xml version="1.0" encoding="UTF-8"?>
<PAYMENT_SUMMARY_REPORT></PAYMENT_SUMMARY_REPORT>';
      DBMS_LOB.createtemporary (p_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (p_xfdf_string, DBMS_LOB.lob_readwrite);
      hr_utility.set_location ('TableCnt' || TO_CHAR (vxmltable.COUNT), 13);

      IF vxmltable.COUNT > 0
      THEN
         DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str1), l_str1);

         FOR ctr_table IN vxmltable.FIRST .. vxmltable.LAST
         LOOP
            hr_utility.set_location (   vxmltable (ctr_table).tagname
                                     || ' '
                                     || vxmltable (ctr_table).tagvalue,
                                     15
                                    );
            l_str8 := vxmltable (ctr_table).tagname;
            l_str9 := vxmltable (ctr_table).tagvalue;

            IF (    l_str9 IS NOT NULL
                AND l_str8 NOT LIKE '/%'
                AND SUBSTR (l_str8, 1, 2) <> 'G_'
               )
            THEN
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str2), l_str2);
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str3), l_str3);
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str9), l_str9);
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str4), l_str4);
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str5), l_str5);
            ELSIF l_str8 LIKE '/%' OR SUBSTR (l_str8, 1, 2) = 'G_'
            THEN
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str2), l_str2);
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str3), l_str3);
            ELSE
               NULL;
            END IF;
         END LOOP;

         DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str6), l_str6);
      ELSE
         DBMS_LOB.writeappend (p_xfdf_string, LENGTH (l_str7), l_str7);
      END IF;
   /*      INSERT INTO tmp
 *                VALUES (p_xfdf_string);*/
   END writetoclob;

--
--------------------------------------------------------------------------------
-- POPULATE_PYMT_SUMMARY_REPORT
--------------------------------------------------------------------------------
   PROCEDURE populate_pymt_summary_rep (
      p_bg_id                  IN              NUMBER,
      p_payroll_id             IN              NUMBER,
      p_period_id              IN              NUMBER,
      p_consolidation_set_id   IN              NUMBER,
      p_template_name          IN              VARCHAR2,
      p_xml                    OUT NOCOPY      CLOB
   )
   IS
      l_time_period              per_time_periods.period_name%TYPE;
      l_payroll_name             pay_payrolls_f.payroll_name%TYPE;
      l_bg_name                  VARCHAR2 (240);
      l_consolidation_set_name
pay_consolidation_sets.consolidation_set_name%TYPE;
      l_report_date              VARCHAR2 (12);

      CURSOR csr_payroll_name
      IS
         SELECT DISTINCT payroll_name
                    FROM pay_payrolls_f
                   WHERE payroll_id = p_payroll_id;

--
      CURSOR csr_time_period
      IS
         SELECT period_name
           FROM per_time_periods
          WHERE time_period_id = p_period_id;

--
      CURSOR csr_consolidation_set_name
      IS
         SELECT consolidation_set_name
           FROM pay_consolidation_sets
          WHERE consolidation_set_id = p_consolidation_set_id;

--
      CURSOR csr_get_pymt_data
      IS
         SELECT dummy_break,
                payment_method_type,
                payment_method_type || ' Totals' payment_method_type_totals,
                NAME,
                source_sort_code,
                bank_name,
                bank_branch,
                account_number,
                account_name,
                amount,
                total_assignments_paid,
                SUM (amount) OVER (PARTITION BY payment_method_type)
                                                           AS amount_per_type,
                SUM (amount) OVER (PARTITION BY dummy_break)
                                                         AS total_amount_paid,
                SUM (total_assignments_paid) OVER (PARTITION BY
payment_method_type)
                                                         AS asg_paid_per_type,
                SUM (total_assignments_paid) OVER (PARTITION BY dummy_break)
                                                            AS total_asg_paid
           FROM (SELECT   'X' dummy_break,
                          SUBSTR (ppttl.payment_type_name, 1, 14)
                                                          payment_method_type,
                          popmftl.org_payment_method_name NAME,
                          SUBSTR (pea.segment1, 1, 6) source_sort_code,
                          hr_general.decode_lookup ('HR_IE_BANK',
                                                    pea.segment2) bank_name,
                          SUBSTR (pea.segment3, 1, 35) bank_branch,
                          SUBSTR (pea.segment4, 1, 8) account_number,
                          SUBSTR (pea.segment5, 1, 18) account_name,
                          SUM (TO_NUMBER (ppp.VALUE)) amount,
                          COUNT (ppp.VALUE) total_assignments_paid
                     FROM pay_payroll_actions ppa,
                          pay_assignment_actions paa,
                          pay_pre_payments ppp,
                          pay_org_payment_methods_f_tl popmftl,
                          pay_org_payment_methods_f popmf,
                          pay_payment_types_tl ppttl,
                          pay_payment_types ppt,
                          pay_external_accounts pea,
                          per_time_periods ptp
                    WHERE ppt.payment_type_id = ppttl.payment_type_id
                      AND ppttl.LANGUAGE = USERENV ('LANG')
                      AND popmf.org_payment_method_id =
                                                 popmftl.org_payment_method_id
                      AND popmftl.LANGUAGE = USERENV ('LANG')
                      AND ppa.payroll_action_id = paa.payroll_action_id
                      AND (   p_consolidation_set_id IS NULL
                           OR ppa.consolidation_set_id =
                                                        p_consolidation_set_id
                          )
                      AND ppa.action_type IN ('U', 'P')
                      AND ppa.action_status = 'C'
                      AND ppa.payroll_id = p_payroll_id
		      AND ptp.payroll_id = ppa.payroll_id                           -- Bug 5070091 Offset payroll Change
		      -- Commented for Time Period Change

                      --AND ptp.time_period_id = p_period_id
                     /* AND ppa.effective_date BETWEEN ptp.start_date
                                                 AND ptp.regular_payment_date
		      */
                      AND ppa.effective_date BETWEEN popmf.effective_start_date
                                                 AND popmf.effective_end_date
                      AND paa.assignment_action_id = ppp.assignment_action_id
                      AND ppp.org_payment_method_id =
                                                   popmf.org_payment_method_id
                      AND popmf.payment_type_id = ppt.payment_type_id
                      AND popmf.external_account_id = pea.external_account_id
                      AND exists ( SELECT NULL                                      -- Bug 5070091 Offset payroll Change
                                   FROM pay_assignment_actions paa_run,
                                        pay_action_interlocks pai_run,
                                        pay_payroll_actions ppa_run
                                   WHERE ppa_run.payroll_id = p_payroll_id
				     AND ptp.time_period_id = p_period_id
                                     AND ppa_run.date_earned between ptp.start_date and ptp.end_date
                                     AND ppa_run.action_type in ('R','Q')
                                     AND ppa_run.payroll_action_id = paa_run.payroll_action_id
                                     AND paa_run.assignment_action_id = pai_run.locked_action_id
                                     AND pai_run.locking_action_id = paa.assignment_action_id
                                 )
                 GROUP BY ppttl.payment_type_name,
                          popmftl.org_payment_method_name,
                          pea.segment1,
                          pea.segment2,
                          pea.segment3,
                          pea.segment4,
                          pea.segment5,
                          ppa.consolidation_set_id,
                          ppa.effective_date,
                          ptp.start_date,
                          ptp.end_date,
                          popmf.effective_start_date,
                          popmf.effective_end_date);

--
/* Moved entire query to exists clause so that it comes out from sub query as soon as it finds a
   record with no Payments (5042843) */
      CURSOR csr_get_warning_not_all_pay
      IS
         SELECT '*** Warning: Not all payroll runs have been paid in this
payroll period ***'
                                               text_not_all_payroll_runs_paid
           FROM DUAL
	   WHERE EXISTS ( SELECT NULL
	                    FROM pay_payroll_actions ppa,
			         pay_assignment_actions paa,
				 per_time_periods ptp                                 -- Bug 5070091 Offset payroll change
			   WHERE paa.payroll_action_id = ppa.payroll_action_id
			     AND ppa.action_status = 'C'
			     AND ppa.action_type IN ('Q', 'R')
			     AND ppa.payroll_id = p_payroll_id
			     AND ptp.payroll_id = ppa.payroll_id                      -- Bug 5070091 Offset payroll change
			     AND ppa.date_earned between ptp.start_date and ptp.end_date
			     --AND ppa.time_period_id = p_period_id
			     AND NOT EXISTS (
					     SELECT 1
					       FROM pay_action_interlocks pai,
						    pay_assignment_actions paa1,
						    pay_payroll_actions ppa1
					      WHERE pai.locked_action_id = paa.assignment_action_id
					        AND pai.locking_action_id = paa1.assignment_action_id
					        AND paa1.payroll_action_id = ppa1.payroll_action_id
					        AND ppa1.action_type IN ('U', 'P')
					        AND ppa1.action_status = 'C'
				            )
                         );

--
      CURSOR csr_get_warning_prev_pay
      IS
         SELECT '*** Warning: These Amount totals include payments from previous
payroll period(s) ***'
                                               payments_from_previous_periods
           FROM /* per_time_periods ptp, */
                pay_payroll_actions ppa,
                pay_assignment_actions paa,
                pay_pre_payments ppp
          WHERE paa.payroll_action_id = ppa.payroll_action_id
            AND (   p_consolidation_set_id IS NULL
                 OR ppa.consolidation_set_id = p_consolidation_set_id
                )
            AND ppa.action_status = 'C'
            AND ppa.payroll_id = p_payroll_id
            --AND ptp.time_period_id = p_period_id
            --AND ppa.effective_date BETWEEN ptp.start_date AND ptp.end_date
            AND ppa.action_type IN ('U', 'P')
            AND ppp.assignment_action_id = paa.assignment_action_id
            AND EXISTS (
                   SELECT 1
                     FROM pay_action_interlocks pai,
                          pay_assignment_actions paa1,
                          pay_payroll_actions ppa1,
			  per_time_periods ptp1
                    WHERE pai.locking_action_id = paa.assignment_action_id
                      AND pai.locked_action_id = paa1.assignment_action_id
                      AND ppa1.payroll_action_id = paa1.payroll_action_id
                      AND ppa1.action_type IN ('Q', 'R')
                      AND ppa1.action_status = 'C'
		      AND ppa1.payroll_id = ptp1.payroll_id                       --Bug 5070091 Offset payroll change
		      AND ppa1.date_earned between ptp1.start_date and ptp1.end_date
		      AND ptp1.time_period_id <> p_period_id)
                      --AND ppa1.time_period_id <> ptp.time_period_id);
	    AND EXISTS (
	           SELECT 1
            		FROM pay_action_interlocks pai2,
                          pay_assignment_actions paa2,
                          pay_payroll_actions ppa2,
			  per_time_periods ptp2
                   WHERE pai2.locking_action_id = paa.assignment_action_id
                     AND pai2.locked_action_id = paa2.assignment_action_id
                     AND ppa2.payroll_action_id = paa2.payroll_action_id
                     AND ppa2.action_type IN ('Q', 'R')
                     AND ppa2.action_status = 'C'
                     AND ppa2.payroll_id =   ptp2.payroll_id
                     AND ppa2.date_earned between ptp2.start_date and ptp2.end_date
                     AND ptp2.time_period_id = p_period_id
                     );


--
      l_pymt_type                pay_payment_types_tl.payment_type_name%TYPE;
      l_master_rec               VARCHAR2 (1);
   BEGIN
      hr_utility.set_location ('Input Parameters', 01);
      hr_utility.set_location ('p_bg_id		  ' || p_bg_id, 01);
      hr_utility.set_location ('p_period_id		  ' || p_period_id, 01);
      hr_utility.set_location ('p_payroll_id	  ' || p_payroll_id, 01);
      hr_utility.set_location (   'p_consolidation_set_id'
                               || p_consolidation_set_id,
                               01
                              );
      l_bg_name :=
             RTRIM (SUBSTRB (hr_reports.get_business_group (p_bg_id), 1, 240));
      OPEN csr_payroll_name;
      FETCH csr_payroll_name
       INTO l_payroll_name;
      CLOSE csr_payroll_name;
      OPEN csr_time_period;
      FETCH csr_time_period
       INTO l_time_period;
      CLOSE csr_time_period;

      IF (p_consolidation_set_id IS NOT NULL)
      THEN
         OPEN csr_consolidation_set_name;
         FETCH csr_consolidation_set_name
          INTO l_consolidation_set_name;
         CLOSE csr_consolidation_set_name;
      END IF;

      SELECT fnd_date.date_to_displaydate (SYSDATE)
        INTO l_report_date
        FROM DUAL;
      hr_utility.set_location ('Header Table Creation', 10);
      vxmltable.DELETE;
      vctr := 1;
      vxmltable (vctr).tagname := 'G_HEADER';
      vxmltable (vctr).tagvalue := ' ';

      IF (l_bg_name IS NOT NULL)
      THEN
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'BUSINESS_GROUP';
         vxmltable (vctr).tagvalue := l_bg_name;
      END IF;

      IF (l_payroll_name IS NOT NULL)
      THEN
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'PAYROLL_NAME';
         vxmltable (vctr).tagvalue := l_payroll_name;
      END IF;

      IF (l_time_period IS NOT NULL)
      THEN
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'TIME_PERIOD';
         vxmltable (vctr).tagvalue := l_time_period;
      END IF;

      IF (l_consolidation_set_name IS NOT NULL)
      THEN
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'CONSOLIDATION_SET_NAME';
         vxmltable (vctr).tagvalue := l_consolidation_set_name;
      END IF;

      vctr := vctr + 1;
      vxmltable (vctr).tagname := 'REPORT_DATE';
      vxmltable (vctr).tagvalue := l_report_date;
      vctr := vctr + 1;
      vxmltable (vctr).tagname := '/G_HEADER';
      vxmltable (vctr).tagvalue := ' ';
      l_pymt_type := NULL;
      l_master_rec := NULL;

      FOR c_pymt_record IN csr_get_pymt_data
      LOOP
         IF (l_master_rec <> c_pymt_record.dummy_break OR l_master_rec IS NULL
            )
         THEN
            vctr := vctr + 1;
            vxmltable (vctr).tagname := 'G_PAYMENT_MASTER_RECORD';
            vxmltable (vctr).tagvalue := ' ';
            vctr := vctr + 1;
            vxmltable (vctr).tagname := 'TOTAL_AMOUNT_PAID';
            vxmltable (vctr).tagvalue := (c_pymt_record.total_amount_paid);
            vctr := vctr + 1;
            vxmltable (vctr).tagname := 'TOTAL_ASG_PAID';
            vxmltable (vctr).tagvalue := (c_pymt_record.total_asg_paid);
            l_master_rec := c_pymt_record.dummy_break;
         END IF;

         IF (   l_pymt_type <> c_pymt_record.payment_method_type
             OR l_pymt_type IS NULL
            )
         THEN
            IF (l_pymt_type IS NOT NULL)
            THEN
               vctr := vctr + 1;
               vxmltable (vctr).tagname := '/G_PYMT_TYPE_RECORD';
               vxmltable (vctr).tagvalue := ' ';
            END IF;

            vctr := vctr + 1;
            vxmltable (vctr).tagname := 'G_PYMT_TYPE_RECORD';
            vxmltable (vctr).tagvalue := ' ';
            vctr := vctr + 1;
            vxmltable (vctr).tagname := 'PAYMENT_METHOD_TYPE_TOTALS';
            vxmltable (vctr).tagvalue :=
                                   (c_pymt_record.payment_method_type_totals
                                   );
            vctr := vctr + 1;
            vxmltable (vctr).tagname := 'AMOUNT_PAID_PER_TYPE';
            vxmltable (vctr).tagvalue := (c_pymt_record.amount_per_type);
            vctr := vctr + 1;
            vxmltable (vctr).tagname := 'ASG_PAID_PER_TYPE';
            vxmltable (vctr).tagvalue := (c_pymt_record.asg_paid_per_type);
            l_pymt_type := c_pymt_record.payment_method_type;
         END IF;

         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'G_PYMT_RECORD';
         vxmltable (vctr).tagvalue := ' ';
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'PAYMENT_METHOD_TYPE';
         vxmltable (vctr).tagvalue := (c_pymt_record.payment_method_type);
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'PAYMENT_METHOD_NAME';
         vxmltable (vctr).tagvalue := (c_pymt_record.NAME);
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'SOURCE_SORT_CODE';
         vxmltable (vctr).tagvalue := (c_pymt_record.source_sort_code);
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'BANK_NAME';
         vxmltable (vctr).tagvalue := (c_pymt_record.bank_name);
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'BANK_BRANCH';
         vxmltable (vctr).tagvalue := (c_pymt_record.bank_branch);
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'ACCOUNT_NUMBER';
         vxmltable (vctr).tagvalue := (c_pymt_record.account_number);
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'ACCOUNT_NAME';
         vxmltable (vctr).tagvalue := (c_pymt_record.account_name);
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'AMOUNT';
         vxmltable (vctr).tagvalue := (c_pymt_record.amount);
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'TOTAL_ASSIGNMENTS_PAID';
         vxmltable (vctr).tagvalue := (c_pymt_record.total_assignments_paid);
         vctr := vctr + 1;
         vxmltable (vctr).tagname := '/G_PYMT_RECORD';
         vxmltable (vctr).tagvalue := ' ';
         hr_utility.set_location ('TableCnt' || TO_CHAR (vxmltable.COUNT), 18);
      END LOOP;

      IF (l_master_rec IS NOT NULL)
      THEN
         IF (l_pymt_type IS NOT NULL)
         THEN
            vctr := vctr + 1;
            vxmltable (vctr).tagname := '/G_PYMT_TYPE_RECORD';
            vxmltable (vctr).tagvalue := ' ';
         END IF;

         vctr := vctr + 1;
         vxmltable (vctr).tagname := '/G_PAYMENT_MASTER_RECORD';
         vxmltable (vctr).tagvalue := ' ';
      ELSE                       /*since l_master_rec is null no data found */
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'NO_DATA_FOUND';
         vxmltable (vctr).tagvalue := '-----  No Data Found  -----';
      END IF;

      FOR c_warning IN csr_get_warning_not_all_pay
      LOOP
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'NOT_ALL_PAY_WARNING';
         vxmltable (vctr).tagvalue :=
                                     c_warning.text_not_all_payroll_runs_paid;
         EXIT;
      END LOOP;

      FOR c_warning IN csr_get_warning_prev_pay
      LOOP
         vctr := vctr + 1;
         vxmltable (vctr).tagname := 'PREV_PAY_WARNING';
         vxmltable (vctr).tagvalue :=
                                     c_warning.payments_from_previous_periods;
         EXIT;
      END LOOP;

      hr_utility.set_location ('TableCnt' || TO_CHAR (vxmltable.COUNT), 13);
      writetoclob (p_xml);
   END populate_pymt_summary_rep;
END pay_ie_pymt_summary_rpt_pkg;

/
