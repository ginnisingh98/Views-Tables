--------------------------------------------------------
--  DDL for Package WIP_OSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OSP" AUTHID CURRENT_USER AS
 /* $Header: wipospvs.pls 120.3.12010000.4 2010/02/01 08:11:58 pfauzdar ship $ */

  /* RELEASE_VALIDATION

     This routine checks if there are outside processing resources at
     the first operation of the routing for the job or schedule identified
     by the parameters.  If so, it selects that operation_seq_num and
     the outside processing account of the job or schedule, and calls
     the CREATE_REQUISITION routine.
   */

  PROCEDURE RELEASE_VALIDATION
    (P_Wip_Entity_Id NUMBER,
     P_Organization_id NUMBER,
     P_Repetitive_Schedule_Id NUMBER);

  /* CREATE_REQUISITION

     This routine does validation to make sure that outside processing
     is allowed at the operation specified in P_Operation_Seq_Num.
     Specifically, it raises an error if the User Id running the process
     is not an employee or if the outside processing operation department
     has no location specified.

     If no error is raised, then a record is inserted into
     PO_REQUISITIONS_INTERFACE.

     Arguments:
        P_Wip_Entity_Id,                These identify the job or schedule
        P_Organization_Id,
        P_Repetitive_Schedule_Id

        P_Operation_Seq_Num             The operation that we are moving
                                        to (or the first op for Release)

        P_Outside_Proc_Acct             Account of the job/schedule, needed
                                        to create the interface record.

        P_Line_Id                       Line attached to the Repetitive Schedule
                                        This is null for Discrete Jobs
  */

  PROCEDURE CREATE_REQUISITION(
      P_Wip_Entity_Id NUMBER,
      P_Organization_Id NUMBER,
      P_Repetitive_Schedule_Id NUMBER,
      P_Operation_Seq_Num NUMBER,
      P_Resource_Seq_Num IN NUMBER DEFAULT NULL,
      P_Run_ReqImport IN NUMBER DEFAULT WIP_CONSTANTS.NO);

 /* CREATE_ADDITIONAL_REQ
    Create Additional PO requisitions

    This Procedure is called only when the job quantity is increased.
    This procedure sets the P_added_quantity to the global variable
    additional_quantity. If the additional_quantity value is > 0 then
    an addtional requisition is created for the increased job quantity */

  PROCEDURE CREATE_ADDITIONAL_REQ
    (P_Wip_Entity_Id NUMBER,
     P_Organization_id NUMBER,
     P_Repetitive_Schedule_Id NUMBER,
     P_Added_Quantity NUMBER,
     P_Op_Seq NUMBER default null);

  FUNCTION PO_REQ_EXISTS ( p_wip_entity_id      in      NUMBER
                          ,p_rep_sched_id       in      NUMBER
                          ,p_organization_id    in      NUMBER
                          ,p_op_seq_num         in      NUMBER default NULL
                          ,p_entity_type        in      NUMBER
                         ) RETURN BOOLEAN;


  /* ConvertToPrimaryMoveQty

     Converts the quantity that is put on the purchase order to the
     PRIMARY quantity to be moved for the assembly being built.

     Arguments:
        p_item_id :     the OSP item that is put on the purchase order
        p_organization_id :
        p_quantity :    the quantity that is on the purchase order
        p_uom_code :    the unit of measure that is on the purchase order
        p_usage_rate_or_amount : the usage_rate_or_amount for the resource that
                        the OSP item is attached to; this is required when
                        the OSP item is of type RESOURCE
  */


  FUNCTION ConvertToPrimaryMoveQty (p_item_id           NUMBER,
                                p_organization_id       NUMBER,
                                p_quantity              NUMBER,
                                p_uom_code              VARCHAR2,
                                p_primary_uom_code      VARCHAR2,
                                p_usage_rate_or_amount  NUMBER) RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(ConvertToPrimaryMoveQty,WNDS,WNPS);


  FUNCTION IS_ORDER_OPEN (
        approved_flag        in VARCHAR2 DEFAULT NULL,
        closed_code          in VARCHAR2 DEFAULT NULL,
        line_closed_status   in VARCHAR2 DEFAULT NULL,
        cancel_flag          in VARCHAR2 DEFAULT NULL,
        frozen_flag          in VARCHAR2 DEFAULT NULL,
        user_hold_flag       in VARCHAR2 DEFAULT NULL,
        line_expiration_date in DATE     DEFAULT NULL,
        line_cancel_flag     in VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(IS_ORDER_OPEN,WNDS,WNPS);


  PROCEDURE ARE_QA_PLANS_AVAILABLE(
   P_AssemblyItemNumber      IN  VARCHAR2 DEFAULT NULL,
   P_VendorName              IN  VARCHAR2 DEFAULT NULL,
   P_WipEntityName           IN  VARCHAR2 DEFAULT NULL,
   P_BasePoNum               IN  VARCHAR2 DEFAULT NULL,
   P_SupplierItemNumber      IN  VARCHAR2 DEFAULT NULL,
   P_AssemblyPrimaryUom      IN  VARCHAR2 DEFAULT NULL,
   P_Uom                     IN  VARCHAR2 DEFAULT NULL,
   P_WipLineCode             IN  VARCHAR2 DEFAULT NULL,
   P_BomRevision             IN  VARCHAR2 DEFAULT NULL,
   P_StartDate               IN  DATE     DEFAULT NULL,
   P_PoReleaseNumber         IN  NUMBER   DEFAULT NULL,
   P_OrganizationId          IN  NUMBER   DEFAULT NULL,
   P_WipEntityType           IN  NUMBER   DEFAULT NULL,
   P_WipEntityId             IN  NUMBER   DEFAULT NULL,
   P_WipRepetitiveScheduleId IN  NUMBER   DEFAULT NULL,
   P_ResourceSeqNum          IN  NUMBER   DEFAULT NULL,
   P_ItemId                  IN  NUMBER   DEFAULT NULL,
   P_AssemblyItemId          IN  NUMBER   DEFAULT NULL,
   P_WipOperationSeqNum      IN  NUMBER   DEFAULT NULL,
   R_QaAvailable             OUT NOCOPY VARCHAR2);

 /**
  * This function validates the from op and to op for the user relating to
  * OSP operation steps.  The follow rules apply to OSP:
  *   -  Users cannot move into a Queue of an OSP operation unless that
  *      department has a location setup.
  *   -  Users cannot move forward into a queue of an operation that has
  *      PO resource unless the user is an employee
  * The error message for the first case would be WIP_PO_MOVE_LOCATION and
  * WIP_VALID_EMPLOYEE for the second case.
  * Parameters:
  *   p_orgID         The organization identifier.
  *   p_wipEntityID   The wip entity identifier.
  *   p_lineID        The line id used only for repetitive schedule. For
  *                   discrete and lotbased, do not need to pass this value.
  *   p_entityType    The wip entity type. (usually discrete)
  *   p_fmOpSeqNum    The from operation sequence number that user is moving.
  *   p_toOpSeqNum    The to operation sequence number that user is moving.
  *   p_toStep        The to intraoperation step that user is moving to.
  *   p_userID        The user identifier.
  *   x_msg           The error message name before translation
  *   x_error         The error message after translation for displaying
  *                   to user.
  * Return:
  *   boolean     A flag indicating whether update successful or not.
  */
  FUNCTION checkOSP(p_orgID             NUMBER,
                    p_wipEntityID       NUMBER,
                    p_lineID            NUMBER := NULL,
                    p_entityType        NUMBER,
                    p_fmOpSeqNum        NUMBER,
                    p_toOpSeqNum        NUMBER,
                    p_toStep            NUMBER,
                    p_userID            NUMBER,
                    x_msg           OUT NOCOPY VARCHAR2,
                    x_error         OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

 /**
  * This procedure will pickup all PO/requisitions associated to the jobs
  * based on the criteria used provided, then call updatePOReqNBD procedure
  * to update PO/requisition need-by date. This procedure will be called from
  * Update PO need-by date concurrent program.
  *
  * Parameters:
  *   errbuf             Error messages that will be displayed in concurrent
  *                      program log file
  *   retcode            Return status of this procedure
  *                        0 - success
  *                        1 - warning
  *                        2 - error
  *   p_project_id       Project that user want to update PO/requisition NBD
  *   p_task_id          Task that user want to update PO/requisition NBD
  *   p_days_forward_fm  Number of days forward that user want us to start
  *                      updating PO/requisition NBD
  *   p_days_forward_to  Number of days forward that user want us to stop
  *                      updating PO/requisition NBD
  *   p_org_id           Organization identifier.
  *   p_entity_type      The wip entity type.
  *
  */
  PROCEDURE updatePOReqNBDManager(errbuf            OUT NOCOPY VARCHAR2,
                                  retcode           OUT NOCOPY NUMBER,
                                  p_project_id      IN         NUMBER,
                                  p_task_id         IN         NUMBER,
                                  p_days_forward_fm IN         NUMBER,
                                  p_days_forward_to IN         NUMBER,
                                  p_org_id          IN         NUMBER,
                                  p_entity_type     IN         NUMBER);

 /**
  * This procedure will update PO/requisition need-by date.
  *
  * Parameters:
  *   p_po_header_id        PO header ID (Standard PO)
  *   p_po_release_id       Release ID (Blanket)
  *   p_po_line_location_id Line location ID (shipment level)
  *   p_req_header_id       Requisition header ID (requisition)
  *   p_req_line_id         Requisition line ID (requisition)
  *   p_po_req_type         Type of document('STANDARD','BLANKET',
  *                         'REQUISITION')
  *   p_approval_status     Document approval status
  *   p_new_NBD             new need-by date
  *   x_return_status       There are 2 possible values
  *                         *fnd_api.g_ret_sts_success*
  *                          means all po/requisition get updated successfully
  *                         *fnd_api.g_ret_sts_unexp_error*
  *                          means an exception occurred
  *
  */
  PROCEDURE updatePOReqNBD(p_po_header_id         IN         NUMBER,
                           p_po_release_id        IN         NUMBER,
                           p_po_line_location_id  IN         NUMBER,
                           p_req_header_id        IN         NUMBER,
                           p_req_line_id          IN         NUMBER,
                           p_po_req_type          IN         VARCHAR2,
                           p_approval_status      IN         VARCHAR2,
                           p_new_NBD              IN         DATE,
                           p_ou_id                IN         NUMBER,
                           x_return_status        OUT NOCOPY VARCHAR2);


 /**
  * This procedure will update PO/requisition quantity..
  *
  * Parameters:
  *   p_job_id           WIP_ENTITY_ID
  *   p_repetitive_id    REPETITIVE_SCHEDULE_ID
  *   p_org_id           ORGANIZATION_ID
  *   p_changed_qty      Quantity of assembly that need to be changed, not PO
  *                      quantity. Pass positive for increase, and negative
  *                      for decrease case. For example, if user change job
  *                      quantity from 10 to 12, pass 2 as p_changed_qty.
  *   p_fm_op            We will update PO/requisition associated to the
  *                      operation greater than p_fm_op.
  *                      quantity. This parameter is useful for scrap, unscrap
  *                      and overmove case. We should not update all PO/req
  *                      associated to the job. Instead, we should update only
  *                      the one affected by these transactions
  *  p_is_scrap_txn      Added for bug 4734309: Pass WIP_CONSTANTS.YES when
  *                      calling  from scrap processor. For scrap transactions, only PO/REQs
  *                      connected to future operations will be affected.
  *   x_return_status    There are 2 possible values
  *                        *fnd_api.g_ret_sts_success*
  *                        means all po/requisition get updated successfully
  *                        *fnd_api.g_ret_sts_unexp_error*
  *                        means an exception occurred
  *
  */
  PROCEDURE updatePOReqQuantity(p_job_id        IN         NUMBER,
                                p_repetitive_id IN         NUMBER := NULL,
                                p_org_id        IN         NUMBER,
                                p_changed_qty   IN         NUMBER,
                                p_fm_op         IN         NUMBER,
                                p_is_scrap_txn  IN         NUMBER := NULL,
                                x_return_status OUT NOCOPY VARCHAR2);

  /**
  * This procedure will update PO/requisition quantity..
  *
  * Parameters:
  *   p_job_id           WIP_ENTITY_ID
  *   p_repetitive_id    REPETITIVE_SCHEDULE_ID
  *   p_org_id           ORGANIZATION_ID
  *   p_op_seq_num       Operation that we have to cancel PO/requisition.
  *                      This parameter is useful if user want to cancel only
  *                      PO/requisition for a specific operation.
  *   x_return_status    There are 2 possible values
  *                        *fnd_api.g_ret_sts_success*
  *                        means all po/requisition get updated successfully
  *                        *fnd_api.g_ret_sts_unexp_error*
  *                        means an exception occurred
  *
  */
  PROCEDURE cancelPOReq(p_job_id        IN         NUMBER,
                        p_repetitive_id IN         NUMBER := NULL,
                        p_org_id        IN         NUMBER,
                        p_op_seq_num    IN         NUMBER := NULL,
                        x_return_status OUT NOCOPY VARCHAR2,
  		        p_clr_fnd_mes_flag IN      VARCHAR2 DEFAULT NULL);  -- added parameter p_clr_fnd_mes_flag for
                                                                            -- bugfix 7415801
                          -- Bug fix 8681037: Changed the default value from 'N' to NULL for p_clr_fnd_mes_flag parameter
 	                  -- as per the standards.


 /* Fix for bug 4446607: This function returns TRUE if a PO/REQ is ever
  * created for this particular job/operation, irrespective of whether the
  * PO/REQ is cancelled or closed. This will be used to determine whether
  * to call release_validation when rescheduling the job through mass-load.
  * We had been using PO_REQ_EXISTS but that would return FALSE if either
  * the PO/REQ is cancelled or if all the quantity is received for the PO.
  * Because of this, requisition creation was erroneously triggered when
  * rescheduling a job, whose associated PO has been received in total.
  */
  FUNCTION PO_REQ_created ( p_wip_entity_id      in      NUMBER
                           ,p_rep_sched_id       in      NUMBER
                           ,p_organization_id    in      NUMBER
                           ,p_op_seq_num         in      NUMBER default NULL
                           ,p_entity_type        in      NUMBER
                          ) RETURN BOOLEAN;

END WIP_OSP;

/
