--------------------------------------------------------
--  DDL for Package EGO_CUSTOM_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_CUSTOM_SECURITY_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOCSECS.pls 120.0.12010000.1 2009/07/23 00:28:25 ksuleman noship $ */

TYPE in_params_rec_type IS RECORD
(
   object_name            VARCHAR2(500)
  ,function_name          VARCHAR2(150)
  ,instance_pk1_value     VARCHAR2(150)
  ,instance_pk2_value     VARCHAR2(150)
  ,instance_pk3_value     VARCHAR2(150)
  ,instance_pk4_value     VARCHAR2(150)
  ,instance_pk5_value     VARCHAR2(150)
  ,user_name   	  VARCHAR2(100)
);


TYPE out_params_rec_type IS RECORD
(
  user_has_function     VARCHAR2(1)
);

-- Start of comments
-- API name   : check_custom_security
-- Type       : Public
-- Pre-reqs   : None.
-- Function   : Customized security check procudure based on information
--              related to user, entity, and object etc.
-- Parameters :
--     IN     :	p_in_params_rec IN  EGO_CUSTOM_SECURITY_PUB.in_params_rec_type
--                               Required
--     OUT    : x_out_params_rec OUT NOCOPY EGO_CUSTOM_SECURITY_PUB.out_params_rec_type
--              x_out_params_rec.user_has_function = 'T' if user has proper previlege
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
--
-- End of comments
PROCEDURE check_custom_security
(
   --program parameters
  	 p_in_params_rec    	IN  EGO_CUSTOM_SECURITY_PUB.in_params_rec_type
  	,x_out_params_rec	OUT NOCOPY EGO_CUSTOM_SECURITY_PUB.out_params_rec_type

   --standard parameters
    ,p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 default FND_API.G_FALSE
    ,p_commit             IN VARCHAR2 default FND_API.G_FALSE
    ,p_validation_level   IN NUMBER   default FND_API.G_VALID_LEVEL_FULL
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
 );

END EGO_CUSTOM_SECURITY_PUB;

/
