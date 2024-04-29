--------------------------------------------------------
--  DDL for Package PAY_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PURGE_PKG" AUTHID CURRENT_USER as
/* $Header: pypurge.pkh 120.2.12010000.1 2008/07/27 23:29:40 appldev ship $ */
/*
   +======================================================================+
   |                Copyright (c) 2000 Oracle Corporation                 |
   |                   Redwood Shores, California, USA                    |
   |                        All rights reserved.                          |
   +======================================================================+
   Package Header Name :    PAY_PURGE_PKG
   Package File Name   :    pypurge.pkh

   Description : Declares procedures for Purge functionality.

   Change List:
   ------------

   Name           Date         Version Bug     Text
   -------------- ------------ ------- ------- ----------------------------
   T. Habara      03-APR-2006  115.7   5131274 Added pypu1_validate_asg.
   T. Habara      17-MAR-2006  115.6   5089841 Added init_pact,bal_exists.
   D. Saxby       05-DEC-2002  115.5   2692195 Nocopy changes.
   D. Saxby       18-NOV-2000  115.4           GSCC standards fix.
   D. Saxby       14-NOV-2000  115.3           Added procedure pypurgbv.
   D. Saxby       08-NOV-2000  115.2           Added dbdrv line.
   D. Saxby       12-DEC-2000  115.1           Added pypurcif.
   D. Saxby       12-DEC-2000  115.0           Initial Version
   ========================================================================
*/

type ctx_rec is record
(
   context_id     number,
   context_name   varchar2(30),
   context_value  varchar2(60)
);

type ctx_cur_t is ref cursor return ctx_rec;

/*--------------------------------- validate --------------------------------*/
/*
   NAME
      validate - validate purge date and reporting date.
   DESCRIPTION
      This procedure is called from the main purge process
      and is used to validate that the purge date as passed
      to the routine is acceptable.  If not, an error is
      raised from the procedure and this will be reported
      by the purge code.
*/

procedure validate
(
   p_balance_set_id     in number default null,
   p_assignment_set_id  in number default null,
   p_business_group_id  in number,
   p_reporting_date     in date,
   p_purge_date         in date
);

procedure phase_two_checks
(
   p_payroll_action_id in number
);

procedure open_ctx_cur
(
   p_ctx_cursor    in out nocopy ctx_cur_t,
   p_assignment_id in     number,
   p_purge_date    in     date,
   p_select_type   in     varchar2
);

/*-------------------------------- pypu2uacs --------------------------------*/
/*
   NAME
      pypu2uacs - Purge Phase 2 Update Action Sequence.
   DESCRIPTION
      Update the action_sequence of the balance initialization
      actions inserted for the balance rollup.
*/

procedure pypu2uacs
(
   p_batch_id        in number,
   p_action_sequence in number      -- of current Purge action.
);

/*--------------------------------- pypurgbv --------------------------------*/
/*
   NAME
      pypurgbv - Purge Get Balance Value.
   DESCRIPTION
      Cover routine to pay_balance_pkg.get_value (assignment action mode).

      Because some balances need time_period_id stamped on the user and
      owner payroll actios, Purge is forced to insert a payroll and
      assignment action before calling get_value.

      Something similar is done within pay_balance_pkg.get_value
      for date mode, but purge has the unique requirement that the
      action_sequence of the assignment action is the same value as
      the parent purge action passed to the routine.  This avoids the
      need to shuffle actions.

      The UK makes particularly heavy use of these types of dimensions,
      for instance, _ASG_TD_YTD, _ASG_YTD and many others.
*/

procedure pypurgbv
(
   p_defined_balance_id   in  number,
   p_assignment_action_id in  number,
   p_balance_value        out nocopy number,
   p_nonzero_flag         out nocopy binary_integer
);

/*-------------------------------- pypu2vbr ---------------------------------*/
/*
   NAME
      pypu2vbr - Purge Phase 2 Validate Balance Rollup.
   DESCRIPTION
      Following balance rollup, attempts to verify that
      the values are as expected.

      The calling of this validation is switchable from
      the PURGE_VALIDATE_ROLLUP action parameter.
*/

procedure pypurvbr
(
   p_assignment_action_id in number
);

/*-------------------------------- pypurcif ---------------------------------*/
/*
   NAME
      pypurcif - Purge Phase 2 Create Initial Feeds
   DESCRIPTION
      Procedure creates the initial balance feeds that are required
      for balance rollup.
*/

procedure pypurcif
(
   p_balance_set_id    in number,
   p_business_group_id in number,
   p_legislation_code  in varchar2
);

/*------------------------------- init_pact -------------------------------*/
/*
   NAME
      init_pact - Purge Phase 1. Initialize Payroll Action
   DESCRIPTION
      This procedure initializes the Purge payroll action cache.

*/

procedure init_pact
(
   p_purge_action_id   in number -- Purge Payroll Action ID
)
;

/*------------------------------- bal_exists -------------------------------*/
/*
   NAME
      bal_exists - Purge Phase 1. Balance Existence Check.
   DESCRIPTION
      This function checks to see if there are any assignments processed
      in the Purge Process that could have a value for the specified balance.

*/

function bal_exists
(
   p_purge_action_id   in number, -- Purge Payroll Action ID
   p_balance_type_id   in number
) return varchar2
;

/*--------------------------- pypu1_validate_asg ---------------------------*/
/*
   NAME
      pypu1_validate_asg - Purge Phase 1. Validate Assignment
   DESCRIPTION
      This procedure validates the assignment on the purge date.

*/

procedure pypu1_validate_asg
(
   p_assignment_action_id   in number
)
;

end pay_purge_pkg;

/
