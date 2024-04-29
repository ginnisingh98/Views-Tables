--------------------------------------------------------
--  DDL for Package Body GROSSUP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GROSSUP_UPD" as
/* $Header: pyusntgu.pkb 115.1 2001/01/24 18:34:36 pkm ship    $ */

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

 CURSOR get_latest_bal IS
   SELECT latest_balance_id
     FROM pay_assignment_latest_balances alb,
          pay_defined_balances pdb
    WHERE alb.latest_balance_id BETWEEN p_start_latest_bal_id
                                    AND p_end_latest_bal_id
      AND alb.defined_balance_id = pdb.defined_balance_id
      AND pdb.balance_dimension_id = p_dim_id;

 l_count NUMBER := 0;

BEGIN

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

END delete_late_bal;

END grossup_upd;

/
