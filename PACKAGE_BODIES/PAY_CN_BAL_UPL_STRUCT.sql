--------------------------------------------------------
--  DDL for Package Body PAY_CN_BAL_UPL_STRUCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_BAL_UPL_STRUCT" AS
/* $Header: pycnbups.pkb 115.6 2003/12/29 04:21:08 sshankar noship $ */

-- Global declarations
   TYPE char_array IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
   TYPE num_array  IS TABLE OF NUMBER(16) INDEX BY BINARY_INTEGER;

   g_leg_code    CONSTANT  VARCHAR2(2) := 'CN';

-- Balance Type Cache
   g_baltyp_tbl_id          num_array;
   g_baltyp_tbl_jl          num_array;
   g_baltyp_tbl_name        char_array;
   g_baltyp_tbl_uom         char_array;
   g_nxt_free_baltyp        NUMBER;

-- Balance Dimension Cache
   g_baldim_tbl_id          num_array;
   g_baldim_tbl_name        char_array;
   g_nxt_free_baldim        NUMBER;

-- Jurisdiction Level Cache
   g_jur_lev_tbl            num_array;
   g_nxt_free_jl            NUMBER;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : LOCAL_ERROR                                         --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : This PROCEDURE IS called whenever an error needs to --
--                  be raised and the retcode IS set to 2 to indicate   --
--                  an error has occurred.                              --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_procedure     VARCHAR2                            --
--                  p_step          NUMBER                              --
--            OUT : retcode         NUMBER                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   14-May-03  statkar  Created this function                      --
--------------------------------------------------------------------------
PROCEDURE local_error(retcode        OUT NOCOPY NUMBER
                     ,p_procedure    IN  VARCHAR2
                     ,p_step         IN  NUMBER)
IS
BEGIN
      retcode := 2;
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'paybalup.'||p_procedure);
      hr_utility.set_message_token('STEP', p_step);
      hr_utility.raise_error;

END local_error;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : PUT_JL_IN_CACHE                                     --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Used to cache Jurisdiction Levels                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_jl            NUMBER                              --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   14-May-03  statkar  Created this function                      --
--------------------------------------------------------------------------
PROCEDURE put_jl_in_cache (p_jl   NUMBER)
IS
    l_jur_level           NUMBER;
    l_count               NUMBER;
    l_found               boolean;
BEGIN

 -- Search for the defined balance in the Cache.

  hr_utility.set_location('paybalup.put_jl_in_cache', 10);
  l_jur_level := nvl(p_jl, 999);
  l_count := 1;
  l_found := FALSE;
  --
  WHILE (l_count < g_nxt_free_jl AND l_found = FALSE)
  LOOP
    IF (l_jur_level =  g_jur_lev_tbl(l_count)) THEN
    --
       hr_utility.set_location('paybalup.put_jl_in_cache', 20);
       l_found := TRUE;
    --
    END IF;
    l_count := l_count + 1;

  END LOOP;
  --
  hr_utility.set_location('paybalup.put_jl_in_cache', 30);
  --
  IF (l_found = FALSE) THEN
       g_jur_lev_tbl(g_nxt_free_jl) := l_jur_level;
       g_nxt_free_jl := g_nxt_free_jl + 1;
  END IF;

END put_jl_in_cache;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_BALANCE_TYPE                                  --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Used to cache Jurisdiction Levels                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_baltype_name     VARCHAR2                         --
--                  p_busgrp_id        NUMBER                           --
--                  p_leg_code         VARCHAR2                         --
--            OUT : retcode         NUMBER                              --
--                  p_baltype_id    NUMBER                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   14-May-03  statkar  Created this function                      --
-- 1.1   19-May-03  statkar  Removed coding standard errors             --
-- 1.2   11-Jun-03  statkar  Removed the upper clause                   --
--------------------------------------------------------------------------
PROCEDURE check_balance_type(p_baltype_id   OUT NOCOPY NUMBER
                            ,p_baltype_name VARCHAR2
                            ,p_busgrp_id    NUMBER
                            ,p_leg_code     VARCHAR2
                            ,retcode        OUT NOCOPY NUMBER)
