--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_UPLOAD" as
/* $Header: pybalupl.pkb 120.8.12010000.2 2008/10/01 06:12:44 ankagarw ship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pybalupl.pkb
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
 INTERNAL
  apply_adjustments
  cache_balances
  calculate_adjustment
  get_current_value
  get_tax_unit_id
  ins_latest_balance
  load_latest_asg_balances
  lock_batch
  post_transfer_batch
  purge_batch
  set_batch_status
  transfer_assignment
  transfer_batch
  undo_transfer_batch
  valid_latest_balance_run
  validate_assignment
  validate_balance
  validate_batch
  validate_batch_header
  validate_batch_lines
  validate_dimension
  validate_transfer_batch
  which_contexts
  write_message_line
 MODIFIED (DD-MON-YYYY)
  115.54 pgongada   08-MAY-2008        Bug # 6997838.
                                       Giving exception to BEE action as it
                                       doesn't contribute to the balance in
                                       the cursor csr_assignment_action under
                                       the procedure validate_assignment.
  115.53 T.Habara   03-OCT-2006        Removed the dynamic sql for batch_type.
  115.52 T.Habara   21-SEP-2006        Bug 5556876. Added g_batch_info and
                                       get_batch_info(). Modified process() and
                                       validate_batch() to set the global info.
                                       Use of dynamic sql for batch_type.
  115.51 T.Habara   31-MAY-2006        Exception handling in dim_expiry_date.
  115.50 T.Habara   28-FEB-2006        Bug 5057885. Corrected index hints for
                                       csr_assignment in transfer_batch and
                                       csr_assignment in load_latest_balances.
  115.49 T.Habara   22-DEC-2005        Nowait in locking batch header.
  115.48 T.Habara   20-DEC-2005        Bug 4893251. Added external function
                                       dim_is_supported.
  115.47 T.Habara   09-DEC-2005        Bug 4872523. Modified the payroll action
                                       creation to support different payrolls.
  115.46 T.Habara   15-NOV-2005        Batch header table is shared for batch
                                       adjustment usage. Added a validation for
                                       batch_type in validate_batch_header.
  115.45 T.Habara   16-FEB-2005        Modified validate_assignment().
                                       Modified write_message_line() to
                                       handle a token value. Bug 4179912.
  115.44 T.Habara   02-SEP-2004        Modified apply_adjustments(). The check
                                       for shared adjustments did not handle
                                       the case of orig entry id being null.
  115.43 T.Habara   11-MAY-2004        Modified transfer_assignment to set
                                       balance conflict errors to correct
                                       batch lines. (Bug 3604595)
  115.42 T.Habara   20-APR-2004        Bug 3513653. Support for source_number
                                       and source_text2.
                                       Use of execute immediate statements for
                                       the dynamic sqls.
                                       Added generic current value calculation
                                       with BAL_INIT_INCLUDE_ADJ leg rule.
  115.41 T.Habara   05-APR-2004        Nocopy changes.
                                       Removed create_adjustment that is
                                       no longer used.
  115.40 T.Habara   30-MAR-2004        Bug 3354765. Batch validation and
                                       transfer processes have been moved in
                                       validate_transfer_batch to handle
                                       unexpected error as a batch level error.
                                       Added post_transfer_batch.
                                       Corrected to pass a proper batch mode
                                       to init_batch.
                                       Corrected validate_balance to use
                                       element link validity cache.
  115.39 A.Logue    22-DEC-2003        Use of unsecured base tables for performance.
  115.38 T.Battoo   3-NOV-2003         support for sparse matrix and
				       pay_latest_balances table
  115.37 T.Habara   18-SEP-2003        Modified the BF include_adjustment call
                                       to pass Source ID and Source Text values.
  115.36 N.Bristow  13-MAR-2003        Source ID and Source Text where being corrupted
                                       on run results.
  115.35 A.Logue    03-MAR-2003        Bug 2700291 - Performance fix introduce
                                       use of csr_get_err_lines into purge_batch.
  115.34 N.Bristow  17-FEB-2003        Added Dynamic option for TAX_UNIT.
  115.33 A.Logue    20-JAN-2003        Remove times from dates.
  115.32 N.Bristow  14-JAN-2003        Jurisdiction Input Value can now be
                                       named by the legislation
  115.31 A.Logue    23-DEC-2002        Bug 2628014 - Enhanced load_latest_asg_balances
                                       to handle exceptions raised.  Affected lines
                                       are now set to Errored, and a message is
                                       put into pay_message_lines. This was done
                                       by passing batch_line_list and num_lines
                                       to the procedure. This avoids the scenario
                                       where some lines were being set as Valid, and
                                       others as Transferred - and the batch has been
                                       marked as Transferred.
  115.30 A.Logue    17-DEC-2002        Bug 2700291 - Performance fixes in
                                       cursor csr_assignment in transfer_batch
                                       and cursor csr_assignment in
                                       load_latest_balances.
  115.29 T.Habara   21-NOV-2002        Bug 2676349 - Implementation of batch
                                       adjustment.
                                       Added the following data structures.
                                        - g_payroll_action_rec_type
                                        - g_payroll_action_tab_type
                                        - g_payroll_actions
                                       Modified apply_adjustments()
                                        - added pay_bal_adjust.init_batch call
                                          and logic to handle payroll actions
                                          cache.
                                        - create_adjustment call was replaced
                                          with pay_bal_adjust.adjust_balance.
                                       Added the logic to handle payroll
                                       actions cache to transfer_assignment()
                                       and process().
                                       Modified transfer_batch() to update
                                       multiple batch lines for a payroll
                                       action.
                                       Modified the select statement in
                                       load_latest_asg_balances() to use
                                       paa.action_sequence instead of ppa.
  115.28 J.Hobbs    11-OCT-2002        Added logic to be able to process International
                                       Payroll supported dimensions. Made changes to
                                       dim_expiry_date()
                                       validate_dimension()
                                       get_current_value()
                                       validate_batch()
  115.27 N.Bristow  09-APR-2002        Changed code to allow balances to be loaded
                                       historically.
  115.26 M.Reid     04-FEB-2002        2211591: Corrected source_text parameter
  115.25 D.Saxby    18-DEC-2001        GSCC standards fix.
  115.24 D.Saxby    17-DEC-2001        Bug 2153245 - changes for Purge.
                                       o New global data structure member:
                                         purge_mode.
                                       o Changed lock_batch to init purge_mode
                                         as appropriate and reset the
                                         BALANCE_ROLLUP to TRANSFER mode.
                                       o Changed transfer_batch and
                                         undo_transfer_batch to perform
                                         commit based on new purge_mode.
                                       o Don't error if upload detects an
                                         assignment has been previously
                                         processed and we are purging.
                                       o Call bal_adjust_actions in purge
                                         mode when appropriate.
                                       o Added dbdrv line.
                                       o Added commit at end of file.
  115.23 A.Logue    25-JUN-2001        Performance changes to dim_expiry_date.
  115.22 A.Logue    22-JUN-2001        Performance changes to
                                       load_latest_asg_balances
                                       including hints.
  115.21 SuSivasu   20-JUN-2001        Re-arranged the parameter call
                                       to the which_context function.
  115.20 A.Logue    09-MAY-2001        Added some CBO hints. Bug 1763446.
  115.19 SuSivasu   06-APR-2001        Added two SOURCE_ID and SOURCE_TEXT
                                       contexts to the batch balance upload
                                       tables.
  115.18 JARTHURT   04-JAN-2001        Removed hard-coded calls to
                                       pay_ca_bal_upload. These calls are now
                                       performed dynamically using the new
                                       functionality added in 115.17
  115.17 N.Bristow  29-SEP-2000        Changes for Singapore, now passing
                                       tax unit id to balance adjustments,
                                       also passing batch_line_id to
                                       include_adjustment.
  115.16 A.Logue    13-JAN-2000        Ensure that error messages fetched from
                                       hr_utility.get_message are of max length 240
                                       to fit into pay_message_lines.
  115.14 A.Logue    07-OCT-1999        Pass batch_line_status to dim_expiry_date so that
                                       it does not call the legislative expiry_date
                                       procedure if the line is to be discarded (ie not 'V').
                                       This should give an improvement of performance.
  115.13 A.Logue    06-OCT-1999        Put call to dim_expiry_date back into
                                       csr_batch_line_transfer.  Can do this as the
                                       procedure does not have to be pragmatised in 11i
                                       and hence can be called from the cursor (nb it
                                       contains dynamic sql).  Thus can remove the insert
                                       sort implemented as part of 730491.  This
                                       should give an improvement of performance.
  115.12 A.Logue    18-MAY-1999        Change dbms_output to hr_utility.trace.
  115.11 A.Logue    14-MAY-1999        Order by line_id on line fetch.
  115.9 T.Battoo    20-APR-1999        setting the previous value for
                                       latest balances - this code had been
                                       deleted for some reason.
  115.8  A.Logue    15-APR-1999        Fix to support of canonical numbers.
  110.10 A.Logue    30-NOV-1998        Bug 713456.  Fix to legislation code
                                       check in csr_initial_balance_feed
                                       cursors.
  110.8 A.Logue     24-NOV-1998        Bug 768805.  Fix to include_adjustment dynamic
                                       sql bind variables for new legislations.
  110.7 A.Logue     23-NOV-1998        Bug 768805.  Fix to is_supported dynamic sql
                                       bind variables for new legislations.
  110.6 A.Logue     17-NOV-1998        Bug 713456. Business group and legislation
                                       code check on potential balance feeds in
                                       csr_initial_balance_feed.
  110.5 A.Logue     30-OCT-1998        Bug 730491. Changes to use dynamic sql to avoid
                                       explicit legislative package references for
                                       any new legislations.  This has resulted in
                                       a slighlty amended interface for any new
                                       legislations where include_adjustment is now
                                       passed the batch_line_id and returns a number,
                                       and is_supported which now returns a number.
  110.4 A.Logue     24-MAR-1998        Bug 485629. Fix for balance initialization
                                       elements, check for
                                       balance_initialization_flag AND
                                       stops a thread attempting to process
                                       a batch if it is already being
                                       processed by another thread. Done by
                                       batch header batch_status getting
                                       L-ocked during processing.
  110.3 N.Bristow   03-MAR-1998        Bug 630068. GRE name was not being
                                       checked correctly.
  110.2 N.Bristow   16-OCT-1997        Now setting the previous value for
                                       latest balances.
  40.26 A.Logue     02-JUL-1997        Bug 485629. Support for JP, CH and CA
                                       legislations ie calls to legislative
                                       routines.
  40.25 A.Logue     26-JUN-1997        Bug 418064. Further fix for jurisdiction
                                       clashes.
  40.24 A.Logue     24-JUN-1997        Bug 418064. Now checks if invalid
                                       combination of balance adjustments.
  40.23 N.Bristow   18-FEB-1997        When validating the tax unit the name
                                       as well as the id are now checked.
  40.22 N.Bristow   04-FEB-1997        Now commits in chunks when performing
                                       in undo mode.
  40.21 N.Bristow   12-JUN-1996        Bug 373446. No longer performing
                                       a full table scan when undoing
                                       a batch.
  40.20 N.Bristow   08-MAY-1996        Bug 359005. Now caching Tax Unit Id
                                       when validating. Reinstated the
                                       tax unit id column on
                                       pay_balance_batch_lines. Tuned several
                                       statements.
  40.19 N.Bristow   18-MAR-1996        Now padding expired latest balance
                                       columns with -9999.
  40.18 N.Bristow   18-MAR-1996        Bug 349583. Order by clause on
                                       csr_bal_adj was wrong, as a result
                                       a no_data_found error was produced
                                       later in the code.
  40.17 N.Bristow   08-MAR-1996        Bug 346991. Upload not erroring
                                       correctly when no defined balance id
                                       is found for the balance to be loaded.
  40.16 N.Bristow   14-DEC-1995        Error HR_7030_ELE_ENTRY_INV_ADJ was
                                       not being raised correctly.
  40.15 N.Bristow   27-Nov-1995        Now loads the latest balances when the
                                       balance value is zero.
  40.14 N.Bristow   22-Nov-1995        Added the loading of latest balances.
                                       Latest balances are now loaded in the
                                       transfer mode.
  40.13 N.Bristow   11-Nov-1995        Now calling bal_adjust_actions to
                                       perform the balance adjustment.
  40.12 N.Bristow   02-Nov-1995        Statements that reference the
                                       hr_tax_units_v view run very slow.
                                       Changed to access base tables.
  40.11 N.Bristow   23-Oct-1995        Now csr_batch_line_transfer ordering in
                                       decending date order. Also reversed the
                                       10.7 changes with regard to the BF
                                       legislative functions.
  40.10 N.Bristow   17-Oct-1995        Now using error tokens in fnd_messages.
                                       Also changed the order by on
                                       csr_batch_line_transfer.
  40.8  N.Bristow   20-Sep_1995        Error status is now set when
                                       an error is encountered.
  40.7  M.Callaghan 11-Sep-1995        "whenever sqlerror" added.
                                       Temp change: references to the package
                                       pay_bf_bal_upload commented out for
                                       prod 5 freeze.
  40.6  N.Bristow   25-Aug-1995        Now picks up the correct
                                       classifications.
  40.5  N.Bristow   13-Jul-1995        Checking against wrong legislation
                                       code.
  40.4  N.Bristow   13-Jul-1995        Closing cursors on error.
  40.3  N.Bristow   07-Jul-1995        Now uses the new rollback function.
  40.2  N.Bristow   06-Jul-1995        General bugs discovered when testing.
  40.1  J.S.Hobbs   16-May-1995        created.
*/
 --
 -- Array data types.
 --
 type number_array   is table of number       index by binary_integer;
 type varchar2_array is table of varchar2(80) index by binary_integer;
 type boolean_array  is table of boolean      index by binary_integer;
 --
 -- Global data structure.
 --
 type glbl_data_rec_type is record
   (upload_mode          varchar2(30)
   ,purge_mode           boolean
   ,upload_date          pay_balance_batch_headers.upload_date%type
   ,batch_id             pay_balance_batch_headers.batch_id%type
   ,business_group_id    pay_balance_batch_headers.business_group_id%type
   ,legislation_code     varchar2(30)
   ,payroll_id           pay_balance_batch_headers.payroll_id%type
   ,consolidation_set_id pay_consolidation_sets.consolidation_set_id%type
   ,assignment_id        pay_balance_batch_lines.assignment_id%type
   ,batch_header_status  pay_balance_batch_headers.batch_status%type
   ,batch_line_status    pay_balance_batch_lines.batch_line_status%type
   ,chunk_size           number(9)
   ,jurisdiction_iv      pay_input_values_f.name%type
   ,include_adj_rule     pay_legislation_rules.rule_mode%type
   );

 type g_payroll_action_rec_type is record
   (payroll_action_id    pay_payroll_actions.payroll_action_id%type
   ,effective_date       pay_payroll_actions.effective_date%type
   ,payroll_id           number
   );

 type g_payroll_action_tab_type is table of g_payroll_action_rec_type
   index by binary_integer;

 type t_pointer_rec is record
  (
    start_ptr number,
    end_ptr number
  );
 type t_pointer_tab is table of t_pointer_rec
   index by binary_integer;

 type t_inpval_context_rec is record
  (
    context_name ff_contexts.context_name%type,
    input_value_id pay_input_values_f.input_value_id%type
  );
 type t_inpval_context_tab is table of t_inpval_context_rec
   index by binary_integer;

 type t_balance_validation_rec is record
  (balance_type_id      number
  ,balance_name         pay_balance_types.balance_name%type
  ,element_type_id      number
  ,element_link_id      number
  ,ibf_input_value_id   number
  ,jc_input_value_id    number
  ,jurisdiction_level   number
  ,bal_invld            boolean -- does the balance exist ?
  ,bal_invl_feed        boolean -- does it have an intial balance feed ?
  ,bal_invl_link        boolean -- does it have an element link ?
  );

 type t_balance_validation_tab is table of t_balance_validation_rec
   index by binary_integer;


 type t_dimension_validation_rec is record
  (balance_dimension_id pay_balance_dimensions.balance_dimension_id%type
  ,dimension_name       pay_balance_dimensions.dimension_name%type
  ,invld                boolean -- does the dimension exist ?
  ,not_supp             boolean -- is it supported ?
  ,jc_cntxt             boolean -- does it use JURISDICTION_CODE ?
  ,gre_cntxt            boolean -- does it use TAX_UNIT_ID ?
  ,oee_cntxt            boolean -- does it use ORIGINAL_ENTRY_ID ?
  ,srcid_cntxt          boolean -- does it use SOURCE_ID ?
  ,srctxt_cntxt         boolean -- does it use SOURCE_TEXT ?
  ,runtyp_cntxt         boolean -- does it use Run Type ?
  ,sn_cntxt             boolean -- does it use SOURCE_NUMBER ?
  ,st2_cntxt            boolean -- does it use SOURCE_TEST2 ?
  ,other_cntxt          boolean -- are any other contexts used ?
  );

 type t_dimension_validation_tab is table of t_dimension_validation_rec
   index by binary_integer;


 type t_balance_rec is record
  (element_link_id     number
  ,ibf_input_value_id  number
  ,jc_input_value_id   number
  ,jurisdiction_level  number
  );

 type t_balance_tab is table of t_balance_rec
   index by binary_integer;

 --
 -- global cache to store the list of payroll actions for a batch
 --
 g_payroll_actions       g_payroll_action_tab_type;

 --
 -- current batch info for the reference from the outside code
 -- during the batch processing.
 --
 g_batch_info            t_batch_info_rec;

 --
 -- Retrieves all the non transferred batch lines for a batch NB. it is
 -- possible that a status has not been set for each line so the nvl ensures
 -- a valid comparison. This is used to retrieve the batch lines during the
 -- VALIDATION process.
 --
 cursor csr_batch_line_validate
   (
    p_batch_id number
   )  is
   select *
   from   pay_balance_batch_lines BL
   where  BL.batch_id          = p_batch_id
     and  nvl(BL.batch_line_status, 'U') <> 'T'
   order  by BL.assignment_id,
             BL.assignment_number
   for    update;
 --
 -- Retrieves the batch lines for an assignment within a batch NB. this
 -- combines the batch header and line information, provides the date on which
 -- the dimension expires and also how many contexts each uses. The batch lines
 -- are ordered by status, then by balance, then by the expiry date of the
 -- dimension, and then finally by the number of contexts the dimension uses.
 -- This is used to retrieve the batch lines during the TRANSFER process.
 --
 cursor csr_batch_line_transfer
   (
    p_batch_id      number
   ,p_assignment_id number
   )  is
   select BL.batch_id
         ,BL.batch_line_id
         ,BL.batch_line_status
         ,BL.assignment_id
         ,BL.balance_type_id
         ,BL.balance_dimension_id
         ,BL.dimension_name
         ,BL.balance_name
         ,BL.assignment_number
         ,BL.gre_name
         ,BL.tax_unit_id
         ,BL.jurisdiction_code
         ,BL.original_entry_id
         ,BL.source_id
         ,BL.source_text
         ,BL.source_number
         ,BL.source_text2
         ,BL.run_type_id
         ,BL.value
         ,trunc(nvl(BL.upload_date, BH.upload_date)) upload_date
         ,pay_balance_upload.count_contexts
          (BL.balance_dimension_id, BL.dimension_name) no_of_contexts
         ,pay_balance_upload.dim_expiry_date
          (BH.business_group_id
          ,trunc(nvl(BL.upload_date, BH.upload_date))
          ,BL.dimension_name
          ,BL.assignment_id
          ,BL.tax_unit_id
          ,BL.jurisdiction_code
          ,BL.original_entry_id
          ,BL.batch_line_status)    expiry_date
   from   pay_balance_batch_headers BH
         ,pay_balance_batch_lines   BL
   where  BH.batch_id      = p_batch_id
     and  BL.batch_id      = BH.batch_id
     and  BL.assignment_id = p_assignment_id
   order  by BL.assignment_id
	    ,decode(BL.batch_line_status,'T',1 ,'E',2 ,'V',3)
            ,BL.balance_type_id
            ,trunc(nvl(BL.upload_date, BH.upload_date))
            ,pay_balance_upload.dim_expiry_date
                  (BH.business_group_id
                  ,trunc(nvl(BL.upload_date,BH.upload_date))
                  ,BL.dimension_name
                  ,BL.assignment_id
                  ,BL.tax_unit_id
                  ,BL.jurisdiction_code
                  ,BL.original_entry_id
                  ,BL.batch_line_status) desc
            ,pay_balance_upload.count_contexts(
                  BL.balance_dimension_id, BL.dimension_name) desc
            ,BL.batch_line_id;

 --
 -- Retrieves all the transferred batch lines for a batch line.  The batch
 -- lines are ordered by the payroll action. This is used to retrieve the batch
 -- lines during the UNDO TRANSFER process.
 --
 cursor csr_batch_line_undo_transfer
   (
    p_batch_id number
   )  is
   select *
   from   pay_balance_batch_lines BL
   where  BL.batch_id = p_batch_id
     and  BL.batch_line_status   = 'T'
   order by BL.payroll_action_id;
 --
 -- SRS Constant Statuses
 --
 SRS_SUCCESS   constant number := 0;
 SRS_ERROR     constant number := 2;
 -- Constants identifying the level at which to report messages.
 --
 HEADER        constant number := 1;
 LINE          constant number := 2;
 --
 -- Constant holding the default chunk size.
 --
 CHUNK_SIZE    constant number := 10;
 --
 -- Constants holding the start and end of time.
 --
 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');
 --
 -- Global Status Indicator
 --
 status_indicator number;
 --
 -- Global Cache.
 --
 g_gre_tbl_name varchar2_array;
 g_gre_tbl_id   number_array;
 g_gre_tbl_nxt  number;
 g_runtyp_tbl_name varchar2_array;
 g_runtyp_tbl_id   number_array;
 g_runtyp_tbl_nxt  number;
 g_legislation_code varchar2(30);
 g_legislation_contexts pay_core_utils.t_contexts_tab;
 g_element_link_contexts  t_pointer_tab;
 g_input_val_contexts     t_inpval_context_tab;
 --
 g_bal_vald t_balance_validation_tab;   -- balance validation cache.
 g_dim_vald t_dimension_validation_tab; -- dimension validation cache.
 -- balance cache indexed by balance type id.
 g_balances             t_balance_tab;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  remove_messages
  -- PURPOSE
  -- This removes the error messages created for a batch. This is used when
  -- the batch is rerun or reversed.
  -- ARGUMENTS
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
procedure remove_messages(p_batch_id in number)
is
  cursor pml (p_batch_id number) is
  select batch_line_id
    from pay_balance_batch_lines
   where batch_id = p_batch_id;
--
begin
    hr_utility.trace('Entering pay_balance_upload.remove_messages');
    --
    --  Remove the messages
    --
    for pmlrec in pml(p_batch_id) loop
       delete from pay_message_lines
       where  source_type = 'L'
       and    source_id = pmlrec.batch_line_id;
    end loop;
    --
    hr_utility.set_location('pay_balance_upload.remove_messages',10);
    delete from pay_message_lines
    where  source_type = 'H'
    and    source_id = p_batch_id;
    --
    hr_utility.trace('Exiting pay_balance_upload.remove_messages');
