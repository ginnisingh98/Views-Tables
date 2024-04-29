--------------------------------------------------------
--  DDL for Package Body PYSGBUPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYSGBUPL" AS
-- /* $Header: pysgbupl.pkb 115.7 2004/01/22 02:40:28 abhargav ship $ */
--
-- +======================================================================+
-- |              Copyright (c) 1997 Oracle Corporation UK Ltd            |
-- |                        Reading, Berkshire, England                   |
-- |                           All rights reserved.                       |
-- +======================================================================+
-- SQL Script File Name : pysgbupl.pkb
-- Description          : This script delivers Initial Balance Structure Creation
--                        package for the Singapore localization (SG).
--                        This package can be activated from the SG Initial Balance
--                        Structure Creation SRS available through Forms.  The user
--                        needs to supply the batch name to run this process.
--
--                        Given the limit of the input values per element type and the
--                        batch id in that order, create_bal_upl_struct will first call
--                        validate_batch_data to validate the batch data, then it will
--                        create the element types, element links, input values, balance
--                        feeds and link input values.
--
--                        The SQL script PYDELSTR.sql when submitted by SRS
--                        will delete the structure created by this package.
--
--
-- Change List:
-- ------------
--
-- ======================================================================
-- Version  Date         Author    Bug No.  Description of Change
-- -------  -----------  --------  -------  -----------------------------
-- 115.0    06-JUN-2000  JBailie            Initial Version
-- 115.1    21-JUL-2000  JBailie            Set ship state
-- 115.2    27-JUL-2000  JBailie            Removed hr_utility.trace_on
-- 115.3    29-NOV-2001  Ragovind 2129823   GSCC Compliance Check
-- 115.4    10-DEC-2001  Rsirigir 2107303   added this line
--                                          REM checkfile:~PROD:~PATH:~FILE
--                                          after
--                                          REM dbdrv: sql ~PROD ~PATH ~FILE
--                                          none none none package &phase=plb
--                                          as part of  GSCC Compliance Check
-- 115.5    10-DEC-2002 Apunekar  2689242   Added nocopy to out and in out parameters
-- 115.6    12-JAN-2004 abhargav  3371693   Modified the cursor 'csr_is_balance_fed'
--                                          for the performance reason.
-- ======================================================================
--
--
--
-- Global declarations
type char_array is table of varchar2(80) index by binary_integer;
type num_array  is table of number(16) index by binary_integer;
--
-- Balance Type Cache
g_baltyp_tbl_id 	num_array;
g_baltyp_tbl_name char_array;
g_baltyp_tbl_uom 	char_array;
g_nxt_free_baltyp number;
--
-- Balance Dimension Cache
g_baldim_tbl_id 	num_array;
g_baldim_tbl_name char_array;
g_nxt_free_baldim number;
--
--
   PROCEDURE local_error(retcode OUT NOCOPY number,
                         p_procedure    IN  varchar2,
                         p_step         IN  number) IS
--
/* This procedure is called whenever an error needs to be raised and
   the retcode is set to 2 to indicate an error has occurred.
*/
--
   BEGIN
--
      retcode := 2;
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'pysgbupl.'||p_procedure);
      hr_utility.set_message_token('STEP', p_step);
      hr_utility.raise_error;
--
   END local_error;
--
--
procedure check_balance_type(p_baltype_id   out nocopy number,
                             p_baltype_name varchar2,
                             p_busgrp_id    number,
                             p_leg_code     varchar2,
                             retcode        out nocopy number)
