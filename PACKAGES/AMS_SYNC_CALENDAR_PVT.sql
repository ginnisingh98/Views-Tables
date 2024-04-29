--------------------------------------------------------
--  DDL for Package AMS_SYNC_CALENDAR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SYNC_CALENDAR_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcals.pls 115.8 2004/05/12 07:01:10 vmodur ship $ */
	TYPE cal_criteria_rec IS RECORD
	( OBJECT_TYPE		VARCHAR2(30)
	, RESOURCE_ID           NUMBER
	, RESOURCE_TYPE         VARCHAR2(30)
	, CUSTOM_SETUP_ID       NUMBER
	, ACTIVITY_TYPE_CODE    VARCHAR2(30)
	, ACTIVITY_ID           NUMBER
	, STATUS_ID		NUMBER
	, PRIORITY_ID           VARCHAR2(30)
	, OBJECT_ID		NUMBER
	, CRITERIA_START_DATE   DATE
	, CRITERIA_END_DATE     DATE
	, CRITERIA_ENABLED      VARCHAR2(1)
	, CRITERIA_DELETED      VARCHAR2(1)
	);

	PROCEDURE Sync_Cal_Items
	(
		x_remove_only		  IN     VARCHAR2 := FND_API.G_False,
	--	x_full_mode		  IN     VARCHAR2 := FND_API.G_False,
		x_api_version             IN     NUMBER   := 1.0,
		x_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
		x_commit                  IN     VARCHAR2 := FND_API.G_False,
		x_return_status		  OUT NOCOPY    VARCHAR2,
		x_msg_count               OUT NOCOPY    NUMBER,
		x_msg_data                OUT NOCOPY    VARCHAR2,
	--	x_inc_mode_start_date     IN     FND_CONCURRENT_REQUESTS.ACTUAL_START_DATE%type,
		x_criteria_rec		  IN	 cal_criteria_rec
	);

	PROCEDURE Create_Cal_Items
	(
		x_full_mode		  IN     VARCHAR2 := 'N',
		x_api_version             IN     NUMBER   := 1.0,
		x_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
		x_commit                  IN     VARCHAR2 := FND_API.G_False,
		x_return_status		  OUT NOCOPY    VARCHAR2,
		x_msg_count               OUT NOCOPY    NUMBER,
		x_msg_data                OUT NOCOPY    VARCHAR2,
--		x_inc_mode_start_date     IN     FND_CONCURRENT_REQUESTS.ACTUAL_START_DATE%type,
		x_criteria_rec		  IN	 cal_criteria_rec
	);

	PROCEDURE Update_Cal_Items
	(
		x_full_mode		  IN     VARCHAR2 := 'N',
		x_api_version             IN     NUMBER   := 1.0,
		x_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
		x_commit                  IN     VARCHAR2 := FND_API.G_False,
		x_return_status		  OUT NOCOPY    VARCHAR2,
		x_msg_count               OUT NOCOPY    NUMBER,
		x_msg_data                OUT NOCOPY    VARCHAR2,
--		x_inc_mode_start_date     IN     FND_CONCURRENT_REQUESTS.ACTUAL_START_DATE%type,
		x_criteria_rec		  IN	 cal_criteria_rec
	);

	PROCEDURE Delete_Cal_Items
	(
		x_full_mode		  IN     VARCHAR2 := 'N',
		x_api_version             IN     NUMBER   := 1.0,
		x_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
		x_commit                  IN     VARCHAR2 := FND_API.G_False,
		x_return_status		  OUT NOCOPY    VARCHAR2,
		x_msg_count               OUT NOCOPY    NUMBER,
		x_msg_data                OUT NOCOPY    VARCHAR2,
--		x_inc_mode_start_date     IN     FND_CONCURRENT_REQUESTS.ACTUAL_START_DATE%type,
		x_criteria_rec		  IN	 cal_criteria_rec,
		x_obj_id		  IN	 NUMBER := 0
	);

END AMS_Sync_Calendar_PVT;

 

/
