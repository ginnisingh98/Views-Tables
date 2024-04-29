--------------------------------------------------------
--  DDL for Package HRASSACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRASSACT" AUTHID CURRENT_USER as
/* $Header: pyassact.pkh 120.6.12010000.3 2009/04/14 07:56:19 priupadh ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1993 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ******************************************************************

 ======================================================================


 Change List
 ===========

 Version Date       Author    ER/CR No. Description of Change
 -------+---------+----------+---------+-------------------------------
 115.31  14/04/09  priupadh   7652030  Added global variables gv_multi_reversal
                                       and gv_cnt_reversal_act_id
 115.30  26/02/08  ckesanap   6820127  Added another definition of
                                       ext_man_payment to be called as
				       a concurrent request for Void &
				       Reversal enhancement.
 115.29  30/11/06  DIVICKER            Retain old reversal signature order
 115.28  23/11/06  DIVICKER            Reversal parameter change for multi
 115.27  30/10/06  DIVICKER   5616882  Reversal by assignment set refactor
                                       of reversal procedure
 115.25  10/08/06  ALOGUE     5441737  Added actype to resequence_actions.
 115.24  29/04/05  SuSivasu            Added p_reason to ext_man_payment.
 115.23  10/12/04  ALOGUE              g_ba_lat_bal_maintenance global
                                       for BAL_ADJ_LAT_BAL legislation
                                       rule.
 115.22  25/10/04  NBRISTOW            Allow retropaying multi
                                       assignments
 115.21  25/10/04  THABARA             Added p_element_type_id to
                                       del_latest_balances().
 115.20  20/09/04  THABARA    3482270  Orig Entry ID support for adjustments.
                                       Added p_rrid and p_oentry to
                                       set_action_context().
                                       Added rrid to maintain_lat_bal().
 115.19  09/08/04  tbattoo    3724695  Support for reversals and retropay
 115.18  03/11/03  tbattoo             support for sparse matrix and
				       pay_latest_balances table
 115.17  05/06/03  ALOGUE     2960902  New trash_latest_balances only
                                       passed balance_type_id and
                                       trash_date. Overloads original
                                       version.
 115.16  05/03/03  sdhole     2805195  Added parameter tax_unit_id with
                                       default value null to bal_adjust.
 115.15  07/02/03  NBRISTOW            Further new context changes.
 115.14  05/02/03  NBRISTOW            Added new contexts.
 115.13  09/01/03  ALOGUE     2266326  Added CHECK_LATEST_BALANCES,
                                       CHECK_RRVS_FIRST and
                                       CHECK_LAT_BALS_FIRST globals
                                       for tuning behaviour of
                                       trash_latest_balances.
 115.12  03/12/02  SCCHAKRA   2613838  Added procedure get_default_leg_value.
                                       Included NOCOPY Performance Changes.
 115.11  03/04/02  TBATTOO             added p_run_type_id parameter
 115.10  18/12/01  DSAXBY              GSCC standards fix.
 115.9   17/09/01  DSAXBY     1682940  Add purge_mode parameter to
                                       bal_adjust_actions, inassact_main and
                                       inassact procedures.
                                       Added dbdrv line.
 115.8   13/11/01  JTOMKINS            Added prepay_flag to bal_adjust
                                       and bal_adjust_actions.
 115.7   04/09/01  NBRISTOW            Added the resequence_chunk
                                       procedure.
 115.6   27/11/00  NBRISTOW            Changes for source text context.
 115.5   29/09/00  NBRISTOW            Now passing tax unit id to
                                       balance adjustments.
 115.4   30/08/00  ALOGUE              Pass eentryid to maintain_lat_bal.
 115.3   04/08/00  ALOGUE              New procedures maintain_lat_bal,
                                       set_jurisdiction_code and
                                       set_action_contexts.
 115.2   19/05/00  NBRISTOW            Added procedures to resequence
                                       sequenced actions.
 40.21   27/3/97   ALOGUE              US reversal GRE Fix #459662
 40.20   14/01/97  NBRISTOW            Reverse Backport.
 40.19   14/01/97  NBRISTOW            Backport end of year performance
                                       fix.
 40.18   29/11/96  DSAXBY     #366215  New procedure rev_pre_inserted_rr.
 40.17   20/11/96  NBRISTOW            Now passing a flag to inassact to
                                       indicate if the assignment needs to
                                       be locked.
 40.16   19/06/96  NBRISTOW   #374931  Now when a balance adjustment
                                       is performed only the latest
                                       balances feed by the adjustment
                                       are deleted.
 40.15   30/01/96  DSAXBY     #333428  Changed trash_latest_balances procedure
                                       to avoid trashing balances
                                       un-necessarily. This required the
                                       addition of a new parameter.
 40.14   10/11/95  NBRISTOW            Changed name of bal_adjust to
                                       bal_adjust_actions, added extra
                                       out arguments. Created new procedure
                                       bal_adjust for existing bal_adjust
                                       calls.
 40.11   11/09/95  DSAXBY     #307123  New parameter to reversal.
 40.10   05/07/95  NBRISTOW            Added initial balance payroll
                                       action type.
 40.9    16/12/94  DSAXBY              Added qpppassact.
 40.8    25/11/94  DSAXBY              Change in parameters to qpassact.
 40.7    15/11/94  DSAXBY              Added overloaded public versions of
                                       validate_pact_rollback and
                                       validate_assact_rollback.
 40.4    05/11/93  DSAXBY              Made inassact public again.
 40.3    04/11/93  DSAXBY              Added qpassact and removed inassact.
 40.2    27/10/93  DSAXBY              Added del_latest_balances.
 40.1    19/10/93  DSAXBY              Altered bal_adjust defintion.
 30.9    27/07/93  DSAXBY              Altered bal_adjust definition.
 30.8    20/07/93  DSAXBY              Added bal_adjust definition..
 3.0     11/03/93  H.MINTON            Added copyright and exit line
 ----------------------------------------------------------------------
*/
type varchar_60_tbl  IS TABLE OF VARCHAR(60)  INDEX BY binary_integer;
type varchar_80_tbl  IS TABLE OF VARCHAR(80)  INDEX BY binary_integer;
type varchar_tbl     IS TABLE OF VARCHAR(1)  INDEX BY binary_integer;
type number_tbl  IS TABLE OF number  INDEX BY binary_integer;
type boolean_tbl  IS TABLE OF boolean  INDEX BY binary_integer;

