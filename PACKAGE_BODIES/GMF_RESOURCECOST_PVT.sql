--------------------------------------------------------
--  DDL for Package Body GMF_RESOURCECOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_RESOURCECOST_PVT" AS
/* $Header: GMFVRESB.pls 120.1 2005/11/08 05:29:24 pmarada noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFVRESB.pls                                        |
--| Package Name       : GMF_ResourceCost_PVT                                |
--| API name           : GMF_ResourceCost_PVT                                |
--| Type               : Private                                             |
--| Pre-reqs           : N/A                                                 |
--| Function           : Resource Cost creation, updatation and              |
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
--|     This package contains private procedures relating to Resource Cost   |
--|     creation, updatation and deletetion.                                 |
--|                                                                          |
--| HISTORY                                                                  |
--|    27/Feb/2001  Uday Moogala  Created  Bug# 1418689                      |
--|                                                                          |
--|    30-OCT-2002  RajaSekhar    Bug#2641405 Added NOCOPY hint              |
--|    05/NOV/2002  Uday Moogala  Bug# 2659435                               |
--|      Performance related fixes.                                          |
--|      1. remove G_MISS_xxx assignments.                                   |
--|      2. Conditionally calling debug routine.                             |
--|      Also, fixed issues found during unit testing. Search for the bug    |
--|      number to find the fixes.                                           |
--|    22/Nov/2005  Prasad Marada Bug 4689137, API changes for convergence   |
--+==========================================================================+
-- End of comments

--


PROCEDURE log_msg       -- Bug 2659435: Removed first paramter for debug level
(
p_msg_text      IN VARCHAR2
);
--

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMF_ResourceCost_PVT';

G_debug_level   NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
                                                                 -- to decide to log a debug msg.


--Start of comments
--+========================================================================+
--| API Name    : Create_Resource_Cost                                     |
--| TYPE        : Private                                                  |
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
--| 01-Oct-05    Prasad marada - Modified as per inventory convergence     |
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

        p_resource_cost_rec     IN  GMF_ResourceCost_PUB.Resource_Cost_Rec_Type         ,
        p_user_id               IN  NUMBER
)
IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'Create_Resource_Cost' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        --l_rsrc_cost_rec         Resource_Cost_Rec_Type ;
        --l_return_status               VARCHAR2(2) ;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Create_Resource_Cost_PVT;

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
       log_msg('Inserting record for resource : ' || p_resource_cost_rec.resources ||
                ' Legal Entity Id : '   || p_resource_cost_rec.legal_entity_id ||
                ' Organization id : '  || p_resource_cost_rec.organization_id ||
                ' Period Id : ' || p_resource_cost_rec.period_id ||
                ' Cost type id : '|| p_resource_cost_rec.cost_type_id);
    END IF;

    INSERT INTO cm_rsrc_dtl
    (
      resources
    , nominal_cost
    , text_code
    , delete_mark
    , rollover_ind
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , trans_cnt
    , last_update_login
    , organization_id
    , cost_type_id
    , period_id
    , usage_uom
    , legal_entity_id
    )
    VALUES
    (
      p_resource_cost_rec.resources
    , p_resource_cost_rec.nominal_cost
    , ''                -- text code
    , 0                 -- delete mark
    , 0                 -- rollover Indicator
    , sysdate
    , p_user_id
    , sysdate
    , p_user_id
    , ''        -- transaction count (not in use)
    , FND_GLOBAL.LOGIN_ID
    , p_resource_cost_rec.organization_id
    , p_resource_cost_rec.cost_type_id
    , p_resource_cost_rec.period_id
    , p_resource_cost_rec.usage_uom
    , p_resource_cost_rec.legal_entity_id
    );

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
        ROLLBACK TO  Create_Resource_Cost_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Resource_Cost_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Create_Resource_Cost_PVT;
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
--| TYPE        : Private                                                  |
--| Function    : Updates Resource Cost based on the input                 |
--|               into CM_RSRC_DTL                                         |
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

        p_resource_cost_rec     IN  GMF_ResourceCost_PUB.Resource_Cost_Rec_Type         ,
        p_user_id               IN  NUMBER
)
IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'Update_Resource_Cost' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        --l_rsrc_cost_rec         Resource_Cost_Rec_Type ;
        --l_no_rows_upd           NUMBER(10) ;
        --l_return_status         VARCHAR2(2) ;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Update_Resource_Cost_PVT;

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
       log_msg('Updating record for resource : ' ||  p_resource_cost_rec.resources ||
               ' Legal Entity Id : '   || p_resource_cost_rec.legal_entity_id ||
               ' Organization id : ' || p_resource_cost_rec.organization_id ||
               ' Period Id : '   || p_resource_cost_rec.period_id ||
               ' Cost type id : '|| p_resource_cost_rec.cost_type_id);
    END IF;

    UPDATE cm_rsrc_dtl
    SET
         -- Modified uage_um to usage_uom by pmarada
         usage_uom          = decode(p_resource_cost_rec.usage_uom,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL, usage_uom,
                                     p_resource_cost_rec.usage_uom)
        ,nominal_cost       = decode(p_resource_cost_rec.nominal_cost,
                                     FND_API.G_MISS_NUM, NULL,
                                     NULL, nominal_cost,
                                     p_resource_cost_rec.nominal_cost)
        ,delete_mark        = decode(p_resource_cost_rec.delete_mark,
                                     FND_API.G_MISS_NUM, NULL,
                                     NULL, delete_mark,
                                     p_resource_cost_rec.delete_mark)
        ,last_update_date   = sysdate
        ,last_updated_by    = p_user_id
        ,last_update_login  = FND_GLOBAL.LOGIN_ID
    WHERE
        legal_entity_id = p_resource_cost_rec.legal_entity_id
    AND organization_id = p_resource_cost_rec.organization_id
    AND resources       = p_resource_cost_rec.resources
    AND period_id       = p_resource_cost_rec.period_id
    AND cost_type_id    = p_resource_cost_rec.cost_type_id
    ;

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
        ROLLBACK TO  Update_Resource_Cost_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Update_Resource_Cost_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Update_Resource_Cost_PVT;
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
--| API Name    : Get_Resource_Cost                                        |
--| TYPE        : Private                                                  |
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
--| 20-sep-2005   Prasad marada - included organization_id, cost_type_id,  |
--|                               period_id etc..
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Get_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                            ,
        x_msg_count             OUT NOCOPY NUMBER                            ,
        x_msg_data              OUT NOCOPY VARCHAR2                            ,

        p_resource_cost_rec     IN  GMF_ResourceCost_PUB.Resource_Cost_Rec_Type              ,
        x_resource_cost_rec     OUT NOCOPY GMF_ResourceCost_PUB.Resource_Cost_Rec_Type
)
IS
 l_api_name              CONSTANT VARCHAR2(30)   := 'Delete_Item_Cost' ;
 l_api_version           CONSTANT NUMBER         := 2.0 ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Get_Reousrce_Cost_PVT;

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
        log_msg('Beginning Private Get Resource Cost API.');
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
       log_msg('Retrieving Resource Costs for legal entity id : ' || p_resource_cost_rec.legal_entity_id ||
               ' Organization Id : ' || p_resource_cost_rec.organization_id ||
               ' Resource : '     || p_resource_cost_rec.resources ||
               ' Period Id : '    || p_resource_cost_rec.Period_id ||
               ' Cost type Id : ' || p_resource_cost_rec.cost_type_id ) ;
    END IF;

    x_resource_cost_rec.resources         := p_resource_cost_rec.resources ;
    x_resource_cost_rec.legal_entity_id   := p_resource_cost_rec.legal_entity_id ;
    x_resource_cost_rec.organization_id   := p_resource_cost_rec.organization_id ;
    x_resource_cost_rec.organization_code := p_resource_cost_rec.organization_code ;
    x_resource_cost_rec.period_id         := p_resource_cost_rec.period_id ;
    x_resource_cost_rec.calendar_code     := p_resource_cost_rec.calendar_code ;
    x_resource_cost_rec.Period_code       := p_resource_cost_rec.Period_code ;
    x_resource_cost_rec.cost_type_id      := p_resource_cost_rec.cost_type_id ;
    x_resource_cost_rec.cost_mthd_code    := p_resource_cost_rec.cost_mthd_code ;

    SELECT
            r.usage_uom
          , r.nominal_cost
          , r.delete_mark
          , f.user_name
    INTO
            x_resource_cost_rec.usage_uom
          , x_resource_cost_rec.nominal_cost
          , x_resource_cost_rec.delete_mark
          , x_resource_cost_rec.user_name
    FROM
          fnd_user f, cm_rsrc_dtl r
    WHERE
       legal_entity_id  = p_resource_cost_rec.legal_entity_id
    AND organization_id = p_resource_cost_rec.organization_id
    AND resources       = p_resource_cost_rec.resources
    AND period_id       = p_resource_cost_rec.period_id
    AND cost_type_id    = p_resource_cost_rec.cost_type_id
    AND f.user_id       = r.last_updated_by
    ;


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
        ROLLBACK TO  Get_Reousrce_Cost_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Get_Reousrce_Cost_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Get_Reousrce_Cost_PVT;
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

  -- IF FND_MSG_PUB.Check_Msg_Level (p_msg_lvl) THEN    -- Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_DEBUG');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
  -- END IF;

END log_msg ;

END GMF_ResourceCost_PVT;

/
