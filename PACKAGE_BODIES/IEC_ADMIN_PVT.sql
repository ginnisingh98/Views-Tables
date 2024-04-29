--------------------------------------------------------
--  DDL for Package Body IEC_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_ADMIN_PVT" as
/* $Header: IECADMB.pls 120.1 2005/06/16 09:10:41 appldev  $ */



-- ===============================================================

-- Start of Comments

-- Package name

--          IEC_ADMIN_PVT

-- Purpose

--          Private api created for use by the Admin utility

-- History

--    30-Apr-2001     msista      Created.

--    21-May-2001     msista      Modified to work better.

--    09-Jul-2001     gpagadal    Removed Dialing Method.

--    20-Jul-2001     gpagadal    fnd_msg_pub.delete_msg() added.

--    02-Aug-2001     gpagadal    Fields added.

--

-- NOTE

--

-- End of Comments

-- ===============================================================





G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEC_ADMIN_PVT';

G_FILE_NAME CONSTANT VARCHAR2(12) := 'iecadmb.pls';



-- don't know if need these

--G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;

--G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;



--===================================================================

-- NAME

--    Update_Camp_Schedule

--

-- PURPOSE

--    Private api to Update Campaign schedules.

--

-- NOTES

--    1. AO Admin will use this procedure to update Campaign Schedule

--       parameters.

--

-- HISTORY

--   15-May-2001     MSISTA   Created

--   09-Jul-2001     GPAGADAL Modified

--===================================================================

PROCEDURE Update_Camp_Schedule(



    p_campaign_schedule_id   IN  NUMBER,

 -- dialing_method used for CTI disabled

    p_dialing_method         IN  VARCHAR2,

    p_calendar_id            IN  NUMBER,

    p_abandon_limit          IN  NUMBER,



-- predictive timeout

    p_predictive_timeout     IN  NUMBER,

    p_user_status_id         IN  NUMBER,



    p_user_id                IN  NUMBER,



    x_msg_data               OUT NOCOPY VARCHAR2,

    x_return_value          OUT NOCOPY NUMBER



    )

IS



   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Camp_Schedule';

   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;



   l_camp_schedule_rec    AMS_Camp_Schedule_PUB.schedule_rec_type;



   l_msg_count                 NUMBER;

   l_msg_data                  VARCHAR2(240);

   l_one_msg                   VARCHAR2(100);

   l_object_version_number     NUMBER;



   x_return_status             VARCHAR2(10);



BEGIN



   fnd_msg_pub.delete_msg();



   -- Standard Start of API savepoint

   SAVEPOINT UPDATE_camp_schedule;



   -- Initialize outgoing parameters

   x_msg_data := '';

   x_return_value := 1;



   -- Initialize API return status to SUCCESS

   x_return_status := FND_API.G_RET_STS_SUCCESS;



   l_camp_schedule_rec.schedule_id := p_campaign_schedule_id;

   -- CTI disabled

   IF NOT (p_dialing_method IS NULL) THEN

    l_camp_schedule_rec.activity_attribute4 := p_dialing_method;

   END IF;



   IF NOT (p_calendar_id IS NULL) THEN

    l_camp_schedule_rec.activity_attribute1 := p_calendar_id;

   END IF;



   IF NOT (p_abandon_limit IS NULL) THEN

    l_camp_schedule_rec.activity_attribute5 := p_abandon_limit;

   END IF;



   IF NOT (p_predictive_timeout IS NULL) THEN

    l_camp_schedule_rec.activity_attribute8 := p_predictive_timeout;

   END IF;



   IF NOT (p_user_status_id IS NULL ) THEN

    IF l_camp_schedule_rec.user_status_id <> p_user_status_id THEN

        l_camp_schedule_rec.user_status_id := p_user_status_id;

        l_camp_schedule_rec.status_date := sysdate;

    END IF;

   END IF;



   l_camp_schedule_rec.last_update_date := sysdate;

   l_camp_schedule_rec.last_updated_by := p_user_id;



   -- fetch the object_version_number from db

   SELECT

    OBJECT_VERSION_NUMBER, SOURCE_CODE into

    l_camp_schedule_rec.object_version_number, l_camp_schedule_rec.source_code

    from AMS_CAMPAIGN_SCHEDULES_B

    WHERE SCHEDULE_ID = p_campaign_schedule_id;



   AMS_Camp_Schedule_PUB.Update_Camp_Schedule( L_API_VERSION_NUMBER,

                                               FND_API.G_FALSE,

                                               FND_API.G_TRUE,

                                               FND_API.G_VALID_LEVEL_FULL,

                                               x_return_status,

                                               l_msg_count,

                                               l_msg_data,

                                               l_camp_schedule_rec,

                                               l_object_version_number

                                             );



  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    UPDATE AMS_CAMPAIGN_SCHEDULES_B

    SET

      ACTIVITY_ATTRIBUTE6 = 'Y'

    WHERE

      SCHEDULE_ID = p_campaign_schedule_id;

    -- msista 11/29

    COMMIT;

  ELSE

    FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP

      FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);

      x_msg_data := x_msg_data || ',' || l_msg_data;

    END LOOP;

    x_return_value := 0;

  END IF;