end remove_messages;
  --
  -----------------------------------------------------------------------------
  -- NAME
  --  get_run_type_id
  -- PURPOSE
  -- This gets the run type name/id given the run type id/name. The run type
  -- details are then stored in a cache.
  -- ARGUMENTS
  -- USES
  -- NOTES
  -- A global cache is used to store the run type details.
  -----------------------------------------------------------------------------
 procedure get_run_type_id (p_business_group in     number,
                            p_run_type_name  in out nocopy varchar2,
                            p_run_type_id    in out nocopy number,
                            p_effective_date in     date) is
   cursor csr_run_type
     (
      p_business_group_id number
     ,p_run_type_name     varchar2
     ,p_run_type_id  number
     ,p_effective_date date
     )  is
     select upper(prt.run_type_name) run_type_name,
            prt.run_type_id
     from   pay_run_types_f prt,
            per_business_groups_perf pbg
     where  pbg.business_group_id = p_business_group_id
       and  p_effective_date between prt.effective_start_date
                                 and prt.effective_end_date
       and  (pbg.business_group_id = prt.business_group_id
           or pbg.legislation_code = prt.legislation_code
           or (prt.business_group_id is null
              and prt.legislation_code is null))
       and  p_run_type_id = prt.run_type_id
       and  p_run_type_id is not null
     union all
     select upper(prt.run_type_name) run_type_name,
            prt.run_type_id
     from   pay_run_types_f prt,
            per_business_groups_perf pbg
     where  pbg.business_group_id = p_business_group_id
       and  p_effective_date between prt.effective_start_date
                                 and prt.effective_end_date
       and  (pbg.business_group_id = prt.business_group_id
           or pbg.legislation_code = prt.legislation_code
           or (prt.business_group_id is null
              and prt.legislation_code is null))
       and  upper(prt.run_type_name) = upper(p_run_type_name)
       and  p_run_type_id is null;
   --
   l_run_type_rec csr_run_type%rowtype;
   l_run_type_name           varchar2(80);
   l_count              NUMBER;
   l_found              BOOLEAN;
 begin
   hr_utility.trace('Entering pay_balance_upload.get_run_type_id');
   --
   -- Search for the defined balance in the Cache.
   --
   l_found := FALSE;
   if (p_run_type_id is not null) then
      hr_utility.set_location('pay_balance_upload.get_run_type_id',10);
      l_count := 1;
      while (l_count < g_runtyp_tbl_nxt and l_found = FALSE) loop
         if (p_run_type_id  = g_runtyp_tbl_id(l_count)) then
            p_run_type_id := g_runtyp_tbl_id(l_count);
            p_run_type_name := g_runtyp_tbl_name(l_count);
            l_found := TRUE;
         end if;
         l_count := l_count + 1;
      end loop;
   else
      if (p_run_type_name is not null) then
         hr_utility.set_location('pay_balance_upload.get_run_type_id',20);
         l_run_type_name := upper(p_run_type_name);
         l_count := 1;
         while (l_count < g_runtyp_tbl_nxt and l_found = FALSE) loop
            if (l_run_type_name = g_runtyp_tbl_name(l_count)) then
               p_run_type_id := g_runtyp_tbl_id(l_count);
               p_run_type_name := g_runtyp_tbl_name(l_count);
               l_found := TRUE;
            end if;
            l_count := l_count + 1;
         end loop;
      end if;
   end if;
   hr_utility.set_location('pay_balance_upload.get_run_type_id',30);
   --
   -- If the balance is not in the Cache get it from the database.
   --
   if (l_found = FALSE) then
     hr_utility.set_location('pay_balance_upload.get_run_type_id',40);
     --
     open csr_run_type(p_business_group,
                       p_run_type_name,
                       p_run_type_id,
                       p_effective_date);
     fetch csr_run_type into l_run_type_rec;
     --
     -- The GRE doesn't exist so raise error.
     --
     if csr_run_type%notfound then
        close csr_run_type;
        raise no_data_found;
     end if;
     --
     p_run_type_name    := l_run_type_rec.run_type_name;
     p_run_type_id := l_run_type_rec.run_type_id;
     close csr_run_type;
     --
     -- Place the defined balance in cache.
     --
     g_runtyp_tbl_name(g_runtyp_tbl_nxt) := l_run_type_rec.run_type_name;
     g_runtyp_tbl_id(g_runtyp_tbl_nxt) := l_run_type_rec.run_type_id;
     g_runtyp_tbl_nxt := g_runtyp_tbl_nxt + 1;
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.get_run_type_id');
 exception
    when no_data_found then
      hr_utility.set_location('pay_balance_upload.get_run_type_id',50);
      -- close csr_tax_unit;
      hr_utility.trace('Exiting pay_balance_upload.get_run_type_id');
      raise;
 end;
  --
  -----------------------------------------------------------------------------
  -- NAME
  --  get_tax_unit_id
  -- PURPOSE
  -- This gets the tax unit name/id given the tax unit id/name. The tax unit
  -- details are then stored in a cache.
  -- ARGUMENTS
  -- USES
  -- NOTES
  -- A global cache is used to store the tax unit details.
  -----------------------------------------------------------------------------
 procedure get_tax_unit_id (p_business_group in     number,
                            p_gre_name       in out nocopy varchar2,
                            p_tax_unit_id    in out nocopy number) is
   cursor csr_tax_unit
     (
      p_business_group_id number
     ,p_gre_name     varchar2
     ,p_tax_unit_id  number
     )  is
     select upper(name) tax_unit_name,
            tax_unit_id
     from   hr_tax_units_v
     where  business_group_id = p_business_group_id
       and  p_tax_unit_id = tax_unit_id
       and  p_tax_unit_id is not null
     union all
     select upper(name) tax_unit_name,
            tax_unit_id
     from   hr_tax_units_v
     where  business_group_id = p_business_group_id
       and  upper(name)       = upper(p_gre_name)
       and  p_tax_unit_id is null;
   --
   cursor csr_establishment_unit
     (
      p_business_group_id number
     ,p_name     varchar2
     ,p_establishment_id  number
     )  is
     select upper(name) tax_unit_name,
            ORGANIZATION_ID tax_unit_id
     from   hr_fr_establishments_v
     where  business_group_id = p_business_group_id
       and  p_establishment_id = ORGANIZATION_ID
       and  p_establishment_id is not null
     union all
     select upper(name) tax_unit_name,
            ORGANIZATION_ID tax_unit_id
     from   hr_fr_establishments_v
     where  business_group_id = p_business_group_id
       and  upper(name)       = upper(p_name)
       and  p_establishment_id is null;
   --
   g_leg_rule    pay_legislation_rules.rule_mode%type;
   --
   l_gre_rec csr_tax_unit%rowtype;
   l_gre_name           varchar2(80);
   l_count              NUMBER;
   l_found              BOOLEAN;
 begin
   hr_utility.trace('Entering pay_balance_upload.get_tax_unit_id');
   --
   -- Search for the defined balance in the Cache.
   --
   l_found := FALSE;
   if (p_tax_unit_id is not null) then
      hr_utility.set_location('pay_balance_upload.get_tax_unit_id',10);
      l_count := 1;
      while (l_count < g_gre_tbl_nxt and l_found = FALSE) loop
         if (p_tax_unit_id  = g_gre_tbl_id(l_count)) then
            p_tax_unit_id := g_gre_tbl_id(l_count);
            p_gre_name := g_gre_tbl_name(l_count);
            l_found := TRUE;
         end if;
         l_count := l_count + 1;
      end loop;
   else
      if (p_gre_name is not null) then
         hr_utility.set_location('pay_balance_upload.get_tax_unit_id',20);
         l_gre_name := upper(p_gre_name);
         l_count := 1;
         while (l_count < g_gre_tbl_nxt and l_found = FALSE) loop
            if (l_gre_name = g_gre_tbl_name(l_count)) then
               p_tax_unit_id := g_gre_tbl_id(l_count);
               p_gre_name := g_gre_tbl_name(l_count);
               l_found := TRUE;
            end if;
            l_count := l_count + 1;
         end loop;
      end if;
   end if;
   hr_utility.set_location('pay_balance_upload.get_tax_unit_id',30);
   --
   -- If the balance is not in the Cache get it from the database.
   --
   if (l_found = FALSE) then
     hr_utility.set_location('pay_balance_upload.get_tax_unit_id',40);
     begin
     --
        select plr.rule_mode
        into g_leg_rule
        from pay_legislation_rules plr,
             per_business_groups_perf pbg
        where pbg.business_group_id = p_business_group
        and plr.legislation_code = pbg.legislation_code
        and plr.rule_type = 'TAX_UNIT';
        --
     --
     exception
        when no_data_found then
           g_leg_rule := 'N';
     end;
     --
     if (g_leg_rule in ('Y', 'D')) then
        open csr_tax_unit(p_business_group,
                          p_gre_name,
                          p_tax_unit_id);
        fetch csr_tax_unit into l_gre_rec;
        --
        -- The GRE doesn't exist so raise error.
        --
        if csr_tax_unit%notfound then
           close csr_tax_unit;
           raise no_data_found;
        end if;
        --
        p_gre_name    := l_gre_rec.tax_unit_name;
        p_tax_unit_id := l_gre_rec.tax_unit_id;
        close csr_tax_unit;
     elsif (g_leg_rule = 'E') then
        open csr_establishment_unit(p_business_group,
                          p_gre_name,
                          p_tax_unit_id);
        fetch csr_establishment_unit into l_gre_rec;
        --
        -- The Establishment doesn't exist so raise error.
        --
        if csr_establishment_unit%notfound then
           close csr_establishment_unit;
           raise no_data_found;
        end if;
        --
        p_gre_name    := l_gre_rec.tax_unit_name;
        p_tax_unit_id := l_gre_rec.tax_unit_id;
        close csr_establishment_unit;
     end if;
      --
      -- Place the defined balance in cache.
      --
      g_gre_tbl_name(g_gre_tbl_nxt) := l_gre_rec.tax_unit_name;
      g_gre_tbl_id(g_gre_tbl_nxt) := l_gre_rec.tax_unit_id;
      g_gre_tbl_nxt := g_gre_tbl_nxt + 1;
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.get_tax_unit_id');
 exception
    when no_data_found then
      hr_utility.set_location('pay_balance_upload.get_tax_unit_id',50);
      -- close csr_tax_unit;
      hr_utility.trace('Exiting pay_balance_upload.get_tax_unit_id');
      raise;
 end;
  -----------------------------------------------------------------------------
  -- NAME
  --  write_message_line
  -- PURPOSE
  --  Writes a message to the message lines table.
  -- ARGUMENTS
  --  p_meesage_level - either HEADER or LINE constants.
  --  p_batch_id      - the batch to report the error against      (optional)
  --  p_batch_line_id - the batch line to report the error against (optional)
  --  p_meesage_text  - the text explaining the error.
  --  p_message_token - the token for the text explaining the error.
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure write_message_line
 (
  p_meesage_level number
 ,p_batch_id      number
 ,p_batch_line_id number
 ,p_message_text  varchar2
 ,p_message_token varchar2
 ,p_token_name    varchar2 default null
 ,p_token_value   varchar2 default null
 ) is
   --
   -- The message text to be reported.
   --
   l_message_text varchar2(500);
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.write_message_line');
   --
   -- Set global error indicator.
   --
   status_indicator := SRS_ERROR;
   --
   -- The message text has been passed.
   --
   if p_message_text is not null then
     l_message_text := p_message_text;
   --
   -- The message token for the message text has been passed so extract the
   -- message text.
   --
   else
     hr_utility.set_message(801, p_message_token);
     if p_token_name is not null then
       --
       -- Set the token value if specified.
       --
       hr_utility.set_message_token
         (p_token_name, p_token_value);
     end if;
     l_message_text := substrb(hr_utility.get_message, 1, 500);
   end if;
   --
   -- Create new message line.
   --
   hr_utility.trace(l_message_text);
   --
   insert into pay_message_lines
   (line_sequence
   ,message_level
   ,source_id
   ,source_type
   ,line_text)
   values
   (pay_message_lines_s.nextval
   ,'F' -- 'F'atal
   ,decode(p_meesage_level, HEADER, p_batch_id, LINE, p_batch_line_id)
   ,decode(p_meesage_level, HEADER, 'H'       , LINE, 'L')
   ,substr(l_message_text, 1, 240));
   --
   hr_utility.trace('Exiting pay_balance_upload.write_message_line');
   --
 end write_message_line;
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
 ) return date is
   --
   -- Retrieves the legislation ocde for the business group.
   --
   cursor csr_legislation_code
     (
      p_business_group_id number
     ) is
     select BG.legislation_code
     from   per_business_groups_perf BG
     where  BG.business_group_id = p_business_group_id;
   --
   -- Holds the expiry date of the dimension.
   --
   l_expiry_date      date;
   --
   -- Holds the legislation code for the business group.
   --
   l_legislation_code varchar2(30);
   --
   -- Dynamic sql variables
   --
   sql_curs           number;
   rows_processed     integer;
   statem             varchar2(512);
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.dim_expiry_date');
   --
   if g_legislation_code is null then
   --
   -- Get the legislation code for the business group.
   --
      open  csr_legislation_code(p_business_group_id);
      fetch csr_legislation_code into g_legislation_code;
      close csr_legislation_code;
   end if;
   --
   l_legislation_code := g_legislation_code;
   --
   if (p_batch_line_status <> 'V') then
   --
   -- line is not valid and hence no point working
   -- out expiry date as it is not used anyway
   --
     hr_utility.trace('pay_balance_upload.dim_expiry_date invalid line');
     --
     l_expiry_date := p_upload_date;
   --
   --
   -- If the dimension uses one of the International Payroll supported routes
   -- then process it NB. this could be for any legislation. All other dimensions
   -- for a given legislation will be processed in the relevant legislation specific
   -- package.
   --
   elsif pay_ip_bal_upload.international_payroll(p_dimension_name ,l_legislation_code) then
     l_expiry_date := pay_ip_bal_upload.expiry_date
                        (p_upload_date
                        ,p_dimension_name
                        ,p_assignment_id
                        ,p_original_entry_id
                        ,p_business_group_id
                        ,l_legislation_code);
   elsif l_legislation_code = 'GB' then
     --
     -- GB dimensions.
     --
     hr_utility.trace('pay_balance_upload.dim_expiry_date UK dimensions');
     --
     statem := 'BEGIN
     :l_expiry_date := pay_uk_bal_upload.expiry_date
                      (:p_upload_date
                      ,:p_dimension_name
                      ,:p_assignment_id
                      ,:p_original_entry_id);  END;';
     --
     execute immediate statem
       using out l_expiry_date
            ,p_upload_date
            ,p_dimension_name
            ,p_assignment_id
            ,p_original_entry_id
            ;
     --
   elsif (l_legislation_code = 'US') OR (l_legislation_code = 'BF') then
     --
     -- US + BF dimensions.
     --
     hr_utility.trace('pay_balance_upload.dim_expiry_date US or BF dimensions');
     --
     statem := 'BEGIN
     :l_expiry_date := pay_'||lower(l_legislation_code)||'_bal_upload.expiry_date
                      (:p_upload_date
                      ,:p_dimension_name
                      ,:p_assignment_id
                      ,:p_tax_unit_id
                      ,:p_jurisdiction_code
                      ,:p_original_entry_id); END;';
     --
     execute immediate statem
       using out l_expiry_date
            ,p_upload_date
            ,p_dimension_name
            ,p_assignment_id
            ,p_tax_unit_id
            ,p_jurisdiction_code
            ,p_original_entry_id
            ;
     --
   else
     --
     -- Other Legislations dimensions.
     --
     statem := 'BEGIN
     :l_expiry_date := pay_'||lower(l_legislation_code)||'_bal_upload.expiry_date
                      (:p_upload_date
                      ,:p_dimension_name
                      ,:p_assignment_id
                      ,:p_original_entry_id); END;';

     execute immediate statem
       using out l_expiry_date
            ,p_upload_date
            ,p_dimension_name
            ,p_assignment_id
            ,p_original_entry_id
            ;
     --
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.dim_expiry_date');
   --
   -- Return the expiry date for the dimension.
   --
   return (l_expiry_date);
   --
 exception
   when others then
     --
     -- Ensures not to raise any error since it causes
     -- csr_batch_line_transfer to fail, and therefore it
     -- cannot be trapped in transfer_assignment.
     --
     hr_utility.trace('Error in pay_balance_upload.dim_expiry_date');
     hr_utility.trace(sqlerrm);
     return null;

 end dim_expiry_date;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  dim_is_supported
  -- PURPOSE
  --  Returns Y if the specified balance dimension is supported in the
  --  balance initialization. This is a wrapper function to call the
  --  legislative is_supported function.
  -- ARGUMENTS
  --   p_legislation_code
  --   p_dimension_name
  -- USES
  --   pay_xx_bal_upload.is_supported
  -- NOTES
  --   This function does not check the existence of the dimension.
  -----------------------------------------------------------------------------
 --
 function dim_is_supported
 (
  p_legislation_code  in varchar2
 ,p_dimension_name    in varchar2
 ) return varchar2 is
 --
   l_dim_name     pay_balance_dimensions.dimension_name%type;
   l_is_supported boolean;
   statem         varchar2(256);
   dim_not_supp   number;
 --
 begin
   --
   l_dim_name      := upper(p_dimension_name);
   --
   -- If the dimension uses one of the International Payroll supported routes
   -- then process it NB. this could be for any legislation. All other dimensions
   -- for a given legislation will be processed in the relevant legislation specific
   -- package.
   --
   if pay_ip_bal_upload.international_payroll(l_dim_name, p_legislation_code) then
     l_is_supported := true;
   elsif p_legislation_code = 'GB' then
     l_is_supported := pay_uk_bal_upload.is_supported(l_dim_name);
   elsif p_legislation_code = 'US' then
     l_is_supported := pay_us_bal_upload.is_supported(l_dim_name);
   elsif p_legislation_code = 'JP' then
     l_is_supported := pay_jp_bal_upload.is_supported(l_dim_name);
   elsif p_legislation_code = 'CH' then
     l_is_supported := pay_ch_bal_upload.is_supported(l_dim_name);
   elsif p_legislation_code = 'BF' then
     l_is_supported := pay_bf_bal_upload.is_supported(l_dim_name);
   else
   --
   -- Other Legislations dimensions.
   -- Note:  can't pass booleans in dynamic sql, so new legislative packages
   -- should return a number with 0 denoting false, and 1 denoting true.
   --
     begin
       statem := 'BEGIN
       :dim_not_supp := pay_'||lower(p_legislation_code)||'_bal_upload.is_supported(:l_dim_name); END;';
       --
       execute immediate statem
         using out dim_not_supp
              ,l_dim_name
              ;
       --
       if dim_not_supp = 0 then
          l_is_supported := false;
       else
          l_is_supported := true;
       end if;
     exception
       when others then
         --
         -- Basically the process reaches here because the localization does
         -- not have the correct balance upload package or is using the
         -- international payroll but the dimension is not supported.
         -- In either case, the dimension is not available, hence marking it
         -- as not supported instead of raising a sql error.
         --
         l_is_supported := false;
     end;
   end if;
   --
   if l_is_supported then
     return 'Y';
   else
     return 'N';
   end if;
   --
 end dim_is_supported;
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
 function get_batch_info return t_batch_info_rec
 is
 begin
   return g_batch_info;
 end get_batch_info;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  count_contexts
  -- PURPOSE
  --  Counts the number of contexts a balance dimension uses.
  -- ARGUMENTS
  --  p_balance_dimension_id - the balance dimeension for which the number of
  --                           contexts is required for.
  -- USES
  -- NOTES
  --  This is used by the csr_batch_line_transfer cursor.
  -----------------------------------------------------------------------------
 --
 function count_contexts
 (
  p_balance_dimension_id number,
  p_dimension_name varchar2
 ) return number is
   --
   -- Holds the number of contexts a balance dimension uses.
   --
   l_no_contexts number;
   --
 begin
   --
   -- Count the number of contexts used by the balance dimension.
   --
   select count(CU.context_id)
   into   l_no_contexts
   from   pay_balance_dimensions  BD
	 ,ff_route_context_usages CU
   where  CU.route_id             = BD.route_id
     and  BD.balance_dimension_id = p_balance_dimension_id;
   --
--
   -- NBR Hard Coding for Korea.
   if (p_dimension_name  like '%_BON'
       or p_dimension_name  like  '%_MTH') then
     l_no_contexts := l_no_contexts +1;
   end if;
