--------------------------------------------------------
--  DDL for Package WIP_MOVPROC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MOVPROC_GRP" AUTHID CURRENT_USER AS
/* $Header: wipmvgps.pls 120.0 2005/05/25 08:17:27 appldev noship $*/

/****************************************************************************
 *
 * This procedure works similar to backflushIntoMMTT and backflushIntoMTI
 * except that this procedure will put item/lot/serial in PL/SQL object
 * instead of insert them into MMTT and MTI. This procedure will be called
 * from OSFM OA page.
 *
 * PARAMETERS:
 *
 * p_wipEntityID          WMTI.WIP_ENTITY_ID
 * p_orgID                WMTI.ORGANIZATION_ID
 * p_primaryQty           WMTI.PRIMARY_QUANTITY
 * p_txnDate              WMTI.TRANSACTION_DATE
 * p_txnHdrID             MMTT.TRANSACTION_HEADER_ID. Caller can generate this
 *                        value from mtl_material_transactions_s.
 * p_txnType              There are 3 possible values for this parameter
 *                        WIP_CONSTANTS.MOVE_TXN (1) [move/scrap/reject]
 *                        WIP_CONSTANTS.COMP_TXN (2) [completion/EZ completion]
 *                        WIP_CONSTANTS.RET_TXN (3) [return/EZ return]
 * p_fmOp                 WMTI.FM_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_fmStep               WMTI.FM_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_toOp                 WMTI.TO_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_toStep               WMTI.TO_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_movTxnID             WMTI.TRANSACTION_ID of parent move record. Only pass
 *                        if not completion and return transactions. Caller can
 *                        generate this value from wip_transactions_s.
 * p_cplTxnID             MMTT.COMPLETION_TRANSACTION_ID. Only pass this
 *                        value if completion/return/EZ completion/EZ return
 *                        Caller can generate this value from
 *                        mtl_material_transactions_s.
 * x_lotSerRequired       This parameter will determine whether we need to
 *                        gather more lot/serial information from the user.
 *                        There are 2 possible return values
 *                        WIP_CONSTANTS.YES(1) and WIP_CONSTANTS.NO(2)
 * x_compInfo             PL/SQL object that store item/lot/serial information
 *                        of backflush components.
 * x_returnStatus         There are 2 possible values
 *                        *fnd_api.g_ret_sts_success*
 *                        means this procedure succesfully processed
 *                        *fnd_api.g_ret_sts_error*
 *                        means this transaction error out
 *****************************************************************************/
PROCEDURE backflush(p_wipEntityID     IN        NUMBER,
                    p_orgID           IN        NUMBER,
                    p_primaryQty      IN        NUMBER,
                    p_txnDate         IN        DATE,
                    p_txnHdrID        IN        NUMBER,
                    p_txnType         IN        NUMBER,
                    p_fmOp            IN        NUMBER,
                    p_fmStep          IN        NUMBER,
                    p_toOp            IN        NUMBER,
                    p_toStep          IN        NUMBER,
                    p_movTxnID        IN        NUMBER,
                    p_cplTxnID        IN        NUMBER:= NULL,
                    x_lotSerRequired OUT NOCOPY NUMBER,
                    x_compInfo       OUT NOCOPY system.wip_lot_serial_obj_t,
                    x_returnStatus   OUT NOCOPY VARCHAR2);

/****************************************************************************
 *
 * This procedure should be called from WIP Completion, WIP Move,
 * and OSFM Move forms to insert all backflush components into MMTT. This
 * procedure should be called before calling the main processors because we
 * may need to gather lot/serial information for the backflush components.
 * By the time the main processor pick up the record, all the information
 * should be ready.
 *
 * PARAMETERS:
 *
 * p_wipEntityID          WMTI.WIP_ENTITY_ID
 * p_orgID                WMTI.ORGANIZATION_ID
 * p_primaryQty           WMTI.PRIMARY_QUANTITY
 * p_txnDate              WMTI.TRANSACTION_DATE
 * p_txnHdrID             MMTT.TRANSACTION_HEADER_ID. Caller can generate this
 *                        value from mtl_material_transactions_s.
 * p_txnType              There are 3 possible values for this parameter
 *                        WIP_CONSTANTS.MOVE_TXN (1) [move/scrap/reject]
 *                        WIP_CONSTANTS.COMP_TXN (2) [completion/EZ completion]
 *                        WIP_CONSTANTS.RET_TXN (3) [return/EZ return]
 * p_fmOp                 WMTI.FM_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_fmStep               WMTI.FM_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_toOp                 WMTI.TO_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_toStep               WMTI.TO_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_movTxnID             WMTI.TRANSACTION_ID of parent move record. Only pass
 *                        if not completion and return transactions. Caller can
 *                        generate this value from wip_transactions_s.
 * p_cplTxnID             MMTT.COMPLETION_TRANSACTION_ID. Only pass this
 *                        value if completion/return/EZ completion/EZ return
 *                        Caller can generate this value from
 *                        mtl_material_transactions_s.
 * p_mtlTxnMode           material processing mode
 * p_reasonID             reason ID that will be inserted into MTI, MMTT
 * p_reference            reference text that will be inserted into MTI, MMTT
 * x_bfRequired           There are 3 possible return values
 *                        WIP_CONSTANTS.WBF_NOBF (0):
 *                        means there is  no component to backflush
 *                        WIP_CONSTANTS.WBF_BF_NOPAGE (1):
 *                        means there are some components to backflush, but
 *                        no need to go to backflush page
 *                        WIP_CONSTANTS.WBF_BF_PAGE (2):
 *                        means there are some components to backflush, and
 *                        backflush page required to gather more lot/serial
 * x_returnStatus         There are 2 possible values
 *                        *fnd_api.g_ret_sts_success*
 *                        means this procedure succesfully processed
 *                        *fnd_api.g_ret_sts_error*
 *                        means this transaction error out
 *****************************************************************************/
