--------------------------------------------------------
--  DDL for Package Body PAY_IN_PROF_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_PROF_TAX_PKG" AS
/* $Header: pyinptax.pkb 120.8 2006/04/24 04:18:28 statkar noship $ */
   g_package       VARCHAR2(20) ;
   g_debug         BOOLEAN;
   g_token_name    pay_in_utils.char_tab_type;
   g_token_value   pay_in_utils.char_tab_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_STATE                                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the state associated with PT Org --
-- Parameters     :                                                     --
--             IN : p_pt_org               VARCHAR2                     --
--            OUT : N/A                                                 --
--         Return : VARCHAR2                                            --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   28-AUG-04  statkar   Created this function                     --
--------------------------------------------------------------------------
  FUNCTION get_state (p_pt_org IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_message          VARCHAR2(255);

     CURSOR csr_state (p_pt_org IN VARCHAR2) IS
        select hoi.org_information4
        from   hr_organization_information hoi
             , hr_organization_units hou
        where  hoi.organization_id = p_pt_org
        and    hoi.organization_id = hou.organization_id
        and    hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
        and    org_information_context ='PER_IN_PROF_TAX_DF';
--
    l_state   hr_lookups.lookup_code%TYPE;
    l_procedure VARCHAR2(100);

  BEGIN
     l_procedure := g_package||'get_state';
     g_debug          := hr_utility.debug_enabled;

     pay_in_utils.set_location(g_debug,'Entering : '||l_procedure, 10);

     OPEN csr_state (p_pt_org);
     FETCH csr_state INTO l_state;
     pay_in_utils.set_location (g_debug,'l_state = '||l_state,20);
     CLOSE csr_state;

     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

     RETURN l_state;
  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,' Leaving : '||l_procedure, 40);
       hr_utility.trace(l_message);
       RETURN NULL;

  END get_state;


----------------------------------------------------------------------------
--                                                                        --
-- Name         : GET_PT_BALANCE                                          --
-- Type         : Function                                                --
-- Access       : Public                                                  --
-- Description  : Function to get the balance values                      --
--                                                                        --
-- Parameters   :                                                         --
--           IN : p_balance_name               VARCHAR2                   --
--                p_year_start                 DATE                       --
--                p_end_date                   DATE                       --
--                p_tot_pay_periods            NUMBER                     --
--                p_period_num                 NUMBER                     --
--                p_frequency                  NUMBER                     --
--                p_state                      VARCHAR2                   --
--          OUT : p_gross_salary               NUMBER                     --
--                p_prepaid_tax                NUMBER                     --
--                p_period_count               NUMBER                     --
--       RETURN : VARCHAR2                                                --
--                                                                        --
-- Change History :                                                       --
----------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                                 --
----------------------------------------------------------------------------
-- 1.0   24-Nov-04  statkar  Created this function                        --
-- 1.1   30-Nov-04  statkar  4038110 - Added to_number(null)              --
-- 1.2   02-Dec-04  statkar  4040984 - Modified to return balance periods --
-- 1.3   24-Dec-04  vgsriniv 3988608 - Corrected the action status for    --
--                                     processing to P. Modified the source--
--                                     action id check to not null        --
-- 1.4   03-Jan-05  vgsriniv 4095616 - Added parameter p_pt_org and used  --
--                                     source id to get Professional tax balance--
-- 1.5   05-Mar-05  abhjain  4161979   Nulled out the function            --
----------------------------------------------------------------------------
FUNCTION get_pt_balance(p_payroll_id      IN NUMBER
                       ,p_assignment_id   IN NUMBER
                       ,p_assignment_action_id IN NUMBER
                       ,p_balance_name    IN VARCHAR2
                       ,p_year_start      IN DATE
                       ,p_end_date        IN DATE
                       ,p_tot_pay_periods IN NUMBER
                       ,p_period_num      IN NUMBER
                       ,p_frequency       IN NUMBER
                       ,p_state           IN VARCHAR2
                       ,p_gross_salary    OUT NOCOPY NUMBER
                       ,p_prepaid_tax     OUT NOCOPY NUMBER
                       ,p_period_count    OUT NOCOPY NUMBER
                       ,p_pt_org          IN NUMBER)
