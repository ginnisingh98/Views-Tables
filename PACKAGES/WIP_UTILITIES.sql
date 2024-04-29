--------------------------------------------------------
--  DDL for Package WIP_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: wiputils.pls 120.5.12010000.2 2008/10/06 16:57:09 hliew ship $ */

/*=====================================================================+
 | PROCEDURE
 |   DO_SQL
 |
 | PURPOSE
 |   Executes a dynamic SQL statement
 |
 | ARGUMENTS
 |   p_sql_stmt   String holding sql statement.  May be up to 8K long.
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
  PROCEDURE DO_SQL(p_sql_stmt in varchar2);

/*=====================================================================+
 | Function
 | is_status_applicable
 |
 | Description
 |   Wrapper function for INV_MATERIAL_STATUS_GRP.is_status_applicable, checks if WMS
 |   is installed, before calling the INV code.
 |
 | Input Paramters
 |
 |   p_trx_status_enabled          Indicate if the transaction type is status control
 |                                 Enabled or not
 |                                 passing 1 for enabled, 2 for disabled
 |                                 this is optional, passing this value can increase the
 |                                 the processing speed
 |   p_trx_type_id                 transaction type id
 |   p_lot_status_enabled          Indicate if the item is lot status control
 |                                 Enabled or not
 |                                 passing 'Y' for enabled, 'N' for disabled
 |                                 this is optional, passing this value can increase the
 |                                 the processing speed
 |   p_serial_status_enabled       Indicate if the item is serial status control
 |                                 Enabled or not
 |                                 passing 'Y' for enabled, 'N' for disabled
 |                                 this is optional, passing this value can increase the
 |                                 the processing speed
 |   p_organization_id             organization id the item resides in
 |   p_inventory_item_id           given item id we query for
 |   p_sub_code                    subinventory code
 |   p_locator_id                  locator id
 |   p_lot_number                  lot number
 |   p_serial_number               serial number
 |   p_object_type                 this parameter is for performance purpose
 |                                 must be specified to get the proper function
 |                                 'Z' checking zone (subinventory)
 |                                 'L' checking locator
 |                                 'O' checking lot
 |                                 'S' checking serial
 |                                 'A' checking all including sub, locator, lot, serial
 |
 |
 |
 |  Return:
 |     'Y'  the given object's status allow the given transaction type or any error occurred
 |     'N'  the given object's status disallow the given transaction type
 |
 | Usage:
 |    TO check any object (sub, locator, lot or serial) is applicable or not,
 |    p_trx_type_id, p_organization_id, p_object_type must be specified.
 |    Additionally,
 |    to check subinventory, p_sub_code must be specified;
 |    to check locator, p_locator_id must be specified;
 |    to check lot,p_inventory_item_id, p_lot_number must be specified
 |    to check serial, p_inventory_item_id, p_serial_number must be specified
 |
 |    p_trx_status_enabled is optional for all checkings
 |    p_lot_status_enabledled is optional for checking lot status,
 |    p_serial_status_enabled is optional for checking serial status
 |    The default value is NULL for all input parameters except p_wms_installed
 +=====================================================================*/

Function is_status_applicable( p_trx_status_enabled         IN NUMBER:=NULL,
                           p_trx_type_id                IN NUMBER:=NULL,
                           p_lot_status_enabled         IN VARCHAR2:=NULL,
                           p_serial_status_enabled      IN VARCHAR2:=NULL,
                           p_organization_id            IN NUMBER:=NULL,
                           p_inventory_item_id          IN NUMBER:=NULL,
                           p_sub_code                   IN VARCHAR2:=NULL,
                           p_locator_id                 IN NUMBER:=NULL,
                           p_lot_number                 IN VARCHAR2:=NULL,
                           p_serial_number              IN VARCHAR2:=NULL,
                           p_object_type                IN VARCHAR2:=NULL)
return varchar2;

