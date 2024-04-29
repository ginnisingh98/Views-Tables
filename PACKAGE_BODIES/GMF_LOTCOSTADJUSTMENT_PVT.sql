--------------------------------------------------------
--  DDL for Package Body GMF_LOTCOSTADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_LOTCOSTADJUSTMENT_PVT" AS
/* $Header: GMFVLCAB.pls 120.3.12000000.2 2007/03/15 10:15:08 pmarada ship $ */

--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFVLCAB.pls                                        |
--| Package Name       : GMF_LotCostAdjustment_PVT                           |
--| API name           : GMF_LotCostAdjustment_PVT			     |
--| Type               : Private                                             |
--| Pre-reqs	       : N/A                                                 |
--| Function	       : Lot Cost Adjustment Creation, Updation, Query and   |
--|			 Deletion 					     |
--|                                                                          |
--| Parameters	       : N/A                                                 |
--|                                                                          |
--| Current Vers       : 1.0                                                 |
--| Previous Vers      : None                                                |
--| Initial Vers       : 1.0                                                 |
--|                                                                          |
--| Notes                                                                    |
--|     This package contains public procedures relating to Lot Cost 	     |
--|	Adjustment Creation, Updation, Query and Deletion		     |
--|  Pre-defined API message levels					     |
--|                                                                          |
--|     Valid values for message levels are from 1-50.			     |
--|      1 being least severe and 50 highest.				     |
--|                                                                          |
--|     The pre-defined levels correspond to standard API     		     |
--|     return status. Debug levels are used to control the amount of        |
--|      debug information a program writes to the PL/SQL message table.     |
--|                                                                          |
--| G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;                           |
--| G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;                           |
--| G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;                           |
--| G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;                           |
--| G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;                           |
--| G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;                           |
--|                                                                          |
--| HISTORY                                                                  |
--|    	22-Mar-2004  			Anand Thiyagarajan  Created	     |
--|	12-Jul-2004  	BUG # 3755374	Anand Thiyagarajan 		     |
--|		Modified Code to insert text_code in Lot Cost Adjustment     |
--|		Details Table						     |
--|                                                                          |
--+==========================================================================+

-- Procedure to log Error messages
PROCEDURE log_msg(p_msg_text      IN VARCHAR2);

-- Global variables
G_PKG_NAME      CONSTANT 	VARCHAR2(30) 	:= 	'GMF_LotCostAdjustment_PVT';
G_DEBUG_LEVEL			NUMBER(2)	:= 	FND_MSG_PUB.G_Msg_Level_Threshold;