RETURN VARCHAR2
IS
BEGIN
  NULL;
END get_pt_balance;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PT_UPDATE                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create PT ELement Entries              --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                  p_dt_mode             VARCHAR2                      --
--                  p_assignment_id       NUMBER                        --
--                  p_pt_org              VARCHAR2                      --
--            OUT : p_message             VARCHAR2                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   10-Sep-04  statkar   Created this function                     --
-- 1.1   02-Dec-04  aaagarwa  Added checks on effective date while      --
--                            deleting Professional Tax entry           --
-- 1.2   04-Dec-04  statkar   Changed IV to Organization                --
-- 1.3   14-Dec-04  aaagawra  Facilitated deletion in update mode       --
-- 1.4   29-Dec-04  lnagaraj  Modified code that checks for presence    --
--                            of element links                          --
-- 1.5   15-Mar-05  abhjain   Added the State Input Value               --
-- 1.6   24-Mar-05  aaagarwa  Modified the cursor c_pt                  --
-- 1.7   07-Apr-05  abhjain   Nulled out the procedure                  --
--------------------------------------------------------------------------
  PROCEDURE check_pt_update
         (p_effective_date   IN  DATE
         ,p_dt_mode          IN  VARCHAR2
         ,p_assignment_id    IN  NUMBER
         ,p_pt_org           IN  VARCHAR2
         ,p_message          OUT NOCOPY VARCHAR2
         )
  IS
  BEGIN

    NULL;

  END check_pt_update;


--------------------------------------------------------------------------
-- Name           : check_pt_exemptions                                 --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc to be called for validation           --
-- Parameters     :                                                     --
--             IN : p_organization_id       IN NUMBER                   --
--                  p_org_info_type_code    IN VARCHAR2                 --
--                  p_calling_procedure     IN VARCHAR2                 --
--                  p_org_information1..4   IN VARCHAR2                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27-Sep-04  statkar   Created this function                     --
-- 1.1   23-Nov-04  rpalli    Modified the "check for uniqueness"       --
--                            functionality to work for updations       --
--                            Bug Fix :3951465                          --
--------------------------------------------------------------------------
PROCEDURE check_pt_exemptions
          (p_organization_id     IN NUMBER
          ,p_org_information_id  IN NUMBER
          ,p_org_info_type_code  IN VARCHAR2
          ,p_state               IN VARCHAR2
          ,p_exemption_catg      IN VARCHAR2
          ,p_eff_start_date      IN VARCHAR2
          ,p_eff_end_date        IN VARCHAR2
          ,p_calling_procedure   IN VARCHAR2
          ,p_message_name        OUT NOCOPY VARCHAR2
          ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type)
IS

   l_procedure  VARCHAR2(100);
   l_dummy      VARCHAR2(1);

   CURSOR c_dup_state IS
      SELECT 'X'
      FROM   hr_organization_information
      WHERE  organization_id         = p_organization_id
      AND    org_information_context = p_org_info_type_code
      AND    org_information1        = p_state
      AND    org_information2        = p_exemption_catg
      AND    (p_org_information_id is NULL OR org_information_id <> p_org_information_id)
      AND    fnd_date.canonical_to_date(p_eff_start_date)
          <= fnd_date.canonical_to_date(NVL(org_information4,'4712/12/31 00:00:00'))
      AND    fnd_date.canonical_to_date(NVL(p_eff_end_date, '4712/12/31 00:00:00'))
          >= fnd_date.canonical_to_date(org_information3);

BEGIN
  l_procedure := g_package ||'check_pt_exemptions';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);
