--------------------------------------------------------
--  DDL for Package PO_CHANGE_API1_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHANGE_API1_S" AUTHID CURRENT_USER AS
/* $Header: POXCHN1S.pls 120.4.12010000.2 2013/09/12 10:34:15 jemishra ship $*/
/*#
 * This package contains procedures that enables you to record supplier
 * acceptance of your purchase orders and lets you create purchase
 * order revisions with changes to order quantity and/or price and/or
 * promised date of delivery.
 *
 * The procedure can be used to import change order data from other
 * legacy applications or to record acceptance or change orders from
 * your suppliers's applications.  All necessary validations are
 * performed before revising the purchase order with the changes.
 *
 * @rep:scope public
 * @rep:product PO
 * @rep:displayname Purchase Order Change APIs
 */

/*===================================================================
 * FUNCTION record_acceptance
 * API that records acceptance or rejection information
 * Parameters:
 * - x_po_number: PO Number of a document
 * - x_release_number: Release number of the doc. Null if not a release
 * - x_revision_number:  Revision of the doc the action is recorded against
 * - x_action: action
 * - x_action_date: action date
 * - x_employee_id: if it is null, then API uses agent_id from document
 * - x_accepted_flag: 'Y' or 'N'
 * - x_acceptance_lookup_code: must exist in PO_LOOKUP_CODES
 * - x_note: Free text
 * - x_interface_type: Default to 'CHANGEPO' if NULL
 * - x_transaction_id: default to PO_INTERFACE_ERRORS_S.nextval if NULL
 * - x_version: Version Checking
 *==================================================================*/

/*#
 * Record the acceptance or rejection of a purchase order by a supplier
 *
 * @param x_po_number Purchase order document
 * @rep:paraminfo {@rep:required}
 *
 * @param x_release_number Release number of the doc.
 * Null if not a release
 * @rep:paraminfo {@rep:required}
 *
 * @param x_revision_number  The revision of the purchase order/release
 * is being acted upon
 * @rep:paraminfo {@rep:required}
 *
 * @param x_action Indicates the action to take.  The value must be NEW
 * @rep:paraminfo {@rep:required}
 *
 * @param x_action_date Indicates the date of follow-up action.
 * Provide a value in the format of MM/DD/YY or MM-DD-YY.  Its
 * default value is TRUNC(SYSDATA)
 *
 * @param x_employee_id The fnd_global.user_id of the buyer
 * @rep:paraminfo {@rep:required}
 *
 * @param x_accepted_flag Indicate if purchase is accepted.
 * Must be 'Y' or 'N'
 * @rep:paraminfo {@rep:required}
 *
 * @param x_acceptance_lookup_code Type of acceptance, its value must
 * be corresponding to the LOOKUP_CODE in PO_LOOKUP_CODES table with
 * LOOKUP_TYPE of ACCEPTANCE TYPE. The possible values are: Accepted
 * Terms, Accepted All Terms, On Schedule, Unacceptable Changes, and
 * REJECTED.
 * @rep:paraminfo {@rep:required}
 *
 * @param x_note Free text
 *
 * @param x_interface_type Used to fetch any error messages recorded in
 * PO_INTERFACE_ERRORS table if the process fails. If not provided, a
 * default value will be used.
 *
 * @param x_transaction_id Used to fetch any error messages recorded in
 * PO_INTERFACE_ERRORS table if the process fails. If not provided, a
 * default value will be used.
 *
 * @param version Version of the current API (currently 1.0)
 * @rep:paraminfo {@rep:required}
 *
 * @param p_org_id  Internal ID for Operating Unit to which document
 * belongs. Not required if the document belongs to Current operating Unit
 * or to the the Default Operating.
 * @rep:paraminfo {@rep:innertype PO_HEADERS_ALL.org_id}
 *
 * @rep:displayname API that record the acceptance or rejection of
 * a purchase order by a supplier
 *
 * @rep:category BUSINESS_ENTITY PO_BLANKET_PURCHASE_AGREEMENT
 * @rep:category BUSINESS_ENTITY PO_CONTRACT_PURCHASE_AGREEMENT
 * @rep:category BUSINESS_ENTITY PO_GLOBAL_BLANKET_AGREEMENT
 * @rep:category BUSINESS_ENTITY PO_GLOBAL_CONTRACT_AGREEMENT
 * @rep:category BUSINESS_ENTITY PO_STANDARD_PURCHASE_ORDER
 * @rep:category BUSINESS_ENTITY PO_BLANKET_RELEASE
 * @rep:category BUSINESS_ENTITY PO_PLANNED_PURCHASE_ORDER
 * @rep:category BUSINESS_ENTITY PO_PLANNED_RELEASE
 */
