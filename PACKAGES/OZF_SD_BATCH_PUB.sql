--------------------------------------------------------
--  DDL for Package OZF_SD_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SD_BATCH_PUB" AUTHID CURRENT_USER as
/* $Header: ozfpsdbs.pls 120.0.12010000.8 2009/05/20 09:41:36 annsrini noship $ */
/*#
* This package can be used to Update Supplier Ship and Debit Batch Header and Line Status for a NEW/WIP batch.
* @rep:scope public
* @rep:product OZF
* @rep:displayname OZF_SD_BATCH_PUB Public API
* @rep:compatibility S
* @rep:businessevent None
* @rep:category BUSINESS_ENTITY OZF_SSD_BATCH
*/

-- API Name	: MARK_BATCH_SUBMITTED
-- Type		: Public
-- PURPOSE	: This procedure Updates Supplier Ship and Debit Batch Header and Line status for a NEW/WIP batch
--              : and also marks the disputes as resolved for those lines in the WIP batch whose status is SUBMITTED
-- PARAMETERS   :
--         IN   : p_api_version_number
--              : p_init_msg_list
--              : p_batch_id
--        OUT   : x_return_status
--              : x_msg_count
--              : x_msg_data
-- NOTES        :
/*#
* This procedure updates Supplier Ship and Debit Batch Header and Line status for a NEW/WIP batch and also marks the disputes as resolved for those lines in the WIP batch whose status is SUBMITTED.
* @param p_api_version_number indicates the Version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_batch_id Batch Id for which Status is to be updated.
* @param x_return_status indicates the status of the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param x_msg_data returns messages by the program.
* @rep:scope public
* @rep:displayname Mark Batch Submitted
* @rep:compatibility S
* @rep:businessevent None
* @rep:category BUSINESS_ENTITY OZF_SSD_BATCH
*/

  PROCEDURE Mark_Batch_Submitted (p_api_version_number      IN NUMBER,
			          p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
			          p_batch_id		    IN NUMBER,
                                  x_return_status	    OUT nocopy VARCHAR2,
                 	          x_msg_count 	            OUT nocopy NUMBER,
			          x_msg_data		    OUT nocopy VARCHAR2
			         );

  END OZF_SD_BATCH_PUB;


/
