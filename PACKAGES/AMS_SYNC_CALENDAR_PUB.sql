--------------------------------------------------------
--  DDL for Package AMS_SYNC_CALENDAR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SYNC_CALENDAR_PUB" AUTHID CURRENT_USER AS
/* $Header: amspcals.pls 115.13 2004/05/12 07:03:19 vmodur ship $ */


	TYPE ams_criteria_rec IS RECORD
	( CRITERIA_ID		NUMBER
	, OBJECT_TYPE_CODE	VARCHAR2(30)
	, CUSTOM_SETUP_ID	NUMBER
	, ACTIVITY_TYPE_CODE    VARCHAR2(30)
	, ACTIVITY_ID           NUMBER
	, STATUS_ID		NUMBER
	, PRIORITY_ID           VARCHAR2(30)
	, OBJECT_ID             NUMBER
	, CRITERIA_START_DATE   DATE
	, CRITERIA_END_DATE     DATE
	, LAST_UPDATE_DATE	DATE
	, CRITERIA_DELETED      VARCHAR2(1)
	, CRITERIA_ENABLED      VARCHAR2(1)
	);


	PROCEDURE Sync_Calendar_Items
	(
	      ERRBUF                    OUT NOCOPY    VARCHAR2,
	      RETCODE                   OUT NOCOPY    NUMBER,
	      p_full_mode               IN  VARCHAR2 := 'N'
	);

	PROCEDURE Sync_Cal_Items
	(
		x_full_mode		  IN     VARCHAR2 := 'N',
		x_api_version             IN     NUMBER   := 1.0,
		x_init_msg_list           IN     VARCHAR2 := FND_API.g_false,
		x_commit                  IN     VARCHAR2 := FND_API.g_false,
		x_return_status		  OUT NOCOPY    VARCHAR2,
		x_msg_count               OUT NOCOPY    NUMBER,
		x_msg_data                OUT NOCOPY    VARCHAR2,
		x_resource_id		  IN	 NUMBER,
		x_criteria_rec		  IN	 ams_criteria_rec,
		x_remove_only             IN     VARCHAR2 := FND_API.G_False
	);

END AMS_Sync_Calendar_PUB;

 

/