EXCEPTION

   WHEN OTHERS THEN

     FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP

       FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);

       x_msg_data := x_msg_data || ',' || l_msg_data;

     END LOOP;

     x_msg_data := x_msg_data || ',' || 'IEC_ERR_UPD_CAMP_FAIL';

     x_return_value := 0;



END Update_Camp_Schedule;











--===================================================================

-- NAME

--    Update_List_DialingMethod

--

-- PURPOSE

--    Private api to Update List headers.

--

-- NOTES

--    1. AO Admin will use this procedure to update List Header

--       parameters.

--

-- HISTORY

--   03-Aug-2001   GPAGADAL     Created



--===================================================================

PROCEDURE Update_List_DialingMethod(



    p_campaign_schedule_id   IN  NUMBER,

 -- dialing_method used for CTI disabled

    p_dialing_method         IN  VARCHAR2,



    p_user_id                IN  NUMBER,



    x_msg_data               OUT NOCOPY VARCHAR2,

    x_return_value          OUT NOCOPY NUMBER



    )

IS



   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_List_DialingMethod';

   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;





   l_list_header_rec    AMS_LISTHEADER_PVT.list_header_rec_type;



   l_msg_count                 NUMBER;

   l_msg_data                  VARCHAR2(240);

   l_one_msg                   VARCHAR2(100);

   l_object_version_number     NUMBER;



   x_return_status             VARCHAR2(10);



   CURSOR l_list_headers(campaign_schedule_id NUMBER) IS

      SELECT LIST_HEADER_ID FROM AMS_ACT_LISTS WHERE LIST_USED_BY_ID = campaign_schedule_id;



BEGIN



   fnd_msg_pub.delete_msg();



   -- Standard Start of API savepoint

   SAVEPOINT UPDATE_list_header;



   -- Initialize outgoing parameters

   x_msg_data := '';

   x_return_value := 1;



   -- Initialize API return status to SUCCESS

   x_return_status := FND_API.G_RET_STS_SUCCESS;



   IF p_dialing_method = 'MAN' THEN



     FOR l_list_header_id_rec IN l_list_headers(p_campaign_schedule_id) LOOP



       -- Initialize list header rec

       AMS_ListHeader_PVT.Init_ListHeader_Rec(l_list_header_rec);



       l_list_header_rec.list_header_id := l_list_header_id_rec.LIST_HEADER_ID;



       l_list_header_rec.dialing_method := 'MAN';

       l_list_header_rec.last_update_date := sysdate;

       l_list_header_rec.last_updated_by := p_user_id;



       -- fetch the object_version_number from db

       SELECT

       OBJECT_VERSION_NUMBER into l_list_header_rec.object_version_number

       FROM AMS_LIST_HEADERS_ALL

       WHERE LIST_HEADER_ID = l_list_header_rec.list_header_id;



       AMS_ListHeader_PUB.Update_ListHeader( l_api_version_number,

                                             FND_API.G_FALSE,

                                             FND_API.G_TRUE,

                                             FND_API.G_VALID_LEVEL_FULL,

                                             x_return_status,

                                             l_msg_count,

                                             l_msg_data,

                                             l_list_header_rec

                                           );



       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP

           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);

           x_msg_data := x_msg_data || ',' || l_msg_data;

         END LOOP;

         x_return_value := 0;

       END IF;



    END LOOP;



  END IF;



