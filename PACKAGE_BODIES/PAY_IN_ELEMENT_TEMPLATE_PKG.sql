--------------------------------------------------------
--  DDL for Package Body PAY_IN_ELEMENT_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_ELEMENT_TEMPLATE_PKG" AS
/* $Header: pyineltm.pkb 120.27.12010000.3 2009/05/27 11:13:43 mdubasi ship $ */

/*========================================================================
  Global Variables
========================================================================*/
   g_debug      BOOLEAN;

/*========================================================================
  Private Functions
========================================================================*/
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Name           : GET_EXCLUSION_RULE_ID                               --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
FUNCTION get_exclusion_rule_id
          (p_template_rec    IN pay_in_etw_struct.t_template_setup_rec
          ,p_exclusion_tag   IN VARCHAR2
          )
RETURN NUMBER
IS

   l_procedure     VARCHAR2(100):= g_package||'get_exclusion_rule_id';
   l_message       VARCHAR2(1000);
BEGIN
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF p_exclusion_tag IS NULL THEN
        pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

        RETURN TO_NUMBER(NULL);
    END IF ;

    FOR i IN p_template_rec.er_setup.FIRST
           ..p_template_rec.er_setup.LAST
    LOOP

        IF p_template_rec.er_setup(i).tag = p_exclusion_tag
        THEN
	    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

            RETURN p_template_rec.er_setup(i).rule_id;
        END IF ;

    END LOOP;
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

    RETURN TO_NUMBER(NULL);

EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,50);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END get_exclusion_rule_id;

--------------------------------------------------------------------------
-- Name           : GET_IV_ID                                           --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the iv_id of base element        --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
FUNCTION get_iv_id
          (p_template_rec    IN pay_in_etw_struct.t_template_setup_rec
          ,p_input_value     IN VARCHAR2
          )
RETURN NUMBER
IS
   l_procedure     VARCHAR2(100):= g_package||'get_iv_id';
   l_message       VARCHAR2(1000);

BEGIN
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    FOR i IN p_template_rec.iv_setup.FIRST
           ..p_template_rec.iv_setup.LAST
    LOOP
        IF p_template_rec.iv_setup(i).input_value_name
                       = p_input_value
        THEN
	    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

            RETURN p_template_rec.iv_setup(i).input_value_id;
        END IF ;

    END LOOP;
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

    RETURN TO_NUMBER(NULL);

EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,40);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END get_iv_id;

--------------------------------------------------------------------------
-- Name           : GET_AET_ID                                          --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the Additional Element Type Id   --
-- Parameters     :                                                     --
--             IN : p_template_rec       VARCHAR2                       --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
FUNCTION get_aet_id
          (p_template_rec    IN pay_in_etw_struct.t_template_setup_rec
          ,p_element_name    IN VARCHAR2
          )
RETURN NUMBER
IS

   l_procedure     VARCHAR2(100):= g_package||'get_aet_id';
   l_message       VARCHAR2(1000);

BEGIN
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    FOR i IN p_template_rec.ae_setup.FIRST
           ..p_template_rec.ae_setup.LAST
    LOOP
        IF p_template_rec.ae_setup(i).element_name
                       = p_element_name
        THEN
	    pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,20);

            RETURN p_template_rec.ae_setup(i).element_id;
        END IF ;

    END LOOP;
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,30);

    RETURN TO_NUMBER(NULL);

EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,40);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;
END get_aet_id;

--------------------------------------------------------------------------
-- Name           : GET_AIV_ID                                          --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the iv_id of additional elements --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
FUNCTION get_aiv_id
          (p_template_rec    IN pay_in_etw_struct.t_template_setup_rec
	  ,p_element_id      IN NUMBER
          ,p_input_value     IN VARCHAR2
          )
RETURN NUMBER
IS
   l_procedure     VARCHAR2(100):= g_package||'get_aiv_id';
   l_message       VARCHAR2(1000);

BEGIN
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    FOR i IN p_template_rec.ae_setup.FIRST
           ..p_template_rec.ae_setup.LAST
    LOOP
       IF p_template_rec.ae_setup(i).element_id = p_element_id
       THEN

          FOR j IN p_template_rec.ae_setup(i).iv_setup.FIRST
	         ..p_template_rec.ae_setup(i).iv_setup.LAST
          LOOP
             IF p_template_rec.ae_setup(i).iv_setup(j).input_value_name
	        = p_input_value
	     THEN
                 pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,20);

                RETURN p_template_rec.ae_setup(i).iv_setup(j).input_value_id;
             END IF ;
	  END LOOP ;
       END IF ;
    END LOOP;

    pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,30);

    RETURN TO_NUMBER(NULL);

EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,40);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END get_aiv_id;


--------------------------------------------------------------------------
-- Name           : GET_TEXT                                            --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
FUNCTION get_text (p_formula_name IN VARCHAR2)
RETURN VARCHAR2
IS
   l_procedure         CONSTANT VARCHAR2(100):= g_package||'get_text';
   l_message       VARCHAR2(1000);

BEGIN
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    FOR i IN 1..pay_in_etw_struct.g_formula_obj.COUNT
    LOOP

       IF pay_in_etw_struct.g_formula_obj(i).NAME = p_formula_name
       THEN
          pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,20);

          RETURN pay_in_etw_struct.g_formula_obj(i).text;
       END IF;

    END LOOP;
    pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,30);

    RETURN NULL;

EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,40);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END get_text;

/*========================================================================
  Private Procedures
========================================================================*/
--------------------------------------------------------------------------
-- Name           : GET_ELEMENT_TEMPLATE                                --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE get_element_template
  (p_template_id            IN  NUMBER
  ,p_element_template       OUT NOCOPY pay_etm_shd.g_rec_type
  )
IS
   l_procedure     VARCHAR2(100):= g_package||'get_element_template';
   l_message       VARCHAR2(1000);

  CURSOR csr_element_template(p_template_id IN NUMBER)
  IS
    SELECT
      template_id,
      template_type,
      template_name,
      base_processing_priority,
      business_group_id,
      legislation_code,
      version_number,
      base_name,
      max_base_name_length,
      configuration_info_category,
      configuration_information1,
      configuration_information2,
      configuration_information3,
      configuration_information4,
      configuration_information5,
      configuration_information6,
      configuration_information7,
      configuration_information8,
      configuration_information9,
      configuration_information10,
      configuration_information11,
      configuration_information12,
      configuration_information13,
      configuration_information14,
      configuration_information15,
      configuration_information16,
      configuration_information17,
      configuration_information18,
      configuration_information19,
      configuration_information20,
      configuration_information21,
      configuration_information22,
      configuration_information23,
      configuration_information24,
      configuration_information25,
      configuration_information26,
      configuration_information27,
      configuration_information28,
      configuration_information29,
      configuration_information30,
      configuration_info_category,
      configuration_information1,
      configuration_information2,
      configuration_information3,
      configuration_information4,
      configuration_information5,
      configuration_information6,
      configuration_information7,
      configuration_information8,
      configuration_information9,
      configuration_information10,
      configuration_information11,
      configuration_information12,
      configuration_information13,
      configuration_information14,
      configuration_information15,
      configuration_information16,
      configuration_information17,
      configuration_information18,
      configuration_information19,
      configuration_information20,
      configuration_information21,
      configuration_information22,
      configuration_information23,
      configuration_information24,
      configuration_information25,
      configuration_information26,
      configuration_information27,
      configuration_information28,
      configuration_information29,
      configuration_information30,
      object_version_number
    FROM   pay_element_templates
    WHERE  template_id = p_template_id
    FOR UPDATE OF template_id;

BEGIN
  pay_in_utils.set_location(g_debug, 'Entering: '||l_procedure,10);

  OPEN  csr_element_template(p_template_id);
  FETCH csr_element_template INTO p_element_template;
  CLOSE csr_element_template;

  pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,20);
EXCEPTION
    WHEN OTHERS THEN
      IF csr_element_template%ISOPEN THEN
         CLOSE csr_element_template;
      END IF;
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,40);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END get_element_template;

--------------------------------------------------------------------------
-- Name           : GET_TEMPLATE                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_rec        t_template_setup_rec          --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE get_template
       (p_template_name         IN VARCHAR2
       ,p_template_rec          OUT NOCOPY pay_in_etw_struct.t_template_setup_rec
       )
IS
   l_procedure     CONSTANT VARCHAR2(100):= g_package||'get_template';
   l_message       VARCHAR2(1000);

BEGIN
   pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

   FOR i IN 1..pay_in_etw_struct.g_template_obj.COUNT
   LOOP

       IF pay_in_etw_struct.g_template_obj(i).template_name = p_template_name THEN

          pay_in_utils.set_location(g_debug,l_procedure,20);

          p_template_rec := pay_in_etw_struct.g_template_obj(i);

          pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,30);

          RETURN ;

       END IF;

    END LOOP;
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,40);

EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,50);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END get_template;


/*========================================================================
  Public Procedures
========================================================================*/
--------------------------------------------------------------------------
-- Name           : CREATE_TEMPLATE                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE create_template
       (p_template_name                 IN   VARCHAR2
       ,p_template_id                   OUT NOCOPY  NUMBER
       )
