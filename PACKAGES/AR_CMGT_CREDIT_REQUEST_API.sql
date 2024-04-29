--------------------------------------------------------
--  DDL for Package AR_CMGT_CREDIT_REQUEST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_CREDIT_REQUEST_API" AUTHID CURRENT_USER AS
/* $Header: ARCMCRAS.pls 120.18.12010000.2 2009/11/18 23:51:45 rravikir ship $ */
/*#
 * Creates a credit request for initiating a credit review for a party,
 * account, or account site.  After the credit request is created with
 * minimal validations, an asynchronous workflow is initiated that
 * starts processing the credit request.
 * @rep:scope public
 * @rep:doccd 120ocmug.pdf Credit Management API User Notes, Oracle Credit Management User Guide
 * @rep:product OCM
 * @rep:lifecycle active
 * @rep:displayname Create Credit Request
 * @rep:category BUSINESS_ENTITY AR_CREDIT_REQUEST
 */

/*#
 * Use this procedure to create a credit request for initiating a credit review
 * for a party, account, or account site.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Credit Request
 */
/* bug4414414 : Added paramters p_parent_credit_request_id and p_credit_request_type
*/

   TYPE hold_reason_rec_type IS TABLE OF
       fnd_new_messages.message_name%TYPE;

   PROCEDURE create_credit_request
     ( p_api_version      IN NUMBER,
       p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_TRUE,
       p_commit            IN VARCHAR2,
       p_validation_level  IN VARCHAR2,
       x_return_status     OUT NOCOPY VARCHAR2,
       x_msg_count         OUT NOCOPY NUMBER,
       x_msg_data          OUT NOCOPY VARCHAR2,
       p_application_number  IN VARCHAR2,
       p_application_date    IN DATE,
       p_requestor_type      IN VARCHAR2,
       p_requestor_id        IN NUMBER, --this happens to be the HR person_id of
                                      --the requestor
       p_review_type           IN VARCHAR2,
       p_credit_classification IN VARCHAR2,
       p_requested_amount     IN NUMBER,
       p_requested_currency   IN VARCHAR2,
       p_trx_amount           IN NUMBER,
       p_trx_currency         IN VARCHAR2,
       p_credit_type          IN VARCHAR2,
       p_term_length          IN NUMBER,  --the unit is no of months
       p_credit_check_rule_id IN NUMBER,  --this is the credit check rule from the OM
       p_credit_request_status IN VARCHAR2, --SAVE or FINISH
       p_party_id             IN NUMBER,
       p_cust_account_id      IN NUMBER,
       p_cust_acct_site_id    IN NUMBER,
       p_site_use_id     IN NUMBER,
       p_contact_party_id     IN NUMBER, --this is the party_id of the pseudo party
                                       --created becoz of the contact relationship.
       p_notes                IN VARCHAR2,
       p_source_org_id               IN NUMBER,
       p_source_user_id              IN NUMBER,
       p_source_resp_id              IN NUMBER,
       p_source_appln_id             IN NUMBER,
       p_source_security_group_id    IN NUMBER,
       p_source_name          IN VARCHAR2,
       p_source_column1       IN VARCHAR2,
       p_source_column2       IN VARCHAR2,
       p_source_column3       IN VARCHAR2,
       p_credit_request_id    OUT NOCOPY NUMBER,
       p_review_cycle         IN VARCHAR2 DEFAULT NULL,
       p_case_folder_number   IN VARCHAR2 DEFAULT NULL,
       p_score_model_id	      IN NUMBER   DEFAULT NULL,
       p_parent_credit_request_id IN NUMBER  DEFAULT NULL,
       p_credit_request_type    IN VARCHAR2 DEFAULT NULL,
       p_reco                   IN VARCHAR2 DEFAULT NULL
       );

   /* Overloaded for hold_reason_rec parameter */
   PROCEDURE create_credit_request
     ( p_api_version      IN NUMBER,
       p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_TRUE,
       p_commit            IN VARCHAR2,
       p_validation_level  IN VARCHAR2,
       x_return_status     OUT NOCOPY VARCHAR2,
       x_msg_count         OUT NOCOPY NUMBER,
       x_msg_data          OUT NOCOPY VARCHAR2,
       p_application_number  IN VARCHAR2,
       p_application_date    IN DATE,
       p_requestor_type      IN VARCHAR2,
       p_requestor_id        IN NUMBER, --this happens to be the HR person_id of
                                      --the requestor
       p_review_type           IN VARCHAR2,
       p_credit_classification IN VARCHAR2,
       p_requested_amount     IN NUMBER,
       p_requested_currency   IN VARCHAR2,
       p_trx_amount           IN NUMBER,
       p_trx_currency         IN VARCHAR2,
       p_credit_type          IN VARCHAR2,
       p_term_length          IN NUMBER,  --the unit is no of months
       p_credit_check_rule_id IN NUMBER,  --this is the credit check rule from the OM
       p_credit_request_status IN VARCHAR2, --SAVE or FINISH
       p_party_id             IN NUMBER,
       p_cust_account_id      IN NUMBER,
       p_cust_acct_site_id    IN NUMBER,
       p_site_use_id     IN NUMBER,
       p_contact_party_id     IN NUMBER, --this is the party_id of the pseudo party
                                       --created becoz of the contact relationship.
       p_notes                IN VARCHAR2,
       p_source_org_id               IN NUMBER,
       p_source_user_id              IN NUMBER,
       p_source_resp_id              IN NUMBER,
       p_source_appln_id             IN NUMBER,
       p_source_security_group_id    IN NUMBER,
       p_source_name          IN VARCHAR2,
       p_source_column1       IN VARCHAR2,
       p_source_column2       IN VARCHAR2,
       p_source_column3       IN VARCHAR2,
       p_credit_request_id    OUT NOCOPY NUMBER,
       p_review_cycle         IN VARCHAR2 DEFAULT NULL,
       p_case_folder_number   IN VARCHAR2 DEFAULT NULL,
       p_score_model_id	      IN NUMBER   DEFAULT NULL,
       p_parent_credit_request_id IN NUMBER  DEFAULT NULL,
       p_credit_request_type    IN VARCHAR2 DEFAULT NULL,
       p_reco                   IN VARCHAR2 DEFAULT NULL,
       p_hold_reason_rec        IN hold_reason_rec_type
       );

FUNCTION is_Credit_Management_Installed RETURN BOOLEAN;

/*#
* Returns application number for a given credit request ID.
* @param p_credit_request_id Credit Request Id
* @return Application Number
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Application Number
 */

FUNCTION get_application_number
	( p_credit_request_id	IN	NUMBER)
 RETURN VARCHAR2;

END AR_CMGT_CREDIT_REQUEST_API; -- Package spec

/
