--------------------------------------------------------
--  DDL for Package CN_ATTAIN_TIER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ATTAIN_TIER_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvattrs.pls 115.3 2002/11/21 21:11:41 hlchen ship $*/

-- job title
TYPE attain_tier_rec_type IS RECORD
  (
    ATTAIN_TIER_ID		NUMBER := NULL,
    ATTAIN_SCHEDULE_ID		NUMBER := NULL,
    PERCENT			NUMBER := NULL,
    ATTRIBUTE_CATEGORY		VARCHAR2(30) := NULL,
    ATTRIBUTE1			VARCHAR2(150) := NULL,
    ATTRIBUTE2			VARCHAR2(150) := NULL,
    ATTRIBUTE3			VARCHAR2(150) := NULL,
    ATTRIBUTE4			VARCHAR2(150) := NULL,
    ATTRIBUTE5			VARCHAR2(150) := NULL,
    ATTRIBUTE6			VARCHAR2(150) := NULL,
    ATTRIBUTE7			VARCHAR2(150) := NULL,
    ATTRIBUTE8			VARCHAR2(150) := NULL,
    ATTRIBUTE9			VARCHAR2(150) := NULL,
    ATTRIBUTE10			VARCHAR2(150) := NULL,
    ATTRIBUTE11			VARCHAR2(150) := NULL,
    ATTRIBUTE12			VARCHAR2(150) := NULL,
    ATTRIBUTE13			VARCHAR2(150) := NULL,
    ATTRIBUTE14			VARCHAR2(150) := NULL,
    ATTRIBUTE15			VARCHAR2(150) := NULL,
    OBJECT_VERSION_NUMBER	NUMBER := NULL
    ) ;

TYPE attain_tier_tbl_type IS
   TABLE OF attain_tier_rec_type INDEX BY BINARY_INTEGER ;

-- Global variable that represent missing values.

G_MISS_ATTAIN_TIER_REC  attain_tier_rec_type;
G_MISS_ATTAIN_TIER_REC_TB  attain_tier_tbl_type;

-- Start of comments
--    API name        : Create_Attain_Tier
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
--                      p_attain_tier	      IN  attain_tier_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Attain_Tier
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_tier                IN      attain_tier_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Start of comments
--      API name        : Update_Attain_Tier
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_attain_tier       IN  attain_tier_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Attain_Tier
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_tier                 IN      attain_tier_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2 );

-- Start of comments
--      API name        : Delete_Attain_Tier
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_attain_tier       IN attain_tier_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Attain_Tier
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_tier                 IN      attain_tier_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);

-- Start of comments
--      API name        : Get_Attain_Tier
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_attain_schedule_id  IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_attain_tier       OUT     attain_tier_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Attain_Tier
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_schedule_id          IN      NUMBER,
   x_attain_tier                 OUT NOCOPY     attain_tier_tbl_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);


END CN_ATTAIN_TIER_PVT;

 

/
