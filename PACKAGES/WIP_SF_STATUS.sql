--------------------------------------------------------
--  DDL for Package WIP_SF_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SF_STATUS" AUTHID CURRENT_USER AS
 /* $Header: wipsfsts.pls 120.1 2005/11/03 17:35:16 kboonyap noship $ */

/* INSERT_STATUS
 * Inserts a status into wip_shop_floor_statuses.  This procedure
 * does no validation
 */

  PROCEDURE INSERT_STATUS
    (P_wip_entity_id            IN      NUMBER,
     P_organization_id          IN      NUMBER,
     P_line_id                  IN      NUMBER,
     P_operation_seq_num        IN      NUMBER,
     P_intraoperation_step_type IN      NUMBER,
     P_shop_floor_status        IN      VARCHAR2);


/* DELETE_STATUS
 * Inserts a status into wip_shop_floor_statuses.  This procedure
 * does no validation
 */

  PROCEDURE DELETE_STATUS(
        P_wip_entity_id                 IN NUMBER,
        P_organization_id               IN NUMBER,
        P_line_id                       IN NUMBER,
        P_operation_seq_num             IN NUMBER,
        P_intraoperation_step_type      IN NUMBER,
        P_shop_floor_status             IN VARCHAR2);

/* ATTACH
   This function attaches a shop floor status to a step of an operation.  The
   following validations are performed.  If any of the validations fail, an
   appropriate message is placed on the message stack and an exception is
   raised.
     * For discrete jobs, the status must be Unreleased, Released, Complete, or
       On hold.
     * For repetitive assemblies, there must be at least one schedule on the
       line with status Unreleased, Released, Complete, or On hold.
     * The operation sequence must exist on the routing.
     * The intraopertion step must be enabled for the organization.
     * The shop floor status must be enabled.
   No other validations are performed (i.e. such as whether the operations
   really exists for the job or repetitive assembly).

 PARAMETERS: No other validation is done on the parameters.
   P_intraoperation_step_type should be one of he following:
     WIP_CONSTANTS.QUEUE, WIP_CONSTANTS.RUN, WIP_CONSTANTS.TOMOVE,
     WIP_CONSTANTS.REJECT, WIP_CONSTANTS.SCRAP
   P_line_id should be NULL if the status is being attached to a job.
*/

  PROCEDURE ATTACH
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_line_id NUMBER,
     P_operation_seq_num NUMBER,
     P_intraoperation_step_type NUMBER,
     P_shop_floor_status VARCHAR2);

/* CREATE_OSP_STATUS
 * Gets osp_shop_floor_status from wip_parameters, and gets line_id
 * from wip_repetitive_schedules.  Then calls Insert_Status.
 */

  FUNCTION GetOSPStatus (p_org_id       NUMBER) return VARCHAR2;

  PROCEDURE CREATE_OSP_STATUS(
        P_org_id                IN NUMBER,
        P_wip_entity_id         IN NUMBER,
        P_repetitive_sched_id   IN NUMBER DEFAULT NULL,
        P_operation_seq_num     IN NUMBER DEFAULT NULL
  );

/* REMOVE_OSP_STATUS
 * Gets osp_shop_floor_status from wip_parameters, and gets line_id
 * from wip_repetitive_schedules.  Then calls Delete_Status.
 */

  PROCEDURE REMOVE_OSP_STATUS(
        P_org_id                IN NUMBER,
        P_wip_entity_id         IN NUMBER,
        P_repetitive_sched_id   IN NUMBER DEFAULT NULL,
        P_operation_seq_num     IN NUMBER DEFAULT NULL
  );

/* COUNT_NO_MOVE_STATUSES
   This function returns the number of No Move shop floor statuses
   between the given From Operation and Intraoperation Step and the
   To Operation and Intraoperation Step.  Step types of scrap and reject
   are excluded from the count.  If the organization allows moves over
   no move statuses, then the count will be 0.

   This function is pragma'd with restrict_references so that it can be
   called in a SQL statement.
*/
  FUNCTION COUNT_NO_MOVE_STATUSES(
    p_org_id   in number,
    p_wip_id   in number,
    p_line_id  in number,
    p_sched_id in number,
    p_fm_op    in number,
    p_fm_step  in number,
    p_to_op    in number,
    p_to_step  in number,
    p_source_code in Varchar2 default null) return number;
   /* Added in bug 2121222 */

  pragma restrict_references (COUNT_NO_MOVE_STATUSES, WNDS, WNPS);

  /* This function returns the number of no move shop floor status at to move
     step of the last operation. This function will return either 1 or 0. If
     a job does not have routing, this API will return 0.
   */
  FUNCTION count_no_move_last_step(
    p_org_id IN NUMBER,
    p_wip_id IN NUMBER) RETURN NUMBER;

END WIP_SF_STATUS;

 

/
