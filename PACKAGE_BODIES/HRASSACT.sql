--------------------------------------------------------
--  DDL for Package Body HRASSACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRASSACT" as
/* $Header: pyassact.pkb 120.30.12010000.7 2009/06/03 07:06:33 priupadh ship $ */
/*
 Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
/*
--
 Name         : hrassact
 Author       : $Author: priupadh $
 Synopsis     : Payroll and Assignment action processing.
 Contents     : applied_interlocks
                bal_adjust
                bal_adjust_actions
                del_latest_balances
                do_assact_rollback
                do_pact_rollback
                ensure_assact_rolled_back
                ensure_pact_rolled_back
                ext_man_payment
                inassact
                inassact_main
                irbaact
                reversal
                rollback_ass_action
                rollback_payroll_action
                trash_latest_balances
                trash_latest_balances
                trash_quickpay
                undo_stop_update
                val_assact_rollback
                val_pact_rollback
                validate_rollback_mode
--
 Change List
 -----------
 Date        Name          Vers    Bug No     Description
 -----------+-------------+-------+----------+-------------------------------+
 03-Jun-2009 priupadh      115.147 8570075     Modified trash_latest_balances,removed "close ivchk"
                                               inside if condition as it was closing twice ivchk.
 14-Apr-2009 priupadh      115.146 7652030     Removed checkfile in dbdrv.
 14-Apr-2009 priupadh      115.145 7652030     Modified multi_assignment_reversal
                                               now calling create_all_group_balances
                                               after last assignment reversal.
 21-Nov-2008 ubhat         115.144 7584883     Divided locking code for
                                               per_all_assignment_f and
                                               per_periods_of_service.
 10-Oct-2008 salogana	   115.143 7371362     Added bulk delete in
					       trash_latest_balances FOR
					       pay_assignment_latest_balances
 05-Aug-2008 salogana	   115.142 6595092     Added bulk delete code in
                                               trash_latest_balances for
					       performance improvement.
 26-Feb-2008 Ckesanap      115.141 6820127     Added another definition of
                                               ext_man_payment to be called as
					       a concurrent request for Void and
					       Reversal enhancement.
 19-DEC-2007 AYegappa      115.140 6676706     Performance fix to Balance
                                               Adjustments (added some hints)
 05-NOV-2007 alogue        115.139             Performance fix to
                                               trash_latest_balances.
 11-JUN-2007 KKawol        115.138             Set the entry path on reversal
                                               run results.
 12-FEB-2007 SuSivasu      115.137             Set the time period to be based
                                               on the period earned for the
                                               Balance Adjustment when the
                                               TIME_PERIOD_ID leg rule is set.
 16-JAN-2007 nbristow      115.136             Changes for
                                               maintain_balances_for_action
 30-NOV-2006 divicker      115.135             Retain old reversal sig order
 23-NOV-2006 divicker      115.134             Multi reversal parameter update
 10-NOV-2006 alogue        115.133 5410515     Stop balance adjustments or
                                               reversals on assignments with
                                               allready incomplete actions.
 09-NOV-2006 divicker      115.132             Further batch reversal changes
 03-NOV-2006 nbristow      115.131             Now performing
                                               a distinct for pog joins
 03-NOV-2006 divicker      115.130             Revert to 115.128 pending
                                               further check on 115.129
 02-NOV-2006 divicker      115.129             Add loop for processing multi
                                               reverse run balances
 31-OCT-2006 divicker      115.128             Need correct refactoring of
                                               reversal proc.
 30-OCT-2006 divicker      115.126 5616882     Reversal by assignment set func
                                               Bug fix 5410515
 19-OCT-2006 alogue        115.125 5612247     Performance fix to POG
                                               resequence statements.
 07-AUG-2006 alogue        115.124 5441737     Resequence G object group actions
                                               - Retropay matser assignment actions
                                               have null assignment_id.
 02-AUG-2006 alogue        115.123 5416668     Performance fix to albc_selective
                                               in del_latest_balances.
 30-JUN-2006 nbristow      115.122             Context length limited to 30
                                               chars
 19-JUN-2006 SuSivasu      115.121             Enabled the Balance Date and Time
                                               Definition ID contexts to be stored
                                               in pay_action_contexts.
 14-MAR-2006 alogue        115.120 5094068     Fix lb_context_match_check
                                               to correctly spot if context
                                               wasn't in the udca.
 07-MAR-2006 alogue        115.119 5082050     Further fix to POG retro
                                               resequencing for assignments
                                               started in the future.
 17-FEB-2006 alogue        115.118             Further fix to previous change.
 17-FEB-2006 nbristow      115.117             Using the interlock rule G, the
                                               Retro actions were not
                                               correctly resequencing for
                                               terminated employees.
 14-FEB-2006 alogue        115.116 5034395     Radix issue in maintain_lat_bal.
 04-OCT-2005 alogue        115.115 4644738     Load cxt_id in udca for Reversals
                                               as used by context_match_check.
 05-SEP-2005 alogue        115.114             Performance CBO hints in
                                               trash_latest_balances.
 27-JUL-2005 nbristow      115.113             Resequence_actions was not
                                               joining to the assignment table
                                               correctly under certain date
                                               track conditions.
 08-JUN-2005 alogue        115.112 4372751     Performance fix: hint in seqasg
                                               in resequence_actions.
 06-MAY-2005 NBristow      115.111             Added new contexts
                                               LOCAL_UNIT_ID, ORGANIZATION_ID
                                               and SOURCE_NUMBER2.
 29-APR-2005 SuSivasu      115.110             Added p_reason parameter for
                                               ext_man_payment.
 29-APR-2005 alogue        115.109 4337565     Support of ENABLE_RR_SPARSE
                                               upgrade.
 14-APR-2005 alogue        115.108 3465844     Use PAY_ASSIGNMENT_ACTIONS_N51
                                               instead of PAY_ASSIGNMENT_ACTIONS_N1
                                               in index hints.
 04-APR-2005 alogue        115.107             Latest Balance Maintenance by
                                               Reversals.
 23-FEB-2005 nbristow      115.106             Changes for Period Allocation.
 10-DEC-2004 alogue        115.105             g_ba_lat_bal_maintenance global
                                               for BAL_ADJ_LAT_BAL legislation
                                               rule.
 25-NOV-2004 nbristow      115.104             Retropay multi assignments
 25-OCT-2004 thabara       115.103 3966979     Added p_element_type_id to
                                               del_latest_balances().
                                               Modified maintain_lat_bal().
 24-SEP-2004 nbristow      115.102             Changes for process group
                                               actions.
 20-SEP-2004 thabara       115.101 3482270     Original Entry ID support for
                                               balance adjustments.
                                               Modified set_action_context(),
                                               bal_adjust_actions() and
                                               maintain_lat_bal().
 16-SEP-2004 alogue        115.100 3863038     More Performance fixes in
                                               del_latest_balances.
 09-AUG-2004 tbattoo       115.99  3724695     Support for reversals and retropay
 08-JUL-2004 nbristow      115.98              Changes for Sparse Matrix JC.
 30-APR-2004 alogue        115.97              More Performance fixes in
                                               del_latest_balances.
 28-APR-2004 thabara       115.96              Modified irbaact not to call
                                               get_tax_unit when taxunt is set
                                               for action type B and I.
 27-APR-2004 alogue        115.95              Performance fix to albc_selective
                                               in del_latest_balances.
 09-Mar-2004 swinton       115.94              Enhancement 3368211 -
                                               Amended Trash_Quickpay() to
                                               support new QuickPay Exclusions
                                               model.
 02-FEB-2004 nbristow      115.93              Reversal was not correctly
                                               setting the run balances, when
                                               the run is prior to the
                                               balance validation date.
 06-JAN-2004 alogue        115.92  3354185     Avoid execution of
                                               del_latest_balances() for balance
                                               initialisations.
 16-DEC-2003 tbattoo       115.91              Fix to mantain latest balances
 11-DEC-2003 tbattoo       115.90              Fix to mantain latest balances
 09-DEC-2003 nbristow      115.89              Changes to maintain
                                               pay_latest_balances.
 24-NOV-2003 alogue        115.88  3262314     Performance enhancement to
                                               previous change.
 24-NOV-2003 alogue        115.87  3262314     Performance enhancement to
                                               previous change.
 21-NOV-2003 alogue        115.86  3262314     Avoid corruption of latest
                                               balance value by balance
                                               adjustments.
 13-NOV-2003 nbristow      115.85              Reversal was not correctly
                                               setting the jurisdiction code
                                               in sparse mode.
 04-NOV-2003 alogue        115.84  3176709     Use of per_business_groups_perf,
                                               per_all_people_f and
                                               pay_all_payrolls_f. Performance
                                               fix to seqper cursors.
 03-NOV-2003 tbattoo       115.83              support for sparse matrix and
					       pay_latest_balances table
 17-OCT-2003 alogue        115.82              Tuned get_rr_values cursor
                                               in set_action_context.
 14-OCT-2003 alogue        115.81  3166638     Performance fix to quickpay
                                               assignment action creation.
 05-SEP-2003 alogue        115.80  3130030     Performance fix to plbc_selective
                                               in del_latest_balances.
 05-SEP-2003 alogue        115.79  3130030     Performance fix to trash_quickpay.
 03-SEP-2003 thabara       115.78              Correction of 115.77.
 03-SEP-2003 thabara       115.77  3105028     Modified set_action_context not
                                               to set defaults to dynamic
                                               contexts for Balance Upload.
                                               Modified the process order of
                                               create_all_asg/group_balances
                                               in bal_adjust_actions to call
                                               them after setting contexts.
 03-SEP-2003 nbristow      115.76              RETRO_DELETE is now a
                                               legislation rule.
 29-AUG-2003 nbristow      115.75              Action sequence on
                                               pay_run_balances was not being
                                               updated correctly.
 53-JUN-2003 alogue        115.74  2960902     New trash_latest_balances
                                               only passed balance_type_id
                                               and trash_date. Overloads
                                               original version.
 12-MAY-2003 alogue        115.73  2911448     Avoid locking issues in Batch
                                               Balance Adjustments by only
                                               updating action_population_status
                                               in inassact_main if need to.
 11-MAR-2004 rthirlby      115.72  2822429     Altered reversal, so that run
                                               result values for SOURCE_IV
                                               and SOURCE_NUMBER input values
                                               are not negated. These rrvs will
                                               be ids/numbers that should not be
                                               reversed.
 05-MAR-2003 sdhole        115.71  2805195     Added parameter tax_unit_id
                                               with default value null to
                                               bal_adjust procedure.
 07-FEB-2003 nbristow      115.70              Reversal was not correctly
                                               working for the new contexts.
 05-FEB-2003 nbristow      115.69              Further new context changes.
 05-FEB-2003 nbristow      115.68              Added contexts for
                                               source_number and source_text2
 24-JAN-2003 alogue        115.67              Reverse bug 2453546 changes.
 20-JAN-2003 alogue        115.66  2758499     Fixed trash_latest_balances
                                               to handle latest balances
                                               earlier than trash_date.
 14-JAN-2003 nbristow      115.65              Now Jurisdiction input value
                                               can have any name.
 10-JAN-2003 alogue        115.64  2266326     Use of CHECK_LATEST_BALANCES,
                                               CHECK_RRVS_FIRST and
                                               CHECK_LAT_BALS_FIRST package
                                               globals to tune behaviour of
                                               trash_latest_balances.
 09-JAN-2003 alogue        115.63  2692195     Use of hr_utility.debug_enabled
                                               for performance of trace
                                               statements.
 06-DEC-2002 alogue        115.62              Subtle-paranoid fix to
                                               bal_adjust_actions to avoid
                                               possible issue with NOCOPY
                                               changes.
 03-DEC-2002 scchakra      115.61  2613838     Added overloaded procedure
                                               get_default_leg_value to return
                                               the default run type for a
                                               legislation. Included
                                               NOCOPY Performance Changes.
 15-NOV-2002 alogue        115.60  2667222     Re-implement 2492007 cartesian
                                               join (in a different way!).
 07-NOV-2002 alogue        115.59  2453546     Optimise performance of seqper
                                               cursor in inassact be breaking
                                               into 2.
 24-OCT-2002 alogue        115.57  2641336     Optimise performance for
                                               statements in del_latest_balances.
 16-OCT-2002 alogue        115.56  2581887     Optimise performance for
                                               Balance Initialisation.
 24-SEP-2002 alogue        115.55  2587443     Further enhanced Reversals so
                                               handle result values with up
                                               to 38 decimal places.
 19-SEP-2002 nbristow      115.54              Changes in 115.50 introduced
                                               a bug in Retropay, reversed
                                               the change to run_results
                                               cursor.
 09-SEP-2002 alogue        115.53  2529691     Performance fix to
                                               resequence_actions.
 09-AUG-2002 alogue        115.52              Performance fix to element
                                               entries statement in
                                               do_assact_rollback that was
                                               using FTS.
 09-AUG-2002 alogue        115.51  2362454     Enhance Reversals so handle
                                               result values with up to 35
                                               decimal places.  Previously
                                               there was a restriction of up
                                               to 20 dcs within the fnd_number
                                               code.
 01-AUG-2002 dsaxby        115.50  2492007     Prevent ora-01403
                                               no data found from within
                                               bal_adjust_actions.
                                               Also, fix select of run results
                                               to reverse to remove apparent
                                               cartesian join.
 21-JUN-2002 alogue        115.49              Fix CA TAX_GROUP value fetch
                                               in udca.
 30-APR-2002 RThirlby      115.48              Support for pay_run_balances -
                                               balance reporting architecture,
                                               for reversals and balance
                                               adjustments.
 26-APR-2002 alogue        115.47  2346351     Support of payroll_id in udca
                                               for balances that use payroll_id
                                               context.
 09-APR-2002 nbristow      115.46              Added get_default_leg_rule to
                                               allow the defaulting of run
                                               type.
 03-APR-2002 tbattoo       115.45              added p_run_type_id parameter
 18-DEC-2001 dsaxby        115.44              GSCC standards fix.
 26-NOV-2001 dsaxby        115.43  1682940     Changes for Purge.
                                               Do not shuffle assignment
                                               actions in purge mode and allow
                                               insert of upload action before
                                               a Purge.
                                               Added commit at end of file.
                                               Added purge_mode parameter to
                                               bal_adjust_actions.
                                               Added dbdrv line.
 13-NOV-2001 jtomkins      115.42              Added prepay_flag parameter to
                                               bal_adjust and bal_adjust_actions
 01-NOV-2001 nbristow      115.41              Set Action Context exist
                                               statement now in the correct
                                               format.
 29-OCT-2001 nbristow      115.40              Set Action Context changed to
                                               check that a row does not
                                               already exist in the action
                                               context table.
 11-OCT-2001 nbristow      115.39              Added hints to statements
                                               in rev_pre_inserted_rr.
 04-SEP-2001 nbristow      115.38              Added the resequence_chunk
                                               procedure.
 12-JUL-2001 kkawol        115.37              Change to inassact_main. If
                                               rule_type 'I' does not exist for
                                               the legislation, we default rule
                                               mode to N. Bug 1337853.
 25-JUN-2001 alogue        115.36              Performance fix to balance
                                               adjustment latest balance
                                               maintenance.
 25-JUN-2001 alogue        115.35              Added CBO hints
 22-JUN-2001 alogue        115.34              Added CBO hints
 12-JUN-2001 nbristow      115.33              Initialising retro_purge.
 04-JUN-2001 kkawol        115.32              Added changes required for
                                               Quickpay Prepay to work with
                                               master and sub actions (iter eng).
                                               Changed qpppassact and inassact.
 29-MAY-2001 nbristow      115.31              Changes to Retropay so that
                                               the RRs are not deleted.
 08-MAY-2001 alogue        115.30  1763446     Added CBO hints
 24-APR-2001 mreid         115.29  1518951     Added CBO hints
 06-APR-2001 alogue        115.28              Changes for source text iv
                                               context.
 26-JAN-2001 alogue        115.26  1614003     Balance Adjustment lat bal
                                               maintenance handle multiple
                                               feeds by same adjustment.
 16-JAN-2001 alogue        115.26              Handle null result values  in
                                               balance adjustment latest
                                               balance maintenance.
 10-JAN-2001 alogue        115.25  1571313     Handle -9999 balance values in
                                               balance adjustment latest
                                               balance maintenance.
 26-NOV-2000 nbristow      115.24              Changes for source text context
 21-NOV-2000 alogue        115.23  887061      Skipped terminated assignments
                                               support.
 02-OCT-2000 alogue        115.22  1421447     Avoid a PLS-00365 in latest
                                               balance maintenance inm balance
                                               adjustments.
 29-SEP-2000 nbristow      115.21              Now passing tax unit id to
                                               balance adjustments.
 18-SEP-2000 nbristow      115.20              Maintenance of latest balances
                                               was not taking into account
                                               null rrv.
 14-SEP-2000 NBRISTOW      115.19              Changes to trash_latest_balances
                                               to remove full pl/sql feed
                                               checking balances.
 30-AUG-2000 ALOGUE        115.17              Deletion of latest balances
                                               by balance adjustment if
                                               leg rule for lat bal maintenance
                                               is not defined.
 04-AUG-2000 ALOGUE        115.16              Maintenance of latest balances
                                               within balance adjustments.
 19-MAY-2000 nbristow      115.15              Added procedures to resequence
                                               sequenced actions.
 22-FEB-2000 dsaxby        115.14  #1168142    Remove the need for a period of
                                               service row to exist when
                                               processing a balance adjustment
                                               action.  This is for OAB.
 13-JAN-2000 alogue        115.13              Ensure that error_messages
                                               inserted into pay_message_lines
                                               are at max 240 in length.
 16-NOV-1999 nbristow      115.12              Now reversals and balance
                                               adjustments populate
                                               pay_action_contexts.
 26-JUL-1999 ALOGUE        115.11              Enhancement in Reversal to
                                               get reversals results in same
                                               order as run being reversed.
                                               Optimises behaviour of the
                                               retrocosting of a reversal.
 02-JUN-1999 ALOGUE        115.10              Fix in bal_adjust_actions to
                                               ensure only update this balance
                                               adjustments run results.
 22-APR-1999 ALOGUE        115.8               Changed rollback_payroll_action
 12-APR-1999 ALOGUE        115.7               Fix to reversals to support
                                               canonical numbers.
 07-APR-1999 SDOSHI        115.6               Flexible Dates Conversion
 04-JAN-1999 NBRISTOW      110.8               Changed rollback_payroll_action
                                               to use the rollback package.
 04-SEP-1998 KKAWOL        40.62   #721925     Reversals run results: select
                                               actual status instead of
                                               forcing it to be 'P'.
 27-NOV-1997 MFENDER       110.3   #589767     Modified inassact to populate
                                               tax_unit_id for quickpay
                                               prepayments.
 05-SEP-1997 KKAWOL        40.61   #547578     Period dates fix.  Set the
                                               date_earned column as
                                               appropriate on the
                                               pay_payroll_actions table.
 19-JUN-1997 ALOGUE        40.60   #507602     Reversals run results: source_id
                                               = run_result_id of the run
                                               result being reversed.
 04-APR-1997 NBRISTOW      40.59   #473685     Segment1 was not being decoded
                                               for US legislation to convert
                                               it to a number.
 01-APR-1997 ALOGUE        40.58               Fixed previous change.
 27-MAR-1997 ALOGUE        40.57               US reversal GRE Fix #459662
 15-JAN-1996 NBRISTOW      40.56               EOY performance fix for W2.
 13-JAN-1996 NBRISTOW      40.55               Reverse Backport.
 13-JAN-1996 NBRISTOW      40.54               Backport EOY performance fix.
 23-DEC-1996 NBRISTOW      40.53               Uncommented exit.
 09-DEC-1996 SSINHA        40.52               Fixed previous change
 05-DEC-1996 NBRISTOW      40.51               Fixed previous change.
 29-NOV-1996 DSAXBY        40.50   #366215     New Reversal functionality.

 20-NOV-1996 NBRISTOW      40.49               Now passing a flag to inassact
                                               to indicate that the assignment
                                               needs to be locked.
 18-JUN-1996 NBRISTOW      40.48   #374931     Now when a balance adjustment
                                               is performed only the latest
                                               balances feed by the adjustment
                                               are deleted.
 14-JUN-1996 DSAXBY        40.47   #374389     When reversing an indirect
                                               result, set source_type of new
                                               result to 'V' (required for
                                               Costing).
 08-MAY-1996 NBRISTOW      40.46   #359005     Performance problem in
                                               del_latest_balances, now using
                                               a cursor to delete context
                                               values.
 22-APR-1996 DSAXBY        40.45   #360386     Change joins to the
                                               per_business_groups view.
 13-APR-1996 DKERR         40.44               Modified inassact for external
                                               manual payments to allow
                                               the insert of an assignment
                                               action where a payment action
                                               have been voided.
 14-MAR-1996 DSAXBY        40.43               Make 'X' actions alter action
                                               sequence where necessary.
 27-FEB-1996 DSAXBY        40.42               Added support for 'X' actions.
 17-JAN-1996 NBRISTOW      40.41   #335099     Altered sql statements in
                                               inassact to improve performance
                                               of US Check report. US Check
                                               Report is using balance
                                               user exit thus calling inassact.
 10-JAN-1996 DSAXBY        40.40   #333428     Changed trash_latest_balances
                                               procedure to avoid trashing
                                               balances un-necessarily. This
                                               required the addition of a new
                                               parameter.
 11-DEC-1995 NBRISTOW      40.39               Changed inassact to insert the
                                               Tax Unit Id for quick pay
                                               actions.
 10-NOV-1995 NBRISTOW      40.38               Changed name of bal_adjust to
                                               bal_adjust_actions, added extra
                                               out arguments. Created new
                                               procedure bal_adjust for
                                               existing bal_adjust calls.
 06-NOV-1995 NBRISTOW      40.37               Tax Unit Id now placed on the
                                               assignment_action for balance
                                               adjustments and resversals.
                                               Also the jurisdiction is placed
                                               on the run result.
 13-SEP-1995 DSAXBY        40.35   #307123     New parameter to reversal
                                               procedure, indicating that we do
                                               not need to insert assact and
                                               interlock. Introduced for
                                               backpay.
 16-AUG-1995 DSAXBY        40.34   #301528     Removed unnecessary check from
                                               ensure_assact_rolled_back
                                               procedure.
 25-JUL-1995 AMILLS        40.33               Amended selection statement
                                               substituting clause :-
                                               'HR_6075_ELE_ENTRY_REC_EXIST'
                                                with the following 2 hard
                                                coded error messages:
                                                'HR_7699_ELE_ENTRY_REC_EXISTS'
                                                'HR_7700_ELE_ENTRY_REC_EXISTS'
 10-JUL-1995 DSAXBY        40.32   #292828     Set date_earned for bal adjust.
 05-JUL-1995 NBRISTOW      40.31               Added intial balance load
                                               payroll action type.
 19-APR-1995 DSAXBY        40.30               #277088 : trash_latest_balances
                                               now deletes latest balances
                                               correctly again!
 18-APR-1995 DSAXBY        40.29               Removed 'nowait' statement to
                                               avoid immediate failure on lock
                                               when called as part of w2
                                               report work.
 04-APR-1995 DSAXBY        40.28               Reverse 'H_HHMM' uom.
 31-MAR-1995 DSAXBY        40.27               Now insert assignment action
                                               with status = 'U' for a non
                                               tracked action type ('N').
 24-MAR-1995 DSAXBY        40.26               Now call undo_stop_update
                                               procedure instead of hr_ent_api
                                               delete_element_entry.
 13-FEB-1995 DSAXBY        40.25               Fix problem causing 7010 error
                                               when inserting quickpay assact.
 31-JAN-1995 DSAXBY        40.24               Must not trash latest balances
                                               for an action type of 'N'.
 16-DEC-1994 DSAXBY        40.23               Added qpppassact.
                                               Delete pre_payment rows for
                                               QuickPay Pre-Payment process.
 25-NOV-1994 DSAXBY        40.22               Change in params to qpassact.
 26-OCT-1994 DSAXBY        40.21               Delete from the
                                               pay_balance_context_values
                                               table where necessary.
                                               Set time_period_id for
                                               balance adjustments.
                                               Created public versions of
                                               validate_pact_rollback and
                                               validate_assact_rollback
                                               procedures. (To be called from
                                               forms).
                                               Prevent mark for retry for
                                               Balance Adjustment. Note this
                                               check has been moved
                                               val_pact_rollback procedure.
                                               Insert value for the
                                               time_period_id column when
                                               processing balance adjustment.
                                               Alter rules and strategy for
                                               checking rules for rolling back
                                               and marking for retry assignment
                                               and payroll actions.
                                               Disabled all uses of the
                                               business_group_id index.
 05-OCT-1994 DKERR         40.20               Set the OBJECT_VERSION_NUMBER
                                               to 1 for inserts into
                                               PAY_PAYROLL_ACTIONS and
                                               PAY_ASSIGNMENT_ACTIONS for
                                               all action types.
 28-JUN-1994 DSAXBY        40.19               Added line to decode statement
                                               in reversal routine, to
                                               prevent invalid number errors.
                                               Delete from pay_costs and
                                               pay_quickpay_inclusions when
                                               we roll back.
                                               Do not attempt to delete from
                                               pay_pre_payments, unless we are
                                               rolling back a Pre-Payment!
 21-JUN-1994 CSWAN         40.18               For reversal RRVs, flip the
                                               sign of the RRVs being reversed,
                                               rather than prepending a '-'
                                               character, which leads to
                                               balance errors.
 28-MAR-1994 DSAXBY        40.17    G622       Set updating_action_id to null
                                               when rolling back update rec
                                               entries which were corrections.
 18-MAR-1994 DSAXBY        40.16    G172       Improved messaging for rollback
                                               assignment action. Added message
                                               for rollback payroll action.
 28-FEB-1994 DSAXBY        40.15    G585       Allow nested mark for retry.
                                               Prevent marking payment action
                                               types for retry.
 05-JAN-1994 DSAXBY        40.14    G481       Only process NEE when reversing
                                               effective of stop and update
                                               rules.
 20-DEC-1993 DSAXBY        40.13    G454       Delete pre-payment rows.
                                    G283/      Ensure interlock rows are
                                    G272       deleted if rollback assact is
                                               called from form.
                                    ----       Altered DELETE_NEXT_CHANGE to
                                               FUTURE_CHANGE for rollback of
                                               REE update feature.
 17-DEC-1993 DSAXBY        40.12    G277       Updated incorrect comments.
 14-DEC-1993 DSAXBY        40.11    G277       Rolling back of Update and
                                               stop REE rules.
                                               pay_element_entry_values table).
 13-DEC-1993 CSWAN         40.10    G410       Removed reference to removed
                                               PLANNED_PAYMENT_DATE column.
 13-DEC-1993 AFRITH        40.9     G396       Unsequenced assignment actions
                                               not interlocked by sequenced
                                               actions  .
 09-DEC-1993 DSAXBY        40.8     G320       Handle ND unit of measure.
 06-DEC-1993 DSAXBY        40.7     G296       Prevent looping on rollback or
                                               mark for retry when assignment
                                               actions are not to be
                                               (correctly) rolled back or
                                               marked for retry.
 12-NOV-1993 DSAXBY        40.6     G36        Handled non tracked action
                                               properly again.
 29-OCT-1993 RPATEL        40.5                Added functionality for
                                               Manual/External Payments,
                                               error handling invalid action.
 26-OCT-1993 DSAXBY        40.4                Added some missing error mesg.
                                               Prevent Reversal of something
                                               that is already reversed.
                                               Trash latest balances for Rev
                                               and Balance Adjustment. (Needed
                                               to add del_latest_balances).
 20-OCT-1993 AFRITH        40.3                Added BACKPAY mode.
 19-OCT-1993 DSAXBY        40.2                Altered bal_adjust. No longer
                                               a function, now procedure and
                                               updates creator_id.
                                               Fixed payroll action roll back.
 13-AUG-1993 DSAXBY        40.1                Fix interlock delete.
 28-JUL-1993 DSAXBY        30.8                Work on reversal and bal_adjust
 20-JUL-1993 DSAXBY        30.7                Added bal_adjust.
 24-FEB-1999 J. Moyano    115.5                MLS Changes. Reference to
                                               pay_payment_types_tl included in
                                               procedure do_pact_rollback.
 11-SEP-2000 divicker     115.18               Performance changes
-----------+-------------+-------+----------+-------------------------------+
*/
--
--
/*--------------------------  RECORD types ---------------------------*/
--
type context_cache_type is record
(
 cxt_id                    number_tbl,
 cxt_name                  varchar_60_tbl,
 sz                        number
);
--
type assact_details is record
(assact_id                 pay_assignment_actions.assignment_action_id%type,
 assignment_id             pay_assignment_actions.assignment_id%type,
 full_name                 per_all_people_f.full_name%type,
 assignment_number         per_all_assignments_f.assignment_number%type,
 payroll_id                per_all_assignments_f.payroll_id%type);
--
type pact_details is record
(pact_id                   pay_payroll_actions.payroll_action_id%type,
 action_name               hr_lookups.meaning%type,
 action_type               pay_payroll_actions.action_type%type,
 sequenced_flag            boolean,
 action_date               date,
 current_date              date, -- this is sysdate.
 payroll_name              pay_all_payrolls_f.payroll_name%type,
 bg_name                   hr_organization_units.name%type,
 independent_periods_flag  boolean);
--
 c_eot constant date := to_date('31/12/4712','DD/MM/YYYY');
 g_context_cache context_cache_type;
 contexts_cached boolean := FALSE;
 g_lat_bal_check_mode pay_action_parameters.parameter_value%TYPE := null;
 g_debug boolean := hr_utility.debug_enabled;
 g_dynamic_contexts          pay_core_utils.t_contexts_tab;
--
--
--
/*------------------------ val_pact_rr_rules ---------------------------*/
--
procedure val_pact_rr_rules (p_pact_rec      in pact_details,
                             p_rollback_mode in varchar2) is
begin
   if p_rollback_mode = 'RETRY' then
      if p_pact_rec.action_type in ('V', 'B', 'Z', 'E', 'H') then
         hr_utility.set_message(801, 'HR_7093_ACTION_CANT_RETPAY');
         hr_utility.set_message_token('ACTION_NAME',p_pact_rec.action_name);
         hr_utility.raise_error;
      end if;
   else
      if p_pact_rec.action_type = 'Z' then
         hr_utility.set_message(801, 'HR_7212_ACTION_RBACK_RULE');
         hr_utility.set_message_token('ACTION_NAME',p_pact_rec.action_name);
         hr_utility.raise_error;
      end if;
   end if;
end val_pact_rr_rules;
--
--
/*------------------------ val_assact_rr_rules -------------------------*/
--
function val_assact_rr_rules (p_pact_rec      in pact_details,
                              p_rollback_mode in varchar2)
                              return boolean is
begin
--
   -- Validate the rollback and mark for retry rules for
   -- assignment actions.
   if g_debug then
      hr_utility.set_location('hrassact.val_assact_rr_rules', 10);
   end if;
   if p_rollback_mode = 'RETRY' then
      if p_pact_rec.action_type in ('V', 'B', 'Z', 'E', 'M', 'H', 'T') then
         return false;
      end if;
   else
      if p_pact_rec.action_type in ('Q', 'V', 'B', 'Z', 'U', 'E', 'M', 'T')
      then
         return false;
      end if;
   end if;
--
   return true;
end val_assact_rr_rules;
--
--
/*----------------------- validate_rollback_mode ----------------------*/
--
procedure validate_rollback_mode(p_rollback_mode in varchar2) is
begin
   if p_rollback_mode not in ('RETRY', 'ROLLBACK', 'BACKPAY') then
      hr_utility.set_message(801, 'HR_7000_ACTION_BAD_ROLL_MODE');
      hr_utility.raise_error;
   end if;
end validate_rollback_mode;
--
--
/*-----------------------  ensure_assact_rolled_back ----------------------*/
/*
 *   This routine checks that the target assignment action appears to
 *   have been rolled back prior to it's deletion (i.e, must have no
 *   attached run results, latest balances, quickpay inclusions, etc).
 *
 *   There are two levels of checking, since this routine is also
 *   used to check whether a RETRY can be performed (in which case any
 *   EEs created by a QuickPay are allowed to remain).
 */
procedure ensure_assact_rolled_back (p_assact_id in number,
                                     p_rollback_mode in varchar2) is
--
   cursor c1 is
   select null from dual
   where exists
      (select null                 --  check for any RRs
       from   pay_run_results
       where  assignment_action_id = p_assact_id)
   or exists
      (select null                 --  check for any MESSAGEs
       from   pay_message_lines
       where  source_type = 'A'
       and    source_id = p_assact_id)
--   or exists                       --  check for any latest balances
--      (select null
--       from   pay_assignment_latest_balances
--       where  assignment_action_id = p_assact_id)
--   or exists                       --  check for any latest balances
--      (select null
--       from   pay_person_latest_balances
--       where  assignment_action_id = p_assact_id)
--   or exists                       --  check for any latest balances
--      (select null
--       from   pay_latest_balances
--       where  assignment_action_id = p_assact_id)
   or exists                       --  check for updates to REEs
       (select null
        from   pay_element_entries_f
        where  updating_action_id = p_assact_id);
--
   cursor c2 is
   select null from dual
   where exists
      (select null                 --  check for any RRs
       from   pay_run_results
       where  assignment_action_id = p_assact_id
         and  status <> 'B')
   or exists
      (select null                 --  check for any MESSAGEs
       from   pay_message_lines
       where  source_type = 'A'
       and    source_id = p_assact_id)
--   or exists                       --  check for any latest balances
--      (select null
--       from   pay_assignment_latest_balances
--       where  assignment_action_id = p_assact_id)
--   or exists                       --  check for any latest balances
--      (select null
--       from   pay_person_latest_balances
--       where  assignment_action_id = p_assact_id)
--   or exists                       --  check for any latest balances
--      (select null
--       from   pay_latest_balances
--       where  assignment_action_id = p_assact_id)
   or exists                       --  check for updates to REEs
       (select null
        from   pay_element_entries_f
        where  updating_action_id = p_assact_id);
--
begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hrassact.ensure_assact_rolled_back',10);
   end if;
   validate_rollback_mode(p_rollback_mode);
--
   if (p_rollback_mode = 'BACKPAY') then
