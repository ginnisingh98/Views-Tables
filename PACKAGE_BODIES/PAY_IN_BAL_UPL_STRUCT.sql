--------------------------------------------------------
--  DDL for Package Body PAY_IN_BAL_UPL_STRUCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_BAL_UPL_STRUCT" AS
/* $Header: pyinbups.pkb 120.2 2006/04/27 04:01:00 rpalli noship $ */


-- Global declarations
type char_array is table of varchar2(80) index by binary_integer;
type num_array  is table of number(16) index by binary_integer;
g_package   constant VARCHAR2(100) := 'pay_in_bal_upl_struct.' ;
g_leg_code  CONSTANT VARCHAR2(2):='IN';
g_debug     BOOLEAN ;

-- Balance Type Cache
g_baltyp_tbl_id num_array;
g_baltyp_tbl_jl num_array;
g_baltyp_tbl_name char_array;
g_baltyp_tbl_uom char_array;
g_nxt_free_baltyp number;

-- Balance Dimension Cache
g_baldim_tbl_id num_array;
g_baldim_tbl_name char_array;
g_nxt_free_baldim number;

-- Jurisdiction Level Cache
g_jur_lev_tbl num_array;
g_nxt_free_jl number;

   PROCEDURE local_error(retcode	OUT NOCOPY number,
                         p_procedure    IN  varchar2,
                         p_step         IN  number) IS

/* This procedure is called whenever an error needs to be raised and
   the retcode is set to 2 to indicate an error has occurred.
*/

   BEGIN

      retcode := 2;
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', g_package||p_procedure);
      hr_utility.set_message_token('STEP', p_step);
      hr_utility.raise_error;

   END local_error;

PROCEDURE put_jl_in_cache (p_jl   NUMBER)
IS
l_jur_level           number;
l_count               number;
l_found               boolean;
l_procedure           VARCHAR2(100);
l_message             VARCHAR2(255);
BEGIN

 -- Search for the defined balance in the Cache.
 g_debug := hr_utility.debug_enabled ;
 l_procedure := g_package || 'put_jl_in_cache' ;
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 l_jur_level := nvl(p_jl, 999);
 l_count := 1;
 l_found := FALSE;
 WHILE (l_count < g_nxt_free_jl and l_found = FALSE) LOOP
    if (l_jur_level = g_jur_lev_tbl(l_count)) then
       pay_in_utils.set_location(g_debug,l_procedure,20);
       l_found := TRUE;
    END IF;
    l_count := l_count + 1;
 END LOOP;

 IF (l_found = FALSE) THEN
    g_jur_lev_tbl(g_nxt_free_jl) := l_jur_level;
    g_nxt_free_jl := g_nxt_free_jl + 1;
 END IF;
 pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,30);
EXCEPTION
  WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
      pay_in_utils.trace(l_message,l_procedure);
END put_jl_in_cache;

PROCEDURE check_balance_type(p_baltype_id   out NOCOPY NUMBER,
                             p_baltype_name VARCHAR2,
                             p_busgrp_id    NUMBER,
                             p_leg_code     VARCHAR2,
                             retcode        OUT NOCOPY NUMBER)
IS
l_balance_type_id     NUMBER;
l_baltyp_name         VARCHAR2(80);
l_bal_uom             VARCHAR2(80);
l_jurisdiction_level  NUMBER;
l_count               NUMBER;
l_found               BOOLEAN;
l_procedure           VARCHAR2(100);
l_message             VARCHAR2(255);

 CURSOR csr_bal_type (l_bal_type_name IN VARCHAR2) IS
 SELECT balance_type_id,
              nvl(jurisdiction_level, 999),
              balance_uom
        FROM   pay_balance_types
       WHERE  upper(balance_name) = upper(l_baltyp_name)
       AND    ((business_group_id = p_busgrp_id)
             OR(   business_group_id is null
               AND legislation_code = p_leg_code)
             OR(   business_group_id IS NULL
               AND legislation_code IS NULL)
              )
       FOR UPDATE OF balance_type_id;