is
l_balance_type_id     number;
l_baltyp_name         varchar2(80);
l_bal_uom             varchar2(80);
l_count               number;
l_found               boolean;
begin
 --
 -- Search for the defined balance in the Cache.
 --
 hr_utility.set_location('pysgbupl.check_balance_type', 10);
 l_balance_type_id := null;
 l_baltyp_name := upper(p_baltype_name);
 l_count := 1;
 l_found := FALSE;
 while (l_count < g_nxt_free_baltyp and l_found = FALSE) loop
    if (l_baltyp_name = g_baltyp_tbl_name(l_count)) then
       hr_utility.set_location('pysgbupl.check_balance_type', 20);
       l_balance_type_id := g_baltyp_tbl_id(l_count);
       l_found := TRUE;
    end if;
    l_count := l_count + 1;
 end loop;
 --
 -- If the balance is not in the Cache get it from the database.
 --
 hr_utility.set_location('pysgbupl.check_balance_type', 30);
 if (l_found = FALSE) then
    BEGIN
--
       select balance_type_id,
              balance_uom
       into   l_balance_type_id, l_bal_uom
       from   pay_balance_types
       where  upper(balance_name) = l_baltyp_name
       and    ((business_group_id = p_busgrp_id)
             or(   business_group_id is null
                   and legislation_code = p_leg_code)
             or(   business_group_id is null
                   and legislation_code is null)
              )
       for update of balance_type_id;
--
       --
       -- Place the defined balance in cache.
       --
       hr_utility.set_location('pysgbupl.check_balance_type', 40);
       g_baltyp_tbl_name(g_nxt_free_baltyp) := l_baltyp_name;
       g_baltyp_tbl_uom(g_nxt_free_baltyp) := l_bal_uom;
       g_baltyp_tbl_id(g_nxt_free_baltyp) := l_balance_type_id;
       g_nxt_free_baltyp := g_nxt_free_baltyp + 1;
--
    EXCEPTION WHEN no_data_found THEN
       hr_utility.trace('Error:  Failure to find balance type');
       local_error(retcode, 'check_balance_type',1);
--
    END;
--
  end if;
--
  p_baltype_id := l_balance_type_id;
--
end check_balance_type;
--
--
procedure check_balance_dim(p_baldim_id  out nocopy number,
                            p_baldim_name    varchar2,
                            p_busgrp_id      number,
                            p_leg_code       varchar2,
                            retcode      out nocopy number)
is
l_baldim_name         varchar2(80);
l_count               number;
l_found               boolean;
l_balance_dim_id      number;
begin
 --
 -- Search for the defined balance in the Cache.
 --
 hr_utility.set_location('pysgbupl.check_balance_dim', 10);
 l_balance_dim_id := null;
 l_baldim_name := upper(p_baldim_name);
 l_count := 1;
 l_found := FALSE;
 while (l_count < g_nxt_free_baldim and l_found = FALSE) loop
    if (l_baldim_name = g_baldim_tbl_name(l_count)) then
       hr_utility.set_location('pysgbupl.check_balance_dim', 20);
       l_balance_dim_id := g_baldim_tbl_id(l_count);
       l_found := TRUE;
    end if;
    l_count := l_count + 1;
 end loop;
 --
 -- If the balance is not in the Cache get it from the database.
 --
 hr_utility.set_location('pysgbupl.check_balance_dim', 30);
 if (l_found = FALSE) then
    BEGIN
--
       select balance_dimension_id
       into   l_balance_dim_id
       from   pay_balance_dimensions
       where  upper(dimension_name) = l_baldim_name
       and    ((business_group_id = p_busgrp_id)
             or(   business_group_id is null
               and legislation_code = p_leg_code)
             or(   business_group_id is null
               and legislation_code is null)
              );
--
       --
       -- Place the defined balance in cache.
       --
       hr_utility.set_location('pysgbupl.check_balance_dim', 40);
       g_baldim_tbl_name(g_nxt_free_baldim) := l_baldim_name;
       g_baldim_tbl_id(g_nxt_free_baldim) := l_balance_dim_id;
       g_nxt_free_baldim := g_nxt_free_baldim + 1;
--
    EXCEPTION WHEN no_data_found THEN
       hr_utility.trace('Error:  Failure to find balance dimension');
       local_error(retcode,'check_balance_dim',2);
--
    END;
--
  end if;
--
  p_baldim_id := l_balance_dim_id;
--
end check_balance_dim;
--
   FUNCTION validate_batch_data (p_batch_id number) RETURN number IS
