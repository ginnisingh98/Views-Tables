--------------------------------------------------------
--  DDL for Package Body PAY_US_GROSSUP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_GROSSUP_UPD" as
/* $Header: pyusntgu.pkb 115.4 2004/01/22 23:17:15 ardsouza noship $ */

PROCEDURE setup_grossup_bal(p_baltype_id number, p_baldim_id number)
IS

   l_defbal_id number;

BEGIN
--
   BEGIN
      select defined_balance_id
        into l_defbal_id
        from pay_defined_balances
       where balance_type_id = p_baltype_id
         and balance_dimension_id = p_baldim_id
         and legislation_code = 'US';
--
      update pay_defined_balances
         set grossup_allowed_flag = 'Y'
       where defined_balance_id = l_defbal_id;

      hr_utility.trace('Updated defined balance id : '||l_defbal_id);
--
   EXCEPTION
      when no_data_found then
--
         insert into pay_defined_balances
                       (defined_balance_id,
                        balance_type_id,
                        balance_dimension_id,
                        legislation_code,
                        force_latest_balance_flag,
                        grossup_allowed_flag
                       )
          values (pay_defined_balances_s.nextval,
                  p_baltype_id,
                  p_baldim_id,
                  'US',
                  'N',
                  'Y');
     hr_utility.trace('Inserted balance_type_id : '||p_baltype_id);
     hr_utility.trace('Inserted balance_dim_id : '||p_baldim_id);

   END;
--
END setup_grossup_bal;


PROCEDURE delete_late_bal(p_start_latest_bal_id number,
                          p_end_latest_bal_id number,
                          p_dim_id number)
IS

 l_defined_bal_id NUMBER;
--
-- Bug 3349650 - Forced index to avoid FTS.
--
 CURSOR get_def_bal IS
  SELECT /*+ INDEX(pay_defined_balances PAY_DEFINED_BALANCES_FK2) */
         defined_balance_id
    FROM pay_defined_balances
   WHERE balance_dimension_id = p_dim_id;

 CURSOR get_latest_bal IS
   SELECT latest_balance_id
     FROM pay_assignment_latest_balances
    WHERE latest_balance_id BETWEEN p_start_latest_bal_id
                                AND p_end_latest_bal_id
      AND defined_balance_id = l_defined_bal_id;

 l_count NUMBER := 0;

BEGIN

 FOR def_bal_rec in get_def_bal LOOP
   l_defined_bal_id := def_bal_rec.defined_balance_id;

   FOR latebal_rec in get_latest_bal LOOP

    l_count := l_count + 1;

   delete from pay_balance_context_values
    where latest_balance_id = latebal_rec.latest_balance_id;

   --hr_utility.trace('Deleted context value '||latebal_rec.latest_balance_id);

--
   delete from pay_assignment_latest_balances
    where latest_balance_id = latebal_rec.latest_balance_id;

   --hr_utility.trace('Deleted asg late bal '||latebal_rec.latest_balance_id);

   if l_count = 100 then
     l_count := 0;
     commit;
   end if;

   END LOOP;
 END LOOP;

END delete_late_bal;

END pay_us_grossup_upd;

/