IS

    l_procedure             CONSTANT VARCHAR2(100):= g_package||'create_template';
    l_message               VARCHAR2(1000);
    l_effective_date        CONSTANT DATE := TO_DATE('01/04/2005','DD/MM/YYYY');

    l_template_exists       VARCHAR2(1);
    l_template_id           pay_element_templates.template_id%TYPE;
    l_enabled_flag          fnd_currencies.enabled_flag%TYPE;
    l_object_version_number NUMBER ;
    l_template_rec          pay_in_etw_struct.t_template_setup_rec;
    l_sequence              NUMBER;
    l_db_items_flag         VARCHAR2(1);
    l_balance_feed_id       pay_balance_feeds_f.balance_feed_id%TYPE ;
    l_formula_id            ff_formulas_f.formula_id%TYPE;
    l_result_rule_id        pay_formula_result_rules_f.formula_result_rule_id%TYPE;

    l_aet_id                NUMBER ;
BEGIN
   g_debug := hr_utility.debug_enabled;


   hr_utility.trace('l_procedure: '||l_procedure);
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   l_template_exists := 'N';

   BEGIN
      SELECT 'Y', template_id
      INTO   l_template_exists, l_template_id
      FROM   pay_element_templates
      WHERE  template_type = pay_in_etw_struct.g_template_type
      AND    legislation_code = pay_in_etw_struct.g_legislation_code
      AND    template_name = p_template_name;
   EXCEPTION
      WHEN OTHERS THEN
        NULL;
   END;
   pay_in_utils.set_location(g_debug,l_procedure,20);

   IF (l_template_exists = 'Y')
   THEN
      pay_in_utils.set_location(g_debug,l_procedure,25);

      BEGIN

         DELETE FROM pay_ele_tmplt_class_usages
         WHERE  template_id = l_template_id;

         pay_element_template_api.delete_user_structure(FALSE ,TRUE ,
                                                        l_template_id);
         l_template_exists := 'N';
         EXCEPTION
         WHEN OTHERS THEN
           l_template_exists := 'N';
           NULL;
      END;
   END IF;

   pay_in_utils.set_location(g_debug,l_procedure,30);

   IF NOT hr_utility.chk_product_install('Oracle Human Resources','IN') OR
       l_template_exists = 'Y'
   THEN
      pay_in_utils.set_location(g_debug,l_procedure,35);
      RETURN;
   END IF;

   SELECT enabled_flag
   INTO   l_enabled_flag
   FROM   fnd_currencies
   WHERE  currency_code = pay_in_etw_struct.g_currency_code;

   UPDATE fnd_currencies
   SET enabled_flag = 'Y'
   WHERE currency_code = pay_in_etw_struct.g_currency_code
   AND   enabled_flag <> 'Y';

   pay_in_utils.set_location(g_debug,l_procedure,40);

   pay_in_etw_struct.init_code;
   pay_in_etw_struct.init_formula;

   pay_in_utils.set_location(g_debug,l_procedure,50);

   get_template
       (p_template_name         => p_template_name
       ,p_template_rec          => l_template_rec
       );

   IF g_debug THEN
      pay_in_utils.trace('Template Name ',l_template_rec.template_name);
      pay_in_utils.trace('Category      ',l_template_rec.category);
      pay_in_utils.trace('Priority      ',l_template_rec.priority);
   END IF;

   --
   --  PAY_ELEMENT_TEMPLATES row.
   --
   pay_in_utils.set_location(g_debug,l_procedure,60);
   pay_etm_ins.ins
        (p_template_id               => l_template_rec.template_id
        ,p_effective_date            => l_effective_date
        ,p_template_type             => pay_in_etw_struct.g_template_type
        ,p_template_name             => l_template_rec.template_name
        ,p_base_processing_priority  => l_template_rec.priority
        ,p_max_base_name_length      => pay_in_etw_struct.g_max_length
        ,p_version_number            => 1
        ,p_legislation_code          => pay_in_etw_struct.g_legislation_code
        ,p_object_version_number     => l_object_version_number
        );

   --
   --  EXCLUSION RULES.
   --
   pay_in_utils.set_location(g_debug,l_procedure,70);
   FOR i IN 1..l_template_rec.er_setup.COUNT
   LOOP
        pay_ter_ins.ins
        (p_exclusion_rule_id          => l_template_rec.er_setup(i).rule_id
        ,p_template_id                => l_template_rec.template_id
        ,p_flexfield_column           => l_template_rec.er_setup(i).ff_column
        ,p_exclusion_value            => l_template_rec.er_setup(i).value
        ,p_description                => l_template_rec.er_setup(i).descr
        ,p_object_version_number      => l_object_version_number
        );
   END LOOP;

   --
   -- USER FORMULAS
   --
   pay_in_utils.set_location(g_debug,l_procedure,80);
   IF l_template_rec.uf_setup.formula_name IS NOT NULL THEN
   BEGIN

      SELECT formula_id, object_version_number
      INTO   l_template_rec.uf_setup.formula_id, l_object_version_number
      FROM   pay_shadow_formulas
      WHERE  template_type = pay_in_etw_struct.g_template_type
      AND    legislation_code= pay_in_etw_struct.g_legislation_code
      AND    formula_name = l_template_rec.uf_setup.formula_name;

      pay_sf_upd.upd
       (p_formula_id                => l_template_rec.uf_setup.formula_id
       ,p_description               => l_template_rec.uf_setup.description
       ,p_formula_text              => get_text(l_template_rec.uf_setup.formula_name)
       ,p_object_version_number     => l_object_version_number
       ,p_effective_date            => l_effective_date
       );

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
         pay_in_utils.set_location(g_debug,l_procedure,90);
         pay_sf_ins.ins
          (p_formula_id                => l_template_rec.uf_setup.formula_id
          ,p_template_type             => pay_in_etw_struct.g_template_type
          ,p_legislation_code          => pay_in_etw_struct.g_legislation_code
          ,p_formula_name              => l_template_rec.uf_setup.formula_name
          ,p_description               => l_template_rec.uf_setup.description
          ,p_formula_text              => get_text(l_template_rec.uf_setup.formula_name)
          ,p_object_version_number     => l_object_version_number
          ,p_effective_date            => l_effective_date
          );
   END ;
   ELSE
      pay_in_utils.set_location(g_debug,l_procedure,100);

      l_template_rec.uf_setup.formula_id := NULL ;
   END IF ;
   --
   --  BASE Element
   --
   pay_in_utils.set_location(g_debug,l_procedure,110);
   pay_set_ins.ins
       (p_element_type_id              => l_template_rec.base_element_id
       ,p_template_id                  => l_template_rec.template_id
       ,p_element_name                 => null
       ,p_reporting_name               => null
       ,p_relative_processing_priority => 0
       ,p_processing_type              => 'R'
       ,p_classification_name          => l_template_rec.category
       ,p_input_currency_code          => pay_in_etw_struct.g_currency_code
       ,p_output_currency_code         => pay_in_etw_struct.g_currency_code
       ,p_multiple_entries_allowed_fla => 'N'
       ,p_post_termination_rule        => 'F'
       ,p_process_in_run_flag          => 'Y'
       ,p_additional_entry_allowed_fla => 'N'
       ,p_adjustment_only_flag         => 'N'
       ,p_closed_for_entry_flag        => 'N'
       ,p_indirect_only_flag           => 'N'
       ,p_multiply_value_flag          => 'N'
       ,p_standard_link_flag           => 'N'
       ,p_process_mode                 => NULL
       ,p_payroll_formula_id           => l_template_rec.uf_setup.formula_id
       ,p_skip_formula                 => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );


   --
   --  BASE Element - Input Values
   --
   pay_in_utils.set_location(g_debug,l_procedure,120);
   FOR i IN 1..l_template_rec.iv_setup.COUNT
   LOOP
     l_db_items_flag := 'N';
     IF l_template_rec.iv_setup(i).input_value_name = 'Pay Value'
     THEN
        l_db_items_flag := 'Y';
     END IF;

      pay_siv_ins.ins
       (p_input_value_id               => l_template_rec.iv_setup(i).input_value_id
       ,p_element_type_id              => l_template_rec.base_element_id
       ,p_display_sequence             => i
       ,p_generate_db_items_flag       => l_db_items_flag
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => l_template_rec.iv_setup(i).mandatory_flag
       ,p_name                         => l_template_rec.iv_setup(i).input_value_name
       ,p_uom                          => l_template_rec.iv_setup(i).uom
       ,p_default_value                => l_template_rec.iv_setup(i).default_value
       ,p_default_value_column         => l_template_rec.iv_setup(i).def_value_column
       ,p_lookup_type                  => l_template_rec.iv_setup(i).lookup_type
       ,p_min_value                    => l_template_rec.iv_setup(i).min_value
       ,p_warning_or_error             => l_template_rec.iv_setup(i).warn_or_error
       ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                               l_template_rec.iv_setup(i).exclusion_tag)
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

     IF l_template_rec.iv_setup(i).balance_name IS NOT NULL THEN
        pay_in_utils.set_location(g_debug,l_procedure,125);

        pay_sbf_ins.ins
          (p_balance_feed_id              => l_balance_feed_id
          ,p_balance_name                 => l_template_rec.iv_setup(i).balance_name
          ,p_input_value_id               => l_template_rec.iv_setup(i).input_value_id
          ,p_scale                        => 1
          ,p_object_version_number        => l_object_version_number
          ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                               l_template_rec.iv_setup(i).exclusion_tag)
          ,p_effective_date               => l_effective_date
         );
     END IF;

    END LOOP ;

   --
   --  BASE Element - Balance Feeds
   --
   pay_in_utils.set_location(g_debug,l_procedure,130);
   FOR i IN 1..l_template_rec.bf_setup.COUNT
   LOOP
     pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_name                 => l_template_rec.bf_setup(i).balance_name
       ,p_input_value_id               => get_iv_id(l_template_rec, l_template_rec.bf_setup(i).iv_name)
       ,p_scale                        => l_template_rec.bf_setup(i).scale
       ,p_object_version_number        => l_object_version_number
       ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                               l_template_rec.bf_setup(i).exclusion_tag)
       ,p_effective_date               => l_effective_date
       );
   END LOOP;

   --
   --  Additional Elements
   --

   pay_in_utils.set_location(g_debug,l_procedure,140);
   FOR i IN 1..l_template_rec.ae_setup.COUNT
   LOOP

   --
   -- User Formulas for Additional Elements
   --
     IF l_template_rec.ae_setup(i).uf_setup.formula_name IS NOT NULL THEN
     BEGIN

      SELECT formula_id, object_version_number
      INTO   l_template_rec.ae_setup(i).uf_setup.formula_id, l_object_version_number
      FROM   pay_shadow_formulas
      WHERE  template_type = pay_in_etw_struct.g_template_type
      AND    legislation_code= pay_in_etw_struct.g_legislation_code
      AND    formula_name = l_template_rec.ae_setup(i).uf_setup.formula_name;

      pay_in_utils.set_location(g_debug,l_procedure,150);

      pay_sf_upd.upd
       (p_formula_id                => l_template_rec.ae_setup(i).uf_setup.formula_id
       ,p_description               => l_template_rec.ae_setup(i).uf_setup.description
       ,p_formula_text              => get_text(l_template_rec.ae_setup(i).uf_setup.formula_name)
       ,p_object_version_number     => l_object_version_number
       ,p_effective_date            => l_effective_date
       );

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         pay_in_utils.set_location(g_debug,l_procedure,160);

         pay_sf_ins.ins
          (p_formula_id                => l_template_rec.ae_setup(i).uf_setup.formula_id
          ,p_template_type             => pay_in_etw_struct.g_template_type
          ,p_legislation_code          => pay_in_etw_struct.g_legislation_code
          ,p_formula_name              => l_template_rec.ae_setup(i).uf_setup.formula_name
          ,p_description               => l_template_rec.ae_setup(i).uf_setup.description
          ,p_formula_text              => get_text(l_template_rec.ae_setup(i).uf_setup.formula_name)
          ,p_object_version_number     => l_object_version_number
          ,p_effective_date            => l_effective_date
          );
     END ;
     ELSE
      pay_in_utils.set_location(g_debug,l_procedure,170);

      l_template_rec.ae_setup(i).uf_setup.formula_id := NULL ;
     END IF ;





     pay_in_utils.set_location(g_debug,l_procedure,180);
     pay_set_ins.ins
       (p_element_type_id              => l_template_rec.ae_setup(i).element_id
       ,p_template_id                  => l_template_rec.template_id
       ,p_element_name                 => l_template_rec.ae_setup(i).element_name
       ,p_reporting_name               => NULL      --Fix for bug 5718112
       ,p_relative_processing_priority => l_template_rec.ae_setup(i).priority
       ,p_processing_type              => 'N'
       ,p_classification_name          => l_template_rec.ae_setup(i).classification
       ,p_input_currency_code          => pay_in_etw_struct.g_currency_code
       ,p_output_currency_code         => pay_in_etw_struct.g_currency_code
       ,p_multiple_entries_allowed_fla => 'N'
       ,p_post_termination_rule        => 'F'
       ,p_process_in_run_flag          => 'Y'
       ,p_additional_entry_allowed_fla => 'N'
       ,p_adjustment_only_flag         => 'N'
       ,p_closed_for_entry_flag        => 'N'
       ,p_indirect_only_flag           => 'N'
       ,p_multiply_value_flag          => 'N'
       ,p_standard_link_flag           => 'N'
       ,p_process_mode                 => NULL
       ,p_payroll_formula_id           => l_template_rec.ae_setup(i).uf_setup.formula_id
       ,p_skip_formula                 => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                             l_template_rec.ae_setup(i).exclusion_tag)
       );

      --
      --  Additional Elements - Input Values
      --
       pay_in_utils.set_location(g_debug,l_procedure,190);
       FOR j IN 1..l_template_rec.ae_setup(i).iv_setup.COUNT
       LOOP

         l_db_items_flag := 'N';
         IF l_template_rec.ae_setup(i).iv_setup(j).input_value_name = 'Pay Value'
         THEN
            l_db_items_flag := 'Y';
         END IF;
         pay_in_utils.set_location(g_debug,l_procedure,200);

	 pay_siv_ins.ins
            (p_input_value_id               => l_template_rec.ae_setup(i).iv_setup(j).input_value_id
            ,p_element_type_id              => l_template_rec.ae_setup(i).element_id
            ,p_display_sequence             => j
            ,p_generate_db_items_flag       => l_db_items_flag
            ,p_hot_default_flag             => 'N'
            ,p_mandatory_flag               => l_template_rec.ae_setup(i).iv_setup(j).mandatory_flag
            ,p_name                         => l_template_rec.ae_setup(i).iv_setup(j).input_value_name
            ,p_uom                          => l_template_rec.ae_setup(i).iv_setup(j).uom
	    ,p_lookup_type                  => l_template_rec.ae_setup(i).iv_setup(j).lookup_type
            ,p_default_value                => l_template_rec.ae_setup(i).iv_setup(j).default_value
	    ,p_default_value_column         => l_template_rec.ae_setup(i).iv_setup(j).def_value_column
            ,p_min_value                    => l_template_rec.ae_setup(i).iv_setup(j).min_value
            ,p_warning_or_error             => l_template_rec.ae_setup(i).iv_setup(j).warn_or_error
            ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                                       l_template_rec.ae_setup(i).iv_setup(j).exclusion_tag)
            ,p_object_version_number        => l_object_version_number
            ,p_effective_date               => l_effective_date
               );

        IF l_template_rec.ae_setup(i).iv_setup(j).balance_name IS NOT NULL
        THEN
           pay_in_utils.set_location(g_debug,l_procedure,210);

           pay_sbf_ins.ins
             (p_balance_feed_id              => l_balance_feed_id
             ,p_balance_name                 => l_template_rec.ae_setup(i).iv_setup(j).balance_name
             ,p_input_value_id               => l_template_rec.ae_setup(i).iv_setup(j).input_value_id
             ,p_scale                        => 1
             ,p_object_version_number        => l_object_version_number
             ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                                 l_template_rec.ae_setup(i).iv_setup(j).exclusion_tag)
             ,p_effective_date               => l_effective_date
            );
        END IF;

      END LOOP;

       --
       --  Additional Elements - Balance Feeds
       --
       pay_in_utils.set_location(g_debug,l_procedure,220);
       FOR j IN 1..l_template_rec.ae_setup(i).bf_setup.COUNT
       LOOP

         pay_sbf_ins.ins
           (p_balance_feed_id              => l_balance_feed_id
           ,p_balance_name                 => l_template_rec.ae_setup(i).bf_setup(j).balance_name
           ,p_input_value_id               => get_aiv_id(l_template_rec
	                                                ,l_template_rec.ae_setup(i).element_id
                                                        ,l_template_rec.ae_setup(i).bf_setup(j).iv_name)
           ,p_scale                        => l_template_rec.ae_setup(i).bf_setup(j).scale
           ,p_object_version_number        => l_object_version_number
           ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                                   l_template_rec.ae_setup(i).bf_setup(j).exclusion_tag)
           ,p_effective_date               => l_effective_date
           );
       END LOOP;

   END LOOP ;

   --
   --  User Defined Formula Result Rules for Base Elements
   --
   pay_in_utils.set_location(g_debug,l_procedure,230);
   FOR i IN 1..l_template_rec.uf_setup.frs_setup.COUNT
   LOOP
      pay_in_utils.set_location(g_debug,l_procedure,240);

      IF l_template_rec.uf_setup.frs_setup(i).result_rule_type = 'D' THEN
         pay_in_utils.set_location(g_debug,l_procedure,250);
         pay_sfr_ins.ins
         (p_formula_result_rule_id       => l_result_rule_id
         ,p_shadow_element_type_id       => l_template_rec.base_element_id
         ,p_result_name                  => l_template_rec.uf_setup.frs_setup(i).result_name
         ,p_result_rule_type             => l_template_rec.uf_setup.frs_setup(i).result_rule_type
         ,p_element_type_id              => l_template_rec.base_element_id
         ,p_input_value_id               => get_iv_id(l_template_rec, l_template_rec.uf_setup.frs_setup(i).input_value_name)
         ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                             l_template_rec.uf_setup.frs_setup(i).exclusion_tag)
         ,p_object_version_number        => l_object_version_number
         ,p_effective_date               => l_effective_date
         );
      ELSIF l_template_rec.uf_setup.frs_setup(i).result_rule_type = 'M' THEN
         pay_in_utils.set_location(g_debug,l_procedure,260);
         pay_sfr_ins.ins
         (p_formula_result_rule_id       => l_result_rule_id
         ,p_shadow_element_type_id       => l_template_rec.base_element_id
         ,p_result_name                  => l_template_rec.uf_setup.frs_setup(i).result_name
         ,p_result_rule_type             => l_template_rec.uf_setup.frs_setup(i).result_rule_type
         ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                            l_template_rec.uf_setup.frs_setup(i).exclusion_tag)
         ,p_severity_level               => l_template_rec.uf_setup.frs_setup(i).severity_level
         ,p_object_version_number        => l_object_version_number
         ,p_effective_date               => l_effective_date
         );
      ELSIF l_template_rec.uf_setup.frs_setup(i).result_rule_type = 'I' THEN
         pay_in_utils.set_location(g_debug,l_procedure,270);
         l_aet_id := get_aet_id(l_template_rec
	                       ,l_template_rec.uf_setup.frs_setup(i).element_name);
         pay_sfr_ins.ins
         (p_formula_result_rule_id       => l_result_rule_id
         ,p_shadow_element_type_id       => l_template_rec.base_element_id
         ,p_result_name                  => l_template_rec.uf_setup.frs_setup(i).result_name
         ,p_result_rule_type             => l_template_rec.uf_setup.frs_setup(i).result_rule_type
	 ,p_element_type_id              => l_aet_id
         ,p_input_value_id               => get_aiv_id(l_template_rec
	                                              ,l_aet_id
	                                              ,l_template_rec.uf_setup.frs_setup(i).input_value_name)
         ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                            l_template_rec.uf_setup.frs_setup(i).exclusion_tag)
         ,p_severity_level               => l_template_rec.uf_setup.frs_setup(i).severity_level
         ,p_object_version_number        => l_object_version_number
         ,p_effective_date               => l_effective_date
         );

      END IF;
   END LOOP;


   --
   --  User Defined Formula Result Rules for Additional Elements
   --
   pay_in_utils.set_location(g_debug,l_procedure,280);
   FOR j IN 1..l_template_rec.ae_setup.COUNT
   LOOP
     pay_in_utils.set_location(g_debug,l_procedure,290);
     FOR i IN 1..l_template_rec.ae_setup(j).uf_setup.frs_setup.COUNT
     LOOP
       pay_in_utils.set_location(g_debug,l_procedure,300);
       IF l_template_rec.ae_setup(j).uf_setup.frs_setup(i).result_rule_type = 'D' THEN
         pay_in_utils.set_location(g_debug,l_procedure,310);
         pay_sfr_ins.ins
         (p_formula_result_rule_id       => l_result_rule_id
         ,p_shadow_element_type_id       => l_template_rec.ae_setup(j).element_id
         ,p_result_name                  => l_template_rec.ae_setup(j).uf_setup.frs_setup(i).result_name
         ,p_result_rule_type             => l_template_rec.ae_setup(j).uf_setup.frs_setup(i).result_rule_type
         ,p_element_type_id              => l_template_rec.ae_setup(j).element_id
         ,p_input_value_id               => get_aiv_id(l_template_rec
	                                              ,l_template_rec.ae_setup(j).element_id
	                                              ,l_template_rec.ae_setup(j).uf_setup.frs_setup(i).input_value_name)
         ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                             l_template_rec.ae_setup(j).uf_setup.frs_setup(i).exclusion_tag)
         ,p_object_version_number        => l_object_version_number
         ,p_effective_date               => l_effective_date
         );
      ELSIF l_template_rec.ae_setup(j).uf_setup.frs_setup(i).result_rule_type = 'M' THEN
         pay_in_utils.set_location(g_debug,l_procedure,320);
         pay_sfr_ins.ins
         (p_formula_result_rule_id       => l_result_rule_id
         ,p_shadow_element_type_id       => l_template_rec.ae_setup(j).element_id
         ,p_result_name                  => l_template_rec.ae_setup(j).uf_setup.frs_setup(i).result_name
         ,p_result_rule_type             => l_template_rec.ae_setup(j).uf_setup.frs_setup(i).result_rule_type
         ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                            l_template_rec.ae_setup(j).uf_setup.frs_setup(i).exclusion_tag)
         ,p_severity_level               => l_template_rec.ae_setup(j).uf_setup.frs_setup(i).severity_level
         ,p_object_version_number        => l_object_version_number
         ,p_effective_date               => l_effective_date
         );
      ELSIF l_template_rec.ae_setup(j).uf_setup.frs_setup(i).result_rule_type = 'I' THEN
         pay_in_utils.set_location(g_debug,l_procedure,330);
         l_aet_id := get_aet_id(l_template_rec
	                       ,l_template_rec.ae_setup(j).uf_setup.frs_setup(i).element_name);

         pay_sfr_ins.ins
         (p_formula_result_rule_id       => l_result_rule_id
         ,p_shadow_element_type_id       => l_template_rec.ae_setup(j).element_id
         ,p_result_name                  => l_template_rec.ae_setup(j).uf_setup.frs_setup(i).result_name
         ,p_result_rule_type             => l_template_rec.ae_setup(j).uf_setup.frs_setup(i).result_rule_type
	 ,p_element_type_id              => l_aet_id
         ,p_input_value_id               => get_aiv_id(l_template_rec
	                                              ,l_aet_id
	                                              ,l_template_rec.ae_setup(j).uf_setup.frs_setup(i).input_value_name)
         ,p_exclusion_rule_id            => get_exclusion_rule_id(l_template_rec,
                                            l_template_rec.ae_setup(j).uf_setup.frs_setup(i).exclusion_tag)
         ,p_severity_level               => l_template_rec.ae_setup(j).uf_setup.frs_setup(i).severity_level
         ,p_object_version_number        => l_object_version_number
         ,p_effective_date               => l_effective_date
         );

      END IF;
    END LOOP ;
   END LOOP;

   pay_in_utils.set_location(g_debug,l_procedure,340);

   UPDATE fnd_currencies
   SET    enabled_flag = l_enabled_flag
   WHERE  currency_code = pay_in_etw_struct.g_currency_code;

   --
   --  PAY_ELE_TMPLT_CLASS_USAGES row.
   --
   pay_in_utils.set_location(g_debug,l_procedure,350);
   create_template_association( l_template_rec.template_id, l_template_rec.category );

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,360);

EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,370);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END create_template;

--------------------------------------------------------------------------
-- Name           : CREATE_TEMPLATE_ASSOCIATION                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to associate template with classification --
-- Parameters     :                                                     --
--             IN : p_template_name         VARCHAR2                    --
--                  p_classification_name   VARCHAR2                    --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE create_template_association
         (p_template_id      IN NUMBER
         ,p_classification   IN VARCHAR2 )
IS
    l_classification_id   pay_element_classifications.classification_id%TYPE ;
    l_exists              NUMBER;
    l_ele_tmplt_class_id  NUMBER;

    l_procedure   CONSTANT VARCHAR2(100):= g_package||'create_template_association';
    l_message     VARCHAR2(1000);

BEGIN
   g_debug := hr_utility.debug_enabled;
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    SELECT classification_id
    INTO   l_classification_id
    FROM   pay_element_classifications
    WHERE  legislation_code = pay_in_etw_struct.g_legislation_code
    AND    classification_name = p_classification;

    pay_in_utils.set_location(g_debug,l_procedure,20);
    SELECT count(*)
    INTO   l_exists
    FROM   pay_ele_tmplt_class_usages
    WHERE  classification_id = l_classification_id
    AND    template_id       = p_template_id;

    pay_in_utils.set_location(g_debug,l_procedure,30);
    IF l_exists = 0 THEN

       pay_in_utils.set_location(g_debug,l_procedure,40);
       SELECT pay_ele_tmplt_class_usg_s.nextval
       INTO   l_ele_tmplt_class_id
       FROM   dual;

       pay_in_utils.set_location(g_debug,l_procedure,50);
       INSERT INTO pay_ele_tmplt_class_usages
                 ( ele_template_classification_id
                  ,classification_id
                  ,template_id
                  ,display_process_mode
                  ,display_arrearage )
        VALUES   ( l_ele_tmplt_class_id
                  ,l_classification_id
                  ,p_template_id
                  ,'Y'
                  ,null);

    END IF;
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,70);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END create_template_association;

