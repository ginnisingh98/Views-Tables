--------------------------------------------------------
--  DDL for Package PAY_HK_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_BAL_UPLOAD" AUTHID CURRENT_USER as
-- /* $Header: pyhkupld.pkh 120.0 2005/05/29 05:40:41 appldev noship $ */
--
-- +======================================================================+
-- |              Copyright (c) 2001 Oracle Corporation UK Ltd            |
-- |                        Reading, Berkshire, England                   |
-- |                           All rights reserved.                       |
-- +======================================================================+
-- SQL Script File Name : pyhkupld.pkh
-- Description          : This script delivers balance upload support
--                        functions for the Hong Kong localization (HK).
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
-- 115.0    02-JAN-2001  JBailie            Initial Version - based on the
--                                          pay_sg_bal_upload
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
  --  Only a subset of the HK dimensions are supported and these have been
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
  --  All the HK dimensions affect each other when they share the same context
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
 --   Applies HK specific validation to the batch.
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
end pay_hk_bal_upload;

 

/
