--------------------------------------------------------
--  DDL for Package PAY_AU_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_BAL_UPLOAD" AUTHID CURRENT_USER as
  --  $Header: pyaubaup.pkh 120.1 2005/09/12 00:51:53 ksingla noship $
  --
  --  Copyright (c) 1999 Oracle Corporation
  --  All rights reserved
  --
  --  Date        Author   Bug/CR Num Notes
  --  -----------+--------+----------+-----------------------------------------
  --  17 Feb 2000 JTurner             Completed development
  --  23-dec-1999 sgoggin             Created
  --
  function expiry_date
  ( p_upload_date       date
  , p_dimension_name    varchar2
  , p_assignment_id     number
  , p_original_entry_id number
  )
  return date;
  -----------------------------------------------------------------------------
  -- name
  --  is_supported
  -- purpose
  --  checks if the dimension is supported by the upload process.
  -- arguments
  --  p_dimension_name - the balance dimension to be checked.
  -- uses
  -- notes
  --  only a subset of the bf dimensions are supported and these have been
  --  picked to allow effective migration to release 10.
  --  this is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
  --
  function is_supported( p_dimension_name varchar2 ) return number;
  --
  -----------------------------------------------------------------------------
  -- name

  --  include_adjustment
  -- purpose
  --  given a dimension, and relevant contexts and details of an existing
  --  balanmce adjustment, it will find out if the balance adjustment effects
  --  the dimension to be set. both the dimension to be set and the adjustment
  --  are for the same assignment and balance. the adjustment also lies between
  --  the expiry date of the new balance and the date on which it is to set.
  -- arguments
  --  p_balance_type_id    - the balance to be set.
  --  p_dimension_name     - the balance dimension to be set.
  --  p_tax_unit_id        - tax_unit_id context.
  --  p_jurisdiction_code  - jurisdiction_code context.
  --  p_original_entry_id  - original_entry_id context.
  --  p_bal_adjustment_rec - details of an existing balance adjustment.
  -- uses
  -- notes
  --  all the bf dimensions affect each other when they share the same context
  --  values so there is no special support required for individual dimensions.
  --  this is used by pay_balance_upload.get_current_value.
  -----------------------------------------------------------------------------
  --
  function include_adjustment
  ( p_balance_type_id    number
  , p_dimension_name     varchar2
  , p_original_entry_id  number
  , p_upload_date        date
  , p_batch_line_id      number
  , p_test_batch_line_id number /*1985161 */
  )
  return number;
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
end pay_au_bal_upload;

 

/
