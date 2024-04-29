--------------------------------------------------------
--  DDL for Package Body PAY_JP_UITE_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_UITE_ARCH_PKG" AS
-- $Header: pyjpuiar.pkb 120.0.12010000.13 2010/06/02 19:15:05 mpothala noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  pyjpuiar.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of pay_jp_uite_arch_pkg
-- *
-- * USAGE
-- *   To install       sqlplus <apps_user>/<apps_pwd> @pyjpuiar.pkb
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC pay_jp_uite_arch_pkg.<procedure name>
-- *
-- * PROGRAM LIST
-- * ==========
-- * NAME                 DESCRIPTION
-- * -----------------    --------------------------------------------------
-- * RANGE_CODE
-- * INITIALIZATION_CODE
-- * ASSIGNMENT_ACTION_CODE
-- * ARCHIVE_CODE
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   08-Feb-2010
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * VERSION             DATE        AUTHOR(S)             DESCRIPTION
-- * ------- ----------- -----------------------------------------------------------
-- * 120.0.12010000.1  08-Mar-2010   RDARASI/MPOTHALA      Creation
-- * 120.0.12010000.2  06-Apr-2010   MPOTHALA              Fixed patch review comments
-- * 120.0.12010000.3  12-Apr-2010   MPOTHALA              Fixed patch review comments
-- * 120.0.12010000.4  16-Apr-2010   MPOTHALA              Fixed for bug #9596298
-- * 120.0.12010000.5  16-Apr-2010   MPOTHALA              Fixed for bug #9648082,9648137,9652235,9655892,9652251
-- * 120.0.12010000.6  06-May-2010   MPOTHALA              Fixed for bug #9648082,9653516,9702153
-- * 120.0.12010000.7  06-May-2010   MPOTHALA              Fixed for bug #9648082,9653516,9702153
-- * 120.0.12010000.8  06-May-2010   MPOTHALA              Fixed for bug #9648082,9653516,9702153
-- * 120.0.12010000.9  21-May-2010   MPOTHALA              Fixed for bug #9728577,9732294
-- * 120.0.12010000.10 26-May-2010   MPOTHALA              Fixed for bug #9728577,9732294
-- * 120.0.12010000.11 26-May-2010   MPOTHALA              Fixed for bug #9732572
-- * 120.0.12010000.12 02-Jun-2010   MPOTHALA              Fixed for bug #9732572
-- * 120.0.12010000.13 02-Jun-2010   MPOTHALA              Fixed for bug #9732572
-- *********************************************************************************

  --Declaration of constant global variables

  gc_package                  CONSTANT VARCHAR2(60) := 'pay_jp_uite_arch_pkg.';
  gc_sal_ele_set              VARCHAR2(20) := 'SAL';
  gc_spb_ele_set              VARCHAR2(20) := 'SPB';
  gc_legislation_code         per_business_groups.legislation_code%TYPE;
  gc_date_earned              CONSTANT VARCHAR2(30) := 'DATE_EARNED';
  gc_date_paid                CONSTANT VARCHAR2(30) := 'DATE_PAID';
  gn_max_period               CONSTANT NUMBER       := 48;
  --  Declaration of global variables
  gn_arc_payroll_action_id    pay_payroll_actions.payroll_action_id%type;
  gn_business_group_id        hr_all_organization_units.organization_id%TYPE;
  gn_payroll_action_id        pay_payroll_actions.payroll_action_id%TYPE;
  gb_debug                    BOOLEAN;
  gd_end_date                 DATE;
  gd_start_date               DATE;
  gc_exception                EXCEPTION;
  gc_santei_base              VARCHAR2(20) DEFAULT  gc_date_earned;
  gn_output_period            NUMBER       DEFAULT  12;
  gn_sal_ele_set_id           pay_element_sets.element_set_id%TYPE;
  gn_spb_ele_set_id           pay_element_sets.element_set_id%TYPE;
  --
  TYPE gt_wage_info IS RECORD (payment_date          DATE
                             ,insured_start_date    DATE
                             ,insured_end_date      DATE
                             ,insured_days          NUMBER
                             ,period_start_date     DATE
                             ,period_end_date       DATE
                             ,base_days             NUMBER
                             ,wage_amount_a         NUMBER
                             ,wage_amount_b         NUMBER
                             ,remarks               VARCHAR2(60)
                             ,exclude_period        VARCHAR2(10)
                             ,line_number           NUMBER
                              );
  --
  TYPE gt_insert_wage_info IS TABLE OF gt_wage_info INDEX BY BINARY_INTEGER;
  --
  FUNCTION get_life_ins_org_id(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                              ,p_effective_date        IN   DATE)
  --************************************************************************
  -- FUNCTION
  -- get_life_ins_org_id
  --
  -- DESCRIPTION
  --  To Retrive life insurance organization Id
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN NUMBER
  IS
  --
  lc_procedure               VARCHAR2(200);
  ln_life_ins_org_id         NUMBER;
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'get_life_ins_org';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    ln_life_ins_org_id     :=  pay_jp_balance_pkg.get_entry_value_number(p_element_name     => 'COM_LI_INFO'
                                                                      ,p_input_value_name => 'EI_LOCATION'
                                                                      ,p_assignment_id    => p_assignment_id
                                                                      ,p_effective_date   => p_effective_date
                                                                      );

    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN ln_life_ins_org_id;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in get_life_ins_org_id',10);
    END IF;
    RETURN NULL;
    --
   WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END get_life_ins_org_id;
  --
  FUNCTION get_ei_type(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                       ,p_effective_date        IN   DATE)
  --************************************************************************
  -- FUNCTION
  -- get_ei_type
  --
  -- DESCRIPTION
  --  To Retrive Employee Insurance Type
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN VARCHAR2
  IS
  --
  lc_procedure               VARCHAR2(200);
  lc_ei_type                 VARCHAR2(60);
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'get_ei_type';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    lc_ei_type     :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_LI_INFO'
                                                                  ,p_input_value_name => 'EI_TYPE'
                                                                      ,p_assignment_id    => p_assignment_id
                                                                      ,p_effective_date   => p_effective_date
                                                                      );

    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN lc_ei_type;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in get_ei_type',10);
    END IF;
    RETURN NULL;
    --
   WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END get_ei_type;
  --
FUNCTION get_term_rpt_flag(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                          ,p_effective_date        IN   DATE)
  --************************************************************************
  -- FUNCTION
  -- get_ei_type
  --
  -- DESCRIPTION
  --  To Retrive Employee Insurance Type
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN VARCHAR2
  IS
  --
  lc_procedure               VARCHAR2(200);
  lc_term_rpt_flag           VARCHAR2(60);
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'get_term_rpt_flag';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    lc_term_rpt_flag      :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_EI_QUALIFY_INFO'
                                                                     ,p_input_value_name => 'TRM_REPORT_OUTPUT_FLAG'
                                                                     ,p_assignment_id    => p_assignment_id
                                                                     ,p_effective_date   => p_effective_date
                                                                     );

    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN lc_term_rpt_flag;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in get_term_rpt_flag',10);
    END IF;
    RETURN NULL;
    --
   WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END get_term_rpt_flag;
  --
  FUNCTION get_ei_qualify_date(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                               ,p_effective_date        IN   DATE)
  --************************************************************************
  -- FUNCTION
  -- get_ei_type
  --
  -- DESCRIPTION
  --  To Retrive Employee Insurance qulified date
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN DATE
  IS
  --
  lc_procedure               VARCHAR2(200);
  ld_qualify_date            DATE;
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'get_ei_quality_date';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    ld_qualify_date     :=  pay_jp_balance_pkg.get_entry_value_date(p_element_name     => 'COM_EI_QUALIFY_INFO'
                                                                    ,p_input_value_name => 'QUALIFY_DATE'
                                                                    ,p_assignment_id    => p_assignment_id
                                                                    ,p_effective_date   => p_effective_date
                                                                    );

    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN ld_qualify_date;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in get_ei_quality_date',10);
    END IF;
    RETURN NULL;
    --
   WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END get_ei_qualify_date;
  --
   FUNCTION get_ei_dis_qual_date(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                               ,p_effective_date        IN   DATE)
  --************************************************************************
  -- FUNCTION
  -- get_ei_type
  --
  -- DESCRIPTION
  --  To Retrive Employee Insurance disqualified date
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN DATE
  IS
  --
  lc_procedure               VARCHAR2(200);
  ld_qualify_date            DATE;
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'get_ei_dis_qual_date';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    ld_qualify_date     :=  pay_jp_balance_pkg.get_entry_value_date(p_element_name     => 'COM_EI_QUALIFY_INFO'
                                                                    ,p_input_value_name => 'DISQUALIFY_DATE'
                                                                    ,p_assignment_id    => p_assignment_id
                                                                    ,p_effective_date   => p_effective_date
                                                                    );

    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN ld_qualify_date;
    --
   EXCEPTION

   WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in get_ei_dis_qual_date',10);
    END IF;
    RETURN NULL;
    --
   WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END get_ei_dis_qual_date;
  --
  FUNCTION get_ui_num(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                     ,p_effective_date        IN   DATE)
  --************************************************************************
  -- FUNCTION
  -- get_ui_num
  --
  -- DESCRIPTION
  --  To Retrive life insurance organization Id
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN VARCHAR2
  IS
  --
  lc_procedure               VARCHAR2(200);
  lc_ui_num                  VARCHAR2(20);
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'get_ui_num';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    lc_ui_num      :=  pay_jp_balance_pkg.get_entry_value_char(p_element_name     => 'COM_LI_INFO'
                                                             ,p_input_value_name => 'EI_NUM'
                                                             ,p_assignment_id    => p_assignment_id
                                                             ,p_effective_date   => p_effective_date
                                                             );

    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    RETURN lc_ui_num;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in get_ui_num',10);
    END IF;
    RETURN NULL;
    --
   WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
    RETURN NULL;
  END get_ui_num;
  --
  FUNCTION  get_element_set_id(p_element_set_name  IN  VARCHAR2
                              ,p_business_group_id IN  NUMBER
                              ,p_legislation_code  IN  VARCHAR2)
  --***********************************************************************
  -- FUNCTION
  -- get_element_set_id
  --
  -- DESCRIPTION
  --  To Retrive life element_set_id
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  archive_code
  --************************************************************************
  RETURN NUMBER
  IS
  --
  CURSOR csr_ele_set
  IS
  SELECT MIN(pes.element_set_id)
  FROM   pay_element_sets PES
  WHERE  PES.element_set_name = p_element_set_name
  AND    NVL(PES.business_group_id,p_business_group_id) = p_business_group_id
  AND    NVL(PES.legislation_code,p_legislation_code) = p_legislation_code;
  --
  ln_element_set_id           NUMBER;
  lc_procedure                VARCHAR2(200);
  --
  BEGIN
  --
    --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
     lc_procedure := gc_package||'RANGE_CODE';
     hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN csr_ele_set;
    FETCH csr_ele_set into ln_element_set_id;
    CLOSE csr_ele_set;
  --
  RETURN ln_element_set_id;
  --
  END get_element_set_id;
  --
 FUNCTION get_insert_action_info( p_insert_wage_info IN gt_insert_wage_info)
  --************************************************************************
  -- FUNCTION
  -- get_insert_action_info
  --
  -- DESCRIPTION
  --  Removes redundant insurance period if employee payroll has been in the
  --  middle of the month and payroll has been run more than once in a month
  --  ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  proc_sal_arch
  --************************************************************************
  RETURN gt_insert_wage_info
  AS
  --
  lt_res_tb                     gt_insert_wage_info;
  lc_procedure                  VARCHAR2(200);
  ln_count                      NUMBER;
  ld_insured_start_date         per_time_periods.start_date%TYPE;
  ld_insured_end_date           per_time_periods.end_date%TYPE;
  lc_duplicate_flag             VARCHAR2(1):='N';
  ln_insured_days               NUMBER;
  ln_ins_rows                   NUMBER:=0;
  ln_row_count                  NUMBER:=0;
  lc_final_flag                 VARCHAR2(1) DEFAULT 'N';
  ld_final_insured_date         DATE;
  --