FUNCTION record_acceptance
(
  X_PO_NUMBER			VARCHAR2,
  X_RELEASE_NUMBER		NUMBER,
  X_REVISION_NUMBER		NUMBER,
  X_ACTION			VARCHAR2,
  X_ACTION_DATE			DATE,
  X_EMPLOYEE_ID			NUMBER,
  X_ACCEPTED_FLAG		VARCHAR2,
  X_ACCEPTANCE_LOOKUP_CODE	VARCHAR2,
  X_NOTE			LONG,
  X_INTERFACE_TYPE      	VARCHAR2,
  X_TRANSACTION_ID      	NUMBER,
  VERSION			VARCHAR2,
  p_org_id          IN NUMBER DEFAULT NULL
) RETURN NUMBER;

/*===================================================================
 * FUNCTION validate_acceptance
 * Verify that recording acceptance can be performed on this document
 * Parameters:
 * - X_po_header_id: po_header_id of the document
 * - X_po_release_id: po_release_id of a release
 * - X_employee_id: Employee that is passed in
 * - x_revision_num: revision of the document
 * - x_interface_type: for error logging
 * - x_transaction_id: for error logging
 *==================================================================*/
FUNCTION validate_acceptance
( X_po_header_id 	IN	NUMBER,
  X_po_release_id 	IN	NUMBER,
  X_employee_id 	IN OUT	NOCOPY NUMBER,
  X_revision_num	IN	NUMBER,
  X_current_revision	IN OUT	NOCOPY NUMBER,
  X_interface_type	IN	VARCHAR2,
  X_transaction_id 	IN	NUMBER
) RETURN NUMBER;

/*===================================================================
 * FUNCTION check_mandatory_params
 * Check the presence of necessary parameters (po_number and revision_number),
 * as well as the version the caller is having
 *==================================================================*/
FUNCTION check_mandatory_params (
  X_PO_NUMBER			VARCHAR2,
  X_REVISION_NUMBER		NUMBER,
  VERSION			VARCHAR2,
  X_INTERFACE_TYPE		VARCHAR2,
  X_TRANSACTION_ID		NUMBER
) RETURN NUMBER;

/*=================================================================
 * PROCEDURE insert_error
 * insert seeded po error
 * Parameters:
 * p_interface_type: type of transaction
 * p_transaction_id: identifier of the transaction
 * p_table_name: table where the error comes from
 * p_message_name: seeded message name in PO
 * p_token_name: token for error
 * p_token_value: token value for error
 *=================================================================*/
PROCEDURE insert_error
( X_INTERFACE_TYPE	IN	VARCHAR2,
  X_transaction_id	IN	NUMBER,
  X_column_name		IN	VARCHAR2,
  X_TABLE_NAME		IN	VARCHAR2,
  X_MESSAGE_NAME	IN	VARCHAR2,
  X_token_name		IN	VARCHAR2,
  X_token_value		IN	VARCHAR2
);

-- <PO_CHANGE_API FPJ>
-- In file version 115.6, removed the X_INTERFACE_TYPE and X_TRANSACTION_ID
-- parameters from UPDATE_PO and added an X_API_ERRORS parameter, because
-- the PO Change API will no longer write error messages to the
-- PO_INTERFACE_ERRORS table. Instead, it will return all of the errors
-- in the x_api_errors object.

/*=====================================================================
 * FUNCTION update_po
 * API that updates qty, price or/and promised_date of a document.
 * Parameters:
 * - x_PO_NUMBER: po number of the document
 * - x_RELEASE_NUMBER: Null if not a release, otherwise, release number
 * - x_REVISION_NUMBER: should be the latest revision
 * - x_LINE_NUMBER: Line number of the doc.
 * - x_SHIPMENT_NUMBER: Shipment number
 * - NEW_QUANTITY : desired new quantity for a line/shipment
 * - NEW_PRICE    : desired new price for a line/shipment
 * - NEW_PROMISED_DATE: desired new promised date for a shipment
 * - NEW_NEED_BY_DATE: desired new need-by date for a shipment
 * - LAUNCH_APPROVALS_FLAG: determines whether approval workflow is
 *                            executed or not after update
 * - UPDATE_SOURCE: for future usage
 * - p_VERSION: version of the API that is intended to be used
 * - p_OVERRIDE_DATE: If funds are reserved for the document, this
 *                    parameter is to speicify the date that is used
 *                    to unreserve the doc. It's meaningless if
 *                    encumbrance is not used.
 * - X_API_ERRORS: If the return value is 0, this object will contain all
 *                 of the error messages.
 * - p_BUYER_NAME:  Added as a part of bug fix 2986718.
 *                  If you want to launch approval through somebody other
 *                  than the person who prepared the document then you
 *                  can use this parameter.
 * Returns:
 *   1 if the API completed successfully;
 *   0 if there will any errors.
 *======================================================================*/