IS
    l_balance_type_id     pay_balance_types.balance_type_id%TYPE;
    l_baltyp_name         pay_balance_types.balance_name%TYPE;
    l_bal_uom             pay_balance_types.balance_uom%TYPE;
    l_jurisdiction_level  NUMBER;
    l_count               NUMBER;
    l_found               BOOLEAN;

    CURSOR csr_bal_type (l_bal_type_name IN VARCHAR2) IS
       SELECT balance_type_id,
              nvl(jurisdiction_level, 999),
              balance_uom
       FROM   pay_balance_types
       WHERE  balance_name          = l_baltyp_name
       AND   (  ( business_group_id = p_busgrp_id)
             OR (   business_group_id IS null
                AND legislation_code = p_leg_code
                )
             OR (   business_group_id IS null
                AND legislation_code IS null)
             )
       FOR UPDATE OF balance_type_id;

BEGIN

 -- Search for the defined balance in the Cache.

  hr_utility.set_location('paybalup.check_balance_type', 10);
  hr_utility.trace('paybalup.check_balance_type p_baltype_id ' || p_baltype_id );
  hr_utility.trace('paybalup.check_balance_type p_baltype_name ' || p_baltype_name);
  hr_utility.trace('paybalup.check_balance_type p_busgrp_id ' || p_busgrp_id);
  hr_utility.trace('paybalup.check_balance_type p_leg_code ' || p_leg_code);

  l_balance_type_id := null;
  l_baltyp_name := p_baltype_name;
  l_count := 1;
  l_found := FALSE;

  WHILE (l_count < g_nxt_free_baltyp AND l_found = FALSE)
  LOOP
  --
     IF (l_baltyp_name = g_baltyp_tbl_name(l_count)) THEN
     --
       hr_utility.set_location('paybalup.check_balance_type', 20);
       --
       l_balance_type_id := g_baltyp_tbl_id(l_count);
       l_found := TRUE;
     --
     END IF;
     --
     l_count := l_count + 1;
  --
  END LOOP;

 -- If the balance IS not in the Cache get it from the database.

  hr_utility.set_location('paybalup.check_balance_type' || l_baltyp_name, 30);
  --
  IF (l_found = FALSE) THEN
  --
       OPEN csr_bal_type(l_baltyp_name);
       --
       FETCH csr_bal_type
       INTO  l_balance_type_id, l_jurisdiction_level, l_bal_uom;
       --
       IF csr_bal_type%NOTFOUND THEN
       --
         CLOSE csr_bal_type;
         hr_utility.trace('Error:  Failure to find balance type');
         local_error(retcode, 'check_balance_type',1);
       --
       END IF;
       CLOSE csr_bal_type;
       -- Place the defined balance in cache.

       hr_utility.set_location('paybalup.check_balance_type', 40);
       --
       g_baltyp_tbl_name(g_nxt_free_baltyp) := l_baltyp_name;
       g_baltyp_tbl_uom(g_nxt_free_baltyp)  := l_bal_uom;
       g_baltyp_tbl_id(g_nxt_free_baltyp)   := l_balance_type_id;
       g_baltyp_tbl_jl(g_nxt_free_baltyp)   := l_jurisdiction_level;
       g_nxt_free_baltyp                    := g_nxt_free_baltyp + 1;
       --
       put_jl_in_cache(l_jurisdiction_level);
  --
  END IF;

  p_baltype_id := l_balance_type_id;

EXCEPTION
   WHEN OTHERS THEN
       IF csr_bal_type%ISOPEN THEN
           CLOSE csr_bal_type;
            END IF;
            p_baltype_id := NULL;