--
   return (l_no_contexts);
   --
 end count_contexts;
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
 ) is
   --
   -- Locks the batch header.
   --
   cursor csr_lock_batch_header
     (
      p_batch_id number
     )  is
     select BBH.batch_id
     from   pay_balance_batch_headers BBH
     where  BBH.batch_id = p_batch_id
     for update nowait;
   --
   -- Holds the batch_id of the locked batch header.
   --
   l_batch_id number;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.lock_batch_header');
   --
   -- Lock the specified batch header.
   --
   begin
     open  csr_lock_batch_header(p_batch_id);
     fetch csr_lock_batch_header into l_batch_id;
     close csr_lock_batch_header;
   exception
     when others then
       if csr_lock_batch_header%isopen then
	 close csr_lock_batch_header;
       end if;
       raise;
   end;
   --
   hr_utility.trace('Exiting pay_balance_upload.lock_batch_header');
   --
 end lock_batch_header;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  get_current_value
  -- PURPOSE
  --  Calculates the current value for a balance based on the list of balance
  --  adjustments that have already been worked out ie. a YTD balance may be
  --  partially set already by a previous QTD balance.
  -- ARGUMENTS
  --  p_glbl_data_rec   - global data structure.
  --  p_batch_line_rec  - the current batch line
  --  p_current_amount  - the current amount for the balance.
  --  p_min_expiry_date - the minimum expiry date of all the balances that
  --                      contribute to the current amount.
  -- USES
  -- NOTES
  --  The list of balance adjustments for the assignment are held in a
  --  temporary DB table caled PAY_TEMP_BALANCE_ADJUSTMENTS.
  -----------------------------------------------------------------------------
 --
 procedure get_current_value
 (
  p_glbl_data_rec   in            glbl_data_rec_type
 ,p_batch_line_rec  in            csr_batch_line_transfer%rowtype
 ,p_current_value      out nocopy number
 ,p_min_expiry_date    out nocopy date
 ) is
   --
   -- Holds information about a balance adjustment held in the temporary table.
   --
   l_bal_adjustment_rec csr_balance_adjustment%rowtype;
   --
   -- Indicates whether the balance adjustment contributes to the new balance.
   --
   l_include            boolean := FALSE;
   --
   -- The current value of the new balance as set by the balance adjustments.
   --
   l_current_value      number := 0;
   --
   -- The minimum expiry date of all the existing adjustments that effect the
   -- new balance.
   --
   l_min_expiry_date    date := p_batch_line_rec.upload_date;
   --
   -- Dynamic sql variables
   --
   sql_curs             number;
   rows_processed       integer;
   statem               varchar2(512);
   p_include            number;
   --
   l_jurisdiction_level number;

   cursor csr_adjustment_value
     (p_balance_type_id    in number
     ,p_expiry_date        in date
     ,p_upload_date        in date
     ,p_jurisdiction_level in number
     )  is
     select
       nvl(sum(BA.adjustment_amount), 0)
      ,nvl(min(BA.adjustment_date), p_upload_date)
     from  pay_temp_balance_adjustments BA
     where BA.balance_type_id = p_balance_type_id
       and BA.adjustment_date between p_expiry_date
                                  and p_upload_date
       and ((p_batch_line_rec.jurisdiction_code is null) or
            substr(p_batch_line_rec.jurisdiction_code, 1, p_jurisdiction_level)
             = substr(BA.jurisdiction_code, 1, p_jurisdiction_level))
       and nvl(p_batch_line_rec.tax_unit_id, nvl(BA.tax_unit_id, -1))
             = nvl(BA.tax_unit_id, -1)
       and nvl(p_batch_line_rec.original_entry_id, nvl(BA.original_entry_id, -1))
             = nvl(BA.original_entry_id, -1)
       and nvl(p_batch_line_rec.source_id, nvl(BA.source_id, -1))
             = nvl(BA.source_id, -1)
       and nvl(p_batch_line_rec.source_text, nvl(BA.source_text, '~nvl~'))
             = nvl(BA.source_text, '~nvl~')
       and nvl(p_batch_line_rec.run_type_id, nvl(BA.run_type_id, -1))
             = nvl(BA.run_type_id, -1)
       and nvl(p_batch_line_rec.source_number, nvl(BA.source_number, -1))
             = nvl(BA.source_number, -1)
       and nvl(p_batch_line_rec.source_text2, nvl(BA.source_text2, '~nvl~'))
             = nvl(BA.source_text2, '~nvl~')
       ;
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.get_current_value');
   --
   if p_glbl_data_rec.include_adj_rule = 'N' then
     --
     -- Generic calculation without include_adjustment.
     --
     l_jurisdiction_level
       := g_balances(p_batch_line_rec.balance_type_id).jurisdiction_level;

     open csr_adjustment_value
            (p_batch_line_rec.balance_type_id
            ,p_batch_line_rec.expiry_date
            ,p_batch_line_rec.upload_date
            ,l_jurisdiction_level
            );
     fetch csr_adjustment_value into l_current_value, l_min_expiry_date;
     close csr_adjustment_value;

   else
     --
     -- Localization specific calculation using include_adjustment.
     --
     open csr_balance_adjustment(p_batch_line_rec.balance_type_id
                                ,p_batch_line_rec.expiry_date
                                ,p_batch_line_rec.upload_date);
     --
     -- Loop for all the balance adjustments in the temporary table that are for
     -- the same balance as that being set and lie betwwen the expiry date of
     -- the new balance and the upload date.
     --
     loop
       --
       -- Get the next balance adjustment.
       --
       fetch csr_balance_adjustment into l_bal_adjustment_rec;
       exit  when csr_balance_adjustment%notfound;
       --
       -- See if the balance adjustment contributes to the value of the balance
       -- being set NB. this is dependent on the dimension of the new balance.
       --
       --
       -- If the dimension uses one of the International Payroll supported routes
       -- then process it NB. this could be for any legislation. All other dimensions
       -- for a given legislation will be processed in the relevant legislation specific
       -- package.
       --
       if pay_ip_bal_upload.international_payroll
           (p_batch_line_rec.dimension_name
           ,p_glbl_data_rec.legislation_code) then

         l_include := pay_ip_bal_upload.include_adjustment
                        (p_batch_line_rec.balance_type_id
                        ,p_batch_line_rec.dimension_name
                        ,p_batch_line_rec.original_entry_id
                        ,p_glbl_data_rec.upload_date
                        ,p_batch_line_rec.batch_line_id
                        ,l_bal_adjustment_rec.batch_line_id
                        ,p_glbl_data_rec.legislation_code);
       --
       -- UK dimensions.
       --
       elsif p_glbl_data_rec.legislation_code = 'GB' then
         l_include := pay_uk_bal_upload.include_adjustment
                        (p_batch_line_rec.balance_type_id
                        ,p_batch_line_rec.dimension_name
                        ,p_batch_line_rec.original_entry_id
                        ,l_bal_adjustment_rec);
       --
       -- US dimensions.
       --
       elsif p_glbl_data_rec.legislation_code = 'US' then
         l_include := pay_us_bal_upload.include_adjustment
                        (p_batch_line_rec.balance_type_id
                        ,p_batch_line_rec.dimension_name
                        ,p_batch_line_rec.jurisdiction_code
                        ,p_batch_line_rec.original_entry_id
                        ,p_batch_line_rec.tax_unit_id
                        ,p_batch_line_rec.assignment_id
                        ,p_glbl_data_rec.upload_date
                        ,l_bal_adjustment_rec);
       --
       -- JP dimensions.
       --
       elsif p_glbl_data_rec.legislation_code = 'JP' then
         l_include := pay_jp_bal_upload.include_adjustment
                        (p_batch_line_rec.balance_type_id
                        ,p_batch_line_rec.dimension_name
                        ,p_batch_line_rec.original_entry_id
                        ,l_bal_adjustment_rec);
       --
       -- CH dimensions.
       --
       elsif p_glbl_data_rec.legislation_code = 'CH' then
         l_include := pay_ch_bal_upload.include_adjustment
                        (p_batch_line_rec.balance_type_id
                        ,p_batch_line_rec.dimension_name
                        ,p_batch_line_rec.original_entry_id
                        ,l_bal_adjustment_rec);
       --
       -- BF dimensions.
       --
       elsif p_glbl_data_rec.legislation_code = 'BF' then
         l_include := pay_bf_bal_upload.include_adjustment
                        (p_batch_line_rec.balance_type_id
                        ,p_batch_line_rec.dimension_name
                        ,p_batch_line_rec.jurisdiction_code
                        ,p_batch_line_rec.original_entry_id
                        ,p_batch_line_rec.tax_unit_id
                        ,p_batch_line_rec.assignment_id
                        ,p_glbl_data_rec.upload_date
                        ,p_batch_line_rec.source_id
                        ,p_batch_line_rec.source_text
                        ,l_bal_adjustment_rec);
       else
         --
         -- Other Legislations dimensions.
         -- Note:  can't pass booleans or records in dynamic sql, so we pass
         -- in the batch_line_id (and thus the legislative packages have to
         -- fetch the line info themselves),  and the legislative packages should
         -- return a number with 0 denoting false, and 1 denoting true.
         --
         statem := 'BEGIN
         :p_include := pay_'||lower(p_glbl_data_rec.legislation_code)||'_bal_upload.include_adjustment
                        (:p_balance_type_id
                        ,:p_dimension_name
                        ,:p_original_entry_id
                        ,:p_upload_date
                        ,:p_batch_line_id
                        ,:p_test_batch_line_id); END;';
         --
         execute immediate statem
           using out p_include
                ,p_batch_line_rec.balance_type_id
                ,p_batch_line_rec.dimension_name
                ,p_batch_line_rec.original_entry_id
                ,p_glbl_data_rec.upload_date
                ,p_batch_line_rec.batch_line_id
                ,l_bal_adjustment_rec.batch_line_id
                ;
         --
         if p_include = 0 then
            l_include := FALSE;
         else
            l_include := TRUE;
         end if;
         --
       end if;
       --
       -- The balance adjustment contributes to the new balance so add to the
       -- running total. Also keep track of the earliest expiry date of the
       -- balance adjustments.
       --
       if l_include then
         hr_utility.set_location('pay_balance_upload.get_current_value',10);
         l_current_value   :=
  	 l_current_value + l_bal_adjustment_rec.adjustment_amount;
         l_min_expiry_date :=
           least(l_min_expiry_date, l_bal_adjustment_rec.expiry_date);
       end if;
       --
     end loop;
     --
     close csr_balance_adjustment;
     --
   end if;
   --
   -- Return the current value.
   --
   p_current_value   := l_current_value;
   p_min_expiry_date := l_min_expiry_date;
   --
   hr_utility.trace('Current Value = '|| l_current_value);
   hr_utility.trace('Exiting pay_balance_upload.get_current_value');
   --
 end get_current_value;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  calculate_adjustment
  -- PURPOSE
  --  Calculates the balance adjustment required to set a balance to a
  --  particular value. It takes into account previous balance adjustments
  --  which may also contribute to the balance.
  -- ARGUMENTS
  --  p_glbl_data_rec   - global data structure.
  --  p_batch_line_rec  - the current batch line
  -- USES
  --  get_current_value
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure calculate_adjustment
 (
  p_glbl_data_rec   in     glbl_data_rec_type
 ,p_batch_line_rec  in     csr_batch_line_transfer%rowtype
 ) is
   --
   -- Retrieves the payroll the assignment is on at a particular time.
   --
   cursor csr_payroll
     (
      p_assignment_id  number
     ,p_effective_date date
     ) is
     select ASS.payroll_id
     from   per_all_assignments_f ASS
     where  ASS.assignment_id = p_assignment_id
       and  p_effective_date    between ASS.effective_start_date
				    and ASS.effective_end_date;
   --
   -- Holds the payroll the assignment is on.
   --
   l_payroll_id        number;
   --
   -- Holds the expiry date of the dimension.
   --
   l_expiry_date       date;
   --
   -- Holds the current value of a balance as set by the planned balance
   -- adjustments.
   --
   l_curr_value        number := 0;
   l_min_expiry_date   date;
   --
   -- Holds the amount and date of the adjustment required to set the balance
   -- to the correct value.
   --
   l_adjustment_amount number;
   l_adjustment_date   date;
   --
   -- Holds the tax unit
   --
   l_tax_unit_id       number;
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.calculate_adjustment');
   --
   -- Retrieve the current value for the initial balance as set by previous
   -- balance adjustments calculated for the assignment.
   --
   get_current_value(p_glbl_data_rec
                    ,p_batch_line_rec
                    ,l_curr_value
                    ,l_min_expiry_date);
   --
   -- Calculate the amount required to set the balance to it's initial value
   -- ie. the difference between what the value should be and the value it
   -- currently is (according to the existing balance adjustments).
   --
   l_adjustment_amount := p_batch_line_rec.value - l_curr_value;
   --
   -- The balance adjustment is to be done on the expiry date of the dimension
   -- being set NB. the advantage of this is that it reduces the chances of
   -- the adjustment affecting other dimensions inadvertently and it also
   -- ensures that the dimension criteria is met ie. the assignment belongs to
   -- the correct tax unit, etc...
   --
   l_adjustment_date := p_batch_line_rec.expiry_date;
   --
   -- Ensure that the proposed balance adjustment is valid.
   --
   -- The expiry date could not be derived successfully NB. this is signified
   -- by an expiry date of the end of time.
   --
   hr_utility.trace(p_batch_line_rec.dimension_name||' '||
                   p_batch_line_rec.jurisdiction_code||' '||
                   p_batch_line_rec.gre_name);
   hr_utility.trace('Adjustment Date '||l_adjustment_date);
   hr_utility.trace('Adjustment Value '|| l_adjustment_amount);
   hr_utility.trace('Adjustment Run Type '|| p_batch_line_rec.run_type_id);

   if    nvl(l_adjustment_date, END_OF_TIME) = END_OF_TIME
      or l_adjustment_date > p_batch_line_rec.upload_date  then

     hr_utility.set_message(801, 'HR_7030_ELE_ENTRY_INV_ADJ');
     hr_utility.set_message_token('ADJ_DATE', l_adjustment_date);
     raise hr_utility.hr_error;
--     null;  -- need to set up message and raise hr_utility.hr_error.
   end if;
   --
   -- Amount cannot be set as the current value is greater than the amount to
   -- be set eg. QTD was 2000.00 while the YTD was 1500.00.
   --
   -- Negative ajustments of balances are valid.
/*
   if l_adjustment_amount < 0 then
     hr_utility.set_message(801, 'HR_7030_ELE_ENTRY_INV_ADJ');
     raise hr_utility.hr_error;
--     null;  -- need to set up message and raise hr_utility.hr_error.
   end if;
*/
   --
   -- Assignment is not to a payroll on the adjustment date NB. an optimisation
   -- here would be to cache the previously tested date for the assignment and
   -- then only carry out the test if the date was different.
   --
   l_payroll_id := null;
   open  csr_payroll(p_glbl_data_rec.assignment_id
		    ,l_adjustment_date);
   fetch csr_payroll into l_payroll_id;
   close csr_payroll;
   if l_payroll_id is null then
     hr_utility.set_message(801, 'HR_7789_SETUP_ASG_HAS_NO_PAYR');
     hr_utility.set_message_token('ADJ_DATE', l_adjustment_date);
     raise hr_utility.hr_error;
--     null;  -- need to set up message and raise hr_utility.hr_error.
   end if;
   --
   -- In the US, each assignment always belongs to a legal company. If the
   -- legal compamy was not specified as a context then get the legal comapny
   -- the assignment belongs to as of the adjustment date. This could be used
   -- when calculating the current value for a new balance.
   --
   l_tax_unit_id := p_batch_line_rec.tax_unit_id;
   if (l_tax_unit_id is null) then
--
      l_tax_unit_id := hr_dynsql.get_tax_unit(
                             p_batch_line_rec.assignment_id,
                             l_adjustment_date);
--
/*    NBR no need to do this anymore need to call the
      core package.
      if p_glbl_data_rec.legislation_code = 'US'  then
        l_tax_unit_id := pay_us_bal_upload.get_tax_unit
                                     (p_batch_line_rec.assignment_id
                                     ,l_adjustment_date);
      end if;
      -- As US
      if p_glbl_data_rec.legislation_code = 'BF'  then
        l_tax_unit_id := pay_bf_bal_upload.get_tax_unit
     				     (p_batch_line_rec.assignment_id
     				     ,l_adjustment_date);
      end if;
*/
   end if;
   --
   -- Add new balance adjustment to the list NB. if the existing balance
   -- adjustments already add up to the correct amount for the initial balance
   -- then do not create a new balance adjustment.
   --
      insert into pay_temp_balance_adjustments
      (batch_line_id
      ,balance_type_id
      ,balance_dimension_id
      ,expiry_date
      ,element_link_id
      ,ibf_input_value_id
      ,jc_input_value_id
      ,adjustment_date
      ,adjustment_amount
      ,tax_unit_id
      ,jurisdiction_code
      ,source_id
      ,source_text
      ,source_number
      ,source_text2
      ,run_type_id
      ,original_entry_id)
      values
      (p_batch_line_rec.batch_line_id
      ,p_batch_line_rec.balance_type_id
      ,p_batch_line_rec.balance_dimension_id
      ,p_batch_line_rec.expiry_date
      ,g_balances(p_batch_line_rec.balance_type_id).element_link_id
      ,g_balances(p_batch_line_rec.balance_type_id).ibf_input_value_id
      ,g_balances(p_batch_line_rec.balance_type_id).jc_input_value_id
      ,l_adjustment_date
      ,l_adjustment_amount
      ,l_tax_unit_id
      ,p_batch_line_rec.jurisdiction_code
      ,p_batch_line_rec.source_id
      ,p_batch_line_rec.source_text
      ,p_batch_line_rec.source_number
      ,p_batch_line_rec.source_text2
      ,p_batch_line_rec.run_type_id
      ,p_batch_line_rec.original_entry_id);
   --
   hr_utility.trace('Exiting pay_balance_upload.calculate_adjustment');
   --
 end calculate_adjustment;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  load_element_contexts
  -- PURPOSE
  -- This procedure loads details of the element types context usage.
  -- ARGUMENTS
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure load_element_contexts(p_element_link_id in number,
                                 p_start_ptr          out nocopy number,
                                 p_end_ptr            out nocopy number
                                )
 is
    l_iv_id pay_input_values_f.input_value_id%type;
    l_start_ptr number;
    l_ptr number;
 begin
--
   hr_utility.trace('Entering load_element_contexts');
--
   p_start_ptr:= null;
   p_end_ptr := null;
--
   if (g_element_link_contexts.exists(p_element_link_id)) then
--
     p_start_ptr := g_element_link_contexts(p_element_link_id).start_ptr;
     p_end_ptr := g_element_link_contexts(p_element_link_id).end_ptr;
--
   else
--
      -- Initialise variables.
--
      g_element_link_contexts(p_element_link_id).start_ptr := p_start_ptr;
      g_element_link_contexts(p_element_link_id).end_ptr := p_end_ptr;
      l_start_ptr := g_input_val_contexts.count + 1;
--
      for i in 1..g_legislation_contexts.count loop
--
        if (g_legislation_contexts(i).input_value_name is not null) then
--
          -- OK does this element have this legislation context
          begin
            select piv.input_value_id
              into l_iv_id
              from pay_input_values_f piv,
                   pay_element_links_f pel
             where pel.element_link_id= p_element_link_id
               and pel.element_type_id = piv.element_type_id
               and piv.name = g_legislation_contexts(i).input_value_name
               and piv.effective_start_date = START_OF_TIME
               and piv.effective_end_date   = END_OF_TIME
               and pel.effective_start_date = START_OF_TIME
               and pel.effective_end_date   = END_OF_TIME;
--
             l_ptr := g_input_val_contexts.count + 1;
             g_input_val_contexts(l_ptr).context_name := g_legislation_contexts(i).context_name;
             g_input_val_contexts(l_ptr).input_value_id := l_iv_id;
             g_element_link_contexts(p_element_link_id).start_ptr := l_start_ptr;
             g_element_link_contexts(p_element_link_id).end_ptr := g_input_val_contexts.count;
--
          exception
             when no_data_found then
                 null;
          end ;
--
        end if;
--
      end loop;
--
      p_start_ptr := g_element_link_contexts(p_element_link_id).start_ptr;
      p_end_ptr := g_element_link_contexts(p_element_link_id).end_ptr;
--
   end if;
--
   hr_utility.trace('Exitting load_element_contexts');
--
 end load_element_contexts;
--

  -----------------------------------------------------------------------------
  -- NAME
  --  set_entry_context
  -- PURPOSE
  -- This procedure sets a specific context for an entry.
  -- ARGUMENTS
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure set_entry_context
 (
   p_element_link_id    in            number,
   p_context_name       in            varchar2,
   p_context_value      in            varchar2,
   p_num_entry_values   in out nocopy number,
   p_input_value_id_tbl in out nocopy hr_entry.number_table,
   p_entry_value_tbl    in out nocopy hr_entry.varchar2_table
 )
is
--
 l_start_ptr number;
 l_end_ptr   number;
 l_iv_id     pay_input_values_f.input_value_id%type;
 cnt         number;
 found       boolean;
--
begin
--
  hr_utility.trace('Entering set_entry_context');
--
  load_element_contexts(p_element_link_id,
                        l_start_ptr,
                        l_end_ptr
                       );
--
  -- Need to get the input value to use.
--
  l_iv_id := null;
--
  -- Only need to do something if the element has contexts.
--
  if (l_start_ptr is not null) then
    for i in l_start_ptr..l_end_ptr loop
--
      if (p_context_name = g_input_val_contexts(i).context_name) then
--
        l_iv_id := g_input_val_contexts(i).input_value_id;
--
      end if;
--
    end loop;
--
    -- Now set the entry value.
--
    if (l_iv_id is not null) then
--
      found := FALSE;
      for cnt in 1..p_num_entry_values loop
--
        if (l_iv_id = p_input_value_id_tbl(cnt)) then
          found := TRUE;
          exit;
        end if;
--
      end loop;
--
      -- Only set the context if needed.
--
      if (found = FALSE) then
--
       p_num_entry_values := p_num_entry_values + 1;
       p_input_value_id_tbl(p_num_entry_values) := l_iv_id;
       p_entry_value_tbl(p_num_entry_values)    := p_context_value;
--
      end if;
--
    end if;
  end if;
--
  hr_utility.trace('Exitting set_entry_context');
--
end set_entry_context;
  -----------------------------------------------------------------------------
  -- NAME
  --  create_entry_values
  -- PURPOSE
  -- This procedure creates the appropreate entry values for an adjustment.
  -- It ensures that the contexts for the entry are set correctly
  -- ARGUMENTS
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure create_entry_values
 (
   p_element_link_id    in            number,
   p_jurisdiction_code  in            varchar2,
   p_source_id          in            number,
   p_source_text        in            varchar2,
   p_source_number      in            number,
   p_source_text2       in            varchar2,
   p_adj_amount         in            number,
   p_adj_iv_id          in            number,
   p_num_entry_values   in out nocopy number,
   p_input_value_id_tbl in out nocopy hr_entry.number_table,
   p_entry_value_tbl    in out nocopy hr_entry.varchar2_table
 )
 is
begin
--
   hr_utility.trace('Entering create_entry_values');
   -- OK setup the contexts
--
   if (p_jurisdiction_code is not null) then
     set_entry_context(
                       p_element_link_id,
                       'JURISDICTION_CODE',
                       p_jurisdiction_code,
                       p_num_entry_values,
                       p_input_value_id_tbl,
                       p_entry_value_tbl
                      );
   end if;
   if (p_source_id is not null) then
     set_entry_context(
                       p_element_link_id,
                       'SOURCE_ID',
                       to_char(p_source_id),
                       p_num_entry_values,
                       p_input_value_id_tbl,
                       p_entry_value_tbl
                      );
   end if;
   if (p_source_text is not null) then
     set_entry_context(
                       p_element_link_id,
                       'SOURCE_TEXT',
                       p_source_text,
                       p_num_entry_values,
                       p_input_value_id_tbl,
                       p_entry_value_tbl
                      );
   end if;
   if (p_source_number is not null) then
     set_entry_context(
                       p_element_link_id,
                       'SOURCE_NUMBER',
                       to_char(p_source_number),
                       p_num_entry_values,
                       p_input_value_id_tbl,
                       p_entry_value_tbl
                      );
   end if;
   if (p_source_text2 is not null) then
     set_entry_context(
                       p_element_link_id,
                       'SOURCE_TEXT2',
                       p_source_text2,
                       p_num_entry_values,
                       p_input_value_id_tbl,
                       p_entry_value_tbl
                      );
   end if;
--
   -- Now set the value
   p_num_entry_values := p_num_entry_values + 1;
   p_input_value_id_tbl(p_num_entry_values) := p_adj_iv_id;
   p_entry_value_tbl(p_num_entry_values)    := to_char(p_adj_amount);
--
   hr_utility.trace('Exitting create_entry_values');
