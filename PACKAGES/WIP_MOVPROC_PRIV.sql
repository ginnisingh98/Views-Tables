--------------------------------------------------------
--  DDL for Package WIP_MOVPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MOVPROC_PRIV" AUTHID CURRENT_USER AS
/* $Header: wipmovps.pls 120.6.12010000.2 2009/06/23 17:18:38 hliew ship $*/
-- Version  Initial version    1.0     Kaweesak Boonyapornnad

-- this record used to store shedule ID and Qty for Repetitive Schedule
-- Allocation
TYPE rsa_rec_t IS RECORD(scheID  NUMBER,
                         scheQty NUMBER);
TYPE rsa_tbl_t IS TABLE OF rsa_rec_t INDEX BY binary_integer;

/***************************************************************************
 *
 * This procedure is a new Move Worker. This procedure is equivalent to
 * wiltws.ppc. This procedure will be used to create an executable file that
 * will be called from Move Manager.
 *
 * PARAMETER:
 *
 * errbuf                 error messages
 * retcode                return status. 0 for success, 1 for warning and
 *                        2 for error.
 * p_group_id             group_id in WIP_MOVE_TXN_INTERFACE
 * p_proc_phase           process phase that want to be processed. It can be
 *                        either WIP_CONSTANTS.MOVE_VAL,
 *                        WIP_CONSTANTS.MOVE_PROC or WIP_CONSTANTS.BF_SETUP
 * p_time_out             time out only use for BACKGROUND transactions. Pass
 *                        0 for online transaction.
 * p_seq_move             this parameter will be used to determine whether
 *                        we need to do sequencing move or not. Pass either
 *                        WIP_CONSTANTS.YES(1) or WIP_CONSTANTS.NO(2)
 * NOTE:
 * This procedure should be called only from the Move Manager
 *
 ***************************************************************************/

PROCEDURE move_worker(errbuf       OUT NOCOPY VARCHAR2,
                      retcode      OUT NOCOPY NUMBER,
                      p_group_id   IN         NUMBER,
                      p_proc_phase IN         NUMBER,
                      p_time_out   IN         NUMBER,
                      p_seq_move   IN         NUMBER);

