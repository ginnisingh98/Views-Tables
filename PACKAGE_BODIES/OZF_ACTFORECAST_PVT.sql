--------------------------------------------------------
--  DDL for Package Body OZF_ACTFORECAST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTFORECAST_PVT" AS
/* $Header: ozfvfctb.pls 120.2 2005/07/29 02:53:12 appldev ship $ */

---------------------------------------------------------------------------------------------------
--
-- NAME
--    OZF_ActForecast_PVT
--
-- HISTORY
-- 20-May-2000    tdonohoe@us     Created package.
-- 15-Jun-2000    tdonohoe@us     Modified package to include new FORECAST_TYPE column.
-- 15-Jun-2000    tdonohoe@us     Modified package to check for valid FORECAST_UOM_CODE values.
-- 11-Jul-2005    inanaiah        R12 changes for non-baseline basis
---------------------------------------------------------------------------------------------------

--
-- Global variables and constants.

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'OZF_ACTFORECAST_PVT'; -- Name of the current package.
G_DEBUG_FLAG 	     VARCHAR2(1)  := 'N';

OZF_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
OZF_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
OZF_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_ActForecast_rec
--
-- HISTORY
--    05/15/2000  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE Init_ActForecast_Rec(
   x_actforecast_rec  OUT NOCOPY  act_forecast_rec_type
)
IS
BEGIN

            x_actforecast_rec.forecast_id             := FND_API.g_miss_num;
	    x_actforecast_rec.arc_act_fcast_used_by   := FND_API.g_miss_char;
            x_actforecast_rec.act_fcast_used_by_id    := FND_API.g_miss_num;
            x_actforecast_rec.creation_date           := FND_API.g_miss_date;
            x_actforecast_rec.created_from            := FND_API.g_miss_char;
            x_actforecast_rec.created_by              := FND_API.g_miss_num;
            x_actforecast_rec.last_update_date        := FND_API.g_miss_date;
            x_actforecast_rec.last_updated_by         := FND_API.g_miss_num;
            x_actforecast_rec.last_update_login       := FND_API.g_miss_num;
            x_actforecast_rec.program_application_id  := FND_API.g_miss_num;
            x_actforecast_rec.program_id              := FND_API.g_miss_num;
            x_actforecast_rec.program_update_date     := FND_API.g_miss_date;
            x_actforecast_rec.request_id              := FND_API.g_miss_num;
            x_actforecast_rec.object_version_number   := FND_API.g_miss_num;
            x_actforecast_rec.hierarchy               := FND_API.g_miss_char;
            x_actforecast_rec.hierarchy_level         := FND_API.g_miss_char;
            x_actforecast_rec.level_value             := FND_API.g_miss_char;
            x_actforecast_rec.forecast_calendar       := FND_API.g_miss_char;
            x_actforecast_rec.period_level            := FND_API.g_miss_char;
            x_actforecast_rec.forecast_period_id      := FND_API.g_miss_num;
            x_actforecast_rec.forecast_date           := FND_API.g_miss_date;
            x_actforecast_rec.forecast_uom_code       := FND_API.g_miss_char;
            x_actforecast_rec.forecast_quantity       := FND_API.g_miss_num;
            x_actforecast_rec.forward_buy_quantity    := FND_API.g_miss_num;
            x_actforecast_rec.forward_buy_period      := FND_API.g_miss_char;
            x_actforecast_rec.cumulation_period_choice  := FND_API.g_miss_char;
            x_actforecast_rec.base_quantity             := FND_API.g_miss_num;
            x_actforecast_rec.context                   := FND_API.g_miss_char;
            x_actforecast_rec.attribute_category        := FND_API.g_miss_char;
            x_actforecast_rec.attribute1                := FND_API.g_miss_char;
            x_actforecast_rec.attribute2                := FND_API.g_miss_char;
            x_actforecast_rec.attribute3                := FND_API.g_miss_char;
            x_actforecast_rec.attribute4                := FND_API.g_miss_char;
            x_actforecast_rec.attribute5                := FND_API.g_miss_char;
            x_actforecast_rec.attribute6                := FND_API.g_miss_char;
            x_actforecast_rec.attribute7                := FND_API.g_miss_char;
            x_actforecast_rec.attribute8                := FND_API.g_miss_char;
            x_actforecast_rec.attribute9                := FND_API.g_miss_char;
            x_actforecast_rec.attribute10               := FND_API.g_miss_char;
            x_actforecast_rec.attribute11               := FND_API.g_miss_char;
            x_actforecast_rec.attribute12               := FND_API.g_miss_char;
            x_actforecast_rec.attribute13               := FND_API.g_miss_char;
            x_actforecast_rec.attribute14               := FND_API.g_miss_char;
            x_actforecast_rec.attribute15               := FND_API.g_miss_char;
            x_actforecast_rec.org_id                    := FND_API.g_miss_num;
            x_actforecast_rec.forecast_remaining_quantity  := FND_API.g_miss_num;
            x_actforecast_rec.forecast_remaining_percent   := FND_API.g_miss_num;
            x_actforecast_rec.base_quantity_type           := FND_API.g_miss_char;
            x_actforecast_rec.forecast_spread_type         := FND_API.g_miss_char;
            x_actforecast_rec.dimention1         := FND_API.g_miss_char;
            x_actforecast_rec.dimention2         := FND_API.g_miss_char;
            x_actforecast_rec.dimention3         := FND_API.g_miss_char;
            x_actforecast_rec.last_scenario_id   := FND_API.g_miss_num;
            x_actforecast_rec.freeze_flag        := FND_API.g_miss_char;
            x_actforecast_rec.comments        := FND_API.g_miss_char;
            x_actforecast_rec.price_list_id        := FND_API.g_miss_num;
            x_actforecast_rec.base_quantity_start_date := FND_API.g_miss_date;
            x_actforecast_rec.base_quantity_end_date := FND_API.g_miss_date;
            x_actforecast_rec.base_quantity_ref := FND_API.g_miss_char;
            x_actforecast_rec.offer_code:= FND_API.g_miss_char;

