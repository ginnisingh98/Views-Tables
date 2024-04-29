--------------------------------------------------------
--  DDL for Package Body AMS_SYNC_CALENDAR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SYNC_CALENDAR_PVT" AS
/* $Header: amsvcalb.pls 120.6 2006/07/28 07:26:01 anskumar noship $ */
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Sync_Cal_Items
(
        x_remove_only             IN     VARCHAR2 := FND_API.G_False,
        x_api_version             IN     NUMBER   := 1.0,
        x_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
        x_commit                  IN     VARCHAR2 := FND_API.G_False,
        x_return_status           OUT NOCOPY    VARCHAR2,
        x_msg_count               OUT NOCOPY    NUMBER,
        x_msg_data                OUT NOCOPY    VARCHAR2,
        x_criteria_rec            IN     cal_criteria_rec
)
IS
   CURSOR c_get_delete_csch_ids (x_criteria_rec cal_criteria_rec) IS
           SELECT obj.SCHEDULE_ID
           FROM AMS_CAMPAIGN_SCHEDULES_B obj, AMS_CAMPAIGNS_ALL_B b, JTF_CAL_ITEMS_B cal
           WHERE   (obj.CUSTOM_SETUP_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.CUSTOM_SETUP_ID, x_criteria_rec.CUSTOM_SETUP_ID)
                   AND obj.schedule_id = cal.source_id
                   AND cal.source_code = 'AMS_CSCH'
                   AND obj.ACTIVITY_TYPE_CODE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.ACTIVITY_TYPE_CODE, x_criteria_rec.ACTIVITY_TYPE_CODE)
                   AND obj.ACTIVITY_ID = DECODE(x_criteria_rec.ACTIVITY_ID, NULL, obj.ACTIVITY_ID, x_criteria_rec.ACTIVITY_ID)
                   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
                   AND obj.SCHEDULE_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.SCHEDULE_ID, x_criteria_rec.OBJECT_ID)
                   AND obj.CAMPAIGN_ID = b.CAMPAIGN_ID
                   AND (
                                ( (b.private_flag = 'N') AND obj.STATUS_CODE NOT IN ('ACTIVE', 'AVAILABLE', 'NEW', 'PLANNING') ) --'CANCELLED', 'COMPLETED', 'CLOSED', 'ARCHIVED') )
                                OR ( (b.private_flag = 'Y') AND obj.STATUS_CODE NOT IN ('ACTIVE', 'AVAILABLE') )
                       )
                   AND obj.START_DATE_TIME IS NOT NULL
                   AND b.actual_exec_end_date IS NOT NULL
                   AND obj.START_DATE_TIME <= nvl(obj.END_DATE_TIME, b.actual_exec_end_date)
                   AND obj.TIMEZONE_ID IS NOT NULL
                   AND  (
                        (TRUNC(obj.START_DATE_TIME) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(obj.START_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
                        AND (TRUNC(nvl(obj.END_DATE_TIME, b.ACTUAL_EXEC_END_DATE)) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(nvl(obj.END_DATE_TIME, b.ACTUAL_EXEC_END_DATE)), TRUNC(x_criteria_rec.CRITERIA_END_DATE)))
                        )
                   );
   l_get_delete_csch_id_rec c_get_delete_csch_ids%ROWTYPE;

    --BugFix  4256877 ams_event_offers_vl to ams_event_offers_all_b

   CURSOR c_get_delete_eveo_ids (x_criteria_rec cal_criteria_rec) IS
           SELECT obj.EVENT_OFFER_ID
           FROM ams_event_offers_all_b obj, jtf_cal_items_b cal
           WHERE   (obj.SETUP_TYPE_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.SETUP_TYPE_ID, x_criteria_rec.CUSTOM_SETUP_ID)
                   AND obj.event_offer_id = cal.source_id
                   AND (cal.source_code = 'AMS_EVEO' or cal.source_code = 'AMS_EONE')
                   AND obj.EVENT_TYPE_CODE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.EVENT_TYPE_CODE, x_criteria_rec.ACTIVITY_TYPE_CODE)
                   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
                   AND obj.EVENT_OFFER_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.EVENT_OFFER_ID, x_criteria_rec.OBJECT_ID)
                   AND (
                        ( (obj.private_flag = 'N') AND obj.SYSTEM_STATUS_CODE NOT IN ('ACTIVE', 'AVAILABLE', 'NEW', 'PLANNING') )
                                OR ( (obj.private_flag = 'Y') AND obj.SYSTEM_STATUS_CODE NOT IN ('ACTIVE', 'AVAILABLE') )
                       )
                   AND obj.event_standalone_flag = DECODE(x_criteria_rec.OBJECT_TYPE, 'EVEO', 'N', 'EONE', 'Y')
                   AND obj.EVENT_START_DATE_TIME IS NOT NULL
                   AND obj.EVENT_END_DATE_TIME IS NOT NULL
                   AND obj.EVENT_START_DATE_TIME <= obj.EVENT_END_DATE_TIME
                   AND obj.TIMEZONE_ID IS NOT NULL
                   AND  (
                        (TRUNC(obj.EVENT_START_DATE_TIME) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(obj.EVENT_START_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
                        AND (TRUNC(obj.EVENT_END_DATE_TIME) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(obj.EVENT_END_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_END_DATE)))
                        )
                   );
   l_get_delete_eveo_id_rec c_get_delete_eveo_ids%ROWTYPE;

  --BugFix 4256877 qp_list_headers_vl to qp_list_headers_b

   CURSOR c_get_delete_offr_ids (x_criteria_rec cal_criteria_rec) IS
           SELECT obj.QP_LIST_HEADER_ID
           FROM OZF_OFFERS obj, qp_list_headers_b g, jtf_cal_items_b cal
           WHERE   (obj.CUSTOM_SETUP_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.CUSTOM_SETUP_ID, x_criteria_rec.CUSTOM_SETUP_ID)
                   AND obj.QP_LIST_HEADER_ID = cal.source_id
                   AND cal.source_code = 'AMS_OFFR'
                   AND obj.OFFER_TYPE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.OFFER_TYPE, x_criteria_rec.ACTIVITY_TYPE_CODE)
                   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
                   AND obj.QP_LIST_HEADER_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.QP_LIST_HEADER_ID, x_criteria_rec.OBJECT_ID)
                   AND obj.QP_LIST_HEADER_ID = g.LIST_HEADER_ID
                   AND (
                                ( (obj.confidential_flag = 'N') AND obj.STATUS_CODE NOT IN ('ACTIVE', 'AVAILABLE', 'NEW', 'PLANNING') )
                                OR ( (obj.confidential_flag = 'Y') AND obj.STATUS_CODE NOT IN ('ACTIVE', 'AVAILABLE') )
                       )
                   AND  (
                        (TRUNC(nvl(g.START_DATE_ACTIVE, obj.CREATION_DATE)) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(nvl(g.START_DATE_ACTIVE, obj.CREATION_DATE)), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
                   )
               );
   l_get_delete_offr_id_rec c_get_delete_offr_ids%ROWTYPE;