EXCEPTION

   WHEN OTHERS THEN

     FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP

       FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);

       x_msg_data := x_msg_data || ',' || l_msg_data;

     END LOOP;

     x_msg_data := x_msg_data || ',' || 'IEC_ERR_UPD_CAMP_FAIL';

     x_return_value := 0;



END Update_List_DialingMethod;





--===================================================================

-- NAME

--    Update_List_Header

--

-- PURPOSE

--    Private api to Update List headers.

--

-- NOTES

--    1. AO Admin will use this procedure to update List Header

--       parameters.

--

-- HISTORY

--   30-Apr-2001     MSISTA   Created

--===================================================================

PROCEDURE Update_List_Header(

   p_list_header_id             IN   NUMBER,

   p_dialing_method             IN   VARCHAR2,

   p_list_priority              IN   NUMBER,

   p_recycling_alg_id           IN   NUMBER,

   p_release_control_alg_id     IN   NUMBER,

   p_calendar_id                IN   NUMBER,

   p_release_strategy           IN   VARCHAR2,

   p_quantum                    IN   NUMBER,

   p_quota                      IN   NUMBER       := null,

   p_quota_reset                IN   NUMBER       := null,



   p_user_id                    IN   NUMBER,



   x_msg_data                   OUT  NOCOPY VARCHAR2,

   x_return_value               OUT  NOCOPY NUMBER

    )



IS



   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_List_Header';

   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;



   l_list_header_rec    AMS_LISTHEADER_PVT.list_header_rec_type;



   l_msg_count                 NUMBER;

   l_msg_data                  VARCHAR2(240);

   l_one_msg                   VARCHAR2(100);

   l_object_version_number     NUMBER;



   x_return_status             VARCHAR2(10);



BEGIN



   fnd_msg_pub.delete_msg();





   -- Standard Start of API savepoint

   SAVEPOINT UPDATE_list_header;



   -- Initialize outgoing parameter values

   x_msg_data := '';

   x_return_value := 1;



   -- Initialize API return status to SUCCESS

   x_return_status := FND_API.G_RET_STS_SUCCESS;



   -- Initialize list header rec

   AMS_ListHeader_PVT.Init_ListHeader_Rec(l_list_header_rec);



   l_list_header_rec.list_header_id := p_list_header_id;

   l_list_header_rec.dialing_method := p_dialing_method;

   l_list_header_rec.list_priority := p_list_priority;

   l_list_header_rec.release_control_alg_id := p_release_control_alg_id;

   l_list_header_rec.release_strategy := p_release_strategy;

   l_list_header_rec.quantum := p_quantum;

   l_list_header_rec.calling_calendar_id := p_calendar_id;

   --l_list_header_rec.recycling_alg_id := p_recycling_alg_id;

   --l_list_header_rec.quota := p_quota;

   --l_list_header_rec.quota_reset := p_quota_reset;



   l_list_header_rec.last_update_date := sysdate;

   l_list_header_rec.last_updated_by := p_user_id;



   AMS_ListHeader_PVT.Update_ListHeader( l_api_version_number,

                                         FND_API.G_FALSE,

                                         FND_API.G_TRUE,

                                         FND_API.G_VALID_LEVEL_FULL,

                                         x_return_status,

                                         l_msg_count,

                                         l_msg_data,

                                         l_list_header_rec

                                       );



  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    UPDATE AMS_LIST_HEADERS_ALL

    SET

      RECYCLING_ALG_ID = p_recycling_alg_id,

      QUOTA = p_quota,

      QUOTA_RESET = p_quota_reset,

      CALL_CENTER_READY_FLAG = 'Y'

    WHERE

      LIST_HEADER_ID = p_list_header_id;

    -- msista 11/29

    COMMIT;

  ELSE

    FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP

      FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);

      x_msg_data := x_msg_data || ',' || l_msg_data;

    END LOOP;

    x_return_value := 0;

  END IF;



EXCEPTION



   WHEN OTHERS THEN

     FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP

       FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);

       x_msg_data := x_msg_data || ',' || l_msg_data;

     END LOOP;

     x_msg_data := x_msg_data || ',' || 'IEC_ERR_UPD_LIST_FAIL';

     x_return_value := 0;



