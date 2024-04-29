--------------------------------------------------------
--  DDL for Package PAY_JP_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_BAL_UPLOAD" AUTHID CURRENT_USER as
/* $Header: pyjpupld.pkh 120.1 2006/04/24 00:53:56 ttagawa noship $  */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pyjpupld.pkh
 DESCRIPTION
  Stub File.
  Provides support for the upload of balances based on JP dimensions.
 EXTERNAL
  expiry_date
  include_adjustment
  is_supported
  validate_batch_lines
 INTERNAL
 MODIFIED (DD-MON-YYYY)
  110.0  A.Logue     11-Jul-1997        created.
  115.1  Keyazawa    12-OCT-1999        Remove the pragma.
  115.2  Ttagawa     18-OCT-2002        dbdrv added.
  115.3  ttagawa     21-Apr-2006        "in" added to input parameters.
*/
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
  p_upload_date        in date
 ,p_dimension_name     in varchar2
 ,p_assignment_id      in number
 ,p_original_entry_id  in number
 ) return date;
 --
-- pragma restrict_references(expiry_date, WNDS, WNPS);
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
  --  Only a subset of the JP dimensions are supported.
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
 --
 function is_supported
 (
  p_dimension_name  in varchar2
 ) return boolean;
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
  p_balance_type_id     in number
 ,p_dimension_name      in varchar2
 ,p_original_entry_id   in number
 ,p_bal_adjustment_rec  in pay_balance_upload.csr_balance_adjustment%rowtype
 ) return boolean;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
 --  Applies JP specific validation to the batch.
  -- ARGUMENTS
  --  p_batch_id - the batch to be validate_batch_linesd.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.validate_batch_lines.
  -----------------------------------------------------------------------------
 --
 procedure validate_batch_lines
 (
  p_batch_id  in number
 );
 --
end pay_jp_bal_upload;
 

/