BEGIN
	IF (x_remove_only = FND_API.G_True) THEN
		Delete_Cal_Items(x_return_status	  => x_return_status,
				x_msg_count               => x_msg_count,
				x_msg_data                => x_msg_data,
				x_criteria_rec		  => x_criteria_rec
				);
	ELSE
		IF (x_criteria_rec.OBJECT_TYPE = 'CSCH') THEN
			OPEN c_get_delete_csch_ids(x_criteria_rec);
			LOOP
				FETCH c_get_delete_csch_ids INTO l_get_delete_csch_id_rec;
				IF (c_get_delete_csch_ids%NOTFOUND) THEN
					x_return_status := FND_API.G_RET_STS_SUCCESS;
					CLOSE c_get_delete_csch_ids;
					l_get_delete_csch_id_rec := NULL;
					EXIT;
				ELSE
					Delete_Cal_Items(x_return_status	  => x_return_status,
							x_msg_count               => x_msg_count,
							x_msg_data                => x_msg_data,
							x_obj_id		  => l_get_delete_csch_id_rec.SCHEDULE_ID,
							x_criteria_rec		  => x_criteria_rec
							);
				END IF;
			END LOOP;
		ELSE
			IF ((x_criteria_rec.OBJECT_TYPE = 'EVEO') OR (x_criteria_rec.OBJECT_TYPE = 'EONE')) THEN
				OPEN c_get_delete_eveo_ids(x_criteria_rec);
				LOOP
					FETCH c_get_delete_eveo_ids INTO l_get_delete_eveo_id_rec;
					IF (c_get_delete_eveo_ids%NOTFOUND) THEN
						x_return_status := FND_API.G_RET_STS_SUCCESS;
						CLOSE c_get_delete_eveo_ids;
						l_get_delete_eveo_id_rec := NULL;
						EXIT;
					ELSE
						Delete_Cal_Items(x_return_status	  => x_return_status,
								x_msg_count               => x_msg_count,
								x_msg_data                => x_msg_data,
								x_obj_id		  => l_get_delete_eveo_id_rec.EVENT_OFFER_ID,
								x_criteria_rec		  => x_criteria_rec
								);
					END IF;
				END LOOP;
			END IF;
			IF (x_criteria_rec.OBJECT_TYPE = 'OFFR') THEN
				OPEN c_get_delete_offr_ids(x_criteria_rec);
				LOOP
					FETCH c_get_delete_offr_ids INTO l_get_delete_offr_id_rec;
					IF (c_get_delete_offr_ids%NOTFOUND) THEN
						x_return_status := FND_API.G_RET_STS_SUCCESS;
						CLOSE c_get_delete_offr_ids;
						l_get_delete_offr_id_rec := NULL;
						EXIT;
					ELSE
						Delete_Cal_Items(x_return_status	  => x_return_status,
								x_msg_count               => x_msg_count,
								x_msg_data                => x_msg_data,
								x_obj_id		  => l_get_delete_offr_id_rec.QP_LIST_HEADER_ID,
								x_criteria_rec		  => x_criteria_rec
								);
					END IF;
				END LOOP;
			END IF;
	        END IF;
		Update_Cal_Items
		(
			x_return_status		  => x_return_status,
			x_msg_count               => x_msg_count,
			x_msg_data                => x_msg_data,
			x_criteria_rec		  => x_criteria_rec
		);
		Create_Cal_Items
		(
			x_return_status		  => x_return_status,
			x_msg_count               => x_msg_count,
			x_msg_data                => x_msg_data,
			x_criteria_rec		  => x_criteria_rec
		);
	END IF;
	COMMIT;
END Sync_Cal_Items;

PROCEDURE Create_Cal_Items
(
	x_full_mode               IN     VARCHAR2 := 'N',
	x_api_version             IN     NUMBER   := 1.0,
	x_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
	x_commit                  IN     VARCHAR2 := FND_API.G_False,
	x_return_status           OUT NOCOPY    VARCHAR2,
	x_msg_count               OUT NOCOPY    NUMBER,
	x_msg_data                OUT NOCOPY    VARCHAR2,
	x_criteria_rec            IN     cal_criteria_rec
)
IS
   CURSOR c_get_grp_id IS
  --BugFix  4256877
   SELECT B.GROUP_ID RESOURCE_ID
   FROM JTF_RS_GROUP_USAGES B, JTF_RS_GROUPS_B A
    WHERE B.USAGE = 'CALENDAR_ITEMS'
    AND A.GROUP_ID = B.GROUP_ID
    AND SYSDATE > A.START_DATE_ACTIVE
    AND (A.END_DATE_ACTIVE IS NULL OR
         A.END_DATE_ACTIVE >= SYSDATE);

   t_group_id JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   CURSOR c_get_cre_csch_items (x_criteria_rec cal_criteria_rec) IS
           SELECT obj.SCHEDULE_Id
                  , obj.START_DATE_TIME
                  , obj.END_DATE_TIME
                  , b.ACTUAL_EXEC_END_DATE      --End Date id the CSCH end date is null
                  , obj.TIMEZONE_ID     --TIMEZONE_ID
                  , obj.OBJECT_VERSION_NUMBER   --OBJECT_VERSION_NUMBER
                  , obj.CREATED_BY
                  , obj.CREATION_DATE
                  , obj.LAST_UPDATED_BY
                  , obj.LAST_UPDATE_DATE
                  , obj.LAST_UPDATE_LOGIN
           FROM AMS_CAMPAIGN_SCHEDULES_B obj, AMS_CAMPAIGNS_ALL_B b
           WHERE   (obj.CUSTOM_SETUP_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.CUSTOM_SETUP_ID, x_criteria_rec.CUSTOM_SETUP_ID)
                   AND obj.ACTIVITY_TYPE_CODE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.ACTIVITY_TYPE_CODE, x_criteria_rec.ACTIVITY_TYPE_CODE)
                   AND DECODE(x_criteria_rec.ACTIVITY_ID,NULL,-9999,obj.ACTIVITY_ID) = DECODE(x_criteria_rec.ACTIVITY_ID, NULL, -9999, x_criteria_rec.ACTIVITY_ID)
                   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
                   AND obj.SCHEDULE_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.SCHEDULE_ID, x_criteria_rec.OBJECT_ID)
                   AND DECODE(x_criteria_rec.PRIORITY_ID, NULL, '1', obj.PRIORITY) = DECODE(x_criteria_rec.PRIORITY_ID, NULL, '1', x_criteria_rec.PRIORITY_ID)
                   AND obj.CAMPAIGN_ID = b.CAMPAIGN_ID
                   AND (
                        ( (b.private_flag = 'N') AND obj.STATUS_CODE IN ('ACTIVE', 'AVAILABLE', 'NEW', 'PLANNING'))
                                OR ( (b.private_flag = 'Y') AND obj.STATUS_CODE IN ('ACTIVE', 'AVAILABLE') )
                        )
                   AND obj.START_DATE_TIME IS NOT NULL
                   AND b.ACTUAL_EXEC_END_DATE IS NOT NULL
                   AND obj.START_DATE_TIME <= nvl(obj.END_DATE_TIME, b.actual_exec_end_date)
                   AND obj.TIMEZONE_ID IS NOT NULL
                   AND NOT EXISTS ( SELECT 1
                                  FROM JTF_CAL_ITEMS_B cal
                                  WHERE cal.source_code = 'AMS_CSCH' --obj_type
                                  AND cal.source_id = obj.SCHEDULE_ID
                                  )
                   AND  (
                        (TRUNC(obj.START_DATE_TIME) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(obj.START_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
                        AND (TRUNC(nvl(obj.END_DATE_TIME, b.ACTUAL_EXEC_END_DATE)) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(nvl(obj.END_DATE_TIME, b.actual_exec_end_date)), TRUNC(x_criteria_rec.CRITERIA_END_DATE)))
                        )
                   );
   l_get_cre_csch_items_rec c_get_cre_csch_items%ROWTYPE;

