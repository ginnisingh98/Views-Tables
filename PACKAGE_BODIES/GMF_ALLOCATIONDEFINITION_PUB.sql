--------------------------------------------------------
--  DDL for Package Body GMF_ALLOCATIONDEFINITION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ALLOCATIONDEFINITION_PUB" AS
/* $Header: GMFPALCB.pls 120.3 2005/12/06 04:30:23 jboppana noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFPALCS.pls                                        |
--| Package Name       : GMF_AllocationDefinition_PUB                        |
--| API name           : GMF_AllocationDefinition_PUB                        |
--| Type               : Public                                              |
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
--|     This package contains public procedures relating to Allocation       |
--|     Definition creation, updatation and deletetion.                      |
--|                                                                          |
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
--|    27/Feb/2001  Uday Moogala  Created  Bug# 1418689                      |
--|                                                                          |
--|    05/NOV/2002  Uday Moogala  Bug# 2659435                               |
--|      Performance related fixes. 					     |
--|	 1. remove G_MISS_xxx assignments.				     |
--|	 2. Conditionally calling debug routine.                             |
--|	 Also, fixed issues found during unit testing. Search for the bug    |
--|	 number to find the fixes.               			     |
--|    30/Oct/2002  R.Sharath Kumar Bug# 2641405 Added NOCOPY hint           |
--|    21/NOV/2002  Uday Moogala  Bug# 2681243                               |
--|      1. Return value of GMA_GLOBAL_GRP.set_who has changed to -1 from 0  |
--|         in case of invalid users.					     |
--| 	 2. Allocation method is always required.			     |
--|	 3. Made g_miss_char to g_miss_num for fixed_percentage validation   |
--|	 4. Removed "when others" section in validate_input_params           |
--+==========================================================================+
-- End of comments


--  Pre-defined API message levels
--
--      Valid values for message levels are from 1-50.
--      1 being least severe and 50 highest.
--
--      The pre-defined levels correspond to standard API
--      return status. Debug levels are used to control the amount of
--      debug information a program writes to the PL/SQL message table.

-- G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;
-- G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;
-- G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;
-- G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;
-- G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;
-- G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;


PROCEDURE Validate_Input_Params
(
 p_alloc_def_rec    IN  Allocation_Definition_Rec_Type
,x_alloc_def_rec    OUT NOCOPY Allocation_Definition_Rec_Type
,x_user_id          OUT NOCOPY fnd_user.user_id%TYPE
,x_return_status    OUT NOCOPY VARCHAR2
) ;
--
-- Function to check existence of allocation definition
FUNCTION check_alloc_def
(
 p_alloc_id 	IN gl_aloc_bas.alloc_id%TYPE
,p_alloc_method  IN gl_aloc_bas.alloc_method%TYPE
)
RETURN BOOLEAN ;
--
FUNCTION is_fxdpct_hundred
(
 p_alloc_id      IN gl_aloc_bas.alloc_id%TYPE
)
RETURN BOOLEAN ;
--
FUNCTION check_record_exist
(
p_alloc_id      IN gl_aloc_bas.alloc_id%TYPE,
p_line_no       IN gl_aloc_bas.line_no%TYPE
)
RETURN BOOLEAN ;
--
PROCEDURE log_msg	-- Bug 2659435: Removed first param for debug level
(
 p_msg_text      IN VARCHAR2
);
--
-- Bug 2659435: Added new procedure to log header message
PROCEDURE add_header_to_error_stack
(
 p_header	Allocation_Definition_Rec_Type
);
--

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMF_AllocationDefinition_PUB';

-- Bug 2659435
G_operation	VARCHAR2(30);	-- values will be Insert, Update or Delete
G_tmp		BOOLEAN := FND_MSG_PUB.Check_Msg_Level(0) ; -- temp call to initialize the
							    -- msg level threshhold gobal
							    -- variable.
G_debug_level	NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
								 -- to decide to log a debug msg.
G_header_logged VARCHAR2(1);  -- to indicate whether header is already in
			      -- error stack or not - avoid logging duplicate headers

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
--|                                   IN Allocation_Definition_Rec_Type    |
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

	p_allocation_definition_rec     IN  Allocation_Definition_Rec_Type
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Allocation_Definition' ;
	l_api_version           	CONSTANT NUMBER		:= 3.0 ;
    l_alloc_def_rec        		Allocation_Definition_Rec_Type ;
    l_user_id              		fnd_user.user_id%TYPE ;
	l_return_status        		VARCHAR2(2) ;
	l_count		       		NUMBER(10) ;
	l_data                 		VARCHAR2(2000) ;
	l_no_rows_ins                   NUMBER(10) ;

BEGIN


    -- Standard Start of API savepoint
    SAVEPOINT	 Create_Alloc_Definition_PUB;

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
    	log_msg('Beginning Create Allocation Definition process.');
    END IF;

    G_operation := 'INSERT';	-- Bug 2659435
    G_header_logged := 'N';  	-- to indicate header is logged or not for errors

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Validating  input parameters');
    END IF;

    -- Validate all the input parameters.
    VALIDATE_INPUT_PARAMS
            (p_alloc_def_rec       => p_allocation_definition_rec,
             x_alloc_def_rec       => l_alloc_def_rec,
             x_user_id             => l_user_id,
             x_return_status       => l_return_status) ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Return Status after validating : ' || l_return_status);
    END IF;

    -- Return if validation failures detected
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Calling private API to insert record.');
    END IF;

    GMF_AllocationDefinition_PVT.Create_Allocation_Definition
    ( p_api_version    		  => 3.0
    , p_init_msg_list  		  => FND_API.G_FALSE
    , p_commit         		  => FND_API.G_FALSE

    , x_return_status  		  => l_return_status
    , x_msg_count      		  => l_count
    , x_msg_data       		  => l_data

    , p_allocation_definition_rec => l_alloc_def_rec
    , p_user_id			  => l_user_id
    );

    -- Return if insert fails for any reason
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_no_rows_ins := SQL%ROWCOUNT ;

    IF l_alloc_def_rec.alloc_method = 1 THEN
      IF NOT is_fxdpct_hundred(l_alloc_def_rec.alloc_id) THEN
	add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_TOTAL_PCT_NOTHUNDRED');
        FND_MESSAGE.SET_TOKEN('ALLOC_ID',l_alloc_def_rec.alloc_id);
        FND_MSG_PUB.Add;
      END IF;
    END IF;

    add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_INS');
    FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_no_rows_ins);
    FND_MSG_PUB.Add;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('1 row inserted');
    END IF;

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
	ROLLBACK TO  Create_Alloc_Definition_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	(  	p_count         	=>      x_msg_count     ,
		p_data          	=>      x_msg_data
	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO  Create_Alloc_Definition_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	(  	p_count         	=>      x_msg_count     ,
		p_data          	=>      x_msg_data
	);
    WHEN OTHERS THEN
	ROLLBACK TO  Create_Alloc_Definition_PUB;
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
--|                                   IN Allocation_Definition_Rec_Type    |
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

p_allocation_definition_rec     IN  Allocation_Definition_Rec_Type
)
IS
	l_api_name              CONSTANT VARCHAR2(30)   := 'Update_Allocation_Definition' ;
   l_api_version           CONSTANT NUMBER         := 3.0 ;
   l_alloc_def_rec         Allocation_Definition_Rec_Type ;
   l_user_id               fnd_user.user_id%TYPE ;
	l_no_rows_upd           NUMBER(10) ;
	l_return_status		VARCHAR2(2) ;
	l_count			NUMBER(10) ;
	l_cnt			NUMBER(10) ;	-- used for validate basis account
	l_data                  VARCHAR2(2000) ;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Update_Alloc_Definition_PUB;

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
    	log_msg('Beginning Update Allocation Definition process.');
    END IF;

    G_operation := 'UPDATE';	-- Bug 2659435
    G_header_logged := 'N';  	-- to indicate header is logged or not for errors

    --
    -- Line Number.
    -- Should be not null
    --
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('validating line_no : '||p_allocation_definition_rec.line_no);
    END IF;

    IF (p_allocation_definition_rec.line_no IS NULL) OR
       (p_allocation_definition_rec.line_no = FND_API.G_MISS_NUM) THEN  -- Bug 2659435
	add_header_to_error_stack(p_allocation_definition_rec); -- Bug 2659435
	FND_MESSAGE.SET_NAME('GMF','GMF_API_LINE_NO_REQ');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Line number

    -- Validate all the input parameters.
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Validating  input parameters');
    END IF;

    VALIDATE_INPUT_PARAMS
            (p_alloc_def_rec       => p_allocation_definition_rec,
             x_alloc_def_rec       => l_alloc_def_rec,
             x_user_id             => l_user_id,
             x_return_status       => l_return_status) ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Return Status after validating : ' || l_return_status);
    END IF;

    -- Return if validation failures detected
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

/*
    -- Check whether any records exists for update
    SELECT count(1)
      INTO l_cnt
      FROM gl_aloc_bas
     WHERE alloc_id = l_alloc_def_rec.alloc_id
       AND line_no  = l_alloc_def_rec.line_no ;

    IF l_cnt = 0 THEN
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_FOUND');
        FND_MESSAGE.SET_TOKEN('ALLOC_ID',l_alloc_def_rec.alloc_id);
        FND_MESSAGE.SET_TOKEN('LINE_NO', l_alloc_def_rec.line_no);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF ;
*/

   -- Check whether any records exists for update
   IF NOT check_record_exist(l_alloc_def_rec.alloc_id, l_alloc_def_rec.line_no) THEN
	add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_FOUND');
        FND_MESSAGE.SET_TOKEN('ALLOC_ID',l_alloc_def_rec.alloc_id);
        FND_MESSAGE.SET_TOKEN('LINE_NO', l_alloc_def_rec.line_no);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
   END IF ;

   IF l_alloc_def_rec.delete_mark = 1 THEN
	add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
	FND_MESSAGE.SET_NAME('GMF','GMF_API_CANT_MARK_FOR_PURGE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Updating record for alloc_id : ' ||
			l_alloc_def_rec.alloc_id || ' line_no : ' || l_alloc_def_rec.line_no);
    END IF;

    GMF_AllocationDefinition_PVT.Update_Allocation_Definition
    ( p_api_version    		  => 3.0
    , p_init_msg_list  		  => FND_API.G_FALSE
    , p_commit         		  => FND_API.G_FALSE

    , x_return_status  		  => l_return_status
    , x_msg_count      		  => l_count
    , x_msg_data       		  => l_data

    , p_allocation_definition_rec => l_alloc_def_rec
    , p_user_id			  => l_user_id
    );

    -- Return if insert fails for any reason
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_no_rows_upd := SQL%ROWCOUNT ;

    IF l_alloc_def_rec.alloc_method = 1 THEN
      IF NOT is_fxdpct_hundred(l_alloc_def_rec.alloc_id) THEN
	add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_TOTAL_PCT_NOTHUNDRED');
        FND_MESSAGE.SET_TOKEN('ALLOC_ID',l_alloc_def_rec.alloc_id);
        FND_MSG_PUB.Add;
      END IF;
    END IF;

    add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_UPD');
    FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_no_rows_upd);
    FND_MSG_PUB.Add;

    --log_msg( l_no_rows_upd  || ' rows updated.');

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
        ROLLBACK TO  Update_Alloc_Definition_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Update_Alloc_Definition_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Update_Alloc_Definition_PUB;
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


