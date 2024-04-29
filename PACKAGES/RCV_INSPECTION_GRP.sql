--------------------------------------------------------
--  DDL for Package RCV_INSPECTION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_INSPECTION_GRP" AUTHID CURRENT_USER AS
/* $Header: rcvginss.pls 120.4.12010000.1 2008/07/24 14:43:39 appldev ship $*/
--
--	API name 	: RCV_INSPECTION_GRP.INSERT_INSPECTION
--
--	Type		: Group.
--
--	Function	: This API serves to insert inspection transaction
--			  to the po interface table
--
--	Pre-reqs	: None.
--
--	Parameters	:
--
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	   	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_created_by		IN NUMBER	Required
--				p_last_updated_by	IN NUMBER 	Required
--				p_last_update_login	IN NUMBER	Required
--				p_employee_id		IN NUMBER	Required
--				p_group_id		IN NUMBER	Required
--					(Transaction Group Id)
--				p_transaction_id	IN NUMBER	Required
--					(Parent Transaction Id)
--				p_transaction_type	IN VARCHAR2	Required
--					(Reject or Accept)
--				p_processing_mode	IN VARCHAR2	Required
--					( 'ONLINE, 'IMMEDIATE', or 'BATCH')
--			        p_quantity		IN VARCHAR2     Required
--			        p_uom			IN VARCHAR2	Required
--			        p_quality_code		IN VARCHAR2	Optional
--					Default = NULL
--			        p_transaction_date	IN DATE		Required
--			        p_comments		IN VARCHAR2	Optional
--					Default = NULL
--			        p_reason_id		IN NUMBER	Optional
--					Default = NULL
--				p_vendor_lot		IN VARCHAR2	Optional
--					Default = NULL
--              p_lpn_id            IN NUMBER   Optional
--                  Default = NULL
--              p_transfer_lpn_id   IN NUMBER   Optional
--                  Default = NULL
--
--				p_qa_collection_id	IN NUMBER	Required
--	OUT		:	p_return_status		OUT	VARCHAR2(1)
--					'S' -- success
--					'U' -- unsuccess
--				p_msg_count		OUT	NUMBER
--				p_msg_data		OUT	VARCHAR2(2000)
--
--	Version		: Current version	1.1
--			  previous version	1.0
--			  Initial version 	1.0
--  History     : 1.1 - Added lpn_id and transfer_lpn_id
--
--	Notes		: User should pass the current version value to p_api_version
--			  If user needs to commit, pass 'T' to p_commit.
--

PROCEDURE Insert_Inspection
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level	IN  	NUMBER	 :=
					FND_API.G_VALID_LEVEL_FULL	,
	p_created_by		IN	NUMBER				,
	p_last_updated_by	IN	NUMBER				,
	p_last_update_login	IN	NUMBER				,
	p_employee_id		IN	NUMBER				,
	p_group_id		IN	NUMBER				,
	p_transaction_id	IN	NUMBER				,
	p_transaction_type	IN	VARCHAR2			,
	p_processing_mode	IN	VARCHAR2 			,
        p_quantity		IN 	NUMBER  			,
        p_uom			IN 	VARCHAR2			,
        p_quality_code		IN 	VARCHAR2 := NULL		,
        p_transaction_date	IN	DATE				,
        p_comments		IN 	VARCHAR2 := NULL		,
        p_reason_id		IN 	NUMBER	 := NULL		,
	p_vendor_lot		IN	VARCHAR2 := NULL		,
        p_qa_collection_id	IN	NUMBER				,
        p_lpn_id            IN NUMBER := NULL,
        p_transfer_lpn_id   IN NUMBER := NULL,
        p_from_subinventory     IN      VARCHAR2 DEFAULT NULL           , -- Added bug # 6529950
	p_from_locator_id       IN      NUMBER   DEFAULT NULL           , -- Added bug # 6529950
	p_subinventory          IN      VARCHAR2 DEFAULT NULL           , -- Added bug # 6529950
	p_locator_id            IN      NUMBER   DEFAULT NULL           , -- Added bug # 6529950
	p_return_status		OUT	NOCOPY VARCHAR2		  	,
	p_msg_count		OUT	NOCOPY NUMBER			,
	p_msg_data		OUT	NOCOPY VARCHAR2

);


END;

/