--BugFix 4256877

   CURSOR c_get_cre_eveo_items (x_criteria_rec cal_criteria_rec) IS
           SELECT obj.EVENT_OFFER_ID                    --SOURCE_ID
                  , obj.EVENT_START_DATE_TIME           --START_DATE
                  , obj.EVENT_END_DATE_TIME             --END_DATE
                  , obj.TIMEZONE_ID                     --TIMEZONE_ID
                  , obj.OBJECT_VERSION_NUMBER           --OBJECT_VERSION_NUMBER
                  , obj.CREATED_BY
                  , obj.CREATION_DATE
                  , obj.LAST_UPDATED_BY
                  , obj.LAST_UPDATE_DATE
                  , obj.LAST_UPDATE_LOGIN
           FROM ams_event_offers_all_b obj
           WHERE   (obj.SETUP_TYPE_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.SETUP_TYPE_ID, x_criteria_rec.CUSTOM_SETUP_ID)
                   AND obj.EVENT_TYPE_CODE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.EVENT_TYPE_CODE, x_criteria_rec.ACTIVITY_TYPE_CODE)
                   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
                   AND obj.EVENT_OFFER_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.EVENT_OFFER_ID, x_criteria_rec.OBJECT_ID)
                   AND DECODE(x_criteria_rec.PRIORITY_ID, NULL, '1', obj.PRIORITY_TYPE_CODE) = DECODE(x_criteria_rec.PRIORITY_ID, NULL, '1', x_criteria_rec.PRIORITY_ID)
                   AND (
                        ( (obj.private_flag = 'N') AND obj.SYSTEM_STATUS_CODE IN ('ACTIVE', 'AVAILABLE', 'NEW', 'PLANNING'))
                                OR ( (obj.private_flag = 'Y') AND obj.SYSTEM_STATUS_CODE IN ('ACTIVE', 'AVAILABLE') )
                        )
                   AND obj.event_standalone_flag = DECODE(x_criteria_rec.OBJECT_TYPE, 'EVEO', 'N', 'EONE', 'Y')
                   AND obj.EVENT_START_DATE_TIME IS NOT NULL
                   AND obj.EVENT_END_DATE_TIME IS NOT NULL
                   AND obj.EVENT_START_DATE_TIME <= obj.EVENT_END_DATE_TIME
                   AND obj.TIMEZONE_ID IS NOT NULL
		   AND (obj.EVENT_OBJECT_TYPE = 'EVEO'  OR (obj.EVENT_OBJECT_TYPE = 'EONE' AND (obj.parent_type is NULL OR obj.parent_type <>'CAMP')))
                   AND NOT EXISTS ( SELECT 1
                                  FROM JTF_CAL_ITEMS_B cal
                                  WHERE ( (cal.source_code = 'AMS_EVEO') OR (cal.source_code = 'AMS_EONE') )			--obj_type
                                  AND cal.source_id = obj.EVENT_OFFER_ID
                                  )
                   AND  (
                        (TRUNC(obj.EVENT_START_DATE_TIME) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(obj.EVENT_START_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
                        AND (TRUNC(obj.EVENT_END_DATE_TIME) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(obj.EVENT_END_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_END_DATE)))
                        )
                   );
   l_get_cre_eveo_items_rec c_get_cre_eveo_items%ROWTYPE;

   CURSOR c_get_cre_offr_items (x_criteria_rec cal_criteria_rec) IS
           SELECT obj.QP_LIST_HEADER_ID		--SOURCE_ID
                  , g.START_DATE_ACTIVE         --START_DATE
                  , g.END_DATE_ACTIVE		--END_DATE
                  , obj.OBJECT_VERSION_NUMBER   --OBJECT_VERSION_NUMBER
                  , obj.CREATED_BY
                  , obj.CREATION_DATE
                  , obj.LAST_UPDATED_BY
                  , obj.LAST_UPDATE_DATE
                  , obj.LAST_UPDATE_LOGIN
           FROM OZF_OFFERS obj, qp_list_headers_b g
           WHERE   (obj.CUSTOM_SETUP_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.CUSTOM_SETUP_ID, x_criteria_rec.CUSTOM_SETUP_ID)
           AND obj.OFFER_TYPE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.OFFER_TYPE, x_criteria_rec.ACTIVITY_TYPE_CODE)
           AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
           AND obj.QP_LIST_HEADER_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.QP_LIST_HEADER_ID, x_criteria_rec.OBJECT_ID)
           AND obj.QP_LIST_HEADER_ID = g.LIST_HEADER_ID
                   AND (
                                ( (obj.confidential_flag = 'N') AND obj.STATUS_CODE IN ('ACTIVE', 'AVAILABLE', 'NEW', 'PLANNING'))
                                OR ( (obj.confidential_flag = 'Y') AND obj.STATUS_CODE IN ('ACTIVE', 'AVAILABLE') )
                        )
                   AND  (
                        (TRUNC(nvl(g.START_DATE_ACTIVE, obj.CREATION_DATE)) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(nvl(g.START_DATE_ACTIVE, obj.CREATION_DATE)), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
                        AND (TRUNC(nvl(g.END_DATE_ACTIVE, add_months(SYSDATE, 60))) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(nvl(g.END_DATE_ACTIVE, add_months(SYSDATE, 60))), TRUNC(x_criteria_rec.CRITERIA_END_DATE)))
                        )
                   AND NOT EXISTS ( SELECT 1
                                  FROM JTF_CAL_ITEMS_B cal
                                  WHERE cal.source_code = 'AMS_OFFR' --obj_type
                                  AND cal.source_id = obj.QP_LIST_HEADER_ID
                                  )
                   );
   l_get_cre_offr_items_rec c_get_cre_offr_items%ROWTYPE;

   l_jtf_cre_itm_rec JTF_CAL_ITEMS_PUB.calItemRec;
   l_cal_item_id NUMBER;

