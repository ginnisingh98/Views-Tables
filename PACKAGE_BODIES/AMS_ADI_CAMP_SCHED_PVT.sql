--------------------------------------------------------
--  DDL for Package Body AMS_ADI_CAMP_SCHED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ADI_CAMP_SCHED_PVT" AS
/* $Header: amsvadsb.pls 120.5 2006/03/14 03:00:27 mayjain noship $ */

type onameArray is table of ams_adi_campaigns_interface.object_name%type index by binary_integer;
type oidArray is table of ams_adi_campaigns_interface.object_id%type index by binary_integer;
type scodeArray is table of ams_adi_campaigns_interface.source_code%type index by binary_integer;
type dateArray is table of ams_adi_campaigns_interface.start_date%type index by binary_integer;
type timeArray is table of ams_adi_campaigns_interface.start_time%type index by binary_integer;
type objectiveArray is table of ams_adi_campaigns_interface.objective%type index by binary_integer;
type lookupCodeArray is table of ams_adi_campaigns_interface.approval_action_code%type index by binary_integer;
type flexAttrArray is table of ams_adi_campaigns_interface.attribute1%type index by binary_integer;
type flexContextArray is table of ams_adi_campaigns_interface.attribute_category%type index by binary_integer;
/* types added by mayjain */
type notesArray is table of ams_adi_campaigns_interface.notes%type index by binary_integer;
type puwsArray is table of ams_adi_campaigns_interface.pretty_url_website%type index by binary_integer;
type wptitleArray is table of ams_adi_campaigns_interface.wp_placement_title%type index by binary_integer;
type ctdAhParamArray is table of ams_adi_campaigns_interface.ctd_adhoc_param1%type index by binary_integer;
type ctdAhParamValArray is table of ams_adi_campaigns_interface.ctd_adhoc_param_val1%type index by binary_integer;
/* types added by mayjain */



AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_ADI_CAMP_SCHED_PVT';

ADI_DATE_FORMAT CONSTANT VARCHAR2(15) := 'DD-MON-RRRR';
ADI_TIME_FORMAT CONSTANT VARCHAR2(15) := 'HH24:MI:SS';

function Get_System_Status_Code(
    p_user_status_id IN NUMBER,
    p_system_status_type IN VARCHAR2
    )
return VARCHAR2
IS
BEGIN
null;
END;


function Get_Activity_Type_Code (
    p_activity_id IN NUMBER
    )
return VARCHAR2;


--========================================================================
-- PROCEDURE
--   Updates Campaign Schedules from Web ADI
-- Purpose
--    Updates Campaign Schedules based on Web ADI input in staging table AMS_ADI_CAMPAIGNS_INTERFACE
--    The algorithm is as follows :
--		1. call AMS_ADI_COMMON_PVT.init
--          2. BULK COLLECT data from staging table in batches of AMS_ADI_COMMON_PVT.g_batch_size(set as 100). Then for
--		   each batch do the following :
--			2.1. call AMS_ADI_COMMON_PVT.init_for_batch
--			2.2 repeat the following Steps for each Row
--				2.2.1 call Schedule UpdateAPI for each ROW
--				2.2.2 if successful, call AMS_ADI_COMMON_PVT.handleSuccesRow
--			    		else call AMS_ADI_COMMON_PVT.handleErrorRow
--			2.3 when done with batch, call AMS_ADI_COMMON_PVT.done_with_batch
--		3. call AMS_ADI_COMMON_PVT.done_with_all_rows
-- HISTORY
--
--========================================================================
PROCEDURE update_campaign_schedules(
x_errbuf        OUT NOCOPY    VARCHAR2,
x_retcode       OUT NOCOPY    NUMBER,
p_upload_batch_id IN NUMBER,
p_ui_instance_id IN NUMBER := 0
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
L_API_NAME                  CONSTANT VARCHAR2(30) := 'update_campaign_schedules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_schedule_rec AMS_Camp_Schedule_PUB.schedule_rec_type;
l_error_recs AMS_ADI_COMMON_PVT.ams_adi_error_rec_t := AMS_ADI_COMMON_PVT.ams_adi_error_rec_t();
l_batch_size PLS_INTEGER := AMS_ADI_COMMON_PVT.g_batch_size;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(4000);
l_object_version_number NUMBER;
l_avail_default_user_status NUMBER;

cursor c(l_upload_batch_id NUMBER) is
select a.object_id,a.object_name,a.parent_object_id,a.source_code,a.start_date,a.end_date,a.start_time,a.end_time,
a.marketing_medium_id,a.country_id,a.owner_user_id,a.timezone_id,a.objective,a.approval_action_code,a.user_status_id,a.status_code,
a.attribute1,a.attribute2,a.attribute3,a.attribute4,a.attribute5,a.attribute6,a.attribute7,a.attribute8,
a.attribute9,a.attribute10,a.attribute11,a.attribute12,a.attribute13,a.attribute14,a.attribute15,
a.activity_attribute1,a.activity_attribute2,a.activity_attribute3,a.activity_attribute4,a.activity_attribute5,
a.activity_attribute6,a.activity_attribute7,a.activity_attribute8,a.activity_attribute9,a.activity_attribute10,
a.activity_attribute11,a.activity_attribute12,a.activity_attribute13,a.activity_attribute14,a.activity_attribute15,
a.activity_attribute_category,a.object_version_number,a.currency_code,a.actual_activity_id,b.media_type_code
from ams_adi_campaigns_interface a, ams_media_b b
where a.upload_batch_id = l_upload_batch_id
and a.actual_activity_id = b.media_id(+)
and b.enabled_flag(+) = 'Y';

l_objectIds oidArray ;
l_objectNames onameArray;
l_parentIds oidArray ;
l_srcCodes scodeArray;
l_startDates dateArray;
l_endDates dateArray;
l_startTimes timeArray;
l_endTimes timeArray;
l_mktMediumIds oidArray;
l_countryIds oidArray;
l_ownerIds oidArray;
l_timezoneIds oidArray;
l_objectives objectiveArray;
l_apprActionCodes lookupCodeArray;
l_nextStatusIds oidArray;
l_nextStatusCodes lookupCodeArray;
l_currencyCodes lookupCodeArray;
l_attribute1s flexAttrArray;
l_attribute2s flexAttrArray;
l_attribute3s flexAttrArray;
l_attribute4s flexAttrArray;
l_attribute5s flexAttrArray;
l_attribute6s flexAttrArray;
l_attribute7s flexAttrArray;
l_attribute8s flexAttrArray;
l_attribute9s flexAttrArray;
l_attribute10s flexAttrArray;
l_attribute11s flexAttrArray;
l_attribute12s flexAttrArray;
l_attribute13s flexAttrArray;
l_attribute14s flexAttrArray;
l_attribute15s flexAttrArray;
l_actAttribute1s flexAttrArray;
l_actAttribute2s flexAttrArray;
l_actAttribute3s flexAttrArray;
l_actAttribute4s flexAttrArray;
l_actAttribute5s flexAttrArray;
l_actAttribute6s flexAttrArray;
l_actAttribute7s flexAttrArray;
l_actAttribute8s flexAttrArray;
l_actAttribute9s flexAttrArray;
l_actAttribute10s flexAttrArray;
l_actAttribute11s flexAttrArray;
l_actAttribute12s flexAttrArray;
l_actAttribute13s flexAttrArray;
l_actAttribute14s flexAttrArray;
l_actAttribute15s flexAttrArray;
l_actContexts flexContextArray;
l_objVersionNos oidArray;
l_activityIds oidArray;
l_activityTypes lookupCodeArray;

BEGIN
  FND_MSG_PUB.initialize;

  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start with batch id : '||p_upload_batch_id||' ui instance id : '||p_ui_instance_id);
 END IF;


   -- Initialize API return status to SUCCESS
   l_return_status := FND_API.G_RET_STS_SUCCESS;

 select user_status_id into l_avail_default_user_status
 from ams_user_statuses_vl
 where system_status_type = 'AMS_CAMPAIGN_SCHEDULE_STATUS'
 and system_status_code = 'AVAILABLE'
 and default_flag = 'Y';


  AMS_ADI_COMMON_PVT.init();

  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Start to read feom ams_adi_campaigns_interface with limit '||AMS_ADI_COMMON_PVT.g_batch_size);
 END IF;

open c(p_upload_batch_id);

--fetches data using BULK COLLECT but limited to AMS_ADI_COMMON_PVT.g_batch_size each time
loop
 fetch c BULK COLLECT
 into l_objectIds,l_objectNames,l_parentIds,l_srcCodes,l_startDates,l_endDates,l_startTimes,l_endTimes,l_mktMediumIds,
 l_countryIds,l_ownerIds,l_timezoneIds,l_objectives,l_apprActionCodes,l_nextStatusIds,l_nextStatusCodes,
 l_attribute1s,l_attribute2s,l_attribute3s,l_attribute4s,l_attribute5s,l_attribute6s,l_attribute7s,l_attribute8s,
 l_attribute9s,l_attribute10s,l_attribute11s,l_attribute12s,l_attribute13s,l_attribute14s,l_attribute15s,
 l_actAttribute1s,l_actAttribute2s,l_actAttribute3s,l_actAttribute4s,l_actAttribute5s,l_actAttribute6s,l_actAttribute7s,
 l_actAttribute8s,l_actAttribute9s,l_actAttribute10s,l_actAttribute11s,l_actAttribute12s,l_actAttribute13s,l_actAttribute14s,
 l_actAttribute15s,l_actContexts,l_objVersionNos,l_currencyCodes,l_activityIds,l_activityTypes
 limit AMS_ADI_COMMON_PVT.g_batch_size;


  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('done with fetch');
 END IF;

  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('calling init_for_batch');
 END IF;

  AMS_ADI_COMMON_PVT.init_for_batch(l_error_recs);  --initialize batch operation

  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Done init_for_batch with loopsize '||l_objectIds.COUNT);
 END IF;

  FOR i in l_objectIds.FIRST .. l_objectIds.LAST LOOP

     SAVEPOINT EXPORT_SCHEDULE;

     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('inside loop');
     END IF;

    --create a Schedule record object for calling Scheule Public API

     l_schedule_rec.schedule_id := l_objectIds(i);
     l_schedule_rec.schedule_name   := l_objectNames(i);
     IF(l_srcCodes(i) IS NOT NULL) THEN
       l_schedule_rec.source_code       := l_srcCodes(i);
     END IF;
     IF(l_startTimes(i) IS NOT NULL) THEN
       l_schedule_rec.start_date_time  := to_date (to_char(l_startDates(i), ADI_DATE_FORMAT) || ' ' ||l_startTimes(i), ADI_DATE_FORMAT || ' ' || ADI_TIME_FORMAT);
     ELSE
       l_schedule_rec.start_date_time := trunc(l_startDates(i));
     END IF;
     IF(l_endDates(i) IS NOT NULL) THEN
       l_schedule_rec.end_date_time     := to_date (to_char(l_endDates(i), ADI_DATE_FORMAT) || ' ' ||l_endTimes(i), ADI_DATE_FORMAT || ' ' || ADI_TIME_FORMAT);
     ELSE
       l_schedule_rec.end_date_time := NULL;
     END IF;
     IF(l_activityIds(i) IS NOT NULL AND l_activityTypes(i) IS NOT NULL) THEN
       l_schedule_rec.activity_id  := l_activityIds(i);
       l_schedule_rec.activity_type_code  := l_activityTypes(i);
     END IF;
     IF(l_mktMediumIds(i) IS NOT NULL AND l_activityIds(i) IS NOT NULL) THEN
       l_schedule_rec.marketing_medium_id  := l_mktMediumIds(i);
     END IF;
     IF(l_countryIds(i) IS NOT NULL) THEN
       l_schedule_rec.country_id    := l_countryIds(i);
     END IF;
     l_schedule_rec.owner_user_id      := l_ownerIds(i);
     IF(l_timezoneIds(i) IS NOT NULL) THEN
       l_schedule_rec.timezone_id       := l_timezoneIds(i);
     END IF;
     IF(l_objectives(i) IS NOT NULL) THEN
       l_schedule_rec.description     := l_objectives(i);
     END IF;
     IF(l_nextStatusIds(i) IS NOT NULL) THEN
       l_schedule_rec.user_status_id := l_nextStatusIds(i);
       l_schedule_rec.status_code := l_nextStatusCodes(i);
       IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('next status id : '||TO_CHAR(l_schedule_rec.user_status_id));
         AMS_UTILITY_PVT.debug_message('next status code : '||l_schedule_rec.status_code);
       END IF;
      END IF;

   l_schedule_rec.object_version_number := l_objVersionNos (i);

   IF(l_currencyCodes(i) IS NOT NULL) THEN
     l_schedule_rec.transaction_currency_code     := l_currencyCodes(i);
   END IF;

     l_schedule_rec.attribute1                      :=  l_attribute1s(i);
     l_schedule_rec.attribute2                      := l_attribute2s(i);
     l_schedule_rec.attribute3                       := l_attribute3s(i);
     l_schedule_rec.attribute4                       := l_attribute4s(i);
     l_schedule_rec.attribute5                      := l_attribute5s(i);
       l_schedule_rec.attribute6                      := l_attribute6s(i);
       l_schedule_rec.attribute7                       := l_attribute7s(i);
       l_schedule_rec.attribute8                       := l_attribute8s(i);
       l_schedule_rec.attribute9                       := l_attribute9s(i);
       l_schedule_rec.attribute10                      := l_attribute10s(i);
       l_schedule_rec.attribute11                      := l_attribute11s(i);
       l_schedule_rec.attribute12                      := l_attribute12s(i);
       l_schedule_rec.attribute13                     := l_attribute13s(i);
       l_schedule_rec.attribute14                      := l_attribute14s(i);
       l_schedule_rec.attribute15                      := l_attribute15s(i);

       l_schedule_rec.activity_attribute1              := l_actAttribute1s(i);
       l_schedule_rec.activity_attribute2              := l_actAttribute2s(i);
       l_schedule_rec.activity_attribute3              := l_actAttribute3s(i);
       l_schedule_rec.activity_attribute4              := l_actAttribute4s(i);
       l_schedule_rec.activity_attribute5              := l_actAttribute5s(i);
       l_schedule_rec.activity_attribute6              := l_actAttribute6s(i);
       l_schedule_rec.activity_attribute7              := l_actAttribute7s(i);
       l_schedule_rec.activity_attribute8              := l_actAttribute8s(i);
       l_schedule_rec.activity_attribute9              := l_actAttribute9s(i);
       l_schedule_rec.activity_attribute10             := l_actAttribute10s(i);
       l_schedule_rec.activity_attribute11             := l_actAttribute11s(i);
       l_schedule_rec.activity_attribute12             := l_actAttribute12s(i);
       l_schedule_rec.activity_attribute13             := l_actAttribute13s(i);
       l_schedule_rec.activity_attribute14             := l_actAttribute14s(i);
       l_schedule_rec.activity_attribute15            := l_actAttribute15s(i);

  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Calling AMS_Camp_Schedule_PUB.Update_Camp_Schedule');
 END IF;

    AMS_Camp_Schedule_PUB.Update_Camp_Schedule(
    1.0,
    FND_API.G_FALSE,
    FND_API.G_FALSE,
    FND_API.g_valid_level_full,
    l_return_status,
    l_msg_count,
    l_msg_data,
    l_schedule_rec,
    l_object_version_number
    );

  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Return Status from Update_Camp_Schedule '||l_return_status);
 END IF;

 -- Approvals Integration Starts here
IF(l_return_status =  FND_API.G_RET_STS_SUCCESS) THEN
  IF (l_apprActionCodes(i) = 'COMPLETE') THEN
      IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name || ' Schedule Update before Approval was  successful  '||TO_CHAR(l_objectIds(i)));
        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name || ' Now proceeding with Approval');
        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name || ' Now calling AMS_ScheduleRules_PVT.Update_Schedule_Status');
      END IF;

      BEGIN
        AMS_ScheduleRules_PVT.Update_Schedule_Status( p_schedule_id    => l_objectIds(i),
                                                      p_campaign_id    => l_parentIds(i),
                                                      p_user_status_id => AMS_UTILITY_PVT.get_default_user_status
                                                        (p_status_type => 'AMS_CAMPAIGN_SCHEDULE_STATUS',
                                                         p_status_code => 'AVAILABLE'),
                                                      p_budget_amount  => null
                                                      );
        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
       END;

    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Return Status from AMS_ScheduleRules_PVT.Update_Schedule_Status API  '||l_return_status);
    END IF;
  END IF;