--
end create_entry_values;
  -----------------------------------------------------------------------------
  -- NAME
  --  apply_adjustments
  -- PURPOSE
  --  Applies the list of balance adjustments held in the temporary table. The
  --  balance adjustments are combined where possible to reduce the number of
  --  balance adjustments to be made ie. if 2 adjustments use the same entry
  --  and they have to be done on the same day then they can share an
  --  adjustment.
  -- ARGUMENTS
  --  p_glbl_data_rec   - global data structure.
  --  p_batch_line_list - the list of batch lines currently being processed
  --  p_num_lines       - the number of batch lines in the list.
  --  p_message         - the error message.
  -- USES
  --  pay_bal_adjust.init_batch
  --  pay_bal_adjust.adjust_balance
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure apply_adjustments
 (
  p_glbl_data_rec   in            glbl_data_rec_type
 ,p_batch_line_list in out nocopy number_array
 ,p_num_lines       in out nocopy number
 ) is
   --
   -- Retrieves the balance adjustments held in the temporary table.
   --
   -- Bug 4872523. Retrieving payroll id for the adjustment date.
   -- Note the assignment has already been checked in calculate_adjustment.
   --
   cursor csr_bal_adj is
     select TBA.*
           ,ASG.payroll_id
     from   pay_temp_balance_adjustments TBA
           ,per_all_assignments_f        ASG
     where
         ASG.assignment_id = p_glbl_data_rec.assignment_id
     and TBA.adjustment_date between ASG.effective_start_date
                                 and ASG.effective_end_date
     order  by TBA.element_link_id
	      ,TBA.adjustment_date
	      ,TBA.jurisdiction_code
              ,TBA.original_entry_id
              ,TBA.tax_unit_id
              ,TBA.source_id
              ,TBA.source_text
              ,TBA.source_number
              ,TBA.source_text2
              ,TBA.run_type_id
              ,TBA.balance_type_id;
   --
   -- Holds information about a balance adjustment.
   --
   l_bal_adj_rec        csr_bal_adj%rowtype;
   --
   -- Strutures to hold the values of element entry values to be used when
   -- creating an element entry.
   --
   l_num_entry_values   number := 0;
   l_input_value_id_tbl hr_entry.number_table;
   l_entry_value_tbl    hr_entry.varchar2_table;
   --
   -- Holds information about the balance adjustment.
   --
   l_ele_link_id        number;
   l_bal_type_id        number;
   l_tax_unit_id        number;
   l_oee_id             number;
   l_source_id          number;
   l_run_type_id        number;
   l_source_text        pay_balance_batch_lines.source_text%type;
   l_source_number      pay_balance_batch_lines.source_number%type;
   l_source_text2       pay_balance_batch_lines.source_text2%type;
   l_adj_date           date;
   l_jurisdiction_code  varchar2(30);
   l_payroll_id         number;
   --
   -- Holds the payroll action used by the latest balance adjustment for an
   -- assignment.
   --
   l_payroll_action_id  number;
   l_payroll_action_rec g_payroll_action_rec_type;
   --
   l_idx                binary_integer;
   l_batch_mode         varchar2(30):= 'STANDARD';
   --
   -- Dummy constants for handling null conditions.
   --
   c_number      constant number       := -987456321;
   c_varchar2    constant varchar2(10) := '~nvl~';
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.apply_adjustments');
   --
   open csr_bal_adj;
   --
   -- Get the first balance adjustment.
   --
   fetch csr_bal_adj into l_bal_adj_rec;
   --
   -- At least one balance adjustment exists.
   --
   hr_utility.set_location('pay_balance_upload.apply_adjustments', 10);
   if csr_bal_adj%found then
     --
     -- Keep track of balance adjustment information.
     --
     hr_utility.trace('Adding to the Adjustment List');
     hr_utility.trace(' Line Id '|| l_bal_adj_rec.batch_line_id);
     hr_utility.trace(' Ele Lnk '|| l_bal_adj_rec.element_link_id);
     hr_utility.trace(' OEE Id '|| l_bal_adj_rec.original_entry_id);
     hr_utility.trace(' Bal Type '|| l_bal_adj_rec.balance_type_id);
     hr_utility.trace(' Adj Date '|| l_bal_adj_rec.adjustment_date);
     hr_utility.trace(' Jur Code '|| l_bal_adj_rec.jurisdiction_code);
     hr_utility.trace(' Tax Unit '|| l_bal_adj_rec.tax_unit_id);
     hr_utility.trace(' Source ID '|| l_bal_adj_rec.source_id);
     hr_utility.trace(' Source Text '|| l_bal_adj_rec.source_text);
     hr_utility.trace(' Source Number '|| l_bal_adj_rec.source_number);
     hr_utility.trace(' Source Text2 '|| l_bal_adj_rec.source_text2);
     hr_utility.trace(' Run Type ID '|| l_bal_adj_rec.run_type_id);
     hr_utility.trace(' IV ID '|| l_bal_adj_rec.ibf_input_value_id);
     hr_utility.trace(' JIV ID '|| l_bal_adj_rec.jc_input_value_id);
     l_ele_link_id       := l_bal_adj_rec.element_link_id;
     l_oee_id            := l_bal_adj_rec.original_entry_id;
     l_bal_type_id       := l_bal_adj_rec.balance_type_id;
     l_adj_date          := l_bal_adj_rec.adjustment_date;
     l_jurisdiction_code := l_bal_adj_rec.jurisdiction_code;
     l_tax_unit_id       := l_bal_adj_rec.tax_unit_id;
     l_source_id         := l_bal_adj_rec.source_id;
     l_source_text       := l_bal_adj_rec.source_text;
     l_source_number     := l_bal_adj_rec.source_number;
     l_source_text2      := l_bal_adj_rec.source_text2;
     l_run_type_id       := l_bal_adj_rec.run_type_id;
     l_payroll_id        := l_bal_adj_rec.payroll_id;
     --
     -- Initialise batch line structure.
     --
     p_num_lines                    := 1;
     p_batch_line_list(p_num_lines) := l_bal_adj_rec.batch_line_id;
     --
     hr_utility.set_location('pay_balance_upload.apply_adjustments', 15);
     -- Add to the list of entry values to be used with the next balance
     -- adjustment.
     --
     create_entry_values (
                          l_ele_link_id,
                          l_jurisdiction_code,
                          l_source_id,
                          l_source_text,
                          l_source_number,
                          l_source_text2,
                          l_bal_adj_rec.adjustment_amount,
                          l_bal_adj_rec.ibf_input_value_id,
                          l_num_entry_values,
                          l_input_value_id_tbl,
                          l_entry_value_tbl
                         );
     --
     -- Loop for all the balance adjustments in the list.
     --
     hr_utility.set_location('pay_balance_upload.apply_adjustments', 20);
     loop
       hr_utility.set_location('pay_balance_upload.apply_adjustments', 30);
       --
       -- Get the next balance adjustment.
       --
       fetch csr_bal_adj into l_bal_adj_rec;
       --
       -- The new balance adjustment cannot be shared with the previous
       -- adjustment so apply the previous adjustment. The rules for sharing
       -- are as follows :-
       --
       -- 1. must use the same element link and therefore the same element type.
       -- 2. adjustment is on the same day.
       -- 3. if both are dependent on context values then they must be the
       --    same as only one combination can be set for each adjustment.
       -- 4. each balance can only be set once per adjustment.
       --
       if not (    l_bal_adj_rec.element_link_id  = l_ele_link_id
               and l_bal_adj_rec.adjustment_date  = l_adj_date
               -- check context values
               and nvl(l_bal_adj_rec.original_entry_id, c_number)
                 = nvl(l_oee_id, c_number)
               and nvl(l_bal_adj_rec.jurisdiction_code, c_varchar2)
                 = nvl(l_jurisdiction_code, c_varchar2)
               and nvl(l_bal_adj_rec.tax_unit_id, c_number)
                 = nvl(l_tax_unit_id, c_number)
               and nvl(l_bal_adj_rec.run_type_id, c_number)
                 = nvl(l_run_type_id, c_number)
               and nvl(l_bal_adj_rec.source_id, c_number)
                 = nvl(l_source_id, c_number)
               and nvl(l_bal_adj_rec.source_text, c_varchar2)
                 = nvl(l_source_text, c_varchar2)
               and nvl(l_bal_adj_rec.source_number, c_number)
                 = nvl(l_source_number, c_number)
               and nvl(l_bal_adj_rec.source_text2, c_varchar2)
                 = nvl(l_source_text2, c_varchar2)
               --
               and l_bal_adj_rec.balance_type_id <> l_bal_type_id
              )
          or csr_bal_adj%notfound then
         --
         hr_utility.set_location('pay_balance_upload.apply_adjustments', 40);

         l_payroll_action_id := null;
         --
         -- Firstly see if the last payroll action is available.
         --
         if l_payroll_action_rec.effective_date = l_adj_date   and
            l_payroll_action_rec.payroll_id     = l_payroll_id then
           --
           -- The previous payroll action is available.
           --
           l_payroll_action_id := l_payroll_action_rec.payroll_action_id;
         else

           --
           -- Check to see if the payroll action is already prepared.
           --
           l_payroll_action_id := null;
           <<payroll_action_search_loop>>
           for l_idx in 1..g_payroll_actions.count loop

             if g_payroll_actions(l_idx).effective_date = l_adj_date   and
                g_payroll_actions(l_idx).payroll_id     = l_payroll_id then

               l_payroll_action_rec := g_payroll_actions(l_idx);
               l_payroll_action_id := l_payroll_action_rec.payroll_action_id;
               exit payroll_action_search_loop;

             end if;

           end loop;

         end if;

         --
         -- If the payroll action does not exist in cache, then prepare a
         -- new payroll action id.
         --
         if l_payroll_action_id is null then

           --
           if p_glbl_data_rec.purge_mode then
             l_batch_mode := 'NO_COMMIT';
           else
             l_batch_mode := 'STANDARD';
           end if;
           --

           l_payroll_action_id :=
             pay_bal_adjust.init_batch
               (p_batch_name           => NULL
               ,p_effective_date       => l_adj_date
               ,p_consolidation_set_id => p_glbl_data_rec.consolidation_set_id
               ,p_payroll_id           => l_payroll_id
               ,p_action_type          => 'I'
               ,p_batch_mode           => l_batch_mode
               ,p_prepay_flag          => null
               );

           l_idx := g_payroll_actions.count + 1;

           hr_utility.trace('Adding new payroll action information to cache.');
           hr_utility.trace('  payroll_action_id = '|| l_payroll_action_id);
           hr_utility.trace('  effective_date    = '|| l_adj_date);
           hr_utility.trace('  payroll_id        = '|| l_payroll_id);

           l_payroll_action_rec.payroll_action_id := l_payroll_action_id;
           l_payroll_action_rec.effective_date    := l_adj_date;
           l_payroll_action_rec.payroll_id        := l_payroll_id;

           g_payroll_actions(l_idx) := l_payroll_action_rec;

         end if;

         --
         -- Create the balance adjustment.
         --   Changed from create_adjustment to pay_bal_adjust.adjust_balance
         --   to perform batch adjustment for the batch.
         --
         pay_bal_adjust.adjust_balance
           (p_batch_id                   => l_payroll_action_id
           ,p_assignment_id              => p_glbl_data_rec.assignment_id
           ,p_element_link_id            => l_ele_link_id
           ,p_num_entry_values           => l_num_entry_values
           ,p_input_value_id_tbl         => l_input_value_id_tbl
           ,p_entry_value_tbl            => l_entry_value_tbl
           ,p_run_type_id                => l_run_type_id
           ,p_original_entry_id          => l_oee_id
           ,p_tax_unit_id                => l_tax_unit_id
           ,p_purge_mode                 => p_glbl_data_rec.purge_mode
           );

         --
         -- Mark the batch lines that have just been transferred with a status
	 -- of 'T'ransferred. Also set the payroll_action_id to that used by
	 -- the balance adjustment. This ensures that the balance adjustment
	 -- used to set each initial balance is held against the corresponding
	 -- batch line.
         --
	 for l_index in 1..p_num_lines loop
           hr_utility.trace('Updating Line '||p_batch_line_list(l_index)||
                            ' With Payroll Action '||l_payroll_action_id);
           update pay_balance_batch_lines BL
	   set    BL.batch_line_status = 'T'  -- Transferred
		 ,BL.payroll_action_id = l_payroll_action_id
	   where  BL.batch_line_id     = p_batch_line_list(l_index);
	 end loop;
         --
         -- Reset in preparation for a new set of balance adjustments.
         --
	 l_num_entry_values := 0;
         p_num_lines        := 0;
         --
       end if;
       --
       -- Stop when there are no more balance adjustments.
       --
       exit when csr_bal_adj%notfound;
       --
       -- Keep track of balance adjustment information.
       --
       hr_utility.trace('Adding to the Adjustment List');
       hr_utility.trace(' Line Id '|| l_bal_adj_rec.batch_line_id);
       hr_utility.trace(' Ele Lnk '|| l_bal_adj_rec.element_link_id);
       hr_utility.trace(' OEE Id '|| l_bal_adj_rec.original_entry_id);
       hr_utility.trace(' Bal Type '|| l_bal_adj_rec.balance_type_id);
       hr_utility.trace(' Adj Date '|| l_bal_adj_rec.adjustment_date);
       hr_utility.trace(' Jur Code '|| l_bal_adj_rec.jurisdiction_code);
       hr_utility.trace(' Tax Unit '|| l_bal_adj_rec.tax_unit_id);
       hr_utility.trace(' Source ID '|| l_bal_adj_rec.source_id);
       hr_utility.trace(' Source Text '|| l_bal_adj_rec.source_text);
       hr_utility.trace(' Run Type ID '|| l_bal_adj_rec.run_type_id);
       hr_utility.trace(' IV ID '|| l_bal_adj_rec.ibf_input_value_id);
       hr_utility.trace(' JIV ID '|| l_bal_adj_rec.jc_input_value_id);
       l_ele_link_id       := l_bal_adj_rec.element_link_id;
       l_oee_id            := l_bal_adj_rec.original_entry_id;
       l_bal_type_id       := l_bal_adj_rec.balance_type_id;
       l_adj_date          := l_bal_adj_rec.adjustment_date;
       l_jurisdiction_code := l_bal_adj_rec.jurisdiction_code;
       l_tax_unit_id       := l_bal_adj_rec.tax_unit_id;
       l_source_id       := l_bal_adj_rec.source_id;
       l_source_text     := l_bal_adj_rec.source_text;
       l_source_number   := l_bal_adj_rec.source_number;
       l_source_text2    := l_bal_adj_rec.source_text2;
       l_run_type_id     := l_bal_adj_rec.run_type_id;
       l_payroll_id      := l_bal_adj_rec.payroll_id;
       --
       -- Add batch line to the list of batch lines currently being processed.
       --
       p_num_lines                    := p_num_lines + 1;
       p_batch_line_list(p_num_lines) := l_bal_adj_rec.batch_line_id;
       --
       -- Add to the list of entry values to be used with the next balance
       -- adjustment.
       --
       create_entry_values (
                            l_ele_link_id,
                            l_jurisdiction_code,
                            l_source_id,
                            l_source_text,
                            l_source_number,
                            l_source_text2,
                            l_bal_adj_rec.adjustment_amount,
                            l_bal_adj_rec.ibf_input_value_id,
                            l_num_entry_values,
                            l_input_value_id_tbl,
                            l_entry_value_tbl
                           );
       --
     end loop;
   hr_utility.set_location('pay_balance_upload.apply_adjustments', 50);
   --
   end if;
   --
   close csr_bal_adj;
   --
   hr_utility.trace('Exiting pay_balance_upload.apply_adjustments');
 --
 -- Trap any exceptions, put the error message into the message
 -- variable and raise an internal exception to indicate that there
 -- has been a failure. Close any open cursors.
 --
 exception
   when others then
     --
     -- Close the cursor if it is open.
     --
     if csr_bal_adj%isopen then
       close csr_bal_adj;
     end if;
     --
     -- reraise the exception to be caught at a higer level.
     --
     raise;
     --
 end apply_adjustments;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  cache_balances
  -- PURPOSE
  --  Caches initial balance feed information for each balance in a batch.
  -- ARGUMENTS
  -- USES
  -- NOTES
  --  The information is held in PLSQL tables indexed by the balance_type_id
  --  for fast access.
  -----------------------------------------------------------------------------
 --
procedure cache_balances
 is
   --
   -- Record to hold initial balance feed information.
   --
   l_bal_id    number;
   l_idx       number;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.cache_balances');
   --
   -- Clear the balance cache.
   --
   g_balances.delete;

   --
   -- Copy valid balance info from the validation cache.
   --
   for l_idx in 1..g_bal_vald.count loop

     --
     if (not g_bal_vald(l_idx).bal_invld)     and
        (not g_bal_vald(l_idx).bal_invl_feed) and
        (not g_bal_vald(l_idx).bal_invl_link) then
        --
        l_bal_id := g_bal_vald(l_idx).balance_type_id;
        --
        g_balances(l_bal_id).element_link_id    := g_bal_vald(l_idx).element_link_id;
        g_balances(l_bal_id).ibf_input_value_id := g_bal_vald(l_idx).ibf_input_value_id;
        g_balances(l_bal_id).jc_input_value_id  := g_bal_vald(l_idx).jc_input_value_id;
        g_balances(l_bal_id).jurisdiction_level := g_bal_vald(l_idx).jurisdiction_level;
     end if;
     --
   end loop;
   --
   hr_utility.trace('Exiting pay_balance_upload.cache_balances');
   --
 end cache_balances;
 --
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  lock_batch
  -- PURPOSE
  --  Places an exclusive row lock on the batch header.
  -- ARGUMENTS
  --  p_mode          - the mode the process is running in ie. PURGE, VALLIDATE
  --                    or TRANSFER.
  --  p_batch_id      - identifies the batch being processed.
  --  p_glbl_data_rec - global data structure.
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure lock_batch
 (
  p_mode          in            varchar2
 ,p_batch_id      in            number
 ,p_glbl_data_rec in out nocopy glbl_data_rec_type
 ) is
   --
   -- Locks the batch.
   --
   cursor csr_lock_batch
     (
      p_batch_id number
     )  is
     select BBH.batch_id
           ,trunc(BBH.upload_date) upload_date
     from   pay_balance_batch_headers BBH
     where  BBH.batch_id = p_batch_id
     for update nowait;
   --
   -- Retrieves the commit unit size held as an action parameter.
   --
   cursor csr_chunk_size is
     select fnd_number.canonical_to_number(AP.parameter_value)
     from   pay_action_parameters AP
     where  AP.parameter_name = 'CHUNK_SIZE';
   --
   -- Holds the batch_id of the locked batch.
   --
   l_batch_rec  csr_lock_batch%rowtype;
   --
   -- Holds the size of each commit unit NB. this is measured in assignments.
   --
   l_chunk_size number;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.lock_batch');
   --
   -- Lock the batch.
   --
   open  csr_lock_batch(p_batch_id);
   fetch csr_lock_batch into l_batch_rec;
   close csr_lock_batch;
   --
   -- Fetch the commit unit.
   --
   open  csr_chunk_size;
   fetch csr_chunk_size into l_chunk_size;
   if csr_chunk_size%notfound then
     l_chunk_size := CHUNK_SIZE;
   end if;
   close csr_chunk_size;
   --
   -- Set batch_status of batch header to 'L' to lock it.
   -- This is used to stop other threads attempting to process this batch.
   --
   update pay_balance_batch_headers BBH
   set   BBH.batch_status = 'L'
   where BBH.batch_id = p_batch_id;
   --
   -- Initialise the global data structure.
   --
   -- There is a 'special' mode that is set when calling balance upload
   -- from Purge.  This simply sets a purge_mode to be FALSE to prevent
   -- the upload process from performing commits.
   -- Otherwise, commits are allowed.
   p_glbl_data_rec.upload_mode := upper(p_mode);
   p_glbl_data_rec.purge_mode  := FALSE;  -- Default to allowing commit.
   --
   if p_glbl_data_rec.upload_mode = 'BALANCE_ROLLUP' then
     p_glbl_data_rec.upload_mode := 'TRANSFER';  -- Now perform a transfer.
     p_glbl_data_rec.purge_mode  := TRUE;
   end if;
   --
   p_glbl_data_rec.batch_id    := l_batch_rec.batch_id;
   p_glbl_data_rec.upload_date := l_batch_rec.upload_date;
   p_glbl_data_rec.chunk_size  := l_chunk_size;
   --
   hr_utility.trace('Exiting pay_balance_upload.lock_batch');
   --
 end lock_batch;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  set_batch_status
  -- PURPOSE
  --  Sets the batch status based on the status of the batch lines.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure set_batch_status
 (
  p_glbl_data_rec in glbl_data_rec_type
 ) is
   --
   -- Retrieves the statuses of the batch lines for a batch
   --
   cursor csr_status
     (
      p_batch_id number
     )  is
     select distinct nvl(BL.batch_line_status, 'U')
     from   pay_balance_batch_lines BL
     where  BL.batch_id = p_batch_id
     order  by decode(nvl(BL.batch_line_status, 'U'), 'U', 1
			                            , 'T', 2
			                            , 'E', 3
			                            , 'V', 4);
   --
   -- The status of a batch line.
   --
   l_status      varchar2(30);
   --
   -- Indicators identifying which statuses are used.
   --
   l_unprocessed boolean := FALSE;
   l_transferred boolean := FALSE;
   l_error       boolean := FALSE;
   l_valid       boolean := FALSE;
   --
   -- Indicates that only one status was used by all the batch lines.
   --
   l_one_status  boolean := FALSE;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.set_batch_status');
   --
   open  csr_status(p_glbl_data_rec.batch_id);
   --
   -- Loop for all the differnent statuses for the batch lines within a natch.
   --
   loop
     --
     -- Get the next status.
     --
     fetch csr_status into l_status;
     exit  when csr_status%notfound;
     --
     -- Set an indicator for each status found.
     --
     if    l_status = 'U' then
       l_unprocessed := TRUE;
     elsif l_status = 'T' then
       l_transferred := TRUE;
     elsif l_status = 'E' then
       l_error       := TRUE;
     elsif l_status = 'V' then
       l_valid       := TRUE;
     end if;
     --
   end loop;
   --
   -- Was only one status found ?
   --
   l_one_status := (csr_status%rowcount = 1);
   --
   --
   -- Only one status for all the batch lines so the batch status is the same
   -- NB. l_status will contain the status selected from the cursor.
   --
   if l_one_status then
     null;
   --
   -- More than one batch status exists so need to derive the batch status.
   --
   elsif l_unprocessed then
     l_status := 'U';
   elsif l_transferred then
     l_status := 'P';
   elsif l_error       then
     l_status := 'E';
   elsif l_valid       then
     l_status := 'V';
   end if;
   --
   -- Set the status on the batch.
   --
   if csr_status%rowcount > 0 then
      update pay_balance_batch_headers BH
      set    BH.batch_status   = l_status
      where  BH.batch_id = p_glbl_data_rec.batch_id;
   end if;
   close csr_status;
   --
   hr_utility.trace('Exiting pay_balance_upload.set_batch_status');
   --
 end set_batch_status;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_header
  -- PURPOSE
  --  Ensures that the batch header for a batch are valid NB. it also populates
  --  the system IDs where necessary.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  --  write_message_line
  -- NOTES
  --  Ensures that
  --   1. the business group exists
  --   2. the payroll exists
  --   3. the payroll has a reasonable number of time periods prior to the
  --      upload date. TBD
  -----------------------------------------------------------------------------
 --
 procedure validate_batch_header
 (
  p_glbl_data_rec in out nocopy glbl_data_rec_type
 ) is
   --
   -- Retrieves the batch header.
   --
   cursor csr_batch_header
     (
      p_batch_id number
     )  is
     select *
     from   pay_balance_batch_headers BBH
     where  BBH.batch_id = p_batch_id
     for    update;
   --
   -- Retrieves business group information NB. either the business_group_id or
   -- name may have been specified. If both are specified then the
   -- business_group_id overrides the name. A constraint on the batch headers
   -- table ensures that at least one of them is set.
   --
   cursor csr_business_group
     (
      p_business_group_id number
     ,p_name              varchar2
     ,p_upload_date       date
     )  is
     select BG.business_group_id
	   ,BG.name
	   ,BG.legislation_code
     from   per_business_groups_perf BG
     where  p_business_group_id    is not null
       and  BG.business_group_id = p_business_group_id
     union all
     select BG.business_group_id
	   ,BG.name
	   ,BG.legislation_code
     from   per_business_groups_perf BG
     where  p_business_group_id   is null
       and  upper(BG.name)      = upper(p_name);
   --
   -- Retrieves payroll information NB. either the payroll_id or payroll_name
   -- may have been specified. If both are specified then the payroll_id
   -- overrides the payroll_name. A constraint on the batch headers table
   -- ensures that at least one of them is set.
   --
   cursor csr_payroll
     (
      p_business_group_id number
     ,p_payroll_id        number
     ,p_payroll_name      varchar2
     ,p_upload_date       date
     )  is
     select PL.payroll_id
	   ,PL.payroll_name
	   ,PL.consolidation_set_id
     from   pay_all_payrolls_f PL
     where  p_payroll_id           is not null
       and  PL.business_group_id + 0 = p_business_group_id
       and  PL.payroll_id        = p_payroll_id
       and  p_upload_date  between PL.effective_start_date
			       and PL.effective_end_date
     union all
     select PL.payroll_id
	   ,PL.payroll_name
	   ,PL.consolidation_set_id
     from   pay_all_payrolls_f PL
     where  p_payroll_id             is null
       and  PL.business_group_id + 0  = p_business_group_id
       and  upper(PL.payroll_name) = upper(p_payroll_name)
       and  p_upload_date    between PL.effective_start_date
			         and PL.effective_end_date;
   --
   -- Record to hold the batch header.
   --
   l_batch_header_rec csr_batch_header%rowtype;
   --
   -- Record to hold business group information.
   --
   l_bg_rec           csr_business_group%rowtype;
   --
   -- Record to hold payroll information.
   --
   l_payroll_rec      csr_payroll%rowtype;
   --
   -- Flags to hold the results of validation checks.
   --
   l_bg_invld         boolean := FALSE;
   l_pyrl_invld       boolean := FALSE;
   l_batchtyp_invld   boolean := FALSE;
   l_found            boolean;
   l_ctx_idx          number;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.validate_batch_header');
   --
   -- Retrieve the batch header.
   --
   open  csr_batch_header(p_glbl_data_rec.batch_id);
   fetch csr_batch_header into l_batch_header_rec;
   --
   -- See if the batch type is for balance initialization.
   -- NOTE: If batch type is null, we regard this as initialization.
   --
   if nvl(l_batch_header_rec.batch_type, 'I') <> 'I' then
     l_batchtyp_invld := TRUE;
   end if;
   --
   -- See if the business group exists.
   --
   hr_utility.set_location('pay_balance_upload.validate_batch_header',10);
   open  csr_business_group(l_batch_header_rec.business_group_id
		           ,l_batch_header_rec.business_group_name
		           ,p_glbl_data_rec.upload_date);
   fetch csr_business_group into l_bg_rec;
   if csr_business_group%notfound then
     l_bg_invld   := TRUE;
     l_pyrl_invld := FALSE;
   else
     l_batch_header_rec.business_group_id   := l_bg_rec.business_group_id;
     l_batch_header_rec.business_group_name := l_bg_rec.name;
     l_bg_invld                             := FALSE;
   end if;
   close csr_business_group;
   --
   -- See if the payroll exists.
   --
   hr_utility.set_location('pay_balance_upload.validate_batch_header',20);
   open  csr_payroll(l_batch_header_rec.business_group_id
		    ,l_batch_header_rec.payroll_id
		    ,l_batch_header_rec.payroll_name
		    ,p_glbl_data_rec.upload_date);
   fetch csr_payroll into l_payroll_rec;
   if csr_payroll%notfound then
     l_pyrl_invld := TRUE;
   else
     l_batch_header_rec.payroll_id   := l_payroll_rec.payroll_id;
     l_batch_header_rec.payroll_name := l_payroll_rec.payroll_name;
     l_pyrl_invld                    := FALSE;
   end if;
   close csr_payroll;
   --
   -- Check each error flag and write out message for each failure against the
   -- batch header being validated.
   --
   -- Batch Type is not valid.
   --
   hr_utility.set_location('pay_balance_upload.validate_batch_header',25);
   if l_batchtyp_invld then
     write_message_line
     (p_meesage_level => HEADER
     ,p_batch_id      => l_batch_header_rec.batch_id
     ,p_batch_line_id => null
     ,p_message_text  => null
     ,p_message_token => 'PAY_50387_BI_INV_BATCH_TYPE');
   end if;
   --
   -- Business group is not valid.
   --
   hr_utility.set_location('pay_balance_upload.validate_batch_header',30);
   if l_bg_invld then
     write_message_line
     (p_meesage_level => HEADER
     ,p_batch_id      => l_batch_header_rec.batch_id
     ,p_batch_line_id => null
     ,p_message_text  => null
     ,p_message_token => 'HR_6673_PO_EMP_NO_BG');
   end if;
   --
   -- Payroll is not valid.
   --
   hr_utility.set_location('pay_balance_upload.validate_batch_header',40);
   if l_pyrl_invld then
     write_message_line
     (p_meesage_level => HEADER
     ,p_batch_id      => l_batch_header_rec.batch_id
     ,p_batch_line_id => null
     ,p_message_text  => null
     ,p_message_token => 'HR_51043_PRL_DOES_NOT_EXIST');
   end if;
   --
   -- At least one of the tests has failed so mark the batch header as invalid.
   --
   if l_batchtyp_invld   or
      l_bg_invld         or
      l_pyrl_invld       then
     hr_utility.set_location('pay_balance_upload.validate_batch_header',50);
     l_batch_header_rec.batch_status := 'E';  -- Error
   --
   -- All tests have succeeded so mark the batch header as valid.
   --
   else
     hr_utility.set_location('pay_balance_upload.validate_batch_header',60);
     l_batch_header_rec.batch_status := 'V';  -- Valid
   end if;
   --
   -- Update the batch header with information retrieved during validation
   -- ie. if the payroll_name was set on a batch header then the payroll_id is
   -- derived.
   --
   -- Only set batch_status if have Error as in the case of Valid we
   -- we need the batch_status to remain L-ocked until end of upload
   -- for this batch.
   --
   if l_batch_header_rec.batch_status = 'E' then
      update pay_balance_batch_headers BBH
      set    BBH.business_group_id   = l_batch_header_rec.business_group_id
            ,BBH.business_group_name = l_batch_header_rec.business_group_name
            ,BBH.payroll_id          = l_batch_header_rec.payroll_id
            ,BBH.payroll_name        = l_batch_header_rec.payroll_name
            ,BBH.batch_status        = l_batch_header_rec.batch_status
      where  current of csr_batch_header;
   else
      update pay_balance_batch_headers BBH
      set    BBH.business_group_id   = l_batch_header_rec.business_group_id
            ,BBH.business_group_name = l_batch_header_rec.business_group_name
            ,BBH.payroll_id          = l_batch_header_rec.payroll_id
            ,BBH.payroll_name        = l_batch_header_rec.payroll_name
      where  current of csr_batch_header;
   end if;
   --
   close csr_batch_header;
   --
   -- Ensure that the global data structure has the current information.
   --
   p_glbl_data_rec.business_group_id    := l_batch_header_rec.business_group_id;
   p_glbl_data_rec.legislation_code     := l_bg_rec.legislation_code;
   p_glbl_data_rec.payroll_id           := l_batch_header_rec.payroll_id;
   p_glbl_data_rec.consolidation_set_id := l_payroll_rec.consolidation_set_id;
   p_glbl_data_rec.batch_header_status  := l_batch_header_rec.batch_status;
   --
   if p_glbl_data_rec.batch_header_status = 'V' then
     --
     -- Get the legislation contexts
     --
     pay_core_utils.get_dynamic_contexts(p_glbl_data_rec.business_group_id,
                                         g_legislation_contexts);

     -- Get the jurisdiction iv name.
     for l_ctx_idx in 1..g_legislation_contexts.count loop

       if (g_legislation_contexts(l_ctx_idx).context_name
             = 'JURISDICTION_CODE')                         then
         --
         p_glbl_data_rec.jurisdiction_iv
           := g_legislation_contexts(l_ctx_idx).input_value_name;
       end if;

     end loop;
     --
     -- Get legislation rule BAL_INIT_INCLUDE_ADJ.
     --
     -- This rule is used to determine whether to use include_adjustment
     -- in calculating sum of adjusted value for a balance.
     --
     -- Rule mode = Y - Call localization include_adjustment.
     -- Rule mode = N - Use a generic routine.
     -- No rule mode  - Call localization include_adjustment.
     --
     pay_core_utils.get_legislation_rule('BAL_INIT_INCLUDE_ADJ'
                                        ,p_glbl_data_rec.legislation_code
                                        ,p_glbl_data_rec.include_adj_rule
                                        ,l_found);
     if (l_found = FALSE) then
       p_glbl_data_rec.include_adj_rule := 'Y';
     end if;
     --
   end if;