BEGIN
  --
  gb_debug := hr_utility.debug_enabled;
  --
  IF gb_debug THEN
     lc_procedure := gc_package||'get_insert_action_info';
     hr_utility.set_location('Entering '||lc_procedure,1);
  END IF;
  --
  ln_count := p_insert_wage_info.count;
  --
  IF gb_debug THEN
     hr_utility.set_location('p_insert_wage_info count = '||ln_count,1);
  END IF;
  --
  IF ln_count=1 THEN
     --
     lt_res_tb := p_insert_wage_info;
     --
  ELSIF ln_count > 1 THEN
     --
     FOR i in p_insert_wage_info.first..p_insert_wage_info.last
     --
     LOOP
       --
       EXIT WHEN (lc_final_flag = 'Y');
       --
       IF i > 0 THEN
         --
         --Checking whether insured periods are same when payroll has been changed
         --
         IF ( (TRUNC(p_insert_wage_info(i).insured_start_date) = TRUNC(p_insert_wage_info(i-1).insured_start_date))
               AND  (TRUNC(p_insert_wage_info(i).insured_end_date) = TRUNC(p_insert_wage_info(i-1).insured_end_date)) ) THEN
           --
           IF (  i < p_insert_wage_info.last) THEN
             --
             ld_insured_start_date := p_insert_wage_info(i+1).insured_start_date;
             ld_insured_end_date   := p_insert_wage_info(i+1).insured_end_date;
             ln_insured_days       := p_insert_wage_info(i+1).insured_days;
             lc_duplicate_flag     := 'Y';
             --
            ELSE
             --
             ld_insured_start_date := NULL;
             ld_insured_end_date   := NULL;
             ln_insured_days       := NULL;
             --
           END IF;
           --
         ELSE
           --
           IF (lc_duplicate_flag = 'Y') THEN
             --
             IF  (i < p_insert_wage_info.last) THEN
               --
               ld_insured_start_date := p_insert_wage_info(i+1).insured_start_date;
               ld_insured_end_date   := p_insert_wage_info(i+1).insured_end_date;
               ln_insured_days       := p_insert_wage_info(i+1).insured_days;
               --
             ELSE
               --
               ld_insured_start_date := NULL;
               ld_insured_end_date   := NULL;
               ln_insured_days       := NULL;
               --
             END IF;
             --
           ELSE
             --
             ld_insured_start_date := p_insert_wage_info(i).insured_start_date;
             ld_insured_end_date   := p_insert_wage_info(i).insured_end_date;
             ln_insured_days       := p_insert_wage_info(i).insured_days;
             --
          END IF;
          --
         END IF;
         --
       ELSE
         --
         ld_insured_start_date := p_insert_wage_info(i).insured_start_date;
         ld_insured_end_date   := p_insert_wage_info(i).insured_end_date;
         ln_insured_days       := p_insert_wage_info(i).insured_days;
         --
       END IF;
       --
       IF ( (NVL(ln_insured_days,0) >= 11) AND (p_insert_wage_info(i).exclude_period = 'N') ) THEN
         --
         ln_ins_rows := ln_ins_rows +1;
         --
       END IF;
       --
       IF p_insert_wage_info(i).exclude_period = 'N' THEN
         --
         ln_row_count := ln_row_count + 1;
         --
       END IF;
       --
       IF ((ln_ins_rows = gn_output_period) OR (ln_row_count = 24)) THEN
       --
       ld_final_insured_date := ld_insured_start_date;

       --
       END IF;
       --
       IF TRUNC(ld_final_insured_date) BETWEEN p_insert_wage_info(i).period_start_date AND p_insert_wage_info(i).period_end_date THEN
         --
         lc_final_flag := 'Y';
         --
       END IF;
       --
       IF ((ln_ins_rows > gn_output_period) OR (ln_row_count > 24)) THEN
           --
           ld_insured_start_date := NULL;
           ld_insured_end_date   := NULL;
           ln_insured_days       := NULL;
           --
       END IF;
       --
       lt_res_tb(i).payment_date          := p_insert_wage_info(i).payment_date;            -- Payment Date
       lt_res_tb(i).insured_start_date    := ld_insured_start_date;                               -- Insured Period Start Date
       lt_res_tb(i).insured_end_date      := ld_insured_end_date;                                 -- Insured Period End Date
       lt_res_tb(i).insured_days          := ln_insured_days ;                                    -- Insured Period Base Days
       lt_res_tb(i).period_start_date     := p_insert_wage_info(i).period_start_date;                                -- Pay Period Start Date
       lt_res_tb(i).period_end_date       := p_insert_wage_info(i).period_end_date;                                  -- Pay Period End Date
       lt_res_tb(i).base_days             := p_insert_wage_info(i).base_days;                                        -- Pay Period Base Days
       lt_res_tb(i).wage_amount_a         := p_insert_wage_info(i).wage_amount_a;                                    -- Wage Amount A
       lt_res_tb(i).wage_amount_b         := p_insert_wage_info(i).wage_amount_b;                                    -- Wage Amount B
       lt_res_tb(i).remarks               := p_insert_wage_info(i).remarks;                                          -- Remarks
       lt_res_tb(i).exclude_period        := p_insert_wage_info(i).exclude_period;                          -- Exclude Period
       lt_res_tb(i).line_number           := p_insert_wage_info(i).line_number;                                      -- Line Number
       --
       ld_insured_start_date := NULL;
       ld_insured_end_date   := NULL;
       ln_insured_days       := NULL;
       --
     END LOOP;
   END IF;
   --
   RETURN lt_res_tb;
   --
   IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1);
   END IF;
   --
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in ' ||lc_procedure,10);
    END IF;
    RETURN lt_res_tb;
  END get_insert_action_info;