END;


-- Start of comments
-- NAME
--    Default_ActForecast
--
--
-- PURPOSE
--    Defaults the Activty Forecast.
--
-- NOTES
--
-- HISTORY
-- 27-Apr-2000	tdonohoe  Created.
--
-- End of comments


PROCEDURE Default_ActForecast(
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_act_forecast_rec    IN  act_forecast_rec_type,
   p_validation_mode        IN  VARCHAR2 ,
   x_complete_rec           OUT NOCOPY act_forecast_rec_type,
   x_return_status 	    OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
)
IS

BEGIN
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_complete_rec := p_act_forecast_rec;

     -- Insert Mode
     IF ((p_validation_mode = JTF_PLSQL_API.g_create) OR (p_validation_mode = JTF_PLSQL_API.g_update)) THEN

           IF  p_act_forecast_rec.forecast_calendar IS NULL  THEN
	        x_complete_rec.forecast_calendar := 'NONE';
	   END IF;

	   IF  p_act_forecast_rec.base_quantity_type IS NULL  THEN
	        x_complete_rec.base_quantity_type := 'LAST_YEAR_SAME_PERIOD';
	   END IF;

	   IF  p_act_forecast_rec.forecast_spread_type IS NULL  THEN
	        x_complete_rec.forecast_spread_type := 'BASELINE_RATIO';
	   END IF;

	   IF  p_act_forecast_rec.forecast_type IS NULL  THEN
	        x_complete_rec.forecast_type := 'NONE';
	   END IF;

           IF p_act_forecast_rec.freeze_flag IS NULL THEN
                x_complete_rec.freeze_flag := 'N';
           END IF;

     END IF;

END Default_ActForecast ;

-- Start of comments
-- NAME
--    Create_ActForecast
--
--
-- PURPOSE
--    Creates an Activity Forecast.

--
-- NOTES
--
-- HISTORY
-- 18-Apr-2000  tdonohoe@us    Created.
-- 15-Jun-2000 tdonohoe Modified to include new column FORECAST_TYPE.
--
-- End of comments

PROCEDURE Create_ActForecast (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_forecast_rec           IN  act_forecast_rec_type,
   x_forecast_id                OUT NOCOPY NUMBER
)
IS
   --
   -- Standard API information constants.
   --
   L_API_VERSION                  CONSTANT NUMBER := 1.0;
   L_API_NAME                     CONSTANT VARCHAR2(30) := 'CREATE_ACTFORECAST';
   L_FULL_NAME   	          CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;


   l_return_status                VARCHAR2(1); -- Return value from procedures.
   l_act_forecast_rec             act_forecast_rec_type := p_act_forecast_rec;
   l_act_forecast_count           NUMBER ;

   l_sql_err_msg varchar2(4000);

   CURSOR c_act_forecast_count(l_forecast_id IN NUMBER) IS
    SELECT count(*)
    FROM   ozf_act_forecasts_all
    WHERE  forecast_id = l_forecast_id;

   CURSOR c_act_forecast_id IS
   SELECT ozf_act_forecasts_all_s.NEXTVAL
   FROM   dual;