END Update_List_Header;



--===================================================================

-- NAME

--    Delete_List_Subset

--

-- PURPOSE

--    Private api to delete a list subset and all dependent data in a cascading fashion.

--

-- NOTES

--    1. AO Admin will use this procedure to delete a List subset.

--

-- HISTORY

--   09-May-2001     MSISTA   Created

--===================================================================

PROCEDURE Delete_List_Subset(

    p_list_subset_id         IN  NUMBER,

    p_user_id                IN  NUMBER,

    x_msg_data               OUT NOCOPY VARCHAR2,

    x_return_value           OUT NOCOPY NUMBER

    )

IS



   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_List_Subset';

   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;



BEGIN



   -- Standard Start of API savepoint

   SAVEPOINT Delete_List_Subset;



   -- Initialize outgoing parameters

   x_msg_data := '';

   x_return_value := 1;



   UPDATE IEC_G_LIST_SUBSETS SET STATUS_CODE='DELETED'

   WHERE LIST_SUBSET_ID = p_list_subset_id;



   COMMIT;



EXCEPTION



   WHEN OTHERS THEN

     x_msg_data := 'IEC_ERR_DEL_SUBSET_FAIL';

     x_return_value := 0;



END Delete_List_Subset;





-- ===============================================================

--    Start of Comments

-- ===============================================================

--   API Name

--           GET_TG_ENTRY_LIST

--

-- Used by Target Group Entry List Page to show the list

-- of entries belonging to a certain target group.

-- This procedure also gathers data for the page header and footer.

--

--   Type: Private

--

--   Parameters

--  IN

--    P_LIST_HEADER_ID		IN  NUMBER

--  , P_SEARCH_COLUMN		IN  VARCHAR2

--  , P_SEARCH_OPERATOR		IN  VARCHAR2

--  , P_SEARCH_PARAM		IN  VARCHAR2

-- 	, P_ORDER_BY			IN  NUMBER

--  , P_NEXT_ROW			IN  NUMBER

--  , P_MAX_ROWS			IN  NUMBER

--  , P_ORDER				IN  VARCHAR2

--

--  OUT

--    X_HEADER_DATA 		OUT NOCOPY TG_ENTRY_CURSOR

--  , X_CONTACT_POINT_DATA 	OUT NOCOPY TG_ENTRY_CURSOR

--  , X_TOTAL_ENTRIES		OUT NUMBER

--

--   Version : Current version 1.0

--

--   End of Comments

-- ===============================================================

PROCEDURE GET_TG_ENTRY_LIST

  ( P_LIST_HEADER_ID		IN  NUMBER

  , P_SEARCH_COLUMN			IN  VARCHAR2

  , P_SEARCH_OPERATOR		IN  VARCHAR2

  , P_SEARCH_PARAM			IN  VARCHAR2

  , P_ORDER_BY				IN  NUMBER

  , P_NEXT_ROW				IN  NUMBER

  , P_MAX_ROWS				IN  NUMBER

  , P_ORDER					IN  VARCHAR2

  , X_HEADER_DATA 			OUT NOCOPY TG_ENTRY_CURSOR

  , X_ENTRY_DATA 			OUT NOCOPY TG_ENTRY_CURSOR

  , X_TOTAL_ENTRIES			OUT NOCOPY NUMBER )

AS

   	l_header_cursor 			TG_ENTRY_CURSOR;

   	l_entries_cursor 			TG_ENTRY_CURSOR;



	l_source_type_view 			VARCHAR2(500);



   	l_header_stmt   			VARCHAR2(2000);

   	l_footer_stmt   			VARCHAR2(2000);



   	l_row_count					NUMBER(10);

	l_cp_count_stmt				VARCHAR2(1000);

	l_cp_valid_count_stmt		VARCHAR2(1000);

	l_cp_invalid_count_stmt		VARCHAR2(2000);

   	l_entries_stmt_temp			VARCHAR2(3000);

   	l_entries_stmt   			VARCHAR2(6000);



   	l_search_clause				VARCHAR2(3000);



