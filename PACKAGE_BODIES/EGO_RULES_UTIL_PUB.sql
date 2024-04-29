--------------------------------------------------------
--  DDL for Package Body EGO_RULES_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_RULES_UTIL_PUB" AS
/* $Header: EGORUTLB.pls 120.0.12010000.2 2009/08/14 02:34:34 chulhale noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):='EGO_RULES_UTIL_PUB';

-- Start of comments
-- API name   : Get_Run_Rule_Result
-- Type       : Public
-- Pre-reqs   : None.
-- Function   : Customized Get_Run_Rule_Result procudure based on information
--              related to user, entity, and object etc.
-- Parameters :
--     IN     : p_rule_id IN VARCHAR2(150)
--              p_entity_type_name IN VARCHAR2(150)
--              p_data_level_name IN VARCHAR2(150)
--              p_entity_key_pairs IN EGO_COL_NAME_VALUE_PAIR_ARRAY
--              p_additional_key_pairs IN EGO_COL_NAME_VALUE_PAIR_ARRAY
--     OUT    : x_rule_result  OUT VARCHAR2   = 'T' if Rule_Result is TRUE
--                                              'F' if Rule_Result is FALSE
--                                              'U' Defalut and if there are unexpected errors
-- Oracle API Standard Parameters :
--     IN     : p_api_version        IN NUMBER Required
--              p_init_msg_list      IN VARCHAR2 default FND_API.G_FALSE
--                                   Optional
--              p_commit             IN VARCHAR2 default FND_API.G_FALSE
--                                   Optional
--              p_validation_level   IN NUMBER   default FND_API.G_VALID_LEVEL_FULL
--                                   Optional
--     OUT    : x_return_status         OUT     VARCHAR2(1)
--              x_msg_count             OUT     NUMBER
--              x_msg_data              OUT     VARCHAR2(2000)
--
-- Version    : Current version       1.0
--              Previous version      N/A
--              Initial version       1.0
--
-- End of comments

PROCEDURE Get_Run_Rule_Result
(
    --program parameters
     p_rule_id              IN VARCHAR2
    ,p_entity_type_name     IN VARCHAR2
    ,p_data_level_name      IN VARCHAR2
    ,p_entity_key_pairs IN  EGO_COL_NAME_VALUE_PAIR_ARRAY default NULL
    ,p_additional_key_pairs IN  EGO_COL_NAME_VALUE_PAIR_ARRAY default NULL
    ,x_rule_result  OUT NOCOPY VARCHAR2

    --standard parameters
    ,p_api_version        IN NUMBER   default 1.0
    ,p_init_msg_list      IN VARCHAR2 default FND_API.G_FALSE
    ,p_commit             IN VARCHAR2 default FND_API.G_FALSE
    ,p_validation_level   IN NUMBER   default FND_API.G_VALID_LEVEL_FULL
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
)
IS
l_api_name    CONSTANT    VARCHAR2(30) := 'Get_Run_Rule_Result';
l_api_version CONSTANT    NUMBER := 1.0;
l_stmt_num                 NUMBER;  --for debuging index

l_index		NUMBER;

l_batch_id	VARCHAR2(150);
l_item_id	VARCHAR2(150);
l_org_id	VARCHAR2(150);
l_rev_id	VARCHAR2(150);

l_item_supp_id VARCHAR2(150);
l_item_supp_site_id VARCHAR2(150);

BEGIN
    -- Leave starting point of this procedure at fnd_log_message
    l_stmt_num := 0;
    IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                   ,G_PKG_NAME||'.'||l_api_name
                   ,'Enter '||G_PKG_NAME||'.'||l_api_name||' '
                   ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss') );
    END IF; --for fnd_log

    -- Standard call to check for call compatibility.
    l_stmt_num := 3;
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                         ,p_api_version
                                         ,l_api_name
                                         ,G_PKG_NAME	)
    THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    l_stmt_num := 5;
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
		   FND_MSG_PUB.initialize;
    END IF;

    --  Initialize OUT parameters
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_rule_result := 'U';

    -- Example of getting entity_keys from p_entity_key_pairs
    l_index := p_entity_key_pairs.FIRST;
    WHILE (l_index IS NOT NULL)
    LOOP
        IF ((p_entity_key_pairs(l_index).NAME IS NOT NULL)
           AND (p_entity_key_pairs(l_index).NAME = 'BATCH_ID')) THEN
           l_batch_id := p_entity_key_pairs(l_index).VALUE;
        ELSIF ((p_entity_key_pairs(l_index).NAME IS NOT NULL)
           AND (p_entity_key_pairs(l_index).NAME = 'ITEM_ID')) THEN
           l_item_id := p_entity_key_pairs(l_index).VALUE;
        ELSIF ((p_entity_key_pairs(l_index).NAME IS NOT NULL)
           AND (p_entity_key_pairs(l_index).NAME = 'ORG_ID')) THEN
           l_org_id := p_entity_key_pairs(l_index).VALUE;
        ELSIF ((p_entity_key_pairs(l_index).NAME IS NOT NULL)
           AND (p_entity_key_pairs(l_index).NAME = 'REV_ID')) THEN
           l_rev_id := p_entity_key_pairs(l_index).VALUE;
        END IF;
        l_index := p_entity_key_pairs.NEXT(l_index);
    END LOOP;

    -- Example of getting additional_keys from p_additional_key_pairs
    -- p_entity_type_anme 'ITEM', 'ITEM_SUPPLIER', 'ITEM_RETAILERSITE', 'ITEM_SUPPLIERSITE', 'ITEM_SUPPLIERSITE_RETAILERSITE' etc.
    -- p_data_level_name 'ITEM', 'ITEM_ORG', 'ITEM_SUP', 'ITEM_SUP_SITE', 'ITEM_SUP_SITE_ORG' etc.
    IF ((p_data_level_name = 'ITEM_SUP')
      OR (p_data_level_name = 'ITEM_SUP_SITE')
      OR (p_data_level_name = 'ITEM_SUP_SITE_ORG')) THEN
        l_index := p_additional_key_pairs.FIRST;
        WHILE (l_index IS NOT NULL)
        LOOP
            IF ((p_additional_key_pairs(l_index).NAME IS NOT NULL)
               AND (p_additional_key_pairs(l_index).NAME = 'PK1_VALUE')) THEN
               l_item_supp_id := p_additional_key_pairs(l_index).VALUE;
            ELSIF ((p_additional_key_pairs(l_index).NAME IS NOT NULL)
               AND (p_additional_key_pairs(l_index).NAME = 'PK2_VALUE')) THEN
               l_item_supp_site_id := p_additional_key_pairs(l_index).VALUE;
            END IF;
            l_index := p_additional_key_pairs.NEXT(l_index);
        END LOOP;
    END IF;

  -- Example of leaving log messages
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string(FND_LOG.LEVEL_STATEMENT
                  ,G_PKG_NAME||'.'||l_api_name
		  ,' p_rule_id=>'|| p_rule_id ||','
                 ||' p_data_level_name=>'|| p_data_level_name ||','
                 ||' p_entity_type_name=>'|| p_entity_type_name ||','
                 ||' l_batch_id=>'|| l_batch_id ||','
                 ||' l_item_id=>'|| l_item_id ||','
                 ||' l_org_id=>'|| l_org_id ||','
                 ||' l_rev_id=>'|| l_rev_id ||','
                 ||' l_item_supp_id=>'|| l_item_supp_id ||','
                 ||' l_item_sup_site_id=>'|| l_item_supp_site_id );
    END IF; --fnd_log













    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
		    COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count
                               ,p_data  => x_msg_data);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                   ,G_PKG_NAME||'.'||l_api_name
                   ,'Exit '||G_PKG_NAME||'.'||l_api_name||' '
                   ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));
    END IF; --for fnd_log


    EXCEPTION
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count
                                      ,p_data  => x_msg_data);
           IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                    fnd_log.string(FND_LOG.LEVEL_EXCEPTION
                                   ,G_PKG_NAME||'.'||l_api_name
                                   ,G_PKG_NAME||'.'||l_api_name
                                   ||' FND_API.G_EXC_EXCEPTION at l_stmt_num = '
                                   || l_stmt_num|| ': ' ||sqlerrm);
           END IF; --for fnd_log
           x_rule_result := 'U';
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       WHEN OTHERS THEN
		       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count
                                      ,p_data  => x_msg_data);
                IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                    fnd_log.string(FND_LOG.LEVEL_EXCEPTION
                                   ,G_PKG_NAME||'.'||l_api_name
                                   ,G_PKG_NAME||'.'||l_api_name
                                   ||' Others Exception at l_stmt_num = '
                                   || l_stmt_num|| ': ' ||sqlerrm);
                END IF; --for fnd_log
                x_rule_result := 'U';
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Run_Rule_Result;

END EGO_RULES_UTIL_PUB;

/
