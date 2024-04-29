--------------------------------------------------------
--  DDL for Package PAY_KW_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KW_BAL_UPLOAD" AUTHID CURRENT_USER as
  --  $Header: pykwbaup.pkh 120.0 2006/04/09 23:42:53 adevanat noship $
  --
  --  Copyright (c) 1999 Oracle Corporation
  --  All rights reserved
  --
  --  Date        Author   Bug/CR Num Notes
  --  -----------+--------+----------+-----------------------------------------
  --  15-Feb-06	  Anand MD            Initial Version
  --
-------------------------------------------------------------------------------
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
  -----------------------------------------------------------------------------
 --
  function expiry_date
  (
     p_upload_date       date,
     p_dimension_name    varchar2,
     p_assignment_id     number,
     p_original_entry_id number
  ) return date ;

    -----------------------------------------------------------------------------
  -- NAME
  --  is_supported
  -- PURPOSE
  --  Checks if the dimension is supported by the upload process.
  -- ARGUMENTS
  --  p_dimension_name - the balance dimension to be checked.
  -- USES
  -- NOTES
  --  Only a subset of the SG dimensions are supported and these have been
  --  picked to allow effective migration to release 10.
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
--
function is_supported
 (
  p_dimension_name varchar2
 ) return number;
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
      p_balance_type_id    number,
      p_dimension_name     varchar2,
      p_original_entry_id  number,
      p_upload_date        date,
      p_batch_line_id      number,
      p_test_batch_line_id number
   ) return number ;
 --
  -----------------------------------------------------------------------------
  -- name
  --  validate_batch_lines
  -- purpose
  --   applies bf specific validation to the batch.
  -- arguments
  --  p_batch_id - the batch to be validate_batch_linesd.
  -- uses
  -- notes
  --  this is used by pay_balance_upload.validate_batch_lines.
  -----------------------------------------------------------------------------
  --
  procedure validate_batch_lines ( p_batch_id number );
  --
end pay_kw_bal_upload;

 

/
