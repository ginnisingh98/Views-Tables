--------------------------------------------------------
--  DDL for Package PAY_HK_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_EXC" AUTHID CURRENT_USER AS
/* $Header: pyhkexch.pkh 120.1 2007/11/16 10:34:07 vamittal noship $ */
/*
  PRODUCT
     Oracle*Payroll
  NAME
     pyhkexch.pkb - PaYroll HK legislation EXpiry Checking code.
  DESCRIPTION
     Contains the expiry checking code associated with the HK
     balance dimensions.  Following the change
     to latest balance functionality, these need to be contained
     as packaged procedures.
  PUBLIC FUNCTIONS
     <none>
  PRIVATE FUNCTIONS
     <none>
  NOTES
     <none>
  MODIFIED (DD/MM/YY)
    jbailie    21/09/2000 - first created. Based on PAYSGEXC (115)

*/
PROCEDURE date_ec
(
   p_owner_payroll_action_id    in     number,   -- run created balance.
   p_user_payroll_action_id     in     number,   -- current run.
   p_owner_assignment_action_id in     number,   -- assact created balance.
   p_user_assignment_action_id  in     number,   -- current assact..
   p_owner_effective_date       in     date,     -- eff date of balance.
   p_user_effective_date        in     date,     -- eff date of current run.
   p_dimension_name             in     varchar2, -- balance dimension name.
   p_expiry_information         out nocopy  number    -- dimension expired flag.
);

FUNCTION get_expiry_date
(
   p_defined_balance_id         in     number,   -- defined balance.
   p_assignment_action_id       in     number    -- assact created balance.
) RETURN DATE;

FUNCTION calculated_value
(
   p_defined_balance_id         in     number,   -- defined balance.
   p_assignment_action_id       in     number,   -- assact created balance.
   p_tax_unit_id                in     number,   -- tax_unit
   p_source_id                  in     number,   -- source_id
   p_session_date               in     date
) RETURN NUMBER;

/* Bug No : 3004608 =>
   Included the following overloaded procedure specification for prevention of loss of latest balances during balance adjustment process */

PROCEDURE date_ec
(
   p_owner_payroll_action_id    in         number,     -- run created balance.
   p_user_payroll_action_id     in         number,     -- current run.
   p_owner_assignment_action_id in         number,     -- assact created balance.
   p_user_assignment_action_id  in         number,     -- current assact.
   p_owner_effective_date       in         date,       -- eff date of balance.
   p_user_effective_date        in         date,       -- eff date of current run.
   p_dimension_name             in         varchar2,   -- balance dimension name.
   p_expiry_date                out nocopy date        -- dimension expired date.
);

/* Bug 6318006 This procedure finds the start date based on the specified date for dimension _ASG_12MTHS_PREV */

PROCEDURE start_code_12mths_prev( p_effective_date  IN         DATE
                            , p_start_date      OUT NOCOPY DATE
                            , p_payroll_id      IN         NUMBER
                            , p_bus_grp         IN         NUMBER
                            , p_asg_action      IN         NUMBER
                            );


END pay_hk_exc;

/
