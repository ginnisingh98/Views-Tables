--------------------------------------------------------
--  DDL for Package WIP_FLOWUTIL_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_FLOWUTIL_PRIV" AUTHID CURRENT_USER as
/* $Header: wipfscms.pls 120.6.12000000.1 2007/01/18 22:15:42 appldev ship $ */

  /**
   * This is to derive and validate the flow interface records for the given
   * header id.
   */
  procedure processFlowInterfaceRecords(p_txnHeaderID in number);



  /**
   * This procedure explodes the BOM and insert the material requirement into
   * mti table under the given header id and parent id.
   * If the supply subinv and locator in the BOM is not provided, then it will try
   * to default those the rule: BOM level --> item level --> wip parameter
   */
  procedure explodeRequirementsToMTI(p_txnHeaderID     in  number,
                                     p_parentID        in  number,
                                     p_txnTypeID       in  number,
                                     p_assyID          in  number,
                                     p_orgID           in  number,
                                     p_qty             in  number,
                                     p_altBomDesig     in  varchar2,
                                     p_altOption       in  number,
                                     p_bomRevDate      in  date default NULL,
                                     p_txnDate         in  date,
                                     p_projectID       in  number,
                                     p_taskID          in  number,
                                     p_toOpSeqNum      in  number,
                                     p_altRoutDesig    in  varchar2,
                                     p_txnMode         in  number,
                                     p_lockFlag        in  number := null,
                                     p_txnSourceID     in  number := null,
                                     p_acctPeriodID    in  number := null,
                                     p_cplTxnID        in  number := null,
                                     p_txnBatchID      in  number := null,
                                     p_txnBatchSeq     in  number := null,
      /* Fix for bug#5262858 */      p_defaultPushSubinv in varchar2 default null,
                                     x_returnStatus    out NOCOPY varchar2,
      /*Fix for bug 5630078 */       x_nontxn_excluded out NOCOPY varchar2);

  /**
   * This procedure creates an entry in wip_flow_schedules and wip_entities for
   * unscheduled work orderless completion. Those entries are needed for the
   * following resource and material transactions.
   * Pass p_txnInterfaceID to insert into WFS based on MTI, pass p_txnTmpID
   * to insert into WFS based on MMTT
   */
  procedure createFlowSchedule(p_txnInterfaceID    in  number := null,
                               p_txnTmpID          in  number := null,
                               x_returnStatus  out NOCOPY varchar2,
                               x_wipEntityID   out nocopy number);

  /**
   * This procedure performs the update to wip flow schedule.
   */
  procedure updateFlowSchedule(p_txnTempID    in  number,
                               x_returnStatus  out NOCOPY varchar2);

  /**
   * This procedure sets the error status to the mmtt. It sets the error
   * for the given temp id as well as the child records.
   */
  procedure setMmttError(p_txnTempID in number,
                         p_msgData   in varchar2);


  /**
   * This procedure explodes the BOM for the given assemble and do the default of
   * subinventory and locator. It will find the components up to the toOpSeqNum.
   * If the supply subinv and locator in the BOM is not provided, then it will try
   * to default those the rule: BOM level --> item level --> wip parameter
   *
   * ER 4369064: This API is called from both Flow and WIP. If called from Flow, we
   * need to   1) Validate transaction flag for components
   *           2) Include / exclude component yield based on WIP Parameter
   * Calling program should pass 'TRUE' through the parameter p_txnFlag if the above
   * two tasks are applicable, and 'FALSE' if not.
   */
  procedure explodeRequirementsAndDefault(p_assyID          in  number,
                                          p_orgID           in  number,
                                          p_qty             in  number,
                                          p_altBomDesig     in  varchar2,
                                          p_altOption       in  number,
            /* Fix for bug#3423629 */     p_bomRevDate      in  date default NULL,
                                          p_txnDate         in  date,
	    /* Fix for bug 5383135 */     p_implFlag        in  number,
                                          p_projectID       in  number,
                                          p_taskID          in  number,
                                          p_toOpSeqNum      in  number,
                                          p_altRoutDesig    in  varchar2,
           /* Fix for bug#4538135 */      p_txnFlag         in  boolean default true,
           /* Fix for bug#5262858 */      p_defaultPushSubinv in varchar2 default null,
           /* added for bug 5332615 */    p_unitNumber  in varchar2 DEFAULT '',
                                          x_compTbl          out NOCOPY system.wip_component_tbl_t,
                                          x_returnStatus     out NOCOPY varchar2);


  /**
   * This procedure explodes the BOM and insert the material requirement into
   * mmtt table under the given header id and completion txn id.
   * If the supply subinv and locator in the BOM is not provided, then it will try
   * to default those the rule: BOM level --> item level --> wip parameter
   */
  procedure explodeRequirementsToMMTT(p_txnTempID    in  number,
                                      p_assyID       in  number,
                                      p_orgID        in  number,
                                      p_qty          in  number,
                                      p_altBomDesig  in  varchar2,
                                      p_altOption    in  number,
                                      p_txnDate      in  date,
                                      p_projectID       in  number,
                                      p_taskID          in  number,
                                      p_toOpSeqNum   in  number,
                                      p_altRoutDesig in  varchar2,
                                      x_returnStatus  out NOCOPY varchar2);


  /**
   * This procedure constructs the wip line ops table of records by calling
   * the appropriate BOM API.
   *
   * You must either privide the routing sequence id or
   * (assy id, orgid, alternate routing designator)
   *
   * p_terminalOpSeqNum is greater than 0, it calls the BOM API to get all the
   *   line ops before the terminal line op in the primary path of the routing network.
   * p_terminalOpSeqNum is -1, then all the line ops in the primary patch of the
   *   routing network are cached.
   * p_terminalOpSeqNum is -2, then all the line ops (except rework loops) in the
   *   routing network are cached.
   */
  procedure constructWipLineOps(p_routingSeqID     in  number,
                                p_assyItemID       in  number,
                                p_orgID            in  number,
                                p_altRoutDesig     in  varchar2,
                                p_terminalOpSeqNum in  number,
                                x_lineOpTbl         out NOCOPY bom_rtg_network_api.op_tbl_type);

  /**
   * This function decides whether the given event belongs to a line op that is
   * prior to or the same as the given line op or not.
   * It returns true if p_eventNum belongs to a line op that is prior or same as
   * p_lineOpNum. It returns false otherwise. It also returns false if any of the
   * given parameter does not exist.
   */
  function eventInPriorSameLineOp(p_routingSeqID in number,
                                  p_eventNum     in number,
                                  p_lineOpNum    in number,
                                  p_lineOpTbl    in bom_rtg_network_api.op_tbl_type) return boolean;

  /**
   * This function is used to derive the transaction action id from the
   * transaction type id
   */
  function getTypeFromAction(p_txnActionID in number) return number;


  /**
   * This function is used to derive the transaction_type_id and transaction_action_id
   * of the child given the parent txn type id and required per assembly.
   */
  procedure getChildTxn(p_parentTxnTypeID  in  number,
                        p_signOfPer        in  number,
                        x_childTxnTypeID    out NOCOPY number,
                        x_childTxnActionID  out NOCOPY number);

  /**
   * Generate the issue locators for all the issues associated with a completion
   * This would be called only for a project related completions.
   */
  procedure generateCompLocator(p_parentID     in  number,
                                x_returnStatus  out NOCOPY varchar2);

end wip_flowUtil_priv;

 

/