BEGIN



	-- get the source type view for this list

    IEC_COMMON_UTIL_PVT.Get_SourceTypeView(P_LIST_HEADER_ID, l_source_type_view);



	-- First get the header data: campaign, schedule, and target group names

	l_header_stmt := ' SELECT ' ||

					 ' campaigns.CAMPAIGN_NAME, schedules.SCHEDULE_NAME, lists_vl.LIST_NAME ' ||

					 ' FROM ' ||

					 ' AMS_LIST_HEADERS_VL lists_vl, AMS_ACT_LISTS act_lists, AMS_CAMPAIGN_SCHEDULES_VL schedules,	AMS_CAMPAIGNS_VL campaigns ' ||

					 ' WHERE ' ||

					 ' lists_vl.LIST_HEADER_ID = :1 ' ||

					 ' AND lists_vl.LIST_HEADER_ID = act_lists.LIST_HEADER_ID ' ||

					 ' AND act_lists.LIST_USED_BY_ID = schedules.SCHEDULE_ID ' ||

					 ' AND schedules.CAMPAIGN_ID = campaigns.CAMPAIGN_ID ';



	-- Populate cursor

	OPEN l_header_cursor for l_header_stmt using P_LIST_HEADER_ID;

	X_HEADER_DATA := l_header_cursor;



	-- Next get the list of target group entries



	-- Get the max row count

	l_row_count := P_NEXT_ROW + P_MAX_ROWS;



	-- temporary strings that will be used to build the final query

	l_cp_count_stmt := 	' Get_Contact_Point_Count( ' ||

						'	NVL(PHONE_NUMBER_S1, RAW_PHONE_NUMBER_S1),  ' ||

						' 	NVL(PHONE_NUMBER_S2, RAW_PHONE_NUMBER_S2),  ' ||

						' 	NVL(PHONE_NUMBER_S3, RAW_PHONE_NUMBER_S3),  ' ||

						' 	NVL(PHONE_NUMBER_S4, RAW_PHONE_NUMBER_S4),  ' ||

						' 	NVL(PHONE_NUMBER_S5, RAW_PHONE_NUMBER_S5),  ' ||

						' 	NVL(PHONE_NUMBER_S6, RAW_PHONE_NUMBER_S6) ) ';



	l_cp_invalid_count_stmt := 	' Get_Invalid_CP_Count( ' ||

							   	'	NVL(PHONE_NUMBER_S1, RAW_PHONE_NUMBER_S1), REASON_CODE_S1, ' ||

							    '   NVL(PHONE_NUMBER_S2, RAW_PHONE_NUMBER_S2), REASON_CODE_S2, ' ||

							    '   NVL(PHONE_NUMBER_S3, RAW_PHONE_NUMBER_S3), REASON_CODE_S3, ' ||

							    '   NVL(PHONE_NUMBER_S4, RAW_PHONE_NUMBER_S4), REASON_CODE_S4, ' ||

							    '   NVL(PHONE_NUMBER_S5, RAW_PHONE_NUMBER_S5), REASON_CODE_S5, ' ||

							    '   NVL(PHONE_NUMBER_S6, RAW_PHONE_NUMBER_S6), REASON_CODE_S6  ) ';



	l_cp_valid_count_stmt := ' ( ' || l_cp_count_stmt || ' - ' || l_cp_invalid_count_stmt || ' ) ';





	l_search_clause := '';



	IF P_SEARCH_PARAM IS NOT NULL THEN



		IF P_SEARCH_COLUMN IN ('PERSON_FIRST_NAME', 'PERSON_LAST_NAME', 'LIST.LIST_ENTRY_ID', 'PARTY_ID' ) THEN

			l_search_clause := ' AND ' || P_SEARCH_COLUMN || P_SEARCH_OPERATOR || '''' || P_SEARCH_PARAM || '''';

		ELSE

			IF P_SEARCH_COLUMN = 'NUM_CPS' THEN

				l_search_clause := ' AND ' || l_cp_count_stmt || P_SEARCH_OPERATOR || P_SEARCH_PARAM;

			ELSIF P_SEARCH_COLUMN = 'NUM_VALID_CPS' THEN

				l_search_clause := ' AND ' || l_cp_valid_count_stmt || P_SEARCH_OPERATOR || P_SEARCH_PARAM;

			ELSIF P_SEARCH_COLUMN = 'NUM_INVALID_CPS' THEN

				l_search_clause := ' AND ' || l_cp_invalid_count_stmt || P_SEARCH_OPERATOR || P_SEARCH_PARAM;

			END IF;

		END IF;



	END IF;



	l_entries_stmt_temp := 	' SELECT ' ||

					  		' PERSON_FIRST_NAME, PERSON_LAST_NAME, ' 			||

					  		' LIST.LIST_ENTRY_ID LIST_ENTRY_ID, PARTY_ID, ' 	||

							  l_cp_count_stmt 			|| ' NUM_CPS, ' 		||

							  l_cp_valid_count_stmt 	|| ' NUM_VALID_CPS, ' 	||

							  l_cp_invalid_count_stmt 	|| ' NUM_INVALID_CPS ' 	||

							' FROM ' 											||

							  l_source_type_view  		|| ' LIST, ' 			||

							' IEC_O_VALIDATION_REPORT_DETS VAL ' 				||

							' WHERE ' 											||

							' LIST.LIST_HEADER_ID = :1 ' 						|| -- P_LIST_HEADER_ID

							' AND LIST.ENABLED_FLAG = ''Y'' ' 					||

							' AND LIST.LIST_HEADER_ID = VAL.LIST_HEADER_ID(+) ' ||

							' AND LIST.LIST_ENTRY_ID  = VAL.LIST_ENTRY_ID(+) ' 	||

							  l_search_clause ||

							' ORDER BY ' || P_ORDER_BY || ' ' || P_ORDER;



	l_entries_stmt := 	' SELECT ' ||

				  		' PERSON_FIRST_NAME, PERSON_LAST_NAME, ' 	||

				  		' LIST_ENTRY_ID, PARTY_ID, ' 				||

				  		' NUM_CPS, NUM_VALID_CPS, NUM_INVALID_CPS ' ||

						' FROM ' ||

						' ( SELECT PERSON_FIRST_NAME, PERSON_LAST_NAME, LIST_ENTRY_ID, PARTY_ID, NUM_CPS, NUM_VALID_CPS, NUM_INVALID_CPS ' ||

						'   FROM ( ' || l_entries_stmt_temp || ' ) AA WHERE ROWNUM <= :2 ) A ' ||  -- l_row_count

						' WHERE ' ||

						' A.LIST_ENTRY_ID NOT IN ' ||

						' ( SELECT LIST_ENTRY_ID FROM ( ' || l_entries_stmt_temp || ' ) BB WHERE ROWNUM <= :4 ) ' || -- P_NEXT_ROW

						' ORDER BY ' || P_ORDER_BY || ' ' || P_ORDER;



	-- Populate cursor

	OPEN l_entries_cursor for l_entries_stmt using P_LIST_HEADER_ID, l_row_count,

												   P_LIST_HEADER_ID, P_NEXT_ROW;

	X_ENTRY_DATA := l_entries_cursor;





	 -- Then get the footer data: number of entries in total

	EXECUTE IMMEDIATE

		' SELECT COUNT(LIST_ENTRY_ID)

		  FROM ' || '( ' || l_entries_stmt_temp || ' ) A '

	INTO X_TOTAL_ENTRIES

	USING P_LIST_HEADER_ID;



	return;



