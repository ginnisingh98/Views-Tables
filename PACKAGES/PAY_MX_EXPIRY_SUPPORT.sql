--------------------------------------------------------
--  DDL for Package PAY_MX_EXPIRY_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_EXPIRY_SUPPORT" AUTHID CURRENT_USER AS
/* $Header: paymxbalexpccode.pkh 120.0 2005/05/29 11:49:56 appldev noship $ */

/*------------------------------ date_ec  ------------------------------------
   NAME
      date_ec
   DESCRIPTION
      Mexico specific Expiry checking code for the following date-related
      dimensions:
        Person and GRE and Bi-Month.
      The Expiry checking code for the rest of the dimensions uses functions
      delivered in PAY_IP_EXPIRY_SUPPORT.


   NOTES
      This procedure assumes the date portion of the dimension name
      is always at the end to allow accurate identification since
      this is used for many dimensions.
*/
PROCEDURE date_ec
(
   p_owner_payroll_action_id    IN     NUMBER,   -- run created balance.
   p_user_payroll_action_id     IN     NUMBER,   -- current run.
   p_owner_assignment_action_id IN     NUMBER,   -- assact created balance.
   p_user_assignment_action_id  IN     NUMBER,   -- current assact..
   p_owner_effective_date       IN     DATE,     -- eff date of balance.
   p_user_effective_date        IN     DATE,     -- eff date of current run.
   p_dimension_name             IN     VARCHAR2, -- balance dimension name.
   p_expiry_information        OUT NOCOPY NUMBER -- dimension expired flag.
);

/* This procedure is the overlaoded function that will take care of the
   of the requirement of Balance adjustment process.*/

PROCEDURE date_ec
(
   p_owner_payroll_action_id    IN     NUMBER,   -- run created balance.
   p_user_payroll_action_id     IN     NUMBER,   -- current run.
   p_owner_assignment_action_id iN     NUMBER,   -- assact created balance.
   p_user_assignment_action_id  IN     NUMBER,   -- current assact..
   p_owner_effective_date       IN     DATE,     -- eff date of balance.
   p_user_effective_date        IN     DATE,     -- eff date of current run.
   p_dimension_name             IN     VARCHAR2, -- balance dimension name.
   p_expiry_information        OUT NOCOPY DATE   -- dimension expired date.
);

END pay_mx_expiry_support;

 

/