--------------------------------------------------------
--  DDL for Package Body GMF_LOTCOSTADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_LOTCOSTADJUSTMENT_PUB" AS
/* $Header: GMFPLCAB.pls 120.8.12000000.2 2007/03/15 10:16:03 pmarada ship $ */

--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFPLCAB.pls                                        |
--| Package Name       : GMF_LotCostAdjustment_PUB                           |
--| API name           : GMF_LotCostAdjustment_PUB			     |
--| Type               : Public                                              |
--| Pre-reqs	       : N/A                                                 |
--| Function	       : Lot Cost Adjustment Creation, Updation, Query and   |
--|			 	 Deletion 				     |
--|                                                                          |
--| Parameters	       : N/A                                                 |
--|                                                                          |
--| Current Vers       : 1.0                                                 |
--| Previous Vers      : None                                                |
--| Initial Vers       : 1.0                                                 |
--|                                                                          |
--| Notes                                                                    |
--|     This package contains public procedures relating to Lot Cost 	     |
--|     This package contains public procedures relating to Lot Cost 	     |
--|	Adjustment Creation, Updation, Query and Deletion		     |
--|                                                                          |
--| HISTORY                                                                  |
--|    22-Mar-2004  Anand Thiyagarajan  Created				     |
--|    02-Jun-2004  Bug 3655773: Added g_tmp variable to initialize          |
--|			G_Msg_Level_Threshold global variable.               |
--|                                                                          |
--+==========================================================================+

-- Procedure to log Error messages
PROCEDURE log_msg(p_msg_text      IN VARCHAR2);

--Procedure to add header record into error stack
PROCEDURE add_header_to_error_stack
(
 p_header_rec	GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
);

--Procedure to validate parameters
PROCEDURE Validate_Input_Params
(
p_header_Rec		IN OUT	NOCOPY	GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl		IN OUT	NOCOPY	GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
, p_operation		IN		VARCHAR2
, x_user_id		OUT	NOCOPY	fnd_user.user_id%TYPE
, x_return_status	OUT	NOCOPY	VARCHAR2
);

--Global Variables
G_PKG_NAME 	CONSTANT	VARCHAR2(30)	:=	'GMF_LotCostAdjustment_PUB ';

--
-- Bug 3655773: Added following variable to initialize G_Msg_Level_Threshold global
-- variable from the profile 'FND: Message Level Threshold'. Otherwise next assignment
-- stmt will fail since G_Msg_Level_Threshold is initialized to 9.99E125 in FND_MSG_PUB
-- package and will cause ORA-6502 error.
--
-- We could made the variable just NUMBER, but it was done the following way in other APIs.
-- So, doing the same here.
--
G_tmp		BOOLEAN := FND_MSG_PUB.Check_Msg_Level(0) ; -- temp call to initialize the
							    -- msg level threshhold gobal
							    -- variable.

G_debug_level			NUMBER(2)	:=	FND_MSG_PUB.G_Msg_Level_Threshold;

G_header_logged			VARCHAR2(1)	:=	'N';

--+========================================================================+
--| API Name	: Create_LotCost_Adjustment                                |
--| TYPE	: Public						   |
--| Function	: Creates Lot Cost Adjustment based on the input           |
--|			into table GMF_LOT_COST_ADJUSTMENTS                |
--| Pre-reqa	: None                                                     |
--| Parameters	:                                                          |
--| IN		:                                                          |
--|			p_api_version	IN  			NUMBER	   |
--|			p_init_msg_list	IN  			VARCHAR2   |
--|			p_header_rec	IN OUT NOCOPY 			   |
--|		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type	   |
--|			p_dtl_Tbl		IN OUT NOCOPY 		   |
--|		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type      |
--|									   |
--| OUT		: 							   |
--|			x_return_status	OUT NOCOPY 		VARCHAR2   |
--|			x_msg_count		OUT NOCOPY 	NUMBER     |
--|			x_msg_data		OUT NOCOPY 	VARCHAR2   |
--|                                                                        |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:							   |
--|  Pre-defined API message levels					   |
--|                                                                        |
--|     Valid values for message levels are from 1-50.			   |
--|      1 being least severe and 50 highest.				   |
--|                                                                        |
--|     The pre-defined levels correspond to standard API     		   |
--|     return status. Debug levels are used to control the amount of      |
--|      debug information a program writes to the PL/SQL message table.   |
--|                                                                        |
--| G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;                         |
--| G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;                         |
--| G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;                         |
--| G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;                         |
--| G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;                         |
--| G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;                         |
--|                                                                        |
--| HISTORY                                                                |
--|    22-Mar-2004  Anand Thiyagarajan  Created				   |
--|                                                                        |
--+========================================================================+

PROCEDURE Create_LotCost_Adjustment
(
p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN OUT 	NOCOPY 	Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl		IN OUT 	NOCOPY 	Lc_adjustment_dtls_Tbl_Type
)
IS
  l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Create_LotCost_Adjustment';
  l_api_version         CONSTANT 	NUMBER 		:= 2.0;
  l_header_exists			BOOLEAN;
  l_detail_exists			BOOLEAN;
  user_cnt				NUMBER;
  l_user_id              		fnd_user.user_id%TYPE ;
  l_return_status			VARCHAR2(11) ;
BEGIN
	-- Standard Start of API savepoint
	SAVEPOINT	 Create_LotCost_Adjustment_PUB ;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call	(l_api_version        	,
	    	    	    	 		p_api_version        	,
	    	 				l_api_name 		,
	    	    	    	    		G_PKG_NAME
						)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
    		log_msg('Beginning Create Lot Cost Adjustment process.');
	END IF;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
    		log_msg('Validating input parameters');
	END IF;

	G_header_logged := 'N';

	Validate_Input_Params
	(
        p_header_rec		=>	p_header_rec
	, p_dtl_tbl		=>	p_dtl_tbl
	, p_operation		=>	'INSERT'
	, x_user_id		=>	l_user_id
	, x_return_status	=>	l_return_status
	);

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
  		log_msg('Return Status after validating : ' || l_return_status);
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
	        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
		FND_MSG_PUB.Add;
	        RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
      		log_msg('Calling private API to insert record...');
	END IF;

	--Call Private Procedure
	GMF_LotCostAdjustment_PVT.Create_LotCost_Adjustment
	(
	p_api_version		=>		p_api_version
	, p_init_msg_list	=>		FND_API.G_FALSE
	, x_return_status	=>		x_return_status
	, x_msg_count		=>		x_msg_count
	, x_msg_data		=>		x_msg_data
	, p_header_rec		=>		p_header_Rec
	, p_dtl_Tbl		=>		p_dtl_tbl
        , p_user_id             =>              l_user_id
	);

        -- Return if insert fails for any reason
	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_INS');
	FND_MESSAGE.SET_TOKEN('NUM_ROWS',p_dtl_tbl.COUNT);
	FND_MSG_PUB.Add;

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit )
	THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    			   	(
				p_count         	=>      x_msg_count
				, p_data          	=>      x_msg_data
    				);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR
	THEN
		ROLLBACK TO Create_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
					(
					p_count         	=>      x_msg_count
					, p_data          	=>      x_msg_data
    					);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
		ROLLBACK TO Create_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    					(
					p_count         	=>      x_msg_count
					,p_data          	=>      x_msg_data
	    				);
	WHEN OTHERS
	THEN
		ROLLBACK TO Create_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg
    	    					(
						G_PKG_NAME
						, l_api_name
	    					);
		END IF;
		FND_MSG_PUB.Count_And_Get
    					(
					p_count         	=>      x_msg_count
					, p_data          	=>      x_msg_data
    					);
  END Create_LotCost_Adjustment;

