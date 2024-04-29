--------------------------------------------------------
--  DDL for Package PAY_ES_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_BAL_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pyesbupl.pkh 120.1 2005/05/31 02:01 vbattu noship $  */
-------------------------------------------------------------------------------
  -- NAME
  --  expiry_date
  -- PURPOSE
  --  Returns the expiry date of a given dimension relative to a date.
  -- ARGUMENTS
  --  p_upload_date       - the date on which the balance should be correct.
  --  p_dimension_name    - the dimension being set.
  --  p_assignment_id     - the assignment involved.
  --  p_original_entry_id - original_entry_id context.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.dim_expiry_date.
  -----------------------------------------------------------------------------
 --
  FUNCTION expiry_date (p_upload_date       DATE
		       ,p_dimension_name    VARCHAR2
		       ,p_assignment_id     NUMBER
		       ,p_original_entry_id NUMBER) RETURN DATE ;
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
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
 --
  FUNCTION is_supported (p_dimension_name VARCHAR2) RETURN NUMBER ;
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
  FUNCTION include_adjustment(p_balance_type_id    NUMBER
			     ,p_dimension_name     VARCHAR2
			     ,p_original_entry_id  NUMBER
			     ,p_upload_date        DATE
			     ,p_batch_line_id      NUMBER
			     ,p_test_batch_line_id NUMBER) RETURN NUMBER ;
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
 FUNCTION get_tax_unit ( p_assignment_id  NUMBER
			,p_effective_date DATE) RETURN NUMBER;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
  --  Applies ES specific validation to the batch.
  -- ARGUMENTS
  --  p_batch_id - the batch to be validate_batch_linesd.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.validate_batch_lines.
  -----------------------------------------------------------------------------
 --
  PROCEDURE validate_batch_lines (p_batch_id NUMBER);
  --
 END pay_es_bal_upload;

 

/
