--------------------------------------------------------
--  DDL for Package WIP_BFLPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_BFLPROC_PRIV" AUTHID CURRENT_USER as
  /* $Header: wipbflps.pls 120.3 2007/09/17 19:06:47 kboonyap ship $ */

  --------------------------------------------------------------------------------------------------------------------
  --This package is the wip backlush processor. It has procedures to explode a bom for work order-less transactions or
  --query WRO for moves and completions. explodeRequirements() explodes the components into a database object while
  --processRequirements has an option of whether to insert requirements into an object or directly into MMTT.
  --------------------------------------------------------------------------------------------------------------------

  -----------------
  --package globals
  -----------------
  g_compTblExtendSize CONSTANT NUMBER := 100;

  --------------------------------------------------------------------------------------------------------------------------
  --This procedure makes sure all backflush requirements are populated. It does *not* do any WIP or INV processing.
  --If you pass an initialized object in the x_compObj parameter, the object will be filled
  --with components. Otherwise they will be directly inserted into MTI.
  --non-obvious parameters:
  --p_batchID: The value to be populated in the MTI.transaction_batch_id column. The batch sequence column is populated with
  --           wip_constants.component_batch_seq
  --p_assyQty: relative to WIP (+ for completions. - for returns).
  --p_firstOp: The first operation to backflush. Pass -1 to backflush all operations until p_lastOp.
  --p_lastOp: The last operation to backflush.
  --p_firstMoveOp: The actual first move operation. Because of the autocharge/backflush flags, this value could be different
  --               than p_firstOp. It is needed to determine whether to backflush autocharge operations. This value is not
  --               necessary when performing assembly pulls (pass null in this case).
  --p_lastMoveOp: The actual last move operation. Because of the autocharge/backflush flags, this value could be different
  --              than p_lastOp. It is needed to determine whether to backflush autocharge operations. This value is not
  --              necessary when performing assembly pulls (pass null in this case).
  --p_srcCode: The source_code column value for the to be created MMTT records, if the procedure inserts into MMTT (see
  --           x_compTbl argument).
  --p_batchSeq: The batch sequence number to be insert into MTI and MMTT.
  --p_mergeMode:
  --  + if it is fnd_api.g_true then processRequirements() will 'merge' requirements from WRO with existing MMTT records,
  --    i.e. update the quantity of the mmtt record
  --  + if it is fnd_api.g_false then processRequirements() will not insert the WRO requirements into MMTT. Instead it
  --    assumes the MMTT record fully represents the backflush transaction.
  --p_reasonID: used during insert into MMTT. This parameter is ignored if inserting into object.
  --p_reference: used during insert into MMTT. This parameter is ignored if inserting into object.
  --p_initMsgList: initialize the message list? Pass fnd_api.g_true if so, g_false if not.
  --p_endDebug: Clean up the log file? Pass fnd_api.g_true unless you plan to call
  --            wip_logger.cleanUp() later.
  --x_compTbl: Pass a null value if you want processRequirements() to insert directly into MMTT. Pass an initialized object
  --           if you want the requirements inserted into an object instead.
  --x_returnStatus: fnd_api.g_ret_sts_success     on successful processing.
  --                fnd_api.g_ret_sts_unexp_error if an unexpected error occurred.
  --------------------------------------------------------------------------------------------------------------------------
  procedure processRequirements(p_wipEntityID   IN NUMBER,
                                p_wipEntityType IN NUMBER,
                                p_repSchedID    IN NUMBER := null,
                                p_repLineID     IN NUMBER := null,
                                p_cplTxnID      IN NUMBER := null,
                                p_movTxnID      IN NUMBER := null,
                                p_batchID       IN NUMBER := null,
                                p_orgID         IN NUMBER,
                                p_assyQty       IN NUMBER, --relative to wip
                                p_txnDate       IN DATE,
                                p_wipSupplyType IN NUMBER,
                                p_txnHdrID      IN NUMBER,
                                p_firstOp       IN NUMBER, -- -1 for regular completions
                                p_lastOp        IN NUMBER, -- last op_seq for completions
                                p_firstMoveOp   IN NUMBER := null,
                                p_lastMoveOp    IN NUMBER := null,
                                p_srcCode       IN VARCHAR2 := null,
                                p_batchSeq      IN NUMBER := null,
                                p_lockFlag      IN NUMBER := null,
                                p_mergeMode     IN VARCHAR2, --see above explanation for setting this parameter
                                p_reasonID      IN NUMBER := null,
                                p_reference     IN VARCHAR2 := null,
                                p_initMsgList   IN VARCHAR2,
                                p_endDebug      IN VARCHAR2, --pass true unless calling wip_logger.cleanup() elsewhere
                                p_mtlTxnMode    IN NUMBER,
                                x_compTbl       IN OUT NOCOPY system.wip_component_tbl_t, --pass null if you want to insert into MMTT
                                x_returnStatus OUT NOCOPY VARCHAR2);


  ----------------------------------------------------------------------------------------
  --This procedure explodes the item's bom into the x_compTbl table. This procedure is a
  --fairly complex wrapper on top of a bom routine.
  --non-obvious parameters:
  --p_qty: pass positive quantity for completions, negative for returns.
  -- p_unitNumber: To explode components properly based on unit number for unit effective assemblies.
  -- p_implFlag: This flag decides whether unimplemented ECOs should be considered.
  --             This flag should be 2 for discrete(consider implemented and unimplemented) and
  --             this goes along with profile 'WIP:Exclude ECOs'.
  --             For WOL/Flow, this flag should be 1 (consider only implemented changes).
  --p_initMsgList: initialize the message list?
  --p_endDebug: Clean up the log file? Pass fnd_api.g_true unless you plan to call
  --            wip_logger.cleanUp() later.
  --x_compTbl: The component requirements for the given item and alternate bom designator.
  --x_returnStatus: fnd_api.g_ret_sts_success     on successful processing.
  --                fnd_api.g_ret_sts_unexp_error if an unexpected error occurred.
  ----------------------------------------------------------------------------------------
  procedure explodeRequirements(p_itemID        IN NUMBER,
                                p_orgID         IN NUMBER,
                                p_qty           IN NUMBER,
                                p_altBomDesig   IN VARCHAR2,
                                p_altOption     IN NUMBER,
   /* Fix for bug#3423629 */    p_bomRevDate    IN DATE   DEFAULT NULL,
                                p_txnDate       IN DATE,
   /* Fix for bug 5383135 */    p_implFlag      IN NUMBER,
                                p_projectID     IN NUMBER,
                                p_taskID        IN NUMBER,
   /* added for bug 5332615 */  p_unitNumber  in varchar2 DEFAULT '',
                                p_initMsgList   IN VARCHAR2,
                                p_endDebug      IN VARCHAR2,
                                x_compTbl      OUT NOCOPY system.wip_component_tbl_t,
                                x_returnStatus OUT NOCOPY VARCHAR2);


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
 * p_ocQty                Overcompleted quantity. Pass NULL if not
 *                        overcompleted transaction.
 * p_primaryQty           WMTI.PRIMARY_QUANTITY
 * p_txnDate              WMTI.TRANSACTION_DATE
 * p_txnHdrID             MMTT.TRANSACTION_HEADER_ID. Caller can generate this
 *                        value from mtl_material_transactions_s.
 * p_batchID              MMTT.TRANSACTION_BATCH_ID. For move, EZ Complete,
 *                        EZ return transactions, pass TRANSACTION_HEADER_ID.
 *                        For completion and return transactions, pass
 *                        COMPLETION_TRANSACTION_ID.
 * p_txnType              There are 3 possible values for this parameter
 *                        WIP_CONSTANTS.MOVE_TXN (1) [move/scrap/reject]
 *                        WIP_CONSTANTS.COMP_TXN (2) [completion/EZ completion]
 *                        WIP_CONSTANTS.RET_TXN (3) [return/EZ return]
 * p_entityType           WE.ENTITY_TYPE. The caller should pass either
 *                        WIP_CONSTANTS.DISCRETE or WIP_CONSTANTS.LOTBASED or
 *                        WIP_CONSTANTS.REPETITIVE
 * p_tblName              This parameter will be used to determine the table
 *                        to insert components to. Caller can pass either
 *                        WIP_CONSTANTS.MMTT_TBL or WIP_CONSTANTS.MTI_TBL
 *                        If called from WIP form, the caller should pass
 *                        'MMTT' because we need to set some columns in MMTT
 *                        before we can use Inventory lot/serial page to
 *                        gather lot/serial information. Otherwise, pass 'MTI'.
 * p_lineID               LINE_ID. Only pass this value for repetitive schedule
 * p_fmOp                 WMTI.FM_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_fmStep               WMTI.FM_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_toOp                 WMTI.TO_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_toStep               WMTI.TO_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_childMovTxnID        WMTI.TRANSACTION_ID of child move record. Only pass
 *                        this value if overmove or overcomplete.Caller can
 *                        generate this value from wip_transactions_s.
 * p_movTxnID             WMTI.TRANSACTION_ID of parent move record. Only pass
 *                        if not completion and return transactions. Caller can
 *                        generate this value from wip_transactions_s.
 * p_cplTxnID             MMTT.COMPLETION_TRANSACTION_ID. Only pass this
 *                        value if completion/return/EZ completion/EZ return
 *                        Caller can generate this value from
 *                        mtl_material_transactions_s
 * p_batchSeq             Batch sequence number that will be insert into MTI
 *                        and MMTT. If caller does not pass anything, we will
 *                        default to WIP_CONSTANTS.COMPONENT_BATCH_SEQ(2)
 * p_fmMoveProcessor      Pass WIP_CONSTANTS.YES(1) if called from Move
 *                        Processing code. Otherwise, leave it null or pass
 *                        WIP_CONSTANTS.NO(2).
 * p_mtlTxnMode           material processing mode.
 * x_lotSerRequired       This parameter will determine whether we need to
 *                        gather more lot/serial information from the user.
 *                        There are 2 possible return values
 *                        WIP_CONSTANTS.YES(1) and WIP_CONSTANTS.NO(2)
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
 */