--
-- Validations are as follows:
--
--  1. Check for mandatory parameters
--  2. Check for lookups
--  3. Check for uniqueness
--  4. Check if Start Date > End Date
--
--
  IF p_state IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_STATE';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,20);

  IF p_exemption_catg IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_EXEMPTION_CATG';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,30);

  IF p_eff_start_date IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_EFFECTIVE_START_DATE';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,40);

  IF hr_general.decode_lookup('IN_PT_STATES',p_state) IS NULL THEN
     IF hr_general.decode_lookup('IN_STATES',p_state) IS NULL THEN
         p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
         p_token_name(1)  := 'VALUE';
         p_token_value(1) := p_state;
         p_token_name(2)  := 'FIELD';
         p_token_value(2) := 'P_STATE';
     END IF;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,50);

  IF length(p_exemption_catg) > 80 THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_exemption_catg;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_EXEMPTION_CATEGORY';
      RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,60);

  OPEN c_dup_state;
  FETCH c_dup_state
  INTO l_dummy;
  IF c_dup_state%FOUND THEN
      p_message_name := 'PER_IN_NON_UNIQUE_COMBINATION';
  END IF;
  CLOSE c_dup_state;
  pay_in_utils.set_location(g_debug,l_procedure,70);

  IF NOT pay_in_utils.validate_dates
               (fnd_date.canonical_to_date(p_eff_start_date),
                fnd_date.canonical_to_date(p_eff_end_date))
  THEN
      p_message_name   := 'PER_IN_INCORRECT_DATES';
      RETURN;
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);

END check_pt_exemptions;

--------------------------------------------------------------------------
-- Name           : check_pt_frequency                                  --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc to be called for validation           --
-- Parameters     :                                                     --
--             IN : p_organization_id       IN NUMBER                   --
--                  p_org_info_type_code    IN VARCHAR2                 --
--                  p_calling_procedure     IN VARCHAR2                 --
--                  p_org_information1..4   IN VARCHAR2                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27-Sep-04  statkar   Created this function                     --
-- 1.1   23-Nov-04  rpalli    Modified the "check for uniqueness"       --
--                            functionality to work for updations       --
--                            Bug Fix :3951465                          --
--------------------------------------------------------------------------
PROCEDURE check_pt_frequency
          (p_organization_id     IN NUMBER
          ,p_org_information_id  IN NUMBER
          ,p_org_info_type_code  IN VARCHAR2
          ,p_state               IN VARCHAR2
          ,p_frequency           IN VARCHAR2
          ,p_eff_start_date      IN VARCHAR2
          ,p_eff_end_date        IN VARCHAR2
          ,p_calling_procedure   IN VARCHAR2
          ,p_message_name        OUT NOCOPY VARCHAR2
          ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type)
IS

   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(255);
   l_dummy      VARCHAR2(1);

   CURSOR c_dup_state IS
      SELECT 'X'
      FROM   hr_organization_information
      WHERE  organization_id         = p_organization_id
      AND    org_information_context = p_org_info_type_code
      AND    org_information1        = p_state
      AND    (p_org_information_id is NULL OR org_information_id <> p_org_information_id)
      AND    fnd_date.canonical_to_date(p_eff_start_date)
          <= fnd_date.canonical_to_date(NVL(org_information4,'4712/12/31 00:00:00'))
      AND    fnd_date.canonical_to_date(NVL(p_eff_end_date, '4712/12/31 00:00:00'))
          >= fnd_date.canonical_to_date(org_information3);


BEGIN
  l_procedure := g_package ||'check_pt_frequency';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

