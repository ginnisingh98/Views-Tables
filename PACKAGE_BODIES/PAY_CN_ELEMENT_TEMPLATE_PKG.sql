--------------------------------------------------------
--  DDL for Package Body PAY_CN_ELEMENT_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_ELEMENT_TEMPLATE_PKG" AS
/* $Header: pycneltp.pkb 120.0 2005/05/29 03:59 appldev noship $ */

   g_package     CONSTANT VARCHAR2(100) := 'pay_cn_element_template_pkg.';
   g_debug       BOOLEAN;
   g_templates_setup         t_results_setup_tab;
   g_results_setup           t_form_results_tab;
   g_count                   NUMBER;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_FORMULA_ID                                      --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to a get the formula id based on the      --
--                  formula name and effective date                     --
--                                                                      --
-- Parameters     : Inputs:  p_formula_name    VARCHAR2                 --
--                           p_effective_date  DATE                     --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   26-May-05  snekkala  Created this Procedure                    --
--------------------------------------------------------------------------
FUNCTION  get_formula_id
         (p_effective_date   IN VARCHAR2
         ,p_formula_name     IN VARCHAR2
         )
RETURN NUMBER
IS
   l_formula_id ff_formulas_f.formula_id%TYPE ;
BEGIN

   SELECT formula_id
   INTO   l_formula_id
   FROM   ff_formulas_f
   WHERE  legislation_code = 'CN'
   AND    formula_name = p_formula_name
   AND    p_effective_date  BETWEEN effective_start_Date AND effective_end_date;

   RETURN l_formula_id;

END get_formula_id;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : INIT_CODE                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to a global structure with all the        --
--                  formula related meta-data                           --
--                                                                      --
-- Parameters     : None                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   21-Apr-05  snekkala  Created this Procedure                    --
-- 1.1   06-May-05  snekkala  Modified the procedure to remove Nested   --
--                            Tables                                    --
--------------------------------------------------------------------------
PROCEDURE init_code
IS