--------------------------------------------------------------------------
-- Name           : DELETE_TEMPLATE_ASSOCIATION                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE delete_template_association
         (p_template_name    IN VARCHAR2
         ,p_classification   IN VARCHAR2 )
IS
    l_procedure   CONSTANT VARCHAR2(100):= g_package||'delete_template_association';
    l_message     VARCHAR2(1000);
BEGIN
    g_debug := hr_utility.debug_enabled;
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    DELETE FROM pay_ele_tmplt_class_usages
    WHERE  ele_template_classification_id
       IN (SELECT petcu.ele_template_classification_id
           FROM   pay_ele_tmplt_class_usages petcu
                 ,pay_element_classifications pec
                 ,pay_element_templates pet
           WHERE  petcu.classification_id = pec.classification_id
           AND    petcu.template_id       = pet.template_id
           AND    pet.template_name       = p_template_name
           AND    pec.classification_name = p_classification
           AND    pec.legislation_code    = pay_in_etw_struct.g_legislation_code
           AND    pet.legislation_code    = pay_in_etw_struct.g_legislation_code);

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,30);
       NULL;
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,40);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;
END delete_template_association;

--------------------------------------------------------------------------
-- Name           : ELEMENT_TEMPLATE_PRE_PROCESS                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the elements for ETW        --
-- Parameters     :                                                     --
--             IN : p_template_obj          PAY_ELE_TMPLT_OBJ           --
--            OUT : p_template_obj          PAY_ELE_TMPLT_OBJ           --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
FUNCTION element_template_pre_process
          (p_template_obj    IN PAY_ELE_TMPLT_OBJ)