END IF;
-- Approvals Integration Ends here

   IF(l_return_status =  FND_API.G_RET_STS_SUCCESS) THEN
     AMS_ADI_COMMON_PVT.handle_success_row(FND_API.G_FALSE); -- do not need commit for every row
   ELSE
     ROLLBACK TO EXPORT_SCHEDULE; --rollback to save_point if errors

     AMS_ADI_COMMON_PVT.handle_error_row(
       FND_API.G_TRUE,
       FND_API.G_FALSE, -- do not need a rollback from procedure
       NULL,
       NULL,
       l_objectIds(i),
       NULL,
       NULL,
       l_error_recs --the table containing error records
     );
    END IF;

  FND_MSG_PUB.initialize; --initializes message table for next loop

  END LOOP; --end inner loop for batch size

  FND_MSG_PUB.initialize; --initializes message table

  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Calling Complete batch');
 END IF;

  AMS_ADI_COMMON_PVT.complete_batch(
    'AMS_ADI_CAMPAIGNS_INTERFACE',
    p_upload_batch_id,
    FND_API.G_TRUE,
    FND_API.G_FALSE, -- do not need COMMIT for batches as well
    l_error_recs
  );

 exit when c%notfound;

end loop;

close c;

  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Calling Complete all');
 END IF;

AMS_ADI_COMMON_PVT.complete_all(FND_API.G_TRUE,FND_API.G_TRUE,p_upload_batch_id); --commit everything here only!

  -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Done with all');
 END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO EXPORT_SCHEDULE; --rollback to save_point if errors


        IF (c%ISOPEN)
        THEN
            CLOSE c;
        END IF;

        AMS_ADI_COMMON_PVT.handle_fatal_error();
        x_retcode := 2;
        x_errbuf := SQLERRM;

        RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO EXPORT_SCHEDULE; --rollback to save_point if errors

         IF (c%ISOPEN)
         THEN
            CLOSE c;
         END IF;

        AMS_ADI_COMMON_PVT.handle_fatal_error();
        RAISE;

   WHEN OTHERS THEN
         ROLLBACK TO EXPORT_SCHEDULE; --rollback to save_point if errors

         IF (c%ISOPEN)
         THEN
            CLOSE c;
         END IF;

     AMS_ADI_COMMON_PVT.handle_fatal_error();
     RAISE;
END update_campaign_schedules;

    --========================================================================
    -- PROCEDURE Handle_Ret_Status_For_Import
    --    handle Return Status for Import
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================