--Start of comments
--+========================================================================+
--| API Name	: Create_LotCost_Adjustment                                |
--| TYPE		: Private                                          |
--| Function	: Creates Lot Cost Adjustment based on the input           |
--|			  into table GMF_LOT_COST_ADJUSTMENTS              |
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
--|			x_msg_count		OUT NOCOPY 	VARCHAR2   |
--|			x_msg_data		OUT NOCOPY 	VARCHAR2   |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version: 1.0                                    |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|    	22-Mar-2004			Anand Thiyagarajan  Created	   |
--|	12-Jul-2004  	BUG # 3755374	Anand Thiyagarajan 		   |
--|		Modified Code to insert text_code in Lot Cost Adjustment   |
--|		Details Table						   |
--|    14-mar-2007  Bug 5586137 Prasad, inserting p_user instead of        |
--|                 fnd_global.user_id                                     |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Create_LotCost_Adjustment
(
	p_api_version			IN  			NUMBER
	, p_init_msg_list		IN  			VARCHAR2 := FND_API.G_FALSE
	, x_return_status		OUT 	NOCOPY 		VARCHAR2
	, x_msg_count			OUT 	NOCOPY 		NUMBER
	, x_msg_data			OUT 	NOCOPY 		VARCHAR2
	, p_header_rec			IN OUT 	NOCOPY 		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
	, p_dtl_Tbl			IN OUT 	NOCOPY 		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
        , p_user_id                     IN                      NUMBER
)
IS
	l_api_name		CONSTANT 		VARCHAR2(30)	:= 'Create_LotCost_Adjustment' ;
	l_api_version		CONSTANT 		NUMBER		:= 2.0 ;
	l_adjustment_id					GMF_LOT_COST_ADJUSTMENTS.ADJUSTMENT_ID%TYPE;
	l_adjustment_dtl_id				GMF_LOT_COST_ADJUSTMENT_DTLS.ADJUSTMENT_DTL_ID%TYPE;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT	 Create_LotCost_Adjustment_PVT ;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call	(
					l_api_version        	,
	    	 	 		p_api_version        	,
			 		l_api_name 		,
	    	    	 		G_PKG_NAME
					)	THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
  	log_msg('Beginning Private Create Lot Cost Adjustment API');
  END IF;

  IF p_header_Rec.adjustment_id IS NULL THEN
        SELECT	GMF_LOT_COST_ADJS_ID_S.NEXTVAL
	INTO	l_adjustment_id
	FROM	dual;
  END IF;

  IF  p_header_Rec.adjustment_id IS NULL THEN

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
  		log_msg	('Inserting Lot Cost Adjustments for Item ' 			|| 	p_header_rec.item_id 		||
								' Legal Entity' 		|| 	p_header_rec.legal_entity_id 		||
            							' Organization ' 		|| 	p_header_rec.organization_id 		||
            							' Cost Type Id ' 	|| 	p_header_rec.cost_type_id 	||
								' Lot Number '		||	p_header_Rec.lot_number		||
								'Adjustment Date '	||	p_header_rec.adjustment_date
			) ;
	END IF;

	BEGIN
		INSERT INTO gmf_lot_cost_adjustments
		(
		ADJUSTMENT_ID
		, legal_entity_id
		, cost_type_id
		, inventory_item_id
		, organization_id
		, lot_number
		, ADJUSTMENT_DATE
		, REASON_CODE
		, DELETE_MARK
		, APPLIED_IND
		, CREATED_BY
		, CREATION_DATE
		, LAST_UPDATED_BY
		, LAST_UPDATE_LOGIN
		, LAST_UPDATE_DATE
		, ATTRIBUTE1
		, ATTRIBUTE2
		, ATTRIBUTE3
		, ATTRIBUTE4
		, ATTRIBUTE5
		, ATTRIBUTE6
		, ATTRIBUTE7
		, ATTRIBUTE8
		, ATTRIBUTE9
		, ATTRIBUTE10
		, ATTRIBUTE11
		, ATTRIBUTE12
		, ATTRIBUTE13
		, ATTRIBUTE14
		, ATTRIBUTE15
		, ATTRIBUTE16
		, ATTRIBUTE17
		, ATTRIBUTE18
		, ATTRIBUTE19
		, ATTRIBUTE20
		, ATTRIBUTE21
		, ATTRIBUTE22
		, ATTRIBUTE23
		, ATTRIBUTE24
		, ATTRIBUTE25
		, ATTRIBUTE26
		, ATTRIBUTE27
		, ATTRIBUTE28
		, ATTRIBUTE29
		, ATTRIBUTE30
		, ATTRIBUTE_CATEGORY
		)
		VALUES
		(
		l_adjustment_id
		, p_header_rec.legal_entity_id
		, p_header_rec.cost_type_id
		, p_header_rec.ITEM_ID
		, p_header_rec.organization_id
		, p_header_rec.lot_number
		, p_header_rec.ADJUSTMENT_DATE
		, p_header_rec.REASON_CODE
		, 0
		, 'N'
		, p_user_id
		, SYSDATE
		, p_user_id
		, FND_GLOBAL.LOGIN_ID
		, SYSDATE
		, p_header_rec.ATTRIBUTE1
		, p_header_rec.ATTRIBUTE2
		, p_header_rec.ATTRIBUTE3
		, p_header_rec.ATTRIBUTE4
		, p_header_rec.ATTRIBUTE5
		, p_header_rec.ATTRIBUTE6
		, p_header_rec.ATTRIBUTE7
		, p_header_rec.ATTRIBUTE8
		, p_header_rec.ATTRIBUTE9
		, p_header_rec.ATTRIBUTE10
		, p_header_rec.ATTRIBUTE11
		, p_header_rec.ATTRIBUTE12
		, p_header_rec.ATTRIBUTE13
		, p_header_rec.ATTRIBUTE14
		, p_header_rec.ATTRIBUTE15
		, p_header_rec.ATTRIBUTE16
		, p_header_rec.ATTRIBUTE17
		, p_header_rec.ATTRIBUTE18
		, p_header_rec.ATTRIBUTE19
		, p_header_rec.ATTRIBUTE20
		, p_header_rec.ATTRIBUTE21
		, p_header_rec.ATTRIBUTE22
		, p_header_rec.ATTRIBUTE23
		, p_header_rec.ATTRIBUTE24
		, p_header_rec.ATTRIBUTE25
		, p_header_rec.ATTRIBUTE26
		, p_header_rec.ATTRIBUTE27
		, p_header_rec.ATTRIBUTE28
		, p_header_rec.ATTRIBUTE29
		, p_header_rec.ATTRIBUTE30
		, p_header_rec.ATTRIBUTE_CATEGORY
		) RETURNING adjustment_id INTO p_header_rec.adjustment_id;

		IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
			log_msg	( SQL%ROWCOUNT || 'Header Record Inserted for Lot Cost Adjustments for Item ' 		|| 	p_header_rec.item_id 		||
											' Legal Entity' 		|| 	p_header_rec.legal_entity_id 		||
            							' Organization ' 		|| 	p_header_rec.organization_id 		||
            							' Cost Type Id ' 	|| 	p_header_rec.cost_type_id 	||
							            ' Lot Number '		||	p_header_Rec.lot_number		||
                                 ' Adjustment Date '	||	p_header_rec.adjustment_date
				);
		END IF;
	  EXCEPTION
		WHEN OTHERS THEN
			FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_INS_FAILED');
			FND_MESSAGE.SET_TOKEN('ITEM', p_header_rec.item_id);
			FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY', p_header_rec.legal_entity_id);
			FND_MESSAGE.SET_TOKEN('ORGANIZATION', p_header_rec.organization_id);
			FND_MESSAGE.SET_TOKEN('COST_TYPE', p_header_rec.cost_type_id);
			FND_MESSAGE.SET_TOKEN('LOT', p_header_rec.lot_number);
			FND_MESSAGE.SET_TOKEN('ADJUSTMENT_DATE', p_header_rec.adjustment_date);
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			RAISE ;
	  END;

  ELSIF p_header_Rec.adjustment_id IS NOT NULL THEN

  	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
  		log_msg	('Lot Cost Adjustments for Item ' 				|| 	p_header_rec.item_id 		||
							   ' Legal Entity' 		|| 	p_header_rec.legal_entity_id 		||
            				' Organization ' 		|| 	p_header_rec.organization_id 		||
            				' Cost Type Id ' 	|| 	p_header_rec.cost_type_id 	||
							   ' Lot Number '		||	p_header_Rec.lot_number		||
								' Adjustment Date '	||	p_header_rec.adjustment_date	||
								' already exists '
			) ;

	END IF;
  END IF;

  FOR i IN p_dtl_tbl.FIRST .. p_dtl_tbl.LAST
  LOOP

	IF p_dtl_tbl(i).adjustment_dtl_id IS NULL THEN
		SELECT GMF_LOT_COST_ADJS_DTL_ID_S.NEXTVAL
		INTO l_adjustment_dtl_id
		FROM dual;
	END IF;

	IF  p_dtl_tbl(i).adjustment_dtl_id IS NULL THEN
		IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
			log_msg	( 'Inserting Detail Record for Cost Component Class Id ' 	|| p_dtl_tbl(i).cost_cmpntcls_id ||
                					      ' Cost Analysis Code ' 	|| p_dtl_tbl(i).cost_analysis_code
				);
		END IF;
		BEGIN
			INSERT INTO gmf_lot_cost_adjustment_dtls
			(
			ADJUSTMENT_DTL_ID
			, ADJUSTMENT_ID
			, COST_CMPNTCLS_ID
			, COST_ANALYSIS_CODE
			, ADJUSTMENT_COST
			, TEXT_CODE 	-- Bug # 3755374 ANTHIYAG 12-Jul-2004
			, DELETE_MARK
			, CREATED_BY
			, CREATION_DATE
			, LAST_UPDATED_BY
			, LAST_UPDATE_LOGIN
			, LAST_UPDATE_DATE
			)
			VALUES
			(
			l_adjustment_dtl_id
			, p_header_rec.adjustment_id
			, p_dtl_tbl(i).COST_CMPNTCLS_ID
			, p_dtl_tbl(i).COST_ANALYSIS_CODE
			, p_dtl_tbl(i).ADJUSTMENT_COST
			, p_dtl_tbl(i).TEXT_CODE -- Bug # 3755374 ANTHIYAG 12-Jul-2004
			, 0
			, p_user_id
			, SYSDATE
			, p_user_id
			, FND_GLOBAL.LOGIN_ID
			, SYSDATE
			) RETURNING adjustment_dtl_id INTO p_dtl_tbl(i).adjustment_dtl_id;
			IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
				log_msg	( SQL%ROWCOUNT || 'Detail Record inserted for Cost Component Class Id ' 	|| p_dtl_tbl(i).cost_cmpntcls_id ||
									      ' Cost Analysis Code ' 	|| p_dtl_tbl(i).cost_analysis_code
					);
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_DTL_INS_FAILED');
				FND_MESSAGE.SET_TOKEN('COMPONENT_CLASS', p_dtl_tbl(i).cost_cmpntcls_id);
				FND_MESSAGE.SET_TOKEN('ANALYSIS_CODE', p_dtl_tbl(i).cost_analysis_code);
				FND_MSG_PUB.Add;
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				RAISE ;
		END ;
	  ELSIF p_dtl_tbl(i).adjustment_dtl_id IS NOT NULL THEN

		IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
  			log_msg	('Ignoring Lot Cost Adjustment Details for Cost Component Class Id ' 	|| p_dtl_tbl(i).cost_cmpntcls_id ||
									      ' Cost Analysis Code ' 	|| p_dtl_tbl(i).cost_analysis_code
				);
		END IF;
	  END IF;
  END LOOP;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get	(
				p_count			=>      x_msg_count
				, p_data		=>      x_msg_data
    				);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_LotCost_Adjustment_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get	(
						p_count         	=>      x_msg_count
						, p_data          =>      x_msg_data
						);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_LotCost_Adjustment_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get	(
						p_count         	=>      x_msg_count
						, p_data         	=>      x_msg_data
						);
	WHEN OTHERS THEN
		ROLLBACK TO Create_LotCost_Adjustment_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg	(
						G_PKG_NAME
						, l_api_name
						);
		END IF;
		FND_MSG_PUB.Count_And_Get	(
						p_count         	=>      x_msg_count
						, p_data         	=>      x_msg_data
						);
