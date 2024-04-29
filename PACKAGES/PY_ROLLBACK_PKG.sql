--------------------------------------------------------
--  DDL for Package PY_ROLLBACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ROLLBACK_PKG" AUTHID CURRENT_USER as
/* $Header: pyrolbak.pkh 120.0.12010000.1 2008/07/27 23:33:53 appldev ship $ */
/*
 Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
 Change List
 ===========

 Version Date       Author    ER/CR No. Description of Change
 -------+---------+----------+---------+-------------------------------
 115.2   05/12/03  NBRISTOW             Added p_grp_multi_thread to
                                        rollback procedures.
 40.3    30/07/96  JALLOUN              Added error handling.
 40.2    23/06/95  DSAXBY               New p_limit_dml parameter.
 40.1    23/06/95  DSAXBY               Fix 290059 : new parameters added to
                                        rollback_ass_action procedure.
 40.0    15/06/95  DSAXBY               First created.
 ----------------------------------------------------------------------
*/
/*------------------------  ins_rollback_message ----------------------------*/
/*
  NAME
    ins_rollback_message - insert rollback message.
  DESCRIPTION
    inserts confirmatory message into pay_message_lines.
  NOTES
    This procedure deals with the fact that Magnetic
    Transfer is generic name, and chooses the correct
    name depending on the Payment Type.
    Needs to be callable from the batch process.
*/
procedure ins_rollback_message(p_payroll_action_id in number);
--
/*----------------------  rollback_payroll_action ---------------------------*/
/*
  NAME
    rollback_payroll_action - undo work for payroll action.
  DESCRIPTION
    performs rollback/mark for retry on payroll action.
  NOTES
    This procedure is the entry point to be called to rollback
    or mark for retry a payroll action. The function will
    attempt to process all the assignment actions, continuing
    on failure until the error limit is reached. Messages are
    written to the message lines table.
--
    The parameters are used as follows:
      p_payroll_action_id :
         identifies the row to be processed.
--
      p_rollback_mode :
         either 'ROLLBACK', 'RETRY' or 'BACKPAY'.
--
      p_leave_base_table_row :
         if this is true, the procedure does not attempt to update/delete the
         payroll action row. It leaves this to the client. Normally, this
         means a form. However, a message IS inserted by the procedure.
         if false, the procedure update/deletes the payroll action before
         exiting.  Must set this to true if rollback mode is set to 'TRUE'.
--
      p_all_or_nothing :
         when TRUE, the entire rollback process will fail with the first error.
         when FALSE, the procedure will process all assignments it can, up to
         the error limit (set from action parameter or defaulted).
--
      p_dml_mode :
         one of the following:
         'FULL'      : all dml and commits.
         'NO_COMMIT' : all dml, no commit.
         'NONE'      : no dml or commits.
         This allows the user to specify a partial or full validation.
--
      p_multi_thread :
         this should only be set to true if being called from the
         multi-threaded version of rollback code (i.e. from pyr.lpc).
--
      p_limit_dml :
         if this is true, the procedure will limit the number of
         assignment actions that can be processed in a single commit
         unit. This is specified using MAX_SINGLE_UNDO action parameter.
--
      p_grp_multi_thread:-
         this is used to indicate which method to maintain the group
         level run balances.  This should be set to true when being
         called from a multi-threaded process. Some multi threaded
         processes use p_multi_thread set to false, hence
         p_grp_multi_thread was created to ensure that all multi threaded
         processes use the correct group run balance deletion.
*/
procedure rollback_payroll_action
(
   p_payroll_action_id    in number,
   p_rollback_mode        in varchar2 default 'ROLLBACK',
   p_leave_base_table_row in boolean  default false,
   p_all_or_nothing       in boolean  default true,
   p_dml_mode             in varchar2 default 'NO_COMMIT',
   p_multi_thread         in boolean  default false,
   p_limit_dml            in boolean  default false,
   p_grp_multi_thread     in boolean  default false
);
--
/*------------------------  rollback_ass_action -----------------------------*/
/*
  NAME
    rollback_ass_action - undo work for assignment action.
  DESCRIPTION
    performs rollback/mark for retry on assignment action.
  NOTES
    This procedure is the entry point to be called to rollback
    or mark for retry an assignment action. On failure, a
    message will be inserted in message lines, indicating that
    the assignment action could not be processed.
--
    The parameters are used as follows:
      p_payroll_action_id    :
         identifies the row to be processed.
--
      p_rollback_mode :
         either 'ROLLBACK', 'RETRY' or 'BACKPAY'.
--
      p_leave_base_table_row :
         if this is true, the procedure does not attempt to update/delete the
         assignment action row. It leaves this to the client. Normally, this
         means a form. However, a message IS inserted by the procedure.
         if false, the procedure update/deletes the assignment action before
         exiting.  Must set this to true if rollback mode is set to 'TRUE'.
--
      p_all_or_nothing :
         when TRUE, procedure fails immediately if error encountered, otherwise
         processes up to assignment level error limit. Latter is required by
         rollback by assignment set.
--
      p_dml_mode :
         one of the following:
         'FULL'      : all dml and commits.
         'NO_COMMIT' : all dml, no commit.
         'NONE'      : no dml or commits.
         This allows the user to specify a partial or full validation.
--
      p_multi_thread :
         this should only be set to true if being called from the
         multi-threaded version of rollback code (i.e. from pyr.lpc).
--
      p_grp_multi_thread:-
         this is used to indicate which method to maintain the group
         level run balances.  This should be set to true when being
         called from a multi-threaded process. Some multi threaded
         processes use p_multi_thread set to false, hence
         p_grp_multi_thread was created to ensure that all multi threaded
         processes use the correct group run balance deletion.
*/
procedure rollback_ass_action
(
   p_assignment_action_id in number,
   p_rollback_mode        in varchar2 default 'ROLLBACK',
   p_leave_base_table_row in boolean  default false,
   p_all_or_nothing       in boolean  default true,
   p_dml_mode             in varchar2 default 'NO_COMMIT',
   p_multi_thread         in boolean  default false,
   p_grp_multi_thread     in boolean  default false
);
--
end py_rollback_pkg;

/