/*Bug 7652030 Added below globals */
gv_multi_reversal BOOLEAN Default FALSE;
gv_cnt_reversal_act_id Number;
--
type context_details is record
(assact_id                 number_tbl,
 asg_id                    number_tbl,
 cxt_id                    number_tbl,
 cxt_name                  varchar_60_tbl,
 cxt_value                 varchar_60_tbl,
 valid                     boolean_tbl,
 sz                        number
);
--
-- The following are used for tuning the behaviour of the
-- trash_latest_balances procedure.
--
CHECK_LATEST_BALANCES boolean := TRUE;
CHECK_RRVS_FIRST      boolean := FALSE;
CHECK_LAT_BALS_FIRST  boolean := FALSE;

--
-- BAL_ADJ_LAT_BAL legislation rule value
--
g_ba_lat_bal_maintenance boolean := null;

/*-----------------------  validate_pact_rollback -------------------------*/
/*
 *   This routine is called before a rollback to get any payroll action level
 *   information (e.g, action type) whch will be needed. This routine also
 *   performs some validation as to whether the action can be rolled back,
 *   and so may fail.
 *   It is overloaded with respect to an internal procedure.
 */
procedure validate_pact_rollback
(
   p_payroll_action_id in number,
   p_rollback_mode     in varchar2
);
--
/*-----------------------  validate_assact_rollback -------------------------*/
/*
 *   This procedure is an overloaded public procedure to validate a
 *   particular assignment action.
 */
function validate_assact_rollback
(
   p_payroll_action_id    in number,
   p_assignment_action_id in number,
   p_rollback_mode        in varchar2
) return boolean;
--
procedure ensure_assact_rolled_back (p_assact_id in number,
                                     p_rollback_mode in varchar2);
procedure ensure_pact_rolled_back (p_pact_id in number);
--
/*-----------------------  rollback_payroll_action  ----------------------*/
/*
 *   This routine rolls back an entire payroll action.
 *
 *   Three forms are available:
 *
 *   1) Rollback entire action without committing, fail if any individual
 *      assignment action couldn't be rolled back.
 *
 *   2) Rollback entire action without committing, continue if any
 *      assignment action couldn't be rolled back, setting
 *      p_failed_assact to indicate the problematic action.
 *
 *   3) Same as previous form, but commit in chunks as processing
 *      continues to avoid huge rollback segments.
 *
 *    p_rollback_mode must be either ROLLBACK or RETRY
 */
--
procedure rollback_payroll_action
                       (p_payroll_action_id    in number,
                        p_rollback_mode        in varchar2,
                        p_leave_base_table_row in boolean);
