--------------------------------------------------------
--  DDL for Package HR_NONRUN_ASACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NONRUN_ASACT" AUTHID CURRENT_USER as
/* $Header: pynonrun.pkh 120.0.12010000.1 2008/07/27 23:14:26 appldev ship $ */
--
/*
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Name        : hr_nonrun_asact

   Description : Non payroll run assignment action processing.

   Test List
   ---------
   Procedure                     Name       Date        Test Id Status
   +----------------------------+----------+-----------+-------+--------------+
   hr_nonrun_asact               dsaxby     00-DEC-0000         ---------.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   23-FEB-2004  NBRISTOW    115.12          Added the get_next chunk procedures
   16-DEC-2003  NBristow    115.11          Changed parameters to the insact
                                            procedure.
   20-AUG-2003  RThirlby    115.10          Added new procedure
                                            ins_additional_asg_action.
   06-JAN-2003  alogue      115.8  2734876  Pass use_pop_person variable to assact.
   19-AUG-2002  kkawol      115.35          Added start_date and end_date to insact.
   23-JUL-2002  NBRISTOW    115.6           Added object type and id to
                                            pay_assignment_actions.
   24-JAN-2002  TBATTOO     115.4           Changes for multi asg prepayments
   05-SEP-2001  NBRISTOW    115.3           Added source_ation_id to insact.
   24-AUG-2001  ALOGUE      115.2           Pass p_actype to reinterlock.
   19-MAY-2000  NBRISTOW    115.1           Added reinterlock.
   05-AUG-1998  NBRISTOW    110.2           Added insint.
   06-MAY-1998  NBRISTOW    40.4            Added insact, so that legislations
                                            can call this function for the
                                            Archiver coding.
   22-MAR-1993  DSAXBY      3.6             Added processing for QuickPaint.
   08-JAN-1993  DSAXBY      3.5             Add restrictions by date_earned.
   06-JAN-1993  DSAXBY      3.4             Mistake in sql statements.
   05-JAN-1993  DSAXBY      3.3             Further change to sql.
   05-JAN-1993  DSAXBY      3.2             Used PAY_ACTION_CLASSIFICATIONS.
   18-DEC-1992  DSAXBY      3.1             Altered range row where clause.
   02-DEC-1992  DSAXBY      3.0             First created.
*/
   ---------------------------get_next_pop_chunk----------------------------
   /*
      NAME
         get_next_pop_chunk - Get the Next Popultaion chunk to process
      DESCRIPTION
         Locks and returns person range information from
         pay_population_ranges. This is used to insert
         a chunk of assignments at a time.
      NOTES
         <none>
   */
   procedure get_next_pop_chunk
   (
      pactid      in            number,   -- payroll_action_id.
      atype       in            varchar2, -- action type.
      p_lckhandle in            varchar2, -- dbms_lock id
      lub         in            varchar2, -- last_updated_by.
      lul         in            varchar2, -- last_update_login.
      chunk_type  in out nocopy varchar2, -- method for allocating chunk
      threads     in            number   default 1, -- Number of Threads
      slave_no    in            number   default 1, -- Slave no
      curr_chunk  in            number   default 1, -- current chunk
      max_chunks  in            number   default 9999, -- Max no of Chunks
      stperson       out nocopy number,  -- starting_person_id.
      endperson      out nocopy number,  -- ending_person_id.
      chunk          out nocopy number,  -- chunk_number.
      rand_chunk     out nocopy number   -- chunk_number.
   );
--
   ---------------------------get_next_proc_chunk----------------------------
   /*
      NAME
         get_next_proc_chunk - Get the Next Process chunk to process
      DESCRIPTION
         Locks and returns person range information from
         pay_population_ranges. This is used to insert
         a chunk of assignments at a time.
      NOTES
         There is a COMMIT in this procedure to release
         the locks and update tables.
   */
   procedure get_next_proc_chunk
   (
      pactid      in            number,   -- payroll_action_id.
      chunk_type  in out nocopy varchar2, -- method for allocating chunk
      threads     in            number   default 1, -- Number of Threads
      slave_no    in            number   default 1, -- Slave no
      curr_chunk  in out nocopy number    -- current chunk
   );
--
   ----------------------------------- asact ----------------------------------
   /*
      NAME
         asact - insert assignment actions and interlocks
      DESCRIPTION
         Overall control of the insertion of assignment actions
         and interlocks for the non run payroll actions.
      NOTES
         <none>
   */
   procedure asact
   (
      pactid in number,   -- payroll_action_id
      atype  in varchar2, -- action_type.
      itpflg in varchar2, -- time dependent legislation flag
      ptype  in number,   -- payment_type_id.
      lub    in varchar2, -- last_updated_by.
      lul    in varchar2, -- last_update_login.
      use_pop_person in number -- use population_ranges person_id column
   );
--
   ---------------------------------- insact ----------------------------------
   /*
      NAME
         insact - insert assignment action row.
      DESCRIPTION
         inserts row into pay_assignment_actions. Does not commit.
      NOTES
         <none>
   */
   procedure insact
   (
      lockingactid in number,                -- locking_action_id.
      assignid     in number default null,   -- assignment_id
      pactid       in number,                -- payroll_action_id
      chunk        in number,                -- chunk_number
      greid        in number default null,   -- GRE id.
      prepayid     in number   default null, -- pre_payment_id.
      status       in varchar2 default 'U',  -- action_status.
      source_act   in number default null,   -- source_action_id
      object_id    in number default null,   -- object id
      object_type  in varchar2 default null, -- object type
      start_date   in date default null,     -- start date
      end_date     in date default null,     -- end date
      p_transient_action in boolean default false -- Transient Action
   );
   ---------------------------------- insint ----------------------------------
   /*
      NAME
         insint - insert interlock row.
      DESCRIPTION
         Simply inserts an interlock row. Does not commit.
      NOTES
         <none>
   */
   procedure insint
   (
      lockingactid in number,
      lockedactid  in number
   );
   ---------------------------------- reinterlock  ----------------------------------
   /*
      NAME
         reinterlock - Re Inserts Interlocks.
      DESCRIPTION
         Simply re inserts interlock rows. Based on the primary (master) interlocked
         action.
      NOTES
         <none>
   */
   procedure reinterlock
   (
      p_assact number,
      p_actype varchar2 default 'U'
   );
-----------------------------------------------------------------------------
-- Name: ins_additional_asg_action
-- Desc: Insert an assignment action to an already existing payroll action.
-----------------------------------------------------------------------------
Procedure ins_additional_asg_action(p_asg_id      number   default null
                                   ,p_pact_id     number
                                   ,p_gre_id      number   default null
                                   ,p_object_id   number   default null
                                   ,p_object_type varchar2 default null
                                   );
-----------------------------------------------------------------------------
end hr_nonrun_asact;

/