/*=====================================================================+
 | PROCEDURE
 |   print_label_java
 |
 | PURPOSE
 |   A wrapper to call the Label Printing capability introduced in H.
 |   This procedure should be used instead of print_label if called from
 |   java.  The p_err_msg basically concatenates all error messages on
 |   the stack if an error is returned from WMS.
 |
 | ARGUMENTS
 |   p_txn_id     an id to either MTI.transaction_header_id or to
 |                MMTT.transaction_header_id depending on p_table_type
 |   p_table_type either 1 (MTI) or 2 (MMTT)
 |   p_ret_status return status returned from INV_LABEL.print_label_wrap
 |   p_err_msg    actual error messages from the msg stack
 |   p_business_flow_code   business flow code, either 26 (comp) or 33 (flow)
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
  procedure print_label_java(p_txn_id              IN NUMBER,
                             p_table_type          IN  NUMBER, -- 1 MTI, 2 MMTT
                             p_ret_status          OUT  NOCOPY VARCHAR2,
                             p_err_msg             OUT  NOCOPY VARCHAR2,
                             p_business_flow_code  IN  NUMBER);

/*=====================================================================+
 | PROCEDURE
 |   print_label
 |
 | PURPOSE
 |   A wrapper to call the Label Printing capability introduced in H.
 |
 | ARGUMENTS
 |   p_txn_id     an id to either MTI.transaction_header_id or to
 |                MMTT.transaction_header_id depending on p_table_type
 |   p_table_type either 1 (MTI) or 2 (MMTT)
 |   p_ret_status return status returned from INV_LABEL.print_label_wrap
 |   p_msg_count  number of error messages from INV_LABEL.print_label_wrap
 |   p_msg_data   actual error messages from INV_LABEL.print_label_wrap
 |   p_label_status  returned from INV_LABEL.print_label_wrap
 |   p_business_flow_code   business flow code, either 26 (comp) or 33 (flow)
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
procedure print_label(p_txn_id              IN  NUMBER,
                      p_table_type          IN  NUMBER, -- 1 MTI 2 MMTT
                      p_ret_status          OUT  NOCOPY VARCHAR2,
                      p_msg_count           OUT  NOCOPY NUMBER,
                      p_msg_data            OUT  NOCOPY VARCHAR2,
                      p_label_status        OUT  NOCOPY VARCHAR2,
                      p_business_flow_code  IN  NUMBER);


/*=====================================================================+
 | PROCEDURE
 |   print_label
 |
 | PURPOSE
 |   A wrapper to call the Label Printing capability introduced in H.
 |
 | ARGUMENTS
 |   <in arguments> these are passed directly to the inventory call.
 |   p_ret_status return status returned from INV_LABEL.print_label_manual_wrap
 |   p_msg_count  number of error messages from INV_LABEL.print_label_manual_wrap
 |   p_msg_data   actual error messages from INV_LABEL.print_label_manual_wrap
 |   p_label_status  returned from INV_LABEL.print_label_manual_wrap
 |   p_business_flow_code   business flow code, either 26 (comp) or 33 (flow)
 |
 | EXCEPTIONS
 |
 | NOTES
 | This version is a generic wrapper to the INV_LABEL.print_label_manual_wrap. This
 | version should be used when printing labels not associated with a transaction in
 | the inventory interface tables, e.g. from the associate serial numbers form.
 +=====================================================================*/
procedure print_label(p_business_flow_code  IN  NUMBER DEFAULT NULL,
                      p_label_type_id       IN  NUMBER DEFAULT NULL,
                      p_organization_id     IN  NUMBER DEFAULT NULL,
                      p_inventory_item_id   IN  NUMBER DEFAULT NULL,
                      p_revision            IN  VARCHAR2 DEFAULT NULL,
                      p_lot_number          IN  VARCHAR2 DEFAULT NULL,
                      p_fm_serial_number    IN  VARCHAR2 DEFAULT NULL,
                      p_to_serial_number    IN  VARCHAR2 DEFAULT NULL,
                      p_lpn_id              IN  NUMBER DEFAULT NULL,
                      p_subinventory_code   IN  VARCHAR2 DEFAULT NULL,
                      p_locator_id          IN  NUMBER DEFAULT NULL,
                      p_delivery_id         IN  NUMBER DEFAULT NULL,
                      p_quantity            IN  NUMBER DEFAULT NULL,
                      p_uom                 IN  VARCHAR2 DEFAULT NULL,
                      p_no_of_copies        IN  NUMBER DEFAULT NULL,
                      p_ret_status          OUT  NOCOPY VARCHAR2,
                      p_msg_count           OUT  NOCOPY NUMBER,
                      p_msg_data            OUT  NOCOPY VARCHAR2,
                      p_label_status        OUT NOCOPY VARCHAR2);