--
     if g_debug then
        hr_utility.set_location('hrassact.ensure_assact_rolled_back',20);
     end if;
     for c2rec in c2 loop
        --  any record fetched is an error
        hr_utility.set_message(801, 'HR_7001_ACTION_MUST_ROLL_FIRST');
        hr_utility.set_message_token('ASSACTID',p_assact_id);
        hr_utility.raise_error;
     end loop;
--
   else
--
     if g_debug then
        hr_utility.set_location('hrassact.ensure_assact_rolled_back',30);
     end if;
     for c1rec in c1 loop
        --  any record fetched is an error
        hr_utility.set_message(801, 'HR_7001_ACTION_MUST_ROLL_FIRST');
        hr_utility.set_message_token('ASSACTID',p_assact_id);
        hr_utility.raise_error;
     end loop;
--
   end if;
--
   return;
end ensure_assact_rolled_back;
--
--
/*-----------------------  ensure_pact_rolled_back ----------------------*/
/*
 *   This routine checks that the payroll action about to be rolled
 *   back has no assignment actions attached to it which would indicate that
 *   the rollback_payroll_action procedure has not been called.
 */
procedure ensure_pact_rolled_back (p_pact_id in number) is
   cursor c1 is
   select null
   from   dual
   where exists
      (select null                 --  check for any ASSACTs
       from   pay_assignment_actions
       where  payroll_action_id = p_pact_id)
   or exists
      (select null                 --  check for any MESSAGEs
       from   pay_message_lines
       where  source_type = 'P'
       and    source_id = p_pact_id);
begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hrassact.ensure_pact_rolled_back',10);
   end if;
   for c1rec in c1 loop
      --  any record fetched is an error
      hr_utility.set_message(801, 'HR_7007_ACTION_ROLL_ASSACTS');
      hr_utility.raise_error;
   end loop;
   return;
end ensure_pact_rolled_back;
--
--
/*-----------------------  val_assact_rollback  ----------------------*/
/*
 *   This routine checks whether the specified assignment action can be
 *   rolled back, but relies on parameters for all information at a
 *   higher level than the ass action (e.g, for action type). This is
 *   more efficient when testing a lot of actions on the same payroll
 *   action.
 *
 *   This means that any rollback checks at a higher level (e.g, can't
 *   rollback a purge) must also have been performed.
 *
 *   This routine is not needed to validate a mark for BACKPAY operation.
 */
function val_assact_rollback (p_pact_rec in pact_details,
                              p_assact_rec in out nocopy assact_details,
                              p_rollback_mode in varchar2)
   return boolean is
--
   l_action_sequence     pay_assignment_actions.action_sequence%type;
   l_action_status       pay_assignment_actions.action_status%type;
   l_person_id           per_all_people_f.person_id%type;
begin
--
   g_debug := hr_utility.debug_enabled;
   --  Obtain information about this assignment action which we will
   --  need later on.
   --  Some of this is required for messages.
   if g_debug then
      hr_utility.set_location('hrassact.val_assact_rollback',10);
   end if;
   select ACT.assignment_id,
          ACT.action_sequence,
          ACT.action_status,
          ASS.payroll_id,
          POS.person_id,
          substr(PEO.full_name,1,80),
          ASS.assignment_number
   into   p_assact_rec.assignment_id,
          l_action_sequence,
          l_action_status,
          p_assact_rec.payroll_id,
          l_person_id,
          p_assact_rec.full_name,
          p_assact_rec.assignment_number
   from   per_periods_of_service POS,
          per_all_assignments_f  ASS,
          per_all_people_f       PEO,
          pay_assignment_actions ACT
   where  ACT.assignment_action_id = p_assact_rec.assact_id
   and    ASS.assignment_id        = ACT.assignment_id
   and    p_pact_rec.action_date between
          ASS.effective_start_date and ASS.effective_end_date
   and    PEO.person_id            = ASS.person_id
   and    p_pact_rec.action_date between
          PEO.effective_start_date and PEO.effective_end_date
   and    POS.period_of_service_id = ASS.period_of_service_id;
--
   --  can only retry if already complete
   if p_rollback_mode = 'RETRY' and l_action_status not in ('C', 'S') then
      return FALSE;
   end if;
--
--
   --
   -- If rolling back or retrying, we need to know if assignments
   -- can be considered in isolation (as prescribed by the
   -- independent time periods flag for this legislation). Assignments
   -- with no Payroll are independent.
   --
   -- Operation is disallowed if this is a sequenced action AND there
   -- exists any sequenced actions in the future. Also disallowed
   -- if any child action exists (e.g can't rollback a run if already
   -- costed).
   -- Note - exception is if are attempting to roll back Reversal or
   -- Balance Adjustment actions, where we do not bother to perform
   -- the future actions check.
   --
   declare
      dummy number;
   begin
         -- For either legislation, examine the assignment action
         -- to see if it is locked by another action. Peform
         -- slightly different checks for RETRY and ROLLBACK
         -- modes. See comments below.
         if g_debug then
            hr_utility.set_location('hrassact.val_assact_rollback',20);
         end if;
         if(p_rollback_mode = 'RETRY') then
            -- Case for RETRY mode.
            -- Check that the assignment action we are attempting to
            -- mark for retry is not locked by an assignment action
            -- that has an action_status that is not mark for retry.
            select null
            into   dummy
            from   dual
            where  not exists (
                   select null
                   from   pay_action_interlocks int,
                          pay_assignment_actions act
                   where  int.locked_action_id     =  p_assact_rec.assact_id
                   and    act.assignment_action_id =  int.locking_action_id
                   and    act.action_status        <> 'M');
         else
            -- Case for ROLLBACK mode.
            -- Check that the assignment action we are attempting to
            -- roll back is not locked by an assignment action.
            select null
            into   dummy
            from   dual
            where  not exists (
                   select null
                   from   pay_action_interlocks int
                   where  int.locked_action_id = p_assact_rec.assact_id);
         end if;
--
         --   Now, if we have a balance adjustment or Reversal,
         --   we do not bother to check for actions in the future,
         --   because these are special cases.
--
         --   Referring to above comments, the reversal has been
         --   extended to incorporate new functionality to now
         --   check for future payroll run actions that now interlock
         if (p_pact_rec.action_type <> 'B'
             and p_pact_rec.action_type <> 'I'
             and p_pact_rec.action_type <> 'V')
         then
            -- Check the legislation case.
            if p_pact_rec.independent_periods_flag then
--
               --   check for other actions on this ASSIGNMENT
               --   Perform different checks for RETRY or ROLLBACK.
               if g_debug then
                  hr_utility.set_location('hrassact.val_assact_rollback',30);
               end if;
               if(p_rollback_mode = 'RETRY') then
                  -- Case for RETRY mode.
                  -- Disallow mark for retry assignment action
                  -- if there are future SEQUENCED assignment actions
                  -- for the assignment and these actions are not
                  -- marked for retry.
                  select null into dummy
                  from   dual
                  where  not exists
                     (select null
                     from   pay_assignment_actions      ACT,
                             pay_payroll_actions         PACT,
                             pay_action_classifications CLASS,
                             pay_action_classifications CLAS2
                      where  ACT.assignment_id  = p_assact_rec.assignment_id
                      and    ACT.action_sequence       > l_action_sequence
                      and    ACT.action_status        <> 'M'
                      and    ACT.payroll_action_id     = PACT.payroll_action_id
                      and    PACT.action_type          = CLASS.action_type
                      and    CLASS.classification_name = 'SEQUENCED'
                      and    CLAS2.action_type         = p_pact_rec.action_type
                      and    CLAS2.classification_name = 'SEQUENCED' );
               else
                  -- Case for ROLLBACK mode.
                  -- Disallow rollback assignment action
                  -- if there are future SEQUENCED assignment actions
                  -- for the assignment.
                  select null into dummy
                  from   dual
                  where  not exists
                     (select null
                      from   pay_assignment_actions     ACT,
                             pay_payroll_actions        PACT,
                             pay_action_classifications CLASS,
                             pay_action_classifications CLAS2
                      where  ACT.assignment_id     = p_assact_rec.assignment_id
                      and    ACT.action_sequence       > l_action_sequence
                      and    ACT.payroll_action_id     = PACT.payroll_action_id
                      and    PACT.action_type          = CLASS.action_type
                      and    CLASS.classification_name = 'SEQUENCED'
                      and    CLAS2.action_type         = p_pact_rec.action_type
                      and    CLAS2.classification_name = 'SEQUENCED' );
               end if;
             else
               --   check for other actions on this PERSON
               --   As above, perform different checks for
               --   RETRY and ROLLBACK modes.
               if g_debug then
                  hr_utility.set_location('hrassact.val_assact_rollback',40);
               end if;
               if(p_rollback_mode = 'RETRY') then
                  -- Case for RETRY mode.
                  select null into dummy
                  from   dual
                  where  not exists
                     (select null
                      from   pay_action_classifications CLASS,
                             pay_action_classifications CLAS2,
                             pay_payroll_actions        PACT,
                             pay_assignment_actions     ACT,
                             per_all_assignments_f          ASS,
                             per_periods_of_service     POS
                      where  POS.person_id             = l_person_id
                      and    ASS.period_of_service_id = POS.period_of_service_id
                      and    ACT.assignment_id         = ASS.assignment_id
                      and    ACT.action_sequence       > l_action_sequence
                      and    ACT.action_status        <> 'M'
                      and    ACT.payroll_action_id     = PACT.payroll_action_id
                      and    PACT.action_type          = CLASS.action_type
                      and    CLASS.classification_name = 'SEQUENCED'
                      and    CLAS2.action_type         = p_pact_rec.action_type
                      and    CLAS2.classification_name = 'SEQUENCED' );
               else
                  -- Case for ROLLBACK mode.
                  select null into dummy
                  from   dual
                  where  not exists
                     (select null
                      from   pay_action_classifications CLASS,
                             pay_action_classifications CLAS2,
                             pay_payroll_actions        PACT,
                             pay_assignment_actions     ACT,
                             per_all_assignments_f          ASS,
                             per_periods_of_service     POS
                      where  POS.person_id             = l_person_id
                      and    ASS.period_of_service_id = POS.period_of_service_id
                      and    ACT.assignment_id         = ASS.assignment_id
                      and    ACT.action_sequence       > l_action_sequence
                      and    ACT.payroll_action_id     = PACT.payroll_action_id
                      and    PACT.action_type          = CLASS.action_type
                      and    CLASS.classification_name = 'SEQUENCED'
                      and    CLAS2.action_type         = p_pact_rec.action_type
                      and    CLAS2.classification_name = 'SEQUENCED' );
               end if;
            end if;
         end if;
--
   exception
      when no_data_found then
         if g_debug then
            hr_utility.set_location('hrassact.val_assact_rollback',50);
         end if;
         return FALSE;
--
   end;
--
   if g_debug then
      hr_utility.set_location('hrassact.val_assact_rollback',60);
   end if;
   return TRUE;
--
end val_assact_rollback;
--
--
/*-----------------------  val_pact_rollback -------------------------*/
/*
 *   This routine is called before a rollback to get any payroll action level
 *   information (e.g, action type) whch will be needed. This routine also
 *   performs some validation as to whether the action can be rolled back,
 *   and so may fail.
 */
procedure val_pact_rollback (p_pact_rec in out nocopy pact_details,
                                  p_rollback_mode in varchar2 ) is
--
   l_business_group_id   hr_organization_units.business_group_id%type;
begin
--
   validate_rollback_mode(p_rollback_mode);
--
   --  get payroll action level information
   if g_debug then
      hr_utility.set_location('hrassact.val_pact_rollback', 10);
   end if;
   select pac.business_group_id,
          pac.effective_date,
          hrl.meaning,
          pac.action_type,
          trunc(sysdate),
          pay.payroll_name,
          grp.name
   into   l_business_group_id,
          p_pact_rec.action_date,
          p_pact_rec.action_name,
          p_pact_rec.action_type,
          p_pact_rec.current_date,
          p_pact_rec.payroll_name,
          p_pact_rec.bg_name
   from   pay_payroll_actions pac,
          pay_all_payrolls_f  pay,
          per_business_groups_perf grp,
          hr_lookups          hrl
   where  pac.payroll_action_id     = p_pact_rec.pact_id
   and    hrl.lookup_code           = pac.action_type
   and    hrl.lookup_type           = 'ACTION_TYPE'
   and    grp.business_group_id     = pac.business_group_id
   and    pay.payroll_id (+)        = pac.payroll_id
   and    pac.effective_date between
          pay.effective_start_date (+) and pay.effective_end_date (+);
   if g_debug then
      hr_utility.trace('action type is ' || p_pact_rec.action_type );
   end if;
--
--
   --  some types (e.g, purge) of action can't be rolled back full stop.
   declare
      dummy number;
   begin
      if g_debug then
         hr_utility.set_location('hrassact.val_pact_rollback', 20);
      end if;
      select null
      into   dummy
      from   dual
      where  not exists
         (select null
          from   pay_action_classifications
          where  action_type = p_pact_rec.action_type
          and    classification_name = 'NONREMOVEABLE');
   exception
      when no_data_found then
         hr_utility.set_message(801, 'HR_6216_ACTION_CANT_PURGE');
         hr_utility.set_message_token('PACT_ID',
                                    to_char(p_pact_rec.pact_id));
         hr_utility.raise_error;
   end;
--
--
   --  get some more info needed to roll back actions
   if g_debug then
      hr_utility.set_location('hrassact.val_pact_rollback', 30);
   end if;
   if upper( hr_leg_rule.get_independent_periods(l_business_group_id))
      like 'Y%' then
      p_pact_rec.independent_periods_flag := TRUE;
   else
      p_pact_rec.independent_periods_flag := FALSE;
   end if;
--
--
   --  see if this type of action is sequenced or not
   declare
      dummy number;
   begin
      p_pact_rec.sequenced_flag := TRUE;
--
      if g_debug then
         hr_utility.set_location('hrassact.val_pact_rollback', 40);
      end if;
      select null
      into   dummy
      from   pay_action_classifications CLASS
      where  CLASS.action_type = p_pact_rec.action_type
      and    CLASS.classification_name = 'SEQUENCED';
      if g_debug then
         hr_utility.trace('this action type IS sequenced');
      end if;
   exception
      when no_data_found then
         p_pact_rec.sequenced_flag := FALSE;
         if g_debug then
            hr_utility.trace('this action type NOT sequenced');
         end if;
   end;
end val_pact_rollback;
--
--
procedure validate_pact_rollback
(
   p_payroll_action_id in number,
   p_rollback_mode     in varchar2
) is
   l_pact_rec pact_details;
begin
   g_debug := hr_utility.debug_enabled;
--
   -- We simply call the internal validate rollback procedure
   -- to give us the information we need.
   if g_debug then
      hr_utility.set_location('hrassact.validate_pact_rollback', 10);
   end if;
   l_pact_rec.pact_id := p_payroll_action_id;
--
   val_pact_rollback(p_pact_rec      => l_pact_rec,
                     p_rollback_mode => p_rollback_mode);
--
   -- Rollback and Mark for retry rules
   val_pact_rr_rules(l_pact_rec, p_rollback_mode);
--
end validate_pact_rollback;
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
) return boolean is
   l_pact_rec   pact_details;
   l_assact_rec assact_details;
   result       boolean;
begin
   g_debug := hr_utility.debug_enabled;
--
   -- Call the validate payroll action routine to get pact details.
   if g_debug then
      hr_utility.set_location('hrassact.validate_assact_rollback',10);
   end if;
   l_pact_rec.pact_id := p_payroll_action_id;
   val_pact_rollback(p_pact_rec      => l_pact_rec,
                     p_rollback_mode => p_rollback_mode);
--
   -- Call the validate assignment action routine to validate assact.
   if g_debug then
      hr_utility.set_location('hrassact.validate_assact_rollback',20);
   end if;
   l_assact_rec.assact_id := p_assignment_action_id;
--
   if val_assact_rollback(l_pact_rec, l_assact_rec, p_rollback_mode) and
      val_assact_rr_rules(l_pact_rec, p_rollback_mode)
   then
      return true;
   else
      return false;
   end if;
end validate_assact_rollback;
--
--
--
/*-----------------------  trash_quickpay  ----------------------------*/
/*
 *   This procedure removes any entries inserted for a Quickpay action
 */
procedure trash_quickpay (p_action_id number) is
   cursor c1 is
   select pee.element_entry_id
   from   pay_element_entries_f pee,
          pay_assignment_actions paa
   where  pee.creator_type = 'Q'
   and    pee.creator_id = paa.assignment_action_id
   and    pee.assignment_id = paa.assignment_id
   and    paa.assignment_action_id = p_action_id
   for update of pee.element_entry_id;
--
begin
   --  For QuickPay actions, we delete the entries which were
   --  inserted as part of the Quickpay transaction. Any processed run
   --  results were trashed in a previous step.
   begin
      -- We wish to remove the QuickPay inclusions.
      if g_debug then
         hr_utility.set_location('hrassact.trash_quickpay',10);
      end if;
--
      -- Enhancement 3368211
      -- Delete from both PAY_QUICKPAY_INCLUSIONS and
      -- PAY_QUICKPAY_EXCLUSIONS.
      --
      -- There is a chance the assignment action id exists in both tables if
      -- the assignment action was created before the QuickPay Exclusions
      -- data model was in use.
      delete from pay_quickpay_exclusions
      where  assignment_action_id = p_action_id;
--
      delete from pay_quickpay_inclusions
      where  assignment_action_id = p_action_id;
--
      if g_debug then
         hr_utility.set_location('hrassact.trash_quickpay',20);
      end if;
      for c1rec in c1 loop
--
         --  delete any unprocessed run result attached to the entry.
         if g_debug then
            hr_utility.set_location('hrassact.trash_quickpay',30);
         end if;
         delete from pay_run_result_values RRV
         where  RRV.run_result_id in
            (select RR.run_result_id
             from   pay_run_results RR
             where  RR.source_type = 'E'
             and    RR.source_id = c1rec.element_entry_id);
--
         if g_debug then
            hr_utility.set_location('hrassact.trash_quickpay',40);
         end if;
         delete from pay_run_results RR
         where  RR.source_type = 'E'
         and    RR.source_id = c1rec.element_entry_id;
--
         --  delete any element entry values
         if g_debug then
            hr_utility.set_location('hrassact.trash_quickpay',50);
         end if;
         delete from pay_element_entry_values_f EEV
         where  EEV.element_entry_id = c1rec.element_entry_id;
--
         --  delete the entry itself
         if g_debug then
            hr_utility.set_location('hrassact.trash_quickpay',60);
         end if;
         delete from pay_element_entries_f
         where  current of c1;
--
      end loop;
   end;
--
   if g_debug then
      hr_utility.set_location('hrassact.trash_quickpay',60);
   end if;
   return;
--
end trash_quickpay;
--
--
--

/*------------------------ undo_stop_update -----------------------------*/
/*
 * This procedure is called when we have detected the need to undo the
 * effect of a stop or update recurring entry formula result rule.
 * Note that, due to the complexity of calculating entry end dates, we
 * call the existing routine, but trap error messages that are
 * inappropriate for our application.
 */
procedure undo_stop_update(
   p_ee_id in number,
   p_mult  in varchar,
   p_date  in date,
   p_mode  in varchar2) is
--
   -- Local variables.
   effstart   date;
   effend     date;
   val_start  date;
   val_end    date;
   next_end   date;
   orig_ee_id number;
   asg_id     number;
   el_id      number;
   c_indent   constant varchar2(30) := 'pyassact.undo_stop_update';
begin
   -- Select some information about the entry we are operating on.
   if g_debug then
      hr_utility.set_location(c_indent, 10);
   end if;
   select pee.effective_start_date,
          pee.effective_end_date,
          pee.original_entry_id,
          pee.assignment_id,
          pee.element_link_id
   into   effstart, effend, orig_ee_id, asg_id, el_id
   from   pay_element_entries_f pee
   where  pee.element_entry_id = p_ee_id
   and    p_date between
          pee.effective_start_date and pee.effective_end_date;
--
   -- Do nothing if the entry end date is end of time.
   if(effend = c_eot) then
      return;
   end if;
--
   -- For undo update, we have to get next effective start date.
   if(p_mode = 'DELETE_NEXT_CHANGE') then
      begin
         if g_debug then
            hr_utility.set_location(c_indent, 20);
         end if;
         select min(ee.effective_end_date)
         into   next_end
         from   pay_element_entries_f ee
         where  ee.element_entry_id     = p_ee_id
         and    ee.effective_start_date > effend;
      exception
         when no_data_found then null;
      end;
--
      val_start := effend + 1;
--
      if next_end is null then
         val_end := c_eot;
      else
         val_end := next_end;
      end if;
   elsif(p_mode = 'FUTURE_CHANGE') then
      val_start := effend + 1;
      val_end   := c_eot;
   end if;
--
   -- For either mode, we need to obtain the date to which
   -- we may legally extend the entry.
   declare
      message    varchar2(200);
      applid     varchar2(200);
   begin
      val_end := hr_entry.recurring_entry_end_date (
                  asg_id, el_id, p_date, 'Y', p_mult, p_ee_id, orig_ee_id);
   exception
      -- Several error messages can be raised from this procedure.
      -- We wish to trap a number of them, as they should be ignored
      -- for our purposes.
      when hr_utility.hr_error then
      hr_utility.get_message_details(message,applid);
--
      if(message in ('HR_7699_ELE_ENTRY_REC_EXISTS',
                     'HR_7700_ELE_ENTRY_REC_EXISTS',
                     'HR_6281_ELE_ENTRY_DT_DEL_LINK',
                     'HR_6283_ELE_ENTRY_DT_ELE_DEL',
                     'HR_6284_ELE_ENTRY_DT_ASG_DEL')
      ) then
         -- We cannot extend the entry.
         if g_debug then
            hr_utility.set_location(c_indent, 25);
         end if;
         return;
      else
         -- Should fail if it is anything else.
         raise;
      end if;
   end;
--
   -- May need to check for entry overlap.
   if(p_mult = 'N') then
--
      declare dummy number;
      begin
         if g_debug then
            hr_utility.set_location(c_indent, 30);
         end if;
         select null
         into   dummy
         from   pay_element_entries_f ee
         where  ee.entry_type = 'E'
         and    ee.element_entry_id <> p_ee_id
         and    ee.assignment_id     = asg_id
         and    ee.element_link_id   = el_id
         and   (ee.effective_start_date <= val_end and
                ee.effective_end_date   >= val_start);
--
         -- If row returned, we are in trouble.
         hr_utility.set_message(801, 'HR_6956_ELE_ENTRY_OVERLAP');
         hr_utility.raise_error;
--
     exception
       when no_data_found then null;
     end;
   end if;
--
   -- May need to set validation end date to the end of time.
   if((p_mode = 'FUTURE_CHANGE') or
       (p_mode = 'DELETE_NEXT_CHANGE' and
        val_end = c_eot)
   ) then
      effend := val_end;
   end if;
--
   -- Process the delete of element entries.
   if(p_mode = 'DELETE_NEXT_CHANGE') then
      if g_debug then
         hr_utility.set_location(c_indent, 40);
      end if;
      delete from pay_element_entries_f ee
      where  ee.element_entry_id     = p_ee_id
      and    ee.effective_start_date = val_start;
--
      if g_debug then
         hr_utility.set_location(c_indent, 50);
      end if;
      update pay_element_entries_f ee
      set    ee.effective_end_date = decode(val_end, c_eot, effend, val_end)
      where  ee.element_entry_id     = p_ee_id
      and    ee.effective_start_date = effstart;
--
   elsif(p_mode = 'FUTURE_CHANGE') then
--
      if g_debug then
         hr_utility.set_location(c_indent, 60);
      end if;
      delete from pay_element_entries_f ee
      where  ee.element_entry_id     = p_ee_id
      and    ee.effective_start_date > effstart;
--
      if g_debug then
         hr_utility.set_location(c_indent, 70);
      end if;
      update pay_element_entries_f ee
      set    ee.effective_end_date = effend
      where  ee.element_entry_id   = p_ee_id
      and  ee.effective_start_date = effstart;
   end if;
--
   -- Now, delete the entry values between validation start/end dates..
--
   if g_debug then
      hr_utility.set_location(c_indent, 80);
   end if;
   delete from pay_element_entry_values_f eev
   where  eev.element_entry_id = p_ee_id
   and    ((eev.effective_end_date between val_start and val_end)
      or    (eev.effective_start_date between val_start and val_end));
--
   -- Update the effective end date as appropriate.
   if g_debug then
      hr_utility.set_location(c_indent, 90);
   end if;
   update  pay_element_entry_values_f eev
   set     eev.effective_end_date = val_end
   where   eev.element_entry_id   = p_ee_id
   and     p_date between
           eev.effective_start_date and eev.effective_end_date;
--
end undo_stop_update;
--
/*-----------------------  do_assact_rollback  ---------------------------*/
/*
 *
 *   This procedure performs all third party DML and validation
 *   needed to support the rollback, mark for retry or mark
 *   for backpay of an assignment action.
 *
 *   For the definitive list of action types, see the ACTION TYPE
 *   domain in CASE.
 *
 *   Any deletes of child records which should only be performed for
 *   rollback, rather than for both retry and rollback, are performed
 *   either via cascading constraints or via the delete trigger on
 *   assignment actions.
 *
 */
procedure do_assact_rollback (p_pact_rec in pact_details,
                              p_assact_rec in assact_details,
                              p_rollback_mode in varchar2,
                              p_leave_base_table_row in boolean) is
begin
--
   if p_pact_rec.sequenced_flag then
--
      --  Delete any Run Results which were created by this action. This
      --  will have no effect for unsequenced actions such as
      --  Pre-Payments. For efficiency there should be no cascade
      --  trigger on Run Results so we need to trash the values as well.
      if g_debug then
         hr_utility.set_location('hrassact.do_assact_rollback',10);
      end if;
      delete from pay_run_result_values RRV
      where  RRV.run_result_id in
         (select RR.run_result_id
          from   pay_run_results RR
          where  RR.assignment_action_id = p_assact_rec.assact_id);
--
      if g_debug then
         hr_utility.set_location('hrassact.do_assact_rollback',20);
      end if;
      delete from pay_run_results RR
      where  RR.assignment_action_id = p_assact_rec.assact_id;
--
      --  Delete latest balances. Not deleted via constraint due to
      --  performance requirements on Insert and Update, and also because
      --  they need to go for retry as well as rollback.
      --  Start with any balance context values.
      if g_debug then
         hr_utility.set_location('hrassact.do_assact_rollback',25);
      end if;
      delete from pay_balance_context_values VAL
      where  exists (
             select null
             from   pay_person_latest_balances PLB
             where  PLB.assignment_action_id = p_assact_rec.assact_id
             and    VAL.latest_balance_id    = PLB.latest_balance_id);
--
      if g_debug then
         hr_utility.set_location('hrassact.do_assact_rollback',30);
      end if;
      delete from pay_person_latest_balances PLB
      where  PLB.assignment_action_id = p_assact_rec.assact_id;
--
      if g_debug then
         hr_utility.set_location('hrassact.do_assact_rollback',35);
      end if;
      delete from pay_balance_context_values VAL
      where  exists (
             select null
             from   pay_assignment_latest_balances ALB
             where  ALB.assignment_action_id = p_assact_rec.assact_id
             and    VAL.latest_balance_id    = ALB.latest_balance_id);
--
      if g_debug then
         hr_utility.set_location('hrassact.do_assact_rollback',40);
      end if;
      delete from pay_assignment_latest_balances ALB
      where  ALB.assignment_action_id = p_assact_rec.assact_id;
--
      -- If the payroll action that is being deleted is
      -- a Balance Adjustment (type = 'B'), then we attempt to
      -- delete the element entry row and element entry rows
      -- that are associated with it.
      if p_pact_rec.action_type = 'B' then
         -- Do the business for Balance Adjustment.
         declare
            v_eeid number; -- the element entry id.
         begin
            -- Start by selecting the element_entry_id
            -- that we need to delete.
            -- We are joining effective dates only to hit the whole
            -- index, because there should only be the one row anyway.
--            hr_utility.set_location('hrassact.do_assact_rollback',50);
            select pee.element_entry_id
            into   v_eeid
            from   pay_element_entries_f pee
            where  pee.creator_id = p_assact_rec.assact_id
            and    pee.assignment_id = p_assact_rec.assignment_id
            and    p_pact_rec.action_date between
                   pee.effective_start_date and pee.effective_end_date;
--
            -- Now, we attempt to delete the entry values.
--            hr_utility.set_location('hrassact.do_assact_rollback',60);
            delete from pay_element_entry_values_f pev
            where  pev.element_entry_id = v_eeid
            and    p_pact_rec.action_date between
                   pev.effective_start_date and pev.effective_end_date;
--
            -- Now we attempt to delete the element entry row.
            -- Note, if this procedure is called from the balance
            -- adjustment row, the form may be attempting to delete
            -- this row. However, this could be called from the
            -- actions form, in which case we do need to do the delete.
--            hr_utility.set_location('hrassact.do_assact_rollback',70);
            delete from pay_element_entries_f pee
            where  pee.element_entry_id = v_eeid
            and    p_pact_rec.action_date between
                   pee.effective_start_date and pee.effective_end_date;
         end;
      else
         -- Now process for Non balance adjustment case.
--
         -- The following section is designed to undo any changes
         -- to Recurring element entries that have been made by
         -- the Payroll Run, via Update and Stop REE rules.
         -- Note, we have to perform some extra joins to check
         -- that we are only picking up recurring element entries.
         declare
            cursor c1 is
            select pet.multiple_entries_allowed_flag,
                   pee.element_entry_id,
                   pee.updating_action_id,
                   pee.effective_start_date,
                   pee.effective_end_date
            from   pay_element_types_f   pet,
                   pay_element_links_f   pel,
                   pay_element_entries_f pee
            where  pee.assignment_id   = p_assact_rec.assignment_id
            and    pee.entry_type      = 'E'
            and    p_pact_rec.action_date between
                   pee.effective_start_date and pee.effective_end_date
            and    pel.element_link_id = pee.element_link_id
            and    p_pact_rec.action_date between
                   pel.effective_start_date and pel.effective_end_date
            and    pet.element_type_id = pel.element_type_id
            and    p_pact_rec.action_date between
                   pel.effective_start_date and pel.effective_end_date
            and    pet.processing_type = 'R';
--
            v_max_date date; -- max effective date of element entry.
         begin
            -- Loop through all the standard entries for the assignment
            -- and attempt to undo changes that have been made by
            -- stop and update REE rules. We cannot be guaranteed
            -- to undo changes in their entirety, since we do not
            -- have all the information we need to hand, but we
            -- perform delete next change.
            if g_debug then
               hr_utility.set_location('hrassact.do_assact_rollback',80);
            end if;
            for c1rec in c1 loop
               -- First, look for possible stop rule case.
               if(c1rec.effective_end_date = p_pact_rec.action_date) then
                  -- We may have a stopped entry, but we need to
                  -- see if this really is the case.
                  if g_debug then
                     hr_utility.set_location('hrassact.do_assact_rollback',90);
                  end if;
                  select max(pee.effective_end_date)
                  into   v_max_date
                  from   pay_element_entries_f pee
                  where  pee.element_entry_id = c1rec.element_entry_id;
--
                  if(v_max_date = p_pact_rec.action_date) then
                     -- This entry has been chopped off. We assume
                     -- it has been performed by the Payroll Run.
                     -- Call the ee api to delete next change.
                     undo_stop_update (c1rec.element_entry_id,
                                       c1rec.multiple_entries_allowed_flag,
                                       p_pact_rec.action_date,
                                       'FUTURE_CHANGE');
                  end if;
               end if; -- stop rule.
--
               -- Now, we look for an Update Rule Case.
               -- Here we need to see if there is a record
               -- whoes effective start date is the same as
               -- that of the run, and the updating_action_id of
               -- the entry is the same as the assignment_action_id
               -- and there exists a previous record with effective
               -- end date of the previous day (i.e. a date effective
               -- update has occurred).
               if(c1rec.effective_start_date = p_pact_rec.action_date
                    and c1rec.updating_action_id = p_assact_rec.assact_id)
               then
                  -- Note, in following select, use max to avoid
                  -- having to deal with no data found error.
                  if g_debug then
                     hr_utility.set_location('hrassact.do_assact_rollback',110);
                  end if;
                  select max(pee.effective_end_date)
                  into   v_max_date
                  from   pay_element_entries_f pee
                  where  pee.element_entry_id   = c1rec.element_entry_id
                  and    pee.effective_end_date = (p_pact_rec.action_date - 1);
--
                  if(v_max_date is not null) then
                     -- Ok, there is a previous record. We now wish
                     -- to delete future changes on that record.
                     undo_stop_update (c1rec.element_entry_id,
                                       c1rec.multiple_entries_allowed_flag,
                                       (p_pact_rec.action_date - 1),
                                       'DELETE_NEXT_CHANGE');
                  else
                     -- In the case where there is no previous record,
                     -- the update was previously a correction. This
                     -- means we need to set the updating_action_id
                     -- to null.
                     if g_debug then
                        hr_utility.set_location('hrassact.do_assact_rollback',130);
                     end if;
                     update pay_element_entries_f pee
                     set    pee.updating_action_id = null
                     where  pee.element_entry_id   = c1rec.element_entry_id
                     and    p_pact_rec.action_date between
                            pee.effective_start_date and pee.effective_end_date;
                  end if;
               end if;
            end loop;
         end;
      end if; -- end of Balance Adjustment specific stuff.
--
   end if;   --  end of actions specific to SEQUENCED actions
--
--
   --  delete any messages associated with the assignment action.
   if g_debug then
      hr_utility.set_location('hrassact.do_assact_rollback',140);
   end if;
   delete from pay_message_lines ML
   where  ML.source_type = 'A'
   and    ML.source_id = p_assact_rec.assact_id;
--
   if(p_pact_rec.action_type in ('P','U')) then
      -- Need to delete pre-payment rows.
      -- Originally left it to the data base, but
      -- that meant that rows were not deleted
      -- in retry mode.
      -- Note, the delete of a pre-payment row causes
      -- a cascade delete from pay_coin_anal_elements.
      if g_debug then
         hr_utility.set_location('hrassact.do_assact_rollback',150);
      end if;
      delete from pay_pre_payments ppp
      where  ppp.assignment_action_id = p_assact_rec.assact_id;
   end if;
