--------------------------------------------------------
--  DDL for Package OCM_CREDIT_REQ_WITHDRAW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OCM_CREDIT_REQ_WITHDRAW_PUB" AUTHID CURRENT_USER AS
 /* $Header: OCMPWIDS.pls 120.3 2006/06/30 22:09:17 bsarkar noship $  */
/*#
* This API withdraws a credit request based on the credit request ID and
* immediately terminates all processing. The withdrawal reason code is
* stored for future reference.
* @rep:scope public
* @rep:doccd 120ocmug.pdf Credit Management API User Notes, Oracle Credit Management User Guide
* @rep:product OCM
* @rep:lifecycle active
* @rep:displayname Withdraw Credit Request
* @rep:category BUSINESS_ENTITY OCM_WITHDRAW_CREDIT_REQUEST
*/

/*#
* Use this procedure to withdraw a credit request.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Withdraw Credit Request
*/

PROCEDURE WITHDRAW_REQUEST (
		p_api_version                    IN 	NUMBER,
    	p_init_msg_list                  IN 	VARCHAR2 ,
    	p_commit                         IN 	VARCHAR2,
       	p_validation_level               IN 	VARCHAR2,
       	x_return_status                  OUT 	NOCOPY VARCHAR2,
       	x_msg_count                      OUT	NOCOPY NUMBER,
       	x_msg_data                       OUT 	NOCOPY VARCHAR2,
		p_credit_request_id				 IN	 	NUMBER,
		p_withdrawl_reason_code			 IN	 	VARCHAR2 );

END OCM_CREDIT_REQ_WITHDRAW_PUB;

 

/
