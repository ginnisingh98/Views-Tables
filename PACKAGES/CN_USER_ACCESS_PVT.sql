--------------------------------------------------------
--  DDL for Package CN_USER_ACCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_USER_ACCESS_PVT" AUTHID CURRENT_USER AS
--$Header: cnvurass.pls 115.6 2002/11/25 19:08:41 nkodkani ship $
TYPE user_access_rec_type IS record
  (user_access_id          number,
   user_id                 number,
   comp_group_id           number,
   org_code                varchar(30),
   access_code             varchar(30),
   attribute_category      varchar2(30),
   attribute1              varchar2(150),
   attribute2              varchar2(150),
   attribute3              varchar2(150),
   attribute4              varchar2(150),
   attribute5              varchar2(150),
   attribute6              varchar2(150),
   attribute7              varchar2(150),
   attribute8              varchar2(150),
   attribute9              varchar2(150),
   attribute10             varchar2(150),
   attribute11             varchar2(150),
   attribute12             varchar2(150),
   attribute13             varchar2(150),
   attribute14             varchar2(150),
   attribute15             varchar2(150),
   object_version_number   number);

TYPE user_access_tbl_type IS
   TABLE OF user_access_rec_type INDEX BY BINARY_INTEGER;

TYPE user_access_sum_rec_type IS RECORD
  (user_id                 number,
   full_name               varchar2(240),
   user_name               varchar2(100));

TYPE user_access_sum_tbl_type IS
   TABLE OF user_access_sum_rec_type INDEX BY BINARY_INTEGER;

-- Start of comments
--    API name        : Create_User_Access
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_rec of table rec type
--    OUT             : standard params
--                      x_user_access_id
--    Version         : 1.0
--
-- End of comments

PROCEDURE Create_User_Access
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_rec                        IN      user_access_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_user_access_id             OUT NOCOPY     NUMBER);

-- Start of comments
--    API name        : Update_User_Access
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_rec of table rec type
--    OUT             : standard params
--    Version         : 1.0
--
-- End of comments

PROCEDURE Update_User_Access
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_rec                        IN      user_access_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Start of comments
--    API name        : Delete_User_Access
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_user_access_id
--    OUT             : standard params
--    Version         : 1.0
--
-- End of comments

PROCEDURE Delete_User_Access
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_user_access_id             IN      NUMBER,
   p_object_version_number      IN      NUMBER,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Start of comments
--    API name        : Get_Accesses - Private
--    Pre-reqs        : None.
--    IN              : range params
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_Accesses
  (p_range_low                  IN      NUMBER,
   p_range_high                 IN      NUMBER,
   x_total_rows                 OUT NOCOPY     NUMBER,
   x_result_tbl                 OUT NOCOPY     user_access_sum_tbl_type);

-- Start of comments
--    API name        : Get_Access_Details - Private
--    Pre-reqs        : None.
--    IN              : p_user_id
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_Access_Details
  (p_user_id                    IN      NUMBER,
   x_result_tbl                 OUT NOCOPY     user_access_tbl_type);

END CN_USER_ACCESS_PVT;

 

/