BEGIN
--
-- Element Template Setup for Special Payments
--
     g_templates_setup(1).template_name  := 'Special Payments';
     g_templates_setup(1).category       := 'Special Payments';
     g_templates_setup(1).formula_name   := 'CN_SPECIAL_PAYMENTS';
     g_templates_setup(1).status_rule_id := NULL;
     g_templates_setup(1).fr_count       := 11;
     g_templates_setup(1).fr_set_index   := 1;

     g_results_setup(1).result_name      := 'L_NORMAL_AMOUNT';
     g_results_setup(1).result_rule_type := 'I';
     g_results_setup(1).input_value_name := 'Pay Value';
     g_results_setup(1).element_name     := 'Special Payments Normal';
     g_results_setup(1).severity_level   := NULL;

     g_results_setup(2).result_name      := 'L_NORMAL_AMOUNT';
     g_results_setup(2).result_rule_type := 'I';
     g_results_setup(2).input_value_name := 'Process Normal Amount';
     g_results_setup(2).element_name     := 'Special Payments Normal';
     g_results_setup(2).severity_level   := NULL;

     g_results_setup(3).result_name      := 'L_JURISDICTION';
     g_results_setup(3).result_rule_type := 'I';
     g_results_setup(3).input_value_name := 'Jurisdiction';
     g_results_setup(3).element_name     := 'Special Payments Normal';
     g_results_setup(3).severity_level   := NULL;

     g_results_setup(4).result_name      := 'L_SEPARATE_AMOUNT';
     g_results_setup(4).result_rule_type := 'I';
     g_results_setup(4).input_value_name := 'Process Separate Amount';
     g_results_setup(4).element_name     := 'Special Payments Separate';
     g_results_setup(4).severity_level   := NULL;

     g_results_setup(5).result_name      := 'L_SEP_JURISDICTION';
     g_results_setup(5).result_rule_type := 'I';
     g_results_setup(5).input_value_name := 'Jurisdiction';
     g_results_setup(5).element_name     := 'Special Payments Separate';
     g_results_setup(5).severity_level   := NULL;

     g_results_setup(6).result_name      := 'L_SPREAD_AMOUNT';
     g_results_setup(6).result_rule_type := 'I';
     g_results_setup(6).input_value_name := 'Process Spread Amount';
     g_results_setup(6).element_name     := 'Special Payments Spread';
     g_results_setup(6).severity_level   := NULL;

     g_results_setup(7).result_name      := 'L_NUMBER_OF_PERIODS';
     g_results_setup(7).result_rule_type := 'I';
     g_results_setup(7).input_value_name := 'Number of Periods';
     g_results_setup(7).element_name     := 'Special Payments Spread';
     g_results_setup(7).severity_level   := NULL;

     g_results_setup(8).result_name      := 'L_BASE';
     g_results_setup(8).result_rule_type := 'I';
     g_results_setup(8).input_value_name := 'Base Value';
     g_results_setup(8).element_name     := 'Special Payments Spread';
     g_results_setup(8).severity_level   := NULL;

     g_results_setup(9).result_name      := 'L_SPR_JURISDICTION';
     g_results_setup(9).result_rule_type := 'I';
     g_results_setup(9).input_value_name := 'Jurisdiction';
     g_results_setup(9).element_name     := 'Special Payments Spread';
     g_results_setup(9).severity_level   := NULL;

     g_results_setup(10).result_name      := 'L_PAYMENT_AMOUNT';
     g_results_setup(10).result_rule_type := 'D';
     g_results_setup(10).input_value_name := 'Pay Value';
     g_results_setup(10).element_name     := NULL;
     g_results_setup(10).severity_level   := NULL;

     g_results_setup(11).result_name      := 'L_ERROR_MESSAGE';
     g_results_setup(11).result_rule_type := 'M';
     g_results_setup(11).input_value_name := NULL;
     g_results_setup(11).element_name     := NULL;
     g_results_setup(11).severity_level   := 'F';

--
-- Element Template Setup for yearly Tax Calculation
--
     g_templates_setup(2).template_name  := 'Variable Yearly Earnings';
     g_templates_setup(2).category       := 'Variable Yearly Earnings';
     g_templates_setup(2).formula_name   := 'CN_YRLY_EARNINGS_XFER';
     g_templates_setup(2).status_rule_id := NULL;
     g_templates_setup(2).fr_count       := 5;
     g_templates_setup(2).fr_set_index   := 12;

     g_results_setup(12).result_name      := 'L_PREV_JURISDICTION';
     g_results_setup(12).result_rule_type := 'I';
     g_results_setup(12).input_value_name := 'Jurisdiction';
     g_results_setup(12).element_name     := 'Previous Year Variable Earnings';
     g_results_setup(12).severity_level   := NULL;

     g_results_setup(13).result_name      := 'L_PREV_YEAR_VARIABLE_EARNINGS';
     g_results_setup(13).result_rule_type := 'I';
     g_results_setup(13).input_value_name := 'Payment Amount';
     g_results_setup(13).element_name     := 'Previous Year Variable Earnings';
     g_results_setup(13).severity_level   := NULL;

     g_results_setup(14).result_name      := 'L_CURR_JURISDICTION';
     g_results_setup(14).result_rule_type := 'I';
     g_results_setup(14).input_value_name := 'Jurisdiction';
     g_results_setup(14).element_name     := 'Current Year Variable Earnings';
     g_results_setup(14).severity_level   := NULL;

     g_results_setup(15).result_name      := 'L_CURR_YEAR_VARIABLE_EARNINGS';
     g_results_setup(15).result_rule_type := 'I';
     g_results_setup(15).input_value_name := 'Payment Amount';
     g_results_setup(15).element_name     := 'Current Year Variable Earnings';
     g_results_setup(15).severity_level   := NULL;

     g_results_setup(16).result_name      := 'L_PAYMENT_AMOUNT';
     g_results_setup(16).result_rule_type := 'D';
     g_results_setup(16).input_value_name := 'Pay Value';
     g_results_setup(16).element_name     := NULL;
     g_results_setup(16).severity_level   := NULL;

     g_count := 2;