END GET_TG_ENTRY_LIST;





-- ===============================================================

--    Start of Comments

-- ===============================================================

--   API Name

--           GET_TG_ENTRY_DETAILS

--

-- Used by Target Group Entry Details Page to show the details

-- (including contact points) belonging to a certain entry.

-- This procedure also gathers data for the page header.

-- A list of timezones is also displayed on the page; their

-- translations are fetched here.

--

--   Type: Private

--

--   Parameters

--  IN

--    P_LIST_HEADER_ID		IN  NUMBER

--  , P_LIST_ENTRY_ID		IN  NUMBER

--  , P_LANGUAGE			IN  VARCHAR2

--

--  OUT

--    X_HEADER_DATA 		OUT NOCOPY TG_ENTRY_CURSOR

--  , X_CONTACT_POINT_DATA 	OUT NOCOPY TG_ENTRY_CURSOR

--  , X_TIME_ZONE_DATA		OUT NOCOPY TG_ENTRY_CURSOR

--

--   Version : Current version 1.0

--

--   End of Comments

-- ===============================================================

PROCEDURE GET_TG_ENTRY_DETAILS

  ( P_LIST_HEADER_ID		IN  NUMBER

  , P_LIST_ENTRY_ID			IN  NUMBER

  , P_LANGUAGE				IN  VARCHAR2

  , X_HEADER_DATA 			OUT NOCOPY TG_ENTRY_CURSOR

  , X_CONTACT_POINT_DATA 	OUT NOCOPY TG_ENTRY_CURSOR

  , X_TIME_ZONE_DATA		OUT NOCOPY TG_ENTRY_CURSOR )