/***************************************************************************
 *
 * This procedure will be used to do move, easy-return, easy-completion, and
 * scrap transaction for Discrete and OSFM jobs. The user need to insert
 * the record into WIP_MOVE_TXN_INTERFACE before call this routine
 *
 * This routine can be called directly for ON-LINE transaction, or can be call
 * from Move Worker for background case. For background case we support batch
 * processing, but we will not support batch processing for online case.
 *
 * PARAMETER:
 *
 * p_group_id             group_id in WIP_MOVE_TXN_INTERFACE
 * p_proc_phase           process phase that want to be processed. It can be
 *                        either WIP_CONSTANTS.MOVE_VAL,
 *                        WIP_CONSTANTS.MOVE_PROC or WIP_CONSTANTS.BF_SETUP
 * p_time_out             time out only use for BACKGROUND transactions. Pass
 *                        0 for online transaction.
 * p_move_mode            Move processing mode. Can be either
 *                        WIP_CONSTANTS.BACKGROUND or WIP_CONSTANTS.ONLINE
 * p_bf_mode              Backflush processing mode. Can be either
 *                        WIP_CONSTANTS.BACKGROUND or WIP_CONSTANTS.ONLINE
 * p_mtl_mode             Material processing mode. Can be either
 *                        WIP_CONSTANTS.BACKGROUND or WIP_CONSTANTS.ONLINE or
 *                        WIP_CONSTANTS.IMMED_CONC
 * p_endDebug             If it is called from Move form or Move mobile, pass
 *                        fnd_api.g_true. If it is called from other forms such
 *                        as Completion form, pass fnd_api.g_false because
 *                        the caller may want to keep the log file in the same
 *                        session.
 * p_initMsgList          A flag used to determine whether the user want to
 *                        initialize message list or not. It can be eiher
 *                        'T' for 'True' or 'F' for 'False'
 * p_insertAssy           This flag is only used for Easy Complete/Return txns
 *                        It is used to determine wheter the caller want this
 *                        API to insert assy record into MMTT and MTLT or not.
 *                        If the caller want to be the one who insert the
 *                        record in MMTT, MTLT, and MSNT, this flag need to be
 *                        'F'. Otherwise pass 'T'.
 * p_do_backflush         This flag will be used to determine whether the
 *                        move processor should insert backflush record or not.
 *                        If called from form/mobile, form/mobile will be the
 *                        one who insert backflush records, so pass 'F'.
 *                        If called from move manager pass 'T'.
 * p_child_txn_id         transaction_id of the child record. This is the id
 *                        we passed to backflush processor to collect
 *                        lot/serial info for Mobile Application. Only use
 *                        for Online Over Move transaction from mobile.
 * p_assy_header_id       (Assembly)transaction_header_id in
 *                        MTL_MATERIAL_TRANSACTIONS_TEMP. Caller can
 *                        generate this value from mtl_material_transactions_s.
 * p_mtl_header_id        (Components)transaction_header_id in
 *                        MTL_MATERIAL_TRANSACTIONS_TEMP. It is used when
 *                        called by completion processor for overcompletion
 *                        transaction and if called from WIP Move,
 *                        WIP Completion and OSFM Move forms. Caller can
 *                        generate this value from mtl_material_transactions_s.
 * p_cmp_txn_id           MMTT.COMPLETION_TRANSACTION_ID. If caller pass this
 *                        value, we will insert assembly completion/return
 *                        records with this value. Othewise, we will generate
 *                        from mtl_material_transaction_s. This parameter
 *                        is useful if called from WIP/OSFM Move form.
 * p_seq_move             this parameter will be used to determine whether
 *                        we need to do sequencing move or not. Pass either
 *                        WIP_CONSTANTS.YES(1) or WIP_CONSTANTS.NO(2). If null
 *                        , we will default to WIP_CONSTANTS.NO.
 * x_returnStatus         There are 3 possible values
 *                        *fnd_api.g_ret_sts_success*
 *                        means the move transaction succesfully
 *                        processed
 *                        *fnd_api.g_ret_sts_error*
 *                        means backflush transaction need more info about
 *                        lot/serial
 *                        *fnd_api.g_ret_sts_unexp_error*
 *                        means an exception occurred
 *
 * NOTE:
 * The user don't need to insert child record for online over move/ over
 * completion. This API will take care everything. The user also don't need
 * to call QA API for online transaction either.
 ***************************************************************************/

PROCEDURE processIntf(p_group_id             IN        NUMBER,
                      p_proc_phase           IN        NUMBER,
                      p_time_out             IN        NUMBER,
                      p_move_mode            IN        NUMBER,
                      p_bf_mode              IN        NUMBER,
                      p_mtl_mode             IN        NUMBER,
                      p_endDebug             IN        VARCHAR2,
                      p_initMsgList          IN        VARCHAR2,
                      p_insertAssy           IN        VARCHAR2,
                      p_do_backflush         IN        VARCHAR2,
                      p_child_txn_id         IN        NUMBER := NULL,
                      p_assy_header_id       IN        NUMBER := NULL,
                      p_mtl_header_id        IN        NUMBER := NULL,
                      p_cmp_txn_id           IN        NUMBER := NULL,
                      p_seq_move             IN        NUMBER := NULL,
                      -- Fixed bug 4361566.
                      p_allow_partial_commit IN  NUMBER := NULL,
                      x_returnStatus         OUT NOCOPY VARCHAR2);

