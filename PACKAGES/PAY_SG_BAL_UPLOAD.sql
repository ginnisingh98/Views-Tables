--------------------------------------------------------
--  DDL for Package PAY_SG_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_BAL_UPLOAD" AUTHID CURRENT_USER as
-- /* $Header: pysgupld.pkh 120.0 2005/05/29 08:50:42 appldev noship $ */
--
-- +======================================================================+
-- |              Copyright (c) 1997 Oracle Corporation UK Ltd            |
-- |                        Reading, Berkshire, England                   |
-- |                           All rights reserved.                       |
-- +======================================================================+
-- SQL Script File Name : pysgupld.pkh
-- Description          : This script delivers balance upload support
--                        functions for the Singapore localization (SG).
--
-- DELIVERS EXTERNAL functions
--   expiry_date
--   include_adjustment
--   is_supported
--   validate_batch_lines
--
-- Change List:
-- ------------
--
-- ======================================================================
-- Version  Date         Author    Bug No.  Description of Change
-- -------  -----------  --------  -------  -----------------------------
-- 115.0    30-JUN-2000  JBailie            Initial Version - based on the
--                                          assumption that the pay_balance_upload
--                                          package pybalupl.pkb will explicitly
--                                          call the function
--                                          pay_sg_bal_upload.insert_adjustment
--                                          and pass a record of the previously
--                                          processed adjustments.
--                                          This package needs to be reviewed
--                                          if a different approach is adopted
-- 115.1    21-JUL-2000  JBailie            Set ship state
-- 115.2    06-NOV-2000  jbailie            Changed to use pybalupl.pkb 115.17
--                                           removed get_tax_unit
--                                           removed tax_unit_id from expiry_date
--                                           added p_batch_line_id and
--                                                 p_test_batch_line_id to
--                                                      include_adjustment
-- 115.3    20-NOV-2000  jbailie            include_adjustment now returns number
--
-- ======================================================================
--
  -----------------------------------------------------------------------------
  -- FUNCTION NAME
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
  --  are for the same assignment and balance. The adjustment also lies between
  --  the expiry date of the new balance and the date on which it is to set.
  -- ARGUMENTS
  --  p_balance_type_id    - the balance to be set.
  --  p_dimension_name     - the balance dimension to be set.
  --  p_original_entry_id  - ORIGINAL_ENTRY_ID context.
  --  p_upload_date        - the date of the upload
  --  p_batch_line_id      - the batch_line_id from pay_balance_batch_line
  --  p_test_batch_line_id - the batch_line-id from pay_temp_balance_adjustments
  -- USES
  -- NOTES
  --  All the SG dimensions affect each other when they share the same context
  --  values so there is no special support required for individual dimensions.
  --  This is used by pay_balance_upload.get_current_value.
  -----------------------------------------------------------------------------
 --
 function include_adjustment
 (
  p_balance_type_id    number
 ,p_dimension_name     varchar2
 ,p_original_entry_id  number
 ,p_upload_date        date
 ,p_batch_line_id      number
 ,p_test_batch_line_id number
) return number;
  --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
 --   Applies SG specific validation to the batch.
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
end pay_sg_bal_upload;

 

/
