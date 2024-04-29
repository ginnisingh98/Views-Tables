--------------------------------------------------------
--  DDL for Package BSC_COMMON_DIMENSIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COMMON_DIMENSIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPLIBS.pls 120.0.12000000.1 2007/07/17 07:44:14 appldev noship $ */

PROCEDURE save_list_button_config
(p_tab_id                 IN               NUMBER
,p_new_list_config        IN               VARCHAR2
,p_old_list_config        IN               VARCHAR2
,p_commit                 IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT       NOCOPY VARCHAR2
,x_msg_count              OUT       NOCOPY NUMBER
,x_msg_data               OUT       NOCOPY VARCHAR2
);

PROCEDURE update_user_list_access
(
 p_tab_id                 IN               NUMBER
,p_new_list_config        IN               VARCHAR2
,p_old_list_config        IN               VARCHAR2
,p_commit                 IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT       NOCOPY VARCHAR2
,x_msg_count              OUT       NOCOPY NUMBER
,x_msg_data               OUT       NOCOPY VARCHAR2
);

PROCEDURE change_prototype_flag
(
  p_prototype_flag         IN               NUMBER
 ,p_tab_id                 IN               NUMBER
 ,p_dim_level_id           IN               NUMBER
 ,p_commit                 IN               VARCHAR2 := FND_API.G_FALSE
 ,x_return_status          OUT       NOCOPY VARCHAR2
 ,x_msg_count              OUT       NOCOPY NUMBER
 ,x_msg_data               OUT       NOCOPY VARCHAR2

);



END BSC_COMMON_DIMENSIONS_PUB;

 

/
