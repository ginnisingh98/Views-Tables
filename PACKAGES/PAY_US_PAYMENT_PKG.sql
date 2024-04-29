--------------------------------------------------------
--  DDL for Package PAY_US_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_PAYMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: pyuspymt.pkh 120.0 2005/05/29 09:52:53 appldev noship $ */
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
      RETURN DATE;

   TYPE override_date_record IS RECORD (
      payroll_action_id   pay_payroll_actions.payroll_action_id%TYPE,
      override_date       pay_payroll_actions.overriding_dd_date%TYPE
   );

   TYPE override_date_table IS TABLE OF override_date_record
      INDEX BY BINARY_INTEGER;

   ltr_override_date_table   override_date_table;
END;

 

/