AS

   	l_header_cursor 		TG_ENTRY_CURSOR;

   	l_contact_point_cursor 	TG_ENTRY_CURSOR;

   	l_time_zone_cursor 		TG_ENTRY_CURSOR;



   	l_header_stmt   		VARCHAR2(2000);

   	l_contact_point_stmt   	VARCHAR2(2000);

   	l_time_zone_stmt   		VARCHAR2(2000);

	l_source_type_view 		VARCHAR2(500);



BEGIN



	-- get the source type view for this list

    IEC_COMMON_UTIL_PVT.Get_SourceTypeView(P_LIST_HEADER_ID, l_source_type_view);



	-- First get the header data: campaign, schedule, and target group names

	l_header_stmt := ' SELECT ' ||

					 ' campaigns.CAMPAIGN_NAME, schedules.SCHEDULE_NAME, lists_vl.LIST_NAME, ' ||

					 ' list_entries.PERSON_FIRST_NAME, list_entries.PERSON_LAST_NAME, list_entries.PARTY_ID ' ||

					 ' FROM ' ||

					 ' AMS_LIST_HEADERS_VL lists_vl, AMS_ACT_LISTS act_lists, AMS_CAMPAIGN_SCHEDULES_VL schedules, AMS_CAMPAIGNS_VL campaigns, ' ||

 				       l_source_type_view  || ' list_entries ' ||

					 ' WHERE ' ||

					 ' list_entries.LIST_ENTRY_ID = :1 ' ||

					 ' AND list_entries.LIST_HEADER_ID = :2 ' ||

					 ' AND list_entries.LIST_HEADER_ID = lists_vl.LIST_HEADER_ID ' ||

					 ' AND lists_vl.LIST_HEADER_ID = act_lists.LIST_HEADER_ID ' ||

					 ' AND act_lists.LIST_USED_BY_ID = schedules.SCHEDULE_ID ' ||

					 ' AND schedules.CAMPAIGN_ID = campaigns.CAMPAIGN_ID ';



	-- Next get the list of contact points

	l_contact_point_stmt := ' SELECT ' ||

	 						' CONTACT_POINT_ID_S1, PHONE_COUNTRY_CODE_S1, PHONE_AREA_CODE_S1, PHONE_NUMBER_S1, RAW_PHONE_NUMBER_S1, TIME_ZONE_S1, Get_Translated_DNU_Reason(DO_NOT_USE_REASON_S1), REASON_CODE_S1, ' ||

							' CONTACT_POINT_ID_S2, PHONE_COUNTRY_CODE_S2, PHONE_AREA_CODE_S2, PHONE_NUMBER_S2, RAW_PHONE_NUMBER_S2, TIME_ZONE_S2, Get_Translated_DNU_Reason(DO_NOT_USE_REASON_S2), REASON_CODE_S2, ' ||

	 						' CONTACT_POINT_ID_S3, PHONE_COUNTRY_CODE_S3, PHONE_AREA_CODE_S3, PHONE_NUMBER_S3, RAW_PHONE_NUMBER_S3, TIME_ZONE_S3, Get_Translated_DNU_Reason(DO_NOT_USE_REASON_S3), REASON_CODE_S3, ' ||

	 						' CONTACT_POINT_ID_S4, PHONE_COUNTRY_CODE_S4, PHONE_AREA_CODE_S4, PHONE_NUMBER_S4, RAW_PHONE_NUMBER_S4, TIME_ZONE_S4, Get_Translated_DNU_Reason(DO_NOT_USE_REASON_S4), REASON_CODE_S4, ' ||

	 						' CONTACT_POINT_ID_S5, PHONE_COUNTRY_CODE_S5, PHONE_AREA_CODE_S5, PHONE_NUMBER_S5, RAW_PHONE_NUMBER_S5, TIME_ZONE_S5, Get_Translated_DNU_Reason(DO_NOT_USE_REASON_S5), REASON_CODE_S5, ' ||

	 						' CONTACT_POINT_ID_S6, PHONE_COUNTRY_CODE_S6, PHONE_AREA_CODE_S6, PHONE_NUMBER_S6, RAW_PHONE_NUMBER_S6, TIME_ZONE_S6, Get_Translated_DNU_Reason(DO_NOT_USE_REASON_S6), REASON_CODE_S6  ' ||

	 						' FROM ' ||

	 				    	  l_source_type_view  || ' LIST, ' ||

	 				  		' IEC_O_VALIDATION_REPORT_DETS VAL ' ||

	 					  	' WHERE ' ||

	 				  		' LIST.LIST_HEADER_ID = :1 ' ||

	 						' AND LIST.LIST_HEADER_ID = VAL.LIST_HEADER_ID(+) ' ||

	 				  		' AND LIST.LIST_ENTRY_ID = :2 ' ||

	 						' AND LIST.LIST_ENTRY_ID = VAL.LIST_ENTRY_ID(+) ';



	-- Finally get the time zone info

	l_time_zone_stmt := ' SELECT ' ||

					 	' B.UPGRADE_TZ_ID, T.TIMEZONE_CODE ' ||

					 	' FROM ' ||

					 	' FND_TIMEZONES_B B, FND_TIMEZONES_TL T ' ||

					 	' WHERE ' ||

					 	' B.TIMEZONE_CODE = T.TIMEZONE_CODE ' ||

					 	' AND T.LANGUAGE = :1 ' || -- P_LANGUAGE

					 	' ORDER BY T.TIMEZONE_CODE ASC ';



	OPEN l_header_cursor for l_header_stmt using P_LIST_ENTRY_ID, P_LIST_HEADER_ID;

	X_HEADER_DATA := l_header_cursor;



	OPEN l_contact_point_cursor for l_contact_point_stmt using P_LIST_HEADER_ID, P_LIST_ENTRY_ID;

	X_CONTACT_POINT_DATA := l_contact_point_cursor;



	OPEN l_time_zone_cursor for l_time_zone_stmt using P_LANGUAGE;

	X_TIME_ZONE_DATA := l_time_zone_cursor;



	return;