--+========================================================================+
--| API Name	: Update_LotCost_Adjustment                                |
--| TYPE	: Public						   |
--| Function	: Updates Lot Cost Adjustment based on the input           |
--|			into table GMF_LOT_COST_ADJUSTMENTS                |
--| Pre-reqa	: None                                                     |
--| Parameters	:                                                          |
--| IN		:                                                          |
--|			p_api_version	IN  			NUMBER	   |
--|			p_init_msg_list	IN  			VARCHAR2   |
--|			p_header_rec	IN OUT NOCOPY 			   |
--|		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type	   |
--|			p_dtl_Tbl		IN OUT NOCOPY 		   |
--|		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type      |
--|									   |
--| OUT		: 							   |
--|			x_return_status	OUT NOCOPY 		VARCHAR2   |
--|			x_msg_count		OUT NOCOPY 	NUMBER     |
--|			x_msg_data		OUT NOCOPY 	VARCHAR2   |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:							   |
--|  Pre-defined API message levels					   |
--|                                                                        |
--|     Valid values for message levels are from 1-50.			   |
--|      1 being least severe and 50 highest.				   |
--|                                                                        |
--|     The pre-defined levels correspond to standard API     		   |
--|     return status. Debug levels are used to control the amount of      |
--|      debug information a program writes to the PL/SQL message table.   |
--|                                                                        |
--| G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;                         |
--| G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;                         |
--| G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;                         |
--| G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;                         |
--| G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;                         |
--| G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;                         |
--|                                                                        |
--| HISTORY                                                                |
--|    22-Mar-2004  Anand Thiyagarajan  Created				   |
--|                                                                        |
--+========================================================================+

PROCEDURE Update_LotCost_Adjustment
(
p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN OUT 	NOCOPY 	Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl		IN OUT 	NOCOPY 	Lc_adjustment_dtls_Tbl_Type
)
IS
  l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Update_LotCost_Adjustment';
  l_api_version         CONSTANT 	NUMBER 		:= 2.0;
  l_header_exists			BOOLEAN;
  l_detail_exists			BOOLEAN;
  user_cnt				NUMBER;
  l_user_id              		fnd_user.user_id%TYPE ;
  l_return_status			VARCHAR2(11) ;
BEGIN
	-- Standard Start of API savepoint
	SAVEPOINT	 Update_LotCost_Adjustment_PUB ;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call	(l_api_version        	,
	    	    	    	 		p_api_version        	,
	    	 				l_api_name 		,
	    	    	    	    		G_PKG_NAME
						)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
    		log_msg('Beginning Update Lot Cost Adjustment process.');
	END IF;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
    		log_msg('Validating input parameters');
	END IF;

	G_header_logged := 'N';

	Validate_Input_Params
	(
        p_header_rec		=>	p_header_rec
	, p_dtl_tbl		=>	p_dtl_tbl
	, p_operation		=>	'UPDATE'
	, x_user_id		=>	l_user_id
	, x_return_status	=>	l_return_status
	);

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
  		log_msg('Return Status after validating : ' || l_return_status);
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
	        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
		FND_MSG_PUB.Add;
	        RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
      		log_msg('Calling private API to Update record...');
	END IF;

	--Call Private Procedure
	GMF_LotCostAdjustment_PVT.Update_LotCost_Adjustment
	(
	p_api_version		=>		p_api_version
	, p_init_msg_list	=>		FND_API.G_FALSE
	, x_return_status	=>		x_return_status
	, x_msg_count		=>		x_msg_count
	, x_msg_data		=>		x_msg_data
	, p_header_rec		=>		p_header_Rec
	, p_dtl_Tbl		=>		p_dtl_tbl
        , p_user_id             =>              l_user_id
	);

	-- Return if update fails for any reason
	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_UPD');
	FND_MESSAGE.SET_TOKEN('NUM_ROWS',p_dtl_tbl.COUNT);
	FND_MSG_PUB.Add;

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit )
	THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    			   	(
				p_count         	=>      x_msg_count
				, p_data          	=>      x_msg_data
    				);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR
	THEN
		ROLLBACK TO Update_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
					(
					p_count         	=>      x_msg_count
					, p_data          	=>      x_msg_data
    					);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
		ROLLBACK TO Update_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    					(
					p_count         	=>      x_msg_count
					,p_data          	=>      x_msg_data
	    				);
	WHEN OTHERS
	THEN
		ROLLBACK TO Update_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg
    	    					(
						G_PKG_NAME
						, l_api_name
	    					);
		END IF;
		FND_MSG_PUB.Count_And_Get
    					(
					p_count         	=>      x_msg_count
					, p_data          	=>      x_msg_data
    					);
END Update_LotCost_Adjustment;

