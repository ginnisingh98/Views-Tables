--------------------------------------------------------
--  DDL for Package PAY_FR_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_BAL_UPLOAD" AUTHID CURRENT_USER as
/* $Header: pyfrupld.pkh 120.0 2005/05/29 05:12 appldev noship $  */
-------------------------------------------------------------------------------
  -- NAME
  --  expiry_date
  -- PURPOSE
  --  Returns the expiry date of a given dimension relative to a date.
  -- ARGUMENTS
  --  p_upload_date       - the date on which the balance should be correct.
  --  p_dimension_name    - the dimension being set (in caps).
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
  ) return date;
  --
  -----------------------------------------------------------------------------
  -- NAME
  --  is_supported
  -- PURPOSE
  --  Checks if the dimension is supported by the upload process.
  -- ARGUMENTS
  --  p_dimension_name - the balance dimension to be checked (in caps).
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
  --
  function is_supported
  (
    p_dimension_name varchar2
  ) return number ;
  --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
  --  Applies FR specific validation to the batch.
  -- ARGUMENTS
  --  p_batch_id - the batch to be validated.
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
  -----------------------------------------------------------------------------
  -- NAME
  --  create_structure
  -- PURPOSE
  --  Creates the structure for Balance Upload
  -- ARGUMENTS
  --  p_batch_id - the batch for which a structure needs to be generated
  -- NOTES
  --  This is called from the SRS
  -----------------------------------------------------------------------------
  --
  procedure create_structure(p_business_group_id       in number,
                             p_batch_id                in number);
  --
  procedure create_structure(
                errbuf                 out NOCOPY varchar2,
                retcode                out NOCOPY number,
                p_business_group_id       in number,
                p_batch_id             in number);
end pay_fr_bal_upload;

 

/
