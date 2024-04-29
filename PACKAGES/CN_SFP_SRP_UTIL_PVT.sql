--------------------------------------------------------
--  DDL for Package CN_SFP_SRP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SFP_SRP_UTIL_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvsfsrs.pls 115.3 2004/01/27 02:24:01 fmburu noship $

-- Used meaning because it has bigger size varchar2(80)

TYPE string_tabletype IS TABLE OF CN_LOOKUPS.MEANING%TYPE INDEX BY BINARY_INTEGER;

-- Start of comments
--    API name        : Get_Valid_Plan_Statuses
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_default_all
--                      p_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--                      x_values_tab            OUT string_tabletype
--                      x_meanings_tab          OUT string_tabletype
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure gets valid statuses of the salesrep/fm/pa/sm.
--
-- End of comments

PROCEDURE Get_Valid_Plan_Statuses
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_default_all             IN  VARCHAR2 := FND_API.G_FALSE,
   p_type                    IN  VARCHAR2 := 'COMPPLANPROCESS',
   x_values_tab              OUT NOCOPY    string_tabletype,
   x_meanings_tab            OUT NOCOPY    string_tabletype,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 );


-- Start of comments
--    API name        : Get_Groups_In_Hierarchy
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              :
--                      p_include_array        IN         DBMS_SQL.NUMBER_TABLE ,
--                      p_exclude_array        IN         DBMS_SQL.NUMBER_TABLE ,
--                      p_date                 IN         DATE := SYSDATE,
--                      p_type
--    OUT             : x_hierarchy_groups     OUT NOCOPY DBMS_SQL.NUMBER_TABLE
--    Version :         Current version       1.0

--
--    Notes           : Given certain root groups, this procedure gets all groups under their heirarchies but
--                      excludes those in the p_exclude_array parameters..
--
-- End of comments
PROCEDURE Get_Groups_In_Hierarchy
(
     p_include_array        IN         DBMS_SQL.NUMBER_TABLE ,
     p_exclude_array        IN         DBMS_SQL.NUMBER_TABLE ,
     p_date                 IN         DATE := SYSDATE,
     x_hierarchy_groups     OUT NOCOPY DBMS_SQL.NUMBER_TABLE
) ;


-- Start of comments
--    API name        : Get_All_Groups_Access
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_org_code                IN  VARCHAR2 := NULL,
--                      p_date                    IN  VARCHAR2,
--                      x_update_groups         OUT    DBMS_SQL.NUMBER_TABLE,
--                      x_view_groups           OUT    DBMS_SQL.NUMBER_TABLE,
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure gets the user_access for all groups
--                      in cn_user_access
--
-- End of comments

PROCEDURE Get_All_Groups_Access
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_org_code                IN  VARCHAR2 := NULL,
   p_date                    IN  VARCHAR2,
   x_update_groups           OUT NOCOPY    DBMS_SQL.NUMBER_TABLE,
   x_view_groups             OUT NOCOPY    DBMS_SQL.NUMBER_TABLE,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) ;

-- Start of comments
--    API name        : Get_Group_Access
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_default_all
--                      p_group_id
--                      p_update_groups         IN      DBMS_SQL.NUMBER_TABLE,
--                      p_view_groups           IN      DBMS_SQL.NUMBER_TABLE,
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--                      x_privilege             OUT     VARCHAR2,
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure get the user access for a particular group.
--
-- End of comments


PROCEDURE Get_Group_Access
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_group_id                IN  NUMBER,
   p_update_groups           IN  DBMS_SQL.NUMBER_TABLE,
   p_view_groups             IN  DBMS_SQL.NUMBER_TABLE,
   x_privilege               OUT NOCOPY    VARCHAR2,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) ;



END CN_SFP_SRP_UTIL_PVT;

 

/