PROCEDURE backflush(p_wipEntityID       IN        NUMBER,
                    p_orgID             IN        NUMBER,
                    p_primaryQty        IN        NUMBER,
                    p_txnDate           IN        DATE,
                    p_txnHdrID          IN        NUMBER,
                    p_batchID           IN        NUMBER,
                    p_txnType           IN        NUMBER,
                    p_entityType        IN        NUMBER,
                    p_tblName           IN        VARCHAR2,
                    p_lineID            IN        NUMBER:= NULL,
                    p_fmOp              IN        NUMBER:= NULL,
                    p_fmStep            IN        NUMBER:= NULL,
                    p_toOp              IN        NUMBER:= NULL,
                    p_toStep            IN        NUMBER:= NULL,
                    p_ocQty             IN        NUMBER:= NULL,
                    p_childMovTxnID     IN        NUMBER:= NULL,
                    p_movTxnID          IN        NUMBER:= NULL,
                    p_cplTxnID          IN        NUMBER:= NULL,
                    p_batchSeq          IN        NUMBER:= NULL,
                    p_fmMoveProcessor   IN        NUMBER:= NULL,
                    p_lockFlag          IN        NUMBER:= NULL,
                    p_mtlTxnMode        IN        NUMBER,
                    p_reasonID          IN        NUMBER := NULL,
                    p_reference         IN        VARCHAR2 := NULL,
                    x_lotSerRequired   OUT NOCOPY NUMBER,
                    x_bfRequired       OUT NOCOPY NUMBER,
                    x_returnStatus     OUT NOCOPY VARCHAR2);