procedure Handle_Ret_Status_For_Import (
                    p_return_status IN VARCHAR2,
                    p_object_name IN VARCHAR2,
                    p_parent_object_id IN NUMBER,
                    p_error_records IN OUT NOCOPY AMS_ADI_COMMON_PVT.ams_adi_error_rec_t,
                    p_commit IN VARCHAR2 := FND_API.G_FALSE,
                    p_purge_metrics IN VARCHAR2 := FND_API.G_FALSE
    );

    --========================================================================
    -- PROCEDURE Associate_Product_Category
    --    Product/Category Association
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================

    procedure Associate_Product_Category(
                        p_product_id IN NUMBER,
                        p_category_id IN NUMBER,
                        p_schedule_id IN NUMBER,
                        p_primary_flag IN VARCHAR2,
                        x_act_product_id OUT NOCOPY NUMBER,
                        x_return_status       OUT NOCOPY    VARCHAR2,
                        x_msg_count           OUT NOCOPY    NUMBER,
                        x_msg_data            OUT NOCOPY    VARCHAR2
    );

    --========================================================================
    -- PROCEDURE Associate_Collaboration_Item
    --    Collaboration Association API CALL
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================
    procedure Associate_Collaboration_Item(
                    p_collab_type IN VARCHAR2,
                    p_collab_assoc_id IN NUMBER,
                    p_schedule_id IN NUMBER,
                    x_return_status       OUT NOCOPY    VARCHAR2,
                    x_msg_count           OUT NOCOPY    NUMBER,
                    x_msg_data            OUT NOCOPY    VARCHAR2
    );

        --========================================================================
    -- PROCEDURE Associate_Web_Planner
    --    Collaboration Association API CALL
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================
    PROCEDURE Associate_Web_Planner(
                    p_application_id IN NUMBER,
                    p_placement_id IN NUMBER,
                    p_content_item_id IN NUMBER,
                    p_placement_title IN VARCHAR2,
                    p_activity_id IN NUMBER,
                    p_schedule_id IN NUMBER,
                    x_placement_mp_id     OUT NOCOPY  NUMBER,
                    x_placement_citem_id_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
                    x_msg_count              OUT NOCOPY  NUMBER,
                    x_msg_data                OUT NOCOPY  VARCHAR2,
                    x_return_status           OUT NOCOPY VARCHAR2
    );

    --========================================================================
    -- PROCEDURE Get_Object_Source_Code
    --    Get the Source Code of an Object
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================
    FUNCTION Get_Object_Source_Code(
                    p_object_type IN VARCHAR2,
                    p_object_id IN NUMBER
    ) RETURN VARCHAR2;



    --========================================================================
    -- PROCEDURE
    --   Imports New Campaign Schedules from Web ADI
    -- Purpose
    --    Imports New Campaign Schedules based on Web ADI input in staging table AMS_ADI_CAMPAIGNS_INTERFACE
    --    The algorithm is as follows :
    --		1. call AMS_ADI_COMMON_PVT.init
    --          2. BULK COLLECT data from staging table in batches of AMS_ADI_COMMON_PVT.g_batch_size(set as 100). Then for
    --		   each batch do the following :
    --			2.1. call AMS_ADI_COMMON_PVT.init_for_batch
    --			2.2 repeat the following Steps for each Row
    --				2.2.1 call Schedule Create API for each ROW
    --				2.2.2 if successful, call AMS_ADI_COMMON_PVT.handleSuccesRow
    --			    		else call AMS_ADI_COMMON_PVT.handleErrorRow
    --			2.3 when done with batch, call AMS_ADI_COMMON_PVT.done_with_batch
    --		3. call AMS_ADI_COMMON_PVT.done_with_all_rows
    -- HISTORY
    --
    --========================================================================

    PROCEDURE Import_Campaign_Schedules(
        x_errbuf        OUT NOCOPY    VARCHAR2,
        x_retcode       OUT NOCOPY    VARCHAR2,
        p_upload_batch_id IN NUMBER,
        p_ui_instance_id IN NUMBER := 0
    )
    IS

        L_API_NAME                  CONSTANT VARCHAR2(30) := 'IMPORT_CAMPAIGN_SCHEDULES';
        L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
        l_schedule_rec AMS_Camp_Schedule_PUB.schedule_rec_type;
        l_error_recs AMS_ADI_COMMON_PVT.ams_adi_error_rec_t := AMS_ADI_COMMON_PVT.ams_adi_error_rec_t();
        l_batch_size PLS_INTEGER := AMS_ADI_COMMON_PVT.g_batch_size;
        l_return_status      VARCHAR2(1);
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(4000);
        l_start_date_time DATE;
        l_end_date_time DATE;
        l_object_version_number NUMBER;
        l_schedule_id NUMBER;
        l_temp_num NUMBER;
        l_note_id NUMBER;

        l_assoc_type_codes      JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
        l_assoc_objects1        JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300();

        l_placement_mp_id       NUMBER;
        l_placement_citem_id_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
        l_ctd_id_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
        l_tmp_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
        l_activity_type_code VARCHAR2(30);
        l_ctd_id  NUMBER;
        l_primary_flag VARCHAR2(1);
        l_ctd_act_product_id NUMBER;



        -- cursor C_IMPORT_BATCH
        cursor C_IMPORT_BATCH(l_upload_batch_id NUMBER) is
        SELECT
            object_name, source_code, parent_object_id, start_date, end_date,
            start_time, end_time, template_id, actual_activity_id, marketing_medium_id,
            purpose, country_id, owner_user_id, timezone_id, currency_code,
            objective, approval_action_code, rep_sched_freq_code, rep_sched_frequency, rep_sched_tg_exclude_flag,
            product_id1, product_id2, product_category_id1, product_category_id2, cover_letter_id,
            collab_citem_id1, collab_citem_id2, collab_citem_id3, collab_script_id,
            notes, pretty_url_website, additional_url_param,
            wp_application_id, wp_placement_id, wp_placement_title, wp_citem_id,
            ctd_action, ctd_param1, ctd_param2, ctd_param3, ctd_param4, ctd_url_text,
            ctd_adhoc_param1, ctd_adhoc_param_val1, ctd_adhoc_param2, ctd_adhoc_param_val2, ctd_adhoc_param3,
            ctd_adhoc_param_val3, ctd_adhoc_param4, ctd_adhoc_param_val4, ctd_adhoc_param5, ctd_adhoc_param_val5,
            attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, attribute7, attribute8,
            attribute9, attribute10, attribute11, attribute12, attribute13, attribute14, attribute15,
            activity_attribute1, activity_attribute2, activity_attribute3, activity_attribute4, activity_attribute5,
            activity_attribute6, activity_attribute7, activity_attribute8, activity_attribute9, activity_attribute10,
            activity_attribute11, activity_attribute12, activity_attribute13, activity_attribute14, activity_attribute15
            --last_update_date, last_updated_by, creation_date, created_by, last_update_login
        FROM
            AMS_ADI_CAMPAIGNS_INTERFACE
        where
            upload_batch_id = l_upload_batch_id and
            operation_status = 'NEW' and
            operation_type = 'IMPORT' and
            object_type = 'CSCH' and
            parent_object_type = 'CAMP';
        -- cursor C_IMPORT_BATCH
        /*
        -- cursor C_DOES_COVLETT_EXIST
        cursor C_DOES_COVLETT_EXIST(p_covlett_id NUMBER) is
        select
            1
        from
            IBC_CONTENT_ITEMS
        where
            content_item_id = p_covlett_id;
        -- cursor C_DOES_COVLETT_EXIST
        */

        -- array Declarations
        l_objectNames onameArray;
        l_srcCodes scodeArray;
        l_campIds oidArray;
        l_startDates dateArray;
        l_endDates dateArray;
        l_startTimes timeArray;
        l_endTimes timeArray;
        l_templateIds oidArray;
        l_ActivityIds oidArray;
        l_mktMediumIds oidArray;
        l_purposeCodes lookupCodeArray;
        l_countryIds oidArray;
        l_ownerIds oidArray;
        l_timezoneIds oidArray;
        l_currCodes lookupCodeArray;
        l_objectives objectiveArray;
        l_apprActionCodes lookupCodeArray;
        l_repschedFreqCodes lookupCodeArray;
        l_repschedFreqs oidArray;
        l_repschedTgFlags lookupCodeArray;
        l_prodIds1 oidArray;
        l_prodIds2 oidArray;
        l_catIds1 oidArray;
        l_catIds2 oidArray;
        l_covLettIds oidArray;
        l_collabCitemIds1 oidArray;
        l_collabCitemIds2 oidArray;
        l_collabCitemIds3 oidArray;
        l_collabScrIds oidArray;
        l_notes notesArray;
        l_puWebsites puwsArray;
        l_puAddlParam puwsArray;
        l_wpAppIds oidArray;
        l_wpPlceIds oidArray;
        l_wpTitles wptitleArray;
        l_wpCitemIds oidArray;
        l_ctdActions oidArray;
        l_ctdParams1 oidArray;
        l_ctdParams2 oidArray;
        l_ctdParams3 oidArray;
        l_ctdParams4 oidArray;
        l_ctdUrlText objectiveArray;
        l_ctdAhParams1 ctdAhParamArray;
        l_ctdAhParamVals1 ctdAhParamValArray;
        l_ctdAhParams2 ctdAhParamArray;
        l_ctdAhParamVals2 ctdAhParamValArray;
        l_ctdAhParams3 ctdAhParamArray;
        l_ctdAhParamVals3 ctdAhParamValArray;
        l_ctdAhParams4 ctdAhParamArray;
        l_ctdAhParamVals4 ctdAhParamValArray;
        l_ctdAhParams5 ctdAhParamArray;
        l_ctdAhParamVals5 ctdAhParamValArray;
        l_attrCategories flexContextArray;
        l_attribute1s flexAttrArray;
        l_attribute2s flexAttrArray;
        l_attribute3s flexAttrArray;
        l_attribute4s flexAttrArray;
        l_attribute5s flexAttrArray;
        l_attribute6s flexAttrArray;
        l_attribute7s flexAttrArray;
        l_attribute8s flexAttrArray;
        l_attribute9s flexAttrArray;
        l_attribute10s flexAttrArray;
        l_attribute11s flexAttrArray;
        l_attribute12s flexAttrArray;
        l_attribute13s flexAttrArray;
        l_attribute14s flexAttrArray;
        l_attribute15s flexAttrArray;
        l_actAttribute1s flexAttrArray;
        l_actAttribute2s flexAttrArray;
        l_actAttribute3s flexAttrArray;
        l_actAttribute4s flexAttrArray;
        l_actAttribute5s flexAttrArray;
        l_actAttribute6s flexAttrArray;
        l_actAttribute7s flexAttrArray;
        l_actAttribute8s flexAttrArray;
        l_actAttribute9s flexAttrArray;
        l_actAttribute10s flexAttrArray;
        l_actAttribute11s flexAttrArray;
        l_actAttribute12s flexAttrArray;
        l_actAttribute13s flexAttrArray;
        l_actAttribute14s flexAttrArray;
        l_actAttribute15s flexAttrArray;
        -- array Declarations

    BEGIN


        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Private API: '|| pkg_name || '.' || l_api_name || 'start with batch id : '||p_upload_batch_id||' ui instance id : '||p_ui_instance_id);
        END IF;


        -- Initialize API return status to SUCCESS
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        AMS_ADI_COMMON_PVT.init();

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'Start to read from ams_adi_campaigns_interface with limit '||AMS_ADI_COMMON_PVT.g_batch_size);
        END IF;

        OPEN C_IMPORT_BATCH(p_upload_batch_id);
        LOOP -- C_IMPORT_BATCH loop

            FETCH C_IMPORT_BATCH BULK COLLECT
            INTO
                 l_objectNames, l_srcCodes, l_campIds ,l_startDates ,l_endDates ,
                 l_startTimes,l_endTimes ,l_templateIds ,l_ActivityIds ,l_mktMediumIds,
                 l_purposeCodes ,l_countryIds ,l_ownerIds ,l_timezoneIds,l_currCodes ,
                 l_objectives , l_apprActionCodes , l_repschedFreqCodes , l_repschedFreqs , l_repschedTgFlags ,
                 l_prodIds1 , l_prodIds2 , l_catIds1 , l_catIds2 , l_covLettIds ,
                 l_collabCitemIds1 , l_collabCitemIds2 , l_collabCitemIds3 , l_collabScrIds ,
                 l_notes , l_puWebsites , l_puAddlParam,
                 l_wpAppIds , l_wpPlceIds , l_wpTitles , l_wpCitemIds ,
                 l_ctdActions , l_ctdParams1 , l_ctdParams2 , l_ctdParams3 , l_ctdParams4 , l_ctdUrlText,
                 l_ctdAhParams1 , l_ctdAhParamVals1 , l_ctdAhParams2 , l_ctdAhParamVals2 , l_ctdAhParams3 ,
                 l_ctdAhParamVals3 , l_ctdAhParams4 , l_ctdAhParamVals4 , l_ctdAhParams5 , l_ctdAhParamVals5 ,
                 l_attrCategories , l_attribute1s , l_attribute2s , l_attribute3s , l_attribute4s , l_attribute5s ,
                 l_attribute6s , l_attribute7s , l_attribute8s , l_attribute9s , l_attribute10s , l_attribute11s ,
                 l_attribute12s , l_attribute13s , l_attribute14s , l_attribute15s ,
                 l_actAttribute1s , l_actAttribute2s , l_actAttribute3s , l_actAttribute4s , l_actAttribute5s ,
                 l_actAttribute6s , l_actAttribute7s , l_actAttribute8s , l_actAttribute9s , l_actAttribute10s ,
                 l_actAttribute11s , l_actAttribute12s , l_actAttribute13s , l_actAttribute14s , l_actAttribute15s
            LIMIT AMS_ADI_COMMON_PVT.g_batch_size;

            -- Debug Message
            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_UTILITY_PVT.Write_Conc_Log('Private API: '|| pkg_name || '.' || l_api_name ||'done with fetch');
            END IF;

            -- Debug Message
            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'calling init_for_batch');
            END IF;

            --initialize batch operation
            AMS_ADI_COMMON_PVT.init_for_batch(l_error_recs);

            -- Debug Message
            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'Done init_for_batch with loopsize'||l_objectNames.COUNT);
            END IF;


            -- start looping the arrays to call the Schedule Public API
            FOR i in l_objectNames.FIRST .. l_objectNames.LAST
            LOOP -- l_objectNames LOOP
                BEGIN
		    -- SAVEPOINT for each row
                    SAVEPOINT Import_Schedule_PVT;
                    --init the schedule rec type with a gmiss record;
                    --l_schedule_rec := AMS_Camp_Schedule_PUB.g_miss_schedule_rec;

                    l_return_status := FND_API.G_RET_STS_SUCCESS;
                    --check for duplicate schedules in the interface table
                    BEGIN
                        SELECT
                            1 into l_temp_num
                        FROM
                            AMS_ADI_CAMPAIGNS_INTERFACE
                        WHERE
                            upload_batch_id = p_upload_batch_id and
                            operation_status = 'NEW' and
                            operation_type = 'IMPORT' and
                            object_type = 'CSCH' and
                            parent_object_type = 'CAMP' and
                            parent_object_id = l_campIds(i) and
                            object_name = l_objectNames(i);
                    EXCEPTION
                        WHEN TOO_MANY_ROWS THEN
                            AMS_Utility_PVT.Error_Message('AMS_CSCH_DUPLICATE_ID');
                            l_return_status := FND_API.G_RET_STS_ERROR;
                            Handle_Ret_Status_For_Import (
                                p_return_status => l_return_status,
                                p_object_name => l_objectNames(i),
                                p_parent_object_id => l_campIds(i),
                                p_error_records => l_error_recs
                            );
                    END;

                    IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
                    THEN
                        --populate the schedule record start
                        l_schedule_rec.last_update_date := sysdate;
                        l_schedule_rec.last_updated_by := FND_GLOBAL.USER_ID;
                        l_schedule_rec.creation_date := sysdate;
                        l_schedule_rec.created_by := FND_GLOBAL.USER_ID;
                        l_schedule_rec.last_update_login := FND_GLOBAL.USER_ID;
                        l_schedule_rec.object_version_number := 1;

                        l_schedule_rec.campaign_id := l_campIds(i);

                        -- get the defult user status from AMS_UTILITY_PVT
                        l_schedule_rec.user_status_id := AMS_UTILITY_PVT.get_default_user_status(p_status_type => 'AMS_CAMPAIGN_SCHEDULE_STATUS',
                                                                                                 p_status_code => 'NEW');

                        l_schedule_rec.status_code := 'NEW';
                        l_schedule_rec.status_date := sysdate;

                        l_schedule_rec.source_code := l_srcCodes(i);

                        l_schedule_rec.use_parent_code_flag := 'N';

                        -- start date and start time need to be appended
                        if (l_startTimes(i) is not NULL)
                        THEN
                            l_start_date_time := to_date (to_char(l_startDates(i), ADI_DATE_FORMAT) || ' ' ||l_startTimes(i), ADI_DATE_FORMAT || ' ' || ADI_TIME_FORMAT);
                        ELSE
                            l_start_date_time := trunc(l_startDates(i));
                        END IF;

                        l_schedule_rec.start_date_time := l_start_date_time;

                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'l_endDates '|| to_char(l_endDates(i), ADI_DATE_FORMAT || ' ' || ADI_TIME_FORMAT));
                        END IF;

                        IF (l_endDates(i) is not NULL)
                        THEN
                            IF (l_endTimes(i) is not NULL)
                            THEN
                                l_end_date_time := to_date (to_char(l_endDates(i), ADI_DATE_FORMAT) || ' ' ||l_endTimes(i), ADI_DATE_FORMAT || ' ' || ADI_TIME_FORMAT);
                            ELSE
                                l_end_date_time := trunc(l_endDates(i));
                            END IF;

                            l_schedule_rec.end_date_time := l_end_date_time;
                        ELSE
                            l_schedule_rec.end_date_time := null;
                        END IF;

                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'Start Date Time'|| to_char(l_schedule_rec.start_date_time, ADI_DATE_FORMAT || ' ' || ADI_TIME_FORMAT));
                        END IF;

                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'End Date Time'|| to_char(l_schedule_rec.end_date_time, ADI_DATE_FORMAT || ' ' || ADI_TIME_FORMAT));
                        END IF;

                        l_schedule_rec.timezone_id := l_timezoneIds(i);

                        l_schedule_rec.activity_type_code := Get_Activity_Type_Code(l_ActivityIds(i));
                        l_schedule_rec.activity_id := l_ActivityIds(i);

                        --l_schedule_rec.arc_marketing_medium_from

                        l_schedule_rec.marketing_medium_id := l_mktMediumIds(i);

                        l_schedule_rec.custom_setup_id := l_templateIds(i);

                        --l_schedule_rec.trigger_id
                        --l_schedule_rec.notify_user_id
                        --l_schedule_rec.l_schedule_rec.approver_user_id

                        l_schedule_rec.owner_user_id := l_ownerIds(i);
                        --l_schedule_rec.active_flag

                        l_schedule_rec.cover_letter_id := l_covLettIds(i);

                        --l_schedule_rec.reply_to_mail
                        --l_schedule_rec.mail_sender_name
                        --l_schedule_rec.mail_subject
                        --l_schedule_rec.from_fax_no
                        l_schedule_rec.accounts_closed_flag := 'N';

                        l_schedule_rec.org_id := FND_PROFILE.value('ORG_ID'); -- need to chek this.
                        --l_schedule_rec.objective_code
                        IF (l_countryIds(i) is not null)
                        THEN
                            l_schedule_rec.country_id := l_countryIds(i);
                        ELSE
                            l_schedule_rec.country_id := FND_PROFILE.value('AMS_SRCGEN_USER_CITY');
                        END IF;


                        --l_schedule_rec.campaign_calendar
                        --l_schedule_rec.start_period_name
                        --l_schedule_rec.end_period_name
                        --l_schedule_rec.priority
                        --l_schedule_rec.l_schedule_rec.workflow_item_key
                        l_schedule_rec.transaction_currency_code := l_currCodes(i);

                        --l_schedule_rec.functional_currency_code
                        --l_schedule_rec.budget_amount_tc
                        --l_schedule_rec.budget_amount_fc
                        l_schedule_rec.language_code := 'US'; --there is an issue related to this. we need to change this when the language issue is fixed.
                        --l_schedule_rec.task_id
                        --l_schedule_rec.related_event_from
                        --l_schedule_rec.related_event_id

                        l_schedule_rec.attribute_category := l_attrCategories(i);
                        l_schedule_rec.attribute1 :=  l_attribute1s(i);
                        l_schedule_rec.attribute2 := l_attribute2s(i);
                        l_schedule_rec.attribute3  := l_attribute3s(i);
                        l_schedule_rec.attribute4  := l_attribute4s(i);
                        l_schedule_rec.attribute5 := l_attribute5s(i);
                        l_schedule_rec.attribute6 := l_attribute6s(i);
                        l_schedule_rec.attribute7  := l_attribute7s(i);
                        l_schedule_rec.attribute8  := l_attribute8s(i);
                        l_schedule_rec.attribute9  := l_attribute9s(i);
                        l_schedule_rec.attribute10 := l_attribute10s(i);
                        l_schedule_rec.attribute11 := l_attribute11s(i);
                        l_schedule_rec.attribute12 := l_attribute12s(i);
                        l_schedule_rec.attribute13 := l_attribute13s(i);
                        l_schedule_rec.attribute14 := l_attribute14s(i);
                        l_schedule_rec.attribute15 := l_attribute15s(i);

                        l_schedule_rec.activity_attribute1 := l_actAttribute1s(i);
                        l_schedule_rec.activity_attribute2 := l_actAttribute2s(i);
                        l_schedule_rec.activity_attribute3 := l_actAttribute3s(i);
                        l_schedule_rec.activity_attribute4 := l_actAttribute4s(i);
                        l_schedule_rec.activity_attribute5 := l_actAttribute5s(i);
                        l_schedule_rec.activity_attribute6 := l_actAttribute6s(i);
                        l_schedule_rec.activity_attribute7 := l_actAttribute7s(i);
                        l_schedule_rec.activity_attribute8 := l_actAttribute8s(i);
                        l_schedule_rec.activity_attribute9 := l_actAttribute9s(i);
                        l_schedule_rec.activity_attribute10 := l_actAttribute10s(i);
                        l_schedule_rec.activity_attribute11 := l_actAttribute11s(i);
                        l_schedule_rec.activity_attribute12 := l_actAttribute12s(i);
                        l_schedule_rec.activity_attribute13 := l_actAttribute13s(i);
                        l_schedule_rec.activity_attribute14 := l_actAttribute14s(i);
                        l_schedule_rec.activity_attribute15 := l_actAttribute15s(i);

                        l_schedule_rec.schedule_name := l_objectNames(i);

                        l_schedule_rec.description     := l_objectives(i);

                        -- bug 5094316
                        IF (l_schedule_rec.activity_type_code = 'EVENTS')
                        THEN
                            l_schedule_rec.related_source_code  := null;
                            l_schedule_rec.related_source_object  := null;
                            l_schedule_rec.related_source_id  := null;
                         END IF;
                         -- bug 5094316

                        --l_schedule_rec.query_id
                        --l_schedule_rec.include_content_flag
                        --l_schedule_rec.content_type
                        --l_schedule_rec.test_email_address
                        --l_schedule_rec.greeting_text
                        --l_schedule_rec.footer_text

                        -- For Repeating Schedule
                        IF ( (l_repschedFreqCodes(i) is not null) AND (l_repschedFreqCodes(i) <> 'NONE') AND
                             (l_repschedFreqs(i) is not null) AND (l_repschedFreqs(i) > 0) AND
                             (l_repschedTgFlags(i) is not null) AND
                             (l_schedule_rec.activity_type_code <> 'INTERNET')
                        )
                        THEN
                            l_schedule_rec.trig_repeat_flag := 'Y';
                            l_schedule_rec.triggerable_flag := 'N';
                            l_schedule_rec.tgrp_exclude_prev_flag := l_repschedTgFlags(i);
                        ELSE
                            l_schedule_rec.trig_repeat_flag := 'N';
                        END IF;

                        --l_schedule_rec.tgrp_exclude_prev_flag
                        --l_schedule_rec.orig_csch_id
                        --l_schedule_rec.cover_letter_version
                        l_schedule_rec.usage := 'LITE';

                        l_schedule_rec.purpose := l_purposeCodes(i);
                        --populate the schedule record end

                        -- Debug Message
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'Calling Campaign Schedule Public API');
                        END IF;

                        AMS_Camp_Schedule_PUB.Create_Camp_Schedule(
                                                                    1.0,
                                                                    FND_API.G_FALSE,
                                                                    FND_API.G_FALSE,
                                                                    FND_API.g_valid_level_full,
                                                                    l_return_status,
                                                                    l_msg_count,
                                                                    l_msg_data,
                                                                    l_schedule_rec,
                                                                    l_schedule_id
                                                                    );
                        -- Debug Message
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'Return Status from Schedule API'||l_return_status);
                        END IF;

                        Handle_Ret_Status_For_Import (
                            p_return_status => l_return_status,
                            p_object_name => l_objectNames(i),
                            p_parent_object_id => l_campIds(i),
                            p_error_records => l_error_recs
                        );
                    END IF;

                    -- Metrics Integration starts here
                    IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                            ' Association before Metrics association was  successful  '||TO_CHAR(l_schedule_id));
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                            ' Now proceeding with Metrics association');
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                            ' Now calling AMS_ADI_MEDIA_PLANNER_PVT.LOAD_METRICS API');
                        END IF;

                        AMS_ADI_MEDIA_PLANNER_PVT.LOAD_METRICS(
                                            p_api_version   => 1.0,
                                            p_init_msg_list => FND_API.G_FALSE,
                                            p_commit        => FND_API.G_FALSE,
                                            x_return_status => l_return_status,
                                            x_msg_count     => l_msg_count,
                                            x_msg_data      => l_msg_data,
                                            p_upload_batch_id => 1, -- workaround
                                            p_object_type   => 'CSCH',
                                            p_object_name   => l_objectNames(i),
                                            p_parent_type   => 'CAMP',
                                            p_parent_id     => l_campIds(i),
                                            p_object_id     => l_schedule_id
                            );

                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                            ' Return Status from AMS_ADI_MEDIA_PLANNER_PVT.LOAD_METRICS API  '||l_return_status);
                        END IF;

                        Handle_Ret_Status_For_Import (
                                    p_return_status => l_return_status,
                                    p_object_name => l_objectNames(i),
                                    p_parent_object_id => l_campIds(i),
                                    p_error_records => l_error_recs,
                                    p_purge_metrics => FND_API.G_TRUE
                            );

                    END IF;
                    -- Metrics Integration end here

                    -- Repeat Schedule Integration Start
                    IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF ( (l_repschedFreqCodes(i) is not null) AND (l_repschedFreqCodes(i) <> 'NONE') AND
                            (l_repschedFreqs(i) is not null) AND (l_repschedFreqs(i) > 0) AND
                            (l_repschedTgFlags(i) is not null) AND
                            (l_schedule_rec.activity_type_code <> 'INTERNET')
                            )
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Schedule Creation successful  '||TO_CHAR(l_schedule_id));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Now proceeding with repeating schedule association ');
                            END IF;

                            AMS_SCHEDULER_PVT.Create_Scheduler(
                                                        p_obj_type => 'CSCH',
                                                        p_obj_id => l_schedule_id,
                                                        p_freq => l_repschedFreqs(i),
                                                        p_freq_type => l_repschedFreqCodes(i),
                                                        x_msg_count => l_msg_count,
                                                        x_msg_data => l_msg_data,
                                                        x_return_status => l_return_status,
                                                        x_scheduler_id => l_temp_num
                                                        );

                             IF (AMS_DEBUG_HIGH_ON) THEN
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'Return Status from AMS_SCHEDULER_PVT.Create_Scheduler API '||l_return_status || ' ' || to_char(l_temp_num));
                                END IF;

                                Handle_Ret_Status_For_Import (
                                    p_return_status => l_return_status,
                                    p_object_name => l_objectNames(i),
                                    p_parent_object_id => l_campIds(i),
                                    p_error_records => l_error_recs
                                );
                        END IF;
                    END IF;

                    -- Repeat Schedule Integration End

                    -- Cover Letter Integration start
                    IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Schedule Creation successful  '||TO_CHAR(l_schedule_id));
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Now proceeding with cover letter association for cover letter  '||TO_CHAR(l_covLettIds (i)));
                        END IF;

                        IF (l_covLettIds (i) is not null)
                        THEN
                            l_assoc_type_codes := JTF_VARCHAR2_TABLE_100();
                            l_assoc_objects1 := JTF_VARCHAR2_TABLE_300();
                            l_assoc_type_codes.extend();
                            l_assoc_objects1.extend();
                            l_assoc_type_codes(1) := 'AMS_CSCH';
                            l_assoc_objects1(1) := to_char(l_schedule_id); --where 123456 is the schedule id

                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Now calling IBC_CITEM_ADMIN_GRP.insert_associations API');
                            END IF;
                            IBC_CITEM_ADMIN_GRP.insert_associations(
                                                                    p_content_item_id         =>  l_covLettIds(i)
                                                                    ,p_assoc_type_codes     => l_assoc_type_codes
                                                                    ,p_assoc_objects1          => l_assoc_objects1
                                                                    ,p_commit                     => FND_API.g_false
                                                                    ,x_return_status            => l_return_status
                                                                    ,x_msg_count               => l_msg_count
                                                                    ,x_msg_data                 => l_msg_data
                            );

                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'Return Status from IBC Association API for Cover Letter '||l_return_status);
                            END IF;

                            Handle_Ret_Status_For_Import (
                                p_return_status => l_return_status,
                                p_object_name => l_objectNames(i),
                                p_parent_object_id => l_campIds(i),
                                p_error_records => l_error_recs
                            );
                        END IF;
                    END IF;
                    -- Cover Letter Integration end

                    l_ctd_act_product_id := null;
                    -- Product Integration starts here
                    IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Schedule Creation/Cover letter associaiton successful  '||TO_CHAR(l_schedule_id));
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Now proceeding with product/category association ');
                        END IF;


                        IF ((l_prodIds1(i) is not null) OR (l_catIds1(i) is not null) )
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' At least one product/category is present to be associated'||TO_CHAR(l_schedule_id));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_prodIds1(i) '||TO_CHAR(l_prodIds1(i)));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_catIds1(i) '||TO_CHAR(l_catIds1(i)));
                            END IF;

                            Associate_Product_Category(
                                            p_product_id => l_prodIds1(i),
                                            p_category_id => l_catIds1(i),
                                            p_schedule_id => l_schedule_id,
                                            p_primary_flag => 'Y', -- 31-Aug-2005 mayjain Support for Primary Flag
                                            x_act_product_id => l_ctd_act_product_id,
                                            x_return_status  => l_return_status,
                                            x_msg_count  => l_msg_count,
                                            x_msg_data  => l_msg_data
                            );

                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_ctd_act_product_id '||TO_CHAR(l_ctd_act_product_id));
                            END IF;

                            Handle_Ret_Status_For_Import (
                                    p_return_status => l_return_status,
                                    p_object_name => l_objectNames(i),
                                    p_parent_object_id => l_campIds(i),
                                    p_error_records => l_error_recs
                            );

                        END IF;

                    END IF;

                    IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Schedule Creation/Product 1 association successful  '||TO_CHAR(l_schedule_id));
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Now proceeding with product/category association ');
                        END IF;

                        IF ((l_prodIds2(i) is not null) OR (l_catIds2(i) is not null) )
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' At least one product/category is present to be associated'||TO_CHAR(l_schedule_id));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_prodIds2(i) '||TO_CHAR(l_prodIds2(i)));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_catIds2(i) '||TO_CHAR(l_catIds2(i)));
                            END IF;

                            -- 31-Aug-2005 mayjain Support for Primary Flag
                            l_primary_flag := 'N';

                            -- 31-Aug-2005 mayjain Support for Primary Flag
                            IF ((l_prodIds1(i) is null) AND (l_catIds1(i) is null) )
                            THEN
                                l_primary_flag := 'Y';
                            END IF;

                            Associate_Product_Category(
                                            p_product_id => l_prodIds2(i),
                                            p_category_id => l_catIds2(i),
                                            p_schedule_id => l_schedule_id,
                                            p_primary_flag => l_primary_flag, -- 31-Aug-2005 mayjain Support for Primary Flag
                                            x_act_product_id => l_temp_num,
                                            x_return_status  => l_return_status,
                                            x_msg_count  => l_msg_count,
                                            x_msg_data  => l_msg_data
                            );

                            IF ((l_prodIds1(i) is null) AND (l_catIds1(i) is null) )
                            THEN
                                l_ctd_act_product_id := l_temp_num;
                                IF (AMS_DEBUG_HIGH_ON) THEN
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_ctd_act_product_id '||TO_CHAR(l_ctd_act_product_id));
                                END IF;
                            END IF;

                            Handle_Ret_Status_For_Import (
                                    p_return_status => l_return_status,
                                    p_object_name => l_objectNames(i),
                                    p_parent_object_id => l_campIds(i),
                                    p_error_records => l_error_recs
                            );

                        END IF;

                    END IF;
                    -- Product Integration ends here

                    -- Collaboration Integration Starts here
                    IF (l_schedule_rec.activity_type_code <> 'INTERNET')
                    THEN
                        -- Content Item 1
                        IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Schedule Creation/Product 1 association successful  '||TO_CHAR(l_schedule_id));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Now proceeding with Collaboration CItem 1 association ');
                            END IF;

                            IF (l_collabCitemIds1(i) is not null)
                            THEN
                                IF (AMS_DEBUG_HIGH_ON) THEN
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Collaboration CItem 1 is present to be associated to '||TO_CHAR(l_schedule_id));
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_collabCitemIds1(i) '||TO_CHAR(l_collabCitemIds1(i)));
                                END IF;

                                Associate_Collaboration_Item(
                                                p_collab_type => 'AMS_CONTENT',
                                                p_collab_assoc_id => l_collabCitemIds1(i),
                                                p_schedule_id => l_schedule_id,
                                                x_return_status  => l_return_status,
                                                x_msg_count  => l_msg_count,
                                                x_msg_data  => l_msg_data
                                );

                                Handle_Ret_Status_For_Import (
                                        p_return_status => l_return_status,
                                        p_object_name => l_objectNames(i),
                                        p_parent_object_id => l_campIds(i),
                                        p_error_records => l_error_recs
                                );

                            END IF;

                        END IF;
                        -- Content Item 1

                        -- Content Item 2
                        IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Schedule Creation/Product 2 association successful  '||TO_CHAR(l_schedule_id));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Now proceeding with Collaboration CItem 2 association ');
                            END IF;

                            IF (l_collabCitemIds2(i) is not null)
                            THEN
                                IF (AMS_DEBUG_HIGH_ON) THEN
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Collaboration CItem 2 is present to be associated to '||TO_CHAR(l_schedule_id));
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_collabCitemIds2(i) '||TO_CHAR(l_collabCitemIds2(i)));
                                END IF;

                                Associate_Collaboration_Item(
                                                p_collab_type => 'AMS_CONTENT',
                                                p_collab_assoc_id => l_collabCitemIds2(i),
                                                p_schedule_id => l_schedule_id,
                                                x_return_status  => l_return_status,
                                                x_msg_count  => l_msg_count,
                                                x_msg_data  => l_msg_data
                                );

                                Handle_Ret_Status_For_Import (
                                        p_return_status => l_return_status,
                                        p_object_name => l_objectNames(i),
                                        p_parent_object_id => l_campIds(i),
                                        p_error_records => l_error_recs
                                );

                            END IF;

                        END IF;
                        -- Content Item 2

                        -- Content Item 3
                        IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Schedule Creation/Product 3 association successful  '||TO_CHAR(l_schedule_id));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Now proceeding with Collaboration CItem 3 association ');
                            END IF;

                            IF (l_collabCitemIds3(i) is not null)
                            THEN
                                IF (AMS_DEBUG_HIGH_ON) THEN
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Collaboration CItem 3 is present to be associated to '||TO_CHAR(l_schedule_id));
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_collabCitemIds3(i) '||TO_CHAR(l_collabCitemIds3(i)));
                                END IF;

                                Associate_Collaboration_Item(
                                                p_collab_type => 'AMS_CONTENT',
                                                p_collab_assoc_id => l_collabCitemIds3(i),
                                                p_schedule_id => l_schedule_id,
                                                x_return_status  => l_return_status,
                                                x_msg_count  => l_msg_count,
                                                x_msg_data  => l_msg_data
                                );

                                Handle_Ret_Status_For_Import (
                                        p_return_status => l_return_status,
                                        p_object_name => l_objectNames(i),
                                        p_parent_object_id => l_campIds(i),
                                        p_error_records => l_error_recs
                                );

                            END IF;

                        END IF;
                        -- Content Item 3

                        -- Script
                        IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Schedule Creation/Content Item 3 association successful  '||TO_CHAR(l_schedule_id));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Now proceeding with Collaboration CItem 3 association ');
                            END IF;

                            IF (l_collabScrIds(i) is not null)
                            THEN
                                IF (AMS_DEBUG_HIGH_ON) THEN
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' Collaboration CItem 3 is present to be associated to '||TO_CHAR(l_schedule_id));
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||' l_collabScrIds(i) '||TO_CHAR(l_collabScrIds(i)));
                                END IF;

                                Associate_Collaboration_Item(
                                                p_collab_type => 'INBOUND_SCRIPT',
                                                p_collab_assoc_id => l_collabScrIds(i),
                                                p_schedule_id => l_schedule_id,
                                                x_return_status  => l_return_status,
                                                x_msg_count  => l_msg_count,
                                                x_msg_data  => l_msg_data
                                );

                                Handle_Ret_Status_For_Import (
                                        p_return_status => l_return_status,
                                        p_object_name => l_objectNames(i),
                                        p_parent_object_id => l_campIds(i),
                                        p_error_records => l_error_recs
                                );

                            END IF;

                        END IF;
                        -- Script
                    END IF; -- l_schedule_rec.activity_type_code <> 'INTERNET'
                    -- Collaboration Integration Ends here


                    -- Web Planner Integration Starts here
                    IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                            ' Association before Web Planner association was successful  '||TO_CHAR(l_schedule_id));
                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                            ' Now proceeding with Web Planner association');
                        END IF;

                        IF ( l_schedule_rec.activity_type_code = 'INTERNET')
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' It is a Web Schedule. No checking if WP Details are present');
                            END IF;

                            IF ((l_wpAppIds(i) is not null) AND
                                (l_wpPlceIds(i) is not null) AND
                                (l_wpCitemIds(i) is not null))
                            THEN
                                IF (AMS_DEBUG_HIGH_ON) THEN
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                    ' Now calling Associate_Web_Planner API');
                                END IF;

                                l_placement_citem_id_tbl := JTF_NUMBER_TABLE();

                                Associate_Web_Planner(
                                                p_application_id        => l_wpAppIds(i),
                                                p_placement_id          => l_wpPlceIds(i),
                                                p_content_item_id       => l_wpCitemIds(i),
                                                p_placement_title       => l_wpTitles(i),
                                                p_activity_id           => l_schedule_rec.activity_id,
                                                p_schedule_id           => l_schedule_id,
                                                x_placement_mp_id       => l_placement_mp_id,
                                                x_placement_citem_id_tbl  => l_placement_citem_id_tbl,
                                                x_msg_count             => l_msg_count,
                                                x_msg_data              => l_msg_data,
                                                x_return_status         => l_return_status
                                );

                                IF (AMS_DEBUG_HIGH_ON) THEN
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                    ' Return Status from Associate_Web_Planner API  '||l_return_status);
                                    AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                            ' Placement Citem ID Table count  '||TO_CHAR(l_placement_citem_id_tbl.count));
                                END IF;

                                Handle_Ret_Status_For_Import (
                                    p_return_status => l_return_status,
                                    p_object_name => l_objectNames(i),
                                    p_parent_object_id => l_campIds(i),
                                    p_error_records => l_error_recs
                                );



                                -- CTD Integration for Web Starts here
                                IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                                THEN
                                    IF (l_ctdActions(i) is not null)
                                    THEN
                                        IF (AMS_DEBUG_HIGH_ON) THEN
                                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                            ' Association before CTD association was  successful  '||TO_CHAR(l_schedule_id));
                                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                            ' Now proceeding with CTD association');
                                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                            ' Now calling AMS_ADI_CTD_PVT.CREATE_CTDS API');
                                        END IF;

                                        AMS_ADI_CTD_PVT.CREATE_CTDS(
                                                        p_action_id           => l_ctdActions(i),
                                                        p_parameter_id1       => l_ctdParams1(i),
                                                        p_parameter_id2       => l_ctdParams2(i),
                                                        p_parameter_id3       => l_ctdParams3(i),
                                                        p_url_text            => l_ctdUrlText(i),
                                                        p_adhoc_param_name1   => l_ctdAhParams1(i),
                                                        p_adhoc_param_name2   => l_ctdAhParams2(i),
                                                        p_adhoc_param_name3   => l_ctdAhParams3(i),
                                                        p_adhoc_param_name4   => l_ctdAhParams4(i),
                                                        p_adhoc_param_name5   => l_ctdAhParams5(i),
                                                        p_adhoc_param_val1    => l_ctdAhParamVals1(i),
                                                        p_adhoc_param_val2    => l_ctdAhParamVals2(i),
                                                        p_adhoc_param_val3    => l_ctdAhParamVals3(i),
                                                        p_adhoc_param_val4    => l_ctdAhParamVals4(i),
                                                        p_adhoc_param_val5    => l_ctdAhParamVals5(i),
                                                        p_used_by_id_list     => l_placement_citem_id_tbl,
                                                        p_schedule_id         => l_schedule_id,
                                                        p_activity_id         => l_schedule_rec.activity_id,
                                                        p_schedule_src_code   => Get_Object_Source_Code('CSCH', l_schedule_id),
                                                        x_ctd_id_list         => l_ctd_id_tbl,
                                                        x_msg_count           => l_msg_count,
                                                        x_msg_data            => l_msg_data,
                                                        x_return_status       => l_return_status,
                                                        p_activity_product_id => l_ctd_act_product_id
                                                        );

                                        IF (AMS_DEBUG_HIGH_ON) THEN
                                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                            ' Return Status from AMS_ADI_CTD_PVT.CREATE_CTDS API  '||l_return_status);
                                            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                            ' CTD ID Table count  '||TO_CHAR(l_ctd_id_tbl.count));
                                        END IF;

                                        Handle_Ret_Status_For_Import (
                                                        p_return_status => l_return_status,
                                                        p_object_name => l_objectNames(i),
                                                        p_parent_object_id => l_campIds(i),
                                                        p_error_records => l_error_recs
                                        );

                                    END IF;
                                END IF;
                                -- CTD Integration for Web Ends here

                            END IF;
                        END IF;
                    END IF;
                    -- Web Planner Integration Ends here

                    -- Pretty URL Association Starts here
                    IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (l_puWebsites(i) is not null)
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Pretty URL detail is present. Now checking for Activity Type ' || l_schedule_rec.activity_type_code);
                            END IF;

                            IF ((l_schedule_rec.activity_type_code = 'BROADCAST') OR
                                (l_schedule_rec.activity_type_code = 'PUBLIC_RELATIONS' ) OR
                                (l_schedule_rec.activity_type_code = 'IN_STORE') OR
                                ((l_schedule_rec.activity_type_code = 'DIRECT_MARKETING') AND
                                 (l_schedule_rec.activity_id <> 20) AND -- Exclude Email
                                 (l_schedule_rec.activity_id <> 460))) -- Exclude Telemarketing
                            THEN
                                l_ctd_id := null;

                                IF (l_ctdActions(i) is not null)
                                THEN
                                    IF (AMS_DEBUG_HIGH_ON) THEN
                                        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                        ' Association before Pretty URL CTD association was  successful  '||TO_CHAR(l_schedule_id));
                                        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                        ' Now proceeding with  Pretty URL CTD association');
                                        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                        ' Now calling AMS_ADI_CTD_PVT.CREATE_CTDS API');
                                    END IF;

                                    l_tmp_tbl := JTF_NUMBER_TABLE();
                                    l_tmp_tbl.extend;
                                    l_tmp_tbl(1) := -1;

                                    AMS_ADI_CTD_PVT.CREATE_CTDS(
                                                    p_action_id           => l_ctdActions(i),
                                                    p_parameter_id1       => l_ctdParams1(i),
                                                    p_parameter_id2       => l_ctdParams2(i),
                                                    p_parameter_id3       => l_ctdParams3(i),
                                                    p_url_text            => l_ctdUrlText(i),
                                                    p_adhoc_param_name1   => l_ctdAhParams1(i),
                                                    p_adhoc_param_name2   => l_ctdAhParams2(i),
                                                    p_adhoc_param_name3   => l_ctdAhParams3(i),
                                                    p_adhoc_param_name4   => l_ctdAhParams4(i),
                                                    p_adhoc_param_name5   => l_ctdAhParams5(i),
                                                    p_adhoc_param_val1    => l_ctdAhParamVals1(i),
                                                    p_adhoc_param_val2    => l_ctdAhParamVals2(i),
                                                    p_adhoc_param_val3    => l_ctdAhParamVals3(i),
                                                    p_adhoc_param_val4    => l_ctdAhParamVals4(i),
                                                    p_adhoc_param_val5    => l_ctdAhParamVals5(i),
                                                    p_used_by_id_list     => l_tmp_tbl,
                                                    p_schedule_id         => l_schedule_id,
                                                    p_activity_id         => l_schedule_rec.activity_id,
                                                    p_schedule_src_code   => Get_Object_Source_Code('CSCH', l_schedule_id),
                                                    x_ctd_id_list         => l_ctd_id_tbl,
                                                    x_msg_count           => l_msg_count,
                                                    x_msg_data            => l_msg_data,
                                                    x_return_status       => l_return_status,
                                                    p_activity_product_id => l_ctd_act_product_id
                                                    );

                                    IF (AMS_DEBUG_HIGH_ON) THEN
                                        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                        ' Return Status from AMS_ADI_CTD_PVT.CREATE_CTDS API  '||l_return_status);
                                        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                        ' CTD ID Table count  '||TO_CHAR(l_ctd_id_tbl.count));
                                    END IF;

                                    Handle_Ret_Status_For_Import (
                                                    p_return_status => l_return_status,
                                                    p_object_name => l_objectNames(i),
                                                    p_parent_object_id => l_campIds(i),
                                                    p_error_records => l_error_recs
                                    );

                                    l_ctd_id := l_ctd_id_tbl(1);

                                END IF; -- (l_ctdActions(i) is not null)

                                -- Now call Pretty URL API
                                IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                                THEN
                                    IF (AMS_DEBUG_HIGH_ON) THEN
                                        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                        ' Pretty URL CTD association was  successful  '||TO_CHAR(l_schedule_id));
                                        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                        ' Now proceeding with  Pretty URL association');
                                        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                        ' Now calling AMS_ADI_PRETTY_URL_PVT.CREATE_PRETTY_URL API');
                                    END IF;

                                    AMS_ADI_PRETTY_URL_PVT.CREATE_PRETTY_URL(
                                                      p_pretty_url      => l_puWebsites(i),
                                                      p_add_url_param   => l_puAddlParam(i),
                                                      p_ctd_id          => l_ctd_id,
                                                      p_schedule_id     => l_schedule_id,
                                                      p_activity_id     => l_schedule_rec.activity_id,
                                                      p_schedule_src_code => Get_Object_Source_Code('CSCH', l_schedule_id),
                                                      x_msg_count       => l_msg_count,
                                                      x_msg_data        => l_msg_data,
                                                      x_return_status   => l_return_status
                                                    ) ;

                                    IF (AMS_DEBUG_HIGH_ON) THEN
                                        AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                        ' Return Status from AMS_ADI_PRETTY_URL_PVT.CREATE_PRETTY_URL API  '||l_return_status);
                                    END IF;

                                    Handle_Ret_Status_For_Import (
                                                    p_return_status => l_return_status,
                                                    p_object_name => l_objectNames(i),
                                                    p_parent_object_id => l_campIds(i),
                                                    p_error_records => l_error_recs
                                    );

                                END IF;
                            END IF; -- Activity Type Check
                        END IF; --l_puWebsites(i) is not null
                    END IF;
                    -- Pretty URL Association Ends here


                    -- Notes Integration starts here
                    IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (l_notes(i) is not null)
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Association before Notes association was  successful  '||TO_CHAR(l_schedule_id));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Now proceeding with Notes association');
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Now calling Jtf_Notes_Pub.Create_note API');
                            END IF;

                            Jtf_Notes_Pub.Create_note(
                                            p_api_version      =>  1.0 ,
                                            x_return_status      =>  l_return_status,
                                            x_msg_count          =>  l_msg_count,
                                            x_msg_data           =>  l_msg_data,
                                            p_source_object_id   =>  l_schedule_id,-- schedule_id
                                            p_source_object_code =>  'AMS_CSCH',
                                            p_notes              =>  l_notes(i), -- varchar2(4000)
                                            p_notes_detail       =>   NULL, -- for upto 32K Note
                                            p_note_status        =>  'I' , -- fnd_lookup JTF_NOTE_STATUS (E,I,P)
                                            p_entered_by         =>   FND_GLOBAL.USER_ID,
                                            p_entered_date       =>  sysdate,
                                            p_last_updated_by    =>   FND_GLOBAL.USER_ID,
                                            x_jtf_note_id        =>  l_note_id ,
                                            p_note_type          =>  '',  -- fnd_lookup JTF_NOTE_TYPE
                                            p_last_update_date   =>  sysdate  ,
                                            p_creation_date      =>  sysdate  ) ;

                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Return Status from Jtf_Notes_Pub.Create_note API  '||l_return_status);
                            END IF;

                            Handle_Ret_Status_For_Import (
                                        p_return_status => l_return_status,
                                        p_object_name => l_objectNames(i),
                                        p_parent_object_id => l_campIds(i),
                                        p_error_records => l_error_recs
                                );
                        END IF;
                    END IF;

                    -- Notes Integration ends here

                    -- Approvals Integration Starts here
                    IF(l_return_status =  FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (l_apprActionCodes(i) = 'COMPLETE')
                        THEN
                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Association before Approval was  successful  '||TO_CHAR(l_schedule_id));
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Now proceeding with Approval');
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Now calling AMS_ScheduleRules_PVT.Update_Schedule_Status');
                            END IF;

                            BEGIN

                                AMS_ScheduleRules_PVT.Update_Schedule_Status(
                                                               p_schedule_id    => l_schedule_id,
                                                               p_campaign_id    => l_campIds(i),
                                                               p_user_status_id => AMS_UTILITY_PVT.get_default_user_status
                                                                                                (p_status_type => 'AMS_CAMPAIGN_SCHEDULE_STATUS',
                                                                                                 p_status_code => 'AVAILABLE'),
                                                               p_budget_amount  => null
                                                            );
                            EXCEPTION
                                WHEN FND_API.G_EXC_ERROR THEN
                                    l_return_status := FND_API.G_RET_STS_ERROR;
                            END;

                            IF (AMS_DEBUG_HIGH_ON) THEN
                                AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||
                                ' Return Status from AMS_ScheduleRules_PVT.Update_Schedule_Status API  '||l_return_status);
                            END IF;

                        END IF;
                    END IF;
                    -- Approvals Integration Ends here

                    Handle_Ret_Status_For_Import (
                                        p_return_status => l_return_status,
                                        p_object_name => l_objectNames(i),
                                        p_parent_object_id => l_campIds(i),
                                        p_error_records => l_error_recs,
                                        p_commit => FND_API.G_TRUE
                                );

                    FND_MSG_PUB.initialize; --initializes message table for next loop
                EXCEPTION

                        WHEN FND_API.G_EXC_ERROR THEN
                             l_return_status := FND_API.G_RET_STS_ERROR;

                             Handle_Ret_Status_For_Import (
                                        p_return_status => l_return_status,
                                        p_object_name => l_objectNames(i),
                                        p_parent_object_id => l_campIds(i),
                                        p_error_records => l_error_recs,
                                        p_purge_metrics => FND_API.G_TRUE
                                );

                        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                            AMS_ADI_COMMON_PVT.handle_fatal_error();

                            AMS_ADI_MEDIA_PLANNER_PVT.purge_import_metrics(
                                                   p_object_type => 'CSCH',
                                                   p_object_name => l_objectNames(i),
                                                   p_parent_type => 'CAMP',
                                                   p_parent_id => l_campIds(i)
                                                   );
                            COMMIT;

                            RAISE;

                        WHEN OTHERS THEN
                            AMS_ADI_COMMON_PVT.handle_fatal_error();

                            AMS_ADI_MEDIA_PLANNER_PVT.purge_import_metrics(
                                                   p_object_type => 'CSCH',
                                                   p_object_name => l_objectNames(i),
                                                   p_parent_type => 'CAMP',
                                                   p_parent_id => l_campIds(i)
                                                   );
                            COMMIT;

                            RAISE;
                END;

            END LOOP; -- l_objectNames LOOP

            FND_MSG_PUB.initialize; --initializes message table for next loop

            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_UTILITY_PVT.debug_message('Calling Complete batch');
            END IF;


            AMS_ADI_COMMON_PVT.complete_batch(
                        'AMS_ADI_CAMPAIGNS_INTERFACE',
                        p_upload_batch_id,
                        FND_API.G_FALSE,
                        FND_API.G_TRUE,
                        l_error_recs
                        );


            EXIT WHEN C_IMPORT_BATCH%NOTFOUND;
        END LOOP; -- C_IMPORT_BATCH loop
        CLOSE C_IMPORT_BATCH;

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'Calling Complete all');
        END IF;

        AMS_ADI_COMMON_PVT.complete_all();

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Private API: ' || pkg_name || '.' || l_api_name ||'Done with all');
        END IF;

        x_retcode := 0;
    EXCEPTION

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF (C_IMPORT_BATCH%ISOPEN)
            THEN
                CLOSE C_IMPORT_BATCH;
            END IF;

            x_retcode := 2;
            x_errbuf := SQLERRM;

            RAISE;

        WHEN OTHERS THEN
            IF (C_IMPORT_BATCH%ISOPEN)
            THEN
                CLOSE C_IMPORT_BATCH;
            END IF;

            x_retcode := 2;
            x_errbuf := SQLERRM;

            RAISE;

    END Import_Campaign_Schedules;




    --========================================================================
    -- PROCEDURE Get_Activity_Type_Code
    --    handles successful API call for a row during Web ADI ->
    --     Marketing integration call
    -- Purpose
    --    COMMIT successful row in database
    -- HISTORY
    --
    --========================================================================
    function Get_Activity_Type_Code (
                      p_activity_id IN NUMBER
                     )
    return VARCHAR2
    IS

        CURSOR C_GET_ACTIVITY_TYPE_CODE
        IS
        SELECT MEDIA_TYPE_CODE
        FROM AMS_MEDIA_B
        WHERE media_id = p_activity_id;

        l_activity_type_code VARCHAR2(30);

    BEGIN

        OPEN C_GET_ACTIVITY_TYPE_CODE;
        FETCH C_GET_ACTIVITY_TYPE_CODE into l_activity_type_code;
        CLOSE C_GET_ACTIVITY_TYPE_CODE;

        return l_activity_type_code;

    END Get_Activity_Type_Code;

    --========================================================================
    -- PROCEDURE Handle_Ret_Status_For_Import
    --    handles return status
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================
    procedure Handle_Ret_Status_For_Import (
                    p_return_status IN VARCHAR2,
                    p_object_name IN VARCHAR2,
                    p_parent_object_id IN NUMBER,
                    p_error_records IN OUT NOCOPY AMS_ADI_COMMON_PVT.ams_adi_error_rec_t,
                    p_commit IN VARCHAR2 := FND_API.G_FALSE,
                    p_purge_metrics IN VARCHAR2 := FND_API.G_FALSE
    )
    IS
    BEGIN
        IF(p_return_status =  FND_API.G_RET_STS_SUCCESS) THEN

            IF (FND_API.To_Boolean(p_purge_metrics))
            THEN
                AMS_ADI_MEDIA_PLANNER_PVT.purge_import_metrics(
                                                   p_object_type => 'CSCH',
                                                   p_object_name => p_object_name,
                                                   p_parent_type => 'CAMP',
                                                   p_parent_id => p_parent_object_id
                                                   );
            END IF;

            AMS_ADI_COMMON_PVT.handle_success_row(p_commit);

        ELSE
            ROLLBACK to Import_Schedule_PVT;

            AMS_ADI_COMMON_PVT.handle_error_row(
                                                FND_API.G_TRUE,
                                                FND_API.G_FALSE,
                                                NULL,
                                                NULL,
                                                NULL,
                                                p_object_name,
                                                p_parent_object_id,
                                                p_error_records --the table containing error records
                                                );

             AMS_ADI_MEDIA_PLANNER_PVT.purge_import_metrics(
                                                   p_object_type => 'CSCH',
                                                   p_object_name => p_object_name,
                                                   p_parent_type => 'CAMP',
                                                   p_parent_id => p_parent_object_id
                                                   );
        END IF;
    END Handle_Ret_Status_For_Import;


    --========================================================================
    -- PROCEDURE Associate_Product_Category
    --    Product/Category Association API CALL
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================
    procedure Associate_Product_Category(
                    p_product_id IN NUMBER,
                    p_category_id IN NUMBER,
                    p_schedule_id IN NUMBER,
                    p_primary_flag IN VARCHAR2,
                    x_act_product_id OUT NOCOPY NUMBER,
                    x_return_status       OUT NOCOPY    VARCHAR2,
                    x_msg_count           OUT NOCOPY    NUMBER,
                    x_msg_data            OUT NOCOPY    VARCHAR2
    )
    IS

        l_act_Product_rec AMS_ActProduct_PVT.act_Product_rec_type;
        l_act_product_id NUMBER;

    BEGIN
        l_act_Product_rec.ACT_PRODUCT_USED_BY_ID := p_schedule_id;
        l_act_Product_rec.ARC_ACT_PRODUCT_USED_BY := 'CSCH';
        l_act_Product_rec.CATEGORY_ID := p_category_id;
        l_act_Product_rec.CATEGORY_SET_ID := AMS_ActProduct_PVT.GET_CATEGORY_SET_ID();
        l_act_Product_rec.ORGANIZATION_ID := fnd_profile.value('AMS_ITEM_ORGANIZATION_ID');
        l_act_Product_rec.INVENTORY_ITEM_ID := p_product_id;
        l_act_Product_rec.LEVEL_TYPE_CODE := AMS_ActProduct_PVT.GET_LEVEL_TYPE_CODE( p_product_id,p_category_id);
        -- mayjain 31-Aug-2005 Support for Primary Flag
        l_act_Product_rec.PRIMARY_PRODUCT_FLAG := p_primary_flag;

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Calling AMS_ActProduct_PVT API');
        END IF;

        AMS_ActProduct_PVT.Create_Act_Product
                        ( p_api_version => 1.0,
                          p_init_msg_list  => FND_API.G_FALSE,
                          p_commit  => FND_API.G_FALSE,
                          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_act_Product_rec => l_act_Product_rec,
                          x_act_product_id => l_act_product_id
                        );

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Return Status from AMS_ActProduct_PVT API ' || x_return_status);
            AMS_UTILITY_PVT.Write_Conc_Log('x_act_product_id ' || to_char(l_act_product_id));
        END IF;

        x_act_product_id := l_act_product_id;
    END Associate_Product_Category;

        --========================================================================
    -- PROCEDURE Associate_Collaboration_Item
    --    Collaboration Association API CALL
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================
    procedure Associate_Collaboration_Item(
                    p_collab_type IN VARCHAR2,
                    p_collab_assoc_id IN NUMBER,
                    p_schedule_id IN NUMBER,
                    x_return_status       OUT NOCOPY    VARCHAR2,
                    x_msg_count           OUT NOCOPY    NUMBER,
                    x_msg_data            OUT NOCOPY    VARCHAR2
    )
    IS
        l_collab_assoc_rec_type AMS_Collab_assoc_PVT.collab_assoc_rec_type;
        l_collab_item_id NUMBER;
    BEGIN

        l_collab_assoc_rec_type.Collab_type := p_collab_type;
        l_collab_assoc_rec_type.collab_assoc_id := p_collab_assoc_id;
        l_collab_assoc_rec_type.obj_type := 'CSCH';
        l_collab_assoc_rec_type.obj_id := p_schedule_id;

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Calling AMS_Collab_assoc_PVT.Create_collab_Assoc API');
        END IF;

        AMS_Collab_assoc_PVT.Create_collab_Assoc(
                        p_api_version_number => 1.0,
                        p_init_msg_list  => FND_API.G_FALSE,
                        p_commit   => FND_API.G_FALSE,
                        p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_collab_assoc_rec_type => l_collab_assoc_rec_type,
                        x_collab_item_id => l_collab_item_id
        );

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Return Status from AMS_ActProduct_PVT API ' || x_return_status);
            AMS_UTILITY_PVT.Write_Conc_Log('l_collab_item_id ' || to_char(l_collab_item_id));
        END IF;

    END Associate_Collaboration_Item;


    --========================================================================
    -- PROCEDURE Associate_Web_Planner
    --    Collaboration Association API CALL
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================
    PROCEDURE Associate_Web_Planner(
                    p_application_id IN NUMBER,
                    p_placement_id IN NUMBER,
                    p_content_item_id IN NUMBER,
                    p_placement_title IN VARCHAR2,
                    p_activity_id IN NUMBER,
                    p_schedule_id IN NUMBER,
                    x_placement_mp_id     OUT NOCOPY  NUMBER,
                    x_placement_citem_id_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
                    x_msg_count              OUT NOCOPY  NUMBER,
                    x_msg_data                OUT NOCOPY  VARCHAR2,
                    x_return_status           OUT NOCOPY VARCHAR2
    )
    IS
        l_web_mp_rec AMS_WEBMARKETING_PVT.web_mp_track_rec_type;
    BEGIN

        l_web_mp_rec.application_id      := p_application_id;
        l_web_mp_rec.placement_id        := p_placement_id;
        l_web_mp_rec.content_item_id     := p_content_item_id;
        l_web_mp_rec.activity_id         := p_activity_id;
        l_web_mp_rec.placement_mp_title  := p_placement_title;
        l_web_mp_rec.object_used_by_id   := p_schedule_id;
        l_web_mp_rec.object_used_by      := 'CSCH';
        l_web_mp_rec.publish_flag        := null; -- Web Planner API will take care of the Publish Flag
        l_web_mp_rec.max_recommendations := 1;
        l_web_mp_rec.display_priority    := null;

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Calling AMS_WEBMARKETING_PVT.CREATE_WEB_PLCE_ASSOC API');
        END IF;

        AMS_WEBMARKETING_PVT.CREATE_WEB_PLCE_ASSOC(
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => FND_API.G_FALSE,
                        p_commit                => FND_API.G_FALSE,
                        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                        p_web_mp_rec            => l_web_mp_rec,
                        x_placement_mp_id       => x_placement_mp_id,
                        x_placement_citem_id_tbl => x_placement_citem_id_tbl,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        x_return_status         => x_return_status
        );

        IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.Write_Conc_Log('Return Status from AMS_WEBMARKETING_PVT.CREATE_WEB_PLCE_ASSOC API ' || x_return_status);
            AMS_UTILITY_PVT.Write_Conc_Log('x_placement_mp_id ' || to_char(x_placement_mp_id));
        END IF;

    END Associate_Web_Planner;

        --========================================================================
    -- PROCEDURE Get_Object_Source_Code
    --    Get the Source Code of an Object
    -- Purpose
    --
    -- HISTORY
    --
    --========================================================================
    FUNCTION Get_Object_Source_Code(
                    p_object_type IN VARCHAR2,
                    p_object_id IN NUMBER
    )
    RETURN VARCHAR2
    IS
        l_source_code VARCHAR2(30);

        CURSOR C_SOURCE_CODE (p_object_type IN VARCHAR2, p_object_id IN NUMBER)
        IS
        SELECT
          source_code
        FROM
          ams_source_codes
        WHERE
          ARC_SOURCE_CODE_FOR = p_object_type and
          SOURCE_CODE_FOR_ID = p_object_id and
          active_flag = 'Y';

    BEGIN

        OPEN C_SOURCE_CODE(p_object_type, p_object_id);
        FETCH C_SOURCE_CODE INTO l_source_code;
        CLOSE C_SOURCE_CODE;

        return l_source_code;

    END Get_Object_Source_Code;




END AMS_ADI_CAMP_SCHED_PVT;

/