--
   hr_utility.trace('Exiting pay_balance_upload.validate_batch_header');
   --
 end validate_batch_header;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  which_contexts
  -- PURPOSE
  --  Sets up flags indicating the contexts used by the balance dimension.
  -- ARGUMENTS
  --  p_dim_vald_rec
  --  The context indicators are set to true if the balance dimension uses that
  --  context :-
  --    jc_cntxt    - JURISDICTION_CODE
  --    gre_cntxt   - TAX_UNIT_ID
  --    oee_cntxt   - ORIGINAL_ENTRY_ID
  --    srcid_cntxt - SOURCE_ID
  --    srctxt_cntxt- SOURCE_TEXT
  --    sn_cntxt    - SOURCE_NUMBER
  --    st2_cntxt   - SOURCE_TEXT2
  --    other_cntxt - any other contexts except ASSIGNMENT_ACTION_ID which is
  --                  common to all dimensions.
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure which_contexts
 (
  p_dim_vald_rec         in out nocopy t_dimension_validation_rec
 ) is
   --
   -- Retrieves all the contexts used by a balance dimension.
   --
   cursor csr_context
     (
      p_balance_dimension_id number
     )  is
     select CO.context_name,
            BD.database_item_suffix,
            BD.legislation_code
     from   pay_balance_dimensions  BD
	   ,ff_route_context_usages CU
	   ,ff_contexts             CO
     where  BD.balance_dimension_id = p_balance_dimension_id
       and  CU.route_id             = BD.route_id
       and  CO.context_id           = CU.context_id;
   --
   l_dim_rec         t_dimension_validation_rec:= p_dim_vald_rec;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.which_contexts');
   --
   -- Indicator variables showing which contexts a balance dimension has.
   --
   l_dim_rec.jc_cntxt     := FALSE;
   l_dim_rec.gre_cntxt    := FALSE;
   l_dim_rec.oee_cntxt    := FALSE;
   l_dim_rec.other_cntxt  := FALSE;
   l_dim_rec.srcid_cntxt  := FALSE;
   l_dim_rec.srctxt_cntxt := FALSE;
   l_dim_rec.runtyp_cntxt := FALSE;
   --
   -- Retrieve all the contexts for the balance dimension.
   --
   for l_cntxt_rec in csr_context(l_dim_rec.balance_dimension_id) loop
     --
     -- Set the appropriate indicator depending on the context NB. the
     -- ASSIGNMENT_ACTION_ID context is common to all balance dimensions as is
     -- therefore ignored.
     --
     if    l_cntxt_rec.context_name = 'JURISDICTION_CODE'    then
       l_dim_rec.jc_cntxt    := TRUE;
     elsif l_cntxt_rec.context_name = 'TAX_UNIT_ID'          then
       l_dim_rec.gre_cntxt   := TRUE;
     elsif l_cntxt_rec.context_name = 'ORIGINAL_ENTRY_ID'    then
       l_dim_rec.oee_cntxt   := TRUE;
     elsif l_cntxt_rec.context_name = 'SOURCE_ID'            then
       l_dim_rec.srcid_cntxt   := TRUE;
     elsif l_cntxt_rec.context_name = 'SOURCE_TEXT'          then
       l_dim_rec.srctxt_cntxt   := TRUE;
     elsif l_cntxt_rec.context_name = 'SOURCE_NUMBER'        then
       l_dim_rec.sn_cntxt    := TRUE;
     elsif l_cntxt_rec.context_name = 'SOURCE_TEXT2'         then
       l_dim_rec.st2_cntxt   := TRUE;
     elsif l_cntxt_rec.context_name = 'ASSIGNMENT_ACTION_ID' then
       null;
     else
       l_dim_rec.other_cntxt := TRUE;
     end if;