/*#
 * Update a standard purchase order or release changes of
 * quantity, price and promise date
 *
 * @param x_PO_NUMBER Purchase order number
 * @rep:paraminfo {@rep:required}
 *
 * @param x_RELEASE_NUMBER Required if the purchase order is a release.
 * @rep:paraminfo {@rep:required}
 *
 * @param x_REVISION_NUMBER Which revision of the purchase
 * order/release is being acted upon.
 * @rep:paraminfo {@rep:required}
 *
 * @param x_LINE_NUMBER Purchase order line number to update.
 * @rep:paraminfo {@rep:required}
 *
 * @param x_SHIPMENT_NUMBER If provided, indicates the update occurs at
 * shipment level, otherwise, it is at line leve.
 *
 * @param NEW_QUANTITY Indicates the new value of quantity ordered that
 * the order should be updated to.
 * @rep:paraminfo {@rep:required}
 *
 * @param NEW_PRICE Indicates the new value of unit price that the
 * order should be updated to.
 * @rep:paraminfo {@rep:required}
 *
 * @param NEW_PROMISED_DATE Indicates the new value of promised date
 * that the order should be updated to. Must be in the format of
 * 'MM/DD/YY' or 'MM-DD-YY'.
 * @rep:paraminfo {@rep:required}
 *
 * @param NEW_NEED_BY_DATE Indicates the new value of need-by date
 * that the order should be updated to. Must be in the format of
 * 'MM/DD/YY' or 'MM-DD-YY'.
 * @rep:paraminfo {@rep:required}
 *
 * @param LAUNCH_APPROVALS_FLAG Indicates if you want to launch
 * APPROVAL workflow after the update. Its value could be either 'Y' or
 * 'N'. If not provided, the default value is 'N'.
 * @rep:paraminfo {@rep:required}
 *
 * @param UPDATE_SOURCE Reserved for future use to record the source of
 * the update.
 *
 * @param VERSION Version of the current API (currently 1.0).
 * @rep:paraminfo {@rep:required}
 *
 * @param X_OVERRIDE_DATE If the document is encumbered, this is the
 * date that will be used to un-reserve the document.
 *
 * @param X_API_ERRORS Holds the error messages if the update process
 * fails.
 *
 * @param p_BUYER_NAME Buyer Name whose approval path should be used
 * while submitting the document for approval.
 *
 * @param p_secondary_quantity New secondary quantity for the line or
 * shipment
 *
 * @param p_preferred_grade Preferred grade for the line or shipment
 *
 * @param p_org_id  Internal ID for Operating Unit to which document
 * belongs. Not required if the document belongs to Current operating Unit
 * or to the the Default Operating.
 * @rep:paraminfo {@rep:innertype PO_HEADERS_ALL.org_id}
 *
 * @rep:displayname API that update a standard purchase order
 * or release changes
 *
 * @rep:category BUSINESS_ENTITY PO_STANDARD_PURCHASE_ORDER
 * @rep:category BUSINESS_ENTITY PO_BLANKET_RELEASE
 * @rep:category BUSINESS_ENTITY PO_PLANNED_PURCHASE_ORDER
 * @rep:category BUSINESS_ENTITY PO_PLANNED_RELEASE
 */
FUNCTION update_po
(
  X_PO_NUMBER			VARCHAR2,
  X_RELEASE_NUMBER		NUMBER,
  X_REVISION_NUMBER		NUMBER,
  X_LINE_NUMBER			NUMBER,
  X_SHIPMENT_NUMBER		NUMBER,
  NEW_QUANTITY			NUMBER,
  NEW_PRICE			NUMBER,
  NEW_PROMISED_DATE		DATE,
  NEW_NEED_BY_DATE              DATE := NULL,
  LAUNCH_APPROVALS_FLAG		VARCHAR2,
  UPDATE_SOURCE			VARCHAR2,
  VERSION			VARCHAR2,
  X_OVERRIDE_DATE		DATE := NULL,
  -- <PO_CHANGE_API FPJ START>
  X_API_ERRORS                  OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  -- <PO_CHANGE_API FPJ END>
  p_BUYER_NAME                  VARCHAR2  default NULL,
  -- <INVCONV R12 START>
  p_secondary_quantity          NUMBER    ,
  p_preferred_grade             VARCHAR2,
    -- <INVCONV R12 END>
  p_org_id          IN NUMBER DEFAULT NULL
) RETURN NUMBER;


/*=====================================================================
 * PROCEDURE update_po
 * API that validates and applies the requested changes and any derived
 * changes to the Purchase Order
 * Parameters:
 * - p_api_version:
 *  -- API version number expected by the caller
 * - p_init_msg_list:
 *  -- If FND_API.G_TRUE, the API will initialize the standard API message list.
 * - x_return_status:
 *  --  FND_API.G_RET_STS_SUCCESS if the API succeeded and the changes are applied.
 *  --  FND_API.G_RET_STS_ERROR if one or more validations failed.
 *  --  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
 * - p_changes:
 *  --  object with the changes to make to the document
 * - x_api_errors:
 *  --  If x_return_status is not FND_API.G_RET_STS_SUCCESS, this
 *  --  PL/SQL object will contain all the error messages, including field-level
 *  --  validation errors, submission checks errors, and unexpected errors.
 *======================================================================*/
PROCEDURE update_po (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  p_changes                IN OUT NOCOPY po_pub_update_rec_type,
  x_api_errors             OUT NOCOPY PO_API_ERRORS_REC_TYPE
);

END PO_CHANGE_API1_S;

/