--
   if(p_pact_rec.action_type = 'C') then
      -- Delete from the costing table.
      delete from pay_costs
      where  assignment_action_id = p_assact_rec.assact_id;
   end if;
--
   /*
    *   ROLLBACK specific code
    */
   if p_rollback_mode = 'ROLLBACK' then
      --
      --  Write a message to payroll action level to indicate
      --  that the action has been rolled back.
      --
      declare
         mesg_text     pay_message_lines.line_text%type;
      begin
         hr_utility.set_message (801, 'HR_ACTION_ASACT_ROLLOK');
         hr_utility.set_message_token
              ('ASG_NUMBER',p_assact_rec.assignment_number);
         hr_utility.set_message_token
              ('FULL_NAME',p_assact_rec.full_name);
         hr_utility.set_message_token
              ('SYSDATE',fnd_date.date_to_canonical(p_pact_rec.current_date));
         mesg_text := substrb(hr_utility.get_message,1,240);
--
         --  now write our message to the payroll_action level. We
         --  want to spit out the asssignment's current Payroll ID as well.
         if g_debug then
            hr_utility.set_location('hrassact.do_assact_rollback',160);
         end if;
         insert into pay_message_lines
         (line_sequence,
          payroll_id,
          message_level,
          source_id,
          source_type,
          line_text
         )
         values
         (pay_message_lines_s.nextval,
          p_assact_rec.payroll_id,
          'I',           -- Information level
          p_pact_rec.pact_id,
          'P',
          mesg_text
         );
      end;
--
      if p_pact_rec.action_type = 'Q' then
         trash_quickpay (p_action_id => p_assact_rec.assact_id);
      end if;
--
   end if;
--
   --   see if we want to alter the assignment action itself (we wouldn't
   --   if we were being called from a form)
   if not p_leave_base_table_row then
      if p_rollback_mode = 'RETRY' then
            if g_debug then
               hr_utility.set_location('hrassact.do_assact_rollback',170);
            end if;
            update pay_assignment_actions
            set    action_status = 'M'
            where  assignment_action_id = p_assact_rec.assact_id;
--
      elsif p_rollback_mode = 'BACKPAY' then
            if g_debug then
               hr_utility.set_location('hrassact.do_assact_rollback',180);
            end if;
            update pay_assignment_actions
            set    action_status = 'B'
            where  assignment_action_id = p_assact_rec.assact_id;
--
      elsif p_rollback_mode = 'ROLLBACK' then
            -- there may be pay_action_interlock rows.
            -- which are locking other assignment actions.
            if g_debug then
               hr_utility.set_location('hrassact.do_assact_rollback',190);
            end if;
            delete from pay_action_interlocks lck
            where  lck.locking_action_id = p_assact_rec.assact_id;
--
            if g_debug then
               hr_utility.set_location('hrassact.do_assact_rollback',200);
            end if;
            delete from pay_assignment_actions
            where  assignment_action_id = p_assact_rec.assact_id;
      end if;
   else
      -- In the case of rolling back (from the form), we
      -- still need to delete interlock rows. Of course,
      -- in this case we do not delete the action.
      if(p_rollback_mode = 'ROLLBACK') then
         if g_debug then
            hr_utility.set_location('hrassact.do_assact_rollback',210);
         end if;
         delete from pay_action_interlocks lck
         where  lck.locking_action_id = p_assact_rec.assact_id;
      end if;
   end if;
--
   if g_debug then
      hr_utility.set_location('hrassact.do_assact_rollback',220);
   end if;
   return;
--
end do_assact_rollback;
--
--
--
/*-----------------------  do_pact_rollback  ----------------------*/
/*
 *   This routine performs the actual work of rolling back a
 *   payroll action. See the description of the three overloaded
 *   calls which use this internal function for details.
 *
 */
procedure do_pact_rollback
              (p_payroll_action_id in number,
               p_chunk_size in number default 200,
               p_all_or_nothing in boolean default TRUE,
               p_failed_assact in out nocopy number,
               p_rollback_mode in varchar2,
               p_leave_base_table_row in boolean) is
--
   l_pact_rec   pact_details;     --  payroll action details
   l_assact_rec assact_details;   --  assignment action details
   l_cur_aseq   number;           --  Current action_sequence.
   l_counter    number;           --  counts number of actions processed
                                  --  within one chunk.
   c_indent     constant varchar2(30) := 'pyassact.do_pact_rollback';
--
begin

   --  populate payroll action details and perform high level validation
   l_pact_rec.pact_id := p_payroll_action_id;
   if g_debug then
      hr_utility.set_location(c_indent, 10);
   end if;
   val_pact_rollback(p_pact_rec => l_pact_rec,
                          p_rollback_mode => p_rollback_mode);
--
   -- Rollback and Mark for retry rules
   val_pact_rr_rules(l_pact_rec, p_rollback_mode);
--
   --  assume things will go well for us
   p_failed_assact := null;
--
   -- If a process has failed disasterously, there could
   -- be range rows still hanging around. Need to trash these.
   delete from pay_population_ranges ppr
   where  ppr.payroll_action_id = p_payroll_action_id;
--
   -- We need to roll back assignment actions in reverse order
   -- from high action_sequence down (for multiple assignments).
   -- Therefore, start by selecting the max action_sequence.
   if g_debug then
      hr_utility.set_location(c_indent, 20);
   end if;
   select max(act.action_sequence) + 1
   into   l_cur_aseq
   from   pay_assignment_actions act
   where  act.payroll_action_id = p_payroll_action_id;
--
   --  now roll back each assignment action in turn (lock as we go)
   declare
      more_actions boolean;
--
      -- This cursor retrieves all target assignment actions which
      -- have not already been considered for rolling back.
      -- It used to use rownum to restrict the fetch to a chunk of
      -- assignment actions. However, rownum and the ordering worked
      -- in opposite directions, leading to the code only processing
      -- the first chunk.
      cursor c1 is
      select act.assignment_action_id,
             act.action_sequence
      from   pay_assignment_actions act
      where  act.payroll_action_id = p_payroll_action_id
      and    act.action_sequence   < l_cur_aseq
      order by act.action_sequence desc
      for update of act.action_status;
   begin
--
      --
      -- The outer loop handles chunks of assignment actions,
      -- We delete a chunk of assignment actions at a time,
      -- using supplied parameter value, we do not use the
      -- existing chunks.
      -- To keep commit unit size down, a local counter is incremented
      -- each time an assignment action is rolled back or marked for
      -- retry (as opposed to when the action is considered for
      -- processing, but rejected, and hence, no db change ensues).
      --
      more_actions := TRUE;  -- Set this to satisfy the while condition.
      while(more_actions) loop
         more_actions := FALSE;
         l_counter := 0;
--
         if g_debug then
            hr_utility.set_location(c_indent,30);
         end if;
         for c1rec in c1 loop
            exit when l_counter = p_chunk_size;
            more_actions := TRUE;
--
            -- Set this variable so that when we re-open cursor c1, for
            -- the next chunk, we don't reprocess the actions we've
            -- dealt with already.
            l_cur_aseq := c1rec.action_sequence;
--
            --  see if OK to roll back or retry this assignment action
            l_assact_rec.assact_id := c1rec.assignment_action_id;
            if g_debug then
               hr_utility.set_location(c_indent,40);
            end if;
            if val_assact_rollback
                        (p_pact_rec => l_pact_rec,
                         p_assact_rec => l_assact_rec,
                         p_rollback_mode => p_rollback_mode) then
--
               --  OK, clean up all child records for the action
               if g_debug then
                  hr_utility.set_location(c_indent,50);
               end if;
               do_assact_rollback
                         (p_pact_rec => l_pact_rec,
                          p_assact_rec => l_assact_rec,
                          p_rollback_mode => p_rollback_mode,
                          p_leave_base_table_row => FALSE);
               -- We've just processed another assignment action, so
               -- increment the counter.
               l_counter := l_counter + 1;
--
            else
               -- We have detected that an assignment action
               -- should not be rolled back. We set a parameter
               -- value to tell the outside world.
               -- Only set if null, because several assignment
               -- actions could fail, and we wish to report on
               -- the first of these
               if p_failed_assact is null then
                  p_failed_assact := c1rec.assignment_action_id;
               end if;
--
               --  decide whether to leap out entirely
               if p_all_or_nothing then
                  hr_utility.set_message(801, 'HR_7008_ACTION_CANT_ROLLBACK');
                  hr_utility.set_message_token
                    ('FAILING_ASSACT', to_char(c1rec.assignment_action_id));
                  hr_utility.raise_error;
               end if;
            end if;
--
         end loop; -- cursor loop.
--
         if not p_all_or_nothing then
            commit;
         end if;
--
      end loop; -- loop round for next chunk.
--
   end;
--
   --  trash messages
   if g_debug then
      hr_utility.set_location(c_indent,60);
   end if;
   delete from pay_message_lines ML
   where  ML.source_type = 'P'
   and    ML.source_id = p_payroll_action_id;
--
   --  now trash the payroll action itself if the user so desires (and if
   --  all assignment actions where successfully rolled back).
   if g_debug then
      hr_utility.set_location(c_indent,70);
   end if;
   if not p_leave_base_table_row and p_failed_assact is null then
--
      --
      -- Now we need to have a message to indicate
      -- that the payroll action was rolled back.
      -- We start by checking the payroll action type.
      -- If that is Magnetic Transfer, we wish to
      -- select the actual payment type (thus giving
      -- us BACS or NACHA or whatever, before generating
      -- the message.
      if(l_pact_rec.action_type = 'M') then
         if g_debug then
            hr_utility.set_location(c_indent,90);
         end if;
         select ppt_tl.payment_type_name
         into   l_pact_rec.action_name
         from   pay_payroll_actions  pac,
                pay_payment_types_tl ppt_tl,
                pay_payment_types    ppt
         where  pac.payroll_action_id = l_pact_rec.pact_id
         and    ppt.payment_type_id = pac.payment_type_id
         and    ppt_tl.payment_type_id = ppt.payment_type_id
         and    userenv('LANG') = ppt_tl.language;
      end if;
--
      -- We now need to set up the message, depending on whether
      -- the payroll_id is null or not.
      declare
         mesg_text pay_message_lines.line_text%type;
      begin
         if(l_pact_rec.payroll_name is null) then
            -- Set up message for no payroll case.
            hr_utility.set_message(801,'HR_ACTION_PACT_ROLLNOPAY');
            hr_utility.set_message_token('ACTION_TYPE',l_pact_rec.action_name);
            hr_utility.set_message_token('BG_NAME',l_pact_rec.bg_name);
            hr_utility.set_message_token('SYSDATE',
                 fnd_date.date_to_canonical(l_pact_rec.current_date));
         else
            -- Set up message for payroll case.
            hr_utility.set_message(801,'HR_ACTION_PACT_ROLLPAY');
            hr_utility.set_message_token('ACTION_TYPE',l_pact_rec.action_name);
            hr_utility.set_message_token('PAYROLL_NAME',
                 l_pact_rec.payroll_name);
            hr_utility.set_message_token('BG_NAME',l_pact_rec.bg_name);
            hr_utility.set_message_token('SYSDATE',
                 fnd_date.date_to_canonical(l_pact_rec.current_date));
         end if;
         mesg_text := substrb(hr_utility.get_message,1,240);
--
         if g_debug then
            hr_utility.set_location(c_indent,100);
         end if;
         insert into pay_message_lines (
                line_sequence,
                payroll_id,
                message_level,
                source_id,
                source_type,
                line_text)
         select pay_message_lines_s.nextval,
                pac.payroll_id,
                'I',  -- information.
                pac.business_group_id,
                'B',
                mesg_text
         from   pay_payroll_actions pac
         where  pac.payroll_action_id = l_pact_rec.pact_id;

      end;
--
      if g_debug then
         hr_utility.set_location(c_indent,80);
      end if;
      delete from pay_payroll_actions
      where  payroll_action_id = p_payroll_action_id;
--
      if not p_all_or_nothing then
         if g_debug then
            hr_utility.set_location(c_indent,110);
         end if;
         commit;
      end if;
--
   end if;
--
   if g_debug then
      hr_utility.set_location(c_indent,120);
   end if;
   return;
--
end do_pact_rollback;
--
--
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
                        p_leave_base_table_row in boolean) is
begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hrassact.rollback_payroll_action',10);
   end if;
   py_rollback_pkg.rollback_payroll_action
        (p_payroll_action_id => p_payroll_action_id,
         p_rollback_mode => p_rollback_mode,
         p_leave_base_table_row => p_leave_base_table_row);
end rollback_payroll_action;
--
--
procedure rollback_payroll_action
                       (p_payroll_action_id    in number,
                        p_failed_assact        in out nocopy number,
                        p_rollback_mode        in varchar2,
                        p_leave_base_table_row in boolean) is
begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hrassact.rollback_payroll_action',20);
   end if;
   py_rollback_pkg.rollback_payroll_action
        (p_payroll_action_id => p_payroll_action_id,
         p_rollback_mode => p_rollback_mode,
         p_leave_base_table_row => p_leave_base_table_row);
end rollback_payroll_action;
--
--
procedure rollback_payroll_action
                       (p_payroll_action_id    in number,
                        p_chunk_size           in number,
                        p_failed_assact        in out nocopy number,
                        p_rollback_mode        in varchar2,
                        p_leave_base_table_row in boolean) is
begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hrassact.rollback_payroll_action',30);
   end if;
   py_rollback_pkg.rollback_payroll_action
        (p_payroll_action_id => p_payroll_action_id,
         p_all_or_nothing    => FALSE,
         p_rollback_mode => p_rollback_mode,
         p_leave_base_table_row => p_leave_base_table_row);
end rollback_payroll_action;
--
--
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
               p_leave_base_table_row in boolean) is
--
   l_pact_rec    pact_details;     --  payroll action details
   l_assact_rec  assact_details;   --  assignment action details
   cursor c1 is
   select payroll_action_id
   from   pay_assignment_actions
   where  assignment_action_id = p_assignment_action_id
   for update of action_status;
--
--
begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hrassact.rollback_ass_action',20);
   end if;
   for c1rec in c1 loop
--
      --  populate payroll action details and perform high level validation
      l_pact_rec.pact_id := c1rec.payroll_action_id;
      if g_debug then
         hr_utility.set_location('hrassact.rollback_ass_action',30);
      end if;
      val_pact_rollback(p_pact_rec => l_pact_rec,
                             p_rollback_mode => p_rollback_mode);
--
      --  see if OK to roll back or retry this assignment action
      l_assact_rec.assact_id := p_assignment_action_id;
--
      if g_debug then
         hr_utility.set_location('hrassact.rollback_ass_action',40);
      end if;
      if  p_rollback_mode = 'BACKPAY' or
         (val_assact_rollback (l_pact_rec, l_assact_rec, p_rollback_mode) and
          val_assact_rr_rules (l_pact_rec, p_rollback_mode))
      then
--
         --  OK, clean up all child records for the action
         if g_debug then
            hr_utility.set_location('hrassact.rollback_ass_action',50);
         end if;
         do_assact_rollback
                   (p_pact_rec => l_pact_rec,
                    p_assact_rec => l_assact_rec,
                    p_rollback_mode => p_rollback_mode,
                    p_leave_base_table_row => p_leave_base_table_row);
      else
         hr_utility.set_message(801, 'HR_7008_ACTION_CANT_ROLLBACK');
         hr_utility.set_message_token('FAILING_ASSACT',l_assact_rec.assact_id);
         hr_utility.raise_error;
      end if;
--
   end loop;
--
   if g_debug then
      hr_utility.set_location('hrassact.rollback_ass_action',60);
   end if;
   return;
--
end rollback_ass_action;
--
--
/*-------------------------  trash_latest_balances  -----------------------*/
/*
 *    This procedure trashes any latest balances
 *    invalidated for the given balance type and input value
 *    on or after the given date where there exists at least
 *    one processed, non zero result value. This is done to
 *    avoid trashing latest balances that could not have
 *    been affected by the change in the balance feed.
 */
procedure trash_latest_balances(l_balance_type_id number,
                                l_input_value_id number,
                                l_trash_date date) is
--
   -- Select all person latest balances to delete.
   cursor plbc is
   select /*+ ORDERED INDEX (PLB PAY_PERSON_LATEST_BALANCES_FK1)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances       pdb,
          pay_person_latest_balances plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id
   and    exists (
          select null
          from   pay_run_results       prr,
                 pay_run_result_values rrv
          where  rrv.input_value_id  = l_input_value_id
          and    prr.run_result_id   = rrv.run_result_id
          and    prr.status          in ('P', 'PA')
          and    nvl(rrv.result_value, '0') <> '0');
--
   cursor lbc is
   select
          lb.latest_balance_id
   from   pay_defined_balances       pdb,
          pay_latest_balances lb
   where  pdb.balance_type_id      = l_balance_type_id
   and    lb.defined_balance_id   = pdb.defined_balance_id
   and    exists (
          select null
          from   pay_run_results       prr,
                 pay_run_result_values rrv
          where  rrv.input_value_id  = l_input_value_id
          and    prr.run_result_id   = rrv.run_result_id
          and    prr.status          in ('P', 'PA')
          and    nvl(rrv.result_value, '0') <> '0');
--
   -- Select all assignment latest balances to delete.
   cursor albc is
   select /*+ ORDERED INDEX (PLB PAY_ASSIGNMENT_LATEST_BALA_FK2)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances           pdb,
          pay_assignment_latest_balances plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id
   and    exists (
          select null
          from   pay_run_results       prr,
                 pay_run_result_values rrv
          where  rrv.input_value_id  = l_input_value_id
          and    prr.run_result_id   = rrv.run_result_id
          and    prr.status          in ('P', 'PA')
          and    nvl(rrv.result_value, '0') <> '0');
--
   cursor platbalc is
   select /*+ ORDERED INDEX (PLB PAY_PERSON_LATEST_BALANCES_FK1)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances       pdb,
          pay_person_latest_balances plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id;
--
   -- Select all assignment latest balances to delete.
   cursor alatbalc is
   select /*+ ORDERED INDEX (PLB PAY_ASSIGNMENT_LATEST_BALA_FK2)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances           pdb,
          pay_assignment_latest_balances plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id;
--
   -- Select all latest balances to delete.
   cursor latbalc is
   select /*+ ORDERED INDEX (PLB PAY_LATEST_BALANCES_FK1)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances           pdb,
          pay_latest_balances            plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id;
--
   -- Select if run result value exists for input value
   cursor ivchk is
   select '1' from dual
    where exists (select 1
     from pay_run_results prr,
          pay_run_result_values rrv
    where rrv.input_value_id = l_input_value_id
      and prr.run_result_id  = rrv.run_result_id
      and prr.status         in ('P', 'PA')
      and nvl(rrv.result_value, '0') <> '0');
--
   -- Select the balances that are PL/SQL fed.
   cursor pl_feed_chk_a is
   select alb.latest_balance_id
     from pay_assignment_latest_balances alb,
          pay_defined_balances pdb,
          pay_balance_dimensions pbd
    where pdb.balance_type_id = l_balance_type_id
      and pdb.defined_balance_id = alb.defined_balance_id
      and pdb.balance_dimension_id = pbd.balance_dimension_id
      and pbd.feed_checking_type = 'F';

   cursor pl_feed_chk is
   select plb.latest_balance_id,
          'P' balance_type
     from pay_person_latest_balances plb,
          pay_defined_balances pdb,
          pay_balance_dimensions pbd
    where pdb.balance_type_id = l_balance_type_id
      and pdb.defined_balance_id = plb.defined_balance_id
      and pdb.balance_dimension_id = pbd.balance_dimension_id
      and pbd.feed_checking_type = 'F'
    union
    select plb.latest_balance_id,
           'B' balance_type
      from pay_latest_balances plb,
           pay_defined_balances pdb,
           pay_balance_dimensions pbd
     where pdb.balance_type_id = l_balance_type_id
       and pdb.defined_balance_id = plb.defined_balance_id
       and pdb.balance_dimension_id = pbd.balance_dimension_id
       and pbd.feed_checking_type = 'F';

  l_ivchk varchar2(2);
  l_rrv_found number := -1;
  --Added following type for Bug:6595092 bulk delete
  Type t_latbal is table of pay_assignment_latest_balances.latest_balance_id%type;
  lat_bal_list t_latbal;
--
begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hrassact.trash_latest_balances',10);
   end if;

   if (g_lat_bal_check_mode is null) then
      begin
         if g_debug then
            hr_utility.set_location('hrassact.trash_latest_balances',15);
         end if;
         select parameter_value
         into   g_lat_bal_check_mode
         from   pay_action_parameters
         where  parameter_name = 'LAT_BAL_CHECK_MODE';

      exception
         when others then
            g_lat_bal_check_mode := 'N';
      end;

      if (g_lat_bal_check_mode = 'B') then
         HRASSACT.CHECK_LAT_BALS_FIRST := TRUE;
      elsif (g_lat_bal_check_mode = 'R') then
         HRASSACT.CHECK_RRVS_FIRST := TRUE;
      end if;
   end if;
--
 if HRASSACT.CHECK_LATEST_BALANCES = TRUE then

  if HRASSACT.CHECK_RRVS_FIRST = TRUE then

   if g_debug then
      hr_utility.set_location('hrassact.trash_latest_balances',20);
   end if;
   --
   -- Check for existance of run result value for input value
   --
   open ivchk;
   fetch ivchk
   into l_ivchk;

   if ivchk%FOUND then
--
     if g_debug then
        hr_utility.set_location('hrassact.trash_latest_balances',30);
     end if;
     -- Delete all balance context values and
     -- person latest balances.
     for plbcrec in platbalc loop
        delete from pay_balance_context_values BCV
        where  BCV.latest_balance_id = plbcrec.latest_balance_id;
--
        delete from pay_person_latest_balances PLB
        where  PLB.latest_balance_id = plbcrec.latest_balance_id;
     end loop;

     if g_debug then
        hr_utility.set_location('hrassact.trash_latest_balances',40);
     end if;
     -- Delete all balance context values and
     -- assignment latest balances.

     --Commented the following and added a block with cusrsor and bulk delete
     --for Bug:6595092
  /*   for albcrec in alatbalc loop
       delete from pay_balance_context_values BCV
        where  BCV.latest_balance_id = albcrec.latest_balance_id;
--
        delete from pay_assignment_latest_balances ALB
        where  ALB.latest_balance_id = albcrec.latest_balance_id;
     end loop; */

     open alatbalc;
      loop
        fetch alatbalc bulk collect into lat_bal_list limit 100000;

        forall i in 1..lat_bal_list.count
          delete from pay_balance_context_values BCV
          where  BCV.latest_balance_id = lat_bal_list(i);

        forall i in 1..lat_bal_list.count
         delete from pay_assignment_latest_balances ALB
         where  ALB.latest_balance_id =lat_bal_list(i);

        exit when alatbalc%notfound;
      end loop;

IF alatbalc%ISOPEN
THEN
   CLOSE alatbalc;
END IF;

--
     -- Delete all latest Balanaces.
     for lbcrec in latbalc loop
--
        delete from pay_latest_balances LB
        where  LB.latest_balance_id = lbcrec.latest_balance_id;
     end loop;
--
   end if;
   close ivchk;

  elsif HRASSACT.CHECK_LAT_BALS_FIRST = TRUE then

   if g_debug then
      hr_utility.set_location('hrassact.trash_latest_balances',50);
   end if;
   --
   -- Check for any latest balances before relevant run result value
   --
   for plbcrec in platbalc loop
      if l_rrv_found = -1 then
         open ivchk;

         fetch ivchk
         into l_ivchk;

         if ivchk%FOUND then
            l_rrv_found := 1;
         else
            l_rrv_found := 0;
            close ivchk;
            exit;
         end if;
         close ivchk;
      end if;
      if l_rrv_found = 1 then
         delete from pay_balance_context_values BCV
         where  BCV.latest_balance_id = plbcrec.latest_balance_id;
--
         delete from pay_person_latest_balances PLB
         where  PLB.latest_balance_id = plbcrec.latest_balance_id;
      end if;
   end loop;
--
  if g_debug then
      hr_utility.set_location('hrassact.trash_latest_balances',60);
   end if;
   -- Delete all balance context values and
   -- assignment latest balances.
   if l_rrv_found <> 0 then
         if l_rrv_found = -1 then
            open ivchk;
            fetch ivchk
            into l_ivchk;

            if ivchk%FOUND then
               l_rrv_found := 1;
            else
               l_rrv_found := 0;
            end if;
            close ivchk;
         end if;
         if l_rrv_found = 1 then
            open alatbalc;
		loop
			fetch alatbalc bulk collect into lat_bal_list limit 100000;

			 forall i in 1..lat_bal_list.count
			 delete from pay_balance_context_values BCV
			 where  BCV.latest_balance_id = lat_bal_list(i);

			 forall i in 1..lat_bal_list.count
			 delete from pay_assignment_latest_balances ALB
			 where  ALB.latest_balance_id =lat_bal_list(i);

			 exit when alatbalc%notfound;
		end loop;

		IF alatbalc%ISOPEN
		THEN
		   CLOSE alatbalc;
		END IF;
         end if;
   end if;
--
   for lbcrec in latbalc loop
      if l_rrv_found = -1 then
         open ivchk;

         fetch ivchk
         into l_ivchk;

         if ivchk%FOUND then
            l_rrv_found := 1;
         else
            l_rrv_found := 0;
            close ivchk;
            exit;
         end if;
         close ivchk;
      end if;
      if l_rrv_found = 1 then
         delete from pay_latest_balances ALB
         where  ALB.latest_balance_id = lbcrec.latest_balance_id;
      end if;
   end loop;

  else
   --
   -- Original Code
   --
   if g_debug then
      hr_utility.set_location('hrassact.trash_latest_balances',70);
   end if;
   -- Delete all balance context values and
   -- person latest balances.
   for plbcrec in plbc loop
      delete from pay_balance_context_values BCV
      where  BCV.latest_balance_id = plbcrec.latest_balance_id;
--
      delete from pay_person_latest_balances PLB
      where  PLB.latest_balance_id = plbcrec.latest_balance_id;
   end loop;
--
   if g_debug then
      hr_utility.set_location('hrassact.trash_latest_balances',80);
   end if;
   -- Delete all balance context values and
   -- assignment latest balances.
		open albc;
		loop
			fetch albc bulk collect into lat_bal_list limit 100000;

			 forall i in 1..lat_bal_list.count
			 delete from pay_balance_context_values BCV
			 where  BCV.latest_balance_id = lat_bal_list(i);

			 forall i in 1..lat_bal_list.count
			 delete from pay_assignment_latest_balances ALB
			 where  ALB.latest_balance_id =lat_bal_list(i);

			 exit when albc%notfound;
		end loop;

		IF albc%ISOPEN
		THEN
		   CLOSE albc;
		END IF;

--
   if g_debug then
      hr_utility.set_location('hrassact.trash_latest_balances',70);
   end if;
--
   for lbcrec in lbc loop
      delete from pay_latest_balances ALB
      where  ALB.latest_balance_id = lbcrec.latest_balance_id;
   end loop;
--
  end if;
--
   if g_debug then
      hr_utility.set_location('hrassact.trash_latest_balances',90);
   end if;
--
   for plrec in pl_feed_chk loop
--
     if g_debug then
        hr_utility.set_location('hrassact.trash_latest_balances',100);
     end if;

     delete from pay_balance_context_values BCV
      where  BCV.latest_balance_id = plrec.latest_balance_id;
--
     if (plrec.balance_type = 'P') then
       delete from pay_person_latest_balances PLB
       where  PLB.latest_balance_id = plrec.latest_balance_id;
     else
       delete from pay_latest_balances PLB
       where  PLB.latest_balance_id = plrec.latest_balance_id;
     end if;
--
   end loop;


		open pl_feed_chk_a;
		loop
			fetch pl_feed_chk_a bulk collect into lat_bal_list limit 100000;

			 forall i in 1..lat_bal_list.count
			 delete from pay_balance_context_values BCV
			 where  BCV.latest_balance_id = lat_bal_list(i);

			 forall i in 1..lat_bal_list.count
			 delete from pay_assignment_latest_balances ALB
			 where  ALB.latest_balance_id =lat_bal_list(i);

			 exit when pl_feed_chk_a%notfound;
		end loop;

		IF pl_feed_chk_a%ISOPEN
		THEN
		   CLOSE pl_feed_chk_a;
		END IF;











--
 end if;
--
   if g_debug then
      hr_utility.set_location('hrassact.trash_latest_balances',110);
   end if;
--
   return;
--
end trash_latest_balances;
--
--
/*-------------------------  trash_latest_balances  -----------------------*/
/*
 *    This procedure trashes any latest balances
 *    invalidated for the given balance type
 */
procedure trash_latest_balances(l_balance_type_id number,
                                l_trash_date date) is
   -- Select all person latest balances to delete.
   cursor plbc is
   select /*+ ORDERED INDEX (PLB PAY_PERSON_LATEST_BALANCES_FK1)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances       pdb,
          pay_person_latest_balances plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id;
--
   -- Select all assignment latest balances to delete.
   cursor albc is
   select /*+ ORDERED INDEX (PLB PAY_ASSIGNMENT_LATEST_BALA_FK2)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances           pdb,
          pay_assignment_latest_balances plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id;
   -- Select all latest balances to delete.
   cursor lbc is
   select /*+ ORDERED INDEX (LB PAY_LATEST_BALANCES_FK1)
              USE_NL (LB) */
          lb.latest_balance_id
   from   pay_defined_balances           pdb,
          pay_latest_balances            lb
   where  pdb.balance_type_id      = l_balance_type_id
   and    lb.defined_balance_id    = pdb.defined_balance_id;

  Type t_latbal is table of pay_assignment_latest_balances.latest_balance_id%type;
  lat_bal_list t_latbal;

begin
   hr_utility.set_location('hrassact.trash_latest_balances',10);
--
   -- Delete all balance context values and
   -- person latest balances.
   for plbcrec in plbc loop
      delete from pay_balance_context_values BCV
      where  BCV.latest_balance_id = plbcrec.latest_balance_id;
--
      delete from pay_person_latest_balances PLB
      where  PLB.latest_balance_id = plbcrec.latest_balance_id;
   end loop;
--
   hr_utility.set_location('hrassact.trash_latest_balances',20);
   -- Delete all balance context values and
   -- assignment latest balances.
   open albc;
		loop
			fetch albc bulk collect into lat_bal_list limit 100000;

			 forall i in 1..lat_bal_list.count
			 delete from pay_balance_context_values BCV
			 where  BCV.latest_balance_id = lat_bal_list(i);

			 forall i in 1..lat_bal_list.count
			 delete from pay_assignment_latest_balances ALB
			 where  ALB.latest_balance_id =lat_bal_list(i);

			 exit when albc%notfound;
		end loop;

		IF albc%ISOPEN
		THEN
		   CLOSE albc;
		END IF;

--
   hr_utility.set_location('hrassact.trash_latest_balances',30);
   for lbcrec in lbc loop
      delete from pay_latest_balances ALB
      where  ALB.latest_balance_id = lbcrec.latest_balance_id;
   end loop;
   hr_utility.set_location('hrassact.trash_latest_balances',40);
--
   return;
--
end trash_latest_balances;
--
/*-------------------------  del_latest_balances  -----------------------*/
/*
 *     This procedure trashes any latest balances for the person.
 */
procedure del_latest_balances
(
   p_assignment_id  in number,
   p_effective_date in date,    -- allow date effective join.
   p_element_entry  in number default null,
   p_element_type_id in number default null
) is
   --
   -- Cursors to delete all the latest balances for an assignment.
   --
   cursor plbc (p_person_id number) is
   select plb.latest_balance_id
     from pay_person_latest_balances plb
    where plb.person_id = p_person_id;
   --
   cursor lbc (p_person_id number) is
   select lb.latest_balance_id
     from pay_latest_balances lb
    where lb.person_id = p_person_id;
   --
   cursor albc (p_person_id number) is
   select /*+ ORDERED */ alb.latest_balance_id
   from   per_periods_of_service         pos,
          per_all_assignments_f          asg,
          pay_assignment_actions         act,
          pay_payroll_actions            pac,
          pay_assignment_latest_balances alb
   where  pos.person_id            = p_person_id
   and    asg.period_of_service_id = pos.period_of_service_id
   and    asg.person_id            = p_person_id
   and    act.assignment_id        = asg.assignment_id
   and    alb.assignment_action_id = act.assignment_action_id
   and    pac.payroll_action_id    = act.payroll_action_id
   and    pac.effective_date between
          asg.effective_start_date and asg.effective_end_date;


   --
   -- Cursors to selectively delete the latest balances for an assignment.
   --
   cursor plbc_selective (p_person_id      number,
                          p_eletyp_id      number
                          ) is
   select
          plb.latest_balance_id
     from
          pay_input_values_f         piv,
          pay_balance_feeds_f        pbf,
          pay_defined_balances       pdb,
          pay_person_latest_balances plb,
          pay_assignment_actions     paa,
          pay_payroll_actions        ppa
    where plb.person_id = p_person_id
    and   piv.element_type_id = p_eletyp_id
    and   piv.input_value_id = pbf.input_value_id
    and   plb.defined_balance_id = pdb.defined_balance_id
    and   pdb.balance_type_id = pbf.balance_type_id
    and   paa.assignment_action_id = plb.assignment_action_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.effective_date between pbf.effective_start_date
                               and pbf.effective_end_date
    and   ppa.effective_date between piv.effective_start_date
                               and piv.effective_end_date;
--
   cursor albc_selective (p_person_id number,
                          p_eletyp_id number) is
   select /*+ ORDERED */
          alb.latest_balance_id
   from   pay_assignment_latest_balances alb,
          pay_assignment_actions         act,
          pay_payroll_actions            pac,
          pay_defined_balances           pdb,
          pay_balance_feeds_f            pbf,
          pay_input_values_f             piv
   where  act.assignment_id        = alb.assignment_id
   and    alb.assignment_id in
          (select distinct asg.assignment_id
           from per_all_assignments_f asg
           where asg.person_id     = p_person_id)
   and    alb.assignment_action_id = act.assignment_action_id
   and    piv.element_type_id      = p_eletyp_id
   and    piv.input_value_id       = pbf.input_value_id
   and    alb.defined_balance_id   = pdb.defined_balance_id
   and    pdb.balance_type_id      = pbf.balance_type_id
   and    pac.payroll_action_id    = act.payroll_action_id
   and    pac.effective_date between pbf.effective_start_date
                                 and pbf.effective_end_date
   and    pac.effective_date between piv.effective_start_date
                                 and piv.effective_end_date;
