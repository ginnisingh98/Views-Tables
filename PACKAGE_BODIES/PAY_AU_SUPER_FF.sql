--------------------------------------------------------
--  DDL for Package Body PAY_AU_SUPER_FF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_SUPER_FF" AS
/* $Header: pyaufmsp.pkb 120.1 2005/07/27 21:22:53 hnainani noship $ */

/*
 +==========================================================================================
 |              Copyright (c) 1999 Oracle Corporation Ltd
 |                           All rights reserved.
 +==========================================================================================
 Change List
 ----------
 DATE        Name            Vers     Bug No    Description
 -----------+---------------+--------+--------+-----------------------+
 01-Dec-1999 makelly         115.0             Created for AU
 05-Dec-2000 rbsinha         115.1             Added a cursor to fetch
                                               balance name for the
                                               balance id . This has
                                               been done to raise a
                                               context sensitive message.
 04-Dec-2002 Ragovind        115.2             Added NOCOPY for function get_bals.
 09-Aug-2004 abhkumar        115.4    2610141  Added tax_unit_id parameter in function get_bals for LE changes.
 12-Aug-2004 abhkumar        115.5    2610141  Modfied code to set the appropriate token for the message
 08-SEP-2004 abhkumar        115.6    2610141  Added a new parameter to function get_bals
 28-JUL-2005 hnainani        115.7    4519080  Changed Get_Value function to add parameter get_rb_routes
 -----------+---------------+--------+--------+-----------------------+
*/


/*
**------------------------------ Formula Fuctions ---------------------------------
**  Package containing addition processing required by superannuation
**  formula in AU localisaton
*/


/*
**  get_bals - get the balances for a user specified balance
*/


function  get_bals
  (
      p_ass_act_id  in     number     /* context - assignment_action_id */
     ,p_tax_unit_id in     number     /* context - tax_unit_id */ --2610141
     ,p_bal_id      in     number     /* Balance id of user Balance     */
     ,p_use_tax_flag IN    VARCHAR2 --2610141
     ,p_bal_run     in out NOCOPY number     /* Run balance                    */
     ,p_bal_mtd     in out NOCOPY number     /* Month to date balance          */
     ,p_bal_qtd     in out NOCOPY number     /* Quarter to date balance        */
  )
  return number is

l_bal_dim_id           number;
l_bal_name             VARCHAR2(80);
l_run_dim_name         VARCHAR2(20);
l_qtd_dim_name         VARCHAR2(20);
l_mtd_dim_name         VARCHAR2(20);

cursor c_get_def_bal_id (v_bal_dim   varchar2) is
select pdb.defined_balance_id
  from pay_balance_dimensions pbd,
       pay_defined_balances   pdb
 where pbd.dimension_name = v_bal_dim
   and pdb.balance_type_id   = p_bal_id
   and pdb.balance_dimension_id = pbd.balance_dimension_id;

cursor c_get_balance_name is
select pbt.balance_name
from   pay_balance_types pbt
where  pbt.balance_type_id = p_bal_id;


begin

  IF p_use_tax_flag = 'N' THEN
	l_run_dim_name := '_ASG_RUN';
	l_qtd_dim_name := '_ASG_QTD';
	l_mtd_dim_name := '_ASG_MTD';
  ELSE
	l_run_dim_name := '_ASG_LE_RUN';
	l_qtd_dim_name := '_ASG_LE_QTD';
	l_mtd_dim_name := '_ASG_LE_MTD';
  END IF ;


  open c_get_def_bal_id (l_run_dim_name); --2610141
  fetch c_get_def_bal_id into l_bal_dim_id;
  if c_get_def_bal_id%notfound then
    open c_get_balance_name;
    fetch c_get_balance_name into l_bal_name;
    close c_get_balance_name;
    hr_utility.set_message(801,'HR_AU_BAL_DIM_NOT_DEFINED');
    hr_utility.set_message_token('DIMENSION',l_run_dim_name); --2610141
    hr_utility.set_message_token('BALANCE_NAME',l_bal_name);
    return(-1);
  end if;
  close c_get_def_bal_id;

