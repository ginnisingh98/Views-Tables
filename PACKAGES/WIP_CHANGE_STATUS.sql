--------------------------------------------------------
--  DDL for Package WIP_CHANGE_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_CHANGE_STATUS" AUTHID CURRENT_USER AS
 /* $Header: wippcsts.pls 120.1 2007/10/15 22:59:52 kkonada ship $ */


/* INSERT_PERIOD_BALANCES
   This procedure inserts accounting records into WIP_PERIOD_BALANCES for an
   acive job or schedule.  No validation is done on any information passed
   into this routine.  If you are calling RELEASE or PUT_JOB_ON_HOLD, you do
   not need to call this procedure.
*/

  PROCEDURE INSERT_PERIOD_BALANCES
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_repetitive_schedule_id NUMBER,
     P_line_id NUMBER,
     P_class_code VARCHAR2,
     P_release_date DATE DEFAULT SYSDATE);


/* CHECK_REPETITIVE_ROUTING
   This procedure verifies that the routing of a current schedule matches the
   routings of all other transactable schedules for the repetitive
   assembly on the line.  You do not need to call this routine if you are
   calling RELEASE or PUT_JOB_ON_HOLD in this package.

 PRE: The routing for the repetitive schedule should have already been
   exploded.  The repetitive schedule may or may not have been released when
   you call this.

 PARAMETERS: No validation is done on the parameters.
*/

  PROCEDURE CHECK_REPETITIVE_ROUTING
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_repetitive_schedule_id NUMBER,
     P_line_id NUMBER);


/* RELEASE
   This procedure updates the tables WIP_OPERATIONS and WIP_PERIOD_BALANCES
   when a job or schedule is released.  For a repetitive schedule, the
   procedure CHECK_REPETITIVE_ROUTING is called.  This routine does not update
   the parent record.

 PRE: The routing must have already been exploded.

 PARAMETERS:
   * P_old_status_type is the previous status
   * P_new_status_type is the status being changed to.  The statuses are
     validated to insure that you are changing from an non-released status to
     a released status.
   * No other validation is performed on the input parameters.
   * P_routing_exists indicates whether the job or schedule has a routing.
     It's values can be WIP_CONSTANTS.YES or WIP_CONSTANTS.NO.
*/

  PROCEDURE RELEASE
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_repetitive_schedule_id NUMBER,
     P_line_id NUMBER,
     P_class_code VARCHAR2,
     P_old_status_type NUMBER,
     P_new_status_type NUMBER,
     P_routing_exists OUT NOCOPY NUMBER,
     P_release_date DATE DEFAULT SYSDATE); /* fix for bug 2424987 */


/* PUT_JOB_ON_HOLD
 DESCRIPTION:
   This procedure places a job on hold.  The following validations are
   performed.  If any of the validations fail, an appropriate message is placed
   on the message stack and an exception is raised.
    * The job must have a status of Unreleased, Released, Complete, or Hold.
      If the job is already on hold, nothing happens.
 PARAMETERS:
    * No validation is performed on the input parameters.
*/

  PROCEDURE PUT_JOB_ON_HOLD
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER);


/* PUT_LINE_ON_HOLD
 DESCRIPTION:
   This procedure puts all active schedules (released, complete, and hold) for
   an assembly on a line on hold.  The following validations are performed.  If
   any of the validations fail, an appropriate message is placed on the message
   stack and an exception is raised.
    * There must be at least one active schedule for the assembly on the line.
      For schedules on hold, nothing happens.
 PARAMETERS:
   No validation is performed on the input parameters.
*/

  PROCEDURE PUT_LINE_ON_HOLD
    (P_wip_entity_id NUMBER,
     P_line_id NUMBER,
     P_organization_id NUMBER);

 /* wrapper over procedure Release()
 This also updates the status of job to Release in the databse at the end
 */
 PROCEDURE RELEASE_MES_WRAPPER
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER
    );

END WIP_CHANGE_STATUS;

/