--
-- Validations are as follows:
--
--  1. Check for mandatory parameters
--  2. Check for lookups
--  3. Check for uniqueness
--  4. Check if Start Date > End Date
--
--
  IF p_state IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_STATE';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,20);

  IF p_frequency IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_FREQUENCY';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,30);

  IF p_eff_start_date IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_EFFECTIVE_START_DATE';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,40);

  IF hr_general.decode_lookup('IN_PT_STATES',p_state) IS NULL THEN
     IF hr_general.decode_lookup('IN_STATES',p_state) IS NULL THEN
         p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
         p_token_name(1)  := 'VALUE';
         p_token_value(1) := p_state;
         p_token_name(2)  := 'FIELD';
         p_token_value(2) := 'P_STATE';
         RETURN;
     END IF;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,50);

  IF hr_general.decode_lookup('IN_PT_FREQUENCIES',p_frequency) IS NULL THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_frequency;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_FREQUENCY';
      RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,60);

  OPEN c_dup_state;
  FETCH c_dup_state
  INTO l_dummy;
  IF c_dup_state%FOUND THEN
      p_message_name := 'PER_IN_NON_UNIQUE_COMBINATION';
  END IF;
  CLOSE c_dup_state;
  pay_in_utils.set_location(g_debug,l_procedure,70);

  IF NOT pay_in_utils.validate_dates
               (fnd_date.canonical_to_date(p_eff_start_date),
                fnd_date.canonical_to_date(p_eff_end_date))
  THEN
      p_message_name   := 'PER_IN_INCORRECT_DATES';
      RETURN;
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);

END check_pt_frequency;

--------------------------------------------------------------------------
-- Name           : check_pt_challan_info                               --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc to be called for validation           --
-- Parameters     :                                                     --
--             IN : p_organization_id       IN NUMBER                   --
--                  p_org_info_type_code    IN VARCHAR2                 --
--                  p_calling_procedure     IN VARCHAR2                 --
--                  p_org_information1..6   IN VARCHAR2                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27-Sep-04  statkar   Created this function                     --
--------------------------------------------------------------------------
PROCEDURE check_pt_challan_info
          (p_organization_id    IN NUMBER
          ,p_org_info_type_code IN VARCHAR2
          ,p_payment_month      IN VARCHAR2
          ,p_payment_date       IN VARCHAR2
          ,p_payment_mode       IN VARCHAR2
          ,p_voucher_number     IN VARCHAR2
          ,p_amount             IN VARCHAR2
          ,p_interest           IN VARCHAR2
          ,p_payment_year       IN VARCHAR2
          ,p_excess_tax         IN VARCHAR2
          ,p_calling_procedure  IN VARCHAR2
          ,p_message_name       OUT NOCOPY VARCHAR2
          ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type)
IS

   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(255);
   l_dummy      VARCHAR2(1);

   CURSOR csr_ppt_id IS
     SELECT 'X'
     FROM   pay_payment_types ppt
     WHERE  ppt.payment_type_id = to_number(p_payment_mode)
     AND ppt.territory_code = 'IN'
     AND ppt.category <> 'MT';

BEGIN
  l_procedure := g_package ||'check_pt_challan_info';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

--
-- Validations are as follows:
--
--  1. Check for mandatory parameters
--  2. Check for lookups
--
--
  IF p_payment_month IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_PAYMENT_MONTH';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,20);

  IF p_payment_date IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_PAYMENT_DATE';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,30);

  IF p_payment_mode IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_PAYMENT_MODE';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,40);

  IF p_voucher_number IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_VOUCHER_NUMBER';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,50);

  IF p_amount IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_AMOUNT';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,60);

  IF p_payment_year IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_PAYMENT_YEAR';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,65);

  IF hr_general.decode_lookup('IN_CALENDAR_MONTH',p_payment_month) IS NULL THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_payment_month;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_PAYMENT_MONTH';
      RETURN;
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure,70);
  OPEN csr_ppt_id;
  FETCH csr_ppt_id
  INTO  l_dummy;
  CLOSE csr_ppt_id;

  pay_in_utils.set_location(g_debug,l_procedure,80);
  IF l_dummy IS NULL THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_payment_mode;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_PAYMENT_MODE';
      RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,90);

  IF length(p_voucher_number) > 20
  THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_voucher_number;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_VOUCHER_NUMBER';
      RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,100);

  IF length(p_amount) > 12
  THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_amount;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_AMOUNT';
      RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,110);

  IF p_interest IS NOT NULL AND length(p_interest) > 12
  THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_interest;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_INTEREST';
      RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,120);

  IF p_excess_tax IS NOT NULL AND length(p_excess_tax) > 12
  THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_excess_tax;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_EXCESS_TAX';
      RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,130);