--+========================================================================+
--| API Name	: Delete_LotCost_Adjustment                                |
--| TYPE	: Public						   |
--| Function	: Deletes Lot Cost Adjustment based on the input           |
--|			from table GMF_LOT_COST_ADJUSTMENTS                |
--| Pre-reqa	: None                                                     |
--| Parameters	:                                                          |
--| IN		:                                                          |
--|			p_api_version	IN  			NUMBER	   |
--|			p_init_msg_list	IN  			VARCHAR2   |
--|			p_header_rec	IN OUT NOCOPY 			   |
--|		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type	   |
--|			p_dtl_Tbl		IN OUT NOCOPY 		   |
--|		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type      |
--|									   |
--| OUT		: 							   |
--|			x_return_status	OUT NOCOPY 		VARCHAR2   |
--|			x_msg_count		OUT NOCOPY 	NUMBER     |
--|			x_msg_data		OUT NOCOPY 	VARCHAR2   |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:							   |
--|  Pre-defined API message levels					   |
--|                                                                        |
--|     Valid values for message levels are from 1-50.			   |
--|      1 being least severe and 50 highest.				   |
--|                                                                        |
--|     The pre-defined levels correspond to standard API     		   |
--|     return status. Debug levels are used to control the amount of      |
--|      debug information a program writes to the PL/SQL message table.   |
--|                                                                        |
--| G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;                         |
--| G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;                         |
--| G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;                         |
--| G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;                         |
--| G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;                         |
--| G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;                         |
--|                                                                        |
--| HISTORY                                                                |
--|    22-Mar-2004  Anand Thiyagarajan  Created				   |
--|                                                                        |
--+========================================================================+

PROCEDURE Delete_LotCost_Adjustment
(
p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN OUT 	NOCOPY 	Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl		IN OUT 	NOCOPY 	Lc_adjustment_dtls_Tbl_Type
)
IS
  l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Delete_LotCost_Adjustment';
  l_api_version         CONSTANT 	NUMBER 		:= 2.0;
  l_header_exists			BOOLEAN;
  l_detail_exists			BOOLEAN;
  user_cnt				NUMBER;
  l_user_id              		fnd_user.user_id%TYPE ;
  l_return_status			VARCHAR2(2) ;
BEGIN
	-- Standard Start of API savepoint
	SAVEPOINT	 Delete_LotCost_Adjustment_PUB ;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call	(l_api_version        	,
	    	    	    	 		p_api_version        	,
	    	 				l_api_name 		,
	    	    	    	    		G_PKG_NAME
						)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
    		log_msg('Beginning Delete Lot Cost Adjustment process.');
	END IF;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
    		log_msg('Validating input parameters');
	END IF;

	G_header_logged := 'N';

	Validate_Input_Params
	(
        p_header_rec		=>	p_header_rec
	, p_dtl_tbl		=>	p_dtl_tbl
	, p_operation		=>	'DELETE'
	, x_user_id		=>	l_user_id
	, x_return_status	=>	l_return_status
	);

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
  		log_msg('Return Status after validating : ' || l_return_status);
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
	        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
		FND_MSG_PUB.Add;
	        RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
      		log_msg('Calling private API to Delete record...');
	END IF;

	--Call Private Procedure
	GMF_LotCostAdjustment_PVT.Delete_LotCost_Adjustment
	(
	p_api_version		=>		p_api_version
	, p_init_msg_list	=>		FND_API.G_FALSE
	, x_return_status	=>		x_return_status
	, x_msg_count		=>		x_msg_count
	, x_msg_data		=>		x_msg_data
	, p_header_rec		=>		p_header_Rec
	, p_dtl_Tbl		=>		p_dtl_tbl
	);

	-- Return if delete fails for any reason
	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_DEL');
	FND_MESSAGE.SET_TOKEN('NUM_ROWS',p_dtl_tbl.COUNT);
	FND_MSG_PUB.Add;

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit )
	THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    			   	(
				p_count         	=>      x_msg_count
				, p_data          	=>      x_msg_data
    				);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR
	THEN
		ROLLBACK TO Delete_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
					(
					p_count         	=>      x_msg_count
					, p_data          	=>      x_msg_data
    					);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
		ROLLBACK TO Delete_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    					(
					p_count         	=>      x_msg_count
					,p_data          	=>      x_msg_data
	    				);
	WHEN OTHERS
	THEN
		ROLLBACK TO Delete_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg
    	    					(
						G_PKG_NAME
						, l_api_name
	    					);
		END IF;
		FND_MSG_PUB.Count_And_Get
    					(
					p_count         	=>      x_msg_count
					, p_data          	=>      x_msg_data
    					);
END Delete_LotCost_Adjustment;

--+========================================================================+
--| API Name	: Get_LotCost_Adjustment                                   |
--| TYPE	: Public						   |
--| Function	: Fetchs Lot Cost Adjustment based on the input            |
--|			from table GMF_LOT_COST_ADJUSTMENTS                |
--| Pre-reqa	: None                                                     |
--| Parameters	:                                                          |
--| IN		:                                                          |
--|			p_api_version	IN  			NUMBER	   |
--|			p_init_msg_list	IN  			VARCHAR2   |
--|			p_header_rec	IN OUT NOCOPY 			   |
--|		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type	   |
--|			p_dtl_Tbl		IN OUT NOCOPY 		   |
--|		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type      |
--|									   |
--| OUT		: 							   |
--|			x_return_status	OUT NOCOPY 		VARCHAR2   |
--|			x_msg_count		OUT NOCOPY 	NUMBER     |
--|			x_msg_data		OUT NOCOPY 	VARCHAR2   |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:							   |
--|  Pre-defined API message levels					   |
--|                                                                        |
--|     Valid values for message levels are from 1-50.			   |
--|      1 being least severe and 50 highest.				   |
--|                                                                        |
--|     The pre-defined levels correspond to standard API     		   |
--|     return status. Debug levels are used to control the amount of      |
--|      debug information a program writes to the PL/SQL message table.   |
--|                                                                        |
--| G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;                         |
--| G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;                         |
--| G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;                         |
--| G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;                         |
--| G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;                         |
--| G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;                         |
--|                                                                        |
--| HISTORY                                                                |
--|    22-Mar-2004  Anand Thiyagarajan  Created				   |
--|                                                                        |
--+========================================================================+

PROCEDURE Get_LotCost_Adjustment
(
p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN OUT 	NOCOPY 	Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl		    OUT 	NOCOPY 	lc_adjustment_dtls_Tbl_Type
)
IS
  l_api_name		CONSTANT 	VARCHAR2(30)	:= 'Get_LotCost_Adjustment';
  l_api_version         CONSTANT 	NUMBER 		:= 2.0;
  l_header_exists			BOOLEAN;
  l_detail_exists			BOOLEAN;
  user_cnt				NUMBER;
  l_user_id              		fnd_user.user_id%TYPE ;
  l_return_status			VARCHAR2(2) ;