PROCEDURE backflushIntoMMTT(p_wipEntityID   IN        NUMBER,
                            p_orgID         IN        NUMBER,
                            p_primaryQty    IN        NUMBER,
                            p_txnDate       IN        DATE,
                            p_txnHdrID      IN        NUMBER,
                            p_txnType       IN        NUMBER,
                            p_fmOp          IN        NUMBER,
                            p_fmStep        IN        NUMBER,
                            p_toOp          IN        NUMBER,
                            p_toStep        IN        NUMBER,
                            p_movTxnID      IN        NUMBER,
                            p_cplTxnID      IN        NUMBER:= NULL,
                            p_mtlTxnMode    IN        NUMBER,
                            p_reasonID      IN        NUMBER:= NULL,
                            p_reference     IN        VARCHAR2:= NULL,
                            x_bfRequired   OUT NOCOPY NUMBER,
                            x_returnStatus OUT NOCOPY VARCHAR2);

/****************************************************************************
 *
 * This procedure will be called from OSFM new backflush API for forward move
 * and completion transaction. For undo and return transaction, OSFM
 * will call their API to derive lot/serial of the component. This API is
 * mainly use for background transaction.
 *
 * PARAMETERS:
 *
 * p_wipEntityID          WMTI.WIP_ENTITY_ID
 * p_orgID                WMTI.ORGANIZATION_ID
 * p_primaryQty           WMTI.PRIMARY_QUANTITY
 * p_txnDate              WMTI.TRANSACTION_DATE
 * p_txnHdrID             MMTT.TRANSACTION_HEADER_ID. Caller can generate this
 *                        value from mtl_material_transactions_s.
 * p_txnType              There are 3 possible values for this parameter
 *                        WIP_CONSTANTS.MOVE_TXN (1) [move/scrap/reject]
 *                        WIP_CONSTANTS.COMP_TXN (2) [completion/EZ completion]
 *                        WIP_CONSTANTS.RET_TXN (3) [return/EZ return]
 * p_fmOp                 WMTI.FM_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_fmStep               WMTI.FM_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_toOp                 WMTI.TO_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_toStep               WMTI.TO_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_movTxnID             WMTI.TRANSACTION_ID of parent move record. Only pass
 *                        if not completion and return transactions. Caller can
 *                        generate this value from wip_transactions_s.
 * p_cplTxnID             MMTT.COMPLETION_TRANSACTION_ID. Only pass this
 *                        value if completion/return/EZ completion/EZ return
 *                        Caller can generate this value from
 *                        mtl_material_transactions_s.
 * p_mtlTxnMode           material processing mode
 * p_reasonID             reason ID that will be inserted into MTI, MMTT
 * p_reference            reference text that will be inserted into MTI, MMTT
 * x_lotSerRequired       This parameter will determine whether we need to
 *                        gather more lot/serial information from the user.
 *                        There are 2 possible return values
 *                        WIP_CONSTANTS.YES(1) and WIP_CONSTANTS.NO(2)
 * x_returnStatus         There are 2 possible values
 *                        *fnd_api.g_ret_sts_success*
 *                        means this procedure succesfully processed
 *                        *fnd_api.g_ret_sts_error*
 *                        means this transaction error out
 *****************************************************************************/
PROCEDURE backflushIntoMTI(p_wipEntityID     IN        NUMBER,
                           p_orgID           IN        NUMBER,
                           p_primaryQty      IN        NUMBER,
                           p_txnDate         IN        DATE,
                           p_txnHdrID        IN        NUMBER,
                           p_txnType         IN        NUMBER,
                           p_fmOp            IN        NUMBER,
                           p_fmStep          IN        NUMBER,
                           p_toOp            IN        NUMBER,
                           p_toStep          IN        NUMBER,
                           p_movTxnID        IN        NUMBER,
                           p_cplTxnID        IN        NUMBER:= NULL,
                           p_mtlTxnMode      IN        NUMBER,
                           p_reasonID        IN        NUMBER:= NULL,
                           p_reference       IN        VARCHAR2:= NULL,
                           x_lotSerRequired OUT NOCOPY NUMBER,
                           x_returnStatus   OUT NOCOPY VARCHAR2);