--
   cursor lbc_selective (p_person_id      number,
                         p_eletyp_id      number
                          ) is
   select
          plb.latest_balance_id
     from
          pay_input_values_f         piv,
          pay_balance_feeds_f        pbf,
          pay_defined_balances       pdb,
          pay_latest_balances plb,
          pay_assignment_actions     paa,
          pay_payroll_actions        ppa
    where plb.person_id = p_person_id
    and   piv.element_type_id = p_eletyp_id
    and   piv.input_value_id = pbf.input_value_id
    and   plb.defined_balance_id = pdb.defined_balance_id
    and   pdb.balance_type_id = pbf.balance_type_id
    and   paa.assignment_action_id = plb.assignment_action_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.effective_date between pbf.effective_start_date
                               and pbf.effective_end_date
    and   ppa.effective_date between piv.effective_start_date
                               and piv.effective_end_date;
--
   l_person_id number;
   l_element_type_id number;
begin
   g_debug := hr_utility.debug_enabled;
--
   -- Simply return the person_id for the assignment.
   if g_debug then
      hr_utility.set_location('hrassact.del_latest_balances',10);
   end if;
   select asg.person_id
   into   l_person_id
   from   per_all_assignments_f asg
   where  asg.assignment_id = p_assignment_id
   and    p_effective_date between
          asg.effective_start_date and asg.effective_end_date;
--
   if (p_element_entry is null) and (p_element_type_id is null) then
      -- Delete (person) balance context values.
      if g_debug then
         hr_utility.set_location('hrassact.del_latest_balances',20);
      end if;
      for plbcrec in plbc(l_person_id) loop
         delete from pay_balance_context_values BCV
         where  BCV.latest_balance_id = plbcrec.latest_balance_id;
--
         delete from pay_person_latest_balances PLB
         where  PLB.latest_balance_id = plbcrec.latest_balance_id;
      end loop;
--
      -- We need to delete all latest balances for the
      -- person's period of service.
      if g_debug then
         hr_utility.set_location('hrassact.del_latest_balances',40);
      end if;
      for albcrec in albc(l_person_id) loop
         delete from pay_balance_context_values BCV
         where  BCV.latest_balance_id = albcrec.latest_balance_id;
--
         delete from pay_assignment_latest_balances ALB
         where  ALB.latest_balance_id = albcrec.latest_balance_id;
      end loop;
--
      if g_debug then
         hr_utility.set_location('hrassact.del_latest_balances',45);
      end if;
      for lbcrec in lbc(l_person_id) loop
         delete from pay_latest_balances ALB
         where  ALB.latest_balance_id = lbcrec.latest_balance_id;
      end loop;
   else
--
      l_element_type_id := p_element_type_id;
      --
      -- Check if the element type id is specified.
      --
      if l_element_type_id is null then
        --
        -- Derive the element type id from the entry id.
        --
        if g_debug then
           hr_utility.set_location('hrassact.del_latest_balances',60);
        end if;
        select pel.element_type_id into l_element_type_id
        from pay_element_entries_f pee
            ,pay_element_links_f   pel
        where
            pee.element_entry_id = p_element_entry
        and p_effective_date between pee.effective_start_date
                                 and pee.effective_end_date
        and pel.element_link_id = pee.element_link_id
        and p_effective_date between pel.effective_start_date
                                 and pel.effective_end_date
        ;
      end if;
      -- Delete (person) balance context values.
      if g_debug then
         hr_utility.set_location('hrassact.del_latest_balances',70);
      end if;
      for plbcrec in plbc_selective(l_person_id, l_element_type_id) loop
         delete from pay_balance_context_values BCV
         where  BCV.latest_balance_id = plbcrec.latest_balance_id;
--
         delete from pay_person_latest_balances PLB
         where  PLB.latest_balance_id = plbcrec.latest_balance_id;
      end loop;
--
      -- Delete contexts and latest balances for assignment.
      -- We need to delete all latest balances for the
      -- person's period of service.
      if g_debug then
         hr_utility.set_location('hrassact.del_latest_balances',80);
      end if;
      for albcrec in albc_selective(l_person_id, l_element_type_id) loop
         delete from pay_balance_context_values BCV
         where  BCV.latest_balance_id = albcrec.latest_balance_id;
--
         delete from pay_assignment_latest_balances ALB
         where  ALB.latest_balance_id = albcrec.latest_balance_id;
      end loop;
--
      if g_debug then
         hr_utility.set_location('hrassact.del_latest_balances',85);
      end if;
      for lbcrec in lbc_selective(l_person_id, l_element_type_id) loop
         delete from pay_latest_balances ALB
         where  ALB.latest_balance_id = lbcrec.latest_balance_id;
      end loop;
   end if;
--
end del_latest_balances;
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
                                        rmode    in varchar2)
      is
         pact number;
         actseq number;
         asgid  number;
         newseq number;
      begin
        select payroll_action_id,
               action_sequence,
               assignment_id,
               pay_assignment_actions_s.nextval
          into pact,
               actseq,
               asgid,
               newseq
          from pay_assignment_actions
         where assignment_action_id = p_assact;
--
        resequence_actions(pact, asgid, actseq, rmode);
--
        update pay_assignment_actions
           set action_sequence = newseq
         where assignment_action_id = p_assact;
--
        update pay_run_balances
           set action_sequence = newseq
         where assignment_action_id = p_assact;
--
      end update_action_sequence;
--
      --------------------------- resequence_chunk ----------------------
      /*
         NAME
            resequence_chunk
         DESCRIPTION
            Resequence sequenced actions for a whole chunk of assignments.
         NOTES
      */
      procedure resequence_chunk
      (
         pactid    in number,
         cnkno     in number,
         rmode    in varchar2, -- rule_mode (time period independent Y or N)
         chldact  in varchar2 default 'N' -- update child actions (Y or N)
      ) is
      --
        cursor cnkasg is
        select ppa.effective_date,
               paa.assignment_action_id,
               ppa.action_type
          from pay_payroll_actions ppa,
               pay_assignment_actions paa
         where ppa.payroll_action_id = pactid
           and paa.payroll_action_id = ppa.payroll_action_id
           and paa.source_action_id is null
           and paa.chunk_number = cnkno;
      --
      begin
      --
         for asgrec in cnkasg loop
            resequence_actions(
                               asgrec.assignment_action_id,
                               rmode,
                               chldact,
                               asgrec.action_type);
         end loop;
      --
      end resequence_chunk;
--
      --------------------------- resequence_actions ---------------------------
---
      /*
         NAME
            resequence_actions
         DESCRIPTION
            Resequence sequenced actions.
         NOTES
      */
      procedure resequence_actions
      (
         aaid      in number,
         rmode     in varchar2, -- rule_mode (time period independent Y or N)
         chldact   in varchar2 default 'N', -- update child actions (Y or N)
         actype    in varchar2  -- action_type
      ) is
--
         --
         cursor seqasg (
                        aaid  number,
                        chldact varchar2
                        ) is
         select ac2.rowid,
                ac2.assignment_action_id
         from   pay_action_classifications acl,
                pay_assignment_actions     ac2,
                pay_assignment_actions     paa,
                pay_payroll_actions        ppa,
                pay_payroll_actions        pa2
         where paa.assignment_action_id = aaid
         and   ppa.payroll_action_id = paa.payroll_action_id
         and    ac2.assignment_id       = paa.assignment_id
         and    pa2.payroll_action_id   = ac2.payroll_action_id
         and    acl.classification_name = 'SEQUENCED'
         and    pa2.effective_date      > ppa.effective_date
         and    pa2.action_type         = acl.action_type
         and    ((     chldact = 'N'
                  and  ac2.source_action_id is null)
                 or
                  (    chldact = 'Y')
                )
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;
   --
         cursor seqper (
                        aaid  number,
                        chldact varchar2
                        ) is
         select ac2.rowid,
                ac2.assignment_action_id
         from   pay_action_classifications acl,
                pay_assignment_actions     ac2,
                pay_assignment_actions     act,
                per_all_assignments_f          as2,
                per_all_assignments_f          asg,
                pay_payroll_actions        pa2,
                pay_payroll_actions        pac
         where act.assignment_action_id = aaid
         and   pac.payroll_action_id    = act.payroll_action_id
         and    asg.assignment_id        = act.assignment_id
         and    pac.effective_date between
                asg.effective_start_date and asg.effective_end_date
         and    as2.person_id            = asg.person_id
         and    as2.effective_end_date   > pac.effective_date
         and    ac2.assignment_id        = as2.assignment_id
         and    pa2.payroll_action_id    = ac2.payroll_action_id
         and    as2.effective_start_date = (select max(paf3.effective_start_date)
                                              from per_all_assignments_f paf3
                                             where paf3.assignment_id = ac2.assignment_id
                                               and paf3.effective_start_date <= pa2.effective_date
                                           )
         and    acl.classification_name  = 'SEQUENCED'
         and    pa2.action_type          = acl.action_type
         and    pa2.effective_date       > pac.effective_date
         and    ((     chldact = 'N'
                  and  ac2.source_action_id is null)
                 or
                  (    chldact = 'Y')
                )
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;
--
--       G when aaid is not a retropay (ie act.assignment is not null)
--
         cursor seqgrp (
                        aaid  number,
                        chldact varchar2
                        ) is
         select ac2.rowid,
                ac2.assignment_action_id
         from
             (
         select distinct ac3.assignment_action_id
         from   pay_assignment_actions     act,
                pay_object_groups          pog,
                pay_object_groups          pog2,
                pay_object_groups          pog3,
                pay_payroll_actions        pac,
                pay_object_groups          pog4,
                pay_assignment_actions     ac3,
                pay_payroll_actions        pa3,
                pay_action_classifications acl
         where  act.assignment_action_id = aaid
         and    pac.payroll_action_id    = act.payroll_action_id
         and    pog.source_id            = act.assignment_id
         and    pog.source_type          = 'PAF'
         and    pog2.object_group_id     = pog.parent_object_group_id
         and    pog2.source_type         = 'PPF'
         and    pog3.source_id           = pog2.source_id
         and    pog3.source_type         = 'PPF'
         and    pog4.parent_object_group_id = pog3.object_group_id
         and    ac3.assignment_id     = pog4.source_id
         and    pa3.payroll_action_id = ac3.payroll_action_id
         and    pa3.effective_date    > pac.effective_date
         and    pa3.action_type      <> 'L'
         and    pa3.action_type       = acl.action_type
         and    acl.classification_name = 'SEQUENCED'
                union all
         select distinct ac3.assignment_action_id
         from   pay_assignment_actions     act,
                pay_object_groups          pog,
                pay_object_groups          pog2,
                pay_object_groups          pog3,
                pay_payroll_actions        pac,
                pay_assignment_actions     ac3,
                pay_payroll_actions        pa3
         where  act.assignment_action_id = aaid
         and    pac.payroll_action_id    = act.payroll_action_id
         and    pog.source_id            = act.assignment_id
         and    pog.source_type          = 'PAF'
         and    pog2.object_group_id     = pog.parent_object_group_id
         and    pog2.source_type         = 'PPF'
         and    pog3.source_id           = pog2.source_id
         and    pog3.source_type         = 'PPF'
         and    ac3.object_id         = pog3.object_group_id
         and    ac3.object_type       = 'POG'
         and    pa3.payroll_action_id = ac3.payroll_action_id
         and    pa3.effective_date    > pac.effective_date
         and    pa3.action_type       = 'L') V,
                  pay_assignment_actions     ac2,
                  pay_payroll_actions        pa2
         where ac2.assignment_action_id = V.assignment_action_id
         and    pa2.payroll_action_id    = ac2.payroll_action_id
         and    ((     chldact = 'N'
                  and  ac2.source_action_id is null)
                 or
                  (    chldact = 'Y')
                )
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;
--
--       G when aaid is a retropay (ie act.assignment is null)
--
         cursor seqgrpret (
                        aaid  number,
                        chldact varchar2
                        ) is
         select ac2.rowid,
                ac2.assignment_action_id
         from
             (
         select distinct ac3.assignment_action_id
         from   pay_assignment_actions     act,
                pay_object_groups          pog,
                pay_object_groups          pog2,
                pay_payroll_actions        pac,
                pay_object_groups          pog3,
                pay_assignment_actions     ac3,
                pay_payroll_actions        pa3,
                pay_action_classifications acl
         where  act.assignment_action_id = aaid
         and    pac.payroll_action_id    = act.payroll_action_id
         and    pog.object_group_id      = act.object_id
         and    pog.source_type          = 'PPF'
         and    pog2.source_id           = pog.source_id
         and    pog2.source_type         = 'PPF'
         and    pog3.parent_object_group_id = pog2.object_group_id
         and    ac3.assignment_id     = pog3.source_id
         and    pa3.payroll_action_id = ac3.payroll_action_id
         and    pa3.effective_date    > pac.effective_date
         and    pa3.action_type      <> 'L'
         and    pa3.action_type       = acl.action_type
         and    acl.classification_name = 'SEQUENCED'
                union all
         select distinct ac3.assignment_action_id
         from   pay_assignment_actions     act,
                pay_object_groups          pog,
                pay_object_groups          pog2,
                pay_payroll_actions        pac,
                pay_assignment_actions     ac3,
                pay_payroll_actions        pa3
         where  act.assignment_action_id = aaid
         and    pac.payroll_action_id    = act.payroll_action_id
         and    pog.object_group_id      = act.object_id
         and    pog.source_type          = 'PPF'
         and    pog2.source_id           = pog.source_id
         and    pog2.source_type         = 'PPF'
         and    ac3.object_id         = pog2.object_group_id
         and    ac3.object_type       = 'POG'
         and    pa3.payroll_action_id = ac3.payroll_action_id
         and    pa3.effective_date    > pac.effective_date
         and    pa3.action_type       = 'L') V,
                  pay_assignment_actions     ac2,
                  pay_payroll_actions        pa2
         where ac2.assignment_action_id = V.assignment_action_id
         and    pa2.payroll_action_id    = ac2.payroll_action_id
         and    ((     chldact = 'N'
                  and  ac2.source_action_id is null)
                 or
                  (    chldact = 'Y')
                )
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;
--
         my_rowid rowid;
         upd_aa_id pay_assignment_actions.assignment_action_id%type;
--
      begin
--
         g_debug := hr_utility.debug_enabled;
--
         if g_debug then
            hr_utility.set_location('hrassact.resequence_actions', 10);
         end if;
         if(rmode = 'Y') then
            open seqasg(aaid, chldact);
         elsif (rmode = 'N') then
            open seqper(aaid, chldact);
         else
            -- G mode
            if (actype = 'L') then
               open seqgrpret(aaid, chldact);
            else
               open seqgrp(aaid, chldact);
            end if;
         end if;
--
         loop
            -- fetch the rowid and then update.
            if(rmode = 'Y') then
               fetch seqasg into my_rowid, upd_aa_id;
               exit when seqasg%notfound;
            elsif (rmode = 'N') then
               fetch seqper into my_rowid, upd_aa_id;
               exit when seqper%notfound;
            else
               -- G mode
               if (actype = 'L') then
                  fetch seqgrpret into my_rowid, upd_aa_id;
                  exit when seqgrpret%notfound;
               else
                  fetch seqgrp into my_rowid, upd_aa_id;
                  exit when seqgrp%notfound;
               end if;
            end if;
--
            --
            -- Now, update with new action_sequence.
            update pay_assignment_actions act
            set    act.action_sequence = pay_assignment_actions_s.nextval
            where  act.rowid           = my_rowid;
--
            update pay_run_balances
               set action_sequence = pay_assignment_actions_s.currval
             where assignment_action_id = upd_aa_id;
--
         end loop;
--
         --
         -- we are finished with the cursor, so we close it here.
         if(rmode = 'Y') then
            close seqasg;
         elsif(rmode = 'N') then
            close seqper;
         else
            -- G mode
            if (actype = 'L') then
               close seqgrpret;
            else
               close seqgrp;
            end if;
         end if;
--
         if g_debug then
            hr_utility.set_location('hrassact.resequence_actions', 20);
         end if;
      end resequence_actions;
--
      procedure resequence_children(p_asg_action in number)
      is
--
         cursor get_chld (p_aa_id number)
         is
         select assignment_action_id
           from pay_assignment_actions
          where source_action_id = p_aa_id
          order by action_sequence;
--
      begin
--
         for chdrec in get_chld(p_asg_action) loop
--
           resequence_children(chdrec.assignment_action_id);
--
           update pay_assignment_actions
              set action_sequence = pay_assignment_actions_s.nextval
            where assignment_action_id = chdrec.assignment_action_id;
--
         end loop;
--
      end resequence_children;
--
      procedure resequence_actions
      (
         pactid    in number,
         asgid    in number,
         actseq    in number,
         rmode    in varchar2  -- rule_mode (time period independent Y or N)
      ) is
--
         --
         cursor seqasg (
                        asgid  number,
                        actseq number) is
         select /*+ INDEX (pa2 PAY_PAYROLL_ACTIONS_PK) */
                ac2.rowid,
                ac2.assignment_action_id,
                ac2.source_action_id,
                ac2.object_type
         from   pay_action_classifications acl,
                pay_assignment_actions     ac2,
                pay_payroll_actions        pa2
         where  ac2.assignment_id       = asgid
         and    pa2.payroll_action_id   = ac2.payroll_action_id
         and    acl.classification_name = 'SEQUENCED'
         and    pa2.action_type         = acl.action_type
         and    ac2.action_sequence > actseq
         and    (ac2.source_action_id is null
                 or
                   (ac2.object_id is not null
                    and ac2.object_type = 'POG')
                )
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;
   --
         cursor seqper (pactid number,
                        asgid  number,
                        actseq number,
                        rmode  varchar2) is
         select /*+ ORDERED
                    INDEX (ac2 PAY_ASSIGNMENT_ACTIONS_N51)
                          (pa2 PAY_PAYROLL_ACTIONS_PK) */
                ac2.rowid,
                ac2.assignment_action_id,
                ac2.source_action_id,
                ac2.object_type
         from   pay_payroll_actions        pac,
                per_all_assignments_f          asg,
                per_all_assignments_f          as2,
                pay_assignment_actions     act,
                pay_assignment_actions     ac2,
                pay_payroll_actions        pa2,
                pay_action_classifications acl
         where  pac.payroll_action_id    = pactid
         and    act.payroll_action_id    = pac.payroll_action_id
         and    act.assignment_id        = asgid
         and    act.source_action_id is null
         and    asg.assignment_id        = act.assignment_id
         and    pac.effective_date between
                asg.effective_start_date and asg.effective_end_date
         and    as2.person_id            = asg.person_id
         and    decode(rmode, 'G', pac.effective_date,
                                   as2.effective_end_date) >= pac.effective_date
         and    ac2.assignment_id        = as2.assignment_id
         and    pa2.payroll_action_id    = ac2.payroll_action_id
         and    as2.effective_start_date = (select max(paf3.effective_start_date)
                                              from per_all_assignments_f paf3
                                             where paf3.assignment_id = ac2.assignment_id
                                           )
         and    acl.classification_name  = 'SEQUENCED'
         and    pa2.action_type          = acl.action_type
         and    ac2.action_sequence > actseq
         and    (ac2.source_action_id is null
                 or
                   (ac2.object_id is not null
                    and ac2.object_type = 'POG')
                )
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;
  --
  --     G nb pactid is never a retropay
  --
         cursor seqgrp (pactid number,
                        asgid  number,
                        actseq number,
                        rmode  varchar2) is
         select /*+ ORDERED
                    INDEX (ac2 PAY_ASSIGNMENT_ACTIONS_PK)
                          (pa2 PAY_PAYROLL_ACTIONS_PK) */
                ac2.rowid,
                ac2.assignment_action_id,
                ac2.source_action_id,
                ac2.object_type
        from
            (
         select /*+ ORDERED */
                distinct ac3.assignment_action_id
         from   pay_payroll_actions        pac,
                pay_assignment_actions     act,
                pay_object_groups          pog,
                pay_object_groups          pog2,
                pay_object_groups          pog3,
                pay_object_groups          pog4,
                pay_assignment_actions     ac3,
                pay_payroll_actions        pa3,
                pay_action_classifications acl
         where  pac.payroll_action_id    = pactid
         and    act.payroll_action_id    = pac.payroll_action_id
         and    act.assignment_id        = asgid
         and    act.source_action_id is null
         and    pog.source_id            = act.assignment_id
         and    pog.source_type          = 'PAF'
         and    pac.effective_date between
                pog.start_date and pog.end_date
         and    pog2.object_group_id     = pog.parent_object_group_id
         and    pog2.source_type         = 'PPF'
         and    pog3.source_id           = pog2.source_id
         and    pog3.source_type         = 'PPF'
         and    pog4.parent_object_group_id = pog3.object_group_id
         and    ac3.assignment_id     = pog4.source_id
         and    ac3.action_sequence   > actseq
         and    pa3.payroll_action_id = ac3.payroll_action_id
         and    pa3.action_type      <> 'L'
         and    pa3.action_type       = acl.action_type
         and    acl.classification_name = 'SEQUENCED'
                union all
         select /*+ ORDERED */
                distinct ac3.assignment_action_id
         from   pay_payroll_actions        pac,
                pay_assignment_actions     act,
                pay_object_groups          pog,
                pay_object_groups          pog2,
                pay_object_groups          pog3,
                pay_assignment_actions     ac3,
                pay_payroll_actions        pa3
         where  pac.payroll_action_id    = pactid
         and    act.payroll_action_id    = pac.payroll_action_id
         and    act.assignment_id        = asgid
         and    act.source_action_id is null
         and    pog.source_id            = act.assignment_id
         and    pog.source_type          = 'PAF'
         and    pac.effective_date between
                pog.start_date and pog.end_date
         and    pog2.object_group_id     = pog.parent_object_group_id
         and    pog2.source_type         = 'PPF'
         and    pog3.source_id           = pog2.source_id
         and    pog3.source_type         = 'PPF'
         and    ac3.object_id         = pog3.object_group_id
         and    ac3.object_type       = 'POG'
         and    ac3.action_sequence   > actseq
         and    pa3.payroll_action_id = ac3.payroll_action_id
         and    pa3.action_type       = 'L') V,
                  pay_assignment_actions     ac2,
                  pay_payroll_actions        pa2
         where ac2.assignment_action_id = V.assignment_action_id
         and    pa2.payroll_action_id    = ac2.payroll_action_id
         and    (ac2.source_action_id is null
                 or
                   (ac2.object_id is not null
                    and ac2.object_type = 'POG')
                )
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;

--
         my_rowid rowid;
         upd_aa_id pay_assignment_actions.assignment_action_id%type;
         src_aa_id pay_assignment_actions.source_action_id%type;
         obj_type pay_assignment_actions.object_type%type;
--
      begin
--
         g_debug := hr_utility.debug_enabled;
--
hr_utility.trace('passing pact = '||pactid);
hr_utility.trace('passing asgid = '||asgid);
hr_utility.trace('passing actseq = '||actseq);
--
         if g_debug then
            hr_utility.set_location('hrassact.resequence_actions', 10);
         end if;
         if(rmode = 'Y') then
            open seqasg(asgid,actseq);
         elsif(rmode = 'N') then
            open seqper(pactid, asgid,actseq,rmode);
         else
            open seqgrp(pactid, asgid,actseq,rmode);
         end if;
--
         loop
            -- fetch the rowid and then update.
            if(rmode = 'Y') then
               fetch seqasg into my_rowid, upd_aa_id, src_aa_id, obj_type;
               exit when seqasg%notfound;
            elsif(rmode = 'N') then
               fetch seqper into my_rowid, upd_aa_id, src_aa_id, obj_type;
               exit when seqper%notfound;
            else
               fetch seqgrp into my_rowid, upd_aa_id, src_aa_id, obj_type;
               exit when seqgrp%notfound;
            end if;
--
hr_utility.trace('Resequenceing '||upd_aa_id);
            resequence_children(upd_aa_id);
--
            --
            -- Now, update with new action_sequence.
            update pay_assignment_actions act
            set    act.action_sequence = pay_assignment_actions_s.nextval
            where  act.rowid           = my_rowid;
--
            update pay_run_balances
               set action_sequence = pay_assignment_actions_s.currval
             where assignment_action_id = upd_aa_id;
--
            /* If it's an assignment action thats created due to a
               POG then we need to up the POGs action sequence
            */
            if (obj_type is not null
                and obj_type = 'POG'
                and src_aa_id is not null) then
--
              update pay_assignment_actions act
              set    act.action_sequence = pay_assignment_actions_s.nextval
              where  act.assignment_action_id = src_aa_id;
--
            end if;
--
         end loop;
--
         --
         -- we are finished with the cursor, so we close it here.
         if(rmode = 'Y') then
            close seqasg;
         elsif(rmode = 'N') then
            close seqper;
         else
            close seqgrp;
         end if;
         if g_debug then
            hr_utility.set_location('hrassact.resequence_actions', 20);
         end if;
      end resequence_actions;
--
--
/*---------------------------  applied_interlocks  -------------------------*/
/*
 *   Returns a string of the assignment actions ids which are locked by
 *   the assignment action p_locking_action_id.
 */
--
function applied_interlocks(p_locking_action_id number) return varchar2 is
--
    -- Cursor definitions
    cursor interlocks(p_locking_action_id number) is
        select int.locked_action_id locked_action_id
          from pay_action_interlocks int
         where int.locking_action_id = p_locking_action_id
      order by int.locked_action_id;
--
    -- Local variables
    v_string_max_length  constant number := 240;
    v_string             varchar2(240)   := NULL;
    v_max_length_reached boolean         := false;
--
  begin
     g_debug := hr_utility.debug_enabled;
--
     -- Find interlocks for this assignment action
     if g_debug then
        hr_utility.set_location('hrassact.applied_interlocks',10);
      end if;
     <<interlocks_loop>>
     for locked IN interlocks(p_locking_action_id) loop
--
       if length(rtrim(v_string)) is null then
         -- If this is the first locked action id set the string to the id
         v_string := locked.locked_action_id;
       else
--
         if length(rtrim(v_string)) + 1 +
            length(rtrim(locked.locked_action_id)) <= v_string_max_length then
           -- For the second and subsequent locked action ids, append them to
           -- the current string, if there is enough space left for the dash
           -- and the whole of the id.
           if g_debug then
              hr_utility.set_location('hrassact.applied_interlocks',20);
           end if;
           v_string := v_string || '-' || locked.locked_action_id;
         else
--
           if length(rtrim(v_string))+2 <= v_string_max_length then
              -- If there is no space left at the end of the string for the
              -- current locked action id, add the arrow symbol to the end
              -- of the string
              if g_debug then
                 hr_utility.set_location('hrassact.applied_interlocks',30);
              end if;
              v_string := v_string || '->';
           else
              -- If the end of the string has already been reached,
              -- replace the last id with the arrow symbol
              if g_debug then
                 hr_utility.set_location('hrassact.applied_interlocks',40);
              end if;
              v_string := substr(v_string, 1, instr(v_string, '-', -1, 1)-1)
                          || '->';
           end if;
--
           v_max_length_reached := true;
--
         end if;                         -- end if length(v_string) + 1 ...
--
       end if;                           -- end if v_string = ''
--
       -- If the end of the string has been reached then end the loop,
       -- as there is no space in v_string to list any more ids
       exit interlocks_loop when v_max_length_reached;
--
     end loop interlocks_loop;           -- end for locked IN interlocks
--
     if g_debug then
        hr_utility.set_location('hrassact.applied_interlocks',40);
     end if;
     return v_string;
--
  end applied_interlocks;
--
   ------------------- get_default_leg_value -------------------
   /*
      NAME
         get_default_leg_value
      DESCRIPTION
         Given a legislative procedure name, identifier
         and an element entry id. This procedure calculates
         the default value.
   */
procedure get_default_leg_value (p_plsql_proc in varchar2,
                                 p_identifier in number,
                                 p_entry      in number,
                                 p_effdate    in date,
                                 p_value      out nocopy varchar2)
is
l_def_rt_str        varchar2(2000);  -- used with dynamic pl/sql
sql_cursor           integer;
l_rows               integer;
l_value             varchar2(2000);
begin
   l_def_rt_str := 'begin '||p_plsql_proc||' (';
   l_def_rt_str := l_def_rt_str || ':p_identifier, ';
   l_def_rt_str := l_def_rt_str || ':p_entry, ';
   l_def_rt_str := l_def_rt_str || ':p_effdate, ';
   l_def_rt_str := l_def_rt_str || ':l_value); end; ';
   --
   sql_cursor := dbms_sql.open_cursor;
   --
   dbms_sql.parse(sql_cursor, l_def_rt_str, dbms_sql.v7);
   --
   --
   dbms_sql.bind_variable(sql_cursor, 'p_identifier', p_identifier);
   --
   dbms_sql.bind_variable(sql_cursor, 'p_entry', p_entry);
   --
   dbms_sql.bind_variable(sql_cursor, 'p_effdate', p_effdate);
   --
   dbms_sql.bind_variable(sql_cursor, 'l_value', l_value, 30);
   --
   l_rows := dbms_sql.execute (sql_cursor);
   --
   if (l_rows = 1) then
      dbms_sql.variable_value(sql_cursor, 'l_value',
                              l_value);
      dbms_sql.close_cursor(sql_cursor);
--
   else
      l_value := null;
      dbms_sql.close_cursor(sql_cursor);
   end if;
--
   p_value := l_value;
--
end get_default_leg_value;
--
   ------------------- get_default_leg_value -------------------
   /*
      NAME
         get_default_leg_value
      DESCRIPTION
         Given a legislative procedure name this procedure
         gets the default run type id.
   */
procedure get_default_leg_value
  (p_plsql_proc     in  varchar2
  ,p_effective_date in  varchar2
  ,p_run_type_id    out nocopy number
  ) is
--
begin
  --
  get_default_leg_value
    (p_plsql_proc => p_plsql_proc
    ,p_identifier => null
    ,p_entry      => null
    ,p_effdate    => p_effective_date
    ,p_value      => p_run_type_id
    );

  p_run_type_id := to_number(p_run_type_id);
  --
end;
--
   --------------------------- cache_contexts------------------------
   /*
      NAME
         cache_contexts - This simply sets up a cache of the context
                          names
      DESCRIPTION
      NOTES
   */
procedure cache_contexts
is
--
cursor get_cxt is
select context_name,
       context_id
  from ff_contexts;
--
begin
--
   g_context_cache.sz := 0;
--
   for cxtrec in get_cxt loop
--
     g_context_cache.sz := g_context_cache.sz + 1;
     g_context_cache.cxt_id(g_context_cache.sz) := cxtrec.context_id;
     g_context_cache.cxt_name(g_context_cache.sz) := cxtrec.context_name;
--
   end loop;
--
   contexts_cached := TRUE;
--
end cache_contexts;
--
   --------------------------- get_cache_context------------------------
   /*
      NAME
         get_cache_context - This retrieves the context id given the
                             context name from the cache.
      DESCRIPTION
      NOTES
   */
procedure get_cache_context(p_cxt_name in     varchar2,
                            p_cxt_id   out    nocopy number)
is
--
cxt_num number;
cxt_id  number;
found   boolean;
begin
--
   if (contexts_cached = FALSE) then
      cache_contexts;
   end if;
--
   found := FALSE;
   for cxt_num in 1..g_context_cache.sz loop
--
     if (g_context_cache.cxt_name(cxt_num) = p_cxt_name) then
       found := TRUE;
       cxt_id := g_context_cache.cxt_id(cxt_num);
     end if;
   end loop;
--
   if (found = TRUE) then
     p_cxt_id := cxt_id;
   else
      hr_general.assert_condition(FALSE);
   end if;
--
end get_cache_context;


   --------------------------- inassact ------------------------------
   /*
      NAME
         inassact - INsert ASSignment Action
      DESCRIPTION
         Inserts and validates the insert of an assignment
         action. This is called
         a) from the QuickPay processing procedure (qpassact).
         b) from the Reversal procedure (reversal).
         c) from external/manual payment procedure (ext_man_payment).
         d) from the Balance Adjustment procedure (bal_adjust).
         e) from the hrbaldtm package (connected to balance user exit).
      NOTES
         This procedure handles the interlock rules
         required in the case of QuickPay, and the
         re-sequencing of action_sequence for
         Reversal and Balance Adjustment and External/Manual
         Payments.
         inassact is a cover for inassact_main, to ensure a
         taxunt is passed to inassact_main.
   */
   procedure inassact
   (
      pactid in number,  -- payroll_action_id.
      asgid  in number,   -- assignment_id to create action for.
      p_ass_action_seq in number   default null, --action sequence
      p_serial_number  in varchar2 default null, --cheque number
      p_pre_payment_id in number   default null, --pre payment id
      p_element_entry  in number   default null,
      p_asg_lock       in boolean  default TRUE,  --lock assignment
      p_purge_mode     in boolean  default FALSE, --purge mode
      run_type_id      in number   default null
   ) is
   --
   begin
      hrassact.inassact_main(pactid, asgid, p_ass_action_seq,
                             p_serial_number, p_pre_payment_id,
                             p_element_entry, p_asg_lock, null,
                             p_purge_mode,run_type_id);
   end inassact;
   --
   procedure inassact_main
   (
      pactid in number,  -- payroll_action_id.
      asgid  in number,   -- assignment_id to create action for.
      p_ass_action_seq in number   default null, --action sequence
      p_serial_number  in varchar2 default null, --cheque number
      p_pre_payment_id in number   default null, --pre payment id
      p_element_entry  in number   default null,
      p_asg_lock       in boolean  default TRUE, --lock assignment
      taxunt           in number   default null, -- tax unit id
      p_purge_mode     in boolean  default FALSE --purge mode
   ) is
   --
   begin
          hrassact.inassact_main(pactid, asgid, p_ass_action_seq,
                             p_serial_number, p_pre_payment_id,
                             p_element_entry, p_asg_lock, taxunt,
                             p_purge_mode,null);
   end inassact_main;

   procedure inassact_main
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
      p_run_type_id    in number   default null
   ) is
    aa_id number;
   begin
      aa_id := inassact_main
                    (
                       pactid           => pactid,
                       asgid            => asgid,
                       p_ass_action_seq => p_ass_action_seq,
                       p_serial_number  => p_serial_number,
                       p_pre_payment_id => p_pre_payment_id,
                       p_element_entry  => p_element_entry,
                       p_asg_lock       => p_asg_lock,
                       taxunt           => taxunt,
                       p_purge_mode     => p_purge_mode,
                       p_run_type_id    => p_run_type_id
                    );
   end inassact_main;
