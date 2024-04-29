--------------------------------------------------------
--  DDL for Package CN_SEASONALITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SEASONALITIES_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvseass.pls 115.4 2002/11/21 21:18:19 hlchen ship $

TYPE cp_seas_schedules_rec_type IS RECORD
  ( SEAS_SCHEDULE_ID      cn_seas_schedules.SEAS_SCHEDULE_ID%TYPE := NULL,
    NAME                  cn_seas_schedules.NAME%TYPE := FND_API.G_MISS_CHAR,
    DESCRIPTION           cn_seas_schedules.DESCRIPTION%TYPE   := FND_API.G_MISS_CHAR,
    PERIOD_YEAR           cn_seas_schedules.PERIOD_YEAR%TYPE := FND_API.G_MISS_NUM,
    START_DATE            cn_seas_schedules.START_DATE%TYPE := FND_API.G_MISS_DATE,
    END_DATE              cn_seas_schedules.END_DATE%TYPE := FND_API.G_MISS_DATE,
    VALIDATION_STATUS     cn_seas_schedules.VALIDATION_STATUS%TYPE := FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER cn_seas_schedules.OBJECT_VERSION_NUMBER%TYPE:= FND_API.G_MISS_NUM
    ) ;

TYPE seasonalities_rec_type IS RECORD
  ( SEAS_SCHEDULE_ID      cn_seasonalities.SEAS_SCHEDULE_ID%TYPE := NULL,
    SEASONALITY_ID        cn_seasonalities.SEASONALITY_ID%TYPE := NULL,
    PCT_SEASONALITY       cn_seasonalities.PCT_SEASONALITY%TYPE := NULL,
    OBJECT_VERSION_NUMBER cn_seasonalities.OBJECT_VERSION_NUMBER%TYPE:= FND_API.G_MISS_NUM
  ) ;

TYPE seasonalities_tbl_type IS TABLE OF seasonalities_rec_type INDEX BY BINARY_INTEGER;

-- Start of comments
--    API name        : Update_Seasonalities
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
--                      p_seasonalities_rec_type  IN      seasonalities_rec_type
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

PROCEDURE Update_Seasonalities
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_seasonalities_rec_type  IN     seasonalities_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
 );


-- Start of comments
--    API name        : Validate_Seasonalities
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
--                      p_seas_schedule_id    IN      NUMBER
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

PROCEDURE Validate_Seasonalities
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_seas_schedule_rec_type  IN     cp_seas_schedules_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 );


END CN_SEASONALITIES_PVT;

 

/