END Create_LotCost_Adjustment;

--+========================================================================+
--| API Name	: Update_LotCost_Adjustment                                |
--| TYPE		: Private                                          |
--| Function	: Updates Lot Cost Adjustment based on the input           |
--|			  in table GMF_LOT_COST_ADJUSTMENTS                |
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
--|			x_msg_count	OUT NOCOPY 		VARCHAR2   |
--|			x_msg_data	OUT NOCOPY 		VARCHAR2   |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|    22-Mar-2004  Anand Thiyagarajan  Created				   |
--|    14-mar-2007  Bug 5586137 Prasad, inserting p_user instead of        |
--|                 fnd_global.user_id                                     |
--|                                                                        |
--+========================================================================+

PROCEDURE Update_LotCost_Adjustment
(
p_api_version		IN  			NUMBER
, p_init_msg_list	IN  			VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 		VARCHAR2
, x_msg_count		OUT 	NOCOPY 		NUMBER
, x_msg_data		OUT 	NOCOPY 		VARCHAR2
, p_header_rec		IN OUT 	NOCOPY 		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl		IN OUT 	NOCOPY 		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
, p_user_id             IN                      NUMBER
)
IS
	l_api_name		CONSTANT 		VARCHAR2(30)	:= 'Update_LotCost_Adjustment' ;
	l_api_version		CONSTANT 		NUMBER		:= 2.0 ;
	l_adjustment_id					GMF_LOT_COST_ADJUSTMENTS.ADJUSTMENT_ID%TYPE;
	l_adjustment_dtl_id				GMF_LOT_COST_ADJUSTMENT_DTLS.ADJUSTMENT_DTL_ID%TYPE;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT	 Update_LotCost_Adjustment_PVT ;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call	( 	l_api_version        	,
	    	    	    	 		p_api_version        	,
	    	 				l_api_name 		,
	    	    	    	    		G_PKG_NAME
						)	THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
  	log_msg('Beginning Private Update Lot Cost Adjustment API');
  END IF;

  FOR i IN p_dtl_tbl.FIRST .. p_dtl_tbl.LAST
  LOOP
    IF p_dtl_tbl(i).adjustment_dtl_id IS NOT NULL THEN
	    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
	      log_msg	( 'Updating Detail Record for Adjustment Detail Id ' 	|| p_dtl_tbl(i).adjustment_dtl_id );
	    END IF;
	    BEGIN
		UPDATE gmf_lot_cost_adjustment_dtls
		SET	ADJUSTMENT_COST = p_dtl_tbl(i).ADJUSTMENT_COST
			, TEXT_CODE = decode( p_dtl_tbl(i).TEXT_CODE, FND_API.G_MISS_NUM, NULL, NULL, TEXT_CODE, p_dtl_tbl(i).TEXT_CODE )
			, LAST_UPDATED_BY = p_user_id
			, LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
			, LAST_UPDATE_DATE = SYSDATE
		WHERE	adjustment_dtl_id = p_dtl_tbl(i).adjustment_dtl_id
		AND	delete_mark = 0;

		IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
			log_msg	( SQL%ROWCOUNT || 'Detail Record Updated for Adjustment Detail Id ' 	|| p_dtl_tbl(i).adjustment_dtl_id );
		END IF;
	    EXCEPTION
		WHEN OTHERS THEN
			FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_DTL_ID_UPD_FAILED');
			FND_MESSAGE.SET_TOKEN('ADJUSTMENT_DTL_ID', p_dtl_tbl(i).adjustment_dtl_id);
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			RAISE ;
	    END ;
    ELSIF p_dtl_tbl(i).adjustment_dtl_id IS NULL THEN

	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
		log_msg	( 'Detail Record for Cost Component Class Id ' 	|| p_dtl_tbl(i).cost_cmpntcls_id ||
							      ' Cost Analysis Code ' 	|| p_dtl_tbl(i).cost_analysis_code ||
							      ' Doesn''t Exist'
			);
	END IF;

    END IF;

  END LOOP;


  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get	(
				p_count		=>      x_msg_count
				, p_data	=>      x_msg_data
    				);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_LotCost_Adjustment_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get	(
						p_count			=>      x_msg_count
						, p_data		=>      x_msg_data
						);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_LotCost_Adjustment_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get	(
						p_count         	=>      x_msg_count
						, p_data         	=>      x_msg_data
						);
	WHEN OTHERS THEN
		ROLLBACK TO Update_LotCost_Adjustment_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg	(
						G_PKG_NAME
						, l_api_name
						);
		END IF;
		FND_MSG_PUB.Count_And_Get	(
						p_count         	=>      x_msg_count
						, p_data         	=>      x_msg_data
						);