--

  PROCEDURE proc_insert_row( p_assignment_action_id   IN pay_assignment_actions.assignment_action_id%TYPE
                          ,p_payroll_action_id        IN pay_payroll_actions.payroll_action_id%TYPE
                          ,p_assignment_id            IN per_all_assignments_f.assignment_id%TYPE
                          ,p_effective_date           IN pay_payroll_actions.effective_date%TYPE
                          ,p_termination_date         IN per_periods_of_service.actual_termination_date%TYPE
                          ,p_payroll_id               IN pay_payrolls_f.payroll_id%TYPE
                          ,p_hire_date                IN per_periods_of_service.date_start%TYPE
                          ,p_last_std_process_date    IN per_periods_of_service.last_standard_process_date%TYPE
                          ,p_line_number              OUT NOCOPY NUMBER)
  IS
  --***************************************************************************
  -- PROCEDURE
  --   proc_insert_row
  --
  -- DESCRIPTION
  --   This procedure is used to process non payroll data
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  --==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  -- p_assignment_id            IN       This parameter passes Assignment Id
  -- p_effective_date           IN       This Parameter Passes Effective Date
  -- p_termination_date         IN       This Parameter passes the Termination Date
  -- p_payroll_id               IN       This Parameter passes the Payroll Id
  -- p_hire_date                IN       This parameter passes the hire date
  -- p_last_std_process_date    IN       This parameter passes the last standard process date
  -- p_ins_start_date           OUT      Passes back   Insurance start date
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --***********************************************************************
  lc_procedure                  VARCHAR2(200);
  --
  CURSOR lcu_period_for_no_assact
  IS
  SELECT   PTP.start_date,
           PTP.end_date
  FROM   per_time_periods PTP
  WHERE  PTP.payroll_id = p_payroll_id
  AND    p_termination_date  BETWEEN PTP.start_date AND PTP.end_date
  ORDER BY  PTP.start_date DESC;
  --
  ln_diff_mth                   NUMBER;
  ld_effective_date             pay_payroll_actions.effective_date%TYPE;
  ld_date_earned                pay_payroll_actions.date_earned%TYPE;
  ld_period_start_date          per_time_periods.start_date%TYPE;
  ld_period_end_date            per_time_periods.end_date%TYPE;
  ld_insured_start_date         per_time_periods.start_date%TYPE;
  ld_insured_end_date           per_time_periods.end_date%TYPE;
  ln_line_number                NUMBER:=0;
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  --
  lr_lcu_period_for_no_assact   lcu_period_for_no_assact%rowtype;
  --
  BEGIN
    --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
     lc_procedure := gc_package||'proc_insert_row';
     hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    OPEN lcu_period_for_no_assact;
      --
      FETCH lcu_period_for_no_assact INTO lr_lcu_period_for_no_assact;
      --
        ln_diff_mth := (TO_NUMBER(TO_CHAR(lr_lcu_period_for_no_assact.start_date,'YYYY'))
                       - TO_NUMBER(TO_CHAR(p_termination_date,'YYYY'))) * 12
                      + (TO_NUMBER(TO_CHAR(lr_lcu_period_for_no_assact.start_date,'MM'))
                         - TO_NUMBER(TO_CHAR(p_termination_date,'MM')));                   --#Bug 9653516
         --
         hr_utility.set_location('ln_diff_mth '||lc_procedure,20);
         --
         -- Wage Payment Days --
         --
         IF TO_CHAR(lr_lcu_period_for_no_assact.start_date,'MM') =  TO_CHAR(lr_lcu_period_for_no_assact.end_date,'MM') THEN
           --
           ld_insured_start_date := add_months(p_termination_date + 1,ln_diff_mth -1);    --#Bug 9653516
           ld_insured_end_date   := add_months(ld_insured_start_date,1) - 1;  --#Bug 9653516
           --
         ELSE
           --
           IF TO_CHAR(lr_lcu_period_for_no_assact.start_date,'YYYY') =  TO_CHAR(lr_lcu_period_for_no_assact.end_date,'YYYY') THEN  --#Bug 9732294
             --
             ld_insured_start_date := add_months(p_termination_date + 1,ln_diff_mth);    --#Bug 9702153
             ld_insured_end_date   := add_months(ld_insured_start_date,1) - 1;  --#Bug 9702153
             --
           ELSE
             --
             ld_insured_start_date := add_months(p_termination_date + 1,ln_diff_mth -1);    --#Bug 9732294
             ld_insured_end_date   := add_months(ld_insured_start_date,1) - 1;  --#Bug 9732294
             --
           END IF;
           --
         END IF;
         --
         ln_line_number        := ln_line_number + 1;
         --
         IF TRUNC(p_hire_date) >  TRUNC(ld_insured_start_date) THEN
           --
           ld_insured_start_date  := p_hire_date;
           --
         END IF;
         --
         IF TRUNC(p_hire_date) >  TRUNC(ld_insured_end_date) THEN
           --
           ld_insured_end_date:= p_hire_date;
           --
         END IF;
         --
         IF TRUNC(p_hire_date) >  TRUNC(lr_lcu_period_for_no_assact.start_date) THEN
           --
           ld_period_start_date := p_hire_date;
           --
         ELSE
           --
           ld_period_start_date := lr_lcu_period_for_no_assact.start_date;
           --
         END IF;
         --
         IF TRUNC(p_termination_date) BETWEEN lr_lcu_period_for_no_assact.start_date AND lr_lcu_period_for_no_assact.end_date THEN
           --
          ld_period_end_date := TRUNC(p_termination_date);
           --
         ELSE
           --
           ld_period_end_date := lr_lcu_period_for_no_assact.end_date;
           --
         END IF;
         --
         IF gb_debug THEN
           hr_utility.set_location('Insured Period Start Date '||ld_insured_start_date,12);
           hr_utility.set_location('Insured Period End Date '||ld_insured_end_date,13);
           hr_utility.set_location('Pay Period Start Date '||ld_period_start_date,15);
           hr_utility.set_location('Pay Period End Date '||ld_period_end_date,16);
         END IF;
         --
        pay_action_information_api.create_action_information
        (p_action_information_id         => ln_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => ln_obj_version_num
        , p_effective_date               => p_effective_date
        , p_assignment_id                => p_assignment_id
        , p_source_id                    => NULL
        , p_source_text                  => NULL
        , p_action_information_category  => 'JP_UITE_SAL'
        , p_action_information1          => fnd_date.date_to_canonical(ld_period_end_date)                         -- Payment Date
        , p_action_information2          => fnd_date.date_to_canonical(ld_insured_start_date)                      -- Insured Period Start Date
        , p_action_information3          => fnd_date.date_to_canonical(ld_insured_end_date)                        -- Insured Period End Date
        , p_action_information4          => NULL                                                                   -- Wage Payment Base Days
        , p_action_information5          => fnd_date.date_to_canonical(ld_period_start_date)                       -- Pay Period Start Date
        , p_action_information6          => fnd_date.date_to_canonical(ld_period_end_date)                         -- Pay Period End Date
        , p_action_information7          => NULL                                                                   -- Base Days
        , p_action_information8          => NULL                                                                   -- Wage Amount A
        , p_action_information9          => NULL                                                                   -- Wage Amount B
        , p_action_information10         => NULL                                                                   -- Total Amount of Salary
        , p_action_information11         => NULL                                                                   -- Remarks
        , p_action_information12         => 'N'                                                                    -- Exclude Period
        , p_action_information13         => fnd_number.number_to_canonical(ln_line_number)                         -- Line Number
        );
       --
    CLOSE lcu_period_for_no_assact;
    --
    p_line_number := ln_line_number;
    --
    IF gb_debug THEN
         hr_utility.set_location('Leaving '||lc_procedure,1);
    END IF;
    --
 EXCEPTION
   --
   WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in '||lc_procedure,999999);
    END IF;
    RAISE;
   --
   WHEN OTHERS THEN
    RAISE  gc_exception;
    --
  END proc_insert_row;
  --
  PROCEDURE proc_sal_arch( p_assignment_action_id     IN pay_assignment_actions.assignment_action_id%TYPE
                          ,p_payroll_action_id        IN pay_payroll_actions.payroll_action_id%TYPE
                          ,p_assignment_id            IN per_all_assignments_f.assignment_id%TYPE
                          ,p_effective_date           IN pay_payroll_actions.effective_date%TYPE
                          ,p_termination_date         IN per_periods_of_service.actual_termination_date%TYPE
                          ,p_payroll_id               IN pay_payrolls_f.payroll_id%TYPE
                          ,p_hire_date                IN per_periods_of_service.date_start%TYPE
                          ,p_last_std_process_date    IN per_periods_of_service.last_standard_process_date%TYPE
                          ,p_ins_start_date           OUT NOCOPY per_time_periods.start_date%TYPE)
  --***************************************************************************
  -- PROCEDURE
  --   proc_sal_arch
  --
  -- DESCRIPTION
  --   This procedure is used to process salary archive
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  --==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  -- p_assignment_id            IN       This parameter passes Assignment Idter passes the Termination Date
  -- p_payroll_id               IN       This Parameter passes the Payroll Id
  -- p_hire_date                IN       This parameter passes the hire date
  -- p_last_std_process_date    IN       This parameter passes the last standard process date
  -- p_ins_start_date           OUT      Passes back   Insurance start date
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   archive_code
  --***********************************************************************
  IS
  --
  CURSOR lcu_assct
  IS
  SELECT  PAA.assignment_action_id,
          PPA.effective_date,
          PPA.date_earned,
          PTP.start_date,
          PTP.end_date,
          PAF.payroll_id,
          PAF.effective_start_date,
          PAF.effective_end_date
  FROM   pay_assignment_actions PAA
        ,pay_payroll_actions PPA
        ,per_time_periods PTP
        ,per_assignments_f PAF
  WHERE  PAA.assignment_id = p_assignment_id
  AND    PAF.assignment_id = PAA.assignment_id
  AND    PAA.action_status = 'C'
  AND    PPA.payroll_action_id = PAA.payroll_action_id
  AND    PPA.effective_date BETWEEN add_months(p_termination_date +1,gn_max_period * -1)
         AND PPA.effective_date
  AND    TRUNC(PTP.start_date) <= TRUNC(p_termination_date)
  AND    PPA.element_set_id = gn_sal_ele_set_id
  AND    PPA.action_type in ('R','Q','G','L')
  AND    NOT EXISTS(
                    SELECT  null
                    FROM   pay_action_interlocks PAI,
                           pay_assignment_actions PAAI,
                           pay_payroll_actions PPAI
                    WHERE  PAI.locked_action_id = PAA.assignment_action_id
                    AND    PAAI.assignment_action_id = PAI.locking_action_id
                    AND    PPAI.payroll_action_id = PAAI.payroll_action_id
                    AND    PPAI.action_type = 'V')
  AND   PTP.payroll_id = PPA.payroll_id
  AND   PPA.date_earned BETWEEN PTP.start_date AND PTP.end_date
  AND   PPA.date_earned BETWEEN PAF.effective_start_date AND PAF.effective_end_date
  ORDER BY  PAA.assignment_action_id DESC;
  --
  CURSOR lcu_assct_effective
  IS
  SELECT  PAA.assignment_action_id,
          PPA.effective_date,
          PPA.date_earned,
          PTP.start_date,
          PTP.end_date,
          PAF.payroll_id,
          PAF.effective_start_date,
          PAF.effective_end_date
  FROM   pay_assignment_actions PAA
        ,pay_payroll_actions PPA
        ,per_time_periods PTP
        ,per_assignments_f PAF
  WHERE  PAA.assignment_id = p_assignment_id
  AND    PAF.assignment_id = PAA.assignment_id
  AND    PAA.action_status = 'C'
  AND    PPA.payroll_action_id = PAA.payroll_action_id
  AND    PPA.effective_date BETWEEN add_months(p_termination_date +1,gn_max_period * -1)
         AND PPA.effective_date
  AND    TRUNC(PTP.start_date) <= TRUNC(p_termination_date)
  AND    PPA.element_set_id = gn_sal_ele_set_id
  AND    PPA.action_type in ('R','Q','G','L')
  AND    NOT EXISTS(
                    SELECT  null
                    FROM   pay_action_interlocks PAI,
                           pay_assignment_actions PAAI,
                           pay_payroll_actions PPAI
                    WHERE  PAI.locked_action_id = PAA.assignment_action_id
                    AND    PAAI.assignment_action_id = PAI.locking_action_id
                    AND    PPAI.payroll_action_id = PAAI.payroll_action_id
                    AND    PPAI.action_type = 'V')
  AND   PTP.payroll_id = PPA.payroll_id
  AND   PPA.effective_date BETWEEN PTP.start_date AND PTP.end_date
  AND   PPA.effective_date BETWEEN PAF.effective_start_date AND PAF.effective_end_date
  ORDER BY  PAA.assignment_action_id DESC; -- Bug 9693280
  --
  CURSOR lcu_period_for_no_assact
  IS
  SELECT   PTP.start_date,
           PTP.end_date
  FROM   per_time_periods PTP
  WHERE  PTP.payroll_id = p_payroll_id
  AND    PTP.start_date BETWEEN add_months(p_termination_date +1,gn_max_period * -1)
         AND    NVL(p_last_std_process_date,PTP.start_date)
  AND    PTP.start_date <=  p_termination_date
  ORDER BY  PTP.start_date DESC;
  --
  CURSOR lcu_get_bal_id(p_balance_name           pay_balance_types.balance_name%TYPE
                       ,p_database_item_suffix   pay_balance_dimensions.database_item_suffix%TYPE)
  IS
  SELECT PDB.defined_balance_id
        ,PBT.balance_type_id
  FROM   pay_balance_types      PBT
        ,pay_balance_dimensions PBD
        ,pay_defined_balances   PDB
  WHERE   PBT.balance_name         = p_balance_name
  AND     PBD.database_item_suffix = p_database_item_suffix
  AND     PBT.balance_type_id      = PDB.balance_type_id
  AND     PBD.balance_dimension_id = PDB.balance_dimension_id;
  --
  CURSOR lcu_balance_asg_run(p_assignment_action_id           pay_assignment_actions.assignment_action_id%TYPE
                            ,p_balance_type_id                pay_balance_types.balance_type_id%TYPE)
  IS
  SELECT 'Y'
  FROM  pay_assignment_actions  ASSACT,
            pay_payroll_actions PACT,
            pay_balance_feeds_f FEED,
            pay_run_results   RR,
            pay_run_result_values TARGET
  WHERE ASSACT.assignment_action_id = p_assignment_action_id
  AND   PACT.payroll_action_id = ASSACT.payroll_action_id
  AND   RR.assignment_action_id = ASSACT.assignment_action_id
  AND   RR.status in ('P','PA')
  AND   PACT.action_type in ('R','Q','G','L')
  AND   TARGET.run_result_id = RR.run_result_id
  AND   FEED.input_value_id = TARGET.input_value_id
  AND   FEED.balance_type_id = p_balance_type_id
  AND   PACT.effective_date BETWEEN FEED.effective_start_date AND FEED.effective_end_date;
  --
  CURSOR lcu_balance_asg_prev_run(p_balance_type_id                pay_balance_types.balance_type_id%TYPE
                                 ,p_date_earned                    pay_payroll_actions.date_earned%TYPE
                                  )
  IS
  SELECT ASSACT.assignment_action_id
  FROM      pay_assignment_actions  ASSACT,
            pay_payroll_actions PACT,
            pay_balance_feeds_f FEED,
            pay_run_results   RR,
            pay_run_result_values TARGET
  WHERE   PACT.payroll_action_id = ASSACT.payroll_action_id
  AND   RR.assignment_action_id = ASSACT.assignment_action_id
  AND   RR.status in ('P','PA')
  AND   PACT.action_type in ('R','Q','G','L')
  AND   TARGET.run_result_id = RR.run_result_id
  AND   FEED.input_value_id = TARGET.input_value_id
  AND   FEED.balance_type_id = p_balance_type_id
  AND   PACT.element_set_id  = gn_sal_ele_set_id
  AND   PACT.date_earned BETWEEN FEED.effective_start_date AND FEED.effective_end_date
  AND   PACT.date_earned BETWEEN (p_date_earned+1) AND add_months(p_date_earned,1)
  AND   ASSACT.assignment_id= p_assignment_id;  -- #Bug 9732572
  --
  TYPE t_assact_rec is record(
      assignment_action_id number,
      effective_date date,
      date_earned date,
      period_start_date date,
      period_end_date date,
      payroll_id      number,
      payroll_change_st_dt date,
      payroll_change_end_dt date
      );
  --
  TYPE t_assact_tbl IS TABLE OF t_assact_rec INDEX BY BINARY_INTEGER;
  --
  lt_assact_tbl                 t_assact_tbl;
  --
  lc_procedure                  VARCHAR2(200);
  lc_exclude_period             VARCHAR2(10)  DEFAULT 'N';
  lc_remarks                    VARCHAR2(60);
  i                             NUMBER := 0;
  j                             NUMBER;
  --
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  ln_line_number                NUMBER:=0;
  ln_diff_mth                   NUMBER;
  ln_assact_tbl_cnt             NUMBER := 0;
  ln_wage_pay_days              NUMBER;
  ln_base_days                  NUMBER;
  ln_wage_amount_a              NUMBER;
  ln_wage_amount_b              NUMBER;
  ln_total_wage                 NUMBER;
  ln_bpd_balance_id             pay_defined_balances.defined_balance_id%TYPE;
  ln_sal_a_bal_id               pay_defined_balances.defined_balance_id%TYPE;
  ln_sal_b_bal_id               pay_defined_balances.defined_balance_id%TYPE;
  ln_sal_a_prev_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  ln_sal_b_prev_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  ln_bpd_baltyp_id              pay_balance_types.balance_type_id%TYPE;
  ln_sal_a_baltyp_id            pay_balance_types.balance_type_id%TYPE;
  ln_sal_b_baltyp_id            pay_balance_types.balance_type_id%TYPE;
  ln_sal_a_prev_baltyp_id       pay_balance_types.balance_type_id%TYPE;
  ln_sal_b_prev_baltyp_id       pay_balance_types.balance_type_id%TYPE;
  ln_wage_dis_count             NUMBER:=0;                                                 -- Count excluding payment days less than 11 Days
  ln_line_count                 NUMBER;
  ln_assignment_action_id       pay_assignment_actions.assignment_action_id%TYPE;
  ln_prev_ass_a_act_id          pay_assignment_actions.assignment_action_id%TYPE;
  ln_prev_ass_b_act_id          pay_assignment_actions.assignment_action_id%TYPE;
  --
  ln_sal_action_id              pay_assignment_actions.assignment_action_id%TYPE;
  ld_effective_date             pay_payroll_actions.effective_date%TYPE;
  ld_date_earned                pay_payroll_actions.date_earned%TYPE;
  ld_period_start_date          per_time_periods.start_date%TYPE;
  ld_period_end_date            per_time_periods.end_date%TYPE;
  ld_insured_start_date         per_time_periods.start_date%TYPE;
  ld_insured_end_date           per_time_periods.end_date%TYPE;
  ld_prev_ins_end_date          per_time_periods.end_date%TYPE;
  lc_wage_a_flag                VARCHAR2(10)  DEFAULT 'N';
  lc_wage_b_flag                VARCHAR2(10)  DEFAULT 'N';
  lc_sal_a_bal_flag             VARCHAR2(1)   DEFAULT 'N';
  lc_sal_b_bal_flag             VARCHAR2(1)   DEFAULT 'N';
  --
  lt_insert_wage_info           gt_insert_wage_info;
  lt_insert_action_info         gt_insert_wage_info;
  --
  lr_lcu_period_for_no_assact   lcu_period_for_no_assact%rowtype;
  --
  BEGIN
    --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
     lc_procedure := gc_package||'proc_sal_arch';
     hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    -- Fetching balnce id for Wage Payment days
    --
    OPEN  lcu_get_bal_id(p_balance_name          => 'B_SAL_TRM_REPORT_WAGE_PAY_BASE_DAYS'
                        ,p_database_item_suffix  => '_ASG_RUN');
    FETCH lcu_get_bal_id INTO ln_bpd_balance_id
                             ,ln_bpd_baltyp_id;
    CLOSE lcu_get_bal_id;
    --
    -- Fetching balnce id for salary A
    --
    OPEN  lcu_get_bal_id(p_balance_name          => 'B_SAL_TRM_REPORT_WAGE_A'
                        ,p_database_item_suffix  => '_ASG_PTD');
    FETCH lcu_get_bal_id INTO ln_sal_a_bal_id
                             ,ln_sal_a_baltyp_id;
    CLOSE lcu_get_bal_id;
    --
    -- Fetching balnce id for salary B
    --
    OPEN  lcu_get_bal_id(p_balance_name          => 'B_SAL_TRM_REPORT_WAGE_B'
                        ,p_database_item_suffix  => '_ASG_PTD');
    FETCH lcu_get_bal_id INTO ln_sal_b_bal_id
                             ,ln_sal_b_baltyp_id;
    CLOSE lcu_get_bal_id;
     --
    -- Fetching balnce id for previous month salary A
    --
    OPEN  lcu_get_bal_id(p_balance_name          => 'B_SAL_TRM_REPORT_WAGE_A_PREV_MTH'
                        ,p_database_item_suffix  => '_ASG_PTD');
    FETCH lcu_get_bal_id INTO ln_sal_a_prev_bal_id
                             ,ln_sal_a_prev_baltyp_id;
    CLOSE lcu_get_bal_id;
    --
    -- Fetching balnce id for previous month salary B
    --
    OPEN  lcu_get_bal_id(p_balance_name          => 'B_SAL_TRM_REPORT_WAGE_B_PREV_MTH'
                        ,p_database_item_suffix  => '_ASG_PTD');
    FETCH lcu_get_bal_id INTO ln_sal_b_prev_bal_id
                             ,ln_sal_b_prev_baltyp_id;
    CLOSE lcu_get_bal_id;
    --
    lt_assact_tbl.DELETE;
    --
    IF (gc_santei_base  = gc_date_earned) THEN
      --
      OPEN lcu_assct;
      --
      LOOP
        --
        FETCH lcu_assct INTO lt_assact_tbl(ln_assact_tbl_cnt);
        EXIT  WHEN lcu_assct%NOTFOUND;
        --
       ln_assact_tbl_cnt := ln_assact_tbl_cnt + 1;
        --
      END LOOP;
      --
      CLOSE lcu_assct;
      --
    ELSE
      --
      OPEN lcu_assct_effective;
      --
      LOOP
        --
        FETCH lcu_assct_effective INTO lt_assact_tbl(ln_assact_tbl_cnt);
        EXIT  WHEN lcu_assct_effective%NOTFOUND;
        --
       ln_assact_tbl_cnt := ln_assact_tbl_cnt + 1;
        --
      END LOOP;
      --
      CLOSE lcu_assct_effective;
      --
    END IF;
    --
    IF lt_assact_tbl.COUNT > 0 THEN
    --
      <<assact_loop>>
      FOR assact_cnt IN lt_assact_tbl.FIRST..lt_assact_tbl.LAST LOOP
      --
      ln_line_number := ln_line_number + 1;
      --
      -- Fetch difference between Payperiod months and Termination date to calculate insurance period --
      --
      IF ln_line_number = 1 AND  TRUNC(p_termination_date) NOT BETWEEN lt_assact_tbl(assact_cnt).period_start_date AND lt_assact_tbl(assact_cnt).period_end_date  THEN
        --
        proc_insert_row(  p_assignment_action_id   => p_assignment_action_id
                          ,p_payroll_action_id     => p_payroll_action_id
                          ,p_assignment_id         => p_assignment_id
                          ,p_effective_date        => p_effective_date
                          ,p_termination_date      => p_termination_date
                          ,p_payroll_id            => p_payroll_id
                          ,p_hire_date             => p_hire_date
                          ,p_last_std_process_date => p_last_std_process_date
                          ,p_line_number           => ln_line_count);
       ln_line_number := ln_line_number + NVL(ln_line_count,0);
        --
      END IF;
      --
      -- Period Start Date and Period End date
      --
      IF TRUNC(p_hire_date) >  TRUNC(lt_assact_tbl(assact_cnt).period_start_date) THEN
         --
         ld_period_start_date := p_hire_date;
         --
       ELSE
         --
         IF assact_cnt < lt_assact_tbl.LAST THEN
           --
           IF (lt_assact_tbl(assact_cnt).payroll_id <> lt_assact_tbl(assact_cnt+1).payroll_id) THEN
             --
             IF lt_assact_tbl(assact_cnt).payroll_change_st_dt > lt_assact_tbl(assact_cnt).period_start_date THEN
               --
               ld_period_start_date := lt_assact_tbl(assact_cnt).payroll_change_st_dt;
               --
             ELSE
               --
               ld_period_start_date := lt_assact_tbl(assact_cnt).period_start_date;
               --
             END IF;
             --
           ELSE
             --
             ld_period_start_date := lt_assact_tbl(assact_cnt).period_start_date;
             --
           END IF;
           --
         ELSE
           --
           ld_period_start_date := lt_assact_tbl(assact_cnt).period_start_date;
           --
         END IF;
         --
      END IF;
      --
      IF TRUNC(p_termination_date) BETWEEN lt_assact_tbl(assact_cnt).period_start_date AND lt_assact_tbl(assact_cnt).period_end_date THEN
        --
        ld_period_end_date := TRUNC(p_termination_date);
        --
      ELSE
        --
        IF  assact_cnt > lt_assact_tbl.FIRST THEN
          --
          IF (lt_assact_tbl(assact_cnt).payroll_id <> lt_assact_tbl(assact_cnt-1).payroll_id) THEN
             --
             IF lt_assact_tbl(assact_cnt).payroll_change_end_dt < lt_assact_tbl(assact_cnt).period_end_date THEN
               --
               ld_period_end_date := lt_assact_tbl(assact_cnt).payroll_change_end_dt;
               --
             ELSE
               --
               ld_period_end_date := lt_assact_tbl(assact_cnt).period_end_date;
               --
             END IF;
            --
          ELSE
            --
            ld_period_end_date := lt_assact_tbl(assact_cnt).period_end_date;
            --
          END IF;
          --
        ELSE
          --
          ld_period_end_date := lt_assact_tbl(assact_cnt).period_end_date;
          --
       END IF;
        --
      END IF;
      --
      -- Checking Maximum period of 4 years or no of display periods greater than Santei base period
      --
      EXIT WHEN ((TRUNC(MONTHS_BETWEEN(p_termination_date,ld_period_start_date)/12)>=4 ));
      --
      ln_assignment_action_id :=  lt_assact_tbl(assact_cnt).assignment_action_id;
      ln_base_days  := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_WAGE_PAY_INFO','PAY_PERIOD_BASE_DAYS',p_assignment_id,lt_assact_tbl(assact_cnt).date_earned);
      --
      IF ln_base_days  IS NULL THEN
         --
         IF ln_assignment_action_id IS NOT NULL THEN   --Bug 9693280
           --
          ln_base_days := pay_jp_balance_pkg.get_balance_value(ln_bpd_balance_id,ln_assignment_action_id);
          --
         END IF;
         --
         IF ( NVL(ln_base_days,0) = 0)THEN                     -- #Bug No 9652251
           --
           ln_base_days  := ROUND(ld_period_end_date - ld_period_start_date)+1;  -- #Bug No 9648082
           --
         END IF;
         --
      END IF;
      --
      -- Insured Days
      --
      ln_diff_mth := (TO_NUMBER(TO_CHAR(ld_period_start_date,'YYYY'))
                       - TO_NUMBER(TO_CHAR(p_termination_date,'YYYY'))) * 12
                      + (TO_NUMBER(TO_CHAR(ld_period_start_date,'MM'))
                         - TO_NUMBER(TO_CHAR(p_termination_date,'MM')));  --#Bug 9653516
      --
      hr_utility.set_location('ln_diff_mth = '||ln_diff_mth,20);
      --
      -- Wage Payment Days --
      --
      IF TO_CHAR(ld_period_start_date,'MM') =  TO_CHAR(ld_period_end_date,'MM') THEN
         --
         ld_insured_start_date := add_months(p_termination_date + 1,ln_diff_mth -1);    --#Bug 9653516
         ld_insured_end_date   := add_months(ld_insured_start_date,1) - 1;  --#Bug 9653516
         --
      ELSE
        --
        IF TO_CHAR(ld_period_start_date,'YYYY') =  TO_CHAR(ld_period_end_date,'YYYY') THEN  --#Bug 9732294
          --
          ld_insured_start_date := add_months(p_termination_date + 1,ln_diff_mth);    --#Bug 9702153
          ld_insured_end_date   := add_months(ld_insured_start_date,1) - 1;  --#Bug 9702153
          --
        ELSE
          --
          ld_insured_start_date := add_months(p_termination_date + 1,ln_diff_mth -1);    --#Bug 9732294
          ld_insured_end_date   := add_months(ld_insured_start_date,1) - 1;  --#Bug 9732294
          --
        END IF;
      END IF;
      --
      ln_wage_pay_days := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_WAGE_PAY_INFO','EE_PERIOD_BASE_DAYS',p_assignment_id,ld_insured_end_date);
      --
      -- Fecthing Start and End insured/pay periods
      --
      IF TRUNC(p_hire_date) >  TRUNC(ld_insured_start_date) THEN
         --
         ld_insured_start_date  := p_hire_date;
         --
      END IF;
      --
      IF TRUNC(p_hire_date) >  TRUNC(ld_insured_end_date) THEN
        --
        ld_insured_end_date:= p_hire_date;
        --
      END IF;

      --
      IF ln_wage_pay_days IS NULL THEN
         --
         IF ( TRUNC(ld_insured_start_date) = TRUNC(ld_period_start_date) AND
               TRUNC(ld_insured_end_date) = TRUNC(ld_period_end_date)) THEN                            --#Bug 9652235
             --
             ln_wage_pay_days:= ln_base_days;  --#Bug 9648082
             --
          ELSE
             --
             ln_wage_pay_days := ROUND(ld_insured_end_date - ld_insured_start_date)+1; -- #Bug No 9648082
             --
          END IF;
      --
      END IF;
      --
      -- checking payrun results for balance B_SAL_TRM_REPORT_WAGE_A
      --
      IF ln_assignment_action_id IS NOT NULL THEN   --Bug 9693280
      --
      OPEN  lcu_balance_asg_run(p_assignment_action_id => ln_assignment_action_id
                               ,p_balance_type_id      => ln_sal_a_baltyp_id);
      FETCH lcu_balance_asg_run INTO lc_sal_a_bal_flag ;
      CLOSE lcu_balance_asg_run;
      --
      -- checking payrun results for balance B_SAL_TRM_REPORT_WAGE_B
      --
      OPEN  lcu_balance_asg_run(p_assignment_action_id => ln_assignment_action_id
                               ,p_balance_type_id      => ln_sal_b_baltyp_id);
      FETCH lcu_balance_asg_run INTO lc_sal_b_bal_flag ;
      CLOSE lcu_balance_asg_run;
      --
      -- checking payrun results for balance B_SAL_TRM_REPORT_WAGE_A_PREV_MTH
      --
      OPEN  lcu_balance_asg_prev_run(p_balance_type_id      => ln_sal_a_prev_baltyp_id
                                    ,p_date_earned          => lt_assact_tbl(assact_cnt).date_earned
                                     );
      FETCH lcu_balance_asg_prev_run INTO ln_prev_ass_a_act_id;
      CLOSE lcu_balance_asg_prev_run;
      --
      -- checking payrun results for balance B_SAL_TRM_REPORT_WAGE_B_PREV_MTH
      --
      OPEN  lcu_balance_asg_prev_run(p_balance_type_id      => ln_sal_b_prev_baltyp_id
                                    ,p_date_earned          => lt_assact_tbl(assact_cnt).date_earned
                                    );
      FETCH lcu_balance_asg_prev_run INTO ln_prev_ass_b_act_id;
      CLOSE lcu_balance_asg_prev_run;
      --
      -- Derving Wage Amount A
      --
      ln_wage_amount_a :=  pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_WAGE_PAY_INFO','WAGE_A',p_assignment_id,lt_assact_tbl(assact_cnt).date_earned);
      --
      IF ln_wage_amount_a IS NULL THEN
         --
         IF lc_sal_a_bal_flag = 'Y' THEN
              --
              IF ln_prev_ass_a_act_id IS NOT NULL  THEN
                 --
                 ln_wage_amount_a := pay_jp_balance_pkg.get_balance_value(ln_sal_a_bal_id,ln_assignment_action_id)
                             + pay_jp_balance_pkg.get_balance_value(ln_sal_a_prev_bal_id,ln_prev_ass_a_act_id);
              ELSE
                 --
                 ln_wage_amount_a := pay_jp_balance_pkg.get_balance_value(ln_sal_a_bal_id,ln_assignment_action_id);
                 --
              END IF;
              --
          ELSE
              --
              IF ln_prev_ass_a_act_id IS NOT NULL  THEN
                 --
                 ln_wage_amount_a := pay_jp_balance_pkg.get_balance_value(ln_sal_a_prev_bal_id,ln_prev_ass_a_act_id);
                 --
              END IF;
              --
            END IF;
           --
         --
      END IF;
      -- Derving Wage Amount B
      --
      ln_wage_amount_b :=  pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_WAGE_PAY_INFO','WAGE_B',p_assignment_id,lt_assact_tbl(assact_cnt).date_earned);
      --
     IF ln_wage_amount_b IS NULL THEN
         --
            IF lc_sal_b_bal_flag = 'Y' THEN
              --
              IF ln_prev_ass_b_act_id IS NOT NULL THEN
                --
                ln_wage_amount_b := pay_jp_balance_pkg.get_balance_value(ln_sal_b_bal_id,ln_assignment_action_id)
                               + pay_jp_balance_pkg.get_balance_value(ln_sal_b_prev_bal_id,ln_prev_ass_b_act_id );
                --
              ELSE
                --
                ln_wage_amount_b := pay_jp_balance_pkg.get_balance_value(ln_sal_b_bal_id,ln_assignment_action_id);
                --
              END IF;
              --
            ELSE
              --
              IF ln_prev_ass_b_act_id IS NOT NULL THEN
                 --
                 ln_wage_amount_b := pay_jp_balance_pkg.get_balance_value(ln_sal_b_prev_bal_id,ln_prev_ass_b_act_id );
                 --
              END IF;
              --
            END IF;
          --
      END IF;
      --
      END IF;  --Bug 9693280
      --
      IF gb_debug THEN
         hr_utility.set_location('ln_wage_amount_a =  '||ln_wage_amount_a,11);
         hr_utility.set_location('ln_wage_amount_b =  '||ln_wage_amount_b,12);
         hr_utility.set_location('ln_assignment_action_id =  '||ln_assignment_action_id,13);
      END IF;
      --
      IF (ln_wage_amount_a IS NOT NULL) THEN         -- #Bug9692693
         --
         lc_wage_a_flag := 'Y';
         --
      END IF;
      --
      IF (ln_wage_amount_b IS NOT NULL) THEN        -- #Bug9692693
         --
         lc_wage_b_flag := 'Y';
         --
      END IF;
      --
      lc_exclude_period :=  pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_WAGE_PAY_INFO','EXCLUDE_PERIOD',p_assignment_id,lt_assact_tbl(assact_cnt).date_earned);
      lc_remarks        :=  pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_WAGE_PAY_INFO','RMKS',p_assignment_id,lt_assact_tbl(assact_cnt).date_earned);
      --
      IF gb_debug THEN
        hr_utility.set_location('Payment Date '||lt_assact_tbl(assact_cnt).effective_date,11);
        hr_utility.set_location('Insured Period Start Date '||ld_insured_start_date,12);
        hr_utility.set_location('Insured Period End Date '||ld_insured_end_date,13);
        hr_utility.set_location('Insured Period Base Days '||ln_wage_pay_days,14);
        hr_utility.set_location('Pay Period Start Date '||ld_period_start_date,15);
        hr_utility.set_location('Pay Period End Date '||ld_period_end_date,16);
        hr_utility.set_location('Pay Period Base Days '||ln_base_days,17);
        hr_utility.set_location('Wage Amount A '||ln_wage_amount_a,18);
        hr_utility.set_location('Wage Amount B '||ln_wage_amount_b,19);
        hr_utility.set_location('Wage Amount Total '||ln_total_wage,20);
        hr_utility.set_location('Remarks '||lc_remarks,21);
        hr_utility.set_location('Exclude Period '||lc_exclude_period,22);
        hr_utility.set_location('ln_line_number '||ln_line_number ,23);
      END IF;
      --

        lt_insert_wage_info(i).payment_date         := lt_assact_tbl(assact_cnt).effective_date;            -- Payment Date
        lt_insert_wage_info(i).insured_start_date   := ld_insured_start_date;                               -- Insured Period Start Date
        lt_insert_wage_info(i).insured_end_date     := ld_insured_end_date;                                 -- Insured Period End Date
        lt_insert_wage_info(i).insured_days         := ln_wage_pay_days;                                    -- Insured Period Base Days
        lt_insert_wage_info(i).period_start_date    := ld_period_start_date;                                -- Pay Period Start Date
        lt_insert_wage_info(i).period_end_date      := ld_period_end_date;                                  -- Pay Period End Date
        lt_insert_wage_info(i).base_days            := ln_base_days;                                        -- Pay Period Base Days
        lt_insert_wage_info(i).wage_amount_a        := ln_wage_amount_a;                                    -- Wage Amount A
        lt_insert_wage_info(i).wage_amount_b        := ln_wage_amount_b;                                    -- Wage Amount B
        lt_insert_wage_info(i).remarks              := lc_remarks;                                          -- Remarks
        lt_insert_wage_info(i).exclude_period       := NVL(lc_exclude_period,'N');                          -- Exclude Period
        lt_insert_wage_info(i).line_number          := ln_line_number;                                      -- Line Number
        --
        -- initialize local arguments
        i := i+1;
        lc_sal_a_bal_flag   := 'N';
        lc_sal_b_bal_flag   := 'N';
        ln_prev_ass_a_act_id := NULL;
        ln_prev_ass_a_act_id := NULL;
        ln_wage_amount_a := NULL;
        ln_wage_amount_b := NULL;
        ln_assignment_action_id := NULL;
        --
        END LOOP;
        --
        --  Inserting into Pay action Information
        -- #Bug9692693 Start
        --
        lt_insert_action_info := get_insert_action_info(p_insert_wage_info => lt_insert_wage_info);
        j := lt_insert_action_info.first;
        --
        WHILE  j IS NOT NULL LOOP
        IF gb_debug THEN
           --
           hr_utility.set_location('Inserting Data into Pay action Information ',30);
           --
        END IF;
        --
        -- Summing total if wage_amount_a and wage_amount_b not null during any month
        --
        IF (lc_wage_a_flag = 'Y' AND lc_wage_b_flag = 'Y') THEN
          --
          IF (lt_insert_action_info(j).wage_amount_a IS NOT NULL OR lt_insert_action_info(j).wage_amount_b IS NOT NULL) THEN
            --
            ln_total_wage := NVL(lt_insert_action_info(j).wage_amount_a,0) + NVL(lt_insert_action_info(j).wage_amount_b,0);
            --
          END IF;
          --
        END IF;
        --
        pay_action_information_api.create_action_information
        ( p_action_information_id        => ln_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => ln_obj_version_num
        , p_effective_date               => p_effective_date
        , p_assignment_id                => p_assignment_id
        , p_source_id                    => NULL
        , p_source_text                  => NULL
        , p_action_information_category  => 'JP_UITE_SAL'
        , p_action_information1          => fnd_date.date_to_canonical(lt_insert_action_info(j).payment_date)           -- Payment Date
        , p_action_information2          => fnd_date.date_to_canonical(lt_insert_action_info(j).insured_start_date)     -- Insured Period Start Date
        , p_action_information3          => fnd_date.date_to_canonical(lt_insert_action_info(j).insured_end_date)       -- Insured Period End Date
        , p_action_information4          => fnd_number.number_to_canonical(lt_insert_action_info(j).insured_days)       -- Insured Period Base Days
        , p_action_information5          => fnd_date.date_to_canonical(lt_insert_action_info(j).period_start_date)      -- Pay Period Start Date
        , p_action_information6          => fnd_date.date_to_canonical(lt_insert_action_info(j).period_end_date)        -- Pay Period End Date
        , p_action_information7          => fnd_number.number_to_canonical(lt_insert_action_info(j).base_days)          -- Pay Period Base Days
        , p_action_information8          => fnd_number.number_to_canonical(lt_insert_action_info(j).wage_amount_a)      -- Wage Amount A
        , p_action_information9          => fnd_number.number_to_canonical(lt_insert_action_info(j).wage_amount_b)      -- Wage Amount B
        , p_action_information10         => fnd_number.number_to_canonical(ln_total_wage)                             -- Wage Amount Total
        , p_action_information11         => lt_insert_action_info(j).remarks                                            -- Remarks
        , p_action_information12         => lt_insert_action_info(j).exclude_period                                     -- Exclude Period
        , p_action_information13         => fnd_number.number_to_canonical(lt_insert_action_info(j).line_number)        -- Line Number
        );
         --
         j := lt_insert_action_info.next(j);
         ln_action_info_id  := NULL;
         ln_obj_version_num := NULL;
         ln_total_wage      := NULL;
        --
        END LOOP;

        -- #Bug9692693 End
       ELSE
         --
         -- show first line even if there is no payroll action for the employee
         --
         OPEN lcu_period_for_no_assact;
         --
         LOOP
         --
         FETCH lcu_period_for_no_assact INTO lr_lcu_period_for_no_assact;
         EXIT  WHEN (lcu_period_for_no_assact%NOTFOUND OR ln_line_number >=gn_output_period OR p_hire_date > lr_lcu_period_for_no_assact.start_date);
         --
         ln_line_number := ln_line_number + 1;
         --
         --
         ln_diff_mth := (TO_NUMBER(TO_CHAR(lr_lcu_period_for_no_assact.start_date,'YYYY'))
                       - TO_NUMBER(TO_CHAR(p_termination_date,'YYYY'))) * 12
                      + (TO_NUMBER(TO_CHAR(lr_lcu_period_for_no_assact.start_date,'MM'))
                         - TO_NUMBER(TO_CHAR(p_termination_date,'MM')));                   --#Bug 9653516

         --
         -- Wage Payment Days --
         --
         IF TO_CHAR(lr_lcu_period_for_no_assact.start_date,'MM') =  TO_CHAR(lr_lcu_period_for_no_assact.end_date,'MM') THEN
           --
           ld_insured_start_date := add_months(p_termination_date + 1,ln_diff_mth -1);    --#Bug 9653516
           ld_insured_end_date   := add_months(ld_insured_start_date,1) - 1;          --#Bug 9653516
           --
         ELSE
           --
           IF TO_CHAR(lr_lcu_period_for_no_assact.start_date,'YYYY') =  TO_CHAR(lr_lcu_period_for_no_assact.end_date,'YYYY') THEN  --#Bug 9732294
             --
             ld_insured_start_date := add_months(p_termination_date + 1,ln_diff_mth);    --#Bug 9702153
             ld_insured_end_date   := add_months(ld_insured_start_date,1) - 1;  --#Bug 9702153
             --
          ELSE
            --
            ld_insured_start_date := add_months(p_termination_date + 1,ln_diff_mth -1);    --#Bug 9732294
            ld_insured_end_date   := add_months(ld_insured_start_date,1) - 1;  --#Bug 9732294
          --
        END IF;

           --
         END IF;
         --
         IF TRUNC(p_hire_date) >  TRUNC(ld_insured_start_date) THEN
         --
          ld_insured_start_date  := p_hire_date;
         --
        END IF;
        --
        IF TRUNC(p_hire_date) >  TRUNC( ld_insured_end_date) THEN
          --
          ld_insured_end_date:= p_hire_date;
          --
        END IF;
         --
         IF TRUNC(p_hire_date) >  TRUNC(lr_lcu_period_for_no_assact.start_date) THEN
           --
           ld_period_start_date := p_hire_date;
           --
         ELSE
           --
           ld_period_start_date := lr_lcu_period_for_no_assact.start_date;
           --
         END IF;
         --
         IF TRUNC(p_termination_date) BETWEEN lr_lcu_period_for_no_assact.start_date AND lr_lcu_period_for_no_assact.end_date THEN
           --
          ld_period_end_date := TRUNC(p_termination_date);
           --
         ELSE
           --
           ld_period_end_date := lr_lcu_period_for_no_assact.end_date;
           --
         END IF;
         --
         IF gb_debug THEN
            --
           hr_utility.set_location('ln_diff_mth '||lc_procedure,20);
           hr_utility.set_location('Insured Period Start Date '||ld_insured_start_date,12);
           hr_utility.set_location('Insured Period End Date '||ld_insured_end_date,13);
           hr_utility.set_location('Pay Period Start Date '||ld_period_start_date,15);
           hr_utility.set_location('Pay Period End Date '||ld_period_end_date,16);
           hr_utility.set_location('Remarks '||lc_remarks,21);
           hr_utility.set_location('Exclude Period '||lc_exclude_period,22);
           hr_utility.set_location('ln_line_number '||ln_line_number ,23);
         END IF;
         --
       pay_action_information_api.create_action_information
        (p_action_information_id         => ln_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => ln_obj_version_num
        , p_effective_date               => p_effective_date
        , p_assignment_id                => p_assignment_id
        , p_source_id                    => NULL
        , p_source_text                  => NULL
        , p_action_information_category  => 'JP_UITE_SAL'
        , p_action_information1          => fnd_date.date_to_canonical(ld_period_end_date)                         -- Payment Date
        , p_action_information2          => fnd_date.date_to_canonical(ld_insured_start_date)                      -- Insured Period Start Date
        , p_action_information3          => fnd_date.date_to_canonical(ld_insured_end_date)                        -- Insured Period End Date
        , p_action_information4          => NULL                                                                   -- Wage Payment Base Days
        , p_action_information5          => fnd_date.date_to_canonical(ld_period_start_date)                       -- Pay Period Start Date
        , p_action_information6          => fnd_date.date_to_canonical(ld_period_end_date)                         -- Pay Period End Date
        , p_action_information7          => NULL                                                                   -- Base Days
        , p_action_information8          => NULL                                                                   -- Wage Amount A
        , p_action_information9          => NULL                                                                   -- Wage Amount B
        , p_action_information10         => NULL                                                                   -- Total Amount of Salary
        , p_action_information11         => lc_remarks                                                             -- Remarks
        , p_action_information12         => NVL(lc_exclude_period,'N')                                             -- Exclude Period
        , p_action_information13         => fnd_number.number_to_canonical(ln_line_number)                         -- Line Number
        );
        --
        END LOOP;
        CLOSE lcu_period_for_no_assact;
        --
        p_ins_start_date := ld_insured_start_date;
         --
       END IF;
       --
      IF gb_debug THEN
         hr_utility.set_location('Leaving '||lc_procedure,1);
      END IF;
    --
 EXCEPTION
   --
   WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in '||lc_procedure,999999);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    RAISE  gc_exception;
    --
  END proc_sal_arch;
  --

  PROCEDURE proc_spb_arch(p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE
                         ,p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
                         ,p_effective_date       IN pay_payroll_actions.effective_date%TYPE
                         ,p_period_start_date    IN per_time_periods.start_date%TYPE
                         ,p_period_end_date      IN per_time_periods.end_date%TYPE
                         ,p_payroll_id           IN NUMBER)
  --***************************************************************************
  -- PROCEDURE
  --   proc_spb_arch
  --
  -- DESCRIPTION
  --   This procedure is used to process special bonus archive
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  --==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  -- p_assignment_id            IN       This parameter passes Assignment Id
  -- p_effective_date           IN       This Parameter Passes Effective Date
  -- p_termination_date         IN       This Paramter  Passes the Termination Date
  -- p_payroll_id               IN       This Paramter  Passes the Payroll Id
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --***********************************************************************
  IS
  --
  TYPE t_spb_assact_rec is record(
      assignment_action_id number,
      effective_date date,
      date_earned date);
  --
  TYPE t_spb_assact_tbl IS TABLE OF t_spb_assact_rec INDEX BY BINARY_INTEGER;
  --
  CURSOR  lcu_spb_assact
  IS
  SELECT   paa.assignment_action_id,
           ppa.effective_date,
           ppa.date_earned
  FROM     pay_assignment_actions paa,
           pay_payroll_actions ppa
  WHERE    paa.assignment_id = p_assignment_id
  AND      paa.action_status = 'C'
  AND      ppa.payroll_action_id = paa.payroll_action_id
  AND      ppa.effective_date
           BETWEEN p_period_start_date and p_period_end_date
  AND      ppa.element_set_id = gn_spb_ele_set_id
  AND      ppa.action_type in ('R','Q','G','L')
  AND      NOT EXISTS(
             SELECT null
             FROM  pay_action_interlocks pai,
                    pay_assignment_actions paa2,
                    pay_payroll_actions ppa2
             WHERE  pai.locked_action_id = paa.assignment_action_id
             AND    paa2.assignment_action_id = pai.locking_action_id
             AND    ppa2.payroll_action_id = paa2.payroll_action_id
             AND    ppa2.action_type = 'V')
  ORDER BY   paa.action_sequence;
  --
  CURSOR lcu_get_bal_id(p_balance_name           pay_balance_types.balance_name%TYPE
                       ,p_database_item_suffix   pay_balance_dimensions.database_item_suffix%TYPE)
  IS
  SELECT PDB.defined_balance_id
  FROM   pay_balance_types      PBT
        ,pay_balance_dimensions PBD
        ,pay_defined_balances   PDB
  WHERE   PBT.balance_name         = p_balance_name
  AND     PBD.database_item_suffix = p_database_item_suffix
  AND     PBT.balance_type_id      = PDB.balance_type_id
  AND     PBD.balance_dimension_id = PDB.balance_dimension_id;
  --
  lc_procedure                  VARCHAR2(200);
  --
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  ln_spb_earnings               NUMBER;
  ln_spb_bal_id                 pay_defined_balances.defined_balance_id%TYPE;
  ln_spb_assact_tbl_cnt         NUMBER := 0;
  --
  lt_spb_assact_tbl             t_spb_assact_tbl;
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
     lc_procedure := gc_package||'proc_spb_arch';
     hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    lt_spb_assact_tbl.delete;
    --
    -- Fetching balnce id for salary A
    --
    OPEN  lcu_get_bal_id(p_balance_name          => 'B_SPB_ERN_SUBJ_EI'
                        ,p_database_item_suffix  => '_ASG_RUN');
    FETCH lcu_get_bal_id INTO ln_spb_bal_id;
    CLOSE lcu_get_bal_id;
    --
    -- opening cursor to fetch details into table type
    --
    OPEN lcu_spb_assact;
    --
    LOOP
    --
      FETCH lcu_spb_assact  INTO lt_spb_assact_tbl(ln_spb_assact_tbl_cnt);
      EXIT WHEN lcu_spb_assact%NOTFOUND;
    --
      ln_spb_assact_tbl_cnt := ln_spb_assact_tbl_cnt + 1;
    --
    END LOOP;
    CLOSE lcu_spb_assact;
    --
    IF lt_spb_assact_tbl.count > 0 THEN
    --
      <<spb_assact_loop>>
      FOR spb_assact_cnt in lt_spb_assact_tbl.first..lt_spb_assact_tbl.last LOOP
      --
      ln_spb_earnings := pay_jp_balance_pkg.get_balance_value(ln_spb_bal_id,lt_spb_assact_tbl(spb_assact_cnt).assignment_action_id);
       --
       --
         pay_action_information_api.create_action_information
        ( p_action_information_id        => ln_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => ln_obj_version_num
        , p_effective_date               => p_effective_date
        , p_assignment_id                => p_assignment_id
        , p_source_id                    => NULL
        , p_source_text                  => NULL
        , p_action_information_category  => 'JP_UITE_SPB'
        , p_action_information1          => fnd_number.number_to_canonical(lt_spb_assact_tbl(spb_assact_cnt).assignment_action_id)            -- Assignment Action ID
        , p_action_information2          => fnd_date.date_to_canonical(lt_spb_assact_tbl(spb_assact_cnt).effective_date)                      -- Effective Date
        , p_action_information3          => fnd_number.number_to_canonical(ln_spb_earnings)                                                   -- Total Earnings Subject to EI
         );
       --
      END LOOP;
    --
    END IF;
    --
    IF gb_debug THEN
     hr_utility.set_location('leaving '||lc_procedure,1);
    END IF;

  --
  END proc_spb_arch;
  --
  PROCEDURE proc_term_arch( p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE
                          ,p_payroll_action_id    IN pay_payroll_actions.payroll_action_id%TYPE
                          ,p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
                          ,p_effective_date       IN pay_payroll_actions.effective_date%TYPE
                          ,p_termination_date     IN per_periods_of_service.actual_termination_date%TYPE
                          )
  --***************************************************************************
  -- PROCEDURE
  --   proc_sal_arch
  --
  -- DESCRIPTION
  --   This procedure is used to process salary archive
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  --==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  -- p_assignment_id            IN       This parameter passes Assignment Id
  -- p_effective_date           IN       This Parameter Passes Effective Date
  -- p_termination_date         IN       This Paramter  Passes the Termination Date
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --***********************************************************************
  IS
  --
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  ln_term_action_info_id        pay_action_information.action_information_id%TYPE;
  ln_term_obj_version_num       pay_action_information.object_version_number%TYPE;
  --
  lc_wage_note                  pay_action_information.action_information1%TYPE;
  lc_wage_note2                 pay_action_information.action_information1%TYPE;
  lc_wage_note3                 pay_action_information.action_information1%TYPE;
  lc_wage_note4                 pay_action_information.action_information2%TYPE;
  lc_wage_note5                 pay_action_information.action_information2%TYPE;
  lc_wage_instr1                pay_action_information.action_information1%TYPE;
  lc_wage_instr2                pay_action_information.action_information2%TYPE;
  lc_term_reason                pay_action_information.action_information1%TYPE;
  lc_reason_detail              pay_action_information.action_information2%TYPE;
  lc_reason_detail2             pay_action_information.action_information2%TYPE;
  lc_reason_detail3             pay_action_information.action_information2%TYPE;
  lc_reason_detail4             pay_action_information.action_information3%TYPE;
  lc_reason_detail5             pay_action_information.action_information3%TYPE;
  lc_concrete_cir1              pay_action_information.action_information2%TYPE;
  lc_concrete_cir2              pay_action_information.action_information3%TYPE;
  --
  lc_procedure                  VARCHAR2(200);
  --
  BEGIN
    --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
     lc_procedure := gc_package||'proc_term_arch';
     hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    --
    --Wage Instructions
    --
    lc_wage_note  := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_INFO','WAGE_SP_DESC',p_assignment_id,p_termination_date);
    lc_wage_note2 := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_INFO','WAGE_SP_DESC2',p_assignment_id,p_termination_date);
    lc_wage_note3 := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_INFO','WAGE_SP_DESC3',p_assignment_id,p_termination_date);
    lc_wage_note4 := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_INFO','WAGE_SP_DESC4',p_assignment_id,p_termination_date);
    lc_wage_note5 := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_INFO','WAGE_SP_DESC5',p_assignment_id,p_termination_date);
    --
    lc_wage_instr1 := lc_wage_note || lc_wage_note2 ||lc_wage_note3;
    --
    lc_wage_instr2 := lc_wage_note4 ||lc_wage_note5;
    --
    -- Termination Details
    --
    lc_term_reason    := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_REASON_INFO','TRM_REASON',p_assignment_id,p_termination_date);
    lc_reason_detail  := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_REASON_INFO','DETAIL',p_assignment_id,p_termination_date);
    lc_reason_detail2 := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_REASON_INFO','DETAIL2',p_assignment_id,p_termination_date);
    lc_reason_detail3 := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_REASON_INFO','DETAIL3',p_assignment_id,p_termination_date);
    lc_reason_detail4 := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_REASON_INFO','DETAIL4',p_assignment_id,p_termination_date);
    lc_reason_detail5 := pay_jp_balance_pkg.get_entry_value_char('COM_TRM_REPORT_REASON_INFO','DETAIL5',p_assignment_id,p_termination_date);
    --
    lc_concrete_cir1 := lc_reason_detail||lc_reason_detail2||lc_reason_detail3;
    lc_concrete_cir2 := lc_reason_detail4||lc_reason_detail5;
    --
    --
    --WAGE NOTE DETAILS ------------
    --
       pay_action_information_api.create_action_information
        ( p_action_information_id        => ln_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => ln_obj_version_num
        , p_effective_date               => p_effective_date
        , p_assignment_id                => p_assignment_id
        , p_source_id                    => NULL
        , p_source_text                  => NULL
        , p_action_information_category  => 'JP_UITE_INSTR'
        , p_action_information1          =>  lc_wage_instr1    -- Wage Special Instruction 1
        , p_action_information2          =>  lc_wage_instr2    -- Wage Special Instruction 2
         );
     --
     --TERMINATION DETAILS ------------
     --
       pay_action_information_api.create_action_information
        ( p_action_information_id        => ln_term_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => ln_term_obj_version_num
        , p_effective_date               => p_effective_date
        , p_assignment_id                => p_assignment_id
        , p_source_id                    => NULL
        , p_source_text                  => NULL
        , p_action_information_category  => 'JP_UITE_TERM'
        , p_action_information1          => lc_term_reason     -- Separation Reason
        , p_action_information2          => lc_concrete_cir1   -- Concrete Circumstance
        , p_action_information3          => lc_concrete_cir2  -- Concrete Circumstance 2
        );
       --
    IF gb_debug THEN
       --
       hr_utility.set_location('Leaving '||lc_procedure,1);
       --
    END IF;
    --
 EXCEPTION
   WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in '||lc_procedure,999999);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    RAISE  gc_exception;
    --
  END proc_term_arch;
  --
  PROCEDURE RANGE_CODE ( p_payroll_action_id  IN         pay_payroll_actions.payroll_action_id%TYPE
                        ,p_sql                OUT        NOCOPY VARCHAR2
                       )
  --***************************************************************************
  -- PROCEDURE
  --   RANGE_CODE
  --
  -- DESCRIPTION
  --   This procedure returns a sql string to select a range
  --  of assignments eligible for archival
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id         IN      This parameter passes Payroll Action Id.
  -- p_sql                       OUT     This parameter retunrs SQL Query.
  --
  -- PREREQUISITES
  --  None
  --
  -- CALLED BY
  --  None
  --*************************************************************************
  IS

  lc_procedure                VARCHAR2(200);

  BEGIN
    --
    gb_debug := hr_utility.debug_enabled;
    --
    IF gb_debug THEN
     lc_procedure := gc_package||'RANGE_CODE';
     hr_utility.set_location('Entering '||lc_procedure,1);
    END IF ;
    -------------------------------------------------------------------------
    -- sql string to SELECT a range of assignments eligible for archival.
    -------------------------------------------------------------------------
    p_sql := ' SELECT distinct p.person_id'                             ||
             ' FROM   per_people_f p,'                                  ||
                    ' pay_payroll_actions pa'                           ||
             ' WHERE  pa.payroll_action_id = :payroll_action_id'        ||
             ' AND    p.business_group_id = pa.business_group_id'       ||
             ' ORDER BY p.person_id';
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
    IF gb_debug THEN
      hr_utility.set_location(lc_procedure,10);
    END IF;
    --
  END RANGE_CODE;
  --
  PROCEDURE initialize ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE )
  --*************************************************************************
  -- PROCEDURE
  --   initialize
  --
  -- DESCRIPTION
  --   This procedure is used to set global contexts
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  INITIALIZATION_CODE
  --*************************************************************************
  IS
  --
  CURSOR lcr_params(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
  --*************************************************************************
  --
  -- CURSOR lcr_params
  --
  -- DESCRIPTION
  --  Fetches User Parameters from legislative_paramters column.
  --
  -- PARAMETERS
  -- ==========
  -- NAME                TYPE     DESCRIPTION
  -------------------   -------- ---------------------------------------------
  -- p_payroll_action_id IN       This parameter passes the Payroll Action Id.
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   initialize procedure
  --
  --**********************************************************************
  IS
  SELECT pay_core_utils.get_parameter('BG',legislative_parameters)
        ,pay_core_utils.get_parameter('ASSETID',legislative_parameters)
        ,TO_DATE(pay_core_utils.get_parameter('TEDF',legislative_parameters),'YYYY/MM/DD')
        ,TO_DATE(pay_core_utils.get_parameter('TEDT',legislative_parameters),'YYYY/MM/DD')
        ,pay_core_utils.get_parameter('LIO',legislative_parameters)
        ,TO_DATE(pay_core_utils.get_parameter('EDATE',legislative_parameters),'YYYY/MM/DD')
  FROM  pay_payroll_actions PPA
  WHERE PPA.payroll_action_id  =  p_payroll_action_id;

  --
  --*************************************************************************
  --
  -- CURSOR lcu_ei_org_info
  --
  -- DESCRIPTION
  --  Fetches Separation Certificate Santei Base, Separation Certificate Output Period at the org EI level
  --
  -- PARAMETERS
  -- ==========
  -- NAME                TYPE     DESCRIPTION
  -------------------   -------- ---------------------------------------------
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   initialize procedure
  --
  --**********************************************************************
  CURSOR lcu_ei_org_info(p_organization_id hr_organization_information.organization_id%TYPE)
  IS
  SELECT  NVL(org_information15,gc_date_earned)
         ,NVL(org_information16,12)
  FROM  hr_organization_information HOI
  WHERE HOI.org_information_context= 'JP_LI_UNION_INFO'
  AND    organization_id= p_organization_id;
  -- Local Variables
  lc_procedure               VARCHAR2(200);
  --
  BEGIN
    --
    gb_debug :=hr_utility.debug_enabled ;
    lc_procedure := gc_package||'initialize';
    --
    IF gb_debug THEN
       hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    -------------------------------------------------------------------------
    -- initialization_code to  set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    -------------------------------------------------------------------------
    gn_arc_payroll_action_id := p_payroll_action_id;
    -------------------------------------------------------------------------
    -- Fetch the parameters passed by user into global variable.
    -------------------------------------------------------------------------
    OPEN  lcr_params(p_payroll_action_id);
    FETCH lcr_params
    INTO  gr_parameters.business_group_id
         ,gr_parameters.assignment_set_id
         ,gr_parameters.termination_date_from
         ,gr_parameters.termination_date_to
         ,gr_parameters.labor_insorg_id
         ,gr_parameters.effective_date;
    CLOSE lcr_params;
    --
    IF gb_debug THEN
       hr_utility.set_location('p_payroll_action_id.........          = ' || p_payroll_action_id,30);
       hr_utility.set_location('gr_parameters.business_group_id.......= ' || gr_parameters.business_group_id,30);
       hr_utility.set_location('gr_parameters.assignment_set_id.......= ' || gr_parameters.assignment_set_id,30);
       hr_utility.set_location('gr_parameters.termination_date_from...= ' || gr_parameters.termination_date_from,30);
       hr_utility.set_location('gr_parameters.termination_date_to.....= ' || gr_parameters.termination_date_to,30);
       hr_utility.set_location('gr_parameters.labor_insorg_id..= ' || gr_parameters.labor_insorg_id,30);
       hr_utility.set_location('gr_parameters.effective_date.......   = ' || gr_parameters.effective_date,30);
    END IF;
    --
    gn_business_group_id := gr_parameters.business_group_id ;
    gn_payroll_action_id := p_payroll_action_id;
    gc_legislation_code  := pay_jp_balance_pkg.get_legislation_code(gr_parameters.business_group_id);
    gn_sal_ele_set_id    := get_element_set_id(gc_sal_ele_set,gr_parameters.business_group_id,gc_legislation_code);
    gn_spb_ele_set_id    := get_element_set_id(gc_spb_ele_set,gr_parameters.business_group_id,gc_legislation_code);
    --
    -------------------------------------------------------------------------
    -- Fetch the Organization information into global type
    -------------------------------------------------------------------------
    OPEN  lcu_ei_org_info(gr_parameters.labor_insorg_id);
    FETCH lcu_ei_org_info
    INTO  gc_santei_base
         ,gn_output_period;
    CLOSE lcu_ei_org_info;
    --
    IF gb_debug THEN
      hr_utility.set_location('Separation Certificate Santei Base.......= ' || gc_santei_base,30);
      hr_utility.set_location('Separation Certificate Output Period.......= ' ||gn_output_period,30);
      hr_utility.set_location('gn_sal_ele_set_id .........= ' ||gn_sal_ele_set_id,30);
      hr_utility.set_location('gn_spb_ele_set_id .........= ' ||gn_spb_ele_set_id,30);
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END initialize;
  --
  PROCEDURE INITIALIZATION_CODE ( p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE )
  --***************************************************************************
  -- PROCEDURE
  --   INITIALIZATION_CODE
  --
  -- DESCRIPTION
  --   This procedure is used to set global contexts
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  --==========
  -- NAME                       TYPE     DESCRIPTION
  -------------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --***********************************************************************
  IS
  -- Local Variables
  lc_procedure               VARCHAR2(200);
  --
  BEGIN
    --
    gb_debug :=hr_utility.debug_enabled ;
    --
    IF gb_debug THEN
      lc_procedure := gc_package||'INITIALIZATION_CODE';
      hr_utility.set_location('Entering '||lc_procedure,1);
    END IF;
    -----------------------------------------------------------
    -- initialization_code to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
    -----------------------------------------------------------
    gn_arc_payroll_action_id := p_payroll_action_id;
    -----------------------------------------------------------
    -- Fetch the parameters passed by user into global variable
    -- initialize procedure
    -----------------------------------------------------------
    initialize(p_payroll_action_id);
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1000);
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Error in '||lc_procedure,999999);
    RAISE;
  END INITIALIZATION_CODE;
  --Function pay_yea_balance_result_value
  --
  FUNCTION range_person_on
  --************************************************************************
  -- FUNCTION
  -- range_person_on
  --
  -- DESCRIPTION
  --  Checks if RANGE_PERSON_ID is enabled for
  --  Archive process.
  --
  -- ACCESS
  --   PRIVATE
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --  assignment_action_code
  --************************************************************************
  RETURN BOOLEAN
  IS
  --
  CURSOR lcu_action_parameter
  IS
  SELECT parameter_value
  FROM   pay_action_parameters
  WHERE  parameter_name = 'RANGE_PERSON_ID';
  --
  lb_return           BOOLEAN;
  lc_action_param_val VARCHAR2(30);
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled;
  --
    IF gb_debug THEN
      hr_utility.set_location('Entering range_person_on',10);
    END IF;
  --
    OPEN  lcu_action_parameter;
    FETCH lcu_action_parameter INTO lc_action_param_val;
    CLOSE lcu_action_parameter;
  --
    IF lc_action_param_val = 'Y' THEN
      lb_return := TRUE;
      IF gb_debug THEN
        hr_utility.set_location('Range Person = True',10);
      END IF;
    ELSE
      lb_return := FALSE;
    END IF;
  --
    IF gb_debug THEN
      hr_utility.set_location('Leaving range_person_on',10);
    END IF;
    RETURN lb_return;
  --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF gb_debug THEN
      hr_utility.set_location('No Data Found Exception in range_person_on',10);
    END IF;
    lb_return := FALSE;
    RETURN lb_return;
  END range_person_on;
  --
  PROCEDURE assignment_action_code ( p_payroll_action_id IN pay_payroll_actions.payroll_action_id%type
                                    ,p_start_person      IN per_all_people_f.person_id%type
                                    ,p_end_person        IN per_all_people_f.person_id%type
                                    ,p_chunk             IN NUMBER
                                   )
  --************************************************************************
  -- PROCEDURE
  --   assignment_action_code
  --
  -- DESCRIPTION
  --   This procedure further restricts the assignment_id's returned by range_code
  --   This procedure gets the parameters given by user and restricts
  --   the assignments to be archived
  --   it then calls hr_nonrun.insact to create an assignment action id
  --   it then archives Payroll Run assignment action id  details
  --   for each assignment.
  --   There are different cursors for choosing the assignment ids.
  --   Depending on the parameters passed,the appropriate cursor is used.
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_payroll_action_id        IN       This parameter passes Payroll Action Id
  -- p_start_person             IN       This parameter passes Start Person Id
  -- p_end_person               IN       This parameter passes End Person Id
  -- p_chunk                    IN      This parameter passes Chunk Number
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   PYUGEN process
  --************************************************************************
  IS
