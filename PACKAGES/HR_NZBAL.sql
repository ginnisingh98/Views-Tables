--------------------------------------------------------
--  DDL for Package HR_NZBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NZBAL" AUTHID CURRENT_USER as
/* $Header: pynzbal.pkh 120.0 2005/05/29 02:11:12 appldev noship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+--------------------+
-- 18-Aug-2004 sshankar        115.6    3181581  Added function balance as
--                                               it is being used by view
--                                               pay_nz_balances_v
-- 13 Aug 2004 sshankar        115.5    3181581  Removed functions:
--                                               balance and calc_balance
-- 13 Feb 2002 vgsriniv        115.4    2203667  Added checkfile in dbdrv
-- 12 Nov 2001 vgsriniv        115.1    2097319  dbdrv command added
-- 11 Jan 2000 J Turner                          Commented out pragmas
-- 13-Aug-1999 sclarke         1.0                 Created
-- -----------+---------------+--------+--------+--------------------+
--
------------------------calc_all_balances----------------------------------
--
function calc_all_balances  (   p_assignment_action_id in number
                            ,   p_defined_balance_id   in number
                            )
return number;
-- pragma restrict_references (calc_all_balances, wnds, wnps);
--
------------------------calc_all_balances----------------------------------
--
function calc_all_balances  (   p_effective_date       in date
                            ,   p_assignment_id        in number
                            ,   p_defined_balance_id   in number
                            )
return number;
-- pragma restrict_references (calc_all_balances, wnds, wnps);
--
-------------------------calc_asg_ytd--------------------------------------
--
function calc_asg_ytd   (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
return number;
-- pragma restrict_references (calc_asg_ytd, wnds, wnps);
--
-------------------------calc_asg_ytd_action---------------------------------
--
function calc_asg_ytd_action(   p_assignment_action_id  in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date default null
                            )
return number;
-- pragma restrict_references (calc_asg_ytd_action, wnds, wnps);
--
-------------------------calc_asg_ytd_date-----------------------------------
--
-- date mode function
--
function calc_asg_ytd_date  (   p_assignment_id         in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date
                            )
return number;
-- pragma restrict_references (calc_asg_ytd_date, wnds, wnps);
--
-------------------------calc_asg_hol_ytd--------------------------------------
--
function calc_asg_hol_ytd   (   p_assignment_action_id  in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date default null
                            ,   p_assignment_id     in number
                            )
return number;
-- pragma restrict_references (calc_asg_hol_ytd, wnds, wnps);
--
-------------------------calc_asg_hol_ytd_action---------------------------------
--
function calc_asg_hol_ytd_action(   p_assignment_action_id  in number
                                ,   p_balance_type_id       in number
                                ,   p_effective_date        in date default null
                                )
return number;
-- pragma restrict_references (calc_asg_hol_ytd_action, wnds, wnps);
--
-------------------------calc_asg_hol_ytd_date-----------------------------------
--
-- date mode function
--
function calc_asg_hol_ytd_date  (   p_assignment_id         in number
                                ,   p_balance_type_id       in number
                                ,   p_effective_date        in date
                                )
return number;
-- pragma restrict_references (calc_asg_hol_ytd_date, wnds, wnps);
--
-------------------------calc_asg_fy_ytd--------------------------------------
--
function calc_asg_fy_ytd(   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
return number;
-- pragma restrict_references (calc_asg_fy_ytd, wnds, wnps);
--
-------------------------calc_asg_fy_ytd_action-------------------------------
--
function calc_asg_fy_ytd_action (   p_assignment_action_id  in number
                                ,   p_balance_type_id       in number
                                ,   p_effective_date        in date default null
                                )
return number;
-- pragma restrict_references (calc_asg_fy_ytd_action, wnds, wnps);
--
-------------------------calc_asg_fy_ytd_date---------------------------------
--
-- date mode function
--
function calc_asg_fy_ytd_date   (   p_assignment_id         in number
                                ,   p_balance_type_id       in number
                                ,   p_effective_date        in date
                                )
return number;
-- pragma restrict_references (calc_asg_fy_ytd_date, wnds, wnps);
--
-------------------------calc_asg_fy_qtd---------------------------------------
--
function calc_asg_fy_qtd(   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
return number;
-- pragma restrict_references (calc_asg_fy_qtd, wnds, wnps);
--
-------------------------calc_asg_fy_qtd_action--------------------------------
--
function calc_asg_fy_qtd_action (   p_assignment_action_id  in number
                                ,   p_balance_type_id       in number
                                ,   p_effective_date        in date default null
                                )
return number;
-- pragma restrict_references (calc_asg_fy_qtd_action, wnds, wnps);
--
-------------------------calc_asg_fy_qtd_date----------------------------------
--
-- date mode function
--
function calc_asg_fy_qtd_date   (   p_assignment_id         in number
                                ,   p_balance_type_id       in number
                                ,   p_effective_date        in date
                                )
return number;
-- pragma restrict_references (calc_asg_fy_qtd_date, wnds, wnps);
--
-------------------------calc_asg_4week----------------------------------------
--
function calc_asg_4week (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id     in number
                        )
return number;
-- pragma restrict_references (calc_asg_4week, wnds, wnps);
--
-------------------------calc_asg_4week_action---------------------------------
--
function calc_asg_4week_action  (   p_assignment_action_id  in number
                                ,   p_balance_type_id       in number
                                ,   p_effective_date        in date default null
                                )
return number;
-- pragma restrict_references (calc_asg_4week_action, wnds, wnps);
--
-------------------------calc_asg_4weel_date----------------------------------
--
-- date mode function
--
function calc_asg_4week_date(   p_assignment_id         in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date
                            )
return number;
-- pragma restrict_references (calc_asg_4week_date, wnds, wnps);
--
-------------------------calc_asg_ptd_action----------------------------------
--
function calc_asg_ptd_action(   p_assignment_action_id  in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date default null
                            )
return number;
-- pragma restrict_references (calc_asg_ptd_action, wnds, wnps);
--
-------------------------calc_asg_ptd------------------------------------------
--
function calc_asg_ptd   (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id     in number
                        )
return number;
-- pragma restrict_references (calc_asg_ptd, wnds, wnps);
--
-------------------------calc_asg_ptd_date-------------------------------------
--
-- date mode function
--
function calc_asg_ptd_date  (   p_assignment_id         in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date
                            )
return number;
-- pragma restrict_references (calc_asg_ptd_date, wnds, wnps);
--
-------------------------calc_asg_td_action-----------------------------
--
function calc_asg_td_action (   p_assignment_action_id  in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date default null
                            )
return number;
-- pragma restrict_references (calc_asg_td_action, wnds, wnps);
--
-------------------------calc_asg_td------------------------------------
--
function calc_asg_td(   p_assignment_action_id  in number
                    ,   p_balance_type_id       in number
                    ,   p_effective_date        in date default null
                    ,   p_assignment_id     in number
                    )
return number;
-- pragma restrict_references (calc_asg_td, wnds, wnps);
--
-------------------------calc_asg_td_date-------------------------------
--
-- date mode function
--
function calc_asg_td_date   (   p_assignment_id         in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date
                            )
return number;
-- pragma restrict_references (calc_asg_td_date, wnds, wnps);
--
-------------------------calc_asg_run_action----------------------------
--
function calc_asg_run_action(   p_assignment_action_id  in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date default null
                            )
return number;
-- pragma restrict_references (calc_asg_run_action, wnds, wnps);
--
-------------------------calc_asg_run-----------------------------------
--
function calc_asg_run   (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id     in number
                        )
return number;
-- pragma restrict_references (calc_asg_run, wnds, wnps);
--
-------------------------calc_asg_run_date------------------------------
--
-- date mode function
--
function calc_asg_run_date  (   p_assignment_id         in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date    in date
                            )
return number;
-- pragma restrict_references (calc_asg_run_date, wnds, wnps);
--
-------------------------calc_payment_action----------------------------
--
function calc_payment_action(   p_assignment_action_id  in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date default null
                            )
return number;
-- pragma restrict_references (calc_payment_action, wnds, wnps);
--
-------------------------calc_payment-----------------------------------
--
function calc_payment   (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id     in number
                        )
return number;
-- pragma restrict_references (calc_payment, wnds, wnps);
--
-------------------------calc_payment_date------------------------------
--
-- date mode function
--
function calc_payment_date  (   p_assignment_id         in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date
                            )
return number;
-- pragma restrict_references (calc_payment_date, wnds, wnps);
--

----------------------------balance-----------------------------------------
--
function balance(   p_assignment_action_id  in number
                ,   p_defined_balance_id    in number
                )
return number;

--
end hr_nzbal;

 

/