/****************************************************************************
 *
 * This procedure will be called from WIP OA Transaction page(move related
 * transctions, completion, and return), and OSFM OA Move page to populate all
 * backflush components into PL/SQL object(system.wip_lot_serial_obj_t). This
 * procedure should be called before calling the main processors because we
 * may need to gather lot/serial information for the backflush components.
 * By the time the main processor pick up the record, all the information
 * should be ready.
 *
 * PARAMETERS:
 *
 * p_wipEntityID          WMTI.WIP_ENTITY_ID
 * p_orgID                WMTI.ORGANIZATION_ID
 * p_ocQty                Overcompleted quantity. Pass NULL if not
 *                        overcompleted transaction.
 * p_primaryQty           WMTI.PRIMARY_QUANTITY
 * p_txnDate              WMTI.TRANSACTION_DATE
 * p_txnHdrID             MMTT.TRANSACTION_HEADER_ID. Caller can generate this
 *                        value from mtl_material_transactions_s.
 * p_txnType              There are 3 possible values for this parameter
 *                        WIP_CONSTANTS.MOVE_TXN (1) [move/scrap/reject]
 *                        WIP_CONSTANTS.COMP_TXN (2) [completion/EZ completion]
 *                        WIP_CONSTANTS.RET_TXN (3) [return/EZ return]
 * p_entityType           WE.ENTITY_TYPE. The caller should pass either
 *                        WIP_CONSTANTS.DISCRETE or WIP_CONSTANTS.LOTBASED or
 *                        WIP_CONSTANTS.REPETITIVE
 * p_fmOp                 WMTI.FM_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_fmStep               WMTI.FM_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_toOp                 WMTI.TO_OPERATION_SEQ_NUM. Only pass this value if
 *                        not completion and return transactions.
 * p_toStep               WMTI.TO_INTRAOPERATION_STEP_TYPE. Only pass this
 *                        value if not completion and return transactions.
 * p_childMovTxnID        WMTI.TRANSACTION_ID of child move record. Only pass
 *                        this value if overmove or overcomplete.Caller can
 *                        generate this value from wip_transactions_s.
 * p_movTxnID             WMTI.TRANSACTION_ID of parent move record. Only pass
 *                        if not completion and return transactions. Caller can
 *                        generate this value from wip_transactions_s.
 * p_cplTxnID             MMTT.COMPLETION_TRANSACTION_ID. Only pass this
 *                        value if completion/return/EZ completion/EZ return
 *                        Caller can generate this value from
 *                        mtl_material_transactions_s
 * p_objectID             Genealogy object ID of assembly serial number. We
 *                        will use this parameter to differentiate between
 *                        regular and serialized transactions.
 * x_compInfo             PL/SQL object that stores backflush components and
 *                        their corresponding lot and serial.
 * x_lotSerRequired       This parameter will determine whether we need to
 *                        gather more lot/serial information from the user.
 *                        There are 2 possible return values
 *                        WIP_CONSTANTS.YES(1) and WIP_CONSTANTS.NO(2)
 * x_returnStatus         There are 2 possible values
 *                        *fnd_api.g_ret_sts_success*
 *                        means this procedure succesfully processed
 *                        *fnd_api.g_ret_sts_error*
 *                        means this transaction error out
 */
PROCEDURE backflush(p_wipEntityID       IN        NUMBER,
                    p_orgID             IN        NUMBER,
                    p_primaryQty        IN        NUMBER,
                    p_txnDate           IN        DATE,
                    p_txnHdrID          IN        NUMBER,
                    p_txnType           IN        NUMBER,
                    p_entityType        IN        NUMBER,
                    p_fmOp              IN        NUMBER:= NULL,
                    p_fmStep            IN        NUMBER:= NULL,
                    p_toOp              IN        NUMBER:= NULL,
                    p_toStep            IN        NUMBER:= NULL,
                    p_ocQty             IN        NUMBER:= NULL,
                    p_childMovTxnID     IN        NUMBER:= NULL,
                    p_movTxnID          IN        NUMBER:= NULL,
                    p_cplTxnID          IN        NUMBER:= NULL,
                    p_objectID          IN        NUMBER:= NULL,
                    x_compInfo         OUT NOCOPY system.wip_lot_serial_obj_t,
                    x_lotSerRequired   OUT NOCOPY NUMBER,
                    x_returnStatus     OUT NOCOPY VARCHAR2);

end wip_bflProc_priv;

/
