--------------------------------------------------------
--  DDL for Package PAY_BF_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BF_BAL_UPLOAD" AUTHID CURRENT_USER as
/* $Header: pybfupld.pkh 115.1 2003/09/19 03:05 thabara ship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pybfupld.pkb
 DESCRIPTION
  Provides support for the upload of balances based on BF dimensions.
 EXTERNAL
  expiry_date
  get_tax_unit
  include_adjustment
  is_supported
  validate_batch_lines
 INTERNAL
 MODIFIED (DD-MON-YYYY)
  115.1 T.Habara       18-Sep-2003        Added p_source_id and p_source_text
                                          params to include_adjustment.
  40.2  J.ALLOUN       30-JUL-1996        Added error handling.
  40.1  N.Bristow      08-May-1996        Bug 359005. Tax Unit Id is now passed
                                          to expiry date and include
                                          adjustment.
  40.0  N.Bristow      16-May-1995        created.
*/
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  get_tax_unit
  -- PURPOSE
  --  Returns the legal company an assignment is associated with at
  --  particular point in time.
  -- ARGUMENTS
  --  p_assignment_id  - the assignment
  --  p_effective_date - the date on which the information is required.
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 function get_tax_unit
 (
  p_assignment_id  number
 ,p_effective_date date
 ) return number;
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
  -----------------------------------------------------------------------------
 --
 function expiry_date
 (
  p_upload_date       date
 ,p_dimension_name    varchar2
 ,p_assignment_id     number
 ,p_tax_unit_id       number
 ,p_jurisdiction_code varchar2
 ,p_original_entry_id number
 ) return date;
 --
 pragma restrict_references(expiry_date, WNDS, WNPS);
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
  --  Only a subset of the BF dimensions are supported and these have been
  --  picked to allow effective migration to release 10.
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
 --
 function is_supported
 (
  p_dimension_name varchar2
 ) return boolean;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  include_adjustment
  -- PURPOSE
  --  Given a dimension, and relevant contexts and details of an existing
  --  balanmce adjustment, it will find out if the balance adjustment effects
  --  the dimension to be set. Both the dimension to be set and the adjustment
  --  are for the same assignment and balance. The adjustment also lies between
  --  the expiry date of the new balance and the date on which it is to set.
  -- ARGUMENTS
  --  p_balance_type_id    - the balance to be set.
  --  p_dimension_name     - the balance dimension to be set.
  --  p_tax_unit_id        - TAX_UNIT_ID context.
  --  p_jurisdiction_code  - JURISDICTION_CODE context.
  --  p_original_entry_id  - ORIGINAL_ENTRY_ID context.
  --  p_bal_adjustment_rec - details of an existing balance adjustment.
  -- USES
  -- NOTES
  --  All the BF dimensions affect each other when they share the same context
  --  values so there is no special support required for individual dimensions.
  --  This is used by pay_balance_upload.get_current_value.
  -----------------------------------------------------------------------------
 --
 function include_adjustment
 (
  p_balance_type_id    number
 ,p_dimension_name     varchar2
 ,p_jurisdiction_code  varchar2
 ,p_original_entry_id  number
 ,p_tax_unit_id        number
 ,p_assignment_id      number
 ,p_upload_date        date
 ,p_source_id          number
 ,p_source_text        varchar2
 ,p_bal_adjustment_rec pay_balance_upload.csr_balance_adjustment%rowtype
 ) return boolean;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
 --   Applies BF specific validation to the batch.
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
 );
 --
end pay_bf_bal_upload;

 

/
