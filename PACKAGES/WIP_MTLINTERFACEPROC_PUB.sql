--------------------------------------------------------
--  DDL for Package WIP_MTLINTERFACEPROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MTLINTERFACEPROC_PUB" AUTHID CURRENT_USER as
/* $Header: wipintps.pls 120.0.12000000.1 2007/01/18 22:16:20 appldev ship $ */

/* This version process a single row *only*. If no rows are passed or more
 * than one is tied to the associated transaction_header_id this procedure will error.
 * parameters: p_txnIntID      The transaction_interface_id of the MTI row. As noted above,
 *                             this should be the only row tied to its associated transaction_header_id.
 *             p_commit        commit after successful processing? pass fnd_api.g_true or fnd_api.g_false
 *             x_returnStatus  fnd_api.g_ret_sts_success on successful processing of the transaction.
 *             x_errorMsg      contains the error message on failure. null on success.
 */
procedure processInterface(p_txnIntID IN NUMBER,
                           p_commit IN VARCHAR2 := fnd_api.g_false,
                           x_returnStatus OUT NOCOPY VARCHAR2,
                           x_errorMsg OUT NOCOPY VARCHAR2);

/* This version process multiple rows in MTI. All the rows tied to the header id should be WIP transactions.
 * The return status will be:
 * + fnd_api.g_ret_sts_success     if all rows processed successfully
 * + fnd_api.g_ret_sts_error       if one or more rows failed processing
 * + fnd_api.g_ret_sts_unexp_error if an unexpected exception occurred(e.g. a package was invalid)
 *
 * If the return status is not success, the caller should query the error_explanation column of the MTI rows to
 * find out which rows errored and for what reason.
 *
 * parameters: p_txnHdrID      The transaction_interface_id of the MTI row. As noted above,
 *                             this should be the only row tied to its associated transaction_header_id.
 *             p_commit        commit after successful processing? pass fnd_api.g_true or fnd_api.g_false
 *             x_returnStatus  fnd_api.g_ret_sts_success if all rows were processed successfully. See note
 *                             above for more details.
 */
procedure processInterface(p_txnHdrID IN NUMBER,
                           p_commit IN VARCHAR2 := fnd_api.g_false,
                           x_returnStatus OUT NOCOPY VARCHAR2);
end wip_mtlInterfaceProc_pub;

 

/