END check_balance_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_BALANCE_DIM                                   --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Used to cache Jurisdiction Levels                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_baldim_name      VARCHAR2                         --
--                  p_busgrp_id        NUMBER                           --
--                  p_leg_code         VARCHAR2                         --
--            OUT : retcode         NUMBER                              --
--                  p_baldim_id     NUMBER                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   14-May-03  statkar  Created this function                      --
-- 1.1   19-May-03  statkar  Removed the coding standard errors         --
--------------------------------------------------------------------------
PROCEDURE check_balance_dim(p_baldim_id    OUT NOCOPY NUMBER
                           ,p_baldim_name      VARCHAR2
                           ,p_busgrp_id        NUMBER
                           ,p_leg_code         VARCHAR2
                           ,retcode        OUT NOCOPY NUMBER)
IS
    l_baldim_name         pay_balance_dimensions.dimension_name%TYPE;
    l_count               NUMBER;
    l_found               BOOLEAN;
    l_balance_dim_id      pay_balance_dimensions.balance_dimension_id%TYPE;

    CURSOR csr_bal_dim (l_bal_dim_name IN VARCHAR2) IS
       SELECT balance_dimension_id
       FROM   pay_balance_dimensions
       WHERE  upper(dimension_name) = l_baldim_name
       AND    (  (business_group_id = p_busgrp_id)
              OR (business_group_id IS null AND legislation_code = p_leg_code)
              OR (business_group_id IS null AND legislation_code IS null)
              );

BEGIN

 -- Search for the defined balance in the Cache.

  hr_utility.set_location('paybalup.check_balance_dim', 10);
  --
  l_balance_dim_id := null;
  l_baldim_name := upper(p_baldim_name);
  l_count := 1;
  l_found := FALSE;
  --
  WHILE (l_count < g_nxt_free_baldim AND l_found = FALSE)
  LOOP
    IF (l_baldim_name = g_baldim_tbl_name(l_count)) THEN
    --
       hr_utility.set_location('paybalup.check_balance_dim', 20);
       l_balance_dim_id := g_baldim_tbl_id(l_count);
       l_found := TRUE;
    --
    END IF;
    --
    l_count := l_count + 1;
  --
  END LOOP;

 -- If the balance IS not in the Cache get it from the database.

  hr_utility.set_location('paybalup.check_balance_dim', 30);
  --
  IF (l_found = FALSE) THEN
  --
      OPEN  csr_bal_dim(l_baldim_name);
      FETCH csr_bal_dim
      INTO  l_balance_dim_id;

      IF csr_bal_dim%NOTFOUND THEN
      --
          CLOSE csr_bal_dim;
          hr_utility.trace('Error:  Failure to find balance dimension');
          local_error(retcode,'check_balance_dim',2);
      --
      END IF;
      CLOSE csr_bal_dim;
      -- Place the defined balance in cache.

      hr_utility.set_location('paybalup.check_balance_dim', 40);
      --
      g_baldim_tbl_name(g_nxt_free_baldim) := l_baldim_name;
      g_baldim_tbl_id(g_nxt_free_baldim) := l_balance_dim_id;
      g_nxt_free_baldim := g_nxt_free_baldim + 1;
  --
  END IF;
  --
  p_baldim_id := l_balance_dim_id;
  --
EXCEPTION
    WHEN OTHERS THEN
    IF csr_bal_dim%ISOPEN THEN
       CLOSE csr_bal_dim;
        END IF;
   p_baldim_id := NULL;
END check_balance_dim;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : VALIDATE_BATCH_DATA                                 --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : This function verifies that the business group,     --
--                  balance types, and balance dimensions actually exist--
--                  If not, it would return a retcode  of 2 and         --
--                  raise an exception.                                 --
-- Parameters     :                                                     --
--             IN : p_batch_id          NUMBER                          --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   14-May-03  statkar  Created this function                      --
--------------------------------------------------------------------------
FUNCTION validate_batch_data (p_batch_id   NUMBER)
RETURN NUMBER
IS

      retcode      NUMBER := 0;
      i          NUMBER := 0;
      l_bg_id       per_business_groups.business_group_id%TYPE;
      l_leg_code    per_business_groups.legislation_code%TYPE;
      l_bt_id      pay_balance_types.balance_type_id%TYPE;
      l_bal_dim_id   pay_balance_dimensions.balance_dimension_id%TYPE;
      --
      CURSOR csr_bg IS
         SELECT hou.business_group_id,
                hou.legislation_code
         FROM   per_business_groups       hou,
                pay_balance_batch_headers bbh
         WHERE  bbh.batch_id    = p_batch_id
         AND    upper(hou.name) = upper(bbh.business_group_name);
      --
      CURSOR c_each_batch (c_batch_id   NUMBER) IS
         SELECT balance_name,
                dimension_name
         FROM   pay_balance_batch_lines
         WHERE  batch_id = c_batch_id;

