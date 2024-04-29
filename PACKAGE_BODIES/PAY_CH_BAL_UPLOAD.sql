--------------------------------------------------------
--  DDL for Package Body PAY_CH_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CH_BAL_UPLOAD" as
/* $Header: pychupld.pkb 115.0 99/07/17 05:52:36 porting ship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pychupld.pkb
 DESCRIPTION
  Stub File.
  Provides support for the upload of balances based on CH dimensions.
 EXTERNAL
  expiry_date
  include_adjustment
  is_supported
  validate_batch_lines
 INTERNAL
 MODIFIED (DD-MON-YYYY)
  110.0  A.Logue   11-Jul-1997        created.
*/
 --
 -- Date constants.
 --
 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  expiry_date
  -- PURPOSE
  --  Returns the expiry date of a given dimension relative to a date.
  -- ARGUMENTS
  --  p_upload_date       - the date on which the balance should be correct.
  --  p_dimension_name    - the dimension being set.
  --  p_assignment_id     - the assignment involved.
  --  p_original_entry_id - ORIGINAL_ENTRY_ID context.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.dim_expiry_date.
  --  If the expiry date cannot be derived then it is set to the end of time
  --  to indicate that a failure has occured. The process that uses the
  --  expiry date knows this rule and acts accordingly.
  -----------------------------------------------------------------------------
 --
 function expiry_date
 (
  p_upload_date       date
 ,p_dimension_name    varchar2
 ,p_assignment_id     number
 ,p_original_entry_id number
 ) return date is
   --
   -- Returns the date on which the assignment transferred payroll prior to
   -- the upload date NB. the payroll is the one the assignment is assigned to
   -- on the upload date.
   --
   l_expiry_date           date;
   --
 begin
   --
   return (l_expiry_date);
   --
 end expiry_date;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  is_supported
  -- PURPOSE
  --  Checks if the dimension is supported by the upload process.
  -- ARGUMENTS
  --  p_dimension_name - the balance dimension to be checked.
  -- USES
  -- NOTES
  --  Only a subset of the CH dimensions are supported.
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
 --
 function is_supported
 (
  p_dimension_name varchar2
 ) return boolean is
 begin
   --
   hr_utility.trace('Entering pay_ch_bal_upload.is_supported stub');
   --
   hr_utility.trace('Exiting pay_ch_bal_upload.is_supported stub');
   --
   return (TRUE);
   --
 end is_supported;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  include_adjustment
  -- PURPOSE
  --  Given a dimension, and relevant contexts and details of an existing
  --  balanmce adjustment, it will find out if the balance adjustment effects
  --  the dimension to be set. Both the dimension to be set and the adjustment
  --  are for the same assignment and balance.
  -- ARGUMENTS
  --  p_balance_type_id    - the balance to be set.
  --  p_dimension_name     - the balance dimension to be set.
  --  p_original_entry_id  - ORIGINAL_ENTRY_ID context.
  --  p_bal_adjustment_rec - details of an existing balance adjustment.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.get_current_value.
  -----------------------------------------------------------------------------
 --
 function include_adjustment
 (
  p_balance_type_id    number
 ,p_dimension_name     varchar2
 ,p_original_entry_id  number
 ,p_bal_adjustment_rec pay_balance_upload.csr_balance_adjustment%rowtype
 ) return boolean is
 --
 begin
   --
   hr_utility.trace('Entering pay_ch_bal_upload.include_adjustment stub');
   --
   hr_utility.trace('Exiting pay_ch_bal_upload.include_adjustment stub');
   --
   return (TRUE);
   --
 end include_adjustment;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
 --  Applies CH specific validation to the batch.
  -- ARGUMENTS
  --  p_batch_id - the batch to be validate_batch_linesd.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.validate_batch_lines.
  -----------------------------------------------------------------------------
 --
 procedure validate_batch_lines
 (
  p_batch_id number
 ) is
 begin
   --
   hr_utility.trace('Entering pay_ch_bal_upload.validate_batch_lines stub');
   --
   hr_utility.trace('Exiting pay_ch_bal_upload.validate_batch_lines stub');
   --
 end validate_batch_lines;
 --
end pay_ch_bal_upload;

/