END Update_LotCost_Adjustment;

--Start of comments
--+========================================================================+
--| API Name	: Delete_LotCost_Adjustment                                |
--| TYPE		: Private                                          |
--| Function	: Deletes Lot Cost Adjustment based on the input           |
--|			  in table GMF_LOT_COST_ADJUSTMENTS                |
--| Pre-reqa	: None                                                     |
--| Parameters	:                                                          |
--| IN		:                                                          |
--|			p_api_version	IN  			NUMBER	   |
--|			p_init_msg_list	IN  			VARCHAR2   |
--|			p_header_rec	IN OUT NOCOPY 			   |
--|		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type    |
--|			p_dtl_Tbl		IN OUT NOCOPY 		   |
--|		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type      |
--|									   |
--| OUT		: 							   |
--|			x_return_status	OUT NOCOPY 		VARCHAR2   |
--|			x_msg_count	OUT NOCOPY 		VARCHAR2   |
--|			x_msg_data	OUT NOCOPY 		VARCHAR2   |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|    22-Mar-2004  Anand Thiyagarajan  Created				   |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Delete_LotCost_Adjustment
(
p_api_version		IN  			NUMBER
, p_init_msg_list	IN  			VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 		VARCHAR2
, x_msg_count		OUT 	NOCOPY 		NUMBER
, x_msg_data		OUT 	NOCOPY 		VARCHAR2
, p_header_rec		IN OUT 	NOCOPY 		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl		IN OUT 	NOCOPY 		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
)
IS
	l_api_name		CONSTANT 		VARCHAR2(30)	:= 'Delete_LotCost_Adjustment' ;
	l_api_version		CONSTANT 		NUMBER		:= 2.0 ;
	l_adjustment_id					GMF_LOT_COST_ADJUSTMENTS.ADJUSTMENT_ID%TYPE;
	l_adjustment_dtl_id				GMF_LOT_COST_ADJUSTMENT_DTLS.ADJUSTMENT_DTL_ID%TYPE;
   l_adjustment_dtl_cnt              NUMBER := 0;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT	 Delete_LotCost_Adjustment_PVT ;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	FND_MSG_PUB.initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call	( 	l_api_version        	,
	    	    	    	 		p_api_version        	,
	    	 				l_api_name 		,
	    	    	    	    	 	G_PKG_NAME
					)	THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
  	log_msg('Beginning Private Delete Lot Cost Adjustment API');
  END IF;

  FOR i IN p_dtl_tbl.FIRST .. p_dtl_tbl.LAST
  LOOP

	IF p_dtl_tbl(i).adjustment_dtl_id IS NOT NULL THEN

		IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
			log_msg	( 'Deleting Detail Record for Adjustment Detail Id ' || p_dtl_tbl(i).adjustment_dtl_id);
		END IF;

		BEGIN
			DELETE gmf_lot_cost_adjustment_dtls
			WHERE adjustment_dtl_id = p_dtl_tbl(i).adjustment_dtl_id;
			IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
				log_msg	( SQL%ROWCOUNT || ' Detail Record(s) deleted for Adjustment Detail Id ' || p_dtl_tbl(i).adjustment_dtl_id);
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_DTL_ID_DEL_FAILED');
				FND_MESSAGE.SET_TOKEN('ADJUSTMENT_ID', p_dtl_tbl(i).adjustment_dtl_id);
				FND_MSG_PUB.Add;
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				RAISE ;
		END ;
	ELSIF p_dtl_tbl(i).adjustment_dtl_id IS NULL THEN

    	    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
	      log_msg	( 'Detail Record for Cost Component Class Id ' 	|| p_dtl_tbl(i).cost_cmpntcls_id ||
							      ' Cost Analysis Code ' 	|| p_dtl_tbl(i).cost_analysis_code||
							      ' Doesn''t Exist '
			);
	    END IF;
	END IF;
  END LOOP;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
	log_msg	('Deleting Lot Cost Adjustments for Item ' 			|| 	p_header_rec.item_id 		||
							' Legal Entity' 		|| 	p_header_rec.legal_entity_id 		||
            							' Organization ' 		|| 	p_header_rec.organization_id 		||
            							' Cost Type Id ' 	|| 	p_header_rec.cost_type_id 	||
								' Lot Number '		||	p_header_Rec.lot_number		||
							 ' Adjustment Date '	||	p_header_rec.adjustment_date
		) ;
  END IF;

