--------------------------------------------------------
--  DDL for Package WIP_MOVPROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MOVPROC_PUB" AUTHID CURRENT_USER AS
/* $Header: wipmvpbs.pls 120.0 2005/05/25 08:18:17 appldev noship $*/

/***************************************************************************
 * This procedure will be used to do move, easy-return, easy-completion, and
 * scrap transaction for Discrete, OSFM jobs, and Repetitive Schedule. The
 * caller need to insert the record into WIP_MOVE_TXN_INTERFACE before calling
 * this routine. Caller can generate wmti.transaction_id and wmti.group_id
 * from the sequence wip_transactions_s. Caller need to insert both group_id
 * and transaction_id before calling the procedure below. These 2 columns
 * should have to same value. Caller should always insert wmti.process_phase =
 * 1(Validation) to make sure that the data inserted is valid, and insert
 * wmti.process_status = 2(Running) to prevent Move Manager from picking up
 * this record.
 *
 * PARAMETER:
 *
 * p_txn_id             transaction_id in WIP_MOVE_TXN_INTERFACE
 * p_do_backflush       this parameter determine whether move procesor has to
 *                      backflush pull component or not. Some customers use
 *                      third party software to insert backflush components, so
 *                      they do not want move processor to backflush them
 *                      again. The default value is null. If the callers do not
 *                      pass this parameter or pass fnd_api.g_true, we will
 *                      backflush pull component. Otherwise, we will not
 *                      backflush them. pass fnd_api.g_true or fnd_api.g_false.
 * p_commmit            commit the change to the database if succesfully
 *                      processing ? pass
 *                      fnd_api.g_true or fnd_api.g_false
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
PROCEDURE processInterface(p_txn_id       IN         NUMBER,
                           p_do_backflush IN         VARCHAR2 := NULL,
                           p_commit       IN         VARCHAR2,
                           x_returnStatus OUT NOCOPY VARCHAR2,
                           x_errorMsg     OUT NOCOPY VARCHAR2);

/***************************************************************************
 * This procedure will be used to do move, easy-return, easy-completion, and
 * scrap transaction for Discrete, OSFM jobs, and Repetitive Schedule. The
 * caller need to insert the record into WIP_MOVE_TXN_INTERFACE before calling
 * this routine. Caller can generate wmti.group_id from the sequence
 * wip_transactions_s. Only group_id is mandatory for procedure below. Caller
 * does not have to insert transaction_id. Caller should always insert
 * wmti.process_phase = 1(Validation) to make sure that the data inserted are
 * valid, and insert wmti.process_status = 2(Running) to prevent Move Manager
 * from picking up these records.
 *
 * PARAMETER:
 *
 * p_group_id           group_id in WIP_MOVE_TXN_INTERFACE
 * p_do_backflush       this parameter determine whether move procesor has to
 *                      backflush pull component or not. Some customers use
 *                      third party software to insert backflush components, so
 *                      they do not want move processor to backflush them
 *                      again. The default value is null. If the callers do not
 *                      pass this parameter or pass fnd_api.g_true, we will
 *                      backflush pull component. Otherwise, we will not
 *                      backflush them. pass fnd_api.g_true or fnd_api.g_false.
 * p_commmit            commit the change to the database if no record in this
 *                      group error out ? pass
 *                      fnd_api.g_true or fnd_api.g_false
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
PROCEDURE processInterface(p_group_id     IN         NUMBER,
                           p_do_backflush IN         VARCHAR2 := NULL,
                           p_commit       IN         VARCHAR2,
                           x_returnStatus OUT NOCOPY VARCHAR2);
END wip_movProc_pub;

 

/