/***************************************************************************
 *
 * This procedure will be called from WIP OA Transaction page to do move,
 * easy-return, easy-completion, and scrap transaction for Discrete jobs.
 * The user need to insert the record into WIP_MOVE_TXN_INTERFACE before
 * calling this routine.
 *
 * PARAMETER:
 *
 * p_group_id             group_id in WIP_MOVE_TXN_INTERFACE
 * p_child_txn_id         transaction_id of the child record. This is the id
 *                        we passed to backflush processor to collect
 *                        lot/serial info for Mobile Application. Only use
 *                        for Online Over Move transaction from mobile.
 * p_mtl_header_id        (Components)transaction_header_id in
 *                        MTL_MATERIAL_TRANSACTIONS_TEMP. It is used when
 *                        called by completion processor for overcompletion
 *                        transaction and if called from WIP Move,
 *                        WIP Completion and OSFM Move forms. Caller can
 *                        generate this value from mtl_material_transactions_s
 * p_do_backflush         This flag will be used to determine whether the
 *                        move processor should insert backflush record or not.
 *                        If called from form/mobile, form/mobile will be the
 *                        one who insert backflush records, so pass 'F'.
 *                        If called from move manager pass 'T'.
 * p_assySerial           Assembly serial number. This parameter will be used
 *                        to differentiate between regular and serialized
 *                        transactions.
 * p_print_label          Print Label flag. This parameter will be used to pass
 *                        the value of the Administrator preference 'Standard
 *                        Operations for Move Labels' for the current transaction.
 * x_return_status        There are 2 possible values
 *                        *fnd_api.g_ret_sts_success*
 *                        means the every record was succesfully processed
 *                        *fnd_api.g_ret_sts_error*
 *                        means some records error out
 *
 * NOTE:
 * The user don't need to insert child record for online over move/ over
 * completion. This API will take care everything. The user also don't need
 * to call QA API for online transaction either.
 ***************************************************************************/

PROCEDURE processOATxn(p_group_id       IN        NUMBER,
                       p_child_txn_id   IN        NUMBER,
                       p_mtl_header_id  IN        NUMBER,
                       p_do_backflush   IN        VARCHAR2,
                       p_assySerial     IN        VARCHAR2:= NULL,
		       p_print_label    IN        NUMBER default null,/*VJ Label Printing*/
                       x_returnStatus  OUT NOCOPY VARCHAR2);

/***************************************************************************
 *
 * This procedure will be used to insert record into MMTA for repetitive
 * scrap.
 *
 * PARAMETER:
 *
 * p_tmp_id               MMTT.TRANSACTION_TEMP_ID
 * x_returnStatus         There are 2 possible values
 *                        *fnd_api.g_ret_sts_success*
 *                        means the move transaction succesfully
 *                        processed
 *                        *fnd_api.g_ret_sts_unexp_error*
 *                        means an exception occurred
 *
 * NOTE:
 * This procedure should be called only from WIP material processor
 *
 ***************************************************************************/
PROCEDURE repetitive_scrap(p_tmp_id       IN         NUMBER,
                           x_returnStatus OUT NOCOPY VARCHAR2);

/*****************************************************************************
 * This procedure is equivalent to witpssa_sched_alloc in wiltps.ppc
 * This procedure is used to allocate quantity to multiple reptitive schedule
 * it works for move, completion/return and over move/complete transactions
 ****************************************************************************/
 /* Fix for bug 5373061: Added parameter p_txn_date. We need it to
    compare it with WRS.date_released */

PROCEDURE schedule_alloc(p_org_id        IN        NUMBER,
                         p_wip_id        IN        NUMBER,
                         p_line_id       IN        NUMBER,
                         p_quantity      IN        NUMBER,
                         p_fm_op         IN        NUMBER,
                         p_fm_step       IN        NUMBER,
                         p_to_op         IN        NUMBER,
                         p_to_step       IN        NUMBER,
                         p_oc_txn_type   IN        NUMBER,
                         p_txnType       IN        NUMBER,
                         p_fm_form       IN        NUMBER,
                         p_comp_alloc    IN        NUMBER,
                         p_txn_date      IN        DATE, /* Bug 5373061 */
                         x_proc_status  OUT NOCOPY NUMBER,
                         x_sche_count   OUT NOCOPY NUMBER,
                         x_rsa          OUT NOCOPY rsa_tbl_t,
                         x_returnStatus OUT NOCOPY VARCHAR2);

/*****************************************************************************
 * This procedure will be used by WIP OA Transaction page to insert record
 * into WIP_MOVE_TXN_INTERFACE.
 ****************************************************************************/
