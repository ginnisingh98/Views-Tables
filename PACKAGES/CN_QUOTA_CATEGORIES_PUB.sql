--------------------------------------------------------
--  DDL for Package CN_QUOTA_CATEGORIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_CATEGORIES_PUB" AUTHID CURRENT_USER AS
-- $Header: cnpqcats.pls 115.7 2002/11/21 21:05:45 hlchen ship $

TYPE quota_category_rec_type IS RECORD
  (  QUOTA_CATEGORY_ID		 NUMBER(15),
     NAME			 VARCHAR2(80),
     DESCRIPTION	       	 VARCHAR2(80),
     TYPE                        VARCHAR2(30),
     TYPE_MEANING		 VARCHAR2(80),
     COMPUTE_FLAG		 VARCHAR2(1),
     COMPUTED                    VARCHAR2(80),
     INTERVAL_TYPE_ID            NUMBER(15),
     QUOTA_UNIT_CODE             VARCHAR2(30),
     OBJECT_VERSION_NUMBER       NUMBER);

TYPE quota_categories_tbl_type IS TABLE OF quota_category_rec_type
  INDEX BY BINARY_INTEGER;

-- Start of comments
--    API name        : Create_Quota_Category
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_rec of table rec type
--    OUT             : standard params
--                      x_user_access_id
--    Version         : 1.0
--
-- End of comments

PROCEDURE Create_Quota_Category(
	p_api_version                IN      NUMBER,
   	p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   	p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
 	p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   	p_rec                        IN      quota_category_rec_type,
  	x_return_status              OUT NOCOPY     VARCHAR2,
	x_msg_count                  OUT NOCOPY     NUMBER,
   	x_msg_data                   OUT NOCOPY     VARCHAR2,
 	x_quota_category_id          OUT NOCOPY     NUMBER);

-- Start of comments
--    API name        : Update_Quota_Category
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_rec of table rec type
--    OUT             : standard params
--    Version         : 1.0
--
-- End of comments

PROCEDURE Update_Quota_Category(
  	p_api_version                IN      NUMBER,
	p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
	p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
	p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	p_rec                        IN      quota_category_rec_type,
	x_return_status              OUT NOCOPY     VARCHAR2,
	x_msg_count                  OUT NOCOPY     NUMBER,
	x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Start of comments
--    API name        : Delete_Quota_Category
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_user_access_id
--    OUT             : standard params
--    Version         : 1.0
--
-- End of comments

PROCEDURE Delete_Quota_Category(
	p_api_version                IN      NUMBER,
	p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   	p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
 	p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   	p_quota_category_id          IN      NUMBER,
  	p_object_version_number      IN      NUMBER,
	x_return_status              OUT NOCOPY     VARCHAR2,
   	x_msg_count                  OUT NOCOPY     NUMBER,
 	x_msg_data                   OUT NOCOPY     VARCHAR2);

-- API name 	: Get_Quota_Category_details
-- Type	: Public.
-- Pre-reqs	:
-- Usage	:
--
-- Desc 	:
--
--
--
-- Parameters	:
--  IN	: p_api_version       NUMBER      Require
-- 	  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 	  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	: x_return_status     VARCHAR2(1)
-- 	  x_msg_count	       NUMBER
-- 	  x_msg_data	       VARCHAR2(2000)
--  IN	: p_start_record      NUMBER,
--        p_increment_count   NUMBER
--  OUT	: x_quota_categories_detail_tbl OUT quota_categories_tbl_type,
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE Get_Quota_Category_details
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,

    p_start_record          IN  NUMBER := 1,
    p_increment_count       IN  NUMBER := 25,

    p_search_name           IN  VARCHAR2,
    p_search_type           IN  VARCHAR2,
    p_search_unit           IN  VARCHAR2,

    x_quota_categories_tbl OUT NOCOPY quota_categories_tbl_type,
    x_total_records           OUT NOCOPY NUMBER
    );

END cn_quota_categories_pub;


 

/