BEGIN

 -- Search for the defined balance in the Cache.
 g_debug := hr_utility.debug_enabled ;
 l_procedure := g_package || 'check_balance_type' ;
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_baltype_id                  : ',p_baltype_id);
  pay_in_utils.trace('p_baltype_name                : ',p_baltype_name);
  pay_in_utils.trace('p_busgrp_id                   : ',p_busgrp_id);
  pay_in_utils.trace('p_leg_code                    : ',p_leg_code);
  pay_in_utils.trace('******************************','********************');
end if;

 l_balance_type_id := NULL;
 l_baltyp_name := p_baltype_name;
 l_count := 1;
 l_found := FALSE;
 WHILE (l_count < g_nxt_free_baltyp and l_found = FALSE) LOOP
    IF (l_baltyp_name = g_baltyp_tbl_name(l_count)) THEN
       pay_in_utils.set_location(g_debug,l_procedure,20);
       l_balance_type_id := g_baltyp_tbl_id(l_count);
       l_found := TRUE;
    END IF;
    l_count := l_count + 1;
 END LOOP;

 -- If the balance is not in the Cache get it from the database.

 pay_in_utils.set_location(g_debug,l_procedure,30);
 pay_in_utils.trace('l_baltyp_name                    : ',l_baltyp_name);
 if (l_found = FALSE) then
    OPEN csr_bal_type(l_baltyp_name);
    --
    FETCH csr_bal_type
     INTO  l_balance_type_id, l_jurisdiction_level, l_bal_uom;
     --
       IF csr_bal_type%NOTFOUND THEN
         --
         CLOSE csr_bal_type;
         pay_in_utils.trace('Error:  Failure to find balance type',l_procedure);
         local_error(retcode, 'check_balance_type',1);
         --
       END IF;
     CLOSE csr_bal_type;




       -- Place the defined balance in cache.

       pay_in_utils.set_location(g_debug,l_procedure,40);
       g_baltyp_tbl_name(g_nxt_free_baltyp) := l_baltyp_name;
       g_baltyp_tbl_uom(g_nxt_free_baltyp) := l_bal_uom;
       g_baltyp_tbl_id(g_nxt_free_baltyp) := l_balance_type_id;
       g_baltyp_tbl_jl(g_nxt_free_baltyp) := l_jurisdiction_level;
       g_nxt_free_baltyp := g_nxt_free_baltyp + 1;
       put_jl_in_cache(l_jurisdiction_level);


  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);

  p_baltype_id := l_balance_type_id;

EXCEPTION
	WHEN OTHERS THEN
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);
	  IF csr_bal_type%ISOPEN THEN
           CLOSE csr_bal_type;
            END IF;
	p_baltype_id := NULL;
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.trace(l_message,l_procedure);
END check_balance_type;


PROCEDURE check_balance_dim(p_baldim_id  OUT NOCOPY NUMBER,
                            p_baldim_name    VARCHAR2,
                            p_busgrp_id      NUMBER,
                            p_leg_code       VARCHAR2,
                            retcode      OUT NOCOPY NUMBER)
IS
l_baldim_name         varchar2(80);
l_count               number;
l_found               boolean;
l_balance_dim_id      number;
l_procedure           VARCHAR2(100);
l_message             VARCHAR2(255);

CURSOR csr_bal_dim (l_bal_dim_name IN VARCHAR2) IS
SELECT balance_dimension_id
       FROM   pay_balance_dimensions
       WHERE  upper(dimension_name) = l_baldim_name
       AND    ((business_group_id = p_busgrp_id)
             OR(   business_group_id IS NULL
               AND legislation_code = p_leg_code)
             OR(   business_group_id IS NULL
               AND legislation_code IS NULL)
              );
