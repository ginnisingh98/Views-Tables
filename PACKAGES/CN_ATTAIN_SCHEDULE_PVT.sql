--------------------------------------------------------
--  DDL for Package CN_ATTAIN_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ATTAIN_SCHEDULE_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvatshs.pls 115.3 2002/11/21 21:11:37 hlchen ship $*/

-- job title
TYPE attain_schedule_rec_type IS RECORD
  (
    ATTAIN_SCHEDULE_ID		NUMBER := NULL,
    NAME			VARCHAR2(30) := NULL,
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

TYPE attain_schedule_tbl_type IS
   TABLE OF attain_schedule_rec_type INDEX BY BINARY_INTEGER ;

-- Global variable that represent missing values.

G_MISS_ATTAIN_SCHEDULE_REC  attain_schedule_rec_type;
G_MISS_ATTAIN_SCHEDULE_REC_TB  attain_schedule_tbl_type;

-- Start of comments
--    API name        : Create_Attain_Schedule
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
--                      p_attain_schedule     IN  attain_schedule_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Attain_Schedule
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_schedule            IN      attain_schedule_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Start of comments
--      API name        : Update_Attain_Schedule
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
--                        p_attain_schedule   IN  attain_schedule_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Attain_Schedule
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_schedule             IN      attain_schedule_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2 );

-- Start of comments
--      API name        : Delete_Attain_Schedule
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
--                        p_attain_schedule   IN attain_schedule_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Attain_Schedule
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_schedule             IN      attain_schedule_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);

-- Start of comments
--      API name        : Get_Attain_Schedule
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
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_attain_schedule        OUT     attain_schedule_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Attain_Schedule
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_attain_schedule             OUT NOCOPY     attain_schedule_tbl_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);


END CN_ATTAIN_SCHEDULE_PVT;

 

/
