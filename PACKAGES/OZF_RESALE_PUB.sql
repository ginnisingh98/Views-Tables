--------------------------------------------------------
--  DDL for Package OZF_RESALE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_RESALE_PUB" AUTHID CURRENT_USER AS
/* $Header: ozfprsss.pls 120.4 2006/05/24 09:39:46 asylvia ship $ */
/*#
* This package defines the procedures that are required for processing
* indirect sales data. It includes the procedure definitions of
* Start_Process_Iface and Start_Purge
* @rep:scope public
* @rep:product OZF
* @rep:lifecycle active
* @rep:displayname Indirect Sales Data Processing Public API
* @rep:businessevent None
* @rep:category BUSINESS_ENTITY OZF_INDIRECT_SALES
*/


---------------------------------------------------------------------
-- PROCEDURE
--    Start_Process_Iface
--
-- PURPOSE
--    This procedure to initiate data process of records in resales interface table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
/*#
* This procedure starts the indirect sales data processing activity.
* @param p_api_version		This indicaters the  API version number.
* @param p_init_msg_list	This  indicates whether the message stack should be initialized.
* @param p_commit		Indicates whether to commit within the program.
* @param p_validation_level	Indicates the validation level.
* @param p_resale_batch_id	Identifies the resale batch that should be processed.
* @param x_return_status	This parameter dsiplays the program status.
* @param x_msg_data		Message returned by the program .
* @param x_msg_count		Number of mesaages the program returns.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Start Process Indirect Sales Data
*/
PROCEDURE Start_Process_Iface (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Start_Payment
--
-- PURPOSE
--    This procedure to initiate payment for a batch.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
/*#
* This procedure starts the payment processing.
* @param p_api_version		This is the API version number.
* @param p_init_msg_list	Indicates whether the message stack should be initialized.
* @param p_commit		Indicates whether to commit within the program.
* @param p_validation_level	This parameter indicates the validation level.
* @param p_resale_batch_id	Identifies the resale batch that should be processed.
* @param x_return_status	This parameter displays the program status.
* @param x_msg_data		This parameter is a return message from the program.
* @param x_msg_count		This is  the number of messages the program returns.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Start Process Indirect Sales Data
*/
PROCEDURE Start_Payment (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Start_Purge
--
-- PURPOSE
--    Purge the successfully processed records
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
/*#
* This procedure removes the processed and closed indirect sales data from the ozf_resale_lines_int_all interface table.
* @param p_api_version		API version number.
* @param p_init_msg_list	This parameter indicates whether to initialize the message stack.
* @param p_commit		This parameter indicates whether to commit within the program.
* @param p_validation_level	This parameter indicates the validation level.
* @param p_data_source_code	This parameter is the data source code of the batches whose line will be removed.
* @param x_return_status	Program status.
* @param x_msg_data Return	This parameter is a return message from the program.
* @param x_msg_count		This indicates the number of messages the program returned.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Start Purge Indirect Sales Data
*/
PROCEDURE Start_Purge
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_data_source_code       IN    VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

END OZF_RESALE_PUB;

 

/
