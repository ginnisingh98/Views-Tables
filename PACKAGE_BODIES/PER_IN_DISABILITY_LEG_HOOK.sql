--------------------------------------------------------
--  DDL for Package Body PER_IN_DISABILITY_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_DISABILITY_LEG_HOOK" AS
/* $Header: peinlhdi.pkb 120.3 2007/09/25 11:54:29 rsaharay ship $ */
--
--
-- Globals
--
g_package         constant VARCHAR2(100) := 'per_in_disability_leg_hook.' ;
g_debug           BOOLEAN ;
g_message_name    VARCHAR2(30);
g_token_name      pay_in_utils.char_tab_type;
g_token_value     pay_in_utils.char_tab_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : EMP_DISABILITY_INT                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Internal Procedure for IN localization              --
-- Parameters     :                                                     --
--             IN : p_effective_date  DATE                              --
--                  p_person_id       NUMBER                            --
--                  p_category        VARCHAR2                          --
--                  p_status          VARCHAR2                          --
--                  p_degree          NUMBER                            --
--                  p_dis_information1 VARCHAR2                         --
--                  p_calling_procedure VARCHAR2                        --
--                                                                      --
--            OUT : p_message_name  VARCHAR2                            --
--                  p_token_name    VARCHAR2                            --
--                  p_token_value   VARCHAR2                            --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   24-Nov-04  vgsriniv 3994151  Created this procedure            --
-- 1.1   26-Nov-04  vgsriniv 3994151  Corrected the message call        --
-- 1.2   25-Apr-05  vgsriniv 4251141  Made a call to pay_in_tax_        --
--                                    declaration.declare_section80u    --
-- 1.3   25-Sep-07  rsaharay 6401091  Added primary_flag join in        --
--                                    cursor c_asg_details              --
--------------------------------------------------------------------------
PROCEDURE emp_disability_int
             (p_effective_date          IN DATE
	     ,p_person_id               IN NUMBER
	     ,p_category                IN VARCHAR2
	     ,p_status                  IN VARCHAR2
	     ,p_degree                  IN NUMBER
	     ,p_dis_information1        IN VARCHAR2
             ,p_calling_procedure       IN VARCHAR2
       	     ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type)
IS

--
l_procedure            VARCHAR2(100);
l_message              VARCHAR2(255);
l_assignment_id        per_assignments_f.assignment_id%TYPE;
l_pension_fund_80ccc   NUMBER;
l_med_ins_prem_80d     NUMBER;
l_80ddb_sr             VARCHAR2(5);
l_disease_trt          NUMBER;
l_80d_sr               VARCHAR2(5);
l_edu_80e              NUMBER;
l_claim_80gg           VARCHAR2(5);
l_don_80gga            NUMBER;
l_inv_80l              NUMBER;
l_sec_80l              NUMBER;
l_date                 DATE;
l_warning              BOOLEAN;
l_payroll_id           per_assignments_f.payroll_id%TYPE;
l_element_entry_id     NUMBER;


   CURSOR c_asg_details IS
   SELECT assignment_id
     FROM per_assignments_f
    WHERE person_id = p_person_id
      AND primary_flag = 'Y'
      AND p_effective_date BETWEEN effective_start_date
                               AND effective_end_date;

--
BEGIN
--
  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package || 'emp_disability_int';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date',p_effective_date);
     pay_in_utils.trace('p_person_id',p_person_id);
     pay_in_utils.trace('p_category',p_category);
     pay_in_utils.trace('p_status',p_status);
     pay_in_utils.trace('p_degree',p_degree);
     pay_in_utils.trace('p_dis_information1',p_dis_information1);
     pay_in_utils.trace('p_calling_procedure',p_calling_procedure);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.null_message(p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  --
  pay_in_utils.set_location(g_debug, l_procedure, 20);
  --
  OPEN c_asg_details;
  FETCH c_asg_details INTO l_assignment_id;
  CLOSE c_asg_details;
  --
  pay_in_utils.set_location(g_debug, l_procedure, 30);
  --

  IF p_dis_information1 = 'Y' AND
     p_degree >= 40 AND
     p_category IN ('BLIND','SA_VIS_IMP','LC','SA_HEA_IMP','LD','07','MI','AU','CP','MD')
  THEN
     --
     pay_in_utils.set_location(g_debug, l_procedure, 50);
     --

    pay_in_tax_declaration.declare_section80u
     (p_assignment_id                   => l_assignment_id
     ,p_effective_date                  => p_effective_date
     ,p_warnings                        => l_warning
     );
     --
     pay_in_utils.set_location(g_debug, l_procedure, 60);
     --
  END IF;
  pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure, 100);

END emp_disability_int;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : EMP_DISABILITY_CREATE                               --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
-- Parameters     :                                                     --
--             IN : p_effective_date   DATE                             --
--                  p_person_id        NUMBER                           --
--                  p_category         VARCHAR2                         --
--                  p_status           VARCHAR2                         --
--                  p_degree           NUMBER                           --
--                  p_dis_information1 VARCHAR2                         --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   24-Nov-04  vgsriniv 3994151  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE emp_disability_create
             (p_effective_date   IN DATE
	     ,p_person_id        IN NUMBER
	     ,p_category         IN VARCHAR2
	     ,p_status           IN VARCHAR2
	     ,p_degree           IN NUMBER
	     ,p_dis_information1 IN VARCHAR2
	     )