BEGIN
	-- Standard Start of API savepoint
	SAVEPOINT	 Get_LotCost_Adjustment_PUB ;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call	(l_api_version        	,
	    	    	    	 		p_api_version        	,
	    	 				l_api_name 		,
	    	    	    	    		G_PKG_NAME
						)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
    		log_msg('Beginning Get Lot Cost Adjustment process.');
	END IF;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
    		log_msg('Validating input parameters');
	END IF;

	G_header_logged := 'N';

	Validate_Input_Params
	(
     p_header_rec		=>	p_header_rec
	, p_dtl_tbl		=>	p_dtl_tbl
	, p_operation		=>	'GET'
	, x_user_id		=>	l_user_id
	, x_return_status	=>	l_return_status
	) ;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
  		log_msg('Return Status after validating : ' || l_return_status);
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
	        RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
      		log_msg('Calling private API to Get record...');
	END IF;

	--Call Private Procedure
	GMF_LotCostAdjustment_PVT.Get_LotCost_Adjustment
	(
	p_api_version		=>		p_api_version
	, p_init_msg_list	=>		FND_API.G_FALSE
	, x_return_status	=>		x_return_status
	, x_msg_count		=>		x_msg_count
	, x_msg_data		=>		x_msg_data
	, p_header_rec		=>		p_header_Rec
	, p_dtl_Tbl		=>		p_dtl_tbl
	);

	-- Return if Get fails for any reason
	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	THEN
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
				(       p_count         =>      x_msg_count             ,
					p_data          =>      x_msg_data
				);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR
	THEN
		ROLLBACK TO  Get_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
					(       p_count                 =>      x_msg_count     ,
						p_data                  =>      x_msg_data
					);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
		ROLLBACK TO  Get_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
					(       p_count                 =>      x_msg_count     ,
						p_data                  =>      x_msg_data
					);
	WHEN OTHERS
	THEN
		ROLLBACK TO  Get_LotCost_Adjustment_PUB;
		add_header_to_error_stack ( p_header_Rec => p_header_rec );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg
						(       G_PKG_NAME      ,
							l_api_name
						);
		END IF;
		FND_MSG_PUB.Count_And_Get
					(       p_count                 =>      x_msg_count     ,
						p_data                  =>      x_msg_data
					);
END Get_LotCost_Adjustment ;

--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Input_Params                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       Validates all the input parameters.                                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|        p_header_rec		IN					     |
--|		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type      |
--|        p_dtl_tbl		IN					     |
--|		GMF_LotCostAdjustment_PUB.Lc_Adjustment_dtls_tbl_Type        |
--|        p_operation		IN      VARCHAR2			     |
--|        x_user_id		OUT	fnd_user.user_id%TYPE                |
--|        x_return_status	OUT	VARCHAR2                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|       22-MAR-2004 Anand Thiyagarajan - Created                           |
--|   18-dec-2006 bug 5705311, Modified the select query to fetch category_id|
--|                            for the cost class, pmarada                   |
--|   14-Mar-2007 Bug 5586137, Removed exception blk if there is no category |
--|               id found for item, also modified code to insert correct    |
--|               values in created_by and updated_by fields                 |
--|                                                                          |
--+==========================================================================+
-- Proc end of comments

PROCEDURE Validate_Input_Params
(
p_header_Rec		IN OUT	NOCOPY	GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl		IN OUT	NOCOPY	GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
, p_operation		IN		VARCHAR2
, x_user_id		OUT	NOCOPY	fnd_user.user_id%TYPE
, x_return_status	OUT	NOCOPY	VARCHAR2
)
IS
	l_adjustment_date		GMF_LOT_COST_ADJUSTMENTS.adjustment_date%TYPE;
	l_reason_cnt			NUMBER;
	l_text_cnt			NUMBER;
   	l_header_cnt			NUMBER;
	l_detail_cnt			NUMBER;
	l_adjustment_id			GMF_LOT_COST_ADJUSTMENTS.adjustment_id%TYPE;
	l_adjustment_dtl_id		GMF_LOT_COST_ADJUSTMENT_DTLS.adjustment_dtl_id%TYPE;
	l_adjustment_cost		GMF_LOT_COST_ADJUSTMENT_DTLS.adjustment_cost%TYPE;
	l_applied_ind			GMF_LOT_COST_ADJUSTMENTS.applied_ind%TYPE;
   l_cost_category_id   NUMBER;
   l_lot_costed_items_cnt NUMBER;
	--l_itemcost_class		IC_ITEM_MST.itemcost_class%TYPE;
	--l_itemcost_class_cnt    	NUMBER;
