--------------------------------------------------------
--  DDL for Package QA_RESULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_RESULTS_PUB" AUTHID CURRENT_USER AS
/* $Header: qltpresb.pls 120.2.12010000.1 2008/07/25 09:22:07 appldev ship $ */


TYPE mesg_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

-- Start of comments
--	API name 	: qa_results_pub
--	Type		: Public
--	Function	: insert_row
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version         IN NUMBER	Required
--			  p_init_msg_list	IN VARCHAR2 	Optional
--						Default = FND_API.G_FALSE
--			  p_commit	    	IN VARCHAR2	Optional
--				Default = FND_API.G_FALSE
--			  p_validation_level	IN NUMBER	Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--			  parameter1
--			  parameter2
--				.
--				.
--	OUT		: x_return_status	OUT	VARCHAR2(1)
--				x_msg_count	OUT	NUMBER
--				x_msg_data	OUT	VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version		: Current version	1.0
--			  previous version	None
--			  Initial version 	1.0
--
-- End of comments

--
-- 12.1 QWB Usability Improvements
-- Added a new parameter p_ssqr_operation so that the
-- validation is not called while inserting
-- rows through the QWB application.
--
PROCEDURE insert_row (
    p_api_version          	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit			IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    p_plan_id               	IN  	NUMBER,
    p_spec_id               	IN  	NUMBER DEFAULT NULL,
    p_org_id                	IN  	NUMBER,
    p_transaction_number    	IN  	NUMBER DEFAULT NULL,
    p_transaction_id        	IN  	NUMBER DEFAULT NULL,
    p_who_last_updated_by   	IN  	NUMBER := fnd_global.user_id,
    p_who_created_by        	IN  	NUMBER := fnd_global.user_id,
    p_who_last_update_login 	IN  	NUMBER := fnd_global.user_id,
    p_enabled_flag	      	IN  	NUMBER,
    x_collection_id         	IN OUT  NOCOPY NUMBER,
    x_row_elements          	IN OUT 	NOCOPY qa_validation_api.ElementsArray,
    x_return_status		OUT	NOCOPY VARCHAR2,
    x_msg_count			OUT	NOCOPY NUMBER,
    x_msg_data			OUT	NOCOPY VARCHAR2,
    x_occurrence            	IN OUT 	NOCOPY NUMBER,
    x_action_result		OUT 	NOCOPY VARCHAR2,
    x_message_array 		OUT 	NOCOPY qa_validation_api.MessageArray,
    x_error_array 		OUT 	NOCOPY qa_validation_api.ErrorArray,
    p_txn_header_id             IN      NUMBER DEFAULT NULL,
    p_ssqr_operation            IN      NUMBER DEFAULT NULL,
    p_last_update_date          IN      DATE   DEFAULT SYSDATE);

--
-- 12.1 QWB Usability Improvements
-- Added a new parameter p_ssqr_operation so that the
-- validation is not called while updating
-- rows through the QWB application.
--
PROCEDURE update_row (
    p_api_version          	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit			IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    p_plan_id               	IN  	NUMBER,
    p_spec_id               	IN  	NUMBER DEFAULT NULL,
    p_org_id                	IN  	NUMBER,
    p_transaction_number    	IN  	NUMBER DEFAULT NULL,
    p_transaction_id        	IN  	NUMBER DEFAULT NULL,
    p_who_last_updated_by   	IN  	NUMBER := fnd_global.user_id,
    p_who_created_by        	IN  	NUMBER := fnd_global.user_id,
    p_who_last_update_login 	IN  	NUMBER := fnd_global.user_id,
    p_enabled_flag	      	IN  	NUMBER,
    p_collection_id         	IN      NUMBER,
    p_occurrence            	IN 	NUMBER,
    x_row_elements          	IN OUT 	NOCOPY qa_validation_api.ElementsArray,
    x_return_status		OUT	NOCOPY VARCHAR2,
    x_msg_count			OUT	NOCOPY NUMBER,
    x_msg_data			OUT	NOCOPY VARCHAR2,
    x_action_result		OUT 	NOCOPY VARCHAR2,
    x_message_array 		OUT 	NOCOPY qa_validation_api.MessageArray,
    x_error_array 		OUT 	NOCOPY qa_validation_api.ErrorArray,
    p_txn_header_id             IN      NUMBER DEFAULT NULL,
    p_ssqr_operation            IN      NUMBER DEFAULT NULL,
    p_last_update_date          IN      DATE   DEFAULT SYSDATE);


PROCEDURE enable_and_fire_action (
    p_api_version      	IN	NUMBER,
    p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    p_collection_id	IN	NUMBER,
    x_return_status	OUT 	NOCOPY VARCHAR2,
    x_msg_count		OUT 	NOCOPY NUMBER,
    x_msg_data		OUT 	NOCOPY VARCHAR2);


PROCEDURE commit_qa_results (
    p_api_version      	IN	NUMBER,
    p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    p_collection_id	IN	NUMBER,
    x_return_status	OUT 	NOCOPY VARCHAR2,
    x_msg_count		OUT 	NOCOPY NUMBER,
    x_msg_data		OUT 	NOCOPY VARCHAR2);

END qa_results_pub;


/
