--------------------------------------------------------
--  DDL for Package CN_PROCESS_TAE_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PROCESS_TAE_TRX_PUB" AUTHID CURRENT_USER as
--$Header: cnpptxws.pls 120.1 2005/11/25 03:08:30 rramakri noship $
/*#
 * This public package populates results from the Territory Assignment Engine
 * into Oracle Incentive Compensation transactions tables.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Populate TAE Data in OIC Public Application Program Interface
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

-- Start of Comments
-- API name 	: Process_Trx_Records
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: This procedure reads the territory resource from the TAE
-- 		  output table and populates the allocated resource information
--		  back to the OIC transaction interface table.
-- IN		:  p_api_version        IN NUMBER      Require
-- 		   p_init_msg_list      IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	        IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level   IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- Version	: Current version	1.0
--		  Initial version 	1.0

/*#
 * This procedure reads the territory resource from the TAE output table and
 * populates the allocated resource information back to the OIC transaction
 * interface table.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after create
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Populate Transaction Interface Table Records With Allocated Resource Information
 */

PROCEDURE Process_Trx_Records(

        p_api_version   	    	IN	NUMBER,
     	p_init_msg_list         	IN      VARCHAR2 	:= FND_API.G_TRUE,
	p_commit	            	IN      VARCHAR2 	:= FND_API.G_FALSE,
     	p_validation_level      	IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,

	x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
	p_org_id                        IN     NUMBER);


END CN_PROCESS_TAE_TRX_PUB;

 

/
