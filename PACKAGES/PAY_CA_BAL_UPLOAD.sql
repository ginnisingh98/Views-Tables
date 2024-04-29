--------------------------------------------------------
--  DDL for Package PAY_CA_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_BAL_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pycaupld.pkh 115.2 2003/03/28 01:41:49 pganguly ship $  */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pycaupld.pkh
 DESCRIPTION
  Provides support for the upload of balances based on CA dimensions.
 EXTERNAL
  expiry_date
  include_adjustment
  is_supported
  validate_batch_lines
 INTERNAL
 MODIFIED (DD-MON-YYYY)
  110.0  A.Logue     11-Jul-1997        created.
  115.1  JARTHURT    31-JUL-2000        Added addition context level support
                                        parameters.
  115.2  P.Ganguly   27-MAR-2003        Added set verify off, dbdrv for GSCC
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
  --  Only a subset of the CA dimensions are supported.
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
  --  p_jurisdiction_code  - JURISDICTION_CODE context
  --  p_original_entry_id  - ORIGINAL_ENTRY_ID context.
  --  p_upload_date        -
  --  p_batch_line_id      -
  --  p_test_batch_line_id -
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
 ,p_upload_date        date
 ,p_batch_line_id      number
 ,p_test_batch_line_id number
 ) return number;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
 --  Applies CA specific validation to the batch.
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
END pay_ca_bal_upload;

 

/