--
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
      p_run_type_id    in number   default null ,
      p_mode           in varchar2 default 'STANDARD'
   ) return number
   is
      rmode pay_legislation_rules.rule_mode%type;
      posid per_periods_of_service.period_of_service_id%type;
      actyp pay_payroll_actions.action_type%type;
      bgid  pay_payroll_actions.business_group_id%type;
      l_action_population_status pay_payroll_actions.action_population_status%type;
      aa_id number;
   --
      --------------------------- irbaact ------------------------------
      /*
         NAME
            irbaact - Insert Reversal or Balance Adjustment ACTion.
         DESCRIPTION
            Insert an assignment action for a Reversal,
            Balance Adjustment or non tracked action.
         NOTES
            This procedure copes with the re-sequencing
            that may be required.
            Note the call from the balance user exit code
            via the hrbaldtm.get_bal_ass_action procedure.
      */
      procedure irbaact
      (
         pactid   in number,    -- payroll_action_id.
         asgid    in number,    -- assignment_id of action to create.
         rmode    in varchar2,  -- rule_mode (time period independent Y or N)
         actyp    in varchar2,  -- action type.
         ee_id    in number,    -- element entry id.
         taxunt   in number,    -- tax unit id
         pmode    in boolean,    -- purge mode
         p_run_type_id   in number,    -- tax unit id
         aa_id    in number,
         p_mode   in varchar2
      ) is
--
         --
         -- This cursor selects the rowid values of all
         -- the sequenced assignment actions for the
         -- specified assignment only, that are later
         -- than the effective_date of the specified
         -- payroll action.
         cursor seqasg (pactid number,
                        asgid  number) is
         select ac2.rowid,
                ac2.assignment_action_id
         from   pay_action_classifications acl,
                pay_assignment_actions     ac2,
                pay_assignment_actions     act,
                pay_payroll_actions        pa2,
                pay_payroll_actions        pac
         where  pac.payroll_action_id   = pactid
         and    act.payroll_action_id   = pac.payroll_action_id
         and    act.assignment_id       = asgid
         and    ac2.assignment_id       = act.assignment_id
         and    pa2.payroll_action_id   = ac2.payroll_action_id
         and    acl.classification_name = 'SEQUENCED'
         and    pa2.action_type         = acl.action_type
         and    pa2.effective_date      > pac.effective_date
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;
   --
         --
         -- This cursor selects the rowid values of all
         -- the sequenced assignment actions for the
         -- specified assignment and any other assignments
         -- for that person, that are later than the
         -- effective_date of the specified payroll action.
         -- Grabs all assignments for person, regardless of
         -- period of service.
         --
         cursor seqper (pactid number,
                        asgid  number) is
         select /*+ ORDERED
                    INDEX(ac2 PAY_ASSIGNMENT_ACTIONS_N51) */
                ac2.rowid,
                ac2.assignment_action_id
         from   pay_payroll_actions        pac,
                pay_assignment_actions     act,
                per_all_assignments_f          asg,
                per_all_assignments_f          as2,
                pay_assignment_actions     ac2,
                pay_payroll_actions        pa2,
                pay_action_classifications acl
         where  pac.payroll_action_id    = pactid
         and    act.payroll_action_id    = pac.payroll_action_id
         and    act.assignment_id        = asgid
         and    asg.assignment_id        = act.assignment_id
         and    pac.effective_date between
                asg.effective_start_date and asg.effective_end_date
         and    as2.person_id            = asg.person_id
         and    as2.effective_end_date   > pac.effective_date
         and    ac2.assignment_id        = as2.assignment_id
         and    pa2.payroll_action_id    = ac2.payroll_action_id
         and    pa2.effective_date between
                as2.effective_start_date and as2.effective_end_date
         and    acl.classification_name  = 'SEQUENCED'
         and    pa2.action_type          = acl.action_type
         and    pa2.effective_date       > pac.effective_date
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;
--
         --
         -- Pay Object Group (G itpflag):
         -- This cursor selects the rowid values of all
         -- the sequenced assignment actions for the
         -- specified assignment and any other assignments
         -- for that person, that are later than the
         -- effective_date of the specified payroll action.
         -- Grabs all assignments for person, regardless of
         -- period of service.
         --
         cursor seqgrp (pactid number,
                        asgid  number) is
         select /*+ ORDERED
                    INDEX(ac2 PAY_ASSIGNMENT_ACTIONS_PK) */
                ac2.rowid,
                ac2.assignment_action_id
         from
            (
         select /*+ ORDERED */
                distinct ac3.assignment_action_id
         from   pay_payroll_actions        pac,
                pay_assignment_actions     act,
                pay_object_groups          pog,
                pay_object_groups          pog2,
                pay_object_groups          pog3,
                pay_object_groups          pog4,
                pay_assignment_actions     ac3,
                pay_payroll_actions        pa3,
                pay_action_classifications acl
         where  pac.payroll_action_id    = pactid
         and    act.payroll_action_id    = pac.payroll_action_id
         and    act.assignment_id        = asgid
         and    pog.source_id            = act.assignment_id
         and    pog.source_type          = 'PAF'
         and    pog2.object_group_id     = pog.parent_object_group_id
         and    pog2.source_type         = 'PPF'
         and    pog3.source_id           = pog2.source_id
         and    pog3.source_type         = 'PPF'
         and    pog4.parent_object_group_id = pog3.object_group_id
         and    ac3.assignment_id     = pog4.source_id
         and    pa3.payroll_action_id = ac3.payroll_action_id
         and    pa3.effective_date    > pac.effective_date
         and    pa3.action_type      <> 'L'
         and    pa3.action_type       = acl.action_type
         and    acl.classification_name = 'SEQUENCED'
                union all
         select /*+ ORDERED */
                distinct ac3.assignment_action_id
         from   pay_payroll_actions        pac,
                pay_assignment_actions     act,
                pay_object_groups          pog,
                pay_object_groups          pog2,
                pay_object_groups          pog3,
                pay_assignment_actions     ac3,
                pay_payroll_actions        pa3
         where  pac.payroll_action_id    = pactid
         and    act.payroll_action_id    = pac.payroll_action_id
         and    act.assignment_id        = asgid
         and    pog.source_id            = act.assignment_id
         and    pog.source_type          = 'PAF'
         and    pog2.object_group_id     = pog.parent_object_group_id
         and    pog2.source_type         = 'PPF'
         and    pog3.source_id           = pog2.source_id
         and    pog3.source_type         = 'PPF'
         and    ac3.object_id         = pog3.object_group_id
         and    ac3.object_type       = 'POG'
         and    pa3.payroll_action_id = ac3.payroll_action_id
         and    pa3.effective_date    > pac.effective_date
         and    pa3.action_type       = 'L') V,
                  pay_assignment_actions     ac2,
                  pay_payroll_actions        pa2
         where ac2.assignment_action_id = V.assignment_action_id
         and    pa2.payroll_action_id    = ac2.payroll_action_id
         order by pa2.effective_date, ac2.action_sequence
         for update of ac2.assignment_action_id;
--
         cursor perasg (persid number) is
         select distinct paf.assignment_id
         from per_all_assignments_f paf
         where paf.person_id = persid;
--
         cursor perobj (asgid number) is
         select distinct pog_grp.source_id assignment_id
         from pay_object_groups      pog_act,
              pay_object_groups      pog_grp
         where pog_act.source_id = asgid
         and   pog_act.source_type = 'PAF'
         and   pog_act.parent_object_group_id = pog_grp.parent_object_group_id
         and   pog_grp.source_type = 'PAF';
--
         my_rowid rowid;
         upd_aa_id pay_assignment_actions.assignment_action_id%type;
         actype   pay_payroll_actions.action_type%type;
         effdate  date;  -- the effective date of the payroll action.
         lgcode   varchar2(30);  -- Used to check if the US legislation.
         persid    number; -- assignments person_id
         taxunt2   number;        -- The tax unit id if legislation is US
         l_run_type_id number;
         aa_exists number;
--
      begin
         g_debug := hr_utility.debug_enabled;
--
         taxunt2 := null;
         l_run_type_id := p_run_type_id;
--
         -- Need the effective date of the payroll action.
         -- Also want to see the action_type.
         if(actyp <> 'X') then
            -- Do not need either effective date or leg code for 'X'.
            -- Need the effective date of the payroll action.
            -- Also want to see the action_type.
            -- The legislation and the tax unit is also needed for the US.
            if g_debug then
               hr_utility.set_location('hrassact.irbaact',10);
--
               hr_utility.trace('pactid = '||pactid);
               hr_utility.trace('assignment_id = '||asgid);
            end if;
--
            select pac.effective_date,
                   pac.action_type,
                   pbg.legislation_code,
                   asg.person_id
            into   effdate, actype, lgcode, persid
            from
                   per_business_groups_perf pbg,
                   per_all_assignments_f   asg,
                   pay_payroll_actions pac
            where  pac.payroll_action_id      = pactid
            and    pbg.business_group_id      = asg.business_group_id
            and    asg.assignment_id          = asgid
            and    pac.effective_date between
                        asg.effective_start_date and asg.effective_end_date;
--
            if    (actyp not in ('V','B','I'))
               or ((actyp in ('B','I')) and (taxunt is null)) then
              --
              taxunt2 := hr_dynsql.get_tax_unit(asgid, effdate);
            end if;
--
            if g_debug then
               hr_utility.set_location('hrassact.irbaact',11);
            end if;
         end if;
--
         if (actyp = 'V') then
            taxunt2 := taxunt;
         end if;
--
         -- Need to set the run type for Bal Adj.
         -- Note, this is not done for Initialisation. These
         -- Have to be set explicitly on initialisation.
         if (actyp = 'B') then
--
          declare
            l_rt_id varchar2(10);
            default_run_type pay_legislation_rules.rule_mode%type;
          begin
           if (p_run_type_id is null) then
             begin
               select rule_mode
               into default_run_type
               from pay_legislation_rules
               where legislation_code = lgcode
               and   rule_type        = 'DEFAULT_RUN_TYPE';
             exception
                when no_data_found then
                  default_run_type := 'N';
             end;
--
             if (default_run_type = 'Y') then
               get_default_leg_value('pay_' || lgcode || '_rules.get_default_run_type',
                                     asgid,
                                     ee_id,
                                     effdate,
                                     l_rt_id);
               l_run_type_id := to_number(l_rt_id);
             end if;
           end if;
          end;
         end if;
--
         if (actyp in ('B', 'I')) then
           if (taxunt is not null) then
              taxunt2 := taxunt;
           end if;
         end if;
--
         -- Before we go further, trash latest balances.
         -- Don't trash for non tracked action.
         -- Note that this is used for the balance function.

         if(actype <> 'N' and actype <> 'X' and actype <> 'B' and
            actype <> 'I' and actype <> 'V') then
            del_latest_balances(asgid, effdate, p_element_entry);
         end if;
--
         -- insert an assigment action.
        if g_debug then
            hr_utility.set_location('hrassact.irbaact',20);
         end if;
         if((actype = 'V' or actype = 'I' or actype = 'B')
             and p_mode <> 'BACKPAY') then
         -- we need to check that there isn't a failed action for this
         -- assignment/person/group
         if (rmode = 'Y') then
            begin
               select 1
               into aa_exists
               from dual
               where exists (
                      select /*+ INDEX (pay_pa2 pay_payroll_actions_pk) */ null
                      from   pay_action_classifications pay_acl,
                             pay_payroll_actions        pay_pa2,
                             pay_assignment_actions     pay_ac2
                      where  pay_ac2.assignment_id       = asgid
                      and    pay_pa2.payroll_action_id   = pay_ac2.payroll_action_id
                      and    pay_acl.classification_name = 'SEQUENCED'
                      and    pay_pa2.action_type         = pay_acl.action_type
                      and    pay_ac2.action_status not in ('C', 'S', 'B'));
            exception
               when no_data_found then
                  aa_exists := 0;
            end;
         elsif (rmode = 'N') then
            aa_exists := 0;
            for dprec in perasg(persid) loop
               begin
                  select 1
                  into aa_exists
                  from sys.dual
                  where exists (
                      select /*+ INDEX (pay_pa2 pay_payroll_actions_pk) */ null
                      from   pay_action_classifications pay_acl,
                             pay_payroll_actions        pay_pa2,
                             pay_assignment_actions     pay_ac2
                      where  pay_ac2.assignment_id       = dprec.assignment_id
                      and    pay_pa2.payroll_action_id   = pay_ac2.payroll_action_id
                      and    pay_acl.classification_name = 'SEQUENCED'
                      and    pay_pa2.action_type         = pay_acl.action_type
                      and    pay_ac2.action_status not in ('C', 'S', 'B'));

                  exit;
               exception
                  when no_data_found then
                     null;
               end;
            end loop;
         else
            -- rmode = G
            aa_exists := 0;
            for dprec in perobj(asgid) loop
               begin
                  select 1
                  into aa_exists
                  from sys.dual
                  where exists (
                      select /*+ INDEX (pay_pa2 pay_payroll_actions_pk) */ null
                      from   pay_action_classifications pay_acl,
                             pay_payroll_actions        pay_pa2,
                             pay_assignment_actions     pay_ac2
                      where  pay_ac2.assignment_id       = dprec.assignment_id
                      and    pay_pa2.payroll_action_id   = pay_ac2.payroll_action_id
                      and    pay_acl.classification_name = 'SEQUENCED'
                      and    pay_pa2.action_type         = pay_acl.action_type
                      and    pay_ac2.action_status not in ('C', 'S', 'B'));

                  exit;
               exception
                  when no_data_found then
                     null;
               end;
            end loop;
         end if;
         if(aa_exists <> 0) then
            hr_utility.set_message(801,'HR_7010_ACTION_INTLOCK_FAIL');
            hr_utility.raise_error;
         end if;
         end if;
         -- we need to check that there is not a purge action
         -- with an effective date later than the effective
         -- date of the assignment action we are about to
         -- insert. If so, raise an error.
         -- An exception is the 'I' action.  It can be inserted
         -- before a purge, because a Purge uses balance
         -- initialisation to perform balance rollup.
         if g_debug then
            hr_utility.set_location('hrassact.irbaact',25);
         end if;
         insert into pay_assignment_actions (
                assignment_action_id,
                assignment_id,
                payroll_action_id,
                action_status,
                chunk_number,
                action_sequence,
                object_version_number,
                tax_unit_id,
                run_type_id)
         select aa_id,
                asgid,
                pactid,
                decode(actyp, 'N', 'U', 'X', 'U', 'C'),
                1,
                aa_id,
                1,
                taxunt2,
                l_run_type_id
         from   sys.dual
         where  not exists (
                select null
                from   pay_payroll_actions    pac,
                       pay_payroll_actions    pa2,
                       pay_assignment_actions act,
                       pay_assignment_actions ac2
                 where pac.payroll_action_id = pactid
                 and   pac.action_type      <> 'I'
                 and   act.payroll_action_id = pac.payroll_action_id
                 and   act.assignment_id     = asgid
                 and   ac2.assignment_id     = act.assignment_id
                 and   pa2.payroll_action_id = ac2.payroll_action_id
                 and   pa2.action_type       = 'Z'
                 and   pa2.effective_date    > pac.effective_date);
--
         if(sql%rowcount = 0) then
            hr_utility.set_message(801,'HR_7009_ACTION_FUTURE_PURGE');
            hr_utility.raise_error;
         end if;
--
         -- If we are really getting called from purge, we do not
         -- want to perform any re-sequencing.  Purge mode is actually
         -- only set when we are creating balance initialzation actions
         -- but we DO want to contine re-sequencing when performing
         -- a "normal" initialization.
         -- When purge mode is operating, the purge process itself
         -- takes responsibility for any re-sequencing required.
         if(not pmode) then
            -- method is to loop round the selected assignment
            -- action rows, updating the action sequence.
            -- We do not attempt a correlated update, since we
            -- need to aquire and hold locks on all the rows.
            -- NOTE - the update of sequences for 'X' actions will
            -- work correctly because the seqasg cursor does not
            -- join to per_all_assignments_f.
            if g_debug then
               hr_utility.set_location('hrassact.irbaact',30);
            end if;
            if(rmode = 'Y') then
               open seqasg(pactid, asgid);
            elsif(rmode = 'N') then
               open seqper(pactid, asgid);
            else
               open seqgrp(pactid, asgid);
            end if;
--
            loop
               -- fetch the rowid and then update.
               if(rmode = 'Y') then
                  fetch seqasg into my_rowid, upd_aa_id;
                  exit when seqasg%notfound;
               elsif(rmode = 'N') then
                  fetch seqper into my_rowid, upd_aa_id;
                  exit when seqper%notfound;
               else
                  fetch seqgrp into my_rowid, upd_aa_id;
                  exit when seqgrp%notfound;
               end if;
--
               --
               -- Now, update with new action_sequence.
               update pay_assignment_actions act
               set    act.action_sequence = pay_assignment_actions_s.nextval
               where  act.rowid           = my_rowid;
--
               update pay_run_balances
                  set action_sequence = pay_assignment_actions_s.currval
                where assignment_action_id = upd_aa_id;
            end loop;
--
            --
            -- we are finished with the cursor, so we close it here.
            if(rmode = 'Y') then
               close seqasg;
            elsif(rmode = 'N') then
               close seqper;
            else
               close seqgrp;
            end if;
         end if;
      end irbaact;
--
   begin
      g_debug := hr_utility.debug_enabled;
--
      -- Start by grabbing the type of the action we are dealing with.
      select pac.action_type,
             pac.business_group_id,
             pay_assignment_actions_s.nextval
      into   actyp,
             bgid,
             aa_id
      from   pay_payroll_actions pac
      where  pac.payroll_action_id = pactid;
--
      -- Most of the action types require that we look for the legislation
      -- rule, i.e. time period dependent (i.e. UK) or time period
      -- independent (i.e. US) time periods.  However, we ignore this for
      -- E(X)tract actions, which are a special case.
      begin
        if(actyp <> 'X') then
           -- take the opportunity here to lock the assignment
           -- and period of service of the person.
           if g_debug then
              hr_utility.set_location('hrassact.inassact_main',10);
           end if;
           if (p_asg_lock) then
              -- We wish to lock the assignment and period of service.
              declare
                 posid number;
              begin
                 select /*+ ORDERED
                            INDEX (asg PER_ASSIGNMENTS_F_PK)
                            USE_NL(asg) */
                           asg.business_group_id,
                           asg.period_of_service_id
                 into   bgid, posid
                 from   pay_payroll_actions   pac,
                     per_all_assignments_f     asg
                 where  pac.payroll_action_id     = pactid
                 and    asg.assignment_id         = asgid
                 and    pac.effective_date between
                        asg.effective_start_date and asg.effective_end_date
                 for update of asg.assignment_id;

                 if posid is not null then
                    begin
                       select 1
                       into   posid
                       from   per_periods_of_service   pos
                       where  pos.period_of_service_id = posid
                       for update of pos.period_of_service_id;
                    exception
                       when no_data_found then
                          null;
                    end;
                 end if;
              end;
           end if;
           --
           if g_debug then
              hr_utility.set_location('hrassact.inassact_main',15);
           end if;
           --
           -- get the rule_mode
           select /*+ ORDERED*/ plr.rule_mode
           into   rmode
           from   per_business_groups_perf grp,
                  pay_legislation_rules plr
           where  grp.business_group_id     = bgid
           and    plr.legislation_code      = grp.legislation_code
           and    plr.rule_type             = 'I'
           and    plr.rule_mode            in ('Y','N','G');
           --
        end if;
        --
        exception
          when no_data_found then
          rmode := 'N';
      end;
--
      --
      -- Different processing, depending on the type of action.
      if(actyp = 'Q') then
         -- process QuickPay.
         -- Defferent processing depending on the rule mode.
         -- the statements below both check that the assignment
         -- is date effective for date_earned and date_paid
         -- (i.e. effective_date). This is is exactly the same
         -- as for the run.
         if(rmode = 'Y') then
            -- time period independent legislation.
            if g_debug then
               hr_utility.set_location('hrassact.inassact_main',20);
            end if;
            insert into pay_assignment_actions (
                   assignment_action_id,
                   assignment_id,
                   payroll_action_id,
                   action_status,
                   chunk_number,
                   action_sequence,
                   object_version_number,
                   tax_unit_id)
            select aa_id,
                   asgid,
                   pac.payroll_action_id,
                   'U',
                   1,
                   aa_id,
                   1,
                   hr_dynsql.get_tax_unit(asg.assignment_id,
                                          pac.effective_date)
            from
                   per_business_groups_perf pbg,
                   per_all_assignments_f asg,
                   per_all_assignments_f as2,
                   pay_payroll_actions pac
            where  pac.payroll_action_id = pactid
            and    asg.payroll_id        = pac.payroll_id
            and    asg.assignment_id     = asgid
            and    pac.effective_date between
                   asg.effective_start_date and asg.effective_end_date
            and    as2.assignment_id     = asg.assignment_id
            and    pac.date_earned between
                   as2.effective_start_date and as2.effective_end_date
            and    pbg.business_group_id = pac.business_group_id
            and    not exists (
                   select null
                   from   pay_action_classifications acl,
                          pay_payroll_actions        pa2,
                          pay_assignment_actions     ac2
                   where  ac2.assignment_id       = asg.assignment_id
                   and    pa2.payroll_action_id   = ac2.payroll_action_id
                   and    acl.classification_name = 'SEQUENCED'
                   and    pa2.action_type         = acl.action_type
                   and   (pa2.effective_date > pac.effective_date
                      or (ac2.action_status not in ('C', 'S')
                   and    pa2.effective_date <= pac.effective_date)));
         else
            -- time period dependent legislation.
            if g_debug then
               hr_utility.set_location('hrassact.inassact_main',30);
            end if;
            insert into pay_assignment_actions (
                   assignment_action_id,
                   assignment_id,
                   payroll_action_id,
                   action_status,
                   chunk_number,
                   action_sequence,
                   object_version_number,
                   tax_unit_id)
            select aa_id,
                   asgid,
                   pac.payroll_action_id,
                   'U',
                   1,
                   aa_id,
                   1,
                   hr_dynsql.get_tax_unit(asg.assignment_id,
                                          pac.effective_date)
            from   per_business_groups_perf pbg,
                   per_all_assignments_f  asg,
                   per_all_assignments_f  as2,
                   per_periods_of_service pos,
                   pay_payroll_actions    pac
            where  pac.payroll_action_id    = pactid
            and    asg.payroll_id           = pac.payroll_id
            and    asg.assignment_id        = asgid
            and    pos.period_of_service_id = asg.period_of_service_id
            and    pac.effective_date between
                   asg.effective_start_date and asg.effective_end_date
            and    as2.assignment_id        = asg.assignment_id
            and    pac.date_earned between
                   as2.effective_start_date and as2.effective_end_date
            and    pbg.business_group_id    = pac.business_group_id
            and    not exists (
                   select null
                   from   pay_action_classifications acl,
                          pay_assignment_actions     ac2,
                          pay_payroll_actions        pa2,
                          per_all_assignments_f          as2
                   where  as2.period_of_service_id = pos.period_of_service_id
                   and    ac2.assignment_id        = as2.assignment_id
                   and    pa2.payroll_action_id    = ac2.payroll_action_id
                   and    acl.classification_name  = 'SEQUENCED'
                   and    pa2.action_type          = acl.action_type
                   and    (pa2.effective_date > pac.effective_date
                       or (ac2.action_status not in ('C', 'S')
                   and    pa2.effective_date <= pac.effective_date)));
         end if;
--
         -- Check if a row was inserted.
         -- If a row was not inserted, it must mean interlock
         -- rule failure for that particular assignment.
         -- This condition is reported via an error message.
         if(sql%rowcount = 0) then
            hr_utility.set_message(801,'HR_7010_ACTION_INTLOCK_FAIL');
            hr_utility.raise_error;
         end if;
      elsif (actyp in ('V','B','N','X','I')) then
         --
         -- The following called to create assignment action for
         -- Reversal, Balance Adjustment Non Tracked, Archive and
         -- Balance Upload actions.
         -- The non tracked case is for the balance user exit.
         irbaact(pactid,asgid,rmode,actyp, p_element_entry, taxunt,
                 p_purge_mode,p_run_type_id,aa_id, p_mode);
      elsif (actyp = 'E') then
         --
         -- Insert a pay_assignment_actions record for Pre-payment
         -- External/Manual payments.
         -- Only do this if the pre-payment has not already
         -- been paid.
         -- This is detected if there is any assignment action
         -- with a pre_payment_id the same as that we are attempting
         -- to process which is not locked by a void action.
         insert into PAY_ASSIGNMENT_ACTIONS (
                ASSIGNMENT_ACTION_ID,
                ASSIGNMENT_ID,
                PAYROLL_ACTION_ID,
                ACTION_STATUS,
                CHUNK_NUMBER,
                ACTION_SEQUENCE,
                PRE_PAYMENT_ID,
                SERIAL_NUMBER,
                OBJECT_VERSION_NUMBER)
         select p_ass_action_seq,
                asgid,
                pactid,
                'C',
                1,
                PAY_ASSIGNMENT_ACTIONS_S.nextval,
                p_pre_payment_id,
                p_serial_number,
                1
         from   sys.dual
         where  not exists (
                select null
                from   pay_assignment_actions act
                where  act.pre_payment_id = p_pre_payment_id
                and not exists
                    ( select null
                      from   pay_action_interlocks loc1,
                             pay_assignment_actions actv,
                             pay_payroll_actions    pactv
                      where  loc1.locked_action_id  = act.assignment_action_id
                      and    loc1.locking_action_id = actv.assignment_action_id
                      and    pactv.payroll_action_id = actv.payroll_action_id
                      and    pactv.action_type       = 'D'
                    )
           ) ;

         --
         -- Check that a row has been inserted.
         if g_debug then
            hr_utility.set_location('hrassact.inassact_main',40);
         end if;
         if(sql%rowcount = 0) then
            hr_utility.set_message(801,'HR_7010_ACTION_INTLOCK_FAIL');
            hr_utility.raise_error;
         end if;
         --
      elsif (actyp = 'U') then
         -- Insert an assignment action for a QuickPay Pre-Payment.
         -- We perform validation of the interlock rules here.
         -- kkawol: Only return rows for master assignment action.
         --
         if g_debug then
            hr_utility.set_location('hrassact.inassact_main',45);
         end if;
         insert into PAY_ASSIGNMENT_ACTIONS (
                ASSIGNMENT_ACTION_ID,
                ASSIGNMENT_ID,
                PAYROLL_ACTION_ID,
                ACTION_STATUS,
                CHUNK_NUMBER,
                ACTION_SEQUENCE,
                OBJECT_VERSION_NUMBER,
                TAX_UNIT_ID)
         select aa_id,
                act.assignment_id,
                pac.payroll_action_id,   -- qpprepay pact.
                'U',
                1,
                aa_id,
                1,
                hr_dynsql.get_tax_unit(asg.assignment_id,
                                       pac.effective_date)
         from   per_business_groups_perf pbg,
                pay_assignment_actions act,
                pay_payroll_actions    pac,  -- prepay action.
                pay_payroll_actions    pa2,  -- the QuickPay action.
                per_periods_of_service pos,
                per_all_assignments_f      asg
         where  pac.payroll_action_id      = pactid
         and    pa2.payroll_action_id      = pac.target_payroll_action_id
         and    act.payroll_action_id      = pa2.payroll_action_id
         and    act.source_action_id is null  /* master assignment action */
         and    asg.assignment_id          = act.assignment_id
         and    pa2.effective_date between
                asg.effective_start_date and asg.effective_end_date
         and    pos.period_of_service_id   = asg.period_of_service_id
         and    pbg.business_group_id      = pac.business_group_id
         and    not exists (
                select null
                from   pay_assignment_actions ac2,
                       pay_payroll_actions    pa3,
                       pay_action_interlocks  int
                where  int.locked_action_id     = act.assignment_action_id
                and    ac2.assignment_action_id = int.locking_action_id
                and    pa3.payroll_action_id    = ac2.payroll_action_id
                and    pa3.action_type          in ('P', 'U'))
         and    not exists (
                select null
                from   per_all_assignments_f  as3,
                       pay_assignment_actions ac3
                where  rmode                 <> 'Y'
                and    ac3.payroll_action_id = pa2.payroll_action_id
                and    ac3.action_status    not in ('C', 'S')
                and    as3.assignment_id     = ac3.assignment_id
                and    pa2.effective_date between
                       as3.effective_start_date and as3.effective_end_date
                and    as3.person_id         = pos.person_id);
      else
         -- If we get here, we are attempting to process
         -- an illegal action type.
         hr_utility.set_message(801,'HR_7034_ACTION_TYP_INV_VBN');
         hr_utility.raise_error;
      end if;
--
      --
      -- update the action_population_status to indicate
      -- an action has been successfully inserted.
      if g_debug then
         hr_utility.set_location('hrassact.inassact_main',50);
      end if;

      begin
         select pac.action_population_status
         into l_action_population_status
         from pay_payroll_actions pac
         where pac.payroll_action_id = pactid;
      exception
         when others then
            l_action_population_status := 'U';
      end;

      if l_action_population_status <> 'C' then
         update pay_payroll_actions pac
         set    pac.action_population_status = 'C'
         where  pac.payroll_action_id        = pactid;
      end if;
--
      return aa_id;
--
   end inassact_main;
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
   ) is
      assactid number;
      c_indent constant varchar2(30) := 'hrassact.qpassact';
   begin
      g_debug := hr_utility.debug_enabled;
--
      -- Simply call the inassact procedure.
      if g_debug then
         hr_utility.set_location(c_indent,5);
      end if;
      inassact(p_payroll_action_id, p_assignment_id, null, null, null);
--
      -- Get the assignment_action_id
      -- that has just been inserted
      select pay_assignment_actions_s.currval
      into   assactid
      from   sys.dual;
--
      -- Return information.
      p_assignment_action_id := assactid;
      p_object_version_number := 1;
   end qpassact;
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
   ) is
      l_assignment_id     number;
      l_locking_action_id number;
      l_locked_action_id  number;
   begin
      g_debug := hr_utility.debug_enabled;
--
      -- We have to get the assignment_id
      -- of the assignment that is going
      -- to be prepaid, so it may be passed on.
      -- kkawol: query restricted to only return the assignment id
      -- of the master action.
      --
      if g_debug then
         hr_utility.set_location('hrassact.qpppassact',10);
      end if;
      select act.assignment_id
      into   l_assignment_id
      from   pay_assignment_actions act,
             pay_payroll_actions    pac
      where  pac.payroll_action_id = p_payroll_action_id
      and    act.payroll_action_id = pac.target_payroll_action_id
      and    act.source_action_id is null;
--
      -- Start by simply inserting an assignment action.
      if g_debug then
         hr_utility.set_location('hrassact.qpppassact',20);
      end if;
      hrassact.inassact(p_payroll_action_id,l_assignment_id,null,null,null);
--
      -- Get some information for insert to interlocks.
      -- kkawol: Only returning details for the master action.
      --
      if g_debug then
         hr_utility.set_location('hrassact.qpppassact',30);
      end if;
      select pay_assignment_actions_s.currval,
             act.assignment_action_id
      into   l_locking_action_id,
             l_locked_action_id
      from   pay_payroll_actions    pac,
             pay_assignment_actions act
      where  pac.payroll_action_id = p_payroll_action_id
      and    act.payroll_action_id = pac.target_payroll_action_id
      and    act.source_action_id is null;
--
      -- We can now insert interlock row.
      if g_debug then
         hr_utility.set_location('hrassact.qpppassact',40);
      end if;
      insert  into pay_action_interlocks (
              locking_action_id,
              locked_action_id)
      values (l_locking_action_id,
              l_locked_action_id);
--
      -- Update the payroll actions table with the
      -- appropriate date_earned value.
      if g_debug then
         hr_utility.set_location('hrassact.qpppassact',50);
      end if;
      update pay_payroll_actions pac
      set    pac.date_earned = (
             select pa2.date_earned
             from   pay_payroll_actions pa2,
                    pay_assignment_actions act
             where  act.assignment_action_id = l_locked_action_id
             and    pa2.payroll_action_id = act.payroll_action_id)

      where  pac.payroll_action_id =p_payroll_action_id;
--

      p_assignment_action_id := l_locking_action_id;
      p_object_version_number := 1;
--
   end qpppassact;