BEGIN

 -- Search for the defined balance in the Cache.
 g_debug := hr_utility.debug_enabled ;
 l_procedure := g_package || 'check_balance_dim' ;
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
 if g_debug then
   pay_in_utils.trace('******************************','********************');
   pay_in_utils.trace('p_baldim_name                  : ',p_baldim_name);
   pay_in_utils.trace('p_busgrp_id                    : ',p_busgrp_id);
   pay_in_utils.trace('p_leg_code                     : ',p_leg_code);
   pay_in_utils.trace('******************************','********************');
 end if;
 l_balance_dim_id := NULL;
 l_baldim_name := UPPER(p_baldim_name);
 l_count := 1;
 l_found := FALSE;
 WHILE (l_count < g_nxt_free_baldim AND l_found = FALSE) LOOP
    IF (l_baldim_name = g_baldim_tbl_name(l_count)) THEN
       pay_in_utils.set_location(g_debug,l_procedure,20);
       l_balance_dim_id := g_baldim_tbl_id(l_count);
       l_found := TRUE;
    END IF;
    l_count := l_count + 1;
 END LOOP;

 -- If the balance is not in the Cache get it from the database.

 pay_in_utils.set_location(g_debug,l_procedure,30);
 IF (l_found = FALSE) then
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

       pay_in_utils.set_location(g_debug,l_procedure,40);
       g_baldim_tbl_name(g_nxt_free_baldim) := l_baldim_name;
       g_baldim_tbl_id(g_nxt_free_baldim) := l_balance_dim_id;
       g_nxt_free_baldim := g_nxt_free_baldim + 1;

  end if;

  p_baldim_id := l_balance_dim_id;

 if g_debug then
   pay_in_utils.trace('******************************','********************');
   pay_in_utils.trace('p_baldim_id                  : ',p_baldim_id);
   pay_in_utils.trace('retcode                      : ',retcode);
   pay_in_utils.trace('******************************','********************');
 end if;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);

EXCEPTION
	WHEN OTHERS THEN
        pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);
	IF csr_bal_dim%ISOPEN THEN
       CLOSE csr_bal_dim;
        END IF;
	p_baldim_id := NULL;
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.trace(l_message,l_procedure);
END check_balance_dim;

   FUNCTION validate_batch_data (p_batch_id number) RETURN number IS

/* This function verifies that the business group, balance types, and
   balance dimensions actually exist.  If not, it would return a retcode
   of 2 and raise an exception.
*/

      retcode		number := 0;
      i			number := 0;
      l_bg_id           per_business_groups.business_group_id%TYPE;
      l_leg_code        per_business_groups.legislation_code%TYPE;
      l_bt_id		pay_balance_types.balance_type_id%TYPE;
      l_bal_dim_id	pay_balance_dimensions.balance_dimension_id%TYPE;
      l_procedure       VARCHAR2(100);
      l_message         VARCHAR2(255);

      CURSOR csr_bg IS
      select hou.business_group_id,
                hou.legislation_code
         from   per_business_groups       hou,
                pay_balance_batch_headers bbh
         where  bbh.batch_id = p_batch_id
         and    upper(hou.name) = upper(bbh.business_group_name);

      cursor c_each_batch (c_batch_id	number) is
         select balance_name,
                dimension_name
         from   pay_balance_batch_lines
         where  batch_id = c_batch_id;

   BEGIN
     g_debug := hr_utility.debug_enabled ;
     l_procedure := g_package || 'validate_batch_data' ;
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
      OPEN  csr_bg;
      FETCH csr_bg
      INTO l_bg_id, l_leg_code;

      IF csr_bg%NOTFOUND THEN
           CLOSE csr_bg;
           local_error(retcode, 'validate_batch_data', 3);
      END IF;
      CLOSE csr_bg;

      pay_in_utils.set_location(g_debug,l_procedure,20);
      for l_each_batch_rec in c_each_batch (p_batch_id) loop

         check_balance_type(l_bt_id, l_each_batch_rec.balance_name,
                            l_bg_id,
                            l_leg_code,
                            retcode);

         check_balance_dim(l_bal_dim_id, l_each_batch_rec.dimension_name,
                            l_bg_id,
                            l_leg_code,
                           retcode);
      end loop;

      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

 if g_debug then
   pay_in_utils.trace('******************************','********************');
   pay_in_utils.trace('retcode                      : ',retcode);
   pay_in_utils.trace('******************************','********************');
 end if;

 return retcode;