BEGIN
      hr_utility.set_location('paybalup.validate_batch_data', 10);
--
-- Check business group exists
--
      OPEN  csr_bg;
      FETCH csr_bg
      INTO l_bg_id, l_leg_code;

      IF csr_bg%NOTFOUND THEN
           CLOSE csr_bg;
           local_error(retcode, 'validate_batch_data', 3);
      END IF;
      CLOSE csr_bg;
      --
      hr_utility.set_location('paybalup.validate_batch_data', 20);
      --
      FOR l_each_batch_rec IN c_each_batch (p_batch_id)
      LOOP
      --
         check_balance_type(l_bt_id,
                            l_each_batch_rec.balance_name,
                            l_bg_id,
                            l_leg_code,
                            retcode);
      --
         check_balance_dim(l_bal_dim_id,
                           l_each_batch_rec.dimension_name,
                           l_bg_id,
                           l_leg_code,
                           retcode);
       --
       END LOOP;
       --
       RETURN retcode;
EXCEPTION
    WHEN OTHERS THEN
        IF csr_bg%ISOPEN THEN
            CLOSE csr_bg;
            END IF;
        local_error(retcode,'validate_batch_data',4);

END validate_batch_data;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_BAL_UPL_STRUCT                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure Called from SRS                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_input_value_limit     NUMBER                      --
--                  p_batch_id              NUMBER                      --
--            OUT : retcode                 NUMBER                      --
--                  errbuf                  VARCHAR2                    --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   14-May-03  statkar  Created this function                      --
-- 1.1   19-Jun-03  bramajey Initialized global variables and           --
-- 1.2                       defaulted l_no_input_values in case        --
--                           is not null                                --
-- 1.3   24-Dec-03  sshankar Changed cursor csr_is_balance_fed          --
--                           (Bug 3305878)                              --
--------------------------------------------------------------------------
PROCEDURE create_bal_upl_struct (errbuf         OUT NOCOPY VARCHAR2
                                ,retcode        OUT NOCOPY NUMBER
                                ,p_input_value_limit   IN  NUMBER
                                ,p_batch_id            IN  NUMBER)
-- errbuf and retcode are special parameters needed for the SRS.
-- retcode = 0 means no error and retcode = 2 means an error occurred.
IS

      l_n_elems         NUMBER := 0;
      j                 NUMBER;
      l_bal_uom         pay_balance_types.balance_uom%TYPE;
      l_element_name    pay_element_types.element_name%TYPE;
      l_element_type_id pay_element_types.element_type_id%TYPE;
      l_elem_link_id    pay_element_links.element_link_id%TYPE;
      l_input_val_id    pay_input_values.input_value_id%TYPE;
      l_bal_name        pay_balance_types.balance_name%TYPE;
      l_bal_type_id     pay_balance_types.balance_type_id%TYPE;
      l_bal_feed_id     pay_balance_feeds.balance_feed_id%TYPE;
      l_bg_name         hr_organization_units.name%TYPE;
      l_bg_id           hr_organization_units.organization_id%TYPE;
      l_jur_level       NUMBER;
      l_jur_count       NUMBER;
      l_bal_count       NUMBER;
      l_no_bal_for_jur  NUMBER;
      l_dummy_id        NUMBER;
      l_currency_code   per_business_groups.currency_code%TYPE;
      l_source_iv       NUMBER(2) := 0;
      l_source_iv_val   pay_legislation_rules.rule_mode%TYPE;
      l_source_text_iv  NUMBER(2) := 0;
      l_source_text_iv_val  pay_legislation_rules.rule_mode%TYPE;
      l_leg_code        pay_legislation_rules.legislation_code%TYPE;
      l_seq_NUMBER      NUMBER(2);
      l_no_input_values NUMBER(10) := 1;