BEGIN
	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_applied_ind := NULL;

        IF P_OPERATION IN ('INSERT', 'UPDATE', 'DELETE', 'GET')
	THEN
		IF	p_header_rec.adjustment_id IS NOT NULL
                THEN
			BEGIN
				SELECT	applied_ind
				INTO	l_applied_ind
				FROM	gmf_lot_cost_adjustments
				WHERE	adjustment_id = p_header_rec.adjustment_id
				AND	ROWNUM = 1;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_applied_ind := NULL;
			END;

			IF	l_applied_ind = 'Y'
			AND	P_OPERATION IN ('INSERT', 'UPDATE', 'DELETE')
			THEN

				FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJ_APPLIED');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;

			ELSIF	l_applied_ind = 'N'
			AND	p_operation IN ('INSERT')
			THEN

				FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_HEADER');
				FND_MSG_PUB.Add;

			ELSIF	l_applied_ind IS NULL
			THEN
				FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJUSTMENT_ID');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			IF	(p_header_Rec.legal_entity_id IS NOT NULL
			AND	(p_header_Rec.COST_MTHD_CODE IS NOT NULL
                OR p_header_Rec.cost_type_id IS NOT NULL)
			AND	(p_header_rec.organization_id  IS NOT NULL
                OR p_header_rec.organization_code  IS NOT NULL)
			AND	p_header_Rec.ADJUSTMENT_date IS NOT NULL
			AND	(p_header_Rec.item_id IS NOT NULL
			       OR	p_header_rec.item_number IS NOT NULL)
			AND  p_header_rec.lot_number IS NOT NULL)
			THEN
				IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
				THEN

					FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_HEADER_KEYS');
					FND_MSG_PUB.Add;

				END IF;
			END IF;
		ELSE
			--Legal Entity Validation
			IF	((p_header_rec.legal_entity_id <> FND_API.G_MISS_NUM)
			AND	(p_header_rec.legal_entity_id IS NOT NULL))
			THEN
				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating Legal_entity : ' || p_header_rec.legal_entity_id);
				END IF;

				IF NOT gmf_validations_pvt.validate_legal_entity_id(p_header_rec.legal_entity_id)
				THEN
               -- jboppana have to change the message
               FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_LE_ID');
					FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY',p_header_rec.legal_entity_id);
					/*FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CO_CODE');
					FND_MESSAGE.SET_TOKEN('CO_CODE',p_header_rec.co_code);*/
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			ELSE
           FND_MESSAGE.SET_NAME('GMF','GMF_API_LE_ID_REQ');
			  -- FND_MESSAGE.SET_NAME('GMF','GMF_API_CO_CODE_REQ');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;

			END IF;

			--Cost type Validation
         IF	(p_header_rec.cost_type_id <> FND_API.G_MISS_NUM)
			AND	(p_header_rec.cost_type_id IS NOT NULL)
			THEN
				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating cost type id: ' || p_header_rec.cost_type_id);
				END IF;
				IF NOT GMF_VALIDATIONS_PVT.Validate_lot_cost_type_Id(p_header_rec.cost_type_id)
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE_ID');
					FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header_rec.cost_type_id);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

				-- Log message if cost_mthd_code is also passed
				IF (p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.cost_type_id IS NOT NULL)
				THEN

					IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
					THEN

						FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_COST_TYPE');
						FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header_rec.cost_mthd_code);
						FND_MSG_PUB.Add;

					END IF;
				END IF;
			ELSIF	((p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR)AND	(p_header_rec.cost_mthd_code IS NOT NULL))
			THEN

				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating Cost Type : ' || p_header_rec.cost_mthd_code);
				END IF;

            p_header_rec.cost_type_id := gmf_validations_pvt.Validate_Lot_Cost_type(p_header_rec.cost_mthd_code);

				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('cost_type_id : ' || p_header_rec.cost_type_id);
				END IF;

				IF p_header_rec.cost_type_id IS NULL
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE');
					FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header_rec.cost_mthd_code);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			ELSE

				FND_MESSAGE.SET_NAME('GMF','GMF_API_COST_TYPE_ID_REQ');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
         END IF;


             --Organization Validation
             IF	(p_header_rec.organization_id <> FND_API.G_MISS_NUM)
			AND	(p_header_rec.organization_id IS NOT NULL)
			THEN
				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating organization id: ' || p_header_rec.organization_id);
				END IF;
				IF NOT GMF_VALIDATIONS_PVT.Validate_organization_Id(p_header_rec.organization_id)
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_ID');
					FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

				-- Log message if organization_code is also passed
				IF (p_header_rec.organization_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.organization_id IS NOT NULL)
				THEN

					IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
					THEN

						FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ORGN_CODE');
						FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_header_rec.organization_code);
						FND_MSG_PUB.Add;

					END IF;
				END IF;
		ELSIF	((p_header_rec.organization_code <> FND_API.G_MISS_CHAR)AND	(p_header_rec.organization_code IS NOT NULL))
		THEN

				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating Organization Code : ' || p_header_rec.organization_code);
				END IF;

            p_header_rec.organization_id := gmf_validations_pvt.validate_organization_code(p_header_rec.organization_code);

				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('organization_id : ' || p_header_rec.organization_id);
				END IF;

				IF p_header_rec.organization_id IS NULL
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_CODE');
					FND_MESSAGE.SET_TOKEN('ORG_CODE',p_header_rec.organization_code);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			ELSE

				FND_MESSAGE.SET_NAME('GMF','GMF_API_ORGANIZATION_ID_REQ');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
            END IF;  -- end for organization



			--Item Validation
			IF	(p_header_rec.item_id <> FND_API.G_MISS_NUM)
			AND	(p_header_rec.item_id IS NOT NULL)
			THEN
				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating item_id : ' || p_header_rec.item_id);
				END IF;

				IF NOT GMF_VALIDATIONS_PVT.Validate_inventory_item_id(p_header_rec.item_id,p_header_rec.organization_id)
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_ID');
					FND_MESSAGE.SET_TOKEN('ITEM_ID',p_header_rec.item_id);
               FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

				-- Log message if item_number is also passed
				IF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND (p_header_rec.item_number IS NOT NULL)
				THEN

					IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
					THEN

						FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ITEM_NO');
						FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
                                                FND_MSG_PUB.Add;

					END IF;
				END IF;
			ELSIF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND (p_header_rec.item_number IS NOT NULL)
			THEN
				-- Convert value into ID.
				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating item_number : ' || p_header_rec.item_number);
				END IF;

				p_header_rec.item_id := GMF_VALIDATIONS_PVT.Validate_Item_Number(p_header_rec.item_number,p_header_rec.organization_id);

				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('item_id : ' || p_header_rec.item_id);
				END IF;

				IF p_header_rec.item_id IS NULL
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_NO');
					FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
               FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			ELSE
				FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_ID_REQ');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			-- Bug # 3755374 ANTHIYAG 12-Jul-2004 Start
			--Lot Costed Item Validation
			IF (p_header_rec.item_id IS NOT NULL and p_header_rec.item_id <> FND_API.G_MISS_NUM)
			THEN

				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating Item id : ' || p_header_rec.Item_id || ' For Lot Costing');
				END IF;

          BEGIN
             -- modified the query for bug 5705311, pmarada
             SELECT 	mic.category_id
	          INTO 	l_cost_category_id
             FROM 	mtl_default_category_sets mdc,
            		   mtl_category_sets mcs,
                    	mtl_item_categories mic,
                    	mtl_categories mc
              WHERE 	mic.inventory_item_id = p_header_rec.item_id
                AND 	mic.organization_id = p_header_rec.organization_id
                AND 	mic.category_id = mc.category_id
                AND 	mcs.structure_id = mc.structure_id
                AND 	mdc.functional_area_id = 19
		          AND  mcs.category_set_id = mic.category_set_id
		          AND  mcs.category_set_id = mdc.category_set_id;
                EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                          l_cost_category_id := NULL;
                END;

				BEGIN
					SELECT 	1
					INTO	l_lot_costed_items_cnt
					FROM	GMF_LOT_COSTED_ITEMS
					WHERE	legal_entity_id = p_header_Rec.legal_entity_id
					AND	cost_type_id = p_header_rec.cost_type_id
					AND	inventory_item_id = p_header_rec.item_id;
				EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
 						BEGIN
							SELECT 	1
							INTO	l_lot_costed_items_cnt
							FROM	GMF_LOT_COSTED_ITEMS
							WHERE	legal_entity_id = p_header_Rec.legal_entity_id
					                  AND	cost_type_id = p_header_rec.cost_type_id
							  AND	cost_category_id = l_cost_category_id;
						EXCEPTION
							WHEN NO_DATA_FOUND
							THEN
								FND_MESSAGE.SET_NAME('GMF','GMF_ITEM_ID_NOT_LOT_COSTED');
								FND_MESSAGE.SET_TOKEN('ITEM_ID',p_header_rec.item_id);
                                                                FND_MSG_PUB.Add;
								RAISE FND_API.G_EXC_ERROR;
						END;
				END;
			END IF;
			-- Bug # 3755374 ANTHIYAG 12-Jul-2004 End

			--Lot Validation
			IF (p_header_rec.lot_number <> FND_API.G_MISS_CHAR) AND (p_header_rec.lot_number IS NOT NULL)
			THEN

				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating Lot Number: ' || p_header_rec.lot_number || ' For Item '||p_header_rec.item_id );
				END IF;
				IF NOT GMF_VALIDATIONS_PVT.Validate_lot_number(p_header_rec.lot_number,p_header_rec.item_id,
                                p_header_rec.organization_id)
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_LOT_NUMBER');
					FND_MESSAGE.SET_TOKEN('LOT_NUMBER',p_header_rec.lot_number);
					FND_MESSAGE.SET_TOKEN('ITEM_ID',p_header_rec.item_number);
                                        FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;
         ELSE
				FND_MESSAGE.SET_NAME('GMF','GMF_API_LOT_NUMBER_REQ');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			--Adjustment_date Validation
			IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
			THEN
				log_msg('Validating Adjustment date : ' || p_header_rec.adjustment_date );
			END IF;

			IF p_header_rec.adjustment_date IS NULL
			THEN
				FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJ_DATE_DEFAULT');
				FND_MSG_PUB.Add;
				p_header_rec.adjustment_date := SYSDATE;
			ELSE
				BEGIN
					SELECT MAX(cost_trans_date)
					INTO l_adjustment_date
					FROM gmf_material_lot_cost_txns txns, gmf_lot_costs lc
					WHERE lc.inventory_item_id = p_header_Rec.item_id
					AND lc.lot_number = p_header_Rec.lot_number
					AND lc.organization_id = p_header_rec.organization_id
					AND lc.final_cost_flag = 1
					AND txns.cost_header_id = lc.header_id
					AND txns.final_cost_flag = 1;
				EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
						l_adjustment_date := NULL;
				END;

				IF (l_adjustment_date IS NOT NULL
				AND ((l_adjustment_date > p_header_Rec.adjustment_date)
				OR  (p_header_Rec.adjustment_date > SYSDATE)))
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJ_DATE');
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				ELSE
					IF p_header_Rec.adjustment_date > SYSDATE
					THEN
						FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJ_DATE');
						FND_MSG_PUB.Add;
						RAISE FND_API.G_EXC_ERROR;
					END IF;
				END IF;
			END IF;

			--Reason Code Validation
			IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
			THEN
				log_msg('Validating Reason Code: ' || p_header_rec.reason_code );
			END IF;

			IF	((p_header_rec.reason_code <> FND_API.G_MISS_CHAR)
			AND	(p_header_rec.reason_code IS NOT NULL))
			THEN
				BEGIN
					SELECT	1
					INTO	l_reason_cnt
					FROM	cm_reas_cds
					WHERE	reason_code = p_header_rec.reason_code
					AND	delete_mark = 0
					AND	ROWNUM = 1;
				EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
						FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_REASON_CODE');
						FND_MESSAGE.SET_TOKEN('REASON_CODE',p_header_rec.reason_code);
						FND_MSG_PUB.Add;
						RAISE FND_API.G_EXC_ERROR;
				END;
			ELSE
				FND_MESSAGE.SET_NAME('GMF','GMF_API_REASON_CODE_REQ');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			-- Bug # 3755374 ANTHIYAG 12-Jul-2004 Start
			-- Delete Mark
		        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
			THEN
            			log_msg('Validating Delete_mark : ' || p_header_Rec.delete_mark);
            		END IF;

            		IF (p_header_Rec.delete_mark <> FND_API.G_MISS_NUM) AND (p_header_Rec.delete_mark IS NOT NULL)
			THEN
              			IF p_header_Rec.delete_mark NOT IN (0,1) THEN
          				add_header_to_error_stack(p_header_rec);
                			FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_DELETE_MARK');
                			FND_MESSAGE.SET_TOKEN('DELETE_MARK',p_header_Rec.delete_mark);
                			FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
              			END IF;
            		ELSIF (p_header_Rec.delete_mark = FND_API.G_MISS_NUM AND p_operation = 'UPDATE') OR
		  	(p_operation = 'INSERT') THEN
          	  		add_header_to_error_stack(p_header_rec);
                  		FND_MESSAGE.SET_NAME('GMF','GMF_API_DELETE_MARK_REQ');
                  		FND_MSG_PUB.Add;
                  		RAISE FND_API.G_EXC_ERROR;
            		END IF;
            		IF ((p_operation = 'UPDATE') AND (p_header_Rec.delete_mark = 1)) THEN
              			add_header_to_error_stack(p_header_rec);
              			FND_MESSAGE.SET_NAME('GMF','GMF_API_CANT_MARK_FOR_PURGE');
              			FND_MSG_PUB.Add;
              			RAISE FND_API.G_EXC_ERROR;
            		END IF;
			-- Bug # 3755374 ANTHIYAG 12-Jul-2004 End

			--Adjustment ID validation
			IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
			THEN
				log_msg('Validating Adjustment ID');
			END IF;

			IF p_operation IN ('UPDATE', 'DELETE', 'INSERT')
			THEN
				IF	p_header_rec.adjustment_id IS NULL
				AND	(p_header_Rec.legal_entity_id IS NOT NULL
				AND	( p_header_Rec.COST_MTHD_CODE IS NOT NULL OR p_header_Rec.cost_type_id IS NOT NULL)
				AND	(p_header_rec.organization_code  IS NOT NULL OR p_header_rec.organization_id IS NOT NULL )
				AND	p_header_Rec.ADJUSTMENT_date IS NOT NULL
				AND	(p_header_Rec.item_id IS NOT NULL OR	p_header_rec.item_number IS NOT NULL)
				AND	p_header_Rec.lot_number IS NOT NULL )
				THEN
					IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
					THEN
						log_msg('Fetching Adjustment ID for Code Combination for ' ||
						' Legal Entity ' || p_header_rec.legal_entity_id ||
						' Cost Type Id ' || p_header_rec.cost_type_id ||
                  ' Cost Type ' || p_header_rec.cost_mthd_code ||
                  ' Organization Id ' || p_header_rec.organization_id ||
						' Organization Code ' || p_header_rec.organization_code ||
						' Adjustment Date ' || p_header_rec.adjustment_date ||
                  ' Item Id ' || p_header_rec.item_id ||
						' Item Code ' || p_header_rec.item_number ||
						' for '|| p_operation );
					END IF;

					BEGIN
						SELECT	adjustment_id, applied_ind
						INTO	p_header_Rec.adjustment_id, l_applied_ind
						FROM	gmf_lot_cost_adjustments
						WHERE	legal_entity_id = p_header_rec.legal_entity_id
						AND	cost_type_id = p_header_rec.cost_type_id
						AND	organization_id = p_header_rec.organization_id
						AND	inventory_item_id = p_header_rec.item_id
						AND	lot_number = p_header_rec.lot_number
						AND	adjustment_date = p_header_rec.adjustment_date
						AND	ROWNUM = 1;
					EXCEPTION
						WHEN NO_DATA_FOUND
						THEN
							p_header_Rec.adjustment_id := NULL;
					END;

					IF p_header_Rec.adjustment_id IS NULL
					AND P_OPERATION IN ('UPDATE', 'DELETE')
					THEN
						IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
						THEN
							log_msg('Adjustment ID for Code Combination for ' ||
						' Legal Entity ' || p_header_rec.legal_entity_id ||
						' Cost Type Id ' || p_header_rec.cost_type_id ||
                  ' Cost Type ' || p_header_rec.cost_mthd_code ||
                  ' Organization Id ' || p_header_rec.organization_id ||
						' Organization Code ' || p_header_rec.organization_code ||
						' Adjustment Date ' || p_header_rec.adjustment_date ||
                  ' Item Id ' || p_header_rec.item_id ||
						' Item Code ' || p_header_rec.item_number ||
							' for '|| p_operation ||' doesn''t exist ');
						END IF;

						FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJUSTMENT_ID');
						FND_MSG_PUB.Add;
						RAISE FND_API.G_EXC_ERROR;
					END IF;

					IF	l_applied_ind = 'Y'
					AND	P_OPERATION IN ('INSERT', 'UPDATE', 'DELETE')
					THEN

						FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJ_APPLIED');
						FND_MSG_PUB.Add;
						RAISE FND_API.G_EXC_ERROR;

					ELSIF	l_applied_ind = 'N'
					AND	p_operation IN ('INSERT')
					THEN

						FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_HEADER');
						FND_MSG_PUB.Add;

					END IF;
				END IF;
			END IF;    -- end if for adjustment p_operation
		END IF;  -- End if for adjustment ind not null

                --Username Validation
                -- User name validate is required for both update and Insert,
                -- even adjustment id passed in update operation. bug 5586137
                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
                THEN
                        log_msg('Validating user name : ' || p_header_rec.user_name);
                END IF;

                IF (p_header_rec.user_name <> FND_API.G_MISS_CHAR)
                AND (p_header_rec.user_name IS NOT NULL)
                THEN
                   GMA_GLOBAL_GRP.Get_who(p_user_name  => p_header_rec.user_name
                                         ,x_user_id  => x_user_id
                                          );
                        IF x_user_id = -1
                        THEN
                                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USER_NAME');
                                FND_MESSAGE.SET_TOKEN('USER_NAME',p_header_rec.user_name);
                                FND_MSG_PUB.Add;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                ELSE
                        FND_MESSAGE.SET_NAME('GMF','GMF_API_USER_NAME_REQ');
                        FND_MSG_PUB.Add;
                        RAISE FND_API.G_EXC_ERROR;
                END IF; -- end if for user name validation
	END IF;   -- End if for p_operation

	--Detail Record Validation
	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
	THEN
    		log_msg('Validating Lot Cost Adjustment Detail Records');
	END IF;

  IF P_OPERATION IN ('INSERT', 'UPDATE', 'DELETE')
	THEN
	FOR i IN p_dtl_tbl.FIRST .. p_dtl_tbl.LAST
	LOOP
       IF p_dtl_tbl(i).adjustment_dtl_id IS NOT NULL
			THEN
				BEGIN
					SELECT	1
					INTO	l_detail_cnt
					FROM	gmf_lot_cost_adjustment_dtls
					WHERE	adjustment_dtl_id = p_dtl_tbl(i).adjustment_dtl_id
					AND	ROWNUM = 1;
				EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
						l_detail_cnt := 0;
				END;

				IF	l_detail_cnt > 0
				AND	P_OPERATION IN ('INSERT')
				THEN

					FND_MESSAGE.SET_NAME('GMF','CM_DUP_RECORD'); -- Bug # 3755374 ANTHIYAG 12-Jul-2004
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;

				ELSIF	l_detail_cnt = 0
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJ_DTL_ID');
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

			ELSE

				--Cost Component Class Validation
				IF (p_dtl_tbl(i).cost_cmpntcls_id <> FND_API.G_MISS_NUM) AND (p_dtl_tbl(i).cost_cmpntcls_id IS NOT NULL)
				THEN

					IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
					THEN
						log_msg('Validating Details Component Class ID ('||i||') :'|| p_dtl_tbl(i).cost_cmpntcls_id);
					END IF;

					IF NOT GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Id (p_dtl_tbl(i).cost_cmpntcls_id)
					THEN
						FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_ID');
						FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID',p_dtl_tbl(i).cost_cmpntcls_id);
						FND_MSG_PUB.Add;
						RAISE FND_API.G_EXC_ERROR;
					END IF;

					IF (p_dtl_tbl(i).cost_cmpntcls_code <> FND_API.G_MISS_CHAR) AND (p_dtl_tbl(i).cost_cmpntcls_code IS NOT NULL)
					THEN
						IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
						THEN
							FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_CMPNTCLS_CODE');
							FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_dtl_tbl(i).cost_cmpntcls_code);
							FND_MSG_PUB.Add;
						END IF;
					END IF;

				ELSIF (p_dtl_tbl(i).cost_cmpntcls_code <> FND_API.G_MISS_CHAR) AND (p_dtl_tbl(i).cost_cmpntcls_code IS NOT NULL)
				THEN

					IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
					THEN
						log_msg('Validating Details Component Class Code('||i||') : ' || p_dtl_tbl(i).cost_cmpntcls_code);
					END IF;

					p_dtl_tbl(i).cost_cmpntcls_id := GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Code (p_dtl_tbl(i).cost_cmpntcls_code);

					IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
					THEN
						log_msg('Component Class Id := ' || p_dtl_tbl(i).cost_cmpntcls_id);
					END IF;

					IF p_dtl_tbl(i).cost_cmpntcls_id IS NULL
					THEN
						FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_CODE');
						FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_dtl_tbl(i).cost_cmpntcls_code);
						FND_MSG_PUB.Add;
						RAISE FND_API.G_EXC_ERROR;
					END IF;
				ELSE
					FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_ID_REQ');
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

				--Analysis Code Validation
				IF (p_dtl_tbl(i).cost_analysis_code <> FND_API.G_MISS_CHAR) AND (p_dtl_tbl(i).cost_analysis_code IS NOT NULL)
				THEN
					IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
					THEN
						log_msg('Validating Details Analysis code('||i||') :' || p_dtl_tbl(i).cost_analysis_code);
					END IF;

					IF NOT GMF_VALIDATIONS_PVT.Validate_Analysis_Code(p_dtl_tbl(i).cost_analysis_code)
					THEN
						FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ANALYSIS_CODE');
						FND_MESSAGE.SET_TOKEN('ANALYSIS_CODE',p_dtl_tbl(i).cost_analysis_code);
						FND_MSG_PUB.Add;
						RAISE FND_API.G_EXC_ERROR;
					END IF;

				ELSE
					FND_MESSAGE.SET_NAME('GMF','GMF_API_ANALYSIS_CODE_REQ');
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

				--Text Code Validation
				IF (p_dtl_tbl(i).text_code <> FND_API.G_MISS_NUM) AND (p_dtl_tbl(i).text_code IS NOT NULL)
				THEN
					IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
					THEN
						log_msg('Validating Details Text code('||i||') :' || p_dtl_tbl(i).text_code);
					END IF;

					BEGIN
						SELECT	1
						INTO	l_text_cnt
						FROM	cm_text_hdr
						WHERE	text_code = p_dtl_tbl(i).text_code
						AND	ROWNUM = 1;
					EXCEPTION
						WHEN NO_DATA_FOUND
						THEN
							l_text_cnt := 0;
					END;
					IF NVL(l_text_cnt,0) = 0
					THEN
						FND_MESSAGE.SET_NAME('GMF','GMF_API_TEXT_CODE'); -- Bug # 3755374 ANTHIYAG 12-Jul-2004
						FND_MESSAGE.SET_TOKEN('TEXT_CODE',p_dtl_tbl(i).text_code);
						FND_MSG_PUB.Add;
						RAISE FND_API.G_EXC_ERROR;
					END IF;
				END IF;
			END IF;

			--Adjustment Cost validation
			IF P_OPERATION IN ('UPDATE', 'INSERT')
			THEN
				IF p_dtl_tbl(i).adjustment_cost IS NULL
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJ_COST');
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;

			--Adjustment Details ID validation
			IF	FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
			THEN
				log_msg('Validating Adjustment Detail ID');
			END IF;

			IF	p_operation IN ('UPDATE', 'DELETE', 'INSERT')
			THEN
				IF	p_dtl_tbl(i).adjustment_dtl_id IS NULL
				THEN
					IF	(p_dtl_tbl(i).cost_cmpntcls_id IS NOT NULL
					AND	p_dtl_tbl(i).cost_analysis_code IS NOT NULL)
					THEN
						BEGIN
							SELECT	adjustment_dtl_id
							INTO	p_dtl_tbl(i).adjustment_dtl_id
							FROM	gmf_lot_cost_adjustment_dtls
							WHERE	cost_cmpntcls_id = p_dtl_tbl(i).cost_cmpntcls_id
							AND	cost_analysis_code = p_dtl_tbl(i).cost_analysis_code
							AND	adjustment_id = p_header_rec.adjustment_id
							AND	ROWNUM = 1;
						EXCEPTION
							WHEN NO_DATA_FOUND
							THEN
								IF	P_operation IN ('UPDATE', 'DELETE')
								THEN
									FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJ_DTL_ID');
									FND_MSG_PUB.Add;
									RAISE FND_API.G_EXC_ERROR;
								ELSE
									p_dtl_tbl(i).adjustment_dtl_id := NULL;
								END IF;
						END;

						IF	P_OPERATION IN ('INSERT')
						AND	p_dtl_tbl(i).adjustment_dtl_id IS NOT NULL
						THEN

							FND_MESSAGE.SET_NAME('GMF','CM_DUP_RECORD'); -- Bug # 3755374 ANTHIYAG 12-Jul-2004
							FND_MSG_PUB.Add;
							RAISE FND_API.G_EXC_ERROR;

						END IF;

						IF	FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
						THEN
							log_msg('Using Adjustment Details ID ' || p_dtl_tbl(i).adjustment_id || ' for ' || p_operation);
						END IF;
					ELSE
						FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_ADJ_DTL_ID');
						FND_MSG_PUB.Add;
						RAISE FND_API.G_EXC_ERROR;
					END IF;
				END IF;
			END IF;
      END LOOP;
     END IF;

