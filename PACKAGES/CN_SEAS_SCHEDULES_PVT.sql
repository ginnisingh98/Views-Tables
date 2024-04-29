--------------------------------------------------------
--  DDL for Package CN_SEAS_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SEAS_SCHEDULES_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvsschs.pls 115.4 2002/11/21 21:19:30 hlchen ship $

TYPE seas_schedules_rec_type IS RECORD
  ( SEAS_SCHEDULE_ID      cn_seas_schedules.SEAS_SCHEDULE_ID%TYPE := NULL,
    NAME                  cn_seas_schedules.NAME%TYPE := FND_API.G_MISS_CHAR,
    DESCRIPTION           cn_seas_schedules.DESCRIPTION%TYPE   := FND_API.G_MISS_CHAR,
    PERIOD_YEAR           cn_seas_schedules.PERIOD_YEAR%TYPE := FND_API.G_MISS_NUM,
    START_DATE            cn_seas_schedules.START_DATE%TYPE := FND_API.G_MISS_DATE,
    END_DATE              cn_seas_schedules.END_DATE%TYPE := FND_API.G_MISS_DATE,
    VALIDATION_STATUS     cn_seas_schedules.VALIDATION_STATUS%TYPE := FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER cn_seas_schedules.OBJECT_VERSION_NUMBER%TYPE:= FND_API.G_MISS_NUM
    ) ;

TYPE seas_schedules_tbl_type IS TABLE OF seas_schedules_rec_type INDEX BY BINARY_INTEGER;


-- Start of comments
--    API name        : Create_Seas_Schedule
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
--                      p_seas_schedules_tbl_type  IN      seas_schedules_tbl_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure uses the table handler CN_SEAS_SCHEDULES_PKG
--                      and CN_SEASONALITIES_PKG to insert rows into CN_SEAS_SCHEDULES
--                      and CN_SEASONALITIES after some validations.
--
-- End of comments

PROCEDURE Create_Seas_Schedule
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_seas_schedules_rec_type IN     seas_schedules_rec_type,
   x_seas_schedule_id        OUT NOCOPY    NUMBER,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 );


-- Start of comments
--    API name        : Update_Seas_Schedule
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
--                      p_seas_schedules_tbl_type  IN      seas_schedules_tbl_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure uses the table handler CN_SEAS_SCHEDULES_PKG
--                      to update rows into CN_SEAS_SCHEDULES after some validations.
--
-- End of comments

PROCEDURE Update_Seas_Schedule
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_seas_schedules_rec_type IN     seas_schedules_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 );


-- Start of comments
--    API name        : Delete_Seas_Schedule
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
--                      P_SEAS_SCHEDULE_ID    IN NUMBER       Required
--
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure uses the table handler CN_SEAS_SCHEDULES_PKG
--                      and CN_SEASONALITIES_PKG to delete rows into CN_SEAS_SCHEDULES
--                      and CN_SEASONALITIES after the validations are done.
--
-- End of comments

PROCEDURE Delete_Seas_Schedule
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   P_SEAS_SCHEDULE_ID        IN     cn_seas_schedules.seas_schedule_id%TYPE,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 );


-- Start of comments
--    API name        : Sum_Seas_Schedule
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
--                      P_SEAS_SCHEDULE_ID    IN NUMBER       Required
--
--    OUT             : x_seas_schedule_sum       OUT    NUMBER,
--                      x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--
--    Version :         Current version       1.0
--
--
--
--    Notes           :  This procedures find the sum of seasonalities
-- End of comments

PROCEDURE Sum_Seas_Schedule
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_seas_schedules_id       IN     NUMBER,
   x_seas_schedule_sum       OUT NOCOPY    NUMBER,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 );

END cn_seas_schedules_PVT;

 

/