--
-- Bug 3305878
-- Start
-- Changed condition in cursor csr_is_balance_fed from
--    BF.balance_type_id + 0 = p_balance_type_id
-- to
--    BF.balance_type_id  = p_balance_type_id
--

 CURSOR csr_is_balance_fed (p_balance_type_id NUMBER,
                                 p_business_group  NUMBER)
      IS
         SELECT balance_feed_id
         FROM   pay_balance_feeds_f BF,
                pay_input_values_f IV,
                pay_element_types_f ET,
                pay_element_classifications EC
         WHERE  EC.classification_name = 'Balance Initialization'
         AND    ET.classification_id   = EC.classification_id
         AND    IV.element_type_id     = ET.element_type_id
         AND    IV.input_value_id      = BF.input_value_id
         AND    BF.balance_type_id     = p_balance_type_id
         AND    nvl(BF.business_group_id, p_business_group) = p_business_group;

--
-- End
-- Bug 3305878
--

      CURSOR csr_bg IS
         SELECT pbg.business_group_id
               ,bbh.business_group_name
               ,pbg.currency_code
              ,pbg.legislation_code
         FROM   pay_balance_batch_headers bbh
               ,per_business_groups       pbg
         WHERE  batch_id        = p_batch_id
         AND    upper(pbg.name) = upper(bbh.business_group_name);

      CURSOR csr_rule1 (p_leg_code IN VARCHAR2)
      IS
         SELECT 1, rule_mode
         FROM   pay_legislation_rules
         WHERE  rule_type        ='SOURCE_IV'
         AND    legislation_code = p_leg_code;

      CURSOR csr_rule2 (p_leg_code IN VARCHAR2)
      IS
         SELECT 1, rule_mode
         FROM   pay_legislation_rules
         WHERE  rule_type        ='SOURCE_TEXT_IV'
         AND    legislation_code = p_leg_code;