--
   --------------------------- reversal ------------------------------
   /*
      NAME
         reversal - Process a reversal.
      DESCRIPTION
         Process a reversal for an assignment action.
      NOTES
         - This is called directly from the Reversal form.
           This fucntion reverses all appropriate run results.
           By 'appropriate', we mean all numeric unit of measure.
           This currently leads us to negate input values such as
           'rate' and so on, as there is currently no way of telling
           the reversal not to do so. This may be altered in a
           subsequent version.
         - The redo parameter indicates whether or not we need to
           insert an assignment action and interlock. If redo is
           set true, we do not need to. This was introduced to
           cope with the requirements for BackPay.
         - The multi flag indicates if we are calling this as part of
           the assignment set reversal procedure in which case we want to
           skip the initial setup part of this procedure
   */
   procedure reversal
   (
      pactid   in number,               -- payroll_action_id.
      assactid in number,               -- assignment_action_id to be reversed.
      redo     in boolean default false, -- ins assact and interlock if false
      rev_aaid in number  default 0,    -- reversal aa id of parent assactid
      multi    in boolean default false
   ) is
  --
  -- Cursors used for latest balance maintenance
  --
  cursor rev_rrs (revassactid number, p_si_needed varchar2, p_st_needed varchar2,
                  p_sn_needed varchar2, p_st2_needed varchar2,
                  p_sn2_needed varchar2, p_org_needed varchar2) is
  select prr.run_result_id,
         paa.tax_unit_id,
         prr.local_unit_id,
         prr.jurisdiction_code,
         prr.source_id original_entry_id,
         ppa.payroll_id,
         decode(p_si_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_ID', prr.run_result_id),
              null)  source_id,
         decode(p_st_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_TEXT', prr.run_result_id),
              null)  source_text,
         decode(p_sn_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_NUMBER', prr.run_result_id),
              null)  source_number,
         decode(p_st2_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_TEXT2', prr.run_result_id),
              null)  source_text2,
         decode(p_sn2_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_NUMBER2', prr.run_result_id),
              null)  source_number2,
         decode(p_org_needed,
              'Y', pay_balance_pkg.find_context('ORGANIZATION_ID', prr.run_result_id),
              null)  organization_id,
         ppa.effective_date
    from pay_assignment_actions paa,
         pay_run_results        prr,
         pay_payroll_actions    ppa
   where paa.assignment_action_id = revassactid
     and ppa.payroll_action_id    = paa.payroll_action_id
     and paa.assignment_action_id = prr.assignment_action_id;
  --
  -- cursor and variables used in reversal of pay_run_balances
  --
    rev_asgact_id pay_assignment_actions.assignment_action_id%type;
    rev_act_seq   pay_assignment_actions.action_sequence%type;
    rev_eff_date  pay_payroll_actions.effective_date%type;
    --
      asgid number; -- assignment_id.
      taxunt number; -- tax unit id if legislation is US
      run_type_id number;
      udca      context_details;
      cxt_id number;

      found number;
      rev_assact number; -- reversal assignment_action_id.
      leg_code   per_business_groups_perf.legislation_code%type;
      l_process_path   pay_assignment_actions.process_path%type;
      l_found    boolean;
      l_inp_val_name pay_input_values_f.name%type;
      l_rev_lat_bal_maintenance boolean;
      l_rule_mode pay_legislation_rules.rule_mode%type;
      l_si_needed pay_legislation_rules.rule_mode%type;
      l_st_needed pay_legislation_rules.rule_mode%type;
      l_sn_needed pay_legislation_rules.rule_mode%type;
      l_sn2_needed pay_legislation_rules.rule_mode%type;
      l_org_needed pay_legislation_rules.rule_mode%type;
      l_st2_needed pay_legislation_rules.rule_mode%type;
      l_value     pay_action_parameters.parameter_value%type;
      l_tax_group hr_organization_information.org_information5%type;
   begin
      g_debug := hr_utility.debug_enabled;
      --
      -- To process the reversal, we need to
      -- obtain information about the assignment.
      -- Note : in addition, the following select
      -- will only return a row if the reversal
      -- effective date is equal to or later than
      -- the effective date of the assignment action
      -- being reversed, and that action is a legal
      -- action to be reversed.
      -- We also get the tax unit id (US only) which is
      -- required for the reversal assigment action.
      -- not part of assignment set reversal so perform normal logic
      begin
         if g_debug then
            hr_utility.trace('pactid: '||to_char(pactid));
            hr_utility.trace('assactid: '||to_char(assactid));
            hr_utility.set_location('hrassact.reversal',10);
         end if;
         select ac2.assignment_id,
                ac2.tax_unit_id,
                ac2.run_type_id,
                pbg.legislation_code
         into   asgid, taxunt,run_type_id, leg_code
         from   pay_action_classifications acl,
                pay_assignment_actions     ac2,
                pay_payroll_actions        pa2,
                per_business_groups_perf   pbg,
                pay_payroll_actions        pac
         where  pac.payroll_action_id    = pactid
         and    pbg.business_group_id    = pac.business_group_id
         and    ac2.assignment_action_id = assactid
         and    pa2.payroll_action_id    = ac2.payroll_action_id
         and    acl.classification_name  = 'REVERSED'
         and    acl.action_type          = pa2.action_type
         and    pa2.effective_date      <= pac.effective_date;
      exception
         when no_data_found then
            hr_utility.set_message(801,'HR_7011_ACTION_ILLEGAL_REV');
            hr_utility.raise_error;
      end;
--
     if not multi then
      -- If redo is true, we do not not need to insert
      -- either an assignment action or an interlock.
      -- the BackPay process needs this.
      if(not redo) then
         --
         -- start by inserting an assignment action row.
         hrassact.inassact_main(pactid,asgid,null,null,null,null,TRUE,taxunt,FALSE,run_type_id);
--
            hr_utility.set_location('hrassact.reversal',10);
         -- Return the Reversal's assignment_action_id
         select act.assignment_action_id
         into   rev_assact
         from   pay_assignment_actions act
         where  act.payroll_action_id = pactid
         and    act.assignment_id     = asgid;
--
         select pay_core_utils.get_process_path(assactid)
         into l_process_path
         from dual;
         -- need to set process path for reversals
         update pay_assignment_actions
         set process_path =l_process_path
         where assignment_action_id=rev_assact;

         -- insert an interlock row.
         -- Take this opportunity to do a specific check that we
         -- have not already reversed the assignment action.
         -- Do this by checking a reversal does not already lock
         -- this row.
         if g_debug then
            hr_utility.set_location('hrassact.reversal',20);
         end if;
         insert into pay_action_interlocks (
                locking_action_id,
                locked_action_id)
         select rev_assact,
                assactid
         from   dual
         where  not exists (
                select null
                from   pay_assignment_actions ac2,
                       pay_payroll_actions    pa2,
                       pay_action_interlocks  pai
                where  pai.locked_action_id     = assactid
                and    ac2.assignment_action_id = pai.locking_action_id
                and    pa2.payroll_action_id    = ac2.payroll_action_id
                and    pa2.action_type          = 'V');
--
         if(sql%rowcount = 0) then
            hr_utility.set_message(801,'HR_7013_ACTION_IS_REVERSED');
            hr_utility.raise_error;
         end if;
            hr_utility.set_location('hrassact.reversal',10);
--
        -- insert lock to master action if this is a sub action

        insert into pay_action_interlocks (
                locking_action_id,
                locked_action_id)
        select rev_assact, paa1.assignment_action_id
        from pay_assignment_actions paa,pay_assignment_actions paa1
        where paa.assignment_action_id=assactid
        and paa1.payroll_action_id=paa.payroll_action_id
        and paa1.source_action_id is null
        and paa1.assignment_id=paa.assignment_id
        and paa1.assignment_action_id<>paa.assignment_action_id;


      else
         -- Return the Reversal's assignment_action_id
         select act.assignment_action_id
         into   rev_assact
         from   pay_assignment_actions act
         where  act.payroll_action_id = pactid
         and    act.assignment_id     = asgid;

           --create new interlock if needed
           insert into pay_action_interlocks
           (locking_action_id,locked_action_id)
           select rev_assact,assactid
           from dual where not exists (select 1
                                       from pay_action_interlocks
                                       where locking_action_id=rev_assact
                                       and locked_action_id=assactid);


      end if;
     else -- multi flag
       rev_assact := rev_aaid;
     end if;
--
      --
      -- Now we need to process the reversal itself.
      -- We insert 'copies' of the run results and values
      -- from the run to be reversed, except we negate the
      -- values of result values that have numeric unit of
      -- measure. Note that there is no intelligence involved
      -- here, the routine does not know anything about
      -- what the values are being used for.
      -- Approach : select all the relevant run result
      -- rows and then insert the run result values
      -- for each one at a time.
      --
      -- Note the order by run run_result_id was introduced to
      -- ensure that the reversals results are in the same order
      -- as the reversed runs results.
      -- This slight change in behaviour will result in optimising
      -- the results of a retrocosting of a reversal.
                --
                -- Note - when the run result that is being reversed is
                -- an indirect we change the source_type of the new
                -- result to 'V' (#374389)
      declare
         cursor run_results(pactid number,assactid number) is
         select prr.run_result_id,         -- original run_result_id.
                prr.element_type_id,
                prr.entry_type,
                prr.source_id,
                decode(prr.source_type, 'I', 'V', 'R'),   -- source_type
                prr.status,       ---'P'                   -- status
                prr.jurisdiction_code,
                prr.start_date,
                prr.end_date,
                prr.time_definition_id,
                prr.entry_process_path
         from   pay_run_results        prr
         where  prr.assignment_action_id = assactid
         order by prr.run_result_id;
      --
         -- hold a run result record row.
         oldrrid   pay_run_results.run_result_id%type;
         etypid    pay_run_results.element_type_id%type;
         enttype   pay_run_results.entry_type%type;
         srcid     pay_run_results.source_id%type;
         stype     pay_run_results.source_type%type;
         stat      pay_run_results.status%type;
         v_jcode   pay_run_results.jurisdiction_code%type;
         start_date pay_run_results.start_date%type;
         end_date  pay_run_results.end_date%type;
         time_def_id  pay_run_results.time_definition_id%type;
         entrypath pay_run_results.entry_process_path%type;
--
         -- format mask for result value
         mask_38_dec_places varchar2(100);
         l_src_iv    varchar2(30);
         l_src_num   varchar2(30);
         l_src_num2  varchar2(30);
         l_org_id_iv varchar2(30);
         l_iv_found  boolean;
         l_num_found boolean;
      begin

         -- intialise mask for a number with 35 decimal places
         -- fnd_number.number_to_canonical uses a mask with only 20 decimal places
         -- bug 2362454
         -- increased to 38 decimal places and redelieverd under bug 2587443
         mask_38_dec_places := 'FM999999999999999999999.99999999999999999999999999999999999999';
                                --123456789012345678901 12345678901234567890123456789012345678

         --
         -- open the cursor.
         open run_results(pactid,assactid);
--
         loop
            fetch run_results
            into oldrrid,etypid,enttype,srcid,stype,stat,v_jcode, start_date, end_date, time_def_id, entrypath;
--
            exit when run_results%notfound;
--
            -- we want to know if element type is
            -- date effective for Reversal Date.
            declare
               dummy number; -- need this for syntax.
            begin
               if g_debug then
                  hr_utility.set_location('hrassact.reversal',25);
               end if;
               select 1
               into   dummy
               from   pay_payroll_actions pac,
                      pay_element_types_f pet
               where  pac.payroll_action_id = pactid
               and    pet.element_type_id   = etypid
               and    pac.effective_date between
                      pet.effective_start_date and pet.effective_end_date;
               exception
                  when no_data_found then
                  hr_utility.set_message(801,'HR_7012_ACTION_ELE_NOT_EFF');
                  hr_utility.raise_error;
            end;
--
            if g_debug then
               hr_utility.set_location('hrassact.reversal',30);
            end if;

            insert  into pay_run_results (
                    run_result_id,
                    element_type_id,
                    assignment_action_id,
                    entry_type,
                    source_id,
                    source_type,
                    status,
                    jurisdiction_code,
                    start_date,
                    end_date,
                    time_definition_id,
                    entry_process_path)
            values (pay_run_results_s.nextval,
                    etypid,
                    rev_assact, -- the reversal assignment action.
                    enttype,
                    oldrrid,
                    stype,
                    stat,
                    v_jcode,
                    start_date,
                    end_date,
                    time_def_id,
                    entrypath);
--
            -- now we need to insert the result values
            -- for the result just inserted.
            -- NOTE - the first line in the decode is a
            -- dummy statement that prevents invalid
            -- number errors, caused by attempted
            -- implicit conversions from characters to
            -- numbers.
            --
            -- Bug 2822429 - Input values that represent the context SOURCE_ID
            -- or SOURCE_NUMBER must not have their run_result_value negated,
            -- as they are ids, not number values. Hence, where uom is I or N
            -- an extra decode is performed. If the piv.name is the SOURCE_ID
            -- or SOURCE_NUMBER input value, then multiply by 1, otherwise by
            -- -1 as before.
            -- Need to get input_value name for SOURCE_ID and SOURCE_NUMBER
            --
            hr_utility.trace('leg_code: '||leg_code);
            pay_core_utils.get_leg_context_iv_name('SOURCE_ID'
                                               ,leg_code
                                               ,l_src_iv
                                               ,l_iv_found);
            if (not l_iv_found) then
               l_src_iv := null;
            else
              l_si_needed := 'Y';
              hr_utility.trace('l_src_iv: '||l_src_iv);
            end if;
            --
            pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER'
                                               ,leg_code
                                               ,l_src_num
                                               ,l_num_found);
            if (not l_num_found) then
               l_src_num := null;
            else
               l_sn_needed := 'Y';
               hr_utility.trace('l_src_num: '||l_src_num);
            end if;
            --
            pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER2'
                                               ,leg_code
                                               ,l_src_num2
                                               ,l_num_found);
            if (not l_num_found) then
               l_src_num2 := null;
            else
               l_sn2_needed := 'Y';
               hr_utility.trace('l_src_num2: '||l_src_num2);
            end if;
--
            pay_core_utils.get_leg_context_iv_name('ORGANIZATION_ID'
                                               ,leg_code
                                               ,l_org_id_iv
                                               ,l_num_found);
            if (not l_num_found) then
               l_org_id_iv := null;
            else
               l_org_needed := 'Y';
               hr_utility.trace('l_org_id_iv: '||l_org_id_iv);
            end if;
            --
            if g_debug then
               hr_utility.set_location('hrassact.reversal',35);
            end if;
            insert into pay_run_result_values (
                   input_value_id,
                   run_result_id,
                   result_value)
            select piv.input_value_id,
                   pay_run_results_s.currval,
                   decode(piv.uom,
                      'XXXXXXXXXX', '***********************',
                      'H_DECIMAL1', rtrim(to_char((-1) * to_number(rrv.result_value, mask_38_dec_places), mask_38_dec_places), '.'),
                      'H_DECIMAL2', rtrim(to_char((-1) * to_number(rrv.result_value, mask_38_dec_places), mask_38_dec_places), '.'),
                      'H_DECIMAL3', rtrim(to_char((-1) * to_number(rrv.result_value, mask_38_dec_places), mask_38_dec_places), '.'),
                      'H_HH'      , rtrim(to_char((-1) * to_number(rrv.result_value, mask_38_dec_places), mask_38_dec_places), '.'),
                      'H_HHMM'    , rtrim(to_char((-1) * to_number(rrv.result_value, mask_38_dec_places), mask_38_dec_places), '.'),
                      'H_HHMMSS'  , rtrim(to_char((-1) * to_number(rrv.result_value, mask_38_dec_places), mask_38_dec_places), '.'),
                      'I' , rtrim(to_char(decode(piv.name, l_src_iv , (1)
                                                         , l_src_num, (1)
                                                         , l_src_num2, (1)
                                                         , l_org_id_iv, (1)
                                                         , (-1))
                            * to_number(rrv.result_value, mask_38_dec_places)
                            , mask_38_dec_places), '.'),
                      'M'         , rtrim(to_char((-1) * to_number(rrv.result_value, mask_38_dec_places), mask_38_dec_places), '.'),
                      'N' , rtrim(to_char(decode(piv.name, l_src_iv , (1)
                                                         , l_src_num, (1)
                                                         , l_src_num2, (1)
                                                         , l_org_id_iv, (1)
                                                         , (-1))
                            * to_number(rrv.result_value, mask_38_dec_places)
                              , mask_38_dec_places), '.'),
                      'ND'        , rtrim(to_char((-1) * to_number(rrv.result_value, mask_38_dec_places), mask_38_dec_places), '.'),
                      rrv.result_value)
            from   pay_payroll_actions   pac,
                   pay_run_result_values rrv,
                   pay_input_values_f    piv
            where  pac.payroll_action_id = pactid
            and    rrv.run_result_id     = oldrrid
            and    piv.input_value_id    = rrv.input_value_id
            and    pac.effective_date between
                   piv.effective_start_date and piv.effective_end_date;
         end loop;
--
         close run_results;
--
         -- Now setup the action contexts, if there are any
        -- if not multi then
         insert into pay_action_contexts
                   (ASSIGNMENT_ACTION_ID,
                    ASSIGNMENT_ID,
                    CONTEXT_ID,
                    CONTEXT_VALUE)
         select distinct rev_assact,
                pac.assignment_id,
                pac.context_id,
                pac.context_value
           from pay_action_contexts pac
          where pac.assignment_action_id = assactid;
        -- end if;
--
         -- Added for fix 366215.
         -- Now we have inserted the negative run results for
         -- the Reversal itself, we call a procedure to create
         -- "pre-inserted" run results and values to allow the
         -- correct re-processing of element entries in a
         -- subsequent run.
         --hrassact.rev_pre_inserted_rr(pactid);
         --
         -- To signal that processing has been successfully
         -- completed, update the action_status to (C)omplete.
         hr_utility.set_location('hrassact.reversal',40);
         update pay_payroll_actions pac
         set    pac.action_status     = 'C'
         where  pac.payroll_action_id = pactid;
      end;
--
--
-- Now do the reversal for pay_run_balances. 1st the asg level balances
--
      if g_debug then
         hr_utility.set_location('hrassact.reversal',45);
      end if;
--
   /* currently for multi reversal we are using pactid as the reversal
      pactid. If multi then the ass_act_id is the rev_act_id we want to
      use and is already set */
   if not multi then

   select paa.assignment_action_id
   ,      paa.action_sequence
   ,      ppa.effective_date
   into   rev_asgact_id
   ,      rev_act_seq
   ,      rev_eff_date
   from   pay_assignment_actions paa
   ,      pay_payroll_actions ppa
   where  paa.payroll_action_id = pactid
   and    paa.payroll_action_id = ppa.payroll_action_id;

   else

   select paa.assignment_action_id
   ,      paa.action_sequence
   ,      ppa.effective_date
   into   rev_asgact_id
   ,      rev_act_seq
   ,      rev_eff_date
   from   pay_assignment_actions paa,
          pay_payroll_actions ppa
   where  paa.assignment_action_id = assactid
   and    ppa.payroll_action_id = paa.payroll_action_id;

   end if;
--
   pay_balance_pkg.maintain_balances_for_action(rev_assact);
--
   if g_debug then
      hr_utility.set_location('Leaving: hrassact.reversal', 100);
   end if;
end reversal;
--
   ----------------- multi_assignment_reversal ------------------------------
   /*
      NAME
         multi_assignment_reversal - Process a reversal by assignment set.
      DESCRIPTION
         Process a reversal for an assignment action, version called via PYUGEN
         as opposed to that called via Reversal Form version.
         This version omits the assignment action creation that has been already
         prepared via the c code routines called as part of PYUGEN prior.
      NOTES
         - This is called directly from PYUGEN REVERSAL

      BUG 7652030 - pay_balance_pkg.create_all_group_balances was getting called
      during reversal of all assignments causing errors
      Now calling create_all_group_balances after the last reversal .
   */
procedure multi_assignment_reversal
(
   pactid   in number,               -- payroll_action_id.
   assactid in number,               -- assignment_action_id to be reversed.
   rev_aaid in number                -- locking action
) is
begin

hrassact.gv_multi_reversal := TRUE;

If hrassact.gv_cnt_reversal_act_id is null then

    SELECT count(*)
    INTO   hrassact.gv_cnt_reversal_act_id
    FROM   pay_action_interlocks pai,
           pay_assignment_actions paa
    WHERE  paa.payroll_action_id = pactid
    AND    paa.assignment_action_id = pai.locking_action_id;
end if;

  reversal(pactid,        -- call reversal with PYUGEN payroll_action_id
           assactid,      -- call reversal with PYUGEN assignment action id
           false,         -- redo flag set to false for reversal thru PYUGEN
           rev_aaid,      -- locking action id
           true           -- multi flag to indicate assignment set reversal
          );

hrassact.gv_cnt_reversal_act_id := hrassact.gv_cnt_reversal_act_id - 1 ;

If hrassact.gv_cnt_reversal_act_id = 0 then
   pay_balance_pkg.create_all_group_balances(pactid,
                                             'ALL',
                                             'NORMAL',
                                             NULL,
                                             NULL);
End if;

end multi_assignment_reversal;
--
   ----------------------- rev_pre_inserted_rr --------------------------
   /* COMMENETED OUT AS THIS PROC IS NO LONGER USED
      NAME
         rev_pre_inserted_rr - Reversal create pre-inserted run results.
      DESCRIPTION
         Creates pre-inserted run results when a Reversal is processed
         These are created for any non-recurring or additional entry
         type for the assignment, where there is not already an
         unprocessed entry.
      NOTES
         <none>
   */
/*   procedure rev_pre_inserted_rr
   (
      p_payroll_action_id in number    -- payroll_action_id of reversal.
   ) is
      cursor c1 is
      select + ORDERED
                 INDEX(PEE PAY_ELEMENT_ENTRIES_F_PK,
                       PEL PAY_ELEMENT_LINKS_F_PK,
                       PET PAY_ELEMENT_TYPES_F_PK,
                       ACT2 PAY_ASSIGNMENT_ACTIONS_PK)
                 USE_NL(PAC ACT PAI ACT2 RR2 PEE)
             pet.element_type_id,
             act.assignment_action_id,
             pee.entry_type,
             pee.element_entry_id
       from  pay_payroll_actions        pac,
             pay_assignment_actions    act,
             pay_action_interlocks      pai,
             pay_assignment_actions    act2,
             pay_run_results            rr2,
             pay_element_entries_f      pee,
             pay_element_links_f        pel,
             pay_element_types_f        pet
      where  pac.payroll_action_id = p_payroll_action_id
      and    act.payroll_action_id = pac.payroll_action_id
      and    pee.assignment_id     = act.assignment_id
      and    pai.locking_action_id = act.assignment_action_id
      and    pai.locked_action_id  = act2.assignment_action_id
      and    pac.date_earned between
             pee.effective_start_date and pee.effective_end_date
      and    pel.element_link_id   = pee.element_link_id
      and    pac.date_earned between
             pel.effective_start_date and pel.effective_end_date
      and    pet.element_type_id   = pel.element_type_id
      and    pac.date_earned between
             pet.effective_start_date and pet.effective_end_date
      and    ((pet.processing_type = 'N' and pee.entry_type <> 'B')
               or pee.entry_type = 'D')
      and    rr2.source_id            = pee.element_entry_id
      and    rr2.source_type  <> 'I'-- exclude indirects
      and    rr2.assignment_action_id = act2.assignment_action_id
      and    rr2.status               <> 'U'
      and    not exists (
             select null
             from   pay_run_results rr3
             where  rr3.source_id = pee.element_entry_id
             and    rr3.status    = 'U')
      order by pee.element_entry_id;
--
      c_indent constant varchar2(30) := 'hrassact.rev_pre_inserted_rr';
   begin
      g_debug := hr_utility.debug_enabled;
      -- Insert un-processed run results and values as appropriate
      if g_debug then
         hr_utility.set_location(c_indent, 10);
      end if;
      for c1rec in c1 loop
         -- Start with insertion of run result.
         insert  into pay_run_results (
                 run_result_id,
                 element_type_id,
                 assignment_action_id,
                 entry_type,
                 source_id,
                 source_type,
                 status,
                 jurisdiction_code)
         values (pay_run_results_s.nextval,
                 c1rec.element_type_id,
                 c1rec.assignment_action_id,
                 c1rec.entry_type,
                 c1rec.element_entry_id,
                 'E',
                 'U',
                 null);
--
         -- Now, insert the appropriate run result values.
         -- All the values should be null, the Payroll Run
         -- will fill these in later.
         insert into pay_run_result_values (
                input_value_id,
                run_result_id,
                result_value)
         select pev.input_value_id,
                pay_run_results_s.currval,
                null
         from   pay_payroll_actions        pac,
                pay_assignment_actions     act,   -- reversal
                pay_element_entry_values_f pev
         where  act.assignment_action_id = c1rec.assignment_action_id --rev
         and    act.payroll_action_id   = pac.payroll_action_id
         and    pev.element_entry_id  = c1rec.element_entry_id
         and    pac.date_earned between
                pev.effective_start_date and pev.effective_end_date;
      end loop;
   end rev_pre_inserted_rr;
*/
   -------------------------- ext_man_payment --------------------------
   /*
      NAME
         ext_man_payment - Performs External/Manual Payments
      DESCRIPTION
         Process a External/Manual Payment.
      NOTES
         This is called directly from the Pre-Payment External/Manual
         Payment form.
   */
   procedure ext_man_payment
   (
      p_payroll_id           in number,
      p_eff_date             in date,
      p_assignment_action_id in number,
      p_assignment_id        in number,
      p_comments             in varchar2,
      p_serial_number        in varchar2,
      p_pre_payment_id       in number,
      p_reason               in varchar2 default null
   ) is
      c_indent constant varchar2(30) := 'hrassact.ext_man_payment';
      l_payroll_action_id    number;
      l_assignment_action_id number;
      l_business_group_id    number;
      l_consolidation_set_id number;
     --
      cursor C_CON1 is
       select pay_payroll_actions_s.nextval,
              pay_assignment_actions_s.nextval,
              pa.CONSOLIDATION_SET_ID,
              pa.BUSINESS_GROUP_ID
       from   PAY_ASSIGNMENT_ACTIONS paa,
              PAY_PAYROLL_ACTIONS pa
       where  paa.ASSIGNMENT_ACTION_ID = p_assignment_action_id
       and    paa.PAYROLL_ACTION_ID    = pa.PAYROLL_ACTION_ID;
     --
   begin
     g_debug := hr_utility.debug_enabled;
     --
     -- Open the cursor and retrieve the payroll action details
     if g_debug then
        hr_utility.set_location(c_indent,5);
     end if;
     open C_CON1;
     fetch C_CON1 into l_payroll_action_id,
                       l_assignment_action_id,
                       l_consolidation_set_id,
                       l_business_group_id;
     close C_CON1;
     --
     -- insert the payroll action row
     if g_debug then
        hr_utility.set_location(c_indent,10);
     end if;
     insert into PAY_PAYROLL_ACTIONS
             (PAYROLL_ACTION_ID,
              ACTION_TYPE,
              BUSINESS_GROUP_ID,
              CONSOLIDATION_SET_ID,
              PAYROLL_ID,
              ACTION_POPULATION_STATUS,
              ACTION_STATUS,
              EFFECTIVE_DATE,
              COMMENTS,
              OBJECT_VERSION_NUMBER,
              PAY_ADVICE_MESSAGE)
         values
             (l_payroll_action_id,
              'E',
              l_business_group_id,
              l_consolidation_set_id,
              p_payroll_id,
              'C',
              'C',
              p_eff_date,
              p_comments,
              1,
              p_reason);
     --
     -- call procedure to insert assignment action record
     if g_debug then
        hr_utility.set_location(c_indent,20);
     end if;
     inassact(pactid           => l_payroll_action_id,
              asgid            => p_assignment_id,
              p_ass_action_seq => l_assignment_action_id,
              p_pre_payment_id => p_pre_payment_id,
              p_serial_number  => p_serial_number);
     --
     -- insert a pay action interlock record.
     if g_debug then
        hr_utility.set_location(c_indent,30);
     end if;
     insert into PAY_ACTION_INTERLOCKS
             (LOCKING_ACTION_ID,
              LOCKED_ACTION_ID)
     values
             (l_assignment_action_id,
              p_assignment_action_id);
--
     -- Update the payroll action table with
     -- the appropriate date earned value.
     if g_debug then
        hr_utility.set_location(c_indent,40);
     end if;
     update pay_payroll_actions pac
        set    pac.date_earned = (
               select pa2.date_earned
               from   pay_payroll_actions    pa2,
                      pay_assignment_actions act
               where  act.assignment_action_id = p_assignment_action_id
               and    pa2.payroll_action_id    = act.payroll_action_id
)
        where  pac.payroll_action_id      = l_payroll_action_id;
--
   end ext_man_payment;
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
      p_errmsg               OUT NOCOPY VARCHAR2,
      p_errcode              OUT NOCOPY NUMBER,
      p_payroll_id           in number, -- payroll id of assign
      p_eff_date             in varchar2,   -- session date
      p_assignment_action_id in number, -- pre-payment assign action
      p_assignment_id        in number, -- assign id
      p_comments             in varchar2,-- comments
      p_serial_number        in varchar2,-- serial number
      p_pre_payment_id       in number,   -- pre-payment id
      p_reason               in varchar2 default null -- Reason
   )
   IS
   c_indent constant varchar2(30) := 'hrassact.ext_man_payment2';

   BEGIN

    g_debug := hr_utility.debug_enabled;

    if g_debug then
        hr_utility.set_location('Entering '||c_indent,10);
    end if;

     ext_man_payment(p_payroll_id,
                     TRUNC(FND_DATE.canonical_to_date(P_EFF_DATE)),
                     p_assignment_action_id,
                     p_assignment_id,
                     p_comments,
                     p_serial_number,
                     p_pre_payment_id,
                     p_reason);

    if g_debug then
        hr_utility.set_location('Leaving '||c_indent,20);
    end if;

   END ext_man_payment;
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
                             )
is
--
cursor get_rr_values (p_run_result_id  number,
                      p_effective_date date
                     )
is
select piv.name,
       prrv.result_value,
       prrv.input_value_id,
       prrv.run_result_id
  from pay_run_results       prr,
       pay_run_result_values prrv,
       pay_input_values_f    piv
 where prr.run_result_id  = p_run_result_id
   and prrv.run_result_id = prr.run_result_id
   and piv.input_value_id = prrv.input_value_id
   and p_effective_date between piv.effective_start_date
                            and piv.effective_end_date;
--
cxt_id number;
cnt    number;
pay_id number;
source_iv pay_legislation_rules.rule_type%type;
source_text_iv pay_legislation_rules.rule_type%type;
jurisdiction_iv pay_legislation_rules.rule_type%type;
action_contexts boolean;
l_def_jur_str        varchar2(2000);  -- used with dynamic pl/sql
l_ctx_balance_date   date;
l_ctx_time_def_id    number;
sql_cursor           integer;
l_rows               integer;
dummy number;
l_found              boolean;
l_action_type        varchar2(30);
l_effective_date     date;
      c_indent constant varchar2(32) := 'hrassact.set_action_context';
--
begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location(c_indent,10);
   end if;
   udca.sz := 0;
   pay_core_utils.get_dynamic_contexts(p_busgrp,
                                       g_dynamic_contexts);
--
   --
   -- Get Payroll ID and Action Type
   --
   select
      pac.payroll_id
     ,pac.action_type
     ,pac.effective_date
   into
      pay_id
     ,l_action_type
     ,l_effective_date
   from
      pay_payroll_actions pac
     ,pay_assignment_actions aa
   where
       aa.assignment_action_id = p_assact
   and pac.payroll_action_id = aa.payroll_action_id;

   --
   -- Do we need to perform the ACTION_CONTEXT code
   --
   begin
--
      if g_debug then
         hr_utility.set_location(c_indent,20);
      end if;
      select 1
        into dummy
        from pay_legislation_rules plr
       where p_legcode = plr.legislation_code
         and plr.rule_type = 'ACTION_CONTEXTS'
         and plr.rule_mode = 'Y';
--
      if g_debug then
         hr_utility.set_location(c_indent,30);
      end if;
      action_contexts := TRUE;
--
   exception
      when no_data_found then
        hr_utility.set_location(c_indent,40);
        action_contexts := FALSE;
   end;
--
     if g_debug then
        hr_utility.set_location(c_indent,50);
     end if;
     --
     -- OK get the contexts cached
     --
     if not contexts_cached then
       cache_contexts;
     end if;
     --
     -- Start setting up the contexts.
     --
     if (p_tax_unit is not null) then
        get_cache_context('TAX_UNIT_ID', cxt_id);
        udca.sz := udca.sz + 1;
        udca.assact_id(udca.sz) := p_assact;
        udca.asg_id(udca.sz)    := p_asgid;
        udca.cxt_id(udca.sz)    := cxt_id;
        udca.cxt_name(udca.sz)  := 'TAX_UNIT_ID';
        udca.cxt_value(udca.sz) := p_tax_unit;
        udca.valid(udca.sz)     := TRUE;
     end if;
     --
     -- Setting up the Balance Date and Time Definition ID contexts.
     --
     if p_rrid is not null then
        select end_date,
               time_definition_id
          into l_ctx_balance_date,
               l_ctx_time_def_id
          from pay_run_results
         where run_result_id = p_rrid;
--
        if l_ctx_balance_date is not null then
           get_cache_context('BALANCE_DATE', cxt_id);
           udca.sz := udca.sz + 1;
           udca.assact_id(udca.sz) := p_assact;
           udca.asg_id(udca.sz)    := p_asgid;
           udca.cxt_id(udca.sz)    := cxt_id;
           udca.cxt_name(udca.sz)  := 'BALANCE_DATE';
           udca.cxt_value(udca.sz) := fnd_date.date_to_canonical(l_ctx_balance_date);
           udca.valid(udca.sz)     := TRUE;
        end if;
--
        if l_ctx_time_def_id is not null then
           get_cache_context('TIME_DEFINITION_ID', cxt_id);
           udca.sz := udca.sz + 1;
           udca.assact_id(udca.sz) := p_assact;
           udca.asg_id(udca.sz)    := p_asgid;
           udca.cxt_id(udca.sz)    := cxt_id;
           udca.cxt_name(udca.sz)  := 'TIME_DEFINITION_ID';
           udca.cxt_value(udca.sz) := l_ctx_time_def_id;
           udca.valid(udca.sz)     := TRUE;
        end if;
--
     end if;
--
     for rrvrec in get_rr_values (p_rrid, l_effective_date) loop
       for l_cnt in 1..g_dynamic_contexts.count loop
--
        hr_utility.set_location(c_indent,90);
--
        --Run Result Contexts
        if (rrvrec.name = g_dynamic_contexts(l_cnt).input_value_name) then
--
         hr_utility.set_location(c_indent,95);
         declare
          l_ctx_value pay_run_result_values.result_value%type;
         begin
          l_ctx_value := null;
--
          if (rrvrec.result_value is not null) then
--
            l_ctx_value := rrvrec.result_value;

          elsif l_action_type <> 'I' then
--
            --
            -- setup defaults of contexts if not Balance Initialization
            --
            if g_dynamic_contexts(l_cnt).is_context_def = TRUE then

               l_def_jur_str := 'begin ' || g_dynamic_contexts(l_cnt).default_plsql || ' (';
               l_def_jur_str := l_def_jur_str || ':p_assact, ';
               l_def_jur_str := l_def_jur_str || ':p_entry, ';
               l_def_jur_str := l_def_jur_str || ':l_ctx_value); end; ';
               --
               sql_cursor := dbms_sql.open_cursor;
               --
               dbms_sql.parse(sql_cursor, l_def_jur_str, dbms_sql.v7);
               --
               --
               dbms_sql.bind_variable(sql_cursor, 'p_assact', p_assact);
               --
               dbms_sql.bind_variable(sql_cursor, 'p_entry', p_entry);
               --
               dbms_sql.bind_variable(sql_cursor, 'l_ctx_value', l_ctx_value, 30);
               --
               l_rows := dbms_sql.execute (sql_cursor);
               --
               if (l_rows = 1) then
                  dbms_sql.variable_value(sql_cursor, 'l_ctx_value',
                                          l_ctx_value);
                  dbms_sql.close_cursor(sql_cursor);
