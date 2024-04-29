--------------------------------------------------------
--  DDL for Package CN_PMTSUB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PMTSUB_PUB" AUTHID CURRENT_USER as
-- $Header: cnppsubs.pls 120.1 2005/10/14 11:41:37 rnagired noship $
/*#
 * This procedure is used to pay a payrun and update the subledger, run the
 * concurrent program, and pay the payrun using a concurrent program.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Submit Payrun Concurrent Programs
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */
--============================================================================
-- Start of Comments
--
-- API name 	: Pay_Payrun
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Transfers the information to the cn_payment_api table and
--                updates the salesperson subledger to reflect the amount paid
-- Desc 	: Procedure to Pay Payrun
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_Payrun_name 	IN            cn_payruns.name%TYPE
--
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

--============================================================================
/*#
 * This procedure is used to pay a payrun and update the subledger.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after update
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the update operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param p_payrun_name Payrun name
 * @param x_status Status
 * @param x_loading_status Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Pay Payrun
 */
 PROCEDURE  Pay
   (    p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := cn_api.g_false,
	p_commit	    		IN  	VARCHAR2 := cn_api.g_false,
	p_validation_level		IN  	NUMBER   := cn_api.g_valid_level_full,
        x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
    	p_payrun_name                   IN      cn_payruns.name%TYPE,
	p_org_id              IN NUMBER,
    	x_status            	 OUT NOCOPY 	VARCHAR2,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2
	) ;

--============================================================================
-- Start of Comments
--
-- API name 	: Pay_Payrun_conc
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Transfers the information to the cn_payment_api table and
--                updates the salesperson subledger to reflect the amount paid
-- Desc 	: Procedure to Pay Payrun using a concurrent program
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_Payrun_name 	IN            cn_payruns.name%TYPE
--
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

--============================================================================
/*#
 * This procedure is used as the executable for the concurrent program CN_PAY_PAYRUN to pay a payrun.
 * @param errbuf Concurrent request error buffer
 * @param retcode Concurrent request return code
 * @param p_name Payrun name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Pay Payrun concurrent program
 */
 PROCEDURE Pay_Payrun_conc
    ( errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER ,
    p_name            cn_payruns.name%TYPE );

--============================================================================
/*#
 * This procedure is used to pay a payrun using a concurrent program.
 * @param p_payrun_id Unique identifier of payrun
 * @param x_request_id Unique identifier of concurrent request
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Submit Pay Payrun concurrent request
 */
 PROCEDURE submit_request (p_payrun_id    IN   NUMBER,
                            x_request_id    OUT NOCOPY  NUMBER) ;
END CN_PmtSub_PUB ;

 

/