END init_code;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_RESULTS_SETUP                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Accepts the Template Name as input and return the   --
--                  Results Setup                                       --
--                                                                      --
-- Parameters     : None                                                --
--        IN      : p_template_name         VARCHAR2                    --
--        OUT     : p_results_setup         t_fr_setup_rec              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   21-Apr-05  snekkala  Created this Procedure                    --
-- 1.1   06-May-05  snekkala  Modified the procedure to remove Nested   --
--                            Tables                                    --
-- 1.2   26-May-05  snekkala  Restructured the code.                    --
--------------------------------------------------------------------------
PROCEDURE get_results_setup
       (p_template_name    IN   VARCHAR2
       ,p_results_setup    OUT  NOCOPY t_fr_setup_rec
       )
IS
  l_procedure      CONSTANT VARCHAR2(100):= g_package||'get_results_setup';

BEGIN
   hr_cn_api.set_location(g_debug,'Entering : '||l_procedure,10);

   init_code;

   hr_cn_api.set_location(g_debug,l_procedure,20);

   FOR i IN 1..g_count
   LOOP

       IF (g_templates_setup(i).template_name = p_template_name) THEN

             hr_cn_api.set_location(g_debug,'CHINA: Found match '||i||' for Template '||p_template_name,25);

             p_results_setup.template_name  := g_templates_setup(i).template_name;
             p_results_setup.category       := g_templates_setup(i).category;
             p_results_setup.formula_name   := g_templates_setup(i).formula_name;
             p_results_setup.fr_count       := g_templates_setup(i).fr_count;
             p_results_setup.status_rule_id := g_templates_setup(i).status_rule_id;
             p_results_setup.fr_set_index   := g_templates_setup(i).fr_set_index;

         IF g_debug THEN
           hr_utility.trace('CHINA: template_name  : '||p_results_setup.template_name);
           hr_utility.trace('CHINA: category       : '||p_results_setup.category);
           hr_utility.trace('CHINA: formula_name   : '||p_results_setup.formula_name);
           hr_utility.trace('CHINA: fr_count       : '||p_results_setup.fr_count);
           hr_utility.trace('CHINA: status_rule_id : '||p_results_setup.status_rule_id);
           hr_utility.trace('CHINA: fr_set_index   : '||p_results_setup.fr_set_index);
         END IF ;
      END IF;
  END LOOP;

  hr_cn_api.set_location(g_debug,'Leaving : '||l_procedure,30);

