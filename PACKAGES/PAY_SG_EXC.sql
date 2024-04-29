--------------------------------------------------------
--  DDL for Package PAY_SG_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_EXC" AUTHID CURRENT_USER AS
/* $Header: pysgexch.pkh 120.0 2005/05/29 08:46:12 appldev noship $ */
/*
  PRODUCT
     Oracle*Payroll
  NAME
     pysgexch.pkb - PaYroll SG legislation EXpiry Checking code.
  DESCRIPTION
     Contains the expiry checking code associated with the SG
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
    jbailie    25/04/00 - first created. Based on PAYUSEXC (115)

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
   p_expiry_information            out nocopy number    -- dimension expired flag.
);
PROCEDURE date_ec /* Bug 2797863 */

(

   p_owner_payroll_action_id    in     number,   -- run created balance.

   p_user_payroll_action_id     in     number,   -- current run.

   p_owner_assignment_action_id in     number,   -- assact created balance.

   p_user_assignment_action_id  in     number,   -- current assact..

   p_owner_effective_date       in     date,     -- eff date of balance.

   p_user_effective_date        in     date,     -- eff date of current run.

   p_dimension_name             in     varchar2, -- balance dimension name.

   p_expiry_information            out nocopy date    -- dimension expired date.

);


FUNCTION get_expiry_date
(
   p_defined_balance_id         in     number,   -- defined balance.
   p_assignment_action_id       in     number    -- assact created balance.
) RETURN DATE;

FUNCTION calculated_value
(
   p_defined_balance_id         in     number,   -- defined balance.
   p_assignment_action_id       in     number,    -- assact created balance.
   p_tax_unit_id                in     number,
   p_session_date               in     date
) RETURN NUMBER;


END pay_sg_exc;

 

/
