--------------------------------------------------------
--  DDL for Package WIP_ONLINE_MTL_TXN_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_ONLINE_MTL_TXN_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: wipopsrs.pls 120.0.12000000.1 2007/01/18 22:19:08 appldev ship $ */

  /* Backflush all materials in WIP_LPN_COMPLETIONS with:
   *    SOURCE_ID == p_header_id AND HEADER_ID != p_header_id
   *
   * Note: This procedure is *not* performed by any of the below completion functions
   *
   * parameters: p_header_id -- SOURCE_ID AND !HEADER_ID of records to process in WIP_LPN_COMPLETIONS
   *             x_err_msg    -- err_msg if call fails, null if success
   *             x_return_status   -- fnd_api.G_RET_STS_SUCCESS ('S') if successful
   */
  PROCEDURE backflushComponents(p_header_id IN  NUMBER,
                                x_err_msg    OUT NOCOPY VARCHAR2,
                                x_return_status   OUT NOCOPY VARCHAR2);


  /* Work Order-less completion processor
   *
   * parameters: p_header_id -- HEADER_ID of record to process in WIP_LPN_COMPLETIONS
   *             x_err_msg    -- err_msg if call fails, null if success
   *             x_return_status   -- fnd_api.G_RET_STS_SUCCESS ('S') if successful
   */
  PROCEDURE completeWol(p_header_id IN  NUMBER,
                        x_err_msg    OUT NOCOPY VARCHAR2,
                        x_return_status   OUT NOCOPY VARCHAR2);


  /* Process an Discrete Job assembly completion and
   * perform material transactions for its pull components
   *
   * parameters: p_header_id -- HEADER_ID of assy record to process in WIP_LPN_COMPLETIONS
   *                         -- SOURCE_ID of component records to process in WIP_LPN_COMPLETIONS
   *             x_err_msg    -- err_msg if call fails, null if success
   *             x_return_status   -- fnd_api.G_RET_STS_SUCCESS ('S') if successful
   */
  PROCEDURE completeAssyAndComponents(p_header_id IN  NUMBER,
                                      x_err_msg    OUT NOCOPY VARCHAR2,
                                      x_return_status   OUT NOCOPY VARCHAR2);


  /* Discrete Job assembly completion processing w/o processing components
   *
   * parameters: p_header_id -- HEADER_ID of record to process in WIP_LPN_COMPLETIONS
   *             x_err_msg    -- err_msg if call fails, null if success
   *             x_return_status   -- fnd_api.G_RET_STS_SUCCESS ('S') if successful
   */
  PROCEDURE completeAssyItem(p_header_id IN  NUMBER,
                             x_err_msg    OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2);


  /* Processes all material transactions in WIP_LPN_COMPLETIONS with:
   *    SOURCE_ID == p_header_id AND HEADER_ID != p_header_id
   *
   * parameters: p_source_id -- SOURCE_ID && !HEADER_ID of records to process in WIP_LPN_COMPLETIONS
   *             x_err_msg    -- err_msg if call fails, null if success
   *             x_return_status   -- fnd_api.G_RET_STS_SUCCESS ('S') if successful
   */
  PROCEDURE transactMaterials(p_source_id IN  NUMBER,
                              x_err_msg    OUT NOCOPY VARCHAR2,
                              x_return_status   OUT NOCOPY VARCHAR2);

  /* Processes the material transaction in WIP_LPN_COMPLETIONS with the given source_id
   *
   * parameters: p_header_id -- HEADER_ID of record to process in WIP_LPN_COMPLETIONS
   *             x_err_msg    -- err_msg if call fails, null if success
   *             x_return_status   -- fnd_api.G_RET_STS_SUCCESS ('S') if successful
   */
  PROCEDURE transactMaterial(p_header_id IN  NUMBER,
                             x_err_msg    OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2);

  /* Process an Lpn flow completion, called by LpnFlowProcessor.java  Calls the new
   * wma online flow processor in mmtt first, then deletes those records and
   * populates wip_lpn_completions for wms processing.
   * Before calling this, the component records should have already been populated
   * into both the temp and wip_lpn tables.
   *
   * parameters: p_orgID  -- current org
   *             p_userID -- current user
   *             p_scheduledFlag -- 1 for scheduled, 3 for unscheduled
   *             p_transactionHeaderID -- header ID in wip_lpn_completions
   *             p_completionTxnID -- completionTxnID in wip_lpn_completions
   *             p_processHeaderID  -- transaction header ID in mmtt
   *             p_processTempID  -- transaction temp ID in mmtt
   *             p_processCmpTxnID -- completionTxnID in mmtt
   *             x_err_msg    -- err_msg if call fails, null if success
   *             x_return_status   -- fnd_api.G_RET_STS_SUCCESS ('S') if successful
   */
  PROCEDURE lpnCompleteFlow (p_orgID NUMBER,
                             p_userID NUMBER,
                             p_scheduledFlag NUMBER,
                             p_scheduleNumber VARCHAR2,
                             p_transactionTypeID NUMBER,
                             p_transactionHeaderID NUMBER,
                             p_completionTxnID NUMBER,
                             p_processHeaderID NUMBER,
                             p_processTempID NUMBER,
                             p_processCmpTxnID NUMBER,
                             p_transactionQty NUMBER,
                             p_transactionUOM VARCHAR2,
                             p_lineID NUMBER,
                             p_lineOp NUMBER,
                             p_assyItemID NUMBER,
                             p_reasonID NUMBER,
                             p_qualityID NUMBER,
                             p_wipEntityID IN OUT NOCOPY NUMBER,
                             p_kanbanID NUMBER,
                             p_projectID NUMBER,
                             p_taskID NUMBER,
                             p_lpnID NUMBER,
                             p_demandSourceHeaderID NUMBER,
                             p_demandSourceLine VARCHAR2,
                             p_demandSourceDelivery VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_err_msg OUT NOCOPY VARCHAR2);

  /* Process an Lpn (discrete job)  completion, called by LpnCmpProcessor.java  Calls
   * wma online processor in mmtt first, then deletes those records and
   * populates wip_lpn_completions for wms processing.
   * Before calling this, the component records should have already been populated
   * into both the temp and wip_lpn tables.
   *
   * parameters: p_orgID  -- current org
   *             p_userID -- current user
   *             p_transactionHeaderID -- header ID in wip_lpn_completions
   *             p_processHeaderID  -- transaction header ID in mmtt
   *             p_processTempID  -- transaction temp ID in mmtt
   *             p_overcomplete   -- 1 for overcomplete
   *             x_err_msg    -- err_msg if call fails, null if success
   *             x_return_status   -- fnd_api.G_RET_STS_SUCCESS ('S') if successful
   */
  PROCEDURE lpnCompleteJob (p_orgID NUMBER,
                            p_userID NUMBER,
                            p_transactionTypeID NUMBER,
                            p_transactionHeaderID NUMBER,
                            p_completionTxnID NUMBER,
                            p_processHeaderID NUMBER,
                            p_processIntID NUMBER,
                            p_processCmpTxnID NUMBER,
                            p_wipEntityID NUMBER,
                            p_wipEntityName VARCHAR2,
                            p_assyItemID NUMBER,
                            p_assyItemName VARCHAR2,
                            p_overcomplete NUMBER,
                            p_transactionQty NUMBER,
                            p_transactionUOM VARCHAR2,
                            p_qualityID NUMBER,
                            p_kanbanID NUMBER,
                            p_projectID NUMBER,
                            p_taskID NUMBER,
                            p_lpnID NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_err_msg OUT NOCOPY VARCHAR2);



END wip_online_mtl_txn_processor;

 

/
