--------------------------------------------------------
--  DDL for Package Body AMS_SYNC_CALENDAR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SYNC_CALENDAR_PUB" AS
/* $Header: amspcalb.pls 115.16 2004/05/13 10:53:07 vmodur ship $ */

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Sync_Calendar_Items
(
      ERRBUF                    OUT NOCOPY     VARCHAR2,
      RETCODE                   OUT NOCOPY     NUMBER,
      p_full_mode               IN  VARCHAR2 := 'N'
)
IS
   --Initialise return status to success.

   l_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

   l_msg_count        NUMBER := 0;
   l_msg_data         VARCHAR2(2000) := NULL;
   l_api_version      NUMBER := 1.0 ;
   -- Bug fix #3159119
   p_resource_id      NUMBER;

   CURSOR c_get_delete_criteria IS
	SELECT  obj.CRITERIA_ID
		, obj.OBJECT_TYPE_CODE
		, obj.CUSTOM_SETUP_ID
		, obj.ACTIVITY_TYPE_CODE
		, obj.ACTIVITY_ID
		, obj.STATUS_ID
		, obj.PRIORITY_ID
		, obj.OBJECT_ID
		, obj.CRITERIA_START_DATE
		, obj.CRITERIA_END_DATE
		, obj.LAST_UPDATE_DATE
		, obj.CRITERIA_ENABLED
		, obj.CRITERIA_DELETED
	FROM ams_calendar_criteria obj
	WHERE (obj.CRITERIA_ENABLED = 'N'
	      OR obj.CRITERIA_DELETED = 'Y');

	CURSOR c_get_create_criteria IS
	SELECT  obj.CRITERIA_ID
		, obj.OBJECT_TYPE_CODE
		, obj.CUSTOM_SETUP_ID
		, obj.ACTIVITY_TYPE_CODE
		, obj.ACTIVITY_ID
		, obj.STATUS_ID
		, obj.PRIORITY_ID
		, obj.OBJECT_ID
		, obj.CRITERIA_START_DATE
		, obj.CRITERIA_END_DATE
		, obj.LAST_UPDATE_DATE
		, obj.CRITERIA_ENABLED
		, obj.CRITERIA_DELETED
	FROM ams_calendar_criteria obj
	WHERE (obj.CRITERIA_ENABLED = 'Y'
	      AND obj.CRITERIA_DELETED = 'N');

        l_get_criteria_rec ams_criteria_rec;
BEGIN
   FND_MSG_PUB.initialize;

   OPEN c_get_delete_criteria;
   LOOP
	FETCH c_get_delete_criteria INTO l_get_criteria_rec;
	IF (c_get_delete_criteria%NOTFOUND) THEN
		l_return_status := FND_API.G_RET_STS_SUCCESS;
		--CLOSE c_get_delete_criteria;
		l_get_criteria_rec := NULL;
		EXIT;
	ELSE
		Sync_Cal_Items (  x_full_mode		=> p_full_mode
				, x_return_status       => l_return_status
				, x_msg_count           => l_msg_count
				, x_msg_data            => l_msg_data
				, x_resource_id		=> p_resource_id
				, x_criteria_rec        => l_get_criteria_rec
				, x_remove_only         => FND_API.G_TRUE
				);
	END IF;
   END LOOP;
   CLOSE c_get_delete_criteria;

   OPEN c_get_create_criteria;
   LOOP
	FETCH c_get_create_criteria INTO l_get_criteria_rec;
	IF (c_get_create_criteria%NOTFOUND) THEN
		l_return_status := FND_API.G_RET_STS_SUCCESS;
		--CLOSE c_get_create_criteria;
		l_get_criteria_rec := NULL;
		EXIT;
	ELSE
		Sync_Cal_Items (  x_full_mode		=> p_full_mode
				, x_return_status       => l_return_status
				, x_msg_count           => l_msg_count
				, x_msg_data            => l_msg_data
				, x_resource_id		=> p_resource_id
				, x_criteria_rec        => l_get_criteria_rec
				);
	END IF;
   END LOOP;
   CLOSE c_get_create_criteria;

   -- Write_log ;
   Ams_Utility_Pvt.Write_Conc_log ;

   IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      retcode :=0;
   ELSE
      retcode  := 2;
      errbuf   :=  l_msg_data ;
   END IF;
   COMMIT;