--
procedure rollback_payroll_action
                       (p_payroll_action_id    in number,
                        p_failed_assact        in out nocopy number,
                        p_rollback_mode        in varchar2,
                        p_leave_base_table_row in boolean);
--
procedure rollback_payroll_action
                       (p_payroll_action_id    in number,
                        p_chunk_size           in number,
                        p_failed_assact        in out nocopy number,
                        p_rollback_mode        in varchar2,
                        p_leave_base_table_row in boolean);
--
--
/*---------------------------  rollback_ass_action  -----------------------*/
/*
 *   This routine performs the actual work of rolling back a
 *   assignment action.
 */
procedure rollback_ass_action
              (p_assignment_action_id in number,
               p_rollback_mode        in varchar2,
               p_leave_base_table_row in boolean);
--
--
/*-------------------------  trash_latest_balances  -----------------------*/
/*
 *    This procedure trashes any latest balances
 *    invalidated for the given balance type on or after the given
 *    date.
 */
procedure trash_latest_balances(l_balance_type_id number,
                                l_input_value_id number,
                                l_trash_date date);
--
--
/*-------------------------  trash_latest_balances  -----------------------*/
/*
 *    This procedure trashes any latest balances
 *    invalidated for the given balance type on or after the given
 *    date.
 */
procedure trash_latest_balances(l_balance_type_id number,
                                l_trash_date date);
--
/*-------------------------  del_latest_balances  -----------------------*/
/*
 *     This procedure trashes any latest balances invalidated for
 *     the given assignment on or after the specified date.
 */
procedure del_latest_balances
(
   p_assignment_id   in number,
   p_effective_date  in date,   -- allow date effective join.
   p_element_entry   in number default null,
   p_element_type_id in number default null
);
--
--
/*---------------------------  applied_interlocks  -------------------------*/
/*
 *   Returns a string of the assignment actions ids which are locked by
 *   the assignment action p_locking_action_id.
 */
--
function applied_interlocks(p_locking_action_id number) return varchar2;
--
--------------------------- inassact ------------------------------
/*
   NAME
      inassact - INsert ASSignment Action
   DESCRIPTION
      Inserts and validates the insert of an assignment
      action. This is called:
      a) Internally, from within pyassact procedures.
      b) Externall, from hrbaldtm package.
   NOTES
      o This is a general procedure, handling the insert of
        assignent actions for QuickPay, Reversal, Balance Adjustment
        and External/Manual payments.
      o The last three parameters are only set for External/Manual payment
        (before taxunt).
      o inassact is a cover to inassact_main to ensure a taxunt gets
        passed.
*/
procedure inassact
(
   pactid in number,  -- payroll_action_id.
   asgid  in number,   -- assignment_id to create action for.
   p_ass_action_seq in number   default null, --action sequence
   p_serial_number  in varchar2 default null, --cheque number
   p_pre_payment_id in number   default null, --pre payment id
   p_element_entry  in number   default null,
   p_asg_lock       in boolean  default TRUE, --lock assignment.
   p_purge_mode     in boolean  default FALSE,--purge mode
   run_type_id      in number   default null
);
--
procedure inassact_main
(
   pactid in number,  -- payroll_action_id.
   asgid  in number,   -- assignment_id to create action for.
   p_ass_action_seq in number   default null, --action sequence
   p_serial_number  in varchar2 default null, --cheque number
   p_pre_payment_id in number   default null, --pre payment id
   p_element_entry  in number   default null,
   p_asg_lock       in boolean  default TRUE,  --lock assignment.
   taxunt           in number   default null, -- tax unit id
   p_purge_mode     in boolean  default FALSE -- purge mode.
);

procedure inassact_main
(
   pactid in number,  -- payroll_action_id.
   asgid  in number,   -- assignment_id to create action for.
   p_ass_action_seq in number   default null, --action sequence
   p_serial_number  in varchar2 default null, --cheque number
   p_pre_payment_id in number   default null, --pre payment id
   p_element_entry  in number   default null,
   p_asg_lock       in boolean  default TRUE,  --lock assignment.
   taxunt           in number   default null, -- tax unit id
   p_purge_mode     in boolean  default FALSE, -- purge mode.
   p_run_type_id      in number   default null
);

   function inassact_main
   (
      pactid in number,  -- payroll_action_id.
      asgid  in number,   -- assignment_id to create action for.
      p_ass_action_seq in number   default null, --action sequence
      p_serial_number  in varchar2 default null, --cheque number
      p_pre_payment_id in number   default null, --pre payment id
      p_element_entry  in number   default null,
      p_asg_lock       in boolean  default TRUE, --lock assignment
      taxunt           in number   default null, -- tax unit id
      p_purge_mode     in boolean  default FALSE, --purge mode
      p_run_type_id    in number   default null,
      p_mode           in varchar2 default 'STANDARD'
   ) return number;
