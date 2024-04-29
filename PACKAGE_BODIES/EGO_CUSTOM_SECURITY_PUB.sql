--------------------------------------------------------
--  DDL for Package Body EGO_CUSTOM_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_CUSTOM_SECURITY_PUB" AS
/* $Header: EGOCSECB.pls 120.0.12010000.1 2009/07/23 00:29:03 ksuleman noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):='EGO_CUSTOM_SECURITY_PUB';

-- Start of comments
-- API name   : check_custom_security
-- Type       : Public
-- Pre-reqs   : None.
-- Function   : Customized security check procudure based on information
--              related to user, entity, and object etc.
-- Parameters :
--     IN     :	p_in_params_rec IN  EGO_CUSTOM_SECURITY_PUB.in_params_rec_type
--                              Required
--              NOTE: p_in_params_rec.user_name is one of the following forms
--                    'HZ_PARTY:partyId' or NULL.
--                    1. Create table EGO_CUSTOM_SEC_B based on fnd_user_name such as 'PLMMGR'
--                       -Set p_in_params_rec.user_name := FND_GLOBAL.USER_NAME
--                    2. Create table combining 'HZ_PARTY:partyId' and find_user_name
--                       -Set p_in_params_rec.user_name := nvl(p_in_params_rec.user_name, FND_GLOBAL.USER_NAME)
--     OUT    : x_out_params_rec OUT NOCOPY EGO_CUSTOM_SECURITY_PUB.out_params_rec_type
--              NOTE: x_out_params_rec.user_has_function = 'T' if user has proper previlege
--                                                   'F' if user has no previlege
--                                                   'U' if there are unexpected errors
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
-- End of comments
PROCEDURE check_custom_security
(
    --program parameters
     p_in_params_rec        IN  EGO_CUSTOM_SECURITY_PUB.in_params_rec_type
    ,x_out_params_rec       OUT NOCOPY  EGO_CUSTOM_SECURITY_PUB.out_params_rec_type

    --standard parameters
    ,p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 default FND_API.G_FALSE
    ,p_commit             IN VARCHAR2 default FND_API.G_FALSE
    ,p_validation_level   IN NUMBER   default FND_API.G_VALID_LEVEL_FULL
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
)
IS
l_api_name    CONSTANT    VARCHAR2(30) := 'check_custom_security';
l_api_version CONSTANT    NUMBER := 1.0;
l_stmt_num                 NUMBER;  --for debuging index



BEGIN
    -- Leave starting poing of this procedure at fnd_log_message
    l_stmt_num := 0;
    IF  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                   ,G_PKG_NAME||'.'||l_api_name
                   ,'Enter '||G_PKG_NAME||'.'||l_api_name||' '
                   ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss') );
    END IF; --for fnd_log

   	-- Standard call to check for call compatibility.
    l_stmt_num := 3;
   	IF NOT FND_API.Compatible_API_Call ( 	l_api_version
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
    x_out_params_rec.user_has_function := 'U';

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    fnd_log.string(FND_LOG.LEVEL_STATEMENT
                  ,G_PKG_NAME||'.'||l_api_name
                  ,' p_in_params_rec.object_name=>'|| p_in_params_rec.object_name ||','
                 ||' p_in_params_rec.function_name=>'|| p_in_params_rec.function_name ||','
                 ||' p_in_params_rec.instance_pk1_value=>'|| p_in_params_rec.instance_pk1_value ||','
                 ||' p_in_params_rec.instance_pk2_value=>'|| p_in_params_rec.instance_pk2_value ||','
                 ||' p_in_params_rec.instance_pk3_value=>'|| p_in_params_rec.instance_pk3_value ||','
                 ||' p_in_params_rec.instance_pk4_value=>'|| p_in_params_rec.instance_pk4_value ||','
                 ||' p_in_params_rec.instance_pk5_value=>'|| p_in_params_rec.instance_pk5_value ||','
                 ||' p_in_params_rec.user_name=>'|| p_in_params_rec.user_name );
    END IF; --fnd_log


--When OBJECT_NAME = EGO_ITEM, pk1_value = inventory_item_id
--                              pk2_value = organization_id
--                              other pk values are NULL.
-- Customer add their own code here


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
           x_out_params_rec.user_has_function := 'U';
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
                x_out_params_rec.user_has_function := 'U';
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_custom_security;

END EGO_CUSTOM_SECURITY_PUB;

/
