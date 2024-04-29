--------------------------------------------------------
--  DDL for Package OZF_ACTFORECAST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACTFORECAST_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvfcts.pls 120.2 2005/07/29 02:54:17 appldev ship $ */

--
-- Start of comments.
--
-- NAME
--   Ozf_ActForecast_Pvt
--
-- PURPOSE
--   This package is a private package used for defining constants, records,
--   types and procedures for activity forecasts API.
--
--   Procedures:
--   Create_ActForecast
--   Update_ActForecast
--   Lock_ActForecast
--   Delete_ActForecast
--   Validate_ActForecast
--
-- NOTES
--
--
-- HISTORY
-- 18/Apr/2000 tdonohoe  Created.
-- 15/Jun/2000 tdonohoe  Modified added column FORECAST_TYPE.
-- 25/APR/2002 kvattiku Added column PRICE_LIST_ID
-- 11/JUL/2005 inanaiah R12 changes for non-baseline basis
--
-- Start AMS_ACT_FORECASTS_ALL
--

TYPE act_forecast_rec_type
IS RECORD (  forecast_id                    number
            ,forecast_type                  varchar2(30)
	    ,arc_act_fcast_used_by          varchar2(30)
            ,act_fcast_used_by_id           number
            ,creation_date                  date
            ,created_from                   varchar2(30)
            ,created_by                     number
            ,last_update_date               date
            ,last_updated_by                number
            ,last_update_login              number
            ,program_application_id         number
            ,program_id                     number
            ,program_update_date            date
            ,request_id                     number
            ,object_version_number          number
            ,hierarchy                      varchar2(30)
            ,hierarchy_level                varchar2(30)
            ,level_value                    varchar2(240)
            ,forecast_calendar              varchar2(30)
            ,period_level                   varchar2(30)
            ,forecast_period_id             number
            ,forecast_date                  date
            ,forecast_uom_code              varchar2(3)
            ,forecast_quantity              number
            ,forward_buy_quantity           number
            ,forward_buy_period             varchar2(20)
            ,cumulation_period_choice       varchar2(30)
            ,base_quantity                  number
            ,context                        varchar2(30)
            ,attribute_category             varchar2(30)
            ,attribute1                     varchar2(150)
            ,attribute2                     varchar2(150)
            ,attribute3                     varchar2(150)
            ,attribute4                     varchar2(150)
            ,attribute5                     varchar2(150)
            ,attribute6                     varchar2(150)
            ,attribute7                     varchar2(150)
            ,attribute8                     varchar2(150)
            ,attribute9                     varchar2(150)
            ,attribute10                    varchar2(150)
            ,attribute11                    varchar2(150)
            ,attribute12                    varchar2(150)
            ,attribute13                    varchar2(150)
            ,attribute14                    varchar2(150)
            ,attribute15                    varchar2(150)
            ,org_id                         number
            ,forecast_remaining_quantity    number
            ,forecast_remaining_percent     number
            ,base_quantity_type             varchar2(30)
            ,forecast_spread_type           varchar2(30)
            ,dimention1                     varchar2(30)
            ,dimention2                     varchar2(30)
            ,dimention3                     varchar2(30)
            ,last_scenario_id               number
            ,freeze_flag                    varchar2(1)
	        ,comments                       varchar2(2000)
	        ,price_list_id                  number
            ,base_quantity_ref              varchar2(30)
            ,base_quantity_start_date       date
            ,base_quantity_end_date         date
            ,offer_code                     varchar2(30)
);
--
-- End AMS_ACT_FORECASTS_ALL
--
--
-- End of comments.


-- Start of comments
-- API Name       Create_ActForecast
-- Type           Private
-- Pre-reqs       None.
-- Function       Creates an Activity Forecast.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_forecast_rec          IN act_forecast_rec_type  Required
--    OUT NOCOPY         x_return_status             OUT NOCOPY VARCHAR2
--                x_msg_count                 OUT NOCOPY NUMBER
--                x_msg_data                  OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Create_ActForecast (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_forecast_rec           IN  act_forecast_rec_type,
   x_forecast_id                OUT NOCOPY NUMBER
);



