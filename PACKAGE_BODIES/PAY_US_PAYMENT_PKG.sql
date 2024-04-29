--------------------------------------------------------
--  DDL for Package Body PAY_US_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_PAYMENT_PKG" AS
/* $Header: pyuspymt.pkb 120.0 2005/05/29 09:52:43 appldev noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2005 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_payment_pkg

    Description : This package contains the function get_trx_date to
                  fetch the payment date.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------
    27-APR-2005 rsethupa   115.0            Created

    *****************************************************************

    ****************************************************************************
    Function Name: get_trx_date
    Description: Returns the Payment Date for a Check Payroll Action
    ***************************************************************************/
   FUNCTION get_trx_date (
      p_business_group_id       pay_payroll_actions.business_group_id%TYPE,
      p_payroll_action_id       pay_payroll_actions.payroll_action_id%TYPE,
      p_assignment_action_id    pay_assignment_actions.assignment_action_id%TYPE
            DEFAULT NULL,
      p_payroll_id              pay_payroll_actions.payroll_id%TYPE
            DEFAULT NULL,
      p_consolidation_set_id    pay_payroll_actions.consolidation_set_id%TYPE
            DEFAULT NULL,
      p_org_payment_method_id   pay_payroll_actions.org_payment_method_id%TYPE
            DEFAULT NULL,
      p_effective_date          pay_payroll_actions.effective_date%TYPE
            DEFAULT NULL,
      p_date_earned             pay_payroll_actions.date_earned%TYPE
            DEFAULT NULL,
      p_override_date           pay_payroll_actions.overriding_dd_date%TYPE
            DEFAULT NULL,
      p_pre_payment_id          pay_pre_payments.pre_payment_id%TYPE
            DEFAULT NULL,
      p_payment_date            pay_payroll_actions.effective_date%TYPE
            DEFAULT NULL
   )
      RETURN DATE
   IS
      /**************************************************************************
       Cursor Name: c_get_override_date
       Description: Fetches the value of the overriding_dd_date column for the
                    the Check Writer payroll Action. More number of parameters
          are passed as input to improve performance
       *************************************************************************/
      CURSOR c_get_override_date (
         cp_business_group_id       IN   NUMBER,
         cp_payroll_action_id       IN   NUMBER,
         cp_payroll_id              IN   NUMBER,
         cp_consolidation_set_id    IN   NUMBER,
         cp_org_payment_method_id   IN   NUMBER,
         cp_effective_date          IN   DATE,
         cp_date_earned             IN   DATE
      )
      IS
         SELECT overriding_dd_date
           FROM pay_payroll_actions
          WHERE business_group_id = cp_business_group_id
            AND payroll_action_id = cp_payroll_action_id
            AND payroll_id = NVL (cp_payroll_id, payroll_id)
            AND consolidation_set_id =
                             NVL (cp_consolidation_set_id, consolidation_set_id)
            AND org_payment_method_id =
                           NVL (cp_org_payment_method_id, org_payment_method_id)
            AND effective_date = NVL (cp_effective_date, effective_date)
            AND date_earned = NVL (cp_date_earned, date_earned);

      /**************************************************************************
       Cursor Name: c_get_pymt_effective_date
       Description: Takes as INPUT the payroll_action_id of Check Writer and
                    other optional parameters. By checking for ASSACT interlocks
          it fetches the effective_date of the prepayment action
          locked by the Check Writer action
       *************************************************************************/
      CURSOR c_get_pymt_effective_date (
         cp_business_group_id       IN   NUMBER,
         cp_payroll_action_id       IN   NUMBER,
         cp_assignment_action_id    IN   NUMBER,
         cp_payroll_id              IN   NUMBER,
         cp_consolidation_set_id    IN   NUMBER,
         cp_org_payment_method_id   IN   NUMBER,
         cp_effective_date          IN   DATE,
         cp_date_earned             IN   DATE,
         cp_pre_payment_id          IN   NUMBER
      )
      IS
         SELECT NVL (ppa_chk.overriding_dd_date, ppa_pre.effective_date)
           FROM pay_payroll_actions ppa_chk,
                pay_assignment_actions paa_chk,
                pay_payroll_actions ppa_pre,
                pay_assignment_actions paa_pre,
                pay_action_interlocks pai,
                pay_pre_payments ppp
          WHERE ppa_chk.payroll_action_id = cp_payroll_action_id
            AND ppa_chk.business_group_id = cp_business_group_id
            AND ppa_chk.payroll_id = NVL (cp_payroll_id, ppa_chk.payroll_id)
            AND ppa_chk.consolidation_set_id =
                     NVL (cp_consolidation_set_id, ppa_chk.consolidation_set_id)
            AND ppa_chk.org_payment_method_id =
                   NVL (cp_org_payment_method_id, ppa_chk.org_payment_method_id)
            AND ppa_chk.effective_date =
                                 NVL (cp_effective_date, ppa_chk.effective_date)
            AND ppa_chk.date_earned = NVL (cp_date_earned, ppa_chk.date_earned)
            AND ppa_chk.action_type = 'H'
            AND ppa_chk.payroll_action_id = paa_chk.payroll_action_id
            AND paa_chk.action_status = 'C'
            AND paa_chk.assignment_action_id = pai.locking_action_id
            AND pai.locked_action_id = paa_pre.assignment_action_id
            AND paa_pre.payroll_action_id = ppa_pre.payroll_action_id
            AND paa_pre.action_status = 'C'
            AND ppa_pre.action_type IN ('P', 'U')
            AND paa_pre.assignment_action_id = ppp.assignment_action_id
            AND ppp.pre_payment_id = NVL (cp_pre_payment_id, ppp.pre_payment_id)
            AND ppp.pre_payment_id = paa_chk.pre_payment_id
            AND ppp.org_payment_method_id = ppa_chk.org_payment_method_id;

      /**************************************************************************
       Cursor Name: c_get_pymt_date_with_prepay_id
       Description: Takes as INPUT the pre_payment_id and fetches effective_date
                    of the prepayment action. This cursor is opened only if the
          the overriding_dd_date column for the Check Writer action is
          NULL and a pre_payment_id is passed
       *************************************************************************/
      CURSOR c_get_pymt_date_with_prepay_id (cp_pre_payment_id IN NUMBER)
      IS
         SELECT ppa.effective_date
           FROM pay_pre_payments ppp,
                pay_assignment_actions paa,
                pay_payroll_actions ppa
          WHERE ppp.pre_payment_id = cp_pre_payment_id
            AND ppp.assignment_action_id = paa.assignment_action_id
            AND paa.payroll_action_id = ppa.payroll_action_id
            AND ppa.action_type IN ('P', 'U');

      l_override_date   pay_payroll_actions.overriding_dd_date%TYPE;
      l_table_count     NUMBER;
   BEGIN
      -- hr_utility.trace_on (NULL, 'PYMT');
      hr_utility.set_location ('pay_us_payment_pkg.get_trx_date', 10);
      hr_utility.TRACE ('p_business_group_id: ' || p_business_group_id);
      hr_utility.TRACE ('p_payroll_action_id: ' || p_payroll_action_id);
      hr_utility.TRACE ('p_assignment_action_id: ' || p_assignment_action_id);
      hr_utility.TRACE ('p_payroll_id: ' || p_payroll_id);
      hr_utility.TRACE ('p_consolidation_set_id: ' || p_consolidation_set_id);
      hr_utility.TRACE ('p_org_payment_method_id: ' || p_org_payment_method_id);
      hr_utility.TRACE ('p_effective_date: ' || p_effective_date);
      hr_utility.TRACE ('p_date_earned: ' || p_date_earned);
      hr_utility.TRACE ('p_override_date: ' || p_override_date);
      hr_utility.TRACE ('p_pre_payment_id: ' || p_pre_payment_id);
      hr_utility.TRACE ('p_payment_date: ' || p_payment_date);

      IF p_override_date IS NOT NULL
      THEN
         l_override_date := p_override_date;
      ELSE
         /* Check if the override_date is already cached for a payroll_Action_id */
         IF ltr_override_date_table.COUNT > 0
         THEN
            FOR j IN
               ltr_override_date_table.FIRST .. ltr_override_date_table.LAST
            LOOP
               IF ltr_override_date_table (j).payroll_action_id =
                                                            p_payroll_action_id
               THEN
                  l_override_date := ltr_override_date_table (j).override_date;
                  hr_utility.set_location ('pay_us_payment_pkg.get_trx_date',
                                           20
                                          );
                  EXIT;
               END IF;
            END LOOP;
         ELSIF ltr_override_date_table.COUNT = 0
         THEN
            /* Check if OVERRIDING_DD_DATE has a value for the Check Writer Action */
            OPEN c_get_override_date (p_business_group_id,
                                      p_payroll_action_id,
                                      p_payroll_id,
                                      p_consolidation_set_id,
                                      p_org_payment_method_id,
                                      p_effective_date,
                                      p_date_earned
                                     );

            FETCH c_get_override_date
             INTO l_override_date;

            CLOSE c_get_override_date;

            hr_utility.set_location ('pay_us_payment_pkg.get_trx_date', 30);
            l_table_count := ltr_override_date_table.COUNT;
            ltr_override_date_table (l_table_count).payroll_action_id :=
                                                             p_payroll_action_id;
            ltr_override_date_table (l_table_count).override_date :=
                                                                 l_override_date;
         END IF;                                            -- check for caching

         IF l_override_date IS NULL
         THEN
            IF p_payment_date IS NOT NULL
            THEN
               l_override_date := p_payment_date;
               hr_utility.set_location ('pay_us_payment_pkg.get_trx_date', 40);
            ELSIF p_pre_payment_id IS NOT NULL
            THEN
               /* Just fetch prepayment action's effective_date with pre_payment_id.
                  This improves performance by not checking for interlocks */
               OPEN c_get_pymt_date_with_prepay_id (p_pre_payment_id);

               FETCH c_get_pymt_date_with_prepay_id
                INTO l_override_date;

               CLOSE c_get_pymt_date_with_prepay_id;

               hr_utility.set_location ('pay_us_payment_pkg.get_trx_date', 50);
            ELSE
               /* With the help of interlocks, get prepayment effective_date */
               OPEN c_get_pymt_effective_date (p_business_group_id,
                                               p_payroll_action_id,
                                               p_assignment_action_id,
                                               p_payroll_id,
                                               p_consolidation_set_id,
                                               p_org_payment_method_id,
                                               p_effective_date,
                                               p_date_earned,
                                               p_pre_payment_id
                                              );

               FETCH c_get_pymt_effective_date
                INTO l_override_date;

               CLOSE c_get_pymt_effective_date;

               hr_utility.set_location ('pay_us_payment_pkg.get_trx_date', 60);
            END IF;                             -- if p_payment_date is not null
         END IF;                                   -- if l_override_date is null
      END IF;

      -- if p_override_date is not null
      RETURN l_override_date;
   END;
END pay_us_payment_pkg;

/