END check_pt_challan_info;

--------------------------------------------------------------------------
-- Name           : check_stat_setup_df                                 --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc to be called for validation           --
-- Parameters     :                                                     --
--             IN : p_calling_procedure     IN VARCHAR2                 --
--                  p_org_information1      IN VARCHAR2                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27-Sep-04  statkar   Created this function                     --
--------------------------------------------------------------------------
PROCEDURE check_stat_setup_df
          (p_organization_id     IN NUMBER
          ,p_org_info_type_code  IN VARCHAR2
          ,p_state_level_bal     IN VARCHAR2
          ,p_gratuity_coverage   IN VARCHAR2
          ,p_calling_procedure   IN VARCHAR2
          ,p_message_name        OUT NOCOPY VARCHAR2
          ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type)
IS
   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(255);

   CURSOR c_org_info IS
      SELECT org_information1, org_information2
      FROM   hr_organization_information
      WHERE  organization_id         = p_organization_id
      AND    org_information_context = p_org_info_type_code;

   l_org_information1   hr_organization_information.org_information1%TYPE;
   l_org_information2   hr_organization_information.org_information2%TYPE;

BEGIN
  g_debug:= hr_utility.debug_enabled;
  l_procedure := g_package ||'check_stat_setup_df';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,l_procedure,20);

  OPEN  c_org_info;
  FETCH c_org_info
  INTO  l_org_information1, l_org_information2;
  CLOSE c_org_info;

  IF l_org_information1 <> p_state_level_bal THEN
       pay_in_utils.set_location(g_debug,l_procedure,30);
       p_message_name := 'PER_IN_PT_DEF_BAL_FLAG_CHANGE';
       RETURN;
  END IF;

  IF l_org_information2 <> p_gratuity_coverage THEN
       pay_in_utils.set_location(g_debug,l_procedure,30);
       p_message_name := 'PER_IN_GRAT_DEF_CHANGE';
       RETURN;
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END check_stat_setup_df;

--------------------------------------------------------------------------
-- Name           : check_pt_loc                                     --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Internal Proc to be called for validation           --
-- Parameters     :                                                     --
--             IN : p_organization_id      IN NUMBER                    --
--                  p_location_id          IN NUMBER                    --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27-Sep-04  statkar   Created this function                     --
--------------------------------------------------------------------------
PROCEDURE check_pt_loc
          (p_organization_id    IN NUMBER
          ,p_location_id        IN NUMBER
          ,p_calling_procedure  IN VARCHAR2
          ,p_message_name       OUT NOCOPY VARCHAR2
          ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type)