BEGIN
   SELECT   count(1)
   INTO     l_adjustment_dtl_cnt
   FROM     gmf_lot_cost_adjustment_dtls
   WHERE	   adjustment_id = p_header_Rec.adjustment_id;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_adjustment_dtl_cnt := 0;
END;

IF NVL(l_adjustment_dtl_cnt,0) = 0  THEN
BEGIN
	DELETE	gmf_lot_cost_adjustments
	WHERE	adjustment_id = p_header_Rec.adjustment_id
	AND	nvl(applied_ind,'N') <> 'Y';
	IF SQL%NOTFOUND THEN
    	FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_DEL_FAILED');
		FND_MESSAGE.SET_TOKEN('ITEM', p_header_rec.item_id);
	   FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY', p_header_rec.legal_entity_id);
		FND_MESSAGE.SET_TOKEN('ORGANIZATION', p_header_rec.organization_id);
		FND_MESSAGE.SET_TOKEN('COST_TYPE', p_header_rec.cost_type_id);
		FND_MESSAGE.SET_TOKEN('LOT', p_header_rec.lot_number);
		FND_MESSAGE.SET_TOKEN('ADJUSTMENT_DATE', p_header_rec.adjustment_date);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
     			log_msg( SQL%ROWCOUNT || ' Record Deleted for Adjustment Id ' || p_header_rec.adjustment_id);
		END IF;
	END IF ;
  EXCEPTION
	WHEN OTHERS THEN
		IF (p_header_rec.adjustment_id IS NOT NULL) OR (p_header_rec.adjustment_id <> FND_API.G_MISS_NUM) THEN
			FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_DEL_FAILED');
			FND_MESSAGE.SET_TOKEN('ADJUSTMENT_ID', p_header_rec.adjustment_id);
			FND_MSG_PUB.Add;
		END IF ;
  END;