BEGIN
   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_ActForecast_Pvt;

   IF (OZF_DEBUG_HIGH_ON) THEN



   OZF_Utility_PVT.Debug_Message(l_full_name||': start');

   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

   Default_ActForecast
       ( p_init_msg_list        => p_init_msg_list,
   	 p_act_forecast_rec  => p_act_forecast_rec,
   	 p_validation_mode      => JTF_PLSQL_API.g_create,
   	 x_complete_rec         => l_act_forecast_rec,
   	 x_return_status        => l_return_status,
   	 x_msg_count            => x_msg_count,
   	 x_msg_data             => x_msg_data  ) ;



   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   --
   -- Validate the record before inserting.
   --


   IF l_act_forecast_rec.forecast_id IS NULL THEN
   	  LOOP
   	  --
   	  -- Set the value for the PK.
   	  	 OPEN c_act_forecast_id;
   		 FETCH c_act_forecast_id INTO l_act_forecast_rec.forecast_id;
   		 CLOSE c_act_forecast_id;

		 OPEN  c_act_forecast_count(l_act_forecast_rec.forecast_id);
		 FETCH c_act_forecast_count INTO l_act_forecast_count ;
		 CLOSE c_act_forecast_count ;

		 EXIT WHEN l_act_forecast_count = 0 ;
	  END LOOP ;
   END IF;



   Validate_ActForecast (
      p_api_version               => l_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data,
      x_return_status             => l_return_status,
      p_act_forecast_rec          => l_act_forecast_rec
   );

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --
   -- Debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;


   --
   -- Insert into the base table.
   --

   INSERT INTO ozf_act_forecasts_all
              (forecast_id
    	      ,forecast_type
              ,arc_act_fcast_used_by
              ,act_fcast_used_by_id
              ,creation_date
              ,created_from
              ,created_by
              ,last_update_date
              ,last_updated_by
              ,last_update_login
              ,program_application_id
              ,program_id
              ,program_update_date
              ,request_id
              ,object_version_number
              ,hierarchy
              ,hierarchy_level
              ,level_value
              ,forecast_calendar
              ,period_level
              ,forecast_period_id
              ,forecast_date
              ,forecast_uom_code
              ,forecast_quantity
              ,forward_buy_quantity
              ,forward_buy_period
              ,cumulation_period_choice
              ,base_quantity
              ,context
              ,attribute_category
              ,attribute1
              ,attribute2
              ,attribute3
              ,attribute4
              ,attribute5
              ,attribute6
              ,attribute7
              ,attribute8
              ,attribute9
              ,attribute10
              ,attribute11
              ,attribute12
              ,attribute13
              ,attribute14
              ,attribute15
              ,org_id
              ,forecast_remaining_quantity
              ,forecast_remaining_percent
              ,base_quantity_type
              ,forecast_spread_type
              ,dimention1
              ,dimention2
              ,dimention3
              ,last_scenario_id
              ,freeze_flag
	          ,comments
	          ,price_list_id
              ,base_quantity_start_date
              ,base_quantity_end_date
              ,base_quantity_ref
              ,offer_code
   )
   VALUES(     l_act_forecast_rec.forecast_id
              ,l_act_forecast_rec.forecast_type
              ,l_act_forecast_rec.arc_act_fcast_used_by
              ,l_act_forecast_rec.act_fcast_used_by_id
              ,SYSDATE
              ,l_act_forecast_rec.created_from
              ,FND_GLOBAL.User_ID
              ,SYSDATE
              ,FND_GLOBAL.User_ID
              ,FND_GLOBAL.Conc_Login_ID
              ,l_act_forecast_rec.program_application_id
              ,l_act_forecast_rec.program_id
              ,l_act_forecast_rec.program_update_date
              ,l_act_forecast_rec.request_id
              ,1 -- object_version_number
              ,l_act_forecast_rec.hierarchy
              ,l_act_forecast_rec.hierarchy_level
              ,l_act_forecast_rec.level_value
              ,l_act_forecast_rec.forecast_calendar
              ,l_act_forecast_rec.period_level
              ,l_act_forecast_rec.forecast_period_id
              ,l_act_forecast_rec.forecast_date
              ,l_act_forecast_rec.forecast_uom_code
              ,l_act_forecast_rec.forecast_quantity
              ,l_act_forecast_rec.forward_buy_quantity
              ,l_act_forecast_rec.forward_buy_period
              ,l_act_forecast_rec.cumulation_period_choice
              ,l_act_forecast_rec.base_quantity
              ,l_act_forecast_rec.context
              ,l_act_forecast_rec.attribute_category
              ,l_act_forecast_rec.attribute1
              ,l_act_forecast_rec.attribute2
              ,l_act_forecast_rec.attribute3
              ,l_act_forecast_rec.attribute4
              ,l_act_forecast_rec.attribute5
              ,l_act_forecast_rec.attribute6
              ,l_act_forecast_rec.attribute7
              ,l_act_forecast_rec.attribute8
              ,l_act_forecast_rec.attribute9
              ,l_act_forecast_rec.attribute10
              ,l_act_forecast_rec.attribute11
              ,l_act_forecast_rec.attribute12
              ,l_act_forecast_rec.attribute13
              ,l_act_forecast_rec.attribute14
              ,l_act_forecast_rec.attribute15
              ,TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10)) -- org_id
              ,l_act_forecast_rec.forecast_remaining_quantity
              ,l_act_forecast_rec.forecast_remaining_percent
              ,l_act_forecast_rec.base_quantity_type
              ,l_act_forecast_rec.forecast_spread_type
              ,l_act_forecast_rec.dimention1
              ,l_act_forecast_rec.dimention2
              ,l_act_forecast_rec.dimention3
              ,l_act_forecast_rec.last_scenario_id
              ,l_act_forecast_rec.freeze_flag
	          ,l_act_forecast_rec.comments
	          ,l_act_forecast_rec.price_list_id
              ,l_act_forecast_rec.base_quantity_start_date
              ,l_act_forecast_rec.base_quantity_end_date
              ,l_act_forecast_rec.base_quantity_ref
              ,l_act_forecast_rec.offer_code);


   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- finish

   --
   -- Set OUT NOCOPY value.
   --
   x_forecast_id := l_act_forecast_rec.forecast_id;

   --
   -- End API Body.
   --

   --
   -- Standard check for commit request.
   --
   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

      --
   -- Add success message to message list.
   --

   IF (OZF_DEBUG_HIGH_ON) THEN



   OZF_Utility_PVT.debug_message(l_full_name ||': end Success');

   END IF;




EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN


      ROLLBACK TO Create_ActForecast_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



      ROLLBACK TO Create_ActForecast_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN


      ROLLBACK TO Create_ActForecast_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Create_ActForecast;


-- Start of comments
-- NAME
--    Update_ActForecast
--
-- PURPOSE
--   Updates an entry in the  OZF_ACT_FORECASTS_ALL table
--
-- NOTES
--
-- HISTORY
-- 18-Apr-2000  tdonohoe  Created.
-- 15-Jun-2000 tdonohoe Modified to include new column FORECAST_TYPE.
--
-- End of comments

PROCEDURE Update_ActForecast (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_forecast_rec           IN 	act_forecast_rec_type
)
IS
   L_API_VERSION                CONSTANT NUMBER := 1.0;
   L_API_NAME                   CONSTANT VARCHAR2(30) := 'UPDATE_ACTFORECAST';
   L_FULL_NAME   		CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status              VARCHAR2(1);
   l_act_forecast_rec           act_forecast_rec_type := p_act_forecast_rec;
   l_temp_act_forecast_rec      act_forecast_rec_type;