IS/*
   l_procedure  VARCHAR2(100);

  CURSOR csr_state IS
     SELECT loc_information16
     FROM   hr_locations
     WHERE  location_id = p_location_id
     AND    style = 'IN';

   l_state      hr_locations.loc_information16%TYPE;
*/
BEGIN/*
  l_procedure := g_package ||'check_pt_loc';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  IF p_location_id IS NULL THEN
    p_message_name :='PER_IN_NO_STATE_ENTERED';
    RETURN;
  ELSE
    OPEN csr_state;
    FETCH csr_state
    INTO  l_state;

    IF l_state IS NULL OR csr_state%NOTFOUND THEN
       p_message_name :='PER_IN_NO_STATE_ENTERED';
       RETURN;
    END IF;
    CLOSE csr_state;

    IF hr_general.decode_lookup('IN_PT_STATES',l_state) IS NULL THEN
      IF hr_general.decode_lookup('IN_STATES',l_state) IS NULL THEN
         p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
         p_token_name(1)  := 'VALUE';
         p_token_value(1) := l_state;
         p_token_name(2)  := 'FIELD';
         p_token_value(2) := 'P_STATE';
      END IF;
    END IF;

  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

EXCEPTION
     WHEN OTHERS THEN
       p_message_name   := 'PER_IN_ORACLE_GENERIC_ERROR';
       p_token_name(1)  := 'FUNCTION';
       p_token_value(1) := l_procedure;
       p_token_name(2)  := 'SQLERRMC';
       p_token_value(2) := sqlerrm;
       RETURN;*/
NULL;
END check_pt_loc;

--------------------------------------------------------------------------
-- Name           : check_pt_org_class                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Internal Proc to be called for validation           --
-- Parameters     :                                                     --
--             IN : p_organization_id      IN NUMBER                    --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27-Sep-04  statkar   Created this function                     --
--------------------------------------------------------------------------
PROCEDURE check_pt_org_class
            (p_organization_id  IN NUMBER
            ,p_calling_procedure  IN VARCHAR2
            ,p_message_name       OUT NOCOPY VARCHAR2
            ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
            ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type)
IS/*
   l_procedure  VARCHAR2(100);

  CURSOR csr_loc IS
   SELECT location_id
   FROM   hr_all_organization_units
   WHERE  organization_id = p_organization_id;

   l_location_id    hr_all_organization_units.location_id%TYPE;
*/
BEGIN/*
  l_procedure := g_package ||'check_pt_loc';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  OPEN csr_loc ;
  FETCH csr_loc
  INTO  l_location_id;
  pay_in_utils.set_location(g_debug,l_procedure,20);

  IF csr_loc%NOTFOUND THEN
    CLOSE csr_loc;
    pay_in_utils.set_location(g_debug,l_procedure,30);
    p_message_name := 'PER_IN_NO_STATE_ENTERED';
    RETURN;
  END IF;
  CLOSE csr_loc;

  pay_in_utils.set_location(g_debug,l_procedure,40);
  pay_in_prof_tax_pkg.check_pt_loc
                (p_organization_id   => p_organization_id
                ,p_location_id       => l_location_id
                ,p_calling_procedure => p_calling_procedure
                ,p_message_name      => p_message_name
                ,p_token_name        => p_token_name
                ,p_token_value       => p_token_value);

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);
  RETURN;

EXCEPTION
     WHEN OTHERS THEN
       p_message_name   := 'PER_IN_ORACLE_GENERIC_ERROR';
       p_token_name(1)  := 'FUNCTION';
       p_token_value(1) := l_procedure;
       p_token_name(2)  := 'SQLERRMC';
       p_token_value(2) := sqlerrm;
       RETURN;*/
NULL;
END check_pt_org_class;

--------------------------------------------------------------------------
-- Name           : check_pt_input                                      --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to check if future State changes for PT Org--
--                  present                                             --
-- Parameters     :                                                     --
--             IN : p_assignment_id        IN NUMBER                    --
--                  p_state                IN VARCHAR2                  --
--                  p_period_end_date      IN DATE                      --
--                  p_prorate_end_date     IN DATE                      --
--        IN  OUT : p_pt_salary            IN OUT  NUMBER               --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   15-Mar-05  abhjain   Created this function                     --
-- 1.1   10-Apr-05  abhjain   Used Asg record to check PT State update  --
--------------------------------------------------------------------------

FUNCTION check_pt_input
            (p_assignment_id      IN NUMBER
            ,p_state              IN VARCHAR2
            ,p_period_end_date    IN DATE
            ,p_prorate_end_date   IN DATE
            ,p_pt_salary          IN OUT NOCOPY NUMBER)
