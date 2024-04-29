--------------------------------------------------------
--  DDL for Package OCM_CREDIT_REQUEST_UPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OCM_CREDIT_REQUEST_UPDATE_PUB" AUTHID CURRENT_USER AS
/*$Header: OCMUPCRS.pls 120.6 2006/06/30 22:10:21 bsarkar noship $  */
/*#
* This API updates a credit request based on the credit request ID. When
* a credit request is updated, its corresponding case folder is refreshed
* to reflect current data.
* @rep:scope public
* @rep:doccd 120ocmug.pdf Credit Management API User Notes, Oracle Credit Management User Guide
* @rep:product OCM
* @rep:lifecycle active
* @rep:displayname Update Credit Request
* @rep:category BUSINESS_ENTITY AR_CREDIT_REQUEST
*/

/*#
* Use this procedure to update a credit request.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Credit Request
*/

TYPE credit_request_rec IS RECORD (
        application_number  	          VARCHAR2(30)     DEFAULT NULL,
        application_date    	          DATE             DEFAULT NULL,
        requestor_type      	          VARCHAR2(30)     DEFAULT NULL,
        requestor_id        	          NUMBER           DEFAULT NULL,
        review_type           	          VARCHAR2(30)     DEFAULT NULL,
        credit_classification             VARCHAR2(30)     DEFAULT NULL,
        requested_amount     	          NUMBER       DEFAULT NULL,
        requested_currency   	          VARCHAR2(30)     DEFAULT NULL,
        trx_amount           	          NUMBER       DEFAULT NULL,
        trx_currency         	          VARCHAR2(30)     DEFAULT NULL,
        credit_type          	          VARCHAR2(30)     DEFAULT NULL,
        check_list_id          	          NUMBER     DEFAULT NULL,
        credit_analyst_id          	      NUMBER     DEFAULT NULL,
        term_length          	          NUMBER       DEFAULT NULL,
        credit_check_rule_id 	          NUMBER       DEFAULT NULL,
        credit_request_status	          VARCHAR2(30)     DEFAULT NULL,
        party_id             	          NUMBER       DEFAULT NULL,
        cust_account_id      	          NUMBER       DEFAULT NULL,
        cust_acct_site_id    	          NUMBER       DEFAULT NULL,
        site_use_id          	          NUMBER       DEFAULT NULL,
        contact_party_id     	          NUMBER       DEFAULT NULL,
        notes                		      VARCHAR2(2000)     DEFAULT NULL,
        source_org_id          	          NUMBER       DEFAULT NULL,
        source_user_id         	          NUMBER       DEFAULT NULL,
        source_resp_id         	          NUMBER       DEFAULT NULL,
        source_resp_appln_id        	  NUMBER       DEFAULT NULL,
        source_security_group_id          NUMBER       DEFAULT NULL,
        source_name          		      VARCHAR2(30)     DEFAULT NULL,
        source_column1       		      VARCHAR2(150)     DEFAULT NULL,
        source_column2       		      VARCHAR2(150)     DEFAULT NULL,
        source_column3       		      VARCHAR2(150)     DEFAULT NULL,
        credit_request_id    		      NUMBER       DEFAULT NULL,
        review_cycle          		      VARCHAR2(30)     DEFAULT NULL,
        case_folder_number   		      VARCHAR2(30)     DEFAULT NULL,
        score_model_id	      		      NUMBER       DEFAULT NULL,
        case_folder_id	      		      NUMBER       DEFAULT NULL,
        stock_exchange                    VARCHAR2(50) DEFAULT NULL,
        current_stock_price               NUMBER       DEFAULT NULL,
        stock_currency                    VARCHAR2(30) DEFAULT NULL,
        market_capitalization             NUMBER       DEFAULT NULL,
        market_cap_monetary_unit          VARCHAR2(15) DEFAULT NULL,
        pending_litigations               NUMBER       DEFAULT NULL,
        bond_rating                       VARCHAR2(30) DEFAULT NULL,
        legal_entity_name                 VARCHAR2(240) DEFAULT NULL,
        entity_type                       VARCHAR2(30) DEFAULT NULL,
        recommendation_name               VARCHAR2(30) DEFAULT NULL
         );

PROCEDURE UPDATE_CREDIT_REQUEST (
        p_api_version           IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2 DEFAULT FND_API.G_TRUE,
        p_commit                IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level      IN          VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY  NUMBER,
        x_msg_data              OUT NOCOPY  VARCHAR2,
        p_credit_request_rec    IN	credit_request_rec );

PROCEDURE GET_CREDIT_REQUEST_REC (
		p_credit_request_id		IN			  NUMBER,
		p_return_status			OUT NOCOPY	  VARCHAR2,
		p_error_msg				OUT NOCOPY 	  VARCHAR2,
        p_credit_request_rec    OUT NOCOPY    credit_request_rec );
/*#
 * Use this procedure to update a credit request status.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Credit Request Status
 */

PROCEDURE update_credit_request_status (
		p_api_version           IN          NUMBER,
        p_init_msg_list         IN          VARCHAR2 DEFAULT FND_API.G_TRUE,
        p_commit                IN          VARCHAR2,
        p_validation_level      IN          VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY  NUMBER,
        x_msg_data              OUT NOCOPY  VARCHAR2,
        p_credit_request_id		IN			NUMBER,
        p_credit_request_status	IN			VARCHAR2 DEFAULT 'SUBMIT');



END OCM_CREDIT_REQUEST_UPDATE_PUB;

 

/