--
  CURSOR lcu_emp_assignment_det_r ( p_business_group_id  per_assignments_f.business_group_id%TYPE
                                   ,p_organization_id    per_assignments_f.organization_id%TYPE
                                   ,p_effective_date     DATE
                                   ,p_start_date         DATE
                                   ,p_end_date           DATE
                                  )
  IS
  SELECT PAF.assignment_id
        ,PPS.actual_termination_date
        ,PPS.projected_termination_date
  FROM   per_people_f             PPF
        ,per_assignments_f        PAF
        ,per_periods_of_service   PPS
        ,pay_population_ranges    PPR
        ,pay_payroll_actions      PPA
  WHERE PPF.person_id              = PAF.person_id
  AND   PPF.person_id              = PPS.person_id
  AND   PPA.payroll_action_id      = p_payroll_action_id
  AND   PPA.payroll_action_id      = PPR.payroll_action_id
  AND   PPR.chunk_number           = p_chunk
  AND   PPR.person_id              = PPF.person_id
  AND   PAF.business_group_id      = p_business_group_id
  AND   PPA.business_group_id      = PAF.business_group_id
  AND   PPS.period_of_service_id   = PAF.period_of_service_id
  AND   TRUNC(NVL(PPS.actual_termination_date,PPS.projected_termination_date)) BETWEEN PPF.effective_start_date AND PPF.effective_end_date
  AND   TRUNC(NVL(PPS.actual_termination_date,PPS.projected_termination_date)) BETWEEN PAF.effective_start_date AND PAF.effective_end_date
  AND   TRUNC(NVL(PPS.actual_termination_date,PPS.projected_termination_date))  BETWEEN p_start_date AND p_end_date
  AND   NVL(get_life_ins_org_id(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date)),-999) =  p_organization_id
  AND   NVL(get_ei_type(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date)),-999) IN ('EE','EE_AGED','EX','EX_AGED')
  AND   NVL(PPS.actual_termination_date,PPS.projected_termination_date) BETWEEN get_ei_qualify_date(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date))
        AND NVL(get_ei_dis_qual_date(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date))-1,TO_DATE('31/12/4712','dd/mm/yyyy'))
  AND   get_term_rpt_flag(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date))= 'Y'
  ORDER BY PAF.assignment_id;
  --
  CURSOR lcu_emp_assignment_det ( p_start_person_id    per_all_people_f.person_id%TYPE
                                 ,p_end_person_id      per_all_people_f.person_id%TYPE
                                 ,p_business_group_id  per_assignments_f.business_group_id%TYPE
                                 ,p_organization_id    per_assignments_f.organization_id%TYPE
                                 ,p_effective_date     DATE
                                 ,p_start_date         DATE
                                 ,p_end_date           DATE
                                )
  IS
  SELECT PAF.assignment_id
        ,PPS.actual_termination_date
        ,PPS.projected_termination_date
  FROM   per_people_f             PPF
        ,per_assignments_f        PAF
        ,per_periods_of_service   PPS
  WHERE PPF.person_id              = PAF.person_id
  AND   PPF.person_id              = PPS.person_id
  AND   PAF.business_group_id      = p_business_group_id
  AND   PPF.person_id        BETWEEN p_start_person_id
                                 AND p_end_person_id
  AND   PPS.period_of_service_id   = PAF.period_of_service_id
  AND   TRUNC(NVL(PPS.actual_termination_date,PPS.projected_termination_date)) BETWEEN PPF.effective_start_date   AND PPF.effective_end_date
  AND   TRUNC(NVL(PPS.actual_termination_date,PPS.projected_termination_date)) BETWEEN PAF.effective_start_date   AND PAF.effective_end_date
  AND   TRUNC(NVL(PPS.actual_termination_date,PPS.projected_termination_date)) BETWEEN p_start_date AND p_end_date
  AND   NVL(get_life_ins_org_id(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date)),-999)    =  p_organization_id
  AND   NVL(get_ei_type(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date)),-999) IN ('EE','EE_AGED','EX','EX_AGED')
  AND   NVL(PPS.actual_termination_date,PPS.projected_termination_date)BETWEEN get_ei_qualify_date(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date))
        AND NVL(get_ei_dis_qual_date(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date))-1,TO_DATE('31/12/4712','dd/mm/yyyy'))
  AND   get_term_rpt_flag(PAF.assignment_id,NVL(PPS.actual_termination_date,PPS.projected_termination_date))= 'Y'
  ORDER BY PAF.assignment_id;
  --
  CURSOR lcu_next_action_id
  IS
  SELECT pay_assignment_actions_s.NEXTVAL
  FROM   dual;
  --
  -- Local Variables
  lt_org_id                     per_jp_report_common_pkg.gt_org_tbl;
  lc_procedure                  VARCHAR2(200);
  lc_include_flag               VARCHAR2(1);
  ld_start_date                 DATE;
  ln_next_assignment_action_id  NUMBER;
