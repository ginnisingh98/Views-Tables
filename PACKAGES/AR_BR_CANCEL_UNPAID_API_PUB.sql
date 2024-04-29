--------------------------------------------------------
--  DDL for Package AR_BR_CANCEL_UNPAID_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BR_CANCEL_UNPAID_API_PUB" AUTHID CURRENT_USER AS
/* $Header: ARBRUOCS.pls 120.7 2005/05/21 19:13:02 apandit ship $*/
/*#
* Unpaid Bill API sets the status for each unpaid bill receivable to
* Unpaid or Canceled based on the Cancel Bill Receivable Flag value.
* It validates the BR number and status and calls the accounting engine
* to perform the appropriate accounting.
* @rep:scope public
* @rep:product AR
* @rep:lifecycle active
* @rep:displayname Unpaid Bill
* @rep:category BUSINESS_ENTITY AR_BILLS_RECEIVABLE
*/

/*#
 * This procedure is the main procedure for the Unpaid Bill API.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_validation_level Validation level
 * @param p_customer_trx_id  Bill Receivable transaction ID
 * @param p_cancel_flag      Cancel Bill Receivable flag
 * @param p_reason     Reason
 * @param p_gl_date   GL date
 * @param p_comments   Comments
 * @param p_org_id    Org ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Bill Receivable -as Canceled or Unpaid
  */

PROCEDURE CANCEL_OR_UNPAID(
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 default FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 default FND_API.G_FALSE,
    p_validation_level IN  NUMBER   default FND_API.G_VALID_LEVEL_FULL,

    p_customer_trx_id  IN  NUMBER,
    p_cancel_flag      IN  VARCHAR2,
    p_reason           IN  VARCHAR2,
    p_gl_date          IN  DATE,
    p_comments         IN  VARCHAR2,
    p_org_id           IN  NUMBER default null,
    x_bill_status      OUT NOCOPY VARCHAR2

);


END AR_BR_CANCEL_UNPAID_API_PUB;

 

/