RETURN PAY_ELE_TMPLT_OBJ
IS
   l_procedure    VARCHAR2(100):= g_package||'element_template_pre_process';
   l_message      VARCHAR2(1000);

   l_template_obj PAY_ELE_TMPLT_OBJ;

BEGIN

   g_debug := hr_utility.debug_enabled;
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   l_template_obj := p_template_obj;

   IF g_debug THEN

      pay_in_utils.trace('Classification  ',l_template_obj.element_classification);
      pay_in_utils.trace('Processing Type ',l_template_obj.processing_type);
      pay_in_utils.trace('Conf Info Catg  ',l_template_obj.configuration_info_category);
      pay_in_utils.trace('Conf Info 1     ',l_template_obj.configuration_information1);
      pay_in_utils.trace('Conf Info 2     ',l_template_obj.configuration_information2);
      pay_in_utils.trace('Conf Info 3     ',l_template_obj.configuration_information3);
      pay_in_utils.trace('Conf Info 4     ',l_template_obj.configuration_information4);
      pay_in_utils.trace('Conf Info 5     ',l_template_obj.configuration_information5);
      pay_in_utils.trace('Conf Info 6     ',l_template_obj.configuration_information6);
      pay_in_utils.trace('Conf Info 7     ',l_template_obj.configuration_information7);
      pay_in_utils.trace('Conf Info 8     ',l_template_obj.configuration_information8);
      pay_in_utils.trace('Conf Info 9     ',l_template_obj.configuration_information9);
      pay_in_utils.trace('Conf Info 10    ',l_template_obj.configuration_information10);

   END IF;

   l_template_obj.configuration_information1 := NVL(l_template_obj.configuration_information1,'N');
   l_template_obj.configuration_information2 := NVL(l_template_obj.configuration_information2,'N');
   l_template_obj.configuration_information3 := NVL(l_template_obj.configuration_information3,'N');
   l_template_obj.configuration_information4 := NVL(l_template_obj.configuration_information4,'N');
   l_template_obj.configuration_information5 := NVL(l_template_obj.configuration_information5,'N');
   l_template_obj.configuration_information6 := NVL(l_template_obj.configuration_information6,'N');
   l_template_obj.configuration_information7 := NVL(l_template_obj.configuration_information7,'N');
   l_template_obj.configuration_information8 := NVL(l_template_obj.configuration_information8,'N');
   l_template_obj.configuration_information9 := NVL(l_template_obj.configuration_information9,'N');
   l_template_obj.configuration_information10 := NVL(l_template_obj.configuration_information10,'N');

/*
  ----------------------------------------------------------------
  | Sr#   |   Classification  | Template Name                    |
  ----------------------------------------------------------------
  |   1   |   Fringe Benefits | Fringe Benefits                  |
  |   2   |   Allowances      | Fixed Allowance                  |
  |   3   |   Allowances      | Actual Expense Allowances        |
  |   4   |   Perquisites     | Free Education                   |
  |   5   |   Perquisites     | Company Accommodation            |
  |   6   |   Perquisites     | Loan at Concessional Rate        |
  |   7   |   Perquisites     | Company Movable Assets           |
  |   8   |   Perquisites     | Other Perquisites                |
  |   9   |   Earnings        | Leave Travel Concession          |
  |  10   |   Earnings        | Earnings                         |
  |  11   |   Perquisites     | Transfer of Company Assets       |
  |  12   |   Employer Charges| Employer Charges                 |
  ----------------------------------------------------------------
*/

   IF l_template_obj.element_classification = 'Allowances' THEN
      pay_in_utils.set_location(g_debug,l_procedure,20);

      IF l_template_obj.configuration_info_category = 'IN Fixed Allowance' THEN
--
--	CI1 -  Allowance Name
--      CI2 -  Enable Projections
--	CI3 -  Is CEA or HEA
--      CI4 -  Enable Advances
--
       /* Set Projection exclusion rule as per the Processing Type */
         pay_in_utils.set_location(g_debug,l_procedure,30);
         IF l_template_obj.processing_type = 'R' THEN
            pay_in_utils.set_location(g_debug,l_procedure,70);
            l_template_obj.configuration_information2 := 'Y'; -- Projections
         END IF ;

       /* For CEA/HEA, set the Claim Exemption u/s 10 Exclusion Rule */
         IF l_template_obj.configuration_information1
               IN ('Children Education Allowance',
                   'Hostel Expenditure Allowance')
         THEN
            pay_in_utils.set_location(g_debug,l_procedure,40);
            l_template_obj.configuration_information3 := 'Y';
         END IF ;

      END IF;

      pay_in_utils.set_location(g_debug,l_procedure,60);
      IF l_template_obj.configuration_info_category = 'IN Actual Expense Allowances' THEN
--
--	CI1 -  Allowance Name
--	CI2 -  Nature of Expense
--	CI3 -  Enable Advances
--	CI4 -  Enable Projections
--	CI5 -  Create Expense Element
--      CI6 -  Is HRA
--      CI7 -  Is Ent
--      CI8 -  HRA  + Advance
--      CI9 -  Ent + Advance


--      Recurring Element NonRec Expense    - Create Expense Element
--      Recurring Element recurring Expense - Create Expense Input
--      Non Recurring Element               - Create Expense Input

       /* Set Projection exclusion rule as per the Processing Type */
         IF l_template_obj.processing_type = 'R' THEN

            pay_in_utils.set_location(g_debug,l_procedure,70);
            l_template_obj.configuration_information4 := 'Y'; -- Projection

	    IF (l_template_obj.configuration_information2 = 'N') THEN
               l_template_obj.configuration_information5 := 'Y'; -- Create Exp Element
            END IF ;


         ELSE /* Non recurring Allowance */
            pay_in_utils.set_location(g_debug,l_procedure,75);
           l_template_obj.configuration_information2 := 'Y';-- Create Exp Input
           l_template_obj.configuration_information5 := 'N';-- Create Exp Element
         END IF ;

         IF l_template_obj.configuration_information1 = 'House Rent Allowance'
         THEN

            pay_in_utils.set_location(g_debug,l_procedure,90);
            l_template_obj.configuration_information2 := 'N'; -- No Exp Projections
            l_template_obj.configuration_information5 := 'N'; -- No Exp Element
            l_template_obj.configuration_information6 := 'Y'; -- Is HRA
	    l_template_obj.configuration_information8 := l_template_obj.configuration_information3;


         ELSIF l_template_obj.configuration_information1 = 'Entertainment Allowance'
         THEN
            l_template_obj.configuration_information2 := 'N'; -- No Exp Projections
            l_template_obj.configuration_information5 := 'N'; -- No Exp Element
            l_template_obj.configuration_information7 := 'Y'; -- Is Entertainment
            l_template_obj.configuration_information9 := l_template_obj.configuration_information3;

         END IF;

      END IF ;
   END IF ;

/*
   For Perquisites except for Other Perquisites, the Taxable should be
   defaulted to ALL
*/


   pay_in_utils.set_location(g_debug,l_procedure,130);

   IF l_template_obj.element_classification = 'Perquisites' THEN
      pay_in_utils.set_location(g_debug,l_procedure,140);
     /* Set Projection exclusion rule as per the Processing Type */
      IF l_template_obj.processing_type = 'R' and l_template_obj.configuration_information2 = 'Y'  THEN
         pay_in_utils.set_location(g_debug,l_procedure,150);
         l_template_obj.configuration_information2 := 'Y'; -- Projections
      ELSE
         pay_in_utils.set_location(g_debug,l_procedure,160);
         l_template_obj.configuration_information2 := 'N'; -- No Projections
      END IF ;

      IF l_template_obj.configuration_information1 IN ('Club Expenditure','Credit Cards') --Club and Car Perqs will have an additional input Official Purpose Expense
      THEN
       l_template_obj.configuration_information5 := 'Y';
      ELSE
       l_template_obj.configuration_information5 := 'N';
      END IF ;

     -- Since defaulting is not happening, we set the values explicitly
     IF l_template_obj.configuration_info_category <> 'IN Other Perquisites'
     THEN
        l_template_obj.configuration_information1 :=
	     REPLACE(l_template_obj.configuration_info_category,
	             pay_in_etw_struct.g_legislation_code||' ');
        l_template_obj.configuration_information3 := REPLACE(l_template_obj.configuration_information3
                                                           , 'N', 'ALL');
     END IF ;


   END IF ;
   pay_in_utils.set_location(g_debug,l_procedure,170);
   IF l_template_obj.element_classification = 'Earnings' THEN
      pay_in_utils.set_location(g_debug,l_procedure,180);
      /* For Recurring Earnings if Processing Type is Recurring,
         Projections are enabled */

      IF l_template_obj.configuration_info_category = 'IN Earnings' THEN
         pay_in_utils.set_location(g_debug,l_procedure,190);

         IF l_template_obj.processing_type = 'R' THEN
            l_template_obj.configuration_information1 := 'Y';
            IF l_template_obj.configuration_information5 = 'Y' THEN
              l_template_obj.configuration_information13 := 'Y';
            ELSE
              l_template_obj.configuration_information13 := 'N';
            END IF ;
         ELSE
            l_template_obj.configuration_information1 := 'N';
         END IF ;

      END IF;

      IF l_template_obj.configuration_info_category = 'IN Leave Travel Concession'
      THEN
      /* LTC is always non-recurring element entry */
         pay_in_utils.set_location(g_debug,l_procedure,190);
         l_template_obj.processing_type := 'N';
      END IF;

   END IF ;

