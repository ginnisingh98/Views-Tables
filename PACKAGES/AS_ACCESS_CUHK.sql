--------------------------------------------------------
--  DDL for Package AS_ACCESS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_ACCESS_CUHK" AUTHID CURRENT_USER AS
/* $Header: asxchacs.pls 120.1 2005/06/05 22:52:08 appldev  $ */

PROCEDURE Create_SalesTeam_Pre(
   p_api_version_number    IN  NUMBER,
   p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
   p_validation_level      IN  VARCHAR2:=FND_API.G_VALID_LEVEL_FULL,
   p_commit                IN  VARCHAR2:=FND_API.G_FALSE,
   p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
   p_check_access_flag     IN  VARCHAR2,
   p_admin_flag            IN  VARCHAR2,
   p_admin_group_id        IN  NUMBER,
   p_identity_salesforce_id  IN NUMBER,
   p_sales_team_rec        IN  AS_ACCESS_PVT.SALES_TEAM_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_access_id             OUT NOCOPY NUMBER
);

PROCEDURE Create_SalesTeam_Post(
   p_api_version_number    IN  NUMBER,
   p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
   p_validation_level      IN  VARCHAR2:=FND_API.G_VALID_LEVEL_FULL,
   p_commit                IN  VARCHAR2:=FND_API.G_FALSE,
   p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
   p_check_access_flag     IN  VARCHAR2,
   p_admin_flag            IN  VARCHAR2,
   p_admin_group_id        IN  NUMBER,
   p_identity_salesforce_id  IN NUMBER,
   p_sales_team_rec        IN  AS_ACCESS_PVT.SALES_TEAM_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_access_id             OUT NOCOPY NUMBER
);

PROCEDURE Update_SalesTeam_Pre(
   p_api_version_number    IN  NUMBER,
 p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
   p_validation_level      IN  VARCHAR2:=FND_API.G_VALID_LEVEL_FULL,
   p_commit                IN  VARCHAR2:=FND_API.G_FALSE,
  p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
   p_check_access_flag     IN  VARCHAR2,
   p_admin_flag            IN  VARCHAR2,
   p_admin_group_id        IN  NUMBER,
   p_identity_salesforce_id  IN NUMBER,
   p_sales_team_rec        IN  AS_ACCESS_PVT.SALES_TEAM_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_access_id             OUT NOCOPY NUMBER
);

PROCEDURE Update_SalesTeam_Post(
   p_api_version_number    IN  NUMBER,
 p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
   p_validation_level      IN  VARCHAR2:=FND_API.G_VALID_LEVEL_FULL,
   p_commit                IN  VARCHAR2:=FND_API.G_FALSE,
   p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
   p_check_access_flag     IN  VARCHAR2,
   p_admin_flag            IN  VARCHAR2,
   p_admin_group_id        IN  NUMBER,
   p_identity_salesforce_id  IN NUMBER,
   p_sales_team_rec        IN  AS_ACCESS_PVT.SALES_TEAM_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_access_id             OUT NOCOPY NUMBER
);

PROCEDURE Delete_SalesTeam_Pre(
   p_api_version_number    IN  NUMBER,
   p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
   p_validation_level      IN  VARCHAR2:=FND_API.G_VALID_LEVEL_FULL,
   p_commit                IN  VARCHAR2:=FND_API.G_FALSE,
   p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
   p_check_access_flag     IN  VARCHAR2,
   p_admin_flag            IN  VARCHAR2,
   p_admin_group_id        IN  NUMBER,
   p_identity_salesforce_id  IN NUMBER,
   p_sales_team_rec        IN  AS_ACCESS_PVT.SALES_TEAM_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_SalesTeam_Post(
   p_api_version_number    IN  NUMBER,
   p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
   p_validation_level      IN  VARCHAR2:=FND_API.G_VALID_LEVEL_FULL,
   p_commit                IN  VARCHAR2:=FND_API.G_FALSE,
   p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
   p_check_access_flag     IN  VARCHAR2,
   p_admin_flag            IN  VARCHAR2,
   p_admin_group_id        IN  NUMBER,
   p_identity_salesforce_id  IN NUMBER,
   p_sales_team_rec        IN  AS_ACCESS_PVT.SALES_TEAM_REC_TYPE,
   x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_msg_count             OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_msg_data              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

END AS_ACCESS_CUHK;

 

/