--
/* This function verifies that the business group, balance types, and
   balance dimensions actually exist.  If not, it would return a retcode
   of 2 and raise an exception.
*/
--
      retcode		number := 0;
      i			number := 0;
      l_bg_id           per_business_groups.business_group_id%TYPE;
      l_leg_code        per_business_groups.legislation_code%TYPE;
      l_bt_id		pay_balance_types.balance_type_id%TYPE;
      l_bal_dim_id	pay_balance_dimensions.balance_dimension_id%TYPE;
--
      cursor c_each_batch (c_batch_id	number) is
         select balance_name,
                dimension_name
         from   pay_balance_batch_lines
         where  batch_id = c_batch_id;
--
   BEGIN
      hr_utility.set_location('pysgbupl.validate_batch_data', 10);
      BEGIN  /* check business group exists */
         select hou.business_group_id,
                hou.legislation_code
           into l_bg_id,
                l_leg_code
         from   per_business_groups       hou,
                pay_balance_batch_headers bbh
         where  bbh.batch_id = p_batch_id
         and    upper(hou.name) = upper(bbh.business_group_name);
      EXCEPTION WHEN no_data_found THEN
         local_error(retcode, 'validate_batch_data', 3);
      END;
--
      hr_utility.set_location('pysgbupl.validate_batch_data', 20);
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
--
      return retcode;
   END validate_batch_data;
--
--
   PROCEDURE create_bal_upl_struct (errbuf		 OUT NOCOPY varchar2,
				    retcode		 OUT NOCOPY number,
				    p_input_value_limit		IN  number,
				    p_batch_id			IN  number) IS
--
-- errbuf and retcode are special parameters needed for the SRS.
-- retcode = 0 means no error and retcode = 2 means an error occurred.
--
--
      l_n_elems			  number := 0;
      j				  number;
      l_bal_uom			  pay_balance_types.balance_uom%TYPE;
      l_element_name		  pay_element_types.element_name%TYPE;
      l_element_type_id		  pay_element_types.element_type_id%TYPE;
      l_elem_link_id		  pay_element_links.element_link_id%TYPE;
      l_input_val_id		  pay_input_values.input_value_id%TYPE;
      l_bal_name			  pay_balance_types.balance_name%TYPE;
      l_bal_type_id		  pay_balance_types.balance_type_id%TYPE;
      l_bal_feed_id		  pay_balance_feeds.balance_feed_id%TYPE;
      l_bg_name	              hr_organization_units.name%TYPE;
      l_bg_id                   hr_organization_units.organization_id%TYPE;
      l_bal_count               number;
      l_dummy_id                number;
      l_bg_currency_code        pay_element_types.output_currency_code%TYPE;
--
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
         and    BF.balance_type_id     = p_balance_type_id
         and    nvl(BF.business_group_id, p_business_group) = p_business_group;
--
--
   BEGIN
--
      hr_utility.set_location('pysgbupl.create_bal_upl_struct', 10);
--
      hr_utility.trace('Started Processing');
--
      select pbg.business_group_id, bbh.business_group_name, pbg.currency_code
      into   l_bg_id, l_bg_name, l_bg_currency_code
      from   pay_balance_batch_headers bbh,
             per_business_groups       pbg
      where  batch_id = p_batch_id
      and    upper(pbg.name) = upper(bbh.business_group_name);
--
      retcode := validate_batch_data (p_batch_id);
--
      hr_utility.set_location('pysgbupl.create_bal_upl_struct', 20);
--
      /* calculate no of elements needed based on 15 input values per element*/
      l_n_elems := ceil ((g_nxt_free_baltyp - 1) / p_input_value_limit);

      l_bal_count := 1;
      for i in 1 .. l_n_elems loop
--
      hr_utility.trace('i='||to_char(i));