--
                  -- OK we got the default, we need to set it
                  update pay_run_result_values
                     set result_value = l_ctx_value
                   where run_result_id = rrvrec.run_result_id
                     and input_value_id = rrvrec.input_value_id;
--
               else
                  l_ctx_value := null;
                  dbms_sql.close_cursor(sql_cursor);
               end if;
            end if;
--
          end if;

          hr_utility.set_location(c_indent,96);
--
          if l_ctx_value is not null then
--
            -- Set the jurisdiction on the run_result.
            if (g_dynamic_contexts(l_cnt).context_name = 'JURISDICTION_CODE') then
              update pay_run_results
              set jurisdiction_code      = l_ctx_value
              where run_result_id          = p_rrid;
--
            elsif (g_dynamic_contexts(l_cnt).context_name = 'ORGANIZATION_ID') then
--
              -- Need to ensure that its a Third Party Organization
--
                  declare
                     l_org_id number;
                  begin
                     select organization_id
                       into l_org_id
                       from hr_organization_information hoi
                      where hoi.organization_id = l_ctx_value
                        and hoi.org_information_context = 'CLASS'
                        and hoi.org_information1 = 'HR_PAYEE';

                  exception
                     when no_data_found then
                       pay_core_utils.assert_condition('set_action_context:1',
                                            1 = 2);
                  end;
            end if;
--
            if g_debug then
               hr_utility.set_location(c_indent,100);
            end if;
            get_cache_context(g_dynamic_contexts(l_cnt).context_name, cxt_id);
            udca.sz := udca.sz + 1;
            udca.assact_id(udca.sz) := p_assact;
            udca.asg_id(udca.sz)    := p_asgid;
            udca.cxt_name(udca.sz)  := g_dynamic_contexts(l_cnt).context_name;
            udca.cxt_id(udca.sz)    := cxt_id;
            udca.cxt_value(udca.sz) := l_ctx_value;
            udca.valid(udca.sz)     := TRUE;
          end if;
         end;
         if g_debug then
           hr_utility.set_location(c_indent,105);
         end if;
--
        end if;
        if g_debug then
           hr_utility.set_location(c_indent,106);
        end if;
       end loop;
     end loop;

     --
     --   Payroll ID
     --
     if g_debug then
        hr_utility.set_location(c_indent,130);
     end if;
     get_cache_context('PAYROLL_ID', cxt_id);
     udca.sz := udca.sz + 1;
     udca.assact_id(udca.sz) := p_assact;
     udca.asg_id(udca.sz)    := p_asgid;
     udca.cxt_name(udca.sz)  := 'PAYROLL_ID';
     udca.cxt_id(udca.sz)    := cxt_id;
     udca.cxt_value(udca.sz) := pay_id;
     udca.valid(udca.sz)     := TRUE;

     --
     --   Original Entry ID
     --
     if p_oentry is not null then
       if g_debug then
          hr_utility.set_location(c_indent,135);
       end if;

       get_cache_context('ORIGINAL_ENTRY_ID', cxt_id);
       udca.sz := udca.sz + 1;
       udca.assact_id(udca.sz) := p_assact;
       udca.asg_id(udca.sz)    := p_asgid;
       udca.cxt_name(udca.sz)  := 'ORIGINAL_ENTRY_ID';
       udca.cxt_id(udca.sz)    := cxt_id;
       udca.cxt_value(udca.sz) := p_oentry;
       udca.valid(udca.sz)     := TRUE;

     end if;
     --
     --   Local Unit ID
     --
     declare
        l_local_unit_id number;
     begin
        select local_unit_id
          into l_local_unit_id
          from pay_run_results
         where run_result_id = p_rrid;
--
        if l_local_unit_id is not null then
          if g_debug then
             hr_utility.set_location(c_indent,136);
          end if;

          get_cache_context('LOCAL_UNIT_ID', cxt_id);
          udca.sz := udca.sz + 1;
          udca.assact_id(udca.sz) := p_assact;
          udca.asg_id(udca.sz)    := p_asgid;
          udca.cxt_name(udca.sz)  := 'LOCAL_UNIT_ID';
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_value(udca.sz) := l_local_unit_id;
          udca.valid(udca.sz)     := TRUE;

        end if;
     end;
--
     if (p_legcode = 'US' or p_legcode = 'CA') then
--
       if g_debug then
          hr_utility.set_location(c_indent,140);
       end if;
       declare
       tax_group hr_organization_information.org_information5%type;
       asg_id    number;
       pay_id    number;
       begin
--
        if (p_legcode = 'US') then
         if g_debug then
            hr_utility.set_location(c_indent,150);
         end if;
         select hoi.org_information5,
                paa.assignment_id
           into tax_group,
                asg_id
           from hr_organization_information hoi,
                pay_assignment_actions      paa
          where UPPER(hoi.org_information_context) = 'FEDERAL TAX RULES'
            and hoi.organization_id = paa.tax_unit_id
            and paa.assignment_action_id = p_assact
            and hoi.org_information5 is not null;
        else
         if g_debug then
            hr_utility.set_location(c_indent,153);
         end if;
         select hoi.org_information4,
                paa.assignment_id
           into tax_group,
                asg_id
           from hr_organization_information hoi,
                pay_assignment_actions      paa
          where UPPER(hoi.org_information_context) = 'CANADA EMPLOYER IDENTIFICATION'
            and hoi.organization_id = paa.tax_unit_id
            and paa.assignment_action_id = p_assact
            and hoi.org_information4 is not null;
         end if;
--
          if g_debug then
             hr_utility.set_location(c_indent,155);
          end if;
          get_cache_context('TAX_GROUP', cxt_id);
          udca.sz := udca.sz + 1;
          udca.assact_id(udca.sz) := p_assact;
          udca.asg_id(udca.sz)    := asg_id;
          udca.cxt_name(udca.sz)  := 'TAX_GROUP';
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_value(udca.sz) := tax_group;
          udca.valid(udca.sz)     := TRUE;
--
       exception
          when no_data_found then
             if g_debug then
                hr_utility.set_location(c_indent,160);
             end if;
             null;
       end;
--
     end if;
--
     if g_debug then
        hr_utility.set_location(c_indent,170);
     end if;
     -- Now do all the inserts.
   if action_contexts = TRUE then
     for cnt in 1..udca.sz loop
--
        if (udca.cxt_name(cnt) in ('SOURCE_ID'
                                  ,'JURISDICTION_CODE'
                                  ,'SOURCE_TEXT'
                                  ,'SOURCE_NUMBER'
                                  ,'SOURCE_TEXT2'
                                  ,'BALANCE_DATE'
                                  ,'TIME_DEFINITION_ID'
                                  ,'TAX_GROUP'
                                  ,'ORIGINAL_ENTRY_ID')) then
          if g_debug then
             hr_utility.set_location(c_indent,180);
          end if;
--
          -- The row could already be in the table due
          -- to batch balance adjustments
          --
            insert into pay_action_contexts
                           (assignment_action_id,
                            assignment_id,
                            context_id,
                            context_value)
            select udca.assact_id(cnt),
                   udca.asg_id(cnt),
                   udca.cxt_id(cnt),
                   udca.cxt_value(cnt)
              from sys.dual
             where not exists (select ''
                                 from pay_action_contexts
                                where assignment_action_id = udca.assact_id(cnt)
                                  and assignment_id = udca.asg_id(cnt)
                                  and context_id = udca.cxt_id(cnt)
                                  and context_value = udca.cxt_value(cnt));
        end if;
--
     end loop;
   end if;
   if g_debug then
      hr_utility.set_location(c_indent,190);
   end if;
exception
    when others then
      hr_utility.trace(sqlerrm);
      raise;
--
end set_action_context;
--
   --------------------------- bal_adjust_actions ----------------------
   /*
      NAME
         bal_adjust_actions - perform balance adjustment.
      DESCRIPTION
         Process a balance adjustment.
      NOTES
   */
   procedure bal_adjust_actions
   (
      consetid in number,              -- consolidation_set_id.
      eentryid in number,              -- element_entry_id.
      effdate  in date,                -- effective_date of bal adjust.
      pyactid out nocopy number,              -- payroll action id.
      asactid out nocopy number,              -- assignment action id.
      act_type in varchar2 default 'B',-- payroll_action_type.
      prepay_flag in varchar2 default null, -- include in prepay process?
      taxunit  in number default null, -- tax unit id.
      purge_mode in boolean default false,  -- are we calling in purge mode?
      run_type_id in number default null
   ) is
      c_indent constant varchar2(32) := 'hrassact.bal_adjust_actions';
      pactid    number;  -- payroll_action_id.
      busgrp    number;  -- business_group_id.
      legcode   pay_legislation_rules.legislation_code%TYPE; -- leg code
      asgid     number;  -- assignment_id.
      payid     number;  -- payroll_id.
      tperiod   number;  -- time_period_id.
      dtearned  date;    -- date_earned.
      creatby   number;  -- created_by.
      creatdate date;    -- creation_date.
      assactid  number;  -- assignment_action_id of inserted action.
      tax_unit  number;  -- tax_unit_id
      udca      context_details;
      l_run_result_id         number;
      l_jc_name               varchar2(30);
      l_rr_sparse             boolean;
      l_rr_sparse_jc          boolean;
      l_found boolean;
      l_rule_mode varchar2(30);
      l_status    varchar2(30);
      l_original_entry_id     number;
      l_dummy varchar2(1);
--
      cursor csr_time_period_leg (p_leg_code in varchar2) is
         select 'Y'
           from pay_legislation_rules
          where rule_type = 'TIME_PERIOD_ID'
            and legislation_code = p_leg_code
            and rule_mode = 'Y';
--
   begin
      g_debug := hr_utility.debug_enabled;
      --
      --
      -- Select a number of values, including assignment
      -- and payroll action details.
      -- take this opportunity to check that the assignment
      -- and element type is date effective. In the case of
      -- the assignment, this should be confirming what has
      -- already been checked by the form.
      -- In addition, select a sequence value for
      -- pay_run_results.
      --
      -- Bug #3482270 - original entry id support.
      -- Original_entry_id will be also derived from the entry
      -- record here, which must have already been validated and
      -- attached to the record by the form or entry API before
      -- calling this process.
      --
      if g_debug then
         hr_utility.trace('effdate='||to_char(effdate, 'DD-MON-YYYY'));
         hr_utility.set_location(c_indent,5);
      end if;
      select /*+ ordered use_nl(pee asg ptp pbg)
                 index(pee PAY_ELEMENT_ENTRIES_F_PK)
                 index(asg PER_ASSIGNMENTS_F_PK)
                 index(ptp PER_TIME_PERIODS_N50) */
             pay_payroll_actions_s.nextval,
             asg.business_group_id,
             pbg.legislation_code,
             asg.assignment_id,
             asg.payroll_id,
             ptp.time_period_id,
             pee.created_by,
             pee.creation_date,
             pee.original_entry_id
      into   pactid,
             busgrp,
             legcode,
             asgid,
             payid,
             tperiod,
             creatby,
             creatdate,
             l_original_entry_id
      from   pay_element_entries_f pee,
             per_all_assignments_f asg,
             per_time_periods      ptp,
             per_business_groups_perf  pbg
      where  pee.element_entry_id = eentryid
      and    effdate between
             pee.effective_start_date and pee.effective_end_date
      and    asg.assignment_id    = pee.assignment_id
      and    effdate between
             asg.effective_start_date and asg.effective_end_date
      and    pbg.business_group_id = asg.business_group_id
      and    ptp.payroll_id       = asg.payroll_id
      and    effdate between
             ptp.start_date and ptp.end_date;
--
      open csr_time_period_leg(legcode);
      fetch csr_time_period_leg into l_dummy;
--
      if (csr_time_period_leg%found) then
         close csr_time_period_leg;
         select pt2.time_period_id, pt2.end_date
         into   tperiod, dtearned
         from   per_time_periods pt2
         where  pt2.time_period_id in
                (select min(time_period_id)
                 from   per_time_periods ptp
                 where  ptp.payroll_id = payid
                 and    effdate between ptp.start_date
                                and greatest(ptp.end_date, ptp.regular_payment_date));
      else
         close csr_time_period_leg;
         dtearned := effdate;
      end if;
--
      -- insert payroll action row.
      if g_debug then
         hr_utility.set_location(c_indent,10);
      end if;
      insert  into pay_payroll_actions (
              payroll_action_id,
              action_type,
              business_group_id,
              consolidation_set_id,
              payroll_id,
              action_population_status,
              action_status,
              effective_date,
              date_earned,
              action_sequence,
              time_period_id,
              future_process_mode,
              created_by,
              creation_date,
              object_version_number)
      values (pactid,
              act_type,
              busgrp,
              consetid,
              payid,
              'C',
              'C',
              effdate,
              dtearned,
              pay_payroll_actions_s.nextval,
              tperiod,
              prepay_flag,
              creatby,
              creatdate,
              1);
--
      -- now, we need to insert the assignment action.
      inassact_main(pactid,asgid,null,null,null,eentryid,
                    TRUE, taxunit,purge_mode,run_type_id);
--
      --
      -- We now need to get the id of the inserted action,
      -- so that it can be used for update purposes.
      if g_debug then
         hr_utility.set_location(c_indent,15);
      end if;
      select act.assignment_action_id, act.tax_unit_id
      into   assactid, tax_unit
      from   pay_assignment_actions act
      where  act.payroll_action_id = pactid;
--
      --
      -- we need to insert the run result row
      if g_debug then
         hr_utility.set_location(c_indent,20);
      end if;


      -- calc jur code name
        pay_core_utils.get_leg_context_iv_name
                      ('JURISDICTION_CODE',
                       legcode,
                       l_jc_name,
                       l_found);

        if (l_found = FALSE) then
          l_jc_name := 'Jurisdiction';
        end if;


        -- set rr sparse leg_rule
        pay_core_utils.get_legislation_rule('RR_SPARSE',
                                            legcode,
                                            l_rule_mode,
                                            l_found
                                           );
        if (l_found = FALSE) then
          l_rule_mode := 'N';
        end if;

        if upper(l_rule_mode)='Y'
        then
           -- Confirm Enabling Upgrade has been made by customer
           pay_core_utils.get_upgrade_status(busgrp,
                                    'ENABLE_RR_SPARSE',
                                    l_status);

           if upper(l_status)='N'
           then
              l_rule_mode := 'N';
           end if;
        end if;

        if upper(l_rule_mode)='Y'
        then
         l_rr_sparse:=TRUE;
        else
         l_rr_sparse :=FALSE;
        end if;
--
       pay_core_utils.get_upgrade_status(busgrp,
                                    'RR_SPARSE_JC',
                                    l_status);
--
        if upper(l_status)='Y'
        then
         l_rr_sparse_jc :=TRUE;
        else
         l_rr_sparse_jc :=FALSE;
        end if;

        -- create run result
        pay_run_result_pkg.create_run_result(
                            p_element_entry_id  => eentryid,
                            p_session_date      => effdate,
                            p_business_group_id => busgrp,
                            p_jc_name           => l_jc_name,
                            p_rr_sparse         => l_rr_sparse,
                            p_rr_sparse_jc      => l_rr_sparse_jc,
                            p_asg_action_id     => assactid,
                            p_run_result_id     => l_run_result_id);


--
      if(sql%notfound) then
         if g_debug then
            hr_utility.trace('Update of pay_run_results has failed');
         end if;
         raise no_data_found;
      end if;
--
      -- Update the element entry creator_id column
      -- with the assignment_action_id of balance
      -- adjustment action.
      if g_debug then
         hr_utility.set_location(c_indent,25);
      end if;
      update pay_element_entries_f pee
      set    pee.creator_id       = assactid
      where  pee.element_entry_id = eentryid;
--
      if(sql%notfound) then
         if g_debug then
            hr_utility.trace('Update of pay_element_entries_f has failed');
         end if;
         raise no_data_found;
      end if;
--
--
      if (act_type = 'B') then

        -- Setup the action contexts
         set_action_context (assactid,
                             l_run_result_id,
                             eentryid,
                             tax_unit,
                             asgid,
                             busgrp,
                             legcode,
                             l_original_entry_id,
                             udca
                            );
--
--       Call to start of latest balance maintenance code
--
         maintain_lat_bal(assactid => assactid,
                          rrid     => l_run_result_id,
                          eentryid => eentryid,
                          effdate  => effdate,
                          udca     => udca,
                          act_type => act_type);

      end if;

      --
      -- Perform balance adjustment for pay_run_balances, 1st for asg level
      -- run balances, then group run balances.
      --
      pay_balance_pkg.create_all_asg_balances(p_asgact_id => assactid);
      --
      pay_balance_pkg.create_all_group_balances(p_pact_id => pactid);
      --

--
--    Set out variables
      pyactid := pactid;
      asactid := assactid;
--
   end bal_adjust_actions;
   --------------------------- bal_adjust ------------------------------
   /*
      NAME
         bal_adjust - perform balance adjustment.
      DESCRIPTION
         Process a balance adjustment.
      NOTES
         This is called directly from the Balance Adjustment form.
         This is used as a cover for bal_adjust_actions.
   */
   procedure bal_adjust
   (
      consetid in number, -- consolidation_set_id.
      eentryid in number, -- element_entry_id.
      effdate  in date,   -- effective_date of bal adjust.
      act_type in varchar2 default 'B', -- payroll_action_type.
      prepay_flag in varchar2 default null, -- include in prepay process?
      run_type_id in number default null,
      tax_unit_id in number default null
   ) is
   --
      l_pay_act_id  number;
      l_asg_act_id  number;
      c_indent constant varchar2(22) := 'hrassact.bal_adjust';
   begin
      g_debug := hr_utility.debug_enabled;
--
      if g_debug then
         hr_utility.set_location(c_indent,10);
      end if;
      bal_adjust_actions(consetid, eentryid, effdate, l_pay_act_id,
                          l_asg_act_id, act_type, prepay_flag,tax_unit_id,false,run_type_id);
      if g_debug then
         hr_utility.set_location(c_indent,20);
      end if;
   end;
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
      eentryid in number,  -- element_entry_id.
      effdate  in date,    -- effective_date of bal adjust.
      udca     in context_details, -- The UDCA
      act_type in varchar2 default 'B' -- payroll_action_type.
   ) is
   --
      --
      -- balance dimensions cache
      --
      type bal_dims_cache is record
      (dim_id                    number_tbl,
       dim_name                  varchar_80_tbl,
       feed_chk_type             varchar_tbl,
       feed_chk_code             varchar_80_tbl,
       exp_chk_lvl               varchar_tbl,
       exp_chk_code              varchar_80_tbl,
       sz                        number
      );
      --
      l_element_type_id          number;
      --
      -- cursor to get the run result values of the balance adjustment
      --
      -- Modified to retrieve result values with run_result_id.
      -- Bug 3482270.
      --
      cursor run_result_values is
      select rrv.input_value_id,
             rrv.result_value,
             rrv.run_result_id
      from   pay_run_result_values rrv
      where  rrv.run_result_id        = rrid
      and    rrv.result_value is not null;

     cursor fed_latest_balances(p_inp_val_id number,
                                p_person_id  number,
                                p_asg_id     number) is
      select plb.latest_balance_id,
             plb.assignment_action_id,
             plb.value,
             nvl(plb.expired_assignment_action_id, -9999) expired_assignment_action_id,
             nvl(plb.expired_value, -9999) expired_value,
             nvl(plb.prev_balance_value, -9999) prev_balance_value,
             nvl(plb.prev_assignment_action_id, -9999) prev_assignment_action_id,
             plb.expiry_date,
             plb.expired_date,
             plb.prev_expiry_date,
             pdb.balance_dimension_id,
             pdb.balance_type_id,
             pbf.scale
      from   pay_latest_balances plb,
             pay_defined_balances           pdb,
             pay_balance_feeds_f            pbf
      where  pbf.input_value_id      = p_inp_val_id
      and    effdate between pbf.effective_start_date
                         and pbf.effective_end_date
      and    pdb.balance_type_id     = pbf.balance_type_id
      and    plb.defined_balance_id = pdb.defined_balance_id
      and    plb.person_id          = p_person_id
      and    (   plb.assignment_id     = p_asg_id
              or plb.assignment_id is null)
      and    (   plb.process_group_id     = (select distinct parent_object_group_id
                                               from pay_object_groups pog
                                              where pog.source_id = p_asg_id
                                                and pog.source_type = 'PAF')
              or plb.process_group_id is null);

      --
      -- cursor to get the assignment latest balances that may be fed
      -- ie pay_balance feeds_f (subject to feed checking)
      --
      cursor fed_assignment_balances(p_inp_val_id number,
                                     p_asgid      number) is
      select palb.latest_balance_id,
             palb.assignment_action_id,
             palb.value,
             nvl(palb.expired_assignment_action_id, -9999) expired_assignment_action_id,
             nvl(palb.expired_value, -9999) expired_value,
             nvl(palb.prev_balance_value, -9999) prev_balance_value,
             nvl(palb.prev_assignment_action_id, -9999) prev_assignment_action_id,
             pdb.balance_dimension_id,
             pdb.balance_type_id,
             pbf.scale
      from   pay_assignment_latest_balances palb,
             pay_defined_balances           pdb,
             pay_balance_feeds_f            pbf
      where  pbf.input_value_id      = p_inp_val_id
      and    effdate between pbf.effective_start_date
                         and pbf.effective_end_date
      and    pdb.balance_type_id     = pbf.balance_type_id
      and    palb.defined_balance_id = pdb.defined_balance_id
      and    palb.assignment_id      = p_asgid;
      --
      -- cursor to get the person latest balances that may be fed
      -- ie pay_balance feeds_f (subject to feed checking)
      --
      cursor fed_person_balances(p_inp_val_id number,
                                 p_person_id  number) is
      select pplb.latest_balance_id,
             pplb.assignment_action_id,
             pplb.value,
             nvl(pplb.expired_assignment_action_id, -9999) expired_assignment_action_id,
             nvl(pplb.expired_value, -9999) expired_value,
             nvl(pplb.prev_balance_value, -9999) prev_balance_value,
             nvl(pplb.prev_assignment_action_id, -9999) prev_assignment_action_id,
             pdb.balance_dimension_id,
             pdb.balance_type_id,
             pbf.scale
      from   pay_person_latest_balances pplb,
             pay_defined_balances       pdb,
             pay_balance_feeds_f        pbf
      where  pbf.input_value_id      = p_inp_val_id
      and    effdate between pbf.effective_start_date
                         and pbf.effective_end_date
      and    pdb.balance_type_id     = pbf.balance_type_id
      and    pplb.defined_balance_id = pdb.defined_balance_id
      and    pplb.person_id          = p_person_id;

      bal_dims bal_dims_cache;

      c_indent constant varchar2(30) := 'hrassact.maintain_lat_bal';
      pactid               pay_payroll_actions.payroll_action_id%TYPE;
      asgid                per_all_assignments_f.assignment_id%TYPE;
      bus_grp_id           per_all_assignments_f.business_group_id%TYPE;
      l_person_id          per_all_assignments_f.person_id%TYPE;
      cxt_id               number;
      tax_unit_id          number;
      bal_dim_name         pay_balance_dimensions.dimension_name%TYPE;
      balance_expiry_code  pay_balance_dimensions.expiry_checking_code%TYPE;
      balance_expiry_level pay_balance_dimensions.expiry_checking_level%TYPE;
      bal_context_string   varchar2(2000);
      bal_fed              boolean;
      l_change_flag        boolean;
      l_rule_mode          pay_legislation_rules.rule_mode%TYPE;
      not_supported        boolean;
      l_status             varchar2(30);
      dummy_date           date;

      --
      -- Name : create_context_string
      --
      -- Get context values and also returns context string that is passed
      -- to feed and expiry checking if the expiry level is A (Assignment Action
      -- Level) or D (Date Level).
      --
      function get_contexts(udca in context_details
      ) return varchar2 is
      --
         l_context_string varchar2(2000);
      --
         c_indent constant varchar2(35) := 'hrassact.create_context_string';
      begin
         --
         if g_debug then
            hr_utility.set_location(c_indent,10);
         end if;
         --
         l_context_string := '';
         for cnt in 1..udca.sz loop
--
            l_context_string := l_context_string||udca.cxt_name(cnt)||
                                '='||udca.cxt_value(cnt)||' ';
