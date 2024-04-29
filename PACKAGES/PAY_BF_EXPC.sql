--------------------------------------------------------
--  DDL for Package PAY_BF_EXPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BF_EXPC" AUTHID CURRENT_USER as
/* $Header: paybfexc.pkh 115.0 1999/11/24 02:18:27 pkm ship      $ */

/*------------------------------ pytd_ec ------------------------------------*/
/*
   NAME
      pytd_ec - Person Tax Year To Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Person-level Tax Year to Date Balance Dimension
   NOTES
      <none>
*/
procedure pytd_ec
(
   p_owner_payroll_action_id    in     number,   -- run created balance.
   p_user_payroll_action_id     in     number,   -- current run.
   p_owner_assignment_action_id in     number,   -- assact created balance.
   p_user_assignment_action_id  in     number,   -- current assact..
   p_owner_effective_date       in     date,     -- eff date of balance.
   p_user_effective_date        in     date,     -- eff date of current run.
   p_dimension_name             in     varchar2, -- balance dimension name.
   p_expiry_information            out number    -- dimension expired flag.
);

/*------------------------------ aytd_ec ------------------------------------*/
/*
   NAME
      aytd_ec - Assignment Tax Year To Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Assignment-level Tax Year to Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at
      Payroll Action level.
*/
procedure aytd_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
);

/*------------------------------ pptd_ec ------------------------------------*/
/*
   NAME
      pptd_ec - Person Period To Date Expiry Check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Person-level Period to Date Balance Dimension
   NOTES
      Associated dimension is expiry checked at
      Payroll Action level.
*/
procedure pptd_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
);

/*------------------------------ aptd_ec ------------------------------------*/
/*
   NAME
      aptd_ec - Assignment Period To Date Expiry Check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Assignment-level Period to Date Balance Dimension
   NOTES
      Associated dimension is expiry checked at
      Payroll Action level.
*/
procedure aptd_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
);

/*---------------------------- pptd_alc_ec ---------------------------------*/
/*
   NAME
      aptd_ec - Person Period To Date Assact Level Expiry Check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Person-level Period to Date Balance Dimension (test)
   NOTES
      The associated dimension is expiry checked at
      Assignment Action ID level.

      This expiry checking code does access the list of
      balance context values.
*/
procedure pptd_alc_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_balance_context_values     in     varchar2,  -- list of context values.
   p_expiry_information            out number     -- dimension expired flag.
);

/*-------------------------- always_expires --------------------------------*/
/*
   NAME
      always_expires - Always expires procedure.
   DESCRIPTION
      Returns value that will cause expiry.
   NOTES
      This is useful for where we wish to create a balance on
      the database that is really a run level balance, but happens
      to have a dimension type of 'A' or 'P'.
*/
procedure always_expires
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
);

/*-------------------------- never_expires --------------------------------*/
/*
   NAME
      never_expires - Never expires procedure.
   DESCRIPTION
      When called, always returns a value that will not cause expiry.
   NOTES
      Although this expiry check could be replaced in reality with
      the 'never expires' expiry checking level, this is left here
      to reproduce the functionality of the original tests.
*/
procedure never_expires
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
);

/*------------------------------ pcon_ec -----------------------------------*/
/*
   NAME
      pcon_ec - Person CONtracted in Expiry Check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Person-level Contracted In YTD Balance Dimension
   NOTES
      The associated dimension is expiry checked at
      Payroll Action level.

      The associated dimension never expires, thus the
      expiry_information flag always returns (FALSE).
*/
procedure pcon_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
);

/*------------------------------ pcon_fc -----------------------------------*/
/*
   NAME
      pcon_fc - Person CONtracted in Feed Check.
   DESCRIPTION
      Feed checking code for the following:
        BF Person-level Contracted In YTD Balance Dimension
   NOTES
      <none>
*/
procedure pcon_fc
(
   p_payroll_action_id    in     number,
   p_assignment_action_id in     number,
   p_assignment_id        in     number,
   p_effective_date       in     date,
   p_dimension_name       in     varchar2,
   p_balance_contexts     in     varchar2,
   p_feed_flag            in out number
);

end pay_bf_expc;

 

/