--
----------------------------- qpassact ------------------------------
/*
   NAME
      qpassact - insert QuickPay ASSignment Action
   DESCRIPTION
      Inserts and validates the insert of an assignment
      action for the QuickPay user exit.
   NOTES
      This procedure directly calls inassact.
*/
procedure qpassact
(
   p_payroll_action_id     in  number, -- payroll_action_id.
   p_assignment_id         in  number, -- assignment_id to create action for.
   p_assignment_action_id  out nocopy number,
   p_object_version_number out nocopy number
);
--
--------------------------- qpppassact ------------------------------
/*
   NAME
      qpppassact - Insert a QuickPay Pre-Payment action.
   DESCRIPTION
      Process a QuickPay Pre-Payment action.
   NOTES
      This procedure is meant to be called via the QuickPay form.
*/
procedure qpppassact
(
   p_payroll_action_id     in  number, -- of QuickPay pre-payment.
   p_assignment_action_id  out nocopy number,
   p_object_version_number out nocopy number
);
--
--------------------------- reversal ------------------------------
/*
   NAME
      reversal - Process a reversal.
   DESCRIPTION
      Process a reversal for an assignment action.
   NOTES
      This is called directly from the Reversal form.
*/
procedure reversal
(
   pactid   in number,               -- payroll_action_id.
   assactid in number,               -- assignment_action_id to be reversed.
   redo     in boolean default false, -- insert assact and interlock if false
   rev_aaid in number  default 0,    -- locking action id
   multi    in boolean default false -- skip setup for multi asg reversals
);
--
--------------------------- multi_assignment_reversal ------------------
/*
   NAME
      multi_assignment_reversal - Process a reversal called via PYUGEN.
   DESCRIPTION
      Process a reversal for an assignment action.
   NOTES
      This is called via PYUGEN. Basically a wrapper around the regular
      single assignment ID, also passing multi flag TRUE
*/
procedure multi_assignment_reversal
(
   pactid   in number,               -- payroll_action_id.
   assactid in number,               -- assignment_action_id to be reversed.
   rev_aaid in number                -- locking action id
);
--
----------------------- rev_pre_inserted_rr --------------------------
/*
   NAME
      rev_pre_inserted_rr - Reversal create pre-inserted run results.
   DESCRIPTION
      Creates pre-inserted run results when a Reversal is processed
      These are created for any non-recurring or additional entry
      type that is processed by the Reversal.
   NOTES
      This routine can be called, irrespective of whether the
      results have already been inserted or not.
*/
/*procedure rev_pre_inserted_rr
(
   p_payroll_action_id in number    -- payroll_action_id of reversal.
); */
----------------------------- ext_man_payment  -------------------------
/*
   NAME
      ext_man_payment - External/Manual Payments
   DESCRIPTION
      Pre-Payment External/Manual Payments
   NOTES
      This is called directly from the Pre-Payment form.
*/
   procedure ext_man_payment
   (
      p_payroll_id           in number, -- payroll id of assign
      p_eff_date             in date,   -- session date
      p_assignment_action_id in number, -- pre-payment assign action
      p_assignment_id        in number, -- assign id
      p_comments             in varchar2,-- comments
      p_serial_number        in varchar2,-- serial number
      p_pre_payment_id       in number,   -- pre-payment id
      p_reason               in varchar2 default null -- Reason
   );
--
-- Added for bug 6820127
 -------------------------- ext_man_payment --------------------------
   /*
      NAME
         ext_man_payment - Performs External/Manual Payments
      DESCRIPTION
         Process a External/Manual Payment.
      NOTES
         This procedure is called from the executable PYEXMNPT within the 'Cancel Check' flow.
   */

   procedure ext_man_payment
   (
      p_errmsg            OUT NOCOPY VARCHAR2,
      p_errcode           OUT NOCOPY NUMBER,
      p_payroll_id           in number, -- payroll id of assign
      p_eff_date             in varchar2,   -- session date
      p_assignment_action_id in number, -- pre-payment assign action
      p_assignment_id        in number, -- assign id
      p_comments             in varchar2,-- comments
      p_serial_number        in varchar2,-- serial number
      p_pre_payment_id       in number,   -- pre-payment id
      p_reason               in varchar2 default null -- Reason
   );
