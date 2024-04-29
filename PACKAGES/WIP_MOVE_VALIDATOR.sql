--------------------------------------------------------
--  DDL for Package WIP_MOVE_VALIDATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MOVE_VALIDATOR" AUTHID CURRENT_USER AS
/* $Header: wipmovvs.pls 120.1 2005/08/05 16:03:16 kboonyap noship $ */

-- declare a PL/SQL table to store errors information
-- with three columns: transaction_id, error_column and error_message

TYPE request_error IS RECORD(transaction_id     NUMBER,
                             error_column       VARCHAR2(30),
                             error_message      VARCHAR2(240));

TYPE error_list IS TABLE OF request_error INDEX BY binary_integer;

TYPE txnID_list IS TABLE OF wip_move_txn_interface.transaction_id%TYPE INDEX BY binary_integer;

current_errors error_list ;
any_current_request boolean ;

-- Add an error message into PL/SQL table current_errors.
PROCEDURE add_error(p_txn_id  IN NUMBER,
                    p_err_col IN VARCHAR2,
                    p_err_msg IN VARCHAR2);

-- Add an error message into PL/SQL table current_errors.
PROCEDURE add_error(p_txn_ids IN txnID_list,
                    p_err_col IN VARCHAR2,
                    p_err_msg IN VARCHAR2);

-- Copy all errors from current_errors into WIP_TXN_INTERFACE_ERRORS.
PROCEDURE load_errors;

/***************************************************************************
 *
 * This procedure is used to validate all the necessary column in
 * WIP_MOVE_TXN_INTERFACE table before processing the record.
 * This procedure is very useful for background transaction inserted by
 * 3rd party softwares.
 *
 * PARAMETER:
 *
 * p_group_id             group_id in WIP_MOVE_TXN_INTERFACE
 * p_initMsgList          A flag used to determine whether the user want to
 *                        initialize message list or not
 * NOTE:
 * There is no return status from this routine. If some information is invalid,
 * update process_status in WIP_MOVE_TXN_INTERFACE to WIP_CONSTANTS.ERROR, and
 * the move processor will not process this record. We will also insert error
 * message into WIP_TXN_INTERFACE_ERRORS
 *
 ***************************************************************************/
PROCEDURE validate(p_group_id    IN NUMBER,
                   p_initMsgList IN VARCHAR2);

/* Fix for bug#2956953 - Added procedure organization_id which is called from
wip move maanger for validation of organization_id/organization_code
- Changes done as part of the Wip Move Sequencing Project */

PROCEDURE organization_id(p_count_of_errored OUT NOCOPY NUMBER);

/***************************************************************************
 *
 * The following two function/procedure returns the type of the move
 * transaction based on the transaction_id in wip_move_transactions.  The
 * possible return values are: Move transaction, Move and completion
 * transaction, Return and move transaction
 *
 * PARAMETER:
 *
 * p_move_id      transaction_id in wip_move_transactions
 * Following optional parameters were added for performance reasons.  If not
 * passed in, they will be queried from wip_move_transactions.
 * p_org_id              organization id of the move txn.
 * p_wip_entity_id       wip_entity_id of the job for the move txn
 * p_assm_item_id        the inventory_item_id of the assembly
 *
 ***************************************************************************/

FUNCTION move_txn_type(p_move_id        IN NUMBER,
                       p_org_id         IN NUMBER DEFAULT NULL,
                       p_wip_entity_id  IN NUMBER DEFAULT NULL,
                       p_assm_item_id   IN NUMBER DEFAULT NULL) return VARCHAR2;

PROCEDURE get_move_txn_type(p_move_id         IN NUMBER,
                            p_org_id          IN NUMBER DEFAULT NULL,
                            p_wip_entity_id   IN NUMBER DEFAULT NULL,
                            p_assm_item_id    IN NUMBER DEFAULT NULL,
                            p_txn_type        OUT NOCOPY VARCHAR2);

/***************************************************************************
 *
 * This procedure is used to validate transaction inserted by WIP OA page.
 *
 * PARAMETER:
 *
 * p_group_id             group_id in WIP_MOVE_TXN_INTERFACE

 * NOTE:
 * There is no return status from this routine. If some information is invalid,
 * update process_status in WIP_MOVE_TXN_INTERFACE to WIP_CONSTANTS.ERROR, and
 * the move processor will not process this record. We will also insert error
 * message into WIP_TXN_INTERFACE_ERRORS
 *
 ***************************************************************************/
PROCEDURE validateOATxn(p_group_id    IN NUMBER);


END wip_move_validator;

 

/