BEGIN
   OPEN c_get_grp_id;
   FETCH c_get_grp_id
   BULK COLLECT INTO t_group_id;
   CLOSE c_get_grp_id;

   IF t_group_id.COUNT > 0 THEN

   IF (x_criteria_rec.OBJECT_TYPE = 'CSCH') THEN
           OPEN c_get_cre_csch_items(x_criteria_rec);
           LOOP
                FETCH c_get_cre_csch_items INTO l_get_cre_csch_items_rec;
                IF (c_get_cre_csch_items%NOTFOUND) THEN
                        x_return_status := FND_API.G_RET_STS_SUCCESS;
                CLOSE c_get_cre_csch_items;
                        l_get_cre_csch_items_rec := NULL;
                        EXIT;
                ELSE
                        l_jtf_cre_itm_rec.CAL_RESOURCE_TYPE := 'RS_GROUP'; --x_criteria_rec.RESOURCE_TYPE;
                        l_jtf_cre_itm_rec.ITEM_TYPE_CODE := 'CALENDAR';
                        l_jtf_cre_itm_rec.ITEM_NAME := ''; --l_get_cre_csch_items_rec.SCHEDULE_NAME;
                        l_jtf_cre_itm_rec.ITEM_DESCRIPTION := ''; --l_get_cre_csch_items_rec.DESCRIPTION;
                        l_jtf_cre_itm_rec.SOURCE_CODE := 'AMS_CSCH'; --l_get_cre_csch_items_rec.SOURCE_CODE;
                        l_jtf_cre_itm_rec.SOURCE_ID := l_get_cre_csch_items_rec.SCHEDULE_ID;
                        l_jtf_cre_itm_rec.START_DATE := l_get_cre_csch_items_rec.START_DATE_TIME;

                        IF (l_get_cre_csch_items_rec.END_DATE_TIME IS NOT NULL) THEN
                                l_jtf_cre_itm_rec.END_DATE := l_get_cre_csch_items_rec.END_DATE_TIME;
                        ELSE
                                l_jtf_cre_itm_rec.END_DATE := l_get_cre_csch_items_rec.ACTUAL_EXEC_END_DATE;
                        END IF;

                        l_jtf_cre_itm_rec.TIMEZONE_ID := l_get_cre_csch_items_rec.TIMEZONE_ID;
                        l_jtf_cre_itm_rec.URL := NULL ;
                        l_jtf_cre_itm_rec.CREATED_BY := l_get_cre_csch_items_rec.CREATED_BY;
                        l_jtf_cre_itm_rec.CREATION_DATE := l_get_cre_csch_items_rec.CREATION_DATE;
                        l_jtf_cre_itm_rec.LAST_UPDATED_BY := l_get_cre_csch_items_rec.LAST_UPDATED_BY;
                        l_jtf_cre_itm_rec.LAST_UPDATE_DATE := l_get_cre_csch_items_rec.LAST_UPDATE_DATE;
                        l_jtf_cre_itm_rec.LAST_UPDATE_LOGIN := l_get_cre_csch_items_rec.LAST_UPDATE_LOGIN;
                        l_jtf_cre_itm_rec.OBJECT_VERSION_NUMBER := l_get_cre_csch_items_rec.OBJECT_VERSION_NUMBER;
                        l_jtf_cre_itm_rec.APPLICATION_ID := '530';

                        FOR i in t_group_id.FIRST .. t_group_id.LAST LOOP
                                        l_jtf_cre_itm_rec.CAL_RESOURCE_ID := t_group_id(i);
                                                JTF_CAL_ITEMS_PUB.CREATEITEM( p_api_version => '1.0'    --x_api_version
                                                                 , x_return_status => x_return_status
                                                                 , x_msg_count => x_msg_count
                                                                 , x_msg_data => x_msg_data
                                                                 , p_itm_rec => l_jtf_cre_itm_rec
                                                                 , x_cal_item_id => l_cal_item_id
                                                                 );
                        END LOOP;
                END IF;
           END LOOP;
   END IF;

   IF ((x_criteria_rec.OBJECT_TYPE = 'EVEO') OR (x_criteria_rec.OBJECT_TYPE = 'EONE')) THEN
	   OPEN c_get_cre_eveo_items(x_criteria_rec);
	   LOOP
		FETCH c_get_cre_eveo_items INTO l_get_cre_eveo_items_rec;
		IF (c_get_cre_eveo_items%NOTFOUND) THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			CLOSE c_get_cre_eveo_items;
			l_get_cre_eveo_items_rec := NULL;
			EXIT;
		ELSE
			l_jtf_cre_itm_rec.CAL_RESOURCE_TYPE := 'RS_GROUP'; --x_criteria_rec.RESOURCE_TYPE;
			l_jtf_cre_itm_rec.ITEM_TYPE_CODE := 'CALENDAR';
			l_jtf_cre_itm_rec.ITEM_NAME := ''; --l_get_cre_eveo_items_rec.EVENT_OFFER_NAME; --append campaign name?
			l_jtf_cre_itm_rec.ITEM_DESCRIPTION := ''; --l_get_cre_eveo_items_rec.description;
			IF (x_criteria_rec.OBJECT_TYPE = 'EVEO') THEN
				l_jtf_cre_itm_rec.SOURCE_CODE := 'AMS_EVEO'; --l_get_cre_eveo_items_rec.SOURCE_CODE;
			END IF;
			IF (x_criteria_rec.OBJECT_TYPE = 'EONE') THEN
				l_jtf_cre_itm_rec.SOURCE_CODE := 'AMS_EONE'; --l_get_cre_eveo_items_rec.SOURCE_CODE;
			END IF;
			l_jtf_cre_itm_rec.SOURCE_ID := l_get_cre_eveo_items_rec.EVENT_OFFER_ID;
			l_jtf_cre_itm_rec.START_DATE := l_get_cre_eveo_items_rec.EVENT_START_DATE_TIME;
			l_jtf_cre_itm_rec.END_DATE := l_get_cre_eveo_items_rec.EVENT_END_DATE_TIME;
			l_jtf_cre_itm_rec.TIMEZONE_ID := l_get_cre_eveo_items_rec.TIMEZONE_ID;
			l_jtf_cre_itm_rec.URL := NULL ;
			l_jtf_cre_itm_rec.CREATED_BY := l_get_cre_eveo_items_rec.CREATED_BY;
			l_jtf_cre_itm_rec.CREATION_DATE := l_get_cre_eveo_items_rec.CREATION_DATE;
			l_jtf_cre_itm_rec.LAST_UPDATED_BY := l_get_cre_eveo_items_rec.LAST_UPDATED_BY;
			l_jtf_cre_itm_rec.LAST_UPDATE_DATE := l_get_cre_eveo_items_rec.LAST_UPDATE_DATE;
			l_jtf_cre_itm_rec.LAST_UPDATE_LOGIN := l_get_cre_eveo_items_rec.LAST_UPDATE_LOGIN;
			l_jtf_cre_itm_rec.OBJECT_VERSION_NUMBER := l_get_cre_eveo_items_rec.OBJECT_VERSION_NUMBER;
			l_jtf_cre_itm_rec.APPLICATION_ID := '530';

                        FOR i in t_group_id.FIRST .. t_group_id.LAST LOOP
                                        l_jtf_cre_itm_rec.CAL_RESOURCE_ID := t_group_id(i);

					JTF_CAL_ITEMS_PUB.CREATEITEM( p_api_version => '1.0' --x_api_version
								 , x_return_status => x_return_status
								 , x_msg_count => x_msg_count
								 , x_msg_data => x_msg_data
								 , p_itm_rec => l_jtf_cre_itm_rec
								 , x_cal_item_id => l_cal_item_id
								 );
                        END LOOP;
		END IF;
	   END LOOP;
   END IF;

   IF (x_criteria_rec.OBJECT_TYPE = 'OFFR') THEN
	   OPEN c_get_cre_offr_items(x_criteria_rec);
	   LOOP
		FETCH c_get_cre_offr_items INTO l_get_cre_offr_items_rec;
		IF (c_get_cre_offr_items%NOTFOUND) THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			CLOSE c_get_cre_offr_items;
			l_get_cre_offr_items_rec := NULL;
			EXIT;
		ELSE
			l_jtf_cre_itm_rec.CAL_RESOURCE_TYPE := 'RS_GROUP'; --x_criteria_rec.RESOURCE_TYPE;
			l_jtf_cre_itm_rec.ITEM_TYPE_CODE := 'CALENDAR';
			l_jtf_cre_itm_rec.ITEM_NAME := ''; --l_get_cre_offr_items_rec.name;
			l_jtf_cre_itm_rec.ITEM_DESCRIPTION := ''; --l_get_cre_offr_items_rec.DESCRIPTION;
			l_jtf_cre_itm_rec.SOURCE_CODE := 'AMS_OFFR'; --l_get_cre_offr_items_rec.SOURCE_CODE;
			l_jtf_cre_itm_rec.SOURCE_ID := l_get_cre_offr_items_rec.QP_LIST_HEADER_ID;


			IF (l_get_cre_offr_items_rec.START_DATE_ACTIVE IS NOT NULL) THEN
				l_jtf_cre_itm_rec.START_DATE := l_get_cre_offr_items_rec.START_DATE_ACTIVE;
			ELSE
				l_jtf_cre_itm_rec.START_DATE := l_get_cre_offr_items_rec.CREATION_DATE;
			END IF;

			IF (l_get_cre_offr_items_rec.END_DATE_ACTIVE IS NOT NULL) THEN
				l_jtf_cre_itm_rec.END_DATE := l_get_cre_offr_items_rec.END_DATE_ACTIVE;
			ELSE
				l_jtf_cre_itm_rec.END_DATE := add_months(SYSDATE, 60); --add 5 years here
			END IF;

			l_jtf_cre_itm_rec.TIMEZONE_ID := '4';	--Pacific Standard Timezone ID
			l_jtf_cre_itm_rec.URL := NULL ;
			l_jtf_cre_itm_rec.CREATED_BY := l_get_cre_offr_items_rec.CREATED_BY;
			l_jtf_cre_itm_rec.CREATION_DATE := l_get_cre_offr_items_rec.CREATION_DATE;
			l_jtf_cre_itm_rec.LAST_UPDATED_BY := l_get_cre_offr_items_rec.LAST_UPDATED_BY;
			l_jtf_cre_itm_rec.LAST_UPDATE_DATE := l_get_cre_offr_items_rec.LAST_UPDATE_DATE;
			l_jtf_cre_itm_rec.LAST_UPDATE_LOGIN := l_get_cre_offr_items_rec.LAST_UPDATE_LOGIN;
			l_jtf_cre_itm_rec.OBJECT_VERSION_NUMBER := l_get_cre_offr_items_rec.OBJECT_VERSION_NUMBER;
			l_jtf_cre_itm_rec.APPLICATION_ID := '530';

                        FOR i in t_group_id.FIRST .. t_group_id.LAST LOOP
                                        l_jtf_cre_itm_rec.CAL_RESOURCE_ID := t_group_id(i);

					JTF_CAL_ITEMS_PUB.CREATEITEM( p_api_version => '1.0' --x_api_version
								 , x_return_status => x_return_status
								 , x_msg_count => x_msg_count
								 , x_msg_data => x_msg_data
								 , p_itm_rec => l_jtf_cre_itm_rec
								 , x_cal_item_id => l_cal_item_id
								 );
                        END LOOP;

		END IF;
	   END LOOP;
   END IF;
  END IF; -- COUNT
COMMIT;
END Create_Cal_Items;

