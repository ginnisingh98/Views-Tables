--------------------------------------------------------
--  DDL for Package PAY_BALANCE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_UPLOAD" AUTHID CURRENT_USER as
/* $Header: pybalupl.pkh 120.2.12010000.1 2008/07/27 22:08:31 appldev ship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pybalupl.pkh
 DESCRIPTION
  Uploads initial balances from batch tables.
 EXTERNAL
  process
  count_contexts
  dim_expiry_date
  dim_is_supported
  get_batch_info
  load_latest_balances
  lock_batch_header
 MODIFIED (DD-MON-YYYY)
 115.7  T.Habara    21-SEP-2006        Bug 5556876. Added t_batch_info_rec
                                       and get_batch_info().
 115.6  T.Habara    20-DEC-2005        Bug 4893251. Added dim_is_supported.
 115.5  T.Habara    05-APR-2004        Added whenever oserror statement.
                                       Nocopy changes.
                                       Removed get_tax_unit_id.
 115.4  N.Bristow   09-APR-2002        Added dbdrv statements.
 115.3  N.Bristow   09-APR-2002        Changes for historical balance loading.
 115.2  A.Logue     07-OCT-1999        Added passing p_batch_line_status to
                                       dim_expiry_date.
 110.1  A.Logue     01-OCT-1998        Bug 730491. Removed pragma on
                                       dim_expiry_date.
  40.5  J.ALLOUN    30-JUL-1996        Added error handling.
  40.4  N.Bristow   08-MAY-1996        Bug 359005. Added new procedure
                                       get_tax_unit_id.
  40.3  N.Bristow   22-Nov-1995        Added a call for the stand-alone latest
                                       balance loading script.
  40.0  J.S.Hobbs   16-May-1995        created.
*/

 --
 -- Record type used by the get_batch_info().
 --
 type t_batch_info_rec is record
   (batch_id           number
   ,business_group_id  number
   ,legislation_code   per_business_groups.legislation_code%type
   ,purge_mode         boolean
   );

 --
 -- Retrieves all the balance adjsutments held in the temporary table that
 -- are for a specific balance and lie between a range of dates. This is used
 -- to calculate the current value of a balance as set by the balance
 -- adjustments.
 --
 cursor csr_balance_adjustment
   (
    p_balance_type_id number
   ,p_expiry_date     date
   ,p_upload_date     date
   )  is
   select *
   from   pay_temp_balance_adjustments BA
   where  BA.balance_type_id = p_balance_type_id
     and  BA.adjustment_date between p_expiry_date
                                 and p_upload_date;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  dim_expiry_date
  -- PURPOSE
  --  Returns the boundary date of a dimension relative to a date ie. the date
  --  returned for a QTD dimension would be the start date of the quarter in
  --  which the date existed. For some dimensions the contexts can affect the
  --  date returned ie. if the dimension is GRE within QTD then the date must
  --  be set such that the assignment belongs to the particular GRE within the
  --  quarter.
  -- ARGUMENTS
  -- USES
  -- NOTES
  --  This is used by the csr_batch_line_transfer cursor.
  -----------------------------------------------------------------------------
 --
 function dim_expiry_date
 (
  p_business_group_id number
 ,p_upload_date       date
 ,p_dimension_name    varchar2
 ,p_assignment_id     number
 ,p_tax_unit_id       number
 ,p_jurisdiction_code varchar2
 ,p_original_entry_id number
 ,p_batch_line_status varchar2 default 'V'
 ) return date;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  dim_is_supported
  -- PURPOSE
  --  Returns Y if the specified balance dimension is supported in the
  --  balance initialization.
  -- ARGUMENTS
  --   p_legislation_code
  --   p_dimension_name
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 function dim_is_supported
 (
  p_legislation_code  in varchar2
 ,p_dimension_name    in varchar2
 ) return varchar2;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  get_batch_info
  -- PURPOSE
  --  Returns batch information that is currently running.
  -- ARGUMENTS
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 function get_batch_info return t_batch_info_rec;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  count_contexts
  -- PURPOSE
  --  Counts the number of contexts a balance dimension uses.
  -- ARGUMENTS
  -- USES
  -- NOTES
  --  This is used by the csr_batch_line_transfer cursor.
  -----------------------------------------------------------------------------
 --
 function count_contexts
 (
  p_balance_dimension_id number,
  p_dimension_name varchar2
 ) return number;
 --
 pragma restrict_references(count_contexts, WNDS, WNPS);
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  load_latest_balances
  -- PURPOSE
  --  Processes a batch of initial balances and will create the latest balances
  --  for the assignments.
  -- ARGUMENTS
  --  p_batch_id - identifies batch being processed.
  -- USES
  --  lock_batch
  --  valid_latest_balance_run
  --  load_latest_asg_balances
  -- NOTES
  --  This should only be used if the latest balances where not loaded by the
  --  balance loading process.
  -----------------------------------------------------------------------------
 --
 procedure load_latest_balances
 (
   p_batch_id in  number
 );
  -----------------------------------------------------------------------------
  -- NAME
  --  process
  -- PURPOSE
  --  Processes a batch of initial balances and will either validate the batch,
  --  transfer the initial balances to the system or purge the batch.
  -- ARGUMENTS
  --  errbuf     - error message string used by SRS.
  --  retcode    - return code for SRS, 0 - Success, 1 - Warning, 2 - Error.
  --  p_mode     - can be 'VALIDATE', 'TRANSFER', or 'PURGE'.
  --  p_batch_id - identifies batch being processed.
  -- USES
  --  lock_batch
  --  validate_batch
  --  transfer_batch
  --  purge_batch
  -- NOTES
  --  Can be run from SRS.
  -----------------------------------------------------------------------------
 --
 procedure process
 (
  errbuf     out nocopy varchar2
 ,retcode    out nocopy number
 ,p_mode     in  varchar2
 ,p_batch_id in  number
 );
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  lock_batch_header
  -- PURPOSE
  --  Locks the batch header.
  -- ARGUMENTS
  --  p_batch_id - the batch header to be locked.
  -- USES
  -- NOTES
  --  This is used by the insert, update and delete triggers for the table
  --  PAY_BALANCE_BATCH_LINES. This can be used to ensure that the batch lines
  --  cannot be changed once another user has a row level lock on the batch
  --  header. This is used by the process to freeze the batch definition while
  --  it is being processed.
  -----------------------------------------------------------------------------
 --
 procedure lock_batch_header
 (
  p_batch_id number
 );
 --

end pay_balance_upload;

/
