--------------------------------------------------------
--  DDL for Package Body GMF_BURDENDETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_BURDENDETAILS_PVT" AS
/* $Header: GMFVBRDB.pls 120.2.12000000.2 2007/04/04 12:11:18 pmarada ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFVBRDB.pls                                        |
--| Package Name       : GMF_BurdenDetails_PVT                               |
--| API name           : GMF_BurdenDetails_PVT                               |
--| Type               : Public                                              |
--| Pre-reqs           : N/A                                                 |
--| Function           : Burden Details creation, updatation and deletion.   |
--|                                                                          |
--| Parameters         : N/A                                                 |
--|                                                                          |
--| Current Vers       : 2.0                                                 |
--| Previous Vers      : 1.0                                                 |
--| Initial Vers       : 1.0                                                 |
--|                                                                          |
--| Contents                                                                 |
--|	Create_Burden_Details                                                |
--|	Update_Burden_Details                                                |
--|	Delete_Burden_Details                                                |
--|	Get_Burden_Details                                                   |
--|                                                                          |
--| Notes                                                                    |
--|     This package contains public procedures relating to Burden Details   |
--|     creation, updatation and deletetion.                                 |
--|                                                                          |
--| HISTORY                                                                  |
--|    12/Apr/2001  Uday Moogala  Created  Bug# 1418689                      |
--|                                                                          |
--|    30/Oct/2002  R.Sharath Kumar Bug# 2641405 Added NOCOPY hint           |
--|    05/NOV/2002  Uday Moogala  Bug# 2659435                               |
--|      Performance related fixes. 					     |
--|	 1. remove G_MISS_xxx assignments.				     |
--|	 2. Conditionally calling debug routine.                             |
--|	 Also, fixed issues found during unit testing. Search for the bug    |
--|	 number to find the fixes.               			     |
--|    24/DEC/2002  Uday Moogala  Bug# 2722404                               |
--|      Removed creation_date and created_by from update stmts. 	     |
--|   20-Oct-2005  Prasad marada, Bug 4689137 Modified as per convergence    |
--+==========================================================================+
-- End of comments



PROCEDURE log_msg	-- Bug 2659435: Removed first paramter for debug level
(
p_msg_text      IN VARCHAR2
);
--
FUNCTION check_records_exist
(
   p_organization_id   IN cm_brdn_dtl.organization_id%TYPE,
   p_inventory_item_id IN cm_brdn_dtl.inventory_item_id%TYPE,
   p_resources         IN cm_brdn_dtl.resources%TYPE,
   p_period_id         IN cm_brdn_dtl.period_id%TYPE,
   p_cost_type_id      IN cm_brdn_dtl.cost_type_id%TYPE ,
   p_cost_cmpntcls_id  IN cm_brdn_dtl.cost_cmpntcls_id%TYPE,
   p_cost_analysis_code IN cm_brdn_dtl.cost_analysis_code%TYPE
) RETURN BOOLEAN;

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMF_BurdenDetails_PVT';

G_debug_level   NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
                                                                 -- to decide to log a debug msg.


--Start of comments
--+========================================================================+
--| API Name	: Create_Burden_Details                                    |
--| TYPE	: Public                                           	   |
--| Function	: Creates a new Burden Details based on the input into table|
--|		  CM_CMPT_DTL                                              |
--| Pre-reqa	: None.                                                    |
--| Parameters	:                                                          |
--| IN          :                                                          |
--|               p_api_version         IN  NUMBER       - Required        |
--|               p_init_msg_list       IN  VARCHAR2     - Optional        |
--|               p_commit              IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Burden_Header_Rec_Type         |
--|               p_dtl_tbl             IN  Burden_Dtl_Tbl_Type            |
--|               p_user_id             IN  NUMBER                         |
--| OUT         :                                                          |
--|               x_return_status    OUT VARCHAR2                          |
--|               x_msg_count        OUT NUMBER                            |
--|               x_msg_data         OUT VARCHAR2                          |
--|               x_burdenline_ids   OUT Burdenline_Ids_Tbl_Type           |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--| 01-apr-07     prasad marada bug 5589409, added check_record_exists     |
--|               procedure call                                           |
--+========================================================================+
-- End of comments

PROCEDURE Create_Burden_Details
(
  p_api_version                 IN  NUMBER                      ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                    ,
  x_msg_count                   OUT NOCOPY VARCHAR2                    ,
  x_msg_data                    OUT NOCOPY VARCHAR2                    ,

  p_header_rec                  IN  GMF_BurdenDetails_PUB.Burden_Header_Rec_Type        ,
  p_dtl_tbl                     IN  GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type           ,
  p_user_id                     IN  fnd_user.user_id%TYPE       ,
  p_burden_factor_tbl		IN  Burden_factor_Tbl_Type	,

  x_burdenline_ids              OUT NOCOPY GMF_BurdenDetails_PUB.Burdenline_Ids_Tbl_Type
)
IS

	l_api_name		CONSTANT VARCHAR2(30)	:= 'Create_Burden_Details' ;
	l_api_version           CONSTANT NUMBER		:= 2.0 ;

        l_burdenline_id		cm_brdn_dtl.burdenline_id%TYPE ;
        l_idx			NUMBER(10) := 0 ;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT	 Create_Burden_Details_PVT ;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version        	,
	    	    	    	 	 p_api_version        	,
	    	 			 l_api_name 		,
	    	    	    	    	 G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Beginning Private Create Burden Details API.');
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Burden Detail Count : ' || p_dtl_tbl.count);
        log_msg('Inserting Burden Details for Item ' || p_header_rec.inventory_item_id ||
	    ' organization_id ' || p_header_rec.organization_id || ' organization_code ' || p_header_rec.organization_code ||
	    ' Calendar ' || p_header_rec.calendar_code || ' Period ' || p_header_rec.Period_code ||
	    ' Mthd ' || p_header_rec.cost_mthd_code ) ;
    END IF;


    FOR i in 1..p_dtl_tbl.count
    LOOP
        -- check if there exists any burden for the same record
      IF check_records_exist(
           p_organization_id    => p_header_rec.organization_id,
           p_inventory_item_id  => p_header_rec.inventory_item_id,
           p_resources          => p_dtl_tbl(i).resources,
           p_period_id          => p_header_rec.period_id,
           p_cost_type_id       => p_header_rec.cost_type_id,
           p_cost_cmpntcls_id   => p_dtl_tbl(i).cost_cmpntcls_id,
           p_cost_analysis_code => p_dtl_tbl(i).cost_analysis_code
           ) THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_DUPLICATE_BRDN_COST');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
          FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_header_rec.inventory_item_id);
          FND_MESSAGE.SET_TOKEN('RESOURCES',p_dtl_tbl(i).resources);
          FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header_rec.period_id);
          FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header_rec.cost_type_id);
          FND_MESSAGE.SET_TOKEN('COST_CMPNTCLS_ID',p_dtl_tbl(i).cost_cmpntcls_id);
          FND_MESSAGE.SET_TOKEN('COST_ANALYSIS_CODE',p_dtl_tbl(i).cost_analysis_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      SELECT gem5_burdenline_id_S.NEXTVAL
        INTO l_burdenline_id
        FROM DUAL ;

      --
      -- Using anonymous block to capture any error for the current record. Duplicate record check is
      -- not done in public API because of the performance considerations.
      -- In case of failure error msg will be logged and will continue with the next record
      --

       BEGIN
        INSERT INTO cm_brdn_dtl
        (
          burdenline_id
        , resources
        , cost_cmpntcls_id
        , cost_analysis_code
        , burden_usage
        , item_qty
        , burden_qty
        , burden_factor
        , rollover_ind
        , cmpntcost_id
        , trans_cnt
        , delete_mark
        , text_code
        , created_by
        , creation_date
        , last_updated_by
        , last_update_login
        , last_update_date
        , request_id
        , program_application_id
        , program_id
        , program_update_date
        , organization_id
        , inventory_item_id
        , period_id
        , cost_type_id
        , item_uom
        , burden_uom
         )
        VALUES
        (
          l_burdenline_id
        , p_dtl_tbl(i).resources
        , p_dtl_tbl(i).cost_cmpntcls_id
        , p_dtl_tbl(i).cost_analysis_code
        , p_dtl_tbl(i).burden_usage
        , p_dtl_tbl(i).item_qty
        , p_dtl_tbl(i).burden_qty
        , p_burden_factor_tbl(i).burden_factor
        , 0	-- rollover indicator
        , ''	-- Component Cost Id
        , ''	-- trans cnt
        , 0	--delete mark
        , ''	-- text code
        , p_user_id
        , sysdate
        , p_user_id
        , FND_GLOBAL.LOGIN_ID
        , sysdate
        , ''	-- request_id
        , ''	-- program_application_id
        , ''	-- program_id
        , ''	-- program_update_date
        , p_header_rec.organization_id
        , p_header_rec.inventory_item_id
        , p_header_rec.period_id
        , p_header_rec.cost_type_id
        , p_dtl_tbl(i).item_uom
        , p_dtl_tbl(i).burden_uom
        );

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
        	log_msg( '1 row inserted for Resource ' || p_dtl_tbl(i).resources ||
		' Cmptcls Id ' || p_dtl_tbl(i).cost_cmpntcls_id || ' Alys Code ' || p_dtl_tbl(i).cost_analysis_code ||
		' Burdenline Id ' || l_burdenline_id);
        END IF;

        l_idx := l_idx + 1 ;

        x_burdenline_ids(l_idx).resources          := p_dtl_tbl(i).resources ;
        x_burdenline_ids(l_idx).cost_cmpntcls_id   := p_dtl_tbl(i).cost_cmpntcls_id ;
        x_burdenline_ids(l_idx).cost_analysis_code := p_dtl_tbl(i).cost_analysis_code ;
        x_burdenline_ids(l_idx).burdenline_id      := l_burdenline_id ;

      EXCEPTION
        WHEN OTHERS THEN
	  x_burdenline_ids.delete ;
          FND_MESSAGE.SET_NAME('GMF','GMF_API_BRDN_INSERT_FAILED');
          FND_MESSAGE.SET_TOKEN('RESOURCE', p_dtl_tbl(i).resources);
          FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_dtl_tbl(i).cost_cmpntcls_id);
          FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_dtl_tbl(i).cost_analysis_code);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          RAISE ;
      END ;
    END LOOP ;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    	( 	p_count		=>      x_msg_count		,
        	p_data		=>      x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO  Create_Burden_Details_PVT;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	(  	p_count         	=>      x_msg_count     ,
		p_data          	=>      x_msg_data
	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO  Create_Burden_Details_PVT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	(  	p_count         	=>      x_msg_count     ,
		p_data          	=>      x_msg_data
	);
    WHEN OTHERS THEN
	ROLLBACK TO  Create_Burden_Details_PVT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF FND_MSG_PUB.Check_Msg_Level
	   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	   FND_MSG_PUB.Add_Exc_Msg
	   	(	G_PKG_NAME	,
			l_api_name
		);
	END IF;
	FND_MSG_PUB.Count_And_Get
		(  	p_count         	=>      x_msg_count     ,
			p_data          	=>      x_msg_data
		);
END Create_Burden_Details;


--Start of comments
--+========================================================================+
--| API Name    : Update_Burden_Details                                    |
--| TYPE        : Public                                                   |
--| Function    : Updates Burden Details based on the input into CM_CMPT_DTL|
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version         IN  NUMBER       - Required        |
--|               p_init_msg_list       IN  VARCHAR2     - Optional        |
--|               p_commit              IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Burden_Header_Rec_Type         |
--|               p_dtl_tbl             IN  Burden_Dtl_Tbl_Type            |
--|               p_user_id             IN  NUMBER                         |
--| OUT         :                                                          |
--|               x_return_status    OUT VARCHAR2                          |
--|               x_msg_count        OUT NUMBER                            |
--|               x_msg_data         OUT VARCHAR2                          |
--|                                                                        |
--| Version     :                                                          |
--|               Current Version       : 2.0                              |
--|               Previous Version      : 1.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Update_Burden_Details
(
  p_api_version                 IN  NUMBER                              ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                    ,
  x_msg_count                   OUT NOCOPY VARCHAR2                    ,
  x_msg_data                    OUT NOCOPY VARCHAR2                    ,

  p_header_rec                  IN  GMF_BurdenDetails_PUB.Burden_Header_Rec_Type        ,
  p_dtl_tbl                     IN  GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type           ,
  p_user_id                     IN  fnd_user.user_id%TYPE	,
  p_burden_factor_tbl		IN  Burden_factor_Tbl_Type
)
IS
	l_api_name              CONSTANT VARCHAR2(30)   := 'Update_Burden_Details' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        l_no_rows_upd		NUMBER ;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Update_Burden_Details_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Beginning Update Burden Details process.');
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Burden Detail Count : ' || p_dtl_tbl.count);
        log_msg('Processing Burden Details for Item ' || p_header_rec.inventory_item_id ||
            ' organization_id ' || p_header_rec.organization_id || ' organization_code ' || p_header_rec.organization_code ||
	    ' Calendar ' || p_header_rec.calendar_code || ' Period ' || p_header_rec.Period_code ||
	    ' Mthd ' || p_header_rec.cost_mthd_code ) ;
    END IF;

    FOR i in 1..p_dtl_tbl.count
    LOOP

      --
      -- Using anonymous block to capture any error for the current record. Duplicate record check is
      -- not done in public API because of the performance considerations.
      -- In case of failure error msg will be logged and will continue with the next record
      --
      BEGIN
        IF (p_dtl_tbl(i).burdenline_id IS NOT NULL) AND		-- Bug 2659435 OR to AND
	   (p_dtl_tbl(i).burdenline_id <> FND_API.G_MISS_NUM) THEN

          IF p_dtl_tbl(i).delete_mark = 0 THEN		-- Update
            UPDATE cm_brdn_dtl
            SET
		/*	Bug 2659435: key columns should not be changed.
                 resources         =  decode(p_dtl_tbl(i).resources
                                      , FND_API.G_MISS_CHAR, NULL
				      , NULL, resources
                                      , p_dtl_tbl(i).resources )
               , cost_cmpntcls_id  =  decode(p_dtl_tbl(i).cost_cmpntcls_id
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, cost_cmpntcls_id
                                      , p_dtl_tbl(i).cost_cmpntcls_id )
               , cost_analysis_code=  decode(p_dtl_tbl(i).cost_analysis_code
                                      , FND_API.G_MISS_CHAR, NULL
				      , NULL, cost_analysis_code
                                      , p_dtl_tbl(i).cost_analysis_code )
		*/
                burden_usage      =  decode(p_dtl_tbl(i).burden_usage
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, burden_usage
                                      , p_dtl_tbl(i).burden_usage )
               , item_qty          =  decode(p_dtl_tbl(i).item_qty
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, item_qty
                                      , p_dtl_tbl(i).item_qty )
               , item_uom          =  decode(p_dtl_tbl(i).item_uom
                                      , FND_API.G_MISS_CHAR, NULL
				      , NULL, item_uom
                                      , p_dtl_tbl(i).item_uom )
               , burden_qty        =  decode(p_dtl_tbl(i).burden_qty
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, burden_qty
                                      , p_dtl_tbl(i).burden_qty )
               , burden_uom        =  decode(p_dtl_tbl(i).burden_uom
                                      , FND_API.G_MISS_CHAR, NULL
				      , NULL, burden_uom
                                      , p_dtl_tbl(i).burden_uom )
               , burden_factor     =  decode(p_burden_factor_tbl(i).burden_factor
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, burden_factor
                                      , p_burden_factor_tbl(i).burden_factor )
               , delete_mark       =  0
               -- , creation_date     =  sysdate	-- Bug 2722404
               -- , created_by        =  p_user_id
               , last_update_date  =  sysdate
               , last_updated_by   =  p_user_id
               , last_update_login =  FND_GLOBAL.LOGIN_ID
            WHERE
               burdenline_id	= p_dtl_tbl(i).burdenline_id
            ;
          ELSE           -- delete the record i.e mark for purge
            UPDATE cm_brdn_dtl
            SET
                 delete_mark       =  1
               -- , creation_date     =  sysdate	-- Bug 2722404
               -- , created_by        =  p_user_id
               , last_update_date  =  sysdate
               , last_updated_by   =  p_user_id
               , last_update_login =  FND_GLOBAL.LOGIN_ID
            WHERE
               burdenline_id    = p_dtl_tbl(i).burdenline_id
            ;
          END IF ;

          IF SQL%NOTFOUND THEN		-- burden details not found
	    IF p_dtl_tbl(i).delete_mark = 0 THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_BRDN_NOT_FOUND_FOR_ID');
              FND_MESSAGE.SET_TOKEN('BURDENLINE_ID', p_dtl_tbl(i).burdenline_id);
              FND_MSG_PUB.Add;
	    ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_DEL_BRDN_NOT_FOUND_ID');
              FND_MESSAGE.SET_TOKEN('OVERHEADLINE_ID', p_dtl_tbl(i).burdenline_id);
              FND_MSG_PUB.Add;
	    END IF ;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            EXIT ;
	  ELSE
	    l_no_rows_upd := l_no_rows_upd + 1 ;

            IF p_dtl_tbl(i).delete_mark = 0 THEN
	       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
	       	log_msg( '1 row updated for Burdenline Id ' || p_dtl_tbl(i).burdenline_id);
	       END IF;
	    ELSE
	       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
	       	log_msg( '1 row deleted for Burdenline Id ' || p_dtl_tbl(i).burdenline_id);
	       END IF;
	    END IF ;
	  END IF ;

        ELSE	-- Burdenline_Id is not supplied.
          IF p_dtl_tbl(i).delete_mark = 0 THEN		-- Update
            UPDATE cm_brdn_dtl
            SET
		/*	Bug 2659435: key columns should not be changed.
                 resources         =  decode(p_dtl_tbl(i).resources
                                      , FND_API.G_MISS_CHAR, NULL
				      , NULL, resources
                                      , p_dtl_tbl(i).resources )
               , cost_cmpntcls_id  =  decode(p_dtl_tbl(i).cost_cmpntcls_id
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, cost_cmpntcls_id
                                      , p_dtl_tbl(i).cost_cmpntcls_id )
               , cost_analysis_code=  decode(p_dtl_tbl(i).cost_analysis_code
                                      , FND_API.G_MISS_CHAR, NULL
				      , NULL, cost_analysis_code
                                      , p_dtl_tbl(i).cost_analysis_code )
		*/
               burden_usage      =  decode(p_dtl_tbl(i).burden_usage
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, burden_usage
                                      , p_dtl_tbl(i).burden_usage )
               , item_qty          =  decode(p_dtl_tbl(i).item_qty
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, item_qty
                                      , p_dtl_tbl(i).item_qty )
               , item_uom           =  decode(p_dtl_tbl(i).item_uom
                                      , FND_API.G_MISS_CHAR, NULL
				      , NULL, item_uom
                                      , p_dtl_tbl(i).item_uom )
               , burden_qty        =  decode(p_dtl_tbl(i).burden_qty
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, burden_qty
                                      , p_dtl_tbl(i).burden_qty )
               , burden_uom        =  decode(p_dtl_tbl(i).burden_uom
                                      , FND_API.G_MISS_CHAR, NULL
				      , NULL, burden_uom
                                      , p_dtl_tbl(i).burden_uom )
               , burden_factor     =  decode(p_burden_factor_tbl(i).burden_factor
                                      , FND_API.G_MISS_NUM, NULL
				      , NULL, burden_factor
                                      , p_burden_factor_tbl(i).burden_factor )
               , delete_mark       =  0
               -- , creation_date     =  sysdate	-- Bug 2722404
               -- , created_by        =  p_user_id
               , last_update_date  =  sysdate
               , last_updated_by   =  p_user_id
               , last_update_login =  FND_GLOBAL.LOGIN_ID
            WHERE
  	         organization_id    = p_header_rec.organization_id
  	    AND  inventory_item_id  = p_header_rec.inventory_item_id
  	    AND  period_id	    = p_header_rec.period_id
  	    AND  cost_type_id	    = p_header_rec.cost_type_id
  	    AND  resources	    = p_dtl_tbl(i).resources
  	    AND  cost_cmpntcls_id   = p_dtl_tbl(i).cost_cmpntcls_id
  	    AND  cost_analysis_code = p_dtl_tbl(i).cost_analysis_code
            ;
          ELSE           -- delete the record i.e mark for purge
            UPDATE cm_brdn_dtl
            SET
                 delete_mark       =  1
               -- , creation_date     =  sysdate	-- Bug 2722404
               -- , created_by        =  p_user_id
               , last_update_date  =  sysdate
               , last_updated_by   =  p_user_id
               , last_update_login =  FND_GLOBAL.LOGIN_ID
            WHERE
  	         organization_id    = p_header_rec.organization_id
  	    AND  inventory_item_id  = p_header_rec.inventory_item_id
  	    AND  period_id	    = p_header_rec.period_id
  	    AND  cost_type_id	    = p_header_rec.cost_type_id
  	    AND  resources	    = p_dtl_tbl(i).resources
  	    AND  cost_cmpntcls_id   = p_dtl_tbl(i).cost_cmpntcls_id
  	    AND  cost_analysis_code = p_dtl_tbl(i).cost_analysis_code
            ;
          END IF ;


          IF SQL%NOTFOUND THEN		-- burden details not found
	    IF p_dtl_tbl(i).delete_mark = 0 THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_BRDN_NOT_FOUND_FOR_DTL');
              FND_MESSAGE.SET_TOKEN('RESOURCE', p_dtl_tbl(i).resources);
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
	    ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_DEL_BRDN_NOT_FOUND_DTL');
              FND_MESSAGE.SET_TOKEN('RESOURCE', p_dtl_tbl(i).resources);
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
	    END IF ;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            EXIT ;
	  ELSE
	    l_no_rows_upd := l_no_rows_upd + 1 ;

            IF p_dtl_tbl(i).delete_mark = 0 THEN
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
               	  log_msg( '1 row updated for Resource ' || p_dtl_tbl(i).resources ||
                  ' Cmptcls Id ' || p_dtl_tbl(i).cost_cmpntcls_id || ' Alys Code ' || p_dtl_tbl(i).cost_analysis_code);
               END IF;
	    ELSE
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
               	  log_msg( '1 row deleted for Resource ' || p_dtl_tbl(i).resources ||
                  ' Cmptcls Id ' || p_dtl_tbl(i).cost_cmpntcls_id || ' Alys Code ' || p_dtl_tbl(i).cost_analysis_code);
               END IF;
	    END IF ;
	  END IF ;

        END IF ;

      EXCEPTION
        WHEN OTHERS THEN
          IF p_dtl_tbl(i).delete_mark = 0 THEN			-- Update
            IF (p_dtl_tbl(i).burdenline_id IS NOT NULL) OR	-- burdenline_id is sent
               (p_dtl_tbl(i).burdenline_id <> FND_API.G_MISS_NUM) THEN
                FND_MESSAGE.SET_NAME('GMF','GMF_API_BRDN_UPD_FAILED_ID');
                FND_MESSAGE.SET_TOKEN('OVERHEADLINE_ID','Burdenline Id ' || p_dtl_tbl(i).burdenline_id);
                FND_MSG_PUB.Add;
	    ELSE
                FND_MESSAGE.SET_NAME('GMF','GMF_API_BRDN_UPD_FAILED_DTLS');
                FND_MESSAGE.SET_TOKEN('RESOURCE', p_dtl_tbl(i).resources);
                FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_dtl_tbl(i).cost_cmpntcls_id);
                FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_dtl_tbl(i).cost_analysis_code);
                FND_MSG_PUB.Add;
	    END IF ;
          ELSE		-- delete
            IF (p_dtl_tbl(i).burdenline_id IS NOT NULL) OR	-- burdenline_id is sent
               (p_dtl_tbl(i).burdenline_id <> FND_API.G_MISS_NUM) THEN
                FND_MESSAGE.SET_NAME('GMF','GMF_API_BRDN_DEL_FAILED_ID');
                FND_MESSAGE.SET_TOKEN('OVERHEADLINE_ID','Burdenline Id ' || p_dtl_tbl(i).burdenline_id);
                FND_MSG_PUB.Add;
	    ELSE
                FND_MESSAGE.SET_NAME('GMF','GMF_API_BRDN_DEL_FAILED_DTLS');
                FND_MESSAGE.SET_TOKEN('RESOURCE', p_dtl_tbl(i).resources);
                FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_dtl_tbl(i).cost_cmpntcls_id);
                FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_dtl_tbl(i).cost_analysis_code);
                FND_MSG_PUB.Add;
	    END IF ;
          END IF ;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          RAISE ;
      END ;
    END LOOP ;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count             ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Update_Burden_Details_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Update_Burden_Details_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Update_Burden_Details_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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

