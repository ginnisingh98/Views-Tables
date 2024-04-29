--------------------------------------------------------
--  DDL for Package CN_SFP_GROUP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SFP_GROUP_UTIL_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvsfgrs.pls 115.2 2003/08/19 22:29:34 sbadami noship $

TYPE srprole_rec_type IS RECORD
( srp_role_id     NUMBER := 0,
  comp_group_id   NUMBER := 0,
  org_code        cn_srp_role_dtls_v.org_code%type := null
);

TYPE srprole_tbl_type IS TABLE OF srprole_rec_type INDEX BY BINARY_INTEGER;


TYPE grporg_rec_type IS RECORD
(
  org_code        cn_lookups.lookup_code%type := null,
  org_meaning     cn_lookups.meaning%type := null
);

TYPE grporg_tbl_type IS TABLE OF grporg_rec_type INDEX BY BINARY_INTEGER;

TYPE grpnum_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Start of comments
--    API name        : Get_Descendant_Groups
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
--                      p_selected_groups     IN   DBMS_SQL.NUMBER_TABLE,
--                      p_effective_date
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_descendant_groups   OUT DBMS_SQL.NUMBER_TABLE
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedures takes many comp group ids as parameters
--                      and tries to generate the distinct comp group id list.
--
-- End of comments

PROCEDURE Get_Descendant_Groups
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_selected_groups         IN  grpnum_tbl_type,
   p_effective_date          IN  DATE := SYSDATE,
   x_descendant_groups       OUT NOCOPY    grpnum_tbl_type,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 );

-- Start of comments
--    API name        : Get_Salesrep_Roles
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
--                      p_selected_groups     IN  DBMS_SQL.NUMBER_TABLE,
--                      p_status              IN  VARCHAR2
--                      p_effective_date      IN  DATE
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_salesrep_roles      OUT srprole_tbl_type
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure gets the srp role ids for all the
--                      groups that have been selected based on the status
--                      Status could be PENDING, LOCKED,GENERATED, SUBMITTED
--                      APPROVED, ISSUED and ACCEPTED or ALL
--
-- End of comments

PROCEDURE Get_Salesrep_Roles
 ( p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_selected_groups         IN  grpnum_tbl_type,
   p_status                  IN  VARCHAR2 := 'ALL',
   p_effective_date          IN  DATE := SYSDATE,
   x_salesrep_roles          OUT NOCOPY    srprole_tbl_type,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) ;


-- Start of comments
--    API name        : Get_Grp_Organization_Access
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
--                      p_comp_group_id       IN  NUMBER,
--                      p_effective_date      IN  DATE
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_updview_organization OUT grporg_tbl_type
--                      x_upd_organization OUT grporg_tbl_type
--                      x_view_organization OUT grporg_tbl_type
--                      x_noview_organization OUT grporg_tbl_type
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure given a comp group id and an effective
--                      date lists the Organization user has UPDATE/VIEW or
--                      NO_READ accesses for that group.
--
-- End of comments
PROCEDURE Get_Grp_Organization_Access
(  p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_comp_group_id           IN  NUMBER,
   p_effective_date          IN  DATE := SYSDATE,
   x_updview_organization    OUT NOCOPY    grporg_tbl_type,
   x_upd_organization        OUT NOCOPY    grporg_tbl_type,
   x_view_organization       OUT NOCOPY    grporg_tbl_type,
   x_noview_organization     OUT NOCOPY    grporg_tbl_type,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
 );


END CN_SFP_GROUP_UTIL_PVT;

 

/