BEGIN

   --
   -- Initialize savepoint.
   --
   SAVEPOINT Update_ActForecast_Pvt;

   --
   -- Output debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body
   --
   -- Debug Message


   Default_ActForecast
       ( p_init_msg_list        => p_init_msg_list,
   	 p_act_forecast_rec  => p_act_forecast_rec,
   	 p_validation_mode      => JTF_PLSQL_API.G_UPDATE,
   	 x_complete_rec         => l_act_forecast_rec,
   	 x_return_status        => l_return_status,
   	 x_msg_count            => x_msg_count,
   	 x_msg_data             => x_msg_data  ) ;

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF (OZF_DEBUG_HIGH_ON) THEN





   OZF_Utility_PVT.debug_message(l_full_name ||': validate ');


   END IF;



   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name ||' 1 ' || l_act_forecast_rec.forecast_id);
   END IF;
      Validate_ActFcst_Items(
         p_act_forecast_rec  => l_act_forecast_rec,
         p_validation_mode      => JTF_PLSQL_API.g_update,
         x_return_status        => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name ||' 2 ' || p_act_forecast_rec.forecast_id);
   END IF;
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- replace g_miss_char/num/date with current column values

   l_temp_act_forecast_rec := l_act_forecast_rec ;

   Complete_ActFcst_Rec(p_act_forecast_rec => l_temp_act_forecast_rec,
                        x_complete_fcst_rec => l_act_forecast_rec);


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN

      Validate_ActFcst_Rec(
       	        p_act_forecast_rec     => p_act_forecast_rec,
                p_complete_fcst_rec    => l_act_forecast_rec,
                x_return_status  	=> l_return_status );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;


   IF (OZF_DEBUG_HIGH_ON) THEN





   OZF_Utility_PVT.debug_message(l_full_name ||': Update Activity Metric Facts Table');


   END IF;


   UPDATE     ozf_act_forecasts_all SET
              object_version_number =  object_version_number +1,
	      forecast_type         =  l_act_forecast_rec.forecast_type,
	      arc_act_fcast_used_by =  l_act_forecast_rec.arc_act_fcast_used_by,
              act_fcast_used_by_id  =  l_act_forecast_rec.act_fcast_used_by_id,
              created_from          =  l_act_forecast_rec.created_from,
              hierarchy             =  l_act_forecast_rec.hierarchy,
              hierarchy_level       =  l_act_forecast_rec.hierarchy_level,
              level_value           =  l_act_forecast_rec.level_value,
              forecast_calendar     =  l_act_forecast_rec.forecast_calendar,
              period_level          =  l_act_forecast_rec.period_level,
              forecast_period_id    =  l_act_forecast_rec.forecast_period_id ,
              forecast_date         =  l_act_forecast_rec.forecast_date,
              forecast_uom_code     =  l_act_forecast_rec.forecast_uom_code,
              forecast_quantity     =  l_act_forecast_rec.forecast_quantity,
              forward_buy_quantity  =  l_act_forecast_rec.forward_buy_quantity,
              forward_buy_period         =  l_act_forecast_rec.forward_buy_period,
              cumulation_period_choice   =  l_act_forecast_rec.cumulation_period_choice,
              base_quantity              =  l_act_forecast_rec.base_quantity,
              context                    =  l_act_forecast_rec.context,
              attribute_category         =  l_act_forecast_rec.attribute_category,
              attribute1                 =  l_act_forecast_rec.attribute1,
              attribute2                 =  l_act_forecast_rec.attribute2,
              attribute3                 =  l_act_forecast_rec.attribute3,
              attribute4                 =  l_act_forecast_rec.attribute4,
              attribute5                 =  l_act_forecast_rec.attribute5,
              attribute6                 =  l_act_forecast_rec.attribute6,
              attribute7                 =  l_act_forecast_rec.attribute7,
              attribute8                 =  l_act_forecast_rec.attribute8,
              attribute9                 =  l_act_forecast_rec.attribute9,
              attribute10                =  l_act_forecast_rec.attribute10,
              attribute11                =  l_act_forecast_rec.attribute11,
              attribute12                =  l_act_forecast_rec.attribute12,
              attribute13                =  l_act_forecast_rec.attribute13,
              attribute14                =  l_act_forecast_rec.attribute14,
              attribute15                =  l_act_forecast_rec.attribute15,
              org_id                     =  l_act_forecast_rec.org_id,
              forecast_remaining_quantity   =  l_act_forecast_rec.forecast_remaining_quantity,
              forecast_remaining_percent    =  l_act_forecast_rec.forecast_remaining_percent,
              base_quantity_type            =  l_act_forecast_rec.base_quantity_type,
              forecast_spread_type          =  l_act_forecast_rec.forecast_spread_type,
              dimention1          =  l_act_forecast_rec.dimention1,
              dimention2          =  l_act_forecast_rec.dimention2,
              dimention3          =  l_act_forecast_rec.dimention3,
              last_scenario_id    =  l_act_forecast_rec.last_scenario_id,
              freeze_flag         =  l_act_forecast_rec.freeze_flag,
	      comments            =  l_act_forecast_rec.comments,
	      price_list_id       =  l_act_forecast_rec.price_list_id
  Where       forecast_id                =  l_act_forecast_rec.forecast_id
  And         object_version_number      =  l_act_forecast_rec.object_version_number;


    IF  (SQL%NOTFOUND)
    THEN
      --
      -- Add error message to API message list.
      --
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
    END IF;


    --
   -- End API Body
   --

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   --
   -- Debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Update_ActForecast_pvt;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_ActForecast_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN

      ROLLBACK TO Update_ActForecast_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Update_ActForecast;

-- Start of comments
-- NAME
--    Delete_ActForecast
--
-- PURPOSE
--    Deletes an entry in the ozf_act_forecasts_all table.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.
--
-- End of comments

PROCEDURE Delete_ActForecast (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_forecast_id              IN  NUMBER,
   p_object_version_number    IN  NUMBER
)
IS
   L_API_VERSION              CONSTANT NUMBER := 1.0;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'DELETE_ACTFORECAST';
   L_FULL_NAME   	      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status            VARCHAR2(1);

BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Delete_ActForecast_pvt;

   --
   -- Output debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

      -- Debug message.
   	  IF (OZF_DEBUG_HIGH_ON) THEN

   	  OZF_Utility_PVT.debug_message(l_full_name ||': delete with Validation');
   	  END IF;


         IF (OZF_DEBUG_HIGH_ON) THEN





         OZF_Utility_PVT.debug_message('forecast id '||to_char(p_forecast_id));


         END IF;
	 IF (OZF_DEBUG_HIGH_ON) THEN

	 OZF_Utility_PVT.debug_message('object version number '||to_char(p_object_version_number));
	 END IF;

	 DELETE from ozf_act_metric_facts_all
         WHERE act_metric_used_by_id = p_forecast_id
         AND  arc_act_metric_used_by = 'FCST';

         DELETE from ozf_act_metrics_all
         WHERE act_metric_used_by_id = p_forecast_id
         AND  arc_act_metric_used_by = 'FCST';

         DELETE from ozf_act_forecasts_all
         WHERE forecast_id = p_forecast_id;

         IF (SQL%NOTFOUND) THEN
	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN

		FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         	FND_MSG_PUB.add;
      	 RAISE FND_API.g_exc_error;
      	 END IF;
	 END IF;



   --
   -- End API Body.
   --

   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Debug message.
   --
   	  IF (OZF_DEBUG_HIGH_ON) THEN

   	  OZF_Utility_PVT.debug_message(l_full_name ||': End');
   	  END IF;


   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_ActForecast_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_ActForecast_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_ActForecast_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Delete_ActForecast;


-- Start of comments
-- NAME
--    Lock_ActForecast
--
-- PURPOSE
--    Lock the given row in OZF_ACT_FORECASTS_ALL table.
--
-- NOTES
--
-- HISTORY
-- 19-Apr-2000 tdonohoe  Created.
--
-- End of comments

PROCEDURE Lock_ActForecast (
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_forecast_id             IN  NUMBER,
   p_object_version_number   IN  NUMBER
)
IS
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'LOCK_ACTFORECAST';
   L_FULL_NAME    	   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_forecast_id    NUMBER;

   CURSOR c_act_forecast_info IS
   SELECT forecast_id
   FROM ozf_act_forecasts_all
   WHERE forecast_id = p_forecast_id
   AND object_version_number = p_object_version_number
   FOR UPDATE OF forecast_id NOWAIT;

BEGIN
   --
   -- Output debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN c_act_forecast_info;
   FETCH c_act_forecast_info INTO l_forecast_id;
   IF  (c_act_forecast_info%NOTFOUND)
   THEN
      CLOSE c_act_forecast_info;
	  -- Error, check the msg level and added an error message to the
	  -- API message list
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_forecast_info;


   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   --
   -- Debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OZF_Utility_PVT.RESOURCE_LOCKED THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCE_LOCKED');
		   FND_MSG_PUB.add;
	  END IF;

      FND_MSG_PUB.Count_And_Get (
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data,
	     p_encoded	    =>      FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
		 p_encoded	    =>      FND_API.G_FALSE
		       );
END Lock_ActForecast;




-- Start of comments
-- NAME
--   Validate_ActForecast
--
-- PURPOSE
--   Validation API for Activity metric facts table.
--

-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.

--
-- End of comments

PROCEDURE Validate_ActForecast (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_forecast_rec        IN  act_forecast_rec_type
)
IS
   L_API_VERSION               CONSTANT NUMBER := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'VALIDATE_ACTFORECAST';
   L_FULL_NAME   	       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status             VARCHAR2(1);