--
     -- NBR.Hardcoded temporary change for Korean.
     if (l_cntxt_rec.legislation_code = 'KR'
         and (l_cntxt_rec.database_item_suffix like '%_BON'
             or l_cntxt_rec.database_item_suffix like '%_MTH')) then
       l_dim_rec.runtyp_cntxt := TRUE;
     end if;
     --
   end loop;
   --
   -- Set the indicator flags.
   --
   p_dim_vald_rec := l_dim_rec;
   --
   hr_utility.trace('Exiting pay_balance_upload.which_contexts');
   --
 end which_contexts;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  ins_latest_balance
  -- PURPOSE
  --  This inserts the latest balance and the context the balances requires
  --  onto the database.
  -- ARGUMENTS
  --  p_bal_type_id       - the balance type of the latest balance.
  --  p_bal_dimension_id  - the dimension of the latest balance.
  --  p_value             - the value of the balance.
  --  p_assignment_id     - the assignment the balance is for.
  --  p_asg_act_id        - the assignment action that last effected the
  --                        balance.
  --  p_tax_unit_id       - the tax unit context.
  --  p_jurisdiction_code - the jurisdiction context.
  --  p_source_id         - the source id context.
  --  p_source_text       - the source text context.
  --  p_source_number     - the source number context.
  --  p_source_text2      - the source text2 context.
  --  p_oee_id            - the original entry context.
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure ins_latest_balance
 (
   p_bal_type_id       in pay_balance_batch_lines.balance_type_id%TYPE,
   p_bal_dimension_id  in pay_balance_batch_lines.balance_dimension_id%TYPE,
   p_value             in pay_balance_batch_lines.value%TYPE,
   p_assignment_id     in pay_balance_batch_lines.assignment_id%TYPE,
   p_asg_act_id        in pay_assignment_actions.assignment_action_id%TYPE,
   p_tax_unit_id       in number,
   p_jurisdiction_code in pay_balance_batch_lines.jurisdiction_code%TYPE
                          default NULL,
   p_source_id         in number,
   p_source_text       in varchar2,
   p_source_number     in number,
   p_source_text2      in varchar2,
   p_run_type_id       in number,
   p_oee_id            in pay_balance_batch_lines.original_entry_id%TYPE
                          default NULL
 ) is
 --
   cursor csr_get_def_bal (p_bal_type_id in number,
                           p_bal_dimension_id in number)
   is
      select defined_balance_id
      from pay_defined_balances
      where balance_type_id = p_bal_type_id
      and   balance_dimension_id = p_bal_dimension_id;
   --
   cursor csr_get_context_id (p_cxt_name in varchar)
   is
      select context_id
      from   ff_contexts
      where  context_name = p_cxt_name;
   --
   --
   l_defined_bal number;
   l_lat_bal_id  number;
   l_bus_grp_id  number;
   l_person_id   number;
   l_status      varchar2(30);
   ctx_id        number;
 begin
    --
    hr_utility.trace('Entering pay_balance_upload.ins_latest_balance');
    open csr_get_def_bal (p_bal_type_id,
                          p_bal_dimension_id);
    fetch csr_get_def_bal into l_defined_bal;
    close csr_get_def_bal;
    --
    hr_utility.set_location('pay_balance_upload.ins_latest_balance',10);
    select pay_latest_balances_s.nextval
    into  l_lat_bal_id
    from sys.dual;
    --
    -- get bus grp id
    select distinct person_id,business_group_id
    into  l_person_id,l_bus_grp_id
    from per_all_assignments_f
    where assignment_id = p_assignment_id;

    pay_core_utils.get_upgrade_status(p_bus_grp_id=> l_bus_grp_id,
                             p_short_name=> 'SINGLE_BAL_TABLE',
                             p_status=>l_status);

   if (l_status='Y')
   then
    hr_utility.trace('latest balances table');
    insert into pay_latest_balances
                     (latest_balance_id,
                      assignment_id,
                      defined_balance_id,
                      assignment_action_id,
                      value,
		      person_id,
                      expired_assignment_action_id,
                      expired_value,
                      prev_assignment_action_id,
                      prev_balance_value,
		      tax_unit_id,
		      jurisdiction_code,
		      original_entry_id,
		      source_id,
		      source_text,
		      source_number,
		      source_text2
                     )
    values (l_lat_bal_id,
            p_assignment_id,
            l_defined_bal,
            p_asg_act_id,
            p_value,
            l_person_id,
            -9999,
            -9999,
            -9999,
            -9999,
	   p_tax_unit_id,
           p_jurisdiction_code,
	   p_oee_id,
	   p_source_id,
	   p_source_text,
	   p_source_number,
	   p_source_text2
	   );
   else
    insert into pay_assignment_latest_balances
                     (latest_balance_id,
                      assignment_id,
                      defined_balance_id,
                      assignment_action_id,
                      value,
                      expired_assignment_action_id,
                      expired_value,
                      prev_assignment_action_id,
                      prev_balance_value)
    values (l_lat_bal_id,
            p_assignment_id,
            l_defined_bal,
            p_asg_act_id,
            p_value,
            -9999,
            -9999,
            -9999,
            -9999);
    --
    if p_tax_unit_id is not null then
       --
       hr_utility.set_location('pay_balance_upload.ins_latest_balance',20);
       open csr_get_context_id('TAX_UNIT_ID');
       fetch csr_get_context_id into ctx_id;
       close csr_get_context_id;
       --
       insert into pay_balance_context_values
             (latest_balance_id,
              context_id,
              value)
       values (l_lat_bal_id,
               ctx_id,
               p_tax_unit_id);
    end if;
    --
    if p_jurisdiction_code is not null then
       --
       hr_utility.set_location('pay_balance_upload.ins_latest_balance',30);
       open csr_get_context_id('JURISDICTION_CODE');
       fetch csr_get_context_id into ctx_id;
       close csr_get_context_id;
       --
       insert into pay_balance_context_values
             (latest_balance_id,
              context_id,
              value)
       values (l_lat_bal_id,
               ctx_id,
               p_jurisdiction_code);
    end if;
    if p_oee_id is not null then
       --
       hr_utility.set_location('pay_balance_upload.ins_latest_balance',40);
       open csr_get_context_id('ORIGINAL_ENTRY_ID');
       fetch csr_get_context_id into ctx_id;
       close csr_get_context_id;
       --
       insert into pay_balance_context_values
             (latest_balance_id,
              context_id,
              value)
       values (l_lat_bal_id,
               ctx_id,
               p_oee_id);
    end if;
    --
    --
    if p_source_id is not null then
       --
       hr_utility.set_location('pay_balance_upload.ins_latest_balance',50);
       open csr_get_context_id('SOURCE_ID');
       fetch csr_get_context_id into ctx_id;
       close csr_get_context_id;
       --
       insert into pay_balance_context_values
             (latest_balance_id,
              context_id,
              value)
       values (l_lat_bal_id,
               ctx_id,
               p_source_id);
    end if;
    --
    if p_source_text is not null then
       --
       hr_utility.set_location('pay_balance_upload.ins_latest_balance',50);
       open csr_get_context_id('SOURCE_TEXT');
       fetch csr_get_context_id into ctx_id;
       close csr_get_context_id;
       --
       insert into pay_balance_context_values
             (latest_balance_id,
              context_id,
              value)
       values (l_lat_bal_id,
               ctx_id,
               p_source_text);
    end if;
    --
    if p_source_number is not null then
       --
       hr_utility.set_location('pay_balance_upload.ins_latest_balance',60);
       open csr_get_context_id('SOURCE_NUMBER');
       fetch csr_get_context_id into ctx_id;
       close csr_get_context_id;
       --
       insert into pay_balance_context_values
             (latest_balance_id,
              context_id,
              value)
       values (l_lat_bal_id,
               ctx_id,
               p_source_number);
    end if;
    --
    if p_source_text2 is not null then
       --
       hr_utility.set_location('pay_balance_upload.ins_latest_balance',70);
       open csr_get_context_id('SOURCE_TEXT2');
       fetch csr_get_context_id into ctx_id;
       close csr_get_context_id;
       --
       insert into pay_balance_context_values
             (latest_balance_id,
              context_id,
              value)
       values (l_lat_bal_id,
               ctx_id,
               p_source_text2);
    end if;
    --
   end if;
   hr_utility.trace('Exiting pay_balance_upload.ins_latest_balance');
 end ins_latest_balance;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  load_latest_asg_balances
  -- PURPOSE
  --  This creates all the latest balances for an assignment.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  --  p_batch_line_list - the list of batch lines currently being processed
  --  p_num_lines       - the number of batch lines in the list.
  -- USES
  --  ins_latest_balance
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure load_latest_asg_balances
 (
  p_glbl_data_rec   in     glbl_data_rec_type,
  p_batch_line_list in out nocopy number_array,
  p_num_lines       in out nocopy number
 ) is
   --
   --
   cursor csr_get_asg_act (p_act_id in number,
                           p_asg_id     in number)
   is
     select paa.assignment_action_id
     from pay_assignment_actions paa
     where paa.assignment_id = p_asg_id
     and   paa.payroll_action_id = p_act_id;
   --
   --
   cursor csr_latest_asg_balances (p_batch_id      number,
                                   p_assignment_id number)
   is
   select pbl.balance_type_id,
          pbl.balance_name,
          pbl.dimension_name,
          pbl.balance_dimension_id,
          pbl.batch_line_id,
          pbl.gre_name,
          pbl.tax_unit_id,
          pbl.jurisdiction_code,
          pbl.original_entry_id,
          pbl.source_id,
          pbl.source_text,
          pbl.source_number,
          pbl.source_text2,
          pbl.run_type_id,
          pbl.run_type_name,
          pbl.payroll_action_id,
          pbl.value
   from
        pay_balance_dimensions  pbd,
        pay_balance_batch_lines pbl
   where pbl.batch_id      = p_batch_id
   and   pbl.assignment_id = p_assignment_id
   and   pbl.balance_dimension_id = pbd.balance_dimension_id
   and   pbl.upload_date is null -- Don't consider historical loads
   and   pbd.dimension_type in ('A', 'P')
   order by pbl.batch_line_status;
   --
   -- Record to hold a batch line NB. the cursor is defined at package level.
   --
   l_lat_asg_balance csr_latest_asg_balances%rowtype;
   l_asg_act_id  number;
   l_max_act_seq number;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.load_latest_asg_balances');
   --
   open csr_latest_asg_balances(p_glbl_data_rec.batch_id
                               ,p_glbl_data_rec.assignment_id);
   --
   loop
     --
     -- Get the next batch line for the assignment.
     --
     fetch csr_latest_asg_balances into l_lat_asg_balance;
     --
     exit  when (csr_latest_asg_balances%notfound);
     --
     --  Store the details of linein case of error
     --
     p_num_lines                    := 1;
     p_batch_line_list(p_num_lines) := l_lat_asg_balance.batch_line_id;
     hr_utility.trace(p_num_lines||' '||p_batch_line_list(p_num_lines));
     --
     if (l_lat_asg_balance.value <> 0) then
       hr_utility.set_location('pay_balance_upload.load_latest_asg_balances',
                                10);
       select /*+ ORDERED
                  USE_NL(pbl ppa pbf paa rr rrv)
                  INDEX(pbl PAY_BALANCE_BATCH_LINES_N51)
                  INDEX(ppa PAY_PAYROLL_ACTIONS_PK)
                  INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                  INDEX(rr PAY_RUN_RESULTS_N50)
                  INDEX(rrv PAY_RUN_RESULT_VALUES_N50)
                  INDEX(pbf PAY_BALANCE_FEEDS_F_N2) */
              to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                               paa.assignment_action_id),16))
       into l_asg_act_id
       from
            pay_balance_batch_lines pbl,
            pay_payroll_actions     ppa,
            pay_assignment_actions  paa,
            pay_run_results         rr,
            pay_run_result_values   rrv,
            pay_balance_feeds_f     pbf
       where pbl.batch_id = p_glbl_data_rec.batch_id
       and   pbl.assignment_id = p_glbl_data_rec.assignment_id
       and   pbl.balance_type_id = l_lat_asg_balance.balance_type_id
       and   pbl.payroll_action_id = ppa.payroll_action_id
       and   pbl.balance_type_id = pbf.balance_type_id + 0
       and   ppa.effective_date between
                      pbf.effective_start_date and pbf.effective_end_date
       and   paa.payroll_action_id = ppa.payroll_action_id
       and   paa.assignment_id = pbl.assignment_id
       and   paa.assignment_action_id = rr.assignment_action_id
       and   rr.run_result_id = rrv.run_result_id
       and   rrv.input_value_id = pbf.input_value_id
       and   nvl(rrv.result_value, '0') <> '0'
       and   upper(nvl(nvl(pbl.gre_name, l_lat_asg_balance.gre_name),'-1')) =
                  upper(nvl(nvl(l_lat_asg_balance.gre_name,
                                pbl.gre_name), '-1'))
       and   upper(nvl(nvl(pbl.run_type_name, l_lat_asg_balance.run_type_name),'-1')) =
                  upper(nvl(nvl(l_lat_asg_balance.run_type_name,
                                pbl.run_type_name), '-1'))
       and   nvl(nvl(pbl.jurisdiction_code,
                     l_lat_asg_balance.jurisdiction_code), -1) =
                         nvl(nvl(l_lat_asg_balance.jurisdiction_code,
                                 pbl.jurisdiction_code), -1)
       and   upper(nvl(nvl(pbl.source_text, l_lat_asg_balance.source_text),'-1')) =
                upper(nvl(nvl(l_lat_asg_balance.source_text, pbl.source_text), '-1'))
       and   nvl(nvl(pbl.source_id, l_lat_asg_balance.source_id), -1) =
                nvl(nvl(l_lat_asg_balance.source_id, pbl.source_id), -1)
       and   upper(nvl(nvl(pbl.source_text2, l_lat_asg_balance.source_text2),'-1')) =
                upper(nvl(nvl(l_lat_asg_balance.source_text2, pbl.source_text2), '-1'))
       and   nvl(nvl(pbl.source_number, l_lat_asg_balance.source_number), -1) =
                nvl(nvl(l_lat_asg_balance.source_number, pbl.source_number), -1)
       and   nvl(nvl(pbl.tax_unit_id, l_lat_asg_balance.tax_unit_id), -1) =
                nvl(nvl(l_lat_asg_balance.tax_unit_id, pbl.tax_unit_id), -1)
       and   nvl(nvl(pbl.run_type_id, l_lat_asg_balance.run_type_id), -1) =
                nvl(nvl(l_lat_asg_balance.run_type_id, pbl.run_type_id), -1)
       and   nvl(nvl(pbl.original_entry_id,
                   l_lat_asg_balance.original_entry_id), -1) =
                         nvl(nvl(l_lat_asg_balance.original_entry_id,
                                           pbl.original_entry_id), -1);
     else
        hr_utility.set_location('pay_balance_upload.load_latest_asg_balances',
                                20);
        --
        open csr_get_asg_act (l_lat_asg_balance.payroll_action_id,
                              p_glbl_data_rec.assignment_id);
        fetch csr_get_asg_act into l_asg_act_id;
        --
        if csr_get_asg_act%notfound then
           close csr_get_asg_act;
           raise no_data_found;
        end if;
        --
        close csr_get_asg_act;
        --
     end if;
     --
     hr_utility.set_location('pay_balance_upload.load_latest_asg_balances', 30);
     ins_latest_balance(l_lat_asg_balance.balance_type_id,
                        l_lat_asg_balance.balance_dimension_id,
                        l_lat_asg_balance.value,
                        p_glbl_data_rec.assignment_id,
                        l_asg_act_id,
                        l_lat_asg_balance.tax_unit_id,
                        l_lat_asg_balance.jurisdiction_code,
                        l_lat_asg_balance.source_id,
                        l_lat_asg_balance.source_text,
                        l_lat_asg_balance.source_number,
                        l_lat_asg_balance.source_text2,
                        l_lat_asg_balance.run_type_id,
                        l_lat_asg_balance.original_entry_id);
     --
   end loop;
   --
   close csr_latest_asg_balances;
   --
   p_num_lines                    := 0;
   --
   hr_utility.trace('Exiting pay_balance_upload.load_latest_asg_balances');
   --
 end load_latest_asg_balances;
  --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_dimension
  -- PURPOSE
  --  Ensures that the balance dimension on the batch line is valid.
  -- ARGUMENTS
  --  p_glbl_data_rec  - global data structure.
  --  p_batch_line_rec - the current batch line.
  --  p_bal_vald_rec   - Balance validation details.
  -- USES
  --  which_contexts
  --  write_message_line
  -- NOTES
  --  Ensures that
  --   1. the balance dimension exists
  --   2. the balance dimension is one of the supported dimensions
  --   3. the JURISDICTION_CODE context is set when required.
  --   4. the TAX_UNIT_ID context is set when required.
  --   5. the TAX_UNIT_ID is valid.
  --   6. the ORIGINAL_ENTRY_ID context is set when required.
  --   7. the ORIGINAL_ENTRY_ID is valid.
  --   8. the SOURCE_ID context is set when required.
  --   9. the SOURCE_ID is valid.
  --   10.the SOURCE_TEXT context is set when required.
  --   11.the SOURCE_TEXT is valid.
  --   12.the SOURCE_NUMBER context is set when required.
  --   13.the SOURCE_NUMBER input value exists when required.
  --   14.the SOURCE_TEXT2 context is set when required.
  --   15.the SOURCE_TEXT2 input value exists when required.
  -----------------------------------------------------------------------------
 --
 procedure validate_dimension
 (
  p_glbl_data_rec  in            glbl_data_rec_type
 ,p_batch_line_rec in out nocopy csr_batch_line_validate%rowtype
 ,p_bal_vald_rec   in            t_balance_validation_rec
 ) is
   --
   -- Retrieves dimension information NB. either the balance_dimension_id or
   -- dimension_name may have been specified. If both are specified then
   -- the balance_dimension_id overrides the dimension_name. A constraint on
   -- the batch lines table ensures that at least one of them is set.
   --
   cursor csr_dimension
     (
      p_business_group_id    number
     ,p_legislation_code     varchar2
     ,p_balance_dimension_id number
     ,p_dimension_name       varchar2
     )  is
     select BD.balance_dimension_id
	   ,upper(BD.dimension_name) dimension_name
     from   pay_balance_dimensions BD
     where  p_balance_dimension_id    is not null
       and  BD.balance_dimension_id = p_balance_dimension_id
       and  nvl(BD.business_group_id, nvl(p_business_group_id, -1)) =
              nvl(p_business_group_id, -1)
       and  nvl(BD.legislation_code, nvl(p_legislation_code, ' '))  =
              nvl(p_legislation_code, ' ')
     union all
     select BD.balance_dimension_id
	   ,upper(BD.dimension_name) dimension_name
     from   pay_balance_dimensions BD
     where  p_balance_dimension_id     is null
       and  upper(BD.dimension_name) = upper(p_dimension_name)
       and  nvl(BD.business_group_id, nvl(p_business_group_id, -1)) =
              nvl(p_business_group_id, -1)
       and  nvl(BD.legislation_code, nvl(p_legislation_code, ' '))  =
              nvl(p_legislation_code, ' ');
   --
   -- This cursor is used to check a defined balance exists.
   --
   cursor csr_get_defined_balance
      (
       p_dimension_id    number
      ,p_balance_type_id number
      ) is
      select defined_balance_id
      from pay_defined_balances
      where balance_type_id      = p_balance_type_id
        and balance_dimension_id = p_dimension_id;
   --
   -- Retrieves element entry information.
   --
   cursor csr_entry
     (
      p_upload_date       date
     ,p_assignment_id     number
     ,p_original_entry_id number
     ) is
     select EE.element_entry_id
     from   pay_element_entries_f EE
     where  EE.assignment_id         = p_assignment_id
       and  EE.entry_type            = 'E'
       and  EE.effective_start_date <= p_upload_date
       and  EE.element_entry_id      = p_original_entry_id
       and  EE.original_entry_id      is null
     union all
     select EE.element_entry_id
     from   pay_element_entries_f EE
     where  EE.assignment_id         = p_assignment_id
       and  EE.entry_type            = 'E'
       and  EE.effective_start_date <= p_upload_date
       and  EE.original_entry_id     = p_original_entry_id;
   --
   -- Record to hold dimension information.
   --
   l_dimension_rec     csr_dimension%rowtype;
   --
   -- Record to hold tax unit information.
   --
   --
   -- Record for the defined balances.
   --
   l_def_bal_rec       csr_get_defined_balance%rowtype;
   --
   -- holds the element entry an assignment has.
   --
   l_ele_entry_id      number;
   --
   -- Variables to cache details of the current dimension being validated.
   --
   l_dim_rec           t_dimension_validation_rec;
   --
   l_dim_is_supported  varchar2(5);
   --
   l_jc_cntxt_not_set  boolean := FALSE;
   l_gre_cntxt_not_set boolean := FALSE;
   l_gre_cntxt_invld   boolean := FALSE;
   l_oee_cntxt_not_set boolean := FALSE;
   l_oee_cntxt_invld   boolean := FALSE;
   l_srcid_cntxt_nset  boolean := FALSE;
   l_srctxt_cntxt_nset boolean := FALSE;
   l_sn_cntxt_nset     boolean := FALSE;
   l_st2_cntxt_nset    boolean := FALSE;
   l_srcid_cntxt_noiv  boolean := FALSE;
   l_srctxt_cntxt_noiv boolean := FALSE;
   l_sn_cntxt_noiv     boolean := FALSE;
   l_st2_cntxt_noiv    boolean := FALSE;
   l_def_bal_not_fnd   boolean := FALSE;
   l_runtyp_cntxt_not_set boolean := FALSE;
   l_runtyp_cntxt_invld boolean := FALSE;
   --
   -- Variables used to control the search through list of previously
   -- validated balances.
   --
   l_index             number  := 0;
   l_dim_index         number;
   l_dimension_found   boolean := FALSE;
   --
   l_msgs         varchar2_array;
   l_msg_idx      number;
   --
   l_iv_start_ptr number;
   l_iv_end_ptr   number;
   l_iv_idx       number;
   l_context      ff_contexts.context_name%type;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.validate_dimension');
   --
   -- Search through list of dimensions that have already been validated NB
   -- the list of dimensions is held in a PLSQL table.
   --
   for l_index in 1..g_dim_vald.count loop
     --
     -- See if the dimension is in the list NB. the balance_dimension_id
     -- overrides the dimension_name. If the dimension is found then the flag
     -- is set and the search index points to the matching entry.
     --
     if ((p_batch_line_rec.balance_dimension_id
           = g_dim_vald(l_index).balance_dimension_id) or
         (p_batch_line_rec.balance_dimension_id    is null               and
	  upper(p_batch_line_rec.dimension_name)
           = g_dim_vald(l_index).dimension_name)) then
       l_dimension_found := TRUE;
       l_dim_index := l_index;
       exit;
     end if;
     --
   end loop;
   --
   -- Dimension has already been validated.
   --
   if l_dimension_found then
     --
     -- Values must be the same as those for the dimension when it was
     -- validated.
     --
     l_dim_rec := g_dim_vald(l_dim_index);

   --
   -- Dimension is new ie. has not been found already. The dimension must be
   -- validated and added to the list of validated dimensions.
   --
   else
     --
     -- See if the dimension exists. If it does not then cache the old values
     -- else cache the new values (for subsequent checks) NB. a dimension
     -- that does not exist cannot be validated any further.
     --
     open csr_dimension(p_glbl_data_rec.business_group_id
		       ,p_glbl_data_rec.legislation_code
                       ,p_batch_line_rec.balance_dimension_id
                       ,p_batch_line_rec.dimension_name);
     fetch csr_dimension into l_dimension_rec;
     if csr_dimension%notfound then
       l_dim_rec.balance_dimension_id:= p_batch_line_rec.balance_dimension_id;
       l_dim_rec.dimension_name      := p_batch_line_rec.dimension_name;
       l_dim_rec.invld               := TRUE;
     else
       l_dim_rec.balance_dimension_id:= l_dimension_rec.balance_dimension_id;
       l_dim_rec.dimension_name      := l_dimension_rec.dimension_name;
       l_dim_rec.invld               := FALSE;
       --
       -- Find out which contexts the balance dimension uses.
       --
       which_contexts(l_dim_rec);
       --
     end if;
     close csr_dimension;
     --
     -- Balance dimension exists so continue validation. This validation
     -- only has to be done once for each new balance dimension eg. is the
     -- dimension one of the supported dimensions.
     --
     if not l_dim_rec.invld then
       --
       -- Ensure that the dimension is supported.
       --
       l_dim_is_supported := dim_is_supported
                               (p_glbl_data_rec.legislation_code
                               ,l_dim_rec.dimension_name
                               );
       --
       if l_dim_is_supported = 'Y' then
         l_dim_rec.not_supp := FALSE;
       else
         l_dim_rec.not_supp := TRUE;
       end if;
       --
     end if;
     --
     -- A new dimension has been found so add it to the list of validated
     -- dimensions.
     --
     if not (l_dim_rec.balance_dimension_id is null and
             l_dim_rec.dimension_name is null) then

       l_dim_index := g_dim_vald.count+1;
       g_dim_vald(l_dim_index) := l_dim_rec;

     end if;
     --
   end if;
   --
   -- Balance dimension exists and is supported so continue validation NB.
   -- this validation has to be done for each new batch line even if the
   -- balance dimension has already been validated. This validation ensures
   -- that the relevant contexts have been set and are valid.
   --
   if not l_dim_rec.invld and not l_dim_rec.not_supp then
     --
     -- Does the balance have this dimension
     --
     open csr_get_defined_balance (l_dim_rec.balance_dimension_id,
                                   p_batch_line_rec.balance_type_id);
     fetch csr_get_defined_balance into l_def_bal_rec;
     if csr_get_defined_balance%notfound then
        l_def_bal_not_fnd := TRUE;
     end if;
     --
     close csr_get_defined_balance;
     --
     -- Dimension requires a JURISDICTION_CODE context.
     --
     if l_dim_rec.jc_cntxt  then
       if p_batch_line_rec.jurisdiction_code is null then
	 l_jc_cntxt_not_set := TRUE;
       end if;
     else
       p_batch_line_rec.jurisdiction_code := null;
     end if;
     --
     -- Dimension requires a TAX_UNIT_ID context.
     --
     if l_dim_rec.gre_cntxt then
       if (p_batch_line_rec.gre_name is null
           and p_batch_line_rec.tax_unit_id is null) then
	 l_gre_cntxt_not_set := TRUE;
       else
         begin
             get_tax_unit_id( p_glbl_data_rec.business_group_id,
                              p_batch_line_rec.gre_name,
                              p_batch_line_rec.tax_unit_id);
         exception
            when no_data_found then
               l_gre_cntxt_invld := TRUE;
         end;
         --
       end if;
     else
       p_batch_line_rec.gre_name := null;
       p_batch_line_rec.tax_unit_id := null;
     end if;
     --
     -- Dimension requires a RUN_TYPE_ID context.
     --
     if l_dim_rec.runtyp_cntxt then
       if (p_batch_line_rec.run_type_name is null
           and p_batch_line_rec.run_type_id is null) then
         l_runtyp_cntxt_not_set := TRUE;
       else
         begin
             get_run_type_id( p_glbl_data_rec.business_group_id,
                              p_batch_line_rec.run_type_name,
                              p_batch_line_rec.run_type_id,
                              p_glbl_data_rec.upload_date);
         exception
            when no_data_found then
               l_runtyp_cntxt_invld := TRUE;
         end;
         --
       end if;
     else
       p_batch_line_rec.run_type_name := null;
       p_batch_line_rec.run_type_id := null;
     end if;
     --
     -- Dimension requires an ORIGINAL_ENTRY_ID context.
     --
     if l_dim_rec.oee_cntxt then
       if p_batch_line_rec.original_entry_id is null then
	 l_oee_cntxt_not_set := TRUE;
       else
         open csr_entry(p_glbl_data_rec.upload_date
                       ,p_batch_line_rec.assignment_id
                       ,p_batch_line_rec.original_entry_id);
         fetch csr_entry into l_ele_entry_id;
         if csr_entry%notfound then
           l_oee_cntxt_invld := TRUE;
         end if;
	 close csr_entry;
       end if;
     else
       p_batch_line_rec.original_entry_id := null;
     end if;
     --
     -- Dimension requires an SOURCE_ID context.
     --
     if l_dim_rec.srcid_cntxt then
       if p_batch_line_rec.source_id is null then
         l_srcid_cntxt_nset := TRUE;
       end if;
     else
       p_batch_line_rec.source_id := null;
     end if;
     --
     -- Dimension requires an SOURCE_TEXT context.
     --
     if l_dim_rec.srctxt_cntxt then
       if p_batch_line_rec.source_text is null then
         l_srctxt_cntxt_nset := TRUE;
       end if;
     else
       p_batch_line_rec.source_text := null;
     end if;
     --
     -- Dimension requires an SOURCE_NUMBER context.
     --
     if l_dim_rec.sn_cntxt then
       if p_batch_line_rec.source_number is null then
         l_sn_cntxt_nset := TRUE;
       end if;
     else
       p_batch_line_rec.source_number := null;
     end if;
     --
     -- Dimension requires an SOURCE_TEXT2 context.
     --
     if l_dim_rec.st2_cntxt then
       if p_batch_line_rec.source_text2 is null then
         l_st2_cntxt_nset := TRUE;
       end if;
     else
       p_batch_line_rec.source_text2 := null;
     end if;
     --
     -- Check the existence of dynamic context input values
     -- NB. jurisdiction code is excluded since it has already
     --     been checked in validate_balance.
     --
     if    (l_dim_rec.srcid_cntxt  or
            l_dim_rec.srctxt_cntxt or
            l_dim_rec.sn_cntxt     or
            l_dim_rec.st2_cntxt)
       and (p_bal_vald_rec.element_link_id is not null) then
       --
       -- Set the indicator of input value existence error.
       --
       if l_dim_rec.srcid_cntxt then
         l_srcid_cntxt_noiv := TRUE;
       end if;
       if l_dim_rec.srctxt_cntxt then
         l_srctxt_cntxt_noiv := TRUE;
       end if;
       if l_dim_rec.sn_cntxt then
         l_sn_cntxt_noiv := TRUE;
       end if;
       if l_dim_rec.st2_cntxt then
         l_st2_cntxt_noiv := TRUE;
       end if;

       load_element_contexts(p_bal_vald_rec.element_link_id
                            ,l_iv_start_ptr
                            ,l_iv_end_ptr
                            );

       if l_iv_start_ptr is not null then
         for l_iv_idx in l_iv_start_ptr..l_iv_end_ptr loop

           l_context := g_input_val_contexts(l_iv_idx).context_name;

           if l_dim_rec.srcid_cntxt and l_context = 'SOURCE_ID' then
             -- Source ID input value exists.
             l_srcid_cntxt_noiv := FALSE;

           elsif l_dim_rec.srctxt_cntxt and l_context = 'SOURCE_TEXT' then
             -- Source Text input value exists.
             l_srctxt_cntxt_noiv := FALSE;

           elsif l_dim_rec.sn_cntxt and l_context = 'SOURCE_NUMBER' then
             -- Source Number input value exists.
             l_sn_cntxt_noiv := FALSE;

           elsif l_dim_rec.st2_cntxt and l_context = 'SOURCE_TEXT2' then
             -- Source Text2 input value exists.
             l_st2_cntxt_noiv := FALSE;

           end if;

         end loop;
       end if;

     end if;
     --
   end if;
   --
   -- Check each error flag and write out message for each failure against the
   -- batch line being validated.
   --
   -- Balance dimension does not exist.
   --
   if l_dim_rec.invld then
     l_msgs(l_msgs.count+1) := 'HR_51044_BLD_DOES_NOT_EXIST';
   end if;
   --
   -- Balance dimension is not supported.
   --
   if l_dim_rec.not_supp then
     l_msgs(l_msgs.count+1) := 'HR_51045_BLD_IS_NOT_SUPPORTED';
   end if;
   --
   -- The Defined Balance does not exist.
   --
   if l_def_bal_not_fnd then
     l_msgs(l_msgs.count+1) := 'HR_51105_BAL_DEF_NOT_EXIST';
   end if;
   --
   -- The JURISDICTION_CODE context must be specified.
   --
   if l_jc_cntxt_not_set then
     l_msgs(l_msgs.count+1) := 'HR_13131_BAL_JURIS_MANDATORY';
   end if;
   --
   -- The TAX_UNIT_ID context must be specified.
   --
   if l_gre_cntxt_not_set then
     l_msgs(l_msgs.count+1) := 'HR_13130_BAL_TAX_UNIT_MAND';
   end if;
   --
   -- The tax unit does not exist.
   --
   if l_gre_cntxt_invld then
     l_msgs(l_msgs.count+1) := 'HR_51046_ORU_TU_INVALID';
   end if;
   --
   -- The RUN_TYPE_ID context must be specified.
   --
   if l_runtyp_cntxt_not_set then
     l_msgs(l_msgs.count+1) := 'PAY_289146_RUN_TYP_MAND';
   end if;
   --
   -- The run type does not exist.
   --
   if l_runtyp_cntxt_invld then
     l_msgs(l_msgs.count+1) := 'PAY_289147_INV_RUN_TYP';
   end if;
   --
   -- The ORIGINAL_ENTRY_ID context must be specified.
   --
   if l_oee_cntxt_not_set then
     l_msgs(l_msgs.count+1) := 'HR_51047_ELE_ORIG_CXT_NEEDED';
   end if;
   --
   -- The element entry does not exist.
   --
   if l_oee_cntxt_invld then
     l_msgs(l_msgs.count+1) := 'HR_51048_ELE_ORIG_DO_NOT_EXIST';
   end if;
   --
   -- The SOURCE_ID context must be specified.
   --
   if l_srcid_cntxt_nset then
     l_msgs(l_msgs.count+1) := 'HR_51445_SRC_ID_CXT_NEEDED';
   end if;
   --
   -- The source id does not exist.
   --
   if l_srcid_cntxt_noiv then
     l_msgs(l_msgs.count+1) := 'HR_51446_SRC_ID_DO_NOT_EXIST';
   end if;
   --
   -- The SOURCE_TEXT context must be specified.
   --
   if l_srctxt_cntxt_nset then
     l_msgs(l_msgs.count+1) := 'HR_51447_SRC_TEXT_CXT_NEEDED';
   end if;
   --
   -- The source text does not exist.
   --
   if l_srctxt_cntxt_noiv then
     l_msgs(l_msgs.count+1) := 'HR_51448_SRC_TEXT_DO_NOT_EXIST';
   end if;
   --
   -- The SOURCE_NUMBER context must be specified.
   --
   if l_sn_cntxt_nset then
     l_msgs(l_msgs.count+1) := 'PAY_33250_BAL_SRC_NUM_MAND';
   end if;
   --
   -- Source Number input value does not exist.
   --
   if l_sn_cntxt_noiv then
     l_msgs(l_msgs.count+1) := 'PAY_33251_BAL_NO_SRC_NUM_IV';
   end if;
   --
   -- The SOURCE_TEXT2 context must be specified.
   --
   if l_st2_cntxt_nset then
     l_msgs(l_msgs.count+1) := 'PAY_33252_BAL_SRC_TXT2_MAND';
   end if;
   --
   -- Source Text2 input value does not exist.
   --
   if l_st2_cntxt_noiv then
     l_msgs(l_msgs.count+1) := 'PAY_33253_BAL_NO_SRC_TXT2_IV';
   end if;
   --
   -- Write all the messages
   --
   for l_msg_idx in 1..l_msgs.count loop

     write_message_line
      (p_meesage_level => LINE
      ,p_batch_id      => null
      ,p_batch_line_id => p_batch_line_rec.batch_line_id
      ,p_message_text  => null
      ,p_message_token => l_msgs(l_msg_idx));

   end loop;
   --
   -- Update the batch line with the balance information.
   --
   p_batch_line_rec.balance_dimension_id := l_dim_rec.balance_dimension_id;
   p_batch_line_rec.dimension_name       := l_dim_rec.dimension_name;
   --
   -- At least one of the tests has failed so mark the batch line as invalid.
   --
   if l_dim_rec.invld     or
      l_dim_rec.not_supp  or
      l_def_bal_not_fnd   or
      l_jc_cntxt_not_set  or
      l_gre_cntxt_not_set or
      l_oee_cntxt_not_set or
      l_srctxt_cntxt_noiv or
      l_srcid_cntxt_noiv  or
      l_srctxt_cntxt_nset or
      l_srcid_cntxt_nset  or
      l_sn_cntxt_nset     or
      l_sn_cntxt_noiv     or
      l_st2_cntxt_nset    or
      l_st2_cntxt_noiv    or
      l_gre_cntxt_invld   or
      l_runtyp_cntxt_not_set or
      l_runtyp_cntxt_invld or
      l_oee_cntxt_invld   then
     p_batch_line_rec.batch_line_status := 'E';  -- Error
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.validate_dimension');
   --
 end validate_dimension;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_balance
  -- PURPOSE
  --  Ensures that the balance on the batch line is valid.
  -- ARGUMENTS
  --  p_glbl_data_rec  - global data structure.
  --  p_batch_line_rec - the current batch line.
  --  p_bal_vald_rec   - balance validation results
  -- USES
  --  write_message_line
  -- NOTES
  --  Ensures that
  --   1. the balance exists
  --   2. the balance has an initial balance feed
  --   3. an element link exists which ensures the eligibility of the element
  --      used by initial balance feed.
  -----------------------------------------------------------------------------
 --
 procedure validate_balance
 (
  p_glbl_data_rec  in            glbl_data_rec_type
 ,p_batch_line_rec in out nocopy csr_batch_line_validate%rowtype
 ,p_bal_vald_rec      out nocopy t_balance_validation_rec
 ) is
   --
   -- Retrieves balance information NB. either the balance_type_id or
   -- balance_name may have been specified. If both are specified then
   -- the balance_type_id overrides the balance_name. A constraint on the
   -- batch lines table ensures that at least one of them is set.
   --
   cursor csr_balance
     (
      p_business_group_id number
     ,p_legislation_code  varchar2
     ,p_balance_type_id   number
     ,p_balance_name      varchar2
     )  is
     select BT.balance_type_id
	   ,upper(BT.balance_name) balance_name
     from   pay_balance_types   BT
     where  p_balance_type_id      is not null
       and  BT.balance_type_id   = p_balance_type_id
       and  nvl(BT.business_group_id, nvl(p_business_group_id, -1)) =
              nvl(p_business_group_id, -1)
       and  nvl(BT.legislation_code, nvl(p_legislation_code, ' '))  =
              nvl(p_legislation_code, ' ')
     union all
     select BT.balance_type_id
	   ,upper(BT.balance_name) balance_name
     from   pay_balance_types   BT
     where  p_balance_type_id        is null
       and  upper(BT.balance_name) = upper(p_balance_name)
       and  nvl(BT.business_group_id, nvl(p_business_group_id, -1)) =
              nvl(p_business_group_id, -1)
       and  nvl(BT.legislation_code, nvl(p_legislation_code, ' '))  =
              nvl(p_legislation_code, ' ');
   --
   -- Retrieves the initial balance feed information for a balance NB. if the
   -- balance uses the JURISDICTION_CODE context then the element used for the
   -- initial balance feed must also have an input valu8e called 'Jurisdiction'.
   --
   cursor csr_initial_balance_feed
     (
      p_business_group_id number
     ,p_legislation_code  varchar2
     ,p_balance_type_id   number
     )  is
     select ET.element_type_id
           ,BT.jurisdiction_level
           ,IV.input_value_id          ibf_input_value_id
           ,decode(nvl(BT.jurisdiction_level, 0),
		   0, null,
		   IV2.input_value_id) jc_input_value_id
     from   pay_balance_types           BT
	   ,pay_balance_feeds_f         BF
           ,pay_input_values_f          IV
           ,pay_input_values_f          IV2
           ,pay_element_types_f         ET
           ,pay_element_classifications EC
     where  BF.balance_type_id = p_balance_type_id
       and  BT.balance_type_id               = BF.balance_type_id
       and  IV.input_value_id                = BF.input_value_id
       and  ET.element_type_id               = IV.element_type_id
       and  EC.classification_id             = ET.classification_id
       and  EC.balance_initialization_flag   = 'Y'
       and  ((nvl(BT.jurisdiction_level, 0) <> 0                  and
	      IV2.element_type_id            = ET.element_type_id and
	      IV2.name                       = p_glbl_data_rec.jurisdiction_iv)    or
             (nvl(BT.jurisdiction_level, 0)  = 0                  and
	      IV2.input_value_id             = IV.input_value_id))
       and  (ET.business_group_id +0 = p_business_group_id
             or (ET.business_group_id is null
                 and ET.legislation_code = p_legislation_code)
             or (ET.business_group_id is null and ET.legislation_code is null))
       and  BF.effective_start_date          = START_OF_TIME
       and  BF.effective_end_date            = END_OF_TIME
       and  IV.effective_start_date          = START_OF_TIME
       and  IV.effective_end_date            = END_OF_TIME
       and  IV2.effective_start_date         = START_OF_TIME
       and  IV2.effective_end_date           = END_OF_TIME
       and  ET.effective_start_date          = START_OF_TIME
       and  ET.effective_end_date            = END_OF_TIME;
   --
   -- Retrieves the element link that makes the initial balance feed eligible.
   --
   cursor csr_element_link
     (
      p_business_group_id number
     ,p_element_type_id   number
     )  is
     select EL.element_link_id
     from   pay_element_links_f EL
     where  EL.business_group_id         = p_business_group_id
       and  EL.element_type_id           = p_element_type_id
       and  EL.link_to_all_payrolls_flag = 'Y'
       and  EL.payroll_id                is null
       and  EL.job_id                    is null
       and  EL.position_id               is null
       and  EL.people_group_id           is null
       and  EL.organization_id           is null
       and  EL.grade_id                  is null
       and  EL.pay_basis_id              is null
       and  EL.employment_category       is null
       and  EL.effective_start_date      = START_OF_TIME
       and  EL.effective_end_date        = END_OF_TIME;
   --
   -- Record to hold balance information.
   --
   l_balance_rec    csr_balance%rowtype;
   --
   -- Holds the element type used by the initial balance feed.
   --
   l_ele_type_id    number;
   l_jurisdiction_level number;
   --
   -- Holds the element link that provides the eligibility for the element
   -- type used by the initial balance feed.
   --
   l_ele_link_id    number;
   --
   -- Variables to cache details of the current balance being validated.
   --
   l_bal_id         pay_balance_batch_lines.balance_type_id%type;
   l_bal_name       pay_balance_batch_lines.balance_name%type;
   l_bal_invld      boolean := FALSE;
   l_bal_invl_feed  boolean := FALSE;
   l_bal_invl_link  boolean := FALSE;
   l_bal_vald_rec   t_balance_validation_rec;
   l_ibf_input_value_id number;
   l_jc_input_value_id  number;
   --
   -- Variables used to control the search through list of previously
   -- validated balances.
   --
   l_index          number  := 0;
   l_bal_index      number;
   l_balance_found  boolean := FALSE;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.validate_balance');
   --
   -- Search through list of balances that have already been validated NB. the
   -- list of balances is held in a PLSQL table.
   --
   for l_index in 1..g_bal_vald.count loop
     --
     -- See if the balance is in the list NB. the balance_type_id overrides the
     -- balance_name. If the balance is found then the flag is set and the
     -- search index points to the matching entry.
     --
     if ((p_batch_line_rec.balance_type_id
           = g_bal_vald(l_index).balance_type_id)    or
         (p_batch_line_rec.balance_type_id is null and
          upper(p_batch_line_rec.balance_name)
           = g_bal_vald(l_index).balance_name)) then
       l_balance_found := TRUE;
       l_bal_index := l_index;
       exit;
     end if;
     --
   end loop;
   --
   -- Balance has already been validated.
   --
   if l_balance_found then
     --
     -- Values must be the same as those for the balance when it was validated.
     --
     l_bal_id        := g_bal_vald(l_bal_index).balance_type_id;
     l_bal_name      := g_bal_vald(l_bal_index).balance_name;
     l_bal_invld     := g_bal_vald(l_bal_index).bal_invld;
     l_bal_invl_feed := g_bal_vald(l_bal_index).bal_invl_feed;
     l_bal_invl_link := g_bal_vald(l_bal_index).bal_invl_link;

     p_bal_vald_rec  := g_bal_vald(l_bal_index);
   --
   -- Balance is new ie. has not been found already. The balance must be
   -- validated and added to the list of validated balances.
   --
   else
     --
     -- See if the balance exists. If it does not then cache the old values
     -- else cache the new values (for subsequent checks) NB. a balance
     -- that does not exist cannot be validated any further.
     --
     open csr_balance(p_glbl_data_rec.business_group_id
		     ,p_glbl_data_rec.legislation_code
                     ,p_batch_line_rec.balance_type_id
                     ,p_batch_line_rec.balance_name);
     fetch csr_balance into l_balance_rec;
     if csr_balance%notfound then
       l_bal_id         := p_batch_line_rec.balance_type_id;
       l_bal_name       := p_batch_line_rec.balance_name;
       l_bal_invld      := TRUE;
     else
       l_bal_id         := l_balance_rec.balance_type_id;
       l_bal_name       := l_balance_rec.balance_name;
     end if;
     close csr_balance;
     --
     -- Balance exists so continue validation.
     --
     if not l_bal_invld then
       --
       -- See if the balance has an initial balance feed.
       --
       open  csr_initial_balance_feed(p_glbl_data_rec.business_group_id
                                     ,p_glbl_data_rec.legislation_code
                                     ,l_bal_id);
       fetch csr_initial_balance_feed into l_ele_type_id
                                          ,l_jurisdiction_level
                                          ,l_ibf_input_value_id
                                          ,l_jc_input_value_id;
       if csr_initial_balance_feed%notfound then
	 l_bal_invl_feed := TRUE;
       end if;
       close csr_initial_balance_feed;
       --
       -- Balance has an initial balance feed so continue validation.
       --
       if not l_bal_invl_feed then
	 --
	 -- See if an element link exists for the element used for the initial
	 -- balance feed.
	 --
         open  csr_element_link(p_glbl_data_rec.business_group_id
                               ,l_ele_type_id);
         fetch csr_element_link into l_ele_link_id;
         if csr_element_link%notfound then
	   l_bal_invl_link := TRUE;
         end if;
         close csr_element_link;
	 --
       end if;
       --
     end if;
     --
     -- A new balance has been found so add it to the list of validated
     -- balances along with the results of the validation.
     --
     l_bal_vald_rec.balance_type_id    := l_bal_id;
     l_bal_vald_rec.balance_name       := l_bal_name;
     l_bal_vald_rec.element_type_id    := l_ele_type_id;
     l_bal_vald_rec.element_link_id    := l_ele_link_id;
     l_bal_vald_rec.ibf_input_value_id := l_ibf_input_value_id;
     l_bal_vald_rec.jc_input_value_id  := l_jc_input_value_id;
     l_bal_vald_rec.jurisdiction_level := l_jurisdiction_level;
     l_bal_vald_rec.bal_invld          := l_bal_invld;
     l_bal_vald_rec.bal_invl_feed      := l_bal_invl_feed;
     l_bal_vald_rec.bal_invl_link      := l_bal_invl_link;

     -- should avoid the case where both ID and name are null
     if not (l_bal_id is null and l_bal_name is null) then
       --
       l_bal_index := g_bal_vald.count+1;
       g_bal_vald(l_bal_index) := l_bal_vald_rec;
     end if;
     --
     p_bal_vald_rec  := l_bal_vald_rec;
     --
   end if;
   --
   -- Check each error flag and write out message for each failure against the
   -- batch line being validated.
   --
   -- Balance does not exist.
   --
   if l_bal_invld then
     write_message_line
     (p_meesage_level => LINE
     ,p_batch_id      => null
     ,p_batch_line_id => p_batch_line_rec.batch_line_id
     ,p_message_text  => null
     ,p_message_token => 'HR_51049_BLT_DOES_NOT_EXIST');
   end if;
   --
   -- Balance does not have an initial balance feed.
   --
   if l_bal_invl_feed then
     write_message_line
     (p_meesage_level => LINE
     ,p_batch_id      => null
     ,p_batch_line_id => p_batch_line_rec.batch_line_id
     ,p_message_text  => null
     ,p_message_token => 'HR_51050_BLF_NO_INI_FEED');
   end if;
   --
   -- Balance does not have an element link for its initial balance feed.
   --
   if l_bal_invl_link then
     write_message_line
     (p_meesage_level => LINE
     ,p_batch_id      => null
     ,p_batch_line_id => p_batch_line_rec.batch_line_id
     ,p_message_text  => null
     ,p_message_token => 'HR_51051_ELI_NO_INI_BAL_LINK');
   end if;
   --
   -- Update the batch line with the balance information.
   --
   p_batch_line_rec.balance_type_id := l_bal_id;
   p_batch_line_rec.balance_name    := l_bal_name;
   --
   -- At least one of the tests has failed so mark the batch line as invalid.
   --
   if l_bal_invld     or
      l_bal_invl_feed or
      l_bal_invl_link then
     p_batch_line_rec.batch_line_status := 'E';  -- Error
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.validate_balance');
   --
 end validate_balance;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_assignment
  -- PURPOSE
  --  Ensures that the assignment on the batch line is valid.
  -- ARGUMENTS
  --  p_glbl_data_rec  - global data structure.
  --  p_batch_line_rec - the current batch line.
  --  p_asg_id         - assignment_id
  --  p_asg_number     - assignment_number
  --  p_asg_invld      - does the assignment exist ?
  --  p_asg_invld_type - is it an employee assignment ?
  --  p_asg_invld_pyrl - does it belong to the payroll specified in the batch ?
  --  p_asg_too_short  - is it assigned to the payroll for sufficent time ?
  --  p_asg_processed  - has it been processed before the upload date ?
  -- USES
  --  write_message_line
  -- NOTES
  --  Ensures that
  --   1. the assignment exists
  --   2. it is an employee assignment
  --   3. it is assigned to the payroll
  --   4. it has not been processed before the upload date
  -----------------------------------------------------------------------------
 --
 procedure validate_assignment
 (
  p_glbl_data_rec  in            glbl_data_rec_type
 ,p_batch_line_rec in out nocopy csr_batch_line_validate%rowtype
 ,p_asg_id         in out nocopy pay_balance_batch_lines.assignment_id%type
 ,p_asg_number     in out nocopy pay_balance_batch_lines.assignment_number%type
 ,p_asg_invld      in out nocopy boolean
 ,p_asg_invld_type in out nocopy boolean
 ,p_asg_invld_pyrl in out nocopy boolean
 ,p_asg_too_short  in out nocopy boolean
 ,p_asg_processed  in out nocopy boolean
 ) is
   --
   -- Retrieves assignment information NB. either the assignment_id or
   -- assignment_number may have been specified. If both are specified then
   -- the assignment_id overrides the assignment_number. A constraint on the
   -- batch lines table ensures that at least one of them is set.
   --
   cursor csr_assignment
     (
      p_business_group_id number
     ,p_assignment_id     number
     ,p_assignment_number varchar2
     ,p_upload_date       date
     )  is
     select ASG.assignment_id
	   ,upper(ASG.assignment_number) assignment_number
	   ,ASG.assignment_type
	   ,ASG.business_group_id
	   ,ASG.payroll_id
	   ,ASG.effective_start_date
     from   per_all_assignments_f ASG
     where  p_assignment_id         is not null
       and  ASG.business_group_id + 0 = p_business_group_id
       and  ASG.assignment_id     = p_assignment_id
       and  p_upload_date   between ASG.effective_start_date
			        and ASG.effective_end_date
     union all
     select ASG.assignment_id
	   ,upper(ASG.assignment_number) assignment_number
	   ,ASG.assignment_type
	   ,ASG.business_group_id
	   ,ASG.payroll_id
	   ,ASG.effective_start_date
     from   per_all_assignments_f ASG
     where  p_assignment_id         is null
       and  ASG.business_group_id + 0 = p_business_group_id
       and  ASG.assignment_number = p_assignment_number
       and  p_upload_date   between ASG.effective_start_date
			        and ASG.effective_end_date;
   --
   -- Retrieves the assignment actions for an assignment that exist before the
   -- upload date.

   -- Bug # 6997838.
   -- If BEE is already run for this assignment, we can still consider that
   -- assignment for balance Initialization as it does not contribute to balance.
   -- This cursor needs to  be changed in future to consider only SEQUENCED
   -- actions as only SEQUENCED actions contribute to balances.

   cursor csr_assignment_action
     (
      p_assignment_id number
     )  is
     select AA.payroll_action_id
     from   pay_assignment_actions AA, pay_payroll_actions PAA
     where  AA.assignment_id      = p_assignment_id
     and    PAA.payroll_action_id = AA.payroll_action_id
     and    PAA.action_type <> 'BEE';
   --
   -- Record to hold assignment information.
   --
   l_assignment_rec csr_assignment%rowtype;
   --
   -- Holds the payroll action the assignment was processed with.
   --
   l_pay_act_id     number;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.validate_assignment');
   --
   -- Assignment has already been validated, so there is no need to do the
   -- validation again NB. the assignment_id overrides the assignment_number.
   --
   if ((p_batch_line_rec.assignment_id              is not null    and
        p_batch_line_rec.assignment_id            = p_asg_id)      or
       (p_batch_line_rec.assignment_id              is null        and
        upper(p_batch_line_rec.assignment_number) = p_asg_number)) then
     --
     -- Do nothing.
     --
     null;
   --
   -- Assignment has not been validated yet, so validate it.
   --
   else
     --
     -- Reset the error flags.
     --
     p_asg_invld      := FALSE;
     p_asg_invld_type := FALSE;
     p_asg_invld_pyrl := FALSE;
     p_asg_too_short  := FALSE;
     p_asg_processed  := FALSE;
     --
     -- See if the assignment exists. If it does not then cache the old values
     -- else cache the new values (for subsequent checks) NB. an assignment
     -- that does not exist cannot be validated any further.
     --
     open  csr_assignment(p_glbl_data_rec.business_group_id
			 ,p_batch_line_rec.assignment_id
			 ,p_batch_line_rec.assignment_number
			 ,p_glbl_data_rec.upload_date);
     fetch csr_assignment into l_assignment_rec;
     if csr_assignment%notfound then
       p_asg_id         := p_batch_line_rec.assignment_id;
       p_asg_number     := p_batch_line_rec.assignment_number;
       p_asg_invld      := TRUE;
     else
       p_asg_id         := l_assignment_rec.assignment_id;
       p_asg_number     := l_assignment_rec.assignment_number;
     end if;
     close csr_assignment;
     --
     -- Assignment exists so continue validation.
     --
     if not p_asg_invld then
       --
       -- It is not an employee assignment.
       --
       if l_assignment_rec.assignment_type <> 'E' then
         p_asg_invld_type := TRUE;
       end if;
       --
       -- Assignment does not belong to the payroll for the batch NB. the
       -- assignment cannot be validated any further.
       --
       if l_assignment_rec.payroll_id = p_glbl_data_rec.payroll_id then
         -- OK.
         null;
       else
         p_asg_invld_pyrl := TRUE;
       end if;
       --
       -- Assignment has already been processed before the upload date.
       --
       open  csr_assignment_action(p_asg_id);
       fetch csr_assignment_action into l_pay_act_id;
       if csr_assignment_action%found then
	 p_asg_processed := TRUE;
       end if;
       close csr_assignment_action;
     --
     -- Assignment does not exist so stop validation.
     --
     else
       --
       -- Do nothing.
       --
       null;
       --
     end if;
     --
   end if;
   --
   -- Check each error flag and write out message for each failure against the
   -- batch line being validated.
   --
   -- Assignment does not exist.
   --
   if p_asg_invld then
     write_message_line
     (p_meesage_level => LINE
     ,p_batch_id      => null
     ,p_batch_line_id => p_batch_line_rec.batch_line_id
     ,p_message_text  => null
     ,p_message_token => 'PAY_7702_PDT_VALUE_NOT_FOUND');
   end if;
   --
   -- Assignment must be an employee assignment
   --
   if p_asg_invld_type then
     write_message_line
     (p_meesage_level => LINE
     ,p_batch_id      => null
     ,p_batch_line_id => p_batch_line_rec.batch_line_id
     ,p_message_text  => null
     ,p_message_token => 'HR_51052_ASG_MUST_BE_AN_EMP');
   end if;
   --
   -- Assignment does not belong to the payroll specified in the batch header.
   --
   if p_asg_invld_pyrl then
     write_message_line
     (p_meesage_level => LINE
     ,p_batch_id      => null
     ,p_batch_line_id => p_batch_line_rec.batch_line_id
     ,p_message_text  => null
     ,p_message_token => 'HR_7789_SETUP_ASG_HAS_NO_PAYR'
     ,p_token_name    => 'ADJ_DATE'
     ,p_token_value   => to_char(p_glbl_data_rec.upload_date)
     );
   end if;
   --
   -- Assignment has already been processed before the upload date.
   --
   if p_asg_processed and p_glbl_data_rec.purge_mode then
     -- Processed error but we are purging, so ignore
     p_asg_processed := FALSE;
   end if;
   --
   if p_asg_processed then
     write_message_line
     (p_meesage_level => LINE
     ,p_batch_id      => null
     ,p_batch_line_id => p_batch_line_rec.batch_line_id
     ,p_message_text  => null
     ,p_message_token => 'HR_51053_ASA_PREV_PROCESSED');
   end if;
   --
   -- Update the batch line with the assignment information.
   --
   p_batch_line_rec.assignment_id     := p_asg_id;
   p_batch_line_rec.assignment_number := p_asg_number;
   --
   -- At least one of the tests has failed so mark the batch line as invalid.
   --
   if p_asg_invld      or
      p_asg_invld_type or
      p_asg_invld_pyrl or
      p_asg_processed  then
     p_batch_line_rec.batch_line_status := 'E';  -- Error
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.validate_assignment');
   --
 end validate_assignment;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
  --  Ensures that all the batch lines for a batch are valid NB. it also
  --  populates the system IDs where necessary.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  --  validate_assignment
  --  validate_balance
  --  validate_dimension
  -- NOTES
  --  All lines that have not been transferred are validated. Multiple errors
  --  may be reported against each line ie. the assignment and dimension may
  --  both be invalid.
  -----------------------------------------------------------------------------
 --
 procedure validate_batch_lines
 (
  p_glbl_data_rec in glbl_data_rec_type
 ) is
   --
   -- Record to hold a batch line NB. the cursor is defined at package level.
   --
   l_batch_line_rec csr_batch_line_validate%rowtype;
   --
   -- Variables to cache details of the previously validated assignment. This
   -- can be used bu the validate_assignment procedure when validating future
   -- assignments.
   --
   l_asg_id         pay_balance_batch_lines.assignment_id%type;
   l_asg_number     pay_balance_batch_lines.assignment_number%type;
   l_asg_invld      boolean := FALSE;
   l_asg_invld_type boolean := FALSE;
   l_asg_invld_pyrl boolean := FALSE;
   l_asg_too_short  boolean := FALSE;
   l_asg_processed  boolean := FALSE;
   --
   -- Balance validation details returned from validate_balance.
   -- This will be reused in validate_dimension.
   --
   l_bal_vald_rec   t_balance_validation_rec;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.validate_batch_lines');
   --
   -- Clear the validation cache.
   --
   g_bal_vald.delete;
   g_dim_vald.delete;
   --
   open csr_batch_line_validate(p_glbl_data_rec.batch_id);
   --
   -- Loop for all the batch lines in the batch.
   --
   loop
     --
     -- Get the next batch line NB. exit the loop when all batch lines have
     -- been retrieved NB. the batch lines are ordered by assignment_id and
     -- then assignment_number. This ensures that all the batch lines for each
     -- assignment are contiguous which allows the validation to be optimised.
     --
     fetch csr_batch_line_validate into l_batch_line_rec;
     exit when csr_batch_line_validate%notfound;
     --
     -- Default the status to valid NB. this will be changed to invalid by
     -- any failures during validation.
     --
     l_batch_line_rec.batch_line_status := 'V';
     --
     -- Check the assignment on the batch line.
     --
     validate_assignment(p_glbl_data_rec
                        ,l_batch_line_rec
                        ,l_asg_id
                        ,l_asg_number
                        ,l_asg_invld
			,l_asg_invld_type
                        ,l_asg_invld_pyrl
                        ,l_asg_too_short
			,l_asg_processed);
     --
     -- Check the balance on the batch line.
     --
     validate_balance(p_glbl_data_rec
                     ,l_batch_line_rec
                     ,l_bal_vald_rec);
     --
     -- Check the dimension on the batch line.
     --
     validate_dimension(p_glbl_data_rec
                       ,l_batch_line_rec
                       ,l_bal_vald_rec);
     --
     -- Validate upload dates
     --
     if (l_batch_line_rec.upload_date is not null) then
       if (l_batch_line_rec.upload_date > p_glbl_data_rec.upload_date) then
         write_message_line
         (p_meesage_level => LINE
         ,p_batch_id      => null
         ,p_batch_line_id => l_batch_line_rec.batch_line_id
         ,p_message_text  => null
         ,p_message_token => 'PAY_33254_BAL_INV_BL_UPL_DATE');
         l_batch_line_rec.batch_line_status := 'E';  -- Error
       end if;
     end if;
     --
     -- Update the batch line with information retrieved during validation
     -- ie. if the assignment_number was set on a batch line then the
     -- assiugnment_id is derived etc...
     --
     update pay_balance_batch_lines BL
     set    BL.assignment_number    = l_batch_line_rec.assignment_number
           ,BL.assignment_id        = l_batch_line_rec.assignment_id
           ,BL.balance_name         = l_batch_line_rec.balance_name
           ,BL.balance_type_id      = l_batch_line_rec.balance_type_id
           ,BL.dimension_name       = l_batch_line_rec.dimension_name
           ,BL.balance_dimension_id = l_batch_line_rec.balance_dimension_id
           ,BL.gre_name             = l_batch_line_rec.gre_name
           ,BL.tax_unit_id          = l_batch_line_rec.tax_unit_id
           ,BL.jurisdiction_code    = l_batch_line_rec.jurisdiction_code
           ,BL.original_entry_id    = l_batch_line_rec.original_entry_id
           ,BL.source_id            = l_batch_line_rec.source_id
           ,BL.source_text          = l_batch_line_rec.source_text
           ,BL.source_number        = l_batch_line_rec.source_number
           ,BL.source_text2         = l_batch_line_rec.source_text2
           ,BL.run_type_id          = l_batch_line_rec.run_type_id
	   ,BL.batch_line_status    = l_batch_line_rec.batch_line_status
     where  current of csr_batch_line_validate;
     --
   end loop;
   --
   close csr_batch_line_validate;
   --
   hr_utility.trace('Exiting pay_balance_upload.validate_batch_lines');
   --
 end validate_batch_lines;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch
  -- PURPOSE
  --  Ensures that all the batch information is valid.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  --  validate_batch_header
  --  validate_batch_lines
  -- NOTES
  --  If the batch header is in error then there is no point in continuing
  --  with the validation of the batch lines.
  -----------------------------------------------------------------------------
 --
 procedure validate_batch
 (
  p_glbl_data_rec in out nocopy glbl_data_rec_type
 ) is
   --
   -- Dynamic sql variables
   --
   sql_curs          number;
   rows_processed    integer;
   statem            varchar2(512);
   l_validation_supp varchar2(30);
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.validate_batch');
   --
   -- Ensure the batch header is valid.
   --
   validate_batch_header(p_glbl_data_rec);
   --
   -- Populate the batch info.
   --
   g_batch_info.batch_id          := p_glbl_data_rec.batch_id;
   g_batch_info.business_group_id := p_glbl_data_rec.business_group_id;
   g_batch_info.legislation_code  := p_glbl_data_rec.legislation_code;
   g_batch_info.purge_mode        := p_glbl_data_rec.purge_mode;

   --
   -- If the batch header is valid then ensure the batch lines are valid.
   --
   if p_glbl_data_rec.batch_header_status = 'V' then
     --
     -- General validation ie. is the data valid ?
     --
     validate_batch_lines(p_glbl_data_rec);
     --
     -- UK specific validation.
     --
     if p_glbl_data_rec.legislation_code = 'GB' then
       pay_uk_bal_upload.validate_batch_lines(p_glbl_data_rec.batch_id);
     --
     -- Other legislation validation.
     --
     else
       --
       --
       -- Check the legislation rule BAL_INIT_VALIDATION which determines if the legislation
       -- supports additional validation for the batches. The rule is interpreted as follows -
       --
       -- No rule                     - call legislation specific validation.
       -- Rule exists with NULL value - call legislation specific validation.
       -- Rule exists with Y value    - call legislation specific validation.
       -- Rule exists with N value    - do not call legislation specific validation.
       --
       -- Up until now every legislation has provided a package for this. This change is being
       -- introduced to support legislations setup using the International Payroll functionality
       -- where we have no pre-determined knowledge of which legislations will be used and
       -- therefore cannot guarantee that a package will exist.
       --
       begin
         select nvl(rule_mode, 'N')
         into   l_validation_supp
         from   pay_legislation_rules
         where  legislation_code = p_glbl_data_rec.legislation_code
           and  rule_type        = 'BAL_INIT_VALIDATION';
       exception
         when no_data_found then
           l_validation_supp := 'Y';
       end;
       --
       --
       -- Batch validation is supported for the legislation so call relevant package.
       --
       if l_validation_supp = 'Y' then
         --
         statem := 'BEGIN
           pay_'||lower(p_glbl_data_rec.legislation_code)||'_bal_upload.validate_batch_lines
                (:p_batch_id); END;';
         --
         execute immediate statem
           using p_glbl_data_rec.batch_id;
         --
       end if;
     end if;
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.validate_batch');
   --
 end validate_batch;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  transfer_assignment
  -- PURPOSE
  --  Transfers all the batch lines for an assiugnment onto the system ie.
  --  creates balance adjustments to produce the correct initial balances as
  --  specified by the batch lines for the assignment.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  --  calculate_adjustment
  --  apply_adjustments
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure transfer_assignment
 (
  p_glbl_data_rec in     glbl_data_rec_type
 ) is
   --
   -- Record to hold a batch line NB. the cursor is defined at package level.
   --
   l_batch_line_rec csr_batch_line_transfer%rowtype;
   --
   -- Holds information about which batch lines are currently being processed
   -- along with an error message to be reported agai9nst those batch lines.
   --
   l_batch_line_list number_array;
   l_num_lines       number := 0;
   l_message         varchar2(240);
   --
   -- An indicator that shows if the assignment is transferable ie. all its
   -- batch lines are valid.
   --
   l_asg_valid       boolean := FALSE;
   --
   conflicts         number := 0;
   --
   -- current number of cached payroll actions
   l_payroll_action_num   number := g_payroll_actions.count;
   --
   cursor csr_conflicts
   is
   select distinct TBA1.batch_line_id
   from pay_temp_balance_adjustments TBA1,
        pay_temp_balance_adjustments TBA2,
        pay_balance_types            BT
   where TBA1.batch_line_id <> TBA2.batch_line_id
     and TBA1.adjustment_date = TBA2.adjustment_date
     and TBA1.balance_type_id = TBA2.balance_type_id
     and TBA1.adjustment_amount <> 0
     and TBA2.adjustment_amount <> 0
     and nvl(TBA1.tax_unit_id, -1) = nvl(TBA2.tax_unit_id, -1)
     and nvl(TBA1.run_type_id, -1) = nvl(TBA2.run_type_id, -1)
     and nvl(TBA1.original_entry_id, -1) = nvl(TBA2.original_entry_id, -1)
     and nvl(TBA1.source_id, -1) = nvl(TBA2.source_id, -1)
     and nvl(TBA1.source_text, '~null~') = nvl(TBA2.source_text, '~null~')
     and nvl(TBA1.source_number, -1) = nvl(TBA2.source_number, -1)
     and nvl(TBA1.source_text2, '~null~') = nvl(TBA2.source_text2, '~null~')
     and BT.balance_type_id = TBA1.balance_type_id
     and nvl(substr(TBA1.jurisdiction_code,1,BT.jurisdiction_level), -1) =
         nvl(substr(TBA2.jurisdiction_code,1,BT.jurisdiction_level), -1);
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.transfer_assignment');
   --
   open csr_batch_line_transfer(p_glbl_data_rec.batch_id
			       ,p_glbl_data_rec.assignment_id);
   --
   -- Set a savepoint indicating the start of processing for an assignment.
   --
   savepoint assignment_savepoint;
   --
   loop
     --
     -- Get the next batch line for the assignment.
     --
     fetch csr_batch_line_transfer into l_batch_line_rec;
     hr_utility.trace('BATCH_LINE_ID = '||l_batch_line_rec.batch_line_id);
     hr_utility.trace('EXPIRY_DATE = '||l_batch_line_rec.expiry_date);
     --
     -- Terminate the loop either if there are no more batch lines to process
     -- or the batch line has been transferred already or is invalid. The
     -- transfer of the batch lines for an assignment will only continue if all
     -- the batch lines are valid. The batch lines are retrieved in such an
     -- order that the transferred and invalid lines appear first. This means
     -- that the first batch line indicates whether the transfer can continue
     -- ie. if the first batch line is valid then all the batch lines are valid.
     --
     exit  when (l_batch_line_rec.batch_line_status in ('E','T') or
		 csr_batch_line_transfer%notfound);
     --
     -- Set an indicator to acknowledge that the assignment is valid ie. all
     -- the batch lines for the assignment are valid. This is confirmed by
     -- getting past the previous check used with the exit condition of the
     -- loop.
     --
     l_asg_valid := TRUE;
     --
     -- Calculate the balance adjustment required to set the initial balance
     -- as specified by the batch line. Store the details about the balance
     -- adjustment for later use.
     --
     l_num_lines                    := 1;
     l_batch_line_list(l_num_lines) := l_batch_line_rec.batch_line_id;
     calculate_adjustment(p_glbl_data_rec
                         ,l_batch_line_rec);
     --
   end loop;
   --
   close csr_batch_line_transfer;
   --
   -- Check if adjustment dates are valid ie different dimensions of same
   -- balance adjusted on same day.
   --
   -- Bug 3604595. Reset the batch line list for balance conflict lines.
   --
   conflicts                      := 0;
   l_num_lines                    := 0;
   l_batch_line_list.delete;

   for l_conflict_adj in csr_conflicts loop

     conflicts                      := conflicts+1;
     l_num_lines                    := l_num_lines+1;
     l_batch_line_list(l_num_lines) := l_conflict_adj.batch_line_id;

   end loop;
    --
   if conflicts <> 0 then
     hr_utility.set_message(801, 'PAY_52152_INV_ASS_BALS');
     raise hr_utility.hr_error;
   end if;
   --
   -- Create all the balance adjustments for the assignment which will set the
   -- initial balances as specified by the batch lines for that assignment.
   --
   if l_asg_valid then
     apply_adjustments(p_glbl_data_rec
                      ,l_batch_line_list
                      ,l_num_lines
                      );
     --
     -- Now load the latest balances for this assignment.
     --
     if not p_glbl_data_rec.purge_mode then
       load_latest_asg_balances(p_glbl_data_rec
                               ,l_batch_line_list
                               ,l_num_lines);
     end if;
   end if;
   --
   -- The process is running in VALIDATION mode so the balance adjustments
   -- were created as a what if question. Must ensure that they are rolled
   -- back.
   --
   if p_glbl_data_rec.upload_mode = 'VALIDATE' then
     rollback to assignment_savepoint;
     -- remove the payroll actions cache
     g_payroll_actions.delete(l_payroll_action_num+1,g_payroll_actions.count);
   end if;
   --
   --
   delete from pay_temp_balance_adjustments;
   --
   hr_utility.trace('Exiting pay_balance_upload.transfer_assignment');
 --
 -- The transfer has failed.
 --
 exception
   when hr_utility.hr_error then
     --
     -- Close the batch line cursor if it is open.
     --
     if csr_batch_line_transfer%isopen then
       close csr_batch_line_transfer;
     end if;
     --
     -- Extract the error message.
     --
     l_message := substrb(nvl(hr_utility.get_message, sqlerrm), 1, 240);
     --
     -- Undo all the work relating to the assignment.
     --
     rollback to assignment_savepoint;
     -- remove the payroll actions cache
     g_payroll_actions.delete(l_payroll_action_num+1,g_payroll_actions.count);
     --
     -- Write out the error message against all the batch lines that were
     -- being processed when the error occured NB. this could be more than one
     -- when several batch lines were being set on one balance adjustment.
     --
     for l_index in 1..l_num_lines loop
       --
       -- Write the message against each line that has failed.
       --
       write_message_line
       (p_meesage_level => LINE
       ,p_batch_id      => null
       ,p_batch_line_id => l_batch_line_list(l_index)
       ,p_message_text  => l_message
       ,p_message_token => null);
       --
       -- Mark each batch line as invalid.
       --
       update pay_balance_batch_lines BL
       set    BL.batch_line_status        = 'E'  -- Error
       where  BL.batch_line_id = l_batch_line_list(l_index);
       --
     end loop;
     --
     delete from pay_temp_balance_adjustments;
     --
   when others then
     --
     hr_utility.trace(sqlerrm);
     --
     -- Extract the error message.
     --
     l_message := substrb(sqlerrm, 1, 240);
     -- Close the batch line cursor if it is open.
     --
     if csr_batch_line_transfer%isopen then
       close csr_batch_line_transfer;
     end if;
     --
     --
     -- Undo all the work relating to the assignment.
     --
     rollback to assignment_savepoint;
     -- remove the payroll actions cache
     g_payroll_actions.delete(l_payroll_action_num+1,g_payroll_actions.count);
     --
     for l_index in 1..l_num_lines loop
       --
       -- Write the message against each line that has failed.
       --
       write_message_line
       (p_meesage_level => LINE
       ,p_batch_id      => null
       ,p_batch_line_id => l_batch_line_list(l_index)
       ,p_message_text  => l_message
       ,p_message_token => null);
       --
       -- Mark each batch line as invalid.
       --
       update pay_balance_batch_lines BL
       set    BL.batch_line_status        = 'E'  -- Error
       where  BL.batch_line_id = l_batch_line_list(l_index);
       --
     end loop;
     --
     delete from pay_temp_balance_adjustments;
     --
 end transfer_assignment;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  transfer_batch
  -- PURPOSE
  --  Transfers a batch onto the system ie. creates balance adjustments to
  --  produce the correct initial balances as specified in the batch.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  --  cache_balances
  --  transfer_assignment
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure transfer_batch
 (
  p_glbl_data_rec in out nocopy glbl_data_rec_type
 ) is
   --
   -- Retrieves all the assignments found in a batch NB. each batch line is for
   -- an assignment.
   --
   cursor csr_assignment
     (
      p_batch_id          number
     ,p_effective_date    date
     ,p_business_group_id number
     ,p_payroll_id        number
     )  is
     select /*+ ORDERED
                INDEX(ASG PER_ASSIGNMENTS_F_PK)*/
            distinct ASG.assignment_id
     from   pay_balance_batch_lines BL,
            per_all_assignments_f ASG
     where  BL.batch_id      = p_batch_id
       and  BL.assignment_id = ASG.assignment_id
       and  ASG.business_group_id = p_business_group_id
       and  ASG.payroll_id + 0    = p_payroll_id
       and  p_effective_date  between ASG.effective_start_date
				  and ASG.effective_end_date;
   --
   -- Keeps a count of the number of assignments that have been processed.
   --
   l_asg_count    number := 0;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.transfer_batch');
   --
   -- Cache the initial balance feed information for each balance found in
   -- the batch.
   --
   cache_balances;
   --
   open csr_assignment(p_glbl_data_rec.batch_id
                      ,p_glbl_data_rec.upload_date
                      ,p_glbl_data_rec.business_group_id
                      ,p_glbl_data_rec.payroll_id);
   --
   -- Repeat for each assignment in the batch.
   --
   loop
     --
     -- Get the next assignment.
     --
     fetch csr_assignment into p_glbl_data_rec.assignment_id;
     exit  when csr_assignment%notfound;
     hr_utility.trace('ASG = '||p_glbl_data_rec.assignment_id);
     --
     -- Keep a count of the number of assignments that have been processed.
     --
     l_asg_count := l_asg_count + 1;
     --
     -- Calculate the balance adjustments required to set the initial balances
     -- for the assignment and then create the balance adjustments.
     --
     transfer_assignment(p_glbl_data_rec);

     --
     -- Commit after every x assignments.
     --
     if mod(l_asg_count, p_glbl_data_rec.chunk_size) = 0 then
       if not p_glbl_data_rec.purge_mode then
         commit;
         -- We need relock the batch header.
         lock_batch_header(p_glbl_data_rec.batch_id);
       end if;
     end if;
     --
   end loop;
   --
   close csr_assignment;
   --
   -- If there are any outstanding assignments that have not been committed
   -- then commit them.
   --
   if mod(l_asg_count, p_glbl_data_rec.chunk_size) <> 0 then
     if not p_glbl_data_rec.purge_mode then
       commit;
       -- We need relock the batch header.
       lock_batch_header(p_glbl_data_rec.batch_id);
     end if;
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.transfer_batch');
   --
 end transfer_batch;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  undo_transfer_batch
  -- PURPOSE
  --  Rolls back all the balance adjustments made to set the initial values of
  --  the balances within the batch.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  --  py_rollback_pkg.rollback_payroll_action
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure undo_transfer_batch
 (
  p_glbl_data_rec in     glbl_data_rec_type
 ) is
   --
   -- Record to hold a batch line NB. the cursor is defined at package level.
   --
   l_batch_line_rec csr_batch_line_undo_transfer%rowtype;
   --
   -- Setup variables to hold the payroll action id and assignment id.
   --
   l_pyrl_act_id    number;
   l_asg_id         number;
   l_asg_count      number;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.undo_transfer_batch');
   --
   l_asg_count := 0;
   --
   open csr_batch_line_undo_transfer(p_glbl_data_rec.batch_id);
   --
   -- Get the first transferred batch line.
   --
   fetch csr_batch_line_undo_transfer into l_batch_line_rec;
   --
   -- At least one transferred batch line exists.
   --
   if csr_batch_line_undo_transfer%found then
     --
     -- Keep track of the payroll action used to set the balance for the
     -- batch line.
     --
     l_asg_id      := l_batch_line_rec.assignment_id;
     l_pyrl_act_id := l_batch_line_rec.payroll_action_id;
     --
     loop
       --
       -- Get the next transferred batch line.
       --
       fetch csr_batch_line_undo_transfer into l_batch_line_rec;
       --
       -- New transferred batch line was not set using the same balance
       -- adjustment as the previous one.
       --
       if l_batch_line_rec.payroll_action_id <> l_pyrl_act_id or
  	  csr_batch_line_undo_transfer%notfound               then
         --
         -- Rollback the balance adjustment.
         --
         py_rollback_pkg.rollback_payroll_action(l_pyrl_act_id);
         --
         -- Reset the status of the batch lines for which the payroll action
	 -- has been rolled back.
         -- (#2676349) commented out the assignment condition in the
         --            where clause.
	 update pay_balance_batch_lines BL
	 set    BL.batch_line_status = 'U'
	       ,BL.payroll_action_id = null
         where  BL.batch_id = p_glbl_data_rec.batch_id
         --and  BL.assignment_id = l_asg_id
           and  BL.payroll_action_id = l_pyrl_act_id;
         --
       end if;
       --
       -- Stop when there are no more transferred batch lines.
       --
       exit when csr_batch_line_undo_transfer%notfound;
       --
       -- Check the chunk size for the commit unit.
       --
       if l_asg_id <> l_batch_line_rec.assignment_id then
          l_asg_count := l_asg_count + 1;
          if mod(l_asg_count, p_glbl_data_rec.chunk_size) = 0 then
            if not p_glbl_data_rec.purge_mode then
              commit;
            end if;
          end if;
       end if;
       --
       -- Keep track of the payroll action used to set the balance for the
       -- batch line.
       --
       l_pyrl_act_id := l_batch_line_rec.payroll_action_id;
       l_asg_id      := l_batch_line_rec.assignment_id;
       --
     end loop;
   --
   end if;
   --
   close csr_batch_line_undo_transfer;
   --
   if mod(l_asg_count, p_glbl_data_rec.chunk_size) <> 0 then
      if not p_glbl_data_rec.purge_mode then
        commit;
      end if;
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.undo_transfer_batch');
   --
 end undo_transfer_batch;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  purge_batch
  -- PURPOSE
  --  Removes all data associated with a batch.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure purge_batch
 (
  p_glbl_data_rec in     glbl_data_rec_type
 ) is
   --
   cursor csr_get_err_lines (p_batch_id in number)
   is
    select  BL.batch_line_id
    from   pay_balance_batch_lines BL
    where  BL.batch_id = p_batch_id
    and    BL.batch_line_status = 'E';
 --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.purge_batch');
   --
   -- Delete batch line messages.
   --
   for errline in csr_get_err_lines(p_glbl_data_rec.batch_id) loop
      delete from pay_message_lines ML
      where  ML.message_level = 'F'
        and  ML.source_type   = 'L'
        and  ML.source_id     = errline.batch_line_id;
   end loop;
   --
   -- Delete batch header messages.
   --
   delete from pay_message_lines ML
   where  ML.message_level = 'F'
     and  ML.source_type   = 'H'
     and  ML.source_id     = p_glbl_data_rec.batch_id;
   --
   -- Delete the batch lines for the batch.
   --
   delete from pay_balance_batch_lines BBL
   where  BBL.batch_id = p_glbl_data_rec.batch_id;
   --
   -- Delete the batch header.
   --
   delete from pay_balance_batch_headers BBH
   where  BBH.batch_id = p_glbl_data_rec.batch_id;
   --
   hr_utility.trace('Exiting pay_balance_upload.purge_batch');
   --
 end purge_batch;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  valid_latest_balance_run
  -- PURPOSE
  --  This ensures that only balance adjustments are performed for the
  --  assignments that the latest balances are to be created.
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 procedure valid_latest_balance_run
 (
  p_glbl_data_rec in     glbl_data_rec_type
 ) is
   --
   cursor csr_get_payroll_actions (p_payroll_id    in number,
                                   p_assignment_id in number)
   is
    select ppa.payroll_action_id
    from pay_payroll_actions    ppa,
         pay_assignment_actions paa
    where ppa.payroll_id = p_payroll_id
    and   ppa.action_type <> 'I'
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   paa.assignment_id = p_assignment_id;
 --
   tmp_payroll_act number;
 --
 begin
   open csr_get_payroll_actions(p_glbl_data_rec.payroll_id,
                                p_glbl_data_rec.assignment_id);
   fetch csr_get_payroll_actions into tmp_payroll_act;
   if csr_get_payroll_actions%notfound then
     close csr_get_payroll_actions;
     return;
   end if;
   --
   close csr_get_payroll_actions;
   hr_utility.set_message(801, 'HR_51053_ASA_PREV_PROCESSED');
   raise hr_utility.hr_error;
 end valid_latest_balance_run;
 --
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
 ) is
   --
   -- Declare the global data structure.
   --
   l_glbl_data_rec glbl_data_rec_type;
   l_asg_count     number := 0;
   l_batch_line_list number_array;
   l_num_lines       number := 0;
   --
   -- Retrieves all the assignments found in a batch NB. each batch line is for
   -- an assignment.
   --
   cursor csr_assignment
     (
      p_batch_id          number
     ,p_effective_date    date
     ,p_business_group_id number
     ,p_payroll_id        number
     )  is
     select /*+ ORDERED
                INDEX(ASG PER_ASSIGNMENTS_F_PK)*/
            distinct ASG.assignment_id
     from   pay_balance_batch_lines BL,
            per_all_assignments_f ASG
     where  BL.batch_id      = p_batch_id
       and  BL.assignment_id = ASG.assignment_id
       and  BL.batch_line_status = 'T'
       and  ASG.business_group_id = p_business_group_id
       and  ASG.payroll_id + 0    = p_payroll_id
       and  p_effective_date  between ASG.effective_start_date
                                  and ASG.effective_end_date;
   --
   cursor csr_batch_header
     (
      p_batch_id          number
     ) is
        select pbh.business_group_id,
               pbg.legislation_code,
               pbh.payroll_id
        from per_business_groups_perf pbg,
             pay_balance_batch_headers pbh
        where pbh.batch_id = p_batch_id
          and pbh.business_group_id = pbg.business_group_id;
 begin
   hr_utility.trace('Entering pay_balance_upload.load_latest_balances');
   --
   -- Freeze the batch while processing it and initialise the global data
   -- structure.
   --
   lock_batch('TRANSFER'
             ,p_batch_id
             ,l_glbl_data_rec);
   --
   open csr_batch_header(p_batch_id);
   fetch csr_batch_header into l_glbl_data_rec.business_group_id,
                               l_glbl_data_rec.legislation_code,
                               l_glbl_data_rec.payroll_id;
   close csr_batch_header;
   --
   open csr_assignment(l_glbl_data_rec.batch_id
                      ,l_glbl_data_rec.upload_date
                      ,l_glbl_data_rec.business_group_id
                      ,l_glbl_data_rec.payroll_id);
   --
   -- Repeat for each assignment in the batch.
   --
   loop
     --
     -- Get the next assignment.
     --
     fetch csr_assignment into l_glbl_data_rec.assignment_id;
     exit  when csr_assignment%notfound;
     --
     -- Keep a count of the number of assignments that have been processed.
     --
     l_asg_count := l_asg_count + 1;
     --
     -- Calculate the balance adjustments required to set the initial balances
     -- for the assignment and then create the balance adjustments.
     --
       valid_latest_balance_run(l_glbl_data_rec);
       load_latest_asg_balances(l_glbl_data_rec
                               ,l_batch_line_list
                               ,l_num_lines);
   end loop;
   --
   close csr_assignment;
   --
   -- If there are any outstanding assignments that have not been committed
   -- then commit them.
   --
   commit;
   --
   hr_utility.trace('Exiting pay_balance_upload.load_latest_balances');
 end load_latest_balances;
  -----------------------------------------------------------------------------
  -- NAME
  --  post_transfer_batch
  -- PURPOSE
  --  Performs the rest of tasks to complete the batch transfer.
  --
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  --  pay_bal_adjust.process_batch
  -- NOTES
  --
  -----------------------------------------------------------------------------
  --
  procedure post_transfer_batch
    (p_glbl_data_rec  in glbl_data_rec_type
    )
  is
    l_proc varchar2(80) := ' pay_balance_upload.post_transfer_batch';

    --
    -- Retrieves incomplete payroll actions.
    --
    cursor csr_batch
    is
    select
      distinct ppa.payroll_action_id
    from
      pay_payroll_actions     ppa
     ,pay_balance_batch_lines pbbl
    where
        ppa.action_status <> 'C'
    and ppa.payroll_action_id = pbbl.payroll_action_id
    and pbbl.batch_line_status = 'T'
    and pbbl.batch_id = p_glbl_data_rec.batch_id
    ;
  begin
    --
    hr_utility.set_location('Entering:'||l_proc, 5);

    if p_glbl_data_rec.upload_mode = 'TRANSFER' then

      for l_batch in csr_batch loop
        --
        hr_utility.trace('  payroll_action_id=:'||l_batch.payroll_action_id);
        --
        -- Completes the payroll action.
        --
        pay_bal_adjust.process_batch(l_batch.payroll_action_id);
        --
      end loop;

    end if;

    hr_utility.set_location('Leaving:'||l_proc, 50);

  end post_transfer_batch;

  -----------------------------------------------------------------------------
  -- NAME
  --  validate_transfer_batch
  -- PURPOSE
  --  Performs validation and transfer of the batch.
  --
  -- ARGUMENTS
  --  p_glbl_data_rec - global data structure.
  -- USES
  --  validate_batch
  --  transfer_batch
  --  post_transfer_batch
  -- NOTES
  --
  -----------------------------------------------------------------------------
  --
  procedure validate_transfer_batch
    (p_glbl_data_rec  in glbl_data_rec_type
    )
  is
    l_proc varchar2(80) := ' pay_balance_upload.validate_transfer_batch';
    l_message        varchar2(240);
    l_glbl_data_rec  glbl_data_rec_type:= p_glbl_data_rec;
  begin
    --
    hr_utility.set_location('Entering:'||l_proc, 5);

    --
    -- Validate the batch.
    --
    validate_batch(l_glbl_data_rec);

    --
    -- Reset the payroll actions cache.
    --
    g_payroll_actions.delete;

    --
    -- Transfer the batch NB. in 'VALIDATE' mode the transfer is done
    -- to see if the transfer would work. The transfer can only continue
    -- if the batch header is valid.
    --
    if l_glbl_data_rec.batch_header_status = 'V' then
      transfer_batch(l_glbl_data_rec);

      post_transfer_batch(l_glbl_data_rec);
    end if;

    --
    -- Set the status of the batch.
    --
    set_batch_status(l_glbl_data_rec);

    hr_utility.set_location('Leaving:'||l_proc, 50);
    --
  exception
    --
    -- Treats the exception trapped here as a batch header error.
    --
    when hr_utility.hr_error then
      hr_utility.set_location(l_proc, 55);

      l_message := substrb(nvl(hr_utility.get_message, sqlerrm), 1, 240);

      write_message_line
        (p_meesage_level => HEADER
        ,p_batch_id      => l_glbl_data_rec.batch_id
        ,p_batch_line_id => null
        ,p_message_text  => l_message
        ,p_message_token => null
        );

      update pay_balance_batch_headers
      set    batch_status = 'E'
      where  batch_id = l_glbl_data_rec.batch_id;

    when others then
      hr_utility.set_location(l_proc, 60);

      l_message := substrb(sqlerrm, 1, 240);

      write_message_line
        (p_meesage_level => HEADER
        ,p_batch_id      => l_glbl_data_rec.batch_id
        ,p_batch_line_id => null
        ,p_message_text  => l_message
        ,p_message_token => null
        );

      update pay_balance_batch_headers
      set    batch_status = 'E'
      where  batch_id = l_glbl_data_rec.batch_id;

  end validate_transfer_batch;
  -----------------------------------------------------------------------------
  -- NAME
  --  process
  -- PURPOSE
  --  Processes a batch of initial balances and will either validate the batch,
  --  transfer the initial balances to the system ,purge the batch or undo the
  --  transfer of a batch.
  -- ARGUMENTS
  --  errbuf     - error message string used by SRS.
  --  retcode    - return code for SRS, 0 - Success, 1 - Warning, 2 - Error.
  --  p_mode     - can be 'VALIDATE', 'TRANSFER', 'PURGE', or 'UNDO'.
  --  p_batch_id - identifies batch being processed.
  -- USES
  --  lock_batch
  --  validate_batch
  --  transfer_batch
  --  purge_batch
  --  undo_transfer_batch
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
 ) is
   --
   -- Declare the global data structure.
   --
   l_glbl_data_rec glbl_data_rec_type;
   --
   -- Indicates that an unsupported mode was passed.
   --
   l_invalid_mode  boolean := FALSE;
   --
   -- Status of Batch
   --
   l_batch_status varchar2(30);
   --
   -- Null batch record to initialize.
   --
   l_null_batch_info  t_batch_info_rec;
   --
 begin
   --
   hr_utility.trace('Entering pay_balance_upload.process');
   status_indicator := SRS_SUCCESS; -- Success
   g_legislation_code := null;
   --
   -- Reset the batch info.
   --
   g_batch_info := l_null_batch_info;
   --
   -- Check whether batch is currently being processed by another process
   -- by checking if batch header batch_status = 'L'.
   --
   select BBH.batch_status
   into l_batch_status
   from  pay_balance_batch_headers BBH
   where BBH.batch_id = p_batch_id;
   --
   if l_batch_status = 'L' then
     --
     -- Set the return code and message for SRS.
     --
     hr_utility.trace('pay_balance_upload.process: batch locked');
     status_indicator := SRS_ERROR; -- Error
     errbuf := 'Batch currently being processed by another process';
   else
     --
     -- Remove previous messages
     --
     remove_messages(p_batch_id);
     --
     -- Freeze the batch while processing it and initialise the global data
     -- structure.
     --
     lock_batch(p_mode
	       ,p_batch_id
  	       ,l_glbl_data_rec);
     --
     -- The batch is being purged.
     --
     if    l_glbl_data_rec.upload_mode = 'PURGE' then
       --
       -- Remove all the data for the batch.
       --
       purge_batch(l_glbl_data_rec);
     --
     -- The transfer of a batch is being undone ie. the balance adjustments are
     -- to be rolled back.
     --
     elsif l_glbl_data_rec.upload_mode = 'UNDO' then
       --
       -- Rollback any balance adjustments made during the transfer of the batch.
       --
       undo_transfer_batch(l_glbl_data_rec);
       --
       -- Set the status of the batch.
       --
       set_batch_status(l_glbl_data_rec);
     --
     -- The batch is either being validated or transferred.
     --
     elsif l_glbl_data_rec.upload_mode in ('VALIDATE','TRANSFER') then
       --
       -- Validate and transfer the batch.
       --
       validate_transfer_batch(l_glbl_data_rec);
     --
     -- An invalid mode has been specified.
     --
     else
       l_invalid_mode := TRUE;
     end if;
   end if;
   --
   -- Reset the batch info.
   --
   g_batch_info := l_null_batch_info;
   --
   --
   -- Set the return code and message for SRS.
   --
   retcode := status_indicator;
   if l_invalid_mode then
     retcode := SRS_ERROR; -- Error
     errbuf  := 'Invalid mode';
   end if;
   --
   hr_utility.trace('Exiting pay_balance_upload.process');
   --
 end process;
 --
begin
  g_gre_tbl_nxt := 1;
  g_runtyp_tbl_nxt := 1;
end pay_balance_upload;

/
