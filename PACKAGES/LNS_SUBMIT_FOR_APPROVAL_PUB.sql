--------------------------------------------------------
--  DDL for Package LNS_SUBMIT_FOR_APPROVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_SUBMIT_FOR_APPROVAL_PUB" AUTHID CURRENT_USER as
/* $Header: LNS_SUBMIT_FOR_APPROVAL_PUB_S.pls 120.0.12000000.3 2007/05/09 11:32:53 mbolli noship $ */
/*#
 * Start of Comments
 * Package name     : LNS_SUBMIT_FOR_APPROVAL_PUB
 * Purpose          : Creates request for Loan Approval
 * History          :
 */
-- * @rep:scope public
-- * @rep:product LNS
-- * @rep:displayname Request For Loan Approval
-- * @rep:lifecycle active
-- * @rep:compatibility S
-- * @rep:category BUSINESS_ENTITY LOAN_APPROVAL_REQUEST


/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
/*
In the Comments below FK stands for Foreign Key. This type is passed as a
parameter to Submit_For_Approval API.
*/
TYPE Loan_Sub_For_Appr_err_type IS TABLE OF LNS_LOAN_CREATE_ERRORS_GT%ROWTYPE;


 /*========================================================================
 | PUBLIC PROCEDURE SUBMIT_FOR_APPROVAL
 |
 | DESCRIPTION
 |      This process
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION      - API Version
 |      P_COMMIT           - Passing 'Y' will result in an explicit commit
 |                           being issued in the API.
 |      P_Loan_id          - Loan_id of the loan for which we are requresting
 |                           for approval.
 |      X_RETURN_STATUS    - Returns 'S' for success and 'F' for Failure.
 |      X_MSG_COUNT        - Returns number of Errors.The errors are inserted
 |                           in the Global temporary table
 |                           LNS_LOAN_CREATE_ERRORS_GT.
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Mar-2007           MBOLLI          Created
 |
 *=======================================================================*/

/*#
 * Creates a Approval Request for a Loan
 * @param P_API_VERSION   API Version Number
 * @param P_COMMIT        Commit flag
 * @param P_APPROVAL_ACTION_REC Details about the request
 * @param P_AUTO_FUNDING_FLAG Funding Advice generation
 * @param X_ACTION_ID action ID of the created request
 * @param X_RETURN_STATUS API return status
 * @param X_MSG_COUNT     Number of error messages
 */
-- * @rep:scope internal
-- * @rep:displayname Submit Request for Loan Approval
-- * @rep:lifecycle active
-- * @rep:compatibility S


PROCEDURE SUBMIT_FOR_APPROVAL(
    P_API_VERSION           IN         NUMBER,
    P_COMMIT                IN         VARCHAR2,
    P_APPROVAL_ACTION_REC   IN	       LNS_APPROVAL_ACTION_PUB.APPROVAL_ACTION_REC_TYPE,
    P_AUTO_FUNDING_FLAG	    IN	       VARCHAR2,
    X_ACTION_ID             OUT NOCOPY NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER);

END LNS_SUBMIT_FOR_APPROVAL_PUB;

 

/