--
  BEGIN
--
    gb_debug := hr_utility.debug_enabled ;
--
    IF gb_debug THEN
      lc_procedure := gc_package||'assignment_action_code';
      hr_utility.set_location('Entering ' || lc_procedure,20);
      hr_utility.set_location('Entering assignment_action_code',20);
      hr_utility.set_location('Person Range '||p_start_person||' - '||p_end_person,20);
      hr_utility.set_location('p_payroll_action_id - '||p_payroll_action_id,20);
      hr_utility.set_location('p_chunk - '||p_chunk,20);
    END IF;
--
    -- initialization_code to to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
--
    initialize(p_payroll_action_id);
--


        IF range_person_on THEN
--
          IF gb_debug THEN
            hr_utility.set_location('Inside Range person if condition',20);
          END IF;
--        -- Assignment Action for Current and Terminated Employees
          FOR lr_emp_assignment_det IN lcu_emp_assignment_det_r(gr_parameters.business_group_id
                                                               ,gr_parameters.labor_insorg_id
                                                               ,gr_parameters.effective_date
                                                               ,gr_parameters.termination_date_from
                                                               ,gr_parameters.termination_date_to
                                                               )
          LOOP
            IF NVL(gr_parameters.assignment_set_id,0) = 0 THEN
              OPEN  lcu_next_action_id;
              FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
              CLOSE lcu_next_action_id;
              --
              IF gb_debug THEN
                hr_utility.set_location('p_payroll_action_id.........        = '||p_payroll_action_id,20);
                hr_utility.set_location('l_next_assignment_action_id.        = '||ln_next_assignment_action_id,20);
                hr_utility.set_location('lr_emp_assignment_det.assignment_id.= '||lr_emp_assignment_det.assignment_id,20);
              END IF;