/*
   For Medical Fringe Benefits we need to set the Exclusion Rule
*/
   g_debug := hr_utility.debug_enabled;

   pay_in_utils.set_location(g_debug,l_procedure,200);
   IF l_template_obj.element_classification = 'Fringe Benefits' THEN
      pay_in_utils.set_location(g_debug,l_procedure,210);

      IF l_template_obj.configuration_information1 = 'Superannuation Fund' THEN
         pay_in_utils.set_location(g_debug,l_procedure,215);
         l_template_obj.configuration_information5 := 'Y';
      END IF ;

     /* Set Medical exclusion rule as per the user input */
      pay_in_utils.set_location(g_debug,l_procedure,220);
      IF l_template_obj.configuration_information1 <> 'Employees Welfare Expense' THEN
         pay_in_utils.set_location(g_debug,l_procedure,230);
         l_template_obj.configuration_information3 := 'N'; -- Override Medical
      ELSE
       IF l_template_obj.configuration_information3 = 'Y' THEN
         IF l_template_obj.processing_type = 'R' THEN
           pay_in_utils.set_location(g_debug,l_procedure,231);
           l_template_obj.configuration_information4 := 'Y';
         END IF ;
       END IF ;
      END IF ;

   END IF ;

   pay_in_utils.set_location(g_debug,l_procedure,240);

   IF l_template_obj.element_classification = 'Employer Charges' THEN
      pay_in_utils.set_location(g_debug,l_procedure,250);
      /* For Employer Charges if Processing Type is Recurring,
         Projections are enabled*/
         pay_in_utils.set_location(g_debug,l_procedure,260);
         IF l_template_obj.processing_type = 'R' THEN
            l_template_obj.configuration_information1 := 'Y';
         ELSE
            l_template_obj.configuration_information1 := 'N';
         END IF ;
   END IF ;



   IF g_debug THEN
      pay_in_utils.trace('Classification  ',l_template_obj.element_classification);
      pay_in_utils.trace('Processing Type ',l_template_obj.processing_type);
      pay_in_utils.trace('Conf Info Catg  ',l_template_obj.configuration_info_category);
      pay_in_utils.trace('Conf Info 1     ',l_template_obj.configuration_information1);
      pay_in_utils.trace('Conf Info 2     ',l_template_obj.configuration_information2);
      pay_in_utils.trace('Conf Info 3     ',l_template_obj.configuration_information3);
      pay_in_utils.trace('Conf Info 4     ',l_template_obj.configuration_information4);
      pay_in_utils.trace('Conf Info 5     ',l_template_obj.configuration_information5);
      pay_in_utils.trace('Conf Info 6     ',l_template_obj.configuration_information6);
      pay_in_utils.trace('Conf Info 7     ',l_template_obj.configuration_information7);
      pay_in_utils.trace('Conf Info 8     ',l_template_obj.configuration_information8);
      pay_in_utils.trace('Conf Info 9     ',l_template_obj.configuration_information9);
      pay_in_utils.trace('Conf Info 10    ',l_template_obj.configuration_information10);

   END IF;
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,240);
   RETURN l_template_obj;
EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,250);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END element_template_pre_process;

--------------------------------------------------------------------------
-- Name           : ELEMENT_TEMPLATE_UPD_USER_STRU                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the elements for ETW        --
-- Parameters     :                                                     --
--             IN : p_template_id          NUMBER                       --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE element_template_upd_user_stru
          (p_template_id    IN  NUMBER)


IS
   l_procedure    VARCHAR2(100):= g_package||'element_template_upd_user_stru';

BEGIN

NULL;

END element_template_upd_user_stru;

--------------------------------------------------------------------------
-- Name           : ELEMENT_TEMPLATE_POST_PROCESS                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the elements for ETW        --
-- Parameters     :                                                     --
--             IN : p_template_id          NUMBER                       --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE element_template_post_process(p_template_id    IN NUMBER)
IS
   l_procedure    VARCHAR2(100):= g_package||'element_template_post_process';

  CURSOR csr_set IS
    SELECT  pet.element_type_id
           ,pet.business_group_id
           ,pet.effective_start_date
           ,pet.object_version_number
	   ,pec.classification_name
	   ,pet.element_name
           ,pet.reporting_name
    FROM    pay_element_types_f pet
           ,pay_element_templates tmp
	   ,pay_element_classifications pec
    WHERE   pet.element_name  = tmp.base_name
    AND     tmp.template_id   = p_template_id
    AND     pet.classification_id = pec.classification_id
    AND     tmp.business_group_id = pet.business_group_id;

  CURSOR csr_ae_set(p_base_name         VARCHAR2
                  , p_business_group_id NUMBER) IS
    SELECT  pet.element_type_id
           ,pet.object_version_number
    FROM    pay_element_types_f pet
           ,pay_element_classifications pec
    WHERE   pet.element_name  = p_base_name || ' Paid MP'
    AND     pet.classification_id = pec.classification_id
    AND     pet.business_group_id = p_business_group_id
    AND     pec.classification_name = 'Paid Monetary Perquisite'
    AND     pec.legislation_code = 'IN';

   l_element    csr_set%ROWTYPE ;

   l_template      pay_etm_shd.g_rec_type;
   l_template_rec  pay_in_etw_struct.t_template_setup_rec;

   CURSOR csr_alwn_details (p_allowance_name IN VARCHAR2)
   IS
      SELECT catg.allowance_name
            ,catg.category_code
	    ,exem.exemption_amount
      FROM  pay_in_allowance_categories_v catg
           ,pay_in_allowance_max_exem_v exem
      WHERE catg.allowance_name = exem.allowance_name
      AND   catg.allowance_name = p_allowance_name;

   l_alwn_details   csr_alwn_details%ROWTYPE;

   CURSOR csr_sec_class (p_element_id IN VARCHAR2
                        ,p_effective_date IN DATE )
   IS
      SELECT pec.classification_name
      FROM   pay_sub_classification_rules_f pscr
            ,pay_element_classifications pec
      WHERE  pscr.classification_id = pec.classification_id
      AND    pec.parent_classification_id =
                  (SELECT classification_id FROM pay_element_classifications
		   WHERE  classification_name = 'Perquisites'
		   AND    legislation_code = 'IN')
      AND   element_type_id = p_element_id
      AND   p_effective_date BETWEEN pscr.effective_start_date
                             AND     pscr.effective_end_date;

   CURSOR csr_ae_type_id (p_element_name      VARCHAR2
                         ,p_business_group_id NUMBER
                         ,p_effective_date    DATE)
   IS
     SELECT element_type_id, object_version_number
     FROM pay_element_types_f
     WHERE element_name = p_element_name || ' Paid MP'
     AND   business_group_id = p_business_group_id
     AND   p_effective_date BETWEEN effective_start_date AND effective_end_date;

   l_sec_class       pay_element_classifications.classification_name%TYPE ;
   l_exp_nature      VARCHAR2(1);

   l_et_start_date   DATE ;
   l_et_end_date     DATE ;
   l_comment_id      NUMBER ;
   l_priority_warn   BOOLEAN ;
   l_name_warn       BOOLEAN ;
   l_change_warn     BOOLEAN ;

   l_st_start_date   DATE ;
   l_st_end_date     DATE ;
   l_st_ovn          NUMBER ;
   l_st_warn         BOOLEAN ;

   l_balance_feed_id NUMBER ;
   l_bf_start_date   DATE ;
   l_bf_end_date     DATE ;
   l_bf_ovn          NUMBER  ;
   l_bf_warn         BOOLEAN ;

   l_et_name         pay_element_types_f.element_name%TYPE ;
   l_cr_result       BOOLEAN ;

   l_element_id      NUMBER ;
   l_input_value_id  NUMBER ;
   l_rowid           ROWID ;
   l_result_rule_id  NUMBER ;

   l_excl_rule_id    pay_template_exclusion_rules.exclusion_rule_id%TYPE ;
   l_ff_column       pay_template_exclusion_rules.flexfield_column%TYPE;
   l_excl_def_value  pay_template_exclusion_rules.exclusion_value%TYPE ;
   l_excl_set_value  pay_template_exclusion_rules.exclusion_value%TYPE ;

   l_flx_val_set_id  NUMBER;

   l_ele_type_id              NUMBER;
   l_object_version_number    NUMBER;
   l_effective_start_date     DATE;
   l_effective_end_date       DATE;
   l_balance_feeds_warning    BOOLEAN;
   l_processing_rules_warning BOOLEAN;
   l_et_id                    NUMBER;
   l_ovn                      NUMBER;