END GET_TG_ENTRY_DETAILS;

PROCEDURE Copy_Calendar_Day(

    p_calendar_id         IN  NUMBER,
    p_day_id              IN  NUMBER,
    p_copyto_code         IN VARCHAR2,
    p_createdBy           IN NUMBER,
    p_creationDate        IN DATE,
    p_updatedBy           IN NUMBER,
    p_updateDate          IN DATE,
    p_updateLogin         IN NUMBER,
    p_versionNumber       IN NUMBER
    )
AS
  l_day_copyto_id  NUMBER;
  cursor c_copy is
  select CALLABLE_REGION_CODE, START_TIME, END_TIME, TYPE_CODE from iec_g_cal_callable_rgns
    where DAY_ID = p_day_id;
BEGIN
  select day_id into l_day_copyto_id from iec_g_cal_days_b where CALENDAR_ID = p_calendar_id
  and DAY_CODE = 'DAY_OF_WEEK' and  PATTERN_CODE = p_copyto_code;

  delete from iec_g_cal_callable_rgns where DAY_ID = l_day_copyto_id;
  for v_copy in c_copy loop
    insert into iec_g_cal_callable_rgns(CALLABLE_REGION_ID, DAY_ID, CALLABLE_REGION_CODE,
              START_TIME, END_TIME, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
              OBJECT_VERSION_NUMBER, TYPE_CODE)
    values (IEC_G_CAL_CALLABLE_RGNS_S.NEXTVAL,l_day_copyto_id,v_copy.CALLABLE_REGION_CODE,
        v_copy.START_TIME, v_copy.END_TIME,p_createdBy, p_creationDate,p_updatedBy,p_updateDate,
        p_updateLogin, p_versionNumber,v_copy.TYPE_CODE);
  end loop;
  commit;

END Copy_Calendar_Day;

END IEC_ADMIN_PVT;


/