EXCEPTION
    WHEN OTHERS THEN
        pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
        IF csr_bg%ISOPEN THEN
            CLOSE csr_bg;
        END IF;
	IF c_each_batch%ISOPEN THEN
	    CLOSE c_each_batch;
        END IF;
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.trace(l_message,l_procedure);
       local_error(retcode,'validate_batch_data',4);
   END validate_batch_data;


   PROCEDURE create_bal_upl_struct (errbuf			OUT NOCOPY varchar2,
				    retcode			OUT NOCOPY number,
				    p_input_value_limit		IN  number,
				    p_batch_id			IN  number) IS

-- errbuf and retcode are special parameters needed for the SRS.
-- retcode = 0 means no error and retcode = 2 means an error occurred.

      l_n_elems			number := 0;
      j				number;
      l_bal_uom			pay_balance_types.balance_uom%TYPE;
      l_element_name		pay_element_types.element_name%TYPE;
      l_element_type_id		pay_element_types.element_type_id%TYPE;
      l_elem_link_id		pay_element_links.element_link_id%TYPE;
      l_input_val_id		pay_input_values.input_value_id%TYPE;
      l_bal_name		pay_balance_types.balance_name%TYPE;
      l_bal_type_id		pay_balance_types.balance_type_id%TYPE;
      l_bal_feed_id		pay_balance_feeds.balance_feed_id%TYPE;
      l_bg_name	                hr_organization_units.name%TYPE;
      l_bg_id                   hr_organization_units.organization_id%TYPE;
      l_jur_level               number;
      l_jur_count               number;
      l_bal_count               number;
      l_no_bal_for_jur          number;
      l_dummy_id                number;
      l_currency_code           per_business_groups.currency_code%TYPE;
      l_source_iv		number(2) := 0;
      l_source_iv_val		VARCHAR2(30);
      l_jur_iv		        number(2) := 0;
      l_jur_iv_val		VARCHAR2(30);
      l_source_text_iv		number(2) := 0;
      l_source_text_iv_val	VARCHAR2(30);
      l_source_text2_iv 	number(2) := 0;
      l_source_text2_iv_val	VARCHAR2(30);
      l_leg_code		pay_legislation_rules.legislation_code%TYPE;
      l_seq_number		NUMBER(2);
      l_no_input_values         NUMBER(10);

      l_message     VARCHAR2(255);
      l_procedure   VARCHAR2(100);

      cursor csr_is_balance_fed (p_balance_type_id number,
                                 p_business_group  number)
      is
         select balance_feed_id
         from   pay_balance_feeds_f BF,
                pay_input_values_f IV,
                pay_element_types_f ET,
                pay_element_classifications EC
         where  EC.classification_name = 'Balance Initialization'
         and    ET.classification_id   = EC.classification_id
         and    IV.element_type_id     = ET.element_type_id
         and    IV.input_value_id      = BF.input_value_id
         and    BF.balance_type_id  = p_balance_type_id
         and    nvl(BF.business_group_id, p_business_group) = p_business_group;

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

      CURSOR csr_rule3 (p_leg_code IN VARCHAR2)
      IS
         select 1, input_value_name
         from pay_legislation_contexts plc, ff_contexts fc
         where legislation_code= p_leg_code
         and plc.context_id = fc.context_id
         and fc.context_name = 'JURISDICTION_CODE';

      CURSOR csr_rule4 (p_leg_code IN VARCHAR2)
      IS
         select 1, input_value_name
         from pay_legislation_contexts plc, ff_contexts fc
         where legislation_code= p_leg_code
         and plc.context_id = fc.context_id
         and fc.context_name = 'SOURCE_TEXT2';

   BEGIN

     g_debug := hr_utility.debug_enabled ;
     l_procedure := g_package || 'create_bal_upl_struct' ;
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

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

     OPEN  csr_rule3 (l_leg_code);
      FETCH csr_rule3
      INTO  l_jur_iv, l_jur_iv_val;
      --
      IF csr_rule3%NOTFOUND THEN
      --
           l_jur_iv     := 0;
           l_jur_iv_val := NULL;
      END IF;
      --
      CLOSE csr_rule3;

     OPEN  csr_rule4 (l_leg_code);
      FETCH csr_rule4
      INTO  l_source_text2_iv, l_source_text2_iv_val;
      --
      IF csr_rule4%NOTFOUND THEN
      --
           l_source_text2_iv     := 0;
           l_source_text2_iv_val := NULL;
      END IF;
      --
      CLOSE csr_rule4;

      l_jur_count := 1;

      while (l_jur_count < g_nxt_free_jl) loop

        pay_in_utils.set_location(g_debug,l_procedure,20);
        l_jur_level := g_jur_lev_tbl(l_jur_count);

        l_no_bal_for_jur := 0;
        l_bal_count := 1;

        while (l_bal_count < g_nxt_free_baltyp) loop
           if g_baltyp_tbl_jl(l_bal_count) = l_jur_level then
               l_no_bal_for_jur := l_no_bal_for_jur + 1;
           end if;
           l_bal_count := l_bal_count + 1;
        end loop;

        IF (p_input_value_limit IS null) OR (p_input_value_limit < 5 ) THEN
           l_no_input_values := 5;
        ELSE
	    l_no_input_values := p_input_value_limit;

	END IF;


         /* for cases where number of balances per jd > 15 */
	 l_n_elems := ceil (l_no_bal_for_jur / (l_no_input_values - (1 + l_source_iv + l_source_text_iv + l_source_text2_iv)));

         l_bal_count := 1;
         for i in 1 .. l_n_elems loop

            pay_in_utils.set_location(g_debug,l_procedure,30);
	    j := 1;
            while (l_bal_count< g_nxt_free_baltyp
                   and j <= l_no_input_values) loop