END get_results_setup;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : INS_FORM_RES_RULE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to insert the formula result.             --
--                                                                      --
-- Parameters     : Inputs:  p_business_group_id     NUMBER             --
--                           p_effective_date        DATE               --
--                           p_status_processing_rule_id  NUMBER        --
--                           p_result_name                VARCHAR2      --
--                           p_result_rule_type           VARCHAR2      --
--                           p_element_name               VARCHAR2      --
--                           p_input_value_name           VARCHAR2      --
--                           p_severity_level             VARCHAR2      --
--                           p_element_type_id            NUMBER        --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   26-May-05  snekkala  Created this Procedure                    --
--------------------------------------------------------------------------
PROCEDURE ins_form_res_rule
 (
  p_business_group_id          IN NUMBER,
  p_effective_date             IN DATE ,
  p_status_processing_rule_id  IN NUMBER,
  p_result_name                IN VARCHAR2,
  p_result_rule_type           IN VARCHAR2,
  p_element_name               IN VARCHAR2 DEFAULT NULL,
  p_input_value_name           IN VARCHAR2 DEFAULT NULL,
  p_severity_level             IN VARCHAR2 DEFAULT NULL,
  p_element_type_id            IN NUMBER   DEFAULT NULL
 )
 IS

  c_end_of_time       CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');
  v_form_res_rule_id  pay_formula_result_rules_f.formula_result_rule_id%TYPE;
  l_input_value_id    pay_formula_result_rules_f.input_value_id%TYPE;
  l_element_type_id   pay_element_types_f.element_type_id%TYPE;
 BEGIN

  IF p_result_rule_type  = 'D' THEN

     SELECT input_value_id
     INTO   l_input_value_id
     FROM   pay_input_values_f
     WHERE  p_effective_date BETWEEN effective_start_date
                             AND     effective_end_date
     AND    business_group_id = p_business_group_id
     AND    element_type_id   = p_element_type_id
     AND    NAME              = p_input_value_name;

  ELSIF p_result_rule_type = 'I' THEN

     SELECT piv.input_value_id
          , pet.element_type_id
     INTO   l_input_value_id
          , l_element_type_id
     FROM   pay_input_values_f piv, pay_element_types_f pet
     WHERE  p_effective_date BETWEEN piv.effective_start_date
                             AND     piv.effective_end_date
     AND    p_effective_date BETWEEN pet.effective_start_date
                             AND     pet.effective_end_date
     AND    piv.legislation_code  = 'CN'
     AND    pet.legislation_code  = 'CN'
     AND    pet.element_name      = p_element_name
     AND    piv.NAME              = p_input_value_name
     AND    pet.element_type_id   = piv.element_type_id;

  END IF;

 SELECT pay_formula_result_rules_s.nextval
   INTO   v_form_res_rule_id
   FROM   sys.dual;

  INSERT INTO pay_formula_result_rules_f
   (formula_result_rule_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    status_processing_rule_id,
    result_name,
    result_rule_type,
    severity_level,
    input_value_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date,
    element_type_id)
   VALUES
   (v_form_res_rule_id,
    p_effective_date,
    c_end_of_time,
    p_business_group_id,
    p_status_processing_rule_id,
    upper(p_result_name),
    p_result_rule_type,
    p_severity_level,
    l_input_value_id,
    trunc(sysdate),
    -1,
    -1,
    -1,
    trunc(sysdate),
    decode(p_result_rule_type,'I',l_element_type_id,null));

END ins_form_res_rule;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : ELEMENT_TEMPLATE_POST_PROCESS                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Accepts the Template Name as input and return the   --
--                  Results Setup                                       --
--                                                                      --
-- Parameters     : None                                                --
--        IN      : p_template_id           NUMBER                      --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   21-Apr-05  snekkala  Created this Procedure                    --
-- 1.0   06-May-05  snekkala  Modified the code to remove nested tables --
--------------------------------------------------------------------------
PROCEDURE element_template_post_process
          (p_template_id    IN NUMBER)
IS

   CURSOR csr_template IS
     SELECT template_name
     FROM   pay_element_templates
     WHERE  template_id = p_template_id;

   l_template_name   pay_element_templates.template_name%TYPE;

  CURSOR csr_set IS
    SELECT  pet.element_type_id
           ,pet.business_group_id
           ,pet.effective_start_date
           ,pet.object_version_number
    FROM    pay_element_types_f pet
           ,pay_element_templates tmp
    WHERE   pet.element_name  = tmp.base_name
    AND     tmp.template_id   = p_template_id;

  l_element_type_id         pay_element_types.element_type_id%TYPE;
  l_business_group_id       pay_element_types.business_group_id%TYPE;
  l_effective_date          DATE;
  l_element_ovn             pay_element_types_f.object_version_number%TYPE;

  l_st_start_date         DATE ;
  l_st_end_date           DATE ;
  l_st_ovn                pay_status_processing_rules_f.object_version_number%TYPE;
  l_st_warn               BOOLEAN ;
  l_results_setup         t_fr_setup_rec;
  l_formula_setup         t_form_results_tab;

  l_procedure              VARCHAR2 (100);
  j                        PLS_INTEGER ;