/* 4519080 - IF changing the parameters for the get_value function ,please make sure to retain the parameter
       p_get_rb_route. Since this function is called from a formula function , latest balances do not always
       work as expected */


  IF p_use_tax_flag = 'Y' THEN
  p_bal_run:=  pay_balance_pkg.get_value(p_defined_balance_id   => l_bal_dim_id
                         ,p_assignment_action_id => p_ass_act_id
                         ,p_tax_unit_id          => p_tax_unit_id
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                        ,p_source_number        => null
                         );

ELSE
  p_bal_run:=  pay_balance_pkg.get_value(p_defined_balance_id   => l_bal_dim_id
                         ,p_assignment_action_id => p_ass_act_id
                         ,p_tax_unit_id          => null
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                        ,p_source_number        => null
                         );



  END IF;

  open c_get_def_bal_id (l_mtd_dim_name); --2610141
  fetch c_get_def_bal_id into l_bal_dim_id;
  if c_get_def_bal_id%notfound then
    open c_get_balance_name;
    fetch c_get_balance_name into l_bal_name;
    close c_get_balance_name;
    hr_utility.set_message(801,'HR_AU_BAL_DIM_NOT_DEFINED');
    hr_utility.set_message_token('DIMENSION',l_mtd_dim_name); --2610141
    hr_utility.set_message_token('BALANCE_NAME',l_bal_name);
    return(-2);
  end if;
  close c_get_def_bal_id;

  IF p_use_tax_flag = 'Y' THEN
       p_bal_mtd :=  pay_balance_pkg.get_value(p_defined_balance_id   => l_bal_dim_id
                         ,p_assignment_action_id => p_ass_act_id
                         ,p_tax_unit_id          => p_tax_unit_id
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );

  ELSE
      p_bal_mtd :=    pay_balance_pkg.get_value(p_defined_balance_id   => l_bal_dim_id
                         ,p_assignment_action_id => p_ass_act_id
                         ,p_tax_unit_id          => null
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );

  END IF ;

  open c_get_def_bal_id (l_qtd_dim_name); --2610141
  fetch c_get_def_bal_id into l_bal_dim_id;
  if c_get_def_bal_id%notfound then
    open c_get_balance_name;
    fetch c_get_balance_name into l_bal_name;
    close c_get_balance_name;
    hr_utility.set_message(801,'HR_AU_BAL_DIM_NOT_DEFINED');
    hr_utility.set_message_token('DIMENSION',l_qtd_dim_name); --2610141
    hr_utility.set_message_token('BALANCE_NAME',l_bal_name);
    return(-3);
  end if;
  close c_get_def_bal_id;

  IF p_use_tax_flag = 'Y' THEN
    p_bal_qtd :=     pay_balance_pkg.get_value(p_defined_balance_id   => l_bal_dim_id
                         ,p_assignment_action_id => p_ass_act_id
                         ,p_tax_unit_id          => p_tax_unit_id
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );

  ELSE
        p_bal_qtd := pay_balance_pkg.get_value(p_defined_balance_id   => l_bal_dim_id
                         ,p_assignment_action_id => p_ass_act_id
                         ,p_tax_unit_id          => null
                         ,p_jurisdiction_code    => null
                         ,p_source_id            => null
                         ,p_source_text          => null
                         ,p_tax_group            => null
                         ,p_date_earned          => null
                         ,p_get_rr_route         => null
                         ,p_get_rb_route         => 'TRUE'
                         ,p_source_text2         => null
                         ,p_source_number        => null
                         );

  END IF ;

   hr_utility.trace('p_bal_run '||p_bal_run);
   hr_utility.trace('p_bal_mtd '||p_bal_mtd);
   hr_utility.trace('p_bal_qtd '||p_bal_qtd);

  return(0);

exception
  when others then
    return(-99);

end get_bals;


end pay_au_super_ff;

/