BEGIN
   g_debug := hr_utility.debug_enabled;

   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   OPEN csr_set;
   FETCH csr_set INTO l_element;
   CLOSE csr_set;

   pay_in_utils.set_location(g_debug,l_procedure,20);
   get_element_template(p_template_id, l_template);

   IF l_element.classification_name = 'Allowances' THEN

     pay_in_utils.set_location(g_debug,l_procedure,30);
     OPEN csr_alwn_details(l_template.configuration_information1);
     FETCH csr_alwn_details
     INTO  l_alwn_details;
     CLOSE csr_alwn_details;

    IF (l_template.configuration_info_category = 'IN Fixed Allowance') THEN

       SELECT DECODE(l_template.configuration_information2,
                    'Y','R',l_template.configuration_information2)
       INTO l_exp_nature
       FROM dual;
    ELSE /* IN Actual Expense Allowances */
       IF(l_template.configuration_information2 = 'Y') THEN
          UPDATE   pay_element_templates
             SET configuration_information2 = 'N'
          WHERE  template_id = p_template_id;
          l_template.configuration_information2 := 'N';
       END IF;
       l_exp_nature := l_template.configuration_information2;

    END IF;

     pay_in_utils.set_location(g_debug,l_procedure,40);
     pay_element_types_api.update_element_type
     (
          p_effective_date               =>   l_element.effective_start_date
        , p_datetrack_update_mode        =>   hr_api.g_correction
        , p_element_type_id              =>   l_element.element_type_id
        , p_object_version_number        =>   l_element.object_version_number
        , p_element_information_category =>   UPPER(pay_in_etw_struct.g_legislation_code||'_'||
						l_element.classification_name)
        , p_element_information1         =>   l_alwn_details.allowance_name
        , p_element_information2         =>   l_alwn_details.category_code
        , p_element_information3         =>   l_alwn_details.exemption_amount
        , p_element_information4         =>   l_exp_nature
        , p_effective_start_date         =>   l_et_start_date
        , p_effective_end_date           =>   l_et_end_date
        , p_comment_id                   =>   l_comment_id
        , p_processing_priority_warning  =>   l_priority_warn
        , p_element_name_warning         =>   l_name_warn
        , p_element_name_change_warning  =>   l_change_warn
      );

     IF l_template.configuration_information1 = 'House Rent Allowance' THEN

        pay_in_utils.del_form_res_rule
	   (p_element_type_id    => l_element.element_type_id
	   ,p_effective_date     => l_element.effective_start_date
	   );

        --
	-- Delete Balance Feeds
	--
        pay_in_utils.delete_balance_feeds
	   (p_balance_name      => 'Taxable Allowances for Projection'
	   ,p_element_name      => l_element.element_name
	   ,p_input_value_name  => 'Standard Taxable Value'
	   ,p_effective_date    => l_element.effective_start_date
	   );

        pay_in_utils.delete_balance_feeds
	   (p_balance_name      => 'Taxable Allowances'
	   ,p_element_name      => l_element.element_name
	   ,p_input_value_name  => 'Taxable Value'
	   ,p_effective_date    => l_element.effective_start_date
	   );
        --
	-- Delete input values : Allowance Amount, Taxable Value, Standard Taxable Value
	--

        DELETE FROM pay_input_values_f
	WHERE  element_type_id = l_element.element_type_id
	AND    NAME IN ('Allowance Amount','Taxable Value','Standard Taxable Value')
	AND    l_element.effective_start_date BETWEEN effective_start_date AND effective_end_date;

     END IF ;

   ELSIF l_element.classification_name = 'Perquisites' THEN

     pay_in_utils.set_location(g_debug,l_procedure,50);
     pay_element_types_api.update_element_type
     (
          p_effective_date               =>   l_element.effective_start_date
        , p_datetrack_update_mode        =>   hr_api.g_correction
        , p_element_type_id              =>   l_element.element_type_id
        , p_object_version_number        =>   l_element.object_version_number
        , p_element_information_category =>   UPPER(pay_in_etw_struct.g_legislation_code||'_'||
						l_element.classification_name)
        , p_element_information1         =>   l_template.configuration_information1
        , p_element_information6         =>   l_template.configuration_information3
        , p_effective_start_date         =>   l_et_start_date
        , p_effective_end_date           =>   l_et_end_date
        , p_comment_id                   =>   l_comment_id
        , p_processing_priority_warning  =>   l_priority_warn
        , p_element_name_warning         =>   l_name_warn
        , p_element_name_change_warning  =>   l_change_warn
      );


      OPEN csr_sec_class(l_element.element_type_id, l_element.effective_start_date);
      LOOP
          FETCH csr_sec_class INTO l_sec_class;
          EXIT WHEN csr_sec_class%NOTFOUND ;
          pay_in_utils.trace('Secondary Classification',l_sec_class);

          IF l_sec_class = 'Monetary Perquisite' THEN
            pay_balance_feeds_api.create_balance_feed
	    (
               p_effective_date           => l_element.effective_start_date
              ,p_balance_type_id          => pay_in_utils.get_balance_type_id
	                                       ('ER Taxable Monetary Perquisite')
              ,p_input_value_id           => pay_in_utils.get_input_value_id
	                                      (l_element.effective_start_date,
					       l_element.element_type_id,
					       'Employer Taxable Amount')
              ,p_scale                    => 1
              ,p_business_group_id        => l_element.business_group_id
              ,p_balance_feed_id          => l_balance_feed_id
              ,p_effective_start_date     => l_bf_start_date
              ,p_effective_end_date       => l_bf_end_date
              ,p_object_version_number    => l_bf_ovn
              ,p_exist_run_result_warning => l_bf_warn
            );

	  ELSIF l_sec_class = 'Non Monetary Perquisite' THEN
            pay_balance_feeds_api.create_balance_feed
	    (
               p_effective_date           => l_element.effective_start_date
              ,p_balance_type_id          => pay_in_utils.get_balance_type_id
	                                       ('ER Taxable Non Monetary Perquisite')
              ,p_input_value_id           => pay_in_utils.get_input_value_id
	                                      (l_element.effective_start_date,
					       l_element.element_type_id,
					       'Employer Taxable Amount')
              ,p_scale                    => 1
              ,p_business_group_id        => l_element.business_group_id
              ,p_balance_feed_id          => l_balance_feed_id
              ,p_effective_start_date     => l_bf_start_date
              ,p_effective_end_date       => l_bf_end_date
              ,p_object_version_number    => l_bf_ovn
              ,p_exist_run_result_warning => l_bf_warn
            );
          END IF ;

      END LOOP ;
      CLOSE csr_sec_class;

      OPEN csr_ae_set(l_element.element_name, l_element.business_group_id);
      FETCH csr_ae_set INTO l_ele_type_id, l_object_version_number;
      CLOSE csr_ae_set;

      IF (l_ele_type_id IS NOT NULL)AND((l_sec_class = 'Non Monetary Perquisite') OR
         (l_sec_class = 'Monetary Perquisite' AND
          l_template.configuration_information4 = 'N')) THEN
         pay_element_types_api.delete_element_type
                  (p_validate                        => FALSE
                  ,p_effective_date                  => l_element.effective_start_date
                  ,p_datetrack_delete_mode           => hr_api.g_zap
                  ,p_element_type_id                 => l_ele_type_id
                  ,p_object_version_number           => l_object_version_number
                  ,p_effective_start_date            => l_effective_start_date
                  ,p_effective_end_date              => l_effective_end_date
                  ,p_balance_feeds_warning           => l_balance_feeds_warning
                  ,p_processing_rules_warning        => l_processing_rules_warning
                  );
      END IF;

      IF (l_sec_class = 'Monetary Perquisite' AND
          l_template.configuration_information4 = 'Y') THEN

         IF (l_element.reporting_name IS NOT NULL) THEN
                 l_et_start_date := NULL;
                 l_et_end_date   := NULL;
                 l_comment_id    := NULL;
                 l_priority_warn := NULL;
                 l_name_warn     := NULL;
                 l_change_warn   := NULL;

                 OPEN csr_ae_type_id(l_element.element_name
                                    ,l_element.business_group_id
                                    ,l_element.effective_start_date);
                 FETCH csr_ae_type_id INTO l_et_id, l_ovn;
                 CLOSE csr_ae_type_id;