/*=====================================================================+
 | PROCEDURE
 |   get_message_stack
 |
 | PURPOSE
 |   Flattens out the message stack into one string. The messages are separated
 |   by a single space. This procedure should only be used for mobile applications
 |   or to print messages to a log file. Forms should loop through the message stack
 |   and display the messages individually.
 |
 | ARGUMENTS
 | p_msg -- The flattened stack.
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
procedure get_message_stack(p_delete_stack in varchar2 := null,
                            p_separator in varchar2 := null,
                            p_msg OUT NOCOPY VARCHAR2);

/*=====================================================================+
 | PROCEDURE
 |   delete_temp_records
 |
 | PURPOSE
 |   Deletes all records for the given transaction in the mtl temp tables.
 |   This method is used by both discrete and flow LPN completions, which
 |   insert records into the temp tables for processing but need to remove
 |   them afterwards.
 |
 | ARGUMENTS
 |  p_header_id (the transaction_header_id for this transaction)
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
procedure delete_temp_records(p_header_id IN NUMBER);
procedure delete_temp_records(p_temp_id IN NUMBER);


/*=====================================================================+
 | PROCEDURE
 | update_serial
 |
 | PURPOSE
 | Updates the wip_entity_id, operation_seq_num, and intraoperation_step_type
 | of the serial number. Currently all three will be updated with the passed
 | value since the caller generally knows all the values
 |
 | ARGUMENTS
 |  p_header_id (the transaction_header_id for this transaction)
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
procedure update_serial(p_serial_number in VARCHAR2,
                        p_inventory_item_id in number,
                        p_organization_id in number,
                        p_wip_entity_id in number,
                        p_line_mark_id in number := null,
                        p_operation_seq_num in number,
                        p_intraoperation_step_type in number,
                        x_return_status OUT NOCOPY VARCHAR2);



/*=====================================================================+
 | PROCEDURE
 | generate_serials
 |
 | PURPOSE
 | Generate serial numbers.
 | ARGUMENTS
 |  p_wip_entity_id  The value to be stamped on the MSN column wip_entity_id
 |  x_start_serial   The first serial generated (alphabetically)
 |  x_end_serial     The last serial generated (alphabetically)
 |
 | EXCEPTIONS
 |
 | NOTES
 | If there is an existing serial number in between the x_start_serial and
 | x_end_serial, that number is skipped. For this purpose, the caller should
 | always query by current_status, group_mark_id, line_mark_id, and if
 | applicable wip_entity_id. Also, the inventory item attributes to do with
 | serial number generation should be defined for the item for this procedure
 | to return successfully.
 +=====================================================================*/

procedure generate_serials(p_org_id in NUMBER,
                           p_item_id in NUMBER,
                           p_qty IN NUMBER,
                           p_wip_entity_id IN NUMBER,
                           p_revision in VARCHAR2,
                           p_lot in varchar2,
                           x_start_serial IN OUT  NOCOPY VARCHAR2,
                           x_end_serial OUT  NOCOPY VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_err_msg OUT NOCOPY VARCHAR2);

/*=====================================================================+
 | FUNCTION
 | require_lot_attributes
 |
 | PURPOSE
 | To check whether completion lot number provided required lot attributes or
 | not. This function will be called for EZ Completion transaction because
 | we cannot gather lot attributes for EZ Completion transaction.
 |
 | ARGUMENTS
 |  p_org_id        organization_id in MTL_LOT_NUMBERS
 |  p_item_id       inventory_item_id in MTL_LOT_NUMBERS
 |  p_lot_number    lot_number in MTL_LOT_NUMBERS
 |
 | RETURN
 | WIP_CONSTANTS.YES if require lot attributes
 | WIP_CONSTANTS.NO if not require lot attributes
 |
 | EXCEPTIONS
 | If there is an unexpected error occur, also return WIP_CONSTANTS.NO.
 +=====================================================================*/
FUNCTION require_lot_attributes(p_org_id         IN NUMBER,
                                p_item_id        IN NUMBER,
                                p_lot_number     IN VARCHAR2)
RETURN NUMBER;

/*=====================================================================+
 | FUNCTION
 | get_locator
 |
 | PURPOSE
 | Returns the concatenated locator number (with project/task names).
 | Basically a wrapper around inv_project.get_locator, but as a
 | procedure.
 |
 | ARGUMENTS
 |  p_locator_id
 |  p_org_id
 |  p_locator
 |
 | EXCEPTIONS
 | This procedure is mainly used for e-records so there's no way to
 | return a status.
 +=====================================================================*/
