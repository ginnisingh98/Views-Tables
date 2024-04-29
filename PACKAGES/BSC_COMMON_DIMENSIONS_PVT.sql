--------------------------------------------------------
--  DDL for Package BSC_COMMON_DIMENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COMMON_DIMENSIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVLIBS.pls 120.2.12000000.1 2007/07/17 07:44:54 appldev noship $ */

C_ALL          		  CONSTANT VARCHAR2(1) := 'T';
C_COM_DIM_DEFAULT_VALUE   CONSTANT VARCHAR2(3) := 'D%';


-- The following API saves LIST BUTTON (Common Dimension) configuration
-- for a particular SCORECARD.
-- INPUT :
--      p_new_list_config     A semicolon(;) seperated values of common dimension objects
--                            that have to be saved.
-- NOTE:    Each common dimension object record contains a commma seperated list of the following
--          properties in order:
--          (dim_level_index, dim_level_id, parent_level_index, parent_level_id)

PROCEDURE insert_common_dimensions
(
 p_tab_id                 IN               NUMBER
,p_new_list_config        IN               VARCHAR2
,p_commit                 IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT       NOCOPY VARCHAR2
,x_msg_count              OUT       NOCOPY NUMBER
,x_msg_data               OUT       NOCOPY VARCHAR2
) ;



-- The following API removes common dimensions for a given scorecard.

PROCEDURE delete_common_dimensions
(
 p_tab_id               IN               NUMBER
,p_commit               IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status        OUT     NOCOPY   VARCHAR2
,x_msg_count            OUT     NOCOPY   NUMBER
,x_msg_data             OUT     NOCOPY   VARCHAR2
);

PROCEDURE delete_common_dimensions_tabs (
  p_commit         IN  VARCHAR2 := FND_API.G_FALSE
, p_tab_ids        IN  VARCHAR2
, x_return_status  OUT NOCOPY VARCHAR2
, x_msg_count      OUT NOCOPY NUMBER
, x_msg_data       OUT NOCOPY VARCHAR2
);


PROCEDURE delete_user_list_access
(
 p_tab_id               IN               NUMBER
,p_dim_level_index      IN               NUMBER
,p_commit               IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status        OUT     NOCOPY   VARCHAR2
,x_msg_count            OUT     NOCOPY   NUMBER
,x_msg_data             OUT     NOCOPY   VARCHAR2
);


PROCEDURE insert_user_list_access
(
 p_responsibility_id     IN               bsc_user_list_access.responsibility_id%TYPE
,p_tab_id                IN               bsc_user_list_access.tab_id%TYPE
,p_dim_level_index       IN               bsc_user_list_access.dim_level_index%TYPE
,p_dim_level_value       IN               bsc_user_list_access.dim_level_value%TYPE
,p_creation_date         IN               bsc_user_list_access.creation_date%TYPE
,p_created_by            IN               bsc_user_list_access.created_by%TYPE
,p_last_update_date      IN               bsc_user_list_access.last_update_date%TYPE
,p_last_updated_by       IN               bsc_user_list_access.last_updated_by%TYPE
,p_last_update_login     IN               bsc_user_list_access.last_update_login%TYPE
,p_commit                IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status         OUT       NOCOPY VARCHAR2
,x_msg_count             OUT       NOCOPY NUMBER
,x_msg_data              OUT       NOCOPY VARCHAR2
);

PROCEDURE reset_dim_default_value
(
   p_Tab_Id           IN     BSC_TABS_B.tab_id%TYPE
  ,x_return_status    OUT    NOCOPY VARCHAR2
  ,x_msg_count        OUT    NOCOPY NUMBER
  ,x_msg_data         OUT    NOCOPY VARCHAR2
);

PROCEDURE set_dim_default_value
(
   p_dim_level_id     IN     BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
  ,p_default_value    IN     BSC_KPI_DIM_LEVELS_B.default_value%TYPE
  ,p_Tab_Id           IN     BSC_TABS_B.tab_id%TYPE
  ,x_return_status    OUT    NOCOPY VARCHAR2
  ,x_msg_count        OUT    NOCOPY NUMBER
  ,x_msg_data         OUT    NOCOPY VARCHAR2
);

END BSC_COMMON_DIMENSIONS_PVT;

 

/
