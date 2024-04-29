--------------------------------------------------------
--  DDL for Package Body GMF_ALLOCATIONDEFINITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ALLOCATIONDEFINITION_PVT" AS
/* $Header: GMFVALCB.pls 120.2 2005/11/02 04:19:16 jboppana noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFPALCS.pls                                        |
--| Package Name       : GMF_AllocationDefinition_PVT                        |
--| API name           : GMF_AllocationDefinition_PVT                        |
--| Type               : Private                                             |
--| Pre-reqs           : N/A                                                 |
--| Function           : Allocation Definition creation, updatation and      |
--|                      deletetion.                                         |
--| Parameters         : N/A                                                 |
--|                                                                          |
--| Current Vers       : 3.0                                                 |
--| Previous Vers      : 2.0                                                 |
--| Initial Vers       : 1.0                                                 |
--|                                                                          |
--| Contents                                                                 |
--|	Create_Allocation_Definition                                         |
--|	Update_Allocation_Definition                                         |
--|	Delete_Allocation_Definition                                         |
--|                                                                          |
--| Notes                                                                    |
--|     This package contains public functions relating to Allocation        |
--|     Definition creation, updatation and deletetion DMLs.                 |
--|                                                                          |
--| HISTORY                                                                  |
--|    27/Feb/2001  Uday Moogala  Created  Bug# 1418689                      |
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
--+==========================================================================+
-- End of comments

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMF_AllocationDefinition_PVT';

G_debug_level   NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
                                                                 -- to decide to log a debug msg.



PROCEDURE log_msg	-- Bug 2659435: Removed first paramter for debug level
(
p_msg_text      IN VARCHAR2
);

--Start of comments
--+========================================================================+
--| API Name	: Create_Allocation_Definition                             |
--| TYPE	: Public                                           	   |
--| Function	: Creates a new Allocation Definition based on the input   |
--|                into table GL_ALOC_BAS                                  |
--| Pre-reqa	: None.                                                    |
--| Parameters	:                                                          |
--| IN		:                                                          |
--|		  p_api_version      IN  NUMBER       - Required           |
--|		  p_init_msg_list    IN  VARCHAR2     - Optional           |
--|		  p_commit           IN  VARCHAR2     - Optional           |
--|		  p_allocation_definition_rec                              |
--|                                   IN GMF_ALLOCATIONDEFINITION_PUB.Allocation_Definition_Rec_Type    |
--| OUT		:                                                          |
--|		  x_return_status    OUT VARCHAR2                          |
--|		  x_msg_count        OUT NUMBER                            |
--|		  x_msg_data         OUT VARCHAR2                          |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 3.0                              |
--|	  	  Previous Version	: 2.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Create_Allocation_Definition
(
        p_api_version                   IN  NUMBER                      ,
        p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,

        x_return_status                 OUT NOCOPY VARCHAR2                    ,
        x_msg_count                     OUT NOCOPY NUMBER                      ,
        x_msg_data                      OUT NOCOPY VARCHAR2                    ,

	p_allocation_definition_rec     IN  GMF_ALLOCATIONDEFINITION_PUB.Allocation_Definition_Rec_Type,
	p_user_id			IN  NUMBER			 -- Bug 2659435 Removed defaults
   )
IS

        l_api_name                      CONSTANT VARCHAR2(30)   := 'Create_Allocation_Definition' ;
        l_api_version                   CONSTANT NUMBER         := 3.0 ;
	l_line_no   			gl_aloc_bas.line_no%TYPE ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Create_Alloc_Definition_PVT;

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


    -- Generate line_no for the alloc_id
    SELECT NVL(MAX(line_no), 0)+1
      INTO l_line_no
      FROM gl_aloc_bas
     WHERE alloc_id = p_allocation_definition_rec.alloc_id ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Inserting record for alloc_id : ' ||
			p_allocation_definition_rec.alloc_id || ' line_no : ' || l_line_no);
    END IF;

    INSERT INTO gl_aloc_bas
    (
      alloc_id
    , line_no
    , alloc_method
    , inventory_item_id
    , basis_account_id
    , balance_type
    , bas_ytd_ptd
    , basis_type
    , fixed_percent
    , cmpntcls_id
    , analysis_code
    , organization_id
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , trans_cnt
    , text_code
    , delete_mark
    )
    VALUES
    (
      p_allocation_definition_rec.alloc_id
    , l_line_no
    , p_allocation_definition_rec.alloc_method
    , p_allocation_definition_rec.item_id
    , p_allocation_definition_rec.basis_account_id
    , p_allocation_definition_rec.balance_type
    , p_allocation_definition_rec.bas_ytd_ptd
    , p_allocation_definition_rec.basis_type
    , p_allocation_definition_rec.fixed_percent
    , p_allocation_definition_rec.cmpntcls_id
    , p_allocation_definition_rec.analysis_code
    , p_allocation_definition_rec.organization_id
    , sysdate
    , p_user_id
    , sysdate
    , p_user_id
    , FND_GLOBAL.LOGIN_ID
    , ''	-- transaction count (not in use)
    , ''	-- text code
    , 0		-- p_allocation_definition_rec.delete_mark
    )
    ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('1 row inserted');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count             ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Create_Alloc_Definition_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Alloc_Definition_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Create_Alloc_Definition_PVT;
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

END Create_Allocation_Definition;


--Start of comments
--+========================================================================+
--| API Name    : Update_Allocation_Definition                             |
--| TYPE        : Public                                                   |
--| Function    : Updates Allocation Definition based on the input         |
--|               into GL_ALOC_BAS                                         |
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version      IN  NUMBER       - Required           |
--|               p_init_msg_list    IN  VARCHAR2     - Optional           |
--|               p_commit           IN  VARCHAR2     - Optional           |
--|               p_allocation_definition_rec                              |
--|                                   IN GMF_ALLOCATIONDEFINITION_PUB.Allocation_Definition_Rec_Type    |
--| OUT         :                                                          |
--|               x_return_status    OUT VARCHAR2                          |
--|               x_msg_count        OUT NUMBER                            |
--|               x_msg_data         OUT VARCHAR2                          |
--|                                                                        |
--| Version     :                                                          |
--|               Current Version       : 3.0                              |
--|               Previous Version      : 2.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Update_Allocation_Definition
(
        p_api_version                   IN  NUMBER                      ,
        p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,

        x_return_status                 OUT NOCOPY VARCHAR2                    ,
        x_msg_count                     OUT NOCOPY NUMBER                      ,
        x_msg_data                      OUT NOCOPY VARCHAR2                    ,

        p_allocation_definition_rec     IN  GMF_ALLOCATIONDEFINITION_PUB.Allocation_Definition_Rec_Type,
        p_user_id                       IN  NUMBER                      -- Bug 2659435 Removed defaults
        )
IS

        l_api_name                      CONSTANT VARCHAR2(30)   := 'Create_Allocation_Definition' ;
        l_api_version                   CONSTANT NUMBER         := 3.0 ;
	l_no_rows_upd           	NUMBER(10) ;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Update_Alloc_Definition_PVT;

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
    	log_msg('Updating record for alloc_id : ' ||
	p_allocation_definition_rec.alloc_id || ' line_no : ' || p_allocation_definition_rec.line_no);
    END IF;

    update gl_aloc_bas
    SET
        inventory_item_id             = decode(p_allocation_definition_rec.item_id,
				     FND_API.G_MISS_NUM, NULL,
				     NULL, inventory_item_id,
				     p_allocation_definition_rec.item_id)
        ,basis_account_id  = decode(p_allocation_definition_rec.basis_account_id,
				     FND_API.G_MISS_NUM, NULL,
				     NULL, basis_account_id,
				     p_allocation_definition_rec.basis_account_id)
        ,balance_type       = decode(p_allocation_definition_rec.balance_type,
				     FND_API.G_MISS_NUM, NULL,
				     NULL, balance_type,
				     p_allocation_definition_rec.balance_type)
        ,bas_ytd_ptd        = decode(p_allocation_definition_rec.bas_ytd_ptd,
				     FND_API.G_MISS_NUM, NULL,
				     NULL, bas_ytd_ptd,
				     p_allocation_definition_rec.bas_ytd_ptd)
        ,basis_type      = decode(p_allocation_definition_rec.basis_type,
				     FND_API.G_MISS_NUM, NULL,
				     NULL, basis_type,
				     p_allocation_definition_rec.basis_type)
        ,fixed_percent      = decode(p_allocation_definition_rec.fixed_percent,
				     FND_API.G_MISS_NUM, NULL,
				     NULL, fixed_percent,
				     p_allocation_definition_rec.fixed_percent)
        ,cmpntcls_id        = decode(p_allocation_definition_rec.cmpntcls_id,
				     FND_API.G_MISS_NUM, NULL,
				     NULL, cmpntcls_id,
				     p_allocation_definition_rec.cmpntcls_id)
        ,analysis_code      = decode(p_allocation_definition_rec.analysis_code,
				     FND_API.G_MISS_CHAR, NULL,
				     NULL, analysis_code,
				     p_allocation_definition_rec.analysis_code)
        ,organization_id          = decode(p_allocation_definition_rec.organization_id,
				     FND_API.G_MISS_NUM, NULL,
				     NULL, organization_id,
				     p_allocation_definition_rec.organization_id)
        -- ,creation_date      = sysdate	-- Bug 2722404
        -- ,created_by         = p_user_id
        ,last_update_date   = sysdate
        ,last_updated_by    = p_user_id
        ,last_update_login  = FND_GLOBAL.LOGIN_ID
        ,delete_mark        = decode(p_allocation_definition_rec.delete_mark,
				     FND_API.G_MISS_NUM, NULL,
				     NULL, delete_mark,
				     p_allocation_definition_rec.delete_mark)
    WHERE
	alloc_id = p_allocation_definition_rec.alloc_id
    AND line_no  = p_allocation_definition_rec.line_no
    ;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count             ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Update_Alloc_Definition_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Update_Alloc_Definition_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Update_Alloc_Definition_PVT;
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

END Update_Allocation_Definition ;

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

END GMF_AllocationDefinition_PVT;

/