ELSE
   	FND_MESSAGE.SET_NAME('GMF','GMF_API_LCA_DEL_IGNORE');
		FND_MESSAGE.SET_TOKEN('ITEM', p_header_rec.item_id);
		FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY', p_header_rec.legal_entity_id);
		FND_MESSAGE.SET_TOKEN('ORGANIZATION', p_header_rec.organization_id);
		FND_MESSAGE.SET_TOKEN('COST_TYPE', p_header_rec.cost_type_id);
		FND_MESSAGE.SET_TOKEN('LOT', p_header_rec.lot_number);
		FND_MESSAGE.SET_TOKEN('ADJUSTMENT_DATE', p_header_rec.adjustment_date);
		FND_MSG_PUB.Add;
END IF;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
	log_msg(p_dtl_tbl.COUNT || ' Lot Cost Adjustment Detail row(s) Deleted');
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get	(
				p_count			=>      x_msg_count
				, p_data		=>      x_msg_data
    				);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Delete_LotCost_Adjustment_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get	(
						p_count         	=>      x_msg_count
						, p_data		=>      x_msg_data
						);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Delete_LotCost_Adjustment_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get	(
						p_count         	=>      x_msg_count
						, p_data         	=>      x_msg_data
						);
	WHEN OTHERS THEN
		ROLLBACK TO Delete_LotCost_Adjustment_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg	(
						G_PKG_NAME
						, l_api_name
						);
		END IF;
		FND_MSG_PUB.Count_And_Get	(
						p_count         	=>      x_msg_count
						, p_data         	=>      x_msg_data
						);

END Delete_LotCost_Adjustment;