/***************************************************************************
 * This procedure will be used to do move, easy-return, easy-completion, and
 * scrap transaction for Discrete, OSFM jobs, and Repetitive Schedule. The
 * caller need to insert the record into WIP_MOVE_TXN_INTERFACE before calling
 * this routine. Caller can generate wmti.transaction_id and wmti.group_id
 * from the sequence wip_transactions_s. Caller need to insert both group_id
 * and transaction_id before calling the procedure below. These 2 columns
 * should have to same value. Caller should insert wmti.process_phase =
 * 1(Validation) if validation needed, and insert wmti.process_phase =
 * 2(Processing) if no validation needed(e.g. form do the validation), and
 * insert wmti.process_status = 2(Running) to prevent Move Manager from
 * picking up this record.
 *
 * PARAMETER:
 *
 * p_movTxnid           transaction_id in WIP_MOVE_TXN_INTERFACE
 * p_procPhase          There are 2 possible values
 *                      WIP_CONSTANTS.MOVE_VAL(1),
 *                      and WIP_CONSTANTS.MOVE_PROC(2)
 *                      This value should be the same as WMTI.PROCESS_PHASE
 * p_txnHdrID           MMTT.TRANSACTION_HEADER_ID. Caller can
 *                      generate this value from mtl_material_transactions_s.
 * p_mtlMode            Material processing mode. Can be either
 *                      WIP_CONSTANTS.BACKGROUND or WIP_CONSTANTS.ONLINE or
 *                      WIP_CONSTANTS.IMMED_CONC
 * p_cplTxnID           MMTT.COMPLETION_TRANSACTION_ID. Caller can
 *                      generate this value from mtl_material_transactions_s.
 * p_commmit            commit the change to the database if succesfully
 *                      processing ? pass
 *                      fnd_api.g_true or fnd_api.g_false
 *                      if callers do not pass anything, no commit occur
 * x_returnStatus       There are 2 possible values
 *                      *fnd_api.g_ret_sts_success*
 *                      means the move transaction succesfully processed
 *                      *fnd_api.g_ret_sts_unexp_error*
 *                      means an exception occurred
 *                      The size of this variable should be VARCHAR2(1)
 * x_errorMsg           contains the error message on failure. null on success.
 *                      The size of this variable should be VARCHAR2(1000)
 *                      because there may be errors in several columns.
 *
 * NOTE:
 * 1. This procedure should be called if caller want to process one record at
 *    a time such as Online transaction.
 * 2. This procedure will return fnd_api.g_ret_sts_unexp_error if this records
 *    failed. The caller can check the error message from x_errorMsg.
 * 3. The caller does not have to insert child record for overmove/
 *    overcompletion. This API will take care everything. The caller does not
 *    have to call QA API either.
 ***************************************************************************/
PROCEDURE processInterface(p_movTxnID      IN         NUMBER,
                           p_procPhase     IN         NUMBER,
                           p_txnHdrID      IN         NUMBER,
                           p_mtlMode       IN         NUMBER,
                           p_cplTxnID      IN         NUMBER := NULL,
                           p_commit        IN         VARCHAR2 := NULL,
                           x_returnStatus  OUT NOCOPY VARCHAR2,
                           x_errorMsg      OUT NOCOPY VARCHAR2);

/***************************************************************************
 * This procedure will be used to do move, easy-return, easy-completion, and
 * scrap transaction for Discrete, OSFM jobs, and Repetitive Schedule. The
 * caller need to insert the record into WIP_MOVE_TXN_INTERFACE before calling
 * this routine. Caller can generate wmti.group_id from the sequence
 * wip_transactions_s. Only group_id is mandatory for procedure below. Caller
 * does not have to insert transaction_id. Caller should always insert
 * wmti.process_phase = 1(Validation) to make sure that the records are valid,
 * and insert wmti.process_status = 2(Running) to prevent Move
 * Manager from picking up these records.
 *
 * PARAMETER:
 *
 * p_groupID            group_id in WIP_MOVE_TXN_INTERFACE
 * p_commmit            commit the change to the database if no record in this
 *                      group error out ? pass
 *                      fnd_api.g_true or fnd_api.g_false
 *                      if callers do not pass anything, no commit occur
 * x_returnStatus       There are 2 possible values
 *                      *fnd_api.g_ret_sts_success*
 *                      means the move transaction succesfully processed
 *                      *fnd_api.g_ret_sts_unexp_error*
 *                      means an exception occurred
 *                      The size of this variable should be VARCHAR2(1)
 *
 * NOTE:
 * 1. This procedure should be called if caller want to do batch processing for
 *    multiple records in WMTI.
 * 2. This procedure will return fnd_api.g_ret_sts_unexp_error if one or more
 *    records in this group_id failed. The caller can check the error message,
 *    and error column from WIP_TXN_INTERFACE_ERRORS.
 * 3. The caller does not have to insert child record for overmove/
 *    overcompletion. This API will take care everything. The callter does not
 *    have to call QA API either.
 ***************************************************************************/
PROCEDURE processInterface(p_groupID       IN         NUMBER,
                           p_commit        IN         VARCHAR2 := NULL,
                           x_returnStatus  OUT NOCOPY VARCHAR2);
END wip_movProc_grp;

 

/