RETURN VARCHAR2 IS

  CURSOR csr_element_input_value(p_assignment_id    NUMBER
                                ,p_prorate_end_date DATE
                                ,p_period_end_date  DATE
                                ,p_state            VARCHAR2) IS
                SELECT '1'
                  FROM per_assignments_f      paf
                      ,hr_soft_coding_keyflex hsc
                 WHERE ((paf.effective_start_date BETWEEN (p_prorate_end_date+1) AND p_period_end_date)
                       OR (paf.effective_end_date BETWEEN (p_prorate_end_date+1) AND p_period_end_date))
                   AND paf.assignment_id = p_assignment_id
                   AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
                   AND pay_in_prof_tax_pkg.get_state(hsc.segment3) = p_state ;

  l_state_value VARCHAR2(240);
   l_procedure  VARCHAR2(100);

BEGIN
  l_procedure := g_package ||'check_pt_input';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  OPEN csr_element_input_value(p_assignment_id
                              ,p_prorate_end_date
                              ,p_period_end_date
                              ,p_state);
  FETCH csr_element_input_value INTO  l_state_value;
  IF csr_element_input_value%NOTFOUND THEN
    CLOSE csr_element_input_value;
    FOR i IN 1..g_count
    LOOP
      IF gPTTable(i).State = p_state THEN
        p_pt_salary := p_pt_salary + gPTTable(i).PT_Salary;
      END IF;
    END LOOP;

   pay_in_utils.set_location(g_debug,l_procedure,20);

    IF p_prorate_end_date = p_period_end_date THEN
      pay_in_utils.set_location(g_debug,l_procedure,30);
       g_count := 0;
    END IF;
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,35);
    RETURN 'N';
  ELSE
    pay_in_utils.set_location(g_debug,l_procedure,40);
    CLOSE csr_element_input_value;
    g_count := g_count + 1;
    gPTTable(g_count).State     := p_state;
    gPTTable(g_count).PT_Salary := p_pt_salary;
    IF p_prorate_end_date = p_period_end_date THEN
       g_count := 0;
    END IF;
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,45);
    RETURN 'Y';
  END IF;

END check_pt_input;

--------------------------------------------------------------------------
-- Name           : check_pt_state_end_date                             --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the if the PT State changes on the  --
--                  1st day of the next payroll period                  --
-- Parameters     :                                                     --
--             IN : p_assignment_id        IN NUMBER                    --
--                  p_end_date             IN DATE                      --
--                  p_state                IN VARCHAR2                  --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   15-Mar-05  abhjain   Created this function                     --
--------------------------------------------------------------------------
FUNCTION check_pt_state_end_date
            (p_assignment_id    IN NUMBER
            ,p_date             IN DATE
            ,p_state            IN VARCHAR2)
RETURN NUMBER IS
  CURSOR cur_element_end_date(p_assignment_id    NUMBER
                             ,p_date         DATE
                             ,p_state            VARCHAR2)
  IS
                SELECT 1
                  FROM per_assignments_f      paf
                      ,hr_soft_coding_keyflex hsc
                 WHERE (p_date + 1) between paf.effective_start_date and paf.effective_end_date
                   AND paf.assignment_id = p_assignment_id
                   AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
                   AND pay_in_prof_tax_pkg.get_state(hsc.segment3) = p_state ;

l_record_end_flag NUMBER ;
  l_procedure  VARCHAR2(100);

BEGIN
  l_procedure := g_package ||'check_pt_state_end_date';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  l_record_end_flag  := 0;

  OPEN cur_element_end_date(p_assignment_id
                           ,p_date
                           ,p_state);
  FETCH cur_element_end_date INTO l_record_end_flag;
  CLOSE cur_element_end_date;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,10);

  RETURN l_record_end_flag;

END check_pt_state_end_date;


