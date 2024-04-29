--------------------------------------------------------
--  DDL for Package HR_AUBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUBAL" AUTHID CURRENT_USER as
--  $Header: pyaubal.pkh 120.0.12000000.1 2007/01/17 15:44:32 appldev noship $

--  Copyright (c) 1999 Oracle Corporation
--  All rights reserved

--  Package used to contain balance functions for Australia.

--  Date        Author   Bug/CR Num Notes
--  -----------+--------+----------+-----------------------------------------
--  28-Aug-2003 Puchil    3010965   Removed functions balance and calc_balance
--  18 Dec 2002 Apunekar            Added DBDRV
--  22 Feb 2000 JTurner             Fixed up incorrect function specs
--  24-Nov-1999 sgoggin             AU Created
--  13-Aug-1999 sclarke             Created

  ------------------------calc_all_balances----------------------------------
  function calc_all_balances
  (p_assignment_action_id in number
  ,p_defined_balance_id   in number
  ) return number;

  ------------------------calc_all_balances----------------------------------
  function calc_all_balances
  (p_effective_date       in date
  ,p_assignment_id        in number
  ,p_defined_balance_id   in number
  ) return number;

  -------------------------calc_asg_mtd--------------------------------------
  function calc_asg_mtd
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  -------------------------calc_asg_mtd_action-------------------------------
  function calc_asg_mtd_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  )return number;

  -------------------------calc_asg_mtd_date---------------------------------
  function calc_asg_mtd_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  )return number;

  -------------------------calc_asg_qtd--------------------------------------
  function calc_asg_qtd
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  -------------------------calc_asg_qtd_action-------------------------------
  function calc_asg_qtd_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  )return number;

  -------------------------calc_asg_qtd_date---------------------------------
  function calc_asg_qtd_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  )return number;

  -------------------------calc_asg_ytd--------------------------------------
  function calc_asg_ytd
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  ----------------------calc_asg_ytd_action---------------------------------
  function calc_asg_ytd_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ) return number;

  -------------------------calc_asg_ytd_date-----------------------------------
  function calc_asg_ytd_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  ) return number;

  -------------------------calc_asg_FBT_ytd--------------------------------------
  function calc_asg_fbt_ytd
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  -------------------------calc_asg_fbt_ytd_action---------------------------------
  function calc_asg_fbt_ytd_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ) return number;

  -------------------------calc_asg_fbt_ytd_date-----------------------------------
  function calc_asg_fbt_ytd_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  ) return number;

  -------------------------calc_asg_fy_ytd--------------------------------------
  function calc_asg_fy_ytd
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  -------------------------calc_asg_fy_ytd_action-------------------------------
  function calc_asg_fy_ytd_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  )return number;

  -------------------------calc_asg_fy_ytd_date---------------------------------
  function calc_asg_fy_ytd_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  )return number;

  -------------------------calc_asg_cal_ytd--------------------------------------
  function calc_asg_cal_ytd
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  -------------------------calc_asg_cal_ytd_action-------------------------------
  function calc_asg_cal_ytd_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  )return number;

  -------------------------calc_asg_cal_ytd_date---------------------------------
  function calc_asg_cal_ytd_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  )return number;

  -------------------------calc_asg_fy_qtd---------------------------------------
  function calc_asg_fy_qtd
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  )return number;

  -------------------------calc_asg_fy_qtd_action--------------------------------
  function calc_asg_fy_qtd_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  )return number;

  -------------------------calc_asg_fy_qtd_date----------------------------------
  function calc_asg_fy_qtd_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  ) return number;

  -------------------------calc_asg_ptd_action----------------------------------
  function calc_asg_ptd_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  )return number;

  -------------------------calc_asg_ptd------------------------------------------
  function calc_asg_ptd
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  -------------------------calc_asg_ptd_date-------------------------------------
  function calc_asg_ptd_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  ) return number;

  -------------------------calc_asg_td_action-----------------------------
  function calc_asg_td_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ) return number;

  -------------------------calc_asg_td------------------------------------
  function calc_asg_td
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  -------------------------calc_asg_td_date-------------------------------
  function calc_asg_td_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  ) return number;

  -------------------------calc_asg_run_action----------------------------
  function calc_asg_run_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ) return number;

  -------------------------calc_asg_run-----------------------------------
  function calc_asg_run
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  -------------------------calc_asg_run_date------------------------------
  function calc_asg_run_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  ) return number;

  -------------------------calc_payment_action----------------------------
  function calc_payment_action
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ) return number;

  -------------------------calc_payment-----------------------------------
  function calc_payment
  (p_assignment_action_id  in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date default null
  ,p_assignment_id         in number
  ) return number;

  -------------------------calc_payment_date------------------------------
  function calc_payment_date
  (p_assignment_id         in number
  ,p_balance_type_id       in number
  ,p_effective_date        in date
  ) return number;
--
end hr_aubal;

 

/