BEGIN
   --
      hr_utility.set_location('paybalup.create_bal_upl_struct', 10);

      OPEN  csr_bg;
      FETCH csr_bg
      INTO  l_bg_id, l_bg_name, l_currency_code, l_leg_code;
      CLOSE csr_bg;

      retcode := validate_batch_data (p_batch_id);
      --
      OPEN  csr_rule1 (l_leg_code);
      FETCH csr_rule1
      INTO  l_source_iv, l_source_iv_val;
      --
      IF csr_rule1%NOTFOUND THEN
      --
           l_source_iv     := 0;
           l_source_iv_val := NULL;
      END IF;
      --
      CLOSE csr_rule1;
      --
      OPEN  csr_rule2 (l_leg_code);
      FETCH csr_rule2
      INTO  l_source_text_iv, l_source_text_iv_val;
      --
      IF csr_rule2%NOTFOUND THEN
      --
           l_source_text_iv     := 0;
           l_source_text_iv_val := NULL;
      END IF;
      --
      CLOSE csr_rule2;
      --
      l_jur_count := 1;
      --
      WHILE (l_jur_count < g_nxt_free_jl)
      LOOP
        --
        hr_utility.set_location('paybalup.create_bal_upl_struct', 20);
        --
        l_jur_level :=     g_jur_lev_tbl(l_jur_count);
        l_no_bal_for_jur := 0;
        l_bal_count := 1;
        --
        WHILE (l_bal_count < g_nxt_free_baltyp)
        LOOP
        --
           IF g_baltyp_tbl_jl(l_bal_count) = l_jur_level THEN
               l_no_bal_for_jur := l_no_bal_for_jur + 1;
           END IF;
           --
           l_bal_count := l_bal_count + 1;
           --
        END LOOP;
        --
        -- If Input value limit is not entered or null, we default it to 1
        -- Bug 3006495
        --
        IF (p_input_value_limit IS null) OR (p_input_value_limit = 0 ) THEN
           l_no_input_values := 1;
        ELSE
           IF l_leg_code IN ('US','CA') THEN
              l_no_input_values := p_input_value_limit - 1;
           ELSE
              l_no_input_values := p_input_value_limit;
           END IF;
        END IF;

        /* For cases where NUMBER of balances per jd > 15 */
        l_n_elems := ceil (l_no_bal_for_jur / (l_no_input_values - (l_source_iv + l_source_text_iv)));
        l_bal_count := 1;

        FOR i in 1 .. l_n_elems
        LOOP
        --
            hr_utility.set_location('paybalup.create_bal_upl_struct', 30);
            j := 1;
            --
            -- Bug 3002366
            -- Use local variable l_no_input_values instead of p_input_value_limit
            --
            WHILE ( l_bal_count < g_nxt_free_baltyp AND j <= l_no_input_values )
            LOOP

               hr_utility.set_location('paybalup.create_bal_upl_struct', 40);
               --
               IF (g_baltyp_tbl_jl(l_bal_count) = l_jur_level) THEN
               --
                  OPEN csr_is_balance_fed(g_baltyp_tbl_id(l_bal_count), l_bg_id);
                  FETCH csr_is_balance_fed INTO l_dummy_id;

                  IF (csr_is_balance_fed%NOTFOUND) THEN
                  --
                  --    If this IS the first balance found for this element
                  --    create the element.
                  --
                     -- Changes for bug 3040744 starts
                     --
                     -- Load Balance Name into Local variable
                     --
                     l_bal_name      := g_baltyp_tbl_name(l_bal_count);

                     IF j = 1 THEN
                     --
                        l_seq_NUMBER := 1;

                        -- Changes for bug 3040744 ends
                        --
                        --   create an element type and name it as follows:
                        --   initial_value_element concatenated with the
                        --   batch id, jurisdiction level, and a NUMBER
                        --   identifying which element type it IS that's being
                        --   created.
                        --
                        l_element_name := 'Initial_Value_Element_' ||
                                          p_batch_id ||
                                          '_' ||
                                          l_jur_level||
                                          '_' ||
                                          to_char(i);

                        hr_utility.trace ('Element Name IS:' || l_element_name);

                        l_element_type_id :=
                            pay_db_pay_setup.create_element (
                                         p_element_name           => l_element_name,
                                         p_effective_start_date   => to_date('01/01/0001', 'DD/MM/YYYY'),
                                         p_effective_end_date     => to_date('31/12/4712','DD/MM/YYYY'),
                                         p_classification_name    => 'Balance Initialization',
                                         p_input_currency_code    => l_currency_code,
                                         p_output_currency_code   => l_currency_code,
                                         p_processing_type        => 'N',
                                         p_adjustment_only_flag   => 'Y',
                                         p_process_in_run_flag    => 'Y',
                                         p_legislation_code       => NULL,
                                         p_business_group_name    => l_bg_name,
                                         p_processing_priority    => 0,
                                         p_post_termination_rule  => 'Final Close');

                        hr_utility.trace ('Element name after IS:' || l_element_name);

                        UPDATE pay_element_types_f ELEM
                        SET    ELEM.element_information1 = 'B'
                        WHERE  element_type_id = l_element_type_id;
                        --
                        -- create an element link for each element type created.
                        -- point it to each of the element type created.
                        --
                        l_elem_link_id :=
                               pay_db_pay_setup.create_element_link (
                                         p_element_name          => l_element_name,
                                         p_link_to_all_pyrlls_fl => 'Y',
                                         p_standard_link_flag    => 'N',
                                         p_effective_start_date  =>  TO_DATE('01-01-0001','DD-MM-YYYY'),
                                         p_effective_end_date    =>  TO_DATE('31-12-4712','DD-MM-YYYY'),
                                         p_business_group_name   => l_bg_name);
                        --
                        -- create a 'Jurisdiction' input value for each
                        -- element type.
                        --
                        IF l_leg_code = g_leg_code THEN
                           l_input_val_id :=
                             pay_db_pay_setup.create_input_value (
                                 p_element_name         => l_element_name,
                                 p_name                 => 'Jurisdiction',
                                 p_uom_code             => 'C',
                                 p_business_group_name  => l_bg_name,
                                 p_display_sequence     => l_seq_NUMBER,
                                 p_effective_start_date => to_date('01-01-0001','DD-MM-YYYY'),
                                 p_effective_end_date   => to_date('31-12-4712','DD-MM-YYYY'));

                           l_seq_NUMBER := l_seq_NUMBER + 1;

                           hr_input_values.create_link_input_value(
                                 p_insert_type           => 'INSERT_INPUT_VALUE',
                                 p_element_link_id       => l_elem_link_id,
                                 p_input_value_id        => l_input_val_id,
                                 p_input_value_name      => 'Jurisdiction',
                                 p_costable_type         => NULL,
                                 p_validation_start_date => to_date('01-01-0001','DD-MM-YYYY'),
                                 p_validation_end_date   => to_date('31-12-4712','DD-MM-YYYY'),
                                 p_default_value         => NULL,
                                 p_max_value             => NULL,
                                 p_min_value             => NULL,
                                 p_warning_or_error_flag => NULL,
                                 p_hot_default_flag      => NULL,
                                 p_legislation_code      => NULL,
                                 p_pay_value_name        => NULL,
                                 p_element_type_id       => l_element_type_id);

                        END IF; -- l_leg_code = 'CN'

                        IF l_source_iv = 1 THEN

                           l_input_val_id :=
                             pay_db_pay_setup.create_input_value (
                                 p_element_name         => l_element_name,
                                 p_name                 => l_source_iv_val,
                                 p_uom_code             => 'C',
                                 p_business_group_name  => l_bg_name,
                                 p_display_sequence     => l_seq_NUMBER,
                                 p_effective_start_date => to_date('01-01-0001','DD-MM-YYYY'),
                                 p_effective_end_date   => to_date('31-12-4712','DD-MM-YYYY'));

                           l_seq_NUMBER := l_seq_NUMBER + 1;

                           hr_input_values.create_link_input_value(
                                 p_insert_type           => 'INSERT_INPUT_VALUE',
                                 p_element_link_id       => l_elem_link_id,
                                 p_input_value_id        => l_input_val_id,
                                 p_input_value_name      => l_source_iv_val,
                                 p_costable_type         => NULL,
                                 p_validation_start_date =>
                                    to_date('01-01-0001','DD-MM-YYYY'),
                                 p_validation_end_date   =>
                                   to_date('31-12-4712','DD-MM-YYYY'),
                                 p_default_value         => NULL,
                                 p_max_value             => NULL,
                                 p_min_value             => NULL,
                                 p_warning_or_error_flag => NULL,
                                 p_hot_default_flag      => NULL,
                                 p_legislation_code      => NULL,
                                 p_pay_value_name        => NULL,
                                 p_element_type_id       => l_element_type_id);

                         END IF; -- l_source_iv = 1

                         IF l_source_text_iv = 1 THEN

                           l_input_val_id :=
                             pay_db_pay_setup.create_input_value (
                                 p_element_name         => l_element_name,
                                 p_name                 => l_source_text_iv_val,
                                 p_uom_code             => 'C',
                                 p_business_group_name  => l_bg_name,
                                 p_display_sequence     => l_seq_NUMBER,
                                 p_effective_start_date => to_date('01-01-0001','DD-MM-YYYY'),
                                 p_effective_end_date   => to_date('31-12-4712','DD-MM-YYYY'));

                           l_seq_NUMBER := l_seq_NUMBER + 1;

                           hr_input_values.create_link_input_value(
                                 p_insert_type           => 'INSERT_INPUT_VALUE',
                                 p_element_link_id       => l_elem_link_id,
                                 p_input_value_id        => l_input_val_id,
                                 p_input_value_name      => l_source_text_iv_val,
                                 p_costable_type         => NULL,
                                 p_validation_start_date => to_date('01-01-0001','DD-MM-YYYY'),
                                 p_validation_end_date   => to_date('31-12-4712','DD-MM-YYYY'),
                                 p_default_value         => NULL,
                                 p_max_value             => NULL,
                                 p_min_value             => NULL,
                                 p_warning_or_error_flag => NULL,
                                 p_hot_default_flag      => NULL,
                                 p_legislation_code      => NULL,
                                 p_pay_value_name        => NULL,
                                 p_element_type_id       => l_element_type_id);

                          END IF; -- l_source_text_iv = 1

                          j := l_seq_NUMBER;

                     END IF;
                      --
                      -- create an input value for each balance_name selected and
                      -- name it after the balance it IS created for.
                      --

                      l_input_val_id :=
                         pay_db_pay_setup.create_input_value (
                                    p_element_name         => l_element_name,
                                    p_name                 => substr(l_bal_name, 1, 28)||j,
                                    p_uom_code             => g_baltyp_tbl_uom(l_bal_count),
                                    p_business_group_name  => l_bg_name,
                                    p_effective_start_date => to_date('01-01-0001','DD-MM-YYYY'),
                                    p_effective_end_date   => to_date('31-12-4712','DD-MM-YYYY'),
                                    p_display_sequence     => j);
                      --
                      -- create a balance feed for each input value created.
                      -- point each to its corresponding input value.
                      --
                      hr_balances.ins_balance_feed(
                           p_option                      => 'INS_MANUAL_FEED',
                           p_input_value_id              => l_input_val_id,
                           p_element_type_id             => l_element_type_id,
                           p_primary_classification_id   => NULL,
                           p_sub_classification_id       => NULL,
                           p_sub_classification_rule_id  => NULL,
                           p_balance_type_id             => g_baltyp_tbl_id(l_bal_count),
                           p_scale                       => '1',
                           p_session_date                => to_date('01-01-0001','DD-MM-YYYY'),
                           p_business_group              => l_bg_id,
                           p_legislation_code            => NULL,
                           p_mode                        => 'USER');
                     --
                     -- create a link input value for each input value created.
                     --
                     hr_input_values.create_link_input_value(
                           p_insert_type           => 'INSERT_INPUT_VALUE',
                           p_element_link_id       => l_elem_link_id,
                           p_input_value_id        => l_input_val_id,
                           p_input_value_name      => substr(l_bal_name, 1 , 28)||j,
                           p_costable_type         => NULL,
                           p_validation_start_date => to_date('01-01-0001','DD-MM-YYYY'),
                           p_validation_end_date   => to_date('31-12-4712','DD-MM-YYYY'),
                           p_default_value         => NULL,
                           p_max_value             => NULL,
                           p_min_value             => NULL,
                           p_warning_or_error_flag => NULL,
                           p_hot_default_flag      => NULL,
                           p_legislation_code      => NULL,
                           p_pay_value_name        => NULL,
                           p_element_type_id       => l_element_type_id);

                     j := j + 1;
                     --
                  END IF;
                  --
                  CLOSE csr_is_balance_fed;
               --
               END IF;
               --
               l_bal_count := l_bal_count + 1;
            --
            END LOOP;
            --
         END LOOP;
         --
         l_jur_count := l_jur_count + 1;
      --
      END LOOP;

      COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        IF csr_bg%ISOPEN THEN
            CLOSE csr_bg;
        END IF;
        IF csr_rule1%ISOPEN THEN
            CLOSE csr_rule1;
        END IF;
        IF csr_rule2%ISOPEN THEN
            CLOSE csr_rule2;
        END IF;
        IF csr_is_balance_fed%ISOPEN THEN
            CLOSE csr_is_balance_fed;
        END IF;
        errbuf :=SQLERRM;
        local_error(retcode,'create_bal_upl_struct',1);
END create_bal_upl_struct;
-- Bug # 3006495
-- Added the following initialization section
BEGIN
  g_nxt_free_baltyp := 1;
  g_nxt_free_baldim := 1;
  g_nxt_free_jl     := 1;
END pay_cn_bal_upl_struct;

/