--
              -- Create the archive assignment actions
              hr_nonrun_asact.insact(ln_next_assignment_action_id
                                    ,lr_emp_assignment_det.assignment_id
                                    ,p_payroll_action_id
                                    ,p_chunk
                                    );
            ELSE
              lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => gr_parameters.assignment_set_id
                                                                              ,p_assignment_id     => lr_emp_assignment_det.assignment_id
                                                                              ,p_effective_date    => NVL(lr_emp_assignment_det.actual_termination_date,lr_emp_assignment_det.projected_termination_date)
                                                                              ,p_populate_fs_flag  => 'Y'
                                                                              );
              IF lc_include_flag = 'Y' THEN
                OPEN  lcu_next_action_id;
                FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
                CLOSE lcu_next_action_id;
                --
                IF gb_debug THEN
                  hr_utility.set_location('p_payroll_action_id.........        = '||p_payroll_action_id,20);
                  hr_utility.set_location('l_next_assignment_action_id.        = '||ln_next_assignment_action_id,20);
                  hr_utility.set_location('lr_emp_assignment_det.assignment_id.= '||lr_emp_assignment_det.assignment_id,20);
                END IF;
--
                -- Create the archive assignment actions
                hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                      );
              END IF;
            END IF;
          END LOOP; -- End loop for assignment details cursor
        ELSE -- Range person is not on
          IF gb_debug THEN
            hr_utility.set_location('Range person returns false',20);
          END IF;
