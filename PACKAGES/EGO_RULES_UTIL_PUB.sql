--------------------------------------------------------
--  DDL for Package EGO_RULES_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_RULES_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: EGORUTLS.pls 120.0.12010000.1 2009/08/13 19:05:31 chulhale noship $ */

-- Start of comments
-- API name   : Get_Run_Rule_Result
-- Type       : Public
-- Pre-reqs   : None.
-- Function   : Customized Get_Run_Rule_Result procudure based on information
--              related to user, entity, and object etc.
-- Parameters :
--     IN     :	p_rule_id IN VARCHAR2(150)
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
         p_rule_id		IN VARCHAR2
	,p_entity_type_name     IN VARCHAR2
	,p_data_level_name	IN VARCHAR2
	,p_entity_key_pairs IN  EGO_COL_NAME_VALUE_PAIR_ARRAY default NULL
  	,p_additional_key_pairs	IN  EGO_COL_NAME_VALUE_PAIR_ARRAY default NULL
  	,x_rule_result	OUT NOCOPY VARCHAR2

   --standard parameters
    ,p_api_version        IN NUMBER   default 1.0
    ,p_init_msg_list      IN VARCHAR2 default FND_API.G_FALSE
    ,p_commit             IN VARCHAR2 default FND_API.G_FALSE
    ,p_validation_level   IN NUMBER   default FND_API.G_VALID_LEVEL_FULL
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
 );

END EGO_RULES_UTIL_PUB;

/