PROCEDURE Update_Cal_Items
(
	x_full_mode		  IN     VARCHAR2 := 'N',
	x_api_version             IN     NUMBER   := 1.0,
	x_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
	x_commit                  IN     VARCHAR2 := FND_API.G_False,
	x_return_status		  OUT NOCOPY    VARCHAR2,
	x_msg_count               OUT NOCOPY    NUMBER,
	x_msg_data                OUT NOCOPY    VARCHAR2,
	x_criteria_rec		  IN	 cal_criteria_rec
)
IS
   CURSOR c_get_grp_id IS
   SELECT B.GROUP_ID RESOURCE_ID
   FROM JTF_RS_GROUP_USAGES B, JTF_RS_GROUPS_B A
    WHERE B.USAGE = 'CALENDAR_ITEMS'
    AND A.GROUP_ID = B.GROUP_ID
    AND SYSDATE > A.START_DATE_ACTIVE
    AND (A.END_DATE_ACTIVE IS NULL OR
        A.END_DATE_ACTIVE >= SYSDATE);  -- BugFix 4256877 jtf_rs_groups_vl to jtf_rs_groups_b
   t_group_id JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   --BugFix 4256877 AMS_CAMPAIGNS_V to AMS_CAMPAIGNS_ALL_B

   CURSOR c_get_upd_csch_items (x_criteria_rec cal_criteria_rec) IS
	   SELECT obj.SCHEDULE_ID		--SOURCE_ID
		  , obj.START_DATE_TIME         --START_DATE
		  , obj.END_DATE_TIME		--END_DATE
		  , b.ACTUAL_EXEC_END_DATE
		  , obj.TIMEZONE_ID		--TIMEZONE_ID
		  , obj.OBJECT_VERSION_NUMBER   --OBJECT_VERSION_NUMBER
		  , obj.CREATED_BY
		  , obj.CREATION_DATE
		  , obj.LAST_UPDATED_BY
		  , obj.LAST_UPDATE_DATE
		  , obj.LAST_UPDATE_LOGIN
  	   FROM AMS_CAMPAIGN_SCHEDULES_B obj, AMS_CAMPAIGNS_ALL_B b, JTF_CAL_ITEMS_B cal
	   WHERE   (obj.CUSTOM_SETUP_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.CUSTOM_SETUP_ID, x_criteria_rec.CUSTOM_SETUP_ID)
                   AND cal.source_code = 'AMS_CSCH'
                   AND cal.source_id = obj.SCHEDULE_ID
                   AND ( cal.start_date <> obj.START_DATE_TIME
                              OR cal.end_date <> nvl(obj.END_DATE_TIME, b.actual_exec_end_date)
                              OR cal.timezone_id <> obj.TIMEZONE_ID
                              OR cal.OBJECT_VERSION_NUMBER <> obj.OBJECT_VERSION_NUMBER
                       )
		   AND obj.ACTIVITY_TYPE_CODE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.ACTIVITY_TYPE_CODE, x_criteria_rec.ACTIVITY_TYPE_CODE)
		   AND DECODE(x_criteria_rec.ACTIVITY_ID,NULL,-9999,obj.ACTIVITY_ID) = DECODE(x_criteria_rec.ACTIVITY_ID, NULL, -9999, x_criteria_rec.ACTIVITY_ID)
		   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
		   AND obj.SCHEDULE_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.SCHEDULE_ID, x_criteria_rec.OBJECT_ID)
		   AND DECODE(x_criteria_rec.PRIORITY_ID, NULL, '1', obj.PRIORITY) = DECODE(x_criteria_rec.PRIORITY_ID, NULL, '1', x_criteria_rec.PRIORITY_ID)
		   AND obj.CAMPAIGN_ID = b.CAMPAIGN_ID
		   AND (
				( (b.private_flag = 'N') AND obj.STATUS_CODE IN ('ACTIVE', 'AVAILABLE', 'NEW', 'PLANNING'))
				OR ( (b.private_flag = 'Y') AND obj.STATUS_CODE IN ('ACTIVE', 'AVAILABLE') )
			)
		   AND obj.START_DATE_TIME IS NOT NULL
		   AND b.ACTUAL_EXEC_END_DATE IS NOT NULL
		   AND obj.START_DATE_TIME <= nvl(obj.END_DATE_TIME, b.actual_exec_end_date)
		   AND obj.TIMEZONE_ID IS NOT NULL
		   AND  (
			(TRUNC(obj.START_DATE_TIME) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(obj.START_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
			AND (TRUNC(nvl(obj.END_DATE_TIME, b.ACTUAL_EXEC_END_DATE)) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(nvl(obj.END_DATE_TIME, b.actual_exec_end_date)), TRUNC(x_criteria_rec.CRITERIA_END_DATE)))
		        )
		   );
   l_get_upd_csch_items_rec c_get_upd_csch_items%ROWTYPE;

   CURSOR c_get_upd_eveo_items (x_criteria_rec cal_criteria_rec) IS
	   SELECT obj.EVENT_OFFER_ID		--SOURCE_ID
		  , obj.EVENT_START_DATE_TIME   --START_DATE
		  , obj.EVENT_END_DATE_TIME	--END_DATE
		  , obj.TIMEZONE_ID		--TIMEZONE_ID
		  , obj.OBJECT_VERSION_NUMBER   --OBJECT_VERSION_NUMBER
		  , obj.CREATED_BY
		  , obj.CREATION_DATE
		  , obj.LAST_UPDATED_BY
		  , obj.LAST_UPDATE_DATE
		  , obj.LAST_UPDATE_LOGIN
  	   FROM ams_event_offers_all_b obj, JTF_CAL_ITEMS_B cal
	   WHERE   (obj.SETUP_TYPE_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.SETUP_TYPE_ID, x_criteria_rec.CUSTOM_SETUP_ID)
                   AND (cal.source_code = 'AMS_EVEO' OR cal.source_code = 'AMS_EONE')
                   AND cal.source_id = obj.EVENT_OFFER_ID
                   AND ( cal.start_date <> obj.EVENT_START_DATE_TIME
                      OR cal.end_date <> obj.EVENT_START_DATE_TIME
                      OR cal.timezone_id <> obj.TIMEZONE_ID
                      OR cal.OBJECT_VERSION_NUMBER <> obj.OBJECT_VERSION_NUMBER
                      )
		   AND obj.EVENT_TYPE_CODE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.EVENT_TYPE_CODE, x_criteria_rec.ACTIVITY_TYPE_CODE)
		   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
		   AND obj.EVENT_OFFER_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.EVENT_OFFER_ID, x_criteria_rec.OBJECT_ID)
		   AND DECODE(x_criteria_rec.PRIORITY_ID, NULL, '1', obj.PRIORITY_TYPE_CODE) = DECODE(x_criteria_rec.PRIORITY_ID, NULL, '1', x_criteria_rec.PRIORITY_ID)
		   AND (
				( (obj.private_flag = 'N') AND obj.SYSTEM_STATUS_CODE IN ('ACTIVE', 'AVAILABLE', 'NEW', 'PLANNING'))
				OR ( (obj.private_flag = 'Y') AND obj.SYSTEM_STATUS_CODE IN ('ACTIVE', 'AVAILABLE') )
			)
		   AND obj.EVENT_START_DATE_TIME IS NOT NULL
		   AND obj.EVENT_END_DATE_TIME IS NOT NULL
		   AND obj.EVENT_START_DATE_TIME <= obj.EVENT_END_DATE_TIME
		   AND obj.TIMEZONE_ID IS NOT NULL
		   AND  (
			(TRUNC(obj.EVENT_START_DATE_TIME) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(obj.EVENT_START_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
			AND (TRUNC(obj.EVENT_END_DATE_TIME) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(obj.EVENT_END_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_END_DATE)))
   		        )
		   AND obj.event_standalone_flag = DECODE(x_criteria_rec.OBJECT_TYPE, 'EVEO', 'N', 'EONE', 'Y')
		   );
   l_get_upd_eveo_items_rec c_get_upd_eveo_items%ROWTYPE;

   CURSOR c_get_upd_offr_items (x_criteria_rec cal_criteria_rec) IS
	   SELECT obj.QP_LIST_HEADER_ID		--SOURCE_ID
		  , g.START_DATE_ACTIVE         --START_DATE
		  , g.END_DATE_ACTIVE		--END_DATE
		  , obj.OBJECT_VERSION_NUMBER   --OBJECT_VERSION_NUMBER
		  , obj.CREATED_BY
		  , obj.CREATION_DATE
		  , obj.LAST_UPDATED_BY
		  , obj.LAST_UPDATE_DATE
		  , obj.LAST_UPDATE_LOGIN
  	   FROM OZF_OFFERS obj  , qp_list_headers_b g, JTF_CAL_ITEMS_B cal
	   WHERE   (obj.CUSTOM_SETUP_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.CUSTOM_SETUP_ID, x_criteria_rec.CUSTOM_SETUP_ID)
                   AND cal.source_code = 'AMS_OFFR'
                   AND cal.source_id = obj.QP_LIST_HEADER_ID
                   AND ( cal.start_date <> nvl(g.START_DATE_ACTIVE, obj.CREATION_DATE)
                              OR DECODE(g.END_DATE_ACTIVE, null, SYSDATE, cal.end_date) <> nvl(g.END_DATE_ACTIVE, SYSDATE)
                              OR cal.OBJECT_VERSION_NUMBER <> obj.OBJECT_VERSION_NUMBER
                       )
		   AND obj.OFFER_TYPE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.OFFER_TYPE, x_criteria_rec.ACTIVITY_TYPE_CODE)
		   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
		   AND obj.QP_LIST_HEADER_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.QP_LIST_HEADER_ID, x_criteria_rec.OBJECT_ID)
		   AND obj.QP_LIST_HEADER_ID = g.LIST_HEADER_ID
		   AND (
				( (obj.confidential_flag = 'N') AND obj.STATUS_CODE IN ('ACTIVE', 'AVAILABLE', 'NEW', 'PLANNING'))
				OR ( (obj.confidential_flag = 'Y') AND obj.STATUS_CODE IN ('ACTIVE', 'AVAILABLE') )
			)
		   AND  (
			(TRUNC(nvl(g.START_DATE_ACTIVE, obj.CREATION_DATE)) >= DECODE( x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(nvl(g.START_DATE_ACTIVE, obj.CREATION_DATE)), TRUNC(x_criteria_rec.CRITERIA_START_DATE) ) )
			AND (TRUNC(nvl(g.END_DATE_ACTIVE, add_months(SYSDATE, 60))) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(nvl(g.END_DATE_ACTIVE, add_months(SYSDATE, 60))), TRUNC(x_criteria_rec.CRITERIA_END_DATE) ) )
		        )
		   );
   l_get_upd_offr_items_rec c_get_upd_offr_items%ROWTYPE;

   l_jtf_upd_itm_rec JTF_CAL_ITEMS_PUB.calItemRec;
   l_cal_obj_ver_number NUMBER;