PROCEDURE get_locator(p_locator_id         IN NUMBER,
                      p_org_id             IN NUMBER,
                      p_locator            OUT NOCOPY VARCHAR2);

/*=====================================================================+
 | FUNCTION
 | is_user_defined_lot_exp
 |
 | PURPOSE
 | To check whether lot expiration date was set to user-defined or not.
 | This function will be called for EZ Completion transaction because
 | we cannot gather lot expiration date for EZ Completion transaction.
 | This check only matter for the new lot. For existing lot, we can
 | EZ complete because we will use existing lot expiration date instead of
 | gathering the new expiration date.
 |
 | ARGUMENTS
 |  p_org_id        organization_id
 |  p_item_id       inventory_item_id
 |  p_lot_number    lot_number
 |
 | RETURN
 | WIP_CONSTANTS.YES if lot expiration date is user-defined
 | WIP_CONSTANTS.NO if lot expiration date is no control or shelf life days
 |
 | EXCEPTIONS
 | If there is an unexpected error occur, also return WIP_CONSTANTS.NO.
 +=====================================================================*/
FUNCTION is_user_defined_lot_exp(p_org_id         IN NUMBER,
                                 p_item_id        IN NUMBER,
                                 p_lot_number     IN VARCHAR2)
RETURN NUMBER;

/**************************************************************************
 * This function can be used to check whether descriptive flex field is
 * required or not. This function will return either fnd_api.g_true or
 * fnd_api.g_false.
 *************************************************************************/
FUNCTION is_dff_required(p_application_id IN NUMBER,
                         p_dff_name       IN VARCHAR2)
RETURN VARCHAR2;

/**************************************************************************
 * This function can be used to check whether descriptive flex field is
 * setup or not. This function will return either fnd_api.g_true or
 * fnd_api.g_false.
 *************************************************************************/
FUNCTION is_dff_setup(p_application_id IN NUMBER,
                      p_dff_name       IN VARCHAR2)
RETURN VARCHAR2;

/*=====================================================================+
 	     | FUNCTION
 	     | validate_scrap_account_id
 	     | Added this function for bug 7138983(FP 7028072).
 	     | PURPOSE
 	     | To check whether the scrap account id is valid for the specified
 	     | structure_id, in the current responsibility. It looks into security
 	     | rules while validating.This function will be called for validating
 	     | Scrap account id from WIPTXSFM.pld
 	     |
 	     | ARGUMENTS
 	     |  scrap_account_id
 	     |  chart_of_accounts_id
 	     |
 	     | RETURN
 	     | 'Y' if the combination is valid.
 	     | 'N' if the combination is invalid.
 	     |
 	     | EXCEPTIONS
 	     | If there is an unexpected error returns 'N'
 	     +=====================================================================*/
 	    FUNCTION validate_scrap_account_id ( scrap_account_id     IN NUMBER ,
 	                                         chart_of_accounts_id IN NUMBER )
 	    RETURN VARCHAR2 ;

--VJ: Label Printing - Start

PROCEDURE print_job_labels(p_wip_entity_id      IN NUMBER,
--                           p_op_seq_num         IN NUMBER,
			   x_status 		IN OUT NOCOPY VARCHAR2,
			   x_msg_count 		IN OUT NOCOPY NUMBER,
			   x_msg 		IN OUT NOCOPY VARCHAR2
                          );

PROCEDURE print_serial_label(p_org_id           IN NUMBER,
                             p_serial_number    IN VARCHAR2,
                             p_item_id          IN NUMBER,
			     x_status 		IN OUT NOCOPY VARCHAR2,
			     x_msg_count 	IN OUT NOCOPY NUMBER,
			     x_msg 		IN OUT NOCOPY VARCHAR2
                            );

PROCEDURE print_move_txn_label(p_txn_id         IN NUMBER,
                               x_status         IN OUT NOCOPY VARCHAR2,
                               x_msg_count      IN OUT NOCOPY NUMBER,
    	                       x_msg            IN OUT NOCOPY VARCHAR2
                              );

--VJ: Label Printing - End

END WIP_UTILITIES;

/