PROCEDURE insert_record(p_transaction_id                 IN NUMBER,
                        p_last_update_date               IN DATE,
                        p_last_updated_by                IN NUMBER,
                        p_last_updated_by_name           IN VARCHAR2,
                        p_creation_date                  IN DATE,
                        p_created_by                     IN NUMBER,
                        p_created_by_name                IN VARCHAR2,
                        p_last_update_login              IN NUMBER,
                        p_request_id                     IN NUMBER,
                        p_program_application_id         IN NUMBER,
                        p_program_id                     IN NUMBER,
                        p_program_update_date            IN DATE,
                        p_group_id                       IN NUMBER,
                        p_source_code                    IN VARCHAR2,
                        p_source_line_id                 IN NUMBER,
                        p_process_phase                  IN NUMBER,
                        p_process_status                 IN NUMBER,
                        p_transaction_type               IN NUMBER,
                        p_organization_id                IN NUMBER,
                        p_organization_code              IN VARCHAR2,
                        p_wip_entity_id                  IN NUMBER,
                        p_wip_entity_name                IN VARCHAR2,
                        p_entity_type                    IN NUMBER,
                        p_primary_item_id                IN NUMBER,
                        p_line_id                        IN NUMBER,
                        p_line_code                      IN VARCHAR2,
                        p_repetitive_schedule_id         IN NUMBER,
                        p_transaction_date               IN DATE,
                        p_acct_period_id                 IN NUMBER,
                        p_fm_operation_seq_num           IN NUMBER,
                        p_fm_operation_code              IN VARCHAR2,
                        p_fm_department_id               IN NUMBER,
                        p_fm_department_code             IN VARCHAR2,
                        p_fm_intraoperation_step_type    IN NUMBER,
                        p_to_operation_seq_num           IN NUMBER,
                        p_to_operation_code              IN VARCHAR2,
                        p_to_department_id               IN NUMBER,
                        p_to_department_code             IN VARCHAR2,
                        p_to_intraoperation_step_type    IN NUMBER,
                        p_transaction_quantity           IN NUMBER,
                        p_transaction_uom                IN VARCHAR2,
                        p_primary_quantity               IN NUMBER,
                        p_primary_uom                    IN VARCHAR2,
                        p_scrap_account_id               IN NUMBER,
                        p_reason_id                      IN NUMBER,
                        p_reason_name                    IN VARCHAR2,
                        p_reference                      IN VARCHAR2,
                        p_attribute_category             IN VARCHAR2,
                        p_attribute1                     IN VARCHAR2,
                        p_attribute2                     IN VARCHAR2,
                        p_attribute3                     IN VARCHAR2,
                        p_attribute4                     IN VARCHAR2,
                        p_attribute5                     IN VARCHAR2,
                        p_attribute6                     IN VARCHAR2,
                        p_attribute7                     IN VARCHAR2,
                        p_attribute8                     IN VARCHAR2,
                        p_attribute9                     IN VARCHAR2,
                        p_attribute10                    IN VARCHAR2,
                        p_attribute11                    IN VARCHAR2,
                        p_attribute12                    IN VARCHAR2,
                        p_attribute13                    IN VARCHAR2,
                        p_attribute14                    IN VARCHAR2,
                        p_attribute15                    IN VARCHAR2,
                        p_qa_collection_id               IN NUMBER,
                        p_kanban_card_id                 IN NUMBER,
                        p_oc_transaction_qty             IN NUMBER,
                        p_oc_primary_qty                 IN NUMBER,
                        p_oc_transaction_id              IN NUMBER,
                        p_xml_document_id                IN VARCHAR2,
                        p_processing_order               IN NUMBER,
                        p_batch_id                       IN NUMBER,
                        p_employee_id                    IN NUMBER,
                        p_completed_instructions         IN NUMBER);

	 /*****************************************************************************
 	  * This procedure update the lock_flag value to 'N' in MMTT if the move
 	  * transaction failed during Move Processing Phase so that no records will
 	  * will stuck in MMTT. Added this procedure for fix of bug 8473023(FP 8358813)
 	  *
 	  * PARAMETER:
 	  *
 	  * p_assy_header_id              mmtt.transaction_header_id
 	  *
 	  ****************************************************************************/
 	  PROCEDURE clean_up(p_assy_header_id  IN         NUMBER);

END wip_movProc_priv;

/