--BugFix 4676786 sikalyan
 CURSOR c_get_cal_item_id (l_source_id NUMBER, l_resource_id NUMBER) IS
	 SELECT cal_item_id, resource_id, source_id, jcal.object_version_number
       FROM JTF_CAL_ITEMS_B jcal,	 ams_campaign_schedules_b camp
      where camp.schedule_id = jcal.source_id and jcal.source_id = l_source_id and  jcal.resource_id = l_resource_id ;

  l_get_cal_item_rec c_get_cal_item_id%ROWTYPE;

  CURSOR c_get_e_cal_item_id (l_source_id NUMBER, l_resource_id NUMBER) IS
	 SELECT cal_item_id, resource_id, source_id, jcal.object_version_number
       FROM JTF_CAL_ITEMS_B jcal,	 ams_event_offers_all_b aevent
      where aevent.event_offer_id = jcal.source_id and jcal.source_id = l_source_id and  jcal.resource_id = l_resource_id ;

   l_get_e_cal_item_rec c_get_e_cal_item_id%ROWTYPE;

   CURSOR c_get_o_cal_item_id (l_source_id NUMBER, l_resource_id NUMBER) IS
	 SELECT cal_item_id, resource_id, source_id, jcal.object_version_number
       FROM JTF_CAL_ITEMS_B jcal,	 ozf_offers qlh
      where qlh.qp_list_header_id = jcal.source_id and jcal.source_id = l_source_id and  jcal.resource_id = l_resource_id ;

    l_get_o_cal_item_rec  c_get_o_cal_item_id%ROWTYPE;

BEGIN
   OPEN c_get_grp_id;
   FETCH c_get_grp_id
   BULK COLLECT INTO t_group_id;
   CLOSE c_get_grp_id;

   IF t_group_id.COUNT > 0 THEN

   IF (x_criteria_rec.OBJECT_TYPE = 'CSCH') THEN
	   OPEN c_get_upd_csch_items(x_criteria_rec);
	   LOOP
		FETCH c_get_upd_csch_items INTO l_get_upd_csch_items_rec;
		IF (c_get_upd_csch_items%NOTFOUND) THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			CLOSE c_get_upd_csch_items;
			l_get_upd_csch_items_rec := NULL;
			EXIT;
		ELSE
			l_jtf_upd_itm_rec.CAL_RESOURCE_TYPE := 'RS_GROUP';
			l_jtf_upd_itm_rec.ITEM_TYPE_CODE := 'CALENDAR';
			l_jtf_upd_itm_rec.ITEM_NAME := NULL; --l_get_upd_csch_items_rec.SCHEDULE_NAME;
			l_jtf_upd_itm_rec.ITEM_DESCRIPTION := NULL; --l_get_upd_csch_items_rec.DESCRIPTION;
			l_jtf_upd_itm_rec.SOURCE_CODE := 'AMS_CSCH';
			l_jtf_upd_itm_rec.SOURCE_ID := l_get_upd_csch_items_rec.SCHEDULE_ID;
			l_jtf_upd_itm_rec.START_DATE := l_get_upd_csch_items_rec.START_DATE_TIME;
			IF (l_get_upd_csch_items_rec.END_DATE_TIME IS NOT NULL) THEN
				l_jtf_upd_itm_rec.END_DATE := l_get_upd_csch_items_rec.END_DATE_TIME;
			ELSE
				l_jtf_upd_itm_rec.END_DATE := l_get_upd_csch_items_rec.ACTUAL_EXEC_END_DATE;
			END IF;

			l_jtf_upd_itm_rec.TIMEZONE_ID := l_get_upd_csch_items_rec.TIMEZONE_ID;
			l_jtf_upd_itm_rec.URL := NULL;
			l_jtf_upd_itm_rec.CREATED_BY := l_get_upd_csch_items_rec.CREATED_BY;
			l_jtf_upd_itm_rec.CREATION_DATE := l_get_upd_csch_items_rec.CREATION_DATE;
			l_jtf_upd_itm_rec.LAST_UPDATED_BY := l_get_upd_csch_items_rec.LAST_UPDATED_BY;
			l_jtf_upd_itm_rec.LAST_UPDATE_DATE := l_get_upd_csch_items_rec.LAST_UPDATE_DATE;
			l_jtf_upd_itm_rec.LAST_UPDATE_LOGIN := l_get_upd_csch_items_rec.LAST_UPDATE_LOGIN;
			l_jtf_upd_itm_rec.OBJECT_VERSION_NUMBER := l_get_upd_csch_items_rec.OBJECT_VERSION_NUMBER;
			l_jtf_upd_itm_rec.APPLICATION_ID := '530';

                        FOR i in t_group_id.FIRST .. t_group_id.LAST LOOP
                                        l_jtf_upd_itm_rec.CAL_RESOURCE_ID := t_group_id(i);

					-- get the CAL_ITEM_ID for each of the record under consideration
					--BugFix 4676786
					OPEN c_get_cal_item_id(l_jtf_upd_itm_rec.SOURCE_ID,l_jtf_upd_itm_rec.CAL_RESOURCE_ID);
					LOOP
					FETCH c_get_cal_item_id INTO l_get_cal_item_rec;
					IF (c_get_cal_item_id%NOTFOUND) THEN
						x_return_status := FND_API.G_RET_STS_SUCCESS;
						CLOSE c_get_cal_item_id;
						l_get_cal_item_rec := NULL;
						EXIT;
					ELSE
						l_jtf_upd_itm_rec.CAL_ITEM_ID := l_get_cal_item_rec.CAL_ITEM_ID;
						l_jtf_upd_itm_rec.OBJECT_VERSION_NUMBER := l_get_cal_item_rec.OBJECT_VERSION_NUMBER;
					--End BugFix 4676786
					JTF_CAL_ITEMS_PUB.UPDATEITEM( p_api_version => x_api_version
								 , p_init_msg_list => x_init_msg_list
								 , p_commit => x_commit
								 , x_return_status => x_return_status
								 , x_msg_count => x_msg_count
								 , x_msg_data => x_msg_data
								 , p_itm_rec => l_jtf_upd_itm_rec
								 , x_object_version_number =>l_cal_obj_ver_number
								 );
					 END IF;
				       END LOOP;
                        END LOOP;
		END IF;
	   END LOOP;
   END IF;

   IF ( (x_criteria_rec.OBJECT_TYPE = 'EVEO') OR (x_criteria_rec.OBJECT_TYPE = 'EONE') ) THEN
	   OPEN c_get_upd_eveo_items(x_criteria_rec);
	   LOOP
		FETCH c_get_upd_eveo_items INTO l_get_upd_eveo_items_rec;
		IF (c_get_upd_eveo_items%NOTFOUND) THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			CLOSE c_get_upd_eveo_items;
			l_get_upd_eveo_items_rec := NULL;
			EXIT;
		ELSE
			l_jtf_upd_itm_rec.CAL_RESOURCE_TYPE := 'RS_GROUP';
			l_jtf_upd_itm_rec.ITEM_TYPE_CODE := 'CALENDAR';
			l_jtf_upd_itm_rec.ITEM_NAME := NULL; --l_get_upd_eveo_items_rec.EVENT_OFFER_NAME;
			l_jtf_upd_itm_rec.ITEM_DESCRIPTION := NULL; --l_get_upd_eveo_items_rec.description;
			l_jtf_upd_itm_rec.SOURCE_CODE := 'AMS_'|| x_criteria_rec.OBJECT_TYPE;  ---Removed Hardcoded value for EONE UPDATE Bug: 5178344
			l_jtf_upd_itm_rec.SOURCE_ID := l_get_upd_eveo_items_rec.EVENT_OFFER_ID;
			l_jtf_upd_itm_rec.START_DATE := l_get_upd_eveo_items_rec.EVENT_START_DATE_TIME;
			l_jtf_upd_itm_rec.END_DATE := l_get_upd_eveo_items_rec.EVENT_END_DATE_TIME;
			l_jtf_upd_itm_rec.TIMEZONE_ID := l_get_upd_eveo_items_rec.TIMEZONE_ID;
			l_jtf_upd_itm_rec.URL := NULL;
			l_jtf_upd_itm_rec.CREATED_BY := l_get_upd_eveo_items_rec.CREATED_BY;
			l_jtf_upd_itm_rec.CREATION_DATE := l_get_upd_eveo_items_rec.CREATION_DATE;
			l_jtf_upd_itm_rec.LAST_UPDATED_BY := l_get_upd_eveo_items_rec.LAST_UPDATED_BY;
			l_jtf_upd_itm_rec.LAST_UPDATE_DATE := l_get_upd_eveo_items_rec.LAST_UPDATE_DATE;
			l_jtf_upd_itm_rec.LAST_UPDATE_LOGIN := l_get_upd_eveo_items_rec.LAST_UPDATE_LOGIN;
			l_jtf_upd_itm_rec.OBJECT_VERSION_NUMBER := l_get_upd_eveo_items_rec.OBJECT_VERSION_NUMBER;
			l_jtf_upd_itm_rec.APPLICATION_ID := '530';

                        FOR i in t_group_id.FIRST .. t_group_id.LAST LOOP
                                        l_jtf_upd_itm_rec.CAL_RESOURCE_ID := t_group_id(i);

					-- get the CAL_ITEM_ID for each of the record under consideration
					--BugFix 4676786
					OPEN c_get_e_cal_item_id(l_jtf_upd_itm_rec.SOURCE_ID,l_jtf_upd_itm_rec.CAL_RESOURCE_ID);
					LOOP
					FETCH c_get_e_cal_item_id INTO l_get_e_cal_item_rec;
					IF (c_get_e_cal_item_id%NOTFOUND) THEN
						x_return_status := FND_API.G_RET_STS_SUCCESS;
						CLOSE c_get_e_cal_item_id;
						l_get_e_cal_item_rec := NULL;
						EXIT;
					ELSE
						l_jtf_upd_itm_rec.CAL_ITEM_ID := l_get_e_cal_item_rec.CAL_ITEM_ID;
						l_jtf_upd_itm_rec.OBJECT_VERSION_NUMBER := l_get_e_cal_item_rec.OBJECT_VERSION_NUMBER;
					--End BugFix 4676786
					JTF_CAL_ITEMS_PUB.UPDATEITEM( p_api_version => x_api_version
								 , p_init_msg_list => x_init_msg_list
								 , p_commit => x_commit
								 , x_return_status => x_return_status
								 , x_msg_count => x_msg_count
								 , x_msg_data => x_msg_data
								 , p_itm_rec => l_jtf_upd_itm_rec
								 , x_object_version_number =>l_cal_obj_ver_number
								 );
					END IF;
				        END LOOP;
			END LOOP;
		END IF;
	   END LOOP;
   END IF;

   IF (x_criteria_rec.OBJECT_TYPE = 'OFFR') THEN
	   OPEN c_get_upd_offr_items(x_criteria_rec);
	   LOOP
		FETCH c_get_upd_offr_items INTO l_get_upd_offr_items_rec;
		IF (c_get_upd_offr_items%NOTFOUND) THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			CLOSE c_get_upd_offr_items;
			l_get_upd_offr_items_rec := NULL;
			EXIT;
		ELSE
			l_jtf_upd_itm_rec.CAL_RESOURCE_TYPE := 'RS_GROUP';
			l_jtf_upd_itm_rec.ITEM_TYPE_CODE := 'CALENDAR';
			l_jtf_upd_itm_rec.ITEM_NAME := NULL; --l_get_upd_offr_items_rec.name;
			l_jtf_upd_itm_rec.ITEM_DESCRIPTION := NULL; --l_get_upd_offr_items_rec.DESCRIPTION;
			l_jtf_upd_itm_rec.SOURCE_CODE := 'AMS_OFFR';
			l_jtf_upd_itm_rec.SOURCE_ID := l_get_upd_offr_items_rec.QP_LIST_HEADER_ID;
			IF (l_get_upd_offr_items_rec.START_DATE_ACTIVE IS NOT NULL) THEN
				l_jtf_upd_itm_rec.START_DATE := l_get_upd_offr_items_rec.START_DATE_ACTIVE;
			ELSE
				l_jtf_upd_itm_rec.START_DATE := l_get_upd_offr_items_rec.CREATION_DATE;
			END IF;

			IF (l_get_upd_offr_items_rec.END_DATE_ACTIVE IS NOT NULL) THEN
				l_jtf_upd_itm_rec.END_DATE := l_get_upd_offr_items_rec.END_DATE_ACTIVE;
			ELSE
				l_jtf_upd_itm_rec.END_DATE := add_months(SYSDATE, 60); --add 5 years here
			END IF;

			l_jtf_upd_itm_rec.TIMEZONE_ID := '4';   --l_get_upd_offr_items_rec.TIMEZONE_ID;
			l_jtf_upd_itm_rec.URL := NULL;
			l_jtf_upd_itm_rec.CREATED_BY := l_get_upd_offr_items_rec.CREATED_BY;
			l_jtf_upd_itm_rec.CREATION_DATE := l_get_upd_offr_items_rec.CREATION_DATE;
			l_jtf_upd_itm_rec.LAST_UPDATED_BY := l_get_upd_offr_items_rec.LAST_UPDATED_BY;
			l_jtf_upd_itm_rec.LAST_UPDATE_DATE := l_get_upd_offr_items_rec.LAST_UPDATE_DATE;
			l_jtf_upd_itm_rec.LAST_UPDATE_LOGIN := l_get_upd_offr_items_rec.LAST_UPDATE_LOGIN;
			l_jtf_upd_itm_rec.OBJECT_VERSION_NUMBER := l_get_upd_offr_items_rec.OBJECT_VERSION_NUMBER;
			l_jtf_upd_itm_rec.APPLICATION_ID := '530';

                        FOR i in t_group_id.FIRST .. t_group_id.LAST LOOP
                                        l_jtf_upd_itm_rec.CAL_RESOURCE_ID := t_group_id(i);

					-- get the CAL_ITEM_ID for each of the record under consideration
					--BugFix 4676786
					OPEN c_get_o_cal_item_id(l_jtf_upd_itm_rec.SOURCE_ID,l_jtf_upd_itm_rec.CAL_RESOURCE_ID);
					LOOP
					FETCH c_get_o_cal_item_id INTO l_get_o_cal_item_rec;
					IF (c_get_o_cal_item_id%NOTFOUND) THEN
						x_return_status := FND_API.G_RET_STS_SUCCESS;
						CLOSE c_get_o_cal_item_id;
						l_get_o_cal_item_rec := NULL;
						EXIT;
					ELSE
						l_jtf_upd_itm_rec.CAL_ITEM_ID := l_get_o_cal_item_rec.CAL_ITEM_ID;
						l_jtf_upd_itm_rec.OBJECT_VERSION_NUMBER := l_get_o_cal_item_rec.OBJECT_VERSION_NUMBER;
					--End BugFix 4676786
					JTF_CAL_ITEMS_PUB.UPDATEITEM( p_api_version => x_api_version
								 , p_init_msg_list => x_init_msg_list
								 , p_commit => x_commit
								 , x_return_status => x_return_status
								 , x_msg_count => x_msg_count
								 , x_msg_data => x_msg_data
								 , p_itm_rec => l_jtf_upd_itm_rec
								 , x_object_version_number =>l_cal_obj_ver_number
								 );
					END IF;
				        END LOOP;
			END LOOP;
		END IF;
	   END LOOP;
   END IF;
  END IF;
   COMMIT;