--        -- Assignment Action for Current and Terminated Employees
          FOR lr_emp_assignment_det IN lcu_emp_assignment_det(p_start_person
                                                             ,p_end_person
                                                             ,gr_parameters.business_group_id
                                                             ,gr_parameters.labor_insorg_id
                                                             ,gr_parameters.effective_date
                                                             ,gr_parameters.termination_date_from
                                                             ,gr_parameters.termination_date_to
                                                             )
          LOOP
            IF NVL(gr_parameters.assignment_set_id,0) = 0 THEN
              OPEN  lcu_next_action_id;
              FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
              CLOSE lcu_next_action_id;
              --
              IF gb_debug THEN
                hr_utility.set_location('p_payroll_action_id.........        = '||p_payroll_action_id,20);
                hr_utility.set_location('l_next_assignment_action_id.        = '||ln_next_assignment_action_id,20);
                hr_utility.set_location('lr_emp_assignment_det.assignment_id.= '||lr_emp_assignment_det.assignment_id,20);
              END IF;
--
              -- Create the archive assignment actions
              hr_nonrun_asact.insact(ln_next_assignment_action_id
                                    ,lr_emp_assignment_det.assignment_id
                                    ,p_payroll_action_id
                                    ,p_chunk
                                    );
            ELSE
              lc_include_flag := hr_jp_ast_utility_pkg.assignment_set_validate(p_assignment_set_id => gr_parameters.assignment_set_id
                                                                              ,p_assignment_id     => lr_emp_assignment_det.assignment_id
                                                                              ,p_effective_date    => NVL(lr_emp_assignment_det.actual_termination_date,lr_emp_assignment_det.projected_termination_date)
                                                                              ,p_populate_fs_flag  => 'Y'
                                                                              );
              IF lc_include_flag = 'Y' THEN
                OPEN  lcu_next_action_id;
                FETCH lcu_next_action_id INTO ln_next_assignment_action_id;
                CLOSE lcu_next_action_id;
                --
                IF gb_debug THEN
                  hr_utility.set_location('p_payroll_action_id.........        = '||p_payroll_action_id,20);
                  hr_utility.set_location('l_next_assignment_action_id.        = '||ln_next_assignment_action_id,20);
                  hr_utility.set_location('lr_emp_assignment_det.assignment_id.= '||lr_emp_assignment_det.assignment_id,20);
                END IF;