--Start of comments
--+========================================================================+
--| API Name    : Delete_Allocation_Definition                             |
--| TYPE        : Public                                                   |
--| Function    : Deletes Allocation Definition based on the input         |
--|               from GL_ALOC_BAS                                         |
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version      IN  NUMBER       - Required           |
--|               p_init_msg_list    IN  VARCHAR2     - Optional           |
--|               p_commit           IN  VARCHAR2     - Optional           |
--|               p_allocation_definition_rec                              |
--|                                   IN Allocation_Definition_Rec_Type    |
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

PROCEDURE Delete_Allocation_Definition
(
p_api_version                   IN  NUMBER                      ,
p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE ,
p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,

x_return_status                 OUT NOCOPY VARCHAR2                    ,
x_msg_count                     OUT NOCOPY NUMBER                      ,
x_msg_data                      OUT NOCOPY VARCHAR2                    ,

p_allocation_definition_rec     IN Allocation_Definition_Rec_Type
)
IS
	l_api_name              CONSTANT VARCHAR2(30)   := 'Delete_Allocation_Definition' ;
	l_api_version           CONSTANT NUMBER         := 3.0 ;

        l_alloc_def_rec         Allocation_Definition_Rec_Type ;
        l_user_id               fnd_user.user_id%TYPE ;
        l_no_rows_del           NUMBER(10) ;
	l_count		        NUMBER(10) ;
	l_cnt		        NUMBER(10) ;
	l_user_name             fnd_user.user_name%TYPE ; --:= FND_API.G_MISS_CHAR ; Bug 2659435
	l_return_status         VARCHAR2(2) ;
	l_data                  VARCHAR2(2000) ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Delete_Alloc_Definition_PUB;

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
    	log_msg('Beginning Delete Allocation Definition process.');
    END IF;

    G_header_logged := 'N';  	-- Bug 2659435 to indicate header is logged or not for errors

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('alloc_id      : '|| p_allocation_definition_rec.alloc_id);
    	log_msg('alloc_code    : '|| p_allocation_definition_rec.alloc_code);
    	log_msg('legal entity id    : '|| p_allocation_definition_rec.legal_entity_id);
    	log_msg('line_no       : '|| p_allocation_definition_rec.line_no);
    	log_msg('user name     : ' || p_allocation_definition_rec.user_name);
    	log_msg('Validating  input parameters');
    END IF;

    --
    -- Line Number.
    -- Should be not null
    --
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('validating line_no : '||p_allocation_definition_rec.line_no);
    END IF;

    IF (p_allocation_definition_rec.line_no IS NULL) OR
       (p_allocation_definition_rec.line_no = FND_API.G_MISS_NUM) THEN  -- Bug 2659435
	  add_header_to_error_stack(p_allocation_definition_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_LINE_NO_REQ');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
    ELSE
        l_alloc_def_rec.line_no := p_allocation_definition_rec.line_no ;
    END IF;
    -- End Line number

    --
    -- Allocation Id
    --
    -- Use alloc_id if sent otherwise use Alloc_code and legal_entity_id
    -- If both are sent then use only alloc_id and ignore other params and log a message
    -- If both are not sent then raise error.
    --
    IF (p_allocation_definition_rec.alloc_id <> FND_API.G_MISS_NUM) AND
       (p_allocation_definition_rec.alloc_id IS NOT NULL) THEN
        -- validate alloc_id
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
        	log_msg('validating alloc_id : '||
					p_allocation_definition_rec.alloc_id);
        END IF;

        IF NOT GMF_VALIDATIONS_PVT.Validate_Alloc_Id(p_allocation_definition_rec.alloc_id) THEN
	  add_header_to_error_stack(p_allocation_definition_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ALLOC_ID');
          FND_MESSAGE.SET_TOKEN('ALLOC_ID',p_allocation_definition_rec.alloc_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_alloc_def_rec.alloc_id := p_allocation_definition_rec.alloc_id ;

        -- Log message if alloc_code and company is also passed
        IF ((p_allocation_definition_rec.alloc_code <> FND_API.G_MISS_CHAR) AND
	    (p_allocation_definition_rec.alloc_code IS NOT NULL)) OR
           ((p_allocation_definition_rec.legal_entity_id <> FND_API.G_MISS_NUM) AND
	    (p_allocation_definition_rec.legal_entity_id IS NOT NULL))
        THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
		add_header_to_error_stack(p_allocation_definition_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ALLOC_CODE');
                FND_MESSAGE.SET_TOKEN('ALLOC_CODE',p_allocation_definition_rec.alloc_code);
                FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY',p_allocation_definition_rec.LEGAL_ENTITY_ID);
                FND_MSG_PUB.Add;
          END IF;
        END IF;
    ELSIF ((p_allocation_definition_rec.alloc_code <> FND_API.G_MISS_CHAR) AND
	   (p_allocation_definition_rec.alloc_code IS NOT NULL)) AND
          ((p_allocation_definition_rec.LEGAL_ENTITY_ID <> FND_API.G_MISS_NUM) AND
	   (p_allocation_definition_rec.alloc_code IS NOT NULL)) THEN

        -- Convert value into ID.

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
        	log_msg(
		'Fetching alloc_id using alloc_code : '|| p_allocation_definition_rec.alloc_code ||
		' legal entity : '|| p_allocation_definition_rec.legal_entity_id);
        END IF;

        l_alloc_def_rec.alloc_id := GMF_VALIDATIONS_PVT.Fetch_Alloc_Id(
					p_allocation_definition_rec.alloc_code,
                                        p_allocation_definition_rec.legal_entity_id);

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
        	log_msg('alloc_id : '|| l_alloc_def_rec.alloc_id);
        END IF;

        IF l_alloc_def_rec.alloc_id IS NULL THEN      -- Alloc_Id fetch was not successful
          -- Conversion failed.
	  add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ALLOC_CODE');
          FND_MESSAGE.SET_TOKEN('ALLOC_CODE',p_allocation_definition_rec.alloc_code);
          FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY',p_allocation_definition_rec.legal_entity_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
	add_header_to_error_stack(p_allocation_definition_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_ALLOC_DTL_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Allocation Id

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('validating user_name : '|| p_allocation_definition_rec.user_name);
    END IF;

    IF (p_allocation_definition_rec.user_name <> FND_API.G_MISS_CHAR) AND
       (p_allocation_definition_rec.user_name IS NOT NULL)  THEN
    	GMA_GLOBAL_GRP.Get_who( p_user_name  => p_allocation_definition_rec.user_name
                          	, x_user_id  => l_user_id
                          	);
    	IF l_user_id = -1 THEN	-- Bug 2681243: GMA changed return status value to -1.
		add_header_to_error_stack(p_allocation_definition_rec); -- Bug 2659435
        	FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USER_NAME');
        	FND_MESSAGE.SET_TOKEN('USER_NAME',p_allocation_definition_rec.user_name);
        	FND_MSG_PUB.Add;
        	RAISE FND_API.G_EXC_ERROR;
    	ELSE
		l_alloc_def_rec.user_name := p_allocation_definition_rec.user_name;
    	END IF;
    ELSE
	add_header_to_error_stack(p_allocation_definition_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_USER_NAME_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End User Name


/*
    -- Check whether any records exists to delete
    SELECT count(1)
      INTO l_cnt
      FROM gl_aloc_bas
     WHERE alloc_id = l_alloc_def_rec.alloc_id
       AND line_no  = l_alloc_def_rec.line_no ;

    IF l_cnt = 0 THEN
	add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_FOUND');
        FND_MESSAGE.SET_TOKEN('ALLOC_ID',l_alloc_def_rec.alloc_id);
        FND_MESSAGE.SET_TOKEN('LINE_NO', l_alloc_def_rec.line_no);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF ;
*/

   -- Check whether any records exists for update
   IF NOT check_record_exist(l_alloc_def_rec.alloc_id, l_alloc_def_rec.line_no) THEN
	add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_FOUND');
        FND_MESSAGE.SET_TOKEN('ALLOC_ID',l_alloc_def_rec.alloc_id);
        FND_MESSAGE.SET_TOKEN('LINE_NO', l_alloc_def_rec.line_no);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
   END IF ;

    l_alloc_def_rec.delete_mark := 1;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('deleteing record for alloc_id : ' ||
				l_alloc_def_rec.alloc_id ||' line_no : ' || l_alloc_def_rec.line_no);
    END IF;

    GMF_AllocationDefinition_PVT.Update_Allocation_Definition
    ( p_api_version    		  => 3.0
    , p_init_msg_list  		  => FND_API.G_FALSE
    , p_commit         		  => FND_API.G_FALSE

    , x_return_status  		  => l_return_status
    , x_msg_count      		  => l_count
    , x_msg_data       		  => l_data

    , p_allocation_definition_rec => l_alloc_def_rec
    , p_user_id			  => l_user_id
   );

    -- Return if insert fails for any reason
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_no_rows_del := SQL%ROWCOUNT ;

    IF p_allocation_definition_rec.alloc_method = 1 THEN
      IF NOT is_fxdpct_hundred(l_alloc_def_rec.alloc_id) THEN
	add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_TOTAL_PCT_NOTHUNDRED');
        FND_MESSAGE.SET_TOKEN('ALLOC_ID',l_alloc_def_rec.alloc_id);
        FND_MSG_PUB.Add;
      END IF;
    END IF;

    add_header_to_error_stack(l_alloc_def_rec); -- Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_DEL');
    FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_no_rows_del);
    FND_MSG_PUB.Add;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg(l_no_rows_del || ' rows deleted.');
    END IF;

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
        ROLLBACK TO  Delete_Alloc_Definition_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Delete_Alloc_Definition_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Delete_Alloc_Definition_PUB;
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

END Delete_Allocation_Definition ;

-- Proc start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Input_Params                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       Validates all the input parameters.                                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_allocation_definition_rec IN  Allocation_Definition_Rec_Type     |
--|       x_return_status    	      OUT VARCHAR2                           |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If succesfully initialized all variables                   |
--|       FALSE - If any error                                               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Proc end of comments

PROCEDURE Validate_Input_Params
(
 p_alloc_def_rec    	IN  Allocation_Definition_Rec_Type
,x_alloc_def_rec    	OUT NOCOPY Allocation_Definition_Rec_Type
,x_user_id          	OUT NOCOPY fnd_user.user_id%TYPE
,x_return_status    	OUT NOCOPY VARCHAR2
)
IS
    -- Bug 2659435. Commented all default assignments to increase performance.
    l_Alloc_id              NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_alloc_code            gl_aloc_mst.alloc_code%TYPE         ; -- := FND_API.G_MISS_CHAR ;
    l_legal_entity_id       gmf_legal_entities.legal_entity_id%TYPE            ; -- := FND_API.G_MISS_CHAR ;
    l_alloc_method          NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_line_no               NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_Item_Id               NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_item_number               mtl_item_flexfields.item_number%TYPE            ; -- := FND_API.G_MISS_CHAR ;
    l_basis_account_id     gl_aloc_bas.basis_account_id%TYPE  ;
    l_basis_account_key     gl_aloc_bas.basis_account_key%TYPE  ; -- := FND_API.G_MISS_CHAR ;
    l_balance_type          NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_bas_ytd_ptd           NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_basis_type            NUMBER;
    l_fixed_percent         NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_cmpntcls_id           NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_cost_cmpntcls_code    cm_cmpt_mst.cost_cmpntcls_code%TYPE ; -- := FND_API.G_MISS_CHAR ;
    l_analysis_code         cm_alys_mst.cost_analysis_code%TYPE ; -- := FND_API.G_MISS_CHAR ;
    l_organization_id       NUMBER          ; -- := FND_API.G_MISS_CHAR ;
    l_delete_mark           NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_user_name             fnd_user.user_name%TYPE             ; -- := FND_API.G_MISS_CHAR ;
    l_user_id               NUMBER                              ; -- := FND_API.G_MISS_NUM ;
    l_usage_ind             cm_cmpt_mst.usage_ind%TYPE ;
    l_status		NUMBER(2) ;	-- used for validate basis account
    l_organization_code     mtl_parameters.organization_code%TYPE;


BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_Alloc_id            := p_alloc_def_rec.Alloc_id ;
    l_alloc_code          := p_alloc_def_rec.alloc_code ;
    l_legal_entity_id     := p_alloc_def_rec.legal_entity_id ;
    l_alloc_method        := p_alloc_def_rec.alloc_method ;
    l_line_no             := p_alloc_def_rec.line_no ;
    l_Item_Id             := p_alloc_def_rec.Item_Id ;
    l_item_number         := p_alloc_def_rec.item_number ;
    l_basis_account_id   := p_alloc_def_rec.basis_account_id ;
    l_basis_account_key   := p_alloc_def_rec.basis_account_key ;
    l_balance_type        := p_alloc_def_rec.balance_type ;
    l_bas_ytd_ptd         := p_alloc_def_rec.bas_ytd_ptd ;
    l_basis_type          := p_alloc_def_rec.basis_type ;
    l_fixed_percent       := p_alloc_def_rec.fixed_percent ;
    l_cmpntcls_id         := p_alloc_def_rec.cmpntcls_id ;
    l_cost_cmpntcls_code  := p_alloc_def_rec.cost_cmpntcls_code ;
    l_analysis_code       := p_alloc_def_rec.analysis_code ;
    l_organization_id     := p_alloc_def_rec.organization_id ;
    l_organization_code   := p_alloc_def_rec.organization_code;
    l_delete_mark         := p_alloc_def_rec.delete_mark ;
    l_user_name           := p_alloc_def_rec.user_name ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('alloc_id      : '|| l_alloc_id);
    	log_msg('alloc_code    : '|| l_alloc_code);
    	log_msg('legal_entity_id: '|| l_legal_entity_id);
    	log_msg('alloc_mthd    : '||l_alloc_method);
    	log_msg('line_no       : '||l_line_no);
    	log_msg('item_id       : ' || l_item_id);
    	log_msg('item_number   : ' || l_item_number);
    	log_msg('Basis Acct    : '|| l_Basis_account_key);
    	log_msg('Balance Type  : '|| l_balance_type);
    	log_msg('Basis YTP/PTD : '|| l_bas_ytd_ptd);
      log_msg('basis type    : '||l_basis_type);
    	log_msg('fixed %       : '||l_fixed_percent);
    	log_msg('Cmpt Cls ID   : '|| l_cmpntcls_id);
    	log_msg('Cmpt Cls Code : '|| l_cost_cmpntcls_code);
    	log_msg('analysis_code : ' || l_analysis_code);
    	log_msg('organization_id : ' || l_organization_id);
    	log_msg('delete_mark   : ' || l_delete_mark);
    	log_msg('user name     : ' || l_user_name);
    END IF;

    --
    -- Allocation Id
    --
    -- Use alloc_id if sent otherwise use Alloc_code and legal_entity_id
    -- If both are sent then use only alloc_id and ignore other params and log a message
    -- If both are not sent then raise error.
    --

    IF (l_alloc_id <> FND_API.G_MISS_NUM) AND
       (l_alloc_id IS NOT NULL) THEN
    	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    		log_msg('validating alloc_id : '|| l_alloc_id);
    	END IF;

      	-- validate alloc_id
      	IF NOT GMF_VALIDATIONS_PVT.Validate_Alloc_Id(l_alloc_id) THEN
      	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
      	  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ALLOC_ID');
      	  FND_MESSAGE.SET_TOKEN('ALLOC_ID',l_alloc_id);
      	  FND_MSG_PUB.Add;
      	  RAISE FND_API.G_EXC_ERROR;
      	END IF;

      	SELECT legal_entity_id
      	  INTO l_legal_entity_id
      	  FROM gl_aloc_mst
      	 WHERE alloc_id = l_alloc_id ;

       	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
       		log_msg('legal_entity_id : '|| l_legal_entity_id);
       	END IF;

   	-- Log message if alloc_code and company is also passed
   	IF ((l_alloc_code <> FND_API.G_MISS_CHAR) AND
   	    (l_alloc_code IS NOT NULL)) OR
              ((p_alloc_def_rec.legal_entity_id <> FND_API.G_MISS_NUM) AND
   	    (p_alloc_def_rec.legal_entity_id IS NOT NULL))  THEN
   	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
   		add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
   		FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ALLOC_CODE');
   		FND_MESSAGE.SET_TOKEN('ALLOC_CODE',l_alloc_code);
   		FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY',p_alloc_def_rec.legal_entity_id);
   		FND_MSG_PUB.Add;
   		--RAISE FND_API.G_EXC_ERROR;
   	  END IF;
   	END IF;
     ELSIF ((l_alloc_code <> FND_API.G_MISS_CHAR) AND
	   (l_alloc_code IS NOT NULL)) AND
          ((l_legal_entity_id <> FND_API.G_MISS_NUM) AND
           (l_legal_entity_id IS NOT NULL))   THEN


        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
        	log_msg('Fetching alloc_id using alloc_code : '||
						 l_alloc_code || ' legal_entity_id : '|| l_legal_entity_id);
        END IF;

	-- Convert value into ID.
	     l_alloc_id := GMF_VALIDATIONS_PVT.Fetch_Alloc_Id(l_alloc_code,
				     l_legal_entity_id);

      	IF l_alloc_id IS NULL THEN	-- Alloc_Id fetch was not successful
      	  -- Conversion failed.
      	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
      	  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ALLOC_CODE');
                FND_MESSAGE.SET_TOKEN('ALLOC_CODE',l_alloc_code);
                FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY',l_legal_entity_id);
      	  FND_MSG_PUB.Add;
      	  RAISE FND_API.G_EXC_ERROR;
      	END IF;
     ELSE
      	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
      	  FND_MESSAGE.SET_NAME('GMF','GMF_API_ALLOC_DTL_REQ');
      	  FND_MSG_PUB.Add;
      	  RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Allocation Id

    --
    -- Allocation Method
    -- Should be 0 or 1
    --
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('validating alloc_mthd : '||l_alloc_method);
    END IF;

    IF (l_alloc_method <> FND_API.G_MISS_NUM) AND
       (l_alloc_method IS NOT NULL) THEN
   	IF (l_alloc_method NOT IN (0,1)) THEN
   	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
   	  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ALLOC_MTHD');
   	  FND_MESSAGE.SET_TOKEN('ALLOC_METHOD',l_alloc_method);
   	  FND_MSG_PUB.Add;
   	  RAISE FND_API.G_EXC_ERROR;
   	END IF;
    ELSE
   	add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
   	FND_MESSAGE.SET_NAME('GMF','GMF_API_ALLOC_MTHD_REQ');
   	FND_MSG_PUB.Add;
   	RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Allocation Method

    --
    -- Checks whether alloc def already exists or not. If exist, compare alloc_method.
    -- If alloc_method differs raise error.
    -- Bug 2659435: was above alloc method check
    --
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('checking for consistency of alloc method...');
    END IF;

    IF NOT check_alloc_def(l_alloc_id, l_alloc_method) THEN
   	add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
   	FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ALLOC_DEF');
   	FND_MESSAGE.SET_TOKEN('ALLOC_METHOD',l_alloc_method);
   	FND_MSG_PUB.Add;
   	RAISE FND_API.G_EXC_ERROR;
    END IF ;

--Organization Validation
         IF	(l_organization_id <> FND_API.G_MISS_NUM)
			AND	(l_organization_id IS NOT NULL)
			THEN
				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating organization id: ' || l_organization_id);
				END IF;

				IF NOT GMF_VALIDATIONS_PVT.Validate_organization_Id(l_organization_id)
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_ID');
					FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',l_organization_id);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;

				-- Log message if organization_code is also passed
				IF (l_organization_code <> FND_API.G_MISS_CHAR) AND (l_organization_code IS NOT NULL)
				THEN

					IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
					THEN

						FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ORGN_CODE');
						FND_MESSAGE.SET_TOKEN('ORG_CODE',l_organization_code);
						FND_MSG_PUB.Add;

					END IF;
				END IF;
			ELSIF	((l_organization_code <> FND_API.G_MISS_CHAR)AND	(l_organization_code IS NOT NULL))
			THEN

				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating Organization Code : ' || l_organization_code);
				END IF;

            l_organization_id := gmf_validations_pvt.validate_organization_code(l_organization_code);

				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('organization_id : ' || l_organization_id);
				END IF;

				IF l_organization_id IS NULL
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_CODE');
					FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',l_organization_code);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			ELSE

				FND_MESSAGE.SET_NAME('GMF','GMF_API_ORGN_ID_REQ');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
         END IF;



    --
    -- Item Id
    --
    -- Use item_id if sent otherwise use item_number
    -- If both are sent then use only item_id and ignore other params and log a message
    -- If both are not sent then raise error.
    --
    IF (l_item_id <> FND_API.G_MISS_NUM) AND
       (l_item_id IS NOT NULL) THEN
	-- validate item_id
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
      	log_msg('validating item_id : ' || l_item_id);
      END IF;

   	IF NOT GMF_VALIDATIONS_PVT.Validate_inventory_item_Id(l_item_id,l_organization_id) THEN
   	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
   	  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_ID');
   	  FND_MESSAGE.SET_TOKEN('ITEM_ID',l_item_id);
        FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',l_organization_id);
   	  FND_MSG_PUB.Add;
   	  RAISE FND_API.G_EXC_ERROR;
   	END IF;

   	-- Log message if item_number is also passed
   	IF (l_item_number <> FND_API.G_MISS_CHAR) AND
          	   (l_item_number IS NOT NULL) THEN
   	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
   		add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
   		FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ITEM_NO');
   	  	FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_number);
   		FND_MSG_PUB.Add;
   	  END IF;
   	END IF;
    ELSIF (l_item_number <> FND_API.G_MISS_CHAR) AND
          (l_item_number IS NOT NULL) THEN
	-- Convert value into ID.
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
            	log_msg('validating item_number : ' || l_item_number);
            END IF;

            l_item_id := GMF_VALIDATIONS_PVT.Validate_Item_Number(l_item_number,l_organization_id);
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
            	log_msg('item_id : ' || l_item_id);
            END IF;

         	IF l_item_id IS NULL THEN	-- item_Id fetch was not successful
         	  -- Conversion failed.
         	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
         	  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_NO');
         	  FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_number);
              FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',l_organization_id);
         	  FND_MSG_PUB.Add;
         	  RAISE FND_API.G_EXC_ERROR;
         	END IF;
     ELSIF (l_item_number = FND_API.G_MISS_CHAR AND		-- Bug 2659435
	    G_operation = 'UPDATE') OR
	   (G_operation = 'INSERT') THEN
      	add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
      	FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_ID_REQ');
      	FND_MSG_PUB.Add;
      	RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Item Id

    --
    -- Basis Account Key and Balance Type
    -- Validate only when alloc_method = 0 else null.
    --
    IF l_alloc_method = 0 THEN
    	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    		log_msg('validating Basis Acct : '|| l_Basis_account_key);
    	END IF;

	-- Validate Basis Account Key
     IF	(l_basis_account_id <> FND_API.G_MISS_NUM)
			AND	(l_basis_account_id IS NOT NULL)
			THEN
				IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
				THEN
					log_msg('Validating basis_account_id: ' || l_basis_account_id);
				END IF;

				IF NOT GMF_VALIDATIONS_PVT.Validate_account_Id(l_basis_account_id,l_legal_entity_id)
				THEN
					FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ACCT_ID');
					FND_MESSAGE.SET_TOKEN('ACCOUNT_ID',l_basis_account_id);
					FND_MSG_PUB.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;


				IF (l_basis_account_key <> FND_API.G_MISS_CHAR) AND (l_basis_account_key IS NOT NULL)
				THEN

					IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
					THEN

						FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ACCT_KEY');
						FND_MESSAGE.SET_TOKEN('ACCT_KEY',l_basis_account_key);
						FND_MSG_PUB.Add;

					END IF;
				END IF;
       ELSIF (l_Basis_account_key <> FND_API.G_MISS_CHAR) AND
             	   (l_Basis_account_key IS NOT NULL) THEN

            	   l_basis_account_id := GMF_VALIDATIONS_PVT.Validate_Basis_account_key(l_Basis_account_key, l_legal_entity_id) ;

            	  IF l_basis_account_id IS NULL THEN 	-- error in acctg_unit_no
                   add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
            	    FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ACCT_NO');
            	    FND_MESSAGE.SET_TOKEN('BAS_ACC_KEY',l_Basis_account_key);
            	    FND_MSG_PUB.Add;
            	    RAISE FND_API.G_EXC_ERROR;
            	  END IF;
       ELSIF (l_basis_account_key = FND_API.G_MISS_CHAR AND	G_operation = 'UPDATE') OR
            	     (G_operation = 'INSERT') THEN
            	       add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
                      FND_MESSAGE.SET_NAME('GMF','GMF_API_ACCOUNT_ID_REQ');
                      FND_MSG_PUB.Add;
                      RAISE FND_API.G_EXC_ERROR;
       END IF;
	-- End Basis Account Key

	--
	-- Balance Type must be 0 = Statistical; 1 = Budget;  or 2 = Actual
	--
    	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    		log_msg('validating Balance Type :'|| l_balance_type);
    	END IF;

	IF (l_balance_type <> FND_API.G_MISS_NUM) AND
           (l_balance_type IS NOT NULL) THEN
	  -- validate Basis Acct Key
	  IF (l_balance_type NOT IN (0,1,2) ) THEN
	    add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
	    FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_BALANCE_TYPE');
	    FND_MESSAGE.SET_TOKEN('BALANCE_TYPE',l_balance_type);
	    FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;
 	ELSIF (l_balance_type = FND_API.G_MISS_NUM AND	-- Bug 2659435
	    G_operation = 'UPDATE') OR
	   (G_operation = 'INSERT') THEN
	       add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_BALANCE_TYPE_REQ');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
	END IF;
	-- End Balance Type

	--
	-- Basis YTP/PTD must be either 0 = Period To Date Basis Amount or
	-- 1 = Year To Date Basis Amount
	--
    	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    		log_msg('validating Basis YTP/PTD :'|| l_bas_ytd_ptd);
    	END IF;

   	IF (l_bas_ytd_ptd <> FND_API.G_MISS_NUM) AND
              (l_bas_ytd_ptd IS NOT NULL) THEN
   	  -- validate Basis YTP/PTD
   	  IF (l_bas_ytd_ptd NOT IN (0,1) ) THEN
   	    add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
   	    FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_BAS_YTD_PTD');
   	    FND_MESSAGE.SET_TOKEN('BAS_YTD_PTD',l_bas_ytd_ptd);
   	    FND_MSG_PUB.Add;
   	    RAISE FND_API.G_EXC_ERROR;
   	  END IF;
 	   ELSIF (l_bas_ytd_ptd = FND_API.G_MISS_NUM AND	-- Bug 2659435
	       G_operation = 'UPDATE') OR
	      (G_operation = 'INSERT') THEN
	       add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_BAS_YTD_PTD_REQ');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
	   END IF;
	-- End Basis YTP/PTD

        IF (l_basis_type <> FND_API.G_MISS_NUM) AND
           (l_basis_type IS NOT NULL) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
      		add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_BASIS_TYPE');
      	   FND_MESSAGE.SET_TOKEN('BASIS_TYPE',l_basis_type);
            FND_MSG_PUB.Add;
          END IF;
        END IF;
        IF (l_fixed_percent <> FND_API.G_MISS_NUM) AND
           (l_fixed_percent IS NOT NULL) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
      		add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_FIXED_PERCENT');
      	   FND_MESSAGE.SET_TOKEN('FIXED_PERCENT',l_fixed_percent);
            FND_MSG_PUB.Add;
          END IF;
        END IF;

   ELSE	-- method = 1
      l_basis_account_key := '' ;
   	l_balance_type      := '' ;
   	l_bas_ytd_ptd       := '' ;
   END IF;

    --
    -- Fixed percentage - Used only when Allocation Method = 1
    --
    IF l_alloc_method = 1 THEN
	--

      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    		log_msg('validating basis type :'||l_basis_type);
    	END IF;

      	IF (l_basis_type <> FND_API.G_MISS_NUM) AND(l_basis_type IS NOT NULL) THEN
      	  IF (l_basis_type <> 1) THEN
      	    add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
      	    FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_BASIS_TYPE');
      	    FND_MESSAGE.SET_TOKEN('BASIS_TYPE',l_basis_type);
      	    FND_MSG_PUB.Add;
      	    RAISE FND_API.G_EXC_ERROR;
      	  END IF;
         ELSE
            l_basis_type := 1;
      	END IF;
	-- Fixed percentage must be a valid number between 1 and 100
	-- (Used only when Allocation Method = 1).
	--
    	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    		log_msg('validating fixed percentage :'||l_fixed_percent);
    	END IF;

      	IF (l_fixed_percent <> FND_API.G_MISS_NUM) AND(l_fixed_percent IS NOT NULL) THEN
      	  IF (l_fixed_percent < 0 OR l_fixed_percent > 100) THEN
      	    add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
      	    FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_FIXED_PERCENT');
      	    FND_MESSAGE.SET_TOKEN('FIXED_PERCENT',l_fixed_percent);
      	    FND_MSG_PUB.Add;
      	    RAISE FND_API.G_EXC_ERROR;
      	  END IF;
       	ELSIF (l_fixed_percent = FND_API.G_MISS_NUM AND	G_operation = 'UPDATE') OR
      	       (G_operation = 'INSERT') THEN
      	       add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_FIXED_PERCENT_REQ');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
      	END IF;
         IF( ((p_alloc_def_rec.basis_account_id <> FND_API.G_MISS_NUM) AND
             	     (p_alloc_def_rec.basis_account_id IS NOT NULL)) OR
             ((p_alloc_def_rec.basis_account_key <> FND_API.G_MISS_CHAR) AND
             	     (p_alloc_def_rec.basis_account_key IS NOT NULL)) OR
      	    ((p_alloc_def_rec.balance_type <> FND_API.G_MISS_NUM) AND
             	     (p_alloc_def_rec.balance_type IS NOT NULL)) OR
                  ((p_alloc_def_rec.bas_ytd_ptd <> FND_API.G_MISS_NUM) AND
             	     (p_alloc_def_rec.bas_ytd_ptd IS NOT NULL))
      	  ) THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
      		          add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
                      FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_BASIS');
                      FND_MSG_PUB.Add;
                END IF;
              END IF;
      ELSE
      	l_fixed_percent := '' ;
         l_basis_type := '';
      END IF;
    -- End Fixed percentage

    --
    -- CmpntCls Id
    --
    -- Use cmpntcls_id if sent otherwise use cmpntcls_code
    -- If both are sent then use only cmpntcls_id and ignore other params and log a message
    -- If both are not sent then raise error.
    --
    IF (l_cmpntcls_id <> FND_API.G_MISS_NUM) AND
       (l_cmpntcls_id IS NOT NULL) THEN
    	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    		log_msg('validating Cmpt Cls ID :'|| l_cmpntcls_id);
    	END IF;

	-- validate CmpntCls Id
        GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Id (
                        l_cmpntcls_id,l_cost_cmpntcls_code,l_usage_ind);

        IF l_usage_ind IS NULL THEN
	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
	  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_ID');
	  FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID',l_cmpntcls_id);
	  FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
        ELSIF l_usage_ind <> 4 THEN
	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_USG_NOT_ALC');
          FND_MESSAGE.SET_TOKEN('CMPNTCLS',l_cmpntcls_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Log message if cost_cmpntcls_code is also passed
	IF (p_alloc_def_rec.cost_cmpntcls_code <> FND_API.G_MISS_CHAR) AND
           (p_alloc_def_rec.cost_cmpntcls_code IS NOT NULL) THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
	    add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
	    FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_CMPNTCLS_CODE');
            FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_alloc_def_rec.cost_cmpntcls_code);
	    FND_MSG_PUB.Add;
	  END IF;
	END IF;
    ELSIF (l_cost_cmpntcls_code <> FND_API.G_MISS_CHAR) AND
          (l_cost_cmpntcls_code IS NOT NULL) THEN
    	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    		log_msg('validating Cmpt Cls Code :'|| l_cost_cmpntcls_code);
    	END IF;

	-- Convert value into ID.
        GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Code (
                                                          l_cost_cmpntcls_code,
                                                          l_cmpntcls_id,
                                                          l_usage_ind
                                                        ) ;
	IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
		log_msg('Cmpt Cls Id := ' || l_cmpntcls_id);
	END IF;

	IF (l_cmpntcls_id IS NULL) OR (l_usage_ind IS NULL) THEN	-- Cmpntcls_Id fetch was not successful
	  -- Conversion failed.
	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
	  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_CODE');
          FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',l_cost_cmpntcls_code);
	  FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
        ELSIF l_usage_ind <> 4 THEN
	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_USG_NOT_ALC');
          FND_MESSAGE.SET_TOKEN('CMPNTCLS',l_cost_cmpntcls_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
	END IF;
    ELSIF (l_cmpntcls_id = FND_API.G_MISS_NUM AND	-- Bug 2659435
	   G_operation = 'UPDATE') OR
	  (G_operation = 'INSERT') THEN
	add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
	FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_ID_REQ');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End CmpntCls Id

    --
    -- Analysis Code
    --
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('validating analysis_code :' || l_analysis_code);
    END IF;

    IF (l_analysis_code <> FND_API.G_MISS_CHAR) AND
       (l_analysis_code IS NOT NULL) THEN
	IF NOT GMF_VALIDATIONS_PVT.Validate_Analysis_Code(l_analysis_code)
	THEN
	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
	  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ANALYSIS_CODE');
	  FND_MESSAGE.SET_TOKEN('ANALYSIS_CODE',l_analysis_code);
	  FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
    ELSIF (l_analysis_code = FND_API.G_MISS_CHAR AND	-- Bug 2659435
	   G_operation = 'UPDATE') OR
	  (G_operation = 'INSERT') THEN
	  add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
	  FND_MESSAGE.SET_NAME('GMF','GMF_API_ANALYSIS_CODE_REQ');
	  FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Analysis Code
    --
    -- Delete Mark
    --
    IF (l_delete_mark <> FND_API.G_MISS_NUM) AND
       (l_delete_mark IS NOT NULL) THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
      	log_msg('validating delete_mark :' || l_delete_mark);
      END IF;

      IF l_delete_mark NOT IN (0,1) THEN
      	add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
      	FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_DELETE_MARK');
      	FND_MESSAGE.SET_TOKEN('DELETE_MARK',l_delete_mark);
      	FND_MSG_PUB.Add;
      	RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF (l_delete_mark = FND_API.G_MISS_NUM AND	G_operation = 'UPDATE') OR
	  (G_operation = 'INSERT') THEN
	       add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_DELETE_MARK_REQ');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Delete Mark

    -- Populate WHO columns
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
    	log_msg('Validating user name : ' || l_user_name);
    END IF;

    IF (l_user_name <> FND_API.G_MISS_CHAR) AND
       (l_user_name IS NOT NULL)  THEN
    	GMA_GLOBAL_GRP.Get_who( p_user_name  => l_user_name
                          	, x_user_id  => l_user_id
                              );

    	IF l_user_id = -1 THEN	-- Bug 2681243: GMA changed return status value to -1.
		add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
		FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USER_NAME');
		FND_MESSAGE.SET_TOKEN('USER_NAME',l_user_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
    	END IF;
    ELSE
	add_header_to_error_stack(p_alloc_def_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_USER_NAME_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End User Name


    x_alloc_def_rec.Alloc_id            := l_Alloc_id ;
    x_alloc_def_rec.alloc_code          := l_alloc_code ;
    x_alloc_def_rec.legal_entity_id     := l_legal_entity_id ;
    x_alloc_def_rec.alloc_method        := l_alloc_method ;
    x_alloc_def_rec.line_no             := l_line_no ;
    x_alloc_def_rec.Item_Id             := l_Item_Id ;
    x_alloc_def_rec.item_number         := l_item_number ;
    x_alloc_def_rec.basis_account_id    := l_basis_account_id ;
    x_alloc_def_rec.basis_account_key   := l_basis_account_key ;
    x_alloc_def_rec.balance_type        := l_balance_type ;
    x_alloc_def_rec.bas_ytd_ptd         := l_bas_ytd_ptd ;
    x_alloc_def_rec.basis_type          := l_basis_type ;
    x_alloc_def_rec.fixed_percent       := l_fixed_percent ;
    x_alloc_def_rec.cmpntcls_id         := l_cmpntcls_id ;
    x_alloc_def_rec.cost_cmpntcls_code  := l_cost_cmpntcls_code ;
    x_alloc_def_rec.analysis_code       := l_analysis_code ;
    x_alloc_def_rec.organization_id     := l_organization_id ;
    x_alloc_def_rec.delete_mark         := l_delete_mark ;
    x_alloc_def_rec.user_name           := l_user_name ;
    x_user_id                           := l_user_id ;

EXCEPTION	-- Bug 2681243: removed when others to capture ORA errors.
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Validate_Input_Params;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       check_alloc_def                                                    |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function checks whether allocation definition is already      |
--|       defined or not. If defined, then check whether allocation methods  |
--|       are same. To add a Alloc Def line allocation methods should be     |
--|	  same.                                                              |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_alloc_id 		IN NUMBER(10) - Allocation Id                |
--|       p_alloc_method	IN NUMBER(10) - Allocation Method            |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Alloc Def is already defined and alloc methods are      |
--|		  same. And also if Alloc Def is not already defined.        |
--|       FALSE - If Alloc Def is already defined and alloc methods are      |
--|               not same.                                                  |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION check_alloc_def
(
p_alloc_id      IN gl_aloc_bas.alloc_id%TYPE,
p_alloc_method  IN gl_aloc_bas.alloc_method%TYPE
)
RETURN BOOLEAN
IS
  CURSOR Cur_gl_aloc_bas(p_alloc_id      gl_aloc_bas.alloc_id%TYPE,
			 p_alloc_method  gl_aloc_bas.alloc_method%TYPE)
  IS
      SELECT distinct alloc_method
        FROM gl_aloc_bas
       WHERE alloc_id = p_alloc_id
         AND delete_mark = 0;

  l_alloc_method                gl_aloc_bas.alloc_method%TYPE ;

BEGIN
  OPEN Cur_gl_aloc_bas(p_alloc_id, p_alloc_method);
  FETCH Cur_gl_aloc_bas INTO l_alloc_method;
  CLOSE Cur_gl_aloc_bas;

  IF l_alloc_method IS NOT NULL THEN
    IF l_alloc_method = p_alloc_method THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSE
     RETURN TRUE;
  END IF;
END check_alloc_def;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       is_fxdpct_hundred                                                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|	  This function checks whether fixed % is greater than hundred.      |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_alloc_id            IN NUMBER(10) - Allocation Id                |
--|       p_fixed_percent       IN NUMBER(10) - Fixed %                      |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If % is = 100                                              |
--|       FALSE - If % is <> 100                                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION is_fxdpct_hundred
(
p_alloc_id      IN gl_aloc_bas.alloc_id%TYPE
)
RETURN BOOLEAN
IS
  CURSOR Cur_gl_aloc_bas(p_alloc_id  gl_aloc_bas.alloc_id%TYPE)
  IS
      SELECT nvl(sum(fixed_percent),0)
        FROM gl_aloc_bas
       WHERE alloc_id     = p_alloc_id
         AND delete_mark  = 0
         AND alloc_method = 1 ;

  l_fixed_percent  gl_aloc_bas.fixed_percent%TYPE ;

BEGIN
  OPEN Cur_gl_aloc_bas(p_alloc_id);
  FETCH Cur_gl_aloc_bas INTO l_fixed_percent;
  CLOSE Cur_gl_aloc_bas;

  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
  	log_msg('Total fixed percent : '||to_char(l_fixed_percent));
  END IF;

  IF (l_fixed_percent) = 100 THEN
      RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;
END is_fxdpct_hundred;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       check_record_exist                                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function checks whether allocation definition exist or not    |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_alloc_id 		IN NUMBER(10) - Allocation Id                |
--|       p_line_no       	IN NUMBER(10) - Allocation Method            |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If record exist.                                           |
--|       FALSE - If record does not exist.                                  |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION check_record_exist
(
p_alloc_id      IN gl_aloc_bas.alloc_id%TYPE,
p_line_no       IN gl_aloc_bas.line_no%TYPE
)
RETURN BOOLEAN
IS
  CURSOR Cur_gl_aloc_bas(p_alloc_id gl_aloc_bas.alloc_id%TYPE,
			 p_line_no  gl_aloc_bas.line_no%TYPE)
  IS
      SELECT count(1)
        FROM gl_aloc_bas
       WHERE alloc_id = p_alloc_id
         AND line_no  = p_line_no ;

  l_count	NUMBER(10) ;

BEGIN
  OPEN Cur_gl_aloc_bas(p_alloc_id, p_line_no);
  FETCH Cur_gl_aloc_bas INTO l_count;
  CLOSE Cur_gl_aloc_bas;

    IF l_count = 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END check_record_exist;

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
--|       05/nov/2002 Uday Moogala Bug 2659435                               |
--|         Removed first param for debug level                              |
--|                                                                          |
--+==========================================================================+
-- Func end of comments


PROCEDURE log_msg
(
p_msg_text      IN VARCHAR2
)
IS
BEGIN

  -- IF FND_MSG_PUB.Check_Msg_Level (p_msg_lvl) THEN	Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_DEBUG');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
  -- END IF;	Bug 2659435

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
--|       05/11/2001 Uday Moogla - Created Bug 2659435                       |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE add_header_to_error_stack
(
 p_header	Allocation_Definition_Rec_Type
)
IS
BEGIN

  IF G_header_logged = 'N' THEN
    G_header_logged := 'Y';
    FND_MESSAGE.SET_NAME('GMF','GMF_API_ALLOCATION_HEADER');
    FND_MESSAGE.SET_TOKEN('ALLOCATION_ID',p_header.alloc_id);
    FND_MESSAGE.SET_TOKEN('ALLOCATION_CODE',p_header.alloc_code);
    FND_MESSAGE.SET_TOKEN('LEGAL ENTITY',p_header.legal_entity_id);
    FND_MESSAGE.SET_TOKEN('ITEM_ID',p_header.item_id);
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header.item_number);
    FND_MESSAGE.SET_TOKEN('CMPNT_CLASS_ID',p_header.cmpntcls_id);
    FND_MESSAGE.SET_TOKEN('CMPNT_CLASS_CODE',p_header.cmpntcls_id);
    FND_MSG_PUB.Add;
  END IF;

END add_header_to_error_stack;


END GMF_AllocationDefinition_PUB;

/