BEGIN
   --
   -- Output debug message.
   --
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

   IF (OZF_DEBUG_HIGH_ON) THEN



   OZF_Utility_PVT.debug_message(l_full_name||': Validate items');

   END IF;

   -- Validate required items in the record.
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

       Validate_ActFcst_Items(
         p_act_forecast_rec     => p_act_forecast_rec,
         p_validation_mode 	   => JTF_PLSQL_API.g_create,
         x_return_status   	   => l_return_status
      );

	  -- If any errors happen abort API.
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	  END IF;
   END IF;

  IF (OZF_DEBUG_HIGH_ON) THEN



  OZF_Utility_PVT.debug_message(l_full_name||': check record');

  END IF;

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_ActFcst_Rec(
         p_act_forecast_rec   => p_act_forecast_rec,
         p_complete_fcst_rec   	 => NULL,
         x_return_status  	 => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             IF (OZF_DEBUG_HIGH_ON) THEN

             OZF_Utility_PVT.debug_message(l_full_name||': error in  check record');
             END IF;
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
          IF (OZF_DEBUG_HIGH_ON) THEN

          OZF_Utility_PVT.debug_message(l_full_name||': error in  check record');
          END IF;
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (OZF_DEBUG_HIGH_ON) THEN



   OZF_Utility_PVT.debug_message(l_full_name||': after check record');

   END IF;


   --
   -- End API Body.
   --

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT NOCOPY variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   IF (OZF_DEBUG_HIGH_ON) THEN



   OZF_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Validate_ActForecast;


--
-- NAME
--    Complete_Forecast_Rec
--
-- PURPOSE
--   Returns the Initialized Activity Forecast Record
--
-- NOTES
--
-- HISTORY
-- 21-Apr-2000 tdonohoe Created.
-- 15-Jun-2000 tdonohoe Modified to include new column FORECAST_TYPE.
--
PROCEDURE Complete_ActFcst_Rec(
   p_act_forecast_rec    IN  act_forecast_rec_type,
   x_complete_fcst_rec   OUT NOCOPY act_forecast_rec_type
)
IS
   CURSOR c_act_forecast IS
   SELECT *
   FROM ozf_act_forecasts_all
   WHERE forecast_id = p_act_forecast_rec.forecast_id;

   l_act_forecast_rec  c_act_forecast%ROWTYPE;
BEGIN

   x_complete_fcst_rec := p_act_forecast_rec;

   IF (OZF_DEBUG_HIGH_ON) THEN



   OZF_Utility_PVT.debug_message('forecast_id before exception  : ' || p_act_forecast_rec.forecast_id);

   END IF;
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message('forecast_id before exception  : ' || x_complete_fcst_rec.forecast_id);
   END IF;

   OPEN c_act_forecast;
   FETCH c_act_forecast INTO l_act_forecast_rec;
   IF c_act_forecast%NOTFOUND THEN
      CLOSE c_act_forecast;
   IF (OZF_DEBUG_HIGH_ON) THEN

   OZF_Utility_PVT.debug_message('forecast_id before raising exception  : ' || x_complete_fcst_rec.forecast_id);
   END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_act_forecast;

   IF (OZF_DEBUG_HIGH_ON) THEN



   OZF_Utility_PVT.debug_message('forecast_id before raising : ' || p_act_forecast_rec.forecast_id);

   END IF;


   IF p_act_forecast_rec.forecast_id  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.forecast_id  := l_act_forecast_rec.forecast_id;
   END IF;

   IF p_act_forecast_rec.forecast_type  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.forecast_type := l_act_forecast_rec.forecast_type;
   END IF;

   IF p_act_forecast_rec.arc_act_fcast_used_by  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.arc_act_fcast_used_by := l_act_forecast_rec.arc_act_fcast_used_by;
   END IF;

   IF p_act_forecast_rec.act_fcast_used_by_id   = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.act_fcast_used_by_id  := l_act_forecast_rec.act_fcast_used_by_id ;
   END IF;

   IF p_act_forecast_rec.creation_date  = FND_API.G_MISS_DATE THEN
      x_complete_fcst_rec.creation_date := l_act_forecast_rec.creation_date;
   END IF;

   IF p_act_forecast_rec.created_from  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.created_from := l_act_forecast_rec.created_from;
   END IF;

   IF p_act_forecast_rec.created_by  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.created_by := l_act_forecast_rec.created_by;
   END IF;

   IF p_act_forecast_rec.last_update_date  = FND_API.G_MISS_DATE THEN
      x_complete_fcst_rec.last_update_date := l_act_forecast_rec.last_update_date;
   END IF;

   IF p_act_forecast_rec.last_updated_by   = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.last_updated_by  := l_act_forecast_rec.last_updated_by ;
   END IF;

   IF p_act_forecast_rec.last_update_login  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.last_update_login := l_act_forecast_rec.last_update_login;
   END IF;

   IF p_act_forecast_rec.program_application_id  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.program_application_id := l_act_forecast_rec.program_application_id;
   END IF;

   IF p_act_forecast_rec.program_id  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.program_id := l_act_forecast_rec.program_id;
   END IF;

   IF p_act_forecast_rec.program_update_date  = FND_API.G_MISS_DATE THEN
      x_complete_fcst_rec.program_update_date := l_act_forecast_rec.program_update_date;
   END IF;

   IF p_act_forecast_rec.request_id   = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.request_id  := l_act_forecast_rec.request_id ;
   END IF;

   IF p_act_forecast_rec.hierarchy  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.hierarchy := l_act_forecast_rec.hierarchy;
   END IF;

   IF p_act_forecast_rec.hierarchy_level  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.hierarchy_level := l_act_forecast_rec.hierarchy_level;
   END IF;

   IF p_act_forecast_rec.level_value  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.level_value := l_act_forecast_rec.level_value;
   END IF;

   IF p_act_forecast_rec.forecast_calendar  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.forecast_calendar := l_act_forecast_rec.forecast_calendar;
   END IF;

   IF p_act_forecast_rec.period_level  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.period_level := l_act_forecast_rec.period_level;
   END IF;

   IF p_act_forecast_rec.forecast_period_id  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.forecast_period_id := l_act_forecast_rec.forecast_period_id;
   END IF;

   IF p_act_forecast_rec.forecast_date  = FND_API.G_MISS_DATE THEN
      x_complete_fcst_rec.forecast_date := l_act_forecast_rec.forecast_date;
   END IF;

   IF p_act_forecast_rec.forecast_uom_code  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.forecast_uom_code := l_act_forecast_rec.forecast_uom_code;
   END IF;

   IF p_act_forecast_rec.forecast_quantity  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.forecast_quantity := l_act_forecast_rec.forecast_quantity;
   END IF;

   IF p_act_forecast_rec.forward_buy_quantity  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.forward_buy_quantity := l_act_forecast_rec.forward_buy_quantity;
   END IF;

   IF p_act_forecast_rec.forward_buy_period  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.forward_buy_period := l_act_forecast_rec.forward_buy_period;
   END IF;

   IF p_act_forecast_rec.cumulation_period_choice  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.cumulation_period_choice := l_act_forecast_rec.cumulation_period_choice;
   END IF;

   IF p_act_forecast_rec.base_quantity   = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.base_quantity  := l_act_forecast_rec.base_quantity ;
   END IF;

   IF p_act_forecast_rec.context  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.context := l_act_forecast_rec.context;
   END IF;

   IF p_act_forecast_rec.attribute_category  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute_category := l_act_forecast_rec.attribute_category;
   END IF;

   IF p_act_forecast_rec.attribute1  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute1 := l_act_forecast_rec.attribute1;
   END IF;

   IF p_act_forecast_rec.attribute2  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute2 := l_act_forecast_rec.attribute2;
   END IF;

   IF p_act_forecast_rec.attribute3  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute3 := l_act_forecast_rec.attribute3;
   END IF;

   IF p_act_forecast_rec.attribute4  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute4 := l_act_forecast_rec.attribute4;
   END IF;

   IF p_act_forecast_rec.attribute5  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute5 := l_act_forecast_rec.attribute5;
   END IF;

   IF p_act_forecast_rec.attribute6  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute6 := l_act_forecast_rec.attribute6;
   END IF;

   IF p_act_forecast_rec.attribute7  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute7 := l_act_forecast_rec.attribute7;
   END IF;

   IF p_act_forecast_rec.attribute8  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute8 := l_act_forecast_rec.attribute8;
   END IF;

   IF p_act_forecast_rec.attribute9  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute9 := l_act_forecast_rec.attribute9;
   END IF;

   IF p_act_forecast_rec.attribute10  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute10 := l_act_forecast_rec.attribute10;
   END IF;

   IF p_act_forecast_rec.attribute11  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute11 := l_act_forecast_rec.attribute11;
   END IF;

   IF p_act_forecast_rec.attribute12  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute12 := l_act_forecast_rec.attribute12;
   END IF;

   IF p_act_forecast_rec.attribute13  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute13 := l_act_forecast_rec.attribute13;
   END IF;

   IF p_act_forecast_rec.attribute14  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute14 := l_act_forecast_rec.attribute14;
   END IF;

   IF p_act_forecast_rec.attribute15  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.attribute15 := l_act_forecast_rec.attribute15;
   END IF;

   IF p_act_forecast_rec.org_id  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.org_id := l_act_forecast_rec.org_id;
   END IF;

   IF p_act_forecast_rec.forecast_remaining_quantity  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.forecast_remaining_quantity := l_act_forecast_rec.forecast_remaining_quantity;
   END IF;

   IF p_act_forecast_rec.forecast_remaining_percent  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.forecast_remaining_percent := l_act_forecast_rec.forecast_remaining_percent;
   END IF;

   IF p_act_forecast_rec.base_quantity_type  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.base_quantity_type := l_act_forecast_rec.base_quantity_type;
   END IF;

   IF p_act_forecast_rec.forecast_spread_type  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.forecast_spread_type := l_act_forecast_rec.forecast_spread_type;
   END IF;

   IF p_act_forecast_rec.dimention1  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.dimention1 := l_act_forecast_rec.dimention1;
   END IF;

   IF p_act_forecast_rec.dimention2  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.dimention2 := l_act_forecast_rec.dimention2;
   END IF;

   IF p_act_forecast_rec.dimention3  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.dimention3 := l_act_forecast_rec.dimention3;
   END IF;

   IF p_act_forecast_rec.last_scenario_id  = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.last_scenario_id := l_act_forecast_rec.last_scenario_id;
   END IF;

   IF p_act_forecast_rec.freeze_flag  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.freeze_flag := l_act_forecast_rec.freeze_flag;
   END IF;

   IF p_act_forecast_rec.comments  = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.comments := l_act_forecast_rec.comments;
   END IF;

   IF p_act_forecast_rec.price_list_id   = FND_API.G_MISS_NUM THEN
      x_complete_fcst_rec.price_list_id  := l_act_forecast_rec.price_list_id ;
   END IF;

   IF p_act_forecast_rec.base_quantity_start_date = FND_API.G_MISS_DATE THEN
      x_complete_fcst_rec.base_quantity_start_date := l_act_forecast_rec.base_quantity_start_date;
    END IF;
    IF p_act_forecast_rec.base_quantity_end_date = FND_API.G_MISS_DATE THEN
      x_complete_fcst_rec.base_quantity_end_date := l_act_forecast_rec.base_quantity_end_date;
    END IF;
    IF p_act_forecast_rec.base_quantity_ref = FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.base_quantity_ref :=  l_act_forecast_rec.base_quantity_ref;
    END IF;
    IF p_act_forecast_rec.offer_code= FND_API.G_MISS_CHAR THEN
      x_complete_fcst_rec.offer_code :=  l_act_forecast_rec.offer_code;
    END IF;

END Complete_ActFcst_Rec ;


-- Start of comments.
--
-- NAME
--    Check_Req_ActFcst_Items
--
-- PURPOSE
--    Validate required forecast items.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.
-- 15-Jun-2000 tdonohoe  Modified to include new column FORECAST_TYPE.
--
-- End of comments.

PROCEDURE Check_Req_ActFcst_Items (
   p_act_forecast_rec  IN act_forecast_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --FORECAST_TYPE

   IF p_act_forecast_rec.forecast_type IS NULL
   THEN
   	  -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FCST_MISSING_TYPE');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --ARC_ACT_FCAST_USED_BY

   IF p_act_forecast_rec.arc_act_fcast_used_by IS NULL
   THEN
   	  -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FCST_MISSING_ARC_USED_FOR');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --ACT_FCAST_USED_BY_ID

   IF p_act_forecast_rec.act_fcast_used_by_id IS NULL
   THEN
   	  -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FCST_MISSING_ARC_USED_FOR');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --FORECAST_CALENDAR

   IF p_act_forecast_rec.forecast_calendar IS NULL
   THEN
   	  -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FCST_MISSING_CALENDAR');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- FORECAST_UOM_CODE

   IF p_act_forecast_rec.forecast_uom_code IS NULL
   THEN
   	  -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('OZF', 'OZF_FCST_MISSING_UOM_CODE');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;



EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END Check_Req_ActFcst_Items;


--
-- Start of comments.
--
-- NAME
--    Check_ActFcst_UK_Items
--
-- PURPOSE
--    Perform Uniqueness check for Activity metric facts.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000	tdonohoe Created.
--
-- End of comments.


PROCEDURE Check_ActFcst_UK_Items(
   p_act_forecast_rec    IN  act_forecast_rec_type,
   p_validation_mode 	 IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   	 OUT NOCOPY VARCHAR2
)
IS
   l_where_clause VARCHAR2(2000); -- Used By Check_Uniqueness

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For Create_ActForecast, check if a Forecast already exists
   -- For the given object

   IF p_validation_mode = JTF_PLSQL_API.g_create
   THEN

      l_where_clause := ' arc_act_fcast_used_by = '||p_act_forecast_rec.arc_act_fcast_used_by ;
      l_where_clause := l_where_clause ||
                        ' act_fcast_used_by_id = '||p_act_forecast_rec.act_fcast_used_by_id ;
      l_where_clause := l_where_clause ||
                        ' last_scenario_id = '||p_act_forecast_rec.last_scenario_id ;

      IF OZF_Utility_PVT.Check_Uniqueness(
	  	 	p_table_name      => 'ozf_act_forecasts_all',
			p_where_clause    => l_where_clause
			) = FND_API.g_false
		THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
			THEN
            FND_MESSAGE.set_name('OZF', 'OZF_FCST_DUP_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_ActFcst_Uk_Items;


--
-- Start of comments.
--
-- NAME
--    Check_ActFcst_Items
--
-- PURPOSE
--    Perform item level validation for Activity metric facts.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Check_ActFcst_Items (
   p_act_forecast_rec IN  act_forecast_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
   l_item_name                   VARCHAR2(30);  -- Used to standardize error messages.
   l_act_forecast_rec         act_forecast_rec_type := p_act_forecast_rec;
   l_return_status               VARCHAR2(1);


   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
   l_lookup_type                 VARCHAR2(30);



BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --FORECAST_TYPE
   IF l_act_forecast_rec.forecast_type <> FND_API.G_MISS_CHAR THEN

            IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'OZF_FCAST_TYPE',
            p_lookup_code => l_act_forecast_rec.forecast_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_FCST_INVALID_TYPE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

   -- ARC_ACT_FCAST_USED_BY

   IF l_act_forecast_rec.arc_act_fcast_used_by <> FND_API.G_MISS_CHAR THEN
      IF l_act_forecast_rec.arc_act_fcast_used_by not in ( 'CAMP','OFFR')

      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('OZF', 'OZF_FCST_INVALID_USED_BY');
            FND_MSG_PUB.Add;
         END IF;

	 x_return_status := FND_API.G_RET_STS_ERROR;
 	 RETURN;
      END IF;
   END IF;

   --BASE_QUANTITY_TYPE
   IF l_act_forecast_rec.base_quantity_type <> FND_API.G_MISS_CHAR AND l_act_forecast_rec.base_quantity_type IS NOT NULL THEN

            IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'OZF_FCAST_BASE_VOL_SOURCE',
            p_lookup_code => l_act_forecast_rec.base_quantity_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_FSCT_INVALID_BASE_QTY');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;


   --FORECAST_SPREAD_TYPE
   IF l_act_forecast_rec.forecast_spread_type <> FND_API.G_MISS_CHAR AND l_act_forecast_rec.forecast_spread_type IS NOT NULL THEN

      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'OZF_FCAST_SPREAD',
            p_lookup_code => l_act_forecast_rec.forecast_spread_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_FSCT_INVALID_SPREAD_TYPE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


   END IF;


   --FORECAST_UOM_CODE
/* -- This value is being validated in the jsp page thru a LOV
   IF l_act_forecast_rec.forecast_uom_code <> FND_API.G_MISS_CHAR THEN

      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'OZF_FCAST_UOM',
            p_lookup_code => l_act_forecast_rec.forecast_uom_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_FSCT_INVALID_UOM_CODE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

*/

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_ActFcst_Items;

--
-- Start of comments.
--
-- NAME
--    Validate_ActFcst_Rec
--
-- PURPOSE
--    Perform Record Level and Other business validations for forecasts.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Validate_ActFcst_rec(
   p_act_forecast_rec      IN  act_forecast_rec_type,
   p_complete_fcst_rec     IN  act_forecast_rec_type,
   x_return_status         OUT NOCOPY VARCHAR2
)
IS

   l_act_forecast_rec   act_forecast_rec_type := p_act_forecast_rec;

   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.

   l_return_status 				 VARCHAR2(1);


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF l_act_forecast_rec.arc_act_fcast_used_by <> FND_API.G_MISS_CHAR      THEN

      -- Get table_name and pk_name for the ARC qualifier.
      OZF_Utility_PVT.Get_Qual_Table_Name_And_PK (
         p_sys_qual                     => l_act_forecast_rec.arc_act_fcast_used_by,
         x_return_status                => l_return_status,
         x_table_name                   => l_table_name,
         x_pk_name                      => l_pk_name
      );


      l_pk_value                 := l_act_forecast_rec.act_fcast_used_by_id;
      l_pk_data_type             := OZF_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL;

      IF OZF_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => NULL
         ) = FND_API.G_FALSE
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('OZF', 'OZF_FCST_INVALID_USED_BY');
            FND_MSG_PUB.Add;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
      END IF;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_ActFcst_Rec;


--
-- Start of comments.
--
-- NAME
--    Validate_ActFcst_Items
--
-- PURPOSE
--    Perform All Item level validation for Activity metric facts.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Validate_ActFcst_Items (
   p_act_forecast_rec    IN  act_forecast_rec_type,
   p_validation_mode        IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
BEGIN



  /*
  ****
   -- Need not check for req items since
   -- Default_ActForecast takes care of all req items

   Check_Req_ActFcst_Items(
      p_act_forecast_rec  => p_act_forecast_rec,
      x_return_status        => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
  ****
  */


   Check_ActFcst_Uk_Items(
      p_act_forecast_rec    => p_act_forecast_rec,
      p_validation_mode        => p_validation_mode,
      x_return_status          => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


 /*
  ****
   -- Default_ActForecast takes care of all req items

   Check_ActFcst_Items(
      p_act_forecast_rec   => p_act_forecast_rec,
      x_return_status         => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   ****
   */

END Validate_ActFcst_Items;



END OZF_ActForecast_PVT;

/