--
                -- Create the archive assignment actions
                hr_nonrun_asact.insact(ln_next_assignment_action_id
                                      ,lr_emp_assignment_det.assignment_id
                                      ,p_payroll_action_id
                                      ,p_chunk
                                      );
              END IF;
            END IF;
          END LOOP; -- End loop for assignment details cursor
        END IF;     -- End If for range_person_on
--
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1);
    END IF;
--
  EXCEPTION
  WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in '||lc_procedure,999999);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    RAISE  gc_exception;
  END assignment_action_code;
--
  --
  PROCEDURE ARCHIVE_CODE ( p_assignment_action_id  IN pay_assignment_actions.assignment_action_id%type
                         , p_effective_date        IN pay_payroll_actions.effective_date%type
                         )
  --************************************************************************
  -- PROCEDURE
  --   ARCHIVE_CODE
  --
  -- DESCRIPTION
  -- If employee details not previously archived,proc archives employee
  -- details in pay_Action_information with context 'JP_UITE_EMP'
  --
  -- ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_assignment_action_id      IN       This parameter passes Assignment Action Id
  -- p_effective_date            IN       This parameter passes Effective Date
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************
  IS
--
  CURSOR lcu_get_assignment_id ( p_assignment_action_id pay_assignment_actions.assignment_action_id%type )
  IS
  SELECT assignment_id
  FROM   pay_assignment_actions
  WHERE  assignment_action_id = p_assignment_action_id;
--
  CURSOR lcu_employee_details ( p_assignment_id     NUMBER
                              , p_effective_date    DATE
                              )
  IS
  SELECT PPF.employee_number                                                                                         EMPLOYEE_NUMBER
       , get_ui_num(p_assignment_id,NVL(PPOS.actual_termination_date,PPOS.projected_termination_date))                                                    UI_REGISTERED_NUMBER
       , PPF.last_name                                                                                               LAST_NAME_KANA
       , PPF.first_name                                                                                              FIRST_NAME_KANA
       , PPF.per_information18                                                                                       LAST_NAME
       , PPF.per_information19                                                                                       FIRST_NAME
       , NVL(PPOS.actual_termination_date,PPOS.projected_termination_date)                                           TERMINATION_DATE
       , PAD.postal_code                                                                                             EMP_ZIP_CODE
       , PAD.address_line1                                                                                           ADDRESS_LINE1
       , PAD.address_line2                                                                                           ADDRESS_LINE2
       , PAD.address_line3                                                                                           ADDRESS_LINE3
       , PAD.telephone_number_1                                                                                      PHONE_NUM
       , PAF.assignment_id                                                                                           ASSIGNMENT_ID
       , PAF.payroll_id                                                                                              PAYROLL_ID
       , PPOS.date_start                                                                                             HIRE_DATE
       , PPOS.last_standard_process_date                                                                             LAST_STD_PROCESS_DATE
  FROM   per_people_f                 PPF
       , per_assignments_f            PAF
       , per_addresses                PAD
       , per_periods_of_service       PPOS
  WHERE PAF.person_id                      = PPF.person_id
  AND   PAD.person_id(+)                   = PPF.person_id
  AND   PAD.address_type(+)                = 'JP_C'
  AND   TRUNC(NVL(PPOS.actual_termination_date,PPOS.projected_termination_date)) BETWEEN  NVL(PAD.date_from,NVL(PPOS.actual_termination_date,PPOS.projected_termination_date))
        AND NVL(PAD.date_to,TO_DATE('31/12/4712','dd/mm/yyyy')) --#Bug9648137
  AND   PPF.person_id                  =    PPOS.person_id
  AND   TRUNC(NVL(PPOS.actual_termination_date,PPOS.projected_termination_date)) BETWEEN PPF.effective_start_date
                                     AND PPF.effective_end_date
  AND   TRUNC(NVL(PPOS.actual_termination_date,PPOS.projected_termination_date)) BETWEEN PAF.effective_start_date
                                     AND PAF.effective_end_date
  AND   PAF.assignment_id                  = p_assignment_id
  AND   PPOS.period_of_service_id          = NVL(PAF.period_of_service_id,PPOS.period_of_service_id)
  ORDER BY PPF.effective_start_date;
  --
  -- Local Variables
  ln_action_info_id             pay_action_information.action_information_id%TYPE;
  ln_obj_version_num            pay_action_information.object_version_number%TYPE;
  ln_assignment_id              per_all_assignments_f.assignment_id%TYPE;
  lc_procedure                  VARCHAR2(200);
  ld_ins_start_date             per_time_periods.start_date%TYPE;
  --
  BEGIN
  --
    gb_debug := hr_utility.debug_enabled ;
    -- initialization_code to set the global tables for EIT
    -- that will be used by each thread in multi-threading.
--
    initialize(gn_payroll_action_id);
--
    IF gb_debug THEN
      lc_procedure  := gc_package||'archive_code';
      hr_utility.set_location('Entering '||lc_procedure,1);
      hr_utility.set_location('p_assignment_action_id......= '|| p_assignment_action_id,10);
      hr_utility.set_location('p_effective_date............= '|| TO_CHAR(p_effective_date,'DD-MON-YYYY'),10);
    END IF;
    --
    -- Fetch the assignment id
    OPEN  lcu_get_assignment_id(p_assignment_action_id);
    FETCH lcu_get_assignment_id INTO ln_assignment_id;
    CLOSE lcu_get_assignment_id;
   --
    IF gb_debug THEN
      hr_utility.set_location('Opening Employee Details cursor for ARCHIVE',30);
      hr_utility.set_location('Archiving EMPLOYEE DETAILS',30);
    END IF;
    --
    FOR lr_employee_details IN lcu_employee_details(p_assignment_id  => ln_assignment_id
                                                   ,p_effective_date => gr_parameters.effective_date)
    LOOP
    --
         -- EMPLOYEE DETAILS ----------
          pay_action_information_api.create_action_information
        ( p_action_information_id        => ln_action_info_id
        , p_action_context_id            => p_assignment_action_id
        , p_action_context_type          => 'AAP'
        , p_object_version_number        => ln_obj_version_num
        , p_effective_date               => p_effective_date
        , p_assignment_id                => lr_employee_details.assignment_id
        , p_source_id                    => NULL
        , p_source_text                  => NULL
        , p_action_information_category  => 'JP_UITE_EMP'
        , p_action_information1          => lr_employee_details.EMPLOYEE_NUMBER
        , p_action_information2          => lr_employee_details.UI_REGISTERED_NUMBER
        , p_action_information3          => lr_employee_details.LAST_NAME_KANA
        , p_action_information4          => lr_employee_details.FIRST_NAME_KANA
        , p_action_information5          => lr_employee_details.LAST_NAME
        , p_action_information6          => lr_employee_details.FIRST_NAME
        , p_action_information7          => fnd_date.date_to_canonical(lr_employee_details.TERMINATION_DATE)
        , p_action_information8          => lr_employee_details.EMP_ZIP_CODE
        , p_action_information9          => lr_employee_details.ADDRESS_LINE1
        , p_action_information10         => lr_employee_details.ADDRESS_LINE2
        , p_action_information11         => lr_employee_details.ADDRESS_LINE3
        , p_action_information12         => lr_employee_details.PHONE_NUM
        );
         -- SALARY DETAILS----------
          proc_sal_arch( p_assignment_action_id => p_assignment_action_id
                          ,p_payroll_action_id  => gn_payroll_action_id
                          ,p_assignment_id      => lr_employee_details.assignment_id
                          ,p_effective_date     => p_effective_date
                          ,p_termination_date   => lr_employee_details.TERMINATION_DATE
                          ,p_payroll_id         => lr_employee_details.payroll_id
                          ,p_hire_date          => lr_employee_details.hire_date
                          ,p_last_std_process_date => lr_employee_details.last_std_process_date
                          ,p_ins_start_date     => ld_ins_start_date );


         -- SPECIAL BONUS DETAILS -------
         proc_spb_arch  (p_assignment_action_id => p_assignment_action_id
                         ,p_assignment_id        => lr_employee_details.assignment_id
                         ,p_effective_date       => p_effective_date
                         ,p_period_start_date    => ld_ins_start_date
                         ,p_period_end_date      => lr_employee_details.TERMINATION_DATE
                         ,p_payroll_id           => lr_employee_details.payroll_id
                         );
         --
         -- Temination details and Wage Instructions ----------
         --
          proc_term_arch( p_assignment_action_id => p_assignment_action_id
                          ,p_payroll_action_id   => gn_payroll_action_id
                          ,p_assignment_id       => lr_employee_details.assignment_id
                          ,p_effective_date      => p_effective_date
                          ,p_termination_date    => lr_employee_details.TERMINATION_DATE
                        );

        --
    END LOOP; -- End LOOP for Employee Details
    --
    IF gb_debug THEN
      hr_utility.set_location('Leaving '||lc_procedure,1);
    END IF;
--
  EXCEPTION
  WHEN gc_exception THEN
    IF gb_debug THEN
      hr_utility.set_location('Error in '||lc_procedure,999999);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    RAISE  gc_exception;
  END ARCHIVE_CODE;

PROCEDURE deinitialize_code(p_payroll_action_id IN NUMBER)
--************************************************************************
  --   PROCEDURE
  --   deinitialize_code
  --
  --   DESCRIPTION
  --   This package is used to remove temporary action codes
  --
  --   ACCESS
  --   PUBLIC
  --
  -- PARAMETERS
  -- ==========
  -- NAME                       TYPE     DESCRIPTION
  -- -----------------         -------- ---------------------------------------
  -- p_payroll_action_id       IN       This parameter passes Assignment Action Id
  --
  -- PREREQUISITES
  --   None
  --
  -- CALLED BY
  --   None
  --************************************************************************/

IS
--
CURSOR lcu_office_details
IS
SELECT HOI.org_information1         LOCATION_NUMBER
      ,HOI.org_information2         BUSINESS_ADDRESS1
      ,HOI.org_information3         BUSINESS_ADDRESS2
      ,HOI.org_information4         BUSINESS_ADDRESS3
      ,HOI.org_information5         EMPLOYER_ADDRESS1
      ,HOI.org_information6         EMPLOYER_ADDRESS2
      ,HOI.org_information7         EMPLOYER_ADDRESS3
      ,HOI.org_information8         LOCATION_NAME
      ,HOI.org_information9         EMPLOYER_NAME
      ,HOI.org_information10        EMPLOYER_FULL_NAME
      ,HOI.org_information11        COMPANY_PHONE
FROM   hr_organization_information  HOI
WHERE  HOI.org_information_context = 'JP_LI_UNION_INFO'
AND    HOI.organization_id         = gr_parameters.labor_insorg_id;
--
lc_proc                       CONSTANT VARCHAR2(61) := gc_package || 'deinitialise_code';
ln_action_info_id             pay_action_information.action_information_id%TYPE;
ln_obj_version_num            pay_action_information.object_version_number%TYPE;

--
BEGIN
  gb_debug := hr_utility.debug_enabled ;
      --
      IF gb_debug THEN
             hr_utility.set_location('Entering: ' || lc_proc, 10);
      END IF;
      --
      -- Office Details
      --
      FOR lr_office_details IN lcu_office_details
          --
          LOOP
          --
          pay_action_information_api.create_action_information
          ( p_action_information_id        => ln_action_info_id
          , p_action_context_id            => p_payroll_action_id
          , p_action_context_type          => 'PA'
          , p_object_version_number        => ln_obj_version_num
          , p_effective_date               => gr_parameters.effective_date
          , p_source_id                    => NULL
          , p_source_text                  => NULL
          , p_action_information_category  => 'JP_UITE_OFFICE'
          , p_action_information1          => lr_office_details.LOCATION_NUMBER
          , p_action_information2          => lr_office_details.LOCATION_NAME
          , p_action_information3          => lr_office_details.BUSINESS_ADDRESS1
          , p_action_information4          => lr_office_details.BUSINESS_ADDRESS2
          , p_action_information5          => lr_office_details.BUSINESS_ADDRESS3
          , p_action_information6          => lr_office_details.COMPANY_PHONE
          , p_action_information7          => lr_office_details.EMPLOYER_FULL_NAME
          , p_action_information8          => lr_office_details.EMPLOYER_ADDRESS1
          , p_action_information9          => lr_office_details.EMPLOYER_ADDRESS2
          , p_action_information10         => lr_office_details.EMPLOYER_ADDRESS3
          , p_action_information11         => lr_office_details.EMPLOYER_NAME
          );
        --
      END LOOP;
      --
       IF gb_debug THEN
             hr_utility.set_location('Leaving: ' || lc_proc, 10);
       END IF;
      --
END deinitialize_code;
--
END pay_jp_uite_arch_pkg;

/