END Sync_Calendar_Items;


PROCEDURE Sync_Cal_Items
(
	x_full_mode		  IN     VARCHAR2 := 'N',
	x_api_version             IN     NUMBER   := 1.0,
	x_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
	x_commit                  IN     VARCHAR2 := FND_API.G_False,
	x_return_status		  OUT NOCOPY    VARCHAR2,
	x_msg_count               OUT NOCOPY    NUMBER,
	x_msg_data                OUT NOCOPY    VARCHAR2,
	x_resource_id		  IN	 NUMBER,
	x_criteria_rec		  IN	 ams_criteria_rec,
	x_remove_only             IN     VARCHAR2 := FND_API.G_False
)
IS
   l_inc_mode_start_date      FND_CONCURRENT_REQUESTS.ACTUAL_START_DATE%type;
   l_cal_pvt_rec	      AMS_Sync_Calendar_PVT.cal_criteria_rec;
BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT AMS_SYNC_CALENDAR;
   --
   -- Debug Message
   --
   -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_Utility_PVT.debug_message(l_api_name || ': start'); END IF;

   --
   -- Initialize message list IF x_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( x_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
/* IF NOT FND_API.Compatible_API_Call ( 1.0,
                                        x_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
*/
/* No Longer needed 3568819
	BEGIN
	SELECT MAX(ACTUAL_START_DATE)
	INTO l_inc_mode_start_date
	FROM FND_CONCURRENT_REQUESTS
	WHERE ( PROGRAM_APPLICATION_ID = '530'
		AND CONCURRENT_PROGRAM_ID = (SELECT CONCURRENT_PROGRAM_ID
				    FROM FND_CONCURRENT_PROGRAMS
				    WHERE CONCURRENT_PROGRAM_NAME = 'AMSSYNCCAL')
		AND STATUS_CODE = 'C'
		AND PHASE_CODE = 'C' );
	EXCEPTION
        WHEN NO_DATA_FOUND THEN
		l_inc_mode_start_date := NULL;
        END;
*/
   --
   --  Initialize API return status to success
   --
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_cal_pvt_rec.OBJECT_TYPE		:= x_criteria_rec.OBJECT_TYPE_CODE;
	l_cal_pvt_rec.RESOURCE_ID		:= x_resource_id;
        -- Bug fix #3159119
        -- SELECT employee_id INTO l_cal_pvt_rec.RESOURCE_TYPE FROM ams_jtf_rs_emp_v WHERE resource_id = x_resource_id;
	l_cal_pvt_rec.RESOURCE_TYPE		:= 'RS_GROUP';

	l_cal_pvt_rec.CUSTOM_SETUP_ID		:= x_criteria_rec.CUSTOM_SETUP_ID;
	l_cal_pvt_rec.ACTIVITY_TYPE_CODE	:= x_criteria_rec.ACTIVITY_TYPE_CODE;
	l_cal_pvt_rec.ACTIVITY_ID		:= x_criteria_rec.ACTIVITY_ID;
	l_cal_pvt_rec.STATUS_ID			:= x_criteria_rec.STATUS_ID;
	l_cal_pvt_rec.PRIORITY_ID		:= x_criteria_rec.PRIORITY_ID;
	l_cal_pvt_rec.OBJECT_ID			:= x_criteria_rec.OBJECT_ID;
	l_cal_pvt_rec.CRITERIA_START_DATE	:= x_criteria_rec.CRITERIA_START_DATE;
	l_cal_pvt_rec.CRITERIA_END_DATE		:= x_criteria_rec.CRITERIA_END_DATE;
	l_cal_pvt_rec.CRITERIA_ENABLED		:= x_criteria_rec.CRITERIA_ENABLED;
	l_cal_pvt_rec.CRITERIA_DELETED		:= x_criteria_rec.CRITERIA_DELETED;

	--Regardless of mode (INCREMENTAL/ FULL) sync criteria which have been modified after the the 'last run date' i.e. l_inc_mode_start_date.
	-- Commented for Bug Fix 3568819
	/*
	IF ((l_inc_mode_start_date is not NULL) AND (x_criteria_rec.LAST_UPDATE_DATE >= l_inc_mode_start_date)) THEN
		IF (x_remove_only = 'Y') THEN
			AMS_Sync_Calendar_PVT.Sync_Cal_Items( x_remove_only => FND_API.G_True
							    , x_return_status => x_return_status
							    , x_msg_count => x_msg_count
							    , x_msg_data => x_msg_data
							    , x_criteria_rec => l_cal_pvt_rec
							    );
		ELSE
			AMS_Sync_Calendar_PVT.Sync_Cal_Items(
							    x_return_status => x_return_status
							    , x_msg_count => x_msg_count
							    , x_msg_data => x_msg_data
							    , x_criteria_rec => l_cal_pvt_rec
							    );
		END IF;
	ELSE
		IF (
		     (l_inc_mode_start_date is NULL) OR
		     (x_full_mode = 'Y' AND x_criteria_rec.LAST_UPDATE_DATE < l_inc_mode_start_date)
		   ) THEN
			IF (x_remove_only = 'Y') THEN
				AMS_Sync_Calendar_PVT.Sync_Cal_Items( x_remove_only => FND_API.G_True
								    , x_return_status => x_return_status
								    , x_msg_count => x_msg_count
								    , x_msg_data => x_msg_data
								    , x_criteria_rec => l_cal_pvt_rec
								    );
			ELSE
				AMS_Sync_Calendar_PVT.Sync_Cal_Items(
								    x_return_status => x_return_status
								    , x_msg_count => x_msg_count
								    , x_msg_data => x_msg_data
								    , x_criteria_rec => l_cal_pvt_rec
								    );
			END IF;
		END IF;
	END IF;
	*/

        -- Bug Fix for 3568819. There is no sense in the Full Mode Logic as there is no dates to
	-- compare in the ams_calendar_criteria. Using last_update_date is not correct. As of today
	-- it will always be full mode. Also x_remove_only is T or F and not Y/N

			IF (x_remove_only = FND_API.G_TRUE) THEN
				AMS_Sync_Calendar_PVT.Sync_Cal_Items( x_remove_only => FND_API.G_True
								    , x_return_status => x_return_status
								    , x_msg_count => x_msg_count
								    , x_msg_data => x_msg_data
								    , x_criteria_rec => l_cal_pvt_rec
								    );
			ELSE
				AMS_Sync_Calendar_PVT.Sync_Cal_Items(
								    x_return_status => x_return_status
								    , x_msg_count => x_msg_count
								    , x_msg_data => x_msg_data
								    , x_criteria_rec => l_cal_pvt_rec
								    );
			END IF;

EXCEPTION
	  WHEN FND_API.G_EXC_ERROR
	  THEN
--	    ROLLBACK TO delete_item_pub;
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
				     , p_data  => x_msg_data
				     );
	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	  THEN
--	    ROLLBACK TO delete_item_pub;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
				     , p_data  => x_msg_data
				     );
	  WHEN OTHERS
	  THEN
--	    ROLLBACK TO delete_item_pub;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	      FND_MSG_PUB.Add_Exc_Msg('AMS_Sync_Calendar_PUB'
				     , 'Sync_Calendar_Items'
				     );
	    END IF;
	    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
				     , p_data  => x_msg_data
				     );
END Sync_Cal_Items;

END AMS_Sync_Calendar_PUB ;

/