--
--------------------------- set_action_contexts------------------------
/*
   NAME
      set_action_contexts - This sets up the action contexts for a
                               given element entry.
   DESCRIPTION
   NOTES
*/
procedure set_action_context (p_assact   in number,
                              p_rrid     in number, -- run_result_id
                              p_entry    in number,
                              p_tax_unit in number,
                              p_asgid    in number,
                              p_busgrp   in number,
                              p_legcode  in varchar2,
                              p_oentry   in number, -- original entry id
                              udca       out nocopy context_details
                             );
--------------------------- bal_adjust_actions -----------------------
/*
   NAME
      bal_adjust_actions - perform balance adjustment.
   DESCRIPTION
      Process a balance adjustment.
   NOTES
*/
procedure bal_adjust_actions
(
   consetid in number, -- consolidation_set_id.
   eentryid in number, -- element_entry_id.
   effdate  in date,   -- effective_date of bal adjust.
   pyactid out nocopy number, -- payroll action id.
   asactid out nocopy number, -- assignment action id.
   act_type in varchar2 default 'B', -- payroll action type.
   prepay_flag in varchar2 default null, -- include in prepay process?
   taxunit  in number   default null, -- tax unit id
   purge_mode in boolean default false,  -- are we calling in purge mode?
   run_type_id in number default null
);
--------------------------- bal_adjust ------------------------------
/*
   NAME
      bal_adjust - perform balance adjustment.
   DESCRIPTION
      Process a balance adjustment.
   NOTES
      This is called directly from the Balance Adjustment form.
      This is a cover for the bal_adjust_actions procedure.
*/
procedure bal_adjust
(
   consetid in number, -- consolidation_set_id.
   eentryid in number, -- element_entry_id.
   effdate  in date,   -- effective_date of bal adjust.
   act_type in varchar2 default 'B', -- payroll action type.
   prepay_flag in varchar2 default null, -- Include in prepay process?
   run_type_id in number default null ,
   tax_unit_id in number default null
);
--
--------------------------- resequence_chunk ----------------------
/*
   NAME
      resequence_chunk
   DESCRIPTION
      Resequence sequenced actions for a whole chunk of assignments.
   NOTE,S
*/
procedure resequence_chunk
(
   pactid    in number,
   cnkno     in number,
   rmode    in varchar2, -- rule_mode (time period independent Y or N)
   chldact  in varchar2 default 'N' -- update child actions (Y or N)
);
--
--------------------------- resequence_actions ------------------------------
/*
   NAME
      resequence_actions - Resequences sequenced actions for an assignment.
   DESCRIPTION
   NOTES
*/
procedure resequence_actions
      (
         aaid    in number,
         rmode    in varchar2, -- rule_mode (time period independent Y or N)
         chldact  in varchar2 default 'N', -- update child actions (Y or N
         actype    in varchar2
      );

procedure resequence_actions
      (
         pactid    in number,
         asgid    in number,
         actseq    in number,
         rmode    in varchar2  -- rule_mode (time period independent Y or N)
      );
--
--------------------------- update_action_sequence ------------------------------
/*
   NAME
      update_action_sequence
   DESCRIPTION
      Update the action sequence of a particular action.
   NOTES
*/
procedure update_action_sequence (p_assact in number,
                                  rmode    in varchar2);
--
--------------------------- maintain_lat_bal ------------------------
/*
   NAME
      maintain_lat_bal - maintenace of latest balances.
   DESCRIPTION
      Perform maintenace of latest balances within balance adjustment.
   NOTES
      This is called from the balance adjustment code above and from the
      batch balance adjustment code.
*/
procedure maintain_lat_bal
(
   assactid in number,  -- assignment_action_id of inserted action.
   rrid     in number,  -- run_result_id
   eentryid in number,  -- element entry id
   effdate  in date,    -- effective_date of bal adjust.
   udca     in context_details,
   act_type in varchar2 default 'B' -- payroll_action_type.
);
--
--------------------------- get_default_leg_value ------------------------
/*
   NAME
      get_default_leg_value - get the default run type
   DESCRIPTION
      Gets the default legislative specific run type id.
   NOTES
      This is called from the Quick Pay form.
*/
procedure get_default_leg_value
  (p_plsql_proc     in  varchar2
  ,p_effective_date in  varchar2
  ,p_run_type_id    out nocopy number
  );
--
function get_retry_revesal_action_id(p_act_id number)
return number ;

   --------------------------- get_cache_context------------------------
   /*
      NAME
         get_cache_context - This retrieves the context id given the
                             context name from the cache.
      DESCRIPTION
      NOTES
   */
procedure get_cache_context(p_cxt_name in     varchar2,
                            p_cxt_id   out    nocopy number);

end hrassact;

/