--Start of comments
--+========================================================================+
--| API Name	: Get_LotCost_Adjustment                                   |
--| TYPE		: Private                                          |
--| Function	: Get Lot Cost Adjustment based on the input               |
--|			  from table GMF_LOT_COST_ADJUSTMENTS              |
--| Pre-reqa	: None                                                     |
--| Parameters	:                                                          |
--| IN		:                                                          |
--|			p_api_version	IN  			NUMBER	   |
--|			p_init_msg_list	IN  			VARCHAR2   |
--|			p_header_rec	IN OUT NOCOPY 			   |
--|		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type    |
--|			p_dtl_Tbl		IN OUT NOCOPY 		   |
--|		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type      |
--|									   |
--| OUT		: 							   |
--|			x_return_status	OUT NOCOPY 		VARCHAR2   |
--|			x_msg_count	OUT NOCOPY 		VARCHAR2   |
--|			x_msg_data	OUT NOCOPY 		VARCHAR2   |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|    22-Mar-2004  Anand Thiyagarajan  Created			     	   |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Get_LotCost_Adjustment
(
p_api_version		IN  			NUMBER
, p_init_msg_list	IN  			VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 		VARCHAR2
, x_msg_count		OUT 	NOCOPY 		NUMBER
, x_msg_data		OUT 	NOCOPY 		VARCHAR2
, p_header_rec		IN OUT 	NOCOPY 		GMF_LotCostAdjustment_PUB.Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl		OUT 	NOCOPY 		GMF_LotCostAdjustment_PUB.Lc_adjustment_dtls_Tbl_Type
)
IS
	CURSOR Adjustment_Header_csr
  	IS
  	SELECT
  	a.ADJUSTMENT_ID
	, a.legal_entity_id
	, a.cost_type_id
	, a.inventory_item_id
	, a.organization_id
	, a.lot_number
	, a.ADJUSTMENT_DATE
	, a.REASON_CODE
	, a.DELETE_MARK
	, a.ATTRIBUTE1
	, a.ATTRIBUTE2
	, a.ATTRIBUTE3
	, a.ATTRIBUTE4
	, a.ATTRIBUTE5
	, a.ATTRIBUTE6
	, a.ATTRIBUTE7
	, a.ATTRIBUTE8
	, a.ATTRIBUTE9
	, a.ATTRIBUTE10
	, a.ATTRIBUTE11
	, a.ATTRIBUTE12
	, a.ATTRIBUTE13
	, a.ATTRIBUTE14
	, a.ATTRIBUTE15
	, a.ATTRIBUTE16
	, a.ATTRIBUTE17
	, a.ATTRIBUTE18
	, a.ATTRIBUTE19
	, a.ATTRIBUTE20
	, a.ATTRIBUTE21
	, a.ATTRIBUTE22
	, a.ATTRIBUTE23
	, a.ATTRIBUTE24
	, a.ATTRIBUTE25
	, a.ATTRIBUTE26
	, a.ATTRIBUTE27
	, a.ATTRIBUTE28
	, a.ATTRIBUTE29
	, a.ATTRIBUTE30
	, a.ATTRIBUTE_CATEGORY
	FROM  gmf_lot_cost_adjustments a
	, mtl_system_items_b b
 	, mtl_lot_numbers c
  	WHERE	a.adjustment_id 	= 	nvl(p_header_rec.adjustment_id, a.adjustment_id)
	AND	a.legal_entity_id 		= 	decode(p_header_rec.adjustment_id, NULL, p_header_rec.legal_entity_id, a.legal_entity_id)
	AND 	a.cost_type_id 	= 	decode(p_header_rec.adjustment_id, NULL, p_header_rec.cost_type_id, a.cost_type_id)
	AND 	a.organization_id		= 	decode(p_header_rec.adjustment_id, NULL, p_header_rec.organization_id, a.organization_id)
	AND 	a.inventory_item_id 		= 	decode(p_header_rec.adjustment_id, NULL, p_header_rec.item_id, a.inventory_item_id)
	AND	a.lot_number		= 	decode(p_header_rec.adjustment_id, NULL, p_header_rec.lot_number, a.lot_number)
	AND	a.adjustment_date	= 	decode(p_header_rec.adjustment_id, NULL, p_header_rec.adjustment_date, a.adjustment_date)
   AND	b.inventory_item_id 		= 	a.inventory_item_id
   AND   b.organization_id = a.organization_id
  	AND	c.lot_number 		= 	a.lot_number
   AND   c.inventory_item_id = 	a.inventory_item_id
   AND   c.organization_id = a.organization_id;

  	CURSOR adjustment_dtls_csr	(
					p_adjustment_id IN NUMBER
					)
	IS
  	SELECT
	a.ADJUSTMENT_DTL_ID
	, a.ADJUSTMENT_ID
	, a.COST_CMPNTCLS_ID
	, a.COST_ANALYSIS_CODE
	, a.ADJUSTMENT_COST
	, a.TEXT_CODE
	FROM  gmf_lot_cost_adjustment_dtls a
  WHERE	a.adjustment_id = NVL(p_adjustment_id, a.adjustment_id);

	l_api_name		CONSTANT 		VARCHAR2(30)	:= 'Get_LotCost_Adjustment' ;
	l_api_version		CONSTANT 		NUMBER		:= 2.0 ;
    l_idx                           NUMBER := 0;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Get_LotCost_Adjustment_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call	(	l_api_version          ,
						p_api_version          ,
						l_api_name             ,
						G_PKG_NAME
					)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	log_msg('Beginning Private Get Lot Cost Adjustment API.');
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
	log_msg	('Retrieving Lot Cost Adjustments for Adjustment ID '		||	p_header_rec.adjustment_id    ||
							' Item ' 		|| 	p_header_rec.item_id 		||
						  ' Legal Entity' 		|| 	p_header_rec.legal_entity_id 		||
            							' Organization ' 		|| 	p_header_rec.organization_id 		||
            							' Cost Type Id ' 	|| 	p_header_rec.cost_type_id 	||
								' Lot Number '		||	p_header_Rec.lot_number		||
							' Adjustment Date '	||	p_header_rec.adjustment_date
		);
    END IF;

    FOR i IN adjustment_header_csr
    LOOP
	p_header_Rec.ADJUSTMENT_ID 		:=	i.ADJUSTMENT_ID;
	p_header_Rec.legal_entity_id 			:=	i.legal_entity_id;
	p_header_Rec.cost_type_id 		:=	i.cost_type_id;
	p_header_Rec.ITEM_ID 			:=	i.inventory_item_id;
	p_header_Rec.organization_id 			:=	i.organization_id;
	p_header_Rec.lot_number			:=	i.lot_number;
	p_header_Rec.ADJUSTMENT_DATE 		:=	i.ADJUSTMENT_DATE;
	p_header_Rec.REASON_CODE 		:=	i.REASON_CODE;
	p_header_Rec.DELETE_MARK 		:=	i.DELETE_MARK;
	p_header_Rec.ATTRIBUTE1 		:=	i.ATTRIBUTE1;
	p_header_Rec.ATTRIBUTE2 		:=	i.ATTRIBUTE2;
	p_header_Rec.ATTRIBUTE3 		:=	i.ATTRIBUTE3;
	p_header_Rec.ATTRIBUTE4 		:=	i.ATTRIBUTE4;
	p_header_Rec.ATTRIBUTE5 		:=	i.ATTRIBUTE5;
	p_header_Rec.ATTRIBUTE6 		:=	i.ATTRIBUTE6;
	p_header_Rec.ATTRIBUTE7 		:=	i.ATTRIBUTE7;
	p_header_Rec.ATTRIBUTE8 		:=	i.ATTRIBUTE8;
	p_header_Rec.ATTRIBUTE9 		:=	i.ATTRIBUTE9;
	p_header_Rec.ATTRIBUTE10 		:=	i.ATTRIBUTE10;
	p_header_Rec.ATTRIBUTE11 		:=	i.ATTRIBUTE11;
	p_header_Rec.ATTRIBUTE12 		:=	i.ATTRIBUTE12;
	p_header_Rec.ATTRIBUTE13 		:=	i.ATTRIBUTE13;
	p_header_Rec.ATTRIBUTE14 		:=	i.ATTRIBUTE14;
	p_header_Rec.ATTRIBUTE15 		:=	i.ATTRIBUTE15;
	p_header_Rec.ATTRIBUTE16 		:=	i.ATTRIBUTE16;
	p_header_Rec.ATTRIBUTE17 		:=	i.ATTRIBUTE17;
	p_header_Rec.ATTRIBUTE18 		:=	i.ATTRIBUTE18;
	p_header_Rec.ATTRIBUTE19 		:=	i.ATTRIBUTE19;
	p_header_Rec.ATTRIBUTE20 		:=	i.ATTRIBUTE20;
	p_header_Rec.ATTRIBUTE21 		:=	i.ATTRIBUTE21;
	p_header_Rec.ATTRIBUTE22 		:=	i.ATTRIBUTE22;
	p_header_Rec.ATTRIBUTE23 		:=	i.ATTRIBUTE23;
	p_header_Rec.ATTRIBUTE24 		:=	i.ATTRIBUTE24;
	p_header_Rec.ATTRIBUTE25 		:=	i.ATTRIBUTE25;
	p_header_Rec.ATTRIBUTE26 		:=	i.ATTRIBUTE26;
	p_header_Rec.ATTRIBUTE27 		:=	i.ATTRIBUTE27;
	p_header_Rec.ATTRIBUTE28 		:=	i.ATTRIBUTE28;
	p_header_Rec.ATTRIBUTE29 		:=	i.ATTRIBUTE29;
	p_header_Rec.ATTRIBUTE30 		:=	i.ATTRIBUTE30;
	p_header_Rec.ATTRIBUTE_CATEGORY 	:=	i.ATTRIBUTE_CATEGORY;

  END LOOP;


  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
  	log_msg	('Retrieving Lot Cost Adjustments for Adjustment ID '		||	p_header_rec.adjustment_id    ||
							' Item ' 		|| 	p_header_rec.item_id 		||
							' Legal Entity' 		|| 	p_header_rec.legal_entity_id 		||
            							' Organization ' 		|| 	p_header_rec.organization_id 		||
            							' Cost Type Id ' 	|| 	p_header_rec.cost_type_id 	||
								' Lot Number '		||	p_header_Rec.lot_number		||
							' Adjustment Date '	||	p_header_rec.adjustment_date
		);
  END IF;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
	log_msg( 'Retrieving Lot Cost Adjustment Records for Adjustment ID'|| p_header_Rec.adjustment_id );
  END IF;

  OPEN adjustment_dtls_csr (p_header_Rec.adjustment_id);
  LOOP
    l_idx := l_idx + 1;
    FETCH adjustment_dtls_csr INTO	p_dtl_tbl(l_idx).ADJUSTMENT_DTL_ID
						, p_dtl_tbl(l_idx).ADJUSTMENT_ID
						, p_dtl_tbl(l_idx).COST_CMPNTCLS_ID
						, p_dtl_tbl(l_idx).COST_ANALYSIS_CODE
						, p_dtl_tbl(l_idx).ADJUSTMENT_COST
						, p_dtl_tbl(l_idx).TEXT_CODE ;
    EXIT WHEN adjustment_dtls_csr%NOTFOUND;
  END LOOP;
  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
	log_msg	( adjustment_dtls_csr%rowcount||' Records retrieved for Adjustment Id ' || p_header_rec.adjustment_id );
  END IF;
  CLOSE adjustment_dtls_csr;


  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get	(
				p_count         	=>      x_msg_count
				, p_data		=>      x_msg_data
        			);

END Get_LotCost_Adjustment;

-- Start of comments
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
--|       22-MAR-2004 Anand Thiyagarajan - Created                           |
--|                                                                          |
--+==========================================================================+
-- End of comments

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

END GMF_LotCostAdjustment_PVT;

/
