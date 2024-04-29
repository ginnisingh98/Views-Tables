--------------------------------------------------------
--  DDL for Package Body GMF_RESOURCECOST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_RESOURCECOST_PUB" AS
/* $Header: GMFPRESB.pls 120.2.12000000.2 2007/03/07 13:10:01 pmarada ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFPRESB.pls                                        |
--| Package Name       : GMF_ResourceCost_PUB                                |
--| API name           : GMF_ResourceCost_PUB                                |
--| Type               : Public                                              |
--| Pre-reqs           : N/A                                                 |
--| Function           : Allocation Definition creation, updatation and      |
--|                      deletetion.                                         |
--| Parameters         : N/A                                                 |
--|                                                                          |
--| Current Vers       : 2.0                                                 |
--| Previous Vers      : 1.0                                                 |
--| Initial Vers       : 1.0                                                 |
--|                                                                          |
--| Contents                                                                 |
--|     Create_Resource_Cost                                                 |
--|     Update_Resource_Cost                                                 |
--|     Delete_Resource_Cost                                                 |
--|                                                                          |
--| Notes                                                                    |
--|     This package contains public procedures relating to Resource Cost    |
--|     creation, updatation and deletetion.                                 |
--|                                                                          |
--|                                                                          |
--|  Pre-defined API message levels                                          |
--|                                                                          |
--|     Valid values for message levels are from 1-50.                       |
--|      1 being least severe and 50 highest.                                |
--|                                                                          |
--|     The pre-defined levels correspond to standard API                    |
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
--|      Performance related fixes.                                          |
--|      1. remove G_MISS_xxx assignments.                                   |
--|      2. Conditionally calling debug routine.                             |
--|      Also, fixed issues found during unit testing. Search for the bug    |
--|      number to find the fixes.                                           |
--|    30-OCT-2002  RajaSekhar    Bug#2641405 Added NOCOPY hint              |
--|    21/NOV/2002  Uday Moogala  Bug# 2681243                               |
--|      1. Return value of GMA_GLOBAL_GRP.set_who has changed to -1 from 0  |
--|         in case of invalid users.                                        |
--|      2. Removed "when others" section in validate_input_params           |
--|    03/Dec/2002  Uday Moogala  Bug# 2692459                               |
--|      Modified code to verify for same usage um type as rsrc um type.     |
--|    13/May/2004 Dinesh Vadivel Bug# 3628252                               |
--|      Removed validation for nominal cost in VALIDATE_INPUT_PARAMS        |
--|      so that it takes negative entries                                   |
--|    19-sep-2005  Prasad marada  Inventory convergence modification, adding|
--|                                legal entity, organization id, period id, |
--|                                cost_type_id,usage_uom coulmns            |
--+==========================================================================+
-- End of comments



PROCEDURE Validate_Input_Params
(
  p_rsrc_cost_rec    IN  Resource_Cost_Rec_Type
 ,x_rsrc_cost_rec   OUT NOCOPY Resource_Cost_Rec_Type
 ,x_user_id         OUT NOCOPY NUMBER
 ,x_return_status   OUT NOCOPY VARCHAR2
) ;
--
-- Modified the function parameter as per the inventory convergence
FUNCTION check_records_exist
(
  p_legal_entity_id cm_rsrc_dtl.legal_entity_id%TYPE,
  p_organization_id cm_rsrc_dtl.organization_id%TYPE,
  p_resources       cm_rsrc_dtl.resources%TYPE,
  p_period_id       cm_rsrc_dtl.period_id%TYPE,
  p_cost_type_id    cm_rsrc_dtl.cost_type_id%TYPE
)

RETURN BOOLEAN ;
--
PROCEDURE log_msg       -- Bug 2659435: Removed first param for debug level
(
  p_msg_text      IN VARCHAR2
);
--
-- Bug 2659435: Added new procedure to log header message
PROCEDURE add_header_to_error_stack
(
 p_header       Resource_Cost_Rec_Type
);
--


-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMF_ResourceCost_PUB';

-- Bug 2659435
G_operation     VARCHAR2(30);   -- values will be Insert, Update or Delete
G_tmp           BOOLEAN := FND_MSG_PUB.Check_Msg_Level(0) ; -- temp call to initialize the
                                                            -- msg level threshhold gobal
                                                            -- variable.
G_debug_level   NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
                                                                 -- to decide to log a debug msg.
G_header_logged VARCHAR2(1);  -- to indicate whether header is already in
                              -- error stack or not - avoid logging duplicate headers


--Start of comments
--+========================================================================+
--| API Name    : Create_Resource_Cost                                     |
--| TYPE        : Public                                                   |
--| Function    : Creates a new Resource Cost based on the input           |
--|               into table CM_RSRC_DTL                                   |
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version       IN  NUMBER       - Required          |
--|               p_init_msg_list     IN  VARCHAR2     - Optional          |
--|               p_commit            IN  VARCHAR2     - Optional          |
--|               p_resource_cost_rec IN Resource_Cost_Rec_Type            |
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

PROCEDURE Create_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                            ,
        x_msg_count             OUT NOCOPY NUMBER                            ,
        x_msg_data              OUT NOCOPY VARCHAR2                            ,

        p_resource_cost_rec     IN Resource_Cost_Rec_Type
)
IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'Create_Resource_Cost' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        l_rsrc_cost_rec         Resource_Cost_Rec_Type ;
        l_return_status         VARCHAR2(2) ;
        l_user_id               NUMBER ;--fnd_user.user_id%TYPE ;
        l_count                 NUMBER(10) ;
        l_data                  VARCHAR2(2000) ;
        l_no_rows_ins                   NUMBER(10) ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Create_Alloc_Definition_PUB;

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

    G_operation := 'INSERT';    -- Bug 2659435
    G_header_logged := 'N';     -- to avoid logging duplicate header for errors

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Validating  input parameters');
    END IF;
    -- Validate all the input parameters.
    VALIDATE_INPUT_PARAMS
            (p_rsrc_cost_rec      => p_resource_cost_rec
            ,x_rsrc_cost_rec       => l_rsrc_cost_rec
            ,x_user_id             => l_user_id
            ,x_return_status       => l_return_status) ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
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

    --
    -- Check for duplicate record.
    --
    IF check_records_exist(p_legal_entity_id => l_rsrc_cost_rec.legal_entity_id,
                           p_organization_id => l_rsrc_cost_rec.organization_id,
                           p_resources       => l_rsrc_cost_rec.resources,
                           p_period_id       => l_rsrc_cost_rec.period_id,
                           p_cost_type_id    => l_rsrc_cost_rec.cost_type_id) THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_DUPLICATE_RES_COST');
          FND_MESSAGE.SET_TOKEN('RESOURCES',l_rsrc_cost_rec.resources);
          FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY_ID',l_rsrc_cost_rec.legal_entity_id);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',l_rsrc_cost_rec.organization_id);
          FND_MESSAGE.SET_TOKEN('PERIOD_ID',l_rsrc_cost_rec.period_id);
          FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',l_rsrc_cost_rec.cost_type_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Inserting record for resource : ' || l_rsrc_cost_rec.resources ||
                ' Legal entity id ' || l_rsrc_cost_rec.legal_entity_id ||
                ' Organization Id ' || l_rsrc_cost_rec.organization_id ||
                ' Period Id ' || l_rsrc_cost_rec.Period_id ||
                ' Cost type Id ' || l_rsrc_cost_rec.cost_type_id);

    END IF;

    -- call to private API to insert to record
    GMF_ResourceCost_PVT.Create_Resource_Cost
    ( p_api_version          => 2.0
    , p_init_msg_list        => FND_API.G_FALSE
    , p_commit               => FND_API.G_FALSE

    , x_return_status        => l_return_status
    , x_msg_count            => l_count
    , x_msg_data             => l_data

    , p_resource_cost_rec    => l_rsrc_cost_rec
    , p_user_id              => l_user_id
    );
     -- created row count
     l_no_rows_ins := SQL%ROWCOUNT ;
    -- Return in case of insert fails
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    add_header_to_error_stack(p_resource_cost_rec); -- Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_INS');
    FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_no_rows_ins);
    FND_MSG_PUB.Add;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('1 row inserted');
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
        ROLLBACK TO  Create_Alloc_Definition_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Alloc_Definition_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Create_Alloc_Definition_PUB;
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

END Create_Resource_Cost;


--Start of comments
--+========================================================================+
--| API Name    : Update_Resource_Cost                                     |
--| TYPE        : Public                                                   |
--| Function    : Updates Allocation Definition based on the input         |
--|               into GL_ALOC_BAS                                         |
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version       IN  NUMBER       - Required          |
--|               p_init_msg_list     IN  VARCHAR2     - Optional          |
--|               p_commit            IN  VARCHAR2     - Optional          |
--|               p_resource_cost_rec IN Resource_Cost_Rec_Type            |
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

PROCEDURE Update_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                            ,
        x_msg_count             OUT NOCOPY NUMBER                            ,
        x_msg_data              OUT NOCOPY VARCHAR2                            ,

        p_resource_cost_rec     IN Resource_Cost_Rec_Type
)
IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'Update_Resource_Cost' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        l_rsrc_cost_rec         Resource_Cost_Rec_Type ;
        l_no_rows_upd           NUMBER(10) ;
        l_return_status         VARCHAR2(2) ;
        l_user_id               fnd_user.user_id%TYPE ;
        l_count                 NUMBER(10) ;
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

    G_operation := 'UPDATE';    -- Bug 2659435
    G_header_logged := 'N';     -- to avoid logging duplicate header for errors

    -- Validate all the input parameters.
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Validating  input parameters');
    END IF;

    VALIDATE_INPUT_PARAMS
            (p_rsrc_cost_rec       => p_resource_cost_rec
            ,x_rsrc_cost_rec       => l_rsrc_cost_rec
            ,x_user_id             => l_user_id
            ,x_return_status       => l_return_status) ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
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

    -- Check whether any records exists for update
    IF NOT check_records_exist(p_legal_entity_id => l_rsrc_cost_rec.legal_entity_id,
                           p_organization_id => l_rsrc_cost_rec.organization_id,
                           p_resources       => l_rsrc_cost_rec.resources,
                           p_period_id       => l_rsrc_cost_rec.period_id,
                           p_cost_type_id    => l_rsrc_cost_rec.cost_type_id) THEN

          FND_MESSAGE.SET_NAME('GMF','GMF_API_RSRC_NO_REC_FOUND');
          FND_MESSAGE.SET_TOKEN('RESOURCES',l_rsrc_cost_rec.resources);
          FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY_ID',l_rsrc_cost_rec.legal_entity_id);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',l_rsrc_cost_rec.organization_id);
          FND_MESSAGE.SET_TOKEN('PERIOD_ID',l_rsrc_cost_rec.period_id);
          FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',l_rsrc_cost_rec.cost_type_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
   END IF ;

   IF l_rsrc_cost_rec.delete_mark = 1 THEN
        add_header_to_error_stack(p_resource_cost_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_CANT_MARK_FOR_PURGE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Updating record for resource : ' || l_rsrc_cost_rec.resources ||
                ' Legal entity id ' || l_rsrc_cost_rec.legal_entity_id ||
                ' Organization Id ' || l_rsrc_cost_rec.organization_id ||
                ' Period Id '    || l_rsrc_cost_rec.Period_id ||
                ' Cost type Id ' || l_rsrc_cost_rec.cost_type_id);
    END IF;
    -- call to private API to insert to record
    GMF_ResourceCost_PVT.Update_Resource_Cost
    ( p_api_version          => 2.0
    , p_init_msg_list        => FND_API.G_FALSE
    , p_commit               => FND_API.G_FALSE

    , x_return_status        => l_return_status
    , x_msg_count            => l_count
    , x_msg_data             => l_data

    , p_Resource_Cost_rec    => l_rsrc_cost_rec
    , p_user_id              => l_user_id
    );
        l_no_rows_upd := SQL%ROWCOUNT ;

    -- Return in case of insert fails
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    add_header_to_error_stack(p_resource_cost_rec); -- Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_UPD');
    FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_no_rows_upd);
    FND_MSG_PUB.Add;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg( l_no_rows_upd  || ' rows updated.');
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

END Update_Resource_Cost ;


--Start of comments
--+========================================================================+
--| API Name    : Delete_Resource_Cost                                     |
--| TYPE        : Public                                                   |
--| Function    : Deletes Resource Costs based on the input from CM_RSRC_MST|
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version       IN  NUMBER       - Required          |
--|               p_init_msg_list     IN  VARCHAR2     - Optional          |
--|               p_commit            IN  VARCHAR2     - Optional          |
--|               p_resource_cost_rec IN Resource_Cost_Rec_Type            |
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

PROCEDURE Delete_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                            ,
        x_msg_count             OUT NOCOPY NUMBER                            ,
        x_msg_data              OUT NOCOPY VARCHAR2                            ,

        p_resource_cost_rec     IN Resource_Cost_Rec_Type
)
IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'Delete_Resource_Cost' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        l_rsrc_cost_rec         Resource_Cost_Rec_Type ;
        l_no_rows_del           NUMBER(10) ;
        l_return_status         VARCHAR2(2) ;
        l_user_id               fnd_user.user_id%TYPE ;
        l_count                 NUMBER(10) ;
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

    G_operation := 'DELETE';    -- Bug 2659435
    G_header_logged := 'N';     -- to avoid logging duplicate header for errors

    -- Validate all the input parameters.
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Validating  input parameters');
    END IF;

    VALIDATE_INPUT_PARAMS
            (p_rsrc_cost_rec       => p_resource_cost_rec
            ,x_rsrc_cost_rec       => l_rsrc_cost_rec
            ,x_user_id             => l_user_id
            ,x_return_status       => l_return_status) ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
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

   -- Check whether any records exists for update
    IF NOT check_records_exist(p_legal_entity_id => l_rsrc_cost_rec.legal_entity_id,
                           p_organization_id => l_rsrc_cost_rec.organization_id,
                           p_resources       => l_rsrc_cost_rec.resources,
                           p_period_id       => l_rsrc_cost_rec.period_id,
                           p_cost_type_id    => l_rsrc_cost_rec.cost_type_id) THEN

          FND_MESSAGE.SET_NAME('GMF','GMF_API_RSRC_NO_REC_FOUND');
          FND_MESSAGE.SET_TOKEN('RESOURCES',l_rsrc_cost_rec.resources);
          FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY_ID',l_rsrc_cost_rec.legal_entity_id);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',l_rsrc_cost_rec.organization_id);
          FND_MESSAGE.SET_TOKEN('PERIOD_ID',l_rsrc_cost_rec.period_id);
          FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',l_rsrc_cost_rec.cost_type_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
   END IF ;

   -- set delete mark to 1 irrespective of users input.
   l_rsrc_cost_rec.delete_mark := 1 ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Deleting record for resource : ' || l_rsrc_cost_rec.resources ||
                ' Legal entity id ' || l_rsrc_cost_rec.legal_entity_id ||
                ' Organization Id ' || l_rsrc_cost_rec.organization_id ||
                ' Period Id '    || l_rsrc_cost_rec.Period_id ||
                ' Cost type Id ' || l_rsrc_cost_rec.cost_type_id);
    END IF;

    -- call to private API to insert to record
    GMF_ResourceCost_PVT.Update_Resource_Cost
    ( p_api_version          => 2.0
    , p_init_msg_list        => FND_API.G_FALSE
    , p_commit               => FND_API.G_FALSE

    , x_return_status        => l_return_status
    , x_msg_count            => l_count
    , x_msg_data             => l_data

    , p_Resource_Cost_rec    => l_rsrc_cost_rec
    , p_user_id              => l_user_id
    );
      -- deleted records row count
     l_no_rows_del := SQL%ROWCOUNT ;

    -- Return in case of insert fails
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    add_header_to_error_stack(p_resource_cost_rec); -- Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_DEL');
    FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_no_rows_del);
    FND_MSG_PUB.Add;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg(l_no_rows_del || ' row(s) deleted.');
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

END Delete_Resource_Cost ;

--Start of comments
--+========================================================================+
--| API Name    : Get_Resource_Cost                                        |
--| TYPE        : Public                                                   |
--| Function    : Retrive Resource Cost based on the input from table      |
--|               CM_RSRC_DTL                                              |
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version       IN  NUMBER       - Required          |
--|               p_init_msg_list     IN  VARCHAR2     - Optional          |
--|               p_resource_cost_rec IN Resource_Cost_Rec_Type            |
--| OUT         :                                                          |
--|               x_return_status    OUT VARCHAR2                          |
--|               x_msg_count        OUT NUMBER                            |
--|               x_msg_data         OUT VARCHAR2                          |
--|               x_resource_cost_rec OUT Resource_Cost_Rec_Type           |
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

PROCEDURE Get_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                            ,
        x_msg_count             OUT NOCOPY NUMBER                            ,
        x_msg_data              OUT NOCOPY VARCHAR2                            ,

        p_resource_cost_rec     IN  Resource_Cost_Rec_Type              ,
        x_resource_cost_rec     OUT NOCOPY Resource_Cost_Rec_Type
)
IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'Delete_Item_Cost' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        l_return_status         VARCHAR2(2) ;
        l_count                 NUMBER(10) ;
        l_data                  VARCHAR2(2000) ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Get_Resource_Cost_PUB;

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

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Beginning Get Resource Cost process.');
    END IF;

    G_header_logged := 'N';     -- to avoid logging duplicate header for errors

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Calling private API to fetch records...');
    END IF;

    GMF_ResourceCost_PVT.Get_Resource_Cost
     (
        p_api_version         => 2.0
      , p_init_msg_list       => FND_API.G_FALSE

      , x_return_status       => l_return_status
      , x_msg_count           => l_count
      , x_msg_data            => l_data

      , p_resource_cost_rec   => p_resource_cost_rec

      , x_resource_cost_rec   => x_resource_cost_rec
     );

     -- Return if update fails for any reason
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

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
        ROLLBACK TO  Get_Resource_Cost_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Get_Resource_Cost_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Get_Resource_Cost_PUB;
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

END Get_Resource_Cost;

-- Proc start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Input_Params                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       Validates all the input parameters.                                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_resource_cost_rec IN  Resource_Cost_Rec_Type                     |
--|       x_return_status     OUT VARCHAR2                                   |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If succesfully initialized all variables                   |
--|       FALSE - If any error                                               |
--|                                                                          |
--|  HISTORY                                                                 |
--|    27/02/2001 Uday Moogla - Created                                      |
--|                                                                          |
--|    03/Dec/2002  Uday Moogala  Bug# 2692459                               |
--|      Modified code to verify for same usage um type as rsrc um type.     |
--|                                                                          |
--|    13/May/2004 Dinesh Vadivel Bug# 3628252                               |
--|      Removed validation for nominal cost so that it takes negative       |
--|      entries                                                             |
--|    22/Nov/2005 Prasad Marada Bug 4689137,Modified input parameter        |
--|                              validation as per datamodel changes         |
--+==========================================================================+
-- Proc end of comments

PROCEDURE Validate_Input_Params
(
        p_rsrc_cost_rec    IN  Resource_Cost_Rec_Type
        ,x_rsrc_cost_rec   OUT NOCOPY Resource_Cost_Rec_Type
        ,x_user_id         OUT NOCOPY NUMBER
        ,x_return_status   OUT NOCOPY VARCHAR2
)
IS

        l_resources         cm_rsrc_dtl.resources%TYPE      ;
        l_legal_entity_id   cm_rsrc_dtl.legal_entity_id%TYPE;
        l_organization_id   cm_rsrc_dtl.organization_id%TYPE;
        l_organization_code mtl_parameters.organization_code%TYPE;
        l_period_id         cm_rsrc_dtl.period_id%TYPE;
        l_calendar_code     cm_rsrc_dtl.calendar_code%TYPE  ;
        l_period_code       cm_rsrc_dtl.period_code%TYPE    ;
--        l_period_status     cm_cldr_dtl.period_status%TYPE  ;
        l_cost_type_id      cm_rsrc_dtl.cost_type_id%TYPE;
        l_cost_type_code    cm_rsrc_dtl.cost_mthd_code%TYPE ;
        l_usage_uom         cm_rsrc_dtl.usage_uom%TYPE       ;
        l_nominal_cost      NUMBER                          ;
        l_delete_mark       NUMBER                        ;
        l_user_name         fnd_user.user_name%TYPE       ;
        l_user_id           NUMBER                        ;

        -- Bug 2692459
        l_usage_uom_class      mtl_units_of_measure.uom_class%TYPE ;
        l_resource_uom_class  mtl_units_of_measure.uom_class%TYPE ;
        l_resource_uom      cr_rsrc_mst.std_usage_uom%TYPE ;


BEGIN

    l_resources         := p_rsrc_cost_rec.resources ;
    l_legal_entity_id   := p_rsrc_cost_rec.legal_entity_id ;
    l_organization_id   := p_rsrc_cost_rec.organization_id;
    l_organization_code := p_rsrc_cost_rec.organization_code;
    l_period_id         := p_rsrc_cost_rec.period_id ;
    l_calendar_code     := p_rsrc_cost_rec.calendar_code ;
    l_period_code       := p_rsrc_cost_rec.period_code ;
    l_cost_type_id      := p_rsrc_cost_rec.cost_type_id ;
    l_cost_type_code    := p_rsrc_cost_rec.cost_mthd_code ;

    l_usage_uom         := p_rsrc_cost_rec.usage_uom ;
    l_nominal_cost      := p_rsrc_cost_rec.nominal_cost ;
    l_delete_mark       := p_rsrc_cost_rec.delete_mark ;
    l_user_name         := p_rsrc_cost_rec.user_name ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg( 'resources : ' || l_resources);
        log_msg( 'legal_entity_id : ' || l_legal_entity_id);
        log_msg( 'organization_id : ' || l_organization_id);
        log_msg( 'period_id : ' || l_period_id);
        log_msg( 'cost_type_id : ' || l_cost_type_id);
        log_msg( 'usage_uom : ' || l_usage_uom);
        log_msg( 'nominal_cost : ' || l_nominal_cost);
        log_msg( 'delete_mark : ' || l_delete_mark);
        log_msg( 'user_name : ' || l_user_name);
    END IF;

    -------------
    -- Resources
    -------------
    IF (l_resources <> FND_API.G_MISS_CHAR) AND
       (l_resources IS NOT NULL)  THEN
        -- validate alloc_id
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
                log_msg('validating resources : '|| l_resources);
        END IF;

        --
        -- Bug 2692459
        -- get uom type also.
        --
       IF NOT (GMF_VALIDATIONS_PVT.Validate_Resources(l_resources)) THEN
          add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_RESOURCES');
          FND_MESSAGE.SET_TOKEN('RESOURCES',l_resources);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
        -- Get the resource UOM code, resource UOM class for further processing
        GMF_VALIDATIONS_PVT.Validate_Resource(l_resources,l_resource_uom,l_resource_uom_class);
        IF l_resource_uom IS NULL AND l_resource_uom_class IS NULL THEN
           add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
           FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_RESOURCES');
           FND_MESSAGE.SET_TOKEN('RESOURCES',l_resources);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
     ELSE
        add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_RESOURCES_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Resource

    --------------------------
    -- Legal entity
    --------------------------
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('validating legal_entity_id : ' || l_legal_entity_id);
    END IF;

    IF (l_legal_entity_id <> FND_API.G_MISS_NUM) AND
       (l_legal_entity_id IS NOT NULL)  THEN
        IF NOT GMF_VALIDATIONS_PVT.Validate_legal_entity_id(l_legal_entity_id)  THEN
          add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_LE_ID');
          FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY',l_legal_entity_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
          add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_LE_ID_REQ');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- End legal entity

    --------------------------
    -- Organization validation
    --------------------------
    -- validate organization id
    IF ((l_organization_id <> FND_API.G_MISS_NUM) AND (l_organization_id IS NOT NULL)) THEN
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_debug_level THEN
          log_msg('Validation Organization ID : '||l_organization_id);
       END IF;
       -- invoke validate organization id method
       IF NOT gmf_validations_pvt.Validate_organization_id(l_organization_id) THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_ID');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', l_organization_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
        -- if organization code also passed then log a message to ignore organization code
       IF ( l_organization_code <> FND_API.G_MISS_CHAR) AND (l_organization_code IS NOT NULL) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
             FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ORGN_CODE');
             FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE', l_organization_code);
             FND_MSG_PUB.Add;
          END IF;
       END IF;
       -- Organization code passed
    ELSIF (l_organization_code <> FND_API.G_MISS_CHAR ) AND (l_organization_code IS NOT NULL ) THEN
        IF (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level) THEN
          log_msg('Validating Organization Code : ' ||l_organization_code);
        END IF;
            -- get the organization id
         l_organization_id := gmf_validations_pvt.validate_organization_code(l_organization_code);
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg('Organization id : ' || l_organization_id);
        END IF;
          -- if organization id is null then log message
        IF l_organization_id IS NULL THEN
           FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_CODE');
           FND_MESSAGE.SET_TOKEN('ORG_CODE', l_organization_code);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Either organization id or organization code required
    ELSE
        FND_MESSAGE.SET_NAME('GMF','GMF_API_ORGANIZATION_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End of Organization validation

    ----------------------------
    --  * Cost Type Validation *
    ----------------------------
    IF	(l_cost_type_id  <> FND_API.G_MISS_NUM) AND (l_cost_type_id IS NOT NULL)  THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
	  log_msg('Validating Cost Type Id : ' || l_cost_type_id);
        END IF;
        -- Invoke cost type id validation method
        IF NOT gmf_validations_pvt.validate_cost_type_id (l_cost_type_id) THEN
           FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE_ID');
           FND_MESSAGE.SET_TOKEN('COST_TYPE_ID', l_cost_type_id);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- if cost method code is not then log a message
        IF (l_cost_type_code <> FND_API.G_MISS_CHAR) AND (l_cost_type_code IS NOT NULL) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)   THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_COST_TYPE');
              FND_MESSAGE.SET_TOKEN('COST_TYPE', l_cost_type_code);
              FND_MSG_PUB.Add;
            END IF;
         END IF;
    ELSIF (l_cost_type_code <> FND_API.G_MISS_CHAR) AND (l_cost_type_code IS NOT NULL)  THEN

        -- Get the cost type id from the method
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
          log_msg('Validating Cost Type Code : ' || l_cost_type_code);
        END IF;

          l_cost_type_id := GMF_VALIDATIONS_PVT.Validate_cost_type_code(l_cost_type_code);
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            log_msg('Cost Type Id : ' || l_cost_type_id);
        END IF;
        IF l_cost_type_id IS NULL  THEN
           FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE');
           FND_MESSAGE.SET_TOKEN('COST_TYPE',l_cost_type_code);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        FND_MESSAGE.SET_NAME('GMF','GMF_API_COST_TYPE_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Cost Method
    --

    --------------------------
    --   * Period Validation *
    --------------------------
     IF (l_period_id  <> FND_API.G_MISS_NUM) AND (l_period_id IS NOT NULL) THEN
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
            log_msg('Validating Period Id : ' || l_period_id);
         END IF;
          -- Invoke validate period id method
         IF NOT gmf_validations_pvt.validate_period_id(l_period_id) THEN
                 FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_PERIOD_ID');
                 FND_MESSAGE.SET_TOKEN('PERIOD_ID', l_period_id);
                 FND_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
         END IF;
           -- If period code also passed then ignore period code
         IF ((l_calendar_code <> FND_API.G_MISS_CHAR) AND (l_calendar_code IS NOT NULL))
            AND ((l_period_code <> FND_API.G_MISS_CHAR) AND (l_period_code IS NOT NULL)) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_PERIOD_CODE');
              FND_MESSAGE.SET_TOKEN('CALENDAR_CODE', l_calendar_code);
              FND_MESSAGE.SET_TOKEN('PERIOD_CODE', l_period_code);
              FND_MSG_PUB.Add;
            END IF;
         END IF;
    ELSIF (l_calendar_code <> FND_API.G_MISS_CHAR) AND (l_calendar_code IS NOT NULL)
        AND ((l_period_code <> FND_API.G_MISS_CHAR) AND (l_period_code IS NOT NULL)) THEN

           -- Get the period id passing period code to the validate period id method
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            log_msg('Validating Calendar Code : ' || l_calendar_code||', Period Code : '||l_period_code);
          END IF;

            l_period_id := GMF_VALIDATIONS_PVT.Validate_period_code(l_organization_id, l_calendar_code, l_period_code, l_cost_type_id);
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            log_msg('Period Id : ' || l_period_id);
          END IF;
          -- if period id null then log message with invalid period code
          IF l_period_id IS NULL  THEN
            FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CLDR_PERIOD');
            FND_MESSAGE.SET_TOKEN('CALENDAR_CODE',l_calendar_code);
            FND_MESSAGE.SET_TOKEN('PERIOD_CODE',l_period_code);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
    ELSE
        FND_MESSAGE.SET_NAME('GMF','GMF_API_PERIOD_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- End Period Validation


    -- Enough of validations for delete.
    -- For update and insert we should do all validations.
    --

    IF (G_operation <> 'DELETE') THEN

        --
        -- Usage Unit of Measure
        --
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
            log_msg('validating usage_uom : ' || l_usage_uom);
        END IF;

        IF (l_usage_uom <> FND_API.G_MISS_CHAR) AND
           (l_usage_uom IS NOT NULL)  THEN

            --
            -- Bug 2692459
            -- get usage uom class also and verify whether it is same uom class as resource uom
            --
            -- get the Usgae UOM class
            GMF_VALIDATIONS_PVT.Validate_Usage_Uom(l_usage_uom, l_usage_uom_class) ;
            IF l_usage_uom_class IS NULL THEN
              add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USAGE_UM');
              FND_MESSAGE.SET_TOKEN('USAGE_UM',l_usage_uom);
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
               log_msg('Usage UOM Class : ' || l_usage_uom_class ||
                       ' resource UOM Class : ' || l_resource_uom_class);
            END IF;

            -- Usage UOM must be of the same type as the resource UOM
            IF (l_resource_uom_class <> l_usage_uom_class) THEN
               add_header_to_error_stack(p_rsrc_cost_rec);
               FND_MESSAGE.SET_NAME('GMF','GMF_API_USAGE_UOM_SAMETYPE_REQ');
               FND_MESSAGE.SET_TOKEN('USAGE_UM',l_usage_uom);
               FND_MESSAGE.SET_TOKEN('RESOURCE_UM',l_resource_uom);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
            -- End of bug 2692459

        ELSIF (l_usage_uom = FND_API.G_MISS_CHAR AND
               G_operation = 'UPDATE') OR
              (G_operation = 'INSERT') THEN
              add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_USAGE_UM_REQ');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- End Usage Unit of Measure

        --
        -- Nominal Cost
        -- Nominal Cost should be > 0
        -- In the form the format mask for this is : 999999999D999999999(999,999,999.999999999)
        -- To put that check here, the cost should not be >= 1,000,000,000
        --
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
            log_msg('Validating Nominal Cost : '||l_nominal_cost);
        END IF;

        /*************************************************************************
         * dvadivel 13-May-2004 Bug # 3628252 Removed validation for Nominal cost
         *************************************************************************/
        /* IF (l_nominal_cost <> FND_API.G_MISS_NUM) AND
           (l_nominal_cost IS NOT NULL)  THEN
              IF ((nvl(l_nominal_cost,0) <= 0) OR (nvl(l_nominal_cost,0) >= 1000000000)) THEN
                add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_NOMINAL_COST');
                FND_MESSAGE.SET_TOKEN('NOMINAL_COST',l_nominal_cost);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
           ELSIF (l_nominal_cost = FND_API.G_MISS_NUM AND
        */
           IF ((l_nominal_cost = FND_API.G_MISS_NUM) OR (l_nominal_cost IS NULL)) AND
              ((G_operation = 'UPDATE') OR
               (G_operation = 'INSERT')) THEN
              add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_NOMINAL_COST_REQ');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
        -- End Nominal Cost

        --
        -- Delete Mark
        --
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
          log_msg('Validating delete_mark : ' || l_delete_mark);
        END IF;

        IF (l_delete_mark <> FND_API.G_MISS_NUM) AND
           (l_delete_mark IS NOT NULL)  THEN
          IF l_delete_mark NOT IN (0,1) THEN
            add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
            FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_DELETE_MARK');
            FND_MESSAGE.SET_TOKEN('DELETE_MARK',l_delete_mark);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSIF (l_delete_mark = FND_API.G_MISS_NUM AND
               G_operation = 'UPDATE') OR
              (G_operation = 'INSERT') THEN
              add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_DELETE_MARK_REQ');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Bug 2692459
        IF ((G_operation = 'UPDATE') AND (l_delete_mark = 1)) THEN
          add_header_to_error_stack(p_rsrc_cost_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_CANT_MARK_FOR_PURGE');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- End Delete Mark

    END IF;  -- Bug 2692459:  G_operation <> 'DELETE'

    -- Populate WHO columns
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Validating user name : ' || l_user_name);
    END IF;

    IF (l_user_name <> FND_API.G_MISS_CHAR) AND
       (l_user_name IS NOT NULL)  THEN
            GMA_GLOBAL_GRP.Get_who( p_user_name  => l_user_name
                                  , x_user_id    => l_user_id
                                  );

            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
                log_msg('user id : ' || l_user_id);
            END IF;

            IF l_user_id = -1 THEN      -- Bug 2681243: GMA changed return status value to -1.
                add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USER_NAME');
                FND_MESSAGE.SET_TOKEN('USER_NAME',l_user_name);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

    ELSE
        add_header_to_error_stack(p_rsrc_cost_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_USER_NAME_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End User Name


    x_rsrc_cost_rec.resources        :=  l_resources ;
    x_rsrc_cost_rec.legal_entity_id  :=  l_legal_entity_id ;
    x_rsrc_cost_rec.organization_id  :=  l_organization_id ;
    x_rsrc_cost_rec.organization_code:=  l_organization_code ;
    x_rsrc_cost_rec.period_id        :=  l_period_id;
    x_rsrc_cost_rec.calendar_code    :=  l_calendar_code ;
    x_rsrc_cost_rec.period_code      :=  l_period_code ;
    x_rsrc_cost_rec.cost_type_id     :=  l_cost_type_id ;
    x_rsrc_cost_rec.cost_mthd_code   :=  l_cost_type_code ;
    x_rsrc_cost_rec.usage_uom        :=  l_usage_uom ;
    x_rsrc_cost_rec.nominal_cost     :=  round(l_nominal_cost,9) ;
    x_rsrc_cost_rec.delete_mark      :=  l_delete_mark ;
    x_rsrc_cost_rec.user_name        :=  l_user_name ;
    x_user_id                        :=  l_user_id ;

EXCEPTION       -- Bug 2681243: removed when others to capture ORA errors.
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Validate_Input_Params;

-- Func start of comments
--+==========================================================================+
--|  Function Name                                                           |
--|       check_records_exist                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This procedure checks for the existance of records for a given     |
--|       resource, orgn, calendar, period and cost method.                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       In case of insert API, if record exists raise error.               |
--|       In case of update/delete API, if record does not exists raise error|
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_resources      IN VARCHAR2 - Actual Message Text                 |
--|       p_orgn_code      IN VARCHAR2 - Actual Message Text                 |
--|       p_calendar_code  IN VARCHAR2 - Actual Message Text                 |
--|       p_period_code    IN VARCHAR2 - Actual Message Text                 |
--|       p_cost_mthd_code IN VARCHAR2 - Actual Message Text                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE : If records exist                                            |
--|       TRUE : If records does not exist                                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|   27/02/2001 Uday Moogla - Created                                       |
--|   2-sep-2005 pmarada - Modified the cursor and where clause              |
--|  07-mar-2007 pmarada - Bug 5586122 Modified the cursor parameters,       |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION check_records_exist
(
  p_legal_entity_id IN cm_rsrc_dtl.legal_entity_id%TYPE,
  p_organization_id IN cm_rsrc_dtl.organization_id%TYPE,
  p_resources       IN cm_rsrc_dtl.resources%TYPE,
  p_period_id       IN cm_rsrc_dtl.period_id%TYPE,
  p_cost_type_id    IN cm_rsrc_dtl.cost_type_id%TYPE
)
RETURN BOOLEAN
IS
    CURSOR Cur_rsrc_dtl
           ( cp_legal_entity_id  cm_rsrc_dtl.legal_entity_id%TYPE,
             cp_organization_id  cm_rsrc_dtl.organization_id%TYPE ,
             cp_resources        cm_rsrc_dtl.resources%TYPE ,
             cp_period_id        cm_rsrc_dtl.period_id%TYPE,
             cp_cost_type_id     cm_rsrc_dtl.cost_type_id%TYPE
           ) IS
    SELECT 'x'
      FROM cm_rsrc_dtl
     WHERE legal_entity_id = cp_legal_entity_id
       AND organization_id = cp_organization_id
       AND resources       = cp_resources
       AND period_id       = cp_period_id
       AND cost_type_id    = cp_cost_type_id;

      l_rec_found VARCHAR2(10);
BEGIN

     l_rec_found := NULL;
    OPEN Cur_rsrc_dtl(p_legal_entity_id, p_organization_id, p_resources, p_period_id, p_cost_type_id) ;
    FETCH cur_rsrc_dtl INTO l_rec_found;

    IF (l_rec_found IS NOT NULL) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE ;
    END IF;
    CLOSE Cur_rsrc_dtl ;

END check_records_exist ;

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

  -- IF FND_MSG_PUB.Check_Msg_Level (p_msg_lvl) THEN    Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_DEBUG');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
  -- END IF;    Bug 2659435

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
--| 05/11/2001  Uday Moogla - Created Bug 2659435                            |
--| 20-sep-2005 Pmarada  - modified the message and tokens                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE add_header_to_error_stack
(
 p_header       Resource_Cost_Rec_Type
)
IS
BEGIN

  IF G_header_logged = 'N' THEN
    G_header_logged := 'Y';
    FND_MESSAGE.SET_NAME('GMF','GMF_API_RESOURCE_COST_HEADER');
    FND_MESSAGE.SET_TOKEN('RESOURCES',p_header.resources);
    FND_MESSAGE.SET_TOKEN('LEGAL_ENTITY_ID',p_header.legal_entity_id);
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header.organization_id);
    FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header.period_id);
    FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header.cost_type_id);
    FND_MSG_PUB.Add;
  END IF;

END add_header_to_error_stack;

END GMF_ResourceCost_PUB;

/