--
         end loop;
         return(l_context_string);

      end get_contexts;
      --
      -- Name : proc_feed_check - Execute balance feeding procedure
      --
      -- Returns TRUE if balance is to be fed
      --
      -- The pl/sql function name that checks whether the balance is fed is
      -- passed to this routine as 'p_feed_checking_code'.  The call to the
      -- function is done using dynamic pl/sql.
      --
      function proc_feed_check
      (
         p_feed_checking_code  in     varchar2,  -- feed checking procedure name
         p_dimension_name      in     varchar2,  -- dimension name
         p_bal_context_str     in     varchar2   -- list of context values.
      ) return boolean is
         l_feed_balance boolean := FALSE;
      --
         c_indent constant varchar2(35) := 'hrassact.proc_feed_check';
         l_feed_chk_str    varchar2(2000);  -- used with dynamic pl/sql
         sql_cursor        integer;
         l_rows            integer;
         l_feed_flag       integer;
      --
      begin
         --
         if g_debug then
            hr_utility.set_location (c_indent, 1);
            hr_utility.trace ('Feed checking code = ' || p_feed_checking_code);
            hr_utility.trace ('context string = ' || p_bal_context_str);
         end if;
         --
         -- we build up the sql string to call the balance
         -- feed checking pl/sql procedure:
         --
         l_feed_chk_str := 'begin ' || p_feed_checking_code || ' (';
         l_feed_chk_str := l_feed_chk_str || ':pactid, ';
         l_feed_chk_str := l_feed_chk_str || ':assactid, ';
         l_feed_chk_str := l_feed_chk_str || ':asgid, ';
         l_feed_chk_str := l_feed_chk_str || ':effdate, ';
         l_feed_chk_str := l_feed_chk_str || ':p_dimension_name, ';
         l_feed_chk_str := l_feed_chk_str || ':p_bal_context_str, ';
         l_feed_chk_str := l_feed_chk_str || ':l_feed_flag); end;';
         --
         -- now execute the SQL statement using dynamic pl/sql:
         --
         -- Dynamic sql steps:
         -- ==================
         -- 1. Open dynamic sql cursor
         -- 2. Parse dynamic sql
         -- 3. bind variables
         -- 4. Execute dynamic sql
         -- 5. Get the variable value (providing there are rows returned)
         -- 6. Close the dynamic sql cursor
         --
         if g_debug then
            hr_utility.set_location (c_indent, 20);
         end if;
         sql_cursor := dbms_sql.open_cursor;                      -- step 1
         --
         if g_debug then
            hr_utility.set_location (c_indent, 25);
         end if;
         dbms_sql.parse(sql_cursor, l_feed_chk_str, dbms_sql.v7); -- step 2
         --
         if g_debug then
            hr_utility.set_location (c_indent, 30);
         end if;
         dbms_sql.bind_variable(sql_cursor, 'pactid', pactid);    -- step 3:
         --
         dbms_sql.bind_variable(sql_cursor, 'assactid', assactid);
         --
         dbms_sql.bind_variable(sql_cursor, 'asgid', asgid);
         --
         dbms_sql.bind_variable(sql_cursor, 'effdate', effdate);
         --
         dbms_sql.bind_variable(sql_cursor, 'p_dimension_name', p_dimension_name);
         --
         dbms_sql.bind_variable(sql_cursor, 'p_bal_context_str', p_bal_context_str);
         --
         dbms_sql.bind_variable(sql_cursor, 'l_feed_flag', l_feed_flag);
         --
         if g_debug then
            hr_utility.set_location (c_indent, 35);
         end if;
         l_rows := dbms_sql.execute (sql_cursor);                 -- step 4
         --
         if (l_rows = 1) then
            if g_debug then
               hr_utility.set_location (c_indent, 40);
            end if;
            dbms_sql.variable_value(sql_cursor, 'l_feed_flag',   -- step 5
                                                l_feed_flag);
            --
            if l_feed_flag = 1 then
               l_feed_balance := TRUE;
            end if;
            --
            if g_debug then
               hr_utility.set_location (c_indent, 45);
            end if;
            dbms_sql.close_cursor(sql_cursor);                   -- step 6
         else
            --
            -- None or more than 1 row has been returned. We must error as package
            -- call can only return 1 row, so this condition should never occur !
            --
            if g_debug then
               hr_utility.set_location (c_indent, 111);
            end if;
            dbms_sql.close_cursor(sql_cursor);
            hr_utility.raise_error;
         end if;
         --
         return(l_feed_balance);
         --
      end proc_feed_check;
      --
      -- Name : context_match_check - Perform context match feed checking
      --
      -- Returns TRUE if balance is to be fed
      --
      -- Performs matching check between latest balance context values
      -- and context values held inthe udca.  Type of checking on
      -- jurisdiction_code context is dependant upon p_feed_checking_type.
      --
      function lb_context_match_check
      (
         p_lat_bal_id          in  number,   -- latest balance_id
         p_feed_checking_type  in  varchar2, -- feed checking type ie 'E' or 'J'
         p_bal_type_id         in  number,   -- balance type id
         udca                  in  context_details
      ) return boolean is
         l_feed_flag boolean;
         l_match     boolean;

         c_indent constant varchar2(35) := 'hrassact.lb_context_match_check';
         l_jurisdiction_level pay_balance_types.jurisdiction_level%TYPE;
         cnt      number;
         l_tax_unit_id number;
         l_jurisdiction_code pay_run_result_values.result_value%type;
         l_original_entry_id number;
         l_source_id number;
         l_source_text pay_run_result_values.result_value%type;
         l_source_text2 pay_run_result_values.result_value%type;
         l_source_number number;
         l_source_number2 number;
         l_tax_group pay_run_result_values.result_value%type;
         l_local_unit_id number;
         l_organization_id number;
         l_payroll_id number;
      --
      begin
         --
         select tax_unit_id,
		jurisdiction_code,
		original_entry_id,
		source_id,
		source_text,
		source_text2,
		source_number,
		source_number2,
		tax_group,
		payroll_id,
                local_unit_id,
                organization_id
         into l_tax_unit_id,
              l_jurisdiction_code,
              l_original_entry_id,
              l_source_id,
              l_source_text,
              l_source_text2,
              l_source_number,
              l_source_number2,
              l_tax_group,
              l_payroll_id,
              l_local_unit_id,
              l_organization_id
         from pay_latest_balances
         where p_lat_bal_id = latest_balance_id;

         if g_debug then
            hr_utility.set_location (c_indent, 1);
         end if;

         l_feed_flag := TRUE;
         if udca.sz = 0 then
             l_feed_flag := FALSE;
         else

           if (l_jurisdiction_code is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
		if (udca.cxt_name(cnt) = 'JURISDICTION_CODE') then
                  l_match := TRUE;
                  select nvl(jurisdiction_level, 0)
                  into   l_jurisdiction_level
                  from   pay_balance_types
                  where  balance_type_id = p_bal_type_id;
                   if substr(udca.cxt_value(cnt), 1, l_jurisdiction_level) <>
                             l_jurisdiction_code then
                         -- jurisdiction_code to required level does not match
                        l_feed_flag := FALSE;
			exit;
                   end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_tax_unit_id is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'TAX_UNIT_ID' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>to_char(l_tax_unit_id) then
                        l_feed_flag := FALSE;
			exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_original_entry_id is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'ORIGINAL_ENTRY_ID' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>to_char(l_original_entry_id) then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_source_id is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'SOURCE_ID' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>to_char(l_source_id) then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_source_text is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'SOURCE_TEXT' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>l_source_text then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_source_text2 is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'SOURCE_TEXT2' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>l_source_text2 then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_source_number is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'SOURCE_NUMBER' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>to_char(l_source_number) then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
              end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_source_number2 is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'SOURCE_NUMBER2' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>to_char(l_source_number2) then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_local_unit_id is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'LOCAL_UNIT_ID' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>to_char(l_local_unit_id) then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_organization_id is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'ORGANIZATION_ID' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>to_char(l_organization_id) then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_tax_group is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'TAX_GROUP' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>l_tax_group then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

           if (l_payroll_id is not null) then
             l_match := FALSE;
             for cnt in 1..udca.sz loop
                if  udca.cxt_name(cnt) = 'PAYROLL_ID' then
                  l_match := TRUE;
                  if  udca.cxt_value(cnt)<>to_char(l_payroll_id) then
                        l_feed_flag := FALSE;
                        exit;
                  end if;
                end if;
             end loop;

             if (l_feed_flag=FALSE or
                 l_match=FALSE) then
              return FALSE;
             end if;
           end if;

         end if;

         if p_feed_checking_type = 'J' then

            for cnt in 1..udca.sz loop
               if udca.cxt_name(cnt) = 'JURISDICTION_CODE' then
                  l_feed_flag := FALSE;
                  exit;
               end if;
            end loop;

         end if;
         return(l_feed_flag);
         --
      end lb_context_match_check;

      function context_match_check
      (
         p_lat_bal_id          in  number,   -- latest balance_id
         p_feed_checking_type  in  varchar2, -- feed checking type ie 'E' or 'J'
         p_bal_type_id         in  number,   -- balance type id
         udca                  in  context_details
      ) return boolean is
         l_feed_flag boolean;
      --
         cursor balance_context_values is
         select context_id,
                value
         from pay_balance_context_values
         where latest_balance_id = p_lat_bal_id;

         c_indent constant varchar2(35) := 'hrassact.context_match_check';
         l_jurisdiction_level pay_balance_types.jurisdiction_level%TYPE;
         cnt      number;
      --
      begin
         --
         if g_debug then
            hr_utility.set_location (c_indent, 1);
         end if;
         --
         l_feed_flag := TRUE;

         for bcv in balance_context_values loop

            if udca.sz = 0 then
               l_feed_flag := FALSE;
            else
               for cnt in 1..udca.sz loop

                  if udca.cxt_id(cnt) = bcv.context_id then

                     -- have to deal with jurisdiction code context
                     -- as a special case
                     if udca.cxt_name(cnt) = 'JURISDICTION_CODE' then

                          select nvl(jurisdiction_level, 0)
                          into   l_jurisdiction_level
                          from   pay_balance_types
                          where  balance_type_id = p_bal_type_id;

                          if substr(udca.cxt_value(cnt), 1, l_jurisdiction_level) <>
                             bcv.value then
                             -- jurisdiction_code to required level does not match
                             l_feed_flag := FALSE;
                          end if;

                     elsif udca.cxt_value(cnt) <> bcv.value then
                        -- balance context value doesn't match udca value
                        l_feed_flag := FALSE;
                     end if;

                     exit;

                  elsif cnt = udca.sz then

                     -- balance context not in udca
                     l_feed_flag := FALSE;

                  end if;

               end loop;
            end if;

         end loop;

         --
         if g_debug then
            hr_utility.set_location (c_indent, 20);
         end if;
         --
         -- jurisdiction_code check for 'J' feed checking type whereby
         -- jurisdiction_code must be undefined in the udca
         if p_feed_checking_type = 'J' then

            for cnt in 1..udca.sz loop
               if udca.cxt_name(cnt) = 'JURISDICTION_CODE' then
                  l_feed_flag := FALSE;
                  exit;
               end if;
            end loop;

         end if;

         return(l_feed_flag);
         --
      end context_match_check;
      --
      -- Name : feed_check - Function to control feed checking
      --                     on a particular latest balance
      --
      -- Returns TRUE if balance is to be fed
      --
      function feed_check
      (
         lat_bal_id      in  number,   -- latest balance_id
         lat_bal_type    in  varchar2, -- latest balance type (ie A or P or L)
         bal_dim_id      in  number,   -- balance dimension id
         bal_type_id     in  number,   -- balance type id
         bal_dim_name    in out nocopy varchar2, -- balance dimension name
         bal_exp_code    in out nocopy varchar2, -- balance dimension expiry code
         bal_exp_level   in out nocopy varchar2, -- balance dimension expiry level
         bal_context_str in  varchar2, -- balance dimension contexts string
         udca            in context_details
      ) return boolean is
         feed_balance boolean;
      --
         c_indent constant varchar2(30) := 'hrassact.feed_check';
         feed_checking_type pay_balance_dimensions.feed_checking_type%TYPE;
         feed_checking_code pay_balance_dimensions.feed_checking_code%TYPE;
         dim_num number;
         found   boolean := FALSE;
      --
      begin
         --
         if g_debug then
            hr_utility.set_location (c_indent, 10);
         end if;
         --
         -- get balance dimension info for the latest balance
         --
         -- check cache first
         --
         for dim_num in 1..bal_dims.sz loop
            if bal_dims.dim_id(dim_num) = bal_dim_id then
               bal_dim_name       := bal_dims.dim_name(dim_num);
               feed_checking_type := bal_dims.feed_chk_type(dim_num);
               feed_checking_code := bal_dims.feed_chk_code(dim_num);
               bal_exp_code       := bal_dims.exp_chk_code(dim_num);
               bal_exp_level      := bal_dims.exp_chk_lvl(dim_num);
               found              := TRUE;
            end if;
         end loop;

         if found = FALSE then

            select pbd.dimension_name,
                   pbd.feed_checking_type,
                   pbd.feed_checking_code,
                   pbd.expiry_checking_code,
                   pbd.expiry_checking_level
            into   bal_dim_name,
                   feed_checking_type,
                   feed_checking_code,
                   bal_exp_code,
                   bal_exp_level
            from  pay_balance_dimensions pbd
            where pbd.balance_dimension_id = bal_dim_id;

            -- put into cache
            bal_dims.sz                         := bal_dims.sz + 1;
            bal_dims.dim_id(bal_dims.sz)        := bal_dim_id;
            bal_dims.dim_name(bal_dims.sz)      := bal_dim_name;
            bal_dims.feed_chk_type(bal_dims.sz) := feed_checking_type;
            bal_dims.feed_chk_code(bal_dims.sz) := feed_checking_code;
            bal_dims.exp_chk_code(bal_dims.sz)  := bal_exp_code;
            bal_dims.exp_chk_lvl(bal_dims.sz)   := bal_exp_level;

         end if;


         --
         if feed_checking_type is null then
            -- default checking type whereby always feed balance
            if g_debug then
               hr_utility.set_location (c_indent, 20);
            end if;
            feed_balance := TRUE;

         elsif feed_checking_type not in ('P', 'E', 'J') then
            -- unhandled checking type is S-ubject
            -- we either just delete latest balance, or
            -- recalculate it
            -- YET TO BE DECIDED

            if g_debug then
               hr_utility.set_location (c_indent, 30);
            end if;

            if lat_bal_type = 'A' then
               delete from pay_balance_context_values
               where latest_balance_id = lat_bal_id;

               delete from pay_assignment_latest_balances
               where latest_balance_id = lat_bal_id;
            elsif lat_bal_type = 'P' then
               delete from pay_balance_context_values
               where latest_balance_id = lat_bal_id;

               delete from pay_person_latest_balances
               where latest_balance_id = lat_bal_id;
            else
               delete from pay_latest_balances
               where latest_balance_id = lat_bal_id;

            end if;
            -- or recalculate latest balance
            feed_balance := FALSE;

         elsif feed_checking_type = 'P' then
            -- legislative defined procedure feed_checking_code is
            -- used to perform feed checking

            feed_balance := proc_feed_check(feed_checking_code, bal_dim_name,
                                            bal_context_str);

         elsif feed_checking_type in ('E', 'J') then

          if (lat_bal_type='L') then
           feed_balance:= lb_context_match_check(lat_bal_id,feed_checking_type,
                                                bal_type_id, udca);
          else
           feed_balance := context_match_check(lat_bal_id, feed_checking_type,
                                                bal_type_id, udca);
          end if;

         end if;

         return(feed_balance);

      end feed_check;
      --
      -- Name : get_expiry_date - Execute balance expiry date procedure
      --
      -- Returns last date in period for dimension containing the
      -- effective_date of p_bal_owner_asg_actid
      --
      -- returns 01/01/1900 if p_bal_owner_asg_actid is the empty value
      -- ie -9999.  The calling code will then treats this as special balance
      -- value - and should leave it unchanged.
      --
      -- returns 01/01/1990 if is a never expired type of balance
      --
      -- The pl/sql function name that checks whether the balance is fed is
      -- passed to this routine as 'p_expiry_date_code'.  The call to the
      -- function is done using dynamic pl/sql.
      --
      -- Also returns effective date of latest balance in p_bal_owner_eff_date
      -- (to save refetching later on).
      --
      function get_expiry_date
      (
         p_expiry_date_code    in     varchar2,  -- expiry date procedure name
         p_ass_action_id       in     number,    -- balance adjustment asg action id
         p_bal_owner_asg_actid in     number,    -- latest balance asg action id
         p_dimension_name      in     varchar2,  -- dimension name
         p_expiry_check_level  in     varchar2,  -- expiry checking level
         p_bal_context_str     in     varchar2,  -- list of context values.
         p_bal_owner_eff_date  in out nocopy date       -- latest balance date
      ) return date is
         l_expiry_date date;
      --
         c_indent constant varchar2(35) := 'hrassact.get_expiry_date';
         l_payroll_action        pay_payroll_actions.payroll_action_id%type;
         l_effective_date        pay_payroll_actions.effective_date%type;
         l_bal_owner_pay_action  pay_payroll_actions.payroll_action_id%type;
         l_expiry_chk_str  varchar2(2000);  -- used with dynamic pl/sql
         sql_cursor        integer;
         l_rows            integer;
      --
      begin
         --
         if g_debug then
            hr_utility.set_location (c_indent, 5);
         end if;
         if p_bal_owner_asg_actid = -9999 then
            l_expiry_date := to_date('01/01/1900', 'DD/MM/YYYY');
            p_bal_owner_eff_date := l_expiry_date;

            return(l_expiry_date);
         end if;
         --
         if g_debug then
            hr_utility.trace ('Expiry date fetching code = ' || p_expiry_date_code);
            hr_utility.set_location (c_indent||p_bal_owner_asg_actid, 7);
         end if;
         --
         -- Get the payroll_action_id and eff date for the latest balance
         -- The expiry date returned is the last date in the period for
         -- the balance dimension that contains this date
         --
         select pay.payroll_action_id,
                pay.effective_date
         into   l_bal_owner_pay_action,
                p_bal_owner_eff_date
         from   pay_assignment_actions        asg
         ,      pay_payroll_actions           pay
         where  asg.assignment_action_id    = p_bal_owner_asg_actid
         and    pay.payroll_action_id       = asg.payroll_action_id;
         --
         -- Get the payroll_action_id and eff date for the adjustment if
         -- it is different
         --
         if g_debug then
            hr_utility.set_location (c_indent||p_ass_action_id, 10);
         end if;
         if p_ass_action_id <> p_bal_owner_asg_actid then
            select pay.payroll_action_id,
                   pay.effective_date
            into   l_payroll_action,
                   l_effective_date
            from   pay_assignment_actions        asg
            ,      pay_payroll_actions           pay
            where  asg.assignment_action_id    = p_ass_action_id
            and    pay.payroll_action_id       = asg.payroll_action_id;
         else
            l_payroll_action := l_bal_owner_pay_action;
            l_effective_date := p_bal_owner_eff_date;
         end if;
         --
         -- if Never expired balance we simply return an expiry date
         -- of beginning of time
         --
         if p_expiry_check_level = 'N' then
            if g_debug then
               hr_utility.set_location (c_indent, 12);
            end if;
            l_expiry_date := to_date('01/01/1900', 'DD/MM/YYYY');

            return(l_expiry_date);
         elsif p_expiry_date_code is null then
            --
            -- expiry date procedure doesn't exist
            --
            if g_debug then
               hr_utility.set_location (c_indent, 14);
            end if;
            dbms_sql.close_cursor(sql_cursor);
            hr_utility.set_message(801, 'HR_7274_PAY_NO_EXPIRY_CODE');
            hr_utility.set_message_token ('EXPIRY_CODE', p_expiry_date_code);
            hr_utility.raise_error;
         end if;
         --
         -- we build up the sql string to call the balance
         -- feed checking pl/sql procedure:
         --
         l_expiry_chk_str := 'begin ' || p_expiry_date_code || ' (';
         l_expiry_chk_str := l_expiry_chk_str || ':l_bal_owner_pay_action, ';
         l_expiry_chk_str := l_expiry_chk_str || ':l_payroll_action, ';
         l_expiry_chk_str := l_expiry_chk_str || ':p_bal_owner_asg_actid, ';
         l_expiry_chk_str := l_expiry_chk_str || ':p_ass_action_id, ';
         l_expiry_chk_str := l_expiry_chk_str || ':p_bal_owner_eff_date, ';
         l_expiry_chk_str := l_expiry_chk_str || ':l_effective_date, ';
         l_expiry_chk_str := l_expiry_chk_str || ':p_dimension_name, ';
         --
         if (p_expiry_check_level in ('A', 'D')) then
            l_expiry_chk_str := l_expiry_chk_str || ':p_bal_context_str, ';
         end if;
         --
         l_expiry_chk_str := l_expiry_chk_str || ':l_expiry_date); end;';
         --
         -- now execute the SQL statement using dynamic pl/sql:
         --
         -- Dynamic sql steps:
         -- ==================
         -- 1. Open dynamic sql cursor
         -- 2. Parse dynamic sql
         -- 3. bind variables
         -- 4. Execute dynamic sql
         -- 5. Get the variable value (providing there are rows returned)
         -- 6. Close the dynamic sql cursor
         --
         if g_debug then
            hr_utility.set_location (c_indent, 20);
         end if;
         sql_cursor := dbms_sql.open_cursor;                      -- step 1
         --
         if g_debug then
            hr_utility.set_location (c_indent, 25);
         end if;
         dbms_sql.parse(sql_cursor, l_expiry_chk_str, dbms_sql.v7); -- step 2
         --
         if g_debug then
            hr_utility.set_location (c_indent||to_char(p_bal_owner_eff_date, 'DD/MM/YYYY'), 30);
         end if;
         dbms_sql.bind_variable(sql_cursor, 'l_bal_owner_pay_action', l_bal_owner_pay_action);  -- step 3:
         --
         dbms_sql.bind_variable(sql_cursor, 'l_payroll_action', l_payroll_action);
         --
         dbms_sql.bind_variable(sql_cursor, 'p_bal_owner_asg_actid', p_bal_owner_asg_actid);
         --
         dbms_sql.bind_variable(sql_cursor, 'p_ass_action_id', p_ass_action_id);
         --
         dbms_sql.bind_variable(sql_cursor, 'p_bal_owner_eff_date', p_bal_owner_eff_date);
         --
         dbms_sql.bind_variable(sql_cursor, 'l_effective_date', l_effective_date);
         --
         dbms_sql.bind_variable(sql_cursor, 'p_dimension_name', p_dimension_name);
         --
         if (p_expiry_check_level in ('A', 'D')) then
            dbms_sql.bind_variable(sql_cursor, 'p_bal_context_str', p_bal_context_str);
         end if;
         --
         dbms_sql.bind_variable(sql_cursor, 'l_expiry_date', l_expiry_date);
         --
         if g_debug then
            hr_utility.set_location (c_indent, 35);
         end if;
         l_rows := dbms_sql.execute (sql_cursor);                 -- step 4
         --
         if (l_rows = 1) then
            if g_debug then
               hr_utility.set_location (c_indent, 40);
            end if;
            dbms_sql.variable_value(sql_cursor, 'l_expiry_date',   -- step 5
                                                l_expiry_date);
            --
            if g_debug then
               hr_utility.set_location (c_indent||to_char(l_expiry_date, 'DD/MM/YYYY'), 45);
            end if;
            dbms_sql.close_cursor(sql_cursor);                   -- step 6
         elsif (l_rows = 0) then
            --
            -- expiry date procedure didn't exist
            --
            if g_debug then
               hr_utility.set_location (c_indent, 50);
            end if;
            dbms_sql.close_cursor(sql_cursor);
            hr_utility.set_message(801, 'HR_7274_PAY_NO_EXPIRY_CODE');
            hr_utility.set_message_token ('EXPIRY_CODE', p_expiry_date_code);
            hr_utility.raise_error;
         else
            --
            -- None or more than 1 row has been returned. We must error as package
            -- call can only return 1 row, so this condition should never occur !
            --
            if g_debug then
               hr_utility.set_location (c_indent, 60);
            end if;
            dbms_sql.close_cursor(sql_cursor);
            hr_utility.raise_error;
         end if;
         --
         return(l_expiry_date);
         --
      end get_expiry_date;
      --
      -- Name : feed_balance - Adjust latest/previous/expired balances
      --
      -- Called if balance adjustment does feed this latest balance.
      -- Have to adjust none of more of latest, previous or expired balance
      -- values and possibly their asg action ids depending upon their
      -- and the balance adjustments period
      --
      function feed_balance
      (
         p_expiry_date_code    in     varchar2,  -- expiry date procedure name
         p_dimension_name      in     varchar2,  -- dimension name
         p_expiry_check_level  in     varchar2,  -- expiry checking level
         p_bal_context_str     in     varchar2,  -- list of context values.
         assignment_action_id  in out nocopy number,    -- lb lat asg action id
         value                 in out nocopy number,    -- lb lat value
         expired_asg_action_id in out nocopy number,    -- lb exp asg action id
         expired_value         in out nocopy number,    -- lb exp value
         prev_asg_action_id    in out nocopy number,    -- lb prev al asg action id
         prev_balance_value    in out nocopy number,    -- lb prev value
         result_value          in     number,    -- balance adjustment rrv
         feed_scale            in     number,    -- balance dimension feed scale
         expiry_date           in out nocopy date  ,    -- lb expiry date
         expired_date          in out nocopy date  ,    -- lb expired date
         prev_expiry_date      in out nocopy date      -- lb prev expiry date
      ) return boolean is
         l_change_flag boolean;
      --
         c_indent constant varchar2(35) := 'hrassact.feed_balance';
         lat_bal_exp_date        date;
         l_bal_owner_eff_date    pay_payroll_actions.effective_date%type;
         bal_adj_exp_date        date;
         bal_adj_eff_date        pay_payroll_actions.effective_date%type;
         prev_bal_exp_date       date;
         p_bal_owner_eff_date    pay_payroll_actions.effective_date%type;
         exp_bal_exp_date        date;
         e_bal_owner_eff_date    pay_payroll_actions.effective_date%type;
      --
      begin
      --
         if g_debug then
            hr_utility.set_location (c_indent, 10);
         end if;
         --
         l_change_flag := TRUE;
       --
         -- Check if latest balance already owned by balance
         -- adjustment. If so simply increment the value
         --
         if assignment_action_id = assactid or
            expired_asg_action_id = assactid then

            if g_debug then
               hr_utility.set_location (c_indent, 15);
            end if;

            if assignment_action_id = assactid then
               value := value + (result_value * feed_scale);
            end if;

            if expired_asg_action_id = assactid then
               expired_value := expired_value + (result_value * feed_scale);

               if prev_asg_action_id = assactid then
                  prev_balance_value := prev_balance_value + (result_value * feed_scale);
               end if;
            end if;

            return(l_change_flag);
         end if;

         --
         -- Get expiry date for balance adjustment
         --
         bal_adj_exp_date := get_expiry_date(p_expiry_date_code, assactid,
                                             assactid, p_dimension_name,
                                             p_expiry_check_level, p_bal_context_str,
                                             bal_adj_eff_date);
         --
         if g_debug then
            hr_utility.set_location (c_indent, 20);
         end if;
         --
         -- Get expiry date for latest balance
         --
         lat_bal_exp_date := get_expiry_date(p_expiry_date_code, assignment_action_id,
                                             assignment_action_id, p_dimension_name,
                                             p_expiry_check_level, p_bal_context_str,
                                             l_bal_owner_eff_date);
         --
         if g_debug then
            hr_utility.set_location (c_indent||p_dimension_name, 30);
         end if;

         if bal_adj_exp_date > lat_bal_exp_date then
            -- balance adjustment expiry date is later than the latest balance
            -- expiry date, and hence in a later period so we copy the latest balance
            -- to the previous latest balance and expired latest balance, and set
            -- the latest balance to be the balance adjustment

            if g_debug then
               hr_utility.set_location (c_indent, 40);
            end if;

            prev_balance_value := value;
            prev_asg_action_id := assignment_action_id;
            expired_value := value;
            expired_asg_action_id := assignment_action_id;

            value := result_value * feed_scale;
            assignment_action_id := assactid;
            expired_date := lat_bal_exp_date;
            prev_expiry_date := lat_bal_exp_date;
            expiry_date := bal_adj_exp_date;

         elsif bal_adj_exp_date = lat_bal_exp_date then
            -- balance adjustment expiry date = latest balance expiry date
            -- so feed latest balance and possibly previous latest balance

            if g_debug then
               hr_utility.set_location (c_indent, 50);
            end if;

            if bal_adj_eff_date >= l_bal_owner_eff_date then
               -- balance adjustment effective date is later than the latest balance
               -- effective date so we copy the latest balance to the previous latest
               -- balance and adjust the latest balance value and its asg action id by
               -- the adjustment

               if g_debug then
                  hr_utility.set_location (c_indent, 60);
               end if;

               prev_balance_value := value;
               prev_asg_action_id := assignment_action_id;

               value := value + (result_value * feed_scale);
               assignment_action_id := assactid;
               prev_expiry_date := lat_bal_exp_date;
               expiry_date := bal_adj_exp_date;

            else
               -- the balance adjustment effective date is earlier than the latest balance
               -- effective date so we adjust the latest balance value (but nots its asg
               -- action id), and then see if we need to adjust the previous latest
               -- balance

               if g_debug then
                  hr_utility.set_location (c_indent, 70);
               end if;

               value := value + (result_value * feed_scale);
               expiry_date := bal_adj_exp_date;

               -- Get expiry date for previous latest balance
               prev_bal_exp_date := get_expiry_date(p_expiry_date_code, prev_asg_action_id,
                                                    prev_asg_action_id, p_dimension_name,
                                                    p_expiry_check_level, p_bal_context_str,
                                                    p_bal_owner_eff_date);

               if bal_adj_exp_date = prev_bal_exp_date then
                  -- need to adjust previous balance as in same period as balance adjustment

                  if g_debug then
                     hr_utility.set_location (c_indent, 80);
                  end if;

                  if bal_adj_eff_date >= p_bal_owner_eff_date then
                     -- as balance adjustment effective date is later than previous latest
                     -- balance effective date we also need to amend previous latest
                     -- balance asg action id

                     if g_debug then
                        hr_utility.set_location (c_indent, 90);
                     end if;

                     prev_balance_value := prev_balance_value + (result_value * feed_scale);
                     prev_asg_action_id := assactid;
                     prev_expiry_date :=  bal_adj_exp_date;
                  else
                     if g_debug then
                        hr_utility.set_location (c_indent, 100);
                     end if;

                     prev_balance_value := prev_balance_value + (result_value * feed_scale);
                     prev_expiry_date := prev_bal_exp_date;
                  end if;

               elsif prev_asg_action_id <> -9999 then
                  -- balance adjustment is in later period than previous latest balance
                  -- so replace previous latest balance value and its asg action id by
                  -- the balance adjustment

                  if g_debug then
                     hr_utility.set_location (c_indent, 110);
                  end if;
                  prev_balance_value := result_value * feed_scale;
                  prev_asg_action_id := assactid;
                  prev_expiry_date := bal_adj_exp_date;

               else
                  -- previous balance value is undefined (ie null or -9999)

                  if g_debug then
                     hr_utility.set_location (c_indent, 115);
                  end if;

               end if;
            end if;

         else
            -- balance adjusmtent expiry date <> latest balance expiry date
            -- so may need to adjust expired and previous latest balances
            if g_debug then
               hr_utility.set_location (c_indent, 120);
            end if;

            -- Get expiry date for expired latest balance
            exp_bal_exp_date := get_expiry_date(p_expiry_date_code, expired_asg_action_id,
                                                expired_asg_action_id, p_dimension_name,
                                                p_expiry_check_level, p_bal_context_str,
                                                e_bal_owner_eff_date);

            -- if balance adjusmtent expiry date = expired balance expiry date
            -- then adjust expired balance and possibly previous latest balance
            if bal_adj_exp_date = exp_bal_exp_date then

               if g_debug then
                  hr_utility.set_location (c_indent, 130);
               end if;

               if bal_adj_eff_date >= e_bal_owner_eff_date then
                  -- balance adjustment effective date is later than the expired balance
                  -- effective date so the expired value and asg action id needs to be
                  -- adjusted by the balance adjustment
                  --
                  -- before doing so we see if the previous latest balance is from the
                  -- same assignment action id and hence also needs adjusting

                  if g_debug then
                     hr_utility.set_location (c_indent, 140);
                  end if;

                  if expired_asg_action_id = prev_asg_action_id then
                     -- adjust the previous latest balance
                     if g_debug then
                        hr_utility.set_location (c_indent, 150);
                     end if;

                     prev_balance_value := prev_balance_value + (result_value * feed_scale);
                     prev_asg_action_id := assactid;
                     prev_expiry_date := bal_adj_exp_date;
                  end if;

                  expired_value := expired_value + (result_value * feed_scale);
                  expired_asg_action_id := assactid;
                  expired_date := bal_adj_exp_date;

               else
                  -- balance adjustment effective date is earlier than the expired balance
                  -- effective date so the expired value (not the asg action id) needs
                  -- to be adjusted by the balance adjustment
                  --
                  -- before doing so we see if the previous latest balance is from the
                  -- same assignment action id and hence also needs adjusting

                  if g_debug then
                     hr_utility.set_location (c_indent, 160);
                  end if;

                  if expired_asg_action_id = prev_asg_action_id then
                     -- adjust the previous latest balance
                     if g_debug then
                        hr_utility.set_location (c_indent||prev_balance_value, 170);
                     end if;

                     prev_balance_value := prev_balance_value + (result_value * feed_scale);
                     prev_expiry_date := exp_bal_exp_date;
                     if g_debug then
                        hr_utility.set_location (c_indent||prev_balance_value, 170);
                     end if;
                  end if;

                  if g_debug then
                     hr_utility.set_location (c_indent||expired_value, 170);
                  end if;
                  expired_value := expired_value + (result_value * feed_scale);
                  expired_date := exp_bal_exp_date;
                  if g_debug then
                     hr_utility.set_location (c_indent||expired_value, 170);
                  end if;

               end if;

            else
               -- the balance adjustment expiry date is not the same as either the
               -- latest balance expiry date or the expired balance expiry date,
               -- and is not later than the latest balance expiry date.
               -- it may be between the latest and expired balance periods - in
               -- which case we would want to adjust the expired, or it may be
               -- ealier than the expired.
               --
               if g_debug then
                  hr_utility.set_location (c_indent, 180);
               end if;

               if expired_asg_action_id <> -9999 and
                  bal_adj_exp_date > exp_bal_exp_date then
                  -- it is newer so we need to replace the expired (and possibly previous)

                  if g_debug then
                     hr_utility.set_location (c_indent, 190);
                  end if;

                  if expired_asg_action_id = prev_asg_action_id then
                     -- adjust the previous latest balance
                     if g_debug then
                        hr_utility.set_location (c_indent, 200);
                     end if;

                     prev_balance_value := result_value * feed_scale;
                     prev_asg_action_id := assactid;
                     prev_expiry_date := bal_adj_exp_date;
                  end if;

                  expired_value := result_value * feed_scale;
                  expired_asg_action_id := assactid;
                  expired_date := bal_adj_exp_date;

               else
                  -- the balance adjustment is in an older period than the expired
                  -- latest balance and therefore does not feed it

                   if g_debug then
                     hr_utility.set_location (c_indent, 210);
                  end if;

                  l_change_flag := FALSE;

               end if;

            end if;
         end if;

         return(l_change_flag);
      --
      end feed_balance;
      --
   begin
      g_debug := hr_utility.debug_enabled;
      --
      if g_debug then
         hr_utility.set_location(c_indent,10);
      end if;
      --
      -- initialise balance dimensions cache
      --
      bal_dims.sz := 0;
      --
      -- get info about assignment and action
      -- including tax_unit_id context value
      --
      select pera.assignment_id,
             pera.person_id,
             paa.payroll_action_id,
             paa.tax_unit_id,
             pera.business_group_id
      into   asgid,
             l_person_id,
             pactid,
             tax_unit_id,
             bus_grp_id
      from   pay_assignment_actions paa,
             per_all_assignments_f pera
      where  paa.assignment_action_id = assactid
      and    pera.assignment_id       = paa.assignment_id
      and    effdate between pera.effective_start_date
                         and pera.effective_end_date;
      --
      if g_debug then
         hr_utility.set_location(c_indent,20);
      end if;
      --
      if act_type = 'B' then
         --
         -- check for BAL_ADJ_LAT_BAL legislation rule to see if
         -- this functionality is supported for this balance adjustment
         --
         if g_ba_lat_bal_maintenance is null then
            begin
               select rule_mode
               into l_rule_mode
               from pay_legislation_rules plr,
                    per_business_groups_perf pbg
               where pbg.business_group_id = bus_grp_id
               and   plr.legislation_code  = pbg.legislation_code
               and   rule_type             = 'BAL_ADJ_LAT_BAL';

               if upper(l_rule_mode) = 'Y' then
                  g_ba_lat_bal_maintenance := FALSE;
               else
                  g_ba_lat_bal_maintenance := TRUE;
               end if;
            exception
               when others then
                  g_ba_lat_bal_maintenance := TRUE;
            end;
         end if;
         not_supported := g_ba_lat_bal_maintenance;
      else
         --
         -- Reversal - as entered maintain_lat_bal REV_LAT_BAL
         -- is set
         --
         not_supported := FALSE;
      end if;
      --
      --
      if not_supported = TRUE then
         --
         -- delete latest balances
         if g_debug then
            hr_utility.set_location(c_indent,25);
         end if;
         --
         -- Derive element type id from the run result.
         --
         select rr.element_type_id into l_element_type_id
         from pay_run_results rr
         where rr.run_result_id = rrid;

         del_latest_balances(asgid, effdate, eentryid, l_element_type_id);
         return;
      end if;
      --
      -- get the contexts cached
      if contexts_cached = FALSE then
         cache_contexts;
      end if;
      --
      if g_debug then
         hr_utility.set_location(c_indent,30);
      end if;
      --
      for rrv in run_result_values loop

         bal_fed := FALSE;
         l_change_flag := FALSE;
         -- return contents of udca
         bal_context_string := get_contexts(udca);


      pay_core_utils.get_upgrade_status(p_bus_grp_id=> bus_grp_id,
                             p_short_name=> 'SINGLE_BAL_TABLE',
                             p_status=>l_status);

      if (l_status='N')
      then
         -- feed check assignment latest balances
         for alb in fed_assignment_balances(rrv.input_value_id, asgid) loop
             bal_fed := feed_check(alb.latest_balance_id, 'A', alb.balance_dimension_id,
                                   alb.balance_type_id, bal_dim_name,
                                   balance_expiry_code, balance_expiry_level,
                                   bal_context_string, udca);


             if bal_fed = TRUE then
                l_change_flag := feed_balance(balance_expiry_code, bal_dim_name,
                             balance_expiry_level, bal_context_string,
                             alb.assignment_action_id, alb.value,
                             alb.expired_assignment_action_id, alb.expired_value,
                             alb.prev_assignment_action_id, alb.prev_balance_value,
                             fnd_number.canonical_to_number(rrv.result_value),
                             alb.scale, dummy_date,dummy_date,dummy_date);

                if l_change_flag = TRUE then
                   update pay_assignment_latest_balances
                   set assignment_action_id         = alb.assignment_action_id,
                       value                        = alb.value,
                       expired_assignment_action_id = alb.expired_assignment_action_id,
                       expired_value                = alb.expired_value,
                       prev_assignment_action_id    = alb.prev_assignment_action_id,
                       prev_balance_value           = alb.prev_balance_value
                   where latest_balance_id          = alb.latest_balance_id;
                end if;
             end if;
         end loop;
      --
         -- feed check person latest balances
         for plb in fed_person_balances(rrv.input_value_id, l_person_id) loop
             bal_fed := feed_check(plb.latest_balance_id, 'P', plb.balance_dimension_id,
                                   plb.balance_type_id, bal_dim_name,
                                   balance_expiry_code, balance_expiry_level,
                                   bal_context_string, udca);

             if bal_fed = TRUE then
                l_change_flag := feed_balance(balance_expiry_code, bal_dim_name,
                             balance_expiry_level, bal_context_string,
                             plb.assignment_action_id, plb.value,
                             plb.expired_assignment_action_id, plb.expired_value,
                             plb.prev_assignment_action_id, plb.prev_balance_value,
                             fnd_number.canonical_to_number(rrv.result_value),
                             plb.scale,dummy_date,dummy_date,dummy_date);

                if l_change_flag = TRUE then
                   update pay_person_latest_balances
                   set assignment_action_id         = plb.assignment_action_id,
                       value                        = plb.value,
                       expired_assignment_action_id = plb.expired_assignment_action_id,
                       expired_value                = plb.expired_value,
                       prev_assignment_action_id    = plb.prev_assignment_action_id,
                       prev_balance_value           = plb.prev_balance_value
                   where latest_balance_id          = plb.latest_balance_id;
                end if;
             end if;
         end loop;
      --
      else
         -- feed check person latest balances
         for lb in fed_latest_balances(rrv.input_value_id, l_person_id, asgid) loop
             hr_utility.set_location(c_indent,100);
             bal_fed := feed_check(lb.latest_balance_id, 'L', lb.balance_dimension_id,
                                   lb.balance_type_id, bal_dim_name,
                                   balance_expiry_code, balance_expiry_level,
                                   bal_context_string, udca);

             if bal_fed = TRUE then
                l_change_flag := feed_balance(balance_expiry_code, bal_dim_name,
                             balance_expiry_level, bal_context_string,
                             lb.assignment_action_id, lb.value,
                             lb.expired_assignment_action_id, lb.expired_value,
                             lb.prev_assignment_action_id, lb.prev_balance_value,
                             fnd_number.canonical_to_number(rrv.result_value),
                             lb.scale,lb.expiry_date, lb.expired_date,lb.prev_expiry_date);

                if l_change_flag = TRUE then
                   update pay_latest_balances
                   set assignment_action_id         = lb.assignment_action_id,
                       value                        = lb.value,
                       expiry_date                = lb.expiry_date,
                       expired_assignment_action_id = lb.expired_assignment_action_id,
                       expired_value                = lb.expired_value,
                       expired_date                = lb.expired_date,
                       prev_assignment_action_id    = lb.prev_assignment_action_id,
                       prev_expiry_date                = lb.prev_expiry_date,
                       prev_balance_value           = lb.prev_balance_value
                   where latest_balance_id          = lb.latest_balance_id;
                end if;
             end if;
         end loop;
       end if;
      end loop;
      --
   end maintain_lat_bal;
--
-- this function retruns the assignment_action id of the
-- reversal that is being retried
-- the action passed is is the assignment action of the reversal

function get_retry_revesal_action_id(p_act_id number)
return number is

l_mst_id number;
new_assactid number;
found number;
begin

-- determine the master action
   SELECT pai.locked_action_id
   INTO   l_mst_id
   FROM   pay_action_interlocks pai,pay_assignment_actions paa
   WHERE  pai.locking_action_id = p_act_id
   AND    paa.assignment_action_id = pai.locked_action_id
   AND    paa.source_action_id is null;

   select 1
   into found
   from dual
   where exists (select 1 from pay_assignment_actions paa
   where paa.source_action_id=l_mst_id);

   begin
   -- if there is no run for that interlocok cacluate

   -- what the new assignment action should be
      select child_asg.assignment_action_id
      into new_assactid
      from pay_assignment_actions mast_asg,
           pay_assignment_actions child_asg,
           pay_assignment_actions rev_asg
      where l_mst_id=mast_asg.assignment_action_id
      and child_asg.source_action_id is not null
      and child_asg.assignment_id=mast_asg.assignment_id
      and child_asg.payroll_action_id=mast_asg.payroll_action_id
      and child_asg.action_status<>'B'
      and pay_core_utils.get_process_path(child_asg.assignment_action_id)
                         =rev_asg.process_path
      and rev_asg.assignment_action_id=p_act_id;

      return new_assactid;

    exception
           when no_data_found then
             return -9999;

           when too_many_rows then
            hr_utility.set_message(801,'HR_34864_INTERLOCK_ERR_REV');
            hr_utility.raise_error;

    end;

exception
  when no_data_found then
     return l_mst_id;

end;
--
end hrassact;

/