--
          hr_utility.set_location('pysgbupl.create_bal_upl_struct', 30);
	  j := 1;
          while (l_bal_count< g_nxt_free_baltyp and j <= p_input_value_limit) loop

               hr_utility.trace('j='||to_char(j));

               hr_utility.set_location('pysgbupl.create_bal_upl_struct', 40);
--
--             Does this balance already have an initial balance feed.
--
               open csr_is_balance_fed(g_baltyp_tbl_id(l_bal_count),l_bg_id);
               fetch csr_is_balance_fed into l_dummy_id;

               if (csr_is_balance_fed%notfound) then
                     /*
                       If this is the first balance found for this element
                       create the element.
                     */
                     hr_utility.trace('Processing: '||g_baltyp_tbl_name(l_bal_count));

                     if j = 1 then
                        /*
                           create an element type and name it as follows:
                           initial_value_element concatenated with the
                           batch id, and a number identifying which element
                           type it is that's being created.
                        */
                        l_element_name := 'Initial_Value_Element_' || -- keep this name
                                          p_batch_id ||               -- as means to identify
                                          '_' ||                      -- elements to delete
                                          to_char(i);                 -- by the Undo
--
                        hr_utility.trace ('Element Name is:' || l_element_name);
--
                        l_element_type_id := pay_db_pay_setup.create_element (
                            p_element_name           => l_element_name,
                            p_effective_start_date   => to_date('01/01/0001','DD/MM/YYYY'),
                            p_effective_end_date     => to_date('31/12/4712','DD/MM/YYYY'),
                            p_classification_name    => 'Balance Initialization',
                            p_input_currency_code    => l_bg_currency_code,
                            p_output_currency_code   => l_bg_currency_code,
                            p_processing_type        => 'N',
                            p_adjustment_only_flag   => 'Y',
                            p_process_in_run_flag    => 'Y',
                            p_legislation_code       => NULL,
                            p_business_group_name    => l_bg_name,
                            p_processing_priority    => 0,
                            p_post_termination_rule  => 'Final Close');
--
                        update pay_element_types_f ELEM
                        set ELEM.element_information1 = 'B'
                        where element_type_id = l_element_type_id;
                        /*
                           create an element link for each element type created.
                           point it to each of the element type created.
                        */
                        l_elem_link_id := pay_db_pay_setup.create_element_link (
                              p_element_name          => l_element_name,
                              p_link_to_all_pyrlls_fl => 'Y',
                              p_standard_link_flag    => 'N',
                              p_effective_start_date  => to_date('01-01-0001','DD-MM-YYYY'),
                              p_effective_end_date    => to_date('31-12-4712','DD-MM-YYYY'),
                              p_business_group_name   => l_bg_name);
--
                     end if;
                     /*
                        create an input value for each balance_name selected and
                        name it after the balance it is created for.
                     */
--
                     l_input_val_id := pay_db_pay_setup.create_input_value (
                           p_element_name         => l_element_name,
                           p_name                 => substr(l_bal_name, 1, 28)||j,
                           p_uom_code             => g_baltyp_tbl_uom(l_bal_count),
                           p_business_group_name  => l_bg_name,
	                     p_effective_start_date => to_date('01-01-0001','DD-MM-YYYY'),
                           p_effective_end_date   => to_date('31-12-4712','DD-MM-YYYY'),
                           p_display_sequence     => j+1);
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
                           p_balance_type_id             => g_baltyp_tbl_id(l_bal_count),
                           p_scale                       => '1',
                           p_session_date                => to_date('01-01-0001','DD-MM-YYYY'),
                           p_business_group              => l_bg_name,
                           p_legislation_code            => NULL,
                           p_mode                        => 'USER');
                     /*
                        create a link input value for each input value created.
                     */
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
--
                     j := j + 1;
               end if;
               close csr_is_balance_fed;
               l_bal_count := l_bal_count + 1;
          end loop;
--
      end loop;
--
      hr_utility.trace('Finished Processing');
commit;
--
   END create_bal_upl_struct;
--
BEGIN
   g_nxt_free_baltyp := 1;
   g_nxt_free_baldim := 1;
END pysgbupl;

/