END Update_Cal_Items;

PROCEDURE Delete_Cal_Items
(	x_full_mode		  IN     VARCHAR2 := 'N',
	x_api_version             IN     NUMBER   := 1.0,
	x_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
	x_commit                  IN     VARCHAR2 := FND_API.G_False,
	x_return_status		  OUT NOCOPY    VARCHAR2,
	x_msg_count               OUT NOCOPY    NUMBER,
	x_msg_data                OUT NOCOPY    VARCHAR2,
	x_criteria_rec            IN     cal_criteria_rec,
	x_obj_id		  IN	 NUMBER := 0
)
IS

--------------------------------------------------------------------------------------------------------------------------------------
   CURSOR c_get_del_item (x_obj_id NUMBER) IS
	   SELECT cal.cal_item_id
		  ,cal.object_version_number
	   FROM JTF_CAL_ITEMS_B cal
	   WHERE  (cal.SOURCE_ID = x_obj_id);
   l_get_del_item_rec c_get_del_item%ROWTYPE;
--------------------------------------------------------------------------------------------------------------------------------------

   CURSOR c_get_del_csch_items (x_criteria_rec cal_criteria_rec) IS
	   SELECT cal.cal_item_id
		  , cal.object_version_number
	   FROM AMS_CAMPAIGN_SCHEDULES_B obj, JTF_CAL_ITEMS_B cal, AMS_CAMPAIGNS_ALL_B b
	   WHERE   (obj.CUSTOM_SETUP_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.CUSTOM_SETUP_ID, x_criteria_rec.CUSTOM_SETUP_ID)
		   AND obj.ACTIVITY_TYPE_CODE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.ACTIVITY_TYPE_CODE, x_criteria_rec.ACTIVITY_TYPE_CODE)
		   AND DECODE(x_criteria_rec.ACTIVITY_ID,NULL,-9999,obj.ACTIVITY_ID) = DECODE(x_criteria_rec.ACTIVITY_ID, NULL, -9999, x_criteria_rec.ACTIVITY_ID)
		   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
		   AND obj.SCHEDULE_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.SCHEDULE_ID, x_criteria_rec.OBJECT_ID)
		   AND cal.SOURCE_ID(+) = obj.SCHEDULE_ID
		   AND obj.CAMPAIGN_ID = b.CAMPAIGN_ID
		   AND cal.cal_item_id IS NOT NULL
		   AND obj.START_DATE_TIME IS NOT NULL
		   AND b.ACTUAL_EXEC_END_DATE IS NOT NULL
		   AND obj.START_DATE_TIME <= nvl(obj.END_DATE_TIME, b.actual_exec_end_date)
		   AND obj.TIMEZONE_ID IS NOT NULL
		   AND  (
			(TRUNC(obj.START_DATE_TIME) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(obj.START_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
			AND (TRUNC(nvl(obj.END_DATE_TIME, b.ACTUAL_EXEC_END_DATE)) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(nvl(obj.END_DATE_TIME, b.actual_exec_end_date)), TRUNC(x_criteria_rec.CRITERIA_END_DATE)))
   		        )
		   );
   l_get_del_csch_items_rec c_get_del_csch_items%ROWTYPE;

  --BugFix

   CURSOR c_get_del_eveo_items (x_criteria_rec cal_criteria_rec) IS
	   SELECT cal.cal_item_id
		  , cal.object_version_number
	   FROM ams_event_offers_all_b obj, JTF_CAL_ITEMS_B cal
	   WHERE   (obj.SETUP_TYPE_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.SETUP_TYPE_ID, x_criteria_rec.CUSTOM_SETUP_ID)
		   AND obj.EVENT_TYPE_CODE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.EVENT_TYPE_CODE, x_criteria_rec.ACTIVITY_TYPE_CODE)
		   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
		   AND obj.EVENT_OFFER_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.EVENT_OFFER_ID, x_criteria_rec.OBJECT_ID)
		   AND cal.SOURCE_ID(+) = obj.EVENT_OFFER_ID
		   AND obj.event_standalone_flag = DECODE(x_criteria_rec.OBJECT_TYPE, 'EVEO', 'N', 'EONE', 'Y')
		   AND cal.cal_item_id IS NOT NULL
		   AND obj.EVENT_START_DATE_TIME IS NOT NULL
		   AND obj.EVENT_END_DATE_TIME IS NOT NULL
		   AND obj.EVENT_START_DATE_TIME <= obj.EVENT_END_DATE_TIME
		   AND obj.TIMEZONE_ID IS NOT NULL
		   AND  (
			(TRUNC(obj.EVENT_START_DATE_TIME) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(obj.EVENT_START_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
			AND (TRUNC(obj.EVENT_END_DATE_TIME) <= DECODE(x_criteria_rec.CRITERIA_END_DATE, NULL, TRUNC(obj.EVENT_END_DATE_TIME), TRUNC(x_criteria_rec.CRITERIA_END_DATE)))
   		        )
		   );
   l_get_del_eveo_items_rec c_get_del_eveo_items%ROWTYPE;

   CURSOR c_get_del_offr_items (x_criteria_rec cal_criteria_rec) IS
	   SELECT cal.cal_item_id
		  , cal.object_version_number
	   FROM OZF_OFFERS obj, JTF_CAL_ITEMS_B cal, qp_list_headers_vl g
	   WHERE   (obj.CUSTOM_SETUP_ID = DECODE(x_criteria_rec.CUSTOM_SETUP_ID, NULL, obj.CUSTOM_SETUP_ID, x_criteria_rec.CUSTOM_SETUP_ID)
		   AND obj.OFFER_TYPE = DECODE(x_criteria_rec.ACTIVITY_TYPE_CODE, NULL, obj.OFFER_TYPE, x_criteria_rec.ACTIVITY_TYPE_CODE)
		   AND obj.USER_STATUS_ID = DECODE(x_criteria_rec.STATUS_ID, NULL, obj.USER_STATUS_ID, x_criteria_rec.STATUS_ID)
		   AND obj.QP_LIST_HEADER_ID = DECODE(x_criteria_rec.OBJECT_ID, NULL, obj.QP_LIST_HEADER_ID, x_criteria_rec.OBJECT_ID)
		   AND cal.SOURCE_ID(+) = obj.QP_LIST_HEADER_ID
		   AND g.LIST_HEADER_ID = obj.QP_LIST_HEADER_ID
		   AND cal.cal_item_id IS NOT NULL
		   AND  (
			(TRUNC(nvl(g.START_DATE_ACTIVE, obj.CREATION_DATE)) >= DECODE(x_criteria_rec.CRITERIA_START_DATE, NULL, TRUNC(nvl(g.START_DATE_ACTIVE, obj.CREATION_DATE)), TRUNC(x_criteria_rec.CRITERIA_START_DATE)))
   		        )
		   );
   l_get_del_offr_items_rec c_get_del_offr_items%ROWTYPE;
--------------------------------------------------------------------------------------------------------------------------------------
BEGIN
	IF (x_obj_id > 0) THEN
		OPEN C_GET_DEL_ITEM(x_obj_id);
		FETCH C_GET_DEL_ITEM INTO l_get_del_item_rec;
		IF (C_GET_DEL_ITEM%NOTFOUND) THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			CLOSE C_GET_DEL_ITEM;
			l_get_del_item_rec := NULL;
		ELSE
			JTF_CAL_ITEMS_PUB.DELETEITEM( p_api_version => x_api_version
						 , p_init_msg_list => x_init_msg_list
						 , p_commit => x_commit
						 , x_return_status => x_return_status
						 , x_msg_count => x_msg_count
						 , x_msg_data => x_msg_data
						 , p_cal_item_id  => l_get_del_item_rec.cal_item_id
						 , p_object_version_number => l_get_del_item_rec.object_version_number
						 );
		END IF;
	ELSE
		IF (x_criteria_rec.OBJECT_TYPE = 'CSCH') THEN
			OPEN c_get_del_csch_items(x_criteria_rec);
			LOOP
				FETCH c_get_del_csch_items INTO L_GET_DEL_CSCH_ITEMS_REC;
				IF (c_get_del_csch_items%NOTFOUND) THEN
					x_return_status := FND_API.G_RET_STS_SUCCESS;
					CLOSE c_get_del_csch_items;
					L_GET_DEL_CSCH_ITEMS_REC := NULL;
					EXIT;
				ELSE
					JTF_CAL_ITEMS_PUB.DELETEITEM( p_api_version => x_api_version
								 , p_init_msg_list => x_init_msg_list
								 , p_commit => x_commit
								 , x_return_status => x_return_status
								 , x_msg_count => x_msg_count
								 , x_msg_data => x_msg_data
								 , p_cal_item_id  => L_GET_DEL_CSCH_ITEMS_REC.cal_item_id
								 , p_object_version_number => L_GET_DEL_CSCH_ITEMS_REC.object_version_number
								 );
				END IF;
			END LOOP;
		END IF;

		IF ( (x_criteria_rec.OBJECT_TYPE = 'EVEO') OR (x_criteria_rec.OBJECT_TYPE = 'EONE') )THEN
			OPEN c_get_del_eveo_items(x_criteria_rec);
			LOOP
				FETCH c_get_del_eveo_items INTO l_get_del_eveo_items_rec;
				IF (c_get_del_eveo_items%NOTFOUND) THEN
					x_return_status := FND_API.G_RET_STS_SUCCESS;
					CLOSE c_get_del_eveo_items;
					l_get_del_eveo_items_rec := NULL;
					EXIT;
				ELSE
					JTF_CAL_ITEMS_PUB.DELETEITEM( p_api_version => x_api_version
								 , p_init_msg_list => x_init_msg_list
								 , p_commit => x_commit
								 , x_return_status => x_return_status
								 , x_msg_count => x_msg_count
								 , x_msg_data => x_msg_data
								 , p_cal_item_id  => l_get_del_eveo_items_rec.cal_item_id
								 , p_object_version_number => l_get_del_eveo_items_rec.object_version_number
								 );
				END IF;
			END LOOP;
		END IF;
		IF (x_criteria_rec.OBJECT_TYPE = 'OFFR') THEN
			OPEN c_get_del_offr_items(x_criteria_rec);
			LOOP
				FETCH c_get_del_offr_items INTO l_get_del_offr_items_rec;
				IF (c_get_del_offr_items%NOTFOUND) THEN
					x_return_status := FND_API.G_RET_STS_SUCCESS;
					CLOSE c_get_del_offr_items;
					l_get_del_offr_items_rec := NULL;
					EXIT;
				ELSE
					JTF_CAL_ITEMS_PUB.DELETEITEM( p_api_version => x_api_version
								 , p_init_msg_list => x_init_msg_list
								 , p_commit => x_commit
								 , x_return_status => x_return_status
								 , x_msg_count => x_msg_count
								 , x_msg_data => x_msg_data
								 , p_cal_item_id  => l_get_del_offr_items_rec.cal_item_id
								 , p_object_version_number => l_get_del_offr_items_rec.object_version_number
								 );
				END IF;
			END LOOP;
		END IF;
	END IF;
        COMMIT;
END Delete_Cal_Items;

END AMS_Sync_Calendar_PVT;

/
