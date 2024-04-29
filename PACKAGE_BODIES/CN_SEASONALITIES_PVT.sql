--------------------------------------------------------
--  DDL for Package Body CN_SEASONALITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SEASONALITIES_PVT" AS
-- $Header: cnvseasb.pls 115.4 2002/11/21 21:18:17 hlchen ship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'cn_seasonalities_pvt';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvseasb.pls';


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
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_seasonalities_rec_type  IN     seasonalities_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
 ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Update_Seasonalities';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_error_code NUMBER;
      l_count NUMBER;
      l_validation_status VARCHAR2(30);
      l_rec cn_seas_schedules_PVT.seas_schedules_rec_type;
      l_return_status VARCHAR2(1);
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(2000);

BEGIN
   --DBMS_OUTPUT.PUT_LINE('Update in progress');
    -- Standard Start of API savepoint
   SAVEPOINT   Update_Seasonalities;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   l_validation_status := 'INVALID';
   -- API body
   -- FIRST IS TO MAKE THE CN_SEAS_SCHEDULE_TABLE INVALID
   -- Fetch the record.


   SELECT OBJECT_VERSION_NUMBER,NAME,DESCRIPTION INTO l_rec.object_version_number,l_rec.name,l_rec.description
   FROM CN_SEAS_SCHEDULES WHERE SEAS_SCHEDULE_ID = p_seasonalities_rec_type.SEAS_SCHEDULE_ID;

   l_rec.seas_schedule_id := p_seasonalities_rec_type.SEAS_SCHEDULE_ID;
   l_rec.validation_status := l_validation_status;

    --DBMS_OUTPUT.PUT_LINE('About to call CN_SEAS_SCHEDULES');
    cn_seas_schedules_PVT.Update_Seas_Schedule
    ( p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_FALSE,
      p_commit               => FND_API.G_FALSE,
      p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
      p_seas_schedules_rec_type => l_rec,
      x_return_status        => l_return_status ,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data
    );
    --DBMS_OUTPUT.PUT_LINE('Call CN_SEAS_SCHEDULES completed validating the output');
    IF l_return_status <> 'S'  THEN
        --DBMS_OUTPUT.PUT_LINE('Updation on CN_SEAS_SCHEDULES Failed');
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SEAS_SCH_UPD_FAIL');
    	 FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR ;
    END IF;

    CN_SEASONALITIES_pkg.update_row
    (
          P_SEASONALITY_ID        => p_seasonalities_rec_type.seasonality_id,
          P_SEAS_SCHEDULE_ID      => p_seasonalities_rec_type.SEAS_SCHEDULE_ID,
          p_CAL_PER_INT_TYPE_ID   => FND_API.G_MISS_NUM,
          P_PERIOD_ID             => FND_API.G_MISS_NUM,
          P_PCT_SEASONALITY       => p_seasonalities_rec_type.pct_seasonality,
          P_OBJECT_VERSION_NUMBER => p_seasonalities_rec_type.OBJECT_VERSION_NUMBER
    );



   -- End of API body.
   << end_Update_Seasonalities >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Seasonalities  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Seasonalities ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Seasonalities ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_code := SQLCODE;
      IF l_error_code = -54 THEN
 	   x_return_status := FND_API.G_RET_STS_ERROR ;
   	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOCK_FAIL');
	    FND_MSG_PUB.Add;
	   END IF;
       ELSE
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	   END IF;
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Update_Seasonalities;


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
 )  IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Seasonalities';
      l_api_version  CONSTANT NUMBER  := 1.0;
      l_error_code NUMBER;
      l_seas_sch_id NUMBER;
      l_rec cn_seas_schedules_PVT.seas_schedules_rec_type;
      l_return_status VARCHAR2(1);
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(2000);
      l_sum NUMBER;

      CURSOR pct_seasonality_cur(p_seas_sch_id NUMBER) IS
      SELECT PCT_SEASONALITY FROM CN_SEASONALITIES
      WHERE seas_schedule_id = p_seas_sch_id;
BEGIN
   --DBMS_OUTPUT.PUT_LINE('Delete in progress');
    -- Standard Start of API savepoint
   SAVEPOINT   Validate_Seasonalities;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   -- API body
   l_sum := 0;


   FOR l_seas_pct IN pct_seasonality_cur(p_seas_schedule_rec_type.seas_schedule_id) LOOP
      l_sum := l_sum + l_seas_pct.pct_seasonality;
   END LOOP;

   -- DBMS_OUTPUT.PUT_LINE('SUM IS : ' || l_sum);

   IF (l_sum = 100) THEN
    --DBMS_OUTPUT.PUT_LINE('SUM IS(IF) : ' || l_sum);
    l_rec.seas_schedule_id := p_seas_schedule_rec_type.SEAS_SCHEDULE_ID;
    l_rec.validation_status := 'VALID';
    l_rec.object_version_number := p_seas_schedule_rec_type.object_version_number;
    SELECT NAME,DESCRIPTION,PERIOD_YEAR,START_DATE,END_DATE INTO l_rec.name,l_rec.description,
           l_rec.period_year,l_rec.start_date,L_rec.end_date from cn_seas_schedules
           where seas_schedule_id = p_seas_schedule_rec_type.SEAS_SCHEDULE_ID;

    cn_seas_schedules_PVT.Update_Seas_Schedule
    ( p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_FALSE,
      p_commit               => FND_API.G_FALSE,
      p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
      p_seas_schedules_rec_type => l_rec,
      x_return_status        => l_return_status ,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data
    );

   --DBMS_OUTPUT.PUT_LINE('STATUS IS ' || x_return_status);

   END IF;

   -- End of API body.
   << end_Validate_Seasonalities >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Validate_Seasonalities  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Validate_Seasonalities ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Validate_Seasonalities ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_code := SQLCODE;
      IF l_error_code = -54 THEN
 	   x_return_status := FND_API.G_RET_STS_ERROR ;
   	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOCK_FAIL');
	    FND_MSG_PUB.Add;
	   END IF;
       ELSE
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	   END IF;
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Validate_Seasonalities;


END cn_seasonalities_pvt;

/