END Validate_Input_Params;

--+==========================================================================+
--|  Procedure Name                                                          |
--|       log_msg                                                            |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This procedure logs messages to message stack.                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_msg_lvl             IN NUMBER(10) - Message Level                |
--|       p_msg_text            IN NUMBER(10) - Actual Message Text          |
--|                                                                          |
--|  RETURNS                                                                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       22-MAR-2004 Anand Thiyagarajan				     |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE log_msg
(
p_msg_text      IN VARCHAR2
)
IS
BEGIN

    FND_MESSAGE.SET_NAME('GMF','GMF_API_DEBUG');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;

END log_msg ;

-- Func start of comments
--+==========================================================================+
--|  Procedure Name                                                          |
--|       add_header_to_error_stack                                          |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This procedure logs header to message stack.                       |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_header            Header Record to be logged                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       15-APR-2004 Anand Thiyagarajan - Created			     |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE add_header_to_error_stack
(
 p_header_rec	GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
)
IS
BEGIN

  IF G_header_logged = 'N'
  THEN
    G_header_logged := 'Y';
    FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_HEADER');
    FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY_ID',p_header_rec.legal_entity_id);
    FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header_rec.cost_type_id);
    FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header_rec.cost_mthd_code);
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_header_rec.organization_code);
    FND_MESSAGE.SET_TOKEN('ITEM_ID',p_header_rec.item_id);
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
    FND_MESSAGE.SET_TOKEN('LOT_NUMBER',p_header_rec.lot_number);
    FND_MESSAGE.SET_TOKEN('ADJUSTMENT_DATE',p_header_rec.adjustment_date);

    FND_MSG_PUB.Add;
  END IF;

END add_header_to_error_stack;

END GMF_LotCostAdjustment_PUB;

/