/*
                 SELECT element_type_id, object_version_number
                 INTO l_et_id, l_ovn
                 FROM pay_element_types_f
                 WHERE element_name = l_element.element_name || ' Paid MP'
                 AND   business_group_id = l_element.business_group_id
                 AND   l_element.effective_start_date between effective_start_date and effective_end_date;
*/
             pay_element_types_api.update_element_type
             (
                  p_effective_date               =>   l_element.effective_start_date
                , p_datetrack_update_mode        =>   hr_api.g_correction
                , p_element_type_id              =>   l_et_id
                , p_object_version_number        =>   l_ovn
                , p_reporting_name               =>   l_element.reporting_name || ' Paid MP'
                , p_once_each_period_flag        =>   'N'
                , p_effective_start_date         =>   l_et_start_date
                , p_effective_end_date           =>   l_et_end_date
                , p_comment_id                   =>   l_comment_id
                , p_processing_priority_warning  =>   l_priority_warn
                , p_element_name_warning         =>   l_name_warn
                , p_element_name_change_warning  =>   l_change_warn
              );
         END IF;
      END IF;

   END IF ;

   pay_in_utils.set_location(g_debug,l_procedure,60);
   pay_in_etw_struct.init_code;

   pay_in_utils.set_location(g_debug,l_procedure,70);
   get_template
       (p_template_name         => l_template.template_name
       ,p_template_rec          => l_template_rec
       );

   pay_in_utils.set_location(g_debug,l_procedure,80);

   IF (l_template.template_name = 'Leave Travel Concession')
   THEN
        l_input_value_id := pay_in_utils.get_input_value_id(l_element.effective_start_date
                                                           ,l_element.element_type_id
                                                           ,'LTC Journey Block'
                                                           );

        SELECT flex_value_set_id
        INTO   l_flx_val_set_id
        FROM   fnd_flex_value_sets
        WHERE  flex_value_set_name = 'PER_IN_LTC_BLOCK';

        IF g_debug THEN
            pay_in_utils.trace('Input Value Id ',TO_CHAR(l_input_value_id));
            pay_in_utils.trace('Flex Value Set ID ',TO_CHAR(l_flx_val_set_id));
        END IF;

        UPDATE pay_input_values_f
           SET value_set_id = l_flx_val_set_id
         WHERE input_value_id = l_input_value_id
           AND l_element.effective_start_date BETWEEN effective_start_date AND effective_end_date;

   END IF;

   IF l_template_rec.sf_setup.formula_name IS NOT NULL THEN

       pay_in_utils.set_location(g_debug,l_procedure,90);
       pay_status_processing_rule_api.create_status_process_rule
       (
         p_effective_date              => l_element.effective_start_date
        ,p_element_type_id             => l_element.element_type_id
        ,p_business_group_id           => l_element.business_group_id
        ,p_formula_id                  => pay_in_utils.get_formula_id(l_element.effective_start_date,
	                                    l_template_rec.sf_setup.formula_name)
        ,p_status_processing_rule_id   => l_template_rec.sf_setup.status_rule_id
        ,p_effective_start_date        => l_st_start_date
        ,p_effective_end_date          => l_st_end_date
        ,p_object_version_number       => l_st_ovn
        ,p_formula_mismatch_warning    => l_st_warn
       );

     FOR i IN 1..l_template_rec.sf_setup.frs_setup.COUNT
     LOOP
        pay_in_utils.set_location(g_debug,l_procedure,100);


        IF (l_template.template_name = 'Other Perquisites'      OR
            l_template.template_name = 'Free Education'         OR
            l_template.template_name = 'Company Accommodation') AND
            l_sec_class = 'Monetary Perquisite'                 AND
            l_template.configuration_information4 = 'Y'         AND
            l_template_rec.sf_setup.frs_setup(i).result_name = 'FED_TO_NET_PAY' THEN
           l_template_rec.sf_setup.frs_setup(i).element_name := l_element.element_name || ' Paid MP';
           l_template_rec.sf_setup.frs_setup(i).input_value_name := 'Pay Value';
        END IF;


        IF g_debug THEN
          pay_in_utils.trace('===================================','================');
          pay_in_utils.trace('result_name       ',l_template_rec.sf_setup.frs_setup(i).result_name);
          pay_in_utils.trace('result_rule_type  ',l_template_rec.sf_setup.frs_setup(i).result_rule_type);
          pay_in_utils.trace('input_value_name  ',l_template_rec.sf_setup.frs_setup(i).input_value_name);
          pay_in_utils.trace('element_name      ',l_template_rec.sf_setup.frs_setup(i).element_name);
          pay_in_utils.trace('severity_level    ',l_template_rec.sf_setup.frs_setup(i).severity_level);
          pay_in_utils.trace('exclusion_tag     ',l_template_rec.sf_setup.frs_setup(i).exclusion_tag);
          pay_in_utils.trace('===================================','================');
        END IF;

      -- Check for Exclusions
      l_cr_result := TRUE ;
      IF l_template_rec.sf_setup.frs_setup(i).exclusion_tag IS NOT NULL THEN
         pay_in_utils.set_location(g_debug,l_procedure,110);

         FOR j IN 1..l_template_rec.er_setup.COUNT
	 LOOP
           pay_in_utils.trace('===================================','================');
           pay_in_utils.trace('ff_column',l_template_rec.er_setup(j).ff_column);
           pay_in_utils.trace('value',l_template_rec.er_setup(j).value);
           pay_in_utils.trace('rule_id=',l_template_rec.er_setup(j).rule_id);
           pay_in_utils.trace('===================================','================');

             IF l_template_rec.er_setup(j).tag = l_template_rec.sf_setup.frs_setup(i).exclusion_tag
	     THEN
	       pay_in_utils.set_location(g_debug,l_procedure,120);

	       l_excl_def_value := l_template_rec.er_setup(j).value;
	       l_ff_column      := l_template_rec.er_setup(j).ff_column;
               pay_in_utils.trace('l_excl_def_value',l_excl_def_value);

	       EXIT ;
             END IF ;
	 END LOOP ;

        pay_in_utils.set_location(g_debug,l_procedure,130);
        SELECT DECODE(l_ff_column,
                     'CONFIGURATION_INFORMATION2',l_template.configuration_information2,
                     'CONFIGURATION_INFORMATION3',l_template.configuration_information3,
                     'CONFIGURATION_INFORMATION4',l_template.configuration_information4,
                     'CONFIGURATION_INFORMATION5',l_template.configuration_information5,
                     'CONFIGURATION_INFORMATION6',l_template.configuration_information6,
                     'CONFIGURATION_INFORMATION7',l_template.configuration_information7,
                     'CONFIGURATION_INFORMATION8',l_template.configuration_information8,
                     'CONFIGURATION_INFORMATION9',l_template.configuration_information9,
                     'CONFIGURATION_INFORMATION10',l_template.configuration_information10)
        INTO l_excl_set_value
        FROM dual ;
        pay_in_utils.trace('l_excl_set_value',l_excl_set_value);

        IF l_excl_set_value = l_excl_def_value THEN
       /* if the two values are different, then we need to create the result */
           l_cr_result := FALSE;
        END IF ;

     END IF ;

     /* At this stage we are aware of whether we want to create the result or not */
     IF l_cr_result THEN
        pay_in_utils.set_location(g_debug,l_procedure,140);

        IF (l_template_rec.sf_setup.frs_setup(i).result_rule_type = 'I' AND
            l_template_rec.sf_setup.frs_setup(i).element_name IS NULL) THEN
            NULL;
        ELSE
        pay_in_utils.ins_form_res_rule
         (
           p_business_group_id         => l_element.business_group_id
          ,p_effective_date            => l_element.effective_start_date
          ,p_status_processing_rule_id => l_template_rec.sf_setup.status_rule_id
          ,p_input_value_name          => l_template_rec.sf_setup.frs_setup(i).input_value_name
          ,p_element_name              => l_template_rec.sf_setup.frs_setup(i).element_name
          ,p_result_name               => l_template_rec.sf_setup.frs_setup(i).result_name
          ,p_result_rule_type          => l_template_rec.sf_setup.frs_setup(i).result_rule_type
          ,p_severity_level            => l_template_rec.sf_setup.frs_setup(i).severity_level
          ,p_element_type_id           => l_element.element_type_id
         );
        END IF;

     END IF ;

     END LOOP ;

   END IF ;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,170);
END element_template_post_process;

--------------------------------------------------------------------------
-- Name           : DELETE_PRE_PROCESS                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the elements for ETW        --
-- Parameters     :                                                     --
--             IN : p_template_id          NUMBER                       --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE delete_pre_process
          (p_template_id    IN NUMBER)
IS

   CURSOR csr_et IS
      SELECT pet.element_type_id
           , pet.effective_start_date
      FROM   pay_element_types_f pet,
             pay_shadow_element_types pset
      WHERE  pset.template_id = p_template_id
      AND    pset.element_name = pet.element_name;

   l_procedure CONSTANT VARCHAR2(100) := g_package ||'delete_pre_process';

BEGIN
   g_debug := hr_utility.debug_enabled;
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   FOR i IN csr_et
   LOOP
     pay_in_utils.set_location(g_debug,l_procedure,20);
     IF g_debug THEN
          pay_in_utils.trace('Element Type Id ',i.element_type_id);
          pay_in_utils.trace('Effective Date  ',to_char(i.effective_start_date,'DD-Mon-YYYY'));
     END IF ;

     pay_in_utils.del_form_res_rule(i.element_type_id, i.effective_start_date);

   END LOOP ; -- csr_et ends

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,100);


EXCEPTION
   WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,120);
      pay_in_utils.trace('SQL Code ',SQLCODE);
      pay_in_utils.trace('SQL Code ',SQLERRM);
      RAISE ;
END delete_pre_process;

END pay_in_element_template_pkg;

/