BEGIN

   g_debug := hr_utility.debug_enabled;
   l_procedure := g_package ||'element_template_post_process';


   hr_cn_api.set_location(g_debug,'Entering : '||l_procedure,10);
   OPEN  csr_template;
   FETCH csr_template
   INTO  l_template_name;
   CLOSE csr_template;

   hr_cn_api.set_location(g_debug,l_procedure,20);
   IF g_debug THEN
      hr_utility.trace ('CHINA: Template Name  : '||l_template_name);
   END IF ;

   get_results_setup
         (p_template_name    => l_template_name
         ,p_results_setup    => l_results_setup
         );


   hr_cn_api.set_location(g_debug,l_procedure,30);
   OPEN csr_set;
   FETCH csr_set
   INTO l_element_type_id
       ,l_business_group_id
       ,l_effective_date
       ,l_element_ovn;
   CLOSE csr_set;

   hr_cn_api.set_location(g_debug,l_procedure,40);

   pay_status_processing_rule_api.create_status_process_rule
     (
         p_effective_date              => l_effective_date
        ,p_element_type_id             => l_element_type_id
        ,p_business_group_id           => l_business_group_id
        ,p_formula_id                  => get_formula_id(l_effective_date, l_results_setup.formula_name)
        ,p_status_processing_rule_id   => l_results_setup.status_rule_id
        ,p_effective_start_date        => l_st_start_date
        ,p_effective_end_date          => l_st_end_date
        ,p_object_version_number       => l_st_ovn
        ,p_formula_mismatch_warning    => l_st_warn
     );

    hr_cn_api.set_location(g_debug,l_procedure,50);

    FOR i IN 1..l_results_setup.fr_count
    LOOP

       hr_cn_api.set_location(g_debug,l_procedure||'--'||i,55);

       j := l_results_setup.fr_set_index+i-1;
       hr_utility.trace('CHINA: Value of i is '||i);
       hr_utility.trace('CHINA: Value of j is '||j);

       l_formula_setup(i).result_name       := g_results_setup(j).result_name ;
       l_formula_setup(i).result_rule_type  := g_results_setup(j).result_rule_type;
       l_formula_setup(i).input_value_name  := g_results_setup(j).input_value_name ;
       l_formula_setup(i).element_name      := g_results_setup(j).element_name ;
       l_formula_setup(i).severity_level    := g_results_setup(j).severity_level ;

       IF g_debug THEN
          hr_utility.trace('CHINA: result_name       : '||l_formula_setup(i).result_name);
          hr_utility.trace('CHINA: result_rule_type  : '||l_formula_setup(i).result_rule_type);
          hr_utility.trace('CHINA: input_value_name  : '||l_formula_setup(i).input_value_name);
          hr_utility.trace('CHINA: element_name      : '||l_formula_setup(i).element_name);
          hr_utility.trace('CHINA: severity_level    : '||l_formula_setup(i).severity_level);
       END IF;

       ins_form_res_rule
         (
           p_business_group_id         => l_business_group_id
          ,p_effective_date            => l_effective_date
          ,p_status_processing_rule_id => l_results_setup.status_rule_id
          ,p_input_value_name          => l_formula_setup(i).input_value_name
          ,p_element_name              => l_formula_setup(i).element_name
          ,p_result_name               => l_formula_setup(i).result_name
          ,p_result_rule_type          => l_formula_setup(i).result_rule_type
          ,p_severity_level            => l_formula_setup(i).severity_level
          ,p_element_type_id           => l_element_type_id
         );

    END LOOP;

    hr_cn_api.set_location(g_debug,'Leaving : '||l_procedure,60);

END element_template_post_process;

END pay_cn_element_template_pkg;

/