--------------------------------------------------------------------------
-- Name           : CHECK_SRTC_STATE                                    --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Proc to be called for validation SRTC for Maharashtra-
-- Parameters     :                                                     --
--             IN : p_organization_id    IN NUMBER                      --
--                  p_org_information_id IN NUMBER                      --
--                  p_org_info_type_code IN VARCHAR2                    --
--                  p_srtc               IN VARCHAR2                    --
--                  p_calling_procedure  IN VARCHAR2                    --
--                  p_message_name       OUT VARCHAR2                   --
--                  p_token_name         OUT pay_in_utils.char_tab_type --
--                  p_token_value        OUT pay_in_utils.char_tab_type --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04-Jul-05  abhjain   Created this function                     --
--------------------------------------------------------------------------
PROCEDURE check_srtc_state
          (p_organization_id     IN NUMBER
          ,p_org_information_id  IN NUMBER
          ,p_org_info_type_code  IN VARCHAR2
          ,p_srtc                IN VARCHAR2
          ,p_calling_procedure   IN VARCHAR2
          ,p_message_name        OUT NOCOPY VARCHAR2
          ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
          ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type)
IS

   l_procedure  VARCHAR2(100);
   l_dummy      VARCHAR2(1);

BEGIN
  l_procedure := g_package ||'check_srtc_state';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);
--
-- Validations are as follows:
--
--  1. Check for mandatory parameters
--
--
  IF get_state(p_organization_id) = 'MH' AND
     p_srtc IS NULL THEN
     p_message_name := 'PER_IN_BSRTC_NO';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,20);

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);

END check_srtc_state;


--------------------------------------------------------------------------
-- Name           : GET_PROJECTED_PT                                    --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to find the projected PT value             --
-- Parameters     :                                                     --
--             IN : p_pt_dedn_ptd        IN NUMBER                      --
--                  p_lrpp               IN NUMBER                      --
--                  p_period_num         IN NUMBER                      --
--                  p_std_ptax           IN NUMBER                      --
--                  p_frequency          IN NUMBER                      --
--                  p_state              IN VARCHAR2                    --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   09-Jan-06  abhjain   Created this function                     --
--------------------------------------------------------------------------
FUNCTION get_projected_pt
        (p_pt_dedn_ptd      IN NUMBER
        ,p_lrpp             IN NUMBER
        ,p_period_num       IN NUMBER
        ,p_std_ptax         IN NUMBER
        ,p_frequency        IN NUMBER
        ,p_state            IN VARCHAR2)
RETURN NUMBER is

l_pt_projected NUMBER;
   l_procedure  VARCHAR2(100);

BEGIN
  l_procedure := g_package ||'get_projected_pt';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_pt_projected := 0;

  l_pt_projected := p_pt_dedn_ptd * (p_lrpp); -- Projection till the remaining pay periods

  -- For MH state, if the PT deducted in Feb is 300 then the projected value should be 200
  IF p_state = 'MH' and p_period_num = 11 and p_pt_dedn_ptd = 300 THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     l_pt_projected := 200 * p_lrpp;
  END IF;

  -- For TN state, in Jan remaining entire PT is deducted, so no need of projection
  IF SUBSTR(p_state,1,2) = 'TN' and p_period_num > 9 THEN
     pay_in_utils.set_location(g_debug,l_procedure,30);
    l_pt_projected := 0;
  END IF;

  -- For TN state, in Aug remaining entire PT for the half year is deducted, so need to project accordingly
  IF SUBSTR(p_state,1,2) = 'TN' and (p_period_num = 5 OR p_period_num = 6) THEN
     pay_in_utils.set_location(g_debug,l_procedure,40);
    l_pt_projected  := p_std_ptax;
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
  RETURN l_pt_projected;

END get_projected_pt;

BEGIN

   g_package   :='pay_in_prof_tax_pkg.';

END pay_in_prof_tax_pkg;

/
