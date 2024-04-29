--------------------------------------------------------
--  DDL for Package Body PAY_MX_SS_ARCH_TRAN_DATE_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_SS_ARCH_TRAN_DATE_UPG" AS
/* $Header: paymxsstrandtupg.pkb 120.0.12000000.1 2007/05/02 10:05:43 sdahiya noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2004, Oracle India Pvt. Ltd., Hyderabad         *
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
    Package Name        : PAY_MX_SS_ARCH_TRAN_DATE_UPG
    Package File Name   : paymxsstrandtupg.pkb

    Description : Used for Social Security Archiver upgrade for transaction
                  date.

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sdahiya       24-Jan-2007 115.0           Created.

   ***************************************************************************/

--
-- Global Variables
--
    g_proc_name     varchar2(240);
    g_debug         boolean;


  /****************************************************************************
    Name        : HR_UTILITY_TRACE
    Description : This procedure prints debug messages.
  *****************************************************************************/
PROCEDURE HR_UTILITY_TRACE
(
    P_TRC_DATA  varchar2
) AS
BEGIN
    IF g_debug THEN
        hr_utility.trace(p_trc_data);
    END IF;
END HR_UTILITY_TRACE;


  /****************************************************************************
    Name        : QUAL_PROC
    Description : Qualifying procedure for generic upgrade process.
  *****************************************************************************/
PROCEDURE QUAL_PROC
(
    P_OBJECT_ID NUMBER,
    P_QUAL      OUT NOCOPY VARCHAR2
) AS

    CURSOR csr_qualified IS
        SELECT 'Y'
          FROM pay_payroll_actions ppa,
               pay_assignment_actions paa,
               pay_action_information pai
         WHERE ppa.payroll_action_id = paa.payroll_action_id
           AND paa.assignment_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS TRANSACTIONS'
           AND paa.assignment_id = p_object_id
           AND ppa.report_type = 'SS_ARCHIVE'
           AND ppa.report_qualifier = 'SS_ARCHIVE'
           AND ppa.report_category = 'RT';

    l_proc_name     varchar2(100);

BEGIN
    l_proc_name := g_proc_name || 'QUAL_PROC';
    hr_utility_trace ('Entering '||l_proc_name);

    p_qual := 'N';
    OPEN csr_qualified;
        FETCH csr_qualified INTO p_qual;
    CLOSE csr_qualified;

    IF p_qual = 'Y' THEN
        hr_utility_trace('Assignment ' || p_object_id || ' qualified.');
    ELSE
        hr_utility_trace('Assignment ' || p_object_id || ' did not qualify.');
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);
END QUAL_PROC;

  /****************************************************************************
    Name        : UPG_PROC
    Description : Upgrade procedure for generic upgrade process.
  *****************************************************************************/
PROCEDURE UPG_PROC
(
    P_OBJECT_ID NUMBER
) AS

    CURSOR csr_upgrade IS
        SELECT pai.action_information2,
               pai.action_information5,
               pai.action_information_id,
               pai.object_version_number
          FROM pay_payroll_actions ppa,
               pay_assignment_actions paa,
               pay_action_information pai
         WHERE ppa.payroll_action_id = paa.payroll_action_id
           AND paa.assignment_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS TRANSACTIONS'
           AND paa.assignment_id = p_object_id
           AND ppa.report_type = 'SS_ARCHIVE'
           AND ppa.report_qualifier = 'SS_ARCHIVE'
           AND ppa.report_category = 'RT';

    lv_transaction_date     pay_action_information.action_information5%type;
    lv_er_ss_id             pay_action_information.action_information2%type;
    ln_act_info_id          number;
    l_object_version_number number;

    l_proc_name         varchar2(100);
    ln_count            number;

BEGIN
    l_proc_name := g_proc_name || 'UPG_PROC';
    hr_utility_trace ('Entering '||l_proc_name);

    ln_count := 0;
    OPEN csr_upgrade;
        LOOP
            FETCH csr_upgrade INTO lv_er_ss_id,
                                   lv_transaction_date,
                                   ln_act_info_id,
                                   l_object_version_number;
            EXIT WHEN csr_upgrade%NOTFOUND;

            pay_action_information_api.update_action_information
               (p_action_information_id   => ln_act_info_id,
                p_object_version_number   => l_object_version_number,
                p_action_information2     => lv_transaction_date,
                p_action_information5     => lv_er_ss_id);

             ln_count := ln_count + 1;
        END LOOP;
         hr_utility_trace(ln_count ||
                          ' transaction(s) upgraded for assignment '||
                                                              p_object_id);
    CLOSE csr_upgrade;
    hr_utility_trace ('Leaving '||l_proc_name);
END UPG_PROC;

BEGIN
    --hr_utility.trace_on(null, 'MX_IDC');
    g_proc_name := 'PAY_MX_SS_ARCH_TRAN_DATE_UPG.';
    g_debug := hr_utility.debug_enabled;
END PAY_MX_SS_ARCH_TRAN_DATE_UPG;

/