--             Does this balance have the same jurisdiction level as the
--             current jurisdiction level.

               pay_in_utils.set_location(g_debug,l_procedure,40);
               if (g_baltyp_tbl_jl(l_bal_count) = l_jur_level) then

--                Does this balance already have an initial balance feed.

                  open csr_is_balance_fed(g_baltyp_tbl_id(l_bal_count),
                                          l_bg_id);
                  fetch csr_is_balance_fed into l_dummy_id;

                  if (csr_is_balance_fed%notfound) then
                     /*
                       If this is the first balance found for this element
                       create the element.
                     */
		     l_bal_name      := g_baltyp_tbl_name(l_bal_count);
                     if j = 1 then
			l_seq_number := 1;
                        /*
                           create an element type and name it as follows:
                           initial_value_element concatenated with the
                           batch id, jurisdiction level, and a number
                           identifying which element type it is that's being
                           created.
                        */
                        l_element_name := 'Initial_Value_Element_' ||
                                          p_batch_id ||
                                          '_' ||
                                          l_jur_level||
                                          '_' ||
                                          to_char(i);

                        pay_in_utils.trace (
                                 'Element Name is:' || l_element_name, l_procedure);

                        l_element_type_id := pay_db_pay_setup.create_element (
                            p_element_name           => l_element_name,
                            p_effective_start_date   =>
                                 to_date('01/01/0001', 'DD/MM/YYYY'),
                            p_effective_end_date     =>
                                to_date('31/12/4712','DD/MM/YYYY'),
                            p_classification_name    =>
                                 'Balance Initialization',
                            p_input_currency_code    => l_currency_code,
                            p_output_currency_code   => l_currency_code,
                            p_processing_type        => 'N',
                            p_adjustment_only_flag   => 'Y',
                            p_process_in_run_flag    => 'Y',
                            p_legislation_code       => NULL,
                            p_business_group_name    => l_bg_name,
                            p_processing_priority    => 0,
                            p_post_termination_rule  => 'Final Close');

                        pay_in_utils.trace (
                            'Element name after is:' || l_element_name, l_procedure);

                        update pay_element_types_f ELEM
                        set ELEM.element_information1 = 'B'
                        where element_type_id = l_element_type_id;
                        /*
                           create an element link for each element type created.
                           point it to each of the element type created.
                        */
                        l_elem_link_id :=
                          pay_db_pay_setup.create_element_link (
                              p_element_name          => l_element_name,
                              p_link_to_all_pyrlls_fl => 'Y',
                              p_standard_link_flag    => 'N',
                              p_effective_start_date  =>
                                 to_date('01-01-0001','DD-MM-YYYY'),
                              p_effective_end_date    =>
                                to_date('31-12-4712','DD-MM-YYYY'),
                              p_business_group_name   => l_bg_name);
                        /*
                           create a 'Jurisdiction' input value for each
                           element type.
                        */
	 		if l_leg_code =g_leg_code then
			  IF l_jur_iv = 1 then
        	                l_input_val_id :=
                	          pay_db_pay_setup.create_input_value (
                        	      p_element_name         => l_element_name,
	                              p_name                 => l_jur_iv_val,
        	                      p_uom_code             => 'C',
                	              p_business_group_name  => l_bg_name,
                        	      p_display_sequence     => l_seq_number,
	                              p_effective_start_date =>
        	                         to_date('01-01-0001','DD-MM-YYYY'),
                	              p_effective_end_date   =>
                        	        to_date('31-12-4712','DD-MM-YYYY'));
			      l_seq_number := l_seq_number + 1;

  	                      hr_input_values.create_link_input_value(
        	                      p_insert_type           => 'INSERT_INPUT_VALUE',
                	              p_element_link_id       => l_elem_link_id,
                        	      p_input_value_id        => l_input_val_id,
	                              p_input_value_name      => l_jur_iv_val,
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
                           END IF; -- l_jur_iv = 1
			end if; -- g_leg_code = 'IN'

			if l_source_iv = 1 then

        	                l_input_val_id :=
                	          pay_db_pay_setup.create_input_value (
                        	      p_element_name         => l_element_name,
	                              p_name                 => l_source_iv_val,
        	                      p_uom_code             => 'C',
                	              p_business_group_name  => l_bg_name,
                        	      p_display_sequence     => l_seq_number,
	                              p_effective_start_date =>
        	                         to_date('01-01-0001','DD-MM-YYYY'),
                	              p_effective_end_date   =>
                        	        to_date('31-12-4712','DD-MM-YYYY'));
				l_seq_number := l_seq_number + 1;

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

			end if; -- l_source_iv = 1

			if l_source_text_iv = 1 then

        	                l_input_val_id :=
                	          pay_db_pay_setup.create_input_value (
                        	      p_element_name         => l_element_name,
	                              p_name                 => l_source_text_iv_val,
        	                      p_uom_code             => 'C',
                	              p_business_group_name  => l_bg_name,
                        	      p_display_sequence     => l_seq_number,
	                              p_effective_start_date =>
        	                         to_date('01-01-0001','DD-MM-YYYY'),
                	              p_effective_end_date   =>
                        	        to_date('31-12-4712','DD-MM-YYYY'));
				l_seq_number := l_seq_number + 1;

  	                      hr_input_values.create_link_input_value(
        	                      p_insert_type           => 'INSERT_INPUT_VALUE',
                	              p_element_link_id       => l_elem_link_id,
                        	      p_input_value_id        => l_input_val_id,
	                              p_input_value_name      => l_source_text_iv_val,
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

			end if; -- l_source_text_iv = 1

			if l_source_text2_iv = 1 then

        	                l_input_val_id :=
                	          pay_db_pay_setup.create_input_value (
                        	      p_element_name         => l_element_name,
	                              p_name                 => l_source_text2_iv_val,
        	                      p_uom_code             => 'C',
                	              p_business_group_name  => l_bg_name,
                        	      p_display_sequence     => l_seq_number,
	                              p_effective_start_date =>
        	                         to_date('01-01-0001','DD-MM-YYYY'),
                	              p_effective_end_date   =>
                        	        to_date('31-12-4712','DD-MM-YYYY'));
				l_seq_number := l_seq_number + 1;

  	                      hr_input_values.create_link_input_value(
        	                      p_insert_type           => 'INSERT_INPUT_VALUE',
                	              p_element_link_id       => l_elem_link_id,
                        	      p_input_value_id        => l_input_val_id,
	                              p_input_value_name      => l_source_text2_iv_val,
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

			end if; -- l_source_text2_iv = 1

				j := l_seq_number;

                     end if;
                     /*
                        create an input value for each balance_name selected and
                        name it after the balance it is created for.
                     */

                     l_input_val_id := pay_db_pay_setup.create_input_value (
                           p_element_name         => l_element_name,
                           p_name                 =>
                                                 substr(l_bal_name, 1, 28)||j,
                           p_uom_code             =>
                                                 g_baltyp_tbl_uom(l_bal_count),
                           p_business_group_name  => l_bg_name,
	                   p_effective_start_date =>
	                      to_date('01-01-0001','DD-MM-YYYY'),
                           p_effective_end_date   =>
                             to_date('31-12-4712','DD-MM-YYYY'),
                           p_display_sequence     => j);
                     /*
                        create a balance feed for each input value created.
                        point each to its corresponding input value.
                     */
                     hr_balances.ins_balance_feed(
                           p_option                      => 'INS_MANUAL_FEED',
                           p_input_value_id              => l_input_val_id,
                           p_element_type_id             => l_element_type_id,
                           p_primary_classification_id   => NULL,
                           p_sub_classification_id       => NULL,
                           p_sub_classification_rule_id  => NULL,
                           p_balance_type_id             =>
                                                  g_baltyp_tbl_id(l_bal_count),
                           p_scale                       => '1',
                           p_session_date                =>
                              to_date('01-01-0001','DD-MM-YYYY'),
                           p_business_group              => l_bg_id,
                           p_legislation_code            => NULL,
                           p_mode                        => 'USER');
                     /*
                        create a link input value for each input value created.
                     */
                     hr_input_values.create_link_input_value(
                           p_insert_type           => 'INSERT_INPUT_VALUE',
                           p_element_link_id       => l_elem_link_id,
                           p_input_value_id        => l_input_val_id,
                           p_input_value_name      =>
                                             substr(l_bal_name, 1 , 28)||j,
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

                     j := j + 1;
                  end if;
                  close csr_is_balance_fed;
               end if;
               l_bal_count := l_bal_count + 1;
            end loop;

         end loop;
         l_jur_count := l_jur_count + 1;
      end loop;

      commit;
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);
EXCEPTION
    WHEN OTHERS THEN
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,60);
        IF csr_bg%ISOPEN THEN
            CLOSE csr_bg;
        END IF;
        IF csr_rule1%ISOPEN THEN
            CLOSE csr_rule1;
        END IF;
        IF csr_rule2%ISOPEN THEN
            CLOSE csr_rule2;
        END IF;
        IF csr_rule3%ISOPEN THEN
            CLOSE csr_rule3;
        END IF;
        IF csr_rule4%ISOPEN THEN
            CLOSE csr_rule4;
        END IF;
        IF csr_is_balance_fed%ISOPEN THEN
            CLOSE csr_is_balance_fed;
        END IF;
        errbuf :=SQLERRM;
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.trace(l_message,l_procedure);
        local_error(retcode,'create_bal_upl_struct',1);

   END create_bal_upl_struct;

BEGIN
   g_nxt_free_baltyp := 1;
   g_nxt_free_baldim := 1;
   g_nxt_free_jl     := 1;
END pay_in_bal_upl_struct;


/