IS
--

l_procedure    VARCHAR2(100);
l_message      VARCHAR2(255);

--
BEGIN
--
  g_debug := hr_utility.debug_enabled ;

  l_procedure := g_package || 'emp_disability_create' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  g_message_name := 'SUCCESS';
  pay_in_utils.null_message (g_token_name, g_token_value);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date',p_effective_date);
     pay_in_utils.trace('p_person_id',p_person_id);
     pay_in_utils.trace('p_category',p_category);
     pay_in_utils.trace('p_status',p_status);
     pay_in_utils.trace('p_degree',p_degree);
     pay_in_utils.trace('p_dis_information1',p_dis_information1);
     pay_in_utils.trace('**************************************************','********************');
  END IF;
  --
  -- Check if PAY is installed for India Localization
  --
  IF hr_utility.chk_product_install('Oracle Payroll','IN') THEN

     pay_in_utils.set_location(g_debug,l_procedure,20);

     emp_disability_int
             (p_effective_date          => p_effective_date
	     ,p_person_id               => p_person_id
	     ,p_category                => p_category
	     ,p_status                  => p_status
	     ,p_degree                  => p_degree
	     ,p_dis_information1        => p_dis_information1
	     ,p_calling_procedure       => l_procedure
	     ,p_message_name            => g_message_name
	     ,p_token_name              => g_token_name
             ,p_token_value             => g_token_value
	     );

  --
  END IF ;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
  pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);
--
END emp_disability_create;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : EMP_DISABILITY_UPDATE                               --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
-- Parameters     :                                                     --
--             IN : p_effective_date   DATE                             --
--                  p_disability_id    NUMBER                           --
--                  p_category         VARCHAR2                         --
--                  p_status           VARCHAR2                         --
--                  p_degree           NUMBER                           --
--                  p_dis_information1 VARCHAR2                         --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   24-Nov-04  vgsriniv 3994151  Created this procedure            --
--------------------------------------------------------------------------

PROCEDURE emp_disability_update
             (p_effective_date   IN DATE
             ,p_disability_id    IN NUMBER
	     ,p_category         IN VARCHAR2
             ,p_status           IN VARCHAR2
             ,p_degree           IN NUMBER
             ,p_dis_information1 IN VARCHAR2
	     )
IS
--
l_procedure         VARCHAR2(100);
l_message           VARCHAR2(255);
l_person_id         per_disabilities_f.person_id%TYPE;
l_category          VARCHAR2(20);
l_status            VARCHAR2(20);
l_degree            NUMBER;
l_dis_information1  VARCHAR2(3);
--

CURSOR c_person_id IS
SELECT person_id,category,status,degree,dis_information1
  FROM per_disabilities_f
 WHERE disability_id = p_disability_id
   AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

BEGIN
--
  g_debug := hr_utility.debug_enabled ;

  l_procedure := g_package || 'emp_disability_update' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  g_message_name := 'SUCCESS';
  pay_in_utils.null_message (g_token_name, g_token_value);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date',p_effective_date);
     pay_in_utils.trace('p_disability_id',p_disability_id);
     pay_in_utils.trace('p_category',p_category);
     pay_in_utils.trace('p_status',p_status);
     pay_in_utils.trace('p_degree',p_degree);
     pay_in_utils.trace('p_dis_information1',p_dis_information1);
     pay_in_utils.trace('**************************************************','********************');
  END IF;
  --
  -- Check if PAY is installed for India Localization
  --
  IF hr_utility.chk_product_install('Oracle Payroll','IN') THEN

     pay_in_utils.set_location(g_debug,l_procedure,20);

     OPEN c_person_id;
     FETCH c_person_id INTO l_person_id,l_category,l_status,l_degree,l_dis_information1;
     CLOSE c_person_id;

     pay_in_utils.set_location(g_debug,l_procedure,30);

     IF p_category <> hr_api.g_varchar2 THEN
       l_category := p_category;
     END IF;

     IF l_status <> hr_api.g_varchar2 THEN
       l_status := p_status;
     END IF;

     IF p_degree <> hr_api.g_number THEN
       l_degree := p_degree;
     END IF;

     IF p_dis_information1 <> hr_api.g_varchar2 THEN
       l_dis_information1 := p_dis_information1;
     END IF;

     emp_disability_int
             (p_effective_date          => p_effective_date
	     ,p_person_id               => l_person_id
	     ,p_category                => l_category
	     ,p_status                  => l_status
	     ,p_degree                  => l_degree
	     ,p_dis_information1        => l_dis_information1
	     ,p_calling_procedure       => l_procedure
	     ,p_message_name            => g_message_name
	     ,p_token_name              => g_token_name
             ,p_token_value             => g_token_value
	     );


  --
  END IF ;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
  pay_in_utils.raise_message(800, g_message_name, g_token_name, g_token_value);
--
END emp_disability_update;

END per_in_disability_leg_hook;

/