-- Start of comments
-- API Name       Update_ActForecast
-- Type           Private
-- Pre-reqs       None.
-- Function       Updates the activity forecast.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_forecast_rec          IN act_forecast_rec_type Required
--    OUT NOCOPY         x_return_status             OUT NOCOPY VARCHAR2
--                x_msg_count                 OUT NOCOPY NUMBER
--                x_msg_data                  OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Update_ActForecast (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_forecast_rec           IN 	act_forecast_rec_type
);


-- Start of comments
-- API Name       Delete_ActForecast
-- Type           Private
-- Pre-reqs       None.
-- Function       Deletes the Activity Forecast.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_forecast_id               IN NUMBER  Required
--                p_object_version_number     IN NUMBER
--    OUT NOCOPY         x_return_status             OUT NOCOPY VARCHAR2
--                x_msg_count                 OUT NOCOPY NUMBER
--                x_msg_data                  OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Delete_ActForecast (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_forecast_id              IN  NUMBER ,
   p_object_version_number    IN  NUMBER
);



-- Start of comments
-- API Name       Lock_ActForecast
-- Type           Private
-- Pre-reqs       None.
-- Function       Lock the given row in AMS_ACT_FORECASTS_ALL.
-- Parameters
--    IN          p_api_version             IN NUMBER     Required
--                p_init_msg_list           IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                  IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_forecast_id             IN NUMBER  Required
--		  p_object_version_number   IN NUMBER	 Required
--    OUT NOCOPY         x_return_status           OUT NOCOPY VARCHAR2
--                x_msg_count               OUT NOCOPY NUMBER
--                x_msg_data                OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Lock_ActForecast (
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_forecast_id             IN  NUMBER,
   p_object_version_number   IN  NUMBER
);



-- Start of comments
-- API Name       Validate_ActForecast
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate items in activity forecast table.

-- Parameters
--    IN          p_api_version           IN NUMBER     Required
--                p_init_msg_list         IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level      IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_forecast_rec      IN act_forecast_rec_type  Required
--    OUT NOCOPY         x_return_status         OUT NOCOPY VARCHAR2
--                x_msg_count             OUT NOCOPY NUMBER
--                x_msg_data              OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Validate_ActForecast (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_forecast_rec           IN  act_forecast_rec_type
);


-- Start of comments
-- API Name       Validate_ActFcst_Items
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Forecast Items
-- Parameters
--    IN          p_act_forecast_rec       IN act_forecast_rec_type  Required
--                p_validate_mode 	   IN VARCHAR2
--    OUT NOCOPY         x_return_status          OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Validate_ActFcst_items(
   p_act_forecast_rec    IN  act_forecast_rec_type,
   p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status       OUT NOCOPY VARCHAR2
) ;


-- Start of comments
-- API Name       Validate_ActFcst_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Forecast Records
-- Parameters
--    IN          p_act_forecast_rec   IN act_forecast_rec_type  Required
--                p_complete_fcst_rec  IN act_forecast_rec_type  Required
--    OUT NOCOPY         x_return_status      OUT NOCOPY VARCHAR2
-- Version        Current version:  1.0
--                Previous version: 1.0
--                Initial version:  1.0
-- End of comments

PROCEDURE Validate_ActFcst_rec(
   p_act_forecast_rec            IN  act_forecast_rec_type,
   p_complete_fcst_rec           IN  act_forecast_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
) ;


-- Start of comments
-- API Name       Complete_ActFcst_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       This Process returns the details for the Activity Metric Fact
--
-- Parameters
--    IN          p_act_forecast_rec            IN  act_forecast_rec_type  Required
--    OUT NOCOPY         x_complete_fcst_rec           OUT NOCOPY act_forecast_rec_type
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Complete_ActFcst_Rec(
   p_act_forecast_rec      IN  act_forecast_rec_type,
   x_complete_fcst_rec     OUT NOCOPY act_forecast_rec_type
);

PROCEDURE Init_ActForecast_Rec(
   x_actforecast_rec  OUT NOCOPY  act_forecast_rec_type
);

END Ozf_ActForecast_Pvt;

 

/