END Update_Burden_Details ;

--Start of comments
--+========================================================================+
--| API Name    : Get_Burden_Details                                       |
--| TYPE        : Private                                                  |
--| Function    : Retrieve Burden Details based on the input from CM_BRDN_DTL|
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|		  p_api_version         IN  NUMBER       - Required        |
--|		  p_init_msg_list       IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Burden_Header_Rec_Type         |
--| OUT		:                                                          |
--|		  x_return_status    OUT VARCHAR2                          |
--|		  x_msg_count        OUT NUMBER                            |
--|		  x_msg_data         OUT VARCHAR2                          |
--|               x_dtl_tbl          OUT Burden_Dtl_Tbl_Type               |
--|                                                                        |
--| Version     :                                                          |
--|               Current Version       : 2.0                              |
--|               Previous Version      : 1.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 26-Apr-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments
PROCEDURE Get_Burden_Details
(
  p_api_version                 IN  NUMBER                              ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                    ,
  x_msg_count                   OUT NOCOPY VARCHAR2                    ,
  x_msg_data                    OUT NOCOPY VARCHAR2                    ,

  p_header_rec                  IN  GMF_BurdenDetails_PUB.Burden_Header_Rec_Type        ,

  x_dtl_tbl                     OUT NOCOPY GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type
)
IS

  l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Burden_Details' ;
  l_api_version           CONSTANT NUMBER         := 2.0 ;

  l_idx                   NUMBER                  := 0 ;

  CURSOR cm_brdn_dtl
  IS
    SELECT
        b.burdenline_id
      , b.resources
      , b.cost_cmpntcls_id
      , c.cost_cmpntcls_code
      , b.cost_analysis_code
      , b.burden_usage
      , b.item_qty
      , b.item_uom
      , b.burden_qty
      , b.burden_uom
      , b.burden_factor
      , b.delete_mark
    FROM
        cm_cmpt_mst c, cm_brdn_dtl b
    WHERE
        b.organization_id   = p_header_rec.organization_id
    AND b.inventory_item_id = p_header_rec.inventory_item_id
    AND b.period_id	    = p_header_rec.period_id
    AND b.cost_type_id	    = p_header_rec.cost_type_id
    AND c.cost_cmpntcls_id =  b.cost_cmpntcls_id
    ORDER BY
        b.resources
      , b.cost_cmpntcls_id
      , b.cost_analysis_code
    ;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Get_Burden_Details_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Beginning Private Get Item Cost API.');
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
      log_msg('Retrieving Burden Details for Item ' || p_header_rec.inventory_item_id ||
            ' organization_id ' || p_header_rec.organization_id || ' organization_code ' || p_header_rec.organization_code ||
            ' Calendar ' || p_header_rec.calendar_code || ' Period ' || p_header_rec.Period_code ||
            ' Mthd ' || p_header_rec.cost_mthd_code ) ;
    END IF;

    FOR cr_rec IN cm_brdn_dtl
    LOOP
        l_idx := l_idx + 1 ;
        x_dtl_tbl(l_idx).burdenline_id      := cr_rec.burdenline_id ;
        x_dtl_tbl(l_idx).resources          := cr_rec.resources ;
        x_dtl_tbl(l_idx).cost_cmpntcls_id   := cr_rec.cost_cmpntcls_id ;
        x_dtl_tbl(l_idx).cost_cmpntcls_code := cr_rec.cost_cmpntcls_code ;
        x_dtl_tbl(l_idx).cost_analysis_code := cr_rec.cost_analysis_code ;
        x_dtl_tbl(l_idx).burden_usage       := cr_rec.burden_usage ;
        x_dtl_tbl(l_idx).item_qty           := cr_rec.item_qty ;
        x_dtl_tbl(l_idx).item_uom           := cr_rec.item_uom ;
        x_dtl_tbl(l_idx).burden_qty         := cr_rec.burden_qty ;
        x_dtl_tbl(l_idx).burden_uom         := cr_rec.burden_uom ;
        x_dtl_tbl(l_idx).burden_factor      := cr_rec.burden_factor ;
        x_dtl_tbl(l_idx).delete_mark        := cr_rec.delete_mark ;

    END LOOP ;


    /*
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    */

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count             ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Get_Burden_Details_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Get_Burden_Details_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Get_Burden_Details_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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
END Get_Burden_Details ;
--
-- Func start of comments
--+==========================================================================+
--|  Function Name                                                           |
--|       check_records_exist                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This procedure checks for the existance of records for a given     |
--|       organization, inventory item id, resource, period id, cost method  |
--|       cost component class and analysis code                             |
--|  USAGE                                                                   |
--|       In case of insert API, if record exists raise error.               |
--|       In case of update/delete API, if record does not exists raise error|
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_organization_id  organization id                                 |
--|       p_inventory_item_id                                                |
--|       p_resources                                                        |
--|       p_period_id                                                        |
--|       p_cost_type_id                                                     |
--|       p_cost_cmpntcls_id                                                 |
--|       p_cost_analysis_code                                               |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE : If records exist                                            |
--|       FALSE : If records does not exist                                  |
--|                                                                          |
--|  HISTORY                                                                 |
--|   3-apr-07 pmarada - created, bug 5589409                                |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION check_records_exist
(
   p_organization_id   IN cm_brdn_dtl.organization_id%TYPE,
   p_inventory_item_id IN cm_brdn_dtl.inventory_item_id%TYPE,
   p_resources         IN cm_brdn_dtl.resources%TYPE,
   p_period_id         IN cm_brdn_dtl.period_id%TYPE,
   p_cost_type_id      IN cm_brdn_dtl.cost_type_id%TYPE ,
   p_cost_cmpntcls_id  IN cm_brdn_dtl.cost_cmpntcls_id%TYPE,
   p_cost_analysis_code IN cm_brdn_dtl.cost_analysis_code%TYPE
)
RETURN BOOLEAN
IS
    CURSOR Cur_burden_dtl
           ( cp_organization_id   cm_brdn_dtl.organization_id%TYPE,
             cp_inventory_item_id cm_brdn_dtl.inventory_item_id%TYPE,
             cp_resources         cm_brdn_dtl.resources%TYPE ,
             cp_period_id         cm_brdn_dtl.period_id%TYPE,
             cp_cost_type_id      cm_brdn_dtl.cost_type_id%TYPE ,
             cp_cost_cmpntcls_id  cm_brdn_dtl.cost_cmpntcls_id%TYPE,
             cp_cost_analysis_code cm_brdn_dtl.cost_analysis_code%TYPE
           )
    IS
    SELECT 'x'
      FROM cm_brdn_dtl
     WHERE organization_id   = cp_organization_id
       AND inventory_item_id = cp_inventory_item_id
       AND resources         = cp_resources
       AND period_id         = cp_period_id
       AND cost_type_id      = cp_cost_type_id
       AND cost_cmpntcls_id  = cp_cost_cmpntcls_id
       AND cost_analysis_code= cp_cost_analysis_code;

      l_rec_found VARCHAR2(10);
BEGIN

   l_rec_found := NULL;
  OPEN Cur_burden_dtl(p_organization_id, p_inventory_item_id, p_resources, p_period_id,
                      p_cost_type_id, p_cost_cmpntcls_id, p_cost_analysis_code) ;
  FETCH Cur_burden_dtl INTO l_rec_found;
  CLOSE Cur_burden_dtl;
  IF (l_rec_found IS NOT NULL) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE ;
  END IF;

END check_records_exist;

-- Func start of comments
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
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE log_msg
(
p_msg_text      IN VARCHAR2
)
IS
BEGIN

  -- IF FND_MSG_PUB.Check_Msg_Level (p_msg_lvl) THEN	-- Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_DEBUG');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
  -- END IF;

END log_msg ;

END GMF_BurdenDetails_PVT;

/
