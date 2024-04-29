--------------------------------------------------------
--  DDL for Package PAY_KR_DIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_DIM_PKG" AUTHID CURRENT_USER as
/* $Header: pykrdim.pkh 120.0.12010000.4 2008/08/06 07:39:23 ubhat ship $ */

--------------------------------------------------------------------------------
procedure ptd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy number);  -- dimension expired flag.
--------------------------------------------------------------------------------
-- Overloaded procedure ptd_ec for bug 2815428
--
procedure ptd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy date);  -- dimension expired date.

--------------------------------------------------------------------------------
procedure mtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy number);  -- dimension expired flag.
--------------------------------------------------------------------------------
-- Overloaded procedure mtd_ec for bug 2815428
--
procedure mtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy date);  -- dimension expired date.

--------------------------------------------------------------------------------
procedure qtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy number);  -- dimension expired flag.
--------------------------------------------------------------------------------
-- Overloaded procedure qtd_ec for bug 2815428
--
procedure qtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy date);  -- dimension expired date.

--------------------------------------------------------------------------------
procedure ytd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy number);  -- dimension expired flag.
--------------------------------------------------------------------------------
-- Overloaded procedure ytd_ec for bug 2815428
--
procedure ytd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy date);  -- dimension expired date.


/* Bug 6263815 - Adding expiry checking code for _itd dimension */
--------------------------------------------------------------------------------
procedure itd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY number);   -- dimension expired flag.

--------------------------------------------------------------------------------
procedure itd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY date);   -- dimension expired date.

--------------------------------------------------------------------------------
procedure fqtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy number);  -- dimension expired flag.
--------------------------------------------------------------------------------
-- Overloaded procedure fqtd_ec for bug 2815428
--
procedure fqtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy date);  -- dimension expired date.
--------------------------------------------------------------------------------
procedure fytd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy  number);  -- dimension expired flag.
--------------------------------------------------------------------------------
-- Overloaded procedure fytd_ec for bug 2815428
--
procedure fytd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out nocopy  date);  -- dimension expired date.

--------------------------------------------------------------------------------
procedure hdtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_balance_context_values     in     varchar2,  -- list of context value
  p_expiry_information         out nocopy number);  -- dimension expired flag.
--------------------------------------------------------------------------------
-- Overloaded procedure hdtd_ec for bug 2815428
--
procedure hdtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_balance_context_values     in     varchar2,  -- list of context value
  p_expiry_information         out nocopy date);  -- dimension expired date.
--------------------------------------------------------------------------------

/*
procedure gen_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out nocopy number);
*/
--------------------------------------------------------------------------------
procedure bptd_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out nocopy number);
--------------------------------------------------------------------------------
procedure mth_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out nocopy number);
--------------------------------------------------------------------------------
procedure bon_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out nocopy number);
--------------------------------------------------------------------------------
procedure sep_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out nocopy number);
--------------------------------------------------------------------------------
function bonus_period_start_date(
	p_payroll_id		in number,
	p_effective_date	in date,
	p_assignment_set_id	in number,
	p_run_type_id		in number) return date;
--------------------------------------------------------------------------------
function bonus_period_start_date(
	p_assignment_action_id	in number,
	p_payroll_action_id	in number) return date;
--------------------------------------------------------------------------------

Function inc_or_exc_assact (
   p_bal_asact in pay_assignment_actions.assignment_action_id%type
  ,p_asact                      in pay_assignment_actions.assignment_action_id%type
  ,p_bal_asact_rtype_name       in pay_run_types_f.run_type_name%type
  ,p_asact_rtype_name           in pay_run_types_f.run_type_name%type ) return varchar2 ;

--------------------------------------------------------------------------------

PROCEDURE hdtd_start_date(
                     p_effective_date  IN  DATE     ,
                     p_start_date      OUT NOCOPY DATE,
                     p_payroll_id      IN  NUMBER   DEFAULT NULL,
                     p_bus_grp         IN  NUMBER   DEFAULT NULL,
                     p_asg_action      IN  NUMBER   DEFAULT NULL);
--------------------------------------------------------------------------
end pay_kr_dim_pkg;

/
