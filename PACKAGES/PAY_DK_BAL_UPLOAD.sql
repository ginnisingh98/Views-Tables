--------------------------------------------------------
--  DDL for Package PAY_DK_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_BAL_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pydkbalupl.pkh 120.1 2007/03/13 07:08:51 saurai noship $ */
  function expiry_date
  (
     p_upload_date       date,
     p_dimension_name    varchar2,
     p_assignment_id     number,
     p_original_entry_id number
  ) return date ;

  function is_supported
  (
    p_dimension_name varchar2
  ) return number ;

  function include_adjustment
   (
      p_balance_type_id    number,
      p_dimension_name     varchar2,
      p_original_entry_id  number,
      p_upload_date        date,
      p_batch_line_id      number,
      p_test_batch_line_id number
   ) return number ;

  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
  --  Applies DK specific validation to the batch.
  -- ARGUMENTS
  --  p_batch_id - the batch to be validate_batch_linesd.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.validate_batch_lines.
  -----------------------------------------------------------------------------
 --
  PROCEDURE validate_batch_lines (p_batch_id NUMBER);
 --


END PAY_DK_BAL_UPLOAD;

/
